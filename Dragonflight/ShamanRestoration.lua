-- ShamanRestoration.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "SHAMAN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 264 )

local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Shaman
    ancestral_defense           = { 92682, 382947, 1 }, -- Increases Leech by 2% and reduces damage taken from area-of-effect attacks by 2%.
    ancestral_guidance          = { 81102, 108281, 1 }, -- For the next 10 sec, 25% of your healing done and 25% of your damage done is converted to healing on up to 3 nearby injured party or raid members, up to 78,460 healing to each target per second.
    ancestral_wolf_affinity     = { 81058, 382197, 1 }, -- Cleanse Spirit, Wind Shear, Purge, and totem casts no longer cancel Ghost Wolf.
    astral_bulwark              = { 81056, 377933, 1 }, -- Astral Shift reduces damage taken by an additional 20%.
    astral_shift                = { 81057, 108271, 1 }, -- Shift partially into the elemental planes, taking 40% less damage for 12 sec.
    brimming_with_life          = { 81085, 381689, 1 }, -- Maximum health increased by 8%, and while you are at full health, Reincarnation cools down 75% faster.
    call_of_the_elements        = { 81090, 383011, 1 }, -- Reduces the cooldown of Totemic Recall by 60 sec.
    capacitor_totem             = { 81071, 192058, 1 }, -- Summons a totem at the target location that gathers electrical energy from the surrounding air and explodes after 2 sec, stunning all enemies within 9 yards for 3 sec.
    creation_core               = { 81090, 383012, 1 }, -- Totemic Recall affects an additional totem.
    earth_elemental             = { 81064, 198103, 1 }, -- Calls forth a Greater Earth Elemental to protect you and your allies for 1 min. While this elemental is active, your maximum health is increased by 15%.
    earth_shield                = { 81106, 974   , 1 }, -- Protects the target with an earthen shield, increasing your healing on them by 20% and healing them for 6,517 when they take damage. This heal can only occur once every few seconds. Maximum 9 charges. Earth Shield can only be placed on the Shaman and one other target at a time. The Shaman can have up to two Elemental Shields active on them.
    earthgrab_totem             = { 81082, 51485 , 1 }, -- Summons a totem at the target location for 30 sec. The totem pulses every 2 sec, rooting all enemies within 9 yards for 8 sec. Enemies previously rooted by the totem instead suffer 50% movement speed reduction.
    elemental_orbit             = { 81105, 383010, 1 }, -- Increases the number of Elemental Shields you can have active on yourself by 1. You can have Earth Shield on yourself and one ally at the same time.
    elemental_warding           = { 81084, 381650, 2 }, -- Reduces all magic damage taken by 2%.
    enfeeblement                = { 81078, 378079, 1 }, -- Your Hex target is slowed by 70% during Hex and for 6 sec after it ends.
    fire_and_ice                = { 81067, 382886, 1 }, -- Increases all Fire and Frost damage you deal by 3%.
    flurry                      = { 81059, 382888, 1 }, -- Increases your attack speed by 15% for your next 3 melee swings after dealing a critical strike with a spell or ability.
    frost_shock                 = { 81074, 196840, 1 }, -- Chills the target with frost, causing 6,874 Frost damage and reducing the target's movement speed by 50% for 6 sec.
    go_with_the_flow            = { 81089, 381678, 2 }, -- Reduces the cooldown of Spirit Walk by 10 sec. Reduces the cooldown of Gust of Wind by 5 sec.
    graceful_spirit             = { 81065, 192088, 1 }, -- Reduces the cooldown of Spiritwalker's Grace by 30 sec and increases your movement speed by 20% while it is active.
    greater_purge               = { 81076, 378773, 1 }, -- Purges the enemy target, removing 2 beneficial Magic effects.
    guardians_cudgel            = { 81070, 381819, 1 }, -- When Capacitor Totem fades or is destroyed, another Capacitor Totem is automatically dropped in the same place.
    gust_of_wind                = { 81088, 192063, 1 }, -- A gust of wind hurls you forward.
    healing_stream_totem        = { 81100, 5394  , 1 }, -- Summons a totem at your feet for 18 sec that heals an injured party or raid member within 46 yards for 4,196 every 1.6 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    hex                         = { 81079, 51514 , 1 }, -- Transforms the enemy into a frog for 1 min. While hexed, the victim is incapacitated, and cannot attack or cast spells. Damage may cancel the effect. Limit 1. Only works on Humanoids and Beasts.
    lightning_lasso             = { 81096, 305483, 1 }, -- Grips the target in lightning, stunning and dealing 49,599 Nature damage over 5 sec while the target is lassoed. Can move while channeling.
    mana_spring                 = { 81103, 381930, 1 }, -- Your Lava Burst and Riptide casts restore 350 mana to you and 4 allies nearest to you within 40 yards. Allies can only benefit from one Shaman's Mana Spring effect at a time, prioritizing healers.
    natures_fury                = { 81086, 381655, 2 }, -- Increases the critical strike chance of your Nature spells and abilities by 2%.
    natures_guardian            = { 81081, 30884 , 2 }, -- When your health is brought below 35%, you instantly heal for 20% of your maximum health. Cannot occur more than once every 45 sec.
    natures_swiftness           = { 81099, 378081, 1 }, -- Your next healing or damaging Nature spell is instant cast and costs no mana.
    planes_traveler             = { 81056, 381647, 1 }, -- Reduces the cooldown of Astral Shift by 30 sec.
    poison_cleansing_totem      = { 81093, 383013, 1 }, -- Summons a totem at your feet that removes all Poison effects from a nearby party or raid member within 34 yards every 1.5 sec for 9 sec.
    purge                       = { 81076, 370   , 1 }, -- Purges the enemy target, removing 1 beneficial Magic effect.
    spirit_walk                 = { 81088, 58875 , 1 }, -- Removes all movement impairing effects and increases your movement speed by 60% for 8 sec.
    spirit_wolf                 = { 81072, 260878, 1 }, -- While transformed into a Ghost Wolf, you gain 5% increased movement speed and 5% damage reduction every 1 sec, stacking up to 4 times.
    spiritwalkers_aegis         = { 81065, 378077, 1 }, -- When you cast Spiritwalker's Grace, you become immune to Silence and Interrupt effects for 5 sec.
    spiritwalkers_grace         = { 81066, 79206 , 1 }, -- Calls upon the guidance of the spirits for 15 sec, permitting movement while casting Shaman spells. Castable while casting. Increases movement speed by 20%.
    static_charge               = { 81070, 265046, 1 }, -- Reduces the cooldown of Capacitor Totem by 5 sec for each enemy it stuns, up to a maximum reduction of 20 sec.
    stoneskin_totem             = { 81095, 383017, 1 }, -- Summons a totem at your feet for 15 sec that grants 10% physical damage reduction to you and the 4 allies nearest to the totem within 35 yards.
    surging_shields             = { 81092, 382033, 2 }, -- Increases the damage dealt by Lightning Shield by 50%. Increases the healing done by Earth Shield by 12%. Increases the amount of mana recovered when Water Shield is triggered by 25%.
    swirling_currents           = { 81101, 378094, 2 }, -- Increases the healing done by Healing Stream Totem and Cloudburst Totem by 10%.
    thunderous_paws             = { 81072, 378075, 1 }, -- Ghost Wolf removes snares and increases your movement speed by an additional 25% for the first 3 sec. May only occur once every 20 sec.
    thundershock                = { 81096, 378779, 1 }, -- Thunderstorm knocks enemies up instead of away and its cooldown is reduced by 5 sec.
    thunderstorm                = { 81097, 51490 , 1 }, -- Calls down a bolt of lightning, dealing 1,140 Nature damage to all enemies within 10 yards, reducing their movement speed by 40% for 5 sec, and knocking them away from the Shaman. Usable while stunned.
    totemic_focus               = { 81094, 382201, 2 }, -- Increases the radius of your totem effects by 15%. Increases the duration of your Earthbind and Earthgrab Totems by 5 sec. Increases the duration of your Healing Stream, Tremor, Poison Cleansing, Ancestral Protection, Earthen Wall, and Wind Rush Totems by 1.5 sec.
    totemic_projection          = { 81080, 108287, 1 }, -- Relocates your active totems to the specified location.
    totemic_recall              = { 81091, 108285, 1 }, -- Resets the cooldown of your most recently used totem with a base cooldown shorter than 3 minutes.
    totemic_surge               = { 81104, 381867, 2 }, -- Reduces the cooldown of your totems by 3 sec.
    tranquil_air_totem          = { 81095, 383019, 1 }, -- Summons a totem at your feet for 20 sec that prevents cast pushback and reduces the duration of all incoming interrupt effects by 50% for you and the 4 allies nearest to the totem within 35 yards.
    tremor_totem                = { 81069, 8143  , 1 }, -- Summons a totem at your feet that shakes the ground around it for 13 sec, removing Fear, Charm and Sleep effects from party and raid members within 34 yards.
    voodoo_mastery              = { 81078, 204268, 1 }, -- Reduces the cooldown of Hex by 15 sec.
    wind_rush_totem             = { 81082, 192077, 1 }, -- Summons a totem at the target location for 18 sec, continually granting all allies who pass within 11 yards 40% increased movement speed for 5 sec.
    wind_shear                  = { 81068, 57994 , 1 }, -- Disrupts the target's concentration with a burst of wind, interrupting spellcasting and preventing any spell in that school from being cast for 2 sec.
    winds_of_alakir             = { 81087, 382215, 2 }, -- Increases the movement speed bonus of Ghost Wolf by 5%. When you have 3 or more totems active, your movement speed is increased by 7%.

    -- Restoration
    acid_rain                   = { 81039, 378443, 1 }, -- Deal 3,703 Nature damage every 1 sec to up to 6 enemies inside of your Healing Rain.
    ancestral_awakening         = { 81043, 382309, 2 }, -- When you critically heal with your Healing Wave, Healing Surge, or Riptide you summon an Ancestral spirit to aid you, instantly healing the lowest percentage health friendly party or raid target within 40 yards for 10% of the amount healed.
    ancestral_protection_totem  = { 81046, 207399, 1 }, -- Summons a totem at the target location for 33 sec. All allies within 23 yards of the totem gain 10% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with 20% health and mana. Cannot reincarnate an ally who dies to massive damage.
    ancestral_reach             = { 81031, 382732, 1 }, -- Chain Heal bounces an additional time and its healing is increased by 8%.
    ancestral_vigor             = { 81030, 207401, 2 }, -- Targets you heal with Healing Wave, Healing Surge, Chain Heal, or Riptide's initial heal gain 5% increased health for 10 sec.
    ascendance                  = { 81055, 114052, 1 }, -- Transform into a Water Ascendant, duplicating all healing you deal for 15 sec and immediately healing for 65,177. Ascendant healing is distributed evenly among allies within 20 yds.
    chain_heal                  = { 81063, 1064  , 1 }, -- Heals the friendly target for 18,562, then jumps up to 15 yards to heal the 4 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_lightning             = { 81061, 188443, 1 }, -- Hurls a lightning bolt at the enemy, dealing 15,729 Nature damage and then jumping to additional nearby enemies. Affects 3 total targets.
    cloudburst_totem            = { 81048, 157153, 1 }, -- Summons a totem at your feet for 18 sec that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within 46 yards for 36% of all healing done while it was active, divided evenly among targets. Casting this spell a second time recalls the totem and releases the healing.
    continuous_waves            = { 81034, 382046, 1 }, -- Reduces the cooldown of Primordial Wave by 15 sec.
    current_control             = { 92675, 404015, 1 }, -- Reduces the cooldown of Healing Tide Totem by 30 sec.
    deeply_rooted_elements      = { 81051, 378270, 1 }, -- Casting Riptide has a 7% chance to activate Ascendance for 6.0 sec.  Ascendance Transform into a Water Ascendant, duplicating all healing you deal for 15 sec and immediately healing for 65,177. Ascendant healing is distributed evenly among allies within 20 yds.
    deluge                      = { 81028, 200076, 2 }, -- Healing Wave, Healing Surge, and Chain Heal heal for an additional 10% on targets affected by your Healing Rain or Riptide.
    downpour                    = { 80976, 207778, 1 }, -- A burst of water at the target location heals up to six injured allies within 12 yards for 16,926. Cooldown increased by 5 sec for each target effectively healed.
    earthen_harmony             = { 81054, 382020, 2 }, -- Earth Shield reduces damage taken by 3% and its healing is increased by 50% if the target is below 75% health.
    earthen_wall_totem          = { 81046, 198838, 1 }, -- Summons a totem at the target location with 392,300 health for 18 sec. 2,280 damage from each attack against allies within 11.5 yards of the totem is redirected to the totem.
    earthliving_weapon          = { 81049, 382021, 1 }, -- Imbue your weapon with the element of Earth for 1 |4hour:hrs;. Your Riptide, Healing Wave, Healing Surge, and Chain Heal healing a 20% chance to trigger Earthliving on the target, healing for 9,217 over 12 sec.
    echo_of_the_elements        = { 81044, 333919, 1 }, -- Riptide and Lava Burst have an additional charge.
    flash_flood                 = { 81020, 280614, 2 }, -- Consuming Tidal Waves reduces the cast time of your next heal by 10%.
    flow_of_the_tides           = { 81031, 382039, 1 }, -- Chain Heal bounces an additional time and casting Chain Heal on a target affected by Riptide consumes Riptide, increasing the healing of your Chain Heal by 30%.
    healing_rain                = { 81040, 73920 , 1 }, -- Blanket the target area in healing rains, restoring 15,586 health to up to 6 allies over 10 sec.
    healing_stream_totem_2      = { 81022, 5394  , 1 }, -- Summons a totem at your feet for 18 sec that heals an injured party or raid member within 46 yards for 4,196 every 1.6 sec. If you already know Healing Stream Totem, instead gain 1 additional charge of Healing Stream Totem.
    healing_tide_totem          = { 81032, 108280, 1 }, -- Summons a totem at your feet for 10 sec, which pulses every 1.6 sec, healing all party or raid members within 46 yards for 3173.8. Healing increased by 100% when not in a raid.
    healing_wave                = { 81026, 77472 , 1 }, -- An efficient wave of healing energy that restores 26,026 of a friendly target’s health.
    high_tide                   = { 81042, 157154, 1 }, -- Every 100,000 mana you spend brings a High Tide, making your next 2 Chain Heals heal for an additional 10% and not reduce with each jump.
    improved_earthliving_weapon = { 81050, 382315, 2 }, -- Increases the healing of Earthliving by 15%. Earthliving always triggers on targets below 25% health.
    improved_primordial_wave    = { 81035, 382191, 2 }, -- Primordial Wave increases the healing done by your next Healing Wave by 15%.
    improved_purify_spirit      = { 81073, 383016, 1 }, -- Purify Spirit additionally removes all Curse effects.
    lava_burst                  = { 81062, 51505 , 1 }, -- Hurls molten lava at the target, dealing 20,152 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.
    lava_surge                  = { 81017, 77756 , 1 }, -- Your Flame Shock damage over time has a 15% chance to reset the remaining cooldown on Lava Burst and cause your next Lava Burst to be instant.
    living_stream               = { 81048, 382482, 1 }, -- Healing Stream Totem heals for 10% more each time it ticks.
    maelstrom_weapon            = { 81060, 187880, 1 }, -- When you deal damage with a melee weapon, you have a chance to gain Maelstrom Weapon, stacking up to 5 times. Each stack of Maelstrom Weapon reduces the cast time of your next damage or healing spell by 20%. A maximum of 5 stacks of Maelstrom Weapon can be consumed at a time.
    mana_tide_totem             = { 81045, 16191 , 1 }, -- Summons a totem at your feet for 8 sec, granting 100% increased mana regeneration to allies within 23 yards.
    master_of_the_elements      = { 81019, 16166 , 1 }, -- Casting Lava Burst increases the damage or healing of your next Nature or Frost spell by 20%.
    overflowing_shores          = { 92677, 383222, 1 }, -- Healing Rain instantly restores 3,117 health to 6 allies within its area, and its radius is increased by 2 yards.
    primal_tide_core            = { 81042, 382045, 1 }, -- Every 4 casts of Riptide also applies Riptide to another friendly target near your Riptide target.
    primordial_wave             = { 81036, 375982, 1 }, -- Blast your target with a Primordial Wave, dealing 4,605 Shadow damage and apply Flame Shock to an enemy, or heal an ally for 4,836 and apply Riptide to them. Your next Healing Wave will also hit all targets affected by your Riptide for 60% of normal healing.
    refreshing_waters           = { 81019, 378211, 1 }, -- Your Healing Surge is 25% more effective on yourself.
    resonant_waters             = { 92681, 404539, 1 }, -- Increases the duration of Mana Tide Totem by 4 sec and increases its radius by 20 yards.
    resurgence                  = { 81024, 16196 , 1 }, -- Your direct heal criticals refund a percentage of your maximum mana: 1.00% from Healing Wave, 0.60% from Healing Surge or Riptide, and 0.25% from Chain Heal.
    riptide                     = { 81027, 61295 , 1 }, -- Restorative waters wash over a friendly target, healing them for 12,648 and an additional 14,082 over 21 sec.
    spirit_link_totem           = { 81033, 98008 , 1 }, -- Summons a totem at the target location for 6 sec, which reduces damage taken by all party and raid members within 11 yards by 10%. Immediately and every 1 sec, the health of all affected players is redistributed evenly.
    spiritwalkers_tidal_totem   = { 92681, 404522, 1 }, -- After using Mana Tide Totem, the cast time and mana cost of Healing Wave and Chain Heal is reduced by 50% for 10 sec.
    stormkeeper                 = { 81023, 383009, 1 }, -- Charge yourself with lightning, causing your next 2 Lightning Bolts or Chain Lightnings to deal 150% more damage and be instant cast.
    tidal_waves                 = { 81021, 51564 , 1 }, -- Casting Riptide grants 2 stacks of Tidal Waves. Tidal Waves reduces the cast time of your next Healing Wave or Chain Heal by 20%, or increases the critical effect chance of your next Healing Surge by 30%.
    tide_turner                 = { 92675, 404019, 1 }, -- The lowest health target of Healing Tide Totem is healed for 30% more and receives 15% increased healing from you for 4 sec.
    tidebringer                 = { 81041, 236501, 2 }, -- Every 1 sec, the cast time of your next Chain Heal is reduced by 50%, and jump distance increased by 100%. Maximum of 2 charges.
    torrent                     = { 81047, 200072, 2 }, -- Increases the initial heal from Riptide by 10%.
    tumbling_waves              = { 81034, 382040, 1 }, -- Primordial Wave has a 30% chance to not incur its cooldown.
    undercurrent                = { 81052, 382194, 2 }, -- For each Riptide active on an ally, your heals are 0.5% more effective.
    undulation                  = { 81037, 200071, 1 }, -- Every third Healing Wave or Healing Surge heals for an additional 50%.
    unleash_life                = { 81037, 73685 , 1 }, -- Unleash elemental forces of Life, healing a friendly target for 14,136 and increasing the effect of your next healing spell. Riptide, Healing Wave, or Healing Surge: 35% increased healing. Chain Heal: 15% increased healing and bounces to 1 additional target. Healing Rain or Downpour: Affects 2 additional targets. Wellspring: 40% of overhealing done is converted to an absorb effect.
    water_totem_mastery         = { 81018, 382030, 1 }, -- Consuming Tidal Waves reduces the cooldown of your Healing Stream, Cloudburst, Healing Tide, Mana Tide, and Poison Cleansing totems by 0.5 sec.
    wavespeakers_blessing       = { 81038, 381946, 1 }, -- Increases the duration of Riptide by 3 sec.
    wellspring                  = { 81051, 197995, 1 }, -- Creates a surge of water that flows forward, healing friendly targets in a wide arc in front of you for 9,895.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    burrow              = 5576, -- (409293) Burrow beneath the ground, becoming unattackable, removing movement impairing effects, and increasing your movement speed by 50% for 5 sec. When the effect ends, enemies within 6 yards are knocked in the air and take 46,765 Physical damage.
    counterstrike_totem = 708 , -- (204331) Summons a totem at your feet for 15 sec. Whenever enemies within 23 yards of the totem deal direct damage, the totem will deal 100% of the damage dealt back to attacker.
    electrocute         = 714 , -- (206642) When you successfully Purge a beneficial effect, the enemy suffers 4,251 Nature damage over 3 sec.
    grounding_totem     = 715 , -- (204336) Summons a totem at your feet that will redirect all harmful spells cast within 34 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    living_tide         = 5388, -- (353115) Healing Tide Totem's cooldown is reduced by 60 sec and it heals for 25% more each time it pulses.
    rain_dance          = 3755, -- (290250) Healing Rain is now instant, 30% more effective, and costs 45% less mana.
    seasoned_winds      = 5566, -- (355630) Interrupting a spell with Wind Shear decreases your damage taken from that spell school by 15% for 18 sec. Stacks up to 3 times.
    skyfury_totem       = 707 , -- (204330) Summons a totem at your feet for 15 sec that increases the critical effect of damage and healing spells of all nearby allies within 46 yards by 20% for 15 sec.
    static_field_totem  = 5567, -- (355580) Summons a totem with 4% of your health at the target location for 6 sec that forms a circuit of electricity that enemies cannot pass through.
    traveling_storms    = 5528, -- (204403) Thunderstorm now can be cast on allies within 40 yards, reduces enemies movement speed by 60% and knocks enemies 25% further. Thundershock knocks enemies 100% higher.
    unleash_shield      = 5437, -- (356736) Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
} )


-- Auras
spec:RegisterAuras( {
    ascendance = {
        id = 114052,
        duration = 15,
        max_stack = 1,
    },
    earthliving_weapon = {
        id = 382021,
        duration = 3600,
        max_stack = 1
    },
    earthliving_weapon_hot = {
        id = 382024,
        duration = 12,
        max_stack = 1
    },
    -- Your Healing Rain is currently active.  $?$w1!=0[Magic damage taken reduced by $w1%.][]
    -- https://wowhead.com/beta/spell=73920
    healing_rain = {
        id = 73920,
        duration = 10,
        max_stack = 1
    },
    spiritwalkers_tidal_totem = {
        id = 404523,
        duration = 10,
        max_stack = 1
    },
    tidal_waves = {
        id = 53390,
        duration = 15,
        max_stack = 2,
    },
    tide_turner = {
        id = 404072,
        duration = 4,
        max_stack = 1
    },
    tidebringer = {
        id = 236502,
        duration = 3600,
        max_stack = 2
    },
    unleash_life = {
        id = 73685,
        duration = 10,
        max_stack = 1
    },
    water_shield = {
        id = 52127,
        duration = 1800,
        max_stack = 1
    },
} )


-- Tier 30
spec:RegisterGear( "tier30", 202473, 202471, 202470, 202469, 202468 )
spec:RegisterAuras( {
    rainstorm = {
        id = 409386,
        duration = 6,
        max_stack = 40 -- IDK.
    },
    swelling_rain = {
        id = 409391,
        duration = 15,
        max_stack = 40 -- IDK.
    }
} )


spec:RegisterHook( "reset_precast", function ()
    local mh, _, _, mh_enchant = GetWeaponEnchantInfo()

    if mh and mh_enchant == 6498 then applyBuff( "earthliving_weapon" ) end
    if buff.earthliving_weapon.down and ( now - action.earthliving_weapon.lastCast < 1 ) then applyBuff( "earthliving_weapon" ) end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Summons a totem at the target location for 30 sec. All allies within 20 yards of the totem gain 10% increased health. If an ally dies, the totem will be consumed to allow them to Reincarnate with 20% health and mana. Cannot reincarnate an ally who dies to massive damage.
    ancestral_protection_totem = {
        id = 207399,
        cast = 0,
        cooldown = 300,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136080,

        toggle = "defensives",

        handler = function ()
            summonTotem( "ancestral_protection_totem" )
            applyBuff( "ancestral_protection_totem" )
        end,
    },

    -- Transform into a Water Ascendant, duplicating all healing you deal for 15 sec and immediately healing for 58,058. Ascendant healing is distributed evenly among allies within 20 yds.
    ascendance = {
        id = 114052,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 135791,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ascendance" )
        end,
    },

    -- Heals the friendly target for 13,918, then jumps to heal the 3 most injured nearby allies. Healing is reduced by 30% with each jump.
    chain_heal = {
        id = 1064,
        cast = function() return 2.5 * ( buff.spiritwalkers_tidal_totem.up and 0.5 or 1 ) * ( buff.tidebringer.up and 0.5 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.3 * ( buff.spiritwalkers_tidal_totem.up and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136042,

        handler = function ()
            removeStack( "tidal_waves" )
            removeStack( "tidebringer" )
            removeBuff( "swelling_rain" ) -- T30
        end,
    },

    -- Hurls a lightning bolt at the enemy, dealing 9,800 Nature damage and then jumping to additional nearby enemies. Affects 3 total targets.
    chain_lightning = {
        id = 188443,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.natures_swiftness.up and 0 or 0.01 end,
        spendType = "mana",

        talent = "chain_lightning",
        startsCombat = true,
        texture = 136015,

        handler = function ()
            removeBuff( "natures_swiftness" )
        end,
    },

    -- Summons a totem at your feet for 15 sec that collects power from all of your healing spells. When the totem expires or dies, the stored power is released, healing all injured allies within 40 yards for 30% of all healing done while it was active, divided evenly among targets. Casting this spell a second time recalls the totem and releases the healing.
    cloudburst_totem = {
        id = 157153,
        cast = 0,
        charges = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 2 end
        end,
        cooldown = 45,
        recharge = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 45 end
        end,
        hasteCD = true,
        gcd = "totem",

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 971076,

        handler = function ()
            summonTotem( "cloudburst_totem" )
        end,
    },

    -- A burst of water at the target location heals up to six injured allies within 12 yards for 15,077. Cooldown increased by 5 sec for each target effectively healed.
    downpour = {
        id = 207778,
        cast = 1.5,
        cooldown = 5,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 1698701,

        handler = function ()
        end,
    },

    -- Summons a totem at the target location with 309,139 health for 15 sec. 2,164 damage from each attack against allies within 10 yards of the totem is redirected to the totem.
    earthen_wall_totem = {
        id = 198838,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 136098,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "earthen_wall_totem" )
        end,
    },

    -- Imbue your weapon with the element of Earth for 1 |4hour:hrs;. Your Riptide, Healing Wave, Healing Surge, and Chain Heal healing a 20% chance to trigger Earthliving on the target, healing for 7,447 over 12 sec.
    earthliving_weapon = {
        id = 382021,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        startsCombat = false,
        texture = 237578,
        essential = true,
        nobuff = "earthliving_weapon",

        handler = function ()
            applyBuff( "earthliving_weapon" )
        end,
    },

    -- Sears the target with fire, causing 3,099 Fire damage and then an additional 19,919 Fire damage over 18 sec. Flame Shock can be applied to a maximum of 6 targets.
    flame_shock = {
        id = 188389,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135813,

        handler = function ()
            applyDebuff( "target", "flame_shock" )
        end,
    },

    -- Imbue your weapon with the element of Fire for 1 |4hour:hrs;, causing each of your attacks to deal 71 additional Fire damage.
    flametongue_weapon = {
        id = 318038,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135814,

        handler = function ()
            applyBuff( "flametongue_weapon" )
        end,
    },

    -- Chills the target with frost, causing 5,788 Frost damage and reducing the target's movement speed by 50% for 6 sec.
    frost_shock = {
        id = 196840,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "frost_shock",
        startsCombat = false,
        texture = 135849,

        handler = function ()
            applyDebuff( "frost_shock" )
        end,
    },

    -- Purges the enemy target, removing 2 beneficial Magic effects.
    greater_purge = {
        id = 378773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 451166,
        debuff = "dispellable_magic",

        handler = function ()
            removeDebuff( "target", "dispellable_magic" )
        end,
    },

    -- Summons a totem at your feet that will redirect all harmful spells cast within 30 yards on a nearby party or raid member to itself. Will not redirect area of effect spells. Lasts 3 sec.
    grounding_totem = {
        id = 204336,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        pvptalent = "grounding_totem",
        startsCombat = false,
        texture = 136039,

        handler = function ()
            summonTotem( "grounding_totem" )
        end,
    },

    -- Blanket the target area in healing rains, restoring 12,334 health to up to 6 allies over 10 sec.
    healing_rain = {
        id = 73920,
        cast = 2,
        cooldown = 10,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,
        texture = 136037,

        handler = function ()
            if set_bonus.tier30_4pc > 0 and active_dot.riptide > 0 then
                applyBuff( "rainstorm", nil, active_dot.riptide )
                applyBuff( "swelling_rain", nil, active_dot.riptide )
            end
        end,
    },

    -- Talent: Summons a totem at your feet for $d that heals $?s147074[two injured party or raid members][an injured party or raid member] within $52042A1 yards for $52042s1 every $5672t1 sec.    If you already know $?s157153[$@spellname157153][$@spellname5394], instead gain $392915s1 additional $Lcharge:charges; of $?s157153[$@spellname157153][$@spellname5394].
    healing_stream_totem = {
        id = 5394,
        cast = 0,
        charges = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 2 end
        end,
        cooldown = 30,
        recharge = function()
            if talent.healing_stream_totem.rank + talent.healing_stream_totem_2.rank > 1 then return 30 end
        end,
        gcd = "totem",

        spend = 0.09,
        spendType = "mana",

        notalent = "cloudburst_totem",
        startsCombat = false,
        texture = 135127,

        handler = function ()
            summonTotem( "healing_stream_totem" )
        end,
    },

    -- A quick surge of healing energy that restores $s1 of a friendly target's health.
    healing_surge = {
        id = 8004,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.24,
        spendType = "mana",

        startsCombat = false,
        texture = 136044,

        handler = function ()
            removeStack( "tidal_waves" )
            removeBuff( "swelling_rain" ) -- T30

            if talent.earthen_harmony.enabled then
                addStack( "earth_shield", nil, 1 )
            end
        end,
    },

    -- Summons a totem at your feet for 10 sec, which pulses every 1.7 sec, healing all party or raid members within 40 yards for 2827.1. Healing increased by 100% when not in a raid.
    healing_tide_totem = {
        id = 108280,
        cast = 0,
        cooldown = function() return talent.current_control.enabled and 150 or 180 end,
        gcd = "totem",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 538569,

        toggle = "defensives",

        handler = function ()
            summonTotem( "healing_tide_totem" )
        end,
    },

    -- An efficient wave of healing energy that restores 21,075 of a friendly target’s health.
    healing_wave = {
        id = 77472,
        cast = function() return 2.5 * ( buff.spiritwalkers_tidal_totem.up and 0.5 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.15 * ( buff.spiritwalkers_tidal_totem.up and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 136043,

        handler = function ()
            removeStack( "tidal_waves" )
            removeBuff( "swelling_rain" ) -- T30

            if talent.earthen_harmony.enabled then
                addStack( "earth_shield", nil, 1 )
            end
        end,
    },

    -- Hurls molten lava at the target, dealing 16,967 Fire damage. Lava Burst will always critically strike if the target is affected by Flame Shock.
    lava_burst = {
        id = 51505,
        cast = function() return buff.lava_surge.up and 0 or ( 2 * haste ) end,
        charges = function()
            if talent.echo_of_the_elements.enabled then return 2 end
        end,
        cooldown = 8,
        recharge = function()
            if talent.echo_of_the_elements.enabled then return 8 end
        end,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 237582,
        velocity = 30,

        indicator = function()
            return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
        end,

        handler = function ()
            removeBuff( "lava_surge" )
        end,
    },

    -- Hurls a bolt of lightning at the target, dealing 10,473 Nature damage.
    lightning_bolt = {
        id = 188196,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136048,

        handler = function ()
        end,
    },

    -- Summons a totem at your feet for 8 sec, granting 100% increased mana regeneration to allies within 20 yards.
    mana_tide_totem = {
        id = 16191,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        startsCombat = false,
        texture = 4667424,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "mana_tide_totem" )
            if talent.spiritwalkers_tidal_totem.enabled then applyBuff( "spiritwalkers_tidal_totem" ) end
        end,
    },

    -- Talent: Summons a totem at your feet that removes $383015s1 poison effect from a nearby party or raid member within $383015a yards every $383014t1 sec for $d.
    poison_cleansing_totem = {
        id = 383013,
        cast = 0,
        cooldown = function () return 45 - 3 * talent.totemic_surge.rank end,
        gcd = "totem",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136070,

        handler = function ()
            summonTotem( "poison_cleansing_totem" )
        end,
    },

    -- Blast your target with a Primordial Wave, dealing 4,265 Shadow damage and apply Flame Shock to an enemy, or heal an ally for 4,308 and apply Riptide to them. Your next Healing Wave will also hit all targets affected by your Riptide for 60% of normal healing.
    primordial_wave = {
        id = 375982,
        cast = 0,
        cooldown = function() return talent.continuous_waves.enabled and 30 or 45 end,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 3578231,

        handler = function ()
            applyBuff("riptide")
            applyDebuff("flame_shock")
        end,
    },

    -- Restorative waters wash over a friendly target, healing them for 13,520 and an additional 10,502 over 18 sec.
    riptide = {
        id = 61295,
        cast = 0,
        charges = 2,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,
        texture = 252995,

        handler = function ()
            applyBuff( "riptide" )
            if talent.tidal_waves.enabled then
                addStack( "tidal_waves", nil, 2 )
            end
        end,
    },

    -- Summons a totem at the target location for 6 sec, which reduces damage taken by all party and raid members within 10 yards by 10%. Immediately and every 1 sec, the health of all affected players is redistributed evenly.
    spirit_link_totem = {
        id = 98008,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "totem",

        spend = 0.11,
        spendType = "mana",

        startsCombat = false,
        texture = 237586,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "spirit_link_totem" )
        end,
    },

    -- Charge yourself with lightning, causing your next 2 Lightning Bolts or Chain Lightnings to deal 150% more damage and be instant cast.
    stormkeeper = {
        id = 383009,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",

        startsCombat = false,
        texture = 839977,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "stormkeeper" )
        end,
    },

    -- Unleash elemental forces of Life, healing a friendly target for 12,592 and increasing the effect of your next healing spell. Riptide, Healing Wave, or Healing Surge: 35% increased healing. Chain Heal: 15% increased healing and bounces to 1 additional target. Healing Rain or Downpour: 2 additional allies healed. Wellspring: 25% of overhealing done is converted to an absorb effect.
    unleash_life = {
        id = 73685,
        cast = 0,
        charges = 1,
        cooldown = 15,
        recharge = 15,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 462328,

        handler = function ()
            applyBuff( "unleash_life" )
        end,
    },

    -- Unleash your Elemental Shield's energy on an enemy target: Lightning Shield: Knocks them away. Earth Shield: Roots them in place for 2 sec. Water Shield: Summons a whirlpool for 6 sec, reducing damage and healing by 50% while they stand within it.
    unleash_shield = {
        id = 356736,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 538567,

        handler = function ()
        end,
    },

    -- The caster is surrounded by globes of water, granting 238 mana per 5 sec. When a melee attack hits the caster, the caster regains 2% of their mana. This effect can only occur once every few seconds. Only one of your Elemental Shields can be active on you at once.
    water_shield = {
        id = 52127,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132315,
        essential = true,
        nobuff = "water_shield",

        handler = function ()
            applyBuff( "water_shield" )
        end,
    },

    -- Creates a surge of water that flows forward, healing friendly targets in a wide arc in front of you for 12,592.
    wellspring = {
        id = 197995,
        cast = 1.5,
        cooldown = 20,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = false,
        texture = 893778,

        handler = function ()
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 25,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Restoration Shaman",
} )


spec:RegisterPack( "Restoration Shaman", 20230321.1, [[Hekili:nBvuVTTnq4FlbdWjbjvZYo1PDijaDBp0emumu1NLiT0jBctjQrrfVayWF77ivSejJDsXEP9Lw57U8DF3X7(itJt)wAsbvbPFz20zZNoFwCu81ZIN((0e1tnqAsdnFdDf(rnTc)3VcTkHKQyIAnjznTIwBI5jUGwyWQv0jZX4stw2X4Q7RtxgMamOgih)9IRstwZkkG(GG280etqVB683nl(30en5tffAYNbkNvVst(kLHz9SpLZk6)X5AcTg)ob5u1gaAaPMOeAYF(3jAsJKjKm1tridLIsgh5fn3q92OgjKlQwsvxC7VcuPAnN9iMJSTaTblThouCBXYqM1UMb8IlzL3USRSmY1yuxZfwJwednYzRwRQnjzWXnXxOOCOwfbCOc)FkptixYursA9MdZIqy(XXexS)rZIH4pCqnc7e7ddErBTnmC6ylLVbKTzRK0C4YkHzk42yt5GFBXmQG1QO15WDl0p8lAY91yfk7AuAIOutYPTQ2ixG3YQlWAcjMR19uy0sxlKXuqvRRXLCHOiRSt(KNvKIGCJzlWXAjtc24DnAyARsIDUCkN7bcDvMOmtjz5B8Y56(fSmjUszQ8t6BdtE(SGI7BwFEDpNvoxkXrzcS4f5BUm)PCoKPOYvGQTVNAc8ridQHkg0EZ8jsOucTRPl5GxZsYQeYcgwfBPp65ItFKMTSt2QmaEMpI3gVBxGLzt6N2m)zTDixW5SZNuiuroCnscvyb2EN50mtXQGj5cbVqSTotciIUm4ytCElNlfClbrTooFFtikFnMLSHOUz2UDN8CxoWLlQbUEtyVl(yhj7NV98lfyn77pn5rCIddWv2ElvAqVnn5BRbnHv1iK4sqPafDpTakPDC1PAIe(NoCWeLLBfvyC0oLOcvfqdipRxbMTL)IvJUINIQ8)HOgtM1)PHtCN2lN)c7rqTzKPa9Fw8)E(iGlomGbnOayd8(sW1pCVTynqodRO8(7)4S(v)0e7x27s7Bd4NFXE3AFd18JKEuZE2YVV)UiZ1HVqiknjhnbsg1cHVoKMCNMSypGfiuk8yYKTrl2RtLSM(mCqjRrcmkyzqAUbP9U6vTcY1vUrmOIfe07DdAuvliQfErnOYfe11UrnO6fe0hCdYxfmiYp6LuxvXGaJNg0vhpvort6pj1Kj400rMphtJRgRf6yxs4OMgsHWd2H2W4ATlV8v)0KB0K5wk6O0IX7knBMonzY)G3xboKvxD0gZz97hUC4wCXut2T7GEMzz3l1O1KZTEoIsTDjyqT2gPVI9yPmEJHL6EdMbA5HL5IJwMVQaSTTpRVKpzy64iYmoe172dlbU()lbWUt8iYbUTq)HVx9jVjn)(Zh)UXy8sgFmuMrTNFO2GQP3PJ3lZFdvVX2ZHEmQMCXZtAbpiD0XbEuQ9Wm2gYR84uh1uNKoON(tghdHyqv)NmE6I9lUu513Dx8wxJzN9WhNSwGAUFg2W4mRT0)7]] )