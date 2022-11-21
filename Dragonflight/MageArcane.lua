-- MageArcane.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local GetItemCooldown = _G.GetItemCooldown

local spec = Hekili:NewSpecialization( 62 )

spec:RegisterResource( Enum.PowerType.ArcaneCharges, {
    arcane_orb = {
        aura = "arcane_orb",

        last = function ()
            local app = state.buff.arcane_orb.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = function () return state.active_enemies end,
    },
} )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Mage
    accumulative_shielding     = { 62093, 382800, 2 }, -- Your barrier's cooldown recharges 20% faster while the shield persists.
    alter_time                 = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 seconds. Effect negated by long distance or death.
    arcane_warding             = { 62114, 383092, 2 }, -- Reduces magic damage taken by 3%.
    blast_wave                 = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 916 Fire damage to all enemies within 8 yards, knocking them back, and reducing movement speed by 70% for 6 sec.
    cryofreeze                 = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement               = { 62092, 389713, 1 }, -- Teleports you back to where you last Blinked. Only usable within 8 sec of Blinking.
    diverted_energy            = { 62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath             = { 62091, 31661 , 1 }, -- Enemies in a cone in front of you take 1,130 Fire damage and are disoriented for 4 sec. Damage will cancel the effect.
    energized_barriers         = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted Clearcasting. Casting your barrier removes all snare effects.
    flow_of_time               = { 62096, 382268, 2 }, -- The cooldown of Blink is reduced by 2.0 sec.
    freezing_cold              = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 80%, decaying over 3 sec.
    frigid_winds               = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    greater_invisibility       = { 62095, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing.
    ice_block                  = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_floes                  = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                   = { 62126, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 2,328 Frost damage to the target and reduced damage to all other enemies within 8 yards, and freezing them in place for 2 sec.
    ice_ward                   = { 62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    improved_frost_nova        = { 62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness   = { 62112, 382293, 2 }, -- Greater Invisibility increases your movement speed by 16% for 6 sec.
    incanters_flow             = { 62113, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to 20% increased damage and then diminishing down to 4% increased damage, cycling every 10 sec.
    invisibility               = { 62118, 66    , 1 }, -- Turns you invisible over 3 sec, reducing threat each second. While invisible, you are untargetable by enemies. Lasts 20 sec. Taking any action cancels the effect.
    mass_polymorph             = { 62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_slow                  = { 62109, 391102, 1 }, -- Slow applies to all enemies within 5 yds of your target.
    master_of_time             = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink when you return to your original location.
    meteor                     = { 62090, 153561, 1 }, -- Calls down a meteor which lands at the target location after 3 sec, dealing 5,044 Fire damage, split evenly between all targets within 8 yards, and burns the ground, dealing 1,280 Fire damage over 8.5 sec to all enemies in the area.
    mirror_image               = { 62124, 55342 , 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy         = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    quick_witted               = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption               = { 62125, 382820, 1 }, -- You are healed for 5% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication              = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse               = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                  = { 62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost              = { 62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    rune_of_power              = { 62113, 116011, 1 }, -- Places a Rune of Power on the ground for 12 sec which increases your spell damage by 40% while you stand within 8 yds. Casting Arcane Power will also create a Rune of Power at your location.
    shifting_power             = { 62085, 382440, 1 }, -- Draw power from the Night Fae, dealing 4,113 Nature damage over 3.5 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.5 sec.
    shimmer                    = { 62105, 212653, 1 }, -- Teleports you 20 yards forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    slow                       = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by 50% for 15 sec.
    spellsteal                 = { 62084, 30449 , 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    tempest_barrier            = { 62111, 382289, 2 }, -- Gain a shield that absorbs 3% of your maximum health for 15 sec after you Blink.
    temporal_velocity          = { 62099, 382826, 2 }, -- Increases your movement speed by 5% for 2 sec after casting Blink and 20% for 5 sec after returning from Alter Time.
    temporal_warp              = { 62094, 386539, 1 }, -- While you have Temporal Displacement or other similar effects, you may use Time Warp to grant yourself 30% Haste for 40 sec.
    time_anomaly               = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain Arcane Surge for 6 sec, Clearcasting, or Time Warp for 6 sec.
    time_manipulation          = { 62129, 387807, 2 }, -- Casting Clearcasting Arcane Missiles reduces the cooldown of your loss of control abilities by 1 sec.
    tome_of_antonidas          = { 62098, 382490, 1 }, -- Increases Haste by 2%.
    tome_of_rhonin             = { 62127, 382493, 1 }, -- Increases Critical Strike chance by 2%.
    volatile_detonation        = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by 5 seconds.
    winters_protection         = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by 20 sec.

    -- Arcane
    amplification              = { 62225, 236628, 1 }, -- When Clearcast, Arcane Missiles fires 3 additional missiles.
    arcane_barrage             = { 62237, 44425 , 1 }, -- Launches bolts of arcane energy at the enemy target, causing 1,617 Arcane damage. For each Arcane Charge, deals 36% additional damage and hits 1 additional nearby target for 40% of its damage. Consumes all Arcane Charges.
    arcane_bombardment         = { 62234, 384581, 1 }, -- Arcane Barrage deals an additional 100% damage against targets below 35% health.
    arcane_echo                = { 62131, 342231, 1 }, -- Direct damage you deal to enemies affected by Touch of the Magi, causes an explosion that deals 206 Arcane damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    arcane_familiar            = { 62145, 205022, 1 }, -- Summon a Familiar that attacks your enemies and increases your maximum mana by 10% for 1 |4hour:hrs;.
    arcane_harmony             = { 62135, 384452, 1 }, -- Each time Arcane Missiles hits an enemy, the damage of your next Arcane Barrage is increased by 5%. This effect stacks up to 20 times.
    arcane_missiles            = { 62238, 5143  , 1 }, -- Launches five waves of Arcane Missiles at the enemy over 2.2 sec, causing a total of 5,158 Arcane damage.
    arcane_orb                 = { 62239, 153626, 1 }, -- Launches an Arcane Orb forward from your position, traveling up to 40 yards, dealing 2,997 Arcane damage to enemies it passes through. Grants 1 Arcane Charge when cast and every time it deals damage.
    arcane_power               = { 62130, 321739, 1 }, -- Arcane Surge lasts an additional 3 sec and grants 25% increased Spell Damage.
    arcane_surge               = { 62230, 365350, 1 }, -- Expend all of your current mana to annihilate your enemy target and nearby enemies for up to 7,716 Arcane damage based on Mana spent. Deals reduced damage beyond 5 targets. For the next 15 sec, your Mana Regeneration is increased by 425% and Spell Damage is increased by 35%.
    arcane_tempo               = { 62144, 383980, 1 }, -- Consuming Arcane Charges increases your Haste by 2% for 12 seconds, stacks up to 5 times.
    arcing_cleave              = { 62140, 231564, 1 }, -- For each Arcane Charge, Arcane Barrage hits 1 additional nearby target for 40% damage.
    cascading_power            = { 62133, 384276, 1 }, -- Consuming a Mana Gem grants up to 2 Clearcasting stacks.
    charged_orb                = { 62241, 384651, 1 }, -- Arcane Orb gains 1 additional charge.
    chrono_shift               = { 62141, 235711, 1 }, -- Arcane Barrage slows enemies by 50% and increases your movement speed by 50% for 5 sec.
    clearcasting               = { 62229, 79684 , 1 }, -- For each 250 mana you spend, you have a 1% chance to gain Clearcasting, making your next Arcane Missiles or Arcane Explosion free and channel 20% faster.
    concentration              = { 62134, 384374, 1 }, -- Arcane Blast has a chance to grant Concentration, which causes your next Clearcasting to not be consumed.
    conjure_mana_gem           = { 62132, 759   , 1 }, -- Conjures a Mana Gem that can be used to instantly restore 25% mana and grant 5% spell damage for 12 sec. Holds up to 3 charges. Conjured Items Conjured items disappear if logged out for more than 15 minutes.
    crackling_energy           = { 62228, 321752, 2 }, -- Increases Arcane Explosion and Arcane Blast damage by 10%.
    enlightened                = { 62143, 321387, 1 }, -- Arcane damage dealt while above 70% mana is increased by 6%, Mana Regen while below 70% is increased by 20%.
    evocation                  = { 62147, 12051 , 1 }, -- Increases your mana regeneration by 750% for 5.3 sec.
    foresight                  = { 62142, 384861, 1 }, -- Standing still for 10 sec grants you Foresight, allowing you to cast while moving for 4 sec. This duration begins when you start moving.
    harmonic_echo              = { 62236, 384683, 1 }, -- Damage dealt to enemies affected by Radiant Spark's vulnerability echo to your current enemy target and 4 nearby enemies for 20% of the damage dealt.
    illuminated_thoughts       = { 62223, 384060, 2 }, -- Clearcasting has a 5% increased chance to proc.
    impetus                    = { 62222, 383676, 1 }, -- Arcane Blast has a 10% chance to generate an additional Arcane Charge. If you were to gain an Arcane Charge while at maximum charges instead gain 10% Arcane damage for 10 sec.
    improved_arcane_missiles   = { 62240, 383661, 2 }, -- Increases Arcane Missiles damage by 10%.
    improved_clearcasting      = { 62224, 321420, 1 }, -- Clearcasting can stack up to 2 additional times.
    improved_prismatic_barrier = { 62232, 321745, 1 }, -- Prismatic Barrier further reduces magical damage taken by an additional 5% and duration of harmful Magic effects by 10%.
    mana_adept                 = { 62231, 321526, 1 }, -- Arcane Barrage grants you 2% of your maximum mana per Arcane Charge spent.
    nether_precision           = { 62226, 383782, 1 }, -- Consuming Clearcasting increases the damage of your next 2 Arcane Blasts by 20%.
    nether_tempest             = { 62138, 114923, 1 }, -- Places a Nether Tempest on the target which deals 459 Arcane damage over 12 sec to the target and nearby enemies within 10 yards. Limit 1 target. Deals reduced damage to secondary targets. Damage increased by 72% per Arcane Charge.
    orb_barrage                = { 62136, 384858, 1 }, -- Consuming Clearcasting reduces the cooldown of Arcane Orb by 2 sec. Additionally, casting Arcane Missiles 15 times fires an Arcane Orb toward your target. Clearcast Arcane Missiles count as 2.
    presence_of_mind           = { 62146, 205025, 1 }, -- Causes your next 2 Arcane Blasts to be instant cast.
    prismatic_barrier          = { 62121, 235450, 1 }, -- Shields you with an arcane force, absorbing 8,622 damage and reducing magic damage taken by 15% for 1 min. The duration of harmful Magic effects against you is reduced by 25%.
    prodigious_savant          = { 62137, 384612, 2 }, -- Arcane Charges further increase Mastery effectiveness of Arcane Blast and Arcane Barrage by 20%.
    radiant_spark              = { 62235, 376103, 1 }, -- Conjure a radiant spark that causes 2,275 Arcane damage instantly, and an additional 1,158 damage over 10 sec. The target takes 10% increased damage from your direct damage spells, stacking each time they are struck. This effect ends after 4 spells.
    resonance                  = { 62139, 205028, 1 }, -- Arcane Barrage deals 15% increased damage per target it hits.
    reverberate                = { 62138, 281482, 1 }, -- If Arcane Explosion hits at least 3 targets, it has a 50% chance to generate an extra Arcane Charge.
    rule_of_threes             = { 62145, 264354, 1 }, -- When you gain your third Arcane Charge, the cost of your next Arcane Blast or Arcane Missiles is reduced by 100%.
    siphon_storm               = { 62148, 384187, 1 }, -- Evocation grants 1 Arcane Charge, and while channeling Evocation, your Intellect is increased by 2% every 0.9 sec. Lasts 30 sec.
    slipstream                 = { 62227, 236457, 1 }, -- Clearcasting allows Arcane Missiles to be channeled while moving. Evocation can be channeled while moving.
    supernova                  = { 62221, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing 748 Arcane damage to all enemies within 8 yards, and knocking them upward. A primary enemy target will take 100% increased damage.
    touch_of_the_magi          = { 62233, 321507, 1 }, -- Applies Touch of the Magi to your current target, accumulating 20% of the damage you deal to the target for 10 sec, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies. Generates 4 Arcane Charges.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    arcane_empowerment = 61  , -- (276741) Clearcasting can now stack 2 additional times, and increases the damage of Arcane Missiles by 5% per stack. Clearcasting no longer reduces the mana cost of Arcane Explosion.
    arcanosphere       = 5397, -- (353128) Builds a sphere of Arcane energy, gaining power over 4 sec. Upon release, the sphere passes through any barriers, knocking enemies back and dealing up to 11,978 Arcane damage.
    ice_wall           = 5488, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    kleptomania        = 3529, -- (198100) Spellsteal steals all spells from the target, now has a 30 sec cooldown and costs 300% more mana.
    mass_invisibility  = 637 , -- (198158) You and your allies within 40 yards instantly become invisible for 5 sec. Dealing damage will cancel the effect.
    master_of_escape   = 635 , -- (210476) Reduces the cooldown of Greater Invisibility by 45 sec.
    netherwind_armor   = 3442, -- (198062) Reduces the chance you will suffer a critical strike by 10%.
    precognition       = 5492, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    prismatic_cloak    = 3531, -- (198064) After you Shimmer, you take 50% less magical damage for 2 sec.
    ring_of_fire       = 5491, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring burn for 24% of their total health over 6 sec.
    temporal_shield    = 3517, -- (198111) Envelops you in a temporal shield for 4 sec. 100% of all damage taken while shielded will be instantly restored when the shield ends.
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: Altering Time. Returning to past location and health when duration expires.
    -- https://wowhead.com/beta/spell=342246
    alter_time = {
        id = 342246,
        duration = 10,
        max_stack = 1
    },
    arcane_blast_overcapped = {
        duration = 3,
        max_stack = 1,
    },
    -- Increases the damage of Arcane Blast, Arcane Missiles, Arcane Explosion, and Arcane Barrage by $36032w1%.    Increases the mana cost of Arcane Blast by $36032w2%$?{$w5<0}[, and reduces the cast time of Arcane Blast by $w5%.][.]    Increases the number of targets hit by Arcane Barrage for 50% damage by $36032w3.
    -- https://wowhead.com/beta/spell=36032
    arcane_charge = {
        duration = 3600,
        max_stack = 4,
        generate = function ()
            local ac = buff.arcane_charge

            if arcane_charges.current > 0 then
                ac.count = arcane_charges.current
                ac.applied = query_time
                ac.expires = query_time + 3600
                ac.caster = "player"
                return
            end

            ac.count = 0
            ac.applied = 0
            ac.expires = 0
            ac.caster = "nobody"
        end,
    },
    -- Talent: Maximum mana increased by $s1%.
    -- https://wowhead.com/beta/spell=210126
    arcane_familiar = {
        id = 210126,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Increases the damage of your next Arcane Barrage by $s1%.
    -- https://wowhead.com/beta/spell=384455
    arcane_harmony = {
        id = 384455,
        duration = 3600,
        max_stack = 1,
        copy = 332777
    },
    -- Intellect increased by $w1%.
    -- https://wowhead.com/beta/spell=1459
    arcane_intellect = {
        id = 1459,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player"
    },
    arcane_orb = {
        duration = 2.5,
        max_stack = 1,
        --[[ generate = function ()
            local last = action.arcane_orb.lastCast
            local ao = buff.arcane_orb

            if query_time - last < 2.5 then
                ao.count = 1
                ao.applied = last
                ao.expires = last + 2.5
                ao.caster = "player"
                return
            end

            ao.count = 0
            ao.applied = 0
            ao.expires = 0
            ao.caster = "nobody"
        end, ]]
    },
    arcane_power = {
        id = 12042,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Spell damage increased by $w1% and Mana Regeneration increase $w3%.
    -- https://wowhead.com/beta/spell=365362
    arcane_surge = {
        id = 365362,
        duration = function() return talent.arcane_power.enabled and 15 or 12 end,
        type = "Magic",
        max_stack = 1
    },
    arcane_tempo = {
        id = 383997,
        duration = 12,
        max_stack = 5
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=157981
    blast_wave = {
        id = 157981,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Absorbs $w1 damage.  Melee attackers take $235314s1 Fire damage.
    -- https://wowhead.com/beta/spell=235313
    blazing_barrier = {
        id = 235313,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Blinking.
    -- https://wowhead.com/beta/spell=1953
    blink = {
        id = 1953,
        duration = 0.3,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=12486
    blizzard = {
        id = 12486,
        duration = 3,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=236298
    chrono_shift = {
        id = 236298,
        duration = 5,
        max_stack = 1,
        copy = "chrono_shift_buff"
    },
    -- Talent: Movement speed slowed by $s1%.
    -- https://wowhead.com/beta/spell=236299
    chrono_shift_snare = {
        id = 236299,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Your next Arcane Missiles or Arcane Explosion costs no mana$?s321758[ and Arcane Missiles fires an additional missile][].
    -- https://wowhead.com/beta/spell=263725
    clearcasting = {
        id = function () return pvptalent.arcane_empowerment.enabled and 276743 or 263725 end,
        duration = 15,
        type = "Magic",
        max_stack = function ()
            return ( talent.improved_clearcasting.enabled and 3 or 1 ) + ( pvptalent.arcane_empowerment.enabled and 2 or 0 )
        end,
        copy = { 263725, 276743 }
    },
    clearcasting_channel = {
        duration = function () return 2.5 * haste end,
        tick_time = function () return ( 2.5 / 6 ) * haste end,
        max_stack = 1,
    },
    -- Talent: Your next Clearcasting will not be consumed.
    -- https://wowhead.com/beta/spell=384379
    concentration = {
        id = 384379,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Mana regeneration increased by $s1%.
    -- https://wowhead.com/beta/spell=12051
    evocation = {
        id = 12051,
        duration = function () return 6 * haste end,
        tick_time = function () return haste end,
        max_stack = 1,
    },
    freezing_cold = {
        id = 386770,
        duration = 5,
        max_stack = 1,
    },
    -- Frozen in place.
    -- https://wowhead.com/beta/spell=122
    frost_nova = {
        id = 122,
        duration = function() return talent.improved_frost_nova.enabled and 8 or 6 end,
        type = "Magic",
        max_stack = 1,
        copy = 235235
    },
    hypothermia = {
        id = 41425,
        duration = 30,
        max_stack = 1,
    },
    -- Talent: Immune to all attacks and damage.  Cannot attack, move, or use spells.
    -- https://wowhead.com/beta/spell=45438
    ice_block = {
        id = 45438,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Able to move while casting spells.
    -- https://wowhead.com/beta/spell=108839
    ice_floes = {
        id = 108839,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    impetus = {
        id = 393939,
        duration = 10,
        max_stack = 1,
    },
    incantation_of_swiftness = {
        id = 382294,
        duration = 6,
        max_stack = 1,
        copy = 337278
    },
    incanters_flow = {
        id = 116267,
        duration = 3600,
        max_stack = 5,
        meta = {
            stack = function() return state.incanters_flow_stacks end,
            stacks = function() return state.incanters_flow_stacks end,
        }
    },
    mirror_image = {
        id = 55342,
        duration = 40,
        max_stack = 3,
        generate = function ()
            local mi = buff.mirror_image

            if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                mi.count = 1
                mi.applied = action.mirror_image.lastCast
                mi.expires = mi.applied + 40
                mi.caster = "player"
                return
            end

            mi.count = 0
            mi.applied = 0
            mi.expires = 0
            mi.caster = "nobody"
        end,
    },
    mirrors_of_torment = {
        id = 314793,
        duration = 20,
        type = "Magic",
        max_stack = 3,
    },
    nether_precision = {
        id = 383783,
        duration = 10,
        max_stack = 2,
        copy = 336889
    },
    -- Talent: Deals $w1 Arcane damage and an additional $w1 Arcane damage to all enemies within $114954A1 yards every $t sec.
    -- https://wowhead.com/beta/spell=114923
    nether_tempest = {
        id = 114923,
        duration = 12,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    orb_barrage = {
        id = 384859,
        duration = 30,
        max_stack = 15
    },
    orb_barrage_ready = {
        id = 384860,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Spell critical strike chance increased by $w1%.
    -- https://wowhead.com/beta/spell=394195
    overflowing_energy = {
        id = 394195,
        duration = 8,
        max_stack = 5
    },
    -- Talent: Arcane Blast is instant cast.
    -- https://wowhead.com/beta/spell=205025
    presence_of_mind = {
        id = 205025,
        duration = 3600,
        max_stack = 2
    },
    -- Talent: Absorbs $w1 damage.  Magic damage taken reduced by $s3%.  Duration of all harmful Magic effects reduced by $w4%.
    -- https://wowhead.com/beta/spell=235450
    prismatic_barrier = {
        id = 235450,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 Arcane damage every $t2 sec.
    -- https://wowhead.com/beta/spell=376103
    radiant_spark = {
        id = 376103,
        duration = 10,
        type = "Magic",
        max_stack = 1,
        copy = 307443
    },
    -- Damage taken from $@auracaster  increased by $w1%.
    -- https://wowhead.com/beta/spell=376104
    radiant_spark_vulnerability = {
        id = 376104,
        duration = 8,
        max_stack = 4,
        copy = 307454
    },
    radiant_spark_consumed = {
        id = 376105,
        duration = 10,
        max_stack = 1,
        copy = 307747
    },
    rule_of_threes = {
        id = 264774,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Every $t1 sec, deal $382445s1 Nature damage to enemies within $382445A1 yds and reduce the remaining cooldown of your abilities by ${-$s2/1000} sec.
    -- https://wowhead.com/beta/spell=382440
    shifting_power = {
        id = 382440,
        duration = function() return 4 * haste end,
        tick_time = function() return haste end,
        type = "Magic",
        max_stack = 1,
        copy = 314791
    },
    -- Talent: Shimmering.
    -- https://wowhead.com/beta/spell=212653
    shimmer = {
        id = 212653,
        duration = 0.65,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=31589
    slow = {
        id = 31589,
        duration = 15,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=382290
    tempest_barrier = {
        id = 382290,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Rooted and Silenced.
    -- https://wowhead.com/beta/spell=317589
    tormenting_backlash = {
        id = 317589,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Will explode for $w1 Arcane damage upon expiration.
    -- https://wowhead.com/beta/spell=210824
    touch_of_the_magi = {
        id = 210824,
        duration = 10,
        max_stack = 1
    },
    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=277703
    trailing_embers = {
        id = 277703,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },

    -- Azerite Powers
    brain_storm = {
        id = 273330,
        duration = 30,
        max_stack = 1,
    },
    equipoise = {
        id = 264352,
        duration = 3600,
        max_stack = 1,
    },

    -- Legendaries
    heart_of_the_fae = {
        id = 356881,
        duration = 15,
        max_stack = 1,
    },
    siphon_storm = {
        id = 332934,
        duration = 30,
        max_stack = 5
    },
    grisly_icicle = {
        id = 348007,
        duration = 8,
        max_stack = 1
    }
} )


 -- Variables from APL (11/13/2021)
-- actions.precombat+=/variable,name=aoe_target_count,op=set,value=3+(1*covenant.kyrian)
spec:RegisterVariable( "aoe_target_count", function ()
    return 3
end )

-- actions.precombat+=/variable,name=evo_pct,op=reset,default=15
spec:RegisterVariable( "evo_pct", function ()
    return 15
end )

-- actions.precombat+=/variable,name=prepull_evo,op=set,if=(runeforge.siphon_storm&(covenant.venthyr|covenant.necrolord|conduit.arcane_prodigy)),value=1,value_else=0
spec:RegisterVariable( "prepull_evo", function ()
    if ( ( talent.siphon_storm.enabled or runeforge.siphon_storm.enabled ) and ( covenant.venthyr or covenant.necrolord or conduit.arcane_prodigy.enabled ) ) then
        return 1
    else
        return 0
    end
end )


local opener_completed = false

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    opener_completed = false
    -- Hekili:Print( "Opener reset (out of combat).")
end )


-- actions.precombat+=/variable,name=have_opened,op=set,if=active_enemies>=variable.aoe_target_count,value=1,value_else=0
-- actions.calculations=variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&prev_gcd.1.evocation&!(runeforge.siphon_storm|runeforge.temporal_warp)
-- actions.calculations+=/variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&buff.arcane_power.down&cooldown.arcane_power.remains&(runeforge.siphon_storm|runeforge.temporal_warp)
-- TODO:  This needs to be updated so that have_opened stays at 1 once it has been set to 1.
spec:RegisterVariable( "have_opened", function ()
    return opener_completed
end )

-- actions.precombat+=/variable,name=final_burn,op=set,value=0
-- actions.calculations+=/variable,name=final_burn,op=set,value=1,if=buff.arcane_charge.stack=buff.arcane_charge.max_stack&!buff.rule_of_threes.up&fight_remains<=((mana%action.arcane_blast.cost)*action.arcane_blast.execute_time)
spec:RegisterVariable( "final_burn", function ()
    if buff.arcane_charge.stack == buff.arcane_charge.max_stack and not buff.rule_of_threes.up and fight_remains <= ( mana.current / action.arcane_blast.cost ) * action.arcane_blast.execute_time then
        return 1
    end

    return 0
end )


-- actions.precombat+=/variable,name=harmony_stack_time,op=reset,default=9
spec:RegisterVariable( "harmony_stack_time", function ()
    return 9
end )

-- + actions.precombat+=/variable,name=always_sync_cooldowns,op=reset,default=1
spec:RegisterVariable( "always_sync_cooldowns", function ()
    return 1
end )

-- actions.precombat+=/variable,name=rs_max_delay_for_totm,op=reset,default=5
spec:RegisterVariable( "rs_max_delay_for_totm", function ()
    return 5
end )

-- actions.precombat+=/variable,name=rs_max_delay_for_rop,op=reset,default=5
spec:RegisterVariable( "rs_max_delay_for_rop", function ()
    return 5
end )

-- actions.precombat+=/variable,name=rs_max_delay_for_ap,op=reset,default=20
spec:RegisterVariable( "rs_max_delay_for_ap", function ()
    return 20
end )

-- actions.precombat+=/variable,name=mot_preceed_totm_by,op=reset,default=8
spec:RegisterVariable( "mot_preceed_totm_by", function ()
    return 8
end )

-- actions.precombat+=/variable,name=mot_max_delay_for_totm,op=reset,default=10
spec:RegisterVariable( "mot_max_delay_for_totm", function ()
    return 10
end )

-- actions.precombat+=/variable,name=mot_max_delay_for_ap,op=reset,default=15
spec:RegisterVariable( "mot_max_delay_for_ap", function ()
    return 15
end )

-- actions.precombat+=/variable,name=ap_max_delay_for_totm,default=-1,op=set,if=variable.ap_max_delay_for_totm=-1,value=10+(20*conduit.arcane_prodigy)
spec:RegisterVariable( "ap_max_delay_for_totm", function ()
    if conduit.arcane_prodigy.enabled then
        return 30
    end

    return 10
end )

-- actions.precombat+=/variable,name=ap_max_delay_for_mot,op=reset,default=20
spec:RegisterVariable( "ap_max_delay_for_mot", function ()
    return 20
end )

-- actions.precombat+=/variable,name=rop_max_delay_for_totm,op=set,value=20-(5*conduit.arcane_prodigy)
spec:RegisterVariable( "rop_max_delay_for_totm", function ()
    if conduit.arcane_prodigy.enabled then
        return 15
    end

    return 20
end )

-- actions.precombat+=/variable,name=totm_max_delay_for_ap,op=set,value=5+20*(covenant.night_fae|(conduit.arcane_prodigy&active_enemies<variable.aoe_target_count))+15*(covenant.kyrian&runeforge.arcane_harmony&active_enemies>=variable.aoe_target_count)
spec:RegisterVariable( "totm_max_delay_for_ap", function ()
    local value = 5

    if ( covenant.night_fae or ( conduit.arcane_prodigy.enabled and active_enemies < variable.aoe_target_count ) ) then
        value = value + 20
    end

    if ( covenant.kyrian and ( talent.arcane_harmony.enabled or runeforge.arcane_harmony.enabled ) and active_enemies >= variable.aoe_target_count ) then
        value = value + 15
    end

    return value
end )

-- actions.precombat+=/variable,name=totm_max_delay_for_rop,op=set,value=20-(8*conduit.arcane_prodigy)
spec:RegisterVariable( "totm_max_delay_for_rop", function ()
    if conduit.arcane_prodigy.enabled then
        return 12
    end

    return 20
end )

-- actions.precombat+=/variable,name=barrage_mana_pct,op=set,if=covenant.night_fae,value=60-(mastery_value*100)
-- actions.precombat+=/variable,name=barrage_mana_pct,op=set,if=covenant.kyrian,value=95-(mastery_value*100)
-- actions.precombat+=/variable,name=barrage_mana_pct,op=set,if=variable.barrage_mana_pct=0,value=80-(mastery_value*100)
spec:RegisterVariable( "barrage_mana_pct", function ()
    if covenant.night_fae then return 60 - mastery_value * 100 end
    if covenant.kyrian then return 95 - mastery_value * 100 end
    return 80 - mastery_value * 100
end )

-- actions.precombat+=/variable,name=ap_minimum_mana_pct,op=reset,default=15
spec:RegisterVariable( "ap_minimum_mana_pct", function ()
    return 15
end )

-- actions.precombat+=/variable,name=totm_max_charges,op=reset,default=2
spec:RegisterVariable( "totm_max_charges", function ()
    return 2
end )

-- actions.precombat+=/variable,name=aoe_totm_max_charges,op=reset,default=2
spec:RegisterVariable( "aoe_totm_max_charges", function ()
    return 2
end )

-- actions.precombat+=/variable,name=fishing_opener,default=-1,op=set,if=variable.fishing_opener=-1,value=1*(equipped.empyreal_ordnance|(talent.rune_of_power&(talent.arcane_echo|!covenant.kyrian)&(!covenant.necrolord|active_enemies=1|runeforge.siphon_storm)&!covenant.venthyr))|(covenant.venthyr&equipped.moonlit_prism)
spec:RegisterVariable( "fishing_opener", function ()
    if ( equipped.empyreal_ordnance or ( talent.rune_of_power.enabled and ( talent.arcane_echo.enabled or not covenant.kyrian ) and ( not covenant.necrolord or active_enemies == 1 or ( talent.siphon_storm.enabled or runeforge.siphon_storm.enabled ) ) and not covenant.venthyr ) ) or ( covenant.venthyr and equipped.moonlit_prism ) then
        return 1
    end

    return 0
end )

-- actions.precombat+=/variable,name=ap_on_use,op=set,value=equipped.macabre_sheet_music|equipped.gladiators_badge|equipped.gladiators_medallion|equipped.darkmoon_deck_putrescence|equipped.inscrutable_quantum_device|equipped.soulletting_ruby|equipped.sunblood_amethyst|equipped.wakeners_frond|equipped.flame_of_battle
spec:RegisterVariable( "ap_on_use", function ()
    return equipped.macabre_sheet_music or equipped.gladiators_badge or equipped.gladiators_medallion or equipped.darkmoon_deck_putrescence or equipped.inscrutable_quantum_device or equipped.soulletting_ruby or equipped.sunblood_amethyst or equipped.wakeners_frond or equipped.flame_of_battle
end )

-- actions.precombat+=/variable,name=aoe_spark_target_count,op=reset,default=8+(2*runeforge.harmonic_echo)
-- actions.precombat+=/variable,name=aoe_spark_target_count,op=max,value=variable.aoe_target_count
spec:RegisterVariable( "aoe_spark_target_count", function ()
    return max( variable.aoe_target_count, 8 + ( ( talent.harmonic_echo.enabled or runeforge.harmonic_echo.enabled ) and 2 or 0 ) )
end )

-- # Either a fully stacked harmony or in execute range with Bombardment
-- actions.calculations+=/variable,name=empowered_barrage,op=set,value=buff.arcane_harmony.stack>=15|(runeforge.arcane_bombardment&target.health.pct<35)
spec:RegisterVariable( "empowered_barrage", function ()
    return buff.arcane_harmony.stack >= 15 or ( ( talent.arcane_bombardment.enabled or runeforge.arcane_bombardment.enabled ) and target.health.pct < 35 )
end )

-- ## actions.calculations+=/variable,name=last_ap_use,default=0,op=set,if=buff.arcane_power.up&(variable.last_ap_use=0|time>=variable.last_ap_use+15),value=time
-- ## Arcane Prodigy gives a variable amount of cdr, but we'll use a flat estimation here. The simc provided remains_expected expression does not work well for prodigy due to the bursty nature of the cdr.
-- ## actions.calculations+=/variable,name=estimated_ap_cooldown,op=set,value=(cooldown.arcane_power.duration*(1-(0.03*conduit.arcane_prodigy.rank)))-(time-variable.last_ap_use)

-- actions.calculations+=/variable,name=time_until_ap,op=set,if=conduit.arcane_prodigy,value=cooldown.arcane_power.remains_expected
-- actions.calculations+=/variable,name=time_until_ap,op=set,if=!conduit.arcane_prodigy,value=cooldown.arcane_power.remains
-- # We'll delay AP up to 20sec for TotM
-- actions.calculations+=/variable,name=time_until_ap,op=max,value=cooldown.touch_of_the_magi.remains,if=(cooldown.touch_of_the_magi.remains-variable.time_until_ap)<20
-- # Since Ruby is such a powerful trinket for Kyrian, we'll stick to the two minute cycle until we get a high enough rank of prodigy
-- actions.calculations+=/variable,name=time_until_ap,op=max,value=trinket.soulletting_ruby.cooldown.remains,if=conduit.arcane_prodigy&conduit.arcane_prodigy.rank<5&equipped.soulletting_ruby&covenant.kyrian&runeforge.arcane_harmony
spec:RegisterVariable( "time_until_ap", function ()
    local value = 0

    if conduit.arcane_prodigy.enabled then
        value = cooldown.arcane_power.remains_expected
    else
        value = cooldown.arcane_power.remains
    end

    if ( cooldown.touch_of_the_magi.remains - value ) < 20 then
        value = max( value, cooldown.touch_of_the_magi.remains )
    end

    if conduit.arcane_prodigy.enabled and conduit.arcane_prodigy.rank < 5 and equipped.soulletting_ruby and covenant.kyrian and ( talent.arcane_harmony.enabled or runeforge.arcane_harmony.enabled ) then
        value = max( value, trinket.soulletting_ruby.cooldown.remains )
    end

    return value
end )

-- # We'll delay TotM up to 20sec for AP
-- actions.calculations+=/variable,name=holding_totm,op=set,value=cooldown.touch_of_the_magi.ready&variable.time_until_ap<20
spec:RegisterVariable( "holding_totm", function ()
    return cooldown.touch_of_the_magi.ready and variable.time_until_ap < 20
end )

-- # Radiant Spark does not immediately put up the vulnerability debuff so it can be difficult to discern that we're at the zeroth vulnerability stack
-- actions.calculations+=/variable,name=just_used_spark,op=set,value=(prev_gcd.1.radiant_spark|prev_gcd.2.radiant_spark|prev_gcd.3.radiant_spark)&action.radiant_spark.time_since<gcd.max*4
spec:RegisterVariable( "just_used_spark", function ()
    return ( prev_gcd[1].radiant_spark or prev_gcd[2].radiant_spark or prev_gcd[3].radiant_spark ) and action.radiant_spark.time_since < gcd.max * 4
end )

-- ## Original SimC checked debuff.radiant_spark_vulnerability.down, but that doesn't work when the addon applies RSV instantly.
-- ## actions.calculations+=/variable,name=just_used_spark,op=set,value=(prev_gcd.1.radiant_spark|prev_gcd.2.radiant_spark|prev_gcd.3.radiant_spark)&debuff.radiant_spark_vulnerability.down
spec:RegisterVariable( "just_used_spark_vulnerability", function ()
    return ( prev_gcd[1].radiant_spark or prev_gcd[2].radiant_spark or prev_gcd[3].radiant_spark ) and debuff.radiant_spark_vulnerability.down
end )

-- actions.calculations+=/variable,name=outside_of_cooldowns,op=set,value=buff.arcane_power.down&buff.rune_of_power.down&debuff.touch_of_the_magi.down&!variable.just_used_spark&debuff.radiant_spark_vulnerability.down
spec:RegisterVariable( "outside_of_cooldowns", function ()
    return buff.arcane_power.down and buff.rune_of_power.down and debuff.touch_of_the_magi.down and not variable.just_used_spark and debuff.radiant_spark_vulnerability.down
end )

-- actions.calculations+=/variable,name=stack_harmony,op=set,value=runeforge.arcane_infinity&((covenant.kyrian&cooldown.touch_of_the_magi.remains<variable.harmony_stack_time))
spec:RegisterVariable( "stack_harmony", function ()
    return ( talent.arcane_harmony.enabled or runeforge.arcane_harmony.enabled ) and ( covenant.kyrian and cooldown.touch_of_the_magi.remains < variable.harmony_stack_time )
end )


do
    -- Builds Disciplinary Command; written so that it can be ported to the other two Mage specs.

    function Hekili:EmbedDisciplinaryCommand( x )
        local file_id = x.id

        x:RegisterAuras( {
            disciplinary_command = {
                id = 327371,
                duration = 20,
            },

            disciplinary_command_arcane = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_frost = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_fire = {
                duration = 10,
                max_stack = 1,
            }
        } )

        local __last_arcane, __last_fire, __last_frost, __last_disciplinary_command = 0, 0, 0, 0
        local __last_arcSpell, __last_firSpell, __last_froSpell

        x:RegisterHook( "reset_precast", function ()
            if not legendary.disciplinary_command.enabled then return end

            if now - __last_arcane < 10 then applyBuff( "disciplinary_command_arcane", 10 - ( now - __last_arcane ) ) end
            if now - __last_fire   < 10 then applyBuff( "disciplinary_command_fire",   10 - ( now - __last_fire ) ) end
            if now - __last_frost  < 10 then applyBuff( "disciplinary_command_frost",  10 - ( now - __last_frost ) ) end

            if now - __last_disciplinary_command < 30 then
                setCooldown( "buff_disciplinary_command", 30 - ( now - __last_disciplinary_command ) )
            end

            Hekili:Debug( "Disciplinary Command:\n - Arcane: %.2f, %s\n - Fire  : %.2f, %s\n - Frost : %.2f, %s\n - ICD   : %.2f", buff.disciplinary_command_arcane.remains, __last_arcSpell or "None", buff.disciplinary_command_fire.remains, __last_firSpell or "None", buff.disciplinary_command_frost.remains, __last_froSpell or "None", cooldown.buff_disciplinary_command.remains )
        end )

        x:RegisterStateFunction( "update_disciplinary_command", function( action )
            local ability = class.abilities[ action ]

            if not ability then return end
            if ability.item or ability.from == 0 then return end

            if     ability.school == "arcane" then applyBuff( "disciplinary_command_arcane" )
            elseif ability.school == "fire"   then applyBuff( "disciplinary_command_fire"   )
            elseif ability.school == "frost"  then applyBuff( "disciplinary_command_frost"  )
            else
                local sAction = x.abilities[ action ]
                local sDiscipline = sAction and sAction.school

                if sDiscipline then
                    if     sDiscipline == "arcane" then applyBuff( "disciplinary_command_arcane" )
                    elseif sDiscipline == "fire"   then applyBuff( "disciplinary_command_fire"   )
                    elseif sDiscipline == "frost"  then applyBuff( "disciplinary_command_frost"  ) end
                else applyBuff( "disciplinary_command_" .. state.spec.key ) end
            end

            if buff.disciplinary_command_arcane.up and buff.disciplinary_command_fire.up and buff.disciplinary_command_frost.up then
                applyBuff( "disciplinary_command" )
                setCooldown( "buff_disciplinary_command", 30 )
                removeBuff( "disciplinary_command_arcane" )
                removeBuff( "disciplinary_command_fire" )
                removeBuff( "disciplinary_command_frost" )
            end
        end )

        x:RegisterHook( "runHandler", function( action )
            if not legendary.disciplinary_command.enabled or cooldown.buff_disciplinary_command.remains > 0 then return end
            update_disciplinary_command( action )
        end )

        local triggerEvents = {
            SPELL_CAST_SUCCESS = true,
            SPELL_HEAL = true,
            SPELL_SUMMON= true
        }

        local spellChanges = {
            [108853] = 319836,
            [212653] = 1953,
            [342130] = 116011,
            [337137] = 1,
        }

        local spellSchools = {
            [4] = "fire",
            [16] = "frost",
            [64] = "arcane"
        }

        x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName, spellSchool )
            if sourceGUID == GUID then
                if triggerEvents[ subtype ] then
                    spellID = spellChanges[ spellID ] or spellID
                    if not IsSpellKnown( spellID, false ) then return end

                    local school = spellSchools[ spellSchool ]
                    if not school then return end

                    if     school == "arcane" then __last_arcane = GetTime(); __last_arcSpell = spellName
                    elseif school == "fire"   then __last_fire   = GetTime(); __last_firSpell = spellName
                    elseif school == "frost"  then __last_frost  = GetTime(); __last_froSpell = spellName end
                    return
                elseif subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.disciplinary_command.id then
                    __last_disciplinary_command = GetTime()
                    __last_arcane = 0
                    __last_fire = 0
                    __last_frost = 0
                end
            end
        end, false )

        x:RegisterAbility( "buff_disciplinary_command", {
            cooldown_special = function ()
                local remains = ( now + offset ) - __last_disciplinary_command

                if remains < 30 then
                    return __last_disciplinary_command, 30
                end

                return 0, 0
            end,
            unlisted = true,

            cast = 0,
            cooldown = 30,
            gcd = "off",

            handler = function()
                applyBuff( "disciplinary_command" )
            end,
        } )
    end

    Hekili:EmbedDisciplinaryCommand( spec )
end


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "arcane_charges" then
        if arcane_charges.current == 0 then
            removeBuff( "arcane_charge" )
        else
            applyBuff( "arcane_charge", nil, arcane_charges.current )
        end
        if amt > 0 and talent.arcane_tempo.enabled then
            addStack( "arcane_tempo", nil, 1 )
        end

    elseif resource == "mana" then
        if azerite.equipoise.enabled and mana.percent < 70 then
            removeBuff( "equipoise" )
        end
    end
end )

spec:RegisterHook( "gain", function( amt, resource )
    if resource == "arcane_charges" then
        if arcane_charges.current == 0 then
            removeBuff( "arcane_charge" )
        else
            if talent.rule_of_threes.enabled and arcane_charges.current >= 3 and arcane_charges.current - amt < 3 then
                applyBuff( "rule_of_threes" )
            end
            applyBuff( "arcane_charge", nil, arcane_charges.current )
        end
    end
end )


spec:RegisterStateTable( "burn_info", setmetatable( {
    __start = 0,
    start = 0,
    __average = 20,
    average = 20,
    n = 1,
    __n = 1,
}, {
    __index = function( t, k )
        if k == "active" then
            return t.start > 0
        end
    end,
} ) )


spec:RegisterTotem( "rune_of_power", 609815 )


spec:RegisterStateTable( "incanters_flow", {
    changed = 0,
    count = 0,
    direction = 0,

    startCount = 0,
    startTime = 0,
    startIndex = 0,

    values = {
        [0] = { 0, 1 },
        { 1, 1 },
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 5, 0 },
        { 5, -1 },
        { 4, -1 },
        { 3, -1 },
        { 2, -1 },
        { 1, 0 }
    },

    f = CreateFrame( "Frame" ),
    fRegistered = false,

    reset = setfenv( function ()
        if talent.incanters_flow.enabled then
            if not incanters_flow.fRegistered then
                Hekili:ProfileFrame( "Incanters_Flow_Arcane", incanters_flow.f )
                -- One-time setup.
                incanters_flow.f:RegisterUnitEvent( "UNIT_AURA", "player" )
                incanters_flow.f:SetScript( "OnEvent", function ()
                    -- Check to see if IF changed.
                    if state.talent.incanters_flow.enabled then
                        local flow = state.incanters_flow
                        local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )
                        local now = GetTime()

                        if name then
                            if count ~= flow.count then
                                if count == 1 then flow.direction = 0
                                elseif count == 5 then flow.direction = 0
                                else flow.direction = ( count > flow.count ) and 1 or -1 end

                                flow.changed = GetTime()
                                flow.count = count
                            end
                        else
                            flow.count = 0
                            flow.changed = GetTime()
                            flow.direction = 0
                        end
                    end
                end )

                incanters_flow.fRegistered = true
            end

            if now - incanters_flow.changed >= 1 then
                if incanters_flow.count == 1 and incanters_flow.direction == 0 then
                    incanters_flow.direction = 1
                    incanters_flow.changed = incanters_flow.changed + 1
                elseif incanters_flow.count == 5 and incanters_flow.direction == 0 then
                    incanters_flow.direction = -1
                    incanters_flow.changed = incanters_flow.changed + 1
                end
            end

            if incanters_flow.count == 0 then
                incanters_flow.startCount = 0
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0
            else
                incanters_flow.startCount = incanters_flow.count
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0

                for i, val in ipairs( incanters_flow.values ) do
                    if val[1] == incanters_flow.count and val[2] == incanters_flow.direction then incanters_flow.startIndex = i; break end
                end
            end
        else
            incanters_flow.count = 0
            incanters_flow.changed = 0
            incanters_flow.direction = 0
        end
    end, state ),
} )

spec:RegisterStateExpr( "incanters_flow_stacks", function ()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 1 ]
end )

spec:RegisterStateExpr( "incanters_flow_dir", function()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 2 ]
end )

-- Seemingly, a very silly way to track Incanter's Flow...
local incanters_flow_time_obj = setmetatable( { __stack = 0 }, {
    __index = function( t, k )
        if not state.talent.incanters_flow.enabled then return 0 end

        local stack = t.__stack
        local ticks = #state.incanters_flow.values

        local start = state.incanters_flow.startIndex + floor( state.offset + state.delay )

        local low_pos, high_pos

        if k == "up" then low_pos = 5
        elseif k == "down" then high_pos = 6 end

        local time_since = ( state.query_time - state.incanters_flow.changed ) % 1

        for i = 0, 10 do
            local index = ( start + i )
            if index > 10 then index = index % 10 end

            local values = state.incanters_flow.values[ index ]

            if values[ 1 ] == stack and ( not low_pos or index <= low_pos ) and ( not high_pos or index >= high_pos ) then
                return max( 0, i - time_since )
            end
        end

        return 0
    end
} )

spec:RegisterStateTable( "incanters_flow_time_to", setmetatable( {}, {
    __index = function( t, k )
        incanters_flow_time_obj.__stack = tonumber( k ) or 0
        return incanters_flow_time_obj
    end
} ) )


spec:RegisterStateExpr( "fake_mana_gem", function ()
    return false
end )


spec:RegisterStateFunction( "start_burn_phase", function ()
    burn_info.start = query_time
end )


spec:RegisterStateFunction( "stop_burn_phase", function ()
    if burn_info.start > 0 then
        burn_info.average = burn_info.average * burn_info.n
        burn_info.average = burn_info.average + ( query_time - burn_info.start )
        burn_info.n = burn_info.n + 1

        burn_info.average = burn_info.average / burn_info.n
        burn_info.start = 0
    end
end )


spec:RegisterStateExpr( "burn_phase", function ()
    return burn_info.start > 0
end )

spec:RegisterStateExpr( "average_burn_length", function ()
    return burn_info.average or 15
end )


local clearcasting_consumed = 0
local used_arcane_blast_at_4 = 0
local arcane_harmony_done = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 12042 then
                burn_info.__start = GetTime()

                -- Hekili:Print( "Burn phase started." )
            elseif spellID == 12051 and burn_info.__start > 0 then
                burn_info.__average = burn_info.__average * burn_info.__n
                burn_info.__average = burn_info.__average + ( query_time - burn_info.__start )
                burn_info.__n = burn_info.__n + 1

                burn_info.__average = burn_info.__average / burn_info.__n
                burn_info.__start = 0
                -- Hekili:Print( "Burn phase ended." )

                -- Setup for opener_done variable.
                if not ( state.talent.siphon_storm.enabled or state.runeforge.siphon_storm.enabled or state.talent.temporal_warp.enabled or state.runeforge.temporal_warp.enabled ) then
                    opener_completed = true
                    -- Hekili:Print( "Opener completed (evocation)." )
                end

            elseif spellID == 30451 and UnitPower( "player", Enum.PowerType.ArcaneCharges ) > 3 then
                used_arcane_blast_at_4 = GetTime()

            elseif spellID == 44425 and ( state.talent.arcane_harmony.enabled or state.runeforge.arcane_harmony.enabled ) and GetTime() - used_arcane_blast_at_4 < 3 then
                arcane_harmony_done = GetTime()

            end

        elseif subtype == "SPELL_AURA_REMOVED" and ( spellID == 276743 or spellID == 263725 ) then
            -- Clearcasting was consumed.
            clearcasting_consumed = GetTime()
        end
    end
end, false )


spec:RegisterStateExpr( "tick_reduction", function ()
    return action.shifting_power.cdr / 4
end )

spec:RegisterStateExpr( "full_reduction", function ()
    return action.shifting_power.cdr
end )


local abs = math.abs


spec:RegisterStateExpr( "echo_opened", function()
    return talent.arcane_echo.enabled and state.combat > 0 and used_arcane_blast_at_4 > state.combat
end )

spec:RegisterHook( "reset_precast", function ()
    if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
    else removeBuff( "rune_of_power" ) end

    if burn_info.__start > 0 and ( ( state.time == 0 and now - player.casttime > ( gcd.execute * 4 ) ) or ( now - burn_info.__start >= 45 ) ) and ( ( cooldown.evocation.remains == 0 and cooldown.arcane_power.remains < action.evocation.cooldown - 45 ) or ( cooldown.evocation.remains > cooldown.arcane_power.remains + 45 ) ) then
        -- Hekili:Print( "Burn phase ended to avoid Evocation and Arcane Power desynchronization (%.2f seconds).", now - burn_info.__start )
        burn_info.__start = 0
    end

    if buff.casting.up and buff.casting.v1 == 5143 and abs( action.arcane_missiles.lastCast - clearcasting_consumed ) < 0.15 then
        applyBuff( "clearcasting_channel", buff.casting.remains )
    end

    burn_info.start = burn_info.__start
    burn_info.average = burn_info.__average
    burn_info.n = burn_info.__n

    if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

    fake_mana_gem = GetItemCount( 36799 ) > 0

    incanters_flow.reset()

    if used_arcane_blast_at_4 > 0 then
        if now - used_arcane_blast_at_4 < 3 then
            applyBuff( "arcane_blast_overcapped", used_arcane_blast_at_4 + 3 - now )
        end
    end

    -- This will set the opener to be completed, which persists while in combat.  For opener_done.
    if not opener_completed and InCombatLockdown() then
        if true_active_enemies > variable.aoe_target_count then
            opener_completed = true
            -- Hekili:Print( "Opener completed (aoe)." )
        elseif buff.arcane_power.down and cooldown.arcane_power.true_remains > 0 and ( talent.siphon_storm.enabled or runeforge.siphon_storm.enabled or talent.temporal_warp.enabled or runeforge.temporal_warp.enabled ) then
            opener_completed = true
            -- Hekili:Print( "Opener completed (Arcane Power)." )
        end
    end
end )


spec:RegisterStateFunction( "handle_radiant_spark", function()
    if debuff.radiant_spark_vulnerability.down then applyDebuff( "target", "radiant_spark_vulnerability" )
    else
        debuff.radiant_spark_vulnerability.count = debuff.radiant_spark_vulnerability.count + 1

        -- Implemented with max of 5 stacks (application of 5th stack makes the debuff expire in 0.1 seconds, to give us time to Arcane Barrage).
        if debuff.radiant_spark_vulnerability.stack == debuff.radiant_spark_vulnerability.max_stack then
            debuff.radiant_spark_vulnerability.expires = query_time + 0.1
            applyBuff( "radiant_spark_consumed", debuff.radiant_spark.remains )
        end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 seconds. Effect negated by long distance or death.
    alter_time = {
        id = function () return buff.alter_time.down and 342247 or 342245 end,
        cast = 0,
        cooldown = function () return talent.master_of_time.enabled and 50 or 60 end,
        gcd = "spell",
        school = "arcane",

        spend = 0.01,
        spendType = "mana",

        toggle = "defensives",
        startsCombat = false,

        handler = function ()
            if buff.alter_time.down then
                applyBuff( "alter_time" )
            else
                removeBuff( "alter_time" )
                if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
            end
        end,

        copy = { 342247, 342245 },
    },

    -- Talent: Launches bolts of arcane energy at the enemy target, causing 1,617 Arcane damage. For each Arcane Charge, deals 36% additional damage and hits 1 additional nearby target for 40% of its damage. Consumes all Arcane Charges.
    arcane_barrage = {
        id = 44425,
        cast = 0,
        cooldown = 3,
        gcd = "spell",
        school = "arcane",

        talent = "arcane_barrage",
        startsCombat = true,

        handler = function ()
            if talent.mana_adept.enabled then gain( 0.02 * mana.modmax * arcane_charges.current, "mana" ) end

            spend( arcane_charges.current, "arcane_charges" )
            removeBuff( "arcane_harmony" )

            if talent.chrono_shift.enabled then
                applyBuff( "chrono_shift_buff" )
                applyDebuff( "target", "chrono_shift_snare" )
            end

            if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
        end,
    },

    -- Blasts the target with energy, dealing 1,340 Arcane damage. Each Arcane Charge increases damage by 72% and mana cost by 100%, and reduces cast time by 8%. Generates 1 Arcane Charge.
    arcane_blast = {
        id = 30451,
        cast = function ()
            if buff.presence_of_mind.up then return 0 end
            return 2.25 * ( 1 - ( 0.08 * arcane_charges.current ) ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if buff.rule_of_threes.up then return 0 end
            local mult = 0.0275 * ( 1 + arcane_charges.current ) * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
            -- if azerite.equipoise.enabled and mana.pct < 70 then return ( mana.modmax * mult ) - 190 end
            return mana.modmax * mult, "mana"
        end,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            if buff.presence_of_mind.up then
                removeStack( "presence_of_mind" )
                if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
            end
            removeBuff( "rule_of_threes" )
            removeStack( "nether_precision" )

            if arcane_charges.current == arcane_charges.max then
                applyBuff( "arcane_blast_overcapped" )
                if talent.arcane_echo.enabled then echo_opened = true end
            end -- Use this to catch "5th" cast of Arcane Blast.
            gain( 1, "arcane_charges" )

            if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
        end,
    },

    -- Causes an explosion of magic around the caster, dealing 1,684 Arcane damage to all enemies within 10 yards. Generates 1 Arcane Charge if any targets are hit.
    arcane_explosion = {
        id = 1449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if not pvptalent.arcane_empowerment.enabled and buff.clearcasting.up then return 0 end
            return 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
        end,
        spendType = "mana",

        startsCombat = true,

        usable = function () return not state.spec.arcane or target.distance < 10, "target out of range" end,
        handler = function ()
            if buff.expanded_potential.up then removeBuff( "expanded_potential" )
            else
                if buff.concentration.up then removeBuff( "concentration" )
                else
                    removeStack( "clearcasting" )
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
                    if talent.orb_barrage.enabled then reduceCooldown( "arcane_orb", 2 ) end
                end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            end
            gain( 1, "arcane_charges" )
        end,
    },

    -- Talent: Summon a Familiar that attacks your enemies and increases your maximum mana by 10% for 1 |4hour:hrs;.
    arcane_familiar = {
        id = 205022,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "arcane",

        talent = "arcane_familiar",
        startsCombat = false,
        nobuff = "arcane_familiar",
        essential = true,

        handler = function ()
            if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
            applyBuff( "arcane_familiar" )
        end,

        copy = "summon_arcane_familiar"
    },

    -- Infuses the target with brilliance, increasing their Intellect by 5% for 1 |4hour:hrs;. If the target is in your party or raid, all party and raid members will be affected.
    arcane_intellect = {
        id = 1459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.04 * ( buff.arcane_surge.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        nobuff = "arcane_intellect",
        essential = true,

        handler = function ()
            applyBuff( "arcane_intellect" )
        end,
    },

    -- Talent: Launches five waves of Arcane Missiles at the enemy over 2.2 sec, causing a total of 5,158 Arcane damage.
    arcane_missiles = {
        id = 5143,
        cast = function () return ( buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if buff.rule_of_threes.up or buff.clearcasting.up then return 0 end
            return 0.15 * ( buff.arcane_surge.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
        end,
        spendType = "mana",

        talent = "arcane_missiles",
        startsCombat = true,
        aura = function () return buff.clearcasting_channel.up and "clearcasting_channel" or "casting" end,
        breakchannel = function ()
            removeBuff( "clearcasting_channel" )
        end,

        tick_time = function ()
            if buff.clearcasting_channel.up then return buff.clearcasting_channel.tick_time end
            return 0.5 * haste
        end,

        start = function ()
            removeBuff( "orb_barrage_ready" )
            removeBuff( "arcane_blast_overcapped" )

            if buff.clearcasting.up then
                if buff.concentration.up then removeBuff( "concentration" )
                else
                    removeStack( "clearcasting" )
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
                    if talent.orb_barrage.enabled then
                        reduceCooldown( "arcane_orb", 2 )
                        addStack( "orb_barrage", nil, 2 )
                    end
                end
                if talent.amplification.enabled then applyBuff( "clearcasting_channel" ) end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            else
                if buff.rule_of_threes.up then removeBuff( "rule_of_threes" ) end
                if talent.orb_barrage.enabled then addStack( "orb_barrage", nil, 1 ) end
            end

            if buff.orb_barrage.stack >= 15 then
                applyBuff( "orb_barrage_ready" )
                removeBuff( "orb_barrage" )
            end

            if buff.expanded_potential.up then removeBuff( "expanded_potential" ) end

            if conduit.arcane_prodigy.enabled and cooldown.arcane_surge.remains > 0 then
                reduceCooldown( "arcane_surge", conduit.arcane_prodigy.mod * 0.1 )
            end
        end,

        tick = function ()
            if talent.arcane_harmony.enabled or legendary.arcane_harmony.enabled then addStack( "arcane_harmony", nil, 1 ) end
            if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
        end,
    },

    -- Talent: Launches an Arcane Orb forward from your position, traveling up to 40 yards, dealing 2,997 Arcane damage to enemies it passes through. Grants 1 Arcane Charge when cast and every time it deals damage.
    arcane_orb = {
        id = 153626,
        cast = 0,
        charges = function() return talent.charged_orb.enabled and 2 or nil end,
        cooldown = 20,
        recharge = function() return talent.charged_orb.enabled and 20 or nil end,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.01 * ( buff.arcane_surge.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "arcane_orb",
        startsCombat = true,

        handler = function ()
            gain( 1, "arcane_charges" )
            applyBuff( "arcane_orb" )
        end,
    },

    -- Talent: Expend all of your current mana to annihilate your enemy target and nearby enemies for up to 7,716 Arcane damage based on Mana spent. Deals reduced damage beyond 5 targets. For the next 15 sec, your Mana Regeneration is increased by 425% and Spell Damage is increased by 35%.
    arcane_surge = {
        id = 365350,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",
        school = "arcane",

        spend = function() return mana.current end,
        spendType = "mana",

        talent = "arcane_surge",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "arcane_surge" )
            mana.regen = mana.regen * 5.25
            forecastResources( "mana" )
            if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
            start_burn_phase()
        end,

        copy = "arcane_power"
    },


    arcanosphere = {
        id = 353128,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "arcanosphere",
        startsCombat = false,
        texture = 4226155,

        handler = function ()
        end,
    },


    blink = {
        id = function () return talent.shimmer.enabled and 212653 or 1953 end,
        cast = 0,
        charges = function () return talent.shimmer.enabled and 2 or nil end,
        cooldown = function () return ( talent.shimmer.enabled and 20 or 15 ) - conduit.flow_of_time.mod * 0.001 - talent.flow_of_time.rank end,
        recharge = function () return ( talent.shimmer.enabled and ( 20 - conduit.flow_of_time.mod * 0.001 - talent.flow_of_time.rank ) or nil ) end,
        gcd = "off",
        icd = 6,

        spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

        handler = function ()
            if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            if talent.tempest_barrier.enabled then applyBuff( "tempest_barrier" ) end
        end,

        copy = { 212653, 1953, "shimmer", "blink_any" }
    },

    -- Talent: Conjures a Mana Gem that can be used to instantly restore 25% mana and grant 5% spell damage for 12 sec. Holds up to 3 charges. Conjured Items Conjured items disappear if logged out for more than 15 minutes.
    conjure_mana_gem = {
        id = 759,
        cast = 3,
        cooldown = 0,
        icd = 10, -- Probably don't want to recast within 10 seconds.
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "conjure_mana_gem",
        startsCombat = false,

        usable = function ()
            if fake_mana_gem then return false, "already has a mana_gem" end
            return true
        end,

        handler = function ()
            fake_mana_gem = true
        end,
    },

    mana_gem = {
        name = "|cff00ccff[Mana Gem]|r",
        known = function ()
            return state.fake_mana_gem
        end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 134132,

        item = 36799,
        bagItem = true,

        usable = function ()
            return fake_mana_gem, "requires mana_gem in bags"
        end,

        readyTime = function ()
            local start, duration = GetItemCooldown( 36799 )
            return max( 0, start + duration - query_time )
        end,

        handler = function ()
            gain( 0.25 * mana.max, "mana" )
            if talent.cascading_power.enabled then gain( 2, "arcane_charges" ) end
        end,

        copy = "use_mana_gem"
    },

    -- Targets in a cone in front of you take 383 Frost damage and have movement slowed by 70% for 5 sec.
    cone_of_cold = {
        id = 120,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "frost",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,

        usable = function () return target.distance <= 12, "target must be nearby" end,
        handler = function ()
            applyDebuff( "target", talent.freezing_cold.enabled and "freezing_cold" or "cone_of_cold" )
            active_dot.cone_of_cold = max( active_enemies, active_dot.cone_of_cold )

            removeBuff( "snowstorm" )
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
        end,
    },

    -- Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for 6 sec.
    counterspell = {
        id = 2139,
        cast = 0,
        cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end,
        gcd = "off",
        school = "arcane",

        spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        toggle = "interrupts",
        debuff = function () return not runeforge.disciplinary_command.enabled and "casting" or nil end,
        readyTime = function () if debuff.casting.up then return state.timeToInterrupt() end end,

        handler = function ()
            interrupt()
            if talent.quick_witted.enabled then reduceCooldown( "counterspell", 4 ) end
        end,
    },

    -- Talent: Increases your mana regeneration by 750% for 5.3 sec.
    evocation = {
        id = 12051,
        cast = function () return 6 * haste end,
        charges = 1,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",
        school = "arcane",

        channeled = true,
        fixedCast = true,

        talent = "evocation",
        startsCombat = false,
        aura = "evocation",
        tick_time = function () return haste end,

        start = function ()
            stop_burn_phase()

            applyBuff( "evocation" )

            if talent.siphon_storm.enabled then
                gain( 1, "arcane_charges" )
                applyBuff( "siphon_storm" )
            end

            if azerite.brain_storm.enabled then
                gain( 2, "arcane_charges" )
                applyBuff( "brain_storm" )
            end

            if legendary.siphon_storm.enabled then
                applyBuff( "siphon_storm" )
            end

            mana.regen = mana.regen * ( 8.5 / haste )
        end,

        tick = function ()
            if talent.siphon_storm.enabled or legendary.siphon_storm.enabled then
                addStack( "siphon_storm", nil, 1 )
            end
        end,

        finish = function ()
            mana.regen = mana.regen / ( 8.5 * haste )
        end,

        breakchannel = function ()
            removeBuff( "evocation" )
            mana.regen = mana.regen / ( 8.5 * haste )
        end,
    },


    focus_magic = {
        id = 321358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135754,

        talent = "focus_magic",

        usable = function () return active_dot.focus_magic == 0 and group, "can apply one in a group" end,
        handler = function ()
            applyBuff( "focus_magic" )
        end,
    },

    -- Blasts enemies within 12 yds of you for 45 Frost damage and freezes them in place for 6 sec. Damage may interrupt the freeze effect.
    frost_nova = {
        id = 122,
        cast = 0,
        charges = function () return talent.ice_ward.enabled and 2 or nil end,
        cooldown = 30,
        recharge = function () return talent.ice_ward.enabled and 30 or nil end,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        usable = function () return not state.spec.frost or target.distance < 12, "target out of range" end,
        handler = function ()
            applyDebuff( "target", "frost_nova" )
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
        end,
    },

    greater_invisibility = {
        id = 110959,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        toggle = "defensives",
        defensive = true,

        startsCombat = false,
        texture = 575584,

        handler = function ()
            applyBuff( "greater_invisibility" )
            if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
        end,
    },

    -- Talent: Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) - 20 * talent.winters_protection.rank end,
        gcd = "spell",
        school = "frost",

        talent = "ice_block",
        startsCombat = false,
        nodebuff = "hypothermia",
        toggle = "defensives",

        handler = function ()
            applyBuff( "ice_block" )
            applyDebuff( "player", "hypothermia" )
        end,
    },

    -- Talent: Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_floes = {
        id = 108839,
        cast = 0,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        dual_cast = true,
        school = "frost",

        talent = "ice_floes",
        startsCombat = false,

        handler = function ()
            applyBuff( "ice_floes" )
        end,
    },

    -- Talent: Causes a whirl of icy wind around the enemy, dealing 2,328 Frost damage to the target and reduced damage to all other enemies within 8 yards, and freezing them in place for 2 sec.
    ice_nova = {
        id = 157997,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "frost",

        talent = "ice_nova",
        startsCombat = false,

        handler = function ()
            applyBuff( "ice_nova" )
        end,
    },


    ice_wall = {
        id = 352278,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        pvptalent = "ice_wall",
        startsCombat = false,
        texture = 4226156,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mass_invisibility = {
        id = 198158,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "mass_invisibility",
        startsCombat = false,
        texture = 1387356,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Talent: Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_polymorph = {
        id = 383121,
        cast = 1.7,
        cooldown = 60,
        gcd = "spell",
        school = "arcane",

        spend = 0.04,
        spendType = "mana",

        talent = "mass_polymorph",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mass_polymorph" )
        end,
    },

    -- Talent: Calls down a meteor which lands at the target location after 3 sec, dealing 2,657 Fire damage, split evenly between all targets within 8 yards, and burns the ground, dealing 675 Fire damage over 8.5 sec to all enemies in the area.
    meteor = {
        id = 153561,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "meteor",
        startsCombat = false,

        flightTime = 1,

        impact = function ()
            applyDebuff( "target", "meteor_burn" )
        end,
    },

    -- Talent: Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "mirror_image",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "mirror_image", nil, 3 )
        end,
    },

    -- Talent: Places a Nether Tempest on the target which deals 459 Arcane damage over 12 sec to the target and nearby enemies within 10 yards. Limit 1 target. Deals reduced damage to secondary targets. Damage increased by 72% per Arcane Charge.
    nether_tempest = {
        id = 114923,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.015 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "nether_tempest",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "nether_tempest" )
        end,
    },


    polymorph = {
        id = 118,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 136071,

        handler = function ()
        end,
    },

    -- Talent: Causes your next 2 Arcane Blasts to be instant cast.
    presence_of_mind = {
        id = 205025,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "arcane",

        talent = "presence_of_mind",
        startsCombat = false,

        handler = function ()
            applyBuff( "presence_of_mind", nil, 2 )
        end,
    },

    -- Talent: Shields you with an arcane force, absorbing 8,622 damage and reducing magic damage taken by 15% for 1 min. The duration of harmful Magic effects against you is reduced by 25%.
    prismatic_barrier = {
        id = 235450,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "arcane",

        spend = function() return 0.03 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "prismatic_barrier",
        startsCombat = false,

        handler = function ()
            applyBuff( "prismatic_barrier" )
            if legendary.triune_ward.enabled then
                applyBuff( "blazing_barrier" )
                applyBuff( "ice_barrier" )
            end
        end,
    },

    -- Talent: Conjure a radiant spark that causes 2,275 Arcane damage instantly, and an additional 1,158 damage over 10 sec. The target takes 10% increased damage from your direct damage spells, stacking each time they are struck. This effect ends after 4 spells.
    radiant_spark = {
        id = function() return talent.radiant_spark.enabled and 376103 or 307443 end,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyBuff( "radiant_spark" )
            applyDebuff( "target", "radiant_spark" )
        end,

        copy = { 376103, 307443 }
    },

    -- Talent: Removes all Curses from a friendly target.
    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.013 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "remove_curse",
        startsCombat = false,
        debuff = "dispellable_curse",

        handler = function ()
            removeDebuff( "player", "dispellable_curse" )
        end,
    },


    ring_of_fire = {
        id = 353082,
        cast = 2,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "ring_of_fire",
        startsCombat = false,
        texture = 4067368,

        handler = function ()
        end,
    },

    -- Talent: Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    ring_of_frost = {
        id = 113724,
        cast = 2,
        cooldown = 45,
        gcd = "spell",
        school = "frost",

        spend = function () return 0.08 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "ring_of_frost",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: Places a Rune of Power on the ground for 12 sec which increases your spell damage by 40% while you stand within 8 yds. Casting Arcane Power will also create a Rune of Power at your location.
    rune_of_power = {
        id = 116011,
        cast = 1.5,
        charges = 2,
        cooldown = 40,
        recharge = 40,
        gcd = "spell",

        talent = "rune_of_power",
        startsCombat = false,
        nobuff = "rune_of_power",

        handler = function ()
            applyBuff( "rune_of_power" )
        end,
    },

    -- Talent: Draw power from the Night Fae, dealing 4,113 Nature damage over 3.5 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.5 sec.
    shifting_power = {
        id = function() return talent.shifting_power.enabled and 382440 or 314791 end,
        cast = function () return 4 * haste end,
        channeled = true,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,

        cdr = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        full_reduction = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        start = function ()
            applyBuff( "shifting_power" )
        end,

        tick  = function ()
            -- TODO: Identify which abilities have their CDs reduced.
        end,

        finish = function ()
            removeBuff( "shifting_power" )
        end,

        copy = { 382440, 314794 }
    },

    -- Talent: Teleports you 20 yards forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    shimmer = {
        id = 212653,
        cast = 0,
        charges = 2,
        cooldown = 25,
        recharge = 25,
        gcd = "off",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        talent = "shimmer",
        startsCombat = false,

        handler = function ()
            applyBuff( "shimmer" )
        end,
    },

    -- Talent: Reduces the target's movement speed by 50% for 15 sec.
    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "slow",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "slow" )
            if active_enemies > 1 and talent.mass_slow.enabled then active_dot.slow = active_enemies end
        end,
    },

    -- Talent: Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        talent = "spellsteal",
        startsCombat = true,
        debuff = "stealable_magic",

        handler = function ()
            applyBuff( "time_warp" )
            applyDebuff( "player", "temporal_displacement" )
        end,
    },

    -- Talent: Pulses arcane energy around the target enemy or ally, dealing 748 Arcane damage to all enemies within 8 yards, and knocking them upward. A primary enemy target will take 100% increased damage.
    supernova = {
        id = 157980,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "arcane",

        talent = "supernova",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "supernova" )
        end,
    },


    temporal_shield = {
        id = 198111,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "temporal_shield",
        startsCombat = false,

        handler = function ()
            applyBuff( "temporal_shield" )
        end,
    },

    -- Warp the flow of time, increasing haste by 30% for all party and raid members for 40 sec. Allies will be unable to benefit from Bloodlust, Heroism, or Time Warp again for 10 min.
    time_warp = {
        id = 80353,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "time_warp" )
            applyDebuff( "player", "temporal_displacement" )
        end,
    },

    -- Talent: Applies Touch of the Magi to your current target, accumulating 20% of the damage you deal to the target for 10 sec, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies. Generates 4 Arcane Charges.
    touch_of_the_magi = {
        id = 321507,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "arcane",

        spend = 0.05,
        spendType = "mana",

        talent = "touch_of_the_magi",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "touch_of_the_magi" )
            gain( 4, "arcane_charges" )
        end,
    },
} )


spec:RegisterSetting( "arcane_info", nil, {
    type = "description",
    name = "The Arcane Mage module treats combat as one of two phases.  The 'Burn' phase begins when you have used Arcane Surge and begun aggressively burning mana.  The 'Conserve' phase starts when you've completed a burn phase and used Evocation to refill your mana bar.  This phase is less " ..
        "aggressive with mana expenditure, so that you will be ready when it is time to start another burn phase.",
    width = "full",
    fontSize = "medium",
    order = 1,
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Arcane",
} )


spec:RegisterPack( "Arcane", 20221120, [[Hekili:S3txZTnos(BjVKypBgfB54mjxfNQYm7C1EBTz2uJNT23SeLeKe3qrQHe0o(Qu63(HUbaj(gGsYzsUjpSZglsc0O7g93OXnNFZVDZ1lYOKB(LXNnE85Np(Sr4)9f3Cn9(TKBUEB28pKTI9pkZ2W(VVTEEwj(Z3xuLTa(8MQ265SFAnLUT5)6zpBvoDD7SrZR28SM8nTfz08QY51zlPWFp)z3C9S28c6)t5nZCn3NF5lzJ5wY8B(LxmMnQ5lwq4VkPz(nx)BRj7MYHIDtFhdY2nDBDEvDo9(Dtxwvd)j573MrNV(z)16SvvLllYxTMUBAEZUPLvS)X9e2)j72S8ISzfSVpJ9GQL7Mo(SDt)LQBjBMrQhTB6UP4CD96Sfv3vKvUOrDQGrBEBDnPKwW(Z2gYIDtN1QopRAZQZkPe4j7MsRypNnEvBP5BYkgDZ1f5n0gadEBwfH9))li1Gucq1IB(XBUEoBQi15zmAr(g2N(6Dt)HBUoBoGqV5662sYKQLt2wDhP(gkdloOppdXHtQQNbF7f7Z3s(42IQg4xyJWZngb57UPQQSiNoHH6A2OoWm60TtwnFXOZhTjVUUQUbwn0Q6nmC6UPpE30t2n9r7Ms(928TBjlgrxtMSmVUHoPjFvEXUPF6tmAqvvbJ(uA(0r1Knz5LmAXPsExDiHbYx6Dr3pQvTZxJWfB43KTkVFCF9vieYxNJi3wnpJ)V(izElLmHJ4(l7ME(fmGaxqDdRabIKU9zeFoUSKO4U3ewuVicL8n7M(cDGjYA8v4BpRD5Yrn5BxxvoPbisJA3QqKTiGaO8dEbfC0eiH5RZQxrg1qzsA2n9kXuP)WnzFCI4fCclDa8B4BJFmY5SGGVPnWPb7UyMFPxip0yIZB3(LZVWAoMvK1GyMxThJF)AKHJo)vjsd9ddNFwsKhopkmjjoJCUgDE248(mchdG8lC78ychrSYfPmvMGx)SATMWzoMCvgOFbNNtrKM(ciYm4x6RYiA)PMK2Mw2EfCanfg)zAN3Zn25zZJaKLWB9o)WLk)sDUansHxzB7nobwm3YweLKn5KgCRpta73JIYpF30VB30gcDYSQY2Mr0Cs94xoz825AcWT2AAjeFndMV56Zz)ywDX9tW)Es(sb9CEbbgIgAE5k4zLLKcev)yDG71VqfD6aWFvsaoUS9sIfYb9(CvogHQoX6FtEttEbPzK7DNgVfIOIOIrfXWMy2ifE48l3pipYzPi2bKWDPp7Vo3VgHoHmNF2rGBnL9qCtVcSxNXPm(sU9x2V1GuvGsTp35MHS66mU4SXPPPshz86WiJWcHg7xBZHH(vKNBSodbpmU2L5nRHD3vBz7xRD5TGT1GOlt15B5)X)EnHrxycdlzJdtdiZnncZDjk6KZ1mhty)XV9V3nTGSIuUiRMjt4P7MEh7P3LbgKdoW8Z3IEXW8ZIi(YFRI(UN923ZEP8sgXM530)QH9Z5uUFvnmBU5)RFTI9sRH)1Y8s2Ib8kI55imdp5w2xWC5dMf8N4OUgv0(jiOdZmdNsjB2wvNvm5US6TJe4ao)O27PXx29ACvu3YwHWpmIrs22wumHaRTRqrFNkfYj3gORcHZHdZMxYPLf)ovc5YRTyKX)NLDOmdePCUK0cgQM51Qtm7t7CLn))LiiRmpFzVaH9FVNUMZIu0q0KeLvGgIQTuurRXu5gxiPH8ndJp9slcUZkO7T9mllYBMNVTiVmRMPGTAZggYtB1HZUR3AYY6QgDNkyEIQOp3V5y9t)kMxPmn75ZZzkT0Mx2uKnA7CkQe4vkQqWPDsz1TzU8M1NEofJjCbhIxNXNSPQ8EBeGXZDlTv(uDHFN0VHYn91hZr2I7XnuWwUG2DCAypGNxvUOnNoAv(sQ8BlYNVwUk7rAliz01ZQQljHDKnSSMa(Z43sdVBIyybFMp436HqJweZjgQg0u8SS3xTlXiz43uZNByJS7qmy5wy3R7lStgrb5HogtCVhDZgOa3U8c07gyx6dafYzuqyXhzitG(iIQ5p9tc1aGM81z3skFcvgVY3v9By4qFk(dS3t8PCL9GevuZXM2Y5CncTLmaOrXkc0gG)gF3EVPd3NGH49mFApZWwkTNzAjld6ywMmcaY13xRlbXzauK88QQ)btjyedYIEv3HLefXb7hLGHkD8DXmvryrtiBvompcof5D1yO(fgeKvab1g4y2MLdXuVcEMGl5oMLJ7M(23)uzaVPWVvW2Sacay)3k04HYQ2vRfXKFwf8jiZcAhiYq2B1yJpolp2L2V3GdyrIBW(zcNpLb2oNF0MO6Sf5mo6jnBZQ)qk(36l0gixZlqjSJrXRXy0IlO1uHLZypf0JdpYkKcFa2bPRfGxfCHqlA3SffmTSf5jr(wmxlsKxpkjYEAhymrSkor1iloYBCV(PZqmyN4MpCpBwkLoj05d8(if70iU(NYcA)2370oBhrfpKx4YxTPIrAium4t1TZSf(p4DewpwBJrNyrLxOFlQuaFcC8Cv2wGFc())L6ksssCgM5X(dK9(fM5X(SyHnCnKY5ikAdtcVHCbmcbVVsSdV53BjeWluytf5J06S(e8(JCnklAR7LGyeXbhQoKF9ppFD1ODtblKu)jEkA5oZswiIXb7Xc7IeGgOLlVm2CcFAoByQRB3sfV8BFh6Nnee2NcrabTpdup2KbETZ8)WWEbHF1c0lbGAvtfo8iTQNyrvZ1nYT43jelysaTeAn2x6EJq6bAbIExN1Gi8zesP0CulYSeF)0ouyRm4sjY50rbzMDOgMkFr0ttTqqvShFuQFdywur1fyOfv5l1Cmw79MCBBrjPoBwoZPKoN1zFZz(9EBSP9nEujyORNOgNWnzFG93mbfKE)o6nje01kmmePnmM)C4n7PppfdefJ2LVeFNAYtGGjsrRm54voga5xaltz0xyRofEpMly3dCwukgGtiKLT1L8)1)lPUsy)jg1lycsYMZro9Q2vGkEST1ep)S0SM4GvQNUBfrI)PPkh)EYO9AcyZi6riBLPPSjXw9Js1NnRzQPxiQSgOoA4ImYOD8ql4(7cmrar9NLXpLlUxqBG4pVOUA7wKElIgQ09foxlkDb)xGJmgCqRR5SWkCFaToDXjgmmksta1VO37QUF2xeiQHmoIT4jIkZkUl7(go2eXHCrMZTeC2R2dqFsbZagJjtJ2NlGo0jgX5ign5fPekAVEryPYeAzR9(My1tCrM)0No5rcL5q00f2SlExZL)N(KtQmJn90tpvt6Fe9)rmFqgY1Edkvmyf4CuZbS6()42vCeYG7f(8QW8D9g1lr4FyQmY3SHWu(rjIkYJh8R7qVqNNbX3JVxgLHChJQsalURMd5KQUAdgpmDP8oIW0E6ShUwn9QqBjDnnRgTafLQaqoyijh6FRm3z9MlLAi2INWf3j5cyU6CU1sC2PQBDcrE97ZHFfDWM7o1t0k6MjaASlPGUdb(f(ZXtGvNwUvCKE(oRIUWNbVk5PRZrauaICOFZvV8sTNj5snsbJxhl9kLeHRlvJVSPcGE4ftICDfLdQbsFCqDiONBePDtInGfGMbqpl3Uo02kjxhKdsm00ZQAf2gIkV3QUYDxMjrdXBavd(R(SqEjTB6fABiCYC(Ma8MQIJ1HovbY9Fod6M0Ym(Tys2wpJ8csr29ty61WxH7OGxgDU1FUrNa3(JCHspnocsAw7HHygyz5zyiT6WNTfCHkFtlmjLzt2QMobxBHcwEj(fC8Ln(mkJ2ETt5G4odGL9NXKVSXYCOlmUwljHEq2rWFmFsKlQhkkqG4lKCOdUkP4my5tQpR8DBGHBR8tRICs2PHGOk)P4PJc8FABOtadXmcHBcOh942Law)1j9YAbuYRHmrYOKvyQIfKXypxd7hlCz(bBR6L4BoU51XTtsHCKMVBgY2S4o6go(RzguRG(gy6lEAE(9tvLnTBKHCG8XTm7nbe22kkehXScowdIvbirSZFVIkW2vL3c98lvVOWNjNSjDJcKYmQJcEX7sXvTxfAEDk7uZ1m3(1C8O)8CugXBH9FbA)SKDN26GzOXN8wr0TO13l87iR8dC)QXip7OAjXQzGNWzg(Atx0NV)jgUWWyeYRj7)s0mlcNeap8DPsNWimRQEljh0dC2tobIV3s2o(1Wd7SfJMp)dyikogXR2NHbH0OGU(2TMkjq(bMaXNMik)S950VSxXCiqnN0nwmMMM8f4wufNI1CTbpjkkXEOPDlPwwwNXl3Kcch9utymfocRQLbVboyAwfCssHf4VI7z6SAMhBa2(SmigXZiyac4riMj8Mud5cIhRaaOBwxHrJgcBarpO9Ie(a)Pe3DJEQtJLPdvZP9sjomwyDT4mod3(GP8CVrX2GLW4yL4mxaboYk)Pg3WdNJJ0C2BKVvH3SV86m4wjjtdtkWxV43hpKSnIRephMiW01xkJTvelPCtt6s6VzkUwbhwgEXm6mlxvlf)yFQN9PUyFtL3HrGpjmnaqTXY7LeZUxb89WXSk5pmHyYh2KahF0x(4DFhWN9dVhgzRw0mCztq2S76if8CMZRFxKUagc)23hMLpe2pUXAdk8ahf6hI0Jul9EQHfmxBiIKcJPa1Lx2fMugvpReihO1kyHPWFNnISGdE9wbeoWX8UsBTRia1psC3x1AwAmD6va3mwJNIoWcOo38Z7eyjzqQ2Wg9f8EMrxn1Ybk5PAWPgPHwsPV5QUcEsnUdFVsChmF2B0kqDJWyGKj)wQV3WzKtTYEaOMmp6NuuN5FdnNwl7B2LvvIwjCJJmnsLLtJp2A1zgoYZX6Vm9YYIEk46elc4QjoFDJdxuGJmxN8JaXiEFL8WFJeYtGqa0vYZXDW8fO5NidVoXxsdojwsdEC8Cg4TSGCB6rkjiOlo1rtQXXC(si1FQX5xjUHiFYSQcA0mF(hapCEnX5bqTdOvr4da(4r0HZqQIl0ouPPCMw9FOsJtAV4SVT15R)ToDhp4d7mihbkuzaor365WHGwlL(AOaaRCygcQsYsbC6wehelSEH8gPyeoINGBN1kJLpk5LqtdGoKZ195xMSCan0JyK40I(Ex2qBmudFm)lDrm3gu1s2yWe96eFgjJD99(ldzNHANxscGRG))6GbR1xSAdDGSIfSgDfzkf3M)dl1bfbs3tMCL48Cm5)8YLW8DI7P068zznZUYMzFd3Y)jEpTTGPU7YKXY)Eg1IzmXZoVkZF0X)LdcUF5x9MhC5X3cGlpck59qAtVN1LWEgNIcd2(o940AGKnUhG1HYkLcV7vj2CVuOq(w7dUaIX1N2QhxExz)79X(kH6mEpW0FZ6VuzRsX6pxjoofv39Y0mokGspvtzzoqbFA81(nbiqsQtcOCyw4Fyc6t0VSJMwGeNV0juA6hgslLi2u4LkL4wS)0UJpa1iH(a13e6EmjbgnZfF1aqibXhQzSgUAy0kio9BI)ouXF4u)ieib64mOsvjlx22az9jRmFt2KS5ZjfK6mMToAaCV1q8ynKp3Wn)W9ne)(bEaXNjPWiayGlplIRZb6Rjha8HBgIbBJ3F7ODVucMmGVT)8pX7pdZ3eSGxtuV1FsvJ(zHQja)(UmuKY51dGoiI54yOVVSjyNeD)huHdJJC0aA3(5BRPgrRVoksYqyTYy8nD9)gRgPKs5qQyx368LOk7(z2VVRhDmGMgb3n0hGU7(irzJZ87k3dbKhuTkuEqJnufejmeMNZe)Ejz1WtEyxO(09htZI)et8adL2GJxPPw9BdxzQW)KMWXqSxIP9jprR0PSAhgdduozi9tVXMVWJJli0wNKo473a0ua)bHjTtcyID9cphjP9VJZzbiAD7JiQQvQSUy1fASNRjjbFNqnynRdrLRo12JnTQN0uX8iAUELqaJJXTMYZ7u)74HxQOK2vxkAwFbC2ppWyXlb1rRjzf01D9aHlUuJX0QD7rLTeKHqf(QBzRsfXLmQdVthF35NsblaV1(CHKLqDVM2I7XoxBqg(D02zu6of75DstiZvdoF(1IfC(oBawI2BXg((gNAyxy01w1wVl(bHqXN7xh3jpSNPXEiY(yj(8i9uwpIQJJkm3aNTzBr(YC5Lhy4nXVm2M4Gc8FEK27ue1pdbqFEyajIEqNeZHEbhOFFxUpNY0OUr(4K6t4oGhkez7LzTf0BKv6T8TNx1cjfUzlPOWqIyWyOjOsKs8cuLrl0lsv9dm2lpZ4hb5MVWtrtK4qQZ(HD6Nve8wvinQnxYJQnl9Tl(ukhs)98sCwiFCDwBdY72Rh1N0pmhTaIywf03GFmC79Wqbt0SJ55617l2)xG5ga4ik11MUUGGekajjE(QrkvZK)t7IvYQljYjs(bduMLTcFAntAnURpn952SbZy7gi1GeFyustbRJrPOQAXKLT1yO)ttTP9Oaf1nosWGmO7KtnJXz2R1qbE15zSD50Gv3v4HQTHmH9MB4hVytjeICFmpJhQ)LmFxz2AXMx2SNVurgL)xH6OqGKF1QcWFikKiHzzlwz3Jfma7Kc(mEDZCzm)nyWZYLK50j8LOfKqdudpEVTzCzCtcHk3Sm)sRQa5YyFaVlB8v1kEx(pYT5DjGbg2Dum)TnRSPt807W8yTJE0wrt1NG6o1DL5be)6RZBZ0dDptfsbZa3fORz3ei8OUyNgwjCdLokheTNyAGEeXQ68ntiZlY32mui8hgea(ds4tBgPMLtXSbaey8lpRZHa1S7uvc95RoQwDnBwZAMSm72k(vtSVAiyt28Sz1KjnRjmwPnTn5ZhaeHj0vHVRdK0Vki5rAt47S6gGE(mhGbnWrT)yb2ray32eKER3he6994CLY9BJIacrJHimYX3PLN54iBXtwa(AImOYcEThbPE6TeM(2Hk82hioXRVWPKWGXPkwDyccgubklI(VPzTr)2tvyv9HDPoY3V2r3(YrVqCTEahoAMRoarV7yXFDFPASB6V2o7ES7F9Fyk7z(p6TEo09gQpp46DLX)sx4HQmjrwxeeU66)AFVsO58)XLK51vfmjYYVx8X2et9X41DbGAroZDtM08DtFgJidOUofCkh1gM6rCh7cLuBMqOASlrKU8uAn9qQxvB8rUkPgFMkwsAb7DBUVmJj9NPjFnmM1gKn3gnM4EG3iCjZo3UHvIe2qtf(DFRbAGByLfGZK4rb9wstdPyaYMJQKtvzYj6Nd1KeOhvmSCHBTiOosbCVtb3VfrIznn5BYlevl)xHlB3ReAGlDfYSQsyBXKBZhKrvF5SM1xb0a3eiImpaApGUewvE9xLlyhldA4lTJ1S14CAdt05kszlt2jZ4G6VoP2(xnuhzixvW)K8vLWYDGl7lIVSv1W3nl0G5cps1q69KYejXQMEDclaVUDYayiuxGhgkbZnRGz3b(htkYHUmc8FfXS4wOrFqdMz9bbbimpGS04q1)WxeY1G)ytNeSyKMKHdhIbaHf)XB2T9sX3znmeRD6Vg(6rhcWLvcTFh3lRpZGUci7pm4FMHPo33qWkHM7dBRbZup(9i1FuiYUlaeAWSH7dMp)pcyUhgUbtZ12AYCi)62j6QtkeLWCJyUvhyYX7UmJzfwEM5DX9fQV68QY)tBny(Uibu6V7ZvFxEvWpjFJvBykqcC6QoSBRalclitAQkU1QYi6ETTTnuORVsGZ5zEFQt7bJLfKM1ZRZwgjFn7hre9EIFt6l1lxxTiFL(R0Rvb7eZGtoZnc6HPYOqbHvXmr1WcbRp)mYQgf44EUtB1gQR8OGzv7hr(ZCu8j(rPo34Bhku2E1XeOGz8NTQJnK70sk)HZ0CRK1jB3VnB(bBf3Puos2uvH4bUrKuAsl6bD6915vSzphUcsfxBx8oOZUP8wOJSxlMTD0UP)l5vxk)34NsGkOkrUJ5yK21lzp6DV7ipj2aNs6osrRu0)YQRmydwFnEAyICToDiSdke4i1FH01WulrdWZHF4SDANcHtsoUANh78pCvSsL5OFIl4VssNcgDSGQFNM3lvofJqtR7TLGSvXchG1dOp29)h6fJFtUucZ3GLl52UNukEQpBmVrBcJklcTgOO3QzWr7SrxVFwEnEzHk1LlVZHZXRFAgKH2car6hA2VIRGEUQF(nIGERyg6AZpDN8I3L9)AqzV8ER9sJib(OKIdvkBYaQ9RWCOEcEZh(DoUe2EoCjSDAkmHY6qjHHlSpjjS6qUbTNoGK68h3YoIPTj4pEO0hFS8IuFBVMJK(cHTspvW9LWdgk2(3sZUyyVb3yyJ7P77yEX)u97sEORy3VnHV5G)1JE42Jyw9mbyeEryFRsaOc3p8mAEfHIF93mhmOdp)HzgObj0NtNgh8q7BHxX5ylVB3d2s6bD94fUlEN5Sq8R3vv(eQqVZwX9Fv3LBp2Z6XYKav7J2nW32HAX4B8GRZhENQpd7Z84Eq6DvWSb4WD9DUErRXhVz(ra7USgC6HBmrUIVrozvdZH0HDzYn9CE7hGzswdswxfCh1AStsWGrZt3QMXxE(OGWN8(bvKQRWa5PryXFJSIHIyWEe2F3EjGS1(U0lsLTwQFqEbOVTQPjhqmpi6lsHf0v3V6qCnjM6eKpB)ASTctSc0TfJp5EoAKFrP0qtG7x(TGJhefl7cEW59wW6rk2TemGcWnUTdpM0NdFVXvpu3u4b7XH(tGtmC1am28KU949x7qwsbo)cnYUEFgnq7Syq3Z(bIbuQlMH2RVrdbdKONa9UWHT2uBCaAts3CBTYW5pqFOyqZ)azWJbw(94y)AsebAJzCHd71L1(FQLReKagOTSDa47dbtf1i4ygZ6ex2pN5d7MTpg(l45y9pc8xkb2DO(e4aZi9k4He3gSFPDmWTgkxs0GlnVLQCBayIH8oHGNhZWUWMsgx0ZBg0z(lMEYuUx1cFxJ5Onz5lC5wTGehE1TTAd3zSMFVLqG8LdbDG8rADg7FoJFh7HXGOK9J9ib5DziCr6vwqGtoTSsvOOFHvLquYx0wJXQqglceOHFw4c4A42qCdEJdVUTCfC)4jmvUpokAxf8rf)zZ)MYbxQV3wsd23XocDfhZgEJNBn8hRVlLJCdqBPb76yow8dcTOVbq9E3CiT48HVMO9v7zG6arjESAC4qajWR4AiMBCUmmgykrOhdjxFEHySZRGqNTMTU21DZxRIj17ecxyumPHsdquw3yQCexFnoRjb9RltiUG4EiCNnxuNapUB6sMhu3pA30Fd2vJX)hoowN)cXBYMO(Bpt47ZMlk5ym6KOSaORSabBCjLJBXFKjDTSKu0fNriULCEBUuKLymhgzONQd1Ht(KoOe0q0D6Oo)mxY6xBFJi9cjYgyncvaB8U6LEjvRvYwUPKmF7MNYL3FKB50(lmkhxZPIcw6NfNW3Dt)NIJ4BxMiz8Xlj31jMwoAqi5qS9Dz58tuxpfdWB8qeJ)jdLvtvohE4zduLY0DwQToOXCRq7pVMgIgmFDDDJV4LsPasFPTE)f5nC0MJ0zNsqs8QaW6mUXZqyOilSpxgeDCqUVFutro5(4HUiefwhoXXYDoUoIFHx9ju60FHTg5292X7AUOK2D6SczRZkfnvSlTJVO5iPZvlmq0ng2z8k9pEoXlEyD3zukiwrzmHexd5(boqolu6)IjqgCff6)mJ6D6HM)GsTFr)XF0KsDdzIT2wDJAm9B9QUZs7jcd6cxY5whcm3LDUMpHXdgRhPaNgkkLjuIYUrGXdlPDe(9h6OGB(uXuRzydGpfC)nwOg3RBZE0hWXy(PfEO1TQbt2E77)l)6)89sN5GmA)JqdrQaZxmpT29jDMH))PFQbpa)ZNtw4tN8W9qpIZlED2ZTzIa7RWor7pxJjt3pnbIX2nnCuMjXlq)kYvk(CZu6JA8RvVxsbcH9vr5rC3RlkowGRCNCG4ujpkNXKJasDvvghJmCPsuLDDlBIVKUY9JKWMtDMeUqwrQggShau1XCPfqcO)uLfrc4jHIZMREmU4f59eEmkbQR1Jsay7ALTbnyb6gJK5uyCFZvwTGQJok3spGVgiGdf)o8gKT6lrF5eW2tf(SZJJkyyvoTHuSKlUG5ffw6qGB7m3TlvpxlqaLDqUnyHHMl6zH1)BGdpc28DAKCiguHzGSbew5ILosrxQnqYehwVbhbpZiryDUUTdfHxaZ3P0pOoEoF0IkKlc92)Tv)Cx4vByKpcp4c3x1kleAKfRlwmY4c1fQNgcqv7hd(sg46yRbm(eY3Otes33USQTMUEVrQJ3BKQR0NAIaXkqpqqz(BIUg)UP)881vmC2BfMn9JfOnqnRz7bGLnrwi5mbqumyIqSwKV9pl7pSQHOb7jDM407sI4T3ytZJA5AVDf)9fJ73k49aq3hGWKgR1RGdKFYG3qbhFaXFY8geEkHx2V8pLMnEkjQYsySWv7eGb90LKWs71j9YQfjMNn3HsywCxLGslGTzxkuBgHEhb1sRL0QgU16TLOY4F8FW1ax1sffXlUz(xLFY1I8CTGKvuyhkZeD8jI99XmhvgvJu8DYzoYCOXYb(J9Z9vaTmXHGrfqYgmpEoP5b5RLkAdyVsFBynLam8g1BUOywiEQZmV5nE)9zpWyT5PHS7YdxCgd00I8ZddjedkyCulTixS5LWfFdqtKjRL7G5DKNawcWRTCszv7Q1WFX0MPOPVcZQaOTQUc(0o19YXcvzvxT9zyfdJPmEaC4bkHfDNZ9Ne1KcrWEgtc3BsKpfNTjs0R20AgTaVTFPa2L8fbT8PWo1UXNhOc02r5KGqoipSmNMdY3uMq4FawdUtEefS4mSU5y6JwXEB1F3o7tggDAxFbc)OiqWvALCS1IqZQgu(Hv)Uss)JuchykCNreNEdUnMyfDiZDBRS1ga)bZpT5Fap7IT5GrQDLfvxvAWwKzlP8dFc5EbzAr7MTGKoWHoKfOZVGoHmjkNEq7Q02SAAVvW(rc1rF2sFRtP0m6CAlw4anpfIKg7xFhh3TTRbsawUFlGrWgcbyLoZh3AP8hBwwpYXJAWOUPIPLK59kKVUx8DB2ZOgBkHtYXQS6fCD1ahMHFHPr(trO6WqsuhT)lVMy7WwehoJbhwfHVyCQCUnYYWLoCVeU7XYDzEyxExVU)eqtPSlz4OjtJ5)AQAr8Akf0nPQHJil3CkFgw5wjnwSikJXKvfvZYkGbGg)I6AV5W9hK1qoJfOjMPuos7W2dVCu0o6bwDuSeSV4F2RmFgp4ga51u1rUWkKScrqE52y0ubMFTSg0fHUcKcc8GILh1XfYL265)gdSLiuOBc79b)SzsEcWyRvazhe74JcM7afpW0iQIogVpovtlhn6dsvlfvgeUUl4LBjt8vnei515D2b(uGoXqXvWRTjJrilROMwmYlHoukr72TvqfePuaNaewcxHM21W5COUqNr0TwezTGg)qhdgI276oeYGF5HaO3Yi43SyDpRVdt0JAWQju0lRCumH90P(WHfTvzGSKbADlM3NmkbHiHP3Ftfs7Sp8Qlnw5E7Ln(6N6YV2vvaP1f9u7NaQy2a9qpnq95QfhTzMssOB4jkw9B8NHRFqfCD1Wq0a7HCdd1fHLGzBsbzAvP2(RFdFdz8dfFm5I(sLWa7WUDaOnkvlWjV0(2GRJL)CTEcPJ0FPrAo3vxHKxkmgV4qUZXG1qaUhVhlZuQL(3x9UDERLEJefO5tn0MzEgKPFUt196M6s(xNTQqy55N0A1Fsy(fMtvYINYvjZE8tKogIGgOdORC(9oN3r4IYrLnYCo8Uod20LH3G6hYPMn5J9)ASn8ZnlcOmTOa56UJ9785fUwSIPosnEIKEGwGO31IUPWmcpHrWA1ImRe4ev1Gsx0tGZPJc(RvVxHaokmFFIrv7iJsdCqkQObQmcr4xtiI)YatVB6zbe8eZ8xNoklBro)OQRXiMNukZN37LgP0TtLVFrqY(BsVOkiRyFeZ(G0PsUuUSZ8iz0BRGHBoYfl1r6SpwREjxyVmKdexSxP6ia38GXuwkO7SINKvZSed)7j5lDeRNjc5Ji094tCrB)0No5rcbJqiLeoakExZ1(N(KVJBZPNE6n2Ph0RS0iIILbYu5cUHJFHnGMrAqTCSIlJ(njfLE)UurdEENTOaM(HR9mZZ8Np7jDbd(o2rwUao0K7ePoRvOo27m6QBolbi8msf5()1TTKxf40Z6ZsYazUoaOR5vW5oUNT78tYNfzkh6REFJHTMYH(nx9Yl1E2Mne4IJK4IcfQyjTnGKktISprPeDVov6u6bogBhc)uNlLoXJ6gmFr6qo7tzsQWiOY2loE8zVIze)13Lvdc4BejGiFdpwaye)Ec3d7NaHn(3BzU8UqgnOSwA1MmSo8azLmwQr7(7)JCq3W5)x7M(tvLSPcF8tc7b(t42kf5TKs5yV9jN)Xt7MRXENln3TTNeNEJBo6N)CJH3w8RCK9ly2Aq)bVWSUYmBG2TYoRj4Lp0tWRoQOLD)DhmE6TR8JfdO2vnT9Y35nrT1Q37OR2knShCx9HJySZUkSwduBTRIU1CCV4Z4wsZ9mh3TKx(aZB)cJXxwXiRYxsLggvKpFTC899CFJV)n)ho3Z5MSMuM)QFGqTUKC7RFiU1j9lgz90S25TQ7t8lz8iVhZ)WFeqtpK0GXN9qo4pOYEmfsCys1fdQ5(PJke7FWpgmHbg(JJSMXp0kQh)zqrT8Uo6jhKk6hkfDhRX1JHGh84AYbCyeOpdY3SgCD4I5gPBago5qd3E1Ja8ggdVxWB4DvhLH8yIccOs6ijMXVAPdDcCkYbU)fhM4gRTVpagg5euxqwM1wqhg06XlaL(8QbdMJoaRfn6bym)mBd4dbrtmvMEvCuNQ)p27QT522gj8VfpDQcPFRswrPP3z5zUlTF460oxNMRF6MRY0sqwmH6LJuu(8mA0V9Bxqqs8kbKiOtBA)uIfj3DXIfl2DbWdezf6p6xwX2YfiZYZitIbnsz9vpC))(W9lttH0HIYMmpA360)ZFflu)weqTkbufxgD7bxhMRVcBKB5DrQXH2YxwP2ybKWFA9EZdOyG(9yZfbSYrB(YG)CjWPkS6BmCbWFU6L)E4fSpPzSG(wjKL4lhD9Bc7vl6C3VN73hijx9SQ0cd7jXG7UzuPk)3LkOV6LqbvBK1L5tEJ5As4bI3Pjq1Lrk2q2nTN4d7sVEke3hrLp0AqsT2v6qRERp54WymWCDe9edmpo1tmORRF4WUUObd7ULpqBeSv3dWV6OIHvwpB8AtQumTEVkjRimYb5BCjfoy6kzsMdDDxPPAnZ(A2Pt8vvXy20zxuM2MTs8Ff)n7O3)8YCIY(KxAhjC0zD(sUqODvb16k6AEQk)RBEj5L5zi9XQF1vL3SRO7N41cS1ruj7H2hbc2LXC3LHC3LLOCG1su26Us1fh1t24DhHn73YdACZoQ8aX7Y0Thyyqz713DgHnSGb)oIWvXotMJNS(DKjrRIxgnjA6uscwWU1v8XHx1z2wBzuekndlJunCeESX4a6EVm2xkK2ZIUAtc9Yryhmr8G1udfV2lwtYEqDqu9rRYSJBV0QKDD7GO6JwL5zm8sRszbEecx7uwYwLcZ6qR3hkkZfLWlkk5OtDqu9rRYCqXEPvjhxSdIQpAvMdh3lTQpntsRWw)2QAOY(EH8MNG2lKVBNZrPa8(iHuLIUxo3ojBn9w8qIKv)UZeujgNhWkkNodpWXQAc13XiJm4w)0LCRLuWxsU1Q47lgzE0QFkI9RTgXRVzqPL9YnjXZJNgXxJFDpZiHneVBliS26gx3(BrTJ9vS4k54Y2PlkxKgw3QlMU6nE1NeEPSTe)mHxYdF95AePudiVsC5jb8kXn54VTdpuiSpL6gQ)Gpcoqj1a)i7A9Pvbx(TZRwDl0hRhqx5ZSROB3E4f7ID8zxqZxYZMwxToxDfDnhiT)1nD5UyRl3eBgRyH32Pjg5G32PjF2SUD(WHq3q0UYjE3rydovANAOtiANUCFDPFPUDZZ3vwgD3c14)WQp89)JLLN0beqmlpJdjXzBX4c)13dHlUyD6V((3hVmpHMx97sJMVfHQlkEx(RV)l(Id3)JuylIb)qFp(lVNSzlz5diW(oyWLyF5n3G8dF27kI78Vu8xxD4EkKUT95nqM7jWNgV8DieFTAwcfAJq8pQccBRWyeQCkapWVAkw8OKjfncmjng5l43H7LwcVcnLyzoandIpyRi7qj)jccSMjuC2eXRyX3nSMdF7AkCK9DuCsHWWY4)53D4(pqXe(hitJOyp2ZRZPaDk9(PaL5uMKH48effqzx(nkaMCnV(BZkikd3SznJCEyw(NOwcGatMpNqXvOAaWbXFAkEPH6V39T)C5lLDTy3rgK380Tf33DKScPczeKkroE3C(UF6xoWUBIRUI5ZH(i8LJWZcZF7N(bA(iFKJY)46DiRlpxbzFf0HpLzxXa14FihVMLxplpHyGHu72Io5SRR2aSxm(RQ6F3sG82bHVP3AE0Y4K4Ou9VeK(1hYtXtkXQOjpsww0c09MLTLlra)CSmKqF56nJrOBB7LSZA24HUskYU1t2mvdfgmYvsapztEsYeGuizqIepFCGEhL9cKHQjexSKpqj4VPlZ0WWl3fLKtgpO4FNqsYiJ77QKYDat4KurmX6UXgrE7wX7AedQK1fuZzcW8hmHcTt0ZtJAN234kX0ET3PspNfU0mkYsrVmCMa960l4uv65SnLc9sxVXNKlsd1UX5w7Y1BNGpLqMrBOtE4zvY92JHAUO8gCuYN92R7JWJ20OacJH0pCLzIpSp)ig3Bgwy7X3VPqqqr1g6bgLgKW6X330)QGrNBWDMRmQc62K7rR5ZOlUP)51oxxHbSdt)qONKoDmVNOFVBn62lm8IbJo3(5XJ5GQNZ(tBtZN5pqup)22QNzGMwXeYSPfRSWL1Smg)gGXmeyFc9xoFq)(ELJfkCg7(MrDe7Q6MKFNXSHVJFBRAP4GpiI4L5lf4(P6tsgnd1mo2vsrTl9h5eHTmrR0bNhuD7QswU55uceuaeWdDfPHHQ6sOQx5VYTo(73FM852TxWz6cKsC044b73RpWSWENjhzw4X03c0bYoqS1w1uxgnn6biq3SfeyW)si9JP73x90htWtN8weeYFiA2Je9pAjzwusciiCpEwu6hxUgy9mcet0M8Tqx2ucvvw9oq2BttZ3Ic7K)Bo08adWzKDXcVK8IWX)O8v0BnQjqdf0kzB5E2trFe7JZWlhGvZ4EW8e4TXEqqBTfYXqB4)fiV(K4LyETAFJ5q2llMIPcJJqnw0Y97nwTr90vW(sJVgZo3nmxsTpEDbw68ung0cLx(dOKEw1hZL3X4b9AUG3nMKgfsnBI2N1mX5h5vLutfPeDhe2KPapi83g5rwA6DMbPrVWubeRctliicCjhFbMhBowWKSnqgX8)ocRfL52sZjuTEI9kb31BHPx6vJ0RVzuih6kB4dgfYZTnRlLzTWOl3BsXibe3rWxUwxkajj9OeH8)webJOIPxJCyURgVvh2V)H1zz9MtJoGTe(3o(19ferARiBYhYN9yzFSEaPTNbmSTNrqAMw1fow9q0J0NNgp9JzDkJGoEs6hbJkxu9fUsNNN(SlVnEdRq)cxEzCk0STy)3uyIcx(IsyxXG(r)lxmJx20OIHRZtJatFm3ESwwZjA)KIIFnH(LYZ2zI3C4fUK1g126UXJgzUtQjrhNWmjgZGnoBPoN)nY3BHe46z)sxL(AbNvnHOeO4SFVRWRt4r0qKJjYwl5no1qEtp0FXDd7R1pVRtTf21AdLWjl6ABURCKtAamQCtS9X04LqiPjXBYCHJFTtm8RBOtxavKSYX7GedHGLR7wkJuTboOgSQv2C74rq)RHzzXGUzMqnznFIS1it15ApFJUFTIAbd6F1OZnLGafdFg2VbNIlIarLmdpZesHYGF7yONOgTFwNVnlEgvkQdumqPmd1Ja0D5IC74BSni3ntCmCdle6M97fNDVX3NM80H7hD9By3Lp4gOcIqImJ7U2491PDC4(FohVqwHiQ)aUAkjnyHkNTcn2Qkf7VJqakpbrwAr(jZQVvKCmkbihLiWPf46Eb(juFjAVMpCWa6oiqpQeBXvutZy3GVHzyiM0RBUDKSmsIvhdgD7H(Ickgm2GNddEaAywGKN3qBprzzXlJtQsF43usj5b4xHXot2f7WKvV0sh7KjG(xGaQ3ToUfZU1rIiidlG)AkKddqiYQCyWh49o93EktA3C8JRWBzdheUHMeoHkGbCzf5P5q4CZWojS4lxIS9PfyXyyxFhJhyoI(gg9dpu5g0cVNDXPgKKbm9g2(pycUhkkAXclY93B7Tr8t9YIvFVqGvQzGH1VvTwKUxWF7ILSu5mP7D2rmDHD5GvUl9Ail1iZo1LQqmpt0nvO5rgU0Ql3hj2fl3fhVY261FMNZELfLauU(2w9sZ77Mg3I(BJZdoooxXBCKWyHkKAT4GmpHOROjA3DW0cAvKOGUNZUkCrIO7ErJ(7NuzLcDislOlkW0fE1Ts(hKwthi7cTRVsDkg6Zk6XPZAojJ7QJ9w3c1YxjtdC(0OQLewa5omuWqHvsT6kEh8cySamSOVFtkz3e8k8BW1vgSOUXImueCGAdP6Irw0Ox4Gryrdp0Lsz9NwCT0IR9DuyxqqG9UQ74dHtDNz0Zu34ynpO6cguiXUMSsorJei7vdElvuLmIxEHYzjUnPWEeKVYdCBHa6yDa5IgqEVODbFA(2kjJR0XTIkCj9w1ddvxRYQYxNIMstOS0IuWxGBZ3o2fQt17RYBhkli2lEJHyT5CywTMCYexr30s6X3J1aPc0rR975(vfbtXAw)IEA2(1ftu((o9gFCfZUr5WczERtIZB)n4uhJo1zhCOgPANaqy9Klxlfd2vkds5SOu7NAdNo1(f7D7JTAdcTN2i6)5CLAMR8s(ln2cHu4e6Wj8c)ELSFPMBww1zvS7mVEeQ0kwGXjBx5qToqPYbJi6LHTKakWvb5XmlfM8UZC8yn6YtYRKvQAxnQ4XYSoulnKuFomc4ZTbFYkW6voYQ27pQ(RoEhlNAOecHLjyAh(hXb79olWbOpJBU3f8iVHs)M2aWpISYCivJBhpQVVzl1wQjwEZPefJwP6pTBTtv7QAFB3YZiAVKdoc)mZhSN1OcmOAra1WwNu13yUb)PwDAzFom4MgxPtFBiNTiEoDEYk9US4Hq4APWnA)(Zel8d8uR9KTqE7zmFa2yB(OhTgiABeeJ(HVd3Bt2Tzefv3MiSnYRjV)28K5jEQ0EmWxs5PNxS6vI0LnEqODmzxEYkqEEiobX67IH2MkJPtCjWKkd8ju9OBeFuJBjjtZAaJz8sRvPwPm6ZxHBkPeQZkKk90T6kFRl7hAgJ2G7YMvtPdZxcglvCIBtVLVPjkA(zvJxOpxMt1UQpNvFBwtGwP6RnKlEjSLkFwAEDOYEqEeUxJvI8JdOq3VNTD5wqIs2UGEIlgoYuFDvb01OE(KkFz5BiP46kzsWloiJvIUwpFbIc3vdcvdAMt06Piz3ouPGYUZ)gNjV5XEgjzFRZpJZb6(MnqrVVIaw6qeFKLBiLlJmzoybSadAaNFTyFlfEAbW0cxcMAd12PcG3QST6B1zR2cXXfE(Ax83BmuTtqp6eHBSdIFssrtDXZlAKCHT5lqB9r96TJmv51cY9VwqqOIreexa7zcIGluKEb(81SDuD0SziKZG)DWI1BiZZtsEoeFLPqFcshiOG4PXGd5NVwuC5zqviWLBhmfGdPelqInUjP0TczqOV12O8LHM)y5kCo0cnlKx4a(Myxm57P5YrPrxi96YwHjKsrzFv6Ub7zSmXsifZtNsiz40xsNwVGa0Q8l1nR801zBdToFnRz(DXOdsO5E4EQ9hIZrGyGMQlkrakecvraCI95vG00tW3E4()E9mohHMd144aJzvt9iOa5vrl4x))7gJtjeC0Z7Dm9QOUAs0g6HeVcEz4GFavZqm8IkBwUphpgj0fiBSUNEXGrLGeurcvOewbzvfhx5d3)i4coJ2bvsd4pws3JQfib2S0lpC)diaA9e5vjjmOVc7qHgi0RbU5xwS(53dD1KRPUPG(54LtPNHJDXZWUBMPf60LmLcaAW)lfr6k8lNTgfckIC90AiVgGxiRMJ2gBkf1kCVI6FdgwKHOX1QOT5um(Q8OKasCd(ZunvkAaGPcO2khRlAUyikIz5f3n7Nhm4QG(x3FObq3aI(F1hdddVIU7UVsxF1Xy)iCQweqjJgqEMgDIv3P0EP4mlIX)N9UA7Tnooc)BXiaQKrQoKswQoOscWo1fnT1ng2bnFuHVCs8qOUJLhzuvGH)T3DMzFFNDV9oszR46pzAQJ7T7SZoZZ86MyAqV9FI4Yq)PbD1mbd3kAB)4rnfZKmf)y9MxVlZwHer)PuuRxqCDT)yMnwN32WZvTrN3ju9wOQUjOsOAeJeEucjdcbKI1jv(JYv5)G63j6JEnaEsRZaBUt8jHLuOyZz3pdo8IVx4xioBddKy4xieUloVvvVf(xGBKoUOozTxOJz333JZREqIZpNF6br7rfhKlcEoomKtILhtW7LpLzHyrcZNW(Eusohis488nA2M3s(oqW)GU8XwwPgJiOzDfiJgxhaRHJpgGflOwbAk5IF1gadj0zcHMjyjGcuOdIw)qENkmLegKjKiFq2k8rCu)TI11GwzVrxIYoBIf0rfbXEZLUZZvABCx3eZZnw)Lt8JpIePIF9KiO0nW5XZLjpWx)mA()dRlVbGDP6lMZwuq4vYWtoOMdPYsI(b7vyRQuQvBrrLl88jReweb7NV9D)BQ)Akg8LPaK)jLyMjrOdZEUIFnoynly5sGSv(HuizE1B1)p8iBpaln8uHs0J7AkH55DSSFTSLXpdshIvhXxbG9WwxA5VvOB4Pukhl44WCowb2EYQNkBhPGmc67abAc1fao(7kBGUbQEXR2VUypKyZTMb6GKYCIF6hV0hS1qz(jlaPdz2KoCxZ)CCdGPp0yAwxCnNMlV4pnccuwgaOUC8NQa9DXOeHg1SsCI5RxhClbf)lLJ0xoEM1XtNcs6Ja3sY6rI0CmPCn0gP)rL2aWESYRb9dq)UwmsO2ea1ztn01S)5V)ALYdaJ9uuJdaFI(5ay7Ja0Nqh1gESguIbOjAkSAl4PmrAky8UEldE1ZV4B)Jdo5Rf6JVAAD12gbEWI1h)8RE2QzdBlxFgpk6pTlt(iZDC3YjRCZQRl8rDb52l(0hi4BJj9Pv9ne59Eb2a9K(BYeSnhSka3gbqbSNgz4)a264b)hjy0UDYVa(IcDqeyEJHXtYUH)Aomnh6N6M7c3MDvffzt4SCMdrMcPRML4d3NHA61s8EO0Y)vQ(1pzmEPMbeVtbMieeob9gzf4is53EhDDfGcdxjDUWY6QBapJlStuzsOyvk9kbX5IIwjExWBoqWkitXxwGSXO3FO1jEJnaQtLVrY6tAID3eYeu6AmaKghHFVh5lVrDiBFppxDPmDL8dI0byBbxGDmiS0fZ(WjE)RRbv5S4dIhl3lpUfJpJX7XdvlGxtj3t5hHv1nnLW0)bwoyp4lCleG(almT8YbDV4iJOmB3kWHhuHKocIESKIP7bHOr2jYiT)JOd(9VNd2u8dQ9NVZjV)ml3uR2yelEIGtXVTdiounUm945Cw4WXNe74G98eMdb4cpE1SdcYU(igBMZmn)YL(YXJ4N085BzwtCB3JAV037VOoWxX)UT)DWRnV8ZS1z)GNWn)T7Q6YvGBQQ9z6XVDLe1NLCVC)HdHGpasT4QIhpeaE)WKp6nMLhGFBFswcel2tsILSXmudBbqL9(vPvNn1IZQ6heIwfsNHy)OIYdlHHK(xWGrEv9Te02M)Z2IcishtWCkAZ6jIpoLsXi0mRkXxAF)SDxzL4dhbroFzrJaZmf4f8PRal5wI5EYA0CmL5wKsctkPSO(oaLDfeT9Tv3axiBRvXTvzQyd)sMl)RzLjeYiLUj2guw0T9w3Pu8wc4qo)ujfQBsC73wQZFQXSmZAXB4fniHYT(ZzMUMjSvdlZBjRNUH5bBydAXmmh6MM5T8iQSmfpa8tiJQGouH8OfYKUd52F37OmS7h)jWVb3uunxCEsmjjFkChYGcmWV6xRTmge(LGVA)gWFV0be7idcwwc(7L(0BRFd4DcXNGkQSzb2yF3I3NJ)HFfnFTaZMm4RuUPWA150GlDW)ALhEo5qPtg65anoY9ebyXveCaoLwPl1DylAHrApy5TCD6T69LWO8ndd54i91ljgJwCVOgVsmHlgZ73SG2xxA1SU9iC(Mo0dqfPLRhtnwmtbtKz0rxbDkai4loruWSl0LW3uwrcvdW8BpnXyXC83mGY)Ok8(2eXfonEkU)IrL7GyHZl2EMqc3W01EiNSiVvMV3IPKZ6gHgA1GTSC2IedqaSj(JTTtCLv6rugyWFxToiw9)Q4dtCeSPWeL4LZh(hkTDp9WbJBlYlbd420x9d4iF2E(owOLTwBjHQ8fd9MnsCAOSn87(oL7WLoZg9knfDqmcJ3xS5it6ft0vu3eilbLzE72QzKSqfwnTspuL1FtLt5knDzWvKHA7dc)ElyYoFVnk5yEaGTxdaSEgTxb5VEQd6i1)FjgPjyg2dK3vyCBP7bijjvf)wvcQzcslc3adiHjjrXyumfZ1pKYI64XDpdIGMyBdrWCKyVWCJf9Ki68t49Hb8k97N1ndtX07kqS7iksDEY3p071rNxiuc4Zdo7WJJD9xWH5mYXp15zGPrbUKs4wmzt3E7QpWvBiTVGSpf4yLy4jhEthgOuUF(GJbXWJcU8hgk9Rv3o3NI9XD7kNPDx5EzTrmBDjC(CV7SHXBwj21E9yR6N9GihTtrlzDu1J1jRp3AAF3QCPXBQFDCxAOkKNxssVv(NGZYngX0677(zlQLHp0(RKxulOnefZL2kk(Zsf2YPgOrr7vLOVt4NQRQr5d)IxJM(uvvabNeYjDvboGX4waYmLUcg3d8KUvc8T7ndDauSXo6E3VGJq8sAFOguesSwiJc)0IIkfQNGnnlNrzxSvLBYMpqVFiuy7y8E3ONCIrs5TL9c5QTJpA87H3pek3kEQ2MNw74cxoI0Jvy7fe74KBY5cfOiY)Ei0iKgl44kxxydj6i0I9kzEHa1dhKMCcveWEjgBhzHWH77a2mX(eCaetNoYvJtfsGr33uJf5MSgEHkVqIadDpa8cYc1vQT(qfsjGzAUVjh8Sr8Am7PsR4q7I4oNdIIsmSBkSqx6pIdjsCf)CZcHQU5YQOXKKI66CPOsE5uPY3XxPZRk)mSy(66vRWDbDk4qWQjEj8Sl(jDg)y2xxSwwswgEcKhRl7yXpQ6TfkpP6K4S2of14tRaY0ezQ4bukK(qcBMfiYXi(hinkrAa1qCWFJX3IAsf5mSoVEdGZfX9iPezbeIeSlTnLSTBmLQggntKZCS6Fieif4nAFbvpSv1ux6k1L1P7k)8CKaT6Y7Vc)FxXzR7vsnYrZFC4Q5rhRoW9KsiRS(w15A70Z37dho03JbsJKpYRM2q1FGJdOmEA2eWHg0riQyHft9cSqgNbUFEneeiWxcDA3JpBg6gSFC98UntwVrxInW0ga6qt9xO8rUfaGonldF5KVjs712yBnC7U54sq5pPLoVsIO92(y72LDcN6AVYooLxzD8gEe7cIi1O7TNJwxswHRbq3x1SDLqPfwg8ZGEfK6gZ5p7OPXKd9yrUtU3z666FrHWaCjBj(QLPD6TfB8kDqP8SlCEnanrk6WC0uE8xm)TYJlWZ3YtQlbX6W0IGbHqrmbILE)MccqCs(gaWYcXbE5dlEvgsLCE5VtPXyCXjw31t8PwEpIXX5JhnKb2N0xJkz)K)iuDYaugeGfy8zghAUa76kOvsWQCgDREzHnKQu7LfxVHiAk1EajwNKUWogDeNuJEnMWGpLJkXirW43lCwPuDr9ecyLMiCdJp7aV(9K7f2lbB2(EfZcmg32HLWdT3HKccFL8(4fkUw5fYRc7aaNU4oTXmQvhi0ejk3nPKUsqnewynzHuRHK5Q7(dyJmjtcO2d5b3yWQB4vlKs(pIjvgo75h8e1PPGNAEzdqZMZnLY07l(G78UHpHk4OFJEoUBEVK5Ec7dDSf84WRPu(1qGxr)uoLTcPIp1eW6eT1fC5fqpLj7(JWLJhpIH8mSlJH3kLHJX2p3g6nRx100C)sMUfcOBUs)5pXZMk0Ux(yy29JwAom7z0kvJLiCqJTEqK(1IZLakA9hClbpZiVpV2KQ)ziw6wxoK3E(62xMzZ61UvEy8g7Xy99GejtakqT2V4nh(2F4nk33a4YE5Y665lX6THklOn6I25yWWGgYKLz8QfIyZldo7mIfqgwk79Ll8AiwNLYBcUgGkNYpnS6pMQOiy8iCOPOBdkLMifNgAt4Y60tsq)2ZNdICJHFjCx4M(G2LJpEORPY(uVtJgfPlbl8795p(tsS0GadC25f8(Ds3HJ)z24MnwPkD4qFZX4tBP6z1Dol4ItENOlHHuv15SKwGqL3f26O20uS8A6mJaNPYNItegpu9bRo3HDYmNRurh(HZpDumDh4QT3A0tP(u6AHOYPJ6ZHuYcB)9LBydU4K03YZHgozT3oVUu7U(xu)kDQb3iOKfKDr3xVvz4pUTRTjvz5P2yYMcGiBgdt(YO67xQNqRTs)BVUE76nlYt5t2uMJ7bLX3wrkfckNrXHurpMB83NYKDbbdY9AD4VulrNyQ5fCmP)QvHMHSF)wPxPHyQvdpmndz9IIG(awKEKGWEXONo6zDI8mMlNiHjwxjBhTSeyXNFXXNgASDab0JgOCPVjOhcXyBqN0uBhfyvVX120BmxX8z4Ullo7uSA6W6LpL042(fY1Bgxa7CmGrNvonh4omZEGMbXAwxD)99)th5gKXtQ1r42WZtYxn25i4EviAgpyoA10hQIPhvyqCgVktQs06m)8mEqVKJaTbakyplMPPfBUdJqIB5Z0qmrBRq4oV8FsyCQHezelPjKb0VtjwoVa9zEw7q5ATueBiAZGCVoErGrwgccClSO7FeQSObQ6F4OJFh3PDGnrXlDsmSDJhLvXPDkwTBCW8sbVlNqAXzIQJ7LPahkb6q2)luJbxXjyZewkpImEuMinUzYXckUHAWs1OpLbDARX0GDkRST11R(gS9lqX4ExzRIexAxtQ5lKkokupt(IOCL0Fbh9Ruex9RjWE(hfBjUjtg5lbefT6LGIfbzjvLBkP4PPFHWhUMViLIlELOr(z1e4tHEzNcCDuKlzFiC9rfDpxkUjyQjXPqcGX4BnTq2xyieGyHuQcSLt6NjS2B2VGHGCBjaHuNeh6IJeYM3R3iR9S7L0vilFXK69E5EM2KMG081qNBlP0YMIYFuXvFUBOVcSD77RuyAl3SL61NhzcVFzJDXBnxv4wydZeGmlmmETgvZokymjyphteCKwYo)1NNaNt6Y3)ZRlUzY65KMhGNW3i08L81zXrzVenkmzSzbs0cPjle9VmKg4z5dYuJSX(RwP7uETk4KzczVFSRDB9)5qySJQa68XNPtEjDIxy)5RUzz90jlTZaJ9pdzCVrY9w5tMHXKH6)GrHevJVYCb0vAAPut6KLYSmK0t2udzpkLItoxuFTOCIzb3xFOjwc)v0Zus)lEBA8PYI9cZVl3KhjpgJNeXn1iyAnT9KrdZMl5RWl(IRLPyaUiwsfUVqqawTkuRYhXICeLoTurqDl0Q4r7H5sjy8WhLspoTcayoub37EHDdGzudy3fXcYACnMtXsgeKgA6jNsVT0k10ujTS)vtp(08NPCw6IhSAWvNtu7qT3MzDRW8dS6FKH)XGiqOF5pBe3J7hLf)eiK53ewawmputqZVie8cA(zYysWmWYhZVkA9(17HQFnAU81XQHKSW85pJzKtekD26TjNnqEY8h(sL44ujoFPcCYz)V9kW5XBL38rPIBu913xABaYMGQU4oMcmvrQtvN3Tv6aS0wo5OqlKj1njtwRefNG504d16QtUUmrjr0Efr8LkHy)wje5qxdMJ2MUKzhiOVVPpc1zWdr9fSxQRGpT1tql1rG6XwxVbNA9pj)7uVD0IZZ575IUtHQwfzTdKVicMmfJRdABCbAk5F3FLYkgSJnIZiYa5tr444uojrsjfLlLVPpgjEmHJItx8ltQth6yHjx1jVhEsSI7sYcVtD2ZFVqq6t5RKvE9(5b)spZyVul((3vqZLOLlu4CEqR6JMxVcN2vBOCPA6DTGcm969rFUfKXChhpUa3TBgT2MXyPMBFmWrpOTLqoaPToegqbLdd8iUnhGhROVfiv(oX(XwW76KTB)3vcyjG3bwvVbAXdqLRbJmewPjY7ju0vWlRPopR(PO6qoZT4GfUD2pOMexPh9NMghuoJCeAzeQ2(GtHbQF)M6HFFR2)4eduLP6Bwld5)u8wWfcIlgSlflYhm92mSlPrTOkXs)wDwSD)FWdKQyVQCD2NSZFfACXZGil)VoNTGdLTc307fvfqaRVc6MgfKeYbRlUwC6EbiHhUlukNb3in9ThFWRcl9fMsks6(WcrRrTz7QI1QysO)PS1DSPeLTdnrBQAcVY9Jn1V8eKJ9VGCEZ8Jk41tOAchnKIIgR41xSg8wRmyulGDT6LwLDTDRlr2mAWemtX0Nh4My3awPjx9JDXvhNyZoW(bQ4oSCCL1(YOKD4KSwSFwSwp)KrX4LWSm00kBYJO87RvFNCQHjrnFobkiinNvzo)nGpzK9IbfMb7KDw72xRyWKh5Lt9Cc)tJ0I(r0heNQ9(3hZdW7f6Y)R5U2XTHHHHEw6s2kG)KKwp4Eucqb6q7qBgAthZzpw00kKsIFSsqrr2cCOzE6hjf5JjHdFfaZ9ka3)FqmDyIEDuNXMU58swW4ZtK2QjGOlTSE)iQlSt)yAxofvnQtkVfasW6eaaHpGBGdSZjKDfFb3)cMpsIfAqWtOyf1Dnd4((mHo7HYFGNLhXDodM79oWa(HZqr)QIwgsgQp(5K0FdUNFYL5ak1svZ5CKso)JKTGymHBpcL2a)BEbPh3exg10jwYTvHwTQ8EB9Qxs2UqEawO7vpcZXqcnLz(91JZTY94QLWBaOoKN4pvMDR6pedQfE0t60aoPwZYZWI7n7GJQedODe6ChDPmRWgBjHT5APcHSV3ta)hh2KB(a15CLXYQ2fSWRBXf8UMnpG7)wipAKvQ0AUR4pEMeCA7VbHSONJTdoG2Sxu2AlHJTSf9AO(fgx0GAsXQMgMZm22BnjTCaanLCFJd6UGpKebkFCpYF5m1TXzQwo7lmlZZG8ZMxGYqDwIKwXa7FSuNBOJ15g4)pOXakrydIc7Mm8Yta6QmQSPOHN)0zICoWxghukoA1yTiEN4mQRgxbRZQTzu7yBhmKRf90SBxj)qDUF202oTIt1CTq2zgDwHK1bnrQy)WptFoC5p]] )

