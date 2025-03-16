-- RogueOutlaw.lua
-- January 2025

--------------------------------------------------------------------------------
-- Check player class first
--------------------------------------------------------------------------------
if UnitClassBase("player") ~= "ROGUE" then return end

--------------------------------------------------------------------------------
-- Upvalue references to minimize repeated global lookups
--------------------------------------------------------------------------------
local addon, ns = ...
local Hekili = _G[addon]

local floor, min, max, abs = math.floor, math.min, math.max, math.abs
local GetTime = _G.GetTime
local pairs, ipairs, select, type = pairs, ipairs, select, type
local strformat = string.format

local class = Hekili.Class
local state = Hekili.State
local PTR = ns.PTR
local FindPlayerAuraByID = ns.FindPlayerAuraByID
local GetUnitChargedPowerPoints = GetUnitChargedPowerPoints

--------------------------------------------------------------------------------
-- Create the specialization object
--------------------------------------------------------------------------------
local spec = Hekili:NewSpecialization(260)

--------------------------------------------------------------------------------
-- Register Outlaw Rogue Resources
--------------------------------------------------------------------------------
spec:RegisterResource(Enum.PowerType.ComboPoints)
spec:RegisterResource(Enum.PowerType.Energy, {
    blade_rush = {
        aura = "blade_rush",
        last = function ()
            local app = state.buff.blade_rush.applied
            local t = state.query_time
            return app + floor(t - app)
        end,
        interval = function() return class.auras.blade_rush.tick_time end,
        value = 5,
    },
},
nil,  -- No replacement model.
{
    -- Meta function replacements for base_time_to_max & base_deficit
    base_time_to_max = function(t)
        local b = state.buff
        if b.adrenaline_rush.up then
            if t.current > t.max - 50 then return 0 end
            return state:TimeToResource(t, t.max - 50)
        end
    end,
    base_deficit = function(t)
        local b = state.buff
        if b.adrenaline_rush.up then
            return max(0, (t.max - 50) - t.current)
        end
    end,
})

--------------------------------------------------------------------------------
-- Register All Outlaw Talents
--------------------------------------------------------------------------------
spec:RegisterTalents({
    -- Rogue
    acrobatic_strikes         = {  90752, 455143, 1 },
    airborne_irritant         = {  90741, 200733, 1 },
    alacrity                  = {  90751, 193539, 2 },
    atrophic_poison           = {  90763, 381637, 1 },
    blackjack                 = {  90686, 379005, 1 },
    blind                     = {  90684,   2094, 1 },
    cheat_death               = {  90742,  31230, 1 },
    cloak_of_shadows          = {  90697,  31224, 1 },
    cold_blood                = {  90748, 382245, 1 },
    deadened_nerves           = {  90743, 231719, 1 },
    deadly_precision          = {  90760, 381542, 1 },
    deeper_stratagem          = {  90750, 193531, 1 },
    echoing_reprimand         = {  90638, 470669, 1 },
    elusiveness               = {  90742,  79008, 1 },
    evasion                   = {  90764,   5277, 1 },
    featherfoot               = {  94563, 423683, 1 },
    fleet_footed              = {  90762, 378813, 1 },
    forced_induction          = {  90638, 470668, 1 },
    gouge                     = {  90741,   1776, 1 },
    graceful_guile            = {  94562, 423647, 1 },
    improved_ambush           = {  90692, 381620, 1 },
    improved_sprint           = {  90746, 231691, 1 },
    improved_wound_poison     = {  90637, 319066, 1 },
    iron_stomach              = {  90744, 193546, 1 },
    leeching_poison           = {  90758, 280716, 1 },
    lethality                 = {  90749, 382238, 2 },
    master_poisoner           = {  90636, 378436, 1 },
    nimble_fingers            = {  90745, 378427, 1 },
    numbing_poison            = {  90763,   5761, 1 },
    recuperator               = {  90640, 378996, 1 },
    rushed_setup              = {  90754, 378803, 1 },
    shadowheart               = { 101714, 455131, 1 },
    shadowrunner              = {  90687, 378807, 1 },
    shiv                      = {  90740,   5938, 1 },
    soothing_darkness         = {  90691, 393970, 1 },
    stillshroud               = {  94561, 423662, 1 },
    subterfuge                = {  90688, 108208, 2 },
    supercharger              = {  90639, 470347, 2 },
    superior_mixture          = {  94567, 423701, 1 },
    thistle_tea               = {  90756, 381623, 1 },
    thrill_seeking            = {  90695, 394931, 1 },
    tight_spender             = {  90692, 381621, 1 },
    tricks_of_the_trade       = {  90686,  57934, 1 },
    unbreakable_stride        = {  90747, 400804, 1 },
    vigor                     = {  90759,  14983, 2 },
    virulent_poisons          = {  90760, 381543, 1 },
    without_a_trace           = { 101713, 382513, 1 },

    -- Outlaw
    ace_up_your_sleeve        = {  90670, 381828, 1 },
    adrenaline_rush           = {  90659,  13750, 1 },
    ambidexterity             = {  90660, 381822, 1 },
    audacity                  = {  90641, 381845, 1 },
    blade_rush                = {  90664, 271877, 1 },
    blinding_powder           = {  90643, 256165, 1 },
    combat_potency            = {  90646,  61329, 1 },
    combat_stamina            = {  90648, 381877, 1 },
    count_the_odds            = {  90655, 381982, 1 },
    crackshot                 = {  94565, 423703, 1 },
    dancing_steel             = {  90669, 272026, 1 },
    deft_maneuvers            = {  90672, 381878, 1 },
    devious_stratagem         = {  90679, 394321, 1 },
    dirty_tricks              = {  90645, 108216, 1 },
    fan_the_hammer            = {  90666, 381846, 2 },
    fatal_flourish            = {  90662,  35551, 1 },
    float_like_a_butterfly    = {  90755, 354897, 1 },
    ghostly_strike            = {  90644, 196937, 1 },
    greenskins_wickers        = {  90665, 386823, 1 },
    heavy_hitter              = {  90642, 381885, 1 },
    hidden_opportunity        = {  90675, 383281, 1 },
    hit_and_run               = {  90673, 196922, 1 },
    improved_adrenaline_rush  = {  90654, 395422, 1 },
    improved_between_the_eyes = {  90671, 235484, 1 },
    improved_main_gauche      = {  90668, 382746, 1 },
    keep_it_rolling           = {  90652, 381989, 1 },
    killing_spree             = {  94566,  51690, 1 },
    loaded_dice               = {  90656, 256170, 1 },
    opportunity               = {  90683, 279876, 1 },
    precise_cuts              = {  90667, 381985, 1 },
    precision_shot            = {  90647, 428377, 1 },
    quick_draw                = {  90663, 196938, 1 },
    retractable_hook          = {  90681, 256188, 1 },
    riposte                   = {  90661, 344363, 1 },
    ruthlessness              = {  90680,  14161, 1 },
    sleight_of_hand           = {  90651, 381839, 1 },
    sting_like_a_bee          = {  90755, 131511, 1 },
    summarily_dispatched      = {  90653, 381990, 2 },
    swift_slasher             = {  90649, 381988, 1 },
    take_em_by_surprise       = {  90676, 382742, 2 },
    thiefs_versatility        = {  90753, 381619, 1 },
    triple_threat             = {  90678, 381894, 1 },
    underhanded_upper_hand    = {  90677, 424044, 1 },

    -- Fatebound
    chosens_revelry           = {  95138, 454300, 1 },
    deal_fate                 = {  95107, 454419, 1 },
    deaths_arrival            = {  95130, 454433, 1 },
    delivered_doom            = {  95119, 454426, 1 },
    destiny_defined           = {  95114, 454435, 1 },
    double_jeopardy           = {  95129, 454430, 1 },
    edge_case                 = {  95139, 453457, 1 },
    fate_intertwined          = {  95120, 454429, 1 },
    fateful_ending            = {  95127, 454428, 1 },
    hand_of_fate              = {  95125, 452536, 1, "fatebound" },
    inevitabile_end           = {  95114, 454434, 1 },
    inexorable_march          = {  95130, 454432, 1 },
    mean_streak               = {  95122, 453428, 1 },
    tempted_fate              = {  95138, 454286, 1 },

    -- Trickster
    cloud_cover               = {  95116, 441429, 1 },
    coup_de_grace             = {  95115, 441423, 1 },
    devious_distractions      = {  95133, 441263, 1 },
    disorienting_strikes      = {  95118, 441274, 1 },
    dont_be_suspicious        = {  95134, 441415, 1 },
    flawless_form             = {  95111, 441321, 1 },
    flickerstrike             = {  95137, 441359, 1 },
    mirrors                   = {  95141, 441250, 1 },
    nimble_flurry             = {  95128, 441367, 1 },
    no_scruples               = {  95116, 441398, 1 },
    smoke                     = {  95141, 441247, 1 },
    so_tricky                 = {  95134, 441403, 1 },
    surprising_strikes        = {  95121, 441273, 1 },
    thousand_cuts             = {  95137, 441346, 1 },
    unseen_blade              = {  95140, 441146, 1, "trickster" },
})

--------------------------------------------------------------------------------
-- Register PvP Talents
--------------------------------------------------------------------------------
spec:RegisterPvpTalents({
    boarding_party       =  853,   -- 209752
    control_is_king      =  138,   -- 354406
    dagger_in_the_dark   = 5549,   -- 198675
    death_from_above     = 3619,   -- 269513
    dismantle            =  145,   -- 207777
    drink_up_me_hearties =  139,   -- 354425
    enduring_brawler     = 5412,   -- 354843
    maneuverability      =  129,   -- 197000
    smoke_bomb           = 3483,   -- 212182
    take_your_cut        =  135,   -- 198265
    thick_as_thieves     = 1208,   -- 221622
    turn_the_tables      = 3421,   -- 198020
    veil_of_midnight     = 5516,   -- 198952
})

--------------------------------------------------------------------------------
-- Register Auras
--------------------------------------------------------------------------------
local rtb_buff_list = {
    "broadside", "buried_treasure", "grand_melee", 
    "ruthless_precision", "skull_and_crossbones", 
    "true_bearing", "rtb_buff_1", "rtb_buff_2"
}

spec:RegisterAuras({
    adrenaline_rush = {
        id = 13750,
        duration = 20,
        max_stack = 1
    },
    atrophic_poison = {
        id = 381637,
        duration = 3600,
        max_stack = 1
    },
    atrophic_poison_dot = {
        id = 392388,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    alacrity = {
        id = 193538,
        duration = 15,
        max_stack = 5,
    },
    audacity = {
        id = 386270,
        duration = 10,
        max_stack = 1,
    },
    between_the_eyes = {
        id = 315341,
        duration = function() return 3 * effective_combo_points end,
        max_stack = 1,
    },
    blade_flurry = {
        id = 13877,
        duration = function() return talent.dancing_steel.enabled and 13 or 10 end,
        max_stack = 1,
    },
    blade_rush = {
        id = 271896,
        duration = 5,
        tick_time = 1,
        max_stack = 1
    },
    coup_de_grace = {
        id = 462127,
        duration = 3600,
        max_stack = 1
    },
    disorienting_strikes = {
        duration = 3600,
        max_stack = 2
    },
    echoing_reprimand = {
        id = 470671,
        duration = 30,
        max_stack = 1
    },
    escalating_blade = {
        id = 441786,
        duration = 3600,
        max_stack = 4
    },
    fazed = {
        id = 441224,
        duration = 10,
        max_stack = 1
    },
    flawless_form = {
        id = 441326,
        duration = 12,
        max_stack = 20
    },
    ghostly_strike = {
        id = 196937,
        duration = 10,
        max_stack = 1
    },
    internal_bleeding = {
        id = 154953,
        duration = 6,
        tick_time = 1,
        mechanic = "bleed",
        max_stack = 1
    },
    keep_it_rolling = {
        id = 381989,
    },
    killing_spree = {
        id = 424562,
        duration = function () return 0.4 * combo_points.current end,
        max_stack = 1
    },
    kingsbane = {
        id = 385627,
        duration = 14,
        max_stack = 50
    },
    leeching_poison = {
        id = 108211,
        duration = 3600,
        max_stack = 1
    },
    loaded_dice = {
        id = 256171,
        duration = 45,
        max_stack = 1,
        copy = 240837
    },
    nothing_personal = {
        id = 286581,
        duration = 20,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    opportunity = {
        id = 195627,
        duration = 12,
        max_stack = 6
    },
    pistol_shot = {
        id = 185763,
        duration = 6,
        max_stack = 1
    },
    quaking_palm = {
        id = 107079,
        duration = 4,
        max_stack = 1
    },
    riposte = {
        id = 199754,
        duration = 10,
        max_stack = 1,
    },
    sharpened_sabers = {
        id = 252285,
        duration = 15,
        max_stack = 2,
    },
    soothing_darkness = {
        id = 393971,
        duration = 6,
        max_stack = 1,
    },
    sprint = {
        id = 2983,
        duration = 8,
        max_stack = 1,
    },
    subterfuge = {
        id = 115192,
        duration = function() return 3 * talent.subterfuge.rank end,
        max_stack = 1,
    },
    stinging_vulnerability = {
        id = 255909,
        duration = 6,
        max_stack = 1
    },
    summarily_dispatched = {
        id = 386868,
        duration = 8,
        max_stack = 5,
    },
    take_em_by_surprise = {
        id = 385907,
        duration = function()
            return combat and (10 * talent.take_em_by_surprise.rank + 3 * talent.subterfuge.rank) or 3600
        end,
        max_stack = 1
    },
    tricks_of_the_trade = {
        id = 57934,
        duration = 30,
        max_stack = 1
    },
    unseen_blade = {
        id = 459485,
        duration = 20,
        max_stack = 1
    },

    -- The real RtB buffs
    broadside = { id = 193356, duration = 30 },
    buried_treasure = { id = 199600, duration = 30 },
    grand_melee = { id = 193358, duration = 30 },
    ruthless_precision = { id = 193357, duration = 30 },
    skull_and_crossbones = { id = 199603, duration = 30 },
    true_bearing = { id = 193359, duration = 30 },

    rtb_buff_1 = {
        duration = 30,
    },
    rtb_buff_2 = {
        duration = 30,
    },
    supercharged_combo_points = {
        duration = 3600,
        max_stack = function() return combo_points.max end,
        copy = { "supercharge", "supercharged", "supercharger" }
    },

    roll_the_bones = {
        alias = rtb_buff_list,
        aliasMode = "longest",
        aliasType = "buff",
        duration = 30,
    },

    lethal_poison = {
        alias = { "instant_poison", "wound_poison" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },
    nonlethal_poison = {
        alias = { "numbing_poison", "crippling_poison", "atrophic_poison" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },

    -- Legendaries (Shadowlands)
    concealed_blunderbuss = {
        id = 340587,
        duration = 8,
        max_stack = 1
    },
    deathly_shadows = {
        id = 341202,
        duration = 15,
        max_stack = 1,
    },
    greenskins_wickers = {
        id = 340573,
        duration = 15,
        max_stack = 1,
        copy = 394131
    },
    master_assassins_mark = {
        id = 340094,
        duration = 4,
        max_stack = 1,
        copy = "master_assassin_any"
    },

    -- Azerite
    snake_eyes = {
        id = 275863,
        duration = 30,
        max_stack = 1,
    },
    deathmark_bleed = {
        -- Not used here; placeholder if needed
    },

    -- Additional aura references for expansions, if needed
    soulrip = {
        id = 409604,
        duration = 8,
        max_stack = 1
    },
    soulripper = {
        id = 409606,
        duration = 15,
        max_stack = 1
    },
    vicious_followup = {
        id = 394879,
        duration = 15,
        max_stack = 1
    },
    brutal_opportunist = {
        id = 394888,
        duration = 15,
        max_stack = 1
    },

    -- Legendary from Legion
    master_assassins_initiative = {
        id = 235027,
        duration = 3600
    },
})

--------------------------------------------------------------------------------
-- Define supercharge expression to avoid errors in APL
--------------------------------------------------------------------------------
for i = 1, 7 do
    spec:RegisterStateExpr("supercharge_" .. i, function()
        -- Return true if we have at least i stacks of supercharged_combo_points.
        return buff.supercharged_combo_points.stack >= i
    end)
end

--------------------------------------------------------------------------------
-- Additional State Expressions for Master Assassin, etc.
--------------------------------------------------------------------------------
spec:RegisterStateExpr("mantle_duration", function()
    return legendary.mark_of_the_master_assassin.enabled and 4 or 0
end)

spec:RegisterStateExpr("master_assassin_remains", function()
    if not legendary.mark_of_the_master_assassin.enabled then
        return 0
    end
    if stealthed.mantle then
        return cooldown.global_cooldown.remains + 4
    elseif buff.master_assassins_mark.up then
        return buff.master_assassins_mark.remains
    end
    return 0
end)

spec:RegisterStateExpr("cp_gain", function()
    return (this_action and class.abilities[this_action].cp_gain) or 0
end)

spec:RegisterStateExpr("effective_combo_points", function()
    local c = combo_points.current or 0
    if c > 0 and buff.supercharged_combo_points.up then
        c = c + (talent.forced_induction.enabled and 3 or 2)
    end
    return c
end)

--------------------------------------------------------------------------------
-- Register a few set bonuses, if relevant
--------------------------------------------------------------------------------
spec:RegisterGear("tww2", 229290, 229288, 229289, 229287, 229292)
spec:RegisterAuras({
    winning_streak = {
        id = 1217078,
        duration = 3600,
        max_stack = 10,
    },
})

spec:RegisterGear("tier31", 207234, 207235, 207236, 207237, 207239,
                  217208, 217210, 217206, 217207, 217209)
spec:RegisterAuras({
    soulrip = {
        id = 409604,
        duration = 8,
        max_stack = 1
    },
    soulripper = {
        id = 409606,
        duration = 15,
        max_stack = 1
    },
})
spec:RegisterGear("tier30", 202500, 202498, 202497, 202496, 202495)
spec:RegisterAuras({
    vicious_followup = {
        id = 394879,
        duration = 15,
        max_stack = 1
    },
    brutal_opportunist = {
        id = 394888,
        duration = 15,
        max_stack = 1
    }
})
spec:RegisterGear("tier29", 200372, 200374, 200369, 200371, 200373)
spec:RegisterAuras({
    snake_eyes = {
        id = 275863,
        duration = 30,
        max_stack = 1,
    }
})

--------------------------------------------------------------------------------
-- Fan the Hammer / Roll the Bones Logging
--------------------------------------------------------------------------------
local lastShot, numShots = 0, 0
local lastRoll, rollDuration = 0, 30

spec:RegisterCombatLogEvent(function(_, subtype, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID)
    -- Only process if it's from us
    if sourceGUID ~= state.GUID then return end

    -- Fan the Hammer logic
    if spellID == 185763 and subtype == "SPELL_CAST_SUCCESS" then
        local now = GetTime()
        if (now - lastShot) > 0.5 then
            -- fresh cast
            local _, _, oppoStacks = FindPlayerAuraByID(195627)
            oppoStacks = oppoStacks or 1
            oppoStacks = oppoStacks - 1
            lastShot = now
            numShots = min(state.talent.fan_the_hammer.rank, oppoStacks, 2)
            Hekili:ForceUpdate("FAN_THE_HAMMER", true)
        elseif numShots > 0 then
            numShots = max(0, numShots - 1)
        end
        return
    end

    -- Roll the Bones tracking
    if spellID == 315508 then
        local now = GetTime()
        if subtype == "SPELL_AURA_APPLIED" then
            lastRoll = now
            rollDuration = 30
        elseif subtype == "SPELL_AURA_REFRESH" then
            local pandemicExtension = min(9, 60 - (now - lastRoll))
            rollDuration = 30 + pandemicExtension
            lastRoll = now
        end
        if Hekili.ActiveDebug then
            Hekili:Debug("Updated lastRoll to %.2f, rollDuration to %.2f", lastRoll, rollDuration)
        end
    end
end)

--------------------------------------------------------------------------------
-- More State Expressions for Roll the Bones
--------------------------------------------------------------------------------
spec:RegisterStateExpr("rtb_buffs", function()
    return buff.roll_the_bones.count
end)

spec:RegisterStateExpr("rtb_primary_remains", function ()
    -- Just rely on lastRoll + rollDuration from the CombatLog event.
    return max(0, (lastRoll + rollDuration) - query_time)
end)

--[[ Caching `local b = buff` inside these expressions so we don't do repeated buff lookups. ]]

spec:RegisterStateExpr("rtb_buffs_shorter", function()
    local b = buff
    local n = 0
    local primary = rtb_primary_remains
    for _, rtbName in ipairs(rtb_buff_list) do
        local bone = b[rtbName]
        if bone.up and (bone.remains < (primary - 0.2)) then
            n = n + 1
        end
    end
    return n
end)

spec:RegisterStateExpr("rtb_buffs_normal", function()
    local b = buff
    local n = 0
    local primary = rtb_primary_remains
    for _, rtbName in ipairs(rtb_buff_list) do
        local bone = b[rtbName]
        if bone.up and abs(bone.remains - primary) <= 0.2 then
            n = n + 1
        end
    end
    return n
end)

spec:RegisterStateExpr("rtb_buffs_min_remains", function()
    local b = buff
    local r = 3600
    for _, rtbName in ipairs(rtb_buff_list) do
        local remains = b[rtbName].remains
        if remains > 0 then
            r = min(r, remains)
        end
    end
    return (r == 3600) and 0 or r
end)

spec:RegisterStateExpr("rtb_buffs_max_remains", function()
    local b = buff
    local r = 0
    for _, rtbName in ipairs(rtb_buff_list) do
        local remains = b[rtbName].remains
        r = max(r, remains)
    end
    return r
end)

spec:RegisterStateExpr("rtb_buffs_longer", function()
    local b = buff
    local n = 0
    local primary = rtb_primary_remains
    for _, rtbName in ipairs(rtb_buff_list) do
        local bone = b[rtbName]
        if bone.up and (bone.remains > (primary + 0.2)) then
            n = n + 1
        end
    end
    return n
end)

spec:RegisterStateExpr("rtb_buffs_will_lose", function()
    local count = 0
    if rtb_buffs_will_lose_buff.broadside then count = count + 1 end
    if rtb_buffs_will_lose_buff.buried_treasure then count = count + 1 end
    if rtb_buffs_will_lose_buff.grand_melee then count = count + 1 end
    if rtb_buffs_will_lose_buff.ruthless_precision then count = count + 1 end
    if rtb_buffs_will_lose_buff.skull_and_crossbones then count = count + 1 end
    if rtb_buffs_will_lose_buff.true_bearing then count = count + 1 end
    return count
end)

spec:RegisterStateTable("rtb_buffs_will_lose_buff", setmetatable({}, {
    __index = function(t, k)
        return buff[k].up and (buff[k].remains <= (rtb_primary_remains + 0.1))
    end
}))

spec:RegisterStateTable("rtb_buffs_will_retain_buff", setmetatable({}, {
    __index = function(t, k)
        return buff[k].up and not rtb_buffs_will_lose_buff[k]
    end
}))

spec:RegisterStateExpr("cp_max_spend", function()
    return combo_points.max
end)

--------------------------------------------------------------------------------
-- Force Update on Combo Points
--------------------------------------------------------------------------------
spec:RegisterUnitEvent("UNIT_POWER_UPDATE", "player", nil, function(event, unit, resource)
    if resource == "COMBO_POINTS" then
        Hekili:ForceUpdate(event, true)
    end
end)

--------------------------------------------------------------------------------
-- Hooks
--------------------------------------------------------------------------------
local restless_blades_list = {
    "adrenaline_rush",
    "between_the_eyes",
    "blade_flurry",
    "blade_rush",
    "ghostly_strike",
    "grappling_hook",
    "keep_it_rolling",
    "killing_spree",
    "roll_the_bones",
    "sprint",
    "vanish"
}

spec:RegisterHook("runHandler", function(ability)
    local t = state.talent
    local b = state.buff
    local l = state.legendary
    local a = class.abilities[ability]

    -- Break stealth if the cast starts combat
    if stealthed.all and (not a or a.startsCombat) then
        if b.stealth.up then
            setCooldown("stealth", 2)
            if b.take_em_by_surprise.up then
                b.take_em_by_surprise.expires = query_time + 10 * t.take_em_by_surprise.rank
            end
            if t.subterfuge.enabled then
                applyBuff("subterfuge")
            end
        end
        if l.mark_of_the_master_assassin.enabled and stealthed.mantle then
            applyBuff("master_assassins_mark")
        end

        removeBuff("stealth")
        removeBuff("shadowmeld")
        removeBuff("vanish")
    end

    if b.cold_blood.up 
       and ((ability == "ambush" or not t.inevitable_end.enabled) and (not a or a.startsCombat)) then
        removeStack("cold_blood")
    end

    local nextPoison = action.apply_poison_actual.next_poison
    class.abilities.apply_poison = class.abilities[nextPoison]
end)

spec:RegisterHook("spend", function(amt, resource)
    if amt > 0 and resource == "combo_points" then
        local t = state.talent
        local b = state.buff
        local l = state.legendary

        if amt >= 5 and t.ruthlessness.enabled then
            gain(1, "combo_points")
        end
        local cdr = amt * (b.true_bearing.up and 1.5 or 1)
        for _, actionName in ipairs(restless_blades_list) do
            reduceCooldown(actionName, cdr)
        end
        if t.float_like_a_butterfly.enabled then
            reduceCooldown("evasion", amt * 0.5)
            reduceCooldown("feint", amt * 0.5)
        end
        if l.obedience.enabled and b.flagellation_buff and b.flagellation_buff.up then
            reduceCooldown("flagellation", amt)
        end
    end
end)

--------------------------------------------------------------------------------
-- reset_precast
--------------------------------------------------------------------------------
spec:RegisterHook("reset_precast", function()
    local query_time = state.query_time
    local t = state.talent
    local b = state.buff
    local gcdRemains = gcd.remains

    -- Supercharged Combo Points
    if t.supercharger.enabled then
        local cPoints = GetUnitChargedPowerPoints("player")
        if cPoints then
            local charged = 0
            for _ in pairs(cPoints) do
                charged = charged + 1
            end
            if charged > 0 then
                applyBuff("supercharged_combo_points", nil, max(b.supercharged_combo_points.stack, charged))
            end
        end
    end

    if b.killing_spree.up then
        setCooldown("global_cooldown", max(gcdRemains, b.killing_spree.remains))
    end

    if b.adrenaline_rush.up and t.improved_adrenaline_rush.enabled then
        state:QueueAuraExpiration("adrenaline_rush", function()
            gain(energy.max, "energy")
        end, b.adrenaline_rush.expires)
    end

    if b.cold_blood.up then
        setCooldown("cold_blood", action.cold_blood.cooldown)
    end

    local nextPoison = action.apply_poison_actual.next_poison
    class.abilities.apply_poison = class.abilities[nextPoison]

    local debugActive = Hekili.ActiveDebug
    if debugActive and b.roll_the_bones.up then
        Hekili:Debug("\nRoll the Bones Debugging:")
        Hekili:Debug(" - lastRoll: %.2f", lastRoll)
        Hekili:Debug(" - rollDuration: %.2f", rollDuration)
        Hekili:Debug(" - rtb_primary_remains: %.2f", rtb_primary_remains)
        for i = 1, #rtb_buff_list do
            local boneName = rtb_buff_list[i]
            local bone = b[boneName]
            if bone.up then
                local boneDur = bone.duration
                local status
                if boneDur < rollDuration then
                    status = "shorter"
                elseif boneDur > rollDuration then
                    status = "longer"
                else
                    status = "normal"
                end
                Hekili:Debug("   * %-20s %5.2f : %5.2f %s",
                             boneName, bone.remains, boneDur, status)
            end
        end
    end

    -- Handle leftover Fan the Hammer shots
    local now = query_time
    if (now - lastShot) < 0.5 and numShots > 0 then
        local toGain = action.pistol_shot.cp_gain
        local gainedCP = numShots * (toGain - 1)
        if debugActive then
            Hekili:Debug("Generating %d combo points from pending Fan the Hammer; removing %d stacks of Opportunity.",
                         gainedCP, numShots)
        end
        gain(gainedCP, "combo_points")
        removeStack("opportunity", numShots)
    end

    if t.underhanded_upper_hand.enabled and b.adrenaline_rush.up then
        if b.subterfuge.up then
            b.adrenaline_rush.expires = b.adrenaline_rush.expires + b.subterfuge.remains
        end
        if b.blade_flurry.up then
            b.blade_flurry.expires = b.blade_flurry.expires + b.adrenaline_rush.remains
        end
    end
end)

--------------------------------------------------------------------------------
-- Register Cycle if needed
--------------------------------------------------------------------------------
spec:RegisterCycle(function()
    -- (Optional cycle logic, if any. If you cycle through marked_for_death, etc.)
end)

--------------------------------------------------------------------------------
-- Register Outlaw Abilities
--------------------------------------------------------------------------------
spec:RegisterAbilities({
    adrenaline_rush = {
        id = 13750,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        talent = "adrenaline_rush",
        startsCombat = false,
        texture = 136206,
        toggle = "cooldowns",

        cp_gain = function()
            return talent.improved_adrenaline_rush.enabled and combo_points.max or 0
        end,

        handler = function()
            applyBuff("adrenaline_rush")

            if talent.improved_adrenaline_rush.enabled then
                gain(action.adrenaline_rush.cp_gain, "combo_points")
                state:QueueAuraExpiration("adrenaline_rush", function()
                    gain(energy.max, "energy")
                end, buff.adrenaline_rush.remains)
            end

            if talent.edge_case.enabled then
                addStack("fatebound_coin_heads")
                addStack("fatebound_coin_tails")
            end

            if talent.loaded_dice.enabled then
                applyBuff("loaded_dice")
            end

            if talent.underhanded_upper_hand.enabled and buff.subterfuge.up then
                buff.adrenaline_rush.expires =
                    buff.adrenaline_rush.expires + buff.subterfuge.remains
            end
        end,
    },

    between_the_eyes = {
        id = 315341,
        cast = 0,
        cooldown = function()
            return talent.crackshot.enabled and stealthed.rogue and 0 or 45
        end,
        gcd = "totem",
        school = "physical",
        spend = function()
            return 25 * (talent.tight_spender.enabled and 0.94 or 1)
        end,
        spendType = "energy",
        startsCombat = true,
        texture = 135610,

        usable = function()
            return combo_points.current > 0, "requires combo points"
        end,

        handler = function()
            if talent.alacrity.rank > 1 and effective_combo_points > 9 then
                addStack("alacrity")
            end

            applyBuff("between_the_eyes")

            -- If stealthed & crackshot, also Dispatch
            if stealthed.rogue and talent.crackshot.enabled then
                spec.abilities.dispatch.handler()
            end

            if set_bonus.tier30_4pc > 0 and (debuff.soulrip.up or active_dot.soulrip > 0) then
                removeDebuff("target", "soulrip")
                active_dot.soulrip = 0
                applyBuff("soulripper")
            end

            if legendary.greenskins_wickers.enabled 
               or (talent.greenskins_wickers.enabled and effective_combo_points >= 5) then
                applyBuff("greenskins_wickers")
            end

            spend(combo_points.current, "combo_points")
            removeStack("supercharged_combo_points")
        end,
    },

    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        school = "physical",
        spend = 15,
        spendType = "energy",
        startsCombat = false,

        handler = function()
            applyBuff("blade_flurry")
            if talent.deft_maneuvers.enabled then
                local addCP = true_active_enemies
                gain(addCP, "combo_points")
            end
            if talent.underhanded_upper_hand.enabled and buff.adrenaline_rush.up then
                buff.blade_flurry.expires = buff.blade_flurry.expires + buff.adrenaline_rush.remains
            end
        end,
    },

    blade_rush = {
        id = 271877,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "physical",
        talent = "blade_rush",
        startsCombat = true,

        usable = function()
            if not settings.check_blade_rush_range then return true end
            local maxRange = talent.acrobatic_strikes.enabled and 9 or 6
            return (target.distance < maxRange), "target out of blade_rush range"
        end,

        handler = function()
            applyBuff("blade_rush")
            setDistance(5)
        end,
    },

    coup_de_grace = {
        id = 441423,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function()
            local base = 35
            if talent.tight_spender.enabled then base = base * 0.94 end
            return base - (5 * buff.summarily_dispatched.stack)
        end,
        spendType = "energy",

        startsCombat = true,

        usable = function()
            return combo_points.current > 0 
                   and talent.coup_de_grace.enabled 
                   and buff.escalating_blade.stack == 4,
                   "requires combo points & 4 stacks of escalating_blade"
        end,

        handler = function()
            local expiration = query_time + 1.5
            state:QueueAuraExpiration("escalating_blade", function()
                removeStack("escalating_blade", 4)
            end, expiration)

            if talent.summarily_dispatched.enabled and (combo_points.current > 5) then
                addStack("summarily_dispatched", buff.summarily_dispatched.remains, 1)
            end

            if buff.slice_and_dice.up then
                buff.slice_and_dice.expires = buff.slice_and_dice.expires + (combo_points.current * 3)
            else
                applyBuff("slice_and_dice", combo_points.current * 3)
            end

            if set_bonus.tier29_2pc > 0 then
                applyBuff("vicious_followup")
            end

            spend(combo_points.current, "combo_points")
            removeStack("supercharged_combo_points")
        end,
    },

    dismantle = {
        id = 207777,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        spend = 25,
        spendType = "energy",
        pvptalent = "dismantle",
        startsCombat = true,

        handler = function()
            applyDebuff("target", "dismantle")
        end,
    },

    dispatch = {
        id = 2098,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",
        spend = function()
            local base = 35
            if talent.tight_spender.enabled then base = base * 0.94 end
            return base - (5 * buff.summarily_dispatched.stack)
        end,
        spendType = "energy",
        startsCombat = true,

        usable = function()
            if talent.coup_de_grace.enabled and buff.escalating_blade.stack == 4 then
                return false, "coup_de_grace ready instead"
            end
            return combo_points.current > 0, "requires combo points"
        end,

        handler = function()
            removeBuff("brutal_opportunist")

            if talent.alacrity.rank > 1 and effective_combo_points > 9 then
                addStack("alacrity")
            end

            if talent.summarily_dispatched.enabled and combo_points.current > 5 then
                addStack("summarily_dispatched", buff.summarily_dispatched.remains, 1)
            end

            if buff.slice_and_dice.up then
                buff.slice_and_dice.expires = buff.slice_and_dice.expires + combo_points.current * 3
            else
                applyBuff("slice_and_dice", combo_points.current * 3)
            end

            if set_bonus.tier29_2pc > 0 then
                applyBuff("vicious_followup")
            end

            spend(combo_points.current, "combo_points")
            removeStack("supercharged_combo_points")
        end,
    },

    ghostly_strike = {
        id = 196937,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "physical",

        spend = 30,
        spendType = "energy",

        talent = "ghostly_strike",
        startsCombat = true,

        cp_gain = function()
            return 1 + (buff.broadside.up and 1 or 0)
        end,

        handler = function()
            applyDebuff("target", "ghostly_strike")
            gain(action.ghostly_strike.cp_gain, "combo_points")
        end,
    },

    grappling_hook = {
        id = 195457,
        cast = 0,
        cooldown = function() 
            local baseCD = talent.retractable_hook.enabled and 45 or 60
            local qdMod = conduit.quick_decisions and (1 - conduit.quick_decisions.mod * 0.01) or 1
            return baseCD * qdMod
        end,
        gcd = "off",
        school = "physical",
        startsCombat = false,

        handler = function()
            -- purely positional
        end,
    },

    keep_it_rolling = {
        id = 381989,
        cast = 0,
        cooldown = 360,
        gcd = "off",
        school = "physical",
        talent = "keep_it_rolling",
        startsCombat = false,
        toggle = "cooldowns",
        buff = "roll_the_bones",

        handler = function()
            for _, v in pairs(rtb_buff_list) do
                local bAura = buff[v]
                if bAura.up then
                    local newExpires = bAura.expires + 30
                    local capExpires = min(newExpires, query_time + 60)
                    bAura.expires = capExpires
                end
            end
        end,
    },

    killing_spree = {
        id = 51690,
        cast = 0,
        cooldown = 90,
        gcd = "totem",
        school = "physical",
        talent = "killing_spree",
        startsCombat = true,
        toggle = "cooldowns",

        usable = function()
            return combo_points.current > 0, "requires combo points"
        end,

        handler = function()
            setCooldown("global_cooldown", 0.4 * combo_points.current)
            applyBuff("killing_spree")
            spend(combo_points.current, "combo_points")
            removeStack("supercharged_combo_points")

            if talent.flawless_form.enabled then
                addStack("flawless_form")
            end
            if talent.disorienting_strikes.enabled then
                applyBuff("disorienting_strikes", nil, 2)
                if Hekili.ActiveDebug then
                    Hekili:Debug("Killing Spree granted 2 stacks of Disorienting Strikes.")
                end
            end
        end,
    },

    pistol_shot = {
        id = 185763,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function()
            return 40 - (buff.opportunity.up and 20 or 0)
        end,
        spendType = "energy",
        startsCombat = true,

        cp_gain = function()
            local base = 1 + (buff.broadside.up and 1 or 0)
            if buff.shadow_blades.up then
                return combo_points.max
            else
                if talent.quick_draw.enabled and buff.opportunity.up then
                    base = base + 1
                end
                if buff.concealed_blunderbuss.up then
                    base = base + 2
                end
            end
            return base
        end,

        handler = function()
            local toGain = action.pistol_shot.cp_gain
            gain(toGain, "combo_points")

            removeBuff("deadshot")
            removeBuff("concealed_blunderbuss")
            removeBuff("greenskins_wickers")
            removeBuff("tornado_trigger")

            if buff.opportunity.up then
                removeStack("opportunity")
                if set_bonus.tier29_4pc > 0 then
                    applyBuff("brutal_opportunist")
                end
            end

            if talent.fan_the_hammer.enabled then
                local shots = min(talent.fan_the_hammer.rank, buff.opportunity.stack)
                gain(shots * (toGain - 1), "combo_points")
                removeStack("opportunity", shots)
            end
        end,
    },

    roll_the_bones = {
        id = 315508,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        school = "physical",
        spend = 25,
        spendType = "energy",
        startsCombat = false,

        handler = function()
            local pandemic = 0
            for _, name in pairs(rtb_buff_list) do
                if rtb_buffs_will_lose_buff[name] then
                    pandemic = min(9, max(pandemic, buff[name].remains))
                    removeBuff(name)
                end
            end

            if talent.supercharger.enabled then
                addStack("supercharged_combo_points", nil, talent.supercharger.rank)
            end

            if azerite.snake_eyes.enabled then
                applyBuff("snake_eyes", nil, 5)
            end

            applyBuff("rtb_buff_1", nil, 30 + pandemic)
            if buff.loaded_dice.up then
                applyBuff("rtb_buff_2", nil, 30 + pandemic)
                removeBuff("loaded_dice")
            end
            if pvptalent.take_your_cut.enabled then
                applyBuff("take_your_cut")
            end
        end,
    },

    shiv = {
        id = 5938,
        cast = 0,
        cooldown = 25,
        gcd = "totem",
        school = "physical",
        spend = function()
            return legendary.tiny_toxic_blade.enabled and 0 or 20
        end,
        spendType = "energy",
        talent = "shiv",
        startsCombat = true,

        cp_gain = function()
            return 1 + (buff.shadow_blades.up and 1 or 0)
                   + (buff.broadside.up and 1 or 0)
        end,

        handler = function()
            gain(action.shiv.cp_gain, "combo_points")
            removeDebuff("target", "dispellable_enrage")
        end,
    },

    shroud_of_concealment = {
        id = 114018,
        cast = 0,
        cooldown = 360,
        gcd = "totem",
        school = "physical",
        startsCombat = false,
        toggle = "interrupts",

        handler = function()
            applyBuff("shroud_of_concealment")
        end,
    },

    sinister_strike = {
        id = 193315,
        known = 1752,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        spend = 45,
        spendType = "energy",
        startsCombat = true,
        texture = 136189,

        cp_gain = function()
            return 1 + (buff.broadside.up and 1 or 0)
        end,

        handler = function()
            gain(action.sinister_strike.cp_gain, "combo_points")
            removeStack("snake_eyes")

            if talent.unseen_blade.enabled and debuff.unseen_blade.down then
                applyDebuff("target", "fazed")
                applyDebuff("player", "unseen_blade")
                if buff.escalating_blade.stack == 3 then
                    removeBuff("escalating_blade")
                    applyBuff("coup_de_grace")
                else
                    addStack("escalating_blade")
                end
            end

            if talent.echoing_reprimand.enabled then
                removeBuff("echoing_reprimand")
            end

            if buff.disorienting_strikes.up then
                removeStack("disorienting_strikes")
                if Hekili.ActiveDebug then
                    Hekili:Debug("Sinister Strike consumed 1 stack of Disorienting Strikes.")
                end
            end
        end,

        copy = 1752,
        bind = function()
            return buff.audacity.down and "ambush" or nil
        end,
    },

    smoke_bomb = {
        id = 212182,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        pvptalent = "smoke_bomb",
        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            applyBuff("smoke_bomb")
        end,
    },
})

--------------------------------------------------------------------------------
-- Example override for shadowmeld if you need it
--------------------------------------------------------------------------------
spec:RegisterAbility("shadowmeld", {
    id = 58984,
    cast = 0,
    cooldown = 120,
    gcd = "off",
    usable = function()
        return boss and group
    end,
    handler = function()
        applyBuff("shadowmeld")
    end,
})

--------------------------------------------------------------------------------
-- Ranges
--------------------------------------------------------------------------------
spec:RegisterRanges("pick_pocket", "kick", "blind", "shadowstep")

--------------------------------------------------------------------------------
-- Register Options
--------------------------------------------------------------------------------
spec:RegisterOptions({
    enabled = true,
    aoe = 3,
    cycle = false,
    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,
    damage = true,
    damageExpiration = 6,
    potion = "tempered_potion",
    package = "Outlaw",
})

spec:RegisterSetting("check_blade_rush_range", true, {
    name = strformat("%s: Melee Only", Hekili:GetSpellLinkWithTexture(spec.abilities.blade_rush.id)),
    desc = strformat("If checked, %s will not be recommended out of melee range.",
                     Hekili:GetSpellLinkWithTexture(spec.abilities.blade_rush.id)),
    type = "toggle",
    width = "full",
})

spec:RegisterSetting("allow_shadowmeld", false, {
    name = strformat("%s: Use in Groups", Hekili:GetSpellLinkWithTexture(58984)),
    desc = strformat("If checked, %s may be recommended for Night Elves when its conditions are met. Your stealth-based abilities can be used in %s, even if your action bar does not change. %s can only be recommended in boss fights or when you are in a group, to avoid resetting combat.",
                     Hekili:GetSpellLinkWithTexture(58984),
                     Hekili:GetSpellLinkWithTexture(58984),
                     Hekili:GetSpellLinkWithTexture(58984)),
    type = "toggle",
    width = "full",
    get = function()
        return not Hekili.DB.profile.specs[260].abilities.shadowmeld.disabled
    end,
    set = function(_, val)
        Hekili.DB.profile.specs[260].abilities.shadowmeld.disabled = not val
    end,
})

spec:RegisterSetting("solo_vanish", true, {
    name = strformat("Allow %s When Solo", Hekili:GetSpellLinkWithTexture(1856)),
    desc = strformat("If enabled, %s can be recommended even when you are alone, |cFFFF0000which may reset combat|r.",
                     Hekili:GetSpellLinkWithTexture(1856)),
    type = "toggle",
    width = "full",
})

spec:RegisterSetting("vanish_charges_reserved", 0, {
    name = strformat("Reserve %s Charges", Hekili:GetSpellLinkWithTexture(1856)),
    desc = strformat("If set above zero, %s will not be recommended if it would leave you with fewer than this number of (fractional) charges.",
                     Hekili:GetSpellLinkWithTexture(1856)),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = 1.5,
})

local assassin = class.specs[259]
spec:RegisterSetting("sinister_clash", -0.5, {
    name = strformat("%s: Clash Buffer", Hekili:GetSpellLinkWithTexture(spec.abilities.sinister_strike.id)),
    desc = strformat("If set below zero, %s will not be recommended when a higher priority ability is available within the time specified.\n\nExample: %s is ready in 0.3 seconds.  |W%s|w is ready immediately.  Clash Buffer is set to |W|cFF00B4FF-0.5s|r.|w  |W%s|w will not be recommended as it pretends to be unavailable for 0.5 seconds.\n\nRecommended: |cFF00B4FF-0.5s|r",
                     Hekili:GetSpellLinkWithTexture(spec.abilities.sinister_strike.id),
                     Hekili:GetSpellLinkWithTexture(assassin.abilities.ambush.id),
                     spec.abilities.sinister_strike.name,
                     spec.abilities.sinister_strike.name),
    type = "range",
    min = -3,
    max = 3,
    step = 0.1,
    get = function()
        return Hekili.DB.profile.specs[260].abilities.sinister_strike.clash
    end,
    set = function(_, val)
        Hekili.DB.profile.specs[260].abilities.sinister_strike.clash = val
    end,
    width = 1.5,
})

spec:RegisterPack( "Outlaw", 20250102, [[Hekili:T3Z6YTTTs)S4PZOyvBRijBNM2X2Z0K2(1KEj9RQ90)jkisilwlrQYl2XZ4rp7NDbiaXvsAB5C5Co)iX2KGla2DXENlNoA6FmDsePGo9xhpC8PdhnC8GrF9WJhpDsXTBOtNSHeEf5s4xsiRH))DLfRi3Gx(2vPKi8PZtlZcHBTSOyt(388NFzCXYY5dctx)8841LRifXPjHzKff4Fh(8PtMxgVQ4njtN7AQhD8XtNqklwMMnDYK41VgGCCueLpCAE40j4WpA4OJgo(B2o7B3Sz1TBNToopNgTDg(eBNvUbbC(2z7xSKKCf8lV5n0)ytAy)bBF723ca4KJgn8OXhday0ObdhCQ8Yd)6Jg(Yd3od(5OHv)80VrhWAdgHXVLgNNMKxF9xE04t5p8WrYhoRyEqgnlD1QTZkUHsUsB84M53P5BOHfBN9ZF32zVBdnHMTDwoTOio5s1bZwr)c5VtHBNrVoopgN9zlYsxxnzkdE4xdd(p5l8zlItIZxIGnmnjkUOXh8fQlP)fbFYTZEnS0UzjnHbH84iAgU4M9QIVhUoq7HrKbmn5ltlQb2xD04xca7pwclH)IaZ(FbJmoz6KvX5f5iBeFHb)2VY4jPjK5ROrtFfWmeIRsGTHcinAsqXsAa9wAoNDilEd)2)zoa7xXhdGFXz67Vf5bks3o7kkDt1fHNa2nZlxSajNhI)k83PS9t6QO0BGFlgU3BwVjl9AA0Z))YaiMFvCsomyscWKrUong(bC3SS4i22VEqtNGZaGvitNShmNKv0KIbHcCYGQD22z9a2t(czG5wBqgDnjgPmNTD2jBND3DsafxTScSEgjGvg9LYLvWnXHxrZugwF2syVQLGJrwUzAbC48HroQzcMHN3JG9sPpkuAzbYib)cG3NuqjRq2iKULrxKrrUo2OD9SQKt84aJqgjyfzd83bPjRO5WG)TmAi7Wc)jujvDIoLvbPGncabijocVZ0XAEcKPmiUiaLiamr6eW6HTMsscYlYabgkepK0CmsAe0JqG5ny(Q00ivYfmQt0hv5MGiAWLW(KAmWtvhyuC(gsr4s9XuaI(HTE665Kc5zvXJqqrXbByYcnaTjtexBcWltZwasxci5H0Kiss4Tb50SY11aTHXiWaoyoZ5mrkRw4zqjEaB6yjsXXdsIYGRcKdAqwzUpayZ3ipwAaan2igpI5a4sC61oxr9qqvVWuffhsf32403RQoYXpf8tmPF45KFNd0TZGT1Msur03kxo4bf8O2C6I0mkFSIdEPjcjPOq)Y1W1(z2Iy7SVdwfaWxVMgfdQyqLXahpG)J4NNtfNxtOVhwbBajO01XHWzBa(s2ohKc8(StsZXzxfNZplQDBgA0p5(fDLCVJjSoxrJ4hKIOliLRkCPYtJwcAGfIer9sBsZZJHbcsLsa6X1LRaReiSla2lSogjuXmTz4S23(mHJJJAZ3Bsamqw5glTIi5NSAv6nGnja9MXhfJdMpd51cDbHdYP9kqBIRJQPBGLevzGxta8oCx83wvc)yFjdp3cWG0nBsZkktIlUvxyjUxtrjpjfaNaDrCiYSFX5BNnE7SdS1DswpxJeEGq(DgWuJQIyI15kirJWU8wo0oDiBzgWfFXHsG0qkxYvAFxQU25Zs4MG1K3ha2DHgBCeyIk7)b0rfjKgnGGNn71K5fiErbdch7csxeSaoI60sHfGD9mvBWH)1Mgj0bYGIwsszejeVPMUr1NQc723LjCcluZ5S7eGqE0iHjQaEPIAJhequ2HC1(hnMZ1lTEWWu0bCtoRefbGhaaOsLIp)pY2wOb3YvyTrlKv5PIfv1QzmFL9TvBt(cq7HJXhei4xtv5x4arNFXu4x78laBbk4JKDjfy2NVcKchSyvzw2TmRmgZifzK4Oa61irJefLparnxa3COQXkkpATHkWOUmmAaGOnioC0h4qxr8guyt1k4qeLI7xXcLV7dxsbJiJ4cnIaJLqZ7a3gky(EKNIAqE93bdeioLRIqToWVFBsivA72RW132z)aBbQIhvx4b4Z0Ke(q4Ksa)pcqNn4UCubPqqCm8SFvtId)X4lxI6lJtZy0wPWyeohIlw8O4ccxzzwA5LvcQts1DYIGkvxRsBTxBGzEXHfOcbfnrAN61w)kI0FPXEO(XfeMbw8FQtxNWxvoPbpXx)qq3SZu4tpAO3vlxC7G5KCAGMK8rNYKtxD)m6L0ef94zHeqVBrAgOdUGnf6MMYVpyYtUPvVJgRoWva1Uip4VlJUCncjJXQzX9CYLOivehEvULDYv0MaGhdg1IaGYtAY92Rz(xBW89o0Tg8jRfiDDLF4zLRysVwfVgWDOxPBaoW8sMCiGHefkjEMvGuqM660KkVSyIbxdkfiao7wHeEM)uvsmbqxcMQLHAoqWdagp6UK7bm(F5LZbI2Ism8qw2nP8SbShna)dxwZwdgT72MVZoT5cvSW1ej56n1sB6Evtk16lG2E12b5Yjps0T1RP2Cs0X952xjhH5Us1lYJR89Z0eoxbDO70a3O4gKCyW16W(Uh4cQnYEhOAkr1qZuKEoSejVaMegI16wmBW43Uxd8tUWfMwb(eHl6gtCnsdn(Br5QaWUstpl3VgNHJAEkS8cwvgE1TWonor5GLXyW7cwJeVkxGlzgkRWnBm2LWPfZX235WTN(UCmSVlcIPzwFSji71fAs1ikixb7W1bZbJDkZadrYTeuYqCUgx5gxydtBL6GTcwOFo04iDfFmxsG7UMYuZxRe0LEVomPtDfCRgcj5gyXfKrfzKqtt63NaifQAWP5HSgnwnb)R8RIbIoZs0qcluLOEsM3UCBoaZFsbtqPVNzWudbFQLiJAAqPROAY0E)AfvX03hsrpYzl1OyqZrbgPLuwSRXOMwJ47cMTDz)kceQjQsfz1MKMLEzjTsNKFXEDGeld4ydHeAdyljqIXfRbsfC75hicC4pswVMMPrRfwcfssuIHLUtBjkg3ZDbH5UjtufAP1RerhqKhagZXR)nHpO8NPota1(a2XWmlfjW5DwY2gdYijxjdMrd6WWr8cnP06HZONECsaLENZcTGuYRZuaurA9lYOvbEkwHZuDYLmGUE1G1WwbMZoqbQrUmJf5YyHHT80bGhTX8cYS8TmHNcGBtlR4ce(0xt6gZ)d(ad3Wb4QQ4CgXJZznmn0I0I9O71G5uMMK2Emh77oNqnfJsBA)yn1hQbvU5m)KdYUsmpaoHDrU)(lkZ4(5phKCUaDGRkbJH8KFIcS(Lu0)QY1yyyItUcDlUgDUV8QdkgnigmxG9KO3wRLphdbig1yFJQF9zgqn7k5DQ2JELHReJbJD6Va2Idg8KyeHcE0shZI2ilYiAUWRg0gRdZUJeZz1rIPHew0WcLhXMVJUOatwCcT8A4i9HI8WzV2RJ0lgMRtR3jvY3WRE8rNiVm)8H8eMwy5anw)tjzfNFGDMKSgmQdGWLGeXehcqaN9lcwlwMMw40SMmm0O2y4JT47RJn85wpH7yaZu2zd6tRel6trLrsCCj(Yrsz4sHij3YswiUAyKlvjxPjOA)LKRPkoZRQyYzYozAR(Jmur9ROemH9SW2HgDCdbxcaLjgiw)DzoQRSkbqmYgOJJIxmQmJWX3CHR03VbScjNR2KW4zkOR3ujbiDo)ecbSxHjj4sW0nXJYfg8Ao7aBsEhgJsvEcSujy7Fo6(ebvwE9G1GReQhvgjJ4TdQ4bn7AU42fagkyohbXUr150(EucUlO2hxtORuFDlZaLk8xbQoIGeGXpyA9GTZEZcZy)CSMUS7n7W9HjOwbW9HMFShtzQS2PbsQXi0OQcBLymm97mBLBZPAINQNpEQ(UI4SGtYmNN6jcSoHSZ5jKf5yyIf4ceWiolyM4w1GpWQ0C17b)4wEYx5SgCTe6zZLvxmCD1gtXibP3e(iN66uK1OAiUPTb4ZeWFe0gepMEygn7oHF(P387B1n0NN8g(g5gN7trf9ix9JLOPywkpbTtdCOTQPS07ypXUUcdoZ8RMIJEJB0F8Dg7ZfmdzzonwlOvqPPz6sCQ3HSTUngHlhIrIQhBuALZNszt0yUO9wLiHllDbs3l)hUx4untAToWUxRNz3Z9X2wsAHHT16PWTMOEjGub32XI5j(kADwkuGPgD(p4w3MVLLs96CLXOdycZkz18iOAMrELoVYOR8ZRlJVKrKQd3awrKyinkOApvxQjhn)DmYfntkzks57H8JxUSqrokszgxJhAUMEg5ZVJ1KOG)Pe9rnGN5c6JBjDQyp7aWYK94CDKehgCzwmyXAAw4YMxfsJ8nJxPW8YMxzgtfUU86kaLahodks5coO3MMe9ixBDc95CEXfQxRJJzcKGJhzuZ409tXvcRWkNbzGj5(5ILC8cxxY7uqNeN01tSkUInTWtBP9BzXRjz36AAnY3wj3JiIWz3YLLlpup3AgzqBaR4yrrUcyWT0N5RMiLF3SmEfT64pzvv8UvcB1HIkZveAdLDCDjjiu5zh(eCLVbxjSmAwqv2rCnPjuuEdABhBDbMZTbZUpg0lcl6iybBCnjEfIa3kTCKV(5c(Lr01krXTWO2LiN1Hq43CshzNgaAoblBDGdL5DTssIoPEuEc1tdr60oX9bvfGWOgRaHjSchZGZJLw3y0IfgNxQDIILoMR4eH0hG)un1U)jp1U)i8NhQf1ueYtQXupcQ3(QX3QnYKE0W8uBt71iTSVp0DDU4r8Up7m5rvXxKhRIDcVCjzMoc061y0oeflMwfnl1Wg6SkhkIxJvUqalyZxi4XCkEY0AXAaYfJJjizf40w7YVb)Rg2qgNvZB0Mu2pXacYSaQghbZwWIsmUt1RjCyALEXCAgOA)kMFX6dtRWlwaos6Q6LhRvYfGLcG7NzKvbHSAHrFO(umwfLWr2imF69uI(iOactdCXasYTbrBYBxXiGMMKVkfJaOCMXLNp1HvdA8dy5nENS8gp1SIvAk08oluL3SOsVuLQVReQXz64pSwhgQIWvgVIZTccjQLYPdfsfv)ftB3MvKBRMu0PuQqB1Yu0yz1j(gk3U4KNHr0IlmSmdXszO0rWzc0Hk8xjlyQ)yqSm30qtHtGQ2XygXYwtuDdbqqTA8KX(scqtFpvh9OthQ7xuqsAgt0eCZH2sobHVHlXiBMPk7SHG)7K6)VuWX2fuoZ0J5SuvYENoktQsCPiYM8nqvqKfKFwSSCAJc)H4waoc2t50WQaulm9W6KulvutpfSR3HIy3HnLZaNOMjkO4ADZC)5K(uZSMs)itT3EsR)QRF1CdGYFxMUVmPkqjyut5yW5g7NmwUAbKqSMzXYgvWzV9Kh4rBoGlTGvf73kJcETrlJoLr0xuST(Ljims3)BXrdTnR(bJMIxFRC1k8VHKn8fIytYrH5oxqvLjbl1tWXBoYMJqotSO8fw5wxumH7wNVO6E91GjaV0vOiVh(pDplgeE5F2usF55hU5YL4BzdQYS3gkD7hymMuQySMed6Vse4XtTU4WpWZQ8a7kw4qFLMasw3KLgQcxLJwcuISwwCki0D1fqT9nsIcCCVUGcnR0)EoRhVMKK2g2TZiom4bexXpq8QfOuHhCDi4nWewWJTnpbh3pSOpCW(oULsPByDpL6p05lrH6j5XEQaNDocvh9Wy2WxdwMmrZkHzeEjfhK0dH4Jcr6)f(zF28EG67(Y)ughEvqug5MAW79n(5lvFsNvIZbICh13(LpIBHD1tlmSlb(NH1v3)cCY0aBhuSc5BLTnDd90mIR2I77PmwrQm7eEvLzsnzJRAE))rK52zFxg2gaCzVXdJG6US)1l3FgXz0GtTr71Sav10K)K53apHYTDkc0HqSwsmCtfK4paoWoND6ghfd3YZ3k66YeuJlZdKjSCfujBNEn7n3hSkcxsmRTve9Re5T2voAulJ(TcOvb)w6Vf5VtAhq1MrK3dnV2zwgGv8bouStqCYOHGNYtUHKHEeaRuwtdiETYR1WZCfpNNH(raK1me1WFbJiLfPRjmCfy5vcyJ2GTV9NzEtGDLHxNMatm72pRXit9mUg4MhKaDadE)rVVFBZuDqRmGUD0S6ieLXjZaGwXpRJWZMIBay)SeMZW4pyyBpZ0dg3C8hSvUNzAxVY3Hu1t(GHB8mtpyCJh490JB0R2FdO7(vbWeYN(bdR7zMEWyDpWBhI19mdpDyDhVZfgGVH3EJ65y7BDOKJ719Z2fQ1EWKmpWZBtOXa(T2SA648zxz6gtK)(CJ5mSRvq4bEgXO1aQEQEOocBLgcJbCD0QyAHjRQjuC)4YE6vT4zgmAGd(420BVdDu08dMdWNYesDhxWepqSBgdDeQATPbtjzUAHdDeU7eANtomzdq5(XJ5zD67vDWlRG73iIoIv2jNI9aBLIzZaUoAVpMW8fFGWooPOvEFD)ON7AZB31gN4bJ(0DUa8D9(HbBtx8UIM)Xy2S00vLGBpV8pYzRLxsOUonEE7HSMg)JRlN41FdxmWyUF9xmH8lFcLt91pHNaQ4P8Ci7bFO1haFcCgY3u9yIJZx9HB17zQE4yEpa8rGogBDSrkeWSixCC(3Xq0HULcd5z)wHUZH0bnKb7kz8AP1280TR873rP5Q1rGf9YU0qmHQhD6p6vRjCzrDxRAfguUrayTRxdjgvzrk2U64fbzzgMmWBOybPYRB(yrgu4bQwupLS(blFCSeUSaBgfQJokchCePGGPR4BaEaS9SPTo8WxWc((oHJyhkv2JxM65XXa6UtYthHSi)jgW0mNlDeA7qmHh(5DaMWB4aFQGCD(TmGQDIV6ievZMPbmDLOttO6n0CpAmGhnr7e(ITV9nSdWiGFPUGc8ik2EptxeJ1zb)w5dKU7EW5pxTH4U9TUgbiicSmJU(qSoLp3)7fJ7Nwu2)w9y0ZhV9TFX2zFU0fyDV7mCDW1U8W4fNxrn95XrpN1)hw1s9eQK0npwCzfVWDV(0Ff98T84L4zQvVQ9HUNh9O2Zih9xWAQ7IxKGhqlLvU0RzbzqDN04yvbo26yv)BrbPXpTy2iUoK1GmpFFVhVV7ox1mWfNp(al8jd0hyvcb97XRhHlo)0HST8)b2Xs9JWnldWkeUks9IZvFZhpA0r7R9smioBjDV4U7KKlLyIE3DcfaQr0SFpVu2E7Bwyg3DNJInPFFgr7JBNm1p(1QVMwHG93XxpBCp7o96fJhwT7D1xrU4YWi1LG5BYdFPGVEriQAN38tBFQfk149MuU8o93NOwbbNrvdc(RL1wHg7CL6W0B2Oi0Du9sxC(OtpqR6LSHaRDKQEDJUpQ6T0A2OmX4cf8OGhx0QUwOS1AIy)nU8ypPIIghN4SQeQ6twFIu7R27lLQRtzZPBLzpdVrAqOJdjm92Rb8sN3Y7MQw9bU)DTR23DHREX5(lAvhcGRKaD24(peKYJRYt3Lid3wrS)Od23YhlhMq8L7727gS4spyu)(6wPC25o8XIJ)(eSIqBflV39an7sOQQa1VC0GtDBs3zNpYgXlnQW2dy5TmdbH9XzoQ)JATB6ajRwMPhkQSZZh9GKSB)qg1VPq5ZRLV87slH)y3s(Qx7GbmoCNc5aD6BeYVTNxBeU7U9AXJR(swiV(KPFQECfRLrlnbXKp6oPNjwG3V(Wn)(TKxnyx0CgX6ZpQA2j9yR7U2x8mxEQwPYm2t1CxW7SEETL9mMTSsvjFs2P7AB3wX2ON(VE(5f7TVb(54EUebQJfDjn0amN2V(y8)R10z0MYmjIgHmcPJYx42lo)KE7l)RbknuSZgbU7Arj40gNDKi(TmAfrWjI(DHw9F3nwU7hf74EM0fMnSEjnk31U7YDXO(nWayr)75N(3Zf9Nt7)mRxWzsomIDQk1yGSdXD25(ur(K1P3AFD6jOXowP9KBPZQIh)N99TToJE85TCdyOkdI0oASxdNn2Z1HdZfOEhxdxGAMHP9L2cPqFi74AMR1UMliMvSAredKQKMN3t7f8gWOJBEgS76zDfYN2gG1BAz2GTYKo72BYD3D)MkxTES7105z7HYyECnImlfqQf(qJrKS3EgH78lWtL)VwpMig8pWwpMjbPXOpJvUJd(iZ0xiUG7IXsC3AunNr0D)f7StCN2oquxdbVg9x8tL2d29gdlF3nDGQ3FVgXT1UKRKlP9Sq4kgk)WAAxUDFtembpTXRloX6mSou4Tulz6Hv7BxofjDSiJooA6Cwlqrx5Y6oYgXL5DK9ElR4NO1UT8jko)qw7K6CrZUQEF5sIR)Q6ZJASHDCEh3T51Uy(8pV8aD9dY87wZm9X)7mEnwHlvGrH133QrCTwM1(UXrIn(j2HYYCSYry)Ax1VYUm3Flrq83NdFyW7iU1dQ1P9Qcp)AaTVNBFlQVHYR3vFhlX6pssoVPYh(Bh3x853rW0pXu(xLanT5PLmRcG5X)zxY1kWFaVDKh0D83xjxRhxmh(TVZMTHFMr77S0D3vRbH9nwQVRjwq1ANq8P8hijNKyNPNZYYlhjrtgYyh5R8fwb6bmVspY8Iy04ucMtIqNsQI(PkTKNuf78gmFZNX9DZmngPyY)1zVVyxY(qPULxbkYI5bw81HEKHOz16dGzzvLDCsiveZu(dMUEnU3wKLwH)lmkWCz3GRUQxCLL2)dRXyADEaTR)CoOvn)qZ93E71sZX0BmrffX0jyw4BUDyEXOthwhGPb82G5fdv9sO(nCG7NWNATXsNi3dWYgtGED6uG0RHET1ulVyeVmg)a2KkBFp5MLHRH04DarpqnFKAeLTVJAU9ucmQwCFDODtEpMwVnHYZCm1EBQKTpHoCJ6L(EQAJDAjyyoBYKv1X8NjFESDIdKb)qrA59nCs2o35les7797xCTarBZw6dMM(qfvlD5XZ37Apr0qk8Y2ulnSMtrgnJ4QXsTxnOp650M04p1iwvzKh7xpZ6YYYTRN)V35pHBj)Co12NR2DDeE645B8CLX5()4sFX5NwX24)JknwkdwdsFAAJNEhY6DVWz75gPvDvhDsirsWC(LFU1nXJte80jSki8DjtN8UYIvy7GmFdnC6Vo(fdzD1VP)7)]] )
