-- Hekili.lua
-- April 2014

local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )
Hekili.Version = GetAddOnMetadata("Hekili", "Version")

if Hekili.Version == ( "@" .. "project-version" .. "@" ) then Hekili.Version = "Development-" .. date("%Y%m%d" ) end

Hekili.AllowSimCImports = true

local format = string.format
local upper  = string.upper


ns.PTR = select( 4, GetBuildInfo() ) > 90005


ns.Patrons = "Abom, Abuna, aerix88, Aern, Aggronaught, Akh270, Alarius, Alasha, alcaras, Amera, Annddyypandy, ApexPlatypus, aphoenix, Archxlock, Aristocles, Arkhon, aro, Artoo, Ash, Aunt Jeremimah, av8ordoc, Belatar, Borelia, Brangeddon, Bsirk, cafasdon, Cele, Chimmi, Coan, Cortland, CptTroll, Cruz, Dane, DarkSparrow, Daz, DB, Dele, DerGuteFee, Dez, Dilvish, djthomp, Drethii, Elmer, Evo, Excitedguy, Feral, fuon, Garumako, glue, Graemec, Grayscale, Grechka, Guycrush Fleetwood, Himea, Hollaputt, Hungrypilot, HXL, Jacii, jawj, Katurn, KayGee, Kingreboot, Kittykiller, Lava Guava, Leorus, Loraniden, LordofWar, Lovien, Lump, Manni, MARU, mr. jing0, Mr_Hunter, MrBean, mrminus, MrSmurfy, Muerr, Mumrikk, muze, Nelix, neurolol, Nighteyez, Nikö, Nissa/Laethri, Nok, nomiss, nqrse, ODB/Tilt, Parameshvar, Rage, Rebdull, RIP, Rivertam, Roodie, Rusah, Samuraiwillz501, sarrge, Sarthol, Sebstar, Seniroth, seriallos, Shakeykev, Shuck, Skeletor, Slem, Smalls, Smiling6Bob9, Spaten, Spy, Srata, Stevi, Stonebone, Ted, Tekfire, Thordros, Tic, Tobi, todd, Torsti, Trikki, Tropical, tsukari, Ulti, Val (Nálá/Bóomah), Vaxum, Wargus (Just 'Gus), Weedwalker, Wonder, Xing, Ytsejam, zab, Zarggg, Zyon"



do
    local cpuProfileDB = {}

    function Hekili:ProfileCPU( name, func )
        cpuProfileDB[ name ] = func
    end

	ns.cpuProfile = cpuProfileDB
	

	local frameProfileDB = {}

	function Hekili:ProfileFrame( name, f )
		frameProfileDB[ name ] = f
	end

	ns.frameProfile = frameProfileDB
end


ns.lib = {
    Format = {}
}


-- 04072017:  Let's go ahead and cache aura information to reduce overhead.
ns.auras = {
    target = {
        buff = {},
        debuff = {}
    },
    player = {
        buff = {},
        debuff = {}
    }
}

Hekili.Class = {
    specs = {},
    num = 0,

    file = "NONE",

	resources = {},
	resourceAuras = {},
    talents = {},
    pvptalents = {},
	auras = {},
	auraList = {},
    powers = {},
	gear = {},
	
	knownAuraAttributes = {},

    stateExprs = {},
    stateFuncs = {},
    stateTables = {},

	abilities = {},
	abilityByName = {},
    abilityList = {},
    itemList = {},
    itemMap = {},
    itemPack = {
        lists = {
            items = {}
        }
    },

    packs = {},

    pets = {},
    totems = {},

    potions = {},
    potionList = {},

	hooks = {},
    range = 8,
	settings = {},
    stances = {},
	toggles = {},
	variables = {},
}

Hekili.Scripts = {
    DB = {},
    Channels = {},
    PackInfo = {},
}

Hekili.State = {}

ns.hotkeys = {}
ns.keys = {}
ns.queue = {}
ns.targets = {}
ns.TTD = {}

ns.UI = {
    Displays = {},
    Buttons = {}
}

ns.debug = {}
ns.snapshots = {}


function Hekili:Query( ... )

	local output = ns

	for i = 1, select( '#', ... ) do
		output = output[ select( i, ... ) ]
    end

    return output
end


function Hekili:Run( ... )

	local n = select( "#", ... )
	local fn = select( n, ... )

	local func = ns

	for i = 1, fn - 1 do
		func = func[ select( i, ... ) ]
    end

    return func( select( fn, ... ) )

end


local debug = ns.debug
local active_debug
local current_display

local lastIndent = 0

function Hekili:SetupDebug( display )
    if not self.ActiveDebug then return end
    if not display then return end

    current_display = display

    debug[ current_display ] = debug[ current_display ] or {
        log = {},
        index = 1
    }
    active_debug = debug[ current_display ]
	active_debug.index = 1
	
	lastIndent = 0
	
	local pack = self.State.system.packName

	self:Debug( "New Recommendations for [ %s ] requested at %s ( %.2f ); using %s( %s ) priority.", display, date( "%H:%M:%S"), GetTime(), self.DB.profile.packs[ pack ].builtIn and "built-in " or "", pack )
end


function Hekili:Debug( ... )
    if not self.ActiveDebug then return end
	if not active_debug then return end
	
	local indent, text = ...
	local start

	if type( indent ) ~= "number" then
		indent = lastIndent
		text = ...
		start = 2
	else
		lastIndent = indent
		start = 3
	end

	local prepend = format( indent > 0 and ( "%" .. ( indent * 4 ) .. "s" ) or "%s", "" )
	text = text:gsub("\n", "\n" .. prepend )

	active_debug.log[ active_debug.index ] = format( "%" .. ( indent > 0 and ( 4 * indent ) or "" ) .. "s" .. text, "", select( start, ... ) )
    active_debug.index = active_debug.index + 1
end


local snapshots = ns.snapshots

function Hekili:SaveDebugSnapshot( dispName )

    local snapped = false

	for k, v in pairs( debug ) do
		
		if dispName == nil or dispName == k then
			if not snapshots[ k ] then
				snapshots[ k ] = {}
			end

			for i = #v.log, v.index, -1 do
				v.log[ i ] = nil
			end

            -- Store aura data.
            local auraString = "\nplayer_buffs:"
            local now = GetTime()

            local class = Hekili.Class

            for i = 1, 40 do
                local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitBuff( "player", i )

                if not name then break end

                auraString = format( "%s\n   %6d - %-40s - %3d - %-.2f", auraString, spellId, class.auras[ spellId ] and class.auras[ spellId ].key or ( "*" .. name ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
            end

            auraString = auraString .. "\n\nplayer_debuffs:"

            for i = 1, 40 do
                local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitDebuff( "player", i )

                if not name then break end

                auraString = format( "%s\n   %6d - %-40s - %3d - %-.2f", auraString, spellId, class.auras[ spellId ] and class.auras[ spellId ].key or ( "*" .. name ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
            end


            if not UnitExists( "target" ) then
                auraString = auraString .. "\n\ntarget_auras:  target does not exist"
            else
                auraString = auraString .. "\n\ntarget_buffs:"
                
                for i = 1, 40 do
                    local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitBuff( "target", i )
    
                    if not name then break end
    
                    auraString = format( "%s\n   %6d - %-40s - %3d - %-.2f", auraString, spellId, class.auras[ spellId ] and class.auras[ spellId ].key or ( "*" .. name ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
                end
    
                auraString = auraString .. "\n\ntarget_debuffs:"

                for i = 1, 40 do
                    local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitDebuff( "target", i, "PLAYER" )
    
                    if not name then break end
    
                    auraString = format( "%s\n   %6d - %-40s - %3d - %-.2f", auraString, spellId, class.auras[ spellId ] and class.auras[ spellId ].key or ( "*" .. name ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
                end
            end

            auraString = auraString .. "\n\n"

            table.insert( v.log, 1, auraString )
            table.insert( v.log, 1, "targets:\n" .. Hekili.TargetDebug )
            table.insert( v.log, 1, self:GenerateProfile() )
            table.insert( snapshots[ k ], table.concat( v.log, "\n" ) )
            
            snapped = true
		end

    end

    return snapped

end

Hekili.Snapshots = ns.snapshots



ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )
