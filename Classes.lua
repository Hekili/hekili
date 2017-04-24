-- Classes.lua
-- July 2014


local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local getResourceID = ns.getResourceID
local getSpecializationKey = ns.getSpecializationKey


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

    if Hekili.DB.profile['Toggle State: '..name] == nil then
        Hekili.DB.profile['Toggle State: '..name] = default
    end

end


ns.addSetting = function( name, default, options )

    table.insert( class.settings, {
        name = name,
        state = default,
        option = options
    } )

    if Hekili.DB.profile['Class Option: '..name] == nil then
        Hekili.DB.profile['Class Option: '..name] = default
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
            if Hekili.DB.profile['Toggle '..j..' Name'] == toggle.name then
                Hekili.DB.profile['Toggle '..j..' Name'] = nil
            end
        end
        if Hekili.DB.profile['Toggle Bind: ' .. toggle.name] then
            SetOverrideBindingClick( Hekili_Keyhandler, true, Hekili.DB.profile['Toggle Bind: '..toggle.name], "Hekili_Keyhandler", toggle.name )
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
    
    local name = GetSpellInfo( values.id )
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
    
    ns.commitKey( key )
    
    storeAbilityElements( key, values )
    
    class.searchAbilities[ key ] = '|T' .. ( GetSpellTexture( values.id ) or 'Interface\\ICONS\\Spell_Nature_BloodLust' ) .. ':O|t ' .. class.abilities[ key ].name
    
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


local function addResource( resource, primary )

    class.resources[ resource ] = true

    if primary or #class.resources == 1 then class.primaryResource = resource end

    ns.commitKey( resource )

end
ns.addResource = addResource


local function removeResource( resource )

    class.resources[ resource ] = nil
    if class.primaryResource == resource then class.primaryResource = nil end

end
ns.removeResource = removeResource


local function addGearSet( name, ... )

    class.gearsets[ name ] = class.gearsets[ name ] or {}

    for i = 1, select( '#', ... ) do
        class.gearsets[ name ][ select( i, ... ) ] = ns.formatKey( GetItemInfo( select( i, ... ) ) or "nothing" )
    end

    ns.commitKey( name )

end
ns.addGearSet = addGearSet


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

    ns.updateTalents()
    ns.updateGear()

    ns.callHook( 'specializationChanged' )
    ns.cacheCriteria()

    for i, v in ipairs( ns.queue ) do
        for j = 1, #v do
            ns.queue[i][j] = nil
        end
        ns.queue[i] = nil
    end

end



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

addAura( 'xavarics_magnum_opus', 207428, 'duration', 30 )

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
    toggle = 'cooldowns'
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


addAbility( 'call_action_list', {
    id = -1,
    name = 'Call Action List',
    spend = 0,
    cast = 0,
    gcdType = 'off',
    cooldown = 0,
    passive = true
} )


addAbility( 'run_action_list', {
    id = -2,
    name = 'Run Action List',
    spend = 0,
    cast = 0,
    gcdType = 'off',
    cooldown = 0,
    passive = true
} )


-- Special Instructions
addAbility( 'wait', {
    id = -3,
    name = 'Wait',
    spend = 0,
    cast = 0,
    gcdType = 'off',
    cooldown = 0,
    passive = true,
} )


-- Universal Gear Stuff
addGearSet( 'rethus_incessant_courage', 146667 )
addAura( 'rethus_incessant_courage', 241330 )

addGearSet( 'vigilance_perch', 146668 )
addAura( 'vigilance_perch', 241332, 'duration', 60, 'max_stack', 5 )

addGearSet( 'the_sentinels_eternal_refuge', 146669 )
addAura( 'the_sentinels_eternal_refuge', 241331, 'duration', 60, 'max_stack', 5 )


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



--[[ 
addAbility( 'use_item', {
    id = -3,
    name = 'Use Item',
    spend = 0,
    cast = 0,
    gcdType = 'off',
    cooldown = 60,
    toggle = 'cooldowns'
} )

class.items = {
} ]]


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
        [124225] = { -- Soul Capacitor
        duration = 10,
        },
        [114429] = {
        stat = 'mastery',
        duration = 10,
        },
        [109998] = {
        stat = 'multistrike',
        duration = 15,
        cooldown = 90,
        },
        [114430] = {
        stat = 'haste',
        duration = 10,
        },
        [110007] = {
        stat = 'critical_strike',
        duration = 20,
        cooldown = 120,
        },
        [109999] = {
        stat = 'haste',
        duration = 10,
        },
        [110008] = {
        stat = 'mastery',
        duration = 15,
        cooldown = 90,
        },
        [110009] = {
        stat = 'versatility',
        duration = 10,
        },
        [114427] = {
        stat = 'critical_strike',
        duration = 10,
        },
        [110012] = {
        stat = 'critical_strike',
        duration = 20,
        cooldown = 120,
        },
        [110013] = {
        stat = 'versatility',
        duration = 15,
        cooldown = 90,
        },
        [110002] = {
        stat = 'haste',
        duration = 20,
        cooldown = 120,
        },
        [110014] = {
        stat = 'haste',
        duration = 10,
        },
        [114428] = {
        stat = 'versatility',
        duration = 10,
        },
        [110003] = {
        stat = 'versatility',
        duration = 15,
        cooldown = 90
        },
        [109997] = {
        stat = 'mastery',
        duration = 20,
        cooldown = 120,
        },
        [110017] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [110004] = {
        stat = 'multistrike',
        duration = 10,
        },
        [110018] = {
        stat = 'mastery',
        duration = 15,
        cooldown = 90
        },
        [110019] = {
        stat = 'mastery',
        duration = 10,
        },
        [114431] = {
        stat = 'versatility',
        duration = 10,
        },
        [119937] = {
        stat = 'strength',
        duration = 20,
        },
        [120049] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [109262] = {
        stat = 'primary',
        duration = 15,
        },
        [115149] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [115150] = {
        stat = 'agility',
        duration = 20,
        },
        [115151] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115152] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115153] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115154] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [115155] = {
        stat = 'intellect',
        duration = 20,
        },
        [115159] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [115160] = {
        stat = 'strength',
        duration = 20
        },
        [115521] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [119926] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [119927] = {
        stat = 'agility',
        duration = 20,
        },
        [119928] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [119929] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [119930] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [119934] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [119932] = {
        stat = 'intellect',
        duration = 20,
        },
        [119936] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [110018] = {
        stat = 'mastery',
        duration = 15,
        cooldown = 90,
        },
        [110019] = {
        stat = 'mastery',
        duration = 10,
        },
        [110014] = {
        stat = 'haste',
        duration = 10,
        },
        [110013] = {
        stat = 'versatility',
        duration = 15,
        cooldown = 90,
        },
        [110012] = {
        stat = 'critical_strike',
        duration = 20,
        cooldown = 120,
        },
        [110009] = {
        stat = 'versatility',
        duration = 10,
        },
        [110008] = {
        stat = 'mastery',
        duration = 15,
        cooldown = 90,
        },
        [110007] = {
        stat = 'critical_strike',
        duration = 20,
        cooldown = 120,
        },
        [114488] = {
        stat = 'mastery',
        duration = 15,
        cooldown = 90,
        },
        [114489] = {
        stat = 'haste',
        duration = 20,
        cooldown = 120,
        },
        [114490] = {
        stat = 'mastery',
        duration = 15,
        cooldown = 90,
        },
        [114491] = {
        stat = 'multistrike',
        duration = 20,
        cooldown = 120,
        },
        [114492] = {
        stat = 'haste',
        duration = 15,
        cooldown = 90,
        },
        [117357] = {
        stat = 'bonus_armor',
        duration = 20,
        cooldown = 120,
        },
        [117360] = {
        stat = 'critical_strike',
        duration = 10,
        },
        [117359] = {
        stat = 'haste',
        duration = 10,
        cooldown = 55,
        internal = true,
        },
        [117358] = {
        stat = 'critical_strike',
        duration = 10,
        cooldown = 55,
        internal = true,
        },
        [122601] = {
        stat = 'primary',
        duration = 15,
        },
        [116292] = {
        stat = 'versatility',
        duration = 10,
        },
        [116291] = {
        stat = 'critical_strike',
        duration = 10,
        },
        [112317] = {
        stat = 'spirit',
        duration = 20,
        cooldown = 115,
        internal = true,
        },
        [112318] = {
        stat = 'critical_strike',
        duration = 20,
        cooldown = 115,
        internal = true,
        },
        [112319] = {
        stat = 'critical_strike',
        duration = 20,
        cooldown = 115,
        internal = true,
        },
        [112320] = {
        stat = 'critical_strike',
        duration = 20,
        cooldown = 115,
        internal = true,
        },
        [114613] = {
        stat = 'multistrike',
        duration = 10,
        },
        [113645] = {
        stat = 'critical_strike',
        duration = 10,
        },
        [113612] = {
        stat = 'multistrike',
        duration = 10,
        },
        [113861] = {
        stat = 'armor',
        duration = 10,
        },
        [113842] = {
        stat = 'haste',
        duration = 20,
        cooldown = 120,
        },
        [113835] = {
        stat = 'haste',
        duration = 20,
        cooldown = 120,
        },
        [113834] = {
        stat = 'mastery',
        duration = 20,
        cooldown = 120,
        },
        [113663] = {
        stat = 'mastery',
        duration = 10,
        },
        [114610] = {
        stat = 'mastery',
        duration = 10,
        },
        [122602] = {
        stat = 'primary',
        duration = 15,
        },
        [116318] = {
        stat = 'critical_strike',
        duration = 10,
        },
        [114611] = {
        stat = 'mastery',
        duration = 10,
        },
        [114612] = {
        stat = 'haste',
        duration = 10,
        },
        [116315] = {
        stat = 'haste',
        duration = 10,
        },
        [116314] = {
        stat = 'multistrike',
        duration = 10,
        },
        [114614] = {
        stat = 'haste',
        duration = 10,
        },
        [115752] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115751] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [111222] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [111228] = {
        stat = 'intellect',
        duration = 20,
        },
        [115760] = {
        stat = 'strength',
        duration = 20,
        },
        [122754] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [111223] = {
        stat = 'agility',
        duration = 20,
        },
        [115496] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [111224] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115753] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115495] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [115755] = {
        stat = 'intellect',
        duration = 20,
        },
        [111233] = {
        stat = 'strength',
        duration = 20,
        },
        [111225] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115749] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [111232] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [111226] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [115750] = {
        stat = 'agility',
        duration = 20,
        },
        [115759] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [111227] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [118884] = {
        stat = 'max_health',
        duration = 20,
        cooldown = 120,
        },
        [118882] = {
        stat = 'strength',
        duration = 15,
        cooldown = 90
        },
        [118880] = {
        stat = 'mana',
        cooldown = 120,
        },
        [118878] = {
        stat = 'spell_power',
        duration = 20,
        cooldown = 120,
        },
        [118876] = {
        stat = 'agility',
        duration = 20,
        cooldown = 120,
        },
        [113842] = {
        stat = 'haste',
        duration = 20,
        cooldown = 120,
        },
        [113987] = {
        stacking_stat = 'haste',
        inverse = true,
        duration = 10,
        },
        [122603] = {
        stat = 'primary',
        duration = 15,
        },
        [113986] = {
        stacking_stat = 'haste',
        inverse = true,
        duration = 10,
        },
        [113985] = {
        stacking_stat = 'critical_strike',
        inverse = true,
        duration = 10,
        },
        [113984] = {
        stacking_stat = 'multistrike',
        inverse = true,
        duration = 10,
        },
        [118114] = {
        stat = 'haste',
        duration = 10,
        },
        [113983] = {
        stacking_stat = 'multistrike',
        inverse = true,
        duration = 10,
        },
        [113969] = {
        stat = 'multistrike',
        duration = 20,
        cooldown = 120,
        },
        [113948] = {
        stat = 'haste',
        duration = 10,
        },
        [113931] = {
        stat = 'multistrike',
        duration = 20,
        cooldown = 120,
        },
        [113905] = {
        stat = 'bonus_armor',
        duration = 20,
        cooldown = 120,
        },
        [113893] = {
        stat = 'mastery',
        duration = 10,
        },
        [113889] = {
        stat = 'multistrike',
        duration = 10,
        },
        [119192] = {
        stat = 'spirit',
        duration = 10,
        },
        [119193] = {
        stat = 'mastery',
        duration = 10,
        },
        [119194] = {
        stat = 'critical_strike',
        duration = 10,
        },
        [125508] = {
        stat = 'agility',
        duration = 20,
        },
        [126634] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [126633] = { 
        stat = 'strength',
        duration = 20,
        },
        [126632] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [126627] = {
        stat = 'intellect',
        duration = 20,
        },
        [126626] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [126625] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [126624] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [126623] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [126622] = {
        stat = 'agility',
        duration = 20,
        },
        [126621] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [126157] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [126156] = {
        stat = 'strength',
        duration = 20,
        },
        [126155] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [126150] = {
        stat = 'intellect',
        duration = 20,
        },
        [126149] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [126148] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [126147] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [126146] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [126145] = {
        stat = 'agility',
        duration = 20,
        },
        [126144] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125520] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125519] = {
        stat = 'strength',
        duration = 20,
        },
        [125518] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125513] = {
        stat = 'intellect',
        duration = 20,
        },
        [125512] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125511] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [125510] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [125509] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [125507] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125030] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125031] = {
        stat = 'agility',
        duration = 20,
        },
        [125032] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [125033] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [125034] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120,
        },
        [125035] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125036] = {
        stat = 'intellect',
        duration = 20,
        },
        [125041] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [125042] = {
        stat = 'strength',
        duration = 20,
        },
        [125043] = {
        stat = 'versatility',
        duration = 20,
        cooldown = 120,
        },
        [124228] = {
        stat = 'intellect',
        duration = 20,
        },
        [124226] = {
        stat = 'agility',
        duration = 20,
        },
        [124241] = {
        stat = 'mastery',
        duration = 10,
        },
        [124236] = {
        stacking_stat = 'strength',
        inverse = true,
        duration = 20,
            -- need a stack counter function, based on # of attacks.
            },
            [124232] = {
            stat = 'critical_strike',
            duration = 15,
            cooldown = 90,
            },
            [126460] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [126459] = {
            stat = 'strength',
            duration = 20,
            },
            [126458] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [124856] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [124857] = {
            stat = 'agility',
            duration = 20,
            },
            [124858] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [124859] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [124860] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [124861] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [124862] = {
            stat = 'intellect',
            duration = 20,
            },
            [124867] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [124868] = {
            stat = 'strength',
            duration = 20,
            },
            [124869] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [125335] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [125336] = {
            stat = 'agility',
            duration = 20,
            },
            [125337] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [125338] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [125339] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [125340] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [125341] = {
            stat = 'intellect',
            duration = 20,
            },
            [125344] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [125345] = {
            stat = 'strength',
            duration = 20,
            },
            [125346] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [126455] = {
            stat = 'intellect',
            duration = 20,
            },
            [125970] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [125971] = {
            stat = 'agility',
            duration = 20,
            },
            [125972] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [125973] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [125974] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [125975] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [125976] = {
            stat = 'intellect',
            duration = 20,
            },
            [125981] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [125982] = {
            stat = 'strength',
            duration = 20,
            },
            [125983] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [126449] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },
            [126450] = {
            stat = 'agility',
            duration = 20,
            },
            [126451] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [126452] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [126453] = {
            stat = 'max_health',
            duration = 15,
            cooldown = 120,
            },
            [126454] = {
            stat = 'versatility',
            duration = 20,
            cooldown = 120,
            },

        --heirlooms
        [122530] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120
        },
        [93900] = {
        stat = 'max_health',
        duration = 15,
        cooldown = 120
    }
}


setmetatable( class.trinkets, {
    __index = function( t, k )
    return t[0]
end
} )


for k, v in pairs( class.trinkets ) do
    local item = k
    local buffs = ns.lib.LibItemBuffs:GetItemBuffs( k )

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



function Hekili.RetrieveFromNamespace( key )
    return nil
end


function Hekili.StoreInNamespace( key, value )
    -- ns[ key ] = value
end
