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


    spec:RegisterPack( "Assassination", 20210705, [[deLFvcqiKepsPGlrOqTjQQ(eiyuGOtbswLsP8kQknlQq3sPq7sj)ceAyiroMkPLrO6zkLyAekDnHI2gva(MsPQghHc5CkLKwhHIEhvqrmpKOUhHSpQO(NsjboOqHwisspKkstuPu5IuryJubvFKqbJKkOOoPsPkRej1lPckmtQi6Mub0ovk6NubfPHQusTuQa9uImvHsxvPKG2kvq(QsjrJvOG9kv)fudMYHfTyQYJvXKLYLH2mbFMOgTk1PLSALsc9AvIzl42cz3k(nWWPshNkO0Yv1ZrmDsxhP2Us13bPgpvfNhjmFHQ9J6(1ESDPwQyFtXPK4xP02NsXCrjXiXk2RXSlPu4IDj38CjLXU0KryxkgjKKqQj1cmDj3KIaiB9y7sea9FWU0TQUeXeIquU0BAV1bebrsfrhsTaZ5tbfIKk6aXUKhDf0T3096sTuX(MItjXVsPTpLI5IsIrIvSDPKwVbFxsQICAx6UAnC6EDPgsoDPyKqscPMulWWMdcKPrMAQPduWwmDKnXPK4xzQzQD6DoYirmzQ3iBXORBGc2Gar)6OqGnHqkZMcyJaIq2IXT2jzta8xiSPa2i5oYM7doiHuJmBAfHlM6nY22bgiOS5q5uKB2ONasiSjfQdYwon22U6GSbDfcSfsIYwamY4ZMENdBoWKO4ZwmsijHuZIPEJS5Gyi9HnhEiLXqi1cmSbr2CiCAOQjBekMdBqwcS5q40qvt2kcBkqwoGn2accSbE2adBjBbWiZMt3oOwm1BKnhyEbzZHhqY95tbLTAu8FAxLTAy7aI8sLTsGnOr22kstu2AvJTszta8STdcPwbeMac74ORUuOikPhBxIOyg0BS1JTV51ESDjCsVa26uTlLhTatx68vebmWkg5IeTl1qY5lxTatxAZs(MOz4c(Sbg22sSIjBo9RicyylwmYfjAx68LIFLDjnd4ORPKVvIMHl4VWj9cyJn)SrCXqawZxgvcBolITTWMF2oGipaSlOgLWMZIytSS5NnnFzuxAfHWkaUviBBKThJYAiS5mBoGU23u8ESDjCsVa26uTlLhTatx6PDv6h7snKC(YvlW0L2SKVjAgUGpBGHTRXkMSjnPl5gOS5G0Uk9JDPZxk(v2L0mGJUMs(wjAgUG)cN0lGn28Z2be5bGDb1Oe2CweBILn)SP5lJ6sRiewbWTczBJS9yuwdHnNzZb01(MBPhBxcN0lGTov7s5rlW0LCbGa8Jea9FWUudjNVC1cmDjjApfFbAzumzlgDDduWg4zZbrHhj3SbDP3S5rliGn2ed5)afjDjbWdpOpAFZRDTVPy7X2LWj9cyRt1UuE0cmDj58FGIDPZxk(v2L0mGJUi0Ek(c0Y4cN0lGn28ZgKS9yuwdHnkZ2vXzlEC2CJOdA5gk8zJYIy7kBqXMF208LrDPvecRa4wHSTr2EmkRHWMZSjEx6qXjGWA(YOs6BETR9nJzp2UeoPxaBDQ2LYJwGPl5cab4hja6)GDPgsoF5Qfy6ss0Ek(c0YiB(YMt4drMnWW21yft2Cqu4rYnBIH8FGISLkB6nYgon2acSrumd6nBkGnzuzlk9HTg9NAbg28qbWJS5e(qYrMUMuXUKa4Hh0hTV51U230b0JTlHt6fWwNQDPZxk(v2L0mGJUi0Ek(c0Y4cN0lGn28ZMMbC0f6djhz6Asfx4KEbSXMF2YJw7imoyuHe2eX2v28ZMhTGWIq7P4lqlJRhJYAiSrz2UU2sxkpAbMUKC(pqXU23C73JTlHt6fWwNQDPZxk(v2L0mGJUi0Ek(c0Y4cN0lGn28Z2be5bGDb1Oe2OSi22sxkpAbMUueTwHuXU21U0Eof5UhBFZR9y7s4KEbS1PAxc42LiO2LYJwGPlTNFLEbSlTNbASlbjBuHTNEqbWlJRgM6DGcyYD2aqtw4KEbSXMF2qbb8O1ocFarEayxqnkHnNfX2Xfok9bM4ItJnOylEC2GKTNEqbWlJRgM6DGcyYD2aqtw4KEbSXMF2oGipaSlOgLWgLztC2GQl1qY5lxTatxYHxtrUzd6sVzlk9HnNU1SjaE22SKVvIMHl47iB0taje2Oj1iZ22HPEhOGnP7SbGM0L2ZhEYiSlnL8Ts0mCbF4Jl8bmTslW01(MI3JTlHt6fWwNQDP8Ofy6s75uK7UudjNVC1cmDjhkNICZg0LEZMt4drMnFzBZs(wjAgUGVyYMdm9PIOJyZPBnB50yZj8HiZ2JzJc2eapBd6JYMyWPBxx68LIFLDjnd4Ol0hsoY01KkUWj9cyJn)SPzahDnL8Ts0mCb)foPxaBS5NT98R0lGRPKVvIMHl4dFCHpGPvAbg28Z2bacna0Zc9HKJmDnPIRhJYAiSrz2U21(MBPhBxcN0lGTov7s5rlW0L2ZPi3DPgsoF5Qfy6souof5MnOl9MTnl5BLOz4c(S5lBBcyZj8HilMS5atFQi6i2C6wZwon2CiCAOQjB0UDPZxk(v2L0mGJUMs(wjAgUG)cN0lGn28ZgvytZao6c9HKJmDnPIlCsVa2yZpB75xPxaxtjFRendxWh(4cFatR0cmS5NTg6rliS2XPHQMlA3U23uS9y7s4KEbS1PAxkpAbMUKlaeGFKaO)d2LqF0pHZia9ODjXgZUKa4Hh0hTV51U23mM9y7s4KEbS1PAx68LIFLDjnd4OlcTNIVaTmUWj9cyJn)SDaGqda9SKZ)bkUODzZpBqYwdOl58FGIRhfEKCNEbKT4XzRHE0ccRDCAOQ5I2Ln)S1a6so)hO4YnIoOLBOWNnklITRSbfB(z7aI8aWUGAuYQHc1Pu2CweBqYgXfdbynFzujlHCGbcWxMAhjS58wbSjw2GIn)S9z1GXDC0v2AKvnS5mBxfVlLhTatxApNIC31(MoGESDjCsVa26uTlLhTatxApNIC3LAi58LRwGPl5q5uKB2GU0B2CGjrXNTyKqssnIjBoiTRs)OVIH8FGISnaLTAy7rHhj3S95iJoYwJ(RrMnhcNgQA6R0DTVytII5Wg0LEZMe6skcBc1Kb2UlLTsGnxaHuEbC1LoFP4xzxcs20mGJUIsIIpCsijHuZcN0lGn2IhNTNEqbWlJRO8VadeG1Beokjk(WjHKesnlCsVa2ydk28ZgvyRb01t7Q0pUEu4rYD6fq28ZwdOl58FGIRhJYAiS5mBBHn)S1qpAbH1oonu1Cr7YMF2GKTg6rliSi31(I2LT4XzRHE0ccRDCAOQ56XOSgcBuMnXYw84S1a6IGUKIS06CPgz2GIn)S1a6IGUKISEmkRHWgLzBlDTRDPgkK0bThBFZR9y7s5rlW0LUuNlDjCsVa26uTR9nfVhBxcN0lGTov7snKC(YvlW0LCqKOyg0B2kb2Cbes5fq2GCaSTthg8tVaYgoyuHe2QHTdiYlvO6s5rlW0LikMb9UR9n3sp2UeoPxaBDQ2LaUDjcQDP8Ofy6s75xPxa7s7zGg7sexmeG18LrLSeYbgiaFzQDKWgLzt8U0E(WtgHDjsnYbewZxg1U23uS9y7s4KEbS1PAxc42LiO2LYJwGPlTNFLEbSlTNbASlHd(YuSEugh4diYRgSXMZSTLy2LAi58LRwGPl5uqKxnyJnNyWxMc2Cqugh2geByJnfWgjv6pvSlTNp8Kryx6rzCGjPs)PITU23mM9y7s4KEbS1PAx68LIFLDjIIzqVX26bY0yxIOFD0(Mx7s5rlW0LoziaNhTadCOiAxkuefEYiSlrumd6n26AFthqp2UeoPxaBDQ2LoFP4xzxcs2OcBAgWrxrjrXhojKKqQzHt6fWgBXJZwdOl58FGIlToxQrMnO6se9RJ238AxkpAbMU0jdb48OfyGdfr7sHIOWtgHDPtJ01(MB)ESDjCsVa26uTlLhTatxIeQdcNtdUvhSl1qY5lxTatxARPv2KMTJnAx2QP0kdbkyta8S5uALnfWMEJS507KGoY2JcpsUzd6sVzZjMDCarSvcSLkBba0S1O)ulW0LoFP4xzxIkS5rliSiH6GW50GB1bx0US5NTdiYda7cQrjS5Si2U21(MIr9y7s4KEbS1PAx68LIFLDjpAbHfjuheoNgCRo4I2Ln)S5rliSiH6GW50GB1bxpgL1qyJYSft28Z2be5bGDb1Oe2CweBITlLhTatxcNDCarDTV5wThBxcN0lGTov7s5rlW0LoziaNhTadCOiAxkuefEYiSl1aAx7BELs9y7s4KEbS1PAxkpAbMU0jdb48OfyGdfr7sHIOWtgHDPw94r7AFZRx7X2LWj9cyRt1U05lf)k7s4GVmfRgkuNszZzrSDnMS5lB4GVmfRhLXb(aI8QbBDP8Ofy6s5FYbHvW)4ODTV5vX7X2LYJwGPlL)jhe2LoqWUeoPxaBDQ21(Mx3sp2UuE0cmDPqjFRe4TI0n5iC0UeoPxaBDQ21(MxfBp2UuE0cmDjVuggiaRFDUq6s4KEbS1PAx7AxY9XdiYl1ES9nV2JTlLhTatxkDDdua7ckcy6s4KEbS1PAx7BkEp2UuE0cmDjpGQbSbleskWg01idRaFQPlHt6fWwNQDTV5w6X2LWj9cyRt1UuE0cmDPO8VGnybWd3WuV7sNVu8RSl9z1GXDC0v2AKvnS5mBxJzxY9XdiYlvycEatJ0LIzx7Bk2ESDjCsVa26uTlD(sXVYUebqh8QPTCPjkDaHXN2vlWSWj9cyJT4XzJaOdE10w7GqQvaHjGWoo6cN0lGTUuE0cmDjHasUpFkODTVzm7X2LWj9cyRt1UeWTlrqTlLhTatxAp)k9cyxApd0yx6kBBKniz7Phua8Y4QrtUaDgUGpb2n1Z9cN0lGn22gBuAj2yYguDP98HNmc7s740qvt4t77AFthqp2UeoPxaBDQ2LaUDjcQDP8Ofy6s75xPxa7s7zGg7sxzBJSbjBp9GcGxgxapSv4CWfoPxaBSTn2O0sSILnO6snKC(YvlW0LI9gzl3XpLr2C625GSve2O0sCXzZJwzRrJSPa20BKnhCtXaBtQ0pYgqGnNU1SjJJJSjUpSP3fHT9mqJSve2aUAfLb2eapBekMtnYSfaY1PlTNp8KryxsiKYyiKAbg4t77AFZTFp2UeoPxaBDQ2LaUDjcQDP8Ofy6s75xPxa7s75dpze2L0VMlOctOyoWKaq7sNVu8RSlPFnxqDPxx3jbMMGWE0ccS5NnizJkSPFnxqDPIVUtcmnbH9OfeylEC20VMlOU0RRdaeAaONvJ(tTadBolIn9R5cQlv81bacna0ZQr)PwGHnOylEC20VMlOU0RRISQHCEAn9ciSdlDokDeCd3Rd2LAi58LRwGPlTDOIFuniBqFxNB2GSeylhkGInIMkBE0ccSPFnxqLnOr2GohLnfWwQkg5QSPa2iumh2GU0B2CiCAOQ5QlTNbASlDTR9nfJ6X2LWj9cyRt1UeWTlrqTlLhTatxAp)k9cyxApd0yxs8U05lf)k7s6xZfuxQ4R7KattqypAbb28ZgKSrf20VMlOU0RR7KattqypAbb2IhNn9R5cQlv81bacna0ZQr)PwGHnNzt)AUG6sVUoaqObGEwn6p1cmSbfBXJZM(1Cb1Lk(QiRAiNNwtVac7WsNJshb3W96GDP98HNmc7s6xZfuHjumhysaODTV5wThBxcN0lGTov7s5rlW0LiH6GW50GB1b7sNVu8RSl9OWJK70lGDj3hpGiVuHj4bmnsx6Ax7BELs9y7s5rlW0LikMb9UlHt6fWwNQDTRDPw94r7X238Ap2UeoPxaBDQ2LYJwGPlHZooGOUudjNVC1cmDjNy2XbeXwQSjwFzdYy6lBqx6nBBNeuS50TEX22lkcBvQyGc2adBI7lBA(YOsCKnOl9MnhcNgQA6iBGNnOl9MTyPQJSb0B8HUiiBqNLYMa4zJaIq2WbFzkwSfJbcGnOZszReyZj8HiZ2be5byRiSDar1iZgT7QlD(sXVYUekiGhT2r4diYda7cQrjS5Si2elB(YMMbC0vdrx8Hj6NAkJrlCsVa2yZpBqYwd9Ofew740qvZfTlBXJZwd9OfewK7AFr7Yw84S1qpAbHLqiLXqi1cmlAx2IhNnCWxMIvdfQtPSrzrSjEmzZx2WbFzkwpkJd8be5vd2ylEC2OcB75xPxaxKAKdiSMVmQSbfB(zds2OcBAgWrxOpKCKPRjvCHt6fWgBXJZ2bacna0Zc9HKJmDnPIRhJYAiS5mBIZguDTVP49y7s4KEbS1PAxc42LiO2LYJwGPlTNFLEbSlTNbASlDarEayxqnkz1qH6ukBoZ2v2IhNnCWxMIvdfQtPSrzrSjEmzZx2WbFzkwpkJd8be5vd2ylEC2OcB75xPxaxKAKdiSMVmQDP98HNmc7s0eewOcb87AFZT0JTlHt6fWwNQDP8Ofy6se8)uXgShyqyIBDb7snKC(YvlW0LIrx3afSjrvj2uaBziWMMVmQe2GU0BaTYwYwd9OfeyljS5(f4lLchzZ9rb8)AKztZxgvcBnkQrMncam4ZwkO4ZMEJS5(vu(uWMMVmQDPZxk(v2L2ZVsVaUOjiSqfc4ZMF2OcBnGUi4)PInypWGWe36cc3a6sRZLAK7AFtX2JTlHt6fWwNQDP8Ofy6se8)uXgShyqyIBDb7sNVu8RSlTNFLEbCrtqyHkeWNn)Srf2AaDrW)tfBWEGbHjU1feUb0LwNl1i3LouCciSMVmQK(Mx7AFZy2JTlHt6fWwNQDP8Ofy6se8)uXgShyqyIBDb7snKC(YvlW0L2kVXHnhymYwryBakBPY2DjFZwJ(tTaJJSrtq2KOQeBkGT01nqbBojMn28OGnNWNmYnGS1O)AKzZHWPHQMoYgqVXh6IGSDbrx2eEqeBN01Tgz2o35lJKU05lf)k7s75xPxax0eewOcb8zZpBrjrXhojKKqQb(XOSgcBuMnkTeJyZpBqYMqjFRWpgL1qyJYIylMSfpoBhai0aqplc(FQyd2dmimXTUGRO0h4ZD(YiHTnY25oFzKal85rlWKb2OSi2O0s8yYw84Sra0bVAARaMnypkGrFYi3aUWj9cyJn)Srf28OfewbmBWEuaJ(KrUbCr7YMF2AOhTGWAhNgQAUODzlEC28Ofewr5)aOXgSmgruWGW4CNZbJWrx0USbvx7B6a6X2LWj9cyRt1UuE0cmDjHCGbcWxMAhjDPgsoF5Qfy6so8CydiWMdJP2rcBPY21TQVSr08CHWgqGnhMRwdh2OAiBiHnWZwkN1qu2eRVSP5lJkz1LoFP4xzxAp)k9c4IMGWcviGpB(zds28Ofew3vRHdSxiBizr08CHnNfX21TkBXJZgKSrf2C)c8Lsb8d0ulWWMF2iUyiaR5lJkzjKdmqa(Yu7iHnNfXMyzZx2ikMb9gBRhitJSbfBq11(MB)ESDjCsVa26uTlLhTatxsihyGa8LP2rsx6qXjGWA(YOs6BETlD(sXVYUeKSrf2C)c8Lsb8d0ulWWw84S1a6so)hO4sRZLAKzlEC2AaD90Uk9JlToxQrMnOyZpB75xPxax0eewOcb8zZpBexmeG18LrLSeYbgiaFzQDKWMZIyBlDPgsoF5Qfy6so8CydiWMdJP2rcBkGT01nqbBUGIagcBLaB1KhT2r2adB5qbBA(YOYgKGNTCOGnVaITAKztZxgvcBqx6nBUFb(sPGThOPwGbk2sLTTeBx7Bkg1JTlHt6fWwNQDPZxk(v2L2ZVsVaUOjiSqfc4ZMF2oaqObGEw740qvZ1Jrzne2CMTRuQlLhTatxcp3GAKHF09ROCADTV5wThBxcN0lGTov7sNVu8RSlTNFLEbCrtqyHkeWNn)SbjBrjrXhojKKqQb(XOSgcBIyJsS5NnQW2tpOa4LXvdaI8czdx4KEbSXw84S5rliS8c10ivdx0USbvxkpAbMUug5rtU7AFZRuQhBxcN0lGTov7s5rlW0LIO1kKk2LouCciSMVmQK(Mx7sNVu8RSlTNFLEbCrtqyHkeWNn)SrCXqawZxgvYsihyGa8LP2rcBIyt8UudjNVC1cmDPytVn6aP1kKkYMcylDDduW22HzlqbBBnOiGHTuztC208LrL01(MxV2JTlHt6fWwNQDPZxk(v2L2ZVsVaUOjiSqfc43LYJwGPlfrRvivSRDTlDAKES9nV2JTlHt6fWwNQDP8Ofy6sr5FbBWcGhUHPE3Lc1GWNwx66kMDPdfNacR5lJkPV51U05lf)k7sFwnyChhDLTgzr7YMF2GKnnFzuxAfHWkaUviBuMTdiYda7cQrjRgkuNszBBSDDft2IhNTdiYda7cQrjRgkuNszZzrSDCHJsFGjU40ydQUudjNVC1cmDPTNaBzRrylFKnAxhzJmLlYMEJSbgKnOl9MTaaAKOSfBSB3ITTcjiBqFJdBnkQrMnHKO4ZMENdBoDRzRHc1Pu2apBqx6nGwzlhkyZPB9QR9nfVhBxcN0lGTov7s5rlW0LIY)c2GfapCdt9Ul1qY5lxTatxA7jW2aylBncBqxHaBTczd6sVRHn9gzBqFu22cLioYgnbzZbkSDSbg28aecBqx6nGwzlhkyZPB9QlD(sXVYU0Nvdg3XrxzRrw1WMZSTfkX2gz7ZQbJ74ORS1iRg9NAbg28Z2be5bGDb1OKvdfQtPS5Si2oUWrPpWexCADTV5w6X2LWj9cyRt1UudjNVC1cmDjhEaj3Npfu2eapBBnnrPdiBoXt7QfyyReyBakBefZGEJn2apB1WwY2bacna0dBhkobSlD(sXVYUeKSra0bVAAlxAIshqy8PD1cmlCsVa2ylEC2ia6GxnT1oiKAfqyciSJJUWj9cyJnOyZpBuHnIIzqVX2kdb28ZgvyRHE0ccRDCAOQ5I2Ln)SfLefF4KqscPg4hJYAiSjInkXMF2GKnCWxMILwriScGJsFGpGiVAWgBoZM4SfpoBuHTg6rliSi31(I2LnO6s1O4)0UkCj0Lia6GxnT1oiKAfqyciSJJ2LQrX)PDv4kkcBvQyx6AxkpAbMUKqaj3Npf0Uunk(pTRclhaEzOlDTR9nfBp2UeoPxaBDQ2LYJwGPljeszmesTatxQHKZxUAbMUKefZHnhEiLXqi1cmSbDP3S5q40qvt2scBbWiZwsydAKnObdeu2cacYwY2jjkBGD8ztVr2ek5BLTg9NAbg2Ge8SvcS5q40qvt2GUcb2oGiKnV8CHTuoRbIfHnfilhWgBabbOwDPZxk(v2LOcBefZGEJT1dKPr28ZgKSbjBhai0aqpRDCAOQ56XOSgcBoZ2wLsSfpoBhai0aqpRDCAOQ56XOSgcBuMTTWguS5NnuqapATJWhqKha2fuJsyZzrSjw28ZMMVmQlTIqyfa3kKnNz7kLylEC2AOhTGWAhNgQAUODzlEC28aecB(ztOKVv4hJYAiSrz2exSSbvx7BgZESDjCsVa26uTlD(sXVYUevyJOyg0BSTEGmnYMF2qbb8O1ocFarEayxqnkHnNfXMyzZpBqYMqaaE2GKniztOKVv4hJYAiSTr2exSSbfBqKnizlpAbg4daeAaOh22gB75xPxaxcHugdHulWaFApBqXguS5mBcba4zds2GKnHs(wHFmkRHW2gztCXY2gz7aaHga6zTJtdvnxpgL1qyBBSTNFLEbCTJtdvnHpTNnOydISbjB5rlWaFaGqda9W22yBp)k9c4siKYyiKAbg4t7zdk2GInO6s5rlW0LecPmgcPwGPR9nDa9y7s4KEbS1PAxkpAbMUebDjfPl1qY5lxTatxsII5WMe6skcBqx6nBoeonu1KTKWwamYSLe2GgzdAWabLTaGGSLSDsIYgyhF20BKnHs(wzRr)PwGXr28Ov2CFuaF208LrLWMENkBqxHaBHAhzlv2cysu2Usjsx68LIFLDjQWgrXmO3yB9azAKn)SbjBhai0aqpRDCAOQ56XOSgcBuMTRS5NnnFzuxAfHWkaUviBoZ2vkXw84S1qpAbH1oonu1Cr7Yw84SjuY3k8Jrzne2OmBxPeBq11(MB)ESDjCsVa26uTlD(sXVYUevyJOyg0BSTEGmnYMF2GKnHaa8SbjBqYMqjFRWpgL1qyBJSDLsSbfBqKT8OfyGpaqObGEydk2CMnHaa8SbjBqYMqjFRWpgL1qyBJSDLsSTr2oaqObGEw740qvZ1Jrzne22gB75xPxax740qvt4t7zdk2GiB5rlWaFaGqda9WguSbvxkpAbMUebDjfPR9nfJ6X2LWj9cyRt1UeWTlrqTlLhTatxAp)k9cyxApd0yxIkSPzahDnL8Ts0mCb)foPxaBSfpoBuHnnd4Ol0hsoY01KkUWj9cyJT4Xz7aaHga6zH(qYrMUMuX1Jrzne2OmBXKTnYM4STn20mGJUAi6Ipmr)utzmAHt6fWwxQHKZxUAbMUKefZHnhcNgQAYg010aqZg0LEZ2ML8Ts0mCbFFDcFi5itxtQiBLaBPRBOoPxa7s75dpze2L2XPHQMWtjFRendxWh(aMwPfy6AFZTAp2UeoPxaBDQ2LaUDjcQDP8Ofy6s75xPxa7s75dpze2L2XPHQMWhWoo5OWhW0kTatx68LIFLDPdyhNC01fk(kh2IhNTdyhNC01GNheaFJT4Xz7a2XjhDnGb7snKC(YvlW0LKOyoS5q40qvt2GU0B2C4HugdHulWWwon2KqxsryljSfaJmBjHnOr2GgmqqzlaiiBjBNKOSb2XNn9gztOKVv2A0FQfy6s7zGg7sx7AFZRuQhBxcN0lGTov7sa3Ueb1UuE0cmDP98R0lGDP9mqJDjHaa8SbjBqYMqjFRWpgL1qyBJSjoLydk2GiBqY2vXPeBBJT98R0lGRDCAOQj8P9SbfBqXMZSjeaGNnizds2ek5Bf(XOSgcBBKnXPeBBKTdaeAaONLqiLXqi1cmRhJYAiSbfBqKniz7Q4uITTX2E(v6fW1oonu1e(0E2GInOylEC28OfewcHugdHulWa7rliSODzlEC2AOhTGWsiKYyiKAbMfTlBXJZMqjFRWpgL1qyJYSjoL6sNVu8RSlDa74KJU2XrVP47s75dpze2L2XPHQMWhWoo5OWhW0kTatx7BE9Ap2UeoPxaBDQ2LaUDjcQDP8Ofy6s75xPxa7s7zGg7scba4zds2GKnHs(wHFmkRHW2gztCkXguSbr2GKTRItj22gB75xPxax740qvt4t7zdk2GInNztiaapBqYgKSjuY3k8Jrzne22iBItj22iBhai0aqplc6skY6XOSgcBqXgezds2UkoLyBBSTNFLEbCTJtdvnHpTNnOydk2IhNTgqxe0LuKLwNl1iZw84SjuY3k8Jrzne2OmBItPU05lf)k7shWoo5ORPKVvyHe7s75dpze2L2XPHQMWhWoo5OWhW0kTatx7BEv8ESDjCsVa26uTlD(sXVYUevyJOyg0BSTEGmnYMF2AaD90Uk9JlToxQrMn)Srf2AOhTGWAhNgQAUODzZpB75xPxax740qvt4PKVvIMHl4dFatR0cmS5NT98R0lGRDCAOQj8bSJtok8bmTslW0LYJwGPlTJtdvn7AFZRBPhBxcN0lGTov7s5rlW0LqFi5itxtQyxQHKZxUAbMUKt4djhz6Asfzd6BCyBakBefZGEJn2YPXMhqVzZbPDv6hzlNgBIH8FGISLpYgTlBcGNTayKzdhaT89QlD(sXVYUevyJOyg0BSTEGmnYMF2GKnQWwdOl58FGIRhfEKCNEbKn)S1a66PDv6hxpgL1qyZz2elB(YMyzBBSDCHJsFGjU40ylEC2AaD90Uk9JRhJYAiSTn2O0kMS5mBA(YOU0kcHvaCRq2GIn)SP5lJ6sRiewbWTczZz2eBx7BEvS9y7s4KEbS1PAxkpAbMUe5U27snKC(YvlW0LKURD2kb2GgzlFKT0dqRSPa2CIzhhqKJSLtJTuvmYvztbSrOyoSbDP3SjHUKIWMqnzGT7szReydAKnObdeu2GojkYwe4r207Cy7odcSP3iBhai0aqpRU05lf)k7snGUEAxL(XLwNl1iZMF2GKnQW2bacna0ZIGUKISEmBuWw84SDaGqda9S2XPHQMRhJYAiS5mBxfNnOylEC2AaDrqxsrwADUuJCx7BEnM9y7s4KEbS1PAx68LIFLDjpAbHLxaaAbAIUEmpkBXJZMhGqyZpBcL8Tc)yuwdHnkZ2wOeBXJZwd9Ofew740qvZfTBxkpAbMUKlqlW01(MxDa9y7s4KEbS1PAx68LIFLDPg6rliS2XPHQMlA3UuE0cmDjVaa0GfOFk6AFZRB)ESDjCsVa26uTlD(sXVYUud9Ofew740qvZfTBxkpAbMUKh(e8VuJCx7BEvmQhBxcN0lGTov7sNVu8RSl1qpAbH1oonu1Cr72LYJwGPljup6faGwx7BEDR2JTlHt6fWwNQDPZxk(v2LAOhTGWAhNgQAUOD7s5rlW0LY5Ge9Za8jdHU23uCk1JTlHt6fWwNQDPZxk(v2LOcBefZGEJTvgcS5NTOKO4dNessi1a)yuwdHnrSrPUuE0cmDPtgcW5rlWahkI2LcfrHNmc7s75uK7U23u8R9y7s4KEbS1PAxkpAbMUK(1Cb1RDPgsoF5Qfy6ssumh20BKn3VaFPuWgrtLnpAbb20VMlOYg0LEZMdHtdvnDKnGEJp0fbzJMGSbg2oaqObGE6sNVu8RSlTNFLEbCPFnxqfMqXCGjbGYMi2UYMF2GKTg6rliS2XPHQMlAx2IhNnpaHWMF2ek5Bf(XOSgcBuweBItj2GIT4Xzds22ZVsVaU0VMlOctOyoWKaqzteBIZMF2OcB6xZfuxQ4RdaeAaON1JzJc2GIT4XzJkSTNFLEbCPFnxqfMqXCGjbG21(MIlEp2UeoPxaBDQ2LoFP4xzxAp)k9c4s)AUGkmHI5atcaLnrSjoB(zds2AOhTGWAhNgQAUODzlEC28aecB(ztOKVv4hJYAiSrzrSjoLydk2IhNnizBp)k9c4s)AUGkmHI5atcaLnrSDLn)Srf20VMlOU0RRdaeAaON1JzJc2GIT4XzJkSTNFLEbCPFnxqfMqXCGjbG2LYJwGPlPFnxqv8U21UudO9y7BEThBxcN0lGTov7sa3Ueb1UuE0cmDP98R0lGDP9mqJDj3VaFPua)an1cmS5NnizRb0LC(pqX1Jrzne2OmBhai0aqpl58FGIRg9NAbg2IhNT98R0lGRhLXbMKk9Nk2ydQUudjNVC1cmDjNSIkLncEatlFkytmK)duKWMa4zZ9lWxkfS9an1cmSvcSbnY2DUJSTLyYgo4ltbBpkJdBGNnXq(pqr2GUcb2qFCRhzdmSP3iBUFfLpfSP5lJAxApF4jJWUe5s5cFO4eqy58FGIDTVP49y7s4KEbS1PAxc42LiO2LYJwGPlTNFLEbSlTNbASl5(f4lLc4hOPwGHn)SbjBn0JwqyrUR9fTlB(zJ4IHaSMVmQKLqoWab4ltTJe2CMnXzlEC22ZVsVaUEughysQ0FQyJnO6snKC(YvlW0LCYkQu2i4bmT8PGnhK2vPFKWMa4zZ9lWxkfS9an1cmSvcSbnY2DUJSTLyYgo4ltbBpkJdBGNnP7ANTIWgTlBGHnXJ13U0E(WtgHDjYLYf(qXjGWpTRs)yx7BULESDjCsVa26uTlbC7seu7s5rlW0L2ZVsVa2L2Zan2LAOhTGWAhNgQAUODzZpBqYwd9OfewK7AFr7Yw84SfLefF4KqscPg4hJYAiS5mBuInOyZpBnGUEAxL(X1Jrzne2CMnX7snKC(YvlW0LCYkQu2CqAxL(rcBLaBoeonu10xP7AhIoWKO4ZwmsijHudBfHnAx2YPXg0iB35oYM4(YgbpGPrylGckBGHn9gzZbPDv6hzB7aX2L2ZhEYiSlrUuUWpTRs)yx7Bk2ESDjCsVa26uTlLhTatxso)hOyxQHKZxUAbMUKKlEQmWMyi)hOiB50yZbPDv6hzJGkTlBUFbE2uaBoHpKCKPRjvKTts0U05lf)k7sAgWrxOpKCKPRjvCHt6fWgB(zJkS1qpAbHLC(pqXf6djhz6AsfBS5NTgqxY5)afxUr0bTCdf(SrzrSDLn)SDaGqda9SqFi5itxtQ46XOSgcBuMnXzZpBexmeG18LrLSeYbgiaFzQDKWMi2UYMF2(SAW4oo6kBnYQg2CMnhaB(zRb0LC(pqX1Jrzne22gBuAft2OmBA(YOU0kcHvaCRWU23mM9y7s4KEbS1PAx68LIFLDjnd4Ol0hsoY01KkUWj9cyJn)SbjBOGaE0AhHpGipaSlOgLWMZIy74chL(atCXPXMF2oaqObGEwOpKCKPRjvC9yuwdHnkZ2v28ZwdORN2vPFC9yuwdHTTXgLwXKnkZMMVmQlTIqyfa3kKnO6s5rlW0LEAxL(XU230b0JTlHt6fWwNQDP8Ofy6sUaqa(rcG(pyxQHKZxUAbMUKyi)hOiB0Uxq01r2YabWM(fsytbSrtq2kLTKWwYgXfpvgytgh8tf8SjaE20BKTqsu2C6wZMhkaEKTKnHAkYn(DjbWdpOpAFZRDTV52VhBxcN0lGTov7sNVu8RSl9OWJK70lGS5NTdiYda7cQrjRgkuNszZzrSDLn)SbjBUr0bTCdf(SrzrSDLT4Xz7XOSgcBuweBADUaRveYMF2iUyiaR5lJkzjKdmqa(Yu7iHnNfX2wydk28ZgKSrf2qFi5itxtQyJT4Xz7XOSgcBuweBADUaRveY22ytC28ZgXfdbynFzujlHCGbcWxMAhjS5Si22cBqXMF2GKnnFzuxAfHWkaUviBBKThJYAiSbfBoZMyzZpBrjrXhojKKqQb(XOSgcBIyJsDP8Ofy6sY5)af7AFtXOESDjCsVa26uTljaE4b9r7BETlLhTatxYfacWpsa0)b7AFZTAp2UeoPxaBDQ2LYJwGPljN)duSlD(sXVYUevyBp)k9c4ICPCHpuCciSC(pqr28Z2JcpsUtVaYMF2oGipaSlOgLSAOqDkLnNfX2v28ZgKS5grh0Ynu4ZgLfX2v2IhNThJYAiSrzrSP15cSwriB(zJ4IHaSMVmQKLqoWab4ltTJe2CweBBHnOyZpBqYgvyd9HKJmDnPIn2IhNThJYAiSrzrSP15cSwriBBJnXzZpBexmeG18LrLSeYbgiaFzQDKWMZIyBlSbfB(zds208LrDPvecRa4wHSTr2EmkRHWguS5mBxfNn)SfLefF4KqscPg4hJYAiSjInk1LouCciSMVmQK(Mx7AFZRuQhBxcN0lGTov7s5rlW0LoFfradSIrUir7shkobewZxgvsFZRDPZxk(v2LiUyiaR5lJkHnNfXM4S5NnuqapATJWhqKha2fuJsyZzrSjw28Zgo4ltX6rzCGpGiVAWgBoZM4uIn)SbjBuHTdaeAaON1oonu1C9y2OGT4XzRb01t7Q0pU06CPgz2GIn)S9yuwdHnkZM4S5lBBHTTXgKSrCXqawZxgvcBolInXYguDPgsoF5Qfy6so9RicyylwmYfjkBGHTi6GwUbKnnFzujSLkBI1x2C6wZg034W2tptnYSbOv2QHnX3ymjSLe2cGrMTKWg0iB35oYgoaA5B2Eugh2YPXw(4abLncQAnYSr7YMa4zZHWPHQMDTV51R9y7s4KEbS1PAxkpAbMU0t7Q0p2LAi58LRwGPl5Warx2ODzZbPDv6hzlv2eRVSbg2YqGnnFzujSbj034WwO2RrMTayKzdhaT8nB50yBakBKjDj3afQU05lf)k7suHT98R0lGlYLYf(PDv6hzZpBOGaE0AhHpGipaSlOgLWMZIytSS5NThfEKCNEbKn)SbjBUr0bTCdf(SrzrSDLT4Xz7XOSgcBuweBADUaRveYMF2iUyiaR5lJkzjKdmqa(Yu7iHnNfX2wydk28ZgKSrf2qFi5itxtQyJT4Xz7XOSgcBuweBADUaRveY22ytC28ZgXfdbynFzujlHCGbcWxMAhjS5Si22cBqXMF208LrDPvecRa4wHSTr2EmkRHWMZSbjBILnFzds2E6bfaVmUAj5UgzyYbqpThdlCsVa2yBBSft2GInFzds2E6bfaVmUAaqKxiB4cN0lGn22gBXKnOyZx2GKT98R0lGRhLXbMKk9Nk2yBBS5aydk2GQR9nVkEp2UeoPxaBDQ2LYJwGPl90Uk9JDPZxk(v2LOcB75xPxaxKlLl8HItaHFAxL(r28ZgvyBp)k9c4ICPCHFAxL(r28ZgkiGhT2r4diYda7cQrjS5Si2elB(z7rHhj3PxazZpBqYMBeDql3qHpBuweBxzlEC2EmkRHWgLfXMwNlWAfHS5NnIlgcWA(YOswc5adeGVm1osyZzrSTf2GIn)SbjBuHn0hsoY01Kk2ylEC2EmkRHWgLfXMwNlWAfHSTn2eNn)SrCXqawZxgvYsihyGa8LP2rcBolITTWguS5NnnFzuxAfHWkaUviBBKThJYAiS5mBqYMyzZx2GKTNEqbWlJRwsURrgMCa0t7XWcN0lGn22gBXKnOyZx2GKTNEqbWlJRgae5fYgUWj9cyJTTXwmzdk28LnizBp)k9c46rzCGjPs)PIn22gBoa2GInO6shkobewZxgvsFZRDTV51T0JTlHt6fWwNQDP8Ofy6sNVIiGbwXixKODPgsoF5Qfy6so8me8YZf2IrGtWMt)kIag2IfJCrIYg0LEZMEJSrYiKTaqUoSLe2spWo6iBE0kBL8a(AKztVr2WbFzky7aMwPfyiSvcSbnYw(4abLnAsnYS5G0Uk9JDPZxk(v2LiUyiaR5lJkHnNfXM4S5NnuqapATJWhqKha2fuJsyZzrSjw28Z2Jrzne2OmBIZMVSTf22gBqYgXfdbynFzujS5Si2elBq11(MxfBp2UeoPxaBDQ2LYJwGPlD(kIagyfJCrI2LAi58LRwGPl50VIiGHTyXixKOSbg2KILTsGTAyZnNggvh2YPX2G5hOGTO0h2WbFzkylNgBLaBoXSJdiInObdeu2Aa2IapYwlJszKTgnYMcylwQcrhym2LoFP4xzxI4IHaSMVmQe2eX2v28Zgvy7Phua8Y4QLK7AKHjha90EmSWj9cyJn)SfLefF4KqscPg4hJYAiSjInkXMF2qbb8O1ocFarEayxqnkHnNfXgKSDCHJsFGjU40yBJSDLnOyZpBpk8i5o9ciB(zJkSH(qYrMUMuXgB(zds2OcBn0JwqyrUR9fTlB(zds2WbFzkwnuOoLYgLfXM4XKnFzdh8LPy9OmoWhqKxnyJnOydk28ZMMVmQlTIqyfa3kKTnY2Jrzne2CMnX21U21U0o(Kcm9nfNsIFLsoaX3QDjOZFQrM0L2kJrhCZT3MIbXKn2I9gzRICbVYMa4zdc75uKBiW2JoS01Jn2iGiKTKwbrPIn2o35iJKftTtwdY2vXKnNcMD8vSXgeE6bfaVmUIbiWMcydcp9GcGxgxXWcN0lGniWgKI7dulMANSgKnhGyYMtbZo(k2ydcp9GcGxgxXaeytbSbHNEqbWlJRyyHt6fWgeydYR(a1IPMPERmgDWn3EBkget2yl2BKTkYf8kBcGNni4(4be5Lkey7rhw66XgBeqeYwsRGOuXgBN7CKrYIP2jRbztSIjBofm74RyJniqa0bVAARyacSPa2Gabqh8QPTIHfoPxaBqGniV6dulMANSgKnXkMS5uWSJVIn2Gabqh8QPTIbiWMcydceaDWRM2kgw4KEbSbb2sLnNWHPojBqE1hOwm1ozniBXumzZPGzhFfBSbHNEqbWlJRyacSPa2GWtpOa4LXvmSWj9cydcSb5vFGAXu7K1GS5aet2Cky2XxXgBq4Phua8Y4kgGaBkGni80dkaEzCfdlCsVa2GaBqE1hOwm1ozniBBFXKnNcMD8vSXge0VMlOUUUIbiWMcydc6xZfux61vmab2GCl(a1IP2jRbzB7lMS5uWSJVIn2GG(1Cb1L4RyacSPa2GG(1Cb1Lk(kgGaBqkUpqTyQDYAq2eJet2Cky2XxXgBqq)AUG666kgGaBkGniOFnxqDPxxXaeydsX9bQftTtwdYMyKyYMtbZo(k2ydc6xZfuxIVIbiWMcydc6xZfuxQ4RyacSb5w8bQftnt9wzm6GBU92umiMSXwS3iBvKl4v2eapBqOvpEuiW2JoS01Jn2iGiKTKwbrPIn2o35iJKftTtwdY2wvmzZPGzhFfBSbHNEqbWlJRyacSPa2GWtpOa4LXvmSWj9cydcSb5vFGAXuZuVvgJo4MBVnfdIjBSf7nYwf5cELnbWZgeoncey7rhw66XgBeqeYwsRGOuXgBN7CKrYIP2jRbzBlIjBofm74RyJniqa0bVAARyacSPa2Gabqh8QPTIHfoPxaBqGnif3hOwm1ozniBXumzZPGzhFfBSjvroLncfJM(WMymBkGnNKozRv7fPadBax8tf8SbjeHInif3hOwm1ozniBBFXKnNcMD8vSXMuf5u2iumA6dBIXSPa2Cs6KTwTxKcmSbCXpvWZgKqek2GuCFGAXu7K1GSDLsIjBofm74RyJnPkYPSrOy00h2eJztbS5K0jBTAVifyyd4IFQGNniHiuSbP4(a1IP2jRbz76vXKnNcMD8vSXMuf5u2iumA6dBIXSPa2Cs6KTwTxKcmSbCXpvWZgKqek2GuCFGAXu7K1GSj(vXKnNcMD8vSXge0VMlOUeFfdqGnfWge0VMlOUuXxXaeydYR(a1IP2jRbztCXft2Cky2XxXgBqq)AUG666kgGaBkGniOFnxqDPxxXaeydYR(a1IPMPERmgDWn3EBkget2yl2BKTkYf8kBcGNni0akey7rhw66XgBeqeYwsRGOuXgBN7CKrYIP2jRbztSIjBofm74RyJniG(qYrMUMuX2kgGaBkGni0qpAbHvmSqFi5itxtQydcSb5vFGAXu7K1GSD9QyYMtbZo(k2ydcp9GcGxgxXaeytbSbHNEqbWlJRyyHt6fWgeydsX9bQftTtwdY2vXft2Cky2XxXgBq4Phua8Y4kgGaBkGni80dkaEzCfdlCsVa2GaBqkUpqTyQDYAq2UkwXKnNcMD8vSXgeE6bfaVmUIbiWMcydcp9GcGxgxXWcN0lGniWgKx9bQftntDS3iBqGMGWLIreiWwE0cmSbDsyBakBca6PXwnSP3fHTkYf86IPE7f5cEfBST9zlpAbg2cfrjlM6UK7deQa2L2WgylgjKKqQj1cmS5GazAKPEdBGnQPduWwmDKnXPK4xzQzQ3WgyZP35iJeXKPEdBGTnYwm66gOGniq0VokeytiKYSPa2iGiKTyCRDs2ea)fcBkGnsUJS5(Gdsi1iZMwr4IPEdBGTnY22bgiOS5q5uKB2ONasiSjfQdYwon22U6GSbDfcSfsIYwamY4ZMENdBoWKO4ZwmsijHuZIPEdBGTnYMdIH0h2C4HugdHulWWgezZHWPHQMSrOyoSbzjWMdHtdvnzRiSPaz5a2ydiiWg4zdmSLSfaJmBoD7GAXuVHnW2gzZbMxq2C4bKCF(uqzRgf)N2vzRg2oGiVuzReydAKTTI0eLTw1yRu2eapB7GqQvaHjGWoo6IPMPEdBGnNWh8qRyJnpua8iBhqKxQS5HY1qwSfJNd6Qe2gWSX78JeOdSLhTadHnWeOyXuNhTadz5(4be5LQO01nqbSlOiGHPopAbgYY9XdiYlvFfbrpGQbSbleskWg01idRaFQHPopAbgYY9XdiYlvFfbXO8VGnybWd3WuVD09XdiYlvycEatJikMowcI(SAW4oo6kBnYQgNVgtM68Ofyil3hpGiVu9veefci5(8PG6yjiIaOdE10wU0eLoGW4t7QfyIhNaOdE10w7GqQvaHjGWooktDE0cmKL7JhqKxQ(kcI75xPxaDCYiu0oonu1e(0Eh3Zank66gH8Phua8Y4QrtUaDgUGpb2n1Z92O0sSXekM6nWwS3iB5o(PmYMt3ohKTIWgLwIloBE0kBnAKnfWMEJS5GBkgyBsL(r2acS50TMnzCCKnX9Hn9UiSTNbAKTIWgWvROmWMa4zJqXCQrMTaqUom15rlWqwUpEarEP6RiiUNFLEb0XjJqrcHugdHulWaFAVJ7zGgfDDJq(0dkaEzCb8WwHZb3gLwIvSqXuVb22ouXpQgKnOVRZnBqwcSLdfqXgrtLnpAbb20VMlOYg0iBqNJYMcylvfJCv2uaBekMdBqx6nBoeonu1CXuNhTadz5(4be5LQVIG4E(v6fqhNmcfPFnxqfMqXCGjbG64EgOrrxDSeePFnxqDDDDNeyAcc7rli4hsQOFnxqDj(6ojW0ee2JwqiEC9R5cQRRRdaeAaONvJ(tTaJZI0VMlOUeFDaGqda9SA0FQfyGkEC9R5cQRRRISQHCEAn9ciSdlDokDeCd3RdYuNhTadz5(4be5LQVIG4E(v6fqhNmcfPFnxqfMqXCGjbG64EgOrrI7yjis)AUG6s81DsGPjiShTGGFiPI(1Cb1111DsGPjiShTGq846xZfuxIVoaqObGEwn6p1cmoRFnxqDDDDaGqda9SA0FQfyGkEC9R5cQlXxfzvd580A6fqyhw6Cu6i4gUxhKPopAbgYY9XdiYlvFfbrsOoiCon4wDqhDF8aI8sfMGhW0iIU6yji6rHhj3PxazQZJwGHSCF8aI8s1xrqKOyg0BMAM6nSb2CcFWdTIn2WD8PGnTIq20BKT8OGNTIWwUNvi9c4IPopAbgIOl15ct9gyZbrIIzqVzReyZfqiLxazdYbW2oDyWp9ciB4GrfsyRg2oGiVuHIPopAbgIVIGirXmO3m15rlWq8vee3ZVsVa64KrOisnYbewZxgvh3ZankI4IHaSMVmQKLqoWab4ltTJeklot9gyZPGiVAWgBoXGVmfS5GOmoSni2WgBkGnsQ0FQitDE0cmeFfbX98R0lGoozek6rzCGjPs)PInh3Zankch8LPy9OmoWhqKxnyZ5TetM68Ofyi(kcINmeGZJwGboue1XjJqrefZGEJnhj6xhv0vhlbrefZGEJT1dKPrM68Ofyi(kcINmeGZJwGboue1XjJqrNgXrI(1rfD1XsqeKurZao6kkjk(WjHKesnlCsVa2IhVb0LC(pqXLwNl1idft9gyBRPv2KMTJnAx2QP0kdbkyta8S5uALnfWMEJS507KGoY2JcpsUzd6sVzZjMDCarSvcSLkBba0S1O)ulWWuNhTadXxrqKeQdcNtdUvh0Xsqev8OfewKqDq4CAWT6GlAx)hqKha2fuJsCw0vM68Ofyi(kcI4SJdiYXsqKhTGWIeQdcNtdUvhCr763Jwqyrc1bHZPb3QdUEmkRHq5y6)aI8aWUGAuIZIeltDE0cmeFfbXtgcW5rlWahkI64KrOOgqzQZJwGH4RiiEYqaopAbg4qruhNmcf1QhpktDE0cmeFfbX8p5GWk4FCuhlbr4GVmfRgkuNsDw01y6lo4ltX6rzCGpGiVAWgtDE0cmeFfbX8p5GWU0bcYuNhTadXxrqmuY3kbERiDtochLPopAbgIVIGOxkddeG1Voxim1m1BydS5uai0aqpeM6nW22tGTS1iSLpYgTRJSrMYfztVr2adYg0LEZwaansu2In2TBX2wHeKnOVXHTgf1iZMqsu8ztVZHnNU1S1qH6ukBGNnOl9gqRSLdfS50TEXuNhTadzDAeFfbXO8VGnybWd3WuVDmudcFAIUUIPJhkobewZxgvIORowcI(SAW4oo6kBnYI21pKA(YOU0kcHvaCRqkFarEayxqnkz1qH6u62UUIz84hqKha2fuJswnuOoL6SOJlCu6dmXfNgum1BGTTNaBdGTS1iSbDfcS1kKnOl9Ug20BKTb9rzBluI4iB0eKnhOW2XgyyZdqiSbDP3aALTCOGnNU1lM68OfyiRtJ4RiigL)fSblaE4gM6TJLGOpRgmUJJUYwJSQX5TqPn(z1GXDC0v2AKvJ(tTaJ)diYda7cQrjRgkuNsDw0Xfok9bM4ItJPEdS5Wdi5(8PGYMa4zBRPjkDazZjEAxTadBLaBdqzJOyg0BSXg4zRg2s2oaqObGEy7qXjGm15rlWqwNgXxrquiGK7ZNcQJLGiija6GxnTLlnrPdim(0UAbM4Xja6GxnT1oiKAfqyciSJJcLFQqumd6n2wzi4Nkn0JwqyTJtdvnx0U(JsIIpCsijHud8JrzneruYpK4GVmflTIqyfahL(aFarE1GnNfpECQ0qpAbHf5U2x0Uq5ynk(pTRcxrryRsffD1XAu8FAxfwoa8YGORowJI)t7QWLGicGo4vtBTdcPwbeMac74Om1BGnjkMdBo8qkJHqQfyyd6sVzZHWPHQMSLe2cGrMTKWg0iBqdgiOSfaeKTKTtsu2a74ZMEJSjuY3kBn6p1cmSbj4zReyZHWPHQMSbDfcSDariBE55cBPCwdelcBkqwoGn2accqTyQZJwGHSonIVIGOqiLXqi1cmowcIOcrXmO3yB9azA0pKqEaGqda9S2XPHQMRhJYAioVvPu84hai0aqpRDCAOQ56XOSgcL3cu(rbb8O1ocFarEayxqnkXzrI1VMVmQlTIqyfa3k05RukE8g6rliS2XPHQMlA34X9aeIFHs(wHFmkRHqzXflum15rlWqwNgXxrquiKYyiKAbghlbruHOyg0BSTEGmn6hfeWJw7i8be5bGDb1OeNfjw)qkeaGhsifk5Bf(XOSgYgfxSqjgd5bacna0Z22ZVsVaUecPmgcPwGb(0EOGYzHaa8qcPqjFRWpgL1q2O4IDJhai0aqpRDCAOQ56XOSgY22ZVsVaU2XPHQMWN2dLymKhai0aqpBBp)k9c4siKYyiKAbg4t7HckOyQ3aBsumh2Kqxsryd6sVzZHWPHQMSLe2cGrMTKWg0iBqdgiOSfaeKTKTtsu2a74ZMEJSjuY3kBn6p1cmoYMhTYM7Jc4ZMMVmQe207uzd6keylu7iBPYwatIY2vkryQZJwGHSonIVIGibDjfXXsqevikMb9gBRhitJ(H8aaHga6zTJtdvnxpgL1qO8v)A(YOU0kcHvaCRqNVsP4XBOhTGWAhNgQAUODJhxOKVv4hJYAiu(kLGIPopAbgY60i(kcIe0LuehlbruHOyg0BSTEGmn6hsHaa8qcPqjFRWpgL1q24vkbLy8bacna0duoleaGhsifk5Bf(XOSgYgVsPnEaGqda9S2XPHQMRhJYAiBBp)k9c4AhNgQAcFApuIXhai0aqpqbft9gytII5WMdHtdvnzd6AAaOzd6sVzBZs(wjAgUGVVoHpKCKPRjvKTsGT01nuN0lGm15rlWqwNgXxrqCp)k9cOJtgHI2XPHQMWtjFRendxWh(aMwPfyCCpd0OiQOzahDnL8Ts0mCb)foPxaBXJtfnd4Ol0hsoY01KkUWj9cylE8daeAaONf6djhz6AsfxpgL1qOCm3O4BtZao6QHOl(We9tnLXOfoPxaBm1BGnjkMdBoeonu1KnOl9MnhEiLXqi1cmSLtJnj0Lue2scBbWiZwsydAKnObdeu2cacYwY2jjkBGD8ztVr2ek5BLTg9NAbgM68OfyiRtJ4RiiUNFLEb0XjJqr740qvt4dyhNCu4dyALwGXXsq0bSJto66cfFLt84hWoo5ORbppia(w84hWoo5ORbmOJ7zGgfDLPopAbgY60i(kcI75xPxaDCYiu0oonu1e(a2Xjhf(aMwPfyCSeeDa74KJU2XrVP4DCpd0OiHaa8qcPqjFRWpgL1q2O4uckXyiVkoL22E(v6fW1oonu1e(0EOGYzHaa8qcPqjFRWpgL1q2O4uAJhai0aqplHqkJHqQfywpgL1qGsmgYRItPTTNFLEbCTJtdvnHpThkOIh3JwqyjeszmesTadShTGWI2nE8g6rliSecPmgcPwGzr7gpUqjFRWpgL1qOS4uIPopAbgY60i(kcI75xPxaDCYiu0oonu1e(a2Xjhf(aMwPfyCSeeDa74KJUMs(wHfs0X9mqJIecaWdjKcL8Tc)yuwdzJItjOeJH8Q4uAB75xPxax740qvt4t7HckNfcaWdjKcL8Tc)yuwdzJItPnEaGqda9SiOlPiRhJYAiqjgd5vXP022ZVsVaU2XPHQMWN2dfuXJ3a6IGUKIS06CPg54Xfk5Bf(XOSgcLfNsm15rlWqwNgXxrqChNgQA6yjiIkefZGEJT1dKPr)nGUEAxL(XLwNl1i7Nkn0JwqyTJtdvnx0U(3ZVsVaU2XPHQMWtjFRendxWh(aMwPfy8VNFLEbCTJtdvnHpGDCYrHpGPvAbgM6nWMt4djhz6Asfzd6BCyBakBefZGEJn2YPXMhqVzZbPDv6hzlNgBIH8FGISLpYgTlBcGNTayKzdhaT89IPopAbgY60i(kcIOpKCKPRjv0XsqevikMb9gBRhitJ(HKknGUKZ)bkUEu4rYD6fq)nGUEAxL(X1JrzneNfRVIDBhx4O0hyIloT4XBaD90Uk9JRhJYAiBJsRy6SMVmQlTIqyfa3kek)A(YOU0kcHvaCRqNflt9gyt6U2zReydAKT8r2spaTYMcyZjMDCaroYwon2svXixLnfWgHI5Wg0LEZMe6skcBc1Kb2UlLTsGnOr2Ggmqqzd6KOiBrGhztVZHT7miWMEJSDaGqda9SyQZJwGHSonIVIGi5U2DSee1a66PDv6hxADUuJSFiPYbacna0ZIGUKISEmBuep(bacna0ZAhNgQAUEmkRH48vXHkE8gqxe0LuKLwNl1iZuNhTadzDAeFfbrxGwGXXsqKhTGWYlaaTanrxpMhnECpaH4xOKVv4hJYAiuElukE8g6rliS2XPHQMlAxM68OfyiRtJ4Rii6faGgSa9tHJLGOg6rliS2XPHQMlAxM68OfyiRtJ4Rii6Hpb)l1i7yjiQHE0ccRDCAOQ5I2LPopAbgY60i(kcIc1JEbaO5yjiQHE0ccRDCAOQ5I2LPopAbgY60i(kcI5CqI(za(KHGJLGOg6rliS2XPHQMlAxM68OfyiRtJ4RiiEYqaopAbg4qruhNmcfTNtrUDSeerfIIzqVX2kdb)rjrXhojKKqQb(XOSgIikXuVb2KOyoSP3iBUFb(sPGnIMkBE0ccSPFnxqLnOl9MnhcNgQA6iBa9gFOlcYgnbzdmSDaGqda9WuNhTadzDAeFfbr9R5cQxDSeeTNFLEbCPFnxqfMqXCGjbGk6QFiBOhTGWAhNgQAUODJh3dqi(fk5Bf(XOSgcLfjoLGkECi3ZVsVaU0VMlOctOyoWKaqfjUFQOFnxqDj(6aaHga6z9y2OaQ4XPYE(v6fWL(1CbvycfZbMeaktDE0cmK1Pr8vee1VMlOkUJLGO98R0lGl9R5cQWekMdmjaurI7hYg6rliS2XPHQMlA34X9aeIFHs(wHFmkRHqzrItjOIhhY98R0lGl9R5cQWekMdmjaurx9tf9R5cQRRRdaeAaON1JzJcOIhNk75xPxax6xZfuHjumhysaOm1m1BydSTD1JhLTwgLYiBPxfkTqct9gyZjMDCarSLkBI1x2GmM(Yg0LEZ22jbfBoDRxST9IIWwLkgOGnWWM4(YMMVmQehzd6sVzZHWPHQMoYg4zd6sVzlwQ6We2a6n(qxeKnOZszta8SrariB4GVmfl2IXabWg0zPSvcS5e(qKz7aI8aSve2oGOAKzJ2DXuNhTadz1QhpQiC2Xbe5yjicfeWJw7i8be5bGDb1OeNfjwF1mGJUAi6Ipmr)utzmAHt6fWMFiBOhTGWAhNgQAUODJhVHE0cclYDTVODJhVHE0cclHqkJHqQfyw0UXJJd(YuSAOqDkLYIepM(Id(YuSEugh4diYRgSfpov2ZVsVaUi1ihqynFzuHYpKurZao6c9HKJmDnPIlCsVa2Ih)aaHga6zH(qYrMUMuX1JrzneNfhkM68OfyiRw94r9vee3ZVsVa64KrOiAccluHa(oUNbAu0be5bGDb1OKvdfQtPoFnECCWxMIvdfQtPuwK4X0xCWxMI1JY4aFarE1GT4XPYE(v6fWfPg5acR5lJkt9gylgDDduWMevLytbSLHaBA(YOsyd6sVb0kBjBn0JwqGTKWM7xGVukCKn3hfW)RrMnnFzujS1OOgz2iaWGpBPGIpB6nYM7xr5tbBA(YOYuNhTadz1QhpQVIGib)pvSb7bgeM4wxqhlbr75xPxax0eewOcb89tLgqxe8)uXgShyqyIBDbHBaDP15snYm15rlWqwT6XJ6RiisW)tfBWEGbHjU1f0XdfNacR5lJkr0vhlbr75xPxax0eewOcb89tLgqxe8)uXgShyqyIBDbHBaDP15snYm1BGTTYBCyZbgJSve2gGYwQSDxY3S1O)ulW4iB0eKnjQkXMcylDDduWMtIzJnpkyZj8jJCdiBn6Vgz2CiCAOQPJSb0B8HUiiBxq0LnHheX2jDDRrMTZD(YiHPopAbgYQvpEuFfbrc(FQyd2dmimXTUGowcI2ZVsVaUOjiSqfc47pkjk(WjHKesnWpgL1qOmLwIr(HuOKVv4hJYAiuwumJh)aaHga6zrW)tfBWEGbHjU1fCfL(aFUZxgjB8CNVmsGf(8OfyYaLfrPL4XmECcGo4vtBfWSb7rbm6tg5gWfoPxaB(PIhTGWkGzd2Jcy0NmYnGlAx)n0JwqyTJtdvnx0UXJ7rliSIY)bqJnyzmIOGbHX5oNdgHJUODHIPEdS5WZHnGaBomMAhjSLkBx3Q(YgrZZfcBab2CyUAnCyJQHSHe2apBPCwdrztS(YMMVmQKftDE0cmKvRE8O(kcIc5adeGVm1osCSeeTNFLEbCrtqyHkeW3pKE0ccR7Q1Wb2lKnKSiAEU4SORB14XHKkUFb(sPa(bAQfy8tCXqawZxgvYsihyGa8LP2rIZIeRVefZGEJT1dKPrOGIPEdS5WZHnGaBomMAhjSPa2sx3afS5ckcyiSvcSvtE0AhzdmSLdfSP5lJkBqcE2YHc28ci2QrMnnFzujSbDP3S5(f4lLc2EGMAbgOylv22sSm15rlWqwT6XJ6RiikKdmqa(Yu7iXXdfNacR5lJkr0vhlbrqsf3VaFPua)an1cmXJ3a6so)hO4sRZLAKJhVb01t7Q0pU06CPgzO8VNFLEbCrtqyHkeW3pXfdbynFzujlHCGbcWxMAhjolAlm15rlWqwT6XJ6RiiINBqnYWp6(vuonhlbr75xPxax0eewOcb89FaGqda9S2XPHQMRhJYAioFLsm15rlWqwT6XJ6RiiMrE0KBhlbr75xPxax0eewOcb89dzusu8HtcjjKAGFmkRHiIs(PYtpOa4LXvdaI8czdJh3Jwqy5fQPrQgUODHIPEdSfB6TrhiTwHur2uaBPRBGc22omBbkyBRbfbmSLkBIZMMVmQeM68OfyiRw94r9veeJO1kKk64HItaH18LrLi6QJLGO98R0lGlAccluHa((jUyiaR5lJkzjKdmqa(Yu7irK4m15rlWqwT6XJ6RiigrRviv0Xsq0E(v6fWfnbHfQqaFMAM6nSb22UmkLr2a74ZMwriBPxfkTqct9gyZjROszJGhW0YNc2ed5)afjSjaE2C)c8LsbBpqtTadBLaBqJSDN7iBBjMSHd(YuW2JY4Wg4ztmK)duKnORqGn0h36r2adB6nYM7xr5tbBA(YOYuNhTadz1aQO98R0lGoozekICPCHpuCciSC(pqrh3ZankY9lWxkfWpqtTaJFiBaDjN)duC9yuwdHYhai0aqpl58FGIRg9NAbM4X3ZVsVaUEughysQ0FQydkM6nWMtwrLYgbpGPLpfS5G0Uk9Je2eapBUFb(sPGThOPwGHTsGnOr2UZDKTTet2WbFzky7rzCyd8SjDx7Sve2ODzdmSjES(YuNhTadz1aQVIG4E(v6fqhNmcfrUuUWhkobe(PDv6hDCpd0Oi3VaFPua)an1cm(HSHE0cclYDTVOD9tCXqawZxgvYsihyGa8LP2rIZIhp(E(v6fW1JY4atsL(tfBqXuVb2CYkQu2CqAxL(rcBLaBoeonu10xP7AhIoWKO4ZwmsijHudBfHnAx2YPXg0iB35oYM4(YgbpGPrylGckBGHn9gzZbPDv6hzB7aXYuNhTadz1aQVIG4E(v6fqhNmcfrUuUWpTRs)OJ7zGgf1qpAbH1oonu1Cr76hYg6rliSi31(I2nE8OKO4dNessi1a)yuwdXzkbL)gqxpTRs)46XOSgIZIZuVb2KCXtLb2ed5)afzlNgBoiTRs)iBeuPDzZ9lWZMcyZj8HKJmDnPISDsIYuNhTadz1aQVIGOC(pqrhlbrAgWrxOpKCKPRjvCHt6fWMFQG(qYrMUMuX2so)hOO)gqxY5)afxUr0bTCdf(uw0v)hai0aqpl0hsoY01KkUEmkRHqzX9tCXqawZxgvYsihyGa8LP2rIOR()SAW4oo6kBnYQgNDa(BaDjN)duC9yuwdzBuAftkR5lJ6sRiewbWTczQZJwGHSAa1xrq8PDv6hDSeePzahDH(qYrMUMuXfoPxaB(HefeWJw7i8be5bGDb1OeNfDCHJsFGjU408FaGqda9SqFi5itxtQ46XOSgcLV6Vb01t7Q0pUEmkRHSnkTIjL18LrDPvecRa4wHqXuVb2ed5)afzJ29cIUoYwgia20VqcBkGnAcYwPSLe2s2iU4PYaBY4GFQGNnbWZMEJSfsIYMt3A28qbWJSLSjutrUXNPopAbgYQbuFfbrxaia)ibq)h0rbWdpOpQORm15rlWqwnG6RiikN)du0Xsq0JcpsUtVa6)aI8aWUGAuYQHc1PuNfD1pKUr0bTCdf(uw014XFmkRHqzrADUaRve6N4IHaSMVmQKLqoWab4ltTJeNfTfO8djvqFi5itxtQylE8hJYAiuwKwNlWAfHBtC)exmeG18LrLSeYbgiaFzQDK4SOTaLFi18LrDPvecRa4wHB8XOSgcuolw)rjrXhojKKqQb(XOSgIikXuNhTadz1aQVIGOlaeGFKaO)d6Oa4Hh0hv0vM68OfyiRgq9veeLZ)bk64HItaH18LrLi6QJLGiQSNFLEbCrUuUWhkobewo)hOO)hfEKCNEb0)be5bGDb1OKvdfQtPol6QFiDJOdA5gk8PSORXJ)yuwdHYI06CbwRi0pXfdbynFzujlHCGbcWxMAhjolAlq5hsQG(qYrMUMuXw84pgL1qOSiToxG1kc3M4(jUyiaR5lJkzjKdmqa(Yu7iXzrBbk)qQ5lJ6sRiewbWTc34JrzneOC(Q4(JsIIpCsijHud8JrzneruIPEdS50VIiGHTyXixKOSbg2IOdA5gq208LrLWwQSjwFzZPBnBqFJdBp9m1iZgGwzRg2eFJXKWwsylagz2scBqJSDN7iB4aOLVz7rzCylNgB5Jdeu2iOQ1iZgTlBcGNnhcNgQAYuNhTadz1aQVIG45RicyGvmYfjQJhkobewZxgvIORowcIiUyiaR5lJkXzrI7hfeWJw7i8be5bGDb1OeNfjw)4GVmfRhLXb(aI8QbBoloL8djvoaqObGEw740qvZ1JzJI4XBaD90Uk9JlToxQrgk)pgL1qOS4(ULTbjXfdbynFzujolsSqXuVb2CyGOlB0US5G0Uk9JSLkBI1x2adBziWMMVmQe2Ge6BCylu71iZwamYSHdGw(MTCASnaLnYKUKBGcftDE0cmKvdO(kcIpTRs)OJLGiQSNFLEbCrUuUWpTRs)OFuqapATJWhqKha2fuJsCwKy9)OWJK70lG(H0nIoOLBOWNYIUgp(JrzneklsRZfyTIq)exmeG18LrLSeYbgiaFzQDK4SOTaLFiPc6djhz6AsfBXJ)yuwdHYI06CbwRiCBI7N4IHaSMVmQKLqoWab4ltTJeNfTfO8R5lJ6sRiewbWTc34JrzneNHuS(c5tpOa4LXvlj31idtoa6P9yyBXekFH8Phua8Y4QbarEHSHBlMq5lK75xPxaxpkJdmjv6pvSTnhauqXuNhTadz1aQVIG4t7Q0p64HItaH18LrLi6QJLGiQSNFLEbCrUuUWhkobe(PDv6h9tL98R0lGlYLYf(PDv6h9Jcc4rRDe(aI8aWUGAuIZIeR)hfEKCNEb0pKUr0bTCdf(uw014XFmkRHqzrADUaRve6N4IHaSMVmQKLqoWab4ltTJeNfTfO8djvqFi5itxtQylE8hJYAiuwKwNlWAfHBtC)exmeG18LrLSeYbgiaFzQDK4SOTaLFnFzuxAfHWkaUv4gFmkRH4mKI1xiF6bfaVmUAj5UgzyYbqpThdBlMq5lKp9GcGxgxnaiYlKnCBXekFHCp)k9c46rzCGjPs)PITT5aGckM6nWMdpdbV8CHTye4eS50VIiGHTyXixKOSbDP3SP3iBKmczlaKRdBjHT0dSJoYMhTYwjpGVgz20BKnCWxMc2oGPvAbgcBLaBqJSLpoqqzJMuJmBoiTRs)itDE0cmKvdO(kcINVIiGbwXixKOowcIiUyiaR5lJkXzrI7hfeWJw7i8be5bGDb1OeNfjw)pgL1qOS4(ULTbjXfdbynFzujolsSqXuVb2C6xreWWwSyKlsu2adBsXYwjWwnS5MtdJQdB50yBW8duWwu6dB4GVmfSLtJTsGnNy2XbeXg0GbckBnaBrGhzRLrPmYwJgztbSflvHOdmgzQZJwGHSAa1xrq88vebmWkg5Ie1XsqeXfdbynFzujIU6Nkp9GcGxgxTKCxJmm5aON2Jb)rjrXhojKKqQb(XOSgIik5hfeWJw7i8be5bGDb1OeNfb5Xfok9bM4ItBJxHY)JcpsUtVa6NkOpKCKPRjvS5hsQ0qpAbHf5U2x0U(Heh8LPy1qH6ukLfjEm9fh8LPy9OmoWhqKxnydkO8R5lJ6sRiewbWTc34JrzneNfltnt9g2aBskMb9gBSfJhTadHPEdSTzjFt0mCbF2adBBjwXKnN(vebmSflg5IeLPopAbgYIOyg0BSj68vebmWkg5Ie1XsqKMbC01uY3krZWf8x4KEbS5N4IHaSMVmQeNfTf)hqKha2fuJsCwKy9R5lJ6sRiewbWTc34JrzneNDam1BGTnl5BIMHl4Zgyy7ASIjBst6sUbkBoiTRs)itDE0cmKfrXmO3yZxrq8PDv6hDSeePzahDnL8Ts0mCb)foPxaB(pGipaSlOgL4SiX6xZxg1LwriScGBfUXhJYAio7ayQ3aBs0Ek(c0YOyYwm66gOGnWZMdIcpsUzd6sVzZJwqaBSjgY)bksyQZJwGHSikMb9gB(kcIUaqa(rcG(pOJcGhEqFurxzQZJwGHSikMb9gB(kcIY5)afD8qXjGWA(YOseD1XsqKMbC0fH2tXxGwgx4KEbS5hYhJYAiu(Q4XJ7grh0Ynu4tzrxHYVMVmQlTIqyfa3kCJpgL1qCwCM6nWMeTNIVaTmYMVS5e(qKzdmSDnwXKnhefEKCZMyi)hOiBPYMEJSHtJnGaBefZGEZMcytgv2IsFyRr)PwGHnpua8iBoHpKCKPRjvKPopAbgYIOyg0BS5Rii6cab4hja6)GokaE4b9rfDLPopAbgYIOyg0BS5RiikN)du0XsqKMbC0fH2tXxGwgx4KEbS5xZao6c9HKJmDnPIlCsVa28NhT2ryCWOcjIU63JwqyrO9u8fOLX1JrznekFDTfM68OfyilIIzqVXMVIGyeTwHurhlbrAgWrxeApfFbAzCHt6fWM)diYda7cQrjuw0wyQzQ3WgyZHYPi3m1BGnhEnf5MnOl9MTO0h2C6wZMa4zBZs(wjAgUGVJSrpbKqyJMuJmBBhM6DGc2KUZgaActDE0cmK1Eof5w0E(v6fqhNmcfnL8Ts0mCbF4Jl8bmTslW44EgOrrqsLNEqbWlJRgM6DGcyYD2aqt8Jcc4rRDe(aI8aWUGAuIZIoUWrPpWexCAqfpoKp9GcGxgxnm17afWK7SbGM4)aI8aWUGAucLfhkM6nWMdLtrUzd6sVzZj8HiZMVSTzjFRendxWxmzZbM(ur0rS50TMTCAS5e(qKz7XSrbBcGNTb9rztm40TJPopAbgYApNIC7RiiUNtrUDSeePzahDH(qYrMUMuXfoPxaB(1mGJUMs(wjAgUG)cN0lGn)75xPxaxtjFRendxWh(4cFatR0cm(paqObGEwOpKCKPRjvC9yuwdHYxzQ3aBouof5MnOl9MTnl5BLOz4c(S5lBBcyZj8HilMS5atFQi6i2C6wZwon2CiCAOQjB0Um15rlWqw75uKBFfbX9CkYTJLGind4ORPKVvIMHl4VWj9cyZpv0mGJUqFi5itxtQ4cN0lGn)75xPxaxtjFRendxWh(4cFatR0cm(BOhTGWAhNgQAUODzQZJwGHS2ZPi3(kcIUaqa(rcG(pOJcGhEqFurxDe9r)eoJa0JksSXKPopAbgYApNIC7RiiUNtrUDSeePzahDrO9u8fOLXfoPxaB(paqObGEwY5)afx0U(HSb0LC(pqX1JcpsUtVagpEd9Ofew740qvZfTR)gqxY5)afxUr0bTCdf(uw0vO8FarEayxqnkz1qH6uQZIGK4IHaSMVmQKLqoWab4ltTJeN3kqSq5)ZQbJ74ORS1iRAC(Q4m1BGnhkNICZg0LEZMdmjk(SfJessQrmzZbPDv6h9vmK)duKTbOSvdBpk8i5MTphz0r2A0FnYS5q40qvtFLUR9fBsumh2GU0B2KqxsrytOMmW2DPSvcS5ciKYlGlM68OfyiR9CkYTVIG4Eof52XsqeKAgWrxrjrXhojKKqQzHt6fWw84p9GcGxgxr5FbgiaR3iCusu8HtcjjKAGYpvAaD90Uk9JRhfEKCNEb0FdOl58FGIRhJYAioVf)n0JwqyTJtdvnx0U(HSHE0cclYDTVODJhVHE0ccRDCAOQ56XOSgcLfB84nGUiOlPilToxQrgk)nGUiOlPiRhJYAiuElDjIlE6BkEm3QDTR9oa]] )


end