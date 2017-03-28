-- Hekili.lua
-- April 2014

local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )

local format = string.format


ns.PTR = GetBuildInfo() ~= "7.2.0"


ns.lib = {
    AceConfig = LibStub( "AceConfig-3.0" ),
    AceConfigDialog = LibStub( "AceConfigDialog-3.0" ),
    ArtifactData = LibStub( "LibArtifactData-1.0h" ),
    -- LegionArtifacts = LibStub:GetLibrary( "LegionArtifacts-1.1" ),
	Format = {}, -- filled by Formatting.lua
	LibDualSpec = LibStub( "LibDualSpec-1.0" ),
	LibItemBuffs = LibStub( "LibItemBuffs-1.0" ),
	RangeCheck = LibStub( "LibRangeCheck-2.0" ),
	SpellFlash = SpellFlash or SpellFlashCore,
	SpellRange = LibStub( "SpellRange-1.0" ),
	SharedMedia = LibStub( "LibSharedMedia-3.0", true )
}


ns.class = {
    file = "NONE",
    abilities = {},
    auras = {},
    castExclusions = {},
    defaults = {},
	exclusions = {}, -- exclude from target detection
	gearsets = {},
	glyphs = {},
	hooks = {},
	perks = {},
    range = 8,
	resources = {},
	searchAbilities = {},
	settings = {},
	stances = {},
	talents = {},
	toggles = {}
}
ns.hotkeys = {}
ns.keys = {}
ns.queue = {}
ns.scripts = {
    D = {},
    P = {},
    A = {}
}
ns.state = {}
ns.targets = {}
ns.TTD = {}
ns.UI = {
    Buttons = {}
}
ns.visible = {
    display = {},
    hook = {},
    list = {},
    action = {}
}


ns.debug = {}
ns.snapshots = {}


-- Default Keybinding UI
BINDING_HEADER_HEKILI_HEADER = "Hekili"
BINDING_NAME_HEKILI_TOGGLE_PAUSE = "Pause"
-- BINDING_NAME_HEKILI_SNAPSHOT = "Snapshot"
BINDING_NAME_HEKILI_TOGGLE_COOLDOWNS = "Toggle Cooldowns"
BINDING_NAME_HEKILI_TOGGLE_POTIONS = "Toggle Potions"
BINDING_NAME_HEKILI_TOGGLE_INTERRUPTS = "Toggle Interrupts"
BINDING_NAME_HEKILI_TOGGLE_MODE = "Toggle Mode"


ns.refreshBindings = function ()

    local profile = Hekili.DB.profile

    profile[ 'HEKILI_TOGGLE_MODE' ] = GetBindingKey( "HEKILI_TOGGLE_MODE" )
    profile[ 'HEKILI_TOGGLE_PAUSE' ] = GetBindingKey( "HEKILI_TOGGLE_PAUSE" )
    profile[ 'HEKILI_TOGGLE_COOLDOWNS' ] = GetBindingKey( "HEKILI_TOGGLE_COOLDOWNS" )
    profile[ 'HEKILI_TOGGLE_POTIONS' ] = GetBindingKey( "HEKILI_TOGGLE_POTIONS" )
    -- profile[ 'HEKILI_SNAPSHOT' ] = GetBindingKey( "HEKILI_SNAPSHOT" )

end


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

    if not self.DB.profile.Debug then return end
    if not display then return end

    current_display = display

    debug[ current_display ] = debug[ current_display ] or {
        log = {},
        index = 1
    }
    active_debug = debug[ current_display ]
    active_debug.index = 1

    self:Debug( "New Recommendations for [ %s ] requested at %s ( %.2f ).", display, date( "%H:%M:%S"), GetTime() )

end

function Hekili:Debug( ... )

    if not Hekili.DB.profile.Debug then return end
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

        table.insert( snapshots[ k ], table.concat( v.log, "\n" ) )

    end

end

Hekili.Snapshots = ns.snapshots



ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )
