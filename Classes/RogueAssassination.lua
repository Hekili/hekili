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


    spec:RegisterPack( "Assassination", 20210320, [[da1bccqiGupsPOUKijAtujFcPIrHeofs0Qac9kIkZIOQBPuWUuYVuQ0WasoMsvldPQNruQPHuPRPuKTHKqFdiOgNsfKZjscRdjrVJOeIMhq09qk7JO4FeLq4GkvOfIK0dvk0ebcCrrs1gjkbFejbJKOeQoPsfyLiPEjqqmtIs6MeLODsLQHQurTurs6PeAQIexLOesBvKu(QsfuJvPISxj9xadMYHfwmv1JvXKL4YqBMGplIrRsDAPwnrjuETsPzlQBtv2TIFRQHtfhhiiTCqphX0jDDISDvY3bQgpvkNhOmFrQ9J66(AkvXsOy1D6bf97bLSPhuR9GApOKn9vrfmhSk6eNTrcwfNWdRI7iHeespH2)ufDcWYFuQPufjVe8GvXBvDiu5U7M06TK)68E7sApPCO9phyiO7sAVZUvrFPoR7GP6xflHIv3Phu0VhuYMEqT2dQ9GI(nvfdj9(HvrX2BJvX7UuWP6xfli5uf3rcjiKEcT)HTu9tKqMAzzap3SrpOKNn6bf97zQzQ34DmjiHkzQ3aB7OJtgm2OdrH9rPdBc5iHn9zJ8EiB74olRSj8WTe20NnsCHS5a)dsi9KWM2E4IPEdSbc(HokBPwmn5MnPjJecBI5(GSftHnqqFq2aVZz2Ybrzl)tccztVJHnzzqueY2osibH0ZQkMBIsQPufjkgz9gl1uQUVVMsveNWpJLkvRIXr7FQIhy7r(bqrphKOvXcsoW2r7FQIU3j3enYBriB)WMStHkzBJW2J8dBPGEoirRIhyRiSJQOgzC010j3krJ8weUWj8ZyHnxSrCWCgqdycQe2KHgBYMnxSDEp)hW57rjSjdn2OlBUytdycQlT9qa9bknY2gydIErpe2KHnQyvRUtFnLQioHFglvQwfJJ2)ufHsoQeeRIfKCGTJ2)ufDVtUjAK3Iq2(HT9PqLSjoHd5(v2svjhvcIvXdSve2rvuJmo6A6KBLOrElcx4e(zSWMl2oVN)d489Oe2KHgB0LnxSPbmb1L2EiG(aLgzBdSbrVOhcBYWgvSQv3LDnLQioHFglvQwfJJ2)ufD(pdarYlbpyvSGKdSD0(NQOOKVIqbPeKkzBhDCYGX2dzlvrbisUzd8wVzZxsqalSrfci8vKuffEiWGUPv33x1Q70TMsveNWpJLkvRIXr7FQIjbe(kwfpWwryhvrnY4OlIKVIqbPeCHt4NXcBUyJc2GOx0dHnqY2E6zlDA2C8KYA7KBeYgiPX2E2OKnxSPbmb1L2EiG(aLgzBdSbrVOhcBYWg9vXdyNmcObmbvs199vT6(MQPufXj8ZyPs1QyC0(NQOZ)zaisEj4bRIfKCGTJ2)uffL8vekiLGSjhBPUBKe2(HT9PqLSLQOaej3Srfci8vKTqztVr2WPW2lWgrXiR3SPpBjOYMx4gBfjyO9pS5Jcpezl1DJetIupHIvrHhcmOBA199vT6ovSMsveNWpJLkvRIhyRiSJQOgzC0frYxrOGucUWj8ZyHnxSPrghDHUrIjrQNqXfoHFglS5IT4O9fcGd61iHnASTNnxS5ljiSis(kcfKsWfe9IEiSbs22VKDvmoA)tvmjGWxXQwDheUMsveNWpJLkvRIhyRiSJQOgzC0frYxrOGucUWj8ZyHnxSDEp)hW57rjSbsASj7QyC0(NQONK25qXQw1Q4vmn5UMs1991uQI4e(zSuPAv8DQIeuRIXr7FQIxbSd)mwfVISewfPGnqZguAqHhMGRcg6DgmaYDuEWjlCc)mwyZfBOGaE0(cboVN)d489Oe2KHgBhhaVWnaIdof2OKT0PzJc2Gsdk8WeCvWqVZGbqUJYdozHt4NXcBUy78E(pGZ3JsydKSrpBuwfli5aBhT)Pkkl0ttUzd8wVzZlCJTnUZSj8q2CVtUvIg5TiuE2KMmsiSjr6jHnqag6Dgm2eVJYdoPkEfqGj8WQ40j3krJ8wecCCao)uAT)PQv3PVMsveNWpJLkvRIXr7FQIxX0K7Qybjhy7O9pvXulMMCZg4TEZwQ7gjHn5yZ9o5wjAK3IqQKnzz4w7j5X2g3z2IPWwQ7gjHnigfWyt4HSnOBkBuHnccQIhyRiSJQOgzC0f6gjMePEcfx4e(zSWMl20iJJUMo5wjAK3IWfoHFglS5ITRa2HFgxtNCRenYBriWXb48tP1(h2CX25)C5bFwOBKysK6juCbrVOhcBGKT9vT6USRPufXj8ZyPs1QyC0(NQ4vmn5UkwqYb2oA)tvm1IPj3SbER3S5ENCRenYBriBYXM7pBPUBKeQKnzz4w7j5X2g3z2IPWwQHtbvnytYPkEGTIWoQIAKXrxtNCRenYBr4cNWpJf2CXgOztJmo6cDJetIupHIlCc)mwyZfBxbSd)mUMo5wjAK3IqGJdW5NsR9pS5ITc6ljiSUWPGQgljNQwDNU1uQI4e(zSuPAvmoA)tv05)maejVe8Gvr0nfgaH3lnAvKUBQkk8qGbDtRUVVQv33unLQioHFglvQwfpWwryhvrnY4OlIKVIqbPeCHt4NXcBUy78FU8GpRKacFfxsoS5InkyR86kjGWxXfefGi5o8ZiBPtZwb9Leewx4uqvJLKdBUyR86kjGWxXLJNuwBNCJq2ajn22ZgLS5ITZ75)aoFpkzvqH(0kBYqJnkyJ4G5mGgWeujlHyaEbGTtFHe2KrweSrx2OKnxSbJUaGx4OROuiREytg22tFvmoA)tv8kMMCx1Q7uXAkvrCc)mwQuTkghT)PkEfttURIfKCGTJ2)uftTyAYnBG36nBYYGOiKTDKqcspujBPQKJkbr5Ocbe(kY28kB9WgefGi5MnymjO8SvKG9KWwQHtbvnKt8UVwSjc2Cyd8wVzteDinHnHEImB3TYwlWMZtiTFgxvXdSve2rvKc20iJJU8cIIqGGqccPNfoHFglSLonBqPbfEycU8c4wGxaqVraVGOieiiKGq6zHt4NXcBuYMl2anBLxxqjhvcIlikarYD4Nr2CXw51vsaHVIli6f9qytg2KnBUyRG(sccRlCkOQXsYHnxSrbBf0xsqyrU7RLKdBPtZwb9Leewx4uqvJfe9IEiSbs2OlBPtZw51fbDinzP9zBpjSrjBUyR86IGoKMSGOx0dHnqYMSRAvRIfuiKYAnLQ77RPufJJ2)uf32NTvrCc)mwQuTQv3PVMsveNWpJLkvRIfKCGTJ2)uftvKOyK1B2Ab2CEcP9ZiBumpBxs5bHHFgzdh0RrcB9W2598dLYQyC0(NQirXiR3vT6USRPufXj8ZyPs1Q47ufjOwfJJ2)ufVcyh(zSkEfzjSkIdctaBbXeCyto2C(M8dwa8ZiwiSbISTdX2USrbB0ZgiYgXbZzG7GOiBuwfVciWeEyveheMagaetWb48E(9GLQwDNU1uQI4e(zSuPAv8DQIeuRIXr7FQIxbSd)mwfVISewfjoyodObmbvYsigGxay70xiHnqYg9vXRacmHhwfj9KKranGjOw1Q7BQMsveNWpJLkvRIhyRiSJQirXiR3yzb)ejSksuyF0Q77RIXr7FQINiNbIJ2)aKBIwfZnrbMWdRIefJSEJLQwDNkwtPkIt4NXsLQvXdSve2rvKc2anBAKXrxEbrriqqibH0ZcNWpJf2sNMTYRRKacFfxAF22tcBuwfjkSpA199vX4O9pvXtKZaXr7FaYnrRI5MOat4HvXtHu1Q7GW1uQI4e(zSuPAvmoA)tvKK7dcetbO0hSkwqYb2oA)tvCNLu2ehqaBsoS1tRDKZGXMWdzBJskB6ZMEJSTX7GGYZgefGi5MnWB9MTuFUW59yRfylu2Yp4SvKGH2)ufpWwryhvrqZMVKGWIK7dcetbO0hCj5WMl2oVN)d489Oe2KHgBYUQv33HQPufXj8ZyPs1Q4b2kc7Ok6ljiSi5(GaXuak9bxsoS5InFjbHfj3heiMcqPp4cIErpe2ajBBInxSDEp)hW57rjSjdn2OBvmoA)tveNlCEVQwDpvutPkIt4NXsLQvX4O9pvXtKZaXr7FaYnrRI5MOat4HvXYRvT6(EqvtPkIt4NXsLQvX4O9pvXtKZaXr7FaYnrRI5MOat4HvXsdXJw1Q773xtPkIt4NXsLQvXdSve2rveheMa2QGc9Pv2KHgB73eBYX2va7WpJlCqycyaqmbhGZ753dwQIXr7FQIb8edcOpeIJw1Q77PVMsvmoA)tvmGNyqahPmbRI4e(zSuPAvRUVx21uQIXr7FQI5o5wjaYIjvs8WrRI4e(zSuPAvRUVNU1uQIXr7FQI(rcWlaOW(SLufXj8ZyPs1Qw1QOdepVNFO1uQUVVMsvmoA)tvmCCYGb48n5NQioHFglvQw1Q70xtPkghT)Pk6)QMXcGqoadlG3tcG(U1tveNWpJLkvRA1DzxtPkIt4NXsLQvX4O9pvrVaUflacpeOGHExfpWwryhvry0fa8chDfLcz1dBYW2(nvfDG4598dfGGNFkKQ4MQA1D6wtPkIt4NXsLQvX3PksqTkghT)PkEfWo8Zyv8kGat4Hvrf2ZwubiGnhas(1Q4b2kc7OkQWE2I6s3VUdcardDfdyafhcBUyJc2anBkSNTOUu6x3bbGOHUIbmGIdHT0PztH9Sf1LUFD(pxEWNvrcgA)dBYqJnf2Zwuxk9RZ)5Yd(SksWq7FyJYQybjhy7O9pvrqaQi0RhKnWV7ZnBu0cSfdyuYgrdLnFjbb2uypBrLnWr2apgLn9zluf9Cu20NncyZHnWB9MTudNcQASQIxrwcRI7RA19nvtPkIt4NXsLQvX3PksqTkghT)PkEfWo8Zyv8kYsyvK(Q4b2kc7OkQWE2I6sPFDheaIg6kgWakoe2CXgfSbA2uypBrDP7x3bbGOHUIbmGIdHT0PztH9Sf1Ls)68FU8GpRIem0(h2KHnf2Zwux6(15)C5bFwfjyO9pSrzv8kGat4Hvrf2ZwubiGnhas(1QwDNkwtPkIt4NXsLQvX4O9pvrsUpiqmfGsFWQ4b2kc7OkcrbisUd)mwfDG4598dfGGNFkKQ4(QwDheUMsvmoA)tvKOyK17QioHFglvQw1QwflnepAnLQ77RPufXj8ZyPs1QyC0(NQiox48EvXcsoW2r7FQIP(CHZ7XwOSrx5yJInjhBG36nBGarkzBJ78ITDGNhw6qXmyS9dB0lhBAatqLipBG36nBPgofu1qE2EiBG36nBPqv5z71BecEtq2apALnHhYg59q2WbHjGTyBhZKNnWJwzRfyl1DJKW2598F2AcBN3RNe2KCwvXdSve2rvefeWJ2xiW598FaNVhLWMm0yJUSjhBAKXrxfeDqiarHHgjO3cNWpJf2CXgfSvqFjbH1fofu1yj5Ww60SvqFjbHf5UVwsoSLonBf0xsqyjKJemNdT)zj5Ww60SHdctaBvqH(0kBGKgB0Vj2KJTRa2HFgx4GWeWaGycoaN3ZVhSWw60SbA2Ucyh(zCr6jjJaAatqLnkzZfBuWgOztJmo6cDJetIupHIlCc)mwylDA2o)Nlp4ZcDJetIupHIli6f9qytg2ONnkRA1D6RPufXj8ZyPs1Q47ufjOwfJJ2)ufVcyh(zSkEfzjSkEEp)hW57rjRck0Nwztg22Zw60SHdctaBvqH(0kBGKgB0Vj2KJTRa2HFgx4GWeWaGycoaN3ZVhSWw60SbA2Ucyh(zCr6jjJaAatqTkEfqGj8WQOebbe6CgHvT6USRPufXj8ZyPs1QyC0(NQibHWqXcG)piaXP3IvXdSve2rv0likcbccjiKEaGOx0dHnASbk2CXgfS5ljiSi5(GaXuak9bxsoS5InqZw51fbHWqXcG)piaXP3IaLxxAF22tcBPtZM)tiS5InHo5wbGOx0dHnqsJTnXw60SD(pxEWNfbHWqXcG)piaXP3IRZDatqcGamoA)tKztgASr)ceEtSLonBKxk73tzLXOa4dga6w45KXfoHFglS5InqZMVKGWkJrbWhma0TWZjJljh2OSkEa7KranGjOsQUVVQv3PBnLQioHFglvQwfJJ2)uffIb4fa2o9fsQIfKCGTJ2)ufLfIHTxGnqitFHe2cLT9Pc5yJOXzlHTxGnzX7sbh2OAokiHThYwKe9qu2ORCSPbmbvYQkEGTIWoQIxbSd)mUKiiGqNZiKnxSrbB(sccR7UuWbWphfKSiAC2YMm0yBFQGT0PzJc2anBoW(HTcga81q7FyZfBehmNb0aMGkzjedWlaSD6lKWMm0yJUSjhBefJSEJLf8tKq2OKnkRA19nvtPkIt4NXsLQvX4O9pvrHyaEbGTtFHKQ4bStgb0aMGkP6((Q4b2kc7OkEfWo8Z4sIGacDoJq2CXgXbZzanGjOswcXa8caBN(cjSjdn2KDvSGKdSD0(NQOSqmS9cSbcz6lKWM(SfoozWydeGrjdgB783KFyRfyRN4O9fY2pSfdySPbmbv2cLnzZMgWeujRQwDNkwtPkIt4NXsLQvXdSve2rv8kGD4NXLebbe6CgHS5ITZ)5Yd(SUWPGQgli6f9qytg22dQQyC0(NQiEU)EsaGOdS9IPu1Q7GW1uQI4e(zSuPAv8aBfHDufVcyh(zCjrqaHoNriBUyJc28cIIqGGqccPhai6f9qyJgBGInxSbA2Gsdk8WeCv(3ZphfCHt4NXcBPtZMVKGWYp3tH0fCj5WgLvX4O9pvXWZxICx1Q77q1uQI4e(zSuPAvmoA)tv0ts7COyv8a2jJaAatqLuDFFv8aBfHDufVcyh(zCjrqaHoNriBUyJ4G5mGgWeujlHyaEbGTtFHe2OXg9vXcsoW2r7FQIPe(BqwkPDouKn9zlCCYGXgiaJsgm225Vj)WwOSrpBAatqLu1Q7PIAkvrCc)mwQuTkEGTIWoQIxbSd)mUKiiGqNZiSkghT)Pk6jPDouSQvTkEkKAkv33xtPkIt4NXsLQvX4O9pvrVaUflacpeOGHExfpGDYiGgWeujv33xfpWwryhvry0fa8chDfLczj5WMl2OGnnGjOU02db0hO0iBGKTZ75)aoFpkzvqH(0kBGiB7xBIT0Pz78E(pGZ3JswfuOpTYMm0y74a4fUbqCWPWgLvXcsoW2r7FQI7ab2IsHWwar2KCKNnY0oiB6nY2piBG36nB5hCKOSLskGGfBYIsq2a)gh2kG1tcBcbrriB6DmSTXDMTck0Nwz7HSbER3VKYwmGX2g35vvRUtFnLQioHFglvQwfJJ2)uf9c4wSai8qGcg6DvSGKdSD0(NQ4oqGT5zlkfcBG35mBLgzd8wV7Hn9gzBq3u2KnOiYZMebztwkacy7h28FcHnWB9(Lu2Ibm224oVQIhyRiSJQim6caEHJUIsHS6Hnzyt2GITnWgm6caEHJUIsHSksWq7FyZfBN3Z)bC(EuYQGc9Pv2KHgBhhaVWnaIdoLQwDx21uQI4e(zSuPAvmoA)tvuihjyohA)tvSGKdSD0(NQOiyZHnzHCKG5CO9pSbER3SLA4uqvd2ccB5FsyliSboYg4)qhLT8tq2c2obrz7VqiB6nYMqNCRSvKGH2)ufpWwryhvrqZgrXiR3yzb)ejKnxSrbBN)ZLh8zDHtbvnwq0l6HWgizt2S5InuqapAFHaN3Z)bC(EucBYqJn6YMl20aMG6sBpeqFGsJSjdB7bfBPtZwb9Leewx4uqvJLKdBPtZM)tiS5InHo5wbGOx0dHnqYg90LnkRA1D6wtPkIt4NXsLQvXdSve2rve0SrumY6nwwWprczZfBOGaE0(cboVN)d489Oe2KHgB0LnxSrbBc5)HSrbBuWMqNCRaq0l6HW2gyJE6YgLSTlBXr7Fao)Nlp4dBuYMmSjK)hYgfSrbBcDYTcarVOhcBBGn6PlBBGTZ)5Yd(SUWPGQgli6f9qydez7kGD4NX1fofu1a4uGSrjB7YwC0(hGZ)5Yd(WgLSrzvmoA)tvuihjyohA)tvRUVPAkvrCc)mwQuTkghT)PksqhstQIfKCGTJ2)uffbBoSjIoKMWg4TEZwQHtbvnyliSL)jHTGWg4iBG)dDu2Ypbzly7eeLT)cHSP3iBcDYTYwrcgA)J8S5lPS5arbeYMgWeujSP3HYg4DoZwUVq2cLTmgeLT9GIufpWwryhvrqZgrXiR3yzb)ejKnxSrbBN)ZLh8zDHtbvnwq0l6HWgizBpBUytdycQlT9qa9bknYMmSThuSLonBf0xsqyDHtbvnwsoSLonBcDYTcarVOhcBGKT9GInkRA1DQynLQioHFglvQwfpWwryhvrqZgrXiR3yzb)ejKnxSrbBc5)HSrbBuWMqNCRaq0l6HW2gyBpOyJs22LT4O9paN)ZLh8Hnkztg2eY)dzJc2OGnHo5wbGOx0dHTnW2EqX2gy78FU8GpRlCkOQXcIErpe2ar2Ucyh(zCDHtbvnaofiBuY2USfhT)b48FU8GpSrjBuwfJJ2)ufjOdPjvT6oiCnLQioHFglvQwfFNQib1QyC0(NQ4va7WpJvXRilHvrqZMgzC010j3krJ8weUWj8ZyHT0Pzd0SPrghDHUrIjrQNqXfoHFglSLonBN)ZLh8zHUrIjrQNqXfe9IEiSbs22eBBGn6zdeztJmo6QGOdcbikm0ib9w4e(zSufli5aBhT)Pkkc2Cyl1WPGQgSbEpLhC2aV1B2CVtUvIg5TiuUu3nsmjs9ekYwlWw44K7t4NXQ4vabMWdRIx4uqvdGPtUvIg5Tie48tP1(NQwDFhQMsveNWpJLkvRIVtvKGAvmoA)tv8kGD4NXQ4vabMWdRIx4uqvdGZFHtmkW5NsR9pvXdSve2rv88x4eJU2cgSJHT0Pz78x4eJUg8a)8dlSLonBN)cNy018dwfli5aBhT)Pkkc2Cyl1WPGQgSbER3SjlKJemNdT)HTykSjIoKMWwqyl)tcBbHnWr2a)h6OSLFcYwW2jikB)fcztVr2e6KBLTIem0(NQ4vKLWQ4(QwDpvutPkIt4NXsLQvX3PksqTkghT)PkEfWo8Zyv8kYsyvui)pKnkyJc2e6KBfaIErpe22aB0dk2OKTDzJc22tpOydez7kGD4NX1fofu1a4uGSrjBuYMmSjK)hYgfSrbBcDYTcarVOhcBBGn6bfBBGTZ)5Yd(SeYrcMZH2)SGOx0dHnkzBx2OGT90dk2ar2Ucyh(zCDHtbvnaofiBuYgLSLonB(scclHCKG5CO9pa(sccljh2sNMTc6ljiSeYrcMZH2)SKCylDA2e6KBfaIErpe2ajB0dQQ4b2kc7OkE(lCIrxx4O3GbRIxbeycpSkEHtbvnao)foXOaNFkT2)u1Q77bvnLQioHFglvQwfFNQib1QyC0(NQ4va7WpJvXRilHvrH8)q2OGnkytOtUvai6f9qyBdSrpOyJs22LnkyBp9GInqKTRa2HFgxx4uqvdGtbYgLSrjBYWMq(FiBuWgfSj0j3kae9IEiSTb2OhuSTb2o)Nlp4ZIGoKMSGOx0dHnkzBx2OGT90dk2ar2Ucyh(zCDHtbvnaofiBuYgLSLonBLxxe0H0KL2NT9KWw60Sj0j3kae9IEiSbs2OhuvXdSve2rv88x4eJUMo5wbecSkEfqGj8WQ4fofu1a48x4eJcC(P0A)tvRUVFFnLQioHFglvQwfpWwryhvrqZgrXiR3yzb)ejKnxSvEDbLCujiU0(STNe2CXgOzRG(sccRlCkOQXsYHnxSDfWo8Z46cNcQAamDYTs0iVfHaNFkT2)WMl2Ucyh(zCDHtbvnao)foXOaNFkT2)ufJJ2)ufVWPGQgvT6(E6RPufXj8ZyPs1QyC0(NQi6gjMePEcfRIfKCGTJ2)uftD3iXKi1tOiBGFJdBZRSrumY6nwylMcB(VEZwQk5OsqKTykSrfci8vKTaISj5WMWdzl)tcB48sj3RQ4b2kc7OkcA2ikgz9gll4NiHS5Inkyd0SvEDLeq4R4cIcqKCh(zKnxSvEDbLCujiUGOx0dHnzyJUSjhB0LnqKTJdGx4gaXbNcBPtZw51fuYrLG4cIErpe2ar2a1AtSjdBAatqDPThcOpqPr2OKnxSPbmb1L2EiG(aLgztg2OBvRUVx21uQI4e(zSuPAvmoA)tvKC3xvXcsoW2r7FQII39fBTaBGJSfqKTW)Lu20NTuFUW59KNTykSfQIEokB6ZgbS5Wg4TEZMi6qAcBc9ez2UBLTwGnWr2a)h6OSbEquKnVhISP3XW2DKfytVr2o)Nlp4ZQkEGTIWoQILxxqjhvcIlTpB7jHnxSrbBGMTZ)5Yd(SiOdPjligfWylDA2o)Nlp4Z6cNcQASGOx0dHnzyBp9SrjBPtZw51fbDinzP9zBpjvT6(E6wtPkIt4NXsLQvXdSve2rv0xsqy5N)VKLi6cIXrzlDA28FcHnxSj0j3kae9IEiSbs2KnOylDA2kOVKGW6cNcQASKCQIXr7FQIoV2)u1Q773unLQioHFglvQwfpWwryhvXc6ljiSUWPGQgljNQyC0(NQOF()cGGeeSQwDFpvSMsveNWpJLkvRIhyRiSJQyb9Leewx4uqvJLKtvmoA)tv0hHeeUTNKQwDFpiCnLQioHFglvQwfpWwryhvXc6ljiSUWPGQgljNQyC0(NQOqdr)8)LQwDF)ounLQioHFglvQwfpWwryhvXc6ljiSUWPGQgljNQyC0(NQymhKOWidCICUQv33NkQPufXj8ZyPs1Q4b2kc7OkcA2ikgz9glRiNzZfBEbrriqqibH0dae9IEiSrJnqXMl2OGnqZMgzC0Lxqueceesqi9SWj8ZyHT0PzZxsqyrY9bbIPau6dUGOx0dHnzyt2SrzvmoA)tv8e5mqC0(hGCt0QyUjkWeEyv8kMMCx1Q70dQAkvrCc)mwQuTkghT)PkQWE2I6(Qybjhy7O9pvrrWMdB6nYMdSFyRGXgrdLnFjbb2uypBrLnWB9MTudNcQAipBVEJqWBcYMebz7h2o)Nlp4tv8aBfHDufVcyh(zCPWE2IkabS5aqYVYgn22ZMl2OGTc6ljiSUWPGQgljh2sNMn)NqyZfBcDYTcarVOhcBGKgB0dk2OKT0PzJc2Ucyh(zCPWE2IkabS5aqYVYgn2ONnxSbA2uypBrDP0Vo)Nlp4ZcIrbm2OKT0Pzd0SDfWo8Z4sH9SfvacyZbGKFTQv3PFFnLQioHFglvQwfpWwryhvXRa2HFgxkSNTOcqaBoaK8RSrJn6zZfBuWwb9Leewx4uqvJLKdBPtZM)tiS5InHo5wbGOx0dHnqsJn6bfBuYw60SrbBxbSd)mUuypBrfGa2Cai5xzJgB7zZfBGMnf2Zwux6(15)C5bFwqmkGXgLSLonBGMTRa2HFgxkSNTOcqaBoaK8RvX4O9pvrf2ZwuPVQvTkwETMs1991uQI4e(zSuPAv8DQIeuRIXr7FQIxbSd)mwfVISewfDG9dBfma4RH2)WMl2ioyodObmbvYsigGxay70xiHnzyt2S5InkyR86kjGWxXfe9IEiSbs2o)Nlp4ZkjGWxXvrcgA)dBPtZMZ3KFWcGFgXcHnzyBtSrzvSGKdSD0(NQOS2ETYgviGWxrcB)W28ZgCGThmGGXMgWeujSj8q20BKnhy)WwbJn4RH2)WwlW2MKJn)mIfcBbezlYqmkGXMKtv8kGat4HvrY22b4a2jJajbe(kw1Q70xtPkIt4NXsLQvX3PksqTkghT)PkEfWo8Zyv8kYsyv0b2pSvWaGVgA)dBUyJ4G5mGgWeujlHyaEbGTtFHe2KHnzZMl2OGTc6ljiSi391sYHT0PzZ5BYpybWpJyHWMmSTj2OSkwqYb2oA)tvuwBVwzlvLCujisy7h2MF2GdS9Gbem20aMGkHnHhYMEJS5a7h2kySbFn0(h2Ab22KCS5NrSqylGiBrgIrbm2KCQIxbeycpSks22oahWozeak5OsqSQv3LDnLQioHFglvQwfFNQib1QyC0(NQ4va7WpJvXRilHvXc6ljiSUWPGQgljh2CXgfSvqFjbHf5UVwsoSLonBEbrriqqibH0dae9IEiSjdBGInkzZfBLxxqjhvcIli6f9qytg2OVkwqYb2oA)tvuwBVwzlvLCujisyRfyl1WPGQgYjE3x7kldIIq22rcjiKEyRjSj5Wwmf2ahz7oUq2Oxo2i45NcHTmkOS9dB6nYwQk5OsqKnqWNsv8kGat4HvrY22bak5OsqSQv3PBnLQioHFglvQwfJJ2)uftci8vSkwqYb2oA)tvu0bpDKzJkeq4RiBXuylvLCujiYgbvjh2CG9dztF2sD3iXKi1tOiBNGOvXdSve2rvuJmo6cDJetIupHIlCc)mwyZfBGMTc6ljiSsci8vCHUrIjrQNqXcBUyR86kjGWxXLJNuwBNCJq2ajn22ZMl2o)Nlp4ZcDJetIupHIli6f9qydKSrpBUyJ4G5mGgWeujlHyaEbGTtFHe2OX2E2CXgm6caEHJUIsHS6HnzyJkYMl2kVUsci8vCbrVOhcBGiBGATj2ajBAatqDPThcOpqPXQwDFt1uQI4e(zSuPAv8aBfHDuf1iJJUq3iXKi1tO4cNWpJf2CXgfSHcc4r7le48E(pGZ3JsytgASDCa8c3aio4uyZfBN)ZLh8zHUrIjrQNqXfe9IEiSbs22ZMl2kVUGsoQeexq0l6HWgiYgOwBInqYMgWeuxA7Ha6duAKnkRIXr7FQIqjhvcIvT6ovSMsveNWpJLkvRIXr7FQIo)NbGi5LGhSkwqYb2oA)tvKkeq4RiBsoBr0rE2Im5ztHnsytF2KiiBTYwqylyJ4GNoYSLGdcd9HSj8q20BKTCqu224oZMpk8qKTGnHEAYncRIcpeyq30Q77RA1Dq4AkvrCc)mwQuTkEGTIWoQIquaIK7WpJS5ITZ75)aoFpkzvqH(0kBYqJT9S5InkyZXtkRTtUriBGKgB7zlDA2GOx0dHnqsJnTpBb02dzZfBehmNb0aMGkzjedWlaSD6lKWMm0yt2SrjBUyJc2anBOBKysK6juSWw60SbrVOhcBGKgBAF2cOThYgiYg9S5InIdMZaAatqLSeIb4fa2o9fsytgASjB2OKnxSrbBAatqDPThcOpqPr22aBq0l6HWgLSjdB0LnxS5fefHabHeespaq0l6HWgn2avvmoA)tvmjGWxXQwDFhQMsveNWpJLkvRIcpeyq30Q77RIXr7FQIo)NbGi5LGhSQv3tf1uQI4e(zSuPAvmoA)tvmjGWxXQ4b2kc7OkcA2Ucyh(zCr22oahWozeijGWxr2CXgefGi5o8ZiBUy78E(pGZ3JswfuOpTYMm0yBpBUyJc2C8KYA7KBeYgiPX2E2sNMni6f9qydK0yt7ZwaT9q2CXgXbZzanGjOswcXa8caBN(cjSjdn2KnBuYMl2OGnqZg6gjMePEcflSLonBq0l6HWgiPXM2NTaA7HSbISrpBUyJ4G5mGgWeujlHyaEbGTtFHe2KHgBYMnkzZfBuWMgWeuxA7Ha6duAKTnWge9IEiSrjBYW2E6zZfBEbrriqqibH0dae9IEiSrJnqvfpGDYiGgWeujv33x1Q77bvnLQioHFglvQwfJJ2)ufpW2J8dGIEoirRIfKCGTJ2)uf3iS9i)WwkONdsu2(HnpPS2ozKnnGjOsylu2ORCSTXDMnWVXHnO0m9KW2lPS1dB0tyJcjh20Nn6YMgWeujuY2dzt2e2OytYXMgWeujuwfpWwryhvrIdMZaAatqLWMm0yJE2CXge9IEiSbs2ONn5yJc2ioyodObmbvcBYqJTnXgLS5InuqapAFHaN3Z)bC(EucBYqJn6w1Q773xtPkIt4NXsLQvX4O9pvrOKJkbXQybjhy7O9pvrqii6WMKdBPQKJkbr2cLn6khB)WwKZSPbmbvcBua(noSL7REsyl)tcB48sj3SftHT5v2it4qUFLYQ4b2kc7OkcA2Ucyh(zCr22oaqjhvcIS5InuqapAFHaN3Z)bC(EucBYqJn6YMl2GOaej3HFgzZfBuWMJNuwBNCJq2ajn22Zw60SbrVOhcBGKgBAF2cOThYMl2ioyodObmbvYsigGxay70xiHnzOXMSzJs2CXgfSbA2q3iXKi1tOyHT0PzdIErpe2ajn20(SfqBpKnqKn6zZfBehmNb0aMGkzjedWlaSD6lKWMm0yt2SrjBUytdycQlT9qa9bknY2gydIErpe2KHnkyJUSjhBqPbfEycUkb5UNeaY5LMceZlCc)mwydezlvWMCSbLgu4Hj4Q8VNFok4cNWpJf2ar2OISrzvRUVN(AkvrCc)mwQuTkghT)PkcLCujiwfpWwryhvrqZ2va7WpJlY22b4a2jJaqjhvcIS5InqZ2va7WpJlY22bak5OsqKnxSHcc4r7le48E(pGZ3JsytgASrx2CXgefGi5o8ZiBUyJc2C8KYA7KBeYgiPX2E2sNMni6f9qydK0yt7ZwaT9q2CXgXbZzanGjOswcXa8caBN(cjSjdn2KnBuYMl2OGnqZg6gjMePEcflSLonBq0l6HWgiPXM2NTaA7HSbISrpBUyJ4G5mGgWeujlHyaEbGTtFHe2KHgBYMnkzZfBAatqDPThcOpqPr22aBq0l6HWMmSrbB0Ln5ydknOWdtWvji39KaqoV0uGyEHt4NXcBGiBPc2KJnO0GcpmbxL)98Zrbx4e(zSWgiYgvKnkRIhWozeqdycQKQ77RA199YUMsveNWpJLkvRIXr7FQIhy7r(bqrphKOvXcsoW2r7FQIBe2EKFylf0ZbjkB)WMykS1cS1dBoXuqV(Wwmf2gmGzWyZlCJnCqycySftHTwGTuFUW59yd8FOJYw5zZ7HiBLWlsq2ksiB6ZwkuDxz5owfpWwryhvrIdMZaAatqLWgn22ZMl2anBqPbfEycUkb5UNeaY5LMceZlCc)mwyZfBEbrriqqibH0dae9IEiSrJnqXMl2qbb8O9fcCEp)hW57rjSjdn2OGTJdGx4gaXbNcBBGT9SrjBUydIcqKCh(zKnxSbA2q3iXKi1tOyHnxSbA2kOVKGWIC3xljh2CXgfSHdctaBvqH(0kBGKgB0Vj2KJTRa2HFgx4GWeWaGycoaN3ZVhSWgLS5InnGjOU02db0hO0iBBGni6f9qytg2OBvRAvRIxiK0)uDNEqr)Eqj79PIQi4bC6jHuf3H3Xu19DG7ubQKn2s5gzR9CEOYMWdzJoxX0KB6WgebHk1qSWg59q2cj99cflSDUJjbjlMAzThKT9ujBB8NleQyHn6aLgu4Hj4ANOdB6ZgDGsdk8WeCTtlCc)mwOdBuqVBuUyQL1Eq2OIujBB8NleQyHn6aLgu4Hj4ANOdB6ZgDGsdk8WeCTtlCc)mwOdBuS3nkxm1m17W7yQ6(oWDQavYgBPCJS1Eopuzt4HSrNckeszLoSbrqOsnelSrEpKTqsFVqXcBN7ysqYIPww7bzt2ujBB8NleQyHnX2BJSraB0Wn2sLSPpBYQuWwPVAs)dBVdcd9HSrXUuYgf7DJYftnt9o8oMQUVdCNkqLSXwk3iBTNZdv2eEiB0XbIN3Zpu6WgebHk1qSWg59q2cj99cflSDUJjbjlMAzThKn6sLSTXFUqOIf2OJc7zlQR9RDIoSPpB0rH9Sf1LUFTt0HnkO3nkxm1YApiB0LkzBJ)CHqflSrhf2Zwux0V2j6WM(Srhf2Zwuxk9RDIoSrb9Ur5IPww7bzBtujBB8NleQyHn6OWE2I6A)ANOdB6ZgDuypBrDP7x7eDyJc6DJYftTS2dY2MOs224pxiuXcB0rH9Sf1f9RDIoSPpB0rH9Sf1Ls)ANOdBuqVBuUyQzQ3H3Xu19DG7ubQKn2s5gzR9CEOYMWdzJoLgIhLoSbrqOsnelSrEpKTqsFVqXcBN7ysqYIPww7bzdeMkzBJ)CHqflSrhO0Gcpmbx7eDytF2OduAqHhMGRDAHt4NXcDyJI9Ur5IPMPEhEhtv33bUtfOs2ylLBKT2Z5HkBcpKn6Cke6WgebHk1qSWg59q2cj99cflSDUJjbjlMAzThKn6sLSTXFUqOIf2eBVnYgbSrd3ylvYM(SjRsbBL(Qj9pS9oim0hYgf7sjBuqVBuUyQL1Eq2OIujBB8NleQyHnX2BJSraB0Wn2sLSPpBYQuWwPVAs)dBVdcd9HSrXUuYgf07gLlMAzThKTubvY2g)5cHkwytS92iBeWgnCJTujB6ZMSkfSv6RM0)W27GWqFiBuSlLSrb9Ur5IPww7bzBpOOs224pxiuXcBIT3gzJa2OHBSLkztF2KvPGTsF1K(h2Eheg6dzJIDPKnkO3nkxm1YApiB0dkQKTn(ZfcvSWgDuypBrDr)ANOdB6ZgDuypBrDP0V2j6Wgf7DJYftTS2dYg97Ps224pxiuXcB0rH9Sf11(1orh20Nn6OWE2I6s3V2j6Wgf7DJYftnt9o8oMQUVdCNkqLSXwk3iBTNZdv2eEiB0P8kDydIGqLAiwyJ8EiBHK(EHIf2o3XKGKftTS2dYgDPs224pxiuXcB0bDJetIupHIL1orh20Nn6uqFjbH1oTq3iXKi1tOyHoSrXE3OCXulR9GSTFpvY2g)5cHkwyJoqPbfEycU2j6WM(SrhO0Gcpmbx70cNWpJf6Wgf07gLlMAzThKT90tLSTXFUqOIf2OduAqHhMGRDIoSPpB0bknOWdtW1oTWj8ZyHoSrb9Ur5IPww7bzBVSPs224pxiuXcB0bknOWdtW1orh20Nn6aLgu4Hj4ANw4e(zSqh2OyVBuUyQzQt5gzJoseeOv0Jqh2IJ2)Wg4bHT5v2eEPPWwpSP3nHT2Z5H6IPEh458qflSbcZwC0(h2YnrjlM6QiXbpv3PFtPIQOd8f6mwf38MzBhjKGq6j0(h2s1prczQ38MztwgWZnB0dk5zJEqr)EMAM6nVz224DmjiHkzQ38MzBdSTJoozWyJoef2hLoSjKJe20NnY7HSTJ7SSYMWd3sytF2iXfYMd8piH0tcBA7HlM6nVz22aBGGFOJYwQfttUztAYiHWMyUpiBXuyde0hKnW7CMTCqu2Y)KGq207yytwgefHSTJesqi9SyQzQ38Mzl1DdpskwyZhfEiY2598dLnFmPhYITD8CqhLW28ZgUdONGuMT4O9pe2(jd2IPooA)dz5aXZ75hkTWXjdgGZ3KFyQJJ2)qwoq88E(HkhTD9FvZybqihGHfW7jbqF36HPooA)dz5aXZ75hQC021lGBXcGWdbkyO3Y7aXZ75hkabp)ui02K8Tany0fa8chDfLcz1Jm73et9MzdeGkc96bzd87(CZgfTaBXagLSr0qzZxsqGnf2ZwuzdCKnWJrztF2cvrphLn9zJa2Cyd8wVzl1WPGQglM64O9pKLdepVNFOYrB3Ra2HFgLFcpKMc7zlQaeWMdaj)Q8xrwcPTx(wGMc7zlQR9R7Gaq0qxXagqXH4IcqRWE2I6I(1DqaiAORyadO4qsNwH9Sf11(15)C5bFwfjyO9pYqtH9Sf1f9RZ)5Yd(SksWq7FOKPooA)dz5aXZ75hQC029kGD4Nr5NWdPPWE2IkabS5aqYVk)vKLqA0lFlqtH9Sf1f9R7Gaq0qxXagqXH4IcqRWE2I6A)6oiaen0vmGbuCiPtRWE2I6I(15)C5bFwfjyO9pYOWE2I6A)68FU8GpRIem0(hkzQJJ2)qwoq88E(HkhTDj5(GaXuak9bL3bIN3ZpuacE(PqOTx(wGgefGi5o8ZitDC0(hYYbIN3Zpu5OTlrXiR3m1m1BEZSL6UHhjflSHxiem202dztVr2IJ(q2AcBXv05WpJlM64O9peAB7ZwM6nZwQIefJSEZwlWMZtiTFgzJI5z7skpim8ZiB4GEnsyRh2oVNFOuYuhhT)HihTDjkgz9MPooA)droA7EfWo8ZO8t4H0WbHjGbaXeCaoVNFpyr(RilH0WbHjGTGycoY58n5hSa4NrSqaXDOujf0dIehmNbUdIIuYuhhT)HihTDVcyh(zu(j8qAKEsYiGgWeuL)kYsinIdMZaAatqLSeIb4fa2o9fsaj9m1Xr7FiYrB3tKZaXr7FaYnrLFcpKgrXiR3yrEIc7JsBV8TanIIrwVXYc(jsitDC0(hIC029e5mqC0(hGCtu5NWdPDke5jkSpkT9YlFlqJcqRrghD5fefHabHeesplCc)mwsNU86kjGWxXL2NT9Kqjt9MzBNLu2ehqaBsoS1tRDKZGXMWdzBJskB6ZMEJSTX7GGYZgefGi5MnWB9MTuFUW59yRfylu2Yp4SvKGH2)WuhhT)HihTDj5(GaXuak9bLVfObAFjbHfj3heiMcqPp4sYX1598FaNVhLidnzZuhhT)HihTDX5cN3t(wGMVKGWIK7dcetbO0hCj54YxsqyrY9bbIPau6dUGOx0dbKBY1598FaNVhLidn6YuhhT)HihTDprodehT)bi3ev(j8qALxzQJJ2)qKJ2UNiNbIJ2)aKBIk)eEiTsdXJYuhhT)HihTDd4jgeqFiehv(wGgoimbSvbf6tRYqB)MK7kGD4NXfoimbmaiMGdW5987blm1Xr7FiYrB3aEIbbCKYeKPooA)droA7M7KBLailMujXdhLPooA)droA76hjaVaGc7Zwctnt9M3mBB8)C5bFim1BMTDGaBrPqylGiBsoYZgzAhKn9gz7hKnWB9MT8dosu2sjfqWInzrjiBGFJdBfW6jHnHGOiKn9og224oZwbf6tRS9q2aV17xszlgWyBJ78IPooA)dzDke5OTRxa3IfaHhcuWqVL)a2jJaAatqLqBV8Tany0fa8chDfLczj54IcnGjOU02db0hO0iipVN)d489OKvbf6tRG4(1MsN(8E(pGZ3JswfuOpTkdTJdGx4gaXbNcLm1BMTDGaBZZwuke2aVZz2knYg4TE3dB6nY2GUPSjBqrKNnjcYMSuaeW2pS5)ecBG369lPSfdySTXDEXuhhT)HSofIC021lGBXcGWdbkyO3Y3c0GrxaWlC0vukKvpYiBqTby0fa8chDfLczvKGH2)468E(pGZ3JswfuOpTkdTJdGx4gaXbNct9MzteS5WMSqosWCo0(h2aV1B2snCkOQbBbHT8pjSfe2ahzd8FOJYw(jiBbBNGOS9xiKn9gztOtUv2ksWq7FyQJJ2)qwNcroA7kKJemNdT)r(wGgOjkgz9gll4NiHUO48FU8GpRlCkOQXcIErpeqkBxOGaE0(cboVN)d489OezOrxxAatqDPThcOpqPrz2dQ0PlOVKGW6cNcQASKCsN2)jexcDYTcarVOhciPNUuYuhhT)HSofIC02vihjyohA)J8TanqtumY6nwwWprcDHcc4r7le48E(pGZ3JsKHgDDrHq(Fifui0j3kae9IEiBGE6szQ88FU8GpukJq(Fifui0j3kae9IEiBGE6UHZ)5Yd(SUWPGQgli6f9qaXRa2HFgxx4uqvdGtbszQ88FU8Gpusjt9MzteS5WMi6qAcBG36nBPgofu1GTGWw(Ne2ccBGJSb(p0rzl)eKTGTtqu2(leYMEJSj0j3kBfjyO9pYZMVKYMdefqiBAatqLWMEhkBG35mB5(czlu2Yyqu22dkctDC0(hY6uiYrBxc6qAI8TanqtumY6nwwWprcDrX5)C5bFwx4uqvJfe9IEiGCVlnGjOU02db0hO0Om7bv60f0xsqyDHtbvnwsoPtl0j3kae9IEiGCpOOKPooA)dzDke5OTlbDinr(wGgOjkgz9gll4NiHUOqi)pKcke6KBfaIErpKnShuuMkp)Nlp4dLYiK)hsbfcDYTcarVOhYg2dQnC(pxEWN1fofu1ybrVOhciEfWo8Z46cNcQAaCkqktLN)ZLh8HskzQ3mBIGnh2snCkOQbBG3t5bNnWB9Mn37KBLOrElcLl1DJetIupHIS1cSfoo5(e(zKPooA)dzDke5OT7va7WpJYpHhs7cNcQAamDYTs0iVfHaNFkT2)i)vKLqAGwJmo6A6KBLOrElcx4e(zSKonO1iJJUq3iXKi1tO4cNWpJL0Pp)Nlp4ZcDJetIupHIli6f9qa5M2a9GOgzC0vbrhecquyOrc6TWj8ZyHPEZSjc2Cyl1WPGQgSbER3SjlKJemNdT)HTykSjIoKMWwqyl)tcBbHnWr2a)h6OSLFcYwW2jikB)fcztVr2e6KBLTIem0(hM64O9pK1PqKJ2UxbSd)mk)eEiTlCkOQbW5VWjgf48tP1(h5BbAN)cNy01wWGDmPtF(lCIrxdEGF(HL0Pp)foXOR5hu(RilH02ZuhhT)HSofIC029kGD4Nr5NWdPDHtbvnao)foXOaNFkT2)iFlq78x4eJUUWrVbdk)vKLqAc5)HuqHqNCRaq0l6HSb6bfLPsk2tpOaXRa2HFgxx4uqvdGtbsjLYiK)hsbfcDYTcarVOhYgOhuB48FU8GplHCKG5CO9pli6f9qOmvsXE6bfiEfWo8Z46cNcQAaCkqkPmDAFjbHLqosWCo0(haFjbHLKt60f0xsqyjKJemNdT)zj5KoTqNCRaq0l6Has6bftDC0(hY6uiYrB3Ra2HFgLFcpK2fofu1a48x4eJcC(P0A)J8TaTZFHtm6A6KBfqiq5VISesti)pKcke6KBfaIErpKnqpOOmvsXE6bfiEfWo8Z46cNcQAaCkqkPugH8)qkOqOtUvai6f9q2a9GAdN)ZLh8zrqhstwq0l6HqzQKI90dkq8kGD4NX1fofu1a4uGusz60Lxxe0H0KL2NT9KKoTqNCRaq0l6Has6bftDC0(hY6uiYrB3lCkOQH8TanqtumY6nwwWprcDvEDbLCujiU0(STNexGUG(sccRlCkOQXsYX1va7WpJRlCkOQbW0j3krJ8wecC(P0A)JRRa2HFgxx4uqvdGZFHtmkW5NsR9pm1BMTu3nsmjs9ekYg434W28kBefJSEJf2IPWM)R3SLQsoQeezlMcBuHacFfzlGiBsoSj8q2Y)KWgoVuY9IPooA)dzDke5OTl6gjMePEcfLVfObAIIrwVXYc(jsOlkaD51vsaHVIlikarYD4NrxLxxqjhvcIli6f9qKHUYrxq84a4fUbqCWPKoD51fuYrLG4cIErpeqeuRnjJgWeuxA7Ha6duAKsxAatqDPThcOpqPrzOlt9Mzt8UVyRfydCKTaISf(VKYM(SL6ZfoVN8SftHTqv0ZrztF2iGnh2aV1B2erhstytONiZ2DRS1cSboYg4)qhLnWdIIS59qKn9og2UJSaB6nY25)C5bFwm1Xr7FiRtHihTDj39L8TaTYRlOKJkbXL2NT9K4IcqF(pxEWNfbDinzbXOaw60N)ZLh8zDHtbvnwq0l6HiZE6PmD6YRlc6qAYs7Z2EsyQJJ2)qwNcroA768A)J8TanFjbHLF()swIOlighnDA)NqCj0j3kae9IEiGu2GkD6c6ljiSUWPGQgljhM64O9pK1PqKJ2U(5)lacsqWKVfOvqFjbH1fofu1yj5WuhhT)HSofIC021hHeeUTNe5BbAf0xsqyDHtbvnwsom1Xr7FiRtHihTDfAi6N)ViFlqRG(sccRlCkOQXsYHPooA)dzDke5OTBmhKOWidCICw(wGwb9Leewx4uqvJLKdtDC0(hY6uiYrB3tKZaXr7FaYnrLFcpK2vmn5w(wGgOjkgz9glRiND5fefHabHeespaq0l6HqduUOa0AKXrxEbrriqqibH0ZcNWpJL0P9LeewKCFqGykaL(Gli6f9qKr2uYuVz2ebBoSP3iBoW(HTcgBenu28LeeytH9Sfv2aV1B2snCkOQH8S96ncbVjiBseKTFy78FU8Gpm1Xr7FiRtHihTDvypBrDV8TaTRa2HFgxkSNTOcqaBoaK8R027IIc6ljiSUWPGQgljN0P9FcXLqNCRaq0l6HasA0dkktNMIRa2HFgxkSNTOcqaBoaK8R0O3fOvypBrDr)68FU8GpligfWOmDAqFfWo8Z4sH9SfvacyZbGKFLPooA)dzDke5OTRc7zlQ0lFlq7kGD4NXLc7zlQaeWMdaj)kn6Drrb9Leewx4uqvJLKt60(pH4sOtUvai6f9qajn6bfLPttXva7WpJlf2ZwubiGnhas(vA7DbAf2Zwux7xN)ZLh8zbXOagLPtd6Ra2HFgxkSNTOcqaBoaK8Rm1m1BEZSbcAiEu2kHxKGSf(DU1gjm1BMTuFUW59ylu2ORCSrXMKJnWB9MnqGiLSTXDEX2oWZdlDOygm2(Hn6LJnnGjOsKNnWB9MTudNcQAipBpKnWB9MTuOQSiz71BecEtq2apALnHhYg59q2WbHjGTyBhZKNnWJwzRfyl1DJKW2598F2AcBN3RNe2KCwm1Xr7FiRsdXJsdNlCEp5BbAOGaE0(cboVN)d489OezOrx50iJJUki6GqaIcdnsqVfoHFglUOOG(sccRlCkOQXsYjD6c6ljiSi391sYjD6c6ljiSeYrcMZH2)SKCsNgheMa2QGc9PvqsJ(nj3va7WpJlCqycyaqmbhGZ753dwsNg0xbSd)mUi9KKranGjOsPlkaTgzC0f6gjMePEcfx4e(zSKo95)C5bFwOBKysK6juCbrVOhIm0tjtDC0(hYQ0q8OYrB3Ra2HFgLFcpKMebbe6CgHYFfzjK2598FaNVhLSkOqFAvM9PtJdctaBvqH(0kiPr)MK7kGD4NXfoimbmaiMGdW5987blPtd6Ra2HFgxKEsYiGgWeuzQJJ2)qwLgIhvoA7sqimuSa4)dcqC6TO8hWozeqdycQeA7LVfO5fefHabHeespaq0l6HqduUOWxsqyrY9bbIPau6dUKCCb6YRlccHHIfa)FqaItVfbkVU0(STNK0P9FcXLqNCRaq0l6HasABkD6Z)5Yd(Siiegkwa8)bbio9wCDUdycsaeGXr7FISm0OFbcVP0PjVu2VNYkJrbWhma0TWZjJlCc)mwCbAFjbHvgJcGpyaOBHNtgxsouYuVz2KfIHTxGnqitFHe2cLT9Pc5yJOXzlHTxGnzX7sbh2OAokiHThYwKe9qu2ORCSPbmbvYIPooA)dzvAiEu5OTRqmaVaW2PVqI8TaTRa2HFgxseeqOZze6IcFjbH1Dxk4a4NJcswenoBLH2(ur60uaAhy)Wwbda(AO9pUioyodObmbvYsigGxay70xirgA0voIIrwVXYc(jsiLuYuVz2KfIHTxGnqitFHe20NTWXjdgBGamkzWyBN)M8dBTaB9ehTVq2(HTyaJnnGjOYwOSjB20aMGkzXuhhT)HSknepQC02vigGxay70xir(dyNmcObmbvcT9Y3c0Ucyh(zCjrqaHoNrOlIdMZaAatqLSeIb4fa2o9fsKHMSzQJJ2)qwLgIhvoA7IN7VNeai6aBVykY3c0Ucyh(zCjrqaHoNrORZ)5Yd(SUWPGQgli6f9qKzpOyQJJ2)qwLgIhvoA7gE(sKB5BbAxbSd)mUKiiGqNZi0ffEbrriqqibH0dae9IEi0aLlqdLgu4Hj4Q8VNFoky60(sccl)CpfsxWLKdLm1BMTuc)nilL0ohkYM(SfoozWydeGrjdgB783KFylu2ONnnGjOsyQJJ2)qwLgIhvoA76jPDouu(dyNmcObmbvcT9Y3c0Ucyh(zCjrqaHoNrOlIdMZaAatqLSeIb4fa2o9fsOrptDC0(hYQ0q8OYrBxpjTZHIY3c0Ucyh(zCjrqaHoNritnt9M3mBGGWlsq2(leYM2EiBHFNBTrct9MztwBVwzJkeq4RiHTFyB(zdoW2dgqWytdycQe2eEiB6nYMdSFyRGXg81q7FyRfyBtYXMFgXcHTaISfzigfWytYHPooA)dzvEL2va7WpJYpHhsJSTDaoGDYiqsaHVIYFfzjKMdSFyRGbaFn0(hxehmNb0aMGkzjedWlaSD6lKiJSDrr51vsaHVIli6f9qa55)C5bFwjbe(kUksWq7FsN25BYpybWpJyHiZMOKPEZSjRTxRSLQsoQeejS9dBZpBWb2EWacgBAatqLWMWdztVr2CG9dBfm2GVgA)dBTaBBso28ZiwiSfqKTidXOagBsom1Xr7FiRYRYrB3Ra2HFgLFcpKgzB7aCa7KraOKJkbr5VISesZb2pSvWaGVgA)JlIdMZaAatqLSeIb4fa2o9fsKr2UOOG(scclYDFTKCsN25BYpybWpJyHiZMOKPEZSjRTxRSLQsoQeejS1cSLA4uqvd5eV7RDLLbrriB7iHeespS1e2KCylMcBGJSDhxiB0lhBe88tHWwgfu2(Hn9gzlvLCujiYgi4tHPooA)dzvEvoA7EfWo8ZO8t4H0iBBhaOKJkbr5VISesRG(sccRlCkOQXsYXfff0xsqyrU7RLKt60EbrriqqibH0dae9IEiYakkDvEDbLCujiUGOx0drg6zQ3mBIo4PJmBuHacFfzlMcBPQKJkbr2iOk5WMdSFiB6ZwQ7gjMePEcfz7eeLPooA)dzvEvoA7Meq4RO8TannY4Ol0nsmjs9ekUWj8ZyXfOr3iXKi1tOyzLeq4RORYRRKacFfxoEszTDYncbjT9Uo)Nlp4ZcDJetIupHIli6f9qaj9UioyodObmbvYsigGxay70xiH2ExWOla4fo6kkfYQhzOIUkVUsci8vCbrVOhcicQ1MaPgWeuxA7Ha6duAKPooA)dzvEvoA7cLCujikFlqtJmo6cDJetIupHIlCc)mwCrbkiGhTVqGZ75)aoFpkrgAhhaVWnaIdofxN)ZLh8zHUrIjrQNqXfe9IEiGCVRYRlOKJkbXfe9IEiGiOwBcKAatqDPThcOpqPrkzQ3mBuHacFfztYzlIoYZwKjpBkSrcB6ZMebzRv2ccBbBeh80rMTeCqyOpKnHhYMEJSLdIY2g3z28rHhISfSj0ttUritDC0(hYQ8QC0215)maejVe8GYl8qGbDtPTNPooA)dzvEvoA7Meq4RO8TanikarYD4NrxN3Z)bC(EuYQGc9PvzOT3ffoEszTDYncbjT9PtdrVOhciPP9zlG2EOlIdMZaAatqLSeIb4fa2o9fsKHMSP0ffGgDJetIupHIL0PHOx0dbK00(SfqBpeeP3fXbZzanGjOswcXa8caBN(cjYqt2u6IcnGjOU02db0hO04gGOx0dHszORlVGOieiiKGq6baIErpeAGIPooA)dzvEvoA768FgaIKxcEq5fEiWGUP02ZuhhT)HSkVkhTDtci8vu(dyNmcObmbvcT9Y3c0a9va7WpJlY22b4a2jJajbe(k6cIcqKCh(z01598FaNVhLSkOqFAvgA7DrHJNuwBNCJqqsBF60q0l6HasAAF2cOTh6I4G5mGgWeujlHyaEbGTtFHezOjBkDrbOr3iXKi1tOyjDAi6f9qajnTpBb02dbr6DrCWCgqdycQKLqmaVaW2PVqIm0KnLUOqdycQlT9qa9bknUbi6f9qOuM907YlikcbccjiKEaGOx0dHgOyQ3mBBe2EKFylf0ZbjkB)WMNuwBNmYMgWeujSfkB0vo224oZg434WguAMEsy7Lu26Hn6jSrHKdB6ZgDztdycQekz7HSjBcBuSj5ytdycQekzQJJ2)qwLxLJ2Uhy7r(bqrphKOY3c0ioyodObmbvIm0O3fe9IEiGKE5OG4G5mGgWeujYqBtu6cfeWJ2xiW598FaNVhLidn6YuVz2aHGOdBsoSLQsoQeezlu2ORCS9dBroZMgWeujSrb434WwUV6jHT8pjSHZlLCZwmf2MxzJmHd5(vkzQJJ2)qwLxLJ2UqjhvcIY3c0a9va7WpJlY22bak5Osq0fkiGhTVqGZ75)aoFpkrgA01fefGi5o8ZOlkC8KYA7KBecsA7tNgIErpeqst7ZwaT9qxehmNb0aMGkzjedWlaSD6lKidnztPlkan6gjMePEcflPtdrVOhciPP9zlG2EiisVlIdMZaAatqLSeIb4fa2o9fsKHMSP0LgWeuxA7Ha6duACdq0l6Hidf0voO0GcpmbxLGC3tca58stbIzqmvihuAqHhMGRY)E(5OGGivKsM64O9pKv5v5OTluYrLGO8hWozeqdycQeA7LVfOb6Ra2HFgxKTTdWbStgbGsoQeeDb6Ra2HFgxKTTdauYrLGOluqapAFHaN3Z)bC(EuIm0ORlikarYD4Nrxu44jL12j3ieK02None9IEiGKM2NTaA7HUioyodObmbvYsigGxay70xirgAYMsxuaA0nsmjs9ekwsNgIErpeqst7ZwaT9qqKExehmNb0aMGkzjedWlaSD6lKidnztPlnGjOU02db0hO04gGOx0drgkORCqPbfEycUkb5UNeaY5LMceZGyQqoO0GcpmbxL)98ZrbbrQiLm1BMTncBpYpSLc65GeLTFytmf2Ab26HnNykOxFylMcBdgWmyS5fUXgoimbm2IPWwlWwQpx48ESb(p0rzR8S59qKTs4fjiBfjKn9zlfQURSChzQJJ2)qwLxLJ2Uhy7r(bqrphKOY3c0ioyodObmbvcT9UanuAqHhMGRsqU7jbGCEPPaXSlVGOieiiKGq6baIErpeAGYfkiGhTVqGZ75)aoFpkrgAuCCa8c3aio4u2WEkDbrbisUd)m6c0OBKysK6juS4c0f0xsqyrU7RLKJlkWbHjGTkOqFAfK0OFtYDfWo8Z4cheMagaetWb48E(9GfkDPbmb1L2EiG(aLg3ae9IEiYqxMAM6nVz2evmY6nwyBhpA)dHPEZS5ENCt0iVfHS9dBYofQKTncBpYpSLc65GeLPooA)dzrumY6nwODGTh5haf9CqIkFlqtJmo6A6KBLOrElcx4e(zS4I4G5mGgWeujYqt2UoVN)d489OezOrxxAatqDPThcOpqPXnarVOhImurM6nZM7DYnrJ8weY2pSTpfQKnXjCi3VYwQk5OsqKPooA)dzrumY6nwKJ2UqjhvcIY3c00iJJUMo5wjAK3IWfoHFglUoVN)d489OezOrxxAatqDPThcOpqPXnarVOhImurM6nZMOKVIqbPeKkzBhDCYGX2dzlvrbisUzd8wVzZxsqalSrfci8vKWuhhT)HSikgz9glYrBxN)ZaqK8sWdkVWdbg0nL2EM64O9pKfrXiR3yroA7Meq4RO8hWozeqdycQeA7LVfOPrghDrK8vekiLGlCc)mwCrbe9IEiGCp9Pt74jL12j3ieK02tPlnGjOU02db0hO04gGOx0drg6zQ3mBIs(kcfKsq2KJTu3nscB)W2(uOs2svuaIKB2Ocbe(kYwOSP3iB4uy7fyJOyK1B20NTeuzZlCJTIem0(h28rHhISL6UrIjrQNqrM64O9pKfrXiR3yroA768FgaIKxcEq5fEiWGUP02ZuhhT)HSikgz9glYrB3KacFfLVfOPrghDrK8vekiLGlCc)mwCPrghDHUrIjrQNqXfoHFglUIJ2xiaoOxJeA7D5ljiSis(kcfKsWfe9IEiGC)s2m1Xr7FilIIrwVXIC021ts7COO8TannY4OlIKVIqbPeCHt4NXIRZ75)aoFpkbK0Kntnt9M3mBPwmn5MPEZSjl0ttUzd8wVzZlCJTnUZSj8q2CVtUvIg5TiuE2KMmsiSjr6jHnqag6Dgm2eVJYdoHPooA)dzDfttUPDfWo8ZO8t4H0Mo5wjAK3IqGJdW5NsR9pYFfzjKgfGgknOWdtWvbd9odga5okp4exOGaE0(cboVN)d489OezODCa8c3aio4uOmDAkGsdk8WeCvWqVZGbqUJYdoX1598FaNVhLas6PKPEZSLAX0KB2aV1B2sD3ijSjhBU3j3krJ8wesLSjld3Apjp224oZwmf2sD3ijSbXOagBcpKTbDtzJkSrqatDC0(hY6kMMClhTDVIPj3Y3c00iJJUq3iXKi1tO4cNWpJfxAKXrxtNCRenYBr4cNWpJfxxbSd)mUMo5wjAK3IqGJdW5NsR9pUo)Nlp4ZcDJetIupHIli6f9qa5EM6nZwQfttUzd8wVzZ9o5wjAK3Iq2KJn3F2sD3ijujBYYWT2tYJTnUZSftHTudNcQAWMKdtDC0(hY6kMMClhTDVIPj3Y3c00iJJUMo5wjAK3IWfoHFglUaTgzC0f6gjMePEcfx4e(zS46kGD4NX10j3krJ8wecCCao)uAT)Xvb9Leewx4uqvJLKdtDC0(hY6kMMClhTDD(pdarYlbpO8cpeyq3uA7LhDtHbq49sJsJUBIPooA)dzDfttULJ2UxX0KB5BbAAKXrxejFfHcsj4cNWpJfxN)ZLh8zLeq4R4sYXffLxxjbe(kUGOaej3HFgtNUG(sccRlCkOQXsYXv51vsaHVIlhpPS2o5gHGK2EkDDEp)hW57rjRck0NwLHgfehmNb0aMGkzjedWlaSD6lKiJSiOlLUGrxaWlC0vukKvpYSNEM6nZwQfttUzd8wVztwgefHSTJesq6HkzlvLCujikhviGWxr2MxzRh2GOaej3SbJjbLNTIeSNe2snCkOQHCI391InrWMdBG36nBIOdPjSj0tKz7Uv2Ab2CEcP9Z4IPooA)dzDfttULJ2UxX0KB5BbAuOrghD5fefHabHeesplCc)mwsNgknOWdtWLxa3c8ca6nc4fefHabHeespu6c0LxxqjhvcIlikarYD4NrxLxxjbe(kUGOx0drgz7QG(sccRlCkOQXsYXfff0xsqyrU7RLKt60f0xsqyDHtbvnwq0l6Has6MoD51fbDinzP9zBpju6Q86IGoKMSGOx0dbKYUQvTwb]] )

end