-- Hekili.lua
-- April 2014

local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )
Hekili.Version = GetAddOnMetadata("Hekili", "Version")

if Hekili.Version == ( "@" .. "project-version" .. "@" ) then Hekili.Version = "Development-" .. date("%Y%m%d" ) end

Hekili.AllowSimCImports = true

local format = string.format
local upper  = string.upper


ns.PTR = GetBuildInfo() == "8.2.5"


ns.Patrons = {
    -- Expecto
	"Akh270",
	"Brugrabud",
	"Elmner",
	"Rusah",
	"Spaten",
	"Spy",
	"SuperRsk",

    -- Supreme
	"Annddyypandy",
	"Ash",
	"av8ordoc",
	"Belatar",
	"Borelia",
	"Bsirk",
	"cortland",
	"DarkosKiLLz",
	"Dele",
	"Dez",
	"Garumako",
	"Goobkill",
	"GSMarketing",
	"Harkun",
	"Hollaputt",
	"Kyatastrophe",
	"Manni",
	"marcusawereally",
	"Meeat",
	"mojodisu.",
	"ODB/Tilt",
	"PJ",
	"Ramen",
	"Rivertam",
	"skrrskrr",
	"Stalorirn",
	"Torsti",
	"unlaern",
	"zvda",
	"Zyon",

	-- Patron
	"Abra",
	"Aern",
	"Alarius",
	"Alvi",
	"ApexPlatypus",
	"cafasdon",
	"chckxy",
	"djthomp",
	"doboro",
	"Electricfury (Vagos)",
	"Fastobreiko",
	"Grayscale",
	"Guycrush Fleetwood",
	"Hexel",
	"Ingrathis",
	"jawj",
	"Kretol",
	"Leorus",
	"Loraniden",
	"MrBean73",
	"muze",
	"neurolol",
	"Opie",
	"Sarthol",
	"Sebstar",
	"Seniroth",
	"Sym",
	"Ted",
	"Tekfire",
	"Tic",
	"Tohr",
	"twiggs",
	"Twiss",
	"Wargus (Just 'Gus)",
	"Weedwalker",
	"Yeitzo",
	"zeus",
}
table.sort( ns.Patrons, function( a, b ) return upper( a ) < upper( b ) end  )



do
    local cpuProfileDB = {}

    function Hekili:ProfileCPU( name, func )
        cpuProfileDB[ name ] = func
    end

    ns.cpuProfile = cpuProfileDB
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
	toggles = {}
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

    self:Debug( "\nNew Recommendations for [ %s ] requested at %s ( %.2f ).", display, date( "%H:%M:%S"), GetTime() )

end

function Hekili:Debug( ... )

    if not self.ActiveDebug then return end
    if not active_debug then return end

    active_debug.log[ active_debug.index ] = format( ... )
    active_debug.index = active_debug.index + 1

end


local snapshots = ns.snapshots

function Hekili:SaveDebugSnapshot()

    for k, v in pairs( debug ) do

        if not snapshots[ k ] then
            snapshots[ k ] = {}
        end

        for i = #v.log, v.index, -1 do
            v.log[ i ] = nil
        end

        table.insert( v.log, 1, self:GenerateProfile() )
        table.insert( snapshots[ k ], table.concat( v.log, "\n" ) )

    end

end

Hekili.Snapshots = ns.snapshots



ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )
