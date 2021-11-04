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

            spend = function () return 40 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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

            spend = function () return 30 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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

            spend = function () return 25 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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

            spend = function () return 35 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
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


    spec:RegisterPack( "Assassination", 20211101, [[diLcDcqiKipIQkDjKKsBIk1Najgfs4uGuRsjv9kHkZIkPBPKWUK0VajnmKehtL0YiKEMskMgvcxtjL2gss6BijvnoKKIZrLOyDeI8oKKkP5riCpc1(OQQ)HKujoOsISqKOEivvmrLuPlsvrTrcr1hrsIrIKuPoPsIQvIK6LujkntQkYnjeLDQK0pPsuXqvsflLQcEkrMQqvxfjPITsLiFLkrvJLQcTxL6VGAWuoSOftvESkMSexgAZi1NjQrRsDAPwnvIk9AvIzl42cz3k(TQgovCCLeflh45iMoPRtW2vIVdcJNQsNheTELeLMVqz)OEFDh)wQKkUxvuQi61RxPY1QOIsfQ6vQ6wsH0b3so55skJBPjJWT0krijH0tQ9pBjNeYWNLD8BjYlao4w6wvhIibvOk36TGx98rqL0rcHu7FoGKwHkPJoqDl5j0bDLpBVTujvCVQOur0RxVsLRvrfLku1RUylLc69d2ssDKF2s3DPGZ2BlvqYzlTsessi9KA)dB(WllGm1R(lyKhcy7QRSjkve9ktntTFUZrgjIet9kyBLCCcqYguikOpkuyJoKYSPpBKpczBLwhFIn6hCHWM(SrYfKnhWFqcPhz20ocRm1RGT19hOOS5s50KB2eMasiSjf6dYwof2w3(GSbrhcSfsIYw4hzeWMENdBISKOiGTvIqscPNkt9kyZhWq6lBI8qkJHqQ9pSbv2CjCkOQjBeiNdBu00S5s4uqvt2AcB6llhWcBpnnBpGTFylzl8JmB(zDHUYuVc2ez5fKnrEaj3hqsRS1JIaGGJYwpSD(iVuzRPzdcKnxUceLTsxyRv2OFaBlFi1oGWKpSGJwzQxbBuDiiBsuwITOhGSPpBeHOOFyZLfx6bke2C58RSyOhz2AA2G8fy7oxq20BKnYle86Pu3sHMOKD8BjIIzqVXYo(9Qx3XVLWj9cyzt5TuE0(NT0b0rKFGvmYbj6wQGKdOD0(NT0QT8nrZWfeW2pSTM4fj28dOJi)Ww8yKds0T0b0kc6ClPzahToT8Ts0mCbbvCsVawyZnBehmeG1eiJkHn)fZ2AyZnBNpY7HD(EucB(lMnxWMB20eiJAv7iewF4sJSTc2ayu2dHn)zJQU19QIUJFlHt6fWYMYBP8O9pBjGGJkaWTubjhq7O9pBPvB5BIMHliGTFy7A8IeBst6qUFLnFqWrfa4w6aAfbDUL0mGJwNw(wjAgUGGkoPxalS5MTZh59WoFpkHn)fZMlyZnBAcKrTQDecRpCPr2wbBamk7HWM)Srv36E11SJFlHt6fWYMYBP8O9pBjN)dWaK8cGdULki5aAhT)zljj4PiGwqgfj2wjhNaKS9a28bKgGKB2GO1B28eOPXcBuLeaEfjBj6hapOV6E1RBDVQl2XVLWj9cyzt5TuE0(NTKCcaVIBPdOve05wsZaoALi4PiGwqgR4KEbSWMB2OGnagL9qyteSDvu2IfJnNiHG2oHgbSjcXSDLnOzZnBAcKrTQDecRpCPr2wbBamk7HWM)Sj6w6a5jGWAcKrLSx96w3RU2D8BjCsVaw2uElLhT)zl58FagGKxaCWTubjhq7O9pBjjbpfb0cYiBXXMp7lrMTFy7A8IeB(asdqYnBuLeaEfzlv20BKnCkS90Srumd6nB6ZMmQSfL(YwraKA)dBEi9dq28zFj5il0tQ4wI(bWd6RUx96w3Rsv3XVLWj9cyzt5T0b0kc6ClPzahTse8ueqliJvCsVawyZnBAgWrROVKCKf6jvSIt6fWcBUzlpAVGW4GrnsytmBxzZnBEc00vIGNIaAbzScWOShcBIGTR11SLYJ2)SLKta4vCR7vP63XVLWj9cyzt5T0b0kc6ClPzahTse8ueqliJvCsVawyZnBNpY7HD(EucBIqmBRzlLhT)zlfjODivCRBDlTKttU3XVx96o(TeoPxalBkVLENTeb1TuE0(NT0sc60lGBPLmiGBjkyJsSbegK(bYyTGPEhGeMCNLhcsfN0lGf2CZgstJhTxq4Zh59WoFpkHn)fZ2Xbok9fM4GtHnOzlwm2OGnGWG0pqgRfm17aKWK7S8qqQ4KEbSWMB2oFK3d789Oe2ebBIYg0BPcsoG2r7F2sI8EAYnBq06nBrPVS5N1Hn6hW2QT8Ts0mCbbUYMWeqcHnbspYSTUyQ3bizt6olpeKT0scGNmc3stlFRendxqa8Xb(8tP1(NTUxv0D8BjCsVaw2uElLhT)zlTKttU3sfKCaTJ2)SLCPCAYnBq06nB(SVez2IJTvB5BLOz4ccej2ezPVDKqeB(zDylNcB(SVez2aywGKn6hW2G(QSrv8Z6ULoGwrqNBjnd4Ov0xsoYc9KkwXj9cyHn3SPzahToT8Ts0mCbbvCsVawyZnBljOtVawNw(wjAgUGa4Jd85NsR9pS5MTZ)HYdXurFj5il0tQyfGrzpe2ebBx36E11SJFlHt6fWYMYBP8O9pBPLCAY9wQGKdOD0(NTKlLttUzdIwVzB1w(wjAgUGa2IJTvF28zFjYIeBIS03osiIn)SoSLtHnxcNcQAYMGZw6aAfbDUL0mGJwNw(wjAgUGGkoPxalS5MnkXMMbC0k6ljhzHEsfR4KEbSWMB2wsqNEbSoT8Ts0mCbbWhh4ZpLw7FyZnBf0tGMUUGtbvnRcoBDVQl2XVLWj9cyzt5TuE0(NTKZ)byasEbWb3sOVkiHZOxy0TKlw7wI(bWd6RUx96w3RU2D8BjCsVaw2uElDaTIGo3sAgWrRebpfb0cYyfN0lGf2CZ25)q5HyQYja8kwfCyZnBuWw51QCcaVIvasdqYD6fq2IfJTc6jqtxxWPGQMvbh2CZw51QCcaVIvNiHG2oHgbSjcXSDLnOzZnBNpY7HD(EusTG09Pv28xmBuWgXbdbynbYOsQ05a)0WxMEbjS5pvxyZfSbnBUzdKDbgxWrRzPqQ9WM)SDv0TuE0(NT0son5ER7vPQ743s4KEbSSP8wkpA)ZwAjNMCVLki5aAhT)zl5s50KB2GO1B2ezjrraBReHKKEej28bbhvaGXrvsa4vKT5v26HnasdqYnBGCKrxzRia6rMnxcNcQAgN0DVuztcY5WgeTEZMe6qAcB09Kb2UBLTMMnNNqAVaw3shqRiOZTefSPzahTgLefbWjHKespvCsVawylwm2acds)azSgLGlWpnSEJWrjrraCsijH0tfN0lGf2GMn3Srj2kVwbcoQaaRaKgGK70lGS5MTYRv5eaEfRamk7HWM)STg2CZwb9eOPRl4uqvZQGdBUzJc2kONanDLC3lvbh2IfJTc6jqtxxWPGQMvagL9qyteS5c2IfJTYRvc6qAsv7ZLEKzdA2CZw51kbDinPcWOShcBIGT1S1TULkiDke0D87vVUJFlLhT)zlDPpx2s4KEbSSP8w3Rk6o(TeoPxalBkVLki5aAhT)zl5dirXmO3S10S58es7fq2OyE2wecdcsVaYgoyuJe26HTZh5Lk0BP8O9pBjIIzqV36E11SJFlHt6fWYMYBP3zlrqDlLhT)zlTKGo9c4wAjdc4wI4GHaSMazujv6CGFA4ltVGe2ebBIULwsa8Kr4wI0JCaH1eiJ6w3R6ID8BjCsVaw2uEl9oBjcQBP8O9pBPLe0Pxa3slzqa3s4GaziRaugh4Zh51dwyZF2wZA3sfKCaTJ2)SL8Zh51dwyZNheidjB(akJdBdIfSWM(SrsvaKkULwsa8Kr4wcGY4atsvaKkw26E11UJFlHt6fWYMYBPdOve05wIOyg0BSubVSaULikOp6E1RBP8O9pBPtgcW5r7FGdnr3sHMOWtgHBjIIzqVXYw3Rsv3XVLWj9cyzt5TuE0(NT0jdb48O9pWHMOBPqtu4jJWT0Pq26EvQ(D8BjCsVaw2uElLhT)zlrc9bHZPax6dULki5aAhT)zlTockBsZ6YMGdB90ANHaKSr)a28JGYM(SP3iB(5ojORSbqAasUzdIwVzZNNfC(i2AA2sLTWdbBfbqQ9pBPdOve05wIsS5jqtxjH(GW5uGl9bRcoS5MTZh59WoFpkHn)fZ21TUxLQzh)wcN0lGLnL3shqRiOZTKNanDLe6dcNtbU0hSk4WMB28eOPRKqFq4CkWL(GvagL9qyteSTw2CZ25J8EyNVhLWM)IzZfBP8O9pBjCwW5J26EvxMD8BjCsVaw2uElLhT)zlDYqaopA)dCOj6wk0efEYiClvEDR7vVsLD8BjCsVaw2uElLhT)zlDYqaopA)dCOj6wk0efEYiClvAaE0TUx961D8BjCsVaw2uElDaTIGo3s4GaziRfKUpTYM)Iz76Azlo2WbbYqwbOmoWNpYRhSSLYJ2)SLsWjhewFaahDR7vVk6o(TuE0(NTuco5GWocbcULWj9cyzt5TUx96A2XVLYJ2)SLcT8TsGD5kuKJWr3s4KEbSSP8w3RE1f743s5r7F2sEPm8tdRG(CHSLWj9cyzt5TU1TKdapFKxQ743REDh)wkpA)ZwkDCcqc78n5NTeoPxalBkV19QIUJFlLhT)zl59QgWcmDiHelq0JmS((2ZwcN0lGLnL36E11SJFlHt6fWYMYBP8O9pBPOeCblW0paUGPEVLoGwrqNBjkX25xWjhTUGJEdjGn3SbYUaJl4O1Sui1EyZF2UU2TKdapFKxQWe88tHSLUsLTUx1f743s4KEbSSP8w6aAfbDULiVqWRNs1rGOcbegbcoA)tfN0lGf2IfJnYle86Pux(qQDaHjFybhTIt6fWYwkpA)ZwIoGK7diP1TUxDT743s4KEbSSP8w6D2seu3s5r7F2sljOtVaULwYGaULUY2kyJc2acds)azSweixGidxqab2j1ZDfN0lGf2wpBuP6I1Yg0BPLeapzeULwWPGQMWNcyR7vPQ743s4KEbSSP8w6D2seu3s5r7F2sljOtVaULwYGaULUY2kyJc2acds)azS(EyPX5GvCsVawyB9SrLQlCbBqVLki5aAhT)zlf)nYwUGGugzZpRRpWwtyJkvrfLnpbLTIaYM(SP3iB(WQuf2MufaiBpnB(zDytghxztuFztVBcBlzqazRjS9oAhLb2OFaBeiNtpYSfE5(SLwsa8Kr4wIoKYyiKA)d8Pa26EvQ(D8BjCsVaw2uEl9oBjcQBP8O9pBPLe0Pxa3sljaEYiClPGEUGkmbY5atcVULoGwrqNBjf0ZfuR616DsGjAQ1CGeU4qyZnBuWgLytb9Cb1QkA9ojWen1AoqcxCiSflgBkONlOw1R1Z)HYdXulcGu7FyZFXSPGEUGAvfTE(puEiMAraKA)dBqZwSySPGEUGAvVwBsThYbiOPxaHxzeYrfIGl4sFq2IfJnkytb9Cb1QET2Kk5olpeYGK4aRVIrS5MTZVGtoADbh9gsaBqVLki5aAhT)zlTUOIGOEq2G4Up3SrrtZwoqcnBenv28eOPztb9Cbv2GazdICu20NTuvmYrztF2iqoh2GO1B2CjCkOQzDlTKbbClDDR7vPA2XVLWj9cyzt5T07SLiOULYJ2)SLwsqNEbClTKbbClj6w6aAfbDULuqpxqTQIwVtcmrtTMdKWfhcBUzJc2OeBkONlOw1R17Kat0uR5ajCXHWwSySPGEUGAvfTE(puEiMAraKA)dB(ZMc65cQv9A98FO8qm1Iai1(h2GMTyXytb9Cb1QkATj1EihGGMEbeELrihvicUGl9bzlwm2OGnf0ZfuRQO1Muj3z5HqgKehy9vmIn3SD(fCYrRl4O3qcyd6T0scGNmc3skONlOctGCoWKWRBDVQlZo(TeoPxalBkVLYJ2)SLiH(GW5uGl9b3shqRiOZTeaPbi5o9c4wYbGNpYlvycE(Pq2sx36E1Ruzh)wkpA)ZwIOyg07TeoPxalBkV1TULknap6o(9Qx3XVLWj9cyzt5TuE0(NTeol48rBPcsoG2r7F2s(8SGZhXwQS5I4yJI1ghBq06nBRRe0S5N1PY2kpkclDQyas2(HnrJJnnbYOsCLniA9MnxcNcQA6kBpGniA9MT4PSRS96ncGOjiBqKTYg9dyJ8riB4GaziRSTsbYZgezRS10S5Z(sKz78rEpBnHTZh1JmBco1T0b0kc6ClH004r7fe(8rEpSZ3JsyZFXS5c2IJnnd4O1cIoiaMOGutzmQIt6fWcBUzJc2kONanDDbNcQAwfCylwm2kONanDLC3lvbh2IfJTc6jqtxPdPmgcP2)ufCylwm2WbbYqwliDFALnriMnrxlBXXgoiqgYkaLXb(8rE9Gf2IfJnkX2sc60lGvspYbewtGmQSflgBinnE0EbHpFK3d789Oe28NTJdCu6lmXbNcBqZMB2OGnkXMMbC0k6ljhzHEsfR4KEbSWwSySD(puEiMk6ljhzHEsfRamk7HWM)SjkBqV19QIUJFlHt6fWYMYBP3zlrqDlLhT)zlTKGo9c4wAjdc4w68rEpSZ3JsQfKUpTYM)SDLTyXydheidzTG09Pv2eHy2eDTSfhB4GaziRaugh4Zh51dwylwm2OeBljOtVawj9ihqynbYOULwsa8Kr4wsGGW0DiGGTUxDn743s4KEbSSP8wkpA)ZwIGaqQyb27heM40xWTubjhq7O9pBPvYXjajBsuwIn9zldb20eiJkHniA9(fu2s2kONannBjHnhq)GwH0v2Cainca9iZMMazujSvGShz2i)piGTKwraB6nYMdOJsaKSPjqg1T0b0kc6ClTKGo9cyvGGW0DiGa2CZgLyR8ALGaqQyb27heM40xq4YRvTpx6rER7vDXo(TeoPxalBkVLYJ2)SLiiaKkwG9(bHjo9fClDaTIGo3sljOtVawfiimDhciGn3Srj2kVwjiaKkwG9(bHjo9feU8Av7ZLEK3shipbewtGmQK9Qx36E11UJFlHt6fWYMYBP8O9pBjccaPIfyVFqyItFb3sfKCaTJ2)SLC5VXHnr2kXwtyBELTuz7ULVzRiasT)Xv2eiiBsuwIn9zlDCcqYMpHzHnpizZN9nJCciBfbqpYS5s4uqvtxz71Beartq2UGOdB0GpITt640JmBN7eiJKT0b0kc6ClTKGo9cyvGGW0DiGa2CZwusueaNessi9adWOShcBIGnQuPAyZnBuWgDlFRWamk7HWMieZ2Azlwm2o)hkpetLGaqQyb27heM40xWAu6l85obYiHTvW25obYibMgKhT)jdSjcXSrLQORLTyXyJ8cbVEk1aMfypiHrFZiNawXj9cyHn3Srj28eOPRbmlWEqcJ(MrobSk4WMB2kONanDDbNcQAwfCylwm28eOPRrja8qGfyzmIO)GW4CNZbJWrRcoSb9w3Rsv3XVLWj9cyzt5TuE0(NTebbGuXcS3pimXPVGBPqpi8PSLUU2T0b0kc6ClrEHGxpL6fCPhc8)RSyOh5koPxalS5MnpbA66fCPhc8)RSyOh5A5Hy2sfKCaTJ2)SLO6qq2KOSeB6Zgrik6h2CzXLEGcHnxo)klg6rMTMMniFb2UZfKn9gzJ8cbVEk1TUxLQFh)wcN0lGLnL3s5r7F2s05a)0WxMEbjBPcsoG2r7F2sI8Cy7PzZLD6fKWwQSD1Ljo2iAEUqy7PzJQ7UuWHnkhYcsy7bSLYzpeLnxehBAcKrLu3shqRiOZT0sc60lGvbcct3HacyZnBuWMNanD9UlfCG9czbjvIMNlS5Vy2U6YWwSySrbBuInhq)GwHeg8AQ9pS5MnIdgcWAcKrLuPZb(PHVm9csyZFXS5c2IJnIIzqVXsf8YciBqZg0BDVkvZo(TeoPxalBkVLYJ2)SLOZb(PHVm9cs2shipbewtGmQK9Qx3shqRiOZTefSrj2Ca9dAfsyWRP2)WwSySvETkNaWRyv7ZLEKzlwm2kVwbcoQaaRAFU0JmBqZMB2wsqNEbSkqqy6oeqaBUzJ4GHaSMazujv6CGFA4ltVGe28xmBRzlvqYb0oA)ZwsKNdBpnBUStVGe20NT0XjajBoFt(HWwtZwp5r7fKTFylhizttGmQSrXdylhizZlGyPhz20eiJkHniA9Mnhq)GwHKnWRP2)anBPY2AIFR7vDz2XVLWj9cyzt5T0b0kc6ClTKGo9cyvGGW0DiGa2CZ25)q5HyQl4uqvZkaJYEiS5pBxPYwkpA)Zwcp3FpYWa0b0r5u26E1Ruzh)wcN0lGLnL3shqRiOZT0sc60lGvbcct3HacyZnBuWwusueaNessi9adWOShcBIzJkS5MnkXgqyq6hiJ1Y)rEHSGvCsVawylwm28eOPREHEkKUGvbh2GElLhT)zlLrEcK7TUx961D8BjCsVaw2uElLhT)zlfjODivClDG8eqynbYOs2REDlDaTIGo3sljOtVawfiimDhciGn3SrCWqawtGmQKkDoWpn8LPxqcBIzt0Tubjhq7O9pBP4tVviYe0oKkYM(SLoobizBDXSeGKT15BYpSLkBIYMMazujBDV6vr3XVLWj9cyzt5T0b0kc6ClTKGo9cyvGGW0DiGGTuE0(NTuKG2HuXTU1T0Pq2XVx96o(TeoPxalBkVLYJ2)SLIsWfSat)a4cM69wk0dcFkBPR11ULoqEciSMazuj7vVULoGwrqNBjq2fyCbhTMLcPk4WMB2OGnkX2sc60lGvspYbewtGmQSflgBAcKrTQDecRpCPr2ebBRHkSbnBUzJc20eiJAv7iewF4sJSjc2oFK3d789OKAbP7tRSTE2UwxlBXIX25J8EyNVhLuliDFALn)fZ2Xbok9fM4GtHnO3sfKCaTJ2)SLw50SLLcHTeGSj44kBKPDq20BKTFq2GO1B2cpeirzl(4x3kBuDiiBqCJdBfi7rMn6KOiGn9oh28Z6WwbP7tRS9a2GO17xqzlhizZpRtDR7vfDh)wcN0lGLnL3s5r7F2srj4cwGPFaCbt9ElvqYb0oA)ZwALtZ28SLLcHni6qGTsJSbrR39WMEJSnOVkBRHkexztGGSjYOxx2OFaBrPVS5N1PY2kPkg5OSPpBeiNdBq06nBI8qkJHqQ9pS10S58es7fW6w6aAfbDULazxGXfC0AwkKApS5pBRHkSTc2azxGXfC0AwkKAraKA)dBUz78rEpSZ3JsQfKUpTYM)Iz74ahL(ctCWPWMB2OeBN)dLhIPsU7LkaZcKS5MnkyJsSD(fCYrRl4O3qcylwm2kONanDLoKYyiKA)tvWHTyXy78FO8qmv6qkJHqQ9pvagL9qyZF2UUw2GER7vxZo(TeoPxalBkVLENTeb1TuE0(NT0sc60lGBPLmiGBjkXMMbC060Y3krZWfeuXj9cyHTyXyJsSPzahTI(sYrwONuXkoPxalSflgBN)dLhIPI(sYrwONuXkaJYEiSjc2wlBRGnrzB9SPzahTwq0bbWefKAkJrvCsVaw2sfKCaTJ2)SLKGCoS5s4uqvt2GONYdbBq06nBR2Y3krZWfeeNp7ljhzHEsfzRPzlDCc9j9c4wAjbWtgHBPfCkOQj80Y3krZWfeaF(P0A)Zw3R6ID8BjCsVaw2uEl9oBjcQBP8O9pBPLe0Pxa3slzqa3suInnd4O1OKOiaojKKq6PIt6fWcBXIXw51QCcaVIvTpx6rMTyXy78l4KJwxWrVHeWMB2oFK3d789OKAbP7tRSjMnQSLki5aAhT)zl5YNTY2pS5s4uqvt2OFaBuLeaEfzdIwVztKTsUYMWeqcHniq2saYwQSfL(YMFwh2OFaBI8qkJHqQ9pBPLeapzeULwWPGQMWrj85NsR9pBDV6A3XVLWj9cyzt5T07SLiOULYJ2)SLwsqNEbClTKa4jJWT0cofu1e(8l4KJcF(P0A)Zw6aAfbDULo)co5O1lqc6Cylwm2o)co5O1bpGp8GcBXIX25xWjhTo)GBPcsoG2r7F2ssqoh2CjCkOQjBq06nBI8qkJHqQ9pSLtHnj0H0e2scBHFKzljSbbYge)afLTWtq2s2ojrz7xqaB6nYgDlFRSveaP2)SLwYGaULUU19Qu1D8BjCsVaw2uEl9oBjcQBP8O9pBPLe0Pxa3slzqa3s0H)bSrbBuWgDlFRWamk7HW2kytuQWg0Sbv2OGTRIsf2wpBljOtVawxWPGQMWNcGnOzdA28Nn6W)a2OGnkyJULVvyagL9qyBfSjkvyBfSD(puEiMkDiLXqi1(NkaJYEiSbnBqLnky7QOuHT1Z2sc60lG1fCkOQj8PaydA2GMTyXyZtGMUshszmesT)b2tGMUk4WwSySvqpbA6kDiLXqi1(NQGdBXIXM3tiS5Mn6w(wHbyu2dHnrWMOuzlDaTIGo3sNFbNC06co6nKGT0scGNmc3sl4uqvt4ZVGtok85NsR9pBDVkv)o(TeoPxalBkVLENTeb1TuE0(NT0sc60lGBPLmiGBj6W)a2OGnkyJULVvyagL9qyBfSjkvydA2GkBuW2vrPcBRNTLe0PxaRl4uqvt4tbWg0SbnB(ZgD4FaBuWgfSr3Y3kmaJYEiSTc2eLkSTc2o)hkpetLGoKMubyu2dHnOzdQSrbBxfLkSTE2wsqNEbSUGtbvnHpfaBqZg0SflgBLxRe0H0KQ2Nl9iZwSyS59ecBUzJULVvyagL9qyteSjkv2shqRiOZT05xWjhToT8TctN4wAjbWtgHBPfCkOQj85xWjhf(8tP1(NTUxLQzh)wcN0lGLnL3sfKCaTJ2)SLe5bKCFajTYg9dyBDeiQqazZNbcoA)dBnnBZRSrumd6nwy7bS1dBjBN)dLhIHTdKNaULoGwrqNBjkyJ8cbVEkvhbIkeqyei4O9pvCsVawylwm2iVqWRNsD5dP2beM8HfC0koPxalSbnBUzJsSrumd6nwQziWMB2OeBf0tGMUUGtbvnRcoS5MTOKOiaojKKq6bgGrzpe2eZgvyZnBuWgoiqgYQ2riS(WrPVWNpYRhSWM)SjkBXIXgLyRGEc00vYDVufCyd6TupkcacokCtVLiVqWRNsD5dP2beM8HfC0TupkcacokChfHLovClDDlLhT)zlrhqY9bK06wQhfbabhfwo8EzylDDR7vDz2XVLWj9cyzt5TuE0(NTeDiLXqi1(NTubjhq7O9pBjjiNdBI8qkJHqQ9pSbrR3S5s4uqvt2scBHFKzljSbbYge)afLTWtq2s2ojrz7xqaB6nYgDlFRSveaP2)WgfpGTMMnxcNcQAYgeDiW25Jq28YZf2s5ShO2e20xwoGf2EAAORBPdOve05wIsSrumd6nwQGxwazZnBuW25)q5HyQl4uqvZkaJYEiSjc2wdBUzBjbD6fW6cofu1eokHp)uAT)Hn3SH004r7fe(8rEpSZ3JsyZFXS5c2CZMMazuRAhHW6dxAKn)z7kvylwm2kONanDDbNcQAwfCylwm28EcHn3Sr3Y3kmaJYEiSjc2e1fSb9w3RELk743s4KEbSSP8w6aAfbDULOeBefZGEJLk4Lfq2CZgstJhTxq4Zh59WoFpkHn)fZMlyZnBuWgD4FaBuWgfSr3Y3kmaJYEiSTc2e1fSbnBqLnkylpA)d85)q5HyyB9STKGo9cyLoKYyiKA)d8PaydA2GMn)zJo8pGnkyJc2OB5BfgGrzpe2wbBI6c2wbBN)dLhIPUGtbvnRamk7HW26zBjbD6fW6cofu1e(uaSbnBqLnkylpA)d85)q5HyyB9STKGo9cyLoKYyiKA)d8PaydA2GMnO3s5r7F2s0HugdHu7F26E1Rx3XVLWj9cyzt5TuE0(NTebDinzlvqYb0oA)ZwscY5WMe6qAcBq06nBUeofu1KTKWw4hz2scBqGSbXpqrzl8eKTKTtsu2(feWMEJSr3Y3kBfbqQ9pUYMNGYMdaPraBAcKrLWMENkBq0HaBHEbzlv2cysu2UsfYw6aAfbDULOeBefZGEJLk4Lfq2CZgfSD(puEiM6cofu1ScWOShcBIGTRS5MnnbYOw1ocH1hU0iB(Z2vQWwSySvqpbA66cofu1Sk4WwSySr3Y3kmaJYEiSjc2Usf2GER7vVk6o(TeoPxalBkVLoGwrqNBjkXgrXmO3yPcEzbKn3SrbB0H)bSrbBuWgDlFRWamk7HW2ky7kvydA2GkB5r7FGp)hkpedBqZM)Srh(hWgfSrbB0T8TcdWOShcBRGTRuHTvW25)q5HyQl4uqvZkaJYEiSTE2wsqNEbSUGtbvnHpfaBqZguzlpA)d85)q5HyydA2GElLhT)zlrqhst26E1RRzh)wcN0lGLnL3shqRiOZTeLyJOyg0BSubVSaYMB2kVwbcoQaaRAFU0JmBUzJsSvqpbA66cofu1Sk4WMB2wsqNEbSUGtbvnHNw(wjAgUGa4ZpLw7FyZnBljOtVawxWPGQMWrj85NsR9pS5MTLe0PxaRl4uqvt4ZVGtok85NsR9pBP8O9pBPfCkOQ5w3RE1f743s4KEbSSP8wkpA)Zwc9LKJSqpPIBPcsoG2r7F2s(SVKCKf6jvKniUXHT5v2ikMb9glSLtHnVxVzZheCubaYwof2Okja8kYwcq2eCyJ(bSf(rMnCEb576w6aAfbDULOeBefZGEJLk4Lfq2CZgfSrj2kVwLta4vScqAasUtVaYMB2kVwbcoQaaRamk7HWM)S5c2IJnxW26z74ahL(ctCWPWwSySvETceCubawbyu2dHT1ZgvQRLn)zttGmQvTJqy9HlnYg0S5MnnbYOw1ocH1hU0iB(ZMl26E1RRDh)wcN0lGLnL3s5r7F2sK7EzlvqYb0oA)Zws6UxyRPzdcKTeGSLEVGYM(S5ZZcoFKRSLtHTuvmYrztF2iqoh2GO1B2KqhstyJUNmW2DRS10SbbYge)afLnisIISf9aKn9oh2UZanB6nY25)q5HyQBPdOve05wQ8AvobGxXQ2Nl9iZMB2kVwbcoQaaRAFU0JmBUzJc2OeBN)dLhIPsqhstQamlqYwSySD(puEiM6cofu1ScWOShcB(Z2vrzdA2IfJTYRvc6qAsv7ZLEK36E1Ru1D8BjCsVaw2uElDaTIGo3sEc00vVW)LGarRampkBXIXM3tiS5Mn6w(wHbyu2dHnrW2AOcBXIXwb9eOPRl4uqvZQGZwkpA)ZwY51(NTUx9kv)o(TeoPxalBkVLoGwrqNBPc6jqtxxWPGQMvbNTuE0(NTKx4)cmTaaYTUx9kvZo(TeoPxalBkVLoGwrqNBPc6jqtxxWPGQMvbNTuE0(NTKhcii4spYBDV6vxMD8BjCsVaw2uElDaTIGo3sf0tGMUUGtbvnRcoBP8O9pBj6gGEH)lBDVQOuzh)wcN0lGLnL3shqRiOZTub9eOPRl4uqvZQGZwkpA)ZwkNdsuqgGpziS19QIEDh)wcN0lGLnL3shqRiOZTeLyJOyg0BSuZqGn3SfLefbWjHKespWamk7HWMy2OYwkpA)Zw6KHaCE0(h4qt0TuOjk8Kr4wAjNMCV19QIk6o(TeoPxalBkVLYJ2)SLuqpxq96wQGKdOD0(NTKeKZHn9gzZb0pOvizJOPYMNannBkONlOYgeTEZMlHtbvnDLTxVraenbztGGS9dBN)dLhIzlDaTIGo3sljOtVawvqpxqfMa5CGjHxztmBxzZnBuWwb9eOPRl4uqvZQGdBXIXM3tiS5Mn6w(wHbyu2dHnriMnrPcBqZwSySrbBljOtVawvqpxqfMa5CGjHxztmBIYMB2OeBkONlOwvrRN)dLhIPcWSajBqZwSySrj2wsqNEbSQGEUGkmbY5atcVU19QIUMD8BjCsVaw2uElDaTIGo3sljOtVawvqpxqfMa5CGjHxztmBIYMB2OGTc6jqtxxWPGQMvbh2IfJnVNqyZnB0T8TcdWOShcBIqmBIsf2GMTyXyJc2wsqNEbSQGEUGkmbY5atcVYMy2UYMB2OeBkONlOw1R1Z)HYdXubywGKnOzlwm2OeBljOtVawvqpxqfMa5CGjHx3s5r7F2skONlOk6w36wQ86o(9Qx3XVLWj9cyzt5T07SLiOULYJ2)SLwsqNEbClTKbbCl5a6h0kKWGxtT)Hn3SrbBLxRYja8kwbyu2dHnrW25)q5HyQYja8kwlcGu7Fylwm2wsqNEbScqzCGjPkasflSb9wQGKdOD0(NTKp1rTYgbp)usaKSrvsa4vKWg9dyZb0pOvizd8AQ9pS10SbbY2DUGSTM1Ygoiqgs2aOmoS9a2Okja8kYgeDiWg6Rtdq2(Hn9gzZb0rjas20eiJ6wAjbWtgHBjYL2b(a5jGWYja8kU19QIUJFlHt6fWYMYBP3zlrqDlLhT)zlTKGo9c4wAjdc4wYb0pOviHbVMA)dBUzJc2kONanDLC3lvbh2CZgXbdbynbYOsQ05a)0WxMEbjS5pBIYwSySTKGo9cyfGY4atsvaKkwyd6Tubjhq7O9pBjFQJALncE(PKaizZheCubasyJ(bS5a6h0kKSbEn1(h2AA2Gaz7oxq2wZAzdheidjBaugh2EaBs39cBnHnbh2(HnrJpUT0scGNmc3sKlTd8bYtaHbcoQaa36E11SJFlHt6fWYMYBP3zlrqDlLhT)zlTKGo9c4wAjdc4wQGEc001fCkOQzvWHn3SrbBf0tGMUsU7LQGdBXIXwusueaNessi9adWOShcB(ZgvydA2CZw51kqWrfayfGrzpe28Nnr3sfKCaTJ2)SL8PoQv28bbhvaGe2AA2CjCkOQzCs39cufzjrraBReHKespS1e2eCylNcBqGSDNliBIghBe88tHWwaPv2(Hn9gzZheCubaY26(XVLwsa8Kr4wICPDGbcoQaa36EvxSJFlHt6fWYMYBP8O9pBj5eaEf3sfKCaTJ2)SLKCWtNb2Okja8kYwof28bbhvaGSrqvWHnhq)a20NnF2xsoYc9KkY2jj6w6aAfbDUL0mGJwrFj5il0tQyfN0lGf2CZgLyRGEc00v5eaEfROVKCKf6jvSWMB2kVwLta4vS6eje02j0iGnriMTRS5MTZ)HYdXurFj5il0tQyfGrzpe2ebBIYMB2ioyiaRjqgvsLoh4Ng(Y0liHnXSDLn3SbYUaJl4O1Sui1EyZF2OQS5MTYRv5eaEfRamk7HW26zJk11YMiyttGmQvTJqy9HlnU19QRDh)wcN0lGLnL3shqRiOZTKMbC0k6ljhzHEsfR4KEbSWMB2OGnKMgpAVGWNpY7HD(EucB(lMTJdCu6lmXbNcBUz78FO8qmv0xsoYc9Kkwbyu2dHnrW2v2CZw51kqWrfayfGrzpe2wpBuPUw2ebBAcKrTQDecRpCPr2GElLhT)zlbeCubaU19Qu1D8BjCsVaw2uElLhT)zl58FagGKxaCWTubjhq7O9pBjQscaVISj4CbrhxzldKNnf0iHn9ztGGS1kBjHTKnIdE6mWMmoii1hWg9dytVr2cjrzZpRdBEi9dq2s2O7Pj3iylr)a4b9v3REDR7vP63XVLWj9cyzt5T0b0kc6ClbqAasUtVaYMB2oFK3d789OKAbP7tRS5Vy2UYMB2OGnNiHG2oHgbSjcXSDLTyXydGrzpe2eHy20(Cbw7iKn3SrCWqawtGmQKkDoWpn8LPxqcB(lMT1Wg0S5MnkyJsSH(sYrwONuXcBXIXgaJYEiSjcXSP95cS2riBRNnrzZnBehmeG1eiJkPsNd8tdFz6fKWM)IzBnSbnBUzJc20eiJAv7iewF4sJSTc2ayu2dHnOzZF2CbBUzlkjkcGtcjjKEGbyu2dHnXSrLTuE0(NTKCcaVIBDVkvZo(TeoPxalBkVLOFa8G(Q7vVULYJ2)SLC(padqYlao4w3R6YSJFlHt6fWYMYBP8O9pBj5eaEf3shqRiOZTeLyBjbD6fWk5s7aFG8eqy5eaEfzZnBaKgGK70lGS5MTZh59WoFpkPwq6(0kB(lMTRS5MnkyZjsiOTtOraBIqmBxzlwm2ayu2dHnriMnTpxG1oczZnBehmeG1eiJkPsNd8tdFz6fKWM)IzBnSbnBUzJc2OeBOVKCKf6jvSWwSySbWOShcBIqmBAFUaRDeY26ztu2CZgXbdbynbYOsQ05a)0WxMEbjS5Vy2wdBqZMB2OGnnbYOw1ocH1hU0iBRGnagL9qydA28NTRIYMB2IsIIa4KqscPhyagL9qytmBuzlDG8eqynbYOs2REDR7vVsLD8BjCsVaw2uElLhT)zlDaDe5hyfJCqIULoqEciSMazuj7vVULoGwrqNBjIdgcWAcKrLWM)Iztu2CZgstJhTxq4Zh59WoFpkHn)fZMlyZnB4GaziRaugh4Zh51dwyZF2eLkS5MnkyJsSD(puEiM6cofu1ScWSajBXIXw51kqWrfayv7ZLEKzdA2CZgaJYEiSjc2eLT4yBnSTE2OGnIdgcWAcKrLWM)IzZfSb9wQGKdOD0(NTKFaDe5h2IhJCqIY2pSfje02jGSPjqgvcBPYMlIJn)SoSbXnoSbeMPhz2EbLTEyt0vSwcBjHTWpYSLe2Gaz7oxq2W5fKVzdGY4Wwof2saoqrzJGQ2JmBcoSr)a2CjCkOQ5w3RE96o(TeoPxalBkVLYJ2)SLacoQaa3sfKCaTJ2)SLCzr0Hnbh28bbhvaGSLkBUio2(HTmeyttGmQe2OaIBCyl0l9iZw4hz2W5fKVzlNcBZRSrM0HC)k0BPdOve05wIsSTKGo9cyLCPDGbcoQaazZnBinnE0EbHpFK3d789Oe28xmBUGn3SbqAasUtVaYMB2OGnNiHG2oHgbSjcXSDLTyXydGrzpe2eHy20(Cbw7iKn3SrCWqawtGmQKkDoWpn8LPxqcB(lMT1Wg0S5MnkyJsSH(sYrwONuXcBXIXgaJYEiSjcXSP95cS2riBRNnrzZnBehmeG1eiJkPsNd8tdFz6fKWM)IzBnSbnBUzttGmQvTJqy9HlnY2kydGrzpe28NnkyZfSfhBuWgqyq6hiJ1ssU7rgMCEHPaWqfN0lGf2wpBRLnOzlo2OGnGWG0pqgRL)J8czbR4KEbSW26zBTSbnBXXgfSTKGo9cyfGY4atsvaKkwyB9SrvzdA2GER7vVk6o(TeoPxalBkVLYJ2)SLacoQaa3shqRiOZTeLyBjbD6fWk5s7aFG8eqyGGJkaq2CZgLyBjbD6fWk5s7adeCubaYMB2qAA8O9ccF(iVh257rjS5Vy2CbBUzdG0aKCNEbKn3SrbBorcbTDcncyteIz7kBXIXgaJYEiSjcXSP95cS2riBUzJ4GHaSMazujv6CGFA4ltVGe28xmBRHnOzZnBuWgLyd9LKJSqpPIf2IfJnagL9qyteIzt7ZfyTJq2wpBIYMB2ioyiaRjqgvsLoh4Ng(Y0liHn)fZ2AydA2CZMMazuRAhHW6dxAKTvWgaJYEiS5pBuWMlylo2OGnGWG0pqgRLKC3Jmm58ctbGHkoPxalSTE2wlBqZwCSrbBaHbPFGmwl)h5fYcwXj9cyHT1Z2AzdA2IJnkyBjbD6fWkaLXbMKQaivSW26zJQYg0Sb9w6a5jGWAcKrLSx96w3REDn743s4KEbSSP8wkpA)Zw6a6iYpWkg5GeDlvqYb0oA)ZwsKNHGxEUW2k9(mB(b0rKFylEmYbjkBq06nB6nYgjJq2cVCFyljSLE)c6kBEckBT88GEKztVr2WbbYqY25NsR9pe2AA2Gazlb4afLnbspYS5dcoQaa3shqRiOZTeXbdbynbYOsyZFXSjkBUzdPPXJ2li85J8EyNVhLWM)IzZfS5MnagL9qyteSjkBXX2AyB9SrbBehmeG1eiJkHn)fZMlyd6TUx9Ql2XVLWj9cyzt5TuE0(NT0b0rKFGvmYbj6wQGKdOD0(NTKFaDe5h2IhJCqIY2pSjfpBnnB9WMtofmQpSLtHTbtqas2IsFzdheidjB5uyRPzZNNfC(i2G4hOOSvE2IEaYwjJszKTIaYM(SfpLHQiBL2shqRiOZTeXbdbynbYOsytmBxzZnBuWgLydimi9dKXAjj39idtoVWuayOIt6fWcBXIXMNanDfimimepOatdEIwfCydA2CZwusueaNessi9adWOShcBIzJkS5MnKMgpAVGWNpY7HD(EucB(lMnky74ahL(ctCWPW2ky7kBqZMB2ainaj3PxazZnBuIn0xsoYc9KkwyZnBuITc6jqtxj39svWHn3SPjqg1Q2riS(WLgzBfSbWOShcB(ZMl26w36wAbbK(N9QIsfrVsfQgrxZwcIem9it2sU8RKpS6kFvQIiXgBXFJS1ropqzJ(bSbLLCAYnuydGRmcnalSr(iKTuq)OuXcBN7CKrsLP2N6bz7QiXMF(zbbkwydkaHbPFGmw9rOWM(SbfGWG0pqgR(yfN0lGfOWgfI6l0vMAFQhKnQQiXMF(zbbkwydkaHbPFGmw9rOWM(SbfGWG0pqgR(yfN0lGfOWgfx9f6ktntTl)k5dRUYxLQisSXw83iBDKZdu2OFaBqXbGNpYlvOWgaxzeAawyJ8riBPG(rPIf2o35iJKktTp1dYMlej28ZpliqXcBqH8cbVEkvFekSPpBqH8cbVEkvFSIt6fWcuyJIR(cDLP2N6bzZfIeB(5NfeOyHnOqEHGxpLQpcf20NnOqEHGxpLQpwXj9cybkSLkB(SlhFInkU6l0vMAFQhKT1ksS5NFwqGIf2Gcqyq6hiJvFekSPpBqbimi9dKXQpwXj9cybkSrXvFHUYu7t9GSrvfj28ZpliqXcBqbimi9dKXQpcf20NnOaegK(bYy1hR4KEbSaf2O4QVqxzQ9PEq2O6fj28ZpliqXcBqrb9Cb161Qpcf20NnOOGEUGAvVw9rOWgfUWxORm1(upiBu9IeB(5NfeOyHnOOGEUGAv0Qpcf20NnOOGEUGAvfT6JqHnke1xORm1(upiBunIeB(5NfeOyHnOOGEUGA9A1hHcB6ZguuqpxqTQxR(iuyJcr9f6ktTp1dYgvJiXMF(zbbkwydkkONlOwfT6JqHn9zdkkONlOwvrR(iuyJcx4l0vMAMAx(vYhwDLVkvrKyJT4Vr26iNhOSr)a2GsPb4rHcBaCLrObyHnYhHSLc6hLkwy7CNJmsQm1(upiBuvrIn)8ZccuSWguiVqWRNs1hHcB6ZguiVqWRNs1hR4KEbSaf2O4QVqxzQ9PEq2UsfrIn)8ZccuSWguacds)azS6JqHn9zdkaHbPFGmw9XkoPxalqHnkU6l0vMAMAx(vYhwDLVkvrKyJT4Vr26iNhOSr)a2GYPqGcBaCLrObyHnYhHSLc6hLkwy7CNJmsQm1(upiBuvrIn)8ZccuSWMuh5h2iqoA6lBuTSPpB(KqYwPxAs)dBVdcs9bSrbuHMnke1xORm1(upiBu9IeB(5NfeOyHnPoYpSrGC00x2OAztF28jHKTsV0K(h2EheK6dyJcOcnBuiQVqxzQ9PEq2OAej28ZpliqXcBqH8cbVEkvFekSPpBqH8cbVEkvFSIt6fWcuyJcr9f6ktTp1dY2vQisS5NFwqGIf2K6i)WgbYrtFzJQLn9zZNes2k9st6Fy7DqqQpGnkGk0SrHO(cDLP2N6bz7QOIeB(5NfeOyHnPoYpSrGC00x2OAztF28jHKTsV0K(h2EheK6dyJcOcnBuiQVqxzQ9PEq2evurIn)8ZccuSWguuqpxqTkA1hHcB6ZguuqpxqTQIw9rOWgfx9f6ktTp1dYMORrKyZp)SGaflSbff0ZfuRxR(iuytF2GIc65cQv9A1hHcBuC1xORm1m1U8RKpS6kFvQIiXgBXFJS1ropqzJ(bSbLYRqHnaUYi0aSWg5Jq2sb9JsflSDUZrgjvMAFQhKnxisS5NFwqGIf2Gc6ljhzHEsflvFekSPpBqPGEc00vFSI(sYrwONuXcuyJIR(cDLP2N6bz76vrIn)8ZccuSWguacds)azS6JqHn9zdkaHbPFGmw9XkoPxalqHnke1xORm1(upiBxfvKyZp)SGaflSbfGWG0pqgR(iuytF2Gcqyq6hiJvFSIt6fWcuyJcr9f6ktTp1dY2vxisS5NFwqGIf2Gcqyq6hiJvFekSPpBqbimi9dKXQpwXj9cybkSrXvFHUYuZuVYJCEGIf2O6zlpA)dBHMOKkt9wYb80Da3s(1VSTsessi9KA)dB(WllGm1(1VST6VGrEiGTRUYMOur0Rm1m1(1VS5N7CKrIiXu7x)Y2kyBLCCcqYguikOpkuyJoKYSPpBKpczBLwhFIn6hCHWM(SrYfKnhWFqcPhz20ocRm1(1VSTc2w3FGIYMlLttUztyciHWMuOpiB5uyBD7dYgeDiWwijkBHFKraB6DoSjYsIIa2wjcjjKEQm1(1VSTc28bmK(YMipKYyiKA)dBqLnxcNcQAYgbY5WgfnnBUeofu1KTMWM(YYbSW2ttZ2dy7h2s2c)iZMFwxORm1(1VSTc2ez5fKnrEaj3hqsRS1JIaGGJYwpSD(iVuzRPzdcKnxUceLTsxyRv2OFaBlFi1oGWKpSGJwzQ9RFzBfSr1HGSjrzj2IEaYM(SreII(HnxwCPhOqyZLZVYIHEKzRPzdYxGT7CbztVr2iVqWRNsLP2V(LTvWMF(zbbkBaHbHH4bLkn4jkB6ZMNanDfimimepOatdEIwfCQm1m1(1VS5Z(IhbflS5H0paz78rEPYMhk3dPY2kDoOJsyB(zf3jiIwiWwE0(hcB)eGSYuNhT)HuDa45J8svC64eGe25BYpm15r7FivhaE(iVuJtmu9EvdybMoKqIfi6rgwFF7HPopA)dP6aWZh5LACIHAucUGfy6haxWuVD1bGNpYlvycE(PqeFLkU20IP05xWjhTUGJEdjWni7cmUGJwZsHu7X)RRLPopA)dP6aWZh5LACIHkDaj3hqsRU20IjVqWRNs1rGOcbegbcoA)tSyKxi41tPU8Hu7act(WcoktDE0(hs1bGNpYl14ed1Le0PxaDDYiu8cofu1e(uaUUKbbu81vqbqyq6hiJ1Ia5cez4cciWoPEUxpvQUyTqZu7x2I)gzlxqqkJS5N11hyRjSrLQOIYMNGYwraztF20BKnFyvQcBtQcaKTNMn)SoSjJJRSjQVSP3nHTLmiGS1e2EhTJYaB0pGncKZPhz2cVCFyQZJ2)qQoa88rEPgNyOUKGo9cORtgHIPdPmgcP2)aFkaxxYGak(6kOaimi9dKX67HLgNdUEQuDHlGMP2VSTUOIGOEq2G4Up3SrrtZwoqcnBenv28eOPztb9Cbv2GazdICu20NTuvmYrztF2iqoh2GO1B2CjCkOQzLPopA)dP6aWZh5LACIH6sc60lGUozekwb9CbvycKZbMeE11LmiGIV6Atlwb9Cb1616DsGjAQ1CGeU4qCtbLuqpxqTkA9ojWen1AoqcxCiXIPGEUGA9A98FO8qm1Iai1(h)fRGEUGAv065)q5HyQfbqQ9pqhlMc65cQ1R1Mu7HCacA6fq4vgHCuHi4cU0hmwmkuqpxqTET2Kk5olpeYGK4aRVIrUp)co5O1fC0BibqZuNhT)HuDa45J8snoXqDjbD6fqxNmcfRGEUGkmbY5atcV66sgeqXI6Atlwb9Cb1QO17Kat0uR5ajCXH4MckPGEUGA9A9ojWen1AoqcxCiXIPGEUGAv065)q5HyQfbqQ9p(RGEUGA9A98FO8qm1Iai1(hOJftb9Cb1QO1Mu7HCacA6fq4vgHCuHi4cU0hmwmkuqpxqTkATjvYDwEiKbjXbwFfJCF(fCYrRl4O3qcGMPopA)dP6aWZh5LACIHkj0heoNcCPpORoa88rEPctWZpfI4RU20Ibinaj3PxazQZJ2)qQoa88rEPgNyOsumd6ntntTF9lB(SV4rqXcB4ccGKnTJq20BKT8OpGTMWwUKDi9cyLPopA)dr8L(CHP2VS5dirXmO3S10S58es7fq2OyE2wecdcsVaYgoyuJe26HTZh5Lk0m15r7FiXjgQefZGEZuNhT)HeNyOUKGo9cORtgHIj9ihqynbYO66sgeqXehmeG1eiJkPsNd8tdFz6fKicrzQ9lB(5J86blS5ZdcKHKnFaLXHTbXcwytF2iPkasfzQZJ2)qItmuxsqNEb01jJqXaughysQcGuXIRlzqafJdcKHScqzCGpFKxpyX)1SwM68O9pK4ed1tgcW5r7FGdnrDDYiumrXmO3yXvIc6Jk(QRnTyIIzqVXsf8YcitDE0(hsCIH6jdb48O9pWHMOUozek(uim1(LT1rqztAwx2eCyRNw7meGKn6hWMFeu20Nn9gzZp3jbDLnasdqYnBq06nB(8SGZhXwtZwQSfEiyRiasT)HPopA)djoXqLe6dcNtbU0h01MwmL8eOPRKqFq4CkWL(Gvbh3NpY7HD(EuI)IVYuNhT)HeNyOIZcoFKRnTypbA6kj0heoNcCPpyvWXTNanDLe6dcNtbU0hScWOShIiwR7Zh59WoFpkXFXUGPopA)djoXq9KHaCE0(h4qtuxNmcfxELPopA)djoXq9KHaCE0(h4qtuxNmcfxAaEuM68O9pK4ed1eCYbH1haWrDTPfJdcKHSwq6(0Q)IVU24WbbYqwbOmoWNpYRhSWuNhT)HeNyOMGtoiSJqGGm15r7FiXjgQHw(wjWUCfkYr4Om15r7FiXjgQEPm8tdRG(CHWuZu7x)YMF(puEigctTFzBLtZwwke2saYMGJRSrM2bztVr2(bzdIwVzl8qGeLT4JFDRSr1HGSbXnoSvGShz2OtIIa207CyZpRdBfKUpTY2dydIwVFbLTCGKn)SovM68O9pK6PqehLGlybM(bWfm1Bxd9GWNI4R1166bYtaH1eiJkr8vxBAXGSlW4coAnlfsvWXnfuAjbD6fWkPh5acRjqg1yX0eiJAv7iewF4sJIynubA3uOjqg1Q2riS(WLgfX5J8EyNVhLuliDFAD9xRRnwSZh59WoFpkPwq6(0Q)IpoWrPVWehCkqZu7x2w50SnpBzPqydIoeyR0iBq06DpSP3iBd6RY2AOcXv2eiiBIm61Ln6hWwu6lB(zDQSTsQIrokB6ZgbY5WgeTEZMipKYyiKA)dBnnBopH0EbSYuNhT)HupfsCIHAucUGfy6haxWuVDTPfdYUaJl4O1Sui1E8FnuzfGSlW4coAnlfsTiasT)X95J8EyNVhLuliDFA1FXhh4O0xyIdof3u68FO8qmvYDVubywG0nfu68l4KJwxWrVHeelwb9eOPR0HugdHu7FQcoXID(puEiMkDiLXqi1(NkaJYEi(FDTqZu7x2KGCoS5s4uqvt2GONYdbBq06nBR2Y3krZWfeeNp7ljhzHEsfzRPzlDCc9j9citDE0(hs9uiXjgQljOtVa66KrO4fCkOQj80Y3krZWfeaF(P0A)JRlzqaftjnd4O1PLVvIMHliOIt6fWsSyusZaoAf9LKJSqpPIvCsVawIf78FO8qmv0xsoYc9Kkwbyu2dreRDfIUEnd4O1cIoiaMOGutzmQIt6fWctTFzZLpBLTFyZLWPGQMSr)a2Okja8kYgeTEZMiBLCLnHjGecBqGSLaKTuzlk9Ln)SoSr)a2e5HugdHu7FyQZJ2)qQNcjoXqDjbD6fqxNmcfVGtbvnHJs4ZpLw7FCDjdcOykPzahTgLefbWjHKespvCsVawIfR8AvobGxXQ2Nl9ihl25xWjhTUGJEdjW95J8EyNVhLuliDFAvmvyQ9lBsqoh2CjCkOQjBq06nBI8qkJHqQ9pSLtHnj0H0e2scBHFKzljSbbYge)afLTWtq2s2ojrz7xqaB6nYgDlFRSveaP2)WuNhT)HupfsCIH6sc60lGUozekEbNcQAcF(fCYrHp)uAT)X1Mw85xWjhTEbsqNtSyNFbNC06GhWhEqjwSZVGtoAD(bDDjdcO4Rm15r7Fi1tHeNyOUKGo9cORtgHIxWPGQMWNFbNCu4ZpLw7FCTPfF(fCYrRl4O3qcCDjdcOy6W)akOGULVvyagL9qwHOubAQwkUkkvw)sc60lG1fCkOQj8PaGgA)Pd)dOGc6w(wHbyu2dzfIsLvC(puEiMkDiLXqi1(NkaJYEiqt1sXvrPY6xsqNEbSUGtbvnHpfa0qhlMNanDLoKYyiKA)dSNanDvWjwSc6jqtxPdPmgcP2)ufCIfZ7je30T8TcdWOShIieLkm15r7Fi1tHeNyOUKGo9cORtgHIxWPGQMWNFbNCu4ZpLw7FCTPfF(fCYrRtlFRW0j66sgeqX0H)buqbDlFRWamk7HScrPc0uTuCvuQS(Le0PxaRl4uqvt4tban0(th(hqbf0T8TcdWOShYkeLkR48FO8qmvc6qAsfGrzpeOPAP4QOuz9ljOtVawxWPGQMWNcaAOJfR8ALGoKMu1(CPh5yX8EcXnDlFRWamk7HicrPctTFztKhqY9bK0kB0pGT1rGOcbKnFgi4O9pS10SnVYgrXmO3yHThWwpSLSD(puEig2oqEcitDE0(hs9uiXjgQ0bKCFajT6AtlMcYle86PuDeiQqaHrGGJ2)elg5fcE9uQlFi1oGWKpSGJcTBkrumd6nwQzi4Msf0tGMUUGtbvnRcoUJsIIa4KqscPhyagL9qetf3uGdcKHSQDecRpCu6l85J86bl(lASyuQGEc00vYDVufCG21EueaeCu4okclDQO4RU2JIaGGJclhEVmi(QR9Oiai4OWnTyYle86Pux(qQDaHjFybhLP2VSjb5CytKhszmesT)HniA9MnxcNcQAYwsyl8JmBjHniq2G4hOOSfEcYwY2jjkB)ccytVr2OB5BLTIai1(h2O4bS10S5s4uqvt2GOdb2oFeYMxEUWwkN9a1MWM(YYbSW2ttdDLPopA)dPEkK4edv6qkJHqQ9pU20IPerXmO3yPcEzb0nfN)dLhIPUGtbvnRamk7HiI14EjbD6fW6cofu1eokHp)uAT)XnstJhTxq4Zh59WoFpkXFXUWTMazuRAhHW6dxA0)RujwSc6jqtxxWPGQMvbNyX8EcXnDlFRWamk7HicrDb0m15r7Fi1tHeNyOshszmesT)X1MwmLikMb9glvWllGUrAA8O9ccF(iVh257rj(l2fUPGo8pGckOB5BfgGrzpKviQlGMQLIZ)HYdXS(Le0PxaR0HugdHu7FGpfa0q7pD4Fafuq3Y3kmaJYEiRquxSIZ)HYdXuxWPGQMvagL9qw)sc60lG1fCkOQj8PaGMQLIZ)HYdXS(Le0PxaR0HugdHu7FGpfa0qdntTFztcY5WMe6qAcBq06nBUeofu1KTKWw4hz2scBqGSbXpqrzl8eKTKTtsu2(feWMEJSr3Y3kBfbqQ9pUYMNGYMdaPraBAcKrLWMENkBq0HaBHEbzlv2cysu2UsfctDE0(hs9uiXjgQe0H0exBAXuIOyg0BSubVSa6MIZ)HYdXuxWPGQMvagL9qeXv3AcKrTQDecRpCPr)VsLyXkONanDDbNcQAwfCIfJULVvyagL9qeXvQantDE0(hs9uiXjgQe0H0exBAXuIOyg0BSubVSa6Mc6W)akOGULVvyagL9qwXvQanv75)q5HyG2F6W)akOGULVvyagL9qwXvQSIZ)HYdXuxWPGQMvagL9qw)sc60lG1fCkOQj8PaGMQ98FO8qmqdntDE0(hs9uiXjgQl4uqvtxBAXuIOyg0BSubVSa6U8Afi4OcaSQ95spYUPub9eOPRl4uqvZQGJ7Le0PxaRl4uqvt4PLVvIMHlia(8tP1(h3ljOtVawxWPGQMWrj85NsR9pUxsqNEbSUGtbvnHp)co5OWNFkT2)Wu7x28zFj5il0tQiBqCJdBZRSrumd6nwylNcBEVEZMpi4OcaKTCkSrvsa4vKTeGSj4Wg9dyl8JmB48cY3vM68O9pK6PqItmurFj5il0tQORnTykrumd6nwQGxwaDtbLkVwLta4vScqAasUtVa6U8Afi4OcaScWOShI)UioxS(JdCu6lmXbNsSyLxRabhvaGvagL9qwpvQR1FnbYOw1ocH1hU0i0U1eiJAv7iewF4sJ(7cMA)YM0DVWwtZgeiBjazl9EbLn9zZNNfC(ixzlNcBPQyKJYM(SrGCoSbrR3SjHoKMWgDpzGT7wzRPzdcKni(bkkBqKefzl6biB6DoSDNbA20BKTZ)HYdXuzQZJ2)qQNcjoXqLC3lU20IlVwLta4vSQ95spYUlVwbcoQaaRAFU0JSBkO05)q5HyQe0H0KkaZcKXID(puEiM6cofu1ScWOShI)xff6yXkVwjOdPjvTpx6rMPopA)dPEkK4edvNx7FCTPf7jqtx9c)xcceTcW8OXI59eIB6w(wHbyu2dreRHkXIvqpbA66cofu1Sk4WuNhT)HupfsCIHQx4)cmTaasxBAXf0tGMUUGtbvnRcom15r7Fi1tHeNyO6HaccU0JSRnT4c6jqtxxWPGQMvbhM68O9pK6PqItmuPBa6f(V4AtlUGEc001fCkOQzvWHPopA)dPEkK4ed1Coirbza(KHGRnT4c6jqtxxWPGQMvbhM68O9pK6PqItmupziaNhT)bo0e11jJqXl50KBxBAXuIOyg0BSuZqWDusueaNessi9adWOShIyQWu7x2KGCoSP3iBoG(bTcjBenv28eOPztb9Cbv2GO1B2CjCkOQPRS96ncGOjiBceKTFy78FO8qmm15r7Fi1tHeNyOQGEUG6vxBAXljOtVawvqpxqfMa5CGjHxfF1nff0tGMUUGtbvnRcoXI59eIB6w(wHbyu2dreIfLkqhlgfljOtVawvqpxqfMa5CGjHxflQBkPGEUGAv065)q5HyQamlqcDSyuAjbD6fWQc65cQWeiNdmj8ktDE0(hs9uiXjgQkONlOkQRnT4Le0PxaRkONlOctGCoWKWRIf1nff0tGMUUGtbvnRcoXI59eIB6w(wHbyu2dreIfLkqhlgfljOtVawvqpxqfMa5CGjHxfF1nLuqpxqTETE(puEiMkaZcKqhlgLwsqNEbSQGEUGkmbY5atcVYuZu7x)Y262a8OSvYOugzl96qRnsyQ9lB(8SGZhXwQS5I4yJI1ghBq06nBRRe0S5N1PY2kpkclDQyas2(HnrJJnnbYOsCLniA9MnxcNcQA6kBpGniA9MT4Pmvxz71Beartq2GiBLn6hWg5Jq2WbbYqwzBLcKNniYwzRPzZN9LiZ25J8E2AcBNpQhz2eCQm15r7Fi1sdWJkgNfC(ixBAXinnE0EbHpFK3d789Oe)f7I40mGJwli6GayIcsnLXOkoPxalUPOGEc001fCkOQzvWjwSc6jqtxj39svWjwSc6jqtxPdPmgcP2)ufCIfdheidzTG09Pvriw01ghoiqgYkaLXb(8rE9GLyXO0sc60lGvspYbewtGmQXIH004r7fe(8rEpSZ3Js8)4ahL(ctCWPaTBkOKMbC0k6ljhzHEsfR4KEbSel25)q5HyQOVKCKf6jvScWOShI)IcntDE0(hsT0a8OXjgQljOtVa66KrOybcct3HacCDjdcO4Zh59WoFpkPwq6(0Q)xJfdheidzTG09Pvriw01ghoiqgYkaLXb(8rE9GLyXO0sc60lGvspYbewtGmQm1(LTvYXjajBsuwIn9zldb20eiJkHniA9(fu2s2kONannBjHnhq)GwH0v2Cainca9iZMMazujSvGShz2i)piGTKwraB6nYMdOJsaKSPjqgvM68O9pKAPb4rJtmujiaKkwG9(bHjo9f01Mw8sc60lGvbcct3HacCtPYRvccaPIfyVFqyItFbHlVw1(CPhzM68O9pKAPb4rJtmujiaKkwG9(bHjo9f01dKNacRjqgvI4RU20IxsqNEbSkqqy6oeqGBkvETsqaivSa79dctC6liC51Q2Nl9iZu7x2C5VXHnr2kXwtyBELTuz7ULVzRiasT)Xv2eiiBsuwIn9zlDCcqYMpHzHnpizZN9nJCciBfbqpYS5s4uqvtxz71Beartq2UGOdB0GpITt640JmBN7eiJeM68O9pKAPb4rJtmujiaKkwG9(bHjo9f01Mw8sc60lGvbcct3HacChLefbWjHKespWamk7HicQuPACtbDlFRWamk7HicXRnwSZ)HYdXujiaKkwG9(bHjo9fSgL(cFUtGmswX5obYibMgKhT)jdIqmvQIU2yXiVqWRNsnGzb2dsy03mYjGvCsVawCtjpbA6AaZcShKWOVzKtaRcoUlONanDDbNcQAwfCIfZtGMUgLaWdbwGLXiI(dcJZDohmchTk4antTFzJQdbztIYsSPpBeHOOFyZLfx6bke2C58RSyOhz2AA2G8fy7oxq20BKnYle86PuzQZJ2)qQLgGhnoXqLGaqQyb27heM40xqxd9GWNI4RR11Mwm5fcE9uQxWLEiW)VYIHEKD7jqtxVGl9qG)FLfd9ixlpedtTFztKNdBpnBUStVGe2sLTRUmXXgrZZfcBpnBuD3LcoSr5qwqcBpGTuo7HOS5I4yttGmQKktDE0(hsT0a8OXjgQ05a)0WxMEbjU20IxsqNEbSkqqy6oeqGBk8eOPR3DPGdSxiliPs08CXFXxDzIfJck5a6h0kKWGxtT)XnXbdbynbYOsQ05a)0WxMEbj(l2fXrumd6nwQGxwaHgAMA)YMiph2EA2CzNEbjSPpBPJtas2C(M8dHTMMTEYJ2liB)WwoqYMMazuzJIhWwoqYMxaXspYSPjqgvcBq06nBoG(bTcjBGxtT)bA2sLT1eptDE0(hsT0a8OXjgQ05a)0WxMEbjUEG8eqynbYOseF11MwmfuYb0pOviHbVMA)tSyLxRYja8kw1(CPh5yXkVwbcoQaaRAFU0Jm0UxsqNEbSkqqy6oeqGBIdgcWAcKrLuPZb(PHVm9cs8x8AyQZJ2)qQLgGhnoXqfp3FpYWa0b0r5uCTPfVKGo9cyvGGW0DiGa3N)dLhIPUGtbvnRamk7H4)vQWuNhT)HulnapACIHAg5jqUDTPfVKGo9cyvGGW0DiGa3ueLefbWjHKespWamk7HiMkUPeqyq6hiJ1Y)rEHSGXI5jqtx9c9uiDbRcoqZu7x2Ip9wHitq7qQiB6Zw64eGKT1fZsas2wNVj)WwQSjkBAcKrLWuNhT)HulnapACIHAKG2HurxpqEciSMazujIV6AtlEjbD6fWQabHP7qabUjoyiaRjqgvsLoh4Ng(Y0lirSOm15r7Fi1sdWJgNyOgjODiv01Mw8sc60lGvbcct3HacyQzQ9RFzBDZOugz7xqaBAhHSLEDO1gjm1(LnFQJALncE(PKaizJQKaWRiHn6hWMdOFqRqYg41u7FyRPzdcKT7CbzBnRLnCqGmKSbqzCy7bSrvsa4vKni6qGn0xNgGS9dB6nYMdOJsaKSPjqgvM68O9pKA5vXljOtVa66KrOyYL2b(a5jGWYja8k66sgeqXoG(bTcjm41u7FCtr51QCcaVIvagL9qeX5)q5HyQYja8kwlcGu7FIfBjbD6fWkaLXbMKQaivSantTFzZN6OwzJGNFkjas28bbhvaGe2OFaBoG(bTcjBGxtT)HTMMniq2UZfKT1Sw2WbbYqYgaLXHThWM0DVWwtytWHTFyt04JJPopA)dPwEnoXqDjbD6fqxNmcftU0oWhipbegi4Oca01LmiGIDa9dAfsyWRP2)4MIc6jqtxj39svWXnXbdbynbYOsQ05a)0WxMEbj(lASyljOtVawbOmoWKufaPIfOzQ9lB(uh1kB(GGJkaqcBnnBUeofu1moP7EbQISKOiGTvIqscPh2AcBcoSLtHniq2UZfKnrJJncE(PqylG0kB)WMEJS5dcoQaazBD)4zQZJ2)qQLxJtmuxsqNEb01jJqXKlTdmqWrfaORlzqafxqpbA66cofu1Sk44MIc6jqtxj39svWjwSOKOiaojKKq6bgGrzpe)Pc0UlVwbcoQaaRamk7H4VOm1(Lnjh80zGnQscaVISLtHnFqWrfaiBeufCyZb0pGn9zZN9LKJSqpPISDsIYuNhT)HulVgNyOkNaWRORnTynd4Ov0xsoYc9KkwXj9cyXnLqFj5il0tQyPkNaWRO7YRv5eaEfRorcbTDcnceH4RUp)hkpetf9LKJSqpPIvagL9qeHOUjoyiaRjqgvsLoh4Ng(Y0lir8v3GSlW4coAnlfsTh)PQUlVwLta4vScWOShY6PsDTIqtGmQvTJqy9HlnYuNhT)HulVgNyOceCuba6AtlwZaoAf9LKJSqpPIvCsVawCtbstJhTxq4Zh59WoFpkXFXhh4O0xyIdof3N)dLhIPI(sYrwONuXkaJYEiI4Q7YRvGGJkaWkaJYEiRNk11kcnbYOw1ocH1hU0i0m1(LnQscaVISj4CbrhxzldKNnf0iHn9ztGGS1kBjHTKnIdE6mWMmoii1hWg9dytVr2cjrzZpRdBEi9dq2s2O7Pj3iGPopA)dPwEnoXq15)amajVa4GUs)a4b9vfFLPopA)dPwEnoXqvobGxrxBAXaKgGK70lGUpFK3d789OKAbP7tR(l(QBkCIecA7eAeicXxJfdGrzperiw7ZfyTJq3ehmeG1eiJkPsNd8tdFz6fK4V41aTBkOe6ljhzHEsflXIbWOShIieR95cS2r46f1nXbdbynbYOsQ05a)0WxMEbj(lEnq7McnbYOw1ocH1hU04kayu2dbA)DH7OKOiaojKKq6bgGrzpeXuHPopA)dPwEnoXq15)amajVa4GUs)a4b9vfFLPopA)dPwEnoXqvobGxrxpqEciSMazujIV6AtlMsljOtVawjxAh4dKNaclNaWROBasdqYD6fq3NpY7HD(EusTG09Pv)fF1nforcbTDcnceH4RXIbWOShIieR95cS2rOBIdgcWAcKrLuPZb(PHVm9cs8x8AG2nfuc9LKJSqpPILyXayu2dreI1(Cbw7iC9I6M4GHaSMazujv6CGFA4ltVGe)fVgODtHMazuRAhHW6dxACfamk7HaT)xf1DusueaNessi9adWOShIyQWu7x28dOJi)Ww8yKdsu2(HTiHG2obKnnbYOsylv2CrCS5N1HniUXHnGWm9iZ2lOS1dBIUI1syljSf(rMTKWgeiB35cYgoVG8nBaugh2YPWwcWbkkBeu1EKztWHn6hWMlHtbvnzQZJ2)qQLxJtmupGoI8dSIroirD9a5jGWAcKrLi(QRnTyIdgcWAcKrL4VyrDJ004r7fe(8rEpSZ3Js8xSlCJdcKHScqzCGpFKxpyXFrPIBkO05)q5HyQl4uqvZkaZcKXIvETceCubaw1(CPhzODdWOShIienU1SEkioyiaRjqgvI)IDb0m1(LnxweDytWHnFqWrfaiBPYMlIJTFyldb20eiJkHnkG4gh2c9spYSf(rMnCEb5B2YPW28kBKjDi3VcntDE0(hsT8ACIHkqWrfaORnTykTKGo9cyLCPDGbcoQaaDJ004r7fe(8rEpSZ3Js8xSlCdqAasUtVa6McNiHG2oHgbIq81yXayu2dreI1(Cbw7i0nXbdbynbYOsQ05a)0WxMEbj(lEnq7MckH(sYrwONuXsSyamk7HicXAFUaRDeUErDtCWqawtGmQKkDoWpn8LPxqI)Ixd0U1eiJAv7iewF4sJRaGrzpe)PWfXrbqyq6hiJ1ssU7rgMCEHPaWW6xl0Xrbqyq6hiJ1Y)rEHSGRFTqhhfljOtVawbOmoWKufaPIL1tvHgAM68O9pKA514edvGGJkaqxpqEciSMazujIV6AtlMsljOtVawjxAh4dKNacdeCuba6MsljOtVawjxAhyGGJkaq3innE0EbHpFK3d789Oe)f7c3aKgGK70lGUPWjsiOTtOrGieFnwmagL9qeHyTpxG1ocDtCWqawtGmQKkDoWpn8LPxqI)Ixd0UPGsOVKCKf6jvSelgaJYEiIqS2NlWAhHRxu3ehmeG1eiJkPsNd8tdFz6fK4V41aTBnbYOw1ocH1hU04kayu2dXFkCrCuaegK(bYyTKK7EKHjNxykamS(1cDCuaegK(bYyT8FKxil46xl0XrXsc60lGvakJdmjvbqQyz9uvOHMP2VSjYZqWlpxyBLEFMn)a6iYpSfpg5GeLniA9Mn9gzJKriBHxUpSLe2sVFbDLnpbLTwEEqpYSP3iB4Gaziz78tP1(hcBnnBqGSLaCGIYMaPhz28bbhvaGm15r7Fi1YRXjgQhqhr(bwXihKOU20IjoyiaRjqgvI)If1nstJhTxq4Zh59WoFpkXFXUWnaJYEiIq04wZ6PG4GHaSMazuj(l2fqZu7x28dOJi)Ww8yKdsu2(HnP4zRPzRh2CYPGr9HTCkSnyccqYwu6lB4GazizlNcBnnB(8SGZhXge)afLTYZw0dq2kzukJSveq20NT4PmufzRetDE0(hsT8ACIH6b0rKFGvmYbjQRnTyIdgcWAcKrLi(QBkOeqyq6hiJ1ssU7rgMCEHPaWqSyEc00vGWGWq8Gcmn4jAvWbA3rjrraCsijH0dmaJYEiIPIBKMgpAVGWNpY7HD(EuI)IP44ahL(ctCWPSIRq7gG0aKCNEb0nLqFj5il0tQyXnLkONanDLC3lvbh3AcKrTQDecRpCPXvaWOShI)UGPMP2V(LnjfZGEJf2wPJ2)qyQ9lBR2Y3endxqaB)W2AIxKyZpGoI8dBXJroirzQZJ2)qQefZGEJfXhqhr(bwXihKOU20I1mGJwNw(wjAgUGGkoPxalUjoyiaRjqgvI)IxJ7Zh59WoFpkXFXUWTMazuRAhHW6dxACfamk7H4pvLP2VSTAlFt0mCbbS9dBxJxKytAshY9RS5dcoQaazQZJ2)qQefZGEJL4edvGGJkaqxBAXAgWrRtlFRendxqqfN0lGf3NpY7HD(EuI)IDHBnbYOw1ocH1hU04kayu2dXFQktTFztsWtraTGmksSTsoobiz7bS5dinaj3SbrR3S5jqtJf2Okja8ksyQZJ2)qQefZGEJL4edvN)dWaK8cGd6k9dGh0xv8vM68O9pKkrXmO3yjoXqvobGxrxpqEciSMazujIV6AtlwZaoALi4PiGwqgR4KEbS4McagL9qeXvrJfZjsiOTtOrGieFfA3AcKrTQDecRpCPXvaWOShI)IYu7x2Ke8ueqliJSfhB(SVez2(HTRXlsS5dinaj3Srvsa4vKTuztVr2WPW2tZgrXmO3SPpBYOYwu6lBfbqQ9pS5H0pazZN9LKJSqpPIm15r7FivIIzqVXsCIHQZ)byasEbWbDL(bWd6Rk(ktDE0(hsLOyg0BSeNyOkNaWRORnTynd4OvIGNIaAbzSIt6fWIBnd4Ov0xsoYc9KkwXj9cyXDE0EbHXbJAKi(QBpbA6krWtraTGmwbyu2drexRRHPopA)dPsumd6nwItmuJe0oKk6AtlwZaoALi4PiGwqgR4KEbS4(8rEpSZ3JseH41WuZu7x)YMlLttUzQ9lBI8EAYnBq06nBrPVS5N1Hn6hW2QT8Ts0mCbbUYMWeqcHnbspYSTUyQ3bizt6olpeeM68O9pK6son5w8sc60lGUozekEA5BLOz4ccGpoWNFkT2)46sgeqXuqjGWG0pqgRfm17aKWK7S8qqCJ004r7fe(8rEpSZ3Js8x8Xbok9fM4Gtb6yXOaimi9dKXAbt9oajm5olpee3NpY7HD(EuIiefAMA)YMlLttUzdIwVzZN9LiZwCSTAlFRendxqGiXMil9TJeIyZpRdB5uyZN9LiZgaZcKSr)a2g0xLnQIFwxM68O9pK6son5ooXqDjNMC7AtlwZaoAf9LKJSqpPIvCsVawCRzahToT8Ts0mCbbvCsVawCVKGo9cyDA5BLOz4ccGpoWNFkT2)4(8FO8qmv0xsoYc9Kkwbyu2drexzQ9lBUuon5MniA9MTvB5BLOz4ccylo2w9zZN9LilsSjYsF7iHi28Z6Wwof2CjCkOQjBcom15r7Fi1LCAYDCIH6son521MwSMbC060Y3krZWfeuXj9cyXnL0mGJwrFj5il0tQyfN0lGf3ljOtVawNw(wjAgUGa4Jd85NsR9pUlONanDDbNcQAwfCyQZJ2)qQl50K74edvN)dWaK8cGd6k9dGh0xv8vxrFvqcNrVWOIDXAzQZJ2)qQl50K74ed1LCAYTRnTynd4OvIGNIaAbzSIt6fWI7Z)HYdXuLta4vSk44MIYRv5eaEfRaKgGK70lGXIvqpbA66cofu1Sk44U8AvobGxXQtKqqBNqJari(k0UpFK3d789OKAbP7tR(lMcIdgcWAcKrLuPZb(PHVm9cs8NQlUaA3GSlW4coAnlfsTh)VkktTFzZLYPj3SbrR3SjYsIIa2wjcjj9isS5dcoQaaJJQKaWRiBZRS1dBaKgGKB2a5iJUYwra0JmBUeofu1moP7EPYMeKZHniA9Mnj0H0e2O7jdSD3kBnnBopH0EbSYuNhT)HuxYPj3XjgQl50KBxBAXuOzahTgLefbWjHKespvCsVawIfdimi9dKXAucUa)0W6nchLefbWjHKespq7MsLxRabhvaGvasdqYD6fq3LxRYja8kwbyu2dX)14UGEc001fCkOQzvWXnff0tGMUsU7LQGtSyf0tGMUUGtbvnRamk7Hicxelw51kbDinPQ95spYq7U8ALGoKMubyu2dreRzlrCWZEvrxRlZw36Eda]] )


end
