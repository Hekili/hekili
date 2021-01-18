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
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
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

    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Assassination", 20210117, [[da1JwbqiOKEKOKUKkLiTjOQprrfJsu4uIIwfkP6vOsMfQu3ckr7sQ(LOsdJIQogu0Yev8muctdLKRrryBqj03GsW4OOs15eLiRtLs6DueLQ5PsX9uj7dk1)uPeLdIskwOOupKIitKIk5IOKsBKIkLpkkbJKIOuoPkLIvcfEjfrjZuLs4MIsODIkmukIQLQsP6Pi1urfDvvkr1wfLO(kfrHXQsP0Ej1FLYGvCyQwmQ6XQyYICzWMrYNPWOrPoTKvRsjIxRs1SP0TjPDR0VrmCsCCkIIwoKNRQPtCDuSDOY3rjA8uKopfL5lQA)cRXuZPMo5cO5ihZNdMMhtmXcDZNLyfwGfyrnTyMcOPv8ZD3a00RRcAAwZ)()16srwnTIBML4jnNA6NWGoGMMTik)TMBUgLWMHVFiQ5(LkJ1LIShKtj5(L6jxnnptzLBZQ510jxanh5y(CW08yIjwOB(SeRWcSGvAANrytqAA6s1K00SRucwnVMob)rtN1yyn)7)xRlfzJ52jgmqGrwJbdFzCKzXGjwG7yYX85GzGrGrwJjlsWbPym3SUbyTUuKnMmmjl47dzgdJsm1gJcQiOsmlMNetjXWscJnfZsKymajgEgubPy4b21MI5fWTc7y8JuK97AAB9YR5ut)c4wHnK0CQ5atnNAAyDElK0zRPpOsau5AAXTWk9TmylV427aQdRZBHum4J5vaRTjoYaKpgSVIHfXGpMdrLN0ui1kFmyFfdRIbFmIJmaPlLk0eslvqmyzmiq1R9Jb7yWIAA)ifz10huP(KTjGQc8Iw0CKJMtnnSoVfs6S10hujaQCnT4wyL(wgSLxC7Da1H15Tqkg8XCiQ8KMcPw5Jb7Ryyvm4JrCKbiDPuHMqAPcIblJbbQETFmyhdwut7hPiRMgXOimiqlAoyHMtnnSoVfs6S10ueuBbtfnhyQP9JuKvtRqi2gcEcd6aArZbR0CQPH15TqsNTM2psrwnTHJqeb00hujaQCnT4wyL(ZWlaIIXa6W68wifd(yYigeO61(XCtmyMtm5ZhJIkJvkfBbOyU5kgmJjZyWhJ4idq6sPcnH0sfedwgdcu9A)yWoMC00hZowOjoYaKxZbMArZHj0CQPH15TqsNTMMIGAlyQO5atnTFKISAAfcX2qWtyqhqlAoWIAo10W68wiPZwtFqLaOY10IBHv6pdVaikgdOdRZBHum4JrClSshm991GPwxGoSoVfsXGpg)ifoOblOwWhZvmygd(y4zOO6pdVaikgdOJavV2pMBIbZol00(rkYQPnCeIiGw0CGf0CQPH15TqsNTM(GkbqLRPf3cR0FgEbqumgqhwN3cPyWhZHOYtAkKALpMBUIHfAA)ifz10QmszDb0Iw0048TE2Ao1CGPMtnnSoVfs6S10efn9dIM2psrwnnohvoVf004CldOPZigSgdIzbkcYa6jWf2wZApBpry53H15Tqkg8XauuWrkCq7qu5jnfsTYhd2xXCuAQUPTxb2umzgt(8XKrmiMfOiidONaxyBnR9S9eHLFhwN3cPyWhZHOYtAkKALpMBIjNyYutJZrT1vbn9wgSLxC7Da1okTdztLuKvlAoYrZPMgwN3cjD2A6dQeavUMwClSshm991GPwxGoSoVfsXGpgXTWk9TmylV427aQdRZBHum4JbNJkN3c9TmylV427aQDuAhYMkPiBm4J5qi2eHLBhm991GPwxGocu9A)yUjgm10(rkYQPX5B9S1IMdwO5utdRZBHKoBn9bvcGkxtlUfwPVLbB5f3EhqDyDElKIbFmyngXTWkDW03xdMADb6W68wifd(yW5OY5TqFld2YlU9oGAhL2HSPskYgd(ysapdfvhhSjqeVZOOP9JuKvtJZ36zRfnhSsZPMgwN3cjD2AA)ifz10keITHGNWGoGMgmvqEZvjmROPzLj00ueuBbtfnhyQfnhMqZPMgwN3cjD2A6dQeavUMwClSs)z4farXyaDyDElKIbFmhcXMiSC7gocreOZOed(yYiMer6gocreOJake8SDElet(8XKaEgkQooytGiENrjg8XKis3WriIaDfvgRuk2cqXCZvmygtMXGpMdrLN0ui1kFpbu1PKyW(kMmI5vaRTjoYaKVt5BJq1UVfo4Jb7BzXWQyYmg8XG8k1aCWkDpL(ETXGDmyMJM2psrwnnoFRNTw0CGf1CQPH15TqsNTM(GkbqLRPZigXTWkDv)fa18)9)RTdRZBHum5ZhdIzbkcYa6Qo6EJq1e2qt1Fbqn)F))A7W68wiftMXGpgSgtIiDeJIWGGocOqWZ25Tqm4JjrKUHJqeb6iq1R9Jb7yyrm4Jjb8muuDCWMar8oJsm4Jjb8muu9NDHRZOOP9JuKvtJZ36zRfTOPtaLZyfnNAoWuZPM2psrwn996CxtdRZBHKoBTO5ihnNAA)ifz10VaUvyRPH15TqsNTw0CWcnNAAyDElK0zRPjkA6henTFKISAACoQCElOPX5wgqtdlGmmRJadyJHRyui1twi14TaK(yy9yWcXKBmzetoXW6X8kG12y7VaXKPMgNJARRcAAybKHzneyaB7qu5RfsArZbR0CQPH15TqsNTMMOOPFq00(rkYQPX5OY5TGMgNBzan9RawBtCKbiFNY3gHQDFlCWhZnXKJMgNJARRcA6Vwdl0ehzaIw0CycnNAAyDElK0zRPpOsau5A6eWZqr1PSUbyTUuKTJavV2pMBIjhnTFKISAAkRBawRlfzBhl47dArZbwuZPMgwN3cjD2A6dQeavUM(fWTcBi1redgqt7hPiRM(4wBZpsr2MTErtBRxARRcA6xa3kSHKw0CGf0CQPH15TqsNTM(GkbqLRPZigSgJ4wyLUQ)cGA()()12H15TqkM85JjrKUHJqeb6sDUxRrmzQP9JuKvtFCRT5hPiBZwVOPT1lT1vbn9j9ArZH5UMtnnSoVfs6S10hujaQCn9RawBtCKbiFNY3gHQDFlCWhZnxXKrmMigSmgeZcueKb0t(ZUwJ2FimBcb2oSoVfsXKzm4JHNHIQ)26anFtTuDGocu9A)yUjgQYGT0qGQx7hd(yqafcE2oVfIbFmhIkpPPqQv(yW(kgwOP9JuKvt)26anFtTuDaTO5ilP5utdRZBHKoBnTFKISA6JBTn)ifzB26fnTTEPTUkOPterlAoW08Ao10W68wiPZwt7hPiRM(4wBZpsr2MTErtBRxARRcA6uHGJOfnhyIPMtnnSoVfs6S10hujaQCnnSaYWSEcOQtjXG9vmyAIy4kgCoQCEl0HfqgM1qGbSTdrLVwiPP9JuKvt7OJVqtiieSIw0CGzoAo10(rkYQPD0XxOPWyFqtdRZBHKoBTO5atwO5ut7hPiRM2wgSLVDlHjzOcROPH15TqsNTw0CGjR0CQP9JuKvtZ7gncvtq15(RPH15TqsNTw0IMwbbhIkVlAo1CGPMtnTFKISAAxrXAwtHupz10W68wiPZwlAoYrZPM2psrwnnprelKAuw3miXYAnAcX0A10W68wiPZwlAoyHMtnnSoVfs6S10(rkYQPvD0Di1OiOwcCHTM(GkbqLRPrELAaoyLUNsFV2yWogmnHMwbbhIkVlThoKn9AAtOfnhSsZPM2psrwn9lGBf2AAyDElK0zRfnhMqZPMgwN3cjD2AA)ifz10VToqZ3ulvhqtFqLaOY10iGcbpBN3cAAfeCiQ8U0E4q20RPXulArtNkeCenNAoWuZPMgwN3cjD2A6dQeavUMgOOGJu4G2HOYtAkKALpgSVIHvXWvmIBHv6jauau7fKlUbO2H15Tqkg8XKrmjGNHIQJd2eiI3zuIjF(ysapdfv)zx46mkXKpFmWcidZ6jGQoLeZnxXKJjIHRyW5OY5TqhwazywdbgW2oev(AHum5ZhdwJbNJkN3c9Vwdl0ehzasmzgd(yYigSgJ4wyLoy67RbtTUaDyDElKIjF(yoeInry52btFFnyQ1fOJavV2pgSJjNyYut7hPiRMgwCWsu1IMJC0CQPH15TqsNTMMOOPFq00(rkYQPX5OY5TGMgNBzan9HOYtAkKALVNaQ6usmyhdMXKpFmWcidZ6jGQoLeZnxXKJjIHRyW5OY5TqhwazywdbgW2oev(AHum5ZhdwJbNJkN3c9Vwdl0ehzaIMgNJARRcAAMhAuL1ciTO5GfAo10W68wiPZwt7hPiRM(beYfi14jl0EL6oOPpOsau5AAEgkQ(BRd08n1s1b6mkXGpgSgtIi9hqixGuJNSq7vQ7qlrKUuN71Aet(8XqvgSLgcu9A)yU5kgtet(8XCieBIWYT)ac5cKA8KfAVsDh6h2oYa(gfYpsrw3gd2xXKthlyIyYNpMNWy5Rn1TGNA8M1atDvfl0H15Tqkg8XG1y4zOO6wWtnEZAGPUQIf6mkA6Jzhl0ehzaYR5atTO5GvAo10W68wiPZwtFqLaOY104Cu58wOZ8qJQSwafd(yYigEgkQo7kLGTXB9e89x8Z9yW(kgmZsXKpFmzedwJrbveujM1qeXLISXGpMxbS2M4idq(oLVncv7(w4GpgSVIHvXWvmVaUvydPoIyWaXKzmzQP9JuKvtt5BJq1UVfo41IMdtO5utdRZBHKoBnTFKISAAkFBeQ29TWbVM(GkbqLRPX5OY5TqN5HgvzTakg8X8kG12ehzaY3P8TrOA33ch8XG9vmSqtFm7yHM4idqEnhyQfnhyrnNAAyDElK0zRPpOsau5AACoQCEl0zEOrvwlGIbFmhcXMiSC74GnbI4DeO61(XGDmyAEnTFKISAA4WMuRrdbkOs13Kw0CGf0CQPH15TqsNTM(GkbqLRPX5OY5TqN5HgvzTakg8XKrmQ(laQ5)7)xBdbQETFmxXy(yYNpgEgkQoVT20xjOZOetMAA)ifz10UkpZZwlAom31CQPH15TqsNTM2psrwnTkJuwxan9bvcGkxtJZrLZBHoZdnQYAbum4J5vaRTjoYaKVt5BJq1UVfo4J5kMC00hZowOjoYaKxZbMArZrwsZPMgwN3cjD2A6dQeavUMgNJkN3cDMhAuL1cinTFKISAAvgPSUaArlA6t61CQ5atnNAA)ifz10uw3aSwxkYQPH15TqsNTw0CKJMtnnSoVfs6S10(rkYQPvD0Di1OiOwcCHTM(GkbqLRPrELAaoyLUNsFNrjg8XKrmIJmaPlLk0eslvqm3eZHOYtAkKALVNaQ6usmSEmy2nrm5ZhZHOYtAkKALVNaQ6usmyFfZrPP6M2EfytXKPM(y2XcnXrgG8AoWulAoyHMtnnSoVfs6S10hujaQCnnYRudWbR09u671gd2XWcZhdwgdYRudWbR09u67jgKlfzJbFmhIkpPPqQv(EcOQtjXG9vmhLMQBA7vGnPP9JuKvtR6O7qQrrqTe4cBTO5GvAo10W68wiPZwttu00piAA)ifz104Cu58wqtJZTmGMgRXiUfwPVLbB5f3EhqDyDElKIjF(yWAmIBHv6GPVVgm16c0H15TqkM85J5qi2eHLBhm991GPwxGocu9A)yUjgtedwgtoXW6XiUfwPNaqbqTxqU4gGAhwN3cjnnoh1wxf004GnbI4TTmylV427aQDiBQKISArZHj0CQPH15TqsNTM(GkbqLRPXAmVaUvydPoIyWaXGpMer6igfHbbDPo3R1ig8XG1ysapdfvhhSjqeVZOed(yW5OY5TqhhSjqeVTLbB5f3EhqTdztLuKvt7hPiRMghSjqexlAoWIAo10W68wiPZwtFqLaOY10ynMxa3kSHuhrmyGyWhtgXG1ysePB4ierGocOqWZ25Tqm4JjrKoIrryqqhbQETFmyhdRIHRyyvmSEmhLMQBA7vGnft(8XKishXOimiOJavV2pgwpgZ3nrmyhJ4idq6sPcnH0sfetMXGpgXrgG0LsfAcPLkigSJHvAA)ifz10GPVVgm16cOfnhybnNAAyDElK0zRPpOsau5A6er6igfHbbDPo3R1iM85JjrK(dkF9DPo3R1qt7hPiRM(zx40IMdZDnNAAyDElK0zRPpOsau5AAEgkQoVLqswMx6iWpsm5ZhdvzWwAiq1R9J5MyyH5JjF(ysapdfvhhSjqeVZOOP9JuKvtRqKISArZrwsZPMgwN3cjD2A6dQeavUMob8muuDCWMar8oJIM2psrwnnVLqsnkgKzArZbMMxZPMgwN3cjD2A6dQeavUMob8muuDCWMar8oJIM2psrwnnpGEaDVwdTO5atm1CQPH15TqsNTM(GkbqLRPtapdfvhhSjqeVZOOP9JuKvttviG3sijTO5aZC0CQPH15TqsNTM(GkbqLRPtapdfvhhSjqeVZOOP9JuKvt77bEb522XTwTO5atwO5utdRZBHKoBn9bvcGkxtJ1yEbCRWgsD3AJbFmQ(laQ5)7)xBdbQETFmxXyEnTFKISA6JBTn)ifzB26fnTTEPTUkOPX5B9S1IMdmzLMtnnSoVfs6S10(rkYQPnSEQCHG(MkKCRTiRM(GkbqLRPtapdfvhhSjqeVZOOPbkk4iT1vbnTH1tLle03uHKBTfz1IMdmnHMtnnSoVfs6S10(rkYQPnSEQCHG(gVNman9bvcGkxtNaEgkQooytGiENrrtduuWrARRcAAdRNkxiOVX7jdqlAoWelQ5ut7hPiRMM5HwjG6RPH15TqsNTw0IMorenNAoWuZPMgwN3cjD2AAIIM(brt7hPiRMgNJkN3cAACULb00kOIGkXSgIiUuKng8X8kG12ehzaY3P8TrOA33ch8XGDmSig8XKrmjI0nCeIiqhbQETFm3eZHqSjcl3UHJqeb6jgKlfzJjF(yui1twi14TaK(yWogtetMAACoQTUkOP)7Ls7y2XcndhHicOfnh5O5utdRZBHKoBnnrrt)GOP9JuKvtJZrLZBbnno3YaAAfurqLywdrexkYgd(yEfWABIJma57u(2iuT7BHd(yWogwed(yYiMeWZqr1F2fUoJsm5ZhJcPEYcPgVfG0hd2XyIyYutJZrT1vbn9FVuAhZowOHyuegeOfnhSqZPMgwN3cjD2AAIIM(brt7hPiRMgNJkN3cAACULb00jGNHIQJd2eiI3zuIbFmzetc4zOO6p7cxNrjM85Jr1Fbqn)F))ABiq1R9Jb7ymFmzgd(ysePJyuege0rGQx7hd2XKJMgNJARRcA6)EP0qmkcdc0IMdwP5utdRZBHKoBn9bvcGkxtlUfwPdM((AWuRlqhwN3cPyWhdwJjb8muuDdhHic0btFFnyQ1fifd(ysePB4ierGUIkJvkfBbOyU5kgmJbFmhcXMiSC7GPVVgm16c0rGQx7hZnXKtm4J5vaRTjoYaKVt5BJq1UVfo4J5kgmJbFmiVsnahSs3tPVxBmyhdwmg8XKis3WriIaDeO61(XW6Xy(UjI5MyehzasxkvOjKwQanTFKISAAdhHicOfnhMqZPMgwN3cjD2A6dQeavUMwClSshm991GPwxGoSoVfsXGpMmIbOOGJu4G2HOYtAkKALpgSVI5O0uDtBVcSPyWhZHqSjcl3oy67RbtTUaDeO61(XCtmygd(ysePJyuege0rGQx7hdRhJ57MiMBIrCKbiDPuHMqAPcIjtnTFKISAAeJIWGaTO5alQ5utdRZBHKoBnnfb1wWurZbMAA)ifz10keITHGNWGoGw0CGf0CQPH15TqsNTM(GkbqLRPrafcE2oVfIbFmhIkpPPqQv(EcOQtjXG9vmygd(yYigfvgRuk2cqXCZvmygt(8XGavV2pMBUIrQZ9MuQqm4J5vaRTjoYaKVt5BJq1UVfo4Jb7Ryyrmzgd(yYigSgdy67RbtTUaPyYNpgeO61(XCZvmsDU3KsfIH1JjNyWhZRawBtCKbiFNY3gHQDFlCWhd2xXWIyYmg8XKrmIJmaPlLk0eslvqmyzmiq1R9JjZyWogwfd(yu9xauZ)3)V2gcu9A)yUIX8AA)ifz10gocreqlAom31CQPH15TqsNTMMIGAlyQO5atnTFKISAAfcX2qWtyqhqlAoYsAo10W68wiPZwt7hPiRM2WriIaA6dQeavUMgRXGZrLZBH(FVuAhZowOz4ierGyWhdcOqWZ25Tqm4J5qu5jnfsTY3tavDkjgSVIbZyWhtgXOOYyLsXwakMBUIbZyYNpgeO61(XCZvmsDU3KsfIbFmVcyTnXrgG8DkFBeQ29TWbFmyFfdlIjZyWhtgXG1yatFFnyQ1fift(8XGavV2pMBUIrQZ9MuQqmSEm5ed(yEfWABIJma57u(2iuT7BHd(yW(kgwetMXGpMmIrCKbiDPuHMqAPcIblJbbQETFmzgd2XGzoXGpgv)fa18)9)RTHavV2pMRymVM(y2XcnXrgG8AoWulAoW08Ao10W68wiPZwtFqLaOY10VcyTnXrgG8XG9vm5ed(yqGQx7hZnXKtmCftgX8kG12ehzaYhd2xXyIyYmg8XauuWrkCq7qu5jnfsTYhd2xXWknTFKISA6dQuFY2eqvbErlAoWetnNAAyDElK0zRPpOsau5AASgdohvoVf6)9sPHyuegeed(yYigGIcosHdAhIkpPPqQv(yW(kgwfd(yqafcE2oVfIjF(yWAmsDUxRrm4JjJyKsfIb7yW08XKpFmhIkpPPqQv(yW(kMCIjZyYmg8XKrmkQmwPuSfGI5MRyWmM85JbbQETFm3CfJuN7nPuHyWhZRawBtCKbiFNY3gHQDFlCWhd2xXWIyYmg8XKrmyngW03xdMADbsXKpFmiq1R9J5MRyK6CVjLkedRhtoXGpMxbS2M4idq(oLVncv7(w4GpgSVIHfXKzm4JrCKbiDPuHMqAPcIblJbbQETFmyhdR00(rkYQPrmkcdc0IMdmZrZPMgwN3cjD2AA)ifz10igfHbbA6dQeavUMgRXGZrLZBH(FVuAhZowOHyuegeed(yWAm4Cu58wO)3lLgIrryqqm4JbOOGJu4G2HOYtAkKALpgSVIHvXGpgeqHGNTZBHyWhtgXOOYyLsXwakMBUIbZyYNpgeO61(XCZvmsDU3KsfIbFmVcyTnXrgG8DkFBeQ29TWbFmyFfdlIjZyWhtgXG1yatFFnyQ1fift(8XGavV2pMBUIrQZ9MuQqmSEm5ed(yEfWABIJma57u(2iuT7BHd(yW(kgwetMXGpgXrgG0LsfAcPLkigSmgeO61(XGDmSstFm7yHM4idqEnhyQfnhyYcnNAAyDElK0zRPpOsau5A6xbS2M4idq(yUIbZyWhdqrbhPWbTdrLN0ui1kFmyFftgXCuAQUPTxb2umyzmygtMXGpgeqHGNTZBHyWhdwJbm991GPwxGum4JbRXKaEgkQ(ZUW1zuIbFmQ(laQ5)7)xBdbQETFmxXy(yWhJ4idq6sPcnH0sfedwgdcu9A)yWogwPP9JuKvtFqL6t2MaQkWlArZbMSsZPM2psrwn9dkF9AAyDElK0zRfTOfnnoa9fz1CKJ5ZX8yMtoyrnnlD0wRXRPnzWAUDoUnCKfU1yIHt2qmLQcbjXqrqXyo48TE2MtmiWKjtHGumprfIXzeIQlqkMdBFnGVhyClQfIbZBngtIS4aKaPymheZcueKb0VTMtmcjgZbXSafbza9BBhwN3cjZjMmYX0m7bg3IAHyWI3AmMezXbibsXyoiMfOiidOFBnNyesmMdIzbkcYa632oSoVfsMtmzGPPz2dmcmmzWAUDoUnCKfU1yIHt2qmLQcbjXqrqXyojGYzSI5edcmzYuiifZtuHyCgHO6cKI5W2xd47bg3IAHyyXTgJjrwCasGum0LQjfZB2kUPXClngHeZTGXJjv4QViBmefa5cbftg5MzmzGPPz2dmUf1cXyUFRXysKfhGeifJ5GywGIGmG(T1CIriXyoiMfOiidOFB7W68wizoXKbMMMzpWiWWKbR52542Wrw4wJjgozdXuQkeKedfbfJ5KiI5edcmzYuiifZtuHyCgHO6cKI5W2xd47bg3IAHyy1TgJjrwCasGumMdy67RbtTUaP(T1CIriXyojGNHIQFB7GPVVgm16cKmNyYattZShyeyCBuviibsXGfIXpsr2yS1lFpWqtRGiuLf00zngwZ)()16sr2yUDIbdeyK1yWWxghzwmyIf4oMCmFoygyeyK1yYIeCqkgZnRBawRlfzJjdtYc((qMXWOetTXOGkcQeZI5jXusmSKWytXSejgdqIHNbvqkgEGDTPyEbCRWog)ifz)EGrGrwJH1AkCyeifdpqrqqmhIkVlXWdg1(9yynNdOiFmlzXs2osLIXgJFKISFmK1AwpWWpsr2VRGGdrL3LlxrXAwtHupzdm8JuK97ki4qu5DHRRC5jIyHuJY6MbjwwRrtiMwBGHFKISFxbbhIkVlCDLRQJUdPgfb1sGlS5wbbhIkVlThoKn9xMG7I6c5vQb4Gv6Ek99AXgttey4hPi73vqWHOY7cxx5(c4wHDGHFKISFxbbhIkVlCDL7BRd08n1s1b4wbbhIkVlThoKn9xyYDrDHake8SDEleyeyK1yyTMchgbsXa4aKzXiLkeJWgIXpcbft9X448Y68wOhy4hPi7FDVo3dmYAm3o8c4wHDmfvmkK)lEletgljgCm2fqoVfIbwqTGpMAJ5qu5DjZad)ifzFUUY9fWTc7ad)ifzFUUYfNJkN3cCVUkCblGmmRHadyBhIkFTqIBCULbUGfqgM1rGbSCPqQNSqQXBbi9Sow4wAg5W6VcyTn2(lqMbg(rkY(CDLlohvoVf4EDv46R1WcnXrgGWno3YaxVcyTnXrgG8DkFBeQ29TWb)n5ey4hPi7Z1vUuw3aSwxkY2owW3h4UOUsapdfvNY6gG16sr2ocu9A)BYjWWpsr2NRRCpU128JuKTzRx4EDv46fWTcBiXDrD9c4wHnK6iIbdey4hPi7Z1vUh3AB(rkY2S1lCVUkCDsp3f1vgyvClSsx1Fbqn)F))A7W68wiLpFIiDdhHic0L6CVwJmdm8JuK956k33whO5BQLQdWDrD9kG12ehzaY3P8TrOA33ch83CLHjWseZcueKb0t(ZUwJ2FimBcb2mXZZqr1FBDGMVPwQoqhbQET)nuLbBPHavV2hpcOqWZ25Ta(drLN0ui1kp2xSiWWpsr2NRRCpU128JuKTzRx4EDv4krKad)ifzFUUY94wBZpsr2MTEH71vHRuHGJey4hPi7Z1vUo64l0eccbRWDrDblGmmRNaQ6uc2xyAcUW5OY5TqhwazywdbgW2oev(AHuGHFKISpxx56OJVqtHX(qGHFKISpxx5Ald2Y3ULWKmuHvcm8JuK956kxE3OrOAcQo3)aJaJSgJjri2eHL7hy4hPi73pP)IY6gG16sr2aJSgZTHkgpL(yCeedJc3X8BPaXiSHyiledllHDmwclHxIHtonx9yUL)qmSKnSXKmRwJyO8xaumcBFJXKm5XKaQ6usmeumSSe2egjgFnlgtYK3dm8JuK97N0Z1vUQo6oKAueulbUWM7Jzhl0ehzaYFHj3f1fYRudWbR09u67mk4ZqCKbiDPuHMqAPcU5qu5jnfsTY3tavDkH1XSBI85pevEstHuR89eqvNsW(6O0uDtBVcSPmdmYAm3gQywsmEk9XWYYAJjvqmSSe21gJWgIzbtLyyH5FUJH5HyYIuMRyiBm8K)JHLLWMWiX4RzXysM8EGHFKISF)KEUUYv1r3HuJIGAjWf2CxuxiVsnahSs3tPVxl2SW8yjYRudWbR09u67jgKlfzXFiQ8KMcPw57jGQoLG91rPP6M2EfytbgznMSmSjqepglXOoUnMdztLuK1TFm8(dPyiBmhgecwjMxbobg(rkY(9t656kxCoQCElW96QWfoytGiEBld2YlU9oGAhYMkPil34CldCHvXTWk9TmylV427aQdRZBHu(8yvClSshm991GPwxGoSoVfs5ZFieBIWYTdM((AWuRlqhbQET)nMalZH1f3cR0taOaO2lixCdqTdRZBHuGHFKISF)KEUUYfhSjqeN7I6cRVaUvydPoIyWa4tePJyuege0L6CVwd8ynb8muuDCWMar8oJcECoQCEl0XbBceXBBzWwEXT3bu7q2ujfzdmYAmSwtFFnyQ1figwYg2ywIeZlGBf2qkgFtXWte2XC7mkcdcIX3umzbhHiceJJGyyuIHIGIXswJyGLWyWUhy4hPi73pPNRRCbtFFnyQ1fG7I6cRVaUvydPoIyWa4ZaRjI0nCeIiqhbui4z78waFIiDeJIWGGocu9AFSzfxSI1pknv302RaBkF(er6igfHbbDeO61(SU57MaBXrgG0LsfAcPLkit8IJmaPlLk0eslva2SkWWpsr2VFspxx5(SlCCxuxjI0rmkcdc6sDUxRr(8jI0Fq5RVl15ETgbg(rkY(9t656kxfIuKL7I6INHIQZBjKKL5Loc8JKppvzWwAiq1R9VHfMpF(eWZqr1XbBceX7mkbg(rkY(9t656kxElHKAumiZ4UOUsapdfvhhSjqeVZOey4hPi73pPNRRC5b0dO71AWDrDLaEgkQooytGiENrjWWpsr2VFspxx5sviG3sijUlQReWZqr1XbBceX7mkbg(rkY(9t656kxFpWli32oU1YDrDLaEgkQooytGiENrjWWpsr2VFspxx5ECRT5hPiBZwVW96QWfoFRNn3f1fwFbCRWgsD3AXR6VaOM)V)FTneO61(xMpWWpsr2VFspxx5Y8qReqLBGIcosBDv4YW6PYfc6BQqYT2ISCxuxjGNHIQJd2eiI3zucm8JuK97N0Z1vUmp0kbu5gOOGJ0wxfUmSEQCHG(gVNmaUlQReWZqr1XbBceX7mkbgzngZfq5mwjgk3A59Z9yOiOyyEN3cXucO(3Am3YFigYgZHqSjcl3EGHFKISF)KEUUYL5HwjG6hyeyK1ymxfcosmjx1nGyC(YwsbFGrwJH1U4GLOgJlXWkUIjdtWvmSSe2XyUOZmgtYK3J52OQcPYfWAwmKnMC4kgXrgG8ChdllHDmzzytGio3XqqXWYsyhdNzBYEmeHnGyz9qmS0ljgkckMNOcXalGmmRhdRX(KyyPxsmfvmSwtFJyoevEsm1hZHOwRrmmk9ad)ifz)EQqWrUGfhSevUlQlGIcosHdAhIkpPPqQvESVyfxIBHv6jauau7fKlUbO2H15TqcFgjGNHIQJd2eiI3zuYNpb8muu9NDHRZOKppSaYWSEcOQtj3CLJj4cNJkN3cDybKHzneyaB7qu5Rfs5ZJvCoQCEl0)AnSqtCKbizIpdSkUfwPdM((AWuRlqhwN3cP85peInry52btFFnyQ1fOJavV2h7CYmWWpsr2VNkeCeUUYfNJkN3cCVUkCX8qJQSwaXno3YaxhIkpPPqQv(EcOQtjyJz(8WcidZ6jGQoLCZvoMGlCoQCEl0HfqgM1qGbSTdrLVwiLppwX5OY5Tq)R1WcnXrgGey4hPi73tfcocxx5(ac5cKA8KfAVsDh4(y2XcnXrgG8xyYDrDXZqr1FBDGMVPwQoqNrbpwteP)ac5cKA8KfAVsDhAjI0L6CVwJ85Pkd2sdbQET)nxMiF(dHytewU9hqixGuJNSq7vQ7q)W2rgW3Oq(rkY6wSVYPJfmr(8pHXYxBQBbp14nRbM6QkwOdRZBHeESYZqr1TGNA8M1atDvfl0zucmYAmMB(gdHkgtwBHd(yCjgmZsCfZl(5(hdHkgt2Quc2yY26j4JHGIXn8AFjgwXvmIJma57bg(rkY(9uHGJW1vUu(2iuT7BHdEUlQlCoQCEl0zEOrvwlGWNbpdfvNDLsW24TEc((l(5o2xyMLYNpdSQGkcQeZAiI4srw8VcyTnXrgG8DkFBeQ29TWbp2xSIRxa3kSHuhrmyGmZmWiRXyU5BmeQymzTfo4JriX4kkwZIXCbEYAwmMCs9KnMIkMA9Ju4GyiBm(AwmIJmajgxIHfXioYaKVhy4hPi73tfcocxx5s5BJq1UVfo45(y2XcnXrgG8xyYDrDHZrLZBHoZdnQYAbe(xbS2M4idq(oLVncv7(w4Gh7lwey4hPi73tfcocxx5ch2KAnAiqbvQ(M4UOUW5OY5TqN5HgvzTac)HqSjcl3ooytGiEhbQETp2yA(ad)ifz)EQqWr46kxxLN5zZDrDHZrLZBHoZdnQYAbe(mu9xauZ)3)V2gcu9A)lZNpppdfvN3wB6Re0zuYmWiRXWPZJLzrgPSUaXiKyCffRzXyUapznlgtoPEYgJlXKtmIJma5dm8JuK97PcbhHRRCvzKY6cW9XSJfAIJma5VWK7I6cNJkN3cDMhAuL1ci8VcyTnXrgG8DkFBeQ29TWb)vobg(rkY(9uHGJW1vUQmszDb4UOUW5OY5TqN5HgvzTakWiWiRXyUCv3aIHGdqXiLkeJZx2sk4dmYAm3IsTKyYcocre4JHSXSKflvqLkYrMfJ4idq(yOiOye2qmkOIGkXSyqeXLISXuuXycUIH3cq6JXrqmUfbEYSyyucm8JuK97jICHZrLZBbUxxfU(7Ls7y2XcndhHicWno3YaxkOIGkXSgIiUuKf)RawBtCKbiFNY3gHQDFlCWJnlWNrIiDdhHic0rGQx7FZHqSjcl3UHJqeb6jgKlfzZNxHupzHuJ3cq6X2ezgyK1yUfLAjXC7mkcdc(yiBmlzXsfuPICKzXioYaKpgkckgHneJcQiOsmlgerCPiBmfvmMGRy4TaK(yCeeJBrGNmlggLad)ifz)EIiCDLlohvoVf4EDv46VxkTJzhl0qmkcdc4gNBzGlfurqLywdrexkYI)vaRTjoYaKVt5BJq1UVfo4XMf4Zib8muu9NDHRZOKpVcPEYcPgVfG0JTjYmWiRXClk1sI52zuege8XuuXKLHnbI4CrZUWLBw0FbqXWA(3)V2yQpggLy8nfdlHyy74GyYHRyE4q20hJfOKyiBmcBiMBNrryqqmMlcNbg(rkY(9er46kxCoQCElW96QW1FVuAigfHbbCJZTmWvc4zOO64GnbI4Dgf8zKaEgkQ(ZUW1zuYNx1Fbqn)F))ABiq1R9X28zIprKoIrryqqhbQETp25eyK1yOvGt52yYcocreigFtXC7mkcdcI5bHrjgfurqXiKyyTM((AWuRlqmh)Lad)ifz)EIiCDLRHJqeb4UOUe3cR0btFFnyQ1fOdRZBHeEScM((AWuRlqQB4iera8jI0nCeIiqxrLXkLITa0nxyI)qi2eHLBhm991GPwxGocu9A)BYb)RawBtCKbiFNY3gHQDFlCWFHjEKxPgGdwP7P03RfBSi(er6gocreOJavV2N1nF3e3ioYaKUuQqtiTubbg(rkY(9er46kxeJIWGaUlQlXTWkDW03xdMADb6W68wiHpdGIcosHdAhIkpPPqQvESVoknv302RaBc)HqSjcl3oy67RbtTUaDeO61(3Gj(er6igfHbbDeO61(SU57M4gXrgG0LsfAcPLkiZaJSgtwWriIaXWOChafUJXTpjgbvWhJqIH5Hykjg)JXJ5vGt52ymGfqUqqXqrqXiSHyS(lXysM8y4bkccIXJHQ26zdOad)ifz)EIiCDLRcHyBi4jmOdWnfb1wWu5cZad)ifz)EIiCDLRHJqeb4UOUqafcE2oVfWFiQ8KMcPw57jGQoLG9fM4ZqrLXkLITa0nxyMppcu9A)BUK6CVjLkG)vaRTjoYaKVt5BJq1UVfo4X(IfzIpdScM((AWuRlqkFEeO61(3Cj15EtkvG1Zb)RawBtCKbiFNY3gHQDFlCWJ9flYeFgIJmaPlLk0eslvawIavV2ptSzfEv)fa18)9)RTHavV2)Y8bg(rkY(9er46kxfcX2qWtyqhGBkcQTGPYfMbg(rkY(9er46kxdhHicW9XSJfAIJma5VWK7I6cR4Cu58wO)3lL2XSJfAgocreapcOqWZ25Ta(drLN0ui1kFpbu1PeSVWeFgkQmwPuSfGU5cZ85rGQx7FZLuN7nPub8VcyTnXrgG8DkFBeQ29TWbp2xSit8zGvW03xdMADbs5ZJavV2)MlPo3BsPcSEo4FfWABIJma57u(2iuT7BHdESVyrM4ZqCKbiDPuHMqAPcWseO61(zInM5Gx1Fbqn)F))ABiq1R9VmFGrwJXKqL6t2y4euvGxIHSXOYyLsXcXioYaKpgxIHvCfJjzYJHLSHngeZU1AedHrIP2yY5JjdgLyesmSkgXrgG8zgdbfdl(yYWeCfJ4idq(mdm8JuK97jIW1vUhuP(KTjGQc8c3f11RawBtCKbip2x5GhbQET)n5WvgVcyTnXrgG8yFzImXduuWrkCq7qu5jnfsTYJ9fRcmYAmMSaqjggLyUDgfHbbX4smSIRyiBmU1gJ4idq(yYGLSHngBHRwJySK1igyjmgSJX3umlrI5xx5ztKmdm8JuK97jIW1vUigfHbbCxuxyfNJkN3c9)EP0qmkcdcWNbqrbhPWbTdrLN0ui1kp2xScpcOqWZ25Tq(8yvQZ9AnWNHuQa2yA(85pevEstHuR8yFLtMzIpdfvgRuk2cq3CHz(8iq1R9V5sQZ9MuQa(xbS2M4idq(oLVncv7(w4Gh7lwKj(mWky67RbtTUaP85rGQx7FZLuN7nPubwph8VcyTnXrgG8DkFBeQ29TWbp2xSit8IJmaPlLk0eslvawIavV2hBwfy4hPi73teHRRCrmkcdc4(y2XcnXrgG8xyYDrDHvCoQCEl0)7Ls7y2XcneJIWGa8yfNJkN3c9)EP0qmkcdcWduuWrkCq7qu5jnfsTYJ9fRWJake8SDElGpdfvgRuk2cq3CHz(8iq1R9V5sQZ9MuQa(xbS2M4idq(oLVncv7(w4Gh7lwKj(mWky67RbtTUaP85rGQx7FZLuN7nPubwph8VcyTnXrgG8DkFBeQ29TWbp2xSit8IJmaPlLk0eslvawIavV2hBwfyK1ymjuP(Kngobvf4LyiBm0CgtrftTXO4BcuRtm(MIPKyyzzTXKiXyH)Jj5QUbeJW23yyTloyjQXKyGyesmCMDUzrwtGHFKISFpreUUY9Gk1NSnbuvGx4UOUEfWABIJma5VWepqrbhPWbTdrLN0ui1kp2xzCuAQUPTxb2ewIzM4rafcE2oVfWJvW03xdMADbs4XAc4zOO6p7cxNrbVQ)cGA()()12qGQx7FzE8IJmaPlLk0eslvawIavV2hBwfy4hPi73teHRRCFq5RpWiWiRXqlGBf2qkgwZrkY(bgzngokd2V427akgYgdl48wJXKqL6t2y4euvGxcm8JuK97VaUvydPRdQuFY2eqvbEH7I6sClSsFld2YlU9oG6W68wiH)vaRTjoYaKh7lwG)qu5jnfsTYJ9fRWloYaKUuQqtiTubyjcu9AFSXIbgzngokd2V427akgYgdMCERXqVUYZMiXC7mkcdccm8JuK97VaUvydjUUYfXOimiG7I6sClSsFld2YlU9oG6W68wiH)qu5jnfsTYJ9fRWloYaKUuQqtiTubyjcu9AFSXIbgzngAgEbqumgWTgdRrrXAwmeum3oqHGNDmSSe2XWZqrbPyYcocre4dm8JuK97VaUvydjUUYvHqSne8eg0b4MIGAlyQCHzGHFKISF)fWTcBiX1vUgocreG7Jzhl0ehzaYFHj3f1L4wyL(ZWlaIIXa6W68wiHpdeO61(3Gzo5ZROYyLsXwa6MlmZeV4idq6sPcnH0sfGLiq1R9XoNaJSgdndVaikgdigUIH1A6BedzJbtoV1yUDGcbp7yYcocreigxIrydXaBkgcvmVaUvyhJqIXaKyuDtJjXGCPiBm8afbbXWAn991GPwxGad)ifz)(lGBf2qIRRCvieBdbpHbDaUPiO2cMkxygy4hPi73FbCRWgsCDLRHJqeb4UOUe3cR0FgEbqumgqhwN3cj8IBHv6GPVVgm16c0H15TqcVFKch0Gful4VWeppdfv)z4farXyaDeO61(3GzNfbg(rkY(9xa3kSHexx5QYiL1fG7I6sClSs)z4farXyaDyDElKWFiQ8KMcPw5V5IfbgbgznMSSV1ZoWiRXyUvB9SJHLLWogv30ymjtEmueumCugSLxC7DaXDmmRf(pgMVwJymxGlSTMfdnBpry5hy4hPi73X5B9SVW5OY5Ta3RRcxBzWwEXT3bu7O0oKnvsrwUX5wg4kdSIywGIGmGEcCHT1S2Z2tew(4bkk4ifoODiQ8KMcPw5X(6O0uDtBVcSPmZNpdeZcueKb0tGlSTM1E2EIWYh)HOYtAkKAL)MCYmWiRXKL9TE2XWYsyhdR103igUIHJYGT8IBVdOBnMSOBAPYOgJjzYJX3umSwtFJyqGNmlgkckMfmvIjlysMRad)ifz)ooFRNnxx5IZ36zZDrDjUfwPdM((AWuRlqhwN3cj8IBHv6BzWwEXT3buhwN3cj84Cu58wOVLbB5f3EhqTJs7q2ujfzXFieBIWYTdM((AWuRlqhbQET)nygyK1yYY(wp7yyzjSJHJYGT8IBVdOy4kgoiXWAn9nU1yYIUPLkJAmMKjpgFtXKLHnbI4XWOey4hPi73X5B9S56kxC(wpBUlQlXTWk9TmylV427aQdRZBHeESkUfwPdM((AWuRlqhwN3cj84Cu58wOVLbB5f3EhqTJs7q2ujfzXNaEgkQooytGiENrjWWpsr2VJZ36zZ1vUkeITHGNWGoa3ueuBbtLlm5gmvqEZvjmRCXktey4hPi73X5B9S56kxC(wpBUlQlXTWk9NHxaefJb0H15Tqc)HqSjcl3UHJqeb6mk4ZirKUHJqeb6iGcbpBN3c5ZNaEgkQooytGiENrbFIiDdhHic0vuzSsPylaDZfMzI)qu5jnfsTY3tavDkb7RmEfWABIJma57u(2iuT7BHdESVLXQmXJ8k1aCWkDpL(ETyJzobgznMSSV1Zogwwc7yYI(lakgwZ)(x7TgdhKyEbCRWogFtXSKy8Ju4GyYISMy4zOO4oMBNrryqqmlrIP2yqafcE2XG81a4oMedQwJyYYWMarCU4m7ad)ifz)ooFRNnxx5IZ36zZDrDLH4wyLUQ)cGA()()12H15TqkFEeZcueKb0vD09gHQjSHMQ)cGA()()1MjESMishXOimiOJake8SDElGprKUHJqeb6iq1R9XMf4tapdfvhhSjqeVZOGpb8muu9NDHRZOOPFf4O5ihtKL0Iw0Aa]] )

end