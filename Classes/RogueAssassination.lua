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
                gain( 2, "combo_points" )

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

            handler = function ()
                gain( 1, "combo_points" )
                removeBuff( "hidden_blades" )
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
                    id = 319504,
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


    spec:RegisterPack( "Assassination", 20210318, [[dafW(bqiKOEKkPCjLcytOQ(evsnkvvDkKWQqkYRqvAwujULsH2Ls(LkjddjYXujwgsLNHQOPHQW1ePQTrLe(gsbACifKZrLKADif17qkaAEQkCpK0(qQ6FifaoisHAHQk6HkfzIQKkxuKkTrKcQpQsQAKifGoPsbALiLEjvssZuPOCtQKODkszOkfvlvKkEkknvQuDvQKezRkf0xrkGglsHSxj9xvzWuoSWIPQESkMSexgAZO4ZIy0QuNwQvtLKOETsPzlQBtv2TIFdmCQ44ujjSCqphX0jUoQSDLQVRQ04Ps58QQmFrY(jD9s19kBjeSMgDuIUluINxC1l645f6OepRSYphSY6eNTrcwzNWdRS0ycjiKEcPbtL1j(LbrP6ELLa4GhSYElIdHMV6QKwU58xhG3vK2JlhsdMdmyKRiT35QkRpxNLn4u9RSLqWAA0rj6UqjEEHgADXvtjEshDv2GtUbWklB7TPk7Dxk4u9RSfKCQS0ycjiKEcPbJAPdiHdvADLb8CR2fAixuJokr3LkBUjcP6ELLiyKLBSuDVM2LQ7vwCc)mwQFwzli5aBhPbtLnTo5MirElcvdmQXt3Pz12eS9iGrn3rphKiv2dSfe2rLvImoYA6KBHirElcx4e(zSOgF1ioyo)KaMGcrn6PQgpvJVAhGNp45a6riQrpv14HA8vtcycklP9WNaELgvBJQbrVOhIA0RMROYghPbtL9aBpcyEc65GePk10OR6ELfNWpJL6Nv2csoW2rAWuztRtUjsK3Iq1aJAxCNMvJDchYnqulD4CeoiwzpWwqyhvwjY4iRPtUfIe5TiCHt4NXIA8v7a88bphqpcrn6PQgpuJVAsatqzjTh(eWR0OABuni6f9quJE1Cfv24inyQSqohHdIvPMgpRUxzXj8ZyP(zLTGKdSDKgmvwwoFbHmCjinRgn2Xj)tnauT0bzGi5wTVTCRMphddwu76dieiiPYYaGVbDtQPDPYghPbtL1baYpisaCWdwLAA8O6ELfNWpJL6Nv24inyQSjbeceSYEGTGWoQSsKXrweoFbHmCj4cNWpJf14R2F1GOx0drTpu7cDQLkLAoECzPDYncv7dQQDrnkuJVAsatqzjTh(eWR0OABuni6f9quJE1ORYE(DY4tcyckKAAxQsnT0xDVYIt4NXs9ZkBbjhy7inyQSSC(ccz4sq14vT01nsIAGrTlUtZQLoidej3QD9beceuTqutUr1WPOgGrnIGrwUvtaQLGIAEHBQv4GH0GrnFKbar1sx3iXKW1tiyLLbaFd6Mut7sLnosdMkRdaKFqKa4GhSk10Cfv3RS4e(zSu)SYEGTGWoQSsKXrweoFbHmCj4cNWpJf14RMezCKf6gjMeUEcbx4e(zSOgF1IJ074dh0RrIAuv7IA8vZNJHzr48feYWLGli6f9qu7d1US4zLnosdMkBsaHabRsnnAWQ7vwCc)mwQFwzpWwqyhvwjY4ilcNVGqgUeCHt4NXIA8v7a88bphqpcrTpOQgpRSXrAWuz94KohcwLQuz3JPj3v3RPDP6ELfNWpJL6NvwGtLLGsLnosdMk7Ea7WpJv29iZHv2)Qrz1GCdYaGj4QGHCN)9i3rb8LSWj8Zyrn(QHmm4r6D8DaE(GNdOhHOg9uv7488c3EehCkQrHAPsP2F1GCdYaGj4QGHCN)9i3rb8LSWj8Zyrn(QDaE(GNdOhHO2hQrNAuuzli5aBhPbtLLgUNMCR23wUvZlCtTnT5QXaGQLwNClejYBrOlQXnzKquJJ0tIAxhgYD(NAS3rb8Luz3d4BcpSYoDYTqKiVfHVJZ7aMslnyQsnn6QUxzXj8ZyP(zLTGKdSDKgmv2nmMMCR23wUvlDDJKOgVQLwNClejYBrinRMRmCR948uBtBUAXuulDDJKOgeJYp1yaq1g0nrTRFtxxL9aBbHDuzLiJJSq3iXKW1ti4cNWpJf14RMezCK10j3crI8weUWj8Zyrn(QThWo8Z4A6KBHirElcFhN3bmLwAWOgF1oaqUa(ol0nsmjC9ecUGOx0drTpu7sLnosdMk7Emn5Uk104z19kloHFgl1pRSfKCGTJ0GPYUHX0KB1(2YTAP1j3crI8weQgVQLgqT01nscnRMRmCR948uBtBUAXuuBdXPGIeQX5uzpWwqyhvwjY4iRPtUfIe5TiCHt4NXIA8vJYQjrghzHUrIjHRNqWfoHFglQXxT9a2HFgxtNClejYBr4748oGP0sdg14Rwb95yyw74uqrIfNtLnosdMk7Emn5Uk104r19kloHFgl1pRSOBcmEHhGBKklpsFLLbaFd6Mut7sLnosdMkRdaKFqKa4GhSk10sF19kloHFgl1pRShyliSJkRezCKfHZxqidxcUWj8Zyrn(QDaGCb8DwjbeceCX5OgF1(RwbiRKacbcUGidej3HFgvlvk1kOphdZAhNcksS4CuJVAfGSsciei4YXJllTtUrOAFqvTlQrHA8v7a88bphqpczvqM(0IA0tvT)QrCWC(jbmbfYIjMhG5TD6DKOg90aqnEOgfQXxny0LhUJJSIsHS6rn6v7cDv24inyQS7X0K7QutZvuDVYIt4NXs9ZkBbjhy7inyQSBymn5wTVTCRMRmiccvJgtibPhAwT0HZr4GiVxFaHabvBaIA9OgezGi5wnymjOlQv4G9KO2gItbfj4L9U3xQX(BoQ9TLB1yrhstuJPNiR2DlQ1mQ5aiK2pJRk7b2cc7OY(xnjY4ilVGii8fesqi9SWj8ZyrTuPudYnidaMGlVaU9byEYn(8cIGWxqibH0ZcNWpJf1Oqn(Qrz1kazb5CeoiUGidej3HFgvJVAfGSsciei4cIErpe1OxnEQgF1kOphdZAhNcksS4CuJVA)vRG(CmmlYDVV4Culvk1kOphdZAhNcksSGOx0drTpuJhQLkLAfGSiOdPjlPpB7jrnkuJVAfGSiOdPjli6f9qu7d14zLnosdMk7Emn5UkvPYwqMGllv3RPDP6ELnosdMk72(STYIt4NXs9ZQutJUQ7vwCc)mwQFwzli5aBhPbtLnDqIGrwUvRzuZbqiTFgv7)auBNlpim8ZOA4GEnsuRh1oap)qOOYghPbtLLiyKL7QutJNv3RS4e(zSu)SYcCQSeuQSXrAWuz3dyh(zSYUhzoSYIdct(TGycoQXRAoGMagS88ZiwiQrtQrdP2vQ9xn6uJMuJ4G587oicQgfv29a(MWdRS4GWKFpiMGZ7a887blvPMgpQUxzXj8ZyP(zLf4uzjOuzJJ0GPYUhWo8ZyLDpYCyLL4G58tcyckKftmpaZB707irTpuJUk7EaFt4Hvwspjz8jbmbLQutl9v3RS4e(zSu)SYEGTGWoQSebJSCJLfeKWHvwIa7Jut7sLnosdMk7jY5xCKgmVCtKkBUjYBcpSYsemYYnwQsnnxr19kloHFgl1pRShyliSJk7F1OSAsKXrwEbrq4liKGq6zHt4NXIAPsPwbiRKacbcUK(STNe1OOYseyFKAAxQSXrAWuzpro)IJ0G5LBIuzZnrEt4Hv2tHuLAA0Gv3RS4e(zSu)SYwqYb2osdMk7MZjQXoxNACoQ1tlDKZ)uJbavBtCIAcqn5gvBt3bbDrniYarYTAFB5wT0D2Xb4PwZOwiQLbFvRWbdPbtL9aBbHDuzPSA(CmmlsUp4lMYR0hCX5OgF1oapFWZb0JquJEQQXZkBCKgmvwsUp4lMYR0hSk10OHQUxzXj8ZyP(zL9aBbHDuz95yywKCFWxmLxPp4IZrn(Q5ZXWSi5(GVykVsFWfe9IEiQ9HAPxn(QDaE(GNdOhHOg9uvJhv24inyQS4SJdWRk10C1v3RS4e(zSu)SYghPbtL9e58losdMxUjsLn3e5nHhwzlaPk10UqPQ7vwCc)mwQFwzJJ0GPYEIC(fhPbZl3ePYMBI8MWdRSLgIhPk10UCP6ELfNWpJL6Nv2dSfe2rLfheM8BvqM(0IA0tvTlPxnEvBpGD4NXfoim53dIj48oap)EWsLnosdMkBapXGpbaH4ivPM2f6QUxzJJ0GPYgWtm4ZHltWkloHFgl1pRsnTl8S6ELnosdMkBUtUfYZvzUsIhosLfNWpJL6NvPM2fEuDVYghPbtL1psEaMNa7ZwsLfNWpJL6NvPkvwhiEaE(HuDVM2LQ7v24inyQSHJt(3Zb0eWuzXj8ZyP(zvQPrx19kBCKgmvwFGizS8yYXpS8TNKNaCRNkloHFgl1pRsnnEwDVYIt4NXs9ZkBCKgmvwVaUflpga8vWqURShyliSJklm6Yd3XrwrPqw9Og9QDj9vwhiEaE(H8i4bmfsLn9vPMgpQUxzXj8ZyP(zLf4uzjOuzJJ0GPYUhWo8ZyLDpGVj8WkRa7zlkpYV58izGuzpWwqyhvwb2ZwuwYL1DqEejKvm)EfhIA8v7VAuwnb2ZwuwcDR7G8isiRy(9koe1sLsnb2ZwuwYL1baYfW3zv4GH0Grn6PQMa7zlklHU1baYfW3zv4GH0GrnkQSfKCGTJ0GPYEDOGqVEq1(E3NB1(3mQfZpkuJiHOMphdJAcSNTOO2xuTVXiQja1crqphrnbOg53Cu7Bl3QTH4uqrIvLDpYCyL9svQPL(Q7vwCc)mwQFwzbovwckv24inyQS7bSd)mwz3JmhwzPRYEGTGWoQScSNTOSe6w3b5rKqwX87vCiQXxT)Qrz1eypBrzjxw3b5rKqwX87vCiQLkLAcSNTOSe6whaixaFNvHdgsdg1Oxnb2ZwuwYL1baYfW3zv4GH0GrnkQS7b8nHhwzfypBr5r(nNhjdKQutZvuDVYghPbtLLiyKL7kloHFgl1pRsnnAWQ7vwCc)mwQFwzJJ0GPYsY9bFXuEL(Gv2dSfe2rLfImqKCh(zSY6aXdWZpKhbpGPqQSxQsvQSLgIhP6EnTlv3RS4e(zSu)SYwqYb2osdMkB6o74a8ule14bVQ9p98Q23wUv76yPqTnT5l12GEEyPdbZ)udmQrhVQjbmbfIlQ9TLB12qCkOiHlQbGQ9TLB1C)txudi3i8Btq1(gTOgdaQgb4HQHdct(TuJgNja1(gTOwZOw66gjrTdWZhOwtu7a86jrnoNvL9aBbHDuzrgg8i9o(oapFWZb0JquJEQQXd14vnjY4iRcIoi8reyirc6TWj8Zyrn(Q9xTc6ZXWS2XPGIeloh1sLsTc6ZXWSi39(IZrTuPuRG(CmmlMCKG5CinywCoQLkLA4GWKFRcY0Nwu7dQQrx6vJx12dyh(zCHdct(9GycoVdWZVhSOwQuQrz12dyh(zCr6jjJpjGjOOgfQXxT)Qrz1KiJJSq3iXKW1ti4cNWpJf1sLsTdaKlGVZcDJetcxpHGli6f9quJE1OtnkQSXrAWuzXzhhGxvQPrx19kloHFgl1pRSaNklbLkBCKgmv29a2HFgRS7rMdRShGNp45a6riRcY0NwuJE1UOwQuQHdct(TkitFArTpOQgDPxnEvBpGD4NXfoim53dIj48oap)EWIAPsPgLvBpGD4NXfPNKm(KaMGsLDpGVj8WklhbFmDoJWQutJNv3RS4e(zSu)SYghPbtLLGqyiy55dg8rC6TyL9aBbHDuz9cIGWxqibH0ZdIErpe1OQgLuJVA)vZNJHzrY9bFXuEL(Gloh14RgLvRaKfbHWqWYZhm4J40BXxbilPpB7jrTuPuZhqiQXxnMo5wEq0l6HO2huvl9QLkLAhaixaFNfbHWqWYZhm4J40BX15oGji5XaJJ0GjYQrpv1OBrdME1sLsncGl73tzLXO88)9q3cpNmUWj8Zyrn(Qrz185yywzmkp)Fp0TWZjJloh1OOYE(DY4tcyckKAAxQsnnEuDVYIt4NXs9ZkBbjhy7inyQS0WXOgGrnx1P3rIAHO2fxnVQrK4SLOgGrnAa7sbh1(mhfKOgaQwKe9qe14bVQjbmbfYQYEGTGWoQS7bSd)mU4i4JPZzeQgF1(RMphdZ6UlfCE(5OGKfrIZw1ONQAxC1QLkLA)vJYQ5aBaSLFpiqcPbJA8vJ4G58tcyckKftmpaZB707irn6PQgpuJx1icgz5glliiHdvJc1OOYghPbtLLjMhG5TD6DKuLAAPV6ELfNWpJL6Nv24inyQSmX8amVTtVJKk753jJpjGjOqQPDPYEGTGWoQS7bSd)mU4i4JPZzeQgF1ioyo)KaMGczXeZdW82o9osuJEQQXZkBbjhy7inyQS0WXOgGrnx1P3rIAcqTWXj)tTRdJs(NABoOjGrTMrTEIJ07OAGrTy(PMeWeuule14PAsatqHSQsnnxr19kloHFgl1pRShyliSJk7Ea7WpJloc(y6CgHQXxTdaKlGVZAhNcksSGOx0drn6v7cLQSXrAWuzXZnONKheDGTxmLQutJgS6ELfNWpJL6Nv2dSfe2rLDpGD4NXfhbFmDoJq14R2F18cIGWxqibH0ZdIErpe1OQgLulvk185yyw(5EkKUGloh1OOYghPbtLn885i3vPMgnu19kloHFgl1pRSXrAWuz94Kohcwzp)oz8jbmbfsnTlv2dSfe2rLDpGD4NXfhbFmDoJq14RgXbZ5NeWeuilMyEaM32P3rIAuvJUkBbjhy7inyQSUh(B0vYjDoeunbOw44K)P21Hrj)tTnh0eWOwiQrNAsatqHuLAAU6Q7vwCc)mwQFwzpWwqyhv29a2HFgxCe8X05mcRSXrAWuz94KohcwLQuzpfs19AAxQUxzXj8ZyP(zLnosdMkRxa3ILhda(kyi3v2ZVtgFsatqHut7sL9aBbHDuzHrxE4ooYkkfYIZrn(Q9xnjGjOSK2dFc4vAuTpu7a88bphqpczvqM(0IA0KAxwPxTuPu7a88bphqpczvqM(0IA0tvTJZZlC7rCWPOgfv2csoW2rAWuz3GmQfLcrTaIQX54IAKPDq1KBunWGQ9TLB1YGViruZD3VULAUkrq1(EJJALF9KOgtqeeQMChJABAZvRGm9Pf1aq1(2YnGtulMFQTPnFvLAA0vDVYIt4NXs9ZkBbjhy7inyQSBqg1gGArPqu7BNZQvAuTVTC3JAYnQ2GUjQXtkrCrnocQMRK56udmQ5die1(2YnGtulMFQTPnFvzpWwqyhvwy0LhUJJSIsHS6rn6vJNusTnQgm6Yd3XrwrPqwfoyinyuJVAhGNp45a6riRcY0NwuJEQQDCEEHBpIdoLkBCKgmvwVaUflpga8vWqURsnnEwDVYIt4NXs9ZkBbjhy7inyQSS)MJA0W5ibZ5qAWO23wUvBdXPGIeQfe1YGjrTGO2xuTVGX1IAzabvlu7eernWocvtUr1y6KBrTchmKgmv2dSfe2rLLYQremYYnwwqqchQgF1(R2baYfW3zTJtbfjwq0l6HO2hQXt14RgYWGhP3X3b45dEoGEeIA0tvnEOgF1KaMGYsAp8jGxPr1OxTlusTuPuRG(CmmRDCkOiXIZrTuPuZhqiQXxnMo5wEq0l6HO2hQrhpuJIkBCKgmvwMCKG5CinyQsnnEuDVYIt4NXs9Zk7b2cc7OYsz1icgz5glliiHdvJVAiddEKEhFhGNp45a6riQrpv14HA8v7VAmzaaQ2F1(RgtNClpi6f9quBJQrhpuJc1UsT4inyEhaixaFh1Oqn6vJjdaq1(R2F1y6KB5brVOhIABun64HABuTdaKlGVZAhNcksSGOx0drnAsT9a2HFgx74uqrI3PavJc1UsT4inyEhaixaFh1OqnkQSXrAWuzzYrcMZH0GPk10sF19kloHFgl1pRSfKCGTJ0GPYY(BoQXIoKMO23wUvBdXPGIeQfe1YGjrTGO2xuTVGX1IAzabvlu7eernWocvtUr1y6KBrTchmKgmUOMpNOMdezqOAsatqHOMChIAF7CwTCVJQfIAzmiIAxOePYEGTGWoQSuwnIGrwUXYccs4q14R2F1oaqUa(oRDCkOiXcIErpe1(qTlQXxnjGjOSK2dFc4vAun6v7cLulvk1kOphdZAhNcksS4Culvk1y6KB5brVOhIAFO2fkPgfv24inyQSe0H0KQutZvuDVYIt4NXs9Zk7b2cc7OYsz1icgz5glliiHdvJVA)vJjdaq1(R2F1y6KB5brVOhIABuTlusnku7k1IJ0G5DaGCb8DuJc1OxnMmaav7VA)vJPtULhe9IEiQTr1Uqj12OAhaixaFN1oofuKybrVOhIA0KA7bSd)mU2XPGIeVtbQgfQDLAXrAW8oaqUa(oQrHAuuzJJ0GPYsqhstQsnnAWQ7vwCc)mwQFwzbovwckv24inyQS7bSd)mwz3JmhwzPSAsKXrwtNClejYBr4cNWpJf1sLsnkRMezCKf6gjMeUEcbx4e(zSOwQuQDaGCb8DwOBKys46jeCbrVOhIAFOw6vBJQrNA0KAsKXrwfeDq4JiWqIe0BHt4NXsLTGKdSDKgmvw2FZrTneNcksO23EkGVQ9TLB1sRtUfIe5TiK301nsmjC9ecQwZOw44K7t4NXk7EaFt4Hv2DCkOiXB6KBHirElcFhWuAPbtvQPrdvDVYIt4NXs9ZklWPYsqPYghPbtLDpGD4NXk7EaFt4Hv2DCkOiX7a2Xjg5DatPLgmv2dSfe2rL9a2XjgzT9hSJrTuPu7a2Xjgzn4bcYayrTuPu7a2XjgznGbRSfKCGTJ0GPYY(BoQTH4uqrc1(2YTA0W5ibZ5qAWOwmf1yrhstuliQLbtIAbrTVOAFbJRf1YacQwO2jiIAGDeQMCJQX0j3IAfoyinyQS7rMdRSxQsnnxD19kloHFgl1pRSaNklbLkBCKgmv29a2HFgRS7rMdRSmzaaQ2F1(RgtNClpi6f9quBJQrhLuJc1UsT)QDHokPgnP2Ea7WpJRDCkOiX7uGQrHAuOg9QXKbaOA)v7VAmDYT8GOx0drTnQgDusTnQ2baYfW3zXKJemNdPbZcIErpe1OqTRu7VAxOJsQrtQThWo8Z4AhNcks8ofOAuOgfQLkLA(CmmlMCKG5CinyE(Cmmloh1sLsTc6ZXWSyYrcMZH0GzX5OwQuQX0j3YdIErpe1(qn6OuL9aBbHDuzpGDCIrw74i3)Gv29a(MWdRS74uqrI3bSJtmY7aMslnyQsnTluQ6ELfNWpJL6NvwGtLLGsLnosdMk7Ea7WpJv29iZHvwMmaav7VA)vJPtULhe9IEiQTr1OJsQrHAxP2F1UqhLuJMuBpGD4NX1oofuK4Dkq1OqnkuJE1yYaauT)Q9xnMo5wEq0l6HO2gvJokP2gv7aa5c47SiOdPjli6f9quJc1UsT)QDHokPgnP2Ea7WpJRDCkOiX7uGQrHAuOwQuQvaYIGoKMSK(STNe1sLsnMo5wEq0l6HO2hQrhLQShyliSJk7bSJtmYA6KB5XeyLDpGVj8Wk7oofuK4Da74eJ8oGP0sdMQut7YLQ7vwCc)mwQFwzpWwqyhvwkRgrWil3yzbbjCOA8vRaKfKZr4G4s6Z2EsuJVAuwTc6ZXWS2XPGIeloh14R2Ea7WpJRDCkOiXB6KBHirElcFhWuAPbJA8vBpGD4NX1oofuK4Da74eJ8oGP0sdMkBCKgmv2DCkOirvQPDHUQ7vwCc)mwQFwzli5aBhPbtLnDDJetcxpHGQ99gh1gGOgrWil3yrTykQ5dKB1shohHdIQftrTRpGqGGQfqunoh1yaq1YGjrnCaCj3Rk7b2cc7OYsz1icgz5glliiHdvJVA)vJYQvaYkjGqGGliYarYD4Nr14RwbiliNJWbXfe9IEiQrVA8qnEvJhQrtQDCEEHBpIdof1sLsTcqwqohHdIli6f9quJMuJsR0Rg9QjbmbLL0E4taVsJQrHA8vtcycklP9WNaELgvJE14rLnosdMkl6gjMeUEcbRsnTl8S6ELfNWpJL6Nv2csoW2rAWuzzV7D1Ag1(IQfquTWhWjQja1s3zhhGNlQftrTqe0ZrutaQr(nh1(2YTASOdPjQX0tKv7Uf1Ag1(IQ9fmUwu7BqeunpaevtUJrT7iZOMCJQDaGCb8Dwv2dSfe2rLTaKfKZr4G4s6Z2EsuJVA)vJYQDaGCb8Dwe0H0KfeJYp1sLsTdaKlGVZAhNcksSGOx0drn6v7cDQrHAPsPwbilc6qAYs6Z2EsQSXrAWuzj39EvQPDHhv3RS4e(zSu)SYEGTGWoQS(Cmml)mauYCezbX4iQLkLA(acrn(QX0j3YdIErpe1(qnEsj1sLsTc6ZXWS2XPGIeloNkBCKgmvwhG0GPk10UK(Q7vwCc)mwQFwzpWwqyhv2c6ZXWS2XPGIeloNkBCKgmvw)mauEmCWFvPM2fxr19kloHFgl1pRShyliSJkBb95yyw74uqrIfNtLnosdMkRpcjiCBpjvPM2fAWQ7vwCc)mwQFwzpWwqyhv2c6ZXWS2XPGIeloNkBCKgmvwMgI(zaOuLAAxOHQUxzXj8ZyP(zL9aBbHDuzlOphdZAhNcksS4CQSXrAWuzJ5Gebg53jY5Qut7IRU6ELfNWpJL6Nv2dSfe2rLLYQremYYnwwroRgF18cIGWxqibH0ZdIErpe1OQgLQSXrAWuzpro)IJ0G5LBIuzZnrEt4Hv29yAYDvQPrhLQUxzXj8ZyP(zLTGKdSDKgmvw2FZrn5gvZb2ayl)uJiHOMphdJAcSNTOO23wUvBdXPGIeUOgqUr43MGQXrq1aJAhaixaFNk7b2cc7OYUhWo8Z4sG9SfLh53CEKmquJQAxuJVA)vRG(CmmRDCkOiXIZrTuPuZhqiQXxnMo5wEq0l6HO2huvJokPgfQLkLA)vBpGD4NXLa7zlkpYV58izGOgv1Otn(Qrz1eypBrzj0ToaqUa(oligLFQrHAPsPgLvBpGD4NXLa7zlkpYV58izGuzJJ0GPYkWE2IYLQutJUlv3RS4e(zSu)SYEGTGWoQS7bSd)mUeypBr5r(nNhjde1OQgDQXxT)QvqFogM1oofuKyX5OwQuQ5die14RgtNClpi6f9qu7dQQrhLuJc1sLsT)QThWo8Z4sG9SfLh53CEKmquJQAxuJVAuwnb2ZwuwYL1baYfW3zbXO8tnkulvk1OSA7bSd)mUeypBr5r(nNhjdKkBCKgmvwb2ZwuORkvPYwas19AAxQUxzXj8ZyP(zLf4uzjOuzJJ0GPYUhWo8ZyLDpYCyL1b2ayl)EqGesdg14RgXbZ5NeWeuilMyEaM32P3rIA0RgpvJVA)vRaKvsaHabxq0l6HO2hQDaGCb8DwjbeceCv4GH0GrTuPuZb0eWGLNFgXcrn6vl9QrrLTGKdSDKgmv2nR9ArTRpGqGGe1aJAdy2OdS9Gb8NAsatqHOgdaQMCJQ5aBaSLFQbbsinyuRzul98QMFgXcrTaIQfzigLFQX5uz3d4BcpSYs22oVZVtgFjbeceSk10OR6ELfNWpJL6NvwGtLLGsLnosdMk7Ea7WpJv29iZHvwhydGT87bbsinyuJVAehmNFsatqHSyI5byEBNEhjQrVA8un(Q9xTc6ZXWSi39(IZrTuPuZb0eWGLNFgXcrn6vl9QrrLTGKdSDKgmv2nR9ArT0HZr4GirnWO2aMn6aBpya)PMeWeuiQXaGQj3OAoWgaB5NAqGesdg1Ag1spVQ5NrSqulGOArgIr5NACov29a(MWdRSKTTZ787KXhKZr4GyvQPXZQ7vwCc)mwQFwzbovwckv24inyQS7bSd)mwz3JmhwzlOphdZAhNcksS4CuJVA)vRG(CmmlYDVV4Culvk18cIGWxqibH0ZdIErpe1OxnkPgfQXxTcqwqohHdIli6f9quJE1ORYwqYb2osdMk7M1ETOw6W5iCqKOwZO2gItbfj4L9U3VYvgebHQrJjKGq6rTMOgNJAXuu7lQ2DSJQrhVQrWdyke1YiJOgyutUr1shohHdIQDDa3RS7b8nHhwzjBBNhKZr4GyvQPXJQ7vwCc)mwQFwzli5aBhPbtLL1bpDKv76dieiOAXuulD4CeoiQgbfoh1CGnaQMaulDDJetcxpHGQDcIuzpWwqyhvwjY4il0nsmjC9ecUWj8Zyrn(Qrz1kOphdZkjGqGGl0nsmjC9ecwuJVAfGSsciei4YXJllTtUrOAFqvTlQXxTdaKlGVZcDJetcxpHGli6f9qu7d1Otn(QrCWC(jbmbfYIjMhG5TD6DKOgv1UOgF1GrxE4ooYkkfYQh1OxnxHA8vRaKvsaHabxq0l6HOgnPgLwPxTputcycklP9WNaELgRSXrAWuztcieiyvQPL(Q7vwCc)mwQFwzpWwqyhvwjY4il0nsmjC9ecUWj8Zyrn(Q9xnKHbpsVJVdWZh8Ca9ie1ONQAhNNx42J4Gtrn(QDaGCb8DwOBKys46jeCbrVOhIAFO2f14RwbiliNJWbXfe9IEiQrtQrPv6v7d1KaMGYsAp8jGxPr1OOYghPbtLfY5iCqSk10Cfv3RS4e(zSu)SYwqYb2osdMk71hqiqq14C2IOJlQfzcqnb2irnbOghbvRf1cIAHAeh80rwTeCqyiaOAmaOAYnQwoiIABAZvZhzaquTqnMEAYncRSma4Bq3KAAxQSXrAWuzDaG8dIeah8GvPMgny19kloHFgl1pRShyliSJklezGi5o8ZOA8v7a88bphqpczvqM(0IA0tvTlQXxT)Q54XLL2j3iuTpOQ2f1sLsni6f9qu7dQQj9z7tApun(QrCWC(jbmbfYIjMhG5TD6DKOg9uvJNQrHA8v7VAuwn0nsmjC9ecwulvk1GOx0drTpOQM0NTpP9q1Oj1Otn(QrCWC(jbmbfYIjMhG5TD6DKOg9uvJNQrHA8v7VAsatqzjTh(eWR0OABuni6f9quJc1OxnEOgF18cIGWxqibH0ZdIErpe1OQgLQSXrAWuztcieiyvQPrdvDVYIt4NXs9Zklda(g0nPM2LkBCKgmvwhai)GibWbpyvQP5QRUxzXj8ZyP(zLnosdMkBsaHabRShyliSJklLvBpGD4NXfzB78o)oz8Leqiqq14RgezGi5o8ZOA8v7a88bphqpczvqM(0IA0tvTlQXxT)Q54XLL2j3iuTpOQ2f1sLsni6f9qu7dQQj9z7tApun(QrCWC(jbmbfYIjMhG5TD6DKOg9uvJNQrHA8v7VAuwn0nsmjC9ecwulvk1GOx0drTpOQM0NTpP9q1Oj1Otn(QrCWC(jbmbfYIjMhG5TD6DKOg9uvJNQrHA8v7VAsatqzjTh(eWR0OABuni6f9quJc1OxTl0PgF18cIGWxqibH0ZdIErpe1OQgLQSNFNm(KaMGcPM2LQut7cLQUxzXj8ZyP(zLTGKdSDKgmv2nbBpcyuZD0ZbjIAGrnpUS0ozunjGjOqule14bVQTPnxTV34OgKBMEsudWjQ1JA0ru7pNJAcqnEOMeWeuiuOgaQgpjQ9p98QMeWeuiuuzpWwqyhvwIdMZpjGjOquJEQQrNA8vdIErpe1(qn6uJx1(RgXbZ5NeWeuiQrpv1sVAuOgF1qgg8i9o(oapFWZb0JquJEQQXJkBCKgmv2dS9iG5jONdsKQut7YLQ7vwCc)mwQFwzli5aBhPbtL1vfrh14CulD4CeoiQwiQXdEvdmQf5SAsatqHO2)V34OwU37jrTmysudhaxYTAXuuBaIAKjCi3aHIk7b2cc7OYsz12dyh(zCr22opiNJWbr14R2F1qgg8i9o(oapFWZb0JquJEQQXd14RgezGi5o8ZOAPsPgLvt6Z2EsuJVA)vtApun6v7cLulvk1oapFWZb0JquJEQQrNAuOgfQXxT)Q54XLL2j3iuTpOQ2f1sLsni6f9qu7dQQj9z7tApun(QrCWC(jbmbfYIjMhG5TD6DKOg9uvJNQrHA8v7VAuwn0nsmjC9ecwulvk1GOx0drTpOQM0NTpP9q1Oj1Otn(QrCWC(jbmbfYIjMhG5TD6DKOg9uvJNQrHA8vtcycklP9WNaELgvBJQbrVOhIA0RgpQSXrAWuzHCocheRsnTl0vDVYIt4NXs9ZkBCKgmvwiNJWbXk7b2cc7OYsz12dyh(zCr22oVZVtgFqohHdIQXxnkR2Ea7WpJlY225b5CeoiQgF1qgg8i9o(oapFWZb0JquJEQQXd14RgezGi5o8ZOA8v7VAoECzPDYncv7dQQDrTuPudIErpe1(GQAsF2(K2dvJVAehmNFsatqHSyI5byEBNEhjQrpv14PAuOgF1(RgLvdDJetcxpHGf1sLsni6f9qu7dQQj9z7tApunAsn6uJVAehmNFsatqHSyI5byEBNEhjQrpv14PAuOgF1KaMGYsAp8jGxPr12OAq0l6HOg9Q9xnEOgVQb5gKbatWvji39K8iha3uGyEHt4NXIA0KAUA14vni3GmaycUkaGNFok4cNWpJf1Oj1CfQrrL987KXNeWeui10UuLAAx4z19kloHFgl1pRSfKCGTJ0GPYUjy7raJAUJEoirudmQX6UAnJA9OMtmf0RpQftrTbdy(NAEHBQHdct(Pwmf1Ag1s3zhhGNAFbJRf1ka18aquTs4fjOAfounbOM7FELRKgxzpWwqyhvwIdMZpjGjOquJQAxuJVAiddEKEhFhGNp45a6riQrpv1(R2X55fU9io4uuBJQDrnkuJVAqKbIK7WpJQXxnkRg6gjMeUEcblQXxnkRwb95yywK7EFX5OgF18cIGWxqibH0ZdIErpe1OQgLuJVA)vdheM8BvqM(0IAFqvn6sVA8Q2Ea7WpJlCqyYVhetW5DaE(9Gf1Oqn(QjbmbLL0E4taVsJQTr1GOx0drn6vJhv24inyQShy7raZtqphKivPkvPYUJqsdMAA0rj6UqjEEHsv2VbC6jHuzPbsJtN02GPD90SAQ5(nQw75aGIAmaOAUEpMMC7A1GORcUgIf1iapuTGtaEHGf1o3XKGKLs7M1dQ2fAwTnbMDekyrnxd5gKbatWfnY1Qja1CnKBqgambx0OfoHFglUwT)05gflL2nRhunxbnR2MaZocfSOMRHCdYaGj4Ig5A1eGAUgYnidaMGlA0cNWpJfxR2)lUrXsPvPLginoDsBdM21tZQPM73OATNdakQXaGQ56cYeCzX1QbrxfCnelQraEOAbNa8cblQDUJjbjlL2nRhunEsZQTjWSJqblQX2EBsnYVrc3uBdOMauBZ4c1k9EtAWOgWbHHaGQ9)kku7)f3OyP0Q0sdKgNoPTbt76Pz1uZ9BuT2Zbaf1yaq1CTdepap)qCTAq0vbxdXIAeGhQwWjaVqWIAN7ysqYsPDZ6bvJh0SABcm7iuWIAUwG9SfL1LfnY1Qja1CTa7zlkl5YIg5A1(tNBuSuA3SEq14bnR2MaZocfSOMRfypBrzr3Ig5A1eGAUwG9SfLLq3Ig5A1(tNBuSuA3SEq1spnR2MaZocfSOMRfypBrzDzrJCTAcqnxlWE2IYsUSOrUwT)05gflL2nRhuT0tZQTjWSJqblQ5Ab2Zwuw0TOrUwnbOMRfypBrzj0TOrUwT)05gflLwLwAG040jTnyAxpnRMAUFJQ1EoaOOgdaQMRpfIRvdIUk4AiwuJa8q1cob4fcwu7ChtcswkTBwpOA8GMvBtGzhHcwuJT92KAKFJeUP2gqnbO2MXfQv69M0GrnGdcdbav7)vuO2F6CJILs7M1dQMRGMvBtGzhHcwuJT92KAKFJeUP2gqnbO2MXfQv69M0GrnGdcdbav7)vuO2F6CJILs7M1dQMRMMvBtGzhHcwuJT92KAKFJeUP2gqnbO2MXfQv69M0GrnGdcdbav7)vuO2F6CJILs7M1dQ2fkrZQTjWSJqblQX2EBsnYVrc3uBdOMauBZ4c1k9EtAWOgWbHHaGQ9)kku7pDUrXsPDZ6bvJokrZQTjWSJqblQ5Ab2Zwuw0TOrUwnbOMRfypBrzj0TOrUwT)xCJILs7M1dQgDxOz12ey2rOGf1CTa7zlkRllAKRvtaQ5Ab2ZwuwYLfnY1Q9)IBuSuAD)gvJbKZGV9KOwWbdIAFriQghblQ1JAYnQwCKgmQLBIOMpNO2xeIQnarnga3uuRh1KBuTOuaJALqc)GG0SsRABunMCKG5CinyE(CmmkTkT0aPXPtABW0UEAwn1C)gvR9CaqrngaunxxaIRvdIUk4AiwuJa8q1cob4fcwu7ChtcswkTBwpOA8GMvBtGzhHcwuZ1OBKys46jeSSOrUwnbOMRlOphdZIgTq3iXKW1tiyX1Q9)IBuSuA3SEq1UqhnR2MaZocfSOMRHCdYaGj4Ig5A1eGAUgYnidaMGlA0cNWpJfxR2F6CJILsRsR73OAUMJGVwqpIRvlosdg1(ge1gGOgdGBkQ1JAYDtuR9CaqzP0Ub9CaqblQrdQwCKgmQLBIqwkTvwhiGPZyL9AxtnAmHeespH0GrT0bKWHkTx7AQ5kd45wTl0qUOgDuIUlkTkTx7AQLUUHhoblQ5JmaiQ2b45hIA(yspKLA04ZbDeIAdy24Da9y4YQfhPbdrnWK)TuAJJ0GHSCG4b45hc1WXj)75aAcyuAJJ0GHSCG4b45hcVuVYhisglpMC8dlF7j5ja36rPnosdgYYbIhGNFi8s9kVaUflpga8vWqUDXbIhGNFipcEatHqn9U0muHrxE4ooYkkfYQh6VKEL2RP21Hcc96bv77DFUv7FZOwm)OqnIeIA(CmmQjWE2IIAFr1(gJOMauleb9Ce1eGAKFZrTVTCR2gItbfjwkTXrAWqwoq8a88dHxQxThWo8ZOlt4HufypBr5r(nNhjdex2Jmhs9Ilndvb2Zwuwxw3b5rKqwX87vCi8)tzb2Zwuw0TUdYJiHSI53R4qsLsG9SfL1L1baYfW3zv4GH0GHEQcSNTOSOBDaGCb8DwfoyinyOqPnosdgYYbIhGNFi8s9Q9a2HFgDzcpKQa7zlkpYV58izG4YEK5qQ05sZqvG9SfLfDR7G8isiRy(9koe()PSa7zlkRlR7G8isiRy(9koKuPeypBrzr36aa5c47SkCWqAWqVa7zlkRlRdaKlGVZQWbdPbdfkTXrAWqwoq8a88dHxQxremYYTsBCKgmKLdepap)q4L6vKCFWxmLxPpOloq8a88d5rWdykeQxCPzOcrgisUd)mQ0Q0ETRPw66gE4eSOgUJWFQjThQMCJQfhbavRjQf7rNd)mUuAJJ0GHqDBF2Q0En1shKiyKLB1Ag1Caes7Nr1(pa125Ydcd)mQgoOxJe16rTdWZpekuAJJ0GHWl1Ricgz5wPnosdgcVuVApGD4NrxMWdPIdct(9GycoVdWZVhS4YEK5qQ4GWKFliMGdVoGMagS88Ziwi0en0g4pD0eXbZ53DqeKcL24inyi8s9Q9a2HFgDzcpKkPNKm(KaMGIl7rMdPsCWC(jbmbfYIjMhG5TD6DK8bDkTXrAWq4L6vNiNFXrAW8YnrCzcpKkrWil3yXfIa7Jq9IlndvIGrwUXYccs4qL24inyi8s9QtKZV4inyE5MiUmHhs9uiUqeyFeQxCXLMH6Fklrghz5febHVGqccPNfoHFglPsvaYkjGqGGlPpB7jHcL2RP2MZjQXoxNACoQ1tlDKZ)uJbavBtCIAcqn5gvBt3bbDrniYarYTAFB5wT0D2Xb4PwZOwiQLbFvRWbdPbJsBCKgmeEPEfj3h8ft5v6d6sZqLY(CmmlsUp4lMYR0hCX5W)a88bphqpcHEQ8uPnosdgcVuVcNDCaEU0mu95yywKCFWxmLxPp4IZHVphdZIK7d(IP8k9bxq0l6H8r65FaE(GNdOhHqpvEO0ghPbdHxQxDIC(fhPbZl3eXLj8qQfGO0ghPbdHxQxDIC(fhPbZl3eXLj8qQLgIhrPnosdgcVuVkGNyWNaGqCexAgQ4GWKFRcY0NwON6L0Z7Ea7WpJlCqyYVhetW5DaE(9GfL24inyi8s9QaEIbFoCzcQ0ghPbdHxQxL7KBH8CvMRK4HJO0ghPbdHxQx5hjpaZtG9zlrPvP9AxtTnba5c47quAVMABqg1IsHOwar14CCrnY0oOAYnQgyq1(2YTAzWxKiQ5U7x3snxLiOAFVXrTYVEsuJjiccvtUJrTnT5QvqM(0IAaOAFB5gWjQfZp120MVuAJJ0GHSofcVuVYlGBXYJbaFfmKBxo)oz8jbmbfc1lU0muHrxE4ooYkkfYIZH)FjGjOSK2dFc4vA8JdWZh8Ca9iKvbz6tl00Lv6tL6a88bphqpczvqM(0c9upopVWThXbNcfkTxtTniJAdqTOuiQ9TZz1knQ23wU7rn5gvBq3e14jLiUOghbvZvYCDQbg18beIAFB5gWjQfZp120MVuAJJ0GHSofcVuVYlGBXYJbaFfmKBxAgQWOlpChhzfLcz1d98KsBegD5H74iROuiRchmKgm8papFWZb0JqwfKPpTqp1JZZlC7rCWPO0En1y)nh1OHZrcMZH0GrTVTCR2gItbfjuliQLbtIAbrTVOAFbJRf1YacQwO2jiIAGDeQMCJQX0j3IAfoyinyuAJJ0GHSofcVuVIjhjyohsdgxAgQuMiyKLBSSGGeoK))daKlGVZAhNcksSGOx0d5dEYhzyWJ0747a88bphqpcHEQ8GVeWeuws7Hpb8kns)fkLkvb95yyw74uqrIfNtQu(acHptNClpi6f9q(GoEqHsBCKgmK1Pq4L6vm5ibZ5qAW4sZqLYebJSCJLfeKWH8rgg8i9o(oapFWZb0JqONkp4)NjdaW))z6KB5brVOhYgPJhuSboaqUa(ouqptgaG))Z0j3YdIErpKnshp24baYfW3zTJtbfjwq0l6Hqt7bSd)mU2XPGIeVtbsXg4aa5c47qbfkTxtn2FZrnw0H0e1(2YTABiofuKqTGOwgmjQfe1(IQ9fmUwuldiOAHANGiQb2rOAYnQgtNClQv4GH0GXf185e1CGidcvtcycke1K7qu7BNZQL7DuTqulJbru7cLikTXrAWqwNcHxQxrqhstCPzOszIGrwUXYccs4q()paqUa(oRDCkOiXcIErpKpUWxcycklP9WNaELgP)cLsLQG(CmmRDCkOiXIZjvkMo5wEq0l6H8XfkrHsBCKgmK1Pq4L6ve0H0exAgQuMiyKLBSSGGeoK)FMmaa))NPtULhe9IEiB8cLOydCaGCb8DOGEMmaa))NPtULhe9IEiB8cL24baYfW3zTJtbfjwq0l6Hqt7bSd)mU2XPGIeVtbsXg4aa5c47qbfkTxtn2FZrTneNcksO23EkGVQ9TLB1sRtUfIe5TiK301nsmjC9ecQwZOw44K7t4NrL24inyiRtHWl1R2dyh(z0Lj8qQ74uqrI30j3crI8we(oGP0sdgx2JmhsLYsKXrwtNClejYBr4cNWpJLuPOSezCKf6gjMeUEcbx4e(zSKk1baYfW3zHUrIjHRNqWfe9IEiFK(nshnjrghzvq0bHpIadjsqVfoHFglkTxtn2FZrTneNcksO23wUvJgohjyohsdg1IPOgl6qAIAbrTmysuliQ9fv7lyCTOwgqq1c1obrudSJq1KBunMo5wuRWbdPbJsBCKgmK1Pq4L6v7bSd)m6YeEi1DCkOiX7a2Xjg5DatPLgmU0mupGDCIrwB)b7ysL6a2Xjgzn4bcYayjvQdyhNyK1ag0L9iZHuVO0ghPbdzDkeEPE1Ea7WpJUmHhsDhNcks8oGDCIrEhWuAPbJlnd1dyhNyK1ooY9pOl7rMdPYKba4))mDYT8GOx0dzJ0rjk2a)VqhLOP9a2HFgx74uqrI3PaPGc6zYaa8)FMo5wEq0l6HSr6O0gpaqUa(olMCKG5Cinywq0l6HqXg4)f6OenThWo8Z4AhNcks8ofifuKkLphdZIjhjyohsdMNphdZIZjvQc6ZXWSyYrcMZH0GzX5KkftNClpi6f9q(GokP0ghPbdzDkeEPE1Ea7WpJUmHhsDhNcks8oGDCIrEhWuAPbJlnd1dyhNyK10j3YJjqx2JmhsLjdaW))z6KB5brVOhYgPJsuSb(FHokrt7bSd)mU2XPGIeVtbsbf0ZKba4))mDYT8GOx0dzJ0rPnEaGCb8Dwe0H0Kfe9IEiuSb(FHokrt7bSd)mU2XPGIeVtbsbfPsvaYIGoKMSK(STNKuPy6KB5brVOhYh0rjL24inyiRtHWl1R2XPGIeU0muPmrWil3yzbbjCi)cqwqohHdIlPpB7jHpLlOphdZAhNcksS4C4VhWo8Z4AhNcks8Mo5wisK3IW3bmLwAWWFpGD4NX1oofuK4Da74eJ8oGP0sdgL2RPw66gjMeUEcbv77noQnarnIGrwUXIAXuuZhi3QLoCochevlMIAxFaHabvlGOACoQXaGQLbtIA4a4sUxkTXrAWqwNcHxQxHUrIjHRNqqxAgQuMiyKLBSSGGeoK)FkxaYkjGqGGliYarYD4Nr(fGSGCochexq0l6Hqpp4Lh00X55fU9io4usLQaKfKZr4G4cIErpeAIsR0tVeWeuws7Hpb8knsbFjGjOSK2dFc4vAKEEO0En1yV7D1Ag1(IQfquTWhWjQja1s3zhhGNlQftrTqe0ZrutaQr(nh1(2YTASOdPjQX0tKv7Uf1Ag1(IQ9fmUwu7BqeunpaevtUJrT7iZOMCJQDaGCb8DwkTXrAWqwNcHxQxrU7DxAgQfGSGCochexsF22tc))u(aa5c47SiOdPjligLFPsDaGCb8Dw74uqrIfe9IEi0FHoksLQaKfbDinzj9zBpjkTXrAWqwNcHxQx5aKgmU0mu95yyw(zaOK5iYcIXrsLYhqi8z6KB5brVOhYh8KsPsvqFogM1oofuKyX5O0ghPbdzDkeEPELFgakpgo4pxAgQf0NJHzTJtbfjwCokTXrAWqwNcHxQx5Jqcc32tIlnd1c6ZXWS2XPGIelohL24inyiRtHWl1RyAi6NbGIlnd1c6ZXWS2XPGIelohL24inyiRtHWl1RI5Gebg53jYzxAgQf0NJHzTJtbfjwCokTXrAWqwNcHxQxDIC(fhPbZl3eXLj8qQ7X0KBxAgQuMiyKLBSSICMVxqee(ccjiKEEq0l6HqLskTxtn2FZrn5gvZb2ayl)uJiHOMphdJAcSNTOO23wUvBdXPGIeUOgqUr43MGQXrq1aJAhaixaFhL24inyiRtHWl1ReypBr5Ilnd19a2HFgxcSNTO8i)MZJKbc1l8)xqFogM1oofuKyX5KkLpGq4Z0j3YdIErpKpOshLOivQ)7bSd)mUeypBr5r(nNhjdeQ0XNYcSNTOSOBDaGCb8Dwqmk)OivkkVhWo8Z4sG9SfLh53CEKmquAJJ0GHSofcVuVsG9Sff6CPzOUhWo8Z4sG9SfLh53CEKmqOsh))f0NJHzTJtbfjwCoPs5die(mDYT8GOx0d5dQ0rjksL6)Ea7WpJlb2ZwuEKFZ5rYaH6f(uwG9SfL1L1baYfW3zbXO8JIuPO8Ea7WpJlb2ZwuEKFZ5rYarPvP9AxtTRRH4ruReErcQw435wAKO0En1s3zhhGNAHOgp4vT)PNx1(2YTAxhlfQTPnFP2g0ZdlDiy(NAGrn64vnjGjOqCrTVTCR2gItbfjCrnauTVTCRM7Fsdq1aYnc)2euTVrlQXaGQraEOA4GWKFl1OXzcqTVrlQ1mQLUUrsu7a88bQ1e1oaVEsuJZzP0ghPbdzvAiEeQ4SJdWZLMHkYWGhP3X3b45dEoGEec9u5bVsKXrwfeDq4JiWqIe0BHt4NXc))f0NJHzTJtbfjwCoPsvqFogMf5U3xCoPsvqFogMftosWCoKgmloNuPWbHj)wfKPpT8bv6spV7bSd)mUWbHj)EqmbN3b453dwsLIY7bSd)mUi9KKXNeWeuOG)FklrghzHUrIjHRNqWfoHFglPsDaGCb8DwOBKys46jeCbrVOhc90rHsBCKgmKvPH4r4L6v7bSd)m6YeEivoc(y6CgHUShzoK6b45dEoGEeYQGm9Pf6VKkfoim53QGm9PLpOsx65DpGD4NXfoim53dIj48oap)EWsQuuEpGD4NXfPNKm(KaMGIsBCKgmKvPH4r4L6veecdblpFWGpItVfD587KXNeWeuiuV4sZq1liccFbHeesppi6f9qOsj()95yywKCFWxmLxPp4IZHpLlazrqimeS88bd(io9w8vaYs6Z2EssLYhqi8z6KB5brVOhYhutFQuhaixaFNfbHWqWYZhm4J40BX15oGji5XaJJ0GjY0tLUfny6tLIa4Y(9uwzmkp)Fp0TWZjJlCc)mw4tzFogMvgJYZ)3dDl8CY4IZHcL2RPgnCmQbyuZvD6DKOwiQDXvZRAejoBjQbyuJgWUuWrTpZrbjQbGQfjrpernEWRAsatqHSuAJJ0GHSknepcVuVIjMhG5TD6DK4sZqDpGD4NXfhbFmDoJq()95yyw3DPGZZphfKSisC2sp1lU6uP(tzhydGT87bbsiny4tCWC(jbmbfYIjMhG5TD6DKqpvEWlrWil3yzbbjCifuO0En1OHJrnaJAUQtVJe1eGAHJt(NAxhgL8p12CqtaJAnJA9ehP3r1aJAX8tnjGjOOwiQXt1KaMGczP0ghPbdzvAiEeEPEftmpaZB707iXLZVtgFsatqHq9Ilnd19a2HFgxCe8X05mc5tCWC(jbmbfYIjMhG5TD6DKqpvEQ0ghPbdzvAiEeEPEfEUb9K8GOdS9IP4sZqDpGD4NXfhbFmDoJq(haixaFN1oofuKybrVOhc9xOKsBCKgmKvPH4r4L6vHNph52LMH6Ea7WpJloc(y6CgH8)7febHVGqccPNhe9IEiuPuQu(Cmml)CpfsxWfNdfkTxtn3d)n6k5KohcQMaulCCY)u76WOK)P2MdAcyule1OtnjGjOquAJJ0GHSknepcVuVYJt6CiOlNFNm(KaMGcH6fxAgQ7bSd)mU4i4JPZzeYN4G58tcyckKftmpaZB707iHkDkTXrAWqwLgIhHxQx5XjDoe0LMH6Ea7WpJloc(y6CgHkTkTx7AQDDHxKGQb2rOAs7HQf(DULgjkTxtTnR9ArTRpGqGGe1aJAdy2OdS9Gb8NAsatqHOgdaQMCJQ5aBaSLFQbbsinyuRzul98QMFgXcrTaIQfzigLFQX5O0ghPbdzvac19a2HFgDzcpKkzB78o)oz8Leqiqqx2Jmhs1b2ayl)EqGesdg(ehmNFsatqHSyI5byEBNEhj0Zt()lazLeqiqWfe9IEiFCaGCb8DwjbeceCv4GH0GjvkhqtadwE(zele6tpfkTxtTnR9ArT0HZr4GirnWO2aMn6aBpya)PMeWeuiQXaGQj3OAoWgaB5NAqGesdg1Ag1spVQ5NrSqulGOArgIr5NACokTXrAWqwfGWl1R2dyh(z0Lj8qQKTTZ787KXhKZr4GOl7rMdP6aBaSLFpiqcPbdFIdMZpjGjOqwmX8amVTtVJe65j))f0NJHzrU79fNtQuoGMagS88Ziwi0NEkuAVMABw71IAPdNJWbrIAnJABiofuKGx27E)kxzqeeQgnMqccPh1AIACoQftrTVOA3XoQgD8QgbpGPqulJmIAGrn5gvlD4CeoiQ21bCxPnosdgYQaeEPE1Ea7WpJUmHhsLSTDEqohHdIUShzoKAb95yyw74uqrIfNd))f0NJHzrU79fNtQuEbrq4liKGq65brVOhc9uIc(fGSGCochexq0l6HqpDkTxtnwh80rwTRpGqGGQftrT0HZr4GOAeu4CuZb2aOAcqT01nsmjC9ecQ2jiIsBCKgmKvbi8s9QKacbc6sZqvImoYcDJetcxpHGlCc)mw4tz0nsmjC9ecwwjbeceKFbiRKacbcUC84Ys7KBe(b1l8paqUa(ol0nsmjC9ecUGOx0d5d64tCWC(jbmbfYIjMhG5TD6DKq9cFy0LhUJJSIsHS6HExb)cqwjbeceCbrVOhcnrPv6)qcycklP9WNaELgvAJJ0GHSkaHxQxb5Ceoi6sZqvImoYcDJetcxpHGlCc)mw4)hzyWJ0747a88bphqpcHEQhNNx42J4GtH)baYfW3zHUrIjHRNqWfe9IEiFCHFbiliNJWbXfe9IEi0eLwP)djGjOSK2dFc4vAKcL2RP21hqiqq14C2IOJlQfzcqnb2irnbOghbvRf1cIAHAeh80rwTeCqyiaOAmaOAYnQwoiIABAZvZhzaquTqnMEAYncvAJJ0GHSkaHxQx5aa5hejao4bDHbaFd6Mq9IsBCKgmKvbi8s9QKacbc6sZqfImqKCh(zK)b45dEoGEeYQGm9Pf6PEH)FhpUS0o5gHFq9sQuq0l6H8bvPpBFs7H8joyo)KaMGczXeZdW82o9osONkpPG)FkJUrIjHRNqWsQuq0l6H8bvPpBFs7H0eD8joyo)KaMGczXeZdW82o9osONkpPG)FjGjOSK2dFc4vACJq0l6Hqb98GVxqee(ccjiKEEq0l6HqLskTXrAWqwfGWl1RCaG8dIeah8GUWaGVbDtOErPnosdgYQaeEPEvsaHabD587KXNeWeuiuV4sZqLY7bSd)mUiBBN353jJVKacbcYhImqKCh(zK)b45dEoGEeYQGm9Pf6PEH)FhpUS0o5gHFq9sQuq0l6H8bvPpBFs7H8joyo)KaMGczXeZdW82o9osONkpPG)FkJUrIjHRNqWsQuq0l6H8bvPpBFs7H0eD8joyo)KaMGczXeZdW82o9osONkpPG)FjGjOSK2dFc4vACJq0l6Hqb9xOJVxqee(ccjiKEEq0l6HqLskTxtTnbBpcyuZD0ZbjIAGrnpUS0ozunjGjOqule14bVQTPnxTV34OgKBMEsudWjQ1JA0ru7pNJAcqnEOMeWeuiuOgaQgpjQ9p98QMeWeuiuO0ghPbdzvacVuV6aBpcyEc65GeXLMHkXbZ5NeWeui0tLo(q0l6H8bD8(N4G58tcycke6PMEk4Jmm4r6D8DaE(GNdOhHqpvEO0En1Cvr0rnoh1shohHdIQfIA8Gx1aJAroRMeWeuiQ9)7noQL79EsuldMe1WbWLCRwmf1gGOgzchYnqOqPnosdgYQaeEPEfKZr4GOlndvkVhWo8Z4ISTDEqohHdI8)Jmm4r6D8DaE(GNdOhHqpvEWhImqKCh(zmvkkl9zBpj8)lThs)fkLk1b45dEoGEec9uPJck4)3XJllTtUr4huVKkfe9IEiFqv6Z2N0EiFIdMZpjGjOqwmX8amVTtVJe6PYtk4)NYOBKys46jeSKkfe9IEiFqv6Z2N0EinrhFIdMZpjGjOqwmX8amVTtVJe6PYtk4lbmbLL0E4taVsJBeIErpe65HsBCKgmKvbi8s9kiNJWbrxo)oz8jbmbfc1lU0muP8Ea7WpJlY225D(DY4dY5iCqKpL3dyh(zCr22opiNJWbr(iddEKEhFhGNp45a6ri0tLh8Hidej3HFg5)3XJllTtUr4huVKkfe9IEiFqv6Z2N0EiFIdMZpjGjOqwmX8amVTtVJe6PYtk4)NYOBKys46jeSKkfe9IEiFqv6Z2N0EinrhFIdMZpjGjOqwmX8amVTtVJe6PYtk4lbmbLL0E4taVsJBeIErpe6)ZdEHCdYaGj4QeK7EsEKdGBkqmttUAEHCdYaGj4QaaE(5OG0KRGcL2RP2MGThbmQ5o65GernWOgR7Q1mQ1JAoXuqV(Owmf1gmG5FQ5fUPgoim5NAXuuRzulDNDCaEQ9fmUwuRauZdar1kHxKGQv4q1eGAU)5vUsASsBCKgmKvbi8s9QdS9iG5jONdsexAgQehmNFsatqHq9cFKHbpsVJVdWZh8Ca9ie6P()488c3EehCkB8cf8Hidej3HFg5tz0nsmjC9ecw4t5c6ZXWSi39(IZHVxqee(ccjiKEEq0l6HqLs8)Jdct(TkitFA5dQ0LEE3dyh(zCHdct(9GycoVdWZVhSqbFjGjOSK2dFc4vACJq0l6HqppuAvAV21uJvWil3yrnA8rAWquAVMAP1j3ejYBrOAGrnE6onR2MGThbmQ5o65GerPnosdgYIiyKLBSq9aBpcyEc65GeXLMHQezCK10j3crI8weUWj8ZyHpXbZ5NeWeui0tLN8papFWZb0JqONkp4lbmbLL0E4taVsJBeIErpe6DfkTxtT06KBIe5TiunWO2f3Pz1yNWHCde1shohHdIkTXrAWqwebJSCJfEPEfKZr4GOlndvjY4iRPtUfIe5TiCHt4NXc)dWZh8Ca9ie6PYd(satqzjTh(eWR04gHOx0dHExHs71uJLZxqidxcsZQrJDCY)udavlDqgisUv7Bl3Q5ZXWGf1U(acbcsuAJJ0GHSicgz5gl8s9khai)GibWbpOlma4Bq3eQxuAJJ0GHSicgz5gl8s9QKacbc6Y53jJpjGjOqOEXLMHQezCKfHZxqidxcUWj8ZyH)Fi6f9q(4cDPs54XLL2j3i8dQxOGVeWeuws7Hpb8knUri6f9qONoL2RPglNVGqgUeunEvlDDJKOgyu7I70SAPdYarYTAxFaHabvle1KBunCkQbyuJiyKLB1eGAjOOMx4MAfoyinyuZhzaquT01nsmjC9ecQ0ghPbdzremYYnw4L6voaq(brcGdEqxyaW3GUjuVO0ghPbdzremYYnw4L6vjbece0LMHQezCKfHZxqidxcUWj8ZyHVezCKf6gjMeUEcbx4e(zSWposVJpCqVgjuVW3NJHzr48feYWLGli6f9q(4YINkTXrAWqwebJSCJfEPELhN05qqxAgQsKXrweoFbHmCj4cNWpJf(hGNp45a6riFqLNkTkTx7AQTHX0KBL2RPgnCpn5wTVTCRMx4MABAZvJbavlTo5wisK3IqxuJBYiHOghPNe1UomK78p1yVJc4lrPnosdgYApMMCtDpGD4NrxMWdPoDYTqKiVfHVJZ7aMslnyCzpYCi1)ugYnidaMGRcgYD(3JChfWxcFKHbpsVJVdWZh8Ca9ie6PECEEHBpIdofksL6pKBqgambxfmK78Vh5okGVe(hGNp45a6riFqhfkTxtTnmMMCR23wUvlDDJKOgVQLwNClejYBrinRMRmCR948uBtBUAXuulDDJKOgeJYp1yaq1g0nrTRFtxNsBCKgmK1Emn5MxQxThttUDPzOkrghzHUrIjHRNqWfoHFgl8LiJJSMo5wisK3IWfoHFgl83dyh(zCnDYTqKiVfHVJZ7aMslny4FaGCb8DwOBKys46jeCbrVOhYhxuAVMABymn5wTVTCRwADYTqKiVfHQXRAPbulDDJKqZQ5kd3Apop120MRwmf12qCkOiHACokTXrAWqw7X0KBEPE1Emn52LMHQezCK10j3crI8weUWj8ZyHpLLiJJSq3iXKW1ti4cNWpJf(7bSd)mUMo5wisK3IW3X5DatPLgm8lOphdZAhNcksS4CuAJJ0GHS2JPj38s9khai)GibWbpOlma4Bq3eQxCbDtGXl8aCJqLhPxPnosdgYApMMCZl1R2JPj3U0muLiJJSiC(ccz4sWfoHFgl8paqUa(oRKacbcU4C4)VaKvsaHabxqKbIK7WpJPsvqFogM1oofuKyX5WVaKvsaHabxoECzPDYnc)G6fk4FaE(GNdOhHSkitFAHEQ)joyo)KaMGczXeZdW82o9osONga8Gc(WOlpChhzfLcz1d9xOtP9AQTHX0KB1(2YTAUYGiiunAmHeKEOz1shohHdI8E9beceuTbiQ1JAqKbIKB1GXKGUOwHd2tIABiofuKGx27EFPg7V5O23wUvJfDinrnMEISA3TOwZOMdGqA)mUuAJJ0GHS2JPj38s9Q9yAYTlnd1)sKXrwEbrq4liKGq6zHt4NXsQuqUbzaWeC5fWTpaZtUXNxqee(ccjiKEOGpLlazb5CeoiUGidej3HFg5xaYkjGqGGli6f9qONN8lOphdZAhNcksS4C4)VG(CmmlYDVV4CsLQG(CmmRDCkOiXcIErpKp4rQufGSiOdPjlPpB7jHc(fGSiOdPjli6f9q(GNvwIdEQPrx6D1vPk1ka]] )

end