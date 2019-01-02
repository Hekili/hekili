-- Classes.lua
-- July 2014


--[[ TODO FOR 8.1
     - Check APLs for DKs, DHs, Druids. ]]


local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local CommitKey = ns.commitKey

local GetItemInfo = ns.CachedGetItemInfo
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local GetResourceInfo, GetResourceID, GetResourceKey = ns.GetResourceInfo, ns.GetResourceID, ns.GetResourceKey
local RegisterEvent = ns.RegisterEvent

local getSpecializationKey = ns.getSpecializationKey
local tableCopy = ns.tableCopy

local mt_resource = ns.metatables.mt_resource

local upper = string.upper
local wipe = table.wipe



local specTemplate = {
    enabled = false,

    potion = "prolonged_power",

    aoe = 2,
    cycle = false,
    gcdSync = true,

    buffPadding = 0,
    debuffPadding = 0,
    
    nameplates = true,
    nameplateRange = 8,

    buffPadding = 0.25,
    debuffPadding = 0,
    
    damage = true,
    damageExpiration = 8,
    damageDots = false,

    throttleRefresh = false,
    maxRefresh = 10,
}


local function Aura_DetectSharedAura( t, type )
    if not t then return end
    local finder = type == "debuff" and FindUnitDebuffByID or FindUnitBuffByID
    local aura = class.auras[ t.key ]

    local name, icon, count, debuffType, duration, expirationTime, caster = finder( aura.shared, aura.id )

    if name then
        t.count = count > 0 and count or 1
        t.applied = expirationTime - duration
        t.expires = expirationTime
        t.caster = caster
        return
    end

    t.count = 0
    t.applied = 0
    t.expires = 0
    t.caster = "nobody"
end


local HekiliSpecMixin = {
    RegisterResource = function( self, resourceID, regen, model )
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
            type = power_type,

            forecast = {},
            fcount = 0,
            times = {},
            values = {},
            
            active_regen = 0,
            inactive_regen = 0,
            last_tick = 0,

            timeTo = function( x )
                return state:TimeToResource( r.state, x )
            end,
        }, mt_resource )
        r.state.regenModel = regen

        if model and not model.timeTo then
            model.timeTo = function( x )
                return state:TimeToResource( r.state, x )
            end
        end

        if r.state.regenModel then
            for k, v in pairs( r.state.regenModel ) do
                v.resource = v.resoure or resource
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
                return
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
        if data.shared then
            a.generate = Aura_DetectSharedAura
        end            

        for element, value in pairs( data ) do
            if type( value ) == 'function' then
                setfenv( value, state )
                if element ~= 'generate' then a.funcs[ element ] = value
                else a[ element ] = value end
            else
                a[ element ] = value
            end
        end

        self.auras[ aura ] = a

        if a.id then
            if a.id > 0 then
                local spell = Spell:CreateFromSpellID( a.id )
                if not spell:IsSpellEmpty() then
                    spell:ContinueOnSpellLoad( function ()
                        a.name = spell:GetSpellName()
                        a.desc = GetSpellDescription( a.id )

                        if not a.funcs.texture then
                            a.texture = a.texture or GetSpellTexture( a.id )
                        end

                        self.auras[ a.name ] = a
                        if GetSpecializationInfo( GetSpecialization() or 0 ) == self.id then
                            -- Copy to class table as well.
                            class.auras[ a.name ] = a
                        end
                    end )
                end
            end
            self.auras[ a.id ] = a
        end

        if data.meta then
            for k, v in pairs( data.meta ) do
                if type( v ) == 'function' then data.meta[ k ] = setfenv( v, state ) end
            end
        end

        if type( data.copy ) == 'string' then
            self.auras[ data.copy ] = a
        elseif type( data.copy ) == 'table' then
            for _, key in ipairs( data.copy ) do
                self.auras[ key ] = a
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

        if auras and type( aura ) == "table" then
            self:RegisterAura( power, aura )
        end
    end,

    RegisterPowers = function( self, powers )
        for k, v in pairs( powers ) do
            self.powers[ k ] = v.id
            self.powers[ v.id ] = k

            for token, ids in pairs( v.triggers ) do
                if not self.auras[ k ] then
                    self:RegisterAura( token, {
                        id = v.id,
                        copy = ids
                    } )
                end
            end
        end
    end,


    RegisterStateExpr = function( self, key, func )
        --[[ if rawget( state, key ) then
            Hekili:Error( "Cannot overwrite an existing value/table with RegisterStateExpr (" .. key .. ")." )
            return
        end ]]

        setfenv( func, state )
        self.stateExprs[ key ] = func
        class.stateExprs[ key ] = func

        --[[ if rawget( state, key ) == nil then
            class.stateExprs[ key ] = func
            rawset( state, key, func ) 
        end -- to prevent errors at login ]]
    end,

    RegisterStateFunction = function( self, key, func )
        --[[ if rawget( state, key ) then
            Hekili:Error( "Cannot overwrite an existing value/table with RegisterStateFunction." )
            return
        end ]]

        setfenv( func, state )
        self.stateFuncs[ key ] = func
        class.stateFuncs[ key ] = func

        --[[ if rawget( state, key ) == nil then
            class.stateFuncs[ key ] = func
            rawset( state, key, func )
        end -- to prevent errors at login ]]
    end,

    RegisterStateTable = function( self, key, data )
        --[[ if rawget( state, key ) then
            Hekili:Error( "Cannot overwrite an existing table with RegisterStateTable (" .. key .. ")." )
            return
        end ]]

        for k, f in pairs( data ) do
            if type( f ) == 'function' then
                setfenv( f, state )
            end
        end

        local meta = getmetatable( data )

        if meta and meta.__index then
            setfenv( meta.__index, state )
        end

        self.stateTables[ key ] = data
        class.stateTables[ key ] = data

        --[[ if rawget( state, key ) == nil then
            class.stateTables[ key ] = data
            rawset( state, key, data )
        end ]]
    end,

    RegisterGear = function( self, key, ... )
        local n = select( "#", ... )

        local gear = self.gear[ key ] or {}

        for i = 1, n do
            local item = select( i, ... )
    
            table.insert( gear, item )
            gear[ item ] = true
        end
    
        self.gear[ key ] = gear
    end,

    RegisterPotion = function( self, potion, data )
        self.potions[ potion ] = data

        if data.copy then
            if type( data.copy ) == "table" then
                for i, key in ipairs( data.copy ) do
                    self.potions[ key ] = data
                end
            else
                self.potions[ data.copy ] = data
            end
        end

        Hekili:ContinueOnItemLoad( data.item, function ()
            local name, link = GetItemInfo( data.item )

            data.name = name
            data.link = link

            class.potionList[ potion ] = link
        end )
    end,

    RegisterPotions = function( self, potions )
        for k, v in pairs( potions ) do
            self:RegisterPotion( k, v )
        end
    end,

    SetPotion = function( self, potion )
        -- if not class.potions[ potion ] then return end
        self.potion = potion
    end,

    RegisterHook = function( self, hook, func )
        self.hooks[ hook ] = self.hooks[ hook ] or {}
        self.hooks[ hook ] = setfenv( func, state )
    end,
    
    RegisterAbility = function( self, ability, data )
        CommitKey( ability )

        local a = setmetatable( {
            funcs = {},
        }, {
            __index = function( t, k )
                if t.funcs[ k ] then return t.funcs[ k ]() end
                return
            end
        } )

        a.key = ability

        if not data.id then
            if data.item then
                self.itemAbilities = self.itemAbilities + 1
                data.id = -100 - self.itemAbilities
            else
                self.pseudoAbilities = self.pseudoAbilities + 1
                data.id = -1000 * self.id - self.pseudoAbilities
            end
        end

        if data.item then
            local name, link, _, _, _, _, _, _, _, texture = GetItemInfo( data.item )

            a.name = name or ability
            a.link = link or ability
            a.texture = texture or "Interface\\ICONS\\Spell_Nature_BloodLust"

            class.itemMap[ data.item ] = ability

            Hekili:ContinueOnItemLoad( data.item, function( success )
                if not success then
                    -- Assume the item is not presently in-game.
                    for key, entry in pairs( class.abilities ) do
                        if a == entry then
                            class.abilities[ key ] = nil
                            class.abilityList[ key ] = nil
                            class.itemList[ key ] = nil

                            self.abilities[ key ] = nil
                            self.abilityList[ key ] = nil
                            self.itemList[ key ] = nil
                        end
                    end

                    return
                end

                local name, link, _, _, _, _, _, _, _, texture = GetItemInfo( data.item )

                if name then
                    a.name = name
                    a.link = link
                    a.texture = texture

                    if a.suffix then
                        a.actualName = name
                        a.name = a.name .. " " .. a.suffix
                    end
                    
                    self.abilities[ ability ] = self.abilities[ ability ] or a
                    self.abilities[ a.name ] = self.abilities[ a.name ] or a
                    self.abilities[ a.link ] = self.abilities[ a.link ] or a
                    self.abilities[ a.id ] = self.abilities[ a.link ] or a

                    if not a.unlisted then 
                        class.abilityList[ ability ] = "|T" .. texture .. ":0|t " .. link
                        class.itemList[ data.item ] = "|T" .. texture .. ":0|t " .. link 
                    end

                    class.abilities[ ability ] = a
                    class.abilities[ a.name ] = a
                    class.abilities[ a.link ] = a
                    class.abilities[ a.id ] = a

                    Hekili:EmbedItemOptions()
                
                    return true
                end

                return false
            end )
        end

        if data.meta then
            for k, v in pairs( data.meta ) do
                if type( v ) == 'function' then data.meta[ k ] = setfenv( v, state ) end
            end
        end

        -- default values.
        -- none.
        if not data.cooldown then data.cooldown = 0 end
        if not data.recharge then data.recharge = data.cooldown end
        if not data.charges  then data.charges = 1 end

        if data.hasteCD then
            if type( data.cooldown ) == "number" and data.cooldown > 0 then data.cooldown = loadstring( "return " .. data.cooldown .. " * haste" ) end
            if type( data.recharge ) == "number" and data.recharge > 0 then data.recharge = loadstring( "return " .. data.recharge .. " * haste" ) end
        end

        if not data.fixedCast and type( data.cast ) == "number" then
            data.cast = loadstring( "return " .. data.cast .. " * haste" )
        end

        for key, value in pairs( data ) do
            if type( value ) == 'function' then
                setfenv( value, state )

                if key ~= 'handler' and key ~= 'recheck' then a.funcs[ key ] = value
                else a[ key ] = value end
                data[ key ] = nil
            else
                a[ key ] = value
            end
        end

        a.lastCast = 0

        if a.id and a.id > 0 then
            local spell = Spell:CreateFromSpellID( a.id )
            if not spell:IsSpellEmpty() then 
                spell:ContinueOnSpellLoad( function () 
                    a.name = spell:GetSpellName()
                    a.desc = GetSpellDescription( a.id ) -- spell:GetSpellDescription() was returning raw tooltip data.

                    if a.suffix then
                        a.actualName = a.name
                        a.name = a.name .. " " .. a.suffix
                    end

                    local texture = a.texture or GetSpellTexture( a.id )

                    self.abilities[ a.name ] = self.abilities[ a.name ] or a
                    
                    class.abilities[ a.name ] = class.abilities[ a.name ] or a
                    if not a.unlisted then class.abilityList[ ability ] = a.listName or ( "|T" .. texture .. ":0|t " .. a.name ) end
                end ) 
            end
        end

        if not a.item then
            self.abilities[ ability ] = a
            self.abilities[ a.id ] = a
            
            if not a.unlisted then class.abilityList[ ability ] = class.abilityList[ ability ] or a.listName or a.name end

            if type( data.copy ) == 'string' or type( data.copy ) == 'number' then
                self.abilities[ data.copy ] = a
            elseif type( data.copy ) == 'table' then
                for _, key in ipairs( data.copy ) do
                    self.abilities[ key ] = a
                end
            end
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

    RegisterOptions = function( self, options )
        self.options = options
        for k, v in pairs( specTemplate ) do
            if options[ k ] == nil then options[ k ] = v end
        end
    end,

    RegisterEvent = function( self, event, func )
        RegisterEvent( event, function( ... )
            if state.spec.id == self.id then func( ... ) end
        end )
    end,

    RegisterCycle = function( self, func )
        self.cycle = setfenv( func, state )
    end,

    RegisterPet = function( self, token, id, spell, duration )
        self.pets[ token ] = {
            id = id,
            token = token,
            spell = spell,
            duration = type( duration ) == 'function' and setfenv( duration, state ) or duration
        }
    end,

    RegisterTotem = function( self, token, id )
        self.totems[ token ] = id
        self.totems[ id ] = token
    end,

    -- info should be an AceOption table.
    RegisterPref = function( self, info )
        table.insert( self.prefs, info )
    end,

    RegisterUsableItem = function( self, item, info )
        
    end,
}

--[[ function Hekili:RestoreDefaults()
    for key, pack in pairs( self.DB.profile.packs ) do
        if not class.defaults[ key ] then pack.builtIn = false end
    end ]]



function Hekili:RestoreDefaults()
    local p = self.DB.profile
    local changed = false

    for k, v in pairs( class.packs ) do
        local existing = rawget( p.packs, k )

        if not existing or not existing.version or existing.version < v.version then            
            local data = self:DeserializeActionPack( v.import )

            if data and type( data ) == 'table' then
                p.packs[ k ] = data.payload
                data.payload.version = v.version
                data.payload.date = v.version
                data.payload.builtIn = true
                changed = true
            end
        
        end
    end

    if changed then self:LoadScripts() end
end


function Hekili:RestoreDefault( name )
    local p = self.DB.profile

    local default = class.packs[ name ]

    if default then
        local data = self:DeserializeActionPack( default.import )

        if data and type( data ) == 'table' then
            p.packs[ name ] = data.payload
            data.payload.version = default.version
            data.payload.date = default.version
            data.payload.builtIn = true
        end
    end
end


ns.restoreDefaults = function( category, purge )
    return    
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


-- Trinket APL
-- ns.storeDefault( [[Usable Items]], 'actionLists', 20180208.181753, [[dq0NnaqijvTjPKpjrrJssPtjr1TufQSljzyk0XqjldPQNHsPAAiLsDnukLTHuk5BOunouk5CQcLMNKk3tQSpjfhucAHivEOefMisPYfvfSrvHmsukQtkbwPu4LOuKBkrj7uv6NQcflvI8uvMkQ0vLOuBfLc9vKsH9s6Vsvdw4WGwScEmctgvDzOnlL6ZOy0iLCAIvJuQ61OuWSv0Tb2Ts)wvnCKILJONlA6uDDKSDuX3vfQA8sOZRkA9iLIMVu0(PSYs5QhTdBdPMUsNEVqaQxzNWHjArbocs9kKWL)Mkx9LLYvVhw4We5v607fcq9ODKqkgA5w8BBX9PMPEfS8cb0)K6T)f1ReoryI6l9JSyN1OELW8trsGPYvD9kCqMI)upEsifdT8(F7(8tnt9ocsHgxV6Tir3LLjR4LeomrElAzH1as4chShxeiyArnDwKO7YYKvazfafWIwwynQ1IeDxwMScalkakGfDDwmArZMwajCHd2JlcemTOUols0DzzYkaSOaOawuU66l9kx9EyHdtKxPtVJGuOX1REls0DzzYkEjHdtK3IwwynGeUWb7XfbcMwutNfj6USmzfqwbqbSOLfwJATir3LLjRaWIcGcyrxNfJw0SPfqcx4G94IabtlQRZIeDxwMScalkakGfLRxjm)uKeyQCvxVchKP4p1RnKA6p7j(uRJKaeMuKOEfS8cb0)K6T)f1ReoryI6l9JSyN1OEVqaQ3JGut)PfLXNADKeGWKIevxFz7kx9EyHdtKxPtVJGuOX1REls0DzzYkEjHdtK3IwwynGeUWb7XfbcMwutNfj6USmzfqwbqbSOLfwJATir3LLjRaWIcGcyrxNfJw0SPfqcx4G94IabtlQRZIeDxwMScalkakGfLR3leG69iC(4EmYe5TOGTnsUWPfLfKGwYI6v4Gmf)PETX5xMiFVSTrYfo7bqcAjlQxjm)uKeyQCvxVs4eHjQV0pYIDwJ6vWYleq)tQ3(xuD9L2w5Q3dlCyI8kD69cbOEp6tYGTfC5lZ0IhbhifcO)j1ReMFkscmvUQRxHdYu8N61(tYGTfC5Z(2WbsHa6Fs9ky5fcO)j1B)lQxjCIWe1x6hzXoRr9ocsHgxV6Tir3LLjR4LeomrElAzH1as4chShxeiyArnDwKO7YYKvazfafWIwwynQ1IeDxwMScalkakGfDDwmArZMwajCHd2JlcemTOUols0DzzYkaSOaOawuU66lBt5Q3dlCyI8kD6DeKcnUE1BrIUlltwXljCyI8w0YcRbKWfoypUiqW0IA6Sir3LLjRaYkakGfTSWAuRfj6USmzfawuaual66Sy0IMnTas4chShxeiyArDDwKO7YYKvayrbqbSOC9EHaup28NCT432c2iC(j1RWbzk(t9O1NC7)T75aNFs9kH5NIKatLR66vcNimr9L(rwSZAuVcwEHa6Fs92)IQRV0wkx9EyHdtKxPtVJGuOX1REls0DzzYkEjHdtK3IwwynGeUWb7XfbcMwutNfj6USmzfqwbqbSOLfwJATir3LLjRaWIcGcyrxNfJw0SPfqcx4G94IabtlQRZIeDxwMScalkakGfLRxjm)uKeyQCvxVchKP4p1JnitApe5Xn7hOixzz6F8ssl9ky5fcO)j1B)lQxjCIWe1x6hzXoRr9EHaup2KmltApe5XTmtlOJICLLXcAdjPL66l7kx9EyHdtKxPtVxia1RSegA5w8BBbBI8NuPELW8trsGPYvD9kCqMI)upGWqlV)3UNnq(tQuVcwEHa6Fs92)I6vcNimr9L(rwSZAuVJGuOX1REls0DzzYkEjHdtK3IwwynGeUWb7XfbcMwutNfj6USmzfqwbqbSOLfwJATir3LLjRaWIcGcyrxNfJw0SPfqcx4G94IabtlQRZIeDxwMScalkakGfLRU(Ywkx9EyHdtKxPtVJGuOX1REls0DzzYkEjHdtK3IwwynGeUWb7XfbcMwutNfj6USmzfqwbqbSOLfwJATir3LLjRaWIcGcyrxNfJw0SPfqcx4G94IabtlQRZIeDxwMScalkakGfLR3leG6vswgl(TTOm(ZjKMuwglEeLtrIPEfoitXFQhPSm9)29e)5estkltFBkNIet9kH5NIKatLR66vcNimr9L(rwSZAuVcwEHa6Fs92)IQRVpwLREpSWHjYR0P3rqk046vVfj6USmzfVKWHjYBrllSgqcx4G94IabtlQPZIeDxwMSciRaOaw0YcRrTwKO7YYKvayrbqbSORZIrlA20ciHlCWECrGGPf11zrIUlltwbGffafWIY1ReMFkscmvUQRxHdYu8N6L0Geos2)B3pGoj8jCQxblVqa9pPE7Fr9kHteMO(s)il2znQ3leG6D0GeosAXVTf0Hoj8jCQU(YAu5Q3dlCyI8kD6DeKcnUE1BrIUlltwXljCyI8w0YcRbKWfoypUiqW0IA6Sir3LLjRaYkakGfTSWAuRfj6USmzfawuaual66Sy0IMnTas4chShxeiyArDDwKO7YYKvayrbqbSOC9ky5fcO)j1B)lQxHdYu8N65Fa2)B3tTKqo4uwM(eUI)uVsy(PijWu5QUELWjctuFPFKf7Sg17fcq94(bOf)2wu2ljKdoLLXIdUI)uD9LflLREpSWHjYR0P3rqk046vVfj6USmzfVKWHjYBrllSgqcx4G94IabtlQPZIeDxwMSciRaOaw0YcRrTwKO7YYKvayrbqbSORZIrlA20ciHlCWECrGGPf11zrIUlltwbGffafWIY1ReMFkscmvUQRxHdYu8N6rbgiHZEW)VmtOWbt9ky5fcO)j1B)lQxjCIWe1x6hzXoRr9EHauVYgmqcNwuw))YmHchmvxFzrVYvVhw4We5v607iifAC9Q3IeDxwMSIxs4We5TOLfwdiHlCWECrGGPf10zrIUlltwbKvaualAzH1Owls0DzzYkaSOaOaw01zXOfnBAbKWfoypUiqW0I66Sir3LLjRaWIcGcyr56vcZpfjbMkx11RWbzk(t94iWz)VDpbctCIz27)IYM6vWYleq)tQ3(xuVs4eHjQV0pYIDwJ69cbOESrboT432IYaHjoXmTG7VOSP6QRxjCIWe1x6hzXwJ0pYwvSyNTX(iBP3rqk046PhBw45XvPtVJgKqGtH2e6YF13r1vfa]] )


function Hekili:NewSpecialization( specID, isRanged )

    local id = specID

    if specID > 0 then
        id, name, _, texture, role, pClass = GetSpecializationInfoByID( specID )
    end

    if not id then
        Hekili:Error( "Unable to generate specialization DB for spec ID #" .. specID .. "." )
        return nil
    end

    local spec = class.specs[ id ] or {
        id = id,
        name = name,
        texture = texture,
        role = role,
        class = pClass,
        melee = not isRanged,

        resources = {},
        primaryResource = nil,
        
        talents = {},
        pvptalents = {},
        powers = {},
        
        auras = {},
        pseudoAuras = 0,

        abilities = {},
        pseudoAbilities = 0,
        itemAbilities = 0,

        pets = {},
        totems = {},

        potions = {},

        prefs = {},
        numPrefs = 0,

        stateExprs = {}, -- expressions are returned as values and take no args.
        stateFuncs = {}, -- functions can take arguments and can be used as helper functions in handlers.
        stateTables = {}, -- tables are... tables.

        gear = {},
        hooks = {},

        funcHooks = {},
        gearSets = {},
        interrupts = {},

        packs = {},
        options = {},
    }

    class.num = class.num + 1

    for key, func in pairs( HekiliSpecMixin ) do
        spec[ key ] = func
    end

    class.specs[ id ] = spec
    return spec
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

    ancient_hysteria = {
        id = 90355,
        duration = 40
    },

    heroism = {
        id = 32182,
        duration = 40,
    },

    time_warp = {
        id = 80353,
        duration = 40,
    },

    netherwinds = {
        id = 160452,
        duration = 40,
    },

    bloodlust = {
        id = 2825,
        duration = 40,
        generate = function ()
            local bloodlusts = {
                [90355] = 'ancient_hysteria',
                [32182] = 'heroism',
                [80353] = 'time_warp',
                [160452] = 'netherwinds'
            }

            for id, key in pairs( bloodlusts ) do
                local aura = buff[ key ]
                if aura.up then
                    buff.bloodlust.count = aura.count
                    buff.bloodlust.expires = aura.expires
                    buff.bloodlust.applied = aura.applied
                    buff.bloodlust.caster = aura.caster
                    return
                end
            end

            local i = 1
            local name, _, count, _, duration, expires, _, _, _, spellID = UnitBuff( 'player', i )

            while( name ) do
                if spellID == 2525 then break end
                i = i + 1
                name, _, count, _, duration, expires, _, _, _, spellID = UnitBuff( 'player', i )
            end

            if name then
                buff.bloodlust.count = max( 1, count )
                buff.bloodlust.expires = expires
                buff.bloodlust.applied = expires - duration
                buff.bloodlust.caster = 'unknown'
                return
            end

            buff.bloodlust.count = 0
            buff.bloodlust.expires = 0
            buff.bloodlust.applied = 0
            buff.bloodlust.caster = 'nobody'
        end,

    },

    exhaustion = {
        id = 57723,
        duration = 600,
    },

    insanity = {
        id = 95809,
        duration = 600,
    },

    sated = {
        id = 57724,
        duration = 600,
    },

    temporal_displacement = {
        id = 80354,
        duration = 600,
    },

    fatigued = {
        id = 160455,
        duration = 600,
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
        generate = function ()
            local aura = debuff.casting

            if UnitCanAttack( "player", "target" ) then
                local spell, _, _, startCast, endCast, _, _, notInterruptible = UnitCastingInfo( "target" )
        
                if notInterruptible == false then
                    aura.name = "Casting " .. spell
                    aura.count = 1
                    aura.expires = endCast / 1000
                    aura.applied = startCast / 1000
                    aura.v1 = spell
                    aura.caster = 'target'
                    return
                end

                spell, _, _, startCast, endCast, _, _, notInterruptible = UnitChannelInfo( "target" )
                
                if notInterruptible == false then
                    aura.name = "Casting " .. spell
                    aura.count = 1
                    aura.expires = endCast / 1000
                    aura.applied = startCast / 1000
                    aura.v1 = spell
                    aura.caster = 'target'
                    return
                end
            end

            aura.name = "Casting"
            aura.count = 0
            aura.expires = 0
            aura.applied = 0
            aura.v1 = 0
            aura.caster = 'target'
        end,
    },

    player_casting = {
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
                aura.caster = 'player'
                return
            end

            name, _, _, startCast, endCast, _, _, notInterruptible, spell = UnitChannelInfo( "player" )
            
            if notInterruptible == false then
                aura.name = name
                aura.count = 1
                aura.expires = endCast / 1000
                aura.applied = startCast / 1000
                aura.v1 = spell
                aura.caster = 'player'
                return
            end

            aura.name = "Casting"
            aura.count = 0
            aura.expires = 0
            aura.applied = 0
            aura.v1 = 0
            aura.caster = 'target'
        end,
    },

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

    -- Why do we have this, again?
    unknown_buff = {},

    berserking = {
        id = 26297,
        duration = 10,
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
        duration = 15,
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
        generate = function ()
            local oor = buff.out_of_range

            if target.distance > 8 then
                oor.count = 1
                oor.applied = query_time
                oor.expires = 3600
                oor.caster = "player"
                return
            end

            oor.count = 0
            oor.applied = 0
            oor.expires = 0
            oor.caster = "nobody"
        end,
    },

    dispellable_curse = {
        generate = function ()
            local dm = debuff.dispellable_curse

            if UnitCanAttack( "player", "target" ) then
                local i = 1
                local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )

                while( name ) do
                    if debuffType == "Curse" and canDispel then break end
                    
                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )
                end
                
                if canDispel then
                    dm.count = count > 0 and count or 1
                    dm.expires = expirationTime > 0 and expirationTime or query_time + 5
                    dm.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    dm.caster = "nobody"
                    return
                end
            end

            dm.count = 0
            dm.expires = 0
            dm.applied = 0
            dm.caster = "nobody"
        end,
    },

    dispellable_poison = {
        generate = function ()
            local dm = debuff.dispellable_poison

            local i = 1
            local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "player", i )

            while( name ) do
                if debuffType == "Poison" and canDispel then break end
                
                i = i + 1
                name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "player", i )
            end
            
            if canDispel then
                dm.count = count > 0 and count or 1
                dm.expires = expirationTime > 0 and expirationTime or query_time + 5
                dm.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                dm.caster = "nobody"
                return
            end

            dm.count = 0
            dm.expires = 0
            dm.applied = 0
            dm.caster = "nobody"
        end,
    },

    dispellable_disease = {
        generate = function ()
            local dm = debuff.dispellable_disease

            local i = 1
            local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "player", i )

            while( name ) do
                if debuffType == "Disease" and canDispel then break end
                
                i = i + 1
                name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "player", i )
            end
            
            if canDispel then
                dm.count = count > 0 and count or 1
                dm.expires = expirationTime > 0 and expirationTime or query_time + 5
                dm.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                dm.caster = "nobody"
                return
            end

            dm.count = 0
            dm.expires = 0
            dm.applied = 0
            dm.caster = "nobody"
        end,
    },

    dispellable_magic = {
        generate = function ()
            local dm = debuff.dispellable_magic

            if UnitCanAttack( "player", "target" ) then
                local i = 1
                local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )

                while( name ) do
                    if debuffType == "Magic" and canDispel then break end
                    
                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )
                end
                
                if canDispel then
                    dm.count = count > 0 and count or 1
                    dm.expires = expirationTime > 0 and expirationTime or query_time + 5
                    dm.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    dm.caster = "nobody"
                    return
                end
            end

            dm.count = 0
            dm.expires = 0
            dm.applied = 0
            dm.caster = "nobody"
        end,
    },

    stealable_magic = {
        generate = function ()
            local dm = debuff.stealable_magic

            if UnitCanAttack( "player", "target" ) then
                local i = 1
                local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )

                while( name ) do
                    if debuffType == "Magic" and canDispel then break end
                    
                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )
                end
                
                if canDispel then
                    dm.count = count > 0 and count or 1
                    dm.expires = expirationTime > 0 and expirationTime or query_time + 5
                    dm.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    dm.caster = "nobody"
                    return
                end
            end

            dm.count = 0
            dm.expires = 0
            dm.applied = 0
            dm.caster = "nobody"
        end,
    },

    reversible_magic = {
        generate = function ()
            local dm = debuff.reversible_magic

            local i = 1
            local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitDebuff( "player", i )

            while( name ) do
                if debuffType == "Magic" and canDispel then break end
                
                i = i + 1
                name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitDebuff( "player", i )
            end
            
            if canDispel then
                dm.count = count > 0 and count or 1
                dm.expires = expirationTime > 0 and expirationTime or query_time + 5
                dm.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                dm.caster = "nobody"
                return
            end

            dm.count = 0
            dm.expires = 0
            dm.applied = 0
            dm.caster = "nobody"
        end,
    },

    dispellable_enrage = {
        generate = function ()
            local dm = debuff.dispellable_enrage

            if UnitCanAttack( "player", "target" ) then
                local i = 1
                local name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )

                while( name ) do
                    if debuffType == "" and canDispel then break end
                    
                    i = i + 1
                    name, _, count, debuffType, duration, expirationTime, _, canDispel = UnitBuff( "target", i )
                end
                
                if canDispel then
                    dm.count = count > 0 and count or 1
                    dm.expires = expirationTime > 0 and expirationTime or query_time + 5
                    dm.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    dm.caster = "nobody"
                    return
                end
            end

            dm.count = 0
            dm.expires = 0
            dm.applied = 0
            dm.caster = "nobody"
        end,
    }
} )


all:RegisterPotions( {
    old_war = {
        item = 127844,
        buff = 'old_war'
    },
    deadly_grace = {
        item = 127843,
        buff = 'deadly_grace'
    },
    prolonged_power = {
        item = 142117,
        buff = 'prolonged_power'
    },
    battle_potion_of_agility = {
        item = 163223,
        buff = 'battle_potion_of_agility',
    },
    battle_potion_of_intellect = {
        item = 163222,
        buff = 'battle_potion_of_intellect',
    },
    battle_potion_of_stamina = {
        item = 163225,
        buff = 'battle_potion_of_stamina',
    },
    battle_potion_of_strength = {
        item = 163224,
        buff = 'battle_potion_of_strength',
    },
    potion_of_bursting_blood = {
        item = 152560,
        buff = 'potion_of_bursting_blood',
        copy = "bursting_blood",
    },
    potion_of_rising_death = {
        item = 152559,
        buff = 'potion_of_rising_death',
        copy = "rising_death",
    },
    steelskin_potion = {
        item = 152557,
        buff = 'steelskin_potion',
    },
} )


all:RegisterAuras( {
    battle_potion_of_agility = {
        id = 279152,
        duration = 25,
        max_stack = 1,
    },
    battle_potion_of_intellect = {
        id = 279151,
        duration = 25,
        max_stack = 1,
    },
    battle_potion_of_stamina = {
        id = 279154,
        duration = 25,
        max_stack = 1,
    },
    battle_potion_of_strength = {
        id = 279153,
        duration = 25,
        max_stack = 1,
    },
    potion_of_bursting_blood = {
        id = 251316,
        duration = 25,
        max_stack = 1,
    },
    potion_of_rising_death = {
        id = 269853,
        duration = 25,
        max_stack = 1,
    },
    steelskin_potion = {
        id = 251231,
        duration = 25,
        max_stack = 1,
    }
})


all:SetPotion( "prolonged_power" )


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

        usable = function () return race.maghar_orc end,
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

        usable = function () return race.nightborne end,
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

        usable = function () return race.troll end,
        handler = function ()
            applyBuff( 'berserking' )
        end,
    },

    blood_fury = {
        id = function ()
            if class.file == "MONK" or class.file == "SHAMAN" then return 33697 end
            return 20572
            -- 33702 ?
        end,
        cast = 0,
        cooldown = 120,
        gcd = "off",
    
        toggle = "cooldowns",

        usable = function () return race.orc end,
        handler = function ()
            applyBuff( "blood_fury", 15 )
        end,
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

        startsCombat = true,

        usable = function () return race.blood_elf end,
        toggle = "cooldowns",

        handler = function ()
            if class.file == "DEATHKNIGHT" then gain( 20, "runic_power" )
            elseif class.file == "HUNTER" then gain( 15, "focus" )
            elseif class.file == "MONK" then gain( 1, "chi" )
            elseif class.file == "PALADIN" then gain( 1, "holy_power" )
            elseif class.file == "ROGUE" then gain( 15, "energy" )
            elseif class.file == "WARRIOR" then gain( 15, "rage" )
            elseif class.file == "DEMONHUNTER" then gain( 15, "fury" ) end 

            removeDebuff( "target", "dispellable_magic" )
        end,
    },

    shadowmeld = {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        usable = function () return boss and race.night_elf end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    },


    lights_judgment = {
        id = 255647,
        cast = 0,
        cooldown = 150,
        gcd = "spell",

        usable = function () return race.lightforged_draenei end,

        toggle = 'cooldowns',
    },


    fireblood = {
        id = 265221,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        toggle = "cooldowns",

        usable = function () return race.dark_iron_dwarf end,
        handler = function () applyBuff( "fireblood" ) end,            
    },


    -- INTERNAL HANDLERS
    call_action_list = {
        name = '|cff00ccff[Call Action List]|r',
        cast = 0,
        cooldown = 0,
        gcd = 'off',
    },

    run_action_list = {
        name = '|cff00ccff[Run Action List]|r',
        cast = 0,
        cooldown = 0,
        gcd = 'off',
    },

    wait = {
        name = '|cff00ccff[Wait]|r',
        cast = 0,
        cooldown = 0,
        gcd = 'off',
    },

    pool_resource = {
        name = '|cff00ccff[Pool Resource]|r',
        cast = 0,
        cooldown = 0,
        gcd = 'off',
    },

    variable = {
        name = '|cff00ccff[Variable]|r',
        cast = 0,
        cooldown = 0,
        gcd = 'off',
    },

    potion = {
        name = '|cff00ccff[Potion]|r',
        cast = 0,
        cooldown = function () return time > 0 and 3600 or 60 end,
        gcd = 'off',

        startsCombat = false,
        toggle = "potions",

        handler = function ()
            local potion = args.potion or args.name
            if not potion or potion == "default" then potion = class.potion end
            potion = class.potions[ potion ]

            if potion then
                applyBuff( potion.buff, potion.duration or 25 )
            end
        end,

        usable = function ()
            local pName = args.potion or args.name
            if not pName or pName == "default" then pName = class.potion end

            local potion = class.potions[ pName ]            
            if not potion or GetItemCount( potion.item ) == 0 then return false end

            return true
        end,
    },

    cancel_buff = {
        name = '|cff00ccff[Cancel Buff]|r',
        cast = 0,
        gcd = 'off',

        startsCombat = false,

        buff = function () return args.buff_name or nil end,

        indicator = "cancel",
        texture = function ()
            local a = class.auras[ args.buff_name ]            
            if a.texture then return a.texture end
            
            a = a and a.id
            a = a and GetSpellTexture( a )
            return a or 134400
        end,

        usable = function () return args.buff_name ~= nil, "no buff name detected" end,
        handler = function ()
            removeBuff( args.buff_name )
        end,
    }
} )


-- Use Items
do
    -- Should handle trinkets/items internally.
    -- 1.  Check APLs and don't try to recommend items that have their own APL entries.
    -- 2.  Respect item preferences registered in spec options.
    
    all:RegisterAbility( "use_items", {
        name = "|cff00ccff[Use Items]|r",
        cast = 0,
        cooldown = 120,
        gcd = 'off',
    } )
end



-- BFA TRINKETS
-- EQUIPPED EFFECTS
all:RegisterAuras( {
    -- Darkmoon Deck: Squalls
    suffocating_squall = { id = 276132, duration = 26, max_stack = 1 }, -- I made up max duration (assume 13 card types and 2s per card).
    
    -- Construct Overcharger
    titanic_overcharge = { id = 278070, duration = 10, max_stack = 8 },
    
    -- Xalzaix's Veiled Eye
    xalzaixs_gaze = { id = 278158, duration = 20, max_stack = 1 },
    
    -- Syringe of Bloodborne Infirmity
    wasting_infection = { id = 278110, duration = 12, max_stack = 1 },
    critical_prowess = { id = 278109, duration = 6, max_stack = 5 },

    -- Frenetic Corpuscle
    frothing_rage = { id = 278140, duration = 45, max_stack = 4 },

    -- Tear of the Void
    voidspark = { id = 278831, duration = 14, max_stack = 1 },

    -- Prism of Dark Intensity
    dark_intensity = { id = 278378, duration = 18, max_stack = 6,
        meta = {
            -- Stacks every 3 seconds until expiration; should generalize this kind of thing...
            stacks = function ( aura )
                if aura.up then return 1 + floor( ( query_time - aura.applied ) / 3 ) end
                return 0
            end
        }
    },

    -- Plume of the Seaborne Avian
    seaborne_tempest = { id = 278382, duration = 10, max_stack = 1 },

    -- Drust-Runed Icicle
    chill_of_the_runes = { id = 278862, duration = 12, max_stack = 1 },

    -- Permafrost-Encrusted Heart
    coldhearted_instincts = { id = 278388, duration = 15, max_stack = 5, copy = "cold_hearted_instincts",
        meta = {
            -- Stacks every 3 seconds until expiration; should generalize this kind of thing...
            stacks = function ( aura )
                if aura.up then return 1 + floor( ( query_time - aura.applied ) / 3 ) end
                return 0
            end
        }
    },

    -- Spiritbound Voodoo Burl
    coalesced_essence = { id = 278224, duration = 12, max_stack = 1 },

    -- Wing Bone of the Budding Tempest
    avian_tempest = { id = 278253, duration = 10, max_stack = 5 },

    -- Razorcrest of the Enraged Matriarch
    winged_tempest = { id = 278248, duration = 16, max_stack = 1 },

    -- Hurricane Heart
    hurricane_within = { id = 161416, duration = 12, max_stack = 6,
        meta = {
            -- Stacks every 2 seconds until expiration; should generalize this kind of thing...
            stacks = function ( aura )
                if aura.up then return 1 + floor( ( query_time - aura.applied ) / 2 ) end
                return 0
            end
        }
    },

    -- Kraulok's Claw
    krauloks_strength = { id = 278287, duration = 10, max_stack = 1 },

    -- Doom's Hatred
    blood_hatred = { id = 278356, duration = 10, max_stack = 1 },

    -- Lion's Grace
    lions_grace = { id = 278815, duration = 10, max_stack = 1 },

    -- Landoi's Scrutiny
    landois_scrutiny = { id = 281544, duration = 15, max_stack = 1 },

    -- Leyshock's Grand Compilation
    precision_module = { id = 281791, duration = 15, max_stack = 3 }, -- Crit.
    iteration_capacitor = { id = 281792, duration = 15, max_stack = 3 }, -- Haste.
    efficiency_widget = { id = 281794, duration = 15, max_stack = 3 }, -- Mastery.
    adaptive_circuit = { id = 281795, duration = 15, max_stack = 3 }, -- Versatility.
    leyshocks_grand_compilation = {
        alias = { "precision_module", "iteration_capacitor", "efficiency_widget", "adaptive_circuit" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 15,
    },

    -- Twitching Tentacle of Xalzaix
    lingering_power_of_xalzaix = { id = 278155, duration = 30, max_stack = 5 },
    uncontained_power = { id = 278156, duration = 12, max_stack = 1 },

    -- Surging Alchemist Stone
    -- I believe these buffs are recycled a lot...
    agility = { id = 60233, duration = 15, max_stack = 1 },
    intellect = { id = 60234, duration = 15, max_stack = 1 },
    strength = { id = 60229, duration = 15, max_stack = 1 },

    -- Harlan's Loaded Dice
    loaded_die_mastery = { id = 267325, duration = 15, max_stack = 1 },
    loaded_die_haste = { id = 267327, duration = 15, max_stack = 1 },
    loaded_die_critical_strike = { id = 267330, duration = 15, max_stack = 1 },
    loaded_die = {
        alias = { "loaded_die_mastery", "loaded_die_haste", "loaded_die_critical_strike" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 15,
    },

    -- Tiny Electromental in a Jar
    phenomenal_power = { id = 267179, duration = 30, max_stack = 12 },

    -- Rezan's Gleaming Eye
    rezans_gleaming_eye = { id = 271103, duration = 15, max_stack = 1 },

    -- Azerokk's Resonating Heart
    resonating_elemental_heart = { id = 268441, duration = 15, max_stack = 1 },

    -- Gore-Crusted Butcher's Block
    butchers_eye = { id = 271104, duration = 15, max_stack = 1 },

    -- Briny Barnacle
    choking_brine = { id = 268194, duration = 6, max_stack = 1 },

    -- Conch of Dark Whispers
    conch_of_dark_whispers = { id = 271071, duration = 15, max_stack = 1 },

    -- Dead Eye Spyglass
    dead_ahead = { id = 268756, duration = 10, max_stack = 1 },
    dead_ahead_crit = { id = 268769, duration = 10, max_stack = 5 },

    -- Lingering Sporepods
    lingering_spore_pods = { id = 268062, duration = 4, max_stack = 1 },

} )


-- BFA TRINKETS
-- ON USE
all:RegisterAbility( "endless_tincture_of_fractional_power", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 152636,

    toggle = "cooldowns",

    handler = function ()
        -- I don't know the auras it applies...
    end
} )


all:RegisterAbility( "mercys_psalter", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 155564,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "potency" )
    end,
} )

all:RegisterAura( "potency", {
    id = 268523,
    duration = 15,
    max_stack = 1,
} )


all:RegisterAbility( "void_portal_stone", {
    cast = 0,
    cooldown = 60, -- no CD reported in-game yet.
    gcd = "off",

    item = 161375,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "syphon_from_the_abyss" )
    end,
} )

all:RegisterAura( "syphon_from_the_abyss", {
    id = 278376,
    duration = 14,
    max_stack = 7,
    meta = {
        -- Stacks every 2 seconds until expiration; should generalize this kind of thing...
        stacks = function ( aura )
            if aura.up then return 1 + floor( ( query_time - aura.applied ) / 2 ) end
            return 0
        end
    }
} )


all:RegisterAbility( "azurethos_singed_plumage", {
    cast = 0,
    cooldown = 88,
    gcd = "off",

    item = 161377,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "ruffling_tempest" )
    end,
} )

all:RegisterAura( "ruffling_tempest", {
    id = 278383,
    duration = 15,
    max_stack = 1,
    -- Actually decrements but doesn't appear to use stacks to implement itself.
} )


all:RegisterAbility( "galecallers_beak", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161379,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "gale_call" )
    end,
} )

all:RegisterAura( "gale_call", {
    id = 278385,
    duration = 15,
    max_stack = 1,
} )


all:RegisterAbility( "sublimating_iceshard", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 161382,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "sublimating_power" )
    end,
} )

all:RegisterAura( "sublimating_power", {
    id = 278869,
    duration = 14,
    max_stack = 1,
    -- Decrements after 6 sec but doesn't appear to use stacks to convey this...
} )


all:RegisterAbility( "tzanes_barkspines", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 161411,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "barkspines" )
    end,
} )

all:RegisterAura( "barkspines", {
    id = 278227,
    duration = 10,
    max_stack = 1,
} )


all:RegisterAbility( "knot_of_spiritual_fury", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 161413,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "spiritual_fury" )
    end,
} )

all:RegisterAura( "spiritual_fury", {
    id = 278231,
    duration = 12,
    max_stack = 1,
} )


all:RegisterAbility( "sandscoured_idol", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 161417,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "secrets_of_the_sands" )
    end,
} )

all:RegisterAura( "secrets_of_the_sands", {
    id = 278267,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "dunewalkers_survival_kit", {
    cast = 0,
    cooldown = 105,
    gcd = "off",

    item = 161418,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "dune_survival_kit" )
    end,
} )

all:RegisterAura( "dune_survival_kit", {
    id = 278260,
    duration = 12,
    max_stack = 4,
    meta = {
        -- Stacks every 2 seconds until expiration; should generalize this kind of thing...
        stacks = function ( aura )
            if aura.up then return 1 + floor( ( query_time - aura.applied ) / 3 ) end
            return 0
        end
    }
} )


all:RegisterAbility( "dooms_wake", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161462,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "dooms_wake" )
    end,
} )

all:RegisterAura( "dooms_wake", {
    id = 278317,
    duration = 16,
    max_stack = 1
} )


all:RegisterAbility( "dooms_fury", {
    cast = 0,
    cooldown = 105,
    gcd = "off",

    item = 161463,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "bristling_fury" )
    end,
} )

all:RegisterAura( "bristling_fury", {
    id = 278364,
    duration = 18,
    max_stack = 1,
} )


all:RegisterAbility( "lions_guile", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161473,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "lions_guile" )
    end,
} )

all:RegisterAura( "lions_guile", {
    id = 278806,
    duration = 16,
    max_stack = 10,
    meta = {
        stack = function( t ) return t.down and 0 or min( 6, 1 + ( ( query_time - t.app ) / 2 ) ) end,
    }
} )


all:RegisterAbility( "lions_strength", {
    cast = 0,
    cooldown = 105,
    gcd = "off",

    item = 161474,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "lions_strength" )
    end,
} )

all:RegisterAura( "lions_strength", {
    id = 278819,
    duration = 18,
    max_stack = 1,
} )


all:RegisterAbility( "bygone_bee_almanac", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 163936,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "process_improvement" )
    end,
} )

all:RegisterAura( "process_improvement", {
    id = 281543,
    duration = 12,
    max_stack = 1,
} ) -- extends on spending resources, could hook here...


all:RegisterAbility( "mydas_talisman", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 158319,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "touch_of_gold" )
    end,
} )

all:RegisterAura( "touch_of_gold", {
    id = 265954,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "merekthas_fang", {
    cast = 3,
    channeled = true,
    cooldown = 120,
    gcd = "off",

    item = 158367,
    toggle = "cooldowns",

    -- not sure if this debuffs during the channel...
} )


all:RegisterAbility( "razdunks_big_red_button", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 159611,
    toggle = "cooldowns",

    velocity = 10,
} )


all:RegisterAbility( "galecallers_boon", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 159614,
    toggle = "cooldowns",

    usable = function () return buff.movement.down end,
    handler = function ()
        applyBuff( "galecallers_boon" )
    end,
} )

all:RegisterAura( "galecallers_boon", {
    id = 268311,
    duration = 10,
    max_stack = 1,
    meta = {
        remains = function( t )
            if t.up then return max( 1, action.galecallers_boon.lastCast + 10 - query_time ) end
            return 0
        end
    }
} )


all:RegisterAbility( "ignition_mages_fuse", {
    cast = 0,
    cooldown = 20,
    gcd = "off",

    item = 159615,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "ignition_mages_fuse" )
    end,
} )

all:RegisterAura( "ignition_mages_fuse", {
    id = 271115,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "lustrous_golden_plumage", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159617,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "golden_luster" )
    end,
} )

all:RegisterAura( "golden_luster", {
    id = 271107,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "mchimbas_ritual_bandages", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159618,
    toggle = "defensives",

    handler = function ()
        applyBuff( "ritual_wraps" )
    end,
} )

all:RegisterAura( "ritual_wraps", {
    id = 265946,
    duration = 6,
    max_stack = 1,
} )


all:RegisterAbility( "rotcrusted_voodoo_doll", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 159624,
    toggle = "cooldowns",

    handler = function ()
        applyDebuff( "target", "rotcrusted_voodoo_doll" )
    end,
} )

all:RegisterAura( "rotcrusted_voodoo_doll", {
    id = 271465,
    duration = 6,
    max_stack = 1,
} )


all:RegisterAbility( "vial_of_animated_blood", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159625,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "blood_of_my_enemies" )
    end,
} )

all:RegisterAura( "blood_of_my_enemies", {
    id = 268836,
    duration = 18,
    max_stack = 1,
} )


all:RegisterAbility( "jes_howler", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 159627,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "motivating_howl" )
    end,
} )

all:RegisterAura( "motivating_howl", {
    id = 266047,
    duration = 12,
    max_stack = 1,
} )


all:RegisterAbility( "balefire_branch", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159630,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "kindled_soul" )
    end,
} )

all:RegisterAura( "kindled_soul", {
    id = 268998,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "sanguinating_totem", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 160753,
    toggle = "defensives",
} )


all:RegisterAbility( "fetish_of_the_tormented_mind", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 160833,
    toggle = "defensives",

    handler = function ()
        applyDebuff( "target", "doubting_mind" )
    end,
} )

all:RegisterAura( "doubting_mind", {
    id = 273559,
    duration = 5,
    max_stack = 1
} )


all:RegisterAbility( "whirlwings_plumage", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 158215,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "gryphons_pride" )
    end,
} )

all:RegisterAura( "gryphons_pride", {
    id = 268550,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "dread_combatants_medallion", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161811,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "rapid_adaptation" )
    end,
} )

all:RegisterAura( "rapid_adaptation", {
    id = 277179,
    duration = 20,
    max_stack = 1
} )


all:RegisterAbility( "dread_combatants_insignia", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161813,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "dig_deep" )
    end,
} )

all:RegisterAura( "dig_deep", {
    id = 277185,
    duration = 15,
    max_stack = 1
} )


-- Dread Combatant's Badge
all:RegisterAura( "taste_of_victory", {
    id = 277182,
    duration = 20,
    max_stack = 1
} )


all:RegisterAbility( "dread_gladiators_medallion", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161674,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "rapid_adaptation" )
    end,
} )


all:RegisterAbility( "dread_gladiators_emblem", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 161675,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "toughen_up" )
    end,
} )

all:RegisterAura( "toughen_up", {
    id = 277187,
    duration = 15,
    max_stack = 1,
} )


all:RegisterAbility( "dread_gladiators_badge", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161902,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "dig_deep" )
    end,
} )


-- Galewind Chimes
all:RegisterAura( "galewind_chimes", {
    id = 268518,
    duration = 8,
    max_stack = 1,
} )

-- Gilded Loa Figurine
all:RegisterAura( "will_of_the_loa", {
    id = 273974,
    duration = 10,
    max_stack = 1,
} )

-- Emblem of Zandalar
all:RegisterAura( "speed_of_the_spirits", {
    id = 273992,
    duration = 8,
    max_stack = 1,
} )

-- Dinobone Charm
all:RegisterAura( "primal_instinct", {
    id = 273988,
    duration = 7,
    max_stack = 1
} )


all:RegisterAbility( "pearl_divers_compass", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 158162,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "true_north" )
    end,
} )

all:RegisterAura( "true_north", {
    id = 273935,
    duration = 12,
    max_stack = 1,
} )


all:RegisterAbility( "first_mates_spyglass", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 158163,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "spyglass_sight" )
    end,
} )

all:RegisterAura( "spyglass_sight", {
    id = 273955,
    duration = 15,
    max_stack = 1
} )


all:RegisterAbility( "plunderbeards_flask", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 158164,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "bolstered_spirits" )
    end,
} )

all:RegisterAura( "bolstered_spirits", {
    id = 273942,
    duration = 10,
    max_stack = 10,
} )


all:RegisterAbility( "living_oil_cannister", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 158216,
    toggle = "cooldowns",
} )


all:RegisterAura( "sound_barrier", {
    id = 268531,
    duration = 8,
    max_stack = 1,
} )


all:RegisterAbility( "vial_of_storms", {
    cast = 0,
    cooldown = 90,
    gcd = "off",
    
    item = 158224,
    toggle = "cooldowns",
} )


all:RegisterAura( "sirens_melody", {
    id = 268512,
    duration = 6,
    max_stack = 1,
} )


all:RegisterAura( "tick", {
    id = 274430,
    duration = 6,
    max_stack = 1,
} )

all:RegisterAura( "tock", {
    id = 274431,
    duration = 6,
    max_stack = 1,
} )

all:RegisterAura( "soulguard", {
    id = 274459,
    duration = 12,
    max_stack = 1,
} )


all:RegisterAbility( "berserkers_juju", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 161117,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "berserkers_frenzy" )
    end,
} )

all:RegisterAura( "berserkers_frenzy", {
    id = 274472,
    duration = 10,
    max_stack = 1,
} )


all:RegisterAbility( "dread_aspirants_medallion", {
    cast = 0,
    cooldown = 120,
    gcd = "off",
    
    item = 162897,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "rapid_adaptation" )
    end,
} )


all:RegisterAbility( "dread_aspirants_emblem", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 162898,
    toggle = "cooldowns",
    
    handler = function ()
        applyBuff( "toughen_up" )
    end,
} )


all:RegisterAbility( "dread_aspirants_badge", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 162966,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "dig_deep" )
    end,
} )


all:RegisterAbility( "knot_of_ancient_wisdom", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 166793,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "wisdom_of_the_forest_lord" )
    end,
} )

all:RegisterAura( "wisdom_of_the_forest_lord", {
    id = 278267,
    duration = 20,
    max_stack = 5
} )


all:RegisterAbility( "knot_of_ancient_fury", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 166795,
    toggle = "cooldowns",

    handler = function ()

    end,
} )

all:RegisterAura( "fury_of_the_forest_lord", {
    id = 278231,
    duration = 12,
    max_stack = 1
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



-- LEGION LEGENDARIES
all:RegisterGear( 'rethus_incessant_courage', 146667 )
    all:RegisterAura( 'rethus_incessant_courage', { id = 241330 } )

all:RegisterGear( 'vigilance_perch', 146668 )
    all:RegisterAura( 'vigilance_perch', { id = 241332, duration =  60, max_stack = 5 } )

all:RegisterGear( 'the_sentinels_eternal_refuge', 146669 )
    all:RegisterAura( 'the_sentinels_eternal_refuge', { id = 241331, duration = 60, max_stack = 5 } )

all:RegisterGear( 'prydaz_xavarics_magnum_opus', 132444 )
    all:RegisterAura( 'xavarics_magnum_opus', { id = 207428, duration = 30 } )



all:RegisterAbility( "draught_of_souls", {
    cast = 0,
    cooldown = 80,
    gcd = 'off',

    item = 140808,

    toggle = 'cooldowns',

    handler = function ()
        applyBuff( "fel_crazed_rage", 3 )
        setCooldown( "global_cooldown", 3 )
    end,
} )

all:RegisterAura( "fel_crazed_rage", {
    id = 225141,
    duration = 3, 
})


all:RegisterAbility( "faulty_countermeasure", {
    cast = 0,
    cooldown = 120,
    gcd = 'off',

    item = 137539,

    toggle = 'cooldowns',

    handler = function ()
        applyBuff( "sheathed_in_frost" )
    end        
} )

all:RegisterAura( "sheathed_in_frost", {
    id = 214962,
    duration = 30
} )


all:RegisterAbility( "feloiled_infernal_machine", {
    cast = 0,
    cooldown = 80,
    gcd = 'off',

    item = 144482,

    toggle = 'cooldowns',

    handler = function ()
        applyBuff( "grease_the_gears" )
    end,        
} )
    
all:RegisterAura( "grease_the_gears", {
    id = 238534,
    duration = 20
} )


all:RegisterAbility( "ring_of_collapsing_futures", {
    item = 142173,
    spend = 0,
    cast = 0, 
    cooldown = 15,
    gcd = 'off',
    
    readyTime = function () return debuff.temptation.remains end,
    handler = function ()
        applyDebuff( "player", "temptation", 30, debuff.temptation.stack + 1 )
    end
} )

all:RegisterAura( "temptation", {
    id = 234143,
    duration = 30,
    max_stack = 20
} )


all:RegisterAbility( "forgefiends_fabricator", {
    item = 151963,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = 'off',
} )


all:RegisterAbility( "horn_of_valor", {
    item = 133642,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
    handler = function () applyBuff( "valarjars_path" ) end
} )

all:RegisterAura( "valarjars_path", {
    id = 215956,
    duration = 30 
} )


all:RegisterAbility( "kiljaedens_burning_wish", {
    item = 144259,

    cast = 0,
    cooldown = 75,
    gcd = 'off',

    texture = 1357805,

    toggle = 'cooldowns',
    usable = function () return level < 116 end,
} )


all:RegisterAbility( "might_of_krosus", {
    item = 140799,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = 'off',
    handler = function () if active_enemies > 3 then setCooldown( "might_of_krosus", 15 ) end end
} )


all:RegisterAbility( "ring_of_collapsing_futures", {
    item = 142173,
    spend = 0,
    cast = 0,
    cooldown = 15,
    gcd = 'off',
    readyTime = function () return debuff.temptation.remains end,
    handler = function () applyDebuff( "player", "temptation", 30, debuff.temptation.stack + 1 ) end
} )

all:RegisterAura( 'temptation', { 
    id = 234143,
    duration = 30,
    max_stack = 20 
} )


all:RegisterAbility( "specter_of_betrayal", {
    item = 151190,
    spend = 0,
    cast = 0,
    cooldown = 45,
    gcd = 'off',
} )


all:RegisterAbility( "tiny_oozeling_in_a_jar", {
    item = 137439,
    spend = 0,
    cast = 0,
    cooldown = 20,
    gcd = "off",
    usable = function () return buff.congealing_goo.stack == 6 end,
    handler = function () removeBuff( "congealing_goo" ) end
} )

all:RegisterAura( "congealing_goo", {
    id = 215126,
    duration = 60,
    max_stack = 6 
} )


all:RegisterAbility( "umbral_moonglaives", {
    item = 147012,
    spend = 0,
    cast = 0,
    cooldown = 90,
    gcd = 'off',
    toggle = 'cooldowns',
} )


all:RegisterAbility( "unbridled_fury", {
    item = 139327,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
    handler = function () applyBuff( "wild_gods_fury" ) end
} )

all:RegisterAura( "wild_gods_fury", { 
    id = 221695,
    duration = 30 
} )


all:RegisterAbility( "vial_of_ceaseless_toxins", {
    item = 147011,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = 'off',
    toggle = 'cooldowns',
    handler = function () applyDebuff( "target", "ceaseless_toxin", 20 ) end
} )

all:RegisterAura( "ceaseless_toxin", {
    id = 242497,
    duration = 20 
} )


all:RegisterAbility( "tome_of_unraveling_sanity", {
    item = 147019,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = "off",
    toggle = "cooldowns",
    handler = function () applyDebuff( "target", "insidious_corruption", 12 ) end
} )

all:RegisterAura( "insidious_corruption", {
    id = 243941,
    duration = 12
} )
all:RegisterAura( "extracted_sanity", {
    id = 243942, 
    duration =  24
} )

all:RegisterGear( 'aggramars_stride', 132443 )
all:RegisterAura( 'aggramars_stride', {
    id = 207438,
    duration = 3600 
} )

all:RegisterGear( 'sephuzs_secret', 132452 )
all:RegisterAura( 'sephuzs_secret', {
    id = 208051, 
    duration = 10
} )
all:RegisterAbility( "buff_sephuzs_secret", {
    name = "Sephuz's Secret (ICD)",
    cast = 0,
    cooldown = 30,
    gcd = "off",

    hidden = true,
    usable = function () return false end,
} )

all:RegisterGear( 'archimondes_hatred_reborn', 144249 )
all:RegisterAura( 'archimondes_hatred_reborn', {
    id = 235169,
    duration = 10,
    max_stack = 1
} )

all:RegisterGear( 'amanthuls_vision', 154172 )
all:RegisterAura( 'glimpse_of_enlightenment', {
    id = 256818, 
    duration = 12 
} )
all:RegisterAura( 'amanthuls_grandeur', {
    id = 256832,
    duration = 15 
} )

all:RegisterGear( 'insignia_of_the_grand_army', 152626 )

all:RegisterGear( 'eonars_compassion', 154172 )
all:RegisterAura( 'mark_of_eonar', {
    id = 256824,
    duration = 12
} )
all:RegisterAura( 'eonars_verdant_embrace', {
    id = function ()
        if class.file == "SHAMAN" then return 257475 end
        if class.file == "DRUID" then return 257470 end
        if class.file == "MONK" then return 257471 end
        if class.file == "PALADIN" then return 257472 end
        if class.file == "PRIEST" then
            if spec.discipline then return 257473 end
            if spec.holy then return 257474 end
        end
        return 257475
    end,
    duration = 20,
    copy = { 257470, 257471, 257472, 257473, 257474, 257475 }
} )
all:RegisterAura( 'verdant_embrace', {
    id = 257444,
    duration = 30 
} )


all:RegisterGear( 'aggramars_conviction', 154173 )
all:RegisterAura( 'celestial_bulwark', {
    id = 256816,
    duration = 14
} )
all:RegisterAura( 'aggramars_fortitude', {
    id = 256831,
    duration = 15
 } )

all:RegisterGear( 'golganneths_vitality', 154174 )
all:RegisterAura( 'golganneths_thunderous_wrath', {
    id = 256833,
    duration = 15 
} )

all:RegisterGear( 'khazgoroths_courage', 154176 )
all:RegisterAura( 'worldforgers_flame', {
    id = 256826,
    duration = 12
} )
all:RegisterAura( 'khazgoroths_shaping', {
    id = 256835,
    duration = 15
} )

all:RegisterGear( 'norgannons_prowess', 154177 )
all:RegisterAura( 'rush_of_knowledge', {
    id = 256828,
    duration = 12
} )
all:RegisterAura( 'norgannons_command', {
    id = 256836,
    duration = 15,
    max_stack = 6 
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
    class.hooks[ hook ] = func
end


ns.callHook = function( hook, ... )

    if class.hooks[ hook ] then
        return class.hooks[ hook ] ( ... )
    end

    return ...

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
        ability.elem[ k ] = type( v ) == 'function' and setfenv( v, state ) or v
    end

end
ns.storeAbilityElements = storeAbilityElements


local function modifyElement( t, k, elem, value )

    local entry = class[ t ][ k ]

    if not entry then
        ns.Error( "modifyElement() - no such key '" .. k .. "' in '" .. t .. "' table." )
        return
    end

    if type( value ) == 'function' then
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

function addItemSettings( key, itemID, options )

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


local function runHandler( key, no_start )

    local ability = class.abilities[ key ]

    if not ability then
        -- ns.Error( "runHandler() attempting to run handler for non-existant ability '" .. key .. "'." )
        return
    end

    if state.channeling then state.stopChanneling() end
    if ability.handler then ability.handler() end

    state.prev.last = key
    state[ ability.gcd == 'off' and 'prev_off_gcd' or 'prev_gcd' ].last = key

    table.insert( state.predictions, 1, key )
    table.insert( state[ ability.gcd == 'off' and 'predictionsOff' or 'predictionsOn' ], 1, key )
    
    state.predictions[6] = nil
    state.predictionsOn[6] = nil
    state.predictionsOff[6] = nil
    
    if state.time == 0 and ability.startsCombat and not no_start then
        state.false_start = state.query_time - 0.01

        -- Assume MH swing at combat start and OH swing half a swing later?
        if state.target.distance < 8 then
            if state.swings.mainhand_speed > 0 and state.nextMH == 0 then state.swings.mh_pseudo = state.false_start end
            if state.swings.offhand_speed > 0 and state.nextOH == 0 then state.swings.oh_pseudo = state.false_start + ( state.offhand_speed / 2 ) end
        end
    end

    state.cast_start = 0
    
    ns.callHook( 'runHandler', key )
    
end
ns.runHandler = runHandler
state.runHandler = runHandler



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


function Hekili:SpecializationChanged()
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
    wipe( class.talents )
    wipe( class.pvptalents )    
    wipe( class.powers )
    wipe( class.gear )
    wipe( class.packs )
    wipe( class.hooks )
    wipe( class.resources )

    wipe( class.pets )

    class.potion = nil

    local specs = { 0 }
    local currentSpec = GetSpecialization()
    local currentID = GetSpecializationInfo( currentSpec )

    for i = 1, 4 do
        local id, name, _, _, role = GetSpecializationInfo( i )

        if not id then break end

        if i == currentSpec then
            table.insert( specs, 1, id )

            state.spec.id = id
            state.spec.name = name        
            state.spec.key = getSpecializationKey( state.spec.id )

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

            state.spec[ state.spec.key ] = true
        else
            table.insert( specs, id )
        end
    end


    for key in pairs( GetResourceInfo() ) do
        state[ key ] = nil
        class[ key ] = nil
    end
    if rawget( state, "rune" ) then state.rune = nil; class.rune = nil; end
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

    for i, specID in ipairs( specs ) do
        local spec = class.specs[ specID ]

        if spec then
            if specID == currentID then
                self.currentSpec = spec
                self.currentSpecOpts = self.DB.profile.specs[ specID ]
                state.settings.spec = self.DB.profile.specs[ specID ]

                for res, model in pairs( spec.resources ) do
                    class.resources[ res ] = model
                    state[ res ] = model.state
                end
                if rawget( state, "runes" ) then state.rune = state.runes end

                class.primaryResource = spec.primaryResource

                for talent, id in pairs( spec.talents ) do
                    class.talents[ talent ] = id
                end

                for talent, id in pairs( spec.pvptalents ) do
                    class.pvptalents[ talent ] = id
                end

                for name, func in pairs( spec.hooks ) do
                    class.hooks[ name ] = func
                end 

                class.potionList.default = "|cFFFFD100Default|r"
            end

            if self.currentSpecOpts and self.currentSpecOpts.potion then
                class.potion = self.currentSpecOpts.potion
            end

            if not class.potion and spec.potion then
                class.potion = spec.potion
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

            for k, v in pairs( spec.pets ) do
                if not class.pets[ k ] then class.pets[ k ] = v end
            end

            for k, v in pairs( spec.totems ) do
                if not class.totems[ k ] then class.totems[ k ] = v end
            end

            for k, v in pairs( spec.potions ) do
                if not class.potions[ k ] then
                    class.potions[ k ] = v
                end
                if class.potion == k and class.auras[ k ] then class.auras.potion = class.auras[ k ] end
            end

            for k, v in pairs( spec.packs ) do
                if not class.packs[ k ] then class.packs[ k ] = v end
            end

            for name, func in pairs( spec.stateExprs ) do
                if not class.stateExprs[ name ] then
                    if rawget( state, name ) then
                        Hekili:Error( "Cannot RegisterStateExpr for an existing expression ( " .. spec.name .. " - " .. name .. " ) -- " .. tostring( rawget( state, name ) ) .. "." )
                    else
                        class.stateExprs[ name ] = func
                        -- Hekili:Error( "Not real error, registered " .. name .. " for " .. spec.name .. " (RSE)." )
                    end
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


            local s = Hekili.DB.profile.specs[ spec.id ]

            for k, v in pairs( spec.options ) do
                if s[ k ] == nil then s[ k ] = v end
            end
        end
    end


    state.GUID = UnitGUID( 'player' )
    state.player.unit = UnitGUID( 'player' )

    ns.callHook( 'specializationChanged' )

    ns.updateGear()
    ns.updateTalents()

    self:UpdateDisplayVisibility()

    self:RefreshOptions()    
    self:LoadScripts()
end


function Hekili:GetSpec()
    return state.spec.id and class.specs[ state.spec.id ]
end


ns.specializationChanged = function()
    Hekili:SpecializationChanged()
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


-- Initialize trinket stuff.
do
    local LIB = LibStub( "LibItemBuffs-1.0", true )
    if LIB then
        for k, v in pairs( class.trinkets ) do
            local item = k
            local buffs = LIB:GetItemBuffs( k )

            if type( buffs ) == 'table' then
                for i, buff in ipairs( buffs ) do
                    buff = GetSpellInfo( buff )
                    if buff then
                        all:RegisterAura( ns.formatKey( buff ), {
                            id = i,
                            stat = v.stat, 
                            duration = v.duration
                        } )
                        class.trinkets[ k ].buff = ns.formatKey( buff )
                    end
                end
            elseif type( buffs ) == 'number' then
                local buff = GetSpellInfo( buffs )
                if buff then
                    all:RegisterAura( ns.formatKey( buff ), {
                        id = i,
                        stat = v.stat, 
                        duration = v.duration
                    } )
                    class.trinkets[ k ].buff = ns.formatKey( buff )
                end
            end
        end
    end
end


-- Register Azerite Powers before going with generics...
all:RegisterAuras( {
    anduins_dedication = {
        id = 280876,
        duration = 10,
        max_stack = 1,
    },

    sylvanas_resolve = {
        id = 280806,
        duration = 10,
        max_stack = 1,
    },

    archive_of_the_titans = {
        id = 280709,
        duration = 60,
        max_stack = 20,
    },

    battlefield_precision = {
        id = 280855,
        duration = 30,
        max_stack = 25,
    },

    battlefield_focus = {
        id = 280817,
        duration = 30,
        max_stack = 25,
    },

    -- from blightborne infusion; ruinous bolt.  ?
    wandering_soul = {
        id = 280204,
        duration = 14,
        max_stack = 1,
    },

    blood_rite = {
        id = 280409,
        duration = 15,
        max_stack = 1,
    },

    champion_of_azeroth = {
        id = 280713,
        duration = 60,
        max_stack = 4,
    },

    stand_as_one = {
        id = 280858,
        duration = 10,
        max_stack = 1,
    },

    collective_will = {
        id = 280830,
        duration = 10,
        max_stack = 1,
    },

    -- from stronger together
    strength_of_the_humans = {
        id = 280625,
        duration = 10,
        max_stack = 1,
    },

    -- from combined might
    might_of_the_orcs = {
        id = 280841,
        duration = 10,
        max_stack = 1,
    },

    dagger_in_the_back = {
        id = 280286,
        duration = 12,
        tick_time = 3,
        max_stack = 2,
    },

    filthy_transfusion = {
        id = 273836,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
    },

    liberators_might = {
        id = 280852,
        duration = 10,
        max_stack = 1,
    },

    glory_in_battle = {
        id = 280577,
        duration = 10,
        max_stack = 1,
    },

    incite_the_pack = {
        id = 280412,
        duration = 20,
        max_stack = 1,
        copy = 280413,
    },

    last_gift = {
        id = 280862,
        duration = 10,
        max_stack = 1,
    },

    retaliatory_fury = {
        id = 280788,
        duration = 10,
        max_stack = 1,
    },

    meticulous_scheming = {
        id = 273685,
        duration = 8,
        max_stack = 1,
    },

    seize_the_moment = {
        id = 273714,
        duration = 8,
        max_stack = 1,
    },

    normalization_decrease = {
        id = 280654,
        duration = 10,
        max_stack = 1,
    },

    normalization_increase = {
        id = 280653,
        duration = 10,
        max_stack = 1,
    },

    rezans_fury = {
        id = 273794,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
    },

    secrets_of_the_deep = {
        id = 273842,
        duration = 18,
        max_stack = 1,
        copy = 273843, -- Technically, there are distinct buffs but I doubt any APLs will care.
    },

    swirling_sands = {
        id = 280433,
        duration = 12,
        max_stack = 1,
    },

    -- from synaptic_spark_capacitor
    spark_coil = {
        id = 280655,
        duration = 10,
        max_stack = 1,
        copy = 280847,            
    },

    building_pressure = {
        id = 280385,
        duration = 30,
        max_stack = 5,
    },

    tidal_surge = {
        id = 280404,
        duration = 6,
        max_stack = 1,
    },

    tradewinds = {
        id = 281843,
        duration = 15,
        max_stack = 1,
    },

    tradewinds_jumped = {
        id = 281844,
        duration = 8,
        max_stack = 1,
    },

    -- not sure about spell ID, or if there really is a buff...
    unstable_catalyst = {
        id = 281515,
        duration = 8,
        max_stack = 1,
    }
} )


-- "Ring 2" powers.
all:RegisterAuras( {
    ablative_shielding = {
        id = 271543,
        duration = 10,
        max_stack = 1,
    },

    azerite_globules = {
        id = 279956,
        duration = 60,
        max_stack = 3,
    },

    azerite_veins = {
        id = 270674,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
    },

    crystalline_carapace = {
        id = 271538,
        duration = 12,
        max_stack = 1,
    },

    -- earthlink aura?

    elemental_whirl_versatility = {
        id = 268956,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl_mastery = {
        id = 268955,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl_haste = {
        id = 268954,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl_critical_strike = {
        id = 268953,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl = {
        alias = { "elemental_whirl_critical_strike", "elemental_whirl_haste", "elemental_whirl_mastery", "elemental_whirl_versatility" },
        aliasMode = "longest", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = 10,
    },

    lifespeed = {
        id = 267665,
        duration = 3600,
        max_stack = 1,
    },

    overwhelming_power = {
        id = 266180,
        duration = 3600,
        max_stack = 25
    },

    strength_in_numbers = {
        id = 271550,
        duration = 15,
        max_stack = 5,
    },

    unstable_flames = {
        id = 279902,
        duration = 5,
        max_stack = 5,
    },

    winds_of_war = {
        id = 269214,
        duration = 3,
        max_stack = 5,
    },
} )


-- "Ring 3" powers.
all:RegisterAuras( {
    -- autoselfcauterizer snare debuff.
    cauterized = {
        id = 280583,
        duration = 5,
        max_stack = 1,
    },

    bulwark_of_the_masses = {
        id = 270657,
        duration = 15,
        max_stack = 1,
    },

    gemhide = {
        id = 270576,
        duration = 10,
        max_stack = 1,
    },

    personal_absorbotron = {
        id = 280661,
        duration = 20,
        max_stack = 1,
    },

    resounding_protection = {
        id = 269279,
        duration = 30,
        max_stack = 1,
    },

    vampiric_speed = {
        id = 269239,
        duration = 6,
        max_stack = 1,
    },
} )


if not PTR then
    all:RegisterPowers( {
        -- Ablative Shielding
        ablative_shielding = {
            id = 271540,
            triggers = {
                ablative_shielding = { 271544, 271540, 271543 },
            },
        },

        -- Accelerant
        accelerant = {
            id = 272955,
            triggers = {
                accelerant = { 272957, 272955 },
            },
        },

        -- Ace Up Your Sleeve
        ace_up_your_sleeve = {
            id = 278676,
            triggers = {
                ace_up_your_sleeve = { 278676 },
            },
        },

        -- Ancestral Resonance
        ancestral_resonance = {
            id = 277666,
            triggers = {
                ancestral_resonance = { 277942, 277943, 277666 },
            },
        },

        -- Anduin's Dedication (Alliance)
        anduins_dedication = {
            id = 280628,
            triggers = {
                anduins_dedication = { 280876, 280628 },
            },
        },

        -- Anomalous Impact
        anomalous_impact = {
            id = 279867,
            triggers = {
                anomalous_impact = { 279867 },
            },
        },

        -- Arcane Flurry
        arcane_flurry = {
            id = 273265,
            triggers = {
                arcane_flurry = { 273265, 273267 },
            },
        },

        -- Arcane Pressure
        arcane_pressure = {
            id = 274594,
            triggers = {
                arcane_pressure = { 274594 },
            },
        },

        -- Arcane Pummeling
        arcane_pummeling = {
            id = 270669,
            triggers = {
                arcane_pummeling = { 270669, 270670 },
            },
        },

        -- Archive of the Titans (Uldir)
        archive_of_the_titans = {
            id = 280555,
            triggers = {
                archive_of_the_titans = { 280555 },
            },
        },

        -- Auto-Self-Cauterizer (Goblin Engineering)
        autoselfcauterizer = {
            id = 280172,
            triggers = {
                autoselfcauterizer = { 280583, 280172 },
            },
        },

        -- Autumn Leaves
        autumn_leaves = {
            id = 274432,
            triggers = {
                autumn_leaves = { 274432 },
            },
        },

        -- Avenger's Might
        avengers_might = {
            id = 272898,
            triggers = {
                avengers_might = { 272898, 272903 },
            },
        },

        -- Azerite Empowered
        azerite_empowered = {
            id = 263978,
            triggers = {
                azerite_empowered = { 263978 },
            },
        },

        -- Azerite Fortification
        azerite_fortification = {
            id = 268435,
            triggers = {
                azerite_fortification = { 268435, 270659 },
            },
        },

        -- Azerite Globules
        azerite_globules = {
            id = 266936,
            triggers = {
                azerite_globules = { 266936 },
            },
        },

        -- Azerite Veins
        azerite_veins = {
            id = 267683,
            triggers = {
                azerite_veins = { 270674, 267683 },
            },
        },

        -- Barrage Of Many Bombs (Goblin Engineering)
        barrage_of_many_bombs = {
            id = 280163,
            triggers = {
                barrage_of_many_bombs = { 280163 },
            },
        },

        -- Battlefield Focus (Horde)
        battlefield_focus = {
            id = 280582,
            triggers = {
                battlefield_focus = { 280582, 280817 },
            },
        },

        -- Battlefield Precision (Alliance)
        battlefield_precision = {
            id = 280627,
            triggers = {
                battlefield_precision = { 280627, 280855 },
            },
        },

        -- Blade In The Shadows
        blade_in_the_shadows = {
            id = 275896,
            triggers = {
                blade_in_the_shadows = { 279754, 275896 },
            },
        },

        -- Blaster Master
        blaster_master = {
            id = 274596,
            triggers = {
                blaster_master = { 274596, 274598 },
            },
        },

        -- Blessed Portents
        blessed_portents = {
            id = 267889,
            triggers = {
                blessed_portents = { 271843, 267889 },
            },
        },

        -- Blessed Sanctuary
        blessed_sanctuary = {
            id = 273313,
            triggers = {
                blessed_sanctuary = { 273313 },
            },
        },

        -- Blightborne Infusion (Drustvar)
        blightborne_infusion = {
            id = 273823,
            triggers = {
                blightborne_infusion = { 280204, 273823 },
            },
        },

        -- Blood Mist
        blood_mist = {
            id = 279524,
            triggers = {
                blood_mist = { 279524, 279526 },
            },
        },

        -- Blood Rite (Nazmir)
        blood_rite = {
            id = 280407,
            triggers = {
                blood_rite = { 280407, 280409 },
            },
        },

        -- Blood Siphon
        blood_siphon = {
            id = 264108,
            triggers = {
                blood_siphon = { 264108 },
            },
        },

        -- Bloodcraze
        bloodcraze = {
            id = 273420,
            triggers = {
                bloodcraze = { 273428, 273420 },
            },
        },

        -- Bloodsport
        bloodsport = {
            id = 279172,
            triggers = {
                bloodsport = { 279172, 279194 },
            },
        },

        -- Blur of Talons
        blur_of_talons = {
            id = 277653,
            triggers = {
                blur_of_talons = { 277969, 277653 },
            },
        },

        -- Boiling Brew
        boiling_brew = {
            id = 272792,
            triggers = {
                boiling_brew = { 123725, 272792 },
            },
        },

        -- Bone Spike Graveyard
        bone_spike_graveyard = {
            id = 273088,
            triggers = {
                bone_spike_graveyard = { 273088 },
            },
        },

        -- Bones of the Damned
        bones_of_the_damned = {
            id = 278484,
            triggers = {
                bones_of_the_damned = { 278484, 279503 },
            },
        },

        -- Brace for Impact
        brace_for_impact = {
            id = 277636,
            triggers = {
                brace_for_impact = { 277636, 278124 },
            },
        },

        -- Bracing Chill
        bracing_chill = {
            id = 267884,
            triggers = {
                bracing_chill = { 267884 },
            },
        },

        -- Brain Storm
        brain_storm = {
            id = 273326,
            triggers = {
                brain_storm = { 273326, 273330 },
            },
        },

        -- Breaking Dawn
        breaking_dawn = {
            id = 278594,
            triggers = {
                breaking_dawn = { 278594 },
            },
        },

        -- Brigand's Blitz
        brigands_blitz = {
            id = 277676,
            triggers = {
                brigands_blitz = { 277724, 277725, 277676 },
            },
        },

        -- Bulwark of Light
        bulwark_of_light = {
            id = 272976,
            triggers = {
                bulwark_of_light = { 272979, 272976 },
            },
        },

        -- Bulwark of the Masses
        bulwark_of_the_masses = {
            id = 268595,
            triggers = {
                bulwark_of_the_masses = { 268595, 270656 },
            },
        },

        -- Burning Soul
        burning_soul = {
            id = 280012,
            triggers = {
                burning_soul = { 274289, 280012 },
            },
        },

        -- Burst of Life
        burst_of_life = {
            id = 277667,
            triggers = {
                burst_of_life = { 277667 },
            },
        },

        -- Bursting Flare
        bursting_flare = {
            id = 279909,
            triggers = {
                bursting_flare = { 279909, 279913 },
            },
        },

        -- Bury the Hatchet
        bury_the_hatchet = {
            id = 280128,
            triggers = {
                bury_the_hatchet = { 280128, 280212 },
            },
        },

        -- Callous Reprisal
        callous_reprisal = {
            id = 278760,
            triggers = {
                callous_reprisal = { 278999, 278760 },
            },
        },

        -- Cankerous Wounds
        cankerous_wounds = {
            id = 278482,
            triggers = {
                cankerous_wounds = { 278482 },
            },
        },

        -- Cascading Calamity
        cascading_calamity = {
            id = 275372,
            triggers = {
                cascading_calamity = { 275378, 275372 },
            },
        },

        -- Cauterizing Blink
        cauterizing_blink = {
            id = 280015,
            triggers = {
                cauterizing_blink = { 280015, 280177 },
            },
        },

        -- Champion of Azeroth
        champion_of_azeroth = {
            id = 280710,
            triggers = {
                champion_of_azeroth = { 280710, 280713 },
            },
        },

        -- Chaotic Inferno
        chaotic_inferno = {
            id = 278748,
            triggers = {
                chaotic_inferno = { 278748 },
            },
        },

        -- Chorus of Insanity
        chorus_of_insanity = {
            id = 278661,
            triggers = {
                chorus_of_insanity = { 279572, 278661 },
            },
        },

        -- Collective Will (Horde)
        collective_will = {
            id = 280581,
            triggers = {
                collective_will = { 280581, 280830 },
            },
        },

        -- Combined Might (Horde)
        combined_might = {
            id = 280580,
            triggers = {
                might_of_the_orcs = { 280841 },
                combined_might = { 280841, 280580 },
            },
        },

        -- Concentrated Mending
        concentrated_mending = {
            id = 267882,
            triggers = {
                concentrated_mending = { 267882, 272260 },
            },
        },

        -- Contemptuous Homily
        contemptuous_homily = {
            id = 278629,
            triggers = {
                contemptuous_homily = { 278629 },
            },
        },

        -- Craggy Bark
        craggy_bark = {
            id = 276155,
            triggers = {
                craggy_bark = { 276155, 276157 },
            },
        },

        -- Crashing Chaos
        crashing_chaos = {
            id = 277644,
            triggers = {
                crashing_chaos = { 277706, 277644 },
            },
        },

        -- Critical Flash
        critical_flash = {
            id = 273136,
            triggers = {
                critical_flash = { 273136 },
            },
        },

        -- Crushing Assault
        crushing_assault = {
            id = 278751,
            triggers = {
                crushing_assault = { 278751 },
            },
        },

        -- Crystalline Carapace
        crystalline_carapace = {
            id = 271536,
            triggers = {
                crystalline_carapace = { 271536, 271538, 271539 },
            },
        },

        -- Cycle of Binding
        cycle_of_binding = {
            id = 278502,
            triggers = {
                cycle_of_binding = { 278769, 278502 },
            },
        },

        -- Dagger in the Back (Tiragarde Sound)
        dagger_in_the_back = {
            id = 280284,
            triggers = {
                dagger_in_the_back = { 280286, 280284 },
            },
        },

        -- Dance of Death
        dance_of_death = {
            id = 274441,
            triggers = {
                dance_of_death = { 274441, 274443 },
            },
        },

        -- Dauntless Divinity
        dauntless_divinity = {
            id = 273553,
            triggers = {
                dauntless_divinity = { 273555, 273553 },
            },
        },

        -- Dawning Sun
        dawning_sun = {
            id = 276152,
            triggers = {
                dawning_sun = { 276152, 276154 },
            },
        },

        -- Deadshot
        deadshot = {
            id = 272935,
            triggers = {
                deadshot = { 272935, 272940 },
            },
        },

        -- Deafening Crash
        deafening_crash = {
            id = 272824,
            triggers = {
                deafening_crash = { 272824 },
            },
        },

        -- Death Throes
        death_throes = {
            id = 278659,
            triggers = {
                death_throes = { 278659 },
            },
        },

        -- Deathbloom
        deathbloom = {
            id = 275974,
            triggers = {
                deathbloom = { 275974 },
            },
        },

        -- Deep Cuts
        deep_cuts = {
            id = 272684,
            triggers = {
                deep_cuts = { 272684, 272685 },
            },
        },

        -- Deferred Sentence
        deferred_sentence = {
            id = 273147,
            triggers = {
                deferred_sentence = { 273147 },
            },
        },

        -- Demonic Meteor
        demonic_meteor = {
            id = 278737,
            triggers = {
                demonic_meteor = { 278737 },
            },
        },

        -- Depth of the Shadows
        depth_of_the_shadows = {
            id = 275541,
            triggers = {
                depth_of_the_shadows = { 275541, 275544 },
            },
        },

        -- Desperate Power
        desperate_power = {
            id = 280022,
            triggers = {
                desperate_power = { 280208, 280022 },
            },
        },

        -- Divine Revelations
        divine_revelations = {
            id = 275463,
            triggers = {
                divine_revelations = { 275468, 275463, 275469 },
            },
        },

        -- Divine Right
        divine_right = {
            id = 277678,
            triggers = {
                divine_right = { 278523, 277678 },
            },
        },

        -- Double Dose
        double_dose = {
            id = 273007,
            triggers = {
                double_dose = { 273009, 273007 },
            },
        },

        -- Dreadful Calling
        dreadful_calling = {
            id = 278727,
            triggers = {
                dreadful_calling = { 278727, 233490 },
            },
        },

        -- Duck and Cover
        duck_and_cover = {
            id = 280014,
            triggers = {
                duck_and_cover = { 280170, 280014 },
            },
        },

        -- Duplicative Incineration
        duplicative_incineration = {
            id = 278538,
            triggers = {
                duplicative_incineration = { 278538 },
            },
        },

        -- Earthlink
        earthlink = {
            id = 279926,
            triggers = {
                earthlink = { 279926 },
            },
        },

        -- Ebb and Flow
        ebb_and_flow = {
            id = 273597,
            triggers = {
                ebb_and_flow = { 273597 },
            },
        },

        -- Echo of the Elementals
        echo_of_the_elementals = {
            id = 275381,
            triggers = {
                echo_of_the_elementals = { 275385, 275381 },
            },
        },

        -- Echoing Blades
        echoing_blades = {
            id = 287649,
            triggers = {
                echoing_blades = { 287649, 287650, 287653 },
            }
        },

        -- Echoing Howl
        echoing_howl = {
            id = 275917,
            triggers = {
                echoing_howl = { 275917 },
            },
        },

        -- Eldritch Warding
        eldritch_warding = {
            id = 274379,
            triggers = {
                eldritch_warding = { 274379 },
            },
        },

        -- Elemental Whirl
        elemental_whirl = {
            id = 263984,
            triggers = {
                elemental_whirl = { 268953, 268954, 268956, 268955, 263984 },
            },
        },

        -- Elusive Footwork
        elusive_footwork = {
            id = 278571,
            triggers = {
                elusive_footwork = { 278571 },
            },
        },

        -- Embrace of the Darkfallen
        embrace_of_the_darkfallen = {
            id = 275924,
            triggers = {
                embrace_of_the_darkfallen = { 275926, 275924 },
            },
        },

        -- Enduring Luminescence
        enduring_luminescence = {
            id = 278643,
            triggers = {
                enduring_luminescence = { 278643 },
            },
        },

        -- Ephemeral Recovery
        ephemeral_recovery = {
            id = 267886,
            triggers = {
                ephemeral_recovery = { 267886, 272572 },
            },
        },

        -- Essence Sever
        essence_sever = {
            id = 278501,
            triggers = {
                essence_sever = { 279450, 278501 },
            },
        },

        -- Eternal Rune Weapon
        eternal_rune_weapon = {
            id = 278479,
            triggers = {
                eternal_rune_weapon = { 278543, 278479 },
            },
        },

        -- Everlasting Light
        everlasting_light = {
            id = 277681,
            triggers = {
                everlasting_light = { 277681 },
            },
        },

        -- Excoriate
        excoriate = {
            id = 276007,
            triggers = {
                excoriate = { 276007 },
            },
        },

        -- Executioner's Precision
        executioners_precision = {
            id = 272866,
            triggers = {
                executioners_precision = { 272870, 272866 },
            },
        },

        -- Explosive Echo
        explosive_echo = {
            id = 278537,
            triggers = {
                explosive_echo = { 278537 },
            },
        },

        -- Explosive Potential
        explosive_potential = {
            id = 275395,
            triggers = {
                explosive_potential = { 275395, 275398 },
            },
        },

        -- Expurgation
        expurgation = {
            id = 273473,
            triggers = {
                expurgation = { 273481, 273473 },
            },
        },

        -- Eyes of Rage
        eyes_of_rage = {
            id = 278500,
            triggers = {
                eyes_of_rage = { 278500 },
            },
        },

        -- Fan of Blades
        fan_of_blades = {
            id = 278664,
            triggers = {
                fan_of_blades = { 278664 },
            },
        },

        -- Feeding Frenzy
        feeding_frenzy = {
            id = 278529,
            triggers = {
                feeding_frenzy = { 217200, 278529 },
            },
        },

        -- Festering Doom
        festering_doom = {
            id = 272738,
            triggers = {
                festering_doom = { 272741, 272738 },
            },
        },

        -- Festermight
        festermight = {
            id = 274081,
            triggers = {
                festermight = { 274081 },
            },
        },

        -- Filthy Transfusion (Nazmir)
        filthy_transfusion = {
            id = 273834,
            triggers = {
                filthy_transfusion = { 273836, 273834 },
            },
        },

        -- Firemind
        firemind = {
            id = 278539,
            triggers = {
                firemind = { 278539, 279715 },
            },
        },

        -- Fit to Burst
        fit_to_burst = {
            id = 275892,
            triggers = {
                fit_to_burst = { 275892, 275894 },
            },
        },

        -- Flames of Alacrity
        flames_of_alacrity = {
            id = 272932,
            triggers = {
                flames_of_alacrity = { 272934, 272932 },
            },
        },

        -- Flashpoint
        flashpoint = {
            id = 275425,
            triggers = {
                flashpoint = { 275425, 275429 },
            },
        },

        -- Focused Fire
        focused_fire = {
            id = 278531,
            triggers = {
                focused_fire = { 278531, 257044 },
            },
        },

        -- Font of Life
        font_of_life = {
            id = 279875,
            triggers = {
                font_of_life = { 279875 },
            },
        },

        -- Footpad
        footpad = {
            id = 274692,
            triggers = {
                footpad = { 274692, 274695 },
            },
        },

        -- Forbidden Knowledge
        forbidden_knowledge = {
            id = 278738,
            triggers = {
                forbidden_knowledge = { 279666, 278738 },
            },
        },

        -- Fortifying Auras
        fortifying_auras = {
            id = 273134,
            triggers = {
                fortifying_auras = { 273134 },
            },
        },

        -- Frigid Grasp
        frigid_grasp = {
            id = 278542,
            triggers = {
                frigid_grasp = { 278542, 279684 },
            },
        },

        -- Frozen Tempest
        frozen_tempest = {
            id = 278487,
            triggers = {
                frozen_tempest = { 278487 },
            },
        },

        -- Fungal Essence
        fungal_essence = {
            id = 272802,
            triggers = {
                fungal_essence = { 272802, 272807 },
            },
        },

        -- Furious Gaze
        furious_gaze = {
            id = 273231,
            triggers = {
                furious_gaze = { 273232, 273231 },
            },
        },

        -- Gallant Steed
        gallant_steed = {
            id = 280017,
            triggers = {
                gallant_steed = { 280191, 280192, 280017 },
            },
        },

        -- Galvanizing Spark
        galvanizing_spark = {
            id = 278536,
            triggers = {
                galvanizing_spark = { 278536 },
            },
        },

        -- Gaping Maw
        gaping_maw = {
            id = 275968,
            triggers = {
                gaping_maw = { 275968, 275972 },
            },
        },

        -- Gathering Storm
        gathering_storm = {
            id = 273409,
            triggers = {
                gathering_storm = { 273415, 273409 },
            },
        },

        -- Gemhide
        gemhide = {
            id = 268596,
            triggers = {
                gemhide = { 268596, 270576 },
            },
        },

        -- Gift of Forgiveness
        gift_of_forgiveness = {
            id = 277680,
            triggers = {
                gift_of_forgiveness = { 277680 },
            },
        },

        -- Glacial Assault
        glacial_assault = {
            id = 279854,
            triggers = {
                glacial_assault = { 279856, 279854 },
            },
        },

        -- Glacial Contagion
        glacial_contagion = {
            id = 274070,
            triggers = {
                glacial_contagion = { 274070, 274074 },
            },
        },

        -- Glory in Battle (Horde)
        glory_in_battle = {
            id = 280577,
            triggers = {
                glory_in_battle = { 280780, 280577 },
            },
        },

        -- Gory Regeneration
        gory_regeneration = {
            id = 278510,
            triggers = {
                gory_regeneration = { 278510 },
            },
        },

        -- Grace of the Justicar
        grace_of_the_justicar = {
            id = 278593,
            triggers = {
                grace_of_the_justicar = { 278593, 278785 },
            },
        },

        -- Grove Tending
        grove_tending = {
            id = 279778,
            triggers = {
                grove_tending = { 279778, 279793 },
            },
        },

        -- Guardian's Wrath
        guardians_wrath = {
            id = 278511,
            triggers = {
                guardians_wrath = { 278511 },
            },
        },

        -- Gushing Lacerations
        gushing_lacerations = {
            id = 278509,
            triggers = {
                gushing_lacerations = { 278509 },
            },
        },

        -- Gutripper
        gutripper = {
            id = 266937,
            triggers = {
                gutripper = { 270668, 266937 },
            },
        },

        -- Harrowing Decay
        harrowing_decay = {
            id = 275929,
            triggers = {
                harrowing_decay = { 275931, 275929 },
            },
        },

        -- Haze of Rage
        haze_of_rage = {
            id = 273262,
            triggers = {
                haze_of_rage = { 273264, 273262 },
            },
        },

        -- Healing Hammer
        healing_hammer = {
            id = 273142,
            triggers = {
                healing_hammer = { 273142 },
            },
        },

        -- Heed My Call
        heed_my_call = {
            id = 263987,
            triggers = {
                heed_my_call = { 263987 },
            },
        },

        -- High Noon
        high_noon = {
            id = 278505,
            triggers = {
                high_noon = { 278505 },
            },
        },

        -- Horrid Experimentation
        horrid_experimentation = {
            id = 273095,
            triggers = {
                horrid_experimentation = { 273095 },
            },
        },

        -- Icy Citadel
        icy_citadel = {
            id = 272718,
            triggers = {
                icy_citadel = { 272718, 272723 },
            },
        },

        -- Igneous Potential
        igneous_potential = {
            id = 279829,
            triggers = {
                igneous_potential = { 279829 },
            },
        },

        -- Impassive Visage
        impassive_visage = {
            id = 268437,
            triggers = {
                impassive_visage = { 270117, 268437 },
            },
        },

        -- In The Rhythm
        in_the_rhythm = {
            id = 264198,
            triggers = {
                in_the_rhythm = { 272733, 264198 },
            },
        },

        -- Incite the Pack (Zuldazar)
        incite_the_pack = {
            id = 280410,
            triggers = {
                incite_the_pack = { 280413, 280410, 280412 },
            },
        },

        -- Indomitable Justice
        indomitable_justice = {
            id = 275496,
            triggers = {
                indomitable_justice = { 275496 },
            },
        },

        -- Inevitability
        inevitability = {
            id = 278683,
            triggers = {
                inevitability = { 278683 },
            },
        },

        -- Inevitable Demise
        inevitable_demise = {
            id = 273521,
            triggers = {
                inevitable_demise = { 273521, 273525 },
            },
        },

        -- Infernal Armor
        infernal_armor = {
            id = 273236,
            triggers = {
                infernal_armor = { 273239, 273236 },
            },
        },

        -- Infinite Fury
        infinite_fury = {
            id = 277638,
            triggers = {
                infinite_fury = { 278134, 277638 },
            },
        },

        -- Inner Light
        inner_light = {
            id = 275477,
            triggers = {
                inner_light = { 275481, 275477 },
            },
        },

        -- Inspiring Beacon
        inspiring_beacon = {
            id = 273130,
            triggers = {
                inspiring_beacon = { 273130 },
            },
        },

        -- Inspiring Vanguard
        inspiring_vanguard = {
            id = 278609,
            triggers = {
                inspiring_vanguard = { 279397, 278609 },
            },
        },

        -- Invigorating Brew
        invigorating_brew = {
            id = 269621,
            triggers = {
                invigorating_brew = { 269621, 269622 },
            },
        },

        -- Iron Fists
        iron_fists = {
            id = 272804,
            triggers = {
                iron_fists = { 272804, 272806 },
            },
        },

        -- Iron Fortress
        iron_fortress = {
            id = 278765,
            triggers = {
                iron_fortress = { 278765 },
            },
        },

        -- Iron Jaws
        iron_jaws = {
            id = 276021,
            triggers = {
                iron_jaws = { 276021, 276026 },
            },
        },

        -- Judicious Defense
        judicious_defense = {
            id = 277675,
            triggers = {
                judicious_defense = { 277675, 278574 },
            },
        },

        -- Killer Frost
        killer_frost = {
            id = 278480,
            triggers = {
                killer_frost = { 278480 },
            },
        },

        -- Laser Matrix (Uldir)
        laser_matrix = {
            id = 280559,
            triggers = {
                laser_matrix = { 280559 },
            },
        },

        -- Last Gift (Alliance)
        last_gift = {
            id = 280624,
            triggers = {
                last_gift = { 280862, 280624 },
            },
        },

        -- Last Surprise
        last_surprise = {
            id = 278489,
            triggers = {
                last_surprise = { 278489 },
            },
        },

        -- Latent Chill
        latent_chill = {
            id = 273093,
            triggers = {
                latent_chill = { 273093 },
            },
        },

        -- Latent Poison
        latent_poison = {
            id = 273283,
            triggers = {
                latent_poison = { 273283 },
            },
        },

        -- Lava Shock
        lava_shock = {
            id = 273448,
            triggers = {
                lava_shock = { 273448, 273453 },
            },
        },

        -- Layered Mane
        layered_mane = {
            id = 279552,
            triggers = {
                layered_mane = { 279552 },
            },
        },

        -- Liberator's Might (Alliance)
        liberators_might = {
            id = 280623,
            triggers = {
                liberators_might = { 280852, 280623 },
            },
        },

        -- Lifeblood
        lifeblood = {
            id = 274418,
            triggers = {
                lifeblood = { 274420, 274418 },
            },
        },

        -- Lifespeed
        lifespeed = {
            id = 267665,
            triggers = {
                lifespeed = { 267665 },
            },
        },

        -- Lightning Conduit
        lightning_conduit = {
            id = 275388,
            triggers = {
                lightning_conduit = { 275388, 275394, 275391 },
            },
        },

        -- Lively Spirit
        lively_spirit = {
            id = 279642,
            triggers = {
                lively_spirit = { 279642, 279648 },
            },
        },

        -- Longstrider
        longstrider = {
            id = 268594,
            triggers = {
                longstrider = { 268594 },
            },
        },

        -- Lord of War
        lord_of_war = {
            id = 278752,
            triggers = {
                lord_of_war = { 278752, 279203 },
            },
        },

        -- Lunar Shrapnel
        lunar_shrapnel = {
            id = 278507,
            triggers = {
                lunar_shrapnel = { 278507 },
            },
        },

        -- March of the Damned
        march_of_the_damned = {
            id = 280011,
            triggers = {
                march_of_the_damned = { 280149, 280011 },
            },
        },

        -- Marrowblood
        marrowblood = {
            id = 274057,
            triggers = {
                marrowblood = { 274057 },
            },
        },

        -- Martyr's Breath
        martyrs_breath = {
            id = 273027,
            triggers = {
                martyrs_breath = { 273027, 273034 },
            },
        },

        -- Masterful Instincts
        masterful_instincts = {
            id = 273344,
            triggers = {
                masterful_instincts = { 273349, 273344 },
            },
        },

        -- Meridian Strikes
        meridian_strikes = {
            id = 278580,
            triggers = {
                meridian_strikes = { 278580 },
            },
        },

        -- Meticulous Scheming (Tiragarde Sound)
        meticulous_scheming = {
            id = 273682,
            triggers = {
                seize_the_moment = { 273714 },
                meticulous_scheming = { 273714, 273682 },
            },
        },

        -- Misty Peaks
        misty_peaks = {
            id = 275975,
            triggers = {
                misty_peaks = { 276025, 275975 },
            },
        },

        -- Moment of Compassion
        moment_of_compassion = {
            id = 273513,
            triggers = {
                moment_of_compassion = { 273513 },
            },
        },

        -- Moment of Glory
        moment_of_glory = {
            id = 280023,
            triggers = {
                moment_of_glory = { 280210, 280023 },
            },
        },

        -- Moment of Repose
        moment_of_repose = {
            id = 272775,
            triggers = {
                moment_of_repose = { 272775, 272776 },
            },
        },

        -- Natural Harmony
        natural_harmony = {
            id = 278697,
            triggers = {
                natural_harmony_nature = { 279033 },
                natural_harmony_frost = { 279029 },
                natural_harmony_fire = { 279028 },
                natural_harmony = { 278697, 279028 },
            },
        },

        -- Night's Vengeance
        nights_vengeance = {
            id = 273418,
            triggers = {
                nights_vengeance = { 273418, 273424 },
            },
        },

        -- Niuzao's Blessing
        niuzaos_blessing = {
            id = 277665,
            triggers = {
                niuzaos_blessing = { 278535, 277665 },
            },
        },

        -- Nothing Personal
        nothing_personal = {
            id = 286581,
            triggers = {
                nothing_personal = { 286581, 286579, 289467 },
            }
        },

        -- On My Way
        on_my_way = {
            id = 267879,
            triggers = {
                on_my_way = { 267879 },
            },
        },

        -- Open Palm Strikes
        open_palm_strikes = {
            id = 279918,
            triggers = {
                open_palm_strikes = { 279918 },
            },
        },

        -- Overflowing Mists
        overflowing_mists = {
            id = 273328,
            triggers = {
                overflowing_mists = { 273328, 273348 },
            },
        },

        -- Overflowing Shores
        overflowing_shores = {
            id = 277658,
            triggers = {
                overflowing_shores = { 277658, 278095 },
            },
        },

        -- Overwhelming Power
        overwhelming_power = {
            id = 266180,
            triggers = {
                overwhelming_power = { 266180 },
            },
        },

        -- Pack Alpha
        pack_alpha = {
            id = 278528,
            triggers = {
                pack_alpha = { 278528 },
            },
        },

        -- Pack Spirit
        pack_spirit = {
            id = 280021,
            triggers = {
                pack_spirit = { 280205, 280021 },
            },
        },

        -- Packed Ice
        packed_ice = {
            id = 272968,
            triggers = {
                packed_ice = { 272968 },
            },
        },

        -- Paradise Lost
        paradise_lost = {
            id = 278675,
            triggers = {
                paradise_lost = { 278962, 278675 },
            },
        },

        -- Perforate
        perforate = {
            id = 277673,
            triggers = {
                perforate = { 277673, 277720 },
            },
        },

        -- Permeating Glow
        permeating_glow = {
            id = 272780,
            triggers = {
                permeating_glow = { 272783, 272780 },
            },
        },

        -- Personal Absorb-o-Tron (Gnomish Engineering)
        personal_absorbotron = {
            id = 280181,
            triggers = {
                personal_absorbotron = { 280660, 280181 },
            },
        },

        -- Poisoned Wire
        poisoned_wire = {
            id = 276072,
            triggers = {
                poisoned_wire = { 276072, 276083 },
            },
        },

        -- Power of the Moon
        power_of_the_moon = {
            id = 273367,
            triggers = {
                power_of_the_moon = { 273367 },
            },
        },

        -- Prayerful Litany
        prayerful_litany = {
            id = 275602,
            triggers = {
                prayerful_litany = { 275602 },
            },
        },

        -- Preheat
        preheat = {
            id = 273331,
            triggers = {
                preheat = { 273331, 273333 },
            },
        },

        -- Pressure Point
        pressure_point = {
            id = 278577,
            triggers = {
                pressure_point = { 278577 },
            },
        },

        -- Primal Instincts
        primal_instincts = {
            id = 279806,
            triggers = {
                primal_instincts = { 279806, 279810 },
            },
        },

        -- Primal Primer
        primal_primer = {
            id = 272992,
            triggers = {
                primal_primer = { 272992, 273006 },
            },
        },

        -- Pulverizing Blows
        pulverizing_blows = {
            id = 275632,
            triggers = {
                pulverizing_blows = { 275672, 275632 },
            },
        },

        -- Radiant Incandescence
        radiant_incandescence = {
            id = 277674,
            triggers = {
                radiant_incandescence = { 277674, 278147, 278145 },
            },
        },

        -- Raking Ferocity
        raking_ferocity = {
            id = 273338,
            triggers = {
                gushing_lacerations = { 279471 },
                raking_ferocity = { 273338, 273340 },
            },
        },

        -- Rampant Growth
        rampant_growth = {
            id = 278515,
            triggers = {
                rampant_growth = { 278515 },
            },
        },

        -- Rapid Reload
        rapid_reload = {
            id = 278530,
            triggers = {
                multishot = { 278565 },
                rapid_reload = { 278530 },
            },
        },

        -- Reawakening
        reawakening = {
            id = 274813,
            triggers = {
                reawakening = { 274813, 274814 },
            },
        },

        -- Reckless Flurry
        reckless_flurry = {
            id = 278758,
            triggers = {
                reckless_flurry = { 278758 },
            },
        },

        -- Reinforced Plating
        reinforced_plating = {
            id = 275860,
            triggers = {
                reinforced_plating = { 275860, 275867 },
            },
        },

        -- Rejuvenating Grace
        rejuvenating_grace = {
            id = 273131,
            triggers = {
                rejuvenating_grace = { 273131 },
            },
        },

        -- Relational Normalization Gizmo (Gnomish Engineering)
        relational_normalization_gizmo = {
            id = 280178,
            triggers = {
                relational_normalization_gizmo = { 280653, 280178 },
            },
        },

        -- Relentless Inquisitor
        relentless_inquisitor = {
            id = 278617,
            triggers = {
                relentless_inquisitor = { 278617, 279204 },
            },
        },

        -- Resounding Protection
        resounding_protection = {
            id = 263962,
            triggers = {
                resounding_protection = { 263962, 269279 },
            },
        },

        -- Retaliatory Fury (Horde)
        retaliatory_fury = {
            id = 280579,
            triggers = {
                retaliatory_fury = { 280579, 280788 },
            },
        },

        -- Revel in Pain
        revel_in_pain = {
            id = 272983,
            triggers = {
                revel_in_pain = { 272983, 272987 },
            },
        },

        -- Revolving Blades
        revolving_blades = {
            id = 279581,
            triggers = {
                revolving_blades = { 279581 },
            },
        },

        -- Rezan's Fury (Zuldazar)
        rezans_fury = {
            id = 273790,
            triggers = {
                rezans_fury = { 273794, 273790 },
            },
        },

        -- Ricocheting Inflatable Pyrosaw (Goblin Engineering)
        ricocheting_inflatable_pyrosaw = {
            id = 280168,
            triggers = {
                ricocheting_inflatable_pyrosaw = { 280168 },
            },
        },

        -- Righteous Flames
        righteous_flames = {
            id = 273140,
            triggers = {
                righteous_flames = { 273140 },
            },
        },

        -- Rigid Carapace
        rigid_carapace = {
            id = 275350,
            triggers = {
                rigid_carapace = { 275350, 275351 },
            },
        },

        -- Roiling Storm
        roiling_storm = {
            id = 278719,
            triggers = {
                roiling_storm = { 279515, 278719 },
            },
        },

        -- Rolling Havoc
        rolling_havoc = {
            id = 278747,
            triggers = {
                rolling_havoc = { 278931, 278747 },
            },
        },

        -- Ruinous Bolt (Drustvar)
        ruinous_bolt = {
            id = 273150,
            triggers = {
                ruinous_bolt = { 273150, 280204 },
            },
        },

        -- Rumbling Tremors
        rumbling_tremors = {
            id = 278709,
            triggers = {
                rumbling_tremors = { 279556, 279523, 278709 },
            },
        },

        -- Runic Barrier
        runic_barrier = {
            id = 280010,
            triggers = {
                runic_barrier = { 280010 },
            },
        },

        -- Sacred Flame
        sacred_flame = {
            id = 278655,
            triggers = {
                sacred_flame = { 278655 },
            },
        },

        -- Sanctum
        sanctum = {
            id = 274366,
            triggers = {
                sanctum = { 274369, 274366 },
            },
        },

        -- Savior
        savior = {
            id = 267883,
            triggers = {
                savior = { 267883, 270679 },
            },
        },

        -- Scent of Blood
        scent_of_blood = {
            id = 277679,
            triggers = {
                scent_of_blood = { 277679, 277731 },
            },
        },

        -- Searing Dialogue
        searing_dialogue = {
            id = 272788,
            triggers = {
                searing_dialogue = { 272788 },
            },
        },

        -- Secrets of the Deep (Stormsong Valley)
        secrets_of_the_deep = {
            id = 273829,
            triggers = {
                secrets_of_the_deep = { 273842, 273829 },
            },
        },

        -- Seething Power
        seething_power = {
            id = 275934,
            triggers = {
                seething_power = { 275936, 275934 },
            },
        },

        -- Seismic Wave
        seismic_wave = {
            id = 277639,
            triggers = {
                seismic_wave = { 277639 },
            },
        },

        -- Self Reliance
        self_reliance = {
            id = 268600,
            triggers = {
                self_reliance = { 270661, 268600 },
            },
        },

        -- Serene Spirit
        serene_spirit = {
            id = 274412,
            triggers = {
                serene_spirit = { 274412, 274416 },
            },
        },

        -- Serrated Jaws
        serrated_jaws = {
            id = 272717,
            triggers = {
                serrated_jaws = { 272717 },
            },
        },

        -- Shadow's Bite
        shadows_bite = {
            id = 272944,
            triggers = {
                shadows_bite = { 272945, 272944 },
            },
        },

        -- Sharpened Blades
        sharpened_blades = {
            id = 272911,
            triggers = {
                sharpened_blades = { 272916, 272911 },
            },
        },

        -- Shellshock
        shellshock = {
            id = 274355,
            triggers = {
                shellshock = { 274355, 274357 },
            },
        },

        -- Shimmering Haven
        shimmering_haven = {
            id = 271557,
            triggers = {
                shimmering_haven = { 271560, 271557 },
            },
        },

        -- Shredding Fury
        shredding_fury = {
            id = 274424,
            triggers = {
                shredding_fury = { 274426, 274424 },
            },
        },

        -- Shrouded Mantle
        shrouded_mantle = {
            id = 280020,
            triggers = {
                shrouded_mantle = { 280020, 280200 },
            },
        },

        -- Shrouded Suffocation
        shrouded_suffocation = {
            id = 278666,
            triggers = {
                shrouded_suffocation = { 278666 },
            },
        },

        -- Simmering Rage
        simmering_rage = {
            id = 278757,
            triggers = {
                simmering_rage = { 278757, 278841 },
            },
        },

        -- Snake Eyes
        snake_eyes = {
            id = 275846,
            triggers = {
                snake_eyes = { 275863, 275846 },
            },
        },

        -- Soaring Shield
        soaring_shield = {
            id = 278605,
            triggers = {
                soaring_shield = { 278605, 278954 },
            },
        },

        -- Soothing Waters
        soothing_waters = {
            id = 272989,
            triggers = {
                soothing_waters = { 272989 },
            },
        },

        -- Soulmonger
        soulmonger = {
            id = 274344,
            triggers = {
                soulmonger = { 274344, 274346 },
            },
        },

        -- Spiteful Apparitions
        spiteful_apparitions = {
            id = 277682,
            triggers = {
                spiteful_apparitions = { 277682 },
            },
        },

        -- Spouting Spirits
        spouting_spirits = {
            id = 278715,
            triggers = {
                spouting_spirits = { 278715 },
            },
        },

        -- Staggering Strikes
        staggering_strikes = {
            id = 273464,
            triggers = {
                staggering_strikes = { 273464, 273469 },
            },
        },

        -- Stalwart Protector
        stalwart_protector = {
            id = 274388,
            triggers = {
                stalwart_protector = { 274395, 274388 },
            },
        },

        -- Stand As One (Alliance)
        stand_as_one = {
            id = 280626,
            triggers = {
                stand_as_one = { 280626, 280858 },
            },
        },

        -- Steady Aim
        steady_aim = {
            id = 277651,
            triggers = {
                steady_aim = { 277651, 277959 },
            },
        },

        -- Storm of Steel
        storm_of_steel = {
            id = 273452,
            triggers = {
                storm_of_steel = { 273452, 273455 },
            },
        },

        -- Streaking Stars
        streaking_stars = {
            id = 272871,
            triggers = {
                streaking_star = { 272873 },
                streaking_stars = { 272871 },
            },
        },

        -- Strength in Numbers
        strength_in_numbers = {
            id = 271546,
            triggers = {
                strength_in_numbers = { 271546, 271550 },
            },
        },

        -- Strength of Earth
        strength_of_earth = {
            id = 273461,
            triggers = {
                strength_of_earth = { 273461, 273466 },
            },
        },

        -- Strength of Spirit
        strength_of_spirit = {
            id = 274762,
            triggers = {
                strength_of_spirit = { 274762, 274774 },
            },
        },

        -- Stronger Together (Alliance)
        stronger_together = {
            id = 280625,
            triggers = {
                strength_of_the_humans = { 280866 },
                stronger_together = { 280625, 280866 },
            },
        },

        -- Sudden Onset
        sudden_onset = {
            id = 278721,
            triggers = {
                sudden_onset = { 278721 },
            },
        },

        -- Sunblaze
        sunblaze = {
            id = 274397,
            triggers = {
                sunblaze = { 274399, 274397 },
            },
        },

        -- Sunrise Technique
        sunrise_technique = {
            id = 273291,
            triggers = {
                sunrise_technique = { 275673, 273298, 273291 },
            },
        },

        -- Supreme Commander
        supreme_commander = {
            id = 279878,
            triggers = {
                supreme_commander = { 279885, 279878 },
            },
        },

        -- Surging Tides
        surging_tides = {
            id = 278713,
            triggers = {
                surging_tides = { 278713, 279187 },
            },
        },

        -- Sweep the Leg
        sweep_the_leg = {
            id = 280016,
            triggers = {
                sweep_the_leg = { 280187, 280016 },
            },
        },

        -- Swelling Stream
        swelling_stream = {
            id = 275488,
            triggers = {
                swelling_stream = { 275488 },
            },
        },

        -- Swift Roundhouse
        swift_roundhouse = {
            id = 277669,
            triggers = {
                swift_roundhouse = { 278710, 277669 },
            },
        },

        -- Swirling Sands (Vol'dun)
        swirling_sands = {
            id = 280429,
            triggers = {
                swirling_sands = { 280429, 280433 },
            },
        },

        -- Sylvanas' Resolve (Horde)
        sylvanas_resolve = {
            id = 280598,
            triggers = {
                sylvanas_resolve = { 280809, 280598 },
            },
        },

        -- Synapse Shock
        synapse_shock = {
            id = 277671,
            triggers = {
                synapse_shock = { 277960, 277671 },
            },
        },

        -- Synaptic Spark Capacitor (Gnomish Engineering)
        synaptic_spark_capacitor = {
            id = 280174,
            triggers = {
                synaptic_spark_capacitor = { 280655, 280174 },
            },
        },

        -- Synergistic Growth
        synergistic_growth = {
            id = 267892,
            triggers = {
                synergistic_growth = { 272090, 267892 },
            },
        },

        -- Test of Might
        test_of_might = {
            id = 275529,
            triggers = {
                test_of_might = { 275529, 275540 },
            },
        },

        -- The First Dance
        the_first_dance = {
            id = 278681,
            triggers = {
                the_first_dance = { 278681, 278981 },
            },
        },

        -- Thirsting Blades
        thirsting_blades = {
            id = 278493,
            triggers = {
                thirsting_blades = { 278493 },
            },
        },

        -- Thought Harvester
        thought_harvester = {
            id = 273319,
            triggers = {
                thought_harvester = { 273319 },
                harvested_thoughts = { 273321 },
            },
        },

        -- Thunderous Blast (Vol'dun)
        thunderous_blast = {
            id = 280380,
            triggers = {
                thunderous_blast = { 280380, 280384 },
            },
        },

        -- Tidal Surge (Stormsong Valley)
        tidal_surge = {
            id = 280402,
            triggers = {
                tidal_surge = { 280402, 280404 },
            },
        },

        -- Tradewinds (Tiragarde Sound)
        tradewinds = {
            id = 281841,
            triggers = {
                tradewinds = { 281841, 281843, 281844 },
            },
        },

        -- Trailing Embers
        trailing_embers = {
            id = 277656,
            triggers = {
                trailing_embers = { 277703, 277656 },
            },
        },

        -- Training of Niuzao
        training_of_niuzao = {
            id = 278569,
            triggers = {
                training_of_niuzao = { 278569 },
            },
        },

        -- Trample the Weak
        trample_the_weak = {
            id = 272836,
            triggers = {
                trample_the_weak = { 272836, 272838 },
            },
        },

        -- Tunnel of Ice
        tunnel_of_ice = {
            id = 277663,
            triggers = {
                tunnel_of_ice = { 277663, 277904 },
            },
        },

        -- Twist Magic
        twist_magic = {
            id = 280018,
            triggers = {
                twist_magic = { 280018 },
            },
        },

        -- Twist the Knife
        twist_the_knife = {
            id = 273488,
            triggers = {
                twist_the_knife = { 273488 },
            },
        },

        -- Twisted Claws
        twisted_claws = {
            id = 275906,
            triggers = {
                twisted_claws = { 275906, 275909 },
            },
        },

        -- Umbral Blaze
        umbral_blaze = {
            id = 273523,
            triggers = {
                umbral_blaze = { 273523, 273526 },
            },
        },

        -- Unbound Chaos
        unbound_chaos = {
            id = 275144,
            triggers = {
                unbound_chaos = { 275144 },
            },
        },

        -- Unerring Vision
        unerring_vision = {
            id = 274444,
            triggers = {
                unerring_vision = { 274444, 274447 },
            },
        },

        -- Unstable Catalyst
        unstable_catalyst = {
            id = 281514,
            triggers = {
                unstable_catalyst = { 281516, 281514 },
            },
        },

        -- Unstable Flames
        unstable_flames = {
            id = 279899,
            triggers = {
                unstable_flames = { 279899, 279902 },
            },
        },

        -- Up Close And Personal
        up_close_and_personal = {
            id = 278533,
            triggers = {
                up_close_and_personal = { 278533 },
            },
        },

        -- Uplifted Spirits
        uplifted_spirits = {
            id = 278576,
            triggers = {
                uplifted_spirits = { 278576 },
            },
        },

        -- Ursoc's Endurance
        ursocs_endurance = {
            id = 280013,
            triggers = {
                ursocs_endurance = { 280165, 280013 },
            },
        },

        -- Vampiric Speed
        vampiric_speed = {
            id = 268599,
            triggers = {
                vampiric_speed = { 268599, 269238, 269239 },
            },
        },

        -- Venomous Fangs
        venomous_fangs = {
            id = 274590,
            triggers = {
                venomous_fangs = { 274590 },
            },
        },

        -- Waking Dream
        waking_dream = {
            id = 278513,
            triggers = {
                waking_dream = { 278513 },
            },
        },

        -- Weal and Woe
        weal_and_woe = {
            id = 273307,
            triggers = {
                weal_and_woe = { 273307 },
            },
        },

        -- Whispers of the Damned
        whispers_of_the_damned = {
            id = 275722,
            triggers = {
                whispers_of_the_damned = { 275726, 275722 },
            },
        },

        -- Whiteout
        whiteout = {
            id = 278541,
            triggers = {
                whiteout = { 278541 },
            },
        },

        -- Wild Fleshrending
        wild_fleshrending = {
            id = 279527,
            triggers = {
                wild_fleshrending = { 279527 },
            },
        },

        -- Wilderness Survival
        wilderness_survival = {
            id = 278532,
            triggers = {
                wilderness_survival = { 278532 },
            },
        },

        -- Wildfire Cluster
        wildfire_cluster = {
            id = 272742,
            triggers = {
                wildfire_cluster = { 272742, 272745 },
            },
        },

        -- Winds of War
        winds_of_war = {
            id = 267671,
            triggers = {
                winds_of_war = { 267671, 269214 },
            },
        },

        -- Winter's Reach
        winters_reach = {
            id = 273346,
            triggers = {
                winters_reach = { 273347, 273346 },
            },
        },

        -- Word of Mending
        word_of_mending = {
            id = 278645,
            triggers = {
                word_of_mending = { 278645 },
            },
        },

        -- Woundbinder
        woundbinder = {
            id = 267880,
            triggers = {
                woundbinder = { 267880, 269085 },
            },
        },

        -- Wracking Brilliance
        wracking_brilliance = {
            id = 272891,
            triggers = {
                wracking_brilliance = { 272893, 272891 },
            },
        },

        -- Zealotry
        zealotry = {
            id = 278615,
            triggers = {
                zealotry = { 278989, 278615 },
            },
        },
    } )
else
    all:RegisterPowers( {
        -- Ablative Shielding
        ablative_shielding = {
            id = 271540,
            triggers = {
                ablative_shielding = { 271544, 271540, 271543 },
            },
        },

        -- Ace Up Your Sleeve
        ace_up_your_sleeve = {
            id = 278676,
            triggers = {
                ace_up_your_sleeve = { 278676 },
            },
        },

        -- Ancestral Resonance
        ancestral_resonance = {
            id = 277666,
            triggers = {
                ancestral_resonance = { 277666, 277943 },
            },
        },

        -- Ancient Ankh Talisman
        ancient_ankh_talisman = {
            id = 287774,
            triggers = {
                ancient_ankh_talisman = { 287774 },
            },
        },

        -- Ancients' Bulwark
        ancients_bulwark = {
            id = 287604,
            triggers = {
                ancients_bulwark = { 287608, 287604 },
            },
        },

        -- Anduin's Dedication
        anduins_dedication = {
            id = 280628,
            triggers = {
                anduins_dedication = { 280876, 280628 },
            },
        },

        -- Apothecary's Concoctions
        apothecarys_concoctions = {
            id = 287631,
            triggers = {
                apothecarys_concoctions = { 287639, 287631 },
            },
        },

        -- Arcane Pressure
        arcane_pressure = {
            id = 274594,
            triggers = {
                arcane_pressure = { 274594 },
            },
        },

        -- Arcane Pummeling
        arcane_pummeling = {
            id = 270669,
            triggers = {
                arcane_pummeling = { 270669, 270670 },
            },
        },

        -- Arcanic Pulsar
        arcanic_pulsar = {
            id = 287773,
            triggers = {
                arcanic_pulsar = { 287773 },
            },
        },

        -- Archive of the Titans
        archive_of_the_titans = {
            id = 280555,
            triggers = {
                archive_of_the_titans = { 280555, 280709 },
            },
        },

        -- Auto-Self-Cauterizer
        autoselfcauterizer = {
            id = 280172,
            triggers = {
                autoselfcauterizer = { 280583, 280172 },
            },
        },

        -- Autumn Leaves
        autumn_leaves = {
            id = 274432,
            triggers = {
                autumn_leaves = { 274432, 287247 },
            },
        },

        -- Avenger's Might
        avengers_might = {
            id = 272898,
            triggers = {
                avengers_might = { 272898, 272903 },
            },
        },

        -- Azerite Empowered
        azerite_empowered = {
            id = 263978,
            triggers = {
                azerite_empowered = { 263978 },
            },
        },

        -- Azerite Fortification
        azerite_fortification = {
            id = 268435,
            triggers = {
                azerite_fortification = { 268435, 270659 },
            },
        },

        -- Azerite Globules
        azerite_globules = {
            id = 266936,
            triggers = {
                azerite_globules = { 279958, 266936 },
            },
        },

        -- Azerite Veins
        azerite_veins = {
            id = 267683,
            triggers = {
                azerite_veins = { 270674, 267683 },
            },
        },

        -- Baleful Invocation
        baleful_invocation = {
            id = 287059,
            triggers = {
                baleful_invocation = { 287060, 287059 },
            },
        },

        -- Barrage Of Many Bombs
        barrage_of_many_bombs = {
            id = 280163,
            triggers = {
                barrage_of_many_bombs = { 280163, 280984 },
            },
        },

        -- Bastion of Might
        bastion_of_might = {
            id = 287377,
            triggers = {
                bastion_of_might = { 287379, 287377 },
            },
        },

        -- Battlefield Focus
        battlefield_focus = {
            id = 280582,
            triggers = {
                battlefield_focus = { 282724, 280817, 280582 },
            },
        },

        -- Battlefield Precision
        battlefield_precision = {
            id = 280627,
            triggers = {
                battlefield_precision = { 282720, 280855, 280627 },
            },
        },

        -- Blade In The Shadows
        blade_in_the_shadows = {
            id = 275896,
            triggers = {
                blade_in_the_shadows = { 279754, 279752, 275896 },
            },
        },

        -- Blaster Master
        blaster_master = {
            id = 274596,
            triggers = {
                blaster_master = { 274596, 274598 },
            },
        },

        -- Blessed Portents
        blessed_portents = {
            id = 267889,
            triggers = {
                blessed_portents = { 271843, 267889 },
            },
        },

        -- Blessed Sanctuary
        blessed_sanctuary = {
            id = 273313,
            triggers = {
                blessed_sanctuary = { 273313 },
            },
        },

        -- Blightborne Infusion
        blightborne_infusion = {
            id = 273823,
            triggers = {
                blightborne_infusion = { 280204, 273823 },
            },
        },

        -- Blood Mist
        blood_mist = {
            id = 279524,
            triggers = {
                blood_mist = { 279524, 279526 },
            },
        },

        -- Blood Rite
        blood_rite = {
            id = 280407,
            triggers = {
                blood_rite = { 280407, 280409 },
            },
        },

        -- Blood Siphon
        blood_siphon = {
            id = 264108,
            triggers = {
                blood_siphon = { 264108 },
            },
        },

        -- Bloodsport
        bloodsport = {
            id = 279172,
            triggers = {
                bloodsport = { 279172, 279194 },
            },
        },

        -- Bloody Runeblade
        bloody_runeblade = {
            id = 289339,
            triggers = {
                bloody_runeblade = { 289339, 289348 },
            },
        },

        -- Blur of Talons
        blur_of_talons = {
            id = 277653,
            triggers = {
                blur_of_talons = { 277969, 277653 },
            },
        },

        -- Boiling Brew
        boiling_brew = {
            id = 272792,
            triggers = {
                boiling_brew = { 123725, 272792 },
            },
        },

        -- Bonded Souls
        bonded_souls = {
            id = 288802,
            triggers = {
                bonded_souls = { 288839, 288802 },
            },
        },

        -- Bone Spike Graveyard
        bone_spike_graveyard = {
            id = 273088,
            triggers = {
                bone_spike_graveyard = { 273088 },
            },
        },

        -- Bones of the Damned
        bones_of_the_damned = {
            id = 278484,
            triggers = {
                bones_of_the_damned = { 278484, 279503 },
            },
        },

        -- Brace for Impact
        brace_for_impact = {
            id = 277636,
            triggers = {
                brace_for_impact = { 277636, 278124 },
            },
        },

        -- Bracing Chill
        bracing_chill = {
            id = 267884,
            triggers = {
                bracing_chill = { 272276, 267884 },
            },
        },

        -- Brain Storm
        brain_storm = {
            id = 273326,
            triggers = {
                brain_storm = { 273326, 273330 },
            },
        },

        -- Breaking Dawn
        breaking_dawn = {
            id = 278594,
            triggers = {
                breaking_dawn = { 278594 },
            },
        },

        -- Brigand's Blitz
        brigands_blitz = {
            id = 277676,
            triggers = {
                brigands_blitz = { 277724, 277725, 277676 },
            },
        },

        -- Bulwark of Light
        bulwark_of_light = {
            id = 272976,
            triggers = {
                bulwark_of_light = { 272979, 272976 },
            },
        },

        -- Bulwark of the Masses
        bulwark_of_the_masses = {
            id = 268595,
            triggers = {
                bulwark_of_the_masses = { 268595, 270656 },
            },
        },

        -- Burning Soul
        burning_soul = {
            id = 280012,
            triggers = {
                burning_soul = { 274289, 280012 },
            },
        },

        -- Burst of Life
        burst_of_life = {
            id = 277667,
            triggers = {
                burst_of_life = { 277667, 287472 },
            },
        },

        -- Burst of Savagery
        burst_of_savagery = {
            id = 289314,
            triggers = {
                burst_of_savagery = { 289315, 289314 },
            },
        },

        -- Bursting Flare
        bursting_flare = {
            id = 279909,
            triggers = {
                bursting_flare = { 279909, 279913 },
            },
        },

        -- Bury the Hatchet
        bury_the_hatchet = {
            id = 280128,
            triggers = {
                bury_the_hatchet = { 280128, 280212 },
            },
        },

        -- Callous Reprisal
        callous_reprisal = {
            id = 278760,
            triggers = {
                callous_reprisal = { 278999, 278760 },
            },
        },

        -- Cankerous Wounds
        cankerous_wounds = {
            id = 278482,
            triggers = {
                cankerous_wounds = { 278482 },
            },
        },

        -- Cascading Calamity
        cascading_calamity = {
            id = 275372,
            triggers = {
                cascading_calamity = { 275378, 275372 },
            },
        },

        -- Cauterizing Blink
        cauterizing_blink = {
            id = 280015,
            triggers = {
                cauterizing_blink = { 280015, 280177 },
            },
        },

        -- Champion of Azeroth
        champion_of_azeroth = {
            id = 280710,
            triggers = {
                champion_of_azeroth = { 280710, 280713 },
            },
        },

        -- Chaos Shards
        chaos_shards = {
            id = 287637,
            triggers = {
                chaos_shards = { 287660, 287637 },
            },
        },

        -- Chaotic Inferno
        chaotic_inferno = {
            id = 278748,
            triggers = {
                chaotic_inferno = { 278748, 279672 },
            },
        },

        -- Chaotic Transformation
        chaotic_transformation = {
            id = 288754,
            triggers = {
                chaotic_transformation = { 288754 },
            },
        },

        -- Chorus of Insanity
        chorus_of_insanity = {
            id = 278661,
            triggers = {
                chorus_of_insanity = { 279572, 278661 },
            },
        },

        -- Cold Hearted
        cold_hearted = {
            id = 288424,
            triggers = {
                cold_hearted = { 288424, 288426 },
            },
        },

        -- Cold Steel, Hot Blood
        cold_steel_hot_blood = {
            id = 288080,
            triggers = {
                cold_steel_hot_blood = { 288080, 288091 },
                gushing_wound = { 288091 },
            },
        },

        -- Collective Will
        collective_will = {
            id = 280581,
            triggers = {
                collective_will = { 280581, 280830 },
            },
        },

        -- Combined Might
        combined_might = {
            id = 280580,
            triggers = {
                might_of_the_sindorei = { 280845 },
                might_of_the_orcs = { 280841 },
                might_of_the_forsaken = { 280844 },
                combined_might = { 280841, 280580 },
                might_of_the_tauren = { 280843 },
                might_of_the_trolls = { 280842 },
            },
        },

        -- Concentrated Mending
        concentrated_mending = {
            id = 267882,
            triggers = {
                concentrated_mending = { 267882, 272260 },
            },
        },

        -- Contemptuous Homily
        contemptuous_homily = {
            id = 278629,
            triggers = {
                contemptuous_homily = { 278629 },
            },
        },

        -- Crashing Chaos
        crashing_chaos = {
            id = 277644,
            triggers = {
                crashing_chaos = { 277706, 277644 },
            },
        },

        -- Crushing Assault
        crushing_assault = {
            id = 278751,
            triggers = {
                crushing_assault = { 278751 },
            },
        },

        -- Crystalline Carapace
        crystalline_carapace = {
            id = 271536,
            triggers = {
                crystalline_carapace = { 271536, 271538, 271539 },
            },
        },

        -- Cycle of Binding
        cycle_of_binding = {
            id = 278502,
            triggers = {
                cycle_of_binding = { 278769, 278502 },
            },
        },

        -- Dagger in the Back
        dagger_in_the_back = {
            id = 280284,
            triggers = {
                dagger_in_the_back = { 280286, 280284 },
            },
        },

        -- Dance of Chi-Ji
        dance_of_chiji = {
            id = 286585,
            triggers = {
                dance_of_chiji = { 286587, 286585 },
            },
        },

        -- Dance of Death
        dance_of_death = {
            id = 274441,
            triggers = {
                dance_of_death = { 274441, 274443 },
            },
        },

        -- Dawning Sun
        dawning_sun = {
            id = 276152,
            triggers = {
                dawning_sun = { 276152, 276154 },
            },
        },

        -- Deadshot
        deadshot = {
            id = 272935,
            triggers = {
                deadshot = { 272935, 272940 },
            },
        },

        -- Deafening Crash
        deafening_crash = {
            id = 272824,
            triggers = {
                deafening_crash = { 272824 },
            },
        },

        -- Death Denied
        death_denied = {
            id = 287717,
            triggers = {
                death_denied = { 287717, 287722, 287723 },
            },
        },

        -- Death Throes
        death_throes = {
            id = 278659,
            triggers = {
                death_throes = { 278659 },
            },
        },

        -- Deep Cuts
        deep_cuts = {
            id = 272684,
            triggers = {
                deep_cuts = { 272684, 272685 },
            },
        },

        -- Demonic Meteor
        demonic_meteor = {
            id = 278737,
            triggers = {
                demonic_meteor = { 278737 },
            },
        },

        -- Depth of the Shadows
        depth_of_the_shadows = {
            id = 275541,
            triggers = {
                depth_of_the_shadows = { 275541, 275544 },
            },
        },

        -- Desperate Power
        desperate_power = {
            id = 280022,
            triggers = {
                desperate_power = { 280022, 234153, 280208 },
            },
        },

        -- Dire Consequences
        dire_consequences = {
            id = 287093,
            triggers = {
                dire_consequences = { 287093 },
            },
        },

        -- Divine Revelations
        divine_revelations = {
            id = 275463,
            triggers = {
                divine_revelations = { 275468, 275463, 275469 },
            },
        },

        -- Double Dose
        double_dose = {
            id = 273007,
            triggers = {
                double_dose = { 273009, 273007 },
            },
        },

        -- Dreadful Calling
        dreadful_calling = {
            id = 278727,
            triggers = {
                dreadful_calling = { 278727, 233490 },
            },
        },

        -- Duck and Cover
        duck_and_cover = {
            id = 280014,
            triggers = {
                duck_and_cover = { 280170, 280014 },
            },
        },

        -- Duplicative Incineration
        duplicative_incineration = {
            id = 278538,
            triggers = {
                duplicative_incineration = { 278538 },
            },
        },

        -- Early Harvest
        early_harvest = {
            id = 287251,
            triggers = {
                early_harvest = { 287251 },
            },
        },

        -- Earthlink
        earthlink = {
            id = 279926,
            triggers = {
                earthlink = { 279926, 279928 },
            },
        },

        -- Echo of the Elementals
        echo_of_the_elementals = {
            id = 275381,
            triggers = {
                echo_of_the_elementals = { 275385, 275381 },
            },
        },

        -- Echoing Blades
        echoing_blades = {
            id = 287649,
            triggers = {
                echoing_blades = { 287653, 287649 },
            },
        },

        -- Echoing Howl
        echoing_howl = {
            id = 275917,
            triggers = {
                echoing_howl = { 275917, 275918 },
            },
        },

        -- Eldritch Warding
        eldritch_warding = {
            id = 274379,
            triggers = {
                eldritch_warding = { 274379 },
            },
        },

        -- Elemental Whirl
        elemental_whirl = {
            id = 263984,
            triggers = {
                elemental_whirl = { 268953, 268954, 268956, 268955, 263984 },
            },
        },

        -- Elusive Footwork
        elusive_footwork = {
            id = 278571,
            triggers = {
                elusive_footwork = { 278571 },
            },
        },

        -- Empyreal Ward
        empyreal_ward = {
            id = 287729,
            triggers = {
                empyreal_ward = { 287731, 287729 },
            },
        },

        -- Empyrean Power
        empyrean_power = {
            id = 286390,
            triggers = {
                empyrean_power = { 286390, 286393 },
            },
        },

        -- Endless Hunger
        endless_hunger = {
            id = 287662,
            triggers = {
                endless_hunger = { 287662 },
            },
        },

        -- Enduring Luminescence
        enduring_luminescence = {
            id = 278643,
            triggers = {
                enduring_luminescence = { 278643 },
            },
        },

        -- Ephemeral Recovery
        ephemeral_recovery = {
            id = 267886,
            triggers = {
                ephemeral_recovery = { 267886, 289362 },
            },
        },

        -- Equipoise
        equipoise = {
            id = 286027,
            triggers = {
                equipoise = { 286027, 264351, 264352 },
            },
        },

        -- Essence Sever
        essence_sever = {
            id = 278501,
            triggers = {
                essence_sever = { 279450, 278501 },
            },
        },

        -- Eternal Rune Weapon
        eternal_rune_weapon = {
            id = 278479,
            triggers = {
                eternal_rune_weapon = { 278543, 278479 },
            },
        },

        -- Everlasting Light
        everlasting_light = {
            id = 277681,
            triggers = {
                everlasting_light = { 277681 },
            },
        },

        -- Exit Strategy
        exit_strategy = {
            id = 289322,
            triggers = {
                exit_strategy = { 289324, 289322 },
            },
        },

        -- Explosive Echo
        explosive_echo = {
            id = 278537,
            triggers = {
                explosive_echo = { 278537 },
            },
        },

        -- Explosive Potential
        explosive_potential = {
            id = 275395,
            triggers = {
                explosive_potential = { 275395, 275398 },
            },
        },

        -- Expurgation
        expurgation = {
            id = 273473,
            triggers = {
                expurgation = { 273481, 273473 },
            },
        },

        -- Eyes of Rage
        eyes_of_rage = {
            id = 278500,
            triggers = {
                eyes_of_rage = { 278500 },
            },
        },

        -- Feeding Frenzy
        feeding_frenzy = {
            id = 278529,
            triggers = {
                feeding_frenzy = { 217200, 278529 },
            },
        },

        -- Festermight
        festermight = {
            id = 274081,
            triggers = {
                festermight = { 274373, 274081 },
            },
        },

        -- Fight or Flight
        fight_or_flight = {
            id = 287818,
            triggers = {
                fight_or_flight = { 287825, 287818 },
            },
        },

        -- Filthy Transfusion
        filthy_transfusion = {
            id = 273834,
            triggers = {
                filthy_transfusion = { 273836, 273834 },
            },
        },

        -- Firemind
        firemind = {
            id = 278539,
            triggers = {
                firemind = { 278539, 279715 },
            },
        },

        -- Fit to Burst
        fit_to_burst = {
            id = 275892,
            triggers = {
                fit_to_burst = { 275893, 275892, 275894 },
            },
        },

        -- Flames of Alacrity
        flames_of_alacrity = {
            id = 272932,
            triggers = {
                flames_of_alacrity = { 272934, 272932 },
            },
        },

        -- Flash Freeze
        flash_freeze = {
            id = 288164,
            triggers = {
                flash_freeze = { 288164 },
            },
        },

        -- Flashpoint
        flashpoint = {
            id = 275425,
            triggers = {
                flashpoint = { 275425, 275429 },
            },
        },

        -- Focused Fire
        focused_fire = {
            id = 278531,
            triggers = {
                focused_fire = { 278531, 279636 },
            },
        },

        -- Font of Life
        font_of_life = {
            id = 279875,
            triggers = {
                font_of_life = { 279875 },
            },
        },

        -- Footpad
        footpad = {
            id = 274692,
            triggers = {
                footpad = { 274692, 274695 },
            },
        },

        -- Fortifying Auras
        fortifying_auras = {
            id = 273134,
            triggers = {
                fortifying_auras = { 273134 },
            },
        },

        -- Frigid Grasp
        frigid_grasp = {
            id = 278542,
            triggers = {
                frigid_grasp = { 278542, 279684 },
            },
        },

        -- Frostwhelp's Indignation
        frostwhelps_indignation = {
            id = 287283,
            triggers = {
                frostwhelps_indignation = { 287338, 287283 },
            },
        },

        -- Frozen Tempest
        frozen_tempest = {
            id = 278487,
            triggers = {
                frozen_tempest = { 278487 },
            },
        },

        -- Furious Gaze
        furious_gaze = {
            id = 273231,
            triggers = {
                furious_gaze = { 273232, 273231 },
            },
        },

        -- Fury of Xuen
        fury_of_xuen = {
            id = 287055,
            triggers = {
                fury_of_xuen = { 287062, 287055, 287063 },
            },
        },

        -- Gallant Steed
        gallant_steed = {
            id = 280017,
            triggers = {
                gallant_steed = { 280191, 280192, 280017 },
            },
        },

        -- Galvanizing Spark
        galvanizing_spark = {
            id = 278536,
            triggers = {
                galvanizing_spark = { 278536 },
            },
        },

        -- Gathering Storm
        gathering_storm = {
            id = 273409,
            triggers = {
                gathering_storm = { 273415, 273409 },
            },
        },

        -- Gemhide
        gemhide = {
            id = 268596,
            triggers = {
                gemhide = { 268596, 270576 },
            },
        },

        -- Glacial Assault
        glacial_assault = {
            id = 279854,
            triggers = {
                glacial_assault = { 279854, 279856, 279855 },
            },
        },

        -- Glimmer of Light
        glimmer_of_light = {
            id = 287268,
            triggers = {
                glimmer_of_light = { 287280, 287268 },
            },
        },

        -- Glory in Battle
        glory_in_battle = {
            id = 280577,
            triggers = {
                glory_in_battle = { 280780, 280577 },
            },
        },

        -- Glory of the Dawn
        glory_of_the_dawn = {
            id = 288634,
            triggers = {
                glory_of_the_dawn = { 288636, 288634 },
            },
        },

        -- Gory Regeneration
        gory_regeneration = {
            id = 278510,
            triggers = {
                gory_regeneration = { 278510 },
            },
        },

        -- Grace of the Justicar
        grace_of_the_justicar = {
            id = 278593,
            triggers = {
                grace_of_the_justicar = { 278593, 278785 },
            },
        },

        -- Grove Tending
        grove_tending = {
            id = 279778,
            triggers = {
                grove_tending = { 279778, 279793 },
            },
        },

        -- Guardian's Wrath
        guardians_wrath = {
            id = 278511,
            triggers = {
                guardians_wrath = { 278511, 279541 },
            },
        },

        -- Gushing Lacerations
        gushing_lacerations = {
            id = 278509,
            triggers = {
                gushing_lacerations = { 278509, 279468 },
            },
        },

        -- Gutripper
        gutripper = {
            id = 266937,
            triggers = {
                gutripper = { 270668, 266937, 269031 },
            },
        },

        -- Harrowing Decay
        harrowing_decay = {
            id = 275929,
            triggers = {
                harrowing_decay = { 275931, 275929 },
            },
        },

        -- Haze of Rage
        haze_of_rage = {
            id = 273262,
            triggers = {
                haze_of_rage = { 273264, 273262 },
            },
        },

        -- Healing Hammer
        healing_hammer = {
            id = 273142,
            triggers = {
                healing_hammer = { 273142 },
            },
        },

        -- Heed My Call
        heed_my_call = {
            id = 263987,
            triggers = {
                heed_my_call = { 263987, 271686, 271685 },
            },
        },

        -- Helchains
        helchains = {
            id = 286832,
            triggers = {
                helchains = { 286832 },
            },
        },

        -- High Noon
        high_noon = {
            id = 278505,
            triggers = {
                high_noon = { 278505 },
            },
        },

        -- Hour of Reaping
        hour_of_reaping = {
            id = 288878,
            triggers = {
                hour_of_reaping = { 288882, 288878 },
            },
        },

        -- Icy Citadel
        icy_citadel = {
            id = 272718,
            triggers = {
                icy_citadel = { 272718, 272723 },
            },
        },

        -- Igneous Potential
        igneous_potential = {
            id = 279829,
            triggers = {
                igneous_potential = { 279829 },
            },
        },

        -- Impassive Visage
        impassive_visage = {
            id = 268437,
            triggers = {
                impassive_visage = { 270117, 270654, 268437 },
            },
        },

        -- In The Rhythm
        in_the_rhythm = {
            id = 264198,
            triggers = {
                in_the_rhythm = { 272733, 264198 },
            },
        },

        -- Incite the Pack
        incite_the_pack = {
            id = 280410,
            triggers = {
                incite_the_pack = { 280413, 280410, 280412 },
            },
        },

        -- Indomitable Justice
        indomitable_justice = {
            id = 275496,
            triggers = {
                indomitable_justice = { 275496 },
            },
        },

        -- Inevitability
        inevitability = {
            id = 278683,
            triggers = {
                inevitability = { 278683 },
            },
        },

        -- Inevitable Demise
        inevitable_demise = {
            id = 273521,
            triggers = {
                inevitable_demise = { 273521, 273525 },
            },
        },

        -- Infernal Armor
        infernal_armor = {
            id = 273236,
            triggers = {
                infernal_armor = { 273239, 273236 },
            },
        },

        -- Infinite Fury
        infinite_fury = {
            id = 277638,
            triggers = {
                infinite_fury = { 278134, 277638 },
            },
        },

        -- Inner Light
        inner_light = {
            id = 275477,
            triggers = {
                inner_light = { 275483, 275481, 275477 },
            },
        },

        -- Inspiring Beacon
        inspiring_beacon = {
            id = 273130,
            triggers = {
                inspiring_beacon = { 273130 },
            },
        },

        -- Inspiring Vanguard
        inspiring_vanguard = {
            id = 278609,
            triggers = {
                inspiring_vanguard = { 279397, 278609 },
            },
        },

        -- Intimidating Presence
        intimidating_presence = {
            id = 288641,
            triggers = {
                intimidating_presence = { 288644, 288641 },
            },
        },

        -- Iron Fortress
        iron_fortress = {
            id = 278765,
            triggers = {
                iron_fortress = { 278765 },
            },
        },

        -- Iron Jaws
        iron_jaws = {
            id = 276021,
            triggers = {
                iron_jaws = { 276021, 276026 },
            },
        },

        -- Judicious Defense
        judicious_defense = {
            id = 277675,
            triggers = {
                judicious_defense = { 277675, 278574 },
            },
        },

        -- Jungle Fury
        jungle_fury = {
            id = 274424,
            triggers = {
                jungle_fury = { 274424, 274426, 274425 },
            },
        },

        -- Keep Your Wits About You
        keep_your_wits_about_you = {
            id = 288979,
            triggers = {
                keep_your_wits_about_you = { 288979 },
            },
        },

        -- Killer Frost
        killer_frost = {
            id = 278480,
            triggers = {
                killer_frost = { 278480 },
            },
        },

        -- Laser Matrix
        laser_matrix = {
            id = 280559,
            triggers = {
                laser_matrix = { 280559 },
            },
        },

        -- Last Gift
        last_gift = {
            id = 280624,
            triggers = {
                last_gift = { 280861, 280862, 280624 },
            },
        },

        -- Last Surprise
        last_surprise = {
            id = 278489,
            triggers = {
                last_surprise = { 278489 },
            },
        },

        -- Latent Chill
        latent_chill = {
            id = 273093,
            triggers = {
                latent_chill = { 273093 },
            },
        },

        -- Latent Poison
        latent_poison = {
            id = 273283,
            triggers = {
                latent_poison = { 273286, 273283 },
            },
        },

        -- Lava Shock
        lava_shock = {
            id = 273448,
            triggers = {
                lava_shock = { 273448, 273453 },
            },
        },

        -- Layered Mane
        layered_mane = {
            id = 279552,
            triggers = {
                layered_mane = { 279552 },
            },
        },

        -- Liberator's Might
        liberators_might = {
            id = 280623,
            triggers = {
                liberators_might = { 280852, 280623 },
            },
        },

        -- Lifeblood
        lifeblood = {
            id = 274418,
            triggers = {
                lifeblood = { 274420, 274418 },
            },
        },

        -- Lifespeed
        lifespeed = {
            id = 267665,
            triggers = {
                lifespeed = { 267665 },
            },
        },

        -- Lightning Conduit
        lightning_conduit = {
            id = 275388,
            triggers = {
                lightning_conduit = { 275388, 275394, 275391 },
            },
        },

        -- Light's Decree
        lights_decree = {
            id = 286229,
            triggers = {
                lights_decree = { 286229, 286231 },
            },
        },

        -- Lively Spirit
        lively_spirit = {
            id = 279642,
            triggers = {
                lively_spirit = { 289335, 279642, 279648 },
            },
        },

        -- Longstrider
        longstrider = {
            id = 268594,
            triggers = {
                longstrider = { 268594 },
            },
        },

        -- Lord of War
        lord_of_war = {
            id = 278752,
            triggers = {
                lord_of_war = { 278752, 279203 },
            },
        },

        -- Lunar Shrapnel
        lunar_shrapnel = {
            id = 278507,
            triggers = {
                lunar_shrapnel = { 278507, 279641 },
            },
        },

        -- Lying In Wait
        lying_in_wait = {
            id = 288079,
            triggers = {
                lying_in_wait = { 288079 },
            },
        },

        -- Magus of the Dead
        magus_of_the_dead = {
            id = 288417,
            triggers = {
                magus_of_the_dead = { 288417, 288544 },
            },
        },

        -- March of the Damned
        march_of_the_damned = {
            id = 280011,
            triggers = {
                march_of_the_damned = { 280149, 280011 },
            },
        },

        -- Marrowblood
        marrowblood = {
            id = 274057,
            triggers = {
                marrowblood = { 274057 },
            },
        },

        -- Masterful Instincts
        masterful_instincts = {
            id = 273344,
            triggers = {
                masterful_instincts = { 273349, 273344 },
            },
        },

        -- Meticulous Scheming
        meticulous_scheming = {
            id = 273682,
            triggers = {
                seize_the_moment = { 273714 },
                meticulous_scheming = { 273714, 273682 },
            },
        },

        -- Misty Peaks
        misty_peaks = {
            id = 275975,
            triggers = {
                misty_peaks = { 276025, 275975 },
            },
        },

        -- Moment of Compassion
        moment_of_compassion = {
            id = 273513,
            triggers = {
                moment_of_compassion = { 273513 },
            },
        },

        -- Moment of Glory
        moment_of_glory = {
            id = 280023,
            triggers = {
                moment_of_glory = { 280210, 280023 },
            },
        },

        -- Moment of Repose
        moment_of_repose = {
            id = 272775,
            triggers = {
                moment_of_repose = { 272775 },
            },
        },

        -- Natural Harmony
        natural_harmony = {
            id = 278697,
            triggers = {
                natural_harmony_nature = { 279033 },
                natural_harmony_frost = { 279029 },
                natural_harmony_fire = { 279028 },
                natural_harmony = { 278697, 279028 },
            },
        },

        -- Nature's Salve
        natures_salve = {
            id = 287938,
            triggers = {
                natures_salve = { 287938, 287940 },
            },
        },

        -- Night's Vengeance
        nights_vengeance = {
            id = 273418,
            triggers = {
                nights_vengeance = { 273418, 273424 },
            },
        },

        -- Nothing Personal
        nothing_personal = {
            id = 286573,
            triggers = {
                nothing_personal = { 286573, 286581 },
            },
        },

        -- On My Way
        on_my_way = {
            id = 267879,
            triggers = {
                on_my_way = { 267879 },
            },
        },

        -- Open Palm Strikes
        open_palm_strikes = {
            id = 279918,
            triggers = {
                open_palm_strikes = { 279918 },
            },
        },

        -- Overflowing Mists
        overflowing_mists = {
            id = 273328,
            triggers = {
                overflowing_mists = { 273328, 273348 },
            },
        },

        -- Overflowing Shores
        overflowing_shores = {
            id = 277658,
            triggers = {
                overflowing_shores = { 277658, 278095 },
            },
        },

        -- Overwhelming Power
        overwhelming_power = {
            id = 266180,
            triggers = {
                overwhelming_power = { 271711, 266180 },
            },
        },

        -- Pack Spirit
        pack_spirit = {
            id = 280021,
            triggers = {
                pack_spirit = { 280205, 280021 },
            },
        },

        -- Packed Ice
        packed_ice = {
            id = 272968,
            triggers = {
                packed_ice = { 272968 },
            },
        },

        -- Pandemic Invocation
        pandemic_invocation = {
            id = 289364,
            triggers = {
                pandemic_invocation = { 289367, 289364 },
            },
        },

        -- Paradise Lost
        paradise_lost = {
            id = 278675,
            triggers = {
                paradise_lost = { 278962, 278675 },
            },
        },

        -- Perforate
        perforate = {
            id = 277673,
            triggers = {
                perforate = { 277673, 277720 },
            },
        },

        -- Permeating Glow
        permeating_glow = {
            id = 272780,
            triggers = {
                permeating_glow = { 272783, 272780 },
            },
        },

        -- Personal Absorb-o-Tron
        personal_absorbotron = {
            id = 280181,
            triggers = {
                personal_absorbotron = { 280660, 280181 },
            },
        },

        -- Power of the Moon
        power_of_the_moon = {
            id = 273367,
            triggers = {
                arcanic_pulsar = { 287790 },
                power_of_the_moon = { 273367 },
            },
        },

        -- Prayerful Litany
        prayerful_litany = {
            id = 275602,
            triggers = {
                prayerful_litany = { 275602 },
            },
        },

        -- Pressure Point
        pressure_point = {
            id = 278577,
            triggers = {
                pressure_point = { 278718, 278577 },
            },
        },

        -- Primal Instincts
        primal_instincts = {
            id = 279806,
            triggers = {
                primal_instincts = { 279806, 279810 },
            },
        },

        -- Primal Primer
        primal_primer = {
            id = 272992,
            triggers = {
                primal_primer = { 272992, 273006 },
            },
        },

        -- Primeval Intuition
        primeval_intuition = {
            id = 288570,
            triggers = {
                primeval_intuition = { 288570, 288573 },
            },
        },

        -- Promise of Deliverance
        promise_of_deliverance = {
            id = 287336,
            triggers = {
                promise_of_deliverance = { 287340, 287336 },
            },
        },

        -- Pulverizing Blows
        pulverizing_blows = {
            id = 275632,
            triggers = {
                pulverizing_blows = { 275672, 275632 },
            },
        },

        -- Quick Thinking
        quick_thinking = {
            id = 288121,
            triggers = {
                quick_thinking = { 288121 },
            },
        },

        -- Radiant Incandescence
        radiant_incandescence = {
            id = 277674,
            triggers = {
                radiant_incandescence = { 277674, 278147, 278145 },
            },
        },

        -- Rampant Growth
        rampant_growth = {
            id = 278515,
            triggers = {
                rampant_growth = { 278515 },
            },
        },

        -- Rapid Reload
        rapid_reload = {
            id = 278530,
            triggers = {
                multishot = { 278565 },
                rapid_reload = { 278530 },
            },
        },

        -- Reawakening
        reawakening = {
            id = 274813,
            triggers = {
                reawakening = { 274813, 285719 },
            },
        },

        -- Reckless Flurry
        reckless_flurry = {
            id = 278758,
            triggers = {
                reckless_flurry = { 278758, 283810 },
            },
        },

        -- Rejuvenating Grace
        rejuvenating_grace = {
            id = 273131,
            triggers = {
                rejuvenating_grace = { 273131 },
            },
        },

        -- Relational Normalization Gizmo
        relational_normalization_gizmo = {
            id = 280178,
            triggers = {
                relational_normalization_gizmo = { 280653, 280178 },
            },
        },

        -- Relentless Inquisitor
        relentless_inquisitor = {
            id = 278617,
            triggers = {
                relentless_inquisitor = { 278617, 279204 },
            },
        },

        -- Replicating Shadows
        replicating_shadows = {
            id = 286121,
            triggers = {
                replicating_shadows = { 286121, 286131 },
            },
        },

        -- Resounding Protection
        resounding_protection = {
            id = 263962,
            triggers = {
                resounding_protection = { 263962, 269279 },
            },
        },

        -- Retaliatory Fury
        retaliatory_fury = {
            id = 280579,
            triggers = {
                retaliatory_fury = { 280787, 280579, 280788 },
            },
        },

        -- Revel in Pain
        revel_in_pain = {
            id = 272983,
            triggers = {
                revel_in_pain = { 272983, 272987 },
            },
        },

        -- Revolving Blades
        revolving_blades = {
            id = 279581,
            triggers = {
                revolving_blades = { 279581, 279584 },
            },
        },

        -- Rezan's Fury
        rezans_fury = {
            id = 273790,
            triggers = {
                rezans_fury = { 273794, 273790 },
            },
        },

        -- Ricocheting Inflatable Pyrosaw
        ricocheting_inflatable_pyrosaw = {
            id = 280168,
            triggers = {
                ricocheting_inflatable_pyrosaw = { 280656, 280168 },
            },
        },

        -- Righteous Conviction
        righteous_conviction = {
            id = 287126,
            triggers = {
                righteous_conviction = { 287126 },
            },
        },

        -- Righteous Flames
        righteous_flames = {
            id = 273140,
            triggers = {
                righteous_flames = { 273140 },
            },
        },

        -- Rigid Carapace
        rigid_carapace = {
            id = 275350,
            triggers = {
                rigid_carapace = { 275350, 275351 },
            },
        },

        -- Roiling Storm
        roiling_storm = {
            id = 278719,
            triggers = {
                roiling_storm = { 279515, 278719 },
            },
        },

        -- Rolling Havoc
        rolling_havoc = {
            id = 278747,
            triggers = {
                rolling_havoc = { 278931, 278747 },
            },
        },

        -- Ruinous Bolt
        ruinous_bolt = {
            id = 273150,
            triggers = {
                ruinous_bolt = { 273150, 280204 },
            },
        },

        -- Runic Barrier
        runic_barrier = {
            id = 280010,
            triggers = {
                runic_barrier = { 280010 },
            },
        },

        -- Sanctum
        sanctum = {
            id = 274366,
            triggers = {
                sanctum = { 274369, 274366 },
            },
        },

        -- Savior
        savior = {
            id = 267883,
            triggers = {
                savior = { 267883, 270679 },
            },
        },

        -- Scent of Blood
        scent_of_blood = {
            id = 277679,
            triggers = {
                scent_of_blood = { 277679, 277731 },
            },
        },

        -- Searing Dialogue
        searing_dialogue = {
            id = 272788,
            triggers = {
                searing_dialogue = { 272788, 288371 },
            },
        },

        -- Secret Infusion
        secret_infusion = {
            id = 287829,
            triggers = {
                secret_infusion = { 287829, 287831 },
            },
        },

        -- Secrets of the Deep
        secrets_of_the_deep = {
            id = 273829,
            triggers = {
                secrets_of_the_deep = { 273842, 273829 },
            },
        },

        -- Seductive Power
        seductive_power = {
            id = 288749,
            triggers = {
                seductive_power = { 288777, 288749 },
            },
        },

        -- Seething Power
        seething_power = {
            id = 275934,
            triggers = {
                seething_power = { 275936, 275934 },
            },
        },

        -- Seismic Wave
        seismic_wave = {
            id = 277639,
            triggers = {
                seismic_wave = { 277639, 278497 },
            },
        },

        -- Self Reliance
        self_reliance = {
            id = 268600,
            triggers = {
                self_reliance = { 270661, 268600 },
            },
        },

        -- Serene Spirit
        serene_spirit = {
            id = 274412,
            triggers = {
                serene_spirit = { 274412, 274416 },
            },
        },

        -- Serrated Jaws
        serrated_jaws = {
            id = 272717,
            triggers = {
                serrated_jaws = { 272717 },
            },
        },

        -- Shadow of Elune
        shadow_of_elune = {
            id = 287467,
            triggers = {
                shadow_of_elune = { 287467, 287471 },
            },
        },

        -- Shadow's Bite
        shadows_bite = {
            id = 272944,
            triggers = {
                shadows_bite = { 272945, 272944 },
            },
        },

        -- Shellshock
        shellshock = {
            id = 274355,
            triggers = {
                shellshock = { 274355, 274357 },
            },
        },

        -- Shimmering Haven
        shimmering_haven = {
            id = 271557,
            triggers = {
                shimmering_haven = { 271560, 271557 },
            },
        },

        -- Shrouded Mantle
        shrouded_mantle = {
            id = 280020,
            triggers = {
                shrouded_mantle = { 280020, 280200 },
            },
        },

        -- Shrouded Suffocation
        shrouded_suffocation = {
            id = 278666,
            triggers = {
                shrouded_suffocation = { 278666 },
            },
        },

        -- Simmering Rage
        simmering_rage = {
            id = 278757,
            triggers = {
                simmering_rage = { 278841, 278757, 184367 },
            },
        },

        -- Snake Eyes
        snake_eyes = {
            id = 275846,
            triggers = {
                snake_eyes = { 275863, 275846 },
            },
        },

        -- Soaring Shield
        soaring_shield = {
            id = 278605,
            triggers = {
                soaring_shield = { 278605, 278954 },
            },
        },

        -- Soothing Waters
        soothing_waters = {
            id = 272989,
            triggers = {
                soothing_waters = { 272989 },
            },
        },

        -- Soulmonger
        soulmonger = {
            id = 274344,
            triggers = {
                soulmonger = { 274344, 274346 },
            },
        },

        -- Spiteful Apparitions
        spiteful_apparitions = {
            id = 277682,
            triggers = {
                spiteful_apparitions = { 277682 },
            },
        },

        -- Spouting Spirits
        spouting_spirits = {
            id = 278715,
            triggers = {
                spouting_spirits = { 278715, 279504 },
            },
        },

        -- Staggering Strikes
        staggering_strikes = {
            id = 273464,
            triggers = {
                staggering_strikes = { 273464, 273469 },
            },
        },

        -- Stalwart Protector
        stalwart_protector = {
            id = 274388,
            triggers = {
                stalwart_protector = { 274395, 274388 },
            },
        },

        -- Stand As One
        stand_as_one = {
            id = 280626,
            triggers = {
                stand_as_one = { 280626, 280858 },
            },
        },

        -- Steady Aim
        steady_aim = {
            id = 277651,
            triggers = {
                steady_aim = { 277651, 277959 },
            },
        },

        -- Straight, No Chaser
        straight_no_chaser = {
            id = 285958,
            triggers = {
                straight_no_chaser = { 285958 },
            },
        },

        -- Streaking Stars
        streaking_stars = {
            id = 272871,
            triggers = {
                streaking_star = { 272873 },
                streaking_stars = { 272871 },
            },
        },

        -- Strength in Numbers
        strength_in_numbers = {
            id = 271546,
            triggers = {
                strength_in_numbers = { 271546, 271550 },
            },
        },

        -- Strength of Earth
        strength_of_earth = {
            id = 273461,
            triggers = {
                strength_of_earth = { 273461, 273466 },
            },
        },

        -- Strength of Spirit
        strength_of_spirit = {
            id = 274762,
            triggers = {
                strength_of_spirit = { 274762, 274774 },
            },
        },

        -- Striking the Anvil
        striking_the_anvil = {
            id = 288452,
            triggers = {
                striking_the_anvil = { 288452 },
            },
        },

        -- Stronger Together
        stronger_together = {
            id = 280625,
            triggers = {
                strength_of_the_dwarves = { 280868 },
                stronger_together = { 280625, 280866 },
                strength_of_the_night_elves = { 280867 },
                strength_of_the_gnomes = { 280870 },
                strength_of_the_humans = { 280866 },
                strength_of_the_draenei = { 280869 },
            },
        },

        -- Sudden Onset
        sudden_onset = {
            id = 278721,
            triggers = {
                sudden_onset = { 278721 },
            },
        },

        -- Sudden Revelation
        sudden_revelation = {
            id = 287355,
            triggers = {
                sudden_revelation = { 287356, 287360, 287355 },
            },
        },

        -- Sunrise Technique
        sunrise_technique = {
            id = 273291,
            triggers = {
                sunrise_technique = { 275673, 273298, 273291 },
            },
        },

        -- Supreme Commander
        supreme_commander = {
            id = 279878,
            triggers = {
                supreme_commander = { 279885, 279878 },
            },
        },

        -- Surging Shots
        surging_shots = {
            id = 287707,
            triggers = {
                surging_shots = { 287707 },
            },
        },

        -- Surging Tides
        surging_tides = {
            id = 278713,
            triggers = {
                surging_tides = { 278713, 279187 },
            },
        },

        -- Sweep the Leg
        sweep_the_leg = {
            id = 280016,
            triggers = {
                sweep_the_leg = { 280187, 280016 },
            },
        },

        -- Swelling Stream
        swelling_stream = {
            id = 275488,
            triggers = {
                swelling_stream = { 275499, 275488 },
            },
        },

        -- Swirling Sands
        swirling_sands = {
            id = 280429,
            triggers = {
                swirling_sands = { 280429, 280433 },
            },
        },

        -- Switch Hitter
        switch_hitter = {
            id = 287803,
            triggers = {
                switch_hitter = { 287808, 287803 },
            },
        },

        -- Sylvanas' Resolve
        sylvanas_resolve = {
            id = 280598,
            triggers = {
                sylvanas_resolve = { 280809, 280598 },
            },
        },

        -- Synapse Shock
        synapse_shock = {
            id = 277671,
            triggers = {
                synapse_shock = { 277960, 277671 },
            },
        },

        -- Synaptic Spark Capacitor
        synaptic_spark_capacitor = {
            id = 280174,
            triggers = {
                synaptic_spark_capacitor = { 280847, 280174 },
            },
        },

        -- Synergistic Growth
        synergistic_growth = {
            id = 267892,
            triggers = {
                synergistic_growth = { 272089, 267892, 272090 },
            },
        },

        -- Tectonic Thunder
        tectonic_thunder = {
            id = 286949,
            triggers = {
                tectonic_thunder = { 286949 },
            },
        },

        -- Terror of the Mind
        terror_of_the_mind = {
            id = 287822,
            triggers = {
                terror_of_the_mind = { 287828, 287822 },
            },
        },

        -- Test of Might
        test_of_might = {
            id = 275529,
            triggers = {
                test_of_might = { 275529, 275540 },
            },
        },

        -- The First Dance
        the_first_dance = {
            id = 278681,
            triggers = {
                the_first_dance = { 278681, 278981 },
            },
        },

        -- Thirsting Blades
        thirsting_blades = {
            id = 278493,
            triggers = {
                thirsting_blades = { 278729, 278493 },
            },
        },

        -- Thought Harvester
        thought_harvester = {
            id = 288340,
            triggers = {
                thought_harvester = { 288340, 288343 },
            },
        },

        -- Thrive in Chaos
        thrive_in_chaos = {
            id = 288973,
            triggers = {
                thrive_in_chaos = { 288973 },
            },
        },

        -- Thunderaan's Fury
        thunderaans_fury = {
            id = 287768,
            triggers = {
                thunderaans_fury = { 287802, 287768 },
            },
        },

        -- Thunderous Blast
        thunderous_blast = {
            id = 280380,
            triggers = {
                thunderous_blast = { 280380, 280384, 280385 },
            },
        },

        -- Tidal Surge
        tidal_surge = {
            id = 280402,
            triggers = {
                tidal_surge = { 280402, 280404 },
            },
        },

        -- Tradewinds
        tradewinds = {
            id = 281841,
            triggers = {
                tradewinds = { 281841, 281843, 281844 },
            },
        },

        -- Trailing Embers
        trailing_embers = {
            id = 277656,
            triggers = {
                trailing_embers = { 277703, 277656 },
            },
        },

        -- Training of Niuzao
        training_of_niuzao = {
            id = 278569,
            triggers = {
                training_of_niuzao = { 278569 },
            },
        },

        -- Treacherous Covenant
        treacherous_covenant = {
            id = 288953,
            triggers = {
                treacherous_covenant = { 288953 },
            },
        },

        -- Tunnel of Ice
        tunnel_of_ice = {
            id = 277663,
            triggers = {
                tunnel_of_ice = { 277663, 277904 },
            },
        },

        -- Turn of the Tide
        turn_of_the_tide = {
            id = 287300,
            triggers = {
                turn_of_the_tide = { 287302, 287300 },
            },
        },

        -- Twist Magic
        twist_magic = {
            id = 280018,
            triggers = {
                twist_magic = { 280198, 280018 },
            },
        },

        -- Twist the Knife
        twist_the_knife = {
            id = 273488,
            triggers = {
                twist_the_knife = { 273488 },
            },
        },

        -- Twisted Claws
        twisted_claws = {
            id = 275906,
            triggers = {
                twisted_claws = { 275906, 275909 },
            },
        },

        -- Umbral Blaze
        umbral_blaze = {
            id = 273523,
            triggers = {
                umbral_blaze = { 273523, 273526 },
            },
        },

        -- Unbridled Ferocity
        unbridled_ferocity = {
            id = 288056,
            triggers = {
                unbridled_ferocity = { 288056, 288060 },
            },
        },

        -- Unerring Vision
        unerring_vision = {
            id = 274444,
            triggers = {
                unerring_vision = { 274444, 274447 },
            },
        },

        -- Unstable Catalyst
        unstable_catalyst = {
            id = 281514,
            triggers = {
                unstable_catalyst = { 281516, 281514 },
            },
        },

        -- Unstable Flames
        unstable_flames = {
            id = 279899,
            triggers = {
                unstable_flames = { 279899, 279902 },
            },
        },

        -- Untamed Ferocity
        untamed_ferocity = {
            id = 273338,
            triggers = {
                gushing_lacerations = { 279471 },
                untamed_ferocity = { 273338 },
            },
        },

        -- Uplifted Spirits
        uplifted_spirits = {
            id = 278576,
            triggers = {
                uplifted_spirits = { 278576 },
            },
        },

        -- Ursoc's Endurance
        ursocs_endurance = {
            id = 280013,
            triggers = {
                ursocs_endurance = { 280165, 280013 },
            },
        },

        -- Vampiric Speed
        vampiric_speed = {
            id = 268599,
            triggers = {
                vampiric_speed = { 268599, 269238, 269239 },
            },
        },

        -- Venomous Fangs
        venomous_fangs = {
            id = 274590,
            triggers = {
                venomous_fangs = { 274590 },
            },
        },

        -- Waking Dream
        waking_dream = {
            id = 278513,
            triggers = {
                waking_dream = { 278513 },
            },
        },

        -- Weal and Woe
        weal_and_woe = {
            id = 273307,
            triggers = {
                weal_and_woe = { 273307 },
            },
        },

        -- Whispers of the Damned
        whispers_of_the_damned = {
            id = 275722,
            triggers = {
                whispers_of_the_damned = { 275726, 275722 },
            },
        },

        -- Whiteout
        whiteout = {
            id = 278541,
            triggers = {
                whiteout = { 278541 },
            },
        },

        -- Wild Fleshrending
        wild_fleshrending = {
            id = 279527,
            triggers = {
                wild_fleshrending = { 279527 },
            },
        },

        -- Wilderness Survival
        wilderness_survival = {
            id = 278532,
            triggers = {
                wilderness_survival = { 278532 },
            },
        },

        -- Wildfire
        wildfire = {
            id = 288755,
            triggers = {
                wildfire = { 288800, 288755 },
            },
        },

        -- Wildfire Cluster
        wildfire_cluster = {
            id = 272742,
            triggers = {
                wildfire_cluster = { 272742, 272745 },
            },
        },

        -- Winds of War
        winds_of_war = {
            id = 267671,
            triggers = {
                winds_of_war = { 267671, 269214 },
            },
        },

        -- Word of Mending
        word_of_mending = {
            id = 278645,
            triggers = {
                word_of_mending = { 278645 },
            },
        },

        -- Woundbinder
        woundbinder = {
            id = 267880,
            triggers = {
                woundbinder = { 267880, 269085 },
            },
        },

        -- Wracking Brilliance
        wracking_brilliance = {
            id = 272891,
            triggers = {
                wracking_brilliance = { 272893, 272891 },
            },
        }
    } )
end