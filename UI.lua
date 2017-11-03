-- UI.lua
-- Dynamic UI Elements

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class

local getInverseDirection = ns.getInverseDirection
local multiUnpack = ns.multiUnpack
local orderedPairs = ns.orderedPairs
local round = ns.round

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

    if ns.UI.Buttons[i][1] and ns.visible.display[ i ] and Hekili.DB.profile.displays[ i ] then
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
      -- v.Header:SetSize( v:GetWidth() * 0.5, 20 )
      v.Header:SetAllPoints( v )
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
    ACD:SetDefaultSize( "Hekili", 805, 605 )
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

  ns.cacheCriteria()

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

  ns.UI.Displays = ns.UI.Displays or {}
  ns.UI.Buttons	= ns.UI.Buttons or {}

  for dispID, display in ipairs( Hekili.DB.profile.displays ) do

    local f = ns.UI.Displays[dispID] or CreateFrame( "Frame", "HekiliDisplay"..dispID, UIParent )

    local border = scaleFactor * 4

    if display.queueDirection == 'TOP' or display.queueDirection == 'BOTTOM' then
      f:SetSize( scaleFactor * max( Hekili.DB.profile.displays[dispID].primaryIconSize, Hekili.DB.profile.displays[dispID].queuedIconSize ), border + scaleFactor * ( Hekili.DB.profile.displays[dispID].primaryIconSize + ( Hekili.DB.profile.displays[dispID].queuedIconSize * ( Hekili.DB.profile.displays[dispID].numIcons - 1 ) ) + ( Hekili.DB.profile.displays[dispID].iconSpacing * ( Hekili.DB.profile.displays[dispID].numIcons - 1 ) ) ) )
    else
      f:SetSize( scaleFactor * ( Hekili.DB.profile.displays[dispID].primaryIconSize + ( Hekili.DB.profile.displays[dispID].queuedIconSize * ( Hekili.DB.profile.displays[dispID].numIcons - 1 ) ) + ( Hekili.DB.profile.displays[dispID].iconSpacing * ( Hekili.DB.profile.displays[dispID].numIcons - 1 ) ) ), border + scaleFactor * max( Hekili.DB.profile.displays[dispID].primaryIconSize, Hekili.DB.profile.displays[dispID].queuedIconSize ) )
    end
    f:SetPoint( "CENTER", Screen, "CENTER", Hekili.DB.profile.displays[ dispID ].x, Hekili.DB.profile.displays[ dispID ].y )
    f:SetFrameStrata( "MEDIUM" )
    f:SetClampedToScreen( true )
    f:EnableMouse( false )
    f:SetMovable( true )
    ns.UI.Displays[dispID] = f

    ns.UI.Buttons[dispID] = ns.UI.Buttons[dispID] or {}

    if not Hekili[ 'ProcessDisplay'..dispID ] then
      Hekili[ 'ProcessDisplay'..dispID ] = function()
        Hekili:ProcessHooks( dispID )
      end
    end

    for i = 1, max( #ns.UI.Buttons[dispID], display.numIcons ) do
      ns.UI.Buttons[dispID][i] = Hekili:CreateButton( dispID, i )
      ns.UI.Buttons[dispID][i]:Hide()

      if Hekili.DB.profile.Enabled and ns.visible.display[ dispID ] and i <= display.numIcons then
        local alpha = ns.CheckDisplayCriteria and ns.CheckDisplayCriteria( dispID ) or 0
        if alpha > 0 then
          ns.UI.Buttons[dispID][i]:SetAlpha( alpha )
          ns.UI.Buttons[dispID][i]:Show()
        end
      end

      if MasqueGroup then MasqueGroup:AddButton( ns.UI.Buttons[dispID][i], { Icon = ns.UI.Buttons[dispID][i].Texture, Cooldown = ns.UI.Buttons[dispID][i].Cooldown } ) end
    end

  end

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


function Hekili:CreateButton( display, ID )

  local name = "Hekili_D" .. display .. "_B" .. ID
  local disp = self.DB.profile.displays[display]

  local button = ns.UI.Buttons[ display ][ ID ] or CreateFrame( "Button", name, ns.UI.Displays[ display ] )

  local btnSize
  if ID == 1 then
    btnSize = disp.primaryIconSize
  else
    btnSize = disp.queuedIconSize
  end
  local btnDirection = disp.queueDirection
  local btnAlignment = disp.queueAlignment or 'c'
  local btnSpacing = disp.iconSpacing

  local scaleFactor = Hekili:GetScale()

  button:SetFrameStrata( "LOW" )
  button:SetFrameLevel( display * 10 )
  button:SetClampedToScreen( true )

  button:SetSize( scaleFactor * btnSize, scaleFactor * btnSize )

  if not button.Texture then
    button.Texture = button:CreateTexture(nil, "LOW")
    button.Texture:SetTexture('Interface\\ICONS\\Spell_Nature_BloodLust')
    button.Texture:SetAlpha(1)
  end
  button.Texture:SetAllPoints(button)

  local SharedMedia = LibStub( "LibSharedMedia-3.0", true )

  -- Indicator Icons
  button.Icon = button.Icon or button:CreateTexture( nil, "OVERLAY" )
  button.Icon:SetSize( max( 10, button:GetWidth() / 3 ), max( 10, button:GetHeight() / 3 ) )
  local iconAnchor = disp.indicatorAnchor or "RIGHT"
  button.Icon:SetPoint( iconAnchor, button, iconAnchor, disp.xOffsetIndicators or 0, disp.yOffsetIndicators or 0 )
  button.Icon:Hide()

  button.Caption = button.Caption or button:CreateFontString(name.."Caption", "OVERLAY" )
  local capFont = disp.captionFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )  
  button.Caption:SetFont( SharedMedia:Fetch( "font", capFont ), disp.captionFontSize or 12, disp.captionFontStyle or "OUTLINE" )
  button.Caption:SetSize( button:GetWidth(), button:GetHeight() / 2 )
  local capAnchor = disp.captionAnchor or "BOTTOM"
  button.Caption:ClearAllPoints()
  button.Caption:SetPoint( capAnchor, button, capAnchor, disp.xOffsetCaptions or 0, disp.yOffsetCaptions or 0 )
  button.Caption:SetJustifyV( capAnchor )
  button.Caption:SetJustifyH( disp.captionAlign or "CENTER" )
  button.Caption:SetTextColor( 1, 1, 1, 1 )

  if ID == 1 then
      button.Targets = button.Targets or button:CreateFontString( name.."Targets", "OVERLAY" )

      local tarFont = disp.targetFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
      button.Targets:SetFont( SharedMedia:Fetch( "font", tarFont ), disp.targetFontSize or 12, disp.targetFontStyle or "OUTLINE" )
      button.Targets:SetSize( button:GetWidth(), button:GetHeight() / 2 )
      
      local tarAnchor = disp.targetAnchor or "BOTTOM"
      button.Targets:ClearAllPoints()
      button.Targets:SetPoint( tarAnchor, button, tarAnchor, disp.xOffsetTargets or 0, disp.yOffsetTargets or 0 )
      
      local tarAlign = tarAnchor:match( "RIGHT" ) and "RIGHT" or ( tarAnchor:match( "LEFT" ) and "LEFT" or "CENTER" )
      button.Targets:SetJustifyH( tarAlign )
      local tarAlignV = tarAnchor:match( "TOP" ) and "TOP" or ( tarAnchor:match( "BOTTOM" ) and "BOTTOM" or "MIDDLE" )
      button.Targets:SetJustifyV( tarAlignV )
      
      button.Targets:SetTextColor( 1, 1, 1, 1 )
  
      
      button.Auras = button.Auras or button:CreateFontString( name.."Auras", "OVERLAY" )

      local auraFont = disp.auraFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
      button.Auras:SetFont( SharedMedia:Fetch( "font", auraFont ), disp.auraFontSize or 12, disp.auraFontStyle or "OUTLINE" )
      button.Auras:SetSize( button:GetWidth(), button:GetHeight() / 2 )

      local auraAnchor = disp.auraAnchor or "BOTTOM"
      button.Auras:ClearAllPoints()
      button.Auras:SetPoint( auraAnchor, button, auraAnchor, disp.xOffsetAuras or 0, disp.yOffsetAuras or 0 )

      local auraAlign = auraAnchor:match( "RIGHT" ) and "RIGHT" or ( auraAnchor:match( "LEFT" ) and "LEFT" or "CENTER" )
      button.Auras:SetJustifyH( auraAlign )
      local auraAlignV = auraAnchor:match( "TOP" ) and "TOP" or ( auraAnchor:match( "BOTTOM" ) and "BOTTOM" or "MIDDLE" )
      button.Auras:SetJustifyV( auraAlignV )
      
      button.Auras:SetTextColor( 1, 1, 1, 1 )

  end

  -- Keybinding Text
  button.Keybinding = button.Keybinding or button:CreateFontString(name.."KB", "OVERLAY" )
  local kbFont = disp.kbFont or ( ElvUI and "PT Sans Narrow" or "Arial Narrow" )
  button.Keybinding:SetFont( SharedMedia:Fetch( "font", kbFont ), disp.kbFontSize or 12, disp.kbFontStyle or "OUTLINE" )
  button.Keybinding:SetSize( button:GetWidth(), button:GetHeight() / 2 )
  local kbAnchor = disp.kbAnchor or "TOPRIGHT"
  button.Keybinding:ClearAllPoints()
  button.Keybinding:SetPoint( kbAnchor, button, kbAnchor, disp.xOffsetKBs or 0, disp.yOffsetKBs or 0 )
  local kbAlign = kbAnchor:match( "RIGHT" ) and "RIGHT" or ( kbAnchor:match( "LEFT" ) and "LEFT" or "CENTER" )
  button.Keybinding:SetJustifyH( kbAlign )
  local kbAlignV = kbAnchor:match( "TOP" ) and "TOP" or ( kbAnchor:match( "BOTTOM" ) and "BOTTOM" or "MIDDLE" )
  button.Keybinding:SetJustifyV( kbAlignV )
  button.Keybinding:SetTextColor( 1, 1, 1, 1 )

  button.Delay = button.Delay or button:CreateFontString( name.."Delay", "OVERLAY" )
  button.Delay:SetSize( button:GetWidth(), button:GetHeight() / 2 )
  button.Delay:SetPoint( "TOPLEFT", button, "TOPLEFT" )
  button.Delay:SetJustifyV( "TOP" )
  button.Delay:SetJustifyH( "LEFT" )
  button.Delay:SetTextColor( 1, 1, 1, 1 )

  button.Cooldown = button.Cooldown or CreateFrame( "Cooldown", name .. "_Cooldown", button, "CooldownFrameTemplate" )
  button.Cooldown:SetAllPoints(button)
  button.Cooldown:SetFrameStrata( "MEDIUM" )
  button.Cooldown:SetDrawBling( false ) -- disabled until Blizzard fixes the animation.
  button.Cooldown:SetDrawEdge( false )

  button:ClearAllPoints()

  if ID == 1 then
    button.Overlay = button.Overlay or button:CreateTexture( nil, "OVERLAY" )
    button.Overlay:SetAllPoints(button)
    button.Overlay:Hide()

    -- button.Caption:SetFont( SharedMedia:Fetch( "font", disp.Font ), disp.primaryFontSize, "OUTLINE" )
    button.Delay:SetFont( SharedMedia:Fetch( "font", disp.Font ), disp.primaryFontSize * 0.67, "OUTLINE" )

    button:SetPoint( getInverseDirection( btnDirection ), ns.UI.Displays[ display ], getInverseDirection( btnDirection ) )
    -- button:SetPoint( "LEFT", ns.UI.Displays[ display ], "LEFT" ) -- self.DB.profile.displays[ display ].rel or "CENTER", self.DB.profile.displays[ display ].x, self.DB.profile.displays[ display ].y )

  else
    -- button.Caption:SetFont( SharedMedia:Fetch("font", disp.Font), disp.queuedFontSize, "OUTLINE" )

    if btnDirection == 'RIGHT' then
      local align
      
      if btnAlignment == 'a' then align = 'TOP'
      elseif btnAlignment == 'b' then align = 'BOTTOM'
      else align = '' end
    
      button:SetPoint( align .. getInverseDirection( btnDirection ), 'Hekili_D' .. display.. "_B" .. ID - 1,  align .. btnDirection, btnSpacing * scaleFactor, 0 )
    elseif btnDirection == 'LEFT' then
      local align
      
      if btnAlignment == 'a' then align = 'TOP'
      elseif btnAlignment == 'b' then align = 'BOTTOM'
      else align = '' end
    
      button:SetPoint( align .. getInverseDirection( btnDirection ), 'Hekili_D' .. display.. "_B" .. ID - 1,  align .. btnDirection, -1 *  btnSpacing * scaleFactor, 0 )
    elseif btnDirection == 'TOP' then
      local align
      
      if btnAlignment == 'a' then align = 'LEFT'
      elseif btnAlignment == 'b' then align = 'RIGHT'
      else align = '' end
    
      button:SetPoint( getInverseDirection( btnDirection ) .. align, 'Hekili_D' .. display.. "_B" .. ID - 1,  btnDirection .. align, 0, btnSpacing * scaleFactor )
    else -- BOTTOM
      local align
      
      if btnAlignment == 'a' then align = 'LEFT'
      elseif btnAlignment == 'b' then align = 'RIGHT'
      else align = '' end
    
      button:SetPoint( getInverseDirection( btnDirection ) .. align, 'Hekili_D' .. display.. "_B" .. ID - 1,  btnDirection .. align, 0, -1 * btnSpacing * scaleFactor )
    end

  end

  button:SetScript( "OnMouseDown", Button_OnMouseDown )
  button:SetScript( "OnMouseUp", Button_OnMouseUp )

  button:SetScript( "OnEnter", function(self)
    if ( not Hekili.Pause ) or ( Hekili.Config or not Hekili.DB.profile.Locked ) then
      ns.Tooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
      ns.Tooltip:SetBackdropColor( 0, 0, 0, 1 )
      ns.Tooltip:SetText(Hekili.DB.profile.displays[ display ].Name .. " (" .. display .. ")")
      ns.Tooltip:AddLine("Left-click and hold to move.", 1, 1, 1)
      if not Hekili.Config or not Hekili.DB.profile.Locked then ns.Tooltip:AddLine("Right-click to lock all and close.",1 ,1 ,1) end
      ns.Tooltip:Show()
      self:SetMovable(true)
    elseif ( Hekili.Pause and ns.queue[ display ] and ns.queue[ display ][ ID ] ) then
      Hekili:ShowDiagnosticTooltip( ns.queue[ display ][ ID ] )
    end
  end )

  button:SetScript( "OnLeave", function(self)
    ns.Tooltip:Hide()
  end )

  button:EnableMouse( not Hekili.DB.profile.Locked )
  button:SetMovable( not Hekili.DB.profile.Locked )

  return button

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
