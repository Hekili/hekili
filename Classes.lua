-- Classes.lua
-- July 2014


local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local getResourceID = ns.getResourceID
local getSpecializationKey = ns.getSpecializationKey

local mt_resource = ns.metatables.mt_resource

local upper = string.upper


ns.initializeClassModule = function()
    -- do nothing, overwrite this stub with a class module.
end


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


local overrideInitialized = false

ns.overrideBinds = function()

    if InCombatLockdown() then
        C_Timer.After( 5, ns.overrideBinds )
        return
    end

    if overrideInitialized then
        ClearOverrideBindings( Hekili_Keyhandler )
    end 

    for i, toggle in ipairs( class.toggles ) do
        for j = 1, 5 do
            if Hekili.DB.profile[ 'Toggle ' .. j .. ' Name' ] == toggle.name then
                Hekili.DB.profile[ 'Toggle ' .. j .. ' Name' ] = nil
            end
        end
        if Hekili.DB.profile[ 'Toggle Bind: ' .. toggle.name ] then
            SetOverrideBindingClick( Hekili_Keyhandler, true, Hekili.DB.profile[ 'Toggle Bind: ' .. toggle.name ], "Hekili_Keyhandler", toggle.name )
            overrideInitialized = true
        end
    end

end


ns.addExclusion = function( spellID )
    class.exclusions[ spellID ] = true
end


ns.addCastExclusion = function( spellID )
    class.castExclusions[ spellID ] = true
end


ns.ignoreCastOnReset = function( spellID )
    class.resetCastExclusions[ spellID ] = true
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




-- Metatable to return modified information about an ability, if available.
local mt_modifiers = {
    __index = function(t, k)
        if t.mods[ k ] then
            local val = t.mods[ k ] ( t.elem[ k ] )
            return val == 'nil' and t.elem[ k ] or val
        elseif t.elem[ k ] then
            return t.elem[ k ]
        end
        return nil
    end
}
ns.mt_modifiers = mt_modifiers


ns.setClass = function( name ) class.file = name end


class.artifacts = {}

function ns.setArtifact( name, remove )
    class.artifacts[ name ] = remove and false or true
end


class.traits = {}

function ns.addTrait( key, id )
    class.traits[ key ] = id
    class.traits[ id ] = key
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
        entry.mods[ elem ] = setfenv( value, ns.state )
    else
        entry.elem[ elem ] = value
    end

end
ns.modifyElement = modifyElement


local function addGearSet( name, ... )

    class.gearsets[ name ] = class.gearsets[ name ] or {}

    for i = 1, select( '#', ... ) do
        local id = select( i, ... )
        local key = ns.formatKey( GetItemInfo( select( i, ... ) ) or "nothing" )
        class.gearsets[ name ][ id ] = key
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

    options.icon = {
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
    }

    options.disabled = {
        type = "toggle",
        name = function () return format( "Disable %s", select( 2, GetItemInfo( itemID ) ) or ( "[" .. itemID .. "]" ) ) end,
        desc = function( info )
            local output = "If disabled, the addon will not recommend this trinket via the [Use Items] action.  You can still manually include the trinket in your action lists with your own tailored criteria."

            for k, v in pairs( class.itemsInAPL ) do
                if v[ key ] then
                    output = output .. "\n\nThis item is auto-disabled for your |cFFFF0000" .. upper( k ) .. "|r specialization; see your Action Lists or Class Settings."
                end
            end

            return output
        end,
        order = 2,
        width = "full"
    }

    options.minimum = {
        type = "range",
        name = "Minimum Targets",
        desc = "The addon will only recommend this trinket (via [Use Items]) when there are at least this many targets available to hit.",
        order = 3,
        width = "full",
        min = 1,
        max = 10,
        step = 1
    }

    options.maximum = {
        type = "range",
        name = "Maximum Targets",
        desc = "The addon will only recommend this trinket (via [Use Items]) when there are no more than this many targets detected.\n\n" ..
            "This setting is ignored if set to 0.",
        order = 4,
        width = "full",
        min = 0,
        max = 10,
        step = 1
    }

    table.insert( class.itemSettings, {
        key = key,
        item = itemID,
        options = options,
    } )  

end


local function addUsableItem( key, id )
    class.items = class.items or {}
    class.items[ key ] = id

    addGearSet( key, id )
    addItemSettings( key, id )
end
ns.addUsableItem = addUsableItem


-- Wrapper for the ability table.
local function modifyAbility( k, elem, value )

    modifyElement( 'abilities', k, elem, value )
    
end
ns.modifyAbility = modifyAbility


local function addAbility( key, values, ... )

    if not values.id then
        ns.Error( "addAbility( " .. key .. " ) - values table is missing 'id' element." )
        return
    end

    if values.item then
        values.name, values.link = GetItemInfo( values.item )

        if not values.name then
            values.name = tostring( key )
            values.recheck_name = true
        end

        values.texture = select( 10, GetItemInfo( values.item ) ) or 'Interface\\ICONS\\Spell_Nature_BloodLust'
        addUsableItem( key, values.item )
    end
    
    local name = values.name or GetSpellInfo( values.id )

    if not name and values.id > 0 then
        ns.Error( "addAbility( " .. key .. " ) - unable to get name of spell #" .. values.id .. "." )
        return
    end
    
    class.abilities[ key ] = setmetatable( {
        name = name,
        key = key,
        elem = {}, -- storage for each attribute
        mods = {} -- storage for attribute modifiers
    }, mt_modifiers )
    
    class.abilities[ values.id ] = class.abilities[ key ]
    if name then class.abilities[ name ] = class.abilities[ key ] end
    
    for i = 1, select( "#", ... ) do
        class.abilities[ select( i, ... ) ] = class.abilities[ key ]
    end

    storeAbilityElements( key, values )
    
    if not values.item or not values.recheck_name then
        class.searchAbilities[ key ] = "|T" .. ( values.texture or GetSpellTexture( values.id ) or 'Interface\\ICONS\\Spell_Nature_BloodLust' ) .. ":0|t " .. name
        if values.suffix then class.searchAbilities[ key ] = class.searchAbilities[ key ] .. " " .. values.suffix end
    end

    ns.commitKey( key )    
    
end
ns.addAbility = addAbility


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

        if class.auras[ key ].incapacitate then
            table.insert( class.incapacitates, key )
        end
                
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


local function addPet( key )
    state.pet[ key ] = rawget( state.pet, key ) or {}
    state.pet[ key ].name = key
    state.pet[ key ].expires = 0

    ns.commitKey( key )
end
ns.addPet = addPet


local function addPerk( key, id )

    local name = GetSpellInfo( id )

    if not name then
        ns.Error( "addPerk( " .. key .. " ) - unable to get perk name from id#" .. id .. "." )
        return
    end

    class.perks[ key ] = {
        id = id,
        key = key,
        name = name
    }

    ns.commitKey( key )
end
ns.addPerk = addPerk


local function addTalent( key, id, ... )

    local name = GetSpellInfo( id )

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


local function addResource( resource, power_type )

    class.resources[ resource ] = power_type

    if primary or #class.resources == 1 then class.primaryResource = resource end

    state[ resource ] = rawget( state, resource ) or setmetatable( {
        resource = key,
        forecast = {},
        fcount = 0,
        times = {},
        values = {},
        last_tick = 0
    }, mt_resource )
    state[ resource ].regenerates = not no_regen

    ns.commitKey( resource )

end
ns.addResource = addResource


local function removeResource( resource )

    class.resources[ resource ] = nil
    -- class.regenModel = nil

    if class.primaryResource == resource then class.primaryResource = nil end

end
ns.removeResource = removeResource


local function setRegenModel( db )
    class.regenModel = db
end
ns.setRegenModel = setRegenModel


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
        
    if ability.elem[ 'handler' ] then
        ability.elem[ 'handler' ]()
    end

    state.prev.last = key
    state[ ability.gcdType == 'off' and 'prev_off_gcd' or 'prev_gcd' ].last = key

    table.insert( state.predictions, 1, key )
    table.insert( state[ ability.gcdType == 'off' and 'predictionsOff' or 'predictionsOn' ], 1, key )
    state.predictions[6] = nil
    state.predictionsOn[6] = nil
    state.predictionsOff[6] = nil
    
    if state.time == 0 and not no_start and not ability.passive then
        state.false_start = state.query_time - 0.01

        -- Generate fake weapon swings.
        state.nextMH = state.query_time + 0.01
        state.nextOH = state.swings.oh_speed and state.query_time + ( state.swings.oh_speed / 2 ) or 0

        if state.swings.mh_actual < state.query_time then        
            state.swings.mh_pseudo = state.query_time + 0.01
            if state.swings.oh_speed then state.swings.oh_pseudo = state.query_time + ( state.swings.oh_speed / 2 ) end
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


ns.specializationChanged = function()

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

    ns.callHook( 'specializationChanged' )
    ns.cacheCriteria()

    ns.forceUpdate()
    --[[ for i, v in ipairs( ns.queue ) do
        for j = 1, #v do
            ns.queue[i][j] = nil
        end
        ns.queue[i] = nil
    end ]]

end


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

-- bloodlust is the "umbrella" aura for all burst haste effects.
addAura( 'bloodlust', 2825, 'duration', 40, 'feign', function ()
    local bloodlusts = { 'ancient_hysteria', 'heroism', 'time_warp', 'netherwinds' }
    
    for i = 1, #bloodlusts do
        local aura = bloodlusts[ i ]
        if buff[ aura ].up then
            buff.bloodlust.count = buff[ aura ].count
            buff.bloodlust.expires = buff[ aura ].expires
            buff.bloodlust.applied = buff[ aura ].applied
            buff.bloodlust.caster = buff[ aura ].caster
            return
        end
    end
    
    local name, _, _, count, _, duration, expires = UnitBuff( 'player', class.auras.bloodlust.name )
    
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


addAura( 'casting', -10, 'feign', function()
    if target.casting then
        debuff.casting.count = 1
        debuff.casting.expires = target.cast_end
        debuff.casting.applied = state.now
        debuff.casting.caster = 'target'
        return
    end

    debuff.casting.count = 0
    debuff.casting.expires = 0
    debuff.casting.applied = 0
    debuff.casting.caster = 'unknown'
end )


addAura( 'unknown_buff', -11 )



addAbility( 'global_cooldown',
{
    id = 61304,
    spend = 0,
    cast = 0,
    gcdType = 'spell',
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
    gcdType = 'off',
    cooldown = 180,
    toggle = "cooldowns"
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
    gcdType = 'off',
    cooldown = 120,
    toggle = "cooldowns"
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
    gcdType = 'off',
    cooldown = 120,
    toggle = 'interrupts'
    }, 50613, 80483, 129597, 155145, 25046, 69179 )

modifyAbility( 'arcane_torrent', 'id', function( x )
    if class.file == 'PALADIN' then return 155145
    elseif class.file == 'MONK' then return 129597 end
    return x
end )

addHandler( 'arcane_torrent', function ()
    interrupt()
    
    if class.death_knight then gain( 20, "runic_power" )
    elseif class.hunter then gain( 15, "focus" )
    elseif class.monk then gain( 1, "chi" )
    elseif class.paladin then gain( 1, "holy_power" )
    elseif class.rogue then gain( 15, "energy" )
    elseif class.warrior then gain( 15, "rage" )
    elseif class.hunter then gain( 15, "focus" ) end
end )

ns.registerInterrupt( 'arcane_torrent' )


addAura( "shadowmeld", 58984, "duration", 3600 )

addAbility( "shadowmeld", {
    id = 58984,
    cast = 0,
    gcdType = "off",
    cooldown = 120,
    passive = true,
    known = function () return race.night_elf end,
    usable = function () return boss end, -- Only use in boss combat, dropping aggro is for the birds.
} )

addHandler( "shadowmeld", function ()
    applyBuff( "shadowmeld" )
end )


addAbility( 'call_action_list', {
    id = -1,
    name = 'Call Action List',
    cast = 0,
    gcdType = 'off',
    cooldown = 0,
    passive = true
} )


addAbility( 'run_action_list', {
    id = -2,
    name = 'Run Action List',
    cast = 0,
    gcdType = 'off',
    cooldown = 0,
    passive = true
} )


-- Special Instructions
addAbility( 'wait', {
    id = -3,
    name = 'Wait',
    cast = 0,
    gcdType = 'off',
    cooldown = 0,
    passive = true,
} )


addAbility( 'pool_resource', {
    id = -4,
    name = 'Pool Resource',
    cast = 0,
    gcdType = 'off',
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
    name = 'Potion',
    spend = 0,
    cast = 0,
    gcdType = 'off',
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
    name = "Use Items",
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcdType = 'off',
    toggle = 'cooldowns',
} )


addAbility( "draught_of_souls", {
    id = -101,
    item = 140808,
    spend = 0,
    cast = 0,
    cooldown = 80,
    gcdType = 'off',
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
    gcdType = 'off',
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
    gcdType = 'off',
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
    gcdType = 'off',
} )


addUsableItem( "horn_of_valor", 133642 )

addAbility( "horn_of_valor", {
    id = -105,
    item = 133642,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcdType = 'off',
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
    gcdType = 'off',
    toggle = 'cooldowns',
} )


addAbility( "might_of_krosus", {
    id = -107,
    item = 140799,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcdType = 'off',
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
    gcdType = 'off',
} )

addAura( 'temptation', 234143, 'duration', 30, 'max_stack', 20 )

addHandler( "ring_of_collapsing_futures", function ()
    applyDebuff( "player", "temptation", 30, buff.temptation.stack + 1 )
end )


addUsableItem( "specter_of_betrayal", 151190 )

addAbility( "specter_of_betrayal", {
    id = -109,
    item = 151190,
    spend = 0,
    cast = 0,
    cooldown = 45,
    gcdType = 'off',
} )


addUsableItem( "tiny_oozeling_in_a_jar", 137439 )

addAbility( "tiny_oozeling_in_a_jar", {
    id = -110,
    item = 137439,
    spend = 0,
    cast = 0,
    cooldown = 20,
    gcdType = "off",
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
    gcdType = 'off',
    toggle = 'cooldowns',
} )


addUsableItem( "unbridled_fury", 139327 )

addAbility( "unbridled_fury", {
    id = -112,
    item = 139327,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcdType = 'off',
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
    gcdType = 'off',
    toggle = 'cooldowns',
} )

addAura( "ceaseless_toxin", 242497, "duration", 20 )

addHandler( "vial_of_ceaseless_toxins", function ()
    applyDebuff( "target", "ceaseless_toxin", 20 )
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
    name = 'Store Value',
    spend = 0,
    cast = 0,
    gcdType = 'off',
    cooldown = 0,
} )
    
    
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
    
    
-- DEFAULTS

class.retiredDefaults = {}

function ns.retireDefaults( ... )
    local defaults = select( "#", ... )

    for i = 1, defaults do
        table.insert( class.retiredDefaults, select( i, ... ), true )
    end
end


    
ns.storeDefault = function( name, category, version, import )

    if not ( name and category and version and import ) then
        return
    end

    class.defaults[ #class.defaults + 1 ] = {
        name = name,
        type = category,
        version = version,
        import = import:gsub("([^|])|([^|])", "%1||%2")
    }

end


ns.restoreDefaults = function( category, purge )

    local profile = Hekili.DB.profile

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
                display.Enabled = false
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
                -- list.Enabled = false
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
                            local existing = profile.displays[index]
                            import.Enabled = existing.Enabled
                            import.spellFlash = existing.spellFlash
                            import.spellFlashColor = existing.spellFlashColor
                            
                            -- import['PvE Visibility'] = existing['PvE Visibility']
                            import.alwaysPvE = existing.alwaysPvE
                            import.alphaAlwaysPvE = existing.alphaAlwaysPvE
                            import.targetPvE = existing.targetPvE
                            import.alphaTargetPvE = existing.alphaTargetPvE
                            import.combatPvE = existing.combatPvE
                            import.alphaCombatPvE = existing.alphaCombatPvE
                            -- import['PvE Visibility'] = existing['PvE Visibility']
                            import.alwaysPvP = existing.alwaysPvP
                            import.alphaAlwaysPvP = existing.alphaAlwaysPvP
                            import.targetPvP = existing.targetPvP
                            import.alphaTargetPvP = existing.alphaTargetPvP
                            import.combatPvP = existing.combatPvP
                            import.alphaCombatPvP = existing.alphaCombatPvP
                            --[[ Mode Overrides - cancel, go ahead and overwrite them
                            import.minAuto = existing.minAuto
                            import.maxAuto = existing.maxAuto
                            import.minST = existing.minST
                            import.maxST = existing.maxST
                            import.minAE = existing.minAE
                            import.maxAE = existing.maxAE ]]
                            
                            import.x = existing.x
                            import.y = existing.y
                            import.rel = existing.rel
                            
                            import.numIcons = existing.numIcons
                            import.iconSpacing = existing.iconSpacing
                            import.queueDirection = existing.queueDirection
                            import.queueAlignment = existing.queueAlignment
                            import.primaryIconSize = existing.primaryIconSize
                            import.queuedIconSize = existing.queuedIconSize
                            
                            import.font = existing.font
                            import.primaryFontSize = existing.primaryFontSize
                            import.queuedFontSize = existing.queuedFontSize
                            import.rangeType = existing.rangeType
                            
                            import.showCaptions = existing.showCaptions
                        else
                            index = #profile.displays + 1
                        end
                        
                        if type( import.precombatAPL ) == 'string' then
                            for i, list in pairs( profile.actionLists ) do
                                if list.Name == import.precombatAPL then
                                    import.precombatAPL = i
                                end
                            end

                            if type( import.precombatAPL ) == 'string' then
                                import.precombatAPL = 0
                            end
                        end

                        if type( import.defaultAPL ) == 'string' then
                            for i, list in pairs( profile.actionLists ) do
                                if list.Name == import.defaultAPL then
                                    import.defaultAPL = i
                                end
                            end

                            if type( import.defaultAPL ) == 'string' then
                                import.defaultAPL = 0
                            end
                        end

                        profile.displays[ index ] = import
                        
                    else
                        ns.Error( "restoreDefaults() - unable to import '" .. default.name .. "' display." )
                    end
                end
            end
        end
    end
    
    ns.refreshOptions()
    ns.loadScripts()
    
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
ns.storeDefault( [[Usable Items]], 'actionLists', 20171128.001745, [[dqeFmaqijvTjPKpjrrJssXPKu6wiLi7ssgMQ4yeYYuOEgHcMgsjvxdPeABiLO(grLXHus5CekY8Ku5EsL9jr1bjQAHiv9qcLAIiLsxuHyJsuAKekQtsOALsHxsOq3uIc7uv6NekPLkrEQktvcUkHsSvKsXxrkj2lP)kvnyrhg0IvWJryYe5YqBwk1Njy0kKonQvJuQ8AKsvZwr3gy3k9Bv1WrkwoIEUW0P66iz7eLVJucgVe68ivwpsjP5lfTFkRI0c69cbOEILaomrlf3rqO3rdsWWjtRcD(V67JEIzwscxLE9kHtegO(o(rKCIenwmu9iMgpE8y9ocsMgxp9KNW5)gAb9vKwqVrw4WeLu617fcq9OTKqkHrDl)TT8(uZqVJGKPX1REld0DEfIkjoGdtuYYwwAnGeold7XfbmgwwENLb6oVcrfGxgqbSSLLwJASmq35viQaWImGcyzxNLpw2SPLqcNLH94IagdlRRZYaDNxHOcalYakGL1QxjCIWa13XpIKt0JELW4trsGHwqD9KFGNStNEsKqkHr9(F7(4tnd9eFLycO)j1B)lQU(owlO3ilCyIsk96DeKmnUE1BzGUZRqujXbCyIsw2YsRbKWzzypUiGXWYY7Smq35viQa8YakGLTS0AuJLb6oVcrfawKbual76S8XYMnTes4SmShxeWyyzDDwgO78kevayrgqbSSw9EHauVYcPMoDwk2FQ1rsacdksup5h4j70PxBi10PRN4tToscqyqrI6j(kXeq)tQ3(xuVs4eHbQVJFejNOh9kHXNIKadTG6QRVIbTGEJSWHjkP0R3rqY046vVLb6oVcrLehWHjkzzllTgqcNLH94IagdllVZYaDNxHOcWldOaw2YsRrnwgO78kevayrgqbSSRZYhlB20siHZYWECraJHL11zzGUZRqubGfzafWYA1RegFkscm0cQRN8d8KD60Rno)8eL65TnsUWzpasmkVOEIVsmb0)K6T)f1ReoryG674hrYj6rVxia1RS4KwsSYtuYsX32i5cNwwgqIr5fvxFP11c6nYchMOKsVEVqaQxz)KcyBgxPYmSSSWbsMa6Fs9ocsMgxV6Tmq35viQK4aomrjlBzP1as4SmShxeWyyz5DwgO78kevaEzafWYwwAnQXYaDNxHOcalYakGLDDw(yzZMwcjCwg2JlcymSSUold0DEfIkaSidOawwREYpWt2PtV2FsbSnJRu03goqYeq)tQN4Reta9pPE7Fr9kHtegO(o(rKCIE0RegFkscm0cQRU(slQf0BKfomrjLE9ocsMgxV6Tmq35viQK4aomrjlBzP1as4SmShxeWyyz5DwgO78kevaEzafWYwwAnQXYaDNxHOcalYakGLDDw(yzZMwcjCwg2JlcymSSUold0DEfIkaSidOawwRELW4trsGHwqD9KFGNStNEJ(j3(F7EzW5NupXxjMa6Fs92)I6vcNimq9D8Ji5e9O3leG6jM)KRL)2wsBGZpP66lTSwqVrw4WeLu617iizAC9Q3YaDNxHOsId4WeLSSLLwdiHZYWECraJHLL3zzGUZRqub4LbualBzP1Ogld0DEfIkaSidOaw21z5JLnBAjKWzzypUiGXWY66Smq35viQaWImGcyzT69cbOEIrEwM0oikHBzgwspf5YRGL0kCmQEYpWt2PtpAppPDquc3OFGIC5vONwGJr1t8vIjG(NuV9VOELWjcduFh)isorp6vcJpfjbgAb1vxFLtlO3ilCyIsk969cbOELblmQB5VTLIrYFqf6DeKmnUE1BzGUZRqujXbCyIsw2YsRbKWzzypUiGXWYY7Smq35viQa8YakGLTS0AuJLb6oVcrfawKbual76S8XYMnTes4SmShxeWyyzDDwgO78kevayrgqbSSw9KFGNStNEawyuV)3UN2t(dQqpXxjMa6Fs92)I6vcNimq9D8Ji5e9Oxjm(uKeyOfuxD9LwtlO3ilCyIsk96DeKmnUE1BzGUZRqujXbCyIsw2YsRbKWzzypUiGXWYY7Smq35viQa8YakGLTS0AuJLb6oVcrfawKbual76S8XYMnTes4SmShxeWyyzDDwgO78kevayrgqbSSw9kHXNIKadTG66j)apzNo9i5vO)3UN4pNqAcEf6Bt5uKyON4Reta9pPE7Fr9kHtegO(o(rKCIE07fcq9kXRGL)2wk2)5estWRGLLLYPiXqD9vmPf0BKfomrjLE9ocsMgxV6Tmq35viQK4aomrjlBzP1as4SmShxeWyyz5DwgO78kevaEzafWYwwAnQXYaDNxHOcalYakGLDDw(yzZMwcjCwg2JlcymSSUold0DEfIkaSidOawwREVqaQ3rds4iPL)2wsp6Kq6Gt9KFGNStNEbniHJK9)29dOtcPdo1t8vIjG(NuV9VOELWjcduFh)isorp6vcJpfjbgAb1vxFf9Of0BKfomrjLE9ocsMgxV6Tmq35viQK4aomrjlBzP1as4SmShxeWyyz5DwgO78kevaEzafWYwwAnQXYaDNxHOcalYakGLDDw(yzZMwcjCwg2JlcymSSUold0DEfIkaSidOawwREVqaQNybmqcNwwg))kmHSmm0t(bEYoD6rbgiHZEW)Vctildd9eFLycO)j1B)lQxjCIWa13XpIKt0JELW4trsGHwqD11xrI0c6nYchMOKsVEhbjtJRx9wgO78kevsCahMOKLTS0AajCwg2JlcymSS8old0DEfIkaVmGcyzllTg1yzGUZRqubGfzafWYUolFSSztlHeold7XfbmgwwxNLb6oVcrfawKbualRvVxia1J2WWPL)2wk2imWjgHLf(f5n0t(bEYoD6jJHZ(F7Eceg4eJO3)f5n0t8vIjG(NuV9VOELWjcduFh)isorp6vcJpfjbgAb1vxD9OTyBi10v6vxva]] )


-- Was for module support; disabled.
function Hekili.RetrieveFromNamespace( key )
    return nil
end


function Hekili.StoreInNamespace( key, value )
    -- ns[ key ] = value
end
