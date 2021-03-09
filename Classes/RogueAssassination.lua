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
        --                     346975 - flagellation_cleanse (Get Mastery Buff)
        flagellation = {
            id = 323654,
            cast = 0,
            cooldown = PTR and 90 or 5,
            gcd = "spell",

            spend = PTR and 0 or 20,
            spendType = "energy",
            
            startsCombat = true,
            texture = 3565724,

            toggle = "essences",

            bind = not PTR and "flagellation_cleanse" or nil,

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
                },
            },
        },

        flagellation_cleanse = not PTR and {
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
        } or nil,


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


    spec:RegisterPack( "Assassination", 20210308, [[da1wccqiKGhPQGlPcu2eQQpHQOrPQ0PuvzvOG8kuLMfvs3sfWUuYVujAyOahtL0YqrEgvIMgQcxtujBJkb(gvczCiHsNtvHyDOG6DujOQ5Ps4EiP9HI6Fuji5GiHQfQQOhQcYercXfvbYgrcfFejKgjvcsDsvGQvIc9svfsMPOs1nPsO2POIHQcQwQOs5PO0uPs1vPsqzRQGYxPsqmwvfQ9kP)QkdMYHfwmv5Xk1KL4YqBgP(SOmAvQtl1QPsqLxRcnBrUnv1Uv8BGHtfhxvHulh0ZrmDsxhv2Uk67QQA8uPCEKO5lQA)exVwDVYwcfR5Wedy6kdCjdOyxmDLhUOC5cQSkLoyL1j2hJmSYoHpwzP4esqi9eAdMkRtqzceLQ7vwcGdUXk7TQoeg(YlZA9MZBTb(xsAFUuOny2WGwVK0(7lRSECDsp4t1RYwcfR5Wedy6kdCjdOyxmDLhUiE4YkBWP3ayLLT9puL9UlfCQEv2cs2vwkoHeespH2GrSCdKXHcJU4aUVfJI1vXyIbmDTYMAIsQUxzjkgj9glv3R5CT6ELfNWlHL6Nv2yRnyQSBy7taZtrFhKOv2cs2W2rBWuzZPZUjAKoIqXaJyU0DgwSdbBFcyeZD03bjALDdBfHDuz1iHJUMo7wjAKoIWfoHxclIXxmIdMspnGzOseJzQI5sX4l2g47bEoGEuIymtvmEigFX0aMH6sBF8PGxPrXoGyq0p6HigZI5cQAnhMQUxzXj8syP(zLn2AdMklKZr5GyLTGKnSD0gmv2C6SBIgPJiumWi2v3zyXyNWHCduXYnohLdIv2nSve2rLvJeo6A6SBLOr6icx4eEjSigFX2aFpWZb0JseJzQIXdX4lMgWmuxA7Jpf8knk2bedI(rpeXywmxqvR54YQ7vwCcVewQFwzJT2GPY6aaPhejao4gRSfKSHTJ2GPYYY5PiKMldzyXO4oojkfdafl3qAisUf7FR3I5XrtJfXOObecuKuzPbW3GUP1CUw1Ao8O6ELfNWlHL6Nv2yRnyQSzbecuSYUHTIWoQSAKWrxeopfH0Cz4cNWlHfX4l2xXGOF0drSle7ktILpVyo(CjTDsncf7cQIDvSFIXxmnGzOU02hFk4vAuSdige9JEiIXSymvz3uUt4tdygQKAoxRAnNCvDVYIt4LWs9ZkBS1gmvwhai9GibWb3yLTGKnSD0gmvwwopfH0CzOy8k2b5gjtmWi2v3zyXYnKgIKBXOObecuuSqftVrXWPigGwmIIrsVftbILHQy(HBIv4GH2GrmpKgarXoi3iXKX1tOyLLgaFd6MwZ5AvR54cQUxzXj8syP(zLDdBfHDuz1iHJUiCEkcP5YWfoHxclIXxmns4Ol0nsmzC9ekUWj8syrm(IfBTpXhoOFJeXOk2vX4lMhhn9IW5PiKMldxq0p6Hi2fIDD5YkBS1gmv2Sacbkw1AoUOQ7vwCcVewQFwz3Wwryhvwns4OlcNNIqAUmCHt4LWIy8fBd89aphqpkrSlOkMlRSXwBWuz950ofkw1QwzpJPj3v3R5CT6ELfNWlHL6NvwGtLLGALn2AdMk7za7WlHv2ZiXHv2VIrbXGCdsdGz4QGHENO8rUJc4pzHt4LWIy8fdPPXT2N4Bd89aphqpkrmMPk2255hU9io4ue7Ny5Zl2xXGCdsdGz4QGHENO8rUJc4pzHt4LWIy8fBd89aphqpkrSleJjX(vzlizdBhTbtLLIPNMCl2)wVfZpCtSdD4IrdGILtNDRenshrORIXnjKqeJJ0tMyuem07eLIXEhfWFsL9mGVj8Xk70z3krJ0re(2oVnykT2GPQ1CyQ6ELfNWlHL6Nv2yRnyQSNX0K7kBbjBy7OnyQShwmn5wS)TEl2b5gjtmEflNo7wjAKoIqgwmxC4w7Z5l2HoCXIPi2b5gjtmigfkfJgafBq3uXOOhIIuz3Wwryhvwns4Ol0nsmzC9ekUWj8syrm(IPrchDnD2Ts0iDeHlCcVeweJVyNbSdVeUMo7wjAKoIW325TbtP1gmIXxSnaKkG)ZcDJetgxpHIli6h9qe7cXUw1AoUS6ELfNWlHL6Nv2yRnyQSNX0K7kBbjBy7OnyQShwmn5wS)TElwoD2Ts0iDeHIXRy5ae7GCJKXWI5Id3AFoFXo0HlwmfXomCkOQHyCov2nSve2rLvJeo6A6SBLOr6icx4eEjSigFXOGyAKWrxOBKyY46juCHt4LWIy8f7mGD4LW10z3krJ0re(2oVnykT2Grm(IvqpoA61jofu1yX5u1Ao8O6ELfNWlHL6Nv2yRnyQSoaq6brcGdUXkl6McJx4d4gTYYJCvzPbW3GUP1CUw1Ao5Q6ELfNWlHL6Nv2nSve2rLvJeo6IW5PiKMldx4eEjSigFX2aqQa(pRSacbkU4CeJVyFfRa0vwaHafxqKgIK7WlHILpVyf0JJMEDItbvnwCoIXxScqxzbecuC54ZL02j1iuSlOk2vX(jgFX2aFpWZb0JswfKU3TkgZuf7RyehmLEAaZqLSOJ5bOFhN(ejIXSluIXdX(jgFXGrxE4jo6kkfYQhXywSRmvzJT2GPYEgttURAnhxq19kloHxcl1pRSXwBWuzpJPj3v2cs2W2rBWuzpSyAYTy)B9wmxCquekgfNqcspmSy5gNJYbrEPObecuuSbOI1JyqKgIKBXGXKHUkwHd2tMyhgofu1Gx27(CjglLZwS)TElgl6qAIy09ejXUBvSMwmhaH0EjCvz3Wwryhv2VIPrchD5hefHVGqccPNfoHxclILpVyqUbPbWmC5hWJpa9tVXNFque(ccjiKEw4eEjSi2pX4lgfeRa0fKZr5G4cI0qKChEjum(Iva6klGqGIli6h9qeJzXCPy8fRGEC00RtCkOQXIZrm(I9vSc6XrtVi395IZrS85fRGEC00RtCkOQXcI(rpeXUqmEiw(8Iva6IGoKMS0EFSNmX(jgFXkaDrqhstwq0p6Hi2fI5YQw1kBbPdUKwDVMZ1Q7v2yRnyQSh79XkloHxcl1pRAnhMQUxzXj8syP(zLTGKnSD0gmv2Cdjkgj9wSMwmhaH0EjuSVdqStU0GWWlHIHd63irSEeBd89c9xLn2AdMklrXiP3vTMJlRUxzXj8syP(zLf4uzjOwzJT2GPYEgWo8syL9msCyLfheMr5cIz4igVI5aAcyWYZlHyHigdj2xXCrIXRyokuSFIDPyFfJjXyiXioyk9UdIII9RYEgW3e(yLfheMr5dIz482aFVEWsvR5WJQ7vwCcVewQFwzbovwcQv2yRnyQSNbSdVewzpJehwzjoyk90aMHkzrhZdq)oo9jse7cXyQYEgW3e(yLL0twcFAaZqTQ1CYv19kloHxcl1pRSByRiSJkBb94OPx0PidtPqBWSGOF0drSleJPkBS1gmvw6uKHPuOnyE7egdbRAnhxq19kloHxcl1pRSByRiSJklrXiP3yzbbzCyLn2AdMk7osPxS1gmVut0kBQj6BcFSYsums6nwQAnhxu19kloHxcl1pRSByRiSJk7xXOGyAKWrx(brr4liKGq6zHt4LWIy5ZlwbORSacbkU0EFSNmX(vzJT2GPYUJu6fBTbZl1eTYMAI(MWhRS7cPQ1COyRUxzXj8syP(zLDdBfHDuzPGyokum(IrCWu6PbmdvYIoMhG(DC6tKi2fuf7Ry5sSdigKBqAamdxLGC3t2JSbCtbIPfoHxclI9tm(I5XrtViPEJVykVsVXfe9JEiIDHy0D2T(GOF0drm(IbrAisUdVekgFX2aFpWZb0JseJzQI5YkBS1gmvwsQ34lMYR0BSQ1C(iv3RS4eEjSu)SYgBTbtLLK6n(IP8k9gRSfKSHTJ2GPYE4CQySdfrmohX6P1osjkfJgaf7qCQykqm9gf7q3bbDvmisdrYTy)B9wSdAoXb4lwtlwOILa)fRWbdTbtLDdBfHDuzDuOy8fJcI5XrtViPEJVykVsVXfNJy8fBd89aphqpkrmMPkMlRAnNRmO6ELfNWlHL6Nv2nSve2rL1rHIXxmpoA6fj1B8ft5v6nU4CeJVyEC00lsQ34lMYR0BCbr)OhIyxiwUeJVyBGVh45a6rjIXmvX4rLn2AdMkloN4a8RAnNRxRUxzXj8syP(zLn2AdMk7osPxS1gmVut0kBQj6BcFSYwaAvR5CLPQ7vwCcVewQFwzJT2GPYUJu6fBTbZl1eTYMAI(MWhRSLgIBTQ1CU6YQ7vwCcVewQFwz3WwryhvwCqygLRcs37wfJzQIDnxIXRyNbSdVeUWbHzu(GygoVnW3RhSuzJT2GPYgWDm4tbqioAvR5CLhv3RSXwBWuzd4og85WLiyLfNWlHL6NvTMZ1CvDVYgBTbtLn1z3k55chxjZhhTYIt4LWs9ZQwZ5QlO6ELn2AdMkRxK9a0pf27JKkloHxcl1pRAvRSoqCd89cT6EnNRv3RSXwBWuzdhNeLphqtatLfNWlHL6NvTMdtv3RSXwBWuz9aQMWYJofuIL)9K9uGB9uzXj8syP(zvR54YQ7vwCcVewQFwzJT2GPY6hWJy5rdGVcg6DLDdBfHDuzHrxE4jo6kkfYQhXywSR5QY6aXnW3l0hb3GPqQS5QQ1C4r19kloHxcl1pRSaNklb1kBS1gmv2Za2HxcRSNb8nHpwzvyphr9rOC2pscOv2nSve2rLvH9Ce1LEDDhKhrdDfdLVIdrm(I9vmkiMc75iQlLP1DqEen0vmu(koeXYNxmf2Zrux611gasfW)zv4GH2GrmMPkMc75iQlLP1gasfW)zv4GH2GrSFv2cs2W2rBWuzPiOIq)EqX(F37BX(20IfdL)eJOHkMhhnTykSNJOk2FuS)XOIPaXcvrFhvmfigHYzl2)wVf7WWPGQgRk7zK4Wk71QwZjxv3RS4eEjSu)SYcCQSeuRSXwBWuzpdyhEjSYEgjoSYYuLDdBfHDuzvyphrDPmTUdYJOHUIHYxXHigFX(kgfetH9Ce1LEDDhKhrdDfdLVIdrS85ftH9Ce1LY0AdaPc4)SkCWqBWigZIPWEoI6sVU2aqQa(pRchm0gmI9RYEgW3e(yLvH9Ce1hHYz)ijGw1AoUGQ7v2yRnyQSefJKExzXj8syP(zvR54IQUxzXj8syP(zLn2AdMklj1B8ft5v6nwz3WwryhvwisdrYD4LWkRde3aFVqFeCdMcPYETQvTYwAiU1Q71CUwDVYIt4LWs9ZkBS1gmvwCoXb4xzlizdBhTbtL9GMtCa(IfQy8GxX(MlEf7FR3Irry)j2Ho8LyhCFFS0HIjkfdmIXeVIPbmdvIRI9V1BXomCkOQHRIbGI9V1BXC)txfdO3i8FtqX(hTkgnakgb4JIHdcZOCjgfpraI9pAvSMwSdYnsMyBGVhqSMi2g43tMyCoRk7g2kc7OYI004w7t8Tb(EGNdOhLigZufJhIXRyAKWrxfeDq4JOWqJm0FHt4LWIy8f7Ryf0JJMEDItbvnwCoILpVyf0JJMErU7ZfNJy5Zlwb94OPx0PidtPqBWS4CelFEXWbHzuUkiDVBvSlOkgt5smEf7mGD4LWfoimJYheZW5Tb(E9GfXYNxmki2za7WlHlspzj8PbmdvX(jgFX(kgfetJeo6cDJetgxpHIlCcVewelFEX2aqQa(pl0nsmzC9ekUGOF0drmMfJjX(v1AomvDVYIt4LWs9ZklWPYsqTYgBTbtL9mGD4LWk7zK4Wk7g47bEoGEuYQG09UvXywSRILpVy4GWmkxfKU3Tk2fufJPCjgVIDgWo8s4cheMr5dIz482aFVEWIy5Zlgfe7mGD4LWfPNSe(0aMHAL9mGVj8XklhbF0DkHWQwZXLv3RS4eEjSu)SYgBTbtLLGqyOy55bg8rC6JyLDdBfHDuz9dIIWxqibH0ZdI(rpeXOkgdeJVyFfZJJMErs9gFXuELEJlohX4lgfeRa0fbHWqXYZdm4J40hXxbOlT3h7jtS85fZdqiIXxm6o7wFq0p6Hi2fuflxILpVyBaiva)NfbHWqXYZdm4J40hX1(oGzi5rdJT2GjsIXmvXyA5IYLy5ZlgbWL86PSsyuEEu(q3cFNeUWj8syrm(IrbX84OPxjmkppkFOBHVtcxCoI9RYUPCNWNgWmuj1CUw1Ao8O6ELfNWlHL6Nv2yRnyQS0X8a0VJtFIKkBbjBy7OnyQSumXigGwSpQPprIyHk21pcVIr0yFKigGwmxO7sbhX(mffKigakwKf9quX4bVIPbmdvYQYUHTIWoQSNbSdVeU4i4JUtjekgFX(kMhhn96UlfCEEPOGKfrJ9rXyMQyx)iILpVyFfJcI5aBaSvkFqGgAdgX4lgXbtPNgWmujl6yEa63XPprIymtvmEigVIrums6nwwqqghk2pX(v1Ao5Q6ELfNWlHL6Nv2yRnyQS0X8a0VJtFIKk7MYDcFAaZqLuZ5ALDdBfHDuzpdyhEjCXrWhDNsium(IrCWu6PbmdvYIoMhG(DC6tKigZufZLv2cs2W2rBWuzPyIrmaTyFutFIeXuGyHJtIsXOiyusuk2HdAcyeRPfRNyR9jkgyelgkftdygQIfQyUumnGzOswvTMJlO6ELfNWlHL6Nv2nSve2rL9mGD4LWfhbF0DkHqX4l2gasfW)zDItbvnwq0p6HigZIDLbv2yRnyQS4(g0t2dIoW2pMsvR54IQUxzXj8syP(zLDdBfHDuzpdyhEjCXrWhDNsium(I9vm)GOi8fesqi98GOF0drmQIXaXYNxmpoA6LxQNcPl4IZrSFv2yRnyQSHVhh5UQ1COyRUxzXj8syP(zLn2AdMkRpN2PqXk7MYDcFAaZqLuZ5ALDdBfHDuzpdyhEjCXrWhDNsium(IrCWu6PbmdvYIoMhG(DC6tKigvXyQYwqYg2oAdMkR7H3bCXCANcfftbIfoojkfJIGrjrPyhoOjGrSqfJjX0aMHkPQ1C(iv3RS4eEjSu)SYUHTIWoQSNbSdVeU4i4JUtjewzJT2GPY6ZPDkuSQvTYUlKQ71CUwDVYIt4LWs9ZkBS1gmvw)aEelpAa8vWqVRSBk3j8PbmdvsnNRv2nSve2rLfgD5HN4OROuilohX4l2xX0aMH6sBF8PGxPrXUqSnW3d8Ca9OKvbP7DRIXqIDDLlXYNxSnW3d8Ca9OKvbP7DRIXmvX2op)WThXbNIy)QSfKSHTJ2GPYEWPflkfIybefJZXvXit7GIP3OyGbf7FR3ILa)rIkM7UtrwI5cJGI9)ghXku2tMy0brrOy6DmIDOdxScs37wfdaf7FR3aovSyOuSdD4RQwZHPQ7vwCcVewQFwzJT2GPY6hWJy5rdGVcg6DLTGKnSD0gmv2doTydqSOuiI9VtjXknk2)wV7rm9gfBq3uXCjdiUkghbfZfttredmI5bieX(36nGtflgkf7qh(QYUHTIWoQSWOlp8ehDfLcz1JymlMlzGyhqmy0LhEIJUIsHSkCWqBWigFX2aFpWZb0JswfKU3TkgZufB788d3EehCkvTMJlRUxzXj8syP(zLn2AdMklDkYWuk0gmv2cs2W2rBWuzzPC2IrXKImmLcTbJy)B9wSddNcQAiwqelbMmXcIy)rX(dgEQILaeuSqSDquXaNium9gfJUZUvXkCWqBWuz3WwryhvwkigrXiP3yzbbzCOy8f7RyBaiva)N1jofu1ybr)OhIyxiMlfJVyinnU1(eFBGVh45a6rjIXmvX4Hy8ftdygQlT9XNcELgfJzXUYaXYNxSc6XrtVoXPGQglohXYNxmpaHigFXO7SB9br)OhIyxigt8qSFvTMdpQUxzXj8syP(zLDdBfHDuzPGyefJKEJLfeKXHIXxmKMg3AFIVnW3d8Ca9OeXyMQy8qm(I9vm6eaaf7RyFfJUZU1he9JEiIDaXyIhI9tSlfl2AdM3gasfW)rSFIXSy0jaak2xX(kgDNDRpi6h9qe7aIXepe7aITbGub8FwN4uqvJfe9JEiIXqIDgWo8s46eNcQA82fOy)e7sXIT2G5TbGub8Fe7Ny)QSXwBWuzPtrgMsH2GPQ1CYv19kloHxcl1pRSByRiSJklfeZrHIXxSc6XrtVOtrgMsH2Gzbr)OhIyxigtv2yRnyQS0PidtPqBW82jmgcw1AoUGQ7vwCcVewQFwzJT2GPYsqhstQSfKSHTJ2GPYYs5SfJfDinrS)TEl2HHtbvneliILatMybrS)Oy)bdpvXsackwi2oiQyGtekMEJIr3z3QyfoyOnyCvmpovmhisJqX0aMHkrm9ouX(3PKyP(efluXsyquXUYasLDdBfHDuzPGyefJKEJLfeKXHIXxSVITbGub8FwN4uqvJfe9JEiIDHyxfJVyAaZqDPTp(uWR0Oyml2vgiw(8IvqpoA61jofu1yX5iw(8Ir3z36dI(rpeXUqSRmqSFvTMJlQ6ELfNWlHL6Nv2nSve2rLLcIrums6nwwqqghkgFX(kgDcaGI9vSVIr3z36dI(rpeXoGyxzGy)e7sXIT2G5TbGub8Fe7NymlgDcaGI9vSVIr3z36dI(rpeXoGyxzGyhqSnaKkG)Z6eNcQASGOF0drmgsSZa2HxcxN4uqvJ3Uaf7NyxkwS1gmVnaKkG)Jy)e7xLn2AdMklbDinPQ1COyRUxzXj8syP(zLf4uzjOwzJT2GPYEgWo8syL9msCyLLcIPrchDnD2Ts0iDeHlCcVewelFEXOGyAKWrxOBKyY46juCHt4LWIy5Zl2gasfW)zHUrIjJRNqXfe9JEiIDHy5sSdigtIXqIPrchDvq0bHpIcdnYq)foHxclv2cs2W2rBWuzzPC2IDy4uqvdX(3tb8xS)TElwoD2Ts0iDeH8EqUrIjJRNqrXAAXchNuVdVewzpd4BcFSYEItbvnEtNDRenshr4BdMsRnyQAnNps19kloHxcl1pRSaNklb1kBS1gmv2Za2HxcRSNb8nHpwzpXPGQgVn4eNy03gmLwBWuz3Wwryhv2n4eNy01rkHDmILpVyBWjoXORb3qqcalILpVyBWjoXORbmyLTGKnSD0gmvwwkNTyhgofu1qS)TElgftkYWuk0gmIftrmw0H0eXcIyjWKjwqe7pk2FWWtvSeGGIfITdIkg4eHIP3Oy0D2TkwHdgAdMk7zK4Wk71QwZ5kdQUxzXj8syP(zLf4uzjOwzJT2GPYEgWo8syL9msCyLLobaqX(k2xXO7SB9br)OhIyhqmMyGy)e7sX(k2vMyGymKyNbSdVeUoXPGQgVDbk2pX(jgZIrNaaOyFf7Ry0D2T(GOF0drSdigtmqSdi2gasfW)zrNImmLcTbZcI(rpeX(j2LI9vSRmXaXyiXodyhEjCDItbvnE7cuSFI9tS85fZJJMErNImmLcTbZZJJMEX5iw(8IvqpoA6fDkYWuk0gmlohXYNxm6o7wFq0p6Hi2fIXedQSByRiSJk7gCItm66eh9MsyL9mGVj8Xk7jofu14TbN4eJ(2GP0AdMQwZ561Q7vwCcVewQFwzbovwcQv2yRnyQSNbSdVewzpJehwzPtaauSVI9vm6o7wFq0p6Hi2beJjgi2pXUuSVIDLjgigdj2za7WlHRtCkOQXBxGI9tSFIXSy0jaak2xX(kgDNDRpi6h9qe7aIXede7aITbGub8Fwe0H0Kfe9JEiI9tSlf7RyxzIbIXqIDgWo8s46eNcQA82fOy)e7Ny5ZlwbOlc6qAYs79XEYelFEXO7SB9br)OhIyxigtmOYUHTIWoQSBWjoXORPZU1hDGv2Za(MWhRSN4uqvJ3gCItm6BdMsRnyQAnNRmvDVYIt4LWs9Zk7g2kc7OYsbXikgj9glliiJdfJVyfGUGCokhexAVp2tMy8fJcIvqpoA61jofu1yX5igFXodyhEjCDItbvnEtNDRenshr4BdMsRnyeJVyNbSdVeUoXPGQgVn4eNy03gmLwBWuzJT2GPYEItbvnQAnNRUS6ELfNWlHL6Nv2yRnyQSOBKyY46juSYwqYg2oAdMk7b5gjMmUEcff7)noInavmIIrsVXIyXueZdO3ILBCokheflMIyu0acbkkwarX4CeJgaflbMmXWbWLDVQSByRiSJklfeJOyK0BSSGGmoum(I9vmkiwbORSacbkUGinej3HxcfJVyfGUGCokhexq0p6HigZIXdX4vmEigdj2255hU9io4uelFEXkaDb5CuoiUGOF0drmgsmgSYLymlMgWmuxA7Jpf8knk2pX4lMgWmuxA7Jpf8knkgZIXJQwZ5kpQUxzXj8syP(zLn2AdMkl5UpRSfKSHTJ2GPYYE3NI10I9hflGOyHhGtftbIDqZjoaFxflMIyHQOVJkMceJq5Sf7FR3IXIoKMigDprsS7wfRPf7pk2FWWtvS)brrX8bqum9ogXUJeTy6nk2gasfW)zvz3Wwryhv2cqxqohLdIlT3h7jtm(I9vmki2gasfW)zrqhstwqmkukw(8ITbGub8FwN4uqvJfe9JEiIXSyxzsSFILpVyfGUiOdPjlT3h7jRQ1CUMRQ7vwCcVewQFwz3WwryhvwpoA6LxcakjoIUGySvXYNxmpaHigFXO7SB9br)OhIyxiMlzGy5Zlwb94OPxN4uqvJfNtLn2AdMkRdqBWu1AoxDbv3RS4eEjSu)SYUHTIWoQSf0JJMEDItbvnwCov2yRnyQSEjaO8O5Guw1AoxDrv3RS4eEjSu)SYUHTIWoQSf0JJMEDItbvnwCov2yRnyQSEiKGWJ9Kv1AoxPyRUxzXj8syP(zLDdBfHDuzlOhhn96eNcQAS4CQSXwBWuzPBi6LaGsvR5C9JuDVYIt4LWs9Zk7g2kc7OYwqpoA61jofu1yX5uzJT2GPYgZgjkmsVDKsvTMdtmO6ELfNWlHL6Nv2nSve2rLLcIrums6nwwrkjgFX8dIIWxqibH0ZdI(rpeXOkgdQSXwBWuz3rk9IT2G5LAIwztnrFt4Jv2ZyAYDvR5W01Q7vwCcVewQFwzJT2GPYQWEoI61kBbjBy7OnyQSSuoBX0BumhydGTsPyenuX84OPftH9CevX(36Tyhgofu1WvXa6nc)3eumockgyeBdaPc4)uz3Wwryhv2Za2HxcxkSNJO(iuo7hjbuXOk2vX4l2xXkOhhn96eNcQAS4CelFEX8aeIy8fJUZU1he9JEiIDbvXyIbI9tS85f7RyNbSdVeUuyphr9rOC2pscOIrvmMeJVyuqmf2ZruxktRnaKkG)ZcIrHsX(jw(8IrbXodyhEjCPWEoI6Jq5SFKeqRAnhMyQ6ELfNWlHL6Nv2nSve2rL9mGD4LWLc75iQpcLZ(rsavmQIXKy8f7Ryf0JJMEDItbvnwCoILpVyEacrm(Ir3z36dI(rpeXUGQymXaX(jw(8I9vSZa2HxcxkSNJO(iuo7hjbuXOk2vX4lgfetH9Ce1LEDTbGub8Fwqmkuk2pXYNxmki2za7WlHlf2ZruFekN9JKaALn2AdMkRc75iQmv1QwzlaT6EnNRv3RS4eEjSu)SYcCQSeuRSXwBWuzpdyhEjSYEgjoSY6aBaSvkFqGgAdgX4lgXbtPNgWmujl6yEa63XPprIymlMlfJVyFfRa0vwaHafxq0p6Hi2fITbGub8FwzbecuCv4GH2GrS85fZb0eWGLNxcXcrmMflxI9RYwqYg2oAdMkBU3(TkgfnGqGIeXaJydyoGdS9HbKsX0aMHkrmAaum9gfZb2ayRukgeOH2GrSMwSCXRyEjeleXcikwKGyuOumoNk7zaFt4JvwYX25TPCNWxwaHafRAnhMQUxzXj8syP(zLf4uzjOwzJT2GPYEgWo8syL9msCyL1b2ayRu(Gan0gmIXxmIdMspnGzOsw0X8a0VJtFIeXywmxkgFX(kwb94OPxK7(CX5iw(8I5aAcyWYZlHyHigZILlX(vzlizdBhTbtLn3B)wfl34CuoisedmInG5aoW2hgqkftdygQeXObqX0BumhydGTsPyqGgAdgXAAXYfVI5LqSqelGOyrcIrHsX4CQSNb8nHpwzjhBN3MYDcFqohLdIvTMJlRUxzXj8syP(zLf4uzjOwzJT2GPYEgWo8syL9msCyLTGEC00RtCkOQXIZrm(I9vSc6XrtVi395IZrS85fZpikcFbHeesppi6h9qeJzXyGy)eJVyfGUGCokhexq0p6HigZIXuLTGKnSD0gmv2CV9BvSCJZr5GirSMwSddNcQAWl7DFEPloikcfJItibH0JynrmohXIPi2FuS74efJjEfJGBWuiILqAvmWiMEJILBCokhefJIaCVYEgW3e(yLLCSDEqohLdIvTMdpQUxzXj8syP(zLn2AdMkBwaHafRSfKSHTJ2GPYY6G7osIrrdieOOyXuel34CuoikgbvohXCGnakMce7GCJetgxpHIITdIwz3Wwryhvwns4Ol0nsmzC9ekUWj8syrm(IrbXkOhhn9klGqGIl0nsmzC9ekweJVyfGUYcieO4YXNlPTtQrOyxqvSRIXxSnaKkG)ZcDJetgxpHIli6h9qe7cXysm(IrCWu6PbmdvYIoMhG(DC6tKigvXUkgFXGrxE4jo6kkfYQhXywmxGy8fRa0vwaHafxq0p6Higdjgdw5sSletdygQlT9XNcELgRAnNCvDVYIt4LWs9Zk7g2kc7OYQrchDHUrIjJRNqXfoHxclIXxSVIH004w7t8Tb(EGNdOhLigZufB788d3EehCkIXxSnaKkG)ZcDJetgxpHIli6h9qe7cXUkgFXkaDb5CuoiUGOF0drmgsmgSYLyxiMgWmuxA7Jpf8knk2VkBS1gmvwiNJYbXQwZXfuDVYIt4LWs9ZkBS1gmvwhai9GibWb3yLTGKnSD0gmvwkAaHaffJZ5iIoUkwKiaXuyJeXuGyCeuSwfliIfIrCWDhjXYWbHHcGIrdGIP3OyPGOIDOdxmpKgarXcXO7Pj3iSYsdGVbDtR5CTQ1CCrv3RS4eEjSu)SYUHTIWoQSqKgIK7WlHIXxSnW3d8Ca9OKvbP7DRIXmvXUkgFX(kMJpxsBNuJqXUGQyxflFEXGOF0drSlOkM27JpT9rX4lgXbtPNgWmujl6yEa63XPprIymtvmxk2pX4l2xXOGyOBKyY46juSiw(8Ibr)OhIyxqvmT3hFA7JIXqIXKy8fJ4GP0tdygQKfDmpa9740NirmMPkMlf7Ny8f7RyAaZqDPTp(uWR0Oyhqmi6h9qe7NymlgpeJVy(brr4liKGq65br)OhIyufJbv2yRnyQSzbecuSQ1COyRUxzXj8syP(zLLgaFd6MwZ5ALn2AdMkRdaKEqKa4GBSQ1C(iv3RS4eEjSu)SYgBTbtLnlGqGIv2nSve2rLLcIDgWo8s4ICSDEBk3j8LfqiqrX4lgePHi5o8sOy8fBd89aphqpkzvq6E3QymtvSRIXxSVI54ZL02j1iuSlOk2vXYNxmi6h9qe7cQIP9(4tBFum(IrCWu6PbmdvYIoMhG(DC6tKigZufZLI9tm(I9vmkig6gjMmUEcflILpVyq0p6Hi2fuft79XN2(OymKymjgFXioyk90aMHkzrhZdq)oo9jseJzQI5sX(jgFX(kMgWmuxA7Jpf8knk2bedI(rpeX(jgZIDLjX4lMFque(ccjiKEEq0p6HigvXyqLDt5oHpnGzOsQ5CTQ1CUYGQ7vwCcVewQFwzJT2GPYUHTpbmpf9DqIwzlizdBhTbtL9qW2NagXCh9DqIkgyeZNlPTtcftdygQeXcvmEWRyh6Wf7)noIb5MPNmXaCQy9igteX(Y5iMceJhIPbmdvYpXaqXCjrSV5IxX0aMHk5xLDdBfHDuzjoyk90aMHkrmMPkgtIXxmi6h9qe7cXysmEf7RyehmLEAaZqLigZuflxI9tm(IH004w7t8Tb(EGNdOhLigZufJhvTMZ1Rv3RS4eEjSu)SYgBTbtLfY5OCqSYwqYg2oAdMk7hfIoIX5iwUX5OCquSqfJh8kgyelsjX0aMHkrSV)VXrSuF2tMyjWKjgoaUSBXIPi2auXit4qUb6Vk7g2kc7OYsbXodyhEjCro2opiNJYbrX4l2xXqAACR9j(2aFpWZb0JseJzQIXdX4lgePHi5o8sOy5Zlgfet79XEYeJVyFftBFumMf7kdelFEX2aFpWZb0JseJzQIXKy)e7Ny8f7Ryo(CjTDsncf7cQIDvS85fdI(rpeXUGQyAVp(02hfJVyehmLEAaZqLSOJ5bOFhN(ejIXmvXCPy)eJVyFfJcIHUrIjJRNqXIy5Zlge9JEiIDbvX0EF8PTpkgdjgtIXxmIdMspnGzOsw0X8a0VJtFIeXyMQyUuSFIXxmnGzOU02hFk4vAuSdige9JEiIXSy8OQ1CUYu19kloHxcl1pRSXwBWuzHCokheRSByRiSJklfe7mGD4LWf5y782uUt4dY5OCqum(IrbXodyhEjCro2opiNJYbrX4lgstJBTpX3g47bEoGEuIymtvmEigFXGinej3HxcfJVyFfZXNlPTtQrOyxqvSRILpVyq0p6Hi2fuft79XN2(Oy8fJ4GP0tdygQKfDmpa9740NirmMPkMlf7Ny8f7Ryuqm0nsmzC9ekwelFEXGOF0drSlOkM27JpT9rXyiXysm(IrCWu6PbmdvYIoMhG(DC6tKigZufZLI9tm(IPbmd1L2(4tbVsJIDaXGOF0drmMf7Ry8qmEfdYninaMHRsqU7j7r2aUPaX0cNWlHfXyiX(iIXRyqUbPbWmCvaaFVuuWfoHxclIXqI5ce7xLDt5oHpnGzOsQ5CTQ1CU6YQ7vwCcVewQFwzJT2GPYUHTpbmpf9DqIwzlizdBhTbtL9qW2NagXCh9DqIkgyeJ1DXAAX6rmNykOFVflMIydgWeLI5hUjgoimJsXIPiwtl2bnN4a8f7py4PkwbiMpaIIvc)idfRWHIPaXC)ZlDXu8k7g2kc7OYsCWu6PbmdvIyuf7Qy8fdPPXT2N4Bd89aphqpkrmMPk2xX2op)WThXbNIyhqSRI9tm(IbrAisUdVekgFXOGyOBKyY46juSigFXOGyf0JJMErU7ZfNJy8fZpikcFbHeesppi6h9qeJQymqm(I9vmCqygLRcs37wf7cQIXuUeJxXodyhEjCHdcZO8bXmCEBGVxpyrSFIXxmnGzOU02hFk4vAuSdige9JEiIXSy8OQvTQv2tesAWuZHjgW0vg4sg4IQS)d40tgPY6cHINB5CWZHIYWIjM73OyTVdaQIrdGIXZZyAYnpfdIF0CnelIra(OybNc8dflITVJjdjlHXCVhuSRmSyhcmNiuXIy8eYninaMHRpMNIPaX4jKBqAamdxF8cNWlHfEk2xMC73sym37bfZfWWIDiWCIqflIXti3G0aygU(yEkMceJNqUbPbWmC9XlCcVew4PyFV62VLWOWOlekEULZbphkkdlMyUFJI1(oaOkgnakgpliDWLuEkge)O5AiweJa8rXcof4hkweBFhtgswcJ5EpOyUKHf7qG5eHkweJT9pKyekhnCtSdMykqSCNleR0NnPbJyahegkak23l)j23RU9BjmM79GILlgwmxydHZXbavSiwS1gmIXt6uKHPuOnyE7egdb55sym37bfJILHf7qG5eHkweJNqUbPbWmC9X8umfigpHCdsdGz46Jx4eEjSWtX(E1TFlHrHrxiu8ClNdEouugwmXC)gfR9DaqvmAaumE6aXnW3luEkge)O5AiweJa8rXcof4hkweBFhtgswcJ5EpOy8GHf7qG5eHkweJNkSNJOUUU(yEkMceJNkSNJOU0RRpMNI9Lj3(TegZ9EqX4bdl2HaZjcvSigpvyphrDX06J5PykqmEQWEoI6szA9X8uSVm52VLWyU3dkwUyyXoeyorOIfX4Pc75iQRRRpMNIPaX4Pc75iQl966J5PyFzYTFlHXCVhuSCXWIDiWCIqflIXtf2ZruxmT(yEkMceJNkSNJOUuMwFmpf7ltU9Bjmkm6cHINB5CWZHIYWIjM73OyTVdaQIrdGIXZDHWtXG4hnxdXIyeGpkwWPa)qXIy77yYqYsym37bfJhmSyhcmNiuXIyST)HeJq5OHBIDWetbIL7CHyL(Sjnyed4GWqbqX(E5pX(YKB)wcJ5EpOy5IHfZf2q4CCaqflIfBTbJy8KofzykfAdM3oHXqqEUegZ9EqXCrmSyhcmNiuXIyST)HeJq5OHBIDWetbIL7CHyL(Sjnyed4GWqbqX(E5pX(YKB)wcJ5EpOyxzadl2HaZjcvSigB7FiXiuoA4MyhmXuGy5oxiwPpBsdgXaoimuauSVx(tSVm52VLWyU3dk21RmSyhcmNiuXIyST)HeJq5OHBIDWetbIL7CHyL(Sjnyed4GWqbqX(E5pX(YKB)wcJ5EpOymDLHf7qG5eHkweJNkSNJOUyA9X8umfigpvyphrDPmT(yEk23RU9BjmM79GIXetmSyhcmNiuXIy8uH9Ce1111hZtXuGy8uH9Ce1LED9X8uSVxD73sy09BumAqkb(3tMybhmiI9hHOyCeSiwpIP3OyXwBWiwQjQyECQy)rik2auXObCtrSEetVrXIsbmIvcn8ccYWcJIDaXOtrgMsH2G55Xrtlmkm6cHINB5CWZHIYWIjM73OyTVdaQIrdGIXZcq5Pyq8JMRHyrmcWhfl4uGFOyrS9DmzizjmM79GIXdgwSdbMteQyrmEIUrIjJRNqXY6J5PykqmEwqpoA61hVq3iXKX1tOyHNI99QB)wcJ5EpOyxzIHf7qG5eHkweJNqUbPbWmC9X8umfigpHCdsdGz46Jx4eEjSWtX(YKB)wcJcJUFJIXtoc(Af9j8uSyRnye7FqeBaQy0aUPiwpIP3nrS23ba1LW4b33bavSiMlsSyRnyel1eLSegRSoqaDNWk7h(GyuCcjiKEcTbJy5giJdfg)WheZfhW9TyuSUkgtmGPRcJcJF4dIDqUHBoflI5H0aik2g47fQyEywpKLyu89gDuIydyoWDa9P5sIfBTbdrmWKOCjmgBTbdz5aXnW3luQHJtIYNdOjGrym2AdgYYbIBGVxO8s9spGQjS8OtbLy5Fpzpf4wpcJXwBWqwoqCd89cLxQx6hWJy5rdGVcg6TRoqCd89c9rWnykeQ5Y1MMkm6YdpXrxrPqw9W81Cjm(bXOiOIq)EqX(F37BX(20IfdL)eJOHkMhhnTykSNJOk2FuS)XOIPaXcvrFhvmfigHYzl2)wVf7WWPGQglHXyRnyilhiUb(EHYl1lpdyhEj01j8rQkSNJO(iuo7hjbuxpJehs9QRnnvf2Zruxxx3b5r0qxXq5R4q4)LckSNJOUyADhKhrdDfdLVIdjFEf2ZruxxxBaiva)NvHdgAdgMPQWEoI6IP1gasfW)zv4GH2G5NWyS1gmKLde3aFVq5L6LNbSdVe66e(ivf2ZruFekN9JKaQRNrIdPYKRnnvf2ZruxmTUdYJOHUIHYxXHW)lfuyphrDDDDhKhrdDfdLVIdjFEf2ZruxmT2aqQa(pRchm0gmmRWEoI666AdaPc4)SkCWqBW8tym2AdgYYbIBGVxO8s9sIIrsVfgJT2GHSCG4g47fkVuVKK6n(IP8k9gD1bIBGVxOpcUbtHq9QRnnvisdrYD4LqHrHXp8bXoi3WnNIfXWtesPyA7JIP3OyXwbqXAIyXz0PWlHlHXyRnyiup27JcJFqSCdjkgj9wSMwmhaH0EjuSVdqStU0GWWlHIHd63irSEeBd89c9NWyS1gmeEPEjrXiP3cJXwBWq4L6LNbSdVe66e(ivCqygLpiMHZBd896blUEgjoKkoimJYfeZWHxhqtadwEEjeleg6RlIxhf(7G9LjgI4GP07oik(tym2AdgcVuV8mGD4LqxNWhPs6jlHpnGzO66zK4qQehmLEAaZqLSOJ5bOFhN(ejxWKWyS1gmeEPEjDkYWuk0gmVDcJHGU20ulOhhn9IofzykfAdMfe9JEixWKWyS1gmeEPE5osPxS1gmVutuxNWhPsums6nwCTPPsums6nwwqqghkmgBTbdHxQxUJu6fBTbZl1e11j8rQ7cX1MM6xkOrchD5hefHVGqccPNfoHxcl5Zxa6klGqGIlT3h7j7NWyS1gmeEPEjj1B8ft5v6n6AttLcokKpXbtPNgWmujl6yEa63XPprYfu)MRda5gKgaZWvji39K9iBa3uGy6hFpoA6fj1B8ft5v6nUGOF0d5c6o7wFq0p6HWhI0qKChEjK)g47bEoGEucZuDPW4he7W5uXyhkIyCoI1tRDKsukgnak2H4uXuGy6nk2HUdc6QyqKgIKBX(36Tyh0CIdWxSMwSqflb(lwHdgAdgHXyRnyi8s9ssQ34lMYR0B01MMQJc5tbpoA6fj1B8ft5v6nU4C4Vb(EGNdOhLWmvxkmgBTbdHxQxIZjoaFxBAQokKVhhn9IK6n(IP8k9gxCo894OPxKuVXxmLxP34cI(rpKlYf)nW3d8Ca9OeMPYdHXyRnyi8s9YDKsVyRnyEPMOUoHpsTauHXyRnyi8s9YDKsVyRnyEPMOUoHpsT0qCRcJXwBWq4L6LbChd(uaeIJ6AttfheMr5QG09UvMPEnx8EgWo8s4cheMr5dIz482aFVEWIWyS1gmeEPEza3XGphUebfgJT2GHWl1ltD2TsEUWXvY8XrfgJT2GHWl1l9IShG(PWEFKimkm(Hpi2HaGub8FicJFqSdoTyrPqelGOyCoUkgzAhum9gfdmOy)B9wSe4psuXC3DkYsmxyeuS)34iwHYEYeJoikcftVJrSdD4Ivq6E3QyaOy)B9gWPIfdLIDOdFjmgBTbdzTleEPEPFapILhna(kyO3UUPCNWNgWmujuV6AttfgD5HN4OROuiloh(F1aMH6sBF8PGxPXl2aFpWZb0JswfKU3TYqxx5kF(nW3d8Ca9OKvbP7DRmtD788d3EehCk)eg)GyhCAXgGyrPqe7FNsIvAuS)TE3Jy6nk2GUPI5sgqCvmockMlMMIigyeZdqiI9V1BaNkwmuk2Ho8LWyS1gmK1Uq4L6L(b8iwE0a4RGHE7AttfgD5HN4OROuiREy2Lm4aWOlp8ehDfLczv4GH2GH)g47bEoGEuYQG09UvMPUDE(HBpIdofHXpiglLZwmkMuKHPuOnye7FR3IDy4uqvdXcIyjWKjwqe7pk2FWWtvSeGGIfITdIkg4eHIP3Oy0D2TkwHdgAdgHXyRnyiRDHWl1lPtrgMsH2GX1MMkfikgj9glliiJd5)DdaPc4)SoXPGQgli6h9qUWL8rAACR9j(2aFpWZb0JsyMkp4Rbmd1L2(4tbVsJmFLb5ZxqpoA61jofu1yX5KpVhGq4t3z36dI(rpKlyIh)egJT2GHS2fcVuVKofzykfAdgxBAQuGOyK0BSSGGmoKpstJBTpX3g47bEoGEucZu5b)V0jaa(9lDNDRpi6h9qoat843bBdaPc4)8Jz6eaa)(LUZU1he9JEihGjECGnaKkG)Z6eNcQASGOF0dHHodyhEjCDItbvnE7c83bBdaPc4)87NWyS1gmK1Uq4L6L0PidtPqBW82jmgc6AttLcokKFb94OPx0PidtPqBWSGOF0d5cMeg)GySuoBXyrhste7FR3IDy4uqvdXcIyjWKjwqe7pk2FWWtvSeGGIfITdIkg4eHIP3Oy0D2TkwHdgAdgxfZJtfZbI0iumnGzOsetVdvS)DkjwQprXcvSegevSRmGimgBTbdzTleEPEjbDinX1MMkfikgj9glliiJd5)DdaPc4)SoXPGQgli6h9qU4kFnGzOU02hFk4vAK5RmiF(c6XrtVoXPGQgloN85P7SB9br)OhYfxzWpHXyRnyiRDHWl1ljOdPjU20uParXiP3yzbbzCi)V0jaa(9lDNDRpi6h9qoWvg87GTbGub8F(XmDcaGF)s3z36dI(rpKdCLbhydaPc4)SoXPGQgli6h9qyOZa2HxcxN4uqvJ3Ua)DW2aqQa(p)(jm(bXyPC2IDy4uqvdX(3tb8xS)TElwoD2Ts0iDeH8EqUrIjJRNqrXAAXchNuVdVekmgBTbdzTleEPE5za7WlHUoHps9eNcQA8Mo7wjAKoIW3gmLwBW46zK4qQuqJeo6A6SBLOr6icx4eEjSKppf0iHJUq3iXKX1tO4cNWlHL853aqQa(pl0nsmzC9ekUGOF0d5ICDaMyins4ORcIoi8ruyOrg6VWj8syry8dIXs5Sf7WWPGQgI9V1BXOysrgMsH2GrSykIXIoKMiwqelbMmXcIy)rX(dgEQILaeuSqSDquXaNium9gfJUZUvXkCWqBWimgBTbdzTleEPE5za7WlHUoHps9eNcQA82GtCIrFBWuATbJRnn1n4eNy01rkHDm5ZVbN4eJUgCdbjaSKp)gCItm6Aad66zK4qQxfgJT2GHS2fcVuV8mGD4LqxNWhPEItbvnEBWjoXOVnykT2GX1MM6gCItm66eh9MsORNrIdPsNaa43V0D2T(GOF0d5amXGFhSVxzIbm0za7WlHRtCkOQXBxG)(XmDcaGF)s3z36dI(rpKdWedoWgasfW)zrNImmLcTbZcI(rpKFhSVxzIbm0za7WlHRtCkOQXBxG)(LpVhhn9IofzykfAdMNhhn9IZjF(c6XrtVOtrgMsH2GzX5KppDNDRpi6h9qUGjgimgBTbdzTleEPE5za7WlHUoHps9eNcQA82GtCIrFBWuATbJRnn1n4eNy010z36JoqxpJehsLobaWVFP7SB9br)OhYbyIb)oyFVYedyOZa2HxcxN4uqvJ3Ua)9Jz6eaa)(LUZU1he9JEihGjgCGnaKkG)ZIGoKMSGOF0d53b77vMyadDgWo8s46eNcQA82f4VF5Zxa6IGoKMS0EFSNS85P7SB9br)OhYfmXaHXyRnyiRDHWl1lpXPGQgU20uParXiP3yzbbzCi)cqxqohLdIlT3h7jJpfkOhhn96eNcQAS4C4FgWo8s46eNcQA8Mo7wjAKoIW3gmLwBWW)mGD4LW1jofu14TbN4eJ(2GP0AdgHXpi2b5gjMmUEcff7)noInavmIIrsVXIyXueZdO3ILBCokheflMIyu0acbkkwarX4CeJgaflbMmXWbWLDVegJT2GHS2fcVuVeDJetgxpHIU20uParXiP3yzbbzCi)VuOa0vwaHafxqKgIK7WlH8laDb5CuoiUGOF0dHzEWlpyOTZZpC7rCWPKpFbOliNJYbXfe9JEimedw5IznGzOU02hFk4vA8hFnGzOU02hFk4vAKzEim(bXyV7tXAAX(JIfquSWdWPIPaXoO5ehGVRIftrSqv03rftbIrOC2I9V1BXyrhsteJUNij2DRI10I9hf7py4Pk2)GOOy(aikMEhJy3rIwm9gfBdaPc4)SegJT2GHS2fcVuVKC3NU20ulaDb5CuoiU0EFSNm(FPWgasfW)zrqhstwqmkuMp)gasfW)zDItbvnwq0p6HW8vM(LpFbOlc6qAYs79XEYegJT2GHS2fcVuV0bOnyCTPP6XrtV8saqjXr0feJTMpVhGq4t3z36dI(rpKlCjdYNVGEC00RtCkOQXIZrym2AdgYAxi8s9sVeauE0CqkDTPPwqpoA61jofu1yX5imgBTbdzTleEPEPhcji8ypzU20ulOhhn96eNcQAS4CegJT2GHS2fcVuVKUHOxcakU20ulOhhn96eNcQAS4CegJT2GHS2fcVuVmMnsuyKE7iLCTPPwqpoA61jofu1yX5imgBTbdzTleEPE5osPxS1gmVutuxNWhPEgttUDTPPsbIIrsVXYksj((brr4liKGq65br)Ohcvgim(bXyPC2IP3OyoWgaBLsXiAOI5XrtlMc75iQI9V1BXomCkOQHRIb0Be(VjOyCeumWi2gasfW)rym2AdgYAxi8s9sf2ZruV6Att9mGD4LWLc75iQpcLZ(rsaL6v(FlOhhn96eNcQAS4CYN3dqi8P7SB9br)OhYfuzIb)YN)7za7WlHlf2ZruFekN9JKakvM4tbf2ZruxmT2aqQa(pligfk)LppfodyhEjCPWEoI6Jq5SFKeqfgJT2GHS2fcVuVuH9CevMCTPPEgWo8s4sH9Ce1hHYz)ijGsLj(FlOhhn96eNcQAS4CYN3dqi8P7SB9br)OhYfuzIb)YN)7za7WlHlf2ZruFekN9JKak1R8PGc75iQRRRnaKkG)ZcIrHYF5ZtHZa2HxcxkSNJO(iuo7hjbuHrHXp8bXOine3QyLWpYqXcVo1AJeHXpi2bnN4a8fluX4bVI9nx8k2)wVfJIW(tSdD4lXo4((yPdftukgyeJjEftdygQexf7FR3IDy4uqvdxfdaf7FR3I5(NUWlgqVr4)MGI9pAvmAaumcWhfdheMr5smkEIae7F0QynTyhKBKmX2aFpGynrSnWVNmX4CwcJXwBWqwLgIBLkoN4a8DTPPI004w7t8Tb(EGNdOhLWmvEWRgjC0vbrhe(ikm0id9x4eEjSW)Bb94OPxN4uqvJfNt(8f0JJMErU7ZfNt(8f0JJMErNImmLcTbZIZjFECqygLRcs37wVGkt5I3Za2Hxcx4GWmkFqmdN3g471dwYNNcNbSdVeUi9KLWNgWmu)X)lf0iHJUq3iXKX1tO4cNWlHL853aqQa(pl0nsmzC9ekUGOF0dHzM(jmgBTbdzvAiUvEPE5za7WlHUoHpsLJGp6oLqORNrIdPUb(EGNdOhLSkiDVBL5R5ZJdcZOCvq6E36fuzkx8EgWo8s4cheMr5dIz482aFVEWs(8u4mGD4LWfPNSe(0aMHQWyS1gmKvPH4w5L6LeecdflppWGpItFeDDt5oHpnGzOsOE11MMQFque(ccjiKEEq0p6HqLb8)6XrtViPEJVykVsVXfNdFkua6IGqyOy55bg8rC6J4Ra0L27J9KLpVhGq4t3z36dI(rpKlOMR853aqQa(plccHHILNhyWhXPpIR9DaZqYJggBTbtKyMktlxuUYNNa4sE9uwjmkppkFOBHVtcx4eEjSWNcEC00RegLNhLp0TW3jHloNFcJFqmkMyedql2h10NirSqf76hHxXiASpsedqlMl0DPGJyFMIcsedaflYIEiQy8GxX0aMHkzjmgBTbdzvAiUvEPEjDmpa9740NiX1MM6za7WlHloc(O7ucH8)6XrtVU7sbNNxkkizr0yFKzQx)i5Z)LcoWgaBLYheOH2GHpXbtPNgWmujl6yEa63XPprcZu5bVefJKEJLfeKXH)(jm(bXOyIrmaTyFutFIeXuGyHJtIsXOiyusuk2HdAcyeRPfRNyR9jkgyelgkftdygQIfQyUumnGzOswcJXwBWqwLgIBLxQxshZdq)oo9jsCDt5oHpnGzOsOE11MM6za7WlHloc(O7ucH8joyk90aMHkzrhZdq)oo9jsyMQlfgJT2GHSkne3kVuVe33GEYEq0b2(XuCTPPEgWo8s4IJGp6oLqi)naKkG)Z6eNcQASGOF0dH5Rmqym2AdgYQ0qCR8s9YW3JJC7Att9mGD4LWfhbF0DkHq(F9dIIWxqibH0ZdI(rpeQmiFEpoA6LxQNcPl4IZ5NW4heZ9W7aUyoTtHIIPaXchNeLIrrWOKOuSdh0eWiwOIXKyAaZqLimgBTbdzvAiUvEPEPpN2Pqrx3uUt4tdygQeQxDTPPEgWo8s4IJGp6oLqiFIdMspnGzOsw0X8a0VJtFIeQmjmgBTbdzvAiUvEPEPpN2PqrxBAQNbSdVeU4i4JUtjekmkm(Hpigfj8JmumWjcftBFuSWRtT2iry8dIL7TFRIrrdieOirmWi2aMd4aBFyaPumnGzOseJgaftVrXCGna2kLIbbAOnyeRPflx8kMxcXcrSaIIfjigfkfJZrym2AdgYQauQNbSdVe66e(ivYX25TPCNWxwaHafD9msCivhydGTs5dc0qBWWN4GP0tdygQKfDmpa9740NiHzxY)BbORSacbkUGOF0d5InaKkG)ZklGqGIRchm0gm5Z7aAcyWYZlHyHWCU(jm(bXY92VvXYnohLdIeXaJydyoGdS9HbKsX0aMHkrmAaum9gfZb2ayRukgeOH2GrSMwSCXRyEjeleXcikwKGyuOumohHXyRnyiRcq5L6LNbSdVe66e(ivYX25TPCNWhKZr5GORNrIdP6aBaSvkFqGgAdg(ehmLEAaZqLSOJ5bOFhN(ejm7s(FlOhhn9IC3NloN85Danbmy55LqSqyox)eg)Gy5E73Qy5gNJYbrIynTyhgofu1Gx27(8sxCquekgfNqccPhXAIyCoIftrS)Oy3Xjkgt8kgb3GPqelH0QyGrm9gfl34Cuoikgfb4UWyS1gmKvbO8s9YZa2HxcDDcFKk5y78GCokheD9msCi1c6XrtVoXPGQgloh(FlOhhn9IC3NloN859dIIWxqibH0ZdI(rpeMzWp(fGUGCokhexq0p6HWmtcJFqmwhC3rsmkAaHafflMIy5gNJYbrXiOY5iMdSbqXuGyhKBKyY46juuSDquHXyRnyiRcq5L6Lzbecu01MMQgjC0f6gjMmUEcfx4eEjSWNcOBKyY46juSSYcieOi)cqxzbecuC54ZL02j1i8cQx5VbGub8FwOBKyY46juCbr)OhYfmXN4GP0tdygQKfDmpa9740NiH6v(WOlp8ehDfLcz1dZUa(fGUYcieO4cI(rpegIbRCDHgWmuxA7Jpf8knkmgBTbdzvakVuVeY5OCq01MMQgjC0f6gjMmUEcfx4eEjSW)lstJBTpX3g47bEoGEucZu3op)WThXbNc)naKkG)ZcDJetgxpHIli6h9qU4k)cqxqohLdIli6h9qyigSY1fAaZqDPTp(uWR04pHXpigfnGqGIIX5CerhxflseGykSrIykqmockwRIfeXcXio4UJKyz4GWqbqXObqX0BuSuquXo0HlMhsdGOyHy090KBekmgBTbdzvakVuV0baspisaCWn6kna(g0nL6vHXyRnyiRcq5L6Lzbecu01MMkePHi5o8si)nW3d8Ca9OKvbP7DRmt9k)Vo(CjTDsncVG6185HOF0d5cQAVp(02h5tCWu6PbmdvYIoMhG(DC6tKWmvx(J)xkGUrIjJRNqXs(8q0p6HCbvT3hFA7Jmet8joyk90aMHkzrhZdq)oo9jsyMQl)X)RgWmuxA7Jpf8knEai6h9q(Xmp47hefHVGqccPNhe9JEiuzGWyS1gmKvbO8s9shai9GibWb3OR0a4Bq3uQxfgJT2GHSkaLxQxMfqiqrx3uUt4tdygQeQxDTPPsHZa2HxcxKJTZBt5oHVSacbkYhI0qKChEjK)g47bEoGEuYQG09UvMPEL)xhFUK2oPgHxq9A(8q0p6HCbvT3hFA7J8joyk90aMHkzrhZdq)oo9jsyMQl)X)lfq3iXKX1tOyjFEi6h9qUGQ27JpT9rgIj(ehmLEAaZqLSOJ5bOFhN(ejmt1L)4)vdygQlT9XNcELgpae9JEi)y(kt89dIIWxqibH0ZdI(rpeQmqy8dIDiy7taJyUJ(oirfdmI5ZL02jHIPbmdvIyHkgp4vSdD4I9)ghXGCZ0tMyaovSEeJjIyF5CetbIXdX0aMHk5NyaOyUKi23CXRyAaZqL8tym2AdgYQauEPE5g2(eW8u03bjQRnnvIdMspnGzOsyMkt8HOF0d5cM49lXbtPNgWmujmtnx)4J004w7t8Tb(EGNdOhLWmvEim(bX(Oq0rmohXYnohLdIIfQy8GxXaJyrkjMgWmujI99)noIL6ZEYelbMmXWbWLDlwmfXgGkgzchYnq)jmgBTbdzvakVuVeY5OCq01MMkfodyhEjCro2opiNJYbr(FrAACR9j(2aFpWZb0JsyMkp4drAisUdVeMppf0EFSNm(F12hz(kdYNFd89aphqpkHzQm97h)Vo(CjTDsncVG6185HOF0d5cQAVp(02h5tCWu6PbmdvYIoMhG(DC6tKWmvx(J)xkGUrIjJRNqXs(8q0p6HCbvT3hFA7Jmet8joyk90aMHkzrhZdq)oo9jsyMQl)XxdygQlT9XNcELgpae9JEimZdHXyRnyiRcq5L6LqohLdIUUPCNWNgWmujuV6AttLcNbSdVeUihBN3MYDcFqohLdI8PWza7WlHlYX25b5CuoiYhPPXT2N4Bd89aphqpkHzQ8GpePHi5o8si)Vo(CjTDsncVG6185HOF0d5cQAVp(02h5tCWu6PbmdvYIoMhG(DC6tKWmvx(J)xkGUrIjJRNqXs(8q0p6HCbvT3hFA7Jmet8joyk90aMHkzrhZdq)oo9jsyMQl)XxdygQlT9XNcELgpae9JEim)Lh8c5gKgaZWvji39K9iBa3uGyIH(i8c5gKgaZWvba89srbzixWpHXpi2HGTpbmI5o67GevmWigR7I10I1JyoXuq)ElwmfXgmGjkfZpCtmCqygLIftrSMwSdAoXb4l2FWWtvScqmFaefRe(rgkwHdftbI5(Nx6IP4cJXwBWqwfGYl1l3W2NaMNI(oirDTPPsCWu6Pbmdvc1R8rAACR9j(2aFpWZb0JsyM63TZZpC7rCWPCGR)4drAisUdVeYNcOBKyY46juSWNcf0JJMErU7ZfNdF)GOi8fesqi98GOF0dHkd4)fheMr5QG09U1lOYuU49mGD4LWfoimJYheZW5Tb(E9GLF81aMH6sBF8PGxPXdar)OhcZ8qyuy8dFqmwfJKEJfXO4BTbdry8dILtNDt0iDeHIbgXCP7mSyhc2(eWiM7OVdsuHXyRnyilIIrsVXc1nS9jG5POVdsuxBAQAKWrxtNDRenshr4cNWlHf(ehmLEAaZqLWmvxYFd89aphqpkHzQ8GVgWmuxA7Jpf8knEai6h9qy2fim(bXYPZUjAKoIqXaJyxDNHfJDchYnqfl34CuoikmgBTbdzrums6nw4L6LqohLdIU20u1iHJUMo7wjAKoIWfoHxcl83aFpWZb0JsyMkp4Rbmd1L2(4tbVsJhaI(rpeMDbcJFqmwopfH0Czidlgf3XjrPyaOy5gsdrYTy)B9wmpoAASigfnGqGIeHXyRnyilIIrsVXcVuV0baspisaCWn6kna(g0nL6vHXyRnyilIIrsVXcVuVmlGqGIUUPCNWNgWmujuV6AttvJeo6IW5PiKMldx4eEjSW)le9JEixCLP85D85sA7KAeEb1R)4Rbmd1L2(4tbVsJhaI(rpeMzsy8dIXY5PiKMldfJxXoi3izIbgXU6odlwUH0qKClgfnGqGIIfQy6nkgofXa0Irums6TykqSmufZpCtSchm0gmI5H0aik2b5gjMmUEcffgJT2GHSikgj9gl8s9shai9GibWb3OR0a4Bq3uQxfgJT2GHSikgj9gl8s9YSacbk6AttvJeo6IW5PiKMldx4eEjSWxJeo6cDJetgxpHIlCcVew4hBTpXhoOFJeQx57XrtViCEkcP5YWfe9JEixCD5sHXyRnyilIIrsVXcVuV0Nt7uOORnnvns4OlcNNIqAUmCHt4LWc)nW3d8Ca9OKlO6sHrHXp8bXoSyAYTW4heJIPNMCl2)wVfZpCtSdD4IrdGILtNDRenshrORIXnjKqeJJ0tMyuem07eLIXEhfWFIWyS1gmK1zmn5M6za7WlHUoHpsD6SBLOr6icFBN3gmLwBW46zK4qQFPaKBqAamdxfm07eLpYDua)j8rAACR9j(2aFpWZb0JsyM6255hU9io4u(Lp)xi3G0aygUkyO3jkFK7Oa(t4Vb(EGNdOhLCbt)eg)Gyhwmn5wS)TEl2b5gjtmEflNo7wjAKoIqgwmxC4w7Z5l2HoCXIPi2b5gjtmigfkfJgafBq3uXOOhIIimgBTbdzDgttU5L6LNX0KBxBAQAKWrxOBKyY46juCHt4LWcFns4ORPZUvIgPJiCHt4LWc)Za2HxcxtNDRenshr4B782GP0Adg(Baiva)Nf6gjMmUEcfxq0p6HCXvHXpi2HfttUf7FR3ILtNDRenshrOy8kwoaXoi3izmSyU4WT2NZxSdD4IftrSddNcQAigNJWyS1gmK1zmn5MxQxEgttUDTPPQrchDnD2Ts0iDeHlCcVew4tbns4Ol0nsmzC9ekUWj8syH)za7WlHRPZUvIgPJi8TDEBWuATbd)c6XrtVoXPGQglohHXyRnyiRZyAYnVuV0baspisaCWn6kna(g0nL6vxr3uy8cFa3Ou5rUegJT2GHSoJPj38s9YZyAYTRnnvns4OlcNNIqAUmCHt4LWc)naKkG)ZklGqGIloh(FlaDLfqiqXfePHi5o8sy(8f0JJMEDItbvnwCo8laDLfqiqXLJpxsBNuJWlOE9h)nW3d8Ca9OKvbP7DRmt9lXbtPNgWmujl6yEa63XPprcZUqXJF8HrxE4jo6kkfYQhMVYKW4he7WIPj3I9V1BXCXbrrOyuCcji9WWILBCokhe5LIgqiqrXgGkwpIbrAisUfdgtg6QyfoypzIDy4uqvdEzV7ZLySuoBX(36TySOdPjIr3tKe7UvXAAXCaes7LWLWyS1gmK1zmn5MxQxEgttUDTPP(vJeo6YpikcFbHeesplCcVewYNhYninaMHl)aE8bOF6n(8dIIWxqibH0Zp(uOa0fKZr5G4cI0qKChEjKFbORSacbkUGOF0dHzxYVGEC00RtCkOQXIZH)3c6XrtVi395IZjF(c6XrtVoXPGQgli6h9qUGh5Zxa6IGoKMS0EFSNSF8laDrqhstwq0p6HCHlRSehCxZHPC9rQAvRva]] )

end