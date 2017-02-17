-- Hekili.lua
-- April 2014

local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )

local format = string.format


ns.PTR = GetBuildInfo() ~= "7.1.5"


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
ns.snapshots = {}
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


ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )
