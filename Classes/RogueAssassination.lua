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
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld" }
    }


    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.sepsis_buff.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.sepsis_buff.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
            end

            return false
        end
    } ) )


    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not talent.master_assassin.enabled then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 3
        elseif buff.master_assassin.up then return buff.master_assassin.remains end
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
                return stealthed.all or buff.subterfuge.up or buff.sepsis_buff.up, "not stealthed"
            end,

            handler = function ()
                applyDebuff( "target", "cheap_shot" )
                gain( 2, "combo_points" )

                removeBuff( "sepsis_buff" )

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

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 3565450,

            toggle = "essences",

            handler = function ()
                -- Can't predict the Animacharge.
                gain( buff.broadside.up and 4 or 3, "combo_points" )
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


    spec:RegisterPack( "Assassination", 20201213, [[daLiwbqiOkEKOexsLscBcL8jkQyuIcNsu0QqfPxHkzwOsDlOKAxs1VevAyuu1XGIwMOupdkX0qf11OiSnvkvFJIkzCuuPCovkfRtLs8okIs18uP4EQK9bL6FQus0bHssluuXdPiYerfHlIkI2ifvQ(OOK0iPikLtQsj1kHcVKIOKzkkP6MIsIDcv1qPiQwkus8uKAQOcxvLssTvrjLVsruySQukTxs(RugSIdt1IrvpwftwKld2ms(mfgnk1PLSAvkj51QunBkDBs1Uv63igoPCCkIIwoKNRQPtCDuSDOY3HQ04PiDEkkZxu1(fwHPIdfDYfqHF2MpBZJz2yILoMybZBhlyrrlMPbkAn)C3naf966GIgR(V)FTUuKvrR5MzjEsXHI(jmOdOOzlI2Fl5MRrjSz47hIEUFPZyDPi7b5usUFPFYvrZZuw5wVkEfDYfqHF2MpBZJz2yILoMybZBhlkANrytqkA6s3Ku0SRucwfVIob)rrNLyWQ)7)xRlfzJbRqmyGaJSedNaoGopGIbtSWDmzB(SnFGrGrwIjRqWbPym3TUbyTUuKnMmmjl47dzgdJwm1gJgQiOsmlMNetjXGxcJnfZsKymajgEgubPy4b21MI5fWTc7y8JuK97kAB9YR4qr)c4wHnKuCOWhtfhkAyDElKu5OOpOsau5kAXTWk9TmylV427aQdRZBHumSI51aRTjoYaKpgSVIblXWkMdrNN00i1kFmyFfdNJHvmIJmaPlLo0eslvqmyDmiq3R9Jb7yUDfTFKISk6dQ0FY2eqxdErjk8ZwXHIgwN3cjvok6dQeavUIwClSsFld2YlU9oG6W68wifdRyoeDEstJuR8XG9vmCogwXioYaKUu6qtiTubXG1XGaDV2pgSJ52v0(rkYQOrmAcdcuIcFSO4qrdRZBHKkhfnfb1wWurHpMkA)ifzv0AeITHGNWGoGsu4ZzfhkAyDElKu5OO9JuKvrB4ieraf9bvcGkxrlUfwP)m8cGOymGoSoVfsXWkMmIbb6ETFm3edMzht(8XOPZyLsZwakMBUIbZyYmgwXioYaKUu6qtiTubXG1XGaDV2pgSJjBf9XSJfAIJma5v4JPsu4BcfhkAyDElKu5OOPiO2cMkk8Xur7hPiRIwJqSne8eg0buIc)BxXHIgwN3cjvok6dQeavUIwClSs)z4farXyaDyDElKIHvmIBHv6GPVVgm16c0H15TqkgwX4hPWbnyb9c(yUIbZyyfdpdfv)z4farXyaDeO71(XCtmy2XII2psrwfTHJqebuIcFZLIdfnSoVfsQCu0hujaQCfT4wyL(ZWlaIIXa6W68wifdRyoeDEstJuR8XCZvmyrr7hPiRIwNrkRlGsuIIgNV1ZwXHcFmvCOOH15TqsLJIMOPOFqu0(rkYQOX5OY5TGIgNBzafDgXGNyqmlqrqgqpbUW2Aw7z7jcE)oSoVfsXWkgGIcosHdAhIopPPrQv(yW(kMJwt3nT9AWMIjZyYNpMmIbXSafbza9e4cBRzTNTNi497W68wifdRyoeDEstJuR8XCtmzhtMkACoQTUoOO3YGT8IBVdO2rRDiBQKISkrHF2kou0W68wiPYrrFqLaOYv0IBHv6GPVVgm16c0H15TqkgwXiUfwPVLbB5f3EhqDyDElKIHvm4Cu58wOVLbB5f3EhqTJw7q2ujfzJHvmhcXMi4D7GPVVgm16c0rGUx7hZnXGPI2psrwfnoFRNTsu4JffhkAyDElKu5OOpOsau5kAXTWk9TmylV427aQdRZBHumSIbpXiUfwPdM((AWuRlqhwN3cPyyfdohvoVf6BzWwEXT3bu7O1oKnvsr2yyftc4zOO64GnbI4DgnfTFKISkAC(wpBLOWNZkou0W68wiPYrr7hPiRIwJqSne8eg0bu0GPcYBUoHzffnNnHIMIGAlyQOWhtLOW3ekou0W68wiPYrrFqLaOYv0IBHv6pdVaikgdOdRZBHumSI5qi2ebVB3WriIaDgTyyftgXKis3WriIaDeqHGNTZBHyYNpMeWZqr1XbBceX7mAXWkMer6gocreORPZyLsZwakMBUIbZyYmgwXCi68KMgPw57jGQoLed2xXKrmVgyTnXrgG8DkFBeQ29TWbFmyFRmgohtMXWkgKxPgGdwP7P03RngSJbZSv0(rkYQOX5B9SvIc)BxXHIgwN3cjvok6dQeavUIoJye3cR019xauZ)3)V2oSoVfsXKpFmiMfOiidOR7O7ncvtydnD)fa18)9)RTdRZBHumzgdRyWtmjI0rmAcdc6iGcbpBN3cXWkMer6gocreOJaDV2pgSJblXWkMeWZqr1XbBceX7mAXWkMeWZqr1F2fUoJMI2psrwfnoFRNTsuIIobuoJvuCOWhtfhkA)ifzv03RZDfnSoVfsQCuIc)SvCOO9JuKvr)c4wHTIgwN3cjvokrHpwuCOOH15TqsLJIMOPOFqu0(rkYQOX5OY5TGIgNBzafnSaYWSocmGngUIrJupzHuJ3cq6JHtJXCftUXKrmzhdNgZRbwBJT)cetMkACoQTUoOOHfqgM1qGbSTdrNVwiPef(CwXHIgwN3cjvokAIMI(brr7hPiRIgNJkN3ckACULbu0VgyTnXrgG8DkFBeQ29TWbFm3et2kACoQTUoOO)AnSqtCKbikrHVjuCOOH15TqsLJI(GkbqLROtapdfvNY6gG16sr2oc09A)yUjMSv0(rkYQOPSUbyTUuKTDSGVpOef(3UIdfnSoVfsQCu0hujaQCf9lGBf2qQJigmGI2psrwf9XT2MFKISnB9II2wV0wxhu0VaUvydjLOW3CP4qrdRZBHKkhf9bvcGkxrNrm4jgXTWkDD)fa18)9)RTdRZBHum5ZhtIiDdhHic0L6CVwJyYur7hPiRI(4wBZpsr2MTErrBRxARRdk6t6vIcFZnfhkAyDElKu5OOpOsau5k6xdS2M4idq(oLVncv7(w4GpMBUIjJymrmyDmiMfOiidON8NDTgT)qy2ecSDyDElKIjZyyfdpdfv)T1bA(MAP6aDeO71(XCtmuLbBPHaDV2pgwXGake8SDEledRyoeDEstJuR8XG9vmyrr7hPiRI(T1bA(MAP6akrH)TrXHIgwN3cjvokA)ifzv0h3AB(rkY2S1lkAB9sBDDqrNiIsu4JP5vCOOH15TqsLJI2psrwf9XT2MFKISnB9II2wV0wxhu0Pcbhrjk8XetfhkAyDElKu5OOpOsau5kAybKHz9eqvNsIb7RyW0eXWvm4Cu58wOdlGmmRHadyBhIoFTqsr7hPiRI2rhFHMqqiyfLOWhZSvCOO9JuKvr7OJVqtJX(GIgwN3cjvokrHpMyrXHI2psrwfTTmylF7wftYqhwrrdRZBHKkhLOWhtoR4qr7hPiRIM3nAeQMGQZ9xrdRZBHKkhLOefTgcoeDExuCOWhtfhkA)ifzv0UMM1SMgPEYQOH15TqsLJsu4NTIdfTFKISkAEIiwi1OSUzqcV1A0eIP1QOH15TqsLJsu4JffhkAyDElKu5OO9JuKvrR7O7qQrrqTe4cBf9bvcGkxrJ8k1aCWkDpL(ETXGDmyAcfTgcoeDExApCiB6v0Mqjk85SIdfTFKISk6xa3kSv0W68wiPYrjk8nHIdfnSoVfsQCu0(rkYQOFBDGMVPwQoGI(GkbqLROrafcE2oVfu0Ai4q05DP9WHSPxrJPsuIIovi4ikou4JPIdfnSoVfsQCu0hujaQCfnqrbhPWbTdrNN00i1kFmyFfdNJHRye3cR0taObO2lixCdqVdRZBHumSIjJysapdfvhhSjqeVZOft(8XKaEgkQ(ZUW1z0IjF(yGfqgM1tavDkjMBUIjBtedxXGZrLZBHoSaYWSgcmGTDi681cPyYNpg8edohvoVf6FTgwOjoYaKyYmgwXKrm4jgXTWkDW03xdMADb6W68wift(8XCieBIG3TdM((AWuRlqhb6ETFmyht2XKPI2psrwfnS4GLORef(zR4qrdRZBHKkhfnrtr)GOO9JuKvrJZrLZBbfno3Yak6drNN00i1kFpbu1PKyWogmJjF(yGfqgM1tavDkjMBUIjBtedxXGZrLZBHoSaYWSgcmGTDi681cPyYNpg8edohvoVf6FTgwOjoYaefnoh1wxhu0mp0OkRfqkrHpwuCOOH15TqsLJI2psrwf9diKlqQXtwO9A1DqrFqLaOYv08muu93whO5BQLQd0z0IHvm4jMer6pGqUaPgpzH2Rv3HwIiDPo3R1iM85JHQmylneO71(XCZvmMiM85J5qi2ebVB)beYfi14jl0ET6o0pSDKb8nkKFKISUngSVIj7U5YeXKpFmpHXYxBQBbp14nRbM66AwOdRZBHumSIbpXWZqr1TGNA8M1atDDnl0z0u0hZowOjoYaKxHpMkrHpNvCOOH15TqsLJI(GkbqLROX5OY5TqN5HgvzTakgwXKrm8muuD2vkbBJ36j47V4N7XG9vmyEBIjF(yYig8eJgQiOsmRHiIlfzJHvmVgyTnXrgG8DkFBeQ29TWbFmyFfdNJHRyEbCRWgsDeXGbIjZyYur7hPiRIMY3gHQDFlCWRef(MqXHIgwN3cjvokA)ifzv0u(2iuT7BHdEf9bvcGkxrJZrLZBHoZdnQYAbumSI51aRTjoYaKVt5BJq1UVfo4Jb7RyWII(y2XcnXrgG8k8Xujk8VDfhkAyDElKu5OOpOsau5kACoQCEl0zEOrvwlGIHvmhcXMi4D74GnbI4DeO71(XGDmyAEfTFKISkA4WMuRrdbAOs33Ksu4BUuCOOH15TqsLJI(GkbqLROX5OY5TqN5HgvzTasr7hPiRI215zE2krHV5MIdfnSoVfsQCu0(rkYQO1zKY6cOOpOsau5kACoQCEl0zEOrvwlGIHvmVgyTnXrgG8DkFBeQ29TWbFmxXKTI(y2XcnXrgG8k8Xujk8Vnkou0W68wiPYrrFqLaOYv04Cu58wOZ8qJQSwaPO9JuKvrRZiL1fqjkrrFsVIdf(yQ4qr7hPiRIMY6gG16srwfnSoVfsQCuIc)SvCOOH15TqsLJI2psrwfTUJUdPgfb1sGlSv0hujaQCfnYRudWbR09u67mAXWkMmIrCKbiDP0HMqAPcI5MyoeDEstJuR89eqvNsIHtJbZUjIjF(yoeDEstJuR89eqvNsIb7RyoAnD302RbBkMmv0hZowOjoYaKxHpMkrHpwuCOOH15TqsLJI(GkbqLROrELAaoyLUNsFV2yWogSy(yW6yqELAaoyLUNsFpXGCPiBmSI5q05jnnsTY3tavDkjgSVI5O10DtBVgSjfTFKISkADhDhsnkcQLaxyRef(CwXHIgwN3cjvokAIMI(brr7hPiRIgNJkN3ckACULbu04jgXTWk9TmylV427aQdRZBHum5ZhdEIrClSshm991GPwxGoSoVfsXKpFmhcXMi4D7GPVVgm16c0rGUx7hZnXyIyW6yYogongXTWk9eaAaQ9cYf3a07W68wiPOX5O266GIghSjqeVTLbB5f3EhqTdztLuKvjk8nHIdfnSoVfsQCu0hujaQCfnEI5fWTcBi1redgigwXKishXOjmiOl15ETgXWkg8etc4zOO64GnbI4DgTyyfdohvoVf64GnbI4TTmylV427aQDiBQKISkA)ifzv04GnbI4krH)TR4qrdRZBHKkhf9bvcGkxrJNyEbCRWgsDeXGbIHvmzedEIjrKUHJqeb6iGcbpBN3cXWkMer6ignHbbDeO71(XGDmCogUIHZXWPXC0A6UPTxd2um5ZhtIiDeJMWGGoc09A)y40ymF3eXGDmIJmaPlLo0eslvqmzgdRyehzasxkDOjKwQGyWogoRO9JuKvrdM((AWuRlGsu4BUuCOOH15TqsLJI(GkbqLROtePJy0ege0L6CVwJyYNpMer6pO913L6CVwdfTFKISk6NDHtjk8n3uCOOH15TqsLJI(GkbqLRO5zOO68wcjzzEPJa)iXKpFmuLbBPHaDV2pMBIblMpM85Jjb8muuDCWMar8oJMI2psrwfTgrkYQef(3gfhkAyDElKu5OOpOsau5k6eWZqr1XbBceX7mAkA)ifzv08wcj1OyqMPef(yAEfhkAyDElKu5OOpOsau5k6eWZqr1XbBceX7mAkA)ifzv08a6b09AnuIcFmXuXHIgwN3cjvok6dQeavUIob8muuDCWMar8oJMI2psrwfnvHaElHKuIcFmZwXHIgwN3cjvok6dQeavUIob8muuDCWMar8oJMI2psrwfTVh4fKBBh3AvIcFmXIIdfnSoVfsQCu0hujaQCfnEI5fWTcBi1DRngwXO7VaOM)V)FTneO71(XCfJ5v0(rkYQOpU128JuKTzRxu026L266GIgNV1Zwjk8XKZkou0W68wiPYrr7hPiRI2W6PYfc6B6qYT2ISk6dQeavUIob8muuDCWMar8oJMIgOOGJ0wxhu0gwpvUqqFthsU1wKvjk8X0ekou0W68wiPYrr7hPiRI2W6PYfc6B8EYau0hujaQCfDc4zOO64GnbI4DgnfnqrbhPTUoOOnSEQCHG(gVNmaLOWhZBxXHI2psrwfnZdTsa9xrdRZBHKkhLOefDIikou4JPIdfnSoVfsQCu0enf9dII2psrwfnohvoVfu04CldOO1qfbvIznerCPiBmSI51aRTjoYaKVt5BJq1UVfo4Jb7yWsmSIjJysePB4ierGoc09A)yUjMdHyte8UDdhHic0tmixkYgt(8XOrQNSqQXBbi9XGDmMiMmv04CuBDDqr)3lT2XSJfAgocreqjk8ZwXHIgwN3cjvokAIMI(brr7hPiRIgNJkN3ckACULbu0AOIGkXSgIiUuKngwX8AG12ehzaY3P8TrOA33ch8XGDmyjgwXKrmjGNHIQ)SlCDgTyYNpgns9KfsnElaPpgSJXeXKPIgNJARRdk6)EP1oMDSqdXOjmiqjk8XIIdfnSoVfsQCu0enf9dII2psrwfnohvoVfu04CldOOtapdfvhhSjqeVZOfdRyYiMeWZqr1F2fUoJwm5ZhJU)cGA()()12qGUx7hd2Xy(yYmgwXKishXOjmiOJaDV2pgSJjBfnoh1wxhu0)9sRHy0egeOef(CwXHIgwN3cjvok6dQeavUIwClSshm991GPwxGoSoVfsXWkg8etc4zOO6gocreOdM((AWuRlqkgwXKis3WriIaDnDgRuA2cqXCZvmygdRyoeInrW72btFFnyQ1fOJaDV2pMBIj7yyfZRbwBtCKbiFNY3gHQDFlCWhZvmygdRyqELAaoyLUNsFV2yWoMBpgwXKis3WriIaDeO71(XWPXy(UjI5MyehzasxkDOjKwQafTFKISkAdhHicOef(MqXHIgwN3cjvok6dQeavUIwClSshm991GPwxGoSoVfsXWkMmIbOOGJu4G2HOZtAAKALpgSVI5O10DtBVgSPyyfZHqSjcE3oy67RbtTUaDeO71(XCtmygdRysePJy0ege0rGUx7hdNgJ57MiMBIrCKbiDP0HMqAPcIjtfTFKISkAeJMWGaLOW)2vCOOH15TqsLJIMIGAlyQOWhtfTFKISkAncX2qWtyqhqjk8nxkou0W68wiPYrrFqLaOYv0iGcbpBN3cXWkMdrNN00i1kFpbu1PKyW(kgmJHvmzeJMoJvknBbOyU5kgmJjF(yqGUx7hZnxXi15EtkDigwX8AG12ehzaY3P8TrOA33ch8XG9vmyjMmJHvmzedEIbm991GPwxGum5Zhdc09A)yU5kgPo3BsPdXWPXKDmSI51aRTjoYaKVt5BJq1UVfo4Jb7RyWsmzgdRyYigXrgG0LshAcPLkigSogeO71(XKzmyhdNJHvm6(laQ5)7)xBdb6ETFmxXyEfTFKISkAdhHicOef(MBkou0W68wiPYrrtrqTfmvu4JPI2psrwfTgHyBi4jmOdOef(3gfhkAyDElKu5OO9JuKvrB4ieraf9bvcGkxrJNyW5OY5Tq)VxATJzhl0mCeIiqmSIbbui4z78wigwXCi68KMgPw57jGQoLed2xXGzmSIjJy00zSsPzlafZnxXGzm5Zhdc09A)yU5kgPo3BsPdXWkMxdS2M4idq(oLVncv7(w4GpgSVIblXKzmSIjJyWtmGPVVgm16cKIjF(yqGUx7hZnxXi15EtkDigonMSJHvmVgyTnXrgG8DkFBeQ29TWbFmyFfdwIjZyyftgXioYaKUu6qtiTubXG1XGaDV2pMmJb7yWm7yyfJU)cGA()()12qGUx7hZvmMxrFm7yHM4idqEf(yQef(yAEfhkAyDElKu5OOpOsau5k6xdS2M4idq(yW(kMSJHvmiq3R9J5MyYogUIjJyEnWABIJma5Jb7RymrmzgdRyakk4ifoODi68KMgPw5Jb7Ry4SI2psrwf9bv6pzBcORbVOef(yIPIdfnSoVfsQCu0hujaQCfnEIbNJkN3c9)EP1qmAcdcIHvmzedqrbhPWbTdrNN00i1kFmyFfdNJHvmiGcbpBN3cXKpFm4jgPo3R1igwXKrmsPdXGDmyA(yYNpMdrNN00i1kFmyFft2XKzmzgdRyYignDgRuA2cqXCZvmygt(8XGaDV2pMBUIrQZ9Mu6qmSI51aRTjoYaKVt5BJq1UVfo4Jb7RyWsmzgdRyYig8edy67RbtTUaPyYNpgeO71(XCZvmsDU3KshIHtJj7yyfZRbwBtCKbiFNY3gHQDFlCWhd2xXGLyYmgwXioYaKUu6qtiTubXG1XGaDV2pgSJHZkA)ifzv0ignHbbkrHpMzR4qrdRZBHKkhfTFKISkAeJMWGaf9bvcGkxrJNyW5OY5Tq)VxATJzhl0qmAcdcIHvm4jgCoQCEl0)7LwdXOjmiigwXauuWrkCq7q05jnnsTYhd2xXW5yyfdcOqWZ25TqmSIjJy00zSsPzlafZnxXGzm5Zhdc09A)yU5kgPo3BsPdXWkMxdS2M4idq(oLVncv7(w4GpgSVIblXKzmSIjJyWtmGPVVgm16cKIjF(yqGUx7hZnxXi15EtkDigonMSJHvmVgyTnXrgG8DkFBeQ29TWbFmyFfdwIjZyyfJ4idq6sPdnH0sfedwhdc09A)yWogoROpMDSqtCKbiVcFmvIcFmXIIdfnSoVfsQCu0hujaQCf9RbwBtCKbiFmxXGzmSIbOOGJu4G2HOZtAAKALpgSVIjJyoAnD302RbBkgSogmJjZyyfdcOqWZ25TqmSIbpXaM((AWuRlqkgwXGNysapdfv)zx46mAXWkgD)fa18)9)RTHaDV2pMRymFmSIrCKbiDP0HMqAPcIbRJbb6ETFmyhdNv0(rkYQOpOs)jBtaDn4fLOWhtoR4qr7hPiRI(bTVEfnSoVfsQCuIsuIIghG(ISk8Z28zBEmZ28MlfnED0wRXROnzGvXk4FRXpRElXedhSHykDncsIHIGIXCW5B9SnNyqGjtMcbPyEIoeJZieDxGumh2(AaFpWiRxledM3smMezXbibsXyoiMfOiidOFBnNyesmMdIzbkcYa632oSoVfsMtmzKTPz2dmY61cXC73smMezXbibsXyoiMfOiidOFBnNyesmMdIzbkcYa632oSoVfsMtmzGPPz2dmcmmzGvXk4FRXpRElXedhSHykDncsIHIGIXCsaLZyfZjgeyYKPqqkMNOdX4mcr3fifZHTVgW3dmY61cXGLBjgtIS4aKaPyOlDtkM3SvCtJ5wrmcjMSoJhtQWvFr2yiAaYfckMmYnZyYattZShyK1RfIXC7wIXKiloajqkgZbXSafbza9BR5eJqIXCqmlqrqgq)22H15TqYCIjdmnnZEGrGHjdSkwb)Bn(z1BjMy4GnetPRrqsmueumMtIiMtmiWKjtHGumprhIXzeIUlqkMdBFnGVhyK1RfIHZ3smMezXbibsXyoGPVVgm16cK63wZjgHeJ5KaEgkQ(TTdM((AWuRlqYCIjdmnnZEGrGXTwxJGeifJ5kg)ifzJXwV89adfTgIqvwqrNLyWQ)7)xRlfzJbRqmyGaJSedNaoGopGIbtSWDmzB(SnFGrGrwIjRqWbPym3TUbyTUuKnMmmjl47dzgdJwm1gJgQiOsmlMNetjXGxcJnfZsKymajgEgubPy4b21MI5fWTc7y8JuK97bgbgzjgoPPWHrGum8afbbXCi68Uedpyu73JbREoGM8XSKfRz7iDkgBm(rkY(XqwRz9ad)ifz)UgcoeDExUCnnRznns9KnWWpsr2VRHGdrN3fUUYLNiIfsnkRBgKWBTgnHyATbg(rkY(DneCi68UW1vU6o6oKAueulbUWMBneCi68U0E4q20FzcUlQlKxPgGdwP7P03RfBmnrGHFKISFxdbhIoVlCDL7lGBf2bg(rkY(DneCi68UW1vUVToqZ3ulvhGBneCi68U0E4q20FHj3f1fcOqWZ25TqGrGrwIHtAkCyeifdGdqMfJu6qmcBig)ieum1hJJZlRZBHEGHFKIS)196CpWilXGvGxa3kSJPOIrJ8FXBHyYyjXGJXUaY5TqmWc6f8XuBmhIoVlzgy4hPi7Z1vUVaUvyhy4hPi7Z1vU4Cu58wG711HlybKHzneyaB7q05RfsCJZTmWfSaYWSocmGLlns9KfsnElaPNtnx3kYiBo91aRTX2FbYmWWpsr2NRRCX5OY5Ta3RRdxFTgwOjoYaeUX5wg461aRTjoYaKVt5BJq1UVfo4Vj7ad)ifzFUUYLY6gG16sr22Xc((a3f1vc4zOO6uw3aSwxkY2rGUx7Ft2bg(rkY(CDL7XT2MFKISnB9c3RRdxVaUvydjUlQRxa3kSHuhrmyGad)ifzFUUY94wBZpsr2MTEH711HRt65UOUYapIBHv66(laQ5)7)xBhwN3cP85tePB4ierGUuN71AKzGHFKISpxx5(26anFtTuDaUlQRxdS2M4idq(oLVncv7(w4G)MRmmbwJywGIGmGEYF21A0(dHztiWMjlEgkQ(BRd08n1s1b6iq3R9VHQmylneO71(SqafcE2oVfyDi68KMgPw5X(clbg(rkY(CDL7XT2MFKISnB9c3RRdxjIey4hPi7Z1vUh3AB(rkY2S1lCVUoCLkeCKad)ifzFUUY1rhFHMqqiyfUlQlybKHz9eqvNsW(cttWfohvoVf6WcidZAiWa22HOZxlKcm8JuK956kxhD8fAAm2hcm8JuK956kxBzWw(2TkMKHoSsGHFKISpxx5Y7gncvtq15(hyeyKLymjcXMi4D)ad)ifz)(j9xuw3aSwxkYgyKLyU1uX4P0hJJGyy04oMFlnigHnedzHyWBjSJXsWl8smCWbNOhZT6hIbVSHnMKz1AedL)cGIry7BmMKjpMeqvNsIHGIbVLWMWiX4RzXysM8EGHFKISF)KEUUYv3r3HuJIGAjWf2CFm7yHM4idq(lm5UOUqELAaoyLUNsFNrJvgIJmaPlLo0eslvWnhIopPPrQv(EcOQtjCkMDtKp)HOZtAAKALVNaQ6uc2xhTMUBA71GnLzGrwI5wtfZsIXtPpg8wwBmPcIbVLWU2ye2qmlyQedwm)ZDmmpetwHItedzJHN8Fm4Te2egjgFnlgtYK3dm8JuK97N0Z1vU6o6oKAueulbUWM7I6c5vQb4Gv6Ek99AXglMhRrELAaoyLUNsFpXGCPilRdrNN00i1kFpbu1PeSVoAnD302RbBkWilXK1GnbI4Xyjg1XTXCiBQKISU9JH3FifdzJ5WGqWkX8AWjWWpsr2VFspxx5IZrLZBbUxxhUWbBceXBBzWwEXT3bu7q2ujfz5gNBzGl8iUfwPVLbB5f3EhqDyDElKYNhpIBHv6GPVVgm16c0H15TqkF(dHyte8UDW03xdMADb6iq3R9VXeyD2CQ4wyLEcana1Eb5IBa6DyDElKcm8JuK97N0Z1vU4GnbI4Cxux45fWTcBi1redgGvIiDeJMWGGUuN71AWcpjGNHIQJd2eiI3z0yHZrLZBHooytGiEBld2YlU9oGAhYMkPiBGrwIHtA67RbtTUaXGx2WgZsKyEbCRWgsX4BkgEIWogScJMWGGy8nftw1riIaX4iiggTyOiOySK1igyjmgS7bg(rkY(9t656kxW03xdMADb4UOUWZlGBf2qQJigmaRmWtIiDdhHic0rafcE2oVfyLishXOjmiOJaDV2hBoZfN50Jwt3nT9AWMYNprKoIrtyqqhb6ETpNA(UjWwCKbiDP0HMqAPcYKL4idq6sPdnH0sfGnNdm8JuK97N0Z1vUp7ch3f1vIiDeJMWGGUuN71AKpFIi9h0(67sDUxRrGHFKISF)KEUUYvJifz5UOU4zOO68wcjzzEPJa)i5ZtvgSLgc09A)BWI5ZNpb8muuDCWMar8oJwGHFKISF)KEUUYL3siPgfdYmUlQReWZqr1XbBceX7mAbg(rkY(9t656kxEa9a6ETgCxuxjGNHIQJd2eiI3z0cm8JuK97N0Z1vUufc4TesI7I6kb8muuDCWMar8oJwGHFKISF)KEUUY13d8cYTTJBTCxuxjGNHIQJd2eiI3z0cm8JuK97N0Z1vUh3AB(rkY2S1lCVUoCHZ36zZDrDHNxa3kSHu3Tww6(laQ5)7)xBdb6ET)L5dm8JuK97N0Z1vUmp0kb05gOOGJ0wxhUmSEQCHG(MoKCRTil3f1vc4zOO64GnbI4DgTad)ifz)(j9CDLlZdTsaDUbkk4iT11HldRNkxiOVX7jdG7I6kb8muuDCWMar8oJwGrwIHtauoJvIHYTwE)CpgkckgM35TqmLa6)TeZT6hIHSXCieBIG3Thy4hPi73pPNRRCzEOvcO)bgbgzjgorHGJetY1DdigNVSLuWhyKLy4Kloyj6X4smCMRyYWeCfdElHDmCc6mJXKm59yU166qQCbSMfdzJjBUIrCKbip3XG3syhtwd2eiIZDmeum4Te2XWroMShdrydi8wpedE9sIHIGI5j6qmWcidZ6XGvTpjg86LetrfdN003iMdrNNet9XCi61AedJwpWWpsr2VNkeCKlyXblrN7I6cOOGJu4G2HOZtAAKALh7loZL4wyLEcana1Eb5IBa6DyDElKyLrc4zOO64GnbI4DgT85tapdfv)zx46mA5ZdlGmmRNaQ6uYnxzBcUW5OY5TqhwazywdbgW2oeD(AHu(84bNJkN3c9Vwdl0ehzasMSYapIBHv6GPVVgm16c0H15TqkF(dHyte8UDW03xdMADb6iq3R9Xo7mdm8JuK97PcbhHRRCX5OY5Ta3RRdxmp0OkRfqCJZTmW1HOZtAAKALVNaQ6uc2yMppSaYWSEcOQtj3CLTj4cNJkN3cDybKHzneyaB7q05Rfs5ZJhCoQCEl0)AnSqtCKbibg(rkY(9uHGJW1vUpGqUaPgpzH2Rv3bUpMDSqtCKbi)fMCxux8muu93whO5BQLQd0z0yHNer6pGqUaPgpzH2Rv3HwIiDPo3R1iFEQYGT0qGUx7FZLjYN)qi2ebVB)beYfi14jl0ET6o0pSDKb8nkKFKISUf7RS7MltKp)tyS81M6wWtnEZAGPUUMf6W68wiXcp8muuDl4PgVznWuxxZcDgTaJSeJ5UVXqOIXK1w4GpgxIbZBdxX8IFU)XqOIXKTkLGnMCSEc(yiOyCdV2xIHZCfJ4idq(EGHFKISFpvi4iCDLlLVncv7(w4GN7I6cNJkN3cDMhAuL1ciwzWZqr1zxPeSnERNGV)IFUJ9fM3M85ZapAOIGkXSgIiUuKL1RbwBtCKbiFNY3gHQDFlCWJ9fN56fWTcBi1redgiZmdmYsmM7(gdHkgtwBHd(yesmUMM1Sy4eGNSMfJjNupzJPOIPw)ifoigYgJVMfJ4idqIXLyWsmIJma57bg(rkY(9uHGJW1vUu(2iuT7BHdEUpMDSqtCKbi)fMCxux4Cu58wOZ8qJQSwaX61aRTjoYaKVt5BJq1UVfo4X(clbg(rkY(9uHGJW1vUWHnPwJgc0qLUVjUlQlCoQCEl0zEOrvwlGyDieBIG3TJd2eiI3rGUx7JnMMpWWpsr2VNkeCeUUY115zE2Cxux4Cu58wOZ8qJQSwafyKLy4W5X6ScJuwxGyesmUMM1Sy4eGNSMfJjNupzJXLyYogXrgG8bg(rkY(9uHGJW1vU6mszDb4(y2XcnXrgG8xyYDrDHZrLZBHoZdnQYAbeRxdS2M4idq(oLVncv7(w4G)k7ad)ifz)EQqWr46kxDgPSUaCxux4Cu58wOZ8qJQSwafyeyKLy4eUUBaXqWbOyKshIX5lBjf8bgzjMSEPxsmzvhHic8Xq2ywYI1AOsh5iZIrCKbiFmueumcBignurqLywmiI4sr2ykQymbxXWBbi9X4iig3IapzwmmAbg(rkY(9erUW5OY5Ta3RRdx)9sRDm7yHMHJqeb4gNBzGlnurqLywdrexkYY61aRTjoYaKVt5BJq1UVfo4XglSYirKUHJqeb6iq3R9V5qi2ebVB3WriIa9edYLIS5ZRrQNSqQXBbi9yBImdmYsmz9sVKyWkmAcdc(yiBmlzXAnuPJCKzXioYaKpgkckgHneJgQiOsmlgerCPiBmfvmMGRy4TaK(yCeeJBrGNmlggTad)ifz)EIiCDLlohvoVf4EDD46VxATJzhl0qmAcdc4gNBzGlnurqLywdrexkYY61aRTjoYaKVt5BJq1UVfo4XglSYib8muu9NDHRZOLpVgPEYcPgVfG0JTjYmWilXK1l9sIbRWOjmi4JPOIjRbBceX5IMDHl3SI)cGIbR(V)FTXuFmmAX4Bkg8cXW2XbXKnxX8WHSPpglqjXq2ye2qmyfgnHbbXWjiCey4hPi73teHRRCX5OY5Ta3RRdx)9sRHy0egeWno3YaxjGNHIQJd2eiI3z0yLrc4zOO6p7cxNrlFED)fa18)9)RTHaDV2hBZNjRer6ignHbbDeO71(yNDGrwIHwdoLBJjR6ierGy8nfdwHrtyqqmpimAXOHkckgHedN003xdMADbI54Vey4hPi73teHRRCnCeIia3f1L4wyLoy67RbtTUaDyDElKyHhW03xdMADbsDdhHicWkrKUHJqeb6A6mwP0SfGU5ctwhcXMi4D7GPVVgm16c0rGUx7Ft2SEnWABIJma57u(2iuT7BHd(lmzH8k1aCWkDpL(ETyF7SsePB4ierGoc09AFo18DtCJ4idq6sPdnH0sfey4hPi73teHRRCrmAcdc4UOUe3cR0btFFnyQ1fOdRZBHeRmakk4ifoODi68KMgPw5X(6O10DtBVgSjwhcXMi4D7GPVVgm16c0rGUx7FdMSsePJy0ege0rGUx7ZPMVBIBehzasxkDOjKwQGmdmYsmzvhHicedJ2Da04og3(KyeubFmcjgMhIPKy8pgpMxdoLBJXawa5cbfdfbfJWgIX6VeJjzYJHhOiiigpgQARNnGcm8JuK97jIW1vUAeITHGNWGoa3ueuBbtLlmdm8JuK97jIW1vUgocreG7I6cbui4z78wG1HOZtAAKALVNaQ6uc2xyYkdnDgRuA2cq3CHz(8iq3R9V5sQZ9Mu6aRxdS2M4idq(oLVncv7(w4Gh7lSKjRmWdy67RbtTUaP85rGUx7FZLuN7nP0bonBwVgyTnXrgG8DkFBeQ29TWbp2xyjtwzioYaKUu6qtiTubync09A)mXMZS09xauZ)3)V2gc09A)lZhy4hPi73teHRRC1ieBdbpHbDaUPiO2cMkxygy4hPi73teHRRCnCeIia3hZowOjoYaK)ctUlQl8GZrLZBH(FV0AhZowOz4ierawiGcbpBN3cSoeDEstJuR89eqvNsW(ctwzOPZyLsZwa6MlmZNhb6ET)nxsDU3Kshy9AG12ehzaY3P8TrOA33ch8yFHLmzLbEatFFnyQ1fiLppc09A)BUK6CVjLoWPzZ61aRTjoYaKVt5BJq1UVfo4X(clzYkdXrgG0LshAcPLkaRrGUx7Nj2yMnlD)fa18)9)RTHaDV2)Y8bgzjgtcv6pzJHdqxdEjgYgJoJvknleJ4idq(yCjgoZvmMKjpg8Yg2yqm7wRrmegjMAJj7pMmy0IriXW5yehzaYNzmeumy5JjdtWvmIJma5ZmWWpsr2VNicxx5EqL(t2Ma6AWlCxuxVgyTnXrgG8yFLnleO71(3Knxz8AG12ehzaYJ9LjYKfqrbhPWbTdrNN00i1kp2xCoWilXyYcaTyy0IbRWOjmiigxIHZCfdzJXT2yehzaYhtg4LnSXylC1AeJLSgXalHXGDm(MIzjsm)6ApBIKzGHFKISFpreUUYfXOjmiG7I6cp4Cu58wO)3lTgIrtyqaRmakk4ifoODi68KMgPw5X(IZSqafcE2oVfYNhpsDUxRbRmKshWgtZNp)HOZtAAKALh7RSZmtwzOPZyLsZwa6MlmZNhb6ET)nxsDU3Kshy9AG12ehzaY3P8TrOA33ch8yFHLmzLbEatFFnyQ1fiLppc09A)BUK6CVjLoWPzZ61aRTjoYaKVt5BJq1UVfo4X(clzYsCKbiDP0HMqAPcWAeO71(yZ5ad)ifz)EIiCDLlIrtyqa3hZowOjoYaK)ctUlQl8GZrLZBH(FV0AhZowOHy0egeWcp4Cu58wO)3lTgIrtyqalGIcosHdAhIopPPrQvESV4mleqHGNTZBbwzOPZyLsZwa6MlmZNhb6ET)nxsDU3Kshy9AG12ehzaY3P8TrOA33ch8yFHLmzLbEatFFnyQ1fiLppc09A)BUK6CVjLoWPzZ61aRTjoYaKVt5BJq1UVfo4X(clzYsCKbiDP0HMqAPcWAeO71(yZ5aJSeJjHk9NSXWbORbVedzJHMJykQyQngnFtGEDIX3umLedElRnMejgl8Fmjx3nGye2(gdNCXblrpMedeJqIHJCYnRGvdm8JuK97jIW1vUhuP)KTjGUg8c3f11RbwBtCKbi)fMSakk4ifoODi68KMgPw5X(kJJwt3nT9AWMWAmZKfcOqWZ25Tal8aM((AWuRlqIfEsapdfv)zx46mAS09xauZ)3)V2gc09A)lZZsCKbiDP0HMqAPcWAeO71(yZ5ad)ifz)EIiCDL7dAF9bgbgzjgAbCRWgsXGvpsr2pWilXGFzW(f3EhqXq2yWch3smMeQ0FYgdhGUg8sGHFKISF)fWTcBiDDqL(t2Ma6AWlCxuxIBHv6BzWwEXT3buhwN3cjwVgyTnXrgG8yFHfwhIopPPrQvESV4mlXrgG0LshAcPLkaRrGUx7J9ThyKLyWVmy)IBVdOyiBmyYXTed96ApBIedwHrtyqqGHFKISF)fWTcBiX1vUignHbbCxuxIBHv6BzWwEXT3buhwN3cjwhIopPPrQvESV4mlXrgG0LshAcPLkaRrGUx7J9ThyKLyOz4farXya3smyvnnRzXqqXGvake8SJbVLWogEgkkiftw1riIaFGHFKISF)fWTcBiX1vUAeITHGNWGoa3ueuBbtLlmdm8JuK97VaUvydjUUY1WriIaCFm7yHM4idq(lm5UOUe3cR0FgEbqumgqhwN3cjwzGaDV2)gmZoFEnDgRuA2cq3CHzMSehzasxkDOjKwQaSgb6ETp2zhyKLyOz4farXyaXWvmCstFJyiBmyYXTedwbOqWZoMSQJqebIXLye2qmWMIHqfZlGBf2XiKymajgD30ysmixkYgdpqrqqmCstFFnyQ1fiWWpsr2V)c4wHnK46kxncX2qWtyqhGBkcQTGPYfMbg(rkY(9xa3kSHexx5A4ieraUlQlXTWk9NHxaefJb0H15TqIL4wyLoy67RbtTUaDyDElKy5hPWbnyb9c(lmzXZqr1FgEbqumgqhb6ET)ny2XsGHFKISF)fWTcBiX1vU6mszDb4UOUe3cR0FgEbqumgqhwN3cjwhIopPPrQv(BUWsGrGrwIjR5B9SdmYsmM71wp7yWBjSJr3nngtYKhdfbfd(LbB5f3EhqChdZAH)JH5R1igob4cBRzXqZ2te8(bg(rkY(DC(wp7lCoQCElW966W1wgSLxC7Da1oATdztLuKLBCULbUYapiMfOiidONaxyBnR9S9ebVplGIcosHdAhIopPPrQvESVoAnD302RbBkZ85ZaXSafbza9e4cBRzTNTNi49zDi68KMgPw5Vj7mdmYsmznFRNDm4Te2XWjn9nIHRyWVmylV427a6wIjR4Mw6m6XysM8y8nfdN003ige4jZIHIGIzbtLyYQMeNiWWpsr2VJZ36zZ1vU48TE2CxuxIBHv6GPVVgm16c0H15TqIL4wyL(wgSLxC7Da1H15TqIfohvoVf6BzWwEXT3bu7O1oKnvsrwwhcXMi4D7GPVVgm16c0rGUx7FdMbgzjMSMV1Zog8wc7yWVmylV427akgUIbFsmCstFJBjMSIBAPZOhJjzYJX3umznytGiEmmAbg(rkY(DC(wpBUUYfNV1ZM7I6sClSsFld2YlU9oG6W68wiXcpIBHv6GPVVgm16c0H15TqIfohvoVf6BzWwEXT3bu7O1oKnvsrwwjGNHIQJd2eiI3z0cm8JuK9748TE2CDLRgHyBi4jmOdWnfb1wWu5ctUbtfK3CDcZkxC2ebg(rkY(DC(wpBUUYfNV1ZM7I6sClSs)z4farXyaDyDElKyDieBIG3TB4ierGoJgRmsePB4ierGocOqWZ25Tq(8jGNHIQJd2eiI3z0yLis3WriIaDnDgRuA2cq3CHzMSoeDEstJuR89eqvNsW(kJxdS2M4idq(oLVncv7(w4Gh7BLCotwiVsnahSs3tPVxl2yMDGrwIjR5B9SJbVLWoMSI)cGIbR(V)1ElXGpjMxa3kSJX3umljg)ifoiMScwngEgkkUJbRWOjmiiMLiXuBmiGcbp7yq(AaChtIbvRrmznytGioxCKtGHFKISFhNV1ZMRRCX5B9S5UOUYqClSsx3Fbqn)F))A7W68wiLppIzbkcYa66o6EJq1e2qt3Fbqn)F))AZKfEsePJy0ege0rafcE2oVfyLis3WriIaDeO71(yJfwjGNHIQJd2eiI3z0yLaEgkQ(ZUW1z0u0VgCu4NTjUnkrjkf]] )

end