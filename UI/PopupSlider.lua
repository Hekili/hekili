local strformat = string.format
local noop = function() end

HekiliPopupDropdownMixin = {};

function HekiliPopupDropdownMixin:OnLoad()
    local function UpdateText(slider, value, isMouse)
        if value % 1 > 0 then
            self.Text:SetText( strformat( "%.1f", value ) )
        else
            self.Text:SetText( strformat( "%d", value ) )
        end
    end
    self.Slider:RegisterPropertyChangeHandler( "OnValueChanged", UpdateText )
end

function HekiliPopupDropdownMixin:OnShow()
    -- self.Toggle:RegisterEvents();
    if ElvUI then
        local E = ElvUI[1]
        local S = E:GetModule( "Skins" )
        S:HandleSliderFrame( self.Slider )

        local r, g, b = unpack( E.media.rgbvaluecolor )

        local name = self:GetName()
        local highlight = _G[ name .. "Highlight" ]

        highlight:SetTexture( E.Media.Textures.Highlight )
        highlight:SetBlendMode( 'BLEND' )
        highlight:SetDrawLayer( 'BACKGROUND' )
        highlight:SetVertexColor( r, g, b )

        self.Slider.backdrop:SetFrameLevel( self:GetFrameLevel() + 1 )
    end

    self.Slider:SetFrameLevel( self:GetFrameLevel() + 2 )

    self:ClearAllPoints()
    self:SetAllPoints( self.owningButton )
end

function HekiliPopupDropdownMixin:OnHide()
    -- self.Toggle:UnregisterEvents();
end

function HekiliPopupDropdownMixin:OnSetOwningButton()
    -- self.Toggle:UpdateVisibleState();
    self.Slider:UpdateVisibleState()
end


HekiliPopupDropdownSliderMixin = {};

function HekiliPopupDropdownSliderMixin:OnLoad()
    self:SetAccessorFunction(self.Set or noop);
    self:SetMutatorFunction(self.Get or noop);
end