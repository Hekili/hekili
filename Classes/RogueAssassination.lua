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


    spec:RegisterPack( "Assassination", 20201206, [[da1jtbqiOuEKOuUefLQAtiPpjkvgLOKtjkAvOK0RqPAwOQ6wqPQDjv)sPIHHQKJbfTmrHNHsyAOeDnusTnLkvFJIcnousW5eLQSoLkP3rrPsnprf3tPSpOK)jkvfhekvAHIk9qkkAIOKOlsrbBuuQQ(ifL0iPOujNuPs0kHcVKIsfZuPs4Muuk7eLYqPOelvPs5Pi1urvCvrPQ0wHsf(kuQOglkj0Ej1FLYGvCyQwmQ8yLmzrUmyZq1NPWOPiNwYQPOuLxRu1SP0TjPDRYVrmCsCCOurwoKNRQPtCDuSDK47Ok14rv58uunFrv7xynMAE00jxanBzWRm4fMzWRDVNbVyjR5LzutlMRaAAfFT3nan95QGMg7(V)FDUuKttR4MBjEsZJM(jmOfOPnjIYVR7SJrjMy46lI6oFPYyDPi3c54YoFPU2rtZXuwzxEAonDYfqZwg8kdEHzg8A37zWlwYAEXAnTZiMiinnDPAMAAtvkbNMttNGFPPZwmy3)9)RZLICXSBedgiWiBXWkHfOYbOyWK)yYGxzWRaJaJSfJzJqbsXK9BDdWADPixmzzMwWVhYmggLyQlgfurqLyEmpjMsIH3egBkMJiXyasmCmOcsXWbMQlfZlGBftX4lPi331026LxZJM(fWTIjiP5rZgMAE00W5CwiPZvtVqLaOY10IBHt6xzysEXT7buhoNZcPyOgZRawBtCKbiFmyTfdlIHAmlIkhPPqQt(yWAlgwgd1yehzasxkvOjKwQGyW(yqGQx3hdwXS7AAFjf500luP(KRjGQc8Iw0SLHMhnnCoNfs6C10lujaQCnT4w4K(vgMKxC7Ea1HZ5SqkgQXSiQCKMcPo5JbRTyyzmuJrCKbiDPuHMqAPcIb7JbbQEDFmyfZURP9LuKttJyuegeOfnBSqZJMgoNZcjDUAACcQDaFIMnm10(skYPPvieBdbpHbTaTOzJLAE00W5CwiPZvt7lPiNM2WriIaA6fQeavUMwClCs)z4eaHZyaD4ColKIHAmzfdcu96(yYjgmZiM85JrrLXkLITaum5SfdMXKzmuJrCKbiDPuHMqAPcIb7JbbQEDFmyftgA6L5ll0ehzaYRzdtTOzJ1AE00W5CwiPZvtJtqTd4t0SHPM2xsronTcHyBi4jmOfOfnB7UMhnnCoNfs6C10lujaQCnT4w4K(ZWjacNXa6W5Cwifd1ye3cN0b(E)myQZfOdNZzHumuJXxsrbAWbQf8XSfdMXqngogC8(ZWjacNXa6iq1R7JjNyWSZcnTVKICAAdhHicOfnBMrnpAA4ColK05QPxOsau5AAXTWj9NHtaeoJb0HZ5SqkgQXSiQCKMcPo5JjNTyyHM2xsronTkJuwxaTOfnDcWDgRO5rZgMAE00(skYPP3xR9AA4ColK05QfnBzO5rt7lPiNM(fWTIjnnCoNfs6C1IMnwO5rtdNZzHKoxnnrrt)GOP9LuKtttXrLZzbnnf3YaAA4aKH5DeyaxmShJcPEYbPgNfG0hdRgJzmMDIjRyYigwnMxbS2Mj)fiMm10uCu7CvqtdhGmmVHad4AlIkxDqslA2yPMhnnCoNfs6C10efn9dIM2xsronnfhvoNf00uCldOPFfWABIJma574(1i4T9xrb(yYjMm00uCu7Cvqt)1zyHM4idq0IMnwR5rtdNZzHKoxn9cvcGkxtNaogC8oU1naR1LICDeO619XKtmzOP9LuKttJBDdWADPixBzb)EqlA22DnpAA4ColK05QPxOsau5A6xa3kMGuhrmyanTVKICA6LBTnFjf5A26fnTTEPDUkOPFbCRycsArZMzuZJMgoNZcjDUA6fQeavUMoRyWwmIBHt6Q(laQ5)7)xxhoNZcPyYNpMer6gocreOl1AFDgXKPM2xsron9YT2MVKICnB9IM2wV0oxf00R0RfnBScAE00W5CwiPZvtVqLaOY10VcyTnXrgG8DC)Ae82(ROaFm5SftwXW6yW(yqmhGtqgqp5VP6mA)IWCjey7W5CwiftMXqngogC8(BRf08l1s1c6iq1R7JjNyWldtsdbQEDFmuJbb4i4n5CwigQXSiQCKMcPo5JbRTyyHM2xsron9BRf08l1s1c0IMTSNMhnnCoNfs6C10(skYPPxU128LuKRzRx0026L25QGMoreTOzdtEP5rtdNZzHKoxnTVKICA6LBTnFjf5A26fnTTEPDUkOPtfcwIw0SHjMAE00W5CwiPZvtVqLaOY10WbidZ7jaVwLedwBXGjRJH9yO4OY5SqhoazyEdbgW1wevU6GKM2xsronTJw(bnHGqWjArZgMzO5rt7lPiNM2rl)GMcJ9bnnCoNfs6C1IMnmzHMhnTVKICAABzys(MzpMKHkCIMgoNZcjDUArZgMSuZJM2xsronnNB0i4nbvR9VMgoNZcjDUArlAAfeSiQCUO5rZgMAE00(skYPPDffR5nfs9KttdNZzHKoxTOzldnpAA4ColK05QP9LuKttR6O9qQHtqTe4Ijn9cvcGkxtJ8k1akWjDpL(EDXGvmyYAnTccwevoxApSix610SwlA2yHMhnTVKICA6xa3kM00W5CwiPZvlA2yPMhnnCoNfs6C10(skYPPFBTGMFPwQwGMEHkbqLRPraocEtoNf00kiyru5CP9WICPxtJPw0IMoviyjAE0SHPMhnnCoNfs6C10lujaQCnnGJdlPOaTfrLJ0ui1jFmyTfdlJH9ye3cN0taOaO2lixCdqTdNZzHumuJjRysahdoENcCjqeVZOet(8XKaogC8(BQO0zuIjF(yGdqgM3taETkjMC2Ijdwhd7XqXrLZzHoCaYW8gcmGRTiQC1bPyYNpgSfdfhvoNf6FDgwOjoYaKyYmgQXKvmylgXTWjDGV3pdM6Cb6W5Cwift(8XSieBIW7Rd89(zWuNlqhbQEDFmyftgXKPM2xsronnCuGJOQfnBzO5rtdNZzHKoxnnrrt)GOP9LuKtttXrLZzbnnf3YaA6frLJ0ui1jFpb41QKyWkgmJjF(yGdqgM3taETkjMC2Ijdwhd7XqXrLZzHoCaYW8gcmGRTiQC1bPyYNpgSfdfhvoNf6FDgwOjoYaennfh1oxf00mp0WlRfqArZgl08OPHZ5SqsNRM2xsron9diKlqQXroO9k1EqtVqLaOY10Cm4493wlO5xQLQf0zuIHAmylMer6pGqUaPgh5G2Ru7HwIiDPw7RZiM85JbVmmjneO619XKZwmSoM85Jzri2eH3x)beYfi14ih0ELAp0xMCKb8nCKVKICUngS2IjJUzK1XKpFmpHXYvxQBbp14mVb85QkwOdNZzHumuJbBXWXGJ3TGNACM3a(Cvfl0zu00lZxwOjoYaKxZgMArZgl18OPHZ5SqsNRMEHkbqLRPP4OY5SqN5HgEzTakgQXKvmCm44DtvkbxJZ6j47V4R9XG1wmyM9IjF(yYkgSfJcQiOsmVHiIlf5IHAmVcyTnXrgG8DC)Ae82(ROaFmyTfdlJH9yEbCRycsDeXGbIjZyYut7lPiNMg3VgbVT)kkWRfnBSwZJMgoNZcjDUAAFjf5004(1i4T9xrbEn9cvcGkxttXrLZzHoZdn8YAbumuJ5vaRTjoYaKVJ7xJG32Fff4JbRTyyHMEz(YcnXrgG8A2WulA22DnpAA4ColK05QPxOsau5AAkoQCol0zEOHxwlGIHAmlcXMi8(6uGlbI4DeO619XGvmyYlnTVKICAAyzIuNrdbkOs1VKw0Szg18OPHZ5SqsNRMEHkbqLRPP4OY5SqN5HgEzTast7lPiNM2v5yEtArZgRGMhnnCoNfs6C10(skYPPvzKY6cOPxOsau5AAkoQCol0zEOHxwlGIHAmVcyTnXrgG8DC)Ae82(ROaFmBXKHMEz(YcnXrgG8A2WulA2YEAE00W5CwiPZvtVqLaOY10uCu5CwOZ8qdVSwaPP9LuKttRYiL1fqlArtVsVMhnByQ5rt7lPiNMg36gG16sronnCoNfs6C1IMTm08OPHZ5SqsNRM2xsronTQJ2dPgob1sGlM00lujaQCnnYRudOaN09u67mkXqnMSIrCKbiDPuHMqAPcIjNywevostHuN89eGxRsIHvJbZoRJjF(ywevostHuN89eGxRsIbRTywknvNV2RaxkMm10lZxwOjoYaKxZgMArZgl08OPHZ5SqsNRMEHkbqLRPrELAaf4KUNsFVUyWkgwWRyW(yqELAaf4KUNsFpXGCPixmuJzru5infsDY3taETkjgS2IzP0uD(AVcCjnTVKICAAvhThsnCcQLaxmPfnBSuZJMgoNZcjDUAAIIM(brt7lPiNMMIJkNZcAAkULb00ylgXTWj9RmmjV429aQdNZzHum5Zhd2IrClCsh479ZGPoxGoCoNfsXKpFmlcXMi8(6aFVFgm15c0rGQx3htoXW6yW(yYigwngXTWj9eakaQ9cYf3au7W5CwiPPP4O25QGMMcCjqeVDLHj5f3UhqTf5sLuKtlA2yTMhnnCoNfs6C10lujaQCnn2I5fWTIji1redgigQXKishXOimiOl1AFDgXqngSftc4yWX7uGlbI4DgLyOgdfhvoNf6uGlbI4TRmmjV429aQTixQKICAAFjf500uGlbI4ArZ2UR5rtdNZzHKoxn9cvcGkxtlUfoPd89(zWuNlqhoNZcPyOgJ4w4K(vgMKxC7Ea1HZ5SqkgQXa44WskkqBru5infsDYhdwBXSuAQoFTxbUumuJzri2eH3xh479ZGPoxGocu96(yYjgm10(skYPPP4x9M0IMnZOMhnnCoNfs6C10lujaQCnT4w4K(vgMKxC7Ea1HZ5SqkgQXGTye3cN0b(E)myQZfOdNZzHumuJbWXHLuuG2IOYrAkK6KpgS2IzP0uD(AVcCPyOgtc4yWX7uGlbI4DgfnTVKICAAk(vVjTOzJvqZJMgoNZcjDUAAFjf500keITHGNWGwGMg4tqEZvjmNOPzjR104eu7a(enByQfnBzpnpAA4ColK05QPxOsau5AAXTWj9NHtaeoJb0HZ5SqkgQXGTyEbCRycsDeXGbIHAmlcXMi8(6gocreOZOed1yYkMer6gocreOJaCe8MColet(8XKaogC8of4sGiENrjgQXKis3WriIaDfvgRuk2cqXKZwmygtMXqnMfrLJ0ui1jFpb41QKyWAlMSI5vaRTjoYaKVJ7xJG32Fff4JbRSpXWYyYmgQXG8k1akWjDpL(EDXGvmyMHM2xsronnf)Q3Kw0SHjV08OPHZ5SqsNRMEHkbqLRPZkgXTWjDv)fa18)9)RRdNZzHum5ZhdI5aCcYa6QoAFJG3etqt1Fbqn)F))66W5CwiftMXqngSfZlGBftqQ7wBmuJr1Fbqn)F))6Aiq1R7JjNTy4vmuJbBXKishXOimiOJaCe8MColed1ysePB4ierGocu96(yWkgwed1ysahdoENcCjqeVZOed1ysahdoE)nvu6mkAAFjf500u8REtArZgMyQ5rtdNZzHKoxn9cvcGkxtJTyEbCRycsDeXGbIHAmzfd2IjrKUHJqeb6iahbVjNZcXqnMer6igfHbbDeO619XGvmSmg2JHLXWQXSuAQoFTxbUum5ZhtIiDeJIWGGocu96(yy1y4vN1XGvmIJmaPlLk0eslvqmzgd1yehzasxkvOjKwQGyWkgwQP9LuKttd89(zWuNlGw0SHzgAE00W5CwiPZvtVqLaOY10jI0rmkcdc6sT2xNrm5ZhtIi9hu(67sT2xNHM2xsron9BQOOfnByYcnpAA4ColK05QPxOsau5AAogC8oNLqswMx6iWxsm5ZhdEzysAiq1R7JjNyybVIjF(ysahdoENcCjqeVZOOP9LuKttRqKICArZgMSuZJMgoNZcjDUA6fQeavUMobCm44DkWLar8oJIM2xsronnNLqsnCgK5ArZgMSwZJMgoNZcjDUA6fQeavUMobCm44DkWLar8oJIM2xsronnhGEaTVodTOzdZDxZJMgoNZcjDUA6fQeavUMobCm44DkWLar8oJIM2xsronnEHaolHK0IMnmnJAE00W5CwiPZvtVqLaOY10jGJbhVtbUeiI3zu00(skYPP9BbVGCBB5wRw0SHjRGMhnnCoNfs6C10(skYPPnSEQCHG(MkKCRTiNMEHkbqLRPtahdoENcCjqeVZOOPbCCyjTZvbnTH1tLle03uHKBTf50IMnmZEAE00W5CwiPZvt7lPiNM2W6PYfc6BCEYa00lujaQCnDc4yWX7uGlbI4DgfnnGJdlPDUkOPnSEQCHG(gNNmaTOzldEP5rt7lPiNMM5HwjG6RPHZ5SqsNRw0IMorenpA2WuZJMgoNZcjDUAAIIM(brt7lPiNMMIJkNZcAAkULb00kOIGkX8gIiUuKlgQX8kG12ehzaY3X9RrWB7VIc8XGvmSigQXKvmjI0nCeIiqhbQEDFm5eZIqSjcVVUHJqeb6jgKlf5IjF(yui1toi14SaK(yWkgwhtMAAkoQDUkOP)9LsBz(YcndhHicOfnBzO5rtdNZzHKoxnnrrt)GOP9LuKtttXrLZzbnnf3YaAAfurqLyEdrexkYfd1yEfWABIJma574(1i4T9xrb(yWkgwed1yYkMeWXGJ3FtfLoJsm5ZhJcPEYbPgNfG0hdwXW6yYuttXrTZvbn9VVuAlZxwOHyuegeOfnBSqZJMgoNZcjDUAAIIM(brt7lPiNMMIJkNZcAAkULb00jGJbhVtbUeiI3zuIHAmzftc4yWX7VPIsNrjM85Jr1Fbqn)F))6Aiq1R7JbRy4vmzgd1ysePJyuege0rGQx3hdwXKHMMIJANRcA6FFP0qmkcdc0IMnwQ5rtdNZzHKoxn9cvcGkxtlUfoPd89(zWuNlqhoNZcPyOgd2IjbCm44DdhHic0b(E)myQZfifd1ysePB4ierGUIkJvkfBbOyYzlgmJHAmlcXMi8(6aFVFgm15c0rGQx3htoXKrmuJ5vaRTjoYaKVJ7xJG32Fff4JzlgmJHAmiVsnGcCs3tPVxxmyfZUhd1ysePB4ierGocu96(yy1y4vN1XKtmIJmaPlLk0eslvGM2xsronTHJqeb0IMnwR5rtdNZzHKoxn9cvcGkxtlUfoPd89(zWuNlqhoNZcPyOgtwXa44WskkqBru5infsDYhdwBXSuAQoFTxbUumuJzri2eH3xh479ZGPoxGocu96(yYjgmJHAmjI0rmkcdc6iq1R7JHvJHxDwhtoXioYaKUuQqtiTubXKPM2xsronnIrryqGw0ST7AE00W5CwiPZvtJtqTd4t0SHPM2xsronTcHyBi4jmOfOfnBMrnpAA4ColK05QPxOsau5AAeGJG3KZzHyOgZIOYrAkK6KVNa8AvsmyTfdMXqnMSIrrLXkLITaum5SfdMXKpFmiq1R7JjNTyKATVjLked1yEfWABIJma574(1i4T9xrb(yWAlgwetMXqnMSIbBXa89(zWuNlqkM85JbbQEDFm5SfJuR9nPuHyy1yYigQX8kG12ehzaY3X9RrWB7VIc8XG1wmSiMmJHAmzfJ4idq6sPcnH0sfed2hdcu96(yYmgSIHLXqngv)fa18)9)RRHavVUpMTy4LM2xsronTHJqeb0IMnwbnpAA4ColK05QPXjO2b8jA2Wut7lPiNMwHqSne8eg0c0IMTSNMhnnCoNfs6C10(skYPPnCeIiGMEHkbqLRPXwmuCu5CwO)7lL2Y8LfAgocreigQXGaCe8MColed1ywevostHuN89eGxRsIbRTyWmgQXKvmkQmwPuSfGIjNTyWmM85JbbQEDFm5SfJuR9nPuHyOgZRawBtCKbiFh3VgbVT)kkWhdwBXWIyYmgQXKvmylgGV3pdM6CbsXKpFmiq1R7JjNTyKATVjLkedRgtgXqnMxbS2M4idq(oUFncEB)vuGpgS2IHfXKzmuJjRyehzasxkvOjKwQGyW(yqGQx3htMXGvmyMrmuJr1Fbqn)F))6Aiq1R7JzlgEPPxMVSqtCKbiVMnm1IMnm5LMhnnCoNfs6C10lujaQCn9RawBtCKbiFmyTftgXqngeO619XKtmzed7XKvmVcyTnXrgG8XG1wmSoMmJHAmaooSKIc0wevostHuN8XG1wmSut7lPiNMEHk1NCnbuvGx0IMnmXuZJMgoNZcjDUA6fQeavUMgBXqXrLZzH(VVuAigfHbbXqnMSIbWXHLuuG2IOYrAkK6KpgS2IHLXqngeGJG3KZzHyYNpgSfJuR91zed1yYkgPuHyWkgm5vm5ZhZIOYrAkK6KpgS2IjJyYmMmJHAmzfJIkJvkfBbOyYzlgmJjF(yqGQx3htoBXi1AFtkvigQX8kG12ehzaY3X9RrWB7VIc8XG1wmSiMmJHAmzfd2Ib479ZGPoxGum5Zhdcu96(yYzlgPw7BsPcXWQXKrmuJ5vaRTjoYaKVJ7xJG32Fff4JbRTyyrmzgd1yehzasxkvOjKwQGyW(yqGQx3hdwXWsnTVKICAAeJIWGaTOzdZm08OPHZ5SqsNRM2xsronnIrryqGMEHkbqLRPXwmuCu5CwO)7lL2Y8LfAigfHbbXqngSfdfhvoNf6)(sPHyuegeed1yaCCyjffOTiQCKMcPo5JbRTyyzmuJbb4i4n5CwigQXKvmkQmwPuSfGIjNTyWmM85JbbQEDFm5SfJuR9nPuHyOgZRawBtCKbiFh3VgbVT)kkWhdwBXWIyYmgQXKvmylgGV3pdM6CbsXKpFmiq1R7JjNTyKATVjLkedRgtgXqnMxbS2M4idq(oUFncEB)vuGpgS2IHfXKzmuJrCKbiDPuHMqAPcIb7JbbQEDFmyfdl10lZxwOjoYaKxZgMArZgMSqZJMgoNZcjDUA6fQeavUM(vaRTjoYaKpMTyWmgQXa44WskkqBru5infsDYhdwBXKvmlLMQZx7vGlfd2hdMXKzmuJbb4i4n5CwigQXGTya(E)myQZfifd1yWwmjGJbhV)MkkDgLyOgJQ)cGA()()11qGQx3hZwm8kgQXioYaKUuQqtiTubXG9XGavVUpgSIHLAAFjf500luP(KRjGQc8Iw0SHjl18OP9LuKtt)GYxVMgoNZcjDUArlArttbqFronBzWRm4fMzWlm1082rxDgVMg7m2D3yBxYMzDxJjgEmbXuQkeKedobft2LaCNXkzxmia7etHGumprfIXzeIQlqkMLj)mGVhySlQdIHf7AmMj5OaibsXqxQMzmV5N48fJz)yesm7cgpMurP(ICXquaKleumzTtMXKfM8LzpWyxuhedRWUgJzsokasGumzhI5aCcYa6SIzxmcjMSdXCaobzaDwXoCoNfszxmzHjFz2dmcmWoJD3n22LSzw31yIHhtqmLQcbjXGtqXKDR0NDXGaStmfcsX8evigNriQUaPywM8Za(EGXUOoigm51UgJzsokasGumzhI5aCcYa6SIzxmcjMSdXCaobzaDwXoCoNfszxmzHjFz2dmcmWoJD3n22LSzw31yIHhtqmLQcbjXGtqXKDjIKDXGaStmfcsX8evigNriQUaPywM8Za(EGXUOoigwURXyMKJcGeift2b89(zWuNlqQZkMDXiKyYUeWXGJ3zf7aFVFgm15cKYUyYct(YShyeySlvviibsXS7X4lPixm26LVhyOPvqe8YcA6Sfd29F))6CPixm7gXGbcmYwmSsybQCakgm5pMm4vg8kWiWiBXy2iuGumz)w3aSwxkYftwMPf87HmJHrjM6IrbveujMhZtIPKy4nHXMI5ismgGedhdQGumCGP6sX8c4wXum(skY99aJaJSfJzGpyXiqkgoaNGGywevoxIHdmQ77XGDxlqr(yoYH9MCKkoJngFjf5(yiN18EGHVKICFxbblIkNlBUII18McPEYfy4lPi33vqWIOY5c7B7O6O9qQHtqTe4Ij(vqWIOY5s7Hf5s)gR5VW3qELAaf4KUNsFVoSWK1bg(skY9DfeSiQCUW(2oVaUvmfy4lPi33vqWIOY5c7B782Abn)sTuTa(vqWIOY5s7Hf5s)gM8x4BiahbVjNZcbgbgzlgZaFWIrGumafazEmsPcXiMGy8LqqXuFmofVSoNf6bg(skY9B7R1(aJSfZUbVaUvmftHhJc5)IZcXK1rIHcJ9aKZzHyGdul4JPUywevoxYmWWxsrUN9TDEbCRykWWxsrUN9TDO4OY5Sa)NRcBWbidZBiWaU2IOYvhK4NIBzGn4aKH5Deyah7kK6jhKACwaspRAgn7NvgS6RawBZK)cKzGHVKICp7B7qXrLZzb(pxf2(6mSqtCKbi8tXTmW2RawBtCKbiFh3VgbVT)kkWNtgbg(skY9SVTdU1naR1LICTLf87b(l8TeWXGJ3XTUbyTUuKRJavVUpNmcm8LuK7zFBNLBTnFjf5A26f(pxf2EbCRycs8x4BVaUvmbPoIyWabg(skY9SVTZYT2MVKICnB9c)NRcBR0ZFHVLf2e3cN0v9xauZ)3)VUoCoNfs5ZNis3WriIaDPw7RZiZadFjf5E2325T1cA(LAPAb8x4BVcyTnXrgG8DC)Ae82(ROaFoBzXAShXCaobza9K)MQZO9lcZLqGntQCm4493wlO5xQLQf0rGQx3NdEzysAiq1R7PIaCe8MColqDru5infsDYJ1glcm8LuK7zFBNLBTnFjf5A26f(pxf2sejWWxsrUN9TDwU128LuKRzRx4)Cvylviyjbg(skY9SVTJJw(bnHGqWj8x4BWbidZ7jaVwLG1gMSMDkoQCol0HdqgM3qGbCTfrLRoify4lPi3Z(2ooA5h0uySpey4lPi3Z(2o2YWK8nZEmjdv4KadFjf5E232HZnAe8MGQ1(pWiWiBXyMeInr499bg(skY99v63WTUbyTUuKlWiBXSlXJXtPpghbXWOWFm)vkqmIjigYbXW7smfJLWB4Ly4HhwzpMSVpedVnbxmjZRZigC)fafJyYVymtZsmjaVwLedbfdVlXeHrIXpZJXmnl9adFjf5((k9SVTJQJ2dPgob1sGlM4Fz(YcnXrgG8ByYFHVH8k1akWjDpL(oJc1SehzasxkvOjKwQGCwevostHuN89eGxRsyvm7SoF(frLJ0ui1jFpb41QeS2wknvNV2RaxkZaJSfZUepMJeJNsFm8US2ysfedVlXuDXiMGyoGpjgwWRN)yyEigZgoRmgYfdh5)y4DjMimsm(zEmMPzPhy4lPi33xPN9TDuD0Ei1WjOwcCXe)f(gYRudOaN09u671Hfl4f2J8k1akWjDpL(EIb5sroQlIkhPPqQt(EcWRvjyTTuAQoFTxbUuGr2Ib7aUeiIhJLyul3gZICPskY52pgo)HumKlMfdcbNeZRaRadFjf5((k9SVTdfhvoNf4)CvyJcCjqeVDLHj5f3UhqTf5sLuKJFkULb2WM4w4K(vgMKxC7Ea1HZ5SqkFESjUfoPd89(zWuNlqhoNZcP85xeInr491b(E)myQZfOJavVUphwJ9zWQIBHt6jauau7fKlUbO2HZ5SqkWWxsrUVVsp7B7qbUeiIZFHVHTxa3kMGuhrmyaQjI0rmkcdc6sT2xNbvSLaogC8of4sGiENrHkfhvoNf6uGlbI4TRmmjV429aQTixQKICbgzlgSd)Q3um8UetXyg47nIH9yyRmmjV429aAxJXS58vQmQXyMMLy8lfJzGV3ige4jZJbNGI5a(KymRMjRmWWxsrUVVsp7B7qXV6nXFHVjUfoPd89(zWuNlqhoNZcjQIBHt6xzysEXT7buhoNZcjQaooSKIc0wevostHuN8yTTuAQoFTxbUe1fHyteEFDGV3pdM6Cb6iq1R7ZbZaJSfd2HF1BkgExIPyyRmmjV429akg2JHnsmMb(EJDngZMZxPYOgJzAwIXVumyhWLar8yyucm8LuK77R0Z(2ou8REt8x4BIBHt6xzysEXT7buhoNZcjQytClCsh479ZGPoxGoCoNfsubCCyjffOTiQCKMcPo5XABP0uD(AVcCjQjGJbhVtbUeiI3zucm8LuK77R0Z(2okeITHGNWGwa)4eu7a(Knm5h4tqEZvjmNSXswhy4lPi33xPN9TDO4x9M4VW3e3cN0Fgobq4mgqhoNZcjQy7fWTIji1redgG6IqSjcVVUHJqeb6mkuZkrKUHJqeb6iahbVjNZc5ZNaogC8of4sGiENrHAIiDdhHic0vuzSsPylaLZgMzsDru5infsDY3taETkbRTSEfWABIJma574(1i4T9xrbESY(WYmPI8k1akWjDpL(EDyHzgbgzlgSd)Q3um8UetXy28xaumy3)9VUDng2iX8c4wXum(LI5iX4lPOaXy2WUXWXGJZFm7gJIWGGyoIetDXGaCe8MIb5NbWFmjguDgXGDaxceXzNNCdm8LuK77R0Z(2ou8REt8x4BzjUfoPR6VaOM)V)FDD4ColKYNhXCaobzaDvhTVrWBIjOP6VaOM)V)FDzsfBVaUvmbPUBTuv9xauZ)3)VUgcu96(C24fvSLishXOimiOJaCe8MColqnrKUHJqeb6iq1R7XIfutahdoENcCjqeVZOqnbCm4493urPZOeyKTymd89(zWuNlqm82eCXCejMxa3kMGum(LIHJiMIz3yuegeeJFPymRocreighbXWOedobfJLCgXahHXWupWWxsrUVVsp7B7a89(zWuNla)f(g2EbCRycsDeXGbOMf2sePB4ierGocWrWBY5Sa1er6igfHbbDeO619yXs2zjRUuAQoFTxbUu(8jI0rmkcdc6iq1R7zvE1znwIJmaPlLk0eslvqMufhzasxkvOjKwQaSyzGHVKICFFLE2325nvu4VW3sePJyuege0LATVoJ85teP)GYxFxQ1(6mcm8LuK77R0Z(2okePih)f(ghdoENZsijlZlDe4ljFE8YWK0qGQx3Ndl4v(8jGJbhVtbUeiI3zucm8LuK77R0Z(2oCwcj1WzqMZFHVLaogC8of4sGiENrjWWxsrUVVsp7B7WbOhq7RZG)cFlbCm44DkWLar8oJsGHVKICFFLE232bVqaNLqs8x4BjGJbhVtbUeiI3zucm8LuK77R0Z(2o(TGxqUTTCRL)cFlbCm44DkWLar8oJsGHVKICFFLE232H5HwjGk)aooSK25QWMH1tLle03uHKBTf54VW3sahdoENcCjqeVZOey4lPi33xPN9TDyEOvcOYpGJdlPDUkSzy9u5cb9nopza8x4BjGJbhVtbUeiI3zucmYwmSsa3zSsm4U1Y5R9XGtqXW8oNfIPeq931yY((qmKlMfHyteEF9adFjf5((k9SVTdZdTsa1pWiWiBXWkleSKysUQBaX4CLTKc(aJSfJz4OahrngxIHLShtwSM9y4DjMIHvsNzmMPzPhZUuvfsLlG18yixmzWEmIJma55pgExIPyWoGlbI48hdbfdVlXum8KRz3XqetaI31dXWBVKyWjOyEIkedCaYW8Emyx7tIH3EjXu4Xyg47nIzru5iXuFmlIADgXWO0dm8LuK77PcblzdokWru5VW3aCCyjffOTiQCKMcPo5XAJLSlUfoPNaqbqTxqU4gGAhoNZcjQzLaogC8of4sGiENrjF(eWXGJ3FtfLoJs(8WbidZ7jaVwLKZwgSMDkoQCol0HdqgM3qGbCTfrLRoiLpp2O4OY5Sq)RZWcnXrgGKj1SWM4w4KoW37NbtDUaD4ColKYNFri2eH3xh479ZGPoxGocu96ESYiZadFjf5(EQqWsyFBhkoQColW)5QWgZdn8YAbe)uCldSTiQCKMcPo57jaVwLGfM5ZdhGmmVNa8AvsoBzWA2P4OY5SqhoazyEdbgW1wevU6Gu(8yJIJkNZc9Vodl0ehzasGHVKICFpviyjSVTZdiKlqQXroO9k1EG)L5ll0ehzaYVHj)f(ghdoE)T1cA(LAPAbDgfQylrK(diKlqQXroO9k1EOLisxQ1(6mYNhVmmjneO6195SX685xeInr491FaHCbsnoYbTxP2d9LjhzaFdh5lPiNBXAlJUzK15Z)eglxDPUf8uJZ8gWNRQyHoCoNfsuXghdoE3cEQXzEd4ZvvSqNrjWiBXK97xme8ym7Cff4JXLyWm7XEmV4R9Fme8ym7Qsj4IjxRNGpgckg3WR7Lyyj7XioYaKVhy4lPi33tfcwc7B7G7xJG32Fff45VW3O4OY5SqN5HgEzTaIAwCm44DtvkbxJZ6j47V4R9yTHz2lF(SWMcQiOsmVHiIlf5O(kG12ehzaY3X9RrWB7VIc8yTXs2FbCRycsDeXGbYmZaJSft2VFXqWJXSZvuGpgHeJROynpgwj4jR5Xywi1tUyk8yQZxsrbIHCX4N5XioYaKyCjgweJ4idq(EGHVKICFpviyjSVTdUFncEB)vuGN)L5ll0ehzaYVHj)f(gfhvoNf6mp0WlRfquFfWABIJma574(1i4T9xrbES2yrGHVKICFpviyjSVTdSmrQZOHafuP6xI)cFJIJkNZcDMhA4L1ciQlcXMi8(6uGlbI4DeO619yHjVcm8LuK77PcblH9TDCvoM3e)f(gfhvoNf6mp0WlRfqbgzlgECoS3SXiL1figHeJROynpgwj4jR5Xywi1tUyCjMmIrCKbiFGHVKICFpviyjSVTJkJuwxa(xMVSqtCKbi)gM8x4BuCu5CwOZ8qdVSwar9vaRTjoYaKVJ7xJG32Fff43YiWWxsrUVNkeSe232rLrkRla)f(gfhvoNf6mp0WlRfqbgbgzlgwPR6gqmekakgPuHyCUYwsbFGr2IzxuQLeJz1riIaFmKlMJCyVcQuroY8yehzaYhdobfJycIrbveujMhdIiUuKlMcpgwZEmCwasFmocIXTiWtMhdJsGHVKICFprKnkoQColW)5QW2VVuAlZxwOz4iera(P4wgytbveujM3qeXLICuFfWABIJma574(1i4T9xrbESyb1SsePB4ierGocu96(CweInr491nCeIiqpXGCPix(8kK6jhKACwaspwSoZaJSfZUOuljMDJrryqWhd5I5ih2RGkvKJmpgXrgG8XGtqXiMGyuqfbvI5XGiIlf5IPWJH1ShdNfG0hJJGyClc8K5XWOey4lPi33teH9TDO4OY5Sa)NRcB)(sPTmFzHgIrryqa)uCldSPGkcQeZBiI4sroQVcyTnXrgG8DC)Ae82(ROapwSGAwjGJbhV)MkkDgL85vi1toi14SaKESyDMbgzlMDrPwsm7gJIWGGpMcpgSd4sGio70Mkk7y28xaumy3)9)RlM6JHrjg)sXWBigtofiMmypMhwKl9XybCjgYfJycIz3yuegeedRKWtGHVKICFpre232HIJkNZc8FUkS97lLgIrryqa)uCldSLaogC8of4sGiENrHAwjGJbhV)MkkDgL85v9xauZ)3)VUgcu96ES4vMutePJyuege0rGQx3JvgbgzlgAfyvUngZQJqebIXVum7gJIWGGyEqyuIrbveumcjgZaFVFgm15ceZYFjWWxsrUVNic7B7y4iera(l8nXTWjDGV3pdM6Cb6W5CwirfBaFVFgm15cK6gocreGAIiDdhHic0vuzSsPylaLZgMuxeInr491b(E)myQZfOJavVUpNmO(kG12ehzaY3X9RrWB7VIc8Bysf5vQbuGt6Ek996WA3PMis3WriIaDeO619SkV6SohXrgG0LsfAcPLkiWWxsrUVNic7B7GyuegeWFHVjUfoPd89(zWuNlqhoNZcjQzb44WskkqBru5infsDYJ12sPP681Ef4suxeInr491b(E)myQZfOJavVUphmPMishXOimiOJavVUNv5vN15ioYaKUuQqtiTubzgyKTymRocreiggL9aOWFmU9jXiOc(yesmmpetjX4FmEmVcSk3gJbCaYfckgCckgXeeJ1FjgZ0SedhGtqqmEm41vVjafy4lPi33teH9TDuieBdbpHbTa(XjO2b8jBygy4lPi33teH9TDmCeIia)f(gcWrWBY5Sa1frLJ0ui1jFpb41QeS2WKAwkQmwPuSfGYzdZ85rGQx3NZMuR9nPubQVcyTnXrgG8DC)Ae82(ROapwBSitQzHnGV3pdM6Cbs5ZJavVUpNnPw7BsPcSAguFfWABIJma574(1i4T9xrbES2yrMuZsCKbiDPuHMqAPcWEeO619zIflPQ6VaOM)V)FDneO619B8kWWxsrUVNic7B7Oqi2gcEcdAb8JtqTd4t2WmWWxsrUVNic7B7y4iera(xMVSqtCKbi)gM8x4ByJIJkNZc9FFP0wMVSqZWriIauraocEtoNfOUiQCKMcPo57jaVwLG1gMuZsrLXkLITauoByMppcu96(C2KATVjLkq9vaRTjoYaKVJ7xJG32Fff4XAJfzsnlSb89(zWuNlqkFEeO6195Sj1AFtkvGvZG6RawBtCKbiFh3VgbVT)kkWJ1glYKAwIJmaPlLk0eslva2JavVUptSWmdQQ(laQ5)7)xxdbQED)gVcmYwmMjQuFYfdpGQc8smKlgvgRukwigXrgG8X4smSK9ymtZsm82eCXGyURoJyimsm1ftgFmzXOeJqIHLXioYaKpZyiOyyXhtwSM9yehzaYNzGHVKICFpre232zHk1NCnbuvGx4VW3EfWABIJma5XAldQiq1R7Zjd2Z6vaRTjoYaKhRnwNjvahhwsrbAlIkhPPqQtES2yzGr2IXSdakXWOeZUXOimiigxIHLShd5IXT2yehzaYhtw82eCXylk1zeJLCgXahHXWum(LI5ism)5kVjIKzGHVKICFpre232bXOimiG)cFdBuCu5CwO)7lLgIrryqa1SaCCyjffOTiQCKMcPo5XAJLuraocEtoNfYNhBsT2xNb1SKsfWctELp)IOYrAkK6KhRTmYmtQzPOYyLsXwakNnmZNhbQEDFoBsT23KsfO(kG12ehzaY3X9RrWB7VIc8yTXImPMf2a(E)myQZfiLppcu96(C2KATVjLkWQzq9vaRTjoYaKVJ7xJG32Fff4XAJfzsvCKbiDPuHMqAPcWEeO619yXYadFjf5(EIiSVTdIrryqa)lZxwOjoYaKFdt(l8nSrXrLZzH(VVuAlZxwOHyuegeqfBuCu5CwO)7lLgIrryqavahhwsrbAlIkhPPqQtES2yjveGJG3KZzbQzPOYyLsXwakNnmZNhbQEDFoBsT23KsfO(kG12ehzaY3X9RrWB7VIc8yTXImPMf2a(E)myQZfiLppcu96(C2KATVjLkWQzq9vaRTjoYaKVJ7xJG32Fff4XAJfzsvCKbiDPuHMqAPcWEeO619yXYaJSfJzIk1NCXWdOQaVed5IHMNyk8yQlgf)sGATIXVumLedVlRnMejgl8Fmjx1nGyet(fJz4OahrnMedeJqIHNC3XSHDdm8LuK77jIW(2oluP(KRjGQc8c)f(2RawBtCKbi)gMubCCyjffOTiQCKMcPo5XAlRLst15R9kWLWEmZKkcWrWBY5SavSb89(zWuNlqIk2sahdoE)nvu6mkuv9xauZ)3)VUgcu96(nErvCKbiDPuHMqAPcWEeO619yXYadFjf5(EIiSVTZdkF9bgbgzlgAbCRycsXGDxsrUpWiBXWwzy6f3UhqXqUyybp7AmMjQuFYfdpGQc8sGHVKICF)fWTIjiTTqL6tUMaQkWl8x4BIBHt6xzysEXT7buhoNZcjQVcyTnXrgG8yTXcQlIkhPPqQtES2yjvXrgG0LsfAcPLka7rGQx3J1UhyKTyyRmm9IB3dOyixmyYZUgd95kVjIeZUXOimiiWWxsrUV)c4wXeKyFBheJIWGa(l8nXTWj9RmmjV429aQdNZzHe1frLJ0ui1jpwBSKQ4idq6sPcnH0sfG9iq1R7XA3dmYwm0mCcGWzmGDngSRII18yiOy2nahbVPy4DjMIHJbhhsXywDeIiWhy4lPi33FbCRycsSVTJcHyBi4jmOfWpob1oGpzdZadFjf5((lGBftqI9TDmCeIia)lZxwOjoYaKFdt(l8nXTWj9NHtaeoJb0HZ5SqIAwiq1R7ZbZmYNxrLXkLITauoByMjvXrgG0LsfAcPLka7rGQx3JvgbgzlgAgobq4mgqmShJzGV3igYfdM8SRXSBaocEtXywDeIiqmUeJycIbUume8yEbCRykgHeJbiXO68ftIb5srUy4aCccIXmW37NbtDUabg(skY99xa3kMGe7B7Oqi2gcEcdAb8JtqTd4t2WmWWxsrUV)c4wXeKyFBhdhHicWFHVjUfoP)mCcGWzmGoCoNfsuf3cN0b(E)myQZfOdNZzHevFjffObhOwWVHjvogC8(ZWjacNXa6iq1R7ZbZolcm8LuK77VaUvmbj232rLrkRla)f(M4w4K(ZWjacNXa6W5CwirDru5infsDYNZgl00VcS0SLbRZEArlAna]] )

end