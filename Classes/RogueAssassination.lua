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


    spec:RegisterPack( "Assassination", 20210307, [[davwccqiKipsPOUeQIQnHQ6tujmkvvoLQsRcjQEfQsZIkPBPuODPKFPs0WqrCmvsldf6zujAAOkCnrvzBOksFdvrzCQkqDovfuRdfPEhkscnpvc3djTpuu)dfjrhefjwOQIEOsbtejkUOOQQnQQG8rKO0irrsLtQQawjk4LQkqMPsr6MOkIDkQYqvvilvuv5PO0uPs1vrrsWwvkIVIIK0yvvO2RK(RQmykhwyXuLhRIjlXLH2ms9zrz0QuNwQvJIKQETsPzlYTPQ2TIFdmCQ44OiPSCqphX0jDDuz7kvFhjmEQuoVQQMVOY(jUET6ELTekwZJrMW4vM4sMWZwmYipy8kpQS6FhSY6eNTrgwzNWhRSmfcjiKEcTbtL1j(NarP6ELLa4GhSYERQdHPV8YSwV58whG)LK2NlfAdMdmO1ljT)5YkRhxN0pWu9QSLqXAEmYegVYexYeE2Irg5bJmHNvzdo9gaRSST)gQS3DPGt1RYwqYPYYuiKGq6j0gmILFGmouyGNeWZTy8mxfJrMW4vHbHHnChtgsyAHHnkgpbSJfX(qPidtPqBWi2VnKWyi4xX4CeRhXCGna26FXiaXAvmkaCPIydqfldvX84GnweZdV7PigrXiP3IfhTbdzvztnrjv3RSefJKEJLQ718UwDVYIt4LWs9ZkBC0gmv2dS9jG5POVds0kBbjhy7OnyQS51z3ensBrOyGrmx6otl2gGTpbmI5o67GeTYEGTIWoQSAKWrxtNDRensBr4cNWlHfX4lgXbtPNgWmujIXmvXCPy8f7a89aphqpkrmMPkgpeJVyAaZqDPTp(uWR0OyBumi6h9qeJzX4PvTMhJv3RS4eEjSu)SYghTbtLfY5OCqSYwqYb2oAdMkBED2nrJ0wekgye7Q7mTySt4qUbQy5hNJYbXk7b2kc7OYQrchDnD2Ts0iTfHlCcVeweJVyhGVh45a6rjIXmvX4Hy8ftdygQlT9XNcELgfBJIbr)OhIymlgpTQ18Cz19kloHxcl1pRSXrBWuzDaG0dIeah8Gv2csoW2rBWuzz58uesZLHmTymfhN0FXaqXYpKgIKBXOO1BX84OPXIyu2acbksQS0a4Bq30AExRAnpEuDVYIt4LWs9ZkBC0gmv2SacbkwzpWwryhvwns4OlcNNIqAUmCHt4LWIy8f7Nyq0p6Hi2fIDLrXYLtmhFUK2oPgHIDbvXUk2xX4lMgWmuxA7Jpf8knk2gfdI(rpeXywmgRSN)Ne(0aMHkPM31QwZlFv3RS4eEjSu)SYghTbtL1baspisaCWdwzli5aBhTbtLLLZtrinxgkgVIL)UrYedmID1DMwS8dPHi5wmkBaHaffluX0BumCkIbOfJOyK0BXuGyzOkMF4MyfoyOnyeZdPbquS83nsmzC9ekwzPbW3GUP18Uw1AE80Q7vwCcVewQFwzpWwryhvwns4OlcNNIqAUmCHt4LWIy8ftJeo6cDJetgxpHIlCcVeweJVyXr7D8Hd63irmQIDvm(I5XrtViCEkcP5YWfe9JEiIDHyxxUSYghTbtLnlGqGIvTMhpR6ELfNWlHL6Nv2dSve2rLvJeo6IW5PiKMldx4eEjSigFXoaFpWZb0Jse7cQI5YkBC0gmvwFoTtHIvTQv29yAYD19AExRUxzXj8syP(zLf4uzjOwzJJ2GPYUhWo8syLDpsCyL9Nyusmi3G0aygUkyO3P)pYDuauqw4eEjSigFXqAA8O9o(oaFpWZb0JseJzQIDCE(HBpIdofX(kwUCI9tmi3G0aygUkyO3P)pYDuauqw4eEjSigFXoaFpWZb0Jse7cXyuSVv2csoW2rBWuz)q90KBXOO1BX8d3eBdFKy0aOy51z3krJ0we6QyCtcjeX4i9KjgLbd9o9xm27OaOGuz3d4BcFSYoD2Ts0iTfHVJZ7aMsRnyQAnpgRUxzXj8syP(zLnoAdMk7Emn5UYwqYb2oAdMk7MettUfJIwVfl)DJKjgVILxNDRensBritlgpjCR958fBdFKyXuel)DJKjgeJYFXObqXg0nvmk7gOmv2dSve2rLvJeo6cDJetgxpHIlCcVeweJVyAKWrxtNDRensBr4cNWlHfX4l2Ea7WlHRPZUvIgPTi8DCEhWuATbJy8f7aaPcGIzHUrIjJRNqXfe9JEiIDHyxRAnpxwDVYIt4LWs9ZkBC0gmv29yAYDLTGKdSD0gmv2njMMClgfTElwED2Ts0iTfHIXRy5bel)DJKX0IXtc3AFoFX2WhjwmfX2eCkOQHyCov2dSve2rLvJeo6A6SBLOrAlcx4eEjSigFXOKyAKWrxOBKyY46juCHt4LWIy8fBpGD4LW10z3krJ0we(ooVdykT2Grm(IvqpoA61oofu1yX5u1AE8O6ELfNWlHL6Nv24OnyQSoaq6brcGdEWkl6McJx4d4gTYYJ8vzPbW3GUP18Uw1AE5R6ELfNWlHL6Nv2dSve2rLvJeo6IW5PiKMldx4eEjSigFXoaqQaOywzbecuCX5igFX(jwbORSacbkUGinej3HxcflxoXkOhhn9AhNcQAS4CeJVyfGUYcieO4YXNlPTtQrOyxqvSRI9vm(IDa(EGNdOhLSkiDFAvmMPk2pXioyk90aMHkzrhZdq)2o9oseJzMkfJhI9vm(IbJU8WDC0vukKvpIXSyxzSYghTbtLDpMMCx1AE80Q7vwCcVewQFwzJJ2GPYUhttURSfKCGTJ2GPYUjX0KBXOO1BX4jbrrOymfcji9W0ILFCokhe5LYgqiqrXgGkwpIbrAisUfdgtg6QyfoypzITj4uqvdEzV79LyS)NJyu06TySOdPjIr3tKe7UvXAAXCaes7LWvL9aBfHDuz)jMgjC0LFque(ccjiKEw4eEjSiwUCIb5gKgaZWLFa3(a0p9gF(brr4liKGq6zHt4LWIyFfJVyusScqxqohLdIlisdrYD4LqX4lwbORSacbkUGOF0drmMfZLIXxSc6XrtV2XPGQglohX4l2pXkOhhn9IC37lohXYLtSc6XrtV2XPGQgli6h9qe7cX4Hy5YjwbOlc6qAYs7Z2EYe7Ry8fRa0fbDinzbr)OhIyxiMlRAvRSfKo4sA19AExRUxzJJ2GPYUTpBRS4eEjSu)SQ18yS6ELfNWlHL6Nv2csoW2rBWuzZpKOyK0BXAAXCaes7LqX(naX25sdcdVekgoOFJeX6rSdW3l0Vv24OnyQSefJKEx1AEUS6ELfNWlHL6NvwGtLLGALnoAdMk7Ea7WlHv29iXHvwCqy2)feZWrmEfZb0eWGLNxcXcrmkxSFIXZeJxXCuOyFf7sX(jgJIr5IrCWu6Dheff7BLDpGVj8Xkloim7)dIz48oaFVEWsvR5XJQ7vwCcVewQFwzbovwcQv24OnyQS7bSdVewz3Jehwzjoyk90aMHkzrhZdq)2o9ose7cXySYUhW3e(yLL0twcFAaZqTQ18Yx19kloHxcl1pRShyRiSJkBb94OPx0PidtPqBWSGOF0drSleJXkBC0gmvw6uKHPuOnyENegdbRAnpEA19kloHxcl1pRShyRiSJklrXiP3yzbbzCyLnoAdMk7jsPxC0gmVut0kBQj6BcFSYsums6nwQAnpEw19kloHxcl1pRShyRiSJk7pXOKyAKWrx(brr4liKGq6zHt4LWIy5YjwbORSacbkU0(STNmX(wzJJ2GPYEIu6fhTbZl1eTYMAI(MWhRSNcPQ18(GRUxzXj8syP(zL9aBfHDuzPKyokum(IrCWu6PbmdvYIoMhG(TD6DKi2fuf7Ny5tSnkgKBqAamdxLGC3t2JCaCtbIPfoHxclI9vm(I5XrtViP(GVykVsFWfe9JEiIDHy0D2T(GOF0drm(IbrAisUdVekgFXoaFpWZb0JseJzQI5YkBC0gmvwsQp4lMYR0hSQ18(Wv3RS4eEjSu)SYghTbtLLK6d(IP8k9bRSfKCGTJ2GPY(rCQySdLrmohX6P1osP)IrdGITbovmfiMEJITH7GGUkgePHi5wmkA9wS8F2Xb4lwtlwOILauiwHdgAdMk7b2kc7OY6OqX4lgLeZJJMErs9bFXuEL(GlohX4l2b47bEoGEuIymtvmxw1AExzs19kloHxcl1pRShyRiSJkRJcfJVyEC00lsQp4lMYR0hCX5igFX84OPxKuFWxmLxPp4cI(rpeXUqS8jgFXoaFpWZb0JseJzQIXJkBC0gmvwC2Xb4x1AExVwDVYIt4LWs9ZkBC0gmv2tKsV4OnyEPMOv2ut03e(yLTa0QwZ7kJv3RS4eEjSu)SYghTbtL9eP0loAdMxQjALn1e9nHpwzlnepAvR5D1Lv3RS4eEjSu)SYEGTIWoQS4GWS)Rcs3NwfJzQIDnFIXRy7bSdVeUWbHz)FqmdN3b471dwQSXrBWuzd4jg8PaiehTQ18UYJQ7v24OnyQSb8ed(C4seSYIt4LWs9ZQwZ7A(QUxzJJ2GPYM6SBL8yQNRK5JJwzXj8syP(zvR5DLNwDVYghTbtL1lYEa6Nc7ZwsLfNWlHL6NvTQvwhiEa(EHwDVM31Q7v24OnyQSHJt6)Zb0eWuzXj8syP(zvR5Xy19kBC0gmvwpGQjS8OtXFSqrpzpf4wpvwCcVewQFw1AEUS6ELfNWlHL6Nv24OnyQS(bClwE0a4RGHExzpWwryhvwy0LhUJJUIsHS6rmMf7A(QSoq8a89c9rWdykKkB(QAnpEuDVYIt4LWs9ZklWPYsqTYghTbtLDpGD4LWk7EaFt4Jvwf2ZwuFK)Z5rsaTYEGTIWoQSkSNTOU0RR7G8iAORy()koeX4l2pXOKykSNTOUugx3b5r0qxX8)vCiILlNykSNTOU0RRdaKkakMvHdgAdgXyMQykSNTOUugxhaivaumRchm0gmI9TYwqYb2oAdMklLbve63dkgf395wSFnTyX8)RyenuX84OPftH9SfvXOafJIyuXuGyHQOVJkMceJ8FoIrrR3ITj4uqvJvLDpsCyL9AvR5LVQ7vwCcVewQFwzbovwcQv24OnyQS7bSdVewz3JehwzzSYEGTIWoQSkSNTOUugx3b5r0qxX8)vCiIXxSFIrjXuypBrDPxx3b5r0qxX8)vCiILlNykSNTOUugxhaivaumRchm0gmIXSykSNTOU0RRdaKkakMvHdgAdgX(wz3d4BcFSYQWE2I6J8FopscOvTMhpT6ELnoAdMklrXiP3vwCcVewQFw1AE8SQ7vwCcVewQFwzJJ2GPYss9bFXuEL(Gv2dSve2rLfI0qKChEjSY6aXdW3l0hbpGPqQSxRAvRSLgIhT6EnVRv3RS4eEjSu)SYghTbtLfNDCa(v2csoW2rBWuzZ)zhhGVyHkgp4vSF5JxXOO1BXOmSFfBdF0sSpGVpw6qX0FXaJymYRyAaZqL4Qyu06TyBcofu1WvXaqXOO1BXC)txfdO3iKIMGIrr0Qy0aOyeGpkgoim7)smMsIaeJIOvXAAXYF3izIDa(EaXAIyhGFpzIX5SQShyRiSJklstJhT3X3b47bEoGEuIymtvmEigVIPrchDvq0bHpIcdnYq)foHxclIXxSFIvqpoA61oofu1yX5iwUCIvqpoA6f5U3xCoILlNyf0JJMErNImmLcTbZIZrSC5edheM9Fvq6(0QyxqvmgZNy8k2Ea7WlHlCqy2)heZW5Da(E9GfXYLtmkj2Ea7WlHlspzj8PbmdvX(kgFX(jgLetJeo6cDJetgxpHIlCcVewelxoXoaqQaOywOBKyY46juCbr)OhIymlgJI9TQ18yS6ELfNWlHL6NvwGtLLGALnoAdMk7Ea7WlHv29iXHv2dW3d8Ca9OKvbP7tRIXSyxflxoXWbHz)xfKUpTk2fufJX8jgVIThWo8s4cheM9)bXmCEhGVxpyrSC5eJsIThWo8s4I0twcFAaZqTYUhW3e(yLLJGp6oLqyvR55YQ7vwCcVewQFwzJJ2GPYsqimuS88ad(io9wSYEGTIWoQS(brr4liKGq65br)OhIyufJjIXxSFI5XrtViP(GVykVsFWfNJy8fJsIva6IGqyOy55bg8rC6T4Ra0L2NT9KjwUCI5bieX4lgDNDRpi6h9qe7cQILpXYLtSdaKkakMfbHWqXYZdm4J40BX15oGzi5rdJJ2GjsIXmvXyCXZYNy5YjgbWL86PSsyuEE)FOBHVtcx4eEjSigFXOKyEC00RegLN3)h6w47KWfNJyFRSN)Ne(0aMHkPM31QwZJhv3RS4eEjSu)SYghTbtLLoMhG(TD6DKuzli5aBhTbtL9dfJyaAX(GMEhjIfQyx)W8kgrJZwIyaAXyQRlfCe7ZuuqIyaOyrw0drfJh8kMgWmujRk7b2kc7OYUhWo8s4IJGp6oLqOy8f7NyEC00R7UuW55LIcswenoBfJzQID9dlwUCI9tmkjMdSbWw))Gan0gmIXxmIdMspnGzOsw0X8a0VTtVJeXyMQy8qmEfJOyK0BSSGGmouSVI9TQ18Yx19kloHxcl1pRSXrBWuzPJ5bOFBNEhjv2Z)tcFAaZqLuZ7AL9aBfHDuz3dyhEjCXrWhDNsium(IrCWu6PbmdvYIoMhG(TD6DKigZufZLv2csoW2rBWuz)qXigGwSpOP3rIykqSWXj9xmkdgL0FX(iqtaJynTy9ehT3rXaJyX8xmnGzOkwOI5sX0aMHkzv1AE80Q7vwCcVewQFwzpWwryhv29a2HxcxCe8r3PecfJVyhaivaumRDCkOQXcI(rpeXywSRmPYghTbtLfp3GEYEq0b2(XuQAnpEw19kloHxcl1pRShyRiSJk7Ea7WlHloc(O7ucHIXxSFI5hefHVGqccPNhe9JEiIrvmMiwUCI5XrtV8s9uiDbxCoI9TYghTbtLn894i3vTM3hC19kloHxcl1pRSXrBWuz950ofkwzp)pj8PbmdvsnVRv2dSve2rLDpGD4LWfhbF0DkHqX4lgXbtPNgWmujl6yEa632P3rIyufJXkBbjhy7OnyQSUhEBKNWPDkuumfiw44K(lgLbJs6VyFeOjGrSqfJrX0aMHkPQ18(Wv3RS4eEjSu)SYEGTIWoQS7bSdVeU4i4JUtjewzJJ2GPY6ZPDkuSQvTYEkKQ718UwDVYIt4LWs9ZkBC0gmvw)aUflpAa8vWqVRSN)Ne(0aMHkPM31k7b2kc7OYcJU8WDC0vukKfNJy8f7NyAaZqDPTp(uWR0Oyxi2b47bEoGEuYQG09PvXOCXUUYNy5Yj2b47bEoGEuYQG09PvXyMQyhNNF42J4GtrSVv2csoW2rBWuz)a0IfLcrSaIIX54QyKPDqX0BumWGIrrR3ILauGevm3DNYSeJPceumkUXrSY)EYeJoikcftVJrSn8rIvq6(0QyaOyu06nGtflM)ITHpAv1AEmwDVYIt4LWs9ZkBC0gmvw)aUflpAa8vWqVRSfKCGTJ2GPY(bOfBaIfLcrmk6usSsJIrrR39iMEJInOBQyUKjexfJJGIXtOPmIbgX8aeIyu06nGtflM)ITHpAvzpWwryhvwy0LhUJJUIsHS6rmMfZLmrSnkgm6Yd3XrxrPqwfoyOnyeJVyhGVh45a6rjRcs3NwfJzQIDCE(HBpIdoLQwZZLv3RS4eEjSu)SYghTbtLLofzykfAdMkBbjhy7OnyQSS)NJyFOuKHPuOnyeJIwVfBtWPGQgIfeXsGjtSGigfOyuagxOILaeuSqStquXa7ium9gfJUZUvXkCWqBWuzpWwryhvwkjgrXiP3yzbbzCOy8f7NyhaivaumRDCkOQXcI(rpeXUqmxkgFXqAA8O9o(oaFpWZb0JseJzQIXdX4lMgWmuxA7Jpf8knkgZIDLjILlNyf0JJMETJtbvnwCoILlNyEacrm(Ir3z36dI(rpeXUqmg5HyFRAnpEuDVYIt4LWs9Zk7b2kc7OYsjXikgj9glliiJdfJVyinnE0EhFhGVh45a6rjIXmvX4Hy8f7Ny0jaak2pX(jgDNDRpi6h9qeBJIXipe7RyxkwC0gmVdaKkakgX(kgZIrNaaOy)e7Ny0D2T(GOF0drSnkgJ8qSnk2basfafZAhNcQASGOF0drmkxS9a2Hxcx74uqvJ3Paf7RyxkwC0gmVdaKkakgX(k23kBC0gmvw6uKHPuOnyQAnV8vDVYIt4LWs9Zk7b2kc7OYwqpoA6fDkYWuk0gmli6h9qe7cXySYghTbtLLofzykfAdM3jHXqWQwZJNwDVYIt4LWs9ZkBC0gmvwc6qAsLTGKdSD0gmvw2)Zrmw0H0eXOO1BX2eCkOQHybrSeyYeliIrbkgfGXfQyjabfle7eevmWocftVrXO7SBvSchm0gmUkMhNkMdePrOyAaZqLiMEhQyu0PKyPEhfluXsyquXUYesL9aBfHDuzPKyefJKEJLfeKXHIXxSFIDaGubqXS2XPGQgli6h9qe7cXUkgFX0aMH6sBF8PGxPrXywSRmrSC5eRGEC00RDCkOQXIZrSC5eJUZU1he9JEiIDHyxzIyFRAnpEw19kloHxcl1pRShyRiSJklLeJOyK0BSSGGmoum(I9tm6eaaf7Ny)eJUZU1he9JEiITrXUYeX(k2LIfhTbZ7aaPcGIrSVIXSy0jaak2pX(jgDNDRpi6h9qeBJIDLjITrXoaqQaOyw74uqvJfe9JEiIr5IThWo8s4AhNcQA8ofOyFf7sXIJ2G5DaGubqXi2xX(wzJJ2GPYsqhstQAnVp4Q7vwCcVewQFwzbovwcQv24OnyQS7bSdVewz3JehwzPKyAKWrxtNDRensBr4cNWlHfXYLtmkjMgjC0f6gjMmUEcfx4eEjSiwUCIDaGubqXSq3iXKX1tO4cI(rpeXUqS8j2gfJrXOCX0iHJUki6GWhrHHgzO)cNWlHLkBbjhy7OnyQSS)NJyBcofu1qmk6PaOqmkA9wS86SBLOrAlc5n)DJetgxpHII10IfooP(eEjSYUhW3e(yLDhNcQA8Mo7wjAK2IW3bmLwBWu1AEF4Q7vwCcVewQFwzbovwcQv24OnyQS7bSdVewz3d4BcFSYUJtbvnEhWooXOVdykT2GPYEGTIWoQShWooXORT)HDmILlNyhWooXORbpqqcalILlNyhWooXORbmyLTGKdSD0gmvw2)ZrSnbNcQAigfTEl2hkfzykfAdgXIPigl6qAIybrSeyYeliIrbkgfGXfQyjabfle7eevmWocftVrXO7SBvSchm0gmv29iXHv2RvTM3vMuDVYIt4LWs9ZklWPYsqTYghTbtLDpGD4LWk7EK4WklDcaGI9tSFIr3z36dI(rpeX2OymYeX(k2LI9tSRmYeXOCX2dyhEjCTJtbvnENcuSVI9vmMfJobaqX(j2pXO7SB9br)OhIyBumgzIyBuSdaKkakMfDkYWuk0gmli6h9qe7Ryxk2pXUYiteJYfBpGD4LW1oofu14DkqX(k2xXYLtmpoA6fDkYWuk0gmppoA6fNJy5Yjwb94OPx0PidtPqBWS4CelxoXO7SB9br)OhIyxigJmPYEGTIWoQShWooXORDC07)Wk7EaFt4Jv2DCkOQX7a2Xjg9DatP1gmvTM31Rv3RS4eEjSu)SYcCQSeuRSXrBWuz3dyhEjSYUhjoSYsNaaOy)e7Ny0D2T(GOF0drSnkgJmrSVIDPy)e7kJmrmkxS9a2Hxcx74uqvJ3Paf7RyFfJzXOtaauSFI9tm6o7wFq0p6Hi2gfJrMi2gf7aaPcGIzrqhstwq0p6Hi2xXUuSFIDLrMigLl2Ea7WlHRDCkOQX7uGI9vSVILlNyfGUiOdPjlTpB7jtSC5eJUZU1he9JEiIDHymYKk7b2kc7OYEa74eJUMo7wF0bwz3d4BcFSYUJtbvnEhWooXOVdykT2GPQ18UYy19kloHxcl1pRShyRiSJklLeJOyK0BSSGGmoum(Iva6cY5OCqCP9zBpzIXxmkjwb94OPx74uqvJfNJy8fBpGD4LW1oofu14nD2Ts0iTfHVdykT2Grm(IThWo8s4AhNcQA8oGDCIrFhWuATbtLnoAdMk7oofu1OQ18U6YQ7vwCcVewQFwzJJ2GPYIUrIjJRNqXkBbjhy7OnyQS5VBKyY46juumkUXrSbOIrums6nwelMIyEa9wS8JZr5GOyXueJYgqiqrXcikgNJy0aOyjWKjgoaUS7vL9aBfHDuzPKyefJKEJLfeKXHIXxSFIrjXkaDLfqiqXfePHi5o8sOy8fRa0fKZr5G4cI(rpeXywmEigVIXdXOCXoop)WThXbNIy5YjwbOliNJYbXfe9JEiIr5IXKv(eJzX0aMH6sBF8PGxPrX(kgFX0aMH6sBF8PGxPrXywmEu1AEx5r19kloHxcl1pRSXrBWuzj39ELTGKdSD0gmvw27ExSMwmkqXcikw4b4uXuGy5)SJdW3vXIPiwOk67OIPaXi)NJyu06TySOdPjIr3tKe7UvXAAXOafJcW4cvmkcIII5dGOy6DmIDhjAX0BuSdaKkakMvL9aBfHDuzlaDb5CuoiU0(STNmX4l2pXOKyhaivaumlc6qAYcIr5Vy5Yj2basfafZAhNcQASGOF0drmMf7kJI9vSC5eRa0fbDinzP9zBpzvTM318vDVYIt4LWs9Zk7b2kc7OY6XrtV8saqjXr0feJJkwUCI5bieX4lgDNDRpi6h9qe7cXCjtelxoXkOhhn9AhNcQAS4CQSXrBWuzDaAdMQwZ7kpT6ELfNWlHL6Nv2dSve2rLTGEC00RDCkOQXIZPYghTbtL1lbaLhnh8FvR5DLNvDVYIt4LWs9Zk7b2kc7OYwqpoA61oofu1yX5uzJJ2GPY6Hqcc32twvR5D9dU6ELfNWlHL6Nv2dSve2rLTGEC00RDCkOQXIZPYghTbtLLUHOxcakvTM31pC19kloHxcl1pRShyRiSJkBb94OPx74uqvJfNtLnoAdMkBmhKOWi9orkv1AEmYKQ7vwCcVewQFwzpWwryhvwkjgrXiP3yzfPKy8fZpikcFbHeesppi6h9qeJQymPYghTbtL9eP0loAdMxQjALn1e9nHpwz3JPj3vTMhJxRUxzXj8syP(zLnoAdMkRc7zlQxRSfKCGTJ2GPYY(FoIP3OyoWgaB9VyenuX84OPftH9SfvXOO1BX2eCkOQHRIb0BesrtqX4iOyGrSdaKkakMk7b2kc7OYUhWo8s4sH9Sf1h5)CEKeqfJQyxfJVy)eRGEC00RDCkOQXIZrSC5eZdqiIXxm6o7wFq0p6Hi2fufJrMi2xXYLtSFIThWo8s4sH9Sf1h5)CEKeqfJQymkgFXOKykSNTOUugxhaivaumligL)I9vSC5eJsIThWo8s4sH9Sf1h5)CEKeqRAnpgzS6ELfNWlHL6Nv2dSve2rLDpGD4LWLc7zlQpY)58ijGkgvXyum(I9tSc6XrtV2XPGQglohXYLtmpaHigFXO7SB9br)OhIyxqvmgzIyFflxoX(j2Ea7WlHlf2ZwuFK)Z5rsavmQIDvm(IrjXuypBrDPxxhaivaumligL)I9vSC5eJsIThWo8s4sH9Sf1h5)CEKeqRSXrBWuzvypBrLXQw1kBbOv3R5DT6ELfNWlHL6NvwGtLLGALnoAdMk7Ea7WlHv29iXHvwhydGT()bbAOnyeJVyehmLEAaZqLSOJ5bOFBNEhjIXSyUum(I9tScqxzbecuCbr)OhIyxi2basfafZklGqGIRchm0gmILlNyoGMagS88siwiIXSy5tSVv2csoW2rBWuz302VvXOSbecuKigyeBaZgDGTpmG)ftdygQeXObqX0BumhydGT(xmiqdTbJynTy5JxX8siwiIfquSibXO8xmoNk7EaFt4JvwY225D(Fs4llGqGIvTMhJv3RS4eEjSu)SYcCQSeuRSXrBWuz3dyhEjSYUhjoSY6aBaS1)piqdTbJy8fJ4GP0tdygQKfDmpa9B707irmMfZLIXxSFIvqpoA6f5U3xCoILlNyoGMagS88siwiIXSy5tSVv2csoW2rBWuz302VvXYpohLdIeXaJydy2OdS9Hb8VyAaZqLignakMEJI5aBaS1)IbbAOnyeRPflF8kMxcXcrSaIIfjigL)IX5uz3d4BcFSYs22oVZ)tcFqohLdIvTMNlRUxzXj8syP(zLf4uzjOwzJJ2GPYUhWo8syLDpsCyLTGEC00RDCkOQXIZrm(I9tSc6XrtVi39(IZrSC5eZpikcFbHeesppi6h9qeJzXyIyFfJVyfGUGCokhexq0p6HigZIXyLTGKdSD0gmv2nT9BvS8JZr5GirSMwSnbNcQAWl7DVFjpjikcfJPqibH0JynrmohXIPigfOy3XokgJ8kgbpGPqelH0QyGrm9gfl)4CuoikgLb4ELDpGVj8XklzB78GCokheRAnpEuDVYIt4LWs9ZkBC0gmv2Sacbkwzli5aBhTbtLL1bpDKeJYgqiqrXIPiw(X5OCqumcQCoI5aBaumfiw(7gjMmUEcff7eeTYEGTIWoQSAKWrxOBKyY46juCHt4LWIy8fJsIvqpoA6vwaHafxOBKyY46juSigFXkaDLfqiqXLJpxsBNuJqXUGQyxfJVyhaivauml0nsmzC9ekUGOF0drSleJrX4lgXbtPNgWmujl6yEa632P3rIyuf7Qy8fdgD5H74OROuiREeJzX4PIXxScqxzbecuCbr)OhIyuUymzLpXUqmnGzOU02hFk4vASQ18Yx19kloHxcl1pRShyRiSJkRgjC0f6gjMmUEcfx4eEjSigFX(jgstJhT3X3b47bEoGEuIymtvSJZZpC7rCWPigFXoaqQaOywOBKyY46juCbr)OhIyxi2vX4lwbOliNJYbXfe9JEiIr5IXKv(e7cX0aMH6sBF8PGxPrX(wzJJ2GPYc5Cuoiw1AE80Q7vwCcVewQFwzJJ2GPY6aaPhejao4bRSfKCGTJ2GPYszdieOOyCoBr0XvXIebiMcBKiMceJJGI1QybrSqmIdE6ijwgoimuaumAaum9gflfevSn8rI5H0aikwigDpn5gHvwAa8nOBAnVRvTMhpR6ELfNWlHL6Nv2dSve2rLfI0qKChEjum(IDa(EGNdOhLSkiDFAvmMPk2vX4l2pXC85sA7KAek2fuf7Qy5Yjge9JEiIDbvX0(S9PTpkgFXioyk90aMHkzrhZdq)2o9oseJzQI5sX(kgFX(jgLedDJetgxpHIfXYLtmi6h9qe7cQIP9z7tBFumkxmgfJVyehmLEAaZqLSOJ5bOFBNEhjIXmvXCPyFfJVy)etdygQlT9XNcELgfBJIbr)OhIyFfJzX4Hy8fZpikcFbHeesppi6h9qeJQymPYghTbtLnlGqGIvTM3hC19kloHxcl1pRS0a4Bq30AExRSXrBWuzDaG0dIeah8GvTM3hU6ELfNWlHL6Nv24OnyQSzbecuSYEGTIWoQSusS9a2HxcxKTTZ78)KWxwaHaffJVyqKgIK7WlHIXxSdW3d8Ca9OKvbP7tRIXmvXUkgFX(jMJpxsBNuJqXUGQyxflxoXGOF0drSlOkM2NTpT9rX4lgXbtPNgWmujl6yEa632P3rIymtvmxk2xX4l2pXOKyOBKyY46juSiwUCIbr)OhIyxqvmTpBFA7JIr5IXOy8fJ4GP0tdygQKfDmpa9B707irmMPkMlf7Ry8f7NyAaZqDPTp(uWR0OyBumi6h9qe7Ryml2vgfJVy(brr4liKGq65br)OhIyufJjv2Z)tcFAaZqLuZ7AvR5DLjv3RS4eEjSu)SYghTbtL9aBFcyEk67GeTYwqYb2oAdMk7gGTpbmI5o67GevmWiMpxsBNekMgWmujIfQy8GxX2Whjgf34igKBMEYedWPI1Jymse7hNJykqmEiMgWmujFfdafZLeX(LpEftdygQKVv2dSve2rLL4GP0tdygQeXyMQymkgFXGOF0drSleJrX4vSFIrCWu6PbmdvIymtvS8j2xX4lgstJhT3X3b47bEoGEuIymtvmEu1AExVwDVYIt4LWs9ZkBC0gmvwiNJYbXkBbjhy7OnyQSFqi6igNJy5hNJYbrXcvmEWRyGrSiLetdygQeX(rXnoIL69EYelbMmXWbWLDlwmfXgGkgzchYnq)wzpWwryhvwkj2Ea7WlHlY225b5CuoikgFX(jgstJhT3X3b47bEoGEuIymtvmEigFXGinej3HxcflxoXOKyAF22tMy8f7NyA7JIXSyxzIy5Yj2b47bEoGEuIymtvmgf7RyFfJVy)eZXNlPTtQrOyxqvSRILlNyq0p6Hi2fuft7Z2N2(Oy8fJ4GP0tdygQKfDmpa9B707irmMPkMlf7Ry8f7Nyusm0nsmzC9ekwelxoXGOF0drSlOkM2NTpT9rXOCXyum(IrCWu6PbmdvYIoMhG(TD6DKigZufZLI9vm(IPbmd1L2(4tbVsJITrXGOF0drmMfJhvTM3vgRUxzXj8syP(zLnoAdMklKZr5GyL9aBfHDuzPKy7bSdVeUiBBN35)jHpiNJYbrX4lgLeBpGD4LWfzB78GCokhefJVyinnE0EhFhGVh45a6rjIXmvX4Hy8fdI0qKChEjum(I9tmhFUK2oPgHIDbvXUkwUCIbr)OhIyxqvmTpBFA7JIXxmIdMspnGzOsw0X8a0VTtVJeXyMQyUuSVIXxSFIrjXq3iXKX1tOyrSC5edI(rpeXUGQyAF2(02hfJYfJrX4lgXbtPNgWmujl6yEa632P3rIymtvmxk2xX4lMgWmuxA7Jpf8knk2gfdI(rpeXywSFIXdX4vmi3G0aygUkb5UNSh5a4McetlCcVeweJYf7dlgVIb5gKgaZWvba89srbx4eEjSigLlgpvSVv2Z)tcFAaZqLuZ7AvR5D1Lv3RS4eEjSu)SYghTbtL9aBFcyEk67GeTYwqYb2oAdMk7gGTpbmI5o67GevmWigR7I10I1JyoXuq)(iwmfXgmGP)I5hUjgoim7VyXueRPfl)NDCa(IrbyCHkwbiMpaIIvc)idfRWHIPaXC)Zl5jmLk7b2kc7OYsCWu6PbmdvIyuf7Qy8fdPPXJ2747a89aphqpkrmMPk2pXoop)WThXbNIyBuSRI9vm(IbrAisUdVekgFXOKyOBKyY46juSigFXOKyf0JJMErU79fNJy8fZpikcFbHeesppi6h9qeJQymrm(I9tmCqy2)vbP7tRIDbvXymFIXRy7bSdVeUWbHz)FqmdN3b471dwe7Ry8ftdygQlT9XNcELgfBJIbr)OhIymlgpQAvRALDhHKgm18yKjmELjxz0Lvwkc40tgPYYuLPKF59bYJYY0IjM73OyTVdaQIrdGI5I9yAYTledIm14AiweJa8rXcof4hkwe7ChtgswcdBApOyxzAX2ay2rOIfXCbKBqAamdxFSletbI5ci3G0aygU(4foHxclUqSFm623LWWM2dkgpLPfBdGzhHkweZfqUbPbWmC9XUqmfiMlGCdsdGz46Jx4eEjS4cX(D1TVlHbHbMQmL8lVpqEuwMwmXC)gfR9DaqvmAaumxuq6GlPUqmiYuJRHyrmcWhfl4uGFOyrSZDmzizjmSP9GI5sMwSnaMDeQyrm22FdIr(pA4My8CXuGyBkxiwP3BsdgXaoimuauSFx(vSFxD77syyt7bf7dMPfBdGzhHkweZfqUbPbWmC9XUqmfiMlGCdsdGz46Jx4eEjS4cX(D1TVlHbHbMQmL8lVpqEuwMwmXC)gfR9DaqvmAaumx4aXdW3luxigezQX1qSigb4JIfCkWpuSi25oMmKSeg20EqX4btl2gaZocvSiMluypBrDDD9XUqmfiMluypBrDPxxFSle7hJU9DjmSP9GIXdMwSnaMDeQyrmxOWE2I6IX1h7cXuGyUqH9Sf1LY46JDHy)y0TVlHHnThuS8X0ITbWSJqflI5cf2ZwuxxxFSletbI5cf2Zwux611h7cX(XOBFxcdBApOy5JPfBdGzhHkweZfkSNTOUyC9XUqmfiMluypBrDPmU(yxi2pgD77syqyGPktj)Y7dKhLLPftm3VrXAFhaufJgafZfNcXfIbrMACnelIra(OybNc8dflIDUJjdjlHHnThumEW0ITbWSJqflIX2(BqmY)rd3eJNlMceBt5cXk9EtAWigWbHHcGI97YVI9Jr3(Ueg20EqX4zmTyBam7iuXIyST)geJ8F0WnX45IPaX2uUqSsV3KgmIbCqyOaOy)U8Ry)y0TVlHHnThuSRmHPfBdGzhHkweJT93GyK)JgUjgpxmfi2MYfIv69M0GrmGdcdfaf73LFf7hJU9DjmSP9GID9ktl2gaZocvSigB7VbXi)hnCtmEUykqSnLleR07nPbJyahegkak2Vl)k2pgD77syyt7bfJXRmTyBam7iuXIyUqH9Sf1fJRp2fIPaXCHc7zlQlLX1h7cX(D1TVlHHnThumgzKPfBdGzhHkweZfkSNTOUUU(yxiMceZfkSNTOU0RRp2fI97QBFxcdcdmvzk5xEFG8OSmTyI5(nkw77aGQy0aOyUOauxigezQX1qSigb4JIfCkWpuSi25oMmKSeg20EqX4btl2gaZocvSiMlq3iXKX1tOyz9XUqmfiMlkOhhn96JxOBKyY46juS4cX(D1TVlHHnThuSRmY0ITbWSJqflI5ci3G0aygU(yxiMceZfqUbPbWmC9XlCcVewCHy)y0TVlHbHb3VrXCbhbFTI(exiwC0gmIrrqeBaQy0aUPiwpIP3nrS23ba1LWWhW3bavSigptS4Onyel1eLSegQSeh8uZJX89HRSoqaDNWk7M3SymfcjiKEcTbJy5hiJdfg28MfJNeWZTy8mxfJrMW4vHbHHnVzX2WDmziHPfg28MfBJIXta7yrSpukYWuk0gmI9Bdjmgc(vmohX6rmhydGT(xmcqSwfJcaxQi2auXYqvmpoyJfX8W7EkIrums6TyXrBWqwcdcdBEZIL)UHhoflI5H0aik2b47fQyEywpKLymLZbDuIydy24Da9P5sIfhTbdrmWK(VegIJ2GHSCG4b47fk1WXj9)5aAcyegIJ2GHSCG4b47fkVuV0dOAclp6u8hlu0t2tbU1JWqC0gmKLdepaFVq5L6L(bClwE0a4RGHE7QdepaFVqFe8aMcHA(CTPPcJU8WDC0vukKvpmFnFcdBwmkdQi0VhumkU7ZTy)AAXI5)xXiAOI5XrtlMc7zlQIrbkgfXOIPaXcvrFhvmfig5)CeJIwVfBtWPGQglHH4OnyilhiEa(EHYl1l3dyhEj01j8rQkSNTO(i)NZJKaQR7rIdPE11MMQc7zlQRRR7G8iAORy()koe()OKc7zlQlgx3b5r0qxX8)vCi5YPWE2I6666aaPcGIzv4GH2GHzQkSNTOUyCDaGubqXSkCWqBW8vyioAdgYYbIhGVxO8s9Y9a2HxcDDcFKQc7zlQpY)58ijG66EK4qQm6AttvH9Sf1fJR7G8iAORy()koe()OKc7zlQRRR7G8iAORy()koKC5uypBrDX46aaPcGIzv4GH2GHzf2ZwuxxxhaivaumRchm0gmFfgIJ2GHSCG4b47fkVuVKOyK0BHH4OnyilhiEa(EHYl1ljP(GVykVsFqxDG4b47f6JGhWuiuV6AttfI0qKChEjuyqyyZBwS83n8WPyrmChH)ftBFum9gflokakwtel2JofEjCjmehTbdH62(SvyyZILFirXiP3I10I5aiK2lHI9BaITZLgegEjumCq)gjI1JyhGVxOFfgIJ2GHWl1ljkgj9wyioAdgcVuVCpGD4LqxNWhPIdcZ()GygoVdW3RhS46EK4qQ4GWS)liMHdVoGMagS88siwiu(pEgVok8lp)hJuoXbtP3Dqu8RWqC0gmeEPE5Ea7WlHUoHpsL0twcFAaZq119iXHujoyk90aMHkzrhZdq)2o9osUGrHH4Onyi8s9s6uKHPuOnyENegdbDTPPwqpoA6fDkYWuk0gmli6h9qUGrHH4Onyi8s9YtKsV4OnyEPMOUoHpsLOyK0BS4AttLOyK0BSSGGmouyioAdgcVuV8eP0loAdMxQjQRt4JupfIRnn1FusJeo6YpikcFbHeesplCcVewYLRa0vwaHafxAF22t2xHH4Onyi8s9ssQp4lMYR0h01MMkLCuiFIdMspnGzOsw0X8a0VTtVJKlO(lFBeYninaMHRsqU7j7roaUPaX0x(EC00lsQp4lMYR0hCbr)OhYf0D2T(GOF0dHpePHi5o8si)dW3d8Ca9OeMP6sHHnl2hXPIXougX4CeRNw7iL(lgnak2g4uXuGy6nk2gUdc6QyqKgIKBXOO1BXY)zhhGVynTyHkwcqHyfoyOnyegIJ2GHWl1ljP(GVykVsFqxBAQokKpL84OPxKuFWxmLxPp4IZH)b47bEoGEucZuDPWqC0gmeEPEjo74a8DTPP6Oq(EC00lsQp4lMYR0hCX5W3JJMErs9bFXuEL(Gli6h9qUiF8paFpWZb0JsyMkpegIJ2GHWl1lprk9IJ2G5LAI66e(i1cqfgIJ2GHWl1lprk9IJ2G5LAI66e(i1sdXJkmehTbdHxQxgWtm4tbqioQRnnvCqy2)vbP7tRmt9A(4DpGD4LWfoim7)dIz48oaFVEWIWqC0gmeEPEzapXGphUebfgIJ2GHWl1ltD2TsEm1ZvY8XrfgIJ2GHWl1l9IShG(PW(SLimimS5nl2gaGubqXqeg2SyFaAXIsHiwarX4CCvmY0oOy6nkgyqXOO1BXsakqIkM7UtzwIXubckgf34iw5FpzIrhefHIP3Xi2g(iXkiDFAvmaumkA9gWPIfZFX2WhTegIJ2GHSofcVuV0pGBXYJgaFfm0Bxp)pj8Pbmdvc1RU20uHrxE4oo6kkfYIZH)pnGzOU02hFk4vA8IdW3d8Ca9OKvbP7tRu(1v(YL7a89aphqpkzvq6(0kZupop)WThXbNYxHHnl2hGwSbiwukeXOOtjXknkgfTE3Jy6nk2GUPI5sMqCvmockgpHMYigyeZdqiIrrR3aovSy(l2g(OLWqC0gmK1Pq4L6L(bClwE0a4RGHE7AttfgD5H74OROuiREy2LmzJWOlpChhDfLczv4GH2GH)b47bEoGEuYQG09PvMPECE(HBpIdofHHnlg7)5i2hkfzykfAdgXOO1BX2eCkOQHybrSeyYeliIrbkgfGXfQyjabfle7eevmWocftVrXO7SBvSchm0gmcdXrBWqwNcHxQxsNImmLcTbJRnnvkrums6nwwqqghY)3basfafZAhNcQASGOF0d5cxYhPPXJ2747a89aphqpkHzQ8GVgWmuxA7Jpf8knY8vMKlxb94OPx74uqvJfNtUCEacHpDNDRpi6h9qUGrE8vyioAdgY6ui8s9s6uKHPuOnyCTPPsjIIrsVXYccY4q(innE0EhFhGVh45a6rjmtLh8)rNaa4VF0D2T(GOF0dzJmYJV88daKkakMVmtNaa4VF0D2T(GOF0dzJmYJnEaGubqXS2XPGQgli6h9qO89a2Hxcx74uqvJ3Pa)YZpaqQaOy((vyioAdgY6ui8s9s6uKHPuOnyENegdbDTPPwqpoA6fDkYWuk0gmli6h9qUGrHHnlg7)5igl6qAIyu06TyBcofu1qSGiwcmzIfeXOafJcW4cvSeGGIfIDcIkgyhHIP3Oy0D2TkwHdgAdgxfZJtfZbI0iumnGzOsetVdvmk6usSuVJIfQyjmiQyxzcryioAdgY6ui8s9sc6qAIRnnvkrums6nwwqqghY)3basfafZAhNcQASGOF0d5IR81aMH6sBF8PGxPrMVYKC5kOhhn9AhNcQAS4CYLJUZU1he9JEixCLjFfgIJ2GHSofcVuVKGoKM4AttLsefJKEJLfeKXH8)rNaa4VF0D2T(GOF0dzJxzYxE(basfafZxMPtaa83p6o7wFq0p6HSXRmzJhaivaumRDCkOQXcI(rpekFpGD4LW1oofu14DkWV88daKkakMVFfg2SyS)NJyBcofu1qmk6PaOqmkA9wS86SBLOrAlc5n)DJetgxpHII10IfooP(eEjuyioAdgY6ui8s9Y9a2HxcDDcFK6oofu14nD2Ts0iTfHVdykT2GX19iXHuPKgjC010z3krJ0weUWj8syjxokPrchDHUrIjJRNqXfoHxcl5YDaGubqXSq3iXKX1tO4cI(rpKlY3gzKY1iHJUki6GWhrHHgzO)cNWlHfHHnlg7)5i2MGtbvneJIwVf7dLImmLcTbJyXueJfDinrSGiwcmzIfeXOafJcW4cvSeGGIfIDcIkgyhHIP3Oy0D2TkwHdgAdgHH4OnyiRtHWl1l3dyhEj01j8rQ74uqvJ3bSJtm67aMsRnyCTPPEa74eJU2(h2XKl3bSJtm6AWdeKaWsUChWooXORbmOR7rIdPEvyioAdgY6ui8s9Y9a2HxcDDcFK6oofu14Da74eJ(oGP0AdgxBAQhWooXORDC07)qx3JehsLobaWF)O7SB9br)OhYgzKjF55)UYitO89a2Hxcx74uqvJ3Pa)(Lz6eaa)9JUZU1he9JEiBKrMSXdaKkakMfDkYWuk0gmli6h9q(YZ)DLrMq57bSdVeU2XPGQgVtb(9BUCEC00l6uKHPuOnyEEC00loNC5kOhhn9IofzykfAdMfNtUC0D2T(GOF0d5cgzIWqC0gmK1Pq4L6L7bSdVe66e(i1DCkOQX7a2Xjg9DatP1gmU20upGDCIrxtNDRp6aDDpsCiv6eaa)9JUZU1he9JEiBKrM8LN)7kJmHY3dyhEjCTJtbvnENc87xMPtaa83p6o7wFq0p6HSrgzYgpaqQaOywe0H0Kfe9JEiF55)UYitO89a2Hxcx74uqvJ3Pa)(nxUcqxe0H0KL2NT9KLlhDNDRpi6h9qUGrMimehTbdzDkeEPE5oofu1W1MMkLikgj9glliiJd5xa6cY5OCqCP9zBpz8Pub94OPx74uqvJfNd)9a2Hxcx74uqvJ30z3krJ0we(oGP0Adg(7bSdVeU2XPGQgVdyhNy03bmLwBWimSzXYF3iXKX1tOOyuCJJydqfJOyK0BSiwmfX8a6Ty5hNJYbrXIPigLnGqGIIfqumohXObqXsGjtmCaCz3lHH4OnyiRtHWl1lr3iXKX1tOORnnvkrums6nwwqqghY)hLkaDLfqiqXfePHi5o8si)cqxqohLdIli6h9qyMh8Ydk)488d3EehCk5Yva6cY5OCqCbr)OhcLZKv(ywdygQlT9XNcELg)YxdygQlT9XNcELgzMhcdBwm27ExSMwmkqXcikw4b4uXuGy5)SJdW3vXIPiwOk67OIPaXi)NJyu06TySOdPjIr3tKe7UvXAAXOafJcW4cvmkcIII5dGOy6DmIDhjAX0BuSdaKkakMLWqC0gmK1Pq4L6LK7E31MMAbOliNJYbXL2NT9KX)hLoaqQaOywe0H0KfeJY)C5oaqQaOyw74uqvJfe9JEimFLXV5Yva6IGoKMS0(STNmHH4OnyiRtHWl1lDaAdgxBAQEC00lVeausCeDbX4O5Y5bie(0D2T(GOF0d5cxYKC5kOhhn9AhNcQAS4CegIJ2GHSofcVuV0lbaLhnh8VRnn1c6XrtV2XPGQglohHH4OnyiRtHWl1l9qibHB7jZ1MMAb94OPx74uqvJfNJWqC0gmK1Pq4L6L0ne9saqX1MMAb94OPx74uqvJfNJWqC0gmK1Pq4L6LXCqIcJ07ePKRnn1c6XrtV2XPGQglohHH4OnyiRtHWl1lprk9IJ2G5LAI66e(i19yAYTRnnvkrums6nwwrkX3pikcFbHeesppi6h9qOYeHHnlg7)5iMEJI5aBaS1)Ir0qfZJJMwmf2ZwufJIwVfBtWPGQgUkgqVrifnbfJJGIbgXoaqQaOyegIJ2GHSofcVuVuH9Sf1RU20u3dyhEjCPWE2I6J8FopscOuVY)xb94OPx74uqvJfNtUCEacHpDNDRpi6h9qUGkJm5BUC)2dyhEjCPWE2I6J8FopscOuzKpLuypBrDX46aaPcGIzbXO8)BUCuApGD4LWLc7zlQpY)58ijGkmehTbdzDkeEPEPc7zlQm6AttDpGD4LWLc7zlQpY)58ijGsLr()kOhhn9AhNcQAS4CYLZdqi8P7SB9br)OhYfuzKjFZL73Ea7WlHlf2ZwuFK)Z5rsaL6v(usH9Sf1111basfafZcIr5)3C5O0Ea7WlHlf2ZwuFK)Z5rsavyqyyZBwmktdXJkwj8JmuSWRtT2iryyZIL)ZooaFXcvmEWRy)YhVIrrR3Irzy)k2g(OLyFaFFS0HIP)IbgXyKxX0aMHkXvXOO1BX2eCkOQHRIbGIrrR3I5(NmvumGEJqkAckgfrRIrdGIra(Oy4GWS)lXykjcqmkIwfRPfl)DJKj2b47beRjIDa(9KjgNZsyioAdgYQ0q8OuXzhhGVRnnvKMgpAVJVdW3d8Ca9OeMPYdE1iHJUki6GWhrHHgzO)cNWlHf()kOhhn9AhNcQAS4CYLRGEC00lYDVV4CYLRGEC00l6uKHPuOnywCo5YHdcZ(VkiDFA9cQmMpE3dyhEjCHdcZ()GygoVdW3RhSKlhL2dyhEjCr6jlHpnGzO(L)pkPrchDHUrIjJRNqXfoHxcl5YDaGubqXSq3iXKX1tO4cI(rpeMz8RWqC0gmKvPH4r5L6L7bSdVe66e(ivoc(O7ucHUUhjoK6b47bEoGEuYQG09PvMVMlhoim7)QG09P1lOYy(4DpGD4LWfoim7)dIz48oaFVEWsUCuApGD4LWfPNSe(0aMHQWqC0gmKvPH4r5L6LeecdflppWGpItVfD98)KWNgWmujuV6Att1pikcFbHeesppi6h9qOYe()84OPxKuFWxmLxPp4IZHpLkaDrqimuS88ad(io9w8va6s7Z2EYYLZdqi8P7SB9br)OhYfuZxUChaivaumlccHHILNhyWhXP3IRZDaZqYJgghTbtKyMkJlEw(YLJa4sE9uwjmkpV)p0TW3jHlCcVew4tjpoA6vcJYZ7)dDl8Ds4IZ5RWWMf7dfJyaAX(GMEhjIfQyx)W8kgrJZwIyaAXyQRlfCe7ZuuqIyaOyrw0drfJh8kMgWmujlHH4OnyiRsdXJYl1lPJ5bOFBNEhjU20u3dyhEjCXrWhDNsiK)ppoA61Dxk488srbjlIgNTmt96hoxUFuYb2ayR)FqGgAdg(ehmLEAaZqLSOJ5bOFBNEhjmtLh8sums6nwwqqgh(9RWWMf7dfJyaAX(GMEhjIPaXchN0FXOmyus)f7JanbmI10I1tC0EhfdmIfZFX0aMHQyHkMlftdygQKLWqC0gmKvPH4r5L6L0X8a0VTtVJexp)pj8Pbmdvc1RU20u3dyhEjCXrWhDNsiKpXbtPNgWmujl6yEa632P3rcZuDPWqC0gmKvPH4r5L6L45g0t2dIoW2pMIRnn19a2HxcxCe8r3Pec5FaGubqXS2XPGQgli6h9qy(ktegIJ2GHSknepkVuVm894i3U20u3dyhEjCXrWhDNsiK)p)GOi8fesqi98GOF0dHktYLZJJME5L6Pq6cU4C(kmSzXCp82ipHt7uOOykqSWXj9xmkdgL0FX(iqtaJyHkgJIPbmdvIWqC0gmKvPH4r5L6L(CANcfD98)KWNgWmujuV6AttDpGD4LWfhbF0DkHq(ehmLEAaZqLSOJ5bOFBNEhjuzuyioAdgYQ0q8O8s9sFoTtHIU20u3dyhEjCXrWhDNsiuyqyyZBwmkt4hzOyGDekM2(OyHxNATrIWWMfBtB)wfJYgqiqrIyGrSbmB0b2(Wa(xmnGzOseJgaftVrXCGna26FXGan0gmI10ILpEfZlHyHiwarXIeeJYFX4CegIJ2GHSkaL6Ea7WlHUoHpsLSTDEN)Ne(YcieOOR7rIdP6aBaS1)piqdTbdFIdMspnGzOsw0X8a0VTtVJeMDj)FfGUYcieO4cI(rpKloaqQaOywzbecuCv4GH2GjxohqtadwEEjeleMZ3xHHnl2M2(Tkw(X5OCqKigyeBaZgDGTpmG)ftdygQeXObqX0BumhydGT(xmiqdTbJynTy5JxX8siwiIfquSibXO8xmohHH4OnyiRcq5L6L7bSdVe66e(ivY225D(Fs4dY5OCq019iXHuDGna26)heOH2GHpXbtPNgWmujl6yEa632P3rcZUK)Vc6XrtVi39(IZjxohqtadwEEjeleMZ3xHHnl2M2(Tkw(X5OCqKiwtl2MGtbvn4L9U3VKNeefHIXuiKGq6rSMigNJyXueJcuS7yhfJrEfJGhWuiILqAvmWiMEJILFCokhefJYaCxyioAdgYQauEPE5Ea7WlHUoHpsLSTDEqohLdIUUhjoKAb94OPx74uqvJfNd)Ff0JJMErU79fNtUC(brr4liKGq65br)OhcZm5l)cqxqohLdIli6h9qyMrHHnlgRdE6ijgLnGqGIIftrS8JZr5GOyeu5CeZb2aOykqS83nsmzC9ekk2jiQWqC0gmKvbO8s9YSacbk6AttvJeo6cDJetgxpHIlCcVew4tj0nsmzC9ekwwzbecuKFbORSacbkUC85sA7KAeEb1R8paqQaOywOBKyY46juCbr)OhYfmYN4GP0tdygQKfDmpa9B707iH6v(WOlpChhDfLcz1dZ8u(fGUYcieO4cI(rpekNjR8DHgWmuxA7Jpf8knkmehTbdzvakVuVeY5OCq01MMQgjC0f6gjMmUEcfx4eEjSW)hstJhT3X3b47bEoGEucZupop)WThXbNc)daKkakMf6gjMmUEcfxq0p6HCXv(fGUGCokhexq0p6Hq5mzLVl0aMH6sBF8PGxPXVcdBwmkBaHaffJZzlIoUkwKiaXuyJeXuGyCeuSwfliIfIrCWthjXYWbHHcGIrdGIP3OyPGOITHpsmpKgarXcXO7Pj3iuyioAdgYQauEPEPdaKEqKa4Gh0vAa8nOBk1RcdXrBWqwfGYl1lZcieOORnnvisdrYD4Lq(hGVh45a6rjRcs3NwzM6v()C85sA7KAeEb1R5Ybr)OhYfu1(S9PTpYN4GP0tdygQKfDmpa9B707iHzQU8l)FucDJetgxpHILC5GOF0d5cQAF2(02hPCg5tCWu6PbmdvYIoMhG(TD6DKWmvx(L)pnGzOU02hFk4vACJq0p6H8LzEW3pikcFbHeesppi6h9qOYeHH4OnyiRcq5L6Loaq6brcGdEqxPbW3GUPuVkmehTbdzvakVuVmlGqGIUE(Fs4tdygQeQxDTPPsP9a2HxcxKTTZ78)KWxwaHaf5drAisUdVeY)a89aphqpkzvq6(0kZuVY)NJpxsBNuJWlOEnxoi6h9qUGQ2NTpT9r(ehmLEAaZqLSOJ5bOFBNEhjmt1LF5)JsOBKyY46juSKlhe9JEixqv7Z2N2(iLZiFIdMspnGzOsw0X8a0VTtVJeMP6YV8)Pbmd1L2(4tbVsJBeI(rpKVmFLr((brr4liKGq65br)OhcvMimSzX2aS9jGrm3rFhKOIbgX85sA7KqX0aMHkrSqfJh8k2g(iXO4ghXGCZ0tMyaovSEeJrIy)4CetbIXdX0aMHk5RyaOyUKi2V8XRyAaZqL8vyioAdgYQauEPE5b2(eW8u03bjQRnnvIdMspnGzOsyMkJ8HOF0d5cg59hXbtPNgWmujmtnFF5J004r7D8Da(EGNdOhLWmvEimSzX(Gq0rmohXYpohLdIIfQy8GxXaJyrkjMgWmujI9JIBCel179KjwcmzIHdGl7wSykInavmYeoKBG(vyioAdgYQauEPEjKZr5GORnnvkThWo8s4ISTDEqohLdI8)H004r7D8Da(EGNdOhLWmvEWhI0qKChEjmxokP9zBpz8)PTpY8vMKl3b47bEoGEucZuz87x()C85sA7KAeEb1R5Ybr)OhYfu1(S9PTpYN4GP0tdygQKfDmpa9B707iHzQU8l)FucDJetgxpHILC5GOF0d5cQAF2(02hPCg5tCWu6PbmdvYIoMhG(TD6DKWmvx(LVgWmuxA7Jpf8knUri6h9qyMhcdXrBWqwfGYl1lHCokheD98)KWNgWmujuV6AttLs7bSdVeUiBBN35)jHpiNJYbr(uApGD4LWfzB78GCokhe5J004r7D8Da(EGNdOhLWmvEWhI0qKChEjK)phFUK2oPgHxq9AUCq0p6HCbvTpBFA7J8joyk90aMHkzrhZdq)2o9osyMQl)Y)hLq3iXKX1tOyjxoi6h9qUGQ2NTpT9rkNr(ehmLEAaZqLSOJ5bOFBNEhjmt1LF5Rbmd1L2(4tbVsJBeI(rpeM)XdEHCdsdGz4QeK7EYEKdGBkqmr5FyEHCdsdGz4Qaa(EPOGuop9RWWMfBdW2NagXCh9DqIkgyeJ1DXAAX6rmNykOFFelMIydgW0FX8d3edheM9xSykI10IL)ZooaFXOamUqfRaeZharXkHFKHIv4qXuGyU)5L8eMIWqC0gmKvbO8s9YdS9jG5POVdsuxBAQehmLEAaZqLq9kFKMgpAVJVdW3d8Ca9OeMP(7488d3EehCkB86x(qKgIK7WlH8Pe6gjMmUEcfl8Pub94OPxK7EFX5W3pikcFbHeesppi6h9qOYe()WbHz)xfKUpTEbvgZhV7bSdVeUWbHz)FqmdN3b471dw(YxdygQlT9XNcELg3ie9JEimZdHbHHnVzXyvms6nweJPC0gmeHHnlwED2nrJ0wekgyeZLUZ0ITby7taJyUJ(oirfgIJ2GHSikgj9glupW2NaMNI(oirDTPPQrchDnD2Ts0iTfHlCcVew4tCWu6PbmdvcZuDj)dW3d8Ca9OeMPYd(AaZqDPTp(uWR04gHOF0dHzEQWWMflVo7MOrAlcfdmID1DMwm2jCi3avS8JZr5GOWqC0gmKfrXiP3yHxQxc5Cuoi6AttvJeo6A6SBLOrAlcx4eEjSW)a89aphqpkHzQ8GVgWmuxA7Jpf8knUri6h9qyMNkmSzXy58uesZLHmTymfhN0FXaqXYpKgIKBXOO1BX84OPXIyu2acbksegIJ2GHSikgj9gl8s9shai9GibWbpOR0a4Bq3uQxfgIJ2GHSikgj9gl8s9YSacbk665)jHpnGzOsOE11MMQgjC0fHZtrinxgUWj8syH)pi6h9qU4kJ5Y54ZL02j1i8cQx)YxdygQlT9XNcELg3ie9JEimZOWWMfJLZtrinxgkgVIL)UrYedmID1DMwS8dPHi5wmkBaHaffluX0BumCkIbOfJOyK0BXuGyzOkMF4MyfoyOnyeZdPbquS83nsmzC9ekkmehTbdzrums6nw4L6Loaq6brcGdEqxPbW3GUPuVkmehTbdzrums6nw4L6Lzbecu01MMQgjC0fHZtrinxgUWj8syHVgjC0f6gjMmUEcfx4eEjSWpoAVJpCq)gjuVY3JJMEr48uesZLHli6h9qU46YLcdXrBWqwefJKEJfEPEPpN2PqrxBAQAKWrxeopfH0Cz4cNWlHf(hGVh45a6rjxq1LcdcdBEZITjX0KBHHnl2hQNMClgfTElMF4MyB4JeJgaflVo7wjAK2IqxfJBsiHighPNmXOmyO3P)IXEhfafeHH4OnyiR9yAYn19a2HxcDDcFK60z3krJ0we(ooVdykT2GX19iXHu)rji3G0aygUkyO3P)pYDuauq4J004r7D8Da(EGNdOhLWm1JZZpC7rCWP8nxUFqUbPbWmCvWqVt)FK7OaOGW)a89aphqpk5cg)kmSzX2KyAYTyu06Ty5VBKmX4vS86SBLOrAlczAX4jHBTpNVyB4JelMIy5VBKmXGyu(lgnak2GUPIrz3aLryioAdgYApMMCZl1l3JPj3U20u1iHJUq3iXKX1tO4cNWlHf(AKWrxtNDRensBr4cNWlHf(7bSdVeUMo7wjAK2IW3X5DatP1gm8paqQaOywOBKyY46juCbr)OhYfxfg2SyBsmn5wmkA9wS86SBLOrAlcfJxXYdiw(7gjJPfJNeU1(C(ITHpsSykITj4uqvdX4CegIJ2GHS2JPj38s9Y9yAYTRnnvns4ORPZUvIgPTiCHt4LWcFkPrchDHUrIjJRNqXfoHxcl83dyhEjCnD2Ts0iTfHVJZ7aMsRny4xqpoA61oofu1yX5imehTbdzThttU5L6Loaq6brcGdEqxPbW3GUPuV6k6McJx4d4gLkpYNWqC0gmK1Emn5MxQxUhttUDTPPQrchDr48uesZLHlCcVew4FaGubqXSYcieO4IZH)VcqxzbecuCbrAisUdVeMlxb94OPx74uqvJfNd)cqxzbecuC54ZL02j1i8cQx)Y)a89aphqpkzvq6(0kZu)rCWu6PbmdvYIoMhG(TD6DKWmtL84lFy0LhUJJUIsHS6H5RmkmSzX2KyAYTyu06Ty8KGOiumMcHeKEyAXYpohLdI8szdieOOydqfRhXGinej3IbJjdDvSchSNmX2eCkOQbVS39(sm2)ZrmkA9wmw0H0eXO7jsID3QynTyoacP9s4syioAdgYApMMCZl1l3JPj3U20u)PrchD5hefHVGqccPNfoHxcl5Yb5gKgaZWLFa3(a0p9gF(brr4liKGq65lFkva6cY5OCqCbrAisUdVeYVa0vwaHafxq0p6HWSl5xqpoA61oofu1yX5W)xb94OPxK7EFX5Klxb94OPx74uqvJfe9JEixWJC5kaDrqhstwAF22t2x(fGUiOdPjli6h9qUWLvTQ1k]] )

end