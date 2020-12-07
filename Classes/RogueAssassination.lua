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


    spec:RegisterPack( "Assassination", 20201207, [[davVvbqiOuEKOexsLscBcQ6tuuYOefoLOOvHsOxHkzwue3ckvTlP6xQummkkogu0YeL6zOennusDnuPSnOuX3GsLghfLkNtLsP1PsjEhQuPY8ev6EQK9bL8pvkj6GOeyHIkEiQu1erjOlIkvSrkkv9rrjXirLkvDsvkPwju4LOsL0mfLuUPOK0orfgkfLYsvPu9uKAQOIUQkLKARIsQ(kQuPmwvkf7Lu)vkdwXHPAXOQhRIjlYLbBgjFMcJgL60swTkLK8AvQMnLUnjTBL(nIHtIJJkvILd55QA6exhfBhQ8DusgpfPZtr18fvTFH1yQ5utNCb0CKTzY2myMTzWUDmnt2yQPfZvanTIFU7gGMEDvqtZc(3)VwxkYQPvCZTepP5ut)eg0b00Sfr5VLBUXOe2m89dr9MVuzSUuK9GCk5MVup3OP5zkRCRxnVMo5cO5iBZKTzWmBZGD7yAMSnd34MM2ze2eKMMUu5Enn7kLGvZRPtWF00zjgwW)()16sr2yUDIbdeyKLyyHWbu5bumyxtIjBZKTzcmcmYsmzvcoifJzV1naR1LISXKb3BbFFiZyyuIP2yuqfbvI5X8KykjgwrySPywIeJbiXWZGkifdpWU2umVaUvyhJFKISFxtBRxEnNA6xa3kSHKMtnhyQ5utdRZBHKohn9bvcGkxtlUfwPVLbB5f3EhqDyDElKIbFmVcyTnXrgG8XG1vmSmg8XCiQ8KMcPw5JbRRyyDm4JrCKbiDPuHMqAPcIb7JbbQETFmyfd2rt7hPiRM(Gk1NSnbuvGx0IMJS1CQPH15TqsNJM(GkbqLRPf3cR03YGT8IBVdOoSoVfsXGpMdrLN0ui1kFmyDfdRJbFmIJmaPlLk0eslvqmyFmiq1R9JbRyWoAA)ifz10igfHbbArZbl1CQPH15TqsNJMMIGAlyQO5atnTFKISAAfcX2qWtyqhqlAoyTMtnnSoVfs6C00(rkYQPnCeIiGM(GkbqLRPf3cR0FgEbqumgqhwN3cPyWhtgXGavV2pMCJbZSJjF(yuuzSsPylaftUxXGzmzgd(yehzasxkvOjKwQGyW(yqGQx7hdwXKTM(y(XcnXrgG8AoWulAo4MMtnnSoVfs6C00ueuBbtfnhyQP9JuKvtRqi2gcEcd6aArZb2rZPMgwN3cjDoA6dQeavUMwClSs)z4farXyaDyDElKIbFmIBHv6GPVVgm16c0H15Tqkg8X4hPWbnyb1c(yUIbZyWhdpdfv)z4farXyaDeO61(XKBmy2zPM2psrwnTHJqeb0IMdSRMtnnSoVfs6C00hujaQCnT4wyL(ZWlaIIXa6W68wifd(yoevEstHuR8XK7vmSut7hPiRMwLrkRlGw0IMgNV1ZwZPMdm1CQPH15TqsNJMMOOPFq00(rkYQPX5OY5TGMgNBzanDgXGTyqmlqrqgqpbUW2AE7z7jcR(oSoVfsXGpgGIcosHdAhIkpPPqQv(yW6kMJst1nT9kWMIjZyYNpMmIbXSafbza9e4cBR5TNTNiS67W68wifd(yoevEstHuR8XKBmzhtMAACoQTUkOP3YGT8IBVdO2rPDiBQKISArZr2Ao10W68wiPZrtFqLaOY10IBHv6GPVVgm16c0H15Tqkg8XiUfwPVLbB5f3EhqDyDElKIbFm4Cu58wOVLbB5f3EhqTJs7q2ujfzJbFmhcXMiSA7GPVVgm16c0rGQx7htUXGPM2psrwnnoFRNTw0CWsnNAAyDElK05OPpOsau5AAXTWk9TmylV427aQdRZBHum4JbBXiUfwPdM((AWuRlqhwN3cPyWhdohvoVf6BzWwEXT3bu7O0oKnvsr2yWhtc4zOO64GnbI4DgfnTFKISAAC(wpBTO5G1Ao10W68wiPZrt7hPiRMwHqSne8eg0b00GPcYBUkHzfnnR5MMMIGAlyQO5atTO5GBAo10W68wiPZrtFqLaOY10IBHv6pdVaikgdOdRZBHum4J5qi2eHvB3WriIaDgLyWhtgXKis3WriIaDeqHGNTZBHyYNpMeWZqr1XbBceX7mkXGpMer6gocreOROYyLsXwakMCVIbZyYmg8XCiQ8KMcPw57jGQoLedwxXKrmVcyTnXrgG8DkFBeQ29TWbFmyDRmgwhtMXGpgKxPgGdwP7P03RngSIbZS10(rkYQPX5B9S1IMdSJMtnnSoVfs6C00hujaQCnDgXiUfwPR6VaOM)V)FTDyDElKIjF(yqmlqrqgqx1r3BeQMWgAQ(laQ5)7)xBhwN3cPyYmg8XGTysePJyuege0rafcE2oVfIbFmjI0nCeIiqhbQETFmyfdlJbFmjGNHIQJd2eiI3zuIbFmjGNHIQ)SlCDgfnTFKISAAC(wpBTOfnDcOCgRO5uZbMAo10(rkYQPVxN7AAyDElK05OfnhzR5ut7hPiRM(fWTcBnnSoVfs6C0IMdwQ5utdRZBHKohnnrrt)GOP9JuKvtJZrLZBbnno3YaAAybKH5DeyaBmCfJcPEYcPgVfG0hdlgd2nMBIjJyYogwmMxbS2gB)fiMm104CuBDvqtdlGmmVHadyBhIkFTqslAoyTMtnnSoVfs6C00efn9dIM2psrwnnohvoVf004CldOPFfWABIJma57u(2iuT7BHd(yYnMS104CuBDvqt)1AyHM4idq0IMdUP5utdRZBHKohn9bvcGkxtNaEgkQoL1naR1LISDeO61(XKBmzRP9JuKvttzDdWADPiB7ybFFqlAoWoAo10W68wiPZrtFqLaOY10VaUvydPoIyWaAA)ifz10h3AB(rkY2S1lAAB9sBDvqt)c4wHnK0IMdSRMtnnSoVfs6C00hujaQCnDgXGTye3cR0v9xauZ)3)V2oSoVfsXKpFmjI0nCeIiqxQZ9AnIjtnTFKISA6JBTn)ifzB26fnTTEPTUkOPpPxlAom70CQPH15TqsNJM(GkbqLRPFfWABIJma57u(2iuT7BHd(yY9kMmIHBXG9XGywGIGmGEYF21A0(dHztiW2H15TqkMmJbFm8muu93whO5BQLQd0rGQx7htUXqvgSLgcu9A)yWhdcOqWZ25Tqm4J5qu5jnfsTYhdwxXWsnTFKISA63whO5BQLQdOfnh3wnNAAyDElK05OP9JuKvtFCRT5hPiBZwVOPT1lT1vbnDIiArZbMMrZPMgwN3cjDoAA)ifz10h3AB(rkY2S1lAAB9sBDvqtNkeCeTO5atm1CQPH15TqsNJM(GkbqLRPHfqgM3tavDkjgSUIbtUfdxXGZrLZBHoSaYW8gcmGTDiQ81cjnTFKISAAhD8fAcbHGv0IMdmZwZPM2psrwnTJo(cnfg7dAAyDElK05OfnhyYsnNAA)ifz102YGT8TBvmjdvyfnnSoVfs6C0IMdmzTMtnTFKISAAE3OrOAcQo3FnnSoVfs6C0Iw00ki4qu5DrZPMdm1CQP9JuKvt7kkwZBkK6jRMgwN3cjDoArZr2Ao10W68wiPZrt7hPiRMw1r3HuJIGAjWf2A6dQeavUMg5vQb4Gv6Ek99AJbRyWKBAAfeCiQ8U0E4q20RP5Mw0CWsnNAA)ifz10VaUvyRPH15TqsNJw0CWAnNAAyDElK05OP9JuKvt)26anFtTuDan9bvcGkxtJake8SDElOPvqWHOY7s7HdztVMgtTOfnDQqWr0CQ5atnNAAyDElK05OPpOsau5AAGIcosHdAhIkpPPqQv(yW6kgwhdxXiUfwPNaqbqTxqU4gGAhwN3cPyWhtgXKaEgkQooytGiENrjM85Jjb8muu9NDHRZOet(8XalGmmVNaQ6usm5Eft2ClgUIbNJkN3cDybKH5neyaB7qu5RfsXKpFmylgCoQCEl0)AnSqtCKbiXKzm4JjJyWwmIBHv6GPVVgm16c0H15TqkM85J5qi2eHvBhm991GPwxGocu9A)yWkMSJjtnTFKISAAyXblrvlAoYwZPMgwN3cjDoAAIIM(brt7hPiRMgNJkN3cAACULb00hIkpPPqQv(EcOQtjXGvmygt(8XalGmmVNaQ6usm5Eft2ClgUIbNJkN3cDybKH5neyaB7qu5RfsXKpFmylgCoQCEl0)AnSqtCKbiAACoQTUkOPzEOrvwlG0IMdwQ5utdRZBHKohnTFKISA6hqixGuJNSq7vQ7GM(GkbqLRP5zOO6VToqZ3ulvhOZOed(yWwmjI0FaHCbsnEYcTxPUdTer6sDUxRrm5ZhdvzWwAiq1R9Jj3Ry4wm5ZhZHqSjcR2(diKlqQXtwO9k1DOFy7id4Bui)ifzDBmyDft2DSl3IjF(yEcJLV2u3cEQXBEdm1vvSqhwN3cPyWhd2IHNHIQBbp14nVbM6QkwOZOOPpMFSqtCKbiVMdm1IMdwR5utdRZBHKohn9bvcGkxtJZrLZBHoZdnQYAbum4JjJy4zOO6SRuc2gV1tW3FXp3JbRRyW82gt(8XKrmylgfurqLyEdrexkYgd(yEfWABIJma57u(2iuT7BHd(yW6kgwhdxX8c4wHnK6iIbdetMXKPM2psrwnnLVncv7(w4GxlAo4MMtnnSoVfs6C00(rkYQPP8TrOA33ch8A6dQeavUMgNJkN3cDMhAuL1cOyWhZRawBtCKbiFNY3gHQDFlCWhdwxXWsn9X8JfAIJma51CGPw0CGD0CQPH15TqsNJM(GkbqLRPX5OY5TqN5HgvzTakg8XCieBIWQTJd2eiI3rGQx7hdwXGPz00(rkYQPHdBsTgneOGkvFtArZb2vZPMgwN3cjDoA6dQeavUMgNJkN3cDMhAuL1cinTFKISAAxLN5zRfnhMDAo10W68wiPZrt7hPiRMwLrkRlGM(GkbqLRPX5OY5TqN5HgvzTakg8X8kG12ehzaY3P8TrOA33ch8XCft2A6J5hl0ehzaYR5atTO542Q5utdRZBHKohn9bvcGkxtJZrLZBHoZdnQYAbKM2psrwnTkJuwxaTOfn9j9Ao1CGPMtnTFKISAAkRBawRlfz10W68wiPZrlAoYwZPMgwN3cjDoAA)ifz10Qo6oKAueulbUWwtFqLaOY10iVsnahSs3tPVZOed(yYigXrgG0LsfAcPLkiMCJ5qu5jnfsTY3tavDkjgwmgm7ClM85J5qu5jnfsTY3tavDkjgSUI5O0uDtBVcSPyYutFm)yHM4idqEnhyQfnhSuZPMgwN3cjDoA6dQeavUMg5vQb4Gv6Ek99AJbRyyPzIb7Jb5vQb4Gv6Ek99edYLISXGpMdrLN0ui1kFpbu1PKyW6kMJst1nT9kWM00(rkYQPvD0Di1OiOwcCHTw0CWAnNAAyDElK05OPjkA6henTFKISAACoQCElOPX5wgqtJTye3cR03YGT8IBVdOoSoVfsXKpFmylgXTWkDW03xdMADb6W68wift(8XCieBIWQTdM((AWuRlqhbQETFm5gd3Ib7Jj7yyXye3cR0taOaO2lixCdqTdRZBHKMgNJARRcAACWMar82wgSLxC7Da1oKnvsrwTO5GBAo10W68wiPZrtFqLaOY10ylMxa3kSHuhrmyGyWhtIiDeJIWGGUuN71Aed(yWwmjGNHIQJd2eiI3zuIbFm4Cu58wOJd2eiI32YGT8IBVdO2HSPskYQP9JuKvtJd2eiIRfnhyhnNAAyDElK05OPpOsau5AASfZlGBf2qQJigmqm4JjJyWwmjI0nCeIiqhbui4z78wig8XKishXOimiOJavV2pgSIH1XWvmSogwmMJst1nT9kWMIjF(ysePJyuege0rGQx7hdlgJz6ClgSIrCKbiDPuHMqAPcIjZyWhJ4idq6sPcnH0sfedwXWAnTFKISAAW03xdMADb0IMdSRMtnnSoVfs6C00hujaQCnDIiDeJIWGGUuN71Aet(8XKis)bLV(UuN71AOP9JuKvt)SlCArZHzNMtnnSoVfs6C00hujaQCnnpdfvN3sijlZlDe4hjM85JHQmylneO61(XKBmS0mXKpFmjGNHIQJd2eiI3zu00(rkYQPvisrwTO542Q5utdRZBHKohn9bvcGkxtNaEgkQooytGiENrrt7hPiRMM3siPgfdYCTO5atZO5utdRZBHKohn9bvcGkxtNaEgkQooytGiENrrt7hPiRMMhqpGUxRHw0CGjMAo10W68wiPZrtFqLaOY10jGNHIQJd2eiI3zu00(rkYQPPkeWBjKKw0CGz2Ao10W68wiPZrtFqLaOY10jGNHIQJd2eiI3zu00(rkYQP99aVGCB74wRw0CGjl1CQPH15TqsNJM(GkbqLRPXwmVaUvydPUBTXGpgv)fa18)9)RTHavV2pMRymJM2psrwn9XT2MFKISnB9IM2wV0wxf0048TE2ArZbMSwZPMgwN3cjDoAA)ifz10gwpvUqqFtfsU1wKvtFqLaOY10jGNHIQJd2eiI3zu00affCK26QGM2W6PYfc6BQqYT2ISArZbMCtZPMgwN3cjDoAA)ifz10gwpvUqqFJ3tgGM(GkbqLRPtapdfvhhSjqeVZOOPbkk4iT1vbnTH1tLle0349KbOfnhyID0CQP9JuKvtZ8qReq910W68wiPZrlArtNiIMtnhyQ5utdRZBHKohnnrrt)GOP9JuKvtJZrLZBbnno3YaAAfurqLyEdrexkYgd(yEfWABIJma57u(2iuT7BHd(yWkgwgd(yYiMer6gocreOJavV2pMCJ5qi2eHvB3WriIa9edYLISXKpFmkK6jlKA8wasFmyfd3Ijtnnoh1wxf00)9sPDm)yHMHJqeb0IMJS1CQPH15TqsNJMMOOPFq00(rkYQPX5OY5TGMgNBzanTcQiOsmVHiIlfzJbFmVcyTnXrgG8DkFBeQ29TWbFmyfdlJbFmzetc4zOO6p7cxNrjM85JrHupzHuJ3cq6JbRy4wmzQPX5O26QGM(VxkTJ5hl0qmkcdc0IMdwQ5utdRZBHKohnnrrt)GOP9JuKvtJZrLZBbnno3YaA6eWZqr1XbBceX7mkXGpMmIjb8muu9NDHRZOet(8XO6VaOM)V)FTneO61(XGvmMjMmJbFmjI0rmkcdc6iq1R9JbRyYwtJZrT1vbn9FVuAigfHbbArZbR1CQPH15TqsNJM(GkbqLRPf3cR0btFFnyQ1fOdRZBHum4JbBXKaEgkQUHJqeb6GPVVgm16cKIbFmjI0nCeIiqxrLXkLITaum5EfdMXGpMdHytewTDW03xdMADb6iq1R9Jj3yYog8X8kG12ehzaY3P8TrOA33ch8XCfdMXGpgKxPgGdwP7P03RngSIb7ed(ysePB4ierGocu9A)yyXymtNBXKBmIJmaPlLk0eslvGM2psrwnTHJqeb0IMdUP5utdRZBHKohn9bvcGkxtlUfwPdM((AWuRlqhwN3cPyWhtgXauuWrkCq7qu5jnfsTYhdwxXCuAQUPTxb2um4J5qi2eHvBhm991GPwxGocu9A)yYngmJbFmjI0rmkcdc6iq1R9JHfJXmDUftUXioYaKUuQqtiTubXKPM2psrwnnIrryqGw0CGD0CQPH15TqsNJMMIGAlyQO5atnTFKISAAfcX2qWtyqhqlAoWUAo10W68wiPZrtFqLaOY10iGcbpBN3cXGpMdrLN0ui1kFpbu1PKyW6kgmJbFmzeJIkJvkfBbOyY9kgmJjF(yqGQx7htUxXi15Etkvig8X8kG12ehzaY3P8TrOA33ch8XG1vmSmMmJbFmzed2Ibm991GPwxGum5Zhdcu9A)yY9kgPo3BsPcXWIXKDm4J5vaRTjoYaKVt5BJq1UVfo4JbRRyyzmzgd(yYigXrgG0LsfAcPLkigSpgeO61(XKzmyfdRJbFmQ(laQ5)7)xBdbQETFmxXygnTFKISAAdhHicOfnhMDAo10W68wiPZrttrqTfmv0CGPM2psrwnTcHyBi4jmOdOfnh3wnNAAyDElK05OP9JuKvtB4ieran9bvcGkxtJTyW5OY5Tq)VxkTJ5hl0mCeIiqm4Jbbui4z78wig8XCiQ8KMcPw57jGQoLedwxXGzm4JjJyuuzSsPylaftUxXGzm5Zhdcu9A)yY9kgPo3BsPcXGpMxbS2M4idq(oLVncv7(w4GpgSUIHLXKzm4JjJyWwmGPVVgm16cKIjF(yqGQx7htUxXi15EtkvigwmMSJbFmVcyTnXrgG8DkFBeQ29TWbFmyDfdlJjZyWhtgXioYaKUuQqtiTubXG9XGavV2pMmJbRyWm7yWhJQ)cGA()()12qGQx7hZvmMrtFm)yHM4idqEnhyQfnhyAgnNAAyDElK05OPpOsau5A6xbS2M4idq(yW6kMSJbFmiq1R9Jj3yYogUIjJyEfWABIJma5JbRRy4wmzgd(yakk4ifoODiQ8KMcPw5JbRRyyTM2psrwn9bvQpzBcOQaVOfnhyIPMtnnSoVfs6C00hujaQCnn2IbNJkN3c9)EP0qmkcdcIbFmzedqrbhPWbTdrLN0ui1kFmyDfdRJbFmiGcbpBN3cXKpFmylgPo3R1ig8XKrmsPcXGvmyAMyYNpMdrLN0ui1kFmyDft2XKzmzgd(yYigfvgRuk2cqXK7vmygt(8XGavV2pMCVIrQZ9MuQqm4J5vaRTjoYaKVt5BJq1UVfo4JbRRyyzmzgd(yYigSfdy67RbtTUaPyYNpgeO61(XK7vmsDU3KsfIHfJj7yWhZRawBtCKbiFNY3gHQDFlCWhdwxXWYyYmg8XioYaKUuQqtiTubXG9XGavV2pgSIH1AA)ifz10igfHbbArZbMzR5utdRZBHKohnTFKISAAeJIWGan9bvcGkxtJTyW5OY5Tq)VxkTJ5hl0qmkcdcIbFmylgCoQCEl0)7LsdXOimiig8XauuWrkCq7qu5jnfsTYhdwxXW6yWhdcOqWZ25Tqm4JjJyuuzSsPylaftUxXGzm5Zhdcu9A)yY9kgPo3BsPcXGpMxbS2M4idq(oLVncv7(w4GpgSUIHLXKzm4JjJyWwmGPVVgm16cKIjF(yqGQx7htUxXi15EtkvigwmMSJbFmVcyTnXrgG8DkFBeQ29TWbFmyDfdlJjZyWhJ4idq6sPcnH0sfed2hdcu9A)yWkgwRPpMFSqtCKbiVMdm1IMdmzPMtnnSoVfs6C00hujaQCn9RawBtCKbiFmxXGzm4JbOOGJu4G2HOYtAkKALpgSUIjJyoknv302RaBkgSpgmJjZyWhdcOqWZ25Tqm4JbBXaM((AWuRlqkg8XGTysapdfv)zx46mkXGpgv)fa18)9)RTHavV2pMRymtm4JrCKbiDPuHMqAPcIb7JbbQETFmyfdR10(rkYQPpOs9jBtavf4fTO5atwR5ut7hPiRM(bLVEnnSoVfs6C0Iw0IMghG(ISAoY2mzBgmZ2myhnnRC0wRXRP5UXcUDoU1CKvULyIHt2qmLQcbjXqrqXyw48TE2MvmiG7ctHGumprfIXzeIQlqkMdBFnGVhyK1QfIbZBjgUNS4aKaPymleZcueKb0VnMvmcjgZcXSafbza9BthwN3cjZkMmY20m7bgzTAHyWo3smCpzXbibsXywiMfOiidOFBmRyesmMfIzbkcYa63MoSoVfsMvmzGPPz2dmcm4UXcUDoU1CKvULyIHt2qmLQcbjXqrqXywjGYzSIzfdc4UWuiifZtuHyCgHO6cKI5W2xd47bgzTAHyy5Ted3twCasGum0Lk3hZB(kUPXCRigHetwJXJjv4QViBmefa5cbftg3KzmzGPPz2dmYA1cXy2DlXW9KfhGeifJzHywGIGmG(TXSIriXywiMfOiidOFB6W68wizwXKbMMMzpWiWG7gl4254wZrw5wIjgozdXuQkeKedfbfJzLiIzfdc4UWuiifZtuHyCgHO6cKI5W2xd47bgzTAHyy9Ted3twCasGumMfy67RbtTUaP(TXSIriXywjGNHIQFB6GPVVgm16cKmRyYattZShyeyCRvviibsXGDJXpsr2yS1lFpWqtRGiuLf00zjgwW)()16sr2yUDIbdeyKLyyHWbu5bumyxtIjBZKTzcmcmYsmzvcoifJzV1naR1LISXKb3BbFFiZyyuIP2yuqfbvI5X8KykjgwrySPywIeJbiXWZGkifdpWU2umVaUvyhJFKISFpWiWilXWDmfomcKIHhOiiiMdrL3Ly4bJA)EmSGZbuKpMLSypBhPsXyJXpsr2pgYAnVhy4hPi73vqWHOY7YLROynVPqQNSbg(rkY(DfeCiQ8UW11nQo6oKAueulbUW2efeCiQ8U0E4q20FXntkQlKxPgGdwP7P03Rflm5wGHFKISFxbbhIkVlCDDZlGBf2bg(rkY(DfeCiQ8UW11nVToqZ3ulvhWefeCiQ8U0E4q20FHPjf1fcOqWZ25TqGrGrwIH7ykCyeifdGdqMhJuQqmcBig)ieum1hJJZlRZBHEGHFKIS)196CpWilXC7WlGBf2XuuXOq(V4TqmzSKyWXyxa58wigyb1c(yQnMdrL3Lmdm8JuK9566Mxa3kSdm8JuK9566gCoQCElyY6QWfSaYW8gcmGTDiQ81cjtW5wg4cwazyEhbgWYLcPEYcPgVfG0ZIy3BfzKnl(kG12y7Vazgy4hPi7Z11n4Cu58wWK1vHRVwdl0ehzaIj4CldC9kG12ehzaY3P8TrOA33ch85MDGHFKISpxx3qzDdWADPiB7ybFFWKI6kb8muuDkRBawRlfz7iq1R9Zn7ad)ifzFUUU54wBZpsr2MTEXK1vHRxa3kSHKjf11lGBf2qQJigmqGHFKISpxx3CCRT5hPiBZwVyY6QW1j9MuuxzGnXTWkDv)fa18)9)RTdRZBHu(8jI0nCeIiqxQZ9AnYmWWpsr2NRRBEBDGMVPwQoGjf11RawBtCKbiFNY3gHQDFlCWN7vgCd7rmlqrqgqp5p7AnA)HWSjeyZeppdfv)T1bA(MAP6aDeO61(5svgSLgcu9AF8iGcbpBN3c4pevEstHuR8yDXYad)ifzFUUU54wBZpsr2MTEXK1vHRercm8JuK9566MJBTn)ifzB26ftwxfUsfcosGHFKISpxx34OJVqtiieSIjf1fSaYW8EcOQtjyDHj34cNJkN3cDybKH5neyaB7qu5Rfsbg(rkY(CDDJJo(cnfg7dbg(rkY(CDDJTmylF7wftYqfwjWWpsr2NRRB4DJgHQjO6C)dmcmYsmCpHytewTFGHFKISF)K(lkRBawRlfzdmYsm3AQy8u6JXrqmmkMeZVLceJWgIHSqmSQe2XyjScEjgo5Kf2J5w9dXWk2WgtY8AnIHYFbqXiS9ngU3SftcOQtjXqqXWQsytyKy818y4EZwpWWpsr2VFspxx3O6O7qQrrqTe4cBtoMFSqtCKbi)fMMuuxiVsnahSs3tPVZOGpdXrgG0LsfAcPLki3drLN0ui1kFpbu1PeweZo3YN)qu5jnfsTY3tavDkbRRJst1nT9kWMYmWilXCRPIzjX4P0hdRkRnMubXWQsyxBmcBiMfmvIHLM5njgMhIjRsXcJHSXWt(pgwvcBcJeJVMhd3B26bg(rkY(9t6566gvhDhsnkcQLaxyBsrDH8k1aCWkDpL(ETyXsZG9iVsnahSs3tPVNyqUuKf)HOYtAkKALVNaQ6ucwxhLMQBA7vGnfyKLyY6WMar8ySeJ642yoKnvsrw3(XW7pKIHSXCyqiyLyEf4ey4hPi73pPNRRBW5OY5TGjRRcx4GnbI4TTmylV427aQDiBQKISMGZTmWf2e3cR03YGT8IBVdOoSoVfs5ZJnXTWkDW03xdMADb6W68wiLp)HqSjcR2oy67RbtTUaDeO61(5YnSpBwuClSspbGcGAVGCXna1oSoVfsbg(rkY(9t6566gCWMarCtkQlS9c4wHnK6iIbdGprKoIrryqqxQZ9AnWJTeWZqr1XbBceX7mk4X5OY5TqhhSjqeVTLbB5f3EhqTdztLuKnWilXWDm991GPwxGyyfByJzjsmVaUvydPy8nfdpryhZTZOimiigFtXKvCeIiqmocIHrjgkckglznIbwcJb7EGHFKISF)KEUUUbm991GPwxatkQlS9c4wHnK6iIbdGpdSLis3WriIaDeqHGNTZBb8jI0rmkcdc6iq1R9XI1CXAw8O0uDtBVcSP85tePJyuege0rGQx7ZIMPZnSehzasxkvOjKwQGmXloYaKUuQqtiTubyX6ad)ifz)(j9CDDZZUWzsrDLishXOimiOl15ETg5ZNis)bLV(UuN71Aey4hPi73pPNRRBuisrwtkQlEgkQoVLqswMx6iWps(8uLbBPHavV2pxwAM85tapdfvhhSjqeVZOey4hPi73pPNRRB4TesQrXGm3KI6kb8muuDCWMar8oJsGHFKISF)KEUUUHhqpGUxRHjf1vc4zOO64GnbI4DgLad)ifz)(j9CDDdvHaElHKmPOUsapdfvhhSjqeVZOey4hPi73pPNRRB89aVGCB74wRjf1vc4zOO64GnbI4DgLad)ifz)(j9CDDZXT2MFKISnB9IjRRcx48TE2Muuxy7fWTcBi1DRfVQ)cGA()()12qGQx7FzMad)ifz)(j9CDDdZdTsavtakk4iT1vHldRNkxiOVPcj3AlYAsrDLaEgkQooytGiENrjWWpsr2VFspxx3W8qReq1eGIcosBDv4YW6PYfc6B8EYamPOUsapdfvhhSjqeVZOeyKLyyHaLZyLyOCRL3p3JHIGIH5DEletjG6FlXCR(HyiBmhcXMiSA7bg(rkY(9t6566gMhALaQFGrGrwIHfwi4iXKCv3aIX5lBjf8bgzjgUZIdwIAmUedR5kMm4gxXWQsyhdlKoZy4EZwpMBTQkKkxaR5Xq2yYMRyehzaYBsmSQe2XK1HnbI4MedbfdRkHDmCMd3DXqe2aIv1dXWkVKyOiOyEIkedSaYW8EmSa7tIHvEjXuuXWDm9nI5qu5jXuFmhIATgXWO0dm8JuK97Pcbh5cwCWsunPOUakk4ifoODiQ8KMcPw5X6I1CjUfwPNaqbqTxqU4gGAhwN3cj8zKaEgkQooytGiENrjF(eWZqr1F2fUoJs(8WcidZ7jGQoLK7v2CJlCoQCEl0HfqgM3qGbSTdrLVwiLpp2W5OY5Tq)R1WcnXrgGKj(mWM4wyLoy67RbtTUaDyDElKYN)qi2eHvBhm991GPwxGocu9AFSYoZad)ifz)EQqWr466gCoQCElyY6QWfZdnQYAbKj4CldCDiQ8KMcPw57jGQoLGfM5ZdlGmmVNaQ6usUxzZnUW5OY5TqhwazyEdbgW2oev(AHu(8ydNJkN3c9Vwdl0ehzasGHFKISFpvi4iCDDZdiKlqQXtwO9k1DWKJ5hl0ehzaYFHPjf1fpdfv)T1bA(MAP6aDgf8ylrK(diKlqQXtwO9k1DOLisxQZ9AnYNNQmylneO61(5EXT85peInry12FaHCbsnEYcTxPUd9dBhzaFJc5hPiRBX6k7o2LB5Z)eglFTPUf8uJ38gyQRQyHoSoVfs4Xgpdfv3cEQXBEdm1vvSqNrjWilXy27BmeQy4UUfo4JXLyW82YvmV4N7FmeQy4UVsjyJjhRNGpgckg3WR9LyynxXioYaKVhy4hPi73tfcocxx3q5BJq1UVfo4nPOUW5OY5TqN5HgvzTacFg8muuD2vkbBJ36j47V4N7yDH5TnF(mWMcQiOsmVHiIlfzX)kG12ehzaY3P8TrOA33ch8yDXAUEbCRWgsDeXGbYmZaJSeJzVVXqOIH76w4GpgHeJROynpgwi4jR5Xy2i1t2ykQyQ1psHdIHSX4R5XioYaKyCjgwgJ4idq(EGHFKISFpvi4iCDDdLVncv7(w4G3KJ5hl0ehzaYFHPjf1fohvoVf6mp0OkRfq4FfWABIJma57u(2iuT7BHdESUyzGHFKISFpvi4iCDDdCytQ1OHafuP6BYKI6cNJkN3cDMhAuL1ci8hcXMiSA74GnbI4DeO61(yHPzcm8JuK97PcbhHRRBCvEMNTjf1fohvoVf6mp0OkRfqbgzjgoDESpRYiL1figHeJROynpgwi4jR5Xy2i1t2yCjMSJrCKbiFGHFKISFpvi4iCDDJkJuwxatoMFSqtCKbi)fMMuux4Cu58wOZ8qJQSwaH)vaRTjoYaKVt5BJq1UVfo4VYoWWpsr2VNkeCeUUUrLrkRlGjf1fohvoVf6mp0OkRfqbgbgzjgwOR6gqmeCakgPuHyC(YwsbFGrwIjRvQLetwXriIaFmKnMLSyVcQuroY8yehzaYhdfbfJWgIrbveujMhdIiUuKnMIkgUXvm8wasFmocIXTiWtMhdJsGHFKISFprKlCoQCElyY6QW1FVuAhZpwOz4ieratW5wg4sbveujM3qeXLIS4FfWABIJma57u(2iuT7BHdESyj(msePB4ierGocu9A)CpeInry12nCeIiqpXGCPiB(8kK6jlKA8waspwClZaJSetwRuljMBNrryqWhdzJzjl2RGkvKJmpgXrgG8XqrqXiSHyuqfbvI5XGiIlfzJPOIHBCfdVfG0hJJGyClc8K5XWOey4hPi73teHRRBW5OY5TGjRRcx)9sPDm)yHgIrryqGj4CldCPGkcQeZBiI4srw8VcyTnXrgG8DkFBeQ29TWbpwSeFgjGNHIQ)SlCDgL85vi1twi14TaKES4wMbgzjMSwPwsm3oJIWGGpMIkMSoSjqeNlA2fUBYQ(lakgwW)()1gt9XWOeJVPyyfedBhhet2CfZdhYM(ySaLedzJrydXC7mkcdcIHfs4mWWpsr2VNicxx3GZrLZBbtwxfU(7LsdXOimiWeCULbUsapdfvhhSjqeVZOGpJeWZqr1F2fUoJs(8Q(laQ5)7)xBdbQETpwMjt8jI0rmkcdc6iq1R9Xk7aJSedTcCk3gtwXriIaX4BkMBNrryqqmpimkXOGkckgHed3X03xdMADbI54Vey4hPi73teHRRBmCeIiGjf1L4wyLoy67RbtTUaDyDElKWJnW03xdMADbsDdhHicGprKUHJqeb6kQmwPuSfGY9ct8hcXMiSA7GPVVgm16c0rGQx7NB24FfWABIJma57u(2iuT7BHd(lmXJ8k1aCWkDpL(ETyHDWNis3WriIaDeO61(SOz6ClxXrgG0LsfAcPLkiWWpsr2VNicxx3GyuegeysrDjUfwPdM((AWuRlqhwN3cj8zauuWrkCq7qu5jnfsTYJ11rPP6M2Efyt4peInry12btFFnyQ1fOJavV2pxmXNishXOimiOJavV2NfntNB5koYaKUuQqtiTubzgyKLyYkocreiggL7aOysmU9jXiOc(yesmmpetjX4FmEmVcCk3gJbSaYfckgkckgHneJ1FjgU3SfdpqrqqmEmu1wpBafy4hPi73teHRRBuieBdbpHbDatOiO2cMkxygy4hPi73teHRRBmCeIiGjf1fcOqWZ25Ta(drLN0ui1kFpbu1PeSUWeFgkQmwPuSfGY9cZ85rGQx7N7LuN7nPub8VcyTnXrgG8DkFBeQ29TWbpwxSmt8zGnW03xdMADbs5ZJavV2p3lPo3BsPcSy24FfWABIJma57u(2iuT7BHdESUyzM4ZqCKbiDPuHMqAPcWEeO61(zIfRXR6VaOM)V)FTneO61(xMjWWpsr2VNicxx3Oqi2gcEcd6aMqrqTfmvUWmWWpsr2VNicxx3y4ieratoMFSqtCKbi)fMMuuxydNJkN3c9)EP0oMFSqZWriIa4rafcE2oVfWFiQ8KMcPw57jGQoLG1fM4ZqrLXkLITauUxyMppcu9A)CVK6CVjLkG)vaRTjoYaKVt5BJq1UVfo4X6ILzIpdSbM((AWuRlqkFEeO61(5Ej15EtkvGfZg)RawBtCKbiFNY3gHQDFlCWJ1flZeFgIJmaPlLk0eslva2JavV2ptSWmB8Q(laQ5)7)xBdbQET)LzcmYsmCpQuFYgdNGQc8smKngvgRukwigXrgG8X4smSMRy4EZwmSInSXGy2TwJyimsm1gt2FmzWOeJqIH1XioYaKpZyiOyy5htgCJRyehzaYNzGHFKISFpreUUU5Gk1NSnbuvGxmPOUEfWABIJma5X6kB8iq1R9ZnBUY4vaRTjoYaKhRlULjEGIcosHdAhIkpPPqQvESUyDGrwIH7kakXWOeZTZOimiigxIH1CfdzJXT2yehzaYhtgSInSXylC1AeJLSgXalHXGDm(MIzjsm)6kpBIKzGHFKISFpreUUUbXOimiWKI6cB4Cu58wO)3lLgIrryqa(makk4ifoODiQ8KMcPw5X6I14rafcE2oVfYNhBsDUxRb(mKsfWctZKp)HOYtAkKALhRRSZmt8zOOYyLsXwak3lmZNhbQETFUxsDU3KsfW)kG12ehzaY3P8TrOA33ch8yDXYmXNb2atFFnyQ1fiLppcu9A)CVK6CVjLkWIzJ)vaRTjoYaKVt5BJq1UVfo4X6ILzIxCKbiDPuHMqAPcWEeO61(yX6ad)ifz)EIiCDDdIrryqGjhZpwOjoYaK)cttkQlSHZrLZBH(FVuAhZpwOHyuegeGhB4Cu58wO)3lLgIrryqaEGIcosHdAhIkpPPqQvESUynEeqHGNTZBb8zOOYyLsXwak3lmZNhbQETFUxsDU3KsfW)kG12ehzaY3P8TrOA33ch8yDXYmXNb2atFFnyQ1fiLppcu9A)CVK6CVjLkWIzJ)vaRTjoYaKVt5BJq1UVfo4X6ILzIxCKbiDPuHMqAPcWEeO61(yX6aJSed3Jk1NSXWjOQaVedzJHMZykQyQngfFtGADIX3umLedRkRnMejgl8Fmjx1nGye2(gd3zXblrnMedeJqIHZCUjRYccm8JuK97jIW11nhuP(KTjGQc8Ijf11RawBtCKbi)fM4bkk4ifoODiQ8KMcPw5X6kJJst1nT9kWMWEmZepcOqWZ25TaESbM((AWuRlqcp2sapdfv)zx46mk4v9xauZ)3)V2gcu9A)lZGxCKbiDPuHMqAPcWEeO61(yX6ad)ifz)EIiCDDZdkF9bgbgzjgAbCRWgsXWcosr2pWilXWrzW(f3EhqXq2yyjN3smCpQuFYgdNGQc8sGHFKISF)fWTcBiDDqL6t2MaQkWlMuuxIBHv6BzWwEXT3buhwN3cj8VcyTnXrgG8yDXs8hIkpPPqQvESUynEXrgG0LsfAcPLka7rGQx7Jf2jWilXWrzW(f3EhqXq2yWKZBjg61vE2ejMBNrryqqGHFKISF)fWTcBiX11nigfHbbMuuxIBHv6BzWwEXT3buhwN3cj8hIkpPPqQvESUynEXrgG0LsfAcPLka7rGQx7Jf2jWilXqZWlaIIXaULyybkkwZJHGI52bke8SJHvLWogEgkkiftwXriIaFGHFKISF)fWTcBiX11nkeITHGNWGoGjueuBbtLlmdm8JuK97VaUvydjUUUXWriIaMCm)yHM4idq(lmnPOUe3cR0FgEbqumgqhwN3cj8zGavV2pxmZoFEfvgRuk2cq5EHzM4fhzasxkvOjKwQaShbQETpwzhyKLyOz4farXyaXWvmChtFJyiBmyY5TeZTdui4zhtwXriIaX4smcBigytXqOI5fWTc7yesmgGeJQBAmjgKlfzJHhOiiigUJPVVgm16cey4hPi73FbCRWgsCDDJcHyBi4jmOdycfb1wWu5cZad)ifz)(lGBf2qIRRBmCeIiGjf1L4wyL(ZWlaIIXa6W68wiHxClSshm991GPwxGoSoVfs49Ju4GgSGAb)fM45zOO6pdVaikgdOJavV2pxm7SmWWpsr2V)c4wHnK466gvgPSUaMuuxIBHv6pdVaikgdOdRZBHe(drLN0ui1kFUxSmWiWilXK19TE2bgzjgZ(ARNDmSQe2XO6Mgd3B2IHIGIHJYGT8IBVditIHzTW)XW81AedleCHT18yOz7jcR(ad)ifz)ooFRN9fohvoVfmzDv4Ald2YlU9oGAhL2HSPskYAco3YaxzGneZcueKb0tGlSTM3E2EIWQhpqrbhPWbTdrLN0ui1kpwxhLMQBA7vGnLz(8zGywGIGmGEcCHT182Z2tew94pevEstHuR85MDMbgzjMSUV1Zogwvc7y4oM(gXWvmCugSLxC7DaDlXKvDtlvg1y4EZwm(MIH7y6Bedc8K5XqrqXSGPsmzfUNfgy4hPi73X5B9S566gC(wpBtkQlXTWkDW03xdMADb6W68wiHxClSsFld2YlU9oG6W68wiHhNJkN3c9TmylV427aQDuAhYMkPil(dHytewTDW03xdMADb6iq1R9ZfZaJSetw336zhdRkHDmCugSLxC7DafdxXWbjgUJPVXTetw1nTuzuJH7nBX4BkMSoSjqepggLad)ifz)ooFRNnxx3GZ36zBsrDjUfwPVLbB5f3EhqDyDElKWJnXTWkDW03xdMADb6W68wiHhNJkN3c9TmylV427aQDuAhYMkPil(eWZqr1XbBceX7mkbg(rkY(DC(wpBUUUrHqSne8eg0bmHIGAlyQCHPjGPcYBUkHzLlwZTad)ifz)ooFRNnxx3GZ36zBsrDjUfwP)m8cGOymGoSoVfs4peInry12nCeIiqNrbFgjI0nCeIiqhbui4z78wiF(eWZqr1XbBceX7mk4tePB4ierGUIkJvkfBbOCVWmt8hIkpPPqQv(EcOQtjyDLXRawBtCKbiFNY3gHQDFlCWJ1TswNjEKxPgGdwP7P03RflmZoWilXK19TE2XWQsyhtw1FbqXWc(3)AVLy4GeZlGBf2X4BkMLeJFKchetwLfedpdfLjXC7mkcdcIzjsm1gdcOqWZogKVgGjXKyq1Aetwh2eiIZfN5ey4hPi73X5B9S566gC(wpBtkQRme3cR0v9xauZ)3)V2oSoVfs5ZJywGIGmGUQJU3iunHn0u9xauZ)3)V2mXJTer6igfHbbDeqHGNTZBb8jI0nCeIiqhbQETpwSeFc4zOO64GnbI4Dgf8jGNHIQ)SlCDgfn9RahnhzZTBRw0Iwd]] )

end