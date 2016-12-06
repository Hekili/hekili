-- Minor tweak to avoid firing on PLAYER_ENTERING_WORLD.
-- My addon waits to see if gear is equipped and then will check artifact information.
-- Hoping to avoid the artifact not unlocked API bug.

local MAJOR, MINOR = "LibArtifactData-1.0h", 8

assert(_G.LibStub, MAJOR .. " requires LibStub")
local lib = _G.LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.callbacks = lib.callbacks or _G.LibStub("CallbackHandler-1.0"):New(lib)

local Debug = function() end
if _G.AdiDebug then
	Debug = _G.AdiDebug:Embed({}, MAJOR)
end

-- local store
local artifacts = {}
local equippedID, viewedID, activeID
artifacts.knowledgeLevel = 0
artifacts.knowledgeMultiplier = 1

-- constants
local _G                       = _G
local BACKPACK_CONTAINER       = _G.BACKPACK_CONTAINER
local BANK_CONTAINER           = _G.BANK_CONTAINER
local INVSLOT_MAINHAND         = _G.INVSLOT_MAINHAND
local LE_ITEM_CLASS_ARMOR      = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON     = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_QUALITY_ARTIFACT = _G.LE_ITEM_QUALITY_ARTIFACT
local NUM_BAG_SLOTS            = _G.NUM_BAG_SLOTS
local NUM_BANKBAGSLOTS         = _G.NUM_BANKBAGSLOTS

-- blizzard api
local aUI                              = _G.C_ArtifactUI
local Clear                            = aUI.Clear
local GetArtifactInfo                  = aUI.GetArtifactInfo
local GetArtifactKnowledgeLevel        = aUI.GetArtifactKnowledgeLevel
local GetArtifactKnowledgeMultiplier   = aUI.GetArtifactKnowledgeMultiplier
local GetContainerItemInfo             = _G.GetContainerItemInfo
local GetContainerNumSlots             = _G.GetContainerNumSlots
local GetCostForPointAtRank            = aUI.GetCostForPointAtRank
local GetCurrencyInfo                  = _G.GetCurrencyInfo
local GetEquippedArtifactInfo          = aUI.GetEquippedArtifactInfo
local GetInventoryItemEquippedUnusable = _G.GetInventoryItemEquippedUnusable
local GetItemInfo                      = _G.GetItemInfo
local GetNumObtainedArtifacts          = aUI.GetNumObtainedArtifacts
local GetNumPurchasableTraits          = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local GetNumRelicSlots                 = aUI.GetNumRelicSlots
local GetPowerInfo                     = aUI.GetPowerInfo
local GetPowers                        = aUI.GetPowers
local GetRelicInfo                     = aUI.GetRelicInfo
local GetRelicSlotType                 = aUI.GetRelicSlotType
local GetSpellInfo                     = _G.GetSpellInfo
local HasArtifactEquipped              = _G.HasArtifactEquipped
local IsAtForge                        = aUI.IsAtForge
local IsViewedArtifactEquipped         = aUI.IsViewedArtifactEquipped
local SocketContainerItem              = _G.SocketContainerItem
local SocketInventoryItem              = _G.SocketInventoryItem

-- lua api
local select   = _G.select
local strmatch = _G.string.match
local tonumber = _G.tonumber

local private = {} -- private space for the event handlers

lib.frame = lib.frame or _G.CreateFrame("Frame")
local frame = lib.frame
frame:UnregisterAllEvents() -- deactivate old versions
frame:SetScript("OnEvent", function(_, event, ...) private[event](event, ...) end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ARTIFACT_CLOSE")
frame:RegisterEvent("ARTIFACT_XP_UPDATE")
frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")

local function CopyTable(tbl)
	if not tbl then return {} end
	local copy = {};
	for k, v in pairs(tbl) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

local function PrepareForScan()
	frame:UnregisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:UnregisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		ArtifactFrame:UnregisterEvent("ARTIFACT_UPDATE")
	end
end

local function RestoreStateAfterScan()
	frame:RegisterEvent("ARTIFACT_UPDATE")
	_G.UIParent:RegisterEvent("ARTIFACT_UPDATE")

	local ArtifactFrame = _G.ArtifactFrame
	if ArtifactFrame and not ArtifactFrame:IsShown() then
		Clear()
		ArtifactFrame:RegisterEvent("ARTIFACT_UPDATE")
	end
end

local function InformEquippedArtifactChanged(artifactID)
	if artifactID ~= equippedID then
		Debug("ARTIFACT_EQUIPPED_CHANGED", artifactID, equippedID)
		lib.callbacks:Fire("ARTIFACT_EQUIPPED_CHANGED", artifactID, equippedID)
		equippedID = artifactID
	end
end

local function InformActiveArtifactChanged(artifactID)
	local oldActiveID = activeID
	if artifactID and not GetInventoryItemEquippedUnusable("player", INVSLOT_MAINHAND) then
		activeID = artifactID
	else
		activeID = nil
	end
	if oldActiveID ~= activeID then
		Debug("ARTIFACT_ACTIVE_CHANGED", activeID, oldActiveID)
		lib.callbacks:Fire("ARTIFACT_ACTIVE_CHANGED", activeID, oldActiveID)
	end
end

local function InformTraitsChanged(artifactID)
	Debug("ARTIFACT_TRAITS_CHANGED", artifactID, artifacts[artifactID].traits)
	lib.callbacks:Fire("ARTIFACT_TRAITS_CHANGED", artifactID, CopyTable(artifacts[artifactID].traits))
end

local function StoreArtifact(artifactID, name, icon, unspentPower, numRanksPurchased, numRanksPurchasable, power, maxPower, traits, relics)
	if not artifacts[artifactID] then
		artifacts[artifactID] = {
			name = name,
			icon = icon,
			unspentPower = unspentPower,
			numRanksPurchased = numRanksPurchased,
			numRanksPurchasable = numRanksPurchasable,
			power = power,
			maxPower = maxPower,
			powerForNextRank = maxPower - power,
			traits = traits,
			relics = relics,
		}
		Debug("ARTIFACT_ADDED", artifactID, name)
		lib.callbacks:Fire("ARTIFACT_ADDED", artifactID)
	else
		local current = artifacts[artifactID]
		current.unspentPower = unspentPower
		current.numRanksPurchased = numRanksPurchased -- numRanksPurchased does not include bonus traits from relics
		current.numRanksPurchasable = numRanksPurchasable
		current.power = power
		current.maxPower = maxPower
		current.powerForNextRank = maxPower - power
		current.traits = traits
		current.relics = relics
	end
end

local function ScanTraits(artifactID)
	local traits = {}
	local powers = GetPowers()

	for i = 1, #powers do
		local traitID = powers[i]
		local spellID, _, currentRank, maxRank, bonusRanks, _, _, _, isStart, isGold, isFinal = GetPowerInfo(traitID)
		if currentRank > 0 then
			local name, _, icon = GetSpellInfo(spellID)
			traits[#traits + 1] = {
				traitID = traitID,
				spellID = spellID,
				name = name,
				icon = icon,
				currentRank = currentRank,
				maxRank = maxRank,
				bonusRanks = bonusRanks,
				isGold = isGold,
				isStart = isStart,
				isFinal = isFinal,
			}
		end
	end

	if artifactID then
		artifacts[artifactID].traits = traits
	end

	return traits
end

local function ScanRelics(artifactID)
	local relics = {}
	for i = 1, ( GetNumRelicSlots() or 0 ) do
		local slotType = GetRelicSlotType(i)
		local lockedReason, name, icon, link = GetRelicInfo(i)
		local isLocked = lockedReason and true or false
		local itemID
		if name then
			itemID = strmatch(link, "item:(%d+):")
		end

		relics[i] = { type = slotType, isLocked = isLocked, name = name, icon = icon, itemID = itemID, link = link }
	end

	if artifactID then
		artifacts[artifactID].relics = relics
	end

	return relics
end

local function GetArtifactKnowledge()
	local lvl = GetArtifactKnowledgeLevel()
	local mult = GetArtifactKnowledgeMultiplier()
	if artifacts.knowledgeMultiplier ~= mult or artifacts.knowledgeLevel ~= lvl then
		artifacts.knowledgeLevel = lvl
		artifacts.knowledgeMultiplier = mult
		Debug("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
		lib.callbacks:Fire("ARTIFACT_KNOWLEDGE_CHANGED", lvl, mult)
	end
end

local function GetViewedArtifactData()
	GetArtifactKnowledge()
	local itemID, _, name, icon, unspentPower, numRanksPurchased = GetArtifactInfo() -- TODO: appearance stuff needed? altItemID ?
	if not itemID then
		Debug("|cffff0000ERROR:|r", "GetArtifactInfo() returned nil.")
		return
	end
	viewedID = itemID
	Debug("GetViewedArtifactData", name, itemID)
	local numRanksPurchasable, power, maxPower = GetNumPurchasableTraits(numRanksPurchased, unspentPower)
	local traits = ScanTraits()
	local relics = ScanRelics()
	StoreArtifact(itemID, name, icon, unspentPower, numRanksPurchased, numRanksPurchasable, power, maxPower, traits, relics)

	if IsViewedArtifactEquipped() then
		InformEquippedArtifactChanged(itemID)
		InformActiveArtifactChanged(itemID)
	end
end

local function ScanContainer(container, numObtained)
	for slot = 1, GetContainerNumSlots(container) do
		local _, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(container, slot)
		if quality == LE_ITEM_QUALITY_ARTIFACT then
			local classID = select(12, GetItemInfo(itemID))
			if classID == LE_ITEM_CLASS_WEAPON or classID == LE_ITEM_CLASS_ARMOR then
				Debug("ARTIFACT_FOUND", "in", container, slot)
				SocketContainerItem(container, slot)
				GetViewedArtifactData()
				Clear()
				numObtained = numObtained - 1
				if numObtained <= 0 then break end
			end
		end
	end

	return numObtained
end

local function IterateContainers(from, to, numObtained)
	for container = from, to do
		numObtained = ScanContainer(container, numObtained)
		if numObtained <= 0 then break end
	end

	return numObtained
end

local function ScanBank(numObtained)
	PrepareForScan()
	numObtained = ScanContainer(BANK_CONTAINER, numObtained)
	if numObtained > 0 then
		IterateContainers(NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, numObtained)
	end
	RestoreStateAfterScan()
end

local function InitializeScan(event)
	if _G.ArtifactFrame and _G.ArtifactFrame:IsShown() then
		Debug("InitializeScan", "aborted because ArtifactFrame is open.")
		return
	end

	local numObtained = GetNumObtainedArtifacts() -- not available at cold login
	Debug("InitializeScan", event, "numObtained", numObtained)

	if numObtained > 0 then
		PrepareForScan()
		if HasArtifactEquipped() then -- scan equipped
			SocketInventoryItem(INVSLOT_MAINHAND)
			GetViewedArtifactData()
			Clear()
			numObtained = numObtained - 1
		end
		if numObtained > 0 then -- scan bags
			numObtained = IterateContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS, numObtained)
		end
		if numObtained > 0 then -- scan bank
			frame:RegisterEvent("BANKFRAME_OPENED")
			Debug("ARTIFACT_DATA_MISSING", "artifact", numObtained)
			lib.callbacks:Fire("ARTIFACT_DATA_MISSING", numObtained)
		end
		RestoreStateAfterScan()
	end
end

function private.PLAYER_ENTERING_WORLD(event)
	frame:UnregisterEvent(event)
	_G.C_Timer.After(5, function()
		InitializeScan(event)
		frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	end)
end

function private.ARTIFACT_CLOSE()
	viewedID = nil
end

function private.ARTIFACT_UPDATE(event, newItem)
	Debug(event, newItem)
	if newItem then
		GetViewedArtifactData()
	else
		local newRelics = ScanRelics()
		local oldRelics = artifacts[viewedID] and artifacts[viewedID].relics or {}

		for i = 1, #newRelics do
			local newRelic = newRelics[i]
			-- TODO: test third slot unlock
			if newRelic.isLocked ~= oldRelics[i].isLocked or newRelic.itemID ~= oldRelics[i].itemID then
				oldRelics[i] = newRelic
				Debug("ARTIFACT_RELIC_CHANGED", viewedID, i, newRelic)
				lib.callbacks:Fire("ARTIFACT_RELIC_CHANGED", viewedID, i, CopyTable(newRelic))
				-- if a relic changed, so did the traits
				ScanTraits(viewedID)
				InformTraitsChanged(viewedID)
				break
			end
		end
	end
end

function private.ARTIFACT_XP_UPDATE(event)
	-- at the forge the player can purchase traits even for unequipped artifacts
	local GetInfo = IsAtForge() and GetArtifactInfo or GetEquippedArtifactInfo
	local itemID, _, _, _, unspentPower, numRanksPurchased = GetInfo()
	local numRanksPurchasable, power, maxPower = GetNumPurchasableTraits(numRanksPurchased, unspentPower)

	local artifact = artifacts[itemID]
	if not artifact then
		Debug("|cffff0000ERROR:|r", "artifact", itemID, "not found.")
		return
	end
	local diff = unspentPower - artifact.unspentPower

	if numRanksPurchased ~= artifact.numRanksPurchased then
		-- both learning traits and artifact respec trigger ARTIFACT_XP_UPDATE
		-- however respec has a positive diff and learning traits has a negative one
		ScanTraits(itemID)
		InformTraitsChanged(itemID)
	end

	if diff ~= 0 then
		artifact.unspentPower = unspentPower
		artifact.power = power
		artifact.maxPower = maxPower
		artifact.numRanksPurchased = numRanksPurchased
		artifact.numRanksPurchasable = numRanksPurchasable
		artifact.powerForNextRank = maxPower - power
		Debug(event, itemID, diff, unspentPower, power, maxPower, maxPower - power, numRanksPurchasable)
		lib.callbacks:Fire("ARTIFACT_POWER_CHANGED", itemID, diff, unspentPower, power, maxPower, maxPower - power, numRanksPurchasable)
	end
end

function private.BANKFRAME_OPENED()
	local numObtained = lib:GetNumObtainedArtifacts()
	if numObtained ~= GetNumObtainedArtifacts() then
		ScanBank(numObtained)
	end
end

function private.CURRENCY_DISPLAY_UPDATE(event)
	local _, lvl = GetCurrencyInfo(1171)
	if lvl ~= artifacts.knowledgeLevel then
		artifacts.knowledgeLevel = lvl
		Debug("ARTIFACT_DATA_MISSING", event, lvl)
		lib.callbacks:Fire("ARTIFACT_DATA_MISSING", "knowledge", lvl)
	end
end

function private.PLAYER_EQUIPMENT_CHANGED(event, slot)
	if slot == INVSLOT_MAINHAND then
		local itemID = GetEquippedArtifactInfo()

		if itemID and not artifacts[itemID] then
			InitializeScan(event)
		end

		InformEquippedArtifactChanged(itemID)
		InformActiveArtifactChanged(itemID)
	end
end

-- needed in case the game fails to switch artifacts
function private.PLAYER_SPECIALIZATION_CHANGED(event)
	local itemID = GetEquippedArtifactInfo()
	Debug(event, itemID)
	InformActiveArtifactChanged(itemID)
end

function lib.GetActiveArtifactID()
	return activeID
end

function lib.GetArtifactInfo(_, artifactID)
	artifactID = artifactID or equippedID
	return artifactID, CopyTable(artifacts[artifactID])
end

function lib.GetAllArtifactsInfo()
	return CopyTable(artifacts)
end

function lib.GetNumObtainedArtifacts()
	local numArtifacts = 0
	for artifact in pairs(artifacts) do
		if tonumber(artifact) then
			numArtifacts = numArtifacts + 1
		end
	end

	return numArtifacts
end

function lib.GetArtifactTraits(_, artifactID)
	artifactID = artifactID or equippedID
	for itemID, data in pairs(artifacts) do
		if itemID == artifactID then
			return artifactID, CopyTable(data.traits)
		end
	end
end

function lib.GetArtifactRelics(_, artifactID)
	artifactID = artifactID or equippedID
	for itemID, data in pairs(artifacts) do
		if itemID == artifactID then
			return artifactID, CopyTable(data.relics)
		end
	end
end

function lib.GetArtifactPower(_, artifactID)
	artifactID = artifactID or equippedID
	for itemID, data in pairs(artifacts) do
		if itemID == artifactID then
			return artifactID, data.unspentPower, data.power, data.maxPower, data.powerForNextRank, data.numRanksPurchased, data.numRanksPurchasable
		end
	end
end

function lib.GetArtifactKnowledge()
	return artifacts.knowledgeLevel, artifacts.knowledgeMultiplier
end

function lib.GetAcquiredArtifactPower(_, artifactID)
	local total = 0

	if artifactID then
		local data = artifacts[artifactID]
		total = total + data.unspentPower
		local rank = 1
		while rank <= data.numRanksPurchased do
			total = total + GetCostForPointAtRank(rank)
			rank = rank + 1
		end

		return total
	end

	for itemID, data in pairs(artifacts) do
		if tonumber(itemID) then
			total = total + data.unspentPower
			local rank = 1
			while rank <= data.numRanksPurchased do
				total = total + GetCostForPointAtRank(rank)
				rank = rank + 1
			end
		end
	end

	return total
end

function lib.ForceUpdate()
	InitializeScan("FORCE_UPDATE")
end
