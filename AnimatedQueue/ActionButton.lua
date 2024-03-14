local _, addon = ...

local OutQuart = addon.Easing.OutQuart;

local GetSpellInfo = GetSpellInfo;
local GetSpellTexture = GetSpellTexture;
local UnitCastingInfo = UnitCastingInfo;
local UnitChannelInfo = UnitChannelInfo;
local GetSpellLossOfControlCooldown = GetSpellLossOfControlCooldown;
local GetSpellCooldown = GetSpellCooldown;
local GetSpellCharges = GetSpellCharges;
local GetTime = GetTime;
local GetCooldownAuraBySpellID = C_UnitAuras.GetCooldownAuraBySpellID;
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;

local ANIM_DURATION_PUSH_DOWN = 0.25;
local PUSH_DOWN_OFFSET = -8;


AnimatedQueueActionMixin = {};

function AnimatedQueueActionMixin:OnLoad()

end

local function AnimOnUpdate_FadeInIcon(self, elapsed)
    self.iconAlpha = self.iconAlpha + 5*elapsed;
    if self.iconAlpha >= 1 then
        self.iconAlpha = 1;
        self:SetScript("OnUpdate", nil);
    end
    self.Icon:SetAlpha(self.iconAlpha);
end

local function AnimOnUpdate_FadeOutIcon(self, elapsed)
    self.iconAlpha = self.iconAlpha - 10*elapsed;
    if self.iconAlpha <= 0 then
        self.iconAlpha = 0;
        self.Icon:SetTexture(self.icon);
        self:SetScript("OnUpdate", AnimOnUpdate_FadeInIcon);
    end
    self.Icon:SetAlpha(self.iconAlpha);
end

function AnimatedQueueActionMixin:SetIcon(icon, fade)
    if fade then
        if icon ~= self.icon then
            self.icon = icon;
            self.iconAlpha = self.Icon:GetAlpha();
            self:SetScript("OnUpdate", AnimOnUpdate_FadeOutIcon);
        end
    else
        self.Icon:SetTexture(icon);
        self:SetScript("OnUpdate", nil);
    end
end

function AnimatedQueueActionMixin:UpdateCooldown()
    if self.order == 1 then
        self.Cooldown:Clear();
        return
    end

    local passiveCooldownSpellID, auraData;

    if self.spellID then
		passiveCooldownSpellID = GetCooldownAuraBySpellID(self.spellID);
	end

	if passiveCooldownSpellID and passiveCooldownSpellID ~= 0 then
		auraData = GetPlayerAuraBySpellID(passiveCooldownSpellID);
	end

    local start, duration, enable, modRate, locStart, locDuration, charges, maxCharges, chargeStart, chargeDuration, chargeModRate, forceShowDrawEdge, endTime;

    if auraData then
		local currentTime = GetTime();
        endTime = auraData.expirationTime;
		local timeUntilExpire = endTime - currentTime;
		local howMuchTimeHasPassed = auraData.duration - timeUntilExpire;
		locStart =  currentTime - howMuchTimeHasPassed;
		locDuration = endTime - currentTime;
		start = currentTime - howMuchTimeHasPassed;
		duration =  auraData.duration
		modRate = auraData.timeMod; 
		charges = auraData.charges; 
		maxCharges = auraData.maxCharges;
		chargeStart = currentTime * 0.001;
		chargeDuration = duration * 0.001;
		chargeModRate = modRate;
		enable = 1;
	elseif self.spellID then
		locStart, locDuration = GetSpellLossOfControlCooldown(self.spellID);
		start, duration, enable, modRate = GetSpellCooldown(self.spellID);
		charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetSpellCharges(self.spellID);
        endTime = start + duration;
    end

    if (locStart + locDuration) > (start + duration) then
        start, duration = locStart, locDuration;
        forceShowDrawEdge = true;
    else
        if ( charges and maxCharges and maxCharges > 1 and charges == 0 ) then
            start, duration, modRate = chargeStart, chargeDuration, chargeModRate;
		else
			--ClearChargeCooldown(self);
		end
        forceShowDrawEdge = false;
    end

    if self.isPrimary then
        local startTimeMS, endTimeMS = select(4, UnitCastingInfo( "player" ));
        if not startTimeMS then
            startTimeMS, endTimeMS = select(4, UnitChannelInfo( "player" ));
        end
        if startTimeMS and endTimeMS then
            local currentCastStartTime = startTimeMS * 0.001;
            local currentCastEndTime = endTimeMS * 0.001;
            if currentCastEndTime > endTime then
                start = currentCastStartTime;
                duration = currentCastEndTime - currentCastStartTime;
            end
        end
    end

    if enable and enable ~= 0 and start > 0 and duration > 0 then
		self.Cooldown:SetDrawEdge(forceShowDrawEdge);
		self.Cooldown:SetCooldown(start, duration, modRate);
    else
        self.Cooldown:Clear();
    end
end

function AnimatedQueueActionMixin:SetSpell(spellID)
    if spellID ~= self.spellID then
        self.spellID = spellID;
        local icon = GetSpellTexture(spellID);
        self:SetIcon(icon, true);
    end

    self:UpdateCooldown();
end

function AnimatedQueueActionMixin:SetAbility(ability)
    --Hekili ability ("local ability = class.abilities[ action ]" in Hekili\Core.lua)
    if ability then
        --if ability.gcd == "spell" then
        --    self:SetSpell(ability.id);
        --end
        self:SetSpell(ability.id);
        self.HotKey:SetText(ability.keybind);
    else
        self:ClearAction();
    end
end

function AnimatedQueueActionMixin:ClearAction()
    self.spellID = nil;
    self.itemID = nil;
    self.HotKey:SetText(nil);
end

function AnimatedQueueActionMixin:SetIconSize(side)
    self.Icon:SetSize(side, side);
    self.Cooldown:SetSize(side, side);
end