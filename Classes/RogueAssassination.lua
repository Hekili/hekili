-- RogueAssassination.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local IterateTargets, ActorHasDebuff = ns.iterateTargets, ns.actorHasDebuff


-- Conduits
-- [-] lethal_poisons
-- [-] maim_mangle
-- [-] poisoned_katar
-- [x] wellplaced_steel

-- Covenant
-- [-] reverberation
-- [-] slaughter_scars
-- [-] sudden_fractures
-- [-] septic_shock

-- Endurance
-- [x] cloaked_in_shadows
-- [x] nimble_fingers -- may need to double check which reductions come first.
-- [-] recuperator

-- Finesse
-- [x] fade_to_nothing
-- [x] prepared_for_all
-- [x] quick_decisions
-- [x] rushed_setup


if UnitClassBase( 'player' ) == 'ROGUE' then
    local spec = Hekili:NewSpecialization( 259 )

    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy, {
        vendetta_regen = {
            aura = "vendetta_regen",

            last = function ()
                local app = state.buff.vendetta_regen.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 20,
        },

        garrote_vim = {
            aura = "garrote",
            debuff = true,

            last = function ()
                local app = state.debuff.garrote.last_tick
                local exp = state.debuff.garrote.expires
                local tick = state.debuff.garrote.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.garrote.tick_time
            end,

            value = 8
        },

        internal_bleeding_vim = {
            aura = "internal_bleeding",
            debuff = true,

            last = function ()
                local app = state.debuff.internal_bleeding.last_tick
                local exp = state.debuff.internal_bleeding.expires
                local tick = state.debuff.internal_bleeding.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.internal_bleeding.tick_time
            end,

            value = 8
        },

        rupture_vim = {
            aura = "rupture",
            debuff = true,

            last = function ()
                local app = state.debuff.rupture.last_tick
                local exp = state.debuff.rupture.expires
                local tick = state.debuff.rupture.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.rupture.tick_time
            end,

            value = 8
        },

        crimson_tempest_vim = {
            aura = "crimson_tempest",
            debuff = true,

            last = function ()
                local app = state.debuff.crimson_tempest.last_tick
                local exp = state.debuff.crimson_tempest.expires
                local tick = state.debuff.crimson_tempest.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.crimson_tempest.tick_time
            end,

            value = 8
        },

        nothing_personal = {
            aura = "nothing_personal_regen",

            last = function ()
                local app = state.buff.nothing_personal_regen.applied
                local exp = state.buff.nothing_personal_regen.expires
                local tick = state.buff.nothing_personal_regen.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.buff.nothing_personal_regen.down
            end,

            interval = function ()
                return state.buff.nothing_personal_regen.tick_time
            end,

            value = 4
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        master_poisoner = 22337, -- 196864
        elaborate_planning = 22338, -- 193640
        blindside = 22339, -- 111240

        nightstalker = 22331, -- 14062
        subterfuge = 22332, -- 108208
        master_assassin = 23022, -- 255989

        vigor = 19239, -- 14983
        deeper_stratagem = 19240, -- 193531
        marked_for_death = 19241, -- 137619

        leeching_poison = 22340, -- 280716
        cheat_death = 22122, -- 31230
        elusiveness = 22123, -- 79008

        internal_bleeding = 19245, -- 154904
        iron_wire = 23037, -- 196861
        prey_on_the_weak = 22115, -- 131511

        venom_rush = 22343, -- 152152
        alacrity = 23015, -- 193539
        exsanguinate = 22344, -- 200806

        poison_bomb = 21186, -- 255544
        hidden_blades = 22133, -- 270061
        crimson_tempest = 23174, -- 121411
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        creeping_venom = 141, -- 354895
        death_from_above = 3479, -- 269513
        dismantle = 5405, -- 207777
        flying_daggers = 144, -- 198128
        hemotoxin = 830, -- 354124
        intent_to_kill = 130, -- 197007
        maneuverability = 3448, -- 197000
        smoke_bomb = 3480, -- 212182
        system_shock = 147, -- 198145
        thick_as_thieves = 5408, -- 221622
    } )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )

    -- Commented out in SimC, but my implementation should hold up vs. theirs.
    -- APLs will use effective_combo_points.
    spec:RegisterStateExpr( "animacharged_cp", function ()
        local n = buff.echoing_reprimand.stack
        if n > 0 then return n end
        return combo_points.max
    end )

    spec:RegisterStateExpr( "effective_combo_points", function ()
        if buff.echoing_reprimand.up and combo_points.current == buff.echoing_reprimand.stack then
            return 7
        end
        return combo_points.current
    end )


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        sepsis  = { "sepsis_buff" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
    }


    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "sepsis" then
                return buff.sepsis_buff.up
            elseif k == "sepsis_remains" then
                return buff.sepsis_buff.remains
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
            end

            return false
        end
    } ) )


    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not ( talent.master_assassin.enabled or legendary.mark_of_the_master_assassin.enabled ) then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + ( legendary.mark_of_the_master_assassin.enabled and 4 or 3 )
        elseif buff.master_assassin_any.up then return buff.master_assassin_any.remains end
        return 0
    end )



    local stealth_dropped = 0


    local function isStealthed()
        return ( FindUnitBuffByID( "player", 1784 ) or FindUnitBuffByID( "player", 115191 ) or FindUnitBuffByID( "player", 115192 ) or FindUnitBuffByID( "player", 11327 ) or GetTime() - stealth_dropped < 0.2 )
    end


    local calculate_multiplier = setfenv( function( spellID )
        local mult = 1
        local stealth = isStealthed()

        if stealth then
            if talent.nightstalker.enabled then
                mult = mult * 1.5
            end

            -- Garrote.
            if talent.subterfuge.enabled and spellID == 703 then
                mult = mult * 1.8
            end
        end

        return mult
    end, state )


    -- index: unitGUID; value: isExsanguinated (t/f)
    local crimson_tempests = {}
    local ltCT = {}

    local garrotes = {}
    local ltG = {}
    local ssG = {}

    local internal_bleedings = {}
    local ltIB = {}

    local ruptures = {}
    local ltR = {}

    local snapshots = {
        [121411] = true,
        [703]    = true,
        [154953] = true,
        [1943]   = true
    }

    local death_events = {
        UNIT_DIED               = true,
        UNIT_DESTROYED          = true,
        UNIT_DISSIPATES        = true,
        PARTY_KILL              = true,
        SPELL_INSTAKILL         = true,
    }


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                if spellID == 115191 or spellID == 1784 then
                    stealth_dropped = GetTime()
                
                elseif spellID == 703 then
                    ssG[ destGUID ] = nil

                end

            elseif snapshots[ spellID ] and ( subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) then
                    ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                    ns.trackDebuff( spellID, destGUID, GetTime(), true )

                    if spellID == 121411 then
                        -- Crimson Tempest
                        crimson_tempests[ destGUID ] = false

                    elseif spellID == 703 then
                        -- Garrote
                        garrotes[ destGUID ] = false
                        ssG[ destGUID ] = state.azerite.shrouded_suffocation.enabled and isStealthed()

                    elseif spellID == 408 then
                        -- Internal Bleeding (from Kidney Shot)
                        internal_bleedings[ destGUID ] = false

                    elseif spellID == 1943 then
                        -- Rupture
                        ruptures[ destGUID ] = false
                    end
            
            elseif subtype == "SPELL_CAST_SUCCESS" and spellID == 200806 then
                -- Exsanguinate
                crimson_tempests[ destGUID ] = true
                garrotes[ destGUID ] = true
                internal_bleedings[ destGUID ] = true
                ruptures[ destGUID ] = true

            elseif subtype == "SPELL_PERIODIC_DAMAGE" then
                if spellID == 121411 then
                    ltCT[ destGUID ] = GetTime()

                elseif spellID == 703 then
                    ltG[ destGUID ] = GetTime()

                elseif spellID == 408 then
                    ltIB[ destGUID ] = GetTime()

                elseif spellID == 1943 then
                    ltR[ destGUID ] = GetTime()

                end
            end
        end

        if death_events[ subtype ] then
            ssG[ destGUID ] = nil
        end
    end )


    spec:RegisterHook( "UNIT_ELIMINATED", function( guid )
        ssG[ guid ] = nil
    end )


    local energySpent = 0

    local ENERGY = Enum.PowerType.Energy
    local lastEnergy = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "ENERGY" then
            local current = UnitPower( "player", ENERGY )

            if current < lastEnergy then
                energySpent = ( energySpent + lastEnergy - current ) % 30
            end

            lastEnergy = current
        end
    end )

    spec:RegisterStateExpr( "energy_spent", function ()
        return energySpent
    end )

    spec:RegisterHook( "spend", function( amt, resource )
        if legendary.duskwalkers_patch.enabled and cooldown.vendetta.remains > 0 and resource == "energy" and amt > 0 then
            energy_spent = energy_spent + amt
            local reduction = floor( energy_spent / 30 )
            energy_spent = energy_spent % 30

            if reduction > 0 then
                reduceCooldown( "vendetta", reduction )
            end
        end
        
        if resource == "combo_points" and legendary.obedience.enabled and buff.flagellation_buff.up then
            reduceCooldown( "flagellation", amt )
        end
    end )


    spec:RegisterStateExpr( 'persistent_multiplier', function ()
        local mult = 1

        if not this_action then return mult end

        local stealth = buff.stealth.up or buff.subterfuge.up

        if stealth then
            if talent.nightstalker.enabled then
                mult = mult * 2
            end

            if talent.subterfuge.enabled and this_action == "garrote" then
                mult = mult * 1.8
            end
        end

        return mult
    end )

    spec:RegisterStateExpr( 'exsanguinated', function ()
        if not this_action then return false end
        local aura = this_action == "kidney_shot" and "internal_bleeding" or this_action

        return debuff[ aura ].exsanguinated == true
    end )

    -- Enemies with either Deadly Poison or Wound Poison applied.
    spec:RegisterStateExpr( 'poisoned_enemies', function ()
        return ns.countUnitsWithDebuffs( "deadly_poison_dot", "wound_poison_dot", "crippling_poison_dot" )
    end )

    spec:RegisterStateExpr( 'poison_remains', function ()
        return debuff.lethal_poison.remains
    end )

    -- Count of bleeds on targets.
    spec:RegisterStateExpr( 'bleeds', function ()
        local n = 0
        if debuff.garrote.up then n = n + 1 end
        if debuff.internal_bleeding.up then n = n + 1 end
        if debuff.rupture.up then n = n + 1 end
        if debuff.crimson_tempest.up then n = n + 1 end
        
        return n
    end )
    
    -- Count of bleeds on all poisoned (Deadly/Wound) targets.
    spec:RegisterStateExpr( 'poisoned_bleeds', function ()
        return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "garrote", "internal_bleeding", "rupture" )
    end )
    
    
    spec:RegisterStateExpr( "ss_buffed", function ()
        return debuff.garrote.ss_buffed or false
    end )

    spec:RegisterStateExpr( "non_ss_buffed_targets", function ()
        local count = ( debuff.garrote.down or not debuff.garrote.exsanguinated ) and 1 or 0

        for guid, counted in ns.iterateTargets() do
            if guid ~= target.unit and counted and ( not ns.actorHasDebuff( guid, 703 ) or not ssG[ guid ] ) then
                count = count + 1
            end
        end

        return count
    end )

    spec:RegisterStateExpr( "ss_buffed_targets_above_pandemic", function ()
        if not debuff.garrote.refreshable and debuff.garrote.ss_buffed then
            return 1
        end
        return 0 -- we aren't really tracking this right now...
    end )



    spec:RegisterStateExpr( "pmultiplier", function ()
        if not this_action then return 0 end

        local a = class.abilities[ this_action ]
        if not a then return 0 end

        local aura = a.aura or this_action
        if not aura then return 0 end

        if debuff[ aura ] and debuff[ aura ].up then
            return debuff[ aura ].pmultiplier or 1
        end

        return 0
    end )

    spec:RegisterStateExpr( "priority_rotation", function ()
        return settings.priority_rotation
    end )


    local ExpireSepsis = setfenv( function ()
        applyBuff( "sepsis_buff" )
    end, state )
    
    spec:RegisterHook( "reset_precast", function ()
        debuff.crimson_tempest.pmultiplier   = nil
        debuff.garrote.pmultiplier           = nil
        debuff.internal_bleeding.pmultiplier = nil
        debuff.rupture.pmultiplier           = nil

        debuff.crimson_tempest.exsanguinated   = nil -- debuff.crimson_tempest.up and crimson_tempests[ target.unit ]
        debuff.garrote.exsanguinated           = nil -- debuff.garrote.up and garrotes[ target.unit ]
        debuff.internal_bleeding.exsanguinated = nil -- debuff.internal_bleeding.up and internal_bleedings[ target.unit ]
        debuff.rupture.exsanguinated           = nil -- debuff.rupture.up and ruptures[ target.unit ]

        debuff.garrote.ss_buffed               = nil

        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if talent.master_assassin.enabled then
                applyBuff( "master_assassin" )
            end

            if talent.subterfuge.enabled then
                applyBuff( "subterfuge" )
            end

            if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
                applyBuff( "master_assassins_mark", 4 )
            end

            if buff.stealth.up then
                setCooldown( "stealth", 2 )
            end

            removeBuff( "stealth" )
            removeBuff( "shadowmeld" )
            removeBuff( "vanish" )
        end
    end )


    -- Auras
    spec:RegisterAuras( {
        blind = {
            id = 2094,
            duration = 60,
            max_stack = 1,
        },
        blindside = {
            id = 121153,
            duration = 10,
            max_stack = 1,
        },
        cheap_shot = {
            id = 1833,
            duration = 4,
            max_stack = 1,
        },
        cloak_of_shadows = {
            id = 31224,
            duration = 5,
            max_stack = 1,
        },
        crimson_tempest = {
            id = 121411,
            duration = function () return talent.deeper_stratagem.enabled and 14 or 12 end,
            max_stack = 1,
            meta = {
                exsanguinated = function ( t ) return t.up and crimson_tempests[ target.unit ] end,                
                last_tick = function ( t ) return ltCT[ target.unit ] or t.applied end,
                tick_time = function( t ) return t.exsanguinated and haste or ( 2 * haste ) end,
            },                    
        },
        crimson_vial = {
            id = 185311,
            duration = 4,
            max_stack = 1,
        },
        crippling_poison = {
            id = 3408,
            duration = 3600,
            max_stack = 1,
        },
        crippling_poison_dot = {
            id = 3409,
            duration = 12,
            max_stack = 1,
        },
        deadly_poison = {
            id = 2823,
            duration = 3600,
            max_stack = 1,
        },
        deadly_poison_dot = {
            id = 2818,
            duration = function () return 12 * haste end,
            max_stack = 1,
        },  
        elaborate_planning = {
            id = 193641,
            duration = 4,
            max_stack = 1,
        },
        envenom = {
            id = 32645,
            duration = function () return talent.deeper_stratagem.enabled and 7 or 6 end,
            type = "Poison",
            max_stack = 1,
        },
        evasion = {
            id = 5277,
            duration = 10,
            max_stack = 1,
        },
        feint = {
            id = 1966,
            duration = 6,
            max_stack = 1,
        },
        fleet_footed = {
            id = 31209,
        },
        garrote = {
            id = 703,
            duration = 18,
            max_stack = 1,
            meta = {
                exsanguinated = function ( t ) return t.up and garrotes[ target.unit ] end,
                last_tick = function ( t ) return ltG[ target.unit ] or t.applied end,
                ss_buffed = function ( t ) return t.up and ssG[ target.unit ] end,
                tick_time = function ( t )
                    --if not talent.exsanguinate.enabled then return 2 * haste end
                    return t.exsanguinated and haste or ( 2 * haste ) end,
            },                    
        },
        garrote_silence = {
            id = 1330,
            duration = function () return talent.iron_wire.enabled and 6 or 3 end,
            max_stack = 1,
        },
        hidden_blades = {
            id = 270070,
            duration = 3600,
            max_stack = 20,
        },
        internal_bleeding = {
            id = 154953,
            duration = 6,
            max_stack = 1,
            meta = {
                exsanguinated = function ( t ) return t.up and internal_bleedings[ target.unit ] end,
                last_tick = function ( t ) return ltIB[ target.unit ] or t.applied end,
                tick_time = function ( t )
                    --if not talent.exsanguinate.enabled then return haste end
                    return t.exsanguinated and ( 0.5 * haste ) or haste end,
            },
        },
        iron_wire = {
            id = 256148,
            duration = 8,
            max_stack = 1,
        },
        kidney_shot = {
            id = 408,
            duration = function () return talent.deeper_stratagem.enabled and 7 or 6 end,
            max_stack = 1,
        },
        marked_for_death = {
            id = 137619,
            duration = 60,
            max_stack = 1,
        },
        master_assassin = {
            id = 256735,
            duration = 3,
            max_stack = 1,
        },
        prey_on_the_weak = {
            id = 255909,
            duration = 6,
            max_stack = 1,
        },
        rupture = {
            id = 1943,
            duration = function () return talent.deeper_stratagem.enabled and 28 or 24 end,
            tick_time = function () return debuff.rupture.exsanguinated and haste or ( 2 * haste ) end,
            max_stack = 1,
            meta = {
                exsanguinated = function ( t ) return t.up and ruptures[ target.unit ] end,
                last_tick = function ( t ) return ltR[ target.unit ] or t.applied end,
                --[[ tick_time = function ( t )
                    --if not talent.exsanguinate.enabled then return 2 * haste end
                    return t.exsanguinated and haste or ( 2 * haste ) end, ]]
            },                    
        },
        shadowstep = {
            id = 36554,
            duration = 2,
            max_stack = 1,
        },
        shroud_of_concealment = {
            id = 114018,
            duration = 15,
            max_stack = 1,
        },
        slice_and_dice = {
            id = 315496,
            duration = function () return talent.deeper_stratagem.enabled and 42 or 36 end,
            max_stack = 1
        },
        sprint = {
            id = 2983,
            duration = 8,
            max_stack = 1,
        },
        stealth = {
            id = function () return talent.subterfuge.enabled and 115191 or 1784 end,
            duration = 3600,
            max_stack = 1,
            copy = { 115191, 1784 }
        },
        subterfuge = {
            id = 115192,
            duration = 3,
            max_stack = 1,
        },
        tricks_of_the_trade = {
            id = 57934,
            duration = 30,
            max_stack = 1,
        },
        vanish = {
            id = 11327,
            duration = 3,
            max_stack = 1,
        },
        vendetta = {
            id = 79140,
            duration = 20,
            max_stack = 1,
        },
        vendetta_regen = {
            name = "Vendetta Regen",
            duration = 3,
            max_stack = 1,
            generate = function ()
                local cast = action.vendetta.lastCast or 0
                local up = cast + 3 < query_time

                local vr = buff.vendetta_regen

                if up then
                    vr.count = 1
                    vr.expires = cast + 3
                    vr.applied = cast
                    vr.caster = "player"
                    return
                end
                vr.count = 0
                vr.expires = 0
                vr.applied = 0
                vr.caster = "nobody"                
            end,
        },
        venomous_wounds = {
            id = 79134,
        },
        wound_poison = {
            id = 8679,
            duration = 3600,
            max_stack = 1,
        },
        wound_poison_dot = {
            id = 8680,
            duration = 12,
            max_stack = 1,
            no_ticks = true,
        },


        lethal_poison = {
            alias = { "deadly_poison", "wound_poison", "instant_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },
        nonlethal_poison = {
            alias = { "crippling_poison", "numbing_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },


        -- Azerite Powers
        nothing_personal = {
            id = 286581,
            duration = 20,
            tick_time = 2,
            max_stack = 1,
        },

        nothing_personal_regen = {
            id = 289467,
            duration = 20,
            tick_time = 2,
            max_stack = 1,
        },

        scent_of_blood = {
            id = 277731,
            duration = 24,            
        },

        sharpened_blades = {
            id = 272916,
            duration = 20,
            max_stack = 30
        },

        -- PvP Talents
        creeping_venom = {
            id = 198097,
            duration = 4,
            max_stack = 18,
        },

        system_shock = {
            id = 198222,
            duration = 2,
        },

        -- Legendaries
        bloodfang = {
            id = 23581,
            duration = 6,
            max_stack = 1
        },

        master_assassins_mark = {
            id = 340094,
            duration = 4,
            max_stack = 1
        },

        master_assassin_any = {
            alias = { "master_assassin", "master_assassins_mark" },
            aliasMode = "longest",
            aliasType = "buff",
            duration = function () return legendary.mark_of_the_master_assassin.enabled and 4 or 3 end,
        }
    } )


    -- Abilities
    spec:RegisterAbilities( {
        ambush = {
            id = 8676,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.blindside.up and 0 or 50 end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132282,
            
            usable = function () return stealthed.all or buff.blindside.up or buff.sepsis_buff.up, "requires stealth or blindside or sepsis proc" end,
            
            handler = function ()                
                gain( 2, "combo_points" )
                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" )
                else
                    removeBuff( "blindside" )
                end
            end,
        },
        
        
        blind = {
            id = 2094,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = true,
            texture = 136175,

            handler = function ()
                applyDebuff( "target", "blind" )
            end,
        },


        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all, "not stealthed"
            end,

            nodebuff = "cheap_shot",

            handler = function ()
                applyDebuff( "target", "cheap_shot" )
                gain( 1, "combo_points" )

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

                if talent.prey_on_the_weak.enabled then applyDebuff( "target", "prey_on_the_weak" ) end
            end,
        },


        cloak_of_shadows = {
            id = 31224,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136177,

            handler = function ()
                applyBuff( "cloak_of_shadows" )
            end,
        },


        crimson_tempest = {
            id = 121411,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 464079,

            talent = "crimson_tempest",
            aura = "crimson_tempest",
            cycle = "crimson_tempest",            

            usable = function () return combo_points.current > 0 end,

            handler = function ()
                applyDebuff( "target", "crimson_tempest", 2 + ( combo_points.current * 2 ) )
                debuff.crimson_tempest.pmultiplier = persistent_multiplier
                debuff.crimson_tempest.exsanguinated = false

                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )

                if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 20 - conduit.nimble_fingers.mod end,
            spendType = "energy",

            startsCombat = false,
            texture = 1373904,

            toggle = "defensives",

            handler = function ()
                applyBuff( "crimson_vial" )
            end,
        },


        crippling_poison = {
            id = 3408,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            texture = 132274,

            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "crippling_poison" )
            end,
        },


        deadly_poison = {
            id = 2823,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,
            texture = 132290,

            
            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "deadly_poison" )
            end,
        },


        distract = {
            id = 1725,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 30 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132289,

            handler = function ()
            end,
        },


        envenom = {
            id = 32645,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,

            spendType = "energy",

            startsCombat = true,
            texture = 132287,

            usable = function () return combo_points.current > 0, "requires combo_points" end,

            handler = function ()
                if pvptalent.system_shock.enabled then
                    if combo_points.current >= 5 and debuff.garrote.up and debuff.rupture.up and ( debuff.deadly_poison_dot.up or debuff.wound_poison_dot.up ) then
                        applyDebuff( "target", "system_shock", 2 )
                    end
                end

                if pvptalent.creeping_venom.enabled then
                    applyDebuff( "target", "creeping_venom" )
                end

                if level > 55 and buff.slice_and_dice.up then
                    buff.slice_and_dice.expires = buff.slice_and_dice.expires + combo_points.current * 3
                end

                applyBuff( "envenom", 1 + combo_points.current )
                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )

                if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            end,
        },


        evasion = {
            id = 5277,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 136205,

            handler = function ()
                applyBuff( "evasion" )
            end,
        },


        exsanguinate = {
            id = 200806,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 538040,

            talent = "exsanguinate",

            handler = function ()
                if debuff.crimson_tempest.up then
                    debuff.crimson_tempest.expires = query_time + ( debuff.crimson_tempest.remains / 2 ) 
                    debuff.crimson_tempest.exsanguinated = true
                end

                if debuff.garrote.up then
                    debuff.garrote.expires = query_time + ( debuff.garrote.remains / 2 )
                    debuff.garrote.exsanguinated = true
                end

                if debuff.internal_bleeding.up then
                    debuff.internal_bleeding.expires = query_time + ( debuff.internal_bleeding.remains / 2 )
                    debuff.internal_bleeding.exsanguinated = true
                end

                if debuff.rupture.up then
                    debuff.rupture.expires = query_time + ( debuff.rupture.remains / 2 )
                    debuff.rupture.exsanguinated = true
                end
            end,
        },


        fan_of_knives = {
            id = 51723,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 236273,

            cycle = function () return buff.deadly_poison.up and "deadly_poison" or nil end,

            handler = function ()
                gain( 1, "combo_points" )
                removeBuff( "hidden_blades" )
                if buff.deadly_poison.up then
                    applyDebuff( "target", "deadly_poison" )
                    active_dot.deadly_poison = min( active_enemies, active_dot.deadly_poison + 8 )
                end
            end,
        },


        feint = {
            id = 1966,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return 35 - conduit.nimble_fingers.mod end,
            spendType = "energy",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                applyBuff( "feint" )
            end,
        },


        garrote = {
            id = 703,
            cast = 0,
            cooldown = function () return ( talent.subterfuge.enabled and ( buff.stealth.up or buff.subterfuge.up ) ) and 0 or 6 end,
            gcd = "spell",

            spend = 45,
            spendType = "energy",

            startsCombat = true,
            texture = 132297,

            aura = "garrote",
            cycle = "garrote",

            handler = function ()
                applyDebuff( "target", "garrote", min( debuff.garrote.remains + debuff.garrote.duration, 1.3 * debuff.garrote.duration ) )
                debuff.garrote.pmultiplier = persistent_multiplier
                debuff.garrote.exsanguinated = false

                gain( 1, "combo_points" )

                if stealthed.rogue then
                    if level > 45 then applyDebuff( "target", "garrote_silence" ) end
                    if talent.iron_wire.enabled then applyDebuff( "target", "iron_wire" ) end

                    if azerite.shrouded_suffocation.enabled then
                        gain( 2, "combo_points" )
                        debuff.garrote.ss_buffed = true
                    end
                end
            end,
        },


        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 132219,

            toggle = "interrupts",
            interrupt = true,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                
                if conduit.prepared_for_all.enabled and cooldown.cloak_of_shadows.remains > 0 then
                    reduceCooldown( "cloak_of_shadows", 2 * conduit.prepared_for_all.mod )
                end
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 25 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132298,

            aura = "internal_bleeding",
            cycle = "internal_bleeding",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.internal_bleeding.enabled then
                    applyDebuff( "target", "internal_bleeding" )
                    debuff.internal_bleeding.pmultiplier = persistent_multiplier
                    debuff.internal_bleeding.exsanguinated = false
                end

                applyDebuff( "target", "kidney_shot", 1 + combo_points.current )
                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )

                if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            end,
        },


        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
            end,

            handler = function ()
                gain( 5, "combo_points" )
                applyDebuff( "target", "marked_for_death" )
            end,
        },


        mutilate = {
            id = 1329,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 132304,

            handler = function ()
                gain( 2, "combo_points" )

                if talent.venom_rush.enabled and ( debuff.deadly_poison_dot.up or debuff.wound_poison_dot.up or debuff.crippling_poison_dot.up ) then
                    gain( 8, "energy" )
                end
            end,
        },


        numbing_poison = {
            id = 5761,
            cast = 1,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136066,

            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "numbing_poison" )
            end,
        },


        --[[ pick_lock = {
            id = 1804,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136058,

            handler = function ()
            end,
        },


        pick_pocket = {
            id = 921,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            startsCombat = true,
            texture = 133644,

            handler = function ()
            end,
        }, ]]


        poisoned_knife = {
            id = 185565,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 1373909,

            handler = function ()
                removeBuff( "sharpened_blades" )
                gain( 1, "combo_points" )
            end,
        },


        rupture = {
            id = 1943,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 132302,

            aura = "rupture",
            cycle = "rupture",

            usable = function () return combo_points.current > 0, "requires combo_points" end,
            handler = function ()
                applyDebuff( "target", "rupture", min( dot.rupture.remains, class.auras.rupture.duration * 0.3 ) + 4 + ( 4 * combo_points.current ) )
                debuff.rupture.pmultiplier = persistent_multiplier
                debuff.rupture.exsanguinated = false

                if azerite.scent_of_blood.enabled then
                    applyBuff( "scent_of_blood", dot.rupture.remains )
                end

                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )
            end,
        },


        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132310,

            usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth" end,
            handler = function ()
                applyDebuff( "target", "sap" )
                removeBuff( "sepsis_buff" )
            end,
        },


        shadowstep = {
            id = 36554,
            cast = 0,
            charges = 1,
            cooldown = function ()
                return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 ) * ( pvptalent.intent_to_kill.enabled and debuff.vendetta.up and 0.1 or 1 )
            end,
            recharge = function ()
                if pvptalent.intent_to_kill.enabled and debuff.vendetta.up then return 10 end
                return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 )
            end,                
            gcd = "spell",

            startsCombat = false,
            texture = 132303,

            handler = function ()
                applyBuff( "shadowstep" )
                setDistance( 5 )
            end,
        },
        

        shiv = {
            id = 5938,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            spend = function () return legendary.tiny_toxic_blade.enabled and 0 or 20 end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135428,
            
            handler = function ()
                gain( 1, "combo_points" )
                applyDebuff( "target", "crippling_poison_shiv" )
                
                if level > 57 then applyDebuff( "target", "shiv" ) end

                if conduit.wellplaced_steel.enabled and debuff.envenom.up then
                    debuff.envenom.expires = debuff.envenom.expires + conduit.wellplaced_steel.mod
                end
            end,

            auras = {
                crippling_poison_shiv = {
                    id = 115196,
                    duration = 9,
                    max_stack = 1,        
                },
                shiv = {
                    id = 319504,
                    duration = 9,
                    max_stack = 1,
                },
            }
        },


        shroud_of_concealment = {
            id = 114018,
            cast = 0,
            cooldown = 360,
            gcd = "spell",

            startsCombat = false,
            texture = 635350,

            usable = function () return stealthed.all, "requires stealth" end,
            handler = function ()
                applyBuff( "shroud_of_concealment" )
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,
        },


        sprint = {
            id = 2983,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 132307,

            handler = function ()
                applyBuff( "sprint" )
            end,
        },


        stealth = {
            id = 1784,
            cast = 0,
            cooldown = 2,
            gcd = "spell",

            startsCombat = false,
            texture = 132320,

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up, "requires out of combat and not stealthed" end,            
            handler = function ()
                applyBuff( "stealth" )

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,

            auras = {
                -- Conduit
                cloaked_in_shadows = {
                    id = 341530,
                    duration = 3600,
                    max_stack = 1
                },
                -- Conduit
                fade_to_nothing = {
                    id = 341533,
                    duration = 3,
                    max_stack = 1
                }
            }
        },


        tricks_of_the_trade = {
            id = 57934,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 236283,

            handler = function ()
                applyBuff( "tricks_of_the_trade" )
            end,
        },


        vanish = {
            id = 1856,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 132331,

            disabled = function ()
                return not settings.solo_vanish and not ( boss and group ), "can only vanish in a boss encounter or with a group"
            end,

            handler = function ()
                applyBuff( "vanish" )
                applyBuff( "stealth" )

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end -- ???
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end

                if legendary.invigorating_shadowdust.enabled then
                    for name, cd in pairs( cooldown ) do
                        if cd.remains > 0 then reduceCooldown( name, 20 ) end
                    end
                end
            end,
        },


        vendetta = {
            id = 79140,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 458726,

            aura = "vendetta",

            handler = function ()
                applyDebuff( "target", "vendetta" )
                applyBuff( "vendetta_regen" )
                if azerite.nothing_personal.enabled then
                    applyDebuff( "target", "nothing_personal" )
                    applyBuff( "nothing_personal_regen" )
                end
            end,
        },


        wound_poison = {
            id = 8679,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            texture = 134197,

            readyTime = function () return buff.lethal_poison.remains - 120 end,
            
            handler = function ()
                applyBuff( "wound_poison" )
            end,
        },


        apply_poison = {
            name = _G.MINIMAP_TRACKING_VENDOR_POISON,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            texture = function ()
                if buff.lethal_poison.down or level < 33 then
                    return state.spec.assassination and level > 12 and class.abilities.deadly_poison.texture or class.abilities.instant_poison.texture
                end
                if level > 32 and buff.nonlethal_poison.down then return class.abilities.crippling_poison.texture end
            end,

            usable = function ()
                return buff.lethal_poison.down or level > 32 and buff.nonlethal_poison.down, "requires missing poison"
            end,

            handler = function ()
                if buff.lethal_poison.down then
                    applyBuff( state.spec.assassination and level > 12 and "deadly_poison" or "instant_poison" )
                elseif level > 32 then applyBuff( "crippling_poison" ) end
            end,
        },


        -- Covenant Abilities
        -- Rogue - Kyrian    - 323547 - echoing_reprimand    (Echoing Reprimand)
        echoing_reprimand = {
            id = 323547,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = function () return 10 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 3565450,

            toggle = "essences",

            handler = function ()
                -- Can't predict the Animacharge, unless you have the legendary.
                if legendary.resounding_clarity.enabled then
                    applyBuff( "echoing_reprimand_2", nil, 2 )
                    applyBuff( "echoing_reprimand_3", nil, 3 )
                    applyBuff( "echoing_reprimand_4", nil, 4 )
                    applyBuff( "echoing_reprimand_5", nil, 5 )
                end
                gain( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + 2, "combo_points" )
            end,

            disabled = function ()
                return covenant.kyrian and not IsSpellKnownOrOverridesKnown( 323547 ), "you have not finished your kyrian covenant intro"
            end,

            auras = {
                echoing_reprimand_2 = {
                    id = 323558,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand_3 = {
                    id = 323559,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand_4 = {
                    id = 323560,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand_5 = {
                    id = 354838,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand = {
                    alias = { "echoing_reprimand_2", "echoing_reprimand_3", "echoing_reprimand_4", "echoing_reprimand_5" },
                    aliasMode = "first",
                    aliasType = "buff",
                    meta = {
                        stack = function ()
                            if combo_points.current > 1 and buff[ "echoing_reprimand_" .. combo_points.current ].up then return combo_points.current end

                            if buff.echoing_reprimand_2.up then return 2 end
                            if buff.echoing_reprimand_3.up then return 3 end
                            if buff.echoing_reprimand_4.up then return 4 end
                            if buff.echoing_reprimand_5.up then return 5 end

                            return 0
                        end
                    }
                }
            }
        },

        -- Rogue - Necrolord - 328547 - serrated_bone_spike  (Serrated Bone Spike)
        serrated_bone_spike = {
            id = 328547,
            cast = 0,
            charges = function () return legendary.deathspike.equipped and 5 or 3 end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 3578230,

            toggle = "essences",

            cycle = "serrated_bone_spike",

            handler = function ()
                applyDebuff( "target", "serrated_bone_spike" )
                gain( ( buff.broadside.up and 1 or 0 ) + active_dot.serrated_bone_spike, "combo_points" )
                -- TODO:  Odd behavior on target dummies.
            end,

            auras = {
                serrated_bone_spike = {
                    id = 324073,
                    duration = 3600,
                    max_stack = 1,
                    copy = "serrated_bone_spike_dot",
                },
            }
        },

        -- Rogue - Night Fae - 328305 - sepsis               (Sepsis)
        sepsis = {
            id = 328305,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 3636848,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "sepsis" )
            end,

            auras = {
                sepsis = {
                    id = 328305,
                    duration = 10,
                    max_stack = 1,
                },
                sepsis_buff = {
                    id = 347037,
                    duration = 5,
                    max_stack = 1
                }
            }
        },

        -- Rogue - Venthyr   - 323654 - flagellation         (Flagellation)
        flagellation = {
            id = 323654,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = 0,
            spendType = "energy",
            
            startsCombat = true,
            texture = 3565724,

            toggle = "essences",

            handler = function ()
                applyBuff( "flagellation" )
                applyDebuff( "target", "flagellation", 30 )
            end,

            auras = {
                flagellation = {
                    id = 323654,
                    duration = 12,
                    max_stack = 30,
                    generate = function( t, aType )
                        local unit, func

                        if aType == "debuff" then
                            unit = "target"
                            func = FindUnitDebuffByID
                        else
                            unit = "player"
                            func = FindUnitBuffByID
                        end
                        
                        local name, _, count, _, duration, expires, caster = func( unit, 323654 )

                        if name then
                            t.count = 1
                            t.duration = duration
                            t.expires = expires
                            t.applied = expires - duration
                            t.caster = "player"
                            return
                        end
            
                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end,
                    copy = "flagellation_buff"
                },
            },
        },


        -- PvP Talents
        shadowy_duel = {
            id = 207736,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            
            pvptalent = "shadowy_duel",

            startsCombat = false,
            texture = 1020341,

            usable = function () return target.is_player, "requires a player target" end,
            
            handler = function ()
                applyBuff( "shadowy_duel" )
            end,

            auras = {
                shadowy_duel = {
                    id = 210558,
                    duration = 6,
                    max_stack = 1,
                },        
            }
        },

        smoke_bomb = {
            id = 212182,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            pvptalent = "smoke_bomb",

            startsCombat = false,
            texture = 458733,
            
            handler = function ()
                applyDebuff( "player", "smoke_bomb" )
                if target.within8 then applyDebuff( "target", "smoke_bomb" ) end
            end,

            auras = {
                smoke_bomb = {
                    id = 212183,
                    duration = 5,
                    max_stack = 1,
                },        
            }
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "phantom_fire",

        package = "Assassination",
    } )


    spec:RegisterSetting( "priority_rotation", false, {
        name = "Funnel AOE -> Target",
        desc = "If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present.",
        type = "toggle",
        width = 1.5
    } )

    spec:RegisterSetting( "envenom_pool_pct", 50, {
        name = "Energy % for |T132287:0|t Envenom",
        desc = "If set above 0, the addon will pool to this Energy threshold before recommending |T132287:0|t Envenom.",
        type = "range",
        min = 0,
        max = 100,
        step = 1,
        width = 1.5
    } )

    spec:RegisterStateExpr( "envenom_pool_deficit", function ()
        return energy.max * ( ( 100 - ( settings.envenom_pool_pct or 100 ) ) / 100 )
    end )

    spec:RegisterSetting( "mfd_points", 3, {
        name = "|T236340:0|t Marked for Death Combo Points",
        desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
        type = "range",
        min = 0,
        max = 5,
        step = 1,
        width = "full"
    } )

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "allow_shadowmeld", nil, {
        name = "Allow |T132089:0|t Shadowmeld",
        desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
            "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled = not val
        end,
    } )     


    spec:RegisterPack( "Assassination", 20210628, [[de1utcqiKOEKOQCjcfYMOQ6tGqJcKCkq0QukLxrvXSOcDlLsSlL8lqWWqs6yQKwgHQNjQW0OcCnrv12iuIVrOqnoQkPoNsjP1rOO3PuQszEirUhHSpQi)tPuL4GIkQfIK4HuvQjQusDrQGAJkLeFKqbJKqjjNuPuvRej1ljusmtQkXnPQKStrv(PsPkvdvPuzPek1tjYufv6Qekj1wPcYxvkvXyfvK9kP)cQbt5WclMQ8yvmzjUm0MrQptuJwL60sTALsvsVwLy2ICBrz3k(nWWPshNqj1Yv1ZrmDsxNGTRu9DqQXtf15rcZxPy)OUETMBvQekwZtCQk(vQkwe3xVeph5Wx7ahuLukCXQKBCUeYyvAImSkLZesqi9eAdMQKBqrceLAUvjcq4pyv6wvxIycbii36TG36aYGaPZesH2G58bTcbsNDGqvYtOt62FQEvPsOynpXPQ4xPQyrCF9s8CKdFDo2QvPqqVbFvsQZ8Dv6UlfCQEvPcsovPCMqccPNqBWWMydKfqMAQfgKnX91oYM4uv8Rm1m1((ogzKiMm1BHTC21nrbBqKOFFuiYgDkKztbSraziB5825lSrd(le2uaBKyhzZ9bhKq6rMnTZWft9wyBRbdev2COyAYnBctcje2Ks9bzlMcBBDFq2GUtj2sbrzlbgz8ztVJHnFvqu8zlNjKGq6zXuVf2eBmfoZ2wjfYykfAdg2GaBoeofu1GncfZHnOAA2CiCkOQbBnHnfilNWcBaAA2apBGHTGTeyKzZ3BnKRQuQjkPMBvIOyK0BSuZTM31AUvjCcVewQuPkfhTbtv68DgbmWkM5IeTkvqY5BxTbtvkVw(MOr6c(Sbg2YrUIjB((7mcyylxmZfjAv68TIFhvjns4ORPLVvIgPl4VWj8syHn)SrCXucwJxgvcBojITCWMF2oGmpaSlOhLWMtIyZbS5NnnEzuxANHWkaU0iBBHThZIEiS5eBILQwZt8AUvjCcVewQuPkfhTbtv6fCvHhRsfKC(2vBWuLYRLVjAKUGpBGHTR5kMSjnHl5gOSj2cUQWJvPZ3k(DuL0iHJUMw(wjAKUG)cNWlHf28Z2bK5bGDb9Oe2CseBoGn)SPXlJ6s7mewbWLgzBlS9yw0dHnNytSu1AE5OMBvcNWlHLkvQsXrBWuLCbGe8JeGWFWQubjNVD1gmvjjbpfFAbzumzlNDDtuWg4ztSr6hj3SbDR3S5jqtJf2edX)afjvjAWdpOZAnVRvTMNdQ5wLWj8syPsLQuC0gmvj54FGIvPZ3k(DuL0iHJUicEk(0cY4cNWlHf28ZguS9yw0dHnkX2vXzBZg2CZesA7MA8zJsIy7kBqYMF204LrDPDgcRa4sJSTf2Eml6HWMtSjEv6qXjHWA8YOsQ5DTQ18YFn3QeoHxclvQuLIJ2GPk5caj4hjaH)GvPcsoF7QnyQsscEk(0cYiB(WMd7mrMnWW21Cft2eBK(rYnBIH4FGISfkB6nYgof2a0Srums6nBkGnzuzllCMTIWhAdg28qAWJS5WotIrwONqXQen4Hh0zTM31QwZtSuZTkHt4LWsLkvPZ3k(DuL0iHJUicEk(0cY4cNWlHf28ZMgjC0f6mjgzHEcfx4eEjSWMF2IJ27imoywJe2eX2v28ZMNan9Ii4P4tliJRhZIEiSrj2UUYrvkoAdMQKC8pqXQwZtmUMBvcNWlHLkvQsNVv87OkPrchDre8u8PfKXfoHxclS5NTdiZda7c6rjSrjrSLJQuC0gmvPmbTtHIvTQvP9yAYDn3AExR5wLWj8syPsLQeWTkrqTkfhTbtvAp(o8syvApscyvck2OmBVWG0Gxgxfm07efWK7OaGMSWj8syHn)SH004r7De(aY8aWUGEucBojITJlCw4mmXfNcBqY2MnSbfBVWG0Gxgxfm07efWK7OaGMSWj8syHn)SDazEayxqpkHnkXM4SbzvQGKZ3UAdMQ0wPNMCZg0TEZww4mB(E7yJg8SLxlFRensxW3r2eMesiSjq6rMTTgd9orbBs3rbanPkThp8ezyvAA5BLOr6c(Whx4dykT2GPQ18eVMBvcNWlHLkvQsXrBWuL2JPj3vPcsoF7QnyQsoumn5MnOB9Mnh2zImB(WwET8Ts0iDbFXKnFv4CNjKXMV3o2IPWMd7mrMThJcfSrdE2g0zLnXGV36Q05Bf)oQsAKWrxOZKyKf6juCHt4LWcB(ztJeo6AA5BLOr6c(lCcVewyZpB7X3HxcxtlFRensxWh(4cFatP1gmS5NTdaKkaONf6mjgzHEcfxpMf9qyJsSDTQ18Yrn3QeoHxclvQuLIJ2GPkThttURsfKC(2vBWuLCOyAYnBq36nB51Y3krJ0f8zZh2YdWMd7mrwmzZxfo3zczS57TJTykS5q4uqvd2eCRsNVv87OkPrchDnT8Ts0iDb)foHxclS5NnkZMgjC0f6mjgzHEcfx4eEjSWMF22JVdVeUMw(wjAKUGp8Xf(aMsRnyyZpBf0tGMETJtbvnwcUvTMNdQ5wLWj8syPsLQuC0gmvjxaib)ibi8hSkHoRFahzaHrRsoi)vjAWdpOZAnVRvTMx(R5wLWj8syPsLQ05Bf)oQsAKWrxebpfFAbzCHt4LWcB(z7aaPca6zjh)duCj4YMF2GITcqxYX)afxps)i5o8siBB2Wwb9eOPx74uqvJLGlB(zRa0LC8pqXLBMqsB3uJpBuseBxzds28Z2bK5bGDb9OKvbP7tRS5Ki2GInIlMsWA8YOsw0XadOHVm9osyZPTxyZbSbjB(z7JUaJ74OROuiREyZj2UkEvkoAdMQ0Emn5UQ18el1CRs4eEjSuPsvkoAdMQ0Emn5UkvqY5BxTbtvYHIPj3SbDR3S5RcIIpB5mHeKEet2eBbxv4rFedX)afzBakB9W2J0psUz7JrgDKTIW3JmBoeofu1WhP7EFXMefZHnOB9Mnj0L0e2O7jsSD3kBnnBUacP9s4QkD(wXVJQeuSPrchDLfefF4GqccPNfoHxclSTzdBVWG0GxgxzXFbgqdR3iCwqu8HdcjiKEw4eEjSWgKS5NnkZwbORxWvfEC9i9JK7WlHS5NTcqxYX)afxpMf9qyZj2YbB(zRGEc00RDCkOQXsWLn)SbfBf0tGMErU79LGlBB2Wwb9eOPx74uqvJ1Jzrpe2OeBoGTnByRa0fbDjnzP95spYSbjB(zRa0fbDjnz9yw0dHnkXwoQAvRsfKoesAn3AExR5wLIJ2GPkDPpxQs4eEjSuPsvR5jEn3QeoHxclvQuLki58TR2GPkj2irXiP3S10S5ciK2lHSb1ayBxin4hEjKnCWSgjS1dBhqMxOqwLIJ2GPkrums6DvR5LJAUvjCcVewQuPkbCRseuRsXrBWuL2JVdVewL2JKawLiUykbRXlJkzrhdmGg(Y07iHnkXM4vP94HNidRsKEKtiSgVmQvTMNdQ5wLWj8syPsLQeWTkrqTkfhTbtvAp(o8syvApscyvch8LPy9OmoWhqMxpyHnNylh5VkvqY5BxTbtvY3GmVEWcBo8GVmfSj2OmoSniwWcBkGnsOcFOyvApE4jYWQ0JY4atcv4dflvTMx(R5wLWj8syPsLQ05Bf)oQsefJKEJL1dKfWQer)(O18UwLIJ2GPkDIucooAdg4ut0QuQjk8ezyvIOyK0BSu1AEILAUvjCcVewQuPkD(wXVJQeuSrz20iHJUYcIIpCqibH0ZcNWlHf22SHTcqxYX)afxAFU0JmBqwLi63hTM31QuC0gmvPtKsWXrBWaNAIwLsnrHNidRsNcPQ18eJR5wLWj8syPsLQuC0gmvjsQpiCmf4sFWQubjNVD1gmvPTtqztA2A2eCzRNw7iLOGnAWZMVfu2uaB6nYMVVdc6iBps)i5MnOB9MnhE2XbKXwtZwOSLaqZwr4dTbtv68TIFhvjkZMNan9IK6dchtbU0hCj4YMF2oGmpaSlOhLWMtIy7AvR55RR5wLWj8syPsLQ05Bf)oQsEc00lsQpiCmf4sFWLGlB(zZtGMErs9bHJPax6dUEml6HWgLyl)S5NTdiZda7c6rjS5Ki2CqvkoAdMQeo74aYQAnVTAn3QeoHxclvQuLIJ2GPkDIucooAdg4ut0QuQjk8ezyvQa0QwZ7kvR5wLWj8syPsLQuC0gmvPtKsWXrBWaNAIwLsnrHNidRsL(XJw1AExVwZTkHt4LWsLkvPZ3k(DuLWbFzkwfKUpTYMtIy7A(zZh2WbFzkwpkJd8bK51dwQsXrBWuLI)edcRG)XrRAnVRIxZTkfhTbtvk(tmiSRqIGvjCcVewQuPQ18UMJAUvP4OnyQsPw(wjWBVkuKZWrRs4eEjSuPsvR5D1b1CRsXrBWuL8czyanS(95cPkHt4LWsLkvTQvj3hpGmVqR5wZ7An3QuC0gmvPW1nrbSlOjGPkHt4LWsLkvTMN41CRsXrBWuL8aQMWcmDkOalq3JmScCUNQeoHxclvQu1AE5OMBvcNWlHLkvQsXrBWuLYI)cwGPbpCbd9UkD(wXVJQ0hDbg3XrxrPqw9WMtSDn)vj3hpGmVqHj4bmfsvk)vTMNdQ5wLWj8syPsLQ05Bf)oQseGqYRNYYvGOcjegFbxTbZcNWlHLQuC0gmvj6esUpFqRvTMx(R5wLWj8syPsLQeWTkrqTkfhTbtvAp(o8syvApscyv6kBBHnOy7fgKg8Y4QiqUaDKUGpb2n0Z9cNWlHf22gBuD5G8ZgKvP94HNidRs74uqvd4t5RAnpXsn3QeoHxclvQuLaUvjcQvP4OnyQs7X3HxcRs7rsaRsxzBlSbfBVWG0GxgxapS04CWfoHxclSTn2O6YboGniRsfKC(2vBWuLY9gzl2XpKr289wl2S1e2O6sCXzZtqzRiGSPa20BKnXopXaBtOcpYgGMnFVDSjJJJSjUZSP3nHT9ijGS1e2aUANfj2ObpBekMtpYSLaY9PkThp8ezyvIofYykfAdg4t5RAnpX4AUvjCcVewQuPkbCRseuRsXrBWuL2JVdVewL2JhEImSkPFpxqfMqXCGjjGwLoFR43rvs)EUG6sVUUdcSabH9eOPzZpBqXgLzt)EUG6sfFDheybcc7jqtZ2MnSPFpxqDPxxhaivaqpRIWhAdg2CseB63ZfuxQ4RdaKkaONvr4dTbdBqY2MnSPFpxqDPxxnz1d58cA4LqyXAHyuHm4cU3hSkvqY5BxTbtvARrf)SEq2G(Up3SbvtZwmuajBenu28eOPzt)EUGkBqJSbDmkBkGTqvmZvztbSrOyoSbDR3S5q4uqvJvvApscyv6AvR55RR5wLWj8syPsLQeWTkrqTkfhTbtvAp(o8syvApscyvs8Q05Bf)oQs63ZfuxQ4R7GalqqypbAA28ZguSrz20VNlOU0RR7GalqqypbAA22SHn975cQlv81basfa0ZQi8H2GHnNyt)EUG6sVUoaqQaGEwfHp0gmSbjBB2WM(9Cb1Lk(QjREiNxqdVeclwleJkKbxW9(GvP94HNidRs63ZfuHjumhyscOvTM3wTMBvcNWlHLkvQsXrBWuLiP(GWXuGl9bRsNVv87Ok9i9JK7WlHvj3hpGmVqHj4bmfsv6AvR5DLQ1CRsXrBWuLikgj9UkHt4LWsLkvTQvPs)4rR5wZ7An3QeoHxclvQuLIJ2GPkHZooGSQubjNVD1gmvjhE2XbKXwOS5aFydQ87dBq36nBBTeKS57TBX22pldlDOyIc2adBI7dBA8YOsCKnOB9MnhcNcQA4iBGNnOB9MTCPIJSb0B8HUjiBqhTYgn4zJaYq2WbFzkwSLZjcGnOJwzRPzZHDMiZ2bK5byRjSDaz9iZMG7QkD(wXVJQestJhT3r4diZda7c6rjS5Ki2CaB(WMgjC0vbrx8Hj6hAiJzlCcVewyZpBqXwb9eOPx74uqvJLGlBB2Wwb9eOPxK7EFj4Y2MnSvqpbA6fDkKXuk0gmlbx22SHnCWxMIvbP7tRSrjrSjE(zZh2WbFzkwpkJd8bK51dwyBZg2OmB7X3HxcxKEKtiSgVmQSbjB(zdk2OmBAKWrxOZKyKf6juCHt4LWcBB2W2basfa0ZcDMeJSqpHIRhZIEiS5eBIZgKvTMN41CRs4eEjSuPsvc4wLiOwLIJ2GPkThFhEjSkThjbSkDazEayxqpkzvq6(0kBoX2v22SHnCWxMIvbP7tRSrjrSjE(zZh2WbFzkwpkJd8bK51dwyBZg2OmB7X3HxcxKEKtiSgVmQvP94HNidRsceeMUtj8RAnVCuZTkHt4LWsLkvP4OnyQse8)qXcShyqyIBFbRsfKC(2vBWuLYzx3efSjrfj2uaBrkXMgVmQe2GU1BGGYwWwb9eOPzliS5(n4BLchzZ9rA8)EKztJxgvcBfk6rMncam4ZwqR4ZMEJS5(Dw8uWMgVmQvPZ3k(DuL2JVdVeUeiimDNs4ZMF2OmBfGUi4)HIfypWGWe3(ccxa6s7ZLEKRAnphuZTkHt4LWsLkvP4OnyQse8)qXcShyqyIBFbRsNVv87OkThFhEjCjqqy6oLWNn)Srz2kaDrW)dflWEGbHjU9feUa0L2Nl9ixLouCsiSgVmQKAExRAnV8xZTkHt4LWsLkvP4OnyQse8)qXcShyqyIBFbRsfKC(2vBWuL2EUXHnFvoZwtyBakBHY2DlFZwr4dTbJJSjqq2KOIeBkGTW1nrbB(cgf28OGnh25iZnHSve(EKzZHWPGQgoYgqVXh6MGSDbrx2OFqgBNW1Thz2o3XlJKQ05Bf)oQs7X3HxcxceeMUtj8zZpBzbrXhoiKGq6b(XSOhcBuInQU81S5NnOyJULVv4hZIEiSrjrSLF22SHTdaKkaONfb)puSa7bgeM42xWvw4m85oEzKW2wy7ChVmsGP)4OnyIeBuseBuDjE(zBZg2iaHKxpLvcJcShfWOZrMBcx4eEjSWMF2OmBEc00RegfypkGrNJm3eUeCzZpBf0tGMETJtbvnwcUSTzdBEc00RS4Fa0ybwgZikyqyCUJ5Gz4Olbx2GSQ18el1CRs4eEjSuPsvkoAdMQeDmWaA4ltVJKQubjNVD1gmvPTsmSbOztSY07iHTqz76w1h2iACUqydqZMyvDPGdBujffKWg4zlKJEikBoWh204LrLSQsNVv87OkThFhEjCjqqy6oLWNn)SbfBEc00R7UuWb2lffKSiACUWMtIy76wLTnBydk2OmBUFd(wPa(bAOnyyZpBexmLG14LrLSOJbgqdFz6DKWMtIyZbS5dBefJKEJL1dKfq2GKniRAnpX4AUvjCcVewQuPkfhTbtvIogyan8LP3rsv6qXjHWA8YOsQ5DTkD(wXVJQeuSrz2C)g8Tsb8d0qBWW2MnSva6so(hO4s7ZLEKzBZg2kaD9cUQWJlTpx6rMnizZpB7X3HxcxceeMUtj8zZpBexmLG14LrLSOJbgqdFz6DKWMtIylhvPcsoF7QnyQsBLyydqZMyLP3rcBkGTW1nrbBUGMagcBnnB9ehT3r2adBXqbBA8YOYguGNTyOGnVeILEKztJxgvcBq36nBUFd(wPGThOH2Gbs2cLTCKBvR55RR5wLWj8syPsLQ05Bf)oQs7X3HxcxceeMUtj8zZpBhaivaqpRDCkOQX6XSOhcBoX2vQwLIJ2GPkHNBqpYWp6(DwmLQwZBRwZTkHt4LWsLkvPZ3k(DuL2JVdVeUeiimDNs4ZMF2GITSGO4dhesqi9a)yw0dHnrSrv28ZgLz7fgKg8Y4QaazEPOGlCcVewyBZg28eOPxEPEkKUGlbx2GSkfhTbtvkY8ei3vTM3vQwZTkHt4LWsLkvP4OnyQszcANcfRshkojewJxgvsnVRvPZ3k(DuL2JVdVeUeiimDNs4ZMF2iUykbRXlJkzrhdmGg(Y07iHnrSjEvQGKZ3UAdMQuUH3w8vcANcfztbSfUUjkyBRXOKOGTTd0eWWwOSjoBA8YOsQAnVRxR5wLWj8syPsLQ05Bf)oQs7X3HxcxceeMUtj8RsXrBWuLYe0ofkw1QwLofsn3AExR5wLWj8syPsLQuC0gmvPS4VGfyAWdxWqVRsPEq4tPkDDL)Q0HItcH14LrLuZ7Av68TIFhvPp6cmUJJUIsHSeCzZpBqXMgVmQlTZqyfaxAKnkX2bK5bGDb9OKvbP7tRSTn2UUYpBB2W2bK5bGDb9OKvbP7tRS5Ki2oUWzHZWexCkSbzvQGKZ3UAdMQ02NMTOuiSfpYMGRJSrM2fztVr2adYg0TEZwcansu2Yn3TEXMy1eKnOVXHTcf9iZgDqu8ztVJHnFVDSvq6(0kBGNnOB9giOSfdfS57TBv1AEIxZTkHt4LWsLkvP4OnyQszXFblW0GhUGHExLki58TR2GPkT9PzBaSfLcHnO7uITsJSbDR39WMEJSnOZkB5GQehztGGS5RO3A2adBEacHnOB9giOSfdfS57TBvLoFR43rv6JUaJ74OROuiREyZj2YbvzBlS9rxGXDC0vukKvr4dTbdB(z7aY8aWUGEuYQG09Pv2CseBhx4SWzyIloLQwZlh1CRs4eEjSuPsvkoAdMQeDcj3NpO1QubjNVD1gmvPTscj3NpOv2ObpBBNarfsiBo8l4QnyyRPzBakBefJKEJf2apB9WwW2basfa0dBhkojSkD(wXVJQebiK86PSCfiQqcHXxWvBWSWj8syHn)Srz2ikgj9glRiLyZpBuMTc6jqtV2XPGQglbx28Zwwqu8HdcjiKEGFml6HWMi2OkB(zdk2WbFzkwANHWkaolCg(aY86blS5eBIZ2MnSrz2kONan9IC37lbx2GSQ18Cqn3QeoHxclvQuLIJ2GPkrNczmLcTbtvQGKZ3UAdMQKefZHTTskKXuk0gmSbDR3S5q4uqvd2ccBjWiZwqydAKnObdev2sacYwW2jikBGD8ztVr2OB5BLTIWhAdg2Gc8S10S5q4uqvd2GUtj2oGmKnV4CHTqo6bcnHnfilNWcBaAAixvPZ3k(DuLOmBefJKEJL1dKfq28ZguSbfBhaivaqpRDCkOQX6XSOhcBoX2wLQSTzdBhaivaqpRDCkOQX6XSOhcBuITCWgKS5NnKMgpAVJWhqMha2f0JsyZjrS5a28ZMgVmQlTZqyfaxAKnNy7kvzBZg2kONan9AhNcQASeCzBZg28aecB(zJULVv4hZIEiSrj2e3bSbzvR5L)AUvjCcVewQuPkD(wXVJQeLzJOyK0BSSEGSaYMF2qAA8O9ocFazEayxqpkHnNeXMdyZpBqXgDcaE2GInOyJULVv4hZIEiSTf2e3bSbjBqGnOyloAdg4daKkaOh22gB7X3Hxcx0PqgtPqBWaFkpBqYgKS5eB0ja4zdk2GIn6w(wHFml6HW2wytChW2wy7aaPca6zTJtbvnwpMf9qyBBSThFhEjCTJtbvnGpLNnizdcSbfBXrBWaFaGuba9W22yBp(o8s4IofYykfAdg4t5zds2GKniRsXrBWuLOtHmMsH2GPQ18el1CRs4eEjSuPsvkoAdMQebDjnPkvqY5BxTbtvsII5WMe6sAcBq36nBoeofu1GTGWwcmYSfe2GgzdAWarLTeGGSfSDcIYgyhF20BKn6w(wzRi8H2GXr28eu2CFKgF204LrLWMEhkBq3PeBPEhzlu2syqu2Usvsv68TIFhvjkZgrXiP3yz9azbKn)SbfBhaivaqpRDCkOQX6XSOhcBuITRS5NnnEzuxANHWkaU0iBoX2vQY2MnSvqpbA61oofu1yj4Y2MnSr3Y3k8Jzrpe2OeBxPkBqw1AEIX1CRs4eEjSuPsv68TIFhvjkZgrXiP3yz9azbKn)SbfB0ja4zdk2GIn6w(wHFml6HW2wy7kvzds2GaBXrBWaFaGuba9WgKS5eB0ja4zdk2GIn6w(wHFml6HW2wy7kvzBlSDaGuba9S2XPGQgRhZIEiSTn22JVdVeU2XPGQgWNYZgKSbb2IJ2Gb(aaPca6HnizdYQuC0gmvjc6sAsvR55RR5wLWj8syPsLQeWTkrqTkfhTbtvAp(o8syvApscyvIYSPrchDnT8Ts0iDb)foHxclSTzdBuMnns4Ol0zsmYc9ekUWj8syHTnBy7aaPca6zHotIrwONqX1Jzrpe2OeB5NTTWM4STn20iHJUki6Ipmr)qdzmBHt4LWsvQGKZ3UAdMQKefZHnhcNcQAWg09uaqZg0TEZwET8Ts0iDbFFCyNjXil0tOiBnnBHRBQpHxcRs7XdprgwL2XPGQgWtlFRensxWh(aMsRnyQAnVTAn3QeoHxclvQuLaUvjcQvP4OnyQs7X3HxcRs7XdprgwL2XPGQgWhWooXOWhWuATbtv68TIFhvPdyhNy01fk(og22SHTdyhNy01GNhKaFHTnBy7a2XjgDnGbRsfKC(2vBWuLKOyoS5q4uqvd2GU1B22kPqgtPqBWWwmf2KqxstyliSLaJmBbHnOr2GgmquzlbiiBbBNGOSb2XNn9gzJULVv2kcFOnyQs7rsaRsxRAnVRuTMBvcNWlHLkvQsa3Qeb1QuC0gmvP947WlHvP9ijGvj6ea8SbfBqXgDlFRWpMf9qyBlSjovzds2GaBqX2vXPkBBJT947WlHRDCkOQb8P8SbjBqYMtSrNaGNnOydk2OB5Bf(XSOhcBBHnXPkBBHTdaKkaONfDkKXuk0gmRhZIEiSbjBqGnOy7Q4uLTTX2E8D4LW1oofu1a(uE2GKnizBZg28eOPx0PqgtPqBWa7jqtVeCzBZg2kONan9IofYykfAdMLGlBB2WgDlFRWpMf9qyJsSjovRsNVv87OkDa74eJU2XrVP4Rs7XdprgwL2XPGQgWhWooXOWhWuATbtvR5D9An3QeoHxclvQuLaUvjcQvP4OnyQs7X3HxcRs7rsaRs0ja4zdk2GIn6w(wHFml6HW2wytCQYgKSbb2GITRItv22gB7X3Hxcx74uqvd4t5zds2GKnNyJobapBqXguSr3Y3k8Jzrpe22cBItv22cBhaivaqplc6sAY6XSOhcBqYgeydk2UkovzBBSThFhEjCTJtbvnGpLNnizds22SHTcqxe0L0KL2Nl9iZ2MnSr3Y3k8Jzrpe2OeBIt1Q05Bf)oQshWooXORPLVvy6aRs7XdprgwL2XPGQgWhWooXOWhWuATbtvR5Dv8AUvjCcVewQuPkD(wXVJQeLzJOyK0BSSEGSaYMF2kaD9cUQWJlTpx6rMn)Srz2kONan9AhNcQASeCzZpB7X3Hxcx74uqvd4PLVvIgPl4dFatP1gmS5NT947WlHRDCkOQb8bSJtmk8bmLwBWuLIJ2GPkTJtbvnQAnVR5OMBvcNWlHLkvQsXrBWuLqNjXil0tOyvQGKZ3UAdMQKd7mjgzHEcfzd6BCyBakBefJKEJf2IPWMhqVztSfCvHhzlMcBIH4FGISfpYMGlB0GNTeyKzdhGG89QkD(wXVJQeLzJOyK0BSSEGSaYMF2GInkZwbOl54FGIRhPFKChEjKn)Sva66fCvHhxpMf9qyZj2CaB(WMdyBBSDCHZcNHjU4uyBZg2kaD9cUQWJRhZIEiSTn2O6k)S5eBA8YOU0odHvaCPr2GKn)SPXlJ6s7mewbWLgzZj2CqvR5D1b1CRs4eEjSuPsvkoAdMQe5U3RsfKC(2vBWuLKU7D2AA2GgzlEKTWdiOSPa2C4zhhqMJSftHTqvmZvztbSrOyoSbDR3SjHUKMWgDprIT7wzRPzdAKnObdev2GoikYwg4r207yy7os0SP3iBhaivaqpRQ05Bf)oQsfGUEbxv4XL2Nl9iZMF2GInkZ2basfa0ZIGUKMSEmkuW2MnSDaGuba9S2XPGQgRhZIEiS5eBxfNnizBZg2kaDrqxstwAFU0JCvR5Dn)1CRs4eEjSuPsv68TIFhvjpbA6LxcakjbIUEmokBB2WMhGqyZpB0T8Tc)yw0dHnkXwoOkBB2Wwb9eOPx74uqvJLGBvkoAdMQKlqBWu1AExfl1CRs4eEjSuPsv68TIFhvPc6jqtV2XPGQglb3QuC0gmvjVeauGPfEkQAnVRIX1CRs4eEjSuPsv68TIFhvPc6jqtV2XPGQglb3QuC0gmvjp8j4FPh5QwZ7QVUMBvcNWlHLkvQsNVv87OkvqpbA61oofu1yj4wLIJ2GPkr3p6LaGsvR5DDRwZTkHt4LWsLkvPZ3k(DuLkONan9AhNcQASeCRsXrBWuLI5Ge9Je8jsPQwZtCQwZTkHt4LWsLkvPZ3k(DuLOmBefJKEJLvKsS5NTSGO4dhesqi9a)yw0dHnrSr1QuC0gmvPtKsWXrBWaNAIwLsnrHNidRs7X0K7QwZt8R1CRs4eEjSuPsvkoAdMQK(9Cb1RvPcsoF7QnyQssumh20BKn3VbFRuWgrdLnpbAA20VNlOYg0TEZMdHtbvnCKnGEJp0nbztGGSbg2oaqQaGEQsNVv87OkThFhEjCPFpxqfMqXCGjjGYMi2UYMF2GITc6jqtV2XPGQglbx22SHnpaHWMF2OB5Bf(XSOhcBuseBItv2GKTnBydk22JVdVeU0VNlOctOyoWKeqzteBIZMF2OmB63ZfuxQ4RdaKkaON1JrHc2GKTnByJYSThFhEjCPFpxqfMqXCGjjGw1AEIlEn3QeoHxclvQuLoFR43rvAp(o8s4s)EUGkmHI5atsaLnrSjoB(zdk2kONan9AhNcQASeCzBZg28aecB(zJULVv4hZIEiSrjrSjovzds22SHnOyBp(o8s4s)EUGkmHI5atsaLnrSDLn)Srz20VNlOU0RRdaKkaON1JrHc2GKTnByJYSThFhEjCPFpxqfMqXCGjjGwLIJ2GPkPFpxqv8Qw1QubO1CR5DTMBvcNWlHLkvQsa3Qeb1QuC0gmvP947WlHvP9ijGvj3VbFRua)an0gmS5NnOyRa0LC8pqX1Jzrpe2OeBhaivaqpl54FGIRIWhAdg22SHT947WlHRhLXbMeQWhkwydYQubjNVD1gmvjFPZALncEatjEkytme)duKWgn4zZ9BW3kfS9an0gmS10SbnY2DSJSLJ8Zgo4ltbBpkJdBGNnXq8pqr2GUtj2qND7hzdmSP3iBUFNfpfSPXlJAvApE4jYWQe5s7cFO4Kqy54FGIvTMN41CRs4eEjSuPsvc4wLiOwLIJ2GPkThFhEjSkThjbSk5(n4BLc4hOH2GHn)SbfBf0tGMErU79LGlB(zJ4IPeSgVmQKfDmWaA4ltVJe2CInXzBZg22JVdVeUEughysOcFOyHniRsfKC(2vBWuL8LoRv2i4bmL4PGnXwWvfEKWgn4zZ9BW3kfS9an0gmS10SbnY2DSJSLJ8Zgo4ltbBpkJdBGNnP7ENTMWMGlBGHnXZ1NQ0E8WtKHvjYL2f(qXjHWVGRk8yvR5LJAUvjCcVewQuPkbCRseuRsXrBWuL2JVdVewL2JKawLkONan9AhNcQASeCzZpBqXwb9eOPxK7EFj4Y2MnSLfefF4GqccPh4hZIEiS5eBuLnizZpBfGUEbxv4X1Jzrpe2CInXRsfKC(2vBWuL8LoRv2eBbxv4rcBnnBoeofu1WhP7Ehc(QGO4ZwotibH0dBnHnbx2IPWg0iB3XoYM4(WgbpGPqylH0kBGHn9gztSfCvHhzBRb5wL2JhEImSkrU0UWVGRk8yvR55GAUvjCcVewQuPkfhTbtvso(hOyvQGKZ3UAdMQKKlE6iXMyi(hOiBXuytSfCvHhzJGQGlBUFdE2uaBoSZKyKf6juKTtq0Q05Bf)oQsAKWrxOZKyKf6juCHt4LWcB(zJYSvqpbA6LC8pqXf6mjgzHEcflS5NTcqxYX)afxUzcjTDtn(SrjrSDLn)SDaGuba9SqNjXil0tO46XSOhcBuInXzZpBexmLG14LrLSOJbgqdFz6DKWMi2UYMF2(OlW4oo6kkfYQh2CInXcB(zRa0LC8pqX1Jzrpe22gBuDLF2OeBA8YOU0odHvaCPXQwZl)1CRs4eEjSuPsv68TIFhvjns4Ol0zsmYc9ekUWj8syHn)SbfBinnE0EhHpGmpaSlOhLWMtIy74cNfodtCXPWMF2oaqQaGEwOZKyKf6juC9yw0dHnkX2v28ZwbORxWvfEC9yw0dHTTXgvx5NnkXMgVmQlTZqyfaxAKniRsXrBWuLEbxv4XQwZtSuZTkHt4LWsLkvP4OnyQsUaqc(rcq4pyvQGKZ3UAdMQKyi(hOiBcUxq01r2IebWM(nsytbSjqq2ALTGWwWgXfpDKytgh8df8SrdE20BKTuqu2892XMhsdEKTGn6EAYn(vjAWdpOZAnVRvTMNyCn3QeoHxclvQuLoFR43rv6r6hj3HxczZpBhqMha2f0JswfKUpTYMtIy7kB(zdk2CZesA7MA8zJsIy7kBB2W2Jzrpe2OKi20(Cbw7mKn)SrCXucwJxgvYIogyan8LP3rcBojITCWgKS5NnOyJYSHotIrwONqXcBB2W2Jzrpe2OKi20(Cbw7mKTTXM4S5NnIlMsWA8YOsw0XadOHVm9osyZjrSLd2GKn)SbfBA8YOU0odHvaCPr22cBpMf9qyds2CInhWMF2YcIIpCqibH0d8Jzrpe2eXgvRsXrBWuLKJ)bkw1AE(6AUvjCcVewQuPkrdE4bDwR5DTkfhTbtvYfasWpsac)bRAnVTAn3QeoHxclvQuLIJ2GPkjh)duSkD(wXVJQeLzBp(o8s4ICPDHpuCsiSC8pqr28Z2J0psUdVeYMF2oGmpaSlOhLSkiDFALnNeX2v28ZguS5MjK02n14ZgLeX2v22SHThZIEiSrjrSP95cS2ziB(zJ4IPeSgVmQKfDmWaA4ltVJe2CseB5GnizZpBqXgLzdDMeJSqpHIf22SHThZIEiSrjrSP95cS2ziBBJnXzZpBexmLG14LrLSOJbgqdFz6DKWMtIylhSbjB(zdk204LrDPDgcRa4sJSTf2Eml6HWgKS5eBxfNn)SLfefF4GqccPh4hZIEiSjInQwLouCsiSgVmQKAExRAnVRuTMBvcNWlHLkvQsXrBWuLoFNradSIzUirRshkojewJxgvsnVRvPZ3k(DuLiUykbRXlJkHnNeXM4S5NnKMgpAVJWhqMha2f0JsyZjrS5a28Zgo4ltX6rzCGpGmVEWcBoXM4uLn)SbfBuMTdaKkaON1oofu1y9yuOGTnByRa01l4QcpU0(CPhz2GKn)S9yw0dHnkXM4S5dB5GTTXguSrCXucwJxgvcBojInhWgKvPcsoF7QnyQs((7mcyylxmZfjkBGHTmHK2UjKnnEzujSfkBoWh2892Xg034W2lmtpYSbeu26HnX3s(jSfe2sGrMTGWg0iB3XoYgoab5B2Eugh2IPWw84arLncQApYSj4Ygn4zZHWPGQgvTM31R1CRs4eEjSuPsvkoAdMQ0l4QcpwLki58TR2GPkjwbrx2eCztSfCvHhzlu2CGpSbg2IuInnEzujSbf034WwQ37rMTeyKzdhGG8nBXuyBakBKjCj3afYQ05Bf)oQsuMT947WlHlYL2f(fCvHhzZpBinnE0EhHpGmpaSlOhLWMtIyZbS5NThPFKChEjKn)SbfBUzcjTDtn(SrjrSDLTnBy7XSOhcBuseBAFUaRDgYMF2iUykbRXlJkzrhdmGg(Y07iHnNeXwoyds28ZguSrz2qNjXil0tOyHTnBy7XSOhcBuseBAFUaRDgY22ytC28ZgXftjynEzujl6yGb0WxMEhjS5Ki2YbBqYMF204LrDPDgcRa4sJSTf2Eml6HWMtSbfBoGnFydk2EHbPbVmUkb5UhzyYbimLhtlCcVewyBBSLF2GKnFydk2EHbPbVmUkaqMxkk4cNWlHf22gB5NnizZh2GIT947WlHRhLXbMeQWhkwyBBSjwyds2GSQ18UkEn3QeoHxclvQuLIJ2GPk9cUQWJvPZ3k(DuLOmB7X3HxcxKlTl8HItcHFbxv4r28ZgLzBp(o8s4ICPDHFbxv4r28ZgstJhT3r4diZda7c6rjS5Ki2CaB(z7r6hj3HxczZpBqXMBMqsB3uJpBuseBxzBZg2Eml6HWgLeXM2NlWANHS5NnIlMsWA8YOsw0XadOHVm9osyZjrSLd2GKn)SbfBuMn0zsmYc9ekwyBZg2Eml6HWgLeXM2NlWANHSTn2eNn)SrCXucwJxgvYIogyan8LP3rcBojITCWgKS5NnnEzuxANHWkaU0iBBHThZIEiS5eBqXMdyZh2GITxyqAWlJRsqU7rgMCact5X0cNWlHf22gB5NnizZh2GITxyqAWlJRcaK5LIcUWj8syHTTXw(zds28HnOyBp(o8s46rzCGjHk8HIf22gBIf2GKniRshkojewJxgvsnVRvTM31CuZTkHt4LWsLkvP4OnyQsNVZiGbwXmxKOvPcsoF7QnyQsBLiL8IZf2YzGdZMV)oJag2YfZCrIYg0TEZMEJSrImKTeqUpSfe2cpWo6iBEckBT8a(EKztVr2WbFzky7aMsRnyiS10SbnYw84arLnbspYSj2cUQWJvPZ3k(DuLiUykbRXlJkHnNeXM4S5NnKMgpAVJWhqMha2f0JsyZjrS5a28Z2Jzrpe2OeBIZMpSLd22gBqXgXftjynEzujS5Ki2CaBqw1AExDqn3QeoHxclvQuLIJ2GPkD(oJagyfZCrIwLki58TR2GPk57VZiGHTCXmxKOSbg2KYLTMMTEyZnMcM1h2IPW2GXNOGTSWz2WbFzkylMcBnnBo8SJdiJnObdev2ka2YapYwjYczKTIaYMcylxQabFvoxLoFR43rvI4IPeSgVmQe2eX2v28ZgLz7fgKg8Y4QeK7EKHjhGWuEmTWj8syHn)SLfefF4GqccPh4hZIEiSjInQYMF2qAA8O9ocFazEayxqpkHnNeXguSDCHZcNHjU4uyBlSDLnizZpBps)i5o8siB(zJYSHotIrwONqXcB(zdk2OmBf0tGMErU79LGlB(zdk2WbFzkwfKUpTYgLeXM45NnFydh8LPy9OmoWhqMxpyHnizds28ZMgVmQlTZqyfaxAKTTW2Jzrpe2CInhu1Qw1Q0o(Kgm18eNQIFLQIfXfJRsqh)0JmPkT9KZIDEB)8edIjBSL7nYwN5cELnAWZge3JPj3qKThfRf6hlSraziBHGcYcflSDUJrgjlMAFPhKTRIjB(gm74RyHni(cdsdEzCLtqKnfWgeFHbPbVmUYPfoHxclqKnOe3zixm1(spiBIfXKnFdMD8vSWgeFHbPbVmUYjiYMcydIVWG0Gxgx50cNWlHfiYguxDgYftnt92tol25T9ZtmiMSXwU3iBDMl4v2ObpBq09XdiZluiY2JI1c9Jf2iGmKTqqbzHIf2o3XiJKftTV0dYMdet28ny2XxXcBqKaesE9uw5eeztbSbrcqi51tzLtlCcVewGiBHYMdV9UVWguxDgYftTV0dYw(ft28ny2XxXcBq8fgKg8Y4kNGiBkGni(cdsdEzCLtlCcVewGiBqD1zixm1(spiBIfXKnFdMD8vSWgeFHbPbVmUYjiYMcydIVWG0Gxgx50cNWlHfiYguxDgYftTV0dYMySyYMVbZo(kwydI63Zfuxxx5eeztbSbr975cQl96kNGiBqLdNHCXu7l9GSjglMS5BWSJVIf2GO(9Cb1L4RCcISPa2GO(9Cb1Lk(kNGiBqjUZqUyQ9LEq281IjB(gm74RyHniQFpxqDDDLtqKnfWge1VNlOU0RRCcISbL4od5IP2x6bzZxlMS5BWSJVIf2GO(9Cb1L4RCcISPa2GO(9Cb1Lk(kNGiBqLdNHCXuZuV9KZIDEB)8edIjBSL7nYwN5cELnAWZgel9JhfIS9OyTq)yHncidzleuqwOyHTZDmYizXu7l9GSTvft28ny2XxXcBq8fgKg8Y4kNGiBkGni(cdsdEzCLtlCcVewGiBqD1zixm1m1Bp5SyN32ppXGyYgB5EJS1zUGxzJg8SbXtHar2EuSwOFSWgbKHSfckiluSW25ogzKSyQ9LEq2YHyYMVbZo(kwydIeGqYRNYkNGiBkGnisacjVEkRCAHt4LWcezdQRod5IP2x6bzl)IjB(gm74RyHnPoZ3SrOy0Wz2eJytbS5lcbBLEVjnyyd4IFOGNnOGaKSbL4od5IP2x6bztmwmzZ3GzhFflSj1z(MncfJgoZMyeBkGnFriyR07nPbdBax8df8SbfeGKnOe3zixm1(spiBxPQyYMVbZo(kwytQZ8nBekgnCMnXi2uaB(IqWwP3Bsdg2aU4hk4zdkiajBqjUZqUyQ9LEq2UEvmzZ3GzhFflSj1z(MncfJgoZMyeBkGnFriyR07nPbdBax8df8SbfeGKnOe3zixm1(spiBIFvmzZ3GzhFflSbr975cQlXx5eeztbSbr975cQlv8vobr2G6QZqUyQ9LEq2exCXKnFdMD8vSWge1VNlOUUUYjiYMcydI63Zfux61vobr2G6QZqUyQzQ3EYzXoVTFEIbXKn2Y9gzRZCbVYgn4zdIfGcr2EuSwOFSWgbKHSfckiluSW25ogzKSyQ9LEq2CGyYMVbZo(kwydIOZKyKf6juSSYjiYMcydIf0tGMELtl0zsmYc9ekwGiBqD1zixm1(spiBxVkMS5BWSJVIf2G4lmin4LXvobr2uaBq8fgKg8Y4kNw4eEjSar2GsCNHCXu7l9GSDvCXKnFdMD8vSWgeFHbPbVmUYjiYMcydIVWG0Gxgx50cNWlHfiYguI7mKlMAFPhKTRoqmzZ3GzhFflSbXxyqAWlJRCcISPa2G4lmin4LXvoTWj8sybISb1vNHCXuZuN7nYgefiiCRygbISfhTbdBqhe2gGYgnqykS1dB6DtyRZCbVUyQ3(zUGxXcBIXSfhTbdBPMOKftDvY9b0DcRs5lFSLZesqi9eAdg2eBGSaYuNV8Xg1cdYM4(AhztCQk(vMAM68Lp289DmYirmzQZx(yBlSLZUUjkydIe97Jcr2OtHmBkGncidzlN3oFHnAWFHWMcyJe7iBUp4GespYSPDgUyQZx(yBlST1GbIkBoumn5MnHjHecBsP(GSftHTTUpiBq3PeBPGOSLaJm(SP3XWMVkik(SLZesqi9SyQZx(yBlSj2ykCMTTskKXuk0gmSbb2CiCkOQbBekMdBq10S5q4uqvd2AcBkqwoHf2a00SbE2adBbBjWiZMV3Aixm1m15lFS5WoJhbflS5H0Ghz7aY8cLnpuUhYITC(CqxLW2aMTChFgTqIT4OnyiSbMeflM64Onyil3hpGmVqffUUjkGDbnbmm1XrBWqwUpEazEH6Jii4bunHfy6uqbwGUhzyf4Cpm1XrBWqwUpEazEH6JiiKf)fSatdE4cg6TJUpEazEHctWdyker53XMw0hDbg3XrxrPqw94018ZuhhTbdz5(4bK5fQpIGaDcj3NpOvhBAreGqYRNYYvGOcjegFbxTbdtDC0gmKL7JhqMxO(icc7X3HxcDCImu0oofu1a(uEh3JKak66wG6fgKg8Y4QiqUaDKUGpb2n0Z92O6Yb5hsM68XwU3iBXo(HmYMV3AXMTMWgvxIloBEckBfbKnfWMEJSj25jgyBcv4r2a0S57TJnzCCKnXDMn9UjSThjbKTMWgWv7SiXgn4zJqXC6rMTeqUpm1XrBWqwUpEazEH6JiiShFhEj0XjYqr0PqgtPqBWaFkVJ7rsafDDlq9cdsdEzCb8WsJZb3gvxoWbqYuNp22AuXpRhKnOV7ZnBq10SfdfqYgrdLnpbAA20VNlOYg0iBqhJYMcylufZCv2uaBekMdBq36nBoeofu1yXuhhTbdz5(4bK5fQpIGWE8D4LqhNidfPFpxqfMqXCGjjG64EKeqrxDSPfPFpxqDDDDheybcc7jqt7hkkRFpxqDj(6oiWcee2tGMEZg975cQRRRdaKkaONvr4dTbJtI0VNlOUeFDaGuba9SkcFOnyGCZg975cQRRRMS6HCEbn8siSyTqmQqgCb37dYuhhTbdz5(4bK5fQpIGWE8D4LqhNidfPFpxqfMqXCGjjG64EKeqrI7ytls)EUG6s81DqGfiiSNanTFOOS(9Cb1111DqGfiiSNan9Mn63ZfuxIVoaqQaGEwfHp0gmoPFpxqDDDDaGuba9SkcFOnyGCZg975cQlXxnz1d58cA4LqyXAHyuHm4cU3hKPooAdgYY9XdiZluFebbsQpiCmf4sFqhDF8aY8cfMGhWuiIU6ytl6r6hj3HxczQJJ2GHSCF8aY8c1hrqGOyK0BMAM68Lp2CyNXJGIf2WD8PGnTZq20BKT4OGNTMWwShDk8s4IPooAdgIOl95ctD(ytSrIIrsVzRPzZfqiTxczdQbW2UqAWp8siB4GznsyRh2oGmVqHKPooAdgIpIGarXiP3m1XrBWq8ree2JVdVe64ezOispYjewJxgvh3JKakI4IPeSgVmQKfDmWaA4ltVJekjotD(yZ3GmVEWcBo8GVmfSj2OmoSniwWcBkGnsOcFOitDC0gmeFebH947WlHoorgk6rzCGjHk8HIfh3JKakch8LPy9OmoWhqMxpyXPCKFM64Onyi(iccNiLGJJ2Gbo1e1XjYqrefJKEJfhj63hv0vhBArefJKEJL1dKfqM64Onyi(iccNiLGJJ2Gbo1e1XjYqrNcXrI(9rfD1rhBArqrzns4ORSGO4dhesqi9SWj8syzZMcqxYX)afxAFU0JmKm15JTTtqztA2A2eCzRNw7iLOGnAWZMVfu2uaB6nYMVVdc6iBps)i5MnOB9MnhE2XbKXwtZwOSLaqZwr4dTbdtDC0gmeFebbsQpiCmf4sFqhBAru2tGMErs9bHJPax6dUeC9FazEayxqpkXjrxzQJJ2GH4JiiGZooGmhBArEc00lsQpiCmf4sFWLGRFpbA6fj1heoMcCPp46XSOhcLYV)diZda7c6rjojYbm1XrBWq8reeorkbhhTbdCQjQJtKHIkaLPooAdgIpIGWjsj44OnyGtnrDCImuuPF8Om1XrBWq8reeI)edcRG)XrDSPfHd(YuSkiDFA1jrxZVp4GVmfRhLXb(aY86blm1XrBWq8reeI)edc7kKiitDC0gmeFebHulFRe4TxfkYz4Om1XrBWq8ree8czyanS(95cHPMPoF5JnFdaPca6HWuNp22(0SfLcHT4r2eCDKnY0UiB6nYgyq2GU1B2saOrIYwU5U1l2eRMGSb9noSvOOhz2OdIIpB6DmS57TJTcs3Nwzd8SbDR3abLTyOGnFVDlM64OnyiRtH4JiiKf)fSatdE4cg6TJPEq4tr01v(D8qXjHWA8YOseD1XMw0hDbg3XrxrPqwcU(HsJxg1L2ziScGlnsPdiZda7c6rjRcs3Nw321v(3S5aY8aWUGEuYQG09PvNeDCHZcNHjU4uGKPoFST9PzBaSfLcHnO7uITsJSbDR39WMEJSnOZkB5GQehztGGS5RO3A2adBEacHnOB9giOSfdfS57TBXuhhTbdzDkeFebHS4VGfyAWdxWqVDSPf9rxGXDC0vukKvpoLdQULp6cmUJJUIsHSkcFOny8FazEayxqpkzvq6(0QtIoUWzHZWexCkm15JTTscj3NpOv2ObpBBNarfsiBo8l4QnyyRPzBakBefJKEJf2apB9WwW2basfa0dBhkojKPooAdgY6ui(icc0jKCF(GwDSPfracjVEklxbIkKqy8fC1gm(PmrXiP3yzfPKFkxqpbA61oofu1yj46plik(WbHeespWpMf9qerv)qHd(YuS0odHvaCw4m8bK51dwCs8nBOCb9eOPxK7EFj4cjtD(ytII5W2wjfYykfAdg2GU1B2CiCkOQbBbHTeyKzliSbnYg0GbIkBjabzly7eeLnWo(SP3iB0T8TYwr4dTbdBqbE2AA2CiCkOQbBq3PeBhqgYMxCUWwih9aHMWMcKLtyHnannKlM64OnyiRtH4JiiqNczmLcTbJJnTiktums6nwwpqwa9dfuhaivaqpRDCkOQX6XSOhItBvQUzZbasfa0ZAhNcQASEml6HqPCaPFKMgpAVJWhqMha2f0JsCsKd8RXlJ6s7mewbWLgD6kv3SPGEc00RDCkOQXsWDZgpaH4NULVv4hZIEiusChajtDC0gmK1Pq8reeOtHmMsH2GXXMweLjkgj9glRhilG(rAA8O9ocFazEayxqpkXjroWpu0ja4Hck6w(wHFml6HSfXDaKIrqDaGuba9ST947WlHl6uiJPuOnyGpLhsiDIobapuqr3Y3k8JzrpKTiUd2Ybasfa0ZAhNcQASEml6HST947WlHRDCkOQb8P8qkgb1basfa0Z22JVdVeUOtHmMsH2Gb(uEiHesM68XMefZHnj0L0e2GU1B2CiCkOQbBbHTeyKzliSbnYg0GbIkBjabzly7eeLnWo(SP3iB0T8TYwr4dTbJJS5jOS5(in(SPXlJkHn9ou2GUtj2s9oYwOSLWGOSDLQeM64OnyiRtH4JiiqqxstCSPfrzIIrsVXY6bYcOFOoaqQaGEw74uqvJ1JzrpekD1VgVmQlTZqyfaxA0PRuDZMc6jqtV2XPGQglb3nBOB5Bf(XSOhcLUsvizQJJ2GHSofIpIGabDjnXXMweLjkgj9glRhilG(HIobapuqr3Y3k8JzrpKTCLQqkgDaGuba9aPt0ja4Hck6w(wHFml6HSLRuDlhaivaqpRDCkOQX6XSOhY22JVdVeU2XPGQgWNYdPy0basfa0dKqYuNp2KOyoS5q4uqvd2GUNcaA2GU1B2YRLVvIgPl47Jd7mjgzHEcfzRPzlCDt9j8sitDC0gmK1Pq8ree2JVdVe64ezOODCkOQb80Y3krJ0f8HpGP0Adgh3JKakIYAKWrxtlFRensxWFHt4LWYMnuwJeo6cDMeJSqpHIlCcVew2S5aaPca6zHotIrwONqX1JzrpekL)Ti(20iHJUki6Ipmr)qdzmBHt4LWctD(ytII5WMdHtbvnyd6wVzBRKczmLcTbdBXuytcDjnHTGWwcmYSfe2GgzdAWarLTeGGSfSDcIYgyhF20BKn6w(wzRi8H2GHPooAdgY6ui(icc7X3HxcDCImu0oofu1a(a2Xjgf(aMsRnyCSPfDa74eJUUqX3XSzZbSJtm6AWZdsGVSzZbSJtm6Aad64EKeqrxzQJJ2GHSofIpIGWE8D4LqhNidfTJtbvnGpGDCIrHpGP0AdghBArhWooXORDC0BkEh3JKakIobapuqr3Y3k8JzrpKTiovHumcQRIt1TThFhEjCTJtbvnGpLhsiDIobapuqr3Y3k8JzrpKTiov3Ybasfa0ZIofYykfAdM1JzrpeifJG6Q4uDB7X3Hxcx74uqvd4t5HeYnB8eOPx0PqgtPqBWa7jqtVeC3SPGEc00l6uiJPuOnywcUB2q3Y3k8JzrpekjovzQJJ2GHSofIpIGWE8D4LqhNidfTJtbvnGpGDCIrHpGP0AdghBArhWooXORPLVvy6aDCpscOi6ea8qbfDlFRWpMf9q2I4ufsXiOUkov32E8D4LW1oofu1a(uEiH0j6ea8qbfDlFRWpMf9q2I4uDlhaivaqplc6sAY6XSOhcKIrqDvCQUT947WlHRDCkOQb8P8qc5MnfGUiOlPjlTpx6rEZg6w(wHFml6HqjXPktDC0gmK1Pq8ree2XPGQgo20IOmrXiP3yz9azb0FbORxWvfECP95spY(PCb9eOPx74uqvJLGR)947WlHRDCkOQb80Y3krJ0f8HpGP0Adg)7X3Hxcx74uqvd4dyhNyu4dykT2GHPoFS5WotIrwONqr2G(gh2gGYgrXiP3yHTykS5b0B2eBbxv4r2IPWMyi(hOiBXJSj4Ygn4zlbgz2WbiiFVyQJJ2GHSofIpIGa6mjgzHEcfDSPfrzIIrsVXY6bYcOFOOCbOl54FGIRhPFKChEj0FbORxWvfEC9yw0dXjh4Jd22XfolCgM4ItzZMcqxVGRk846XSOhY2O6k)oPXlJ6s7mewbWLgH0VgVmQlTZqyfaxA0jhWuNp2KU7D2AA2GgzlEKTWdiOSPa2C4zhhqMJSftHTqvmZvztbSrOyoSbDR3SjHUKMWgDprIT7wzRPzdAKnObdev2GoikYwg4r207yy7os0SP3iBhaivaqplM64OnyiRtH4JiiqU7DhBArfGUEbxv4XL2Nl9i7hkkFaGuba9SiOlPjRhJcfB2CaGuba9S2XPGQgRhZIEioDvCi3SPa0fbDjnzP95spYm1XrBWqwNcXhrqWfOnyCSPf5jqtV8saqjjq01JXr3SXdqi(PB5Bf(XSOhcLYbv3SPGEc00RDCkOQXsWLPooAdgY6ui(iccEjaOatl8u4ytlQGEc00RDCkOQXsWLPooAdgY6ui(iccE4tW)spYo20IkONan9AhNcQASeCzQJJ2GHSofIpIGaD)Oxcako20IkONan9AhNcQASeCzQJJ2GHSofIpIGqmhKOFKGprk5ytlQGEc00RDCkOQXsWLPooAdgY6ui(iccNiLGJJ2Gbo1e1XjYqr7X0KBhBAruMOyK0BSSIuYFwqu8HdcjiKEGFml6HiIQm15JnjkMdB6nYM73GVvkyJOHYMNannB63Zfuzd6wVzZHWPGQgoYgqVXh6MGSjqq2adBhaivaqpm1XrBWqwNcXhrqq)EUG6vhBAr7X3Hxcx63ZfuHjumhyscOIU6hQc6jqtV2XPGQglb3nB8aeIF6w(wHFml6HqjrItvi3SbQ947WlHl975cQWekMdmjburI7NY63ZfuxIVoaqQaGEwpgfkGCZgkVhFhEjCPFpxqfMqXCGjjGYuhhTbdzDkeFebb975cQI7ytlAp(o8s4s)EUGkmHI5atsavK4(HQGEc00RDCkOQXsWDZgpaH4NULVv4hZIEiusK4ufYnBGAp(o8s4s)EUGkmHI5atsav0v)uw)EUG6666aaPca6z9yuOaYnBO8E8D4LWL(9CbvycfZbMKaktntD(YhBBD)4rzRezHmYw41PwBKWuNp2C4zhhqgBHYMd8HnOYVpSbDR3ST1sqYMV3UfBB)SmS0HIjkydmSjUpSPXlJkXr2GU1B2CiCkOQHJSbE2GU1B2YLkBVXgqVXh6MGSbD0kB0GNncidzdh8LPyXwoNia2GoALTMMnh2zImBhqMhGTMW2bK1JmBcUlM64OnyiRs)4rfHZooGmhBArinnE0EhHpGmpaSlOhL4Kih4JgjC0vbrx8Hj6hAiJzlCcVew8dvb9eOPx74uqvJLG7Mnf0tGMErU79LG7Mnf0tGMErNczmLcTbZsWDZgCWxMIvbP7tRusK453hCWxMI1JY4aFazE9GLnBO8E8D4LWfPh5ecRXlJkK(HIYAKWrxOZKyKf6juCHt4LWYMnhaivaqpl0zsmYc9ekUEml6H4K4qYuhhTbdzv6hpQpIGWE8D4LqhNidfjqqy6oLW3X9ijGIoGmpaSlOhLSkiDFA1PRB2Gd(YuSkiDFALsIep)(Gd(YuSEugh4diZRhSSzdL3JVdVeUi9iNqynEzuzQZhB5SRBIc2KOIeBkGTiLytJxgvcBq36nqqzlyRGEc00Sfe2C)g8TsHJS5(in(FpYSPXlJkHTcf9iZgbag8zlOv8ztVr2C)olEkytJxgvM64OnyiRs)4r9reei4)HIfypWGWe3(c6ytlAp(o8s4sGGW0DkHVFkxa6IG)hkwG9adctC7liCbOlTpx6rMPooAdgYQ0pEuFebbc(FOyb2dmimXTVGoEO4KqynEzujIU6ytlAp(o8s4sGGW0DkHVFkxa6IG)hkwG9adctC7liCbOlTpx6rMPoFST9CJdB(QCMTMW2au2cLT7w(MTIWhAdghztGGSjrfj2uaBHRBIc28fmkS5rbBoSZrMBczRi89iZMdHtbvnCKnGEJp0nbz7cIUSr)Gm2oHRBpYSDUJxgjm1XrBWqwL(XJ6JiiqW)dflWEGbHjU9f0XMw0E8D4LWLabHP7ucF)zbrXhoiKGq6b(XSOhcLO6Yx7hk6w(wHFml6Hqjr5FZMdaKkaONfb)puSa7bgeM42xWvw4m85oEzKSLZD8YibM(JJ2GjsusevxIN)nBiaHKxpLvcJcShfWOZrMBcx4eEjS4NYEc00RegfypkGrNJm3eUeC9xqpbA61oofu1yj4UzJNan9kl(hanwGLXmIcgegN7yoygo6sWfsM68X2wjg2a0Sjwz6DKWwOSDDR6dBenoxiSbOztSQUuWHnQKIcsyd8SfYrpeLnh4dBA8YOswm1XrBWqwL(XJ6JiiqhdmGg(Y07iXXMw0E8D4LWLabHP7ucF)q5jqtVU7sbhyVuuqYIOX5ItIUUv3Sbkk7(n4BLc4hOH2GXpXftjynEzujl6yGb0WxMEhjojYb(qums6nwwpqwaHesM68X2wjg2a0Sjwz6DKWMcylCDtuWMlOjGHWwtZwpXr7DKnWWwmuWMgVmQSbf4zlgkyZlHyPhz204LrLWg0TEZM73GVvky7bAOnyGKTqzlh5YuhhTbdzv6hpQpIGaDmWaA4ltVJehpuCsiSgVmQerxDSPfbfLD)g8Tsb8d0qBWSztbOl54FGIlTpx6rEZMcqxVGRk84s7ZLEKH0)E8D4LWLabHP7ucF)exmLG14LrLSOJbgqdFz6DK4KOCWuhhTbdzv6hpQpIGaEUb9id)O73zXuCSPfThFhEjCjqqy6oLW3)basfa0ZAhNcQASEml6H40vQYuhhTbdzv6hpQpIGqK5jqUDSPfThFhEjCjqqy6oLW3puzbrXhoiKGq6b(XSOhIiQ6NYVWG0GxgxfaiZlffCZgpbA6LxQNcPl4sWfsM68XwUH3w8vcANcfztbSfUUjkyBRXOKOGTTd0eWWwOSjoBA8YOsyQJJ2GHSk9Jh1hrqitq7uOOJhkojewJxgvIORo20I2JVdVeUeiimDNs47N4IPeSgVmQKfDmWaA4ltVJerIZuhhTbdzv6hpQpIGqMG2PqrhBAr7X3HxcxceeMUtj8zQzQZx(yBRJSqgzdSJpBANHSfEDQ1gjm15JnFPZALncEatjEkytme)duKWgn4zZ9BW3kfS9an0gmS10SbnY2DSJSLJ8Zgo4ltbBpkJdBGNnXq8pqr2GUtj2qND7hzdmSP3iBUFNfpfSPXlJktDC0gmKvbOI2JVdVe64ezOiYL2f(qXjHWYX)afDCpscOi3VbFRua)an0gm(HQa0LC8pqX1JzrpekDaGuba9SKJ)bkUkcFOny2Szp(o8s46rzCGjHk8HIfizQZhB(sN1kBe8aMs8uWMyl4QcpsyJg8S5(n4BLc2EGgAdg2AA2Ggz7o2r2Yr(zdh8LPGThLXHnWZM0DVZwtytWLnWWM456dtDC0gmKvbO(icc7X3HxcDCImue5s7cFO4Kq4xWvfE0X9ijGIC)g8Tsb8d0qBW4hQc6jqtVi39(sW1pXftjynEzujl6yGb0WxMEhjoj(Mn7X3HxcxpkJdmjuHpuSajtD(yZx6SwztSfCvHhjS10S5q4uqvdFKU7Di4RcIIpB5mHeespS1e2eCzlMcBqJSDh7iBI7dBe8aMcHTesRSbg20BKnXwWvfEKTTgKltDC0gmKvbO(icc7X3HxcDCImue5s7c)cUQWJoUhjbuub9eOPx74uqvJLGRFOkONan9IC37lb3nBYcIIpCqibH0d8JzrpeNOkK(laD9cUQWJRhZIEiojotD(ytYfpDKytme)duKTykSj2cUQWJSrqvWLn3VbpBkGnh2zsmYc9ekY2jiktDC0gmKvbO(iccYX)afDSPfPrchDHotIrwONqXfoHxcl(Pm6mjgzHEcfll54FGI(laDjh)duC5MjK02n14tjrx9FaGuba9SqNjXil0tO46XSOhcLe3pXftjynEzujl6yGb0WxMEhjIU6)JUaJ74OROuiRECsS4Va0LC8pqX1JzrpKTr1v(PKgVmQlTZqyfaxAKPooAdgYQauFebHxWvfE0XMwKgjC0f6mjgzHEcfx4eEjS4hkKMgpAVJWhqMha2f0JsCs0XfolCgM4ItX)basfa0ZcDMeJSqpHIRhZIEiu6Q)cqxVGRk846XSOhY2O6k)usJxg1L2ziScGlncjtD(ytme)duKnb3li66iBrIayt)gjSPa2eiiBTYwqylyJ4INosSjJd(HcE2ObpB6nYwkikB(E7yZdPbpYwWgDpn5gFM64OnyiRcq9reeCbGe8JeGWFqhPbp8GoRIUYuhhTbdzvaQpIGGC8pqrhBArps)i5o8sO)diZda7c6rjRcs3NwDs0v)q5MjK02n14tjrx3S5XSOhcLeP95cS2zOFIlMsWA8YOsw0XadOHVm9osCsuoG0puugDMeJSqpHILnBEml6HqjrAFUaRDgUnX9tCXucwJxgvYIogyan8LP3rItIYbK(HsJxg1L2ziScGlnULhZIEiq6Kd8NfefF4GqccPh4hZIEiIOktDC0gmKvbO(iccUaqc(rcq4pOJ0GhEqNvrxzQJJ2GHSka1hrqqo(hOOJhkojewJxgvIORo20IO8E8D4LWf5s7cFO4Kqy54FGI(FK(rYD4Lq)hqMha2f0JswfKUpT6KOR(HYntiPTBQXNsIUUzZJzrpekjs7ZfyTZq)exmLG14LrLSOJbgqdFz6DK4KOCaPFOOm6mjgzHEcflB28yw0dHsI0(Cbw7mCBI7N4IPeSgVmQKfDmWaA4ltVJeNeLdi9dLgVmQlTZqyfaxAClpMf9qG0PRI7plik(WbHeespWpMf9qervM68XMV)oJag2YfZCrIYgyyltiPTBcztJxgvcBHYMd8HnFVDSb9noS9cZ0JmBabLTEyt8TKFcBbHTeyKzliSbnY2DSJSHdqq(MThLXHTykSfpoquzJGQ2JmBcUSrdE2CiCkOQbtDC0gmKvbO(iccNVZiGbwXmxKOoEO4KqynEzujIU6ytlI4IPeSgVmQeNejUFKMgpAVJWhqMha2f0JsCsKd8Jd(YuSEugh4diZRhS4K4u1puu(aaPca6zTJtbvnwpgfk2SPa01l4QcpU0(CPhzi9)yw0dHsI7to2guexmLG14LrL4KihajtD(ytScIUSj4YMyl4QcpYwOS5aFydmSfPeBA8YOsydkOVXHTuV3JmBjWiZgoab5B2IPW2au2it4sUbkKm1XrBWqwfG6Jii8cUQWJo20IO8E8D4LWf5s7c)cUQWJ(rAA8O9ocFazEayxqpkXjroW)J0psUdVe6hk3mHK2UPgFkj66MnpMf9qOKiTpxG1od9tCXucwJxgvYIogyan8LP3rItIYbK(HIYOZKyKf6juSSzZJzrpekjs7ZfyTZWTjUFIlMsWA8YOsw0XadOHVm9osCsuoG0VgVmQlTZqyfaxAClpMf9qCckh4duVWG0GxgxLGC3Jmm5aeMYJPTLFi9bQxyqAWlJRcaK5LIcUT8dPpqThFhEjC9OmoWKqf(qXY2elqcjtDC0gmKvbO(iccVGRk8OJhkojewJxgvIORo20IO8E8D4LWf5s7cFO4Kq4xWvfE0pL3JVdVeUixAx4xWvfE0pstJhT3r4diZda7c6rjojYb(FK(rYD4Lq)q5MjK02n14tjrx3S5XSOhcLeP95cS2zOFIlMsWA8YOsw0XadOHVm9osCsuoG0puugDMeJSqpHILnBEml6HqjrAFUaRDgUnX9tCXucwJxgvYIogyan8LP3rItIYbK(14LrDPDgcRa4sJB5XSOhItq5aFG6fgKg8Y4QeK7EKHjhGWuEmTT8dPpq9cdsdEzCvaGmVuuWTLFi9bQ947WlHRhLXbMeQWhkw2MybsizQZhBBLiL8IZf2YzGdZMV)oJag2YfZCrIYg0TEZMEJSrImKTeqUpSfe2cpWo6iBEckBT8a(EKztVr2WbFzky7aMsRnyiS10SbnYw84arLnbspYSj2cUQWJm1XrBWqwfG6JiiC(oJagyfZCrI6ytlI4IPeSgVmQeNejUFKMgpAVJWhqMha2f0JsCsKd8)yw0dHsI7to2guexmLG14LrL4KihajtD(yZ3FNradB5IzUirzdmSjLlBnnB9WMBmfmRpSftHTbJprbBzHZSHd(YuWwmf2AA2C4zhhqgBqdgiQSvaSLbEKTsKfYiBfbKnfWwUubc(QCMPooAdgYQauFebHZ3zeWaRyMlsuhBArexmLG14LrLi6QFk)cdsdEzCvcYDpYWKdqykpM8NfefF4GqccPh4hZIEiIOQFKMgpAVJWhqMha2f0JsCseuhx4SWzyIloLTCfs)ps)i5o8sOFkJotIrwONqXIFOOCb9eOPxK7EFj46hkCWxMIvbP7tRusK453hCWxMI1JY4aFazE9GfiH0VgVmQlTZqyfaxAClpMf9qCYbm1m15lFSjPyK0BSWwoF0gmeM68XwET8nrJ0f8zdmSLJCft2893zeWWwUyMlsuM64OnyilIIrsVXIOZ3zeWaRyMlsuhBArAKWrxtlFRensxWFHt4LWIFIlMsWA8YOsCsuo8FazEayxqpkXjroWVgVmQlTZqyfaxAClpMf9qCsSWuNp2YRLVjAKUGpBGHTR5kMSjnHl5gOSj2cUQWJm1XrBWqwefJKEJfFebHxWvfE0XMwKgjC010Y3krJ0f8x4eEjS4)aY8aWUGEuItICGFnEzuxANHWkaU04wEml6H4KyHPoFSjj4P4tliJIjB5SRBIc2apBIns)i5MnOB9MnpbAASWMyi(hOiHPooAdgYIOyK0BS4Jii4caj4hjaH)GosdE4bDwfDLPooAdgYIOyK0BS4Jiiih)du0XdfNecRXlJkr0vhBArAKWrxebpfFAbzCHt4LWIFOEml6HqPRIVzJBMqsB3uJpLeDfs)A8YOU0odHvaCPXT8yw0dXjXzQZhBscEk(0cYiB(WMd7mrMnWW21Cft2eBK(rYnBIH4FGISfkB6nYgof2a0Srums6nBkGnzuzllCMTIWhAdg28qAWJS5WotIrwONqrM64OnyilIIrsVXIpIGGlaKGFKae(d6in4Hh0zv0vM64OnyilIIrsVXIpIGGC8pqrhBArAKWrxebpfFAbzCHt4LWIFns4Ol0zsmYc9ekUWj8syXFC0EhHXbZAKi6QFpbA6frWtXNwqgxpMf9qO01voyQJJ2GHSikgj9gl(icczcANcfDSPfPrchDre8u8PfKXfoHxcl(pGmpaSlOhLqjr5GPMPoF5JnhkMMCZuNp22k90KB2GU1B2YcNzZ3BhB0GNT8A5BLOr6c(oYMWKqcHnbspYST1yO3jkyt6okaOjm1XrBWqw7X0KBr7X3HxcDCImu00Y3krJ0f8HpUWhWuATbJJ7rsafbfLFHbPbVmUkyO3jkGj3rbanXpstJhT3r4diZda7c6rjoj64cNfodtCXPa5Mnq9cdsdEzCvWqVtuatUJcaAI)diZda7c6rjusCizQZhBoumn5MnOB9Mnh2zImB(WwET8Ts0iDbFXKnFv4CNjKXMV3o2IPWMd7mrMThJcfSrdE2g0zLnXGV3AM64OnyiR9yAYTpIGWEmn52XMwKgjC0f6mjgzHEcfx4eEjS4xJeo6AA5BLOr6c(lCcVew8VhFhEjCnT8Ts0iDbF4Jl8bmLwBW4)aaPca6zHotIrwONqX1JzrpekDLPoFS5qX0KB2GU1B2YRLVvIgPl4ZMpSLhGnh2zISyYMVkCUZeYyZ3BhBXuyZHWPGQgSj4YuhhTbdzThttU9ree2JPj3o20I0iHJUMw(wjAKUG)cNWlHf)uwJeo6cDMeJSqpHIlCcVew8VhFhEjCnT8Ts0iDbF4Jl8bmLwBW4VGEc00RDCkOQXsWLPooAdgYApMMC7Jii4caj4hjaH)GosdE4bDwfD1r0z9d4idimQihKFM64OnyiR9yAYTpIGWEmn52XMwKgjC0frWtXNwqgx4eEjS4)aaPca6zjh)duCj46hQcqxYX)afxps)i5o8s4Mnf0tGMETJtbvnwcU(laDjh)duC5MjK02n14tjrxH0)bK5bGDb9OKvbP7tRojckIlMsWA8YOsw0XadOHVm9osCA7fhaP)p6cmUJJUIsHS6XPRIZuNp2COyAYnBq36nB(QGO4ZwotibPhXKnXwWvfE0hXq8pqr2gGYwpS9i9JKB2(yKrhzRi89iZMdHtbvn8r6U3xSjrXCyd6wVztcDjnHn6EIeB3TYwtZMlGqAVeUyQJJ2GHS2JPj3(icc7X0KBhBArqPrchDLfefF4GqccPNfoHxclB28cdsdEzCLf)fyanSEJWzbrXhoiKGq6bs)uUa01l4QcpUEK(rYD4Lq)fGUKJ)bkUEml6H4uo8xqpbA61oofu1yj46hQc6jqtVi39(sWDZMc6jqtV2XPGQgRhZIEiuYbB2ua6IGUKMS0(CPhzi9xa6IGUKMSEml6HqPCuLiU4PMN45FRw1QwRa]] )


end