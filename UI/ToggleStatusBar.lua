-- ToggleStatusBar.lua
-- Handles the Toggle Status Bar display for showing toggle states

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local CreateFrame = CreateFrame
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local C_Timer = C_Timer
local UIParent = UIParent
local GameTooltip = GameTooltip

local LSM = LibStub( "LibSharedMedia-3.0" )

-- Build the standard toggle status bar
function Hekili:BuildToggleStatusBar()
    -- Ensure we're not called too early or during combat lockdown
    if not self.DB or not self.DB.profile then return end
    if InCombatLockdown() then
        -- Defer creation during combat
        C_Timer.After( 0.1, function() self:BuildToggleStatusBar() end )
        return
    end

    local profile = self.DB.profile
    local barSettings = profile.toggleBar or {}
    if not barSettings.enabled then
        if self.ToggleStatusBar then
            self.ToggleStatusBar:Hide()
            if self.ToggleStatusBar.Backdrop then
                self.ToggleStatusBar.Backdrop:Hide()
            end
        end
        return
    end

    -- Create or reuse the bar frame first
    local bar = self.ToggleStatusBar
    if not bar then
        -- Create frame without any global name
        bar = CreateFrame( "Frame", nil, UIParent, "BackdropTemplate" )
        if not bar then
            -- Fallback without backdrop template
            bar = CreateFrame( "Frame", nil, UIParent )
        end
        self.ToggleStatusBar = bar
    end

    if not bar then return end -- Safety check

    bar:SetMovable( true )
    bar:SetUserPlaced( true )
    bar:SetClampedToScreen( true )
    bar:SetFrameStrata( "MEDIUM" )
    bar:SetFrameLevel( 5 )

    -- Create backdrop frame for mouse handling (like primary displays)
    -- This happens regardless of mode, just like other displays
    bar.Backdrop = bar.Backdrop or CreateFrame( "Frame", nil, UIParent, "BackdropTemplate" )
    bar.Backdrop:ClearAllPoints()
    bar.Backdrop:SetAllPoints( bar )
    bar.Backdrop:SetFrameStrata( bar:GetFrameStrata() )
    bar.Backdrop:SetFrameLevel( bar:GetFrameLevel() + 1 )
    bar.Backdrop.moveObj = bar

    -- Always hide backdrop first (like other displays)
    bar.Backdrop:Hide()

    -- Add mover functionality via backdrop
    bar.Backdrop:EnableMouse( true )
    bar.Backdrop:SetMovable( true )

    -- Set up backdrop appearance (similar to displays)
    bar.Backdrop:SetBackdrop( {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 8, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    } )

    -- Show backdrop if we're currently in config mode
    -- This handles the case where the bar gets rebuilt during config mode
    if Hekili.Config then
        bar.Backdrop:SetBackdropBorderColor( 1, 1, 1, 1 )
        bar.Backdrop:SetBackdropColor( 0, 0, 0, 0.8 )
        bar.Backdrop:Show()
    end

    -- Set up mouse event handlers
    bar.Backdrop:SetScript( "OnMouseDown", function( self, btn )
        local obj = self.moveObj or self
        if Hekili.Config and btn == "LeftButton" and not obj.Moving then
            -- Use existing movement functions from UI.lua scope
            local movementData = Hekili.movementData or {}
            Hekili.movementData = movementData
            movementData.origX, movementData.origY = select( 4, obj:GetPoint() )
            obj:StartMoving()
            movementData.fromX, movementData.fromY = select( 4, obj:GetPoint() )
            obj.Moving = true
        end
    end )

    bar.Backdrop:SetScript( "OnMouseUp", function( self, btn )
        local obj = self.moveObj or self
        if btn == "LeftButton" and obj.Moving then
            -- Use existing movement functions from UI.lua scope
            local movementData = Hekili.movementData or {}
            local resolution = C_VideoOptions.GetCurrentGameWindowSize()
            local scrW, scrH = resolution.x, resolution.y

            local scale, pScale = Hekili:GetScale(), UIParent:GetScale()

            scrW = scrW / ( scale * pScale )
            scrH = scrH / ( scale * pScale )

            local limitX = ( scrW - obj:GetWidth() ) / 2
            local limitY = ( scrH - obj:GetHeight() ) / 2

            movementData.toX, movementData.toY = select( 4, obj:GetPoint() )
            obj:StopMovingOrSizing()
            obj.Moving = false
            obj:ClearAllPoints()
            obj:SetPoint( "CENTER", nil, "CENTER",
                max( -limitX, min( limitX, movementData.origX + ( movementData.toX - movementData.fromX ) ) ),
                max( -limitY, min( limitY, movementData.origY + ( movementData.toY - movementData.fromY ) ) ) )
            Hekili:SaveCoordinates()
        elseif btn == "RightButton" then
            -- Open toggle status bar settings
            LibStub( "AceConfigDialog-3.0" ):SelectGroup( "Hekili", "displays", "toggleBar" )
        end
    end )

    -- Check display mode and route to appropriate function
    local displayMode = barSettings.displayMode or "standard"
    if displayMode == "minimalist" then
        -- Hide any standard mode elements before building minimalist
        if self.ToggleStatusBar and self.ToggleStatusBar.buttons then
            for i = 1, 9 do
                if self.ToggleStatusBar.buttons[ i ] then
                    self.ToggleStatusBar.buttons[ i ]:Hide()
                end
            end
        end
        self:BuildMinimalistToggleBar( bar )
        return
    end

    -- Standard mode continues below
    -- Hide any minimalist mode elements before building standard
    if bar.miniButtons then
        for i = 1, 3 do
            if bar.miniButtons[ i ] then
                bar.miniButtons[ i ]:Hide()
            end
        end
    end

    self:BuildStandardToggleBar( bar )
end

-- Build the standard toggle status bar
function Hekili:BuildStandardToggleBar( bar )
    local barSettings = self.DB.profile.toggleBar or {}

    -- Get configuration values with defaults
    local buttonSize = barSettings.buttonSize or 32
    local spacing = barSettings.spacing or 4

    local isVertical = barSettings.direction == "VERTICAL"
    local maxColumns = barSettings.maxColumns or 9
    local maxRows = barSettings.maxRows or 1

    -- Count enabled toggles only and sort by order
    local enabledToggles = {}
    for i, btnData in ipairs( barSettings ) do
        if btnData.enabled ~= false then
            table.insert( enabledToggles, { index = i, data = btnData } )
        end
    end

    -- Sort by order if specified, otherwise by index
    table.sort( enabledToggles, function( a, b )
        local orderA = a.data.order or a.index
        local orderB = b.data.order or b.index
        return orderA < orderB
    end )

    local count = #enabledToggles
    if count == 0 then
        bar:Hide()
        return
    end

    -- Calculate dimensions based on row/column limits
    local rows, cols
    if isVertical then
        -- For vertical, we fill columns first
        rows = math.min( maxRows, count )
        cols = math.ceil( count / rows )
    else
        -- For horizontal, we fill rows first
        cols = math.min( maxColumns, count )
        rows = math.ceil( count / cols )
    end

    local width = cols * buttonSize + ( cols - 1 ) * spacing
    local height = rows * buttonSize + ( rows - 1 ) * spacing

    bar:SetSize( width, height )
    bar:ClearAllPoints()

    -- Handle anchoring
    local anchorTarget = barSettings.anchorTarget or "UIParent"

    if anchorTarget ~= "UIParent" then
        -- Use the proper anchoring system
        local conf = {
            anchorTarget = anchorTarget == "HekiliDisplay1" and "PRIMARY" or "SCREEN",
            anchorPoint = barSettings.anchor or "CENTER",
            relativePoint = barSettings.anchorPoint or "CENTER",
            anchorX = barSettings.x or 0,
            anchorY = barSettings.y or -200,
        }

        local anchored = Hekili.TrySetAnchor( bar, conf )
        if not anchored then
            -- Fallback to screen positioning
            bar:SetPoint( "CENTER", UIParent, "CENTER", barSettings.x or 0, barSettings.y or -200 )
        end
    else
        -- Screen positioning
        bar:SetPoint( "CENTER", UIParent, "CENTER", barSettings.x or 0, barSettings.y or -200 )
    end

    -- Control mover visibility based on anchor mode using DisplayAnchorUtils
    local isAnchored = ( barSettings.anchorTarget or "UIParent" ) ~= "UIParent"
    ns.DisplayAnchorUtils.ConfigureMoverFrame( bar, isAnchored, Hekili.Config )

    bar:Show()

    bar.buttons = bar.buttons or {}

    -- Hide all existing buttons first
    for i = 1, #bar.buttons do
        if bar.buttons[ i ] then
            bar.buttons[ i ]:Hide()
        end
    end

    -- Use global MasqueGroup if available (like other displays)

    -- Create/update buttons for enabled toggles only
    local buttonIndex = 0
    for j, toggle in ipairs( enabledToggles ) do
        local i = toggle.index
        local btnData = toggle.data

        buttonIndex = buttonIndex + 1
        local btn = bar.buttons[ i ]
        if not btn then
            btn = CreateFrame( "Button", nil, bar )
            btn.icon = btn:CreateTexture( nil, "ARTWORK" )
            btn.icon:SetAllPoints()
            btn.icon:SetTexCoord( 0.08, 0.92, 0.08, 0.92 )

            -- Create label text
            btn.label = btn:CreateFontString( nil, "OVERLAY" )
            local labelFont = barSettings.labelFont or "Friz Quadrata TT"
            btn.label:SetFont( LSM:Fetch( "font", labelFont ), barSettings.labelFontSize or 10 )
            local color = barSettings.labelFontColor or {}
            btn.label:SetTextColor( color.r or 1, color.g or 1, color.b or 1, color.a or 1 )

            -- Create animation group for reactive effects
            btn.animGroup = btn:CreateAnimationGroup()

            -- Pulse animation
            local pulse = btn.animGroup:CreateAnimation( "Scale" )
            pulse:SetDuration( 0.2 )
            pulse:SetScale( 1.2, 1.2 )
            pulse:SetOrder( 1 )

            local pulseBack = btn.animGroup:CreateAnimation( "Scale" )
            pulseBack:SetDuration( 0.2 )
            pulseBack:SetScale( 0.833, 0.833 ) -- 1/1.2 to return to normal
            pulseBack:SetOrder( 2 )

            -- Glow texture
            btn.glow = btn:CreateTexture( nil, "OVERLAY" )
            btn.glow:SetTexture( "Interface\\Buttons\\UI-ActionButton-Border" )
            btn.glow:SetBlendMode( "ADD" )
            btn.glow:SetAlpha( 0 )
            btn.glow:SetAllPoints()
            btn.glow:Hide()  -- Make sure it starts hidden
            btn.glow:SetVertexColor( 1, 1, 1, 0.3 ) -- Make it semi-transparent when shown

            -- Glow animation
            btn.glowAnim = btn.glow:CreateAnimationGroup()
            local fadeIn = btn.glowAnim:CreateAnimation( "Alpha" )
            fadeIn:SetFromAlpha( 0 )
            fadeIn:SetToAlpha( 1 )
            fadeIn:SetDuration( 0.2 )
            fadeIn:SetOrder( 1 )

            local fadeOut = btn.glowAnim:CreateAnimation( "Alpha" )
            fadeOut:SetFromAlpha( 1 )
            fadeOut:SetToAlpha( 0 )
            fadeOut:SetDuration( 0.3 )
            fadeOut:SetOrder( 2 )
            fadeOut:SetStartDelay( 0.2 )

            btn:SetScript( "OnEnter", function( self )
                -- Check if tooltips should be shown
                -- Show tooltips: always in combat, or out of combat only if tooltipOutOfCombat is true
                local showTooltip = InCombatLockdown() or ( barSettings.tooltipOutOfCombat == true )

                if showTooltip then
                    local toggleValue = Hekili:GetToggleState( btnData.toggle )
                    local status = toggleValue and "On" or "Off"

                    GameTooltip:SetOwner( self, "ANCHOR_TOPRIGHT" )
                    GameTooltip:SetText( "Hekili " .. ( btnData.label or btnData.toggle ) .. " Toggle: " .. status )
                    GameTooltip:Show()
                end
            end )
            btn:SetScript( "OnLeave", function()
                GameTooltip:Hide()
            end )

            btn:SetScript( "OnClick", function( self, button )
                if barSettings.clickable and button == "LeftButton" then
                    Hekili:FireToggle( btnData.toggle )
                    -- Update the icon desaturation immediately
                    local value = Hekili:GetToggleState( btnData.toggle )
                    self.icon:SetDesaturated( not value )
                end
            end )

            bar.buttons[ i ] = btn
        end

        btn:SetParent( bar )

        -- Set the button size FIRST before any Masque operations
        btn:SetSize( buttonSize, buttonSize )
        btn:SetWidth( buttonSize )
        btn:SetHeight( buttonSize )

        -- Add to Masque group if available AFTER setting size
        -- Only add if not explicitly disabled due to sizing conflicts
        if self.MasqueToggleGroup and not barSettings.disableMasque then
            self.MasqueToggleGroup:AddButton( btn, {
                Icon = btn.icon,
                Width = buttonSize,
                Height = buttonSize
            } )

            -- Force a reskin with the correct size
            if self.MasqueToggleGroup.ReSkin then
                self.MasqueToggleGroup:ReSkin()
            end
        end

        -- Ensure size is maintained after Masque operations
        btn:SetSize( buttonSize, buttonSize )
        btn:SetWidth( buttonSize )
        btn:SetHeight( buttonSize )

        -- Also ensure icon texture sizing is correct
        if btn.icon then
            btn.icon:SetAllPoints( btn )
        end

        -- Ensure glow texture is properly configured after Masque
        if btn.glow then
            btn.glow:Hide()
            btn.glow:SetAlpha( 0 )
            btn.glow:SetTexture( "Interface\\Buttons\\UI-ActionButton-Border" )
            btn.glow:SetAllPoints( btn )
        end

        -- Final pass to ensure Masque elements respect our button size
        if not barSettings.disableMasque and self.MasqueToggleGroup then
            -- Schedule a delayed resize to ensure Masque elements are properly sized
            C_Timer.After( 0.01, function()
                if btn and btn:IsShown() then
                    -- Resize Masque background elements to match button size
                    if btn.__MSQ_NormalTexture then
                        btn.__MSQ_NormalTexture:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_NormalTexture:SetAllPoints( btn )
                    end
                    if btn.__MSQ_Border then
                        btn.__MSQ_Border:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_Border:SetAllPoints( btn )
                    end
                    if btn.__MSQ_Background then
                        btn.__MSQ_Background:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_Background:SetAllPoints( btn )
                    end
                    if btn.__MSQ_Highlight then
                        btn.__MSQ_Highlight:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_Highlight:SetAllPoints( btn )
                    end
                    if btn.__MSQ_Pushed then
                        btn.__MSQ_Pushed:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_Pushed:SetAllPoints( btn )
                    end
                    if btn.__MSQ_Disabled then
                        btn.__MSQ_Disabled:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_Disabled:SetAllPoints( btn )
                    end
                    if btn.__MSQ_Flash then
                        btn.__MSQ_Flash:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_Flash:SetAllPoints( btn )
                    end
                    if btn.__MSQ_Gloss then
                        btn.__MSQ_Gloss:SetSize( buttonSize, buttonSize )
                        btn.__MSQ_Gloss:SetAllPoints( btn )
                    end
                end
            end )
        end

        -- Update label settings
        if btn.label then
            btn.label:SetText( barSettings.showLabels and ( btnData.label or btnData.toggle ) or "" )
            btn.label:ClearAllPoints()

            -- Update font and font size
            local labelFont = barSettings.labelFont or "Friz Quadrata TT"
            local fontSize = barSettings.labelFontSize or 10
            btn.label:SetFont( LSM:Fetch( "font", labelFont ), fontSize )

            -- Update font color
            local color = barSettings.labelFontColor or {}
            btn.label:SetTextColor( color.r or 1, color.g or 1, color.b or 1, color.a or 1 )

            local labelPos = barSettings.labelPosition or "BOTTOM"
            if labelPos == "TOP" then
                btn.label:SetPoint( "BOTTOM", btn, "TOP", 0, 2 )
            elseif labelPos == "BOTTOM" then
                btn.label:SetPoint( "TOP", btn, "BOTTOM", 0, -2 )
            elseif labelPos == "LEFT" then
                btn.label:SetPoint( "RIGHT", btn, "LEFT", -2, 0 )
            elseif labelPos == "RIGHT" then
                btn.label:SetPoint( "LEFT", btn, "RIGHT", 2, 0 )
            end
        end

        -- Position calculation based on layout direction
        local row, col, xPos, yPos
        if isVertical then
            -- For vertical, fill top to bottom, then left to right
            col = math.floor( ( buttonIndex - 1 ) / rows )
            row = ( buttonIndex - 1 ) % rows
            xPos = col * ( buttonSize + spacing )
            yPos = -row * ( buttonSize + spacing )
        else
            -- For horizontal, fill left to right, then top to bottom
            row = math.floor( ( buttonIndex - 1 ) / cols )
            col = ( buttonIndex - 1 ) % cols
            xPos = col * ( buttonSize + spacing )
            yPos = -row * ( buttonSize + spacing )
        end

        -- Update icon - use custom icon if provided, otherwise use defaults
        if btnData.icon then
            btn.icon:SetTexture( btnData.icon )
        else
            -- Fallback to default icons based on toggle type
            local defaultIcons = {
                cooldowns = 6352455,
                essences = 132329,
                defensives = 134950,
                interrupts = 132219,
                potions = 134813,
                custom1 = 134400,
                custom2 = 134400
            }
            btn.icon:SetTexture( defaultIcons[ btnData.toggle ] or 132329 )
        end

        local value = Hekili:GetToggleState( btnData.toggle )
        btn.icon:SetDesaturated( not value )

        -- Ensure glow texture is properly hidden and reset
        if btn.glow then
            btn.glow:Hide()
            btn.glow:SetAlpha( 0 )
            btn.glow:SetTexture( "Interface\\Buttons\\UI-ActionButton-Border" )
        end

        -- Position the button (size was already set after Masque)
        btn:ClearAllPoints()
        btn:SetPoint( "TOPLEFT", bar, "TOPLEFT", xPos, yPos )
        btn:Show()
    end

    -- Disable button mouse interaction if we're in config mode (like primary displays)
    if Hekili.Config and bar.buttons then
        for i = 1, 9 do
            if bar.buttons[ i ] then
                bar.buttons[ i ]:EnableMouse( false )
            end
        end
    end
end

-- Build the minimalist toggle bar
function Hekili:BuildMinimalistToggleBar( bar )
    local barSettings = self.DB.profile.toggleBar or {}

    -- Hide all standard mode buttons
    if bar.buttons then
        for i = 1, 9 do
            if bar.buttons[ i ] then
                bar.buttons[ i ]:Hide()
            end
        end
    end

    -- Get minimalist settings
    local indicatorStyle = barSettings.minimalistStyle or "dots"
    local indicatorSize = barSettings.minimalistSize or 12
    local spacing = barSettings.minimalistSpacing or 2
    local anchorMode = barSettings.minimalistAnchor or "primary"
    local layoutStyle = barSettings.minimalistLayout or "horizontal"
    local curveAngle = barSettings.minimalistAngle or 0
    local enabledColor = barSettings.minimalistColorEnabled or { r = 0, g = 1, b = 0, a = 1 }
    local disabledColor = barSettings.minimalistColorDisabled or { r = 0.5, g = 0.5, b = 0.5, a = 1 }

    -- Get active toggles (up to 3)
    local activeToggles = {}
    local toggleMap = {
        cooldowns = { index = 1, label = "CDs" },
        essences = { index = 2, label = "Min" },
        defensives = { index = 3, label = "Def" },
        interrupts = { index = 4, label = "Int" },
        potions = { index = 5, label = "Pot" }
    }

    for i = 1, 3 do
        local toggleName = barSettings["minimalistToggle" .. i]
        if toggleName and toggleName ~= "none" and toggleMap[toggleName] then
            table.insert( activeToggles, {
                name = toggleName,
                data = toggleMap[toggleName]
            } )
        end
    end

    local count = #activeToggles
    if count == 0 then
        bar:Hide()
        return
    end

    -- Calculate bar size to accommodate the chosen pattern
    local baseDistance = ( indicatorSize * 0.3 ) + spacing -- Distance between dot centers
    local curveOffset = math.abs( curveAngle ) / 90 * baseDistance -- Maximum curve offset

    if layoutStyle == "horizontal" then
        width = baseDistance * 2 + indicatorSize -- Space for 3 dots horizontally
        height = curveOffset + indicatorSize -- Include curve offset in height
    elseif layoutStyle == "vertical" then
        width = curveOffset + indicatorSize -- Include curve offset in width
        height = baseDistance * 2 + indicatorSize -- Space for 3 dots vertically
    end

    bar:SetSize( width, height )
    bar:ClearAllPoints()

    -- Handle anchoring
    if anchorMode == "primary" then
        -- Use the proper anchoring system for primary display
        local conf = {
            anchorTarget = "PRIMARY",
            anchorPoint = barSettings.minimalistFromPoint or "TOP",
            relativePoint = barSettings.minimalistAnchorPoint or "BOTTOM",
            anchorX = barSettings.minimalistPrimaryX or 0,
            anchorY = barSettings.minimalistPrimaryY or -5,
        }

        local anchored = Hekili.TrySetAnchor( bar, conf )
        if not anchored then
            -- Fallback if primary display not available
            bar:SetPoint( "CENTER", UIParent, "CENTER", 0, -100 )
        end
    else
        -- Free positioning (screen)
        local xOffset = barSettings.minimalistX or 0
        local yOffset = barSettings.minimalistY or 0
        bar:SetPoint( "CENTER", UIParent, "CENTER", xOffset, yOffset )
    end

    -- Control mover visibility based on anchor mode using DisplayAnchorUtils
    local isAnchored = ( barSettings.minimalistAnchor or "primary" ) == "primary"
    ns.DisplayAnchorUtils.ConfigureMoverFrame( bar, isAnchored, Hekili.Config )

    bar:Show()

    -- Create minimalist indicators
    bar.miniButtons = bar.miniButtons or {}

    for i = 1, 3 do
        local btn = bar.miniButtons[ i ]
        if not btn then
            btn = CreateFrame( "Button", nil, bar )

            -- Create the indicator based on style
            if indicatorStyle == "mini" then
                -- Mini icons
                btn.icon = btn:CreateTexture( nil, "ARTWORK" )
                btn.icon:SetAllPoints()
                btn.icon:SetTexCoord( 0.08, 0.92, 0.08, 0.92 )
            else
                -- Text-based indicators (dots, circles, squares)
                btn.text = btn:CreateFontString( nil, "OVERLAY" )
                btn.text:SetFont( "Fonts\\FRIZQT__.TTF", indicatorSize )
                btn.text:SetAllPoints()
            end

            -- Create label text for minimalist mode
            btn.label = btn:CreateFontString( nil, "OVERLAY" )
            local labelFont = barSettings.labelFont or "Friz Quadrata TT"
            btn.label:SetFont( LSM:Fetch( "font", labelFont ), barSettings.labelFontSize or 10 )
            local color = barSettings.labelFontColor or {}
            btn.label:SetTextColor( color.r or 1, color.g or 1, color.b or 1, color.a or 1 )

            btn:SetScript( "OnEnter", function( self )
                if self.toggleData then
                    -- Check tooltip settings - only show if in combat OR if tooltipOutOfCombat is enabled
                    local showTooltip = InCombatLockdown() or ( barSettings.tooltipOutOfCombat == true )

                    if showTooltip then
                        local toggleValue = Hekili:GetToggleState( self.toggleData.name )
                        local status = toggleValue and "On" or "Off"

                        GameTooltip:SetOwner( self, "ANCHOR_TOP" )
                        GameTooltip:SetText( self.toggleData.data.label .. ": " .. status )
                        GameTooltip:Show()
                    end
                end
            end )

            btn:SetScript( "OnLeave", function()
                GameTooltip:Hide()
            end )

            btn:SetScript( "OnClick", function( self, button )
                if barSettings.clickable and button == "LeftButton" and self.toggleData then
                    Hekili:FireToggle( self.toggleData.name )
                    self:UpdateIndicator()
                end
            end )

            -- Add update function
            btn.UpdateIndicator = function( self )
                if not self.toggleData then return end

                local value = Hekili:GetToggleState( self.toggleData.name )

                if indicatorStyle == "mini" and self.icon then
                    self.icon:SetDesaturated( not value )
                    self.icon:SetAlpha( value and 1 or 0.3 )
                elseif self.text then
                    -- Get current color settings dynamically
                    local currentSettings = Hekili.DB.profile.toggleBar or {}
                    local currentEnabledColor = currentSettings.minimalistColorEnabled or { r = 0, g = 1, b = 0, a = 1 }
                    local currentDisabledColor = currentSettings.minimalistColorDisabled or { r = 0.5, g = 0.5, b = 0.5, a = 1 }

                    -- Set color based on state using current colors
                    local color = value and currentEnabledColor or currentDisabledColor
                    self.text:SetTextColor( color.r, color.g, color.b, color.a )
                end
            end

            bar.miniButtons[ i ] = btn
        end

        -- Update button for current toggle
        if i <= count then
            local toggle = activeToggles[i]
            btn.toggleData = toggle

            -- Set indicator content first
            if indicatorStyle == "mini" and btn.icon then
                -- Use mini icons from the toggle map
                local iconMap = {
                    cooldowns = 6352455,
                    essences = 132329,
                    defensives = 134950,
                    interrupts = 132219,
                    potions = 134813
                }
                btn.icon:SetTexture( iconMap[ toggle.name ] or 132329 )
            elseif btn.text then
                -- Set text based on style
                local symbols = {
                    dots = "•",
                    circles = "○",
                    squares = "□"
                }
                btn.text:SetText( symbols[ indicatorStyle ] or "•" )
            end

            -- Add to Masque group if available and button has icon
            -- Only add if not explicitly disabled due to sizing conflicts
            if self.MasqueToggleGroup and btn.icon and not barSettings.disableMasque then
                self.MasqueToggleGroup:AddButton( btn, { Icon = btn.icon } )
            end

            -- Set size and position AFTER Masque to override skin sizing
            -- Use multiple methods to ensure size sticks with Masque
            btn:SetSize( indicatorSize, indicatorSize )
            btn:SetWidth( indicatorSize )
            btn:SetHeight( indicatorSize )

            -- Also ensure icon texture sizing is correct
            if btn.icon then
                btn.icon:SetAllPoints( btn )
            end

            -- Immediately resize Masque elements after size change
            if not barSettings.disableMasque and self.MasqueToggleGroup and btn.icon then
                -- Resize Masque background elements to match new button size
                if btn.__MSQ_NormalTexture then btn.__MSQ_NormalTexture:SetAllPoints( btn ) end
                if btn.__MSQ_Border then btn.__MSQ_Border:SetAllPoints( btn ) end
                if btn.__MSQ_Background then btn.__MSQ_Background:SetAllPoints( btn ) end
                if btn.__MSQ_Highlight then btn.__MSQ_Highlight:SetAllPoints( btn ) end
                if btn.__MSQ_Pushed then btn.__MSQ_Pushed:SetAllPoints( btn ) end
                if btn.__MSQ_Disabled then btn.__MSQ_Disabled:SetAllPoints( btn ) end
                if btn.__MSQ_Flash then btn.__MSQ_Flash:SetAllPoints( btn ) end
                if btn.__MSQ_Gloss then btn.__MSQ_Gloss:SetAllPoints( btn ) end
            end

            -- Find the corresponding button config to get custom label
            local customLabel = nil
            for j = 1, 9 do
                local btnData = barSettings[j]
                if btnData and btnData.toggle == toggle.name then
                    customLabel = btnData.label
                    break
                end
            end

            -- Update label settings
            if btn.label then
                btn.label:SetText( barSettings.showLabels and ( customLabel or toggle.data.label ) or "" )
                btn.label:ClearAllPoints()

                -- Update font and font size
                local labelFont = barSettings.labelFont or "Friz Quadrata TT"
                local fontSize = barSettings.labelFontSize or 10
                btn.label:SetFont( LSM:Fetch( "font", labelFont ), fontSize )

                -- Update font color
                local color = barSettings.labelFontColor or {}
                btn.label:SetTextColor( color.r or 1, color.g or 1, color.b or 1, color.a or 1 )

                local labelPos = barSettings.labelPosition or "BOTTOM"
                if labelPos == "TOP" then
                    btn.label:SetPoint( "BOTTOM", btn, "TOP", 0, 2 )
                elseif labelPos == "BOTTOM" then
                    btn.label:SetPoint( "TOP", btn, "BOTTOM", 0, -2 )
                elseif labelPos == "LEFT" then
                    btn.label:SetPoint( "RIGHT", btn, "LEFT", -2, 0 )
                elseif labelPos == "RIGHT" then
                    btn.label:SetPoint( "LEFT", btn, "RIGHT", 2, 0 )
                end
            end

            -- Set button size for minimalist mode
            btn:SetSize( indicatorSize, indicatorSize )

            -- Update font size for text indicators to match button size
            if btn.text then
                btn.text:SetFont( "Fonts\\FRIZQT__.TTF", indicatorSize )
            end

            -- Position button based on layout style
            btn:ClearAllPoints()

            -- Calculate dot position using curve angle
            -- Start with a much smaller base distance, then add spacing
            local baseDistance = ( indicatorSize * 0.3 ) + spacing
            local xPos, yPos = 0, 0

            -- Calculate base positions for straight line
            if layoutStyle == "horizontal" then
                -- Horizontal: left, center, right
                xPos = ( i - 2 ) * baseDistance -- i=1 gives -10, i=2 gives 0, i=3 gives 10
                yPos = 0

                -- Apply curve by offsetting perpendicular (Y axis for horizontal)
                if curveAngle ~= 0 then
                    -- Create a curve by offsetting middle dot and pulling end dots inward
                    local curveAmount = curveAngle / 90 * baseDistance -- Scale curve to spacing
                    if i == 2 then
                        -- Middle dot: push out perpendicular to the line
                        yPos = curveAmount
                    else
                        -- End dots: pull inward toward the curve (consistent direction)
                        yPos = curveAmount * 0.3
                    end
                end
            elseif layoutStyle == "vertical" then
                -- Vertical: top, center, bottom
                xPos = 0
                yPos = ( 2 - i ) * baseDistance -- i=1 gives 10, i=2 gives 0, i=3 gives -10

                -- Apply curve by offsetting perpendicular (X axis for vertical)
                if curveAngle ~= 0 then
                    -- Create a curve by offsetting middle dot and pulling end dots inward
                    local curveAmount = curveAngle / 90 * baseDistance -- Scale curve to spacing
                    if i == 2 then
                        -- Middle dot: push out perpendicular to the line
                        xPos = curveAmount
                    else
                        -- End dots: pull inward toward the curve (consistent direction)
                        xPos = curveAmount * 0.3
                    end
                end
            end

            btn:SetPoint( "CENTER", bar, "CENTER", xPos, yPos )

            btn:UpdateIndicator()
            btn:Show()
        else
            btn:Hide()
        end
    end

    -- Disable button mouse interaction if we're in config mode (like primary displays)
    if Hekili.Config and bar.miniButtons then
        for i = 1, 3 do
            if bar.miniButtons[ i ] then
                bar.miniButtons[ i ]:EnableMouse( false )
            end
        end
    end
end

-- Trigger animation when a toggle changes
function Hekili:TriggerToggleAnimation( toggleName )
    if not self.ToggleStatusBar then return end

    local barSettings = self.DB.profile.toggleBar or {}
    if not barSettings.enabled then return end

    local displayMode = barSettings.displayMode or "standard"

    if displayMode == "minimalist" then
        -- Trigger animation on minimalist indicators
        if self.ToggleStatusBar.miniButtons then
            for i = 1, 3 do
                local btn = self.ToggleStatusBar.miniButtons[ i ]
                if btn and btn:IsShown() and btn.toggleData and btn.toggleData.name == toggleName then
                    -- Update the indicator immediately
                    btn:UpdateIndicator()
                    break
                end
            end
        end
    else
        -- Trigger animation on standard buttons
        if self.ToggleStatusBar.buttons then
            for i = 1, 9 do
                local btn = self.ToggleStatusBar.buttons[ i ]
                if btn and btn:IsShown() then
                    local btnData = barSettings[i]
                    if btnData and btnData.toggle == toggleName then
                        -- Trigger pulse animation
                        if btn.animGroup then
                            btn.animGroup:Play()
                        end
                        -- Trigger glow animation
                        if btn.glowAnim then
                            btn.glowAnim:Play()
                        end
                        -- Update desaturation immediately
                        local value = self:GetToggleState( btnData.toggle )
                        btn.icon:SetDesaturated( not value )
                        break
                    end
                end
            end
        end
    end
end

-- Update toggle bar when a toggle state changes
function Hekili:UpdateToggleBar()
    if not self.ToggleStatusBar then return end

    local barSettings = self.DB.profile.toggleBar or {}
    if not barSettings.enabled then return end

    local displayMode = barSettings.displayMode or "standard"

    if displayMode == "minimalist" then
        -- Update minimalist indicators
        if self.ToggleStatusBar.miniButtons then
            for i = 1, 3 do
                local btn = self.ToggleStatusBar.miniButtons[ i ]
                if btn and btn:IsShown() and btn.UpdateIndicator then
                    btn:UpdateIndicator()
                end
            end
        end
    else
        -- Update standard buttons
        if self.ToggleStatusBar.buttons then
            for i = 1, 9 do
                local btn = self.ToggleStatusBar.buttons[ i ]
                if btn and btn:IsShown() then
                    local btnData = barSettings[i]
                    if btnData then
                        local value = self:GetToggleState( btnData.toggle )
                        btn.icon:SetDesaturated( not value )
                    end
                end
            end
        end
    end
end