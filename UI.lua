-- UI.lua
-- Dynamic UI Elements

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local getInverseDirection = ns.getInverseDirection
local multiUnpack = ns.multiUnpack
local orderedPairs = ns.orderedPairs
local round = ns.round

local string_format = string.format


local Masque, MasqueGroup
local UIDropDownMenuTemplate = L_UIDropDownMenuTemplate
local UIDropDownMenu_AddButton = L_UIDropDownMenu_AddButton
local UIDropDownMenu_AddSeparator = L_UIDropDownMenu_AddSeparator


function Hekili:GetScale()
    local monitorIndex = ( tonumber(GetCVar('gxMonitor')) or 0 ) + 1
    local resolutions = { GetScreenResolutions() }
    local resolution = resolutions[ GetCurrentResolution() ] or GetCVar("gxWindowedResolution")

    return GetCVar( "UseUIScale" ) == "1" and ( GetScreenHeight() / resolution:match("%d+x(%d+)") ) or 1
end


local movementData = {}

local function startScreenMovement( frame )
  _, _, _, movementData.origX, movementData.origY = frame:GetPoint()
  frame:StartMoving()
  _, _, _, movementData.fromX, movementData.fromY = frame:GetPoint()
  frame.Moving = true
end


local function stopScreenMovement( frame )
    local monitor = ( tonumber(GetCVar('gxMonitor')) or 0 ) + 1
    local resolutions = { GetScreenResolutions() }
    local resolution = resolutions[ GetCurrentResolution() ] or GetCVar("gxWindowedResolution")

    local scrW, scrH = resolution:match("(%d+)x(%d+)")
    local scale = Hekili:GetScale()

    scrW = scrW * scale
    scrH = scrH * scale

    local limitX = ( scrW - frame:GetWidth() ) / 2
    local limitY = ( scrH - frame:GetHeight() ) / 2

    _, _, _, movementData.toX, movementData.toY = frame:GetPoint()
    frame:StopMovingOrSizing()
    frame.Moving = false
    frame:ClearAllPoints()
    frame:SetPoint( "CENTER", Screen, "CENTER", max( -limitX, min( limitX, movementData.origX + ( movementData.toX - movementData.fromX ) ) ), max( -limitY, min( limitY, movementData.origY + ( movementData.toY - movementData.fromY ) ) ) )
    Hekili:SaveCoordinates()
end


local function Mover_OnMouseUp( self, btn )
  if ( btn == "LeftButton" and self.Moving ) then
    stopScreenMovement( self )
  elseif ( btn == "RightButton" and not Hekili.Config ) then
    if self.Moving then
      stopScreenMovement( self )
    end
    Hekili.DB.profile.Locked = true
    local MouseInteract = Hekili.Pause or Hekili.Config or not Hekili.DB.profile.Locked
    for i = 1, #ns.UI.Buttons do
      for j = 1, #ns.UI.Buttons[i] do
        ns.UI.Buttons[i][j]:EnableMouse( MouseInteract )
      end
    end
    ns.UI.Notification:EnableMouse( Hekili.Config or ( not Hekili.DB.profile.Locked ) )
    -- Hekili:SetOption( { "locked" }, true )
    GameTooltip:Hide()
  end
  Hekili:SaveCoordinates()
end


local function Mover_OnMouseDown( self, btn )
  if ( Hekili.Config or not Hekili.DB.profile.Locked ) and btn == "LeftButton" and not self.Moving then
    startScreenMovement( self )
  end
end


local function Button_OnMouseUp( self, btn )
  local display = self:GetName():match("Hekili_D(%d+)_B(%d+)")
  local mover = _G[ "HekiliDisplay" .. display ]
  if ( btn == "LeftButton" and mover.Moving ) then
    stopScreenMovement( mover )
  elseif ( btn == "RightButton" and not Hekili.Config ) then
    if mover.Moving then
      stopScreenMovement( mover )
    end
    Hekili.DB.profile.Locked = true
    local MouseInteract = ( Hekili.Pause ) or Hekili.Config or ( not Hekili.DB.profile.Locked )
    for i = 1, #ns.UI.Buttons do
      for j = 1, #ns.UI.Buttons[i] do
        ns.UI.Buttons[i][j]:EnableMouse( MouseInteract )
      end
    end
    ns.UI.Notification:EnableMouse( Hekili.Config or ( not Hekili.DB.profile.Locked ) )
    -- Hekili:SetOption( { "locked" }, true )
    GameTooltip:Hide()
  end
  Hekili:SaveCoordinates()
end


local function Button_OnMouseDown( self, btn )
  local display = self:GetName():match("Hekili_D(%d+)_B(%d+)")
  local mover = _G[ "HekiliDisplay" .. display ]
  if ( Hekili.Config or not Hekili.DB.profile.Locked ) and btn == "LeftButton" and not mover.Moving then
    startScreenMovement( mover )
  end
end


function ns.StartConfiguration( external )
  Hekili.Config = true

  local scaleFactor = Hekili:GetScale()

  -- Notification Panel
  ns.UI.Notification:EnableMouse(true)
  ns.UI.Notification:SetMovable(true)
  ns.UI.Notification.Mover = ns.UI.Notification.Mover or CreateFrame( "Frame", "HekiliNotificationMover", ns.UI.Notification )
  ns.UI.Notification.Mover:SetAllPoints(HekiliNotification)
  -- ns.UI.Notification.Mover:SetHeight(20)
  ns.UI.Notification.Mover:SetBackdrop( {
    bgFile	 	= "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile 	= "Interface/Tooltips/UI-Tooltip-Border",
    tile		  = false,
    tileSize 	= 0,
    edgeSize 	= 2,
    insets 		= { left = 0, right = 0, top = 0, bottom = 0 }
  } )
  ns.UI.Notification.Mover:SetBackdropColor(.1, .1, .1, .8)
  ns.UI.Notification.Mover:SetBackdropBorderColor(.1, .1, .1, .5)
  ns.UI.Notification.Mover:Show()

  f = ns.UI.Notification.Mover
  f.Header = f.Header or f:CreateFontString( "HekiliNotificationHeader", "OVERLAY", "GameFontNormal" )
  -- f.Header:SetSize( Hekili.DB.profile['Notification Width'] * scaleFactor * 0.5, 20 )
  f.Header:SetAllPoints( HekiliNotificationMover )
  f.Header:SetText( "Notifications" )
  f.Header:SetJustifyH( "CENTER" )
  -- f.Header:SetPoint( "BOTTOMLEFT", f, "TOPLEFT" )
  f.Header:Show()

  HekiliNotification:SetScript( "OnMouseDown", Mover_OnMouseDown )
  HekiliNotification:SetScript( "OnMouseUp", Mover_OnMouseUp )

  for i,v in ipairs(ns.UI.Displays) do
    if v.Mover then v.Mover:Hide() end
    if v.Header then v.Header:Hide() end

    if ns.UI.Buttons[i][1] and Hekili:IsDisplayActive( i ) and Hekili.DB.profile.displays[ i ] then
      v:EnableMouse(true)
      v:SetMovable(true)
      -- v.Mover:EnableMouse(true)
      -- v.Mover:SetMovable(true)

      v:SetBackdrop( {
        bgFile	 	= "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile 	= "Interface/Tooltips/UI-Tooltip-Border",
        tile		= false,
        tileSize 	= 0,
        edgeSize 	= 2,
        insets 		= { left = 0, right = 0, top = 0, bottom = 0 }
      } )
      v:SetBackdropColor(.1, .1, .1, .8)
      v:SetBackdropBorderColor(.1, .1, .1, .5)
      v:SetScript( "OnMouseDown", Mover_OnMouseDown )
      v:SetScript( "OnMouseUp", Mover_OnMouseUp )
      v:Show()

      v.Header = v.Header or v:CreateFontString( "HekiliDisplay"..i.."Header", "OVERLAY", "GameFontNormal" )
      local path, size, flags = v.Header:GetFont()
      v.Header:SetFont( path, size, "OUTLINE" )
      -- v.Header:SetSize( v:GetWidth() * 0.5, 20 )
      v.Header:ClearAllPoints()
      v.Header:SetPoint( "BOTTOM", v, "TOP", 0, 2 )
      v.Header:SetText( Hekili.DB.profile.displays[ i ].Name )
      v.Header:SetJustifyH( "CENTER" )
      -- v.Header:SetPoint( "BOTTOMLEFT", v, "TOPLEFT" )
      v.Header:Show()
    else
      v:Hide()
    end
  end

  -- HekiliNotification:EnableMouse(true)
  -- HekiliNotification:SetMovable(true)
  if not external then
    local ACD = LibStub( "AceConfigDialog-3.0" )
    ACD:SetDefaultSize( "Hekili", min( 900, GetScreenWidth() - 200 ), min( 800, GetScreenHeight() - 100 ) )
    ACD:Open("Hekili")
    ns.OnHideFrame = ns.OnHideFrame or CreateFrame("Frame", nil)
    ns.OnHideFrame:SetParent( ACD.OpenFrames["Hekili"].frame )
    ns.OnHideFrame:SetScript( "OnHide", function(self)
      ns.StopConfiguration()
      self:SetScript( "OnHide", nil )
      collectgarbage()
    end )
  end

end



function ns.StopConfiguration()
  Hekili.Config = false

  local scaleFactor = Hekili:GetScale()

  local MouseInteract = ( Hekili.Pause ) or ( not Hekili.DB.profile.Locked )

  for i,v in ipairs(ns.UI.Buttons) do
    for j, btn in ipairs(v) do
      btn:EnableMouse( MouseInteract )
      btn:SetMovable( not Hekili.DB.profile.Locked )
    end
  end

  HekiliNotification:EnableMouse( false )
  HekiliNotification:SetMovable( false )
  HekiliNotification.Mover:Hide()
  -- HekiliNotification.Mover.Header:Hide()

  for i,v in ipairs(ns.UI.Displays) do
    v:EnableMouse( false )
    v:SetMovable( true )
    v:SetBackdrop( nil )
    if v.Header then v.Header:Hide() end
  end
  
  Hekili.MakeDefaults = false

end


local function MasqueUpdate( Addon, Group, SkinID, Gloss, Backdrop, Colors, Disabled )
    if Disabled then
        for dispID, display in ipairs( ns.UI.Buttons ) do
            for btnID, button in ipairs( display ) do
                button.__MSQ_NormalTexture:Hide()
                button.Texture:SetAllPoints( button )
            end
        end
    end
end


local menuInfo = {}

local function menu_Enabled()
    Hekili:Toggle()
end

local function menu_Locked()
    local p = Hekili.DB.profile

    p.Locked = not p.Locked

    local MouseInteract = Hekili.Pause or Hekili.Config or ( not p.Locked )

    for _, v in ipairs( ns.UI.Buttons ) do
        v[1]:EnableMouse( MouseInteract )
    end
    ns.UI.Notification:EnableMouse( MouseInteract )
end

local function menu_Paused()
    Hekili:TogglePause()
end

local function menu_Auto()
    local p = Hekili.DB.profile

    p[ 'Mode Status' ] = 3
    p[ 'Switch Type' ] = 0
    ns.UI.Minimap:RefreshDataText()
end

local function menu_AOE()
    local p = Hekili.DB.profile

    p[ 'Mode Status' ] = 2
    p[ 'Switch Type' ] = 0
    ns.UI.Minimap:RefreshDataText()
end

local function menu_Single()
    local p = Hekili.DB.profile

    p[ 'Mode Status' ] = 0
    ns.UI.Minimap:RefreshDataText()
end

local function menu_Cooldowns()
    local p = Hekili.DB.profile

    p.Cooldowns = not p.Cooldowns
    ns.UI.Minimap:RefreshDataText()
end

local function menu_Interrupts()
    local p = Hekili.DB.profile

    p.Interrupts = not p.Interrupts
    ns.UI.Minimap:RefreshDataText()
end

local function menu_Potions()
    local p = Hekili.DB.profile

    p.Potions = not p.Potions
    ns.UI.Minimap:RefreshDataText()
end




Hekili_Menu = CreateFrame( "Frame", "HekiliMenu" )
Hekili_Menu.displayMode = "MENU"
Hekili_Menu.initialize = function( self, level ) 
    if not level then return end

    wipe( menuInfo )
    local p = Hekili.DB.profile
    local i = menuInfo

    if level == 1 then

        i.isTitle = 1
        i.text = "Hekili"
        i.notCheckable = 1
        UIDropDownMenu_AddButton( i, level )

        i.isTitle = nil
        i.disabled = nil
        i.notCheckable = nil

        i.text = "Enable"
        i.func = menu_Enabled
        i.checked = p.Enabled
        UIDropDownMenu_AddButton( i, level )

        i.text = "Lock"
        i.func = menu_Locked
        i.checked = p.Locked
        UIDropDownMenu_AddButton( i, level )

        i.text = " "
        i.func = nil
        i.notCheckable = 1
        i.disabled = 1
        UIDropDownMenu_AddButton( i, level )

        i.notCheckable = nil
        i.disabled = nil

        i.isTitle = 1
        i.text = "Target Mode"
        i.notCheckable = 1
        UIDropDownMenu_AddButton( i, level )

        i.isTitle = nil
        i.notCheckable = nil
        i.disabled = nil

        i.text = "Single-Target"
        i.func = menu_Single
        i.checked = p[ 'Mode Status' ] == 0
        UIDropDownMenu_AddButton( i, level )

        i.text = "AOE"
        i.func = menu_AOE
        i.checked = p[ 'Mode Status' ] == 2
        UIDropDownMenu_AddButton( i, level )

        i.text = "Automatic"
        i.func = menu_Auto
        i.checked = p[ 'Mode Status' ] == 3
        UIDropDownMenu_AddButton( i, level )

        i.notCheckable = nil
        i.tooltipText = nil
        i.tooltipTitle = nil
        i.tooltipOnButton = nil

        i.text = " "
        i.func = nil
        i.notCheckable = 1
        i.disabled = 1
        UIDropDownMenu_AddButton( i, level )

        i.notCheckable = nil
        i.disabled = nil

        i.isTitle = 1
        i.text = "Toggles"
        i.notCheckable = 1
        UIDropDownMenu_AddButton( i, level )

        i.isTitle = nil
        i.notCheckable = nil
        i.disabled = nil

        i.text = "Cooldowns"
        i.func = menu_Cooldowns
        i.checked = p.Cooldowns
        UIDropDownMenu_AddButton( i, level )

        i.text = "Interrupts"
        i.func = menu_Interrupts
        i.checked = p.Interrupts
        UIDropDownMenu_AddButton( i, level )

        i.text = "Potions"
        i.func = menu_Potions
        i.checked = p.Potions
        UIDropDownMenu_AddButton( i, level )       

        i.notCheckable = nil
        i.hasArrow = nil
        i.value = nil

        i.text = " "
        i.func = nil
        i.notCheckable = 1
        i.disabled = 1
        UIDropDownMenu_AddButton( i, level )

        i.notCheckable = nil
        i.disabled = nil

        i.text = "Pause"
        i.func = menu_Paused
        i.checked = Hekili.Pause
        UIDropDownMenu_AddButton( i, level )

    end
end



local function getDisplayDimensions( dispID )

    local display = Hekili.DB.profile.displays[ dispID ]
    if not display then return end

    local scale = Hekili:GetScale()

    local anchor = display.queueAnchor
    local space  = display.iconSpacing

    local qLen   = display.numIcons - 1
    local qSpace = qLen == 0 and 0 or ( space * ( qLen - 1 ) )    
    local aHoriz = ( anchor:sub( 1, 4 ) == "LEFT" or anchor:sub( 1, 5 ) == "RIGHT" )

    -- Calculate Width.
    local pWidth = display.primaryIconWidth
    local qHoriz = display.queueDirection == "LEFT" or display.queueDirection == "RIGHT"
    local qWidth = qHoriz and ( ( qLen * display.queuedIconWidth ) + qSpace ) or display.queuedIconWidth
    
    local width  = aHoriz and ( pWidth + space + qWidth ) or max( pWidth, qWidth )

    
    -- Calculate Height.
    local pH = display.primaryIconHeight
    local qH = qHoriz and display.queuedIconHeight or ( qSpace + ( qLen * display.queuedIconHeight ) )

    local height = aHoriz and max( pH, qH ) or ( pH + space + qH )


    -- Anchor Point for Icon #1.
    local anchorPoint, offX, offY = nil, 0, 0

    if aHoriz then
        local aLeft = anchor:sub( 1, 4 ) == "LEFT"
        anchorPoint = aLeft and "RIGHT" or "LEFT"
        offX = aLeft and -2 or 2
    else
        local aTop = anchor:sub( 1, 3 ) == "TOP"
        anchorPoint = aTop and "BOTTOM" or "TOP"
        offY = aTop and 2 or -2
    end

    return width + 2, height + 2, anchorPoint, offX, offY

end


do
    ns.UI.Displays = ns.UI.Displays or {}    
    local dPool = ns.UI.Displays


    local alphaUpdateEvents = {
        PET_BATTLE_OPENING_START = 1,
        PET_BATTLE_CLOSE = 1,
        BARBER_SHOP_OPEN = 1,
        BARBER_SHOP_CLOSE = 1,
        UNIT_ENTERED_VEHICLE = 1,
        UNIT_EXITED_VEHICLE = 1,
        PLAYER_TARGET_CHANGED = 1,
        PLAYER_REGEN_ENABLED = 1,
        PLAYER_REGEN_DISABLED = 1,
        PLAYER_SPECIALIZATION_CHANGED = 1,
        ACTIVE_TALENT_GROUP_CHANGED = 1,
        ZONE_CHANGED = 1,
        ZONE_CHANGED_INDOORS = 1,
        ZONE_CHANGED_NEW_AREA = 1,        
    }


    local function CalculateAlpha( id )
        if C_PetBattles.IsInBattle() or UnitOnTaxi( 'player' ) or Hekili.Barber or HasVehicleActionBar() or not Hekili:IsDisplayActive( id ) then
            return 0

        end

        local prof = Hekili.DB.profile
        local conf, switch, mode = prof.displays[ id ], prof[ "Switch Type" ], prof[ "Mode Status" ]

        local _, zoneType = IsInInstance()

        if ( not conf.Enabled ) or ( switch == 0 and not conf.showSwitchAuto ) or ( switch == 1 and not conf.showSwitchAE ) or ( mode == 0 and not conf.showST ) or ( mode == 3 and not conf.showAuto ) or ( mode == 2 and not conf.showAE ) then
            return 0

        elseif zoneType == "pvp" or zoneType == "arena" then
            if conf.visibilityType == 'a' then
                return conf.alphaShowPvP
                
            else
                if conf.targetPvP and UnitExists( 'target' ) and not ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
                    return conf.alphaTargetPvP
                    
                elseif conf.combatPvP and UnitAffectingCombat( 'player' ) then
                    return conf.alphaCombatPvP
                    
                elseif conf.alwaysPvP then
                    return conf.alphaAlwaysPvP
                    
                end
            end
            
            return 0     

        else
            if conf.visibilityType == 'a' then
                return conf.alphaShowPvE
                
            else
                if conf.targetPvE and UnitExists( 'target' ) and not ( UnitIsDead( 'target' ) or not UnitCanAttack( 'player', 'target' ) ) then
                    return conf.alphaTargetPvE
                    
                elseif conf.combatPvE and UnitAffectingCombat( 'player' ) then
                    return conf.alphaCombatPvE
                    
                elseif conf.alwaysPvE then
                    return conf.alphaAlwaysPvE
                    
                end
            end
            
            return 0
        end

        return 0
    end


    local kbEvents = {
        ACTIONBAR_SLOT_CHANGED = 1,
        ACTIONBAR_PAGE_CHANGED = 1,
        ACTIONBAR_UPDATE_STATE = 1,
        SPELLS_CHANGED = 1,
        UPDATE_SHAPESHIFT_FORM = 1
    }


    local function Display_UpdateKeybindings( self )
        local conf = Hekili.DB.profile.displays[ self.id ]

        for i, b in ipairs( self.Buttons ) do
            local r = self.Recommendations[ i ]

            local a = r.actionName

            if a then
                r.keybind = Hekili:GetBindingForAction( r.actionName, not conf.lowercaseKBs == true )
            end

            if conf.showKeybindings and ( i == 1 or conf.queuedKBs ) then
                b.Keybinding:SetText( r.keybind )
            else
                b.Keybinding:SetText( nil )
            end
        end
    end



    local pulseAuras   = 0.1
    local pulseDelay   = 0.05
    local pulseGlow    = 0.25
    local pulseTargets = 0.1
    local pulseRange   = TOOLTIP_UPDATE_TIME
    local pulseFlash   = 0.5

    local oocRefresh   = 0.5
    local icRefresh    = 0.25
    
    local refreshPulse = 10


    local LRC = LibStub( "LibRangeCheck-2.0" )
    local LSF = SpellFlashCore
    local LSR = LibStub( "SpellRange-1.0" )


    local function Display_OnUpdate( self, elapsed )
        if not self.Recommendations then return end
        local profile = Hekili.DB.profile
        local conf = profile.displays[ self.id ]

        if self.alpha == 0 then return end

        if Hekili.Pause then
            if not self.paused then
                self.Buttons[ 1 ].Overlay:Show()
                self.paused = true
            end

            return

        elseif self.paused then
            self.Buttons[ 1 ].Overlay:Hide()
            self.paused = false

        end
       

        local now = GetTime()

        if self.NewRecommendations then
            local alpha = self.alpha

            for i, b in ipairs( self.Buttons ) do
                local rec = self.Recommendations[ i ]

                local action    = rec.actionName
                local caption   = rec.caption
                local indicator = rec.indicator
                local keybind   = rec.keybind

                local ability   = class.abilities[ action ]

                if ability then
                    b:Show()

                    b.Texture:SetTexture( rec.texture or ability.texture or GetSpellTexture( ability.id ) )
                    b.Texture:Show()

                    if conf.showIndicators and indicator then
                        if indicator == 'cycle'  then b.Icon:SetTexture( "Interface\\Addons\\Hekili\\Textures\\Cycle" ) end
                        if indicator == 'cancel' then b.Icon:SetTexture( "Interface\\Addons\\Hekili\\Textures\\Cancel" ) end
                        b.Icon:Show()

                    else
                        b.Icon:Hide()

                    end

                    if conf.showCaptions and ( i == 1 or conf.queuedCaptions ) then
                        b.Caption:SetText( caption )

                    else
                        b.Caption:SetText( nil )

                    end

                    if conf.showKeybindings and ( i == 1 or conf.queuedKBs ) then
                        b.Keybinding:SetText( keybind )

                    else
                        b.Keybinding:SetText( nil )

                    end

                    if conf.blizzGlow and ( i == 1 or conf.queuedBlizzGlow ) and IsSpellOverlayed( ability.id ) then
                        ActionButton_ShowOverlayGlow( b )
                        b.glowing = true

                    elseif b.glowing then
                        ActionButton_HideOverlayGlow( b )
                        b.glowing = false

                    end

                else
                    b:Hide()

                end                
            end

            -- Force glow, range, SpellFlash updates.
            self.glowTimer  = -1
            self.rangeTimer = -1
            self.flashTimer = -1

            self.refreshTimer = state.combat == 0 and oocRefresh or icRefresh

            self.refreshCount = ( self.refreshCount or 0 ) + 1

            self:RefreshCooldowns()            
            self.NewRecommendations = false
        end


        self.glowTimer = self.glowTimer - elapsed

        if self.glowTimer < 0 then
            if conf.blizzGlow then
                for i, b in ipairs( self.Buttons ) do
                    local r = self.Recommendations[ i ]

                    if not r.actionName then break end

                    local a = class.abilities[ r.actionName ]

                    if i == 1 or conf.queuedBlizzGlow then
                        local glowing = not a.item and IsSpellOverlayed( a.id )

                        if glowing and not b.glowing then
                            ActionButton_ShowOverlayGlow( b )
                            b.glowing = true
                        
                        elseif not glowing and b.glowing then
                            ActionButton_HideOverlayGlow( b )
                            b.glowing = false
                        
                        end

                    else
                        if b.glowing then
                            ActionButton_HideOverlayGlow( b )
                            b.glowing = false
                        end
                    end
                end
            end
        end


        self.rangeTimer = ( self.rangeTimer or 0 ) - elapsed

        if self.rangeTimer < 0 then
            for i, b in ipairs( self.Buttons ) do
                local r = self.Recommendations[ i ]
                local a = class.abilities[ r.actionName ]

                if not a then break end

                local outOfRange

                if conf.rangeType == 'melee' then
                    outOfRange = LRC:GetRange( 'target' ) > 7

                elseif conf.rangeType == 'ability' then
                    if a.item then
                        outOfRange = UnitExists( "target" ) and UnitCanAttack( "player", "target" ) and IsItemInRange( a.item, "target" ) == false 
                    else
                        outOfRange = LSR.IsSpellInRange( a.range and class.abilities[ a.range ].name or a.name, "target" ) == 0
                    end
                end

                if outOfRange and not b.outOfRange then
                    b.Texture:SetDesaturated( true )
                    b.Texture:SetVertexColor( 1.0, 0.0, 0.0, 1.0 )
                    b.outOfRange = true

                elseif b.outOfRange and not outOfRange then
                    b.Texture:SetDesaturated( false )
                    b.Texture:SetVertexColor( 1.0, 1.0, 1.0, 1.0 )
                    b.outOfRange = false

                end

                if not b.outOfRange then
                    local unusable
                    
                    if a.item then unusable = not IsUsableItem( a.item )
                    else _, unusable = IsUsableSpell( a.name ) end

                    if unusable and not b.unusable then
                        b.Texture:SetVertexColor( 0.4, 0.4, 0.4, 1.0 )
                        b.unusable = true

                    elseif b.unusable and not unusable then
                        b.Texture:SetVertexColor( 1.0, 1.0, 1.0, 1.0 )
                        b.unusable = false
                    end

                end
            end

            self.rangeTimer = pulseRange
        end


        self.flashTimer = ( self.flashTimer or 0 ) - elapsed

        if self.flashTimer < 0 then
            if conf.spellFlash and LSF then
                local a = self.Recommendations and self.Recommendations[ 1 ] and self.Recommendations[ 1 ].actionName
                
                if a then
                    local ability = class.abilities[ a ]

                    if ability.item then
                        LSF.FlashItem( ability.name, conf.spellFlashColor )
                    else
                        LSF.FlashAction( ability.name, conf.spellFlashColor )
                    end
                end
            end

            self.flashTimer = pulseFlash
        end


        self.counterTimer = ( self.counterTimer or 0 ) - elapsed

        if self.counterTimer < 0 then
            self.refreshInLastTen = self.refreshCount or 0
            self.refreshCount = 0

            self.counterTimer = refreshPulse
        end


        self.targetTimer = self.targetTimer - elapsed

        if self.targetTimer < 0 then
            local b = self.Buttons[ 1 ]

            if conf.showTargets then
                local tMin, tMax = 0, 0
                local mode = profile["Mode Status"]

                -- Primary Display
                if conf.displayType == 'a' then
                    if mode == 0 then
                        tMin, tMax = 0, 1
                    elseif mode == 2 then
                        tMin, tMax = conf.simpleAOE or 2, 0
                    end

                -- Single Target
                elseif conf.displayType == 'b' then
                    tMin, tMax = 0, 1

                -- AOE
                elseif conf.displayType == 'c' then
                    tMin, tMax = conf.simpleAOE or 2, 0

                elseif conf.displayType == 'z' then
                    if mode == 0 then
                        tMin = conf.minST > 0 and conf.minST or tMin
                        tMax = conf.maxST > 0 and conf.maxST or tMax

                    elseif mode == 2 then
                        tMin = conf.minAE > 0 and conf.minAE or tMin
                        tMax = conf.maxAE > 0 and conf.maxAE or tMax

                    elseif mode == 3 then
                        tMin = conf.minAuto > 0 and conf.minAuto or tMin
                        tMax = conf.maxAuto > 0 and conf.maxAuto or tMax
                    end
                end

                local detected = max( 1, ns.getNumberTargets() )
                local shown = detected

                if tMin > 0 then shown = max( tMin, shown ) end
                if tMax > 0 then shown = min( tMax, shown ) end

                if shown > 1 then
                    local color = detected < shown and '|cFFFF0000' or ( shown > detected and '|cFF00C0FF' or '' )
                    b.Targets:SetText( color .. shown .. '|r' )
                    b.targetShown = true
                else
                    b.Targets:SetText( nil )
                    b.targetShown = false
                end
            
            elseif b.targetShown then
                b.Targets:SetText( nil )
            end

            self.targetTimer = pulseTargets
        end


        self.auraTimer = self.auraTimer - elapsed

        if self.auraTimer < 0 then
            local b = self.Buttons[ 1 ]

            if conf.showAuraInfo then
                if type( conf.auraSpellID ) == 'string' or conf.auraSpellID > 0 then
                    local aura = class.auras[ conf.auraSpellID ]

                    if not aura then b.Auras:SetText( nil )
                    else
                        if conf.auraInfoType == 'count' then
                            local c = ns.numDebuffs( aura.name )
                            b.Auras:SetText( c > 0 and c or nil )

                        elseif conf.auraInfoType == 'buff' then
                            local name, _, _, count = UnitBuff( conf.auraUnit, aura.name, nil, conf.auraMine and "PLAYER" or "" )
                            if not name then b.Auras:SetText( nil )
                            else b.Auras:SetText( max( 1, count ) ) end

                        elseif conf.auraInfoType == 'debuff' then
                            local name, _, _, count = UnitDebuff( conf.auraUnit, aura.name, nil, conf.auraMine and "PLAYER" or "" )
                            if not name then b.Auras:SetText( nil )
                            else b.Auras:SetText( max( 1, count ) ) end

                        elseif conf.auraInfoType == 'buffRem' then
                            local name, _, _, _, _, _, expires = UnitBuff( conf.auraUnit, aura.name, nil, conf.auraMine and "PLAYER" or "" )
                            if not name then b.Auras:SetText( nil )
                            else b.Auras:SetText( format( "%.1f", expires - now ) ) end

                        elseif conf.auraInfoType == 'debuffRem' then
                            local name, _, _, _, _, _, expires = UnitDebuff( conf.auraUnit, aura.name, nil, conf.auraMine and "PLAYER" or "" )
                            if not name then b.Auras:SetText( nil )
                            else b.Auras:SetText( format( "%.1f", expires - now ) ) end

                        end
                        b.auraShown = true
                    end
                else
                    b.Auras:SetText( nil )
                    b.auraShown = false
                end

            elseif b.auraShown then
                b.Auras:SetText( nil )
                b.auraShown = false
            end

            self.auraTimer = pulseAuras
        end


        local rec = self.Recommendations[ 1 ]

        self.delayTimer = self.delayTimer - elapsed

        if rec.exact_time and self.delayTimer < 0 then
            local b = self.Buttons[ 1 ]
            local delay = rec.exact_time - now

            local start, duration = GetSpellCooldown( 61304 )
            local gRemains = start > 0 and ( start + duration - now ) or 0

            if conf.showDelay ~= "NONE" then
                if conf.showDelay == "TEXT" then
                    if self.delayIconShown then b.DelayIcon:Hide(); self.delayIconShown = false end

                    if delay > gRemains + 0.1 then
                        b.DelayText:SetText( string_format( "%.1f", delay ) )                    
                        self.delayTextShown = true
                    else
                        b.DelayText:SetText( nil )
                        self.delayTextShown = false
                    end

                elseif conf.showDelay == "ICON" then
                    if self.delayTextShown then b.DelayText:SetText( nil ); self.delayTextShown = false end
                    
                    b.DelayIcon:Show()
                    self.delayIconShown = true

                    if delay < 0.5 then
                        b.DelayIcon:SetVertexColor( 0.0, 1.0, 0.0, 1.0 )

                    elseif delay < 1.5 then
                        b.DelayIcon:SetVertexColor( 1.0, 1.0, 0.0, 1.0 )

                    else
                        b.DelayIcon:SetVertexColor( 1.0, 0.0, 0.0, 1.0 )

                    end

                end

            else
                if self.delayTextShown then b.DelayText:SetText( nil ); self.delayTextShown = false end
                if self.delayIconShown then b.DelayIcon:Hide(); self.delayIconShown = false end

            end

            self.delayTimer = pulseDelay
        end


        self.refreshTimer = self.refreshTimer - elapsed

        if self.criticalUpdate or self.refreshTimer < 0 then
            Hekili:ProcessHooks( self.id )
            
            self.criticalUpdate = false
            self.refreshTimer = state.combat == 0 and oocRefresh or icRefresh
        end

    end


    local function Display_UpdateAlpha( self )

        if not self.Active then
            self:SetAlpha(0)
            self:Hide()
            self.alpha = 0
            return
        end

        local preAlpha = self.alpha or 0
        local newAlpha = CalculateAlpha( self.id )

        if preAlpha > 0 and newAlpha == 0 then
            self:SetAlpha( 0 )
            self:Deactivate()

        else
            if preAlpha == 0 and newAlpha > 0 then
                Hekili:ProcessHooks( self.id )
            end
            self:SetAlpha( newAlpha )
            self:Show()

        end

        self.alpha = newAlpha
    end


    local function Display_RefreshCooldowns( self )
        local gStart, gDuration = GetSpellCooldown( 61304 )
        local gExpires = gStart + gDuration

        for i, rec in ipairs( self.Recommendations ) do
            if not rec.actionName then break end

            local ability = class.abilities[ rec.actionName ]
            local cd = self.Buttons[ i ].Cooldown

            if ability then
                local start, duration = 0, 0

                if ability.item then
                    start, duration = GetItemCooldown( ability.item )

                else
                    start, duration = GetSpellCooldown( ability.id )

                end

                local expires = start + duration

                if ability.gcdType ~= 'off' and ( expires < gExpires ) then
                    start, duration = gStart, gDuration
                end

                cd:SetCooldown( start, duration )
            end
        end
    end


    local function Display_OnEvent( self, event, ... )
        if not self.Recommendations then return end
        local conf = Hekili.DB.profile.displays[ self.id ]

        -- Update the CDs.
        if event == "SPELL_UPDATE_USABLE" or event == "SPELL_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_USABLE" or event == "ACTIONBAR_UPDATE_COOLDOWN" then
            self:RefreshCooldowns()
        
        elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
            if conf.blizzGlow then                
                for i, r in ipairs( self.Recommendations ) do
                    if i > 1 and not conf.queuedBlizzGlow then break end                    
                    if not r.actionName then break end

                    local b = self.Buttons[ i ]
                    local a = class.abilities[ r.actionName ]

                    if not b.glowing and not a.item and IsSpellOverlayed( a.id ) then
                        ActionButton_ShowOverlayGlow( b )
                        b.glowing = true
                    end
                end
            end

        elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
            if conf.blizzGlow then
                for i, r in ipairs( self.Recommendations ) do
                    if i > 1 and not conf.queuedBlizzGlow then break end
                    if not r.actionName then break end

                    local b = self.Buttons[ i ]
                    local a = class.abilities[ r.actionName ]

                    if b.glowing and ( a.item or not IsSpellOverlayed( a.id ) ) then
                        ActionButton_HideOverlayGlow( b )
                        b.glowing = false

                    end
                end
            end

        elseif kbEvents[ event ] then self:UpdateKeybindings()        
        elseif alphaUpdateEvents[ event ] then self:UpdateAlpha() end

    end


    local function Display_Activate( self )
        
        self.Active = true

        self.Recommendations = self.Recommendations or ( ns.queue and ns.queue[ self.id ] )

        self.auraTimer = 0
        self.delayTimer = 0
        self.glowTimer = 0
        self.refreshTimer = 0
        self.targetTimer = 0

        self:SetScript( "OnUpdate", Display_OnUpdate )
        self:SetScript( "OnEvent",  Display_OnEvent )

        if not self.Initialized then
            -- Update Cooldown Wheels.
            self:RegisterEvent( "ACTIONBAR_UPDATE_USABLE" )
            self:RegisterEvent( "ACTIONBAR_UPDATE_COOLDOWN" )        
            self:RegisterEvent( "SPELL_UPDATE_COOLDOWN" )
            self:RegisterEvent( "SPELL_UPDATE_USABLE" )

            -- Show/Hide Overlay Glows.
            self:RegisterEvent( "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" )
            self:RegisterEvent( "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" )

            -- Recalculate Alpha/Visibility.
            self:RegisterEvent( "PET_BATTLE_OPENING_START" )
            self:RegisterEvent( "PET_BATTLE_CLOSE" )
            self:RegisterEvent( "BARBER_SHOP_OPEN" )
            self:RegisterEvent( "BARBER_SHOP_CLOSE" )
            self:RegisterUnitEvent( "UNIT_ENTERED_VEHICLE", "player" )
            self:RegisterUnitEvent( "UNIT_EXITED_VEHICLE", "player" )
            self:RegisterUnitEvent( "PLAYER_SPECIALIZATION_CHANGED", "player" )
            self:RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED" )
            self:RegisterEvent( "PLAYER_TARGET_CHANGED" )
            self:RegisterEvent( "PLAYER_CONTROL_LOST" )
            self:RegisterEvent( "PLAYER_CONTROL_GAINED" )
            self:RegisterEvent( "PLAYER_REGEN_DISABLED" )
            self:RegisterEvent( "PLAYER_REGEN_ENABLED" )
            self:RegisterEvent( "ZONE_CHANGED" )
            self:RegisterEvent( "ZONE_CHANGED_INDOORS" )
            self:RegisterEvent( "ZONE_CHANGED_NEW_AREA" )

            -- Update keybindings.
            for k in pairs( kbEvents ) do            
                self:RegisterEvent( k )
            end

            self.Initialized = true
        end

    end


    local function Display_Deactivate( self )

        self.Active = false

        self:SetScript( "OnUpdate", nil )
        self:SetScript( "OnEvent",  nil )

        for i, b in ipairs( self.Buttons ) do
            b:Hide()
        end

    end


    function Hekili:CreateDisplay( id )
        local conf = self.DB.profile.displays[ id ]
        if not conf then return end

        dPool[ id ] = dPool[ id ] or CreateFrame( "Frame", "HekiliDisplay"..id, UIParent )
        local d = dPool[ id ]

        d.id = id       

        local scale = self:GetScale()
        local border = 4

        d:SetSize( scale * ( border + conf.primaryIconWidth ), scale * ( border + conf.primaryIconHeight ) )
        d:SetPoint( "CENTER", Screen, "CENTER", conf.x, conf.y )
        d:SetFrameStrata( "MEDIUM" )
        d:SetClampedToScreen( true )
        d:EnableMouse( false )
        d:SetMovable( true )

        d.Activate          = Display_Activate
        d.Deactivate        = Display_Deactivate
        d.RefreshCooldowns  = Display_RefreshCooldowns
        d.UpdateAlpha       = Display_UpdateAlpha
        d.UpdateKeybindings = Display_UpdateKeybindings

        ns.queue[ id ] = ns.queue[ id ] or {}
        d.Recommendations = ns.queue[ id ]

        ns.UI.Buttons[ id ] = ns.UI.Buttons[ id ] or {}
        d.Buttons = ns.UI.Buttons[ id ]

        for i = 1, 10 do
            d.Buttons[i] = self:CreateButton( id, i )
            d.Buttons[i]:Hide()

            if self.DB.profile.Enabled and self:IsDisplayActive( id ) and i <= conf.numIcons then
                if d.Recommendations[i] and d.Recommendations[i].actionName then
                    d.Buttons[i]:Show()
                end
            end

            if MasqueGroup then MasqueGroup:AddButton( d.Buttons[i], { Icon = d.Buttons[i].Texture, Cooldown = d.Buttons[i].Cooldown } ) end            
        end

    end


    local dispActive = {}
    local listActive = {}
    local actsActive = {}


    function Hekili:UpdateDisplayVisibility()
        local profile = self.DB.profile
        local displays = ns.UI.Displays

        for i in ipairs( dispActive ) do dispActive[ i ] = nil end
        for i in ipairs( listActive ) do listActive[ i ] = nil end
        for a in  pairs( actsActive ) do actsActive[ a ] = nil end

        if profile.Enabled then
            for i, display in ipairs( profile.displays ) do            
                if display.Enabled and ( display.Specialization == 0 or display.Specialization == state.spec.id ) then
                    dispActive[ i ] = true
                    if displays[ i ] then displays[ i ]:Activate() end
                else
                    if displays[ i ] then displays[ i ]:Deactivate() end
                end
            end

            for i, list in ipairs( profile.actionLists ) do
                if list.Specialization == 0 or list.Specialization == state.spec.id then
                    listActive[ i ] = true
                end


                -- NYI:  We can cache if abilities are disabled here as well to reduce checking in ProcessHooks.
                for a, action in ipairs( list.Actions ) do
                    if action.Enabled and action.Ability then
                        actsActive[ i ..':' .. a ] = true
                    end
                end
            end
        end

        for i, d in ipairs( ns.UI.Displays ) do
            d:UpdateAlpha()
        end
    end


    function Hekili:IsDisplayActive( display )
        return dispActive[ display ] == true
    end


    function Hekili:IsListActive( list )
        return listActive[ list ] == true
    end


    function Hekili:IsActionActive( list, action )
        return actsActive[ list .. ':' .. action ] == true
    end


    function Hekili:DumpActionActive()
        DevTools_Dump( actsActive )
    end


    local LSM = LibStub( "LibSharedMedia-3.0", true )
    local LRC = LibStub( "LibRangeCheck-2.0" )
    local LSR = LibStub( "SpellRange-1.0" )

    function Hekili:CreateButton( dispID, id )

        local d = dPool[ dispID ]
        if not d then return end

        local conf = self.DB.profile.displays[ dispID ]
        if not conf then return end

        ns.queue[ dispID ][ id ] = ns.queue[ dispID ][ id ] or {}

        local bName = "Hekili_D" .. dispID .. "_B" .. id
        local b = d.Buttons[ id ] or CreateFrame( "Button", bName, d )

        local scale = self:GetScale()       

        b:SetHeight( scale * ( id == 1 and conf.primaryIconHeight or conf.queuedIconHeight or 50 ) )
        b:SetWidth ( scale * ( id == 1 and conf.primaryIconWidth  or conf.queuedIconWidth  or 50 ) )


        -- Texture
        if not b.Texture then
            b.Texture = b:CreateTexture( nil, "LOW" )
            b.Texture:SetTexture( "Interface\\ICONS\\Spell_Nature_BloodLust" )
            b.Texture:SetAllPoints( b )
        end

        local zoom = 1 - ( ( conf.iconZoom or 0 ) / 200 )

        if conf.KeepAspectRatio then
            local biggest = id == 1 and max( conf.primaryIconHeight, conf.primaryIconWidth ) or max( conf.queuedIconHeight, conf.queuedIconWidth )
            local height  = 0.5 * zoom * ( id == 1 and conf.primaryIconHeight or conf.queuedIconHeight ) / biggest
            local width   = 0.5 * zoom * ( id == 1 and conf.primaryIconWidth  or conf.queuedIconWidth  ) / biggest
            b.Texture:SetTexCoord( 0.5 - width, 0.5 + width, 0.5 - height, 0.5 + height )
        else
            local zoom = zoom / 2
            b.Texture:SetTexCoord( 0.5 - zoom, 0.5 + zoom, 0.5 - zoom, 0.5 + zoom )
        end


        -- Indicator Icons.
        b.Icon = b.Icon or b:CreateTexture( nil, "OVERLAY" )
        b.Icon:SetSize( max( 10, b:GetWidth() / 3 ), max( 10, b:GetHeight() / 3 ) )
        local iconAnchor = conf.indicatorAnchor or "RIGHT"
        b.Icon:ClearAllPoints()
        b.Icon:SetPoint( iconAnchor, b, iconAnchor, conf.xOffsetIndicators or 0, conf.yOffsetIndicators or 0 )
        b.Icon:Hide()

        -- Caption Text.
        b.Caption = b.Caption or b:CreateFontString( bName .. "_Caption", "OVERLAY" )
        
        local captionFont = conf.captionFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
        b.Caption:SetFont( LSM:Fetch( "font", captionFont ), conf.captionFontSize or 12, conf.captionFontStyle or "OUTLINE" )
        b.Caption:SetSize( b:GetWidth(), max( 12, b:GetHeight() / 2 ) )
        
        local capAnchor = conf.captionAnchor or "BOTTOM"
        b.Caption:ClearAllPoints()
        b.Caption:SetPoint( capAnchor, b, capAnchor, conf.xOffsetCaptions or 0, conf.yOffsetCaptions or 0 )
        b.Caption:SetJustifyV( capAnchor )
        b.Caption:SetJustifyH( conf.captionAlign or "CENTER" )
        b.Caption:SetTextColor( 1, 1, 1, 1 )


        -- Keybinding Text
        b.Keybinding = b.Keybinding or b:CreateFontString( bName.."_KB", "OVERLAY" )
        
        local kbFont = conf.kbFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
        b.Keybinding:SetFont( LSM:Fetch( "font", kbFont ), conf.kbFontSize or 12, conf.kbFontStyle or "OUTLINE" )
        b.Keybinding:SetSize( b:GetWidth(), b:GetHeight() / 2 )

        local kbAnchor = conf.kbAnchor or "TOPRIGHT"
        b.Keybinding:ClearAllPoints()
        b.Keybinding:SetPoint( kbAnchor, b, kbAnchor, conf.xOffsetKBs or 0, conf.yOffsetKBs or 0 )
        b.Keybinding:SetJustifyH( kbAnchor:match( "RIGHT" ) and "RIGHT" or ( kbAnchor:match( "LEFT" )   and "LEFT"   or "CENTER" ) )
        b.Keybinding:SetJustifyV( kbAnchor:match( "TOP" )   and "TOP"   or ( kbAnchor:match( "BOTTOM" ) and "BOTTOM" or "MIDDLE" ) )
        b.Keybinding:SetTextColor( 1, 1, 1, 1 )


        -- Cooldown Wheel
        b.Cooldown = b.Cooldown or CreateFrame( "Cooldown", bName .. "_Cooldown", b, "CooldownFrameTemplate" )
        b.Cooldown:ClearAllPoints()
        b.Cooldown:SetAllPoints( b )
        b.Cooldown:SetFrameStrata( "MEDIUM" )
        b.Cooldown:SetFrameLevel( 50 )
        b.Cooldown:SetDrawBling( false )
        b.Cooldown:SetDrawEdge( false )


        -- Primary Icon Stuff
        if id == 1 then
            b:ClearAllPoints()
            b:SetPoint( "CENTER", d, "CENTER" )

            -- Target Counter
            b.Targets = b.Targets or b:CreateFontString( bName .. "_Targets", "OVERLAY" )

            local tarFont = conf.targetFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
            b.Targets:SetFont( LSM:Fetch( "font", tarFont ), conf.targetFontSize or 12, conf.targetFontStyle or "OUTLINE" )
            b.Targets:SetSize( b:GetWidth(), b:GetHeight() / 2 )

            local tarAnchor = conf.targetAnchor or "BOTTOM"
            b.Targets:ClearAllPoints()
            b.Targets:SetPoint( tarAnchor, b, tarAnchor, conf.xOffsetTargets or 0, conf.yOffsetTargets or 0 )

            b.Targets:SetJustifyH( tarAnchor:match( "RIGHT" ) and "RIGHT" or ( tarAnchor:match( "LEFT" )   and "LEFT"   or "CENTER" ) )
            b.Targets:SetJustifyV( tarAnchor:match( "TOP" )   and "TOP"   or ( tarAnchor:match( "BOTTOM" ) and "BOTTOM" or "MIDDLE" ) )
            b.Targets:SetTextColor( 1, 1, 1, 1 )


            -- Aura Counter
            b.Auras = b.Auras or b:CreateFontString( bName .. "_Auras", "OVERLAY" )
            
            local auraFont = conf.auraFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
            b.Auras:SetFont( LSM:Fetch( "font", auraFont ), conf.auraFontSize or 12, conf.auraFontStyle or "OUTLINE" )
            b.Auras:SetSize( b:GetWidth(), b:GetHeight() / 2 )

            local auraAnchor = conf.auraAnchor or "BOTTOM"
            b.Auras:ClearAllPoints()
            b.Auras:SetPoint( auraAnchor, b, auraAnchor, conf.xOffsetAuras or 0, conf.yOffsetAuras or 0 )

            b.Auras:SetJustifyH( auraAnchor:match( "RIGHT" ) and "RIGHT" or ( auraAnchor:match( "LEFT" )   and "LEFT"   or "CENTER" ) )
            b.Auras:SetJustifyV( auraAnchor:match( "TOP" )   and "TOP"   or ( auraAnchor:match( "BOTTOM" ) and "BOTTOM" or "MIDDLE" ) )
            b.Auras:SetTextColor( 1, 1, 1, 1 )


            -- Delay Counter
            b.DelayText = b.DelayText or b:CreateFontString( bName .. "_DelayText", "OVERLAY" )

            local delayFont = conf.delayFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
            b.DelayText:SetFont( LSM:Fetch( "font", delayFont), conf.delayFontSize or 12, conf.delayFontStyle or "OUTLINE" )
            b.DelayText:SetSize( b:GetWidth(), b:GetHeight() / 2 )

            local delayAnchor = conf.delayAnchor or "TOPLEFT"
            b.DelayText:ClearAllPoints()
            b.DelayText:SetPoint( delayAnchor, b, delayAnchor, conf.xOffsetDelay or 0, conf.yOffsetDelay or 0 )

            b.DelayText:SetJustifyH( delayAnchor:match( "RIGHT" ) and "RIGHT" or ( delayAnchor:match( "LEFT" )   and "LEFT"   or "CENTER" ) )
            b.DelayText:SetJustifyV( delayAnchor:match( "TOP" )   and "TOP"   or ( delayAnchor:match( "BOTTOM" ) and "BOTTOM" or "MIDDLE" ) )
            b.DelayText:SetTextColor( 1, 1, 1, 1 )


            -- Delay Icon
            b.DelayIcon = b.DelayIcon or b:CreateTexture( bName .. "_DelayIcon", "OVERLAY" )
            b.DelayIcon:SetSize( min( 20, max( 10, b:GetSize() / 3 ) ), min( 20, max( 10, b:GetSize() / 3 ) ) )
            b.DelayIcon:SetTexture( "Interface\\FriendsFrame\\StatusIcon-Online" )
            b.DelayIcon:SetDesaturated( true )
            b.DelayIcon:SetVertexColor( 1, 0, 0, 1 )

            b.DelayIcon:ClearAllPoints()
            b.DelayIcon:SetPoint( delayAnchor, b, delayAnchor, conf.xOffsetDelay or 0, conf.yOffsetDelay or 0 )
            b.DelayIcon:Hide()


            -- Overlay (for Pause)
            b.Overlay = b.Overlay or b:CreateTexture( nil, "OVERLAY" )    
            b.Overlay:SetAllPoints( b )
            b.Overlay:SetTexture( 'Interface\\Addons\\Hekili\\Textures\\Pause.blp' )
            b.Overlay:SetTexCoord( b.Texture:GetTexCoord() )
            b.Overlay:Hide()


        -- Anchoring stuff for the queue.
        elseif id == 2 then
            local queueAnchor = conf.queueAnchor or "RIGHT"
            local qOffset = conf.queueAnchorOffset

            b:ClearAllPoints()

            if queueAnchor:sub( 1, 5 ) == 'RIGHT' then
                local dir, align = 'RIGHT', queueAnchor:sub( 6 )
                b:SetPoint( align .. getInverseDirection( dir ), 'Hekili_D' .. dispID .. '_B1', align .. dir, qOffset * scale, 0 )

            elseif queueAnchor:sub( 1, 4 ) == 'LEFT' then
                local dir, align = 'LEFT', queueAnchor:sub( 5 )
                b:SetPoint( align .. getInverseDirection( dir ), 'Hekili_D' .. dispID.. "_B1",  align .. dir, -1 *  qOffset * scale, 0 )

            elseif queueAnchor:sub( 1, 3 ) == 'TOP' then
                local dir, align = 'TOP', queueAnchor:sub( 4 )     
                b:SetPoint( getInverseDirection( dir ) .. align, 'Hekili_D' .. dispID.. "_B1",  dir .. align, 0, qOffset * scale )

            else -- BOTTOM
                local dir, align = 'BOTTOM', queueAnchor:sub( 7 )
                b:SetPoint( getInverseDirection( dir ) .. align, 'Hekili_D' .. dispID.. "_B1",  dir .. align, 0, -1 * qOffset * scale )

            end

        -- Anchoring for the remainder.
        else

            local queueDirection = conf.queueDirection or "RIGHT"
            local btnSpacing = conf.iconSpacing or 5        

            b:ClearAllPoints()

            if queueDirection == 'RIGHT' then
                b:SetPoint( getInverseDirection( queueDirection ), 'Hekili_D' .. dispID.. "_B" .. id - 1,  queueDirection, btnSpacing * scale, 0 )

            elseif queueDirection == 'LEFT' then
                b:SetPoint( getInverseDirection( queueDirection ), 'Hekili_D' .. dispID.. "_B" .. id - 1,  queueDirection, -1 *  btnSpacing * scale, 0 )

            elseif queueDirection == 'TOP' then
                b:SetPoint( getInverseDirection( queueDirection ), 'Hekili_D' .. dispID.. "_B" .. id - 1,  queueDirection, 0, btnSpacing * scale )

            else -- BOTTOM
                b:SetPoint( getInverseDirection( queueDirection ), 'Hekili_D' .. dispID.. "_B" .. id - 1,  queueDirection, 0, -1 * btnSpacing * scale )

            end
        end

        -- Mover Stuff.
        b:SetScript( "OnMouseDown", Button_OnMouseDown )
        b:SetScript( "OnMouseUp", Button_OnMouseUp )

        b:SetScript( "OnEnter", function( self )
            if ( not Hekili.Pause ) or ( Hekili.Config or not Hekili.DB.profile.Locked ) then
                ns.Tooltip:SetOwner( self, "ANCHOR_TOPRIGHT" )
                ns.Tooltip:SetBackdropColor( 0, 0, 0, 1 )
                ns.Tooltip:SetText( Hekili.DB.profile.displays[ dispID ].Name .. " (" .. dispID .. ")" )
                ns.Tooltip:AddLine("Left-click and hold to move.", 1, 1, 1 )
                if not Hekili.Config or not Hekili.DB.profile.Locked then ns.Tooltip:AddLine( "Right-click to lock all and close.", 1, 1, 1 ) end
                ns.Tooltip:Show()
                self:SetMovable( true )
            elseif ( Hekili.Pause and ns.queue[ dispID ] and ns.queue[ dispID ][ id ] ) then
                Hekili:ShowDiagnosticTooltip( ns.queue[ dispID ][ id ] )
            end
        end )

        b:SetScript( "OnLeave", function(self)
            ns.Tooltip:Hide()
        end )

        b:EnableMouse( not Hekili.DB.profile.Locked )
        b:SetMovable( not Hekili.DB.profile.Locked )

        return b

    end
    
end



-- Builds and maintains the visible UI elements.
-- Buttons (as frames) are never deleted, but should get reused effectively.
function ns.buildUI()

  if not Masque then
    Masque = LibStub( "Masque", true )

    if Masque then
        Masque:Register( "Hekili", MasqueUpdate, Hekili )
        MasqueGroup = Masque:Group( addon )
    end
  end

  ns.UI.Keyhandler = ns.UI.Keyhandler or CreateFrame( "Button", "Hekili_Keyhandler", UIParent )
  ns.UI.Keyhandler:RegisterForClicks("AnyDown")
  ns.UI.Keyhandler:SetScript("OnClick", function(self, button, down)
    Hekili:ClassToggle( button )
  end)


  local scaleFactor = Hekili:GetScale()

  local MouseInteract = ( Hekili.Pause ) or ( not Hekili.DB.profile.Locked )

  local f = ns.UI.Notification or CreateFrame( "Frame", "HekiliNotification", UIParent )
  f:SetSize( Hekili.DB.profile['Notification Width'] * scaleFactor, Hekili.DB.profile['Notification Height'] * scaleFactor )
  f:SetClampedToScreen( true )
  f:ClearAllPoints()
  f:SetPoint( "CENTER", Screen, "CENTER", Hekili.DB.profile['Notification X'], Hekili.DB.profile['Notification Y'] )

  f.Text = f.Text or f:CreateFontString( "HekiliNotificationText", "OVERLAY" )
  f.Text:SetSize( Hekili.DB.profile['Notification Width'] * scaleFactor, Hekili.DB.profile['Notification Height'] * scaleFactor )
  f.Text:SetPoint( "TOP", f, "TOP" )
  f.Text:SetFont( LibStub( "LibSharedMedia-3.0" ):Fetch("font", Hekili.DB.profile['Notification Font']), Hekili.DB.profile['Notification Font Size'] * scaleFactor, "OUTLINE" )
  f.Text:SetJustifyV( "MIDDLE" )
  f.Text:SetJustifyH( "CENTER" )
  f.Text:SetTextColor(1, 1, 1, 1)

  ns.UI.Notification = f
  ns.UI.Menu = ns.UI.Menu or CreateFrame( "Frame", "Hekili_Menu", UIParent, "L_UIDropDownMenuTemplate" )

  if not Hekili.DB.profile['Notification Enabled'] then
    ns.UI.Notification:Hide()
  else
    ns.UI.Notification.Text:SetText(nil)
    ns.UI.Notification:Show()
  end

  for dispID, display in ipairs( Hekili.DB.profile.displays ) do
    Hekili:CreateDisplay( dispID )
  end

  Hekili:UpdateDisplayVisibility()  

  --if Hekili.Config then ns.StartConfiguration() end
  if MasqueGroup then MasqueGroup:ReSkin() end

  -- Check for a display that has been removed.
  for display, buttons in ipairs( ns.UI.Buttons ) do
    if not Hekili.DB.profile.displays[display] then
      for i,_ in ipairs( buttons) do
        buttons[i]:Hide()
      end
    end
  end

  if Hekili.Config then ns.StartConfiguration( true ) end

end


local T = ns.lib.Format.Tokens
local SyntaxColors = {};

function ns.primeTooltipColors()
  T = ns.lib.Format.Tokens;
  --- Assigns a color to multiple tokens at once.
  local function Color ( Code, ... )
    for Index = 1, select( "#", ... ) do
      SyntaxColors[ select( Index, ... ) ] = Code;
    end
  end
  Color( "|cffB266FF", T.KEYWORD ) -- Reserved words

  Color( "|cffffffff", T.LEFTCURLY, T.RIGHTCURLY,
    T.LEFTBRACKET, T.RIGHTBRACKET,
    T.LEFTPAREN, T.RIGHTPAREN )

  Color( "|cffFF66FF", T.UNKNOWN, T.ADD, T.SUBTRACT, T.MULTIPLY, T.DIVIDE, T.POWER, T.MODULUS,
    T.CONCAT, T.VARARG, T.ASSIGNMENT, T.PERIOD, T.COMMA, T.SEMICOLON, T.COLON, T.SIZE,
    T.EQUALITY, T.NOTEQUAL, T.LT, T.LTE, T.GT, T.GTE )

  Color( "|cFFB2FF66", multiUnpack( ns.keys, ns.attr ) )

  Color( "|cffFFFF00", T.NUMBER )
  Color( "|cff888888", T.STRING, T.STRING_LONG )
  Color( "|cff55cc55", T.COMMENT_SHORT, T.COMMENT_LONG )
  Color( "|cff55ddcc", -- Minimal standard Lua functions
    "assert", "error", "ipairs", "next", "pairs", "pcall", "print", "select",
    "tonumber", "tostring", "type", "unpack",
    -- Libraries
    "bit", "coroutine", "math", "string", "table" )
  Color( "|cffddaaff", -- Some of WoW's aliases for standard Lua functions
    -- math
    "abs", "ceil", "floor", "max", "min",
    -- string
    "format", "gsub", "strbyte", "strchar", "strconcat", "strfind", "strjoin",
    "strlower", "strmatch", "strrep", "strrev", "strsplit", "strsub", "strtrim",
    "strupper", "tostringall",
    -- table
    "sort", "tinsert", "tremove", "wipe" )
end


local SpaceLeft = { "(%()" }
local SpaceRight = { "(%))" }
local DoubleSpace = { "(!=)", "(~=)", "(>=*)", "(<=*)", "(&)", "(||)", "(+)", "(*)", "(-)", "(/)" }


local function Format ( Code )
  for Index = 1, #SpaceLeft do
    Code = Code:gsub( "%s-"..SpaceLeft[Index].."%s-", " %1")
  end

  for Index = 1, #SpaceRight do
    Code = Code:gsub( "%s-"..SpaceRight[Index].."%s-", "%1 ")
  end

  for Index = 1, #DoubleSpace do
    Code = Code:gsub( "%s-"..DoubleSpace[Index].."%s-", " %1 ")
  end

  Code = Code:gsub( "([^<>~!])(=+)", "%1 %2 ")
  Code = Code:gsub( "%s+", " " ):trim()
  return Code
end


function Hekili:ShowDiagnosticTooltip( q )

    local tt = ns.Tooltip
    local fmt = ns.lib.Format

    -- Grab the default backdrop and copy it with a solid background.
    local backdrop = GameTooltip:GetBackdrop()
    backdrop.bgFile = [[Interface\Buttons\WHITE8X8]]

    tt:SetBackdrop( backdrop )

    tt:SetOwner( UIParent, "ANCHOR_CURSOR" )
    tt:SetBackdropColor( 0, 0, 0, 1 )
    tt:SetText( class.abilities[ q.actionName ].name )
    tt:AddDoubleLine( q.listName.." #"..q.action, "+" .. ns.formatValue( round( q.time or 0, 2 ) ), 1, 1, 1, 1, 1, 1 )

    if q.resources and q.resources[ q.resource_type ] then
        tt:AddDoubleLine( q.resource_type, ns.formatValue( q.resources[ q.resource_type ] ), 1, 1, 1, 1, 1, 1 )
    end

    if q.HookHeader or ( q.HookScript and q.HookScript ~= "" ) then
        if q.HookHeader then
            tt:AddLine( "\n"..q.HookHeader )
        else
            tt:AddLine( "\nHook Criteria" )
        end

        if q.HookScript and q.HookScript ~= "" then
            local Text = Format ( q.HookScript )
            tt:AddLine( fmt:ColorString( Text, SyntaxColors ), 1, 1, 1, 1 )
        end

        if q.HookElements then
            local applied = false
            for k, v in orderedPairs( q.HookElements ) do
                if not applied then
                    tt:AddLine( "Values" )
                    applied = true
                end
                tt:AddDoubleLine( k, ns.formatValue( v ) , 1, 1, 1, 1, 1, 1 )
            end
        end
    end

    if q.ReadyScript and q.ReadyScript ~= "" then
        tt:AddLine("\nTime Script" )

        local Text = Format( q.ReadyScript )
        tt:AddLine( fmt:ColorString( Text, SyntaxColors ), 1, 1, 1, 1 )

        if q.ReadyElements then
            tt:AddLine( "Values" )
            for k,v in orderedPairs( q.ReadyElements ) do
                tt:AddDoubleLine( k, ns.formatValue( v ), 1, 1, 1, 1, 1, 1 )
            end
        end
    end

    if q.ActScript and q.ActScript ~= "" then
        tt:AddLine( "\nAction Criteria" )

        local Text = Format ( q.ActScript )
        tt:AddLine( fmt:ColorString( Text, SyntaxColors ), 1, 1, 1, 1 )

        if q.ActElements then
            tt:AddLine( "Values" )
            for k,v in orderedPairs( q.ActElements ) do
                tt:AddDoubleLine( k, ns.formatValue( v ) , 1, 1, 1, 1, 1, 1 )
            end
        end
    end
    tt:Show()
    
end


function Hekili:SaveCoordinates()
  for i in pairs(Hekili.DB.profile.displays) do
    local _, _, rel, x, y = ns.UI.Displays[i]:GetPoint()

    self.DB.profile.displays[i].rel = "CENTER"
    self.DB.profile.displays[i].x = x
    self.DB.profile.displays[i].y = y
  end

  _, _, _, self.DB.profile['Notification X'], self.DB.profile['Notification Y'] = HekiliNotification:GetPoint()

end
