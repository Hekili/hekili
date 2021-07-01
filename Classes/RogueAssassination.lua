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

            cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + 2 end,

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

            cp_gain = function () return ( buff.broadside.up and 1 or 0 ) + active_dot.serrated_bone_spike end,

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


    spec:RegisterPack( "Assassination", 20210629, [[deLiucqiKOEKOsDjLsvTjQQ(eiyuGKtbIwLsP8kQknlQq3sPe7sj)ceAyechtL0YiKEMsrMgHORPuuBdjj9nQayCubOZrfqRdjPENsjPY8qICpc1(OI6FkLKIdkQKwisIhsfPjQuQCrQiAJkLeFejjgjvqroPsPkRej1lPckmtQiCtQGQDQu4NkLKQgQsj1sPc0tjYufvCvLssPTsfKVQusYyfvI9kP)cQbt5WclMQ8yvmzjUm0MrQptuJwL60sTAQGI61QeZwKBlk7wXVbgov64ubLwUQEoIPt66eSDLQVdsnEQkopsy(IQ2pQRxR5uLkHI1neveIEveuvrDGRRxfPduKoavjLcxSk5gNlHmwLMidRs5kHeespH2GPk5guKarPMtvIae(dwLUv1Lq1qeIYTEl4ToGmis6mHuOnyoFqRqK0zhiwL8e6KU9MQxvQekw3quri6vrqvf1bUUEvKoqrsvRsHGEd(QKuN50Q0Dxk4u9QsfKCQs5kHeespH2GHnheilGm1ulmiBI6aDKnrfHOxzQzQD6DmYiHQzQ3cB5QRBIc2Gar)(OqGn6uiZMcyJaYq2Y1T2jyJg8xiSPa2iXoYM7doiH0JmBANHlM6TW22bgiOS5qX0KB2eMesiSjL6dYwmf22U(GSbDNsSLcIYwcmY4ZMEhdBo8GO4ZwUsibH0ZIPElS5Gyk8HTTskKXuk0gmSbr2CiCkOQbBekMdBq10S5q4uqvd2AcBkqwoHf2a00SbE2adBbBjWiZMt3oixvPutusnNQerXiP3yPMtDJR1CQs4eEjSuPsvkoAdMQ057mcyGvmZfjAvQGKZ3UAdMQ0gT8nrJ0f8zdmSTPCOA2C63zeWWwoyMls0Q05Bf)oQsAKWrxtlFRensxWFHt4LWcB(zJ4IPeSgVmQe2CwmBBIn)SDazEayxqpkHnNfZMizZpBA8YOU0odHvaCPr22cBpMf9qyZz2OQvTUHO1CQs4eEjSuPsvkoAdMQ0l4QcpwLki58TR2GPkTrlFt0iDbF2adBxZHQztAcxYnqzZbfCvHhRsNVv87OkPrchDnT8Ts0iDb)foHxclS5NTdiZda7c6rjS5Sy2ejB(ztJxg1L2ziScGlnY2wy7XSOhcBoZgvTQ1n2unNQeoHxclvQuLIJ2GPk5caj4hjaH)GvPcsoF7QnyQsscEk(0cYivZwU66MOGnWZMdI0psUzd6wVzZtGMglSrvI)bksQs0GhEqF06gxRADdrwZPkHt4LWsLkvP4OnyQsYX)afRsNVv87OkPrchDre8u8PfKXfoHxclS5NnOy7XSOhcBuITRIYw(8S5MjK02n14ZgLeZ2v2GKn)SPXlJ6s7mewbWLgzBlS9yw0dHnNzt0Q0HItcH14LrLu34AvRBS5AovjCcVewQuPkfhTbtvYfasWpsac)bRsfKC(2vBWuLKe8u8PfKr28LnN0hImBGHTR5q1S5Gi9JKB2OkX)afzlu20BKnCkSbOzJOyK0B2uaBYOYww4dBfHp0gmS5H0GhzZj9HeJSqpHIvjAWdpOpADJRvTUbvTMtvcNWlHLkvQsNVv87OkPrchDre8u8PfKXfoHxclS5Nnns4Ol0hsmYc9ekUWj8syHn)SfhT3ryCWSgjSjMTRS5NnpbA6frWtXNwqgxpMf9qyJsSDDTPQuC0gmvj54FGIvTUHdqnNQeoHxclvQuLoFR43rvsJeo6Ii4P4tliJlCcVewyZpBhqMha2f0JsyJsIzBtvP4OnyQszcANcfRAvRs7X0K7Ao1nUwZPkHt4LWsLkvjGBvIGAvkoAdMQ0E8D4LWQ0EKeWQeuSrz2EHbPbVmUkyO3jkGj3rbanzHt4LWcB(zdPPXJ27i8bK5bGDb9Oe2CwmBhx4SWhyIlof2GKT85zdk2EHbPbVmUkyO3jkGj3rbanzHt4LWcB(z7aY8aWUGEucBuInrzdYQubjNVD1gmvPTspn5MnOB9MTSWh2C6wZgn4zBJw(wjAKUGVJSjmjKqytG0JmBBhg6DIc2KUJcaAsvApE4jYWQ00Y3krJ0f8HpUWhWuATbtvRBiAnNQeoHxclvQuLIJ2GPkThttURsfKC(2vBWuLCOyAYnBq36nBoPpez28LTnA5BLOr6c(unBo8WNotiJnNU1SftHnN0hImBpgfkyJg8SnOpkBufNUDvPZ3k(DuL0iHJUqFiXil0tO4cNWlHf28ZMgjC010Y3krJ0f8x4eEjSWMF22JVdVeUMw(wjAKUGp8Xf(aMsRnyyZpBhaivaqpl0hsmYc9ekUEml6HWgLy7AvRBSPAovjCcVewQuPkfhTbtvApMMCxLki58TR2GPk5qX0KB2GU1B22OLVvIgPl4ZMVSTbGnN0hImvZMdp8PZeYyZPBnBXuyZHWPGQgSj4wLoFR43rvsJeo6AA5BLOr6c(lCcVewyZpBuMnns4Ol0hsmYc9ekUWj8syHn)SThFhEjCnT8Ts0iDbF4Jl8bmLwBWWMF2kONan9AhNcQASeCRADdrwZPkHt4LWsLkvP4OnyQsUaqc(rcq4pyvc9r)aoYacJwLe5MRs0GhEqF06gxRADJnxZPkHt4LWsLkvPZ3k(DuL0iHJUicEk(0cY4cNWlHf28Z2basfa0Zso(hO4sWLn)SbfBfGUKJ)bkUEK(rYD4Lq2YNNTc6jqtV2XPGQglbx28ZwbOl54FGIl3mHK2UPgF2OKy2UYgKS5NTdiZda7c6rjRcs3NwzZzXSbfBexmLG14LrLSOJbgqdFz6DKWMZB1WMizds28Z2hDbg3XrxrPqw9WMZSDv0QuC0gmvP9yAYDvRBqvR5uLWj8syPsLQuC0gmvP9yAYDvQGKZ3UAdMQKdfttUzd6wVzZHhefF2Yvcji9q1S5GcUQWJ(svI)bkY2au26HThPFKCZ2hJm6iBfHVhz2CiCkOQHVs39(InjkMdBq36nBsOlPjSr3tKy7Uv2AA2Cbes7LWvv68TIFhvjOytJeo6klik(WbHeesplCcVewylFE2EHbPbVmUYI)cmGgwVr4SGO4dhesqi9SWj8syHnizZpBuMTcqxVGRk846r6hj3HxczZpBfGUKJ)bkUEml6HWMZSTj28Zwb9eOPx74uqvJLGlB(zdk2kONan9IC37lbx2YNNTc6jqtV2XPGQgRhZIEiSrj2ejB5ZZwbOlc6sAYs7ZLEKzds28ZwbOlc6sAY6XSOhcBuITnv1QwLkiDiK0Ao1nUwZPkfhTbtv6sFUuLWj8syPsLQw3q0AovjCcVewQuPkvqY5BxTbtvYbrIIrsVzRPzZfqiTxczdQbW2UqAWp8siB4GznsyRh2oGmVqHSkfhTbtvIOyK07Qw3yt1CQs4eEjSuPsvc4wLiOwLIJ2GPkThFhEjSkThjbSkrCXucwJxgvYIogyan8LP3rcBuInrRs7XdprgwLi9iNqynEzuRADdrwZPkHt4LWsLkvjGBvIGAvkoAdMQ0E8D4LWQ0EKeWQeo4ltX6rzCGpGmVEWcBoZ2M2CvQGKZ3UAdMQKtbzE9Gf2CYbFzkyZbrzCyBqSGf2uaBKqf(qXQ0E8WtKHvPhLXbMeQWhkwQADJnxZPkHt4LWsLkvPZ3k(DuLikgj9glRhilGvjI(9rRBCTkfhTbtv6ePeCC0gmWPMOvPutu4jYWQerXiP3yPQ1nOQ1CQs4eEjSuPsv68TIFhvjOyJYSPrchDLfefF4GqccPNfoHxclSLppBfGUKJ)bkU0(CPhz2GSkr0VpADJRvP4OnyQsNiLGJJ2Gbo1eTkLAIcprgwLofsvRB4auZPkHt4LWsLkvP4OnyQsKuFq4ykWL(GvPcsoF7QnyQsBTGYM0SDSj4YwpT2rkrbB0GNnNkOSPa20BKnNEhe0r2EK(rYnBq36nBo5SJdiJTMMTqzlbGMTIWhAdMQ05Bf)oQsuMnpbA6fj1heoMcCPp4sWLn)SDazEayxqpkHnNfZ21Qw3WbSMtvcNWlHLkvQsNVv87Ok5jqtViP(GWXuGl9bxcUS5NnpbA6fj1heoMcCPp46XSOhcBuITnZMF2oGmpaSlOhLWMZIztKvP4OnyQs4SJdiRQ1nCG1CQs4eEjSuPsvkoAdMQ0jsj44OnyGtnrRsPMOWtKHvPcqRADJRIOMtvcNWlHLkvQsXrBWuLorkbhhTbdCQjAvk1efEImSkv6hpAvRBC9AnNQeoHxclvQuLoFR43rvch8LPyvq6(0kBolMTRBMnFzdh8LPy9OmoWhqMxpyPkfhTbtvk(tmiSc(hhTQ1nUkAnNQuC0gmvP4pXGWUcjcwLWj8syPsLQw346MQ5uLIJ2GPkLA5BLa7WSqrodhTkHt4LWsLkvTUXvrwZPkfhTbtvYlKHb0W63NlKQeoHxclvQu1QwLCF8aY8cTMtDJR1CQsXrBWuLcx3efWUGMaMQeoHxclvQu16gIwZPkfhTbtvYdOAclW0PGcSaDpYWkWNEQs4eEjSuPsvRBSPAovjCcVewQuPkfhTbtvkl(lybMg8Wfm07Q05Bf)oQsF0fyChhDfLcz1dBoZ21nxLCF8aY8cfMGhWuivPnx16gISMtvcNWlHLkvQsNVv87OkracjVEklxbIkKqy8fC1gmlCcVewylFE2iaHKxpL1oifANqyciTJJUWj8syPkfhTbtvIoHK7Zh0AvRBS5AovjCcVewQuPkbCRseuRsXrBWuL2JVdVewL2JKawLUY2wydk2EHbPbVmUkcKlqhPl4tGDd9CVWj8syHTTXMiwICZSbzvApE4jYWQ0oofu1a(u(Qw3GQwZPkHt4LWsLkvjGBvIGAvkoAdMQ0E8D4LWQ0EKeWQ0v22cBqX2lmin4LXfWdlnohCHt4LWcBBJnrSePizdYQubjNVD1gmvPCUr2ID8dzKnNUDoiBnHnrSevu28eu2kciBkGn9gzZb3GQW2eQWJSbOzZPBnBY44iBI6dB6DtyBpsciBnHnGR2zrInAWZgHI50JmBjGCFQs7XdprgwLOtHmMsH2Gb(u(Qw3WbOMtvcNWlHLkvQsa3Qeb1QuC0gmvP947WlHvP94HNidRs63ZfuHjumhyscOvPZ3k(DuL0VNlOU0RR7GalqqypbAA28ZguSrz20VNlOUurx3bbwGGWEc00SLppB63Zfux611basfa0ZQi8H2GHnNfZM(9Cb1Lk66aaPca6zve(qBWWgKSLppB63Zfux61vtw9qoVGgEje2HvigvidUG79bRsfKC(2vBWuL2ouXpRhKnOV7ZnBq10SfdfqYgrdLnpbAA20VNlOYg0iBqhJYMcylufZCv2uaBekMdBq36nBoeofu1yvL2JKawLUw16goG1CQs4eEjSuPsvc4wLiOwLIJ2GPkThFhEjSkThjbSkjAv68TIFhvj975cQlv01DqGfiiSNannB(zdk2OmB63Zfux611DqGfiiSNannB5ZZM(9Cb1Lk66aaPca6zve(qBWWMZSPFpxqDPxxhaivaqpRIWhAdg2GKT85zt)EUG6sfD1KvpKZlOHxcHDyfIrfYGl4EFWQ0E8WtKHvj975cQWekMdmjb0Qw3WbwZPkHt4LWsLkvP4OnyQsKuFq4ykWL(GvPZ3k(DuLEK(rYD4LWQK7JhqMxOWe8aMcPkDTQ1nUkIAovP4OnyQsefJKExLWj8syPsLQw1QuPF8O1CQBCTMtvcNWlHLkvQsXrBWuLWzhhqwvQGKZ3UAdMQKto74aYylu2ePVSb1M9LnOB9MTTtcs2C6wVyB7LLHLoumrbBGHnr9LnnEzujoYg0TEZMdHtbvnCKnWZg0TEZwouXr2a6n(q3eKnOJwzJg8SraziB4GVmfl2Y1ebWg0rRS10S5K(qKz7aY8aS1e2oGSEKztWDvLoFR43rvcPPXJ27i8bK5bGDb9Oe2CwmBIKnFztJeo6QGOl(We9dnKXSfoHxclS5NnOyRGEc00RDCkOQXsWLT85zRGEc00lYDVVeCzlFE2kONan9IofYykfAdMLGlB5ZZgo4ltXQG09Pv2OKy2eDZS5lB4GVmfRhLXb(aY86blSLppBuMT947WlHlspYjewJxgv2GKn)SbfBuMnns4Ol0hsmYc9ekUWj8syHT85z7aaPca6zH(qIrwONqX1Jzrpe2CMnrzdYQw3q0AovjCcVewQuPkbCRseuRsXrBWuL2JVdVewL2JKawLoGmpaSlOhLSkiDFALnNz7kB5ZZgo4ltXQG09Pv2OKy2eDZS5lB4GVmfRhLXb(aY86blSLppBuMT947WlHlspYjewJxg1Q0E8WtKHvjbcct3Pe(vTUXMQ5uLWj8syPsLQuC0gmvjc(FOyb2dmimXTVGvPcsoF7QnyQs5QRBIc2KOIeBkGTiLytJxgvcBq36nqqzlyRGEc00Sfe2C)g8TsHJS5(in(FpYSPXlJkHTcf9iZgbag8zlOv8ztVr2C)olEkytJxg1Q05Bf)oQs7X3HxcxceeMUtj8zZpBuMTcqxe8)qXcShyqyIBFbHlaDP95spYvTUHiR5uLWj8syPsLQuC0gmvjc(FOyb2dmimXTVGvPZ3k(DuL2JVdVeUeiimDNs4ZMF2OmBfGUi4)HIfypWGWe3(ccxa6s7ZLEKRshkojewJxgvsDJRvTUXMR5uLWj8syPsLQuC0gmvjc(FOyb2dmimXTVGvPcsoF7QnyQsBv34WMdpxzRjSnaLTqz7ULVzRi8H2GXr2eiiBsurInfWw46MOGnNaJcBEuWMt6tK5Mq2kcFpYS5q4uqvdhzdO34dDtq2UGOlB0piJTt462JmBN74Lrsv68TIFhvP947WlHlbcct3Pe(S5NTSGO4dhesqi9a)yw0dHnkXMiwoGS5NnOyJULVv4hZIEiSrjXSTz2YNNTdaKkaONfb)puSa7bgeM42xWvw4d85oEzKW2wy7ChVmsGP)4OnyIeBusmBIyj6MzlFE2iaHKxpLvcJcShfWOprMBcx4eEjSWMF2OmBEc00RegfypkGrFIm3eUeCzZpBf0tGMETJtbvnwcUSLppBEc00RS4Fa0ybwgZikyqyCUJ5Gz4Olbx2GSQ1nOQ1CQs4eEjSuPsvkoAdMQeDmWaA4ltVJKQubjNVD1gmvPTsmSbOzZHX07iHTqz7Qd0x2iACUqydqZMdtDPGdBujffKWg4zlKJEikBI0x204LrLSQsNVv87OkThFhEjCjqqy6oLWNn)SbfBEc00R7UuWb2lffKSiACUWMZIz7QdKT85zdk2OmBUFd(wPa(bAOnyyZpBexmLG14LrLSOJbgqdFz6DKWMZIztKS5lBefJKEJL1dKfq2GKniRADdhGAovjCcVewQuPkfhTbtvIogyan8LP3rsv6qXjHWA8YOsQBCTkD(wXVJQeuSrz2C)g8Tsb8d0qBWWw(8Sva6so(hO4s7ZLEKzlFE2kaD9cUQWJlTpx6rMnizZpB7X3HxcxceeMUtj8zZpBexmLG14LrLSOJbgqdFz6DKWMZIzBtvPcsoF7QnyQsBLyydqZMdJP3rcBkGTW1nrbBUGMagcBnnB9ehT3r2adBXqbBA8YOYguGNTyOGnVeILEKztJxgvcBq36nBUFd(wPGThOH2Gbs2cLTnLtvRB4awZPkHt4LWsLkvPZ3k(DuL2JVdVeUeiimDNs4ZMF2oaqQaGEw74uqvJ1Jzrpe2CMTRIOkfhTbtvcp3GEKHF097SykvTUHdSMtvcNWlHLkvQsNVv87OkThFhEjCjqqy6oLWNn)SbfBzbrXhoiKGq6b(XSOhcBIzteS5NnkZ2lmin4LXvbaY8srbx4eEjSWw(8S5jqtV8s9uiDbxcUSbzvkoAdMQuK5jqURADJRIOMtvcNWlHLkvQsXrBWuLYe0ofkwLouCsiSgVmQK6gxRsNVv87OkThFhEjCjqqy6oLWNn)SrCXucwJxgvYIogyan8LP3rcBIzt0QubjNVD1gmvPCcVT4Wf0ofkYMcylCDtuW22HrjrbBBnOjGHTqztu204LrLu16gxVwZPkHt4LWsLkvPZ3k(DuL2JVdVeUeiimDNs4xLIJ2GPkLjODkuSQvTkDkKAo1nUwZPkHt4LWsLkvP4OnyQszXFblW0GhUGHExLs9GWNsv66AZvPdfNecRXlJkPUX1Q05Bf)oQsF0fyChhDfLczj4YMF2GInnEzuxANHWkaU0iBuITdiZda7c6rjRcs3NwzBBSDDTz2YNNTdiZda7c6rjRcs3NwzZzXSDCHZcFGjU4uydYQubjNVD1gmvPThnBrPqylEKnbxhzJmTlYMEJSbgKnOB9MTeaAKOSLtoB3ITTAjiBqFJdBfk6rMn6GO4ZMEhdBoDRzRG09Pv2apBq36nqqzlgkyZPB9QQ1neTMtvcNWlHLkvQsXrBWuLYI)cwGPbpCbd9UkvqY5BxTbtvA7rZ2aylkfcBq3PeBLgzd6wV7Hn9gzBqFu22KiioYMabzZHtVDSbg28aecBq36nqqzlgkyZPB9QkD(wXVJQ0hDbg3XrxrPqw9WMZSTjrW2wy7JUaJ74OROuiRIWhAdg28Z2bK5bGDb9OKvbP7tRS5Sy2oUWzHpWexCkvTUXMQ5uLWj8syPsLQuC0gmvj6esUpFqRvPcsoF7QnyQsBLesUpFqRSrdE22AbIkKq2CYxWvBWWwtZ2au2ikgj9glSbE26HTGTdaKkaOh2ouCsyv68TIFhvjOyJaesE9uwUceviHW4l4Qnyw4eEjSWw(8SracjVEkRDqk0oHWeqAhhDHt4LWcBqYMF2OmBefJKEJLvKsS5NnkZwb9eOPx74uqvJLGlB(zllik(WbHeespWpMf9qytmBIGn)SbfB4GVmflTZqyfaNf(aFazE9Gf2CMnrzlFE2OmBf0tGMErU79LGlBqw16gISMtvcNWlHLkvQsXrBWuLOtHmMsH2GPkvqY5BxTbtvsII5W2wjfYykfAdg2GU1B2CiCkOQbBbHTeyKzliSbnYg0GbckBjabzly7eeLnWo(SP3iB0T8TYwr4dTbdBqbE2AA2CiCkOQbBq3PeBhqgYMxCUWwih9aXMWMcKLtyHnannKRQ05Bf)oQsuMnIIrsVXY6bYciB(zdk2GITdaKkaON1oofu1y9yw0dHnNzZbkc2YNNTdaKkaON1oofu1y9yw0dHnkX2Myds28ZgstJhT3r4diZda7c6rjS5Sy2ejB(ztJxg1L2ziScGlnYMZSDveSLppBf0tGMETJtbvnwcUSLppBEacHn)Sr3Y3k8Jzrpe2OeBIks2GSQ1n2CnNQeoHxclvQuLoFR43rvIYSrums6nwwpqwazZpBinnE0EhHpGmpaSlOhLWMZIztKS5NnOyJobapBqXguSr3Y3k8Jzrpe22cBIks2GKniYguSfhTbd8basfa0dBBJT947WlHl6uiJPuOnyGpLNnizds2CMn6ea8SbfBqXgDlFRWpMf9qyBlSjQizBlSDaGuba9S2XPGQgRhZIEiSTn22JVdVeU2XPGQgWNYZgKSbr2GIT4OnyGpaqQaGEyBBSThFhEjCrNczmLcTbd8P8SbjBqYgKvP4OnyQs0PqgtPqBWu16gu1AovjCcVewQuPkfhTbtvIGUKMuLki58TR2GPkjrXCytcDjnHnOB9MnhcNcQAWwqylbgz2ccBqJSbnyGGYwcqq2c2obrzdSJpB6nYgDlFRSve(qBW4iBEckBUpsJpBA8YOsytVdLnO7uITuVJSfkBjmikBxfbPkD(wXVJQeLzJOyK0BSSEGSaYMF2GITdaKkaON1oofu1y9yw0dHnkX2v28ZMgVmQlTZqyfaxAKnNz7QiylFE2kONan9AhNcQASeCzlFE2OB5Bf(XSOhcBuITRIGniRADdhGAovjCcVewQuPkD(wXVJQeLzJOyK0BSSEGSaYMF2GIn6ea8SbfBqXgDlFRWpMf9qyBlSDveSbjBqKT4OnyGpaqQaGEyds2CMn6ea8SbfBqXgDlFRWpMf9qyBlSDveSTf2oaqQaGEw74uqvJ1Jzrpe22gB7X3Hxcx74uqvd4t5zds2GiBXrBWaFaGuba9WgKSbzvkoAdMQebDjnPQ1nCaR5uLWj8syPsLQeWTkrqTkfhTbtvAp(o8syvApscyvIYSPrchDnT8Ts0iDb)foHxclSLppBuMnns4Ol0hsmYc9ekUWj8syHT85z7aaPca6zH(qIrwONqX1Jzrpe2OeBBMTTWMOSTn20iHJUki6Ipmr)qdzmBHt4LWsvQGKZ3UAdMQKefZHnhcNcQAWg09uaqZg0TEZ2gT8Ts0iDbFFDsFiXil0tOiBnnBHRBQpHxcRs7XdprgwL2XPGQgWtlFRensxWh(aMsRnyQADdhynNQeoHxclvQuLaUvjcQvP4OnyQs7X3HxcRs7XdprgwL2XPGQgWhWooXOWhWuATbtv68TIFhvPdyhNy01fk(og2YNNTdyhNy01GNhKaFHT85z7a2XjgDnGbRsfKC(2vBWuLKOyoS5q4uqvd2GU1B22kPqgtPqBWWwmf2KqxstyliSLaJmBbHnOr2GgmqqzlbiiBbBNGOSb2XNn9gzJULVv2kcFOnyQs7rsaRsxRADJRIOMtvcNWlHLkvQsa3Qeb1QuC0gmvP947WlHvP9ijGvj6ea8SbfBqXgDlFRWpMf9qyBlSjQiyds2GiBqX2vrfbBBJT947WlHRDCkOQb8P8SbjBqYMZSrNaGNnOydk2OB5Bf(XSOhcBBHnrfbBBHTdaKkaONfDkKXuk0gmRhZIEiSbjBqKnOy7QOIGTTX2E8D4LW1oofu1a(uE2GKnizlFE28eOPx0PqgtPqBWa7jqtVeCzlFE2kONan9IofYykfAdMLGlB5ZZgDlFRWpMf9qyJsSjQiQsNVv87OkDa74eJU2XrVP4Rs7XdprgwL2XPGQgWhWooXOWhWuATbtvRBC9AnNQeoHxclvQuLaUvjcQvP4OnyQs7X3HxcRs7rsaRs0ja4zdk2GIn6w(wHFml6HW2wyturWgKSbr2GITRIkc22gB7X3Hxcx74uqvd4t5zds2GKnNzJobapBqXguSr3Y3k8Jzrpe22cBIkc22cBhaivaqplc6sAY6XSOhcBqYgezdk2UkQiyBBSThFhEjCTJtbvnGpLNnizds2YNNTcqxe0L0KL2Nl9iZw(8Sr3Y3k8Jzrpe2OeBIkIQ05Bf)oQshWooXORPLVvy6aRs7XdprgwL2XPGQgWhWooXOWhWuATbtvRBCv0AovjCcVewQuPkD(wXVJQeLzJOyK0BSSEGSaYMF2kaD9cUQWJlTpx6rMn)Srz2kONan9AhNcQASeCzZpB7X3Hxcx74uqvd4PLVvIgPl4dFatP1gmS5NT947WlHRDCkOQb8bSJtmk8bmLwBWuLIJ2GPkTJtbvnQADJRBQMtvcNWlHLkvQsXrBWuLqFiXil0tOyvQGKZ3UAdMQKt6djgzHEcfzd6BCyBakBefJKEJf2IPWMhqVzZbfCvHhzlMcBuL4FGISfpYMGlB0GNTeyKzdhGG89QkD(wXVJQeLzJOyK0BSSEGSaYMF2GInkZwbOl54FGIRhPFKChEjKn)Sva66fCvHhxpMf9qyZz2ejB(YMizBBSDCHZcFGjU4uylFE2kaD9cUQWJRhZIEiSTn2eXAZS5mBA8YOU0odHvaCPr2GKn)SPXlJ6s7mewbWLgzZz2ezvRBCvK1CQs4eEjSuPsvkoAdMQe5U3RsfKC(2vBWuLKU7D2AA2GgzlEKTWdiOSPa2CYzhhqMJSftHTqvmZvztbSrOyoSbDR3SjHUKMWgDprIT7wzRPzdAKnObdeu2GoikYwg4r207yy7os0SP3iBhaivaqpRQ05Bf)oQsfGUEbxv4XL2Nl9iZMF2GInkZ2basfa0ZIGUKMSEmkuWw(8SDaGuba9S2XPGQgRhZIEiS5mBxfLnizlFE2kaDrqxstwAFU0JCvRBCDZ1CQs4eEjSuPsv68TIFhvjpbA6LxcakjbIUEmokB5ZZMhGqyZpB0T8Tc)yw0dHnkX2MebB5ZZwb9eOPx74uqvJLGBvkoAdMQKlqBWu16gxPQ1CQs4eEjSuPsv68TIFhvPc6jqtV2XPGQglb3QuC0gmvjVeauGPfEkQADJRoa1CQs4eEjSuPsv68TIFhvPc6jqtV2XPGQglb3QuC0gmvjp8j4FPh5Qw34QdynNQeoHxclvQuLoFR43rvQGEc00RDCkOQXsWTkfhTbtvIUF0lbaLQw34QdSMtvcNWlHLkvQsNVv87OkvqpbA61oofu1yj4wLIJ2GPkfZbj6hj4tKsvTUHOIOMtvcNWlHLkvQsNVv87Okrz2ikgj9glRiLyZpBzbrXhoiKGq6b(XSOhcBIztevP4OnyQsNiLGJJ2Gbo1eTkLAIcprgwL2JPj3vTUHOxR5uLWj8syPsLQuC0gmvj975cQxRsfKC(2vBWuLKOyoSP3iBUFd(wPGnIgkBEc00SPFpxqLnOB9MnhcNcQA4iBa9gFOBcYMabzdmSDaGuba9uLoFR43rvAp(o8s4s)EUGkmHI5atsaLnXSDLn)SbfBf0tGMETJtbvnwcUSLppBEacHn)Sr3Y3k8Jzrpe2OKy2eveSbjB5ZZguSThFhEjCPFpxqfMqXCGjjGYMy2eLn)Srz20VNlOUurxhaivaqpRhJcfSbjB5ZZgLzBp(o8s4s)EUGkmHI5atsaTQ1nev0AovjCcVewQuPkD(wXVJQ0E8D4LWL(9CbvycfZbMKakBIztu28ZguSvqpbA61oofu1yj4Yw(8S5bie28ZgDlFRWpMf9qyJsIzturWgKSLppBqX2E8D4LWL(9CbvycfZbMKakBIz7kB(zJYSPFpxqDPxxhaivaqpRhJcfSbjB5ZZgLzBp(o8s4s)EUGkmHI5atsaTkfhTbtvs)EUGQOvTQvPcqR5u34AnNQeoHxclvQuLaUvjcQvP4OnyQs7X3HxcRs7rsaRsUFd(wPa(bAOnyyZpBqXwbOl54FGIRhZIEiSrj2oaqQaGEwYX)afxfHp0gmSLppB7X3HxcxpkJdmjuHpuSWgKvPcsoF7QnyQsorN1kBe8aMs8uWgvj(hOiHnAWZM73GVvky7bAOnyyRPzdAKT7yhzBtBMnCWxMc2Eugh2apBuL4FGISbDNsSH(42pYgyytVr2C)olEkytJxg1Q0E8WtKHvjYL2f(qXjHWYX)afRADdrR5uLWj8syPsLQeWTkrqTkfhTbtvAp(o8syvApscyvY9BW3kfWpqdTbdB(zdk2kONan9IC37lbx28ZgXftjynEzujl6yGb0WxMEhjS5mBIYw(8SThFhEjC9OmoWKqf(qXcBqwLki58TR2GPk5eDwRSrWdykXtbBoOGRk8iHnAWZM73GVvky7bAOnyyRPzdAKT7yhzBtBMnCWxMc2Eugh2apBs39oBnHnbx2adBIMJVvP94HNidRsKlTl8HItcHFbxv4XQw3yt1CQs4eEjSuPsvc4wLiOwLIJ2GPkThFhEjSkThjbSkvqpbA61oofu1yj4YMF2GITc6jqtVi39(sWLT85zllik(WbHeespWpMf9qyZz2ebBqYMF2kaD9cUQWJRhZIEiS5mBIwLki58TR2GPk5eDwRS5GcUQWJe2AA2CiCkOQHVs39oeD4brXNTCLqccPh2AcBcUSftHnOr2UJDKnr9LncEatHWwcPv2adB6nYMdk4QcpY22bYPkThp8ezyvICPDHFbxv4XQw3qK1CQs4eEjSuPsvkoAdMQKC8pqXQubjNVD1gmvjjx80rInQs8pqr2IPWMdk4QcpYgbvbx2C)g8SPa2CsFiXil0tOiBNGOvPZ3k(DuL0iHJUqFiXil0tO4cNWlHf28ZgLzRGEc00l54FGIl0hsmYc9ekwyZpBfGUKJ)bkUCZesA7MA8zJsIz7kB(z7aaPca6zH(qIrwONqX1Jzrpe2OeBIYMF2iUykbRXlJkzrhdmGg(Y07iHnXSDLn)S9rxGXDC0vukKvpS5mBuv28ZwbOl54FGIRhZIEiSTn2eXAZSrj204LrDPDgcRa4sJvTUXMR5uLWj8syPsLQ05Bf)oQsAKWrxOpKyKf6juCHt4LWcB(zdk2qAA8O9ocFazEayxqpkHnNfZ2Xfol8bM4ItHn)SDaGuba9SqFiXil0tO46XSOhcBuITRS5NTcqxVGRk846XSOhcBBJnrS2mBuInnEzuxANHWkaU0iBqwLIJ2GPk9cUQWJvTUbvTMtvcNWlHLkvQsXrBWuLCbGe8JeGWFWQubjNVD1gmvjQs8pqr2eCVGORJSfjcGn9BKWMcytGGS1kBbHTGnIlE6iXMmo4hk4zJg8SP3iBPGOS50TMnpKg8iBbB090KB8Rs0GhEqF06gxRADdhGAovjCcVewQuPkD(wXVJQ0J0psUdVeYMF2oGmpaSlOhLSkiDFALnNfZ2v28ZguS5MjK02n14ZgLeZ2v2YNNThZIEiSrjXSP95cS2ziB(zJ4IPeSgVmQKfDmWaA4ltVJe2CwmBBInizZpBqXgLzd9HeJSqpHIf2YNNThZIEiSrjXSP95cS2ziBBJnrzZpBexmLG14LrLSOJbgqdFz6DKWMZIzBtSbjB(zdk204LrDPDgcRa4sJSTf2Eml6HWgKS5mBIKn)SLfefF4GqccPh4hZIEiSjMnruLIJ2GPkjh)duSQ1nCaR5uLWj8syPsLQen4Hh0hTUX1QuC0gmvjxaib)ibi8hSQ1nCG1CQs4eEjSuPsvkoAdMQKC8pqXQ05Bf)oQsuMT947WlHlYL2f(qXjHWYX)afzZpBps)i5o8siB(z7aY8aWUGEuYQG09Pv2CwmBxzZpBqXMBMqsB3uJpBusmBxzlFE2Eml6HWgLeZM2NlWANHS5NnIlMsWA8YOsw0XadOHVm9osyZzXSTj2GKn)SbfBuMn0hsmYc9ekwylFE2Eml6HWgLeZM2NlWANHSTn2eLn)SrCXucwJxgvYIogyan8LP3rcBolMTnXgKS5NnOytJxg1L2ziScGlnY2wy7XSOhcBqYMZSDvu28Zwwqu8HdcjiKEGFml6HWMy2erv6qXjHWA8YOsQBCTQ1nUkIAovjCcVewQuPkfhTbtv68DgbmWkM5IeTkDO4KqynEzuj1nUwLoFR43rvI4IPeSgVmQe2CwmBIYMF2qAA8O9ocFazEayxqpkHnNfZMizZpB4GVmfRhLXb(aY86blS5mBIkc28ZguSrz2oaqQaGEw74uqvJ1JrHc2YNNTcqxVGRk84s7ZLEKzds28Z2Jzrpe2OeBIYMVSTj22gBqXgXftjynEzujS5Sy2ejBqwLki58TR2GPk50VZiGHTCWmxKOSbg2YesA7Mq204LrLWwOSjsFzZPBnBqFJdBVWm9iZgqqzRh2eDlBMWwqylbgz2ccBqJSDh7iB4aeKVz7rzCylMcBXJdeu2iOQ9iZMGlB0GNnhcNcQAu16gxVwZPkHt4LWsLkvP4OnyQsVGRk8yvQGKZ3UAdMQKddeDztWLnhuWvfEKTqztK(Ygyylsj204LrLWguqFJdBPEVhz2sGrMnCacY3SftHTbOSrMWLCduiRsNVv87Okrz22JVdVeUixAx4xWvfEKn)SH004r7De(aY8aWUGEucBolMnrYMF2EK(rYD4Lq28ZguS5MjK02n14ZgLeZ2v2YNNThZIEiSrjXSP95cS2ziB(zJ4IPeSgVmQKfDmWaA4ltVJe2CwmBBInizZpBqXgLzd9HeJSqpHIf2YNNThZIEiSrjXSP95cS2ziBBJnrzZpBexmLG14LrLSOJbgqdFz6DKWMZIzBtSbjB(ztJxg1L2ziScGlnY2wy7XSOhcBoZguSjs28LnOy7fgKg8Y4QeK7EKHjhGWuEmTWj8syHTTX2Mzds28LnOy7fgKg8Y4QaazEPOGlCcVewyBBSTz2GKnFzdk22JVdVeUEughysOcFOyHTTXgvLnizdYQw34QO1CQs4eEjSuPsvkoAdMQ0l4QcpwLoFR43rvIYSThFhEjCrU0UWhkoje(fCvHhzZpBuMT947WlHlYL2f(fCvHhzZpBinnE0EhHpGmpaSlOhLWMZIztKS5NThPFKChEjKn)SbfBUzcjTDtn(SrjXSDLT85z7XSOhcBusmBAFUaRDgYMF2iUykbRXlJkzrhdmGg(Y07iHnNfZ2Myds28ZguSrz2qFiXil0tOyHT85z7XSOhcBusmBAFUaRDgY22ytu28ZgXftjynEzujl6yGb0WxMEhjS5Sy22eBqYMF204LrDPDgcRa4sJSTf2Eml6HWMZSbfBIKnFzdk2EHbPbVmUkb5UhzyYbimLhtlCcVewyBBSTz2GKnFzdk2EHbPbVmUkaqMxkk4cNWlHf22gBBMnizZx2GIT947WlHRhLXbMeQWhkwyBBSrvzds2GSkDO4KqynEzuj1nUw16gx3unNQeoHxclvQuLIJ2GPkD(oJagyfZCrIwLki58TR2GPkTvIuYloxylxbojBo97mcyylhmZfjkBq36nB6nYgjYq2sa5(Wwqyl8a7OJS5jOS1Yd47rMn9gzdh8LPGTdykT2GHWwtZg0iBXJdeu2ei9iZMdk4QcpwLoFR43rvI4IPeSgVmQe2CwmBIYMF2qAA8O9ocFazEayxqpkHnNfZMizZpBpMf9qyJsSjkB(Y2MyBBSbfBexmLG14LrLWMZIztKSbzvRBCvK1CQs4eEjSuPsvkoAdMQ057mcyGvmZfjAvQGKZ3UAdMQKt)oJag2YbZCrIYgyytkh2AA26Hn3ykywFylMcBdgFIc2YcFydh8LPGTykS10S5KZooGm2GgmqqzRayld8iBLilKr2kciBkGTCOceD45Av68TIFhvjIlMsWA8YOsytmBxzZpBuMTxyqAWlJRsqU7rgMCact5X0cNWlHf28Zwwqu8HdcjiKEGFml6HWMy2ebB(zdPPXJ27i8bK5bGDb9Oe2CwmBqX2Xfol8bM4ItHTTW2v2GKn)S9i9JK7WlHS5NnkZg6djgzHEcflS5NnOyJYSvqpbA6f5U3xcUS5NnOydh8LPyvq6(0kBusmBIUz28LnCWxMI1JY4aFazE9Gf2GKnizZpBA8YOU0odHvaCPr22cBpMf9qyZz2ezvRAvRs74tAWu3quri6vrqvf1bSkbD8tpYKQ0wvU6GBS92GQq1SXwo3iBDMl4v2ObpBqypMMCdb2E0HvOFSWgbKHSfckiluSW25ogzKSyQDIEq2Us1S5uWSJVIf2GWlmin4LXvUab2uaBq4fgKg8Y4kxw4eEjSab2GsuFGCXu7e9GSrvPA2Cky2XxXcBq4fgKg8Y4kxGaBkGni8cdsdEzCLllCcVewGaBqD1hixm1m1Bv5QdUX2BdQcvZgB5CJS1zUGxzJg8Sbb3hpGmVqHaBp6Wk0pwyJaYq2cbfKfkwy7ChJmswm1orpiBIKQzZPGzhFflSbbcqi51tzLlqGnfWgeiaHKxpLvUSWj8sybcSb1vFGCXu7e9GSjsQMnNcMD8vSWgeiaHKxpLvUab2uaBqGaesE9uw5YcNWlHfiWwOS5KB17eSb1vFGCXu7e9GSTzQMnNcMD8vSWgeEHbPbVmUYfiWMcydcVWG0Gxgx5YcNWlHfiWgux9bYftTt0dYgvLQzZPGzhFflSbHxyqAWlJRCbcSPa2GWlmin4LXvUSWj8sybcSb1vFGCXu7e9GS5aq1S5uWSJVIf2GG(9Cb111vUab2uaBqq)EUG6sVUYfiWguBYhixm1orpiBoaunBofm74RyHniOFpxqDj6kxGaBkGniOFpxqDPIUYfiWguI6dKlMANOhKnhqQMnNcMD8vSWge0VNlOUUUYfiWMcydc63Zfux61vUab2GsuFGCXu7e9GS5as1S5uWSJVIf2GG(9Cb1LORCbcSPa2GG(9Cb1Lk6kxGaBqTjFGCXuZuVvLRo4gBVnOkunBSLZnYwN5cELnAWZgek9JhfcS9OdRq)yHncidzleuqwOyHTZDmYizXu7e9GS5aPA2Cky2XxXcBq4fgKg8Y4kxGaBkGni8cdsdEzCLllCcVewGaBqD1hixm1m1Bv5QdUX2BdQcvZgB5CJS1zUGxzJg8SbHtHab2E0HvOFSWgbKHSfckiluSW25ogzKSyQDIEq22evZMtbZo(kwydceGqYRNYkxGaBkGniqacjVEkRCzHt4LWceydkr9bYftTt0dY2MPA2Cky2XxXcBsDMtzJqXOHpST9ztbS5ecbBLEVjnyyd4IFOGNnOGiKSbLO(a5IP2j6bzZbGQzZPGzhFflSj1zoLncfJg(W22NnfWMtieSv69M0GHnGl(HcE2GcIqYguI6dKlMANOhKTRIGQzZPGzhFflSj1zoLncfJg(W22NnfWMtieSv69M0GHnGl(HcE2GcIqYguI6dKlMANOhKTRxPA2Cky2XxXcBsDMtzJqXOHpST9ztbS5ecbBLEVjnyyd4IFOGNnOGiKSbLO(a5IP2j6bzt0RunBofm74RyHniOFpxqDj6kxGaBkGniOFpxqDPIUYfiWgux9bYftTt0dYMOIs1S5uWSJVIf2GG(9Cb111vUab2uaBqq)EUG6sVUYfiWgux9bYftnt9wvU6GBS92GQq1SXwo3iBDMl4v2ObpBqOauiW2JoSc9Jf2iGmKTqqbzHIf2o3XiJKftTt0dYMiPA2Cky2XxXcBqa9HeJSqpHILvUab2uaBqOGEc00RCzH(qIrwONqXceydQR(a5IP2j6bz76vQMnNcMD8vSWgeEHbPbVmUYfiWMcydcVWG0Gxgx5YcNWlHfiWguI6dKlMANOhKTRIs1S5uWSJVIf2GWlmin4LXvUab2uaBq4fgKg8Y4kxw4eEjSab2GsuFGCXu7e9GSDvKunBofm74RyHni8cdsdEzCLlqGnfWgeEHbPbVmUYLfoHxclqGnOU6dKlMAM6CUr2GGabHBfZiqGT4Onyyd6GW2au2ObctHTEytVBcBDMl41ft92lZf8kwyZbGT4Onyyl1eLSyQRsex8u3q0n7aRsUpGUtyvk35MTCLqccPNqBWWMdcKfqM6CNB2Owyq2e1b6iBIkcrVYuZuN7CZMtVJrgjuntDUZnBBHTC11nrbBqGOFFuiWgDkKztbSraziB56w7eSrd(le2uaBKyhzZ9bhKq6rMnTZWftDUZnBBHTTdmqqzZHIPj3SjmjKqytk1hKTykSTD9bzd6oLylfeLTeyKXNn9og2C4brXNTCLqccPNftDUZnBBHnhetHpSTvsHmMsH2GHniYMdHtbvnyJqXCydQMMnhcNcQAWwtytbYYjSWgGMMnWZgyylylbgz2C62b5IPMPo35MnN0h8iOyHnpKg8iBhqMxOS5HY9qwSLRNd6Qe2gWSL74ZOfsSfhTbdHnWKOyXuhhTbdz5(4bK5fQ4W1nrbSlOjGHPooAdgYY9XdiZluFfdrpGQjSatNckWc09idRaF6HPooAdgYY9XdiZluFfdXS4VGfyAWdxWqVD09XdiZluycEatHiEZo20I)OlW4oo6kkfYQhNVUzM64Onyil3hpGmVq9vmePti5(8bT6ytlMaesE9uwUceviHW4l4QnyYNNaesE9uw7GuODcHjG0ooktDC0gmKL7JhqMxO(kgI7X3HxcDCImu8oofu1a(uEh3JKak(6wG6fgKg8Y4QiqUaDKUGpb2n0Z92eXsKBgsM6CZwo3iBXo(HmYMt3ohKTMWMiwIkkBEckBfbKnfWMEJS5GBqvyBcv4r2a0S50TMnzCCKnr9Hn9UjSThjbKTMWgWv7SiXgn4zJqXC6rMTeqUpm1XrBWqwUpEazEH6RyiUhFhEj0XjYqX0PqgtPqBWaFkVJ7rsafFDlq9cdsdEzCb8WsJZb3MiwIuKqYuNB22ouXpRhKnOV7ZnBq10SfdfqYgrdLnpbAA20VNlOYg0iBqhJYMcylufZCv2uaBekMdBq36nBoeofu1yXuhhTbdz5(4bK5fQVIH4E8D4LqhNidfRFpxqfMqXCGjjG64EKeqXxDSPfRFpxqDDDDheybcc7jqt7hkkRFpxqDj66oiWcee2tGMoFE975cQRRRdaKkaONvr4dTbJZI1VNlOUeDDaGuba9SkcFOnyGmFE975cQRRRMS6HCEbn8siSdRqmQqgCb37dYuhhTbdz5(4bK5fQVIH4E8D4LqhNidfRFpxqfMqXCGjjG64EKeqXI6ytlw)EUG6s01DqGfiiSNanTFOOS(9Cb1111DqGfiiSNanD(863ZfuxIUoaqQaGEwfHp0gmoRFpxqDDDDaGuba9SkcFOnyGmFE975cQlrxnz1d58cA4LqyhwHyuHm4cU3hKPooAdgYY9XdiZluFfdrsQpiCmf4sFqhDF8aY8cfMGhWuiIV6ytl(r6hj3HxczQJJ2GHSCF8aY8c1xXqKOyK0BMAM6CNB2CsFWJGIf2WD8PGnTZq20BKT4OGNTMWwShDk8s4IPooAdgI4l95ctDUzZbrIIrsVzRPzZfqiTxczdQbW2UqAWp8siB4GznsyRh2oGmVqHKPooAdgIVIHirXiP3m1XrBWq8vme3JVdVe64ezOyspYjewJxgvh3JKakM4IPeSgVmQKfDmWaA4ltVJekjktDUzZPGmVEWcBo5GVmfS5GOmoSniwWcBkGnsOcFOitDC0gmeFfdX947WlHoorgk(rzCGjHk8HIfh3JKakgh8LPy9OmoWhqMxpyX5nTzM64Onyi(kgINiLGJJ2Gbo1e1XjYqXefJKEJfhj63hv8vhBAXefJKEJL1dKfqM64Onyi(kgINiLGJJ2Gbo1e1XjYqXNcXrI(9rfF1XMwmuuwJeo6klik(WbHeesplCcVewYNVa0LC8pqXL2Nl9idjtDUzBRfu2KMTJnbx26P1osjkyJg8S5ubLnfWMEJS507GGoY2J0psUzd6wVzZjNDCazS10SfkBja0Sve(qBWWuhhTbdXxXqKK6dchtbU0h0XMwmL9eOPxKuFq4ykWL(Glbx)hqMha2f0JsCw8vM64Onyi(kgI4SJdiZXMwSNan9IK6dchtbU0hCj463tGMErs9bHJPax6dUEml6HqPn7)aY8aWUGEuIZIfjtDC0gmeFfdXtKsWXrBWaNAI64ezO4cqzQJJ2GH4RyiEIucooAdg4utuhNidfx6hpktDC0gmeFfdX4pXGWk4FCuhBAX4GVmfRcs3NwDw81n7lo4ltX6rzCGpGmVEWctDC0gmeFfdX4pXGWUcjcYuhhTbdXxXqm1Y3kb2HzHICgoktDC0gmeFfdrVqggqdRFFUqyQzQZDUzZPaqQaGEim15MTThnBrPqylEKnbxhzJmTlYMEJSbgKnOB9MTeaAKOSLtoB3ITTAjiBqFJdBfk6rMn6GO4ZMEhdBoDRzRG09Pv2apBq36nqqzlgkyZPB9IPooAdgY6ui(kgIzXFblW0GhUGHE7yQhe(ueFDTzhpuCsiSgVmQeXxDSPf)rxGXDC0vukKLGRFO04LrDPDgcRa4sJu6aY8aWUGEuYQG09P1TDDT585pGmpaSlOhLSkiDFA1zXhx4SWhyIlofizQZnBBpA2gaBrPqyd6oLyR0iBq36DpSP3iBd6JY2MebXr2eiiBoC6TJnWWMhGqyd6wVbckBXqbBoDRxm1XrBWqwNcXxXqml(lybMg8Wfm0BhBAXF0fyChhDfLcz1JZBseB5JUaJ74OROuiRIWhAdg)hqMha2f0JswfKUpT6S4JlCw4dmXfNctDUzBRKqY95dALnAWZ2wlquHeYMt(cUAdg2AA2gGYgrXiP3yHnWZwpSfSDaGuba9W2HItczQJJ2GHSofIVIHiDcj3NpOvhBAXqracjVEklxbIkKqy8fC1gm5ZtacjVEkRDqk0oHWeqAhhfs)uMOyK0BSSIuYpLlONan9AhNcQASeC9NfefF4GqccPh4hZIEiIfHFOWbFzkwANHWkaol8b(aY86blolA(8uUGEc00lYDVVeCHKPo3SjrXCyBRKczmLcTbdBq36nBoeofu1GTGWwcmYSfe2GgzdAWabLTeGGSfSDcIYgyhF20BKn6w(wzRi8H2GHnOapBnnBoeofu1GnO7uITdidzZloxylKJEGytytbYYjSWgGMgYftDC0gmK1Pq8vmePtHmMsH2GXXMwmLjkgj9glRhilG(HcQdaKkaON1oofu1y9yw0dXzhOiYN)aaPca6zTJtbvnwpMf9qO0MG0pstJhT3r4diZda7c6rjolwK(14LrDPDgcRa4sJoFve5ZxqpbA61oofu1yj4MpVhGq8t3Y3k8JzrpekjQiHKPooAdgY6ui(kgI0PqgtPqBW4ytlMYefJKEJL1dKfq)innE0EhHpGmpaSlOhL4Syr6hk6ea8qbfDlFRWpMf9q2IOIeYTpuhaivaqpBBp(o8s4IofYykfAdg4t5HesNPtaWdfu0T8Tc)yw0dzlIkYTCaGuba9S2XPGQgRhZIEiBBp(o8s4AhNcQAaFkpKBFOoaqQaGE22E8D4LWfDkKXuk0gmWNYdjKqYuNB2KOyoSjHUKMWg0TEZMdHtbvnyliSLaJmBbHnOr2GgmqqzlbiiBbBNGOSb2XNn9gzJULVv2kcFOnyCKnpbLn3hPXNnnEzujSP3HYg0DkXwQ3r2cLTegeLTRIGWuhhTbdzDkeFfdrc6sAIJnTyktums6nwwpqwa9d1basfa0ZAhNcQASEml6HqPR(14LrDPDgcRa4sJoFve5ZxqpbA61oofu1yj4MppDlFRWpMf9qO0vrajtDC0gmK1Pq8vmejOlPjo20IPmrXiP3yz9azb0pu0ja4Hck6w(wHFml6HSLRIaYT)basfa0dKotNaGhkOOB5Bf(XSOhYwUkITCaGuba9S2XPGQgRhZIEiBBp(o8s4AhNcQAaFkpKB)daKkaOhiHKPo3SjrXCyZHWPGQgSbDpfa0SbDR3STrlFRensxW3xN0hsmYc9ekYwtZw46M6t4LqM64OnyiRtH4RyiUhFhEj0XjYqX74uqvd4PLVvIgPl4dFatP1gmoUhjbumL1iHJUMw(wjAKUG)cNWlHL85PSgjC0f6djgzHEcfx4eEjSKp)basfa0Zc9HeJSqpHIRhZIEiuAZBr0TPrchDvq0fFyI(HgYy2cNWlHfM6CZMefZHnhcNcQAWg0TEZ2wjfYykfAdg2IPWMe6sAcBbHTeyKzliSbnYg0GbckBjabzly7eeLnWo(SP3iB0T8TYwr4dTbdtDC0gmK1Pq8vme3JVdVe64ezO4DCkOQb8bSJtmk8bmLwBW4ytl(a2XjgDDHIVJjF(dyhNy01GNhKaFjF(dyhNy01ag0X9ijGIVYuhhTbdzDkeFfdX947WlHoorgkEhNcQAaFa74eJcFatP1gmo20IpGDCIrx74O3u8oUhjbumDcaEOGIULVv4hZIEiBrura52hQRIkITThFhEjCTJtbvnGpLhsiDMobapuqr3Y3k8JzrpKTiQi2Ybasfa0ZIofYykfAdM1Jzrpei3(qDvurST947WlHRDCkOQb8P8qcz(8Ec00l6uiJPuOnyG9eOPxcU5ZxqpbA6fDkKXuk0gmlb385PB5Bf(XSOhcLevem1XrBWqwNcXxXqCp(o8sOJtKHI3XPGQgWhWooXOWhWuATbJJnT4dyhNy010Y3kmDGoUhjbumDcaEOGIULVv4hZIEiBrura52hQRIkITThFhEjCTJtbvnGpLhsiDMobapuqr3Y3k8JzrpKTiQi2Ybasfa0ZIGUKMSEml6Ha52hQRIkITThFhEjCTJtbvnGpLhsiZNVa0fbDjnzP95spY5Zt3Y3k8JzrpekjQiyQJJ2GHSofIVIH4oofu1WXMwmLjkgj9glRhilG(laD9cUQWJlTpx6r2pLlONan9AhNcQASeC9VhFhEjCTJtbvnGNw(wjAKUGp8bmLwBW4Fp(o8s4AhNcQAaFa74eJcFatP1gmm15MnN0hsmYc9ekYg034W2au2ikgj9glSftHnpGEZMdk4QcpYwmf2OkX)afzlEKnbx2ObpBjWiZgoab57ftDC0gmK1Pq8vmerFiXil0tOOJnTyktums6nwwpqwa9dfLlaDjh)duC9i9JK7WlH(laD9cUQWJRhZIEiolsFf52oUWzHpWexCk5Zxa66fCvHhxpMf9q2MiwB2znEzuxANHWkaU0iK(14LrDPDgcRa4sJolsM6CZM0DVZwtZg0iBXJSfEabLnfWMto74aYCKTykSfQIzUkBkGncfZHnOB9Mnj0L0e2O7jsSD3kBnnBqJSbnyGGYg0brr2YapYMEhdB3rIMn9gz7aaPca6zXuhhTbdzDkeFfdrYDV7ytlUa01l4QcpU0(CPhz)qr5daKkaONfbDjnz9yuOiF(daKkaON1oofu1y9yw0dX5RIcz(8fGUiOlPjlTpx6rMPooAdgY6ui(kgIUaTbJJnTypbA6LxcakjbIUEmoA(8EacXpDlFRWpMf9qO0Mer(8f0tGMETJtbvnwcUm1XrBWqwNcXxXq0lbafyAHNchBAXf0tGMETJtbvnwcUm1XrBWqwNcXxXq0dFc(x6r2XMwCb9eOPx74uqvJLGltDC0gmK1Pq8vmeP7h9saqXXMwCb9eOPx74uqvJLGltDC0gmK1Pq8vmeJ5Ge9Je8jsjhBAXf0tGMETJtbvnwcUm1XrBWqwNcXxXq8ePeCC0gmWPMOoorgkEpMMC7ytlMYefJKEJLvKs(ZcIIpCqibH0d8JzrpeXIGPo3SjrXCytVr2C)g8TsbBenu28eOPzt)EUGkBq36nBoeofu1Wr2a6n(q3eKnbcYgyy7aaPca6HPooAdgY6ui(kgI63ZfuV6ytlEp(o8s4s)EUGkmHI5atsav8v)qvqpbA61oofu1yj4MpVhGq8t3Y3k8Jzrpekjwuraz(8qThFhEjCPFpxqfMqXCGjjGkwu)uw)EUG6s01basfa0Z6XOqbK5Zt5947WlHl975cQWekMdmjbuM64OnyiRtH4RyiQFpxqvuhBAX7X3Hxcx63ZfuHjumhyscOIf1puf0tGMETJtbvnwcU5Z7bie)0T8Tc)yw0dHsIfveqMppu7X3Hxcx63ZfuHjumhyscOIV6NY63ZfuxxxhaivaqpRhJcfqMppL3JVdVeU0VNlOctOyoWKeqzQzQZDUzB76hpkBLilKr2cVo1AJeM6CZMto74aYylu2ePVSb1M9LnOB9MTTtcs2C6wVyB7LLHLoumrbBGHnr9LnnEzujoYg0TEZMdHtbvnCKnWZg0TEZwouzRo2a6n(q3eKnOJwzJg8SraziB4GVmfl2Y1ebWg0rRS10S5K(qKz7aY8aS1e2oGSEKztWDXuhhTbdzv6hpQyC2XbK5ytlgPPXJ27i8bK5bGDb9OeNflsF1iHJUki6Ipmr)qdzmBHt4LWIFOkONan9AhNcQASeCZNVGEc00lYDVVeCZNVGEc00l6uiJPuOnywcU5ZJd(YuSkiDFALsIfDZ(Id(YuSEugh4diZRhSKppL3JVdVeUi9iNqynEzuH0puuwJeo6c9HeJSqpHIlCcVewYN)aaPca6zH(qIrwONqX1JzrpeNffsM64OnyiRs)4r9vme3JVdVe64ezOybcct3Pe(oUhjbu8bK5bGDb9OKvbP7tRoFnFECWxMIvbP7tRusSOB2xCWxMI1JY4aFazE9GL85P8E8D4LWfPh5ecRXlJktDUzlxDDtuWMevKytbSfPeBA8YOsyd6wVbckBbBf0tGMMTGWM73GVvkCKn3hPX)7rMnnEzujSvOOhz2iaWGpBbTIpB6nYM73zXtbBA8YOYuhhTbdzv6hpQVIHib)puSa7bgeM42xqhBAX7X3HxcxceeMUtj89t5cqxe8)qXcShyqyIBFbHlaDP95spYm1XrBWqwL(XJ6RyisW)dflWEGbHjU9f0XdfNecRXlJkr8vhBAX7X3HxcxceeMUtj89t5cqxe8)qXcShyqyIBFbHlaDP95spYm15MTTQBCyZHNRS1e2gGYwOSD3Y3Sve(qBW4iBceKnjQiXMcylCDtuWMtGrHnpkyZj9jYCtiBfHVhz2CiCkOQHJSb0B8HUjiBxq0Ln6hKX2jCD7rMTZD8YiHPooAdgYQ0pEuFfdrc(FOyb2dmimXTVGo20I3JVdVeUeiimDNs47plik(WbHeespWpMf9qOKiwoG(HIULVv4hZIEius8MZN)aaPca6zrW)dflWEGbHjU9fCLf(aFUJxgjB5ChVmsGP)4OnyIeLelILOBoFEcqi51tzLWOa7rbm6tK5MWfoHxcl(PSNan9kHrb2Jcy0NiZnHlbx)f0tGMETJtbvnwcU5Z7jqtVYI)bqJfyzmJOGbHX5oMdMHJUeCHKPo3STvIHnanBomMEhjSfkBxDG(YgrJZfcBaA2CyQlfCyJkPOGe2apBHC0drztK(YMgVmQKftDC0gmKvPF8O(kgI0XadOHVm9osCSPfVhFhEjCjqqy6oLW3puEc00R7UuWb2lffKSiACU4S4RoW85HIYUFd(wPa(bAOny8tCXucwJxgvYIogyan8LP3rIZIfPVefJKEJL1dKfqiHKPo3STvIHnanBomMEhjSPa2cx3efS5cAcyiS10S1tC0EhzdmSfdfSPXlJkBqbE2IHc28siw6rMnnEzujSbDR3S5(n4BLc2EGgAdgizlu22uom1XrBWqwL(XJ6RyishdmGg(Y07iXXdfNecRXlJkr8vhBAXqrz3VbFRua)an0gm5Zxa6so(hO4s7ZLEKZNVa01l4QcpU0(CPhzi9VhFhEjCjqqy6oLW3pXftjynEzujl6yGb0WxMEhjolEtm1XrBWqwL(XJ6RyiINBqpYWp6(DwmfhBAX7X3HxcxceeMUtj89FaGuba9S2XPGQgRhZIEioFvem1XrBWqwL(XJ6RyigzEcKBhBAX7X3HxcxceeMUtj89dvwqu8HdcjiKEGFml6Hiwe(P8lmin4LXvbaY8srbZN3tGME5L6Pq6cUeCHKPo3SLt4TfhUG2Pqr2uaBHRBIc22omkjkyBRbnbmSfkBIYMgVmQeM64OnyiRs)4r9vmeZe0ofk64HItcH14LrLi(QJnT4947WlHlbcct3Pe((jUykbRXlJkzrhdmGg(Y07irSOm1XrBWqwL(XJ6RyiMjODku0XMw8E8D4LWLabHP7ucFMAM6CNB22UilKr2a74ZM2ziBHxNATrctDUzZj6SwzJGhWuINc2OkX)afjSrdE2C)g8TsbBpqdTbdBnnBqJSDh7iBBAZSHd(YuW2JY4Wg4zJQe)duKnO7uIn0h3(r2adB6nYM73zXtbBA8YOYuhhTbdzvaQ4947WlHoorgkMCPDHpuCsiSC8pqrh3JKak29BW3kfWpqdTbJFOkaDjh)duC9yw0dHshaivaqpl54FGIRIWhAdM853JVdVeUEughysOcFOybsM6CZMt0zTYgbpGPepfS5GcUQWJe2ObpBUFd(wPGThOH2GHTMMnOr2UJDKTnTz2WbFzky7rzCyd8SjD37S1e2eCzdmSjAo(YuhhTbdzvaQVIH4E8D4LqhNidftU0UWhkoje(fCvHhDCpscOy3VbFRua)an0gm(HQGEc00lYDVVeC9tCXucwJxgvYIogyan8LP3rIZIMp)E8D4LW1JY4atcv4dflqYuNB2CIoRv2Cqbxv4rcBnnBoeofu1WxP7EhIo8GO4ZwUsibH0dBnHnbx2IPWg0iB3XoYMO(YgbpGPqylH0kBGHn9gzZbfCvHhzB7a5WuhhTbdzvaQVIH4E8D4LqhNidftU0UWVGRk8OJ7rsafxqpbA61oofu1yj46hQc6jqtVi39(sWnF(SGO4dhesqi9a)yw0dXzraP)cqxVGRk846XSOhIZIYuNB2KCXthj2OkX)afzlMcBoOGRk8iBeufCzZ9BWZMcyZj9HeJSqpHISDcIYuhhTbdzvaQVIHOC8pqrhBAXAKWrxOpKyKf6juCHt4LWIFkJ(qIrwONqXYso(hOO)cqxYX)afxUzcjTDtn(us8v)haivaqpl0hsmYc9ekUEml6Hqjr9tCXucwJxgvYIogyan8LP3rI4R()OlW4oo6kkfYQhNPQ(laDjh)duC9yw0dzBIyTzkPXlJ6s7mewbWLgzQJJ2GHSka1xXq8fCvHhDSPfRrchDH(qIrwONqXfoHxcl(HcPPXJ27i8bK5bGDb9OeNfFCHZcFGjU4u8FaGuba9SqFiXil0tO46XSOhcLU6Va01l4QcpUEml6HSnrS2mL04LrDPDgcRa4sJqYuNB2OkX)afztW9cIUoYwKia20VrcBkGnbcYwRSfe2c2iU4PJeBY4GFOGNnAWZMEJSLcIYMt3A28qAWJSfSr3ttUXNPooAdgYQauFfdrxaib)ibi8h0rAWdpOpQ4Rm1XrBWqwfG6Ryikh)du0XMw8J0psUdVe6)aY8aWUGEuYQG09PvNfF1puUzcjTDtn(us8185Fml6HqjXAFUaRDg6N4IPeSgVmQKfDmWaA4ltVJeNfVji9dfLrFiXil0tOyjF(hZIEiusS2NlWANHBtu)exmLG14LrLSOJbgqdFz6DK4S4nbPFO04LrDPDgcRa4sJB5XSOhcKols)zbrXhoiKGq6b(XSOhIyrWuhhTbdzvaQVIHOlaKGFKae(d6in4Hh0hv8vM64OnyiRcq9vmeLJ)bk64HItcH14LrLi(QJnTykVhFhEjCrU0UWhkojewo(hOO)hPFKChEj0)bK5bGDb9OKvbP7tRol(QFOCZesA7MA8PK4R5Z)yw0dHsI1(Cbw7m0pXftjynEzujl6yGb0WxMEhjolEtq6hkkJ(qIrwONqXs(8pMf9qOKyTpxG1od3MO(jUykbRXlJkzrhdmGg(Y07iXzXBcs)qPXlJ6s7mewbWLg3YJzrpeiD(QO(ZcIIpCqibH0d8JzrpeXIGPo3S50VZiGHTCWmxKOSbg2YesA7Mq204LrLWwOSjsFzZPBnBqFJdBVWm9iZgqqzRh2eDlBMWwqylbgz2ccBqJSDh7iB4aeKVz7rzCylMcBXJdeu2iOQ9iZMGlB0GNnhcNcQAWuhhTbdzvaQVIH457mcyGvmZfjQJhkojewJxgvI4Ro20IjUykbRXlJkXzXI6hPPXJ27i8bK5bGDb9OeNfls)4GVmfRhLXb(aY86blolQi8dfLpaqQaGEw74uqvJ1JrHI85laD9cUQWJlTpx6rgs)pMf9qOKO(UPTbfXftjynEzujolwKqYuNB2CyGOlBcUS5GcUQWJSfkBI0x2adBrkXMgVmQe2Gc6BCyl179iZwcmYSHdqq(MTykSnaLnYeUKBGcjtDC0gmKvbO(kgIVGRk8OJnTykVhFhEjCrU0UWVGRk8OFKMgpAVJWhqMha2f0JsCwSi9)i9JK7WlH(HYntiPTBQXNsIVMp)Jzrpekjw7ZfyTZq)exmLG14LrLSOJbgqdFz6DK4S4nbPFOOm6djgzHEcfl5Z)yw0dHsI1(Cbw7mCBI6N4IPeSgVmQKfDmWaA4ltVJeNfVji9RXlJ6s7mewbWLg3YJzrpeNHsK(c1lmin4LXvji39idtoaHP8yABBgsFH6fgKg8Y4QaazEPOGBBZq6lu7X3HxcxpkJdmjuHpuSSnQkKqYuhhTbdzvaQVIH4l4Qcp64HItcH14LrLi(QJnTykVhFhEjCrU0UWhkoje(fCvHh9t5947WlHlYL2f(fCvHh9J004r7De(aY8aWUGEuIZIfP)hPFKChEj0puUzcjTDtn(us8185Fml6HqjXAFUaRDg6N4IPeSgVmQKfDmWaA4ltVJeNfVji9dfLrFiXil0tOyjF(hZIEiusS2NlWANHBtu)exmLG14LrLSOJbgqdFz6DK4S4nbPFnEzuxANHWkaU04wEml6H4muI0xOEHbPbVmUkb5UhzyYbimLhtBBZq6luVWG0GxgxfaiZlffCBBgsFHAp(o8s46rzCGjHk8HILTrvHesM6CZ2wjsjV4CHTCf4KS50VZiGHTCWmxKOSbDR3SP3iBKidzlbK7dBbHTWdSJoYMNGYwlpGVhz20BKnCWxMc2oGP0AdgcBnnBqJSfpoqqztG0JmBoOGRk8itDC0gmKvbO(kgINVZiGbwXmxKOo20IjUykbRXlJkXzXI6hPPXJ27i8bK5bGDb9OeNfls)pMf9qOKO(UPTbfXftjynEzujolwKqYuNB2C63zeWWwoyMlsu2adBs5WwtZwpS5gtbZ6dBXuyBW4tuWww4dB4GVmfSftHTMMnNC2XbKXg0GbckBfaBzGhzRezHmYwraztbSLdvGOdpxzQJJ2GHSka1xXq88DgbmWkM5Ie1XMwmXftjynEzujIV6NYVWG0GxgxLGC3Jmm5aeMYJj)zbrXhoiKGq6b(XSOhIyr4hPPXJ27i8bK5bGDb9OeNfd1Xfol8bM4ItzlxH0)J0psUdVe6NYOpKyKf6juS4hkkxqpbA6f5U3xcU(Hch8LPyvq6(0kLel6M9fh8LPy9OmoWhqMxpybsi9RXlJ6s7mewbWLg3YJzrpeNfjtntDUZnBskgj9glSLRhTbdHPo3STrlFt0iDbF2adBBkhQMnN(DgbmSLdM5IeLPooAdgYIOyK0BSi(8DgbmWkM5Ie1XMwSgjC010Y3krJ0f8x4eEjS4N4IPeSgVmQeNfVj)hqMha2f0JsCwSi9RXlJ6s7mewbWLg3YJzrpeNPQm15MTnA5BIgPl4Zgyy7AounBst4sUbkBoOGRk8itDC0gmKfrXiP3yXxXq8fCvHhDSPfRrchDnT8Ts0iDb)foHxcl(pGmpaSlOhL4Syr6xJxg1L2ziScGlnULhZIEiotvzQZnBscEk(0cYivZwU66MOGnWZMdI0psUzd6wVzZtGMglSrvI)bksyQJJ2GHSikgj9gl(kgIUaqc(rcq4pOJ0GhEqFuXxzQJJ2GHSikgj9gl(kgIYX)afD8qXjHWA8YOseF1XMwSgjC0frWtXNwqgx4eEjS4hQhZIEiu6QO5Z7MjK02n14tjXxH0VgVmQlTZqyfaxAClpMf9qCwuM6CZMKGNIpTGmYMVS5K(qKzdmSDnhQMnhePFKCZgvj(hOiBHYMEJSHtHnanBefJKEZMcytgv2YcFyRi8H2GHnpKg8iBoPpKyKf6juKPooAdgYIOyK0BS4Ryi6caj4hjaH)GosdE4b9rfFLPooAdgYIOyK0BS4Ryikh)du0XMwSgjC0frWtXNwqgx4eEjS4xJeo6c9HeJSqpHIlCcVew8hhT3ryCWSgjIV63tGMEre8u8PfKX1JzrpekDDTjM64OnyilIIrsVXIVIHyMG2PqrhBAXAKWrxebpfFAbzCHt4LWI)diZda7c6rjus8MyQzQZDUzZHIPj3m15MTTspn5MnOB9MTSWh2C6wZgn4zBJw(wjAKUGVJSjmjKqytG0JmBBhg6DIc2KUJcaActDC0gmK1Emn5w8E8D4LqhNidfpT8Ts0iDbF4Jl8bmLwBW44EKeqXqr5xyqAWlJRcg6DIcyYDuaqt8J004r7De(aY8aWUGEuIZIpUWzHpWexCkqMppuVWG0Gxgxfm07efWK7OaGM4)aY8aWUGEucLefsM6CZMdfttUzd6wVzZj9HiZMVSTrlFRensxWNQzZHh(0zczS50TMTykS5K(qKz7XOqbB0GNTb9rzJQ40TJPooAdgYApMMC7RyiUhttUDSPfRrchDH(qIrwONqXfoHxcl(1iHJUMw(wjAKUG)cNWlHf)7X3HxcxtlFRensxWh(4cFatP1gm(paqQaGEwOpKyKf6juC9yw0dHsxzQZnBoumn5MnOB9MTnA5BLOr6c(S5lBBayZj9Hit1S5WdF6mHm2C6wZwmf2CiCkOQbBcUm1XrBWqw7X0KBFfdX9yAYTJnTyns4ORPLVvIgPl4VWj8syXpL1iHJUqFiXil0tO4cNWlHf)7X3HxcxtlFRensxWh(4cFatP1gm(lONan9AhNcQASeCzQJJ2GHS2JPj3(kgIUaqc(rcq4pOJ0GhEqFuXxDe9r)aoYacJkwKBMPooAdgYApMMC7RyiUhttUDSPfRrchDre8u8PfKXfoHxcl(paqQaGEwYX)afxcU(HQa0LC8pqX1J0psUdVeMpFb9eOPx74uqvJLGR)cqxYX)afxUzcjTDtn(us8vi9FazEayxqpkzvq6(0QZIHI4IPeSgVmQKfDmWaA4ltVJeN3QrKq6)JUaJ74OROuiREC(QOm15MnhkMMCZg0TEZMdpik(SLResq6HQzZbfCvHh9LQe)duKTbOS1dBps)i5MTpgz0r2kcFpYS5q4uqvdFLU79fBsumh2GU1B2KqxstyJUNiX2DRS10S5ciK2lHlM64OnyiR9yAYTVIH4Emn52XMwmuAKWrxzbrXhoiKGq6zHt4LWs(8VWG0GxgxzXFbgqdR3iCwqu8HdcjiKEG0pLlaD9cUQWJRhPFKChEj0FbOl54FGIRhZIEioVj)f0tGMETJtbvnwcU(HQGEc00lYDVVeCZNVGEc00RDCkOQX6XSOhcLez(8fGUiOlPjlTpx6rgs)fGUiOlPjRhZIEiuAtvTQ1k]] )


end