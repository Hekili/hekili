local _, addon = ...


local TEMPLATE_NAME = "AnimatedQueueActionTemplate";

local BUTTON_SIZE_PRIMARY = 45;
local BUTTON_SIZE_QUEUE_MIN = 36;
local BUTTON_CENTER_OFFSET = 45;
local PRIMARY_ACTION_FRAME_LEVEL = 20;
local INTERPOLATION_AMOUNT = 0.15;
local GLOBAL_COOLDOWN = 1.5;

local Lerp = addon.Easing.Lerp;
local InterpolateDimension = addon.Easing.InterpolateDimension;

local FindBaseSpellByID = FindBaseSpellByID;


local function GetPixelSize()
    local SCREEN_WIDTH, SCREEN_HEIGHT = GetPhysicalScreenSize();
    local scale = UIParent:GetEffectiveScale();
    return (768/SCREEN_HEIGHT)/scale
end

PIXEL = GetPixelSize();

local GAP = 2 * PIXEL;

--[[
local TEST_SPELLS = {
    12051, 30451, 153626, 55342, 44425
};
--]]

local QUEUE_SIZE = 4;   --#TEST_SPELLS

AnimatedQueueFrameMixin = {};

function AnimatedQueueFrameMixin:OnLoad()
    self.offset = 0;
    self.castSucceeded = true;
    self.ActionButtons = {};
    self:SetSize(BUTTON_SIZE_PRIMARY, BUTTON_SIZE_PRIMARY);
    self.HighlightFrame:SetFrameLevel(PRIMARY_ACTION_FRAME_LEVEL + 5);
    self.HighlightFrame:SetSize(BUTTON_SIZE_PRIMARY, BUTTON_SIZE_PRIMARY);
    self:EnableSpellCastFeedback(true);
end

function AnimatedQueueFrameMixin:ClearQueue()
    for i, button in pairs(self.ActionButtons) do
        button:ClearAction();
        button:Hide();
    end
end

function AnimatedQueueFrameMixin:AcquireButton(order)
    if not self.ActionButtons[order] then
        local button = CreateFrame("Frame", nil, self.ActionContainer, TEMPLATE_NAME);
        self.ActionButtons[order] = button
        --button:SetPoint("CENTER", self.ActionContainer, "CENTER", (order - 1) * BUTTON_CENTER_OFFSET, 0);
        button:SetFrameLevel( PRIMARY_ACTION_FRAME_LEVEL - order + 1 );
        button.order = order;
        if order == 1 then
            button:SetPoint("CENTER", self.ActionContainer, "CENTER", 0, 0);
        elseif order == 2 then
            button:SetPoint("CENTER", self.ActionContainer, "CENTER", BUTTON_SIZE_PRIMARY, 0);
            button.isPrimary = true;
        else
            button:SetPoint("CENTER", self.ActionContainer, "CENTER", BUTTON_SIZE_PRIMARY + GAP + (order - 2) * (BUTTON_SIZE_QUEUE_MIN + GAP), 0);
        end
        button:SetAlpha(0);
    end
    return self.ActionButtons[order];
end

function AnimatedQueueFrameMixin:SetAbilityByOrder(order, ability)
    self:AcquireButton(order):SetAbility(ability);
end

function AnimatedQueueFrameMixin:QueueAbility(order, ability)
    self.newQueue[order] = ability;
end

function AnimatedQueueFrameMixin:PreQueueUpdate()
    self.newQueue = {};
end

function AnimatedQueueFrameMixin:OnQueueFullyUpdate()
    --[[
    if self.queue then
        local anyChange = false;
        for order, ability in ipairs(self.newQueue) do
            if ability ~= self.queue[order] then
                anyChange = true;
                break
            end
        end
        if not anyChange then
            return
        end
    end
    --]]

    for order, ability in ipairs(self.newQueue) do
        self:SetAbilityByOrder(order + 1, ability);
    end
    if self.queue then
        self:SetAbilityByOrder(1, self.queue[1]);
    end

    self.queue = self.newQueue;

    if self.castSucceeded then
        self.castSucceeded = false;
        self:StartMoving();
    end
    --self:UpdateVisual();
end

function AnimatedQueueFrameMixin:OnUpdate(elapsed)
    self.t = self.t + elapsed;

    self.offset = InterpolateDimension(self.offset, self.toOffset, INTERPOLATION_AMOUNT, elapsed);

    local diff = self.offset - self.toOffset;
    if diff < 0 then
        diff = -diff;
    end
    if diff <= PIXEL then
        self.offset = self.toOffset;
        self:SetScript("OnUpdate", nil);
    end

    self.ActionContainer:SetPoint("CENTER", self.offset, 0);
    self:UpdateVisual();
end

function AnimatedQueueFrameMixin:OnUpdate_Holding(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 1.5 then
        self.t = 0;
        self:StartMoving();
    end
end

function AnimatedQueueFrameMixin:StartHolding()
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate_Holding);
end

function AnimatedQueueFrameMixin:StartMoving()
    self.offset = 0;
    self.toOffset = self.offset - BUTTON_CENTER_OFFSET;
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function AnimatedQueueFrameMixin:UpdateVisual()
    local alpha;
    local iconSize;
    local ratio;
    local buttonOffset;

    for i, button in pairs(self.ActionButtons) do
        buttonOffset = self.offset + (i - 1)*BUTTON_SIZE_PRIMARY;
        if buttonOffset < 0 then
            buttonOffset = -buttonOffset;
        end

        ratio = buttonOffset / BUTTON_SIZE_PRIMARY;
        if ratio > 1 then
            ratio = 1;
        end

        iconSize = Lerp(BUTTON_SIZE_PRIMARY, BUTTON_SIZE_QUEUE_MIN, ratio);
        button:SetIconSize(iconSize)

        if i == 1 then
            alpha = 1 + self.offset / BUTTON_SIZE_PRIMARY;
        elseif i >= QUEUE_SIZE then
            alpha = (-self.offset) / BUTTON_SIZE_PRIMARY;
        else
            alpha = 1;
        end


        if alpha < 0 then
            alpha = 0;
        elseif alpha > 1 then
            alpha = 1;
        end
        button:SetAlpha(alpha)
    end
end


function AnimatedQueueFrameMixin:PlayPrimaryGlow(state)
    self.HighlightFrame:StopAnimating();
    self.HighlightFrame.Icon:SetAlpha(0);
    self.HighlightFrame.GlowBorder:SetAlpha(0);

    if state then
        self.HighlightFrame.Icon:SetTexture(self.ActionButtons[2].icon)
        self.HighlightFrame.AnimGlow:Play();
        self.castSucceeded = true;
    end
end

function AnimatedQueueFrameMixin:IsQueuedSpell(order, spellID)
    if not self.ActionButtons[order] then return false end;

    local queuedSpell = self.ActionButtons[order].spellID;
    return queuedSpell and (spellID == queuedSpell or FindBaseSpellByID(spellID) == queuedSpell)
end

function AnimatedQueueFrameMixin:OnEvent(event, ...)
    if event == "UNIT_SPELLCAST_START" then
        local _, _, spellID = ...
        if self:IsQueuedSpell(2, spellID) then
            self:PlayPrimaryGlow(true);
            self.consumeNextSpellEvent = true;
        else
            self:PlayPrimaryGlow(false);
            self.consumeNextSpellEvent = false;
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if self.consumeNextSpellEvent then
            self.consumeNextSpellEvent = false;
            return
        end
        local _, _, spellID = ...

        self.consumeNextSpellEvent = false;
        if self:IsQueuedSpell(2, spellID) then
            self:PlayPrimaryGlow(true);
        else
            self:PlayPrimaryGlow(false);
        end
    end
end

function AnimatedQueueFrameMixin:EnableSpellCastFeedback(state)
    if state then
        self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
        self:SetScript("OnEvent", self.OnEvent);
    else
        self:UnregisterEVent("UNIT_SPELLCAST_START");
        self:UnregisterEVent("UNIT_SPELLCAST_SUCCEEDED");
        self:SetScript("OnEvent", nil);
    end
end