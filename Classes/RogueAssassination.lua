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
                return not ( boss and group ), "can only vanish in a boss encounter or with a group"
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

        potion = "potion_of_unbridled_fury",

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


    spec:RegisterPack( "Assassination", 20201201, [[da1(sbqiOuEKOuUKOuLAtiPpjkvgLOKtjkAvKa9kukZIe1TGsv7sQ(LOsdJIIJPu1YefEgkrtdLW1irSnOuPVrrPmosa6CuuQwNOQY7eLQOMNOk3tPSpOK)jkvfhekvSqrfpKePMijsCrsaTrrPQ6JuuIrkkvroPOQOvcf9srPkmtrvvUjfL0orjnusK0sfvLEksnvuQUQOuvARIQcFvuvvglja2lP(RugSIdt1IrLhRKjlYLbBgQ(mfgnf50swTOuL8AOWSP0TjPDRYVrmCu1XfvvvlhYZv10jUok2os8DsqJNe68uunFLk7xy9En7A6KlGM1mmtgMzFgMzFFplmtg7zPMwmNh008(cd3a00NRcAASZ)()15sronnVBUL4jn7A6NWGwGM2Ki8F(LBUgLyIHRViQ5(LkJ1LIClKJl5(L6kxnnhtzL85P500jxanRzyMmmZ(mmZ((EwyMmmd2vt7mIjcsttxQkTM2uLsWP500j4xA6Sfd25F))6CPixm5lXGbcmZwmkfybQCakM9khtgMjdZeygyMTymRekqkMSFRBawRlf5IjlL2c(9qMXWWhtDXWJkcQeZJ5jXusmkKWytXCejgdqIHJbvqkgoWuDPyEbCRykgFjf5(UM2wV8A210VaUvmbjn7Aw3RzxtdNZzHKohn9cvcGkxtlUfoPFLHj5f3IbG6W5Cwifd1yEEWABIJma5JbRTyyzmuJzru5inEsDYhdwBXWIyOgJ4idq6sPcnH0sfed2hdcu96(yWkgSRM2xsron9cvQp5AcOYdVOfnRzOzxtdNZzHKohn9cvcGkxtlUfoPFLHj5f3IbG6W5Cwifd1ywevosJNuN8XG1wmSigQXioYaKUuQqtiTubXG9XGavVUpgSIb7QP9LuKttJy4fgeOfnRSuZUMgoNZcjDoAACcQDGIIM19AAFjf5008eITHGNWGwGw0SYcn7AA4ColK05OP9LuKttB4ieran9cvcGkxtlUfoP)mCcGWzmGoCoNfsXqnMSIbbQEDFm5fZ(mIz3Uy4vzSsXBlaftEBXSpMmJHAmIJmaPlLk0eslvqmyFmiq1R7JbRyYqtVmFzHM4idqEnR71IMvLOzxtdNZzHKohnnob1oqrrZ6EnTVKICAAEcX2qWtyqlqlAwXUA210W5CwiPZrtVqLaOY10IBHt6pdNaiCgdOdNZzHumuJrClCshu89ZGPoxGoCoNfsXqngFjffObhOwWhZwm7JHAmCm449NHtaeoJb0rGQx3htEXSVZsnTVKICAAdhHicOfnRMnn7AA4ColK05OPxOsau5AAXTWj9NHtaeoJb0HZ5SqkgQXSiQCKgpPo5JjVTyyPM2xsronTkJuwxaTOfnDcWDgROzxZ6En7AAFjf500yulm00W5CwiPZrlAwZqZUM2xsron9lGBftAA4ColK05OfnRSuZUMgoNZcjDoAAcVM(brt7lPiNMMIJkNZcAAkULb00WbidZ7iWaUyylgEs9KdsnolaPpgfmgZwm5gtwXKrmkymppyTnt(lqmzQPP4O25QGMgoazyEdbgW1wevU6GKw0SYcn7AA4ColK05OPj8A6henTVKICAAkoQColOPP4wgqt)8G12ehzaY3X9RrWByCff4JjVyYqttXrTZvbn9xNHfAIJmarlAwvIMDnnCoNfs6C00lujaQCnDc4yWX74w3aSwxkY1rGQx3htEXKHM2xsronnU1naR1LICTLf87bTOzf7QzxtdNZzHKohn9cvcGkxt)c4wXeK6iIbdOP9LuKttVCRT5lPixZwVOPT1lTZvbn9lGBftqslAwnBA210W5CwiPZrtVqLaOY10zfd2IrClCsx1Fbqn)F))66W5CwifZUDXKis3WriIaDPwyuNrmzQP9LuKttVCRT5lPixZwVOPT1lTZvbn9k9ArZQcOMDnnCoNfs6C00lujaQCn9ZdwBtCKbiFh3VgbVHXvuGpM82IjRyusmyFmiMdWjidON83uDgTFryUecSD4ColKIjZyOgdhdoE)T1cA(LAPAbDeO619XKxm4LHjPHavVUpgQXGaCe8MColed1ywevosJNuN8XG1wmSut7lPiNM(T1cA(LAPAbArZQzxZUMgoNZcjDoAAFjf500l3AB(skY1S1lAAB9s7CvqtNiIw0SU3mA210W5CwiPZrt7lPiNME5wBZxsrUMTErtBRxANRcA6uHGLOfnR73RzxtdNZzHKohn9cvcGkxtdhGmmVNa8AvsmyTfZELedBXqXrLZzHoCaYW8gcmGRTiQC1bjnTVKICAAhT8dAcbHGt0IM19zOzxt7lPiNM2rl)GgpJ9bnnCoNfs6C0IM19SuZUM2xsronTTmmjFl7ftYqfortdNZzHKohTOzDpl0SRP9LuKttZ5gncEtq1cJxtdNZzHKohTOfnnpcwevox0SRzDVMDnTVKICAANN3AEJNup500W5CwiPZrlAwZqZUMgoNZcjDoAAFjf500Qocdi1WjOwcCXKMEHkbqLRPrELAaf4KUNsFVUyWkM9krtZJGfrLZL2dlYLEnTs0IMvwQzxt7lPiNM(fWTIjnnCoNfs6C0IMvwOzxtdNZzHKohnTVKICA63wlO5xQLQfOPxOsau5AAeGJG3KZzbnnpcwevoxApSix61071Iw00PcblrZUM19A210W5CwiPZrtVqLaOY10aooSKIc0wevosJNuN8XG1wmSig2IrClCspbapGAVGCXna1oCoNfsXqnMSIjbCm44DkWLar8odFm72ftc4yWX7VPIsNHpMD7IboazyEpb41QKyYBlMmusmSfdfhvoNf6WbidZBiWaU2IOYvhKIz3UyWwmuCu5CwO)1zyHM4idqIjZyOgtwXGTye3cN0bfF)myQZfOdNZzHum72fZIqSjIcVoO47NbtDUaDeO619XGvmzetMAAFjf500WrboIQw0SMHMDnnCoNfs6C00eEn9dIM2xsronnfhvoNf00uCldOPxevosJNuN89eGxRsIbRy2hZUDXahGmmVNa8Avsm5Tftgkjg2IHIJkNZcD4aKH5neyaxBru5QdsXSBxmylgkoQCol0)6mSqtCKbiAAkoQDUkOPzEOHxwlG0IMvwQzxtdNZzHKohnTVKICA6hqixGuJJCq75lman9cvcGkxtZXGJ3FBTGMFPwQwqNHpgQXGTyseP)ac5cKACKdApFHb0sePl1cJ6mIz3UyWldtsdbQEDFm5TfJsIz3UyweInru41FaHCbsnoYbTNVWa6ltoYa(goYxsro3gdwBXKr3SPKy2TlMNWy5Ql1TGNACM3afDvEl0HZ5SqkgQXGTy4yWX7wWtnoZBGIUkVf6m8A6L5ll0ehzaYRzDVw0SYcn7AA4ColK05OPxOsau5AAkoQCol0zEOHxwlGIHAmzfdhdoE3uLsW14SEc((l(cJyWAlM9M9y2TlMSIbBXWJkcQeZBiI4srUyOgZZdwBtCKbiFh3VgbVHXvuGpgS2IHfXWwmVaUvmbPoIyWaXKzmzQP9LuKttJ7xJG3W4kkWRfnRkrZUMgoNZcjDoAAFjf5004(1i4nmUIc8A6fQeavUMMIJkNZcDMhA4L1cOyOgZZdwBtCKbiFh3VgbVHXvuGpgS2IHLA6L5ll0ehzaYRzDVw0SID1SRPHZ5SqsNJMEHkbqLRPP4OY5SqN5HgEzTakgQXSieBIOWRtbUeiI3rGQx3hdwXS3mAAFjf500WYePoJgc4rLQFjTOz1SPzxtdNZzHKohn9cvcGkxttXrLZzHoZdn8YAbKM2xsronTRYX8M0IMvfqn7AA4ColK05OP9LuKttRYiL1fqtVqLaOY10uCu5CwOZ8qdVSwafd1yEEWABIJma574(1i4nmUIc8XSftgA6L5ll0ehzaYRzDVw0SA21SRPHZ5SqsNJMEHkbqLRPP4OY5SqN5HgEzTast7lPiNMwLrkRlGw0IMELEn7Aw3Rzxt7lPiNMg36gG16sronnCoNfs6C0IM1m0SRPHZ5SqsNJM2xsronTQJWasnCcQLaxmPPxOsau5AAKxPgqboP7P03z4JHAmzfJ4idq6sPcnH0sfetEXSiQCKgpPo57jaVwLeJcgZ(UsIz3UywevosJNuN89eGxRsIbRTyw8nvxX2ZdxkMm10lZxwOjoYaKxZ6ETOzLLA210W5CwiPZrtVqLaOY10iVsnGcCs3tPVxxmyfdlntmyFmiVsnGcCs3tPVNyqUuKlgQXSiQCKgpPo57jaVwLedwBXS4BQUITNhUKM2xsronTQJWasnCcQLaxmPfnRSqZUMgoNZcjDoAAcVM(brt7lPiNMMIJkNZcAAkULb00ylgXTWj9RmmjV4wmauhoNZcPy2TlgSfJ4w4KoO47NbtDUaD4ColKIz3UyweInru41bfF)myQZfOJavVUpM8IrjXG9XKrmkymIBHt6ja4bu7fKlUbO2HZ5SqsttXrTZvbnnf4sGiE7kdtYlUfda1wKlvsroTOzvjA210W5CwiPZrtVqLaOY10ylMxa3kMGuhrmyGyOgtIiDedVWGGUulmQZigQXGTysahdoENcCjqeVZWhd1yO4OY5SqNcCjqeVDLHj5f3IbGAlYLkPiNM2xsronnf4sGiUw0SID1SRPHZ5SqsNJMEHkbqLRPf3cN0bfF)myQZfOdNZzHumuJrClCs)kdtYlUfda1HZ5SqkgQXa44WskkqBru5inEsDYhdwBXS4BQUITNhUumuJzri2erHxhu89ZGPoxGocu96(yYlM9AAFjf500u8REtArZQztZUMgoNZcjDoA6fQeavUMwClCs)kdtYlUfda1HZ5SqkgQXGTye3cN0bfF)myQZfOdNZzHumuJbWXHLuuG2IOYrA8K6KpgS2IzX3uDfBppCPyOgtc4yWX7uGlbI4DgEnTVKICAAk(vVjTOzvbuZUMgoNZcjDoAAFjf5008eITHGNWGwGMguuqEZvjmNOPzHs004eu7affnR71IMvZUMDnnCoNfs6C00lujaQCnT4w4K(ZWjacNXa6W5Cwifd1yWwmVaUvmbPoIyWaXqnMfHytefEDdhHic0z4JHAmzftIiDdhHic0raocEtoNfIz3UysahdoENcCjqeVZWhd1ysePB4ierGoVkJvkEBbOyYBlM9XKzmuJzru5inEsDY3taETkjgS2IjRyEEWABIJma574(1i4nmUIc8XGv2Nyyrmzgd1yqELAaf4KUNsFVUyWkM9zOP9LuKtttXV6nPfnR7nJMDnnCoNfs6C00lujaQCnDwXiUfoPR6VaOM)V)FDD4ColKIz3UyqmhGtqgqx1ry0i4nXe0u9xauZ)3)VUoCoNfsXKzmuJbBX8c4wXeK6U1gd1yu9xauZ)3)VUgcu96(yYBlgZed1yWwmjI0rm8cdc6iahbVjNZcXqnMer6gocreOJavVUpgSIHLXqnMeWXGJ3PaxceX7m8XqnMeWXGJ3FtfLodVM2xsronnf)Q3Kw0SUFVMDnnCoNfs6C00lujaQCnn2I5fWTIji1redgigQXKvmylMer6gocreOJaCe8MColed1ysePJy4fge0rGQx3hdwXWIyylgweJcgZIVP6k2EE4sXSBxmjI0rm8cdc6iq1R7JrbJXmDLedwXioYaKUuQqtiTubXKzmuJrCKbiDPuHMqAPcIbRyyHM2xsronnO47NbtDUaArZ6(m0SRPHZ5SqsNJMEHkbqLRPtePJy4fge0LAHrDgXSBxmjI0FG)RVl1cJ6m00(skYPPFtffTOzDpl1SRPHZ5SqsNJMEHkbqLRP5yWX7CwcjzzEPJaFjXSBxmjGJbhVtbUeiI3z410(skYPP5jsroTOzDpl0SRPHZ5SqsNJMEHkbqLRPtahdoENcCjqeVZWRP9LuKttZzjKudNbzUw0SUxjA210W5CwiPZrtVqLaOY10jGJbhVtbUeiI3z410(skYPP5a0dimQZqlAw3JD1SRPHZ5SqsNJMEHkbqLRPtahdoENcCjqeVZWRP9LuKttJxiGZsijTOzDVztZUMgoNZcjDoA6fQeavUMobCm44DkWLar8odVM2xsronTFl4fKBBl3A1IM19kGA210W5CwiPZrt7lPiNM2W6PYfc6BQqYT2ICA6fQeavUMobCm44DkWLar8odVMgWXHL0oxf00gwpvUqqFtfsU1wKtlAw3B21SRPHZ5SqsNJM2xsronTH1tLle0348KbOPxOsau5A6eWXGJ3PaxceX7m8AAahhws7CvqtBy9u5cb9nopzaArZAgMrZUM2xsronnZdTsa1xtdNZzHKohTOfnDIiA21SUxZUMgoNZcjDoAAcVM(brt7lPiNMMIJkNZcAAkULb008OIGkX8gIiUuKlgQX88G12ehzaY3X9RrWByCff4JbRyyzmuJjRysePB4ierGocu96(yYlMfHytefEDdhHic0tmixkYfZUDXWtQNCqQXzbi9XGvmkjMm10uCu7Cvqt)yu8TL5ll0mCeIiGw0SMHMDnnCoNfs6C00eEn9dIM2xsronnfhvoNf00uCldOP5rfbvI5nerCPixmuJ55bRTjoYaKVJ7xJG3W4kkWhdwXWYyOgtwXKaogC8(BQO0z4Jz3Uy4j1toi14SaK(yWkgLetMAAkoQDUkOPFmk(2Y8LfAigEHbbArZkl1SRPHZ5SqsNJMMWRPFq00(skYPPP4OY5SGMMIBzanDc4yWX7uGlbI4Dg(yOgtwXKaogC8(BQO0z4Jz3Uyu9xauZ)3)VUgcu96(yWkgZetMXqnMer6igEHbbDeO619XGvmzOPP4O25QGM(XO4BigEHbbArZkl0SRPHZ5SqsNJMEHkbqLRPf3cN0bfF)myQZfOdNZzHumuJbBXKaogC8UHJqeb6GIVFgm15cKIHAmjI0nCeIiqNxLXkfVTaum5TfZ(yOgZIqSjIcVoO47NbtDUaDeO619XKxmzed1yEEWABIJma574(1i4nmUIc8XSfZ(yOgdYRudOaN09u671fdwXGDJHAmjI0nCeIiqhbQEDFmkymMPRKyYlgXrgG0LsfAcPLkqt7lPiNM2WriIaArZQs0SRPHZ5SqsNJMEHkbqLRPf3cN0bfF)myQZfOdNZzHumuJjRyaCCyjffOTiQCKgpPo5JbRTyw8nvxX2ZdxkgQXSieBIOWRdk((zWuNlqhbQEDFm5fZ(yOgtIiDedVWGGocu96(yuWymtxjXKxmIJmaPlLk0eslvqmzQP9LuKttJy4fgeOfnRyxn7AA4ColK05OPXjO2bkkAw3RP9LuKttZti2gcEcdAbArZQztZUMgoNZcjDoA6fQeavUMgb4i4n5CwigQXSiQCKgpPo57jaVwLedwBXSpgQXKvm8QmwP4TfGIjVTy2hZUDXGavVUpM82IrQfgnPuHyOgZZdwBtCKbiFh3VgbVHXvuGpgS2IHLXKzmuJjRyWwmGIVFgm15cKIz3UyqGQx3htEBXi1cJMuQqmkymzed1yEEWABIJma574(1i4nmUIc8XG1wmSmMmJHAmzfJ4idq6sPcnH0sfed2hdcu96(yYmgSIHfXqngv)fa18)9)RRHavVUpMTymJM2xsronTHJqeb0IMvfqn7AA4ColK05OPXjO2bkkAw3RP9LuKttZti2gcEcdAbArZQzxZUMgoNZcjDoAAFjf500gocreqtVqLaOY10ylgkoQCol0Fmk(2Y8LfAgocreigQXGaCe8MColed1ywevosJNuN89eGxRsIbRTy2hd1yYkgEvgRu82cqXK3wm7Jz3UyqGQx3htEBXi1cJMuQqmuJ55bRTjoYaKVJ7xJG3W4kkWhdwBXWYyYmgQXKvmylgqX3pdM6CbsXSBxmiq1R7JjVTyKAHrtkvigfmMmIHAmppyTnXrgG8DC)Ae8ggxrb(yWAlgwgtMXqnMSIrCKbiDPuHMqAPcIb7JbbQEDFmzgdwXSpJyOgJQ)cGA()()11qGQx3hZwmMrtVmFzHM4idqEnR71IM19MrZUMgoNZcjDoA6fQeavUM(5bRTjoYaKpgS2IjJyOgdcu96(yYlMmIHTyYkMNhS2M4idq(yWAlgLetMXqngahhwsrbAlIkhPXtQt(yWAlgwOP9LuKttVqL6tUMaQ8WlArZ6(9A210W5CwiPZrtVqLaOY10ylgkoQCol0Fmk(gIHxyqqmuJjRyaCCyjffOTiQCKgpPo5JbRTyyrmuJbb4i4n5CwiMD7IbBXi1cJ6mIHAmzfJuQqmyfZEZeZUDXSiQCKgpPo5JbRTyYiMmJjZyOgtwXWRYyLI3wakM82IzFm72fdcu96(yYBlgPwy0KsfIHAmppyTnXrgG8DC)Ae8ggxrb(yWAlgwgtMXqnMSIbBXak((zWuNlqkMD7IbbQEDFm5TfJulmAsPcXOGXKrmuJ55bRTjoYaKVJ7xJG3W4kkWhdwBXWYyYmgQXioYaKUuQqtiTubXG9XGavVUpgSIHfAAFjf500igEHbbArZ6(m0SRPHZ5SqsNJM2xsronnIHxyqGMEHkbqLRPXwmuCu5CwO)yu8TL5ll0qm8cdcIHAmylgkoQCol0Fmk(gIHxyqqmuJbWXHLuuG2IOYrA8K6KpgS2IHfXqngeGJG3KZzHyOgtwXWRYyLI3wakM82IzFm72fdcu96(yYBlgPwy0KsfIHAmppyTnXrgG8DC)Ae8ggxrb(yWAlgwgtMXqnMSIbBXak((zWuNlqkMD7IbbQEDFm5TfJulmAsPcXOGXKrmuJ55bRTjoYaKVJ7xJG3W4kkWhdwBXWYyYmgQXioYaKUuQqtiTubXG9XGavVUpgSIHfA6L5ll0ehzaYRzDVw0SUNLA210W5CwiPZrtVqLaOY10ppyTnXrgG8XSfZ(yOgdGJdlPOaTfrLJ04j1jFmyTftwXS4BQUITNhUumyFm7JjZyOgdcWrWBY5SqmuJbBXak((zWuNlqkgQXGTysahdoE)nvu6m8Xqngv)fa18)9)RRHavVUpMTymtmuJrCKbiDPuHMqAPcIb7JbbQEDFmyfdl00(skYPPxOs9jxtavE4fTOzDpl0SRP9LuKtt)a)xVMgoNZcjDoArlArttbqFronRzyMmmZ(9zy210k0rxDgVMo)d7KVSMpz1SKFXed7MGykvEcsIbNGIj7saUZyLSlgeK)ZuiifZtuHyCgHO6cKIzzYpd47bM5V6Gyyz(fJstokasGum0LQshZB(jUIXK9ogHet(JXJjvuQVixmeEa5cbftw5MzmzTxXm7bM5V6GyuaZVyuAYrbqcKIj7qmhGtqgqxbi7IriXKDiMdWjidORa0HZ5Sqk7IjR9kMzpWmWm)d7KVSMpz1SKFXed7MGykvEcsIbNGIj7wPp7Ibb5)mfcsX8evigNriQUaPywM8Za(EGz(RoiM9Mj)IrPjhfajqkMSdXCaobzaDfGSlgHet2HyoaNGmGUcqhoNZcPSlMS2RyM9aZaZ8pSt(YA(KvZs(ftmSBcIPu5jijgCckMSlrKSlgeK)ZuiifZtuHyCgHO6cKIzzYpd47bM5V6Gyyr(fJstokasGumzhO47NbtDUaPUcq2fJqIj7sahdoExbOdk((zWuNlqk7IjR9kMzpWmWmFQYtqcKIb7gJVKICXyRx(EGPM(5HLM1muIzxtZJi4Lf00zlgSZ)()15srUyYxIbdeyMTyukWcu5aum7voMmmtgMjWmWmBXywjuGumz)w3aSwxkYftwkTf87HmJHHpM6IHhveujMhZtIPKyuiHXMI5ismgGedhdQGumCGP6sX8c4wXum(skY99aZaZSfJcuryXiqkgoaNGGywevoxIHdmQ77XGDwlGx(yoYH9MCKkoJngFjf5(yiN18EGPVKICFNhblIkNlBopV18gpPEYfy6lPi335rWIOY5cBB5Q6imGudNGAjWftkZJGfrLZL2dlYL(nLOCHVH8k1akWjDpL(EDyTxjbM(skY9DEeSiQCUW2wUVaUvmfy6lPi335rWIOY5cBB5(2Abn)sTuTaL5rWIOY5s7Hf5s)2ELl8neGJG3KZzHaZaZSfJcuryXiqkgGcGmpgPuHyetqm(siOyQpgNIxwNZc9atFjf5(nmQfgbMzlM8fEbCRykMcpgEY)fNfIjRJedfg7biNZcXahOwWhtDXSiQCUKzGPVKICpBB5(c4wXuGPVKICpBB5sXrLZzbLpxf2GdqgM3qGbCTfrLRoiPmf3YaBWbidZ7iWao24j1toi14SaKEf0SL9oRmuWNhS2Mj)fiZatFjf5E22YLIJkNZckFUkS91zyHM4idquMIBzGTNhS2M4idq(oUFncEdJROaFEzey6lPi3Z2wU4w3aSwxkY1wwWVhuUW3sahdoEh36gG16srUocu96(8YiW0xsrUNTTCxU128LuKRzRxu(Cvy7fWTIjiPCHV9c4wXeK6iIbdey6lPi3Z2wUl3AB(skY1S1lkFUkSTsVYf(wwytClCsx1Fbqn)F))66W5CwiTBxIiDdhHic0LAHrDgzgy6lPi3Z2wUVTwqZVulvlq5cF75bRTjoYaKVJ7xJG3W4kkWN3wwkb7rmhGtqgqp5VP6mA)IWCjeyZKkhdoE)T1cA(LAPAbDeO6195HxgMKgcu96EQiahbVjNZcuxevosJNuN8yTXYatFjf5E22YD5wBZxsrUMTEr5ZvHTercm9LuK7zBl3LBTnFjf5A26fLpxf2sfcwsGPVKICpBB56OLFqtiieCIYf(gCaYW8EcWRvjyTTxjSrXrLZzHoCaYW8gcmGRTiQC1bPatFjf5E22Y1rl)GgpJ9HatFjf5E22Y1wgMKVL9IjzOcNey6lPi3Z2wUCUrJG3euTW4dmdmZwmknHytefEFGPVKICFFL(nCRBawRlf5cmZwm5t8y8u6JXrqmm8khZFfpeJycIHCqmkSetXyjkeEjg2zxP0Jj77dXOqtWftY86mIb3FbqXiM8lgLwPgtcWRvjXqqXOWsmryKy8Z8yuALApW0xsrUVVspBB5Q6imGudNGAjWftkVmFzHM4idq(T9kx4BiVsnGcCs3tPVZWtnlXrgG0LsfAcPLkiVfrLJ04j1jFpb41QefCFxj72TiQCKgpPo57jaVwLG12IVP6k2EE4szgyMTyYN4XCKy8u6JrHL1gtQGyuyjMQlgXeeZbkkXWsZ8khdZdXywXvkXqUy4i)hJclXeHrIXpZJrPvQ9atFjf5((k9STLRQJWasnCcQLaxmPCHVH8k1akWjDpL(EDyXsZG9iVsnGcCs3tPVNyqUuKJ6IOYrA8K6KVNa8AvcwBl(MQRy75HlfyMTyYhWLar8ySeJA52ywKlvsro3(XW5pKIHCXSyqi4KyEEyfy6lPi33xPNTTCP4OY5SGYNRcBuGlbI4TRmmjV4wmauBrUujf5uMIBzGnSjUfoPFLHj5f3IbG6W5CwiTBh2e3cN0bfF)myQZfOdNZzH0UDlcXMik86GIVFgm15c0rGQx3NNsW(muqXTWj9ea8aQ9cYf3au7W5Cwify6lPi33xPNTTCPaxceXvUW3W2lGBftqQJigma1er6igEHbbDPwyuNbvSLaogC8of4sGiENHNkfhvoNf6uGlbI4TRmmjV4wmauBrUujf5cmZwm5d)Q3umkSetXOav8nIHTyyTmmjV4wmau(fJz1vSuzuJrPvQX4xkgfOIVrmiWtMhdobfZbkkXywuALsGPVKICFFLE22YLIF1Bs5cFtClCshu89ZGPoxGoCoNfsuf3cN0VYWK8IBXaqD4ColKOc44WskkqBru5inEsDYJ12IVP6k2EE4suxeInru41bfF)myQZfOJavVUpV9bMzlM8HF1BkgfwIPyyTmmjV4wmaumSfdRKyuGk(g5xmMvxXsLrngLwPgJFPyYhWLar8yy4dm9LuK77R0Z2wUu8REtkx4BIBHt6xzysEXTyaOoCoNfsuXM4w4KoO47NbtDUaD4ColKOc44WskkqBru5inEsDYJ12IVP6k2EE4sutahdoENcCjqeVZWhy6lPi33xPNTTC5jeBdbpHbTaLXjO2bkkB7vguuqEZvjmNSXcLey6lPi33xPNTTCP4x9MuUW3e3cN0Fgobq4mgqhoNZcjQy7fWTIji1redgG6IqSjIcVUHJqeb6m8uZkrKUHJqeb6iahbVjNZc72LaogC8of4sGiENHNAIiDdhHic05vzSsXBlaL32(mPUiQCKgpPo57jaVwLG1wwppyTnXrgG8DC)Ae8ggxrbESY(WImPI8k1akWjDpL(EDyTpJaZSft(WV6nfJclXumMv)fafd25F)Rl)IHvsmVaUvmfJFPyosm(skkqmMvStmCm44kht(YWlmiiMJiXuxmiahbVPyq(zakhtIbvNrm5d4sGioBSNtGPVKICFFLE22YLIF1Bs5cFllXTWjDv)fa18)9)RRdNZzH0UDiMdWjidOR6imAe8MycAQ(laQ5)7)xxMuX2lGBftqQ7wlvv)fa18)9)RRHavVUpVnZqfBjI0rm8cdc6iahbVjNZcutePB4ierGocu96ESyj1eWXGJ3PaxceX7m8utahdoE)nvu6m8bMzlgfOIVFgm15ceJcnbxmhrI5fWTIjifJFPy4iIPyYxgEHbbX4xkgZIJqebIXrqmm8XGtqXyjNrmWrymm1dm9LuK77R0Z2wUGIVFgm15cOCHVHTxa3kMGuhrmyaQzHTer6gocreOJaCe8MColqnrKoIHxyqqhbQEDpwSGnwOGl(MQRy75HlTBxIiDedVWGGocu96Ef0mDLGL4idq6sPcnH0sfKjvXrgG0LsfAcPLkalwey6lPi33xPNTTCFtffLl8Ter6igEHbbDPwyuNXUDjI0FG)RVl1cJ6mcm9LuK77R0Z2wU8ePiNYf(ghdoENZsijlZlDe4lz3UeWXGJ3PaxceX7m8bM(skY99v6zBlxolHKA4miZvUW3sahdoENcCjqeVZWhy6lPi33xPNTTC5a0dimQZq5cFlbCm44DkWLar8odFGPVKICFFLE22YfVqaNLqskx4BjGJbhVtbUeiI3z4dm9LuK77R0Z2wU(TGxqUTTCRv5cFlbCm44DkWLar8odFGPVKICFFLE22YL5HwjGQYaooSK25QWMH1tLle03uHKBTf5uUW3sahdoENcCjqeVZWhy6lPi33xPNTTCzEOvcOQmGJdlPDUkSzy9u5cb9nopzakx4BjGJbhVtbUeiI3z4dmZwmkfa3zSsm4U1Y5lmIbNGIH5DoletjG6NFXK99HyixmlcXMik86bM(skY99v6zBlxMhALaQFGzGz2IrPuiyjXKCv3aIX5kBjf8bMzlgf4rboIAmUedlylMSucBXOWsmfJsHoZyuALApM8PQkKkxaR5XqUyYGTyehzaYRCmkSetXKpGlbI4khdbfJclXumSNt2ZXqetasH1dXOqVKyWjOyEIkedCaYW8Emyh7tIrHEjXu4XOav8nIzru5iXuFmlIADgXWW3dm9LuK77PcblzdokWruvUW3aCCyjffOTiQCKgpPo5XAJfSjUfoPNaGhqTxqU4gGAhoNZcjQzLaogC8of4sGiENHF3UeWXGJ3FtfLod)UDWbidZ7jaVwLK3wgkHnkoQCol0HdqgM3qGbCTfrLRoiTBh2O4OY5Sq)RZWcnXrgGKj1SWM4w4KoO47NbtDUaD4ColK2TBri2erHxhu89ZGPoxGocu96ESYiZatFjf5(EQqWsyBlxkoQColO85QWgZdn8YAbKYuCldSTiQCKgpPo57jaVwLG1(D7GdqgM3taETkjVTmucBuCu5CwOdhGmmVHad4AlIkxDqA3oSrXrLZzH(xNHfAIJmajW0xsrUVNkeSe22Y9beYfi14ih0E(cdq5L5ll0ehzaYVTx5cFJJbhV)2Abn)sTuTGodpvSLis)beYfi14ih0E(cdOLisxQfg1zSBhEzysAiq1R7ZBtj72TieBIOWR)ac5cKACKdApFHb0xMCKb8nCKVKICUfRTm6MnLSB3tySC1L6wWtnoZBGIUkVf6W5CwirfBCm44Dl4PgN5nqrxL3cDg(aZSft2VFXqWJj7XvuGpgxIzVzNTyEXxy8XqWJj7PkLGlMCSEc(yiOyCdVUxIHfSfJ4idq(EGPVKICFpviyjSTLlUFncEdJROaVYf(gfhvoNf6mp0WlRfquZIJbhVBQsj4ACwpbF)fFHbwB7n772Lf24rfbvI5nerCPih1NhS2M4idq(oUFncEdJROapwBSGTxa3kMGuhrmyGmZmWmBXK97xme8yYECff4JriX488wZJrPaEYAEmkvs9KlMcpM68LuuGyixm(zEmIJmajgxIHLXioYaKVhy6lPi33tfcwcBB5I7xJG3W4kkWR8Y8LfAIJma532RCHVrXrLZzHoZdn8YAbe1NhS2M4idq(oUFncEdJROapwBSmW0xsrUVNkeSe22YfwMi1z0qapQu9lPCHVrXrLZzHoZdn8YAbe1fHytefEDkWLar8ocu96ES2BMatFjf5(EQqWsyBlxxLJ5nPCHVrXrLZzHoZdn8YAbuGz2IHDNd7nRmszDbIriX488wZJrPaEYAEmkvs9KlgxIjJyehzaYhy6lPi33tfcwcBB5QYiL1fq5L5ll0ehzaYVTx5cFJIJkNZcDMhA4L1ciQppyTnXrgG8DC)Ae8ggxrb(Tmcm9LuK77PcblHTTCvzKY6cOCHVrXrLZzHoZdn8YAbuGzGz2IrP4QUbedHcGIrkvigNRSLuWhyMTyYFLAjXywCeIiWhd5I5ih2ZJkvKJmpgXrgG8XGtqXiMGy4rfbvI5XGiIlf5IPWJrjSfdNfG0hJJGyClc8K5XWWhy6lPi33tezJIJkNZckFUkS9yu8TL5ll0mCeIiGYuCldSXJkcQeZBiI4sroQppyTnXrgG8DC)Ae8ggxrbESyj1SsePB4ierGocu96(8weInru41nCeIiqpXGCPi3UD8K6jhKACwaspwkjZaZSft(RuljM8LHxyqWhd5I5ih2ZJkvKJmpgXrgG8XGtqXiMGy4rfbvI5XGiIlf5IPWJrjSfdNfG0hJJGyClc8K5XWWhy6lPi33teHTTCP4OY5SGYNRcBpgfFBz(YcnedVWGaLP4wgyJhveujM3qeXLICuFEWABIJma574(1i4nmUIc8yXsQzLaogC8(BQO0z43TJNup5GuJZcq6XsjzgyMTyYFLAjXKVm8cdc(yk8yYhWLarC2OnvuY1S6VaOyWo)7)xxm1hddFm(LIrHqmMCkqmzWwmpSix6JXc4smKlgXeet(YWlmiigLcH9atFjf5(EIiSTLlfhvoNfu(Cvy7XO4BigEHbbktXTmWwc4yWX7uGlbI4DgEQzLaogC8(BQO0z43Tt1Fbqn)F))6Aiq1R7XYmzsnrKoIHxyqqhbQEDpwzeyMTyO5Hv52ymlocreig)sXKVm8cdcI5bHHpgEurqXiKyuGk((zWuNlqml)LatFjf5(EIiSTLRHJqebuUW3e3cN0bfF)myQZfOdNZzHevSbk((zWuNlqQB4ieraQjI0nCeIiqNxLXkfVTauEB7PUieBIOWRdk((zWuNlqhbQEDFEzq95bRTjoYaKVJ7xJG3W4kkWVTNkYRudOaN09u671Hf2LAIiDdhHic0rGQx3RGMPRK8ehzasxkvOjKwQGatFjf5(EIiSTLlIHxyqGYf(M4w4KoO47NbtDUaD4ColKOMfGJdlPOaTfrLJ04j1jpwBl(MQRy75HlrDri2erHxhu89ZGPoxGocu96(82tnrKoIHxyqqhbQEDVcAMUsYtCKbiDPuHMqAPcYmWmBXywCeIiqmm8yaaVYX42NeJGk4JriXW8qmLeJ)X4X88WQCBmgWbixiOyWjOyetqmw)LyuALAmCaobbX4XGxx9MauGPVKICFpre22YLNqSne8eg0cugNGAhOOSTpW0xsrUVNicBB5A4ieraLl8neGJG3KZzbQlIkhPXtQt(EcWRvjyTTNAw8QmwP4TfGYBB)UDiq1R7ZBtQfgnPubQppyTnXrgG8DC)Ae8ggxrbES2yzMuZcBGIVFgm15cK2TdbQEDFEBsTWOjLkOGzq95bRTjoYaKVJ7xJG3W4kkWJ1glZKAwIJmaPlLk0eslva2JavVUptSybvv)fa18)9)RRHavVUFZmbM(skY99eryBlxEcX2qWtyqlqzCcQDGIY2(atFjf5(EIiSTLRHJqebuEz(YcnXrgG8B7vUW3WgfhvoNf6pgfFBz(YcndhHicqfb4i4n5CwG6IOYrA8K6KVNa8AvcwB7PMfVkJvkEBbO822VBhcu96(82KAHrtkvG6ZdwBtCKbiFh3VgbVHXvuGhRnwMj1SWgO47NbtDUaPD7qGQx3N3MulmAsPckyguFEWABIJma574(1i4nmUIc8yTXYmPML4idq6sPcnH0sfG9iq1R7ZeR9zqv1Fbqn)F))6Aiq1R73mtGz2IrPrL6tUyyhu5HxIHCXOYyLI3cXioYaKpgxIHfSfJsRuJrHMGlgeZD1zedHrIPUyY4Jjlg(yesmSigXrgG8zgdbfdl)yYsjSfJ4idq(mdm9LuK77jIW2wUluP(KRjGkp8IYf(2ZdwBtCKbipwBzqfbQEDFEzWwwppyTnXrgG8yTPKmPc44WskkqBru5inEsDYJ1glcmZwmzpaGpgg(yYxgEHbbX4smSGTyixmU1gJ4idq(yYsHMGlgBrPoJySKZig4imgMIXVumhrI5pN)nrKmdm9LuK77jIW2wUigEHbbkx4ByJIJkNZc9hJIVHy4fgeqnlahhwsrbAlIkhPXtQtES2ybveGJG3KZzHD7WMulmQZGAwsPcyT3m72TiQCKgpPo5XAlJmZKAw8QmwP4TfGYBB)UDiq1R7ZBtQfgnPubQppyTnXrgG8DC)Ae8ggxrbES2yzMuZcBGIVFgm15cK2TdbQEDFEBsTWOjLkOGzq95bRTjoYaKVJ7xJG3W4kkWJ1glZKQ4idq6sPcnH0sfG9iq1R7XIfbM(skY99eryBlxedVWGaLxMVSqtCKbi)2ELl8nSrXrLZzH(JrX3wMVSqdXWlmiGk2O4OY5Sq)XO4BigEHbbubCCyjffOTiQCKgpPo5XAJfuraocEtoNfOMfVkJvkEBbO822VBhcu96(82KAHrtkvG6ZdwBtCKbiFh3VgbVHXvuGhRnwMj1SWgO47NbtDUaPD7qGQx3N3MulmAsPckyguFEWABIJma574(1i4nmUIc8yTXYmPkoYaKUuQqtiTubypcu96ESyrGz2IrPrL6tUyyhu5HxIHCXqZEmfEm1fdVFjqTwX4xkMsIrHL1gtIeJf(pMKR6gqmIj)IrbEuGJOgtIbIriXWEo5AwXobM(skY99eryBl3fQuFY1eqLhEr5cF75bRTjoYaKFBpvahhwsrbAlIkhPXtQtES2YAX3uDfBppCjSFFMuraocEtoNfOInqX3pdM6CbsuXwc4yWX7VPIsNHNQQ)cGA()()11qGQx3VzgQIJmaPlLk0eslva2JavVUhlwey6lPi33teHTTCFG)RpWmWmBXqlGBftqkgSZskY9bMzlgwldtV4wmaumKlgwYE(fJsJk1NCXWoOYdVey6lPi33FbCRycsBluP(KRjGkp8IYf(M4w4K(vgMKxClgaQdNZzHe1NhS2M4idqES2yj1frLJ04j1jpwBSGQ4idq6sPcnH0sfG9iq1R7Xc7gyMTyyTmm9IBXaqXqUy2ZE(fd958VjIet(YWlmiiW0xsrUV)c4wXeKyBlxedVWGaLl8nXTWj9RmmjV4wmauhoNZcjQlIkhPXtQtES2ybvXrgG0LsfAcPLka7rGQx3Jf2nWmBXqZWjacNXaYVyWo88wZJHGIjFbCe8MIrHLykgogCCifJzXriIaFGPVKICF)fWTIjiX2wU8eITHGNWGwGY4eu7afLT9bM(skY99xa3kMGeBB5A4ieraLxMVSqtCKbi)2ELl8nXTWj9NHtaeoJb0HZ5SqIAwiq1R7ZBFg72XRYyLI3wakVT9zsvCKbiDPuHMqAPcWEeO619yLrGz2IHMHtaeoJbedBXOav8nIHCXSN98lM8fWrWBkgZIJqebIXLyetqmWLIHGhZlGBftXiKymajgvxXysmixkYfdhGtqqmkqfF)myQZfiW0xsrUV)c4wXeKyBlxEcX2qWtyqlqzCcQDGIY2(atFjf5((lGBftqITTCnCeIiGYf(M4w4K(ZWjacNXa6W5CwirvClCshu89ZGPoxGoCoNfsu9LuuGgCGAb)2EQCm449NHtaeoJb0rGQx3N3(oldm9LuK77VaUvmbj22YvLrkRlGYf(M4w4K(ZWjacNXa6W5CwirDru5inEsDYN3gl1Iw0Aa]] )

end