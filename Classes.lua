-- Classes.lua
-- July 2014


local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local CommitKey = ns.commitKey

local GetResourceInfo, GetResourceID, GetResourceKey = ns.GetResourceInfo, ns.GetResourceID, ns.GetResourceKey
local RegisterEvent = ns.RegisterEvent

local getSpecializationKey = ns.getSpecializationKey
local tableCopy = ns.tableCopy

local mt_resource = ns.metatables.mt_resource

local upper = string.upper
local wipe = table.wipe





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
            last_tick = 0
        }, mt_resource )
        r.state.regenModel = regen

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
                if not spell:IsSpellEmpty() then spell:ContinueOnSpellLoad( function ()
                    a.name = spell:GetSpellName()
                    a.desc = spell:GetSpellDescription()

                    self.auras[ a.name ] = a
                    if GetSpecializationInfo( GetSpecialization() or 0 ) == self.id then
                        -- Copy to class table as well.
                        class.auras[ a.name ] = a
                    end
                end ) end
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

    RegisterStateExpr = function( self, key, func )
        if rawget( state, key ) then
            Hekili:Error( "Cannot overwrite an existing value/table with RegisterStateExpr (" .. key .. ")." )
            return
        end

        setfenv( func, state )
        self.stateExprs[ key ] = func
    end,

    RegisterStateFunction = function( self, key, func )
        if rawget( state, key ) then
            Hekili:Error( "Cannot overwrite an existing value/table with RegisterStateFunction." )
            return
        end

        setfenv( func, state )
        self.stateFuncs[ key ] = func
    end,

    RegisterStateTable = function( self, key, data )
        if rawget( state, key ) then
            Hekili:Error( "Cannot overwrite an existing table with RegisterStateTable." )
            return
        end

        for k, f in pairs( data ) do
            if type( f ) == 'function' then
                setfenv( f, state )
            end
        end

        local meta = getmetatable( data )

        if meta and meta.__index then
            setfenv( meta.__index, state )
        end

        rawset( state, key, data )
        self.stateTables[ key ] = data
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

    RegisterHook = function( self, event, func )
        self.hooks[ event ] = self.hooks[ event ] or {}
        
        -- func = setfenv( func, state )
        table.insert( self.hooks[ event ], func )
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

            Hekili:ContinueOnItemLoad( data.item, function ()
                local name, link, _, _, _, _, _, _, _, texture = GetItemInfo( data.item )

                if name then
                    a.name = link
                    a.link = link
                    a.texture = texture

                    class.abilities[ name ] = class.abilities[ name ] or a
                    class.abilities[ link ] = class.abilities[ link ] or a

                    if not a.unlisted then class.abilityList[ ability ] = "|T" .. texture .. ":0|t " .. link end
                    if not a.unlisted then class.itemList[ ability ] = "|T" .. texture .. ":0|t " .. link end
                
                    return true
                end

                return false
            end )
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

        if a.id and a.id > 0 then
            local spell = Spell:CreateFromSpellID( a.id )
            if not spell:IsSpellEmpty() then 
                spell:ContinueOnSpellLoad( function () 
                    a.name = spell:GetSpellName()
                    a.desc = spell:GetSpellDescription()

                    if a.suffix then a.name = a.name .. " " .. a.suffix end

                    local texture = a.texture or GetSpellTexture( a.id )

                    self.abilities[ a.name ] = self.abilities[ a.name ] or a
                    
                    class.abilities[ a.name ] = class.abilities[ a.name ] or a
                    if not a.unlisted then class.abilityList[ ability ] = "|T" .. texture .. ":0|t " .. a.name end
                end ) 
            end
        end

        self.abilities[ ability ] = a
        self.abilities[ a.id ] = a

        if not a.unlisted then class.abilityList[ ability ] = class.abilityList[ ability ] or a.name end

        if type( data.copy ) == 'string' or type( data.copy ) == 'number' then
            self.abilities[ data.copy ] = a
        elseif type( data.copy ) == 'table' then
            for _, key in ipairs( data.copy ) do
                self.abilities[ key ] = a
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
    end,

    RegisterEvent = function( self, event, func )
        RegisterEvent( event, function( ... )
            if state.spec.id == self.id then func( ... ) end
        end )
    end,

    RegisterHook = function( self, hook, func )
        self.hooks[ hook ] = self.hooks[ hook ] or {}
        self.hooks[ hook ] = setfenv( func, state )
    end,
}

--[[ function Hekili:RestoreDefaults()
    for key, pack in pairs( self.DB.profile.packs ) do
        if not class.defaults[ key ] then pack.builtIn = false end
    end ]]



function Hekili:RestoreDefaults()
    local p = self.DB.profile

    for k, v in pairs( class.packs ) do
        local existing = rawget( p.packs, k )

        if not existing or not existing.version or existing.version < v.version then
            local data = self:DeserializeActionPack( v.import )

            if data and type( data ) == 'table' then
                p.packs[ k ] = data.payload
                data.payload.version = v.version
                data.payload.builtIn = true
            end
        
        end
    end

    self:RefreshOptions()
end

ns.restoreDefaults = function( category, purge )
    return

    --[[ local profile = Hekili.DB.profile

    if purge then
        for i, display in ipairs( Hekili.DB.profile.displays ) do
            local disable = false
            if display.Default then
                disable = true
                for x, default in ipairs( class.defaults ) do
                    if default.type == 'displays' and default.name == display.Name then
                        disable = false
                        break
                    end
                end
            end
            if disable then
                display.Default = false
                display.enabled = false
            end
        end


        for i, list in ipairs( Hekili.DB.profile.actionLists ) do
            local disable = false
            if list.Default then
                disable = true
                for x, default in ipairs( class.defaults ) do
                    if default.type == 'actionLists' and default.name == list.Name then
                        disable = false
                        break
                    end
                end
            end
            if disable then
                list.Default = false
                -- list.enabled = false
            end
        end
    end


    -- By default, restore action lists.
    if not category or category == 'actionLists' then
        for i, default in ipairs( class.defaults ) do
            if default.type == 'actionLists' then
                local reload = true
                local index
                
                for j, list in ipairs( profile.actionLists ) do
                    if list.Name == default.name then
                        if type(list.Release) == 'string' then list.Release = tonumber( list.Release ) end
                        reload = list.Default and ( list.Release < default.version )
                        index = j
                        break
                    end
                end
                
                if reload then
                    local import = ns.deserializeActionList( default.import )
                    
                    if import and type( import ) == 'table' then
                        import.Name = default.name
                        import.Release = default.version
                        import.Default = true
                        if not index then index = #profile.actionLists + 1 end
                        ns.Error( "rD() - putting " .. default.name .. " at index " .. index .. "." )
                        profile.actionLists[ index ] = import
                    else
                        ns.Error( "restoreDefaults() - unable to import actionList " .. default.name .. "." )
                    end
                end
            end
        end
    end
    
    
    if not category or category == 'displays' then
        for i, default in ipairs( class.defaults ) do
            if default.type == 'displays' then
                local reload = true
                local index
                
                for j, display in ipairs( profile.displays ) do
                    if display.Name == default.name then
                        index = j
                        if type( display.Release ) == 'string' then display.Release = tonumber( display.Release ) end
                        reload = display.Default and ( display.Release < default.version )
                        break
                    end
                end
                
                if reload then
                    ns.Error( "restoreDefaults() - didn't find " .. default.name .. "." )
                    local import = ns.deserializeDisplay( default.import )
                    
                    if import and type( import ) == 'table' then
                        import.Name = default.name
                        import.Release = default.version
                        import.Default = true
                        
                        if index then
                            local existing = profile.displays[ index ]

                            -- Overwrite only what wasn't customized.
                            for setting, value in pairs( import ) do
                                if existing[ setting ] == nil then existing[ setting ] = value end
                            end

                            -- Except APLs and release.
                            existing.Release = default.version
                            existing.Default = true
                            existing.precombatAPL = import.precombatAPL
                            existing.defaultAPL = import.defaultAPL
                        
                        else
                            index = #profile.displays + 1
                            profile.displays[ index ] = import

                        end

                        local updated = profile.displays[ index ]

                        if type( updated.precombatAPL ) == 'string' then
                            for i, list in pairs( profile.actionLists ) do
                                if list.Name == updated.precombatAPL then
                                    updated.precombatAPL = i
                                end
                            end

                            if type( updated.precombatAPL ) == 'string' then
                                updated.precombatAPL = 0
                            end
                        end

                        if type( updated.defaultAPL ) == 'string' then
                            for i, list in pairs( profile.actionLists ) do
                                if list.Name == updated.defaultAPL then
                                    updated.defaultAPL = i
                                end
                            end

                            if type( updated.defaultAPL ) == 'string' then
                                updated.defaultAPL = 0
                            end
                        end

                    else
                        ns.Error( "restoreDefaults() - unable to import '" .. default.name .. "' display." )
                    end
                end
            end
        end
    end
    
    self:RefreshOptions()
    scripts:LoadScripts() ]]
    
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


function Hekili:NewSpecialization( specID, name, texture )

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

        resources = {},
        
        talents = {},
        pvptalents = {},
        
        auras = {},
        pseudoAuras = 0,

        abilities = {},
        pseudoAbilities = 0,
        itemAbilities = 0,

        potions = {},

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

    enlisted = {
        id = 269083,
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
                local _, _, _, startCast, endCast, _, _, notInterruptible, spell = UnitCastingInfo( "target" )
        
                if notInterruptible == false then
                    aura.name = "Casting " .. spell
                    aura.count = 1
                    aura.expires = endCast / 1000
                    aura.applied = startCast / 1000
                    aura.v1 = spell
                    aura.caster = 'target'
                    return
                end

                _, _, _, startCast, endCast, _, _, notInterruptible, spell = UnitChannelInfo( "target" )
                
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
            local aura = buff.casting

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

    -- setGCD?

    berserking = {
        id = 26297,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        usable = function () return race.troll end,
        handler = function ()
            applyBuff( 'berserking' )
        end,

        toggle = "cooldowns",
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

        usable = function () return race.orc end,
        handler = function ()
            applyBuff( "blood_fury", 15 )
        end,
    
        toggle = "cooldowns",
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
        gcd = "off",

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
        toggle = 'potions',

        handler = function ()
            local potion = args.ModName or args.name or class.potion
            potion = class.potions[ potion ]

            if potion then
                applyBuff( potion.buff, potion.duration or 25 )
            end
        end,

        usable = function ()
            if not toggle.potions then return false end
            local pName = args.ModName or args.name or class.potion
            local potion = class.potions[ pName ]
            if not potion or GetItemCount( potion.item ) == 0 then return false end
            return true
        end,
    },

    use_items = {
        name = "|cff00ccff[Use Items]|r",
        cast = 0,
        cooldown = 120,
        gcd = 'off',

        toggle = 'cooldowns',
    },
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
    ready = function () return debuff.temptation.remains end,

    handler = function ()
        applyDebuff( "player", "temptation", 30, debuff.temptation.stack + 1 )
    end
} )

all:RegisterAura( "temptation", {
    id = 234143,
    duration = 30,
    max_stack = 20
} )


--[[
    
    addAbility( "forgefiends_fabricator", {
        id = -104,
        item = 151963,
        spend = 0,
        cast = 0,
        cooldown = 30,
        gcd = 'off',
    } )
    
    
    addUsableItem( "horn_of_valor", 133642 )
    
    addAbility( "horn_of_valor", {
        id = -105,
        item = 133642,
        spend = 0,
        cast = 0,
        cooldown = 120,
        gcd = 'off',
        toggle = 'cooldowns',
    } )
    
    addAura( "valarjars_path", 215956, "duration", 30 )
    
    addHandler( "horn_of_valor", function ()
        applyBuff( "valarjars_path" )
    end )
    
    
    addUsableItem( "kiljaedens_burning_wish", 144259 )
    
    addAbility( "kiljaedens_burning_wish", {
        id = -106,
        item = 144259,
        spend = 0,
        cast = 0,
        cooldown = 75,
        texture = 1357805,
        gcd = 'off',
        toggle = 'cooldowns',
    } )
    
    
    addAbility( "might_of_krosus", {
        id = -107,
        item = 140799,
        spend = 0,
        cast = 0,
        cooldown = 30,
        gcd = 'off',
    } )
    
    addHandler( "might_of_krosus", function ()
        if active_enemies > 3 then setCooldown( "might_of_krosus", 15 ) end
    end )
    
    
    addUsableItem( "ring_of_collapsing_futures", 142173 )
    
    addAbility( "ring_of_collapsing_futures", {
        id = -108,
        item = 142173,
        spend = 0,
        cast = 0,
        cooldown = 15,
        gcd = 'off',
        ready = function () return debuff.temptation.remains end,
    } )
    
    addAura( 'temptation', 234143, 'duration', 30, 'max_stack', 20 )
    
    addHandler( "ring_of_collapsing_futures", function ()
        applyDebuff( "player", "temptation", 30, debuff.temptation.stack + 1 )
    end )
    
    
    addUsableItem( "specter_of_betrayal", 151190 )
    
    addAbility( "specter_of_betrayal", {
        id = -109,
        item = 151190,
        spend = 0,
        cast = 0,
        cooldown = 45,
        gcd = 'off',
    } )
    
    
    addUsableItem( "tiny_oozeling_in_a_jar", 137439 )
    
    addAbility( "tiny_oozeling_in_a_jar", {
        id = -110,
        item = 137439,
        spend = 0,
        cast = 0,
        cooldown = 20,
        gcd = "off",
        usable = function () return buff.congealing_goo.stack == 6 end,
    } )
    
    addAura( "congealing_goo", 215126, "duration", 60, "max_stack", 6 )
    
    addHandler( "tiny_oozeling_in_a_jar", function ()
        removeBuff( "congealing_goo" )
    end )
    
    
    addUsableItem( "umbral_moonglaives", 147012 )
    
    addAbility( "umbral_moonglaives", {
        id = -111,
        item = 147012,
        spend = 0,
        cast = 0,
        cooldown = 90,
        gcd = 'off',
        toggle = 'cooldowns',
    } )
    
    
    addUsableItem( "unbridled_fury", 139327 )
    
    addAbility( "unbridled_fury", {
        id = -112,
        item = 139327,
        spend = 0,
        cast = 0,
        cooldown = 120,
        gcd = 'off',
        toggle = 'cooldowns',
    } )
    
    addAura( "wild_gods_fury", 221695, "duration", 30 )
    
    addHandler( "unbridled_fury", function ()
        applyBuff( "unbridled_fury" )
    end )
    
    
    addUsableItem( "vial_of_ceaseless_toxins", 147011 )
    
    addAbility( "vial_of_ceaseless_toxins", {
        id = -113,
        item = 147011,
        spend = 0,
        cast = 0,
        cooldown = 60,
        gcd = 'off',
        toggle = 'cooldowns',
    } )
    
    addAura( "ceaseless_toxin", 242497, "duration", 20 )
    
    addHandler( "vial_of_ceaseless_toxins", function ()
        applyDebuff( "target", "ceaseless_toxin", 20 )
    end )
    
    
    addUsableItem( "tome_of_unraveling_sanity", 147019 )
    
    addAbility( "tome_of_unraveling_sanity", {
        id = -114,
        item = 147019,
        spend = 0,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        toggle = "cooldowns",
    } )
    
    addAura( "insidious_corruption", 243941, "duration", 12 )
    addAura( "extracted_sanity", 243942, "duration", 24 )
    
    addHandler( "tome_of_unraveling_sanity", function ()
        applyDebuff( "target", "insidious_corruption", 12 )
    end )    

addGearSet( 'aggramars_stride', 132443 )
    addAura( 'aggramars_stride', 207438, 'duration', 3600 )

addGearSet( 'sephuzs_secret', 132452 )
    addAura( 'sephuzs_secret', 208051, 'duration', 10 )

addGearSet( 'amanthuls_vision', 154172 )
    addAura( 'glimpse_of_enlightenment', 256818, 'duration', 12 )
    addAura( 'amanthuls_grandeur', 256832, 'duration', 15 )

addGearSet( 'insignia_of_the_grand_army', 152626 )

addGearSet( 'eonars_compassion', 154172 )
    addAura( 'mark_of_eonar', 256824, 'duration', 12 )
    addAura( 'eonars_verdant_embrace', 257475, 'duration', 20 )
        class.auras[ 257470 ] = class.auras[ 257475 ]
        class.auras[ 257471 ] = class.auras[ 257475 ]
        class.auras[ 257472 ] = class.auras[ 257475 ]
        class.auras[ 257473 ] = class.auras[ 257475 ]
        class.auras[ 257474 ] = class.auras[ 257475 ]
    modifyAura( 'eonars_verdant_embrace', 'id', function( x )
        if class.file == "SHAMAN" then return x end
        if class.file == "DRUID" then return 257470 end
        if class.file == "MONK" then return 257471 end
        if class.file == "PALADIN" then return 257472 end
        if class.file == "PRIEST" then
            if spec.discipline then return 257473 end
            if spec.holy then return 257474 end
        end
        return x
    end )
    addAura( 'verdant_embrace', 257444, 'duration', 30 )


addGearSet( 'aggramars_conviction', 154173 )
    addAura( 'celestial_bulwark', 256816, 'duration', 14 )
    addAura( 'aggramars_fortitude', 256831, 'duration', 15 )

addGearSet( 'golganneths_vitality', 154174 )
    addAura( 'golganneths_thunderous_wrath', 256833, 'duration', 15 )

addGearSet( 'khazgoroths_courage', 154176 )
    addAura( 'worldforgers_flame', 256826, 'duration', 12 )
    addAura( 'khazgoroths_shaping', 256835, 'duration', 15 )

addGearSet( 'norgannons_prowess', 154177 )
    addAura( 'rush_of_knowledge', 256828, 'duration', 12 )
    addAura( 'norgannons_command', 256836, 'duration', 15, 'max_stack', 6 )


addAbility( 'potion', {
    id = -4,
    name = '|cff00ccff[Potion]|r',
    spend = 0,
    cast = 0,
    gcd = 'off',
    cooldown = 60,
    passive = true,
    toggle = 'potions',
    usable = function ()
        if not toggle.potions then return false end

        local pName = args.ModName or args.name or class.potion

        local potion = class.potions[ pName ]

        if not potion or GetItemCount( potion.item ) == 0 then return false end
        return true
    end
} )

modifyAbility( 'potion', 'cooldown', function ( x )
    if time > 0 then return 3600 end
    return x
end )

addHandler( 'potion', function ()
    local potion = args.ModName or args.name or class.potion
    local potion = class.potions[ potion ]
    
    if potion then
        applyBuff( potion.buff, potion.duration or 25 )
    end
    
end )


addAbility( "use_items", {
    id = -99,
    name = "|cff00ccff[Use Items]|r",
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )


addAbility( "draught_of_souls", {
    id = -101,
    item = 140808,
    spend = 0,
    cast = 0,
    cooldown = 80,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "fel_crazed_rage", 225141, "duration", 3, "incapacitate", true )

addHandler( "draught_of_souls", function ()
    applyBuff( "fel_crazed_rage", 3 )
    setCooldown( "global_cooldown", 3 )
end )


addAbility( "faulty_countermeasure", {
    id = -102,
    item = 137539,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "sheathed_in_frost", 214962, "duration", 30 )

addHandler( "faulty_countermeasure", function ()
    applyBuff( "sheathed_in_frost", 30 )
end )


addUsableItem( "feloiled_infernal_machine", 144482 )

addAbility( "feloiled_infernal_machine", {
    id = -103,
    item = 144482,
    spend = 0,
    cast = 0,
    cooldown = 80,
    gcd = 'off',
    toggle = 'cooldowns'
} )

addAura( "grease_the_gears", 238534, "duration", 20 )

addHandler( "feloiled_infernal_machine", function ()
    applyBuff( "grease_the_gears" )
end )


addAbility( "forgefiends_fabricator", {
    id = -104,
    item = 151963,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = 'off',
} )


addUsableItem( "horn_of_valor", 133642 )

addAbility( "horn_of_valor", {
    id = -105,
    item = 133642,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "valarjars_path", 215956, "duration", 30 )

addHandler( "horn_of_valor", function ()
    applyBuff( "valarjars_path" )
end )


addUsableItem( "kiljaedens_burning_wish", 144259 )

addAbility( "kiljaedens_burning_wish", {
    id = -106,
    item = 144259,
    spend = 0,
    cast = 0,
    cooldown = 75,
    texture = 1357805,
    gcd = 'off',
    toggle = 'cooldowns',
} )


addAbility( "might_of_krosus", {
    id = -107,
    item = 140799,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = 'off',
} )

addHandler( "might_of_krosus", function ()
    if active_enemies > 3 then setCooldown( "might_of_krosus", 15 ) end
end )


addUsableItem( "ring_of_collapsing_futures", 142173 )

addAbility( "ring_of_collapsing_futures", {
    id = -108,
    item = 142173,
    spend = 0,
    cast = 0,
    cooldown = 15,
    gcd = 'off',
    ready = function () return debuff.temptation.remains end,
} )

addAura( 'temptation', 234143, 'duration', 30, 'max_stack', 20 )

addHandler( "ring_of_collapsing_futures", function ()
    applyDebuff( "player", "temptation", 30, debuff.temptation.stack + 1 )
end )


addUsableItem( "specter_of_betrayal", 151190 )

addAbility( "specter_of_betrayal", {
    id = -109,
    item = 151190,
    spend = 0,
    cast = 0,
    cooldown = 45,
    gcd = 'off',
} )


addUsableItem( "tiny_oozeling_in_a_jar", 137439 )

addAbility( "tiny_oozeling_in_a_jar", {
    id = -110,
    item = 137439,
    spend = 0,
    cast = 0,
    cooldown = 20,
    gcd = "off",
    usable = function () return buff.congealing_goo.stack == 6 end,
} )

addAura( "congealing_goo", 215126, "duration", 60, "max_stack", 6 )

addHandler( "tiny_oozeling_in_a_jar", function ()
    removeBuff( "congealing_goo" )
end )


addUsableItem( "umbral_moonglaives", 147012 )

addAbility( "umbral_moonglaives", {
    id = -111,
    item = 147012,
    spend = 0,
    cast = 0,
    cooldown = 90,
    gcd = 'off',
    toggle = 'cooldowns',
} )


addUsableItem( "unbridled_fury", 139327 )

addAbility( "unbridled_fury", {
    id = -112,
    item = 139327,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "wild_gods_fury", 221695, "duration", 30 )

addHandler( "unbridled_fury", function ()
    applyBuff( "unbridled_fury" )
end )


addUsableItem( "vial_of_ceaseless_toxins", 147011 )

addAbility( "vial_of_ceaseless_toxins", {
    id = -113,
    item = 147011,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "ceaseless_toxin", 242497, "duration", 20 )

addHandler( "vial_of_ceaseless_toxins", function ()
    applyDebuff( "target", "ceaseless_toxin", 20 )
end )


addUsableItem( "tome_of_unraveling_sanity", 147019 )

addAbility( "tome_of_unraveling_sanity", {
    id = -114,
    item = 147019,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = "off",
    toggle = "cooldowns",
} )

addAura( "insidious_corruption", 243941, "duration", 12 )
addAura( "extracted_sanity", 243942, "duration", 24 )

addHandler( "tome_of_unraveling_sanity", function ()
    applyDebuff( "target", "insidious_corruption", 12 )
end )


class.itemsInAPL = {}

-- If an item is handled by a spec's APL, drop it from Use Items.
function ns.registerItem( key, spec )
    if not key or not spec then return end

    class.itemsInAPL[ spec ] = class.itemsInAPL[ spec ] or {}

    class.itemsInAPL[ spec ][ key ] = not class.itemsInAPL[ spec ][ key ]
end
]]


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


local function addGearSet( name, ... )

    class.gear[ name ] = class.gear[ name ] or {}

    for i = 1, select( '#', ... ) do
        local id = select( i, ... )
        local key = ns.formatKey( GetItemInfo( select( i, ... ) ) or "nothing" )
        class.gear[ name ][ id ] = key
    end

    ns.commitKey( name )

end
ns.addGearSet = addGearSet


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


local function addUsableItem( key, id )
    class.items = class.items or {}
    class.items[ key ] = id

    addGearSet( key, id )
    addItemSettings( key, id )
end
ns.addUsableItem = addUsableItem


function Hekili:GetAbilityInfo( index )

    local ability = class.abilities[ index ]

    if not ability then return end

    -- Decide if more details are needed later.
    return ability.id, ability.name, ability.key, ability.item

end


class.interrupts = {}

function ns.registerInterrupt( key )
    if class.abilities[ key ] and class.abilities[ key ].toggle and class.abilities[ key ].toggle == 'interrupts' then
        class.interrupts[ key ] = true
    end
end


local storeAuraElements = function( key, ... )

    local aura = class.auras[ key ]

    if not aura then
        ns.Error( "storeAuraElements() - no aura '" .. key .. "' in auras table." )
        return
    end

    for i = 1, select( "#", ... ), 2 do
        local k, v = select( i, ... ), select( i+1, ... )

        if k and v then
            if k == 'id' or k == 'name' then aura[k] = v
            elseif type(v) == 'function' then aura.elem[k] = setfenv( v, state )
            else aura.elem[k] = v end
        end
    end

end
ns.storeAuraElements = storeAuraElements


local function modifyAura( key, elem, func )
    modifyElement( 'auras', key, elem, func )
end
ns.modifyAura = modifyAura


local function addAura( key, id, ... )

    local name = GetSpellInfo( id )

    if not class.auras[ key ] then

        class.auras[ key ] = setmetatable( {
            id = id,
            key = key,
            elem = {},
            mods = {}
        }, mt_modifiers )

        ns.commitKey( key )

        -- Add the elements, front-loading defaults and just overriding them if something else is specified.
        storeAuraElements( key, 'name', name, 'duration', 30, 'max_stack', 1, ... )

    end
    
    -- Allow reference by ID and name as well.
    class.auras[ id ] = class.auras[ key ]
    if name then class.auras[ name ] = class.auras[ key ] end
    
end
ns.addAura = addAura


local function addGlyph( key, id )

    local name = GetSpellInfo( id )
    
    if not name then
        ns.Error( "addGlyph() - unable to get glyph name from id#" .. id .. "." )
        return
    end
        
        class.glyphs[ key ] = {
        id = id,
        name = name
    }

    ns.commitKey( key )

end
ns.addGlyph = addGlyph 


local function addPet( key, permanent )
    state.pet[ key ] = rawget( state.pet, key ) or {}
    state.pet[ key ].name = key
    state.pet[ key ].expires = 0

    ns.commitKey( key )
end
ns.addPet = addPet


local function addTalent( key, id, ... )

    local _, name = GetTalentInfoByID( id )

    if not name then
        ns.Error( "addTalent() - unable to get talent name from id #" .. id .. "." )
        return
    end

    class.talents[ key ] = {
        id = id,
        name = name
    }

    ns.commitKey( key )
end
ns.addTalent = addTalent


local primarySet = false

local function addResource( resource, power_type )

    class.resources[ resource ] = power_type

    if not primarySet then
        class.primaryResource = resource
        primarySet = true
    end

    state[ resource ] = rawget( state, resource ) or setmetatable( {
        resource = resource,
        type = power_type,
        forecast = {},
        fcount = 0,
        times = {},
        values = {},
        last_tick = 0
    }, mt_resource )
    state[ resource ].regenerates = not no_regen

    state[ resource ].time_to = function( amount )
        return state:TimeToResource( state[ resource ], amount )
    end

    ns.commitKey( resource )

end
ns.addResource = addResource


local function removeResource( resource )

    class.resources[ resource ] = nil
    -- class.regenModel = nil

    if class.primaryResource == resource then
        class.primaryResource = nil
        primarySet = false
    end

end
ns.removeResource = removeResource


local function setPrimaryResource( resource )

    class.primaryResource = resource
    primarySet = true

end
ns.setPrimaryResource = setPrimaryResource


local function setRegenModel( db )
    class.regenModel = db
end
ns.setRegenModel = setRegenModel


{
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
}


local function setPotion( potion )
    class.potion = potion
    class.auras.potion = class.auras[ class.potions[ potion ].buff ]
end
ns.setPotion = setPotion


local function addHandler( key, func, tt )

    local ability = class.abilities[ key ]

    if not ability then
        ns.Error( "addHandler() attempting to store handler for non-existant ability '" .. key .. "'." )
        return
    end

    if tt then
        ability.elem[ 'onHit' ] = setfenv( func, state )
    else
        ability.elem[ 'handler' ] = setfenv( func, state )
    end

end
ns.addHandler = addHandler


local function runHandler( key, no_start )

    local ability = class.abilities[ key ]

    if not ability then
        -- ns.Error( "runHandler() attempting to run handler for non-existant ability '" .. key .. "'." )
        return
    end

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


function Hekili:SpecializationChanged()
    for k, _ in pairs( state.spec ) do
        state.spec[ k ] = nil
    end

    for key in pairs( GetResourceInfo() ) do
        state[ key ] = nil
        class[ key ] = nil
    end

    class.primaryResource = nil

    wipe( class.auras )
    wipe( class.abilities )
    wipe( class.talents )
    wipe( class.pvptalents )
    wipe( class.gear )
    wipe( class.packs )
    wipe( class.hooks )

    local specs = { 0 }
    local currentSpec = GetSpecialization()
    local currentID = GetSpecializationInfo( currentSpec )

    for i = 1, 4 do
        local id, name, _, _, role = GetSpecializationInfo( i )

        if not id then break end

        if i == currentSpec then
            table.insert( specs, 2, id )

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
    class.primaryResource = nil


    for k in pairs( class.stateTables ) do
        state[ k ] = nil
        class.stateTables[ k ] = nil
    end

    for k in pairs( class.stateFuncs ) do
        state[ k ] = nil
        class.stateFuncs[ k ] = nil
    end

    wipe( class.stateExprs )

    for i, specID in ipairs( specs ) do
        local spec = class.specs[ specID ]

        if spec then
            if specID == currentID then
                for res, model in pairs( spec.resources ) do
                    class.resources[ res ] = model
                    state[ res ] = model.state
                end

                for talent, id in pairs( spec.talents ) do
                    class.talents[ talent ] = id
                end

                for talent, id in pairs( spec.pvptalents ) do
                    class.pvptalents[ talent ] = id
                end

                for name, func in pairs( spec.stateExprs ) do
                    class.stateExprs[ name ] = func
                end

                for name, func in pairs( spec.stateFuncs ) do
                    class.stateFuncs[ name ] = func
                    rawset( state, name, func )
                end

                for name, t in pairs( spec.stateTables ) do
                    class.stateTables[ name ] = t
                    rawset( state, name, t )
                end

                for name, func in pairs( spec.hooks ) do
                    class.hooks[ name ] = func
                end 

                class.potion = spec.potion or class.potion
                class.potionList.default = "|cFFFFD100Default|r"
            end

            for k, v in pairs( spec.auras ) do
                if not class.auras[ k ] then class.auras[ k ] = v end
            end

            for k, v in pairs( spec.abilities ) do
                if not class.abilities[ k ] then class.abilities[ k ] = v end
            end

            for k, v in pairs( spec.gear ) do
                if not class.gear[ k ] then class.gear[ k ] = v end
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

            local s = Hekili.DB.profile.specs[ spec.id ]
            for k, v in pairs( spec.options ) do
                if s[ k ] == nil then s[ k ] = v end
            end
        end
    end


    state.GUID = UnitGUID( 'player' )
    state.player.unit = UnitGUID( 'player' )

    ns.updateGear()
    ns.updateTalents()

    ns.callHook( 'specializationChanged' )

    self:UpdateDisplayVisibility()
    self:LoadScripts()

end


ns.specializationChanged = function()
    Hekili:SpecializationChanged()
    --[[ 
    for k, _ in pairs( state.spec ) do
        state.spec[ k ] = nil
    end

    if GetSpecialization() then
        state.spec.id, state.spec.name = GetSpecializationInfo( GetSpecialization() )
        state.spec.key = getSpecializationKey( state.spec.id )
        state.spec[ state.spec.key ] = true
    end

    state.GUID = UnitGUID( 'player' )
    state.player.unit = UnitGUID( 'player' )

    ns.updateGear()
    ns.updateTalents()

    Hekili:UpdateDisplayVisibility()

    ns.callHook( 'specializationChanged' ) ]]
end



--[[

local function setTalentLegendary( item, spec, talent )

    class.talentLegendary[ item ] = class.talentLegendary[ item ] or {}
    class.talentLegendary[ item ][ spec ] = talent

end
ns.setTalentLegendary = setTalentLegendary

------------------------------
-- SHARED SPELLS/BUFFS/ETC. --
------------------------------

-- Bloodlust.
addAura( 'ancient_hysteria', 90355, 'duration', 40 )
addAura( 'heroism', 32182, 'duration', 40 )
addAura( 'time_warp', 80353, 'duration', 40 )
addAura( 'netherwinds', 160452, 'duration', 40 )

local bloodlusts = { 
    [90355] = 'ancient_hysteria',
    [32182] = 'heroism',
    [80353] = 'time_warp',
    [160452] = 'netherwinds',
}

-- bloodlust is the "umbrella" aura for all burst haste effects.
addAura( 'bloodlust', 2825, 'duration', 40, 'feign', function ()
    for id, key in pairs( bloodlusts ) do
        if buff[ key ].up then
            buff.bloodlust.count = buff[ key ].count
            buff.bloodlust.expires = buff[ aura ].expires
            buff.bloodlust.applied = buff[ aura ].applied
            buff.bloodlust.caster = buff[ aura ].caster
            return
        end
    end
    
    local name, count, duration, expires, spellID
    for i = 1, 40 do
        name, _, count, _, duration, expires, _, _, _, spellID = UnitBuff( 'player', i )

        if not name then break end
        if spellID == 2525 then break end
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
    buff.bloodlust.caster = 'unknown'

end )

-- Sated.
addAura( 'exhaustion', 57723, 'duration', 600 )
addAura( 'insanity', 95809, 'duration', 600 )
addAura( 'sated', 57724, 'duration', 600 )
addAura( 'temporal_displacement', 80354, 'duration', 600 )
addAura( 'fatigued', 160455, 'duration', 600 )

-- Enchants.
addAura( 'dancing_steel', 104434, 'duration', 12, 'max_stack', 2 )

-- Potions.
addAura( 'jade_serpent_potion', 105702, 'duration', 25 )
addAura( 'mogu_power_potion', 105706, 'duration', 25 )
addAura( 'virmens_bite_potion', 105697, 'duration', 25 )
addAura( 'draenic_agility_potion', 156423, 'duration', 25 )
addAura( 'draenic_armor_potion', 156430, 'duration', 25 )
addAura( 'draenic_intellect_potion', 156425, 'duration', 25 )
addAura( 'draenic_strength_potion', 156428, 'duration', 25 )
addAura( 'old_war', 188028, 'duration', 25 )
addAura( 'deadly_grace', 188027, 'duration', 25 )
addAura( 'prolonged_power', 229206, 'duration', 60 )

-- Trinkets.
addAura( 'dextrous', 146308, 'duration', 20 )
addAura( 'vicious', 148903, 'duration', 10 )

-- Legendary
addAura( 'archmages_incandescence_agi', 177161, 'duration', 10 )
addAura( 'archmages_incandescence_int', 177159, 'duration', 10 )
addAura( 'archmages_incandescence_str', 177160, 'duration', 10 )
addAura( 'archmages_greater_incandescence_agi', 177172, 'duration', 10 )
addAura( 'archmages_greater_incandescence_int', 177176, 'duration', 10 )
addAura( 'archmages_greater_incandescence_str', 177175, 'duration', 10 )

addAura( 'maalus', 187620, 'duration', 15 )
addAura( 'thorasus', 187619, 'duration', 15 )

-- Raid Buffs
addAura( 'str_agi_int', -1, 'duration', 3600 )
addAura( 'stamina', -2, 'duration', 3600 )
addAura( 'attack_power_multiplier', -3, 'duration', 3600 )
addAura( 'haste', -4, 'duration', 3600 )
addAura( 'spell_power_multiplier', -5, 'duration', 3600 )
addAura( 'critical_strike', -6, 'duration', 3600 )
addAura( 'mastery', -7, 'duration', 3600 )
addAura( 'multistrike', -8, 'duration', 3600 )
addAura( 'versatility', -9, 'duration', 3600 )


addAura( 'casting', -10, 'feign', function ()    
    if UnitCanAttack( "player", "target" ) then
        local _, _, _, startCast, endCast, _, _, notInterruptible, spell = UnitCastingInfo( "target" )
        
        if notInterruptible == false then
            debuff.casting.name = "Casting " .. spell
            debuff.casting.count = 1
            debuff.casting.expires = endCast / 1000
            debuff.casting.applied = startCast / 1000
            debuff.casting.v1 = spell
            debuff.casting.caster = 'target'
            return
        end

        _, _, _, startCast, endCast, _, _, notInterruptible, spell = UnitChannelInfo( "target" )
        
        if notInterruptible == false then
            debuff.casting.name = "Casting " .. spell
            debuff.casting.count = 1
            debuff.casting.expires = endCast / 1000
            debuff.casting.applied = startCast / 1000
            debuff.casting.v1 = spell
            debuff.casting.caster = 'target'
            return
        end
    end

    debuff.casting.name = "Casting"
    debuff.casting.count = 0
    debuff.casting.expires = 0
    debuff.casting.applied = 0
    debuff.casting.v1 = 0
    debuff.casting.caster = 'target'
end )


addAura( "player_casting", -11, "duration", 3 )

addAura( 'unknown_buff', -15 )



addAbility( 'global_cooldown',
{
    id = 61304,
    spend = 0,
    cast = 0,
    gcd = 'spell',
    cooldown = 0,
    known = function () return true end,
} )


class.gcd = 'global_cooldown'


-- Racials.
-- AddSpell( 26297, "berserking", 10 )
addAbility( 'berserking',
{
    id = 26297,
    spend = 0,
    cast = 0,
    gcd = 'off',
    cooldown = 180,
    toggle = "cooldowns",
    usable = function () return race.troll end,
} )

addHandler( 'berserking', function ()
    applyBuff( 'berserking' )
    end )

addAura( 'berserking', 26297, 'duration', 10 )


-- AddSpell( 20572, "blood_fury", 15 )
addAbility( 'blood_fury', {
    id = 20572,
    spend = 0,
    cast = 0,
    gcd = 'off',
    cooldown = 120,
    toggle = "cooldowns",
    usable = function () return race.orc end,
}, 33697, 33702 )

modifyAbility( 'blood_fury', 'id', function( x )
    if class.file == 'MONK' or class.file == 'SHAMAN' then return 33697 end
    return x
    end )

addHandler( 'blood_fury', function ()
    applyBuff( 'blood_fury', 15 )
    end )


addAura( 'blood_fury', 20572, 'duration', 15 )


addAbility( 'arcane_torrent', {
    id = 28730,
    spend = 0,
    cast = 0,
    gcd = 'off',
    cooldown = 120,
    toggle = 'cooldowns',
    usable = function () return race.blood_elf end,
}, 50613, 80483, 129597, 155145, 25046, 69179, 202719, 232633 )

local atIDs = {
    PALADIN     = 155145,
    MONK        = 129597,
    DEATHKNIGHT = 50613,
    WARRIOR     = 69179,
    ROGUE       = 25046,
    HUNTER      = 80483,
    DEMONHUNTER = 202719,
    PRIEST      = 232633
}

modifyAbility( 'arcane_torrent', 'id', function( x )
    return atIDs[ class.file ] or x
end )

addHandler( 'arcane_torrent', function ()
    if class.file == "DEATHKNIGHT" then gain( 20, "runic_power" )
    elseif class.file == "HUNTER" then gain( 15, "focus" )
    elseif class.file == "MONK" then gain( 1, "chi" )
    elseif class.file == "PALADIN" then gain( 1, "holy_power" )
    elseif class.file == "ROGUE" then gain( 15, "energy" )
    elseif class.file == "WARRIOR" then gain( 15, "rage" )
    elseif class.file == "DEMONHUNTER" then gain( 15, "fury" ) end 
end )

ns.registerInterrupt( 'arcane_torrent' )


addAura( "shadowmeld", 58984, "duration", 3600 )

addAbility( "shadowmeld", {
    id = 58984,
    cast = 0,
    gcd = "off",
    cooldown = 120,
    passive = true,
    usable = function () return race.night_elf and boss end, -- Only use in boss combat, dropping aggro is for the birds.
} )

addHandler( "shadowmeld", function ()
    applyBuff( "shadowmeld" )
end )


addAbility( "lights_judgment", {
    id = 255647,
    cast = 0,
    gcd = "spell",
    cooldown = 150,
    toggle = 'cooldowns',
    usable = function () return race.lightforged_draenei end
} )



addAbility( 'call_action_list', {
    id = -1,
    name = '|cff00ccff[Call Action List]|r',
    cast = 0,
    gcd = 'off',
    cooldown = 0,
    passive = true
} )


addAbility( 'run_action_list', {
    id = -2,
    name = '|cff00ccff[Run Action List]|r',
    cast = 0,
    gcd = 'off',
    cooldown = 0,
    passive = true
} )


-- Special Instructions
addAbility( 'wait', {
    id = -3,
    name = '|cff00ccff[Wait]|r',
    cast = 0,
    gcd = 'off',
    cooldown = 0,
    passive = true,
} )


addAbility( 'pool_resource', {
    id = -4,
    name = '|cff00ccff[Pool Resource]|r',
    cast = 0,
    gcd = 'off',
    cooldown = 0,
    passive = true
} )



-- Universal Gear Stuff
addGearSet( 'rethus_incessant_courage', 146667 )
    addAura( 'rethus_incessant_courage', 241330 )

addGearSet( 'vigilance_perch', 146668 )
    addAura( 'vigilance_perch', 241332, 'duration', 60, 'max_stack', 5 )

addGearSet( 'the_sentinels_eternal_refuge', 146669 )
    addAura( 'the_sentinels_eternal_refuge', 241331, 'duration', 60, 'max_stack', 5 )

addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
    addAura( 'xavarics_magnum_opus', 207428, 'duration', 30 )

addGearSet( 'aggramars_stride', 132443 )
    addAura( 'aggramars_stride', 207438, 'duration', 3600 )

addGearSet( 'sephuzs_secret', 132452 )
    addAura( 'sephuzs_secret', 208051, 'duration', 10 )

addGearSet( 'amanthuls_vision', 154172 )
    addAura( 'glimpse_of_enlightenment', 256818, 'duration', 12 )
    addAura( 'amanthuls_grandeur', 256832, 'duration', 15 )

addGearSet( 'insignia_of_the_grand_army', 152626 )

addGearSet( 'eonars_compassion', 154172 )
    addAura( 'mark_of_eonar', 256824, 'duration', 12 )
    addAura( 'eonars_verdant_embrace', 257475, 'duration', 20 )
        class.auras[ 257470 ] = class.auras[ 257475 ]
        class.auras[ 257471 ] = class.auras[ 257475 ]
        class.auras[ 257472 ] = class.auras[ 257475 ]
        class.auras[ 257473 ] = class.auras[ 257475 ]
        class.auras[ 257474 ] = class.auras[ 257475 ]
    modifyAura( 'eonars_verdant_embrace', 'id', function( x )
        if class.file == "SHAMAN" then return x end
        if class.file == "DRUID" then return 257470 end
        if class.file == "MONK" then return 257471 end
        if class.file == "PALADIN" then return 257472 end
        if class.file == "PRIEST" then
            if spec.discipline then return 257473 end
            if spec.holy then return 257474 end
        end
        return x
    end )
    addAura( 'verdant_embrace', 257444, 'duration', 30 )


addGearSet( 'aggramars_conviction', 154173 )
    addAura( 'celestial_bulwark', 256816, 'duration', 14 )
    addAura( 'aggramars_fortitude', 256831, 'duration', 15 )

addGearSet( 'golganneths_vitality', 154174 )
    addAura( 'golganneths_thunderous_wrath', 256833, 'duration', 15 )

addGearSet( 'khazgoroths_courage', 154176 )
    addAura( 'worldforgers_flame', 256826, 'duration', 12 )
    addAura( 'khazgoroths_shaping', 256835, 'duration', 15 )

addGearSet( 'norgannons_prowess', 154177 )
    addAura( 'rush_of_knowledge', 256828, 'duration', 12 )
    addAura( 'norgannons_command', 256836, 'duration', 15, 'max_stack', 6 )


class.potions = {
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
}


addAbility( 'potion', {
    id = -4,
    name = '|cff00ccff[Potion]|r',
    spend = 0,
    cast = 0,
    gcd = 'off',
    cooldown = 60,
    passive = true,
    toggle = 'potions',
    usable = function ()
        if not toggle.potions then return false end

        local pName = args.ModName or args.name or class.potion

        local potion = class.potions[ pName ]

        if not potion or GetItemCount( potion.item ) == 0 then return false end
        return true
    end
} )

modifyAbility( 'potion', 'cooldown', function ( x )
    if time > 0 then return 3600 end
    return x
end )

addHandler( 'potion', function ()
    local potion = args.ModName or args.name or class.potion
    local potion = class.potions[ potion ]
    
    if potion then
        applyBuff( potion.buff, potion.duration or 25 )
    end
    
end )


addAbility( "use_items", {
    id = -99,
    name = "|cff00ccff[Use Items]|r",
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )


addAbility( "draught_of_souls", {
    id = -101,
    item = 140808,
    spend = 0,
    cast = 0,
    cooldown = 80,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "fel_crazed_rage", 225141, "duration", 3, "incapacitate", true )

addHandler( "draught_of_souls", function ()
    applyBuff( "fel_crazed_rage", 3 )
    setCooldown( "global_cooldown", 3 )
end )


addAbility( "faulty_countermeasure", {
    id = -102,
    item = 137539,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "sheathed_in_frost", 214962, "duration", 30 )

addHandler( "faulty_countermeasure", function ()
    applyBuff( "sheathed_in_frost", 30 )
end )


addUsableItem( "feloiled_infernal_machine", 144482 )

addAbility( "feloiled_infernal_machine", {
    id = -103,
    item = 144482,
    spend = 0,
    cast = 0,
    cooldown = 80,
    gcd = 'off',
    toggle = 'cooldowns'
} )

addAura( "grease_the_gears", 238534, "duration", 20 )

addHandler( "feloiled_infernal_machine", function ()
    applyBuff( "grease_the_gears" )
end )


addAbility( "forgefiends_fabricator", {
    id = -104,
    item = 151963,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = 'off',
} )


addUsableItem( "horn_of_valor", 133642 )

addAbility( "horn_of_valor", {
    id = -105,
    item = 133642,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "valarjars_path", 215956, "duration", 30 )

addHandler( "horn_of_valor", function ()
    applyBuff( "valarjars_path" )
end )


addUsableItem( "kiljaedens_burning_wish", 144259 )

addAbility( "kiljaedens_burning_wish", {
    id = -106,
    item = 144259,
    spend = 0,
    cast = 0,
    cooldown = 75,
    texture = 1357805,
    gcd = 'off',
    toggle = 'cooldowns',
} )


addAbility( "might_of_krosus", {
    id = -107,
    item = 140799,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = 'off',
} )

addHandler( "might_of_krosus", function ()
    if active_enemies > 3 then setCooldown( "might_of_krosus", 15 ) end
end )


addUsableItem( "ring_of_collapsing_futures", 142173 )

addAbility( "ring_of_collapsing_futures", {
    id = -108,
    item = 142173,
    spend = 0,
    cast = 0,
    cooldown = 15,
    gcd = 'off',
    ready = function () return debuff.temptation.remains end,
} )

addAura( 'temptation', 234143, 'duration', 30, 'max_stack', 20 )

addHandler( "ring_of_collapsing_futures", function ()
    applyDebuff( "player", "temptation", 30, debuff.temptation.stack + 1 )
end )


addUsableItem( "specter_of_betrayal", 151190 )

addAbility( "specter_of_betrayal", {
    id = -109,
    item = 151190,
    spend = 0,
    cast = 0,
    cooldown = 45,
    gcd = 'off',
} )


addUsableItem( "tiny_oozeling_in_a_jar", 137439 )

addAbility( "tiny_oozeling_in_a_jar", {
    id = -110,
    item = 137439,
    spend = 0,
    cast = 0,
    cooldown = 20,
    gcd = "off",
    usable = function () return buff.congealing_goo.stack == 6 end,
} )

addAura( "congealing_goo", 215126, "duration", 60, "max_stack", 6 )

addHandler( "tiny_oozeling_in_a_jar", function ()
    removeBuff( "congealing_goo" )
end )


addUsableItem( "umbral_moonglaives", 147012 )

addAbility( "umbral_moonglaives", {
    id = -111,
    item = 147012,
    spend = 0,
    cast = 0,
    cooldown = 90,
    gcd = 'off',
    toggle = 'cooldowns',
} )


addUsableItem( "unbridled_fury", 139327 )

addAbility( "unbridled_fury", {
    id = -112,
    item = 139327,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "wild_gods_fury", 221695, "duration", 30 )

addHandler( "unbridled_fury", function ()
    applyBuff( "unbridled_fury" )
end )


addUsableItem( "vial_of_ceaseless_toxins", 147011 )

addAbility( "vial_of_ceaseless_toxins", {
    id = -113,
    item = 147011,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = 'off',
    toggle = 'cooldowns',
} )

addAura( "ceaseless_toxin", 242497, "duration", 20 )

addHandler( "vial_of_ceaseless_toxins", function ()
    applyDebuff( "target", "ceaseless_toxin", 20 )
end )


addUsableItem( "tome_of_unraveling_sanity", 147019 )

addAbility( "tome_of_unraveling_sanity", {
    id = -114,
    item = 147019,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = "off",
    toggle = "cooldowns",
} )

addAura( "insidious_corruption", 243941, "duration", 12 )
addAura( "extracted_sanity", 243942, "duration", 24 )

addHandler( "tome_of_unraveling_sanity", function ()
    applyDebuff( "target", "insidious_corruption", 12 )
end )


class.itemsInAPL = {}

-- If an item is handled by a spec's APL, drop it from Use Items.
function ns.registerItem( key, spec )
    if not key or not spec then return end

    class.itemsInAPL[ spec ] = class.itemsInAPL[ spec ] or {}

    class.itemsInAPL[ spec ][ key ] = not class.itemsInAPL[ spec ][ key ]
end


addAbility( 'variable', {
    id = -5,
    name = '|cff00ccff[Store Value]|r',
    spend = 0,
    cast = 0,
    gcd = 'off',
    cooldown = 0,
} ) ]]
    
    
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
                        addAura( ns.formatKey( buff ), i, 'stat', v.stat, v.duration and "duration", v.duration )
                        class.trinkets[ k ].buff = ns.formatKey( buff )
                    end
                end
            elseif type( buffs ) == 'number' then
                local buff = GetSpellInfo( buffs )
                if buff then
                    addAura( ns.formatKey( buff ), buffs, 'stat', v.stat, v.duration and "duration", v.duration )
                    class.trinkets[ k ].buff = ns.formatKey( buff )
                end
            end
        end
    end
end
    
    


-- Was for module support; disabled.
function Hekili.RetrieveFromNamespace( key )
    return nil
end


function Hekili.StoreInNamespace( key, value )
    -- ns[ key ] = value
end


--
