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

            value = 7
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

            value = 7
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

            value = 7
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

            value = 7
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
                energySpent = ( energySpent + lastEnergy - current ) % 50
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
            local reduction = floor( energy_spent / 50 )
            energy_spent = energy_spent % 50

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
                local cast = rawget( class.abilities.vendetta, "lastCast" ) or 0
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
        --                     346975 - flagellation_cleanse (Get Mastery Buff)
        flagellation = {
            id = 323654,
            cast = 0,
            cooldown = 5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 3565724,

            toggle = "essences",

            bind = "flagellation_cleanse",

            usable = function ()
                return IsActiveSpell( 323654 ) and buff.flagellation.down, "flagellation already active"
            end,

            handler = function ()
                applyBuff( "flagellation" )
                applyDebuff( "target", "flagellation", 30 )
            end,

            auras = {
                flagellation = {
                    id = 323654,
                    duration = 45,
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
                },
            },
        },

        flagellation_cleanse = {
            id = 346975,
            cast = 0,
            cooldown = 5,
            gcd = "spell",

            startsCombat = true,
            texture = 3565724,

            bind = "flagellation",

            usable = function () return IsActiveSpell( 346975 ), "flagellation_cleanse not active" end,

            handler = function ()
                if buff.flagellation_buff.down then
                    stat.haste = stat.haste + ( 0.005 * debuff.flagellation.stack )
                end

                active_dot.flagellation = 0
                applyBuff( "flagellation_buff", nil, debuff.flagellation.stack )
                removeBuff( "flagellation" )
                removeDebuff( "target", "flagellation" )
                setCooldown( "flagellation", 5 )
            end,

            auras = {
                flagellation_buff = {
                    id = 345569,
                    duration = 20,
                    max_stack = 30,
                }
            }
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


    spec:RegisterPack( "Assassination", 20210123, [[da1EHbqiuIEeQQ6sqrsSjs4tssLrjj6usswLKqEfkvZIe1TGIQDPIFPsyysk5yqPwMKINHsyAOkCnuvzBOkIVHQinojbPZbfjwNKaVtsqO5Ps09uP2hkP)jji4GskLfkPYdHIyIssvxusk2iuuYhHIIrkjuQtkjuTsOKxkjumtjb1nLuQ2jQsdvskTuuf1trYurPCvOiP2kuK6RscLmwOOu7Lk)vPgSOdlSys6XkzYsCzWMrXNjLrdvoTuRgkssVgkmBQ62KQDR43igoQCCjbrlhYZv10jUosTDOQVlPQXJQY5jrMVkP9tzh2o2CuLqahV1uRAWUwyxdloyZt5b)yrfQJsuIdCuCXcJqdCutOdoQA7)4)EcPjJJIluYtIIJnh1tOrlWrHteUVcU4cTwWrREwe9l(wN2hstMfkyKl(wFDHJsLU9sfFCQoQsiGJ3AQvnyxlSRHfhS5P8GFSWrf0cocYrr16yIJcxxkW4uDuf4xok(ZFlRT)J)7jKMmwYZenAWWI)83sSIHoqkzznSqzlRPw1GTHLHf)5VL1obpuSeZYhAG3hstglRet8qmpuLL0Cw2JLCOMGArjlFILTyz9eAFXYHiwQbILQ0OgkwQc46Py5lq4fCwglPjZFCu((L3XMJ6fi8coO4yZXl2o2CuWeQEO4QZrflPjJJAHA9NmBb05GxCuf4xOMtAY4O4T1W9s4XaqwsglzbBvGLycQ1FYyjBGoh8IJAHAbqD4OKWdJCMwdN8s4XaqhycvpuSuHLph49BjqAG8wY6TLSWsfwUi6QKnhPh5TK1Bl5HLkSucKgihP1HTq2LgSeZTeb6rpVLSAjpXjoERXXMJcMq1dfxDoQyjnzCuiAoHgboQc8luZjnzCu82A4Ej8yailjJLyZwfyj1eCpoIyjptZj0iWrTqTaOoCus4HrotRHtEj8yaOdmHQhkwQWYfrxLS5i9iVLSEBjpSuHLsG0a5iToSfYU0GLyULiqp65TKvl5joXXllCS5OGju9qXvNJkwstghfhH43i4j0Of4OkWVqnN0KXrrrRkaIHwdQalRnooVswsqwYZadcECwwFl4SuLMHbkwIzceIiW7OyiO9a8joEX2joE5HJnhfmHQhkU6CuXsAY4O0ceIiGJAHAbqD4OKWdJCEAvbqm0AWbMq1dflvyzLwIa9ON3YlTe7AS86vl50P9sZ5Baz5L3wITLvzPclLaPbYrADylKDPblXClrGE0ZBjRwwJJAP0YdBjqAG8oEX2joE5NJnhfmHQhkU6CuXsAY4O4ie)gbpHgTahvb(fQ5KMmokkAvbqm0AGLSBz1W3RzjzSeB2Qal5zGbbpolXmbcreWYqSuWbwctXscJLVaHxWzPqSudel1d(SSqJcPjJLQadbbwwn89XOr3tiGJIHG2dWN44fBN44LN4yZrbtO6HIRoh1c1cG6WrjHhg580QcGyO1GdmHQhkwQWsj8WihGVpgn6EcboWeQEOyPclJL04HnmGEdVL3wITLkSuLMH580QcGyO1Gdc0JEElV0sSpSWrflPjJJslqiIaoXXlp1XMJcMq1dfxDoQfQfa1HJscpmY5PvfaXqRbhycvpuSuHLlIUkzZr6rElV82sw4OIL0KXrPtlTpeWjoXrHpM(X5yZXl2o2CuWeQEO4QZrr4CupioQyjnzCu4duhQEWrHp80GJQslzPLi6byiin4uGqW5vA)4IcP()atO6HILkSeyyGL04H9IORs2CKEK3swVTCXT1d(2phmflRYYRxTSslr0dWqqAWPaHGZR0(Xffs9)bMq1dflvy5IORs2CKEK3YlTSglRYrvGFHAoPjJJcZQN(Xzz9TGZs9GplXKQ1sgcYsEBnCYlHhdaPSL0Jh(3s6VhnlREieCELSKcxui1)ok8bApHo4OMwdN8s4Xaq7f3ErMslnzCIJ3ACS5OGju9qXvNJkwstghf(y6hNJQa)c1CstghfMoM(Xzz9TGZYQHVxZs2TK3wdN8s4XaqvGL1EWxRtRBjMuTwgtXYQHVxZseefLSKHGSCa(elXmys17OwOwauhokj8WihGVpgn6EcboWeQEOyPclLWdJCMwdN8s4XaqhycvpuSuHL4duhQE4mTgo5LWJbG2lU9ImLwAYyPclxeIVqQFoaFFmA09ecCqGE0ZB5LwITtC8YchBokycvpuC15OIL0KXrHpM(X5OkWVqnN0KXrHPJPFCwwFl4SK3wdN8s4XaqwYUL8sSSA471QalR9GVwNw3smPATmMILyAykGiHL0CoQfQfa1HJscpmYzAnCYlHhdaDGju9qXsfwYslLWdJCa((y0O7je4atO6HILkSeFG6q1dNP1WjVeEma0EXTxKP0stglvyzbuPzyo4HPaIehAoN44Lho2CuWeQEO4QZrflPjJJIJq8Be8eA0cCuaFck2HoHEehfp4NJIHG2dWN44fBN44LFo2CuWeQEO4QZrTqTaOoCus4HropTQaigAn4atO6HILkSCri(cP(5OfierGdnNLkSSslle5OfierGdcyqWJlu9GLxVAzbuPzyo4HPaIehAolvyzHihTaHicC40P9sZ5Baz5L3wITLvzPclxeDvYMJ0J8NcW0RwSK1BlR0YNd8(Teinq(dtmBcZgJPXdVLSwHGL8WYQSuHLOOlBapmYjkL)0JLSAj214OIL0KXrHpM(X5ehV8ehBokycvpuC15OIL0KXrHpM(X5OkWVqnN0KXrHPJPFCwwFl4SS2JxaKL12)X3tfyjVelFbcVGZYykwoelJL04blR9AZsvAggLTKNP5eAey5qel7XseWGGhNLOy0aLTSqJ6rZsmnmfqKGD2QZrTqTaOoCuvAPeEyKJE8cG2X)X)9CGju9qXYRxTerpadbPbh9aHXMWSfCWwpEbq74)4)EoWeQEOyzvwQWswAzHihenNqJGdcyqWJlu9GLkSSqKJwGqeboiqp65TKvlzHLkSSaQ0mmh8WuarIdnNLkSSaQ0mmNhxJ)qZ5eN4Okatq7fhBoEX2XMJkwstghfg9cdhfmHQhkU6CIJ3ACS5OGju9qXvNJQa)c1CstghfpdVaHxWzzZyjh5)w1dww5qSepTFauO6blHb0B4TShlxeD1qQYrflPjJJ6fi8coN44Lfo2CuWeQEO4QZrr4CupioQyjnzCu4duhQEWrHp80GJcgaPP0bbAWyj7wYr6NmqzR6bO8wwrwYtT8clR0YASSIS85aVFJlEbSSkhf(aTNqhCuWainL2iqdM9IOR2duCIJxE4yZrbtO6HIRohfHZr9G4OIL0KXrHpqDO6bhf(WtdoQNd8(Teinq(dtmBcZgJPXdVLxAznok8bApHo4O(E08WwcKgioXXl)CS5OGju9qXvNJAHAbqD4OkGkndZHXhAG3hstMdc0JEElV0YACuXsAY4Oy8Hg49H0KzV8qmp4ehV8ehBokycvpuC15OwOwauhoQxGWl4GYbr0ObhvSKMmoQv497yjnz2((fhLVFzpHo4OEbcVGdkoXXlp1XMJcMq1dfxDoQfQfa1HJQslzPLs4Hro6XlaAh)h)3ZbMq1dflVE1YcroAbcre4i9cJE0SSkhvSKMmoQv497yjnz2((fhLVFzpHo4OwL3joERqDS5OGju9qXvNJAHAbqD4OEoW73sG0a5pmXSjmBmMgp8wE5TLvAj)SeZTerpadbPbNs846rB)lc9uqG)atO6HILvzPclvPzyoVVxWoMYU0l4Ga9ON3YlTKP1WjBeOh98wQWseWGGhxO6blvy5IORs2CKEK3swVTKfoQyjnzCuVVxWoMYU0lWjoEXuCS5OGju9qXvNJkwstgh1k8(DSKMmBF)IJY3VSNqhCufI4ehVyxlhBokycvpuC15OIL0KXrTcVFhlPjZ23V4O89l7j0bhvPrWsCIJxSX2XMJcMq1dfxDoQfQfa1HJcgaPP0Pam9Qflz92sS5NLSBj(a1HQhoWainL2iqdM9IOR2duCuXsAY4Oc0kgyleecgXjoEXUghBoQyjnzCubAfdS5O9p4OGju9qXvNtC8InlCS5OIL0KXr5BnCYVXuLUOPdJ4OGju9qXvNtC8InpCS5OIL0KXrPgABcZwq9cJ3rbtO6HIRoN4ehfhcweD1qCS54fBhBoQyjnzCubhNxPnhPFY4OGju9qXvNtC8wJJnhvSKMmokvIiEOSz8HsqP(E02cHVECuWeQEO4QZjoEzHJnhfmHQhkU6CuXsAY4O0degqzZqq7cecoh1c1cG6WrHIUSb8WiNOu(tpwYQLyZphfhcweD1q2pSit5Du8ZjoE5HJnhvSKMmoQxGWl4CuWeQEO4QZjoE5NJnhfmHQhkU6CuXsAY4OEFVGDmLDPxGJAHAbqD4OqadcECHQhCuCiyr0vdz)WImL3rHTtCIJQ0iyjo2C8ITJnhfmHQhkU6CuXsAY4OGbpmeDhvb(fQ5KMmoQQzWddr3YqSKhSBzL8JDlRVfCww9uvzjMuThlR466qPdb8kzjzSSg2TucKgiVYwwFl4Setdtbeju2scYY6BbNLSvNYwseCaQ((blRpAXsgcYYNOdwcdG0u6yzT5FIL1hTyzZyz1W3Rz5IORsSSFlxe9E0SKM74OwOwauhokGHbwsJh2lIUkzZr6rElz92sEyj7wkHhg5uaGdq7xqHeAG(bMq1dflvyzLwwavAgMdEykGiXHMZYRxTSaQ0mmNhxJ)qZz51RwcdG0u6uaME1ILxEBzn8Zs2TeFG6q1dhyaKMsBeObZEr0v7bkwE9QLS0s8bQdvpC(E08WwcKgiwwLLkSSslzPLs4HroaFFmA09ecCGju9qXYRxTCri(cP(5a89XOr3tiWbb6rpVLSAznwwLtC8wJJnhfmHQhkU6Cueoh1dIJkwstghf(a1HQhCu4dpn4OweDvYMJ0J8NcW0RwSKvlX2YRxTegaPP0Pam9QflV82YA4NLSBj(a1HQhoWainL2iqdM9IOR2duS86vlzPL4duhQE489O5HTeinqCu4d0EcDWrr)WMP9Ea5ehVSWXMJcMq1dfxDoQyjnzCupGqHaLTkzG9Z1yaoQfQfa1HJspEbq74)4)E2iqp65T82YAzPclR0svAgMZ77fSJPSl9co0CwQWswAzHiNhqOqGYwLmW(5AmGDHihPxy0JMLxVAjtRHt2iqp65T8YBl5NLxVA5Iq8fs9Z5bekeOSvjdSFUgd4SWfin43mOyjnzcVLSEBznhEk)S86vlFcTxTNYXdrzRQ0g4l058WbMq1dflvyjlTuLMH54HOSvvAd8f6CE4qZzzvoQLslpSLaPbY74fBN44Lho2CuWeQEO4QZrflPjJJIjMnHzJX04H3rvGFHAoPjJJcZkgljmwwXmnE4TmelXgtHDlFjwy8wsySSIDxkWyzD(OaVLeKLHw0ZlwYd2TucKgi)XrTqTaOoCu4duhQE4q)WMP9EazPclR0svAgMdUUuGzR6Jc8NxIfgwY6TLyJPy51RwwPLS0soutqTO0grKqAYyPclFoW73sG0a5pmXSjmBmMgp8wY6TL8Ws2T8fi8coOCqenAWYQSSkN44LFo2CuWeQEO4QZrflPjJJIjMnHzJX04H3rTuA5HTeinqEhVy7OwOwauhok8bQdvpCOFyZ0EpGSuHLph49BjqAG8hMy2eMngtJhElz92sw4OkWVqnN0KXrHzfJLeglRyMgp8wkeldooVsww9qu8kzz1s6Nmw2mw2tSKgpyjzSmgLSucKgiwgILSWsjqAG8hN44LN4yZrbtO6HIRoh1c1cG6WrHpqDO6Hd9dBM27bKLkSCri(cP(5GhMcisCqGE0ZBjRwIDTCuXsAY4OGfospABeWHA9ykoXXlp1XMJcMq1dfxDoQfQfa1HJcFG6q1dh6h2mT3dilvyzLwQhVaOD8F8FpBeOh98wEBzTS86vlvPzyoQ(EkFxGdnNLv5OIL0KXrf6Q0poN44Tc1XMJcMq1dfxDoQyjnzCu60s7dbCulLwEylbsdK3Xl2oQfQfa1HJcFG6q1dh6h2mT3dilvy5ZbE)wcKgi)HjMnHzJX04H3YBlRXrvGFHAoPjJJITqfZRDAP9HawkeldooVsww9qu8kzz1s6NmwgIL1yPeinqEN44ftXXMJcMq1dfxDoQfQfa1HJcFG6q1dh6h2mT3dihvSKMmokDAP9HaoXjoQv5DS54fBhBoQyjnzCum(qd8(qAY4OGju9qXvNtC8wJJnhfmHQhkU6CuXsAY4O0degqzZqq7cecoh1sPLh2sG0a5D8ITJAHAbqD4Oqrx2aEyKtuk)HMZsfwwPLsG0a5iToSfYU0GLxA5IORs2CKEK)uaME1ILvKLyF4NLxVA5IORs2CKEK)uaME1ILSEB5IBRh8TFoykwwLJQa)c1CstghvfNXYOuEldeyjnNYw(tZbwk4aljdyz9TGZspPE4flzJTQ)yjM6hSSECWyzrPE0SKjEbqwk4IXsmPATSam9QfljilRVfCeAXYyuYsmPApoXXllCS5OGju9qXvNJkwstghLEGWakBgcAxGqW5OkWVqnN0KXrvXzSCiwgLYBz9T3BzPblRVfC9yPGdSCa(elzrTELTK(blRDMQ3sYyPk5FlRVfCeAXYyuYsmPApoQfQfa1HJcfDzd4HrorP8NESKvlzrTSeZTefDzd4HrorP8NcnkKMmwQWYfrxLS5i9i)Pam9Qflz92Yf3wp4B)CWuCIJxE4yZrbtO6HIRohfHZr9G4OIL0KXrHpqDO6bhf(WtdokwAPeEyKZ0A4Kxcpga6atO6HILxVAjlTucpmYb47JrJUNqGdmHQhkwE9QLlcXxi1phGVpgn6Ecboiqp65T8sl5NLyUL1yzfzPeEyKtbaoaTFbfsOb6hycvpuCuf4xOMtAY4OW0Wuarcl9eTEfElxKP0stMW)wQgpuSKmwUOriyelFoy5OWhO9e6GJcpmfqKypTgo5LWJbG2lYuAPjJtC8YphBokycvpuC15OwOwauhokwA5lq4fCq5GiA0GLkSSqKdIMtOrWr6fg9OzPclzPLfqLMH5GhMcisCO5SuHL4duhQE4GhMcisSNwdN8s4Xaq7fzkT0KXrflPjJJcpmfqKWjoE5jo2CuWeQEO4QZrflPjJJc47JrJUNqahvb(fQ5KMmoQQHVpgn6EcbSSECWy5qelFbcVGdkwgtXsvIGZsEMMtOrGLXuSeZeieraldeyjnNLmeKLEYOzjmeAnChh1c1cG6WrXslFbcVGdkherJgSuHLvAjlTSqKJwGqeboiGbbpUq1dwQWYcroiAoHgbheOh98wYQL8Ws2TKhwwrwU426bF7NdMILxVAzHihenNqJGdc0JEElRilR1HFwYQLsG0a5iToSfYU0GLvzPclLaPbYrADylKDPblz1sE4ehV8uhBokycvpuC15OwOwauhoQcroiAoHgbhPxy0JMLxVAzHiNh4((psVWOhnhvSKMmoQhxJ3joERqDS5OGju9qXvNJAHAbqD4OuPzyoQEcP4PF5GGyjwE9QLmTgozJa9ON3YlTKf1YYRxTSaQ0mmh8WuarIdnNJkwstghfhrAY4ehVyko2CuWeQEO4QZrTqTaOoCufqLMH5GhMcisCO5CuXsAY4Ou9eszZqJuYjoEXUwo2CuWeQEO4QZrTqTaOoCufqLMH5GhMcisCO5CuXsAY4Oub0dim6rZjoEXgBhBokycvpuC15OwOwauhoQcOsZWCWdtbejo0CoQyjnzCumncu9esXjoEXUghBokycvpuC15OwOwauhoQcOsZWCWdtbejo0CoQyjnzCuXSGxqHFVcV3joEXMfo2CuWeQEO4QZrTqTaOoCuS0YxGWl4GYj8ElvyPE8cG2X)X)9SrGE0ZB5TL1YrflPjJJAfE)owstMTVFXr57x2tOdok8X0poN44fBE4yZrbtO6HIRohvSKMmoknFu6qiOFRdLW7BY4OwOwauhoQcOsZWCWdtbejo0CokGHbwYEcDWrP5Jshcb9BDOeEFtgN44fB(5yZrbtO6HIRohvSKMmoknFu6qiOFRgfnWrTqTaOoCufqLMH5GhMcisCO5CuaddSK9e6GJsZhLoec63QrrdCIJxS5jo2CuWeQEO4QZrvGFHAoPjJJQ6bMG2lwYeEVASWWsgcYs6pu9GLTa6FfyjM6hSKmwUieFHu)CCuXsAY4OOFy3cO)oXjoQcrCS54fBhBokycvpuC15OiCoQhehvSKMmok8bQdvp4OWhEAWrXHAcQfL2iIestglvy5ZbE)wcKgi)HjMnHzJX04H3swTKfwQWYkTSqKJwGqeboiqp65T8slxeIVqQFoAbcre4uOrH0KXYRxTKJ0pzGYw1dq5TKvl5NLv5OkWVqnN0KXrvHB9wSeZeierG3sYy5qgmNd16OaPKLsG0a5TKHGSuWbwYHAcQfLSerKqAYyzZyj)y3svpaL3YabwgEeefLSKMZrHpq7j0bh1JrZTxkT8WwlqiIaoXXBno2CuWeQEO4QZrr4CupioQyjnzCu4duhQEWrHp80GJId1eulkTrejKMmwQWYNd8(Teinq(dtmBcZgJPXdVLSAjlSuHLvAzbuPzyopUg)HMZYRxTKJ0pzGYw1dq5TKvl5NLv5OkWVqnN0KXrvHB9wSKNP5eAe8wsglhYG5COwhfiLSucKgiVLmeKLcoWsoutqTOKLiIestglBgl5h7wQ6bO8wgiWYWJGOOKL0Cok8bApHo4OEmAU9sPLh2iAoHgboXXllCS5OGju9qXvNJIW5OEqCuXsAY4OWhOou9GJcF4PbhvbuPzyo4HPaIehAolvyzLwwavAgMZJRXFO5S86vl1Jxa0o(p(VNnc0JEElz1YAzzvwQWYcroiAoHgbheOh98wYQL14OkWVqnN0KXrvHB9wSKNP5eAe8w2mwIPHPaIeStHRXFrThVailRT)J)7XY(TKMZYykwwpyjUapyznSB5dlYuEl9aJyjzSuWbwYZ0CcncSS6jS5OWhO9e6GJ6XO52iAoHgboXXlpCS5OGju9qXvNJkwstghLwGqebCuf4xOMtAY4OO4GvhElXmbcreWYykwYZ0CcncS8bHMZsoutqwkelRg((y0O7jeWYv8IJAHAbqD4OKWdJCa((y0O7je4atO6HILkSKLwwavAgMJwGqeboaFFmA09ecuSuHLfIC0ceIiWHtN2lnNVbKLxEBj2wQWYfH4lK6NdW3hJgDpHaheOh98wEPL1yPclFoW73sG0a5pmXSjmBmMgp8wEBj2wQWsu0LnGhg5eLYF6XswTKNyPclle5OfierGdc0JEElRilR1HFwEPLsG0a5iToSfYU0GtC8YphBokycvpuC15OwOwauhokj8WihGVpgn6EcboWeQEOyPclR0sGHbwsJh2lIUkzZr6rElz92Yf3wp4B)CWuSuHLlcXxi1phGVpgn6Ecboiqp65T8slX2sfwwiYbrZj0i4Ga9ON3YkYYAD4NLxAPeinqosRdBHSlnyzvoQyjnzCuiAoHgboXXlpXXMJcMq1dfxDoQyjnzCuCeIFJGNqJwGJQa)c1CstghfMjqiIawsZHbaCkBz4FILcQH3sHyj9dw2ILXBzy5ZbRo8wQbdGcHGSKHGSuWbw6JxSetQwlvbgccSmSKPN(XbihfdbThGpXXl2oXXlp1XMJcMq1dfxDoQfQfa1HJcbmi4XfQEWsfwUi6QKnhPh5pfGPxTyjR3wITLkSSsl50P9sZ5Baz5L3wITLxVAjc0JEElV82sPxySLwhSuHLph49BjqAG8hMy2eMngtJhElz92swyzvwQWYkTKLwc89XOr3tiqXYRxTeb6rpVLxEBP0lm2sRdwwrwwJLkS85aVFlbsdK)WeZMWSXyA8WBjR3wYclRYsfwwPLsG0a5iToSfYU0GLyULiqp65TSklz1sEyPcl1Jxa0o(p(VNnc0JEElVTSwoQyjnzCuAbcreWjoERqDS5OGju9qXvNJIHG2dWN44fBhvSKMmokocXVrWtOrlWjoEXuCS5OGju9qXvNJkwstghLwGqebCululaQdhflTeFG6q1dNhJMBVuA5HTwGqebSuHLiGbbpUq1dwQWYfrxLS5i9i)Pam9Qflz92sSTuHLvAjNoTxAoFdilV82sST86vlrGE0ZB5L3wk9cJT06GLkS85aVFlbsdK)WeZMWSXyA8WBjR3wYclRYsfwwPLS0sGVpgn6EcbkwE9QLiqp65T8YBlLEHXwADWYkYYASuHLph49BjqAG8hMy2eMngtJhElz92swyzvwQWYkTucKgihP1HTq2LgSeZTeb6rpVLvzjRwIDnwQWs94faTJ)J)7zJa9ON3YBlRLJAP0YdBjqAG8oEX2joEXUwo2CuWeQEO4QZrflPjJJAHA9NmBb05GxCuf4xOMtAY4OWeuR)KXs2aDo4fljJL60EP58GLsG0a5Tmel5b7wIjvRL1Jdglr0Z0JMLeAXYESSM3YkP5SuiwYdlLaPbYxLLeKLS4TSs(XULsG0a5RYrTqTaOoCuph49BjqAG8wY6TL1yPclrGE0ZB5LwwJLSBzLw(CG3VLaPbYBjR3wYplRYsfwcmmWsA8WEr0vjBospYBjR3wYdN44fBSDS5OGju9qXvNJkwstghfIMtOrGJQa)c1CstghvfdaCwsZzjptZj0iWYqSKhSBjzSm8ElLaPbYBzL1Jdgl9n(E0S0tgnlHHqRHZYykwoeXYFcUhhrQYrTqTaOoCuS0s8bQdvpCEmAUnIMtOrGLkSSslbggyjnEyVi6QKnhPh5TK1Bl5HLkSebmi4XfQEWYRxTKLwk9cJE0SuHLvAP06GLSAj21YYRxTCr0vjBospYBjR3wwJLvzzvwQWYkTKtN2lnNVbKLxEBj2wE9QLiqp65T8YBlLEHXwADWsfw(CG3VLaPbYFyIzty2ymnE4TK1BlzHLvzPclR0swAjW3hJgDpHaflVE1seOh98wE5TLsVWylToyzfzznwQWYNd8(Teinq(dtmBcZgJPXdVLSEBjlSSklvyPeinqosRdBHSlnyjMBjc0JEElz1sE4ehVyxJJnhfmHQhkU6CuXsAY4Oq0CcncCululaQdhflTeFG6q1dNhJMBVuA5HnIMtOrGLkSKLwIpqDO6HZJrZTr0CcncSuHLaddSKgpSxeDvYMJ0J8wY6TL8WsfwIage84cvpyPclR0soDAV0C(gqwE5TLyB51RwIa9ON3YlVTu6fgBP1blvy5ZbE)wcKgi)HjMnHzJX04H3swVTKfwwLLkSSslzPLaFFmA09ecuS86vlrGE0ZB5L3wk9cJT06GLvKL1yPclFoW73sG0a5pmXSjmBmMgp8wY6TLSWYQSuHLsG0a5iToSfYU0GLyULiqp65TKvl5HJAP0YdBjqAG8oEX2joEXMfo2CuWeQEO4QZrflPjJJAHA9NmBb05GxCuf4xOMtAY4OWeuR)KXs2aDo4fljJLuSzzZyzpwYftb07LLXuSSflRV9Ellel9W)wwc9qdSuWfJLvZGhgIULfAWsHyjB1DrTxBoQfQfa1HJ65aVFlbsdK3YBlX2sfwcmmWsA8WEr0vjBospYBjR3wwPLlUTEW3(5GPyjMBj2wwLLkSebmi4XfQEWsfwYslb((y0O7jeOyPclzPLfqLMH584A8hAolvyPE8cG2X)X)9SrGE0ZB5TL1YsfwkbsdKJ06Wwi7sdwI5wIa9ON3swTKhoXXl28WXMJkwstgh1dCF)okycvpuC15eN4ehfEa9nzC8wtTQb7AHn28uhv9bA6r7DuvSQnEM3koVyMkWslzdhyzRZrqILmeKLvh(y6hx1zjcQqs3iOy5t0bldAHOhcuSCHlgn4pgwv4EalXUcSetidEajqXYQdrpadbPbhm7QZsHyz1HOhGHG0GdM9bMq1dLQZYkRHVQogwv4Eal5jvGLyczWdibkwwDi6byiin4GzxDwkelRoe9ameKgCWSpWeQEOuDwwj28v1XWYWQIvTXZ8wX5fZubwAjB4alBDocsSKHGSS6katq7LQZseuHKUrqXYNOdwg0crpeOy5cxmAWFmSQW9awYIkWsmHm4bKaflPADmXYxPrc(SetflfILvy6WYsJV)Mmws4auieKLvErvwwj28v1XWQc3dyzfAfyjMqg8asGILvhIEagcsdoy2vNLcXYQdrpadbPbhm7dmHQhkvNLvInFvDmSmSQyvB8mVvCEXmvGLwYgoWYwNJGelziilRUcrQolrqfs6gbflFIoyzqle9qGILlCXOb)XWQc3dyjpQalXeYGhqcuSS6a((y0O7jeOCWSRolfILvxbuPzyoy2hGVpgn6EcbkvNLvInFvDmSmSQ46CeKafl5PwglPjJL((L)yy5O4qeM2dok(ZFlRT)J)7jKMmwYZenAWWI)83sSIHoqkzznSqzlRPw1GTHLHf)5VL1obpuSeZYhAG3hstglRet8qmpuLL0Cw2JLCOMGArjlFILTyz9eAFXYHiwQbILQ0OgkwQc46Py5lq4fCwglPjZFmSmS4p)TSA4dw0cuSufyiiWYfrxnelvbTE(JL12AbCYB5qgmhxG0zO9wglPjZBjz8kDmSIL0K5pCiyr0vd5o448kT5i9tgdRyjnz(dhcweD1qy)(cvIiEOSz8HsqP(E02cHVEmSIL0K5pCiyr0vdH97l0degqzZqq7cecoL5qWIORgY(Hfzk)n)uUzUrrx2aEyKtuk)PhwXMFgwXsAY8hoeSi6QHW(9fVaHxWzyflPjZF4qWIORgc73x8(Eb7yk7sVaL5qWIORgY(Hfzk)n2k3m3iGbbpUq1dgwgw8N)wwn8blAbkwc4bKswkToyPGdSmwcbzz)wg4J2hQE4yyflPjZFJrVWWWI)wYZWlq4fCw2mwYr(Vv9GLvoelXt7hafQEWsya9gEl7XYfrxnKQmSIL0K5z)(IxGWl4mSIL0K5z)(c8bQdvpO8e6WnmastPnc0GzVi6Q9afLXhEA4ggaPP0bbAWWohPFYaLTQhGYxr8umvQSMk65aVFJlEbQYWkwstMN97lWhOou9GYtOd3FpAEylbsdeLXhEA4(5aVFlbsdK)WeZMWSXyA8WFzngwXsAY8SFFbJp0aVpKMm7LhI5bLBM7cOsZWCy8Hg49H0K5Ga9ON)YAmSIL0K5z)(Iv497yjnz2((fLNqhUFbcVGdkk3m3VaHxWbLdIOrdgwXsAY8SFFXk8(DSKMmBF)IYtOd3RYRCZCxjlLWdJC0Jxa0o(p(VNdmHQhkxVwiYrlqiIahPxy0JwvgwXsAY8SFFX77fSJPSl9cuUzUFoW73sG0a5pmXSjmBmMgp8xExj)WCe9ameKgCkXJRhT9Vi0tbb(QuOsZWCEFVGDmLDPxWbb6rp)LmTgozJa9ONxbcyqWJlu9GIfrxLS5i9ipR3SWWkwstMN97lwH3VJL0Kz77xuEcD4UqedRyjnzE2VVyfE)owstMTVFr5j0H7sJGLyyflPjZZ(9fbAfdSfccbJOCZCddG0u6uaME1cR3yZp2XhOou9WbgaPP0gbAWSxeD1EGIHvSKMmp73xeOvmWMJ2)GHvSKMmp73x4BnCYVXuLUOPdJyyflPjZZ(9fQH2MWSfuVW4nSmS4p)TetieFHu)8gwXsAY8Nv5Vz8Hg49H0KXWI)wwXzSmkL3YabwsZPSL)0CGLcoWsYawwFl4S0tQhEXs2yR6pwIP(blRhhmwwuQhnlzIxaKLcUySetQwllatVAXscYY6BbhHwSmgLSetQ2JHvSKMm)zvE2VVqpqyaLndbTlqi4uEP0YdBjqAG83yRCZCJIUSb8WiNOu(dnNIkLaPbYrADylKDPHlxeDvYMJ0J8NcW0RwQiSp8761frxLS5i9i)Pam9QfwVxCB9GV9ZbtPkdl(BzfNXYHyzukVL13EVLLgSS(wW1JLcoWYb4tSKf16v2s6hSS2zQEljJLQK)TS(wWrOflJrjlXKQ9yyflPjZFwLN97l0degqzZqq7cecoLBMBu0LnGhg5eLYF6HvwulmhfDzd4HrorP8NcnkKMmkweDvYMJ0J8NcW0Rwy9EXT1d(2phmfdl(BjMgMcisyPNO1RWB5ImLwAYe(3s14HILKXYfncbJy5ZbldRyjnz(ZQ8SFFb(a1HQhuEcD4gpmfqKypTgo5LWJbG2lYuAPjJY4dpnCZsj8WiNP1WjVeEma0bMq1dLRxzPeEyKdW3hJgDpHahycvpuUEDri(cP(5a89XOr3tiWbb6rp)L8dZRPIKWdJCkaWbO9lOqcnq)atO6HIHvSKMm)zvE2VVapmfqKq5M5MLVaHxWbLdIOrdkke5GO5eAeCKEHrpAkyzbuPzyo4HPaIehAof4duhQE4GhMcisSNwdN8s4Xaq7fzkT0KXWI)wwn89XOr3tiGL1JdglhIy5lq4fCqXYykwQseCwYZ0CcncSmMILyMaHicyzGalP5SKHGS0tgnlHHqRH7yyflPjZFwLN97la((y0O7jeq5M5MLVaHxWbLdIOrdkQKLfIC0ceIiWbbmi4XfQEqrHihenNqJGdc0JEEw5b78OIwCB9GV9Zbt561croiAoHgbheOh98vuTo8JvjqAGCKwh2czxAOkfsG0a5iToSfYU0aR8WWkwstM)Skp73x84A8k3m3fICq0CcncosVWOhTRxle58a33)r6fg9OzyflPjZFwLN97l4istgLBMBvAgMJQNqkE6xoiiwY1RmTgozJa9ON)swuRRxlGkndZbpmfqK4qZzyflPjZFwLN97lu9eszZqJus5M5UaQ0mmh8WuarIdnNHvSKMm)zvE2VVqfqpGWOhnLBM7cOsZWCWdtbejo0CgwXsAY8Nv5z)(cMgbQEcPOCZCxavAgMdEykGiXHMZWkwstM)Skp73xeZcEbf(9k8ELBM7cOsZWCWdtbejo0CgwXsAY8Nv5z)(Iv497yjnz2((fLNqhUXht)4uUzUz5lq4fCq5eEVc94faTJ)J)7zJa9ON)UwgwXsAY8Nv5z)(c6h2Ta6kdmmWs2tOd3A(O0Hqq)whkH33Kr5M5UaQ0mmh8WuarIdnNHvSKMm)zvE2VVG(HDlGUYaddSK9e6WTMpkDie0VvJIgOCZCxavAgMdEykGiXHMZWI)ww9atq7flzcVxnwyyjdbzj9hQEWYwa9VcSet9dwsglxeIVqQFogwXsAY8Nv5z)(c6h2Ta6VHLHf)5VLvFJGLyzj0dnWYqT9T0WByXFlRMbpmeDldXsEWULvYp2TS(wWzz1tvLLys1ESSIRRdLoeWRKLKXYAy3sjqAG8kBz9TGZsmnmfqKqzljilRVfCwYwDviAjrWbO67hSS(OflziilFIoyjmastPJL1M)jwwF0ILnJLvdFVMLlIUkXY(TCr07rZsAUJHvSKMm)P0iyj3WGhgIUYnZnWWalPXd7frxLS5i9ipR38GDj8WiNcaCaA)ckKqd0pWeQEOOOYcOsZWCWdtbejo0CxVwavAgMZJRXFO5UEfgaPP0Pam9QLlVRHFSJpqDO6HdmastPnc0GzVi6Q9aLRxzj(a1HQhoFpAEylbsdKQuujlLWdJCa((y0O7je4atO6HY1RlcXxi1phGVpgn6Ecboiqp65zTMQmSIL0K5pLgblH97lWhOou9GYtOd30pSzAVhqkJp80W9IORs2CKEK)uaME1cRyF9kmastPtby6vlxExd)yhFG6q1dhyaKMsBeObZEr0v7bkxVYs8bQdvpC(E08WwcKgigwXsAY8NsJGLW(9fpGqHaLTkzG9Z1yakVuA5HTeinq(BSvUzU1Jxa0o(p(VNnc0JE(7APOsvAgMZ77fSJPSl9co0CkyzHiNhqOqGYwLmW(5AmGDHihPxy0J21RmTgozJa9ON)YB(D96Iq8fs9Z5bekeOSvjdSFUgd4SWfin43mOyjnzcpR31C4P8761Nq7v7PC8qu2QkTb(cDopCGju9qrblvPzyoEikBvL2aFHoNho0CvzyXFlXSIXscJLvmtJhEldXsSXuy3YxIfgVLeglRy3LcmwwNpkWBjbzzOf98IL8GDlLaPbYFmSIL0K5pLgblH97lyIzty2ymnE4vUzUXhOou9WH(Hnt79asrLQ0mmhCDPaZw1hf4pVelmy9gBmLRxRKLCOMGArPnIiH0KrXZbE)wcKgi)HjMnHzJX04HN1BEW(lq4fCq5GiA0qvvzyXFlXSIXscJLvmtJhElfILbhNxjlREikELSSAj9tglBgl7jwsJhSKmwgJswkbsdeldXswyPeinq(JHvSKMm)P0iyjSFFbtmBcZgJPXdVYlLwEylbsdK)gBLBMB8bQdvpCOFyZ0EpGu8CG3VLaPbYFyIzty2ymnE4z9MfgwXsAY8NsJGLW(9fWchPhTnc4qTEmfLBMB8bQdvpCOFyZ0EpGuSieFHu)CWdtbejoiqp65zf7AzyflPjZFkncwc73xe6Q0poLBMB8bQdvpCOFyZ0EpGuuPE8cG2X)X)9SrGE0ZFxRRxvPzyoQ(EkFxGdnxvgw83s2cvmV2PL2hcyPqSm448kzz1drXRKLvlPFYyziwwJLsG0a5nSIL0K5pLgblH97l0PL2hcO8sPLh2sG0a5VXw5M5gFG6q1dh6h2mT3difph49BjqAG8hMy2eMngtJh(7AmSIL0K5pLgblH97l0PL2hcOCZCJpqDO6Hd9dBM27bKHLHf)5VLvFOhAGLe8aYsP1bld123sdVHf)TSc36TyjMjqiIaVLKXYHmyohQ1rbsjlLaPbYBjdbzPGdSKd1eulkzjIiH0KXYMXs(XULQEakVLbcSm8iikkzjnNHvSKMm)PqKB8bQdvpO8e6W9JrZTxkT8WwlqiIakJp80WnhQjOwuAJisinzu8CG3VLaPbYFyIzty2ymnE4zLfkQSqKJwGqeboiqp65VCri(cP(5OfierGtHgfstMRx5i9tgOSv9auEw5xvgw83YkCR3IL8mnNqJG3sYy5qgmNd16OaPKLsG0a5TKHGSuWbwYHAcQfLSerKqAYyzZyj)y3svpaL3YabwgEeefLSKMZWkwstM)uic73xGpqDO6bLNqhUFmAU9sPLh2iAoHgbkJp80WnhQjOwuAJisinzu8CG3VLaPbYFyIzty2ymnE4zLfkQSaQ0mmNhxJ)qZD9khPFYaLTQhGYZk)QYWI)wwHB9wSKNP5eAe8w2mwIPHPaIeStHRXFrThVailRT)J)7XY(TKMZYykwwpyjUapyznSB5dlYuEl9aJyjzSuWbwYZ0CcncSS6jSzyflPjZFkeH97lWhOou9GYtOd3pgn3grZj0iqz8HNgUlGkndZbpmfqK4qZPOYcOsZWCECn(dn31R6XlaAh)h)3Zgb6rppR1QkffICq0Ccncoiqp65zTgdl(BjfhS6WBjMjqiIawgtXsEMMtOrGLpi0CwYHAcYsHyz1W3hJgDpHawUIxmSIL0K5pfIW(9fAbcreq5M5wcpmYb47JrJUNqGdmHQhkkyjW3hJgDpHaLJwGqebuuiYrlqiIahoDAV0C(gqxEJTIfH4lK6NdW3hJgDpHaheOh98xwJINd8(Teinq(dtmBcZgJPXd)n2kqrx2aEyKtuk)Phw5jkke5OfierGdc0JE(kQwh(DPeinqosRdBHSlnyyflPjZFkeH97lq0CcncuUzULWdJCa((y0O7je4atO6HIIkbggyjnEyVi6QKnhPh5z9EXT1d(2phmfflcXxi1phGVpgn6Ecboiqp65VeBffICq0Ccncoiqp65ROAD43LsG0a5iToSfYU0qvgw83smtGqebSKMdda4u2YW)elfudVLcXs6hSSflJ3YWYNdwD4TudgafcbzjdbzPGdS0hVyjMuTwQcmeeyzyjtp9JdqgwXsAY8Ncry)(cocXVrWtOrlqzgcApaFYn2gwXsAY8Ncry)(cTaHicOCZCJage84cvpOyr0vjBospYFkatVAH1BSvujNoTxAoFdOlVX(6veOh98xEl9cJT06GINd8(Teinq(dtmBcZgJPXdpR3SOkfvYsGVpgn6EcbkxVIa9ON)YBPxySLwhQOAu8CG3VLaPbYFyIzty2ymnE4z9MfvPOsjqAGCKwh2czxAaZrGE0ZxfR8qHE8cG2X)X)9SrGE0ZFxldRyjnz(tHiSFFbhH43i4j0OfOmdbThGp5gBdRyjnz(tHiSFFHwGqebuEP0YdBjqAG83yRCZCZs8bQdvpCEmAU9sPLh2AbcreqbcyqWJlu9GIfrxLS5i9i)Pam9QfwVXwrLC60EP58nGU8g7RxrGE0ZF5T0lm2sRdkEoW73sG0a5pmXSjmBmMgp8SEZIQuujlb((y0O7jeOC9kc0JE(lVLEHXwADOIQrXZbE)wcKgi)HjMnHzJX04HN1BwuLIkLaPbYrADylKDPbmhb6rpFvSIDnk0Jxa0o(p(VNnc0JE(7AzyXFlXeuR)KXs2aDo4fljJL60EP58GLsG0a5Tmel5b7wIjvRL1Jdglr0Z0JMLeAXYESSM3YkP5SuiwYdlLaPbYxLLeKLS4TSs(XULsG0a5RYWkwstM)uic73xSqT(tMTa6CWlk3m3ph49BjqAG8SExJceOh98xwd7v(CG3VLaPbYZ6n)QsbWWalPXd7frxLS5i9ipR38WWI)wwXaaNL0CwYZ0CcncSmel5b7wsgldV3sjqAG8wwz94GXsFJVhnl9KrZsyi0A4SmMILdrS8NG7XrKQmSIL0K5pfIW(9fiAoHgbk3m3SeFG6q1dNhJMBJO5eAeOOsGHbwsJh2lIUkzZr6rEwV5HceWGGhxO6HRxzP0lm6rtrLsRdSIDTUEDr0vjBospYZ6DnvvLIk50P9sZ5BaD5n2xVIa9ON)YBPxySLwhu8CG3VLaPbYFyIzty2ymnE4z9MfvPOswc89XOr3tiq56veOh98xEl9cJT06qfvJINd8(Teinq(dtmBcZgJPXdpR3SOkfsG0a5iToSfYU0aMJa9ONNvEyyflPjZFkeH97lq0CcncuEP0YdBjqAG83yRCZCZs8bQdvpCEmAU9sPLh2iAoHgbkyj(a1HQhopgn3grZj0iqbWWalPXd7frxLS5i9ipR38qbcyqWJlu9GIk50P9sZ5BaD5n2xVIa9ON)YBPxySLwhu8CG3VLaPbYFyIzty2ymnE4z9MfvPOswc89XOr3tiq56veOh98xEl9cJT06qfvJINd8(Teinq(dtmBcZgJPXdpR3SOkfsG0a5iToSfYU0aMJa9ONNvEyyXFlXeuR)KXs2aDo4fljJLuSzzZyzpwYftb07LLXuSSflRV9Ellel9W)wwc9qdSuWfJLvZGhgIULfAWsHyjB1DrTxBgwXsAY8Ncry)(IfQ1FYSfqNdEr5M5(5aVFlbsdK)gBfaddSKgpSxeDvYMJ0J8SEx5IBRh8TFoykyo2vPabmi4XfQEqblb((y0O7jeOOGLfqLMH584A8hAof6XlaAh)h)3Zgb6rp)DTuibsdKJ06Wwi7sdyoc0JEEw5HHvSKMm)Pqe2VV4bUVFdldl(ZFlPei8coOyzTTKMmVHf)TK3wd3lHhdazjzSKfSvbwIjOw)jJLSb6CWlgwXsAY8NxGWl4GY9c16pz2cOZbVOCZClHhg5mTgo5LWJbGoWeQEOO45aVFlbsdKN1BwOyr0vjBospYZ6npuibsdKJ06Wwi7sdyoc0JEEw5jgw83sEBnCVeEmaKLKXsSzRcSKAcUhhrSKNP5eAeyyflPjZFEbcVGdkSFFbIMtOrGYnZTeEyKZ0A4Kxcpga6atO6HIIfrxLS5i9ipR38qHeinqosRdBHSlnG5iqp65zLNyyXFlPOvfaXqRbvGL1ghNxjljil5zGbbpolRVfCwQsZWaflXmbcre4nSIL0K5pVaHxWbf2VVGJq8Be8eA0cuMHG2dWNCJTHvSKMm)5fi8coOW(9fAbcreq5LslpSLaPbYFJTYnZTeEyKZtRkaIHwdoWeQEOOOseOh98xIDnxVYPt7LMZ3a6YBSRsHeinqosRdBHSlnG5iqp65zTgdl(BjfTQaigAnWs2TSA471SKmwInBvGL8mWGGhNLyMaHicyziwk4alHPyjHXYxGWl4SuiwQbIL6bFwwOrH0KXsvGHGalRg((y0O7jeWWkwstM)8ceEbhuy)(cocXVrWtOrlqzgcApaFYn2gwXsAY8NxGWl4Gc73xOfieraLBMBj8WiNNwvaedTgCGju9qrHeEyKdW3hJgDpHahycvpuuelPXdBya9g(BSvOsZWCEAvbqm0AWbb6rp)LyFyHHvSKMm)5fi8coOW(9f60s7dbuUzULWdJCEAvbqm0AWbMq1dfflIUkzZr6r(lVzHHLHf)5VLy6y6hNHf)TeZQN(Xzz9TGZs9GplXKQ1sgcYsEBnCYlHhdaPSL0Jh(3s6VhnlREieCELSKcxui1)gwXsAY8h8X0pUB8bQdvpO8e6W90A4KxcpgaAV42lYuAPjJY4dpnCxjlr0dWqqAWPaHGZR0(Xffs9VcGHbwsJh2lIUkzZr6rEwVxCB9GV9ZbtPQRxRerpadbPbNcecoVs7hxui1)kweDvYMJ0J8xwtvgw83smDm9JZY6BbNLvdFVMLSBjVTgo5LWJbGQalR9GVwNw3smPATmMILvdFVMLiikkzjdbz5a8jwIzWKQ3WkwstM)GpM(XX(9f4JPFCk3m3s4HroaFFmA09ecCGju9qrHeEyKZ0A4Kxcpga6atO6HIc8bQdvpCMwdN8s4Xaq7f3ErMslnzuSieFHu)Ca((y0O7je4Ga9ON)sSnS4VLy6y6hNL13col5T1WjVeEmaKLSBjVelRg(ETkWYAp4R1P1TetQwlJPyjMgMcisyjnNHvSKMm)bFm9JJ97lWht)4uUzULWdJCMwdN8s4XaqhycvpuuWsj8WihGVpgn6EcboWeQEOOaFG6q1dNP1WjVeEma0EXTxKP0stgffqLMH5GhMcisCO5mSIL0K5p4JPFCSFFbhH43i4j0OfOmdbThGp5gBLb(euSdDc9i38GFgwXsAY8h8X0po2VVaFm9Jt5M5wcpmY5PvfaXqRbhycvpuuSieFHu)C0ceIiWHMtrLfIC0ceIiWbbmi4XfQE461cOsZWCWdtbejo0Ckke5OfierGdNoTxAoFdOlVXUkflIUkzZr6r(tby6vlSEx5ZbE)wcKgi)HjMnHzJX04HN1ke4rvkqrx2aEyKtuk)PhwXUgdl(BjMoM(Xzz9TGZYApEbqwwB)hFpvGL8sS8fi8colJPy5qSmwsJhSS2RnlvPzyu2sEMMtOrGLdrSShlradcECwIIrdu2YcnQhnlX0Wuarc2zRodRyjnz(d(y6hh73xGpM(XPCZCxPeEyKJE8cG2X)X)9CGju9q56ve9ameKgC0degBcZwWbB94faTJ)J)7PkfSSqKdIMtOrWbbmi4XfQEqrHihTaHicCqGE0ZZkluuavAgMdEykGiXHMtrbuPzyopUg)HMZr9CWYXBn8dtXjoX5a]] )

end