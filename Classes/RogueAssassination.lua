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


    spec:RegisterPack( "Assassination", 20201123, [[defeicqiQQ6riv0LqQeztOOpjQqJcL0PqjwfsL6vOuMfLKBHsf7sWVufmmvPCmvjltuLNHsvtturxJQsTnvr03evqJJQs05evG1HubVdLkPAEIQ6EiX(qQ6FuvsLdIujTqvr9qvrQjIujCrQkjBKQsiFuvK0irPskNKQsWkrHEjsLOMPQiXnPQKYoPKAOQIqlfPc9uu1uPQYvPQKQ2QQi4ROujzSOuj2Rq)vKbRYHjTyu5XkzYuCzWMvQplkJgPCAfRMQsOEnky2u52uLDl1VHA4uQJJsLA5iEoKPtCDv12rsFxuPXtvX5vfA9Qs18Pe7xYXxr)I8gvGO159wEV96vESp8Y3((jZ7jJ8YJ2qK3wxmOzqKVvpiYtxrifHMwLb3rEB9rhwnr)I8i8NSGipnrSr0HhEiBeAFUWc79aA8(ovgCVi6wEanERhI8C)Xj(cDKlYBubIwN3B592Rx5X(WlF77NmViV(fAysKNF8E6ipTXyGoYf5naAf5PZ6ORiKIqtRYG76OJ4SpumsN1znMk4XbK6YJ9wvxEVL3BrE3Geu0Vipsa1j0at0VO1VI(f5Hw5CGj(CKFrgbiJg5f1bTe6jJMGe1XaqcqRCoWuhZ6wypoCYgpTGQJEk1LZ6ywNOKmqcY4bjbNmduh7uhb80Pr1rFDpzKxxYG7ip5BlFceLO15f9lYdTY5at85i)gtsn4JeT(vKxxYG7iVng7seaH)KfeLO1Sp6xKhALZbM4Zr(fzeGmAKxFhiJabenc(Batc93B8sLb3bOvohyQJzDC)9oG(Ccq2)mi8TRJzDC)9oG(Ccq2)miqapDAuD5x3Ra7RJzD(xhcL4(7nyI86sgCh5ZucblquIwNZOFrEOvohyIph53ysQbFKO1VI86sgCh5TXyxIai8NSGOeT23r)I8qRCoWeFoYRlzWDKptjeSar(fzeGmAKxuh0sa95eGS)zqaALZbM6ywhR1rapDAuD5x3R8QZIL6S9(ozSDdqQlFk19QowQJzDIsYajiJhKeCYmqDStDeWtNgvh91LxKF94YbjrjzGGIw)kkrRFYOFrEOvohyIph5xKraYOrErDqlb0NtaY(NbbOvohyQJzD67azeiGOrWFdysO)EJxQm4oaTY5atDmRZ)6myjq(2YNabzwmmDwDmRJQsgLZbb00zoijkjdKiVUKb3rEY3w(eikrRZHr)I8qRCoWeFoYVXKud(irRFf51Lm4oYBJXUebq4pzbrjATVm6xKhALZbM4ZrEDjdUJ8zkHGfiYViJaKrJ8I6GwcOpNaK9pdcqRCoWuhZ603bYiqarJG)gWKq)9gVuzWDaALZbM6ywhR1PlzOcjObVbq1rFDVQZIL68VorDqlbWhK2z)PvbcqRCoWuhl1XSorjzGeKXdscozgOo6RJaE60O6ywhR1rapDAuD5x3lFzDwSuN)1HqjU)EdM6yjYVEC5GKOKmqqrRFfLO15GOFrEOvohyIph53ysQbFKO1VI86sgCh5TXyxIai8NSGOeT(1Br)I8qRCoWeFoYViJaKrJ8I6GwcOpNaK9pdcqRCoWuhZ6e1bTeaFqAN9NwfiaTY5atDmRtxYqfsqdEdGQJsDVQJzDC)9oG(Ccq2)miqapDAuD5x3Ra7J86sgCh5ZucblquIsKhqiOxak6x06xr)I8qRCoWeFoYViJaKrJ8qdKShdY4bjbN8uFQJ(6EvhZ68VodW937avOnGiA4BxhZ6yTo)RZGLWc3lOfIkGjTDQhK4(KoiZIHPZQJzD(xNUKb3HfUxqlevatA7upimDA7MmAsDwSu3(7CjcSOPKmijJhux(1LTmbp1N6yjYRlzWDKFH7f0crfWK2o1dIs068I(f5Hw5CGj(CKFrgbiJg5na3FVduH2aIOHVDDmRJ16ma3FVdzkHGfia(G0o7pTkGPolwQZaC)9oGOnudF76yw3c7XHt24PfuWa7znsD5tPUx1zXsDgG7V3bQqBar0ab80Pr1LpL6E9wDSuNfl1TNmAsIaE60O6YNsDVElYRlzWDKNZHXMeENeAqcAW7XOeTM9r)I8qRCoWeFoYViJaKrJ8lm2zW52bQqBar0ab80Pr1LFDSVolwQZaC)9oqfAdiIg(21zXsD7jJMKiGNonQU8RJ9Vf51Lm4oYN9vIz0oH3j9DGGfArjADoJ(f5Hw5CGj(CKFrgbiJg53omMuhR1XAD7jJMKiGNonQo2Po2)wDSu3d1PlzWDAHXodo3UowQJ(62omMuhR1XAD7jJMKiGNonQo2Po2)wDStDlm2zW52bQqBar0ab80Pr1XsDpuNUKb3Pfg7m4C76yjYRlzWDKp7ReZODcVt67abl0Is0AFh9lYdTY5at85i)ImcqgnYJSbNljkjdeuyRDcVtm0dvavh9uQlV6SyPoIoMeqfAjOgdkmDD0x3t(wDmRdAGK9yD5xxo8TiVUKb3r(nE9rGjPVdKrGehOErjA9tg9lYdTY5at85i)ImcqgnYJSbNljkjdeuyRDcVtm0dvavh9uQlV6SyPoIoMeqfAjOgdkmDD0x3t(wKxxYG7iV9Nm7hNolX5uKeLO15WOFrEOvohyIph5xKraYOrEU)EhiWIbhGqPnMSGW3UolwQJ7V3bcSyWbiuAJjliTW)wasaj6IH6YVUxVf51Lm4oYl0G0V5W)2K2yYcIs0AFz0ViVUKb3rEYyB7G00jKTUGip0kNdmXNJs06Cq0ViVUKb3r(CXeNHkmDIaiCR9cI8qRCoWeFokrRF9w0Vip0kNdmXNJ8lYiaz0ip0aj7X6YVoF)wDmRZ)6wySZGZTduH2aIOHVDKxxYG7iVh4HjpMW7K7VgtYqa1dfLO1VEf9lYdTY5at85iVUKb3rEcO2tNL2o1dqr(fzeGmAKxusgibz8GKGtMbQl)6Ef8DDwSuhR1XADIsYajqduNqlyVK6OVoF5B1zXsDIsYajqduNqlyVK6YNsD59wDSuhZ6yToDjdvibn4naQok19QolwQtusgibz8GKGtMbQJ(6Ylhuhl1XsDwSuhR1jkjdKGmEqsWj7LKY7T6OVo2)wDmRJ160LmuHe0G3aO6Ou3R6SyPorjzGeKXdscozgOo6RlN5SowQJLi)6XLdsIsYabfT(vuIsK3aB97KOFrRFf9lYRlzWDKNHzXqKhALZbM4ZrjADEr)I86sgCh5rcOoHwKhALZbM4ZrjAn7J(f5Hw5CGj(CKhBh5rGe51Lm4oYtvjJY5Gipv19Hip0aj7XabYGUo2QZgpiCdMeNdadQo6UUCyDpuhR1LxD0DDiBW5s0uKa1XsKNQssT6brEObs2JjcKbDAH94MgmrjADoJ(f5Hw5CGj(CKhBh5rGe51Lm4oYtvjJY5Gipv19HipYgCUKOKmqqHT2j8oXqpubuD5xxErEQkj1Qhe5rtN5GKOKmqIs0AFh9lYdTY5at85i)ImcqgnYJeqDcnWei4Spe51Lm4oYVuNlPlzWDYnijY7gKKA1dI8ibuNqdmrjA9tg9lYdTY5at85i)ImcqgnYZAD(xNOoOLGNIeGKuesrOPdqRCoWuNfl1zWsitjeSabzwmmDwDSe51Lm4oYVuNlPlzWDYnijY7gKKA1dI8ldkkrRZHr)I8qRCoWeFoYViJaKrJ8iBW5sIsYabf2ANW7ed9qfq1LpL6yToFxh7uh53WgtYGGrr0MolHw4FBiGlaS7)yBdM6yPoM1X937aYnliPTjzMfeiGNonQU8RBpz0Keb80Pr1XSocSjaIMY5G6yw3c7XHt24PfuD0tPo2h51Lm4oYJCZcsABsMzbrjATVm6xKhALZbM4ZrEDjdUJ8l15s6sgCNCdsI8UbjPw9GiVblrjADoi6xKhALZbM4ZrEDjdUJ8l15s6sgCNCdsI8UbjPw9GiVziWsIs06xVf9lYdTY5at85i)ImcqgnYdnqYEmyG9SgPo6Pu3lFxhB1rvjJY5Ga0aj7XebYGoTWECtdMiVUKb3rELS0gscMqGwIs06xVI(f51Lm4oYRKL2qY(7qqKhALZbM4ZrjA9R8I(f51Lm4oY7MmAck5l(BY8GwI8qRCoWeFokrRFX(OFrEDjdUJ8CAwcVtczwmGI8qRCoWeFokrjYBtGf2JtLOFrRFf9lYRlzWDKxTTDpMSXdc3rEOvohyIphLO15f9lYdTY5at85iVUKb3rEpLWaysBmjzavOf5xKraYOrEIoMeqfAjOgdkmDD0x3lFh5TjWc7XPscblCBqrEFhLO1Sp6xKxxYG7ipsa1j0I8qRCoWeFokrRZz0Vip0kNdmXNJ86sgCh5rUzbjTnjZSGi)ImcqgnYtGnbq0uohe5TjWc7XPscblCBqr(xrjATVJ(f5Hw5CGj(CKVvpiYRVJOPefL24ws4DYgNlqI86sgCh513r0uIIsBClj8ozJZfirjA9tg9lYdTY5at85i)ImcqgnYlQdAja(G0o7pTkqaALZbMiVUKb3r(SVsmJ2j8oPVdeSqlkrjYBgcSKOFrRFf9lYdTY5at85i)ImcqgnYd7nSKHkKwypoCYgpTGQJEk1LZ6yRorDqlbda2ajHeIkAg4fGw5CGPoM1XADgG7V3bQqBar0W3UolwQZaC)9oGOnudF76SyPoObs2JbdSN1i1LpL6YZ31XwDuvYOCoianqYEmrGmOtlSh30GPolwQZ)6OQKr5CqanDMdsIsYaPowQJzDSwN)1jQdAja(G0o7pTkqaALZbM6SyPUfg7m4C7a4ds7S)0Qabc4PtJQJ(6YRowI86sgCh5HMk0yVOeToVOFrEOvohyIph5X2rEeirEDjdUJ8uvYOCoiYtvDFiYVWEC4KnEAbfmWEwJuh919QolwQdAGK9yWa7znsD5tPU88DDSvhvLmkNdcqdKShteid60c7XnnyQZIL68VoQkzuoheqtN5GKOKmqI8uvsQvpiY)rqApohqIs0A2h9lYdTY5at85iVUKb3rEeqiQaMehUHeYEyaI8lYiaz0ip3FVdi3SGK2MKzwq4BxhZ68VodwciGqubmjoCdjK9WaKmyjiZIHPZQZIL62tgnjrapDAuD5tPoFxNfl1TWyNbNBhqaHOcysC4gsi7HbiSOPKmaL2eDjdUvxD0tPU8c5qFxNfl1HWFh30MGdutI7Xe4J6z7Ga0kNdm1XSo)RJ7V3bhOMe3JjWh1Z2bHVDKF94YbjrjzGGIw)kkrRZz0Vip0kNdmXNJ8lYiaz0ipvLmkNdcFeK2JZbK6ywN(oqgbcWIgE6SeNtnakaTY5atDmRdzdoxsusgiOWw7eENyOhQaQo6PuxE1XwDSwNb4(7DGk0gqen8TRJURJ16EvhB1XAD67azeialA4PZsCo1aOarBgQJsDVQJL6yPowI86sgCh53ANW7ed9qfqrjATVJ(f5Hw5CGj(CKFrgbiJg5PQKr5Cq4JG0ECoGuhZ6yToU)EhOngd0joNAauaj6IH6ONsDVYb1zXsDSwN)1ztgmzKhteSOYG76ywhYgCUKOKmqqHT2j8oXqpubuD0tPUCwhB1XAD67azeiyWFohKmyeeiAZqD0xxE1XsDSvhsa1j0atGGZ(qDSuhlrEDjdUJ8BTt4DIHEOcOOeT(jJ(f5Hw5CGj(CKxxYG7i)w7eENyOhQakYViJaKrJ8uvYOCoi8rqApohqQJzDiBW5sIsYabf2ANW7ed9qfq1rpL6yFKF94YbjrjzGGIw)kkrRZHr)I8qRCoWeFoYViJaKrJ8uvYOCoi8rqApohqQJzDlm2zW52bQqBar0ab80Pr1rFDVElYRlzWDKhw0WtNLiGnz802eLO1(YOFrEOvohyIph5xKraYOrEQkzuohe(iiThNdirEDjdUJ8Qh3hrlkrRZbr)I8qRCoWeFoYRlzWDK37lJtfiYViJaKrJ8uvYOCoi8rqApohqQJzDiBW5sIsYabf2ANW7ed9qfq1rPU8I8Rhxoijkjdeu06xrjA9R3I(f5Hw5CGj(CKFrgbiJg5PQKr5Cq4JG0ECoGe51Lm4oY79LXPceLOe5xgu0VO1VI(f5Hw5CGj(CKxxYG7iV(oIMsuuAJBjH3jBCUajYViJaKrJ8(xhsa1j0atqDU6ywNNIeGKuesrOPteWtNgvhL6ERoM1XADlm2zW52bQqBar0ab80Pr1LVVU6yTUfg7m4C7aI2qnqapDAuD0DDa7(p22GjOiAu1gqjI(oMKwyI6QJL6yPU8R71B1XwDVERo6UoGD)hBBWeuenQAdOerFhtslmrD1XSo)RZaC)9oqfAdiIg(21XSo)RZaC)9oGOnudF7iFREqKxFhrtjkkTXTKW7KnoxGeLO15f9lYdTY5at85i)ImcqgnY7FDibuNqdmb15QJzDgSeiFB5tGGmlgMoRoM15PibijfHueA6eb80Pr1rPU3I86sgCh5xQZL0Lm4o5gKe5DdssT6brEaHGEbOOeTM9r)I8qRCoWeFoYRlzWDK3tjmaM0gtsgqfAr(fzeGmAKNOJjbuHwcQXGcF76ywhR1jkjdKGmEqsWjZa1LFDlShhozJNwqbdSN1i1r319k476SyPUf2JdNSXtlOGb2ZAK6ONsDl7KN6tczdTPowI8Rhxoijkjdeu06xrjADoJ(f5Hw5CGj(CKFrgbiJg5j6ysavOLGAmOW01rFDS)T6yN6i6ysavOLGAmOG5tuzWDDmRBH94WjB80ckyG9SgPo6Pu3Yo5P(Kq2qBI86sgCh59ucdGjTXKKbuHwuIw77OFrEDjdUJ8BNMboNkdUJ8qRCoWeFokrRFYOFrEOvohyIph5xKraYOrEdW937W2PzGZPYG7ab80Pr1LFD5f51Lm4oYVDAg4CQm4oTCG2iikrRZHr)I8qRCoWeFoYJTJ8iqI86sgCh5PQKr5CqKNQ6(qK3)6e1bTeqFobi7FgeGw5CGPolwQZ)603bYiqarJG)gWKq)9gVuzWDaALZbM6SyPodwczkHGfiy79DYy7gGuh919QoM1XADiBW5sIsYabf2ANW7ed9qfq1LFDpzDwSuN)1TWyNbNBhOQ9GOf(21XsKNQssT6brEQqBar0e6Zjaz)ZG0c3MrgChLO1(YOFrEOvohyIph5X2rEeirEDjdUJ8uvYOCoiYtvDFiY7FDI6Gwc9KrtqI6yaibOvohyQZIL68VorDqlbWhK2z)PvbcqRCoWuNfl1TWyNbNBhaFqAN9NwfiqapDAuD5xNVRJDQlV6O76e1bTemaydKesiQOzGxaALZbMipvLKA1dI8uH2aIOPEYOjirDmaK0c3MrgChLO15GOFrEOvohyIph5X2rEeirEDjdUJ8uvYOCoiYtvDFiY7FDa7(p22GjOVJOPefL24ws4DYgNlqQZIL603bYiqarJG)gWKq)9gVuzWDaALZbM6SyPodW937arFhtslmrDjdW937GbNBxNfl1TWyNbNBhuenQAdOerFhtslmrDbc4PtJQl)6E9wDmRJ16wySZGZTdiAd1ab80Pr1LFDVQZIL6ma3FVdiAd1W3UowI8uvsQvpiYtfAdiIM24wslCBgzWDuIw)6TOFrEOvohyIph5xKraYOrE)RdjG6eAGjqWzFOoM1zWsG8TLpbcYSyy6S6ywN)1zaU)EhOcTberdF76ywhvLmkNdcuH2aIOj0NtaY(NbPfUnJm4UoM1rvjJY5GavOnGiAQNmAcsuhdajTWTzKb31XSoQkzuoheOcTbertBClPfUnJm4oYRlzWDKNk0gqenkrRF9k6xKhALZbM4Zr(fzeGmAKxuh0sa8bPD2FAvGa0kNdm1XSorDqlHEYOjirDmaKa0kNdm1XSoyVHLmuH0c7XHt24PfuD0tPULDYt9jHSH2uhZ6wySZGZTdGpiTZ(tRceiGNonQU8R7vKxxYG7ipvTheTOeT(vEr)I8qRCoWeFoYViJaKrJ8I6Gwc9KrtqI6yaibOvohyQJzD(xNOoOLa4ds7S)0QabOvohyQJzDWEdlzOcPf2JdNSXtlO6ONsDl7KN6tczdTPoM1XADgG7V3bQqBar0W3UolwQdqiOxqG6GgCNW7Knq2WsgChGw5CGPowI86sgCh5PQ9GOfLO1VyF0Vip0kNdmXNJ8y7ipcKiVUKb3rEQkzuohe5PQUpe513bYiqarJG)gWKq)9gVuzWDaALZbM6ywhR114oHqjU)EdMKOKmqq1rpL6EvNfl1HSbNljkjdeuyRDcVtm0dvavhL6yFDSuhZ6yToekX93BWKeLKbckPCyQqYwBd4nR6Ou3B1zXsDiBW5sIsYabf2ANW7ed9qfq1rpL6EY6yjYtvjPw9GipcLOQ9GOLw42mYG7OeT(voJ(f5Hw5CGj(CKxxYG7iVng7seaH)Kfe5bFeIMup8VLiFo9DKFJjPg8rIw)kkrRF57OFrEOvohyIph5xKraYOrErDqlb0NtaY(NbbOvohyQJzD(xhsa1j0atGGZ(qDmRBHXodo3oKPecwGW3UoM1XADuvYOCoiGqjQApiAPfUnJm4UolwQZ)603bYiqarJG)gWKq)9gVuzWDaALZbM6ywhR1zWsitjeSabcSjaIMY5G6SyPodW937avOnGiA4BxhZ6myjKPecwGGT33jJTBasD5tPUx1XsDSuhZ6wypoCYgpTGcgypRrQJEk1XADSw3R6yRU8QJURtFhiJabenc(Batc93B8sLb3bOvohyQJL6O76q2GZLeLKbckS1oH3jg6HkGQJL6O3xxD5SoM1r0XKaQqlb1yqHPRJ(6ELxKxxYG7ipvTheTOeT(1tg9lYdTY5at85i)ImcqgnYZADI6GwcEksassrifHMoaTY5atDwSuh53WgtYGGNsyiH3jHgK8uKaKKIqkcnDay3)X2gm1XsDmRZ)6qcOoHgycQZvhZ68uKaKKIqkcnDIaE60O6YNsDVvhZ68VodwcKVT8jqGaBcGOPCoOoM1zWsitjeSabc4PtJQJ(6yFDmRJ16ma3FVduH2aIOHVDDmRZaC)9oGOnudF76ywhR15FDacb9ccCom2KW7KqdsqdEpg8uFXysDwSuNb4(7DGZHXMeENeAqcAW7XW3UowQZIL6aec6feOoOb3j8ozdKnSKb3bOvohyQJLiVUKb3rEQApiArjA9RCy0Vip0kNdmXNJ8lYiaz0iV)1HeqDcnWeuNRoM1PVdKrGaIgb)nGjH(7nEPYG7a0kNdm1XSodwczkHGfiqGnbq0uohuhZ6myjKPecwGGT33jJTBasD5tPUx1XSUf2JdNSXtlOGb2ZAK6ONsDVI86sgCh5r0udoxpWzIs06x(YOFrEOvohyIph5xKraYOrE)RdjG6eAGjqWzFOoM1XAD(xNblHmLqWceiWMaiAkNdQJzDgSeiFB5tGab80Pr1rFD5So2QlN1r31TStEQpjKn0M6SyPodwcKVT8jqGaE60O6O76El476OVorjzGeKXdscozgOowQJzDIsYajiJhKeCYmqD0xxoJ86sgCh5bFqAN9NwfikrRFLdI(f5Hw5CGj(CKFrgbiJg5DavWvh9uQZ3(Y6ywhR1zWsG8TLpbcYSyy6S6SyPodwciWgnOGmlgMoRowQJzDSwN)1bS7)yBdMG(oIMsuuAJBjH3jBCUaPolwQBHXodo3oqfAdiIgiGNonQo6R71B1XsKxxYG7ipI2qnkrRZ7TOFrEOvohyIph5xKraYOrEU)Eh4CySX9rsGa6sQZIL6ma3FVduH2aIOHVDKxxYG7iVnwgChLO159k6xKhALZbM4Zr(fzeGmAK3aC)9oqfAdiIg(2rEDjdUJ8Com2K2FYJrjADE5f9lYdTY5at85i)ImcqgnYBaU)EhOcTberdF7iVUKb3rEoGGacdtNfLO15X(OFrEOvohyIph5xKraYOrEdW937avOnGiA4Bh51Lm4oYVhcW5WytuIwNxoJ(f5Hw5CGj(CKFrgbiJg5na3FVduH2aIOHVDKxxYG7iV2laje1LwQZfLO1557OFrEOvohyIph51Lm4oYNPoyPohqqjomUJ8lYiaz0ipR1zaU)EhOcTberdF76SyPowRZ)6e1bTeaFqAN9NwfiaTY5atDmRBHXodo3oqfAdiIgiGNonQo6RlN(UolwQtuh0sa8bPD2FAvGa0kNdm1XSowRBHXodo3oa(G0o7pTkqGaE60O6YVUNSolwQBHXodo3oa(G0o7pTkqGaE60O6OVU8ERoM1TNmAsIaE60O6OVUN031XsDSuhl1XSo)RZaC)9oq(2YNabWhK2z)Pvbmr(w9GiFM6GL6CabL4W4okrRZ7jJ(f5Hw5CGj(CKxxYG7iVIOrvBaLi67ysAHjQlYViJaKrJ8gG7V3bI(oMKwyI6sgG7V3bdo3UolwQtusgibz8GKGtMbQl)6Y7TiFREqKxr0OQnGse9DmjTWe1fLO15LdJ(f5Hw5CGj(CKxxYG7iVIOrvBaLi67ysAHjQlYViJaKrJ8SwN)1jQdAja(G0o7pTkqaALZbM6SyPo)Rtuh0sa95eGS)zqaALZbM6yPoM1zaU)EhOcTberdeWtNgvh9196T6yN6YzD0DDa7(p22GjOVJOPefL24ws4DYgNlqI8T6brEfrJQ2akr03XK0ctuxuIwNNVm6xKhALZbM4ZrEDjdUJ8kIgvTbuIOVJjPfMOUi)ImcqgnYZADI6GwcGpiTZ(tRceGw5CGPoM1jQdAjG(Ccq2)miaTY5atDSuhZ6ma3FVduH2aIOHVDDmRJ16ma3FVdzkHGfia(G0o7pTkGPolwQtFhiJabenc(Batc93B8sLb3bOvohyQJzDgSeYucblqW277KX2naPo6R7vDSe5B1dI8kIgvTbuIOVJjPfMOUOeToVCq0Vip0kNdmXNJ86sgCh5xpUCyHG7zL4CksI8lYiaz0iVNIeGKuesrOPteWtNgvhL6ERoM15FDgG7V3bQqBar0W3UoM15FDgG7V3beTHA4BxhZ64(7DWd8WKht4DY9xJjziG6HcgCUDDmRdAGK9yD5xNV8T6ywNblbY3w(eiqapDAuD0xxoJ8WEdlj1Qhe5xpUCyHG7zL4CksIs0A2)w0Vip0kNdmXNJ86sgCh5DFcdabLMgnMb)rPSzlr(fzeGmAK3aC)9oqfAdiIg(2r(w9GiV7tyaiO00OXm4pkLnBjkrRz)ROFrEOvohyIph51Lm4oY7(iHG)Oug2zGoz7(EAge5xKraYOrEdW937avOnGiA4Bh5B1dI8Upsi4pkLHDgOt2UVNMbrjAn7Zl6xKhALZbM4ZrEDjdUJ8zo1mQGjOKhyuNBWDKFrgbiJg5na3FVduH2aIOHVDKh2ByjPw9GiFMtnJkyck5bg15gChLO1SN9r)I8qRCoWeFoYRlzWDKpZPMrfmbL4utge5xKraYOrEdW937avOnGiA4Bh5H9gwsQvpiYN5uZOcMGsCQjdIs0A2NZOFrEDjdUJ8FeKgb8qrEOvohyIphLOe5nyj6x06xr)I8qRCoWeFoYJTJ8iqI86sgCh5PQKr5CqKNQ6(qK3MmyYipMiyrLb31XSoKn4CjrjzGGcBTt4DIHEOcO6OVo2xhZ6yTodwczkHGfiqapDAuD5x3cJDgCUDitjeSabZNOYG76SyPoB8GWnysCoamO6OVoFxhlrEQkj1Qhe5rmm2P1JlhKYucblquIwNx0Vip0kNdmXNJ8y7ipcKiVUKb3rEQkzuohe5PQUpe5TjdMmYJjcwuzWDDmRdzdoxsusgiOWw7eENyOhQaQo6RJ91XSowRZaC)9oGOnudF76SyPowRZgpiCdMeNdadQo6RZ31XSo)RtFhiJab0cAjH3johgBcqRCoWuhl1XsKNQssT6brEedJDA94YbjY3w(eikrRzF0Vip0kNdmXNJ8y7ipcKiVUKb3rEQkzuohe5PQUpe5na3FVduH2aIOHVDDmRJ16ma3FVdiAd1W3UolwQZtrcqskcPi00jc4PtJQJ(6ERowQJzDgSeiFB5tGab80Pr1rFD5f5PQKuREqKhXWyNiFB5tGOeToNr)I8qRCoWeFoYViJaKrJ8I6GwcGpiTZ(tRceGw5CGPoM15FDgG7V3HmLqWceaFqAN9NwfWuhZ6myjKPecwGGT33jJTBasD5tPUx1XSUfg7m4C7a4ds7S)0Qabc4PtJQl)6YRoM1HSbNljkjdeuyRDcVtm0dvavhL6EvhZ6i6ysavOLGAmOW01rFDpzDmRZGLqMsiybceWtNgvhDx3BbFxx(1jkjdKGmEqsWjZarEDjdUJ8zkHGfikrR9D0Vip0kNdmXNJ8lYiaz0iVOoOLa4ds7S)0QabOvohyQJzDSwhS3WsgQqAH94WjB80cQo6Pu3Yo5P(Kq2qBQJzDlm2zW52bWhK2z)PvbceWtNgvx(19QoM1zWsG8TLpbceWtNgvhDx3BbFxx(1jkjdKGmEqsWjZa1XsKxxYG7ip5BlFceLO1pz0Vip0kNdmXNJ8Bmj1Gps06xrEDjdUJ82ySlrae(twquIwNdJ(f5Hw5CGj(CKFrgbiJg5jWMaiAkNdQJzDlShhozJNwqbdSN1i1rpL6EvhB1X(6O76yTo9DGmceq0i4Vbmj0FVXlvgChGw5CGPoM1TWyNbNBhOQ9GOf(21XsDmRJ16S9(ozSDdqQlFk19QolwQJaE60O6YNsDYSyijJhuhZ6q2GZLeLKbckS1oH3jg6HkGQJEk1X(6yRo9DGmceq0i4Vbmj0FVXlvgChGw5CGPowQJzDSwN)1b(G0o7pTkGPolwQJaE60O6YNsDYSyijJhuhDxxE1XSoKn4CjrjzGGcBTt4DIHEOcO6ONsDSVo2QtFhiJabenc(Batc93B8sLb3bOvohyQJL6ywN)1HqjU)EdM6ywhR1jkjdKGmEqsWjZa1Xo1rapDAuDSuh91LZ6ywhR15PibijfHueA6eb80Pr1rPU3QZIL68VozwmmDwDmRtFhiJabenc(Batc93B8sLb3bOvohyQJLiVUKb3r(mLqWceLO1(YOFrEOvohyIph53ysQbFKO1VI86sgCh5TXyxIai8NSGOeTohe9lYdTY5at85iVUKb3r(mLqWce5xKraYOrE)RJQsgLZbbedJDA94YbPmLqWcuhZ6iWMaiAkNdQJzDlShhozJNwqbdSN1i1rpL6EvhB1X(6O76yTo9DGmceq0i4Vbmj0FVXlvgChGw5CGPoM1TWyNbNBhOQ9GOf(21XsDmRJ16S9(ozSDdqQlFk19QolwQJaE60O6YNsDYSyijJhuhZ6q2GZLeLKbckS1oH3jg6HkGQJEk1X(6yRo9DGmceq0i4Vbmj0FVXlvgChGw5CGPowQJzDSwN)1b(G0o7pTkGPolwQJaE60O6YNsDYSyijJhuhDxxE1XSoKn4CjrjzGGcBTt4DIHEOcO6ONsDSVo2QtFhiJabenc(Batc93B8sLb3bOvohyQJL6ywN)1HqjU)EdM6ywhR1jkjdKGmEqsWjZa1Xo1rapDAuDSuh919kV6ywhR15PibijfHueA6eb80Pr1rPU3QZIL68VozwmmDwDmRtFhiJabenc(Batc93B8sLb3bOvohyQJLi)6XLdsIsYabfT(vuIw)6TOFrEOvohyIph5xKraYOrEKn4CjrjzGGQJEk1LxDmRJaE60O6YVU8QJT6yToKn4CjrjzGGQJEk1576yPoM1b7nSKHkKwypoCYgpTGQJEk1LZiVUKb3r(fz8q4ojGNnGKOeT(1ROFrEOvohyIph5xKraYOrE)RJQsgLZbbedJDI8TLpbQJzDSwhS3WsgQqAH94WjB80cQo6PuxoRJzDeytaenLZb1zXsD(xNmlgMoRoM1XADY4b1rFDVERolwQBH94WjB80cQo6PuxE1XsDSuhZ6yToBVVtgB3aK6YNsDVQZIL6iGNonQU8PuNmlgsY4b1XSoKn4CjrjzGGcBTt4DIHEOcO6ONsDSVo2QtFhiJabenc(Batc93B8sLb3bOvohyQJL6ywhR15FDGpiTZ(tRcyQZIL6iGNonQU8PuNmlgsY4b1r31LxDmRdzdoxsusgiOWw7eENyOhQaQo6Puh7RJT603bYiqarJG)gWKq)9gVuzWDaALZbM6yPoM1jkjdKGmEqsWjZa1Xo1rapDAuD0xxoJ86sgCh5jFB5tGOeT(vEr)I8qRCoWeFoYRlzWDKN8TLpbI8lYiaz0iV)1rvjJY5GaIHXoTEC5Ge5BlFcuhZ68VoQkzuoheqmm2jY3w(eOoM1b7nSKHkKwypoCYgpTGQJEk1LZ6ywhb2eart5CqDmRJ16S9(ozSDdqQlFk19QolwQJaE60O6YNsDYSyijJhuhZ6q2GZLeLKbckS1oH3jg6HkGQJEk1X(6yRo9DGmceq0i4Vbmj0FVXlvgChGw5CGPowQJzDSwN)1b(G0o7pTkGPolwQJaE60O6YNsDYSyijJhuhDxxE1XSoKn4CjrjzGGcBTt4DIHEOcO6ONsDSVo2QtFhiJabenc(Batc93B8sLb3bOvohyQJL6ywNOKmqcY4bjbNmduh7uhb80Pr1rFD5mYVEC5GKOKmqqrRFfLO1VyF0Vip0kNdmXNJ8lYiaz0ipYgCUKOKmqq1rPUx1XSoyVHLmuH0c7XHt24PfuD0tPowRBzN8uFsiBOn1Xo19QowQJzDeytaenLZb1XSo)Rd8bPD2FAvatDmRZ)6ma3FVdiAd1W3UoM15PibijfHueA6eb80Pr1rPU3QJzD(xN(oqgbcsUdsscniXqpBiaTY5atDmRtusgibz8GKGtMbQJDQJaE60O6OVUCg51Lm4oYViJhc3jb8SbKeLO1VYz0ViVUKb3rEeyJguKhALZbM4ZrjkrjYtfiOb3rRZ7T8E71RxVI85QKE6muKNDfDLoATVG1pv6qD15hnOUXZgtK62ysD5iGqqVauowhby3)HaM6qypOo9lypvatDlAANbOqX4tzAOU8Od1904MkqeWuxoc(G0o7pTkGjWUKJ1j46YrdW937a7sa8bPD2FAvatowhRV8HLqX4tzAOUCshQ7PXnvGiGPo(X7PRd9ylQp1rxQobx3t5R1zgQdAWDDyBGOcMuhRpWsDSMNpSekglgzxrxPJw7ly9tLouxD(rdQB8SXePUnMuxoAGT(Dsowhby3)HaM6qypOo9lypvatDlAANbOqX4tzAOo2thQ7PXnvGiGPo(X7PRd9ylQp1rxQobx3t5R1zgQdAWDDyBGOcMuhRpWsDS(YhwcfJfJSROR0rR9fS(PshQRo)Ob1nE2yIu3gtQlhxguowhby3)HaM6qypOo9lypvatDlAANbOqX4tzAOUCaDOUNg3ubIaM6YrHmndGeyxclm2zW525yDcUUCCHXodo3oWUKJ1X6lFyjum(uMgQlpFthQ7PXnvGiGPUCe8bPD2FAvatGDjhRtW1LJgG7V3b2La4ds7S)0QaMCSowF5dlHIXNY0qD55lPd1904MkqeWuxoc(G0o7pTkGjWUKJ1j46YrdW937a7sa8bPD2FAvatowhRV8HLqXyXi7k6kD0AFbRFQ0H6QZpAqDJNnMi1TXK6YrdwYX6ia7(peWuhc7b1PFb7PcyQBrt7mafkgFktd1Lt6qDpnUPcebm1LJGpiTZ(tRcycSl5yDcUUC0aC)9oWUeaFqAN9NwfWKJ1X6lFyjumwm6l4zJjcyQlhwNUKb315gKGcfJrEKnSIwNNVZbrEBcEpoiYtN1rxrifHMwLb31rhXzFOyKoRZAmvWJdi1Lh7TQU8ElV3kglgPZ68v(aRVaM64GnMa1TWECQuhhKnnkuhDDTaBbvxJB2HMs82FxD6sgCJQd3UhdfJ6sgCJc2eyH94uHIAB7EmzJheUlg1Lm4gfSjWc7XPcBuEWtjmaM0gtsgqfAwztGf2JtLecw42GO4BRMnfIoMeqfAjOgdkmn9V8DXOUKb3OGnbwypovyJYdibuNqRyuxYGBuWMalShNkSr5bKBwqsBtYmlWkBcSWECQKqWc3geLxwnBkeytaenLZbfJ6sgCJc2eyH94uHnkp8rqAeWZQw9ak67iAkrrPnULeENSX5cKIrDjdUrbBcSWECQWgLhY(kXmANW7K(oqWcnRMnfrDqlbWhK2z)PvbcqRCoWumwmsN15R8bwFbm1bubYJ1jJhuNqdQtxcMu3GQtPQJt5CqOyuxYGBefgMfdfJ0zD0rajG6eA1n76SXi0W5G6yTX1r97AGOCoOoObVbq1nDDlShNkSumQlzWnInkpGeqDcTIrDjdUrSr5bQkzuohyvREafObs2JjcKbDAH94MgmwrvDFGc0aj7XabYGMnB8GWnysCoami6ohsxI18OBKn4CjAksawkg1Lm4gXgLhOQKr5CGvT6buqtN5GKOKmqSIQ6(afKn4CjrjzGGcBTt4DIHEOcO8ZRyuxYGBeBuEyPoxsxYG7KBqIvT6buqcOoHgySA2uqcOoHgyceC2hkg1Lm4gXgLhwQZL0Lm4o5gKyvREaLLbz1SPWQ)I6GwcEksassrifHMoaTY5aJflgSeYucblqqMfdtNXsXOUKb3i2O8aYnliPTjzMfy1SPGSbNljkjdeuyRDcVtm0dvaLpfw9n7q(nSXKmiyueTPZsOf(3gc4ca7(p22GHfMC)9oGCZcsABsMzbbc4PtJYFpz0Keb80PrmjWMaiAkNdyUWEC4KnEAbrpf2xmQlzWnInkpSuNlPlzWDYniXQw9akgSumQlzWnInkpSuNlPlzWDYniXQw9akMHalPyuxYGBeBuEqjlTHKGjeOfRMnfObs2JbdSN1i0t5LVzJQsgLZbbObs2JjcKbDAH94MgmfJ6sgCJyJYdkzPnKS)oeumQlzWnInkp4MmAck5l(BY8Gwkg1Lm4gXgLh40SeENeYSyavmwmsN190ySZGZTrfJ6sgCJcldIYhbPrapRA1dOOVJOPefL24ws4DYgNlqSA2u8hjG6eAGjOohtpfjajPiKIqtNiGNonIYBmzDHXodo3oqfAdiIgiGNonkFFDSUWyNbNBhq0gQbc4PtJOBGD)hBBWeuenQAdOerFhtslmrDSWs(VEJTxVr3a7(p22GjOiAu1gqjI(oMKwyI6y6Vb4(7DGk0gqen8Tz6Vb4(7DarBOg(2fJ6sgCJcldInkpSuNlPlzWDYniXQw9akacb9cqwnBk(JeqDcnWeuNJPblbY3w(eiiZIHPZy6PibijfHueA6eb80PruERyKoRZxyxNAmO6ucu332Q6q9yd1j0G6WnuxUJqRohoxaj15NF0fH681JG6YLg01zEC6S62ksasDcnTR7PFI1zG9SgPomPUChHg(l1P9J190pXqXOUKb3OWYGyJYdEkHbWK2ysYaQqZQ1JlhKeLKbcIYlRMnfIoMeqfAjOgdk8TzYQOKmqcY4bjbNmdK)c7XHt24PfuWa7zncD)k4BlwwypoCYgpTGcgypRrONYYo5P(Kq2qByPyKoRZxyxxJRtnguD5ooxDMbQl3rOnDDcnOUg8rQJ9VHSQUpcQZxBtxuhURJdJq1L7i0WFPoTFSUN(jgkg1Lm4gfwgeBuEWtjmaM0gtsgqfAwnBkeDmjGk0sqnguyA6z)BSdrhtcOcTeuJbfmFIkdUzUWEC4KnEAbfmWEwJqpLLDYt9jHSH2umQlzWnkSmi2O8W2PzGZPYG7IrDjdUrHLbXgLh2ondCovgCNwoqBey1SPyaU)Eh2ondCovgChiGNonk)8kgPZ6EcqBar06C4SzPU6w42mYGB1HQJtrGPoCx36tiql1HSHvXOUKb3OWYGyJYduvYOCoWQw9akuH2aIOj0NtaY(NbPfUnJm42kQQ7du8xuh0sa95eGS)zqaALZbglw8xFhiJabenc(Batc93B8sLb3bOvohySyXGLqMsiybc2EFNm2Ubi0)IjRiBW5sIsYabf2ANW7ed9qfq5)KwS4)cJDgCUDGQ2dIw4BZsXOUKb3OWYGyJYduvYOCoWQw9akuH2aIOPEYOjirDmaK0c3MrgCBfv19bk(lQdAj0tgnbjQJbGeGw5CGXIf)f1bTeaFqAN9NwfiaTY5aJfllm2zW52bWhK2z)PvbceWtNgLVVzN8OBrDqlbda2ajHeIkAg4fGw5CGPyuxYGBuyzqSr5bQkzuohyvREafQkzuohyvREafQqBar00g3sAHBZidUTIQ6(af)b29FSTbtqFhrtjkkTXTKW7KnoxGyXI(oqgbciAe83aMe6V34LkdUdqRCoWyXIb4(7DGOVJjPfMOUKb4(7DWGZTTyritZaibfrJQ2akr03XK0ctuxyHXodo3oqapDAu(VEJjRlm2zW52beTHAGaE60O8FzXIb4(7DarBOg(2SumQlzWnkSmi2O8avOnGiQvZMI)ibuNqdmbco7dmnyjq(2YNabzwmmDgt)na3FVduH2aIOHVntQkzuoheOcTbertOpNaK9pdslCBgzWntQkzuoheOcTbert9KrtqI6yaiPfUnJm4MjvLmkNdcuH2aIOPnUL0c3MrgCxmsN19e0Eq0Ql3rOvNVYhuwDSvN1tgnbjQJbGqhQZxt9z8(E190pX602uNVYhuwDeqnpw3gtQRbFK6EQpnDrXOUKb3OWYGyJYdu1Eq0SA2ue1bTeaFqAN9NwfiaTY5adtrDqlHEYOjirDmaKa0kNdmmH9gwYqfslShhozJNwq0tzzN8uFsiBOnmxySZGZTdGpiTZ(tRceiGNonk)xfJ0zDpbTheT6YDeA1z9KrtqI6yai1XwDwJRZx5dkJouNVM6Z499Q7PFI1PTPUNa0gqeTUVDDS(BhGq19rtNv3ta)ezPyuxYGBuyzqSr5bQApiAwnBkI6Gwc9KrtqI6yaibOvohyy6VOoOLa4ds7S)0QabOvohyyc7nSKHkKwypoCYgpTGONYYo5P(Kq2qByYQb4(7DGk0gqen8TTybqiOxqG6GgCNW7Knq2WsgChGw5CGHLIr6SoEaQB)DU6wyppOL6WDD0eXgrhE4HSrO95clS3d0rLk00WoJWo(90pqhXzF4HChgMhORiKIqtRYGB2HU(eFkSdDeqGsw0cfJ6sgCJcldInkpqvjJY5aRA1dOGqjQApiAPfUnJm42kQQ7du03bYiqarJG)gWKq)9gVuzWDaALZbgMS24oHqjU)EdMKOKmqq0t5LfliBW5sIsYabf2ANW7ed9qfquyplmzfHsC)9gmjrjzGGskhMkKS12aEZIYBwSGSbNljkjdeuyRDcVtm0dvarpLNKLIrDjdUrHLbXgLhSXyxIai8NSaR2ysQbFekVSc8riAs9W)wOKtFxmQlzWnkSmi2O8avThenRMnfrDqlb0NtaY(NbbOvohyy6psa1j0atGGZ(aZfg7m4C7qMsiybcFBMSsvjJY5GacLOQ9GOLw42mYGBlw8xFhiJabenc(Batc93B8sLb3bOvohyyYQblHmLqWceiWMaiAkNdSyXaC)9oqfAdiIg(2mnyjKPecwGGT33jJTBas(uEXclmxypoCYgpTGcgypRrONcRS(IT8OB9DGmceq0i4Vbmj0FVXlvgChGw5CGHf6gzdoxsusgiOWw7eENyOhQaIf691LtMeDmjGk0sqnguyA6FLxXiDw3tq7brRUChHwD(AksasD0vesrtthQZACDibuNqRoTn11460LmuH681OR1X93BRQJo(TLpbQRXsDtxhb2earRoI2zGv1z(KPZQ7jaTberzZVNz7zS4RQJ1F7aeQUpA6S6Ec4NilfJ6sgCJcldInkpqv7brZQztHvrDqlbpfjajPiKIqthGw5CGXIfYVHnMKbbpLWqcVtcni5PibijfHueA6aWU)JTnyyHP)ibuNqdmb15y6PibijfHueA6eb80Pr5t5nM(BWsG8TLpbceytaenLZbmnyjKPecwGab80Pr0ZEMSAaU)EhOcTberdFBMgG7V3beTHA4BZKv)bec6fe4CySjH3jHgKGg8Em4P(IXelwma3FVdCom2KW7KqdsqdEpg(2SyXcGqqVGa1bn4oH3jBGSHLm4oaTY5adlfJ0zD80udoxpWzQBJj1XtJG)gWuh)FVXlvgCxmQlzWnkSmi2O8aIMAW56boJvZMI)ibuNqdmb15yQVdKrGaIgb)nGjH(7nEPYG7a0kNdmmnyjKPecwGab2eart5CatdwczkHGfiy79DYy7gGKpLxmxypoCYgpTGcgypRrONYRIr6SoFLpiTZ(tRcuxU0GUUgl1HeqDcnWuN2M64WcT6OJFB5tG602u3tvjeSa1PeOUVDDBmPohUZQdA8pJwOyuxYGBuyzqSr5bWhK2z)PvbSA2u8hjG6eAGjqWzFGjR(BWsitjeSabcSjaIMY5aMgSeiFB5tGab80Pr0Nt2YjDVStEQpjKn0glwmyjq(2YNabc4PtJO73c(MErjzGeKXdscozgGfMIsYajiJhKeCYma95SyuxYGBuyzqSr5beTHQvZMIdOco6P4BFjtwnyjq(2YNabzwmmDMflgSeqGnAqbzwmmDglmz1FGD)hBBWe03r0uIIsBClj8ozJZfiwSSWyNbNBhOcTberdeWtNgr)R3yPyuxYGBuyzqSr5bBSm42QztH7V3bohgBCFKeiGUelwma3FVduH2aIOHVDXOUKb3OWYGyJYdCom2K2FYJwnBkgG7V3bQqBar0W3UyuxYGBuyzqSr5boGGacdtNz1SPyaU)EhOcTberdF7IrDjdUrHLbXgLh2db4CySXQztXaC)9oqfAdiIg(2fJ6sgCJcldInkpO9cqcrDPL6CwnBkgG7V3bQqBar0W3UyuxYGBuyzqSr5HpcsJaEw1QhqjtDWsDoGGsCyCB1SPWQb4(7DGk0gqen8TTyHv)f1bTeaFqAN9NwfiaTY5adZfg7m4C7avOnGiAGaE60i6ZPVTyruh0sa8bPD2FAvGa0kNdmmzDHXodo3oa(G0o7pTkqGaE60O8FslwwySZGZTdGpiTZ(tRceiGNonI(8EJ5EYOjjc4PtJO)j9nlSWct)bFqAN9NwfWeiFB5tGIrDjdUrHLbXgLh(iinc4zvREaffrJQ2akr03XK0ctuNvZMIb4(7DGOVJjPfMOUKb4(7DWGZTTyrusgibz8GKGtMbYpV3kg1Lm4gfwgeBuE4JG0iGNvT6buuenQAdOerFhtslmrDwnBkS6VOoOLa4ds7S)0QabOvohySyXFrDqlb0NtaY(NbbOvohyyHPb4(7DGk0gqenqapDAe9VEJDYjDdS7)yBdMG(oIMsuuAJBjH3jBCUaPyuxYGBuyzqSr5HpcsJaEw1Qhqrr0OQnGse9DmjTWe1z1SPWQOoOLa4ds7S)0QabOvohyykQdAjG(Ccq2)miaTY5adlmna3FVduH2aIOHVntwbFqAN9NwfWeYucblGfl67azeiGOrWFdysO)EJxQm4oaTY5adtdwczkHGfiy79DYy7gGq)lwkg1Lm4gfwgeBuE4JG0iGNvWEdlj1Qhqz94YHfcUNvIZPiXQztXtrcqskcPi00jc4PtJO8gt)na3FVduH2aIOHVnt)na3FVdiAd1W3Mj3FVdEGhM8ycVtU)AmjdbupuWGZTzcnqYEmFF5Bmnyjq(2YNabc4PtJOpNfJ6sgCJcldInkp8rqAeWZQw9akUpHbGGstJgZG)Ou2SfRMnfdW937avOnGiA4BxmQlzWnkSmi2O8WhbPrapRA1dO4(iHG)Oug2zGoz7(EAgy1SPyaU)EhOcTberdF7IrDjdUrHLbXgLh(iinc4zfS3WssT6buYCQzubtqjpWOo3GBRMnfdW937avOnGiA4BxmQlzWnkSmi2O8WhbPrapRG9gwsQvpGsMtnJkyckXPMmWQztXaC)9oqfAdiIg(2fJ0zD0fWw)oPUT6CC6IH62ysDFKY5G6gb8q0H681JG6WDDlm2zW52HIrDjdUrHLbXgLh(iinc4HkglgPZ6OlgcSK6mQNMb1PCJBKbqfJ0zD(QMk0yV6uPUCYwDS6B2Ql3rOvhDbpl190pXqD(cEEGzubCpwhURlp2QtusgiiRQl3rOv3taAdiIAvDysD5ocT687z21Rdl0asUdcQlxDK62ysDiShuh0aj7XqD0vhcxxU6i1n768v(GYQBH94W1nO6wyVPZQ7Bhkg1Lm4gfmdbwcfOPcn2ZQztb2ByjdviTWEC4KnEAbrpLCYMOoOLGbaBGKqcrfnd8cqRCoWWKvdW937avOnGiA4BBXIb4(7DarBOg(2wSanqYEmyG9SgjFk55B2OQKr5CqaAGK9yIazqNwypUPbJfl(tvjJY5GaA6mhKeLKbclmz1FrDqlbWhK2z)PvbcqRCoWyXYcJDgCUDa8bPD2FAvGab80Pr0NhlfJ6sgCJcMHalHnkpqvjJY5aRA1dO8rqApohqSIQ6(aLf2JdNSXtlOGb2ZAe6FzXc0aj7XGb2ZAK8PKNVzJQsgLZbbObs2JjcKbDAH94MgmwS4pvLmkNdcOPZCqsusgifJ6sgCJcMHalHnkpGacrfWK4WnKq2ddGvRhxoijkjdeeLxwnBkC)9oGCZcsABsMzbHVnt)nyjGacrfWK4WnKq2ddqYGLGmlgMoZIL9KrtseWtNgLpfFBXYcJDgCUDabeIkGjXHBiHShgGWIMsYauAt0Lm4wD0tjVqo03wSGWFh30MGdutI7Xe4J6z7Ga0kNdmm9N7V3bhOMe3JjWh1Z2bHVDXiDwh7QrOvNVArdpDwDp7udGSQoFrAxhExhD5EOcO6uPU8yRorjzGGSQomPo2Zo5KT6eLKbcQUCPbDDpbOnGiADdQUVDXOUKb3OGziWsyJYdBTt4DIHEOciRMnfQkzuohe(iiThNdim13bYiqaw0WtNL4CQbqbOvohyyISbNljkjdeuyRDcVtm0dvarpL8yJvdW937avOnGiA4Bt3S(Inw13bYiqaw0WtNL4CQbqbI2mq5flSWsXiDwNViTRdVRJUCpubuDQu3RCaB1HeDXaQo8Uo21gJb66E2PgavhMuNMPtJK6YjB1XQVzRUChHwD0f4pNdQJUaJawQtusgiOqXOUKb3OGziWsyJYdBTt4DIHEOciRMnfQkzuohe(iiThNdimzL7V3bAJXaDIZPgafqIUyGEkVYbwSWQ)2Kbtg5XeblQm4MjYgCUKOKmqqHT2j8oXqpube9uYjBSQVdKrGGb)5CqYGrqGOnd0NhlSHeqDcnWei4SpWclfJ0zD(I0Uo8Uo6Y9qfq1j46uBB3J1rxaQX9yDpr8GWDDZUUP1LmuH6WDDA)yDIsYaPovQJ91jkjdeuOyuxYGBuWmeyjSr5HT2j8oXqpubKvRhxoijkjdeeLxwnBkuvYOCoi8rqApohqyISbNljkjdeuyRDcVtm0dvarpf2xmQlzWnkygcSe2O8aSOHNolraBY4PTXQztHQsgLZbHpcs7X5acZfg7m4C7avOnGiAGaE60i6F9wXOUKb3OGziWsyJYdQh3hrZQztHQsgLZbHpcs7X5asXiDwNFkh74R9LXPcuNGRtTTDpwhDbOg3J19eXdc31PsD5vNOKmqqfJ6sgCJcMHalHnkp49LXPcy16XLdsIsYabr5LvZMcvLmkNdcFeK2JZbeMiBW5sIsYabf2ANW7ed9qfquYRyuxYGBuWmeyjSr5bVVmovaRMnfQkzuohe(iiThNdifJfJ0zD0fQNMb1HPcK6KXdQt5g3idGkgPZ6EkJ3i19uvcblaQoCxxJB2XMmEeL8yDIsYabv3gtQtOb1ztgmzKhRJGfvgCx3SRZ3SvhNdadQoLa1PocOMhR7BxmQlzWnkyWcfQkzuohyvREafedJDA94YbPmLqWcyfv19bk2Kbtg5XeblQm4MjYgCUKOKmqqHT2j8oXqpube9SNjRgSeYucblqGaE60O8xySZGZTdzkHGfiy(evgCBXInEq4gmjohage9(MLIr6SUNY4nsD0XVT8jaQoCxxJB2XMmEeL8yDIsYabv3gtQtOb1ztgmzKhRJGfvgCx3SRZ3SvhNdadQoLa1PocOMhR7BxmQlzWnkyWcBuEGQsgLZbw1QhqbXWyNwpUCqI8TLpbSIQ6(afBYGjJ8yIGfvgCZezdoxsusgiOWw7eENyOhQaIE2ZKvdW937aI2qn8TTyHvB8GWnysCoami69nt)13bYiqaTGws4DIZHXMa0kNdmSWsXiDw3tz8gPo643w(eav3SR7jaTberzJN2q9bFnfjaPo6kcPi001nO6(21PTPUCH6OPuH6YJT6qWc3guDoyl1H76eAqD0XVT8jqD0fy)kg1Lm4gfmyHnkpqvjJY5aRA1dOGyyStKVT8jGvuv3hOyaU)EhOcTberdFBMSAaU)Ehq0gQHVTflEksassrifHMorapDAe9VXctdwcKVT8jqGaE60i6ZRyKoRJ3gwJ6Q7PQecwG602uhD8BlFcuhcKVDD2KbtQtW15R8bPD2FAvG6wkskg1Lm4gfmyHnkpKPecwaRMnfrDqlbWhK2z)PvbcqRCoWW0FWhK2z)PvbmHmLqWcW0GLqMsiybc2EFNm2Ubi5t5fZfg7m4C7a4ds7S)0Qabc4PtJYppMiBW5sIsYabf2ANW7ed9qfquEXKOJjbuHwcQXGctt)tY0GLqMsiybceWtNgr3Vf8D(IsYajiJhKeCYmqXOUKb3OGblSr5bY3w(eWQztruh0sa8bPD2FAvGa0kNdmmzf2ByjdviTWEC4KnEAbrpLLDYt9jHSH2WCHXodo3oa(G0o7pTkqGaE60O8FX0GLa5BlFceiGNonIUFl478fLKbsqgpij4KzawkgPZ6EQkHGfOUVndayBvDQdHRtidGQtW19rqDJuNIQtRdzdRrD1LbnqubtQBJj1j0G6CksQ7PFI1XbBmbQtRBp9GObKIrDjdUrbdwyJYd2ySlrae(twGvBmj1GpcLxfJ6sgCJcgSWgLhYucblGvZMcb2eart5CaZf2JdNSXtlOGb2ZAe6P8In2t3SQVdKrGaIgb)nGjH(7nEPYG7a0kNdmmxySZGZTdu1Eq0cFBwyYQT33jJTBas(uEzXcb80Pr5trMfdjz8aMiBW5sIsYabf2ANW7ed9qfq0tH9SPVdKrGaIgb)nGjH(7nEPYG7a0kNdmSWKv)bFqAN9NwfWyXcb80Pr5trMfdjz8a6opMiBW5sIsYabf2ANW7ed9qfq0tH9SPVdKrGaIgb)nGjH(7nEPYG7a0kNdmSW0FekX93BWWKvrjzGeKXdscozgGDiGNonIf6Zjtw9uKaKKIqkcnDIaE60ikVzXI)YSyy6mM67azeiGOrWFdysO)EJxQm4oaTY5adlfJ6sgCJcgSWgLhSXyxIai8NSaR2ysQbFekVkg1Lm4gfmyHnkpKPecwaRwpUCqsusgiikVSA2u8NQsgLZbbedJDA94YbPmLqWcWKaBcGOPCoG5c7XHt24PfuWa7znc9uEXg7PBw13bYiqarJG)gWKq)9gVuzWDaALZbgMlm2zW52bQApiAHVnlmz1277KX2najFkVSyHaE60O8PiZIHKmEatKn4CjrjzGGcBTt4DIHEOci6PWE203bYiqarJG)gWKq)9gVuzWDaALZbgwyYQ)GpiTZ(tRcySyHaE60O8PiZIHKmEaDNhtKn4CjrjzGGcBTt4DIHEOci6PWE203bYiqarJG)gWKq)9gVuzWDaALZbgwy6pcL4(7nyyYQOKmqcY4bjbNmdWoeWtNgXc9VYJjREksassrifHMorapDAeL3SyXFzwmmDgt9DGmceq0i4Vbmj0FVXlvgChGw5CGHLIr6SUNMmEiCxNFGNnGK6WDDEFNm2oOorjzGGQtL6YjB190pX6YLg01r(DpDwD4Vu301LhQow)21j46YzDIsYabXsDysDShvhR(MT6eLKbcILIrDjdUrbdwyJYdlY4HWDsapBajwnBkiBW5sIsYabrpL8ysapDAu(5XgRiBW5sIsYabrpfFZctyVHLmuH0c7XHt24Pfe9uYzXiDwhDzaSR7BxhD8BlFcuNk1Lt2Qd31PoxDIsYabvhR5sd66Cd1PZQZH7S6Gg)ZOvN2M6ASuhQvBenSWsXOUKb3OGblSr5bY3w(eWQztXFQkzuoheqmm2jY3w(eGjRWEdlzOcPf2JdNSXtli6PKtMeytaenLZbwS4VmlgMoJjRY4b0)6nlwwypoCYgpTGONsESWctwT9(ozSDdqYNYllwiGNonkFkYSyijJhWezdoxsusgiOWw7eENyOhQaIEkSNn9DGmceq0i4Vbmj0FVXlvgChGw5CGHfMS6p4ds7S)0QaglwiGNonkFkYSyijJhq35XezdoxsusgiOWw7eENyOhQaIEkSNn9DGmceq0i4Vbmj0FVXlvgChGw5CGHfMIsYajiJhKeCYma7qapDAe95SyuxYGBuWGf2O8a5BlFcy16XLdsIsYabr5LvZMI)uvYOCoiGyyStRhxoir(2YNam9NQsgLZbbedJDI8TLpbyc7nSKHkKwypoCYgpTGONsozsGnbq0uohWKvBVVtgB3aK8P8YIfc4PtJYNImlgsY4bmr2GZLeLKbckS1oH3jg6HkGONc7ztFhiJabenc(Batc93B8sLb3bOvohyyHjR(d(G0o7pTkGXIfc4PtJYNImlgsY4b0DEmr2GZLeLKbckS1oH3jg6HkGONc7ztFhiJabenc(Batc93B8sLb3bOvohyyHPOKmqcY4bjbNmdWoeWtNgrFolgPZ6EAY4HWDD(bE2asQd31X7xDZUUPRZwBd4nR602u3i1L74C1zW15aeQoJ6PzqDcnTRZx1uHg7vN5d1j46875h81ORp4NqxUyuxYGBuWGf2O8WImEiCNeWZgqIvZMcYgCUKOKmqquEXe2ByjdviTWEC4KnEAbrpfwx2jp1NeYgAd78IfMeytaenLZbm9h8bPD2FAvadt)na3FVdiAd1W3MPNIeGKuesrOPteWtNgr5nM(RVdKrGGK7GKKqdsm0ZgcqRCoWWuusgibz8GKGtMbyhc4PtJOpNfJ6sgCJcgSWgLhqGnAqfJfJ0zD(kec6fGkg1Lm4gfaec6fGOSW9cAHOcysBN6bwnBkqdKShdY4bjbN8uFO)ft)na3FVduH2aIOHVntw93GLWc3lOfIkGjTDQhK4(KoiZIHPZy6VUKb3HfUxqlevatA7upimDA7MmAIfl7VZLiWIMsYGKmEq(zltWt9HLIr6So6Qlx9ruDFeu3Zom2uxUJqRUNa0gqeTUVDOo21WotDBmPoFLpiTZ(tRceQZxpcQl3rOvNFpx33UooyJjqDAD7PhenGuNIQZH7S6uuDJuh53O62ysDVEdvN5tMoRUNa0gqenumQlzWnkaie0laXgLh4CySjH3jHgKGg8E0QztXaC)9oqfAdiIg(2mzf8bPD2FAvatitjeSawSyaU)Ehq0gQHVnZf2JdNSXtlOGb2ZAK8P8YIfdW937avOnGiAGaE60O8P86nwSyzpz0Keb80Pr5t51BfJ0zD0vrapBPobxN6MSUUN6xjMr76YDeA19eG2aIO1PO6C4oRofv3i1LlUZrPocG(oPUPRZHrtNvNw3(7CSdv19H6wksQdtfi1j0G6iGNo90z1z(evgCxhExNqdQBpz0KIrDjdUrbaHGEbi2O8q2xjMr7eEN03bcwOz1SPSWyNbNBhOcTberdeWtNgLp7TyXaC)9oqfAdiIg(2wSSNmAsIaE60O8z)BfJ6sgCJcacb9cqSr5HSVsmJ2j8oPVdeSqZQztz7WycRSUNmAsIaE60i2H9VXcDPfg7m4CBwOF7WycRSUNmAsIaE60i2H9VXolm2zW52bQqBar0ab80PrSqxAHXodo3MLIrDjdUrbaHGEbi2O8WgV(iWK03bYiqIdupRMnfKn4CjrjzGGcBTt4DIHEOci6PKNfleDmjGk0sqnguyA6FY3ycnqYEm)C4BfJ6sgCJcacb9cqSr5b7pz2poDwIZPiXQztbzdoxsusgiOWw7eENyOhQaIEk5zXcrhtcOcTeuJbfMM(N8TIrDjdUrbaHGEbi2O8Gqds)Md)BtAJjlWQztH7V3bcSyWbiuAJjli8TTyH7V3bcSyWbiuAJjliTW)wasaj6IH8F9wXOUKb3OaGqqVaeBuEGm22oinDczRlOyuxYGBuaqiOxaInkpKlM4muHPteaHBTxqXOUKb3OaGqqVaeBuEWd8WKht4DY9xJjziG6HSA2uGgizpMVVFJP)lm2zW52bQqBar0W3UyKoRJDnSZuhDeu7PZQZxKt9auDBmPoWhy9fOoI2zqDysDmmoxDC)9gzvDZUoBmcnCoiuhD1LR(iQoH8yDcUUmqQtOb15W5ciPUfg7m4C764ueyQd31Pu1XPCoOoObVbqHIrDjdUrbaHGEbi2O8abu7PZsBN6biRwpUCqsusgiikVSA2ueLKbsqgpij4KzG8Ff8TflSYQOKmqc0a1j0c2lHEF5BwSikjdKanqDcTG9sYNsEVXctw1LmuHe0G3aikVSyrusgibz8GKGtMbOpVCalSyXcRIsYajiJhKeCYEjP8EJE2)gtw1LmuHe0G3aikVSyrusgibz8GKGtMbOpN5KfwkglgPZ64fqDcnWuhDDjdUrfJ0zDwpz0qI6yai1H76E5hDOo(wTr0WsD0XVT8jqXOUKb3Oasa1j0adfY3w(eWQztruh0sONmAcsuhdajaTY5adZf2JdNSXtli6PKtMIsYajiJhKeCYma7qapDAe9pzXiDwh)NtaY(Nb1XwD80i4Vbm1X)3B8sLb30H68vn6tG6YfQ7JG6WnuxMdZPU6eCDQTT7X6EQkHGfOobxNqdQZtNUorjzGu3SRBK6guDnwQd1QnIgwQ7rqSQoeUo15Qdl0asDE601jkjdK6uUXnYaO6Sj49iHIrDjdUrbKaQtObg2O8Gng7seaH)Kfy1gtsn4Jq5vXOUKb3Oasa1j0adBuEitjeSawnBk67azeiGOrWFdysO)EJxQm4oaTY5adtU)EhqFobi7Fge(2m5(7Da95eGS)zqGaE60O8Ffypt)rOe3FVbtXiDwh)NtaY(Nb0H6OR22UhRdtQJocBcGOvxUJqRoU)EdM6EQkHGfavmQlzWnkGeqDcnWWgLhSXyxIai8NSaR2ysQbFekVkg1Lm4gfqcOoHgyyJYdzkHGfWQ1JlhKeLKbcIYlRMnfrDqlb0NtaY(NbbOvohyyYkb80Pr5)kplwS9(ozSDdqYNYlwykkjdKGmEqsWjZaSdb80Pr0NxXiDwh)NtaY(Nb1XwD80i4Vbm1X)3B8sLb31nDD8(rhQJUAB7ESoqjUhRJo(TLpbQtOPsD5ooxDCqDeytaenWu3gtQZwBd4nRIrDjdUrbKaQtObg2O8a5BlFcy1SPiQdAjG(Ccq2)miaTY5adt9DGmceq0i4Vbmj0FVXlvgChGw5CGHP)gSeiFB5tGGmlgMoJjvLmkNdcOPZCqsusgifJ0zD8Fobi7FguxUpuhpnc(BatD8)9gVuzWnDOo6iO22UhRBJj1XH7pQUN(jwN2MhWK6aFeOnGPouR2iAyPoZNOYG7qXOUKb3Oasa1j0adBuEWgJDjcGWFYcSAJjPg8rO8QyuxYGBuajG6eAGHnkpKPecwaRwpUCqsusgiikVSA2ue1bTeqFobi7FgeGw5CGHP(oqgbciAe83aMe6V34LkdUdqRCoWWKvDjdvibn4naI(xwS4VOoOLa4ds7S)0QabOvohyyHPOKmqcY4bjbNmdqpb80PrmzLaE60O8F5lTyXFekX93BWWsXiDwh)NtaY(Nb1XwD(kFqz1H76E5hDOo6iSjaIwDpvLqWcuNk1j0G6G2uhExhsa1j0QtW1LbsDEQp1z(evgCxhhSXeOoFLpiTZ(tRcumQlzWnkGeqDcnWWgLhSXyxIai8NSaR2ysQbFekVkg1Lm4gfqcOoHgyyJYdzkHGfWQztruh0sa95eGS)zqaALZbgMI6GwcGpiTZ(tRceGw5CGHPUKHkKGg8gar5ftU)EhqFobi7FgeiGNonk)xb2hLOeJa]] )

end