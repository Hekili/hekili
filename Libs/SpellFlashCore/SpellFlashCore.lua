local MinBuild, OverBuild = 110000, 0
local BuildStr, _, _, Build = GetBuildInfo()
if BuildStr:match("^3.4.") then MinBuild = 30400 end
if Build < (MinBuild or 0) or ( (OverBuild or 0) > 0 and Build >= OverBuild ) then return end
local AddonName, a = ...
a.AddonName = AddonName
local AddonTitle = select(2, C_AddOns.GetAddOnInfo(AddonName))
local GetSpellSubtext = C_Spell.GetSpellSubtext
local PlainAddonTitle = AddonTitle:gsub("|c........", ""):gsub("|r", "")
local L = a.Localize
function a.print(...)
    print("|cFF0099FF["..PlainAddonTitle.."]|r", ...)
end
if SpellFlashCore and not SpellFlashCore.LS then
    a.print(L["Old uncompletable version of SFC detected, shuttingdown. \r\n Please update other copies of SFC before use."])
    return
end
SpellFlashCore = LibStub:NewLibrary("SpellFlashCore", tonumber("20240915150302") or tonumber(date("%Y%m%d%H%M%S")))
if not SpellFlashCore then return end
SpellFlashCore.LS = true
local FrameNames = {}
local ButtonFrames = {}
ButtonFrames.Action = {}
ButtonFrames.Pet = {}
ButtonFrames.Form = {}
ButtonFrames.Vehicle = {}
local Buttons = {}
Buttons.Spell = {}
Buttons.Macro = {}
Buttons.Item = {}
local Frames = {}
Frames.Spell = {}
Frames.Macro = {}
Frames.Item = {}
local BUTTONSREGISTERED = nil
local FRAMESREGISTERED = nil
local LOADING = true
if not SpellFlashCoreAddonConfig then
    SpellFlashCoreAddonConfig = {}
end

function SpellFlashCore.RegisterBigLibTimer(Table)
    return LibStub:GetLibrary("BigLibTimer6"):Register(Table)
end

SpellFlashCore.RegisterBigLibTimer(a)

local EmptyTable = {}

local GetSpellInfo, GetSpellSubtext = C_Spell.GetSpellInfo, C_Spell.GetSpellSubtext

local ItemCache = setmetatable({}, {__index = function(t, v) if C_Item.GetItemInfo(v) then t[v] = {C_Item.GetItemInfo(v)} return t[v] end return EmptyTable end})
function SpellFlashCore.GetItemInfo(id)
    if type(id) == "string" then return C_Item.GetItemInfo(id) end
    return unpack(ItemCache[id])
end
local GetItemInfo = SpellFlashCore.GetItemInfo

function SpellFlashCore.SpellName(GlobalSpellID, NoSubName)
    if type(GlobalSpellID) == "number" then
        local sInfo = GetSpellInfo(GlobalSpellID)
        if not sInfo then return GlobalSpellID end
        local SpellName = sInfo.name
        local SubName = GetSpellSubtext(GlobalSpellID)
        if not NoSubName and SubName and SubName ~= "" then
            return SpellName.."("..SubName..")"
        end
        return SpellName
    end
    return GlobalSpellID
end

function SpellFlashCore.ItemName(ItemID)
    if type(ItemID) == "number" then
        return (C_Item.GetItemInfo(ItemID))
    end
    return ItemID
end

function SpellFlashCore.Replace(...)
    local STRING = ...
    for i = 2, select("#", ...), 2 do
        local FIND, REPLACE = select(i, ...)
        STRING = STRING:gsub(tostring(FIND or ""), tostring(REPLACE or ""))
    end
    return STRING
end

function SpellFlashCore.CopyTable(Table)
    local t = {}
    if type(Table) == "table" then
        for k, v in pairs(Table) do
            if type(v) == "table" then
                t[k] = SpellFlashCore.CopyTable(v)
            else
                t[k] = v
            end
        end
    end
    return t
end

a.PetActions = {
    ["Attack"] = "PET_ACTION_ATTACK",
    ["Follow"] = "PET_ACTION_FOLLOW",
    ["Stay"] = "PET_ACTION_WAIT",
    ["Move To"] = "PET_ACTION_MOVE_TO",
    ["Assist"] = "PET_MODE_ASSIST",
    ["Aggressive"] = "PET_MODE_AGGRESSIVE", --Removed in the 4.2 Patch
    ["Defensive"] = "PET_MODE_DEFENSIVE",
    ["Passive"] = "PET_MODE_PASSIVE",
    [PET_ACTION_ATTACK or "Attack"] = "PET_ACTION_ATTACK",
    [PET_ACTION_FOLLOW or "Follow"] = "PET_ACTION_FOLLOW",
    [PET_ACTION_WAIT or "Stay"] = "PET_ACTION_WAIT",
    [PET_ACTION_MOVE_TO or "Move To"] = "PET_ACTION_MOVE_TO",
    [PET_MODE_ASSIST or "Assist"] = "PET_MODE_ASSIST",
    [PET_MODE_AGGRESSIVE or "Aggressive"] = "PET_MODE_AGGRESSIVE", --Removed in the 4.2 Patch
    [PET_MODE_DEFENSIVE or "Defensive"] = "PET_MODE_DEFENSIVE",
    [PET_MODE_PASSIVE or "Passive"] = "PET_MODE_PASSIVE",
}

local function BodyHasMetaTag(body)
    return body and body:match("#show") and (
        body:match("^%s*#show%s*$")
        or body:match("\n%s*#show%s*$")
        or body:match("^%s*#show%s*\n")
        or body:match("\n%s*#show%s*\n")
        or body:match("^%s*#show%s")
        or body:match("\n%s*#show%s")
        or body:match("^%s*#showtooltip%s*$")
        or body:match("\n%s*#showtooltip%s*$")
        or body:match("^%s*#showtooltip%s*\n")
        or body:match("\n%s*#showtooltip%s*\n")
        or body:match("^%s*#showtooltip%s")
        or body:match("\n%s*#showtooltip%s")
    )
end

local function RegisterButtons()
    BUTTONSREGISTERED = nil
    Buttons.Spell = a:CreateTable(Buttons.Spell, 1)
    Buttons.Macro = a:CreateTable(Buttons.Macro, 1)
    Buttons.Item = a:CreateTable(Buttons.Item, 1)
    Frames.Spell = a:CreateTable(Frames.Spell, 1)
    Frames.Macro = a:CreateTable(Frames.Macro, 1)
    Frames.Item = a:CreateTable(Frames.Item, 1)
    SpellFlashCore.debug("-     Button Slots Found:")
    for i = 1, 180 do
        if HasAction(i) then
            local Type, ID = GetActionInfo(i)
            local name = GetActionText(i)
            if Type == "macro" then
                if BodyHasMetaTag(GetMacroBody(name)) then
                    ID = tostring(ID)
                    if not Buttons.Macro[ID] then
                        Buttons.Macro[ID] = a:CreateTable()
                    end
                    Buttons.Macro[ID][i] = 1
                    SpellFlashCore.debug(i, Type, ID, "=", GetActionText(i))
                end
            elseif Type == "item" then
                local item = Item:CreateFromItemID(ID)
                item:ContinueOnItemLoad(function()
                    local Name = SpellFlashCore.ItemName(ID)
                    if type(Name) == "string" and Name ~= "" then
                        if not Buttons.Item[Name] then
                            Buttons.Item[Name] = a:CreateTable()
                        end
                        Buttons.Item[Name][i] = 1
                        SpellFlashCore.debug(i, Type, ID, "=", Name)
                    end
                end)
            elseif Type == "spell" then
                local spell = Spell:CreateFromSpellID(ID)
                if not spell:IsSpellEmpty() then
                    spell:ContinueOnSpellLoad(function()
                        local Name = SpellFlashCore.SpellName(ID) or ID
                        if Name then
                            if not Buttons.Spell[Name] then
                                Buttons.Spell[Name] = a:CreateTable()
                            end
                            Buttons.Spell[Name][i] = 1
                            SpellFlashCore.debug(i, Type, ID, "=", Name)
                        end
                    end)
                end
            elseif Type == "flyout" then
                if not Buttons.Spell[ID] then
                    Buttons.Spell[ID] = a:CreateTable()
                end
                Buttons.Spell[ID][i] = 1
                SpellFlashCore.debug(i, Type, ID, "=", ID)
            end
        end
    end
    if C_AddOns.IsAddOnLoaded("ButtonForge") then
        local i = 1
        local frame = _G["ButtonForge"..i]
        while type(frame) == "table" do
            if type(frame.ParentButton) == "table" then
                local Type = frame.ParentButton.Mode
                if Type == "macro" then
                    local Name = frame.ParentButton.MacroName
                    if type(Name) == "string" and Name ~= "" then
                        local ID = frame.ParentButton.MacroIndex
                        if BodyHasMetaTag(GetMacroBody(ID)) then
                            ID = tostring(ID)
                            if not Frames.Macro[ID] then
                                Frames.Macro[ID] = a:CreateTable()
                            end
                            Frames.Macro[ID][frame] = 1
                            SpellFlashCore.debug("ButtonForge"..i, Type, ID, "=", Name)
                        end
                    end
                elseif Type == "item" then
                    local ID = frame.ParentButton.ItemId
                    local Name = SpellFlashCore.ItemName(ID) or frame.ParentButton.ItemName
                    if type(Name) == "string" and Name ~= "" then
                        if not Frames.Item[Name] then
                            Frames.Item[Name] = a:CreateTable()
                        end
                        Frames.Item[Name][frame] = 1
                        SpellFlashCore.debug("ButtonForge"..i, Type, ID, "=", Name)
                    end
                elseif Type == "spell" then
                    local ID = frame.ParentButton.SpellId
                    local Name = SpellFlashCore.SpellName(ID) or frame.ParentButton.SpellName
                    if type(Name) == "string" and Name ~= "" then
                        if not Frames.Spell[Name] then
                            Frames.Spell[Name] = a:CreateTable()
                        end
                        Frames.Spell[Name][frame] = 1
                        SpellFlashCore.debug("ButtonForge"..i, Type, ID, "=", Name)
                    end
                elseif Type == "flyout" then
                    local ID = frame.ParentButton.FlyoutId
                    local Name = SpellFlashCore.SpellName(ID) or ID
                    if Name then
                        if not Frames.Spell[Name] then
                            Frames.Spell[Name] = a:CreateTable()
                        end
                        Frames.Spell[Name][frame] = 1
                        SpellFlashCore.debug("ButtonForge"..i, Type, ID, "=", Name)
                    end
                end
            end
            i = i + 1
            frame = _G["ButtonForge"..i]
        end
    end
    BUTTONSREGISTERED = 1
end

local function DuplicateFrame(frame)
    for _, Table in pairs(ButtonFrames) do
        if Table[frame] then
            return true
        end
    end
    return false
end

FrameNames.Form = {
    "DominosClassButton", -- Dominos
    "VFLStanceButton", -- OpenRDX
}

FrameNames.Pet = {
    "VFLPetButton", -- OpenRDX
}

FrameNames.Action = {
    "VFLButton", -- OpenRDX
    "DominosActionButton", -- Dominos
}

local function FrameScriptCheck(script,tipe)
    if tipe == "Form" then
        for i=1, 10, 1 do
            if script == _G["StanceButton" .. i]:GetScript("OnClick") then return true end
        end
    elseif tipe == "Pet" then
        for i=1, 10, 1 do
            if script == _G["PetActionButton" .. i]:GetScript("OnClick") then return true end
        end
    elseif tipe == "Action" then
        local BarNames = {"Action","MultiBarBottomRight","MultiBarBottomLeft","MultiBarRight","MultiBarLeft","MultiBar5","MultiBar6","MultiBar7","MultiBarRightAction","MultiBarLeftAction","MultiBarBottomRightAction","MultiBarBottomLeftAction","MultiBar5Action","MultiBar6Action","MultiBar7Action"}
        for _, BarName in pairs(BarNames) do
            for i=1, 12, 1 do
                local button = _G[BarName .. "Button" .. i]
                if button and script == button:GetScript("OnClick") then return true end
            end
        end
    elseif tipe == "Vehicle" then
        for i=1, 6, 1 do
            if script == _G["OverrideActionBarButton" .. i]:GetScript("OnClick") then return true end
        end
    end
    return false
end

local function RegisterFrames()
    FRAMESREGISTERED = nil
    wipe(ButtonFrames.Action)
    wipe(ButtonFrames.Pet)
    wipe(ButtonFrames.Form)
    wipe(ButtonFrames.Vehicle)
    for Type in pairs(FrameNames) do
        for _, Name in ipairs(FrameNames[Type]) do
            for i = 1, 144 do
                local frame = _G[Name..i]
                if frame and not DuplicateFrame(frame) then
                    ButtonFrames[Type][frame] = 1
                end
            end
        end
    end
    local LAB = {
        original = LibStub:GetLibrary("LibActionButton-1.0", true),
        elvui = LibStub:GetLibrary("LibActionButton-1.0-ElvUI", true),
        NDui = LibStub:GetLibrary("LibActionButton-1.0-NDui", true),
        UI = LibStub:GetLibrary("LibActionButton-1.0-UI", true)
    }

    for _, lib in pairs(LAB) do
        for frame in pairs(lib:GetAllButtons()) do
            if not DuplicateFrame(frame) then
                ButtonFrames.Action[frame] = 1
            end
        end
    end
    local frame = EnumerateFrames()

    while frame do
        if type(frame) == "table" and type(frame[0]) == "userdata" and frame.IsProtected and frame.GetObjectType and frame.GetScript and frame:GetObjectType() == "CheckButton" and frame:IsProtected() then
            if FrameScriptCheck(frame:GetScript("OnClick"),"Form") then
                if not DuplicateFrame(frame) then
                    ButtonFrames.Form[frame] = 1
                end
            elseif FrameScriptCheck(frame:GetScript("OnClick"),"Pet") then
                if not DuplicateFrame(frame) then
                    ButtonFrames.Pet[frame] = 1
                end
            elseif FrameScriptCheck(frame:GetScript("OnClick"),"Action") then
                if not DuplicateFrame(frame) then
                    ButtonFrames.Action[frame] = 1
                end
            elseif FrameScriptCheck(frame:GetScript("OnClick"),"Vehicle") then
                if not DuplicateFrame(frame) then
                    ButtonFrames.Vehicle[frame] = 1
                end
            end
        end
        frame = EnumerateFrames(frame)
    end

    FRAMESREGISTERED = 1
end

local COLORTABLE = {
    white = {r=1, g=1, b=1},
    yellow = {r=1, g=1, b=0},
    purple = {r=1, g=0, b=1},
    blue = {r=0, g=0, b=1},
    orange = {r=1, g=0.5, b=0.25},
    aqua = {r=0, g=1, b=1},
    green = {r=0.1, g=1, b=0.1},
    red = {r=1, g=0.1, b=0.1},
    pink = {r=0.9, g=0.4, b=0.4},
    gray = {r=0.5, g=0.5, b=0.5},
}

local function FlashFrameOnUpdate(self, elapsed)
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
    if self.TimeSinceLastUpdate >= self.UpdateInterval then
        local TimeSinceLastUpdate = self.TimeSinceLastUpdate
        self.TimeSinceLastUpdate = 0
        if self.show then
            self.modifier = self.FlashModifier
            self.FlashModifier = self.modifier - self.modifier * TimeSinceLastUpdate
            self.alpha = self.FixedBrightness and self.FlashBrightness or (self.FlashModifier * self.FlashBrightness)
            if self.modifier < 0.1 or self.alpha <= 0 then
                self.show = false
                self:SetAlpha(0)
                self:Hide()
            else
                self.FlashTexture:SetHeight(self.FixedSize and (self:GetHeight() * self.FlashSize) or (self.modifier * self:GetHeight() * self.FlashSize))
                self.FlashTexture:SetWidth(self.FixedSize and (self:GetWidth() * self.FlashSize) or (self.modifier * self:GetWidth() * self.FlashSize))
                self.FlashTexture:SetAlpha(self.alpha)
            end
        else
            self:Hide()
        end
    end
end

local FlashFrameName = "SpellFlashCoreAddonFlashFrame"

-- code for the blink option
local tables = setmetatable({}, { __mode = "k" })
local ffades = {}
local fflashs = {}

local function trelease(t)
    tables[t] = true
    while true do
        local k = next(t)
        if k then t[k] = nil else break end
        end
end

local function fadeget(frame)
    if not frame then return end
    local r = ffades[frame]
    if r then return r end
    r = next(tables)
    if r then
        tables[r] = nil
    else
        r = {}
    end
    ffades[frame] = r
    return r
end

local function faderelease(frame)
    if not frame then return end
    local t = ffades[frame]
    ffades[frame] = nil
    if t then trelease(t) end
    frame.fadeInfo = nil
end

local function flashrelease(frame)
    if not frame then return end
    fflashs[frame] = nil
end

local function FrameFade(frame, info)
    if not frame or not info then return end
    local mode = info.mode or "IN"
    info.mode = mode
    if mode == "IN" then
        info.startAlpha = info.startAlpha or 0
        info.endAlpha = info.endAlpha or 1
    elseif mode == "OUT" then
        info.startAlpha = info.startAlpha or 1
        info.endAlpha = info.endAlpha or 0
    end

    info.timer = 0
    frame:SetAlpha(info.startAlpha)
    frame.fadeInfo = info
end

local function FrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
    if not frame then return end
    local info = fadeget(frame)
    info.timeToFade = timeToFade
    info.startAlpha = startAlpha
    info.endAlpha = endAlpha
    info.mode = "IN"
    FrameFade(frame, info)
end

local function FrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
    if not frame then return end
    local info = fadeget(frame)
    info.timeToFade = timeToFade
    info.startAlpha = startAlpha
    info.endAlpha = endAlpha
    info.mode = "OUT"
    FrameFade(frame, info)
end

local function FrameIsFading(frame)
    if not frame then return end
    return ffades[frame]
end

local function FrameFadeUpdate(elapsed)
    for frame, info in pairs(ffades) do
        local timer = (info.timer or 0) + elapsed
        local timeToFade = info.timeToFade
        if timer < timeToFade then
            local mode = info.mode
            if mode == "IN" then
                local startAlpha = info.startAlpha
                frame:SetAlpha(timer * (info.endAlpha - startAlpha) / timeToFade + startAlpha)
            elseif info.mode == "OUT" then
                local endAlpha = info.endAlpha
                frame:SetAlpha((timeToFade - timer) * (info.startAlpha - endAlpha) / timeToFade + endAlpha)
            end
            info.timer = timer
        else
            frame:SetAlpha(info.endAlpha)

            local holdTime = info.holdTime or 0
            if holdTime > 0 then
                info.holdTime = holdTime - elapsed
            else
                local func = info.finishedFunc
                if func then
                    func(info.finishedArg1, info.finishedArg2, info.finishedArg3, info.finishedArg4)
                end
                faderelease(frame)
            end
        end
    end
end

local function FrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime)
    if not frame then return end
    frame.fadeInTime = fadeInTime
    frame.fadeOutTime = fadeOutTime
    frame.flashDuration = flashDuration
    frame.showWhenDone = showWhenDone
    frame.flashTimer = 0
    frame.flashMode = "IN"
    frame.flashInHoldTime = flashInHoldTime
    frame.flashOutHoldTime = flashOutHoldTime
    fflashs[frame] = 1
end

local function FrameFlashSwitch(frame, mode)
    if not frame then return end
    frame.flashMode = mode
end

local function FrameFlashStop(frame)
    if not frame then return end
    frame.flashDuration = 0
end

local function FrameFlashUpdate(elapsed)
    for frame in pairs(fflashs) do
        local timer = frame.flashTimer + elapsed
        local duration = frame.flashDuration
        if timer > duration and duration ~= -1 then
            faderelease(frame)
            flashrelease(frame)
            frame:SetAlpha(1)
            timer = nil
        elseif frame.flashMode then
            local fadeInfo = fadeget(frame)
            if frame.flashMode == "IN" then
                fadeInfo.timeToFade = frame.fadeInTime
                fadeInfo.mode = "IN"
                fadeInfo.finishedFunc = FrameFlashSwitch
                fadeInfo.finishedArg1 = frame
                fadeInfo.finishedArg2 = "OUT"
                fadeInfo.fadeHoldTime = frame.flashOutHoldTime
                FrameFade(frame, fadeInfo)
            elseif frame.flashMode == "OUT" then
                fadeInfo.timeToFade = frame.fadeOutTime
                fadeInfo.mode = "OUT"
                fadeInfo.finishedFunc = FrameFlashSwitch
                fadeInfo.finishedArg1 = frame
                fadeInfo.finishedArg2 = "IN"
                fadeInfo.fadeHoldTime = frame.flashInHoldTime
                FrameFade(frame, fadeInfo)
            end
            frame.flashMode = nil
        end
        frame.flashTimer = timer
    end
end

local function FrameIsFlashing(frame)
    if not frame then return end
    return fflashs[frame]
end

local FrameFlashEventFrame = CreateFrame("Frame")
local function FrameFlashOnUpdate(self, elapsed)
    FrameFadeUpdate(elapsed)
    FrameFlashUpdate(elapsed)
end
FrameFlashEventFrame:SetScript("OnUpdate", FrameFlashOnUpdate)
FrameFlashEventFrame:Show()

function SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    if frame and frame:IsVisible() then
        if blink and frame:GetName() and not FrameIsFading(frame) then
            FrameFlash(frame, 0, 0.2, 0.2, true, 0, 0)
        end
        if not frame[FlashFrameName] then
            frame[FlashFrameName] = CreateFrame("Frame", nil, frame)
            frame[FlashFrameName]:SetAlpha(0)
            frame[FlashFrameName]:SetAllPoints(frame)
            frame[FlashFrameName].FlashTexture = frame[FlashFrameName]:CreateTexture(nil, "OVERLAY")
            if texture and C_Texture.GetAtlasInfo(texture) then
                frame[FlashFrameName].FlashTexture:SetAtlas(texture or "AftLevelup-WhiteStarBurst")
            else
                frame[FlashFrameName].FlashTexture:SetTexture(texture or "Interface\\Cooldown\\star4")
            end
	    frame[FlashFrameName].FlashTexture:SetPoint("CENTER", frame[FlashFrameName], "CENTER")
	    frame[FlashFrameName].FlashTexture:SetBlendMode("ADD")
            frame[FlashFrameName].UpdateInterval = 0.02
            frame[FlashFrameName].TimeSinceLastUpdate = 0
            frame[FlashFrameName]:SetScript("OnUpdate", FlashFrameOnUpdate)
        end
        frame[FlashFrameName].FlashModifier = 1
        frame[FlashFrameName].FixedSize = fixedSize or false
        frame[FlashFrameName].FlashSize = (size or 240) / 100
        frame[FlashFrameName].FixedBrightness = fixedBrightness or false
        frame[FlashFrameName].FlashBrightness = (brightness or 100) / 100
        frame[FlashFrameName].FlashTexture:SetHeight(frame[FlashFrameName]:GetHeight() * frame[FlashFrameName].FlashSize)
        frame[FlashFrameName].FlashTexture:SetWidth(frame[FlashFrameName]:GetWidth() * frame[FlashFrameName].FlashSize)
        frame[FlashFrameName].FlashTexture:SetAlpha(1 * frame[FlashFrameName].FlashBrightness)
        if type(color) == "table" then
            frame[FlashFrameName].FlashTexture:SetVertexColor(color.r or 1, color.g or 1, color.b or 1)
        elseif type(color) == "string" then
            local color = COLORTABLE[color:lower()]
            if color then
                frame[FlashFrameName].FlashTexture:SetVertexColor(color.r or 1, color.g or 1, color.b or 1)
            else
                frame[FlashFrameName].FlashTexture:SetVertexColor(1, 1, 1)
            end
        else
            frame[FlashFrameName].FlashTexture:SetVertexColor(1, 1, 1)
        end
        frame[FlashFrameName]:SetAlpha(1)
        frame[FlashFrameName].show = true
        frame[FlashFrameName]:Show()
        return true
    end
    return false
end

local function FlashActionButton(button, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    if FRAMESREGISTERED and button then
        for frame in pairs(ButtonFrames.Action) do
            if frame._state_action then
                if frame._state_action == button then
                    SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                end
            elseif frame.action == button then
                SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
            end
        end
    end
end

local function SetMultiCastSpellHook()
    BUTTONSREGISTERED = nil
    a:SetTimer("RegisterButtons", 1, 0, RegisterButtons)
end
hooksecurefunc("SetMultiCastSpell", SetMultiCastSpellHook)


local Event = {}
local function OnEvent(self, event, ...)
    Event[event](event, ...)
end
local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", OnEvent)

function Event.ACTIONBAR_SHOWGRID()
    BUTTONSREGISTERED = nil
end

local function RegisterAll()
    FRAMESREGISTERED = nil
    BUTTONSREGISTERED = nil
    a:SetTimer("RegisterFrames", 0.5, 0, RegisterFrames)
    a:SetTimer("RegisterButtons", 1, 0, RegisterButtons)
end
Event.ACTIONBAR_HIDEGRID = RegisterAll
Event.LEARNED_SPELL_IN_TAB = RegisterAll
Event.CHARACTER_POINTS_CHANGED = RegisterAll
Event.ACTIVE_TALENT_GROUP_CHANGED = RegisterAll
function Event.ACTIONBAR_SLOT_CHANGED(event, arg1)
    local Type, ID = GetActionInfo(arg1)
    local name = GetActionText(arg1)
    local Name = SpellFlashCore.SpellName(ID) or ID
    if Name then
        if not Buttons.Spell[Name] then
            Buttons.Spell[Name] = a:CreateTable()
        end
        Buttons.Spell[Name][arg1] = 1
    end
end
if Build >= 100000 then Event.PLAYER_SPECIALIZATION_CHANGED = RegisterAll end -- Does not exist in Wrath.
Event.UPDATE_MACROS = RegisterAll
Event.VEHICLE_UPDATE = RegisterAll
function Event.UNIT_PET(event, arg1)
    if arg1 == "player" and not a:IsTimer("RegisterButtons") then
        RegisterButtons()
    end
end

local function StartUp()
    if LOADING then
        a:SetTimer("RegisterFrames", 2, 0, RegisterFrames)
        a:SetTimer("RegisterButtons", 2, 0, RegisterButtons)
        LOADING = false
    end
end
Event.PLAYER_ENTERING_WORLD = StartUp
Event.PLAYER_ALIVE = StartUp

function Event.ADDON_LOADED(event, arg1)
    if arg1 == AddonName then
        if not SpellFlashCoreAddonConfig then
            SpellFlashCoreAddonConfig = {}
        elseif SpellFlashCoreAddonConfig.DebugEvents then
            for event in pairs(SpellFlashCoreAddonConfig.DebugEvents) do
                SpellFlashCore.RegisterDebugEvent(event)
            end
        elseif SpellFlashCoreAddonConfig.AllDebugEventsEnabled then
            SpellFlashCore.RegisterAllDebugEvents()
        end
    end
end

for event in pairs(Event) do
    EventFrame:RegisterEvent(event)
end


local function SlashHandler(msg)
    if msg:lower():match("event") or msg:lower():match("register") then
        if msg:lower():match("unregister%s+all") then
            SpellFlashCore.UnregisterAllDebugEvents()
            a.print(L["all events unregistered"])
        elseif msg:lower():match("register%s+all") then
            SpellFlashCore.RegisterAllDebugEvents()
            a.print(L["all events registered"])
        else
            local event = msg:match("[Ee][Vv][Ee][Nn][Tt]%s+([A-Z_]+)%s*$") or msg:match("[Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr]%s+([A-Z_]+)%s*$")
            if event then
                if msg:match("unregister") then
                    if SpellFlashCoreAddonConfig.DebugEvents then
                        SpellFlashCore.UnregisterDebugEvent(event)
                        a.print("-", event)
                    end
                else
                    SpellFlashCore.RegisterDebugEvent(event)
                    a.print("+", event)
                end
            end
        end
    elseif msg:lower():match("debug") then
        if msg:lower():match("on") then
            a.print(L["debug is enabled"])
            SpellFlashCoreAddonConfig.Debug = true
        elseif msg:lower():match("off") then
            a.print(L["debug is disabled"])
            SpellFlashCoreAddonConfig.Debug = nil
        elseif SpellFlashCoreAddonConfig.Debug then
            a.print(L["debug is disabled"])
            SpellFlashCoreAddonConfig.Debug = nil
        else
            a.print(L["debug is enabled"])
            SpellFlashCoreAddonConfig.Debug = true
        end
    elseif msg:lower():match("reset.*all") or msg:lower():match("clear.*all") or msg:lower():match("delete.*all") then
        SpellFlashCore.UnregisterAllDebugEvents()
        wipe(SpellFlashCoreAddonConfig)
        a.print(L["all settings cleared"])
    end
end
SlashCmdList.SpellFlashCoreAddon = SlashHandler
SLASH_SpellFlashCoreAddon1 = "/spellflashcore"
SLASH_SpellFlashCoreAddon2 = "/sfcore"
SLASH_SpellFlashCoreAddon3 = "/sfc"


local DebugCount = 0
function SpellFlashCore.debug(...)
    if SpellFlashCoreAddonConfig.Debug and select("#", ...) > 0 then
        DebugCount = DebugCount + 1
        print("["..DebugCount.."]  ", ...)
    end
end


function SpellFlashCore.Flashable(SpellName, NoMacros)
    if type(SpellName) == "table" then
        for _, SpellName in ipairs(SpellName) do
            if SpellFlashCore.Flashable(SpellName, NoMacros) then
                return true
            end
        end
        return false
    elseif FRAMESREGISTERED and BUTTONSREGISTERED then
        local SpellName, PlainName = SpellName, SpellName
        if type(SpellName) == "number" then
            local sInfo = GetSpellInfo(SpellName)
            local name = sInfo and sInfo.name
            local second =  GetSpellSubtext(SpellName)
            if name then
                PlainName = name
                if second and second ~= "" then
                    SpellName = PlainName.."("..second..")"
                else
                    SpellName = PlainName
                end
            end
        end
        if SpellName then
            if Buttons.Spell[SpellName] or Buttons.Item[SpellName] or Frames.Spell[SpellName] or Frames.Item[SpellName] then
                return true
            end

            local sInfo = GetSpellInfo(SpellName)
            if not NoMacros and type(SpellName) == "string" and ( sInfo and sInfo.name or C_Item.GetItemCount(SpellName) > 0 ) then
                local SpellTexture = sInfo and sInfo.iconID
                local ItemTexture = C_Item.GetItemIconByID(SpellName)
                for ID in pairs(Buttons.Macro) do
                    local mInfo = GetSpellInfo(ID)
                    if mInfo and SpellName == mInfo.name then
                        return true
                    end
                end
                for ID in pairs(Frames.Macro) do
                    local mInfo = GetSpellInfo(ID)
                    if mInfo and SpellName == mInfo.name then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function SpellFlashCore.ItemFlashable(ItemName, NoMacros)
    if type(ItemName) == "table" then
        for _, ItemName in ipairs(ItemName) do
            if SpellFlashCore.ItemFlashable(ItemName, NoMacros) then
                return true
            end
        end
        return false
    end
    return SpellFlashCore.Flashable(SpellFlashCore.ItemName(ItemName) or ItemName, NoMacros)
end

function SpellFlashCore.FlashAction(SpellName, color, size, brightness, blink, NoMacros, texture, fixedSize, fixedBrightness)
    if type(SpellName) == "table" then
        for _, SpellName in ipairs(SpellName) do
            SpellFlashCore.FlashAction(SpellName, color, size, brightness, blink, NoMacros, texture, fixedSize, fixedBrightness)
        end
    elseif FRAMESREGISTERED and BUTTONSREGISTERED then
        local SpellName, PlainName = SpellName, SpellName
        if type(SpellName) == "number" then
            local sInfo = GetSpellInfo(SpellName)
            local name = sInfo and sInfo.name
            local second =  GetSpellSubtext(SpellName)
            if name then
                PlainName = name
                if second and second ~= "" then
                    SpellName = PlainName.."("..second..")"
                else
                    SpellName = PlainName
                end
            end
        end
        if SpellName then
            if Buttons.Spell[SpellName] then
                for button in pairs(Buttons.Spell[SpellName]) do
                    FlashActionButton(button, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                end
            end
            if Buttons.Item[SpellName] then
                for button in pairs(Buttons.Item[SpellName]) do
                    FlashActionButton(button, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                end
            end
            if Frames.Spell[SpellName] then
                for frame in pairs(Frames.Spell[SpellName]) do
                    SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                end
            end
            if Frames.Item[SpellName] then
                for frame in pairs(Frames.Item[SpellName]) do
                    SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                end
            end

            local sInfo = GetSpellInfo(SpellName)
            if not NoMacros and type(SpellName) == "string" and ( sInfo and sInfo.name or C_Item.GetItemCount(SpellName) > 0 ) then
                local SpellTexture = sInfo and sInfo.iconID
                local ItemTexture = C_Item.GetItemIconByID(SpellName)
                for ID, Table in pairs(Buttons.Macro) do
                    local mInfo = GetSpellInfo(ID)
                    if mInfo and mInfo.name then
                        for button in pairs(Table) do
                            if SpellName == mInfo.name then
                                FlashActionButton(button, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                            end
                        end
                    end
                end
                for ID, Table in pairs(Frames.Macro) do
                    local mInfo = GetSpellInfo(ID)

                    if mInfo and SpellName == mInfo.name then
                        SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                    end
                end
            end
        end
    end
end

function SpellFlashCore.FlashItem(ItemName, color, size, brightness, blink, NoMacros, texture, fixedSize, fixedBrightness)
    if type(ItemName) == "table" then
        for _, ItemName in ipairs(ItemName) do
            SpellFlashCore.FlashItem(ItemName, color, size, brightness, blink, NoMacros, texture, fixedSize, fixedBrightness)
        end
    else
        SpellFlashCore.FlashAction(SpellFlashCore.ItemName(ItemName) or ItemName, color, size, brightness, blink, NoMacros, texture, fixedSize, fixedBrightness)
    end
end

function SpellFlashCore.FlashVehicle(SpellName, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    if type(SpellName) == "table" then
        for _, SpellName in ipairs(SpellName) do
            SpellFlashCore.FlashVehicle(SpellName, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
        end
    elseif FRAMESREGISTERED and UnitInVehicle("player") then
        local SpellName = SpellName
        if type(SpellName) == "number" then
            SpellName = SpellFlashCore.SpellName(SpellName)
        end
        if type(SpellName) == "string" and SpellName ~= "" then
            for i = 121, 138 do
                local ID = select(2, GetActionInfo(i))
                if ID and SpellFlashCore.SpellName(ID) == SpellName then
                    for frame in pairs(ButtonFrames.Vehicle) do
                        if frame._state_action then
                            if frame._state_action == i then
                                SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                            end
                        elseif frame.action == i then
                            SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                        end
                    end
                    for frame in pairs(ButtonFrames.Action) do
                        if frame._state_action then
                            if frame._state_action == i then
                                SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                            end
                        elseif frame.action == i then
                            SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                        end
                    end
                end
            end
        end
    end
end

function SpellFlashCore.FlashPet(SpellName, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    if type(SpellName) == "table" then
        for _, SpellName in ipairs(SpellName) do
            SpellFlashCore.FlashPet(SpellName, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
        end
    elseif FRAMESREGISTERED then
        local SpellName = SpellName
        if type(SpellName) == "number" then
            SpellName = SpellFlashCore.SpellName(SpellName)
        end
        if type(SpellName) == "string" and SpellName ~= "" then
            for n = 1, NUM_PET_ACTION_SLOTS do
                local name = GetPetActionInfo(n)
                if ( a.PetActions[SpellName] or SpellName ) == name then
                    for frame in pairs(ButtonFrames.Pet) do
                        if frame.id then
                            if frame.id == n then
                                SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                            end
                        elseif frame:GetID() == n then
                            SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                        end
                    end
                end
            end
        end
    end
end

function SpellFlashCore.FlashForm(SpellName, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    if type(SpellName) == "table" then
        for _, SpellName in ipairs(SpellName) do
            SpellFlashCore.FlashForm(SpellName, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
        end
    elseif FRAMESREGISTERED then
        local SpellName = SpellName
        if type(SpellName) == "number" then
            SpellName = SpellFlashCore.SpellName(SpellName, 1)
        end
        if type(SpellName) == "string" and SpellName ~= "" then
            for n=1,GetNumShapeshiftForms() do
                if select(2,GetShapeshiftFormInfo(n)) == SpellName then
                    for frame in pairs(ButtonFrames.Form) do
                        if frame.id then
                            if frame.id == n then
                                SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                            end
                        elseif frame:GetID() == n then
                            SpellFlashCore.FlashFrame(frame, color, size, brightness, blink, texture, fixedSize, fixedBrightness)
                        end
                    end
                end
            end
        end
    end
end


local TotemCallFrames = {
    "MultiCastSummonSpellButton", -- Blizzard
    "DominosSpellButton10", -- Dominos
    "DominosSpellButton21", -- Dominos
    "DominosSpellButton32", -- Dominos
}

function SpellFlashCore.FlashTotemCall(color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    for _, frame in ipairs(TotemCallFrames) do
        SpellFlashCore.FlashFrame(_G[frame], color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    end
end

local TotemRecallFrames = {
    "MultiCastRecallSpellButton", -- Blizzard
    "DominosSpellButton11", -- Dominos
    "DominosSpellButton22", -- Dominos
    "DominosSpellButton33", -- Dominos
}

function SpellFlashCore.FlashTotemRecall(color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    for _, frame in ipairs(TotemRecallFrames) do
        SpellFlashCore.FlashFrame(_G[frame], color, size, brightness, blink, texture, fixedSize, fixedBrightness)
    end
end


local DebugEventFrame = CreateFrame("Frame")
DebugEventFrame.LastEventTime = 0
local function DebugOnEvent(self, event, ...)
    if SpellFlashCoreAddonConfig.Debug then
        local t = GetTime()
        SpellFlashCore.debug("event:  "..event)
        SpellFlashCore.debug("       Time:  "..t.."  -  "..self.LastEventTime.."  =  "..( t - self.LastEventTime ))
        self.LastEventTime = t
        local n = select("#", ...)
        if n > 0 then
            for i=1,n do
                if type(select(i, ...)) ~= "nil" then
                    SpellFlashCore.debug("       arg"..i.." = "..type(select(i, ...))..": "..tostring(select(i, ...)))
                end
            end
        end
    end
end
DebugEventFrame:SetScript("OnEvent", DebugOnEvent)

function SpellFlashCore.RegisterDebugEvent(event)
    if SpellFlashCoreAddonConfig.AllDebugEventsEnabled then
        DebugEventFrame:UnregisterAllEvents()
        SpellFlashCoreAddonConfig.AllDebugEventsEnabled = nil
        SpellFlashCoreAddonConfig.DebugEvents = nil
    end
    DebugEventFrame:RegisterEvent(event)
    if not SpellFlashCoreAddonConfig.DebugEvents then
        SpellFlashCoreAddonConfig.DebugEvents = {}
    end
    SpellFlashCoreAddonConfig.DebugEvents[event] = true
end

function SpellFlashCore.UnregisterDebugEvent(event)
    if SpellFlashCoreAddonConfig.AllDebugEventsEnabled then
        DebugEventFrame:UnregisterAllEvents()
        SpellFlashCoreAddonConfig.AllDebugEventsEnabled = nil
        SpellFlashCoreAddonConfig.DebugEvents = nil
    else
        DebugEventFrame:UnregisterEvent(event)
        if SpellFlashCoreAddonConfig.DebugEvents then
            SpellFlashCoreAddonConfig.DebugEvents[event] = nil
            if not next(SpellFlashCoreAddonConfig.DebugEvents) then
                SpellFlashCoreAddonConfig.DebugEvents = nil
            end
        end
    end
end

function SpellFlashCore.RegisterAllDebugEvents()
    DebugEventFrame:RegisterAllEvents()
    SpellFlashCoreAddonConfig.AllDebugEventsEnabled = true
    SpellFlashCoreAddonConfig.DebugEvents = nil
end

function SpellFlashCore.UnregisterAllDebugEvents()
    DebugEventFrame:UnregisterAllEvents()
    SpellFlashCoreAddonConfig.AllDebugEventsEnabled = nil
    SpellFlashCoreAddonConfig.DebugEvents = nil
end




-- This is used for testing purposes only
-- Example: SpellFlashCore.SaveAllFrameNameStringsIntoATable(SpellFlashAddonConfig)
function SpellFlashCore.SaveAllFrameNameStringsIntoATable(TABLE)
    if type(TABLE) == "table" then
        local n = "ALL DETECTABLE FRAME STRINGS"
        if not TABLE[n] then
            TABLE[n] = {}
        end
        wipe(TABLE[n])
        local frame = EnumerateFrames()
        while frame do
            if frame:GetName() then
                if type(frame) == "table" and type(frame[0]) == "userdata" and frame.IsProtected and frame.GetObjectType and frame.GetScript and frame:GetObjectType() == "CheckButton" and frame:IsProtected() then
                    if not TABLE[n].Buttons then
                        TABLE[n].Buttons = {}
                    end
                    if frame:GetScript("OnClick") == StanceButton1:GetScript("OnClick") then
                        if not TABLE[n].Buttons.Form then
                            TABLE[n].Buttons.Form = {}
                        end
                        TABLE[n].Buttons.Form[frame:GetName()] = "form"
                    elseif frame:GetScript("OnClick") == PetActionButton1:GetScript("OnClick") then
                        if not TABLE[n].Buttons.Pet then
                            TABLE[n].Buttons.Pet = {}
                        end
                        TABLE[n].Buttons.Pet[frame:GetName()] = "pet"
                    elseif frame:GetScript("OnClick") == ActionButton1:GetScript("OnClick") then
                        if not TABLE[n].Buttons.Action then
                            TABLE[n].Buttons.Action = {}
                        end
                        TABLE[n].Buttons.Action[frame:GetName()] = "action"
                    elseif frame:GetScript("OnClick") == OverrideActionBarButton1:GetScript("OnClick") then
                        if not TABLE[n].Buttons.Vehicle then
                            TABLE[n].Buttons.Vehicle = {}
                        end
                        TABLE[n].Buttons.Vehicle[frame:GetName()] = "vehicle"
                    else
                        if not TABLE[n].Buttons.Other then
                            TABLE[n].Buttons.Other = {}
                        end
                        TABLE[n].Buttons.Other[frame:GetName()] = "other"
                    end
                else
                    if not TABLE[n].Any then
                        TABLE[n].Any = {}
                    end
                    TABLE[n].Any[frame:GetName()] = "any"
                end
            end
            frame = EnumerateFrames(frame)
        end
    end
end

