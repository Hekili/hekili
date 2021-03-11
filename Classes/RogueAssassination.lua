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


    spec:RegisterPack( "Assassination", 20210310, [[daLS(bqiKOEKkPCjLcytOQ(evsgLQQofsyvOa9kuLMfvIBPuODPKFPsYWuv0XujwgkYZOsQPHQW1ePY2qveFdfGghQIkNdvrzDOG6DOaGMNQc3djTpuu)dfa4GOGyHirEOsrMOkPYffPQ2iki5JQKQgjka0jvkqRef6LOkQAMkfLBIQiTtrkdvPOAPIuLNIstLkvxffKkBvPG(kkaASOaAVs6VQYGPCyHftv9yvmzjUm0MrQplIrRsDAPwnkiv9ALsZwu3MQSBf)gy4uXXrbPSCqphX0jUoQSDLQVRQY4Ps58QknFrY(jD9s19kBjeSMgtFY0LpD9Lpxx4zP7ctxQSYxhSY6eNTrcwzNWdRSmecjiKEcPbtL1j(MbrP6ELLa4GhSYElIdHHV6QKwU58xhG3vK2JlhsdMdmOLRiT35QkRpxNLn4u9RSLqWAAm9jtx(01x(CDHNLUlFMUkBWj3ayLLT92uL9UlfCQ(v2csovwgcHeespH0GrT0dKWHkJ80aEUv7YNUOgtFY0LkBUjcP6ELLiyKLBSuDVM2LQ7vwCc)mwQuQYghPbtL9aBpcyEc65GePYwqYb2osdMkBADYnrI8weQgyuZ1UZWQTjy7raJAUJEoirQShyliSJkRezCK10j3crI8weUWj8Zyrn(QrCWC(jbmbfIAmtvnxRgF1oapFWZb0JquJzQQXd14RMeWeuws7Hpb8knQ2gvdIErpe1ywnEsvQPXu19kloHFglvkvzJJ0GPYc5Ceoiwzli5aBhPbtLnTo5MirElcvdmQDXDgwn2jCi3arT0JZr4GyL9aBbHDuzLiJJSMo5wisK3IWfoHFglQXxTdWZh8Ca9ie1yMQA8qn(QjbmbLL0E4taVsJQTr1GOx0drnMvJNuLAAUU6ELfNWpJLkLQSXrAWuzDaG8dIeah8Gv2csoW2rAWuzz58fesZLGmSAmehN8x1aq1spKgIKB1(1YTA(C00yrTRpGqGGKklna(g0nPM2LQutJhv3RS4e(zSuPuLnosdMkBsaHabRShyliSJkRezCKfHZxqinxcUWj8Zyrn(Q9xni6f9qu7d1UWKAPsPMJhxwANCJq1(GQAxuJc14RMeWeuws7Hpb8knQ2gvdIErpe1ywnMQSNVNm(KaMGcPM2LQutlDv3RS4e(zSuPuLnosdMkRdaKFqKa4GhSYwqYb2osdMkllNVGqAUeunEvl9DJKOgyu7I7mSAPhsdrYTAxFaHabvle1KBunCkQbOvJiyKLB1eGAjOOMx4MAfoyinyuZhPbquT03nsmjC9ecwzPbW3GUj10UuLAA8KQ7vwCc)mwQuQYEGTGWoQSsKXrweoFbH0Cj4cNWpJf14RMezCKf6gjMeUEcbx4e(zSOgF1IJ074dh0RrIAuv7IA8vZNJMEr48fesZLGli6f9qu7d1USCDLnosdMkBsaHabRsnngWQ7vwCc)mwQuQYEGTGWoQSsKXrweoFbH0Cj4cNWpJf14R2b45dEoGEeIAFqvnxxzJJ0GPY6XjDoeSkvPYUhttURUxt7s19kloHFglvkvzbovwckv24inyQS7bSd)mwz3Jmhwz)RgLvdYninaMGRcgYD(7JChfWpYcNWpJf14RgstJhP3X3b45dEoGEeIAmtvTJZZlC7rCWPOgfQLkLA)vdYninaMGRcgYD(7JChfWpYcNWpJf14R2b45dEoGEeIAFOgtQrrLTGKdSDKgmvwgQEAYTA)A5wnVWn120MRgnaQwADYTqKiVfHUOg3KrcrnospjQDDyi35VQXEhfWpsLDpGVj8Wk70j3crI8we(ooVdykT0GPk10yQ6ELfNWpJLkLQSXrAWuz3JPj3v2csoW2rAWuz3WyAYTA)A5wT03nsIA8QwADYTqKiVfHmSA80WT2JZtTnT5QftrT03nsIAqmkFvJgavBq3e1U(nDDv2dSfe2rLvImoYcDJetcxpHGlCc)mwuJVAsKXrwtNClejYBr4cNWpJf14R2Ea7WpJRPtUfIe5Ti8DCEhWuAPbJA8v7aa5c43Sq3iXKW1ti4cIErpe1(qTlvPMMRRUxzXj8ZyPsPkBCKgmv29yAYDLTGKdSDKgmv2nmMMCR2VwUvlTo5wisK3Iq14vT0aQL(Ursyy14PHBThNNABAZvlMIABiofuKqnoNk7b2cc7OYkrghznDYTqKiVfHlCc)mwuJVAuwnjY4il0nsmjC9ecUWj8Zyrn(QThWo8Z4A6KBHirElcFhN3bmLwAWOgF1kOphn9AhNcksS4CQsnnEuDVYIt4NXsLsv24inyQSoaq(brcGdEWkl6MaJx4b4gPYYJ0vzPbW3GUj10UuLAAPR6ELfNWpJLkLQShyliSJkRezCKfHZxqinxcUWj8Zyrn(QDaGCb8BwjbeceCX5OgF1(RwbiRKacbcUGinej3HFgvlvk1kOphn9AhNcksS4CuJVAfGSsciei4YXJllTtUrOAFqvTlQrHA8v7a88bphqpczvq6(0IAmtvT)QrCWC(jbmbfYIoMhG(TD6DKOgZmaqnEOgfQXxny0LhUJJSIsHS6rnMv7ctv24inyQS7X0K7QutJNuDVYIt4NXsLsv24inyQS7X0K7kBbjhy7inyQSBymn5wTFTCRgpniccvJHqibPhgwT0JZr4GiVxFaHabvBaIA9OgePHi5wnymjOlQv4G9KO2gItbfj4L9U3xQX(DoQ9RLB1yrhstuJUNiR2DlQ10Q5aiK2pJRk7b2cc7OY(xnjY4ilVGii8fesqi9SWj8ZyrTuPudYninaMGlVaU9bOFYn(8cIGWxqibH0ZcNWpJf1Oqn(Qrz1kazb5CeoiUGinej3HFgvJVAfGSsciei4cIErpe1ywnxRgF1kOphn9AhNcksS4CuJVA)vRG(C00lYDVV4Culvk1kOphn9AhNcksSGOx0drTpuJhQLkLAfGSiOdPjlPpB7jrnkuJVAfGSiOdPjli6f9qu7d1CDvQsLTG0bxwQUxt7s19kBCKgmv2T9zBLfNWpJLkLQsnnMQUxzXj8ZyPsPkBbjhy7inyQSPhsemYYTAnTAoacP9ZOA)hGA7C5bHHFgvdh0RrIA9O2b45hcfv24inyQSebJSCxLAAUU6ELfNWpJLkLQSaNklbLkBCKgmv29a2HFgRS7rMdRS4GWKVliMGJA8QMdOjGblp)mIfIAmOA8CQDLA)vJj1yq1ioyo)UdIGQrrLDpGVj8Wkloim57dIj48oap)EWsvQPXJQ7vwCc)mwQuQYcCQSeuQSXrAWuz3dyh(zSYUhzoSYsCWC(jbmbfYIoMhG(TD6DKO2hQXuLDpGVj8WklPNKm(KaMGsvQPLUQ7vwCc)mwQuQYEGTGWoQSf0NJMErNJemNdPbZcIErpe1(qnMQSXrAWuzPZrcMZH0G5DYymeSk104jv3RS4e(zSuPuL9aBbHDuzjcgz5glliiHdRSXrAWuzpro)IJ0G5LBIuzZnrEt4HvwIGrwUXsvQPXawDVYIt4NXsLsv2dSfe2rL9VAuwnjY4ilVGii8fesqi9SWj8ZyrTuPuRaKvsaHabxsF22tIAuuzJJ0GPYEIC(fhPbZl3ePYMBI8MWdRSNcPk1045QUxzXj8ZyPsPkBCKgmvwsUp4lMYR0hSYwqYb2osdMk7MZjQXoxNACoQ1tlDKZFvJgavBtCIAcqn5gvBt3bbDrnisdrYTA)A5wT0F2Xb4PwtRwiQLb)uRWbdPbtL9aBbHDuzPSA(C00lsUp4lMYR0hCX5OgF1oapFWZb0JquJzQQ56QutJNvDVYIt4NXsLsv2dSfe2rL1NJMErY9bFXuEL(Gloh14RMphn9IK7d(IP8k9bxq0l6HO2hQLo14R2b45dEoGEeIAmtvnEuzJJ0GPYIZooaVQut7YNv3RS4e(zSuPuLnosdMk7jY5xCKgmVCtKkBUjYBcpSYwasvQPD5s19kloHFglvkvzJJ0GPYEIC(fhPbZl3ePYMBI8MWdRSLgIhPk10UWu19kloHFglvkvzpWwqyhvwCqyY3vbP7tlQXmv1UKo14vT9a2HFgx4GWKVpiMGZ7a887blv24inyQSb8ed(eaeIJuLAAxCD19kBCKgmv2aEIbFoCzcwzXj8ZyPsPQut7cpQUxzJJ0GPYM7KBH8yONRK4HJuzXj8ZyPsPQut7s6QUxzJJ0GPY6hjpa9tG9zlPYIt4NXsLsvPkvwhiEaE(HuDVM2LQ7v24inyQSHJt(7Zb0eWuzXj8ZyPsPQutJPQ7v24inyQS(arYy5rNJVy5xpjpb4wpvwCc)mwQuQk10CD19kloHFglvkvzJJ0GPY6fWTy5rdGVcgYDL9aBbHDuzHrxE4ooYkkfYQh1ywTlPRY6aXdWZpKhbpGPqQSPRk104r19kloHFglvkvzbovwckv24inyQS7bSd)mwz3d4BcpSYkWE2IYJ8Dopsgiv2dSfe2rLvG9SfLLCzDhKhrczfZ3xXHOgF1(RgLvtG9SfLLW06oipIeYkMVVIdrTuPutG9SfLLCzDaGCb8BwfoyinyuJzQQjWE2IYsyADaGCb8BwfoyinyuJIkBbjhy7inyQSxhki0RhuTF395wT)nTAX8Lc1isiQ5ZrtRMa7zlkQ9dv7xmIAcqTqe0ZrutaQr(oh1(1YTABiofuKyvz3JmhwzVuLAAPR6ELfNWpJLkLQSaNklbLkBCKgmv29a2HFgRS7rMdRSmvzpWwqyhvwb2ZwuwctR7G8isiRy((koe14R2F1OSAcSNTOSKlR7G8isiRy((koe1sLsnb2ZwuwctRdaKlGFZQWbdPbJAmRMa7zlkl5Y6aa5c43SkCWqAWOgfv29a(MWdRScSNTO8iFNZJKbsvQPXtQUxzJJ0GPYsemYYDLfNWpJLkLQsnngWQ7vwCc)mwQuQYghPbtLLK7d(IP8k9bRShyliSJklePHi5o8ZyL1bIhGNFipcEatHuzVuLQuzlneps19AAxQUxzXj8ZyPsPkBCKgmvwC2Xb4vzli5aBhPbtLn9NDCaEQfIA8Gx1(NoEv7xl3QDDSuO2M28LABqppS0HG5VQbg1yIx1KaMGcXf1(1YTABiofuKWf1aq1(1YTAUtjxudi3i8xtq1(fTOgnaQgb4HQHdct(UuJHKja1(fTOwtRw67gjrTdWZhOwtu7a86jrnoNvL9aBbHDuzrAA8i9o(oapFWZb0JquJzQQXd14vnjY4iRcIoi8reyirc6TWj8Zyrn(Q9xTc6ZrtV2XPGIeloh1sLsTc6ZrtVi39(IZrTuPuRG(C00l6CKG5CinywCoQLkLA4GWKVRcs3Nwu7dQQXu6uJx12dyh(zCHdct((GycoVdWZVhSOwQuQrz12dyh(zCr6jjJpjGjOOgfQXxT)Qrz1KiJJSq3iXKW1ti4cNWpJf1sLsTdaKlGFZcDJetcxpHGli6f9quJz1ysnkQsnnMQUxzXj8ZyPsPklWPYsqPYghPbtLDpGD4NXk7EK5Wk7b45dEoGEeYQG09Pf1ywTlQLkLA4GWKVRcs3Nwu7dQQXu6uJx12dyh(zCHdct((GycoVdWZVhSOwQuQrz12dyh(zCr6jjJpjGjOuz3d4BcpSYYrWhDNZiSk10CD19kloHFglvkvzJJ0GPYsqimeS88bd(io9wSYEGTGWoQSEbrq4liKGq65brVOhIAuv7t14R2F185OPxKCFWxmLxPp4IZrn(Qrz1kazrqimeS88bd(io9w8vaYs6Z2Esulvk18beIA8vJUtULhe9IEiQ9bv1sNAPsP2baYfWVzrqimeS88bd(io9wCDUdycsE0W4inyISAmtvnMwmGPtTuPuJa4Y(9uwzmkp)Vp0TWZjJlCc)mwuJVAuwnFoA6vgJYZ)7dDl8CY4IZrnkQSNVNm(KaMGcPM2LQutJhv3RS4e(zSuPuLnosdMklDmpa9B707iPYwqYb2osdMkldvmQbOvJNF6DKOwiQDHNXRAejoBjQbOvJbWUuWrnkLJcsudavlsIEiIA8Gx1KaMGczvzpWwqyhv29a2HFgxCe8r35mcvJVA)vZNJMED3Lcop)CuqYIiXzRAmtvTl8m1sLsT)Qrz1CGna2Y3heiH0Grn(QrCWC(jbmbfYIoMhG(TD6DKOgZuvJhQXRAebJSCJLfeKWHQrHAuuLAAPR6ELfNWpJLkLQSXrAWuzPJ5bOFBNEhjv2Z3tgFsatqHut7sL9aBbHDuz3dyh(zCXrWhDNZiun(QrCWC(jbmbfYIoMhG(TD6DKOgZuvZ1v2csoW2rAWuzzOIrnaTA88tVJe1eGAHJt(RAxhgL8x12CqtaJAnTA9ehP3r1aJAX8vnjGjOOwiQ5A1KaMGczvLAA8KQ7vwCc)mwQuQYEGTGWoQS7bSd)mU4i4JUZzeQgF1oaqUa(nRDCkOiXcIErpe1ywTlFwzJJ0GPYINBqpjpi6aBVykvPMgdy19kloHFglvkvzpWwqyhv29a2HFgxCe8r35mcvJVA)vZliccFbHeesppi6f9quJQAFQwQuQ5ZrtV8Z9uiDbxCoQrrLnosdMkB45ZrURsnnEUQ7vwCc)mwQuQYghPbtL1Jt6CiyL989KXNeWeui10UuzpWwqyhv29a2HFgxCe8r35mcvJVAehmNFsatqHSOJ5bOFBNEhjQrvnMQSfKCGTJ0GPY6E4VrEkN05qq1eGAHJt(RAxhgL8x12CqtaJAHOgtQjbmbfsvQPXZQUxzXj8ZyPsPk7b2cc7OYUhWo8Z4IJGp6oNryLnosdMkRhN05qWQuLk7PqQUxt7s19kloHFglvkvzJJ0GPY6fWTy5rdGVcgYDL989KXNeWeui10UuzpWwqyhvwy0LhUJJSIsHS4CuJVA)vtcycklP9WNaELgv7d1oapFWZb0JqwfKUpTOgdQ2Lv6ulvk1oapFWZb0JqwfKUpTOgZuv7488c3EehCkQrrLTGKdSDKgmv2niTArPqulGOACoUOgzAhun5gvdmOA)A5wTm4hse1C39RBPgdDeuTF34Ow5BpjQrhebHQj3XO2M2C1kiDFArnauTFTCd4e1I5RABAZxvPMgtv3RS4e(zSuPuLnosdMkRxa3ILhna(kyi3v2csoW2rAWuz3G0Qna1IsHO2VoNvR0OA)A5Uh1KBuTbDtuZ1FsCrnocQgpL(6udmQ5die1(1YnGtulMVQTPnFvzpWwqyhvwy0LhUJJSIsHS6rnMvZ1FQ2gvdgD5H74iROuiRchmKgmQXxTdWZh8Ca9iKvbP7tlQXmv1oopVWThXbNsvQP56Q7vwCc)mwQuQYghPbtLLohjyohsdMkBbjhy7inyQSSFNJAmu5ibZ5qAWO2VwUvBdXPGIeQfe1YGjrTGO2puTFGXvIAzabvlu7eernWocvtUr1O7KBrTchmKgmv2dSfe2rLLYQremYYnwwqqchQgF1(R2baYfWVzTJtbfjwq0l6HO2hQ5A14RgstJhP3X3b45dEoGEeIAmtvnEOgF1KaMGYsAp8jGxPr1ywTlFQwQuQvqFoA61oofuKyX5OwQuQ5die14RgDNClpi6f9qu7d1yIhQrrvQPXJQ7vwCc)mwQuQYEGTGWoQSuwnIGrwUXYccs4q14RgstJhP3X3b45dEoGEeIAmtvnEOgF1(RgDgaGQ9xT)Qr3j3YdIErpe12OAmXd1OqTRulosdM3baYfWVrnkuJz1OZaauT)Q9xn6o5wEq0l6HO2gvJjEO2gv7aa5c43S2XPGIeli6f9quJbvBpGD4NX1oofuK4Dkq1OqTRulosdM3baYfWVrnkuJIkBCKgmvw6CKG5CinyQsnT0vDVYIt4NXsLsv24inyQSe0H0KkBbjhy7inyQSSFNJASOdPjQ9RLB12qCkOiHAbrTmysuliQ9dv7hyCLOwgqq1c1obrudSJq1KBun6o5wuRWbdPbJlQ5ZjQ5arAeQMeWeuiQj3HO2VoNvl37OAHOwgdIO2Lpjv2dSfe2rLLYQremYYnwwqqchQgF1(R2baYfWVzTJtbfjwq0l6HO2hQDrn(QjbmbLL0E4taVsJQXSAx(uTuPuRG(C00RDCkOiXIZrTuPuJUtULhe9IEiQ9HAx(unkQsnnEs19kloHFglvkvzpWwqyhvwkRgrWil3yzbbjCOA8v7VA0zaaQ2F1(RgDNClpi6f9quBJQD5t1OqTRulosdM3baYfWVrnkuJz1OZaauT)Q9xn6o5wEq0l6HO2gv7YNQTr1oaqUa(nRDCkOiXcIErpe1yq12dyh(zCTJtbfjENcunku7k1IJ0G5DaGCb8BuJc1OOYghPbtLLGoKMuLAAmGv3RS4e(zSuPuLf4uzjOuzJJ0GPYUhWo8ZyLDpYCyLLYQjrghznDYTqKiVfHlCc)mwulvk1OSAsKXrwOBKys46jeCHt4NXIAPsP2baYfWVzHUrIjHRNqWfe9IEiQ9HAPtTnQgtQXGQjrghzvq0bHpIadjsqVfoHFglv2csoW2rAWuzz)oh12qCkOiHA)6Pa(P2VwUvlTo5wisK3IqEtF3iXKW1tiOAnTAHJtUpHFgRS7b8nHhwz3XPGIeVPtUfIe5Ti8DatPLgmvPMgpx19kloHFglvkvzbovwckv24inyQS7bSd)mwz3d4BcpSYUJtbfjEhWooXiVdykT0GPYEGTGWoQShWooXiRTFHDmQLkLAhWooXiRbpqqgalQLkLAhWooXiRbmyLTGKdSDKgmvw2VZrTneNcksO2VwUvJHkhjyohsdg1IPOgl6qAIAbrTmysuliQ9dv7hyCLOwgqq1c1obrudSJq1KBun6o5wuRWbdPbtLDpYCyL9svQPXZQUxzXj8ZyPsPklWPYsqPYghPbtLDpGD4NXk7EK5WklDgaGQ9xT)Qr3j3YdIErpe12OAm9PAuO2vQ9xTlm9PAmOA7bSd)mU2XPGIeVtbQgfQrHAmRgDgaGQ9xT)Qr3j3YdIErpe12OAm9PABuTdaKlGFZIohjyohsdMfe9IEiQrHAxP2F1UW0NQXGQThWo8Z4AhNcks8ofOAuOgfQLkLA(C00l6CKG5CinyE(C00loh1sLsTc6ZrtVOZrcMZH0GzX5OwQuQr3j3YdIErpe1(qnM(SYEGTGWoQShWooXiRDCK7VWk7EaFt4Hv2DCkOiX7a2Xjg5DatPLgmvPM2LpRUxzXj8ZyPsPklWPYsqPYghPbtLDpGD4NXk7EK5WklDgaGQ9xT)Qr3j3YdIErpe12OAm9PAuO2vQ9xTlm9PAmOA7bSd)mU2XPGIeVtbQgfQrHAmRgDgaGQ9xT)Qr3j3YdIErpe12OAm9PABuTdaKlGFZIGoKMSGOx0drnku7k1(R2fM(unguT9a2HFgx74uqrI3PavJc1OqTuPuRaKfbDinzj9zBpjQLkLA0DYT8GOx0drTpuJPpRShyliSJk7bSJtmYA6KB5rhyLDpGVj8Wk7oofuK4Da74eJ8oGP0sdMQut7YLQ7vwCc)mwQuQYEGTGWoQSuwnIGrwUXYccs4q14RwbiliNJWbXL0NT9KOgF1OSAf0NJMETJtbfjwCoQXxT9a2HFgx74uqrI30j3crI8we(oGP0sdg14R2Ea7WpJRDCkOiX7a2Xjg5DatPLgmv24inyQS74uqrIQut7ctv3RS4e(zSuPuLnosdMkl6gjMeUEcbRSfKCGTJ0GPYM(UrIjHRNqq1(DJJAdquJiyKLBSOwmf18bYTAPhNJWbr1IPO21hqiqq1ciQgNJA0aOAzWKOgoaUK7vL9aBbHDuzPSAebJSCJLfeKWHQXxT)Qrz1kazLeqiqWfePHi5o8ZOA8vRaKfKZr4G4cIErpe1ywnEOgVQXd1yq1oopVWThXbNIAPsPwbiliNJWbXfe9IEiQXGQ95kDQXSAsatqzjTh(eWR0OAuOgF1KaMGYsAp8jGxPr1ywnEuLAAxCD19kloHFglvkvzJJ0GPYsU79kBbjhy7inyQSS39UAnTA)q1ciQw4d4e1eGAP)SJdWZf1IPOwic65iQja1iFNJA)A5wnw0H0e1O7jYQD3IAnTA)q1(bgxjQ9licQMhaIQj3XO2DKPvtUr1oaqUa(nRk7b2cc7OYwaYcY5iCqCj9zBpjQXxT)Qrz1oaqUa(nlc6qAYcIr5RAPsP2baYfWVzTJtbfjwq0l6HOgZQDHj1OqTuPuRaKfbDinzj9zBpjvPM2fEuDVYIt4NXsLsv2dSfe2rL1NJME5NbGsMJilighrTuPuZhqiQXxn6o5wEq0l6HO2hQ56pvlvk1kOphn9AhNcksS4CQSXrAWuzDasdMQut7s6QUxzXj8ZyPsPk7b2cc7OYwqFoA61oofuKyX5uzJJ0GPY6NbGYJMd(Tk10UWtQUxzXj8ZyPsPk7b2cc7OYwqFoA61oofuKyX5uzJJ0GPY6Jqcc32tsvQPDHbS6ELfNWpJLkLQShyliSJkBb95OPx74uqrIfNtLnosdMklDdr)mauQsnTl8Cv3RS4e(zSuPuL9aBbHDuzlOphn9AhNcksS4CQSXrAWuzJ5Gebg53jY5Qut7cpR6ELfNWpJLkLQShyliSJklLvJiyKLBSSICwn(Q5febHVGqccPNhe9IEiQrvTpRSXrAWuzpro)IJ0G5LBIuzZnrEt4Hv29yAYDvQPX0Nv3RS4e(zSuPuLnosdMkRa7zlkxQSfKCGTJ0GPYY(DoQj3OAoWgaB5RAeje185OPvtG9Sff1(1YTABiofuKWf1aYnc)1eunocQgyu7aa5c43uzpWwqyhv29a2HFgxcSNTO8iFNZJKbIAuv7IA8v7VAf0NJMETJtbfjwCoQLkLA(acrn(Qr3j3YdIErpe1(GQAm9PAuOwQuQ9xT9a2HFgxcSNTO8iFNZJKbIAuvJj14RgLvtG9SfLLW06aa5c43SGyu(QgfQLkLAuwT9a2HFgxcSNTO8iFNZJKbsvQPX0LQ7vwCc)mwQuQYEGTGWoQS7bSd)mUeypBr5r(oNhjde1OQgtQXxT)QvqFoA61oofuKyX5OwQuQ5die14RgDNClpi6f9qu7dQQX0NQrHAPsP2F12dyh(zCjWE2IYJ8DopsgiQrvTlQXxnkRMa7zlkl5Y6aa5c43SGyu(QgfQLkLAuwT9a2HFgxcSNTO8iFNZJKbsLnosdMkRa7zlkmvLQuzlaP6EnTlv3RS4e(zSuPuLf4uzjOuzJJ0GPYUhWo8ZyLDpYCyL1b2aylFFqGesdg14RgXbZ5NeWeuil6yEa632P3rIAmRMRvJVA)vRaKvsaHabxq0l6HO2hQDaGCb8BwjbeceCv4GH0GrTuPuZb0eWGLNFgXcrnMvlDQrrLTGKdSDKgmv2nR9ArTRpGqGGe1aJAdy2OdS9Gb8RAsatqHOgnaQMCJQ5aBaSLVQbbsinyuRPvlD8QMFgXcrTaIQfzigLVQX5uz3d4BcpSYs22oVZ3tgFjbeceSk10yQ6ELfNWpJLkLQSaNklbLkBCKgmv29a2HFgRS7rMdRSoWgaB57dcKqAWOgF1ioyo)KaMGczrhZdq)2o9osuJz1CTA8v7VAf0NJMErU79fNJAPsPMdOjGblp)mIfIAmRw6uJIkBbjhy7inyQSBw71IAPhNJWbrIAGrTbmB0b2EWa(vnjGjOquJgavtUr1CGna2Yx1GajKgmQ10QLoEvZpJyHOwar1ImeJYx14CQS7b8nHhwzjBBN357jJpiNJWbXQutZ1v3RS4e(zSuPuLf4uzjOuzJJ0GPYUhWo8ZyLDpYCyLTG(C00RDCkOiXIZrn(Q9xTc6ZrtVi39(IZrTuPuZliccFbHeesppi6f9quJz1(unkuJVAfGSGCochexq0l6HOgZQXuLTGKdSDKgmv2nR9ArT0JZr4GirTMwTneNcksWl7DVFfpniccvJHqibH0JAnrnoh1IPO2puT7yhvJjEvJGhWuiQLrArnWOMCJQLECochev76aUxz3d4BcpSYs22opiNJWbXQutJhv3RS4e(zSuPuLnosdMkBsaHabRSfKCGTJ0GPYY6GNoYQD9beceuTykQLECochevJGcNJAoWgavtaQL(UrIjHRNqq1obrQShyliSJkRezCKf6gjMeUEcbx4e(zSOgF1OSAf0NJMELeqiqWf6gjMeUEcblQXxTcqwjbeceC54XLL2j3iuTpOQ2f14R2baYfWVzHUrIjHRNqWfe9IEiQ9HAmPgF1ioyo)KaMGczrhZdq)2o9osuJQAxuJVAWOlpChhzfLcz1JAmRgprn(QvaYkjGqGGli6f9quJbv7Zv6u7d1KaMGYsAp8jGxPXQutlDv3RS4e(zSuPuL9aBbHDuzLiJJSq3iXKW1ti4cNWpJf14R2F1qAA8i9o(oapFWZb0JquJzQQDCEEHBpIdof14R2baYfWVzHUrIjHRNqWfe9IEiQ9HAxuJVAfGSGCochexq0l6HOgdQ2NR0P2hQjbmbLL0E4taVsJQrrLnosdMklKZr4GyvQPXtQUxzXj8ZyPsPkBCKgmvwhai)GibWbpyLTGKdSDKgmv2RpGqGGQX5SfrhxulYeGAcSrIAcqnocQwlQfe1c1io4PJSAj4GWqaq1Obq1KBuTCqe120MRMpsdGOAHA090KBewzPbW3GUj10UuLAAmGv3RS4e(zSuPuL9aBbHDuzHinej3HFgvJVAhGNp45a6riRcs3NwuJzQQDrn(Q9xnhpUS0o5gHQ9bv1UOwQuQbrVOhIAFqvnPpBFs7HQXxnIdMZpjGjOqw0X8a0VTtVJe1yMQAUwnkuJVA)vJYQHUrIjHRNqWIAPsPge9IEiQ9bv1K(S9jThQgdQgtQXxnIdMZpjGjOqw0X8a0VTtVJe1yMQAUwnkuJVA)vtcycklP9WNaELgvBJQbrVOhIAuOgZQXd14RMxqee(ccjiKEEq0l6HOgv1(SYghPbtLnjGqGGvPMgpx19kloHFglvkvzPbW3GUj10UuzJJ0GPY6aa5hejao4bRsnnEw19kloHFglvkvzJJ0GPYMeqiqWk7b2cc7OYsz12dyh(zCr22oVZ3tgFjbeceun(QbrAisUd)mQgF1oapFWZb0JqwfKUpTOgZuv7IA8v7VAoECzPDYncv7dQQDrTuPudIErpe1(GQAsF2(K2dvJVAehmNFsatqHSOJ5bOFBNEhjQXmv1CTAuOgF1(RgLvdDJetcxpHGf1sLsni6f9qu7dQQj9z7tApungunMuJVAehmNFsatqHSOJ5bOFBNEhjQXmv1CTAuOgF1(RMeWeuws7Hpb8knQ2gvdIErpe1OqnMv7ctQXxnVGii8fesqi98GOx0drnQQ9zL989KXNeWeui10UuLAAx(S6ELfNWpJLkLQSXrAWuzpW2JaMNGEoirQSfKCGTJ0GPYUjy7raJAUJEoirudmQ5XLL2jJQjbmbfIAHOgp4vTnT5Q97gh1GCZ0tIAaorTEuJjIA)5CutaQXd1KaMGcHc1aq1CnrT)PJx1KaMGcHIk7b2cc7OYsCWC(jbmbfIAmtvnMuJVAq0l6HO2hQXKA8Q2F1ioyo)KaMGcrnMPQw6uJc14RgstJhP3X3b45dEoGEeIAmtvnEuLAAxUuDVYIt4NXsLsv24inyQSqohHdIv2csoW2rAWuz55r0rnoh1spohHdIQfIA8Gx1aJAroRMeWeuiQ9)3noQL79EsuldMe1WbWLCRwmf1gGOgzchYnqOOYEGTGWoQSuwT9a2HFgxKTTZdY5iCqun(Q9xnKMgpsVJVdWZh8Ca9ie1yMQA8qn(QbrAisUd)mQwQuQrz1K(STNe14R2F1K2dvJz1U8PAPsP2b45dEoGEeIAmtvnMuJc1Oqn(Q9xnhpUS0o5gHQ9bv1UOwQuQbrVOhIAFqvnPpBFs7HQXxnIdMZpjGjOqw0X8a0VTtVJe1yMQAUwnkuJVA)vJYQHUrIjHRNqWIAPsPge9IEiQ9bv1K(S9jThQgdQgtQXxnIdMZpjGjOqw0X8a0VTtVJe1yMQAUwnkuJVAsatqzjTh(eWR0OABuni6f9quJz14rvQPDHPQ7vwCc)mwQuQYghPbtLfY5iCqSYEGTGWoQSuwT9a2HFgxKTTZ789KXhKZr4GOA8vJYQThWo8Z4ISTDEqohHdIQXxnKMgpsVJVdWZh8Ca9ie1yMQA8qn(QbrAisUd)mQgF1(RMJhxwANCJq1(GQAxulvk1GOx0drTpOQM0NTpP9q14RgXbZ5NeWeuil6yEa632P3rIAmtvnxRgfQXxT)Qrz1q3iXKW1tiyrTuPudIErpe1(GQAsF2(K2dvJbvJj14RgXbZ5NeWeuil6yEa632P3rIAmtvnxRgfQXxnjGjOSK2dFc4vAuTnQge9IEiQXSA)vJhQXRAqUbPbWeCvcYDpjpYbWnfiMx4e(zSOgdQgptnEvdYninaMGRca45NJcUWj8ZyrngunEIAuuzpFpz8jbmbfsnTlvPM2fxxDVYIt4NXsLsv24inyQShy7raZtqphKiv2csoW2rAWuz3eS9iGrn3rphKiQbg1yDxTMwTEuZjMc61h1IPO2Gbm)vnVWn1WbHjFvlMIAnTAP)SJdWtTFGXvIAfGAEaiQwj8IeuTchQMauZDkDfpLHuzpWwqyhvwIdMZpjGjOquJQAxuJVAinnEKEhFhGNp45a6riQXmv1(R2X55fU9io4uuBJQDrnkuJVAqKgIK7WpJQXxnkRg6gjMeUEcblQXxnkRwb95OPxK7EFX5OgF18cIGWxqibH0ZdIErpe1OQ2NQXxT)QHdct(UkiDFArTpOQgtPtnEvBpGD4NXfoim57dIj48oap)EWIAuOgF1KaMGYsAp8jGxPr12OAq0l6HOgZQXJQuLQuz3riPbtnnM(KPlF66p55QS)c40tcPYYaKHKEPTbt76zy1uZ9BuT2Zbaf1Obq1C1Emn52vQbrgACnelQraEOAbNa8cblQDUJjbjlLXnRhuTlmSABcm7iuWIAUcYninaMGlgORutaQ5ki3G0aycUyGlCc)mwCLA)zYnkwkJBwpOA8egwTnbMDekyrnxb5gKgatWfd0vQja1CfKBqAambxmWfoHFglUsT)xCJILYOYidqgs6L2gmTRNHvtn3Vr1AphauuJgavZvfKo4YIRudIm04AiwuJa8q1cob4fcwu7ChtcswkJBwpOAUMHvBtGzhHcwuJT92KAKVJeUP2gqnbO2MXfQv69M0GrnGdcdbav7)vuO2)lUrXszuzKbidj9sBdM21ZWQPM73OATNdakQrdGQ5khiEaE(H4k1GidnUgIf1iapuTGtaEHGf1o3XKGKLY4M1dQgpyy12ey2rOGf1CLa7zlkRllgORutaQ5kb2ZwuwYLfd0vQ9Nj3OyPmUz9GQXdgwTnbMDekyrnxjWE2IYIPfd0vQja1CLa7zlklHPfd0vQ9Nj3OyPmUz9GQLogwTnbMDekyrnxjWE2IY6YIb6k1eGAUsG9SfLLCzXaDLA)zYnkwkJBwpOAPJHvBtGzhHcwuZvcSNTOSyAXaDLAcqnxjWE2IYsyAXaDLA)zYnkwkJkJmaziPxABW0UEgwn1C)gvR9CaqrnAaunxDkexPgezOX1qSOgb4HQfCcWleSO25oMeKSug3SEq14bdR2MaZocfSOgB7Tj1iFhjCtTnGAcqTnJluR07nPbJAahegcaQ2)ROqT)m5gflLXnRhunEcdR2MaZocfSOgB7Tj1iFhjCtTnGAcqTnJluR07nPbJAahegcaQ2)ROqT)m5gflLXnRhunEgdR2MaZocfSOgB7Tj1iFhjCtTnGAcqTnJluR07nPbJAahegcaQ2)ROqT)m5gflLXnRhuTlFYWQTjWSJqblQX2EBsnY3rc3uBdOMauBZ4c1k9EtAWOgWbHHaGQ9)kku7ptUrXszCZ6bvJPpzy12ey2rOGf1CLa7zlklMwmqxPMauZvcSNTOSeMwmqxP2)lUrXszCZ6bvJPlmSABcm7iuWIAUsG9SfL1Lfd0vQja1CLa7zlkl5YIb6k1(FXnkwkJkJmaziPxABW0UEgwn1C)gvR9CaqrnAaunxvaIRudIm04AiwuJa8q1cob4fcwu7ChtcswkJBwpOA8GHvBtGzhHcwuZvOBKys46jeSSyGUsnbOMRkOphn9IbUq3iXKW1tiyXvQ9)IBuSug3SEq1UWedR2MaZocfSOMRGCdsdGj4Ib6k1eGAUcYninaMGlg4cNWpJfxP2FMCJILYOYO73OAUIJGVwqpIRulosdg1(fe1gGOgnGBkQ1JAYDtuR9CaqzPmUb9CaqblQXaQwCKgmQLBIqwkJvwhiGUZyL9AxtngcHeespH0GrT0dKWHkJx7AQXtd45wTlF6IAm9jtxugvgV21ul9DdpCcwuZhPbquTdWZpe18XKEil1yiNd6ie1gWSX7a6rZLvlosdgIAGj)DPmghPbdz5aXdWZpeQHJt(7Zb0eWOmghPbdz5aXdWZpeEPELpqKmwE054lw(1tYtaU1JYyCKgmKLdepap)q4L6vEbClwE0a4RGHC7Idepap)qEe8aMcHA6CPPPcJU8WDCKvukKvpmFjDkJxtTRdfe61dQ2V7(CR2)MwTy(sHAeje185OPvtG9Sff1(HQ9lgrnbOwic65iQja1iFNJA)A5wTneNcksSugJJ0GHSCG4b45hcVuVApGD4NrxMWdPkWE2IYJ8DopsgiUShzoK6fxAAQcSNTOSUSUdYJiHSI57R4q4)NYcSNTOSyADhKhrczfZ3xXHKkLa7zlkRlRdaKlGFZQWbdPbdZufypBrzX06aa5c43SkCWqAWqHYyCKgmKLdepap)q4L6v7bSd)m6YeEivb2ZwuEKVZ5rYaXL9iZHuzYLMMQa7zlklMw3b5rKqwX89vCi8)tzb2Zwuwxw3b5rKqwX89vCiPsjWE2IYIP1baYfWVzv4GH0GHzb2Zwuwxwhaixa)MvHdgsdgkugJJ0GHSCG4b45hcVuVIiyKLBLX4inyilhiEaE(HWl1Ri5(GVykVsFqxCG4b45hYJGhWuiuV4sttfI0qKCh(zuzuz8AxtT03n8WjyrnChHFvtApun5gvlocaQwtul2Joh(zCPmghPbdH62(Svz8AQLEirWil3Q10Q5aiK2pJQ9FaQTZLheg(zunCqVgjQ1JAhGNFiuOmghPbdHxQxremYYTYyCKgmeEPE1Ea7WpJUmHhsfheM89bXeCEhGNFpyXL9iZHuXbHjFxqmbhEDanbmy55NrSqyqEUnWFMyqIdMZV7GiifkJXrAWq4L6v7bSd)m6YeEivspjz8jbmbfx2JmhsL4G58tcyckKfDmpa9B707i5dMugJJ0GHWl1ROZrcMZH0G5DYyme0LMMAb95OPx05ibZ5qAWSGOx0d5dMugJJ0GHWl1Roro)IJ0G5LBI4YeEivIGrwUXIlnnvIGrwUXYccs4qLX4inyi8s9QtKZV4inyE5MiUmHhs9uiU00u)tzjY4ilVGii8fesqi9SWj8ZyjvQcqwjbeceCj9zBpjuOmEn12Corn256uJZrTEAPJC(RA0aOABItutaQj3OAB6oiOlQbrAisUv7xl3QL(Zooap1AA1crTm4NAfoyinyugJJ0GHWl1Ri5(GVykVsFqxAAQu2NJMErY9bFXuEL(Gloh(hGNp45a6rimt11kJXrAWq4L6v4SJdWZLMMQphn9IK7d(IP8k9bxCo895OPxKCFWxmLxPp4cIErpKpsh)dWZh8Ca9ieMPYdLX4inyi8s9QtKZV4inyE5MiUmHhsTaeLX4inyi8s9QtKZV4inyE5MiUmHhsT0q8ikJXrAWq4L6vb8ed(eaeIJ4sttfheM8Dvq6(0cZuVKoE3dyh(zCHdct((GycoVdWZVhSOmghPbdHxQxfWtm4ZHltqLX4inyi8s9QCNClKhd9CLepCeLX4inyi8s9k)i5bOFcSpBjkJkJx7AQTjaixa)gIY41uBdsRwuke1ciQgNJlQrM2bvtUr1adQ2VwUvld(Hern3D)6wQXqhbv73noQv(2tIA0brqOAYDmQTPnxTcs3Nwudav7xl3aorTy(Q2M28LYyCKgmK1Pq4L6vEbClwE0a4RGHC7Y57jJpjGjOqOEXLMMkm6Yd3XrwrPqwCo8)lbmbLL0E4taVsJFCaE(GNdOhHSkiDFAHbVSsxQuhGNp45a6riRcs3NwyM6X55fU9io4uOqz8AQTbPvBaQfLcrTFDoRwPr1(1YDpQj3OAd6MOMR)K4IACeunEk91PgyuZhqiQ9RLBaNOwmFvBtB(szmosdgY6ui8s9kVaUflpAa8vWqUDPPPcJU8WDCKvukKvpm76p3im6Yd3XrwrPqwfoyiny4FaE(GNdOhHSkiDFAHzQhNNx42J4Gtrz8AQX(DoQXqLJemNdPbJA)A5wTneNcksOwquldMe1cIA)q1(bgxjQLbeuTqTtqe1a7iun5gvJUtUf1kCWqAWOmghPbdzDkeEPEfDosWCoKgmU00uPmrWil3yzbbjCi))haixa)M1oofuKybrVOhYhUMpstJhP3X3b45dEoGEecZu5bFjGjOSK2dFc4vAK5lFMkvb95OPx74uqrIfNtQu(acHpDNClpi6f9q(GjEqHYyCKgmK1Pq4L6v05ibZ5qAW4sttLYebJSCJLfeKWH8rAA8i9o(oapFWZb0JqyMkp4)NodaW))P7KB5brVOhYgzIhuSboaqUa(nuWmDgaG))t3j3YdIErpKnYep24baYfWVzTJtbfjwq0l6HWG7bSd)mU2XPGIeVtbsXg4aa5c43qbfkJxtn2VZrnw0H0e1(1YTABiofuKqTGOwgmjQfe1(HQ9dmUsuldiOAHANGiQb2rOAYnQgDNClQv4GH0GXf185e1CGincvtcycke1K7qu7xNZQL7DuTqulJbru7YNeLX4inyiRtHWl1RiOdPjU00uPmrWil3yzbbjCi))haixa)M1oofuKybrVOhYhx4lbmbLL0E4taVsJmF5ZuPkOphn9AhNcksS4CsLIUtULhe9IEiFC5tkugJJ0GHSofcVuVIGoKM4sttLYebJSCJLfeKWH8)tNba4))0DYT8GOx0dzJx(KInWbaYfWVHcMPZaa8)F6o5wEq0l6HSXlFUXdaKlGFZAhNcksSGOx0dHb3dyh(zCTJtbfjENcKInWbaYfWVHckugVMASFNJABiofuKqTF9ua)u7xl3QLwNClejYBriVPVBKys46jeuTMwTWXj3NWpJkJXrAWqwNcHxQxThWo8ZOlt4Hu3XPGIeVPtUfIe5Ti8DatPLgmUShzoKkLLiJJSMo5wisK3IWfoHFglPsrzjY4il0nsmjC9ecUWj8ZyjvQdaKlGFZcDJetcxpHGli6f9q(iDBKjguImoYQGOdcFebgsKGElCc)mwugVMASFNJABiofuKqTFTCRgdvosWCoKgmQftrnw0H0e1cIAzWKOwqu7hQ2pW4krTmGGQfQDcIOgyhHQj3OA0DYTOwHdgsdgLX4inyiRtHWl1R2dyh(z0Lj8qQ74uqrI3bSJtmY7aMslnyCPPPEa74eJS2(f2XKk1bSJtmYAWdeKbWsQuhWooXiRbmOl7rMdPErzmosdgY6ui8s9Q9a2HFgDzcpK6oofuK4Da74eJ8oGP0sdgxAAQhWooXiRDCK7Vqx2JmhsLodaW))P7KB5brVOhYgz6tk2a)VW0Nm4Ea7WpJRDCkOiX7uGuqbZ0zaa()pDNClpi6f9q2itFUXdaKlGFZIohjyohsdMfe9IEiuSb(FHPpzW9a2HFgx74uqrI3PaPGIuP85OPx05ibZ5qAW885OPxCoPsvqFoA6fDosWCoKgmloNuPO7KB5brVOhYhm9PYyCKgmK1Pq4L6v7bSd)m6YeEi1DCkOiX7a2Xjg5DatPLgmU00upGDCIrwtNClp6aDzpYCiv6maa))NUtULhe9IEiBKPpPyd8)ctFYG7bSd)mU2XPGIeVtbsbfmtNba4))0DYT8GOx0dzJm95gpaqUa(nlc6qAYcIErpek2a)VW0Nm4Ea7WpJRDCkOiX7uGuqrQufGSiOdPjlPpB7jjvk6o5wEq0l6H8btFQmghPbdzDkeEPE1oofuKWLMMkLjcgz5glliiHd5xaYcY5iCqCj9zBpj8PCb95OPx74uqrIfNd)9a2HFgx74uqrI30j3crI8we(oGP0sdg(7bSd)mU2XPGIeVdyhNyK3bmLwAWOmEn1sF3iXKW1tiOA)UXrTbiQremYYnwulMIA(a5wT0JZr4GOAXuu76dieiOAbevJZrnAauTmysudhaxY9szmosdgY6ui8s9k0nsmjC9ec6sttLYebJSCJLfeKWH8)t5cqwjbeceCbrAisUd)mYVaKfKZr4G4cIErpeM5bV8GbpopVWThXbNsQufGSGCochexq0l6HWGFUshZsatqzjTh(eWR0if8LaMGYsAp8jGxPrM5HY41uJ9U3vRPv7hQwar1cFaNOMaul9NDCaEUOwmf1crqphrnbOg57Cu7xl3QXIoKMOgDprwT7wuRPv7hQ2pW4krTFbrq18aqun5og1UJmTAYnQ2baYfWVzPmghPbdzDkeEPEf5U3DPPPwaYcY5iCqCj9zBpj8)t5daKlGFZIGoKMSGyu(Mk1baYfWVzTJtbfjwq0l6HW8fMOivQcqwe0H0KL0NT9KOmghPbdzDkeEPELdqAW4stt1NJME5NbGsMJilighjvkFaHWNUtULhe9IEiF46ptLQG(C00RDCkOiXIZrzmosdgY6ui8s9k)mauE0CWVU00ulOphn9AhNcksS4CugJJ0GHSofcVuVYhHeeUTNexAAQf0NJMETJtbfjwCokJXrAWqwNcHxQxr3q0pdafxAAQf0NJMETJtbfjwCokJXrAWqwNcHxQxfZbjcmYVtKZU00ulOphn9AhNcksS4CugJJ0GHSofcVuV6e58losdMxUjIlt4Hu3JPj3U00uPmrWil3yzf5mFVGii8fesqi98GOx0dH6NkJxtn2VZrn5gvZb2aylFvJiHOMphnTAcSNTOO2VwUvBdXPGIeUOgqUr4VMGQXrq1aJAhaixa)gLX4inyiRtHWl1ReypBr5Ilnn19a2HFgxcSNTO8iFNZJKbc1l8)xqFoA61oofuKyX5KkLpGq4t3j3YdIErpKpOY0NuKk1)9a2HFgxcSNTO8iFNZJKbcvM4tzb2ZwuwmToaqUa(nligLVuKkfL3dyh(zCjWE2IYJ8DopsgikJXrAWqwNcHxQxjWE2IctU00u3dyh(zCjWE2IYJ8DopsgiuzI))c6ZrtV2XPGIeloNuP8becF6o5wEq0l6H8bvM(KIuP(VhWo8Z4sG9SfLh57CEKmqOEHpLfypBrzDzDaGCb8BwqmkFPivkkVhWo8Z4sG9SfLh57CEKmqugvgV21u76AiEe1kHxKGQf(DULgjkJxtT0F2Xb4PwiQXdEv7F64vTFTCR21XsHABAZxQTb98WshcM)QgyuJjEvtcyckexu7xl3QTH4uqrcxudav7xl3Q5oLyaOAa5gH)AcQ2VOf1Obq1iapunCqyY3LAmKmbO2VOf1AA1sF3ijQDaE(a1AIAhGxpjQX5SugJJ0GHSknepcvC2Xb45sttfPPXJ0747a88bphqpcHzQ8GxjY4iRcIoi8reyirc6TWj8ZyH))c6ZrtV2XPGIeloNuPkOphn9IC37loNuPkOphn9IohjyohsdMfNtQu4GWKVRcs3Nw(GktPJ39a2HFgx4GWKVpiMGZ7a887blPsr59a2HFgxKEsY4tcyckuW)pLLiJJSq3iXKW1ti4cNWpJLuPoaqUa(nl0nsmjC9ecUGOx0dHzMOqzmosdgYQ0q8i8s9Q9a2HFgDzcpKkhbF0DoJqx2Jmhs9a88bphqpczvq6(0cZxsLcheM8Dvq6(0YhuzkD8UhWo8Z4cheM89bXeCEhGNFpyjvkkVhWo8Z4I0tsgFsatqrzmosdgYQ0q8i8s9kccHHGLNpyWhXP3IUC(EY4tcyckeQxCPPP6febHVGqccPNhe9IEiu)K)FFoA6fj3h8ft5v6dU4C4t5cqweecdblpFWGpItVfFfGSK(STNKuP8becF6o5wEq0l6H8b10Lk1baYfWVzrqimeS88bd(io9wCDUdycsE0W4inyImZuzAXaMUuPiaUSFpLvgJYZ)7dDl8CY4cNWpJf(u2NJMELXO88)(q3cpNmU4COqz8AQXqfJAaA145NEhjQfIAx4z8QgrIZwIAaA1yaSlfCuJs5OGe1aq1IKOhIOgp4vnjGjOqwkJXrAWqwLgIhHxQxrhZdq)2o9osCPPPUhWo8Z4IJGp6oNri))(C00R7UuW55NJcswejoBzM6fEwQu)PSdSbWw((GajKgm8joyo)KaMGczrhZdq)2o9osyMkp4LiyKLBSSGGeoKckugVMAmuXOgGwnE(P3rIAcqTWXj)vTRdJs(RABoOjGrTMwTEIJ07OAGrTy(QMeWeuule1CTAsatqHSugJJ0GHSknepcVuVIoMhG(TD6DK4Y57jJpjGjOqOEXLMM6Ea7WpJloc(O7CgH8joyo)KaMGczrhZdq)2o9osyMQRvgJJ0GHSknepcVuVcp3GEsEq0b2EXuCPPPUhWo8Z4IJGp6oNri)daKlGFZAhNcksSGOx0dH5lFQmghPbdzvAiEeEPEv45ZrUDPPPUhWo8Z4IJGp6oNri))Ebrq4liKGq65brVOhc1ptLYNJME5N7Pq6cU4COqz8AQ5E4VrEkN05qq1eGAHJt(RAxhgL8x12CqtaJAHOgtQjbmbfIYyCKgmKvPH4r4L6vECsNdbD589KXNeWeuiuV4sttDpGD4NXfhbF0DoJq(ehmNFsatqHSOJ5bOFBNEhjuzszmosdgYQ0q8i8s9kpoPZHGU00u3dyh(zCXrWhDNZiuzuz8AxtTRl8IeunWocvtApuTWVZT0irz8AQTzTxlQD9beceKOgyuBaZgDGThmGFvtcycke1Obq1KBunhydGT8vniqcPbJAnTAPJx18ZiwiQfquTidXO8vnohLX4inyiRcqOUhWo8ZOlt4HujBBN357jJVKacbc6YEK5qQoWgaB57dcKqAWWN4G58tcyckKfDmpa9B707iHzxZ)FbiRKacbcUGOx0d5JdaKlGFZkjGqGGRchmKgmPs5aAcyWYZpJyHWC6Oqz8AQTzTxlQLECochejQbg1gWSrhy7bd4x1KaMGcrnAaun5gvZb2aylFvdcKqAWOwtRw64vn)mIfIAbevlYqmkFvJZrzmosdgYQaeEPE1Ea7WpJUmHhsLSTDENVNm(GCocheDzpYCivhydGT89bbsiny4tCWC(jbmbfYIoMhG(TD6DKWSR5)VG(C00lYDVV4CsLYb0eWGLNFgXcH50rHY41uBZAVwul94CeoisuRPvBdXPGIe8YE37xXtdIGq1yiesqi9OwtuJZrTykQ9dv7o2r1yIx1i4bmfIAzKwudmQj3OAPhNJWbr1UoG7kJXrAWqwfGWl1R2dyh(z0Lj8qQKTTZdY5iCq0L9iZHulOphn9AhNcksS4C4)VG(C00lYDVV4CsLYliccFbHeesppi6f9qy(tk4xaYcY5iCqCbrVOhcZmPmEn1yDWthz1U(acbcQwmf1spohHdIQrqHZrnhydGQja1sF3iXKW1tiOANGikJXrAWqwfGWl1RscieiOlnnvjY4il0nsmjC9ecUWj8ZyHpLr3iXKW1tiyzLeqiqq(fGSsciei4YXJllTtUr4huVW)aa5c43Sq3iXKW1ti4cIErpKpyIpXbZ5NeWeuil6yEa632P3rc1l8HrxE4ooYkkfYQhM5j8lazLeqiqWfe9IEim4NR09HeWeuws7Hpb8knQmghPbdzvacVuVcY5iCq0LMMQezCKf6gjMeUEcbx4e(zSW)pstJhP3X3b45dEoGEecZupopVWThXbNc)daKlGFZcDJetcxpHGli6f9q(4c)cqwqohHdIli6f9qyWpxP7djGjOSK2dFc4vAKcLXRP21hqiqq14C2IOJlQfzcqnb2irnbOghbvRf1cIAHAeh80rwTeCqyiaOA0aOAYnQwoiIABAZvZhPbquTqn6EAYncvgJJ0GHSkaHxQx5aa5hejao4bDHgaFd6Mq9IYyCKgmKvbi8s9QKacbc6sttfI0qKCh(zK)b45dEoGEeYQG09PfMPEH)FhpUS0o5gHFq9sQuq0l6H8bvPpBFs7H8joyo)KaMGczrhZdq)2o9osyMQRPG)FkJUrIjHRNqWsQuq0l6H8bvPpBFs7Hmit8joyo)KaMGczrhZdq)2o9osyMQRPG)FjGjOSK2dFc4vACJq0l6HqbZ8GVxqee(ccjiKEEq0l6Hq9tLX4inyiRcq4L6voaq(brcGdEqxObW3GUjuVOmghPbdzvacVuVkjGqGGUC(EY4tcyckeQxCPPPs59a2HFgxKTTZ789KXxsaHab5drAisUd)mY)a88bphqpczvq6(0cZuVW)VJhxwANCJWpOEjvki6f9q(GQ0NTpP9q(ehmNFsatqHSOJ5bOFBNEhjmt11uW)pLr3iXKW1tiyjvki6f9q(GQ0NTpP9qgKj(ehmNFsatqHSOJ5bOFBNEhjmt11uW)VeWeuws7Hpb8knUri6f9qOG5lmX3liccFbHeesppi6f9qO(PY41uBtW2Jag1Ch9CqIOgyuZJllTtgvtcycke1crnEWRABAZv73noQb5MPNe1aCIA9Ogte1(Z5OMauJhQjbmbfcfQbGQ5AIA)thVQjbmbfcfkJXrAWqwfGWl1RoW2JaMNGEoirCPPPsCWC(jbmbfcZuzIpe9IEiFWeV)joyo)KaMGcHzQPJc(innEKEhFhGNp45a6rimtLhkJxtnEEeDuJZrT0JZr4GOAHOgp4vnWOwKZQjbmbfIA))DJJA5EVNe1YGjrnCaCj3QftrTbiQrMWHCdekugJJ0GHSkaHxQxb5Ceoi6sttLY7bSd)mUiBBNhKZr4Gi))innEKEhFhGNp45a6rimtLh8Hinej3HFgtLIYsF22tc))s7HmF5ZuPoapFWZb0JqyMktuqb))oECzPDYnc)G6LuPGOx0d5dQsF2(K2d5tCWC(jbmbfYIoMhG(TD6DKWmvxtb))ugDJetcxpHGLuPGOx0d5dQsF2(K2dzqM4tCWC(jbmbfYIoMhG(TD6DKWmvxtbFjGjOSK2dFc4vACJq0l6HWmpugJJ0GHSkaHxQxb5Ceoi6Y57jJpjGjOqOEXLMMkL3dyh(zCr22oVZ3tgFqohHdI8P8Ea7WpJlY225b5CeoiYhPPXJ0747a88bphqpcHzQ8GpePHi5o8Zi))oECzPDYnc)G6LuPGOx0d5dQsF2(K2d5tCWC(jbmbfYIoMhG(TD6DKWmvxtb))ugDJetcxpHGLuPGOx0d5dQsF2(K2dzqM4tCWC(jbmbfYIoMhG(TD6DKWmvxtbFjGjOSK2dFc4vACJq0l6HW8FEWlKBqAambxLGC3tYJCaCtbIzgKNXlKBqAambxfaWZphfKb5juOmEn12eS9iGrn3rphKiQbg1yDxTMwTEuZjMc61h1IPO2Gbm)vnVWn1WbHjFvlMIAnTAP)SJdWtTFGXvIAfGAEaiQwj8IeuTchQMauZDkDfpLHOmghPbdzvacVuV6aBpcyEc65GeXLMMkXbZ5NeWeuiuVWhPPXJ0747a88bphqpcHzQ)popVWThXbNYgVqbFisdrYD4Nr(ugDJetcxpHGf(uUG(C00lYDVV4C47febHVGqccPNhe9IEiu)K)FCqyY3vbP7tlFqLP0X7Ea7WpJlCqyY3hetW5DaE(9Gfk4lbmbLL0E4taVsJBeIErpeM5HYOY41UMAScgz5glQXqosdgIY41ulTo5MirElcvdmQ5A3zy12eS9iGrn3rphKikJXrAWqwebJSCJfQhy7raZtqphKiU00uLiJJSMo5wisK3IWfoHFgl8joyo)KaMGcHzQUM)b45dEoGEecZu5bFjGjOSK2dFc4vACJq0l6HWmprz8AQLwNCtKiVfHQbg1U4odRg7eoKBGOw6X5iCquzmosdgYIiyKLBSWl1RGCocheDPPPkrghznDYTqKiVfHlCc)mw4FaE(GNdOhHWmvEWxcycklP9WNaELg3ie9IEimZtugVMASC(ccP5sqgwngIJt(RAaOAPhsdrYTA)A5wnFoAASO21hqiqqIYyCKgmKfrWil3yHxQx5aa5hejao4bDHgaFd6Mq9IYyCKgmKfrWil3yHxQxLeqiqqxoFpz8jbmbfc1lU00uLiJJSiC(ccP5sWfoHFgl8)drVOhYhxykvkhpUS0o5gHFq9cf8LaMGYsAp8jGxPXncrVOhcZmPmEn1y58fesZLGQXRAPVBKe1aJAxCNHvl9qAisUv76dieiOAHOMCJQHtrnaTAebJSCRMaulbf18c3uRWbdPbJA(inaIQL(UrIjHRNqqLX4inyilIGrwUXcVuVYbaYpisaCWd6cna(g0nH6fLX4inyilIGrwUXcVuVkjGqGGU00uLiJJSiC(ccP5sWfoHFgl8LiJJSq3iXKW1ti4cNWpJf(Xr6D8Hd61iH6f((C00lcNVGqAUeCbrVOhYhxwUwzmosdgYIiyKLBSWl1R84Kohc6sttvImoYIW5liKMlbx4e(zSW)a88bphqpc5dQUwzuz8AxtTnmMMCRmEn1yO6Pj3Q9RLB18c3uBtBUA0aOAP1j3crI8we6IACtgje14i9KO21HHCN)Qg7Dua)ikJXrAWqw7X0KBQ7bSd)m6YeEi1PtUfIe5Ti8DCEhWuAPbJl7rMdP(NYqUbPbWeCvWqUZFFK7Oa(r4J004r6D8DaE(GNdOhHWm1JZZlC7rCWPqrQu)HCdsdGj4QGHCN)(i3rb8JW)a88bphqpc5dMOqz8AQTHX0KB1(1YTAPVBKe14vT06KBHirElczy14PHBThNNABAZvlMIAPVBKe1Gyu(QgnaQ2GUjQD9B66ugJJ0GHS2JPj38s9Q9yAYTlnnvjY4il0nsmjC9ecUWj8ZyHVezCK10j3crI8weUWj8ZyH)Ea7WpJRPtUfIe5Ti8DCEhWuAPbd)daKlGFZcDJetcxpHGli6f9q(4IY41uBdJPj3Q9RLB1sRtUfIe5TiunEvlnGAPVBKegwnEA4w7X5P2M2C1IPO2gItbfjuJZrzmosdgYApMMCZl1R2JPj3U00uLiJJSMo5wisK3IWfoHFgl8PSezCKf6gjMeUEcbx4e(zSWFpGD4NX10j3crI8we(ooVdykT0GHFb95OPx74uqrIfNJYyCKgmK1Emn5MxQx5aa5hejao4bDHgaFd6Mq9IlOBcmEHhGBeQ8iDkJXrAWqw7X0KBEPE1Emn52LMMQezCKfHZxqinxcUWj8ZyH)baYfWVzLeqiqWfNd))fGSsciei4cI0qKCh(zmvQc6ZrtV2XPGIeloh(fGSsciei4YXJllTtUr4huVqb)dWZh8Ca9iKvbP7tlmt9pXbZ5NeWeuil6yEa632P3rcZmaGhuWhgD5H74iROuiREy(ctkJxtTnmMMCR2VwUvJNgebHQXqiKG0ddRw6X5iCqK3RpGqGGQnarTEudI0qKCRgmMe0f1kCWEsuBdXPGIe8YE37l1y)oh1(1YTASOdPjQr3tKv7Uf1AA1Caes7NXLYyCKgmK1Emn5MxQxThttUDPPP(xImoYYliccFbHeesplCc)mwsLcYninaMGlVaU9bOFYn(8cIGWxqibH0df8PCbiliNJWbXfePHi5o8Zi)cqwjbeceCbrVOhcZUMFb95OPx74uqrIfNd))f0NJMErU79fNtQuf0NJMETJtbfjwq0l6H8bpsLQaKfbDinzj9zBpjuWVaKfbDinzbrVOhYhUUYsCWtnnMshpRkvPwb]] )

end