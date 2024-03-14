local _, addon = ...
local Easing = {};
addon.Easing = Easing;

local sin = math.sin;
local cos = math.cos;
local pow = math.pow;
local pi = math.pi;

local TARGET_FRAME_PER_SEC = 60.0;

local function Clamp(value, min, max)
	if value > max then
		return max
	elseif value < min then
		return min
	end
	return value
end

local function Saturate(value)
	return Clamp(value, 0.0, 1.0)
end

local function Lerp(startValue, endValue, amount)
    return (1 - amount) * startValue + amount * endValue;
end


local function DeltaLerp(startValue, endValue, amount, timeSec)
	return Lerp(startValue, endValue, Saturate(amount * timeSec * TARGET_FRAME_PER_SEC));
end


local function InterpolateDimension(lastValue, targetValue, amount, elapsed)
	return lastValue and amount and DeltaLerp(lastValue, targetValue, amount, elapsed) or targetValue
end

local function OutQuart(elapsed, fromValue, toValue, duration)
    elapsed = elapsed / duration - 1;
    return (fromValue - toValue) * (pow(elapsed, 4) - 1) + fromValue
end

Easing.Lerp = Lerp;
Easing.InterpolateDimension = InterpolateDimension;
Easing.OutQuart = OutQuart;