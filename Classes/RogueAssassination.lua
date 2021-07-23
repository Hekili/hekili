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
        creeping_venom = 141, -- 354895
        death_from_above = 3479, -- 269513
        dismantle = 5405, -- 207777
        flying_daggers = 144, -- 198128
        hemotoxin = 830, -- 354124
        intent_to_kill = 130, -- 197007
        maneuverability = 3448, -- 197000
        smoke_bomb = 3480, -- 212182
        system_shock = 147, -- 198145
        thick_as_thieves = 5408, -- 221622
    } )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )

    -- Commented out in SimC, but my implementation should hold up vs. theirs.
    -- APLs will use effective_combo_points.
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

    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end
        if this_action == "marked_for_death" then
            if active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
            if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
            if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
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
        
        if resource == "combo_points" and legendary.obedience.enabled and buff.flagellation_buff.up then
            reduceCooldown( "flagellation", amt )
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
            duration = 6,
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
                local cast = action.vendetta.lastCast or 0
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
            max_stack = 18,
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
                gain( 1, "combo_points" )

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

                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
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
                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
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

            cycle = function () return buff.deadly_poison.up and "deadly_poison" or nil end,

            handler = function ()
                gain( 1, "combo_points" )
                removeBuff( "hidden_blades" )
                if buff.deadly_poison.up then
                    applyDebuff( "target", "deadly_poison" )
                    active_dot.deadly_poison = min( active_enemies, active_dot.deadly_poison + 8 )
                end
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
                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
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

                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
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
                return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 ) * ( pvptalent.intent_to_kill.enabled and debuff.vendetta.up and 0.1 or 1 )
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
                    id = 115196,
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

            cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + 2 end,

            handler = function ()
                -- Can't predict the Animacharge, unless you have the legendary.
                if legendary.resounding_clarity.enabled then
                    applyBuff( "echoing_reprimand_2", nil, 2 )
                    applyBuff( "echoing_reprimand_3", nil, 3 )
                    applyBuff( "echoing_reprimand_4", nil, 4 )
                    applyBuff( "echoing_reprimand_5", nil, 5 )
                end
                gain( action.echoing_reprimand.cp_gain, "combo_points" )
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
                echoing_reprimand_5 = {
                    id = 354838,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand = {
                    alias = { "echoing_reprimand_2", "echoing_reprimand_3", "echoing_reprimand_4", "echoing_reprimand_5" },
                    aliasMode = "first",
                    aliasType = "buff",
                    meta = {
                        stack = function ()
                            if combo_points.current > 1 and buff[ "echoing_reprimand_" .. combo_points.current ].up then return combo_points.current end

                            if buff.echoing_reprimand_2.up then return 2 end
                            if buff.echoing_reprimand_3.up then return 3 end
                            if buff.echoing_reprimand_4.up then return 4 end
                            if buff.echoing_reprimand_5.up then return 5 end

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
            charges = function () return legendary.deathspike.equipped and 5 or 3 end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 3578230,

            toggle = "essences",

            cycle = "serrated_bone_spike",

            cp_gain = function () return ( buff.broadside.up and 1 or 0 ) + active_dot.serrated_bone_spike end,

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
                    copy = "flagellation_buff"
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


    spec:RegisterPack( "Assassination", 20210723, [[defMycqiKOEKOIUeHaTjQOpbsAuiHtbsTkLs5vuv1SOcDlLc2Ls(fiXWqsCmvslJq6zkLyAubUMsjTncH6BIkuJJqqDocbzDeI8oQGK08qICpc1(OQY)eviXbvkKfIK0dPQOjQuQCrQk0gPcIpQuQAKIkK0jjeWkrs9sQGeZKQcUjHq2Psr)KkijgQsHAPub1tjYufv6Qubj1wje1xPcsnwrfSxj9xqnykhwyXuLhRIjlXLH2ms9zIA0QuNwQvlQqQxRsmBrUTOSBf)wvdNkDCrfILd8CetN01jy7kvFhenEQkDEqy(IQ2pQRxR5wLkHI1nfLkIELk5yr3Y6Ao(AoMkIwLuiCXQKBCUeYyvAImSkTresqi9eA)tvYnGi9rPMBvI8cGdwLUv1LisqbkYTEl4ToFguiDMqk0(NdiOvOq6SduQsEcDsfbMQxvQekw3uuQi6vQKJfDlRR54RI4TETkfc69dQssDMpRs3DPGt1RkvqYPkTresqi9eA)dBo8llGm1ulKGGnrV6iBIsfrVYuZu7Z7yKrIiXuVb22ix3eeSbvIc6Jcv2OtHmB6Zg5Zq22On2hyJ(bxiSPpBKyhzZf8hKq6rMnTZWft9gyB7(bQkBICmn5MnHjHecBsP(GSftHTTRpiBq2PeBPGOSL(rgbSP3XWMikikcyBJiKGq6zXuVb2Cymf(YMdjfYykfA)dBqHnrgNcQAWgbI5WgfnnBImofu1GTMWM(YYjSW2ttZ2dy7h2c2s)iZMp3oOxm1BGnruCbzZHKqY9be0kB9Oiai4QS1dBNpZlu2AA2GezlhTarzR0f2ALn6hW2(NcTtim5t74ORQuQjkPMBvIOyK0BSuZTU51AUvjCcVewQuTkfhT)PkDaDg5hyfZCrIwLki5aAxT)PkTzlFt0iDbbS9dBBjxrInFc6mYpSLlM5IeTkDaTIGoQsAKWrxtlFRensxqWcNWlHf2CYgXftjynaYOsyZpXSTf2CY25Z8Ey3VhLWMFIzZbS5KnnaYOU0odH1hU0iBBGnaMf9qyZp2eXvTUPO1CRs4eEjSuPAvkoA)tvci4QcaSkvqYb0UA)tvAZw(MOr6ccy7h2UMRiXM0eUK7xzZHfCvbawLoGwrqhvjns4ORPLVvIgPliyHt4LWcBoz78zEpS73JsyZpXS5a2CYMgazuxANHW6dxAKTnWgaZIEiS5hBI4Qw3Cl1CRs4eEjSuPAvkoA)tvY9)emajVa4GvPcsoG2v7FQsscEkcOfKrrITnY1nbbBpGnhgPbi5MniB9MnpbAASW22haWRiPkr)a4b9vRBETQ1nDqn3QeoHxclvQwLIJ2)uLKda4vSkDaTIGoQsAKWrxebpfb0cY4cNWlHf2CYgfSbWSOhcBuITRIYw(8S5MjK02n1iGnkjMTRSbnBoztdGmQlTZqy9HlnY2gydGzrpe28JnrRshiojewdGmQK6MxRADZTwZTkHt4LWsLQvP4O9pvj3)tWaK8cGdwLki5aAxT)Pkjj4PiGwqgzZF28rFjYS9dBxZvKyZHrAasUzB7da4vKTqztVr2WPW2tZgrXiP3SPpBYOYww4lBfbqO9pS5H0pazZh9LeJSqpHIvj6hapOVADZRvTUPiUMBvcNWlHLkvRshqRiOJQKgjC0frWtraTGmUWj8syHnNSPrchDH(sIrwONqXfoHxclS5KT4O9ocJdM1iHnXSDLnNS5jqtVicEkcOfKXfaZIEiSrj2UU2svkoA)tvsoaGxXQw3mhxZTkHt4LWsLQvPdOve0rvsJeo6Ii4PiGwqgx4eEjSWMt2oFM3d7(9Oe2OKy22svkoA)tvktq7uOyvRAvApMMCxZTU51AUvjCcVewQuTk9UvjcQvP4O9pvP9a0HxcRs7rsaRsuWgLzdimi9dKXvbd9obbm5okpKKfoHxclS5KnKMgpAVJWNpZ7HD)EucB(jMTJlCw4lmXfNcBqZw(8SrbBaHbPFGmUkyO3jiGj3r5HKSWj8syHnNSD(mVh297rjSrj2eLnORsfKCaTR2)uLCi90KB2GS1B2YcFzZNBmB0pGTnB5BLOr6ccCKnHjHecBcKEKzB7WqVtqWM0DuEijvP9aaprgwLMw(wjAKUGa4Jl85NsR9pvTUPO1CRs4eEjSuPAvkoA)tvApMMCxLki5aAxT)PkjYX0KB2GS1B28rFjYS5pBB2Y3krJ0feisSjIcF7mHm285gZwmf28rFjYSbWOabB0pGTb9vzB7952vLoGwrqhvjns4Ol0xsmYc9ekUWj8syHnNSPrchDnT8Ts0iDbblCcVewyZjB7bOdVeUMw(wjAKUGa4Jl85NsR9pS5KTZ)PYd5SqFjXil0tO4cGzrpe2OeBxRADZTuZTkHt4LWsLQvP4O9pvP9yAYDvQGKdOD1(NQKihttUzdYwVzBZw(wjAKUGa28NTnF28rFjYIeBIOW3otiJnFUXSftHnrgNcQAWMGBv6aAfbDuL0iHJUMw(wjAKUGGfoHxclS5KnkZMgjC0f6ljgzHEcfx4eEjSWMt22dqhEjCnT8Ts0iDbbWhx4ZpLw7FyZjBf0tGMETJtbvnwcUvTUPdQ5wLWj8syPs1QuC0(NQK7)jyasEbWbRsOVkiGJSxy0QKd2AvI(bWd6Rw38AvRBU1AUvjCcVewQuTkDaTIGoQsAKWrxebpfb0cY4cNWlHf2CY25)u5HCwYba8kUeCzZjBuWw51LCaaVIlasdqYD4Lq2YNNTc6jqtV2XPGQglbx2CYw51LCaaVIl3mHK2UPgbSrjXSDLnOzZjBNpZ7HD)EuYQG09Pv28tmBuWgXftjynaYOsw0Xa)0WxMEhjS5xokS5a2GMnNSbIUaJ74OROuiREyZp2UkAvkoA)tvApMMCx16MI4AUvjCcVewQuTkfhT)PkThttURsfKCaTR2)uLe5yAYnBq26nBIOGOiGTnIqcspIeBoSGRkaq)3(aaEfzBELTEydG0aKCZgigz0r2kcGEKztKXPGQg(lD37l2KGyoSbzR3SjHUKMWgDprIT7wzRPzZ9jK2lHRQ0b0kc6OkrbBAKWrxzbrraCqibH0ZcNWlHf2YNNnGWG0pqgxzb4c8tdR3iCwqueahesqi9SWj8syHnOzZjBuMTYRlGGRkaWfaPbi5o8siBozR86soaGxXfaZIEiS5hBBHnNSvqpbA61oofu1yj4YMt2OGTc6jqtVi39(sWLT85zRGEc00RDCkOQXcGzrpe2OeBoGT85zR86IGUKMS0(CPhz2GMnNSvEDrqxstwaml6HWgLyBlvTQvPcshcjTMBDZR1CRsXr7FQsx6ZLQeoHxclvQw16MIwZTkHt4LWsLQvPcsoG2v7FQsomsums6nBnnBUpH0EjKnkMNTDH0GGWlHSHdM1iHTEy78zEHcDvkoA)tvIOyK07Qw3Cl1CRs4eEjSuPAv6DRseuRsXr7FQs7bOdVewL2JKawLiUykbRbqgvYIog4Ng(Y07iHnkXMOvP9aaprgwLi9iNqynaYOw16MoOMBvcNWlHLkvRsVBvIGAvkoA)tvApaD4LWQ0EKeWQeoiqgIfaLXb(8zE9Gf28JTTS1Qubjhq7Q9pvjF(zE9Gf28XbbYqWMdJY4W2GyblSPpBKqfaHIvP9aaprgwLaOmoWKqfaHILQw3CR1CRs4eEjSuPAv6aAfbDuLikgj9gllWllGvjIc6Jw38AvkoA)tv6ePeCC0(h4ut0QuQjk8ezyvIOyK0BSu16MI4AUvjCcVewQuTkfhT)PkDIucooA)dCQjAvk1efEImSkDkKQw3mhxZTkHt4LWsLQvP4O9pvjsQpiCmf4sFWQubjhq7Q9pvPnwqztA2o2eCzRNw7iLGGn6hWMpfu20Nn9gzZN3bbDKnasdqYnBq26nB(4SJZNXwtZwOSLEizRiacT)PkDaTIGoQsuMnpbA6fj1heoMcCPp4sWLnNSD(mVh297rjS5Ny2Uw16MIW1CRs4eEjSuPAv6aAfbDuL8eOPxKuFq4ykWL(Glbx2CYMNan9IK6dchtbU0hCbWSOhcBuITTYMt2oFM3d7(9Oe28tmBoOkfhT)PkHZooFwvRBkcvZTkHt4LWsLQvP4O9pvPtKsWXr7FGtnrRsPMOWtKHvPYRvTU5vQuZTkHt4LWsLQvP4O9pvPtKsWXr7FGtnrRsPMOWtKHvPsdWJw16MxVwZTkHt4LWsLQvPdOve0rvcheidXQG09Pv28tmBx3kB(ZgoiqgIfaLXb(8zE9GLQuC0(NQuaoXGW6da4OvTU5vrR5wLIJ2)uLcWjge2virWQeoHxclvQw16Mx3sn3QuC0(NQuQLVvcCoAHICgoAvcNWlHLkvRADZRoOMBvkoA)tvYlKHFAyf0NlKQeoHxclvQw1QwLCb45Z8cTMBDZR1CRsXr7FQsHRBccy3Vj)uLWj8syPs1Qw3u0AUvP4O9pvjVx1ewGPtbeybYEKH133EQs4eEjSuPAvRBULAUvjCcVewQuTkfhT)PkLfGlybM(bWfm07Q0b0kc6OkbIUaJ74OROuiREyZp2UU1QKlapFMxOWe88tHuL2AvRB6GAUvjCcVewQuTkDaTIGoQsKxi51tz5kquHecJabxT)zHt4LWcB5ZZg5fsE9uw7Fk0oHWKpTJJUWj8syPkfhT)PkrNqY9be0AvRBU1AUvjCcVewQuTk9UvjcQvP4O9pvP9a0HxcRs7rsaRsxzBdSrbBaHbPFGmUkcKlqgPliGa7g65EHt4LWcBBJnQSCWwzd6Q0EaGNidRs74uqvd4tbu16MI4AUvjCcVewQuTk9UvjcQvP4O9pvP9a0HxcRs7rsaRsxzBdSrbBaHbPFGmUEpS04CWfoHxclSTn2OYYboGnORsfKCaTR2)uLY9gzl2rqiJS5ZTZHzRjSrLLOIYMNGYwraztF20BKnhEZTNTjubaY2tZMp3y2KXXr2e1x207MW2EKeq2AcBVR2zrIn6hWgbI50JmBPxUpvP9aaprgwLOtHmMsH2)aFkGQw3mhxZTkHt4LWsLQvP3TkrqTkfhT)PkThGo8syvApaWtKHvjf0ZfuHjqmhys61Q0b0kc6OkPGEUG6sVUUdcmrdDfdeWfxcBozJc2OmBkONlOUurx3bbMOHUIbc4IlHT85ztb9Cb1LEDD(pvEiNvraeA)dB(jMnf0ZfuxQORZ)PYd5SkcGq7FydA2YNNnf0Zfux61vtw9qoabn8siCoIqmQqgCb37dYw(8SrbBkONlOU0RRMSi3r5Hugeexy9vmJnNSD(DCIrx74O3qayd6Qubjhq7Q9pvPTdveK1dYgK395MnkAA2IbcOzJOHYMNannBkONlOYgKiBqgJYM(SfQIzUkB6ZgbI5WgKTEZMiJtbvnwvP9ijGvPRvTUPiCn3QeoHxclvQwLE3Qeb1QuC0(NQ0Ea6WlHvP9ijGvjrRshqRiOJQKc65cQlv01DqGjAORyGaU4syZjBuWgLztb9Cb1LEDDheyIg6kgiGlUe2YNNnf0ZfuxQORZ)PYd5SkcGq7FyZp2uqpxqDPxxN)tLhYzveaH2)Wg0SLppBkONlOUurxnz1d5ae0WlHW5icXOczWfCVpiB5ZZgfSPGEUG6sfD1Kf5okpKYGG4cRVIzS5KTZVJtm6Ahh9gcaBqxL2da8ezyvsb9CbvyceZbMKETQ1nfHQ5wLWj8syPs1QuC0(NQej1heoMcCPpyv6aAfbDuLainaj3HxcRsUa88zEHctWZpfsv6AvRBELk1CRsXr7FQsefJKExLWj8syPs1Qw1QuPb4rR5w38An3QeoHxclvQwLIJ2)uLWzhNpRkvqYb0UA)tvYhNDC(m2cLnh4pBuSv)zdYwVzB7KGMnFUXl2ebYYWshkMGGTFytu)ztdGmQehzdYwVztKXPGQgoY2dydYwVzlxQ6iBVEJaiBcYgKrRSr)a2iFgYgoiqgIfBBuI8Sbz0kBnnB(OVez2oFM3Zwty78z9iZMG7QkDaTIGoQsinnE0EhHpFM3d7(9Oe28tmBoGn)ztJeo6QGOlcGjki0qgZw4eEjSWMt2OGTc6jqtV2XPGQglbx2YNNTc6jqtVi39(sWLT85zRGEc00l6uiJPuO9plbx2YNNnCqGmeRcs3NwzJsIzt0TYM)SHdcKHybqzCGpFMxpyHT85zJYSThGo8s4I0JCcH1aiJkBqZMt2OGnkZMgjC0f6ljgzHEcfx4eEjSWw(8SD(pvEiNf6ljgzHEcfxaml6HWMFSjkBqx16MIwZTkHt4LWsLQvP3TkrqTkfhT)PkThGo8syvApscyv68zEpS73JswfKUpTYMFSDLT85zdheidXQG09Pv2OKy2eDRS5pB4Gaziwaugh4ZN51dwylFE2OmB7bOdVeUi9iNqynaYOwL2da8ezyvsGGW0DkHGQw3Cl1CRs4eEjSuPAvkoA)tvIGaqOyb27heM42xWQubjhq7Q9pvPnY1nbbBsuvIn9zlsj20aiJkHniB9(fu2c2kONannBbHnxq)GwHWr2Cbinca9iZMgazujSvGOhz2i)piGTGwraB6nYMlOZcaeSPbqg1Q0b0kc6OkThGo8s4sGGW0DkHa2CYgLzR86IGaqOyb27heM42xq4YRlTpx6rUQ1nDqn3QeoHxclvQwLIJ2)uLiiaekwG9(bHjU9fSkDaTIGoQs7bOdVeUeiimDNsiGnNSrz2kVUiiaekwG9(bHjU9feU86s7ZLEKRshiojewdGmQK6MxRADZTwZTkHt4LWsLQvP4O9pvjccaHIfyVFqyIBFbRsfKCaTR2)uLCOVXHnr0gXwtyBELTqz7ULVzRiacT)Xr2eiiBsuvIn9zlCDtqWMpGrHnpiyZh9nYCtiBfbqpYSjY4uqvdhz71Beaztq2UGOlB0GpJTt462JmBN7aiJKQ0b0kc6OkThGo8s4sGGW0DkHa2CYwwqueahesqi9adWSOhcBuInQSeHzZjBuWgDlFRWaml6HWgLeZ2wzlFE2o)NkpKZIGaqOyb27heM42xWvw4l85oaYiHTnW25oaYibMgehT)jsSrjXSrLLOBLT85zJ8cjVEkRegfypiGrFJm3eUWj8syHnNSrz28eOPxjmkWEqaJ(gzUjCj4YMt2kONan9AhNcQASeCzlFE28eOPxzba8qIfyzmJO)GW4ChZbZWrxcUSbDvRBkIR5wLWj8syPs1QuC0(NQeDmWpn8LP3rsvQGKdOD1(NQKdjg2EA2COm9osylu2Ukc5pBenoxiS90SLJAxk4WgvtrbjS9a2c5OhIYMd8NnnaYOswvPdOve0rvApaD4LWLabHP7ucbS5KnkyZtGMED3LcoWEPOGKfrJZf28tmBxfHylFE2OGnkZMlOFqRqadEn0(h2CYgXftjynaYOsw0Xa)0WxMEhjS5Ny2CaB(ZgrXiP3yzbEzbKnOzd6Qw3mhxZTkHt4LWsLQvP4O9pvj6yGFA4ltVJKQ0bItcH1aiJkPU51Q0b0kc6OkrbBuMnxq)GwHag8AO9pSLppBLxxYba8kU0(CPhz2YNNTYRlGGRkaWL2Nl9iZg0S5KT9a0HxcxceeMUtjeWMt2iUykbRbqgvYIog4Ng(Y07iHn)eZ2wQsfKCaTR2)uLCiXW2tZMdLP3rcB6Zw46MGGn3Vj)qyRPzRN4O9oY2pSfdeSPbqgv2O4bSfdeS5LqS0JmBAaKrLWgKTEZMlOFqRqWg41q7FGMTqzBl5w16MIW1CRs4eEjSuPAv6aAfbDuL2dqhEjCjqqy6oLqaBoz78FQ8qoRDCkOQXcGzrpe28JTRuPkfhT)PkHN7Vhzya6c6SykvTUPiun3QeoHxclvQwLoGwrqhvP9a0HxcxceeMUtjeWMt2OGTSGOiaoiKGq6bgGzrpe2eZgvyZjBuMnGWG0pqgxL)Z8srbx4eEjSWw(8S5jqtV8s9uiDbxcUSbDvkoA)tvkY8ei3vTU5vQuZTkHt4LWsLQvP4O9pvPmbTtHIvPdeNecRbqgvsDZRvPdOve0rvApaD4LWLabHP7ucbS5KnIlMsWAaKrLSOJb(PHVm9osytmBIwLki5aAxT)PkLB4TbrKG2Pqr20NTW1nbbBBhgLeeSTXFt(HTqztu20aiJkPQ1nVETMBvcNWlHLkvRshqRiOJQ0Ea6WlHlbcct3PecQsXr7FQszcANcfRAvRsNcPMBDZR1CRs4eEjSuPAvkoA)tvklaxWcm9dGlyO3vPupi8PuLUU2Av6aXjHWAaKrLu38Av6aAfbDuLarxGXDC0vukKLGlBozJc20aiJ6s7mewF4sJSrj2oFM3d7(9OKvbP7tRSTn2UU2kB5ZZ25Z8Ey3VhLSkiDFALn)eZ2Xfol8fM4ItHnORsfKCaTR2)uLebOzlkfcBbaztW1r2it7ISP3iB)GSbzR3SLEirIYwU5UDl2COMGSb5noSvGOhz2OdIIa207yyZNBmBfKUpTY2dydYwVFbLTyGGnFUXRQw3u0AUvjCcVewQuTkfhT)PkLfGlybM(bWfm07Qubjhq7Q9pvjraA2MNTOuiSbzNsSvAKniB9Uh20BKTb9vzBluH4iBceKnre92X2pS59ecBq269lOSfdeS5ZnEvLoGwrqhvjq0fyChhDfLcz1dB(X2wOcBBGnq0fyChhDfLczveaH2)WMt2oFM3d7(9OKvbP7tRS5Ny2oUWzHVWexCkvTU5wQ5wLWj8syPs1Q07wLiOwLIJ2)uL2dqhEjSkThjbSkrz20iHJUMw(wjAKUGGfoHxclSLppBuMnns4Ol0xsmYc9ekUWj8syHT85z78FQ8qol0xsmYc9ekUayw0dHnkX2wzBdSjkBBJnns4ORcIUiaMOGqdzmBHt4LWsvQGKdOD1(NQKeeZHnrgNcQAWgK9uEizdYwVzBZw(wjAKUGa)9rFjXil0tOiBnnBHRBQpHxcRs7baEImSkTJtbvnGNw(wjAKUGa4ZpLw7FQADthuZTkHt4LWsLQvP3TkrqTkfhT)PkThGo8syvApscyvIYSPrchDLfefbWbHeesplCcVewylFE2kVUKda4vCP95spYSLppBNFhNy01oo6nea2CY25Z8Ey3VhLSkiDFALnXSrLQubjhq7Q9pvjh6Ov2(HnrgNcQAWg9dyB7da4vKniB9Mnr0g5iBctcje2GezlaiBHYww4lB(CJzJ(bS5qsHmMsH2)uL2da8ezyvAhNcQAaNfWNFkT2)u16MBTMBvcNWlHLkvRsVBvIGAvkoA)tvApaD4LWQ0EaGNidRs74uqvd4ZVJtmk85NsR9pvPdOve0rv6874eJUUabOJHT85z7874eJUg8a(0dkSLppBNFhNy018dwLki5aAxT)PkjbXCytKXPGQgSbzR3S5qsHmMsH2)Wwmf2KqxstyliSL(rMTGWgKiBq(duv2spbzly7eeLTFhbSP3iB0T8TYwraeA)tvApscyv6AvRBkIR5wLWj8syPs1Q07wLiOwLIJ2)uL2dqhEjSkThjbSkrN(hWgfSrbB0T8TcdWSOhcBBGnrPcBqZguyJc2UkkvyBBSThGo8s4AhNcQAaFka2GMnOzZp2Ot)dyJc2OGn6w(wHbyw0dHTnWMOuHTnW25)u5HCw0PqgtPq7Fwaml6HWg0Sbf2OGTRIsf22gB7bOdVeU2XPGQgWNcGnOzdA2YNNnpbA6fDkKXuk0(hypbA6LGlB5ZZwb9eOPx0PqgtPq7FwcUSLppBEpHWMt2OB5BfgGzrpe2OeBIsLQ0b0kc6OkD(DCIrx74O3qaQs7baEImSkTJtbvnGp)ooXOWNFkT2)u16M54AUvjCcVewQuTk9UvjcQvP4O9pvP9a0HxcRs7rsaRs0P)bSrbBuWgDlFRWaml6HW2gytuQWg0Sbf2OGTRIsf22gB7bOdVeU2XPGQgWNcGnOzdA28Jn60)a2OGnkyJULVvyaMf9qyBdSjkvyBdSD(pvEiNfbDjnzbWSOhcBqZguyJc2UkkvyBBSThGo8s4AhNcQAaFka2GMnOzlFE2kVUiOlPjlTpx6rMT85zZ7je2CYgDlFRWaml6HWgLytuQuLoGwrqhvPZVJtm6AA5BfMoWQ0EaGNidRs74uqvd4ZVJtmk85NsR9pvTUPiCn3QeoHxclvQwLki5aAxT)Pk5qsi5(acALn6hW2glquHeYMpceC1(h2AA2MxzJOyK0BSW2dyRh2c2o)NkpKdBhiojSkDaTIGoQsuWg5fsE9uwUceviHWiqWv7Fw4eEjSWw(8SrEHKxpL1(NcTtim5t74OlCcVewydA2CYgLzJOyK0BSSIuInNSrz2kONan9AhNcQASeCzZjBzbrraCqibH0dmaZIEiSjMnQWMt2OGnCqGmelTZqy9HZcFHpFMxpyHn)ytu2YNNnkZwb9eOPxK7EFj4Yg0vPEueaeCv4MUkrEHKxpL1(NcTtim5t74OvPEueaeCv4oldlDOyv6AvkoA)tvIoHK7diO1QupkcacUkSC69Iuv6AvRBkcvZTkHt4LWsLQvP4O9pvj6uiJPuO9pvPcsoG2v7FQssqmh2CiPqgtPq7FydYwVztKXPGQgSfe2s)iZwqydsKni)bQkBPNGSfSDcIY2VJa20BKn6w(wzRiacT)HnkEaBnnBImofu1Gni7uITZNHS5fNlSfYrpqPjSPVSCclS900qVQshqRiOJQeLzJOyK0BSSaVSaYMt2OGTZ)PYd5S2XPGQglaMf9qyJsSTf2CY2Ea6WlHRDCkOQbCwaF(P0A)dBozdPPXJ27i85Z8Ey3VhLWMFIzZbS5KnnaYOU0odH1hU0iB(X2vQWw(8SvqpbA61oofu1yj4Yw(8S59ecBozJULVvyaMf9qyJsSjQdyd6Qw38kvQ5wLWj8syPs1Q0b0kc6Okrz2ikgj9gllWllGS5KnKMgpAVJWNpZ7HD)EucB(jMnhWMt2OGn60)a2OGnkyJULVvyaMf9qyBdSjQdydA2GcBuWwC0(h4Z)PYd5W22yBpaD4LWfDkKXuk0(h4tbWg0SbnB(XgD6FaBuWgfSr3Y3kmaZIEiSTb2e1bSTb2o)NkpKZAhNcQASayw0dHTTX2Ea6WlHRDCkOQb8PaydA2GcBuWwC0(h4Z)PYd5W22yBpaD4LWfDkKXuk0(h4tbWg0SbnBqxLIJ2)uLOtHmMsH2)u16MxVwZTkHt4LWsLQvP4O9pvjc6sAsvQGKdOD1(NQKeeZHnj0L0e2GS1B2ezCkOQbBbHT0pYSfe2GezdYFGQYw6jiBbBNGOS97iGn9gzJULVv2kcGq7FCKnpbLnxasJa20aiJkHn9ou2GStj2s9oYwOSLWGOSDLkKQ0b0kc6Okrz2ikgj9gllWllGS5Knky78FQ8qoRDCkOQXcGzrpe2OeBxzZjBAaKrDPDgcRpCPr28JTRuHT85zRGEc00RDCkOQXsWLT85zJULVvyaMf9qyJsSDLkSbDvRBEv0AUvjCcVewQuTkDaTIGoQsuMnIIrsVXYc8YciBozJc2Ot)dyJc2OGn6w(wHbyw0dHTnW2vQWg0Sbf2IJ2)aF(pvEih2GMn)yJo9pGnkyJc2OB5BfgGzrpe22aBxPcBBGTZ)PYd5S2XPGQglaMf9qyBBSThGo8s4AhNcQAaFka2GMnOWwC0(h4Z)PYd5Wg0SbDvkoA)tvIGUKMu16Mx3sn3QeoHxclvQwLoGwrqhvjkZgrXiP3yzbEzbKnNSvEDbeCvbaU0(CPhz2CYgLzRGEc00RDCkOQXsWLnNSThGo8s4AhNcQAapT8Ts0iDbbWNFkT2)WMt22dqhEjCTJtbvnGZc4ZpLw7FyZjB7bOdVeU2XPGQgWNFhNyu4ZpLw7FQsXr7FQs74uqvJQw38QdQ5wLWj8syPs1QuC0(NQe6ljgzHEcfRsfKCaTR2)uL8rFjXil0tOiBqEJdBZRSrums6nwylMcBEVEZMdl4QcaKTykST9ba8kYwaq2eCzJ(bSL(rMnCEb57vv6aAfbDuLOmBefJKEJLf4Lfq2CYgfSrz2kVUKda4vCbqAasUdVeYMt2kVUacUQaaxaml6HWMFS5a28NnhW22y74cNf(ctCXPWw(8SvEDbeCvbaUayw0dHTTXgvwBLn)ytdGmQlTZqy9HlnYg0S5KnnaYOU0odH1hU0iB(XMdQADZRBTMBvcNWlHLkvRsXr7FQsK7EVkvqYb0UA)tvs6U3zRPzdsKTaGSfEVGYM(S5JZooFMJSftHTqvmZvztF2iqmh2GS1B2KqxstyJUNiX2DRS10SbjYgK)avLnidIISL9aKn9og2UJenB6nY25)u5HCwvPdOve0rvQ86soaGxXL2Nl9iZMt2kVUacUQaaxAFU0JmBozJc2OmBN)tLhYzrqxstwamkqWw(8SD(pvEiN1oofu1ybWSOhcB(X2vrzdA2YNNTYRlc6sAYs7ZLEKRADZRI4AUvjCcVewQuTkDaTIGoQsEc00lV0)LKarxamokB5ZZM3tiS5Kn6w(wHbyw0dHnkX2wOcB5ZZwb9eOPx74uqvJLGBvkoA)tvY91(NQw38AoUMBvcNWlHLkvRshqRiOJQub9eOPx74uqvJLGBvkoA)tvYl9FbMwaarvRBEveUMBvcNWlHLkvRshqRiOJQub9eOPx74uqvJLGBvkoA)tvYdbeeCPh5Qw38Qiun3QeoHxclvQwLoGwrqhvPc6jqtV2XPGQglb3QuC0(NQeDdqV0)LQw3uuQuZTkHt4LWsLQvPdOve0rvQGEc00RDCkOQXsWTkfhT)PkfZbjkisWNiLQADtrVwZTkHt4LWsLQvPdOve0rvIYSrums6nwwrkXMt2YcIIa4GqccPhyaMf9qytmBuPkfhT)PkDIucooA)dCQjAvk1efEImSkThttURADtrfTMBvcNWlHLkvRsXr7FQskONlOETkvqYb0UA)tvscI5WMEJS5c6h0keSr0qzZtGMMnf0ZfuzdYwVztKXPGQgoY2R3iaYMGSjqq2(HTZ)PYd5uLoGwrqhvP9a0HxcxkONlOctGyoWK0RSjMTRS5KnkyRGEc00RDCkOQXsWLT85zZ7je2CYgDlFRWaml6HWgLeZMOuHnOzlFE2OGT9a0HxcxkONlOctGyoWK0RSjMnrzZjBuMnf0ZfuxQORZ)PYd5SayuGGnOzlFE2OmB7bOdVeUuqpxqfMaXCGjPxRADtr3sn3QeoHxclvQwLoGwrqhvP9a0HxcxkONlOctGyoWK0RSjMnrzZjBuWwb9eOPx74uqvJLGlB5ZZM3tiS5Kn6w(wHbyw0dHnkjMnrPcBqZw(8SrbB7bOdVeUuqpxqfMaXCGjPxztmBxzZjBuMnf0Zfux6115)u5HCwamkqWg0SLppBuMT9a0HxcxkONlOctGyoWK0RvP4O9pvjf0ZfufTQvTkvETMBDZR1CRs4eEjSuPAv6DRseuRsXr7FQs7bOdVewL2JKawLCb9dAfcyWRH2)WMt2OGTYRl5aaEfxaml6HWgLy78FQ8qol5aaEfxfbqO9pSLppB7bOdVeUaOmoWKqfaHIf2GUkvqYb0UA)tvYh6SwzJGNFkbac22(aaEfjSr)a2Cb9dAfc2aVgA)dBnnBqISDh7iBBzRSHdcKHGnakJdBpGTTpaGxr2GStj2qFDBaY2pSP3iBUGolaqWMgazuRs7baEImSkrU0UWhiojewoaGxXQw3u0AUvjCcVewQuTk9UvjcQvP4O9pvP9a0HxcRs7rsaRsUG(bTcbm41q7FyZjBuWwb9eOPxK7EFj4YMt2iUykbRbqgvYIog4Ng(Y07iHn)ytu2YNNT9a0HxcxaughysOcGqXcBqxLki5aAxT)Pk5dDwRSrWZpLaabBoSGRkaqcB0pGnxq)GwHGnWRH2)WwtZgKiB3XoY2w2kB4GaziydGY4W2dyt6U3zRjSj4Y2pSjAU(xL2da8ezyvICPDHpqCsimqWvfayvRBULAUvjCcVewQuTk9UvjcQvP4O9pvP9a0HxcRs7rsaRsf0tGMETJtbvnwcUS5KnkyRGEc00lYDVVeCzlFE2YcIIa4GqccPhyaMf9qyZp2OcBqZMt2kVUacUQaaxaml6HWMFSjAvQGKdOD1(NQKp0zTYMdl4QcaKWwtZMiJtbvn8x6U3HIikikcyBJiKGq6HTMWMGlBXuydsKT7yhztu)zJGNFke2siTY2pSP3iBoSGRkaq22Up3Q0EaGNidRsKlTlmqWvfayvRB6GAUvjCcVewQuTkfhT)PkjhaWRyvQGKdOD1(NQKKlE6iX22haWRiBXuyZHfCvbaYgbvbx2Cb9dytF28rFjXil0tOiBNGOvPdOve0rvsJeo6c9LeJSqpHIlCcVewyZjBuMTc6jqtVKda4vCH(sIrwONqXcBozR86soaGxXLBMqsB3uJa2OKy2UYMt2o)NkpKZc9LeJSqpHIlaMf9qyJsSjkBozJ4IPeSgazujl6yGFA4ltVJe2eZ2v2CYgi6cmUJJUIsHS6Hn)yteZMt2kVUKda4vCbWSOhcBBJnQS2kBuInnaYOU0odH1hU0yvRBU1AUvjCcVewQuTkDaTIGoQsAKWrxOVKyKf6juCHt4LWcBozJc2qAA8O9ocF(mVh297rjS5Ny2oUWzHVWexCkS5KTZ)PYd5SqFjXil0tO4cGzrpe2OeBxzZjBLxxabxvaGlaMf9qyBBSrL1wzJsSPbqg1L2ziS(WLgzd6QuC0(NQeqWvfayvRBkIR5wLWj8syPs1QuC0(NQK7)jyasEbWbRsfKCaTR2)uL2(aaEfztW9cIUoYwKipBkOrcB6ZMabzRv2ccBbBex80rInzCqqOpGn6hWMEJSLcIYMp3y28q6hGSfSr3ttUrqvI(bWd6Rw38AvRBMJR5wLWj8syPs1Q0b0kc6OkbqAasUdVeYMt2oFM3d7(9OKvbP7tRS5Ny2UYMt2OGn3mHK2UPgbSrjXSDLT85zdGzrpe2OKy20(Cbw7mKnNSrCXucwdGmQKfDmWpn8LP3rcB(jMTTWg0S5KnkyJYSH(sIrwONqXcB5ZZgaZIEiSrjXSP95cS2ziBBJnrzZjBexmLG1aiJkzrhd8tdFz6DKWMFIzBlSbnBozJc20aiJ6s7mewF4sJSTb2ayw0dHnOzZp2CaBozllikcGdcjiKEGbyw0dHnXSrLQuC0(NQKCaaVIvTUPiCn3QeoHxclvQwLOFa8G(Q1nVwLIJ2)uLC)pbdqYlaoyvRBkcvZTkHt4LWsLQvP4O9pvj5aaEfRshqRiOJQeLzBpaD4LWf5s7cFG4Kqy5aaEfzZjBaKgGK7WlHS5KTZN59WUFpkzvq6(0kB(jMTRS5KnkyZntiPTBQraBusmBxzlFE2ayw0dHnkjMnTpxG1odzZjBexmLG1aiJkzrhd8tdFz6DKWMFIzBlSbnBozJc2OmBOVKyKf6juSWw(8SbWSOhcBusmBAFUaRDgY22ytu2CYgXftjynaYOsw0Xa)0WxMEhjS5Ny22cBqZMt2OGnnaYOU0odH1hU0iBBGnaMf9qydA28JTRIYMt2YcIIa4GqccPhyaMf9qytmBuPkDG4KqynaYOsQBETQ1nVsLAUvjCcVewQuTkfhT)PkDaDg5hyfZCrIwLoqCsiSgazuj1nVwLoGwrqhvjIlMsWAaKrLWMFIztu2CYgstJhT3r4ZN59WUFpkHn)eZMdyZjB4Gaziwaugh4ZN51dwyZp2eLkS5KnkyJYSD(pvEiN1oofu1ybWOabB5ZZw51fqWvfa4s7ZLEKzdA2CYgaZIEiSrj2eLn)zBlSTn2OGnIlMsWAaKrLWMFIzZbSbDvQGKdOD1(NQKpbDg5h2YfZCrIY2pSLjK02nHSPbqgvcBHYMd8NnFUXSb5noSbeMPhz2EbLTEyt0nSvcBbHT0pYSfe2Gez7o2r2W5fKVzdGY4Wwmf2caoqvzJGQ2JmBcUSr)a2ezCkOQrvRBE9An3QeoHxclvQwLIJ2)uLacUQaaRsfKCaTR2)uLCOGOlBcUS5WcUQaazlu2CG)S9dBrkXMgazujSrbK34WwQ37rMT0pYSHZliFZwmf2MxzJmHl5(vORshqRiOJQeLzBpaD4LWf5s7cdeCvbaYMt2qAA8O9ocF(mVh297rjS5Ny2CaBozdG0aKChEjKnNSrbBUzcjTDtncyJsIz7kB5ZZgaZIEiSrjXSP95cS2ziBozJ4IPeSgazujl6yGFA4ltVJe28tmBBHnOzZjBuWgLzd9LeJSqpHIf2YNNnaMf9qyJsIzt7ZfyTZq22gBIYMt2iUykbRbqgvYIog4Ng(Y07iHn)eZ2wydA2CYMgazuxANHW6dxAKTnWgaZIEiS5hBuWMdyZF2OGnGWG0pqgxLGC3Jmm58ctbGPfoHxclSTn22kBqZM)SrbBaHbPFGmUk)N5LIcUWj8syHTTX2wzdA28NnkyBpaD4LWfaLXbMeQaiuSW22yteZg0SbDvRBEv0AUvjCcVewQuTkfhT)PkbeCvbawLoGwrqhvjkZ2Ea6WlHlYL2f(aXjHWabxvaGS5KnkZ2Ea6WlHlYL2fgi4QcaKnNSH004r7De(8zEpS73JsyZpXS5a2CYgaPbi5o8siBozJc2CZesA7MAeWgLeZ2v2YNNnaMf9qyJsIzt7ZfyTZq2CYgXftjynaYOsw0Xa)0WxMEhjS5Ny22cBqZMt2OGnkZg6ljgzHEcflSLppBaml6HWgLeZM2NlWANHSTn2eLnNSrCXucwdGmQKfDmWpn8LP3rcB(jMTTWg0S5KnnaYOU0odH1hU0iBBGnaMf9qyZp2OGnhWM)SrbBaHbPFGmUkb5UhzyY5fMcatlCcVewyBBSTv2GMn)zJc2acds)azCv(pZlffCHt4LWcBBJTTYg0S5pBuW2Ea6WlHlakJdmjubqOyHTTXMiMnOzd6Q0bItcH1aiJkPU51Qw386wQ5wLWj8syPs1QuC0(NQ0b0zKFGvmZfjAvQGKdOD1(NQKdjsjV4CHTn69r28jOZi)WwUyMlsu2GS1B20BKnsKHSLE5(Wwqyl8(D0r28eu2A55b9iZMEJSHdcKHGTZpLw7FiS10SbjYwaWbQkBcKEKzZHfCvbawLoGwrqhvjIlMsWAaKrLWMFIztu2CYgstJhT3r4ZN59WUFpkHn)eZMdyZjBaml6HWgLytu28NTTW22yJc2iUykbRbqgvcB(jMnhWg0vTU5vhuZTkHt4LWsLQvP4O9pvPdOZi)aRyMls0Qubjhq7Q9pvjFc6mYpSLlM5IeLTFytkx2AA26Hn3ykywFylMcBdgGeeSLf(Ygoiqgc2IPWwtZMpo748zSb5pqvzR8SL9aKTsKfYiBfbKn9zlxQcfr0gvLoGwrqhvjIlMsWAaKrLWMy2UYMt2OmBaHbPFGmUkb5UhzyY5fMcatlCcVewyZjBzbrraCqibH0dmaZIEiSjMnQWMt2qAA8O9ocF(mVh297rjS5Ny2OGTJlCw4lmXfNcBBGTRSbnBozdG0aKChEjKnNSrz2qFjXil0tOyHnNSrbBuMTc6jqtVi39(sWLnNSrbB4GaziwfKUpTYgLeZMOBLn)zdheidXcGY4aF(mVEWcBqZg0S5KnnaYOU0odH1hU0iBBGnaMf9qyZp2CqvRAvRs7iG0)u3uuQi6vQKJPYwRsqgGPhzsvYHEJC4nfb2C7fj2yl3BKToZ9bkB0pGnOUhttUHkBamhrObyHnYNHSfc6Nfkwy7ChJmswm1(qpiBxfj285p7iqXcBqfimi9dKXvoav20NnOcegK(bY4khw4eEjSav2OquFHEXu7d9GSjIfj285p7iqXcBqfimi9dKXvoav20NnOcegK(bY4khw4eEjSav2O4QVqVyQzQDO3ihEtrGn3ErIn2Y9gzRZCFGYg9dydQUa88zEHcv2ayoIqdWcBKpdzle0pluSW25ogzKSyQ9HEq2CGiXMp)zhbkwydQKxi51tzLdqLn9zdQKxi51tzLdlCcVewGkBuC1xOxm1(qpiBoqKyZN)SJaflSbvYlK86PSYbOYM(SbvYlK86PSYHfoHxclqLTqzZhDOIpWgfx9f6ftTp0dY2wfj285p7iqXcBqfimi9dKXvoav20NnOcegK(bY4khw4eEjSav2O4QVqVyQ9HEq2eXIeB(8NDeOyHnOcegK(bY4khGkB6Zgubcds)azCLdlCcVewGkBuC1xOxm1(qpiB5yrInF(ZocuSWguvqpxqDDDLdqLn9zdQkONlOU0RRCaQSrHd8f6ftTp0dYwowKyZN)SJaflSbvf0ZfuxIUYbOYM(Sbvf0ZfuxQORCaQSrHO(c9IP2h6bztewKyZN)SJaflSbvf0Zfuxxx5auztF2GQc65cQl96khGkBuiQVqVyQ9HEq2eHfj285p7iqXcBqvb9Cb1LORCaQSPpBqvb9Cb1Lk6khGkBu4aFHEXuZu7qVro8MIaBU9IeBSL7nYwN5(aLn6hWgulnapkuzdG5icnalSr(mKTqq)SqXcBN7yKrYIP2h6bztesKyZN)SJaflSbvGWG0pqgx5auztF2Gkqyq6hiJRCyHt4LWcuzJIR(c9IPMP2HEJC4nfb2C7fj2yl3BKToZ9bkB0pGnOEkeOYgaZreAawyJ8ziBHG(zHIf2o3XiJKftTp0dYMiwKyZN)SJaflSj1z(KnceJg(YMiiB6ZMpieSv69M0)W27IGqFaBuafOzJcr9f6ftTp0dYwowKyZN)SJaflSj1z(KnceJg(YMiiB6ZMpieSv69M0)W27IGqFaBuafOzJcr9f6ftTp0dYMiSiXMp)zhbkwydQKxi51tzLdqLn9zdQKxi51tzLdlCcVewGkBuiQVqVyQ9HEq2UsfrInF(ZocuSWMuN5t2iqmA4lBIGSPpB(GqWwP3Bs)dBVlcc9bSrbuGMnke1xOxm1(qpiBxfvKyZN)SJaflSj1z(KnceJg(YMiiB6ZMpieSv69M0)W27IGqFaBuafOzJcr9f6ftTp0dYMOIksS5ZF2rGIf2GQc65cQlrx5auztF2GQc65cQlv0voav2O4QVqVyQ9HEq2eDlIeB(8NDeOyHnOQGEUG666khGkB6ZguvqpxqDPxx5auzJIR(c9IPMP2HEJC4nfb2C7fj2yl3BKToZ9bkB0pGnOwEfQSbWCeHgGf2iFgYwiOFwOyHTZDmYizXu7d9GS5arInF(ZocuSWgurFjXil0tOyzLdqLn9zdQf0tGMELdl0xsmYc9ekwGkBuC1xOxm1(qpiBxVksS5ZF2rGIf2Gkqyq6hiJRCaQSPpBqfimi9dKXvoSWj8sybQSrHO(c9IP2h6bz7QOIeB(8NDeOyHnOcegK(bY4khGkB6Zgubcds)azCLdlCcVewGkBuiQVqVyQ9HEq2U6arInF(ZocuSWgubcds)azCLdqLn9zdQaHbPFGmUYHfoHxclqLnkU6l0lMAM6CVr2GQabHBfZiqLT4O9pSbzqyBELn6xykS1dB6DtyRZCFGUyQfbYCFGIf2YXSfhT)HTutuYIPUkrCXtDtr3QiuvYf80DcRs5mNSTresqi9eA)dBo8llGm15mNSrTqcc2e9QJSjkve9ktntDoZjB(8ogzKism15mNSTb22ix3eeSbvIc6Jcv2OtHmB6Zg5Zq22On2hyJ(bxiSPpBKyhzZf8hKq6rMnTZWftDoZjBBGTT7hOQSjYX0KB2eMesiSjL6dYwmf22U(GSbzNsSLcIYw6hzeWMEhdBIOGOiGTnIqccPNftDoZjBBGnhgtHVS5qsHmMsH2)WguytKXPGQgSrGyoSrrtZMiJtbvnyRjSPVSCclS900S9a2(HTGT0pYS5ZTd6ftDoZjBBGnruCbzZHKqY9be0kB9Oiai4QS1dBNpZlu2AA2GezlhTarzR0f2ALn6hW2(NcTtim5t74OlMAM6CMt28rFXJGIf28q6hGSD(mVqzZdL7HSyBJoh0vjSn)SH7aKrlKyloA)dHTFsqSyQJJ2)qwUa88zEHkoCDtqa7(n5hM64O9pKLlapFMxO(lgkEVQjSatNciWcK9idRVV9WuhhT)HSCb45Z8c1FXqjlaxWcm9dGlyO3o6cWZN5fkmbp)uiI3QJnTyq0fyChhDfLcz1JFx3ktDC0(hYYfGNpZlu)fdf6esUpGGwDSPftEHKxpLLRarfsimceC1(N85jVqYRNYA)tH2jeM8PDCuM64O9pKLlapFMxO(lgk7bOdVe64ezO4DCkOQb8PaCCpscO4RBGcGWG0pqgxfbYfiJ0feqGDd9CVnQSCWwHMPoNSL7nYwSJGqgzZNBNdZwtyJklrfLnpbLTIaYM(SP3iBo8MBpBtOcaKTNMnFUXSjJJJSjQVSP3nHT9ijGS1e2ExTZIeB0pGnceZPhz2sVCFyQJJ2)qwUa88zEH6VyOShGo8sOJtKHIPtHmMsH2)aFkah3JKak(6gOaimi9dKX17HLgNdUnQSCGdGMPoNSTDOIGSEq2G8Up3SrrtZwmqanBenu28eOPztb9Cbv2GezdYyu20NTqvmZvztF2iqmh2GS1B2ezCkOQXIPooA)dz5cWZN5fQ)IHYEa6WlHoorgkwb9CbvyceZbMKE1X9ijGIV6ytlwb9Cb1111DqGjAORyGaU4sCsbLvqpxqDj66oiWen0vmqaxCj5ZRGEUG66668FQ8qoRIai0(h)eRGEUG6s015)u5HCwfbqO9pqNpVc65cQRRRMS6HCacA4Lq4CeHyuHm4cU3hmFEkuqpxqDDD1Kf5okpKYGG4cRVIzop)ooXORDC0BiaqZuhhT)HSCb45Z8c1FXqzpaD4LqhNidfRGEUGkmbI5atsV64EKeqXI6ytlwb9Cb1LOR7Gat0qxXabCXL4KckRGEUG6666oiWen0vmqaxCj5ZRGEUG6s015)u5HCwfbqO9p(PGEUG66668FQ8qoRIai0(hOZNxb9Cb1LORMS6HCacA4Lq4CeHyuHm4cU3hmFEkuqpxqDj6QjlYDuEiLbbXfwFfZCE(DCIrx74O3qaGMPooA)dz5cWZN5fQ)IHcj1heoMcCPpOJUa88zEHctWZpfI4Ro20Ibinaj3HxczQJJ2)qwUa88zEH6VyOqums6ntntDoZjB(OV4rqXcB4ocGGnTZq20BKT4OpGTMWwShDk8s4IPooA)dr8L(CHPoNS5WirXiP3S10S5(es7Lq2OyE22fsdccVeYgoywJe26HTZN5fk0m1Xr7Fi(lgkefJKEZuhhT)H4VyOShGo8sOJtKHIj9iNqynaYO64EKeqXexmLG1aiJkzrhd8tdFz6DKqjrzQZjB(8Z86blS5JdcKHGnhgLXHTbXcwytF2iHkacfzQJJ2)q8xmu2dqhEj0XjYqXaughysOcGqXIJ7rsafJdcKHybqzCGpFMxpyXVTSvM64O9pe)fdLtKsWXr7FGtnrDCImumrXiP3yXrIc6Jk(QJnTyIIrsVXYc8YcitDC0(hI)IHYjsj44O9pWPMOoorgk(uim15KTnwqztA2o2eCzRNw7iLGGn6hWMpfu20Nn9gzZN3bbDKnasdqYnBq26nB(4SJZNXwtZwOSLEizRiacT)HPooA)dXFXqHK6dchtbU0h0XMwmL9eOPxKuFq4ykWL(GlbxNNpZ7HD)EuIFIVYuhhT)H4VyOGZooFMJnTypbA6fj1heoMcCPp4sW1PNan9IK6dchtbU0hCbWSOhcL2QZZN59WUFpkXpXoGPooA)dXFXq5ePeCC0(h4utuhNidfxELPooA)dXFXq5ePeCC0(h4utuhNidfxAaEuM64O9pe)fdLaCIbH1haWrDSPfJdcKHyvq6(0QFIVUv)XbbYqSaOmoWNpZRhSWuhhT)H4VyOeGtmiSRqIGm1Xr7Fi(lgkPw(wjW5OfkYz4Om1Xr7Fi(lgkEHm8tdRG(CHWuZuNZCYMp)pvEihctDozteGMTOuiSfaKnbxhzJmTlYMEJS9dYgKTEZw6HejkB5M72TyZHAcYgK34WwbIEKzJoikcytVJHnFUXSvq6(0kBpGniB9(fu2Ibc285gVyQJJ2)qwNcXFXqjlaxWcm9dGlyO3oM6bHpfXxxB1XdeNecRbqgvI4Ro20IbrxGXDC0vukKLGRtk0aiJ6s7mewF4sJu68zEpS73JswfKUpTUTRRTMp)5Z8Ey3VhLSkiDFA1pXhx4SWxyIlofOzQZjBIa0SnpBrPqydYoLyR0iBq26DpSP3iBd6RY2wOcXr2eiiBIi6TJTFyZ7je2GS17xqzlgiyZNB8IPooA)dzDke)fdLSaCblW0paUGHE7ytlgeDbg3XrxrPqw943wOYgarxGXDC0vukKvraeA)JZZN59WUFpkzvq6(0QFIpUWzHVWexCkm15KnjiMdBImofu1Gni7P8qYgKTEZ2MT8Ts0iDbb(7J(sIrwONqr2AA2cx3uFcVeYuhhT)HSofI)IHYEa6WlHoorgkEhNcQAapT8Ts0iDbbWNFkT2)44EKeqXuwJeo6AA5BLOr6ccw4eEjSKppL1iHJUqFjXil0tO4cNWlHL85p)NkpKZc9LeJSqpHIlaMf9qO0w3GOBtJeo6QGOlcGjki0qgZw4eEjSWuNt2COJwz7h2ezCkOQbB0pGTTpaGxr2GS1B2erBKJSjmjKqydsKTaGSfkBzHVS5ZnMn6hWMdjfYykfA)dtDC0(hY6ui(lgk7bOdVe64ezO4DCkOQbCwaF(P0A)JJ7rsaftzns4ORSGOiaoiKGq6zHt4LWs(8LxxYba8kU0(CPh585p)ooXORDC0BiaopFM3d7(9OKvbP7tRIPctDoztcI5WMiJtbvnydYwVzZHKczmLcT)HTykSjHUKMWwqyl9JmBbHnir2G8hOQSLEcYwW2jikB)ocytVr2OB5BLTIai0(hM64O9pK1Pq8xmu2dqhEj0XjYqX74uqvd4ZVJtmk85NsR9po20Ip)ooXORlqa6yYN)874eJUg8a(0dk5ZF(DCIrxZpOJ7rsafFLPooA)dzDke)fdL9a0HxcDCImu8oofu1a(874eJcF(P0A)JJnT4ZVJtm6Ahh9gcGJ7rsaftN(hqbf0T8TcdWSOhYgeLkqlcsXvrPY22dqhEjCTJtbvnGpfa0q7hD6Fafuq3Y3kmaZIEiBquQSHZ)PYd5SOtHmMsH2)Sayw0dbArqkUkkv22Ea6WlHRDCkOQb8PaGg6859eOPx0PqgtPq7FG9eOPxcU5ZxqpbA6fDkKXuk0(NLGB(8EpH4KULVvyaMf9qOKOuHPooA)dzDke)fdL9a0HxcDCImu8oofu1a(874eJcF(P0A)JJnT4ZVJtm6AA5BfMoqh3JKakMo9pGckOB5BfgGzrpKnikvGweKIRIsLTThGo8s4AhNcQAaFkaOH2p60)akOGULVvyaMf9q2GOuzdN)tLhYzrqxstwaml6HaTiifxfLkBBpaD4LW1oofu1a(uaqdD(8Lxxe0L0KL2Nl9iNpV3tioPB5BfgGzrpekjkvyQZjBoKesUpGGwzJ(bSTXceviHS5JabxT)HTMMT5v2ikgj9glS9a26HTGTZ)PYd5W2bItczQJJ2)qwNcXFXqHoHK7diOvhBAXuqEHKxpLLRarfsimceC1(N85jVqYRNYA)tH2jeM8PDCuODszIIrsVXYksjNuUGEc00RDCkOQXsW1zwqueahesqi9adWSOhIyQ4KcCqGmelTZqy9HZcFHpFMxpyXprZNNYf0tGMErU79LGl0o2JIaGGRc3zzyPdffF1XEueaeCvy507fjXxDShfbabxfUPftEHKxpL1(NcTtim5t74Om15KnjiMdBoKuiJPuO9pSbzR3SjY4uqvd2ccBPFKzliSbjYgK)avLT0tq2c2obrz73raB6nYgDlFRSveaH2)WgfpGTMMnrgNcQAWgKDkX25Zq28IZf2c5OhO0e20xwoHf2EAAOxm1Xr7FiRtH4VyOqNczmLcT)XXMwmLjkgj9gllWllGoP48FQ8qoRDCkOQXcGzrpekTfN7bOdVeU2XPGQgWzb85NsR9porAA8O9ocF(mVh297rj(j2bo1aiJ6s7mewF4sJ(DLk5ZxqpbA61oofu1yj4MpV3tioPB5BfgGzrpekjQdGMPooA)dzDke)fdf6uiJPuO9po20IPmrXiP3yzbEzb0jstJhT3r4ZN59WUFpkXpXoWjf0P)buqbDlFRWaml6HSbrDa0IGuC(pvEiNTThGo8s4IofYykfA)d8PaGgA)Ot)dOGc6w(wHbyw0dzdI6GnC(pvEiN1oofu1ybWSOhY22dqhEjCTJtbvnGpfa0IGuC(pvEiNTThGo8s4IofYykfA)d8PaGgAOzQZjBsqmh2KqxstydYwVztKXPGQgSfe2s)iZwqydsKni)bQkBPNGSfSDcIY2VJa20BKn6w(wzRiacT)Xr28eu2CbincytdGmQe207qzdYoLyl17iBHYwcdIY2vQqyQJJ2)qwNcXFXqHGUKM4ytlMYefJKEJLf4LfqNuC(pvEiN1oofu1ybWSOhcLU6udGmQlTZqy9Hln63vQKpFb9eOPx74uqvJLGB(80T8TcdWSOhcLUsfOzQJJ2)qwNcXFXqHGUKM4ytlMYefJKEJLf4LfqNuqN(hqbf0T8TcdWSOhYgUsfOfbp)NkpKd0(rN(hqbf0T8TcdWSOhYgUsLnC(pvEiN1oofu1ybWSOhY22dqhEjCTJtbvnGpfa0IGN)tLhYbAOzQJJ2)qwNcXFXqzhNcQA4ytlMYefJKEJLf4LfqNLxxabxvaGlTpx6r2jLlONan9AhNcQASeCDUhGo8s4AhNcQAapT8Ts0iDbbWNFkT2)4CpaD4LW1oofu1aolGp)uAT)X5Ea6WlHRDCkOQb853Xjgf(8tP1(hM6CYMp6ljgzHEcfzdYBCyBELnIIrsVXcBXuyZ71B2CybxvaGSftHTTpaGxr2caYMGlB0pGT0pYSHZliFVyQJJ2)qwNcXFXqb9LeJSqpHIo20IPmrXiP3yzbEzb0jfuU86soaGxXfaPbi5o8sOZYRlGGRkaWfaZIEi(5a)DW2oUWzHVWexCk5ZxEDbeCvbaUayw0dzBuzTv)0aiJ6s7mewF4sJq7udGmQlTZqy9Hln6NdyQZjBs39oBnnBqISfaKTW7fu20NnFC2X5ZCKTykSfQIzUkB6ZgbI5WgKTEZMe6sAcB09ej2UBLTMMnir2G8hOQSbzquKTShGSP3XW2DKOztVr2o)NkpKZIPooA)dzDke)fdfYDV7ytlU86soaGxXL2Nl9i7S86ci4QcaCP95spYoPGYN)tLhYzrqxstwamkqKp)5)u5HCw74uqvJfaZIEi(DvuOZNV86IGUKMS0(CPhzM64O9pK1Pq8xmuCFT)XXMwSNan9Yl9Fjjq0faJJMpV3tioPB5BfgGzrpekTfQKpFb9eOPx74uqvJLGltDC0(hY6ui(lgkEP)lW0caiCSPfxqpbA61oofu1yj4YuhhT)HSofI)IHIhcii4spYo20IlONan9AhNcQASeCzQJJ2)qwNcXFXqHUbOx6)IJnT4c6jqtV2XPGQglbxM64O9pK1Pq8xmuI5Gefej4tKso20IlONan9AhNcQASeCzQJJ2)qwNcXFXq5ePeCC0(h4utuhNidfVhttUDSPftzIIrsVXYksjNzbrraCqibH0dmaZIEiIPctDoztcI5WMEJS5c6h0keSr0qzZtGMMnf0ZfuzdYwVztKXPGQgoY2R3iaYMGSjqq2(HTZ)PYd5WuhhT)HSofI)IHIc65cQxDSPfVhGo8s4sb9CbvyceZbMKEv8vNuuqpbA61oofu1yj4MpV3tioPB5BfgGzrpekjwuQaD(8uShGo8s4sb9CbvyceZbMKEvSOoPSc65cQlrxN)tLhYzbWOab05Zt59a0HxcxkONlOctGyoWK0Rm1Xr7FiRtH4VyOOGEUGQOo20I3dqhEjCPGEUGkmbI5atsVkwuNuuqpbA61oofu1yj4MpV3tioPB5BfgGzrpekjwuQaD(8uShGo8s4sb9CbvyceZbMKEv8vNuwb9Cb11115)u5HCwamkqaD(8uEpaD4LWLc65cQWeiMdmj9ktntDoZjBBxdWJYwjYczKTWRtT2iHPoNS5JZooFgBHYMd8Nnk2Q)SbzR3STDsqZMp34fBIazzyPdftqW2pSjQ)SPbqgvIJSbzR3SjY4uqvdhz7bSbzR3SLlvDOkBVEJaiBcYgKrRSr)a2iFgYgoiqgIfBBuI8Sbz0kBnnB(OVez2oFM3Zwty78z9iZMG7IPooA)dzvAaEuX4SJZN5ytlgPPXJ27i85Z8Ey3VhL4Nyh4VgjC0vbrxeatuqOHmMTWj8syXjff0tGMETJtbvnwcU5ZxqpbA6f5U3xcU5ZxqpbA6fDkKXuk0(NLGB(84GaziwfKUpTsjXIUv)XbbYqSaOmoWNpZRhSKppL3dqhEjCr6roHWAaKrfANuqzns4Ol0xsmYc9ekUWj8syjF(Z)PYd5SqFjXil0tO4cGzrpe)efAM64O9pKvPb4r9xmu2dqhEj0XjYqXceeMUtje44EKeqXNpZ7HD)EuYQG09Pv)UMppoiqgIvbP7tRusSOB1FCqGmelakJd85Z86bl5Zt59a0HxcxKEKtiSgazuzQZjBBKRBcc2KOQeB6ZwKsSPbqgvcBq269lOSfSvqpbAA2ccBUG(bTcHJS5cqAea6rMnnaYOsyRarpYSr(FqaBbTIa20BKnxqNfaiytdGmQm1Xr7FiRsdWJ6VyOqqaiuSa79dctC7lOJnT49a0HxcxceeMUtje4KYLxxeeacflWE)GWe3(ccxEDP95spYm1Xr7FiRsdWJ6VyOqqaiuSa79dctC7lOJhiojewdGmQeXxDSPfVhGo8s4sGGW0DkHaNuU86IGaqOyb27heM42xq4YRlTpx6rMPoNS5qFJdBIOnITMW28kBHY2DlFZwraeA)JJSjqq2KOQeB6Zw46MGGnFaJcBEqWMp6BK5Mq2kcGEKztKXPGQgoY2R3iaYMGSDbrx2ObFgBNW1Thz2o3bqgjm1Xr7FiRsdWJ6VyOqqaiuSa79dctC7lOJnT49a0HxcxceeMUtje4mlikcGdcjiKEGbyw0dHsuzjc7Kc6w(wHbyw0dHsI3A(8N)tLhYzrqaiuSa79dctC7l4kl8f(ChazKSHZDaKrcmnioA)tKOKyQSeDR5ZtEHKxpLvcJcSheWOVrMBcx4eEjS4KYEc00RegfypiGrFJm3eUeCDwqpbA61oofu1yj4MpVNan9klaGhsSalJze9hegN7yoygo6sWfAM6CYMdjg2EA2COm9osylu2Ukc5pBenoxiS90SLJAxk4WgvtrbjS9a2c5OhIYMd8NnnaYOswm1Xr7FiRsdWJ6VyOqhd8tdFz6DK4ytlEpaD4LWLabHP7ucboPWtGMED3LcoWEPOGKfrJZf)eFvekFEkOSlOFqRqadEn0(hNexmLG1aiJkzrhd8tdFz6DK4Nyh4prXiP3yzbEzbeAOzQZjBoKyy7PzZHY07iHn9zlCDtqWM73KFiS10S1tC0Ehz7h2Ibc20aiJkBu8a2Ibc28siw6rMnnaYOsydYwVzZf0pOviyd8AO9pqZwOSTLCzQJJ2)qwLgGh1FXqHog4Ng(Y07iXXdeNecRbqgvI4Ro20IPGYUG(bTcbm41q7FYNV86soaGxXL2Nl9iNpF51fqWvfa4s7ZLEKH25Ea6WlHlbcct3PecCsCXucwdGmQKfDmWpn8LP3rIFI3ctDC0(hYQ0a8O(lgk45(7rggGUGolMIJnT49a0HxcxceeMUtje488FQ8qoRDCkOQXcGzrpe)UsfM64O9pKvPb4r9xmuImpbYTJnT49a0HxcxceeMUtje4KISGOiaoiKGq6bgGzrpeXuXjLbcds)azCv(pZlffmFEpbA6LxQNcPl4sWfAM6CYwUH3gercANcfztF2cx3eeSTDyusqW2g)n5h2cLnrztdGmQeM64O9pKvPb4r9xmuYe0ofk64bItcH1aiJkr8vhBAX7bOdVeUeiimDNsiWjXftjynaYOsw0Xa)0WxMEhjIfLPooA)dzvAaEu)fdLmbTtHIo20I3dqhEjCjqqy6oLqatntDoZjBBxKfYiB)ocyt7mKTWRtT2iHPoNS5dDwRSrWZpLaabBBFaaVIe2OFaBUG(bTcbBGxdT)HTMMnir2UJDKTTSv2WbbYqWgaLXHThW22haWRiBq2PeBOVUnaz7h20BKnxqNfaiytdGmQm1Xr7FiRYRI3dqhEj0XjYqXKlTl8bItcHLda4v0X9ijGIDb9dAfcyWRH2)4KIYRl5aaEfxaml6HqPZ)PYd5SKda4vCveaH2)Kp)Ea6WlHlakJdmjubqOybAM6CYMp0zTYgbp)ucaeS5WcUQaajSr)a2Cb9dAfc2aVgA)dBnnBqISDh7iBBzRSHdcKHGnakJdBpGnP7ENTMWMGlB)WMO56ptDC0(hYQ8Q)IHYEa6WlHoorgkMCPDHpqCsimqWvfaOJ7rsaf7c6h0keWGxdT)Xjff0tGMErU79LGRtIlMsWAaKrLSOJb(PHVm9os8t0853dqhEjCbqzCGjHkacflqZuNt28HoRv2CybxvaGe2AA2ezCkOQH)s39ouerbrraBBeHeespS1e2eCzlMcBqISDh7iBI6pBe88tHWwcPv2(Hn9gzZHfCvbaY2295YuhhT)HSkV6VyOShGo8sOJtKHIjxAxyGGRkaqh3JKakUGEc00RDCkOQXsW1jff0tGMErU79LGB(8zbrraCqibH0dmaZIEi(rfODwEDbeCvbaUayw0dXprzQZjBsU4PJeBBFaaVISftHnhwWvfaiBeufCzZf0pGn9zZh9LeJSqpHISDcIYuhhT)HSkV6VyOihaWROJnTyns4Ol0xsmYc9ekUWj8syXjLrFjXil0tOyzjhaWROZYRl5aaEfxUzcjTDtncOK4Rop)NkpKZc9LeJSqpHIlaMf9qOKOojUykbRbqgvYIog4Ng(Y07ir8vNGOlW4oo6kkfYQh)eXolVUKda4vCbWSOhY2OYARusdGmQlTZqy9HlnYuhhT)HSkV6VyOaeCvba6ytlwJeo6c9LeJSqpHIlCcVewCsbstJhT3r4ZN59WUFpkXpXhx4SWxyIlofNN)tLhYzH(sIrwONqXfaZIEiu6QZYRlGGRkaWfaZIEiBJkRTsjnaYOU0odH1hU0i0m15KTTpaGxr2eCVGORJSfjYZMcAKWM(Sjqq2ALTGWwWgXfpDKytghee6dyJ(bSP3iBPGOS5ZnMnpK(biBbB090KBeWuhhT)HSkV6VyO4(FcgGKxaCqhPFa8G(QIVYuhhT)HSkV6VyOihaWROJnTyasdqYD4LqNNpZ7HD)EuYQG09Pv)eF1jfUzcjTDtncOK4R5ZdWSOhcLeR95cS2zOtIlMsWAaKrLSOJb(PHVm9os8t8wG2jfug9LeJSqpHIL85byw0dHsI1(Cbw7mCBI6K4IPeSgazujl6yGFA4ltVJe)eVfODsHgazuxANHW6dxACdaml6HaTFoWzwqueahesqi9adWSOhIyQWuhhT)HSkV6VyO4(FcgGKxaCqhPFa8G(QIVYuhhT)HSkV6VyOihaWROJhiojewdGmQeXxDSPft59a0HxcxKlTl8bItcHLda4v0jaPbi5o8sOZZN59WUFpkzvq6(0QFIV6Kc3mHK2UPgbus8185byw0dHsI1(Cbw7m0jXftjynaYOsw0Xa)0WxMEhj(jElq7KckJ(sIrwONqXs(8aml6HqjXAFUaRDgUnrDsCXucwdGmQKfDmWpn8LP3rIFI3c0oPqdGmQlTZqy9HlnUbaMf9qG2VRI6mlikcGdcjiKEGbyw0drmvyQZjB(e0zKFylxmZfjkB)WwMqsB3eYMgazujSfkBoWF285gZgK34WgqyMEKz7fu26Hnr3WwjSfe2s)iZwqydsKT7yhzdNxq(MnakJdBXuyla4avLncQApYSj4Yg9dytKXPGQgm1Xr7FiRYR(lgkhqNr(bwXmxKOoEG4KqynaYOseF1XMwmXftjynaYOs8tSOorAA8O9ocF(mVh297rj(j2boXbbYqSaOmoWNpZRhS4NOuXjfu(8FQ8qoRDCkOQXcGrbI85lVUacUQaaxAFU0Jm0obyw0dHsI6)w2gfexmLG1aiJkXpXoaAM6CYMdfeDztWLnhwWvfaiBHYMd8NTFylsj20aiJkHnkG8gh2s9EpYSL(rMnCEb5B2IPW28kBKjCj3VcntDC0(hYQ8Q)IHcqWvfaOJnTykVhGo8s4ICPDHbcUQaaDI004r7De(8zEpS73Js8tSdCcqAasUdVe6Kc3mHK2UPgbus8185byw0dHsI1(Cbw7m0jXftjynaYOsw0Xa)0WxMEhj(jElq7KckJ(sIrwONqXs(8aml6HqjXAFUaRDgUnrDsCXucwdGmQKfDmWpn8LP3rIFI3c0o1aiJ6s7mewF4sJBaGzrpe)OWb(tbqyq6hiJRsqU7rgMCEHPaW022k0(tbqyq6hiJRY)zEPOGBBRq7pf7bOdVeUaOmoWKqfaHILTjIHgAM64O9pKv5v)fdfGGRkaqhpqCsiSgazujIV6ytlMY7bOdVeUixAx4deNecdeCvba6KY7bOdVeUixAxyGGRkaqNinnE0EhHpFM3d7(9Oe)e7aNaKgGK7WlHoPWntiPTBQraLeFnFEaMf9qOKyTpxG1odDsCXucwdGmQKfDmWpn8LP3rIFI3c0oPGYOVKyKf6juSKppaZIEiusS2NlWANHBtuNexmLG1aiJkzrhd8tdFz6DK4N4TaTtnaYOU0odH1hU04gayw0dXpkCG)uaegK(bY4QeK7EKHjNxykamTTTcT)uaegK(bY4Q8FMxkk422k0(tXEa6WlHlakJdmjubqOyzBIyOHMPoNS5qIuYloxyBJEFKnFc6mYpSLlM5IeLniB9Mn9gzJeziBPxUpSfe2cVFhDKnpbLTwEEqpYSP3iB4Gaziy78tP1(hcBnnBqISfaCGQYMaPhz2CybxvaGm1Xr7FiRYR(lgkhqNr(bwXmxKOo20IjUykbRbqgvIFIf1jstJhT3r4ZN59WUFpkXpXoWjaZIEiusu)3Y2OG4IPeSgazuj(j2bqZuNt28jOZi)WwUyMlsu2(HnPCzRPzRh2CJPGz9HTykSnyasqWww4lB4GaziylMcBnnB(4SJZNXgK)avLTYZw2dq2krwiJSveq20NTCPkuerBetDC0(hYQ8Q)IHYb0zKFGvmZfjQJnTyIlMsWAaKrLi(QtkdegK(bY4QeK7EKHjNxykam5mlikcGdcjiKEGbyw0drmvCI004r7De(8zEpS73Js8tmfhx4SWxyIloLnCfANaKgGK7WlHoPm6ljgzHEcfloPGYf0tGMErU79LGRtkWbbYqSkiDFALsIfDR(JdcKHybqzCGpFMxpybAODQbqg1L2ziS(WLg3aaZIEi(5aMAM6CMt2Kums6nwyBJoA)dHPoNSTzlFt0iDbbS9dBBjxrInFc6mYpSLlM5IeLPooA)dzrums6nweFaDg5hyfZCrI6ytlwJeo6AA5BLOr6ccw4eEjS4K4IPeSgazuj(jElopFM3d7(9Oe)e7aNAaKrDPDgcRpCPXnaWSOhIFIyM6CY2MT8nrJ0feW2pSDnxrInPjCj3VYMdl4QcaKPooA)dzrums6nw8xmuacUQaaDSPfRrchDnT8Ts0iDbblCcVewCE(mVh297rj(j2bo1aiJ6s7mewF4sJBaGzrpe)eXm15Knjbpfb0cYOiX2g56MGGThWMdJ0aKCZgKTEZMNannwyB7da4vKWuhhT)HSikgj9gl(lgkU)NGbi5fah0r6hapOVQ4Rm1Xr7FilIIrsVXI)IHICaaVIoEG4KqynaYOseF1XMwSgjC0frWtraTGmUWj8syXjfaml6HqPRIMpVBMqsB3uJakj(k0o1aiJ6s7mewF4sJBaGzrpe)eLPoNSjj4PiGwqgzZF28rFjYS9dBxZvKyZHrAasUzB7da4vKTqztVr2WPW2tZgrXiP3SPpBYOYww4lBfbqO9pS5H0pazZh9LeJSqpHIm1Xr7FilIIrsVXI)IHI7)jyasEbWbDK(bWd6Rk(ktDC0(hYIOyK0BS4VyOihaWROJnTyns4OlIGNIaAbzCHt4LWItns4Ol0xsmYc9ekUWj8syXzC0EhHXbZAKi(QtpbA6frWtraTGmUayw0dHsxxBHPooA)dzrums6nw8xmuYe0ofk6ytlwJeo6Ii4PiGwqgx4eEjS488zEpS73JsOK4TWuZuNZCYMihttUzQZjBoKEAYnBq26nBzHVS5ZnMn6hW2MT8Ts0iDbboYMWKqcHnbspYSTDyO3jiyt6okpKeM64O9pK1Emn5w8Ea6WlHoorgkEA5BLOr6ccGpUWNFkT2)44EKeqXuqzGWG0pqgxfm07eeWK7O8qsCI004r7De(8zEpS73Js8t8Xfol8fM4Itb685Paimi9dKXvbd9obbm5okpKeNNpZ7HD)EucLefAM6CYMihttUzdYwVzZh9LiZM)STzlFRensxqGiXMik8TZeYyZNBmBXuyZh9LiZgaJceSr)a2g0xLTT3NBhtDC0(hYApMMC7VyOShttUDSPfRrchDH(sIrwONqXfoHxclo1iHJUMw(wjAKUGGfoHxclo3dqhEjCnT8Ts0iDbbWhx4ZpLw7FCE(pvEiNf6ljgzHEcfxaml6HqPRm15KnroMMCZgKTEZ2MT8Ts0iDbbS5pBB(S5J(sKfj2erHVDMqgB(CJzlMcBImofu1GnbxM64O9pK1Emn52FXqzpMMC7ytlwJeo6AA5BLOr6ccw4eEjS4KYAKWrxOVKyKf6juCHt4LWIZ9a0HxcxtlFRensxqa8Xf(8tP1(hNf0tGMETJtbvnwcUm1Xr7FiR9yAYT)IHI7)jyasEbWbDK(bWd6Rk(QJOVkiGJSxyuXoyRm1Xr7FiR9yAYT)IHYEmn52XMwSgjC0frWtraTGmUWj8syX55)u5HCwYba8kUeCDsr51LCaaVIlasdqYD4LW85lONan9AhNcQASeCDwEDjhaWR4YntiPTBQraLeFfANNpZ7HD)EuYQG09Pv)etbXftjynaYOsw0Xa)0WxMEhj(LJIdG2ji6cmUJJUIsHS6XVRIYuNt2e5yAYnBq26nBIOGOiGTnIqcspIeBoSGRkaq)3(aaEfzBELTEydG0aKCZgigz0r2kcGEKztKXPGQg(lD37l2KGyoSbzR3SjHUKMWgDprIT7wzRPzZ9jK2lHlM64O9pK1Emn52FXqzpMMC7ytlMcns4ORSGOiaoiKGq6zHt4LWs(8aHbPFGmUYcWf4NgwVr4SGOiaoiKGq6bANuU86ci4QcaCbqAasUdVe6S86soaGxXfaZIEi(TfNf0tGMETJtbvnwcUoPOGEc00lYDVVeCZNVGEc00RDCkOQXcGzrpek5G85lVUiOlPjlTpx6rgANLxxe0L0KfaZIEiuAlvTQ1ka]] )


end