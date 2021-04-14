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
        adaptation = 3453, -- 214027
        gladiators_medallion = 3456, -- 208683
        relentless = 3461, -- 196029

        mindnumbing_poison = 137, -- 197050
        honor_among_thieves = 132, -- 198032
        maneuverability = 3448, -- 197000
        shiv = 131, -- 248744
        intent_to_kill = 130, -- 197007
        creeping_venom = 141, -- 198092
        flying_daggers = 144, -- 198128
        system_shock = 147, -- 198145
        death_from_above = 3479, -- 269513
        smoke_bomb = 3480, -- 212182
        neurotoxin = 830, -- 206328
    } )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )

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
            duration = 5,
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

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
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
                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
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
                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
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

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
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
                if pvptalent.intent_to_kill.enabled and debuff.vendetta.up then return 10 end
                return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 )
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
                -- Can't predict the Animacharge.
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
                echoing_reprimand = {
                    alias = { "echoing_reprimand_2", "echoing_reprimand_3", "echoing_reprimand_4" },
                    aliasMode = "first",
                    aliasType = "buff",
                    meta = {
                        stack = function ()
                            if buff.echoing_reprimand_2.up then return 2 end
                            if buff.echoing_reprimand_3.up then return 3 end
                            if buff.echoing_reprimand_4.up then return 4 end
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
            charges = 3,
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


    spec:RegisterPack( "Assassination", 20210413, [[davakcqiqkpsPGlbss2er1NqszuirNcjSkckEfvPMfvHBPuHDPKFPuPHHKQJbclJG8mIsnnIsUMsrTnqs13iOkghvrPohvrX6iO07ajPsZdK4EeyFef)JGQuoivrSqqQEOsHMOsf1fPkQ2OsrYhbjLrsqvQoPsrQvIK8sqskZuPiUjbv1ofvAOGKyPufPNsOPkQ4QGKuXwjOYxPkkzSkvK9kv)fudMYHfwSO8yvmzPCzOnJuFMkgTk50swnijv9ALsZwKBtvTBf)wvdNkDCcQswoWZrmDsxNiBxL67kvnEQsopiA(IQ2pQ7q0ZPl2cf75ke1fccQlliK9siiK9M7IkKUyx0noBdhSloHp2f9ecjiKAcT(Pl6gqM(O1ZPlsEjWb7IxQ6se2D31P0lPS1593Lu(sPqRFoGGw3Lu(ND7Izsvs30tpRl2cf75ke1fccQlliK9siiKTSeswDXqsVEqxuS83yx8QAnC6zDXgsoDrpHqccPMqRFyZtFhjKPYtCbvInieYd2eI6cbbtft1gVIXbjclt1oyZtCDtqYg1ikOok1yJofoSPpBK3hzZtGkBcB0pylHn9zJe3iBUG)GesnoSPLpUyQ2bB78putzt4IPixSjnjKqytmvhKTyASTZ1bzBFLsSLcIYw6hheWMEfdBc)GOiGnpHqccPMft1oyZtXu4fBBQu4GPuO1pSTlBchonu1GncKZHnklA2eoCAOQbBfHn9DCsyJTNMMThW2pSfSL(XHTnUZuS6IPIOKEoDrIIrsVWwpNEUq0ZPlItKLWwh6DX4O1pDXdO8j)aROVls0Uydjhq5Q1pDXClNlIgPTiGTFyt25iSSTrq5t(HTCqFxKODXdOueurxuJeo6AkNlLOrAlcw4ezjSXMC2iUykbRbWbvcBYiGnzZMC2oVF2d7(1Oe2KraBYIn5SPbWb1Lw(iS(WTczBhSbq)OgcBYWguVR9CfQNtxeNilHTo07IXrRF6IajxvcGDXgsoGYvRF6I5woxensBraB)Wge5iSSjoHl56v28ujxvcGDXdOueurxuJeo6AkNlLOrAlcw4ezjSXMC2oVF2d7(1Oe2KraBYIn5SPbWb1Lw(iS(WTczBhSbq)OgcBYWguVR9CLDpNUiorwcBDO3fJJw)0fD)pbdqYlboyxSHKdOC16NUOOuMIaAjhuyzZtCDtqY2dyZtrAasUyBFPxSLjrtJn2GAba8ks6I0paEqV0EUq01EUYQNtxeNilHTo07IXrRF6Ioba8k2fpGsrqfDrns4OlIuMIaAjhCHtKLWgBYzJs2aOFudHnOWgecXw(8S56lL0YnviGnOiGniyJc2KZMgahuxA5JW6d3kKTDWga9JAiSjdBc1fpqEsiSgahuj9CHOR9C3CpNUiorwcBDO3fJJw)0fD)pbdqYlboyxSHKdOC16NUOOuMIaAjhKnVzZZ9I4W2pSbroclBEksdqYfBqTaaEfzlu20lKnCAS90Srums6fB6ZMdQS5hEXwtceA9dBzi9dq28CViX4ivtOyxK(bWd6L2ZfIU2ZfQ3ZPlItKLWwh6DXdOueurxuJeo6IiLPiGwYbx4ezjSXMC20iHJUqViX4ivtO4cNilHn2KZwC06gHXb9lKWMa2GGn5SLjrtViszkcOLCWfa9JAiSbf2Gyj7UyC06NUOtaaVIDTNRWtpNUiorwcBDO3fpGsrqfDrns4OlIuMIaAjhCHtKLWgBYz78(zpS7xJsydkcyt2DX4O1pDrFjTsHIDTRDX7ykYvpNEUq0ZPlItKLWwh6DX3TlsqTlghT(PlEhGkYsyx8ossyxKs2GgBaPbPFGdUAyOxjiHjxr73tw4ezjSXMC2qAA8O1ncFE)Sh29RrjSjJa2oUW(HxWexCASrbB5ZZgLSbKgK(bo4QHHELGeMCfTFpzHtKLWgBYz78(zpS7xJsydkSjeBu0fBi5akxT(PlUPQPixSTV0l28dVyBJqf2OFaB5woxkrJ0we4bBstcje2Ki14W2oJHELGKnXRO97jDX7aapHp2fNY5sjAK2Ia4Jl85NwP1pDTNRq9C6I4ezjS1HExmoA9tx8oMIC1fBi5akxT(PlkCXuKl22x6fBEUxeh28MTClNlLOrAlcew2e(HxLVKpBBeQWwmn28CVioSbWObjB0pGTb9szdQTXDUlEaLIGk6IAKWrxOxKyCKQjuCHtKLWgBYztJeo6AkNlLOrAlcw4ezjSXMC2UdqfzjCnLZLs0iTfbWhx4ZpTsRFytoBN)tTF)SqViX4ivtO4cG(rne2GcBq01EUYUNtxeNilHTo07IXrRF6I3XuKRUydjhq5Q1pDrHlMICX2(sVyl3Y5sjAK2Ia28MTCF28CVioclBc)WRYxYNTncvylMgBchonu1Gnj3U4bukcQOlQrchDnLZLs0iTfblCISe2ytoBqJnns4Ol0lsmos1ekUWjYsyJn5SDhGkYs4AkNlLOrAlcGpUWNFALw)WMC2AyMen96gNgQASKC7Apxz1ZPlItKLWwh6DX4O1pDr3)tWaK8sGd2frVuqah(V0ODrzT5Ui9dGh0lTNleDTN7M750fXjYsyRd9U4bukcQOlQrchDrKYueql5GlCISe2ytoBN)tTF)SCca4vCj5YMC2OKT2RlNaaEfxaKgGKRilHSLppBnmtIMEDJtdvnwsUSjNT2RlNaaEfxU(sjTCtfcydkcydc2OGn5SDE)Sh29RrjRgsxNsztgbSrjBexmLG1a4Gkzrhd8tdVDQBKWMmcVXMSyJc2KZgiQgmEJJUIwJSQHnzydcH6IXrRF6I3XuKRU2ZfQ3ZPlItKLWwh6DX4O1pDX7ykYvxSHKdOC16NUOWftrUyBFPxSj8dIIa28ecji1iSS5PsUQea9gQfaWRiBZRSvdBaKgGKl2aX4GEWwtcuJdBchonu1WBXR6EXMiKZHT9LEXMi6skcB01ej2UkLTIMn3NqQSeU6IhqPiOIUiLSPrchD5hefbWbHeesnlCISe2ylFE2asds)ahC5hGTWpnSEHW(brraCqibHuZcNilHn2OGn5Sbn2AVUasUQeaxaKgGKRilHSjNT2RlNaaEfxa0pQHWMmSjB2KZwdZKOPx340qvJLKlBYzJs2AyMen9ICv3ljx2YNNTgMjrtVUXPHQgla6h1qydkSjl2YNNT2Rlc6skYsRZ2ACyJc2KZw71fbDjfzbq)OgcBqHnz31U2fBiDiL0Eo9CHONtxmoA9txCBD22fXjYsyRd9U2ZvOEoDrCISe26qVl2qYbuUA9tx0trIIrsVyROzZ9jKklHSr58SDlLgeezjKnCq)cjSvdBN3pluk6IXrRF6IefJKE11EUYUNtxeNilHTo07IVBxKGAxmoA9tx8oavKLWU4DKKWUiXftjynaoOsw0Xa)0WBN6gjSbf2eQlEha4j8XUiPgNecRbWb1U2Zvw9C6I4ezjS1HEx8akfbv0fjkgj9cBlW7iHDrIcQJ2ZfIUyC06NU4jsj44O1pWPIODXuru4j8XUirXiPxyRR9C3CpNUiorwcBDO3fpGsrqfDrkzdASPrchD5hefbWbHeesnlCISe2ylFE2AVUCca4vCP1zBnoSrrxKOG6O9CHOlghT(PlEIucooA9dCQiAxmvefEcFSlEAKU2ZfQ3ZPlItKLWwh6DX4O1pDrsQoiCmn4wDWUydjhq5Q1pDrOIKYM4SZSj5YwnLwrkbjB0pGTnkPSPpB6fY2gVcc6bBaKgGKl22x6fBE(CJZ7ZwrZwOSL(9S1KaHw)0fpGsrqfDrOXwMen9IKQdchtdUvhCj5YMC2oVF2d7(1Oe2KraBYUR9CfE650fXjYsyRd9U4bukcQOlMjrtViP6GWX0GB1bxsUSjNTmjA6fjvheoMgCRo4cG(rne2GcBBMn5SDE)Sh29RrjSjJa2KvxmoA9txeNBCE)U2Z1ZUNtxeNilHTo07IXrRF6INiLGJJw)aNkI2ftfrHNWh7ITx7ApxptpNUiorwcBDO3fJJw)0fprkbhhT(boveTlMkIcpHp2fBfapAx75cb1750fXjYsyRd9U4bukcQOlIdcCGC1q66ukBYiGni2mBEZgoiWbYfaDWb(8(z1GTUyC06NUyaoXGW6da4ODTNleq0ZPlghT(PlgGtmiSRuIGDrCISe26qVR9CHqOEoDX4O1pDXu5CPeyO6LAo(4ODrCISe26qVR9CHq29C6IXrRF6IzHd8tdRG6SL0fXjYsyRd9U21UOlapVFwO9C65crpNUyC06NUy46MGe29lYpDrCISe26qVR9CfQNtxmoA9txm7vnHny6uaj22xJdS(EvtxeNilHTo07Apxz3ZPlItKLWwh6DX4O1pDr)aSfBW0paUHHE1fpGsrqfDrquny8ghDfTgzvdBYWgeBUl6cWZ7Nfkmbp)0iDXn31EUYQNtxeNilHTo07IVBxKGAxmoA9tx8oavKLWU4DaGNWh7IkOMTOctGCoWK0RDXdOueurxub1Sf1LcX6kiWen0vmqc3CjSjNnkzdASPGA2I6sfADfeyIg6kgiHBUe2YNNnfuZwuxkeRZ)P2VFwnjqO1pSjJa2uqnBrDPcTo)NA)(z1KaHw)WgfDXgsoGYvRF6I7mQiWVgKT9x15InklA2IbskyJOHYwMennBkOMTOY2EKT9XOSPpBHQOVRYM(SrGCoSTV0l2eoCAOQXQlEhjjSlcrx75U5EoDrCISe26qVl(UDrcQDX4O1pDX7aurwc7I3rsc7Ic1fpGsrqfDrfuZwuxQqRRGat0qxXajCZLWMC2OKnOXMcQzlQlfI1vqGjAORyGeU5sylFE2uqnBrDPcTo)NA)(z1KaHw)WMmSPGA2I6sHyD(p1(9ZQjbcT(Hnk6I3baEcFSlQGA2IkmbY5atsV21EUq9EoDrCISe26qVlghT(Plss1bHJPb3Qd2fpGsrqfDrasdqYvKLWUOlapVFwOWe88tJ0fHOR9CfE650fJJw)0fjkgj9QlItKLWwh6DTRDXwbWJ2ZPNle9C6I4ezjS1HExmoA9txeNBCE)Uydjhq5Q1pDrpFUX59zlu2KL3Sr5M9MT9LEX2olsbBBeQSyBt77JTkumbjB)WMqEZMgahujEW2(sVyt4WPHQgEW2dyBFPxSLd09GTxVqW(IGSTpkLn6hWg59r2WbboqUyZtsKNT9rPSv0S55ErCy78(zpBfHTZ7xJdBsURU4bukcQOlI004rRBe(8(zpS7xJsytgbSjl28Mnns4ORgIUiaMOGqdh0FHtKLWgBYzJs2AyMen96gNgQASKCzlFE2AyMen9ICv3ljx2YNNTgMjrtVOtHdMsHw)SKCzlFE2WbboqUAiDDkLnOiGnH2mBEZgoiWbYfaDWb(8(z1Gn2YNNnOX2DaQilHlsnojewdGdQSrbBYzJs2GgBAKWrxOxKyCKQjuCHtKLWgB5ZZ25)u73pl0lsmos1ekUaOFudHnzyti2OOR9CfQNtxeNilHTo07IVBxKGAxmoA9tx8oavKLWU4DKKWU459ZEy3VgLSAiDDkLnzydc2YNNnCqGdKRgsxNszdkcytOnZM3SHdcCGCbqhCGpVFwnyJT85zdASDhGkYs4IuJtcH1a4GAx8oaWt4JDrjcctxPec6Apxz3ZPlItKLWwh6DX4O1pDrccaHIn4SFqyIBTf7InKCaLRw)0f9ex3eKSjcDr20NTiLytdGdQe22x61lPSfS1WmjAA2ccBUG6bLcPhS5cqAeaQXHnnaoOsyRbznoSr(FqaBbTIa20lKnxq5haiztdGdQDXdOueurx8oavKLWLebHPRucbSjNnOXw71fbbGqXgC2pimXT2IWTxxAD2wJtx75kREoDrCISe26qVlghT(PlsqaiuSbN9dctCRTyx8akfbv0fVdqfzjCjrqy6kLqaBYzdAS1EDrqaiuSbN9dctCRTiC71LwNT140fpqEsiSgahuj9CHOR9C3CpNUiorwcBDO3fJJw)0fjiaek2GZ(bHjU1wSl2qYbuUA9tx0Z6ch2e(EcBfHT5v2cLTRY5ITMei06hpytIGSjcDr20NTW1nbjBBcgn2YGKnp3RW3nHS1Ka14WMWHtdvn8GTxVqW(IGSTfrx2ObVpBNW1Tgh2oxbWbjDXdOueurx8oavKLWLebHPRucbSjNn)GOiaoiKGqQbgG(rne2GcBuF5zZMC2OKn6Y5sHbOFudHnOiGTnZw(8SD(p1(9ZIGaqOydo7heM4wBX15kaoibMgehT(jsSjJa2eAj8Sz2YNNnYlLYQPTsy0GZGeg9k8Dt4cNilHn2KZg0yltIMELWObNbjm6v47MWLKlBYzRHzs00RBCAOQXsYLT85zltIME5haWVhBWoOpr)bHX5kMd6JJUKCzJIU2ZfQ3ZPlItKLWwh6DX4O1pDr6yGFA4TtDJKUydjhq5Q1pDXnvmS90SbvBQBKWwOSbHNXB2iAC2sy7Pzt49Q1WHnONIgsy7bSforneLnz5nBAaCqLS6IhqPiOIU4DaQilHljcctxPecytoBuYwMen96QAnCGZsrdjlIgNTSjJa2GWZWw(8SrjBqJnxq9GsHeg8AO1pSjNnIlMsWAaCqLSOJb(PH3o1nsytgbSjl28MnIIrsVW2c8osiBuWgfDTNRWtpNUiorwcBDO3fJJw)0fPJb(PH3o1ns6IhipjewdGdQKEUq0fpGsrqfDX7aurwcxseeMUsjeWMC2iUykbRbWbvYIog4NgE7u3iHnzeWMS7InKCaLRw)0f3uXW2tZguTPUrcB6Zw46MGKn3Vi)qyROzRM4O1nY2pSfdKSPbWbv2O8bSfdKSLLqSvJdBAaCqLW2(sVyZfupOuizd8AO1puWwOSj7C6Apxp7EoDrCISe26qVlEaLIGk6I3bOISeUKiimDLsiGn5SD(p1(9Z6gNgQASaOFudHnzydcQ3fJJw)0fXZ1xJdmaDbLFmTU2Z1Z0ZPlItKLWwh6DXdOueurx8oavKLWLebHPRucbSjNnkzZpikcGdcjiKAGbOFudHnbSrD2KZg0ydini9dCWv7F)Su0WforwcBSLppBzs00RSunns1WLKlBu0fJJw)0fd)mjYvx75cb1750fXjYsyRd9UyC06NUOVKwPqXU4bYtcH1a4GkPNleDXdOueurx8oavKLWLebHPRucbSjNnIlMsWAaCqLSOJb(PH3o1nsytaBc1fBi5akxT(PlMtKTdHVKwPqr20NTW1nbjB7mgTeKSbv(I8dBHYMqSPbWbvsx75cbe9C6I4ezjS1HEx8akfbv0fVdqfzjCjrqy6kLqqxmoA9tx0xsRuOyx7Ax80i9C65crpNUiorwcBDO3fJJw)0f9dWwSbt)a4gg6vxmvdcFADriwBUlEG8KqynaoOs65crx8akfbv0fbr1GXBC0v0AKLKlBYzJs20a4G6slFewF4wHSbf2oVF2d7(1OKvdPRtPSjmSbXAZSLppBN3p7HD)AuYQH01Pu2KraBhxy)WlyIlon2OOl2qYbuUA9txCttZw0Ae2caYMKRhSrMYfztVq2(bzBFPxSL(9irzlNC25fBq1HGST)ch2AqwJdB0brraB6vmSTrOcBnKUoLY2dyBFPxVKYwmqY2gHkRU2ZvOEoDrCISe26qVlghT(Pl6hGTydM(bWnm0RUydjhq5Q1pDXnnnBZZw0Ae22xPeBTczBFPx1WMEHSnOxkBYM6epytIGSj8P3z2(HTSNqyBFPxVKYwmqY2gHkRU4bukcQOlcIQbJ34ORO1iRAytg2Kn1zBhSbIQbJ34ORO1iRMei06h2KZ259ZEy3VgLSAiDDkLnzeW2Xf2p8cM4ItRR9CLDpNUiorwcBDO3fJJw)0fPtHdMsHw)0fBi5akxT(Plkc5CyBtLchmLcT(HT9LEXMWHtdvnyliSL(XHTGW2EKT9)qnLT0tq2c2obrz7VraB6fYgD5CPS1KaHw)WgLpGTIMnHdNgQAW2(kLy78(iBzXzlBHtuZUfHn9DCsyJTNMMIvx8akfbv0fHgBefJKEHTf4DKq2KZgLSrjBN)tTF)SUXPHQgla6h1qytg28muNT85z78FQ97N1nonu1ybq)OgcBqHnzZgfSjNnKMgpADJWN3p7HD)AucBYiGnzXMC20a4G6slFewF4wHSjdBqqD2YNNTgMjrtVUXPHQgljx2YNNTSNqytoB0LZLcdq)OgcBqHnHKfBu01EUYQNtxeNilHTo07IhqPiOIUi0yJOyK0lSTaVJeYMC2qAA8O1ncFE)Sh29RrjSjJa2KfBYzJs2Ot)dyJs2OKn6Y5sHbOFudHTDWMqYInkyBx2IJw)aF(p1(9dBuWMmSrN(hWgLSrjB0LZLcdq)OgcB7GnHKfB7GTZ)P2VFw340qvJfa9JAiSjmSDhGkYs46gNgQAaFAa2OGTDzloA9d85)u73pSrbBu0fJJw)0fPtHdMsHw)01EUBUNtxeNilHTo07IXrRF6Ie0LuKUydjhq5Q1pDrriNdBIOlPiSTV0l2eoCAOQbBbHT0poSfe22JST)hQPSLEcYwW2jikB)ncytVq2OlNlLTMei06hpyltszZfG0iGnnaoOsytVcLT9vkXwQUr2cLTegeLniOoPlEaLIGk6IqJnIIrsVW2c8osiBYzJs2o)NA)(zDJtdvnwa0pQHWguydc2KZMgahuxA5JW6d3kKnzydcQZw(8S1WmjA61nonu1yj5Yw(8Srxoxkma9JAiSbf2GG6Srrx75c1750fXjYsyRd9U4bukcQOlcn2ikgj9cBlW7iHSjNnkzJo9pGnkzJs2OlNlfgG(rne22bBqqD2OGTDzloA9d85)u73pSrbBYWgD6FaBuYgLSrxoxkma9JAiSTd2GG6STd2o)NA)(zDJtdvnwa0pQHWMWW2DaQilHRBCAOQb8PbyJc22LT4O1pWN)tTF)WgfSrrxmoA9txKGUKI01EUcp9C6I4ezjS1HEx8D7Ieu7IXrRF6I3bOISe2fVJKe2fHgBAKWrxt5CPensBrWcNilHn2YNNnOXMgjC0f6fjghPAcfx4ezjSXw(8SD(p1(9Zc9IeJJunHIla6h1qydkSTz22bBcXMWWMgjC0vdrxeatuqOHd6VWjYsyRl2qYbuUA9txueY5WMWHtdvnyBFnTFpB7l9ITClNlLOrAlc82Z9IeJJunHISv0SfUUP6ezjSlEha4j8XU4nonu1aEkNlLOrAlcGp)0kT(PR9C9S750fXjYsyRd9U472fjO2fJJw)0fVdqfzjSlEha4j8XU4nonu1a(834eJcF(PvA9tx8akfbv0fp)noXORTqcQyylFE2o)noXORbpGp9GgB5ZZ25VXjgDn)GDXgsoGYvRF6IIqoh2eoCAOQbB7l9ITnvkCWuk06h2IPXMi6skcBbHT0poSfe22JST)hQPSLEcYwW2jikB)ncytVq2OlNlLTMei06NU4DKKWUieDTNRNPNtxeNilHTo07IVBxKGAxmoA9tx8oavKLWU4DKKWUiD6FaBuYgLSrxoxkma9JAiSTd2eI6SrbB7YgLSbHquNnHHT7aurwcx340qvd4tdWgfSrbBYWgD6FaBuYgLSrxoxkma9JAiSTd2eI6STd2o)NA)(zrNchmLcT(zbq)OgcBuW2USrjBqie1ztyy7oavKLW1nonu1a(0aSrbBuWw(8SLjrtVOtHdMsHw)aNjrtVKCzlFE2AyMen9IofoykfA9ZsYLT85zJUCUuya6h1qydkSje17IhqPiOIU45VXjgDDJJEbjOlEha4j8XU4nonu1a(834eJcF(PvA9tx75cb1750fXjYsyRd9U472fjO2fJJw)0fVdqfzjSlEhjjSlsN(hWgLSrjB0LZLcdq)OgcB7GnHOoBuW2USrjBqie1ztyy7oavKLW1nonu1a(0aSrbBuWMmSrN(hWgLSrjB0LZLcdq)OgcB7GnHOoB7GTZ)P2VFwe0LuKfa9JAiSrbB7YgLSbHquNnHHT7aurwcx340qvd4tdWgfSrbB5ZZw71fbDjfzP1zBnoSLppB0LZLcdq)OgcBqHnHOEx8akfbv0fp)noXORPCUuy6a7I3baEcFSlEJtdvnGp)noXOWNFALw)01EUqarpNUiorwcBDO3fpGsrqfDrOXgrXiPxyBbEhjKn5S1EDbKCvjaU06STgh2KZg0yRHzs00RBCAOQXsYLn5SDhGkYs46gNgQAapLZLs0iTfbWNFALw)WMC2UdqfzjCDJtdvnGp)noXOWNFALw)0fJJw)0fVXPHQgDTNlec1ZPlItKLWwh6DX4O1pDr0lsmos1ek2fBi5akxT(Pl65ErIXrQMqr22FHdBZRSrums6f2ylMgBzVEXMNk5QsaKTyASb1ca4vKTaGSj5Yg9dyl9JdB48soxRU4bukcQOlcn2ikgj9cBlW7iHSjNnkzdAS1ED5eaWR4cG0aKCfzjKn5S1EDbKCvjaUaOFudHnzytwS5nBYInHHTJlSF4fmXfNgB5ZZw71fqYvLa4cG(rne2eg2O(AZSjdBAaCqDPLpcRpCRq2OGn5SPbWb1Lw(iS(WTcztg2Kvx75cHS750fXjYsyRd9UyC06NUi5QU7InKCaLRw)0ffVQB2kA22JSfaKTi7Lu20NnpFUX599GTyASfQI(UkB6ZgbY5W2(sVyteDjfHn6AIeBxLYwrZ2EKT9)qnLT9brr28FaYMEfdBxrIMn9cz78FQ97Nvx8akfbv0fBVUasUQeaxAD2wJdBYzJs2GgBN)tTF)SiOlPilagnizlFE2o)NA)(zDJtdvnwa0pQHWMmSbHqSrbB5ZZw71fbDjfzP1zBnoDTNleYQNtxeNilHTo07IhqPiOIUyMen9kl9Fljr0faJJYw(8SL9ecBYzJUCUuya6h1qydkSjBQZw(8S1WmjA61nonu1yj52fJJw)0fDFT(PR9CHyZ9C6I4ezjS1HEx8akfbv0fByMen96gNgQASKC7IXrRF6IzP)BW0sai7ApxiG69C6I4ezjS1HEx8akfbv0fByMen96gNgQASKC7IXrRF6IziGGGT1401EUqi80ZPlItKLWwh6DXdOueurxSHzs00RBCAOQXsYTlghT(Plsxaml9FRR9CHWZUNtxeNilHTo07IhqPiOIUydZKOPx340qvJLKBxmoA9txmMdsuqKGprk11EUq4z650fXjYsyRd9U4bukcQOlcn2ikgj9cBRiLytoB(brraCqibHudma9JAiSjGnQZMC2OKnOXMgjC0LFqueahesqi1SWjYsyJT85zltIMErs1bHJPb3QdUaOFudHnzyt2SrrxmoA9tx8ePeCC06h4ur0UyQik8e(yx8oMIC11EUcr9EoDrCISe26qVlghT(PlQGA2IkeDXgsoGYvRF6IIqoh20lKnxq9GsHKnIgkBzs00SPGA2IkB7l9InHdNgQA4bBVEHG9fbztIGS9dBN)tTF)0fpGsrqfDX7aurwcxkOMTOctGCoWK0RSjGniytoBuYwdZKOPx340qvJLKlB5ZZw2tiSjNn6Y5sHbOFudHnOiGnHOoBuWw(8SrjB3bOISeUuqnBrfMa5CGjPxztaBcXMC2GgBkOMTOUuHwN)tTF)Say0GKnkylFE2GgB3bOISeUuqnBrfMa5CGjPx7ApxHGONtxeNilHTo07IhqPiOIU4DaQilHlfuZwuHjqohys6v2eWMqSjNnkzRHzs00RBCAOQXsYLT85zl7je2KZgD5CPWa0pQHWgueWMquNnkylFE2OKT7aurwcxkOMTOctGCoWK0RSjGniytoBqJnfuZwuxkeRZ)P2VFwamAqYgfSLppBqJT7aurwcxkOMTOctGCoWK0RDX4O1pDrfuZwufQRDTl2ETNtpxi650fXjYsyRd9U472fjO2fJJw)0fVdqfzjSlEhjjSl6cQhukKWGxdT(Hn5SrjBTxxoba8kUaOFudHnOW25)u73plNaaEfxnjqO1pSLppB4Gahixa0bh4Z7Nvd2ytg2K9MzJIUydjhq5Q1pDXnP8lLncE(PfaizdQfaWRiHn6hWMlOEqPqYg41qRFyROzBpY2vCJSj7nZgoiWbs2aOdoS9a2GAba8kY2(kLyd9YTaiB)WMEHS5ck)aajBAaCqTlEha4j8XUizB5cFG8KqyNaaEf7ApxH650fXjYsyRd9U472fjO2fJJw)0fVdqfzjSlEhjjSl6cQhukKWGxdT(Hn5SrjBnmtIMErUQ7LKlBYzJ4IPeSgahujl6yGFA4TtDJe2KHnHylFE2WbboqUaOdoWN3pRgSXMmSj7nZgfDXgsoGYvRF6IBs5xkBe88tlaqYMNk5QsaKWg9dyZfupOuizd8AO1pSv0SThz7kUr2K9Mzdhe4ajBa0bh2EaBIx1nBfHnjx2(HnHYX7U4DaGNWh7IKTLl8bYtcHbsUQea7Apxz3ZPlItKLWwh6DX3TlsqTlghT(PlEhGkYsyx8ossyxSHzs00RBCAOQXsYLn5SrjBnmtIMErUQ7LKlB5ZZMFqueahesqi1adq)OgcBYWg1zJc2KZw71fqYvLa4cG(rne2KHnH6InKCaLRw)0f3KYVu28ujxvcGe2kA2eoCAOQH3Ix19Uc)GOiGnpHqccPg2kcBsUSftJT9iBxXnYMqEZgbp)0iSLqALTFytVq28ujxvcGSTZFoDX7aapHp2fjBlxyGKRkbWU2Zvw9C6I4ezjS1HExmoA9tx0jaGxXUydjhq5Q1pDrrx8urInOwaaVISftJnpvYvLaiBeuLCzZfupGn9zZZ9IeJJunHISDcI2fpGsrqfDrns4Ol0lsmos1ekUWjYsyJn5Sbn2AyMen9YjaGxXf6fjghPAcfBSjNT2RlNaaEfxU(sjTCtfcydkcydc2KZ25)u73pl0lsmos1ekUaOFudHnOWMqSjNnIlMsWAaCqLSOJb(PH3o1nsytaBqWMC2ar1GXBC0v0AKvnSjdBqD2KZw71LtaaVIla6h1qytyyJ6RnZguytdGdQlT8ry9HBf21EUBUNtxeNilHTo07IhqPiOIUOgjC0f6fjghPAcfx4ezjSXMC2OKnKMgpADJWN3p7HD)AucBYiGTJlSF4fmXfNgBYz78FQ97Nf6fjghPAcfxa0pQHWguydc2KZw71fqYvLa4cG(rne2eg2O(AZSbf20a4G6slFewF4wHSrrxmoA9txei5QsaSR9CH69C6I4ezjS1HExmoA9tx09)emajVe4GDXgsoGYvRF6IqTaaEfztYDlIUEWwKipBkOqcB6ZMebzRu2ccBbBex8urInhCqqOpGn6hWMEHSLcIY2gHkSLH0pazlyJUMICHGUi9dGh0lTNleDTNRWtpNUiorwcBDO3fpGsrqfDrasdqYvKLq2KZ259ZEy3VgLSAiDDkLnzeWgeSjNnkzZ1xkPLBQqaBqraBqWw(8Sbq)OgcBqraBAD2cRLpYMC2iUykbRbWbvYIog4NgE7u3iHnzeWMSzJc2KZgLSbn2qViX4ivtOyJT85zdG(rne2GIa206SfwlFKnHHnHytoBexmLG1a4Gkzrhd8tdVDQBKWMmcyt2SrbBYzJs20a4G6slFewF4wHSTd2aOFudHnkytg2KfBYzZpikcGdcjiKAGbOFudHnbSr9UyC06NUOtaaVIDTNRNDpNUiorwcBDO3fPFa8GEP9CHOlghT(Pl6(FcgGKxcCWU2Z1Z0ZPlItKLWwh6DX4O1pDrNaaEf7IhqPiOIUi0y7oavKLWfzB5cFG8KqyNaaEfztoBaKgGKRilHSjNTZ7N9WUFnkz1q66ukBYiGniytoBuYMRVusl3uHa2GIa2GGT85zdG(rne2GIa206SfwlFKn5SrCXucwdGdQKfDmWpn82PUrcBYiGnzZgfSjNnkzdASHErIXrQMqXgB5ZZga9JAiSbfbSP1zlSw(iBcdBcXMC2iUykbRbWbvYIog4NgE7u3iHnzeWMSzJc2KZgLSPbWb1Lw(iS(WTczBhSbq)OgcBuWMmSbHqSjNn)GOiaoiKGqQbgG(rne2eWg17IhipjewdGdQKEUq01EUqq9EoDrCISe26qVlghT(PlEaLp5hyf9DrI2fBi5akxT(PlUrq5t(HTCqFxKOS9dB(sjTCtiBAaCqLWwOSjlVzBJqf22FHdBaPzQXHTxszRg2eAhYMWwqyl9JdBbHT9iBxXnYgoVKZfBa0bh2IPXwaWHAkBeu1ACytYLn6hWMWHtdvn6IhqPiOIUiXftjynaoOsytgbSjeBYzdG(rne2GcBcXM3SrjBexmLG1a4GkHnzeW2MzJc2KZgstJhTUr4Z7N9WUFnkHnzeWMSytoB4Gahixa0bh4Z7Nvd2ytg2eI6SjNnkzdASD(p1(9Z6gNgQASay0GKT85zR96ci5QsaCP1zBnoSrrx75cbe9C6I4ezjS1HExmoA9txei5QsaSl2qYbuUA9txeQgIUSj5YMNk5QsaKTqztwEZ2pSfPeBAaCqLWgL7VWHTuDxJdBPFCydNxY5ITyASnVYgzcxY1Ru0fpGsrqfDrOX2DaQilHlY2Yfgi5QsaKn5SH004rRBe(8(zpS7xJsytgbSjl2KZgaPbi5kYsiBYzJs2C9LsA5MkeWgueWgeSLppBa0pQHWgueWMwNTWA5JSjNnIlMsWAaCqLSOJb(PH3o1nsytgbSjB2OGn5SrjBqJn0lsmos1ek2ylFE2aOFudHnOiGnToBH1Yhztyyti2KZgXftjynaoOsw0Xa)0WBN6gjSjJa2KnBuWMC20a4G6slFewF4wHSTd2aOFudHnzyJs2KfBEZgqAq6h4GRwqUQXbMCEPPbW0cNilHn2eg28mS5nBaPbPFGdUA)7NLIgUWjYsyJnHHnOoBu01EUqiupNUiorwcBDO3fJJw)0fbsUQea7IhqPiOIUi0y7oavKLWfzB5cFG8KqyGKRkbq2KZg0y7oavKLWfzB5cdKCvjaYMC2qAA8O1ncFE)Sh29RrjSjJa2KfBYzdG0aKCfzjKn5SrjBU(sjTCtfcydkcydc2YNNna6h1qydkcytRZwyT8r2KZgXftjynaoOsw0Xa)0WBN6gjSjJa2KnBuWMC2OKnOXg6fjghPAcfBSLppBa0pQHWgueWMwNTWA5JSjmSjeBYzJ4IPeSgahujl6yGFA4TtDJe2KraBYMnkytoBAaCqDPLpcRpCRq22bBa0pQHWMmSrjBYInVzdini9dCWvlix14atoV00ayAHtKLWgBcdBEg28MnG0G0pWbxT)9Zsrdx4ezjSXMWWguNnk6IhipjewdGdQKEUq01EUqi7EoDrCISe26qVlghT(PlEaLp5hyf9DrI2fBi5akxT(PlUPIukloBzZtEpNTnckFYpSLd67IeLT9LEXMEHSrcFKT07uh2ccBr2FJEWwMKYw5mpOgh20lKnCqGdKSD(PvA9dHTIMT9iBbahQPSjrQXHnpvYvLayx8akfbv0fjUykbRbWbvcBYiGnHytoBa0pQHWguyti28MnkzJ4IPeSgahujSjJa22mBuWMC2qAA8O1ncFE)Sh29RrjSjJa2Kvx75cHS650fXjYsyRd9UyC06NU4bu(KFGv03fjAxSHKdOC16NU4gbLp5h2Yb9DrIY2pSjMdBfnB1WMBmn0VoSftJTbdqcs28dVydhe4ajBX0yROzZZNBCEF22)d1u2ApB(pazRf(HdYwtcztF2Yb67k89KU4bukcQOlsCXucwdGdQe2eWgeSjNnOXgqAq6h4GRwqUQXbMCEPPbW0cNilHn2KZMFqueahesqi1adq)OgcBcyJ6SjNnKMgpADJWN3p7HD)AucBYiGnkz74c7hEbtCXPX2oydc2OGn5SbqAasUISeYMC2GgBOxKyCKQjuSXMC2GgBnmtIMErUQ7LKlBYzJs2WbboqUAiDDkLnOiGnH2mBEZgoiWbYfaDWb(8(z1Gn2OGn5SPbWb1Lw(iS(WTczBhSbq)OgcBYWMS6Ax7Ax8gbK6NEUcrDHGG6YI6YUlUpatnoKUONLN4P5UPZfQjSSXwoxiBLV7du2OFaBu7oMICrn2aOWlPcGn2iVpYwiPVFOyJTZvmoizXuTj1GSbHWY2g)5gbk2yJAaPbPFGdU2jQXM(SrnG0G0pWbx70cNilHnQXgLc5fflMQnPgKnOUWY2g)5gbk2yJAaPbPFGdU2jQXM(SrnG0G0pWbx70cNilHnQXgLq4fflMkMkplpXtZDtNlutyzJTCUq2kF3hOSr)a2OMlapVFwOuJnak8sQayJnY7JSfs67hk2y7CfJdswmvBsniBYsyzBJ)CJafBSrnfuZwuxqS2jQXM(SrnfuZwuxkeRDIASrPqErXIPAtQbztwclBB8NBeOyJnQPGA2I6sO1orn20NnQPGA2I6sfATtuJnkfYlkwmvBsniBBwyzBJ)CJafBSrnfuZwuxqS2jQXM(SrnfuZwuxkeRDIASrPqErXIPAtQbzBZclBB8NBeOyJnQPGA2I6sO1orn20NnQPGA2I6sfATtuJnkfYlkwmvmvEwEINM7MoxOMWYgB5CHSv(UpqzJ(bSrTwbWJsn2aOWlPcGn2iVpYwiPVFOyJTZvmoizXuTj1GS5zew224p3iqXgBudini9dCW1orn20NnQbKgK(bo4ANw4ezjSrn2OecVOyXuLZfYg9Ns)(ACylKabHT9iaztIGn2QHn9czloA9dBPIOSLjPSThbiBZRSr)stJTAytVq2Iw7h2AHgzbbfwMk22bB(ba87XgSd6t0FqyCUI5G(4OmvmvEwEINM7MoxOMWYgB5CHSv(UpqzJ(bSrTtJqn2aOWlPcGn2iVpYwiPVFOyJTZvmoizXuTj1GSjlHLTn(ZncuSXMy5Vr2iqoA4fBqvSPpBBIuWwRUls9dBVlcc9bSr5UuWgLc5fflMQnPgKnOUWY2g)5gbk2ytS83iBeihn8InOk20NTnrkyRv3fP(HT3fbH(a2OCxkyJsH8IIft1MudYMNryzBJ)CJafBSjw(BKncKJgEXgufB6Z2MifS1Q7Iu)W27IGqFaBuUlfSrPqErXIPAtQbzdcQlSSTXFUrGIn2el)nYgbYrdVydQIn9zBtKc2A1DrQFy7DrqOpGnk3Lc2OuiVOyXuTj1GSje1fw224p3iqXgButb1Sf1LqRDIASPpButb1Sf1Lk0ANOgBucHxuSyQ2KAq2eccHLTn(ZncuSXg1uqnBrDbXANOgB6Zg1uqnBrDPqS2jQXgLq4fflMkMkplpXtZDtNlutyzJTCUq2kF3hOSr)a2Ow7vQXgafEjvaSXg59r2cj99dfBSDUIXbjlMQnPgKnzjSSTXFUrGIn2Og6fjghPAcfBRDIASPpBuRHzs00RDAHErIXrQMqXg1yJsi8IIft1MudYgeqiSSTXFUrGIn2OgqAq6h4GRDIASPpBudini9dCW1oTWjYsyJASrPqErXIPAtQbzdcHew224p3iqXgBudini9dCW1orn20NnQbKgK(bo4ANw4ezjSrn2OuiVOyXuTj1GSbHSew224p3iqXgBudini9dCW1orn20NnQbKgK(bo4ANw4ezjSrn2OecVOyXuXuLZfYg1KiiCPOpHASfhT(HT9bHT5v2OFPPXwnSPxfHTY39b6IPAt77(afBSj8WwC06h2sfrjlMQUiXfp9CfAZEMUOl4PRe2f3WgyZtiKGqQj06h2803rczQ2WgyZtCbvInieYd2eI6cbbtft1g2aBB8kghKiSmvBydSTd28ex3eKSrnIcQJsn2OtHdB6Zg59r28eOYMWg9d2sytF2iXnYMl4piHuJdBA5JlMQnSb22bB78putzt4IPixSjnjKqytmvhKTyASTZ1bzBFLsSLcIYw6hheWMEfdBc)GOiGnpHqccPMft1g2aB7GnpftHxSTPsHdMsHw)W2USjC40qvd2iqoh2OSOzt4WPHQgSve203XjHn2EAA2EaB)WwWw6hh224otXIPIPAdBGnp3l8iPyJTmK(biBN3plu2YqNAil28KZbDvcBZp74ka(0sj2IJw)qy7NeKlMQ4O1pKLlapVFwOccx3eKWUFr(HPkoA9dz5cWZ7NfQ3c2n7vnHny6uaj22xJdS(EvdtvC06hYYfGN3pluVfSRFa2Iny6ha3WqV8WfGN3pluycE(PreSzpkAbGOAW4no6kAnYQgzGyZmvBGTDgve4xdY2(R6CXgLfnBXajfSr0qzltIMMnfuZwuzBpY2(yu20NTqv03vztF2iqoh22x6fBchonu1yXufhT(HSCb459Zc1Bb7EhGkYsOht4JcuqnBrfMa5CGjPx94ossOai8OOfOGA2I6cI1vqGjAORyGeU5sKtj0uqnBrDj06kiWen0vmqc3Cj5ZRGA2I6cI15)u73pRMei06hzeOGA2I6sO15)u73pRMei06hkyQIJw)qwUa88(zH6TGDVdqfzj0Jj8rbkOMTOctGCoWK0REChjjuGqEu0cuqnBrDj06kiWen0vmqc3CjYPeAkOMTOUGyDfeyIg6kgiHBUK85vqnBrDj068FQ97NvtceA9JmkOMTOUGyD(p1(9ZQjbcT(HcMQ4O1pKLlapVFwOElyxsQoiCmn4wDqpCb459ZcfMGNFAebq4rrlaG0aKCfzjKPkoA9dz5cWZ7NfQ3c2LOyK0lMkMQnSb28CVWJKIn2WBeajBA5JSPxiBXrFaBfHT4oQuKLWftvC06hIGT1zlt1gyZtrIIrsVyROzZ9jKklHSr58SDlLgeezjKnCq)cjSvdBN3plukyQIJw)q8wWUefJKEXufhT(H4TGDVdqfzj0Jj8rbKACsiSgahu94ossOaIlMsWAaCqLSOJb(PH3o1nsGIqmvXrRFiEly3tKsWXrRFGtfr9ycFuarXiPxyZdIcQJkacpkAbefJKEHTf4DKqMQ4O1peVfS7jsj44O1pWPIOEmHpk40iEquqDubq4HhfTakHMgjC0LFqueahesqi1SWjYsylF(2RlNaaEfxAD2wJdfmvBGnOIKYM4SZSj5YwnLwrkbjB0pGTnkPSPpB6fY2gVcc6bBaKgGKl22x6fBE(CJZ7ZwrZwOSL(9S1KaHw)WufhT(H4TGDjP6GWX0GB1b9OOfaTmjA6fjvheoMgCRo4sYv(59ZEy3VgLiJazZufhT(H4TGDX5gN33JIwqMen9IKQdchtdUvhCj5kptIMErs1bHJPb3QdUaOFudbkBw(59ZEy3VgLiJazXufhT(H4TGDprkbhhT(bove1Jj8rbTxzQIJw)q8wWUNiLGJJw)aNkI6Xe(OGwbWJYufhT(H4TGDdWjgewFaah1JIwaoiWbYvdPRtPYiaIn7noiWbYfaDWb(8(z1GnMQ4O1peVfSBaoXGWUsjcYufhT(H4TGDtLZLsGHQxQ54JJYufhT(H4TGDZch4Ngwb1zlHPIPAdBGTn(FQ97hct1gyBttZw0Ae2caYMKRhSrMYfztVq2(bzBFPxSL(9irzlNC25fBq1HGST)ch2AqwJdB0brraB6vmSTrOcBnKUoLY2dyBFPxVKYwmqY2gHklMQ4O1pK1Pr8wWU(byl2GPFaCdd9YJuni8PjaI1M94a5jHWAaCqLiacpkAbGOAW4no6kAnYsYvoLAaCqDPLpcRpCRqOCE)Sh29RrjRgsxNsfgiwBoF(Z7N9WUFnkz1q66uQmcoUW(HxWexCAuWuTb2200SnpBrRryBFLsS1kKT9LEvdB6fY2GEPSjBQt8GnjcYMWNENz7h2YEcHT9LE9skBXajBBeQSyQIJw)qwNgXBb76hGTydM(bWnm0lpkAbGOAW4no6kAnYQgzKn13biQgmEJJUIwJSAsGqRFKFE)Sh29RrjRgsxNsLrWXf2p8cM4ItJPAdSjc5CyBtLchmLcT(HT9LEXMWHtdvnyliSL(XHTGW2EKT9)qnLT0tq2c2obrz7VraB6fYgD5CPS1KaHw)WgLpGTIMnHdNgQAW2(kLy78(iBzXzlBHtuZUfHn9DCsyJTNMMIftvC06hY60iElyx6u4GPuO1pEu0cGgrXiPxyBbEhjuoLuE(p1(9Z6gNgQASaOFudrgpd1ZN)8FQ97N1nonu1ybq)OgcuKnfYrAA8O1ncFE)Sh29RrjYiqwY1a4G6slFewF4wHYab1ZNVHzs00RBCAOQXsYnF(SNqKtxoxkma9JAiqrizrbtvC06hY60iElyx6u4GPuO1pEu0cGgrXiPxyBbEhjuostJhTUr4Z7N9WUFnkrgbYsoL0P)busjD5CPWa0pQHSdHKffqvN)tTF)qHm0P)busjD5CPWa0pQHSdHK1oo)NA)(zDJtdvnwa0pQHim3bOISeUUXPHQgWNgGcOQZ)P2VFOGcMQnWMiKZHnr0Lue22x6fBchonu1GTGWw6hh2ccB7r22)d1u2spbzly7eeLT)gbSPxiB0LZLYwtceA9JhSLjPS5cqAeWMgahujSPxHY2(kLylv3iBHYwcdIYgeuNWufhT(HSonI3c2LGUKI4rrlaAefJKEHTf4DKq5uE(p1(9Z6gNgQASaOFudbkqixdGdQlT8ry9HBfkdeupF(gMjrtVUXPHQglj385PlNlfgG(rneOab1PGPkoA9dzDAeVfSlbDjfXJIwa0ikgj9cBlW7iHYPKo9pGskPlNlfgG(rnKDab1PaQ68FQ97hkKHo9pGskPlNlfgG(rnKDab13X5)u73pRBCAOQXcG(rneH5oavKLW1nonu1a(0auavD(p1(9dfuWuTb2eHCoSjC40qvd22xt73Z2(sVyl3Y5sjAK2IaV9CViX4ivtOiBfnBHRBQorwczQIJw)qwNgXBb7EhGkYsOht4JcUXPHQgWt5CPensBra85NwP1pEChjjua00iHJUMY5sjAK2IGforwcB5Zdnns4Ol0lsmos1ekUWjYsylF(Z)P2VFwOxKyCKQjuCbq)Ogcu28oesy0iHJUAi6IayIccnCq)forwcBmvBGnriNdBchonu1GT9LEX2MkfoykfA9dBX0yteDjfHTGWw6hh2ccB7r22)d1u2spbzly7eeLT)gbSPxiB0LZLYwtceA9dtvC06hY60iEly37aurwc9ycFuWnonu1a(834eJcF(PvA9JhfTGZFJtm6AlKGkM85p)noXORbpGp9Gw(8N)gNy018d6XDKKqbqWufhT(HSonI3c29oavKLqpMWhfCJtdvnGp)noXOWNFALw)4rrl4834eJUUXrVGe4XDKKqb0P)busjD5CPWa0pQHSdHOofqvucHquxyUdqfzjCDJtdvnGpnafuidD6FaLusxoxkma9JAi7qiQVJZ)P2VFw0PWbtPqRFwa0pQHqbufLqie1fM7aurwcx340qvd4tdqbf5ZNjrtVOtHdMsHw)aNjrtVKCZNVHzs00l6u4GPuO1plj385PlNlfgG(rneOie1zQIJw)qwNgXBb7EhGkYsOht4JcUXPHQgWN)gNyu4ZpTsRF8OOfC(BCIrxt5CPW0b6XDKKqb0P)busjD5CPWa0pQHSdHOofqvucHquxyUdqfzjCDJtdvnGpnafuidD6FaLusxoxkma9JAi7qiQVJZ)P2VFwe0LuKfa9JAiuavrjecrDH5oavKLW1nonu1a(0auqr(8Txxe0LuKLwNT14KppD5CPWa0pQHafHOotvC06hY60iEly3BCAOQHhfTaOrums6f2wG3rcL3EDbKCvjaU06STgh5qRHzs00RBCAOQXsYv(DaQilHRBCAOQb8uoxkrJ0weaF(PvA9J87aurwcx340qvd4ZFJtmk85NwP1pmvBGnp3lsmos1ekY2(lCyBELnIIrsVWgBX0yl71l28ujxvcGSftJnOwaaVISfaKnjx2OFaBPFCydNxY5AXufhT(HSonI3c2f9IeJJunHIEu0cGgrXiPxyBbEhjuoLqR96YjaGxXfaPbi5kYsO82RlGKRkbWfa9JAiYilVLLWCCH9dVGjU40YNV96ci5QsaCbq)OgIWq91MLrdGdQlT8ry9HBfsHCnaoOU0YhH1hUvOmYIPAdSjEv3Sv0SThzlaiBr2lPSPpBE(CJZ77bBX0yluf9Dv20NncKZHT9LEXMi6skcB01ej2UkLTIMT9iB7)HAkB7dIIS5)aKn9kg2UIenB6fY25)u73plMQ4O1pK1Pr8wWUKR62JIwq71fqYvLa4sRZ2ACKtj0o)NA)(zrqxsrwamAqMp)5)u73pRBCAOQXcG(rnezGqikYNV96IGUKIS06STghMQ4O1pK1Pr8wWUUVw)4rrlitIMELL(VLKi6cGXrZNp7je50LZLcdq)OgcuKn1ZNVHzs00RBCAOQXsYLPkoA9dzDAeVfSBw6)gmTeaspkAbnmtIMEDJtdvnwsUmvXrRFiRtJ4TGDZqabbBRXXJIwqdZKOPx340qvJLKltvC06hY60iElyx6cGzP)BEu0cAyMen96gNgQASKCzQIJw)qwNgXBb7gZbjkisWNiL8OOf0WmjA61nonu1yj5YufhT(HSonI3c29ePeCC06h4urupMWhfChtrU8OOfanIIrsVW2ksj5(brraCqibHudma9JAicOUCkHMgjC0LFqueahesqi1SWjYsylF(mjA6fjvheoMgCRo4cG(rnezKnfmvBGnriNdB6fYMlOEqPqYgrdLTmjAA2uqnBrLT9LEXMWHtdvn8GTxVqW(IGSjrq2(HTZ)P2VFyQIJw)qwNgXBb7QGA2IkeEu0cUdqfzjCPGA2IkmbY5atsVkac5u2WmjA61nonu1yj5MpF2tiYPlNlfgG(rneOiqiQtr(8uEhGkYs4sb1SfvycKZbMKEvGqYHMcQzlQlHwN)tTF)Say0GKI85H2DaQilHlfuZwuHjqohys6vMQ4O1pK1Pr8wWUkOMTOkKhfTG7aurwcxkOMTOctGCoWK0RcesoLnmtIMEDJtdvnwsU5ZN9eIC6Y5sHbOFudbkceI6uKppL3bOISeUuqnBrfMa5CGjPxfaHCOPGA2I6cI15)u73plagniPiFEODhGkYs4sb1SfvycKZbMKELPIPAdBGTDUa4rzRf(HdYwKvPslKWuTb2885gN3NTqztwEZgLB2B22x6fB7SifSTrOYITnTVp2QqXeKS9dBc5nBAaCqL4bB7l9InHdNgQA4bBpGT9LEXwoqhQUS96fc2xeKT9rPSr)a2iVpYgoiWbYfBEsI8STpkLTIMnp3lIdBN3p7zRiSDE)ACytYDXufhT(HSAfapQaCUX599OOfG004rRBe(8(zpS7xJsKrGS8wJeo6QHOlcGjki0Wb9x4ezjSjNYgMjrtVUXPHQglj385ByMen9ICv3lj385ByMen9IofoykfA9ZsYnFECqGdKRgsxNsHIaH2S34Gahixa0bh4Z7Nvd2YNhA3bOISeUi14KqynaoOsHCkHMgjC0f6fjghPAcfx4ezjSLp)5)u73pl0lsmos1ekUaOFudrgHOGPkoA9dz1kaEuVfS7DaQilHEmHpkqIGW0vkHapUJKek48(zpS7xJswnKUoLkde5ZJdcCGC1q66ukuei0M9ghe4a5cGo4aFE)SAWw(8q7oavKLWfPgNecRbWbvMQnWMN46MGKnrOlYM(SfPeBAaCqLW2(sVEjLTGTgMjrtZwqyZfupOui9GnxasJaqnoSPbWbvcBniRXHnY)dcylOveWMEHS5ck)aajBAaCqLPkoA9dz1kaEuVfSlbbGqXgC2pimXT2IEu0cUdqfzjCjrqy6kLqGCO1EDrqaiuSbN9dctCRTiC71LwNT14WufhT(HSAfapQ3c2LGaqOydo7heM4wBrpoqEsiSgahujcGWJIwWDaQilHljcctxPecKdT2RlccaHIn4SFqyIBTfHBVU06STghMQnWMN1foSj89e2kcBZRSfkBxLZfBnjqO1pEWMebzte6ISPpBHRBcs22emASLbjBEUxHVBczRjbQXHnHdNgQA4bBVEHG9fbzBlIUSrdEF2oHRBnoSDUcGdsyQIJw)qwTcGh1Bb7sqaiuSbN9dctCRTOhfTG7aurwcxseeMUsjei3pikcGdcjiKAGbOFudbkuF5zlNs6Y5sHbOFudbkc2C(8N)tTF)Siiaek2GZ(bHjU1wCDUcGdsGPbXrRFIKmceAj8S585jVukRM2kHrdodsy0RW3nHlCISe2KdTmjA6vcJgCgKWOxHVBcxsUYByMen96gNgQASKCZNptIME5haWVhBWoOpr)bHX5kMd6JJUKCPGPAdSTPIHTNMnOAtDJe2cLni8mEZgrJZwcBpnBcVxTgoSb9u0qcBpGTWjQHOSjlVztdGdQKftvC06hYQva8OElyx6yGFA4TtDJepkAb3bOISeUKiimDLsiqoLzs00RRQ1WbolfnKSiAC2kJai8m5Ztj0Cb1dkfsyWRHw)iN4IPeSgahujl6yGFA4TtDJezeilVjkgj9cBlW7iHuqbt1gyBtfdBpnBq1M6gjSPpBHRBcs2C)I8dHTIMTAIJw3iB)WwmqYMgahuzJYhWwmqYwwcXwnoSPbWbvcB7l9Inxq9GsHKnWRHw)qbBHYMSZHPkoA9dz1kaEuVfSlDmWpn82PUrIhhipjewdGdQebq4rrl4oavKLWLebHPRucbYjUykbRbWbvYIog4NgE7u3irgbYMPkoA9dz1kaEuVfSlEU(ACGbOlO8JP5rrl4oavKLWLebHPRucbYp)NA)(zDJtdvnwa0pQHideuNPkoA9dz1kaEuVfSB4NjrU8OOfChGkYs4sIGW0vkHa5u6hefbWbHeesnWa0pQHiG6YHgqAq6h4GR2)(zPOH5ZNjrtVYs10ivdxsUuWuTb2YjY2HWxsRuOiB6Zw46MGKTDgJwcs2GkFr(HTqzti20a4GkHPkoA9dz1kaEuVfSRVKwPqrpoqEsiSgahujcGWJIwWDaQilHljcctxPecKtCXucwdGdQKfDmWpn82PUrIaHyQIJw)qwTcGh1Bb76lPvku0JIwWDaQilHljcctxPecyQyQ2WgyBNd)Wbz7VraBA5JSfzvQ0cjmvBGTnP8lLncE(PfaizdQfaWRiHn6hWMlOEqPqYg41qRFyROzBpY2vCJSj7nZgoiWbs2aOdoS9a2GAba8kY2(kLyd9YTaiB)WMEHS5ck)aajBAaCqLPkoA9dz1EvWDaQilHEmHpkGSTCHpqEsiStaaVIEChjjuGlOEqPqcdEn06h5u2ED5eaWR4cG(rneOC(p1(9ZYjaGxXvtceA9t(84Gahixa0bh4Z7Nvd2Kr2BMcMQnW2Mu(LYgbp)0caKS5PsUQeajSr)a2Cb1dkfs2aVgA9dBfnB7r2UIBKnzVz2WbboqYgaDWHThWM4vDZwrytYLTFytOC8MPkoA9dz1E1Bb7EhGkYsOht4JciBlx4dKNecdKCvja6XDKKqbUG6bLcjm41qRFKtzdZKOPxKR6Ej5kN4IPeSgahujl6yGFA4TtDJezekFECqGdKla6Gd859ZQbBYi7ntbt1gyBtk)szZtLCvjasyROzt4WPHQgElEv37k8dIIa28ecjiKAyRiSj5Ywmn22JSDf3iBc5nBe88tJWwcPv2(Hn9czZtLCvjaY2o)5WufhT(HSAV6TGDVdqfzj0Jj8rbKTLlmqYvLaOh3rscf0WmjA61nonu1yj5kNYgMjrtVix19sYnFE)GOiaoiKGqQbgG(rnezOofYBVUasUQeaxa0pQHiJqmvBGnrx8urInOwaaVISftJnpvYvLaiBeuLCzZfupGn9zZZ9IeJJunHISDcIYufhT(HSAV6TGDDca4v0JIwGgjC0f6fjghPAcfx4ezjSjhAOxKyCKQjuSTCca4vuE71LtaaVIlxFPKwUPcbqraeYp)NA)(zHErIXrQMqXfa9JAiqri5exmLG1a4Gkzrhd8tdVDQBKiac5GOAW4no6kAnYQgzG6YBVUCca4vCbq)OgIWq91MHIgahuxA5JW6d3kKPkoA9dz1E1Bb7cKCvja6rrlqJeo6c9IeJJunHIlCISe2KtjstJhTUr4Z7N9WUFnkrgbhxy)WlyIlon5N)tTF)SqViX4ivtO4cG(rneOaH82RlGKRkbWfa9JAicd1xBgkAaCqDPLpcRpCRqkyQ2aBqTaaEfztYDlIUEWwKipBkOqcB6ZMebzRu2ccBbBex8urInhCqqOpGn6hWMEHSLcIY2gHkSLH0pazlyJUMICHaMQ4O1pKv7vVfSR7)jyasEjWb9G(bWd6LkacMQ4O1pKv7vVfSRtaaVIEu0cainajxrwcLFE)Sh29RrjRgsxNsLraeYP01xkPLBQqauear(8a0pQHafbAD2cRLpkN4IPeSgahujl6yGFA4TtDJezeiBkKtj0qViX4ivtOylFEa6h1qGIaToBH1YhfgHKtCXucwdGdQKfDmWpn82PUrImcKnfYPudGdQlT8ry9HBfUda6h1qOqgzj3pikcGdcjiKAGbOFudra1zQIJw)qwTx9wWUU)NGbi5Lah0d6hapOxQaiyQIJw)qwTx9wWUoba8k6XbYtcH1a4GkraeEu0cG2DaQilHlY2Yf(a5jHWoba8kkhG0aKCfzju(59ZEy3VgLSAiDDkvgbqiNsxFPKwUPcbqrae5Zdq)OgcueO1zlSw(OCIlMsWAaCqLSOJb(PH3o1nsKrGSPqoLqd9IeJJunHIT85bOFudbkc06SfwlFuyesoXftjynaoOsw0Xa)0WBN6gjYiq2uiNsnaoOU0YhH1hUv4oaOFudHczGqi5(brraCqibHudma9JAicOot1gyBJGYN8dB5G(Uirz7h28LsA5Mq20a4GkHTqztwEZ2gHkST)ch2asZuJdBVKYwnSj0oKnHTGWw6hh2ccB7r2UIBKnCEjNl2aOdoSftJTaGd1u2iOQ14WMKlB0pGnHdNgQAWufhT(HSAV6TGDpGYN8dSI(Uir9OOfqCXucwdGdQezeiKCa6h1qGIqEtjXftjynaoOsKrWMPqostJhTUr4Z7N9WUFnkrgbYsooiWbYfaDWb(8(z1GnzeI6YPeAN)tTF)SUXPHQglagniZNV96ci5QsaCP1zBnouWuTb2GQHOlBsUS5PsUQeazlu2KL3S9dBrkXMgahujSr5(lCylv314Ww6hh2W5LCUylMgBZRSrMWLC9kfmvXrRFiR2RElyxGKRkbqpkAbq7oavKLWfzB5cdKCvjakhPPXJw3i859ZEy3VgLiJazjhG0aKCfzjuoLU(sjTCtfcGIaiYNhG(rneOiqRZwyT8r5exmLG1a4Gkzrhd8tdVDQBKiJaztHCkHg6fjghPAcfB5Zdq)OgcueO1zlSw(OWiKCIlMsWAaCqLSOJb(PH3o1nsKrGSPqUgahuxA5JW6d3kCha0pQHidLYYBG0G0pWbxTGCvJdm58stdGjHXZ4nqAq6h4GR2)(zPOHcduNcMQ4O1pKv7vVfSlqYvLaOhhipjewdGdQebq4rrlaA3bOISeUiBlx4dKNecdKCvjakhA3bOISeUiBlxyGKRkbq5innE06gHpVF2d7(1Oezeil5aKgGKRilHYP01xkPLBQqauear(8a0pQHafbAD2cRLpkN4IPeSgahujl6yGFA4TtDJezeiBkKtj0qViX4ivtOylFEa6h1qGIaToBH1YhfgHKtCXucwdGdQKfDmWpn82PUrImcKnfY1a4G6slFewF4wH7aG(rnezOuwEdKgK(bo4QfKRACGjNxAAamjmEgVbsds)ahC1(3plfnuyG6uWuTb22urkLfNTS5jVNZ2gbLp5h2Yb9DrIY2(sVytVq2iHpYw6DQdBbHTi7VrpyltszRCMhuJdB6fYgoiWbs2o)0kT(HWwrZ2EKTaGd1u2Ki14WMNk5QsaKPkoA9dz1E1Bb7EaLp5hyf9DrI6rrlG4IPeSgahujYiqi5a0pQHafH8MsIlMsWAaCqLiJGntHCKMgpADJWN3p7HD)AuImcKft1gyBJGYN8dB5G(Uirz7h2eZHTIMTAyZnMg6xh2IPX2GbibjB(HxSHdcCGKTyASv0S55ZnoVpB7)HAkBTNn)hGS1c)WbzRjHSPpB5a9Df(EctvC06hYQ9Q3c29akFYpWk67Ie1JIwaXftjynaoOseaHCObKgK(bo4QfKRACGjNxAAamj3pikcGdcjiKAGbOFudra1LJ004rRBe(8(zpS7xJsKraLhxy)WlyIloTDabfYbinajxrwcLdn0lsmos1ek2KdTgMjrtVix19sYvoL4GahixnKUoLcfbcTzVXbboqUaOdoWN3pRgSrHCnaoOU0YhH1hUv4oaOFudrgzXuXuTHnWMOIrsVWgBEYrRFimvBGTClNlIgPTiGTFyt25iSSTrq5t(HTCqFxKOmvXrRFilIIrsVWMGdO8j)aROVlsupkAbAKWrxt5CPensBrWcNilHn5exmLG1a4GkrgbYw(59ZEy3VgLiJazjxdGdQlT8ry9HBfUda6h1qKbQZuTb2YTCUiAK2Ia2(HniYryztCcxY1RS5PsUQeazQIJw)qwefJKEHnVfSlqYvLaOhfTans4ORPCUuIgPTiyHtKLWM8Z7N9WUFnkrgbYsUgahuxA5JW6d3kCha0pQHiduNPAdSjkLPiGwYbfw28ex3eKS9a28uKgGKl22x6fBzs00yJnOwaaVIeMQ4O1pKfrXiPxyZBb76(FcgGKxcCqpOFa8GEPcGGPkoA9dzrums6f28wWUoba8k6XbYtcH1a4GkraeEu0c0iHJUiszkcOLCWforwcBYPeG(rneOaHq5Z76lL0YnviakcGGc5AaCqDPLpcRpCRWDaq)OgImcXuTb2eLYueql5GS5nBEUxeh2(HniYryzZtrAasUydQfaWRiBHYMEHSHtJTNMnIIrsVytF2CqLn)Wl2AsGqRFyldPFaYMN7fjghPAcfzQIJw)qwefJKEHnVfSR7)jyasEjWb9G(bWd6LkacMQ4O1pKfrXiPxyZBb76eaWROhfTans4OlIuMIaAjhCHtKLWMCns4Ol0lsmos1ekUWjYsytEC06gHXb9lKiac5zs00lIuMIaAjhCbq)OgcuGyjBMQ4O1pKfrXiPxyZBb76lPvku0JIwGgjC0frktraTKdUWjYsyt(59ZEy3VgLafbYMPIPAdBGnHlMICXuTb22u1uKl22x6fB(HxSTrOcB0pGTClNlLOrAlc8GnPjHecBsKACyBNXqVsqYM4v0(9eMQ4O1pK1Dmf5sWDaQilHEmHpkykNlLOrAlcGpUWNFALw)4XDKKqbucnG0G0pWbxnm0ReKWKRO97jYrAA8O1ncFE)Sh29RrjYi44c7hEbtCXPrr(8ucKgK(bo4QHHELGeMCfTFpr(59ZEy3VgLafHOGPAdSjCXuKl22x6fBEUxeh28MTClNlLOrAlcew2e(HxLVKpBBeQWwmn28CVioSbWObjB0pGTb9szdQTXDMPkoA9dzDhtrU8wWU3XuKlpkAbAKWrxOxKyCKQjuCHtKLWMCns4ORPCUuIgPTiyHtKLWM87aurwcxt5CPensBra8Xf(8tR06h5N)tTF)SqViX4ivtO4cG(rneOabt1gyt4IPixSTV0l2YTCUuIgPTiGnVzl3Nnp3lIJWYMWp8Q8L8zBJqf2IPXMWHtdvnytYLPkoA9dzDhtrU8wWU3XuKlpkAbAKWrxt5CPensBrWcNilHn5qtJeo6c9IeJJunHIlCISe2KFhGkYs4AkNlLOrAlcGpUWNFALw)iVHzs00RBCAOQXsYLPkoA9dzDhtrU8wWUU)NGbi5Lah0d6hapOxQai8a9sbbC4)sJkqwBMPkoA9dzDhtrU8wWU3XuKlpkAbAKWrxePmfb0so4cNilHn5N)tTF)SCca4vCj5kNY2RlNaaEfxaKgGKRilH5Z3WmjA61nonu1yj5kV96YjaGxXLRVusl3uHaOiackKFE)Sh29RrjRgsxNsLraLexmLG1a4Gkzrhd8tdVDQBKiJWBYIc5GOAW4no6kAnYQgzGqiMQnWMWftrUyBFPxSj8dIIa28ecji1iSS5PsUQea9gQfaWRiBZRSvdBaKgGKl2aX4GEWwtcuJdBchonu1WBXR6EXMiKZHT9LEXMi6skcB01ej2UkLTIMn3NqQSeUyQIJw)qw3XuKlVfS7Dmf5YJIwaLAKWrx(brraCqibHuZcNilHT85bsds)ahC5hGTWpnSEHW(brraCqibHudfYHw71fqYvLa4cG0aKCfzjuE71LtaaVIla6h1qKr2YByMen96gNgQASKCLtzdZKOPxKR6Ej5MpFdZKOPx340qvJfa9JAiqrw5Z3EDrqxsrwAD2wJdfYBVUiOlPila6h1qGIS7Ax7D]] )


end