-- Options/DevTools.lua
-- Development-only tools and debug utilities.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local format, lower, match = string.format, string.lower, string.match
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe

local UnitBuff, UnitDebuff, formatKey = ns.UnitBuff, ns.UnitDebuff, ns.formatKey
local orderedPairs = ns.orderedPairs
local SkeletonGen = {}
ns.SkeletonGen = SkeletonGen
ns.SkeletonGen.listener = CreateFrame( "Frame" )
local ResourceInfo = ns.ResourceInfo or {}
-- Atlas/Textures
local AtlasToString, GetAtlasFile, GetAtlasCoords = ns.AtlasToString, ns.GetAtlasFile, ns.GetAtlasCoords

local IsPassiveSpell = C_Spell.IsSpellPassive or _G.IsPassiveSpell
local IsHarmfulSpell = C_Spell.IsSpellHarmful or _G.IsHarmfulSpell
local IsHelpfulSpell = C_Spell.IsSpellHelpful or _G.IsHelpfulSpell
local IsPressHoldReleaseSpell = C_Spell.IsPressHoldReleaseSpell or _G.IsPressHoldReleaseSpell
local GetSpellBookItemInfo = function(index, bookType)
    local spellBank = ( bookType == "spell" or bookType == Enum.SpellBookItemType.Spell ) and Enum.SpellBookSpellBank.Player or Enum.SpellBookSpellBank.Pet
    local info = C_SpellBook.GetSpellBookItemInfo(index, spellBank)
    if info then return info.name, info.iconID, info.spellID end
end
local GetSpellBookItemName = function(index, bookType)
    local spellBank = ( bookType == "spell" or bookType == Enum.SpellBookItemType.Spell ) and Enum.SpellBookSpellBank.Player or Enum.SpellBookSpellBank.Pet
    local info = C_SpellBook.GetSpellBookItemInfo(index, spellBank)
    return info and info.name
end

local GetNumSpellTabs = C_SpellBook.GetNumSpellBookSkillLines

local GetSpellTabInfo = function(index)
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(index)
    if skillLineInfo then
        return	skillLineInfo.name,
                skillLineInfo.iconID,
                skillLineInfo.itemIndexOffset,
                skillLineInfo.numSpellBookItems,
                skillLineInfo.isGuild,
                skillLineInfo.offSpecID,
                skillLineInfo.shouldHide,
                skillLineInfo.specID
    end
end

local GetSpellInfo = ns.GetUnpackedSpellInfo
local GetSpellCooldown = C_Spell.GetSpellCooldown

local GetSpellDescription = C_Spell.GetSpellDescription

local GetSpellCharges = function(spellID)
    local spellChargeInfo = C_Spell.GetSpellCharges(spellID)
    if spellChargeInfo then
        return spellChargeInfo.currentCharges, spellChargeInfo.maxCharges, spellChargeInfo.cooldownStartTime, spellChargeInfo.cooldownDuration, spellChargeInfo.chargeModRate
    end
end

function Hekili:RunStressTest()
    if InCombatLockdown() then
        self:Print( "Cannot run stress test while in combat." )
        return true
    end

    local preErrorCount = 0
    for _, v in pairs( self.ErrorDB ) do
        preErrorCount = preErrorCount + v.n
    end

    local results, count, specs = "", 0, {}
    for i in ipairs( class.specs ) do
        if i ~= 0 then insert( specs, i ) end
    end
    sort( specs )

    for i, specID in ipairs( specs ) do
        local spec = class.specs[ specID ]
        results = format( "%sSpecialization: %s\n", results, spec.name )

        for key, aura in ipairs( spec.auras ) do
            local keyNamed = false
            -- Avoid duplicates.
            if aura.key == key then
                for k, v in pairs( aura ) do
                    if type( v ) == "function" then
                        local ok, val = pcall( v )
                        if not ok then
                            if not keyNamed then results = format( "%s - Aura: %s\n", results, k )
keyNamed = true end
                            results = format( "%s    - %s = %s\n", results, tostring( val ) )
                            count = count + 1
                        end
                    end
                end
                for k, v in pairs( aura.funcs ) do
                    if type( v ) == "function" then
                        local ok, val = pcall( v )
                        if not ok then
                            if not keyNamed then results = format( "%s - Aura: %s\n", results, k )
keyNamed = true end
                            results = format( "%s    - %s = %s\n", results, tostring( val ) )
                            count = count + 1
                        end
                    end
                end
            end
        end

        for key, ability in ipairs( spec.abilities ) do
            local keyNamed = false
            -- Avoid duplicates.
            if ability.key == key then
                for k, v in pairs( ability ) do
                    if type( v ) == "function" then
                        local ok, val = pcall( v )
                        if not ok then
                            if not keyNamed then results = format( "%s - Ability: %s\n", results, k )
keyNamed = true end
                            results = format( "%s    - %s = %s\n", results, tostring( val ) )
                            count = count + 1
                        end
                    end
                end
                for k, v in pairs( ability.funcs ) do
                    if type( v ) == "function" then
                        local ok, val = pcall( v )
                        if not ok then
                            if not keyNamed then results = format( "%s - Ability: %s\n", results, k )
keyNamed = true end
                            results = format( "%s    - %s = %s\n", results, tostring( val ) )
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    local postErrorCount = 0
    for _, v in pairs( self.ErrorDB ) do
        postErrorCount = postErrorCount + v.n
    end

    if count > 0 then
        Hekili:Print( results )
        Hekili:Error( results )
        return results
    end


    if postErrorCount > preErrorCount then Hekili:Print( "New warnings were loaded in /hekili > Warnings." ) end
    if count == 0 and postErrorCount == preErrorCount then
        Hekili:Print( "Stress test completed; no issues found." )
        return "Stress test completed; no issues found."
    end

    return true
end

function SkeletonGen:Init()
    self.output         = {}
    self.indent         = ""
    self.specID         = select( 1, GetSpecializationInfo( GetSpecialization() ) )
    self.talents        = {}
    self.auras          = {}
    self.abilities      = {}
    self.resources      = {}
    self.pvptalents     = {}
    self.idToToken      = {}
    self._applications  = {}
    self._removals      = {}
    self._lastCast      = { ability = nil, time = 0 }
end

function SkeletonGen:Append( s )
    insert( self.output, self.indent .. s )
end

function SkeletonGen:AppendAttr( t, k )
    if t[k] ~= nil then
        local v = t[k]
        local line = ( type(v) == "string" )
            and string.format( "%s = \"%s\",", k, tostring(v) )
            or string.format( "%s = %s,", k, tostring(v) )
        self:Append( line )
    end
end

function SkeletonGen:AppendField( field, value )
    if type( value ) == "string" then
        self:Append( field .. ' = "' .. value .. '",' )
    else
        self:Append( field .. " = " .. tostring( value ) .. "," )
    end
end

function SkeletonGen:IncreaseIndent() self.indent = self.indent .. "    " end
function SkeletonGen:DecreaseIndent() self.indent = self.indent:sub( 1, self.indent:len() - 4 ) end
function SkeletonGen:Blank() insert( self.output, "" ) end
function SkeletonGen:StartRegistration( comment, registerLine )
    self:Append( "-- " .. comment )
    self:Append( "spec:Register" .. registerLine .. "( {" )
    self:IncreaseIndent()
end

function SkeletonGen:EndRegistration()
    self:DecreaseIndent()
    self:Append( "} )\n" )
end

function SkeletonGen:FormatTalentEntry( k, v )
    return string.format(
        "%-30s = { %6d, %7d, %d }, -- %s",
        k,
        v.node or 0,
        v.id or 0,
        v.ranks or 0,
        v.tooltip or ""
    )
end

function SkeletonGen:GetBuffTooltip( unit, index, filter )
    local tooltip = HekiliTooltip or CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )
    tooltip:SetOwner( UIParent, "ANCHOR_NONE" )

    if filter == "HELPFUL" then
        tooltip:SetUnitBuff( unit, index )
    else
        tooltip:SetUnitDebuff( unit, index )
    end

    local tooltipText = {}
    for i = 1, tooltip:NumLines() do
        local line = _G[ "HekiliTooltipTextLeft" .. i ]
        if line then
            table.insert( tooltipText, line:GetText() or "" )
        end
    end

    return tooltipText
end

function SkeletonGen:CleanTooltip( tooltip )
    if not tooltip or tooltip == "" then return nil end

    -- Strip Blizzard formatting
    tooltip = tooltip:gsub( "|c%x%x%x%x%x%x%x%x", "" ):gsub( "|r", "" )

    -- Normalize thousands separators
    tooltip = tooltip:gsub( "([%d]+),([%d]+)", "%1%2" )

    -- Remove standalone 'Passive'
    tooltip = tooltip:gsub( "^%s*[Pp]assive%.?%s*$", "" )
    tooltip = tooltip:gsub( "[Pp]assive%.?%s*", "" )

    -- Early cleanup of known junk
    tooltip = tooltip:gsub( "SpellID%s*%d*", "" )
    tooltip = tooltip:gsub( "IconID%s*%d*", "" )

    -- Clean whitespace and trailing dot
    tooltip = tooltip:gsub( "\n", " " )
    tooltip = tooltip:gsub( "%s+", " " ):gsub( "^%s+", "" ):gsub( "%s+$", "" )
    tooltip = tooltip:gsub( "%.$", "" )

    if tooltip == "" then return nil end

    -- Replace numeric values with placeholders
    local counter = 1
    tooltip = tooltip:gsub( "([%d%.]+) ([A-Za-z]+ damage)", function( num, dtype )
        local repl = "$s" .. counter .. " " .. dtype
        counter = counter + 1
        return repl
    end )
    tooltip = tooltip:gsub( "%f[%d]([%d%.]+)%f[%D]", function( value )
        if value:find( "%%" ) then return value end
        local repl = "$s" .. counter
        counter = counter + 1
        return repl
    end )

    return tooltip
end


--[[
local function trackAuraApplication( token, spellID, time )
    table.insert( SkeletonGen._applications, { token = token, id = spellID, time = time } )
end

local function trackAuraRemoval( token, spellID, time )
    table.insert( SkeletonGen._removals, { token = token, id = spellID, time = time } )
end

local function assignAuraToLastCast( auraType, token, spellID )
    local last = SkeletonGen._lastCast
    if not last.ability or ( GetTime() - last.time > 0.25 ) then return end

    -- Ensure ability exists
    local ability = SkeletonGen.abilities[ last.ability ]
    if not ability then
        SkeletonGen.abilities[ last.ability ] = { id = spellID }
        ability = SkeletonGen.abilities[ last.ability ]
    end

    ability[ auraType ] = ability[ auraType ] or {}
    ability[ auraType ][ token ] = spellID
end--]]

local function GetAbilityKey( ability )
    local name = GetSpellInfo( ability.id )
    return name and formatKey( name ) or "s" .. ability.id
end

local function HasText( s ) return s and s ~= "" end

local function TitleCase( str )
    return str:gsub( "_", " " ):gsub( "(%a)(%w*)", function( a, b ) return a:upper() .. b:lower() end )
end

local function WowHeadComment( s )
    return "-- https://www.wowhead.com/spell=" .. ( type( s ) == "table" and s.id or s )
end

local function SkeletonCLEU( _, _, subtype, _, sourceGUID, sourceName, _, _, _, _, _, spellID, spellName )
    if not sourceName or not UnitIsUnit( sourceName, "player" ) then return end
    if type( spellName ) ~= "string" then return end

    local now = GetTime()
    local token = "s" .. spellID

    if subtype:find( "AURA" ) then
        if subtype:match( "APPLIED" ) or subtype:match( "REFRESH" ) then
            assignAuraToLastCast( "applies", token, spellID )
            trackAuraApplication( token, spellID, now )

        elseif subtype:match( "REMOVED" ) then
            assignAuraToLastCast( "removes", token, spellID )
            trackAuraRemoval( token, spellID, now )
        end
    elseif subtype == "SPELL_CAST_SUCCESS" then
        SkeletonGen._lastCast.ability = token
        SkeletonGen._lastCast.time = now
    end
end

local function SkeletonHandler( self, event, unit, ... )

    if event == "UNIT_AURA" then
        if UnitIsUnit( unit, "player" ) or UnitCanAttack( "player", unit ) then
            -- Buffs
            for i = 1, 40 do
                local name, _, count, _, duration, _, _, _, _, spellID = UnitBuff( unit, i, "PLAYER" )
                if not name then break end

                local token = name and formatKey( name ) or "s" .. spellID
                SkeletonGen.idToToken[ spellID ] = token
                local aura = SkeletonGen.auras[ token ] or {}

                aura.id = spellID
                aura.duration = duration
                aura.max_stack = math.max( aura.max_stack or 1, count )

                local lines = SkeletonGen:GetBuffTooltip( unit, i, "HELPFUL" )
                if lines then
                    aura.tooltip = SkeletonGen:CleanTooltip( table.concat( lines, " " ) )
                end

                SkeletonGen.auras[ token ] = aura
            end

            -- Debuffs
            for i = 1, 40 do
                local name, _, count, debuffType, duration, _, _, _, _, spellID = UnitDebuff( unit, i, "PLAYER" )
                if not name then break end

                local token = name and formatKey( name ) or "s" .. spellID
                SkeletonGen.idToToken[ spellID ] = token
                local aura = SkeletonGen.auras[ token ] or {}

                aura.id = spellID
                aura.duration = duration == 0 and 3600 or duration
                aura.type = debuffType or "None"
                aura.max_stack = math.max( aura.max_stack or 1, count )


                SkeletonGen.auras[ token ] = aura
            end
        end

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local spellUnit, castGUID, spellID = unit, ...

        if not spellID or type( spellID ) ~= "number" then
            return
        end

        if UnitIsUnit( spellUnit, "player" ) then
            local spellName = GetSpellInfo( spellID )
            if not spellName then
                return
            end

            local token = "s" .. spellID

            local now = GetTime()
            SkeletonGen._lastCast.ability = token
            SkeletonGen._lastCast.time = now

            local ability = SkeletonGen.abilities[ token ] or {}
            ability.id = spellID
            ability.cast = true

            local _, duration = GetSpellCooldown( spellID )
            if duration and duration > 1.5 then
                ability.cooldown = math.floor( duration + 0.5 )
            end

            local _, maxCharges = GetSpellCharges( spellID )
            if maxCharges and maxCharges > 1 then
                ability.charges = maxCharges
            end

            for _, entry in ipairs( SkeletonGen._applications ) do
                if now - entry.time < 0.5 then
                    ability.applies = ability.applies or {}
                    ability.applies[ entry.token ] = entry.id
                end
            end

            for _, entry in ipairs( SkeletonGen._removals ) do
                if now - entry.time < 0.5 then
                    ability.removes = ability.removes or {}
                    ability.removes[ entry.token ] = entry.id
                end
            end

            SkeletonGen.abilities[ token ] = SkeletonGen:EmbedSpellData( spellID, token, ability )

            wipe( SkeletonGen._applications )
            wipe( SkeletonGen._removals )
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        SkeletonCLEU( CombatLogGetCurrentEventInfo() )
    end
end

ns.SkeletonHandler = SkeletonHandler

function SkeletonGen:PrepareSpecData()
    wipe( self.resources )
    wipe( self.talents )
    wipe( self.pvptalents )
    wipe( self.auras )
    wipe( self.abilities )
    wipe( self.idToToken )

    self.specID = select( 1, GetSpecializationInfo( GetSpecialization() ) )
    local specName = select( 2, GetSpecializationInfo( GetSpecialization() ) )

    self.idToToken = {}

    -- 1. Resources
    for k, powerType in pairs( ResourceInfo ) do
        local maxPower = UnitPowerMax( "player", powerType )
        if maxPower and maxPower > 0 then
            self.resources[ k ] = true
        end
    end

    -- 2. Talents (Class, Spec, Hero)
    local configID = C_ClassTalents.GetActiveConfigID()
    local configInfo = configID and C_Traits.GetConfigInfo( configID )
    local specID = self.specID

    local validHeroTrees = {}
    local heroTreeIDs = C_ClassTalents.GetHeroTalentSpecsForClassSpec( configID, specID )
    if heroTreeIDs then
        for _, treeID in ipairs( heroTreeIDs ) do
            validHeroTrees[ treeID ] = true
        end
    end

    if configInfo then
        for _, treeID in ipairs( configInfo.treeIDs or {} ) do
            local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo( configID, treeID, false )
            local classCurrencyID = treeCurrencyInfo[1].traitCurrencyID
            local specCurrencyID = treeCurrencyInfo[2].traitCurrencyID

            for _, nodeID in ipairs( C_Traits.GetTreeNodes( treeID ) or {} ) do
                local nodeInfo = C_Traits.GetNodeInfo( configID, nodeID )
                if nodeInfo and nodeInfo.maxRanks > 0 then
                    local isClass, isSpec, isHero = false, false, false
                    local treeName = "Unknown"
                    local validNode = false

                    if nodeInfo.subTreeID then
                        local subTreeInfo = C_Traits.GetSubTreeInfo( configID, nodeInfo.subTreeID )
                        if subTreeInfo then
                            local id = subTreeInfo.traitCurrencyID
                            if id == classCurrencyID then
                                isClass, treeName, validNode = true, "Class", true
                            elseif id == specCurrencyID then
                                isSpec, treeName, validNode = true, specName, true
                            elseif validHeroTrees[ nodeInfo.subTreeID ] then
                                isHero, validNode = true, true
                                local heroMeta = ns.HeroTrees[ nodeInfo.subTreeID ]
                                treeName = heroMeta and heroMeta.name or subTreeInfo.name
                            end
                        end
                    end

                    -- Try again via cost lookup if still not categorized.
                    if not validNode then
                        for _, cost in ipairs( C_Traits.GetNodeCost( configID, nodeID ) or {} ) do
                            if cost.ID == classCurrencyID then
                                isClass, treeName, validNode = true, "Class", true
                            elseif cost.ID == specCurrencyID then
                                isSpec, treeName, validNode = true, specName, true
                            end
                        end
                    end

                    if not validNode then
                        -- Skip this node.
                        -- (no-op, continue loop)
                    else
                        for _, entryID in ipairs( nodeInfo.entryIDs or {} ) do
                            local entryInfo = C_Traits.GetEntryInfo( configID, entryID )
                            if entryInfo and entryInfo.definitionID then
                                local defInfo = C_Traits.GetDefinitionInfo( entryInfo.definitionID )
                                if defInfo and defInfo.spellID then
                                    local name = defInfo.overrideName or GetSpellInfo( defInfo.spellID )
                                    local token = name and formatKey( name ) or "s" .. defInfo.spellID
                                    local tooltip = self:CleanTooltip( GetSpellDescription( defInfo.spellID ) )

                                    self.idToToken[ defInfo.spellID ] = token

                                    self.talents[ token ] = {
                                        node = nodeID,
                                        id = defInfo.spellID,
                                        ranks = nodeInfo.maxRanks,
                                        tooltip = tooltip,
                                        isSpec = isSpec,
                                        isHero = isHero,
                                        tree = treeName
                                    }

                                    if not IsPassiveSpell( defInfo.spellID ) then
                                        local ability = self.abilities[ token ] or {}
                                        ability.id = defInfo.spellID
                                        ability.talent = token
                                        self.abilities[ token ] = self:EmbedSpellData( defInfo.spellID, token, ability )
                                    end
                                end
                            end
                        end
                    end
                end
            end

        end
    end

    -- 3. PvP Talents
    local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo( 1 )
    if slotInfo then
        for _, tID in ipairs( slotInfo.availableTalentIDs ) do
            local _, name, _, _, _, spellID = GetPvpTalentInfoByID( tID )
            if name and spellID then
                local name = GetSpellInfo( spellID )
                local token = name and formatKey( name ) or "s" .. spellID

                local tooltip = self:CleanTooltip( GetSpellDescription( spellID ) )

                self.idToToken[ spellID ] = token

                self.pvptalents[ token ] = {
                    talent = tID,
                    id = spellID,
                    tooltip = tooltip,
                }

                if not IsPassiveSpell( spellID ) then
                    local ability = self.abilities[ token ] or {}
                    ability.id = spellID
                    ability.pvptalent = token
                    self.abilities[ token ] = self:EmbedSpellData( spellID, token, ability )
                end
            end
        end
    end

    -- Sort PvP Talents by name.
    local sorted = {}
    for k, v in pairs( self.pvptalents ) do
        v.name = k
        table.insert( sorted, v )
    end
    table.sort( sorted, function( a, b ) return a.name < b.name end )
    self.pvptalents = {}
    for _, v in ipairs( sorted ) do
        self.pvptalents[ v.name ] = v
    end

    -- 4. Spellbook Abilities
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, count = GetSpellTabInfo( tab )
        for i = 1, count do
            local index = offset + i
            local name = GetSpellBookItemName( index, "spell" )
            local _, _, spellID = GetSpellBookItemInfo( index, "spell" )

            if name and spellID and not IsPassiveSpell( spellID ) and IsPlayerSpell( spellID ) then
                local token = "s" .. spellID
                local ability = self.abilities[ token ] or {}
                ability.id = spellID
                local desc = GetSpellDescription( spellID )
                if HasText ( desc ) then
                    ability.tooltip = self:CleanTooltip( desc )
                end

                self.idToToken[ spellID ] = token
                self.abilities[ token ] = self:EmbedSpellData( spellID, token, ability )
            end
        end
    end
end

function SkeletonGen:EmbedSpellData( spellID, token, ability )
    local name, _, texture, castTime, minRange, maxRange = GetSpellInfo( spellID )
    local haste = UnitSpellHaste( "player" )
    haste = 1 + ( haste / 100 )

    token = token or formatKey( name )
    ability = ability or {}
    if not ability.tooltip or ability.tooltip == "" then
        local desc = GetSpellDescription( spellID )
        if HasText ( desc ) then
            ability.tooltip = self:CleanTooltip( desc )
        end
    end

    if castTime % 10 ~= 0 then
        castTime = castTime * haste * 0.001
        castTime = tonumber( format( "%.2f", castTime ) )
    else
        castTime = castTime * 0.001
    end

    local cost, spendPerSec, resource
    local costs = C_Spell.GetSpellPowerCost( spellID )

    if costs then
        for _, v in ipairs( costs ) do
            if not v.hasRequiredAura or IsPlayerSpell( v.requiredAuraID ) then
                cost = v.costPercent > 0 and v.costPercent / 100 or v.cost
                spendPerSec = v.costPerSecond
                resource = formatKey( v.name )
                break
            end
        end
    end

    local passive = IsPassiveSpell( spellID )
    local harmful = IsHarmfulSpell( name )
    local helpful = IsHelpfulSpell( name )
    local _, charges, _, recharge = GetSpellCharges( spellID )

    local cooldown, gcd, icd = GetSpellBaseCooldown( spellID )
    if cooldown then cooldown = cooldown / 1000 end

    if gcd == 1000 then gcd = "totem"
    elseif gcd == 1500 then gcd = "spell"
    elseif gcd == 0 then gcd = "off"
    else
        icd = gcd / 1000
        gcd = "off"
    end

    if recharge and recharge > cooldown then
        if ( recharge * 1000 ) % 10 ~= 0 then
            recharge = recharge * haste
            recharge = tonumber( format( "%.2f", recharge ) )
        end
        cooldown = recharge
    end

    local empowered = IsPressHoldReleaseSpell and IsPressHoldReleaseSpell( spellID )

    ability.desc = GetSpellDescription( spellID ):gsub( "\r", " " ):gsub( "\n", " " ):gsub( "%s%s+", " " )
    ability.spend = cost
    ability.spendType = resource
    ability.spendPerSec = spendPerSec
    ability.cast = castTime
    ability.empowered = empowered
    ability.gcd = gcd or "spell"
    ability.icd = icd
    ability.texture = texture
    ability.startsCombat = harmful == true or helpful == false
    ability.cooldown = cooldown
    ability.charges = charges
    ability.recharge = recharge

    return ability
end

function SkeletonGen:Generate()
    local playerClass = UnitClass( "player" ):gsub( " ", "" )
    local playerSpec = select( 2, GetSpecializationInfo( GetSpecialization() ) ):gsub( " ", "" )

    local specInfo = ns.Specializations[ self.specID ]
    local isRanged = specInfo and specInfo.ranged or false

    -- Top of skeleton
    self:Append( "-- " .. playerClass .. playerSpec .. ".lua" )
    self:Append( "-- " .. date( "%B %Y" ) )
    self:Append( string.format( [[if UnitClassBase("player") ~= "%s" then return end]], UnitClassBase( "player" ) ) )
    self:Append( "" )
    self:Append( "local addon, ns = ..." )
    self:Append( "local Hekili = _G[ addon ]" )
    self:Append( "local class, state = Hekili.Class, Hekili.State" )
    self:Blank()
    self:Append( "local spec = Hekili:NewSpecialization( " .. self.specID .. ", " .. tostring( isRanged ) .. " )" )
    self:Blank()

    -- Resources
    for k in orderedPairs( self.resources ) do
        self:Append( "spec:RegisterResource( Enum.PowerType." .. k .. " )" )
    end
    self:Blank()

    -- Talents
    self:StartRegistration( "Talents", "Talents" )

    -- Organize talents into categories.
    local specName = select( 2, GetSpecializationInfo( GetSpecialization() ) )
    local className = select( 1, UnitClass( "player" ) )
    local groups = {
        [className] = {},  -- e.g., "Hunter"
        [specName] = {},   -- e.g., "Marksmanship"
    }

    for k, v in pairs( self.talents ) do
        local talentType = v.isHero and formatKey( v.tree or "unknown" ) or v.isSpec and specName or className
        groups[ talentType ] = groups[ talentType ] or {}
        table.insert( groups[ talentType ], { k, v } )
    end

    -- Capture hero tree keys for sorting
    local heroKeys = {}
    for k in pairs( groups ) do
        if k ~= className and k ~= specName then
            table.insert( heroKeys, k )
        end
    end
    table.sort( heroKeys )

    -- Class and Spec talents
    for _, section in ipairs( { className, specName } ) do
        if groups[ section ] then
            sort( groups[ section ], function( a, b ) return a[ 1 ] < b[ 1 ] end )
            self:Blank()
            self:Append( "-- " .. section )
            for _, entry in ipairs( groups[ section ] ) do
                self:Append( self:FormatTalentEntry( entry[1], entry[2] ) )
            end
        end
    end

    -- Hero Talents
    for _, key in ipairs( heroKeys ) do
        local list = groups[ key ]
        if list then
            table.sort( list, function( a, b ) return a[ 1 ] < b[ 1 ] end )
            self:Blank()
            self:Append( "-- " .. TitleCase( key ) )
            for _, entry in ipairs( list ) do
                self:Append( self:FormatTalentEntry( entry[1], entry[2] ) )
            end
        end
    end

    self:EndRegistration()

    -- PvP Talents
    self:StartRegistration( "PvP Talents", "PvpTalents" )
    for k, v in orderedPairs( self.pvptalents ) do
        self:Append( string.format( "%-30s = %4d, -- (%d) %s", k, v.talent or 0, v.id or 0, v.tooltip or "" ) )
    end
    self:EndRegistration()

    -- Auras
    self:StartRegistration( "Auras", "Auras" )

    for token, aura in orderedPairs( self.auras ) do
        local nameToken = self.idToToken[ aura.id ] or token

        if HasText( aura.tooltip ) then
            self:Append( "-- " .. aura.tooltip )
        end

        self:Append( WowHeadComment( aura.id ) )
        self:Append( nameToken .. " = {" )
        self:IncreaseIndent()

        local lines = {
            "id = " .. aura.id,
            "duration = " .. ( aura.duration == 0 and 3600 or ( aura.duration or 0 ) )
        }

        if aura.max_stack and aura.max_stack > 1 then
            insert( lines, "max_stack = " .. aura.max_stack )
        end

        local auraType = aura.type
        if auraType and auraType ~= "None" then
            local lower = auraType:lower()
            if lower == "poison" or lower == "disease" then
                insert( lines, 'type = "' .. lower .. '"' )
                insert( lines, "pandemic = true" )
            elseif lower == "magic" or lower == "curse" or lower == "enrage" then
                insert( lines, 'type = "' .. lower .. '"' )
            end
        end

        for i, line in ipairs( lines ) do
            if i < #lines then
                self:Append( line .. "," )
            else
                self:Append( line )
            end
        end

        self:DecreaseIndent()
        self:Append( "}," )
    end

    self:EndRegistration()

    -- Abilities
    self:StartRegistration( "Abilities", "Abilities" )

    local abilities = {}
    for _, ability in pairs( self.abilities ) do
        local key = GetAbilityKey( ability )
        abilities[ key ] = ability
    end

    for _, ability in orderedPairs( abilities ) do
        local k = GetAbilityKey( ability )

        if HasText( ability.tooltip ) then
            self:Append( "-- " .. ability.tooltip )
        end

        self:Append( WowHeadComment( ability.id ) )
        self:Append( k .. " = {" )
        self:IncreaseIndent()

        self:AppendField( "id", ability.id )

        if ability.empowered then
            self:Append( "cast = empowered_cast_time," )
            self:AppendField( "empowered", true )
            self:AppendField( "empowerment_default", 1)
        elseif ability.cast and ability.cast > 0 then
            self:AppendField( "cast", ability.cast )
        end

        if ability.cooldown and ability.cooldown > 0 then self:AppendField( "cooldown", ability.cooldown ) end

        if ability.charges and ability.charges > 1 then
            self:AppendField( "charges", ability.charges )
            local recharge = ability.recharge or ability.cooldown
            if recharge and recharge > 0 then
                self:AppendField( "recharge", recharge )
            end
        end

        if ability.gcd then self:AppendField( "gcd", ability.gcd ) end
        self:Blank()
        if ability.texture then self:AppendField( "texture", ability.texture ) end
        self:Blank()

        if ability.spend and ability.spend > 0 then
            self:AppendField( "spend", ability.spend )
            if ability.spendType then
                self:AppendField( "spendType", ability.spendType )
            end
            self:Blank()
        end

        if ability.talent then
            self:AppendField( "talent", ability.talent )
            self:Blank()
        end

        --[[ Applies/Removes lines as comments
        if ability.applies then
            for auraKey, auraID in pairs( ability.applies ) do
                self:Append( "-- applies " .. auraKey .. " (" .. auraID .. ")" )
            end
        end
        if ability.removes then
            for auraKey, auraID in pairs( ability.removes ) do
                self:Append( "-- removes " .. auraKey .. " (" .. auraID .. ")" )
            end
        end --]]

        self:Append( "handler = function () end" )

        self:DecreaseIndent()
        self:Append( "}," )
    end

    self:EndRegistration()


    self:StartRegistration( "Options", "Options" )

    self:AppendField( "enabled", true )
    self:Blank()
    self:AppendField( "aoe", 3 )
    self:AppendField( "cycle", false )
    self:Blank()
    self:AppendField( "nameplates", not isRanged )
    self:AppendField( "nameplateRange", ( isRanged and 40 or 8 ) )
    self:AppendField( "rangeFilter", false )
    self:Blank()
    self:AppendField( "damage", true )
    self:AppendField( "damageExpiration", 6 )
    self:Blank()
    self:AppendField( "potion", "tempered_potion" )
    self:Blank()
    self:AppendField( "package", specName )

    self:EndRegistration()

    do
        local today = tonumber( date( "%Y%m%d" ) )
        local export = "Hekili:INSERT_EXPORT_STRING"

        self:Append( "" )
        self:Append( string.format( "spec:RegisterPack( \"%s\", %d, [[%s]] )", specName, today, export ) )
    end


    -- End
    local output = table.concat( self.output, "\n" )
    Hekili.Skeleton = output
    return output
end

function Hekili:StartSkeletonListener()
    SkeletonGen:Init()

    -- Prep static spec data like talents, PvP talents, resources, spellbook abilities.
    SkeletonGen:PrepareSpecData()

    local listener = ns.SkeletonGen.listener
    if not listener then return end

    -- Initialize ephemeral, runtime-tracked fields.
    SkeletonGen._applications = SkeletonGen._applications or {}
    SkeletonGen._removals = SkeletonGen._removals or {}
    SkeletonGen._lastCast = SkeletonGen._lastCast or { ability = nil, time = 0 }

    -- Register relevant events.
    listener:RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED" )
    listener:RegisterEvent( "PLAYER_ENTERING_WORLD" )
    listener:RegisterEvent( "SPELLS_CHANGED" )
    listener:RegisterEvent( "UNIT_AURA" )
    listener:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
    listener:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )

    listener:SetScript( "OnEvent", ns.SkeletonHandler )

    -- Run initial fetches (to populate aura info, etc.).
    ns.SkeletonHandler( listener, "PLAYER_SPECIALIZATION_CHANGED", "player" )
    ns.SkeletonHandler( listener, "SPELLS_CHANGED" )
end

function Hekili:StopSkeletonListener()
    if SkeletonGen.listener then
        SkeletonGen.listener:SetScript("OnEvent", nil)
    end
end