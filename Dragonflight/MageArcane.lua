-- MageArcane.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID

local GetItemCooldown = GetItemCooldown
local strformat = string.format

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
    accumulative_shielding     = { 62093, 382800, 1 }, -- Your barrier's cooldown recharges 30% faster while the shield persists.
    alter_time                 = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 sec. Effect negated by long distance or death.
    arcane_warding             = { 62114, 383092, 2 }, -- Reduces magic damage taken by 3%.
    blast_wave                 = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 1,054 Fire damage to all enemies within 8 yds, knocking them back, and reducing movement speed by 70% for 6 sec.
    cryofreeze                 = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement               = { 62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for 11,036 health. Only usable within 8 sec of Blinking.
    diverted_energy            = { 62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath             = { 62091, 31661 , 1 }, -- Enemies in a cone in front of you take 1,300 Fire damage and are disoriented for 4 sec. Damage will cancel the effect.
    energized_barriers         = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted Clearcasting. Casting your barrier removes all snare effects.
    flow_of_time               = { 62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by 2 sec.
    freezing_cold              = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 90%, decaying over 3 sec.
    frigid_winds               = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    greater_invisibility       = { 93524, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing. Increases your movement speed by 16% for 6 sec.
    ice_block                  = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_cold                   = { 62085, 414659, 1 }, -- Ice Block now reduces all damage taken by 70% for 6 sec but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                  = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                   = { 62126, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 2,677 Frost damage to the target and reduced damage to all other enemies within 8 yds, and freezing them in place for 2 sec.
    ice_ward                   = { 62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    improved_frost_nova        = { 62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness   = { 62112, 382293, 2 }, -- Invisibility increases your movement speed by 40% for 6 sec.
    incanters_flow             = { 62118, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to 10% increased damage and then diminishing down to 2% increased damage, cycling every 10 sec.
    mass_barrier               = { 62092, 414660, 1 }, -- Cast Prismatic Barrier on yourself and 4 nearby allies.
    mass_invisibility          = { 62092, 414664, 1 }, -- You and your allies within 40 yards instantly become invisible for 12 sec. Taking any action will cancel the effect. Does not affect allies in combat.
    mass_polymorph             = { 62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_slow                  = { 62109, 391102, 1 }, -- Slow applies to all enemies within 5 yds of your target.
    master_of_time             = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image               = { 62124, 55342 , 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy         = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    quick_witted               = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption               = { 62125, 382820, 1 }, -- You are healed for 5% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication              = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse               = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                  = { 62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost              = { 62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    shifting_power             = { 62113, 382440, 1 }, -- Draw power from the Night Fae, dealing 4,730 Nature damage over 3.5 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.5 sec.
    shimmer                    = { 62105, 212653, 1 }, -- Teleports you 20 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    slow                       = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by 60% for 15 sec.
    spellsteal                 = { 62084, 30449 , 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    tempest_barrier            = { 62111, 382289, 2 }, -- Gain a shield that absorbs 3% of your maximum health for 15 sec after you Blink.
    temporal_velocity          = { 62099, 382826, 2 }, -- Increases your movement speed by 5% for 3 sec after casting Blink and 20% for 6 sec after returning from Alter Time.
    temporal_warp              = { 62094, 386539, 1 }, -- While you have Temporal Displacement or other similar effects, you may use Time Warp to grant yourself 30% Haste for 40 sec.
    time_anomaly               = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain Arcane Surge for 6 sec, Clearcasting, or Time Warp for 6 sec.
    time_manipulation          = { 62129, 387807, 1 }, -- Casting Clearcasting Arcane Missiles reduces the cooldown of your loss of control abilities by 2 sec.
    tome_of_antonidas          = { 62098, 382490, 1 }, -- Increases Haste by 2%.
    tome_of_rhonin             = { 62127, 382493, 1 }, -- Increases Critical Strike chance by 2%.
    volatile_detonation        = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by 5 sec.
    winters_protection         = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by 30 sec.

    -- Arcane
    amplification              = { 62225, 236628, 1 }, -- When Clearcast, Arcane Missiles fires 3 additional missiles.
    arcane_bombardment         = { 62234, 384581, 1 }, -- Arcane Barrage deals an additional 100% damage against targets below 35% health.
    arcane_echo                = { 62131, 342231, 1 }, -- Direct damage you deal to enemies affected by Touch of the Magi, causes an explosion that deals 194 Arcane damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    arcane_familiar            = { 62145, 205022, 1 }, -- Summon a Familiar that attacks your enemies and increases your maximum mana by 10% for 1 |4hour:hrs;.
    arcane_harmony             = { 62135, 384452, 1 }, -- Each time Arcane Missiles hits an enemy, the damage of your next Arcane Barrage is increased by 5%. This effect stacks up to 20 times.
    arcane_missiles            = { 62238, 5143  , 1 }, -- Launches five waves of Arcane Missiles at the enemy over 2.2 sec, causing a total of 5,540 Arcane damage.
    arcane_orb                 = { 62239, 153626, 1 }, -- Launches an Arcane Orb forward from your position, traveling up to 40 yds, dealing 3,060 Arcane damage to enemies it passes through. Grants 1 Arcane Charge when cast and every time it deals damage.
    arcane_surge               = { 62230, 365350, 1 }, -- Expend all of your current mana to annihilate your enemy target and nearby enemies for up to 8,371 Arcane damage based on Mana spent. Deals reduced damage beyond 5 targets. For the next 15 sec, your Mana regeneration is increased by 425% and spell damage is increased by 35%.
    arcane_tempo               = { 62144, 383980, 1 }, -- Consuming Arcane Charges increases your Haste by 2% for 12 sec, stacks up to 5 times.
    arcing_cleave              = { 62140, 231564, 1 }, -- For each Arcane Charge, Arcane Barrage hits 1 additional nearby target for 40% damage.
    cascading_power            = { 62133, 384276, 1 }, -- Consuming a Mana Gem grants up to 2 Clearcasting stacks.
    charged_orb                = { 62241, 384651, 1 }, -- Arcane Orb gains 1 additional charge.
    chrono_shift               = { 62141, 235711, 1 }, -- Arcane Barrage slows enemies by 50% and increases your movement speed by 50% for 5 sec.
    concentrated_power         = { 62229, 414379, 1 }, -- Clearcasting makes your next Arcane Missiles channel 20% faster or Arcane Explosion echo for 40% damage.
    concentration              = { 62134, 384374, 1 }, -- Arcane Blast has a chance to grant Concentration, which causes your next Clearcasting to not be consumed.
    conjure_mana_gem           = { 62132, 759   , 1 }, -- Conjures a Mana Gem that can be used to instantly restore 25% mana and grant 5% spell damage for 12 sec. Holds up to 3 charges. Conjured Items Conjured items disappear if logged out for more than 15 min.
    crackling_energy           = { 62228, 321752, 2 }, -- Increases Arcane Explosion and Arcane Blast damage by 10%.
    enlightened                = { 62143, 321387, 1 }, -- Arcane damage dealt while above 70% mana is increased by 6%, Mana Regen while below 70% is increased by 20%.
    evocation                  = { 62147, 12051 , 1 }, -- Increases your mana regeneration by 750% for 5.3 sec.
    foresight                  = { 62142, 384861, 1 }, -- Standing still for 10 sec grants you Foresight, allowing you to cast while moving for 4 sec. This duration begins when you start moving.
    harmonic_echo              = { 62236, 384683, 1 }, -- Damage dealt to enemies affected by Radiant Spark's vulnerability echo to your current enemy target and 4 nearby enemies for 20% of the damage dealt.
    illuminated_thoughts       = { 62223, 384060, 2 }, -- Clearcasting has a 5% increased chance to proc.
    impetus                    = { 62222, 383676, 1 }, -- Arcane Blast has a 10% chance to generate an additional Arcane Charge. If you were to gain an Arcane Charge while at maximum charges instead gain 10% Arcane damage for 10 sec.
    improved_arcane_missiles   = { 62240, 383661, 2 }, -- Increases Arcane Missiles damage by 10%.
    improved_clearcasting      = { 62224, 321420, 1 }, -- Clearcasting can stack up to 2 additional times.
    improved_prismatic_barrier = { 62232, 321745, 1 }, -- Prismatic Barrier further reduces magical damage taken by an additional 10% and duration of harmful Magic effects by 15%.
    mana_adept                 = { 62231, 321526, 1 }, -- Arcane Barrage grants you 2% of your maximum mana per Arcane Charge spent.
    nether_precision           = { 62226, 383782, 1 }, -- Consuming Clearcasting increases the damage of your next 2 Arcane Blasts by 20%.
    nether_tempest             = { 62138, 114923, 1 }, -- Places a Nether Tempest on the target which deals 498 Arcane damage over 12 sec to the target and nearby enemies within 10 yds. Limit 1 target. Deals reduced damage to secondary targets. Damage increased by 72% per Arcane Charge.
    orb_barrage                = { 62136, 384858, 1 }, -- Arcane Barrage has a 10% chance per Arcane Charge consumed to launch an Arcane Orb in front of you.
    presence_of_mind           = { 62146, 205025, 1 }, -- Causes your next 2 Arcane Blasts to be instant cast.
    prismatic_barrier          = { 62121, 235450, 1 }, -- Shields you with an arcane force, absorbing 11,888 damage and reducing magic damage taken by 15% for 1 min. The duration of harmful Magic effects against you is reduced by 25%.
    prodigious_savant          = { 62137, 384612, 2 }, -- Arcane Charges further increase Mastery effectiveness of Arcane Blast and Arcane Barrage by 20%.
    radiant_spark              = { 62235, 376103, 1 }, -- Conjure a radiant spark that causes 2,469 Arcane damage instantly, and an additional 1,509 damage over 12 sec. The target takes 10% increased damage from your direct damage spells, stacking each time they are struck. This effect ends after 4 spells.
    resonance                  = { 62139, 205028, 1 }, -- Arcane Barrage deals 12% increased damage per target it hits.
    reverberate                = { 93427, 281482, 1 }, -- If Arcane Explosion hits at least 3 targets, it has a 50% chance to generate an extra Arcane Charge.
    rule_of_threes             = { 62145, 264354, 1 }, -- When you gain your third Arcane Charge, the cost of your next Arcane Blast or Arcane Missiles is reduced by 100%.
    siphon_storm               = { 62148, 384187, 1 }, -- Evocation channels 50% faster and while channeling Evocation, your Intellect is increased by 2% every 0.4 sec. Lasts 30 sec.
    slipstream                 = { 62227, 236457, 1 }, -- Clearcasting allows Arcane Missiles to be channeled while moving. Evocation can be channeled while moving.
    supernova                  = { 62221, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing 812 Arcane damage to all enemies within 8 yds, and knocking them upward. A primary enemy target will take 100% increased damage.
    touch_of_the_magi          = { 62233, 321507, 1 }, -- Applies Touch of the Magi to your current target, accumulating 20% of the damage you deal to the target for 12 sec, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies. Generates 4 Arcane Charges.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    arcanosphere               = 5397, -- (353128) Builds a sphere of Arcane energy, gaining power over 4 sec. Upon release, the sphere passes through any barriers, knocking enemies back and dealing up to 11,300 Arcane damage.
    ethereal_blink             = 5601, -- (410939) Blink and Shimmer apply Slow at 100% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by 1 sec, up to 5 sec.
    ice_wall                   = 5488, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    improved_mass_invisibility = 637 , -- (415945) The cooldown of Mass Invisibility is reduced by 4 min and can affect allies in combat.
    kleptomania                = 3529, -- (198100) Unleash a flurry of disruptive magic onto your target, stealing a beneficial magic effect every 0.4 sec for 3.5 sec. Castable while moving, but movement speed is reduced by 40% while channeling.
    master_of_escape           = 635 , -- (210476) Reduces the cooldown of Greater Invisibility by 45 sec.
    master_shepherd            = 5589, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by 25% and your Versatility is increased by 6%. Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    ring_of_fire               = 5491, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring burn for 24% of their total health over 6 sec.
    temporal_shield            = 3517, -- (198111) Envelops you in a temporal shield for 4 sec. 100% of all damage taken while shielded will be instantly restored when the shield ends.
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
    -- Talent: Spell damage increased by $w1% and Mana Regeneration increase $w3%.
    -- https://wowhead.com/beta/spell=365362
    arcane_surge = {
        id = 365362,
        duration = function() return 15 + ( set_bonus.tier30_2pc > 0 and 3 or 0 ) end,
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
    ice_cold = {
        id = 414658,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Able to move while casting spells.
    -- https://wowhead.com/beta/spell=108839
    ice_floes = {
        id = 108839,
        duration = 15,
        type = "Magic",
        max_stack = 3
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
        max_stack = 2,
        onRemove = function( t )
            setCooldown( "presence_of_mind", action.presence_of_mind.cooldown )
        end,
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
        duration = 12,
        type = "Magic",
        max_stack = 1,
        copy = 307443
    },
    -- Damage taken from $@auracaster  increased by $w1%.
    -- https://wowhead.com/beta/spell=376104
    radiant_spark_vulnerability = {
        id = 376104,
        duration = 12,
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
    siphon_storm = {
        id = 384267,
        duration = 30,
        max_stack = 7,
        copy = 332934
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
    temporal_velocity = {
        id = 384360,
        duration = 3,
        type = "Magic",
        max_stack = 1,
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
        duration = 12,
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
    grisly_icicle = {
        id = 348007,
        duration = 8,
        max_stack = 1
    }
} )


-- Variables from APL (2022-11-30)
-- actions.precombat+=/variable,name=aoe_target_count,default=-1,op=set,if=variable.aoe_target_count=-1,value=3
spec:RegisterVariable( "aoe_target_count", function ()
    return 3
end )

-- Goal is to conserve mana through the first TotM in a fight, then burn otherwise.
local totm_casts = 0
local clearcasting_consumed = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" and spellID == 321507 then
            totm_casts = ( totm_casts + 1 ) % 2

        elseif subtype == "SPELL_AURA_REMOVED" and ( spellID == 276743 or spellID == 263725 ) then
            -- Clearcasting was consumed.
            clearcasting_consumed = GetTime()
        end
    end
end, false )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    totm_casts = 0
end )

-- actions.precombat+=/variable,name=conserve_mana,op=set,value=0
-- actions.touch_phase+=/variable,name=conserve_mana,op=set,if=debuff.touch_of_the_magi.remains>9,value=1-variable.conserve_mana
spec:RegisterVariable( "conserve_mana", function ()
    return totm_casts % 2 > 0
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
end


-- Tier 30
spec:RegisterGear( "tier30", 202554, 202552, 202551, 202550, 202549 )
spec:RegisterAura( "arcane_overload", {
    id = 409022,
    duration = 18,
    max_stack = 25
} )

local TriggerArcaneOverloadT30 = setfenv( function()
    applyBuff( "arcane_overload" )
end, state )

spec:RegisterGear( "tier29", 200318, 200320, 200315, 200317, 200319 )
spec:RegisterAura( "bursting_energy", {
    id = 395006,
    duration = 12,
    max_stack = 4
} )


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

spec:RegisterHook( "runHandler", function( action )
    if buff.ice_floes.up then
        local ability = class.abilities[ action ]
        if ability and ability.cast > 0 and ability.cast < 10 then removeStack( "ice_floes" ) end
    end
end )


--[[ spec:RegisterStateTable( "burn_info", setmetatable( {
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
} ) ) ]]


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


spec:RegisterStateExpr( "mana_gem_charges", function ()
    return 0
end )


--[[ spec:RegisterStateFunction( "start_burn_phase", function ()
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
end ) ]]


spec:RegisterStateExpr( "tick_reduction", function ()
    return action.shifting_power.cdr / 4
end )

spec:RegisterStateExpr( "full_reduction", function ()
    return action.shifting_power.cdr
end )


-- Dragonflight APL 20230711
--
-- aoe_spark_phase starts:
--    active_enemies>=variable.aoe_target_count&(action.arcane_orb.charges>0|buff.arcane_charge.stack>=3)&cooldown.radiant_spark.ready&cooldown.touch_of_the_magi.remains<=(gcd.max*2)
-- aoe_spark_phase ends:
--     variable.aoe_spark_phase&debuff.radiant_spark_vulnerability.down&dot.radiant_spark.remains<7&cooldown.radiant_spark.remains

local realAoeSparkPhase = {}
local virtualAoeSparkPhase = false

local SetAoeSparkPhase = setfenv( function()
    if realAoeSparkPhase[ display ] == nil then realAoeSparkPhase[ display ] = false end

    if not realAoeSparkPhase[ display ] and active_enemies >= variable.aoe_target_count and ( cooldown.arcane_orb.charges > 0 or buff.arcane_charge.stack >= 3 ) and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= gcd.max * 2 then
        realAoeSparkPhase[ display ] = true
    end

    if realAoeSparkPhase[ display ] and active_dot.radiant_spark_vulnerability == 0 and debuff.radiant_spark.remains < 7 and cooldown.radiant_spark.remains > gcd.max then
        realAoeSparkPhase[ display ] = false
    end

    virtualAoeSparkPhase = realAoeSparkPhase[ display ]
end, state )

local UpdateAoeSparkPhase = setfenv( function()
    if not virtualAoeSparkPhase and active_enemies >= variable.aoe_target_count and ( action.arcane_orb.charges > 0 or buff.arcane_charge.stack >= 3 ) and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= 2 * gcd.max then
        virtualAoeSparkPhase = true
    end

    if virtualAoeSparkPhase and active_dot.radiant_spark_vulnerability == 0 and dot.radiant_spark.remains < 7 and cooldown.radiant_spark.remains > gcd.max then
        virtualAoeSparkPhase = false
    end
end, state )

spec:RegisterVariable( "aoe_spark_phase", function ()
    return virtualAoeSparkPhase
end )


-- spark_phase starts:
--     buff.arcane_charge.stack>3&active_enemies<variable.aoe_target_count&cooldown.radiant_spark.ready&cooldown.touch_of_the_magi.remains<=(gcd.max*7)
-- spark_phase ends:
--     variable.aoe_spark_phase&debuff.radiant_spark_vulnerability.down&dot.radiant_spark.remains<7&cooldown.radiant_spark.remains

local realSparkPhase = {}
local virtualSparkPhase = false

local SetSparkPhase = setfenv( function()
    if realSparkPhase[ display ] == nil then realSparkPhase[ display ] = false end

    if not realSparkPhase[ display ] and buff.arcane_charge.stack > 3 and active_enemies < variable.aoe_target_count and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= gcd.max * 7 then
        realSparkPhase[ display ] = true
    end

    if realSparkPhase[ display ] and not prev[1].radiant_spark and not prev[2].radiant_spark and active_dot.radiant_spark_vulnerability == 0 and debuff.radiant_spark.remains < 7 and cooldown.radiant_spark.remains > gcd.max then
        realSparkPhase[ display ] = false
    end

    virtualSparkPhase = realSparkPhase[ display ]
end, state )

local UpdateSparkPhase = setfenv( function()
    if not virtualSparkPhase and buff.arcane_charge.stack >= 3 and active_enemies < variable.aoe_target_count and cooldown.radiant_spark.remains < gcd.max and cooldown.touch_of_the_magi.remains <= gcd.max * 7 then
        virtualSparkPhase = true
    end

    if virtualSparkPhase and not prev[1].radiant_spark and not prev[2].radiant_spark and active_dot.debuff.radiant_spark_vulnerability == 0 and dot.radiant_spark.remains < 7 and cooldown.radiant_spark.remains > gcd.max then
        virtualSparkPhase = false
    end
end, state )

spec:RegisterVariable( "spark_phase", function ()
    return virtualSparkPhase
end )


-- rop_phase starts:
--     talent.rune_of_power&!talent.radiant_spark&buff.arcane_charge.stack>=3&cooldown.rune_of_power.ready&active_enemies<variable.aoe_target_count
-- rop_phase ends:
--     debuff.touch_of_the_magi.up|!talent.rune_of_power

local realRopPhase = {}
local virtualRopPhase = false

local SetRopPhase = setfenv( function()
    if realRopPhase[ display ] == nil then realRopPhase[ display ] = false end

    if not realRopPhase[ display ] and talent.rune_of_power.enabled and not talent.radiant_spark.enabled and buff.arcane_charge.stack >= 3 and cooldown.rune_of_power.remains < gcd.max and active_enemies < variable.aoe_target_count then
        realRopPhase[ display ] = true
    end

    if realRopPhase[ display ] and ( debuff.touch_of_the_magi.up or not talent.rune_of_power.enabled ) then
        realRopPhase[ display ] = false
    end

    virtualRopPhase = realRopPhase[ display ]
end, state )

local UpdateRopPhase = setfenv( function()
    if not virtualRopPhase and talent.rune_of_power.enabled and not talent.radiant_spark.enabled and buff.arcane_charge.stack >= 3 and cooldown.rune_of_power.remains < gcd.max and active_enemies < variable.aoe_target_count then
        virtualRopPhase = true
    end

    if virtualRopPhase and debuff.touch_of_the_magi.up or not talent.rune_of_power.enabled then
        virtualRopPhase = false
    end
end, state )

spec:RegisterVariable( "rop_phase", function ()
    return virtualRopPhase
end )

spec:RegisterVariable( "opener", function ()
    return combat == 0 or action.touch_of_the_magi.lastCast < combat
end )


local abs = math.abs


spec:RegisterHook( "reset_precast", function ()
    if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
    else removeBuff( "rune_of_power" ) end

    if buff.casting.up and buff.casting.v1 == 5143 and abs( action.arcane_missiles.lastCast - clearcasting_consumed ) < 0.15 then
        applyBuff( "clearcasting_channel", buff.casting.remains )
    end

    if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

    mana_gem_charges = GetItemCount( 36799, nil, true )

    if prev[1].conjure_mana_gem and now - action.conjure_mana_gem.lastCast < 1 and mana_gem_charges == 0 then
        mana_gem_charges = 3
    end

    if buff.arcane_surge.up and set_bonus.tier30_4pc > 0 then
        state:QueueAuraEvent( "arcane_overload", TriggerArcaneOverloadT30, buff.arcane_surge.expires, "AURA_EXPIRATION" )
    end

    incanters_flow.reset()

    SetAoeSparkPhase( display )
    SetSparkPhase( display )
    SetRopPhase( display )

    if Hekili.ActiveDebug then Hekili:Debug( "Arcane Phases (reset): aoe_spark_phase[%s], spark_phase[%s], rop_phase[%s]", tostring( virtualAoeSparkPhase ), tostring( virtualSparkPhase ), tostring( virtualRopPhase ) ) end
end )

spec:RegisterHook( "runHandler", function()
    UpdateAoeSparkPhase()
    UpdateSparkPhase()
    UpdateRopPhase()

    if Hekili.ActiveDebug then Hekili:Debug( "Arcane Phases (handler): aoe_spark_phase[%s], spark_phase[%s], rop_phase[%s]", tostring( virtualAoeSparkPhase ), tostring( virtualSparkPhase ), tostring( virtualRopPhase ) ) end
end )

spec:RegisterHook( "advance", function()
    UpdateAoeSparkPhase()
    UpdateSparkPhase()
    UpdateRopPhase()

    if Hekili.ActiveDebug then Hekili:Debug( "Arcane Phases (advance): aoe_spark_phase[%s], spark_phase[%s], rop_phase[%s]", tostring( virtualAoeSparkPhase ), tostring( virtualSparkPhase ), tostring( virtualRopPhase ) ) end
end )


spec:RegisterStateFunction( "handle_radiant_spark", function()
    if debuff.radiant_spark_vulnerability.down then
        applyDebuff( "target", "radiant_spark_vulnerability" )
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

        startsCombat = true,

        handler = function ()
            if talent.mana_adept.enabled then gain( 0.02 * mana.modmax * arcane_charges.current, "mana" ) end

            spend( arcane_charges.current, "arcane_charges" )
            removeBuff( "arcane_harmony" )
            removeBuff( "bursting_energy" )

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

        usable = function () return not settings.check_explosion_range or target.distance < 10, "target out of range" end,
        handler = function ()
            if buff.expanded_potential.up then removeBuff( "expanded_potential" )
            else
                if buff.concentration.up then removeBuff( "concentration" )
                else
                    removeStack( "clearcasting" )
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
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
        cast = function () return ( talent.concentrated_power.enabled and buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
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
            removeBuff( "arcane_blast_overcapped" )

            if buff.clearcasting.up then
                if buff.concentration.up then removeBuff( "concentration" )
                else
                    removeStack( "clearcasting" )
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
                end
                if talent.amplification.enabled then applyBuff( "clearcasting_channel" ) end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            else
                if buff.rule_of_threes.up then removeBuff( "rule_of_threes" ) end
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
            -- start_burn_phase()
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
        cooldown = function () return ( talent.shimmer.enabled and 25 or 15 ) - conduit.flow_of_time.mod * 0.001 - ( 2 * talent.flow_of_time.rank ) end,
        recharge = function () return ( talent.shimmer.enabled and ( 25 - conduit.flow_of_time.mod * 0.001 - talent.flow_of_time.rank * 2 ) or nil ) end,
        gcd = "off",
        icd = 6,

        spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

        handler = function ()
            if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            if talent.tempest_barrier.enabled then applyBuff( "tempest_barrier" ) end
            if talent.temporal_velocity.enabled then applyBuff( "temporal_velocity" ) end
        end,

        copy = { 212653, 1953, "shimmer", "blink_any", "any_blink" }
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
            if mana_gem_charges > 0 then return false, "already has a mana_gem" end
            return true
        end,

        handler = function ()
            mana_gem_charges = 3
        end,
    },

    mana_gem = {
        name = "|cff00ccff[Mana Gem]|r",
        known = function ()
            return state.mana_gem_charges > 0
        end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 134132,

        item = 36799,
        bagItem = true,

        usable = function ()
            return mana_gem_charges > 0, "requires mana_gem in bags"
        end,

        readyTime = function ()
            local start, duration = GetItemCooldown( 36799 )
            return max( 0, start + duration - query_time )
        end,

        handler = function ()
            gain( 0.25 * mana.max, "mana" )
            if talent.cascading_power.enabled then gain( 2, "arcane_charges" ) end
            mana_gem_charges = mana_gem_charges - 1
        end,

        copy = "use_mana_gem"
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

    -- Talent: Teleports you back to where you last Blinked. Only usable within 8 sec of Blinking.
    displacement = {
        id = 389713,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "arcane",

        talent = "displacement",
        startsCombat = false,
        buff = "displacement_beacon",

        handler = function ()
            gain( 0.2 * health.max, "health" )
            removeBuff( "displacement_beacon" )
        end,
    },

    -- Talent: Increases your mana regeneration by 750% for 5.3 sec.
    evocation = {
        id = 12051,
        cast = function () return 6 * ( 1 - 0.5 * talent.siphon_storm.rank ) * haste end,
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
            -- stop_burn_phase()

            applyBuff( "evocation" )

            if talent.siphon_storm.enabled or legendary.siphon_storm.enabled then
                applyBuff( "siphon_storm" )
            end

            if azerite.brain_storm.enabled then
                gain( 2, "arcane_charges" )
                applyBuff( "brain_storm" )
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
            if conduit.incantation_of_swiftness.enabled or talent.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
        end,
    },

    -- Talent: Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) - 30 * talent.winters_protection.rank end,
        gcd = "spell",
        school = "frost",

        talent = "ice_block",
        notalent = "ice_cold",
        startsCombat = false,
        nodebuff = "hypothermia",
        toggle = "defensives",

        handler = function ()
            applyBuff( "ice_block" )
            applyDebuff( "player", "hypothermia" )
        end,
    },

    -- Talent: Ice Block now reduces all damage taken by $414658s8% for $414658d but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_cold = {
        id = 414658,
        known = 45438,
        cast = 0,
        cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) - 30 * talent.winters_protection.rank end,
        gcd = "spell",
        school = "frost",

        talent = "ice_cold",
        startsCombat = false,
        nodebuff = "hypothermia",
        toggle = "defensives",

        handler = function ()
            applyBuff( "ice_cold" )
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
            addStack( "ice_floes" )
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

    -- Cast $?c1[Prismatic]?c2[Blazing]?c3[Ice][] Barrier on yourself and $414661i nearby allies.
    mass_barrier = {
        id = 414660,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "spell",

        spend = 0.120,
        spendType = 'mana',

        talent = "mass_barrier",
        startsCombat = false,

        handler = function ()
            if state.spec.arcane then applyBuff( "prismatic_barrier" )
            elseif state.spec.fire then applyBuff( "blazing_barrier" )
            elseif state.spec.frost then applyBuff( "ice_barrier" ) end
        end,
    },

    -- You and your allies within $A1 yards instantly become invisible for $d. Taking any action will cancel the effect.; $?a415945[]; [Does not affect allies in combat.]
    mass_invisibility = {
        id = 414664,
        cast = 0.0,
        cooldown = function() return pvptalent.improved_mass_invisibility.rank and 60 or 300 end,
        gcd = "spell",

        spend = 0.060,
        spendType = 'mana',

        talent = "mass_invisibility",
        startsCombat = false,

        handler = function()
            applyBuff( "mass_invisibility" )
        end,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INVISIBILITY, 'points': 200.0, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 1.0, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 1421, 'schools': ['physical', 'fire', 'nature'], 'value1': 7, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #3: { 'type': SANCTUARY_2, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- improved_mass_invisibility[415945] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -240000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        nobuff = "presence_of_mind",

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

    --[[ Talent: Teleports you 20 yards forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    shimmer = {
        id = 212653,
        cast = 0,
        charges = 2,
        cooldown = function() return 25 - talent.flow_of_time.rank * 2 end,
        recharge = function() return 25 - talent.flow_of_time.rank * 2 end,
        gcd = "off",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        talent = "shimmer",
        startsCombat = false,

        handler = function ()
            applyBuff( "shimmer" )
        end,
    }, ]]

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

        nobuff = "bloodlust",
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


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Arcane",
} )


spec:RegisterSetting( "check_explosion_range", true, {
    name = strformat( "%s: Range Check", Hekili:GetSpellLinkWithTexture( spec.abilities.arcane_explosion.id ) ),
    desc = strformat( "If checked, %s will not be recommended when you are more than 10 yards from your target.", Hekili:GetSpellLinkWithTexture( spec.abilities.arcane_explosion.id ) ),
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Arcane", 20230718, [[Hekili:T3ZApoUns(BzqaCSZ0tp(z3ZKZUbsMlFidUKSy7j3cCFODllt3wzKL8PhDpZcd)B)QIKsIKIVK7hji42pStAlQIvvSy9Mu3m6MpDZ1Rdki38RJhoEYWlh9(Zh9(PZM(UBUU4R7j3C9(GWphCh8FKeSd())HSWGe6p)140G14RNNwMfc)02II95F)BF7DrfBlxDEy6U3MhTRmoOiknjmlytb(3HV9MRxvgfx8Zj3Ss)CFbaZ9KWB(1lgdqnA9AcBOK8WBUgh6BgE5Bg9UV)4ThV9xIssZoEB5EeqhVTi94Tmu84T)w2QZA(RFmildOd4x(uAXVC(XpE8J1GAefu)JGIWThVD0WZhD(SkqknWHJPd8dBjHF(4TRjRk3S58CyuRpVC)XB3GyYNi72NMfeF82)vq2EHx)I3mEk91)rsqyAYBlYIs(mP44TXP3ffwnFR)paaNM8TWV)t3Ngs5DhVDFg5n7lJbGgTPHKUUm7o4FIYPdpJeS(RhVTpIefP3Dxmz9XBt3SzGaom7nJVGIdF6bsWNLzx)yCqEr(XBdayTn6oGtSf(bI8BZ4u)tYBijbRIjsizAzboHhVDvAoaNnamkYLF9H0x)NUNadFxAg8(bR)JY8IDKeCQr0PiAhI47ZIsZIkaccEuwergqJMXXJ4GVC8280DaKIJqQimnnED6djCOTLeVhbrEjozfzbj5rmSnkrK4PSs5PysB5l5bWeg(bq8eW3pnzOisVjlDha1ODFq6D4cq)oxALkWqL3U564iG7JBNcsjlZslOmv4V)v6wug7E9n)4nxhcZajlk4MR7F82xbevqmWIoNuTqCoFShV9WHg(HWZZi7cIqg0vWKp(4TdoEBpqUreybu2YYCkxrp8KgIhGSiTmC7Y0nll2swUl4UidWT940dC6EpjKaF9Q5vAQd3gapF9Y0SvntAV20c(CntgIEa8ccPCpHXYGlm2fhVDOE2JbqoawMPGd00TnAtruYDl3N(aj7McqzOTf8mYMms(w2MpCgrYmk8Zae0XzyO455fbOgRfAF4UGVSKpaN8veRVNSKKq2fryK0fn4bJDd08YvmTTnSBbkoHalTzllafLK8cKINyJIvNY5avmLnNuCnmMGOBoYePQH9GlmPbB4dHJWi2m1i2yfMdLLPCih)UwyaW2WzF2Pn72xxrM1UGKGZ3hc6ONJkDSXbUGQhs(XKVSponN(lnyhU6rvyLVpi7Zl3dwmi21zbwYUF5DHRbDEvZlA3r7(X26wUCwdEbdjKeVejCgVzjZdfygYjWJqE)UOK123sPbF48H6jQ1k5nxxMJGFd(IiXwjcx9gzbRJcskyCfz(1jjDnxNelkVCnA0BjGexpYUSJSEDs420QTMg3xka7zMekORqke4LgrchRVZX1xQGa3Zkj24Y7lJtizbRIIblScs(tPVIv1p2K1FNnDpDcrg7TqSOzLonfJ8zkMxpfpg(Y7v4lggj1R8SO9Sh(BW)Ul6FdMMGzdukXge6yuAiGzRlZO2POejZttqKdjOCURJIeoOTh8wN8LqY(c2GNHWfCBIawkr6ciB0TXhaXwakFnTegg3HoUwf0tp6umjBD98Y5NOR0r47JgncswZHW2G7ruIzB)XipmITg3P3z8PjxmHUwRX4CJOwNG3uVSI60xclsEGegydsqJsl12YAvgz1n4UYVgFc8KjETLQJBTR30ALBj5(KOztkNXQ)IEGdQQsB7bi3Rk)jlvjttov6bd1IokUVhm7ZE47HzNjDjPpPM(p5ne201AEf0QpbJn5d5Ko5)M38p(cVfpBr2j6mfq1w2z7MIvFfQeORfPUX9R2(yn2drqcqCxAYxPOcFNGSxvRs3bRPR3rJgximtMDQZ3scIl2w7b(eMQ5bIo80voBBjjvVlvg5UO88OyQzTTaCr3gvz9sHtXzUxv55rva1Pj)rzgIIjblVJStFu1OtY1JGMDkpIVH7ekiaegHsRa728A3fpTulGJHfvr66Ej5k05esyzbOckAhrnm4wYWckZRCtwlHjB47D6gxLZxk7K9lTr2JZOI(PJAvCA664Y8cU(A54irFzhwVz4(aa6WSbSSIDlttwIed36qJlbEgFmMnTb6m7X1Wzw)HFOX)FQZ0ynUhpPTlLEnHqUBNRkZApFLVsewWg3CSPZoj0(udc3H(8EEysWUDrNrWJAAwgKKUli(RsQD171M2hizu5c)vV6Pr6hh)XHDETPcPgJnN7bBA7nA3BHUNz2NIA7nUsRWZEsCR0FxWlg1YhWArv55IsMavnCjVDrkWMUP8aJbwWh1259vnhd(Sn0hYxIaNnujidnQ71QczS1CKYIE95g5VKH81AsbpVYjz3ZCSQz9OXonFpON2emP90bP7W3cRBZsbngjfzSfGNC36f3cAjW4tEcBq3o5O6iZ2jFCOIKWYfofw8uSyKsTm07a00HNM0J3XOeLa8OSY9flJ2CZ1y0p8zzXWEMwd61VILC1KH9CtVWOoCO(vUC4Gojn3cbWjtjNOFGwNcQQDoPrZUyscjgyxb5y9RX0uI)x8SwgLxxoFSi1HvsrZ8mMHr6YvVPGgQ4r(KbGNQQL43otfZlnAWLs9uBhR6IBQ1siYWKZ9D5ksN0nXdDXSVNoXL(oqNMShFYyT8g)gm)CjZ68mryigTA1EM9M1jPABRxtMxAT)t0IEFBBsfYMxRNlwjf7uQO5gP9C2QaOzNuFuvPBYqtPlqxv6m76v7945S(mczycpugrA9yfoWj5iLr1nkZ2y7pEI2h3xyetBncn7cAxMn0GRTmZ)IKkvxU5OjmTo4OYjzCw0eSzNLCL5VAf)g0f88zNDQF2zPyWMGY4cDwnLqUFILOqqXe5EsgoF0mgslnjmryvnrKj4(GOyQVBnZFyAjYQZ3tIJTB70KalM51grOu6)QXOy1iQ92tHg(0wefPOjWbbBfO377ibSERlkHYaRQd7gGqyCvS3fzGeE2drfBX(IB)wCPaCwiB35A0aMthayrcFUOoDgBBEBxunUhDMDBUvPvrkqzXzSvxEYSSyHxZnTqBcY2(htR40W2ftskNnAEN3jRRHMhiezTBN1I7ugvbvpcCUKQN8cPAoftBWZL)r567We44rgJobePz6wfCh9PzrHFoxND06bcBwizyYuueG)Fy)kOxL22aGBPWsCWMcSzc424sllYJwtynJW60YvOwemW6ZWvRI6Htr2kXzXXPKPhJgtz(ZAopn6JSFGyDynk9yKHsbH9StzaHf4UicTCtz2xpj3iAa0MOmcfyD2jafaH69ZlqUxyatfzldVvdfJebG7UCfjJFh1BLI2FGLwwFzNZuPD9NufrW1CARoxmz4z6fi4pbBPKvKn0(CUQxTbq(d)2pj0xlFkigvf(W2i89JQLlzqI3XkkZjAUqgPODsm8qfXp3sG5KILRstkZpViIKnz4YP7dffYA7JvZRBvoRNfy3aEnLKh1YuNcdA99P5tEj1oyvwiTQ(TNv)uhO1Pjr9QRq3l2IbqwGloT5P(vydx2MwqHvDagFxvBg0WD8UgkgxKhixqPgOHe2sMIleQL5nzIwNENQJ)Ho2Jn3g5vkEneNzuC8DXPRiIStPAjEXmDyAom00O1l5Blxs(FlJ2V3)AQnEOa6RdDSLsQv0JQXYIuQS9kYxtXgtQb)9hrT4YGmU2tNIDrhAgjsqArW6ufPHIwdco7sX1Es4NxMfTJCA0JpetfsQzoRtsLtuCnQE)LghztkIKMCYqE8rjBizjPV0Oz10IiQQj9AeLaroKbEVcJ((0pd(gbAsxt(YlaUAAMr01u7LgfYCkaiWGIT5jbzVal(6MumslZoLO6GUUMXsSbVm5qIqSwYbuxhc9I3pR3R0ew0Hdnz6wcB(UPd69Q(s)0vJesfUo(X8rTZ79j4SEL(7(AQXyp)Q(WCUgB)BTbe(ZemZjnZkRtFhR1w1M5a6zzJ1vWpqQAdyssAjEu4yvqH6rh)05XEUuKSvPLefbPr0VHhHpflOT)m)OYrt8qzscnAeWXoQmIjxsu72kfS)xc(mHgsEc5bm0MDctmjHN9a2ucwRVRHMOud1WFuHQ)KyG7ze4L3xr7WMRWph)vVsILCMB0li5Y7OwRDm)vRyc8extdeCS507x1WAb5HbR1utBTzxskH6APcXuOvVSGyIjhjAw7K0L5b6zm8N6e)sZWXyvd(YPFIjduXZbOULMQMh2INeZW1yoDONgZQ8pXeGdt3XKq3Sr8LPbk9qecaE(V4cm82pR5GqkiedHMTK9hlXJ6OIt1E7PRB)O04xDFA)l(AnvoGhvGs)AAkl8v(tRPxGBcax9jP3tYWJkTWztZvHvNjOi1tvGIK70oP)8QAnUAs5ZCxXI11ivCBwEYWwl0AlseoZRtvlgynKOp2DNQ3SO4lV2uyBctOHmVCkCy2bdEzv4lsLQf32BoJB2QvkftKMwgVHb3RZXKSHEPzB)RaEPcaeXmxLl)eu8h9FuOUkABoZyUY2rNYJr3ru1t6aISMZ(MF84Uss2Kv7ofPqntm7T9laRTU1PrmXK36wHIaekOzTmeBUXMsdPeDa6UFCmjuT3ngRzSBc2bARcYugQ0X8OTxIsJv1XKuWdMCsbgQrfeQ4O0)lorLUhy6zyDdPawJ(fokwD6iQMcagXLWswmUPC8q8)X)n4phpd)ZI2fUGJv6Xj67AiLLk(78FZFTQKPIENK)qWErFuyxrdL5upCWTjcNwqw5b5BuWsbCnlpS0SSIdye9Wfc)14K1I8ltB30vCe3eBveTNFxmQgeIXihIQCDvfSRFCuw0Asz(Ynq8MyPyuEmbJQe9UeIhhWudJkFFAuCoQgiHexaRNL5kJOiDhTkYLjanb4jZBv1b1odHkJyBAwccgGitZmUWfLSocRzyopgfCviOo784YaEIqxLMsV0saec)NQdy6QYmC3zZ6IPCfORosDyDrlX2ZYkJpKBv5Kqyrj9MksWkkaTKbV9NzGws6RDwDRR2tDKirzzPzlJ21QxWCEKFzvaxoWI1rfvBWcUh4WaoYIIs6QHzfP4bcgQr(Ua8wSbVlBYTDz2qOxrmup9oNEF1qR9CqCoopHu985vv9GEx3KFU(qR0xjz)sqe7CVBP0uwMdDP4HAyq0HdR9ANypHl6UdtLCtGPIzQVzwn2MqtNvBLXUNdcZJRQTOPIb9QYBGKT6wMt0kIvyU3e4JZ(j7YlwLHy)94ubC1IwN1FdXGmVQdRn3Gl6Sn3jI1Qz4wPVO65nP4yKyWMEY5eJ)1a3ZpwJ9I51m0jnEluXCS1HDMdkQVutFjbdVqLfQN5Vbk9A2mtn(MJBxdZHl1xSZxTK2cZ0LkoQwt0wsCSmmvyRpbWvColqQHq7PYGM7vy4Iz5RVMJtN2dkesuAoSri(mrmJWDG3DHkVJxt0oaIzTy)MvZzoaop4znhtGPTNHhB)v2RU28n35vvNmFq79M42DO0WZ59FSqZak8eXMxYNEeFKUOM02T76czYq3UJofsYOhd(QlDqqB6dbzyQ4ZXECd9bbBgNcU7fFRy0HFl6tc4BxgUOZU25ckb3IdOobHDB4D0BQU)l6DrhEz59H0eycPp(Bvp)rFlZVPw)ELCf88(J(YaxWtCtRciL0I1nO2Ansb0gpuQEcFw(7PxkBkqw4jMG5y9Wu46JqbMAUyjAG5XpAyzxWxTUTYpZ6kfMsz9luIjBwLMV8jLMzW8DpdW89pdWCKbHO)cc0xartHeN1nXYjwflfSXQx6uJryvYFQHn7kjNsDhVH7tcvOFHEOR2H7kqVvdW7hx(005By5)K15BaEpsD(gG6tMoFdIbpHcAg0WkE84vrEnNCEpfWEcXBdACLpYAkqx)bY2t9UNGKN2TdY1E6jztHKZTkON26(4PqGAG2kG20Hgtf6gm4EIgX1Yu5LpVBCtdAXfZcLQaKMeu55wwPotxDhLUdnrlvngqxLEEqb0g6iIwa3K9MNeGBx8IheOEHlLie9f0NOSfhOg0E9O3Mn2WoHhbG1UBOUMzDB)GDJn8mEPNDQKUmpvP(i3PnA4tmy1Ymp5yxE(yNgeJEc2pzWQ6ZVD7NpC)rb5JF8NPcdiaFFvACWRi)C6nYpM5N0nryfTypk)869EVEXB5CL6kuF8JwgvvTP1pivp7p(XV5BQWh5rwL65ZWszTqTO(NLUFb6gFXzCtMlM4lOKUfmq4GqHwiVfd1J0YVVsnl4qiAZzaGxt)ycSq7Ua(CWk29znLdFbRA4a6F82x06u7dXAQ(1Y8TxP9K9itqp(636d(AQUUY4RX6OF4GXk1k8id1pxyeAQDUWt1x3CXb0UmYcpvQE5M5YDRSX(WClAxozd8vneqpZDNG2PwSU0uI8VqLw2QcqAkPplAZc9DPV1kkD1Oz6HDD0ziG1axufpYJ66XkVE2wiESYR)vyMzNpCCATv1xCYFUop4IyJl(qpKGN784nmteM1hDAbykfktpLZ8DV(wyfhoGN07EsnR(8fthc)UM2dwDCVB4arut5ivJiO(wOVN1EVVhcXMgM7QfJfNePds9PofujGxIduTeMxFYUr0UVHwJV3R6ZqCLdvDVwvYEWGdh6RDzYsNrkTG1CAOrmY0XWu4fQp1ZEoE5d3S1x6Bq)H(h)8BVUC3osZje(FYIeR23aEp)ZLOZ5D(FvR(xUh)MzvwuUlPgcFIT2KwDQs(fGrGNAaQz7myLx0tmaNzh3RLKVaVDsa7t0bZIc1WhES1kZ57P73)v6IySNbQexWCnE5hyxXWI(8kx)DtgmyG)eciEMJEKHYg5u(nLy(RdTCAKsaDHxs5V5BoTzuDa)T5OZlURR(EcGjIAurJo)GXL196p182uR0tlSqG1xvBUXwFEGrjeWqvpJ9)XaDKo3fW2o2XyjoBW8UiSce5RCdqtBJg0t8TB7Z6HdVQTMF19hQKnihNTeP8ITcU17WZikP170mNAcv0CK1ruO(SFEXmrY3u8qU8dD8qlcb6oK5uhE9yAn66u18QHDvFOuTHuTpu5(IsUWiFNt6He)LEs5h57xGP1WP3(5FM1CASF6Mu5D9Tt6KqAtLJ1DeIdERjUxF2KuHicFUaVsj0aXRNXRwmrqhUMJ9Mh3OPcQwh3snxhi4HiblrGcdTNh9NgtRNPtO38lntOSwhZkQBFD61N2RzCzzIsevZnVW)0T6DPJvppx5(R0QglxQvylGL2CisPzKBLZwHuWWAFgeGYXxpM6I6F(NVFJP04u8vOx)6B(bPmFywMcSUlOB084gnBqZ9N8C1BvIZeVHkw8IFbvqxkFzVSdex2uRKHvPx6YKH1w70PeBP3RuVUduTAkIn81aLQB3RDx6t1PnFSgee4aMMaE)QVyg1wSH5YsUjGW1(T)ZF77XpAZ3hLhrlBbEmnHDpXb3vxtJCI4x8zCfNaaatd8dPnzTyj)(lGpYQLW1LHWp(H)XVJJmbIlNEkLyW5pRRabjziLZpALh(IeflpcUJgYUJ1cMr6p6191w2WEYLTcBTGbySy6elK)vHR0ab3vADzgC1ui2K(EO3PcvN6LAkmyfVTh7zSL2DCCYqb2Tg76hoy0Gj8i32Cr2Op8jXGMRbS2Cu6p)XT8PQxIS9TmpM0M)kton6EQmnnUxaTJiDcjuoP9siIn)v8o4a3OGPP3nFWFe0SmHB8t8mriHGpH8GAvPFSPezIZl8IYngPugyRvgjOrPTcQrJXKhjRhKU13vOKsVylMTxAXqqyWfHMKIlCwiAPJs4w5hbgOOZymNlg2MGuE9bg5YYwnOCzHpGrho8k(XuvMCeJFsxGv1FXbmYeuKLUaNjgxrOL5nJ2TJnqbIZxmLBwt5tiVfczIRPdqnBrsUWh)1VA07Cnncu1jX0B(MNaHq4AYQ)0HQUvuqT6IWMph78A9O029iU22)qA1ZDy(9YzgNwajBXgpt4SKX0kPzA5NZnlWv(u8zzG(TYpFsTl0JSbT272A7MwdKSYzuDbh8c(Ffq)Ixt90vOLJI2vgtRh)(4GVsYO9drC6dupFZQQFiJrqFHOKqyXb7LdAzzOeOCO)AqNhG5(SCs4IHNpKgfHRvDnHtWexQ0d0setKV0rKXqOlpgqA3dDG(8W1qUAh)izNIccQnE6qUP90OxUBitFVNSXo1vGgc9gCJCeooao9uhij83Up29pxRzJ8kii(6Bxw9utl7vZg0HPA6P6Ws3K2v3X6dxUQLY67pVyChO8jAfQ9CJtvUPC6l2tNa0uTPQYt8TsurVBMg2E3wxVqizV2Rwm2w0IvAREFv1hEtDGsYF0((OzuqddTL)TwCKDG5Qqzv63duYLNqJ9agA95uotzpAF)exIBbA)wHTLvOQcw8AhPQtSm3TXJ2X4AiEjT9EKfalVyzJqmkfn3pbfttDTAoRtEFZYrkDVN3OM1qPxWZX2aBRk83R6Q5XjrqXM2xvo9uYm7(QZKiNQ1ELbX34A6Zw3CFWFFfs6u0ic9qLroMq9amo0tY3CxtSGEsdG7WbJDiL0J8L3PkLButKa0v)s2j8i1VIDITzM63VohE1EHvno6cC3LLS5v7A6a)Gcr1jJwcQ6A2g9i)AU5gBe3bBElNP9VYLefzbC(HNFe8CJFmAtWgyNt508jCLjn9)gtlsncE5qqwYDQL9iXvtgkQ1XAMADpF)9ixUk15EMNShpQzLHj0oXoDMFyKoLawKWADnCnFYmL6lkCilTjnxREOAbr4ABqByawAGWfx41mzsruhPkZUjnXgA0sdKg3eA)7coQl97AC)6fmv(6p4fsjBUjl(Yc9EUbAXOXwxtFK5fVwR98zd71s)JcUi0eJpROYLd7Pp8W2NOfFusRQbWoz4V4PYx2)tteY)nSDfYEye(5Cr8cJlIESKj2EuAAZIHAwrFg8H6riCO1RkBEpzAX6r)993PaMhIdI(JjNLR2kyRuPQ2oJT37whoZ0zMaV6gbvyAY2FDiOs6kq2YvQWO(GU7ahex6DsAgJ)1GHTReZZV(grDMnbRq8IYvSoBojbzR6BzhHFjvyBfV6CNpcBTjN09aDfyMr5UipZNLh2aMm0fvAiovxcSIrvk3on2rOfI37RdecCv5crvBu7AxFyb5hj0vhknWMjmDGLq59DRv9fClnHq9ejU5EK15QSKRgrIG)Iho0Y)YRwmbBbxhuRYLuBJhvMEbLvGbV4fdwMv3k)oDKGP90xhjz)L6em57X6mZfGPMG5Jjb1QNHe(p3(63DoWihF4GGbu6VmWfHkBTZgZqTGi)jxme5P)jkFv6RUIZyepj3cDnRc10rNjimKQ(MJdvxyRdgyU1a7ipXUtFm73JQctwTT5BmIi2D5mxuABqZJ1eRo0Fc4ppV8UywxjAqOrdSQeYGUqtUgdtQ4MRdkl2IF5uUMPPgEJpKfSHD9wFZ)3d]] )

