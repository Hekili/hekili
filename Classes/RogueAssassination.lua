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


    spec:RegisterPack( "Assassination", 20201226, [[da1iwbqiOkEefvDjvkjSjuYNOOIrjkCkrrRcvKEfQKzrrClOu1UKQFjQ0WeLQJbfTmrjpdkLPHkQRHkLTPsP6BuuPghQiQZPsPyDQuI3rrLOMNkf3tLSpOK)PsjrhekvAHIkEiQu1erfHlIkvSrkQK(OOu0iPOsKtQsj1kHcVKIkHzkkL6MIsHDcv1qrLkTuOuXtrQPIkCvvkj1wfLs(kQiIXQsP0Ej5VszWkomvlgv9yvmzrUmyZi5Zuy0OuNwYQvPKKxRs1SP0Tjv7wPFJy4KYXrfrA5qEUQMoX1rX2HkFhQsJNI05POmFrv7xyfMkou0jxaf(zL9SYoMzL1T3XetSHnSHPIwmtdu0A(5UBak611bfn29F))ADPiRIwZnZs8KIdf9tyqhqrZweT)wYnxJsyZW3pe9C)sNX6sr2dYPKC)s)KRIMNPSYTEv8k6KlGc)SYEwzhZSY627yIj2WwwCYkANrytqkA6sN7v0SRucwfVIob)rrB(yWU)7)xRlfzJb7qmyGadZhdNaoGopGIbtSzsmzL9SYEGrGH5JjBqWbPymxTUbyTUuKnMm4El47dzgdJwm1gJgQiOsmlMNetjXGxcJnfZsKymajgEgubPy4b21MI5fWTc7y8JuK97kAB9YR4qr)c4wHnKuCOWhtfhkAyDElKu5OOpOsau5kAXTWk9TmylV427aQdRZBHumSI51aRTjoYaKpgSUIbBXWkMdrNN00i1kFmyDfdNJHvmIJmaPlLo0eslvqmyFmiq3R9JbRyUDfTFKISk6dQ0FY2eqxdErjk8ZsXHIgwN3cjvok6dQeavUIwClSsFld2YlU9oG6W68wifdRyoeDEstJuR8XG1vmCogwXioYaKUu6qtiTubXG9XGaDV2pgSI52v0(rkYQOrmAcdcuIcFSP4qrdRZBHKkhfnfb1wWurHpMkA)ifzv0AeITHGNWGoGsu4ZzfhkAyDElKu5OO9JuKvrB4ieraf9bvcGkxrlUfwP)m8cGOymGoSoVfsXWkMmIbb6ETFm3edMzft(8XOPZyLsZwakMBUIbZyYmgwXioYaKUu6qtiTubXG9XGaDV2pgSIjlf9XSJfAIJma5v4JPsu4ZnfhkAyDElKu5OOPiO2cMkk8Xur7hPiRIwJqSne8eg0buIc)BxXHIgwN3cjvok6dQeavUIwClSs)z4farXyaDyDElKIHvmIBHv6GPVVgm16c0H15TqkgwX4hPWbnyb9c(yUIbZyyfdpdfv)z4farXyaDeO71(XCtmy2XMI2psrwfTHJqebuIcFZTIdfnSoVfsQCu0hujaQCfT4wyL(ZWlaIIXa6W68wifdRyoeDEstJuR8XCZvmytr7hPiRIwNrkRlGsuIIgNV1ZwXHcFmvCOOH15TqsLJIMOPOFqu0(rkYQOX5OY5TGIgNBzafDgXGNyqmlqrqgqpbUW2Aw7z7jcE)oSoVfsXWkgGIcosHdAhIopPPrQv(yW6kMJwt3nT9AWMIjZyYNpMmIbXSafbza9e4cBRzTNTNi497W68wifdRyoeDEstJuR8XCtmzftMkACoQTUoOO3YGT8IBVdO2rRDiBQKISkrHFwkou0W68wiPYrrFqLaOYv0IBHv6GPVVgm16c0H15TqkgwXiUfwPVLbB5f3EhqDyDElKIHvm4Cu58wOVLbB5f3EhqTJw7q2ujfzJHvmhcXMi4D7GPVVgm16c0rGUx7hZnXGPI2psrwfnoFRNTsu4JnfhkAyDElKu5OOpOsau5kAXTWk9TmylV427aQdRZBHumSIbpXiUfwPdM((AWuRlqhwN3cPyyfdohvoVf6BzWwEXT3bu7O1oKnvsr2yyftc4zOO64GnbI4DgnfTFKISkAC(wpBLOWNZkou0W68wiPYrr7hPiRIwJqSne8eg0bu0GPcYBUoHzffnN5MIMIGAlyQOWhtLOWNBkou0W68wiPYrrFqLaOYv0IBHv6pdVaikgdOdRZBHumSI5qi2ebVB3WriIaDgTyyftgXKis3WriIaDeqHGNTZBHyYNpMeWZqr1XbBceX7mAXWkMer6gocreORPZyLsZwakMBUIbZyYmgwXCi68KMgPw57jGQoLedwxXKrmVgyTnXrgG8DkFBeQ29TWbFmyDRmgohtMXWkgKxPgGdwP7P03RngSIbZSu0(rkYQOX5B9SvIc)BxXHIgwN3cjvok6dQeavUIoJye3cR019xauZ)3)V2oSoVfsXKpFmiMfOiidOR7O7ncvtydnD)fa18)9)RTdRZBHumzgdRyWtmjI0rmAcdc6iGcbpBN3cXWkMer6gocreOJaDV2pgSIbBXWkMeWZqr1XbBceX7mAXWkMeWZqr1F2fUoJMI2psrwfnoFRNTsuIIobuoJvuCOWhtfhkA)ifzv03RZDfnSoVfsQCuIc)SuCOO9JuKvr)c4wHTIgwN3cjvokrHp2uCOOH15TqsLJIMOPOFqu0(rkYQOX5OY5TGIgNBzafnSaYWSocmGngUIrJupzHuJ3cq6JHtJXChtUXKrmzfdNgZRbwBJT)cetMkACoQTUoOOHfqgM1qGbSTdrNVwiPef(CwXHIgwN3cjvokAIMI(brr7hPiRIgNJkN3ckACULbu0VgyTnXrgG8DkFBeQ29TWbFm3etwkACoQTUoOO)AnSqtCKbikrHp3uCOOH15TqsLJI(GkbqLROtapdfvNY6gG16sr2oc09A)yUjMSu0(rkYQOPSUbyTUuKTDSGVpOef(3UIdfnSoVfsQCu0hujaQCf9lGBf2qQJigmGI2psrwf9XT2MFKISnB9II2wV0wxhu0VaUvydjLOW3CR4qrdRZBHKkhf9bvcGkxrNrm4jgXTWkDD)fa18)9)RTdRZBHum5ZhtIiDdhHic0L6CVwJyYur7hPiRI(4wBZpsr2MTErrBRxARRdk6t6vIcFozfhkAyDElKu5OOpOsau5k6xdS2M4idq(oLVncv7(w4GpMBUIjJy4wmyFmiMfOiidON8NDTgT)qy2ecSDyDElKIjZyyfdpdfv)T1bA(MAP6aDeO71(XCtmuLbBPHaDV2pgwXGake8SDEledRyoeDEstJuR8XG1vmytr7hPiRI(T1bA(MAP6akrH)TrXHIgwN3cjvokA)ifzv0h3AB(rkY2S1lkAB9sBDDqrNiIsu4Jz2vCOOH15TqsLJI2psrwf9XT2MFKISnB9II2wV0wxhu0Pcbhrjk8XetfhkAyDElKu5OOpOsau5kAybKHz9eqvNsIbRRyWKBXWvm4Cu58wOdlGmmRHadyBhIoFTqsr7hPiRI2rhFHMqqiyfLOWhZSuCOO9JuKvr7OJVqtJX(GIgwN3cjvokrHpMytXHI2psrwfTTmylF7wftYqhwrrdRZBHKkhLOWhtoR4qr7hPiRIM3nAeQMGQZ9xrdRZBHKkhLOefTgcoeDExuCOWhtfhkA)ifzv0UMM1SMgPEYQOH15TqsLJsu4NLIdfTFKISkAEIiwi1OSUzqcV1A0eIP1QOH15TqsLJsu4JnfhkAyDElKu5OO9JuKvrR7O7qQrrqTe4cBf9bvcGkxrJ8k1aCWkDpL(ETXGvmyYnfTgcoeDExApCiB6v0Ctjk85SIdfTFKISk6xa3kSv0W68wiPYrjk85MIdfnSoVfsQCu0(rkYQOFBDGMVPwQoGI(GkbqLROrafcE2oVfu0Ai4q05DP9WHSPxrJPsuIIovi4ikou4JPIdfnSoVfsQCu0hujaQCfnqrbhPWbTdrNN00i1kFmyDfdNJHRye3cR0taObO2lixCdqVdRZBHumSIjJysapdfvhhSjqeVZOft(8XKaEgkQ(ZUW1z0IjF(yGfqgM1tavDkjMBUIjlUfdxXGZrLZBHoSaYWSgcmGTDi681cPyYNpg8edohvoVf6FTgwOjoYaKyYmgwXKrm4jgXTWkDW03xdMADb6W68wift(8XCieBIG3TdM((AWuRlqhb6ETFmyftwXKPI2psrwfnS4GLORef(zP4qrdRZBHKkhfnrtr)GOO9JuKvrJZrLZBbfno3Yak6drNN00i1kFpbu1PKyWkgmJjF(yGfqgM1tavDkjMBUIjlUfdxXGZrLZBHoSaYWSgcmGTDi681cPyYNpg8edohvoVf6FTgwOjoYaefnoh1wxhu0mp0OkRfqkrHp2uCOOH15TqsLJI2psrwf9diKlqQXtwO9A1DqrFqLaOYv08muu93whO5BQLQd0z0IHvm4jMer6pGqUaPgpzH2Rv3HwIiDPo3R1iM85JHQmylneO71(XCZvmClM85J5qi2ebVB)beYfi14jl0ET6o0pSDKb8nkKFKISUngSUIjRU5MBXKpFmpHXYxBQBbp14nRbM66AwOdRZBHumSIbpXWZqr1TGNA8M1atDDnl0z0u0hZowOjoYaKxHpMkrHpNvCOOH15TqsLJI(GkbqLROX5OY5TqN5HgvzTakgwXKrm8muuD2vkbBJ36j47V4N7XG1vmyEBIjF(yYig8eJgQiOsmRHiIlfzJHvmVgyTnXrgG8DkFBeQ29TWbFmyDfdNJHRyEbCRWgsDeXGbIjZyYur7hPiRIMY3gHQDFlCWRef(CtXHIgwN3cjvokA)ifzv0u(2iuT7BHdEf9bvcGkxrJZrLZBHoZdnQYAbumSI51aRTjoYaKVt5BJq1UVfo4JbRRyWMI(y2XcnXrgG8k8Xujk8VDfhkAyDElKu5OOpOsau5kACoQCEl0zEOrvwlGIHvmhcXMi4D74GnbI4DeO71(XGvmyMDfTFKISkA4WMuRrdbAOs33Ksu4BUvCOOH15TqsLJI(GkbqLROX5OY5TqN5HgvzTasr7hPiRI215zE2krHpNSIdfnSoVfsQCu0(rkYQO1zKY6cOOpOsau5kACoQCEl0zEOrvwlGIHvmVgyTnXrgG8DkFBeQ29TWbFmxXKLI(y2XcnXrgG8k8Xujk8Vnkou0W68wiPYrrFqLaOYv04Cu58wOZ8qJQSwaPO9JuKvrRZiL1fqjkrrFsVIdf(yQ4qr7hPiRIMY6gG16srwfnSoVfsQCuIc)SuCOOH15TqsLJI2psrwfTUJUdPgfb1sGlSv0hujaQCfnYRudWbR09u67mAXWkMmIrCKbiDP0HMqAPcI5MyoeDEstJuR89eqvNsIHtJbZo3IjF(yoeDEstJuR89eqvNsIbRRyoAnD302RbBkMmv0hZowOjoYaKxHpMkrHp2uCOOH15TqsLJI(GkbqLROrELAaoyLUNsFV2yWkgSL9yW(yqELAaoyLUNsFpXGCPiBmSI5q05jnnsTY3tavDkjgSUI5O10DtBVgSjfTFKISkADhDhsnkcQLaxyRef(CwXHIgwN3cjvokAIMI(brr7hPiRIgNJkN3ckACULbu04jgXTWk9TmylV427aQdRZBHum5ZhdEIrClSshm991GPwxGoSoVfsXKpFmhcXMi4D7GPVVgm16c0rGUx7hZnXWTyW(yYkgongXTWk9eaAaQ9cYf3a07W68wiPOX5O266GIghSjqeVTLbB5f3EhqTdztLuKvjk85MIdfnSoVfsQCu0hujaQCfnEI5fWTcBi1redgigwXKishXOjmiOl15ETgXWkg8etc4zOO64GnbI4DgTyyfdohvoVf64GnbI4TTmylV427aQDiBQKISkA)ifzv04GnbI4krH)TR4qrdRZBHKkhf9bvcGkxrJNyEbCRWgsDeXGbIHvmzedEIjrKUHJqeb6iGcbpBN3cXWkMer6ignHbbDeO71(XGvmCogUIHZXWPXC0A6UPTxd2um5ZhtIiDeJMWGGoc09A)y40yYENBXGvmIJmaPlLo0eslvqmzgdRyehzasxkDOjKwQGyWkgoRO9JuKvrdM((AWuRlGsu4BUvCOOH15TqsLJI(GkbqLROtePJy0ege0L6CVwJyYNpMer6pO913L6CVwdfTFKISk6NDHtjk85KvCOOH15TqsLJI(GkbqLRO5zOO68wcjzzEPJa)iXKpFmuLbBPHaDV2pMBIbBzpM85Jjb8muuDCWMar8oJMI2psrwfTgrkYQef(3gfhkAyDElKu5OOpOsau5k6eWZqr1XbBceX7mAkA)ifzv08wcj1OyqMPef(yMDfhkAyDElKu5OOpOsau5k6eWZqr1XbBceX7mAkA)ifzv08a6b09AnuIcFmXuXHIgwN3cjvok6dQeavUIob8muuDCWMar8oJMI2psrwfnvHaElHKuIcFmZsXHIgwN3cjvok6dQeavUIob8muuDCWMar8oJMI2psrwfTVh4fKBBh3AvIcFmXMIdfnSoVfsQCu0hujaQCfnEI5fWTcBi1DRngwXO7VaOM)V)FTneO71(XCft2v0(rkYQOpU128JuKTzRxu026L266GIgNV1Zwjk8XKZkou0W68wiPYrr7hPiRI2W6PYfc6B6qYT2ISk6dQeavUIob8muuDCWMar8oJMIgOOGJ0wxhu0gwpvUqqFthsU1wKvjk8XKBkou0W68wiPYrr7hPiRI2W6PYfc6B8EYau0hujaQCfDc4zOO64GnbI4DgnfnqrbhPTUoOOnSEQCHG(gVNmaLOWhZBxXHI2psrwfnZdTsa9xrdRZBHKkhLOefDIikou4JPIdfnSoVfsQCu0enf9dII2psrwfnohvoVfu04CldOO1qfbvIznerCPiBmSI51aRTjoYaKVt5BJq1UVfo4JbRyWwmSIjJysePB4ierGoc09A)yUjMdHyte8UDdhHic0tmixkYgt(8XOrQNSqQXBbi9XGvmClMmv04CuBDDqr)3lT2XSJfAgocreqjk8ZsXHIgwN3cjvokAIMI(brr7hPiRIgNJkN3ckACULbu0AOIGkXSgIiUuKngwX8AG12ehzaY3P8TrOA33ch8XGvmylgwXKrmjGNHIQ)SlCDgTyYNpgns9KfsnElaPpgSIHBXKPIgNJARRdk6)EP1oMDSqdXOjmiqjk8XMIdfnSoVfsQCu0enf9dII2psrwfnohvoVfu04CldOOtapdfvhhSjqeVZOfdRyYiMeWZqr1F2fUoJwm5ZhJU)cGA()()12qGUx7hdwXK9yYmgwXKishXOjmiOJaDV2pgSIjlfnoh1wxhu0)9sRHy0egeOef(CwXHIgwN3cjvok6dQeavUIwClSshm991GPwxGoSoVfsXWkg8etc4zOO6gocreOdM((AWuRlqkgwXKis3WriIaDnDgRuA2cqXCZvmygdRyoeInrW72btFFnyQ1fOJaDV2pMBIjRyyfZRbwBtCKbiFNY3gHQDFlCWhZvmygdRyqELAaoyLUNsFV2yWkMBpgwXKis3WriIaDeO71(XWPXK9o3I5MyehzasxkDOjKwQafTFKISkAdhHicOef(CtXHIgwN3cjvok6dQeavUIwClSshm991GPwxGoSoVfsXWkMmIbOOGJu4G2HOZtAAKALpgSUI5O10DtBVgSPyyfZHqSjcE3oy67RbtTUaDeO71(XCtmygdRysePJy0ege0rGUx7hdNgt27ClMBIrCKbiDP0HMqAPcIjtfTFKISkAeJMWGaLOW)2vCOOH15TqsLJIMIGAlyQOWhtfTFKISkAncX2qWtyqhqjk8n3kou0W68wiPYrrFqLaOYv0iGcbpBN3cXWkMdrNN00i1kFpbu1PKyW6kgmJHvmzeJMoJvknBbOyU5kgmJjF(yqGUx7hZnxXi15EtkDigwX8AG12ehzaY3P8TrOA33ch8XG1vmylMmJHvmzedEIbm991GPwxGum5Zhdc09A)yU5kgPo3BsPdXWPXKvmSI51aRTjoYaKVt5BJq1UVfo4JbRRyWwmzgdRyYigXrgG0LshAcPLkigSpgeO71(XKzmyfdNJHvm6(laQ5)7)xBdb6ETFmxXKDfTFKISkAdhHicOef(CYkou0W68wiPYrrtrqTfmvu4JPI2psrwfTgHyBi4jmOdOef(3gfhkAyDElKu5OO9JuKvrB4ieraf9bvcGkxrJNyW5OY5Tq)VxATJzhl0mCeIiqmSIbbui4z78wigwXCi68KMgPw57jGQoLedwxXGzmSIjJy00zSsPzlafZnxXGzm5Zhdc09A)yU5kgPo3BsPdXWkMxdS2M4idq(oLVncv7(w4GpgSUIbBXKzmSIjJyWtmGPVVgm16cKIjF(yqGUx7hZnxXi15EtkDigonMSIHvmVgyTnXrgG8DkFBeQ29TWbFmyDfd2IjZyyftgXioYaKUu6qtiTubXG9XGaDV2pMmJbRyWmRyyfJU)cGA()()12qGUx7hZvmzxrFm7yHM4idqEf(yQef(yMDfhkAyDElKu5OOpOsau5k6xdS2M4idq(yW6kMSIHvmiq3R9J5MyYkgUIjJyEnWABIJma5JbRRy4wmzgdRyakk4ifoODi68KMgPw5JbRRy4SI2psrwf9bv6pzBcORbVOef(yIPIdfnSoVfsQCu0hujaQCfnEIbNJkN3c9)EP1qmAcdcIHvmzedqrbhPWbTdrNN00i1kFmyDfdNJHvmiGcbpBN3cXKpFm4jgPo3R1igwXKrmsPdXGvmyM9yYNpMdrNN00i1kFmyDftwXKzmzgdRyYignDgRuA2cqXCZvmygt(8XGaDV2pMBUIrQZ9Mu6qmSI51aRTjoYaKVt5BJq1UVfo4JbRRyWwmzgdRyYig8edy67RbtTUaPyYNpgeO71(XCZvmsDU3KshIHtJjRyyfZRbwBtCKbiFNY3gHQDFlCWhdwxXGTyYmgwXioYaKUu6qtiTubXG9XGaDV2pgSIHZkA)ifzv0ignHbbkrHpMzP4qrdRZBHKkhfTFKISkAeJMWGaf9bvcGkxrJNyW5OY5Tq)VxATJzhl0qmAcdcIHvm4jgCoQCEl0)7LwdXOjmiigwXauuWrkCq7q05jnnsTYhdwxXW5yyfdcOqWZ25TqmSIjJy00zSsPzlafZnxXGzm5Zhdc09A)yU5kgPo3BsPdXWkMxdS2M4idq(oLVncv7(w4GpgSUIbBXKzmSIjJyWtmGPVVgm16cKIjF(yqGUx7hZnxXi15EtkDigonMSIHvmVgyTnXrgG8DkFBeQ29TWbFmyDfd2IjZyyfJ4idq6sPdnH0sfed2hdc09A)yWkgoROpMDSqtCKbiVcFmvIcFmXMIdfnSoVfsQCu0hujaQCf9RbwBtCKbiFmxXGzmSIbOOGJu4G2HOZtAAKALpgSUIjJyoAnD302RbBkgSpgmJjZyyfdcOqWZ25TqmSIbpXaM((AWuRlqkgwXGNysapdfv)zx46mAXWkgD)fa18)9)RTHaDV2pMRyYEmSIrCKbiDP0HMqAPcIb7Jbb6ETFmyfdNv0(rkYQOpOs)jBtaDn4fLOWhtoR4qr7hPiRI(bTVEfnSoVfsQCuIsuIIghG(ISk8Zk7zLDmZctSPOXRJ2AnEfnNeSl2b)Bn(zZBjMy4GnetPRrqsmueumMdoFRNT5edc4KYuiifZt0HyCgHO7cKI5W2xd47bgz7AHyW8wIH7jloajqkgZbXSafbza9BR5eJqIXCqmlqrqgq)22H15TqYCIjJSmnZEGr2UwiMB)wIH7jloajqkgZbXSafbza9BR5eJqIXCqmlqrqgq)22H15TqYCIjdmnnZEGrGbNeSl2b)Bn(zZBjMy4GnetPRrqsmueumMtcOCgRyoXGaoPmfcsX8eDigNri6UaPyoS91a(EGr2UwigSDlXW9KfhGeifdDPZ9X8MTIBAm3kIriXKTz8ysfU6lYgdrdqUqqXKrUzgtgyAAM9aJSDTqmCY3smCpzXbibsXyoiMfOiidOFBnNyesmMdIzbkcYa632oSoVfsMtmzGPPz2dmcm4KGDXo4FRXpBElXedhSHykDncsIHIGIXCseXCIbbCszkeKI5j6qmoJq0DbsXCy7Rb89aJSDTqmC(wIH7jloajqkgZbm991GPwxGu)2AoXiKymNeWZqr1VTDW03xdMADbsMtmzGPPz2dmcmU16AeKaPym3X4hPiBm26LVhyOOFn4OWplUDBu0AicvzbfT5Jb7(V)FTUuKngSdXGbcmmFmCc4a68akgmXMjXKv2Zk7bgbgMpMSbbhKIXC16gG16sr2yYG7TGVpKzmmAXuBmAOIGkXSyEsmLedEjm2umlrIXaKy4zqfKIHhyxBkMxa3kSJXpsr2Vhyeyy(y4oMchgbsXWdueeeZHOZ7sm8GrTFpgS75aAYhZswSNTJ0PySX4hPi7hdzTM1dm8JuK97Ai4q05D5Y10SM10i1t2ad)ifz)UgcoeDEx46kxEIiwi1OSUzqcV1A0eIP1gy4hPi731qWHOZ7cxx5Q7O7qQrrqTe4cBt0qWHOZ7s7Hdzt)f3mPOUqELAaoyLUNsFVwSWKBbg(rkY(DneCi68UW1vUVaUvyhy4hPi731qWHOZ7cxx5(26anFtTuDat0qWHOZ7s7Hdzt)fMMuuxiGcbpBN3cbgbgMpgUJPWHrGumaoazwmsPdXiSHy8JqqXuFmooVSoVf6bg(rkY(x3RZ9adZhd2bEbCRWoMIkgnY)fVfIjJLedog7ciN3cXalOxWhtTXCi68UKzGHFKISpxx5(c4wHDGHFKISpxx5IZrLZBbtwxhUGfqgM1qGbSTdrNVwizco3YaxWcidZ6iWawU0i1twi14TaKEo1CFRiJS40xdS2gB)fiZad)ifzFUUYfNJkN3cMSUoC91AyHM4idqmbNBzGRxdS2M4idq(oLVncv7(w4G)MScm8JuK956kxkRBawRlfzBhl47dMuuxjGNHIQtzDdWADPiBhb6ET)nzfy4hPi7Z1vUh3AB(rkY2S1lMSUoC9c4wHnKmPOUEbCRWgsDeXGbcm8JuK956k3JBTn)ifzB26ftwxhUoP3KI6kd8iUfwPR7VaOM)V)FTDyDElKYNprKUHJqeb6sDUxRrMbg(rkY(CDL7BRd08n1s1bmPOUEnWABIJma57u(2iuT7BHd(BUYGBypIzbkcYa6j)zxRr7peMnHaBMS4zOO6VToqZ3ulvhOJaDV2)gQYGT0qGUx7Zcbui4z78wG1HOZtAAKALhRlSfy4hPi7Z1vUh3AB(rkY2S1lMSUoCLisGHFKISpxx5ECRT5hPiBZwVyY66WvQqWrcm8JuK956kxhD8fAcbHGvmPOUGfqgM1tavDkbRlm5gx4Cu58wOdlGmmRHadyBhIoFTqkWWpsr2NRRCD0XxOPXyFiWWpsr2NRRCTLbB5B3Qysg6Wkbg(rkY(CDLlVB0iunbvN7FGrGH5JH7jeBIG39dm8JuK97N0FrzDdWADPiBGH5J5wtfJNsFmocIHrZKy(T0Gye2qmKfIbVLWoglbVWlXWbhCIEm3QFig8Yg2ysMvRrmu(lakgHTVXW9C3ysavDkjgckg8wcBcJeJVMfd3ZD7bg(rkY(9t656kxDhDhsnkcQLaxyBYXSJfAIJma5VW0KI6c5vQb4Gv6Ek9DgnwzioYaKUu6qtiTub3Ci68KMgPw57jGQoLWPy25w(8hIopPPrQv(EcOQtjyDD0A6UPTxd2uMbgMpMBnvmljgpL(yWBzTXKkig8wc7AJrydXSGPsmyl7VjXW8qmzdkormKngEY)XG3sytyKy81Sy4EUBpWWpsr2VFspxx5Q7O7qQrrqTe4cBtkQlKxPgGdwP7P03RflSLDSh5vQb4Gv6Ek99edYLISSoeDEstJuR89eqvNsW66O10DtBVgSPadZht2c2eiIhJLyuh3gZHSPskY62pgE)HumKnMddcbReZRbNad)ifz)(j9CDLlohvoVfmzDD4chSjqeVTLbB5f3EhqTdztLuK1eCULbUWJ4wyL(wgSLxC7Da1H15TqkFE8iUfwPdM((AWuRlqhwN3cP85peInrW72btFFnyQ1fOJaDV2)gUH9zXPIBHv6ja0au7fKlUbO3H15TqkWWpsr2VFspxx5Id2eiIBsrDHNxa3kSHuhrmyawjI0rmAcdc6sDUxRbl8KaEgkQooytGiENrJfohvoVf64GnbI4TTmylV427aQDiBQKISbgMpgUJPVVgm16cedEzdBmlrI5fWTcBifJVPy4jc7yWomAcdcIX3umzthHiceJJGyy0IHIGIXswJyGLWyWUhy4hPi73pPNRRCbtFFnyQ1fWKI6cpVaUvydPoIyWaSYapjI0nCeIiqhbui4z78wGvIiDeJMWGGoc09AFS4mxCMtpAnD302RbBkF(er6ignHbbDeO71(CA27CdlXrgG0LshAcPLkitwIJmaPlLo0eslvawCoWWpsr2VFspxx5(SlCMuuxjI0rmAcdc6sDUxRr(8jI0Fq7RVl15ETgbg(rkY(9t656kxnIuK1KI6INHIQZBjKKL5Loc8JKppvzWwAiq3R9VbBzpF(eWZqr1XbBceX7mAbg(rkY(9t656kxElHKAumiZmPOUsapdfvhhSjqeVZOfy4hPi73pPNRRC5b0dO71AysrDLaEgkQooytGiENrlWWpsr2VFspxx5sviG3sijtkQReWZqr1XbBceX7mAbg(rkY(9t656kxFpWli32oU1AsrDLaEgkQooytGiENrlWWpsr2VFspxx5ECRT5hPiBZwVyY66WfoFRNTjf1fEEbCRWgsD3AzP7VaOM)V)FTneO71(xzpWWpsr2VFspxx5Y8qReq3eGIcosBDD4YW6PYfc6B6qYT2ISMuuxjGNHIQJd2eiI3z0cm8JuK97N0Z1vUmp0kb0nbOOGJ0wxhUmSEQCHG(gVNmatkQReWZqr1XbBceX7mAbgMpgobq5mwjgk3A59Z9yOiOyyEN3cXucO)3sm3QFigYgZHqSjcE3EGHFKISF)KEUUYL5HwjG(hyeyy(y4efcosmjx3nGyC(YwsbFGH5JH7S4GLOhJlXWzUIjdUXvm4Te2XWjOZmgUN72J5wRRdPYfWAwmKnMS4kgXrgG8MedElHDmzlytGiUjXqqXG3syhdh5yUCmeHnGWB9qm41ljgkckMNOdXalGmmRhd21(KyWRxsmfvmChtFJyoeDEsm1hZHOxRrmmA9ad)ifz)EQqWrUGfhSeDtkQlGIcosHdAhIopPPrQvESU4mxIBHv6ja0au7fKlUbO3H15TqIvgjGNHIQJd2eiI3z0YNpb8muu9NDHRZOLppSaYWSEcOQtj3CLf34cNJkN3cDybKHzneyaB7q05Rfs5ZJhCoQCEl0)AnSqtCKbizYkd8iUfwPdM((AWuRlqhwN3cP85peInrW72btFFnyQ1fOJaDV2hRSYmWWpsr2VNkeCeUUYfNJkN3cMSUoCX8qJQSwazco3YaxhIopPPrQv(EcOQtjyHz(8WcidZ6jGQoLCZvwCJlCoQCEl0HfqgM1qGbSTdrNVwiLppEW5OY5Tq)R1WcnXrgGey4hPi73tfcocxx5(ac5cKA8KfAVwDhm5y2XcnXrgG8xyAsrDXZqr1FBDGMVPwQoqNrJfEseP)ac5cKA8KfAVwDhAjI0L6CVwJ85Pkd2sdb6ET)nxClF(dHyte8U9hqixGuJNSq71Q7q)W2rgW3Oq(rkY6wSUYQBU5w(8pHXYxBQBbp14nRbM66AwOdRZBHel8WZqr1TGNA8M1atDDnl0z0cmmFmMR(gdHkgZfBHd(yCjgmVnCfZl(5(hdHkgZLQuc2yYX6j4JHGIXn8AFjgoZvmIJma57bg(rkY(9uHGJW1vUu(2iuT7BHdEtkQlCoQCEl0zEOrvwlGyLbpdfvNDLsW24TEc((l(5owxyEBYNpd8OHkcQeZAiI4srwwVgyTnXrgG8DkFBeQ29TWbpwxCMRxa3kSHuhrmyGmZmWW8XyU6BmeQymxSfo4JriX4AAwZIHtaEYAwmCxs9KnMIkMA9Ju4GyiBm(AwmIJmajgxIbBXioYaKVhy4hPi73tfcocxx5s5BJq1UVfo4n5y2XcnXrgG8xyAsrDHZrLZBHoZdnQYAbeRxdS2M4idq(oLVncv7(w4GhRlSfy4hPi73tfcocxx5ch2KAnAiqdv6(MmPOUW5OY5TqN5HgvzTaI1HqSjcE3ooytGiEhb6ETpwyM9ad)ifz)EQqWr46kxxNN5zBsrDHZrLZBHoZdnQYAbuGH5JHdNh7ZgmszDbIriX4AAwZIHtaEYAwmCxs9KngxIjRyehzaYhy4hPi73tfcocxx5QZiL1fWKJzhl0ehzaYFHPjf1fohvoVf6mp0OkRfqSEnWABIJma57u(2iuT7BHd(RScm8JuK97PcbhHRRC1zKY6cysrDHZrLZBHoZdnQYAbuGrGH5JHt46UbedbhGIrkDigNVSLuWhyy(yY2LEjXKnDeIiWhdzJzjl2RHkDKJmlgXrgG8XqrqXiSHy0qfbvIzXGiIlfzJPOIHBCfdVfG0hJJGyClc8KzXWOfy4hPi73te5cNJkN3cMSUoC93lT2XSJfAgocreWeCULbU0qfbvIznerCPilRxdS2M4idq(oLVncv7(w4GhlSXkJer6gocreOJaDV2)MdHyte8UDdhHic0tmixkYMpVgPEYcPgVfG0Jf3YmWW8XKTl9sIb7WOjmi4JHSXSKf71qLoYrMfJ4idq(yOiOye2qmAOIGkXSyqeXLISXuuXWnUIH3cq6JXrqmUfbEYSyy0cm8JuK97jIW1vU4Cu58wWK11HR)EP1oMDSqdXOjmiWeCULbU0qfbvIznerCPilRxdS2M4idq(oLVncv7(w4GhlSXkJeWZqr1F2fUoJw(8AK6jlKA8waspwClZadZht2U0ljgSdJMWGGpMIkMSfSjqeNlA2fUCZg(lakgS7)()1gt9XWOfJVPyWledBhhetwCfZdhYM(ySaLedzJrydXGDy0egeedNGWrGHFKISFpreUUYfNJkN3cMSUoC93lTgIrtyqGj4CldCLaEgkQooytGiENrJvgjGNHIQ)SlCDgT8519xauZ)3)V2gc09AFSYEMSsePJy0ege0rGUx7JvwbgMpgAn4uUnMSPJqebIX3umyhgnHbbX8GWOfJgQiOyesmChtFFnyQ1fiMJ)sGHFKISFpreUUY1WriIaMuuxIBHv6GPVVgm16c0H15TqIfEatFFnyQ1fi1nCeIiaRer6gocreORPZyLsZwa6MlmzDieBIG3TdM((AWuRlqhb6ET)nzX61aRTjoYaKVt5BJq1UVfo4VWKfYRudWbR09u671I1TZkrKUHJqeb6iq3R950S352nIJmaPlLo0eslvqGHFKISFpreUUYfXOjmiWKI6sClSshm991GPwxGoSoVfsSYaOOGJu4G2HOZtAAKALhRRJwt3nT9AWMyDieBIG3TdM((AWuRlqhb6ET)nyYkrKoIrtyqqhb6ETpNM9o3UrCKbiDP0HMqAPcYmWW8XKnDeIiqmmA3bqZKyC7tIrqf8XiKyyEiMsIX)y8yEn4uUngdybKleumueumcBigR)smCp3ngEGIGGy8yOQTE2akWWpsr2VNicxx5Qri2gcEcd6aMqrqTfmvUWmWWpsr2VNicxx5A4ieratkQleqHGNTZBbwhIopPPrQv(EcOQtjyDHjRm00zSsPzlaDZfM5ZJaDV2)MlPo3BsPdSEnWABIJma57u(2iuT7BHdESUWwMSYapGPVVgm16cKYNhb6ET)nxsDU3Ksh40Sy9AG12ehzaY3P8TrOA33ch8yDHTmzLH4idq6sPdnH0sfG9iq3R9ZeloZs3Fbqn)F))ABiq3R9VYEGHFKISFpreUUYvJqSne8eg0bmHIGAlyQCHzGHFKISFpreUUY1WriIaMCm7yHM4idq(lmnPOUWdohvoVf6)9sRDm7yHMHJqebyHake8SDElW6q05jnnsTY3tavDkbRlmzLHMoJvknBbOBUWmFEeO71(3Cj15EtkDG1RbwBtCKbiFNY3gHQDFlCWJ1f2YKvg4bm991GPwxGu(8iq3R9V5sQZ9Mu6aNMfRxdS2M4idq(oLVncv7(w4GhRlSLjRmehzasxkDOjKwQaShb6ETFMyHzwS09xauZ)3)V2gc09A)RShyy(y4EuP)KngoaDn4LyiBm6mwP0SqmIJma5JXLy4mxXW9C3yWlByJbXSBTgXqyKyQnMS(yYGrlgHedNJrCKbiFMXqqXGTpMm4gxXioYaKpZad)ifz)EIiCDL7bv6pzBcORbVysrD9AG12ehzaYJ1vwSqGUx7FtwCLXRbwBtCKbipwxCltwaffCKch0oeDEstJuR8yDX5adZhJ5ca0IHrlgSdJMWGGyCjgoZvmKng3AJrCKbiFmzGx2WgJTWvRrmwYAedSegd2X4BkMLiX8RR9SjsMbg(rkY(9er46kxeJMWGatkQl8GZrLZBH(FV0AignHbbSYaOOGJu4G2HOZtAAKALhRloZcbui4z78wiFE8i15ETgSYqkDalmZE(8hIopPPrQvESUYkZmzLHMoJvknBbOBUWmFEeO71(3Cj15EtkDG1RbwBtCKbiFNY3gHQDFlCWJ1f2YKvg4bm991GPwxGu(8iq3R9V5sQZ9Mu6aNMfRxdS2M4idq(oLVncv7(w4GhRlSLjlXrgG0LshAcPLka7rGUx7JfNdm8JuK97jIW1vUignHbbMCm7yHM4idq(lmnPOUWdohvoVf6)9sRDm7yHgIrtyqal8GZrLZBH(FV0AignHbbSakk4ifoODi68KMgPw5X6IZSqafcE2oVfyLHMoJvknBbOBUWmFEeO71(3Cj15EtkDG1RbwBtCKbiFNY3gHQDFlCWJ1f2YKvg4bm991GPwxGu(8iq3R9V5sQZ9Mu6aNMfRxdS2M4idq(oLVncv7(w4GhRlSLjlXrgG0LshAcPLka7rGUx7JfNdmmFmCpQ0FYgdhGUg8smKngAoIPOIP2y08nb61jgFtXusm4TS2ysKySW)XKCD3aIry7BmCNfhSe9ysmqmcjgoYj3Sb2nWWpsr2VNicxx5EqL(t2Ma6AWlMuuxVgyTnXrgG8xyYcOOGJu4G2HOZtAAKALhRRmoAnD302RbBc7XmtwiGcbpBN3cSWdy67RbtTUajw4jb8muu9NDHRZOXs3Fbqn)F))ABiq3R9VYolXrgG0LshAcPLka7rGUx7JfNdm8JuK97jIW1vUpO91hyeyy(yOfWTcBifd29ifz)adZhd(Lb7xC7DafdzJbBCClXW9Os)jBmCa6AWlbg(rkY(9xa3kSH01bv6pzBcORbVysrDjUfwPVLbB5f3EhqDyDElKy9AG12ehzaYJ1f2yDi68KMgPw5X6IZSehzasxkDOjKwQaShb6ETpw3EGH5Jb)YG9lU9oGIHSXGjh3sm0RR9SjsmyhgnHbbbg(rkY(9xa3kSHexx5Iy0egeysrDjUfwPVLbB5f3EhqDyDElKyDi68KMgPw5X6IZSehzasxkDOjKwQaShb6ETpw3EGH5JHMHxaefJbClXGD10SMfdbfd2bOqWZog8wc7y4zOOGumzthHic8bg(rkY(9xa3kSHexx5Qri2gcEcd6aMqrqTfmvUWmWWpsr2V)c4wHnK46kxdhHicyYXSJfAIJma5VW0KI6sClSs)z4farXyaDyDElKyLbc09A)BWmR8510zSsPzlaDZfMzYsCKbiDP0HMqAPcWEeO71(yLvGH5JHMHxaefJbedxXWDm9nIHSXGjh3smyhGcbp7yYMocreigxIrydXaBkgcvmVaUvyhJqIXaKy0DtJjXGCPiBm8afbbXWDm991GPwxGad)ifz)(lGBf2qIRRC1ieBdbpHbDatOiO2cMkxygy4hPi73FbCRWgsCDLRHJqebmPOUe3cR0FgEbqumgqhwN3cjwIBHv6GPVVgm16c0H15TqILFKch0Gf0l4VWKfpdfv)z4farXyaDeO71(3GzhBbg(rkY(9xa3kSHexx5QZiL1fWKI6sClSs)z4farXyaDyDElKyDi68KMgPw5V5cBbgbgMpMSLV1ZoWW8XyUwB9SJbVLWogD30y4EUBmueum4xgSLxC7DazsmmRf(pgMVwJy4eGlSTMfdnBprW7hy4hPi73X5B9SVW5OY5TGjRRdxBzWwEXT3bu7O1oKnvsrwtW5wg4kd8GywGIGmGEcCHT1S2Z2te8(Sakk4ifoODi68KMgPw5X66O10DtBVgSPmZNpdeZcueKb0tGlSTM1E2EIG3N1HOZtAAKAL)MSYmWW8XKT8TE2XG3syhd3X03igUIb)YGT8IBVdOBjMSHBAPZOhd3ZDJX3umChtFJyqGNmlgkckMfmvIjBY9CIad)ifz)ooFRNnxx5IZ36zBsrDjUfwPdM((AWuRlqhwN3cjwIBHv6BzWwEXT3buhwN3cjw4Cu58wOVLbB5f3EhqTJw7q2ujfzzDieBIG3TdM((AWuRlqhb6ET)nygyy(yYw(wp7yWBjSJb)YGT8IBVdOy4kg8jXWDm9nULyYgUPLoJEmCp3ngFtXKTGnbI4XWOfy4hPi73X5B9S56kxC(wpBtkQlXTWk9TmylV427aQdRZBHel8iUfwPdM((AWuRlqhwN3cjw4Cu58wOVLbB5f3EhqTJw7q2ujfzzLaEgkQooytGiENrlWWpsr2VJZ36zZ1vUAeITHGNWGoGjueuBbtLlmnbmvqEZ1jmRCXzUfy4hPi73X5B9S56kxC(wpBtkQlXTWk9NHxaefJb0H15TqI1HqSjcE3UHJqeb6mASYirKUHJqeb6iGcbpBN3c5ZNaEgkQooytGiENrJvIiDdhHic010zSsPzlaDZfMzY6q05jnnsTY3tavDkbRRmEnWABIJma57u(2iuT7BHdESUvY5mzH8k1aCWkDpL(ETyHzwbgMpMSLV1Zog8wc7yYg(lakgS7)(x7Ted(KyEbCRWogFtXSKy8Ju4GyYgy3y4zOOmjgSdJMWGGywIetTXGake8SJb5RbysmjguTgXKTGnbI4CXrobg(rkY(DC(wpBUUYfNV1Z2KI6kdXTWkDD)fa18)9)RTdRZBHu(8iMfOiidOR7O7ncvtydnD)fa18)9)Rntw4jrKoIrtyqqhbui4z78wGvIiDdhHic0rGUx7Jf2yLaEgkQooytGiENrJvc4zOO6p7cxNrtjkrPa]] )

end