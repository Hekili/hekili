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


    spec:RegisterPack( "Assassination", 20210627, [[daLPmcqiKOEKijxIGe2Ki8jcIrbsDkqYQar6vurnlQi3sPO2Ls(LsLggsQogiSmcQNjIY0OcCnLISnKu03erLghbj5CkvOwhsk9ocsenpqu3Ja7Jk0)iir4GIOQfIe5HIKAIGiCrQGAJkviFejfgjbjQoPsfPvIK8sLkIMPsfCtruXovkmuqeTuQG8uImvrIRsqI0wji1xvQimwLkQ9kv)fudMYHfwmv1JvXKLYLH2ms9zIA0QuNwYQjir51kLMTOUnvz3k(nWWPshNGKA5Q65iMoPRtOTRs(UsvJxe58iH5lsTFu3HONsxQfk23qyQlmeuNAkCYDbrYnzcvuxOQlPu4IDj34SnKXU0eEyxk5jKGqQj0cmDj3GImiA9u6seG4FWU0TQUeQD3DLl9w0FDaE7skpXCOfyoFqR7skVZUDjFXkR70P73LAHI9neM6cdb1PMcNC7sHOEd(UKu5L6U0D1A4097snKC6sjpHeesnHwGHnhcilImvujoiBcNCDInHPUWqWuXuL67yKrc1YuTz2sEx3mfSjeI(1rfcB05qMnfWgb4HSL8qYDGnAWVLWMcyJexiBUp4GesnYSPLhUyQ2mBqcWieLnHoMICZM4KrcHnPCDq2IPXgKOoiB7RCMTCqu2YGrgF207yyl5eefF2sEcjiKAwmvBMnhcZrsSTJYHmMZHwGHTDztOXPHQgSrOyoSbDrZMqJtdvnyRiSPaz5m2ydqtZg4zdmSfSLbJmBPgsa1QlLlIs6P0Likgz9gB9u6BarpLUeoHFgBDk1LAi58LRwGPlTrjFt0iVfF2adBjlfQLTu)LhbmSLc65IeTlD(sXVIUKgzC01uY3krJ8w8x4e(zSXwc2iUyodRXlJkHnhfWwYylbBhGNpa2fuJsyZrbS5a2sWMgVmQlT8qyfa3kKTnZ2JErne2CKnQzxkoAbMU05lpcyGv0ZfjAx7BiCpLUeoHFgBDk1LAi58LRwGPlTrjFt0iVfF2adBqKc1YM0eUKBGYMdj6QIp2LoFP4xrxsJmo6Ak5BLOrEl(lCc)m2ylbBhGNpa2fuJsyZrbS5a2sWMgVmQlT8qyfa3kKTnZ2JErne2CKnQzxkoAbMU0l6QIp21(gjRNsxcNWpJToL6snKC(YvlW0LKe9v8PfLrQLTK31ntbBGNnhcPFKCZ2(sVzZxKMgBSrnI)bks6s0GhEWK0(gq0LIJwGPl5caz4hjaX)GDTVHd6P0LWj8ZyRtPUuC0cmDj54FGIDPZxk(v0L0iJJUiI(k(0IY4cNWpJn2sWg0S9OxudHniZgecZw60S56jM1Ynx4ZgKfWgeSbfBjytJxg1LwEiScGBfY2Mz7rVOgcBoYMWDPdfNmcRXlJkPVbeDTVXM6P0LWj8ZyRtPUudjNVC1cmDjjrFfFArzKnNzZHtIiZgyydIuOw2CiK(rYnBuJ4FGISfkB6nYgon2a0SrumY6nBkGnzuzZlsITM4hAbg28rAWJS5WjrIrwSMqXUen4HhmjTVbeDP4Ofy6sUaqg(rcq8pyx7Bqn7P0LWj8ZyRtPU05lf)k6sAKXrxerFfFArzCHt4NXgBjytJmo6ctIeJSynHIlCc)m2ylbBXrRlegh0RqcBcydc2sWMVin9Ii6R4tlkJRh9IAiSbz2GyLSUuC0cmDj54FGIDTVrYTNsxcNWpJToL6sNVu8ROlPrghDre9v8PfLXfoHFgBSLGTdWZha7cQrjSbzbSLSUuC0cmDjprTYHIDTRDPRykYDpL(gq0tPlHt4NXwNsDjGBxIGAxkoAbMU0v8v4NXU0vKfXUe0Srz2EXbPbVmUAyO3zkGj3rdSNSWj8ZyJTeSH004rRle(a88bWUGAucBokGTJlSxKemXfNgBqXw60SbnBV4G0Gxgxnm07mfWK7Ob2tw4e(zSXwc2oapFaSlOgLWgKzty2GQl1qY5lxTatxAhvtrUzBFP3S5fjXwQHKSrdE22OKVvIg5T47eBItgje2ej1iZgKad9otbBs3rdSN0LUIhEcpSlnL8Ts0iVfF4Jl8bmTslW01(gc3tPlHt4NXwNsDPgsoF5Qfy6scDmf5MT9LEZMdNerMnNzBJs(wjAK3Ip1YwYjsQ8e9yl1qs2IPXMdNerMThJgfSrdE2gmjLnQrQHeDPZxk(v0L0iJJUWKiXilwtO4cNWpJn2sWMgzC01uY3krJ8w8x4e(zSXwc2UIVc)mUMs(wjAK3Ip8Xf(aMwPfyylbBhai3a7NfMejgzXAcfxp6f1qydYSbrxkoAbMU0vmf5UR9nswpLUeoHFgBDk1LAi58LRwGPlj0XuKB22x6nBBuY3krJ8w8zZz22aWMdNerMAzl5ejvEIESLAijBX0ytOXPHQgSj62LoFP4xrxsJmo6Ak5BLOrEl(lCc)m2ylbBuMnnY4OlmjsmYI1ekUWj8ZyJTeSDfFf(zCnL8Ts0iVfF4Jl8bmTslWWwc2AOVin96cNgQASeD7sXrlW0LUIPi3DTVHd6P0LWj8ZyRtPUeMK(bC4behTl5Gn1LObp8GjP9nGOlfhTatxYfaYWpsaI)b7AFJn1tPlHt4NXwNsDPZxk(v0L0iJJUiI(k(0IY4cNWpJn2sW2baYnW(zjh)duCj6Ywc2GMTgqxYX)afxps)i5o8ZiBPtZwd9fPPxx40qvJLOlBjyRb0LC8pqXLRNywl3CHpBqwaBqWguSLGTdWZha7cQrjRgsxNszZrbSbnBexmNH14LrLSOJbgqdVDQlKWMJcLGnhWguSLGTpQgmEHJUIwJSQHnhzdcH7sXrlW0LUIPi3DTVb1SNsxcNWpJToL6snKC(YvlW0Le6ykYnB7l9MTKtqu8zl5jKGud1YMdj6QIp6m1i(hOiBdqzRg2EK(rYnBFmYOtS1e)AKztOXPHQgolDxxl2KOyoSTV0B2KqxsryJUMiZ2DPSv0S5ciKYpJRU05lf)k6sqZMgzC0Lxqu8HdcjiKAw4e(zSXw60S9IdsdEzC5f)wyanSEJWEbrXhoiKGqQzHt4NXgBqXwc2OmBnGUErxv8X1J0psUd)mYwc2AaDjh)duC9OxudHnhzlzSLGTg6lstVUWPHQglrx2sWg0S1qFrA6f5UUwIUSLonBn0xKMEDHtdvnwp6f1qydYS5a2sNMTgqxe0LuKLwNT1iZguSLGTgqxe0LuK1JErne2GmBjRlfhTatx6kMIC31U2LAiDiM1Ek9nGONsxkoAbMU026STlHt4NXwNsDTVHW9u6s4e(zS1PuxQHKZxUAbMUKdHefJSEZwrZMlGqk)mYg0dGTlX8GF4Nr2Wb9kKWwnSDaE(HcvxkoAbMUerXiR3DTVrY6P0LWj8ZyRtPUeWTlrqTlfhTatx6k(k8Zyx6kYIyxI4I5mSgVmQKfDmWaA4TtDHe2GmBc3LUIhEcpSlrQroJWA8YO21(goONsxcNWpJToL6sa3Ueb1UuC0cmDPR4RWpJDPRilIDjCWxMI1JY4aFaE(1Gn2CKTKTPUudjNVC1cmDPud88RbBS5Wd(YuWMdHY4W2GydBSPa2iHk(HIDPR4HNWd7spkJdmjuXpuS11(gBQNsxcNWpJToL6sNVu8ROlrumY6n2wpqwe7se9RJ23aIUuC0cmDPtKZWXrlWaNlI2LYfrHNWd7sefJSEJTU23GA2tPlHt4NXwNsDPZxk(v0LGMnkZMgzC0Lxqu8HdcjiKAw4e(zSXw60S1a6so(hO4sRZ2AKzdQUer)6O9nGOlfhTatx6e5mCC0cmW5IODPCru4j8WU0Pr6AFJKBpLUeoHFgBDk1LAi58LRwGPlbjfv2KgibBIUSvtPvKZuWgn4zl1IkBkGn9gzl13bbDIThPFKCZ2(sVzZHNlCaESv0SfkBzWE2AIFOfy6sNVu8ROlrz28fPPxKCDq4yAWT6Glrx2sW2b45dGDb1Oe2CuaBq0LIJwGPlrY1bHJPb3Qd21(gcv9u6s4e(zS1Pux68LIFfDjFrA6fjxheoMgCRo4s0LTeS5lstVi56GWX0GB1bxp6f1qydYSTj2sW2b45dGDb1Oe2CuaBoOlfhTatxcNlCaEDTVXoUNsxcNWpJToL6sXrlW0LorodhhTadCUiAxkxefEcpSl1aAx7Bab17P0LWj8ZyRtPUuC0cmDPtKZWXrlWaNlI2LYfrHNWd7sT6XJ21(gqarpLUeoHFgBDk1LoFP4xrxch8LPy1q66ukBokGni2eBoZgo4ltX6rzCGpap)AWwxkoAbMUu8Nyqyf8poAx7BaHW9u6sXrlW0LI)edc7kMjyxcNWpJToL6AFdiswpLUuC0cmDPCjFReyHYeBYE4ODjCc)m26uQR9nGWb9u6sXrlW0L8dzyanS(1zlPlHt4NXwNsDTRDj3hpap)q7P03aIEkDP4Ofy6sHRBMcyxqratxcNWpJToL6AFdH7P0LIJwGPl5dunJny6Cqb22xJmScsQMUeoHFgBDk11(gjRNsxcNWpJToL6sXrlW0L8IFl2GPbpCdd9UlD(sXVIU0hvdgVWrxrRrw1WMJSbXM6sUpEaE(HctWdyAKU0M6AFdh0tPlHt4NXwNsDjGBxIGAxkoAbMU0v8v4NXU0v8Wt4HDj9RzlQWekMdmjd0U05lf)k6s6xZwuxkeR7GalsqyFrAA2sWg0Srz20VMTOUuHx3bbwKGW(I00SLonB6xZwuxkeRdaKBG9ZQj(HwGHnhfWM(1Sf1Lk86aa5gy)SAIFOfyydk2sNMn9RzlQlfIvrw1qoVOg(zewOwmgv0dUHx1b7snKC(YvlW0LGeOIVxniB7VRZnBqx0SfdfqXgrdLnFrAA20VMTOY2EKT9XOSPa2cvrpxLnfWgHI5W2(sVztOXPHQgRU0vKfXUeeDTVXM6P0LWj8ZyRtPUeWTlrqTlfhTatx6k(k8Zyx6kYIyxs4U05lf)k6s6xZwuxQWR7GalsqyFrAA2sWg0Srz20VMTOUuiw3bbwKGW(I00SLonB6xZwuxQWRdaKBG9ZQj(HwGHnhzt)A2I6sHyDaGCdSFwnXp0cmSbfBPtZM(1Sf1Lk8QiRAiNxud)mclulgJk6b3WR6GDPR4HNWd7s6xZwuHjumhysgODTVb1SNsxcNWpJToL6sXrlW0Li56GWX0GB1b7sNVu8ROl9i9JK7WpJDj3hpap)qHj4bmnsxcIU23i52tPlfhTatxIOyK17UeoHFgBDk11U2LA1JhTNsFdi6P0LWj8ZyRtPUudjNVC1cmDjhEUWb4XwOS5aNzd6n5mB7l9MniHeuSLAi5ITDQNh2QqXmfSbg2e2z204LrL4eB7l9MnHgNgQA4eBGNT9LEZwkuYj2a6n(7lcY2(Ou2ObpBeGhYgo4ltXITKptaSTpkLTIMnhojImBhGNpGTIW2b4vJmBIURU05lf)k6sinnE06cHpapFaSlOgLWMJcyZbS5mBAKXrxneDXhMOFOHm6TWj8ZyJTeSbnBn0xKMEDHtdvnwIUSLonBn0xKMErURRLOlBPtZwd9fPPx05qgZ5qlWSeDzlDA2WbFzkwnKUoLYgKfWMWBInNzdh8LPy9OmoWhGNFnyJT0PzJYSDfFf(zCrQroJWA8YOYguSLGnOzJYSPrghDHjrIrwSMqXfoHFgBSLonBhai3a7NfMejgzXAcfxp6f1qyZr2eMnO6sXrlW0LW5chGxx7BiCpLUeoHFgBDk1LaUDjcQDP4Ofy6sxXxHFg7sxrwe7shGNpa2fuJswnKUoLYMJSbbBPtZgo4ltXQH01Pu2GSa2eEtS5mB4GVmfRhLXb(a88RbBSLonBuMTR4RWpJlsnYzewJxg1U0v8Wt4HDjrcctx5m(DTVrY6P0LWj8ZyRtPUudjNVC1cmDPK31ntbBsusInfWwKZSPXlJkHT9LEdev2c2AOVinnBbHn3VaFPu4eBUpsJ)xJmBA8YOsyRrrnYSraGbF2cAfF20BKn3V8INc204LrTlD(sXVIU0v8v4NXLibHPRCgF2sWgLzRb0fb)puSb7dgeM4wBr4gqxAD2wJCxkoAbMUeb)puSb7dgeM4wBXU23Wb9u6s4e(zS1PuxkoAbMUeb)puSb7dgeM4wBXU05lf)k6sxXxHFgxIeeMUYz8zlbBuMTgqxe8)qXgSpyqyIBTfHBaDP1zBnYDPdfNmcRXlJkPVbeDTVXM6P0LWj8ZyRtPUudjNVC1cmDPDIBCyl5K8Sve2gGYwOSDxY3S1e)qlW4eBIeKnjkjXMcylCDZuW2oGrJnFkyZHtk8CZiBnXVgz2eACAOQHtSb0B83xeKTTi6Yg9d8y7eUU1iZ25oEzK0LoFP4xrx6k(k8Z4sKGW0voJpBjyZlik(WbHeesnWp6f1qydYSr9LqfBjydA2Ol5Bf(rVOgcBqwaBBIT0Pz7aa5gy)Si4)HInyFWGWe3AlU8IKGp3XlJe22mBN74Lrcm9hhTatKzdYcyJ6lH3eBPtZgbiM9RPTYy0G9Pagtk8CZ4cNWpJn2sWgLzZxKMELXOb7tbmMu45MXLOlBjyRH(I00RlCAOQXs0LT0PzZxKME5f)d2Jnyz0JOGbHX5oMd6HJUeDzdQUuC0cmDjc(FOyd2hmimXT2IDTVb1SNsxcNWpJToL6snKC(YvlW0L2rXWgGMTDYPUqcBHYge7yNzJOXzlHnanBcLxTgoSrPC0qcBGNTqoQHOS5aNztJxgvYQlD(sXVIU0v8v4NXLibHPRCgF2sWg0S5lstVURwdhy)C0qYIOXzlBokGni2XSLonBqZgLzZ9lWxkfWpqdTadBjyJ4I5mSgVmQKfDmWaA4TtDHe2CuaBoGnNzJOyK1BSTEGSiYguSbvxkoAbMUeDmWaA4TtDHKU23i52tPlHt4NXwNsDP4Ofy6s0XadOH3o1fs6shkozewJxgvsFdi6sNVu8ROlDfFf(zCjsqy6kNXNTeSrCXCgwJxgvYIogyan82PUqcBokGTK1LAi58LRwGPlTJIHnanB7KtDHe2uaBHRBMc2Cbfbme2kA2QjoADHSbg2IHc204LrLnObpBXqbB(zeB1iZMgVmQe22x6nBUFb(sPGThOHwGbk2cLTKLsx7Biu1tPlHt4NXwNsDPZxk(v0LUIVc)mUejimDLZ4Zwc2oaqUb2pRlCAOQX6rVOgcBoYgeuVlfhTatxcp3GAKHF09lVyADTVXoUNsxcNWpJToL6sNVu8ROlDfFf(zCjsqy6kNXNTeSbnBEbrXhoiKGqQb(rVOgcBcyJ6SLGnkZ2loin4LXvda88Zrdx4e(zSXw60S5lstV8Z10ivdxIUSbvxkoAbMUu45lsU7AFdiOEpLUeoHFgBDk1LIJwGPl5jQvouSlDO4KrynEzuj9nGOlD(sXVIU0v8v4NXLibHPRCgF2sWgXfZzynEzujl6yGb0WBN6cjSjGnH7snKC(YvlW0Lsj83CYruRCOiBkGTW1ntbBqcmAzkydsckcyylu2eMnnEzujDTVbeq0tPlHt4NXwNsDPZxk(v0LUIVc)mUejimDLZ43LIJwGPl5jQvouSRDTlDAKEk9nGONsxcNWpJToL6sXrlW0L8IFl2GPbpCdd9UlLRbHpTUeeRn1LouCYiSgVmQK(gq0LoFP4xrx6JQbJx4ORO1ilrx2sWg0SPXlJ6slpewbWTczdYSDaE(ayxqnkz1q66ukBqkBqS2eBPtZ2b45dGDb1OKvdPRtPS5Oa2oUWErsWexCASbvxQHKZxUAbMU0oLMTO1iSfpYMORtSrMYfztVr2adY2(sVzld2JeLTusbsSytOucY2(BCyRrrnYSrhefF207yyl1qs2AiDDkLnWZ2(sVbIkBXqbBPgsU6AFdH7P0LWj8ZyRtPUudjNVC1cmDPDknBdGTO1iSTVYz2AfY2(sVRHn9gzBWKu2sg1joXMibzl5qdjydmS5die22x6nquzlgkyl1qYvx68LIFfDPpQgmEHJUIwJSQHnhzlzuNTnZ2hvdgVWrxrRrwnXp0cmSLGTdWZha7cQrjRgsxNszZrbSDCH9IKGjU406sXrlW0L8IFl2GPbpCdd9UR9nswpLUeoHFgBDk1LAi58LRwGPljrXCyBhLdzmNdTadB7l9MnHgNgQAWwqyldgz2ccB7r22dgHOSLbeKTGTtqu2ax4ZMEJSrxY3kBnXp0cmSbn4zROztOXPHQgSTVYz2oapKn)4SLTqoQz3IWMcKLZyJnannuRU05lf)k6suMnIIrwVX26bYIiBjydA2GMTdaKBG9Z6cNgQASE0lQHWMJSTJPoBPtZ2baYnW(zDHtdvnwp6f1qydYSLm2GITeSH004rRle(a88bWUGAucBokGnhWwc204LrDPLhcRa4wHS5iBqqD2sNMTg6lstVUWPHQglrx2sNMnFaHWwc2Ol5Bf(rVOgcBqMnHDaBq1LIJwGPlrNdzmNdTatx7B4GEkDjCc)m26uQlD(sXVIUeLzJOyK1BSTEGSiYwc2qAA8O1fcFaE(ayxqnkHnhfWMdylbBqZgDgaE2GMnOzJUKVv4h9IAiSTz2e2bSbfB7YwC0cmWhai3a7h2GInhzJodapBqZg0SrxY3k8JErne22mBc7a22mBhai3a7N1fonu1y9OxudHniLTR4RWpJRlCAOQb8P9SbfB7YwC0cmWhai3a7h2GInO6sXrlW0LOZHmMZHwGPR9n2upLUeoHFgBDk1LAi58LRwGPljrXCytcDjfHT9LEZMqJtdvnyliSLbJmBbHT9iB7bJqu2YacYwW2jikBGl8ztVr2Ol5BLTM4hAbgNyZxuzZ9rA8ztJxgvcB6DOSTVYz2Y1fYwOSLXGOSbb1jDPZxk(v0LOmBefJSEJT1dKfr2sWg0SDaGCdSFwx40qvJ1JErne2GmBqWwc204LrDPLhcRa4wHS5iBqqD2sNMTg6lstVUWPHQglrx2sNMn6s(wHF0lQHWgKzdcQZguDP4Ofy6se0LuKU23GA2tPlHt4NXwNsDPZxk(v0LOmBefJSEJT1dKfr2sWg0SrNbGNnOzdA2Ol5Bf(rVOgcBBMniOoBqX2USfhTad8baYnW(HnOyZr2OZaWZg0SbnB0L8Tc)OxudHTnZgeuNTnZ2baYnW(zDHtdvnwp6f1qydsz7k(k8Z46cNgQAaFApBqX2USfhTad8baYnW(HnOydQUuC0cmDjc6sksx7BKC7P0LWj8ZyRtPUeWTlrqTlfhTatx6k(k8Zyx6kYIyxIYSPrghDnL8Ts0iVf)foHFgBSLonBuMnnY4OlmjsmYI1ekUWj8ZyJT0Pz7aa5gy)SWKiXilwtO46rVOgcBqMTnX2Mzty2Gu20iJJUAi6Ipmr)qdz0BHt4NXwxQHKZxUAbMUKefZHnHgNgQAW2(AAG9STV0B22OKVvIg5T47SdNejgzXAcfzROzlCDZ1j8Zyx6kE4j8WU0fonu1aEk5BLOrEl(WhW0kTatx7Biu1tPlHt4NXwNsDjGBxIGAxkoAbMU0v8v4NXU0v8Wt4HDPlCAOQb8bCHtmk8bmTslW0LoFP4xrx6aUWjgDTLIVIHT0Pz7aUWjgDn45bzW3ylDA2oGlCIrxdyWUudjNVC1cmDjjkMdBcnonu1GT9LEZ2okhYyohAbg2IPXMe6skcBbHTmyKzliSThzBpyeIYwgqq2c2obrzdCHpB6nYgDjFRS1e)qlW0LUISi2LGOR9n2X9u6s4e(zS1Puxc42LiO2LIJwGPlDfFf(zSlDfzrSlrNbGNnOzdA2Ol5Bf(rVOgcBBMnHPoBqX2USbnBqim1zdsz7k(k8Z46cNgQAaFApBqXguS5iB0za4zdA2GMn6s(wHF0lQHW2MztyQZ2Mz7aa5gy)SOZHmMZHwGz9OxudHnOyBx2GMnieM6SbPSDfFf(zCDHtdvnGpTNnOydk2sNMnFrA6fDoKXCo0cmW(I00lrx2sNMTg6lstVOZHmMZHwGzj6Yw60SrxY3k8JErne2GmBct9U05lf)k6shWfoXORlC0Bk(U0v8Wt4HDPlCAOQb8bCHtmk8bmTslW01(gqq9EkDjCc)m26uQlbC7seu7sXrlW0LUIVc)m2LUISi2LOZaWZg0SbnB0L8Tc)OxudHTnZMWuNnOyBx2GMnieM6SbPSDfFf(zCDHtdvnGpTNnOydk2CKn6ma8SbnBqZgDjFRWp6f1qyBZSjm1zBZSDaGCdSFwe0LuK1JErne2GITDzdA2GqyQZgKY2v8v4NX1fonu1a(0E2GInOylDA2AaDrqxsrwAD2wJmBPtZgDjFRWp6f1qydYSjm17sNVu8ROlDax4eJUMs(wHPdSlDfp8eEyx6cNgQAaFax4eJcFatR0cmDTVbeq0tPlHt4NXwNsDPZxk(v0LOmBefJSEJT1dKfr2sWwdORx0vfFCP1zBnYSLGnkZwd9fPPxx40qvJLOlBjy7k(k8Z46cNgQAapL8Ts0iVfF4dyALwGHTeSDfFf(zCDHtdvnGpGlCIrHpGPvAbMUuC0cmDPlCAOQrx7BaHW9u6s4e(zS1PuxQHKZxUAbMUKdNejgzXAcfzB)noSnaLnIIrwVXgBX0yZhO3S5qIUQ4JSftJnQr8pqr2Ihzt0LnAWZwgmYSHdqu(E1LoFP4xrxIYSrumY6n2wpqwezlbBqZgLzRb0LC8pqX1J0psUd)mYwc2AaD9IUQ4JRh9IAiS5iBoGnNzZbSbPSDCH9IKGjU40ylDA2AaD9IUQ4JRh9IAiSbPSr91MyZr204LrDPLhcRa4wHSbfBjytJxg1LwEiScGBfYMJS5GUuC0cmDjmjsmYI1ek21(gqKSEkDjCc)m26uQl1qY5lxTatxs6UUyROzBpYw8iBHpquztbS5WZfoapNylMgBHQONRYMcyJqXCyBFP3SjHUKIWgDnrMT7szROzBpY2EWieLT9brr28apYMEhdB3rMMn9gz7aa5gy)S6sNVu8ROl1a66fDvXhxAD2wJmBjydA2OmBhai3a7NfbDjfz9y0OGT0Pz7aa5gy)SUWPHQgRh9IAiS5iBqimBqXw60S1a6IGUKIS06STg5UuC0cmDjYDD11(gq4GEkDjCc)m26uQlD(sXVIUKVin9YpdaTSirxpghLT0PzZhqiSLGn6s(wHF0lQHWgKzlzuNT0PzRH(I00RlCAOQXs0TlfhTatxYfOfy6AFdi2upLUeoHFgBDk1LoFP4xrxQH(I00RlCAOQXs0TlfhTatxYpdanyAXNIU23acQzpLUeoHFgBDk1LoFP4xrxQH(I00RlCAOQXs0TlfhTatxYhFc(BRrUR9nGi52tPlHt4NXwNsDPZxk(v0LAOVin96cNgQASeD7sXrlW0LORh9ZaqRR9nGqOQNsxcNWpJToL6sNVu8ROl1qFrA61fonu1yj62LIJwGPlfZbj6hz4tKZDTVbe74EkDjCc)m26uQlD(sXVIUeLzJOyK1BSTICMTeS5fefF4GqccPg4h9IAiSjGnQZwc2GMnkZMgzC0Lxqu8HdcjiKAw4e(zSXw60S5lstVi56GWX0GB1bxp6f1qyZr2sgBq1LIJwGPlDICgooAbg4Cr0UuUik8eEyx6kMIC31(gct9EkDjCc)m26uQl1qY5lxTatxsII5WMEJS5(f4lLc2iAOS5lstZM(1Sfv22x6nBcnonu1Wj2a6n(7lcYMibzdmSDaGCdSF6sNVu8ROlDfFf(zCPFnBrfMqXCGjzGYMa2GGTeSbnBn0xKMEDHtdvnwIUSLonB(acHTeSrxY3k8JErne2GSa2eM6SbfBPtZg0SDfFf(zCPFnBrfMqXCGjzGYMa2eMTeSrz20VMTOUuHxhai3a7N1JrJc2GIT0PzJYSDfFf(zCPFnBrfMqXCGjzG2LIJwGPlPFnBrfIU23qyi6P0LWj8ZyRtPU05lf)k6sxXxHFgx6xZwuHjumhysgOSjGnHzlbBqZwd9fPPxx40qvJLOlBPtZMpGqylbB0L8Tc)OxudHnilGnHPoBqXw60SbnBxXxHFgx6xZwuHjumhysgOSjGniylbBuMn9RzlQlfI1baYnW(z9y0OGnOylDA2OmBxXxHFgx6xZwuHjumhysgODP4Ofy6s6xZwufURDTl1aApL(gq0tPlHt4NXwNsDjGBxIGAxkoAbMU0v8v4NXU0vKfXUK7xGVukGFGgAbg2sWg0S1a6so(hO46rVOgcBqMTdaKBG9Zso(hO4Qj(HwGHT0Pz7k(k8Z46rzCGjHk(HIn2GQl1qY5lxTatxAhkVszJGhW0INc2OgX)afjSrdE2C)c8LsbBpqdTadBfnB7r2UJlKTKTj2WbFzky7rzCyd8SrnI)bkY2(kNzdtYTEKnWWMEJS5(Lx8uWMgVmQDPR4HNWd7sKTLl8HItgHLJ)bk21(gc3tPlHt4NXwNsDjGBxIGAxkoAbMU0v8v4NXU0vKfXUK7xGVukGFGgAbg2sWg0S1qFrA6f5UUwIUSLGnIlMZWA8YOsw0XadOH3o1fsyZr2eMT0Pz7k(k8Z46rzCGjHk(HIn2GQl1qY5lxTatxAhkVszJGhW0INc2Cirxv8rcB0GNn3VaFPuW2d0qlWWwrZ2EKT74czlzBInCWxMc2Eugh2apBs31fBfHnrx2adBcNIZDPR4HNWd7sKTLl8HItgHFrxv8XU23iz9u6s4e(zS1Puxc42LiO2LIJwGPlDfFf(zSlDfzrSl1qFrA61fonu1yj6Ywc2GMTg6lstVi311s0LT0PzZlik(WbHeesnWp6f1qyZr2OoBqXwc2AaD9IUQ4JRh9IAiS5iBc3LAi58LRwGPlTdLxPS5qIUQ4Je2kA2eACAOQHZs311UjNGO4ZwYtibHudBfHnrx2IPX2EKT74cztyNzJGhW0iSLrALnWWMEJS5qIUQ4JSbjaP0LUIhEcpSlr2wUWVORk(yx7B4GEkDjCc)m26uQl1qY5lxTatxsYfpvKzJAe)duKTyAS5qIUQ4JSrqv0Ln3VapBkGnhojsmYI1ekY2jiAx68LIFfDjnY4OlmjsmYI1ekUWj8ZyJTeSrz2AOVin9so(hO4ctIeJSynHIn2sWwdOl54FGIlxpXSwU5cF2GSa2GGTeSDaGCdSFwysKyKfRjuC9OxudHniZMWSLGnIlMZWA8YOsw0XadOH3o1fsytaBqWwc2(OAW4fo6kAnYQg2CKnQjBjyRb0LC8pqX1JErne2Gu2O(AtSbz204LrDPLhcRa4wHDP4Ofy6sYX)af7AFJn1tPlHt4NXwNsDPZxk(v0L0iJJUWKiXilwtO4cNWpJn2sWg0SH004rRle(a88bWUGAucBokGTJlSxKemXfNgBjy7aa5gy)SWKiXilwtO46rVOgcBqMniylbBnGUErxv8X1JErne2Gu2O(AtSbz204LrDPLhcRa4wHSbvxkoAbMU0l6QIp21(guZEkDjCc)m26uQl1qY5lxTatxIAe)duKnr3Ti66eBrMayt)cjSPa2ejiBLYwqylyJ4INkYSjJd(HcE2ObpB6nYwoikBPgsYMpsdEKTGn6AkYn(DjAWdpysAFdi6sXrlW0LCbGm8JeG4FWU23i52tPlHt4NXwNsDPZxk(v0LEK(rYD4Nr2sW2b45dGDb1OKvdPRtPS5Oa2GGTeSbnBUEIzTCZf(SbzbSbbBPtZ2JErne2GSa206SfwlpKTeSrCXCgwJxgvYIogyan82PUqcBokGTKXguSLGnOzJYSHjrIrwSMqXgBPtZ2JErne2GSa206SfwlpKniLnHzlbBexmNH14LrLSOJbgqdVDQlKWMJcylzSbfBjydA204LrDPLhcRa4wHSTz2E0lQHWguS5iBoGTeS5fefF4GqccPg4h9IAiSjGnQ3LIJwGPljh)duSR9neQ6P0LWj8ZyRtPUen4HhmjTVbeDP4Ofy6sUaqg(rcq8pyx7BSJ7P0LWj8ZyRtPUuC0cmDj54FGIDPZxk(v0LOmBxXxHFgxKTLl8HItgHLJ)bkYwc2EK(rYD4Nr2sW2b45dGDb1OKvdPRtPS5Oa2GGTeSbnBUEIzTCZf(SbzbSbbBPtZ2JErne2GSa206SfwlpKTeSrCXCgwJxgvYIogyan82PUqcBokGTKXguSLGnOzJYSHjrIrwSMqXgBPtZ2JErne2GSa206SfwlpKniLnHzlbBexmNH14LrLSOJbgqdVDQlKWMJcylzSbfBjydA204LrDPLhcRa4wHSTz2E0lQHWguS5iBqimBjyZlik(WbHeesnWp6f1qytaBuVlDO4KrynEzuj9nGOR9nGG69u6s4e(zS1PuxkoAbMU05lpcyGv0ZfjAx6qXjJWA8YOs6Barx68LIFfDjIlMZWA8YOsyZrbSjmBjydPPXJwxi8b45dGDb1Oe2CuaBoGTeSHd(YuSEugh4dWZVgSXMJSjm1zlbBqZgLz7aa5gy)SUWPHQgRhJgfSLonBnGUErxv8XLwNT1iZguSLGTh9IAiSbz2eMnNzlzSbPSbnBexmNH14LrLWMJcyZbSbvxQHKZxUAbMUuQ)YJag2sb9CrIYgyyZtmRLBgztJxgvcBHYMdCMTudjzB)noS9IZuJmBarLTAyt4nVjcBbHTmyKzliSThz7oUq2WbikFZ2JY4Wwmn2IhhHOSrqvRrMnrx2ObpBcnonu1OR9nGaIEkDjCc)m26uQl1qY5lxTatxANerx2eDzZHeDvXhzlu2CGZSbg2ICMnnEzujSb9(BCylxx1iZwgmYSHdqu(MTyASnaLnYeUKBGcvx68LIFfDjkZ2v8v4NXfzB5c)IUQ4JSLGnKMgpADHWhGNpa2fuJsyZrbS5a2sW2J0psUd)mYwc2GMnxpXSwU5cF2GSa2GGT0Pz7rVOgcBqwaBAD2cRLhYwc2iUyodRXlJkzrhdmGgE7uxiHnhfWwYydk2sWg0Srz2WKiXilwtOyJT0Pz7rVOgcBqwaBAD2cRLhYgKYMWSLGnIlMZWA8YOsw0XadOH3o1fsyZrbSLm2GITeSPXlJ6slpewbWTczBZS9OxudHnhzdA2CaBoZg0S9IdsdEzC1cYDnYWKdqCApMx4e(zSXgKY2Mydk2CMnOz7fhKg8Y4QbaE(5OHlCc)m2ydszBtSbfBoZg0SDfFf(zC9OmoWKqf)qXgBqkBut2GInO6sXrlW0LErxv8XU23acH7P0LWj8ZyRtPUuC0cmDPx0vfFSlD(sXVIUeLz7k(k8Z4ISTCHpuCYi8l6QIpYwc2OmBxXxHFgxKTLl8l6QIpYwc2qAA8O1fcFaE(ayxqnkHnhfWMdylbBps)i5o8ZiBjydA2C9eZA5Ml8zdYcydc2sNMTh9IAiSbzbSP1zlSwEiBjyJ4I5mSgVmQKfDmWaA4TtDHe2CuaBjJnOylbBqZgLzdtIeJSynHIn2sNMTh9IAiSbzbSP1zlSwEiBqkBcZwc2iUyodRXlJkzrhdmGgE7uxiHnhfWwYydk2sWMgVmQlT8qyfa3kKTnZ2JErne2CKnOzZbS5mBqZ2loin4LXvli31idtoaXP9yEHt4NXgBqkBBInOyZz2GMTxCqAWlJRga45NJgUWj8ZyJniLTnXguS5mBqZ2v8v4NX1JY4atcv8dfBSbPSrnzdk2GQlDO4KrynEzuj9nGOR9nGiz9u6s4e(zS1PuxQHKZxUAbMU0okYz)4SLTKh4WSL6V8iGHTuqpxKOSTV0B20BKns4HSLbY1HTGWw4dUqNyZxuzRKhWxJmB6nYgo4ltbBhW0kTadHTIMT9iBXJJqu2ej1iZMdj6QIp2LoFP4xrxI4I5mSgVmQe2CuaBcZwc2qAA8O1fcFaE(ayxqnkHnhfWMdylbBp6f1qydYSjmBoZwYydszdA2iUyodRXlJkHnhfWMdydQUuC0cmDPZxEeWaRONls0U23ach0tPlHt4NXwNsDPgsoF5Qfy6sP(lpcyylf0ZfjkBGHnPuyROzRg2CJPHE1HTyASny8zkyZlsInCWxMc2IPXwrZMdpx4a8yBpyeIYwdWMh4r2AHxiJS1er2uaBPqPDtojFx68LIFfDjIlMZWA8YOsytaBqWwc2OmBV4G0GxgxTGCxJmm5aeN2J5foHFgBSLGnVGO4dhesqi1a)OxudHnbSrD2sWgstJhTUq4dWZha7cQrjS5Oa2GMTJlSxKemXfNgBBMniydk2sW2J0psUd)mYwc2OmBysKyKfRjuSXwc2GMnkZwd9fPPxK76Aj6Ywc2GMnCWxMIvdPRtPSbzbSj8MyZz2WbFzkwpkJd8b45xd2ydk2GITeSPXlJ6slpewbWTczBZS9OxudHnhzZbDP4Ofy6sNV8iGbwrpxKODTRDTlDHpPatFdHPUWqqDQPWj3U0(4NAKjDPDIK3H2yNUb1GAzJTuUr2kpxWRSrdE2eYvmf5wiS9OqTy9yJncWdzlevGxOyJTZDmYizXuTd1GSbb1YwQbZf(k2ytiV4G0Gxgx7SqytbSjKxCqAWlJRDEHt4NXMqydAHtcQft1oudYg1KAzl1G5cFfBSjKxCqAWlJRDwiSPa2eYloin4LX1oVWj8ZytiSbnejb1IPIPANi5DOn2PBqnOw2ylLBKTYZf8kB0GNnH4(4b45hQqy7rHAX6XgBeGhYwiQaVqXgBN7yKrYIPAhQbzZbulBPgmx4RyJnHOFnBrDbXANfcBkGnHOFnBrDPqS2zHWg0jljOwmv7qniBoGAzl1G5cFfBSje9RzlQlHx7SqytbSje9RzlQlv41ole2Gw4KGAXuTd1GSTjQLTudMl8vSXMq0VMTOUGyTZcHnfWMq0VMTOUuiw7SqydAHtcQft1oudY2MOw2snyUWxXgBcr)A2I6s41ole2uaBcr)A2I6sfETZcHnOtwsqTyQyQ2jsEhAJD6gudQLn2s5gzR8CbVYgn4ztiT6XJke2EuOwSESXgb4HSfIkWluSX25ogzKSyQ2HAq22XulBPgmx4RyJnH8IdsdEzCTZcHnfWMqEXbPbVmU25foHFgBcHnOHijOwmvPCJSrdYzW(AKzle)GW2E8r2ejyJTAytVr2IJwGHTCru28fv22JpY2au2ObItJTAytVr2IwdmS1cn8dcsTmvSTz28I)b7XgSm6ruWGW4ChZb9WrzQyQ2jsEhAJD6gudQLn2s5gzR8CbVYgn4ztiNgriS9OqTy9yJncWdzlevGxOyJTZDmYizXuTd1GS5aQLTudMl8vSXMu5LA2iumAKeBcfSPa22bXGTwDvKcmSbCXpuWZg07cfBqlCsqTyQ2HAq2OMulBPgmx4RyJnPYl1SrOy0ij2ekytbSTdIbBT6Qifyyd4IFOGNnO3fk2Gw4KGAXuTd1GSTJPw2snyUWxXgBsLxQzJqXOrsSjuWMcyBhed2A1vrkWWgWf)qbpBqVluSbTWjb1IPAhQbzdcQtTSLAWCHVIn2KkVuZgHIrJKytOGnfW2oigS1QRIuGHnGl(HcE2GExOydAHtcQft1oudYMWuNAzl1G5cFfBSje9RzlQlHx7SqytbSje9RzlQlv41ole2GgIKGAXuTd1GSjmeulBPgmx4RyJnHOFnBrDbXANfcBkGnHOFnBrDPqS2zHWg0qKeulMkMQDIK3H2yNUb1GAzJTuUr2kpxWRSrdE2esdOcHThfQfRhBSraEiBHOc8cfBSDUJrgjlMQDOgKnhqTSLAWCHVIn2ecMejgzXAcfBRDwiSPa2esd9fPPx78ctIeJSynHInHWg0qKeulMQDOgKniGGAzl1G5cFfBSjKxCqAWlJRDwiSPa2eYloin4LX1oVWj8ZytiSbTWjb1IPAhQbzdcHPw2snyUWxXgBc5fhKg8Y4ANfcBkGnH8IdsdEzCTZlCc)m2ecBqlCsqTyQ2HAq2GWbulBPgmx4RyJnH8IdsdEzCTZcHnfWMqEXbPbVmU25foHFgBcHnOHijOwmvmvPCJSjerccxk6recBXrlWW2(GW2au2ObItJTAytVlcBLNl41ft1o1Zf8k2yl5YwC0cmSLlIswmvDjIlE6Bi8M2XDj3hqxzSlLQuXwYtibHutOfyyZHaYIitvQsfBujoiBcNCDInHPUWqWuXuLQuXwQVJrgjultvQsfBBMTK31ntbBcHOFDuHWgDoKztbSraEiBjpKChyJg8BjSPa2iXfYM7doiHuJmBA5HlMQuLk22mBqcWieLnHoMICZM4KrcHnPCDq2IPXgKOoiB7RCMTCqu2YGrgF207yyl5eefF2sEcjiKAwmvPkvSTz2CimhjX2okhYyohAbg22LnHgNgQAWgHI5Wg0fnBcnonu1GTIWMcKLZyJnannBGNnWWwWwgmYSLAibulMkMQuLk2C4KWJOIn28rAWJSDaE(HYMpkxdzXwYFoORsyBaZMVJ3JwmZwC0cme2atMIftvC0cmKL7JhGNFOccx3mfWUGIagMQ4Ofyil3hpap)qDwWU(avZydMohuGT91idRGKQHPkoAbgYY9XdWZpuNfSRx8BXgmn4HByO3o5(4b45hkmbpGPreSjNkAbFuny8chDfTgzvJJqSjMQuXgKav89QbzB)DDUzd6IMTyOak2iAOS5lstZM(1Sfv22JSTpgLnfWwOk65QSPa2iumh22x6nBcnonu1yXufhTadz5(4b45hQZc29k(k8ZOtt4Hc0VMTOctOyoWKmqD6kYIOaiCQOfOFnBrDbX6oiWIee2xKMob0uw)A2I6s41DqGfjiSVinD606xZwuxqSoaqUb2pRM4hAbghfOFnBrDj86aa5gy)SAIFOfyGkDA9RzlQliwfzvd58IA4NryHAXyurp4gEvhKPkoAbgYY9XdWZpuNfS7v8v4NrNMWdfOFnBrfMqXCGjzG60vKfrbc7urlq)A2I6s41DqGfjiSVinDcOPS(1Sf1feR7GalsqyFrA60P1VMTOUeEDaGCdSFwnXp0cmoQFnBrDbX6aa5gy)SAIFOfyGkDA9RzlQlHxfzvd58IA4NryHAXyurp4gEvhKPkoAbgYY9XdWZpuNfSljxheoMgCRoOtUpEaE(HctWdyAebq4url4r6hj3HFgzQIJwGHSCF8a88d1zb7sumY6ntftvQsfBoCs4ruXgB4f(uWMwEiB6nYwCuWZwrylUIkh(zCXufhTadrW26SLPkvS5qirXiR3Sv0S5ciKYpJSb9ay7smp4h(zKnCqVcjSvdBhGNFOqXufhTadXzb7sumY6ntvC0cmeNfS7v8v4NrNMWdfqQroJWA8YO60vKfrbexmNH14LrLSOJbgqdVDQlKazHzQsfBPg45xd2yZHh8LPGnhcLXHTbXg2ytbSrcv8dfzQIJwGH4SGDVIVc)m60eEOGhLXbMeQ4hk2C6kYIOaCWxMI1JY4aFaE(1Gnht2MyQIJwGH4SGDprodhhTadCUiQtt4Hcikgz9gBor0VoQaiCQOfqumY6n2wpqwezQIJwGH4SGDprodhhTadCUiQtt4HconIte9RJkacNCQOfanL1iJJU8cIIpCqibHuZcNWpJT0PBaDjh)duCP1zBnYqXuLk2GKIkBsdKGnrx2QP0kYzkyJg8SLArLnfWMEJSL67GGoX2J0psUzBFP3S5WZfoap2kA2cLTmypBnXp0cmmvXrlWqCwWUKCDq4yAWT6Gov0cOSVin9IKRdchtdUvhCj6M4a88bWUGAuIJcGGPkoAbgIZc2fNlCaEov0c8fPPxKCDq4yAWT6Glr3e(I00lsUoiCmn4wDW1JErneiVPehGNpa2fuJsCuGdyQIJwGH4SGDprodhhTadCUiQtt4HcAaLPkoAbgIZc29e5mCC0cmW5IOonHhkOvpEuMQ4Ofyioly34pXGWk4FCuNkAb4GVmfRgsxNsDuaeBYzCWxMI1JY4aFaE(1GnMQ4Ofyioly34pXGWUIzcYufhTadXzb7Ml5BLaluMyt2dhLPkoAbgIZc21pKHb0W6xNTeMkMQuLk2snaKBG9dHPkvSTtPzlAncBXJSj66eBKPCr20BKnWGSTV0B2YG9irzlLuGel2ekLGST)gh2AuuJmB0brXNn9og2snKKTgsxNszd8STV0BGOYwmuWwQHKlMQ4OfyiRtJ4SGD9IFl2GPbpCdd92PCni8PjaI1MC6qXjJWA8YOseaHtfTGpQgmEHJUIwJSeDtaTgVmQlT8qyfa3keYhGNpa2fuJswnKUoLcPqS2u60hGNpa2fuJswnKUoL6OGJlSxKemXfNgumvPITDknBdGTO1iSTVYz2AfY2(sVRHn9gzBWKu2sg1joXMibzl5qdjydmS5die22x6nquzlgkyl1qYftvC0cmK1PrCwWUEXVfBW0GhUHHE7url4JQbJx4ORO1iRACmzuFZFuny8chDfTgz1e)qlWK4a88bWUGAuYQH01PuhfCCH9IKGjU40yQsfBsumh22r5qgZ5qlWW2(sVztOXPHQgSfe2YGrMTGW2EKT9GrikBzabzly7eeLnWf(SP3iB0L8TYwt8dTadBqdE2kA2eACAOQbB7RCMTdWdzZpoBzlKJA2TiSPaz5m2ydqtd1IPkoAbgY60iolyx6CiJ5COfyCQOfqzIIrwVX26bYIycOH(aa5gy)SUWPHQgRh9IAioUJPE60hai3a7N1fonu1y9OxudbYjdQeinnE06cHpapFaSlOgL4OahKqJxg1LwEiScGBf6ieupD6g6lstVUWPHQglr30P9besc6s(wHF0lQHazHDaumvXrlWqwNgXzb7sNdzmNdTaJtfTaktumY6n2wpqwetG004rRle(a88bWUGAuIJcCqcOPZaWdn00L8Tc)OxudzZc7aOekoaqUb2pq5iDgaEOHMUKVv4h9IAiBwyhS5daKBG9Z6cNgQASE0lQHaPxXxHFgxx40qvd4t7HsO4aa5gy)afumvPInjkMdBsOlPiSTV0B2eACAOQbBbHTmyKzliSThzBpyeIYwgqq2c2obrzdCHpB6nYgDjFRS1e)qlW4eB(IkBUpsJpBA8YOsytVdLT9voZwUUq2cLTmgeLniOoHPkoAbgY60iolyxc6skItfTaktumY6n2wpqweta9baYnW(zDHtdvnwp6f1qGmej04LrDPLhcRa4wHocb1tNUH(I00RlCAOQXs0nDA6s(wHF0lQHaziOoumvXrlWqwNgXzb7sqxsrCQOfqzIIrwVX26bYIycOPZaWdn00L8Tc)OxudzZqqDOekoaqUb2pq5iDgaEOHMUKVv4h9IAiBgcQV5daKBG9Z6cNgQASE0lQHaPxXxHFgxx40qvd4t7HsO4aa5gy)afumvPInjkMdBcnonu1GT910a7zBFP3STrjFRenYBX3zhojsmYI1ekYwrZw46MRt4NrMQ4OfyiRtJ4SGDVIVc)m60eEOGlCAOQb8uY3krJ8w8HpGPvAbgNUISikGYAKXrxtjFRenYBXFHt4NXw60uwJmo6ctIeJSynHIlCc)m2sN(aa5gy)SWKiXilwtO46rVOgcK30Mfgs1iJJUAi6Ipmr)qdz0BHt4NXgtvQytII5WMqJtdvnyBFP3STJYHmMZHwGHTyASjHUKIWwqyldgz2ccB7r22dgHOSLbeKTGTtqu2ax4ZMEJSrxY3kBnXp0cmmvXrlWqwNgXzb7EfFf(z0Pj8qbx40qvd4d4cNyu4dyALwGXPIwWbCHtm6AlfFft60hWfoXORbppid(w60hWfoXORbmOtxrwefabtvC0cmK1PrCwWUxXxHFgDAcpuWfonu1a(aUWjgf(aMwPfyCQOfCax4eJUUWrVP4D6kYIOa6ma8qdnDjFRWp6f1q2SWuhkHcOHqyQdPxXxHFgxx40qvd4t7HckhPZaWdn00L8Tc)OxudzZct9nFaGCdSFw05qgZ5qlWSE0lQHaLqb0qim1H0R4RWpJRlCAOQb8P9qbv60(I00l6CiJ5COfyG9fPPxIUPt3qFrA6fDoKXCo0cmlr30PPl5Bf(rVOgcKfM6mvXrlWqwNgXzb7EfFf(z0Pj8qbx40qvd4d4cNyu4dyALwGXPIwWbCHtm6Ak5BfMoqNUISikGodap0qtxY3k8JErnKnlm1HsOaAieM6q6v8v4NX1fonu1a(0EOGYr6ma8qdnDjFRWp6f1q2SWuFZhai3a7NfbDjfz9OxudbkHcOHqyQdPxXxHFgxx40qvd4t7HcQ0PBaDrqxsrwAD2wJC600L8Tc)OxudbYctDMQ4OfyiRtJ4SGDVWPHQgov0cOmrXiR3yB9azrmrdORx0vfFCP1zBnYjOCd9fPPxx40qvJLOBIR4RWpJRlCAOQb8uY3krJ8w8HpGPvAbMexXxHFgxx40qvd4d4cNyu4dyALwGHPkvS5WjrIrwSMqr22FJdBdqzJOyK1BSXwmn28b6nBoKORk(iBX0yJAe)duKT4r2eDzJg8SLbJmB4aeLVxmvXrlWqwNgXzb7IjrIrwSMqrNkAbuMOyK1BSTEGSiMaAk3a6so(hO46r6hj3HFgt0a66fDvXhxp6f1qC0bo7ai94c7fjbtCXPLoDdORx0vfFC9OxudbsP(AtoQXlJ6slpewbWTcHkHgVmQlT8qyfa3k0rhWuLk2KURl2kA22JSfpYw4dev2uaBo8CHdWZj2IPXwOk65QSPa2iumh22x6nBsOlPiSrxtKz7Uu2kA22JSThmcrzBFquKnpWJSP3XW2DKPztVr2oaqUb2plMQ4OfyiRtJ4SGDj31LtfTGgqxVORk(4sRZ2AKtanLpaqUb2plc6skY6XOrr60hai3a7N1fonu1y9OxudXriegQ0PBaDrqxsrwAD2wJmtvC0cmK1PrCwWUUaTaJtfTaFrA6LFgaAzrIUEmoA60(acjbDjFRWp6f1qGCYOE60n0xKMEDHtdvnwIUmvXrlWqwNgXzb76NbGgmT4tHtfTGg6lstVUWPHQglrxMQ4OfyiRtJ4SGD9XNG)2AKDQOf0qFrA61fonu1yj6YufhTadzDAeNfSlD9OFgaAov0cAOVin96cNgQASeDzQIJwGHSonIZc2nMds0pYWNiNDQOf0qFrA61fonu1yj6YufhTadzDAeNfS7jYz44OfyGZfrDAcpuWvmf52PIwaLjkgz9gBRiNt4fefF4GqccPg4h9IAicOEcOPSgzC0Lxqu8HdcjiKAw4e(zSLoTVin9IKRdchtdUvhC9OxudXXKbftvQytII5WMEJS5(f4lLc2iAOS5lstZM(1Sfv22x6nBcnonu1Wj2a6n(7lcYMibzdmSDaGCdSFyQIJwGHSonIZc2v)A2Ikeov0cUIVc)mU0VMTOctOyoWKmqfarcOBOVin96cNgQASeDtN2hqijOl5Bf(rVOgcKfim1HkDAOVIVc)mU0VMTOctOyoWKmqfiCckRFnBrDj86aa5gy)SEmAuav60u(k(k8Z4s)A2IkmHI5atYaLPkoAbgY60iolyx9RzlQc7url4k(k8Z4s)A2IkmHI5atYavGWjGUH(I00RlCAOQXs0nDAFaHKGUKVv4h9IAiqwGWuhQ0PH(k(k8Z4s)A2IkmHI5atYavaejOS(1Sf1feRdaKBG9Z6XOrbuPtt5R4RWpJl9RzlQWekMdmjduMkMQuLk2Ge1JhLTw4fYiBHFLlTqctvQyZHNlCaESfkBoWz2GEtoZ2(sVzdsibfBPgsUyBN65HTkumtbBGHnHDMnnEzujoX2(sVztOXPHQgoXg4zBFP3SLcLekjBa9g)9fbzBFukB0GNncWdzdh8LPyXwYNja22hLYwrZMdNerMTdWZhWwry7a8QrMnr3ftvC0cmKvRE8OcW5chGNtfTaKMgpADHWhGNpa2fuJsCuGdCwJmo6QHOl(We9dnKrVfoHFgBjGUH(I00RlCAOQXs0nD6g6lstVi311s0nD6g6lstVOZHmMZHwGzj6Mono4ltXQH01Puilq4n5mo4ltX6rzCGpap)AWw60u(k(k8Z4IuJCgH14LrfQeqtznY4OlmjsmYI1ekUWj8ZylD6daKBG9ZctIeJSynHIRh9IAiokmumvXrlWqwT6XJ6SGDVIVc)m60eEOarcctx5m(oDfzruWb45dGDb1OKvdPRtPocr604GVmfRgsxNsHSaH3KZ4GVmfRhLXb(a88RbBPtt5R4RWpJlsnYzewJxgvMQuXwY76MPGnjkjXMcylYz204LrLW2(sVbIkBbBn0xKMMTGWM7xGVukCIn3hPX)RrMnnEzujS1OOgz2iaWGpBbTIpB6nYM7xEXtbBA8YOYufhTadz1QhpQZc2LG)hk2G9bdctCRTOtfTGR4RWpJlrcctx5m(jOCdOlc(FOyd2hmimXT2IWnGU06STgzMQ4OfyiRw94rDwWUe8)qXgSpyqyIBTfD6qXjJWA8YOseaHtfTGR4RWpJlrcctx5m(jOCdOlc(FOyd2hmimXT2IWnGU06STgzMQuX2oXnoSLCsE2kcBdqzlu2Ul5B2AIFOfyCInrcYMeLKytbSfUUzkyBhWOXMpfS5WjfEUzKTM4xJmBcnonu1Wj2a6n(7lcY2weDzJ(bESDcx3AKz7ChVmsyQIJwGHSA1Jh1zb7sW)dfBW(GbHjU1w0PIwWv8v4NXLibHPRCg)eEbrXhoiKGqQb(rVOgcKP(sOkb00L8Tc)OxudbYc2u60hai3a7Nfb)puSb7dgeM4wBXLxKe85oEzKS5ZD8YibM(JJwGjYqwa1xcVP0PjaXSFnTvgJgSpfWysHNBgx4e(zSLGY(I00RmgnyFkGXKcp3mUeDt0qFrA61fonu1yj6MoTVin9Yl(hShBWYOhrbdcJZDmh0dhDj6cftvQyBhfdBaA22jN6cjSfkBqSJDMnIgNTe2a0SjuE1A4WgLYrdjSbE2c5OgIYMdCMnnEzujlMQ4OfyiRw94rDwWU0XadOH3o1fsCQOfCfFf(zCjsqy6kNXpb0(I00R7Q1Wb2phnKSiAC26Oai2XPtdnLD)c8Lsb8d0qlWKG4I5mSgVmQKfDmWaA4TtDHehf4aNjkgz9gBRhilIqbftvQyBhfdBaA22jN6cjSPa2cx3mfS5ckcyiSv0SvtC06czdmSfdfSPXlJkBqdE2IHc28Zi2QrMnnEzujSTV0B2C)c8LsbBpqdTaduSfkBjlfMQ4OfyiRw94rDwWU0XadOH3o1fsC6qXjJWA8YOseaHtfTGR4RWpJlrcctx5m(jiUyodRXlJkzrhdmGgE7uxiXrbjJPkoAbgYQvpEuNfSlEUb1id)O7xEX0CQOfCfFf(zCjsqy6kNXpXbaYnW(zDHtdvnwp6f1qCecQZufhTadz1QhpQZc2n88fj3ov0cUIVc)mUejimDLZ4NaAVGO4dhesqi1a)Oxudra1tq5xCqAWlJRga45NJgMoTVin9YpxtJunCj6cftvQylLWFZjhrTYHISPa2cx3mfSbjWOLPGnijOiGHTqzty204LrLWufhTadz1QhpQZc21tuRCOOthkozewJxgvIaiCQOfCfFf(zCjsqy6kNXpbXfZzynEzujl6yGb0WBN6cjceMPkoAbgYQvpEuNfSRNOw5qrNkAbxXxHFgxIeeMUYz8zQyQsvQydseEHmYg4cF20Ydzl8RCPfsyQsfB7q5vkBe8aMw8uWg1i(hOiHnAWZM7xGVuky7bAOfyyROzBpY2DCHSLSnXgo4ltbBpkJdBGNnQr8pqr22x5mBysU1JSbg20BKn3V8INc204LrLPkoAbgYQbubxXxHFgDAcpuazB5cFO4Kry54FGIoDfzruG7xGVukGFGgAbMeq3a6so(hO46rVOgcKpaqUb2pl54FGIRM4hAbM0PVIVc)mUEughysOIFOydkMQuX2ouELYgbpGPfpfS5qIUQ4Je2ObpBUFb(sPGThOHwGHTIMT9iB3XfYwY2eB4GVmfS9OmoSbE2KURl2kcBIUSbg2eofNzQIJwGHSAa1zb7EfFf(z0Pj8qbKTLl8HItgHFrxv8rNUISikW9lWxkfWpqdTatcOBOVin9ICxxlr3eexmNH14LrLSOJbgqdVDQlK4OWPtFfFf(zC9OmoWKqf)qXgumvPITDO8kLnhs0vfFKWwrZMqJtdvnCw6UU2n5eefF2sEcjiKAyRiSj6Ywmn22JSDhxiBc7mBe8aMgHTmsRSbg20BKnhs0vfFKnibifMQ4OfyiRgqDwWUxXxHFgDAcpuazB5c)IUQ4JoDfzruqd9fPPxx40qvJLOBcOBOVin9ICxxlr30P9cIIpCqibHud8JErnehPoujAaD9IUQ4JRh9IAiokmtvQytYfpvKzJAe)duKTyAS5qIUQ4JSrqv0Ln3VapBkGnhojsmYI1ekY2jiktvC0cmKvdOolyx54FGIov0c0iJJUWKiXilwtO4cNWpJTeugtIeJSynHITLC8pqXenGUKJ)bkUC9eZA5Ml8HSaisCaGCdSFwysKyKfRjuC9OxudbYcNG4I5mSgVmQKfDmWaA4TtDHebqK4JQbJx4ORO1iRACKAMOb0LC8pqX1JErneiL6RnbznEzuxA5HWkaUvitvC0cmKvdOoly3x0vfF0PIwGgzC0fMejgzXAcfx4e(zSLaAKMgpADHWhGNpa2fuJsCuWXf2lscM4ItlXbaYnW(zHjrIrwSMqX1JErneidrIgqxVORk(46rVOgcKs91MGSgVmQlT8qyfa3kekMQuXg1i(hOiBIUBr01j2ImbWM(fsytbSjsq2kLTGWwWgXfpvKztgh8df8SrdE20BKTCqu2snKKnFKg8iBbB01uKB8zQIJwGHSAa1zb76caz4hjaX)GordE4btsfabtvC0cmKvdOolyx54FGIov0cEK(rYD4NXehGNpa2fuJswnKUoL6OaisaTRNywl3CHpKfar60p6f1qGSaToBH1YdtqCXCgwJxgvYIogyan82PUqIJcsgujGMYysKyKfRjuSLo9JErneilqRZwyT8qiv4eexmNH14LrLSOJbgqdVDQlK4OGKbvcO14LrDPLhcRa4wHB(rVOgcuo6GeEbrXhoiKGqQb(rVOgIaQZufhTadz1aQZc21faYWpsaI)bDIg8WdMKkacMQ4OfyiRgqDwWUYX)afD6qXjJWA8YOseaHtfTakFfFf(zCr2wUWhkozewo(hOyIhPFKCh(zmXb45dGDb1OKvdPRtPokaIeq76jM1Ynx4dzbqKo9JErneilqRZwyT8WeexmNH14LrLSOJbgqdVDQlK4OGKbvcOPmMejgzXAcfBPt)OxudbYc06SfwlpesfobXfZzynEzujl6yGb0WBN6cjokizqLaAnEzuxA5HWkaUv4MF0lQHaLJqiCcVGO4dhesqi1a)Oxudra1zQsfBP(lpcyylf0ZfjkBGHnpXSwUzKnnEzujSfkBoWz2snKKT934W2lotnYSbev2QHnH38MiSfe2YGrMTGW2EKT74czdhGO8nBpkJdBX0ylECeIYgbvTgz2eDzJg8Sj040qvdMQ4OfyiRgqDwWUNV8iGbwrpxKOoDO4KrynEzujcGWPIwaXfZzynEzujokq4einnE06cHpapFaSlOgL4OahKah8LPy9OmoWhGNFnyZrHPEcOP8baYnW(zDHtdvnwpgnksNUb01l6QIpU06STgzOs8OxudbYc7CYGuOjUyodRXlJkXrboakMQuX2ojIUSj6YMdj6QIpYwOS5aNzdmSf5mBA8YOsyd6934WwUUQrMTmyKzdhGO8nBX0yBakBKjCj3afkMQ4OfyiRgqDwWUVORk(OtfTakFfFf(zCr2wUWVORk(ycKMgpADHWhGNpa2fuJsCuGds8i9JK7WpJjG21tmRLBUWhYcGiD6h9IAiqwGwNTWA5HjiUyodRXlJkzrhdmGgE7uxiXrbjdQeqtzmjsmYI1ek2sN(rVOgcKfO1zlSwEiKkCcIlMZWA8YOsw0XadOH3o1fsCuqYGkHgVmQlT8qyfa3kCZp6f1qCeAh4m0V4G0GxgxTGCxJmm5aeN2JziDtq5m0V4G0GxgxnaWZphnes3euod9v8v4NX1JY4atcv8dfBqk1ekOyQIJwGHSAa1zb7(IUQ4JoDO4KrynEzujcGWPIwaLVIVc)mUiBlx4dfNmc)IUQ4JjO8v8v4NXfzB5c)IUQ4JjqAA8O1fcFaE(ayxqnkXrboiXJ0psUd)mMaAxpXSwU5cFilaI0PF0lQHazbAD2cRLhMG4I5mSgVmQKfDmWaA4TtDHehfKmOsanLXKiXilwtOylD6h9IAiqwGwNTWA5HqQWjiUyodRXlJkzrhdmGgE7uxiXrbjdQeA8YOU0YdHvaCRWn)OxudXrODGZq)IdsdEzC1cYDnYWKdqCApMH0nbLZq)IdsdEzC1aap)C0qiDtq5m0xXxHFgxpkJdmjuXpuSbPutOGIPkvSTJIC2poBzl5bomBP(lpcyylf0ZfjkB7l9Mn9gzJeEiBzGCDyliSf(Gl0j28fv2k5b81iZMEJSHd(YuW2bmTslWqyROzBpYw84ieLnrsnYS5qIUQ4JmvXrlWqwnG6SGDpF5radSIEUirDQOfqCXCgwJxgvIJceobstJhTUq4dWZha7cQrjokWbjE0lQHazHDozqk0exmNH14LrL4OahaftvQyl1F5radBPGEUirzdmSjLcBfnB1WMBmn0RoSftJTbJptbBErsSHd(YuWwmn2kA2C45chGhB7bJqu2Aa28apYwl8czKTMiYMcylfkTBYj5zQIJwGHSAa1zb7E(YJagyf9CrI6urlG4I5mSgVmQebqKGYV4G0GxgxTGCxJmm5aeN2J5eEbrXhoiKGqQb(rVOgIaQNaPPXJwxi8b45dGDb1Oehfa9Xf2lscM4ItBZqavIhPFKCh(zmbLXKiXilwtOylb0uUH(I00lYDDTeDtano4ltXQH01Puilq4n5mo4ltX6rzCGpap)AWguqLqJxg1LwEiScGBfU5h9IAio6aMkMQuLk2KumY6n2yl5pAbgctvQyBJs(MOrEl(Sbg2swkulBP(lpcyylf0ZfjktvC0cmKfrXiR3ytW5lpcyGv0ZfjQtfTanY4ORPKVvIg5T4VWj8ZylbXfZzynEzujokizjoapFaSlOgL4OahKqJxg1LwEiScGBfU5h9IAiosnzQsfBBuY3enYBXNnWWgePqTSjnHl5gOS5qIUQ4JmvXrlWqwefJSEJnNfS7l6QIp6urlqJmo6Ak5BLOrEl(lCc)m2sCaE(ayxqnkXrboiHgVmQlT8qyfa3kCZp6f1qCKAYuLk2Ke9v8PfLrQLTK31ntbBGNnhcPFKCZ2(sVzZxKMgBSrnI)bksyQIJwGHSikgz9gBolyxxaid)ibi(h0jAWdpysQaiyQIJwGHSikgz9gBolyx54FGIoDO4KrynEzujcGWPIwGgzC0fr0xXNwugx4e(zSLa6h9IAiqgcHtN21tmRLBUWhYcGaQeA8YOU0YdHvaCRWn)OxudXrHzQsfBsI(k(0IYiBoZMdNerMnWWgePqTS5qi9JKB2OgX)afzlu20BKnCASbOzJOyK1B2uaBYOYMxKeBnXp0cmS5J0GhzZHtIeJSynHImvXrlWqwefJSEJnNfSRlaKHFKae)d6en4HhmjvaemvXrlWqwefJSEJnNfSRC8pqrNkAbAKXrxerFfFArzCHt4NXwcnY4OlmjsmYI1ekUWj8ZylrC06cHXb9kKiaIe(I00lIOVIpTOmUE0lQHaziwjJPkoAbgYIOyK1BS5SGD9e1khk6urlqJmo6Ii6R4tlkJlCc)m2sCaE(ayxqnkbYcsgtftvQsfBcDmf5MPkvSTJQPi3STV0B28IKyl1qs2ObpBBuY3krJ8w8DInXjJecBIKAKzdsGHENPGnP7Ob2tyQIJwGHSUIPi3cUIVc)m60eEOGPKVvIg5T4dFCHpGPvAbgNUISikaAk)IdsdEzC1WqVZuatUJgypjbstJhTUq4dWZha7cQrjok44c7fjbtCXPbv60q)IdsdEzC1WqVZuatUJgypjXb45dGDb1OeilmumvPInHoMICZ2(sVzZHtIiZMZSTrjFRenYBXNAzl5ejvEIESLAijBX0yZHtIiZ2JrJc2ObpBdMKYg1i1qcMQ4OfyiRRykYTZc29kMIC7urlqJmo6ctIeJSynHIlCc)m2sOrghDnL8Ts0iVf)foHFgBjUIVc)mUMs(wjAK3Ip8Xf(aMwPfysCaGCdSFwysKyKfRjuC9OxudbYqWuLk2e6ykYnB7l9MTnk5BLOrEl(S5mBBayZHtIitTSLCIKkprp2snKKTyASj040qvd2eDzQIJwGHSUIPi3oly3RykYTtfTanY4ORPKVvIg5T4VWj8ZylbL1iJJUWKiXilwtO4cNWpJTexXxHFgxtjFRenYBXh(4cFatR0cmjAOVin96cNgQASeDzQIJwGHSUIPi3olyxxaid)ibi(h0jAWdpysQaiCcts)ao8aIJkWbBIPkoAbgY6kMIC7SGDVIPi3ov0c0iJJUiI(k(0IY4cNWpJTehai3a7NLC8pqXLOBcOBaDjh)duC9i9JK7WpJPt3qFrA61fonu1yj6MOb0LC8pqXLRNywl3CHpKfabujoapFaSlOgLSAiDDk1rbqtCXCgwJxgvYIogyan82PUqIJcLWbqL4JQbJx4ORO1iRACecHzQsfBcDmf5MT9LEZwYjik(SL8esqQHAzZHeDvXhDMAe)duKTbOSvdBps)i5MTpgz0j2AIFnYSj040qvdNLURRfBsumh22x6nBsOlPiSrxtKz7Uu2kA2Cbes5NXftvC0cmK1vmf52zb7EftrUDQOfaTgzC0Lxqu8HdcjiKAw4e(zSLo9loin4LXLx8BHb0W6nc7fefF4GqccPgOsq5gqxVORk(46r6hj3HFgt0a6so(hO46rVOgIJjlrd9fPPxx40qvJLOBcOBOVin9ICxxlr30PBOVin96cNgQASE0lQHazhKoDdOlc6skYsRZ2AKHkrdOlc6skY6rVOgcKtwx7AVda]] )


end