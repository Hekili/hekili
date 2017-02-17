-- Options.lua
-- Everything related to building/configuring options.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local scripts = ns.scripts

local format = string.format
local match = string.match

local callHook = ns.callHook
local restoreDefaults = ns.restoreDefaults

local escapeMagic = ns.escapeMagic
local formatKey = ns.formatKey
local tableCopy = ns.tableCopy

-- Default Table
function Hekili:GetDefaults()
  local defaults = {
    profile = {
      Version = 7,
      Release = 20170100,
      Legion = true,
      Enabled = true,
      Locked = false,
      Debug = false,

      ['Switch Type'] = 0,
      ['Mode Status'] = 3,
      Interrupts = true,
      Hardcasts = true,

      Clash = 0,
      ['Audit Targets'] = 6,
      ['Count Nameplate Targets'] = true,
      ['Nameplate Detection Range'] = 8,
      ['Count Targets by Damage'] = true,
      ['Updates Per Second'] = 20,
      ['Recommendation Window'] = 0.1,

      ['Notification Enabled'] = true,
      ['Notification Font'] = 'Arial Narrow',
      ['Notification X'] = 0,
      ['Notification Y'] = 0,
      ['Notification Width'] = 600,
      ['Notification Height'] = 40,
      ['Notification Font Size'] = 20,

      displays = {
      },
      actionLists = {
      },
    }
  }

  return defaults
end


-- DISPLAYS
-- Add a display to the profile (to be stored in SavedVariables).
ns.newDisplay = function( name )

  if not name then
    return nil
  end

  for i,v in ipairs( Hekili.DB.profile.displays ) do
    if v.Name == name then
      ns.Error( "newDisplay() - display '" .. name .. "' already exists." )
      return nil
    end
  end

  local index = #Hekili.DB.profile.displays + 1

  -- FIX: REPLACE HEARTBEAT
  if not Hekili[ 'ProcessDisplay'..index ] then
    Hekili[ 'ProcessDisplay'..index ] = function()
      Hekili:ProcessHooks( index )
    end
  end

  Hekili.DB.profile.displays[ index ] = {
    Name = name,
    Release = Hekili.DB.profile.Release,

    Enabled = true,

    ['PvE - Default'] = true,
    ['PvE - Default Alpha'] = 1,
    ['PvE - Target'] = false,
    ['PvE - Target Alpha'] = 1,
    ['PvE - Combat'] = false,
    ['PvE - Combat Alpha'] = 1,

    ['PvP - Default'] = true,
    ['PvP - Default Alpha'] = 1,
    ['PvP - Target'] = false,
    ['PvP - Target Alpha'] = 1,
    ['PvP - Combat'] = false,
    ['PvP - Combat Alpha'] = 1,

    Script = '',

    ['Auto - Minimum'] = 0,
    ['Auto - Maximum'] = 0,
    ['Single - Minimum'] = 0,
    ['Single - Maximum'] = 1,
    ['AOE - Minimum'] = 3,
    ['AOE - Maximum'] = 0,

    ['Use SpellFlash'] = false,
    ['SpellFlash Color'] = { r = 1, g = 1, b = 1, a = 1 },

    -- Talent Group: Primary, Secondary, Both
    ['Talent Group'] = 0,
    ['Specialization'] = ns.getSpecializationID(),
    ['Icons Shown'] = 5,
    ['Maximum Time'] = 30,
    ['Queue Direction'] = 'RIGHT',
    ['Queue Alignment'] = 'c',

    -- Captions
    ['Action Captions'] = true,
    -- Primary Caption: Default, # Targets, Buff ________ Stacks, Debuff ________ Count, Debuff ________ Count / # Targets
    ['Primary Caption'] = 'default',
    ['Primary Caption Aura'] = '',

    -- Visual Elements
    Font = 'Arial Narrow',
    ['Primary Icon Size'] = 50,
    ['Primary Font Size'] = 12,
    ['Queued Icon Size'] = 40,
    ['Queued Font Size'] = 12,
    Spacing = 5,
    Zoom = 0.0,
    Overlay = false,
    ['Show Keybindings'] = true,
    ['Keybinding Style'] = 1,
    ['Range Checking'] = 'ability',

    Queues = {}
  }

  return ( 'D' .. index ), index

end


-- Add a display to the options UI.
ns.newDisplayOption = function( key )

  if not key or not Hekili.DB.profile.displays[ key ] then
    return nil
  end

  local dispOption = {
    type = "group",
    name = function(info, val)
      if Hekili.DB.profile.displays[key].Default then
        return "|cFF00C0FF" .. Hekili.DB.profile.displays[key].Name .. "|r"
      end
      return Hekili.DB.profile.displays[key].Name
    end,
    order = key,
    args = {
      Enabled = {
        type = 'toggle',
        name = 'Enabled',
        desc = 'Enable this display (hides the display and ignores its hooked action list(s) if unchecked).',
        order = 1,
        width = 'double'
      },
      Default = {
        type = 'toggle',
        name = 'Default',
        desc = function(info, val)
          local disp = tonumber( match( info[#info-1], "^D(%d+)" ) )
          return 'This display is a default, and is updated automatically updated when the addon is updated.  Unchecking this setting will prevent the addon from automatically updating this display.  This cannot be undone without reloading the display.\n|cFF00C0FF' .. Hekili.DB.profile.displays[ disp ].Release .. '|r'
        end,
        order = 3,
        hidden = function(info, val)
          return not Hekili.DB.profile.displays[key].Default
        end,
        width = 'single',
      },
      UndefBlank = {
        type = "description",
        name = " ",
        width = "single",
        order = 3,
        hidden = function(info, val)
          return Hekili.DB.profile.displays[key].Default
        end
      },
      ['Name'] = {
        type = 'input',
        name = 'Name',
        desc = 'Rename this display.',
        order = 20,
        validate = function(info, val)
          local key = tonumber( info[2]:match("^D(%d+)") )
          for i, display in pairs( Hekili.DB.profile.displays ) do
            if i ~= key and display.Name == val then
              return "That display name is already in use."
            end
          end
          return true
        end,
        width = 'full',
      },
      ['Talent Group'] = {
        type = 'select',
        name = 'Talent Group',
        desc = 'Choose the talent group(s) for this display.',
        order = 30,
        values = {
          [0] = 'Both',
          [1] = 'Primary',
          [2] = 'Secondary'
        },
        width = "single"
      },
      ['Specialization'] = {
        type = 'select',
        name = 'Specialization',
        desc = 'Choose the talent specialization(s) for this display.',
        order = 40,
        values = function(info)
          local class = select(2, UnitClass("player"))
          if not class then return nil end

          local num = GetNumSpecializations()
          local list = {}

          for i = 1, num do
            local specID, name = GetSpecializationInfoForClassID( ns.getClassID(class), i )
            list[specID] = '|T' .. select( 4, GetSpecializationInfoByID( specID ) ) .. ':0|t ' .. name
          end

          list[ 0 ] = '|TInterface\\Addons\\Hekili\\Textures\\' .. class .. '.blp:0|t Any'
          return list
        end,
        width = 'single',
      },
      ['Range Checking'] = {
        type = 'select',
        name = 'Range Checking',
        desc = "Select the type of range checking to use when coloring abilities that are in or out of range.\n" ..
          "|cFFFFD100Per Ability|r - Each ability is individually highlighted in red if that ability is out of range.\n" ..
          "|cFFFFD100Melee|r - All abilities are highlighted in red if you are out of melee range.\n" ..
          "|cFFFFD100No Range Checking|r - Do not warn in red if an ability is out of range.\n" ..
          "|cFFFFD100Disable Out of Range|r - Treat abilities as unusable if not in range.\n",
        values = { ability = "Per Ability",
          melee = "Melee",
          off = "No Range Checking",
          xclude = "Disable Out of Range" },
        order = 41
      },
      ['Mode Overrides'] = {
        type = 'group',
        inline = true,
        name = 'Mode Overrides',
        order = 45,
        args = {
          ['Auto - Minimum'] = {
            type = 'range',
            min = 0,
            max = 20,
            step = 1,
            name = 'Auto: Minimum',
            desc = "This display will always act as though there are at least this many targets when your mode is set to Auto.  If set to 0, this will be ignored.",

            order = 1
          },
          ['Single - Minimum'] = {
            type = 'range',
            min = 0,
            max = 20,
            step = 1,
            name = 'Single: Minimum',
            desc = "This display will always act as though there are at least this many targets when your mode is set to Single Target.  If set to 0, this will be ignored.",

            order = 2
          },
          ['AOE - Minimum'] = {
            type = 'range',
            min = 0,
            max = 20,
            step = 1,
            name = 'AOE: Minimum',
            desc = "This display will always act as though there are at least this many targets when your mode is set to AOE.  If set to 0, this will be ignored.",
            order = 3
          },
          ['Auto - Maximum'] = {
            type = 'range',
            min = 0,
            max = 20,
            step = 1,
            name = 'Auto: Maximum',
            desc = "This display will always act as though there are no more than this many targets when your mode is set to Auto.  If set to 0, this will be ignored.",
            order = 4
          },
          ['Single - Maximum'] = {
            type = 'range',
            min = 0,
            max = 20,
            step = 1,
            name = 'Single: Maximum',
            desc = "This display will always act as though there are no more than this many targets when your mode is set to Single Target.  If set to 0, this will be ignored.",
            order = 5
          },
          ['AOE - Maximum'] = {
            type = 'range',
            min = 0,
            max = 20,
            step = 1,
            name = 'AOE: Maximum',
            desc = "This display will always act as though there are no more than this many targets when your mode is set to AOE.  If set to 0, this will be ignored.",
            order = 6
          },
        },
      },
      ['SpellFlash Group'] = {
        type = 'group',
        inline = true,
        name = "SpellFlash",
        order = 50,
        hidden = function(info, val)
          return ns.lib.SpellFlash == nil
        end,
        args = {
          ['Use SpellFlash'] = {
            type = 'toggle',
            name = 'Use SpellFlash',
            desc = "If enabled and SpellFlash (or SpellFlashCore) is installed, the addon will cause the action buttons for recommended abilities to flash.",
            order = 3,
            width = 'double'
          },
          ['SpellFlash Color'] = {
            type = 'color',
            name = 'SpellFlash Color',
            desc = "If SpellFlash is installed, actions recommended from this display will flash with the selected color.",
            order = 4,
            width = 'single'
          }
        }
      },
      PvE = {
        type = 'group',
        inline = true,
        name = "PvE Visibility",
        order = 60,
        args = {
          ["PvE - Default"] = {
            type = 'toggle',
            name = 'Show Always',
            desc = 'Show this display at all times, regardless of combat state and whether you have a target.',
            order = 1
          },
          ['PvE - Default Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show Always', set the alpha transparency to this value.",
            order = 2,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double",
          },
          ['PvE - Target'] = {
            type = 'toggle',
            name = 'Show with Target',
            desc = 'Show this display whenever you have a hostile enemy targeted, regardless of whether you are in combat.',
            order = 3,
          },
          ['PvE - Target Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show with Target', set the alpha transparency to this value.",
            order = 4,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double"
          },
          ['PvE - Combat'] = {
            type = 'toggle',
            name = 'Show in Combat',
            desc = "Show this display whenever you are in combat.",
            order = 5
          },
          ['PvE - Combat Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When the display is shown because you are in combat, set the transparency to this value.",
            order = 6,
            min = 0,
            max = 1,
            step = 0.01,
            width = 'double'

          }
        }
      },
      PvP = {
        type = 'group',
        inline = true,
        name = "PvP Visibility",
        order = 65,
        args = {
          ["PvP - Default"] = {
            type = 'toggle',
            name = 'Show Always',
            desc = 'Show this display at all times, regardless of combat state and whether you have a target.',
            order = 1
          },
          ['PvP - Default Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show Always', set the alpha transparency to this value.",
            order = 2,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double",
          },
          ['PvP - Target'] = {
            type = 'toggle',
            name = 'Show with Target',
            desc = 'Show this display whenever you have a hostile enemy targeted, regardless of whether you are in combat.',
            order = 3,
          },
          ['PvP - Target Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When this display is shown due to 'Show with Target', set the alpha transparency to this value.",
            order = 4,
            min = 0,
            max = 1,
            step = 0.01,
            width = "double"
          },
          ['PvP - Combat'] = {
            type = 'toggle',
            name = 'Show in Combat',
            desc = "Show this display whenever you are in combat.",
            order = 5
          },
          ['PvP - Combat Alpha'] = {
            type = 'range',
            name = 'Alpha',
            desc = "When the display is shown because you are in combat, set the transparency to this value.",
            order = 6,
            min = 0,
            max = 1,
            step = 0.01,
            width = 'double'

          }
        }
      },
      Script = {
        type = 'input',
        name = 'Conditions',
        desc = 'Enter the conditions (Lua or SimC-like syntax) for this display to be visible.',
        dialogControl = "HekiliCustomEditor",
        arg = function(info)
          local dispKey = info[2]
          local dispIdx = tonumber( dispKey:match("^D(%d+)" ) )
          local results = {}

          ns.state.reset()
          ns.state.this_action = 'wait'
          ns.storeValues( results, ns.scripts.D[ dispIdx ] )
          return results
        end,
        multiline = 6,
        order = 70,
        usage = 'See http://www.curse.com/addons/wow/hekili for a reference list of game state options.',
        width = 'full'
      },
      BLANK = {
        type = "description",
        name = " ",
        width = "full",
        order = 80
      },
      ['Add Hook'] = {
        type = "execute",
        name = "Add Hook",
        desc = "Adds a new hook for an action list.  You can specific which action list to use, and under which conditions to use the list.",
        order = 90,
        func = function (info)
          local dispKey, display = info[2], tonumber( info[2]:match("^D(%d+)") )

          local clear, suffix, name, result = 0, 1, "New Hook", "New Hook"
          while clear < #Hekili.DB.profile.displays[ display ].Queues do
            for i, queue in ipairs( Hekili.DB.profile.displays[ display ].Queues ) do
              if queue.Name == result then
                result = name .. ' (' .. suffix .. ')'
                suffix = suffix + 1
              else
                clear = clear + 1
              end
            end
          end

          local key, index = ns.newHook( display, result )
          if key then
            Hekili.Options.args.displays.args[ dispKey ].args[ key ] = ns.newHookOption( display, index )
            ns.refreshOptions()
          end
          ns.cacheCriteria()
          ns.loadScripts()
        end
      },
      Reload = {
        type = "execute",
        name = "Reload Display",
        desc = function( info, ... )
          local dispKey, dispID = info[2], tonumber( string.match( info[2], "^D(%d+)" ) )
          local display = Hekili.DB.profile.displays[ dispID ]

          local _, defaultID = ns.isDefault( display.Name, 'displays' )

          local output = "Reloads this display from the default options available. Style settings are left untouched, but hooks and criteria are reset."

          if class.defaults[ defaultID ].version > ( display.Release or 0 ) then
            output = output .. "\n|cFF00FF00The default display is newer (" .. class.defaults[ defaultID ].version .. ") than your existing display (" .. ( display.Release or "2.00" ) .. ").|r"
          end

          return output
        end,
        confirm = true,
        confirmText = "Reload the default settings for this default display?",
        order = 91,
        hidden = function( info, ... )
          local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
          local display = Hekili.DB.profile.displays[ dispID ]

          if ns.isDefault( display.Name, 'displays' ) then
            return false
          end

          return true
        end,
        func = function( info, ... )
          local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
          local display = Hekili.DB.profile.displays[ dispID ]

          local _, defaultID = ns.isDefault( display.Name, 'displays' )

          local import = ns.deserializeDisplay( class.defaults[ defaultID ].import )

          if not import then
            Hekili:Print("Unable to import " .. class.defaults[ defaultID ].name .. ".")
            return
          end

          local settings_to_keep = { "Primary Icon Size", "Queued Font Size", "Primary Font Size", "Primary Caption Aura", "rel", "Spacing", "Queue Direction", "Queued Icon Size", "Font", "x", "y", "Icons Shown", "Action Captions", "Primary Caption", "Primary Caption Aura" }

          for _, k in pairs( settings_to_keep ) do
            import[ k ] = display[ k ]
          end

          Hekili.DB.profile.displays[ dispID ] = import
          Hekili.DB.profile.displays[ dispID ].Name = class.defaults[ defaultID ].name
          Hekili.DB.profile.displays[ dispID ].Release = class.defaults[ defaultID ].version
          Hekili.DB.profile.displays[ dispID ].Default = true
          ns.checkImports()
          ns.refreshOptions()
          ns.loadScripts()
          ns.buildUI()
        end,
      },
      BLANK2 = {
        type = "description",
        name = " ",
        order = 92,
        hidden = function( info, ... )
          local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
          local display = Hekili.DB.profile.displays[ dispID ]

          if ns.isDefault( display.Name, 'displays' ) then
            return true
          end

          return false
        end,
        width = "single",
      },
      Delete = {
        type = "execute",
        name = "Delete Display",
        desc = "Deletes this display and all associated action list hooks and criteria.  The action lists will remain untouched.",
        confirm = true,
        confirmText = "Permanently delete this display and all associated action list hooks?",
        order = 93,
        func		=	function(info, ...)
          if not info[2] then return end

          -- Key to Current Display (string)
          local dispKey = info[2]
          local dispIdx = tonumber( match( info[2], "^D(%d+)" ) )

          for i, queue in ipairs( Hekili.DB.profile.displays[dispIdx].Queues ) do
            for k,v in pairs( queue ) do
              queue[k] = nil
            end
            table.remove( Hekili.DB.profile.displays[dispIdx].Queues, i)
          end

          -- Will need to be more elaborate later.
          table.remove( Hekili.DB.profile.displays, dispIdx )
          table.remove( ns.queue, dispIdx )
          ns.refreshOptions()
          ns.loadScripts()
          ns.buildUI()
          ns.lib.AceConfigDialog:SelectGroup( "Hekili", 'displays' )
        end
      },
      ['UI and Style'] = {
        type = 'group',
        name = 'UI and Style',
        order = 9,
        args = {
          x = {
            type = 'input',
            name = "Position (X)",
            desc = "Enter the horizontal position of this display's primary icon relative to the center of your screen.  Negative numbers move the icon left, positive numbers move the icon right.",
            order = 2,
          },
          y = {
            type = 'input',
            name = "Position (Y)",
            desc = "Enter the vertical position of this display's primary icon relative to the center of your screen.  Negative numbers move the icon up, positive numbers move the icon down.",
            order = 3,
          },
          iconHeader = {
            type = 'header',
            name = 'Icons and Layout',
            order = 5,
          },
          ['Queue Direction'] = {
            type = 'select',
            name = 'Queue Direction',
            order = 06,
            values = {
              TOP = 'Up',
              BOTTOM = 'Down',
              LEFT = 'Left',
              RIGHT = 'Right'
            },
          },
          ['Queue Alignment'] = {
            type = 'select',
            name = 'Queue Alignment',
            order = 07,
            values = function( info )
              local dispIdx = tonumber( match( info[2], "^D(%d+)" ) )
              local display = dispIdx and Hekili.DB.profile.displays[ dispIdx ]
              
              if not display then return nil end
              
              if display['Queue Direction'] == 'LEFT' or display['Queue Direction'] == 'RIGHT' then
                return { a = 'Top', b = 'Bottom', c = 'Center' }
              end
              
              return { a = 'Left', b = 'Right', c = 'Center' }
            end
          },
          ['Blank I&L Space'] = {
            type = 'description',
            name = ' ',
            order = 08,
            width = 'single',
          },
          ['Icons Shown'] = {
            type = 'range',
            name = 'Icons Shown',
            desc = "Select the number of icons to display.  This also determines the number of actions the addon will try to predict.",
            min = 1,
            max = 10,
            order = 10,
            step = 1,
          },
          Spacing = {
            type = 'range',
            name = 'Icon Spacing',
            desc = "Select the number of pixels to skip between icons in this display.",
            min = -10,
            max = 50,
            order = 11,
            step = 1,
          },
          Zoom = {
            type = 'range',
            name = 'Icon Zoom',
            desc = "Select the zoom percentage for the icon textures in this display.  (Roughly 15% will trim off the default Blizzard borders.)",
            min = 0,
            max = 100,
            order = 12,
            step = 1
          },
          ['Primary Icon Size'] = {
            type = 'range',
            name = 'Primary Icon Size',
            desc = "Select the size of the primary icon.",
            min = 10,
            max = 500,
            order = 21,
            step = 1,
          },
          ['Queued Icon Size'] = {
            type = 'range',
            name = 'Queued Icon Size',
            desc = "Select the size of the queued icons.",
            min = 10,
            max = 500,
            order = 22,
            step = 1,
          },
          fontHeader = {
            type = 'header',
            name = 'Style',
            order = 30,
          },
          Font = {
            type = 'select',
            name = 'Font',
            desc = "Select the font to use on all icons in this display.",
            dialogControl = 'LSM30_Font',
            order = 31,
            values = ns.lib.SharedMedia:HashTable("font"), -- pull in your font list from LSM
          },
          ['Primary Font Size'] = {
            type = 'range',
            name = 'Primary Font Size',
            desc = "Enter the size of the font for primary icon captions.",
            min = 6,
            max = 100,
            order = 32,
            step = 1,
          },
          ['Queued Font Size'] = {
            type = 'range',
            name = 'Queued Font Size',
            desc = "Enter the size of the font for queued icon captions.",
            min = 6,
            max = 100,
            order = 33,
            step = 1,
          },
          ['Show Keybindings'] = {
            type = 'toggle',
            name = "Show Keybindings",
            desc = "If checked, the addon will show keybindings for recommended actions.",
            order = 34,
          },
          ['Keybinding Style'] = {
            type = "select",
            name = "Keybinding Style",
            values = {
                "Lowercase",
                "Uppercase"
            },
            get = function( info )
              local dispKey, display = info[2], tonumber( info[2]:match("^D(%d+)") )

              return Hekili.DB.profile.displays[ display ]['Keybinding Style'] or 1
            end,
            order = 35,
          },
          Overlay = {
            type = "toggle",
            name = "Show Overlay Glow",
            desc = "If checked, the primary icon will glow if the ability has an active overlay (i.e., Stormbringer for Stormstrike or Hot Hand for Lava Lash).",
            order = 39,

          },
          captionHeader = {
            type = 'header',
            name = 'Captions',
            order = 40,
          },
          -- Captions
          ['Action Captions'] = {
            type = 'toggle',
            name = 'Action Captions',
            desc = "Enable or disable action captions.  This allows you to display additional information about a particular action when shown.",
            order = 51,
            width = 'full'
          },
          ['Primary Caption'] = {
            type = 'select',
            name = 'Primary Caption',
            desc = "This allows you to override the caption on the primary icon under a variety of circumstances.",
            hidden = function(info)
              local display = tonumber( match( info[2], "^D(%d+)" ) )
              if not Hekili.DB.profile.displays[ display ]['Action Captions'] then
                return true
              end
              return false
            end,
            order = 52,
            values = {
              default = 'Use Default Captions',
              targets = 'Show # of Targets',
              buff = 'Buff Stacks',
              debuff = 'Debuff Count',
              ratio = 'Debuff Count / # Targets',
              sratio = 'Buff Stacks / # Targets'
            }
          },
          -- Should probably use the autocomplete aura tool.
          ['Primary Caption Aura'] = {
            type = 'input',
            name = 'Aura',
            desc = "Enter the name of the aura to check for certain Primary Caption overrides.",
            hidden = function(info)
              local display = tonumber( match( info[2], "^D(%d+)" ) )
              if not Hekili.DB.profile.displays[ display ]['Action Captions'] then
                return true
              end
              return false
            end,
            order = 53,
          }
        }
      },
      ['Import/Export'] = {
        type = 'group',
        name = 'Import/Export',
        order = 10,
        args = {
          ['Copy To'] = {
            type = 'input',
            name = 'Copy To',
            desc = 'Enter a name for the new display.  All settings, including action list hooks, will be duplicated in the new display.',
            order = 11,
            validate = function(info, val)
              if val == '' then return true end
              for k,v in ipairs(Hekili.DB.profile.displays) do
                if val == v.Name then
                  Hekili:Print("That name is already in use.")
                  return "That name is already in use."
                end
              end
              return true
            end,
            width = 'full',
          },
          ['Import'] = {
            type = 'input',
            name = 'Import Display',
            desc = "Paste the export string from another display to copy its settings to this display.  All settings will be copied, except for the display name.",
            order = 11,
            width = 'full',
            multiline = 6,
          },
          ['Export'] = {
            type = 'input',
            name = 'Export Display',
            desc = "Copy this export string and paste it into another display's Import field to copy all settings from this display to another existing display.",
            get = function(info)
              local dispKey = info[2]
              local dispIdx = tonumber( dispKey:match("^D(%d+)") )

              return ns.serializeDisplay( dispIdx )
            end,
            set = function(...)
              return
            end,
            order = 12,
            width = 'full',
            multiline = 6,
          },
        }
      },
    }
  }

  return dispOption

end


-- DISPLAYS > HOOKS
-- Add a hook to a display.
ns.newHook = function( display, name )

  if not name then
    return nil
  end

  if type(display) == string then
    display = tonumber( match( display, "^D(%d+)") )
  end

  for i,v in ipairs( Hekili.DB.profile.displays[ display ].Queues ) do
    if v.Name == name then
      ns.Error('NewHook() - tried to use an existing hook name.')
      return nil
    end
  end

  local index = #Hekili.DB.profile.displays[display].Queues + 1

  Hekili.DB.profile.displays[ display ].Queues[ index ] = {
    Name = name,
    Release = Hekili.DB.profile.Release,
    Enabled = false,
    ['Action List'] = 0,
    Script = '',
  }

  return ( 'P' .. index ), index

end


-- Add a hook to the options UI.
-- display	(number)	The index of the display to which this entry is attached.
-- key		(number)	The index for this particular hook.
ns.newHookOption = function( display, key )

  if not key or not Hekili.DB.profile.displays[display].Queues[ key ] then
    return nil
  end

  local pqOption = {
    type = "group",
    name = '|cFFFFD100' .. key .. '.|r ' .. Hekili.DB.profile.displays[ display ] .Queues[ key ].Name,
    order = 50 + key,
    -- childGroups = "tab",
    -- This number must be index + number of options in "Display Queues" section.
    -- order = index + 2,
    args = {

      Enabled = {
        type = 'toggle',
        name = 'Enabled',
        order = 00,
        width = 'double',
      },
      ['Move'] = {
        type = 'select',
        name = 'Position',
        order = 01,
        values = function(info)
          local dispKey, hookKey = info[2], info[3]
          local dispIdx, hookID = tonumber( dispKey:match("^D(%d+)") ), tonumber( hookKey:match("^P(%d+)") )
          local list = {}
          for i = 1, #Hekili.DB.profile.displays[ dispIdx ].Queues do
            list[i] = i
          end
          return list
        end
      },
      ['Name'] = {
        type = 'input',
        name = 'Name',
        order = 03,
        validate = function(info, val)
          local key = tonumber(info[2])
          for i, hook in pairs( Hekili.DB.profile.displays[display].Queues ) do
            if i ~= key and hook.Name == val then
              return "That hook name is already in use."
            end
          end
          return true
        end,
        width = 'double'
      },
      ['Action List'] = {
        type = 'select',
        name = 'Action List',
        order = 04,
        values = function(info)
          local lists = {}

          lists[0] = 'None'
          for i, list in ipairs( Hekili.DB.profile.actionLists ) do
            if list.Specialization > 0 then
              lists[i] = '|T' .. select(4, GetSpecializationInfoByID( list.Specialization ) ) .. ':0|t ' .. list.Name
            else
              lists[i] = '|TInterface\\Addons\\Hekili\\Textures\\' .. select(2, UnitClass('player')) .. '.blp:0|t ' .. list.Name
            end
          end

          return lists
        end,
      },
      Script = {
        type = 'input',
        name = 'Conditions',
        dialogControl = "HekiliCustomEditor",
        arg = function(info)
          local dispKey, hookKey = info[2], info[3]
          local dispIdx, hookID = tonumber( dispKey:match("^D(%d+)" ) ), tonumber( hookKey:match("^P(%d+)") )
          local prio = Hekili.DB.profile.displays[ dispIdx ].Queues[ hookID ]
          local results = {}

          ns.state.reset()
          ns.state.this_action = 'wait'
          ns.storeValues( results, ns.scripts.P[ dispIdx..':'..hookID ] )
          return results
        end,
        multiline = 6,
        order = 12,
        width = 'full'
      },
      Delete = {
        type = "execute",
        name = "Delete Hook",
        confirm = true,
        -- confirmText = '
        order = 999,
        func		=	function(info, ...)
          -- Key to Current Display (string)
          local dispKey = info[2]
          local dispIdx = tonumber( match( dispKey, "^D(%d+)" ) )
          local queueKey = info[3]
          local queueIdx = tonumber( match( queueKey, "^P(%d+)" ) )

          -- Will need to be more elaborate later.
          table.remove( Hekili.DB.profile.displays[dispIdx].Queues, queueIdx )
          ns.refreshOptions()
          ns.loadScripts()
        end
      },
    }
  }

  return pqOption

end


-- ACTION LISTS
-- Add an action list to the profile (to be stored in SavedVariables).
ns.newActionList = function( name )

  local index = #Hekili.DB.profile.actionLists + 1

  if not name then
    name = "List #" .. index
  end

  Hekili.DB.profile.actionLists[index] = {
    Enabled = false,
    Name = name,
    Release = tonumber( date("%Y%m%d.1") ),
    Specialization = ns.getSpecializationID() or 0,
    Script = '',
    Actions = {}
  }

  return ( 'L' .. index ), index
end


-- Add an action list to the options UI.
ns.newActionListOption = function( index )

  if not index or Hekili.DB.profile.actionLists[ index ] == nil then
    return nil
  end

  local name = Hekili.DB.profile.actionLists[ index ].Name

  local listOption = {
    type = "group",
    name = function(info, val)
      if Hekili.DB.profile.actionLists[ index ].Default then
        return "|cFF00C0FF" .. name .. "|r"
      end
      return name
    end,
    icon = function(info)
      local list = tonumber( match( info[#info], "^L(%d+)" ) )
      if Hekili.DB.profile.actionLists[ list ].Specialization > 0 then
        return select( 4, GetSpecializationInfoByID( Hekili.DB.profile.actionLists[ list ].Specialization ) )
      else return 'Interface\\Addons\\Hekili\\Textures\\' .. select(2, UnitClass('player')) .. '.blp' end
    end,
    order = 10 + index,
    args = {
      Enabled = {
        type = 'toggle',
        name = 'Enabled',
        desc = "Enable or disable this action list for processing in all displays.",
        order = 1,
        width = 'double',
      },
      Default = {
        type = 'toggle',
        name = 'Default',
        desc = function(info, val)
          local list = tonumber( match( info[#info-1], "^L(%d+)" ) )
          return "This action list is a default, and will be automatically updated when the addon is updated.  To prevent this behavior, uncheck this box.  This cannot be undone without reloading the action list.\n|cFF00C0FF" .. Hekili.DB.profile.actionLists[ list ].Release .. "|r"
        end,
        order = 2,
        hidden = function(info, val)
          return not Hekili.DB.profile.actionLists[ index ].Default
        end
      },
      DefBlank = {
        type = 'description',
        name = " ",
        order = 2,
        hidden = function(info, val)
          return Hekili.DB.profile.actionLists[ index ].Default
        end
      },
      Name = {
        type = "input",
        name = "Name",
        desc = "Enter a unique name for this action list.",
        validate = function(info, val)
          for i, list in pairs( Hekili.DB.profile.actionLists ) do
            if list.Name == val and index ~= i then
              return "That action list name is already in use."
            end
          end
          return true
        end,
        order = 3,
        width = "full",
      },
      Specialization = {
        type = 'select',
        name = 'Specialization',
        desc = "Select the class specialization for this action list.  If you select 'Any', the list will work in all specializations, though abilities unavailable to your specialization will not be recommended.",
        order = 4,
        values = function(info)
          local class = select(2, UnitClass("player"))
          if not class then return nil end

          local num = GetNumSpecializations()
          local list = {}

          list[0] = '|TInterface\\Addons\\Hekili\\Textures\\' .. select(2, UnitClass('player')) .. '.blp:0|t Any'
          for i = 1, num do
            local specID, name = GetSpecializationInfoForClassID( ns.getClassID(class), i )
            list[specID] = '|T' .. select( 4, GetSpecializationInfoByID( specID ) ) .. ':0|t ' .. name
          end
          return list
        end,
        width = 'full'
      },
      ['Import/Export'] = {
        type = "group",
        name = 'Import/Export',
        order = 5,
        args = {
          ['Copy To'] = {
            type = 'input',
            name = 'Copy To',
            desc = 'Enter a name for the new action list.  All settings, except for the list name, will be duplicated into the new list.',
            order = 32,
            validate = function(info, val)
              if val == '' then return true end
              for k,v in ipairs(Hekili.DB.profile.actionLists) do
                if val == v.Name then
                  Hekili:Print("That name is already in use.")
                  return "That name is already in use."
                end
              end
              return true
            end,
            width = 'full',
          },
          ['Import Action List'] = {
            type = 'input',
            name = 'Import Action List',
            desc = "Paste the export string from another action list to copy it here.  All settings, except for the list name, will be duplicated into this list.",
            order = 33,
            width = 'full',
            multiline = 6,
          },
          ['Export Action List'] = {
            type = 'input',
            name = 'Export Action List',
            desc = "Copy this export string and paste it into another action list to overwrite the other action list.",
            get = function(info)
              local listKey = info[2]
              local listIdx = tonumber( listKey:match("^L(%d+)") )

              return ns.serializeActionList( listIdx )
            end,
            set = function(...)
              return
            end,
            order = 34,
            width = 'full',
            multiline = 6,
          },
          ['SimulationCraft'] = {
            type = 'input',
            name = 'Import SimulationCraft List',
            desc = "Copy a SimulationCraft action list and paste it here to import.  If any lines cannot be parsed, the action list will not be imported.",
            order = 35,
            multiline = 6,
            dialogControl = 'HekiliCustomEditor',
            -- validate = 'ImportSimulationCraftActionList',
            width = 'full',
            confirm = true,
          },
        }
      },
      spcHeader = {
        type = 'description',
        name = "\n",
        order = 900,
        width = 'full'
      },
      ['Add Action'] = {
        type = "execute",
        name = "Add Action",
        desc = "Adds a new action entry, where you can set the ability and conditions required for that ability to be shown.",
        order = 901,
        func = function( info )
          local listKey, listIdx = info[2], tonumber( info[2]:match("^L(%d+)") )

          local clear, suffix, name, result = 0, 1, "New Action", "New Action"
          while clear < #Hekili.DB.profile.actionLists[ listIdx ].Actions do
            for i, action in ipairs( Hekili.DB.profile.actionLists[ listIdx ].Actions ) do
              if action.Name == result then
                result = name .. ' (' .. suffix .. ')'
                suffix = suffix + 1
              else
                clear = clear + 1
              end
            end
          end

          local key, index = ns.newAction( listIdx, result )
          if key then
            Hekili.Options.args.actionLists.args[ listKey ].args[ key ] = ns.newActionOption( listIdx, index )
            ns.cacheCriteria()
            ns.loadScripts()
          end
        end
      },
      Reload = {
        type = "execute",
        name = "Reload Action List",
        desc = function( info, ... )
          local listKey, listID = info[2], tonumber( string.match( info[2], "^L(%d+)" ) )
          local list = Hekili.DB.profile.actionLists[ listID ]

          local _, defaultID = ns.isDefault( list.Name, 'actionLists' )

          local output = "Reloads this action list from the default options available."

          if class.defaults[ defaultID ].version > ( list.Release or 0 ) then
            output = output .. "\n|cFF00FF00The default action list is newer (" .. class.defaults[ defaultID ].version .. ") than your existing action list (" .. ( list.Release or "7.00" ) .. ").|r"
          end

          return output
        end,
        confirm = true,
        confirmText = "Reload the default settings for this default action list?",
        order = 902,
        hidden = function( info, ... )
          local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
          local list = Hekili.DB.profile.actionLists[ listID ]

          if ns.isDefault( list.Name, 'actionLists' ) then
            return false
          end

          return true
        end,
        func = function( info, ... )
          local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
          local list = Hekili.DB.profile.actionLists[ listID ]

          local _, defaultID = ns.isDefault( list.Name, 'actionLists' )

          local import = ns.deserializeActionList( class.defaults[ defaultID ].import )

          if not import then
            Hekili:Print("Unable to import " .. class.defaults[ defaultID ].name .. ".")
            return
          end

          Hekili.DB.profile.actionLists[ listID ] = import
          Hekili.DB.profile.actionLists[ listID ].Name = class.defaults[ defaultID ].name
          Hekili.DB.profile.actionLists[ listID ].Release = class.defaults[ defaultID ].version
          Hekili.DB.profile.actionLists[ listID ].Default = true
          ns.refreshOptions()
          ns.loadScripts()
          -- ns.buildUI()
        end,
      },
      BLANK2 = {
        type = "description",
        name = " ",
        order = 902,
        hidden = function( info, ... )
          local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
          local list = Hekili.DB.profile.actionLists[ listID ]

          if ns.isDefault( list.Name, 'actionLists' ) then
            return true
          end

          return false
        end,
        width = "single",
      },
      Delete = {
        type = "execute",
        name = "Delete Action List",
        desc = "Delete this action list, and all actions associated with this list.",
        confirm = true,
        order = 999,
        func		=	function(info, ...)
          local actKey = info[2]
          local actIdx = tonumber( match( actKey, "^L(%d+)" ) )

          for d_key, display in ipairs( Hekili.DB.profile.displays ) do
            for l_key, list in ipairs ( display.Queues ) do
              if list['Action List'] == actIdx then
                list['Action List'] = 0
                list.Enabled = false
              elseif list['Action List'] > actIdx then
                list['Action List'] = list['Action List'] - 1
              end
            end
          end

          table.remove( Hekili.DB.profile.actionLists, actIdx )
          ns.loadScripts()
          ns.refreshOptions()
          ns.lib.AceConfigDialog:SelectGroup( "Hekili", "actionLists" )

        end
      }
    }
  }

  return listOption

end


-- ACTION LISTS > ACTIONS
-- Add an action to the action list.
ns.newAction = function( aList, name )

  if not name then
    return nil
  end

  if type(aList) == string then
    aList = tonumber( match( aList, "^A(%d+)") )
  end

  local clear, suffix, name_arg = 0, 1, name
  while clear < #Hekili.DB.profile.actionLists[aList].Actions do
    clear = 0
    for i, action in ipairs( Hekili.DB.profile.actionLists[aList].Actions ) do
      if name == action.Name then
        name = name_arg .. ' (' .. suffix .. ')'
        suffix = suffix + 1
      else
        clear = clear + 1
      end
    end
  end

  local index = #Hekili.DB.profile.actionLists[ aList ].Actions + 1

  Hekili.DB.profile.actionLists[ aList ].Actions[ index ] = {
    Name = name,
    Release = Hekili.DB.profile.Version + ( Hekili.DB.profile.Release / 100 ),
    Enabled = false,
    Ability = nil,
    Caption = nil,
    Indicator = 'none',
    Arguments = nil,
    Script = '',
  }

  return ( 'A' .. index ), index

end


local function getActionKeys( info )
    return info[2], info[3]
end


local function getActionIndexes( info )
    local k1, k2 = getActionKeys( info )

    return tonumber( k1:match("^L(%d+)") ), tonumber( k2:match( "^A(%d+)" ) )
end


local function getActionEntry( info )
    local lID, aID = getActionIndexes( info )

    if lID and aID then return Hekili.DB.profile.actionLists[ lID ].Actions[ aID ] end

    return nil
end


--- NewActionOption()
-- Add a new action to the action list options.
-- aList	(number)	index of the action list.
-- index	(number)	index of the action in the action list.
ns.newActionOption = function( aList, index )

  if not index then return nil end

  local entry = Hekili.DB.profile.actionLists[ aList ].Actions[ index ]

  if not entry then return nil end

  local actOption = {
    type = "group",
    name = '|cFFFFD100' .. index .. '.|r ' .. Hekili.DB.profile.actionLists[ aList ].Actions[ index ].Name,
    order = index * 10,
    -- childGroups = "tab",
    -- This number must be index + number of options in "Display Queues" section.
    -- order = index + 2,
    args = {
      Enabled = {
        type = 'toggle',
        name = 'Enabled',
        desc = "If disabled, this action will not be shown under any circumstances.",
        order = 00,
        width = 'double'
      },
      ['Move'] = {
        type = 'select',
        name = 'Position',
        desc = "Select another position in the action list and move this item to that location.",
        order = 01,
        values = function(info)
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)") ), tonumber( actKey:match("^A(%d+)") )
          local list = {}
          for i = 1, #Hekili.DB.profile.actionLists[ listIdx ].Actions do
            list[i] = i
          end
          return list
        end
      },
      ['Name'] = {
        type = 'input',
        name = 'Name',
        desc = "Enter a unique name for this action in the action list.  This is typically the ability name accompanied by a short description.",
        order = 03,
        validate = function(info, val)
          local listIdx = tonumber( match( info[2], "^L(%d+)" ) )

          for i, action in pairs( Hekili.DB.profile.actionLists[ aList ].Actions ) do
            if action.Name == val and i ~= listIdx then
              return "That action name is already in use."
            end
          end
          return true
        end,
      },
      Caption = {
        type = 'input',
        name = 'Caption',
        desc = "Enter a caption to be displayed on this action's icon when the action is shown.",
        order = 04,
      },

      Indicator = {
        type = 'select',
        name = 'Indicator',
        desc = "Select a special indicator for this ability.  It will appear at the top of the action's icon when shown.",
        order = 05,
        values = {
          none = "None",
          cancel = "|TInterface\\Addons\\Hekili\\Textures\\Cancel:0|t Cancel",
          cycle = "|TInterface\\Addons\\Hekili\\Textures\\Cycle2:0|t Cycle Targets"
        },
      },

      Ability = {
        type = 'select',
        name = 'Ability',
        desc = "Select the ability for this action entry.  Only abilities supported by the addon's prediction engine will be shown.",
        order = 06,
        values = class.searchAbilities,
        width = 'single'
      },


      -- Special Settings Per Ability Here.
      WaitSeconds = {
        type = 'input',
        name = 'Time to Wait',
        desc = "Specify the number of seconds that addon should delay before checking its next recommendation.  " ..
            "This can be specified as a number or an expression that evaluates to a number.  For instance, |cFFFFD100cooldown.judgment.remains|r " ..
            "will tell the addon to wait until the remaining cooldown on Judgment has passed.\n\n" ..
            "If left blank, the addon will wait |cFFFFD1001|r second.",
        order = 07,
        hidden = function( info )
            local action = getActionEntry( info )
            return not action or action.Ability ~= 'wait'
        end,
        width = "double",
      },
      ModName = {
        type = 'select',
        name = "Ability Settings",
        desc = "Select the appropriate option for the chosen ability.",
        order = 09,
        values = function( info )
            local action = getActionEntry( info )
            local opts = {}

            if action.Ability == 'call_action_list' or action.Ability == 'run_action_list' then
                for i, list in ipairs( Hekili.DB.profile.actionLists ) do
                    opts[ '"' .. list.Name .. '"' ] = '|T' .. select(4, GetSpecializationInfoByID( list.Specialization ) ) .. ':0|t ' .. list.Name
                end
            elseif action.Ability == 'potion' then
                for key, potion in pairs( class.potions ) do
                    opts[ '"' .. key .. '"' ] = GetItemInfo( potion.item )
                end
            end

            --[[ if action.ModName and not opts[ action.ModName ] then
                opts[ action.ModName ] = action.ModName
            end ]]  

            return opts
        end,
        hidden = function( info )
            local action = getActionEntry( info )

            if not action then return true
            elseif action.Ability == 'potion' then return false
            elseif ( action.Ability == 'call_action_list' or action.Ability == 'run_action_list' ) then return false end

            return true
        end,
        width = "double"
      },

      Script = {
        type = 'input',
        name = 'Conditions',
        dialogControl = "HekiliCustomEditor",
        arg = function(info)
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )
          local results = {}

          ns.state.reset()
          ns.state.this_action = Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].Ability
          ns.storeValues( results, ns.scripts.A[ listIdx..':'..actIdx ] )

          return results, true
        end,
        multiline = 6,
        order = 20,
        width = 'full',
        --[[ hidden = function (info)
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )

          return Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].ScriptType == 'time'
        end, ]]
      },
      whenReady = {
        type = 'select',
        name = 'Check When...',
        order = 10,
        width = 'full',
        desc = "\n|cFFFFD100Automatic|r:  This entry is checked when its assigned action is off-cooldown and the resources that are required are available.  This is the default setting.\n" ..
            "|cFFFFD100Script|r:  The entry is checked based on the value of a script, similar to the |cFFFFD100Conditions|r that are tested to determine if the entry will be used.\n\n" ..
            "Scripts have access to the simulated game state, and must return a number value in seconds (or else the addon will revert to the 'Automatic' value).",
        values = {
            auto = 'Automatic',
            script = 'Script'
        },
        get = function( info )
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )
          
          local value = Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].whenReady
          if value == nil then value = 'auto' end

          return value
        end,
      },
      ReadyTime = {
        type = 'input',
        name = 'Time Script',
        desc = 'This is an experimental feature that allows an action list author to provide additional information ' ..
            'about |cFF00D1D1when|r the criteria will be met for this ability.  While the |cFFFFD100Conditions|r above ' ..
            'tell the addon that an action should or should not be shown, when properly scripted, the |cFFFFD100Time Script|r tells ' ..
            'the addon when the entry will be ready.',
        dialogControl = "HekiliCustomEditor",
        multiline = 6,
        order = 11,
        arg = function(info)
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )
          
          local action = Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].Ability

          local results = {}

          ns.state.reset()
          results.delay = action and ns.state.action[ action ].ready_time or 0

          local ability = ns.state.class.abilities[ action ]

          if ability then
            if ability.spend then
                if type( ns.state.class.abilities[ action ].spend ) == 'function' then
                    results.cost, results.resource = ability.spend()
                else
                    results.cost, results.resource = ability.spend, ability.spend_type
                end
                results.resource = results.resource or ability.spend_type or class.primaryResource
            end
          end

          ns.storeReadyValues( results, ns.scripts.A[ listIdx..':'..actIdx ] )

          return results
        end,
        hidden = function (info)
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )

          return Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].whenReady ~= 'script'
        end,
        width = 'full',
      },
      ReadyTimeDescription = {
        type = 'description',
        name = "|cFFFFD100Time Script:|r\n" ..
            "This is an experimental feature that allows an action list author to provide additional information " ..
            "about |cFF00D1D1when|r the criteria will be met for this ability.  While the |cFFFFD100Conditions|r are " ..
            "checked when the ability is ready, a proper |cFFFFD100Time Script|r script will tell the addon |cFF00D1D1when|r " ..
            "the ability will be ready *and* its Conditions will be met.",
        hidden = function (info)
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )

          return Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].ScriptType ~= 'time'
        end,
        order = 22,
      },
      ShowModifiers = {
        type = 'toggle',
        name = 'Show Modifiers',
        desc = "Modifiers are additional action list criteria used by the addon (and often by SimulationCraft) to " ..
            "make additional decisions about what abilities to recommend.  For instance, the |cFFFFD100wait|r action " ..
            "has a modifier called |cFFFFD100sec|r that specifies (or calculates) how many seconds to wait.\n\n" ..
            "The |cFFFFD100potion|r action has a modifier of |cFFFFD100name|r to specify which potion to use.\n\n" ..
            "For most actions, no modifiers are required.",
        order = 30,
        width = 'full'
      },
      CheckMovement = {
        type = 'toggle',
        name = 'Check Movement',
        desc = "If toggled, this action will also test whether your character is currently moving when deciding " ..
            "whether to recommend this action.  You can specify whether to the action is recommended when moving or " ..
            "when stationary.",
        order = 33,
        hidden = function( info )
            local action = getActionEntry( info )
            return not action or not action.ShowModifiers
        end,
        width = 'single',
      },
      Moving = {
        type = 'select',
        name = "Show Only If...",
        desc = "When |cFFFFD100Check Movement|r is selected, this setting specifies whether the ability is recommended " ..
            "when |cFFFFD100Moving|r or when |cFFFFD100Stationary|r.",
        order = 34,
        disabled = function( info )
            local action = getActionEntry( info )
            return not action or not action.CheckMovement
        end,
        hidden = function( info )
            local action = getActionEntry( info )
            return not action or not action.ShowModifiers
        end,
        values = {
            [0] = 'Stationary',
            [1] = 'Moving'
        },
        get = function( info )
            local action = getActionEntry( info )

            if not action or not action.Moving then return 0 end
            
            return type( action.Moving ) == 'number' and action.Moving or tonumber( action.Moving )
        end,
        set = function( info, val )
            getActionEntry( info ).Moving = val
        end,
        width = 'double'
      },

      CycleTargets = {
        type = 'toggle',
        name = 'Cycle Targets',
        desc = "If toggled, this action will show an indicator to swap to another target when your current target is " ..
            "already afflicted by any debuffs applied by this ability.  For instance, if the ability in question is " ..
            "Tiger Palm for a Windwalker Monk, the addon will recommend hitting another target if your current target " ..
            "is already afflicted by Mark of the Crane (and by Eye of the Tiger, if talented).\n\n" ..
            "If a |cFFFFD100Maximum Targets|r value is specified, the addon will only recommend target swapping if/when " ..
            "fewer than |cFFFFD100Maximum Targets|r are afflicted by this ability's debuffs.",
        order = 35,
        width = 'single',
        get = function( info )
            local action = getActionEntry( info )
            return action.CycleTargets
        end,
        set = function( info, val )
            local action = getActionEntry( info )
            if not action then return end
            action.CycleTargets = val
        end,
        hidden = function( info )
            local action = getActionEntry( info )
            return not action or not action.ShowModifiers
        end,
      },
      MaximumTargets = {
        type = 'input',
        name = 'Maximum Targets',
        desc = "When |cFFFFD100Cycle Targets|r is enabled, this setting specified the maximum number of targets " ..
            "that the addon should attempt debuff using this ability.  For instance, if the ability in question is " ..
            "Tiger Palm for a Windwalker Monk, setting this value to |cFFFFD1003|r means the addon will make recommendations " ..
            "to keep Mark of the Crane applied to a maximum of 3 targets.",
        order = 36,
        width = 'double',
        -- dialogControl = "HekiliCustomEditor",
        disabled = function( info )
            local action = getActionEntry( info )
            if not action or not action.CycleTargets or action.CycleTargets == 0 then return true end
            return false
        end,
        get = function( info )
            local action = getActionEntry( info )
            if not action or not action.MaximumTargets then return "" end
            return action.MaximumTargets
        end,
        set = function( info, val )
            local action = getActionEntry( info )
            if not action then return end

            action.MaximumTargets = val:trim()
        end,
        hidden = function( info )
            local action = getActionEntry( info )
            return not action or not action.ShowModifiers
        end,
      },

      Args = { -- should rename at some point.
        type = 'input',
        name = 'Custom Modifiers',
        order = 39,
        width = 'full',
        hidden = function( info )
            local action = getActionEntry( info )
            return not action or not action.ShowModifiers
        end,
      },

      --[[ ConsumableArgs = { -- should rename at some point.
        type = 'select',
        name = 'Consumable',
        order = 30,
        width = 'full',
        values = function ()
          local v = { none = 'None' }
          for key, potion in pairs( class.potions ) do
            v[ 'name='..key ] = GetItemInfo( potion.item )
          end
          return v
        end,
        hidden = function( info )
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )

          return Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].Ability ~= 'potion'
        end
      }, ]]
      --[[ ScriptType = {
        type = 'select',
        name = 'Script Type',
        values = {
            simc = 'SimC-like Conditions',
            time = 'Time Script'
        },
        get = function( info )
          local listKey, actKey = info[2], info[3]
          local listIdx, actIdx = tonumber( listKey:match("^L(%d+)" ) ), tonumber( actKey:match("^A(%d+)" ) )
          
          local value = Hekili.DB.profile.actionLists[ listIdx ].Actions[ actIdx ].ScriptType
          if value == nil then value = 'simc' end

          return value
        end,
        order = 12,
        width = 'full',
      }, ]]
      deleteHeader = {
        type = 'header',
        name = 'Delete',
        order = 998,
      },
      Delete = {
        type = "execute",
        name = "Delete Action",
        confirm = true,
        -- confirmText = '
        order = 999,
        func		=	function(info, ...)
          -- Key to Current Display (string)
          local listKey = info[2]
          local listIdx = tonumber( match( listKey, "^L(%d+)" ) )
          local actKey = info[3]
          local actIdx = tonumber( match( actKey, "^A(%d+)" ) )

          -- Will need to be more elaborate later.
          ns.lib.AceConfigDialog:SelectGroup("Hekili", 'actionLists', listKey )
          table.remove( Hekili.DB.profile.actionLists[ listIdx ].Actions, actIdx )
          Hekili.Options.args.actionLists.args[ listKey ].args[ actKey ] = nil
          ns.loadScripts()
          ns.refreshOptions()
        end
      },
    },    
    plugins = {}
  }

  --[[ if not entry.attr then entry.attr = {} end

  local attributeOption = {}
  local attributes = 0

  local supportedAttributes = {
    target = {
        eng = "Name",
        dep = { potion = true, use_item = true } },

    cycle_targets = {
        eng = "Cycle Targets" },

    max_cycle_targets = {
        eng = "Max Cycle Targets" },

    sec = {
        eng = "Seconds",
        dep = { wait = true } },

    moving = {
        eng = "Moving" },

    line_cd = {
        eng = "Line Cooldown",
        dep = { none = true } },

    sync = {
        eng = "Synchronize with..." },

    interrupt = {
        eng = "Interrupt" },

    interrupt_if = {
        eng = "Interrupt if..." },

    interrupt_immediate = {
        eng = "Interrupt Immediate" },

    chain = {
        eng = "Chain Channel (last tick)" },

    early_chain_if = {
        eng = "Chain Channel (early)" },

    travel_speed = {
        eng = "Set Velocity" },

    wait_on_ready = {
        eng = "Wait Until Ready" },

    choose = {
        eng = "Choose Stance",
        dep = { stance = true } },
  }

  for k,v in pairs( entry.attr ) do
    attributes = attributes + 1

    attributeOption[ k ] = {
        type = 'input',
        name = k,
        order = 100 + attributes,
        width = 'full',
        get = function( info )
            return entry.attr[ k ]
        end,
        set = function( info, val )
            entry.attr[ k ] = val
        end
    }
  end

  actOption.plugins.newAttributes = attributeOption ]]

  return actOption

end


ns.ClassSettings = function ()

  local option = {
    type = 'group',
    name = "Class Settings",
    order = 20,
    args = {},
    hidden = function()
      return #class.toggles == 0 and #class.settings == 0
    end
  }

  option.args.toggles = {
    type = 'group',
    name = 'Toggles',
    order = 10,
    inline = true,
    args = {
    },
    hidden = function()
      return #class.toggles == 0
    end
  }

  for i = 1, #class.toggles do
    option.args.toggles.args[ 'Bind: ' .. class.toggles[i].name ] = {
      type = 'keybinding',
      name = class.toggles[i].option,
      desc = class.toggles[i].oDesc,
      order = ( i - 1 ) * 2
    }
    option.args.toggles.args[ 'State: ' .. class.toggles[i].name ] = {
      type = 'toggle',
      name = class.toggles[i].option,
      desc = class.toggles[i].oDesc,
      width = 'double',
      order = 1 + ( i - 1 ) * 2
    }
  end

  option.args.settings = {
    type = 'group',
    name = 'Settings',
    order = 20,
    inline = true,
    args = {},
    hidden = function()
      return #class.settings == 0
    end
  }

  for i, setting in ipairs(class.settings) do
    option.args.settings.args[ setting.name ] = setting.option
    option.args.settings.args[ setting.name ].order = i
  end

  return option

end


local importerOpts = {
  importToDisplay = false,
  destinationType = 'new',
  newDisplay = 'New Display',
  existingDisplay = 0,

  overwrite = true,
  prefix = 'Imported',
  enemies = 'any',

  APL = "Paste your SimulationCraft action priority list here.",

  warnings = nil
}


local function addWarning( s )
  if importerOpts.warnings == nil then
    importerOpts.warnings = s .. "\n"
  else
    importerOpts.warnings = importerOpts.warnings .. s .. "\n"
  end
end


function Hekili:sciGet( info, value )
  return importerOpts[ info[#info] ]
end


function Hekili:sciSet( info, value )
  importerOpts[ info[#info] ] = value
  importerOpts.warnings = nil
end

-- SimulationCraft Panel
ns.SimulationCraftImporter = function ()

  local importer = {
    type = "group",
    name = 'SimulationCraft Importer',
    get = 'sciGet',
    set = 'sciSet',
    order = 75,
    hidden = function ()
        return Hekili.AllowSimCImports ~= true
    end,
    args = {
      displayGroup = {
        type = 'group',
        name = 'Display Settings',
        order = 10,
        inline = true,
        args = {
          destinationType = {
            type = 'select',
            name = 'Destination Display',
            order = 10,
            values = {
              new = 'Create New Display',
              reuse = 'Use Existing Display',
              skip = 'Do Not Create/Modify Display'
            },
            validate = function (info, val)
              if #Hekili.DB.profile.displays == 0 and val == 'existing' then
                return "There are no existing displays to use."
              end
              return true
            end,
          },
          newDisplay = {
            type = 'input',
            name = 'New Display Name',
            order = 20,
            hidden = function ()
              return importerOpts.destinationType ~= 'new'
            end,
            validate = function (info, val)
              for i, disp in ipairs( Hekili.DB.profile.displays ) do
                if disp.Name == val then return 'A display with that name already exists.' end
              end
              return true
            end,
            width = 'double',
          },
          existingDisplay = {
            type = 'select',
            name = 'Existing Display',
            order = 20,
            hidden = function ()
              return importerOpts.destinationType ~= 'reuse'
            end,
            values = function()
              local displays = {}
              for i, disp in ipairs( Hekili.DB.profile.displays ) do
                displays[ i ] = disp.Name
              end
              if #displays == 0 then
                displays[ 0 ] = 'No Existing Displays'
              end
              return displays
            end,
            width = 'double',
          }
        }
      },
      actionListGroup = {
        type = 'group',
        name = 'Action List Settings',
        order = 15,
        inline = true,
        args = {
          overwrite = {
            type = 'toggle',
            name = 'Overwrite Existing',
            order = 5,
            desc = 'If this is checked, any existing displays with the same name will be wiped and overwritten.  If unchecked, the addon will prompt you to choose a new prefix for imported action lists.'
          },
          prefix = {
            type = 'input',
            name = 'Action List Prefix',
            order = 10,
            desc = 'Your imported action list(s) will be given a name based on their identifier in the SimulationCraft APL.  The format for a SimulationCraft action list actions.|cFFFFD100identifier|r will be converted to "|cFFFFD100prefix|r: |cFFFFD100identifier|r".\n',
            width = 'double',
          },
          enemies = {
            type = 'select',
            name = 'Target Counting',
            order = 15,
            desc = "By default, action lists will count any targets that you or your minions have targeted as enemies (|cFFFFD100active_enemies|r).  If this is set to |cFFFFD100Only My Enemies|r, then the imported action lists will only count targets that you have directly injured yourself (|cFFFFD100my_enemies|r).\n\nThis is particularly useful for classes that have abilities with effects based on the number of enemies hit.  For example, Spinning Crane Kick will generate Chi if you hit 3 or more targets.",
            values = { any = 'All Detected Enemies',
              strict = 'Only My Enemies' }
          },
        }
      },
      APL = {
        type = 'input',
        name = 'SimulationCraft APL',
        -- dialogControl = "HekiliCustomEditor",
        multiline = 4,
        order = 1,
        width = 'full'
      },
      Import = {
        type = 'execute',
        name = 'Import Action Lists',
        order = 25,
        func = function ()
          local APL = '\n'..importerOpts.APL
          local lists = {}
          local hooks = { [1] = "precombat,if=time=0", [2] = "default" }
          local elems = 0

          importerOpts.warnings = nil

          if importerOpts.importToDisplay and importerOpts.destinationType == 'new' then
            for i, disp in ipairs( Hekili.DB.profile.displays ) do
              if disp.Name == importerOpts.newDisplay then
                addWarning( "If importing to a new display, you must specify an new (unused) display name." )
                -- Hekili:Print( "If importing to a new display, you must specify an new (unused) display name." )
                return
              end
            end
          end

          -- name the default action list.
          APL = APL:gsub( "actions(%+?)=", "actions.default%1=" )
          
          if importerOpts.enemies == 'strict' then
            APL = APL:gsub( "active_enemies", "my_enemies" )
          end

          APL = APL:gsub( "spell_targets%.[a-zA-Z0-9_]+", importerOpts.enemies == 'string' and "my_enemies" or "active_enemies" )

          -- gather other lists
          for list, action in APL:gmatch( "\nactions%.(%S-)%+?=/?([^\n^$]*)" ) do
            list = ns.titlefy( list )

            lists[ list ] = lists[ list ] or {
              status = 'active',
              current = 1,
              [1] = ""
            }

            if lists[ list ].status == 'calling' then
              --w we are returning to an action list after calling some hooks, we need a new list fragment.
              lists[ list ].status = 'active'
              lists[ list ][ lists[ list ].current ] = ""

              local previous_list
              if lists[ list ].current == 2 then
                previous_list = list
              else
                previous_list = list .. " (" .. lists[ list ].current - 1 .. ")"
              end

              -- find the last hook for our previous list and duplicate its hook.
              -- note, if the previous list isn't found, the new fragment won't get hooked...
              for i = #hooks, 1, -1 do
                if hooks[ i ]:match( previous_list ) then
                  local new_hook = hooks[ i ]:gsub( previous_list, list .. " (" .. lists[ list ].current .. ")" )
                  table.insert( hooks, new_hook )
                  break
                end
              end
            end

            if action:sub( 1, 6 ) == "potion" then
                local pot = action:match( "name=(.-),")
                pot = pot or action:match( "name=(.-)$" )
                action = action:gsub( pot, "\""..pot.."\"" )
            end
              
            if action:sub( 1, 16 ) == "call_action_list" or action:sub( 1, 15 ) == "run_action_list" then
              local called = action:match( "name=[\"]?(.-)[\"]?," )
              if not called then called = action:match( "name=[\"]?(.-)[\"]?$" ) end
              if called then
                local updated = importerOpts.prefix .. ': ' .. ns.titlefy( called )
                action = action:gsub( "name=[\"]?"..called.."[\"]?", "name=\""..updated.."\"" )
              end
            end
            
            lists[ list ][ lists[ list ].current ] = lists[ list ][ lists[ list ].current ] .. 'actions+=/' .. action .. '\n'
          end
          --end

          if not lists.default then
            table.remove( hooks, 2 )
          end

          if not lists.precombat then
            table.remove( hooks, 1 )
          end
          
          local count = 0

          for k, v in pairs( lists ) do
            for i, sublist in ipairs( v ) do
              local new_list = k .. ( i > 1 and " (" .. i .. ")" or "" )

              local import, warning = Hekili:ImportSimulationCraftActionList( sublist, importerOpts.enemies == 'strict' and 'my_enemies' or 'active_enemies' )

              if warning then
                addWarning( "WARNING:  The import for '" .. new_list .. "' required modifications:" )
                for i = 1, #warning do
                  addWarning( warning[i] )
                end
                addWarning( "" )
              end

              if not import then
                addWarning( "No actions from '" .. new_list .. "' were successfully imported." )
              end

              local target = 0
              for i, list in ipairs( Hekili.DB.profile.actionLists ) do
                if list.Name == importerOpts.prefix .. ': ' .. new_list then
                  table.wipe( list.Actions )
                  target = i
                end
              end

              if target == 0 then
                local success = ns.newActionList( #Hekili.DB.profile.actionLists + 1 )
                if success then target = #Hekili.DB.profile.actionLists end
              end

              local list = Hekili.DB.profile.actionLists[ target ]
              list.Name = importerOpts.prefix .. ': ' .. new_list
              list.Enabled = true

              if import then
                for i, entry in ipairs( import ) do

                  local ability = class.abilities[ entry.Ability ]

                  local key = ns.newAction( target, ability.name )

                  local action = list.Actions[ i ]

                  action.Ability = entry.Ability
                  action.Args = entry.Args

                  action.CycleTargets = entry.CycleTargets
                  action.MaximumTargets = entry.MaximumTargets
                  action.CheckMovement = entry.CheckMovement or false
                  action.Moving = entry.Moving
                  action.ModName = entry.ModName or ''

                  --[[ if entry.Args then
                    local cycle = entry.Args:match("cycle_targets=1")
                    local target = entry.Args:match("target=(%d+)")
                    if target then target = tonumber( target ) end

                    if cycle or ( target and target > 1 ) then
                      action.Indicator = "cycle"
                    end
                  else
                    action.Indicator = "none"
                  end ]]

                  if ability.toggle then
                    if entry.Script and entry.Script:len() > 0 then
                      action.Script = 'toggle.' .. ability.toggle .. '&(' .. entry.Script .. ')'
                    else
                      action.Script = 'toggle.' .. ability.toggle
                    end
                  else
                    action.Script = entry.Script
                  end
                  
                  if entry.Ability == 'heroism' or entry.Ability == 'bloodlust' then
                    addWarning( "Found " .. entry.Ability .. " in " .. list.Name .. " (#" .. i .. ").  This entry is disabled.  You can manually enable it if so desired." )
                    action.Enabled = false
                  else
                    action.Enabled = true
                  end
                end
                count = count + 1
              end
            end
          end
          
          if count == 0 then
            addWarning("No action lists were imported from the above APL.")
          else
            addWarning( count .. " action lists imported.")
          end

          if importerOpts.destinationType ~= 'skip' then
            local display, dispIdx

            if importerOpts.destinationType == 'new' then
              if not importerOpts.newDisplay or importerOpts.newDisplay == '' then
                addWarning( "You must specify a new display name." )
                return
              end

              display, dispIdx = ns.newDisplay( importerOpts.newDisplay )

              if display then
                display = Hekili.DB.profile.displays[ dispIdx ]
                C_Timer.After( 1 / Hekili.DB.profile['Updates Per Second'], Hekili[ 'ProcessDisplay'..dispIdx ] )
              else
                addWarning( "Failed to create a new display with name '" ..importerOpts.newDisplay .. "'." )
                return
              end

            elseif importerOpts.destinationType == 'reuse' then
              dispIdx = importerOpts.existingDisplay
              display = Hekili.DB.profile.displays[ dispIdx ]

              if not display then
                addWarning( "The existing display was not found." )
                return
              end

              -- wipe existing hooks.
              for i = #display.Queues, 1, -1 do
                table.remove( display.Queues, i )
              end

            end

            if #hooks > 0 then
              for i = 1, #hooks do
                local name, criteria = hooks[i]:match( "^(.*),if=(.-)$" )
                name = ns.titlefy( name or hooks[i] ) -- no criteria

                local _, hookIdx = ns.newHook( dispIdx, importerOpts.prefix .. ': ' .. name )
                display.Queues[ i ].Script = criteria

                for l, list in ipairs( Hekili.DB.profile.actionLists ) do
                  if list.Name == importerOpts.prefix .. ': ' .. name then
                    display.Queues[ i ]['Action List'] = l
                    display.Queues[ i ].Enabled = true
                  end
                end

              end
            end
          end

          ns.refreshOptions()
          ns.loadScripts()
          ns.buildUI()
          ns.cacheCriteria()

          -- ns.lib.AceConfigDialog:SelectGroup( "Hekili", "SimulationCraftImporter" )

        end
      },
      spacer = {
        type = 'description',
        name = ' ',
        order = 26,
        width = 'double',
      },
      warnings = {
        type = 'input',
        name = "Warnings",
        multiline = 4,
        width = 'full',
        order = 30,
        hidden = function ()
          return importerOpts.warnings == nil
        end
      },
    }
  }

  return importer

end





local optionBuffer = {}

local buffer = function( msg )
  optionBuffer[ #optionBuffer + 1 ] = msg
end

local getBuffer = function()
  local output = table.concat( optionBuffer )
  table.wipe( optionBuffer )
  return output
end

local getColoredName = function( tab )
  if not tab then return '(none)'
  elseif tab.Default then return '|cFF00C0FF' .. tab.Name .. '|r'
  else return '|cFFFFC000' .. tab.Name .. '|r' end
end


function Hekili:GetOptions()
  local Options = {
    name = "Hekili",
    type = "group",
    handler = Hekili,
    get = 'GetOption',
    set = 'SetOption',
    childGroups = "tree",
    args = {
      welcome = {
        type = "group",
        name = "Welcome",
        order = 10,
        args = {
          headerWarn = {
            type = 'description',
            name	=	"Welcome to Hekili v7 for |cFF00FF00Legion|r.  This addon's default settings will give you similar behavior to the original version. " ..
            'Please report bugs to hekili.tcn@gmail.com / @Hekili808 on Twitter / Hekili on MMO-C.\n',
            order = 0,
          },
          gettingStarted = {
            type = 'description',
            name = "|cFFFFD100Getting Started|r\n\n" ..
            "By default, this addon has two displays.  The primary display is a hybrid display that will display a single-target, cleave, or AOE priority list depending on the number of targets that have been detected.  " ..
            "For greater control over the primary display, you may want to adjust the |cFFFFD100Mode Switch|r settings found in the |cFFFFD100Toggles|r section of the options.  You can bind a key that will manually swap " ..
            "the primary display between fixed single-target mode, automatic mode, or fixed AOE mode.\n\n" ..
            "When the primary display is in fixed single-target mode, a second display may appear (if configured) that will show AOE recommendations.\n\n" ..
            "Additionally, by default, most major cooldowns are excluded from the action lists.  To enable them, it is strongly recommend that you bind a key in the |cFFFFD100Toggles|r section for |cFFFFD100Show Cooldowns|r.  " ..
            "This will enable you to tell the addon when you do (or do not) want to have your cooldowns recommended.\n\n" ..
            "There are additional |cFFFFD100Class Settings|r you can use to adjust preferences on for your class or specialization.  Read the tooltips for more information.\n\n" ..
            "Finally, there are many options that can be changed on a per-display basis.  Check the |cFFFFD100Displays|r section, click the display in question, and check the |cFFFFD100UI and Style|r section to explore the " ..
            "available options for customization.\n",
            order = 1,
          },
          whatsNew = {
            type = 'description',
            name = "|cFFFFD100What's New!|r\n\n" ..
            "|cFF00FF00Monks!|r - Windwalker and Brewmaster Monks are supported through an additional class module.  You can download it from http://curse.com/addons/wow/hekili-monks/.",
            order = 2
          },
          endCap = { -- just here to trigger scrolling if needed.
            type = 'description',
            name = ' ',
            order = 3
          }

        }
      },
      general = {
        type = "group",
        name = "General",
        order = 15,
        args = {
          Enabled = {
            type = "toggle",
            name = "Enabled",
            desc = "Enables or disables the addon.",
            order = 1
          },
          Locked = {
            type = "toggle",
            name = "Locked",
            desc = "Locks or unlocks all displays for movement, except when the options window is open.",
            order = 2
          },
          Debug = {
            type = "toggle",
            name = "Debug",
            desc = "If checked, the addon will collect additional information that you can view by pausing the addon and placing your mouse over your displayed abilities.",
            order = 3
          },
          ['Counter'] = {
            type = "group",
            name = "Target Count",
            inline = true,
            order = 5,
            args = {
              ['Delay Description'] = {
                type = 'description',
                name = "This addon includes a mechanism for counting targets with whom you are actively engaged.  Targets can be detected via nameplates, or by tracking any target that you damage, or is damaged by your pets/totems/guardians.  You can specify how targets are counted below.  Targets using damage-based detection are removed when they are killed or if you do not damage them within the following 'Grace Period'.",
                order = 0,
                width = 'full'
              },
              ['Count Nameplate Targets'] = {
                type = 'toggle',
                name = "Count Targets by Nameplate",
                desc = "If checked, the addon will check to see how many hostile nameplates are within the specified range and count them as enemies.\n\n" ..
                    "If enemy nameplates are not enabled, the addon will fallback to damage-based detection regardless of these settings.\n\n" ..
                    "This feature is not used by ranged specializations.",
                order = 1,

              },
              ['Nameplate Detection Range'] = {
                type = 'range',
                name = 'Nameplate Detection Range',
                desc = "When |cFFFFD100Count Nameplate Targets|r is checked, the addon will count enemy nameplates within this many yards as active enemies.\n\n" ..
                    "This value will 'snap' to valid enemy ranges that can be used for target detection.",
                min = 5,
                max = 100,
                step = 1,
                set = function( info, val )
                    -- local values = { [5] = 5, [6] = 6, [8] = 8, [10] = 10, [15] = 15, [20] = 20, [25] = 25, [30] = 30, [35] = 35, [40] = 40, [45] = 45, [50] = 50, [60] = 60, [70] = 70, [80] = 80, [100] = 100 }
                    local values = { 5, 6, 8, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 100 }

                    local closest, difference = 0, 100

                    for _, value in ipairs( values ) do
                        local diff = abs( val - value )
                        if diff < difference then
                            closest = value
                            difference = diff
                        end

                        if closest > val then break end
                    end

                    Hekili.DB.profile['Nameplate Detection Range'] = closest
                end,
                order = 2,
                width = 'double',
              },
              ['Count Targets by Damage'] = {
                type = 'toggle',
                name = 'Count Targets by Damage',
                desc = "If checked, the addon will track which units you have recently attacked or have recently attacked you and count them as enemies.\n\n" ..
                    "If nameplate target detection is turned off, this feature will be used regardless of this setting.\n\n" ..
                    "For ranged specializations, this feature is always active.",
                order = 3,
              },
              ['Audit Targets'] = {
                type = 'range',
                name = "Grace Period",
                min = 3,
                max = 20,
                step = 1,
                width = 'double',
                order = 4
              },
            }
          },
          ['Engine'] = {
            type = "group",
            name = "Engine Settings",
            inline = true,
            order = 4,
            args = {
              ['Engine Description'] = {
                type = 'description',
                name = "Set the frequency with which you want the addon to update your priority displays.  More frequent updates require more processor time (and can impact your frame rate); less frequent updates use less CPU, but may cause the display to be sluggish or to respond slowly to game events.  The default setting is 10 updates per second.",
                order = 0
              },
              ['Updates Per Second'] = {
                type = 'range',
                name = "Updates Per Second",
                min = 4,
                max = 40,
                step = 1,
                width = 'full',
                order = 1
              },
              ['Recommendation Window'] = {
                type = 'range',
                name = "Recommendation Window",
                min = 0,
                max = 0.25,
                step = 0.01,
                width = 'full',
                order = 2
              }
            }
          },
          ['Clash'] = {
            type = "group",
            name = "Cooldown Clash",
            inline = true,
            order = 6,
            args = {
              ['Clash Description'] = {
                type = 'description',
                name = "When recommending abilities, the addon prioritizes the action that is available soonest and with passing criteria.  Sometimes, a lower priority action will be recommended over a higher priority action because the lower priority action will be available slightly sooner.  By setting a Cooldown Clash value greater than 0, the addon will recommend a lower priority action only if it is available at least this much sooner than a higher priority ability.  Some classes may have specific clash settings for specific abilities, overriding this setting.",
                order = 0
              },
              ['Clash'] = {
                type = 'range',
                name = "Clash",
                min = 0,
                max = 0.5,
                step = 0.01,
                width = 'full',
                order = 1
              }
            }
          },
        }
      },
      notifs = {
        type = "group",
        name = "Notifications",
        childGroups = "tree",
        cmdHidden = true,
        order = 40,
        args = {
          ['Notification Enabled'] = {
            type = 'toggle',
            name = "Show Notifications",
            desc = "Show a frame where some updates will be posted during combat (e.g., 'Cooldowns ON' when you press your Cooldown toggle key).",
            order = 1,
            width = 'full',
          },
          ['Notification X'] = {
            type = 'input',
            name = 'Position (X)',
            desc = "Enter the horizontal position of the notification panel relative to the center of your screen.",
            order = 2,
          },
          ['Notification Y'] = {
            type = 'input',
            name = 'Position (Y)',
            desc = "Enter the vertical position of the notification panel relative to the center of your screen.",
            order = 3,
          },
          blank1 = {
            type = 'description',
            name = ' ',
            order = 4,
          },
          ['Notification Width'] = {
            type = 'range',
            name = 'Panel Width',
            desc = "Select the width of the panel in pixels.",
            order = 4,
            min = 25,
            max = 2500,
            step = 1,
          },
          ['Notification Height'] = {
            type = 'range',
            name = 'Panel Height',
            desc = "Select the height of the panel in pixels.",
            order = 5,
            min = 10,
            max = 500,
            step = 1,
          },
          blank2 = {
            type = 'description',
            name = ' ',
            order = 6
          },
          ['Notification Font'] = {
            type = 'select',
            name = 'Font',
            desc = "Select the font to use in the Notification panel.",
            dialogControl = 'LSM30_Font',
            order = 7,
            values = ns.lib.SharedMedia:HashTable("font"), -- pull in your font list from LSM
          },
          ['Notification Font Size'] = {
            type = 'range',
            name = "Font Size",
            desc = "Select the height of the notification text.",
            order = 8,
            min = 8,
            max = 200,
            step = 1
          },
        },
      },
      displays = {
        type = "group",
        name = "Displays",
        childGroups = "tree",
        cmdHidden = true,
        order = 50,
        args = {
          header = {
            type = "description",
            name = "A display is a group of 1 to 10 icons.  Each display can multiple hooks for action lists, with customized criteria and actions for display.",
            order = 0
          },
          ['New Display'] = {
            type = "input",
            name = "New Display",
            desc = 'Enter a new display name.  Default options will be used.',
            width = 'full',
            validate = function(info, val)
              if val == '' then return true end
              for k,v in pairs(Hekili.DB.profile.displays) do
                if val == v.name then
                  Hekili:Print("That name is already in use.")
                  return "That name is already in use."
                end
              end
              return true
            end,
            order = 1
          },
          ['Import Display'] = {
            type = "input",
            name = "Import Display",
            desc = "Paste a display's export string to import it here.",
            width = 'full',
            order = 2,
            multiline = 6,
          },
          footer = {
            type = "description",
            name = "   ",
            order = 3
          },
          Reload = {
            type = "execute",
            name = "Reload Missing",
            desc = "Reloads all missing default displays.",
            confirm = true,
            confirmText = "Restore any deleted default displays?",
            order = 4,
            func = function( info, ... )
              local exists = {}

              for i, display in ipairs( Hekili.DB.profile.displays ) do
                exists[ display.Name ] = true
              end

              for i, default in ipairs( class.defaults ) do
                if not exists[ default.name ] and default.type == 'displays' then
                  local import = ns.deserializeDisplay( default.import )
                  local index = #Hekili.DB.profile.displays + 1

                  if import then
                    Hekili.DB.profile.displays[ index ] = import
                    Hekili.DB.profile.displays[ index ].Name = default.name
                    Hekili.DB.profile.displays[ index ].Release = default.version
                    Hekili.DB.profile.displays[ index ].Default = true

                    if not Hekili[ 'ProcessDisplay' .. index ] then
                      Hekili[ 'ProcessDisplay' .. index ] = function()
                        Hekili:ProcessHooks( index )
                      end
                      C_Timer.After( 2 / Hekili.DB.profile['Updates Per Second'], Hekili[ 'ProcessDisplay' .. index ] )
                    end
                  else
                    Hekili:Print("Unable to import " .. default.name .. ".")
                  end
                end
              end

              ns.checkImports()
              ns.refreshOptions()
              ns.loadScripts()
              ns.buildUI()
            end,
          },
          ReloadAll = {
            type = "execute",
            name = "Reload All",
            desc = "Reloads all default displays.",
            confirm = true,
            confirmText = "Restore all default displays?",
            order = 5,
            func = function( info, ... )
              local exists = {}

              for i, display in ipairs( Hekili.DB.profile.displays ) do
                exists[ display.Name ] = i
              end

              for i, default in ipairs( class.defaults ) do
                if default.type == 'displays' then
                  local import = ns.deserializeDisplay( default.import )
                  local index = exists[ default.name ] or #Hekili.DB.profile.displays + 1

                  if import then
                    if exists[ default.name ] then
                      local settings_to_keep = { "Primary Icon Size", "Queued Font Size", "Primary Font Size", "Primary Caption Aura", "rel", "Spacing", "Queue Direction", "Queued Icon Size", "Font", "x", "y", "Icons Shown", "Action Captions", "Primary Caption", "Primary Caption Aura", "PvE - Default", "PvE - Default Alpha", "PvE - Target", "PvE - Target Alpha", "PvE - Combat", "PvE - Combat Alpha", "PvP - Default", "PvP - Default Alpha", "PvP - Target", "PvP - Target Alpha", "PvP - Combat", "PvP - Combat Alpha" }

                      for _, k in pairs( settings_to_keep ) do
                        import[ k ] = Hekili.DB.profile.displays[ index ][ k ]
                      end
                    end

                    Hekili.DB.profile.displays[ index ] = import
                    Hekili.DB.profile.displays[ index ].Name = default.name
                    Hekili.DB.profile.displays[ index ].Release = default.version
                    Hekili.DB.profile.displays[ index ].Default = true

                    if not Hekili[ 'ProcessDisplay' .. index ] then
                      Hekili[ 'ProcessDisplay' .. index ] = function()
                        Hekili:ProcessHooks( index )
                      end
                      C_Timer.After( 2 / Hekili.DB.profile['Updates Per Second'], Hekili[ 'ProcessDisplay' .. index ] )
                    end
                  else
                    Hekili:Print("Unable to import " .. default.name .. ".")
                  end
                end
              end

              ns.refreshOptions()
              ns.loadScripts()
              ns.buildUI()
            end,
          },
        }
      },
      actionLists = {
        type = "group",
        name = "Action Lists",
        childGroups = "tree",
        cmdHidden = true,
        order = 60,
        args = {
          header = {
            type = "description",
            name = "Each action list is a selection of several abilities and the conditions for using them.",
            order = 10
          },
          ['New Action List'] = {
            type = "input",
            name = "New Action List",
            desc = "Enter a name for this action list and press ENTER.",
            width = "full",
            validate = function(info, val)
              if val == '' then return true	end
              for k,v in pairs(Hekili.DB.profile.actionLists) do
                if val == v.Name then
                  Hekili:Print("That name is already in use.")
                  return "That name is already in use."
                end
              end

              return true
            end,
            order = 20
          },
          ['Import Action List'] = {
            type = "input",
            name = "Import Action List",
            desc = "Paste an action list's export string to import it here.",
            width = 'full',
            order = 30,
            multiline = 6,
          },
          footer = {
            type = "description",
            name = "   ",
            order = 35
          },
          Reload = {
            type = "execute",
            name = "Reload Missing",
            desc = "Reloads all missing default action lists.",
            confirm = true,
            confirmText = "Restore any deleted default action lists?",
            order = 40,
            func = function( info, ... )
              local exists = {}

              for i, list in ipairs( Hekili.DB.profile.actionLists ) do
                exists[ list.Name ] = true
              end

              for i, default in ipairs( class.defaults ) do
                if not exists[ default.name ] and default.type == 'actionLists' then
                  local import = ns.deserializeActionList( default.import )
                  local index = #Hekili.DB.profile.actionLists + 1

                  if import then
                    Hekili.DB.profile.actionLists[ index ] = import
                    Hekili.DB.profile.actionLists[ index ].Name = default.name
                    Hekili.DB.profile.actionLists[ index ].Release = default.version
                    Hekili.DB.profile.actionLists[ index ].Default = true
                  else
                    Hekili:Print("Unable to import " .. default.name .. ".")
                    return
                  end
                end
              end

              ns.refreshOptions()
              ns.loadScripts()
            end,
          },
          ReloadAll = {
            type = "execute",
            name = "Reload All",
            desc = "Reloads all default action lists.",
            confirm = true,
            confirmText = "Restore all default action lists?",
            order = 41,
            func = function( info, ... )
              local exists = {}

              for i, list in ipairs( Hekili.DB.profile.actionLists ) do
                exists[ list.Name ] = i
              end

              for i, default in ipairs( class.defaults ) do
                if default.type == 'actionLists' then
                  local index = exists[ default.name ] or #Hekili.DB.profile.actionLists+1

                  local import = ns.deserializeActionList( default.import )

                  if import then
                    Hekili.DB.profile.actionLists[ index ] = import
                    Hekili.DB.profile.actionLists[ index ].Name = default.name
                    Hekili.DB.profile.actionLists[ index ].Release = default.version
                    Hekili.DB.profile.actionLists[ index ].Default = true
                  else
                    Hekili:Print("Unable to import " .. default.name .. ".")
                    return
                  end
                end
              end

              ns.refreshOptions()
              ns.loadScripts()
            end,
          },
        }
      },
      bindings = {
        type = 'group',
        name = 'Toggles',
        desc = "Formerly 'Filters and Keybinds'",
        order = 15,
        childGroups = 'tab',
        args = {
          default = {
            type = 'group',
            name = 'Default Filters',
            order = 0,
            args = {
              HEKILI_TOGGLE_PAUSE = {
                type = 'keybinding',
                name = 'Pause',
                desc = "Set a key to pause processing of your action lists.  Your current display(s) will freeze, and you can mouseover each icon to see information about the displayed action.",
                order = 10,
              },
              Pause = {
                type = 'toggle',
                name = 'Pause',
                order = 11,
                width = 'double',
              },
              HEKILI_TOGGLE_MODE = {
                type = 'keybinding',
                name = 'Mode Switch',
                desc = "Pressing this key will tell the addon to change how it handles the priority lists in the primary display, if your displays and action lists are configured to take advantage of this feature.\n" ..
                "|cFFFFD100Auto:|r\nPressing this key will switch between single-target and automatic detection of single-target vs. cleave vs. AOE.\n" ..
                "|cFFFFD100Manual:|r\nPressing this key will switch between single-target and AOE.  Cleave action lists will not be used.\n",
                order = 20,
              },
              ['Switch Type'] = {
                type = 'select',
                name = 'Switch Type',
                desc = "|cFFFFD100Auto / Single-Target:|r\nPressing the Mode Switch keybind will switch between strict single target (1 enemy) vs. using auto-detection to count active enemies.\n" ..
                "|cFFFFD100Single-Target / AOE:|r\nPressing this key will switch between single-target and AOE.  AOE is defined as a minimum of 3 targets for default displays.\n",
                values = {
                  [0] = 'Single-Target <-> Auto',
                  [1] = 'Single-Target <-> AOE',
                },
                order = 21,
              },
              ['Mode Status'] = {
                type = 'select',
                name = 'Current Mode',
                desc = "Based upon the Switch Type, this setting can switch between single-target, AOE, or auto-detection of enemies.",
                values = function(info, val)
                  if Hekili.DB.profile['Switch Type'] == 2 then
                    return { [0] = 'Single-Target', [1] = 'Cleave', [2] = 'AOE' }
                  elseif Hekili.DB.profile['Switch Type'] == 1 then
                    return { [0] = 'Single-Target', [2] = 'AOE' }
                  elseif Hekili.DB.profile['Switch Type'] == 0 then
                    return { [0] = 'Single-Target', [3] = 'Auto-Detect' }
                  end
                end,
                order = 22
              },
              HEKILI_TOGGLE_COOLDOWNS = {
                type = 'keybinding',
                name = 'Cooldowns',
                desc = 'Set a key for toggling cooldowns on and off.  This option is used by testing the criterion |cFFFFD100toggle.cooldowns|r in your condition scripts.',
                order = 30
              },
              Cooldowns = {
                type = 'toggle',
                name = 'Show Cooldowns',
                order = 31,
                -- width = 'double'
              },
              BloodlustCooldowns = {
                type = 'toggle',
                name = 'Bloodlust Override',
                desc = "When checked, the addon will also show cooldowns when Bloodlust (Heroism, Time Warp, etc.) is active, even if Show Cooldowns is disabled.",
                order = 32,
              },
              HEKILI_TOGGLE_POTIONS = {
                type = 'keybinding',
                name = 'Potions',
                desc = 'Set a key for toggling potions on and off.  Potion handling is handled by the addon and does not need to be included in your condition scripts.',
                order = 35,
              },
              Potions = {
                type = 'toggle',
                name = 'Show Potions',
                order = 36,
                width = 'double',
              },
              HEKILI_TOGGLE_INTERRUPTS = {
                type = 'keybinding',
                name = 'Interrupts',
                desc = 'Set a key for toggling interrupts on and off.  This option is used by testing the criterion |cFFFFD100toggle.interrupts|r in your condition scripts.',
                order = 50
              },
              Interrupts = {
                type = 'toggle',
                name = 'Show Interrupts',
                order = 51,
                width = 'double'
              },
            }
          },
          custom = {
            type = 'group',
            name = 'Custom Filters',
            order = 10,
            args = {
              HEKILI_TOGGLE_1 = {
                type = 'keybinding',
                name = 'Toggle 1',
                order = 10
              },
              ['Toggle 1 Name'] = {
                type = 'input',
                name = 'Alias',
                desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.one|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
                order = 12,
                validate = function(info, val)
                  if val == '' then
                    return true
                  elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
                    Hekili:Print("'" .. val .. "' is a reserved toggle name.")
                    return "'" .. val .. "' is a reserved toggle name."
                  end

                  if match(val, "[^a-z]") then
                    Hekili:Print("Toggle names must be all lowercase alphabet characters.")
                    return "Toggle names must be all lowercase alphabet characters."

                  else
                    local this = tonumber( info[#info]:match('Toggle (%d) Name') )

                    for i = 1, 5 do
                      if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
                        Hekili:Print("That name is already in use.")
                        return "That name is already in use."
                      end
                    end

                  end

                  return true
                end,
              },
              Toggle_1 = {
                type = 'toggle',
                name = 'Enabled',
                desc = 'Toggle the current state of this custom toggle.',
                order = 12,
              },
              HEKILI_TOGGLE_2 = {
                type = 'keybinding',
                name = 'Toggle 2',
                order = 20
              },
              ['Toggle 2 Name'] = {
                type = 'input',
                name = 'Alias',
                desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.two|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
                order = 21,
                validate = function(info, val)
                  if val == '' then
                    return true
                  elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
                    Hekili:Print("'" .. val .. "' is a reserved toggle name.")
                    return "'" .. val .. "' is a reserved toggle name."
                  end

                  if match(val, "[^a-z]") then
                    Hekili:Print("Toggle names must be all lowercase alphabet characters.")
                    return "Toggle names must be all lowercase alphabet characters."

                  else
                    local this = tonumber( info[#info]:match('Toggle (%d) Name') )

                    for i = 1, 5 do
                      if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
                        Hekili:Print("That name is already in use.")
                        return "That name is already in use."
                      end
                    end

                  end

                  return true
                end,
              },
              Toggle_2 = {
                type = 'toggle',
                name = 'Enabled',
                desc = 'Toggle the current state of this custom toggle.',
                order = 22,
              },
              HEKILI_TOGGLE_3 = {
                type = 'keybinding',
                name = 'Toggle 3',
                order = 30
              },
              ['Toggle 3 Name'] = {
                type = 'input',
                name = 'Alias',
                desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.three|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
                order = 31,
                validate = function(info, val)
                  if val == '' then
                    return true
                  elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
                    Hekili:Print("'" .. val .. "' is a reserved toggle name.")
                    return "'" .. val .. "' is a reserved toggle name."
                  end

                  if match(val, "[^a-z]") then
                    Hekili:Print("Toggle names must be all lowercase alphabet characters.")
                    return "Toggle names must be all lowercase alphabet characters."

                  else
                    local this = tonumber( info[#info]:match('Toggle (%d) Name') )

                    for i = 1, 5 do
                      if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
                        Hekili:Print("That name is already in use.")
                        return "That name is already in use."
                      end
                    end

                  end

                  return true
                end,
              },
              Toggle_3 = {
                type = 'toggle',
                name = 'Enabled',
                desc = 'Toggle the current state of this custom toggle.',
                order = 32,
              },
              HEKILI_TOGGLE_4 = {
                type = 'keybinding',
                name = 'Toggle 4',
                order = 40
              },
              ['Toggle 4 Name'] = {
                type = 'input',
                name = 'Alias',
                desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.four|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
                order = 41,
                validate = function(info, val)
                  if val == '' then
                    return true
                  elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
                    Hekili:Print("'" .. val .. "' is a reserved toggle name.")
                    return "'" .. val .. "' is a reserved toggle name."
                  end

                  if match(val, "[^a-z]") then
                    Hekili:Print("Toggle names must be all lowercase alphabet characters.")
                    return "Toggle names must be all lowercase alphabet characters."

                  else
                    local this = tonumber( info[#info]:match('Toggle (%d) Name') )

                    for i = 1, 5 do
                      if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
                        Hekili:Print("That name is already in use.")
                        return "That name is already in use."
                      end
                    end

                  end

                  return true
                end,
              },
              Toggle_4 = {
                type = 'toggle',
                name = 'Enabled',
                desc = 'Toggle the current state of this custom toggle.',
                order = 42,
              },
              HEKILI_TOGGLE_5 = {
                type = 'keybinding',
                name = 'Toggle 5',
                order = 50
              },
              ['Toggle 5 Name'] = {
                type = 'input',
                name = 'Alias',
                desc = 'Set a unique alias for this custom toggle.  You can check to see if this toggle is active by testing the criterion |cFFFFD100toggle.five|r or |cFFFFD100toggle.<alias>|r.  Aliases must be all lowercase, with no spaces.',
                order = 51,
                validate = function(info, val)
                  if val == '' then
                    return true
                  elseif val == 'cooldowns' or val == 'hardcasts' or val == 'mode' or val == 'interrupts' then
                    Hekili:Print("'" .. val .. "' is a reserved toggle name.")
                    return "'" .. val .. "' is a reserved toggle name."
                  end

                  if match(val, "[^a-z]") then
                    Hekili:Print("Toggle names must be all lowercase alphabet characters.")
                    return "Toggle names must be all lowercase alphabet characters."

                  else
                    local this = tonumber( info[#info]:match('Toggle (%d) Name') )

                    for i = 1, 5 do
                      if i ~= this and val == Hekili.DB.profile['Toggle ' .. i .. ' Name'] then
                        Hekili:Print("That name is already in use.")
                        return "That name is already in use."
                      end
                    end

                  end

                  return true
                end,
              },
              Toggle_5 = {
                type = 'toggle',
                name = 'Enabled',
                desc = 'Toggle the current state of this custom toggle.',
                order = 52,
              },
            }
          }
        }
      },
      make_defaults = {
        type = 'group',
        name = 'Defaults',
        -- desc = "",
        order = 99,
        childGroups = 'tab',
        hidden = function()
          return not Hekili.MakeDefaults
        end,
        args = {
          defaults = {
            type = "input",
            name = "Export Defaults",
            desc = "A full export of class defaults can be copied from here and pasted into the appropriate class module.",
            width = 'full',
            order = 1,
            get = function ()
              local out = ''
              
              for i, list in ipairs( Hekili.DB.profile.actionLists ) do
                out = out .. "    storeDefault( [[" .. list.Name .. "]], 'actionLists', " .. date("%Y%m%d.1") .. ", [[" .. ns.serializeActionList( i ) .. "]] )\n\n"
              end
              
              out = out .. "\n"
              
              for i, display in ipairs( Hekili.DB.profile.displays ) do
                out = out .. "    storeDefault( [[" .. display.Name .. "]], 'displays', " .. date("%Y%m%d.1") .. ", [[" .. ns.serializeDisplay( i ) .. "]] )\n\n"
              end
              
              return out
            end,
            set = function ()
              return
            end,
            multiline = 29
          }
        }
      }
    }
  }

  for i, v in ipairs(Hekili.DB.profile.displays) do
    local dispKey = 'D' .. i
    Options.args.displays.args[ dispKey ] = ns.newDisplayOption( i )

    if v.Queues then
      for key, value in ipairs( v.Queues ) do
        Options.args.displays.args[ dispKey ].args[ 'P' .. key ] = ns.newHookOption( i, key )
      end
    end

  end

  for i,v in ipairs(Hekili.DB.profile.actionLists) do
    local listKey = 'L' .. i
    Options.args.actionLists.args[ listKey ] = ns.newActionListOption( i )

    if v.Actions then
      for key, value in ipairs( v.Actions ) do
        --				Options.args.actionLists.args[ listKey ].args['Actions'].args[ 'A' .. key ] = ns.newActionOption( i, key )
        Options.args.actionLists.args[ listKey ].args[ 'A' .. key ] = ns.newActionOption( i, key )
      end
    end

  end

  return Options
end


function Hekili:TotalRefresh()

  restoreDefaults()

  for i, queue in ipairs( ns.queue ) do
    for j, _ in pairs( queue ) do
      ns.queue[i][j] = nil
    end
    ns.queue[i] = nil
  end

  callHook( "onInitialize" )
  
  for k, v in pairs( class.toggles ) do
    if Hekili.DB.profile['Toggle State: '..v.name] == nil then
      Hekili.DB.profile['Toggle State: '..v.name] = v.state
    end
  end
  
  for k, v in pairs( class.settings ) do
    if Hekili.DB.profile['Class Option: '..v.name] == nil then
      Hekili.DB.profile['Class Option: '..v.name] = v.state
    end
  end
  
  ns.checkImports()
  ns.refreshOptions()
  ns.buildUI()
  ns.overrideBinds()

end


ns.refreshOptions = function()

  if not Hekili.Options then return end

  -- Remove existing displays from Options and rebuild the options table.
  for k,_ in pairs(Hekili.Options.args.displays.args) do
    if match(k, "^D(%d+)") then
      Hekili.Options.args.displays.args[k] = nil
    end
  end

  for i,v in ipairs(Hekili.DB.profile.displays) do
    local dispKey = 'D' .. i
    Hekili.Options.args.displays.args[ dispKey ] = ns.newDisplayOption( i )

    if v.Queues then
      for p, value in ipairs( v.Queues ) do
        local hookKey = 'P' .. p
        Hekili.Options.args.displays.args[ dispKey ].args[ hookKey ] = ns.newHookOption( i, p )
      end
    end
  end

  for k,_ in pairs(Hekili.Options.args.actionLists.args) do
    if match(k, "^L(%d+)") then
      Hekili.Options.args.actionLists.args[k] = nil
    end
  end

  for i,v in ipairs(Hekili.DB.profile.actionLists) do
    local listKey = 'L' .. i
    Hekili.Options.args.actionLists.args[ listKey ] = ns.newActionListOption( i )

    if v.Actions then
      for a,_ in ipairs( v.Actions ) do
        local actKey = 'A' .. a
        Hekili.Options.args.actionLists.args[ listKey ].args[ actKey ] = ns.newActionOption( i, a )
      end
    end
  end

  if not Hekili.Options.args.SimulationCraftImporter then
    Hekili.Options.args.SimulationCraftImporter = ns.SimulationCraftImporter()
  end

  Hekili.Options.args.class = nil
  Hekili.Options.args.class = ns.ClassSettings()

  -- Until I feel like making this better at managing memory.
  collectgarbage()

end


function Hekili:GetOption( info, input )
  local category, depth, option = info[1], #info, info[#info]
  local profile = Hekili.DB.profile

  if category == 'general' then
    return profile[option]

  elseif category == 'class' then
    if info[2] == 'toggles' then
      return profile['Toggle '..option]

    elseif info[2] == 'settings' then
      return profile['Class Option: '..option]

    end

  elseif category == 'notifs' then
    if option == 'Notification X' or option == 'Notification Y' then
      return tostring( profile[ option ] )
    end
    return profile[option]

  elseif category == 'bindings' then

    if option:match( "TOGGLE" ) then
      return select( 1, GetBindingKey( option ) )

    elseif option == 'Pause' then
      return self.Pause

    else
      return profile[ option ]

    end

  elseif category == 'displays' then

    -- This is a generic display option/function.
    if depth == 2 then
      return nil

        -- This is a display (or a hook).
    else
      local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
      local hookKey, hookID = info[3], tonumber( match( info[3] or "", "^P(%d+)" ) )
      local display = profile.displays[ dispID ]

      -- This is a specific display's settings.
      if depth == 3 or not hookID then

        if option == 'x' or option == 'y' then
          return tostring( display[ option ] )

        elseif option == 'SpellFlash Color' then
          if type( display[option] ) ~= 'table' then display[option] = { r = 1, g = 1, b = 1, a = 1 } end
          return display[option].r, display[option].g, display[option].b, display[option].a

        elseif option == 'Copy To' or option == 'Import' then
          return nil

        else
          return display[ option ]

        end

        -- This is a priority hook.
      else
        local hook = display.Queues[ hookID ]

        if option == 'Move' then
          return hookID

        else
          return hook[ option ]

        end

      end

    end

  elseif category == 'actionLists' then

    -- This is a general action list option.
    if depth == 2 then
      return nil

    else
      local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
      local actKey, actID = info[3], tonumber( match( info[3], "^A(%d+)" ) )
      local list = listID and profile.actionLists[ listID ]

      -- This is a specific action list.
      if depth == 3 or not actID then
        return list[ option ]

          -- This is a specific action.
      elseif listID and actID then
        local action = list.Actions[ actID ]

        if option == 'ConsumableArgs' then option = 'Args' end

        if option == 'Move' then
          return actID

        else
          return action[ option ]

        end

      end

    end

  end

  ns.Error( "GetOption() - should never see." )

end


local getUniqueName = function( category, name )
  local numChecked, suffix, original = 0, 1, name

  while numChecked < #category do
    for i, instance in ipairs( category ) do
      if name == instance.Name then
        name = original .. ' (' .. suffix .. ')'
        suffix = suffix + 1
        numChecked = 0
      else
        numChecked = numChecked + 1
      end
    end
  end

  return name
end


function Hekili:SetOption( info, input, ... )
  local category, depth, option, subcategory = info[1], #info, info[#info], nil
  local Rebuild, RebuildUI, RebuiltScripts, RebuildOptions, RebuildCache, Select
  local profile = Hekili.DB.profile

  if category == 'general' then
    -- We'll preset the option here; works for most options.
    profile[ option ] = input

    if option == 'Enabled' then
      for i, buttons in ipairs( ns.UI.Buttons ) do
        for j, _ in ipairs( buttons ) do
          if input == false then
            buttons[j]:Hide()
          else
            buttons[j]:Show()
          end
        end
      end

      if input == true then self:Enable()
      else self:Disable() end

      return

    elseif option == 'Locked' then
      if not self.Config and not self.Pause then
        for i, v in ipairs( ns.UI.Buttons ) do
          ns.UI.Buttons[i][1]:EnableMouse( not input )
        end
      end

    elseif option == 'Audit Targets' or option == 'Updates Per Second' then
      return

    end

    -- General options do not need add'l handling.
    return

  elseif category == 'class' then
    subcategory = info[2]

    if subcategory == 'toggles' then
      if option:match("State:") then
        Hekili:ClassToggle( option:match("State: (.-)$") )
      else
        profile[ 'Toggle ' .. option ] = input
        ns.overrideBinds()
      end

    elseif subcategory == 'settings' then
      profile[ 'Class Option: '..option] = input

    end

    return

  elseif category == 'notifs' then
    profile[ option ] = input

    if option == 'Notification X' or option == 'Notification Y' then
      profile[ option ] = tonumber( input )
    end

    RebuildUI = true

  elseif category == 'bindings' then

    local revert = profile[ option ]
    profile[ option ] = input

    if option:match( "TOGGLE" ) then
      if GetBindingKey( option ) then
        SetBinding( GetBindingKey( option ) )
      end
      SetBinding( input, option )
      SaveBindings( GetCurrentBindingSet() )

    elseif option == 'Mode' then
      profile[option] = revert
      self:ToggleMode()

    elseif option == 'Pause' then
      profile[option] = revert
      self:TogglePause()
      return

    elseif option == 'Cooldowns' then
      profile[option] = revert
      self:ToggleCooldowns()
      return

    elseif option == 'Potions' then
      profile[option] = revert
      self:TogglePotions()
      return

    elseif option == 'Hardcasts' then
      profile[option] = revert
      self:ToggleHardcasts()
      return

    elseif option == 'Interrupts' then
      profile[option] = revert
      self:ToggleInterrupts()
      return

    elseif option == 'Switch Type' then
      if input == 0 then
        if profile['Mode Status'] == 1 or profile['Mode Status'] == 2 then
          -- Check that the current mode is supported.
          profile['Mode Status'] = 0
          self:Print("Switch type updated; reverting to single-target.")
        end
      elseif input == 1 then
        if profile['Mode Status'] == 1 or profile['Mode Status'] == 3 then
          profile['Mode Status'] = 0
          self:Print("Switch type updated; reverting to single-target.")
        end
      end

    elseif option == 'Mode Status' or option:match("Toggle_") or option == 'BloodlustCooldowns' then
    -- do nothing, we're good.

    else -- Toggle Names.
      if input:trim() == "" then
        profile[ option ] = nil
    end

    end

    -- Bindings do not need add'l handling.
    return

  elseif category == 'displays' then

    -- This is a generic display option/function.
    if depth == 2 then

      if option == 'New Display' then
        local key, index = ns.newDisplay( input )

        if not key then return end

        C_Timer.After( 1 / profile['Updates Per Second'], Hekili[ 'ProcessDisplay'..index ] )

      elseif option == 'Import Display' then
        local import = ns.deserializeDisplay( input )

        if not import then
          Hekili:Print("Unable to import from given input string.")
          return
        end

        import.Name = getUniqueName( profile.displays, import.Name )
        table.insert( profile.displays, import )

      end

      Rebuild = true

      -- This is a display (or a hook).
    else
      local dispKey, dispID = info[2], info[2] and tonumber( match( info[2], "^D(%d+)" ) )
      local hookKey, hookID = info[3], info[3] and tonumber( match( info[3], "^P(%d+)" ) )
      local display = dispID and profile.displays[ dispID ]

      -- This is a specific display's settings.
      if depth == 3 or not hookID then
        local revert = display[option]
        display[option] = input

        if option == 'x' or option == 'y' then
          display[option] = tonumber( input )
          RebuildUI = true

        elseif option == 'Name' then
          Hekili.Options.args.displays.args[ dispKey ].name = input
          if input ~= revert and display.Default then display.Default = false end

        elseif option == 'Enabled' then
          -- Might want to replace this with RebuildUI = true
          for i, button in ipairs( ns.UI.Buttons[ dispID ] ) do
            if not input then
              button:Hide()
            else
              button:Show()
            end
          end
          RebuildUI = true

        elseif option == 'Single - Minimum' or option == 'Single - Maximum' or option == 'AOE - Minimum' or option == 'AOE - Maximum' then
        -- do nothing, it's already set.

        elseif option == 'Use SpellFlash' then

        elseif option == 'SpellFlash Color' then
          if type( display[ option ] ~= 'table' ) then display[ option ] = {} end
          display[ option ].r = input
          display[ option ].g = select( 1, ... )
          display[ option ].b = select( 2, ... )
          display[ option ].a = select( 3, ... )

        elseif option == 'Script' then
          display[option] = input:trim()
          RebuildScripts = true

        elseif option == 'Copy To' then
          local index = #profile.displays + 1

          profile.displays[ index ] = tableCopy( display )
          profile.displays[ index ].Name = input
          profile.displays[ index ].Default = false

          if not Hekili[ 'ProcessDisplay'..index ] then
            Hekili[ 'ProcessDisplay'..index ] = function ()
              Hekili:ProcessHooks( index )
            end
            C_Timer.After( 1 / self.DB.profile['Updates Per Second'], self[ 'ProcessDisplay'..index ] )
          end
          Rebuild = true

        elseif option == 'Import' then
          local import = ns.deserializeDisplay( input )

          if not import then
            Hekili:Print("Unable to import from given input string.")
            return
          end

          local name = display.Name
          profile.displays[ dispID ] = import
          profile.displays[ dispID ].Name = name

          Rebuild = true

        elseif option == 'Icons Shown' then
          if ns.queue[ dispID ] then
            for i = input + 1, #ns.queue[ dispID ] do
              ns.queue[ dispID ][ i ] = nil
            end
          end

        end

        RebuildUI = true

        -- This is a priority hook.
      else
        local hook = display.Queues[ hookID ]

        if option == 'Move' then
          local placeholder = table.remove( display.Queues, hookID )
          table.insert( display.Queues, input, placeholder )
          Rebuild, Select = true, 'P'..input

        elseif option == 'Script' then
          hook[ option ] = input:trim()
          RebuildScripts = true

        elseif option == 'Name' then
          Hekili.Options.args.displays.args[ dispKey ].args[ hookKey ].name = '|cFFFFD100' .. hookID .. '.|r ' .. input
          hook[ option ] = input

        elseif option == 'Action List' or option == 'Enabled' then
          hook[ option ] = input
          RebuildCache = true

        else
          hook[ option ] = input

        end

      end
    end

  elseif category == 'actionLists' then

    if depth == 2 then

      if option == 'New Action List' then
        local key = ns.newActionList( input )
        if key then
          RebuildOptions, RebuildCache = true, true
        end

      elseif option == 'Import Action List' then
        local import = ns.deserializeActionList( input )

        if not import then
          Hekili:Print("Unable to import from given input string.")
          return
        end

        import.Name = getUniqueName( profile.actionLists, import.Name )
        profile.actionLists[ #profile.actionLists + 1 ] = import
        Rebuild = true

      end

    else
      local listKey, listID = info[2], info[2] and tonumber( match( info[2], "^L(%d+)" ) )
      local actKey, actID = info[3], info[3] and tonumber( match( info[3], "^A(%d+)" ) )
      local list = profile.actionLists[ listID ]

      if depth == 3 or not actID then

        local revert = list[ option ]
        list[option] = input

        if option == 'Name' then
          Hekili.Options.args.actionLists.args[ listKey ].name = input
          if input ~= revert and list.Default then list.Default = false end

        elseif option == 'Enabled' or option == 'Specialization' then
          RebuildCache = true

        elseif option == 'Script' then
          list[ option ] = input:trim()
          RebuildScripts = true

          -- Import/Exports
        elseif option == 'Copy To' then
          list[option] = nil

          local index = #profile.actionLists + 1

          profile.actionLists[ index ] = tableCopy( list )
          profile.actionLists[ index ].Name = input
          profile.actionLists[ index ].Default = false

          Rebuild = true

        elseif option == 'Import Action List' then
          list[option] = nil

          local import = ns.deserializeActionList( input )

          if not import then
            Hekili:Print("Unable to import from given import string.")
            return
          end

          import.Name = list.Name
          table.remove( profile.actionLists, listID )
          table.insert( profile.actionLists, listID, import )
          -- profile.actionLists[ listID ] = import
          Rebuild = true

        elseif option == 'SimulationCraft' then
          list[option] = nil

          local import, warnings = self:ImportSimulationCraftActionList( input )

          if warnings then
            Hekili:Print( "|cFFFF0000WARNING:|r\nThe following issues were noted during actionlist import." )
            for i = 1, #warnings do
              Hekili:Print( warnings[i] )
            end
          end

          if not import then
            Hekili:Print( "No actions were successfully imported." )
            return
          end

          table.wipe( list.Actions )

          for i, entry in ipairs( import ) do

            local key = ns.newAction( listID, class.abilities[ entry.Ability ].name )

            local action = list.Actions[ i ]

            action.Ability = entry.Ability
            action.Args = entry.Args

            action.CycleTargets = entry.CycleTargets
            action.MaximumTargets = entry.MaximumTargets
            action.CheckMovement = entry.CheckMovement or false
            action.Movement = entry.Movement
            action.ModName = entry.ModName or ''

            --[[ if entry.Args and entry.Args:match("cycle_targets=1") then
              action.Indicator = "cycle"
            else
              action.Indicator = "none"
            end ]]
            action.Indicator = 'none'

            action.Script = entry.Script
            action.Enabled = true
          end

          Rebuild = true

        end

        -- This is a specific action.
      else
        local list = profile.actionLists[ listID ]
        local action = list.Actions[ actID ]

        action[ option ] = input

        if option == 'Name' then
          Hekili.Options.args.actionLists.args[ listKey ].args[ actKey ].name = '|cFFFFD100' .. actID .. '.|r ' .. input

        elseif option == 'Enabled' then
          RebuildCache = true

        elseif option == 'Move' then
          action[ option ] = nil
          local placeholder = table.remove( list.Actions, actID )
          table.insert( list.Actions, input, placeholder )
          Rebuild, Select = true, 'A'..input

        elseif option == 'Script' or option == 'Args' then
          input = input:trim()
          RebuildScripts = true

        elseif option == 'ReadyTime' then
          list[ option ] = input:trim()
          RebuildScripts = true

        elseif option == 'ConsumableArgs' then
          action[ option ] = nil
          action.Args = input
          RebuildScripts = true

        end

      end
    end
  end

  if Rebuild then
    ns.refreshOptions()
    ns.loadScripts()
    ns.buildUI()
    ns.cacheCriteria()
  else
    if RebuildOptions then ns.refreshOptions() end
    if RebuildScripts then ns.loadScripts() end
    if RebuildUI then ns.buildUI() end
    if RebuildCache and not RebuildUI then ns.cacheCriteria() end
  end

  if Select then
    ns.lib.AceConfigDialog:SelectGroup( "Hekili", category, info[2], Select )
  end

end



function Hekili:CmdLine( input )
  if not input or input:trim() == "" or input:trim() == "makedefaults" or input:trim() == 'force' or input:trim() == 'import' then
    if InCombatLockdown() and input:trim() ~= 'force' then
        Hekili:Print( "This addon cannot be configured while in combat." )
        return
    end
    if input:trim() == 'makedefaults' then
        Hekili.MakeDefaults = true
    end
    if input:trim() == 'import' then
        Hekili.AllowSimCImports = true
    end
    ns.StartConfiguration()

  elseif input:trim() == 'center' then
    for i, v in ipairs( Hekili.DB.profile.displays ) do
      ns.UI.Buttons[i][1]:ClearAllPoints()
      ns.UI.Buttons[i][1]:SetPoint("CENTER", 0, (i-1) * 50 )
    end
    self:SaveCoordinates()

  elseif input:trim() == 'recover' then
    Hekili.DB.profile.displays = {}
    Hekili.DB.profile.actionLists = {}
    ns.restoreDefaults()
    ns.buildUI()
    Hekili:Print("Default displays and action lists restored.")

  else
    LibStub("AceConfigCmd-3.0"):HandleCommand("hekili", "Hekili", input)
  end
end




-- Import/Export
-- Nicer string encoding from WeakAuras, thanks to Stanzilla.

local bit_band, bit_lshift, bit_rshift = bit.band, bit.lshift, bit.rshift
local string_char = string.char

local bytetoB64 = {
  [0]="a","b","c","d","e","f","g","h",
  "i","j","k","l","m","n","o","p",
  "q","r","s","t","u","v","w","x",
  "y","z","A","B","C","D","E","F",
  "G","H","I","J","K","L","M","N",
  "O","P","Q","R","S","T","U","V",
  "W","X","Y","Z","0","1","2","3",
  "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
  a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
  i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
  q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
  y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
  G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
  O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
  W = 48,  X = 49,  Y = 50,  Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
  ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

-- This code is based on the Encode7Bit algorithm from LibCompress
-- Credit goes to Galmok (galmok@gmail.com)
local encodeB64Table = {};

function encodeB64(str)
  local B64 = encodeB64Table;
  local remainder = 0;
  local remainder_length = 0;
  local encoded_size = 0;
  local l=#str
  local code
  for i=1,l do
    code = string.byte(str, i);
    remainder = remainder + bit_lshift(code, remainder_length);
    remainder_length = remainder_length + 8;
    while(remainder_length) >= 6 do
      encoded_size = encoded_size + 1;
      B64[encoded_size] = bytetoB64[bit_band(remainder, 63)];
      remainder = bit_rshift(remainder, 6);
      remainder_length = remainder_length - 6;
    end
  end
  if remainder_length > 0 then
    encoded_size = encoded_size + 1;
    B64[encoded_size] = bytetoB64[remainder];
  end
  return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}

function decodeB64(str)
  local bit8 = decodeB64Table;
  local decoded_size = 0;
  local ch;
  local i = 1;
  local bitfield_len = 0;
  local bitfield = 0;
  local l = #str;
  while true do
    if bitfield_len >= 8 then
      decoded_size = decoded_size + 1;
      bit8[decoded_size] = string_char(bit_band(bitfield, 255));
      bitfield = bit_rshift(bitfield, 8);
      bitfield_len = bitfield_len - 8;
    end
    ch = B64tobyte[str:sub(i, i)];
    bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
    bitfield_len = bitfield_len + 6;
    if i > l then
      break;
    end
    i = i + 1;
  end
  return table.concat(bit8, "", 1, decoded_size)
end

local Compresser = LibStub:GetLibrary("LibCompress");
local Encoder = Compresser:GetChatEncodeTable()
local Serializer = LibStub:GetLibrary("AceSerializer-3.0");


function TableToString(inTable, forChat)
  local serialized = Serializer:Serialize(inTable);
  local compressed = Compresser:CompressHuffman(serialized);
  if(forChat) then
    return encodeB64(compressed);
  else
    return Encoder:Encode(compressed);
  end
end


function StringToTable(inString, fromChat)
  local decoded;
  if(fromChat) then
    decoded = decodeB64(inString);
  else
    decoded = Encoder:Decode(inString);
  end
  local decompressed, errorMsg = Compresser:Decompress(decoded);
  if not(decompressed) then
    return "Error decompressing: "..errorMsg;
  end
  local success, deserialized = Serializer:Deserialize(decompressed);
  if not(success) then
    return "Error deserializing "..deserialized;
  end
  return deserialized;
end


function ns.serializeDisplay( display )
    if not Hekili.DB.profile.displays[ display ] then return nil end
    local serial = tableCopy( Hekili.DB.profile.displays[ display ] )

    -- Change actionlist IDs to actionlist names so we can validate later.
    for i,v in ipairs( serial.Queues ) do
        if serial.Queues[i]['Action List'] ~= 0 then
            serial.Queues[i]['Action List'] = Hekili.DB.profile.actionLists[ v['Action List'] ].Name
        end
    end

    return TableToString( serial, true )
end

Hekili.SerializeDisplay = ns.serializeDisplay


function ns.deserializeDisplay( str )
    local display = StringToTable( str, true )

    -- Check for dupes.
    for i, prio in pairs( display.Queues ) do
        if prio['Action List'] ~= 0 then
            local fixed = false
            for j, list in ipairs( Hekili.DB.profile.actionLists ) do
                if prio['Action List'] == list.Name then
                    prio['Action List'] = j
                    fixed = true
                    break
                end
            end
            if not fixed or type( prio['Action List'] ) == 'string' then
                prio['Action List'] = 0
            end
        end
    end

    return display
end

Hekili.DeserializeDisplay = ns.deserializeDisplay


function ns.serializeActionList( num ) 
    if not Hekili.DB.profile.actionLists[ num ] then return nil end
    local serial = tableCopy( Hekili.DB.profile.actionLists[ num ] )
    return TableToString( serial, true )
end


function ns.deserializeActionList( str )
    return StringToTable( str, true )
end



local ignore_actions = {
  -- call_action_list = 1,
  run_action_list = 1,
  snapshot_stats = 1,
  auto_attack = 1,
  use_item = 1,
  flask = 1,
  food = 1
}


local function make_substitutions( i, swaps, prefixes, postfixes )  

  if not i then return nil end

  for k,v in pairs( swaps ) do
  
    for token in i:gmatch( k ) do
    
      local times = 0
      while (i:find(token)) do
        local strpos, strend = i:find(token)
        
        local pre = i:sub( strpos - 1, strpos - 1 )
        local j = 2

        while ( pre == '(' and strpos - j > 0 ) do
          pre = i:sub( strpos - j, strpos - j )
          j = j + 1
        end
        
        local post = i:sub( strend + 1, strend + 1 )
        j = 2

        while ( post == ')' and strend + j < i:len() ) do
          post = i:sub( strend + j, strend + j )
          j = j + 1
        end
      
        local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
        local finish = strend < i:len() and i:sub( strend + 1 ) or ''

        if not ( prefixes and prefixes[ pre ] ) and pre ~= '.' and pre ~= '_' and not pre:match('%a') and not ( postfixes and postfixes[ post ] ) and post ~= '.' and post ~= '_' and not post:match('%a') then
          i = start .. '\a' .. finish
        else
          i = start .. '\v' .. finish
        end
      
      end
      
      i = i:gsub( '\v', token )
      i = i:gsub( '\a', v )
    
    end
  
  end

  return i

end
ns.accomm = accommodate_targets


local function accommodate_targets( targets, ability, i, line, warnings )

  local insert_targets = targets
  local insert_ability = ability

  if ability == 'storm_earth_and_fire' then
    insert_targets = type( targets ) == 'number' and min( 2, ( targets - 1 ) ) or 2
    insert_ability = 'storm_earth_and_fire_target'
  elseif ability == 'windstrike' then
    insert_ability = 'stormstrike'
  end

  local swaps = {}
  
  swaps["d?e?buff%."..insert_ability.."%.up"] = "active_dot."..insert_ability.. ">=" ..insert_targets
  swaps["d?e?buff%."..insert_ability.."%.down"] = "active_dot."..insert_ability.. "<" ..insert_targets
  swaps["dot%."..insert_ability.."%.up"] = "active_dot."..insert_ability..'>=' ..insert_targets
  swaps["dot%."..insert_ability.."%.ticking"] = "active_dot."..insert_ability..'>=' ..insert_targets
  swaps["dot%."..insert_ability.."%.down"] = "active_dot."..insert_ability..'<' ..insert_targets
  swaps["up"] = "active_dot."..insert_ability..">=" ..insert_targets
  swaps["ticking"] = "active_dot."..insert_ability..">=" ..insert_targets
  swaps["down"] = "active_dot."..insert_ability.."<" ..insert_targets  
  
  return make_substitutions( i, swaps )

end


local function sanitize( segment, i, line, warnings )

  if i == nil then return i end

  local operators = { [">"] = true,
    ["<"] = true,
    ["="] = true,
    ["~"] = true,
    ["+"] = true,
    ["-"] = true,
    ["%"] = true,
    ["*"] = true
  }
  
  local maths = { ['+'] = true,
    ['-'] = true,
    ['*'] = true,
    ['%%'] = true
  }

  local times = 0
  
  
  for v in pairs( class.resources ) do
  
    for token in i:gmatch( v ) do
    
      local times = 0
      while (i:find(token)) do
      
        local strpos, strend = i:find(token)
        
        local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
        local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
        local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
        local finish = strend < i:len() and i:sub( strend + 1 ) or ''

        if pre ~= '.' and pre ~= '_' and not pre:match('%a') and post ~= '.' and post ~= '_' and not post:match('%a') then
          i = start .. '\a' .. finish
        else
          i = start .. '\v' .. finish
        end
      
      end
      
      i = i:gsub( '\v', token )
      i = i:gsub( '\a', token..'.current' )
    
    end 
  
  end

  for token in i:gmatch( "equipped%.[0-9]+" ) do

    local itemID = tonumber( token:match( "([0-9]+)" ) )
    local itemName = GetItemInfo( itemID )
    local itemKey = formatKey( itemName )

    if itemKey and itemKey ~= '' then
        i = i:gsub( tostring( itemID ), itemKey )
    end

  end

  

  i, times = i:gsub( "pet%.%w+%.([%w_]+)%.", "%1." )
  if times > 0 then
    table.insert( warnings, "Line " .. line .. ": Converted 'pet.X.Y...' to 'Y...' (" .. times .. "x)." )
  end

  i, times = i:gsub( "gcd%.max", "gcd" )
  if times > 0 then
    table.insert( warnings, "Line " .. line .. ": Converted 'gcd.max' to 'gcd' (" .. times .. "x)." )
  end

  i, times = i:gsub( "gcd%.remains", "cooldown.global_cooldown.remains" )
  if times > 0 then
    table.insert( warnings, "Line " .. line .. ": Converted gcd.remains to cooldown.global_cooldown.remains (" .. times .. "x)." )
  end

  --[[ i, times = i:gsub( "spell_targets%.[a-zA-Z0-9_]+", "active_enemies" )
  if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted spell_targets.X syntax to active_enemies(" .. times .. "x)." )
  end ]]
  

  for token in i:gmatch( "incoming_damage_%d+m?s" ) do
    local times = 0
    while (i:find(token)) do
      local strpos, strend = i:find(token)
    
      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end
      
      if not operators[pre] and not operators[post] then
        i = i:sub( 1, strpos - 1 ) .. '\v' .. '>0' .. i:sub( strend + 1 )
        times = times + 1
      else
        i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
      end
    end

    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. ">0' (" .. times .. "x)." )
    end
    i = i:gsub( '\v', token )
  end


  for token in i:gmatch( "set_bonus%.[%a%d_]+" ) do
    local times = 0
    while (i:find(token)) do
      local strpos, strend = i:find(token)
    
      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end
      
      if not operators[pre] and not operators[post] then
        i = i:sub( 1, strpos - 1 ) .. '\v' .. '>0' .. i:sub( strend + 1 )
        times = times + 1
      else
        i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
      end
    end

    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. "=1' (" .. times .. "x)." )
    end
    i = i:gsub( '\v', token )
  end
  

  for token in i:gmatch( "cooldown%.[%a_]+%.remains" ) do
    local times = 0
    while (i:find(token)) do
      local strpos, strend = i:find(token)

      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end

      local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
      local finish = strend < i:len() and i:sub( strend + 1 ) or ''
      
      if not operators[pre] and not operators[post] then
        i = start .. '\v' .. '>0' .. finish
        times = times + 1
      else
        i = start .. '\v' .. finish
      end
    end

    i = i:gsub( '\v', token )
    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. ">0' (" .. times .. "x)." )
    end
  end

  for token in i:gmatch( "artifact%.[%a_]+%.rank" ) do
    local times = 0
    while (i:find(token)) do
      local strpos, strend = i:find(token)

      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end

      local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
      local finish = strend < i:len() and i:sub( strend + 1 ) or ''
      
      if not operators[pre] and not operators[post] then
        i = start .. '\v' .. '>0' .. finish
        times = times + 1
      else
        i = start .. '\v' .. finish
      end
    end

    i = i:gsub( '\v', token )
    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. ">0' (" .. times .. "x)." )
    end
  end  
  
  for token, attr in i:gmatch( "(d?e?buff%.[%a_]+%.)(remains)" ) do
    local times = 0
    while (i:find(token..attr)) do
      local strpos, strend = i:find(token..attr)

      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end

      local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
      local finish = strend < i:len() and i:sub( strend + 1 ) or ''
      
      if not operators[pre] and not operators[post] then
        i = start .. '\v' .. 'up' .. finish
        times = times + 1
      else
        i = start .. '\v' .. attr .. finish
      end
    end

    i = i:gsub( '\v', token )
    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. attr .. "' to '" .. token .. "up' (" .. times .. "x)." )
    end
  end

  
  for token, attr in i:gmatch( "(d?e?buff%.[%a_]+%.)(react)" ) do
    local times = 0
    while (i:find(token..attr)) do
      local strpos, strend = i:find(token..attr)
    
      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end

      local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
      local finish = strend < i:len() and i:sub( strend + 1 ) or ''
      
      if not operators[pre] and not operators[post] then
        i = start .. '\v' .. 'up' .. finish
        times = times + 1
      else
        i = start .. '\v' .. attr .. finish
      end
    end

    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. attr .. "' to '" .. token .. "up' (" .. times .. "x)." )
    end
    i = i:gsub( '\v', token )
  end
  
  
  for token, attr in i:gmatch( "(trinket%.[%a%._]+%.)(react)" ) do
    local times = 0
    while (i:find(token..attr)) do
      local strpos, strend = i:find(token..attr)
    
      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end

      local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
      local finish = strend < i:len() and i:sub( strend + 1 ) or ''
      
      if not operators[pre] and not operators[post] then
        i = start .. '\v' .. 'up' .. finish
        times = times + 1
      else
        i = start .. '\v' .. attr .. finish
      end
    end

    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. attr .. "' to '" .. token .. "up' (" .. times .. "x)." )
    end
    i = i:gsub( '\v', token )
  end
  
  
  for token, attr in i:gmatch( "(talent%.[%a%._]+%.)(enabled)" ) do
    local times = 0
    while (i:find(token..attr)) do
      local strpos, strend = i:find(token..attr)
    
      local pre = i:sub( strpos - 1, strpos - 1 )
      local j = 2

      while ( pre == '(' and strpos - j > 0 ) do
        pre = i:sub( strpos - j, strpos - j )
        j = j + 1
      end
      
      local post = i:sub( strend + 1, strend + 1 )
      j = 2

      while ( post == ')' and strend + j < i:len() ) do
        post = i:sub( strend + j, strend + j )
        j = j + 1
      end

      local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
      local finish = strend < i:len() and i:sub( strend + 1 ) or ''
      
      if maths[pre] or maths[post] then
        i = start .. '\a' .. finish
        times = times + 1
      else
        i = start .. '\v' .. finish
      end
    end

    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted '" .. token .. attr .. "' to '" .. token .. "i_enabled' for mathematical comparison (" .. times .. "x)." )
    end
    i = i:gsub( '\a', token .. 'i_enabled' ) 
    i = i:gsub( '\v', token .. attr )
  end  

  if segment == 'c' then
    for token in i:gmatch( "target" ) do
      local times = 0
      while (i:find(token)) do
        local strpos, strend = i:find(token)
      
        local pre = i:sub( strpos - 1, strpos - 1 )
        local post = i:sub( strend + 1, strend + 1 )
        
        if pre ~= '_' and post ~= '.' then
          i = i:sub( 1, strpos - 1 ) .. '\v.unit' .. i:sub( strend + 1 )
          times = times + 1
        else
          i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
        end
      end

      if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted non-specific 'target' to 'target.unit' (" .. times .. "x)." )
      end
      i = i:gsub( '\v', token )
    end
  end  


  for token in i:gmatch( "player" ) do
    local times = 0
    while (i:find(token)) do
      local strpos, strend = i:find(token)
    
      local pre = i:sub( strpos - 1, strpos - 1 )
      local post = i:sub( strend + 1, strend + 1 )
      
      if pre ~= '_' and post ~= '.' then
        i = i:sub( 1, strpos - 1 ) .. '\v.unit' .. i:sub( strend + 1 )
        times = times + 1
      else
        i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
      end
    end

    if times > 0 then
      table.insert( warnings, "Line " .. line .. ": Converted non-specific 'player' to 'player.unit' (" .. times .. "x)." )
    end
    i = i:gsub( '\v', token )
  end

  --[[ i,times = i:gsub( "(set_bonus%.[^%.=|&]+)=1", "%1" )
  if times > 0 then
    table.insert( warnings, "Line " .. line .. ": Converted set_bonus.X=1 to set_bonus.X (" .. times .. "x)." )
  end
  i,times = i:gsub( "(set_bonus%.[^%.=|&]+)=0", "!%1" )
  if times > 0 then
    table.insert( warnings, "Line " .. line .. ": Converted set_bonus.X=0 to !set_bonus.X (" .. times .. "x)." )
  end ]]
  
  return i
end


local function strsplit( str, delimiter )
    local result = {}
    local from = 1

    if not delimiter or delimiter == "" then
        result[1] = str
        return result
    end

    local delim_from, delim_to = string.find( str, delimiter, from )

    while delim_from do
        table.insert( result, string.sub( str, from, delim_from - 1 ) )
        from = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from )
    end

    table.insert( result, string.sub( str, from ) )
    return result
end


local function storeModifier( entry, key, value )

    if key ~= 'if' and key ~= 'ability' then
        if not entry.Args then entry.Args = key .. '=' .. value
        else entry.Args = entry.Args .. "," .. key .. "=" .. value end
    end

    if key == 'if' then
        entry.Script = value

    elseif key == 'cycle_targets' then
        entry.CycleTargets = tonumber( value ) == 1 and true or false

    elseif key == 'max_cycle_targets' then
        entry.MaximumTargets = value

    elseif key == 'moving' then
        entry.CheckMovement = true
        entry.Moving = tonumber( value )

    elseif key == 'name' then
        entry.ModName = value

    end

end



function Hekili:ImportSimulationCraftActionList( str, enemies )
    local import = str and str or Hekili.ImportString
    local output, warnings = {}, {}
    local line, times = 0, 0

    import = import:gsub("(|)([^|])", "%1|%2"):gsub("|||", "||")
    enemies = enemies or "active_enemies"

    for i in import:gmatch("action.-=/?([^\n^$]*)") do
        line = line + 1

        if i:sub(1, 3) == 'jab' then
            for token in i:gmatch( 'cooldown%.expel_harm%.remains>=gcd' ) do

                local times = 0
                while (i:find(token)) do
                    local strpos, strend = i:find(token)

                    local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                    local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                    local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                    local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                    local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                    i = start .. repl .. finish
                    times = times + 1
                end
                table.insert( warnings, "Line " .. line .. ": Removed unnecessary expel_harm cooldown check from action entry for jab (" .. times .. "x)." )
            end
        end

        for token in i:gmatch( 'spell_targets%.[%a_]+' ) do

            local times = 0
            while (i:find(token)) do
                local strpos, strend = i:find(token)

                local start = strpos > 2 and i:sub( 1, strpos - 1 ) or ''
                local finish = strend < i:len() - 1 and i:sub( strend + 1 ) or ''

                i = start .. enemies .. finish
                times = times + 1
            end
            table.insert( warnings, "Line " .. line .. ": Replaced unsupported '" .. token .. "' with '" .. enemies .. "' (" .. times .. "x)." )
        end

        if i:sub(1, 13) == 'fists_of_fury' then
            for token in i:gmatch( "energy.time_to_max>cast_time" ) do
                local times = 0
                while (i:find(token)) do
                    local strpos, strend = i:find(token)

                    local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                    local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                    local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                    local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                    local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                    i = start .. repl .. finish
                    times = times + 1
                end
                table.insert( warnings, "Line " .. line .. ": Removed unnecessary energy cap check from action entry for fists_of_fury (" .. times .. "x)." )
            end
        end

        local components = strsplit( i, "," )
        local result = {}

        for a, str in ipairs( components ) do

            -- First element is the action, if supported.
            if a == 1 then
                local ability = str:trim()

                if ability and class.abilities[ ability ] then
                    result.Ability = ability
                elseif not ignore_actions[ ability ] then
                    table.insert( warnings, "Line " .. line .. ": Unsupported action '" .. ability .. "'." )
                end

            else
                local key, value = str:match( "^(.-)=(.-)$" )

                if key and value then
                    storeModifier( result, key, value )
                end
            end

        end

        if result.Script then
            result.Script = sanitize( 'c', result.Script, line, warnings )
        end

        if result.Ability then
            table.insert( output, result )
        end

    end

    return #output > 0 and output or nil, #warnings > 0 and warnings or nil

end



-- Key Bindings
function Hekili:TogglePause()
  self.Pause = not self.Pause

  local MouseInteract = ( self.DB.profile.Debug and self.Pause ) or self.Config or ( not Hekili.DB.profile.Locked )

  for i = 1, #ns.UI.Buttons do
    for j = 1, #ns.UI.Buttons[i] do
      ns.UI.Buttons[i][j]:EnableMouse( MouseInteract )
    end
  end

  Hekili:Print( (not self.Pause and "UN" or "") .. "PAUSED." )
  Hekili:Notify( (not self.Pause and "UN" or "") .. "PAUSED" )
end


function Hekili:Notify( str )
  HekiliNotificationText:SetText( str )
  HekiliNotificationText:SetTextColor( 1, 0.8, 0, 1 )
  UIFrameFadeOut( HekiliNotificationText, 3, 1, 0 )
end


local nextMode = {
  [0] = { [0] = 3, [3] = 0 },
  [1] = { [0] = 2, [2] = 0 },
  [2] = { [0] = 1, [1] = 2, [2] = 0 }
}

local modeMsgs = {
  [0] = {
    p = "Single-target mode activated.",
    n = "Mode: Single"
  },
  [1] = {
    p = "Cleave mode activated.",
    n = "Mode: Cleave"
  },
  [2] = {
    p = "AOE mode activated.",
    n = "Mode: AOE"
  },
  [3] = {
    p = "Automatic mode activated.",
    n = "Mode: Auto"
  }
}

function Hekili:ToggleMode()
  local switch = Hekili.DB.profile['Switch Type']

  Hekili.DB.profile['Mode Status'] = nextMode[ switch ][ Hekili.DB.profile['Mode Status'] ]

  Hekili:Print( modeMsgs[ Hekili.DB.profile['Mode Status'] ].p )
  Hekili:Notify( modeMsgs[ Hekili.DB.profile['Mode Status'] ].n )

  if WeakAuras then WeakAuras.ScanEvents( 'HEKILI_TOGGLE_MODE', Hekili.DB.profile['Mode Status'] ) end
end


function Hekili:ToggleInterrupts()
  Hekili.DB.profile.Interrupts = not Hekili.DB.profile.Interrupts
  Hekili:Print( Hekili.DB.profile.Interrupts and "Interrupts |cFF00FF00ENABLED|r." or "Interrupts |cFFFF0000DISABLED|r." )
  Hekili:Notify( "Interrupts " .. ( Hekili.DB.profile.Interrupts and "ON" or "OFF" ) )
  if WeakAuras then WeakAuras.ScanEvents( 'HEKILI_TOGGLE_INTERRUPTS', Hekili.DB.profile.Interrupts ) end
end


function Hekili:ToggleCooldowns()
  Hekili.DB.profile.Cooldowns = not Hekili.DB.profile.Cooldowns
  Hekili:Print( Hekili.DB.profile.Cooldowns and "Cooldowns |cFF00FF00ENABLED|r." or "Cooldowns |cFFFF0000DISABLED|r." )
  Hekili:Notify( "Cooldowns " .. ( Hekili.DB.profile.Cooldowns and "ON" or "OFF" ) )
  if WeakAuras then WeakAuras.ScanEvents( 'HEKILI_TOGGLE_COOLDOWNS', Hekili.DB.profile.Cooldowns ) end
end


function Hekili:TogglePotions()
  Hekili.DB.profile.Potions = not Hekili.DB.profile.Potions
  Hekili:Print( Hekili.DB.profile.Potions and "Potions |cFF00FF00ENABLED|r." or "Potions |cFFFF0000DISABLED|r." )
  Hekili:Notify( "Potions " .. ( Hekili.DB.profile.Potions and "ON" or "OFF" ) )
  if WeakAuras then WeakAuras.ScanEvents( 'HEKILI_TOGGLE_POTIONS', Hekili.DB.profile.Potions ) end
end


function Hekili:ClassToggle( name )

  local key = 'Toggle State: '..name

  Hekili.DB.profile[key] = not Hekili.DB.profile[key]

  local toggle = name

  for i = 1, #class.toggles do
    if class.toggles[i].name == name then toggle = class.toggles[i].option; break end
  end

  Hekili:Print( Hekili.DB.profile[key] and ( 'Toggle \'' .. toggle .. "' |cFF00FF00ENABLED|r." ) or ( 'Toggle \'' .. toggle .. "' |cFFFF0000DISABLED|r." ) )
  Hekili:Notify( Hekili.DB.profile[key] and ( toggle .. " ON" ) or ( toggle .. " OFF" ) )

  if WeakAuras then WeakAuras.ScanEvents( 'HEKILI_CLASS_TOGGLE', name, Hekili.DB.profile[ key ] ) end
end


function Hekili:GetToggleState( name, class )
    if class then
        return Hekili.DB.profile[ 'Toggle State: ' .. name ]
    end
    return Hekili.DB.profile[ name ]
end