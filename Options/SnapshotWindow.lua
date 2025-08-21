-- Snapshot window implementation inspired by https://github.com/simulationcraft/simc-addon
-- Credit to SimulationCraft addon authors for the user-friendly popup window design

local addon, ns = ...
local Hekili = _G[ addon ]

local SnapshotWindow = {}
ns.SnapshotWindow = SnapshotWindow

local SnapshotFrame = nil

function SnapshotWindow:GetSnapshotFrame( snapshotText )
    if not SnapshotFrame then
        -- Get or create saved settings
        if not Hekili.DB.profile.snapshots then
            Hekili.DB.profile.snapshots = {}
        end
        if not Hekili.DB.profile.snapshots.window then
            Hekili.DB.profile.snapshots.window = {
                point = "CENTER",
                relativeFrame = nil,
                relativePoint = "CENTER",
                ofsx = 0,
                ofsy = 0,
                width = 750,
                height = 500,
                closeOnCopy = true,
            }
        end
        local frameConfig = Hekili.DB.profile.snapshots.window

        -- Main Frame
        local f = CreateFrame( "Frame", "HekiliSnapshotFrame", UIParent, "DialogBoxFrame" )
        f:ClearAllPoints()
        f:SetPoint(
            frameConfig.point,
            frameConfig.relativeFrame,
            frameConfig.relativePoint,
            frameConfig.ofsx,
            frameConfig.ofsy
        )
        f:SetSize( frameConfig.width, frameConfig.height )
        f:SetBackdrop( {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
            edgeSize = 16,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        } )
        f:SetMovable( true )
        f:SetClampedToScreen( true )
        f:SetScript( "OnMouseDown", function( self, button )
            if button == "LeftButton" then
                self:StartMoving()
            end
        end )
        f:SetScript( "OnMouseUp", function( self, _ )
            self:StopMovingOrSizing()
            -- Save position between sessions
            local point, relativeFrame, relativeTo, ofsx, ofsy = self:GetPoint()
            frameConfig.point = point
            frameConfig.relativeFrame = relativeFrame
            frameConfig.relativePoint = relativeTo
            frameConfig.ofsx = ofsx
            frameConfig.ofsy = ofsy
        end )
        f:SetScript( "OnHide", function( self )
            -- Restore the settings window when snapshot window is closed
            if self.wasSettingsVisible then
                -- Use a timer to try and avoid frame state conflicts during hide events
                C_Timer.After( 0.1, function()
                    -- Try even more stuff to prevent AceConfigDialog errors
                    local success, ACD = pcall( function() return LibStub( "AceConfigDialog-3.0" ) end )
                    if not success then return end

                    -- Check if ACD is in a valid state before proceeding
                    if not ACD or not ACD.Open or not ACD.SelectGroup then return end

                    -- Try to restore, but silently fail if there are issues
                    -- Spoiler alert, it triggers a rootframe error, but still works 100% and doesn't seem to affect anything.
                    local restoreSuccess = pcall( function()
                        ACD:Open( "Hekili" )
                        ACD:SelectGroup( "Hekili", "snapshots" )
                    end )

                    -- If restore failed, just let the user manually reopen settings
                    if not restoreSuccess then
                    end
                end )
            end
        end )

        -- Title
        local title = f:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" )
        title:SetPoint( "TOP", f, "TOP", 0, -12 )
        title:SetText( "Hekili Snapshot" )

        -- Scroll frame
        local sf = CreateFrame( "ScrollFrame", "HekiliSnapshotScrollFrame", f, "UIPanelScrollFrameTemplate" )
        sf:SetPoint( "LEFT", 16, 0 )
        sf:SetPoint( "RIGHT", -32, 0 )
        sf:SetPoint( "TOP", 0, -40 )
        sf:SetPoint( "BOTTOM", HekiliSnapshotFrameButton, "TOP", 0, 0 )

        -- Edit box
        local ctrlDown = false
        local eb = CreateFrame( "EditBox", "HekiliSnapshotEditBox", HekiliSnapshotScrollFrame )
        eb:SetSize( sf:GetSize() )
        eb:SetMultiLine( true )
        eb:SetAutoFocus( true )
        eb:SetFontObject( "ChatFontNormal" )
        eb:SetScript( "OnEscapePressed", function() f:Hide() end )
        eb:SetScript( "OnKeyDown", function( self, key )
            if key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA" then
                ctrlDown = true
            end
        end )
        eb:SetScript( "OnKeyUp", function( self, key )
            if key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA" then
                C_Timer.After( 0.2, function() ctrlDown = false end )
            end
            if ctrlDown then
                -- Handle copy or cut
                if key == "C" or key == "X" then
                    if frameConfig.closeOnCopy then
                        -- Make sure the copy happens before frame goes away
                        C_Timer.After( 0.1, function()
                            f:Hide()
                        end )
                    end
                end
            end
        end )
        sf:SetScrollChild( eb )

        f:SetResizable( true )
        if f.SetMinResize then
            -- We probably don't need this? Just in case
            f:SetMinResize( 400, 300 )
        else
            -- This is probably sufficient, for retail atleast
            f:SetResizeBounds( 400, 300, nil, nil )
        end
        local rb = CreateFrame( "Button", "HekiliSnapshotResizeButton", f )
        rb:SetPoint( "BOTTOMRIGHT", -6, 7 )
        rb:SetSize( 16, 16 )

        rb:SetNormalTexture( "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up" )
        rb:SetHighlightTexture( "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight" )
        rb:SetPushedTexture( "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down" )

        rb:SetScript( "OnMouseDown", function( self, button )
            if button == "LeftButton" then
                f:StartSizing( "BOTTOMRIGHT" )
                self:GetHighlightTexture():Hide()
            end
        end )
        rb:SetScript( "OnMouseUp", function( self, _ )
            f:StopMovingOrSizing()
            self:GetHighlightTexture():Show()
            eb:SetWidth( sf:GetWidth() )

            frameConfig.width = f:GetWidth()
            frameConfig.height = f:GetHeight()
        end )

        -- Close on copy checkbox
        local checkbox = CreateFrame( "CheckButton", "HekiliSnapshotCloseOnCopy", f, "ChatConfigCheckButtonTemplate" )
        checkbox:SetPoint( "BOTTOMLEFT", 12, 18 )
        checkbox.Text:SetText( "Close after copy" )
        checkbox:SetChecked( frameConfig.closeOnCopy )
        checkbox:HookScript( "OnClick", function( self )
            frameConfig.closeOnCopy = self:GetChecked()
        end )

        -- Instructions text
        local instructions = f:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
        instructions:SetPoint( "BOTTOMLEFT", checkbox, "BOTTOMRIGHT", 180, 4 )
        instructions:SetPoint( "BOTTOMRIGHT", -12, 22 )
        instructions:SetJustifyH( "LEFT" )
        instructions:SetText( "Press Ctrl+A to select all, then Ctrl+C to copy. Text is pre-selected for your convenience." )
        instructions:SetTextColor( 0.8, 0.8, 0.8, 1 )

        SnapshotFrame = f
    end

    -- Set the snapshot text and highlight it
    HekiliSnapshotEditBox:SetText( snapshotText )
    HekiliSnapshotEditBox:HighlightText()
    HekiliSnapshotEditBox:SetFocus()

    return SnapshotFrame
end

function SnapshotWindow:ShowSnapshot( snapshotText )
    if not snapshotText or snapshotText == "" then
        Hekili:Print( "No snapshot data available." )
        return
    end

    -- Hide the settings window temporarily with safety checks
    local ACD = LibStub( "AceConfigDialog-3.0" )
    local wasSettingsVisible = false

    -- Safely check if settings window is open and visible
    local success, settingsFrame = pcall( function()
        return ACD.OpenFrames and ACD.OpenFrames[ "Hekili" ]
    end )

    if success and settingsFrame and settingsFrame.frame and settingsFrame.frame:IsVisible() then
        wasSettingsVisible = true
        pcall( function() settingsFrame.frame:Hide() end )
    end

    local frame = self:GetSnapshotFrame( snapshotText )

    -- Store reference to restore settings window when snapshot window closes
    frame.wasSettingsVisible = wasSettingsVisible

    frame:Show()
end

function Hekili:OpenSnapshotWindow( snapshotIndex )
    if not snapshotIndex or snapshotIndex == 0 or not ns.snapshots[ snapshotIndex ] then
        self:Print( "Please select a valid snapshot first." )
        return
    end

    local snapshotData = ns.snapshots[ snapshotIndex ].log
    SnapshotWindow:ShowSnapshot( snapshotData )
end

return SnapshotWindow