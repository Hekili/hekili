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

        if AddOnSkins then
            local AS = AddOnSkins[1]

            local r, g, b = unpack( AS.Color )

            local name = self:GetName()
            local highlight = _G[ name .. "Highlight" ]

            highlight:SetTexture( [[Interface\AddOns\AddOnSkins\Media\Textures\Highlight]] )
            highlight:SetVertexColor( r, g, b )
            highlight:SetDrawLayer( highlight:GetDrawLayer(), 0 )
        end
    end

    self.Slider.backdrop:SetFrameLevel( self:GetFrameLevel() + 1 )
    self.Slider:SetFrameLevel( self:GetFrameLevel() + 2 )
end

function HekiliPopupDropdownMixin:OnHide()
    -- self.Toggle:UnregisterEvents();
end

function HekiliPopupDropdownMixin:OnSetOwningButton()
    -- self.Toggle:UpdateVisibleState();
    self.Slider:UpdateVisibleState()
    self.owningButton:SetHeight( self:GetHeight() )
end


HekiliPopupDropdownSliderMixin = {};

function HekiliPopupDropdownSliderMixin:OnLoad()
    self:SetAccessorFunction(self.Set or noop);
    self:SetMutatorFunction(self.Get or noop);
end