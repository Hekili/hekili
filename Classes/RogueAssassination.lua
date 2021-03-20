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


    spec:RegisterPack( "Assassination", 20210319, [[davVacqiKOEKsrDjLcYMOs(essJcO6uiHvbe1RqvzwOQ6wkfAxk5xkvAyivCmLQwgsvpdvPMgsLUMsr2gQs4Bar04ukOCoKiADir6DOkrrZdiCpKY(qv8puLOWbvQOwisIhksQjcePlQuGnIQe5JiryKOkrvNuKeTsKuVuPGQzIQKUPijStQunuLk0sfjPNIstvK4QOkrPTQubFficgRsfzVs6VagmLdlSyr8yvmzjUm0MrXNPQgTk1PLA1OkrLxRuA2I62uLDR43QA4uXXbIqlh0ZrmDsxhv2Uk57aLXtLY5bsZxKA)ex3xtPYwcfRUtpDOFpD49Ek5IEEtx63tjRSkOoyL1joBdFSYoHhwz3zcjiKEcT)PY6eGM)OutPYsEo4bRS3Q6qO0D31V1BUK1592L0EC5q7FoWGr3L0ENDRSjCDwtLtnPYwcfRUtpDOFpD49Ek5IEEtx63Z7kBWP3pSYY2EPUYE3Lco1KkBbjNk7otibH0tO9pILQVphkuNkc45wS9us(fJE6q)EHAH6uFhJpsOuH6nk2o74KbvmQsuyFuQkgto8ftFXiVhk2oVJ8QympClrm9fJexOyoW)Gesp(IPThUQS5MOKAkvwIIrwVXsnLQ77RPuzXjsYyPsLkBC0(Nk7b2EKFau0ZbjALTGKdSD0(NkR7T)nrJ8wek2pIX7uOuXsnS9i)iwkONds0k7b2kc7OYQrghDnT)Ts0iVfHlCIKmweZLyehmNb0a6JkrmEOjgVfZLyN3l5bC(EuIy8qtm6kMlX0a6J6sBpeqFGsJITrXGOx0drmEeJxu1Q70xtPYItKKXsLkv24O9pvwiNJYbXkBbjhy7O9pvw3B)BIg5TiuSFeBFkuQySt4qUFvSuLZr5GyL9aBfHDuz1iJJUM2)wjAK3IWforsglI5sSZ7L8aoFpkrmEOjgDfZLyAa9rDPThcOpqPrX2Oyq0l6HigpIXlQA1DExtPYItKKXsLkv24O9pvwN)ZaqK8CWdwzli5aBhT)PYYYLOiKHZhPuX2zhNmOI9qXsvKbIKBXaR1BXs4yyWIyuIacFfjvwMhcmOBA199vT6oDRPuzXjsYyPsLkBC0(NkRFaHVIv2dSve2rLvJmo6IWLOiKHZhx4ejzSiMlXaxmi6f9qedeITNEXsNwmhpUS2o5gHIbcAITxmkeZLyAa9rDPThcOpqPrX2Oyq0l6HigpIrFL9a6jJaAa9rLuDFFvRUVPAkvwCIKmwQuPYghT)PY68FgaIKNdEWkBbjhy7O9pvwwUefHmC(Oy8j2g4gXxSFeBFkuQyPkYarYTyuIacFffluX0BumCkI9mIrumY6Ty6lMpQI5fUjwHdgA)JyjiZdrX2a3iX4Z1tOyLL5Had6MwDFFvRUZlQPuzXjsYyPsLk7b2kc7OYQrghDr4sueYW5JlCIKmweZLyAKXrxOBKy856juCHtKKXIyUeloAFHa4GEnseJMy7fZLyjCmmlcxIIqgoFCbrVOhIyGqS9lExzJJ2)uz9di8vSQv3bjRPuzXjsYyPsLk7b2kc7OYQrghDr4sueYW5JlCIKmweZLyN3l5bC(EuIyGGMy8UYghT)PY6XPDouSQvTYEfttURPuDFFnLklorsglvQuzFNklb1kBC0(Nk7va7ijJv2RiZHvwWfJYIb5gK5H(4QGHENbfGChLhmYcNijJfXCjgYWGhTVqGZ7L8aoFpkrmEOj2XbWlCdG4GtrmkelDAXaxmi3Gmp0hxfm07mOaK7O8Grw4ejzSiMlXoVxYd489OeXaHy0lgfv2csoW2r7FQS8s90KBXaR1BX8c3el17Oympum3B)BLOrElc5xmUjJeIyCKE8fdKIHENbvm27O8GrQSxbeycpSYoT)Ts0iVfHahhGZpLw7FQA1D6RPuzXjsYyPsLkBC0(Nk7vmn5UYwqYb2oA)tLDhIPj3IbwR3ITbUr8fJpXCV9VvIg5TiKsflveU1ECEIL6DuSykITbUr8fdIrbuXyEOyd6MkgLi1G0k7b2kc7OYQrghDHUrIXNRNqXforsglI5smnY4ORP9VvIg5TiCHtKKXIyUe7kGDKKX10(3krJ8wecCCao)uAT)rmxID(pxEWMf6gjgFUEcfxq0l6HigieBFvRUZ7AkvwCIKmwQuPYghT)PYEfttURSfKCGTJ2)uz3HyAYTyG16TyU3(3krJ8wekgFI5(l2g4gXNsflveU1ECEIL6DuSykITd4uqvdX4CQShyRiSJkRgzC010(3krJ8weUWjsYyrmxIrzX0iJJUq3iX4Z1tO4cNijJfXCj2va7ijJRP9VvIg5Tie44aC(P0A)JyUeRGjCmmRlCkOQXIZPQv3PBnLklorsglvQuzJJ2)uzD(pdarYZbpyLfDtHbq49CJwzP7MQSmpeyq30Q77RA19nvtPYItKKXsLkv2dSve2rLvJmo6IWLOiKHZhx4ejzSiMlXo)NlpyZYpGWxXfNJyUedCXkVU8di8vCbrgisUJKmkw60IvWeogM1fofu1yX5iMlXkVU8di8vC54XL12j3iumqqtS9IrHyUe78EjpGZ3JswfKPpTkgp0edCXioyodOb0hvYIjgGNby70xirmE4LHy0vmkeZLyWOla4fo6kkfYQhX4rS90xzJJ2)uzVIPj3vT6oVOMsLfNijJLkvQSXr7FQSxX0K7kBbjhy7O9pv2DiMMClgyTElwQiikcfBNjKG0dLkwQY5OCqKpkraHVIInVkwpIbrgisUfdgJpYVyfoyp(ITd4uqvd(yV7RLySGohXaR1BXyrhsteJPNil2DRI1mI58esNKXvL9aBfHDuzbxmnY4OlVGOieiiKGq6zHtKKXIyPtlgKBqMh6JlVaUf4za0BeWlikcbccjiKEw4ejzSigfI5smklw51fKZr5G4cImqKChjzumxIvED5hq4R4cIErpeX4rmElMlXkychdZ6cNcQAS4CeZLyGlwbt4yywK7(AX5iw60IvWeogM1fofu1ybrVOhIyGqm6kw60IvEDrqhstwAF22JVyuiMlXkVUiOdPjli6f9qedeIX7Qw1kBbzcUSwtP6((Akv24O9pv2T9zBLfNijJLkvQA1D6RPuzXjsYyPsLkBbjhy7O9pv2ufjkgz9wSMrmNNq6Kmkg4Zl2fxEqyKKrXWb9AKiwpIDEVKqPOYghT)PYsumY6DvRUZ7AkvwCIKmwQuPY(ovwcQv24O9pv2Ra2rsgRSxrMdRS4GqFqxq0hhX4tmNVj)GfGKmIfIyGSyByITRyGlg9IbYIrCWCg4oikkgfv2RacmHhwzXbH(GcarFCaoVxspyPQv3PBnLklorsglvQuzFNklb1kBC0(Nk7va7ijJv2RiZHvwIdMZaAa9rLSyIb4za2o9fsedeIrFL9kGat4Hvwsp(zeqdOpQvT6(MQPuzXjsYyPsLk7b2kc7OYsumY6nwwW3NdRSef2hT6((kBC0(Nk7jYzG4O9pa5MOv2CtuGj8WklrXiR3yPQv35f1uQS4ejzSuPsL9aBfHDuzbxmklMgzC0Lxqueceesqi9SWjsYyrS0PfR86YpGWxXL2NT94lgfvwIc7JwDFFLnoA)tL9e5mqC0(hGCt0kBUjkWeEyL9uivT6oiznLklorsglvQuzJJ2)uzj5(GaXuak9bRSfKCGTJ2)uz3rovm2bKkgNJy90Ah5mOIX8qXsnNkM(IP3OyP(oii)IbrgisUfdSwVfBdMlCEpXAgXcvS8dMyfoyO9pv2dSve2rLLYILWXWSi5(GaXuak9bxCoI5sSZ7L8aoFpkrmEOjgVRA19nSAkvwCIKmwQuPYEGTIWoQSjCmmlsUpiqmfGsFWfNJyUelHJHzrY9bbIPau6dUGOx0drmqi2MeZLyN3l5bC(EuIy8qtm6wzJJ2)uzX5cN3RQv3PK1uQS4ejzSuPsLnoA)tL9e5mqC0(hGCt0kBUjkWeEyLT8AvRUVNo1uQS4ejzSuPsLnoA)tL9e5mqC0(hGCt0kBUjkWeEyLT0q8OvT6((91uQS4ejzSuPsL9aBfHDuzXbH(GUkitFAvmEOj2(njgFIDfWosY4che6dkae9Xb48Ej9GLkBC0(NkBapXGa6dH4OvT6(E6RPuzJJ2)uzd4jgeWHltWklorsglvQu1Q775DnLkBC0(NkBU9VvcaVCCfFpC0klorsglvQu1Q77PBnLkBC0(NkBs4d8makSpBjvwCIKmwQuPQvTY6aXZ7LeAnLQ77RPuzJJ2)uzdhNmOaoFt(PYItKKXsLkvT6o91uQSXr7FQSjVQzSaWKdqXcy94dOVB9uzXjsYyPsLQwDN31uQS4ejzSuPsLnoA)tL1lGBXcaZdbkyO3v2dSve2rLfgDbaVWrxrPqw9igpITFtvwhiEEVKqbi45NcPYUPQwDNU1uQS4ejzSuPsL9DQSeuRSXr7FQSxbSJKmwzVciWeEyLvH9SfvacOZbGKFTYEGTIWoQSkSNTOU09R7Gaq0qxXakqXHiMlXaxmklMc7zlQlL(1DqaiAORyafO4qelDAXuypBrDP7xN)ZLhSzv4GH2)igp0etH9Sf1Ls)68FU8GnRchm0(hXOOYwqYb2oA)tLfKIkc96bfdS7(Clg4nJyXakfIr0qflHJHrmf2ZwufdmumWIrftFXcvrphvm9fJa6CedSwVfBhWPGQgRk7vK5Wk7(QwDFt1uQS4ejzSuPsL9DQSeuRSXr7FQSxbSJKmwzVImhwzPVYEGTIWoQSkSNTOUu6x3bbGOHUIbuGIdrmxIbUyuwmf2Zwux6(1DqaiAORyafO4qelDAXuypBrDP0Vo)NlpyZQWbdT)rmEetH9Sf1LUFD(pxEWMvHdgA)JyuuzVciWeEyLvH9SfvacOZbGKFTQv35f1uQS4ejzSuPsLnoA)tLLK7dcetbO0hSYEGTIWoQSqKbIK7ijJvwhiEEVKqbi45NcPYUVQv3bjRPuzJJ2)uzjkgz9UYItKKXsLkvTQv2sdXJwtP6((AkvwCIKmwQuPYghT)PYIZfoVxLTGKdSD0(Nk7gmx48EIfQy0LpXaFt8jgyTElgiLLcXs9oUelv65HLoumdQy)ig98jMgqFuj8lgyTEl2oGtbvn4xShkgyTElwkuHFXE9gHG1eumWIwfJ5HIrEpumCqOpOlX25m5fdSOvXAgX2a3i(IDEVKxSMi2596XxmoNvL9aBfHDuzrgg8O9fcCEVKhW57rjIXdnXORy8jMgzC0vbrhecquyOHp6TWjsYyrmxIbUyfmHJHzDHtbvnwCoILoTyfmHJHzrU7RfNJyPtlwbt4yywm5WhZ5q7FwCoILoTy4GqFqxfKPpTkgiOjg9Bsm(e7kGDKKXfoi0huai6JdW59s6blILoTyuwSRa2rsgxKE8ZiGgqFufJcXCjg4IrzX0iJJUq3iX4Z1tO4cNijJfXsNwSZ)5Yd2Sq3iX4Z1tO4cIErpeX4rm6fJIQwDN(AkvwCIKmwQuPY(ovwcQv24O9pv2Ra2rsgRSxrMdRSN3l5bC(EuYQGm9PvX4rS9ILoTy4GqFqxfKPpTkgiOjg9Bsm(e7kGDKKXfoi0huai6JdW59s6blILoTyuwSRa2rsgxKE8ZiGgqFuRSxbeycpSYYrqaMoNryvRUZ7AkvwCIKmwQuPYghT)PYsqimuSaK8dcqC6TyL9aBfHDuz9cIIqGGqccPhai6f9qeJMy0rmxIbUyjCmmlsUpiqmfGsFWfNJyUeJYIvEDrqimuSaK8dcqC6Tiq51L2NT94lw60IL8eIyUeJP9Vvai6f9qede0eBtILoTyN)ZLhSzrqimuSaK8dcqC6T46ChqFKaWaJJ2)ezX4HMy0Vaj3KyPtlg55Yj9uwzmkajGcGUfEozCHtKKXIyUeJYILWXWSYyuasafaDl8CY4IZrmkQShqpzeqdOpQKQ77RA1D6wtPYItKKXsLkv24O9pvwMyaEgGTtFHKkBbjhy7O9pvwEPye7zeBdF6lKiwOITNsYNyenoBjI9mIXlFxk4igvYrbjI9qXc)OhIkgD5tmnG(Oswv2dSve2rL9kGDKKXfhbby6CgHI5smWflHJHzD3Lcoaj5OGKfrJZwX4HMy7PKILoTyGlgLfZb2pSvqbGVgA)JyUeJ4G5mGgqFujlMyaEgGTtFHeX4HMy0vm(eJOyK1BSSGVphkgfIrrvRUVPAkvwCIKmwQuPYghT)PYYedWZaSD6lKuzpGEYiGgqFujv33xzpWwryhv2Ra2rsgxCeeGPZzekMlXioyodOb0hvYIjgGNby70xirmEOjgVRSfKCGTJ2)uz5LIrSNrSn8PVqIy6lw44KbvmqkgLmOITJFt(rSMrSEIJ2xOy)iwmGkMgqFufluX4TyAa9rLSQA1DErnLklorsglvQuzpWwryhv2Ra2rsgxCeeGPZzekMlXo)NlpyZ6cNcQASGOx0drmEeBpDQSXr7FQS45(7XhaIoW2lMsvRUdswtPYItKKXsLkv2dSve2rL9kGDKKXfhbby6CgHI5smWfZlikcbccjiKEaGOx0drmAIrhXCjgLfdYniZd9Xv5FVKCuWforsglILoTyjCmmRKCpfsxWfNJyuuzJJ2)uzdVeoYDvRUVHvtPYItKKXsLkv24O9pvwpoTZHIv2dONmcOb0hvs199v2dSve2rL9kGDKKXfhbby6CgHI5smIdMZaAa9rLSyIb4za2o9fseJMy0xzli5aBhT)PYMsKSXubN25qrX0xSWXjdQyGumkzqfBh)M8JyHkg9IPb0hvsvRUtjRPuzXjsYyPsLk7b2kc7OYEfWosY4IJGamDoJWkBC0(NkRhN25qXQw1k7PqQPuDFFnLklorsglvQuzJJ2)uz9c4wSaW8qGcg6DL9a6jJaAa9rLuDFFL9aBfHDuzHrxaWlC0vukKfNJyUedCX0a6J6sBpeqFGsJIbcXoVxYd489OKvbz6tRIbYITFTjXsNwSZ7L8aoFpkzvqM(0Qy8qtSJdGx4gaXbNIyuuzli5aBhT)PYMkzelkfIybefJZHFXit7GIP3Oy)GIbwR3ILFWqIkwkPasxIXllbfdSBCeRaAp(IXeefHIP3XiwQ3rXkitFAvShkgyTE)CQyXaQyPEhxvT6o91uQS4ejzSuPsLnoA)tL1lGBXcaZdbkyO3v2csoW2r7FQSPsgXMxSOuiIbwNZIvAumWA9UhX0BuSbDtfJ30HWVyCeuSubdivSFel5jeXaR17Ntflgqfl174QYEGTIWoQSWOla4fo6kkfYQhX4rmEthX2OyWOla4fo6kkfYQWbdT)rmxIDEVKhW57rjRcY0NwfJhAIDCa8c3aio4uQA1DExtPYItKKXsLkv24O9pvwMC4J5CO9pv2csoW2r7FQSSGohX4LYHpMZH2)igyTEl2oGtbvneliIL)XxSGigyOyG9dvvXYpbfle7eevS)cHIP3OymT)TkwHdgA)tL9aBfHDuzPSyefJSEJLf895qXCjg4ID(pxEWM1fofu1ybrVOhIyGqmElMlXqgg8O9fcCEVKhW57rjIXdnXORyUetdOpQlT9qa9bknkgpITNoILoTyfmHJHzDHtbvnwCoILoTyjpHiMlXyA)BfaIErpeXaHy0txXOOQv3PBnLklorsglvQuzpWwryhvwklgrXiR3yzbFFoumxIHmm4r7le48EjpGZ3JseJhAIrxXCjg4IXK)hkg4IbUymT)TcarVOhIyBum6PRyui2UIfhT)b48FU8GnIrHy8igt(FOyGlg4IX0(3kae9IEiITrXONUITrXo)NlpyZ6cNcQASGOx0drmqwSRa2rsgxx4uqvdGtbkgfITRyXr7Fao)NlpyJyuigfv24O9pvwMC4J5CO9pvT6(MQPuzXjsYyPsLkBC0(NklbDinPYwqYb2oA)tLLf05igl6qAIyG16Ty7aofu1qSGiw(hFXcIyGHIb2puvfl)euSqStquX(lekMEJIX0(3QyfoyO9p8lwcNkMdezqOyAa9rLiMEhQyG15Sy5(cfluXYyquX2thsL9aBfHDuzPSyefJSEJLf895qXCjg4ID(pxEWM1fofu1ybrVOhIyGqS9I5smnG(OU02db0hO0Oy8i2E6iw60IvWeogM1fofu1yX5iw60IX0(3kae9IEiIbcX2thXOOQv35f1uQS4ejzSuPsL9aBfHDuzPSyefJSEJLf895qXCjg4IXK)hkg4IbUymT)TcarVOhIyBuS90rmkeBxXIJ2)aC(pxEWgXOqmEeJj)pumWfdCXyA)BfaIErpeX2Oy7PJyBuSZ)5Yd2SUWPGQgli6f9qedKf7kGDKKX1fofu1a4uGIrHy7kwC0(hGZ)5Yd2igfIrrLnoA)tLLGoKMu1Q7GK1uQS4ejzSuPsL9DQSeuRSXr7FQSxbSJKmwzVImhwzPSyAKXrxt7FRenYBr4cNijJfXsNwmklMgzC0f6gjgFUEcfx4ejzSiw60ID(pxEWMf6gjgFUEcfxq0l6HigieBtITrXOxmqwmnY4ORcIoieGOWqdF0BHtKKXsLTGKdSD0(NkllOZrSDaNcQAigy9uEWedSwVfZ92)wjAK3Iq(2a3iX4Z1tOOynJyHJtUprsgRSxbeycpSYEHtbvnaM2)wjAK3IqGZpLw7FQA19nSAkvwCIKmwQuPY(ovwcQv24O9pv2Ra2rsgRSxbeycpSYEHtbvnao)foXOaNFkT2)uzpWwryhv2ZFHtm6AlOWogXsNwSZFHtm6AWd8ZpSiw60ID(lCIrxZpyLTGKdSD0(NkllOZrSDaNcQAigyTElgVuo8XCo0(hXIPigl6qAIybrS8p(IfeXadfdSFOQkw(jOyHyNGOI9xium9gfJP9VvXkCWq7FQSxrMdRS7RA1DkznLklorsglvQuzFNklb1kBC0(Nk7va7ijJv2RiZHvwM8)qXaxmWfJP9Vvai6f9qeBJIrpDeJcX2vmWfBp90rmqwSRa2rsgxx4uqvdGtbkgfIrHy8igt(FOyGlg4IX0(3kae9IEiITrXONoITrXo)NlpyZIjh(yohA)ZcIErpeXOqSDfdCX2tpDedKf7kGDKKX1fofu1a4uGIrHyuiw60ILWXWSyYHpMZH2)aKWXWS4CelDAXkychdZIjh(yohA)ZIZrS0PfJP9Vvai6f9qedeIrpDQShyRiSJk75VWjgDDHJEdkSYEfqGj8Wk7fofu1a48x4eJcC(P0A)tvRUVNo1uQS4ejzSuPsL9DQSeuRSXr7FQSxbSJKmwzVImhwzzY)dfdCXaxmM2)wbGOx0drSnkg90rmkeBxXaxS90thXazXUcyhjzCDHtbvnaofOyuigfIXJym5)HIbUyGlgt7FRaq0l6Hi2gfJE6i2gf78FU8Gnlc6qAYcIErpeXOqSDfdCX2tpDedKf7kGDKKX1fofu1a4uGIrHyuiw60IvEDrqhstwAF22JVyPtlgt7FRaq0l6HigieJE6uzpWwryhv2ZFHtm6AA)BfGjWk7vabMWdRSx4uqvdGZFHtmkW5NsR9pvT6((91uQS4ejzSuPsL9aBfHDuzPSyefJSEJLf895qXCjw51fKZr5G4s7Z2E8fZLyuwScMWXWSUWPGQglohXCj2va7ijJRlCkOQbW0(3krJ8wecC(P0A)JyUe7kGDKKX1fofu1a48x4eJcC(P0A)tLnoA)tL9cNcQAu1Q77PVMsLfNijJLkvQSXr7FQSOBKy856juSYwqYb2oA)tLDdCJeJpxpHIIb2noInVkgrXiR3yrSykIL86TyPkNJYbrXIPigLiGWxrXcikgNJympuS8p(IHZZ5FVQShyRiSJklLfJOyK1BSSGVphkMlXaxmklw51LFaHVIliYarYDKKrXCjw51fKZr5G4cIErpeX4rm6kgFIrxXazXooaEHBaehCkILoTyLxxqohLdIli6f9qedKfJoRnjgpIPb0h1L2EiG(aLgfJcXCjMgqFuxA7Ha6duAumEeJUvT6(EExtPYItKKXsLkv24O9pvwYDFvzli5aBhT)PYYE3xI1mIbgkwarXIKNtftFX2G5cN3JFXIPiwOk65OIPVyeqNJyG16TySOdPjIX0tKf7UvXAgXadfdSFOQkgybrrX8EikMEhJy3rMrm9gf78FU8GnRk7b2kc7OYwEDb5CuoiU0(SThFXCjg4IrzXo)NlpyZIGoKMSGyuavS0Pf78FU8GnRlCkOQXcIErpeX4rS90lgfILoTyLxxe0H0KL2NT94x1Q77PBnLklorsglvQuzpWwryhv2eogMvs()sMJOlighvS0Pfl5jeXCjgt7FRaq0l6HigieJ30rS0PfRGjCmmRlCkOQXIZPYghT)PY68A)tvRUVFt1uQS4ejzSuPsL9aBfHDuzlychdZ6cNcQAS4CQSXr7FQSj5)lamCqqRA1998IAkvwCIKmwQuPYEGTIWoQSfmHJHzDHtbvnwCov24O9pv2eesq42E8RA199GK1uQS4ejzSuPsL9aBfHDuzlychdZ6cNcQAS4CQSXr7FQSmnetY)xQA199By1uQS4ejzSuPsL9aBfHDuzlychdZ6cNcQAS4CQSXr7FQSXCqIcJmWjY5QwDFpLSMsLfNijJLkvQShyRiSJklLfJOyK1BSSICwmxI5fefHabHeespaq0l6HignXOtLnoA)tL9e5mqC0(hGCt0kBUjkWeEyL9kMMCx1Q70tNAkvwCIKmwQuPYghT)PYQWE2I6(kBbjhy7O9pvwwqNJy6nkMdSFyRGkgrdvSeoggXuypBrvmWA9wSDaNcQAWVyVEJqWAckghbf7hXo)NlpytL9aBfHDuzVcyhjzCPWE2Ikab05aqYVkgnX2lMlXaxScMWXWSUWPGQglohXsNwSKNqeZLymT)TcarVOhIyGGMy0thXOqS0PfdCXUcyhjzCPWE2Ikab05aqYVkgnXOxmxIrzXuypBrDP0Vo)NlpyZcIrbuXOqS0PfJYIDfWosY4sH9SfvacOZbGKFTQv3PFFnLklorsglvQuzpWwryhv2Ra2rsgxkSNTOcqaDoaK8RIrtm6fZLyGlwbt4yywx4uqvJfNJyPtlwYtiI5smM2)wbGOx0drmqqtm6PJyuiw60IbUyxbSJKmUuypBrfGa6Cai5xfJMy7fZLyuwmf2Zwux6(15)C5bBwqmkGkgfILoTyuwSRa2rsgxkSNTOcqaDoaK8Rv24O9pvwf2ZwuPVQvTYwETMs1991uQS4ejzSuPsL9DQSeuRSXr7FQSxbSJKmwzVImhwzDG9dBfua4RH2)iMlXioyodOb0hvYIjgGNby70xirmEeJ3I5smWfR86YpGWxXfe9IEiIbcXo)NlpyZYpGWxXvHdgA)JyPtlMZ3KFWcqsgXcrmEeBtIrrLTGKdSD0(NklV2ETkgLiGWxrIy)i28ZgDGThmGGkMgqFujIX8qX0Bumhy)Wwbvm4RH2)iwZi2M4tSKmIfIybeflYqmkGkgNtL9kGat4HvwY22b4a6jJa(be(kw1Q70xtPYItKKXsLkv23PYsqTYghT)PYEfWosYyL9kYCyL1b2pSvqbGVgA)JyUeJ4G5mGgqFujlMyaEgGTtFHeX4rmElMlXaxScMWXWSi391IZrS0PfZ5BYpybijJyHigpITjXOOYwqYb2oA)tLLxBVwflv5Cuoise7hXMF2OdS9GbeuX0a6JkrmMhkMEJI5a7h2kOIbFn0(hXAgX2eFILKrSqelGOyrgIrbuX4CQSxbeycpSYs22oahqpzeaY5OCqSQv35DnLklorsglvQuzFNklb1kBC0(Nk7va7ijJv2RiZHv2cMWXWSUWPGQglohXCjg4IvWeogMf5UVwCoILoTyEbrriqqibH0dae9IEiIXJy0rmkeZLyLxxqohLdIli6f9qeJhXOVYwqYb2oA)tLLxBVwflv5CuoiseRzeBhWPGQg8XE3x7MkcIIqX2zcjiKEeRjIX5iwmfXadf7oUqXONpXi45NcrSmYOI9Jy6nkwQY5OCqumq6NsL9kGat4HvwY22baY5OCqSQv3PBnLklorsglvQuzJJ2)uz9di8vSYwqYb2oA)tLL1bpDKfJseq4ROyXuelv5CuoikgbvohXCG9dftFX2a3iX4Z1tOOyNGOv2dSve2rLvJmo6cDJeJpxpHIlCIKmweZLyuwScMWXWS8di8vCHUrIXNRNqXIyUeR86YpGWxXLJhxwBNCJqXabnX2lMlXo)NlpyZcDJeJpxpHIli6f9qedeIrVyUeJ4G5mGgqFujlMyaEgGTtFHeXOj2EXCjgm6caEHJUIsHS6rmEeJxiMlXkVU8di8vCbrVOhIyGSy0zTjXaHyAa9rDPThcOpqPXQwDFt1uQS4ejzSuPsL9aBfHDuz1iJJUq3iX4Z1tO4cNijJfXCjg4IHmm4r7le48EjpGZ3JseJhAIDCa8c3aio4ueZLyN)ZLhSzHUrIXNRNqXfe9IEiIbcX2lMlXkVUGCokhexq0l6HigilgDwBsmqiMgqFuxA7Ha6duAumkQSXr7FQSqohLdIvT6oVOMsLfNijJLkvQSXr7FQSo)NbGi55GhSYwqYb2oA)tLLseq4ROyCoBr0HFXIm5ftHnsetFX4iOyTkwqeleJ4GNoYI5Jdcd9HIX8qX0BuSCquXs9okwcY8quSqmMEAYncRSmpeyq30Q77RA1DqYAkvwCIKmwQuPYEGTIWoQSqKbIK7ijJI5sSZ7L8aoFpkzvqM(0Qy8qtS9I5smWfZXJlRTtUrOyGGMy7flDAXGOx0drmqqtmTpBb02dfZLyehmNb0a6JkzXedWZaSD6lKigp0eJ3IrHyUedCXOSyOBKy856juSiw60IbrVOhIyGGMyAF2cOThkgilg9I5smIdMZaAa9rLSyIb4za2o9fseJhAIXBXOqmxIbUyAa9rDPThcOpqPrX2Oyq0l6HigfIXJy0vmxI5fefHabHeespaq0l6HignXOtLnoA)tL1pGWxXQwDFdRMsLfNijJLkvQSmpeyq30Q77RSXr7FQSo)NbGi55GhSQv3PK1uQS4ejzSuPsLnoA)tL1pGWxXk7b2kc7OYszXUcyhjzCr22oahqpzeWpGWxrXCjgezGi5osYOyUe78EjpGZ3JswfKPpTkgp0eBVyUedCXC84YA7KBekgiOj2EXsNwmi6f9qede0et7ZwaT9qXCjgXbZzanG(OswmXa8maBN(cjIXdnX4TyuiMlXaxmklg6gjgFUEcflILoTyq0l6HigiOjM2NTaA7HIbYIrVyUeJ4G5mGgqFujlMyaEgGTtFHeX4HMy8wmkeZLyGlMgqFuxA7Ha6duAuSnkge9IEiIrHy8i2E6fZLyEbrriqqibH0dae9IEiIrtm6uzpGEYiGgqFujv33x1Q77PtnLklorsglvQuzJJ2)uzpW2J8dGIEoirRSfKCGTJ2)uztnS9i)iwkONdsuX(rmpUS2ozumnG(OseluXOlFIL6DumWUXrmi3m94l2ZPI1Jy0tedCohX0xm6kMgqFujui2dfJ3eXaFt8jMgqFujuuzpWwryhvwIdMZaAa9rLigp0eJEXCjge9IEiIbcXOxm(edCXioyodOb0hvIy8qtSnjgfI5smKHbpAFHaN3l5bC(EuIy8qtm6w1Q773xtPYItKKXsLkv24O9pvwiNJYbXkBbjhy7O9pv2nCeDeJZrSuLZr5GOyHkgD5tSFelYzX0a6JkrmWb7ghXY9vp(IL)XxmCEo)BXIPi28QyKjCi3VsrL9aBfHDuzPSyxbSJKmUiBBhaiNJYbrXCjgYWGhTVqGZ7L8aoFpkrmEOjgDfZLyqKbIK7ijJI5smWfZXJlRTtUrOyGGMy7flDAXGOx0drmqqtmTpBb02dfZLyehmNb0a6JkzXedWZaSD6lKigp0eJ3IrHyUedCXOSyOBKy856juSiw60IbrVOhIyGGMyAF2cOThkgilg9I5smIdMZaAa9rLSyIb4za2o9fseJhAIXBXOqmxIPb0h1L2EiG(aLgfBJIbrVOhIy8ig4IrxX4tmi3Gmp0hxLGC3Jpa58CtbI5forsglIbYIrjfJpXGCdY8qFCv(3ljhfCHtKKXIyGSy8cXOOQv33tFnLklorsglvQuzJJ2)uzHCokheRShyRiSJklLf7kGDKKXfzB7aCa9KraiNJYbrXCjgLf7kGDKKXfzB7aa5CuoikMlXqgg8O9fcCEVKhW57rjIXdnXORyUedImqKChjzumxIbUyoECzTDYncfde0eBVyPtlge9IEiIbcAIP9zlG2EOyUeJ4G5mGgqFujlMyaEgGTtFHeX4HMy8wmkeZLyGlgLfdDJeJpxpHIfXsNwmi6f9qede0et7ZwaT9qXazXOxmxIrCWCgqdOpQKftmapdW2PVqIy8qtmElgfI5smnG(OU02db0hO0OyBumi6f9qeJhXaxm6kgFIb5gK5H(4QeK7E8biNNBkqmVWjsYyrmqwmkPy8jgKBqMh6JRY)Ej5OGlCIKmwedKfJxigfv2dONmcOb0hvs199vT6(EExtPYItKKXsLkv24O9pv2dS9i)aOONds0kBbjhy7O9pv2udBpYpILc65GevSFeJnfXAgX6rmNykOxFelMIydgWmOI5fUjgoi0huXIPiwZi2gmx48EIb2puvfR8I59quSs4f(Oyfoum9flfQSBQyNRShyRiSJklXbZzanG(OseJMy7fZLyuwmi3Gmp0hxLGC3Jpa58CtbI5forsglI5smVGOieiiKGq6baIErpeXOjgDeZLyiddE0(cboVxYd489OeX4HMyGl2XbWlCdG4GtrSnk2EXOqmxIbrgisUJKmkMlXOSyOBKy856juSiMlXOSyfmHJHzrU7RfNJyUedCXWbH(GUkitFAvmqqtm63Ky8j2va7ijJlCqOpOaq0hhGZ7L0dweJcXCjMgqFuxA7Ha6duAuSnkge9IEiIXJy0TQvTQv2les6FQUtpDOFpD49EkzLfSao94tQSGe25u19uP7uckvmXs5gfR9CEOkgZdfJQxX0KBQkgebjY1qSig59qXco99cflIDUJXhjlHAEThuS9uQyP(NleQyrmQc5gK5H(4ANOQy6lgvHCdY8qFCTtlCIKmwOQyGtVBuSeQ51EqX4fuQyP(NleQyrmQc5gK5H(4ANOQy6lgvHCdY8qFCTtlCIKmwOQyGV3nkwc1c1Ge25u19uP7uckvmXs5gfR9CEOkgZdfJQfKj4YkvfdIGe5AiweJ8EOybN(EHIfXo3X4JKLqnV2dkgVPuXs9pxiuXIySTxQfJa6OHBITHetFX4vUqSsF1K(hXEheg6dfd8DPqmW37gflHAHAqc7CQ6EQ0DkbLkMyPCJI1EopufJ5HIrvhiEEVKqPQyqeKixdXIyK3dfl403luSi25ogFKSeQ51EqXOlLkwQ)5cHkweJQkSNTOU2V2jQkM(Irvf2Zwux6(1orvXaNE3OyjuZR9GIrxkvSu)ZfcvSigvvypBrDr)ANOQy6lgvvypBrDP0V2jQkg407gflHAEThuSnrPIL6FUqOIfXOQc7zlQR9RDIQIPVyuvH9Sf1LUFTtuvmWP3nkwc18ApOyBIsfl1)CHqflIrvf2Zwux0V2jQkM(Irvf2Zwuxk9RDIQIbo9UrXsOwOgKWoNQUNkDNsqPIjwk3OyTNZdvXyEOyuT0q8OuvmicsKRHyrmY7HIfC67fkwe7ChJpswc18ApOyGKuQyP(NleQyrmQc5gK5H(4ANOQy6lgvHCdY8qFCTtlCIKmwOQyGV3nkwc1c1Ge25u19uP7uckvmXs5gfR9CEOkgZdfJQNcHQIbrqICnelIrEpuSGtFVqXIyN7y8rYsOMx7bfJUuQyP(NleQyrm22l1IraD0WnX2qIPVy8kxiwPVAs)JyVdcd9HIb(Uuig407gflHAEThumEbLkwQ)5cHkweJT9sTyeqhnCtSnKy6lgVYfIv6RM0)i27GWqFOyGVlfIbo9UrXsOMx7bfJssPIL6FUqOIfXyBVulgb0rd3eBdjM(IXRCHyL(Qj9pI9oim0hkg47sHyGtVBuSeQ51EqX2thkvSu)ZfcvSigB7LAXiGoA4MyBiX0xmELleR0xnP)rS3bHH(qXaFxkedC6DJILqnV2dkg90Hsfl1)CHqflIrvf2Zwux0V2jQkM(Irvf2Zwuxk9RDIQIb(E3OyjuZR9GIr)EkvSu)ZfcvSigvvypBrDTFTtuvm9fJQkSNTOU09RDIQIb(E3OyjuludsyNtv3tLUtjOuXelLBuS2Z5HQympumQwELQIbrqICnelIrEpuSGtFVqXIyN7y8rYsOMx7bfJUuQyP(NleQyrmQIUrIXNRNqXYANOQy6lgvlychdZANwOBKy856juSqvXaFVBuSeQ51EqX2VNsfl1)CHqflIrvi3Gmp0hx7evftFXOkKBqMh6JRDAHtKKXcvfdC6DJILqnV2dk2E6PuXs9pxiuXIyufYniZd9X1orvX0xmQc5gK5H(4ANw4ejzSqvXaNE3OyjuZR9GITN3uQyP(NleQyrmQc5gK5H(4ANOQy6lgvHCdY8qFCTtlCIKmwOQyGV3nkwc1c1PCJIrvocc0k6rOQyXr7FedSGi28Qymp3ueRhX07Miw758qDjuNk9CEOIfXajfloA)Jy5MOKLqDL1b(mDgRSBEZITZesqi9eA)JyP67ZHc1BEZILkc45wS9us(fJE6q)EHAH6nVzXs9Dm(iHsfQ38MfBJITZoozqfJQef2hLQIXKdFX0xmY7HITZ7iVkgZd3setFXiXfkMd8piH0JVyA7HlHAH6nVzX2a3WdNIfXsqMhIIDEVKqflb97HSeBNph0rjIn)SX7a6XWLfloA)drSFYGUeQJJ2)qwoq88EjHslCCYGc48n5hH64O9pKLdepVxsO8rB3Kx1mwayYbOybSE8b03TEeQJJ2)qwoq88EjHYhTD9c4wSaW8qGcg6n)oq88EjHcqWZpfcTnXFZqdgDbaVWrxrPqw9WZ(njuVzXaPOIqVEqXa7Up3IbEZiwmGsHyenuXs4yyetH9SfvXadfdSyuX0xSqv0ZrftFXiGohXaR1BX2bCkOQXsOooA)dz5aXZ7LekF029kGDKKr(NWdPPWE2Ikab05aqYVY)vK5qA75VzOPWE2I6A)6oiaen0vmGcuCiUaNYkSNTOUOFDheaIg6kgqbkoK0PvypBrDTFD(pxEWMvHdgA)dp0uypBrDr)68FU8GnRchm0(hkeQJJ2)qwoq88EjHYhTDVcyhjzK)j8qAkSNTOcqaDoaK8R8FfzoKg983m0uypBrDr)6oiaen0vmGcuCiUaNYkSNTOU2VUdcardDfdOafhs60kSNTOUOFD(pxEWMvHdgA)dpkSNTOU2Vo)NlpyZQWbdT)HcH64O9pKLdepVxsO8rBxsUpiqmfGsFq(DG459scfGGNFkeA75VzObrgisUJKmkuhhT)HSCG459scLpA7sumY6TqTq9M3SyBGB4HtXIy4fcbvmT9qX0BuS4OpuSMiwCfDosY4sOooA)dH22(SvOEZILQirXiR3I1mI58esNKrXaFEXU4YdcJKmkgoOxJeX6rSZ7Lekfc1Xr7Fi8rBxIIrwVfQJJ2)q4J2UxbSJKmY)eEinCqOpOaq0hhGZ7L0dw4)kYCinCqOpOli6JdFoFt(blajzeleqEdBdbo9GmXbZzG7GOifc1Xr7Fi8rB3Ra2rsg5FcpKgPh)mcOb0hv(VImhsJ4G5mGgqFujlMyaEgGTtFHeqqVqDC0(hcF029e5mqC0(hGCtu(NWdPrumY6nw4NOW(O02ZFZqJOyK1BSSGVphkuhhT)HWhTDprodehT)bi3eL)j8qANcHFIc7JsBp)83m0aNYAKXrxEbrriqqibH0ZcNijJL0PlVU8di8vCP9zBp(uiuVzX2rovm2bKkgNJy90Ah5mOIX8qXsnNkM(IP3OyP(oii)IbrgisUfdSwVfBdMlCEpXAgXcvS8dMyfoyO9pc1Xr7Fi8rBxsUpiqmfGsFq(BgAuoHJHzrY9bbIPau6dU4CCDEVKhW57rj8qJ3c1Xr7Fi8rBxCUW594VzOLWXWSi5(GaXuak9bxCoUs4yywKCFqGykaL(Gli6f9qaXMCDEVKhW57rj8qJUc1Xr7Fi8rB3tKZaXr7FaYnr5FcpKw5vH64O9pe(OT7jYzG4O9pa5MO8pHhsR0q8Oc1Xr7Fi8rB3aEIbb0hcXr5VzOHdc9bDvqM(0kp02Vj(UcyhjzCHdc9bfaI(4aCEVKEWIqDC0(hcF02nGNyqahUmbfQJJ2)q4J2U52)wja8YXv89WrfQJJ2)q4J2UjHpWZaOW(SLiuluV5nlwQ)pxEWgIq9MflvYiwukeXcikgNd)IrM2bftVrX(bfdSwVfl)GHevSusbKUeJxwckgy34iwb0E8fJjikcftVJrSuVJIvqM(0QypumWA9(5uXIbuXs9oUeQJJ2)qwNcHpA76fWTybG5Hafm0B(pGEYiGgqFuj02ZFZqdgDbaVWrxrPqwCoUaxdOpQlT9qa9bkncIZ7L8aoFpkzvqM(0kiVFTP0PpVxYd489OKvbz6tR8q74a4fUbqCWPqHq9MflvYi28IfLcrmW6CwSsJIbwR39iMEJInOBQy8Moe(fJJGILkyaPI9JyjpHigyTE)CQyXaQyPEhxc1Xr7FiRtHWhTD9c4wSaW8qGcg6n)ndny0fa8chDfLcz1dp8MoBegDbaVWrxrPqwfoyO9pUoVxYd489OKvbz6tR8q74a4fUbqCWPiuVzXybDoIXlLdFmNdT)rmWA9wSDaNcQAiwqel)JVybrmWqXa7hQQILFckwi2jiQy)fcftVrXyA)BvSchm0(hH64O9pK1Pq4J2Um5WhZ5q7F4VzOrzIIrwVXYc((COlWp)NlpyZ6cNcQASGOx0dbe82fYWGhTVqGZ7L8aoFpkHhA01LgqFuxA7Ha6duAKN90jD6cMWXWSUWPGQgloN0PtEcXft7FRaq0l6Hac6Plfc1Xr7FiRtHWhTDzYHpMZH2)WFZqJYefJSEJLf895qxiddE0(cboVxYd489OeEOrxxGZK)hco4mT)TcarVOhYgPNUuSHo)Nlpydf8WK)hco4mT)TcarVOhYgPNUB88FU8GnRlCkOQXcIErpeq(kGDKKX1fofu1a4uGuSHo)NlpydfuiuVzXybDoIXIoKMigyTEl2oGtbvneliIL)XxSGigyOyG9dvvXYpbfle7eevS)cHIP3OymT)TkwHdgA)d)ILWPI5argekMgqFujIP3HkgyDolwUVqXcvSmgevS90HiuhhT)HSofcF02LGoKMWFZqJYefJSEJLf895qxGF(pxEWM1fofu1ybrVOhci27sdOpQlT9qa9bknYZE6KoDbt4yywx4uqvJfNt60mT)TcarVOhci2thkeQJJ2)qwNcHpA7sqhst4VzOrzIIrwVXYc((COlWzY)dbhCM2)wbGOx0dzJ7PdfBOZ)5Yd2qbpm5)HGdot7FRaq0l6HSX90zJN)ZLhSzDHtbvnwq0l6HaYxbSJKmUUWPGQgaNcKIn05)C5bBOGcH6nlglOZrSDaNcQAigy9uEWedSwVfZ92)wjAK3Iq(2a3iX4Z1tOOynJyHJtUprsgfQJJ2)qwNcHpA7EfWosYi)t4H0UWPGQgat7FRenYBriW5NsR9p8FfzoKgL1iJJUM2)wjAK3IWforsglPttznY4Ol0nsm(C9ekUWjsYyjD6Z)5Yd2Sq3iX4Z1tO4cIErpeqSPnspiRrghDvq0bHaefgA4JElCIKmweQ3SySGohX2bCkOQHyG16Ty8s5WhZ5q7FelMIySOdPjIfeXY)4lwqedmumW(HQQy5NGIfIDcIk2FHqX0BumM2)wfRWbdT)rOooA)dzDke(OT7va7ijJ8pHhs7cNcQAaC(lCIrbo)uAT)H)MH25VWjgDTfuyht60N)cNy01Gh4NFyjD6ZFHtm6A(b5)kYCiT9c1Xr7FiRtHWhTDVcyhjzK)j8qAx4uqvdGZFHtmkW5NsR9p83m0o)foXORlC0BqH8FfzoKgt(Fi4GZ0(3kae9IEiBKE6qXgc890thq(kGDKKX1fofu1a4uGuqbpm5)HGdot7FRaq0l6HSr6PZgp)NlpyZIjh(yohA)ZcIErpek2qGVNE6aYxbSJKmUUWPGQgaNcKcksNoHJHzXKdFmNdT)biHJHzX5KoDbt4yywm5WhZ5q7FwCoPtZ0(3kae9IEiGGE6iuhhT)HSofcF029kGDKKr(NWdPDHtbvnao)foXOaNFkT2)WFZq78x4eJUM2)wbycK)RiZH0yY)dbhCM2)wbGOx0dzJ0thk2qGVNE6aYxbSJKmUUWPGQgaNcKck4Hj)peCWzA)BfaIErpKnspD245)C5bBwe0H0Kfe9IEiuSHaFp90bKVcyhjzCDHtbvnaofifuKoD51fbDinzP9zBp(PtZ0(3kae9IEiGGE6iuhhT)HSofcF029cNcQAWFZqJYefJSEJLf895qxLxxqohLdIlTpB7X3fLlychdZ6cNcQAS4CCDfWosY46cNcQAamT)Ts0iVfHaNFkT2)46kGDKKX1fofu1a48x4eJcC(P0A)Jq9MfBdCJeJpxpHIIb2noInVkgrXiR3yrSykIL86TyPkNJYbrXIPigLiGWxrXcikgNJympuS8p(IHZZ5FVeQJJ2)qwNcHpA7IUrIXNRNqr(BgAuMOyK1BSSGVph6cCkxED5hq4R4cImqKChjz0v51fKZr5G4cIErpeEOlF0fKpoaEHBaehCkPtxEDb5CuoiUGOx0dbKPZAt8Ob0h1L2EiG(aLgPWLgqFuxA7Ha6duAKh6kuVzXyV7lXAgXadflGOyrYZPIPVyBWCHZ7XVyXueluf9CuX0xmcOZrmWA9wmw0H0eXy6jYID3QynJyGHIb2puvfdSGOOyEpeftVJrS7iZiMEJID(pxEWMLqDC0(hY6ui8rBxYDFXFZqR86cY5OCqCP9zBp(UaNYN)ZLhSzrqhstwqmkGMo95)C5bBwx4uqvJfe9IEi8SNEksNU86IGoKMS0(SThFH64O9pK1Pq4J2UoV2)WFZqlHJHzLK)VK5i6cIXrtNo5jexmT)TcarVOhci4nDsNUGjCmmRlCkOQXIZrOooA)dzDke(OTBs()cadheu(BgAfmHJHzDHtbvnwCoc1Xr7FiRtHWhTDtqibHB7XN)MHwbt4yywx4uqvJfNJqDC0(hY6ui8rBxMgIj5)l83m0kychdZ6cNcQAS4CeQJJ2)qwNcHpA7gZbjkmYaNiN5VzOvWeogM1fofu1yX5iuhhT)HSofcF029e5mqC0(hGCtu(NWdPDfttU5VzOrzIIrwVXYkYzxEbrriqqibH0dae9IEi0OJq9MfJf05iMEJI5a7h2kOIr0qflHJHrmf2ZwufdSwVfBhWPGQg8l2R3ieSMGIXrqX(rSZ)5Yd2iuhhT)HSofcF02vH9Sf1983m0UcyhjzCPWE2Ikab05aqYVsBVlWlychdZ6cNcQAS4CsNo5jexmT)TcarVOhciOrpDOiDAWVcyhjzCPWE2Ikab05aqYVsJExuwH9Sf1f9RZ)5Yd2SGyuaLI0PP8va7ijJlf2ZwubiGohas(vH64O9pK1Pq4J2UkSNTOsp)ndTRa2rsgxkSNTOcqaDoaK8R0O3f4fmHJHzDHtbvnwCoPtN8eIlM2)wbGOx0dbe0ONouKon4xbSJKmUuypBrfGa6Cai5xPT3fLvypBrDTFD(pxEWMfeJcOuKonLVcyhjzCPWE2Ikab05aqYVkuluV5nlgiTH4rfReEHpkwK05wBKiuVzX2G5cN3tSqfJU8jg4BIpXaR1BXaPSuiwQ3XLyPsppS0HIzqf7hXONpX0a6JkHFXaR1BX2bCkOQb)I9qXaR1BXsHk8YuSxVriynbfdSOvXyEOyK3dfdhe6d6sSDotEXalAvSMrSnWnIVyN3l5fRjIDEVE8fJZzjuhhT)HSknepknCUW594VzOHmm4r7le48EjpGZ3Js4HgD5tJmo6QGOdcbikm0Wh9w4ejzS4c8cMWXWSUWPGQgloN0PlychdZIC3xloN0PlychdZIjh(yohA)ZIZjDACqOpORcY0Nwbbn63eFxbSJKmUWbH(GcarFCaoVxspyjDAkFfWosY4I0JFgb0a6JkfUaNYAKXrxOBKy856juCHtKKXs60N)ZLhSzHUrIXNRNqXfe9IEi8qpfc1Xr7FiRsdXJYhTDVcyhjzK)j8qACeeGPZzeY)vK5qAN3l5bC(EuYQGm9PvE2Nonoi0h0vbz6tRGGg9BIVRa2rsgx4GqFqbGOpoaN3lPhSKonLVcyhjzCr6XpJaAa9rvOooA)dzvAiEu(OTlbHWqXcqYpiaXP3I8Fa9KranG(OsOTN)MHMxqueceesqi9aarVOhcn64c8eogMfj3heiMcqPp4IZXfLlVUiiegkwas(bbio9weO86s7Z2E8tNo5jexmT)TcarVOhciOTP0Pp)NlpyZIGqyOybi5heG40BX15oG(ibGbghT)jY8qJ(fi5MsNM8C5KEkRmgfGeqbq3cpNmUWjsYyXfLt4yywzmkajGcGUfEozCX5qHq9MfJxkgXEgX2WN(cjIfQy7PK8jgrJZwIypJy8Y3LcoIrLCuqIypuSWp6HOIrx(etdOpQKLqDC0(hYQ0q8O8rBxMyaEgGTtFHe(BgAxbSJKmU4iiatNZi0f4jCmmR7UuWbijhfKSiAC2YdT9uY0PbNYoW(HTcka81q7FCrCWCgqdOpQKftmapdW2PVqcp0OlFefJSEJLf895qkOqOEZIXlfJypJyB4tFHeX0xSWXjdQyGumkzqfBh)M8JynJy9ehTVqX(rSyavmnG(OkwOIXBX0a6JkzjuhhT)HSknepkF02LjgGNby70xiH)dONmcOb0hvcT983m0UcyhjzCXrqaMoNrOlIdMZaAa9rLSyIb4za2o9fs4HgVfQJJ2)qwLgIhLpA7IN7VhFai6aBVyk83m0UcyhjzCXrqaMoNrORZ)5Yd2SUWPGQgli6f9q4zpDeQJJ2)qwLgIhLpA7gEjCKB(BgAxbSJKmU4iiatNZi0f4EbrriqqibH0dae9IEi0OJlkd5gK5H(4Q8Vxsoky60jCmmRKCpfsxWfNdfc1BwSuIKnMk40ohkkM(IfoozqfdKIrjdQy743KFeluXOxmnG(OseQJJ2)qwLgIhLpA76XPDouK)dONmcOb0hvcT983m0UcyhjzCXrqaMoNrOlIdMZaAa9rLSyIb4za2o9fsOrVqDC0(hYQ0q8O8rBxpoTZHI83m0UcyhjzCXrqaMoNrOqTq9M3SyG0Wl8rX(lekM2EOyrsNBTrIq9MfJxBVwfJseq4RirSFeB(zJoW2dgqqftdOpQeXyEOy6nkMdSFyRGkg81q7FeRzeBt8jwsgXcrSaIIfzigfqfJZrOooA)dzvEL2va7ijJ8pHhsJSTDaoGEYiGFaHVI8FfzoKMdSFyRGcaFn0(hxehmNb0a6JkzXedWZaSD6lKWdVDbE51LFaHVIli6f9qaX5)C5bBw(be(kUkCWq7FsN25BYpybijJyHWZMOqOEZIXRTxRILQCokhejI9JyZpB0b2EWacQyAa9rLigZdftVrXCG9dBfuXGVgA)JynJyBIpXsYiwiIfquSidXOaQyCoc1Xr7FiRYR8rB3Ra2rsg5FcpKgzB7aCa9KraiNJYbr(VImhsZb2pSvqbGVgA)JlIdMZaAa9rLSyIb4za2o9fs4H3UaVGjCmmlYDFT4CsN25BYpybijJyHWZMOqOEZIXRTxRILQCokhejI1mITd4uqvd(yV7RDtfbrrOy7mHeespI1eX4CelMIyGHIDhxOy0ZNye88tHiwgzuX(rm9gflv5Cuoikgi9trOooA)dzvELpA7EfWosYi)t4H0iBBhaiNJYbr(VImhsRGjCmmRlCkOQXIZXf4fmHJHzrU7RfNt60EbrriqqibH0dae9IEi8qhkCvEDb5CuoiUGOx0dHh6fQ3SySo4PJSyuIacFfflMIyPkNJYbrXiOY5iMdSFOy6l2g4gjgFUEcff7eevOooA)dzvELpA76hq4Ri)ndnnY4Ol0nsm(C9ekUWjsYyXfLr3iX4Z1tOyz5hq4RORYRl)acFfxoECzTDYncbbT9Uo)NlpyZcDJeJpxpHIli6f9qab9UioyodOb0hvYIjgGNby70xiH2ExWOla4fo6kkfYQhE4fUkVU8di8vCbrVOhcitN1MaHgqFuxA7Ha6duAuOooA)dzvELpA7c5CuoiYFZqtJmo6cDJeJpxpHIlCIKmwCboYWGhTVqGZ7L8aoFpkHhAhhaVWnaIdofxN)ZLhSzHUrIXNRNqXfe9IEiGyVRYRliNJYbXfe9IEiGmDwBceAa9rDPThcOpqPrkeQ3SyuIacFffJZzlIo8lwKjVykSrIy6lghbfRvXcIyHyeh80rwmFCqyOpumMhkMEJILdIkwQ3rXsqMhIIfIX0ttUrOqDC0(hYQ8kF0215)maejph8G8Z8qGbDtPTxOooA)dzvELpA76hq4Ri)ndniYarYDKKrxN3l5bC(EuYQGm9PvEOT3f4oECzTDYncbbT9PtdrVOhciOP9zlG2EOlIdMZaAa9rLSyIb4za2o9fs4HgVPWf4ugDJeJpxpHIL0PHOx0dbe00(SfqBpeKP3fXbZzanG(OswmXa8maBN(cj8qJ3u4cCnG(OU02db0hO04gHOx0dHcEORlVGOieiiKGq6baIErpeA0rOooA)dzvELpA768FgaIKNdEq(zEiWGUP02luhhT)HSkVYhTD9di8vK)dONmcOb0hvcT983m0O8va7ijJlY22b4a6jJa(be(k6cImqKChjz0159sEaNVhLSkitFALhA7DbUJhxwBNCJqqqBF60q0l6HacAAF2cOTh6I4G5mGgqFujlMyaEgGTtFHeEOXBkCboLr3iX4Z1tOyjDAi6f9qabnTpBb02dbz6DrCWCgqdOpQKftmapdW2PVqcp04nfUaxdOpQlT9qa9bknUri6f9qOGN907YlikcbccjiKEaGOx0dHgDeQ3SyPg2EKFelf0ZbjQy)iMhxwBNmkMgqFujIfQy0LpXs9okgy34igKBME8f75uX6rm6jIboNJy6lgDftdOpQeke7HIXBIyGVj(etdOpQekeQJJ2)qwLx5J2Uhy7r(bqrphKO83m0ioyodOb0hvcp0O3fe9IEiGGE(aN4G5mGgqFuj8qBtu4czyWJ2xiW59sEaNVhLWdn6kuVzX2Wr0rmohXsvohLdIIfQy0LpX(rSiNftdOpQeXahSBCel3x94lw(hFXW558VflMIyZRIrMWHC)kfc1Xr7FiRYR8rBxiNJYbr(BgAu(kGDKKXfzB7aa5Cuoi6czyWJ2xiW59sEaNVhLWdn66cImqKChjz0f4oECzTDYncbbT9PtdrVOhciOP9zlG2EOlIdMZaAa9rLSyIb4za2o9fs4HgVPWf4ugDJeJpxpHIL0PHOx0dbe00(SfqBpeKP3fXbZzanG(OswmXa8maBN(cj8qJ3u4sdOpQlT9qa9bknUri6f9q4bC6YhKBqMh6JRsqU7XhGCEUPaXmitj5dYniZd9Xv5FVKCuqqMxqHqDC0(hYQ8kF02fY5OCqK)dONmcOb0hvcT983m0O8va7ijJlY22b4a6jJaqohLdIUO8va7ijJlY22baY5OCq0fYWGhTVqGZ7L8aoFpkHhA01fezGi5osYOlWD84YA7KBeccA7tNgIErpeqqt7ZwaT9qxehmNb0a6JkzXedWZaSD6lKWdnEtHlWPm6gjgFUEcflPtdrVOhciOP9zlG2EiitVlIdMZaAa9rLSyIb4za2o9fs4HgVPWLgqFuxA7Ha6duACJq0l6HWd40Lpi3Gmp0hxLGC3Jpa58CtbIzqMsYhKBqMh6JRY)Ej5OGGmVGcH6nlwQHTh5hXsb9CqIk2pIXMIynJy9iMtmf0RpIftrSbdyguX8c3edhe6dQyXueRzeBdMlCEpXa7hQQIvEX8Eikwj8cFuSchkM(ILcv2nvSZc1Xr7FiRYR8rB3dS9i)aOONdsu(BgAehmNb0a6JkH2ExugYniZd9Xvji394dqop3uGy2Lxqueceesqi9aarVOhcn64czyWJ2xiW59sEaNVhLWdnWpoaEHBaehCkBCpfUGidej3rsgDrz0nsm(C9ekwCr5cMWXWSi391IZXf44GqFqxfKPpTccA0Vj(UcyhjzCHdc9bfaI(4aCEVKEWcfU0a6J6sBpeqFGsJBeIErpeEORqTq9M3SySkgz9glITZhT)HiuVzXCV9VjAK3IqX(rmENcLkwQHTh5hXsb9CqIkuhhT)HSikgz9gl0oW2J8dGIEoir5VzOPrghDnT)Ts0iVfHlCIKmwCrCWCgqdOpQeEOXBxN3l5bC(Eucp0ORlnG(OU02db0hO04gHOx0dHhEHq9MfZ92)MOrElcf7hX2NcLkg7eoK7xflv5CuoikuhhT)HSikgz9gl8rBxiNJYbr(BgAAKXrxt7FRenYBr4cNijJfxN3l5bC(Eucp0ORlnG(OU02db0hO04gHOx0dHhEHq9MfJLlrridNpsPITZoozqf7HILQidej3IbwR3ILWXWGfXOebe(kseQJJ2)qwefJSEJf(OTRZ)zaisEo4b5N5Had6MsBVqDC0(hYIOyK1BSWhTD9di8vK)dONmcOb0hvcT983m00iJJUiCjkcz48XforsglUahIErpeqSN(0PD84YA7KBeccA7PWLgqFuxA7Ha6duACJq0l6HWd9c1BwmwUefHmC(Oy8j2g4gXxSFeBFkuQyPkYarYTyuIacFffluX0BumCkI9mIrumY6Ty6lMpQI5fUjwHdgA)JyjiZdrX2a3iX4Z1tOOqDC0(hYIOyK1BSWhTDD(pdarYZbpi)mpeyq3uA7fQJJ2)qwefJSEJf(OTRFaHVI83m00iJJUiCjkcz48XforsglU0iJJUq3iX4Z1tO4cNijJfxXr7leah0RrcT9Us4yyweUefHmC(4cIErpeqSFXBH64O9pKfrXiR3yHpA76XPDouK)MHMgzC0fHlrridNpUWjsYyX159sEaNVhLacA8wOwOEZBwSDiMMCluVzX4L6Pj3IbwR3I5fUjwQ3rXyEOyU3(3krJ8weYVyCtgjeX4i94lgifd9odQyS3r5bJiuhhT)HSUIPj30UcyhjzK)j8qAt7FRenYBriWXb48tP1(h(VImhsdCkd5gK5H(4QGHENbfGChLhmIlKHbpAFHaN3l5bC(Eucp0ooaEHBaehCkuKon4qUbzEOpUkyO3zqbi3r5bJ468EjpGZ3Jsab9uiuVzX2HyAYTyG16TyBGBeFX4tm3B)BLOrElcPuXsfHBThNNyPEhflMIyBGBeFXGyuavmMhk2GUPIrjsnivOooA)dzDfttU5J2UxX0KB(BgAAKXrxOBKy856juCHtKKXIlnY4ORP9VvIg5TiCHtKKXIRRa2rsgxt7FRenYBriWXb48tP1(hxN)ZLhSzHUrIXNRNqXfe9IEiGyVq9MfBhIPj3IbwR3I5E7FRenYBrOy8jM7VyBGBeFkvSur4w7X5jwQ3rXIPi2oGtbvneJZrOooA)dzDfttU5J2UxX0KB(BgAAKXrxt7FRenYBr4cNijJfxuwJmo6cDJeJpxpHIlCIKmwCDfWosY4AA)BLOrElcbooaNFkT2)4QGjCmmRlCkOQXIZrOooA)dzDfttU5J2Uo)NbGi55GhKFMhcmOBkT98JUPWai8EUrPr3njuhhT)HSUIPj38rB3RyAYn)ndnnY4OlcxIIqgoFCHtKKXIRZ)5Yd2S8di8vCX54c8YRl)acFfxqKbIK7ijJPtxWeogM1fofu1yX54Q86YpGWxXLJhxwBNCJqqqBpfUoVxYd489OKvbz6tR8qdCIdMZaAa9rLSyIb4za2o9fs4Hxg0LcxWOla4fo6kkfYQhE2tVq9MfBhIPj3IbwR3ILkcIIqX2zcji9qPILQCokhe5Jseq4ROyZRI1JyqKbIKBXGX4J8lwHd2JVy7aofu1Gp27(AjglOZrmWA9wmw0H0eXy6jYID3QynJyopH0jzCjuhhT)HSUIPj38rB3RyAYn)ndnW1iJJU8cIIqGGqccPNforsglPtd5gK5H(4YlGBbEga9gb8cIIqGGqccPhkCr5YRliNJYbXfezGi5osYORYRl)acFfxq0l6HWdVDvWeogM1fofu1yX54c8cMWXWSi391IZjD6cMWXWSUWPGQgli6f9qabDtNU86IGoKMS0(SThFkCvEDrqhstwq0l6HacExzjo4P6o9BIsw1QwRa]] )

end