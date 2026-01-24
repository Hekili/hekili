-- Practice.lua
-- Practice mode functionality for Hekili

local addon, ns = ...
local Hekili = _G[ addon ]

local RegisterEvent = ns.RegisterEvent
local tableCopy = ns.tableCopy
local GetSpellInfo = ns.GetUnpackedSpellInfo

local LAST_COMMIT_TIMESTAMP = "2025-09-23 16:00:25"

-- Practice Mode Module
local Practice = {}
ns.Practice = Practice

-- Practice session data
local practiceSession = {
    active = false,
    inCombat = false,
    combatStart = 0,
    combatEnd = 0,
    expectedActions = {},
    actualActions = {},
    reportShown = false,
    currentRecommendation = nil,
    recommendations = {},
    processedCasts = {},
    unguidedCastTimes = {},
}

-- Configuration
local function getPracticeConfig()
    if not Hekili.DB or not Hekili.DB.profile then
        return {
            enabled = false,
            showReport = true,
            hideDisplaysInCombat = true,
            trackAllAbilities = true,
            accuracyThreshold = 2.0,
            reportDuration = 10,
        }
    end

    -- Ensure practice config exists
    if not Hekili.DB.profile.practice then
        Hekili.DB.profile.practice = {
            enabled = false,
            showReport = true,
            hideDisplaysInCombat = true,
            trackAllAbilities = true,
            accuracyThreshold = 2.0,
            reportDuration = 10,
        }
    end

    return Hekili.DB.profile.practice
end

local function isPracticeEnabled()
    if not Hekili.DB or not Hekili.DB.profile or not Hekili.DB.profile.toggles or not Hekili.DB.profile.toggles.practice then
        return false
    end
    return Hekili.DB.profile.toggles.practice.value
end

-- Practice session management
function Practice:StartSession()
    practiceSession.active = true
    practiceSession.inCombat = false
    practiceSession.expectedActions = {}
    practiceSession.actualActions = {}
    practiceSession.recommendations = {}
    practiceSession.reportShown = false
    practiceSession.currentRecommendation = nil
    table.wipe(practiceSession.processedCasts)
    table.wipe(practiceSession.unguidedCastTimes)

    -- Practice mode is controlled by toggle state

    Hekili:Print("|cFF00FF00Practice Mode enabled.|r Recommendations will hide during combat.")

    -- Also show prominent on-screen message
    UIErrorsFrame:AddMessage(
        "Practice Mode enabled",
        0.0, 1.0, 0.0, -- Green color
        1, -- UIErrorsFrame flags
        3  -- Hold time
    )
end

function Practice:EndSession()
    if not practiceSession.active then return end

    practiceSession.active = false
    if practiceSession.inCombat then
        self:ExitCombat()
    end
end

function Practice:EnterCombat()
    if not practiceSession.active then return end

    practiceSession.inCombat = true
    practiceSession.combatStart = GetTime()
    practiceSession.combatEnd = 0
    practiceSession.reportShown = false

    -- Clear previous session data and start fresh for combat
    table.wipe(practiceSession.expectedActions)
    table.wipe(practiceSession.actualActions)
    table.wipe(practiceSession.recommendations) -- Clear to start tracking during combat
    practiceSession.currentRecommendation = nil
    table.wipe(practiceSession.processedCasts)
    table.wipe(practiceSession.unguidedCastTimes)

end

function Practice:ExitCombat()
    if not practiceSession.active or not practiceSession.inCombat then return end

    practiceSession.inCombat = false
    practiceSession.combatEnd = GetTime()
    practiceSession.currentRecommendation = nil


    -- Calculate and show report
    if getPracticeConfig().showReport then
        self:ShowReport()
    end
end

function Practice:TrackRecommendation(primary, secondary, time, actionKey)
    if not practiceSession.active then return end

    if not practiceSession.inCombat then return end

    if not primary and not secondary and not actionKey then return end

    local timestamp = time or GetTime()
    local spellID, spellName

    if type(primary) == "number" then
        spellID = primary
    elseif type(secondary) == "number" then
        spellID = secondary
    end

    if type(primary) == "string" and not secondary then
        spellName = GetSpellInfo(primary) or primary
    elseif type(secondary) == "string" then
        spellName = GetSpellInfo(secondary) or secondary
    end

    if not spellName and spellID then
        spellName = GetSpellInfo(spellID)
    end

    if not spellName and type(actionKey) == "string" then
        spellName = GetSpellInfo(actionKey) or actionKey
    end

    if not spellName then return end

    local current = practiceSession.currentRecommendation
    local sameSpell = current
        and ((current.spellID and spellID and current.spellID == spellID)
            or (current.spell and spellName and current.spell == spellName)
            or (current.actionKey and actionKey and current.actionKey == actionKey))

    if sameSpell then
        current.time = timestamp
        current.spellID = current.spellID or spellID
        current.spell = current.spell or spellName
        current.actionKey = current.actionKey or actionKey
        return
    end

    practiceSession.currentRecommendation = {
        spellID = spellID,
        spell = spellName,
        actionKey = actionKey,
        time = timestamp,
    }

end

function Practice:DebugHook()
end

-- Track player actions
function Practice:TrackPlayerAction(spellID, castGUID, time)
    if not practiceSession.active or not practiceSession.inCombat then return end

    if castGUID and practiceSession.processedCasts[castGUID] then
        return
    end

    local actionTime = time or GetTime()
    local spellName = GetSpellInfo(spellID)

    if not spellName then return end

    if castGUID then
        practiceSession.processedCasts[castGUID] = true
    else
        -- Fallback dedupe for casts without GUID (e.g., some pet/vehicle abilities)
        local last = practiceSession.unguidedCastTimes[spellID]
        if last and (actionTime - last) < 0.05 then
            return
        end
        practiceSession.unguidedCastTimes[spellID] = actionTime
    end

    local current = practiceSession.currentRecommendation
    if not current then
        return
    end

    table.insert(practiceSession.actualActions, {
        spell = spellName,
        spellID = spellID,
        time = actionTime,
    })

    local threshold = getPracticeConfig().accuracyThreshold or 2
    local matched = false
    local delta

    local idMatch = current.spellID and current.spellID == spellID
    local nameMatch = not current.spellID and current.spell == spellName
    delta = actionTime - (current.time or actionTime)

    if (idMatch or nameMatch) and math.abs(delta) <= threshold then
        matched = true
    end

    local entry = {
        expected = current.spell or current.actionKey,
        expectedSpell = current.spell,
        expectedSpellID = current.spellID,
        expectedActionKey = current.actionKey,
        expectedTime = current.time,
        actualSpell = spellName,
        actualSpellID = spellID,
        actualTime = actionTime,
        used = matched,
        delta = delta,
    }

    entry.action = entry.expected or entry.actualSpell

    table.insert(practiceSession.recommendations, entry)
    practiceSession.currentRecommendation = nil
end

-- Calculate accuracy
function Practice:CalculateAccuracy()
    if #practiceSession.recommendations == 0 then return 0, 0, 0 end

    local correct = 0
    local total = #practiceSession.recommendations
    local threshold = getPracticeConfig().accuracyThreshold

    for _, rec in ipairs(practiceSession.recommendations) do
        if rec.used then
            correct = correct + 1
        end
    end

    local accuracy = (correct / total) * 100
    return accuracy, correct, total
end

-- Report display
function Practice:ShowReport()
    if practiceSession.reportShown then return end
    practiceSession.reportShown = true

    local accuracy, correct, total = self:CalculateAccuracy()
    local combatDuration = practiceSession.combatEnd - practiceSession.combatStart

    -- Create a detailed report
    local accuracyColor = "|cFF00FF00" -- Green
    if accuracy < 50 then
        accuracyColor = "|cFFFF0000" -- Red
    elseif accuracy < 80 then
        accuracyColor = "|cFFFFAA00" -- Orange
    end

    local message = string.format(
        "|cFFFFD100=== Practice Mode Report ===|r\n" ..
        "|cFFFFFFFFCombat Duration:|r %.1fs\n" ..
        "|cFFFFFFFFAccuracy:|r %s%.1f%%|r (%d/%d actions)\n" ..
        "|cFFFFFFFFRecommendations Given:|r %d total\n" ..
        "|cFFFFFFFFPlayer Actions:|r %d total\n" ..
        "|cFFFFFFFFCommit Timestamp:|r %s",
        combatDuration,
        accuracyColor, accuracy, correct, total,
        #practiceSession.recommendations,
        #practiceSession.actualActions,
        LAST_COMMIT_TIMESTAMP
    )

    -- Add performance rating
    local rating = "Needs Practice"
    if accuracy >= 90 then
        rating = "|cFF00FF00Excellent!|r"
    elseif accuracy >= 80 then
        rating = "|cFF00AA00Good|r"
    elseif accuracy >= 60 then
        rating = "|cFFFFAA00Fair|r"
    else
        rating = "|cFFFF0000Needs Practice|r"
    end

    message = message .. "\n|cFFFFFFFFPerformance:|r " .. rating

    -- Show detailed missed recommendations if accuracy is low
    if accuracy < 80 and total > 0 then
        local missed = {}
        for _, rec in ipairs(practiceSession.recommendations) do
            if not rec.used then
                table.insert(missed, rec.action)
            end
        end

        if #missed > 0 then
            message = message .. "\n|cFFFFAAAAMissed Actions:|r " .. table.concat(missed, ", ", 1, math.min(5, #missed))
            if #missed > 5 then
                message = message .. " (+" .. (#missed - 5) .. " more)"
            end
        end
    end

    Hekili:Print(message)

    -- Also show in UI error frame for better visibility
    UIErrorsFrame:AddMessage(
        string.format("Practice Mode: %.1f%% (%d/%d) | Commit: %s", accuracy, correct, total, LAST_COMMIT_TIMESTAMP),
        1.0, 0.8, 0.0, -- Gold color
        1, -- UIErrorsFrame flags
        5  -- Hold time
    )

    -- Hide report after configured duration
    local duration = getPracticeConfig().reportDuration or 10
    C_Timer.After(duration, function()
        -- Could add a way to hide the report if it was shown in a frame
    end)
end

-- Check if displays should be hidden during combat
function Practice:ShouldHideDisplays()
    return practiceSession.active and
           practiceSession.inCombat and
           getPracticeConfig().hideDisplaysInCombat
end

-- Check if we should force recommendation generation
function Practice:ShouldForceRecommendations()
    return practiceSession.active and
           practiceSession.inCombat and
           isPracticeEnabled()
end

-- Integration with events
RegisterEvent("PLAYER_REGEN_DISABLED", function()
    Practice:EnterCombat()
end)

RegisterEvent("PLAYER_REGEN_ENABLED", function()
    Practice:ExitCombat()
end)

RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(event, unit, castGUID, spellID)
    if unit == "player" then
        Practice:TrackPlayerAction(spellID, castGUID)
    end
end)

-- Toggle practice mode
function Practice:ToggleMode()
    -- Ensure toggle exists
    if not Hekili.DB or not Hekili.DB.profile or not Hekili.DB.profile.toggles or not Hekili.DB.profile.toggles.practice then
        Hekili:Print("|cFFFF0000[Practice] Toggle not available - DB not ready|r")
        return
    end

    -- Toggle the setting first
    Hekili.DB.profile.toggles.practice.value = not Hekili.DB.profile.toggles.practice.value

    -- Then sync the session state to match the toggle
    if Hekili.DB.profile.toggles.practice.value then
        self:StartSession()
    else
        self:EndSession()
        Hekili:Print("|cFFFFD100Practice Mode disabled.|r")

        -- Also show prominent on-screen message
        UIErrorsFrame:AddMessage(
            "Practice Mode disabled",
            1.0, 0.8, 0.0, -- Gold color
            1, -- UIErrorsFrame flags
            3  -- Hold time
        )
    end
end

-- Initialize when addon loads
function Practice:Initialize()
    -- Ensure configuration exists
    getPracticeConfig()

    Hekili:Print(string.format("[Practice] Last commit timestamp: %s", LAST_COMMIT_TIMESTAMP))

    -- Check if practice mode should be auto-started based on toggle state
    if isPracticeEnabled() then
        -- Start practice mode if toggle is enabled
        self:StartSession()
    end
end

-- Access to session data for other modules
function Practice:GetSessionData()
    return practiceSession
end

function Practice:IsActive()
    return practiceSession.active
end

function Practice:IsInCombat()
    return practiceSession.inCombat
end
