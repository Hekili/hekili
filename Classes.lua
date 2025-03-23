-- Classes.lua
-- January 2025

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local CommitKey = ns.commitKey
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local GetItemInfo = ns.CachedGetItemInfo
local GetResourceInfo, GetResourceKey = ns.GetResourceInfo, ns.GetResourceKey
local ResetDisabledGearAndSpells = ns.ResetDisabledGearAndSpells
local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local formatKey = ns.formatKey
local getSpecializationKey = ns.getSpecializationKey
local tableCopy = ns.tableCopy

local LSR = LibStub( "SpellRange-1.0" )

local insert, wipe = table.insert, table.wipe

local mt_resource = ns.metatables.mt_resource

local GetActiveLossOfControlData, GetActiveLossOfControlDataCount = C_LossOfControl.GetActiveLossOfControlData, C_LossOfControl.GetActiveLossOfControlDataCount
local GetItemCooldown = C_Item.GetItemCooldown
local GetSpellDescription, GetSpellTexture = C_Spell.GetSpellDescription, C_Spell.GetSpellTexture
local GetSpecialization, GetSpecializationInfo = _G.GetSpecialization, _G.GetSpecializationInfo
local GetItemSpell, GetItemCount, IsUsableItem = C_Item.GetItemSpell, C_Item.GetItemCount, C_Item.IsUsableItem
local GetSpellInfo = C_Spell.GetSpellInfo
local GetSpellLink = C_Spell.GetSpellLink

local UnitBuff, UnitDebuff = ns.UnitBuff, ns.UnitDebuff

local specTemplate = {
    enabled = true,

    aoe = 2,
    cycle = false,
    cycle_min = 6,
    gcdSync = true,

    nameplates = true,
    petbased = false,

    damage = true,
    damageExpiration = 8,
    damageDots = false,
    damageOnScreen = true,
    damageRange = 0,
    damagePets = false,

    -- Toggles
    custom1Name = "Custom 1",
    custom2Name = "Custom 2",
    noFeignedCooldown = false,

    abilities = {
        ['**'] = {
            disabled = false,
            toggle = "default",
            clash = 0,
            targetMin = 0,
            targetMax = 0,
            boss = false
        }
    },
    items = {
        ['**'] = {
            disabled = false,
            toggle = "default",
            clash = 0,
            targetMin = 0,
            targetMax = 0,
            boss = false,
            criteria = nil
        }
    },

    placeboBar = 3,

    ranges = {},
    settings = {},
    phases = {},
    cooldowns = {},
    utility = {},
    defensives = {},
    custom1 = {},
    custom2 = {},
}
ns.specTemplate = specTemplate -- for options.


local function Aura_DetectSharedAura( t, type )
    if not t then return end
    local finder = type == "debuff" and FindUnitDebuffByID or FindUnitBuffByID
    local aura = class.auras[ t.key ]

    local name, _, count, _, duration, expirationTime, caster = finder( aura.shared, aura.id )

    if name then
        t.count = count > 0 and count or 1

        if expirationTime > 0 then
            t.applied = expirationTime - duration
            t.expires = expirationTime
        else
            t.applied = state.query_time
            t.expires = state.query_time + t.duration
        end
        t.caster = caster
        return
    end

    t.count = 0
    t.applied = 0
    t.expires = 0
    t.caster = "nobody"
end


local protectedFunctions = {
    -- Channels.
    start = true,
    tick = true,
    finish = true,

    -- Casts
    handler = true, -- Cast finish.
    impact = true,  -- Projectile impact.
}


local HekiliSpecMixin = {
    RegisterResource = function( self, resourceID, regen, model, meta )
        local resource = GetResourceKey( resourceID )

        if not resource then
            Hekili:Error( "Unable to identify resource with PowerType " .. resourceID .. "." )
            return
        end

        local r = self.resources[ resource ] or {}

        r.resource = resource
        r.type = resourceID
        r.state = model or setmetatable( {
            resource = resource,
            type = resourceID,

            forecast = {},
            fcount = 0,
            times = {},
            values = {},

            actual = 0,
            max = 1,

            active_regen = 0.001,
            inactive_regen = 0.001,
            last_tick = 0,

            swingGen = false,

            add = function( amt, overcap )
                -- Bypasses forecast, useful in hooks.
                if overcap then r.state.amount = r.state.amount + amt
                else r.state.amount = max( 0, min( r.state.amount + amt, r.state.max ) ) end
            end,

            timeTo = function( x )
                return state:TimeToResource( r.state, x )
            end,
        }, mt_resource )
        r.state.regenModel = regen
        r.state.meta = meta or {}

        for _, func in pairs( r.state.meta ) do
            setfenv( func, state )
        end

        if r.state.regenModel then
            for _, v in pairs( r.state.regenModel ) do
                v.resource = v.resource or resource
                self.resourceAuras[ v.resource ] = self.resourceAuras[ v.resource ] or {}

                if v.aura then
                    self.resourceAuras[ v.resource ][ v.aura ] = true
                end

                if v.channel then
                    self.resourceAuras[ v.resource ].casting = true
                end

                if v.swing then
                    r.state.swingGen = true
                end
            end
        end

        self.primaryResource = self.primaryResource or resource
        self.resources[ resource ] = r

        CommitKey( resource )
    end,

    RegisterTalents = function( self, talents )
        for talent, id in pairs( talents ) do
            self.talents[ talent ] = id
            CommitKey( talent )

            local hero = id[ 4 ]

            if hero then
                self.talents[ hero ] = id
                CommitKey( hero )
                id[ 4 ] = nil
            end
        end
    end,

    RegisterPvpTalents = function( self, pvp )
        for talent, spell in pairs( pvp ) do
            self.pvptalents[ talent ] = spell
            CommitKey( talent )
        end
    end,

    RegisterAura = function( self, aura, data )
        CommitKey( aura )

        local a = setmetatable( {
            funcs = {}
        }, {
            __index = function( t, k )
                if t.funcs[ k ] then return t.funcs[ k ]() end

                local setup = rawget( t, "onLoad" )
                if setup then
                    t.onLoad = nil
                    setup( t )

                    return t[ k ]
                end
            end
        } )

        a.key = aura

        if not data.id then
            self.pseudoAuras = self.pseudoAuras + 1
            data.id = ( -1000 * self.id ) - self.pseudoAuras
        end

        -- default values.
        data.duration  = data.duration or 30
        data.max_stack = data.max_stack or 1

        -- This is a shared buff that can come from anyone, give it a special generator.
        --[[ if data.shared then
            a.generate = Aura_DetectSharedAura
        end ]]

        for element, value in pairs( data ) do
            if type( value ) == "function" then
                setfenv( value, state )
                if element ~= "generate" then a.funcs[ element ] = value
                else a[ element ] = value end
            else
                a[ element ] = value
            end

            class.knownAuraAttributes[ element ] = true
        end

        self.auras[ aura ] = a

        if a.id then
            if a.id > 0 then
                -- Hekili:ContinueOnSpellLoad( a.id, function( success )
                a.onLoad = function( a )
                    local d = GetSpellInfo( a.id )
                    a.name = d and d.name

                    if not a.name then
                        for k, v in pairs( class.auraList ) do
                            if v == a then class.auraList[ k ] = nil end
                        end

                        Hekili.InvalidSpellIDs = Hekili.InvalidSpellIDs or {}
                        Hekili.InvalidSpellIDs[ a.id ] = a.name or a.key

                        a.id = a.key
                        a.name = a.name or a.key

                        return
                    end

                    a.desc = GetSpellDescription( a.id )

                    local texture = a.texture or GetSpellTexture( a.id )

                    if self.id > 0 then
                        class.auraList[ a.key ] = "|T" .. texture .. ":0|t " .. a.name
                    end

                    self.auras[ a.name ] = a
                    if GetSpecializationInfo( GetSpecialization() or 0 ) == self.id then
                        -- Copy to class table as well.
                        class.auras[ a.name ] = a
                    end

                    if self.pendingItemSpells[ a.name ] then
                        local items = self.pendingItemSpells[ a.name ]

                        if type( items ) == "table" then
                            for i, item in ipairs( items ) do
                                local ability = self.abilities[ item ]
                                ability.itemSpellKey = a.key .. "_" .. ability.itemSpellID

                                self.abilities[ ability.itemSpellKey ] = a
                                class.abilities[ ability.itemSpellKey ] = a
                            end
                        else
                            local ability = self.abilities[ items ]
                            ability.itemSpellKey = a.key .. "_" .. ability.itemSpellID

                            self.abilities[ ability.itemSpellKey ] = a
                            class.abilities[ ability.itemSpellKey ] = a
                        end

                        self.pendingItemSpells[ a.name ] = nil
                        self.itemPended = nil
                    end
                end
            end
            self.auras[ a.id ] = a
        end

        if data.meta then
            for k, v in pairs( data.meta ) do
                if type( v ) == "function" then data.meta[ k ] = setfenv( v, state ) end
                class.knownAuraAttributes[ k ] = true
            end
        end

        if data.copy then
            if type( data.copy ) ~= "table" then
                self.auras[ data.copy ] = a
            else
                for _, key in ipairs( data.copy ) do
                    self.auras[ key ] = a
                end
            end
        end
    end,

    RegisterAuras = function( self, auras )
        for aura, data in pairs( auras ) do
            self:RegisterAura( aura, data )
        end
    end,

    RegisterPower = function( self, power, id, aura )
        self.powers[ power ] = id
        CommitKey( power )

        if aura and type( aura ) == "table" then
            self:RegisterAura( power, aura )
        end
    end,

    RegisterPowers = function( self, powers )
        for k, v in pairs( powers ) do
            self.powers[ k ] = v.id
            self.powers[ v.id ] = k

            for token, ids in pairs( v.triggers ) do
                if not self.auras[ token ] then
                    self:RegisterAura( token, {
                        id = v.id,
                        copy = ids
                    } )
                end
            end
        end
    end,

    RegisterStateExpr = function( self, key, func )
        setfenv( func, state )
        self.stateExprs[ key ] = func
        class.stateExprs[ key ] = func
        CommitKey( key )
    end,

    RegisterStateFunction = function( self, key, func )
        setfenv( func, state )
        self.stateFuncs[ key ] = func
        class.stateFuncs[ key ] = func
        CommitKey( key )
    end,

    RegisterStateTable = function( self, key, data )
        for _, f in pairs( data ) do
            if type( f ) == "function" then
                setfenv( f, state )
            end
        end

        local meta = getmetatable( data )

        if meta and meta.__index then
            setfenv( meta.__index, state )
        end

        self.stateTables[ key ] = data
        class.stateTables[ key ] = data
        CommitKey( key )
    end,

    -- Phases are for more durable variables that should be recalculated over the course of recommendations.
    -- The start/finish conditions are calculated on reset and that state is persistent between sets of recommendations.
    -- Within a set of recommendations, the phase conditions are recalculated when the clock advances and/or when ability handlers are fired.
    -- Notably, finish is only fired if we are currently in the phase.
    RegisterPhase = function( self, key, start, finish, ... )
        if start then start = setfenv( start, state ) end
        if finish then finish = setfenv( finish, state ) end

        self.phases[ key ] = {
            activate = start,
            deactivate = finish,
            virtual = {},
            real = {}
        }

        local phase = self.phases[ key ]
        local n = select( "#", ... )

        for i = 1, n do
            local hook = select( i, ... )

            if hook == "reset_precast" then
                self:RegisterHook( hook, function()
                    local d = display or "Primary"

                    if phase.real[ d ] == nil then
                        phase.real[ d ] = false
                    end

                    local original = phase.real[ d ]

                    if state.time == 0 and not InCombatLockdown() then
                        phase.real[ d ] = false
                        -- Hekili:Print( format( "[ %s ] Phase '%s' set to '%s' (%s) - out of combat.", self.name or "Unspecified", key, tostring( phase.real[ d ] ), hook ) )
                        -- if Hekili.ActiveDebug then Hekili:Debug( "[ %s ] Phase '%s' set to '%s' (%s) - out of combat.", self.name or "Unspecified", key, tostring( phase.virtual[ display or "Primary" ] ), hook ) end
                    end

                    if not phase.real[ d ] and phase.activate() then
                        phase.real[ d ] = true
                    end

                    if phase.real[ d ] and phase.deactivate() then
                        phase.real[ d ] = false
                    end

                    --[[ if phase.real[ d ] ~= original then
                        if d == "Primary" then Hekili:Print( format( "Phase change for %s [ %s ] (from %s to %s).", key, d, tostring( original ), tostring( phase.real[ d ] ) ) ) end
                    end ]]

                    phase.virtual[ d ] = phase.real[ d ]

                    if Hekili.ActiveDebug then Hekili:Debug( "[ %s ] Phase '%s' set to '%s' (%s).", self.name or "Unspecified", key, tostring( phase.virtual[ d ] ), hook ) end
                end )
            else
                self:RegisterHook( hook, function()
                    local d = display or "Primary"
                    local previous = phase.virtual[ d ]

                    if phase.virtual[ d ] ~= true and phase.activate() then
                        phase.virtual[ d ] = true
                    end

                    if phase.virtual[ d ] == true and phase.deactivate() then
                        phase.virtual[ d ] = false
                    end

                    if Hekili.ActiveDebug and phase.virtual[ d ] ~= previous then Hekili:Debug( "[ %s ] Phase '%s' set to '%s' (%s) - virtual.", self.name or "Unspecified", key, tostring( phase.virtual[ d ] ), hook ) end
                end )
            end
        end

        self:RegisterVariable( key, function()
            return self.phases[ key ].virtual[ display or "Primary" ]
        end )
    end,

    RegisterPhasedVariable = function( self, key, default, value, ... )
        value = setfenv( value, state )

        self.phases[ key ] = {
            update = value,
            virtual = {},
            real = {}
        }

        local phase = self.phases[ key ]
        local n = select( "#", ... )

        if type( default ) == "function" then
            phase.default = setfenv( default, state )
        else
            phase.default = setfenv( function() return default end, state )
        end

        for i = 1, n do
            local hook = select( i, ... )

            if hook == "reset_precast" then
                self:RegisterHook( hook, function()
                    local d = display or "Primary"

                    if phase.real[ d ] == nil or ( state.time == 0 and not InCombatLockdown() ) then
                        phase.real[ d ] = phase.default()
                    end

                    local original = phase.real[ d ] or "nil"

                    phase.real[ d ] = phase.update( phase.real[ d ], phase.default() )
                    phase.virtual[ d ] = phase.real[ d ]

                    if Hekili.ActiveDebug then
                        Hekili:Debug( "[ %s ] Phased variable '%s' set to '%s' (%s) - was '%s'.", self.name or "Unspecified", key, tostring( phase.virtual[ display or "Primary" ] ), hook, tostring( original ) )
                    end
                end )
            else
                self:RegisterHook( hook, function()
                    local d = display or "Primary"
                    local previous = phase.virtual[ d ]

                    phase.virtual[ d ] = phase.update( phase.virtual[ d ], phase.default() )

                    if Hekili.ActiveDebug and phase.virtual[ d ] ~= previous then Hekili:Debug( "[ %s ] Phased variable '%s' set to '%s' (%s) - virtual.", self.name or "Unspecified", key, tostring( phase.virtual[ display or "Primary" ] ), hook ) end
                end )
            end
        end

        self:RegisterVariable( key, function()
            return self.phases[ key ].virtual[ display or "Primary" ]
        end )
    end,

    RegisterGear = function( self, ... )
        local arg1 = select( 1, ... )
        if not arg1 then return end

        -- If the first arg is a table, it's registering multiple items/sets
        if type( arg1 ) == "table" then
            for set, data in pairs( arg1 ) do
                self:RegisterGear( set, data )
            end
            return
        end

        local arg2 = select( 2, ... )
        if not arg2 then return end

        -- If the first arg is a string, register it
        if type( arg1 ) == "string" then
            local gear = self.gear[ arg1 ] or {}
            local found = false

            -- If the second arg is a table, it's a tier set with auras
            if type( arg2 ) == "table" then
                if arg2.items then
                    for _, item in ipairs( arg2.items ) do
                        table.insert( gear, item )
                        gear[ item ] = true
                        found = true
                    end
                end

                if arg2.auras then
                    -- Register auras (even if no items are found, can be useful for early patch testing).
                    self:RegisterAuras( arg2.auras )
                end
            end

            -- If the second arg is a number, this is a legacy registration with a single set/item
            if type( arg2 ) == "number" then
                local n = select( "#", ... )
                local item, i = arg2, 3

                while item do
                    table.insert( gear, item )
                    gear[ item ] = true
                    found = true

                    i = i + 1
                    item = select( i, ... )
                end
            end

            if found then
                self.gear[ arg1 ] = gear
                CommitKey( arg1 )
            else
                -- No valid items found, remove the set.
                self.gear[ arg1 ] = nil
            end

            return
        end

        -- Debug print if needed
        -- Hekili:Print( "|cFFFF0000[Hekili]|r Invalid input passed to RegisterGear." )
    end,


    -- Check for the set bonus based on hidden aura instead of counting the number of equipped items.
    -- This may be useful for tier set items that are crafted so their item ID doesn't match.
    -- The alternative is *probably* to treat sets based on bonusIDs.
    RegisterSetBonus = function( self, key, spellID )
        self.setBonuses[ key ] = spellID
        CommitKey( key )
    end,

    RegisterSetBonuses = function( self, ... )
        local n = select( "#", ... )

        for i = 1, n, 2 do
            self:RegisterSetBonus( select( i, ... ) )
        end
    end,

    RegisterPotion = function( self, potion, data )
        self.potions[ potion ] = data

        data.key = potion

        if data.items then
            if type( data.items ) == "table" then
                for _, key in ipairs( data.items ) do
                    self.potions[ key ] = data
                    CommitKey( key )
                end
            else
                self.potions[ data.items ] = data
                CommitKey( data.items )
            end
        end

        local potionItem = Item:CreateFromItemID( data.item )

        if not potionItem:IsItemEmpty() then
            potionItem:ContinueOnItemLoad( function()
                local name = potionItem:GetItemName() or data.name
                local link = potionItem:GetItemLink() or data.link

                data.name = name
                data.link = link

                class.potionList[ potion ] = link
                return true
            end )
        end

        CommitKey( potion )
    end,

    RegisterPotions = function( self, potions )
        for k, v in pairs( potions ) do
            self:RegisterPotion( k, v )
        end
    end,

    RegisterRecheck = function( self, func )
        self.recheck = func
    end,

    RegisterHook = function( self, hook, func, noState )
        if not ( noState == true or hook == "COMBAT_LOG_EVENT_UNFILTERED" and noState == nil ) then
            func = setfenv( func, state )
        end
        self.hooks[ hook ] = self.hooks[ hook ] or {}
        insert( self.hooks[ hook ], func )
    end,

    RegisterAbility = function( self, ability, data )
        CommitKey( ability )

        local a = setmetatable( {
            funcs = {},
        }, {
            __index = function( t, k )
                local setup = rawget( t, "onLoad" )
                if setup then
                    t.onLoad = nil
                    setup( t )
                    return t[ k ]
                end

                if t.funcs[ k ] then return t.funcs[ k ]() end
                if k == "lastCast" then return state.history.casts[ t.key ] or t.realCast end
                if k == "lastUnit" then return state.history.units[ t.key ] or t.realUnit end
            end,
        } )

        a.key = ability
        a.from = self.id

        if not data.id then
            if data.item then
                class.specs[ 0 ].itemAbilities = class.specs[ 0 ].itemAbilities + 1
                data.id = -100 - class.specs[ 0 ].itemAbilities
            else
                self.pseudoAbilities = self.pseudoAbilities + 1
                data.id = -1000 * self.id - self.pseudoAbilities
            end
            a.id = data.id
        end

        if data.id and type( data.id ) == "function" then
            if not data.copy or type( data.copy ) == "table" and #data.copy == 0 then
                Hekili:Error( "RegisterAbility for %s (Specialization %d) will fail; ability has an ID function but needs to have 'copy' entries for the abilities table.", ability, self.id )
            end
        end


        local item = data.item
        if item and type( item ) == "function" then
            setfenv( item, state )
            item = item()
        end

        if data.meta then
            for k, v in pairs( data.meta ) do
                if type( v ) == "function" then data.meta[ k ] = setfenv( v, state ) end
            end
        end

        -- default values.
        if not data.cast     then data.cast     = 0             end
        if not data.cooldown then data.cooldown = 0             end
        if not data.recharge then data.recharge = data.cooldown end
        if not data.charges  then data.charges  = 1             end

        if data.hasteCD then
            if type( data.cooldown ) == "number" and data.cooldown > 0 then data.cooldown = Hekili:Loadstring( "return " .. data.cooldown .. " * haste" ) end
            if type( data.recharge ) == "number" and data.recharge > 0 then data.recharge = Hekili:Loadstring( "return " .. data.recharge .. " * haste" ) end
        end

        if not data.fixedCast and type( data.cast ) == "number" then
            data.cast = Hekili:Loadstring( "return " .. data.cast .. " * haste" )
        end

        if data.toggle == "interrupts" and data.gcd == "off" and data.readyTime == state.timeToInterrupt and data.interrupt == nil then
            data.interrupt = true
        end

        for key, value in pairs( data ) do
            if type( value ) == "function" then
                setfenv( value, state )

                if not protectedFunctions[ key ] then a.funcs[ key ] = value
                else a[ key ] = value end
                data[ key ] = nil
            else
                a[ key ] = value
            end
        end

        if ( a.velocity or a.flightTime ) and a.impact and a.isProjectile == nil then
            a.isProjectile = true
        end

        a.realCast = 0

        if item then
            --[[ local name, link, _, _, _, _, _, _, _, texture = GetItemInfo( item )

            a.name = name or ability
            a.link = link or ability ]]

            class.itemMap[ item ] = ability

            -- Register the item if it doesn't already exist.
            class.specs[0]:RegisterGear( ability, item )

            local actionItem = Item:CreateFromItemID( item )
            if not actionItem:IsItemEmpty() then
                actionItem:ContinueOnItemLoad( function( success )
                    local name = actionItem:GetItemName()
                    local link = actionItem:GetItemLink()
                    local texture = actionItem:GetItemIcon()

                   
                    if name then
                        if not a.name or a.name == a.key then a.name = name end
                        if not a.link or a.link == a.key then a.link = link end
                        if not a.funcs.texture then a.texture = a.texture or texture end

                        if a.suffix then
                            a.actualName = name
                            a.name = a.name .. " " .. a.suffix
                        end

                        self.abilities[ ability ] = self.abilities[ ability ] or a
                        self.abilities[ a.name ] = self.abilities[ a.name ] or a
                        self.abilities[ a.link ] = self.abilities[ a.link ] or a
                        self.abilities[ data.id ] = self.abilities[ a.link ] or a

                        a.itemLoaded = GetTime()

                        if a.item and a.item ~= 158075 then
                            a.itemSpellName, a.itemSpellID = GetItemSpell( a.item )

                            if a.itemSpellID then
                                a.itemSpellKey = a.key .. "_" .. a.itemSpellID
                                self.abilities[ a.itemSpellKey ] = a
                                class.abilities[ a.itemSpellKey ] = a
                            end

                            if a.itemSpellName then
                                local itemAura = self.auras[ a.itemSpellName ]

                                if itemAura then
                                    a.itemSpellKey = itemAura.key .. "_" .. a.itemSpellID
                                    self.abilities[ a.itemSpellKey ] = a
                                    class.abilities[ a.itemSpellKey ] = a

                                else
                                    if self.pendingItemSpells[ a.itemSpellName ] then
                                        if type( self.pendingItemSpells[ a.itemSpellName ] ) == "table" then
                                            table.insert( self.pendingItemSpells[ a.itemSpellName ], ability )
                                        else
                                            local first = self.pendingItemSpells[ a.itemSpellName ]
                                            self.pendingItemSpells[ a.itemSpellName ] = {
                                                first,
                                                ability
                                            }
                                        end
                                    else
                                        self.pendingItemSpells[ a.itemSpellName ] = ability
                                        a.itemPended = GetTime()
                                    end
                                end
                            end
                        end

                        if not a.unlisted then
                            class.abilityList[ ability ] = a.listName or ( "|T" .. ( a.texture or texture ) .. ":0|t " .. link )
                            class.itemList[ item ] = a.listName or ( "|T" .. a.texture .. ":0|t " .. link )
                            class.abilityByName[ a.name ] = a
                        end

                        if data.copy then
                            if type( data.copy ) == "string" or type( data.copy ) == "number" then
                                self.abilities[ data.copy ] = a
                            elseif type( data.copy ) == "table" then
                                for _, key in ipairs( data.copy ) do
                                    self.abilities[ key ] = a
                                end
                            end
                        end

                        if data.items then
                            local addedToItemList = false

                            for _, id in ipairs( data.items ) do
                                local copyItem = Item:CreateFromItemID( id )

                                if not copyItem:IsItemEmpty() then
                                    copyItem:ContinueOnItemLoad( function()
                                        local name = copyItem:GetItemName()
                                        local link = copyItem:GetItemLink()
                                        local texture = copyItem:GetItemIcon()

                                        if name then
                                            class.abilities[ name ] = a
                                            self.abilities[ name ]  = a

                                            if not class.itemList[ id ] then
                                                class.itemList[ id ] = a.listName or ( "|T" .. ( a.texture or texture ) .. ":0|t " .. link )
                                                addedToItemList = true
                                            end
                                        end
                                    end )
                                end
                            end

                            if addedToItemList then
                                if ns.ReadKeybindings then ns.ReadKeybindings() end
                            end
                        end

                        if ability then class.abilities[ ability ] = a end
                        if a.name  then class.abilities[ a.name ]  = a end
                        if a.link  then class.abilities[ a.link ]  = a end
                        if a.id    then class.abilities[ a.id ]    = a end

                        Hekili.OptionsReady = false

                        return true
                    end

                    return false
                end )
            end
        end

        if a.id and a.id > 0 then
            -- Hekili:ContinueOnSpellLoad( a.id, function( success )
            a.onLoad = function()
                local spellInfo = GetSpellInfo( a.id )
                
                if spellInfo == nil then
                    spellInfo = GetItemInfo( a.id )
                end
                if spellInfo then
                    a.name = spellInfo.name
                else
                    a.name = nil
                end

                if not a.name then
                    for k, v in pairs( class.abilityList ) do
                        if v == a then class.abilityList[ k ] = nil end
                    end
                    Hekili.InvalidSpellIDs = Hekili.InvalidSpellIDs or {}
                    table.insert( Hekili.InvalidSpellIDs, a.id )
                    Hekili:Error( "Name info not available for " .. a.id .. "." )
                    return
                end

                if not a.name then Hekili:Error( "Name info not available for " .. a.id .. "." ); return false end

                a.desc = GetSpellDescription( a.id ) -- was returning raw tooltip data.

                if a.suffix then
                    a.actualName = a.name
                    a.name = a.name .. " " .. a.suffix
                end

                local texture = a.texture or GetSpellTexture( a.id )

                self.abilities[ a.name ] = self.abilities[ a.name ] or a
                class.abilities[ a.name ] = class.abilities[ a.name ] or a

                if not a.unlisted then
                    class.abilityList[ ability ] = a.listName or ( "|T" .. texture .. ":0|t " .. a.name )
                    class.abilityByName[ a.name ] = class.abilities[ a.name ] or a
                end

                if a.rangeSpell and type( a.rangeSpell ) == "number" then
                    Hekili:ContinueOnSpellLoad( a.rangeSpell, function( success )
                        if success then
                            local info = GetSpellInfo( a.rangeSpell )
                            if info then
                                a.rangeSpell = info.name
                            else
                                a.rangeSpell = nil
                            end
                        else
                            a.rangeSpell = nil
                        end
                    end )
                end

                Hekili.OptionsReady = false
            end
        end

        self.abilities[ ability ] = a
        self.abilities[ a.id ] = a

        if not a.unlisted then class.abilityList[ ability ] = class.abilityList[ ability ] or a.listName or a.name end

        if data.copy then
            if type( data.copy ) == "string" or type( data.copy ) == "number" then
                self.abilities[ data.copy ] = a
            elseif type( data.copy ) == "table" then
                for _, key in ipairs( data.copy ) do
                    self.abilities[ key ] = a
                end
            end
        end

        if data.items then
            for _, itemID in ipairs( data.items ) do
                class.itemMap[ itemID ] = ability
            end
        end

        if a.dual_cast or a.funcs.dual_cast then
            self.can_dual_cast = true
            self.dual_cast[ a.key ] = true
        end

        if a.empowered or a.funcs.empowered then
            self.can_empower = true
        end

        if a.auras then
            self:RegisterAuras( a.auras )
        end
    end,

    RegisterAbilities = function( self, abilities )
        for ability, data in pairs( abilities ) do
            self:RegisterAbility( ability, data )
        end
    end,

    RegisterPack = function( self, name, version, import )
        self.packs[ name ] = {
            version = tonumber( version ),
            import = import:gsub("([^|])|([^|])", "%1||%2")
        }
    end,

    RegisterPriority = function( self, name, version, notes, priority )
    end,

    RegisterRanges = function( self, ... )
        if type( ... ) == "table" then
            self.ranges = ...
            return
        end

        for i = 1, select( "#", ... ) do
            insert( self.ranges, ( select( i, ... ) ) )
        end
    end,

    RegisterRangeFilter = function( self, name, func )
        self.filterName = name
        self.filter = func
    end,

    RegisterOptions = function( self, options )
        self.options = options
    end,

    RegisterEvent = function( self, event, func )
        RegisterEvent( event, function( ... )
            if state.spec.id == self.id then func( ... ) end
        end )
    end,

    RegisterUnitEvent = function( self, event, unit1, unit2, func )
        RegisterUnitEvent( event, unit1, unit2, function( ... )
            if state.spec.id == self.id then func( ... ) end
        end )
    end,

    RegisterCombatLogEvent = function( self, func )
        self:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", func )
    end,

    RegisterCycle = function( self, func )
        self.cycle = setfenv( func, state )
    end,

    RegisterPet = function( self, token, id, spell, duration, ... )
        CommitKey( token )
    
        -- Register the main pet.
        self.pets[ token ] = {
            id = type( id ) == "function" and setfenv( id, state ) or id,
            token = token,
            spell = spell,
            duration = type( duration ) == "function" and setfenv( duration, state ) or duration
        }
    
        -- Process copies.
        local n = select( "#", ... )
        if n and n > 0 then
            for i = 1, n do
                local copy = select( i, ... )
                self.pets[ copy ] = self.pets[ token ]
            end
        end
    end,

    RegisterPets = function( self, pets )
        for token, data in pairs( pets ) do
            -- Extract fields from the pet definition.
            local id = data.id
            local spell = data.spell
            local duration = data.duration
            local copy = data.copy
    
            -- Register the pet and handle the copy field if it exists.
            if copy then
                self:RegisterPet( token, id, spell, duration, copy )
            else
                self:RegisterPet( token, id, spell, duration )
            end
        end
    end,

    RegisterTotem = function( self, token, id, ... )
        -- Register the primary totem.
        self.totems[ token ] = id
        self.totems[ id ] = token
    
        -- Handle copies if provided.
        local n = select( "#", ... )
        if n and n > 0 then
            for i = 1, n do
                local copy = select( i, ... )
                self.totems[ copy ] = id
                self.totems[ id ] = copy
            end
        end
    
        -- Commit the primary token.
        CommitKey( token )
    end,

    RegisterTotems = function( self, totems )
        for token, data in pairs( totems ) do
            local id = data.id
            local copy = data.copy
    
            -- Register the primary totem.
            self.totems[ token ] = id
            self.totems[ id ] = token
    
            -- Register any copies (aliases).
            if copy then
                if type( copy ) == "string" then
                    self.totems[ copy ] = id
                    self.totems[ id ] = copy
                elseif type( copy ) == "table" then
                    for _, alias in ipairs( copy ) do
                        self.totems[ alias ] = id
                        self.totems[ id ] = alias
                    end
                end
            end
    
            CommitKey( token )
        end
    end,

    GetSetting = function( self, info )
        local setting = info[ #info ]
        return Hekili.DB.profile.specs[ self.id ].settings[ setting ]
    end,

    SetSetting = function( self, info, val )
        local setting = info[ #info ]
        Hekili.DB.profile.specs[ self.id ].settings[ setting ] = val
    end,

    -- option should be an AceOption table.
    RegisterSetting = function( self, key, value, option )
        CommitKey( key )

        table.insert( self.settings, {
            name = key,
            default = value,
            info = option
        } )

        option.order = 100 + #self.settings

        option.get = option.get or function( info )
            local setting = info[ #info ]
            local val = Hekili.DB.profile.specs[ self.id ].settings[ setting ]

            if val ~= nil then return val end
            return value
        end

        option.set = option.set or function( info, val )
            local setting = info[ #info ]
            Hekili.DB.profile.specs[ self.id ].settings[ setting ] = val
        end
    end,

    -- For faster variables.
    RegisterVariable = function( self, key, func )
        CommitKey( key )
        self.variables[ key ] = setfenv( func, state )
    end,
}


function Hekili:RestoreDefaults()
    local p = self.DB.profile
    local reverted = {}
    local changed = {}

    for k, v in pairs( class.packs ) do
        local existing = rawget( p.packs, k )

        if not existing or not existing.version or existing.version ~= v.version then
            local data = self.DeserializeActionPack( v.import )

            if data and type( data ) == "table" then
                p.packs[ k ] = data.payload
                data.payload.version = v.version
                data.payload.date = v.version
                data.payload.builtIn = true

                if not existing or not existing.version or existing.version < v.version then
                    insert( changed, k )
                else
                    insert( reverted, k )
                end

                local specID = data.payload.spec

                if specID then
                    local spec = rawget( p.specs, specID )
                    if spec then
                        if spec.package then
                            local currPack = p.packs[ spec.package ]
                            if not currPack or currPack.spec ~= specID then
                                spec.package = k
                            end
                        else
                            spec.package = k
                        end
                    end
                end
            end
        end
    end

    if #changed > 0 or #reverted > 0 then
        self:LoadScripts()
    end

    if #changed > 0 then
        local msg

        if #changed == 1 then
            msg = "The |cFFFFD100" .. changed[1] .. "|r priority was updated."
        elseif #changed == 2 then
            msg = "The |cFFFFD100" .. changed[1] .. "|r and |cFFFFD100" .. changed[2] .. "|r priorities were updated."
        else
            msg = "|cFFFFD100" .. changed[1] .. "|r"

            for i = 2, #changed - 1 do
                msg = msg .. ", |cFFFFD100" .. changed[i] .. "|r"
            end

            msg = "The " .. msg .. ", and |cFFFFD100" .. changed[ #changed ] .. "|r priorities were updated."
        end

        if msg then
            C_Timer.After( 5, function()
                if Hekili.DB.profile.notifications.enabled then Hekili:Notify( msg, 6 ) end
                Hekili:Print( msg )
            end )
        end
    end

    if #reverted > 0 then
        local msg

        if #reverted == 1 then
            msg = "The |cFFFFD100" .. reverted[1] .. "|r priority was reverted."
        elseif #reverted == 2 then
            msg = "The |cFFFFD100" .. reverted[1] .. "|r and |cFFFFD100" .. reverted[2] .. "|r priorities were reverted."
        else
            msg = "|cFFFFD100" .. reverted[1] .. "|r"

            for i = 2, #reverted - 1 do
                msg = msg .. ", |cFFFFD100" .. reverted[i] .. "|r"
            end

            msg = "The " .. msg .. ", and |cFFFFD100" .. reverted[ #reverted ] .. "|r priorities were reverted."
        end

        if msg then
            C_Timer.After( 6, function()
                if Hekili.DB.profile.notifications.enabled then Hekili:Notify( msg, 6 ) end
                Hekili:Print( msg )
            end )
        end
    end
end


function Hekili:RestoreDefault( name )
    local p = self.DB.profile

    local default = class.packs[ name ]

    if default then
        local data = self.DeserializeActionPack( default.import )

        if data and type( data ) == "table" then
            p.packs[ name ] = data.payload
            data.payload.version = default.version
            data.payload.date = default.version
            data.payload.builtIn = true
        end
    end
end


ns.restoreDefaults = function( category, purge )
end


ns.isDefault = function( name, category )
    if not name or not category then
        return false
    end

    for i, default in ipairs( class.defaults ) do
        if default.type == category and default.name == name then
            return true, i
        end
    end

    return false
end

function Hekili:NewSpecialization( specID, isRanged, icon )

    if not specID or specID < 0 then return end

    local id, name, _, texture, role, pClass

    if Hekili.IsRetail() and specID > 0 then id, name, _, texture, role, pClass = GetSpecializationInfoByID( specID )
    else
        id = specID
        texture = icon
    end

    if not id then
        Hekili:Error( "Unable to generate specialization DB for spec ID #" .. specID .. "." )
        return nil
    end

    if specID ~= 0 then
        class.initialized = true
    end

    local token = getSpecializationKey( id )

    local spec = class.specs[ id ] or {
        id = id,
        key = token,
        name = name,
        texture = texture,
        role = role,
        class = pClass,
        melee = not isRanged,

        resources = {},
        resourceAuras = {},
        primaryResource = nil,
        primaryStat = nil,

        talents = {},
        pvptalents = {},
        powers = {},

        auras = {},
        pseudoAuras = 0,

        abilities = {},
        pseudoAbilities = 0,
        itemAbilities = 0,
        pendingItemSpells = {},

        pets = {},
        totems = {},

        potions = {},

        ranges = {},
        settings = {},

        stateExprs = {}, -- expressions are returned as values and take no args.
        stateFuncs = {}, -- functions can take arguments and can be used as helper functions in handlers.
        stateTables = {}, -- tables are... tables.

        gear = {},
        setBonuses = {},

        hooks = {},
        funcHooks = {},
        phases = {},
        interrupts = {},

        dual_cast = {},

        packs = {},
        options = {},

        variables = {}
    }

    class.num = class.num + 1

    for key, func in pairs( HekiliSpecMixin ) do
        spec[ key ] = func
    end

    class.specs[ id ] = spec
    return spec
end

function Hekili:GetSpecialization( specID )
    if not specID then return class.specs[ 0 ] end
    return class.specs[ specID ]
end


class.file = UnitClassBase( "player" )
local all = Hekili:NewSpecialization( 0, "All", "Interface\\Addons\\Hekili\\Textures\\LOGO-WHITE.blp" )

------------------------------
-- SHARED SPELLS/BUFFS/ETC. --
------------------------------

all:RegisterAuras( {

    enlisted_a = {
        id = 282559,
        duration = 3600,
    },

    enlisted_b = {
        id = 289954,
        duration = 3600,
    },

    enlisted_c = {
        id = 269083,
        duration = 3600,
    },

    enlisted = {
        alias = { "enlisted_c", "enlisted_b", "enlisted_a" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },

    -- The War Within M+ Affix auras
    -- Haste
    cosmic_ascension = {
        id = 461910,
        duration = 30,
        max_stack = 1
    },
    -- Crit
    rift_essence = {
        id = 465136,
        duration = 30,
        max_stack = 1
    },
    -- Mastery
    void_essence = {
        id = 463767,
        duration = 30,
        max_stack = 1
    },
    -- CDR & Vers
    voidbinding = {
        id = 462661,
        duration = 30,
        max_stack = 1
    },
    -- Priory of the Sacred Flame
    blessing_of_the_sacred_flame = {
        id = 435088,
        duration = 1800,
        max_stack = 1
    },

    -- Can be used in GCD calculation.
    shadowform = {
        id = 232698,
        duration = 3600,
        max_stack = 1,
    },

    voidform = {
        id = 194249,
        duration = 15,
        max_stack = 1,
    },

    adrenaline_rush = {
        id = 13750,
        duration = 20,
        max_stack = 1,
    },

    -- Bloodlusts
    ancient_hysteria = {
        id = 90355,
        shared = "player", -- use anyone's buff on the player, not just player's.
        duration = 40,
        max_stack = 1,
    },

    heroism = {
        id = 32182,
        shared = "player", -- use anyone's buff on the player, not just player's.
        duration = 40,
        max_stack = 1,
    },

    time_warp = {
        id = 80353,
        shared = "player", -- use anyone's buff on the player, not just player's.
        duration = 40,
        max_stack = 1,
    },

    netherwinds = {
        id = 160452,
        shared = "player", -- use anyone's buff on the player, not just player's.
        duration = 40,
        max_stack = 1,
    },

    primal_rage = {
        id = 264667,
        shared = "player", -- use anyone's buff on the player, not just player's.
        duration = 40,
        max_stack = 1,
    },

    drums_of_deathly_ferocity = {
        id = 309658,
        shared = "player", -- use anyone's buff on the player, not just player's.
        duration = 40,
        max_stack = 1,
    },

    bloodlust = {
        alias = { "ancient_hysteria", "bloodlust_actual", "drums_of_deathly_ferocity", "fury_of_the_aspects", "heroism", "netherwinds", "primal_rage", "time_warp", "harriers_cry" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },

    bloodlust_actual = {
        id = 2825,
        duration = 40,
        shared = "player",
        max_stack = 1,
    },

    exhaustion = {
        id = 57723,
        duration = 600,
        shared = "player",
        max_stack = 1,
        copy = 390435
    },

    insanity = {
        id = 95809,
        duration = 600,
        shared = "player",
        max_stack = 1
    },

    temporal_displacement = {
        id = 80354,
        duration = 600,
        shared = "player",
        max_stack = 1
    },

    fury_of_the_aspects = {
        id = 390386,
        duration = 40,
        max_stack = 1,
        shared = "player",
    },

    harriers_cry = {
        id = 466904,
        duration = 40,
        max_stack = 1,
        shared = "player"
    },

    mark_of_the_wild = {
        id = 1126,
        duration = 3600,
        max_stack = 1,
        shared = "player",
    },

    fatigued = {
        id = 264689,
        duration = 600,
        shared = "player",
        max_stack = 1
    },

    sated = {
        alias = { "exhaustion", "fatigued", "insanity", "sated_actual", "temporal_displacement" },
        aliasMode = "first",
        aliasType = "debuff",
        duration = 3600,
    },

    sated_actual = {
        id = 57724,
        duration = 600,
        shared = "player",
        max_stack = 1,
    },

    blessing_of_the_bronze = {
        alias = {
            "blessing_of_the_bronze_evoker",
            "blessing_of_the_bronze_deathknight",
            "blessing_of_the_bronze_demonhunter",
            "blessing_of_the_bronze_druid",
            "blessing_of_the_bronze_hunter",
            "blessing_of_the_bronze_mage",
            "blessing_of_the_bronze_monk",
            "blessing_of_the_bronze_paladin",
            "blessing_of_the_bronze_priest",
            "blessing_of_the_bronze_rogue",
            "blessing_of_the_bronze_shaman",
            "blessing_of_the_bronze_warlock",
            "blessing_of_the_bronze_warrior",
        },
        aliasType = "buff",
        aliasMode = "longest"
    },
    -- Can always be seen and tracked by the Hunter.; Damage taken increased by $428402s4% while above $s3% health.
    -- https://wowhead.com/beta/spell=257284
    hunters_mark = {
        id = 257284,
        duration = 3600,
        tick_time = 0.5,
        type = "Magic",
        max_stack = 1,
        shared = "target"
    },
    chaos_brand = {
        id = 1490,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "target"
    },
    blessing_of_the_bronze_deathknight = {
        id = 381732,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_demonhunter = {
        id = 381741,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_druid = {
        id = 381746,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_evoker = {
        id = 381748,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_hunter = {
        id = 364342,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_mage = {
        id = 381750,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_monk = {
        id = 381751,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_paladin = {
        id = 381752,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_priest = {
        id = 381753,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_rogue = {
        id = 381754,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_shaman = {
        id = 381756,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_warlock = {
        id = 381757,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_warrior = {
        id = 381758,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },

    power_infusion = {
        id = 10060,
        duration = 20,
        max_stack = 1,
        shared = "player",
        dot = "buff"
    },

    battle_shout = {
        id = 6673,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        dot = "buff"
    },

    -- Mastery increased by $w1% and auto attacks have a $h% chance to instantly strike again.
    skyfury = {
        id = 462854,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        dot = "buff"
    },

    -- SL Season 3
    decrypted_urh_cypher = {
        id = 368239,
        duration = 10,
        max_stack = 1,
    },

    old_war = {
        id = 188028,
        duration = 25,
    },

    deadly_grace = {
        id = 188027,
        duration = 25,
    },

    prolonged_power = {
        id = 229206,
        duration = 60,
    },

    dextrous = {
        id = 146308,
        duration = 20,
    },

    vicious = {
        id = 148903,
        duration = 10,
    },

    -- WoD Legendaries
    archmages_incandescence_agi = {
        id = 177161,
        duration = 10,
    },

    archmages_incandescence_int = {
        id = 177159,
        duration = 10,
    },

    archmages_incandescence_str = {
        id = 177160,
        duration = 10,
    },

    archmages_greater_incandescence_agi = {
        id = 177172,
        duration = 10,
    },

    archmages_greater_incandescence_int = {
        id = 177176,
        duration = 10,
    },

    archmages_greater_incandescence_str = {
        id = 177175,
        duration = 10,
    },

    maalus = {
        id = 187620,
        duration = 15,
    },

    thorasus = {
        id = 187619,
        duration = 15,
    },

    sephuzs_secret = {
        id = 208052,
        duration = 10,
        max_stack = 1,
    },

    str_agi_int = {
        duration = 3600,
    },

    stamina = {
        duration = 3600,
    },

    attack_power_multiplier = {
        duration = 3600,
    },

    haste = {
        duration = 3600,
    },

    spell_power_multiplier = {
        duration = 3600,
    },

    critical_strike = {
        duration = 3600,
    },

    mastery = {
        duration = 3600,
    },

    versatility = {
        duration = 3600,
    },

    casting = {
        name = "Casting",
        generate = function( t, auraType )
            local unit = auraType == "debuff" and "target" or "player"

            if unit == "player" or UnitCanAttack( "player", "target" ) then
                local spell, _, _, startCast, endCast, _, _, notInterruptible, spellID = UnitCastingInfo( unit )

                if spell then
                    startCast = startCast / 1000
                    endCast = endCast / 1000

                    t.name = spell
                    t.count = 1
                    t.expires = endCast
                    t.applied = startCast
                    t.duration = endCast - startCast
                    t.v1 = spellID
                    t.v2 = notInterruptible and 1 or 0
                    t.v3 = 0
                    t.caster = unit

                    if unit == "target" and Hekili.DB.profile.toggles.interrupts.filterCasts then
                        local filters = class.interruptibleFilters
                        local zone = state.instance_id
                        local npcid = state.target.npcid or -1

                        if filters then
                            local interruptible = filters[ zone ][ npcid ][ spellID ]

                            if not interruptible then
                                if Hekili.ActiveDebug then Hekili:Debug( "Cast '%s' not interruptible per user preference.", spell ) end
                                t.v2 = 1
                            elseif interruptible == "testing" then
                                t.v2 = 0
                            end
                        end
                    end

                    return
                end

                spell, _, _, startCast, endCast, _, notInterruptible, spellID = UnitChannelInfo( unit )

                if spell then
                    startCast = startCast / 1000
                    endCast = endCast / 1000

                    t.name = spell
                    t.count = 1
                    t.expires = endCast
                    t.applied = startCast
                    t.duration = endCast - startCast
                    t.v1 = spellID
                    t.v2 = notInterruptible and 1 or 0
                    t.v3 = 1 -- channeled.
                    t.caster = unit

                    if class.abilities[ spellID ] and class.abilities[ spellID ].dontChannel then
                        removeBuff( "casting" )
                    elseif unit == "target" and Hekili.DB.profile.filterCasts then
                        local filters = Hekili.DB.profile.castFilters
                        local zone = state.instance_id
                        local npcid = state.target.npcid or -1

                        if filters then
                            local interruptible = filters[ zone ][ npcid ][ spellID ]

                            if not interruptible then
                                if Hekili.ActiveDebug then Hekili:Debug( "Cast '%s' not interruptible per user preference.", spell ) end
                                t.v2 = 1
                            elseif interruptible == "testing" then
                                t.v2 = 0
                            end
                        end
                    end

                    return
                end
            end

            t.name = "Casting"
            t.count = 0
            t.expires = 0
            t.applied = 0
            t.v1 = 0
            t.v2 = 0
            t.v3 = 0
            t.caster = unit
        end,
    },

    --[[ player_casting = {
        name = "Casting",
        generate = function ()
            local aura = buff.player_casting

            local name, _, _, startCast, endCast, _, _, notInterruptible, spell = UnitCastingInfo( "player" )

            if name then
                aura.name = name
                aura.count = 1
                aura.expires = endCast / 1000
                aura.applied = startCast / 1000
                aura.v1 = spell
                aura.caster = "player"
                return
            end

            name, _, _, startCast, endCast, _, _, notInterruptible, spell = UnitChannelInfo( "player" )

            if notInterruptible == false then
                aura.name = name
                aura.count = 1
                aura.expires = endCast / 1000
                aura.applied = startCast / 1000
                aura.v1 = spell
                aura.caster = "player"
                return
            end

            aura.name = "Casting"
            aura.count = 0
            aura.expires = 0
            aura.applied = 0
            aura.v1 = 0
            aura.caster = "target"
        end,
    }, ]]

    movement = {
        duration = 5,
        max_stack = 1,
        generate = function ()
            local m = buff.movement

            if moving then
                m.count = 1
                m.expires = query_time + 5
                m.applied = query_time
                m.caster = "player"
                return
            end

            m.count = 0
            m.expires = 0
            m.applied = 0
            m.caster = "nobody"
        end,
    },

    repeat_performance = {
        id = 304409,
        duration = 30,
        max_stack = 1,
    },

    -- Why do we have this, again?
    unknown_buff = {},

    berserking = {
        id = 26297,
        duration = 10,
    },

    hyper_organic_light_originator = {
        id = 312924,
        duration = 6,
    },

    blood_fury = {
        id = 20572,
        duration = 15,
    },

    shadowmeld = {
        id = 58984,
        duration = 3600,
    },

    ferocity_of_the_frostwolf = {
        id = 274741,
        duration = 15,
    },

    might_of_the_blackrock = {
        id = 274742,
        duration = 15,
    },

    zeal_of_the_burning_blade = {
        id = 274740,
        duration = 15,
    },

    rictus_of_the_laughing_skull = {
        id = 274739,
        duration = 15,
    },

    ancestral_call = {
        duration = 15,
        alias = { "ferocity_of_the_frostwolf", "might_of_the_blackrock", "zeal_of_the_burning_blade", "rictus_of_the_laughing_skull" },
        aliasMode = "first",
    },

    arcane_pulse = {
        id = 260369,
        duration = 12,
    },

    fireblood = {
        id = 273104,
        duration = 8,
    },

    out_of_range = {
        generate = function ( oor )
            oor.rangeSpell = rawget( oor, "rangeSpell" ) or settings.spec.rangeChecker or class.specs[ state.spec.id ].ranges[ 1 ]

            if LSR.IsSpellInRange( class.abilities[ oor.rangeSpell ].name, "target" ) ~= 1 then
                oor.count = 1
                oor.applied = query_time
                oor.expires = query_time + 3600
                oor.caster = "player"
                oor.v1 = oor.rangeSpell
                return
            end

            oor.count = 0
            oor.applied = 0
            oor.expires = 0
            oor.caster = "nobody"
        end,
    },

    loss_of_control = {
        duration = 10,
        generate = function( t )
            local max_events = GetActiveLossOfControlDataCount()

            if max_events > 0 then
                local spell, start, duration, remains = "none", 0, 0, 0

                for i = 1, max_events do
                    local event = GetActiveLossOfControlData( i )

                    if event.lockoutSchool == 0 and event.startTime and event.startTime > 0 and event.timeRemaining and event.timeRemaining > 0 and event.timeRemaining > remains then
                        spell = event.spellID
                        start = event.startTime
                        duration = event.duration
                        remains = event.timeRemaining
                    end
                end

                if start + duration > query_time then
                    t.count = 1
                    t.expires = start + duration
                    t.applied = start
                    t.duration = duration
                    t.caster = "anybody"
                    t.v1 = spell
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.duration = 10
            t.caster = "nobody"
            t.v1 = 0
        end,
    },

    disoriented = {  -- Disorients (e.g., Polymorph, Dragon’s Breath, Blind)
        duration = 10,
        generate = function( t )
            local max_events = GetActiveLossOfControlDataCount()

            if max_events > 0 then
                local spell, start, duration, remains = "none", 0, 0, 0

                for i = 1, max_events do
                    local event = GetActiveLossOfControlData( i )

                    if event.locType == "CONFUSE"
                        and event.startTime and event.startTime > 0
                        and event.timeRemaining and event.timeRemaining > 0
                        and event.timeRemaining > remains then

                        spell = event.spellID
                        start = event.startTime
                        duration = event.duration
                        remains = event.timeRemaining
                    end
                end

                if start + duration > query_time then
                    t.count = 1
                    t.expires = start + duration
                    t.applied = start
                    t.duration = duration
                    t.caster = "anybody"
                    t.v1 = spell
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.duration = 10
            t.caster = "nobody"
            t.v1 = 0
        end,
    },

    feared = {
        duration = 10,
        generate = function( t )
            local max_events = GetActiveLossOfControlDataCount()

            if max_events > 0 then
                local spell, start, duration, remains = "none", 0, 0, 0

                for i = 1, max_events do
                    local event = GetActiveLossOfControlData( i )

                    if ( event.locType == "FEAR" or event.locType == "FEAR_MECHANIC" or event.locType == "HORROR" )
                        and event.startTime and event.startTime > 0
                        and event.timeRemaining and event.timeRemaining > 0
                        and event.timeRemaining > remains then

                        spell = event.spellID
                        start = event.startTime
                        duration = event.duration
                        remains = event.timeRemaining
                    end
                end

                if start + duration > query_time then
                    t.count = 1
                    t.expires = start + duration
                    t.applied = start
                    t.duration = duration
                    t.caster = "anybody"
                    t.v1 = spell
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.duration = 10
            t.caster = "nobody"
            t.v1 = 0
        end,
    },

    incapacitated = {  -- Effects like Sap, Freezing Trap, Gouge
        duration = 10,
        generate = function( t )
            local max_events = GetActiveLossOfControlDataCount()

            if max_events > 0 then
                local spell, start, duration, remains = "none", 0, 0, 0

                for i = 1, max_events do
                    local event = GetActiveLossOfControlData( i )

                    if event.locType == "STUN"
                        and event.startTime and event.startTime > 0
                        and event.timeRemaining and event.timeRemaining > 0
                        and event.timeRemaining > remains then

                        spell = event.spellID
                        start = event.startTime
                        duration = event.duration
                        remains = event.timeRemaining
                    end
                end

                if start + duration > query_time then
                    t.count = 1
                    t.expires = start + duration
                    t.applied = start
                    t.duration = duration
                    t.caster = "anybody"
                    t.v1 = spell
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.duration = 10
            t.caster = "nobody"
            t.v1 = 0
        end,
        copy = "sapped"
    },

    rooted = {
        duration = 10,
        generate = function( t )
            local max_events = GetActiveLossOfControlDataCount()

            if max_events > 0 then
                local spell, start, duration, remains = "none", 0, 0, 0

                for i = 1, max_events do
                    local event = GetActiveLossOfControlData( i )

                    if event.locType == "ROOT" and event.startTime and event.startTime > 0 and event.timeRemaining and event.timeRemaining > 0 and event.timeRemaining > remains then
                        spell = event.spellID
                        start = event.startTime
                        duration = event.duration
                        remains = event.timeRemaining
                    end
                end

                if start + duration > query_time then
                    t.count = 1
                    t.expires = start + duration
                    t.applied = start
                    t.duration = duration
                    t.caster = "anybody"
                    t.v1 = spell
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.duration = 10
            t.caster = "nobody"
            t.v1 = 0
        end,
    },

    snared = {
        duration = 10,
        generate = function( t )
            local max_events = GetActiveLossOfControlDataCount()

            if max_events > 0 then
                local spell, start, duration, remains = "none", 0, 0, 0

                for i = 1, max_events do
                    local event = GetActiveLossOfControlData( i )

                    if event.locType == "SNARE" and event.startTime and event.startTime > 0 and event.timeRemaining and event.timeRemaining > 0 and event.timeRemaining > remains then
                        spell = event.spellID
                        start = event.startTime
                        duration = event.duration
                        remains = event.timeRemaining
                    end
                end

                if start + duration > query_time then
                    t.count = 1
                    t.expires = start + duration
                    t.applied = start
                    t.duration = duration
                    t.caster = "anybody"
                    t.v1 = spell
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.duration = 10
            t.caster = "nobody"
            t.v1 = 0
        end,
        copy = "slowed"
    },

    stunned = {  -- Shorter stuns (e.g., Kidney Shot, Cheap Shot, Bash)
        duration = 10,
        generate = function( t )
            local max_events = GetActiveLossOfControlDataCount()

            if max_events > 0 then
                local spell, start, duration, remains = "none", 0, 0, 0

                for i = 1, max_events do
                    local event = GetActiveLossOfControlData( i )

                    if event.locType == "STUN_MECHANIC"
                        and event.startTime and event.startTime > 0
                        and event.timeRemaining and event.timeRemaining > 0
                        and event.timeRemaining > remains then

                        spell = event.spellID
                        start = event.startTime
                        duration = event.duration
                        remains = event.timeRemaining
                    end
                end

                if start + duration > query_time then
                    t.count = 1
                    t.expires = start + duration
                    t.applied = start
                    t.duration = duration
                    t.caster = "anybody"
                    t.v1 = spell
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.duration = 10
            t.caster = "nobody"
            t.v1 = 0
        end,
    },

    dispellable_curse = {
        generate = function( t )
            local i = 1
            local name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )

            while( name ) do
                if debuffType == "Curse" then break end

                i = i + 1
                name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )
            end

            if name then
                t.count = count > 0 and count or 1
                t.expires = expirationTime > 0 and expirationTime or query_time + 5
                t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                t.caster = "nobody"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    dispellable_poison = {
        generate = function( t )
            local i = 1
            local name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )

            while( name ) do
                if debuffType == "Poison" then break end

                i = i + 1
                name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )
            end

            if name then
                t.count = count > 0 and count or 1
                t.expires = expirationTime > 0 and expirationTime or query_time + 5
                t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                t.caster = "nobody"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    dispellable_disease = {
        generate = function( t )
            local i = 1
            local name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )

            while( name ) do
                if debuffType == "Disease" then break end

                i = i + 1
                name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )
            end

            if name then
                t.count = count > 0 and count or 1
                t.expires = expirationTime > 0 and expirationTime or query_time + 5
                t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                t.caster = "nobody"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    dispellable_magic = {
        generate = function( t, auraType )
            if auraType == "buff" then
                local i = 1
                local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )

                while( name ) do
                    if debuffType == "Magic" and canDispel then break end

                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )
                end

                if canDispel then
                    t.count = count > 0 and count or 1
                    t.expires = expirationTime > 0 and expirationTime or query_time + 5
                    t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    t.caster = "nobody"
                    return
                end

            else
                local i = 1
                local name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )

                while( name ) do
                    if debuffType == "Magic" then break end

                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )
                end

                if name then
                    t.count = count > 0 and count or 1
                    t.expires = expirationTime > 0 and expirationTime or query_time + 5
                    t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    t.caster = "nobody"
                    return
                end

            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    stealable_magic = {
        generate = function( t )
            if UnitCanAttack( "player", "target" ) then
                local i = 1
                local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )

                while( name ) do
                    if debuffType == "Magic" and canDispel then break end

                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )
                end

                if canDispel then
                    t.count = count > 0 and count or 1
                    t.expires = expirationTime > 0 and expirationTime or query_time + 5
                    t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    t.caster = "nobody"
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    reversible_magic = {
        generate = function( t )
            local i = 1
            local name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )

            while( name ) do
                if debuffType == "Magic" then break end

                i = i + 1
                name, _, count, debuffType, duration, expirationTime = UnitDebuff( "player", i, "RAID" )
            end

            if name then
                t.count = count > 0 and count or 1
                t.expires = expirationTime > 0 and expirationTime or query_time + 5
                t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                t.caster = "nobody"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    dispellable_enrage = {
        generate = function( t )
            if UnitCanAttack( "player", "target" ) then
                local i = 1
                local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )

                while( name ) do
                    if debuffType == "" and canDispel then break end

                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )
                end

                if canDispel then
                    t.count = count > 0 and count or 1
                    t.expires = expirationTime > 0 and expirationTime or query_time + 5
                    t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    t.caster = "nobody"
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },

    all_absorbs = {
        duration = 15,
        max_stack = 1,
        -- TODO: Check if function works.
        generate = function( t, auraType )
            local unit = auraType == "debuff" and "target" or "player"
            local amount = UnitGetTotalAbsorbs( unit )

            if amount > 0 then
                -- t.name = ABSORB
                t.count = 1
                t.expires = now + 10
                t.applied = now - 5
                t.caster = unit
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
        copy = "unravel_absorb"
    },
} )

do
    -- Dragonflight Potions
    -- There are multiple items for each potion, and there are also Toxic potions that people may not want to use.
    local exp_potions = {
        {
            name = "tempered_potion",
            items = { 212971, 212970, 212969, 212265, 212264, 212263 }
        },
        {
            name = "potion_of_unwavering_focus",
            items = { 212965, 212964, 212963, 212259, 212258, 212257 }
        },
        {
            name = "frontline_potion",
            items = { 212968, 212967, 212966, 212262, 212261, 212260 }
        },
        {
            name = "elemental_potion_of_ultimate_power",
            items = { 191914, 191913, 191912, 191383, 191382, 191381 }
        },
        {
            name = "elemental_potion_of_power",
            items = { 191907, 191906, 191905, 191389, 191388, 191387 }
        },
        {
            name = "algari_healing_potion",
            items = { 211878, 211879, 211880 }
        },
        {
            name = "cavedwellers_delight",
            items = { 212242, 212243, 212244 }
        }
    }

    all:RegisterAura( "fake_potion", {
        duration = 30,
        max_stack = 1,
    } )

    local first_potion, first_potion_key
    local potion_items = {}

    all:RegisterHook( "reset_precast", function ()
        wipe( potion_items )
        for _, potion in ipairs( exp_potions ) do
            for _, item in ipairs( potion.items ) do
                if GetItemCount( item, false ) > 0 then
                    potion_items[ potion.name ] = item
                    break
                end
            end
        end
    end )

    all:RegisterAura( "potion", {
        alias = { "fake_potion" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 30
    } )

    local GetItemInfo = C_Item.GetItemInfo

    for _, potion in ipairs( exp_potions ) do
        local potionItem = Item:CreateFromItemID( potion.items[ #potion.items ] )

        -- all:RegisterAbility( potion.name, {} ) -- Create stub.

        potionItem:ContinueOnItemLoad( function()
            all:RegisterAbility( potion.name, {
                name = potionItem:GetItemName(),
                listName = potionItem:GetItemLink(),
                cast = 0,
                cooldown = 300,
                gcd = "off",

                startsCombat = false,
                toggle = "potions",

                item = function ()
                    return potion_items[ potion.name ] or potion.items[ #potion.items ]
                end,
                items = potion.items,
                bagItem = true,
                texture = potionItem:GetItemIcon(),

                handler = function ()
                    applyBuff( potion.name )
                end,
            } )

            class.abilities[ potion.name ] = all.abilities[ potion.name ]

            class.potions[ potion.name ] = {
                name = potionItem:GetItemName(),
                link = potionItem:GetItemLink(),
                item = potion.items[ #potion.items ]
            }

            class.potionList[ potion.name ] = "|T" .. potionItem:GetItemIcon() .. ":0|t |cff00ccff[" .. potionItem:GetItemName() .. "]|r"

            for i, item in ipairs( potion.items ) do
                if not first_potion then
                    first_potion_key = potion.name
                    first_potion = item
                end

                local each_potion = Item:CreateFromItemID( item )

                if not each_potion:IsItemEmpty() then
                    each_potion:ContinueOnItemLoad( function()
                        local _, spell = GetItemSpell( item )

                        if not spell then Hekili:Error( "No spell found for item %d.", item ) return false end

                        if not all.auras[ potion.name ] then
                            all:RegisterAura( potion.name, {
                                id = spell,
                                duration = 30,
                                max_stack = 1,
                                copy = { spell }
                            } )

                            class.auras[ spell ] = all.auras[ potion.name ]
                        else
                            local existing = all.auras[ potion.name ]
                            if not existing.copy then existing.copy = {} end
                            insert( existing.copy, spell )
                            all.auras[ spell ] = all.auras[ potion.name ]
                            class.auras[ spell ] = all.auras[ potion.name ]
                        end

                        return true
                    end )
                else
                    Hekili:Error( "Item %d is empty.", item )
                end
            end
        end )
    end

    all:RegisterAbility( "potion", {
        name = "Potion",
        listName = '|T136243:0|t |cff00ccff[Potion]|r',
        cast = 0,
        cooldown = 300,
        gcd = "off",

        startsCombat = false,
        toggle = "potions",

        consumable = function() return state.args.potion or settings.potion or first_potion_key or "tempered_potion" end,
        item = function()
            if state.args.potion and class.abilities[ state.args.potion ] then return class.abilities[ state.args.potion ].item end
            if spec.potion and class.abilities[ spec.potion ] then return class.abilities[ spec.potion ].item end
            if first_potion and class.abilities[ first_potion ] then return class.abilities[ first_potion ].item end
            return 191387
        end,
        bagItem = true,

        handler = function ()
            local use = all.abilities.potion
            use = use and use.consumable

            if use and use ~= "global_cooldown" then
                class.abilities[ use ].handler()
                setCooldown( use, action[ use ].cooldown )
            end
        end,

        usable = function ()
            return potion_items[ all.abilities.potion.item ], "no valid potions found in inventory"
        end,

        copy = "potion_default"
    } )
end



local gotn_classes = {
    WARRIOR = 28880,
    MONK = 121093,
    DEATHKNIGHT = 59545,
    SHAMAN = 59547,
    HUNTER = 59543,
    PRIEST = 59544,
    MAGE = 59548,
    PALADIN = 59542,
    ROGUE = 370626
}

local baseClass = UnitClassBase( "player" ) or "WARRIOR"

all:RegisterAura( "gift_of_the_naaru", {
    id = gotn_classes[ baseClass ],
    duration = 5,
    max_stack = 1,
    copy = { 28800, 121093, 59545, 59547, 59543, 59544, 59548, 59542, 370626 }
} )

all:RegisterAbility( "gift_of_the_naaru", {
    id = gotn_classes[ baseClass ],
    cast = 0,
    cooldown = 180,
    gcd = "off",

    handler = function ()
        applyBuff( "gift_of_the_naaru" )
    end,
} )


all:RegisterAbilities( {
    global_cooldown = {
        id = 61304,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        unlisted = true,
        known = function () return true end,
    },

    ancestral_call = {
        id = 274738,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        toggle = "cooldowns",

        -- usable = function () return race.maghar_orc end,
        handler = function ()
            applyBuff( "ancestral_call" )
        end,
    },

    arcane_pulse = {
        id = 260364,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        toggle = "cooldowns",

        -- usable = function () return race.nightborne end,
        handler = function ()
            applyDebuff( "target", "arcane_pulse" )
        end,
    },

    berserking = {
        id = 26297,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        toggle = "cooldowns",

        -- usable = function () return race.troll end,
        handler = function ()
            applyBuff( "berserking" )
        end,
    },

    hyper_organic_light_originator = {
        id = 312924,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        toggle = "defensives",

        handler = function ()
            applyBuff( "hyper_organic_light_originator" )
        end
    },

    bag_of_tricks = {
        id = 312411,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        toggle = "cooldowns",
    },

    haymaker = {
        id = 287712,
        cast = 1,
        cooldown = 150,
        gcd = "spell",

        handler = function ()
            if not target.is_boss then applyDebuff( "target", "haymaker" ) end
        end,

        auras = {
            haymaker = {
                id = 287712,
                duration = 3,
                max_stack = 1,
            },
        }
    }
} )


-- Blood Fury spell IDs vary by class (whether you need AP/Int/both).
local bf_classes = {
    DEATHKNIGHT = 20572,
    HUNTER = 20572,
    MAGE = 33702,
    MONK = 33697,
    ROGUE = 20572,
    SHAMAN = 33697,
    WARLOCK = 33702,
    WARRIOR = 20572,
    PRIEST = 33702
}

all:RegisterAbilities( {
    blood_fury = {
        id = function () return bf_classes[ class.file ] or 20572 end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        toggle = "cooldowns",

        -- usable = function () return race.orc end,
        handler = function ()
            applyBuff( "blood_fury", 15 )
        end,

        copy = { 33702, 20572, 33697 },
    },

    arcane_torrent = {
        id = function ()
            if class.file == "PALADIN"      then return 155145 end
            if class.file == "MONK"         then return 129597 end
            if class.file == "DEATHKNIGHT"  then return  50613 end
            if class.file == "WARRIOR"      then return  69179 end
            if class.file == "ROGUE"        then return  25046 end
            if class.file == "HUNTER"       then return  80483 end
            if class.file == "DEMONHUNTER"  then return 202719 end
            if class.file == "PRIEST"       then return 232633 end
            return 28730
        end,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        -- It does start combat if there are enemies in range, but we often use it precombat for resources.
        startsCombat = false,

        -- usable = function () return race.blood_elf end,
        toggle = "cooldowns",

        handler = function ()
            if class.file == "DEATHKNIGHT" then gain( 20, "runic_power" )
            elseif class.file == "HUNTER" then gain( 15, "focus" )
            elseif class.file == "MONK" then gain( 1, "chi" )
            elseif class.file == "PALADIN" then gain( 1, "holy_power" )
            elseif class.file == "ROGUE" then gain( 15, "energy" )
            elseif class.file == "WARRIOR" then gain( 15, "rage" )
            elseif class.file == "DEMONHUNTER" then gain( 15, "fury" )
            elseif class.file == "PRIEST" and state.spec.shadow then gain( 15, "insanity" ) end

            removeBuff( "dispellable_magic" )
        end,

        copy = { 155145, 129597, 50613, 69179, 25046, 80483, 202719, 232633 }
    },

    will_to_survive = {
        id = 59752,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        toggle = "defensives",
    },

    shadowmeld = {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        usable = function ()
            if not boss or solo then return false, "requires boss fight or group (to avoid resetting)" end
            if moving then return false, "can't shadowmeld while moving" end
            return true
        end,

        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    },


    lights_judgment = {
        id = 255647,
        cast = 0,
        cooldown = 150,
        gcd = "spell",

        -- usable = function () return race.lightforged_draenei end,

        toggle = "cooldowns",
    },


    stoneform = {
        id = 20594,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        toggle = "defensives",

        buff = function()
            local aura, remains = "dispellable_poison", buff.dispellable_poison.remains

            for _, effect in pairs( { "dispellable_disease", "dispellable_curse", "dispellable_magic", "dispellable_bleed" } ) do
                local rem = buff[ effect ].remains
                if rem > remains then
                    aura = effect
                    remains = rem
                end
            end

            return aura
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_disease" )
            removeBuff( "dispellable_curse" )
            removeBuff( "dispellable_magic" )
            removeBuff( "dispellable_bleed" )

            applyBuff( "stoneform" )
        end,

        auras = {
            stoneform = {
                id = 65116,
                duration = 8,
                max_stack = 1
            }
        }
    },


    fireblood = {
        id = 265221,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        toggle = "cooldowns",

        -- usable = function () return race.dark_iron_dwarf end,
        handler = function () applyBuff( "fireblood" ) end,
    },


    -- INTERNAL HANDLERS
    call_action_list = {
        name = "|cff00ccff[Call Action List]|r",
        listName = '|T136243:0|t |cff00ccff[Call Action List]|r',
        cast = 0,
        cooldown = 0,
        gcd = "off",
        essential = true,
    },

    run_action_list = {
        name = "|cff00ccff[Run Action List]|r",
        listName = '|T136243:0|t |cff00ccff[Run Action List]|r',
        cast = 0,
        cooldown = 0,
        gcd = "off",
        essential = true,
    },

    wait = {
        name = "|cff00ccff[Wait]|r",
        listName = '|T136243:0|t |cff00ccff[Wait]|r',
        cast = 0,
        cooldown = 0,
        gcd = "off",
        essential = true,
    },

    pool_resource = {
        name = "|cff00ccff[Pool Resource]|r",
        listName = "|T136243:0|t |cff00ccff[Pool Resource]|r",
        cast = 0,
        cooldown = 0,
        gcd = "off",
    },

    cancel_action = {
        name = "|cff00ccff[Cancel Action]|r",
        listName = "|T136243:0|t |cff00ccff[Cancel Action]|r",
        cast = 0,
        cooldown = 0,
        gcd = "off",

        usable = function ()
            local a = args.action_name
            local ability = class.abilities[ a ]
            if not a or not ability then return false, "no action identified" end
            if buff.casting.down or buff.casting.v3 ~= 1 then return false, "not channeling" end
            if buff.casting.v1 ~= ability.id then return false, "not channeling " .. a end
            return true
        end,
        timeToReady = function () return gcd.remains end,
    },

    variable = {
        name = "|cff00ccff[Variable]|r",
        listName = '|T136243:0|t |cff00ccff[Variable]|r',
        cast = 0,
        cooldown = 0,
        gcd = "off",
        essential = true,
    },

    healthstone = {
        name = "Healthstone",
        listName = "|T538745:0|t |cff00ccff[Healthstone]|r",
        cast = 0,
        cooldown = function () return time > 0 and 3600 or 60 end,
        gcd = "off",

        item = function() return talent.pact_of_gluttony.enabled and 224464 or 5512 end,
        items = { 224464, 5512 },
        bagItem = true,

        startsCombat = false,
        texture = function() return talent.pact_of_gluttony.enabled and 538744 or 538745 end,

        usable = function ()
            local item = talent.pact_of_gluttony.enabled and 224464 or 5512
            if GetItemCount( item ) == 0 then return false, "requires healthstone in bags"
            elseif not IsUsableItem( item ) then return false, "healthstone on CD"
            elseif health.current >= health.max then return false, "must be damaged" end
            return true
        end,

        readyTime = function ()
            local start, duration = GetItemCooldown( talent.pact_of_gluttony.enabled and 224464 or 5512 )
            return max( 0, start + duration - query_time )
        end,

        handler = function ()
            gain( 0.25 * health.max, "health" )
        end,
    },

    weyrnstone = {
        name = function () return ( GetItemInfo( 205146 ) ) or "Weyrnstone" end,
        listName = function ()
            local _, link, _, _, _, _, _, _, _, tex = GetItemInfo( 205146 )
            if link and tex then return "|T" .. tex .. ":0|t " .. link end
            return "|cff00ccff[Weyrnstone]|r"
        end,
        cast = 1.5,
        cooldown = 120,
        gcd = "spell",

        item = 205146,
        bagItem = true,

        startsCombat = false,
        texture = 5199618,

        usable = function ()
            if GetItemCount( 205146 ) == 0 then return false, "requires weyrnstone in bags" end
            if solo then return false, "must have an ally to teleport" end
            return true
        end,

        readyTime = function ()
            local start, duration = GetItemCooldown( 205146 )
            return max( 0, start + duration - query_time )
        end,

        handler = function ()
        end,

        copy = { "use_weyrnstone", "active_weyrnstone" }
    },

    cancel_buff = {
        name = "|cff00ccff[Cancel Buff]|r",
        listName = '|T136243:0|t |cff00ccff[Cancel Buff]|r',
        cast = 0,
        gcd = "off",

        startsCombat = false,

        buff = function () return args.buff_name or nil end,

        indicator = "cancel",
        texture = function ()
            if not args.buff_name then return 134400 end

            local a = class.auras[ args.buff_name ]
            -- if not a then return 134400 end
            if a.texture then return a.texture end

            a = a and a.id
            a = a and GetSpellTexture( a )

            return a or 134400
        end,

        usable = function () return args.buff_name ~= nil, "no buff name detected" end,
        timeToReady = function () return gcd.remains end,
        handler = function ()
            if not args.buff_name then return end

            local cancel = args.buff_name and buff[ args.buff_name ]
            cancel = cancel and rawget( cancel, "onCancel" )

            if cancel then
                cancel()
                return
            end

            removeBuff( args.buff_name )
        end,
    },

    null_cooldown = {
        name = "|cff00ccff[Null Cooldown]|r",
        listName = "|T136243:0|t |cff00ccff[Null Cooldown]|r",
        cast = 0,
        cooldown = 0.001,
        gcd = "off",

        startsCombat = false,

        unlisted = true
    },

    trinket1 = {
        name = "|cff00ccff[Trinket #1]|r",
        listName = "|T136243:0|t |cff00ccff[Trinket #1]|r",
        cast = 0,
        cooldown = 600,
        gcd = "off",

        usable = false,

        copy = "actual_trinket1",
    },

    trinket2 = {
        name = "|cff00ccff[Trinket #2]|r",
        listName = "|T136243:0|t |cff00ccff[Trinket #2]|r",
        cast = 0,
        cooldown = 600,
        gcd = "off",

        usable = false,

        copy = "actual_trinket2",
    },

    main_hand = {
        name = "|cff00ccff[" .. INVTYPE_WEAPONMAINHAND .. "]|r",
        listName = "|T136243:0|t |cff00ccff[" .. INVTYPE_WEAPONMAINHAND .. "]|r",
        cast = 0,
        cooldown = 600,
        gcd = "off",

        usable = false,

        copy = "actual_main_hand",
    }
} )


-- Use Items
do
    -- Should handle trinkets/items internally.
    -- 1.  Check APLs and don't try to recommend items that have their own APL entries.
    -- 2.  Respect item preferences registered in spec options.

    all:RegisterAbility( "use_items", {
        name = "Use Items",
        listName = "|T136243:0|t |cff00ccff[Use Items]|r",
        cast = 0,
        cooldown = 120,
        gcd = "off",
    } )

    all:RegisterAbility( "unusable_trinket", {
        name = "Unusable Trinket",
        listName = "|T136240:0|t |cff00ccff[Unusable Trinket]|r",
        cast = 0,
        cooldown = 180,
        gcd = "off",

        usable = false,
        unlisted = true
    } )

    all:RegisterAbility( "heart_essence", {
        name = function () return ( GetItemInfo( 158075 ) ) or "Heart Essence" end,
        listName = function ()
            local _, link, _, _, _, _, _, _, _, tex = GetItemInfo( 158075 )
            if link and tex then return "|T" .. tex .. ":0|t " .. link end
            return "|cff00ccff[Heart Essence]|r"
        end,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        item = 158075,
        essence = true,

        toggle = "essences",

        usable = function () return false, "your equipped major essence is supported elsewhere in the priority or is not an active ability" end
    } )
end


-- x.x - Heirloom Trinket(s)
all:RegisterAbility( "touch_of_the_void", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 128318,
    toggle = "cooldowns",
} )


-- PvP Trinkets
-- Medallions
do
    local pvp_medallions = {
        { "dread_aspirants_medallion", 162897 },
        { "dread_gladiators_medallion", 161674 },
        { "sinister_aspirants_medallion", 165220 },
        { "sinister_gladiators_medallion", 165055 },
        { "notorious_aspirants_medallion", 167525 },
        { "notorious_gladiators_medallion", 167377 },
        { "old_corrupted_gladiators_medallion", 172666 },
        { "corrupted_aspirants_medallion", 184058 },
        { "corrupted_gladiators_medallion", 184055 },
        { "sinful_aspirants_medallion", 184052 },
        { "sinful_gladiators_medallion", 181333 },
        { "unchained_aspirants_medallion", 185309 },
        { "unchained_gladiators_medallion", 185304 },
        { "cosmic_aspirants_medallion", 186966 },
        { "cosmic_gladiators_medallion", 186869 },
        { "eternal_aspirants_medallion", 192412 },
        { "eternal_gladiators_medallion", 192298 },
        { "obsidian_combatants_medallion", 204164 },
        { "obsidian_aspirants_medallion", 205779 },
        { "obsidian_gladiators_medallion", 205711 },
        { "forged_aspirants_medallion", 218422 },
        { "forged_gladiators_medallion", 218716 }
    }

    local pvp_medallions_copy = {}

    for _, v in ipairs( pvp_medallions ) do
        insert( pvp_medallions_copy, v[1] )
        all:RegisterGear( v[1], v[2] )
        all:RegisterGear( "gladiators_medallion", v[2] )
    end

    all:RegisterAbility( "gladiators_medallion", {
        name = function ()
            local data = GetSpellInfo( 277179 )
            return data and data.name or "Gladiator's Medallion"
        end,
        listName = function ()
            local data = GetSpellInfo( 277179 )
            if data and data.iconID then return "|T" .. data.iconID .. ":0|t " .. ( GetSpellLink( 277179 ) ) end
        end,
        link = function () return ( GetSpellLink( 277179 ) ) end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = function ()
            local m
            for _, medallion in ipairs( pvp_medallions ) do
                m = medallion[ 2 ]
                if equipped[ m ] then return m end
            end
            return m
        end,
        items = { 161674, 162897, 165055, 165220, 167377, 167525, 181333, 184052, 184055, 172666, 184058, 185309, 185304, 186966, 186869, 192412, 192298, 204164, 205779, 205711, 205779, 205711, 218422, 218716 },
        toggle = "defensives",

        usable = function () return debuff.loss_of_control.up, "requires loss of control effect" end,

        handler = function ()
            applyBuff( "gladiators_medallion" )
        end,

        copy = pvp_medallions_copy
    } )

    all:RegisterAura( "gladiators_medallion", {
        id = 277179,
        duration = 20,
        max_stack = 1
    } )
end

-- Badges
do
    local pvp_badges = {
        { "dread_aspirants_badge", 162966 },
        { "dread_gladiators_badge", 161902 },
        { "sinister_aspirants_badge", 165223 },
        { "sinister_gladiators_badge", 165058 },
        { "notorious_aspirants_badge", 167528 },
        { "notorious_gladiators_badge", 167380 },
        { "corrupted_aspirants_badge", 172849 },
        { "corrupted_gladiators_badge", 172669 },
        { "sinful_aspirants_badge_of_ferocity", 175884 },
        { "sinful_gladiators_badge_of_ferocity", 175921 },
        { "unchained_aspirants_badge_of_ferocity", 185161 },
        { "unchained_gladiators_badge_of_ferocity", 185197 },
        { "cosmic_aspirants_badge_of_ferocity", 186906 },
        { "cosmic_gladiators_badge_of_ferocity", 186866 },
        { "eternal_aspirants_badge_of_ferocity", 192352 },
        { "eternal_gladiators_badge_of_ferocity", 192295 },
        { "crimson_aspirants_badge_of_ferocity", 201449 },
        { "crimson_gladiators_badge_of_ferocity", 201807 },
        { "obsidian_aspirants_badge_of_ferocity", 205778 },
        { "obsidian_gladiator_badge_of_ferocity", 205708 },
        { "verdant_aspirants_badge_of_ferocity", 209763 },
        { "verdant_gladiators_badge_of_ferocity", 209343 },
        { "forged_aspirants_badge_of_ferocity", 218421 },
        { "forged_gladiators_badge_of_ferocity", 218713 },
        { "prized_aspirants_badge_of_ferocity", 229491 },
        { "prized_gladiators_badge_of_ferocity", 229780 }
    }

    local pvp_badges_copy = {}

    for _, v in ipairs( pvp_badges ) do
        insert( pvp_badges_copy, v[1] )
        all:RegisterGear( v[1], v[2] )
        all:RegisterGear( "gladiators_badge", v[2] )
    end

    all:RegisterAbility( "gladiators_badge", {
        name = function ()
            local data = GetSpellInfo( 277185 )
            return data and data.name or "Gladiator's Badge"
        end,
        listName = function ()
            local data = GetSpellInfo( 277185 )
            if data and data.iconID then return "|T" .. data.iconID .. ":0|t " .. ( GetSpellLink( 277185 ) ) end
        end,
        link = function () return ( GetSpellLink( 277185 ) ) end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 162966, 161902, 165223, 165058, 167528, 167380, 172849, 172669, 175884, 175921, 185161, 185197, 186906, 186866, 192352, 192295, 201449, 201807, 205778, 205708, 209763, 209343, 218421, 218713, 229491, 229780 },
        texture = 135884,

        toggle = "cooldowns",
        item = function ()
            local b

            for i = #pvp_badges, 1, -1 do
                b = pvp_badges[ i ][ 2 ]
                if equipped[ b ] then
                    break
                end
            end
            return b
        end,

        usable = function () return set_bonus.gladiators_badge > 0, "requires Gladiator's Badge" end,
        handler = function ()
            applyBuff( "gladiators_badge" )
        end,

        copy = pvp_badges_copy
    } )

    all:RegisterAura( "gladiators_badge", {
        id = 277185,
        duration = 15,
        max_stack = 1
    } )
end


-- Insignias -- N/A, not on-use.
all:RegisterAura( "gladiators_insignia", {
    id = 277181,
    duration = 20,
    max_stack = 1,
    copy = 345230
} )


-- Safeguard (equipped, not on-use)
all:RegisterAura( "gladiators_safeguard", {
    id = 286342,
    duration = 10,
    max_stack = 1
} )


-- Emblems
do
    local pvp_emblems = {
        -- dread_combatants_emblem = 161812,
        dread_aspirants_emblem = 162898,
        dread_gladiators_emblem = 161675,
        sinister_aspirants_emblem = 165221,
        sinister_gladiators_emblem = 165056,
        notorious_gladiators_emblem = 167378,
        notorious_aspirants_emblem = 167526,
        corrupted_gladiators_emblem = 172667,
        corrupted_aspirants_emblem = 172847,
        sinful_aspirants_emblem = 178334,
        sinful_gladiators_emblem = 178447,
        unchained_aspirants_emblem = 185242,
        unchained_gladiators_emblem = 185282,
        cosmic_aspirants_emblem = 186946,
        cosmic_gladiators_emblem = 186868,
        eternal_aspirants_emblem = 192392,
        eternal_gladiators_emblem = 192297,
        crimson_aspirants_emblem = 201452,
        crimson_gladiators_emblem = 201809,
        obsidian_combatants_emblem = 204166,
        obsidian_aspirants_emblem = 205781,
        obsidian_gladiators_emblem = 205710,
        verdant_aspirants_emblem = 209766,
        verdant_combatants_emblem = 208309,
        verdant_gladiators_emblem = 209345,
        algari_competitors_emblem = 219933,
        forged_gladiators_emblem = 218715,
        prized_aspirants_emblem = 229494,
        prized_gladiators_emblem = 229782
    }

    local pvp_emblems_copy = {}

    for k, v in pairs( pvp_emblems ) do
        insert( pvp_emblems_copy, k )
        all:RegisterGear( k, v )
        all:RegisterGear( "gladiators_emblem", v )
    end


    all:RegisterAbility( "gladiators_emblem", {
        name = function ()
            local data = GetSpellInfo( 277187 )
            return data and data.name or "Gladiator's Emblem"
        end,
        listName = function ()
            local data = GetSpellInfo( 277187 )
            if data and data.iconID then return "|T" .. data.iconID .. ":0|t " .. ( GetSpellLink( 277187 ) ) end
        end,
        link = function () return ( GetSpellLink( 277187 ) ) end,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = function ()
            local e
            for _, emblem in pairs( pvp_emblems ) do
                e = emblem
                if equipped[ e ] then return e end
            end
            return e
        end,
        items = { 162898, 161675, 165221, 165056, 167378, 167526, 172667, 172847, 178334, 178447, 185242, 185282, 186946, 186868, 192392, 192297, 201452, 201809, 204166, 205781, 205710, 209766, 208309, 209345, 219933, 218715, 229494, 229782 },
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "gladiators_emblem" )
        end,

        copy = pvp_emblems_copy
    } )

    all:RegisterAura( "gladiators_emblem", {
        id = 277187,
        duration = 15,
        max_stack = 1,
    } )
end


-- 8.3 Corrupted On-Use

-- DNI, because potentially you have no enemies w/ Corruption w/in range.
--[[
    all:RegisterAbility( "corrupted_gladiators_breach", {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 174276,
        toggle = "defensives",

        handler = function ()
            applyBuff( "void_jaunt" )
            -- +Debuff?
        end,

        auras = {
            void_jaunt = {
                id = 314517,
                duration = 6,
                max_stack = 1,
            }
        }
} )
]]


all:RegisterAbility( "corrupted_gladiators_spite", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 174472,
    toggle = "cooldowns",

    handler = function ()
        applyDebuff( "target", "gladiators_spite" )
        applyDebuff( "target", "lingering_spite" )
    end,

    auras = {
        gladiators_spite = {
            id = 315391,
            duration = 15,
            max_stack = 1,
        },

        lingering_spite = {
            id = 320297,
            duration = 3600,
            max_stack = 1,
        }
    }
} )


all:RegisterAbility( "corrupted_gladiators_maledict", {
    cast = 0,
    cooldown = 120,
    gcd = "off", -- ???

    item = 172672,
    toggle = "cooldowns",

    handler = function ()
        applyDebuff( "target", "gladiators_maledict" )
    end,

    auras = {
        gladiators_maledict = {
            id = 305252,
            duration = 6,
            max_stack = 1
        }
    }
} )


-- BREWFEST
all:RegisterAbility( "brawlers_statue", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 117357,
    toggle = "defensives",

    handler = function ()
        applyBuff( "drunken_evasiveness" )
    end
} )

all:RegisterAura( "drunken_evasiveness", {
    id = 127967,
    duration = 20,
    max_stack = 1
} )


-- HALLOW'S END
all:RegisterAbility( "the_horsemans_sinister_slicer", {
    cast = 0,
    cooldown = 600,
    gcd = "off",

    item = 117356,
    toggle = "cooldowns",
} )


ns.addToggle = function( name, default, optionName, optionDesc )

    table.insert( class.toggles, {
        name = name,
        state = default,
        option = optionName,
        oDesc = optionDesc
    } )

    if Hekili.DB.profile[ 'Toggle State: ' .. name ] == nil then
        Hekili.DB.profile[ 'Toggle State: ' .. name ] = default
    end

end


ns.addSetting = function( name, default, options )

    table.insert( class.settings, {
        name = name,
        state = default,
        option = options
    } )

    if Hekili.DB.profile[ 'Class Option: ' .. name ] == nil then
        Hekili.DB.profile[ 'Class Option: ' ..name ] = default
    end

end


ns.addWhitespace = function( name, size )

    table.insert( class.settings, {
        name = name,
        option = {
            name = " ",
            type = "description",
            desc = " ",
            width = size
        }
    } )

end


ns.addHook = function( hook, func )
    insert( class.hooks[ hook ], func )
end


do
    local inProgress = {}
    local vars = {}

    local function load_args( ... )
        local count = select( "#", ... )
        if count == 0 then return end

        for i = 1, count do
            vars[ i ] = select( i, ... )
        end
    end

    ns.callHook = function( event, ... )
        if not class.hooks[ event ] or inProgress[ event ] then return ... end
        wipe( vars )
        load_args( ... )

        inProgress[ event ] = true
        for i, hook in ipairs( class.hooks[ event ] ) do
            load_args( hook( unpack( vars ) ) )
        end
        inProgress[ event ] = nil

        return unpack( vars )
    end
end


ns.registerCustomVariable = function( var, default )
    state[ var ] = default
end




ns.setClass = function( name )
    -- deprecated.
    --class.file = name
end


function ns.setRange( value )
    class.range = value
end


local function storeAbilityElements( key, values )

    local ability = class.abilities[ key ]

    if not ability then
        ns.Error( "storeAbilityElements( " .. key .. " ) - no such ability in abilities table." )
        return
    end

    for k, v in pairs( values ) do
        ability.elem[ k ] = type( v ) == "function" and setfenv( v, state ) or v
    end

end
ns.storeAbilityElements = storeAbilityElements


local function modifyElement( t, k, elem, value )

    local entry = class[ t ][ k ]

    if not entry then
        ns.Error( "modifyElement() - no such key '" .. k .. "' in '" .. t .. "' table." )
        return
    end

    if type( value ) == "function" then
        entry.mods[ elem ] = setfenv( value, Hekili.State )
    else
        entry.elem[ elem ] = value
    end

end
ns.modifyElement = modifyElement



local function setUsableItemCooldown( cd )
    state.setCooldown( "usable_items", cd or 10 )
end


-- For Trinket Settings.
class.itemSettings = {}

local function addItemSettings( key, itemID, options )

    options = options or {}

    --[[ options.icon = {
        type = "description",
        name = function () return select( 2, GetItemInfo( itemID ) ) or format( "[%d]", itemID )  end,
        order = 1,
        image = function ()
            local tex = select( 10, GetItemInfo( itemID ) )
            if tex then
                return tex, 50, 50
            end
            return nil
        end,
        imageCoords = { 0.1, 0.9, 0.1, 0.9 },
        width = "full",
        fontSize = "large"
    } ]]

    options.disabled = {
        type = "toggle",
        name = function () return format( "Disable %s via |cff00ccff[Use Items]|r", select( 2, GetItemInfo( itemID ) ) or ( "[" .. itemID .. "]" ) ) end,
        desc = function( info )
            local output = "If disabled, the addon will not recommend this item via the |cff00ccff[Use Items]|r action.  " ..
                "You can still manually include the item in your action lists with your own tailored criteria."
            return output
        end,
        order = 25,
        width = "full"
    }

    options.minimum = {
        type = "range",
        name = "Minimum Targets",
        desc = "The addon will only recommend this trinket (via |cff00ccff[Use Items]|r) when there are at least this many targets available to hit.",
        order = 26,
        width = "full",
        min = 1,
        max = 10,
        step = 1
    }

    options.maximum = {
        type = "range",
        name = "Maximum Targets",
        desc = "The addon will only recommend this trinket (via |cff00ccff[Use Items]|r) when there are no more than this many targets detected.\n\n" ..
            "This setting is ignored if set to 0.",
        order = 27,
        width = "full",
        min = 0,
        max = 10,
        step = 1
    }

    class.itemSettings[ itemID ] = {
        key = key,
        name = function () return select( 2, GetItemInfo( itemID ) ) or ( "[" .. itemID .. "]" ) end,
        item = itemID,
        options = options,
    }

end


--[[ local function addUsableItem( key, id )
    class.items = class.items or {}
    class.items[ key ] = id

    addGearSet( key, id )
    addItemSettings( key, id )
end
ns.addUsableItem = addUsableItem ]]


function Hekili:GetAbilityInfo( index )

    local ability = class.abilities[ index ]

    if not ability then return end

    -- Decide if more details are needed later.
    return ability.id, ability.name, ability.key, ability.item
end

class.interrupts = {}


local function addPet( key, permanent )
    state.pet[ key ] = rawget( state.pet, key ) or {}
    state.pet[ key ].name = key
    state.pet[ key ].expires = 0

    ns.commitKey( key )
end
ns.addPet = addPet


local function addStance( key, spellID )
    class.stances[ key ] = spellID
    ns.commitKey( key )
end
ns.addStance = addStance


local function setRole( key )

    for k,v in pairs( state.role ) do
        state.role[ k ] = nil
    end

    state.role[ key ] = true

end
ns.setRole = setRole


function Hekili:GetActiveSpecOption( opt )
    if not self.currentSpecOpts then return end
    return self.currentSpecOpts[ opt ]
end


function Hekili:GetActivePack()
    return self:GetActiveSpecOption( "package" )
end


Hekili.SpecChangeHistory = {}

function Hekili:SpecializationChanged()
    local currentSpec = GetSpecialization()
    local currentID = GetSpecializationInfo( currentSpec )

    if currentID == nil then
        self.PendingSpecializationChange = true
        return
    end

    self.PendingSpecializationChange = false
    self:ForceUpdate( "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" )

    insert( self.SpecChangeHistory, {
        spec = currentID,
        time = GetTime(),
        bt = debugstack()
    } )

    for k, _ in pairs( state.spec ) do
        state.spec[ k ] = nil
    end

    for key in pairs( GetResourceInfo() ) do
        state[ key ] = nil
        class[ key ] = nil
    end

    class.primaryResource = nil

    wipe( state.buff )
    wipe( state.debuff )

    wipe( class.auras )
    wipe( class.abilities )
    wipe( class.hooks )
    wipe( class.talents )
    wipe( class.pvptalents )
    wipe( class.powers )
    wipe( class.gear )
    wipe( class.setBonuses )
    wipe( class.packs )
    wipe( class.resources )
    wipe( class.resourceAuras )

    wipe( class.pets )

    local specs = {}

    -- If the player does not have a specialization, use their first spec instead.
    if currentSpec == 5 then
        currentSpec = 1
        currentID = GetSpecializationInfo( 1 )
    end

    for i = 1, 4 do
        local id, name, _, _, role, primaryStat = GetSpecializationInfo( i )

        if not id then break end

        if i == currentSpec then
            insert( specs, 1, id )

            state.spec.id = id
            state.spec.name = name
            state.spec.key = getSpecializationKey( id )

            for k in pairs( state.role ) do
                state.role[ k ] = false
            end

            if role == "DAMAGER" then
                state.role.attack = true
            elseif role == "TANK" then
                state.role.tank = true
            else
                state.role.healer = true
            end

            if primaryStat == 1 then
                state.spec.primaryStat = "strength"
            elseif primaryStat == 2 then
                state.spec.primaryStat = "agility"
            else
                state.spec.primaryStat = "intellect"
            end

            state.spec[ state.spec.key ] = true
        else
            insert( specs, id )
        end
    end

    insert( specs, 0 )


    for key in pairs( GetResourceInfo() ) do
        state[ key ] = nil
        class[ key ] = nil
    end
    if rawget( state, "rune" ) then state.rune = nil; class.rune = nil; end

    for k in pairs( class.resourceAuras ) do
        class.resourceAuras[ k ] = nil
    end

    class.primaryResource = nil

    for k in pairs( class.stateTables ) do
        rawset( state, k, nil )
        class.stateTables[ k ] = nil
    end

    for k in pairs( class.stateFuncs ) do
        rawset( state, k, nil )
        class.stateFuncs[ k ] = nil
    end

    for k in pairs( class.stateExprs ) do
        class.stateExprs[ k ] = nil
    end

    self.currentSpec = nil
    self.currentSpecOpts = nil

    for i, specID in ipairs( specs ) do
        local spec = class.specs[ specID ]

        if spec then
            if specID == currentID then
                self.currentSpec = spec
                self.currentSpecOpts = rawget( self.DB.profile.specs, specID )
                state.settings.spec = self.currentSpecOpts

                state.spec.can_dual_cast = spec.can_dual_cast
                state.spec.dual_cast = spec.dual_cast

                for res, model in pairs( spec.resources ) do
                    class.resources[ res ] = model
                    state[ res ] = model.state
                end
                if rawget( state, "runes" ) then state.rune = state.runes end

                for k,v in pairs( spec.resourceAuras ) do
                    class.resourceAuras[ k ] = v
                end

                class.primaryResource = spec.primaryResource

                for talent, id in pairs( spec.talents ) do
                    class.talents[ talent ] = id
                end

                for talent, id in pairs( spec.pvptalents ) do
                    class.pvptalents[ talent ] = id
                end

                class.variables = spec.variables

                class.potionList.default = "|T967533:0|t |cFFFFD100Default|r"
            end

            if specID == currentID or specID == 0 then
                for event, hooks in pairs( spec.hooks ) do
                    for _, hook in ipairs( hooks ) do
                        class.hooks[ event ] = class.hooks[ event ] or {}
                        insert( class.hooks[ event ], hook )
                    end
                end
            end

            for res, model in pairs( spec.resources ) do
                if not class.resources[ res ] then
                    class.resources[ res ] = model
                    state[ res ] = model.state
                end
            end

            if rawget( state, "runes" ) then state.rune = state.runes end

            for k, v in pairs( spec.auras ) do
                if not class.auras[ k ] then class.auras[ k ] = v end
            end

            for k, v in pairs( spec.powers ) do
                if not class.powers[ k ] then class.powers[ k ] = v end
            end

            for k, v in pairs( spec.abilities ) do
                if not class.abilities[ k ] then class.abilities[ k ] = v end
            end

            for k, v in pairs( spec.gear ) do
                if not class.gear[ k ] then class.gear[ k ] = v end
            end

            for k, v in pairs( spec.setBonuses ) do
                if not class.setBonuses[ k ] then class.setBonuses[ k ] = v end
            end

            for k, v in pairs( spec.pets ) do
                if not class.pets[ k ] then class.pets[ k ] = v end
            end

            for k, v in pairs( spec.totems ) do
                if not class.totems[ k ] then class.totems[ k ] = v end
            end

            for k, v in pairs( spec.packs ) do
                if not class.packs[ k ] then class.packs[ k ] = v end
            end

            for name, func in pairs( spec.stateExprs ) do
                if not class.stateExprs[ name ] then
                    if rawget( state, name ) then state[ name ] = nil end
                    class.stateExprs[ name ] = func
                end
            end

            for name, func in pairs( spec.stateFuncs ) do
                if not class.stateFuncs[ name ] then
                    if rawget( state, name ) then
                        Hekili:Error( "Cannot RegisterStateFunc for an existing expression ( " .. spec.name .. " - " .. name .. " )." )
                    else
                        class.stateFuncs[ name ] = func
                        rawset( state, name, func )
                        -- Hekili:Error( "Not real error, registered " .. name .. " for " .. spec.name .. " (RSF)." )
                    end
                end
            end

            for name, t in pairs( spec.stateTables ) do
                if not class.stateTables[ name ] then
                    if rawget( state, name ) then
                        Hekili:Error( "Cannot RegisterStateTable for an existing expression ( " .. spec.name .. " - " .. name .. " )." )
                    else
                        class.stateTables[ name ] = t
                        rawset( state, name, t )
                        -- Hekili:Error( "Not real error, registered " .. name .. " for " .. spec.name .. " (RST)." )
                    end
                end
            end

            if spec.id > 0 then
                local s = rawget( Hekili.DB.profile.specs, spec.id )

                if s then
                    for k, v in pairs( spec.settings ) do
                        if s.settings[ v.name ] == nil then s.settings[ v.name ] = v.default end
                    end
                end
            end
        end
    end

    for k in pairs( class.abilityList ) do
        local ability = class.abilities[ k ]

        if ability and ability.id > 0 then
            if not ability.texture or not ability.name then
                local data = GetSpellInfo( ability.id )

                if data and data.name and data.iconID then
                    ability.name = ability.name or data.name
                    class.abilityList[ k ] = "|T" .. data.iconID .. ":0|t " .. ability.name
                end
            else
                class.abilityList[ k ] = "|T" .. ability.texture .. ":0|t " .. ability.name
            end
        end
    end

    state.GUID = UnitGUID( "player" )
    state.player.unit = UnitGUID( "player" )

    ns.callHook( "specializationChanged" )

    ns.updateTalents()
    ResetDisabledGearAndSpells()

    state.swings.mh_speed, state.swings.oh_speed = UnitAttackSpeed( "player" )

    HekiliEngine.activeThread = nil
    self:UpdateDisplayVisibility()
    self:UpdateDamageDetectionForCLEU()
end


do
    RegisterEvent( "PLAYER_ENTERING_WORLD", function( event, login, reload )
        if login or reload then
            local currentSpec = GetSpecialization()
            local currentID = GetSpecializationInfo( currentSpec )

            if currentID ~= state.spec.id then
                Hekili:SpecializationChanged()
            end
        end
    end )

    local SpellDisableEvents = {
        CHALLENGE_MODE_START = 1,
        CHALLENGE_MODE_RESET = 1,
        CHALLENGE_MODE_COMPLETED = 1,
        PLAYER_ALIVE = 1,
        ZONE_CHANGED_NEW_AREA = 1,
        QUEST_SESSION_CREATED = 1,
        QUEST_SESSION_DESTROYED = 1,
        QUEST_SESSION_ENABLED_STATE_CHANGED = 1,
        QUEST_SESSION_JOINED = 1,
        QUEST_SESSION_LEFT = 1
    }

    local WipeCovenantCache = ns.WipeCovenantCache

    local function CheckSpellsAndGear()
        WipeCovenantCache()
        ResetDisabledGearAndSpells()
        ns.updateGear()
    end

    for k in pairs( SpellDisableEvents ) do
        RegisterEvent( k, function( event )
            C_Timer.After( 1, CheckSpellsAndGear )
        end )
    end
end


class.trinkets = {
    [0] = { -- for when nothing is equipped.
    },
}


setmetatable( class.trinkets, {
    __index = function( t, k )
    return t[0]
end
} )