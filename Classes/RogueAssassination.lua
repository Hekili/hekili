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


    spec:RegisterPack( "Assassination", 20210403, [[davXhcqiKOEKOkUKOQKnrv6teeJcjCkqQvHKKxrvywevULsf2Ls(LsLggsIJPu1YiOEgrHPru01evvBdKO(gbjmoIQiNJGKwhss9ocsenpqs3Ja7JO0)iir6GevLfIe5HIQ0evQixuuvSrqc6JGezKeKO6KIQsTsKuVeKaMjrv6MevHDkQ0qbj0sjQQEkHMQOIRsqIWwji1xjQIASkvu7vs)fudMYHfwmv1JvXKL4YqBgP(mvA0QuNwQvtqIYRvknBrUTOSBf)gy4uXXbjqlxvphX0jDDISDvY3brJNQOZdcZxPy)OUUVMtvSekwZvyQi8EQitQiJ1(9urOGk5VkQq4GvrN4SnCXQ4ezyvu(iKGq6j0gmvrNaIeik1CQIeG0FWQ4TQoeQE3DDB9wYFDaz7s6mPuOnyoFqR7s6SZUvrFPoP57P6xflHI1CfMkcVNkYKkYyTFpvGYYqOwfdj9g8vrXolVvX7UuWP6xfli5ufLpcjiKEcTbdBYpWvczQLpNVtSjd5ytyQi8EMAM68EhJlsOAM6DWM854KGGnHq0VpQqyJofUSPa2iGmKn5dkkVSrd(Te2uaBK4czZ5bhKq6XLnTZWft9oyBNaJqu2e6yAYnBstcje2et9bzlMcB7uFq2GStj2sbrzlbgx8ztVJHn5rqu8zt(iKGq6zXuVd2KFmfEYguykCXuk0gmSTlBcnofu1GnceZHnkAA2eACkOQbBnHnf46MWcBaAA2apBGHTGTeyCzlV7e0RQyQjkPMtvKOyK0BSuZPM7(AovrCc)ewQuQkE(wXVJQOgjC010U3krJ0w8x4e(jSWMx2ioykbRX7IkHnzfWMmyZlBhqMpa2b0JsytwbSjt28YMgVlQlTZqyfaxAKTDW2Jzrpe2KLnOCvmoAdMQ457mcyGvmZbjAvSGKZ3oAdMQyUT7nrJ0w8zdmSjJCOA2Y73zeWWwoyMds0QwZv4AovrCc)ewQuQkE(wXVJQOgjC010U3krJ0w8x4e(jSWMx2oGmFaSdOhLWMScytMS5LnnExuxANHWkaU0iB7GThZIEiSjlBq5QyC0gmvXxYrLESkwqY5BhTbtvm329MOrAl(Sbg22NdvZM4eoKBGYM8l5Ospw1AUYOMtveNWpHLkLQI0GhEqp1AU7RIXrBWufDaGe8JeG0FWQybjNVD0gmvrrjFfFAjxKQzt(CCsqWg4zt(r6hj3SbzR3S5lrtJf2GsX)afjvTMRmR5ufXj8tyPsPQ45Bf)oQIAKWrxejFfFAjxCHt4NWcBEzJc2Eml6HWguzBVWSTzdBozsjTDsn(SbvbSTNnOzZlBA8UOU0odHvaCPr22bBpMf9qytw2eUkghTbtv0n(hOyv8aXjHWA8UOsQ5UVQ1CZFnNQioHFclvkvfPbp8GEQ1C3xfJJ2GPk6aaj4hjaP)GvXcsoF7OnyQIIs(k(0sUiBEWw(4jXLnWW2(COA2KFK(rYnBqP4FGISfkB6nYgof2a0Srums6nBkGnxuzll8KTI0hAdg28rAWJSLpEsIXvQNqXQwZfkxZPkIt4NWsLsvXZ3k(Duf1iHJUis(k(0sU4cNWpHf28YMgjC0f6jjgxPEcfx4e(jSWMx2IJ2ximoywJe2eW2E28YMVen9Ii5R4tl5IRhZIEiSbv22VKrvmoAdMQOB8pqXQwZvOOMtveNWpHLkLQINVv87OkQrchDrK8v8PLCXfoHFclS5LTdiZha7a6rjSbvbSjJQyC0gmvXmjTtHIvTQvXRyAYDnNAU7R5ufXj8tyPsPQiWPksqTkghTbtv8k(o8tyv8kssyvKc2OmBV0G0G3fxfm07eeWK7OaGKSWj8tyHnVSH004r7le(aY8bWoGEucBYkGTJdCw4jmXbNcBqZ2MnSrbBV0G0G3fxfm07eeWK7OaGKSWj8tyHnVSDaz(ayhqpkHnOYMWSbDv8kE4jYWQ40U3krJ0w8HpoWhWuATbtvSGKZ3oAdMQiuypn5MniB9MTSWt2YluKnAWZwUT7Ts0iTfF5ytAsiHWMePhx22jm07eeSjEhfaKKQwZv4AovrCc)ewQuQkE(wXVJQOgjC0f6jjgxPEcfx4e(jSWMx20iHJUM29wjAK2I)cNWpHf28Y2v8D4NW10U3krJ0w8HpoWhWuATbdBEz7aaPcaYzHEsIXvQNqX1Jzrpe2GkB7RIXrBWufVIPj3vXcsoF7OnyQIcDmn5MniB9MT8XtIlBEWwUT7Ts0iTfFQMn5r4zNjLXwEHISftHT8XtIlBpgfiyJg8SnONkBqP8UtvTMRmQ5ufXj8tyPsPQ45Bf)oQIAKWrxt7ERensBXFHt4NWcBEzJYSPrchDHEsIXvQNqXfoHFclS5LTR47WpHRPDVvIgPT4dFCGpGP0Adg28Ywb9LOPxx4uqvJLKtvmoAdMQ4vmn5UkwqY5BhTbtvuOJPj3SbzR3SLB7ERensBXNnpylxaB5JNexQMn5r4zNjLXwEHISftHnHgNcQAWMKtvR5kZAovrCc)ewQuQksdE4b9uR5UVkghTbtv0basWpsas)bRION6hWrgqA0QOmZFvR5M)AovrCc)ewQuQkE(wXVJQOgjC0frYxXNwYfx4e(jSWMx2oaqQaGCwUX)afxsoS5LnkyRa0LB8pqX1J0psUd)eY2MnSvqFjA61fofu1yj5WMx2kaD5g)duC5KjL02j14ZgufW2E2GMnVSDaz(ayhqpkzvq6(0kBYkGnkyJ4GPeSgVlQKfDmWaA4TtFHe2KvOu2KjBqZMx2(OlW4fo6kkfYQh2KLT9cxfJJ2GPkEfttURAnxOCnNQioHFclvkvfpFR43rvKc20iHJUYcIIpCqibH0ZcNWpHf22SHTxAqAW7IRS43cdOH1Beolik(WbHeesplCc)ewydA28YgLzRa01l5OspUEK(rYD4Nq28YwbOl34FGIRhZIEiSjlBYGnVSvqFjA61fofu1yj5WMx2OGTc6lrtVi391sYHTnByRG(s00RlCkOQX6XSOhcBqLnzY2MnSva6IGoKMS0(SThx2GMnVSva6IGoKMSEml6HWguztgvX4OnyQIxX0K7QybjNVD0gmvrHoMMCZgKTEZM8iik(SjFesq6HQzt(LCuPh9akf)duKTbOS1dBps)i5MTpgxuo2ksFpUSj04uqvdpeV7RfBIqmh2GS1B2erhstyJUNiX2DRS10S5aiK2pHRQw1QybPdPKwZPM7(AovX4OnyQIB7Z2QioHFclvkv1AUcxZPkIt4NWsLsvXcsoF7OnyQIYpsums6nBnnBoacP9tiBuma2UKsd(HFczdhmRrcB9W2bK5hk0vX4OnyQIefJKEx1AUYOMtveNWpHLkLQIaNQib1QyC0gmvXR47WpHvXRijHvrCW3fI1JU4WMhS5aAcyWcSFcXcHnQIn5j22Lnkyty2Ok2ioykbFhefzd6Q4v8WtKHvrCW3fc4hDXb(aY87blvTMRmR5ufXj8tyPsPQiWPksqTkghTbtv8k(o8tyv8kssyvK4GPeSgVlQKfDmWaA4TtFHe2GkBcxfVIhEImSks6XnHWA8UOw1AU5VMtveNWpHLkLQINVv87Oksums6nwwpWvcRIe97JwZDFvmoAdMQ4jsj44OnyGtnrRIPMOWtKHvrIIrsVXsvR5cLR5ufXj8tyPsPQ45Bf)oQIuWgLztJeo6klik(WbHeesplCc)ewyBZg2kaD5g)duCP9zBpUSbDvKOFF0AU7RIXrBWufprkbhhTbdCQjAvm1efEImSkEkKQwZvOOMtveNWpHLkLQINVv87Oksz28LOPxKuFq4ykWL(Gljh28Y2bK5dGDa9Oe2KvaBYOkghTbtvKK6dchtbU0hSkwqY5BhTbtvekkPSjo7eBsoS1tRDKsqWgn4zlVskBkGn9gzlV3bbLJThPFKCZgKTEZw(mx4aYyRPzlu2saizRi9H2GPQ1CLNQ5ufXj8tyPsPQ45Bf)oQI(s00lsQpiCmf4sFWLKdBEzZxIMErs9bHJPax6dUEml6HWguzl)S5LTdiZha7a6rjSjRa2KzvmoAdMQiox4aYQAnxHAnNQioHFclvkvfJJ2GPkEIucooAdg4ut0QyQjk8ezyvSa0QwZDpvQ5ufXj8tyPsPQyC0gmvXtKsWXrBWaNAIwftnrHNidRIL(XJw1AU73xZPkIt4NWsLsvXZ3k(DufXbFxiwfKUpTYMScyBF(zZd2UIVd)eUWbFxiGF0fh4diZVhSufJJ2GPkg)jgewb)JJw1AU7fUMtvmoAdMQy8NyqyhPebRI4e(jSuPuvR5Uxg1CQIXrBWuftT7TsGfktQ4MHJwfXj8tyPsPQwZDVmR5ufJJ2GPk6hUWaAy97ZwsveNWpHLkLQAvRIopEaz(HwZPM7(AovX4OnyQIHJtccyhqtatveNWpHLkLQAnxHR5ufJJ2GPk6dunHfy6uabwGShxyf4zpvrCc)ewQuQQ1CLrnNQioHFclvkvfpFR43rv8JUaJx4OROuiREytw22N)QyC0gmvXS43IfyAWdxWqVRIopEaz(HctWdykKQy(RAnxzwZPkIt4NWsLsvrGtvKGAvmoAdMQ4v8D4NWQ4v8WtKHvr97zlQWeiMdmjb0Q4vKKWQ4(QybjNVD0gmvXDcv8Z6bzdY7(CZgfnnBXab0Sr0qzZxIMMn97zlQSbjYgKXOSPa2cvXmhLnfWgbI5WgKTEZMqJtbvnwvXZ3k(Duf1VNTOU09R7Gat0qxXabCXHWMx2OGnkZM(9Sf1Lk86oiWen0vmqaxCiSTzdB63Zwux6(1basfaKZQi9H2GHnzfWM(9Sf1Lk86aaPcaYzvK(qBWWg0vTMB(R5ufXj8tyPsPQiWPksqTkghTbtv8k(o8tyv8kssyvu4Q4v8WtKHvr97zlQWeiMdmjb0Q45Bf)oQI63ZwuxQWR7Gat0qxXabCXHWMx2OGnkZM(9Sf1LUFDheyIg6kgiGloe22SHn97zlQlv41basfaKZQi9H2GHnzzt)E2I6s3VoaqQaGCwfPp0gmSbDvR5cLR5ufXj8tyPsPQ45Bf)oQIps)i5o8tyvmoAdMQij1heoMcCPpyv05XdiZpuycEatHuf3x1AUcf1CQIXrBWufjkgj9UkIt4NWsLsvTQvXs)4rR5uZDFnNQioHFclvkvfpFR43rvePPXJ2xi8bK5dGDa9Oe2KvaBYKnpytJeo6QGOd(We9dnCXSfoHFclS5LnkyRG(s00RlCkOQXsYHTnByRG(s00lYDFTKCyBZg2kOVen9IofUykfAdMLKdBB2Wgo47cXQG09Pv2GQa2eo)S5bBxX3HFcx4GVleWp6Id8bK53dwyBZg2OmBxX3HFcxKECtiSgVlQSbnBEzJc2OmBAKWrxONKyCL6juCHt4NWcBB2W2basfaKZc9KeJRupHIRhZIEiSjlBcZg0vX4OnyQI4CHdiRkwqY5BhTbtvmFMlCazSfkBY0d2Oi)EWgKTEZ2ojcnB5fkUylFNLHLoumbbBGHnH9GnnExujYXgKTEZMqJtbvnKJnWZgKTEZwouso2a6n(q2eKniJwzJg8SraziB4GVlel2KVebWgKrRS10SLpEsCz7aY8bS1e2oGSECztYzv1AUcxZPkIt4NWsLsvrGtvKGAvmoAdMQ4v8D4NWQ4vKKWQ4bK5dGDa9OKvbP7tRSjlB7zBZg2WbFxiwfKUpTYgufWMW5Nnpy7k(o8t4ch8DHa(rxCGpGm)EWcBB2WgLz7k(o8t4I0JBcH14DrTkEfp8ezyvuIGW0DkHFvR5kJAovrCc)ewQuQkE(wXVJQ4v8D4NWLebHP7ucF28YgLzRa0fb)puSa7dgeM40Br4cqxAF22JBvmoAdMQib)puSa7dgeM40BXQybjNVD0gmvr5ZXjbbBIusKnfWwKsSPX7IkHniB9giPSfSvqFjAA2ccBoFd(wHqo2CEKg)Vhx204DrLWwbIECzJaad(Sf0k(SP3iBoFNfpeSPX7IAvR5kZAovrCc)ewQuQkE(wXVJQ4v8D4NWLebHP7ucF28YgLzRa0fb)puSa7dgeM40Br4cqxAF22JBvmoAdMQib)puSa7dgeM40BXQ4bItcH14DrLuZDFvR5M)AovrCc)ewQuQkE(wXVJQ4v8D4NWLebHP7ucF28Ywwqu8HdcjiKEGFml6HWguzJkl5j28YgfSr3U3k8Jzrpe2GQa2YpBB2W2basfaKZIG)hkwG9bdctC6T46ChVlsGP)4OnyIeBYkGnHxcf5NTnByJaKs(9uwjmkW(qaJEgzojCHt4NWcBEzJYS5lrtVsyuG9Hag9mYCs4sYHnVSvqFjA61fofu1yj5Wg0vX4OnyQIe8)qXcSpyqyItVfRIfKC(2rBWufLNVXHn5H8XwtyBakBHY2D7EZwr6dTbJCSjrq2ePKiBkGTWXjbbBYlgf28HGT8XZiZjHSvK(ECztOXPGQgYXgqVXhYMGSTfrh2OFqgBNWXPhx2o3X7IKQwZfkxZPkIt4NWsLsvXZ3k(DufVIVd)eUKiimDNs4ZMx2OGnFjA61Dxk4a7NIcswenoBztwbSTxOY2MnSrbBuMnNVbFRqa)an0gmS5LnIdMsWA8UOsw0XadOH3o9fsytwbSjt28GnIIrsVXY6bUsiBqZg0vX4OnyQI0XadOH3o9fsQIfKC(2rBWufHcJHnanBqbM(cjSfkB7fQEWgrJZwcBaA2ekVlfCyJsPOGe2apBHB0drztMEWMgVlQKvvR5kuuZPkIt4NWsLsvX4OnyQI0XadOH3o9fsQIhiojewJ3fvsn39vXcsoF7OnyQIqHXWgGMnOatFHe2uaBHJtcc2Canbme2AA26joAFHSbg2Ibc204DrLnkapBXabB(jel94YMgVlQe2GS1B2C(g8TcbBpqdTbd0SfkBYiNQ45Bf)oQIxX3HFcxseeMUtj8zZlBehmLG14DrLSOJbgqdVD6lKWMScytgvTMR8unNQioHFclvkvfpFR43rv8k(o8t4sIGW0DkHpBEz7aaPcaYzDHtbvnwpMf9qytw22tLQyC0gmvr8Cd6Xf(rNVZIPu1AUc1AovrCc)ewQuQkE(wXVJQ4v8D4NWLebHP7ucF28YgfSLfefF4GqccPh4hZIEiSjGnQWMx2OmBV0G0G3fxfaiZpffCHt4NWcBB2WMVen9Yp1tH0fCj5Wg0vX4OnyQIrMVe5UQ1C3tLAovrCc)ewQuQkghTbtvmts7uOyv8aXjHWA8UOsQ5UVkwqY5BhTbtvmNWFhYdjTtHISPa2chNeeSTtyusqWgue0eWWwOSjmBA8UOsQINVv87OkEfFh(jCjrqy6oLWNnVSrCWucwJ3fvYIogyan82PVqcBcyt4QwZD)(AovrCc)ewQuQkE(wXVJQ4v8D4NWLebHP7uc)QyC0gmvXmjTtHIvTQvXtHuZPM7(AovrCc)ewQuQkghTbtvml(TybMg8Wfm07Q4bItcH14DrLuZDFvSGKZ3oAdMQy(MMTOuiSfpYMKJCSrM2bztVr2adYgKTEZwcajsu2YjNDAXMqjiiBqEJdBfi6XLn6GO4ZMEhdB5fkYwbP7tRSbE2GS1BGKYwmqWwEHIRQ45Bf)oQIF0fy8chDfLczj5WMx2OGnnExuxANHWkaU0iBqLTdiZha7a6rjRcs3NwzJQyB)k)STzdBhqMpa2b0JswfKUpTYMScy74aNfEctCWPWg0vTMRW1CQI4e(jSuPuv88TIFhvXp6cmEHJUIsHS6HnzztguHTDW2hDbgVWrxrPqwfPp0gmS5LTdiZha7a6rjRcs3NwztwbSDCGZcpHjo4uQIXrBWufZIFlwGPbpCbd9UkwqY5BhTbtvmFtZ2aylkfcBq2PeBLgzdYwV7Hn9gzBqpv2KbviYXMebztEqVtSbg28becBq26nqszlgiylVqXvvR5kJAovrCc)ewQuQkE(wXVJQiLzJOyK0BSSEGReYMx2OGnky7aaPcaYzDHtbvnwpMf9qytw2eQuHTnBy7aaPcaYzDHtbvnwpMf9qydQSjd2GMnVSH004r7le(aY8bWoGEucBYkGnzYMx204DrDPDgcRa4sJSjlB7PcBB2Wwb9LOPxx4uqvJLKdBB2WMpGqyZlB0T7Tc)yw0dHnOYMWYKnORIXrBWufPtHlMsH2GPkwqY5BhTbtvueI5WguykCXuk0gmSbzR3Sj04uqvd2ccBjW4YwqydsKnibJqu2sacYwW2jikBGl8ztVr2OB3BLTI0hAdg2Oa8S10Sj04uqvd2GStj2oGmKn)4SLTWn6z3MWMcCDtyHnann0RQwZvM1CQI4e(jSuPuv88TIFhvrkZgrXiP3yz9axjKnVSH004r7le(aY8bWoGEucBYkGnzYMx2OGn6ea8SrbBuWgD7ERWpMf9qyBhSjSmzdA22LT4OnyGpaqQaGCydA2KLn6ea8SrbBuWgD7ERWpMf9qyBhSjSmzBhSDaGuba5SUWPGQgRhZIEiSrvSDfFh(jCDHtbvnGpLNnOzBx2IJ2Gb(aaPcaYHnOzd6QyC0gmvr6u4IPuOnyQAn38xZPkIt4NWsLsvXZ3k(DufPmBefJKEJL1dCLq28YgfSDaGuba5SUWPGQgRhZIEiSbv22ZMx204DrDPDgcRa4sJSjlB7PcBB2Wwb9LOPxx4uqvJLKdBB2WgD7ERWpMf9qydQSTNkSbDvmoAdMQibDinPkwqY5BhTbtvueI5WMi6qAcBq26nBcnofu1GTGWwcmUSfe2GezdsWieLTeGGSfSDcIYg4cF20BKn629wzRi9H2Gro28Lu2CEKgF204DrLWMEhkBq2PeBP(czlu2syqu22tfsvR5cLR5ufXj8tyPsPQ45Bf)oQIuMnIIrsVXY6bUsiBEzJc2OtaWZgfSrbB0T7Tc)yw0dHTDW2EQWg0STlBXrBWaFaGuba5Wg0SjlB0ja4zJc2OGn629wHFml6HW2oyBpvyBhSDaGuba5SUWPGQgRhZIEiSrvSDfFh(jCDHtbvnGpLNnOzBx2IJ2Gb(aaPcaYHnOzd6QyC0gmvrc6qAsvR5kuuZPkIt4NWsLsvrGtvKGAvmoAdMQ4v8D4NWQ4vKKWQiLztJeo6AA3BLOrAl(lCc)ewyBZg2OmBAKWrxONKyCL6juCHt4NWcBB2W2basfaKZc9KeJRupHIRhZIEiSbv2YpB7GnHzJQytJeo6QGOd(We9dnCXSfoHFclvXR4HNidRIx4uqvd4PDVvIgPT4dFatP1gmvXcsoF7OnyQIIqmh2eACkOQbBq2tbajBq26nB52U3krJ0w89iF8KeJRupHIS10SfooP(e(jSQ1CLNQ5ufXj8tyPsPQiWPksqTkghTbtv8k(o8tyv8kE4jYWQ4fofu1a(aUWjgf(aMsRnyQIxrscRI7RIfKC(2rBWuffHyoSj04uqvd2GS1B2GctHlMsH2GHTykSjIoKMWwqylbgx2ccBqISbjyeIYwcqq2c2obrzdCHpB6nYgD7ERSvK(qBWufpFR43rv8aUWjgDTfIVJHTnBy7aUWjgDn45bjWxyBZg2oGlCIrxdyWQwZvOwZPkIt4NWsLsvrGtvKGAvmoAdMQ4v8D4NWQ4vKKWQiDcaE2OGnkyJUDVv4hZIEiSTd2eMkSbnB7YgfSTxyQWgvX2v8D4NW1fofu1a(uE2GMnOztw2OtaWZgfSrbB0T7Tc)yw0dHTDWMWuHTDW2basfaKZIofUykfAdM1Jzrpe2GMTDzJc22lmvyJQy7k(o8t46cNcQAaFkpBqZg0STzdB(s00l6u4IPuOnyG9LOPxsoSTzdBf0xIMErNcxmLcTbZsYHTnByJUDVv4hZIEiSbv2eMkvXR4HNidRIx4uqvd4d4cNyu4dykT2GPkE(wXVJQ4bCHtm66ch9gIVQ1C3tLAovrCc)ewQuQkcCQIeuRIXrBWufVIVd)ewfVIKewfPtaWZgfSrbB0T7Tc)yw0dHTDWMWuHnOzBx2OGT9ctf2Ok2UIVd)eUUWPGQgWNYZg0SbnBYYgDcaE2OGnkyJUDVv4hZIEiSTd2eMkSTd2oaqQaGCwe0H0K1Jzrpe2GMTDzJc22lmvyJQy7k(o8t46cNcQAaFkpBqZg0STzdBfGUiOdPjlTpB7XLTnByJUDVv4hZIEiSbv2eMkvXR4HNidRIx4uqvd4d4cNyu4dykT2GPkE(wXVJQ4bCHtm6AA3BfMoWQwZD)(AovrCc)ewQuQkE(wXVJQiLzJOyK0BSSEGReYMx2kaD9soQ0JlTpB7XLnVSrz2kOVen96cNcQASKCyZlBxX3HFcxx4uqvd4PDVvIgPT4dFatP1gmS5LTR47WpHRlCkOQb8bCHtmk8bmLwBWufJJ2GPkEHtbvnQAn39cxZPkIt4NWsLsvXZ3k(DufPmBefJKEJL1dCLq28YgfSrz2kaD5g)duC9i9JK7WpHS5LTcqxVKJk946XSOhcBYYMmzZd2KjBufBhh4SWtyIdof22SHTcqxVKJk946XSOhcBufBuzLF2KLnnExuxANHWkaU0iBqZMx204DrDPDgcRa4sJSjlBYSkghTbtve9KeJRupHIvXcsoF7OnyQI5JNKyCL6juKniVXHTbOSrums6nwylMcB(a9Mn5xYrLEKTykSbLI)bkYw8iBsoSrdE2sGXLnCasU3RQwZDVmQ5ufXj8tyPsPQ45Bf)oQIfGUEjhv6XL2NT94YMx2OGnkZ2basfaKZIGoKMSEmkqW2MnSDaGuba5SUWPGQgRhZIEiSjlB7fMnOzBZg2kaDrqhstwAF22JBvmoAdMQi5UVQIfKC(2rBWuffV7l2AA2GezlEKTWhiPSPa2YN5chqMCSftHTqvmZrztbSrGyoSbzR3SjIoKMWgDprIT7wzRPzdsKnibJqu2GmikYwg4r207yy7os0SP3iBhaivaqoRQwZDVmR5ufXj8tyPsPQ45Bf)oQI(s00l)eausseD9yCu22SHnFaHWMx2OB3Bf(XSOhcBqLnzqf22SHTc6lrtVUWPGQgljNQyC0gmvrhG2GPQ1C3N)AovrCc)ewQuQkE(wXVJQyb9LOPxx4uqvJLKtvmoAdMQOFcakW0spevTM7EOCnNQioHFclvkvfpFR43rvSG(s00RlCkOQXsYPkghTbtv0hFc(B7XTQ1C3luuZPkIt4NWsLsvXZ3k(DuflOVen96cNcQASKCQIXrBWufP7h9taqPQ1C3lpvZPkIt4NWsLsvXZ3k(DuflOVen96cNcQASKCQIXrBWufJ5Ge9Je8jsPQwZDVqTMtveNWpHLkLQIXrBWufprkbhhTbdCQjAv88TIFhvrkZgrXiP3yzfPeBEzllik(WbHeespWpMf9qytaBuHnVSrbBuMnns4ORSGO4dhesqi9SWj8tyHTnByZxIMErs9bHJPax6dUEml6HWMSSjd2GUkMAIcprgwfVIPj3vTMRWuPMtveNWpHLkLQINVv87OkEfFh(jCPFpBrfMaXCGjjGYMa22ZMx2OGTc6lrtVUWPGQgljh22SHnFaHWMx2OB3Bf(XSOhcBqvaBctf2GMTnByJc2UIVd)eU0VNTOctGyoWKeqztaBcZMx2OmB63ZwuxQWRdaKkaiN1Jrbc2GMTnByJYSDfFh(jCPFpBrfMaXCGjjGwfJJ2GPkQFpBrDFvSGKZ3oAdMQOieZHn9gzZ5BW3keSr0qzZxIMMn97zlQSbzR3Sj04uqvd5ydO34dztq2KiiBGHTdaKkaiNQwZv491CQI4e(jSuPuv88TIFhvXR47WpHl97zlQWeiMdmjbu2eWMWS5LnkyRG(s00RlCkOQXsYHTnByZhqiS5Ln629wHFml6HWgufWMWuHnOzBZg2OGTR47WpHl97zlQWeiMdmjbu2eW2E28YgLzt)E2I6s3VoaqQaGCwpgfiydA22SHnkZ2v8D4NWL(9SfvyceZbMKaAvmoAdMQO(9SfvHRAvRIfGwZPM7(AovrCc)ewQuQkcCQIeuRIXrBWufVIVd)ewfVIKewfD(g8Tcb8d0qBWWMx2OGTcqxUX)afxpMf9qydQSDaGuba5SCJ)bkUksFOnyyBZg2WbFxiwp6Id8bK53dwytw2Kr(zd6Q4v8WtKHvrY22b(aXjHWUX)afRIfKC(2rBWufL3oRv2i4bmL4HGnOu8pqrcB0GNnNVbFRqW2d0qBWWwtZgKiB3XfYMmYpB4GVleS9OloSbE2GsX)afzdYoLyd90PFKnWWMEJS58Dw8qWMgVlQvTMRW1CQI4e(jSuPuve4ufjOwfJJ2GPkEfFh(jSkEfjjSk68n4Bfc4hOH2GHnVSrbBf0xIMErU7RLKdBEzJ4GPeSgVlQKfDmWaA4TtFHe2KLnHzBZg2WbFxiwp6Id8bK53dwytw2Kr(zd6Q4v8WtKHvrY22b(aXjHWVKJk9yvSGKZ3oAdMQO82zTYgbpGPepeSj)soQ0Je2ObpBoFd(wHGThOH2GHTMMnir2UJlKnzKF2WbFxiy7rxCyd8SjE3xS1e2KCydmSjCoEu1AUYOMtveNWpHLkLQIaNQib1QyC0gmvXR47WpHvXRijHvXc6lrtVUWPGQgljh28YgfSvqFjA6f5UVwsoSTzdBzbrXhoiKGq6b(XSOhcBYYgvydA28YwbORxYrLEC9yw0dHnzzt4Q4v8WtKHvrY22b(LCuPhRIfKC(2rBWufL3oRv2KFjhv6rcBnnBcnofu1WdX7(Ax5rqu8zt(iKGq6HTMWMKdBXuydsKT74cztypyJGhWuiSLqALnWWMEJSj)soQ0JSTtGCQAnxzwZPkIt4NWsLsvXZ3k(Duf1iHJUqpjX4k1tO4cNWpHf28YgLzRG(s00l34FGIl0tsmUs9ekwyZlBfGUCJ)bkUCYKsA7KA8zdQcyBpBEz7aaPcaYzHEsIXvQNqX1Jzrpe2GkBcZMx2ioykbRX7IkzrhdmGgE70xiHnbSTNnVS9rxGXlC0vukKvpSjlBqz28YwbOl34FGIRhZIEiSrvSrLv(zdQSPX7I6s7mewbWLgRIXrBWufDJ)bkwfli58TJ2GPkk6GNosSbLI)bkYwmf2KFjhv6r2iOk5WMZ3GNnfWw(4jjgxPEcfz7eeTQ1CZFnNQioHFclvkvfpFR43rvuJeo6c9KeJRupHIlCc)ewyZlBuWgstJhTVq4diZha7a6rjSjRa2ooWzHNWehCkS5LTdaKkaiNf6jjgxPEcfxpMf9qydQSTNnVSva66LCuPhxpMf9qyJQyJkR8ZguztJ3f1L2ziScGlnYg0vX4OnyQIVKJk9yvR5cLR5ufXj8tyPsPQin4Hh0tTM7(QyC0gmvrhaib)ibi9hSkwqY5BhTbtvekf)duKnjNTi6ihBrIayt)gjSPa2KiiBTYwqylyJ4GNosS5Id(HcE2ObpB6nYwkikB5fkYMpsdEKTGn6EAYn(vTMRqrnNQioHFclvkvfpFR43rv8r6hj3HFczZlBhqMpa2b0JswfKUpTYMScyBpBEzJc2CYKsA7KA8zdQcyBpBB2W2Jzrpe2GQa20(Sfw7mKnVSrCWucwJ3fvYIogyan82PVqcBYkGnzWg0S5LnkyJYSHEsIXvQNqXcBB2W2Jzrpe2GQa20(Sfw7mKnQInHzZlBehmLG14DrLSOJbgqdVD6lKWMScytgSbnBEzJc204DrDPDgcRa4sJSTd2Eml6HWg0SjlBYKnVSLfefF4GqccPh4hZIEiSjGnQufJJ2GPk6g)duSQ1CLNQ5ufXj8tyPsPQin4Hh0tTM7(QyC0gmvrhaib)ibi9hSQ1CfQ1CQI4e(jSuPuv88TIFhvrkZ2v8D4NWfzB7aFG4Kqy34FGIS5LThPFKCh(jKnVSDaz(ayhqpkzvq6(0kBYkGT9S5LnkyZjtkPTtQXNnOkGT9STzdBpMf9qydQcyt7ZwyTZq28YgXbtjynExujl6yGb0WBN(cjSjRa2KbBqZMx2OGnkZg6jjgxPEcflSTzdBpMf9qydQcyt7ZwyTZq2Ok2eMnVSrCWucwJ3fvYIogyan82PVqcBYkGnzWg0S5LnkytJ3f1L2ziScGlnY2oy7XSOhcBqZMSSTxy28Ywwqu8HdcjiKEGFml6HWMa2OsvmoAdMQOB8pqXQ4bItcH14DrLuZDFvR5UNk1CQI4e(jSuPuv88TIFhvrIdMsWA8UOsytwbSjmBEz7XSOhcBqLnHzZd2OGnIdMsWA8UOsytwbSLF2GMnVSH004r7le(aY8bWoGEucBYkGnzwfJJ2GPkE(oJagyfZCqIwfli58TJ2GPkM3VZiGHTCWmhKOSbg2YKsA7Kq204DrLWwOSjtpylVqr2G8gh2EPz6XLnGKYwpSjmHnkKCytbSjt204DrLanBGNnzqyJI87bBA8UOsGUQ1C3VVMtveNWpHLkLQINVv87Oksz2UIVd)eUiBBh4xYrLEKnVSH004r7le(aY8bWoGEucBYkGnzYMx2EK(rYD4Nq28YgfS5KjL02j14ZgufW2E22SHThZIEiSbvbSP9zlS2ziBEzJ4GPeSgVlQKfDmWaA4TtFHe2KvaBYGnOzZlBuWgLzd9KeJRupHIf22SHThZIEiSbvbSP9zlS2ziBufBcZMx2ioykbRX7IkzrhdmGgE70xiHnzfWMmydA28YMgVlQlTZqyfaxAKTDW2Jzrpe2KLnkytMS5bBV0G0G3fxLGC3Jlm5aKMYJPfoHFclSrvSjuzZd2EPbPbVlUkaqMFkk4cNWpHf2Ok2GYSbDvmoAdMQ4l5Ospwfli58TJ2GPkcfarh2KCyt(LCuPhzlu2KPhSbg2IuInnExujSrbK34WwQV6XLTeyCzdhGK7nBXuyBakBKjCi3af6QwZDVW1CQI4e(jSuPuv88TIFhvrkZ2v8D4NWfzB7aFG4Kq4xYrLEKnVSrz2UIVd)eUiBBh4xYrLEKnVSH004r7le(aY8bWoGEucBYkGnzYMx2EK(rYD4Nq28YgfS5KjL02j14ZgufW2E22SHThZIEiSbvbSP9zlS2ziBEzJ4GPeSgVlQKfDmWaA4TtFHe2KvaBYGnOzZlBuWgLzd9KeJRupHIf22SHThZIEiSbvbSP9zlS2ziBufBcZMx2ioykbRX7IkzrhdmGgE70xiHnzfWMmydA28YMgVlQlTZqyfaxAKTDW2Jzrpe2KLnkytMS5bBV0G0G3fxLGC3Jlm5aKMYJPfoHFclSrvSjuzZd2EPbPbVlUkaqMFkk4cNWpHf2Ok2GYSbDvmoAdMQ4l5OspwfpqCsiSgVlQKAU7RAn39YOMtveNWpHLkLQINVv87OksCWucwJ3fvcBcyBpBEzJYS9sdsdExCvcYDpUWKdqAkpMw4e(jSWMx2YcIIpCqibH0d8Jzrpe2eWgvyZlBinnE0(cHpGmFaSdOhLWMScyJc2ooWzHNWehCkSTd22Zg0S5LThPFKCh(jKnVSrz2qpjX4k1tOyHnVSrz2kOVen9IC3xljh28YgfSHd(UqSkiDFALnOkGnHZpBEW2v8D4NWfo47cb8JU4aFaz(9Gf2GMnVSPX7I6s7mewbWLgzBhS9yw0dHnzztMvX4OnyQINVZiGbwXmhKOvXcsoF7OnyQI597mcyylhmZbjkBGHnXCyRPzRh2CIPGz9HTykSny8jiyll8KnCW3fc2IPWwtZw(mx4aYydsWieLTcGTmWJSvISWfzRiHSPa2YHs7kpKVQw1QwfVWN0GPMRWur49urgctLQiKXp94sQIYZYN8NB(oxOevZgB5CJS1zoGxzJg8SjKRyAYTqy7rOGs9Jf2iGmKTqsbzHIf2o3X4IKftT82dY2EQMT8cMl8vSWMqEPbPbVlU2zHWMcytiV0G0G3fx78cNWpHfHWgfc7j0lMA5ThKnOmvZwEbZf(kwytiV0G0G3fx7SqytbSjKxAqAW7IRDEHt4NWIqyJI9Ec9IPMPwEw(K)CZ35cLOA2ylNBKToZb8kB0GNnHuq6qkPcHThHck1pwyJaYq2cjfKfkwy7ChJlswm1YBpiBYGQzlVG5cFflSj2z5LnceJgEYw(InfWM8kfSv6RM0GHnGd(HcE2OyxOzJI9Ec9IPMPwEw(K)CZ35cLOA2ylNBKToZb8kB0GNnH484bK5hQqy7rOGs9Jf2iGmKTqsbzHIf2o3X4IKftT82dYMmPA2YlyUWxXcBcr)E2I6A)ANfcBkGnHOFpBrDP7x7SqyJcH9e6ftT82dYMmPA2YlyUWxXcBcr)E2I6s41ole2uaBcr)E2I6sfETZcHnke2tOxm1YBpiB5NQzlVG5cFflSje97zlQR9RDwiSPa2eI(9Sf1LUFTZcHnke2tOxm1YBpiB5NQzlVG5cFflSje97zlQlHx7SqytbSje97zlQlv41ole2OqypHEXuZulplFYFU57CHsunBSLZnYwN5aELnAWZMqk9JhviS9iuqP(XcBeqgYwiPGSqXcBN7yCrYIPwE7bztOs1SLxWCHVIf2eYlnin4DX1ole2uaBc5LgKg8U4ANx4e(jSie2OyVNqVyQzQLNLp5p38DUqjQMn2Y5gzRZCaVYgn4ztiNcriS9iuqP(XcBeqgYwiPGSqXcBN7yCrYIPwE7bztMunB5fmx4RyHnXolVSrGy0Wt2YxSPa2KxPGTsF1KgmSbCWpuWZgf7cnBuiSNqVyQL3Eq2GYunB5fmx4RyHnXolVSrGy0Wt2YxSPa2KxPGTsF1KgmSbCWpuWZgf7cnBuiSNqVyQL3Eq2eQunB5fmx4RyHnXolVSrGy0Wt2YxSPa2KxPGTsF1KgmSbCWpuWZgf7cnBuiSNqVyQL3Eq22tfQMT8cMl8vSWMyNLx2iqmA4jB5l2uaBYRuWwPVAsdg2ao4hk4zJIDHMnke2tOxm1YBpiBctfQMT8cMl8vSWMq0VNTOUeETZcHnfWMq0VNTOUuHx7SqyJI9Ec9IPwE7bzt49unB5fmx4RyHnHOFpBrDTFTZcHnfWMq0VNTOU09RDwiSrXEpHEXuZulplFYFU57CHsunBSLZnYwN5aELnAWZMqkaviS9iuqP(XcBeqgYwiPGSqXcBN7yCrYIPwE7bztMunB5fmx4RyHnHGEsIXvQNqXYANfcBkGnHuqFjA61oVqpjX4k1tOyriSrXEpHEXulV9GSTFpvZwEbZf(kwytiV0G0G3fx7SqytbSjKxAqAW7IRDEHt4NWIqyJcH9e6ftT82dY2EHPA2YlyUWxXcBc5LgKg8U4ANfcBkGnH8sdsdExCTZlCc)ewecBuiSNqVyQL3Eq22ldQMT8cMl8vSWMqEPbPbVlU2zHWMcytiV0G0G3fx78cNWpHfHWgf79e6ftntDo3iBcrIGWTIzeHWwC0gmSbzqyBakB0aPPWwpSP3nHToZb86IPoFN5aEflSjuWwC0gmSLAIswm1vrNhq3jSkMN8WM8ribH0tOnyyt(bUsitDEYdBYNZ3j2KHCSjmveEptntDEYdB59ogxKq1m15jpSTd2KphNeeSjeI(9rfcB0PWLnfWgbKHSjFqr5LnAWVLWMcyJexiBop4GespUSPDgUyQZtEyBhSTtGrikBcDmn5MnPjHecBIP(GSftHTDQpiBq2PeBPGOSLaJl(SP3XWM8iik(SjFesqi9SyQZtEyBhSj)yk8KnOWu4IPuOnyyBx2eACkOQbBeiMdBu00Sj04uqvd2AcBkW1nHf2a00SbE2adBbBjW4YwE3jOxm1m15jpSLpEIhjflS5J0Ghz7aY8dLnF0ThYIn57CqhLW2aMDChFgTuIT4OnyiSbMeelM64OnyilNhpGm)qfeoojiGDanbmm1XrBWqwopEaz(H6HGD9bQMWcmDkGalq2JlSc8ShM64OnyilNhpGm)q9qWUzXVflW0GhUGHElNZJhqMFOWe8aMcrq(LRPf8rxGXlC0vukKvpYUp)m15HTDcv8Z6bzdY7(CZgfnnBXab0Sr0qzZxIMMn97zlQSbjYgKXOSPa2cvXmhLnfWgbI5WgKTEZMqJtbvnwm1XrBWqwopEaz(H6HGDVIVd)ek3ezOa97zlQWeiMdmjbu5UIKekyVCnTa97zlQR9R7Gat0qxXabCXH4LckRFpBrDj86oiWen0vmqaxCiB2OFpBrDTFDaGuba5SksFOnyKvG(9Sf1LWRdaKkaiNvr6dTbd0m1XrBWqwopEaz(H6HGDVIVd)ek3ezOa97zlQWeiMdmjbu5UIKekqy5AAb63ZwuxcVUdcmrdDfdeWfhIxkOS(9Sf11(1DqGjAORyGaU4q2Sr)E2I6s41basfaKZQi9H2Grw97zlQR9RdaKkaiNvr6dTbd0m1XrBWqwopEaz(H6HGDjP(GWXuGl9bLZ5XdiZpuycEatHiyVCnTGhPFKCh(jKPooAdgYY5XdiZpupeSlrXiP3m1m15jpSLpEIhjflSHx4dbBANHSP3iBXrbpBnHT4k6u4NWftDC0gmebB7ZwM68WM8JefJKEZwtZMdGqA)eYgfdGTlP0GF4Nq2WbZAKWwpSDaz(HcntDC0gmepeSlrXiP3m1XrBWq8qWUxX3HFcLBImuao47cb8JU4aFaz(9Gf5UIKekah8DHy9OloE4aAcyWcSFcXcHQKNYxuimvrCWuc(oikcntDC0gmepeS7v8D4Nq5Midfq6XnHWA8UOk3vKKqbehmLG14DrLSOJbgqdVD6lKavHzQJJ2GH4HGDprkbhhTbdCQjQCtKHcikgj9glYr0VpQG9Y10cikgj9glRh4kHm1XrBWq8qWUNiLGJJ2Gbo1evUjYqbNcroI(9rfSxo5AAbuqzns4ORSGO4dhesqi9SWj8tyzZMcqxUX)afxAF22Jl0m15HnOOKYM4StSj5WwpT2rkbbB0GNT8kPSPa20BKT8Eheuo2EK(rYnBq26nB5ZCHdiJTMMTqzlbGKTI0hAdgM64OnyiEiyxsQpiCmf4sFq5AAbu2xIMErs9bHJPax6dUKC8Eaz(ayhqpkrwbYGPooAdgIhc2fNlCazY10c8LOPxKuFq4ykWL(GljhV(s00lsQpiCmf4sFW1JzrpeOMFVhqMpa2b0JsKvGmzQJJ2GH4HGDprkbhhTbdCQjQCtKHckaLPooAdgIhc29ePeCC0gmWPMOYnrgkO0pEuM64OnyiEiy34pXGWk4FCu5AAb4GVleRcs3NwLvW(87Xv8D4NWfo47cb8JU4aFaz(9GfM64OnyiEiy34pXGWosjcYuhhTbdXdb7MA3BLaluMuXndhLPooAdgIhc21pCHb0W63NTeMAM68Kh2YlaKkaihctDEylFtZwuke2IhztYro2it7GSP3iBGbzdYwVzlbGejkB5KZoTytOeeKniVXHTce94YgDqu8ztVJHT8cfzRG09Pv2apBq26nqszlgiylVqXftDC0gmK1Pq8qWUzXVflW0GhUGHEl3bItcH14DrLiyVCnTGp6cmEHJUIsHSKC8sHgVlQlTZqyfaxAeQhqMpa2b0JswfKUpTsv7x5FZMdiZha7a6rjRcs3NwLvWXbol8eM4GtbAM68Ww(MMTbWwuke2GStj2knYgKTE3dB6nY2GEQSjdQqKJnjcYM8GENydmS5die2GS1BGKYwmqWwEHIlM64OnyiRtH4HGDZIFlwGPbpCbd9wUMwWhDbgVWrxrPqw9iRmOYo(OlW4fo6kkfYQi9H2GX7bK5dGDa9OKvbP7tRYk44aNfEctCWPWuNh2eHyoSbfMcxmLcTbdBq26nBcnofu1GTGWwcmUSfe2GezdsWieLTeGGSfSDcIYg4cF20BKn629wzRi9H2GHnkapBnnBcnofu1Gni7uITdidzZpoBzlCJE2TjSPax3ewydqtd9IPooAdgY6uiEiyx6u4IPuOnyKRPfqzIIrsVXY6bUsOxkO4aaPcaYzDHtbvnwpMf9qKvOsLnBoaqQaGCwx4uqvJ1JzrpeOkdO9I004r7le(aY8bWoGEuIScKPxnExuxANHWkaU0OS7PYMnf0xIMEDHtbvnwsoB24dieV0T7Tc)yw0dbQcltOzQJJ2GHSofIhc2LofUykfAdg5AAbuMOyK0BSSEGRe6fPPXJ2xi8bK5dGDa9OezfitVuqNaGNckOB3Bf(XSOhYoewMqNVoaqQaGCGww6ea8uqbD7ERWpMf9q2HWYChhaivaqoRlCkOQX6XSOhcvDfFh(jCDHtbvnGpLh681basfaKd0qZuNh2eHyoSjIoKMWgKTEZMqJtbvnyliSLaJlBbHnir2GemcrzlbiiBbBNGOSbUWNn9gzJUDVv2ksFOnyKJnFjLnNhPXNnnExujSP3HYgKDkXwQVq2cLTegeLT9uHWuhhTbdzDkepeSlbDinrUMwaLjkgj9glRh4kHEP4aaPcaYzDHtbvnwpMf9qG6EVA8UOU0odHvaCPrz3tLnBkOVen96cNcQASKC2SHUDVv4hZIEiqDpvGMPooAdgY6uiEiyxc6qAICnTaktums6nwwpWvc9sbDcaEkOGUDVv4hZIEi7ypvGoFDaGuba5aTS0ja4PGc629wHFml6HSJ9uzhhaivaqoRlCkOQX6XSOhcvDfFh(jCDHtbvnGpLh681basfaKd0qZuNh2eHyoSj04uqvd2GSNcas2GS1B2YTDVvIgPT47r(4jjgxPEcfzRPzlCCs9j8titDC0gmK1Pq8qWUxX3HFcLBImuWfofu1aEA3BLOrAl(WhWuATbJCxrscfqzns4ORPDVvIgPT4VWj8tyzZgkRrchDHEsIXvQNqXfoHFclB2CaGuba5SqpjX4k1tO46XSOhcuZ)oeMQ0iHJUki6Gpmr)qdxmBHt4NWctDEyteI5WMqJtbvnydYwVzdkmfUykfAdg2IPWMi6qAcBbHTeyCzliSbjYgKGrikBjabzly7eeLnWf(SP3iB0T7TYwr6dTbdtDC0gmK1Pq8qWUxX3HFcLBImuWfofu1a(aUWjgf(aMsRnyKRPfCax4eJU2cX3XSzZbCHtm6AWZdsGVSzZbCHtm6Aadk3vKKqb7zQJJ2GHSofIhc29k(o8tOCtKHcUWPGQgWhWfoXOWhWuATbJCnTGd4cNy01fo6neVCxrscfqNaGNckOB3Bf(XSOhYoeMkqNVOyVWuHQUIVd)eUUWPGQgWNYdn0YsNaGNckOB3Bf(XSOhYoeMk74aaPcaYzrNcxmLcTbZ6XSOhc05lk2lmvOQR47WpHRlCkOQb8P8qd9Mn(s00l6u4IPuOnyG9LOPxsoB2uqFjA6fDkCXuk0gmljNnBOB3Bf(XSOhcufMkm1XrBWqwNcXdb7EfFh(juUjYqbx4uqvd4d4cNyu4dykT2GrUMwWbCHtm6AA3BfMoq5UIKekGobapfuq3U3k8JzrpKDimvGoFrXEHPcvDfFh(jCDHtbvnGpLhAOLLobapfuq3U3k8JzrpKDimv2XbasfaKZIGoKMSEml6HaD(II9ctfQ6k(o8t46cNcQAaFkp0qVztbOlc6qAYs7Z2EC3SHUDVv4hZIEiqvyQWuhhTbdzDkepeS7fofu1qUMwaLjkgj9glRh4kHElaD9soQ0JlTpB7X1lLlOVen96cNcQASKC8EfFh(jCDHtbvnGN29wjAK2Ip8bmLwBW49k(o8t46cNcQAaFax4eJcFatP1gmm15HT8XtsmUs9ekYgK34W2au2ikgj9glSftHnFGEZM8l5OspYwmf2GsX)afzlEKnjh2ObpBjW4Ygoaj37ftDC0gmK1Pq8qWUONKyCL6juuUMwaLjkgj9glRh4kHEPGYfGUCJ)bkUEK(rYD4NqVfGUEjhv6X1JzrpezLPhYKQooWzHNWehCkB2ua66LCuPhxpMf9qOkQSYVSA8UOU0odHvaCPrO9QX7I6s7mewbWLgLvMm15HnX7(ITMMnir2Ihzl8bskBkGT8zUWbKjhBXuylufZCu2uaBeiMdBq26nBIOdPjSr3tKy7Uv2AA2GezdsWieLnidIISLbEKn9og2UJenB6nY2basfaKZIPooAdgY6uiEiyxYDFjxtlOa01l5OspU0(SThxVuq5daKkaiNfbDinz9yuGyZMdaKkaiN1fofu1y9yw0dr29cd9MnfGUiOdPjlTpB7XLPooAdgY6uiEiyxhG2GrUMwGVen9YpbaLKerxpghDZgFaH4LUDVv4hZIEiqvguzZMc6lrtVUWPGQgljhM64OnyiRtH4HGD9taqbMw6HqUMwqb9LOPxx4uqvJLKdtDC0gmK1Pq8qWU(4tWFBpUY10ckOVen96cNcQASKCyQJJ2GHSofIhc2LUF0pbaf5AAbf0xIMEDHtbvnwsom1XrBWqwNcXdb7gZbj6hj4tKsY10ckOVen96cNcQASKCyQJJ2GHSofIhc29ePeCC0gmWPMOYnrgk4kMMClxtlGYefJKEJLvKsEZcIIpCqibH0d8JzrpebuXlfuwJeo6klik(WbHeesplCc)ew2SXxIMErs9bHJPax6dUEml6HiRmGMPopSjcXCytVr2C(g8TcbBenu28LOPzt)E2IkBq26nBcnofu1qo2a6n(q2eKnjcYgyy7aaPcaYHPooAdgY6uiEiyx97zlQ7LRPfCfFh(jCPFpBrfMaXCGjjGkyVxkkOVen96cNcQASKC2SXhqiEPB3Bf(XSOhcufimvGEZgkUIVd)eU0VNTOctGyoWKeqfiSxkRFpBrDj86aaPcaYz9yuGa6nBO8v8D4NWL(9SfvyceZbMKaktDC0gmK1Pq8qWU63ZwufwUMwWv8D4NWL(9SfvyceZbMKaQaH9srb9LOPxx4uqvJLKZMn(acXlD7ERWpMf9qGQaHPc0B2qXv8D4NWL(9SfvyceZbMKaQG9EPS(9Sf11(1basfaKZ6XOab0B2q5R47WpHl97zlQWeiMdmjbuMAM68Kh22P(XJYwjYcxKTWVtT2iHPopSLpZfoGm2cLnz6bBuKFpydYwVzBNeHMT8cfxSLVZYWshkMGGnWWMWEWMgVlQe5ydYwVztOXPGQgYXg4zdYwVzlhkjus2a6n(q2eKniJwzJg8SraziB4GVlel2KVebWgKrRS10SLpEsCz7aY8bS1e2oGSECztYzXuhhTbdzv6hpQaCUWbKjxtlaPPXJ2xi8bK5dGDa9Oezfitp0iHJUki6Gpmr)qdxmBHt4NWIxkkOVen96cNcQASKC2SPG(s00lYDFTKC2SPG(s00l6u4IPuOnywsoB2Gd(UqSkiDFAfQceo)ECfFh(jCHd(Uqa)OloWhqMFpyzZgkFfFh(jCr6XnHWA8UOcTxkOSgjC0f6jjgxPEcfx4e(jSSzZbasfaKZc9KeJRupHIRhZIEiYkm0m1XrBWqwL(XJ6HGDVIVd)ek3ezOajcct3Pe(YDfjjuWbK5dGDa9OKvbP7tRYUFZgCW3fIvbP7tRqvGW53JR47WpHlCW3fc4hDXb(aY87blB2q5R47WpHlspUjewJ3fvM68WM854KGGnrkjYMcylsj204DrLWgKTEdKu2c2kOVennBbHnNVbFRqihBopsJ)3JlBA8UOsyRarpUSraGbF2cAfF20BKnNVZIhc204DrLPooAdgYQ0pEupeSlb)puSa7dgeM40Br5AAbxX3HFcxseeMUtj89s5cqxe8)qXcSpyqyItVfHlaDP9zBpUm1XrBWqwL(XJ6HGDj4)HIfyFWGWeNElk3bItcH14DrLiyVCnTGR47WpHljcct3Pe(EPCbOlc(FOyb2hmimXP3IWfGU0(SThxM68WM88noSjpKp2AcBdqzlu2UB3B2ksFOnyKJnjcYMiLeztbSfoojiytEXOWMpeSLpEgzojKTI03JlBcnofu1qo2a6n(q2eKTTi6Wg9dYy7eoo94Y25oExKWuhhTbdzv6hpQhc2LG)hkwG9bdctC6TOCnTGR47WpHljcct3Pe(EZcIIpCqibH0d8JzrpeOsLL8KxkOB3Bf(XSOhcufK)nBoaqQaGCwe8)qXcSpyqyItVfxN74Drcm9hhTbtKKvGWlHI8VzdbiL87PSsyuG9Hag9mYCs4cNWpHfVu2xIMELWOa7dbm6zK5KWLKJ3c6lrtVUWPGQgljhOzQZdBqHXWgGMnOatFHe2cLT9cvpyJOXzlHnanBcL3LcoSrPuuqcBGNTWn6HOSjtpytJ3fvYIPooAdgYQ0pEupeSlDmWaA4TtFHe5AAbxX3HFcxseeMUtj89sHVen96UlfCG9trbjlIgNTYkyVqDZgkOSZ3GVviGFGgAdgVehmLG14DrLSOJbgqdVD6lKiRaz6brXiP3yz9axjeAOzQZdBqHXWgGMnOatFHe2uaBHJtcc2Canbme2AA26joAFHSbg2Ibc204DrLnkapBXabB(jel94YMgVlQe2GS1B2C(g8TcbBpqdTbd0SfkBYihM64OnyiRs)4r9qWU0XadOH3o9fsK7aXjHWA8UOseSxUMwWv8D4NWLebHP7ucFVehmLG14DrLSOJbgqdVD6lKiRazWuhhTbdzv6hpQhc2fp3GECHF057SykY10cUIVd)eUKiimDNs479aaPcaYzDHtbvnwpMf9qKDpvyQJJ2GHSk9Jh1db7gz(sKB5AAbxX3HFcxseeMUtj89srwqu8HdcjiKEGFml6HiGkEP8lnin4DXvbaY8trb3SXxIME5N6Pq6cUKCGMPopSLt4Vd5HK2Pqr2uaBHJtcc22jmkjiydkcAcyylu2eMnnExujm1XrBWqwL(XJ6HGDZK0ofkk3bItcH14DrLiyVCnTGR47WpHljcct3Pe(EjoykbRX7IkzrhdmGgE70xirGWm1XrBWqwL(XJ6HGDZK0ofkkxtl4k(o8t4sIGW0DkHptntDEYdB7uKfUiBGl8zt7mKTWVtT2iHPopSjVDwRSrWdykXdbBqP4FGIe2ObpBoFd(wHGThOH2GHTMMnir2UJlKnzKF2WbFxiy7rxCyd8SbLI)bkYgKDkXg6Pt)iBGHn9gzZ57S4HGnnExuzQJJ2GHSkavWv8D4Nq5Midfq22oWhioje2n(hOOCxrscf48n4Bfc4hOH2GXlffGUCJ)bkUEml6Ha1daKkaiNLB8pqXvr6dTbZMn4GVleRhDXb(aY87blYkJ8dntDEytE7SwzJGhWuIhc2KFjhv6rcB0GNnNVbFRqW2d0qBWWwtZgKiB3XfYMmYpB4GVleS9OloSbE2eV7l2AcBsoSbg2eohpyQJJ2GHSka1db7EfFh(juUjYqbKTTd8bItcHFjhv6r5UIKekW5BW3keWpqdTbJxkkOVen9IC3xljhVehmLG14DrLSOJbgqdVD6lKiRWB2Gd(UqSE0fh4diZVhSiRmYp0m15Hn5TZALn5xYrLEKWwtZMqJtbvn8q8UV2vEeefF2KpcjiKEyRjSj5Wwmf2Gez7oUq2e2d2i4bmfcBjKwzdmSP3iBYVKJk9iB7eihM64OnyiRcq9qWUxX3HFcLBImuazB7a)soQ0JYDfjjuqb9LOPxx4uqvJLKJxkkOVen9IC3xljNnBYcIIpCqibH0d8JzrpezPc0ElaD9soQ0JRhZIEiYkmtDEyt0bpDKydkf)duKTykSj)soQ0JSrqvYHnNVbpBkGT8XtsmUs9ekY2jiktDC0gmKvbOEiyx34FGIY10c0iHJUqpjX4k1tO4cNWpHfVug9KeJRupHILLB8pqrVfGUCJ)bkUCYKsA7KA8HQG9EpaqQaGCwONKyCL6juC9yw0dbQc7L4GPeSgVlQKfDmWaA4TtFHeb79(rxGXlC0vukKvpYcL9wa6Yn(hO46XSOhcvrLv(HQgVlQlTZqyfaxAKPooAdgYQaupeS7l5OspkxtlqJeo6c9KeJRupHIlCc)ew8sbstJhTVq4diZha7a6rjYk44aNfEctCWP49aaPcaYzHEsIXvQNqX1JzrpeOU3BbORxYrLEC9yw0dHQOYk)qvJ3f1L2ziScGlncntDEydkf)duKnjNTi6ihBrIayt)gjSPa2KiiBTYwqylyJ4GNosS5Id(HcE2ObpB6nYwkikB5fkYMpsdEKTGn6EAYn(m1XrBWqwfG6HGDDaGe8JeG0Fq5Obp8GEQc2ZuhhTbdzvaQhc21n(hOOCnTGhPFKCh(j07bK5dGDa9OKvbP7tRYkyVxkCYKsA7KA8HQG9B28yw0dbQc0(Sfw7m0lXbtjynExujl6yGb0WBN(cjYkqgq7LckJEsIXvQNqXYMnpMf9qGQaTpBH1odPkH9sCWucwJ3fvYIogyan82PVqIScKb0EPqJ3f1L2ziScGlnUJhZIEiqlRm9MfefF4GqccPh4hZIEicOctDC0gmKvbOEiyxhaib)ibi9huoAWdpONQG9m1XrBWqwfG6HGDDJ)bkk3bItcH14DrLiyVCnTakFfFh(jCr22oWhioje2n(hOO3hPFKCh(j07bK5dGDa9OKvbP7tRYkyVxkCYKsA7KA8HQG9B28yw0dbQc0(Sfw7m0lXbtjynExujl6yGb0WBN(cjYkqgq7LckJEsIXvQNqXYMnpMf9qGQaTpBH1odPkH9sCWucwJ3fvYIogyan82PVqIScKb0EPqJ3f1L2ziScGlnUJhZIEiql7EH9MfefF4GqccPh4hZIEicOctDEylVFNradB5GzoirzdmSLjL02jHSPX7IkHTqztMEWwEHISb5noS9sZ0JlBajLTEytycBui5WMcytMSPX7IkbA2apBYGWgf53d204DrLantDC0gmKvbOEiy3Z3zeWaRyMdsu5AAbehmLG14DrLiRaH9(yw0dbQc7bfehmLG14DrLiRG8dTxKMgpAFHWhqMpa2b0JsKvGmzQZdBqbq0Hnjh2KFjhv6r2cLnz6bBGHTiLytJ3fvcBua5noSL6RECzlbgx2Wbi5EZwmf2gGYgzchYnqHMPooAdgYQaupeS7l5OspkxtlGYxX3HFcxKTTd8l5Osp6fPPXJ2xi8bK5dGDa9OezfitVps)i5o8tOxkCYKsA7KA8HQG9B28yw0dbQc0(Sfw7m0lXbtjynExujl6yGb0WBN(cjYkqgq7LckJEsIXvQNqXYMnpMf9qGQaTpBH1odPkH9sCWucwJ3fvYIogyan82PVqIScKb0E14DrDPDgcRa4sJ74XSOhISuitpEPbPbVlUkb5UhxyYbinLhtuLq1JxAqAW7IRcaK5NIcsvqzOzQJJ2GHSka1db7(soQ0JYDG4KqynExujc2lxtlGYxX3HFcxKTTd8bItcHFjhv6rVu(k(o8t4ISTDGFjhv6rVinnE0(cHpGmFaSdOhLiRaz69r6hj3HFc9sHtMusBNuJpufSFZMhZIEiqvG2NTWANHEjoykbRX7IkzrhdmGgE70xirwbYaAVuqz0tsmUs9ekw2S5XSOhcufO9zlS2zivjSxIdMsWA8UOsw0XadOH3o9fsKvGmG2RgVlQlTZqyfaxAChpMf9qKLcz6Xlnin4DXvji394ctoaPP8yIQeQE8sdsdExCvaGm)uuqQckdntDEylVFNradB5GzoirzdmSjMdBnnB9WMtmfmRpSftHTbJpbbBzHNSHd(UqWwmf2AA2YN5chqgBqcgHOSvaSLbEKTsKfUiBfjKnfWwouAx5H8XuhhTbdzvaQhc298DgbmWkM5GevUMwaXbtjynExujc27LYV0G0G3fxLGC3Jlm5aKMYJjVzbrXhoiKGq6b(XSOhIaQ4fPPXJ2xi8bK5dGDa9OezfqXXbol8eM4Gtzh7H27J0psUd)e6LYONKyCL6juS4LYf0xIMErU7RLKJxkWbFxiwfKUpTcvbcNFpUIVd)eUWbFxiGF0fh4diZVhSaTxnExuxANHWkaU04oEml6HiRmzQzQZtEytuXiP3yHn57Onyim15HTCB3BIgPT4Zgyytg5q1SL3VZiGHTCWmhKOm1XrBWqwefJKEJfbNVZiGbwXmhKOY10c0iHJUM29wjAK2I)cNWpHfVehmLG14DrLiRaz49aY8bWoGEuIScKPxnExuxANHWkaU04oEml6HiluMPopSLB7Et0iTfF2adB7ZHQztCchYnqzt(LCuPhzQJJ2GHSikgj9glEiy3xYrLEuUMwGgjC010U3krJ0w8x4e(jS49aY8bWoGEuIScKPxnExuxANHWkaU04oEml6HiluMPopSjk5R4tl5IunBYNJtcc2apBYps)i5MniB9MnFjAASWguk(hOiHPooAdgYIOyK0BS4HGDDaGe8JeG0Fq5Obp8GEQc2ZuhhTbdzrums6nw8qWUUX)afL7aXjHWA8UOseSxUMwGgjC0frYxXNwYfx4e(jS4LIhZIEiqDVWB24KjL02j14dvb7H2RgVlQlTZqyfaxAChpMf9qKvyM68WMOKVIpTKlYMhSLpEsCzdmSTphQMn5hPFKCZguk(hOiBHYMEJSHtHnanBefJKEZMcyZfv2YcpzRi9H2GHnFKg8iB5JNKyCL6juKPooAdgYIOyK0BS4HGDDaGe8JeG0Fq5Obp8GEQc2ZuhhTbdzrums6nw8qWUUX)afLRPfOrchDrK8v8PLCXfoHFclE1iHJUqpjX4k1tO4cNWpHfVXr7leghmRrIG9E9LOPxejFfFAjxC9yw0dbQ7xYGPooAdgYIOyK0BS4HGDZK0ofkkxtlqJeo6Ii5R4tl5IlCc)ew8Eaz(ayhqpkbQcKbtntDEYdBcDmn5MPopSbf2ttUzdYwVzll8KT8cfzJg8SLB7ERensBXxo2KMesiSjr6XLTDcd9obbBI3rbajHPooAdgY6kMMCl4k(o8tOCtKHcM29wjAK2Ip8Xb(aMsRnyK7kssOakO8lnin4DXvbd9obbm5okaijErAA8O9fcFaz(ayhqpkrwbhh4SWtyIdofO3SHIxAqAW7IRcg6DccyYDuaqs8Eaz(ayhqpkbQcdntDEytOJPj3SbzR3SLpEsCzZd2YTDVvIgPT4t1Sjpcp7mPm2YluKTykSLpEsCz7XOabB0GNTb9uzdkL3DIPooAdgY6kMMC7HGDVIPj3Y10c0iHJUqpjX4k1tO4cNWpHfVAKWrxt7ERensBXFHt4NWI3R47WpHRPDVvIgPT4dFCGpGP0AdgVhaivaqol0tsmUs9ekUEml6Ha19m15HnHoMMCZgKTEZwUT7Ts0iTfF28GTCbSLpEsCPA2KhHNDMugB5fkYwmf2eACkOQbBsom1XrBWqwxX0KBpeS7vmn5wUMwGgjC010U3krJ0w8x4e(jS4LYAKWrxONKyCL6juCHt4NWI3R47WpHRPDVvIgPT4dFCGpGP0AdgVf0xIMEDHtbvnwsom1XrBWqwxX0KBpeSRdaKGFKaK(dkhn4Hh0tvWE5qp1pGJmG0OcKz(zQJJ2GHSUIPj3Eiy3RyAYTCnTans4OlIKVIpTKlUWj8tyX7basfaKZYn(hO4sYXlffGUCJ)bkUEK(rYD4NWnBkOVen96cNcQASKC8wa6Yn(hO4YjtkPTtQXhQc2dT3diZha7a6rjRcs3NwLvafehmLG14DrLSOJbgqdVD6lKiRqPYeAVF0fy8chDfLcz1JS7fMPopSj0X0KB2GS1B2KhbrXNn5JqcspunBYVKJk9OhqP4FGISnaLTEy7r6hj3S9X4IYXwr67XLnHgNcQA4H4DFTyteI5WgKTEZMi6qAcB09ej2UBLTMMnhaH0(jCXuhhTbdzDfttU9qWUxX0KB5AAbuOrchDLfefF4GqccPNfoHFclB28sdsdExCLf)wyanSEJWzbrXhoiKGq6bAVuUa01l5OspUEK(rYD4NqVfGUCJ)bkUEml6HiRm8wqFjA61fofu1yj54LIc6lrtVi391sYzZMc6lrtVUWPGQgRhZIEiqvMB2ua6IGoKMS0(SThxO9wa6IGoKMSEml6Havzufjo4PMRW5xOw1QwR]] )

end