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

    self.Slider:RegisterPropertyChangeHandler( "OnValueChanged", UpdateText );
end

function HekiliPopupDropdownMixin:OnShow()
    -- self.Toggle:RegisterEvents();
end

function HekiliPopupDropdownMixin:OnHide()
    -- self.Toggle:UnregisterEvents();
end

function HekiliPopupDropdownMixin:OnSetOwningButton()
    -- self.Toggle:UpdateVisibleState();
    self.Slider:UpdateVisibleState();
end


HekiliPopupDropdownSliderMixin = {};

function HekiliPopupDropdownSliderMixin:OnLoad()
    self:SetAccessorFunction(self.Set or noop);
    self:SetMutatorFunction(self.Get or noop);
end