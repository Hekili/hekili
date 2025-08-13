-- Targets.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[addon]

local class = Hekili.Class
local state = Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID
local FindUnitDebuffByID = ns.FindUnitDebuffByID
local FindExclusionAuraByID

local targetCount = 0
local targets = {}

local myTargetCount = 0
local myTargets = {}

local addMissingTargets = true
local counted = {}

local formatKey = ns.formatKey
local orderedPairs = ns.orderedPairs
local FeignEvent, RegisterEvent = ns.FeignEvent, ns.RegisterEvent
local TargetDummies = ns.TargetDummies

local format = string.format
local insert, remove, wipe = table.insert, table.remove, table.wipe

local unitIDs = { "target", "targettarget", "focus", "focustarget", "boss1", "boss2", "boss3", "boss4", "boss5", "arena1", "arena2", "arena3", "arena4", "arena5" }

local npGUIDs = {}
local npUnits = {}

Hekili.unitIDs = unitIDs
Hekili.npGUIDs = npGUIDs
Hekili.npUnits = npUnits


function Hekili:GetNameplateUnitForGUID( id )
    return npUnits[ id ]
end

function Hekili:GetGUIDForNameplateUnit( unit )
    return npGUIDs[ unit ]
end

function Hekili:GetUnitByGUID( id )
    for _, unit in ipairs( unitIDs ) do
        if UnitGUID( unit ) == id then return unit end
    end
end

function Hekili:GetUnitByName( name )
    for _, unit in ipairs( unitIDs ) do
        if UnitName( unit ) == name then return unit end
    end

    for unit in pairs( npUnits ) do
        if UnitName( unit ) == name then return unit end
    end
end


do
    -- Pet-Based Target Detection
    -- Requires a class-appropriate pet ability on the player's action bars.
    -- ** Not the pet's action bar. **
    local petAction = 0
    local petSlot = 0

    local myClass = UnitClassBase( "player" )

    local petSpells = {
        HUNTER = {
            [288962] = 10,
            [17253]  = 5,
            [16827]  = 5,
            [159953] = 5,
            [49966]  = 5,
            [263863] = 7,
            [50433]  = 7,
            [24423]  = 7,
            [160060] = 7,
            [50285]  = 7,
            [263840] = 7,
            [263856] = 7,
            [263861] = 7,
            [279362] = 7,
            [160018] = 7,
            [263853] = 7,
            [263423] = 7,
            [54680]  = 7,
            [344352] = 7,
            [50245]  = 7,
            [263857] = 7,
            [263854] = 7,
            [263852] = 7,
            [160065] = 7,
            [263858] = 7,
            [341118] = 7,
            [35346]  = 7,
            [160067] = 7,

            best     = 288962,
            count    = 28
        },

        WARLOCK = {
            [6360]   = 10,
            [7814]   = 7,
            [30213]  = 7,
            [115625] = 7,
            [54049]  = 7,
            [115778] = 7,

            best     = 6360,
            count    = 6
        }
    }

    function Hekili:GetPetBasedTargetSpells()
        return petSpells[ myClass ]
    end

    function Hekili:CanUsePetBasedTargetDetection()
        return petSpells[ myClass ] ~= nil
    end

    function Hekili:HasPetBasedTargetSpell()
        return petSlot > 0
    end

    function Hekili:GetPetBasedTargetSpell()
        return petAction > 0 and petAction or nil
    end

    function Hekili:PetBasedTargetDetectionIsReady( skipRange )
        if petSlot == 0 then return false, "Pet action not found in player action bars." end
        if not UnitExists( "pet" ) then return false, "No active pet." end
        if UnitIsDead( "pet" ) then return false, "Pet is dead." end

        -- If we have a target and the target is out of our pet's range, don't use pet detection.
        if not skipRange and UnitExists( "target" ) and not IsActionInRange( petSlot ) then return false, "Player has target and player's target not in range of pet." end
        return true
    end

    function Hekili:SetupPetBasedTargetDetection()
        petAction = 0
        petSlot = 0

        if not self:CanUsePetBasedTargetDetection() then return end

        local spells = petSpells[ myClass ]
        local success = false

        for i = 1, 180 do
            local slotType, spell = GetActionInfo( i )

            if slotType and spell and spells[ spell ] then
                petAction = spell
                petSlot = i
                return true
            end
        end

        return success
    end

    function Hekili:TargetIsNearPet( unit )
        return IsActionInRange( petSlot, unit )
    end

    function Hekili:DumpPetBasedTargetInfo()
        self:Print( petAction, petSlot )
    end
end


-- Excluding enemy by NPC ID (as string).  This keeps the enemy from being counted if they are not your target.
-- = true           Always Exclude
-- = number         If table, [1] = de/buff Id per below, [2] = boolean (true = exclude if not present)
-- = number < 0     Exclude if debuff ID abs( number ) is active on unit.
-- = number > 0     Exclude if buff ID number is active on unit.
local enemyExclusions = {
    [23775]  = true,              -- Head of the Horseman
    [120651] = true,              -- Explosives
    [128652] = true,              -- Viq'Goth (Siege of Boralus - untargetable background boss)
    [156227] = true,              -- Neferset Denizen
    [160966] = true,              -- Thing from Beyond?
    [161895] = true,              -- Thing from Beyond?
    [157452] = true,              -- Nightmare Antigen in Carapace
    [158041] = 310126,            -- N'Zoth with Psychic Shell
    [164698] = true,              -- Tor'ghast Junk
    [177117] = 355790,            -- Ner'zhul: Orb of Torment (Protected by Eternal Torment)
    [176581] = true,              -- Painsmith:  Spiked Ball
    [186150] = true,              -- Soul Fragment (Gavel of the First Arbiter)
    [185685] = true,              -- Season 3 Relics
    [185680] = true,              -- Season 3 Relics
    [185683] = true,              -- Season 3 Relics
    [183501] = 367573,            -- Xy'mox: Genesis Bulwark
    [166969] = true,              -- Frieda
    [166970] = true,              -- Stavros
    [166971] = true,              -- Niklaus
    [168113] = 329606,            -- Grashaal (when shielded)
    [168112] = 329636,            -- Kaal (when shielded)
    [193760] = true,              -- Surging Ruiner (Raszageth) -- gives bad range information.
    [204560] = true,              -- Incorporeal Being
    [229296] = true,              -- Orb of Ascendance (TWW S1 Affix)
    [218884] = true,              -- Silken Court: Scattershell Scarab
    [235187] = true,              -- Cauldron: Voltaic Image
    [231788] = true,              -- Mug'Zee: Unstable Crawler Mine
    [233474] = true,              -- Mug'Zee: Gallagio Goon (they are within a cage with LoS restrictions)
    [231727] = true,              -- Gallywix: 1500-Pound "Dud"
    [237967] = true,              -- Gallywix: Discharged Giga Bomb
    [237968] = true,              -- Gallywix: Charged Giga Bomb
    [151579] = true,              -- Operation: Mechagon - Shield Generator
    [219588] = true               -- Cinderbrew Meadery - Yes Man (etc.)
}

local requiredForInclusion = {
    [131825] = 260805,    -- Focusing Iris (damage on others is wasted)
    [131823] = 260805,    -- Same
    [131824] = 206805,    -- Same
    [230312] = 467454     -- Mug'Zee: Volunteer Rocketeer, only attackable with "Charred"
}

if Hekili.IsDev then
    -- Add these exclusions only in development copies, until a solution is built for funnelers vs. non-funnelers.
    enemyExclusions[202971] = 404705 -- Null Glimmer
    enemyExclusions[202969] = 404705 -- Empty Recollection
end

RegisterEvent( "NAME_PLATE_UNIT_ADDED", function( event, unit )
    local id = UnitGUID( unit )

    if UnitIsFriend( "player", unit ) then
        npGUIDs[ unit ] = nil
        npUnits[ id ] = nil
        return
    end

    npGUIDs[ unit ] = id
    npUnits[ id ]   = unit
end )

RegisterEvent( "NAME_PLATE_UNIT_REMOVED", function( event, unit )
    local storedGUID = npGUIDs[ unit ]
    local id = UnitGUID( unit )

    npGUIDs[ unit ] = nil

    if npUnits[ id ] and npUnits[ id ] == unit then npUnits[ id ] = nil end
    if npUnits[ storedGUID ] and npUnits[ storedGUID ] == unit then npUnits[ storedGUID ] = nil end
end )

RegisterEvent( "UNIT_FLAGS", function( event, unit )
    if unit == "player" or UnitIsUnit( unit, "player" ) then return end

    if UnitIsFriend( "player", unit ) then
        local id = UnitGUID( unit )
        ns.eliminateUnit( id )

        npGUIDs[ unit ] = nil
        npUnits[ id ]   = nil
    end
end )


local RC = LibStub( "LibRangeCheck-3.0" )
local LSR = LibStub( "SpellRange-1.0" )

local lastCount = 1
local lastStationary = 1


-- Chromie Time impacts phasing as well.
local chromieTime = false

do
    local IsPlayerInChromieTime = C_PlayerInfo.IsPlayerInChromieTime

    local function UpdateChromieTime()
        chromieTime = IsPlayerInChromieTime()
    end

    local function ChromieCheck( self, event, login, reload )
        if event ~= "PLAYER_ENTERING_WORLD" or login or reload then
            chromieTime = IsPlayerInChromieTime()
            C_Timer.After( 2, UpdateChromieTime )
        end
    end

    if not Hekili.IsDragonflight() then
        RegisterEvent( "CHROMIE_TIME_OPEN", ChromieCheck )
        RegisterEvent( "CHROMIE_TIME_CLOSE", ChromieCheck )
    end

    RegisterEvent( "PLAYER_ENTERING_WORLD", ChromieCheck )
end


-- War Mode
local warmode = false

do
    local function CheckWarMode( event, login, reload )
        if event ~= "PLAYER_ENTERING_WORLD" or login or reload then
            warmode = C_PvP.IsWarModeDesired()
        end
    end

    RegisterEvent( "UI_INFO_MESSAGE", CheckWarMode )
    RegisterEvent( "PLAYER_ENTERING_WORLD", CheckWarMode )
end


local function UnitInPhase( unit )
    local reason = UnitPhaseReason( unit )
    local wm = not IsInInstance() and warmode

    if reason == 3 and chromieTime then return true end
    if reason == 2 and wm then return true end
    if reason == nil then return true end

    return false
end


--[[

For targeting, let's keep more of the settings static to reduce overhead with target counting.

We have:
1. Count Nameplates
   - Spell
   - Filter UnitAffectingCombat
   -

]]--


do
    function ns.iterateTargets()
        return next, counted, nil
    end

    FindExclusionAuraByID = function( unit, spellID, invert )
        local result
        if spellID < 0 then
            result = FindUnitDebuffByID( unit, -1 * spellID ) ~= nil
        else
            result = FindUnitBuffByID( unit, spellID ) ~= nil
        end
        return invert and ( not result ) or result
    end

    -- New Nameplate Proximity System
    function ns.getNumberTargets( forceUpdate )
        if not forceUpdate then
            return lastCount, lastStationary
        end

        local debugging = true
        local details = nil
        local showNPs = GetCVar( "nameplateShowEnemies" ) == "1" and GetCVar( "nameplateShowAll" ) == "1"

        wipe( counted )

        local count, stationary = 0, 0
        if debugging then details = format( "Nameplates are %s.", showNPs and "enabled" or "disabled" ) end

        local spec = state.spec.id
        spec = spec and rawget( Hekili.DB.profile.specs, spec )

        local inRaid = IsInRaid()
        local inGroup = GetNumGroupMembers() > 0

        local FriendCheck = inRaid and UnitInRaid or UnitInParty

        local checkPets = showNPs and spec and spec.petbased and Hekili:PetBasedTargetDetectionIsReady()
        -- local filterPlates = showNPs and spec and spec.rangeFilter and class.specs[ state.spec.id ].rangeFilter

        local checkPlates = showNPs and spec and spec.nameplates and ( spec.nameplateRange or class.specs[ state.spec.id ].nameplateRange or 10 )

        --[[ if rangeCheck == "Auto" then
            rangeChecker = spec.ranges.Auto[2]
            rangeCheck = true
        else
            rangeChecker = spec.ranges[ rangeCheck ][ 1 ]
        end ]]

        if spec then
            if checkPets or checkPlates then
                for unit, guid in pairs( npGUIDs ) do
                    local npcid = tonumber( guid:match( "(%d+)-%x-$" ) or 0 )

                    if UnitExists( unit ) and not UnitIsDead( unit ) and UnitCanAttack( "player", unit ) and UnitInPhase( unit ) and ( UnitHealth( unit ) > 1 or TargetDummies[ npcid ] ) and ( not inGroup or not FriendCheck( unit ) ) and ( UnitIsPVP( "player" ) or not UnitIsPlayer( unit ) ) then
                        local excluded = not UnitIsUnit( unit, "target" )
                        local _, range = nil, -1

                        if debugging then details = format( "%s\n - Checking nameplate list for %s [ %s ] %s.", details, unit, guid, UnitName( unit ) ) end

                        if excluded then
                            if requiredForInclusion[ npcid ] then
                                excluded = not FindExclusionAuraByID( unit, requiredForInclusion[ npcid ] )
                            else
                                excluded = enemyExclusions[ npcid ]
                            end

                            -- If our table has a number, unit is ruled out based on aura.
                            local invert = false

                            if type( excluded ) == "table" then
                                invert = excluded[ 2 ]
                                excluded = excluded[ 1 ]
                            end

                            if excluded and type( excluded ) == "number" then
                                excluded = FindExclusionAuraByID( unit, excluded, invert )

                                if debugging and excluded then
                                    details = format( "%s\n    - Excluded by %s aura.", details, ( invert and "missing" or "present" ) )
                                end
                            end

                            if not excluded and checkPets then
                                excluded = not Hekili:TargetIsNearPet( unit )

                                if debugging and excluded then
                                    details = format( "%s\n    - Excluded by pet range.", details )
                                end
                            end
                            -- FIXME It looks like some kind of resolution/backup plan is needed for range checking (note to self: see Targets.lua line 436)
                            -- https://github.com/Hekili/hekili/issues/4845
                            if not excluded and checkPlates then
                                local _, maxR = RC:GetRange( unit )
                                excluded = maxR ~= nil and maxR > checkPlates

                                if debugging and excluded then
                                    details = format( "%s\n    - Excluded by range (%d > %d).", details, maxR, checkPlates )
                                end
                            end

                            if not excluded and showNPs and spec.damageOnScreen and not npUnits[ guid ] then
                                excluded = true
                                if debugging then details = format( "%s\n    - Excluded by on-screen nameplate requirement.", details ) end
                            end
                        end

                        if not excluded then
                            local rate, n = Hekili:GetTTD( unit )
                            count = count + 1
                            counted[ guid ] = true

                            local moving = GetUnitSpeed( unit ) > 0

                            if not moving then
                                stationary = stationary + 1
                            end

                            if debugging then details = format( "%s\n    %-12s - %2d - %s - %.2f - %d - %s %s\n", details, unit, range or -1, guid, rate or -1, n or -1, unit and UnitName( unit ) or "Unknown", ( moving and "(moving)" or "" ) ) end
                        end
                    end

                    counted[ guid ] = counted[ guid ] or false
                end

                for _, unit in ipairs( unitIDs ) do
                    local guid = UnitGUID( unit )

                    if guid and counted[ guid ] == nil then
                        local npcid = tonumber( guid:match( "(%d+)-%x-$" ) or 0 )

                        if UnitExists( unit ) and not UnitIsDead( unit ) and UnitCanAttack( "player", unit ) and UnitAffectingCombat( unit ) and UnitInPhase( unit ) and ( UnitHealth( unit ) > 1 or TargetDummies[ npcid ] ) and ( not inGroup or not FriendCheck( unit ) ) and ( UnitIsPVP( "player" ) or not UnitIsPlayer( unit ) ) then
                            local excluded = not UnitIsUnit( unit, "target" )

                            local _, range = nil, -1

                            if debugging then details = format( "%s\n - Checking %s [ %s ] %s.", details, unit, guid, UnitName( unit ) ) end

                            if excluded then
                                excluded = enemyExclusions[ npcid ]

                                -- If our table has a number, unit is ruled out only if the buff is present.
                                if excluded and type( excluded ) == "number" then
                                    excluded = FindExclusionAuraByID( unit, excluded )

                                    if debugging and excluded then
                                        details = format( "%s\n    - Excluded by aura.", details )
                                    end
                                end

                                if not excluded and checkPets then
                                    excluded = not Hekili:TargetIsNearPet( unit )

                                    if debugging and excluded then
                                        details = format( "%s\n    - Excluded by pet range.", details )
                                    end
                                end

                                if not excluded and checkPlates then
                                    local _, maxR = RC:GetRange( unit )
                                    excluded = maxR ~= nil and maxR > checkPlates

                                    if debugging and excluded then
                                        details = format( "%s\n    - Excluded by range (%d > %d).", details, maxR, checkPlates )
                                    end
                                end

                                if not excluded and spec.damageOnScreen and showNPs and not npUnits[ guid ] then
                                    excluded = true
                                    if debugging then details = format( "%s\n    - Excluded by on-screen nameplate requirement.", details ) end
                                end
                            end

                            if not excluded then
                                local rate, n = Hekili:GetTTD(unit)
                                count = count + 1
                                counted[ guid ] = true

                                local moving = GetUnitSpeed( unit ) > 0

                                if not moving then
                                    stationary = stationary + 1
                                end

                                if debugging then details = format( "%s\n    %-12s - %2d - %s - %.2f - %d - %s %s\n", details, unit, range or -1, guid, rate or -1, n or -1, unit and UnitName( unit ) or "Unknown", ( moving and "(moving)" or "" ) ) end
                            end

                            counted[ guid ] = counted[ guid ] or false
                        end
                    end
                end
            end
        end

        if not spec or spec.damage or not checkPets and not checkPlates then
            local db = spec and ( spec.myTargetsOnly and myTargets or targets ) or targets

            for guid, seen in pairs( db ) do
                if counted[ guid ] == nil then
                    local npcid = guid:match( "(%d+)-%x-$" ) or 0
                    npcid = tonumber( npcid )

                    local unit = Hekili:GetUnitByGUID( guid ) or UnitTokenFromGUID( guid )
                    local excluded = false

                    if unit and not UnitIsUnit( unit, "target" ) then
                        excluded = enemyExclusions[ npcid ]

                        if debugging then details = format( "%s\n - Checking %s [ %s ] #%s.", details, unit, guid, UnitName( unit ) ) end

                        -- If our table has a number, unit is ruled out only if the buff is present.
                        if excluded and type( excluded ) == "number" then
                            excluded = FindExclusionAuraByID( unit, excluded )

                            if debugging and excluded then
                                details = format( "%s\n    - Excluded by aura.", details )
                            end
                        end

                        if not excluded and inGroup and FriendCheck( unit ) then
                            excluded = true
                            if debugging then details = format( "%s\n    - Excluded by friend check.", details ) end
                        end

                        if not excluded and checkPets then
                            excluded = not Hekili:TargetIsNearPet( unit )

                            if debugging and excluded then
                                details = format( "%s\n    - Excluded by pet range.", details )
                            end
                        end
                    end

                    if not excluded and spec.damageOnScreen and showNPs and not npUnits[ guid ] then
                        excluded = true
                        if debugging then details = format( "%s\n    - Excluded by on-screen nameplate requirement.", details ) end
                    end

                    if not excluded then
                        count = count + 1
                        counted[ guid ] = true

                        local moving = unit and GetUnitSpeed( unit ) > 0

                        if not moving then
                            stationary = stationary + 1
                        end

                        if debugging then details = format("%s\n    %-12s - %s %s\n", details, "dmg", guid, ( moving and "(moving)" or "" ) ) end
                    else
                        counted[ guid ] = false
                    end
                end
            end
        end

        local targetGUID = UnitGUID( "target" )
        if targetGUID then
            if counted[ targetGUID ] == nil and UnitExists( "target" ) and not UnitIsDead( "target" ) and UnitCanAttack( "player", "target" ) and UnitInPhase( "target" ) and ( UnitIsPVP( "player" ) or not UnitIsPlayer( "target" ) ) then
                count = count + 1
                counted[ targetGUID ] = true

                local moving = GetUnitSpeed( "target" ) > 0

                if not moving then
                    stationary = stationary + 1
                end

                if debugging then details = format("%s\n    %-12s - %2d - %s %s\n", details, "target", 0, targetGUID, ( moving and "(moving)" or "" ) ) end
            else
                counted[ targetGUID ] = false
            end
        end

        count = max( 1, count )

        if count ~= lastCount or stationary ~= lastStationary then
            lastCount = count
            lastStationary = stationary
            if Hekili:GetToggleState( "mode" ) == "reactive" then HekiliDisplayAOE:UpdateAlpha() end
        end

        if details then
            Hekili.TargetDebug = details
        end

        return count, stationary
    end
end

function Hekili:GetNumTargets( forceUpdate )
    return ns.getNumberTargets( forceUpdate )
end


function ns.dumpNameplateInfo()
    return counted
end


function ns.updateTarget( id, time, mine, spellID )
    local spec = rawget( Hekili.DB.profile.specs, state.spec.id )
    if not spec or not spec.damage then return end

    id, time, mine, spellID = ns.callHook( "filter_target", id, time, mine, spellID )

    if id == nil or id == state.GUID then
        return
    end

    if time then
        if not targets[id] then
            targetCount = targetCount + 1
            targets[id] = time
            ns.updatedTargetCount = true
        else
            targets[id] = time
        end

        if mine then
            if not myTargets[id] then
                myTargetCount = myTargetCount + 1
                myTargets[id] = time
                ns.updatedTargetCount = true
            else
                myTargets[id] = time
            end
        end
    else
        if state.empowerment.start > 0 and state.empowerment.hold > GetTime() then
            -- Don't expire targets mid-empowerment cast.
            return
        end

        if targets[id] then
            targetCount = max( 0, targetCount - 1 )
            targets[id] = nil
        end

        if myTargets[id] then
            myTargetCount = max( 0, myTargetCount - 1 )
            myTargets[id] = nil
        end

        ns.updatedTargetCount = true
    end
end

ns.reportTargets = function()
    for k, v in pairs(targets) do
        Hekili:Print("Saw " .. k .. " exactly " .. GetTime() - v .. " seconds ago.")
    end
end

ns.numTargets = function()
    return targetCount > 0 and targetCount or 1
end
ns.numMyTargets = function()
    return myTargetCount > 0 and myTargetCount or 1
end
ns.isTarget = function(id)
    return targets[id] ~= nil
end
ns.isMyTarget = function(id)
    return myTargets[id] ~= nil
end

-- MINIONS
local minions = {}

ns.updateMinion = function(id, time)
    minions[id] = time
end

ns.isMinion = function(id)
    return minions[id] ~= nil or UnitGUID("pet") == id
end

function Hekili:HasMinionID(id)
    for k, v in pairs(minions) do
        local npcID = tonumber(k:match("%-(%d+)%-[0-9A-F]+$"))

        if npcID == id and v > state.now then
            return true, v
        end
    end
end

function Hekili:DumpMinions()
    local o = ""

    for k, v in orderedPairs(minions) do
        o = o .. k .. " " .. tostring(v) .. "\n"
    end

    return o
end

local debuffs = {}
local debuffCount = {}
local debuffMods = {}

function ns.saveDebuffModifier( id, val )
    debuffMods[ id ] = val
end

ns.wipeDebuffs = function()
    for k, _ in pairs(debuffs) do
        table.wipe(debuffs[k])
        debuffCount[k] = 0
    end
end

ns.actorHasDebuff = function( target, spell )
    return ( debuffs[ spell ] and debuffs[ spell ][ target ] ~= nil ) or false
end

ns.trackDebuff = function( spell, target, time, application, snapshotHaste )
    debuffs[spell] = debuffs[spell] or {}
    debuffCount[spell] = debuffCount[spell] or 0

    if not time then
        if debuffs[spell][target] then
            -- Remove it.
            debuffs[spell][target] = nil
            debuffCount[spell] = max( 0, debuffCount[spell] - 1 )
        end
    else
        if not debuffs[spell][target] then
            debuffs[spell][target] = {}
            debuffCount[spell] = debuffCount[spell] + 1
        end

        local debuff = debuffs[spell][target]

        debuff.last_seen = time
        debuff.applied = debuff.applied or time

        local model = class.auras[ spell ]

        if model and snapshotHaste then
            debuff.haste = 100 / ( 100 + GetHaste() )
            debuff.next_tick = time + ( model.base_tick_time or model.tick_time ) * debuff.haste
        else
            debuff.haste = -1
            debuff.next_tick = time + ( model.base_tick_time or model.tick_time or 3 )
        end

        if application then
            debuff.pmod = debuffMods[spell]
        else
            debuff.pmod = debuff.pmod or 1
        end
    end
end

ns.GetDebuffLastTick = function( spell, target )
    local aura = debuffs[ spell ] and debuffs[ spell ][ target ]
    if not aura then return 0 end
    return aura.last_seen or 0
end

ns.GetDebuffNextTick = function( spell, target )
    local aura = debuffs[ spell ] and debuffs[ spell ][ target ]
    if not aura then return 0 end
    if ( aura.last_seen or 0 ) == 0 then return 0 end

    local model = class.auras[ spell ]
    return aura.next_tick or ( aura.last_seen + ( model.tick_time or 3 ) )
end

ns.GetDebuffHaste = function( spell, target )
    local aura = debuffs[ spell ] and debuffs[ spell ][ target ]
    if not aura then return 1 end
    return aura.haste or state.haste or 1
end

ns.GetDebuffApplicationTime = function( spell, target )
    if not debuffCount[ spell ] or debuffCount[ spell ] == 0 then return 0 end
    return debuffs[ spell ] and debuffs[ spell ][ target ] and ( debuffs[ spell ][ target ].applied or debuffs[ spell ][ target ].last_seen ) or 0
end


function ns.getModifier( id, target )
    local debuff = debuffs[ id ]
    if not debuff then
        return 1
    end

    local app = debuff[target]
    if not app then
        return 1
    end

    return app.pmod or 1
end

ns.numDebuffs = function(spell)
    return debuffCount[spell] or 0
end

ns.compositeDebuffCount = function( ... )
    local n = 0

    for i = 1, select("#", ...) do
        local debuff = select( i, ... )
        debuff = class.auras[ debuff ] and class.auras[ debuff ].id
        debuff = debuff and debuffs[ debuff ]

        if debuff then
            for unit in pairs(debuff) do
                n = n + 1
            end
        end
    end

    return n
end

ns.conditionalDebuffCount = function(req1, req2, req3, ...)
    local n = 0

    req1 = class.auras[req1] and class.auras[req1].id
    req2 = class.auras[req2] and class.auras[req2].id
    req3 = class.auras[req3] and class.auras[req3].id

    for i = 1, select("#", ...) do
        local debuff = select(i, ...)
        debuff = class.auras[debuff] and class.auras[debuff].id
        debuff = debuff and debuffs[debuff]

        if debuff then
            for unit in pairs(debuff) do
                if (req1 and debuffs[req1] and debuffs[req1][unit]) or (req2 and debuffs[req2] and debuffs[req2][unit]) or (req3 and debuffs[req3] and debuffs[req3][unit]) then
                    n = n + 1
                end
            end
        end
    end

    return n
end

do
    local counted = {}

    -- Useful for "count number of enemies with at least one of these debuffs applied".
    -- i.e., poisoned_enemies for Assassination Rogue.

    ns.countUnitsWithDebuffs = function( ... )
        wipe( counted )

        local n = 0

        for i = 1, select("#", ...) do
            local debuff = select( i, ... )
            debuff = class.auras[ debuff ] and class.auras[ debuff ].id
            debuff = debuff and debuffs[ debuff ]

            if debuff then
                for unit in pairs( debuff ) do
                    if not counted[ unit ] then
                        n = n + 1
                        counted[ unit ] = true
                    end
                end
            end
        end

        return n
    end
end

ns.isWatchedDebuff = function(spell)
    return debuffs[spell] ~= nil
end

ns.eliminateUnit = function( id, force )
    ns.updateMinion(id)
    ns.updateTarget(id)

    if force then
        for k, v in pairs( debuffs ) do
            if v[ id ] then
                ns.trackDebuff( k, id )
            end
        end
    end

    ns.callHook( "UNIT_ELIMINATED", id )
end


do
    local damage = {
        [1] = 0,
        [5] = 0,
        [10] = 0,
    }

    local physical = {
        [1] = 0,
        [5] = 0,
        [10] = 0
    }

    local magical = {
        [1] = 0,
        [5] = 0,
        [10] = 0
    }

    local healing = {
        [1] = 0,
        [5] = 0,
        [10] = 0
    }

    ns.storeDamage = function( _, dam, isPhysical )
        if dam and dam > 0 then
            local db = isPhysical and physical or magical

            db[ 1 ] = db[ 1 ] + dam
            damage[ 1 ] = damage[ 1 ] + dam

            C_Timer.After( 1, function()
                db[ 1 ] = db[ 1 ] - dam
                damage[ 1 ] = damage[ 1 ] - dam
            end )

            db[ 5 ] = db[ 5 ] + dam
            damage[ 5 ] = damage[ 5 ] + dam

            C_Timer.After( 5, function()
                db[ 5 ] = db[ 5 ] - dam
                damage[ 5 ] = damage[ 5 ] - dam
            end )

            db[ 10 ] = db[ 10 ] + dam
            damage[ 10 ] = damage[ 10 ] + dam

            C_Timer.After( 10, function()
                db[ 10 ] = db[ 10 ] - dam
                damage[ 10 ] = damage[ 10 ] - dam
            end )
        end
    end

    ns.damageInLast = function( seconds, isPhysical )
        local db
        if isPhysical == nil then db = damage
        elseif isPhysical == true then db = physical
        else db = magical end

        if db[ seconds ] then return db[ seconds ] end

        if seconds < 1 then
            return db[ 1 ] * ( seconds / 1 )
        end

        if seconds < 5 then
            return db[ 1 ] + ( db[ 5 ] - db[ 1 ] ) * ( seconds - 1 ) / 5
        end

        if seconds < 10 then
            return db[ 5 ] + ( db[ 10 ] - db[ 5 ] ) * ( seconds - 5 ) / 10
        end

        return db[ 10 ] * seconds / 10
    end

    ns.storeHealing = function( _, amount )
        if amount and amount > 0 then
            healing[ 1 ] = healing[ 1 ] + amount
            C_Timer.After( 1, function() healing[ 1 ] = healing[ 1 ] - amount end )

            healing[ 5 ] = healing[ 5 ] + amount
            C_Timer.After( 5, function() healing[ 5 ] = healing[ 5 ] - amount end )

            healing[ 10 ] = healing[ 10 ] + amount
            C_Timer.After( 10, function() healing[ 10 ] = healing[ 10 ] - amount end )
        end
    end

    ns.healingInLast = function( seconds )
        if healing[ seconds ] then return healing[ seconds ] end

        if seconds < 1 then
            return healing[ 1 ] * ( seconds / 1 )
        end

        if seconds < 5 then
            return healing[ 1 ] + ( healing[ 5 ] - healing[ 1 ] ) * ( seconds - 1 ) / 5
        end

        if seconds < 10 then
            return healing[ 5 ] + ( healing[ 10 ] - healing[ 5 ] ) * ( seconds - 5 ) / 10
        end

        return healing[ 10 ] * seconds / 10
    end

    ns.sanitizeDamageAndHealing = function()
        physical[ 1 ] = max( 0, physical[ 1 ] )
        physical[ 5 ] = max( 0, physical[ 5 ] )
        physical[ 10 ] = max( 0, physical[ 10 ] )

        magical[ 1 ] = max( 0, magical[ 1 ] )
        magical[ 5 ] = max( 0, magical[ 5 ] )
        magical[ 10 ] = max( 0, magical[ 10 ] )

        healing[ 1 ] = max( 0, healing[ 1 ] )
        healing[ 5 ] = max( 0, healing[ 5 ] )
        healing[ 10 ] = max( 0, healing[ 10 ] )
    end
end


-- Auditor should clean things up for us.
do
    ns.Audit = function( special )
        -- Don't audit while recommendations are being generated.
        if HekiliEngine:IsThreadActive() then
            return
        end

        if special == "combatExit" and InCombatLockdown() then
            special = nil
        end

        if not special and not Hekili.DB.profile.enabled or not Hekili:IsValidSpec() then
            return
        end

        Hekili:ExpireTTDs()

        local now = GetTime()
        local spec = state.spec.id and rawget( Hekili.DB.profile.specs, state.spec.id )
        local grace = spec and spec.damageExpiration or 6

        for whom, when in pairs( targets ) do
            if now - when > grace then
                ns.eliminateUnit( whom )
            end
        end

        for aura, targets in pairs( debuffs ) do
            local a = class.auras[ aura ]
            local window = a and a.duration or grace
            local friendly = a and ( a.friendly or a.dot == "buff" ) or false

            for unit, entry in pairs( targets ) do
                if now - entry.last_seen > window then
                    ns.trackDebuff( aura, unit )
                elseif special == "combatExit" and not friendly then
                    -- Hekili:Error( format( "Auditor removed an aura %d from %s after exiting combat.", aura, unit ) )
                    ns.trackDebuff( aura, unit )
                end
            end
        end

        ns.sanitizeDamageAndHealing()
    end

    Hekili.AuditTimer = C_Timer.NewTicker( 1, ns.Audit )
end
Hekili:ProfileCPU( "Audit", ns.Audit )


local IsAddOnLoaded, LoadAddOn = C_AddOns.IsAddOnLoaded, C_AddOns.LoadAddOn

function Hekili:DumpDotInfo( aura )
    if not IsAddOnLoaded( "Blizzard_DebugTools" ) then
        LoadAddOn( "Blizzard_DebugTools" )
    end

    aura = aura and class.auras[ aura ] and class.auras[ aura ].id or aura

    Hekili:Print( "Current DoT Information at " .. GetTime() .. ( aura and ( " for " .. aura ) or "" ) .. ":" )
    DevTools_Dump( aura and debuffs[ aura ] or debuffs )
end

do
    -- New TTD, hopefully more aggressive and accurate than old TTD.
    Hekili.TTD = Hekili.TTD or {}
    local db = Hekili.TTD

    local recycle = {}

    local function EliminateEnemy(guid)
        local enemy = db[guid]
        if not enemy then
            return
        end

        db[guid] = nil
        wipe(enemy)
        insert( recycle, enemy )

        --[[ for k, v in pairs( debuffs ) do
            if v[ guid ] then ns.trackDebuff( k, guid ) end
        end ]]
    end


    -- These enemies die (or encounter ends) at a health percentage greater than 0.
    -- In theory, one could also mark certain targets as dying at 1.0 and they'd be considered dead, but I don't know why I'd do that.
    local deathPercent = {
        [162099] = 0.5, -- General Kaal; Sanguine Depths
        [166608] = 0.1, -- Mueh'zala; De Other Side
        [164929] = 0.2, -- Tirnenn Villager; Mists of Tirna Scythe
        [164804] = 0.2, -- Droman Oulfarran; Mists of Tirna Scythe
    }

    local DEFAULT_TTD = 30
    local FOREVER = 300
    local TRIVIAL = 5

    local function UpdateEnemy(guid, healthPct, unit, time)
        local enemy = db[ guid ]
        time = time or GetTime()

        if not enemy then
            -- This is the first time we've seen the enemy.
            enemy = remove(recycle, 1) or {}
            db[guid] = enemy

            enemy.firstSeen = time
            enemy.firstHealth = healthPct
            enemy.lastSeen = time
            enemy.lastHealth = healthPct

            enemy.unit = unit

            enemy.rate = 0
            enemy.n = 0

            local npcid = guid:match( "(%d+)-%x-$" )
            npcid = tonumber( npcid )

            enemy.npcid = npcid
            enemy.deathPercent = npcid and deathPercent[ npcid ] or 0
            enemy.deathTime = ( UnitIsTrivial(unit) and UnitLevel(unit) > -1 ) and TRIVIAL or DEFAULT_TTD
            enemy.excluded = enemyExclusions[ npcid ]
            return
        end

        local difference = enemy.lastHealth - healthPct

        -- We don't recalculate the rate when enemies heal.
        if difference > 0 then
            local elapsed = time - enemy.lastSeen

            -- If this is our first health difference, just store it.
            if enemy.n == 0 then
                enemy.rate = difference / elapsed
                enemy.n = 1
            else
                local samples = min(enemy.n, 9)
                local newRate = enemy.rate * samples + (difference / elapsed)
                enemy.n = samples + 1
                enemy.rate = newRate / enemy.n
            end

            enemy.deathTime = ( healthPct - enemy.deathPercent ) / enemy.rate
        end

        enemy.unit = unit
        enemy.lastHealth = healthPct
        enemy.lastSeen = time
    end

    local function CheckEnemyExclusion( guid )
        local enemy = db[ guid ]

        if not enemy or enemy.excluded == nil then return end

        -- Player target is always counted.
        if UnitIsUnit( enemy.unit, "target" ) then
            return false
        end

        if type( enemy.excluded ) == "boolean" then
            return enemy.excluded
        end

        if type( enemy.excluded ) == "number" then
            return FindExclusionAuraByID( enemy.unit, enemy.excluded )
        end

        return false
    end

    function Hekili:GetDeathClockByGUID( guid )
        if state.target.is_dummy then return 180 end

        local time, validUnit = 0, false
        local enemy = db[ guid ]

        if enemy then
            time = max( time, enemy.deathTime )
            validUnit = true
        end

        if not validUnit then return FOREVER end

        return time
    end

    function Hekili:GetTTD( unit, isGUID )
        if state.target.is_dummy then return 180 end

        local default = ( isGUID or UnitIsTrivial(unit) and UnitLevel(unit) > -1 ) and TRIVIAL or FOREVER
        local guid = isGUID and unit or UnitExists(unit) and UnitCanAttack("player", unit) and UnitGUID(unit)

        if not guid then
            return default
        end

        local enemy = db [guid ]
        if not enemy then
            return default
        end

        -- Don't have enough data to predict yet.
        if enemy.n < 3 or enemy.rate == 0 then
            return default, enemy.n
        end

        local health, healthMax = UnitHealth(unit), UnitHealthMax(unit)
        health = health + UnitGetTotalAbsorbs(unit)
        local healthPct = health / healthMax

        if healthPct == 0 then
            return 1, enemy.n
        end

        return ceil(healthPct / enemy.rate), enemy.n
    end

    function Hekili:GetTimeToPct( unit, percent )
        local default = 0.7 * ( UnitIsTrivial( unit ) and TRIVIAL or FOREVER )
        local guid = UnitExists( unit ) and UnitCanAttack( "player", unit ) and UnitGUID( unit )

        if percent >= 1 then
            percent = percent / 100
        end

        if not guid then return default end

        local enemy = db[ guid ]
        if not enemy then return default end

        local health, healthMax = UnitHealth( unit ), UnitHealthMax( unit )
        local healthPct = health / healthMax

        if healthPct <= percent then return 0, enemy.n end

        health = health + UnitGetTotalAbsorbs( unit )
        healthPct = health / healthMax

        if enemy.n < 3 or enemy.rate == 0 then
            return default, enemy.n
        end

        return ceil( ( healthPct - percent ) / enemy.rate ), enemy.n
    end

    function Hekili:GetTimeToPctByGUID( guid, percent )
        if percent >= 1 then
            percent = percent / 100
        end

        local default = percent * FOREVER

        if not guid then return default end

        local enemy = db[ guid ]
        if not enemy then return default end

        if enemy.n < 3 or enemy.rate == 0 then
            return default, enemy.n
        end

        local healthPct = enemy.lastHealth
        if healthPct <= percent then return FOREVER, enemy.n end

        return ceil( ( healthPct - percent ) / enemy.rate ), enemy.n
    end

    function Hekili:GetGreatestTTD()
        if state.target.is_dummy then return 180 end

        local time, validUnit, now = 0, false, GetTime()

        for k, v in pairs( db ) do
            if not CheckEnemyExclusion( k ) then
                time = max( time, max( 0, v.deathTime ) )
                validUnit = true
            end
        end

        if not validUnit then return state.boss and FOREVER or DEFAULT_TTD end

        return time
    end

    function Hekili:GetGreatestTimeToPct( percent )
        local time, validUnit, now = 0, false, GetTime()

        if percent >= 1 then
            percent = percent / 100
        end

        for k, v in pairs(db) do
            if not CheckEnemyExclusion( k ) and v.lastHealth > percent then
                local scale = ( percent - v.deathPercent ) / ( v.lastHealth - v.deathPercent )
                time = max( time, max( 0, v.deathTime * scale ) )
                validUnit = true
            end
        end

        if not validUnit then return FOREVER end

        return time
    end

    function Hekili:GetLowestTTD()
        if state.target.is_dummy then return 180 end

        local time, validUnit, now = 3600, false, GetTime()

        for k, v in pairs(db) do
            if not CheckEnemyExclusion( k ) then
                time = min( time, max( 0, v.deathTime ) )
                validUnit = true
            end
        end

        if not validUnit then
            return FOREVER
        end

        return time
    end

    function Hekili:GetNumTTDsWithin( x )
        local count, now = 0, GetTime()
        local dummy_override = state.target.is_dummy

        for k, v in pairs(db) do
            if not dummy_override and not CheckEnemyExclusion( k ) and max( 0, v.deathTime ) <= x then
                count = count + 1
            end
        end

        return count
    end
    Hekili.GetNumTTDsBefore = Hekili.GetNumTTDsWithin

    function Hekili:GetNumTTDsAfter( x )
        local count = 0
        local dummy_override = state.target.is_dummy

        for k, v in pairs(db) do
            if dummy_override or CheckEnemyExclusion( k ) and max( 0, v.deathTime ) > x then
                count = count + 1
            end
        end

        return count
    end

    function Hekili:GetNumTargetsAboveHealthPct( amount, inclusive, minTTD )
        local count, now = 0, GetTime()

        amount = amount > 1 and ( amount / 100 ) or amount
        inclusive = inclusive or false
        minTTD = minTTD or 3

        for k, v in pairs(db) do
            if not CheckEnemyExclusion( k ) then
                if inclusive then
                    if v.lastHealth >= amount and max( 0, v.deathTime ) >= minTTD then
                        count = count + 1
                    end
                else
                    if v.lastHealth > amount and max( 0, v.deathTime ) >= minTTD then
                        count = count + 1
                    end
                end
            end
        end

        return count
    end

    function Hekili:GetNumTargetsBelowHealthPct( amount, inclusive, minTTD )
        amount = amount > 1 and ( amount / 100 ) or amount
        inclusive = inclusive or false
        minTTD = minTTD or 3

        local count, now = 0, GetTime()

        amount = amount > 1 and ( amount / 100 ) or amount
        inclusive = inclusive or false
        minTTD = minTTD or 3

        for k, v in pairs(db) do
            if not CheckEnemyExclusion( k ) then
                if inclusive then
                    if v.lastHealth <= amount and max( 0, v.deathTime ) >= minTTD then
                        count = count + 1
                    end
                else
                    if v.lastHealth < amount and max( 0, v.deathTime ) >= minTTD then
                        count = count + 1
                    end
                end
            end
        end

        return count
    end

    local bosses = {}

    function Hekili:GetAddWaveTTD()
        if state.target.is_dummy then return 180 end

        if not UnitExists( "boss1" ) then
            return self:GetGreatestTTD()
        end

        wipe(bosses)

        for i = 1, 5 do
            local unit = "boss" .. i
            local guid = UnitExists(unit) and UnitGUID(unit)
            if guid then
                bosses[ guid ] = true
            end
        end

        local time = 0

        for k, v in pairs(db) do
            if not CheckEnemyExclusion( k ) and not bosses[ k ] then
                time = max( time, v.deathTime )
            end
        end

        return time
    end

    function Hekili:GetTTDInfo()
        local output = "targets:"
        local found = false

        if state.target.is_dummy then
            output = output .. "    Target TTDs overridden; target is a training dummy"
        end

        for k, v in pairs( db ) do
            local unit = ( v.unit or "unknown" )
            local excluded = CheckEnemyExclusion( k )

            if v.n > 3 then
                output = output .. format( "\n    %-11s: %4ds [%d] #%6s%s %s", unit, v.deathTime, v.n, v.npcid, excluded and "*" or "", UnitName( v.unit ) or "Unknown" )
            else
                output = output .. format( "\n    %-11s: TBD  [%d] #%6s%s %s", unit, v.n, v.npcid, excluded and "*" or "", UnitName(v.unit) or "Unknown" )
            end
            found = true
        end

        if not found then output = output .. "  none" end

        return output
    end

    function Hekili:ExpireTTDs( all )
        local now = GetTime()

        for k, v in pairs( db ) do
            if all or now - v.lastSeen > 10 then
                EliminateEnemy( k )
            end
        end
    end

    local trackedUnits = { "target", "boss1", "boss2", "boss3", "boss4", "boss5", "focus", "arena1", "arena2", "arena3", "arena4", "arena5" }
    local seen = {}

    local UpdateTTDs = function()
        if not InCombatLockdown() then return end

        wipe(seen)

        local now = GetTime()

        for _, unit in ipairs( trackedUnits ) do
            local guid = UnitGUID(unit)

            if guid and not seen[guid] then
                if db[ guid ] and ( not UnitExists(unit) or UnitIsDead(unit) or not UnitCanAttack("player", unit) or ( UnitHealth(unit) <= 1 and UnitHealthMax(unit) > 1 ) ) then
                    EliminateEnemy( guid )
                    -- deletions = deletions + 1
                else
                    local health, healthMax = UnitHealth(unit), UnitHealthMax(unit)
                    health = health + UnitGetTotalAbsorbs(unit)
                    healthMax = max( 1, healthMax )

                    UpdateEnemy( guid, health / healthMax, unit, now )
                    -- updates = updates + 1
                end
                seen[ guid ] = true
            end
        end

        for unit, guid in pairs(npGUIDs) do
            if db[guid] and (not UnitExists(unit) or UnitIsDead(unit) or not UnitCanAttack("player", unit)) then
                EliminateEnemy(guid)
                -- deletions = deletions + 1
            elseif not seen[guid] then
                local health, healthMax = UnitHealth(unit), UnitHealthMax(unit)
                UpdateEnemy(guid, health / healthMax, unit, now)
                -- updates = updates + 1
            end
            seen[ guid ] = true
        end
    end
    Hekili:ProfileCPU( "UpdateTTDs", UpdateTTDs )

    C_Timer.NewTicker( 0.5, UpdateTTDs )
end
