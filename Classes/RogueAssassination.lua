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


    spec:RegisterPack( "Assassination", 20201129, [[da1tsbqiOuEKOuUKOQaBcQ6tIsvJsuYPefTkuI6vOuMfjQBbLk7sQ(LOsdJIIJbfwMOWZibMgkHRrIyBqPQ(MOuPXjkvCouIyDIQkVJIsLmprvUNszFqj)tuvqhekvzHIkEijsnrkkPlsIeBuuvOpsrjgjfLk1jfvLSsOOxIsK0mfvfDtkkLDIsAOKiPLkQQ6Pi1urP6QuuQQTkQk1xPOuXyrjsTxs9xPmyfhMQfJQESsMSixgSzK8zkmAkYPLSAkkv51kvnBkDBsA3Q8BedhvookrILd55QA6exhfBhQ8DsqJNe68uunFLk7xyngA210jxanRzyMmmdgyKblPBMSdlYWmSqtlMZbAAoFT3nan95QGMg79V)FDUuKttZ5MBjEsZUM(jmOfOPnjc3NF5MRrjMy47lIAUFPYyDPi3c5usUFPUYvtZZuwjFDAEnDYfqZAgMjdZGbgzWs6Mj7WIm00oJyIG000LQsRPnvPeCAEnDc(LMoBXG9(3)VoxkYft(tmyGaZSfdReCGkpGIjdwIYXKHzYWmbMbMzlgZgbhKIjF06gG16srUyYsPTGFpKzmmCXuxmCOIGkX8yEsmLeJcjm2umhrIXaKy4zqfKIHhmvxkMxa3kMIXxsrUVRPT1lVMDn9lGBftqsZUMvm0SRPHZ5TqsNJMEHkbqLRPf3cN0VYWK8IB3dOoCoVfsXGpMNdS2M4idq(yWAlgfed(ywevEsJJuN8XG1wmSig8XioYaKUuQqtiTubXGDXGavVUpgSIb7RP9LuKttVqL6tUMaQCWlArZAgA210W58wiPZrtVqLaOY10IBHt6xzysEXT7buhoN3cPyWhZIOYtACK6KpgS2IHfXGpgXrgG0LsfAcPLkigSlgeO619XGvmyFnTVKICAAedNWGaTOzvbA210W58wiPZrttrqTduu0SIHM2xsronnhHyBi4jmOfOfnRSqZUMgoN3cjDoAAFjf500gocreqtVqLaOY10IBHt6pdVaikgdOdNZBHum4JjRyqGQx3htEXGrgXSBxmCQmwP4SfGIjVTyWiMmJbFmIJmaPlLk0eslvqmyxmiq1R7JbRyYqtVmFzHM4idqEnRyOfnRkrZUMgoN3cjDoAAkcQDGIIMvm00(skYPP5ieBdbpHbTaTOzf7RzxtdNZBHKohn9cvcGkxtlUfoP)m8cGOymGoCoVfsXGpgXTWjDqX3pdM6Cb6W58wifd(y8Lu4GgCGAbFmBXGrm4JHNHIQ)m8cGOymGocu96(yYlgm6kqt7lPiNM2WriIaArlA6eq5mwrZUMvm0SRP9LuKttVVw710W58wiPZrlAwZqZUM2xsron9lGBftAA4CElK05OfnRkqZUMgoN3cjDoAAcNM(brt7lPiNMgNJkN3cAACULb00WbidZ7iWaUyylgos9KdsnElaPpgwoMSBm5gtwXKrmSCmphyTnt(lqmzQPX5O25QGMgoazyEdbgW1wev(6GKw0SYcn7AA4CElK05OPjCA6henTVKICAACoQCElOPX5wgqt)CG12ehzaY3P8RrOA7Vch8XKxmzOPX5O25QGM(RZWcnXrgGOfnRkrZUMgoN3cjDoA6fQeavUMob8muuDkRBawRlf56iq1R7JjVyYqt7lPiNMMY6gG16srU2Yc(9Gw0SI91SRPHZ5TqsNJMEHkbqLRPFbCRycsDeXGb00(skYPPxU128LuKRzRx0026L25QGM(fWTIjiPfnRzxn7AA4CElK05OPxOsau5A6SIbBXiUfoPR6VaOM)V)FDD4CElKIz3UysePB4ierGUuR91zetMAAFjf500l3AB(skY1S1lAAB9s7CvqtVsVw0SMD0SRPHZ5TqsNJMEHkbqLRPFoWABIJma57u(1iuT9xHd(yYBlMSIrjXGDXGyoGIGmGEYFt1z0(fH5siW2HZ5TqkMmJbFm8muu93wlO5xQLQf0rGQx3htEXqvgMKgcu96(yWhdcOqWBY5Tqm4Jzru5jnosDYhdwBXOanTVKICA63wlO5xQLQfOfnRSen7AA4CElK05OP9LuKttVCRT5lPixZwVOPT1lTZvbnDIiArZkgMrZUMgoN3cjDoAAFjf500l3AB(skY1S1lAAB9s7CvqtNkeSeTOzfdm0SRPHZ5TqsNJMEHkbqLRPHdqgM3tavTkjgS2IbdLedBXGZrLZBHoCaYW8gcmGRTiQ81bjnTVKICAAhT8dAcbHGt0IMvmYqZUM2xsronTJw(bnog7dAA4CElK05OfnRyOan7AAFjf5002YWK8nZEmjdv4ennCoVfs6C0IMvmyHMDnTVKICAAE3OrOAcQw7FnnCoVfs6C0Iw00Ciyru5DrZUMvm0SRP9LuKtt7CCwZBCK6jNMgoN3cjDoArZAgA210W58wiPZrt7lPiNMw1r7HuJIGAjWftA6fQeavUMg5vQb4Gt6Ek996IbRyWqjAAoeSiQ8U0EyrU0RPvIw0SQan7AAFjf500VaUvmPPHZ5TqsNJw0SYcn7AA4CElK05OP9LuKtt)2Abn)sTuTan9cvcGkxtJake8MCElOP5qWIOY7s7Hf5sVMgdTOfnDQqWs0SRzfdn7AA4CElK05OPxOsau5AAGIcwsHdAlIkpPXrQt(yWAlgwedBXiUfoPNaGdqTxqU4gGAhoN3cPyWhtwXKaEgkQoo4sGiENHlMD7Ijb8muu93uHRZWfZUDXahGmmVNaQAvsm5Tftgkjg2IbNJkN3cD4aKH5neyaxBru5RdsXSBxmylgCoQCEl0)6mSqtCKbiXKzm4JjRyWwmIBHt6GIVFgm15c0HZ5TqkMD7Izri2erHxhu89ZGPoxGocu96(yWkMmIjtnTVKICAA4WbhrvlAwZqZUMgoN3cjDoAAcNM(brt7lPiNMgNJkN3cAACULb00lIkpPXrQt(EcOQvjXGvmyeZUDXahGmmVNaQAvsm5Tftgkjg2IbNJkN3cD4aKH5neyaxBru5RdsXSBxmylgCoQCEl0)6mSqtCKbiAACoQDUkOPzEOrvwlG0IMvfOzxtdNZBHKohnTVKICA6hqixGuJNCq75Q9GMEHkbqLRP5zOO6VTwqZVulvlOZWfd(yWwmjI0FaHCbsnEYbTNR2dTer6sT2xNrm72fdvzysAiq1R7JjVTyusm72fZIqSjIcV(diKlqQXtoO9C1EOVm5id4BuiFjf5CBmyTftg9SRsIz3UyEcJLVUu3cEQXBEdu0v5SqhoN3cPyWhd2IHNHIQBbp14nVbk6QCwOZWPPxMVSqtCKbiVMvm0IMvwOzxtdNZBHKohn9cvcGkxtJZrLZBHoZdnQYAbum4JjRy4zOO6MQucUgV1tW3FXx7JbRTyWGLeZUDXKvmylgourqLyEdrexkYfd(yEoWABIJma57u(1iuT9xHd(yWAlgwedBX8c4wXeK6iIbdetMXKPM2xsronnLFncvB)v4GxlAwvIMDnnCoVfs6C00(skYPPP8RrOA7Vch8A6fQeavUMgNJkN3cDMhAuL1cOyWhZZbwBtCKbiFNYVgHQT)kCWhdwBXOan9Y8LfAIJma51SIHw0SI91SRPHZ5TqsNJMEHkbqLRPX5OY5TqN5HgvzTakg8XSieBIOWRJdUeiI3rGQx3hdwXGHz00(skYPPHLjsDgneWHkv)sArZA2vZUMgoN3cjDoA6fQeavUMgNJkN3cDMhAuL1cinTVKICAAxLN5nPfnRzhn7AA4CElK05OP9LuKttRYiL1fqtVqLaOY104Cu58wOZ8qJQSwafd(yEoWABIJma57u(1iuT9xHd(y2Ijdn9Y8LfAIJma51SIHw0SYs0SRPHZ5TqsNJMEHkbqLRPX5OY5TqN5HgvzTast7lPiNMwLrkRlGw0IMELEn7AwXqZUM2xsronnL1naR1LICAA4CElK05OfnRzOzxtdNZBHKohnTVKICAAvhThsnkcQLaxmPPxOsau5AAKxPgGdoP7P03z4IbFmzfJ4idq6sPcnH0sfetEXSiQ8KghPo57jGQwLedlhdgDLeZUDXSiQ8KghPo57jGQwLedwBXS4AQUITNdUumzQPxMVSqtCKbiVMvm0IMvfOzxtdNZBHKohn9cvcGkxtJ8k1aCWjDpL(EDXGvmkWmXGDXG8k1aCWjDpL(EIb5srUyWhZIOYtACK6KVNaQAvsmyTfZIRP6k2Eo4sAAFjf500QoApKAueulbUyslAwzHMDnnCoVfs6C00eon9dIM2xsronnohvoVf004CldOPXwmIBHt6xzysEXT7buhoN3cPy2TlgSfJ4w4KoO47NbtDUaD4CElKIz3UyweInru41bfF)myQZfOJavVUpM8IrjXGDXKrmSCmIBHt6ja4au7fKlUbO2HZ5TqstJZrTZvbnno4sGiE7kdtYlUDpGAlYLkPiNw0SQen7AA4CElK05OPxOsau5AASfZlGBftqQJigmqm4JjrKoIHtyqqxQ1(6mIbFmylMeWZqr1XbxceX7mCXGpgCoQCEl0XbxceXBxzysEXT7buBrUujf500(skYPPXbxceX1IMvSVMDnnCoVfs6C00lujaQCnT4w4KoO47NbtDUaD4CElKIbFmIBHt6xzysEXT7buhoN3cPyWhdqrblPWbTfrLN04i1jFmyTfZIRP6k2Eo4sXGpMfHytefEDqX3pdM6Cb6iq1R7JjVyWqt7lPiNMgNF1BslAwZUA210W58wiPZrtVqLaOY10IBHt6xzysEXT7buhoN3cPyWhd2IrClCshu89ZGPoxGoCoVfsXGpgGIcwsHdAlIkpPXrQt(yWAlMfxt1vS9CWLIbFmjGNHIQJdUeiI3z400(skYPPX5x9M0IM1SJMDnnCoVfs6C00(skYPP5ieBdbpHbTannOOG8MRsyortZcLOPPiO2bkkAwXqlAwzjA210W58wiPZrtVqLaOY10IBHt6pdVaikgdOdNZBHum4JbBX8c4wXeK6iIbded(yweInru41nCeIiqNHlg8XKvmjI0nCeIiqhbui4n58wiMD7Ijb8muuDCWLar8odxm4JjrKUHJqeb6CQmwP4SfGIjVTyWiMmJbFmlIkpPXrQt(EcOQvjXG1wmzfZZbwBtCKbiFNYVgHQT)kCWhdw5dJHfXKzm4Jb5vQb4Gt6Ek996IbRyWidnTVKICAAC(vVjTOzfdZOzxtdNZBHKohn9cvcGkxtNvmIBHt6Q(laQ5)7)xxhoN3cPy2TlgeZbueKb0vD0(gHQjMGMQ)cGA()()11HZ5TqkMmJbFmylMxa3kMGu3T2yWhJQ)cGA()()11qGQx3htEBXyMyWhd2IjrKoIHtyqqhbui4n58wig8XKis3WriIaDeO619XGvmkig8XKaEgkQoo4sGiENHlg8XKaEgkQ(BQW1z400(skYPPX5x9M0IMvmWqZUMgoN3cjDoA6fQeavUMgBX8c4wXeK6iIbded(yYkgSftIiDdhHic0rafcEtoVfIbFmjI0rmCcdc6iq1R7JbRyyrmSfdlIHLJzX1uDfBphCPy2TlMer6igoHbbDeO619XWYXyMUsIbRyehzasxkvOjKwQGyYmg8XioYaKUuQqtiTubXGvmSqt7lPiNMgu89ZGPoxaTOzfJm0SRPHZ5TqsNJMEHkbqLRPtePJy4ege0LATVoJy2TlMer6pW913LATVodnTVKICA63uHtlAwXqbA210W58wiPZrtVqLaOY108muuDElHKSmV0rGVKy2TlMeWZqr1XbxceX7mCAAFjf500CePiNw0SIbl0SRPHZ5TqsNJMEHkbqLRPtapdfvhhCjqeVZWPP9LuKttZBjKuJIbzUw0SIHs0SRPHZ5TqsNJMEHkbqLRPtapdfvhhCjqeVZWPP9LuKttZdOhq7RZqlAwXa7RzxtdNZBHKohn9cvcGkxtNaEgkQoo4sGiENHtt7lPiNMMQqaVLqsArZkgzxn7AA4CElK05OPxOsau5A6eWZqr1XbxceX7mCAAFjf500(TGxqUTTCRvlAwXi7OzxtdNZBHKohnTVKICAAdRNkxiOVPcj3AlYPPxOsau5A6eWZqr1XbxceX7mCAAGIcws7CvqtBy9u5cb9nvi5wBroTOzfdwIMDnnCoVfs6C00(skYPPnSEQCHG(gVNman9cvcGkxtNaEgkQoo4sGiENHttduuWsANRcAAdRNkxiOVX7jdqlAwZWmA210(skYPPzEOvcO(AA4CElK05OfTOPterZUMvm0SRPHZ5TqsNJMMWPPFq00(skYPPX5OY5TGMgNBzannhQiOsmVHiIlf5IbFmphyTnXrgG8Dk)AeQ2(RWbFmyfJcIbFmzftIiDdhHic0rGQx3htEXSieBIOWRB4ierGEIb5srUy2Tlgos9KdsnElaPpgSIrjXKPMgNJANRcA6FFX1wMVSqZWriIaArZAgA210W58wiPZrtt400piAAFjf5004Cu58wqtJZTmGMMdveujM3qeXLICXGpMNdS2M4idq(oLFncvB)v4GpgSIrbXGpMSIjb8muu93uHRZWfZUDXWrQNCqQXBbi9XGvmkjMm104Cu7Cvqt)7lU2Y8LfAigoHbbArZQc0SRPHZ5TqsNJMMWPPFq00(skYPPX5OY5TGMgNBzanDc4zOO64GlbI4DgUyWhtwXKaEgkQ(BQW1z4Iz3Uyu9xauZ)3)VUgcu96(yWkgZetMXGpMer6igoHbbDeO619XGvmzOPX5O25QGM(3xCnedNWGaTOzLfA210W58wiPZrtVqLaOY10IBHt6GIVFgm15c0HZ5Tqkg8XGTysapdfv3WriIaDqX3pdM6CbsXGpMer6gocreOZPYyLIZwakM82IbJyWhZIqSjIcVoO47NbtDUaDeO619XKxmzed(yEoWABIJma57u(1iuT9xHd(y2IbJyWhdYRudWbN09u671fdwXG9JbFmjI0nCeIiqhbQEDFmSCmMPRKyYlgXrgG0LsfAcPLkqt7lPiNM2WriIaArZQs0SRPHZ5TqsNJMEHkbqLRPf3cN0bfF)myQZfOdNZBHum4JjRyakkyjfoOTiQ8KghPo5JbRTywCnvxX2Zbxkg8XSieBIOWRdk((zWuNlqhbQEDFm5fdgXGpMer6igoHbbDeO619XWYXyMUsIjVyehzasxkvOjKwQGyYut7lPiNMgXWjmiqlAwX(A210W58wiPZrttrqTduu0SIHM2xsronnhHyBi4jmOfOfnRzxn7AA4CElK05OPxOsau5AAeqHG3KZBHyWhZIOYtACK6KVNaQAvsmyTfdgXGpMSIHtLXkfNTaum5TfdgXSBxmiq1R7JjVTyKATVjLked(yEoWABIJma57u(1iuT9xHd(yWAlgfetMXGpMSIbBXak((zWuNlqkMD7IbbQEDFm5TfJuR9nPuHyy5yYig8X8CG12ehzaY3P8RrOA7Vch8XG1wmkiMmJbFmzfJ4idq6sPcnH0sfed2fdcu96(yYmgSIHfXGpgv)fa18)9)RRHavVUpMTymJM2xsronTHJqeb0IM1SJMDnnCoVfs6C00ueu7affnRyOP9LuKttZri2gcEcdAbArZklrZUMgoN3cjDoAAFjf500gocreqtVqLaOY10ylgCoQCEl0)9fxBz(YcndhHiced(yqafcEtoVfIbFmlIkpPXrQt(EcOQvjXG1wmyed(yYkgovgRuC2cqXK3wmyeZUDXGavVUpM82IrQ1(MuQqm4J55aRTjoYaKVt5xJq12Ffo4JbRTyuqmzgd(yYkgSfdO47NbtDUaPy2TlgeO619XK3wmsT23KsfIHLJjJyWhZZbwBtCKbiFNYVgHQT)kCWhdwBXOGyYmg8XKvmIJmaPlLk0eslvqmyxmiq1R7JjZyWkgmYig8XO6VaOM)V)FDneO619XSfJz00lZxwOjoYaKxZkgArZkgMrZUMgoN3cjDoA6fQeavUM(5aRTjoYaKpgS2IjJyWhdcu96(yYlMmIHTyYkMNdS2M4idq(yWAlgLetMXGpgGIcwsHdAlIkpPXrQt(yWAlgwOP9LuKttVqL6tUMaQCWlArZkgyOzxtdNZBHKohn9cvcGkxtJTyW5OY5Tq)3xCnedNWGGyWhtwXauuWskCqBru5jnosDYhdwBXWIyWhdcOqWBY5Tqm72fd2IrQ1(6mIbFmzfJuQqmyfdgMjMD7Izru5jnosDYhdwBXKrmzgtMXGpMSIHtLXkfNTaum5TfdgXSBxmiq1R7JjVTyKATVjLked(yEoWABIJma57u(1iuT9xHd(yWAlgfetMXGpMSIbBXak((zWuNlqkMD7IbbQEDFm5TfJuR9nPuHyy5yYig8X8CG12ehzaY3P8RrOA7Vch8XG1wmkiMmJbFmIJmaPlLk0eslvqmyxmiq1R7JbRyyHM2xsronnIHtyqGw0SIrgA210W58wiPZrt7lPiNMgXWjmiqtVqLaOY10ylgCoQCEl0)9fxBz(YcnedNWGGyWhd2IbNJkN3c9FFX1qmCcdcIbFmaffSKch0wevEsJJuN8XG1wmSig8XGake8MCEled(yYkgovgRuC2cqXK3wmyeZUDXGavVUpM82IrQ1(MuQqm4J55aRTjoYaKVt5xJq12Ffo4JbRTyuqmzgd(yYkgSfdO47NbtDUaPy2TlgeO619XK3wmsT23KsfIHLJjJyWhZZbwBtCKbiFNYVgHQT)kCWhdwBXOGyYmg8XioYaKUuQqtiTubXGDXGavVUpgSIHfA6L5ll0ehzaYRzfdTOzfdfOzxtdNZBHKohn9cvcGkxt)CG12ehzaYhZwmyed(yakkyjfoOTiQ8KghPo5JbRTyYkMfxt1vS9CWLIb7IbJyYmg8XGake8MCEled(yWwmGIVFgm15cKIbFmylMeWZqr1FtfUodxm4Jr1Fbqn)F))6Aiq1R7JzlgZed(yehzasxkvOjKwQGyWUyqGQx3hdwXWcnTVKICA6fQuFY1eqLdErlAwXGfA210(skYPPFG7RxtdNZBHKohTOfTOPXbOViNM1mmtgMbdmYi7OPvOJU6mEnTzhSx(ZA(IvZs(ftmSBcIPu5iijgkckMSpbuoJvY(yqalfMcbPyEIkeJZievxGumlt(zaFpWmFwheJcYVyuAYHdqcKIHUuv6yEZpXvmM8bXiKyYNmEmPcx9f5IHWbixiOyYk3mJjlmumZEGz(SoiMSt(fJstoCasGumzpI5akcYa6S0zFmcjMShXCafbzaDw6oCoVfszFmzHHIz2dmdmn7G9YFwZxSAwYVyIHDtqmLkhbjXqrqXK9R0N9XGawkmfcsX8evigNriQUaPywM8Za(EGz(Soigmmt(fJstoCasGumzpI5akcYa6S0zFmcjMShXCafbzaDw6oCoVfszFmzHHIz2dmdmn7G9YFwZxSAwYVyIHDtqmLkhbjXqrqXK9jIK9XGawkmfcsX8evigNriQUaPywM8Za(EGz(SoigwKFXO0KdhGeift2dk((zWuNlqQZsN9XiKyY(eWZqr1zP7GIVFgm15cKY(yYcdfZShygyMVu5iibsXG9JXxsrUyS1lFpWut)CWsZAgkHLOP5qeQYcA6Sfd27F))6CPixm5pXGbcmZwmSsWbQ8akMmyjkhtgMjdZeygyMTymBeCqkM8rRBawRlf5IjlL2c(9qMXWWftDXWHkcQeZJ5jXusmkKWytXCejgdqIHNbvqkgEWuDPyEbCRykgFjf5(EGzGz2IrPOiSyeifdpqrqqmlIkVlXWdg199yWERfWjFmh5WotosLIXgJVKICFmKZAEpW0xsrUVZHGfrL3LnNJZAEJJup5cm9LuK77Ciyru5DHTTCvD0Ei1OiOwcCXKYCiyru5DP9WICPFtjkxuBiVsnahCs3tPVxhwyOKatFjf5(ohcwevExyBl3xa3kMcm9LuK77Ciyru5DHTTCFBTGMFPwQwGYCiyru5DP9WICPFddLlQneqHG3KZBHaZaZSfJsrryXiqkgahGmpgPuHyetqm(siOyQpghNxwN3c9atFjf5(T91AFGz2Ij)Hxa3kMIPOIHJ8FXBHyY6iXGJXEaY5TqmWbQf8XuxmlIkVlzgy6lPi3Z2wUVaUvmfy6lPi3Z2wU4Cu58wq5ZvHn4aKH5neyaxBru5RdskJZTmWgCaYW8ocmGJnos9KdsnElaPNLZU5dYkdw(5aRTzYFbYmW0xsrUNTTCX5OY5TGYNRcBFDgwOjoYaeLX5wgy75aRTjoYaKVt5xJq12Ffo4ZlJatFjf5E22YLY6gG16srU2Yc(9GYf1wc4zOO6uw3aSwxkY1rGQx3NxgbM(skY9STL7YT2MVKICnB9IYNRcBVaUvmbjLlQTxa3kMGuhrmyGatFjf5E22YD5wBZxsrUMTEr5ZvHTv6vUO2YcBIBHt6Q(laQ5)7)xxhoN3cPD7sePB4ierGUuR91zKzGPVKICpBB5(2Abn)sTuTaLlQTNdS2M4idq(oLFncvB)v4GpVTSuc2HyoGIGmGEYFt1z0(fH5siWMjEEgkQ(BRf08l1s1c6iq1R7ZJQmmjneO6194rafcEtoVfWViQ8KghPo5XAtbbM(skY9STL7YT2MVKICnB9IYNRcBjIey6lPi3Z2wUl3AB(skY1S1lkFUkSLkeSKatFjf5E22Y1rl)GMqqi4eLlQn4aKH59eqvRsWAddLWgohvoVf6WbidZBiWaU2IOYxhKcm9LuK7zBlxhT8dACm2hcm9LuK7zBlxBzys(MzpMKHkCsGPVKICpBB5Y7gncvtq1A)hygyMTyuAcXMik8(atFjf5((k9Buw3aSwxkYfyMTyYxuX4P0hJJGyy4uoM)koigXeed5GyuyjMIXsui8smSZUzThJz)hIrHMGlMK51zedL)cGIrm5xmkTsnMeqvRsIHGIrHLyIWiX4N5XO0k1EGPVKICFFLE22Yv1r7HuJIGAjWftkVmFzHM4idq(nmuUO2qELAao4KUNsFNHdFwIJmaPlLk0eslvqElIkpPXrQt(EcOQvjSmgDLSB3IOYtACK6KVNaQAvcwBlUMQRy75GlLzGz2IjFrfZrIXtPpgfwwBmPcIrHLyQUyetqmhOOeJcmZRCmmpeJzJYSgd5IHN8FmkSetegjg)mpgLwP2dm9LuK77R0Z2wUQoApKAueulbUys5IAd5vQb4Gt6Ek996WsbMb7qELAao4KUNsFpXGCPih(frLN04i1jFpbu1QeS2wCnvxX2ZbxkWmBXKVHlbI4Xyjg1YTXSixQKICU9JH3Fifd5IzXGqWjX8CWkW0xsrUVVspBB5IZrLZBbLpxf2WbxceXBxzysEXT7buBrUujf5ugNBzGnSjUfoPFLHj5f3UhqD4CElK2TdBIBHt6GIVFgm15c0HZ5TqA3UfHytefEDqX3pdM6Cb6iq1R7ZtjyxgSS4w4KEcaoa1Eb5IBaQD4CElKcm9LuK77R0Z2wU4GlbI4kxuBy7fWTIji1redgaFIiDedNWGGUuR91zGhBjGNHIQJdUeiI3z4WJZrLZBHoo4sGiE7kdtYlUDpGAlYLkPixGz2IjF7x9MIrHLykgLIIVrmSfdRLHj5f3Uhq5xmMnxXsLrngLwPgJFPyukk(gXGapzEmueumhOOeJzrPnRbM(skY99v6zBlxC(vVjLlQnXTWjDqX3pdM6Cb6W58wiHxClCs)kdtYlUDpG6W58wiHhOOGLu4G2IOYtACK6KhRTfxt1vS9CWLWVieBIOWRdk((zWuNlqhbQEDFEyeyMTyY3(vVPyuyjMIH1YWK8IB3dOyylgwjXOuu8nYVymBUILkJAmkTsng)sXKVHlbI4XWWfy6lPi33xPNTTCX5x9MuUO2e3cN0VYWK8IB3dOoCoVfs4XM4w4KoO47NbtDUaD4CElKWduuWskCqBru5jnosDYJ12IRP6k2Eo4s4tapdfvhhCjqeVZWfy6lPi33xPNTTC5ieBdbpHbTaLPiO2bkkByOmOOG8MRsyozJfkjW0xsrUVVspBB5IZV6nPCrTjUfoP)m8cGOymGoCoVfs4X2lGBftqQJigma(fHytefEDdhHic0z4WNvIiDdhHic0rafcEtoVf2Tlb8muuDCWLar8odh(er6gocreOZPYyLIZwakVnmYe)IOYtACK6KVNaQAvcwBz9CG12ehzaY3P8RrOA7Vch8yLpKfzIh5vQb4Gt6Ek996WcJmcmZwm5B)Q3umkSetXy28xaumyV)9VU8lgwjX8c4wXum(LI5iX4lPWbXy2WEXWZqrPCm5pdNWGGyoIetDXGake8MIb5NbOCmjguDgXKVHlbI4SXEobM(skY99v6zBlxC(vVjLlQTSe3cN0v9xauZ)3)VUoCoVfs72HyoGIGmGUQJ23iunXe0u9xauZ)3)VUmXJTxa3kMGu3Tw8Q(laQ5)7)xxdbQEDFEBMbp2sePJy4ege0rafcEtoVfWNis3WriIaDeO619yPa8jGNHIQJdUeiI3z4WNaEgkQ(BQW1z4cmZwmkffF)myQZfigfAcUyoIeZlGBftqkg)sXWtetXK)mCcdcIXVumMfhHiceJJGyy4IHIGIXsoJyGJWyyQhy6lPi33xPNTTCbfF)myQZfq5IAdBVaUvmbPoIyWa4ZcBjI0nCeIiqhbui4n58waFIiDedNWGGocu96ESybBSGLxCnvxX2ZbxA3Uer6igoHbbDeO619SSz6kblXrgG0LsfAcPLkit8IJmaPlLk0eslvawSiW0xsrUVVspBB5(MkCkxuBjI0rmCcdc6sT2xNXUDjI0FG7RVl1AFDgbM(skY99v6zBlxoIuKt5IAJNHIQZBjKKL5Loc8LSBxc4zOO64GlbI4DgUatFjf5((k9STLlVLqsnkgK5kxuBjGNHIQJdUeiI3z4cm9LuK77R0Z2wU8a6b0(6muUO2sapdfvhhCjqeVZWfy6lPi33xPNTTCPkeWBjKKYf1wc4zOO64GlbI4DgUatFjf5((k9STLRFl4fKBBl3AvUO2sapdfvhhCjqeVZWfy6lPi33xPNTTCzEOvcOQmqrblPDUkSzy9u5cb9nvi5wBroLlQTeWZqr1XbxceX7mCbM(skY99v6zBlxMhALaQkduuWsANRcBgwpvUqqFJ3tgGYf1wc4zOO64GlbI4DgUaZSfJzfOCgRedLBT8(AFmueummVZBHykbu)8lgZ(ped5Izri2erHxpW0xsrUVVspBB5Y8qReq9dmdmZwmM1cbljMKR6gqmoFzlPGpWmBXOuoCWruJXLyybBXKLsylgfwIPymR0zgJsRu7XKVuvHu5cynpgYftgSfJ4idqELJrHLykM8nCjqex5yiOyuyjMIH9Cm7kgIycqkSEigf6LedfbfZtuHyGdqgM3Jb7zFsmk0ljMIkgLIIVrmlIkpjM6JzruRZiggUEGPVKICFpviyjBWHdoIQYf1gqrblPWbTfrLN04i1jpwBSGnXTWj9eaCaQ9cYf3au7W58wiHpReWZqr1XbxceX7mC72LaEgkQ(BQW1z42TdoazyEpbu1QK82YqjSHZrLZBHoCaYW8gcmGRTiQ81bPD7WgohvoVf6FDgwOjoYaKmXNf2e3cN0bfF)myQZfOdNZBH0UDlcXMik86GIVFgm15c0rGQx3Jvgzgy6lPi33tfcwcBB5IZrLZBbLpxf2yEOrvwlGugNBzGTfrLN04i1jFpbu1QeSWy3o4aKH59eqvRsYBldLWgohvoVf6WbidZBiWaU2IOYxhK2TdB4Cu58wO)1zyHM4idqcm9LuK77PcblHTTCFaHCbsnEYbTNR2dkVmFzHM4idq(nmuUO24zOO6VTwqZVulvlOZWHhBjI0FaHCbsnEYbTNR2dTer6sT2xNXUDuLHjPHavVUpVnLSB3IqSjIcV(diKlqQXtoO9C1EOVm5id4BuiFjf5ClwBz0ZUkz3UNWy5Rl1TGNA8M3afDvol0HZ5Tqcp24zOO6wWtnEZBGIUkNf6mCbMzlM8r)IHqfdl1RWbFmUedgSe2I5fFT)JHqfJz3vkbxm5y9e8XqqX4gEDVedlylgXrgG89atFjf5(EQqWsyBlxk)AeQ2(RWbVYf1gohvoVf6mp0OkRfq4ZINHIQBQsj4A8wpbF)fFThRnmyj72Lf24qfbvI5nerCPih(NdS2M4idq(oLFncvB)v4GhRnwW2lGBftqQJigmqMzgyMTyYh9lgcvmSuVch8XiKyCooR5XywbpznpgLkPEYftrftD(skCqmKlg)mpgXrgGeJlXOGyehzaY3dm9LuK77PcblHTTCP8RrOA7Vch8kVmFzHM4idq(nmuUO2W5OY5TqN5HgvzTac)ZbwBtCKbiFNYVgHQT)kCWJ1Mccm9LuK77PcblHTTCHLjsDgneWHkv)skxuB4Cu58wOZ8qJQSwaHFri2erHxhhCjqeVJavVUhlmmtGPVKICFpviyjSTLRRYZ8MuUO2W5OY5TqN5HgvzTakWmBXWUZJDMngPSUaXiKyCooR5XywbpznpgLkPEYfJlXKrmIJma5dm9LuK77PcblHTTCvzKY6cO8Y8LfAIJma53Wq5IAdNJkN3cDMhAuL1ci8phyTnXrgG8Dk)AeQ2(RWb)wgbM(skY99uHGLW2wUQmszDbuUO2W5OY5TqN5HgvzTakWmWmBXywDv3aIHGdqXiLkeJZx2sk4dmZwm5ZsTKymlocre4JHCXCKd74qLkYrMhJ4idq(yOiOyetqmCOIGkX8yqeXLICXuuXOe2IH3cq6JXrqmUfbEY8yy4cm9LuK77jISHZrLZBbLpxf2(9fxBz(YcndhHicOmo3YaBCOIGkX8gIiUuKd)ZbwBtCKbiFNYVgHQT)kCWJLcWNvIiDdhHic0rGQx3N3IqSjIcVUHJqeb6jgKlf52TJJup5GuJ3cq6XsjzgyMTyYNLAjXK)mCcdc(yixmh5WoouPICK5XioYaKpgkckgXeedhQiOsmpgerCPixmfvmkHTy4TaK(yCeeJBrGNmpggUatFjf5(EIiSTLlohvoVfu(Cvy73xCTL5ll0qmCcdcugNBzGnourqLyEdrexkYH)5aRTjoYaKVt5xJq12Ffo4Xsb4Zkb8muu93uHRZWTBhhPEYbPgVfG0JLsYmWmBXKpl1sIj)z4ege8XuuXKVHlbI4SrBQWLRzZFbqXG9(3)VUyQpggUy8lfJcHym54GyYGTyEyrU0hJfOKyixmIjiM8NHtyqqmMvc7bM(skY99eryBlxCoQCElO85QW2VV4AigoHbbkJZTmWwc4zOO64GlbI4Dgo8zLaEgkQ(BQW1z42Tt1Fbqn)F))6Aiq1R7XYmzIprKoIHtyqqhbQEDpwzeyMTyO5Gv52ymlocreig)sXK)mCcdcI5bHHlgourqXiKyukk((zWuNlqml)LatFjf5(EIiSTLRHJqebuUO2e3cN0bfF)myQZfOdNZBHeESbk((zWuNlqQB4iera8jI0nCeIiqNtLXkfNTauEByGFri2erHxhu89ZGPoxGocu96(8Ya)ZbwBtCKbiFNYVgHQT)kCWVHbEKxPgGdoP7P03RdlSp(er6gocreOJavVUNLntxj5joYaKUuQqtiTubbM(skY99eryBlxedNWGaLlQnXTWjDqX3pdM6Cb6W58wiHplGIcwsHdAlIkpPXrQtES2wCnvxX2Zbxc)IqSjIcVoO47NbtDUaDeO6195Hb(er6igoHbbDeO619SSz6kjpXrgG0LsfAcPLkiZaZSfJzXriIaXWWThaoLJXTpjgbvWhJqIH5Hykjg)JXJ55Gv52ymGdqUqqXqrqXiMGyS(lXO0k1y4bkccIXJHQU6nbOatFjf5(EIiSTLlhHyBi4jmOfOmfb1oqrzdJatFjf5(EIiSTLRHJqebuUO2qafcEtoVfWViQ8KghPo57jGQwLG1gg4ZItLXkfNTauEBySBhcu96(82KATVjLkG)5aRTjoYaKVt5xJq12Ffo4XAtbzIplSbk((zWuNlqA3oeO6195Tj1AFtkvGLZa)ZbwBtCKbiFNYVgHQT)kCWJ1McYeFwIJmaPlLk0eslva2HavVUptSybEv)fa18)9)RRHavVUFZmbM(skY99eryBlxocX2qWtyqlqzkcQDGIYggbM(skY99eryBlxdhHicO8Y8LfAIJma53Wq5IAdB4Cu58wO)7lU2Y8LfAgocreapcOqWBY5Ta(frLN04i1jFpbu1QeS2WaFwCQmwP4SfGYBdJD7qGQx3N3MuR9nPub8phyTnXrgG8Dk)AeQ2(RWbpwBkit8zHnqX3pdM6Cbs72HavVUpVnPw7BsPcSCg4FoWABIJma57u(1iuT9xHdES2uqM4ZsCKbiDPuHMqAPcWoeO619zIfgzGx1Fbqn)F))6Aiq1R73mtGz2IrPrL6tUyyhu5GxIHCXOYyLIZcXioYaKpgxIHfSfJsRuJrHMGlgeZD1zedHrIPUyY4JjlgUyesmSigXrgG8zgdbfJc(yYsjSfJ4idq(mdm9LuK77jIW2wUluP(KRjGkh8IYf12ZbwBtCKbipwBzGhbQEDFEzWwwphyTnXrgG8yTPKmXduuWskCqBru5jnosDYJ1glcmZwmSubGlggUyYFgoHbbX4smSGTyixmU1gJ4idq(yYsHMGlgBHRoJySKZig4imgMIXVumhrI5pN7nrKmdm9LuK77jIW2wUigoHbbkxuBydNJkN3c9FFX1qmCcdcWNfqrblPWbTfrLN04i1jpwBSapcOqWBY5TWUDytQ1(6mWNLuQawyyMD7wevEsJJuN8yTLrMzIplovgRuC2cq5THXUDiq1R7ZBtQ1(MuQa(NdS2M4idq(oLFncvB)v4GhRnfKj(SWgO47NbtDUaPD7qGQx3N3MuR9nPubwod8phyTnXrgG8Dk)AeQ2(RWbpwBkit8IJmaPlLk0eslva2HavVUhlwey6lPi33teHTTCrmCcdcuEz(YcnXrgG8ByOCrTHnCoQCEl0)9fxBz(YcnedNWGa8ydNJkN3c9FFX1qmCcdcWduuWskCqBru5jnosDYJ1glWJake8MCElGplovgRuC2cq5THXUDiq1R7ZBtQ1(MuQa(NdS2M4idq(oLFncvB)v4GhRnfKj(SWgO47NbtDUaPD7qGQx3N3MuR9nPubwod8phyTnXrgG8Dk)AeQ2(RWbpwBkit8IJmaPlLk0eslva2HavVUhlweyMTyuAuP(Klg2bvo4Lyixm0ShtrftDXW5xcuRvm(LIPKyuyzTXKiXyH)Jj5QUbeJyYVyukho4iQXKyGyesmSNtUMnSxGPVKICFpre22YDHk1NCnbu5GxuUO2EoWABIJma53WapqrblPWbTfrLN04i1jpwBzT4AQUITNdUe2HrM4rafcEtoVfWJnqX3pdM6Cbs4Xwc4zOO6VPcxNHdVQ)cGA()()11qGQx3Vzg8IJmaPlLk0eslva2HavVUhlwey6lPi33teHTTCFG7RpWmWmBXqlGBftqkgS3skY9bMzlgwldtV429akgYfJcyp)IrPrL6tUyyhu5Gxcm9LuK77VaUvmbPTfQuFY1eqLdEr5IAtClCs)kdtYlUDpG6W58wiH)5aRTjoYaKhRnfGFru5jnosDYJ1glWloYaKUuQqtiTubyhcu96ESW(bMzlgwldtV429akgYfdgSNFXqFo3BIiXK)mCcdccm9LuK77VaUvmbj22YfXWjmiq5IAtClCs)kdtYlUDpG6W58wiHFru5jnosDYJ1glWloYaKUuQqtiTubyhcu96ESW(bMzlgAgEbqumgq(fd2JJZAEmeum5pqHG3umkSetXWZqrbPymlocre4dm9LuK77VaUvmbj22YLJqSne8eg0cuMIGAhOOSHrGPVKICF)fWTIjiX2wUgocreq5L5ll0ehzaYVHHYf1M4w4K(ZWlaIIXa6W58wiHpleO6195Hrg72XPYyLIZwakVnmYeV4idq6sPcnH0sfGDiq1R7XkJaZSfdndVaikgdig2IrPO4Bed5Ibd2ZVyYFGcbVPymlocreigxIrmbXaxkgcvmVaUvmfJqIXaKyuDfJjXGCPixm8afbbXOuu89ZGPoxGatFjf5((lGBftqITTC5ieBdbpHbTaLPiO2bkkByey6lPi33FbCRycsSTLRHJqebuUO2e3cN0FgEbqumgqhoN3cj8IBHt6GIVFgm15c0HZ5TqcVVKch0Gdul43Wappdfv)z4farXyaDeO6195HrxbArlAna]] )

end