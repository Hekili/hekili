if UnitClassBase( 'player' ) ~= 'ROGUE' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 4 )

local strformat = string.format
local UA_GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

local tracked_bleeds = {}
-- TODO:  Check gains from Cold Blood, Seal Fate; i.e., guaranteed crits.

spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

spec:RegisterGear( "tier11",  60300, 60299, 60298, 60301, 65239, 65240, 65241, 65242, 65243 )
spec:RegisterGear( "tier13",  77023, 77024, 77025, 77026, 77027 )

-- Talents
spec:RegisterTalents( {
    adrenaline_rush             = {   205, 1, 13750 },
    aggression                  = {  1122, 3, 18427, 18428, 18429 },
    ambidexterity               = {  5686, 1, 13852 },
    bandits_guile               = {  11174, 3, 84652, 84653, 84654 },
    blackjack                   = {  6515, 2, 79123, 79125 },
    blade_flurry                = {  5170, 1, 13877 },
    blade_twisting              = {  1706, 2, 31124, 31126 },
    cheat_death                 = {  1722, 3, 31228, 31229, 31230 },
    cold_blood                  = {  280,  1, 14177 },
    combat_potency              = {  1825, 3, 35541, 35550, 35551 },
    coup_de_grace               = {  276,  3, 14162, 14163, 14164 },
    cut_to_the_chase            = {  2070, 3, 51664, 51665, 51667 },
    deadened_nerves             = {  1723, 3, 31380, 31382, 31383 },
    deadliness                  = {  1702, 5, 30902, 30903, 30904, 30905, 30906 },
    deadly_brew                 = {  2065, 2, 51625, 51626 },
    deadly_momentum             = {  6514, 2, 79121, 79122 },
    deflection                  = {  5690, 3, 13713, 13853, 13854 },
    dirty_deeds                 = {  5654, 2, 14082, 14083 },
    elusiveness                 = {  247,  2, 13981, 14066 },
    energetic_recovery          = {  11665, 3, 79150, 79151, 79152 },
    enveloping_shadows          = {  1711, 3, 31211, 31212, 31213 },
    filthy_tricks               = {  2079, 2, 58414, 58415 },
    find_weakness               = {  6519, 2, 51632, 91023 },
    heightened_senses           = {  1701, 2, 30894, 30895 },
    hemorrhage                  = {  681,  1, 16511 },
    honor_among_thieves         = {  2078, 3, 51698, 51700, 51701 },
    improved_ambush             = {  261,  3, 14079, 14080, 84661 },
    improved_expose_armor       = {  278,  2, 14168, 14169 },
    improved_gouge              = {  203,  2, 13741, 13793 },
    improved_kick               = {  206,  2, 13754, 13867 },
    improved_poisons            = {  5758, 5, 14113, 14114, 14115, 14116, 14117 },
    improved_recuperate         = {  6395, 2, 79007, 79008 },
    improved_sinister_strike    = {  201,  3, 13732, 13863, 79004 },
    improved_slice_and_dice     = {  1827, 2, 14165, 14166 },
    improved_sprint             = {  222,  2, 13743, 13875 },
    initiative                  = {  245,  2, 13976, 13979 },
    killing_spree               = {  2076, 1, 51690 },
    lethality                   = {  269,  3, 14128, 14132, 14135 },
    lightning_reflexes          = {  186,  3, 13712, 13788, 13789 },
    malice                      = {  5742, 5, 14138, 14139, 14140, 14141, 14142 },
    master_of_subtlety          = {  10054,1, 31223 },
    master_poisoner             = {  1715, 1, 58410 },
    murderous_intent            = {  6516, 2, 14158, 14159 },
    mutilate                    = {  1719, 1, 1329 },
    nerves_of_steel             = {  5722, 2, 31130, 31131 },
    nightstalker                = {  244,  2, 13975, 14062 },
    opportunity                 = {  261,  3, 14057, 14072, 79141 },
    overkill                    = {  281,  1, 58426 },
    precision                   = {  181,  3, 13705, 13832, 13843 },
    premeditation               = {  381,  1, 14183 },
    preparation                 = {  284,  1, 14185 },
    prey_on_the_weak            = {  5734, 5, 51685, 51686, 51687, 51688, 51689 },
    puncturing_wounds           = {  5748, 3, 13733, 13865, 13866 },
    quickening                  = {  5760, 2, 31208, 31209 },
    reinforced_leather          = {  6511, 2, 79077, 79079 },
    relentless_strikes          = {  2244, 3, 14179, 58422, 58423 },
    remorseless_attacks         = {  272,  2, 14144, 14148 },
    restless_blades             = {  5740, 2, 79095, 79096 },
    revealing_strike            = {  11171,1, 84617 },
    riposte                     = {  5696, 1, 14251 },
    ruthlessness                = {  1744, 3, 14156, 14160, 14161 },
    sanguinary_vein             = {  10074,2, 79146, 79147 },
    savage_combat               = {  10898,2, 51682, 58413 },
    seal_fate                   = {  283,  2, 14186, 14190 },
    serrated_blades             = {  1123, 2, 14171, 14172 },
    setup                       = {  5644, 3, 13983, 14070, 14071 },
    shadow_dance                = {  5680, 1, 51713 },
    shadowstep                  = {  10072, 1, 36554 },
    sinister_calling            = {  1712, 1, 31220 },
    slaughter_from_the_shadows  = {  2080, 3, 51708, 51709, 51710 },
    surprise_attacks            = {  5730, 1, 32601 },
    throwing_specialization     = {  9944, 2, 5952, 51679 },
    unfair_advantage            = {  2073, 2, 51672, 51674 },
    vendetta                    = {  2071, 1, 79140 },
    venomous_wounds             = {  6517, 2, 79133, 79134 },
    vile_poisons                = {  5756, 3, 16513, 16514, 16515 },
    vitality                    = {  1705, 1, 61329 },
    waylay                      = {  2077, 2, 51692, 51696 },
} )

-- Glyphs
spec:RegisterGlyphs( {
    [56808] = "adrenaline_rush",
    [56813] = "ambush",
    [56800] = "backstab",
    [56818] = "blade_flurry",
    [91299] = "blind",
    [58039] = "blurred_speed",
    [63269] = "cloak_of_shadows",
    [56820] = "crippling_poison",
    [56806] = "deadly_throw",
    [58032] = "distract",
    [56799] = "evasion",
    [56802] = "eviscerate",
    [56803] = "expose_armor",
    [63254] = "fan_of_knives",
    [56804] = "feint",
    [56812] = "garrote",
    [56809] = "gouge",
    [56807] = "hemorrhage",
    [56805] = "kick",
    [63252] = "killing_spree",
    [63268] = "mutilate",
    [58027] = "pick_lock",
    [58017] = "pick_pocket",
    [58038] = "poisons",
    [56819] = "preparation",
    [56814] = "revealing_strike",
    [56801] = "rupture",
    [58033] = "safe_fall",
    [56798] = "sap",
    [63253] = "shadow_dance",
    [56821] = "sinister_strike",
    [56810] = "slice_and_dice",
    [56811] = "sprint",
    [63256] = "tricks_of_the_trade",
    [89758] = "vanish",
    [63249] = "vendetta",
} )


-- Auras
spec:RegisterAuras({
    -- Energy regeneration increased by $s1%.
    adrenaline_rush = {
        id = 13750,
        duration = function() return glyph.adrenaline_rush.enabled and 20 or 15 end,
        max_stack = 1,
    },
    backstab = {
        id = 53,
        duration = 15,
        max_stack = 1,
    },
    -- Weapon attacks strike an additional nearby opponent.
    blade_flurry = {
        id = 13877,
        duration = 3600,
        max_stack = 1,
        texture = 236319,
    },
    -- Dazed.
    blade_twisting = {
        id = 31124,
        duration = 8,
        max_stack = 1,
        copy = { 31124, 31126 },
    },
    -- Disoriented.
    blind = {
        id = 2094,
        duration = 10,
        max_stack = 1,
    },
    -- Stunned.
    cheap_shot = {
        id = 1833,
        duration = 4,
        max_stack = 1,
    },
    cheating_death = {
        id = 45182,
        duration = 3,
        max_stack = 1,
    },
    -- Increases chance to resist spells by $s1%.
    cloak_of_shadows = {
        id = 31224,
        duration = 5,
        max_stack = 1,
    },
    -- Critical strike chance of your next offensive ability increased by $s1%.
    cold_blood = {
        id = 14177,
        duration = 3600,
        max_stack = 1,
    },
    deadly_poison = {
        id = 2818,
        duration = 12,
        max_stack = 5,
        copy = { 2819, 11353, 11354, 25349, 26968, 27187, 57970, 57969 },
    },
    deadly_poison_dot = {
        id = 2818,
        duration = function () return 12 * haste end,
        tick_time = 3,
        max_stack = 5,
        copy = { 2818, 11353, 11354, 25349, 26968, 27187, 57970, 57969 },
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.deadly_poison_dot.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod 
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
        },
    },
    -- Movement slowed by $s2%.
    deadly_throw = {
        id = 48674,
        duration = 6,
        max_stack = 1,
        copy = { 26679, 48673, 48674 },
    },
    -- Detecting traps.
    detect_traps = {
        id = 2836,
        duration = 3600,
        max_stack = 1,
    },
    -- Disarmed.
    dismantle = {
        id = 51722,
        duration = 10,
        max_stack = 1,
    },
    -- Chance to apply Deadly Poison increased by $s3% and frequency of applying Instant Poison increased by $s2%.
    envenom = {
        id = 57993,
        duration = 1,
        max_stack = 1,
        copy = { 32645, 32684, 57992, 57993 },
    },
    -- Dodge chance increased by $s1% and chance ranged attacks hit you reduced by $s2%.
    evasion = {
        id = 26669,
        duration = function() return glyph.evasion.enabled and 20 or 15 end,
        max_stack = 1,
        copy = { 5277, 26669, 67354, 67378, 67380 },
    },
    fury_of_the_destroyer = {
        id = 109950,
        duration = 6,  
        max_stack = 1, 
    
    },
    -- $s2% reduced damage taken from area of effect attacks.
    feint = {
        id = 48659,
        duration = 6,
        max_stack = 1,
        copy = { 48659 },
    },
    -- $s1 damage every $t1 seconds.
    garrote = {
        id = 48676,
        duration = function() return glyph.garrote.enabled and 21 or 18 end,
        tick_time = 3,
        max_stack = 1,
        copy = { 703, 8631, 8632, 8633, 8818, 11289, 11290, 26839, 26884, 48675, 48676 },
    },
    -- Silenced.
    garrote_silence = {
        id = 1330,
        duration = 3,
        max_stack = 1,
    },
    -- Dodge chance increased by $s2%.
    ghostly_strike = {
        id = 14278,
        duration = function() return glyph.ghostly_strike.enabled and 11 or 7 end,
        max_stack = 1,
    },
    -- Glyph of Hemorrhage
    glyph_of_hemorrhage = {
        id = 89775,
        duration = 24,
        max_stack = 1,
    },
    -- Incapacitated.
    gouge = {
        id = 1776,
        duration = function() return 4 + 2 * talent.improved_gouge.rank end,
        max_stack = 1,
    },
    -- Increases damage taken by $s3.
    hemorrhage = {
        id = 16511,
        duration = 15,
        max_stack = 1,
        copy = { 16511, 17347, 17348, 26864, 48660 },
    },
    -- Stunned.
    kidney_shot = {
        id = 8643,
        duration = 1,
        max_stack = 1,
        copy = { 408, 8643, 27615, 30621 },
    },
    -- Attacking an enemy every $t1 sec.  Damage dealt increased by $61851s3%.
    killing_spree = {
        id = 51690,
        duration = 2,
        tick_time = 0.5,
        max_stack = 1,
    },
    master_of_subtlety = {
        id = 31665,
        duration = 6,
        max_stack = 1,
    },
    overkill = {
        id = 58427,
        duration = 20,
        max_stack = 1,
    },
    recuperate = {
        id = 73651,
        max_stack = 1,
        tick_time = 3,
        copy = { 79007 },
    },
    -- Critical strike chance for your next Sinister Strike, Backstab, Mutilate, Ambush, Hemorrhage, or Ghostly strike increased by $s1%.
    remorseless = {
        id = 14149,
        duration = 20,
        max_stack = 1,
        copy = { 14143, 14149 },
    },
    -- Restless Blades logic
    restless_blades = {
        id = 79096,
        max_stack = 1,
    },

    -- Melee attack speed slowed by $s2%.
    riposte = {
        id = 14251,
        duration = 30,
        max_stack = 1,
    },
    -- Causes damage every $t1 seconds.
    rupture = {
        id = 1943,
        duration = function() return ( glyph.rupture.enabled and 10 or 6 ) + ( 1 + effective_combo_points ) end,
        tick_time = 2,
        max_stack = 1,
        meta = {
            last_tick = function( t ) return t.up and ( tracked_bleeds.rupture.last_tick[ target.unit ] or t.applied ) or 0 end,
            tick_time = function( t )
                if t.down then return haste * 2 end
                local hasteMod = tracked_bleeds.rupture.haste[ target.unit ]
                hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                return hasteMod 
            end,
            haste_pct = function( t ) return ( 100 / haste ) end,
            haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.rupture.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
            copy = { 1943, 8639, 8640, 11273, 11274, 11275, 26867, 48671, 48672 },
        },
    },
    bandits_guile = {
        id = 84654,
        max_stack = 1,
    },
    -- Sapped.
    sap = {
        id = 51724,
        duration = function() return glyph.sap.enabled and 80 or 60 end,
        max_stack = 1,
        copy = { 2070, 6770, 11297, 51724 },
    },
    -- Increases physical damage taken by $s1%.
    savage_combat = {
        id = 58684,
        duration = 3600,
        max_stack = 1,
        copy = { 58683, 58684 },
    },
    -- Can use opening abilities without being stealthed.
    shadow_dance = {
        id = 51713,
        duration = function() return glyph.sap.enabled and 8 or 6 end,
        max_stack = 1,
    },
    shadowstep = {
        id = 36563,
        duration = 10,
        max_stack = 1,
    },
    shadowstep_sprint = {
        id = 36554,
        duration = 3,
        max_stack = 1,
    },
    shallow_insight = {
        id = 84745,
        duration = 15,
        max_stack = 1,
    },
    -- Silenced.
    silenced_improved_kick = {
        id = 18425,
        duration = 2,
        max_stack = 1,
    },
    sinister_strike = {
        id = 1752,
        duration = 15,
        max_stack = 1,
    },
    -- Melee attack speed increased by $s2%.
    slice_and_dice = {
        id = 6774,
        duration = function() return ( ( glyph.slice_and_dice.enabled and 12 or 6  ) + ( 3 * combo_points.current ) ) * ( 1 + 0.25 * talent.improved_slice_and_dice.rank ) end,
        max_stack = 1,
        copy = { 5171, 6434, 6774, 60847 },
    },
    -- Movement speed increased by $w1%.
    sprint = {
        id = 11305,
        duration = 15,
        max_stack = 1,
        copy = { 2983, 8696, 11305, 48594, 56354 },
    },
    -- Stealthed.  Movement slowed by $s3%.
    stealth = {
        id = 1784,
        duration = 3600,
        max_stack = 1,
    },
    smoke_bomb = {
        id = 76577,
        duration = 5,
        max_stack = 1,
    },
    -- $s1% increased critical strike chance with combo moves.
    turn_the_tables = {
        id = 52915,
        duration = 8,
        max_stack = 1,
        copy = { 52915, 52914, 52910 },
    },
    vanish = {
        id = 11327,
        duration = 10,
        max_stack = 1,
    },

    vendetta = {
        id = 79140,
        duration = 30,
        max_stack = 1,
    },
    -- Time between melee and ranged attacks increased by $s1%.    Movement speed reduced by $s2%.
    waylay = {
        id = 51693,
        duration = 8,
        max_stack = 1,
    },
    -- $s1 damage every $t sec
    lacerate = {
        id = 48568,
        duration = 15,
        tick_time = 3,
        max_stack = 5,
        copy = { 33745, 48567, 48568 },
    },
    -- Bleeding for $s1 damage every $t1 seconds.
    pounce_bleed = {
        id = 9007,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
        copy = { 9007, 9824, 9826, 27007, 49804 },
    },
    -- Bleeding for $s2 damage every $t2 seconds.
    rake = {
        id = 1822,
        duration = function() return 9 + ( set_bonus.tier9_2pc == 1 and 3 or 0) end,
        max_stack = 1,
        copy = { 1822, 1823, 1824, 9904, 27003, 48573, 48574, 59881, 59882, 59883, 59884, 59885, 59886 },
    },
    -- redirect
    redirect = {
        id = 73981,
        max_stack = 1,
    },
    rend = {
        id = 47465,
        duration = 15,
        max_stack = 1,
        shared = "target",
        copy = { 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208 }
    },
    -- Revealing Strike logic
    revealing_strike = {
        id = 84617,
        duration = 15,
        max_stack = 1,
    },
    -- Bleed damage every $t1 seconds.
    rip = {
        id = 1079,
        duration = function() return 16 + ( set_bonus.tier7_2pc == 1 and 4 or 0 ) end,
        tick_time = 2,
        max_stack = 1,
        copy = { 1079, 9492, 9493, 9752, 9894, 9896, 27008, 49799, 49800 },
    },
    tricks_of_the_trade = {
        id = 57934,
        duration = 20,
        max_stack = 1
    },
    tricks_of_the_trade_rogue = {
        id = 59628,
        duration = 6,
        max_stack = 1
    },
    tricks_of_the_trade_threat = {
        id = 396937,
        duration = 6,
        max_stack = 1,
        dot = "buff",
    },

    -- Bleeding for $s1 damage every $t1 seconds.
    deep_wound = {
        id = 43104,
        duration = 12,
        max_stack = 1,
        shared = "target"
    },
    deep_insight = {
        id = 84747,
        duration = 15,
        max_stack = 1,
    },
    bleed = {
        alias = { "lacerate", "pounce_bleed", "rip", "rake", "deep_wound", "rend", "garrote", "rupture" },
        aliasType = "debuff",
        aliasMode = "longest"
    }
})

spec:RegisterStateExpr( "envenom_pool_deficit", function ()
    return energy.max * ( ( 100 - ( settings.envenom_pool_pct or 100 ) ) / 100 )
end )

spec:RegisterStateExpr( "pmultiplier", function ()
    if not this_action then return 0 end

    local a = class.abilities[ this_action ]
    if not a then return 0 end

    local aura = a.aura or this_action
    if not aura then return 0 end

    if debuff[ aura ] and debuff[ aura ].up then
        return debuff[ aura ].pmultiplier or 1
    end

    return 0
end )

-- Bleed Modifiers

local function NewBleed( key, spellID )
    tracked_bleeds[ key ] = {
        id = spellID,
        rate = {},
        last_tick = {},
        haste = {}
    }

    tracked_bleeds[ spellID ] = tracked_bleeds[ key ]
end

local function ApplyBleed( key, target )
    local bleed = tracked_bleeds[ key ]
    bleed.haste[ target ]        = 100 + GetHaste()
end

local function UpdateBleed( key, target )
    local bleed = tracked_bleeds[ key ]

    if not bleed.rate[ target ] then
        return
    end


    bleed.haste[ target ] = 100 + GetHaste()
end

local function UpdateBleedTick( key, target, time )
    local bleed = tracked_bleeds[ key ]

    if not bleed.rate[ target ] then return end

    bleed.last_tick[ target ] = time or GetTime()
end

local function RemoveBleed( key, target )
    local bleed = tracked_bleeds[ key ]

    bleed.rate[ target ]         = nil
    bleed.last_tick[ target ]    = nil
    bleed.haste[ target ]        = nil
end


NewBleed( "garrote", 703 )
NewBleed( "rupture", 1943 )
NewBleed( "deadly_poison_dot", 2823 )
local tick_events = {
    SPELL_PERIODIC_DAMAGE   = true,
}

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local application_events = {
    SPELL_AURA_APPLIED      = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REFRESH      = true,
}

local removal_events = {
    SPELL_AURA_REMOVED      = true,
    SPELL_AURA_BROKEN       = true,
    SPELL_AURA_BROKEN_SPELL = true,
}

local stealth_spells = {
    [1784] = true,
    [1856] = true,
}
local function isStealthed()
    return ( UA_GetPlayerAuraBySpellID( 1784 ) or UA_GetPlayerAuraBySpellID( 1856 )  or GetTime() - stealth_dropped < 0.2 )
end

local calculate_multiplier = setfenv( function( spellID )
    local mult = 1

    if talent.nightstalker.enabled and isStealthed() then
        mult = mult * 1.08
    end


    return mult
end, state )



spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        if removal_events[ subtype ] then
            if stealth_spells[ spellID ] then
                stealth_dropped = GetTime()
                return
            end
        end

        if tracked_bleeds[ spellID ] then
            if application_events[ subtype ] then
                -- TODO:  Modernize basic debuff tracking and snapshotting.
                ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                ns.trackDebuff( spellID, destGUID, GetTime(), true )

                ApplyBleed( spellID, destGUID )
                return
            end

            if tick_events[ subtype ] then
                UpdateBleedTick( spellID, destGUID, GetTime() )
                return
            end

            if removal_events[ subtype ] then
                RemoveBleed( spellID, destGUID )
                return
            end
        end
    end
end )
local energySpent = 0

local ENERGY = Enum.PowerType.Energy
local lastEnergy = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "ENERGY" then
        local current = UnitPower( "player", ENERGY )

        if current < lastEnergy then
            energySpent = ( energySpent + lastEnergy - current ) % 30
        end

        lastEnergy = current
        return
    elseif powerType == "COMBO_POINTS" then
        Hekili:ForceUpdate( powerType, true )
    end
end )
spec:RegisterStateExpr( "energy_spent", function ()
    return energySpent
end )
-- Enemies with either Deadly Poison or Wound Poison applied.
spec:RegisterStateExpr( "poisoned_enemies", function ()
    return ns.countUnitsWithDebuffs( "deadly_poison_dot", "wound_poison_dot", "crippling_poison_dot", "amplifying_poison_dot" )
end )
-- Count of bleeds on targets.
spec:RegisterStateExpr( "bleeds", function ()
    local n = 0

    for _, aura in pairs( valid_bleeds ) do
        if debuff[ aura ].up then
            n = n + 1
        end
    end

    return n
end )
-- Count of bleeds on all poisoned (Deadly/Wound) targets.
spec:RegisterStateExpr( "poisoned_bleeds", function ()
    return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "amplifying_poison_dot", "garrote", "rupture" )
end )

spec:RegisterStateExpr( "cp_max_spend", function ()
    return combo_points.max
end )

local stealth = {
    rogue   = { "stealth", "vanish", "shadow_dance" },
    mantle  = { "stealth", "vanish" },
    all     = { "stealth", "vanish", "shadow_dance", "shadowmeld" }
}

local enchant_ids = {
    [7] = "deadly",
    [8] = "deadly",
    [626] = "deadly",
    [627] = "deadly",
    [3771] = "deadly",
    [2630] = "deadly",
    [2642] = "deadly",
    [2643] = "deadly",
    [3770] = "deadly",
    [323] = "instant",
    [324] = "instant",
    [325] = "instant",
    [623] = "instant",
    [3769] = "instant",
    [624] = "instant",
    [625] = "instant",
    [2641] = "instant",
    [3768] = "instant",
    [2640] = "anesthetic",
    [3774] = "anesthetic",
    [703] = "wound",
    [704] = "wound",
    [705] = "wound",
    [706] = "wound",
    [2644] = "wound",
    [3772] = "wound",
    [3773] = "wound",
    [35] = "mind",
    [22] = "crippling",
}


spec:RegisterStateTable( "stealthed", setmetatable( {}, {
    __index = function( t, k )
        if k == "rogue" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up
        elseif k == "rogue_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains )

        elseif k == "mantle" then
            return buff.stealth.up or buff.vanish.up
        elseif k == "mantle_remains" then
            return max( buff.stealth.remains, buff.vanish.remains )

        elseif k == "all" then
            return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.shadowmeld.up
        elseif k == "remains" or k == "all_remains" then
            return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.shadowmeld.remains )
        end

        return false
    end
} ) )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "combo_points" and amt * talent.relentless_strikes.rank * 4 >= 100 then
        gain( 25, "energy" )
    end
end )


-- We need to break stealth when we start combat from an ability.
spec:RegisterHook( "runHandler", function( action )
    local a = class.abilities[ action ]

    if stealthed.all and ( not a or a.startsCombat ) then
        if buff.stealth.up then
            setCooldown( "stealth", 10 )
            if talent.master_of_subtlety.enabled then applyBuff( "master_of_subtlety", 6 ) end
            if talent.overkill.enabled then applyBuff( "overkill", 20 ) end
        end

        removeBuff( "stealth" )
        removeBuff( "shadowmeld" )
        removeBuff( "vanish" )
    end

    if ( not a or a.startsCombat ) then
        if buff.cold_blood.up then removeBuff( "cold_blood" ) end
        if buff.shadowstep.up then removeBuff( "shadowstep" ) end
    end
    
end )


spec:RegisterHook( "reset_precast", function()
    if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end

    -- local mh, mh_expires, _, mh_id, oh, oh_expires, _, oh_id = GetWeaponEnchantInfo()

end )


-- Abilities
spec:RegisterAbilities( {
    -- Increases your Energy regeneration rate by 100% for 15 sec.
    adrenaline_rush = {
        id = 13750,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        talent = "adrenaline_rush",
        startsCombat = false,
        texture = 136206,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "adrenaline_rush" )
            energy.regen = energy.regen * 2
        end,
    },


    -- Ambush the target, causing 275% weapon damage plus 509 to the target.  Must be stealthed and behind the target.  Requires a dagger in the main hand.  Awards 2 combo points.
    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 60 - 4 * talent.slaughter_from_the_shadows.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132282,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            -- TODO: Use fail positioning from Burning Crusade.
            gain( talent.initiative.rank == 3 and 3 or 2, "combo_points" )
            removeBuff( "remorseless" )
            if talent.waylay.rank == 2 then applyDebuff( "target", "waylay" ) end
        end,

        copy = { 8676, 8724, 8725, 11267, 11268, 11269, 27441, 48689, 48690, 48691 },
    },


    -- Backstab the target, causing 150% weapon damage plus 255 to the target.  Must be behind the target.  Requires a dagger in the main hand.  Awards 1 combo point.
    backstab = {
        id = 53,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 60 - 4 * talent.slaughter_from_the_shadows.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132090,


        handler = function ()

            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
            if talent.waylay.rank == 2 then applyDebuff( "target", "waylay" ) end
        end,

        copy = { 53, 2589, 2590, 2591, 8721, 11279, 11280, 11281, 25300, 26863, 48656, 48657 },
    },


    -- Increases your attack speed by 20%.  In addition, attacks strike an additional nearby opponent.  Lasts 15 sec.
    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        spend = function() return glyph.blade_flurry.enabled and 0 or 25 end,
        spendType = "energy",

        talent = "blade_flurry",
        startsCombat = false,
        texture = 132350,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "blade_flurry" )
        end,
    },


    -- Blinds the target, causing it to wander disoriented for up to 10 sec.  Any damage caused will remove the effect.
    blind = {
        id = 2094,
        cast = 0,
        cooldown = function() return 180 - 30 * talent.elusiveness.rank end,
        gcd = "totem",

        spend = function() return 30 * ( 1 - 0.25 * talent.dirty_tricks.rank ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 136175,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "blind" )
        end,
    },


    -- Stuns the target for 4 sec.  Must be stealthed.  Awards 2 combo points.
    cheap_shot = {
        id = 1833,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 60 - 10 * talent.dirty_deeds.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132092,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            applyDebuff( "tagret", "cheap_shot" )
            gain( talent.initiative.rank == 3 and 3 or 2, "combo_points" )
        end,
    },


    -- Instantly removes all existing harmful spell effects and increases your chance to resist all spells by 90% for 5 sec.  Does not remove effects that prevent you from using Cloak of Shadows.
    cloak_of_shadows = {
        id = 31224,
        cast = 0,
        cooldown = function() return 180 - 15 * talent.elusiveness.rank end,
        gcd = "totem",

        startsCombat = false,
        texture = 136177,

        toggle = "defensives",

        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
            applyBuff( "cloak_of_shadows" )
        end,
    },


    -- When activated, increases the critical strike chance of your next offensive ability by 100%.
    cold_blood = {
        id = 14177,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "cold_blood",
        startsCombat = false,
        texture = 135988,

        toggle = "cooldowns",

        nobuff = "cold_blood",

        handler = function ()
            applyBuff( "cold_blood" )
        end,
    },


    -- Finishing move that reduces the movement of the target by 50% for 6 sec and causes increased thrown weapon damage:     1 point  : 223 - 245 damage     2 points: 365 - 387 damage     3 points: 507 - 529 damage     4 points: 649 - 671 damage     5 points: 791 - 813 damage
    deadly_throw = {
        id = 26679,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        texture = 135430,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyDebuff( "target", "deadly_throw" )
            spend( combo_points.current, "combo_points" )
            if talent.throwing_specialization.rank == 2 then interrupt() end
        end,

        copy = { 26679, 48673, 48674 },
    },


    -- Disarm the enemy, removing all weapons, shield or other equipment carried for 10 sec.
    dismantle = {
        id = 51722,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 236272,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "dismantle" )
        end,
    },


    -- Throws a distraction, attracting the attention of all nearby monsters for 10 seconds.  Does not break stealth.
    distract = {
        id = 1725,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.filthy_tricks.rank end,
        gcd = "totem",

        spend = function() return 30 - 5 * talent.filthy_tricks.rank end,
        spendType = "energy",

        startsCombat = false,
        texture = 132289,

        handler = function ()
        end,
    },


    -- Finishing move that consumes your Deadly Poison doses on the target and deals instant poison damage.  Following the Envenom attack you have an additional 15% chance to apply Deadly Poison and a 75% increased frequency of applying Instant Poison for 1 sec plus an additional 1 sec per combo point.  One dose is consumed for each combo point:    1 dose:  180 damage    2 doses: 361 damage    3 doses: 541 damage    4 doses: 722 damage    5 doses: 902 damage
    envenom = {
        id = 32645,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        texture = 132287,
     
        usable = function() return combo_points.current > 0, "requires combo_points" end,


        handler = function ()
            if not ( glyph.envenom.enabled or talent.master_poisoner.rank == 3 ) then
                removeDebuffStack( "target", "deadly_poison", combo_points.current )
            end

            if talent.cut_to_the_chase.rank == 5 and buff.slice_and_dice.up then
                buff.slice_and_dice.expires = query_time + buff.slice_and_dice.duration
            end

            spend( combo_points.current, "combo_points" )
        end,

        copy = { 32645, 32684, 57992, 57993 },
    },


    -- Increases the rogue's dodge chance by 50% and reduces the chance ranged attacks hit the rogue by 25%.  Lasts 15 sec.
    evasion = {
        id = 5277,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0,
        spendType = "energy",

        startsCombat = false,
        texture = 136205,

        toggle = "defensives",

        handler = function ()
            applyBuff( "evasion" )
        end,

        copy = { 5277, 26669 },
    },


    -- Finishing move that causes damage per combo point:     1 point  : 256-391 damage     2 points: 452-602 damage     3 points: 648-813 damage     4 points: 845-1024 damage     5 points: 1040-1235 damage
    eviscerate = {
        id = 2098,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        texture = 132292,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            if talent.cut_to_the_chase.rank == 5 and buff.slice_and_dice.up then
                buff.slice_and_dice.expires = query_time + buff.slice_and_dice.duration
            end

            spend( combo_points.current, "combo_points" )
        end,

        copy = { 2098, 6760, 6761, 6762, 8623, 8624, 11299, 11300, 26865, 31016, 48667, 48668 },
    },


    -- Finishing move that exposes the target, reducing armor by 20% and lasting longer per combo point:     1 point  : 6 sec.     2 points: 12 sec.     3 points: 18 sec.     4 points: 24 sec.     5 points: 30 sec.
    expose_armor = {
        id = 8647,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 25 - 5 * talent.improved_expose_armor.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132354,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            spend( combo_points.current, "combo_points" )
        end,
    },


    -- Instantly throw both weapons at all targets within 8 yards, causing 105% weapon damage with daggers, and 70% weapon damage with all other weapons.
    fan_of_knives = {
        id = 51723,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        texture = 236273,

        handler = function ()
        end,
    },


    -- Performs a feint, causing no damage but lowering your threat by a large amount, making the enemy less likely to attack you.
    feint = {
        id = 1966,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        spend = function() return glyph.feint.enabled and 0 or 20 end,
        spendType = "energy",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            applyBuff( "feint" )
        end,

        copy = { 1966, 6768, 8637, 11303, 25302, 27448, 48658, 48659 },
    },


    -- Garrote the enemy, silencing them for 3 sec causing 768 damage over 18 sec, increased by attack power.  Must be stealthed and behind the target.  Awards 1 combo point.
    garrote = {
        id = 703,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 50 - 10 * talent.dirty_deeds.rank end,
        spendType = "energy",

        startsCombat = true,
        texture = 132297,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            applyDebuff( "target", "garrote" )
            applyDebuff( "target", "garrote_silence" )
            gain( talent.initiative.rank == 3 and 2 or 1, "combo_points" )
        end,

        copy = { 703, 8631, 8632, 8633, 11289, 11290, 26839, 26884, 48675, 48676 },
    },


    --[[ Increases dodge by 15% for 7-11 seconds.
    ghostly_strike = {
        id = 14278,
        cast = 0,
        cooldown = function() return glyph.ghostly_strike.enabled and 30 or 20 end,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        talent = "ghostly_strike",
        startsCombat = true,
        texture = 136136,

        handler = function ()
            applyBuff( "ghostly_strike" )
            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
        end,
    }, ]]


    -- Causes 79 damage, incapacitating the opponent for 4 sec, and turns off your attack.  Target must be facing you.  Any damage caused will revive the target.  Awards 1 combo point.
    gouge = {
        id = 1776,
        cast = 0,
        cooldown = 10,
        gcd = "totem",
        requiresFacing = function() return not glyph.gouge.enabled end,

        spendType = "energy",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "gouge" )
            gain( 1, "combo_points" )
        end,
    },


    -- An instant strike that deals 110% weapon damage (160% if a dagger is equipped) and causes the target to hemorrhage, increasing any Physical damage dealt to the target by up to 13.  Lasts 10 charges or 15 sec.  Awards 1 combo point.
    hemorrhage = {
        id = 16511,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 35 - talent.slaughter_from_the_shadows.rank end,
        spendType = "energy",

        talent = "hemorrhage",
        startsCombat = true,
        texture = 136168,

        handler = function ()
            applyDebuff( "target", "hemorrhage", nil, 10 )
            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
        end,

        copy = { 16511, 17347, 17348, 26864, 48660 }
    },


    -- A quick kick that interrupts spellcasting and prevents any spell in that school from being cast for 5 sec.
    kick = {
        id = 1766,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132219,

        toggle = "interrupts",

        debuff = "casting",
        timeToReady = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.improved_kick.rank > 1 then applyDebuff( "target", "silenced_improved_kick" ) end
        end,
    },


    -- Finishing move that stuns the target.  Lasts longer per combo point:     1 point  : 2 seconds     2 points: 3 seconds     3 points: 4 seconds     4 points: 5 seconds     5 points: 6 seconds
    kidney_shot = {
        id = 408,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132298,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyDebuff( "target", "kidney_shot" )
            spend( combo_points.current, "combo_points" )
        end,

        copy = { 408, 8643 },
    },


    -- Step through the shadows from enemy to enemy within 10 yards, attacking an enemy every .5 secs with both weapons until 5 assaults are made, and increasing all damage done by 20% for the duration.  Can hit the same target multiple times.  Cannot hit invisible or stealthed targets.
    killing_spree = {
        id = 51690,
        cast = 0,
        cooldown = function() return glyph.killing_spree.enabled and 75 or 120 end,
        gcd = "totem",

        spend = 0,
        spendType = "energy",

        talent = "killing_spree",
        startsCombat = true,
        texture = 236277,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "killing_spree" )
            setCooldown( "global_cooldown", 2.5 )
        end,
    },


    -- Instantly attacks with both weapons for 100% weapon damage plus an additional 44 with each weapon.  Damage is increased by 20% against Poisoned targets.  Awards 2 combo points.
    mutilate = {
        id = 1329,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return glyph.mutilate.enabled and 55 or 60 end,
        spendType = "energy",

        talent = "mutilate",
        startsCombat = true,
        texture = 132304,

        handler = function ()
            gain( 2, "combo_points" )
            removeBuff( "remorseless" )
        end,

        copy = { 1329, 34411, 34412, 34413, 48663, 48666 },
    },


    -- When used, adds 2 combo points to your target.  You must add to or use those combo points within 20 sec or the combo points are lost.
    premeditation = {
        id = 14183,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        spend = 0,
        spendType = "energy",

        talent = "premeditation",
        startsCombat = false,
        texture = 136183,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            gain( 2, "combo_points" )
        end,
    },


    -- When activated, this ability immediately finishes the cooldown on your Evasion, Sprint, Vanish, Cold Blood and Shadowstep abilities.
    preparation = {
        id = 14185,
        cast = 0,
        cooldown = function() return 480 - 90 * talent.filthy_tricks.rank end,
        gcd = "totem",

        talent = "preparation",
        startsCombat = false,
        texture = 460693,

        toggle = "cooldowns",

        handler = function ()
            setCooldown( "evasion", 0 )
            setCooldown( "sprint", 0 )
            setCooldown( "vanish", 0 )
            setCooldown( "cold_blood", 0 )
            setCooldown( "shadowstep", 0 )

            if glyph.preparation.enabled then
                setCooldown( "blade_flurry", 0 )
                setCooldown( "dismantle", 0 )
                setCooldown( "kick", 0 )
            end
        end,
    },


    -- A strike that becomes active after parrying an opponent's attack.  This attack deals 150% weapon damage and slows their melee attack speed by 20% for 30 sec.  Awards 1 combo point.
    riposte = {
        id = 14251,
        cast = 0,
        cooldown = 6,
        gcd = "totem",

        spend = 10,
        spendType = "energy",

        talent = "riposte",
        startsCombat = true,
        texture = 132336,

        handler = function ()
            applyDebuff( "target", "riposte" )
            gain( 1, "combo_points" )
        end,
    },


    -- Finishing move that causes damage over time, increased by your attack power.  Lasts longer per combo point:     1 point  : 346 damage over 8 secs     2 points: 505 damage over 10 secs     3 points: 685 damage over 12 secs     4 points: 887 damage over 14 secs     5 points: 1111 damage over 16 secs
    rupture = {
        id = 1943,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132302,

        usable = function ()
            if combo_points.current == 0 then return false, "requires combo_points" end

        end,

        handler = function ()
            applyDebuff( "target", "rupture" )
            spend( combo_points.current, "combo_points" )
        end,

        copy = { 1943, 8639, 8640, 11273, 11274, 11275, 26867, 48671, 48672 },
    },

    recuperate = {
        id = 73651,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 30,
        spendType = "energy",

        toggle = "defensives",

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyBuff( "recuperate" )
            spend( combo_points.current, "combo_points" )
        end,
    },

    revealing_strike = {
        id = 84617,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        talent = "revealing_strike",
        startsCombat = true,
        texture = 135407,

        handler = function ()
            gain( 1, "combo_points" )
            applyBuff( "revealing_strike" )
        end,
    },
    -- Transferes any existiong combo points to the current enemy target
    redirect = {
        id = 73981,
        range = 40,
        cast = 0,
        cooldown = 60,
    },

    -- Incapacitates the target for up to 45 sec.  Must be stealthed.  Only works on Humanoids that are not in combat.  Any damage caused will revive the target.  Only 1 target may be sapped at a time.
    sap = {
        id = 6770,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 65 * ( 1 - 0.25 * talent.dirty_tricks.rank ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 132310,

        usable = function() return stealthed.all, "must be in stealth" end,

        handler = function ()
            applyDebuff( "target", "sap" )
        end,

        copy = { 2070, 6770, 11297, 51724 },
    },

    smoke_bomb = {
        id = 76577,
        cast = 0,
        cooldown = 180,
        gcd = "spell"
    },

    -- Enter the Shadow Dance for 6 sec, allowing the use of Sap, Garrote, Ambush, Cheap Shot, Premeditation, Pickpocket and Disarm Trap regardless of being stealthed.
    shadow_dance = {
        id = 51713,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "shadow_dance",
        startsCombat = false,
        texture = 236279,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "shadow_dance" )
        end,
    },


    -- Attempts to step through the shadows and reappear behind your enemy and increases movement speed by 70% for 3 sec.  The damage of your next ability is increased by 20% and the threat caused is reduced by 50%.  Lasts 10 sec.
    shadowstep = {
        id = 36554,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.filthy_tricks.rank end,
        gcd = "off",

        spend = function() return 10 - 5 * talent.filthy_tricks.rank end,
        spendType = "energy",

        talent = "shadowstep",
        startsCombat = true,
        texture = 132303,

        handler = function ()
            applyBuff( "shadowstep_sprint" )
            applyBuff( "shadowstep" )
            setDistance( 7.5 )
        end,
    },


    -- Performs an instant off-hand weapon attack that automatically applies the poison from your off-hand weapon to the target.  Slower weapons require more Energy.  Neither Shiv nor the poison it applies can be a critical strike.  Awards 1 combo point.
    shiv = {
        id = 5938,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40, -- TODO: Cost is based on weapon speed.
        spendType = "energy",

        startsCombat = true,
        texture = 135428,

        handler = function ()
           removeDebuff( "target", "dispellable_enrage" )
        end,
    },


    -- An instant strike that causes 98 damage in addition to 100% of your normal weapon damage.  Awards 1 combo point.
    sinister_strike = {
        id = 1752,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 45 - ( 3 * talent.improved_sinister_strike.rank ) end,
        spendType = "energy",

        startsCombat = true,
        texture = 136189,

        handler = function ()
            gain( 1, "combo_points" )
            removeBuff( "remorseless" )
        end,

        copy = { 1752, 1757, 1758, 1759, 1760, 8621, 11293, 11294, 26861, 26862, 48637, 48638 },
    },


    -- Finishing move that increases melee attack speed by 40%.  Lasts longer per combo point:     1 point  : 9 seconds     2 points: 12 seconds     3 points: 15 seconds     4 points: 18 seconds     5 points: 21 seconds
    slice_and_dice = {
        id = 5171,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132306,

        usable = function() return combo_points.current > 0, "requires combo_points" end,

        handler = function ()
            applyBuff( "slice_and_dice" )
            spend( combo_points.current, "combo_points" )
        end,

        copy = { 5171, 6774 },
    },


    -- Increases the rogue's movement speed by 70% for 15 sec.  Does not break stealth.
    sprint = {
        id = 2983,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        startsCombat = false,
        texture = 132307,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "sprint" )
        end,

        copy = { 2983, 8696, 11305 },
    },


    -- Allows the rogue to sneak around, but reduces your speed by 30%.  Lasts until cancelled.
    stealth = {
        id = 1784,
        cast = 0,
        cooldown = function() return 10 - talent.camouflage.rank end,
        gcd = "off",

        startsCombat = false,
        texture = 132320,

        usable = function() return time == 0, "cannot be in combat" end,

        handler = function ()
            applyBuff( "stealth" )
        end,
    },


    -- The current party or raid member becomes the target of your Tricks of the Trade.  The threat caused by your next damaging attack and all actions taken for 6 sec afterwards will be transferred to the target.  In addition, all damage caused by the target is increased by 15% during this time.
    tricks_of_the_trade = {
        id = 57934,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.filthy_tricks.rank end,
        gcd = "totem",

        spend = function() return 15 - 5 * talent.filthy_tricks.rank end,
        spendType = "energy",

        startsCombat = false,
        texture = 236283,

        handler = function ()
            applyBuff( "tricks_of_the_trade" )
            active_dot.tricks_of_the_trade_threat = 1
        end,
    },

    vendetta = {
        id = 79140,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 458726,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "vendetta" )
        end,
    },
    -- Allows the rogue to vanish from sight, entering an improved stealth mode for 10 sec.  Also breaks movement impairing effects.  More effective than Vanish (Rank 2).
    vanish = {
        id = 1856,
        cast = 0,
        cooldown = function() return 180 - 30 * talent.elusiveness.rank end,
        gcd = "off",

        spend = 0,
        spendType = "energy",

        startsCombat = true,
        texture = 132331,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "stealth" )
        end,

        copy = { 1856, 1857, 26889 },
    },
} )

spec:RegisterSetting( "rogue_description", nil, {
    type = "description",
    name = "Adjust the settings below according to your playstyle preference.  It is always recommended that you use a simulator "..
        "to determine the optimal values for these settings for your specific character."
} )

spec:RegisterSetting( "rogue_description_footer", nil, {
    type = "description",
    name = "\n\n"
} )

spec:RegisterSetting( "rogue_general", nil, {
    type = "header",
    name = "General"
} )

spec:RegisterSetting( "rogue_general_description", nil, {
    type = "description",
    name = "General settings will change the parameters used in the core rotation.\n\n"
} )

spec:RegisterSetting("maintain_expose", false, {
    type = "toggle",
    name = strformat( "Maintain %s", Hekili:GetSpellLinkWithTexture( spec.abilities.expose_armor.id ) ),
    desc = strformat( "When enabled, %s may be recommended when there is no major armor debuff up on your target.", Hekili:GetSpellLinkWithTexture( spec.abilities.expose_armor.id ) ),
    width = "full",
} )

spec:RegisterSetting ("backstab", true, {
    type = "toggle",
    name = strformat( "Use Backstab",Hekili:GetSpellLinkWithTexture( spec.abilities.backstab.id ) ),
    desc = strformat( "When enabled, Hekili will recommend Backstab as a filler ability when you are behind your target.",Hekili:GetSpellLinkWithTexture( spec.abilities.backstab.id ) ),
    width = "full",
} )

spec:RegisterSetting ("t12_4pc", true, {
    type = "toggle",
    name = strformat( "Tricks of the trade",Hekili:GetSpellLinkWithTexture( spec.abilities.tricks_of_the_trade.id ) ),
    desc = strformat( "When enabled, Hekili will recommend Tricks of the trade as ability for set proc",Hekili:GetSpellLinkWithTexture( spec.abilities.tricks_of_the_trade.id ) ),
    width = "full",
} )

spec:RegisterSetting( "rogue_general_footer", nil, {
    type = "description",
    name = "\n\n"
} )

spec:RegisterSetting( "envenom_pool_pct", 60, {
    name = "Energy % for |T132292:0|t Envenom",
    desc = "If set above 0, the addon will pool to this Energy threshold before recommending |T132292:0|t Envenom.",
   type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = 1.5
} )

spec:RegisterSetting( "dot_threshold", 7, {
    name = "Remaining Time DoT Threshold",
    desc = "If set above 0, the DoT priority will not be used if your enemy or enemies will not survive longer than the specified time.",
    type = "range",
    min = 0,
    max = 10,
    step = 0.1,
    width = "full"
} )

spec:RegisterSetting( "solo_vanish", true, {
    name = "Allow |T132292:0|t Vanish when Solo",
    desc = "If unchecked, the addon will not recommend |T132292:0|t Vanish when you are alone (to avoid resetting combat).",
    type = "toggle",
    width = "full"
} )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    package = "Assassination",
    usePackSelector = true
} )


spec:RegisterPack( "Assassination", 20250226, [[Hekili:9QvBVnoUr4FllkGJZ1uvl54SzpyBGTBlA3fx3E482x(KLzKOTjISKRiv2nhm8V9oJiPfffPSZLffhU7I5lpZmKdF4md1YWLFz5IuIGU8ZrJIMmkk6UGOXtIgF3YfIN3txUypj5rYg4pYj7G)775CcNZYjcwro27ZzfKuefErvzcmILlEOILj(y(YhCdD4YfKkX2IYLlwSRADj7XLl2YstPYzq5jlx8LTm(Xv4)soUsPchxvSg(Dck5JRYyCb096IYJR(B0hzzSGLlQBevMKu8)95AZJMtEiJMU8pbYnrQ2prZtPcbrkUs2EzZFOOilT4R5CaGsMGwYGriiLBOIabBhnwueNYafz(XvJhDC1GJREOA96aEglHgtYtHEtObv7R7kLw3zz1Ervj26sbSuyPrnYjPy3dfX7ly5ODn74Qj1Om8eqALUg)dhoUYLMn94QiqZUUXwtaBk(HSIIuu(J9kFeMAlluAz0CA5MNRrCISL3OnxbLKj2QTtDZfprlH9HmD7GMNOwqB09s6oclNxdlkOESJXTTJNi5m(w0gU1ZUk)5CYEonMVVKLVP1MO9cO2D2Eka6t8GUagXJuryFWEM9fqEzfcdOaXDx)Il67N4IqX9wV7)DxI0QsTZt86QYNreU)Ir4SQ3jbql5OVt(guaV77VaYyRPNoceo67JagBiarrw8tSs44B9VrP4J7jHKLfl)rmYxjzTIL(J7y8KyK8sa)dqoTMuLjCXKva7pCQW84bybqV4FLvHU27PGGK6opynjpUyD8J5SNOYtFrwKF)lfaaTBotWizSFLCcAL6be)BYOkqDrNDE1AydZcW1CVKzPn3h0(TWrF5I)qf7cnh2xk21Maj4(wuvWeNmXpGMwIcU4KI8uMEpZMC88wJuYGsTHMhJcLLttRfimpbsPO6tSTKY3cSHMkHSlobUFaUNm1f325vHwes7lPpfVjjnimWG33qKnTgNq4kHAt5DEHc0LfGqFoUSq0XlPBNo456vgAKYleWMyrgYmifDmnJdDGEgQRf5BzpD6O6PlCeqaec0vLscwxbhekPjBr32y59C67jLttTnUpra7DZq3sZf1HFxLLTdT62spo5GYe1JAkBFnBZwrCRj9UrUy71R1pYsE064)FhM7XvnBNDcasTeGEnW2HXL)QWbOPbaZw)3q0z0n3DlBUF(FpZDdPe0B6z42TLDT6Be0tRREtEKJ0LWyJfLKu6VDgDjz(Nd9h43B8ffPXQtRUQXRNa5iz0CrqsLaVTcnbWBKtdud(CHT6QltsxNeSZQVprRUk34A90MqZxaVie3k3tChW9D1DwsxJePsIcT8uHyxlpBUmdVN(Uqef)yteZ9UJskKsYxKB96oWRV2m0FyyBLXwxFghwTVB0fcmeRanNJgJm2b4MaCbM4m6bnIK97ZEg3c44VAXh8Z65Rt5cINoJk2sYWbssZE219)UboVixpvua7Zur6v7d33PodODC34lKxXVNH)P3nUo7DDRGhTo4G3p03XyB)GZFZBRR7vr2hicdGJ4XCG8oGK)CC6EUofmW2onQihJQoa3gyoDPwkgtcdZ0gpAyaHJr0kYk1qJHuRsIRtaXXvcN3oJCANUSGU2PRvJw2PtRy(5wioRzkKKd9CGtZuTi55KtbsZXXFbeJgCF9suADs(9f)fJl2DCO1NKpr2FwMZBBSWw96kO6ETtN3HCPxHC5674E0x)0eDKMH6URsWYi1bHimsJZHRqdEDRRtdETZ52)owVy0kTA)7d1iulWSkUaUSNGx(4XbddUmmQ3uF9VFj1vYLLFDyKrj2AuptlSkNxK9ekO4swAAgT)nqBXBWm)1IY0nvKY0y6UhklyPu5k)5O7DnVAwFZsa6C3PBPNe1Hh0d7H(mr7Z3lQtkxVmAQIAs1aNz7Ez0aqC)RzjmHmkznBRvk84UyNKAU25PJlKpWHyvUjwbinEIDjaU3SYseiMcb5HlNgPLGh9BwWPm(EIiXzGhRlGlrOFtut7RNaMMlKcNQk69655FDYhFKrWH94ELKvqEejdH7yaxyULF2FUbeFXRotMPRrrHTX8SLb3gp1YSgp6teoOnTojPARFNlwoSSbNuItj7iqQ5tK1fsjUDKVDC1paB4bgPXSMcRW975y7t4SCwOv0YiGqRR2tXA(0YoAAEPkAINagCSl8fuUnmes6BXxjL5YQB)VF)V85p(5)6pEC1XvFzlw3UD7lkfQ3e5kvXdVcJB4)wXkXm)4fy6UKkrXoSGtGMULKVHYdo(PAewxKLv8vaECqLeq5)kTeAVIJdglqGahMuHLVbdAsc94YlQfFvERrNMIdoLaNdH8q)XJF64Q)aOlBzpb)5NoJzCkpMl1q(jwo0viG3)mNxThXchGwNVYm1KRon(Ox44Flm(puaSDYrFLoYXWG)dOOIcJMeY2gg9TRp70JCm9OUt)(xN09n9Zk9ZUBbX88Y2NEN319t1S)QlrW8xO)XTELRM5(IeRoqVlv4)F)uMoAh0w(4oTX(wR3rf0S66JKGCDl2xwSMHPIPEEwyWMV6lMmXMkkI4V74Q33URFPURv)d4oJDSFfL17)5FsTA9bq3sYEMVtn1ULy44Nu)rWPJ9)(z)rZtG3ilKWmzjiUGXFQ2dZov6b3ZYr9hCpqvPcUHTE2BAxrr342k(4lDwTlvaolFLxaxmDHGo4VBW8vN1jD1BQZZEwicDd9HDEZdg(MgYb7opCOzIDsxE(SMj2PZRFnQCKPk3vRmu5U2tJk7qRM3J5CTYN13RKDYG6ygTEZmLj0tcQtJ8dvNW4vWnuge687hnWm0J53E9HddD9WctddUFGAstMypj)kG1dwPeVZhbBUVhaZp6DEBktFuNVSLFS68gukS60UFimE8jubg2(nGoC4cF)NPrJ6SnuTFGZTLzrWqBELN5ZUF0HdTEDNPZE3OBAEjSzho8QuR2Ys5J3(PGmxGW3nQ(0NNNeAGhQTlI1egK6LCWb5Dmo4P7c6a0eNhoYCI2Lpx50LYBPMD4DFJN3kXysQTr5ktVp(Ya3G5Sz9oU15ZzTiiufuefD7rD7GULvz(DdmRHylyY7U0qkK7e(jRMpB85xHHOxo7yAsqfLytwvtVt7u2Ukhn3FWfT3a8xZdR5OZq2EPtNr98Wbn8QhoyD(9Al00fAOh06ugHPJNm4KeSWthfQx8g9YWRv5fUrxbIzHV4ffDyFMfvUbeWLXWPSvrUL042oPg(JoDyTHUL7NnGWrLEDwV1gnd)glf77QChBJMVL5P3QwEp9Li2mtGOcVIsvkrdwyZ1RXJ8XW05Rr0g5MBvT1QztgmSBLmHqP6iF8sLoAC93TxT(k5Kv(OtNmAGIB903tOQbJVKWbd9(neonCKtDyCxDaYSkMjO7uesTR86PGRn)WV8baghQo4ZqxZ0ZYYfby0RaWMhm4sSNMNg4viYtzO)kWOB2rxeqJhzM2JYb25nl6m0nhVUTolBo(sBDoPwREx4K8yPwV7IdsWPZcnx3mGSZZF0S(r6F9dqCGL49O2oFHdxYX9S9CuZ)7MmW1YznNyt9NBevtCdOdGvTMTcLywKMWXrrP9aPQ0Y2ibx0krQPC0EaOUgY407w)55n1E(hgfe5bGMIcBPeJTs2B2yLo1U6YyDKx()o]] )

spec:RegisterPack( "Combat", 20250306, [[Hekili:1M1BVTTnt8plbdWjzRpE2Y2PRfrgOn7zBTOlOOUd7DsIrI2wWYIEIuolag6Z(oskzjsrs7MSHGeylD8()9J3DjyCWxdwKGy4G79g5nB0Kr3m0BY4XtFDWc2t7Wbl2HI3GwbFihTf(7DKTpGy8h)ugbLWpoLuwedVkyXdLPzSpKh8qFE6nEcq5oCCW9tdwSonjblPdtJdw811P0Qi(VOQOAjwfrwcFpMLsYRIYsPm41ljfvr)gEtAw6WGfIhYvbUG56Y9c7bNJEidNe8(GfYJhSyfPKBdCPvKUt(S3ZpuvubHHKpaEfdxKIGpbwjjChjnNlu)QOPbmWA0yEl9puUC5qAwAmoeLNeMaFyyc5rqVhuf1JzJA1lAAoyd4IqkRiDdMlLj)BiL5Qsr5mCHm1Qqu5ZTG6orW)eSq8f49yuwA(QAnUvbmPDf4TO0CP(mRvF0zcxJMDUAKcNm4)UXkJU6ekjWApt(sFXZV2L)81wY7OpLJ2rXH0DfG5s7fntW4DHGWtxTMnSCxv0Hd1kjkPa4h4KWHfL01WlBkb15jd(bYSxIkZyUQbORt3Rvc87GHBUcOoCNKc1SzzCEfIZlGYsUI4SwGHkwHzdRzqmIYaTuO(nkYM04nUZ0zPBXIKMjDYIHiC8gAizziBnoKvGsmMk3qEmkllu(LqoqHeUiu6dJtOFljD(QPVL5wz8sEc5A35HcxAO0prh(qgyiHlZklkEsMSn58efI4m1ZP9lbmHt)tpNtdjByiNDpUo5BxbowEVGH0pLeUp3qzdYo9KXxrM2rAizH7tlGaJ87TYXz(0fvrakbkdyCYqWY6uuiFSBmrBaVoqeyY4JJYXUXDnV07i)FZvLxudo09SNBbjVMkKrafelrrfqDCTzpV2gVnflbQ96cuNKcrmMBV7jVAWfcUP7c(2IeDXVNzd)2f495IcWz0uHam5sbp3yVUVTXTuUJvw0XBO7YVv0FrNsEb9Flqilr58YMn58sYU6PlhVYHmbKCEGH49P0yCbVDpdWjp3BXzsiAhLpaL5BWSX8akH197VORyvQdVJqY4HnQPcmnfX7fkyfRWZDbhK6uS6jHxCImJVbyaAmwwlbqYyHqD06w9RBAlYU((qgHKKvsLpUtJqAgI7A3(ATPQ5AL6cRUk3681DBZOJVWDD(PUr2trN0rFndP)nu)QkWJTH6wyXO8yCwiNizcxZv7AkH9Y6NrwARLczeHllLIWEv)lre4ckUydeb5I4n)xiIS0LyHLe00dDtBnoaEIH5E3WroPRra4avdZ4NBzshLCTOlJH7Izs8EVrkzu688K3PRZpnya8Eef0gfJT(zUrwsZbCAErtcAl0SF4mzlb1IBl6VRI(Ey0YHDUpDjgG0Dx5ROTW1KJSCl9efJaA8OCN4Mff7O9XYOwDh3Ug8r9gF141VioU52TE(DB4m41)60g7MbDadE)JqCekvMkR3ZaCOXayNlyPZOrftLogBeXEcJjBHRWwA68glESPYtzXZCCW91qV7Khvk0BmJTKersXXxk736ANm2TdqP1grU2EatI)QMfBbtQ9iQixoA)F(UVC)hU)xFBvuv0xxd2B62DKcw9sRUuMNEjKPH)RsOR6eyMecFmxujJSfec8G41O8vy6WQpkyWsc3CfjeOYceO5pIlGNxs5eZhDNXjtQVYDKXTjwdD5eH0lZvOojHtCcIHEarXVT6Jvr)VQiD)h84pEclc6q7CnNpb4VvrVb40FKtl3X5cNGgn)YJiXxoKl4pSTHIxRTcq41qaQKTMueSyX2YLqNm8bqjltZGs7VRk6U65l)czvjiZ395pvRV3bwCC2t0TCjae2Fwu(lQ)4WJZ0(d()OHjtTqOY4PMPPEIZxLU0)cLHsTqUc8d)uMqLej7sZsDNohzkNvRt3ZzGRD70LE(EA40BBJoDP1GlsCuO(F(KrDPuFZcVI32IpKl1LiT9EiPrwbXzB3Yz)zN8GWK48tzVPR5(toTkk2zYPjRTlI6aIY08TbzqPaE0vlePegHY1ouZy5DcoDaAVD2a1RlM71NbQJc0jRW4u8d66WVDMo7oVC06Bob1Rl3M73x7Kx8OhON7pDqFRD(yVb2h4wZtCR)uDHPmgC)SeLxZ1a3EI2RmCKM241uN6v)aCMlYF0()u0YgrcjWiX)CJEYBAFcnirBGjk2P)id86SI59y1CdSYu2OINWFYaNzNoY2Mp7SCd2IQ2T2RCLI7PNIFDFwcxIhcDrTvIAOTu)J(tTMtoCWYqn15k6DZ2kwj45zh4oJI1JC0s9Q)Sbxu3q7GR4TYE4GA1O)4RhyeVZszUXj96RoUQbpCWaE5nA240dh0SJRS0(5a7TEEDpMyw9fHTJlAQ1CGle7MKWxpKFZoUEgzhNbB9EXSvJco)Kl952jZQJ06lOYAHn8QRCOmDxj1166HIqu1ct56GOUWIfAwh6jq9BXD1PHN5CEDw2z9o1TFC2Y426sLtiH2D48Id8T7Q5fZQJtc8m4KOw6N70)vdRB7jJ7z1w2cxqTBO4wFVr1ridBLXclR3TIoNoM13UpglmqSef(X7VaM5TlF57hn0ZcdA3kIMsmEKg62KADsD9k8XBd(Np]] )

spec:RegisterPack( "Subtlety", 20250306, [[Hekili:DRvBVnoUr4FlbfWNd6vxj)s2ChSdW133fOPfR2R73KfTfDSqKe1jrL0ayOF7DOOEHKIKsgB6b0Id3cfrYzgoCMN5HJSVR)x89cruS)JlDwUXzLZDlwUY5EFp6BzyFVm0XNrpbpKIsG)1R8angtFJnWBXeuiB5fKY8JWG(EhkJIPFm1)Goz(Hn)GVhQKEMKdckP8uE0Z(ENJcdX8vGlo679LZrfvbS)hvf0O9QaYj4VpsJiPvbXrfuy4tK8QG)g(5O4OfG5KtoffdgXVPk4ZKNkH10ARvFQ6tWB)N54JKKdiARKkQ(uZdlYAh73U73tZJo(CXEYP90Z490Cuiw)eHhlZW5W(u)4zKA7v7yfumkME(7JoT7MMNXHlqXXgevoobhgrrwKyC0r8EuA4(q4bMGpuE60c5xViK8QH1JsouwuBqSxr2NrIsPfB3mtX8Q9L)JmCkgC)f4FPeNEuWbqQhXSj3nEV(mS)7M503zxUOBeWqqrPfBVtJSZlZOL5y1T9d7wplexlSMzul)zuu(ty6cAucezqaXJFW9EnI9moHKNFgcDzsUrs9Vu5yOFNEgbJSpeLkUpfEj3kyZ(P3Ey3DogLb4tZ0lHYmRhgdxqR7B5S6XovM)wBYbKXsZjVHZ1lv8lrfhRtqg6F3O7WOlHA48xX1E)uA8H1HJ)DWazP9nbBbZ)lrPHvbFfJEofxayf)Cg7i72EDMm9aR29)QzYw0sfPzjuQjSrjIQ3XosyvYWqkzjkez1k01l2OUBLcmmK0LihnajXVS)PJHlCx0V8lxST4daKDbfDqdsY8(a32mv5it1di59SI04cRZPLG(3B35Ayx3NsjJ22esdrl7FTjyPZdUBP6bExI3hCu0YlO0OcnO5xH83cH49(Nz3ypZvyVLGJdFx1Ss2pk8TjznwZ2VCzym(wxhfp8Aw(CDgThfY)q5HwZQ)tacGCEDDAy6E(FTNru47z8w2XHyQtCG5VDJ4cEgk3pmL6iQGgL(K42CcfTGPCe(7HgWrcjMbyvio1Yc8(ikoHpLI3srzWBkYYbfxyc9(YLwzzaMUj16qmHegxwqzhHhPA1BrmHUd47K(mM6AwHAo6w6mQax(niq9oXKCHQPYH2YhtxhW(UnQHH6aK3D)S5wLYQlx4zrB3T2rjKSRYGosfkPkARg4Wo2LNMHQjGDQnBTh8sk63wn3ndQ52rLsVro(riIuRh27FbVhmPKimR6U4kLr9NBSuhNX3OvcxDRbhIC9erlWynS1xUmxBzii8W5wZdEhdPRjR9mjLKVhLqsFcirfHFb3Hm)Wo3Bn7jUY6FVtqYxrGxd29FSdRlyUxTphGQzoD4Ixma8)vDXsHA9DGJAQxl5bLRzDZyibscgOYKHYRlLWDgnhh8s3DNaINu6WxFyLJE53tbG5pHKHz2mDTbKx3gACI(nvcA2HMKZy10u9I93QBqqjqSy(umKw2FC9jt8tsBKw1ORKM2a4vgOw2eB(tK)SaLIoLcWsG6oHsz3S55uaBQqtgNkQ1AvbCD1DSCHcU4ARBW3M7womjwBLk37nCHJqPBDQvhR(VHoM49a5twgZt2LVv9QugVsnxwwUlIQG99EbNxaRTRNvR89EfLNY4I5791F6Zp(Xh)R)yvqvWxodizrjzKCAtxO(UK8VRkih)lLr5yaHRGKWa7kPKeytdV44zu6taoF1NQx8jsCm5vqYSjLJaGYxX5W7bEuWKz3LLYMgFZWB4vvWHsA78sj1AUmvA2HHSjhIGnmQa)JqeFWVdMMiycllyKTsi(eQmM()n7No8K)3zh9X6natr3P01tW889kYWh9FeIyRFfRbS8R3ap9yD7CXPOdX4q))aVNQ5rzmr47P21oFpUWzDpvaw3Nc5akYbecfNhHaTlwKOxc8QiSLUY4s1bgwN2gC5cZ7zeQSkyl4l6vM8SykDTrLkM3xf8WUQG1vbZGtbn4wS3peSdwvvG799QVznm9UXOE1Jq1lK(byY5UrCAQ9aS2u5em4BQ7CeCpcZMj8pCfcVmtvomggmPC)vifXZTL12kNyJHEhQlm6hUIt0n9cOVwdtiUoxHuw1BOkTzu4OVBaq8uFVeTzDgItLZgNAtlhlds0xZ3cd3AlTNtBkhXAFlfoCVUCgZaeJDxUAvUEXgtzrMrbmGAjhHBozwBFq5WwJIhAo1w2TdBTn1EZ5Qz2I4JkSAdUTxLTSDSNYBqPdVnjmiODxZEBZac3O4weqa01qsUMwAk2Daw3hSG1zg24DZO22HvOEmbV6g9hu9gm)sqJao9RMToSxVtBx03656DIkaOvWAE4SomdiA01XqyWAdy8ugSAnL1r5)CDnvwe7sQLYsiwrjC7EdNo2E(NjVHqMvqxt9BUxVSotBhWCuWhveX2zO2DojRVJYSoqXUia52vpgRc(HU1wR0wqPdSt5((T)geu1Sgm2wJST32tZ6mesU0HvjNqfeNgewfvU89vLlTd4AOXrt88oj3oYPDwh7AlHmclcz2bWO33wTBu5VI7SAHWyVATJuTVH3iWc6QjQ)AXQSqVXPnOw)YmsBQBVBaMDybVnAjsDTWUAy3kDbl7BwdKGF01mehBb9nzPHL9edkreU0nd(nxLGQA3GeZWSZPecWUD0tKHmNmXmYDQxhDBDocZmNRt(dceU3P2qN(cURTC64F8b(cCnsP01m943poLUtLT83ctIVH0wZKq6(TunknKH)q0KQEO(JpRJfHM0pbD0YtODw8ENRmdZXLQmofGw5VUJlqNcK6zKSEgRDgd7bKnO8R(YmJrlIkYXX293fVCH8H4e)ixIgR28s9K1VPlmCqj9rUiV2VQvncUkuGEkyWex5iDi3(vZSZeLte(HU0URBZAeZ1IJqZnQmhEBMbw9iDFzk1Z(XBnWyXAt)()DxHBUjhYq7vS1aDFnnji8bT2DKUbQ(7gXge7klTMyasuDAhRQULeoPVaNsgN0NUBcGa6iFS2E6JDIO2AVMf0lZ5mxfHzw70ehvdj2HKeBUKPV3s7Ph)kAjRSNoPPQSHAUwsSup63QVHMtS38xD5hDQxlNQ2)Z))m]])


spec:RegisterPackSelector( "assassination", "Assassination", "T132292:0|t Assassination",
    "If you have spent more points in |T132292:0|t Assassination than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "combat", "Combat", "T132090:0|t Combat",
    "If you have spent more points in |T132090:0|t Combat than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "subtlety", "Subtlety", "T132320:0|t Subtlety",
    "If you have spent more points in |T132320:0|t Subtlety than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )
