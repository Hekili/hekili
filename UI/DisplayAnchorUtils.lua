-- DisplayAnchorUtils.lua
-- Shared anchoring utilities for Hekili displays and toggle status bar

local addon, ns = ...
local Hekili = _G[ addon ]

-- Module table
local DisplayAnchorUtils = {}

-- Proxy frame storage
local proxyFrames = {}

-- Personal Resource Display anchor detection
local function GetPersonalResourceAnchor()
    local frame = C_NamePlate and C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit( "player" )
    if frame then
        -- ElvUI support
        if _G.ElvUIPlayerNamePlateAnchor then
            return _G.ElvUIPlayerNamePlateAnchor
        end
        if frame.UnitFrame and frame.UnitFrame.healthBar then
            return frame.UnitFrame
        end
    end
    return nil
end

-- Cooldown Manager root frames mapping (declared at module scope for efficiency)
local cooldownManagerRootFrames = {
    COOLDOWN_ESSENTIALS     = _G.EssentialCooldownViewer,
    COOLDOWN_UTILITY        = _G.UtilityCooldownViewer,
    COOLDOWN_TRACKED_BUFFS  = _G.BuffIconCooldownViewer,
    COOLDOWN_TRACKED_BARS   = _G.BuffBarCooldownViewer,
}

-- Cooldown Manager anchor detection
local function GetCooldownManagerAnchor( category )
    if not C_CooldownViewer or not C_CooldownViewer.IsCooldownViewerAvailable() then return nil end

    local root = cooldownManagerRootFrames[ category ]
    if not root then
        Hekili:Print( "Cooldown Manager anchor category '%s' not mapped to a root frame.", category )
        return nil
    end

    for i = 1, root:GetNumChildren() do
        local child = select(i, root:GetChildren())
        if child and child:IsShown() then
            return child
        end
    end

    return nil
end

-- Core anchoring function
local function TrySetAnchor( d, conf )
    local anchor = DisplayAnchorUtils.GetActiveAnchorFrame( conf )

    if not anchor or not anchor:IsShown() then
        return false
    end

    d:ClearAllPoints()

    if conf.anchorTarget ~= "SCREEN" then
        if conf.obeyAnchorScale == false then
            d:SetParent( UIParent )
            d:SetScale( Hekili:GetScale() )
        else
            d:SetParent( anchor )
            d:SetScale( 1 ) -- reset to inherit
        end
    end

    d:SetPoint(
        conf.anchorPoint or "CENTER",
        anchor,
        conf.relativePoint or "CENTER",
        conf.anchorX or 0,
        conf.anchorY or 0
    )

    return true
end

-- Mover frame configuration utility
function DisplayAnchorUtils.ConfigureMoverFrame( frame, isAnchored, isConfigMode )
    if not frame or not frame.Backdrop then return end

    if isAnchored then
        -- Anchored to something - disable and hide mover
        frame:SetMovable(false)
        frame:EnableMouse(false)
        frame.Backdrop:EnableMouse(false)
        frame.Backdrop:SetMovable(false)
        if not isConfigMode then
            frame.Backdrop:Hide()
        end
    else
        -- Screen positioning - enable and show mover when in config mode
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame.Backdrop:EnableMouse(true)
        frame.Backdrop:SetMovable(true)
        if isConfigMode then
            frame.Backdrop:Show()
        end
    end
end

-- Evaluate and update all display anchors
function DisplayAnchorUtils.EvaluateDisplayAnchors()
    for id, display in pairs( ns.UI.Displays ) do
        local conf = Hekili.DB.profile.displays[ id ]
        if display and conf then
            TrySetAnchor( display, conf )
        end
    end
end

-- Get or create proxy frames
function DisplayAnchorUtils.GetProxyFrame( anchorTarget )
    if anchorTarget == "TARGET" then
        proxyFrames.TARGET = proxyFrames.TARGET or CreateFrame( "Frame", "HekiliAnchorProxy_TargetNameplate", UIParent )
        proxyFrames.TARGET:SetSize( 1, 1 )
        return proxyFrames.TARGET


    elseif anchorTarget == "SCREEN" then
        proxyFrames.SCREEN = proxyFrames.SCREEN or CreateFrame( "Frame", "HekiliAnchorProxy_Screen", UIParent )
        proxyFrames.SCREEN:SetSize( 1, 1 )
        proxyFrames.SCREEN:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
        return proxyFrames.SCREEN
    end
end

-- Update target nameplate proxy
function DisplayAnchorUtils.UpdateTargetNameplateProxy()
    local proxy = DisplayAnchorUtils.GetProxyFrame( "TARGET" )
    if not proxy then return end

    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit( "target" )

    if plate and plate:IsShown() then
        proxy:ClearAllPoints()
        proxy:SetPoint( "CENTER", plate, "CENTER", 0, 0 )
        proxy:Show()
    else
        proxy:Hide()
    end
end


-- Get active anchor frame for configuration
function DisplayAnchorUtils.GetActiveAnchorFrame( conf )
    local target = conf.anchorTarget

    if target == "PRIMARY" then
        return ns.UI.Displays.Primary

    elseif target == "TARGET" then
        local nameplate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit( "target" )
        if nameplate and nameplate:IsShown() then return nameplate end
        local proxy = DisplayAnchorUtils.GetProxyFrame( "TARGET" )
        return proxy:IsShown() and proxy or nil

    elseif target == "COOLDOWN_ESSENTIALS"
    or target == "COOLDOWN_UTILITY"
    or target == "COOLDOWN_TRACKED_BUFFS"
    or target == "COOLDOWN_TRACKED_BARS" then

        return GetCooldownManagerAnchor(target)

    end
    return nil
end

-- Check if real anchor is available
function DisplayAnchorUtils.IsRealAnchorAvailable( anchorTarget )
    if anchorTarget == "PRIMARY" then
        return ns.UI.Displays.Primary and ns.UI.Displays.Primary:IsShown()


    elseif anchorTarget == "TARGET" then
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit( "target" )
        return plate and plate:IsShown()

    elseif anchorTarget == "COOLDOWN_ESSENTIALS"
        or anchorTarget == "COOLDOWN_UTILITY"
        or anchorTarget == "COOLDOWN_TRACKED_BUFFS"
        or anchorTarget == "COOLDOWN_TRACKED_BARS" then

        local anchor = GetCooldownManagerAnchor( anchorTarget )
        return anchor and anchor:IsShown()
    end
end

-- Export public interface
DisplayAnchorUtils.TrySetAnchor = TrySetAnchor
DisplayAnchorUtils.GetPersonalResourceAnchor = GetPersonalResourceAnchor
DisplayAnchorUtils.GetCooldownManagerAnchor = GetCooldownManagerAnchor

-- Attach to Hekili namespace for backward compatibility
Hekili.TrySetAnchor = TrySetAnchor
Hekili.EvaluateDisplayAnchors = DisplayAnchorUtils.EvaluateDisplayAnchors
Hekili.GetProxyFrame = DisplayAnchorUtils.GetProxyFrame
Hekili.UpdateTargetNameplateProxy = DisplayAnchorUtils.UpdateTargetNameplateProxy
Hekili.GetActiveAnchorFrame = DisplayAnchorUtils.GetActiveAnchorFrame
Hekili.IsRealAnchorAvailable = DisplayAnchorUtils.IsRealAnchorAvailable

-- Store in namespace for other modules
ns.DisplayAnchorUtils = DisplayAnchorUtils

return DisplayAnchorUtils