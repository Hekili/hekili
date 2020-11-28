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

        -- Rogue - Venthyr   - 323654 - flagellation        (Flagellation)
        --                     345569 - flagellation        (Get Mastery Buff)
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
            id = 345569,
            cast = 0,
            cooldown = 5,
            gcd = "off",

            startsCombat = true,
            texture = 3565724,

            toggle = "essences",

            bind = "flagellation",

            usable = function () return IsActiveSpell( 345569 ), "flagellation_cleanse not active" end,

            handler = function ()
                if buff.flagellation_buff.down then
                    stat.haste = stat.haste + ( 0.005 * buff.flagellation.stack )
                end

                removeBuff( "flagellation" )
                removeDebuff( "target", "flagellation" )
                active_dot.flagellation = 0
                applyBuff( "flagellation_buff" )
                setCooldown( "flagellation", 5 )
            end,

            auras = {
                flagellation_buff = {
                    id = 345569,
                    duration = 20,
                    max_stack = 1,
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


    spec:RegisterPack( "Assassination", 20201128, [[daLQqbqiOuEKuqxIKqvBcQ6tkQKgLuItjfzvKe8kukZIKYTuuv7sQ(LuudJKQoguyzuv1ZqjmnuIUgjrBtrv6BsbQXrsiNtrfSoOuP3rsOsZtkP7Pi7dk6FkQqCqOuLfkf6HkQOjkfqxekv1gvuPIpkfiJKKqfNekvyLqjVurLQMjuQOBQOsStusdvkalvrv8uenvuQUQIkvARkQu(QIkunwfviTxs9xHgSshMYIrvpwHjl4YGnJWNPkJMQYPLSAfvO8AfLztLBtIDRYVrA4OYXjjuwoKNRQPtCDuSDOY3jPY4jjDEQQmFPu7x0Am0SRjdMaAw9x9(REmWWFvuhJ5v9QiwWsnP4hhOj5SXmZd0KNPaAsS3)2)1zsrpnjN5NJAbn7AYNYGgGM0NiCp2T5M9kXhdFFqvA(lfgNjf9giJqA(lLrZAsEMYjyhNMxtgmb0S6V69x9yGH)QOogZR6vrSadnPXi(OinjzPmNAsFviaNMxtgGFOjByUyV)T)RZKIE5opupgiXQH5YkfhOWdOC9xfPwU(RE)vVM0vV8A21KVaMt8bbn7AwXqZUMeoJ3bbDJAYbQeavMMumhCs)kpFYlMBgG6Wz8oiKl(CFoW5IIH8a5ZfZPCzrU4ZDqv4ProADYNlMt5YYCXNRyipq6sParHgdfK78ZfbkwDFUyM78QjTHu0ttoqLYtVOakCWlArZQ)A21KWz8oiOButoqLaOY0KI5Gt6x55tEXCZauhoJ3bHCXN7GQWtJC06KpxmNYLL5IpxXqEG0LsbIcngki35NlcuS6(CXm35vtAdPONMeXWjmiqlAwzHMDnjCgVdc6g1Keuu8avfnRyOjTHu0ttYrPUicEkdAaArZkl1SRjHZ4Dqq3OM0gsrpnPNHqub0KdujaQmnPyo4K(ZWlaIGXd6Wz8oiKl(CBjxeOy1952AUy4FUTBNlNcJtkoxbOCBDkxmYTPCXNRyipq6sParHgdfK78ZfbkwDFUyMR)AYHFdhefd5bYRzfdTOzvLA21KWz8oiOButsqrXduv0SIHM0gsrpnjhL6Ii4PmObOfnRZRMDnjCgVdc6g1KdujaQmnPyo4K(ZWlaIGXd6Wz8oiKl(CfZbN0bvF78yQZeOdNX7GqU4Z1gsHdIWbkf85oLlg5IpxEgcI(ZWlaIGXd6iqXQ7ZT1CXOZcnPnKIEAspdHOcOfTOjdaHX4en7AwXqZUM0gsrpn5SAmttcNX7GGUrTOz1Fn7AsBif90KVaMt8PjHZ4Dqq3Ow0SYcn7As4mEhe0nQjPCAYhenPnKIEAsCgQmEhOjXzogqtchG88RJap4YLTC5O1tpie5Dae(CvHCBW52CUTKR)5Qc5(CGZf9zVa52KMeNHINPaAs4aKNFre4bxCqv4RdcArZkl1SRjHZ4Dqq3OMKYPjFq0K2qk6PjXzOY4DGMeN5yan5ZboxumKhiFNWUiLio7kCWNBR56VMeNHINPaAYVophefd5bIw0SQsn7As4mEhe0nQjhOsauzAYxaZj(Gqhr9yanPnKIEAYH5CrBif9IU6fnPREjEMcOjFbmN4dcArZ68QzxtcNX7GGUrn5avcGktt2sUylxXCWjDf7fafT)T)RRdNX7GqUTBNBGkDpdHOc0LAmRoVCBstAdPONMCyox0gsrVORErt6QxINPaAYr41IM1gSMDnjCgVdc6g1KdujaQmn5ZboxumKhiFNWUiLio7kCWNBRt52sUQm35NlI5ackYd6b79vNx8huMlGaxhuXykooiKBt5IpxEgcI(7QbeTled1a6iqXQ7ZT1CjkpFsebkwDFU4Zfbei49z8oix85oOk80ihTo5ZfZPCzHM0gsrpn57QbeTled1a0IMvvKMDnjCgVdc6g1K2qk6PjhMZfTHu0l6Qx0KU6L4zkGMmqfTOzDoOzxtcNX7GGUrnPnKIEAYH5CrBif9IU6fnPREjEMcOjdfcgIw0SIH61SRjHZ4Dqq3OMCGkbqLPjHdqE(1darnkjxmNYfdvMlB5IZqLX7GoCaYZVic8GloOk81bbnPnKIEAsdnSdIcfHGt0IMvmWqZUM0gsrpnPHg2brog3dAs4mEhe0nQfnRy4VMDnPnKIEAsx55t(4CmMGNcCIMeoJ3bbDJArZkgSqZUM0gsrpnjV5fPerbvJzVMeoJ3bbDJArlAsoemOk8MOzxZkgA21K2qk6PjnooNFroA90ttcNX7GGUrTOz1Fn7As4mEhe0nQjTHu0ttQyOzqisqrXayIpn5avcGkttISkebCWjDle(ED5IzUyOsnjhcgufEtIpmOx41KQulAwzHMDnPnKIEAYxaZj(0KWz8oiOBulAwzPMDnjCgVdc6g1K2qk6PjFxnGODHyOgGMCGkbqLPjrabcEFgVd0KCiyqv4nj(WGEHxtIHw0IMmuiyiA21SIHMDnjCgVdc6g1KdujaQmnjqqadPWbXbvHNg5O1jFUyoLllZLTCfZbN0daWbO4litmpqPdNX7GqU4ZTLCdapdbrhhCbqeRZWLB725gaEgcI(7RW1z4YTD7CHdqE(1darnkj3wNY1FvMlB5IZqLX7GoCaYZVic8GloOk81bHCB3oxSLlodvgVd6FDEoikgYdKCBkx852sUylxXCWjDq13opM6mb6Wz8oiKB725oOuxGQURdQ(25XuNjqhbkwDFUyMR)52KM0gsrpnjC4GJQOfnR(RzxtcNX7GGUrnjLtt(GOjTHu0ttIZqLX7anjoZXaAYbvHNg5O1jFpae1OKCXmxmYTD7CHdqE(1darnkj3wNY1FvMlB5IZqLX7GoCaYZVic8GloOk81bHCB3oxSLlodvgVd6FDEoikgYdenjodfptb0KmpejkNdqArZkl0SRjHZ4Dqq3OM0gsrpn5diKjqiYtpi(C1mqtoqLaOY0K8mee93vdiAxigQb0z4YfFUyl3av6pGqMaHip9G4ZvZGyGkDPgZQZl32TZLO88jreOy19526uUQm32TZDqPUavDx)beYeie5PheFUAg0h(mKh8rcKnKIEMlxmNY1)EdwL52UDUpLXXxxO7ale59lcQAkCoOdNX7GqU4ZfB5YZqq0DGfI8(fbvnfoh0z40Kd)goikgYdKxZkgArZkl1SRjHZ4Dqq3OMCGkbqLPjXzOY4DqN5Hir5Cakx852sU8meeDFviaxK3zb47VyJz5I5uUymhYTD7CBjxSLlhQOOs8lIOIjf9YfFUph4CrXqEG8Dc7IuI4SRWbFUyoLllZLTCFbmN4dcDe1JbYTPCBstAdPONMKWUiLio7kCWRfnRQuZUMeoJ3bbDJAsBif90Ke2fPeXzxHdEn5avcGkttIZqLX7GoZdrIY5auU4Z95aNlkgYdKVtyxKseNDfo4ZfZPCzHMC43WbrXqEG8AwXqlAwNxn7As4mEhe0nQjhOsauzAsCgQmEh0zEisuohGYfFUdk1fOQ764GlaIyDeOy195IzUyOEnPnKIEAsy4JwNxebCOsXUGw0S2G1SRjHZ4Dqq3OMCGkbqLPjXzOY4DqN5Hir5CastAdPONM0u4zEFArZQksZUMeoJ3bbDJAsBif90Kkms5mb0KdujaQmnjodvgVd6mpejkNdq5Ip3NdCUOyipq(oHDrkrC2v4Gp3PC9xto8B4GOyipqEnRyOfnRZbn7As4mEhe0nQjhOsauzAsCgQmEh0zEisuohG0K2qk6PjvyKYzcOfTOjhHxZUMvm0SRjTHu0tts4mpW5mPONMeoJ3bbDJArZQ)A21KWz8oiOButoqLaOY0KbGNHGOt4mpW5mPOxhbkwDFUTMR)AsBif90KeoZdCotk6fhoWUh0IMvwOzxtcNX7GGUrnPnKIEAsfdndcrckkgat8PjhOsauzAsKvHiGdoPBHW3z4YfFUTKRyipq6sParHgdfKBR5oOk80ihTo57bGOgLKRkKlgDvMB725oOk80ihTo57bGOgLKlMt5o4IkMQXNdUqUnPjh(nCqumKhiVMvm0IMvwQzxtcNX7GGUrn5avcGkttISkebCWjDle(ED5IzUSq95o)CrwfIao4KUfcFpWGmPOxU4ZDqv4ProADY3darnkjxmNYDWfvmvJphCbnPnKIEAsfdndcrckkgat8PfnRQuZUMeoJ3bbDJAskNM8brtAdPONMeNHkJ3bAsCMJb0KylxXCWj9R88jVyUzaQdNX7GqUTBNl2YvmhCshu9TZJPotGoCgVdc52UDUdk1fOQ76GQVDEm1zc0rGIv3NBR5QYCNFU(NRkKRyo4KEaaoafFbzI5bkD4mEhe0K4mu8mfqtIdUaiIfVYZN8I5MbO4GEHsk6PfnRZRMDnjCgVdc6g1KdujaQmnj2Y9fWCIpi0rupgix85gOshXWjmiOl1ywDE5IpxSLBa4zii64GlaIyDgUCXNlodvgVd64GlaIyXR88jVyUzakoOxOKIEAsBif90K4GlaIyArZAdwZUMeoJ3bbDJAYbQeavMMumhCshu9TZJPotGoCgVdc5IpxXCWj9R88jVyUzaQdNX7GqU4ZfiiGHu4G4GQWtJC06KpxmNYDWfvmvJphCHCXN7GsDbQ6UoO6BNhtDMaDeOy1952AUyOjTHu0ttIZU69PfnRQin7As4mEhe0nQjhOsauzAsXCWj9R88jVyUzaQdNX7GqU4ZfB5kMdoPdQ(25XuNjqhoJ3bHCXNlqqadPWbXbvHNg5O1jFUyoL7GlQyQgFo4c5Ip3aWZqq0XbxaeX6mCAsBif90K4SREFArZ6CqZUMeoJ3bbDJAsBif90KCuQlIGNYGgGMeuvqw0uOmNOjzPk1Keuu8avfnRyOfnRyOEn7As4mEhe0nQjhOsauzAsXCWj9NHxaebJh0HZ4Dqix85ITCFbmN4dcDe1JbYfFUdk1fOQ76EgcrfOZWLl(CBj3av6EgcrfOJace8(mEhKB725gaEgcIoo4cGiwNHlx85gOs3ZqiQaDofgNuCUcq526uUyKBt5Ip3bvHNg5O1jFpae1OKCXCk3wY95aNlkgYdKVtyxKseNDfo4ZfZ5i5YYCBkx85ISkebCWjDle(ED5IzUy4VM0gsrpnjo7Q3Nw0SIbgA21KWz8oiOButoqLaOY0KTKRyo4KUI9cGI2)2)11HZ4Dqi32TZfXCabf5bDfdnlsjIIpiQyVaOO9V9FDDqfJP44GqUnLl(CXwUVaMt8bHU5C5Ipxf7fafT)T)RlIafRUp3wNYv95IpxSLBGkDedNWGGociqW7Z4DqU4ZnqLUNHqub6iqXQ7ZfZCzrU4Zna8meeDCWfarSodxU4Zna8mee93xHRZWPjTHu0ttIZU69PfnRy4VMDnjCgVdc6g1KdujaQmnj2Y9fWCIpi0rupgix852sUyl3av6EgcrfOJace8(mEhKl(CduPJy4ege0rGIv3NlM5YYCzlxwMRkK7GlQyQgFo4c52UDUbQ0rmCcdc6iqXQ7ZvfYv9DvMlM5kgYdKUukquOXqb52uU4ZvmKhiDPuGOqJHcYfZCzPM0gsrpnjO6BNhtDMaArZkgSqZUMeoJ3bbDJAYbQeavMMmqLoIHtyqqxQXS68YTD7CduP)a3xFxQXS680K2qk6PjFFfoTOzfdwQzxtcNX7GGUrn5avcGkttYZqq05DuAWX8shb2qYTD7CdapdbrhhCbqeRZWPjTHu0ttYrLIEArZkgQuZUMeoJ3bbDJAYbQeavMMma8meeDCWfarSodNM0gsrpnjVJsdrcgKFArZkgZRMDnjCgVdc6g1KdujaQmnza4zii64GlaIyDgonPnKIEAsEa9aAwDEArZkgnyn7As4mEhe0nQjhOsauzAYaWZqq0XbxaeX6mCAsBif90Kefc4DuAqlAwXqfPzxtcNX7GGUrn5avcGkttgaEgcIoo4cGiwNHttAdPONM0Ub8cYCXH5CArZkgZbn7As4mEhe0nQjTHu0tt65Sqzcf9rfiyoxrpn5avcGkttgaEgcIoo4cGiwNHttceeWqINPaAspNfktOOpQabZ5k6PfnR(REn7As4mEhe0nQjTHu0tt65Sqzcf9rEl4bAYbQeavMMma8meeDCWfarSodNMeiiGHeptb0KEoluMqrFK3cEGw0S6pgA21K2qk6PjzEiwcO8As4mEhe0nQfTOjdurZUMvm0SRjHZ4Dqq3OMKYPjFq0K2qk6PjXzOY4DGMeN5yanjhQOOs8lIOIjf9YfFUph4CrXqEG8Dc7IuI4SRWbFUyMllYfFUTKBGkDpdHOc0rGIv3NBR5oOuxGQUR7zievGEGbzsrVCB3oxoA90dcrEhaHpxmZvL52KMeNHINPaAYFwXfh(nCq0ZqiQaArZQ)A21KWz8oiOButs50KpiAsBif90K4muz8oqtIZCmGMKdvuuj(fruXKIE5Ip3NdCUOyipq(oHDrkrC2v4GpxmZLf5Ip3wYna8mee93xHRZWLB725YrRNEqiY7ai85IzUQm3M0K4mu8mfqt(ZkU4WVHdIigoHbbArZkl0SRjHZ4Dqq3OMKYPjFq0K2qk6PjXzOY4DGMeN5yanza4zii64GlaIyDgUCXNBl5gaEgcI(7RW1z4YTD7CvSxau0(3(VUicuS6(CXmx1NBt5Ip3av6igoHbbDeOy195IzU(RjXzO4zkGM8NvCredNWGaTOzLLA21KWz8oiOButoqLaOY0KI5Gt6GQVDEm1zc0HZ4Dqix85ITCdapdbr3ZqiQaDq13opM6mbc5Ip3av6EgcrfOZPW4KIZvak3wNYfJCXN7GsDbQ6UoO6BNhtDMaDeOy1952AU(Nl(CFoW5IIH8a57e2fPeXzxHd(CNYfJCXNlYQqeWbN0Tq471LlM5oV5Ip3av6EgcrfOJafRUpxvix13vzUTMRyipq6sParHgdfOjTHu0tt6zievaTOzvLA21KWz8oiOButoqLaOY0KI5Gt6GQVDEm1zc0HZ4Dqix852sUabbmKchehufEAKJwN85I5uUdUOIPA85GlKl(ChuQlqv31bvF78yQZeOJafRUp3wZfJCXNBGkDedNWGGocuS6(CvHCvFxL52AUIH8aPlLcefAmuqUnPjTHu0ttIy4egeOfnRZRMDnjCgVdc6g1Keuu8avfnRyOjTHu0ttYrPUicEkdAaArZAdwZUMeoJ3bbDJAYbQeavMMebei49z8oix85oOk80ihTo57bGOgLKlMt5IrU4ZTLC5uyCsX5kaLBRt5IrUTBNlcuS6(CBDkxPgZIsPa5Ip3NdCUOyipq(oHDrkrC2v4GpxmNYLf52uU4ZTLCXwUGQVDEm1zceYTD7CrGIv3NBRt5k1ywukfixvix)ZfFUph4CrXqEG8Dc7IuI4SRWbFUyoLllYTPCXNBl5kgYdKUukquOXqb5o)CrGIv3NBt5IzUSmx85QyVaOO9V9FDreOy195oLR61K2qk6Pj9meIkGw0SQI0SRjHZ4Dqq3OMKGIIhOQOzfdnPnKIEAsok1frWtzqdqlAwNdA21KWz8oiOButAdPONM0ZqiQaAYbQeavMMeB5IZqLX7G(pR4Id)goi6zievGCXNlciqW7Z4DqU4ZDqv4ProADY3darnkjxmNYfJCXNBl5YPW4KIZvak3wNYfJCB3oxeOy19526uUsnMfLsbYfFUph4CrXqEG8Dc7IuI4SRWbFUyoLllYTPCXNBl5ITCbvF78yQZeiKB725IafRUp3wNYvQXSOukqUQqU(Nl(CFoW5IIH8a57e2fPeXzxHd(CXCkxwKBt5Ip3wYvmKhiDPuGOqJHcYD(5IafRUp3MYfZCXW)CXNRI9cGI2)2)1frGIv3N7uUQxto8B4GOyipqEnRyOfnRyOEn7As4mEhe0nQjhOsauzAYNdCUOyipq(CXCkx)ZfFUiqXQ7ZT1C9px2YTLCFoW5IIH8a5ZfZPCvzUnLl(CbccyifoioOk80ihTo5ZfZPCzPM0gsrpn5avkp9IcOWbVOfnRyGHMDnjCgVdc6g1KdujaQmnj2YfNHkJ3b9FwXfrmCcdcYfFUTKlqqadPWbXbvHNg5O1jFUyoLllZfFUiGabVpJ3b52UDUylxPgZQZlx852sUsPa5IzUyO(CB3o3bvHNg5O1jFUyoLR)52uUnLl(CBjxofgNuCUcq526uUyKB725IafRUp3wNYvQXSOukqU4Z95aNlkgYdKVtyxKseNDfo4ZfZPCzrUnLl(CBjxSLlO6BNhtDMaHCB3oxeOy19526uUsnMfLsbYvfY1)CXN7ZboxumKhiFNWUiLio7kCWNlMt5YICBkx85kgYdKUukquOXqb5o)CrGIv3NlM5YsnPnKIEAsedNWGaTOzfd)1SRjHZ4Dqq3OM0gsrpnjIHtyqGMCGkbqLPjXwU4muz8oO)ZkU4WVHdIigoHbb5IpxSLlodvgVd6)SIlIy4egeKl(CbccyifoioOk80ihTo5ZfZPCzzU4Zfbei49z8oix852sUCkmoP4CfGYT1PCXi32TZfbkwDFUToLRuJzrPuGCXN7ZboxumKhiFNWUiLio7kCWNlMt5YICBkx852sUylxq13opM6mbc52UDUiqXQ7ZT1PCLAmlkLcKRkKR)5Ip3NdCUOyipq(oHDrkrC2v4GpxmNYLf52uU4ZvmKhiDPuGOqJHcYD(5IafRUpxmZLLAYHFdhefd5bYRzfdTOzfdwOzxtcNX7GGUrn5avcGktt(CGZffd5bYN7uUyKl(CbccyifoioOk80ihTo5ZfZPCBj3bxuXun(CWfYD(5IrUnLl(CrabcEFgVdYfFUylxq13opM6mbc5IpxSLBa4zii6VVcxNHlx85QyVaOO9V9FDreOy195oLR6ZfFUIH8aPlLcefAmuqUZpxeOy195IzUSutAdPONMCGkLNErbu4Gx0IMvmyPMDnPnKIEAYh4(61KWz8oiOBulArlAsCa6l6Pz1F17V6Xad)zHMuDg6QZ71KZXXEZdRyhS2GWU5Ml7(GClfoksYLGIYDUgacJXjZ1CrGkgtHGqUpvbY1yeQIjqi3Hp78GVNyHDwhKllWU5oN0dhGeiKlzPmN5((DIPAUQ4ZvO5IDYy5gkC1x0lxkhGmHIYTLMBk3wWq1M6jwjwZXXEZdRyhS2GWU5Ml7(GClfoksYLGIYDUgOYCnxeOIXuiiK7tvGCngHQyceYD4Zop47jwyN1b5YsSBUZj9Wbibc5oxbvF78yQZei0NJoxZvO5oxdapdbrFoAhu9TZJPotGWCn3wWq1M6jwjwyhkCuKaHCN3CTHu0lxx9Y3tS0Kphm0S6VkNdAsoeLOCGMSH5I9(3(Votk6L78q9yGeRgMlRuCGcpGY1FvKA56V69x9jwjwnmxSVQWGrGqU8abfb5oOk8MKlp4v33Zf7ngaN85E0B((mKcbJlxBif9(CPNZVEILnKIEFNdbdQcVjtghNZVihTE6LyzdPO335qWGQWBcBtnRyOzqisqrXayIp14qWGQWBs8Hb9c)KkvRiMqwfIao4KUfcFVomXqLjw2qk69DoemOk8MW2uZVaMt8LyzdPO335qWGQWBcBtn)UAar7cXqna14qWGQWBs8Hb9c)egQvetiGabVpJ3bjwjwnmxSVQWGrGqUaoa5xUsPa5k(GCTHqr5wFUgoRCgVd6jw2qk69tZQXSeRgM78aVaMt8LBrKlh9)I3b52YrZfhJ7aKX7GCHduk4ZTUChufEtAkXYgsrVNTPMFbmN4lXYgsrVNTPMXzOY4DGANPatWbip)IiWdU4GQWxheudN5yGj4aKNFDe4bhBC06PheI8oacVk0GvX3I)QWZbox0N9c0uILnKIEpBtnJZqLX7a1otbM(68CqumKhiQHZCmW0ZboxumKhiFNWUiLio7kCW3Q)jw2qk69Sn18WCUOnKIErx9IANPatVaMt8bb1kIPxaZj(Gqhr9yGelBif9E2MAEyox0gsrVORErTZuGPr4vRiMAbBI5Gt6k2lakA)B)xxhoJ3bH2TduP7zievGUuJz151uILnKIEpBtn)UAar7cXqna1kIPNdCUOyipq(oHDrkrC2v4GV1Pwu58rmhqqrEqpyVV68I)GYCbe46GkgtXXbHMWZZqq0FxnGODHyOgqhbkwDFReLNpjIafRUhpciqW7Z4Da(bvHNg5O1jpMtSiXYgsrVNTPMhMZfTHu0l6Qxu7mfykqLelBif9E2MAEyox0gsrVORErTZuGPqHGHKyzdPO3Z2uZgAyhefkcbNOwrmbhG88RhaIAucMtyOs2WzOY4Dqhoa55xebEWfhuf(6GqILnKIEpBtnBOHDqKJX9qILnKIEpBtn7kpFYhNJXe8uGtsSSHu07zBQzEZlsjIcQgZ(eReRgM7CsPUavD3NyzdPO33hHFIWzEGZzsrVelBif9((i8Sn1mHZ8aNZKIEXHdS7b1kIPaWZqq0jCMh4CMu0RJafRUVv)tSAyUyhe5AHWNRHGCz4ul3)koixXhKl9GCvxj(Y1rvh8sUSZEdSN7C3hYvD(Gl3GF15LlH9cGYv8zxUZzdi3aquJsYLIYvDL4JYi5ANF5oNnGEILnKIEFFeE2MAwXqZGqKGIIbWeFQn8B4GOyipq(jmuRiMqwfIao4KUfcFNHdFlIH8aPlLcefAmuqRdQcpnYrRt(EaiQrjQagDv2U9GQWtJC06KVhaIAucMtdUOIPA85Gl0uIvdZf7Gi3JMRfcFUQRCUCdfKR6kXxD5k(GCpqvjxwO(xTCzEi35crdmx6Llp9)Cvxj(OmsU25xUZzdONyzdPO33hHNTPMvm0miejOOyamXNAfXeYQqeWbN0Tq471Hjlu)8rwfIao4KUfcFpWGmPOh(bvHNg5O1jFpae1OemNgCrft14ZbxiXQH5o3GlaIy56OE1WC5oOxOKIEM7ZL3EiKl9YDWGqWj5(CWiXYgsrVVpcpBtnJZqLX7a1otbMWbxaeXIx55tEXCZauCqVqjf9udN5yGjSjMdoPFLNp5fZndqD4mEheA3gBI5Gt6GQVDEm1zc0HZ4DqOD7bL6cu1DDq13opM6mb6iqXQ7BvLZ3FvqmhCspaahGIVGmX8aLoCgVdcjw2qk699r4zBQzCWfarm1kIjS9cyoXhe6iQhdGpqLoIHtyqqxQXS68WJTaWZqq0XbxaeX6mC4XzOY4DqhhCbqelELNp5fZndqXb9cLu0lXQH5o3SREF5QUs8Ll2x13lx2YL1YZN8I5MbiSBUZft1sHrj35SbKRDHCX(Q(E5Ial4xUeuuUhOQKBdAoBGjw2qk699r4zBQzC2vVp1kIjXCWjDq13opM6mb6Wz8oiGxmhCs)kpFYlMBgG6Wz8oiGhiiGHu4G4GQWtJC06KhZPbxuXun(CWfWpOuxGQURdQ(25XuNjqhbkwDFRyKy1WCNB2vVVCvxj(YL1YZN8I5MbOCzlxwP5I9v99WU5oxmvlfgLCNZgqU2fYDUbxaeXYLHlXYgsrVVpcpBtnJZU69PwrmjMdoPFLNp5fZndqD4mEheWJnXCWjDq13opM6mb6Wz8oiGhiiGHu4G4GQWtJC06KhZPbxuXun(CWfWhaEgcIoo4cGiwNHlXYgsrVVpcpBtnZrPUicEkdAaQrqrXduvMWqnqvbzrtHYCYelvzILnKIEFFeE2MAgND17tTIysmhCs)z4farW4bD4mEheWJTxaZj(Gqhr9ya8dk1fOQ76EgcrfOZWHVLav6EgcrfOJace8(mEh0UDa4zii64GlaIyDgo8bQ09meIkqNtHXjfNRauRty0e(bvHNg5O1jFpae1OemNA55aNlkgYdKVtyxKseNDfo4XCoclBcpYQqeWbN0Tq471Hjg(Ny1WCNB2vVVCvxj(YDUyVaOCXE)BFDy3CzLM7lG5eF5Axi3JMRnKchK7Cb7LlpdbHA5opmCcdcY9OsU1LlciqW7lxKDEGA5gyq15L7CdUaiIXg7nMyzdPO33hHNTPMXzx9(uRiMArmhCsxXEbqr7F7)66Wz8oi0UnI5ackYd6kgAwKsefFquXEbqr7F7)66GkgtXXbHMWJTxaZj(Gq3Co8k2lakA)B)xxebkwDFRtQhp2cuPJy4ege0rabcEFgVdWhOs3ZqiQaDeOy19yYc8bGNHGOJdUaiI1z4WhaEgcI(7RW1z4sSAyUyFvF78yQZeix15dUCpQK7lG5eFqix7c5YtfF5opmCcdcY1UqUnidHOcKRHGCz4YLGIY1rpVCHJY45RNyzdPO33hHNTPMbvF78yQZeqTIycBVaMt8bHoI6Xa4BbBbQ09meIkqhbei49z8oaFGkDedNWGGocuS6EmzjBSufgCrft14ZbxOD7av6igoHbbDeOy19QG67QetXqEG0LsbIcngkOj8IH8aPlLcefAmuaMSmXYgsrVVpcpBtn)(kCQvetbQ0rmCcdc6snMvNx72bQ0FG7RVl1ywDEjw2qk699r4zBQzoQu0tTIyINHGOZ7O0GJ5LocSH0UDa4zii64GlaIyDgUelBif9((i8Sn1mVJsdrcgKFQvetbGNHGOJdUaiI1z4sSSHu077JWZ2uZ8a6b0S68uRiMcapdbrhhCbqeRZWLyzdPO33hHNTPMjkeW7O0GAfXua4zii64GlaIyDgUelBif9((i8Sn1SDd4fK5IdZ5uRiMcapdbrhhCbqeRZWLyzdPO33hHNTPMzEiwcOOgqqadjEMcm55Sqzcf9rfiyoxrp1kIPaWZqq0XbxaeX6mCjw2qk699r4zBQzMhILakQbeeWqINPatEoluMqrFK3cEGAfXua4zii64GlaIyDgUeRgMBdeimgNKlH5C82ywUeuuUmVX7GClbuESBUZDFix6L7GsDbQ6UEILnKIEFFeE2MAM5HyjGYNyLy1WCBGfcgsUbtX8GCn(YvsbFIvdZf7F4GJQKRj5Ys2YTfvYwUQReF52ajBk35Sb0Zf7qrbcLjGZVCPxU(ZwUIH8a5vlx1vIVCNBWfarm1YLIYvDL4lx2Buf3CPIpaPU6HCvNvsUeuuUpvbYfoa55xpxSN7P5QoRKClICX(Q(E5oOk80CRp3bvPoVCz46jw2qk699qHGHmbho4OkQvetabbmKchehufEAKJwN8yoXs2eZbN0daWbO4litmpqPdNX7Ga(wcapdbrhhCbqeRZW1UDa4zii6VVcxNHRDB4aKNF9aquJsADYFvYgodvgVd6Wbip)IiWdU4GQWxheA3gB4muz8oO)155GOyipqAcFlytmhCshu9TZJPotGoCgVdcTBpOuxGQURdQ(25XuNjqhbkwDpM(3uILnKIEFpuiyiSn1modvgVdu7mfyI5Hir5CasnCMJbMgufEAKJwN89aquJsWeJ2THdqE(1darnkP1j)vjB4muz8oOdhG88lIap4IdQcFDqODBSHZqLX7G(xNNdIIH8ajXYgsrVVhkeme2MA(beYeie5PheFUAgO2WVHdIIH8a5NWqTIyINHGO)UAar7cXqnGodhESfOs)beYeie5PheFUAgeduPl1ywDETBtuE(KicuS6(wNuz72dk1fOQ76pGqMaHip9G4ZvZG(WNH8GpsGSHu0ZCyo5FVbRY2TFkJJVUq3bwiY7xeu1u4CqhoJ3bb8yJNHGO7ale59lcQAkCoOZWLy1WCN7yxUuICN7Vch85AsUymhyl3xSXSpxkrUQ4uHaC52OZcWNlfLR5z19sUSKTCfd5bY3tSSHu077HcbdHTPMjSlsjIZUch8Qvet4muz8oOZ8qKOCoaHVfEgcIUVkeGlY7Sa89xSXmmNWyo0UDlyJdvuuj(fruXKIE4FoW5IIH8a57e2fPeXzxHdEmNyjBVaMt8bHoI6Xan1uIvdZDUJD5sjYDU)kCWNRqZ144C(LBdeSGZVCBa06PxUfrU1zdPWb5sVCTZVCfd5bsUMKllYvmKhiFpXYgsrVVhkeme2MAMWUiLio7kCWR2WVHdIIH8a5NWqTIycNHkJ3bDMhIeLZbi8ph4CrXqEG8Dc7IuI4SRWbpMtSiXYgsrVVhkeme2MAgg(O15frahQuSlOwrmHZqLX7GoZdrIY5ae(bL6cu1DDCWfarSocuS6EmXq9jw2qk699qHGHW2uZMcpZ7tTIycNHkJ3bDMhIeLZbOeRgMl7g)8Nlms5mbYvO5ACCo)YTbcwW5xUnaA90lxtY1)Cfd5bYNyzdPO33dfcgcBtnRWiLZeqTHFdhefd5bYpHHAfXeodvgVd6mpejkNdq4FoW5IIH8a57e2fPeXzxHd(j)tSSHu077HcbdHTPMvyKYzcOwrmHZqLX7GoZdrIY5auIvIvdZTbAkMhKlfhGYvkfixJVCLuWNy1WCXolLsYTbzievGpx6L7rV5ZHkfKH8lxXqEG85sqr5k(GC5qffvIF5IOIjf9YTiYvLSLlVdGWNRHGCnhcSGF5YWLyzdPO33duzcNHkJ3bQDMcm9ZkU4WVHdIEgcrfqnCMJbM4qffvIFrevmPOh(NdCUOyipq(oHDrkrC2v4GhtwGVLav6EgcrfOJafRUV1bL6cu1DDpdHOc0dmitk61UnhTE6bHiVdGWJPkBkXQH5IDwkLK78WWjmi4ZLE5E0B(COsbzi)YvmKhiFUeuuUIpixourrL4xUiQysrVClICvjB5Y7ai85AiixZHal4xUmCjw2qk699avyBQzCgQmEhO2zkW0pR4Id)goiIy4egeOgoZXatCOIIkXViIkMu0d)ZboxumKhiFNWUiLio7kCWJjlW3sa4zii6VVcxNHRDBoA90dcrEhaHhtv2uIvdZf7Sukj35HHtyqWNBrK7CdUaiIXgPVcxZZf7faLl27F7)6YT(Cz4Y1UqUQdY1NHdY1F2Y9Hb9cFUoGqYLE5k(GCNhgoHbb52aPSNyzdPO33duHTPMXzOY4DGANPat)SIlIy4egeOgoZXatbGNHGOJdUaiI1z4W3sa4zii6VVcxNHRDBf7fafT)T)RlIafRUht13e(av6igoHbbDeOy19y6FIvdZLKdgL5YTbzievGCTlK78WWjmii3hegUC5qffLRqZf7R6BNhtDMa5oSxsSSHu077bQW2uZEgcrfqTIysmhCshu9TZJPotGoCgVdc4XgO6BNhtDMaHUNHqubWhOs3ZqiQaDofgNuCUcqToHb(bL6cu1DDq13opM6mb6iqXQ7B1F8ph4CrXqEG8Dc7IuI4SRWb)eg4rwfIao4KUfcFVomNx8bQ09meIkqhbkwDVkO(UkBvmKhiDPuGOqJHcsSSHu077bQW2uZigoHbbQvetI5Gt6GQVDEm1zc0HZ4DqaFlabbmKchehufEAKJwN8yon4IkMQXNdUa(bL6cu1DDq13opM6mb6iqXQ7Bfd8bQ0rmCcdc6iqXQ7vb13vzRIH8aPlLcefAmuqtjwnm3gKHqubYLHBgaCQLR5EAUcQGpxHMlZd5wsU2NRL7ZbJYC56bhGmHIYLGIYv8b56SxYDoBa5YdeueKRLlrD17dqjw2qk699avyBQzok1frWtzqdqnckkEGQYegjw2qk699avyBQzpdHOcOwrmHace8(mEhGFqv4ProADY3darnkbZjmW3cNcJtkoxbOwNWODBeOy19Toj1ywukfa)ZboxumKhiFNWUiLio7kCWJ5elAcFlydu9TZJPotGq72iqXQ7BDsQXSOukGk4p(NdCUOyipq(oHDrkrC2v4GhZjw0e(wed5bsxkfik0yOG5JafRUVjmzjEf7fafT)T)RlIafRUFs9jw2qk699avyBQzok1frWtzqdqnckkEGQYegjw2qk699avyBQzpdHOcO2WVHdIIH8a5NWqTIycB4muz8oO)ZkU4WVHdIEgcrfapciqW7Z4Da(bvHNg5O1jFpae1OemNWaFlCkmoP4CfGADcJ2TrGIv336KuJzrPua8ph4CrXqEG8Dc7IuI4SRWbpMtSOj8TGnq13opM6mbcTBJafRUV1jPgZIsPaQG)4FoW5IIH8a57e2fPeXzxHdEmNyrt4BrmKhiDPuGOqJHcMpcuS6(MWed)XRyVaOO9V9FDreOy19tQpXQH5oNOs5PxUSdkCWl5sVCvyCsX5GCfd5bYNRj5Ys2YDoBa5QoFWLlI5U68YLYi5wxU()52cdxUcnxwMRyipq(MYLIYLfFUTOs2YvmKhiFtjw2qk699avyBQ5bQuE6ffqHdErTIy65aNlkgYdKhZj)XJafRUVv)zRLNdCUOyipqEmNuzt4bccyifoioOk80ihTo5XCILjwnm35Ea4YLHl35HHtyqqUMKllzlx6LR5C5kgYdKp3wuNp4Y1v4QZlxh98YfokJNVCTlK7rLC)Z4EFuPPelBif9(EGkSn1mIHtyqGAfXe2WzOY4Dq)NvCredNWGa8TaeeWqkCqCqv4ProADYJ5elXJace8(mEh0Un2KAmRop8TiLcGjgQVD7bvHNg5O1jpMt(3ut4BHtHXjfNRauRty0UncuS6(wNKAmlkLcG)5aNlkgYdKVtyxKseNDfo4XCIfnHVfSbQ(25XuNjqODBeOy19Toj1ywukfqf8h)ZboxumKhiFNWUiLio7kCWJ5elAcVyipq6sParHgdfmFeOy19yYYelBif9(EGkSn1mIHtyqGAd)goikgYdKFcd1kIjSHZqLX7G(pR4Id)goiIy4egeGhB4muz8oO)ZkUiIHtyqaEGGagsHdIdQcpnYrRtEmNyjEeqGG3NX7a8TWPW4KIZvaQ1jmA3gbkwDFRtsnMfLsbW)CGZffd5bY3jSlsjIZUch8yoXIMW3c2avF78yQZei0UncuS6(wNKAmlkLcOc(J)5aNlkgYdKVtyxKseNDfo4XCIfnHxmKhiDPuGOqJHcMpcuS6EmzzIvdZDorLYtVCzhu4GxYLE5sYEUfrU1LlNDbqPg5Axi3sYvDLZLBGMRd(p3GPyEqUIp7Yf7F4GJQKBGbYvO5YEJnpxWEjw2qk699avyBQ5bQuE6ffqHdErTIy65aNlkgYdKFcd8abbmKchehufEAKJwN8yo1YGlQyQgFo4cZhJMWJace8(mEhGhBGQVDEm1zceWJTaWZqq0FFfUodhEf7fafT)T)RlIafRUFs94fd5bsxkfik0yOG5JafRUhtwMyzdPO33duHTPMFG7RpXkXQH5skG5eFqixS3qk69jwnmxwlpFVyUzakx6Lllyh7M7CIkLNE5YoOWbVKyzdPO33FbmN4dctduP80lkGch8IAfXKyo4K(vE(Kxm3ma1HZ4Dqa)ZboxumKhipMtSa)GQWtJC06KhZjwIxmKhiDPuGOqJHcMpcuS6EmN3eRgMlRLNVxm3maLl9Yfd2XU5sEg37Jk5opmCcdcsSSHu077VaMt8bb2MAgXWjmiqTIysmhCs)kpFYlMBgG6Wz8oiGFqv4ProADYJ5elXlgYdKUukquOXqbZhbkwDpMZBIvdZLKHxaebJhGDZf7XX58lxkk35biqW7lx1vIVC5ziiGqUnidHOc8jw2qk699xaZj(GaBtnZrPUicEkdAaQrqrXduvMWiXYgsrVV)cyoXheyBQzpdHOcO2WVHdIIH8a5NWqTIysmhCs)z4farW4bD4mEheW3ccuS6(wXW)2T5uyCsX5ka16egnHxmKhiDPuGOqJHcMpcuS6Em9pXQH5sYWlaIGXdYLTCX(Q(E5sVCXGDSBUZdqGG3xUnidHOcKRj5k(GCHlKlLi3xaZj(YvO56bsUkMQ5gyqMu0lxEGGIGCX(Q(25XuNjqILnKIEF)fWCIpiW2uZCuQlIGNYGgGAeuu8avLjmsSSHu077VaMt8bb2MA2ZqiQaQvetI5Gt6pdVaicgpOdNX7GaEXCWjDq13opM6mb6Wz8oiG3gsHdIWbkf8tyGNNHGO)m8cGiy8GocuS6(wXOZcTOfTga]] )

end