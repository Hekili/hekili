-- DeathKnightUnholy.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 252 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

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

        elseif k == "current_fractional" then
            local current = t.current
            local fraction = t.cooldown and ( t.time_to_next / t.cooldown ) or 0

            return current + fraction

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

spec:RegisterResource( Enum.PowerType.RunicPower, {
    -- Frost Fever Tick RP (20% chance to generate 4 RP)
    frost_fever_tick = {
        aura = "frost_fever",

        last = function ()
            local app = state.dot.frost_fever.applied
            return app + floor( state.query_time - app )
        end,

        interval = 1,
        value = function ()
            -- 20% chance * 4 RP = 0.8 RP per tick
            -- We'll lowball to 0.6 RP for conservative estimate
            return 0.6 * min( state.active_dot.frost_fever or 0, 5 )
        end,
    },

    -- Runic Attenuation (mainhand swings 50% chance to generate 3 RP)
    runic_attenuation = {
        talent = "runic_attenuation",
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time
            if state.mainhand_speed == 0 then
                return 0
            else
                return swing + floor( ( t - swing ) / state.mainhand_speed ) * state.mainhand_speed
            end
        end,

        interval = "mainhand_speed",

        stop = function () return state.swings.mainhand == 0 end,

        value = function ()
            -- 50% chance * 3 RP = 1.5 RP per swing
            -- We'll lowball to 1.0 RP
            return state.talent.runic_attenuation.enabled and 1.0 or 0
        end,
    }
} )

local spendHook = function( amt, resource, noHook )
    if amt > 0 and resource == "runes" and active_dot.shackle_the_unworthy > 0 then
        reduceCooldown( "shackle_the_unworthy", 4 * amt )
    end
end

spec:RegisterHook( "spend", spendHook )

-- Talents
spec:RegisterTalents( {

    -- Death Knight
    antimagic_barrier              = {  76046,  205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by $s1 sec and increases its duration and amount absorbed by $s2%
    antimagic_zone                 = {  76065,   51052, 1 }, -- Places an Anti-Magic Zone for $s1 sec, reducing the magic damage taken by party or raid members by $s2%
    asphyxiate                     = {  76064,  221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $s1 sec
    assimilation                   = {  76048,  374383, 1 }, -- The cooldown of Anti-Magic Zone is reduced by $s1 sec and its duration is increased by $s2 sec
    blinding_sleet                 = {  76044,  207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for $s1 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by $s2% for $s3 sec
    blood_draw                     = {  76056,  374598, 1 }, -- When you fall below $s1% health you drain $s2 health from nearby enemies, the damage you take is reduced by $s3% and your Death Strike cost is reduced by $s4 for $s5 sec. Can only occur every $s6 min
    blood_scent                    = {  76078,  374030, 1 }, -- Increases Leech by $s1%
    brittle                        = {  76061,  374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal $s1% increased damage for $s2 sec
    cleaving_strikes               = {  76073,  316916, 1 }, -- Clawing Shadows hits up to $s1 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for $s2 sec
    coldthirst                     = {  76083,  378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants $s1 Runic Power and reduces its cooldown by $s2 sec
    control_undead                 = {  76059,  111673, 1 }, -- Dominates the target undead creature up to level $s1, forcing it to do your bidding for $s2 min
    death_pact                     = {  76075,   48743, 1 }, -- Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s2% of your max health for $s3 sec
    death_strike                   = {  76071,   49998, 1 }, -- Focuses dark power into a strike that deals $s$s2 Physical damage and heals you for $s3% of all damage taken in the last $s4 sec, minimum $s5% of maximum health
    deaths_echo                    = { 102007,  356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have $s1 additional charge
    deaths_reach                   = { 102006,  276079, 1 }, -- Increases the range of Death Grip by $s1 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip
    enfeeble                       = {  76060,  392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by $s1% and the damage they deal to you by $s2% for $s3 sec
    gloom_ward                     = {  76052,  391571, 1 }, -- Absorbs are $s1% more effective on you
    grip_of_the_dead               = {  76057,  273952, 1 }, -- Defile reduces the movement speed of enemies within its area by $s1%, decaying by $s2% every sec
    ice_prison                     = {  76086,  454786, 1 }, -- Chains of Ice now also roots enemies for $s1 sec but its cooldown is increased to $s2 sec
    icebound_fortitude             = {  76081,   48792, 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s1% for $s2 sec
    icy_talons                     = {  76085,  194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by $s1% for $s2 sec, stacking up to $s3 times
    improved_death_strike          = {  76067,  374277, 1 }, -- Death Strike's cost is reduced by $s1, and its healing is increased by $s2%
    insidious_chill                = {  76051,  391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by $s1% for $s2 sec, stacking up to $s3 times
    march_of_darkness              = {  76074,  391546, 1 }, -- Death's Advance grants an additional $s1% movement speed over the first $s2 sec
    mind_freeze                    = {  76084,   47528, 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for $s1 sec
    null_magic                     = { 102008,  454842, 1 }, -- Magic damage taken is reduced by $s1% and the duration of harmful Magic effects against you are reduced by $s2%
    osmosis                        = {  76088,  454835, 1 }, -- Anti-Magic Shell increases healing received by $s1%
    permafrost                     = {  76066,  207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to $s1% of the damage dealt
    proliferating_chill            = { 101708,  373930, 1 }, -- Chains of Ice affects $s1 additional nearby enemy
    raise_dead                     = {  76072,   46585, 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts $s1 min
    rune_mastery                   = {  76079,  374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by $s1% for $s2 sec
    runic_attenuation              = {  76045,  207104, 1 }, -- Auto attacks have a chance to generate $s1 Runic Power
    runic_protection               = {  76055,  454788, 1 }, -- Your chance to be critically struck is reduced by $s1% and your Armor is increased by $s2%
    sacrificial_pact               = {  76060,  327574, 1 }, -- Sacrifice your ghoul to deal $s$s2 Shadow damage to all nearby enemies and heal for $s3% of your maximum health. Deals reduced damage beyond $s4 targets
    soul_reaper                    = {  76063,  343294, 1 }, -- Strike an enemy for $s$s3 Shadowfrost damage and afflict the enemy with Soul Reaper. After $s4 sec, if the target is below $s5% health this effect will explode dealing an additional $s$s6 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption
    subduing_grasp                 = {  76080,  454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by $s1% for $s2 sec
    suppression                    = {  76087,  374049, 1 }, -- Damage taken from area of effect attacks reduced by $s1%. When suffering a loss of control effect, this bonus is increased by an additional $s2% for $s3 sec
    unholy_bond                    = {  76076,  374261, 1 }, -- Increases the effectiveness of your Runeforge effects by $s1%
    unholy_endurance               = {  76058,  389682, 1 }, -- Increases Lichborne duration by $s1 sec and while active damage taken is reduced by $s2%
    unholy_momentum                = {  76069,  374265, 1 }, -- Increases Haste by $s1%
    unyielding_will                = {  76050,  457574, 1 }, -- Anti-Magic Shell now removes all harmful magical effects when activated, but its cooldown is increased by $s1 sec
    vestigial_shell                = {  76053,  454851, 1 }, -- Casting Anti-Magic Shell grants $s2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to $s$s3 magic damage and reduces the duration of harmful Magic effects against them by $s4%
    veteran_of_the_third_war       = {  76068,   48263, 1 }, -- Stamina increased by $s1%
    will_of_the_necropolis         = {  76054,  206967, 2 }, -- Damage taken below $s1% Health is reduced by $s2%
    wraith_walk                    = {  76077,  212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $s2 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below $s3%

    -- Unholy
    all_will_serve                 = {  76181,  194916, 1 }, -- Raise Dead summons an additional skeletal archer at your command that shoots Blighted Arrows. Blighted Arrow
    apocalypse                     = {  76185,  275699, 1 }, -- Bring doom upon the enemy, dealing $s$s2 Shadow damage and bursting up to $s3 Festering Wounds on the target. Summons $s4 Army of the Dead ghouls for $s5 sec. Generates $s6 Runes
    army_of_the_dead               = {  76196,   42650, 1 }, -- Summons a legion of ghouls who swarms your enemies, fighting anything they can for $s1 sec
    bursting_sores                 = {  76164,  207264, 1 }, -- Bursting a Festering Wound deals $s2% more damage, and deals $s$s3 Shadow damage to up to $s4 nearby enemies
    clawing_shadows                = { 107574,  207311, 1 }, -- Deals $s$s2 Shadow damage and causes $s3 Festering Wound to burst. Critical strikes cause the Festering Wound to burst for $s4% increased damage
    coil_of_devastation            = {  76156,  390270, 1 }, -- Death Coil causes the target to take an additional $s1% of the direct damage dealt over $s2 sec
    commander_of_the_dead          = {  76149,  390259, 1 }, -- Dark Transformation also empowers your Gargoyle and Army of the Dead for $s1 sec, increasing their damage by $s2%
    dark_transformation            = {  76187,   63560, 1 }, -- Your ghoul deals $s$s2 Shadow damage to $s3 nearby enemies and transforms into a powerful undead monstrosity for $s4 sec. Granting them $s5% energy and the ghoul's abilities are empowered and take on new functions while the transformation is active
    death_rot                      = {  76158,  377537, 1 }, -- Death Coil and Epidemic debilitate your enemy applying Death Rot causing them to take $s1% increased Shadow damage, up to $s2% from you for $s3 sec. If Death Coil or Epidemic consume Sudden Doom it applies two stacks of Death Rot
    decomposition                  = {  76154,  455398, 2 }, -- Virulent Plague has a chance to abruptly flare up, dealing $s1% of the damage it dealt to target in the last $s2 sec. When this effect triggers, the duration of your active minions are increased by $s3 sec, up to $s4 sec
    defile                         = {  76161,  152280, 1 }, -- Defile the targeted ground, dealing $s$s2 Shadow damage to all enemies over $s3 sec. While you remain within your Defile, your Clawing Shadows will hit $s4 enemies near the target. Every sec, if any enemies are standing in the Defile, it grows in size and deals increased damage
    desecrate                      = {  76161, 1234559, 1 }, -- Death and Decay deals $s1% more damage, has its cooldown reduced by $s2 sec, and is replaced by Desecrate after it is cast. Desecrate Consume your Death and Decay and crush your enemies within, dealing $s5% of its remaining damage instantly. Applies or bursts $s6-$s7 Festering Wounds, depending on whether the target is already affected by Festering Wounds. Grants you the benefits of standing in Death and Decay
    doomed_bidding                 = {  76176,  455386, 1 }, -- Consuming Sudden Doom calls upon a Magus of the Dead to assist you for $s1 sec
    ebon_fever                     = {  76160,  207269, 1 }, -- Diseases deal $s1% more damage over time in half the duration
    eternal_agony                  = {  76182,  390268, 1 }, -- Death Coil and Epidemic increase the duration of Dark Transformation by $s1 sec
    festering_scythe               = {  76193,  455397, 1 }, -- Every $s2 Festering Wound you burst empowers your next Festering Strike to become Festering Scythe. Festering Scythe Sweep through all enemies within $s5 yds in front of you, dealing $s$s6 Shadow damage and infecting them with $s7-$s8 Festering Wounds
    festering_strike               = {  76189,   85948, 1 }, -- Strikes for $s$s3 Physical damage and infects the target with $s4-$s5 Festering Wounds.  Festering Wound A pustulent lesion that will burst on death or when damaged by Clawing Shadows, dealing $s$s8 Shadow damage and generating $s9 Runic Power
    festermight                    = {  76152,  377590, 2 }, -- Popping a Festering Wound increases your Strength by $s1% for $s2 sec stacking. Multiple instances may overlap
    foul_infections                = {  76162,  455396, 1 }, -- Your diseases deal $s1% more damage and have a $s2% increased chance to critically strike
    ghoulish_frenzy                = {  76194,  377587, 1 }, -- Dark Transformation also increases the attack speed and damage of you and your Monstrosity by $s1%
    grave_mastery                  = {  76186, 1238900, 1 }, -- Critical strike damage of your minions is increased by $s1%
    harbinger_of_doom              = {  76178,  276023, 1 }, -- Sudden Doom triggers $s1% more often, can accumulate up to $s2 charges, and increases the damage of your next Death Coil by $s3% or Epidemic by $s4%
    improved_death_coil            = {  76184,  377580, 1 }, -- Death Coil deals $s1% additional damage and seeks out $s2 additional nearby enemy
    improved_festering_strike      = {  76192,  316867, 1 }, -- Festering Strike and Festering Wound damage increased by $s1%
    infected_claws                 = {  76195,  207272, 1 }, -- Your ghoul's Claw attack has a $s1% chance to cause a Festering Wound on the target
    legion_of_souls                = {  76153,  383269, 1 }, -- Summon a legion of clawing souls to assist you, dealing $s$s2 Shadow damage and applying up to $s3 Festering Wounds over $s4 sec to all nearby enemies. Deals reduced damage beyond $s5 targets. Grants you the benefits of standing in Death and Decay
    magus_of_the_dead              = {  76148,  390196, 1 }, -- Apocalypse and Army of the Dead also summon a Magus of the Dead who hurls Frostbolts and Shadow Bolts at your foes
    menacing_magus                 = { 101882,  455135, 1 }, -- Your Magus of the Dead Shadow Bolt now fires a volley of Shadow Bolts at up to $s1 nearby enemies
    morbidity                      = {  76197,  377592, 2 }, -- Diseased enemies take $s1% increased damage from you per disease they are affected by
    plague_mastery                 = {  76186,  390166, 1 }, -- Critical strike damage of your diseases is increased by $s1%
    plaguebringer                  = {  76183,  390175, 1 }, -- Scourge Strike causes your disease damage to occur $s1% more quickly for $s2 sec
    raise_abomination              = {  76153,  455395, 1 }, -- Raises an Abomination for $s1 sec which wanders and attacks enemies, applying Festering Wound when it melees targets, and affecting all those nearby with Virulent Plague
    raise_dead_2                   = {  76188,   46584, 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time
    reaping                        = {  76179,  377514, 1 }, -- Your Soul Reaper, Clawing Shadows, Festering Strike, and Death Coil deal $s1% additional damage to enemies below $s2% health. Soul Reaper's execute effect increases the damage of your minions by $s3% for $s4 sec
    rotten_touch                   = {  76175,  390275, 1 }, -- Sudden Doom causes your next Death Coil to also increase your Clawing Shadows damage against the target by $s1% for $s2 sec
    scourge_strike                 = {  76190,   55090, 1 }, -- An unholy strike that deals $s$s3 Physical damage and $s$s4 Shadow damage, and causes $s5 Festering Wound to burst. Critical strikes cause the Festering Wound to burst for $s6% increased damage
    sudden_doom                    = {  76191,   49530, 1 }, -- Your auto attacks have a $s1% chance to make your next Death Coil or Epidemic to critically strike. Additionally, your next Death Coil will cost $s2 less Runic Power and burst $s3 Festering Wound
    summon_gargoyle                = {  76176,   49206, 1 }, -- Summon a Gargoyle into the area to bombard the target for $s1 sec. The Gargoyle gains $s2% increased damage for every $s3 Runic Power you spend. Generates $s4 Runic Power
    superstrain                    = {  76155,  390283, 1 }, -- Your Virulent Plague also applies Frost Fever and Blood Plague at $s1% effectiveness
    unholy_assault                 = {  76151,  207289, 1 }, -- Strike your target dealing $s$s2 Shadow damage, applying $s3 Festering Wounds and sending you into an Unholy Frenzy increasing all damage done by $s4% for $s5 sec
    unholy_aura                    = {  76150,  377440, 2 }, -- All enemies within $s1 yards take $s2% increased damage from your minions
    unholy_blight                  = {  76163,  460448, 1 }, -- Dark Transformation surrounds your ghoul with a vile swarm of insects for $s1 sec, stinging all nearby enemies and infecting them with Virulent Plague and an unholy disease that deals $s2 damage over $s3 sec, stacking up to $s4 times
    unholy_pact                    = {  76180,  319230, 1 }, -- Dark Transformation creates an unholy pact that forms shadowy chains between you and your ghoul, dealing $s$s2 Shadow damage over $s3 sec to enemies caught in between

    -- Rider Of The Apocalypse
    a_feast_of_souls               = {  95042,  444072, 1 }, -- While you have $s1 or more Horsemen aiding you, your Runic Power spending abilities deal $s2% increased damage
    apocalypse_now                 = {  95041,  444040, 1 }, -- Army of the Dead and Frostwyrm's Fury call upon all $s1 Horsemen to aid you for $s2 sec
    death_charge                   = {  95060,  444010, 1 }, -- Call upon your Death Charger to break free of movement impairment effects. For $s1 sec, while upon your Death Charger your movement speed is increased by $s2%, you cannot be slowed below $s3% of normal speed, and you are immune to forced movement effects and knockbacks
    fury_of_the_horsemen           = {  95042,  444069, 1 }, -- Every $s1 Runic Power you spend extends the duration of the Horsemen's aid in combat by $s2 sec, up to $s3 sec
    horsemens_aid                  = {  95037,  444074, 1 }, -- While at your aid, the Horsemen will occasionally cast Anti-Magic Shell on you and themselves at $s1% effectiveness. You may only benefit from this effect every $s2 sec
    hungering_thirst               = {  95044,  444037, 1 }, -- The damage of your diseases and Death Coil are increased by $s1%
    mawsworn_menace                = {  95054,  444099, 1 }, -- Clawing Shadows deals $s1% increased damage and the cooldown of your Defile is reduced by $s2
    mograines_might                = {  95067,  444047, 1 }, -- Your damage is increased by $s1% and you gain the benefits of your Death and Decay while inside Mograine's Death and Decay
    nazgrims_conquest              = {  95059,  444052, 1 }, -- If an enemy dies while Nazgrim is active, the strength of Apocalyptic Conquest is increased by $s1%. Additionally, each Rune you spend increase its value by $s2%
    on_a_paler_horse               = {  95060,  444008, 1 }, -- While outdoors you are able to mount your Acherus Deathcharger in combat
    pact_of_the_apocalypse         = {  95037,  444083, 1 }, -- When you take damage, $s1% of the damage is redirected to each active horsemen
    riders_champion                = {  95066,  444005, 1 }, -- Spending Runes has a chance to call forth the aid of a Horsemen for $s2 sec. Mograine Casts Death and Decay at his location that follows his position. Whitemane Casts Undeath on your target dealing $s$s3 Shadowfrost damage per stack every $s4 sec, for $s5 sec. Each time Undeath deals damage it gains a stack. Cannot be refreshed. Trollbane Casts Chains of Ice on your target slowing their movement speed by $s6% and increasing the damage they take from you by $s7% for $s8 sec. Nazgrim While Nazgrim is active you gain Apocalyptic Conquest, increasing your Strength by $s9%
    trollbanes_icy_fury            = {  95063,  444097, 1 }, -- Clawing Shadows shatters Trollbane's Chains of Ice when hit, dealing $s$s2 Shadowfrost damage to nearby enemies, and slowing them by $s3% for $s4 sec. Deals reduced damage beyond $s5 targets
    whitemanes_famine              = {  95047,  444033, 1 }, -- When Clawing Shadows damages an enemy affected by Undeath it gains $s1 stack and infects another nearby enemy

    -- Sanlayn
    bloodsoaked_ground             = {  95048,  434033, 1 }, -- While you are within your Death and Decay, your physical damage taken is reduced by $s1% and your chance to gain Vampiric Strike is increased by $s2%
    bloody_fortitude               = {  95056,  434136, 1 }, -- Icebound Fortitude reduces all damage you take by up to an additional $s1% based on your missing health. Killing an enemy that yields experience or honor reduces the cooldown of Icebound Fortitude by $s2 sec
    frenzied_bloodthirst           = {  95065,  434075, 1 }, -- Essence of the Blood Queen stacks $s1 additional times and increases the damage of your Death Coil and Death Strike by $s2% per stack
    gift_of_the_sanlayn            = {  95053,  434152, 1 }, -- While Dark Transformation is active you gain Gift of the San'layn. Gift of the San'layn increases the effectiveness of your Essence of the Blood Queen by $s1%, and Vampiric Strike replaces your Clawing Shadows for the duration
    incite_terror                  = {  95040,  434151, 1 }, -- Vampiric Strike and Clawing Shadows cause your targets to take $s1% increased Shadow damage, up to $s2% for $s3 sec. Vampiric Strike benefits from Incite Terror at $s4% effectiveness
    infliction_of_sorrow           = {  95033,  434143, 1 }, -- When Vampiric Strike damages an enemy affected by your Virulent Plague, it extends the duration of the disease by $s1 sec, and deals $s2% of the remaining damage to the enemy. After Gift of the San'layn ends, you gain a charge of Defile, and your next Clawing Shadows consumes the disease to deal $s3% of their remaining damage to the target
    newly_turned                   = {  95064,  433934, 1 }, -- Raise Ally revives players at full health and grants you and your ally an absorb shield equal to $s1% of your maximum health
    pact_of_the_sanlayn            = {  95055,  434261, 1 }, -- You store $s1% of all Shadow damage dealt into your Blood Beast to explode for additional damage when it expires
    sanguine_scent                 = {  95055,  434263, 1 }, -- Your Death Coil, Epidemic and Death Strike have a $s1% increased chance to trigger Vampiric Strike when damaging enemies below $s2% health
    the_blood_is_life              = {  95046,  434260, 1 }, -- Apocalypse summons a Blood Beast to attack your enemy for $s1 sec. Each time the Blood Beast attacks, it stores a portion of the damage dealt. When the Blood Beast dies, it explodes, dealing $s2% of the damage accumulated to nearby enemies and healing the Death Knight for the same amount. Deals reduced damage beyond $s3 targets
    vampiric_aura                  = {  95056,  434100, 1 }, -- Your Leech is increased by $s1%. While Lichborne is active, the Leech bonus of this effect is increased by $s2%, and it affects $s3 allies within $s4 yds
    vampiric_speed                 = {  95064,  434028, 1 }, -- Death's Advance and Wraith Walk movement speed bonuses are increased by $s1%. Activating Death's Advance or Wraith Walk increases $s2 nearby allies movement speed by $s3% for $s4 sec
    vampiric_strike                = {  95051,  433901, 1 }, -- Your Death Coil, Epidemic and Death Strike have a $s1% chance to make your next Clawing Shadows become Vampiric Strike. Vampiric Strike heals you for $s2% of your maximum health and grants you Essence of the Blood Queen, increasing your Haste by $s3%, up to $s4% for $s5 sec
    visceral_strength              = {  95045,  434157, 1 }, -- When Sudden Doom is consumed, you gain $s1% Strength for $s2 sec. When Scourge Strike consumes Virulent Plague, your next Outbreak costs no Runes and casts Death Coil or Epidemic at $s3% effectiveness, whichever you most recently cast
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bloodforged_armor              = 5585, -- (410301) Death Strike reduces all Physical damage taken by $s1% for $s2 sec
    dark_simulacrum                =   41, -- (77606) Places a dark ward on an enemy player that persists for $s1 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell
    doomburst                      = 5436, -- (356512) Sudden Doom also causes your next Death Coil to burst up to $s1 Festering Wounds and reduce the target's movement speed by $s2% per burst. Lasts $s3 sec
    life_and_death                 =   40, -- (288855) When targets afflicted by your Virulent Plague are healed, you are also healed for $s1% of the amount. In addition, your Virulent Plague now erupts for $s2% of normal eruption damage when dispelled
    necromancers_bargain           = 3746, -- (288848) The cooldown of your Apocalypse is reduced by $s1 sec, but your Apocalypse no longer summons ghouls but instead applies Crypt Fever to the target. Crypt Fever Deals up to $s2% of the targets maximum health in Shadow damage over $s3 sec. Healing spells cast on this target will refresh the duration of Crypt Fever
    necrotic_wounds                =  149, -- (356520) Bursting a Festering Wound converts it into a Necrotic Wound, absorbing $s1% of all healing received for $s2 sec. Max $s3 stacks. Adding a stack does not refresh the duration
    reanimation                    =  152, -- (210128) Reanimates a nearby corpse, summoning a zombie for $s1 sec that slowly moves towards your target. If your zombie reaches its target, it explodes after $s2 sec. The explosion stuns all enemies within $s3 yards for $s4 sec and deals $s5% of their health in Shadow damage
    rot_and_wither                 = 5511, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to $s1% of damage dealt
    spellwarden                    = 5590, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by $s1 sec
    strangulate                    = 5430, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for $s1 sec
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bloodforged_armor              = 5585, -- (410301) Death Strike reduces all Physical damage taken by $s1% for $s2 sec
    dark_simulacrum                =   41, -- (77606) Places a dark ward on an enemy player that persists for $s1 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell
    doomburst                      = 5436, -- (356512)
    life_and_death                 =   40, -- (288855)
    necromancers_bargain           = 3746, -- (288848)
    necrotic_wounds                =  149, -- (356520)
    reanimation                    =  152, -- (210128) Reanimates a nearby corpse, summoning a zombie for $s1 sec that slowly moves towards your target. If your zombie reaches its target, it explodes after $s2 sec. The explosion stuns all enemies within $s3 yards for $s4 sec and deals $s5% of their health in Shadow damage
    rot_and_wither                 = 5511, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to $s1% of damage dealt
    spellwarden                    = 5590, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by $s1 sec
    strangulate                    = 5430, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for $s1 sec
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
    -- https://wowhead.com/spell=1235372
    blood_plague = {
        id = 1235372,
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
        id = function() return talent.apocalypse.enabled and 1233448 or 63560 end,
        duration = 15,
        type = "Magic",
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = FindUnitBuffByID( "pet", talent.apocalypse.enabled and 1233448 or 63560 )

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
    --[[ Inflicts $s1 Shadow damage every sec.
    death_and_decay = {
        id = 391988,
        duration = 3600,
        tick_time = 1.0,
        max_stack = 1
    }, ]]
    death_and_decay = {
        id = 188290,
        duration = 10,
        max_stack = 1,
        copy = { "death_and_decay_cleave_buff", "defile_buff" }
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
    desecrate = {
        id = 1234689,
        duration = 10,
        max_stack = 1
    },

    -- Haste increased by ${$W1}.1%. $?a434075[Damage of Death Strike and Death Coil increased by $W2%.][]
    essence_of_the_blood_queen = {
        id = 433925,
        duration = 20.0,
        max_stack = function() return 5 + ( talent.frenzied_bloodthirst.enabled and 2 or 0 ) end
    },
    festering_scythe_ready = {
        id = 458123,
        duration = 30,
        max_stack = 1,
        copy = "festering_scythe"
    },
    festering_scythe_stack = {
        id = 459238,
        duration = 3600,
        max_stack = 20,
        copy = "festering_scythe_stacks"
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
    -- https://wowhead.com/spell=1235371
    frost_fever = {
        id = 1235371,
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
        duration = 30,
        max_stack = 1
    },
    -- Time between auto-attacks increased by $w1%.
    -- https://www.wowhead.com/spell=391568
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
    },
    -- Legion of Souls Dealing $s$s2 Shadow damage and applying a Festering Wound to nearby enemies every $s3 sec. $s4 seconds remaining
    -- https://www.wowhead.com/spell=383269
    legion_of_souls = {
        id = 383269,
        duration = 12,
        max_stack = 1
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
        -- https://www.wowhead.com/spell=1235261
    reaping = {
        id = 1235261,
        duration = 10,
        max_stack = 1
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
    -- New: Tracking aura pops if all nearby enemies have Festering Wounds; but it is a LIAR.
    scourge_strike = {
        id = 1227017,
        duration = 30,
        max_stack = function() return true_active_enemies end,
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
        max_stack = 1,
        copy = "unholy_frenzy"
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
    -- Visceral Strength Your Strength is increased by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=434159
    visceral_strength_buff = {
        id = 434159,
        duration = 5,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=1234532
    visceral_strength_unholy = {
        id = 1234532,
        duration = 30,
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
        id = 237409,
        spell = "apocalypse",
        duration = 20,
        copy = "army_ghoul",
    },
    magus_of_the_dead = {
        id = 163366,
        spell = "apocalypse",
        duration = 20,
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
        copy = "mograine"
    },
    king_thoras_trollbane = {
        id = 221635,
        spell = "army_of_the_dead",
        duration = 20,
        copy = "trollbane"
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
        copy = "whitemane"
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
    blood_beast = {
        id = 217228
    }
} )

local dmg_events = {
    SPELL_DAMAGE = 1,
    SPELL_PERIODIC_DAMAGE = 1
}

local aura_removals = {
    SPELL_AURA_REMOVED = 1,
    SPELL_AURA_REMOVED_DOSE = 1
}

local dnd_damage_ids = {
    [52212] = "death_and_decay",
    [156000] = "defile"
}

local last_dnd_tick, dnd_spell = 0, "death_and_decay"

local sd_consumers = {
    death_coil = "doomed_bidding_magus_coil",
    epidemic = "doomed_bidding_magus_epi"
}

local db_casts = {}
local doomed_biddings = {}

local last_bb_summon = 0

-- 20250426: Decouple Death and Decay *buff* from dot.death_and_decay.ticking
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID ~= state.GUID then return end

    if dnd_damage_ids[ spellID ] and dmg_events[ subtype ] then
        last_dnd_tick = GetTime()
        dnd_spell = dnd_damage_ids[ spellID ]
        return
    end

    if state.talent.doomed_bidding.enabled then
        if subtype == "SPELL_CAST_SUCCESS" then
            local consumer = class.abilities[ spellID ]
            if not consumer then return end
            consumer = consumer and consumer.key

            if sd_consumers[ consumer ] then
                db_casts[ GetTime() ] = consumer

            end
            return
        end

        if spellID == class.auras.sudden_doom.id and aura_removals[ subtype ] and #doomed_biddings > 0 then
            local now = GetTime()
            for time, consumer in pairs( db_casts ) do
                if now - time < 0.5 then
                    doomed_biddings[ now + 6 ] = sd_consumers[ consumer ]
                    db_casts[ time ] = nil
                end
            end
            return
        end
    end

    if subtype == "SPELL_SUMMON" and spellID == 434237 then
        last_bb_summon = GetTime()
        return
    end
end )

local dnd_model = setmetatable( {}, {
    __index = function( t, k )
        if k == "ticking" then
            -- Disabled
            -- if state.query_time - class.abilities.any_dnd.lastCast < 10 then return true end
            return buff.death_and_decay.up

        elseif k == "remains" then
            return buff.death_and_decay.remains

        end

        return false
    end
} )

spec:RegisterStateTable( "death_and_decay", dnd_model )
spec:RegisterStateTable( "defile", dnd_model )

-- Expression to deal with APL weirdness between the 2 spells. SimC has them as separate spells, but only refers to the CD of one of them for conditions
spec:RegisterStateExpr( "dark_transformation_cooldown", function ()
    if talent.apocalypse.enabled then
        return cooldown.apocalypse.remains
    else
        return cooldown.dark_transformation.remains
    end
end )

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
    if Hekili.ActiveDebug then Hekili:Debug( "Rune Regeneration Time: 1=%.2f, 2=%.2f, 3=%.2f, 4=%.2f, 5=%.2f, 6=%.2f\n", runes.time_to_1, runes.time_to_2, runes.time_to_3, runes.time_to_4, runes.time_to_5, runes.time_to_6 ) end
end )

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237631, 237629, 237627, 237628, 237626 },
        },
    tww2 = {
        items = { 229253, 229251, 229256, 229254, 229252 },
        auras = {
            -- https://www.wowhead.com/spell=1216813
            winning_streak_unholy = {
                id = 1216813,
                duration = 3600,
                max_stack = 10,
                copy = "winning_streak" -- I'm stubborn.
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

local wound_spender_set = false

local TriggerInflictionOfSorrow = setfenv( function ()
    applyBuff( "infliction_of_sorrow" )
    gainCharges( "death_and_decay", 1 )
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

spec:RegisterHook( "TALENTS_UPDATED", function()
    class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any " .. class.abilities.death_and_decay.name .. "]|r"
    local dnd = talent.defile.enabled and "defile" or "death_and_decay"

    class.abilities.any_dnd = class.abilities[ dnd ]
    rawset( cooldown, "any_dnd", nil )
    rawset( cooldown, "death_and_decay", nil )
    rawset( cooldown, "defile", nil )

    if dnd == "defile" then rawset( cooldown, "death_and_decay", cooldown.defile )
    else rawset( cooldown, "defile", cooldown.death_and_decay ) end
end )

local ghoul_applicators = {
    raise_abomination = {
        abomination = { 30 },
        abom_magus = { 30, "magus_of_the_dead" },
    },

    army_of_the_dead = {
        army_ghoul = { 30 },
        army_magus = { 30, "magus_of_the_dead" },

    },

    apocalypse = {
        apoc_ghoul = { 20 },
        apoc_magus = { 20, "magus_of_the_dead" }
    },

    summon_gargoyle = {
        gargoyle = { 25 }
    }
}

spec:RegisterHook( "reset_precast", function ()
    if totem.dark_arbiter.remains > 0 then
        summonPet( "dark_arbiter", totem.dark_arbiter.remains )
    elseif totem.gargoyle.remains > 0 then
        summonPet( "gargoyle", totem.gargoyle.remains )
    end

    local control_expires = action.control_undead.lastCast + 300
    if control_expires > now and pet.up and not pet.ghoul.up then
        summonPet( "controlled_undead", control_expires - now )
    end

    for spell, ghouls in pairs( ghoul_applicators ) do
        local cast_time = action[ spell ].lastCast

        for ghoul, info in pairs( ghouls ) do
            dismissPet( ghoul )

            if cast_time > 0 then
                local expires = cast_time + info[ 1 ]
                local required = info[ 2 ]

                if expires > now and ( not required or talent[ required ].enabled ) then
                    summonPet( ghoul, expires - now )
                end
            end
        end
    end

    if talent.doomed_bidding.enabled then
        dismissPet( "doomed_bidding_magus_epi" )
        dismissPet( "doomed_bidding_magus_coil" )

        for time, magus in pairs( doomed_biddings ) do
            local remains = time - now
            if remains <= 0 then doomed_biddings[ time ] = nil
            elseif remains > pet[ magus ].remains then summonPet( magus, remains ) end
        end
    end

    local bb_remains = last_bb_summon + 10 - now
    if bb_remains > 0 then summonPet( "blood_beast", bb_remains )
    else dismissPet( "blood_beast" ) end

    if buff.death_and_decay.up then
        local duration = buff.death_and_decay.duration
        if duration > 4 then
            if Hekili.ActiveDebug then Hekili:Debug( "Death and Decay buff extended by 4; %.2f to %.2f.", buff.death_and_decay.remains, buff.death_and_decay.remains + 4 ) end
            -- Extend by 4 to support on-leave effect.
            buff.death_and_decay.expires = buff.death_and_decay.expires + 4
        else
            if Hekili.ActiveDebug then Hekili:Debug( "Death and Decay buff with duration of %.2f not extended; %.2f remains.", duration, buff.death_and_decay.remains ) end
        end
    end

    -- Death and Decay tick time is 1s; if we haven't seen a tick in 2 seconds, it's not ticking.
    local last_dnd = action[ dnd_spell ].lastCast
    local dnd_expires = last_dnd + 10
    if now - last_dnd_tick < 2 and dnd_expires > now then
        applyDebuff( "target", "death_and_decay", dnd_expires - now )
        debuff.death_and_decay.duration = 10
        debuff.death_and_decay.applied = debuff.death_and_decay.expires - 10
    end

    if IsActiveSpell( 433895 ) then
        applyBuff( "vampiric_strike" )
        if buff.gift_of_the_sanlayn.up then buff.vampiric_strike.expires = buff.gift_of_the_sanlayn.expires end
    end

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

    --[[ if state:IsKnown( "deaths_due" ) and cooldown.deaths_due.remains then setCooldown( "death_and_decay", cooldown.deaths_due.remains )
    elseif talent.defile.enabled and cooldown.defile.remains then setCooldown( "death_and_decay", cooldown.defile.remains ) end ]]

    if talent.infliction_of_sorrow.enabled and buff.gift_of_the_sanlayn.up then
        state:QueueAuraExpiration( "gift_of_the_sanlayn", TriggerInflictionOfSorrow, buff.gift_of_the_sanlayn.expires )
    end

    if Hekili.ActiveDebug then Hekili:Debug( "Pet is %s.", pet.alive and "alive" or "dead" ) end

    if IsSpellKnownOrOverridesKnown( 458128 ) then applyBuff( "festering_scythe" ) end
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
        disabled = function() return not talent.apocalypse.enabled end,

        toggle = function () return not talent.army_of_the_damned.enabled and "cooldowns" or nil end,

        debuff = "festering_wound",

        handler = function ()
            if pvptalent.necrotic_wounds.enabled and debuff.festering_wound.up and debuff.necrotic_wound.down then
                applyDebuff( "target", "necrotic_wound" )
            else
                summonPet( "apoc_ghoul" )
                if set_bonus.tww1_4pc > 0 then addStack( "unholy_commander" ) end
            end

            if talent.the_blood_is_life.enabled then summonPet( "blood_beast" ) end
            spec.abilities.raise_dead.handler()
            spec.abilities.dark_transformation.handler()

            PopWounds( 4, 1 )

            gain( 2, "runes" )
            if set_bonus.tier29_2pc > 0 then applyBuff( "vile_infusion" ) end
            if pvptalent.necromancers_bargain.enabled then applyDebuff( "target", "crypt_fever" ) end
        end,
    },

    -- Talent: Summons a legion of ghouls who swarms your enemies, fighting anything they ca...
    army_of_the_dead = {
        id = 42650,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "army_of_the_dead",
        notalent = function() return talent.raise_abomination.enabled and "raise_abomination" or "legion_of_souls" end,
        startsCombat = false,
        texture = 237511,

        toggle = "cooldowns",

        handler = function ()
            if set_bonus.tier30_4pc > 0 then addStack( "master_of_death", nil, 20 ) end
            if set_bonus.tww1_4pc > 0 then addStack( "unholy_commander" ) end

            applyBuff( "army_of_the_dead", 4 )
            summonPet( "army_ghoul", 30 )

            if talent.apocalypse_now.enabled then
                summonPet( "mograine", 20 )
                summonPet( "trollbane", 20 )
                summonPet( "nazgrim", 20 )
                summonPet( "whitemane", 20 )
            end
        end,

        bind = "raise_abomination"
    },

    raise_abomination = {
        id = 455395,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "raise_abomination",
        startsCombat = false,
        texture = 298667,

        toggle = "cooldowns",

        handler = function ()
            if set_bonus.tier30_4pc > 0 then addStack( "master_of_death", nil, 20 ) end
            if set_bonus.tww1_4pc > 0 then addStack( "unholy_commander" ) end

            summonPet( "abomination", 30 )

            if talent.apocalypse_now.enabled then
                summonPet( "mograine", 20 )
                summonPet( "trollbane", 20 )
                summonPet( "nazgrim", 20 )
                summonPet( "whitemane", 20 )
            end
        end,

        bind = "army_of_the_dead"
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
        flash = { 55090, 207311, 433895 },
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "clawing_shadows",
        startsCombat = true,
        max_targets = function()
            if talent.cleaving_strikes.enabled and buff.death_and_decay.up then return 8 end
            return 1
        end,

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

            if talent.plaguebringer.enabled then
                applyBuff( "plaguebringer" )
            end

            if talent.trollbanes_icy_fury.enabled and debuff.chains_of_ice_trollbane_slow.up then
                removeDebuff( "target", "chains_of_ice_trollbane_slow" )
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
        notalent = "apocalypse",
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
        cooldown = function() return 30 - ( 10 * talent.desecrate.rank ) - ( 10 * talent.mawsworn_menace.rank ) end,
        recharge = function () if talent.deaths_echo.enabled then return 30 end end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        notalent = "defile",

        usable = function () return ( settings.dnd_while_moving or not moving ), "cannot cast while moving" end,

        handler = function ()
            applyBuff( "death_and_decay" )
            applyDebuff( "target", "death_and_decay" )
            if talent.grip_of_the_dead.enabled then applyDebuff( "target", "grip_of_the_dead" ) end
            if talent.desecrate.enabled then applyBuff( "desecrate" ) end
        end,

        bind = { "defile", "any_dnd", "deaths_due" },

        copy = "any_dnd"
    },

    desecrate = {
        id = 1234698,
        known = 1234559,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        texture = 236305,

        startsCombat = true,
        talent = "desecrate",

        buff = "desecrate",

        handler = function ()
            removeBuff( "death_and_decay" ) -- removes the real DnD
            removeBuff( "desecrate" )
            applyBuff( "death_and_decay", 7 ) -- gives you the fake DnD extension buff thing

            if debuff.festering_wound.up then PopWounds( 1, active_enemies ) else applyDebuff( "target", "festering_wound", debuff.festering_wound.stack + 1 ) end
        end,

        bind = "death_and_decay"

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

        cycle = function()
            if talent.rotten_touch.enabled and buff.sudden_doom.up then return "rotten_touch" end
        end,
        cycle_to = true,

        handler = function ()
            if talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, debuff.death_rot.stack + ( buff.sudden_doom.up and 2 or 1 ) ) end

            if buff.sudden_doom.up then
                PopWounds( 1 + ( 1 * pvptalent.doomburst.rank ) )
                removeStack( "sudden_doom" )
                if talent.doomed_bidding.enabled then summonPet( "doomed_bidding_magus_coil", 6 ) end
                if talent.rotten_touch.enabled then applyDebuff( "target", "rotten_touch" ) end
            end

            if talent.eternal_agony.enabled then
                if buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 1 end
                if buff.gift_of_the_sanlayn.up then buff.gift_of_the_sanlayn.expires = buff.gift_of_the_sanlayn.expires + 1 end
            end

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
        cooldown = 15,
        recharge = function() if talent.deaths_echo.enabled then return 15 end end,

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
        cooldown = 30,
        recharge = function() if talent.deaths_echo.enabled then return 20 end end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "defile",
        startsCombat = true,

        usable = function () return ( settings.dnd_while_moving or not moving ), "cannot cast while moving" end,

        handler = function ()
            applyDebuff( "target", "defile" )

            applyBuff( "death_and_decay" )
            applyDebuff( "target", "death_and_decay" )
        end,

        bind = { "defile", "any_dnd" }
    },

    -- Talent: Causes each of your Virulent Plagues to flare up, dealing $212739s1 Shadow da...
    epidemic = {
        id = 207317,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = false,

        targets = {
            count = function() return active_dot.virulent_plague end,
        },

        usable = function() return active_dot.virulent_plague > 0, "requires active virulent_plague dots" end,

        handler = function ()
            if talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, debuff.death_rot.stack + ( buff.sudden_doom.up and 2 or 1 ) ) end

            if talent.eternal_agony.enabled then
                if buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 1 end
                if buff.gift_of_the_sanlayn.up then buff.gift_of_the_sanlayn.expires = buff.gift_of_the_sanlayn.expires + 1 end
            end

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
            return 879926
        end,

        cycle = function()
            if debuff.festering_wound.stack_pct > 60 then return "festering_wound" end
            return "disabled_below_stack_pct_60"
        end,
        min_ttd = function() return min( cooldown.death_and_decay.remains + 3, 8 ) end, -- don't try to cycle onto targets that will die too fast to get consumed.

        handler = function ()
            if buff.festering_scythe.up then active_dot.festering_wound = active_enemies end
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

    -- Summon a legion of clawing souls to assist you, dealing $s1 million Shadow damage and applying up to $s2 Festering Wounds over $s3 sec to all nearby enemies. Deals reduced damage beyond $s4 targets. Grants you the benefits of standing in Death and Decay
    -- https://www.wowhead.com/spell=383269
    legion_of_souls = {
        id = 383269,
        cooldown = 90,
        gcd = "spell",

        texture = 3578196,

        talent = "legion_of_souls",
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "legion_of_souls" )
            applyBuff( "death_and_decay", spec.auras.legion_of_souls.duration )
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

        spend = function() return buff.visceral_strength_unholy.up and 0 or 1 end,
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
            if buff.visceral_strength_unholy.up then
                if action.death_coil.time_since < action.epidemic.time_since then
                    spec.abilities.death_coil.handler()
                else
                    spec.abilities.epidemic.handler()
                end
                removeBuff( "visceral_strength_unholy" )
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
            if talent.cleaving_strikes.enabled and buff.death_and_decay.up then return 8 end
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

            if debuff.rotten_touch.up then removeDebuff( "target", "rotten_touch" ) end

            if buff.vampiric_strike.up then
                gain( 0.01 * health.max, "health" )
                addStack( "essence_of_the_blood_queen" )

                if talent.infliction_of_sorrow.enabled and dot.virulent_plague.ticking then
                    dot.virulent_plague.expires = dot.virulent_plague.expires + 3
                end

                -- Vampiric Strike is consumed unless it's from Gift of the San'layn.
                if not buff.gift_of_the_sanlayn.up then
                    removeBuff( "vampiric_strike" )
                else
                    -- Enforce Vampiric Strike expiration when GotS drops.
                    buff.vampiric_strike.expires = buff.gift_of_the_sanlayn.expires
                end
            end

            if talent.plaguebringer.enabled then
                applyBuff( "plaguebringer" )
            end

            if buff.infliction_of_sorrow.up then
                removeDebuff( "target", "virulent_plague" )
                removeBuff( "infliction_of_sorrow" )
                applyBuff( "visceral_strength_unholy" )
            end

            if talent.trollbanes_icy_fury.enabled and debuff.chains_of_ice_trollbane_slow.up then
                removeDebuff( "target", "chains_of_ice_trollbane_slow" )
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
            applyBuff( "unholy_assault" )

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

spec:RegisterSetting( "dnd_while_moving", true, {
    name = strformat( "Allow %s while moving", Hekili:GetSpellLinkWithTexture( spec.abilities.death_and_decay.id ) ),
    desc = strformat( "If checked, then allow recommending %s while the player is moving otherwise only recommend it if the player is standing still.", Hekili:GetSpellLinkWithTexture( spec.abilities.death_and_decay.id ) ),
    type = "toggle",
    width = "full",
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

spec:RegisterPack( "Unholy", 20250817, [[Hekili:S3ZAVnUrs(BXyr0inpKfPg74eyjGCzpCxgeeeSEUpTynffjLe3HIuljL94ad9B)6QB(OBYQFqkP5rY8LepInRU66vxv1vx8ER7F)9357MhC)VzpX(Qj3y99JNC9vtNE993L)0UG7VBNR3hCxt(Jy3TK)7)x8MKONGF(POexF41Zs2N6rE0M88Dz)4LxUomFZ(LJ9s2Ezw429rU5HjXEPURYH)T3LlJswEz(MGhDtFKm0W4l)jpyi)EAysAy(t)AywE2L(bRC3hLt()U5B(qC46n5o7Pt(yak3F3Y9Hr5)s89lXwatSSji2UapYpFf5p3e67hWgBqg5LHX(Mj38gRR)Xdl(hbBtEi4WIGpMhKg7gDyXV)lhw45gfD4DhEx1qFlzO)0V)RhwC3tXEKNF1KGPlj)XRoSWAvWYvlxYp8jaK)L4W8qaGK37(7IGfgqXCtcCYcY3VJ8p(nklii2DzuG)9)x3FNhHgeKg6cRWvRgVkid(NXRDY8EIq1gtER7CPeS7VJ7H5PHFi4(CY6vk8U4Wck10Xn23XpWZ9PX5HEFG86hwm4WIHhwSAFuKtAG3g301bo5HBjuLBpSW(WIxEyXAp)XBD)4Hfp)CjGy8LXREmzFSFGVto8E5zhwmFgHa9KxuGtqCW2WGSYziDFmbMZpSykdoK)DONZUKhdsPt10jhwmI9OC3OG48Xegwar6jpyCXIQeufpVfbIFyAqtcwoHoousnHOse(Zgt)FuSZIn6lK8ceEdd1VWaSJSkhvZjDJFYXp2hyGtBWaLYS5yTMUo9ssI8tEmES7UeIa(t7YcgNgS1nmoJUaR4XmsC1W9Dt)GtEQBC2QK0Tun663JhUmvuh3Smq7TEmavXObvt6AmQAchzHtfTkwEGkeHS9wPY9(buUfrQMmlojRCc9iVCAsu0s3ycxok5rbTkk5ZHy9GqetbqFLeocJQ7Leg1qn7bxYFrg94DKLmWXeeZj0lacpWPCCl37eSl0N8ZE1SVbL6nKH9w8v)1Q061IokM7BN1gBBGpLKJYxgWNVxf(qzhnnfb6omPUArGL7tZYPs8jPbz1IagybcbTn4Ta7w3uyzYn03j4banC99jt(hbZ3SfFJhvRbrEDll1JHy77QkrDvuIk7FRcJcee)rmACZNFr0HflNS9WETo(jjBRmiEozwsSh8dFI1i(mU8XuaTM8zvIaNNyj3zhniGKfztNDob7vElLQY2LVR8njRAz7OlUrttp)EWD7UWucbGTeOBrHa(CYV6N5q8PeZBYYPsCZueaXn7v8bWWLdZWfZX50WDmW9BjXVHy(jY9P4dl(5)oHw8tj)3Q9(edQLkosDlvWTHMJI3XLPckciUROYZQANH(KIWf()gW)VjHf4SmjEF248hFCQtkrwpfCzbChTgnDS351hhHsYh)qy6EyFfNDrUR3hqX86v3T0nNahNrgAAWkYUWBaa3ER6cbSLruDfHDQvpcyYAZUCkjIuhLBozKnxjeb3LjBdJzoJInHkgfVlRThwfFItKkzF(Y0a3puOXff4(GsfUY9Mf1B(z27zEqz4cHClY1HRYlfqYyAKLltTrdQ1IFXCeUDxkjcza)k37OAoW2xbrvZaBBsD)wUaTjRHloMLHmp)vT)c6cKjkZqhouENdD1MveSAJOkPpJl8Z3Y48YZlGjrgC8lbDbrwlZsEoKfHsHz9lq8LG8GjqiLYfKk2PKyblnWxLU7UKszbov37OVgD3oEmyi36nJAQmoUANaCTxedAz73ULy0BnzzN8eV3(c7N0Cu8XuC9eoaZcRajM9IqlGSSaUpkDCscjVPibV90DbKiDs3(KZ6nj7JgZCmc7jcrlbyshNdqOcFoQFYXohCBg0CsW2NOCwkYC1kA2kB8u1wJpgXOIfLxY2TUXC(lqmL5JVLNsw(T8bOAmSBgCaiEzjLIqiixXTxjiCWby1BGCmKkdebaOmuQOMizHZay17ps1IEs9IULBhQ3Q7yw16J4bl8ZH6T0pTPdVAKRM2mTNrbRbN9i8(mcvodBl3tdjGLbquP42jT90lTBZjT3Wkoj2mICqYQvoR981MnpbwP7wsCFlZssx6Sli1JG60TcyP6flZ6d4c4WM3xvYM0URbLHnbrrQ3YfBPBxsMzQyksDwBsZ1fbc1N0TrF7rvIRMK2DPoq1oB)nxPd0K5)kHTwKiQWXG(Qi21Sqy6BnH3hFLhJIYL9aJjOwtAQ)xD4o1UNXcTcILbZfnrxYeYarzSvAscGSugjKeaeNqLL8Gwzwr0lAfEHP37lGMzxiZMKjtdYEYrPczpXS8i0ksyrtZAZyaxqRBjMSc9dZFsqkJspcJxffsNj2UcPP0tNHxunBpXAhzBBYkqmncemyvAczRHvKLAAR8vapFzusIpk6H4JWXKtdZ2tCEPfSMt9NQmCmN3eklSVWmVGu3iWXOG41eBifh7U88pkj3Jn0eo6tYgjeDU5O(ePq3Hw7XxqXrSSPui8vD0O0d5z8emLX5MOu)s6EVMyIX4f38VWwCLCk(C1lZCI0KGljBbcgpvEYzYo9WbACSDoEkmW5zFEpByZs5JXZpoNRPVGMY50EG7y4USdYuv6Q0fMcEcP6EQ0AEKIMGBAZ5LeBbsp)oDuDj6l6K4fQUhj5OTAxuSdrqMgcz)bY7h)HaATpP2HUIJv6fmV6EF5Rvu7zK9JC92eKMSpJz)zByEUinyOQmMJh84OoSDn1h2AwHmesXExEeBse3WZYtikcH(jrDrowGh17euOYZZYyHXXex)Nk5fTxhkCrUG)B1GtrXIiIZ)ebjI1U01pvQwWvggWAH96JZTghMrC56PWGiFqapoGOTMUlnmBBjFSIhx8sowoW0Kv6HvRNVROQdPrez1EoThVXnJ70OOEFv)WAFS40LSN02HU(Yj6xkprid(7tPqw57YkoLrTtUyZu01m8qJCiTFPi2O1cY7oNfWPXUl33e)Ae(jX37giyJ0Hj6ZVPu5JxMR1kYMtjsPWV8eGRGkD)DepcY5mtOWBXIXyFSMsS7HPe7UykXgZ8LctjwF1ykX(prMsWwlFjzkbd)(62uIfMPemH)oykXwMPeBvrOH5vYfDWdcF3TUqvYRWrcL2knXtddoHyr20rRBz(SAYuAAoTgW7Yzta20EOXQHgMam76tU1Sv(PKEpW0ypAV4vHIgvZa2vxNbWWs1qkTwj90SSUcBlBzfAc2w2y6zY2EvLEMTb7IAY2WF657MpRMmLFtpRlO5xT6z2Qshh8EoBCHAouW3yD7PPuxuR2vNaa22GsaGvxWaLtqL)N9Z)xRBAkY2hFHQqIH4RMA38it5pmroDR1aBPrzSlDs1P6c80cSbsDw3y7lYCNEuP6rTOpnFJzUXoRcZ2aPKu55s1)QP4Ttuw(eYl0lvhYPSK8Q8OHUq9zHCH0S5YVaQUhrYlajkuAE5wQfaGFkW3zzOpepTOSKqrTB78wO41lvycYYcI9ckLDyNp7)zFqaHnN7S19JfLra)CTkni(pcHzdgD(MW0S8Mc5Ax0Ql0361nlz2J3e4gLVz8oVCMzHPS6KV9zKXxPpePDYZC3X4HkpwMoIVYRpNH6QZwiJitpS4nkdtv3XfGFKkcNJCxkX7MN6J2t1O(8tuTuuE(Y1xCgzfBsfPhPssuvjkWDHHBjGFIed4QuxevxGoYweCNe4SIl6IIdyqE5OifnuUXLQNl4RIHNPDLnNDD9o30hsf8i(RytNVYmskSfSBnJclDvosAwHRi5o5CHIDcljsfZK86s5cT(b76)utxaKaU6cm9OR9Nl0xJcDKi2)Q)rXjCshL0tJ)GIsPvlXKJeDcQQOR(Cxvrv5(TEdbvfwuPzbXRzfyBMwfhQDJRXoe9S8IK4wOrfCjNFq)5TDvWwh9Pkdzvzg(7lSjs9n1qQ1(64DKHjibtxHaibzpPrfPkmLQ2ctAj(iX)hkc0AJkDLULGcSQgIGMHOx8cVKN7(l9sIy643wlOIDJ4LfnXqTbuuRQTL8BEWkLe81ECIrAsEozgYt27TrCaf(vYwDKHjihwvOfJA4cH9bUYnNVO8q9bP(g7rlE3r9taq3(IO1U3W(x(E9WljnY8)LteM(ixIJiUz51hbx5lAMOh6iBvl9MlDQsg8RH6hv2X4PRE46vvik7Sm0nzyfFNIiI5Ey7T6WXmzz)fFZOUySbF(KhzExCdgNLEgQNYzhFbvIwcJqkflshR(Yy8VWLW43QkrJkLOg1uWjjdmkRdn6gAF)0YjuDTlDkQEH6G)uIxanvyFIVslgSZdh0UVCWtX5IRGdA3bo45OgC4xxGlwSovz1H1OlzsTx5TGYOw05VvUp6Nstt20GVvgc62N(l5Yq4CuUp86oNavAeO0nv6tHf0ppIyMpRMmLFtLUlO5xTQ0FbwzrclpdHJ6lKJs8Td4JjtxL1MJ3ZW5vz7PB6JMiKlQY8LBP(aaaZRxb2NAHemTaMxUskJOIwqFv4(vQdHX(oRsdc(JaE1fKqMt2raDqE9RwIHWFfTpODcAaNjPdZHfrlxC(yXY29jyEzVib5es4Ny(E)jsiykN4kyiC5PRSCOS2sQoTBjj6HTZkV9rzDtCwT4qjdobrqDgyxrvUclOe9eZH9TWyevZWY)r9zPB214v2Q(2ARuSjtwBuFq70axhjtbsiC8jfyGMmDQV2JERYAps6wwkLkGSLwl3X1marCuvpB2OTEz4dwDbYJiTVI9i7ZwGrHRul6XzNw6XAPCaS9eKXBHxNdrPnECVW8krQkj06ZOtrh1SCWiYy2cOk8sW2j(bpq8yVXocnpHJIs6b1zh4b0vg2H1WV1FNA7MfsSSTj4SldPl2jDhwkY1WoRaHBmLI5SfRVbPOUi5XmrdCwvIl2y5xxVK)u6NZet4UVsOOguwqMVKpV18lAkzvaqB2hVMXeqQQZYX4MUmeggvQbyY8dcvcqG116CpWoCa(6)KoRs6xGWo0KFfabxgYDJICy)dh4J(c7t)chBVW)e2uRSNOFQNDHzwEfW00SMDvvqxCsJ1tNBQhCCA5jPeHGCkCv27gPmiM48Q9PpXvq7VIQFdI1c63vgDhOokNHgf8hmsJSVl0qv731nv3sT0uw3VucMa5wE(Xm9o4G8goDbLuAVgt7mxlwupeQiHYkSKbZG0SGuap(ZViH8L6XksOgYNtrczZmNir1qOIeYl5Ekal8BTSybrRLe2E2BBxiLC7OZEkVNKfv0pKBqIzlh)qENhAoT6Er(Mzkmtzo)79(R3wAkuEn)pKD1I(tKSD5nLQFYVLV95rg16gUDSi(vbfqCKdSvjLn152DAbha2qS2rz4zTclq8XxlwTHfBEUBp4(gGiYl3Is7KRctdOgx)tVzs5R0(lLzaGppcGkN4AbIQrqLgK)nmcjSkRssUuZNkXrwjBZzT2Dnn4Ju4YiqtULScOrD7YVqIjtNsLvBZ7NyrrDzITBDf)(jyx2l67N0RWBJFXTA(OwVVbYQfnRE5bMmKl6DDTkBZoBKBpdnDEfI666(82NNo1V2a6QShlr(qKajjpIgS811h6TppTFFQM1NQUWUQoMC3Ah72Q(2s23BqC36h72YQGgLr7Z95obGHCNr1jvkHypT7jGG)kxc4KYpuK9eTS7nArrj5(G1d8P)OdxJqhWk5(c0pSYQFyvb6mvEcZ6hFR3yefBKVv1jIFW6T8WujFNbuneX9alUP9c77vFlTK4FPkCKTqCkZ1mIck3QO(7onSqKBIx(czOcNGRcHUDPSl(Uk)IwsgvJpC00cF8QkZ69q2ciYxxMd)tiTKD1ebAP8niKtlVqk56uIKu0tEQwWudPyxbzwXNxUYfHgh8OxNyULRIBrIUd(GxRXm3kfdUISxRXeZoqiALE)YEpcq6LVNRUz8KLZFaLkKtnpphvyJwZ59aHaKH8t7sdio5T0TDjwWCkL6noh6MR4R3rtN4RboTialorSUx)e5If3h4CiiMwylQ(HHzJLCxkWgkEXMZFkv5If4cG8DQgmerEBviVT5iVIkLhd5TRrEjfBHUdjTMmu3Ih588PV0)vq6raYbrWodBazHRjRTsjkALH(K5msSrICTz4p6wUbd0mULBBbrvR1xYkRPxPzflBy4R7xYobWwJw2Qx24BrdkqeqarszAyQaITAbKUkJRsaX2qbeLxRK2J0ubeBDciQxRiCESvSSHzSaIYvVSXRsaPJvntBliBiUD6uwIpDZgIYYSON1)rTKRgetf)Sp1)HPiMLt2tXE8O0d6UxoYZl1GdOvxBDEW)o8ARtOF3jw90yE(1V5ddsnN4rDylFrUcj6Lk(c(vrTJmgB9mMM3UcZymO9zWZiJr781hgJ5QlTzmnZJqhzmL3GKgPdrPAJwwx96c)2Lulq26(7jKswjWFOo(XLAUaGJO2OHJZECRnme96SAKiWdKOvpIARK8ZzzbKjUmcJEiIwMP8QR0FBeDbznzszQYhrZrBdiGAXaJqyzeHOzSdYxMwAjewDGqyHqiSLsiuUxsRIfZqvdj3XQUOHO86FmazPbjcPbnq1AlVoZMNWMa4DVh1aDRJmb775iwKU9gw1Xix3Y9qcfwh8hy0zOQ)StHKXv3OsuJXnAMHiXaxoYV9rP8zDJyGPjnB(x)FukLEHZXKt0WbL0th1Xy)lktdLDWSWECwxl(2WvzHvVflDhcCVmZYiV6Uctv9dPxEG)lbKCVWHrGLpFB1wv5AiEQxPkmP21nc6WKjUJtN7YQYSulttDOgTsaeAT32ltUmyTmLEVeekgJpJQJ6BCTVSSP42Y8yvtpcV3Bwo(g9ojjDbP7iKfG6(EQnbEgVQDxvRDYQNojFpYzuCv9hsKhx2JLW(D4wtA16X72hfr9SVsDqX7YrLX6gPY1cPRuK(mN0ttRsgyaFS)QAq7LsDO3ASc7l83bRb1hNhRSw8imT97QmjbJxY2McLbdH0CZeUT5pIZgS)nlEvDN(hdPg9OUD4(HsNoApxfeNQZ2vh2YRMYDaL(c94Dn9IFzFFw1ED2SmGIZjvO7iGpjHeuSHPmlliE0X7)MQo0VbN78PPj(puhTFwzPGPZ7HQ9DXAU(xONIBMhJ1LEI(EQxv1FWe0Nx1vjBwvB3uNqUHglbPJfj6(KsOnYWfKLARXk)8kO3tU(DjXh1Y7sDE8R8orB8N7H6OSqSOmsHkP8cL7cHRBl(35CZBdQL5Daztq9RDRgBFzFOD7EU0IR8AStZ8qVjUsPtkUDPAiuYqufxA0ZUaAHjGzkxZ0IRbZZrtnBJDxRuAywv7CNY702iyLY)K7BMyacRtPcfyM2KxtCkQ0BvkS43NhUqVm5B6JjQP1bbwCL3zZpwJuxM0Q8TU1(1D5TC(ZZHQ1xG)kJxOXcOXPB5BMJmxkequweZ9r)2ulRDTrgOsHLOYsIyodE6VzpX(Qj3yDnzCUPGhWKv)73qKWc3UljLOPs2p6WIxuKK9SxqSke8F2hsVXpzjqpxZDFEczhl4hikEKWIZgF4D)Aiy6y6pcxlOyYKrFCjugROKsitqEc3qvv(jKXo06JJ0oDINNwRzO1JneO1bNZ0nqamYqoJa)mb2pn48BLcwZLvupwHvHSPZsTSsRhBiq1sAqhYze4NjW(PbNV6Kkc2aNpTa3aWEegNU(KsFpRa3aWEeAEF)jfxpRaxly7NGMH4C)aUwW2psHH4C)aUwW2psHH4C)aUwWIuUkQOfCJXiSUVGxlGrQ3iv0JUI39f8eaF4DiU7Y36MEXxNU82hXVZkWnaShXoHFX4(OwsJE7GNwGBaypInEL5wJvDB5gdj5E2NdW1pj4ZkWnaShH6HmNUSvqxTLtx)ebU(jWFwbUbG9i0MmyF5oGRNvGRfS9tnWqCUFaxly7hPWqCUFaxly7hPWqCUFaxMBvv3uZxCI8PIVyRLOQX9yJCUr1T9azkuoyZNqd9qPdEgk3HiLeTwp2qG2bIMMbB(eAirRdU1j39JoS(6IqHYju4I6HpnnhI5ah769HphsgP5tLH8PoiCRC6AD1cXNjSHz4KSlnXJ1Hp2LPkqzzJ7epnGMQt3b)3eP)lNiTC)27GWqxSFRCcvlmGoeZbUrcdQgP5tLHcdDyFiLtNEHbPdZWjXmdpYh3jEAuAF7BI0FtKwBymNTn7U5tT03piDfwffwNYC)zg8Nna)5hV7adUlsunMWKDbmukJemDmbOYUaTdgkTsahOAP(DFx1pHCN)Nn55N1Fx)nDcuDj)NnzezQmKIrjVNCkX5MqCQPdvYmwtKAgsV4Vbh72jh(Npi)LaMRx0TxM(BoJ6nny3bfcKf7P10G6jWCvctOVNCkX5MqCQPd1cnwsftpIJtskupQt)qbU2pL1Zn8nbY0Bni9onuCH2LqQBogtXCtHVSu6Qa0q70aZIf7Nndkw4qXQRqrpdYaVep5W3eiRNbHpgtXCtHFNfaonSUJsmQ1wCxi1PpfM8XTP98ZxiXUeXkRCOnuLfHVd59kF2Oxo0A8vVsIAj5PiVl0IGWFsDRbcG7ReqlGY(Mg8RrFN1KjJgnAo3iX8rfH(kBbyPDbyjDbyPyby1ybylSakLK(cxs4YVCLeU0ijH2lGVyKekwaCwFTpjgFKbfdneE4D)c90UH3167zD5dOBHb9dz4WSV)o395BssV)U7c3UpIsj)5u3v0(JCYQqODA93(BhwSjpFx2pE5LRdZ3SFjHZS9YSQxWdEb4F7D5YOKLxMVj4r30hjdnm(YFIoJ)ErN36xH59YIVT1xsV2rSgYE5TBhGYH3btzdecidB3cFjRUJW1iufVRMemDzXG)7U5b)i0(pSV6ntU5nwVfw6Wd(N)VbFimk8FDyX7jUKsOOU0)ZHfRCdtpSiE)2LWvnlzf5VHRUKF9nCQW(ozvq(RYwh2HfpUj0Bdz6DJH)draJqntwh6Dz5fvmmlBpTsbo8og5oBCvrg8Qzxw3DPXFEZMj9Rf7L0ZSXFTsS(1qNpBwd7pVMkkpRw4Hx3O2)Dvr23yus6TQDa1SrrnBjOMQilAmQJh1QTQ86KDZO9zUwuq5OZlTQnd1(0dB9uS8I)s7jVYaYDRH1kz0Kz7119Eoo0h9CoETxsSFinSotwOnejewMnEg2I0ijQgdQDl6TdSvBTSvvsz8mU2hAsRNQJTQquT1WmLTk54RqyRDqDscBv6I0iTXgd6OyR87w3KXAZtMS6O8Dxqc7JbjuXn6csW8OP50BXp9tgFfhc0H0vpOMIDstkNHW14CqD6yOhlTuE(9guZ4pp0YtuEnpvYLLopzSIXXeiL04O6tyuhx80izc7KfjvJaPKgr9XfqnsQCozHs1iskXqQnr8ss399eiL1(jLIgIy78zIlgoF(jyljCaFNvPbb)ra)plUi46UHfiEbAZARgLnKXzwTJNbIlXlzFejMLLKOqY2eUIgadnKWMndUI6GE(1VagDrGlq4u(jqKoPb57tJH)pmmACmq0gKiJIHMugq0CHV1cvFUSgg8rVO9(0rs2(g(87x(uiWtzlxUpnJQwUZTgi0JpMFTcqw3LyebPGps2CmEmlSft0TxnqsNSaEHbvVPyNSSI6ELC0SUFziILdvGnZRKd5wKGjTM7OmAWqjO9(D6q6BTNmqSvYumGbnfbF(5IjrOx9rMbPZD1BG2xqMp7TVbVnZqSolW)LZw2VtfjVvpprK2xrzK8z8D(vd4E3BF7ef6XfnOMMwFgEbs)nSAtC(FCWf4u3NFg5d6nHPnc2NIbMWTeh)Fia6VpLnYLbdBW9SRMu4XGp7(bp4s4duZ(0jj42Pp)msV955Nz7ai0bSiIHvsN1Y2YytL8Bol7TjHUXuu3zlr4ZyR40Ptr3oSCMLpVb7c9j0iVY2gCXmo9vYPUVAOIg84lROlcROrvV0M9qNAfioSxOu9BJB6Yq4ruUdHmpaHUpITrWp7gfDyXpvKppAE14xHn)eOvtHl2Xk71SpCAeAz4QzfiqJEWMEaIcSlKbnaV)hUEHUrc4AX3H(8e6Uiae4v6iwNOIM28VcJbVAF6tWWhsjt1)wLNoVA68zyFu6hGiKtubQ0vByo45N1AO4AqDe9RY9a8Vi33otosZucB1xUgG)15wnKASV6m7bs(gAsw)qNKvCFxvWwGFeqcGpfadh)O63(AIFGH09JFGdPtd)ad288dAZIoZ5FV3F92cDk6l2(dZ)GkImZK9w4nlm4Z9lvlU2TgVIb3e0YFbHTaCjMTHUPDKdyHHk9yDZxWsjw30vPb4nowUU1nigm3TNSxiqXAbDcrbSzw6SW8zc(Xu)ZK1ppCxfMgqv1RvIR(PVI0HXW5UY0uaOJLxkf0cguDxtDMjfAz6T5XZSgmuIcn6KEf41WHf3r)CSdhLgJ0lSn8Ue4VWKNSgCSCrkUI30GhmDY8zsFEbukyFglhmDsxz4vVrRyrg08N5EhjS4Ptyo78)bbzFR7HfBsdwn7fLNI6Jp(44htECtGRp7Ou3fefnZAYKRNCjvd9nHXR2dndXxm)3z9cZFP4hU9s350ZGmQdq(T)G9KRVKXGEtjd6fZ)Fk(lgmHSjSF3RpSWL8hpgaExc)LPZH93F11)WpCzDiPVy(pv93SzaUV1WPcBoqVE6vescix8gr5Ixm)Vt(XdlEVWVwSqwz(eyiwBk4mIqtpb64eA6saDkIcjvyPwtmm(HKpq0)(iz33yYoJG2rzeTePbNsPdj6QigIhGzX(2z221jtOH(Bzmjnpo6Q0z36Z)ql9enQpW(IxOgygRVBDZi5RKlKTuuyvso0u)sy0EDMiFL1K5vJbJ37iY2R2YO9ErtvAQfYgd(ovfbv(pV7P0Wv)RdlQtKlx(j5YyoxA8grtAieF8HfRst2sB43rHXqwfHsU41qcjtGb5Vp23nox0tMgf7a44rvAk2U1fAqSc8mLNIr12D1SpCO0sRb3q(uH851siLITDGsvVnAJqJjUjHUBfAQ(KGQc5MQHK2RHZVnHiiT2ZNfJE3qBQmfkLuqv5OO12xjgwajGb31afAtalUaMSlRCHg7UnJWjYssx6Sli1Jm7ZNiKRUPyPnapjg0V)EmpJmASUj0E)VbjqP1AFQXZGjzuPf4nCX6ff4(qpxdMohAb()F7D91BJJJd)ZsXb4jUZTbjoP9MdBsa2BMDF8wGRdW92M6M42AmPjb2jxN(s)SF6V2wYKusoPPTafZlttIKOKiPi)rsjWoFOxDEhwB8QNfllgDE4ZDbZr2oMLuY(zoWz0JGo4EuTQn11NE9jLd4yddQ52pc6M9fS)mycQhYGQ84V91kVUfkH0Bfy)MTudS6SP9KVpBQX48b9ViUcwA6nWjdV0e7y0zB4ZZZqMogk)3Vggp1BZlVNJ7f2OYSitnbbE7qa9Sd)NhDMJJ)sx(KA2a)CMe5cTCnlNphZ(zp0MjFfVOKPQMVbd(SR(ffhAPXo)2F(7vJrFgFdhaeRRP)kCZGUF)TABDWb(7gpcHsItCw0yBE6QJBTdbre1Ei7qCMfV9hyfIux(qFEInjRhvucC2RmbA8obaTSIh0tmnukEcHgrX(5MISYOqJbByB(nduwRis6npb1Uh5i01vvhVzjofEa6zQiVdhRBFf)8z0PIn5KJjZhf7et4qnRA)IhfH9Qjky5uQT287pF9)IZ(AqWYZ4peDyv9GLutlBVTpw3sZRweBzwz2cMJQzvqgytbr0D7Giq6EU8PVtTTXTncB6v7zI9xY8Pb(bAmcnVzA3IAZZydeI(goSeWJKvgoWgat)Hg2aBEGThuDnySw(QMP2jvtDKv2PzP6KCpCIfRri)yM1HJHcaoy2iuXJz(stQ5fFiBD6conZ8PCFjy6xuLQklTFtWMWez1jirsSk2ktgBJ(c)t4(1g7)sTxhI2l0trr4BmoVaJl5D6MV4dtNFBg)68Dd)DCD)QY(nY)iWnvGVvRubC)gA39v1ePQ9wFpRkKJ0dUZHs)le(mupi7IkpFf3ClwG2ulUtpp51)LkjB30US7AyxWvCKhm7ebyebBxGbAW)gtyJJUBkNBH)CEjsE0Bslf1d9ADQIYZ7uXZMiJlJrCL)QU45YvLs3IuE7EAZ(NV((u(tgNCs881LpMUL9BQE76Uz)U(97NwKT(tQVDBUiLuvBKIHI9HRE65R)dn5)81)xrkO1hE(RavrO9dbxdMQ29R4pRFYjGOE7MKCU65GuJEok4ggyBej0AmBKr27nreXW3d2hf7jteilonrt5daBPoQNpyp4kPwBeyASFGEUB(9itCtrWoQqv3zNcVfLOFpgMa821XiCnI2w9tnEnL9qu8JB5ri(E4ug9lm5XGm8NDk9quNcUa3W)AVG4vrncx1jHrOhOzuh3vvK53lbF2R405uSDDGlKVqQTN8fDei8Bj2hLOa0aI1IctCE(6)9M1)YvstOF(6V(TgdYILCuIboUWWOoJiDcfbYb29O5rdyDwevjCWps78eOa5cLjzO2)lqsWlAUEaoWj)M97UPil9h8UPheWufz3YuqFpV7RmQPC)2mM6BMcZ1rIgDBXg2qFlt5zHzd4FPmYdT7U4gHkxThCJiLwRghzBUHZtNv04x3kg91(63kftQ21A9vvk4XWJthB8ZhfJXCkmiV5s6CjSIw8uasbqbHhQNCXV3O5eHYR2AlRFHMZyum0G3GnZZPWbrd11NctzY8B2SEFz)Dp(4O5f5nY3GAIAEY2f2j1YVWtJozA1W814NBzCB80Pr6nX9SbLNtDxL)Wx5o1WDTyX9zsOx5VJ7Im8s9QH81VbTK0uGXfJdVGMOfPCjby8Pra8c1L66lL4HM33nFph6Jq5yrmSQfSBtbyqvJx3K1O0cJ)Dv42MGrnDrKX)fbTec6IHt95M8NwsAjZhVDreGwEBL8wC5NbNvGXvo9AYh7raUB55MSPXrEFi1dBkUjFz(ohXk3JjBt5vYd0yIGeX2HW8xBtxdsRGpEsp7Ixm9dSUowdbyE5ImEvEuQYuD9f(uL1DMkr(QixCmzLRtBjyvje)ACrpIg5w7XbQOaXqSGDr1Y2nZzrLypa93bjgX0kF9TRYfdOeS9IcbAhhBjMJnN(LVCC6x2vg9R(U5ENFhuAynpPH8TfaoO(XxpIoqjJw1)nm18bV9BhE7W2Dawnbm3GAb(D2sOw4xxbwwWxOsa5p3SmSclhTrQxHtxfAHLiUHvjh86WISNcQIUi7j)lvfzLEHuKxG7Ihyj8e0o)h17Zh17t417diBly94eeZOAv8ux8oO1TJ58RfFx4tqevkHwcpOvVJjbVk7Uklr2VQmCYLgw)wExsHK9OMa1rSbocL96TEzjHwrswsjh)ItYCaQsnaOJhsI61djNcTCL8YG9K8YMvSVDsbGKmUM5BGj1IN7bX2xqrZggucIDud530QBaRwPGb6eWVKViwB4xlane)9N9lVuG4)Rmifa9kGHPrSlDfdr9AbW9Eeqh3kZiqdI3brtNrruM3mE)NmMJk6lcV0vR28OrwcDLSkquLIoZ7p()xK5qsB5(Fz)Q(9(wM6sRZ2Z00TIzzEzo)RLjZuz(dSF)6LYkBDbVCxFmLFH6XZAO(wMgQNX(eiwW1pUs3OGVWTMK4tc0)QrDJPOUJ)EkJ9HFfgY3s3902CErf9KQs8L3XPlL7S8qa1)OV8eAPp4yPZhjrGneD2cEv66pjrH6pK1VwD)1OO2ogN114sZZQRH1CGG)co95o1IWY2zS(0uVKOXwjCSszKzYMdgXerRjk4U0DZFi9NQJnQofc4wLl4zb3Gr2zfPBLlUs20(3NLUA3993UyhZd2lSs)4l8BfjukP1gn2LvP6U6BeYTczWLPvmAciJrQqzjlPGigTwd2Rso7kwl5by(7I9bZXhilFdsCi4c)jcZcsGYvHBQr7pB2WHgF829RwjVSG5H0a83hdq0Uf1eFgue6uB8iv(bynEOZQFDj)k1tTGTOUFRyVJ72aGqCd9zZ(YaftvhRWw)f4X0M8yUWTibkSP)qJbRz)kMMth5KA0spJ8MHeQQ1iLMhsUErzg7HfiEMtLatkV0ksgwysvMOsIKQ8CKv0iQ2oJA5Xlp1hoG2kdo(sI0yFSzAS)foCO9i24OwaRDmh47JDqqd9HpThuY2f8zh(Li6ZqVzIDCyg6rtUvts7PeDfpbL(SUfGv1cLpl(K914dBU5Z4FK28fS9th36y8VxiVXBnDWRSXfR70LBMJ8OjW8vO8hTr9sQKUG9746WxNYyYUlBE2d5I8tJuzx1boOTUcnlfd3IINyN1Tyo7Z2vSxr)(meGn0U3zZ7v53joEAD2p3ZFVf4pEz3jo)zzU()61a6BFvrdMSh69dgtcFfpFx2d6lTyWnht8hnqAbcvYyFvX6jv16nWHtpEdPmDykGz)tx(KBARC1MD6R5zjeTIrAvkZOQDC41kU7jTIcraEkQEqeWE8FIB)kEu9UZ4KPGATgOB1Ho58b9)hJIA)(uOF0i4k50KEJh9dvp3yEz(8IWrYNyuNn1WyHWwTtcy1M4Pwcy1o5Lz1oX)v7KMpypeR2dDVANCCwTTkHJwmMnixEngZb5B2aN25a1O4glmipHjDKBSdHeLiFhcoqX4b3Tw)JvJQoeozWHLGfjd6saH9GIPm9RbrBpKUIbmRTrqbpUvqOgEry8XjW8XaptsDGpoju(4UjNFm3j)Gp(DgFm)NpNxngsJ5r1iJYJtXYjix3nSTox4go0VrKSBDK7vUogE2WbuPTgkpdvU4GXMbMJoe87yo(c9mHPwiX3BSzNurw9V1czvDPy9jZiH6p6pQpTXlwGbkpuE96D5Gl6LgXUqTgQYAX7k49p69syewQMGTGdjGArlb4fETbL6h9Ow7odS69GHvFCupO4jIhWq75JFbdRRlbUgSGJfAnudgCViWnOvE(sa1G)PXKRQvff0GJ(O4lsbhVbUMba6GSxxygqPiqigOaEwGy4rzbZlmiCzB7ja)bsacqD7I2UbaejPxQclpNjWFaPn86YQ(zP1FJjdlhDDsxTAZSHuwphy6g7E8bm)UbbyL5Lu2lf6(lQ3z48rTt)CIPN)suNamMibbc1bqAdQp1sujVrLOSPRtTeL94)2rIAOLevB(ipKOs6GeLlCeDczYhq)9bKjAFC9NTZfSFoz7(aPUpy7cGTJ)tFXqPZNw1w3y3WNJYMleNfrTBOzfU53jxXrKVu)t)NdaNXn((yVog9nd4FX)1o2)(R))p]] )