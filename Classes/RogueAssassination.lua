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


    spec:RegisterPack( "Assassination", 20210823, [[di11AcqicWJOQsxcjsAtuv(KkjJcK6uiHvPuQELOIzrf6wkfSlL8lvsnmKKogiSmc0Zuk00OcCnLIABirQVHejghse15uksTociVJaQKMhsI7rq7JQQ(hbujoOsrSqKOEivvmrLsPlsfP2ive8rKimscOsDsKiYkrs9scOQzsfj3Kak7uPKFsfHyOkLILsfupLitvuPRsavSvQG8vQiuJLkI2Ru9xqnykhwyXuLhRIjlLldTzc9zIA0QuNwYQPIq61QeZwKBlk7wXVv1WPshxPiXYbEoIPt66i12vQ(oiz8urDEq06vksA(IQ2pQ7q0ZTl1cf7BjivfecQsjl4gxuDt7ahSzkLUKcPl2LCJZLqg7stKHDPnHqccPMqRF6sUbKPpA9C7sKNgCWU0TQUeb66RLl9M2BD(SRjvgDk06Ndie1Rjv256UKhDLukPP71LAHI9TeKQccbvPKfCJlQUPDGd2mLUlf069d6ssvMF6s3vRHt3Rl1qYPlTjesqi1eA9dBo8ltJm1BcTmnrztWn6iBcsvbHGPMP2p3XiJebIPEdSTjUUjiz7kIcQJEfBIPqMn9zJ8ziBBY24uSj(Gle20NnsSJS5c(dsi1iZMwz4IPEdSTT)CLYMdftrUzJEsiHWMuQoiBX0yBBRdYguvkXwkikBPFKraB6DmSjWcIIa22ecjiKAwm1BGnhgtHZS5esHmMsHw)W21S5q40qvd2iqoh2GUezZHWPHQgSve20xwoHn2Err2EaB)WwWw6hz28Z2sXIPEdSjWIliBoHesUpGquzRgfbaAxLTAy78zEHYwjYguiBorPjkBTQXwPSj(a22)uOvcHjFAhhDXuVb2e4qq2KOSeBzpaztF2i0zz)WMapUxZve2CI8BQyQgz2kr2G8Pz7o2r20BKnYtN8QPT6sPIOKEUDjIIrsVXwp3(wq0ZTlHt4LWwNYDP4O1pDPdOYi)aRyMls0Uudjhq5Q1pDPTk5BIgPliGTFyBJ5kqS5hqLr(HTCXmxKODPdOueurxsJeo6Ak5BLOr6ccw4eEjSXMp2iUykbRbqgvcB(lKTnYMp2oFM3d7(1Oe28xiBoGnFSPbqg1LwziS(WTczBdSbWSOgcB(ZgLUR9TeSNBxcNWlHToL7sXrRF6saAxLgGDPgsoGYvRF6sBvY3ensxqaB)Wge5kqSjnHl5(v2CyAxLgGDPdOueurxsJeo6Ak5BLOr6ccw4eEjSXMp2oFM3d7(1Oe28xiBoGnFSPbqg1LwziS(WTczBdSbWSOgcB(ZgLUR9T2yp3UeoHxcBDk3LIJw)0LC)pbdqYtdoyxQHKdOC16NUKeTNIarAzuGyBtCDtqY2dyZHrrasUzdQsVzZJwueBSrjca4vK0LeFa8GoR9TGOR9TCqp3UeoHxcBDk3LIJw)0LKda4vSlDaLIGk6sAKWrxeApfbI0Y4cNWlHn28Xg0SbWSOgcBuHnieKT85zZnJoPLBQqaBuriBqWgfS5JnnaYOU0kdH1hUviBBGnaMf1qyZF2eSlDG8KqynaYOs6Bbrx7BT5EUDjCcVe26uUlfhT(Pl5(FcgGKNgCWUudjhq5Q1pDjjApfbI0YiB5WMt7mrMTFydICfi2CyueGKB2Oeba8kYwOSP3iB40y7fzJOyK0B20NnzuzllCMTgni06h28qXhGS50otIrMUMqXUK4dGh0zTVfeDTVfLUNBxcNWlHToL7shqPiOIUKgjC0fH2trGiTmUWj8syJnFSPrchDHotIrMUMqXfoHxcBS5JT4O1ocJdMviHnHSbbB(yZJwuCrO9ueislJlaMf1qyJkSbXAJDP4O1pDj5aaEf7AFlkLEUDjCcVe26uUlDaLIGk6sAKWrxeApfbI0Y4cNWlHn28X25Z8Ey3VgLWgveY2g7sXrRF6sz0ALcf7Ax7s7XuK7EU9TGONBxcNWlHToL7sVBxIGAxkoA9txApav4LWU0EKOXUe0Sja2a0dk(azC1WqVtqctUJ2dfzHt4LWgB(ydffXJw7i85Z8Ey3VgLWM)cz74cNfodtCXPXgfSLppBqZgGEqXhiJRgg6DcsyYD0EOilCcVe2yZhBNpZ7HD)AucBuHnbzJIUudjhq5Q1pDjNqnf5MnOk9MTSWz28Z2WM4dyBRs(wjAKUGahzJEsiHWgnPgz22wm07eKSjDhThksxApaWtKHDPPKVvIgPlia(4cF(PvA9tx7Bjyp3UeoHxcBDk3LIJw)0L2JPi3DPgsoGYvRF6soumf5MnOk9MnN2zImB5W2wL8Ts0iDbbceBcSW5kJoJn)SnSftJnN2zImBamAqYM4dyBqNv2Oe(zB7shqPiOIUKgjC0f6mjgz6Acfx4eEjSXMp20iHJUMs(wjAKUGGfoHxcBS5JT9auHxcxtjFRensxqa8Xf(8tR06h28X25)u7HAwOZKyKPRjuCbWSOgcBuHni6AFRn2ZTlHt4LWwNYDP4O1pDP9ykYDxQHKdOC16NUKdftrUzdQsVzBRs(wjAKUGa2YHTTE2CANjYceBcSW5kJoJn)SnSftJnhcNgQAWgTBx6akfbv0L0iHJUMs(wjAKUGGfoHxcBS5JnbWMgjC0f6mjgz6Acfx4eEjSXMp22dqfEjCnL8Ts0iDbbWhx4ZpTsRFyZhBn0JwuCTJtdvnw0UDTVLd652LWj8syRt5UuC06NUK7)jyasEAWb7sOZkiGJSNE0UKd2Cxs8bWd6S23cIU23AZ9C7s4eEjS1PCx6akfbv0L0iHJUi0EkcePLXfoHxcBS5JTZ)P2d1SKda4vCr7YMp2GMT2Rl5aaEfxaueGK7WlHSLppBn0JwuCTJtdvnw0US5JT2Rl5aaEfxUz0jTCtfcyJkczdc2OGnFSD(mVh29RrjRgkwNszZFHSbnBexmLG1aiJkzjgd8lcFzQDKWM)cCHnhWgfS5JnqunyChhDfTgzvdB(Zgec2LIJw)0L2JPi3DTVfLUNBxcNWlHToL7sXrRF6s7XuK7Uudjhq5Q1pDjhkMICZguLEZMalikcyBtiKGuJaXMdt7Q0amhkraaVISnVYwnSbqrasUzdeJm6iBnAqnYS5q40qvJCKUR9fBsqoh2GQ0B2KqxsrytSMiX2DPSvIS5(es5LWvx6akfbv0LGMnns4ORSGOiaoiKGqQzHt4LWgB5ZZgGEqXhiJRSaCb(fH1BeolikcGdcjiKAw4eEjSXgfS5JnbWw71fG2vPb4cGIaKChEjKnFS1EDjhaWR4cGzrne28NTnYMp2AOhTO4AhNgQASODzZhBqZwd9OffxK7AFr7Yw(8S1qpArX1oonu1ybWSOgcBuHnhWw(8S1EDrqxsrwADUuJmBuWMp2AVUiOlPilaMf1qyJkSTXU21Uudfd6K2ZTVfe9C7sXrRF6sxQZLUeoHxcBDk31(wc2ZTlHt4LWwNYDPgsoGYvRF6somsums6nBLiBUpHuEjKnONNTD60GGWlHSHdMviHTAy78zEHsrxkoA9txIOyK07U23AJ9C7s4eEjS1PCx6D7seu7sXrRF6s7bOcVe2L2Jen2LiUykbRbqgvYsmg4xe(Yu7iHnQWMGDP9aaprg2Li1iNqynaYO21(woONBxcNWlHToL7sVBxIGAxkoA9txApav4LWU0EKOXUeoiqgYfaLXb(8zE1Gn28NTnU5Uudjhq5Q1pDj)8zE1Gn2C6bbYqYMdJY4W2GydBSPpBKqPbHIDP9aaprg2LaOmoWKqPbHITU23AZ9C7s4eEjS1PCx6akfbv0Likgj9gBlWltJDjIcQJ23cIUuC06NU0jsj44O1pWPIODPuru4jYWUerXiP3yRR9TO09C7s4eEjS1PCxkoA9tx6ePeCC06h4ur0UuQik8ezyx60iDTVfLsp3UeoHxcBDk3LIJw)0LiP6GWX0GB1b7snKCaLRw)0L2gALnPzBzJ2LTAkTIucs2eFaB(HwztF20BKn)Che0r2aOiaj3SbvP3S50ZooFgBLiBHYw6HITgni06NU0bukcQOlja28OffxKuDq4yAWT6GlAx28X25Z8Ey3VgLWM)czdIU23IsUNBxcNWlHToL7shqPiOIUKhTO4IKQdchtdUvhCr7YMp28OffxKuDq4yAWT6GlaMf1qyJkSTz28X25Z8Ey3VgLWM)czZbDP4O1pDjC2X5Z6AFRnDp3UeoHxcBDk3LIJw)0LorkbhhT(boveTlLkIcprg2LAV21(wqq1EUDjCcVe26uUlfhT(PlDIucooA9dCQiAxkvefEImSl1kaE0U23cci652LWj8syRt5U0bukcQOlHdcKHC1qX6ukB(lKni2mB5WgoiqgYfaLXb(8zE1GTUuC06NUuaoXGW6da4ODTVfec2ZTlfhT(PlfGtmiSlDIGDjCcVe26uUR9TGyJ9C7sXrRF6sPs(wjWorPBYz4ODjCcVe26uUR9TGWb9C7sXrRF6sEHm8lcRG6CH0LWj8syRt5U21UKlapFMxO9C7Bbrp3UuC06NUu46MGe29lYpDjCcVe26uUR9TeSNBxkoA9txY7vnHnyXuaj2GQgzy9DUMUeoHxcBDk31(wBSNBxcNWlHToL7sXrRF6szb4c2GfFaCdd9UlDaLIGk6sGOAW4oo6kAnYQg28Nni2CxYfGNpZluycE(Pr6sBUR9TCqp3UeoHxcBDk3LoGsrqfDjYtN8QPTCPjkDcHraTRw)SWj8syJT85zJ80jVAAR9pfALqyYN2Xrx4eEjS1LIJw)0Leti5(acrTR9T2Cp3UeoHxcBDk3LE3Ueb1UuC06NU0EaQWlHDP9irJDjiyBdSbnBa6bfFGmUA0KlqfPliGa7g65EHt4LWgBBNnQUCWMzJIU0EaGNid7s740qvd4td01(wu6EUDjCcVe26uUl9UDjcQDP4O1pDP9auHxc7s7rIg7sqW2gydA2a0dk(azC9EyRW5GlCcVe2yB7Sr1LdCaBu0LAi5akxT(PlL7nYwSJGqgzZpBRdZwryJQlbfKnpALTgnYM(SP3iBo8wuc2MqPbiBViB(zBytghhztqNztVlcB7rIgzRiS9UALfj2eFaBeiNtnYSLE560L2da8ezyxsmfYykfA9d8Pb6AFlkLEUDjCcVe26uUl9UDjcQDP4O1pDP9auHxc7s7baEImSlPGAUGkmbY5atsV2LoGsrqfDjfuZfuxkeR7Gat0qxXajCZLWMp2GMnbWMcQ5cQlvW1DqGjAORyGeU5sylFE2uqnxqDPqSo)NApuZQrdcT(Hn)fYMcQ5cQlvW15)u7HAwnAqO1pSrbB5ZZMcQ5cQlfIvrw1qoaAn8si8McDmkDgCd3RdYw(8SbnBkOMlOUuiwfzrUJ2dLmiiUW6RygB(y7874eJU2XrVHeWgfDPgsoGYvRF6sBlQiiRgKnOURZnBqxISfdKuWgrdLnpArr2uqnxqLnOq2GkgLn9zlufZCv20NncKZHnOk9MnhcNgQAS6s7rIg7sq01(wuY9C7s4eEjS1PCx6D7seu7sXrRF6s7bOcVe2L2Jen2LeSlDaLIGk6skOMlOUubx3bbMOHUIbs4MlHnFSbnBcGnfuZfuxkeR7Gat0qxXajCZLWw(8SPGAUG6sfCD(p1EOMvJgeA9dB(ZMcQ5cQlfI15)u7HAwnAqO1pSrbB5ZZMcQ5cQlvWvrw1qoaAn8si8McDmkDgCd3RdYw(8SbnBkOMlOUubxfzrUJ2dLmiiUW6RygB(y7874eJU2XrVHeWgfDP9aaprg2LuqnxqfMa5CGjPx7AFRnDp3UeoHxcBDk3LIJw)0LiP6GWX0GB1b7shqPiOIUeafbi5o8syxYfGNpZluycE(Pr6sq01(wqq1EUDP4O1pDjIIrsV7s4eEjS1PCx7AxQva8O9C7Bbrp3UeoHxcBDk3LIJw)0LWzhNpRl1qYbuUA9txYPNDC(m2cLnhKdBqV5CydQsVzBBLOGn)Snl2OKYYWwfkMGKTFytWCytdGmQehzdQsVzZHWPHQgoY2dydQsVzlxk7iBVEJaOkcYgurPSj(a2iFgYgoiqgYfBBsI8SbvukBLiBoTZez2oFM3Zwry78z1iZgT7QlDaLIGk6sOOiE0AhHpFM3d7(1Oe28xiBoGTCytJeo6QHOlcGjki0qgZw4eEjSXMp2GMTg6rlkU2XPHQglAx2YNNTg6rlkUi31(I2LT85zRHE0IIlXuiJPuO1plAx2YNNnCqGmKRgkwNszJkcztWnZwoSHdcKHCbqzCGpFMxnyJT85ztaSThGk8s4IuJCcH1aiJkBuWMp2GMnbWMgjC0f6mjgz6Acfx4eEjSXw(8SD(p1EOMf6mjgz6AcfxamlQHWM)SjiBu01(wc2ZTlHt4LWwNYDP3TlrqTlfhT(PlThGk8syxAps0yx68zEpS7xJswnuSoLYM)SbbB5ZZgoiqgYvdfRtPSrfHSj4Mzlh2WbbYqUaOmoWNpZRgSXw(8Sja22dqfEjCrQroHWAaKrTlTha4jYWUenbHfRucbDTV1g752LWj8syRt5UuC06NUebbGqXgS3pimXTUGDPgsoGYvRF6sBIRBcs2KOSeB6ZwKsSPbqgvcBqv69tRSfS1qpArr2ccBUG6bLcPJS5cqreaQrMnnaYOsyRbznYSr(FqaBHOIa20BKnxqLfaiztdGmQDPdOueurxApav4LWfnbHfRucbS5JnbWw71fbbGqXgS3pimXTUGWTxxADUuJCx7B5GEUDjCcVe26uUlfhT(PlrqaiuSb79dctCRlyx6akfbv0L2dqfEjCrtqyXkLqaB(ytaS1EDrqaiuSb79dctCRliC71LwNl1i3LoqEsiSgazuj9TGOR9T2Cp3UeoHxcBDk3LIJw)0Liiaek2G9(bHjU1fSl1qYbuUA9txYj(gh2eyBcBfHT5v2cLT7s(MTgni06hhzJMGSjrzj20NTW1nbjBofgn28GKnN25iZnHS1Ob1iZMdHtdvnCKTxVraufbz7cIUSjc(m2oHRBnYSDUdGms6shqPiOIU0EaQWlHlAcclwPecyZhBzbrraCqibHudmaZIAiSrf2O6IsMnFSbnBIL8TcdWSOgcBuriBBMT85z78FQ9qnlccaHInyVFqyIBDbxzHZWN7aiJe22aBN7aiJeyrqC06NiXgveYgvxcUz2YNNnYtN8QPTsy0G9GegDoYCt4cNWlHn28XMayZJwuCLWOb7bjm6CK5MWfTlB(yRHE0IIRDCAOQXI2LT85zZJwuCLfaWdf2GLXmI(dcJZDmhmdhDr7YgfDTVfLUNBxcNWlHToL7sXrRF6seeacfBWE)GWe36c2Ls1GWNwxcIn3LoGsrqfDjYtN8QPTUG71qG)Ftft1iVWj8syJnFS5rlkUUG71qG)Ftft1iVAputxQHKdOC16NUKahcYMeLLytF2i0zz)WMapUxZve2CI8BQyQgz2kr2G8Pz7o2r20BKnYtN8QPT6AFlkLEUDjCcVe26uUlfhT(Pljgd8lcFzQDK0LAi5akxT(Pl5eIHTxKnb(P2rcBHYgeB6CyJOX5cHTxKnbURwdh2OCkAiHThWwih1qu2CqoSPbqgvYQlDaLIGk6s7bOcVeUOjiSyLsiGnFSbnBE0IIR7Q1Wb2lfnKSiACUWM)czdInnB5ZZg0Sja2Cb1dkfsyWRHw)WMp2iUykbRbqgvYsmg4xe(Yu7iHn)fYMdylh2ikgj9gBlWltJSrbBu01(wuY9C7s4eEjS1PCxkoA9txsmg4xe(Yu7iPlDG8KqynaYOs6Bbrx6akfbv0LGMnbWMlOEqPqcdEn06h2YNNT2Rl5aaEfxADUuJmB5ZZw71fG2vPb4sRZLAKzJc28X2EaQWlHlAcclwPecyZhBexmLG1aiJkzjgd8lcFzQDKWM)czBJDPgsoGYvRF6soHyy7fztGFQDKWM(SfUUjizZ9lYpe2kr2QjoATJS9dBXajBAaKrLnOFaBXajBEjeB1iZMgazujSbvP3S5cQhukKSbEn06hkylu22yUDTV1MUNBxcNWlHToL7shqPiOIU0EaQWlHlAcclwPecyZhBN)tThQzTJtdvnwamlQHWM)Sbbv7sXrRF6s45(RrggGUGklMwx7Bbbv752LWj8syRt5U0bukcQOlThGk8s4IMGWIvkHa28Xg0SLfefbWbHeesnWamlQHWMq2OkB(ytaSbOhu8bY4Q9FMxkA4cNWlHn2YNNnpArXLxQMgPA4I2Lnk6sXrRF6srMhn5UR9TGaIEUDjCcVe26uUlfhT(PlLrRvkuSlDG8KqynaYOs6Bbrx6akfbv0L2dqfEjCrtqyXkLqaB(yJ4IPeSgazujlXyGFr4ltTJe2eYMGDPgsoGYvRF6s5gEBqGrRvkuKn9zlCDtqY22IrlbjBBZxKFylu2eKnnaYOs6AFlieSNBxcNWlHToL7shqPiOIU0EaQWlHlAcclwPec6sXrRF6sz0ALcf7Ax7sNgPNBFli652LWj8syRt5UuC06NUuwaUGnyXha3WqV7sPAq4tRlbXAZDPdKNecRbqgvsFli6shqPiOIUeiQgmUJJUIwJSODzZhBqZMgazuxALHW6d3kKnQW25Z8Ey3VgLSAOyDkLTTZgeRnZw(8SD(mVh29RrjRgkwNszZFHSDCHZcNHjU40yJIUudjhq5Q1pDjkjr2IwJWwaq2ODDKnYuUiB6nY2piBqv6nBPhkKOSLBUB7InboeKnOUXHTgK1iZMyqueWMEhdB(zByRHI1Pu2EaBqv69tRSfdKS5NTz11(wc2ZTlHt4LWwNYDP4O1pDPSaCbBWIpaUHHE3LAi5akxT(PlrjjY28SfTgHnOQuITwHSbvP31WMEJSnOZkBBKQehzJMGSjWe3w2(HnVNqydQsVFALTyGKn)SnRU0bukcQOlbIQbJ74ORO1iRAyZF22ivzBdSbIQbJ74ORO1iRgni06h28X25Z8Ey3VgLSAOyDkLn)fY2XfolCgM4ItRR9T2yp3UeoHxcBDk3LE3Ueb1UuC06NU0EaQWlHDP9irJDjbWMgjC01uY3krJ0feSWj8syJT85ztaSPrchDHotIrMUMqXfoHxcBSLppBN)tThQzHotIrMUMqXfaZIAiSrf22mBBGnbzB7SPrchD1q0fbWefeAiJzlCcVe26snKCaLRw)0LKGCoS5q40qvd2GQM2dfBqv6nBBvY3krJ0feKJt7mjgz6AcfzRezlCDt1j8syxApaWtKHDPDCAOQb8uY3krJ0feaF(PvA9tx7B5GEUDjCcVe26uUl9UDjcQDP4O1pDP9auHxc7s7rIg7scGnns4ORSGOiaoiKGqQzHt4LWgB5ZZw71LCaaVIlToxQrMT85z7874eJU2XrVHeWMp2oFM3d7(1OKvdfRtPSjKnQ2LAi5akxT(Pl5ehLY2pS5q40qvd2eFaBuIaaEfzdQsVztGTjoYg9KqcHnOq2caYwOSLfoZMF2g2eFaBoHuiJPuO1pDP9aaprg2L2XPHQgWzb85NwP1pDTV1M752LWj8syRt5U072LiO2LIJw)0L2dqfEjSlTha4jYWU0oonu1a(874eJcF(PvA9tx6akfbv0Lo)ooXORlqcQyylFE2o)ooXORbpGp9GgB5ZZ253XjgDn)GDPgsoGYvRF6ssqoh2CiCAOQbBqv6nBoHuiJPuO1pSftJnj0Lue2ccBPFKzliSbfYgu)CLYw6jiBbBNGOS97iGn9gztSKVv2A0GqRF6s7rIg7sq01(wu6EUDjCcVe26uUl9UDjcQDP4O1pDP9auHxc7s7rIg7sIP)bSbnBqZMyjFRWamlQHW2gytqQYgfSDnBqZgecsv22oB7bOcVeU2XPHQgWNgGnkyJc28NnX0)a2GMnOztSKVvyaMf1qyBdSjivzBdSD(p1EOMLykKXuk06NfaZIAiSrbBxZg0SbHGuLTTZ2EaQWlHRDCAOQb8PbyJc2OGT85zZJwuCjMczmLcT(b2JwuCr7Yw(8S1qpArXLykKXuk06NfTlB5ZZM3tiS5JnXs(wHbywudHnQWMGuTlDaLIGk6sNFhNy01oo6nKGU0EaGNid7s740qvd4ZVJtmk85NwP1pDTVfLsp3UeoHxcBDk3LE3Ueb1UuC06NU0EaQWlHDP9irJDjX0)a2GMnOztSKVvyaMf1qyBdSjivzJc2UMnOzdcbPkBBNT9auHxcx740qvd4tdWgfSrbB(ZMy6FaBqZg0SjwY3kmaZIAiSTb2eKQSTb2o)NApuZIGUKISaywudHnky7A2GMnieKQSTD22dqfEjCTJtdvnGpnaBuWgfSLppBTxxe0LuKLwNl1iZw(8S59ecB(ytSKVvyaMf1qyJkSjiv7shqPiOIU053XjgDnL8TclgyxApaWtKHDPDCAOQb853Xjgf(8tR06NU23IsUNBxcNWlHToL7snKCaLRw)0LCcjKCFaHOYM4dyBBOjkDczZPb0UA9dBLiBZRSrums6n2y7bSvdBbBN)tThQHTdKNe2LoGsrqfDjOzJ80jVAAlxAIsNqyeq7Q1plCcVe2ylFE2ipDYRM2A)tHwjeM8PDC0foHxcBSrbB(ytaSrums6n2wrkXMp2eaBn0JwuCTJtdvnw0US5JTSGOiaoiKGqQbgGzrne2eYgvzZhBqZgoiqgYLwziS(WzHZWNpZRgSXM)SjiB5ZZMayRHE0IIlYDTVODzJIUunkca0UkCj2LipDYRM2A)tHwjeM8PDC0Uunkca0UkCLLHTkuSlbrxkoA9txsmHK7die1Uunkca0UkSC69IuxcIU23At3ZTlHt4LWwNYDP4O1pDjXuiJPuO1pDPgsoGYvRF6ssqoh2CcPqgtPqRFydQsVzZHWPHQgSfe2s)iZwqydkKnO(5kLT0tq2c2obrz73raB6nYMyjFRS1ObHw)Wg0pGTsKnhcNgQAWguvkX25Zq28IZf2c5OMRlcB6llNWgBVOifRU0bukcQOlja2ikgj9gBlWltJS5JnOz78FQ9qnRDCAOQXcGzrne2OcBBKnFSThGk8s4AhNgQAaNfWNFALw)WMp2qrr8O1ocF(mVh29RrjS5Vq2CaB(ytdGmQlTYqy9HBfYM)SbbvzlFE2AOhTO4AhNgQASODzlFE28EcHnFSjwY3kmaZIAiSrf2e0bSrrx7Bbbv752LWj8syRt5U0bukcQOlja2ikgj9gBlWltJS5JnuuepATJWNpZ7HD)AucB(lKnhWMp2GMnX0)a2GMnOztSKVvyaMf1qyBdSjOdyJc2UMnOzloA9d85)u7HAyB7SThGk8s4smfYykfA9d8PbyJc2OGn)ztm9pGnOzdA2el5BfgGzrne22aBc6a22aBN)tThQzTJtdvnwamlQHW22zBpav4LW1oonu1a(0aSrbBxZg0SfhT(b(8FQ9qnSTD22dqfEjCjMczmLcT(b(0aSrbBuWgfDP4O1pDjXuiJPuO1pDTVfeq0ZTlHt4LWwNYDP4O1pDjc6sksxQHKdOC16NUKeKZHnj0Lue2GQ0B2CiCAOQbBbHT0pYSfe2GczdQFUszl9eKTGTtqu2(DeWMEJSjwY3kBnAqO1poYMhTYMlafraBAaKrLWMEhkBqvPeBPAhzlu2syqu2GGQKU0bukcQOlja2ikgj9gBlWltJS5JnOz78FQ9qnRDCAOQXcGzrne2OcBqWMp20aiJ6sRmewF4wHS5pBqqv2YNNTg6rlkU2XPHQglAx2YNNnXs(wHbywudHnQWgeuLnk6AFlieSNBxcNWlHToL7shqPiOIUKayJOyK0BSTaVmnYMp2GMnX0)a2GMnOztSKVvyaMf1qyBdSbbvzJc2UMT4O1pWN)tThQHnkyZF2et)dydA2GMnXs(wHbywudHTnWgeuLTnW25)u7HAw740qvJfaZIAiSTD22dqfEjCTJtdvnGpnaBuW21SfhT(b(8FQ9qnSrbBu0LIJw)0LiOlPiDTVfeBSNBxcNWlHToL7shqPiOIUKayJOyK0BSTaVmnYMp2AVUa0UknaxADUuJmB(ytaS1qpArX1oonu1yr7YMp22dqfEjCTJtdvnGNs(wjAKUGa4ZpTsRFyZhB7bOcVeU2XPHQgWzb85NwP1pS5JT9auHxcx740qvd4ZVJtmk85NwP1pDP4O1pDPDCAOQrx7BbHd652LWj8syRt5UuC06NUe6mjgz6Acf7snKCaLRw)0LCANjXitxtOiBqDJdBZRSrums6n2ylMgBEVEZMdt7Q0aKTyASrjca4vKTaGSr7YM4dyl9JmB480Y3RU0bukcQOlja2ikgj9gBlWltJS5JnOztaS1EDjhaWR4cGIaKChEjKnFS1EDbODvAaUaywudHn)zZbSLdBoGTTZ2XfolCgM4ItJT85zR96cq7Q0aCbWSOgcBBNnQU2mB(ZMgazuxALHW6d3kKnkyZhBAaKrDPvgcRpCRq28Nnh01(wqS5EUDjCcVe26uUlfhT(PlrUR9Uudjhq5Q1pDjP7ANTsKnOq2caYw490kB6ZMtp748zoYwmn2cvXmxLn9zJa5CydQsVztcDjfHnXAIeB3LYwjYguiBq9ZvkBqfefzl7biB6DmSDhjr20BKTZ)P2d1S6shqPiOIUu71LCaaVIlToxQrMnFS1EDbODvAaU06CPgz28Xg0Sja2o)NApuZIGUKISay0GKT85z78FQ9qnRDCAOQXcGzrne28NnieKnkylFE2AVUiOlPilToxQrUR9TGGs3ZTlHt4LWwNYDPdOueurxYJwuC5L(VLOj6cGXrzlFE28EcHnFSjwY3kmaZIAiSrf22ivzlFE2AOhTO4AhNgQASOD7sXrRF6sUVw)01(wqqP0ZTlHt4LWwNYDPdOueurxQHE0IIRDCAOQXI2TlfhT(Pl5L(VblsdGSR9TGGsUNBxcNWlHToL7shqPiOIUud9Offx740qvJfTBxkoA9txYdbeeCPg5U23cInDp3UeoHxcBDk3LoGsrqfDPg6rlkU2XPHQglA3UuC06NUKybqV0)TU23sqQ2ZTlHt4LWwNYDPdOueurxQHE0IIRDCAOQXI2TlfhT(PlfZbjkisWNiL6AFlbHONBxcNWlHToL7shqPiOIUKayJOyK0BSTIuInFSLfefbWbHeesnWamlQHWMq2OAxkoA9tx6ePeCC06h4ur0UuQik8ezyxApMIC31(wckyp3UeoHxcBDk3LIJw)0LuqnxqfIUudjhq5Q1pDjjiNdB6nYMlOEqPqYgrdLnpArr2uqnxqLnOk9MnhcNgQA4iBVEJaOkcYgnbz7h2o)NAputx6akfbv0L2dqfEjCPGAUGkmbY5atsVYMq2GGnFSbnBn0JwuCTJtdvnw0USLppBEpHWMp2el5BfgGzrne2OIq2eKQSrbB5ZZg0SThGk8s4sb1CbvycKZbMKELnHSjiB(ytaSPGAUG6sfCD(p1EOMfaJgKSrbB5ZZMayBpav4LWLcQ5cQWeiNdmj9Ax7Bj4g752LWj8syRt5U0bukcQOlThGk8s4sb1CbvycKZbMKELnHSjiB(ydA2AOhTO4AhNgQASODzlFE28EcHnFSjwY3kmaZIAiSrfHSjivzJc2YNNnOzBpav4LWLcQ5cQWeiNdmj9kBczdc28XMaytb1Cb1LcX68FQ9qnlagnizJc2YNNnbW2EaQWlHlfuZfuHjqohys61UuC06NUKcQ5cQc21U2LAV2ZTVfe9C7s4eEjS1PCx6D7seu7sXrRF6s7bOcVe2L2Jen2LCb1dkfsyWRHw)WMp2GMT2Rl5aaEfxamlQHWgvy78FQ9qnl5aaEfxnAqO1pSLppB7bOcVeUaOmoWKqPbHIn2OOl1qYbuUA9txYPQSszJGNFAbas2Oeba8ksyt8bS5cQhukKSbEn06h2kr2Gcz7o2r224MzdheidjBaugh2EaBuIaaEfzdQkLydD2TaiB)WMEJS5cQSaajBAaKrTlTha4jYWUe5s5cFG8Kqy5aaEf7AFlb752LWj8syRt5U072LiO2LIJw)0L2dqfEjSlThjASl5cQhukKWGxdT(HnFSbnBn0JwuCrUR9fTlB(yJ4IPeSgazujlXyGFr4ltTJe28NnbzlFE22dqfEjCbqzCGjHsdcfBSrrxQHKdOC16NUKtvzLYgbp)0caKS5W0UknajSj(a2Cb1dkfs2aVgA9dBLiBqHSDh7iBBCZSHdcKHKnakJdBpGnP7ANTIWgTlB)WMG5MtxApaWtKHDjYLYf(a5jHWaAxLgGDTV1g752LWj8syRt5U072LiO2LIJw)0L2dqfEjSlThjASl1qpArX1oonu1yr7YMp2GMTg6rlkUi31(I2LT85zllikcGdcjiKAGbywudHn)zJQSrbB(yR96cq7Q0aCbWSOgcB(ZMGDPgsoGYvRF6sovLvkBomTRsdqcBLiBoeonu1ihP7A)AbwqueW2MqibHudBfHnAx2IPXguiB3XoYMG5Wgbp)0iSLqrLTFytVr2CyAxLgGSTTFUDP9aaprg2LixkxyaTRsdWU23Yb9C7s4eEjS1PCxkoA9txsoaGxXUudjhq5Q1pDjjx8urInkraaVISftJnhM2vPbiBeuPDzZfupGn9zZPDMeJmDnHISDcI2LoGsrqfDjns4Ol0zsmY01ekUWj8syJnFSja2AOhTO4soaGxXf6mjgz6AcfBS5JT2Rl5aaEfxUz0jTCtfcyJkczdc28X25)u7HAwOZKyKPRjuCbWSOgcBuHnbzZhBexmLG1aiJkzjgd8lcFzQDKWMq2GGnFSbIQbJ74ORO1iRAyZF2O0S5JT2Rl5aaEfxamlQHW22zJQRnZgvytdGmQlTYqy9HBf21(wBUNBxcNWlHToL7shqPiOIUKgjC0f6mjgz6Acfx4eEjSXMp2GMnuuepATJWNpZ7HD)AucB(lKTJlCw4mmXfNgB(y78FQ9qnl0zsmY01ekUaywudHnQWgeS5JT2RlaTRsdWfaZIAiSTD2O6AZSrf20aiJ6sRmewF4wHSrrxkoA9txcq7Q0aSR9TO09C7s4eEjS1PCxkoA9txY9)emajpn4GDPgsoGYvRF6suIaaEfzJ29cIUoYwKipBkOqcB6ZgnbzRu2ccBbBex8urInzCqqOpGnXhWMEJSLcIYMF2g28qXhGSfSjwtrUrqxs8bWd6S23cIU23IsPNBxcNWlHToL7shqPiOIUeafbi5o8siB(y78zEpS7xJswnuSoLYM)czdc28Xg0S5MrN0YnviGnQiKniylFE2aywudHnQiKnToxG1kdzZhBexmLG1aiJkzjgd8lcFzQDKWM)czBJSrbB(ydA2eaBOZKyKPRjuSXw(8SbWSOgcBuriBADUaRvgY22ztq28XgXftjynaYOswIXa)IWxMAhjS5Vq22iBuWMp2GMnnaYOU0kdH1hUviBBGnaMf1qyJc28NnhWMp2YcIIa4GqccPgyaMf1qytiBuTlfhT(PljhaWRyx7Brj3ZTlHt4LWwNYDjXhapOZAFli6sXrRF6sU)NGbi5PbhSR9T209C7s4eEjS1PCxkoA9txsoaGxXU0bukcQOlja22dqfEjCrUuUWhipjewoaGxr28Xgafbi5o8siB(y78zEpS7xJswnuSoLYM)czdc28Xg0S5MrN0YnviGnQiKniylFE2aywudHnQiKnToxG1kdzZhBexmLG1aiJkzjgd8lcFzQDKWM)czBJSrbB(ydA2eaBOZKyKPRjuSXw(8SbWSOgcBuriBADUaRvgY22ztq28XgXftjynaYOswIXa)IWxMAhjS5Vq22iBuWMp2GMnnaYOU0kdH1hUviBBGnaMf1qyJc28NnieKnFSLfefbWbHeesnWamlQHWMq2OAx6a5jHWAaKrL03cIU23ccQ2ZTlHt4LWwNYDP4O1pDPdOYi)aRyMls0U0bYtcH1aiJkPVfeDPdOueurxI4IPeSgazujS5Vq2eKnFSHII4rRDe(8zEpS7xJsyZFHS5a28XgoiqgYfaLXb(8zE1Gn28NnbPkB(ydA2eaBN)tThQzTJtdvnwamAqYw(8S1EDbODvAaU06CPgz2OGnFSbWSOgcBuHnbzlh22iBBNnOzJ4IPeSgazujS5Vq2CaBu0LAi5akxT(Pl5hqLr(HTCXmxKOS9dBz0jTCtiBAaKrLWwOS5GCyZpBdBqDJdBa6zQrMTNwzRg2eCdBMWwqyl9JmBbHnOq2UJDKnCEA5B2aOmoSftJTaGZvkBeu1AKzJ2LnXhWMdHtdvn6AFliGONBxcNWlHToL7sXrRF6saAxLgGDPgsoGYvRF6sc8i6YgTlBomTRsdq2cLnhKdB)WwKsSPbqgvcBqd1noSLQ9AKzl9JmB480Y3SftJT5v2it4sUFLIU0bukcQOlja22dqfEjCrUuUWaAxLgGS5JnuuepATJWNpZ7HD)AucB(lKnhWMp2aOiaj3HxczZhBqZMBgDsl3uHa2OIq2GGT85zdGzrne2OIq206CbwRmKnFSrCXucwdGmQKLymWVi8LP2rcB(lKTnYgfS5JnOztaSHotIrMUMqXgB5ZZgaZIAiSrfHSP15cSwziBBNnbzZhBexmLG1aiJkzjgd8lcFzQDKWM)czBJSrbB(ytdGmQlTYqy9HBfY2gydGzrne28NnOzZbSLdBqZgGEqXhiJRwqURrgMCE6PbW0cNWlHn22oBBMnkylh2GMna9GIpqgxT)Z8srdx4eEjSX22zBZSrbB5Wg0SThGk8s4cGY4atcLgek2yB7SrPzJc2OOR9TGqWEUDjCcVe26uUlfhT(PlbODvAa2LoGsrqfDjbW2EaQWlHlYLYf(a5jHWaAxLgGS5JnbW2EaQWlHlYLYfgq7Q0aKnFSHII4rRDe(8zEpS7xJsyZFHS5a28Xgafbi5o8siB(ydA2CZOtA5MkeWgveYgeSLppBamlQHWgveYMwNlWALHS5JnIlMsWAaKrLSeJb(fHVm1osyZFHSTr2OGnFSbnBcGn0zsmY01ek2ylFE2aywudHnQiKnToxG1kdzB7SjiB(yJ4IPeSgazujlXyGFr4ltTJe28xiBBKnkyZhBAaKrDPvgcRpCRq22aBamlQHWM)SbnBoGTCydA2a0dk(azC1cYDnYWKZtpnaMw4eEjSX22zBZSrbB5Wg0SbOhu8bY4Q9FMxkA4cNWlHn22oBBMnkylh2GMT9auHxcxaughysO0GqXgBBNnknBuWgfDPdKNecRbqgvsFli6AFli2yp3UeoHxcBDk3LIJw)0LoGkJ8dSIzUir7snKCaLRw)0LCcrk5fNlSTjVtZMFavg5h2YfZCrIYguLEZMEJSrImKT0lxh2ccBH3VJoYMhTYwjppOgz20BKnCqGmKSD(PvA9dHTsKnOq2caoxPSrtQrMnhM2vPbyx6akfbv0LiUykbRbqgvcB(lKnbzZhBOOiE0AhHpFM3d7(1Oe28xiBoGnFSbWSOgcBuHnbzlh22iBBNnOzJ4IPeSgazujS5Vq2CaBu01(wq4GEUDjCcVe26uUlfhT(PlDavg5hyfZCrI2LAi5akxT(Pl5hqLr(HTCXmxKOS9dBs5YwjYwnS5gtdZQdBX0yBWaKGKTSWz2WbbYqYwmn2kr2C6zhNpJnO(5kLT2Zw2dq2ArwiJS1Or20NTCP81cSnPlDaLIGk6sexmLG1aiJkHnHSbbB(ytaSbOhu8bY4QfK7AKHjNNEAamTWj8syJnFSLfefbWbHeesnWamlQHWMq2OkB(ydffXJw7i85Z8Ey3VgLWM)czdA2oUWzHZWexCASTb2GGnkyZhBaueGK7WlHS5JnbWg6mjgz6AcfBS5JnOztaS1qpArXf5U2x0US5JnOzdheid5QHI1Pu2OIq2eCZSLdB4Gazixaugh4ZN5vd2yJc2OGnFSPbqg1LwziS(WTczBdSbWSOgcB(ZMd6Ax7AxAhbK6N(wcsvbHGQukcUXUeubyQrM0LCI3ehElkPTOeceBSL7nYwL5(aLnXhW2v7XuK7RydGBk0faBSr(mKTGw)SqXgBN7yKrYIP2PQbzdcbIn)8ZocuSX2va6bfFGmUCYRytF2UcqpO4dKXLtUWj8sy7k2GwqNPyXu7u1GSrPfi28Zp7iqXgBxbOhu8bY4YjVIn9z7ka9GIpqgxo5cNWlHTRydAiCMIftntTt8M4WBrjTfLqGyJTCVr2Qm3hOSj(a2UYfGNpZl0RydGBk0faBSr(mKTGw)SqXgBN7yKrYIP2PQbzZbceB(5NDeOyJTRipDYRM2YjVIn9z7kYtN8QPTCYfoHxcBxXg0q4mflMANQgKnhiqS5NF2rGIn2UI80jVAAlN8k20NTRipDYRM2Yjx4eEjSDfBHYMt7eXPydAiCMIftTtvdY2Mfi28Zp7iqXgBxbOhu8bY4YjVIn9z7ka9GIpqgxo5cNWlHTRydAiCMIftTtvdYgLwGyZp)SJafBSDfGEqXhiJlN8k20NTRa0dk(azC5KlCcVe2UInOHWzkwm1ovniBukceB(5NDeOyJTRuqnxqDbXYjVIn9z7kfuZfuxkelN8k2G2botXIP2PQbzJsrGyZp)SJafBSDLcQ5cQlbxo5vSPpBxPGAUG6sfC5KxXg0c6mflMANQgKnkzbIn)8ZocuSX2vkOMlOUGy5KxXM(SDLcQ5cQlfILtEfBqlOZuSyQDQAq2OKfi28Zp7iqXgBxPGAUG6sWLtEfB6Z2vkOMlOUubxo5vSbTdCMIftntTt8M4WBrjTfLqGyJTCVr2Qm3hOSj(a2UQva8OxXga3uOla2yJ8ziBbT(zHIn2o3XiJKftTtvdYgLwGyZp)SJafBSDf5PtE10wo5vSPpBxrE6KxnTLtUWj8sy7k2GgcNPyXu7u1GSbbvfi28Zp7iqXgBxbOhu8bY4YjVIn9z7ka9GIpqgxo5cNWlHTRydAiCMIftntTt8M4WBrjTfLqGyJTCVr2Qm3hOSj(a2U60ixXga3uOla2yJ8ziBbT(zHIn2o3XiJKftTtvdYgLwGyZp)SJafBSjvz(HncKJgoZgLkB6ZMtrhS1Q9Iu)W27IGqFaBqFnfSbTGotXIP2PQbzJsrGyZp)SJafBSjvz(HncKJgoZgLkB6ZMtrhS1Q9Iu)W27IGqFaBqFnfSbTGotXIP2PQbzJswGyZp)SJafBSDf5PtE10wo5vSPpBxrE6KxnTLtUWj8sy7k2GwqNPyXu7u1GSbbvfi28Zp7iqXgBsvMFyJa5OHZSrPYM(S5u0bBTAVi1pS9Uii0hWg0xtbBqlOZuSyQDQAq2GqqbIn)8ZocuSXMuL5h2iqoA4mBuQSPpBofDWwR2ls9dBVlcc9bSb91uWg0c6mflMANQgKnbfuGyZp)SJafBSDLcQ5cQlbxo5vSPpBxPGAUG6sfC5KxXg0q4mflMANQgKnb3OaXMF(zhbk2y7kfuZfuxqSCYRytF2Usb1Cb1LcXYjVInOHWzkwm1m1oXBIdVfL0wucbIn2Y9gzRYCFGYM4dy7Q2RxXga3uOla2yJ8ziBbT(zHIn2o3XiJKftTtvdYMdei28Zp7iqXgBxHotIrMUMqX2YjVIn9z7Qg6rlkUCYf6mjgz6AcfBxXg0q4mflMANQgKniGqGyZp)SJafBSDfGEqXhiJlN8k20NTRa0dk(azC5KlCcVe2UInOf0zkwm1ovniBqiOaXMF(zhbk2y7ka9GIpqgxo5vSPpBxbOhu8bY4Yjx4eEjSDfBqlOZuSyQDQAq2GWbceB(5NDeOyJTRa0dk(azC5KxXM(SDfGEqXhiJlNCHt4LW2vSbneotXIPMPMskZ9bk2yJsHT4O1pSLkIswm1DjxWlwjSl5x)Y2MqibHutO1pS5WVmnYu7x)Y2Mqlttu2eCJoYMGuvqiyQzQ9RFzZp3XiJebIP2V(LTnW2M46MGKTRikOo6vSjMcz20NnYNHSTjBJtXM4dUqytF2iXoYMl4piHuJmBALHlMA)6x22aBB7pxPS5qXuKB2ONesiSjLQdYwmn2226GSbvLsSLcIYw6hzeWMEhdBcSGOiGTnHqccPMftTF9lBBGnhgtHZS5esHmMsHw)W21S5q40qvd2iqoh2GUezZHWPHQgSve20xwoHn2Err2EaB)WwWw6hz28Z2sXIP2V(LTnWMalUGS5esi5(acrLTAueaODv2QHTZN5fkBLiBqHS5eLMOS1QgBLYM4dyB)tHwjeM8PDC0ftTF9lBBGnboeKnjklXw2dq20NncDw2pSjWJ71CfHnNi)MkMQrMTsKniFA2UJDKn9gzJ80jVAAlMAMA)6x2CANXdTIn28qXhGSD(mVqzZdLRHSyBtoh0vjSn)SH7aKjsNyloA9dHTFsqUyQJJw)qwUa88zEHkmCDtqc7(f5hM64O1pKLlapFMxO5i8AVx1e2GftbKydQAKH135AyQJJw)qwUa88zEHMJWRZcWfSbl(a4gg6TJUa88zEHctWZpnIWn7yjkeevdg3XrxrRrw14peBMPooA9dz5cWZN5fAocVwmHK7dievhlrHKNo5vtB5stu6ecJaAxT(jFEYtN8QPT2)uOvcHjFAhhLPooA9dz5cWZN5fAocVEpav4LqhNidfUJtdvnGpnGJ7rIgfcXgGgqpO4dKXvJMCbQiDbbey3qp3BNQlhSzkyQ9lB5EJSf7iiKr28Z26WSve2O6sqbzZJwzRrJSPpB6nYMdVfLGTjuAaY2lYMF2g2KXXr2e0z207IW2EKOr2kcBVRwzrInXhWgbY5uJmBPxUom1XrRFilxaE(mVqZr417bOcVe64ezOqXuiJPuO1pWNgWX9irJcHydqdOhu8bY469WwHZb3ovxoWbuWu7x22wurqwniBqDxNB2GUezlgiPGnIgkBE0IISPGAUGkBqHSbvmkB6ZwOkM5QSPpBeiNdBqv6nBoeonu1yXuhhT(HSCb45Z8cnhHxVhGk8sOJtKHcvqnxqfMa5CGjPxDCps0OqiCSefQGAUG6cI1DqGjAORyGeU5s8bTauqnxqDj46oiWen0vmqc3Cj5ZRGAUG6cI15)u7HAwnAqO1p(lub1Cb1LGRZ)P2d1SA0GqRFOiFEfuZfuxqSkYQgYbqRHxcH3uOJrPZGB4EDW85Hwb1Cb1feRISi3r7Hsgeexy9vmZ353XjgDTJJEdjGcM64O1pKLlapFMxO5i869auHxcDCImuOcQ5cQWeiNdmj9QJ7rIgfkOJLOqfuZfuxcUUdcmrdDfdKWnxIpOfGcQ5cQliw3bbMOHUIbs4MljFEfuZfuxcUo)NApuZQrdcT(XFfuZfuxqSo)NApuZQrdcT(HI85vqnxqDj4QiRAihaTgEjeEtHogLodUH71bZNhAfuZfuxcUkYIChThkzqqCH1xXmFNFhNy01oo6nKakyQJJw)qwUa88zEHMJWRjP6GWX0GB1bD0fGNpZluycE(PrecHJLOqakcqYD4LqM64O1pKLlapFMxO5i8AIIrsVzQzQ9RFzZPDgp0k2yd3raKSPvgYMEJSfh9bSve2I9OsHxcxm1XrRFicVuNlm1(Lnhgjkgj9MTsKn3NqkVeYg0ZZ2oDAqq4Lq2WbZkKWwnSD(mVqPGPooA9djhHxtums6ntDC06hsocVEpav4LqhNidfsQroHWAaKr1X9irJcjUykbRbqgvYsmg4xe(Yu7iHkcYu7x28ZN5vd2yZPheidjBomkJdBdInSXM(SrcLgekYuhhT(HKJWR3dqfEj0XjYqHaughysO0GqXMJ7rIgfIdcKHCbqzCGpFMxnyZ)nUzM64O1pKCeE9jsj44O1pWPIOoorgkKOyK0BS5irb1rfcHJLOqIIrsVX2c8Y0itDC06hsocV(ePeCC06h4uruhNidfEAeMA)Y22qRSjnBlB0USvtPvKsqYM4dyZp0kB6ZMEJS5N7GGoYgafbi5MnOk9MnNE2X5ZyRezlu2spuS1ObHw)WuhhT(HKJWRjP6GWX0GB1bDSefkapArXfjvheoMgCRo4I2135Z8Ey3VgL4VqiyQJJw)qYr414SJZN5yjk0JwuCrs1bHJPb3QdUOD95rlkUiP6GWX0GB1bxamlQHqLn778zEpS7xJs8xOdyQJJw)qYr41NiLGJJw)aNkI64ezOW2Rm1XrRFi5i86tKsWXrRFGtfrDCImuyRa4rzQJJw)qYr41b4edcRpaGJ6yjkeheid5QHI1Pu)fcXMZbheid5cGY4aF(mVAWgtDC06hsocVoaNyqyx6ebzQJJw)qYr41Ps(wjWorPBYz4Om1XrRFi5i8AVqg(fHvqDUqyQzQ9RFzZp)NApudHP2VSrjjYw0Ae2caYgTRJSrMYfztVr2(bzdQsVzl9qHeLTCZDBxSjWHGSb1noS1GSgz2edIIa207yyZpBdBnuSoLY2dydQsVFALTyGKn)SnlM64O1pK1PrYr41zb4c2GfFaCdd92Xuni8PjeI1MD8a5jHWAaKrLiechlrHGOAW4oo6kAnYI21h0AaKrDPvgcRpCRqQC(mVh29RrjRgkwNs3oeRnNp)5Z8Ey3VgLSAOyDk1FHhx4SWzyIlonkyQ9lBusISnpBrRrydQkLyRviBqv6DnSP3iBd6SY2gPkXr2OjiBcmXTLTFyZ7je2GQ07NwzlgizZpBZIPooA9dzDAKCeEDwaUGnyXha3WqVDSefcIQbJ74ORO1iRA8FJuDdGOAW4oo6kAnYQrdcT(X35Z8Ey3VgLSAOyDk1FHhx4SWzyIlonMA)YMeKZHnhcNgQAWgu10EOydQsVzBRs(wjAKUGGCCANjXitxtOiBLiBHRBQoHxczQJJw)qwNgjhHxVhGk8sOJtKHc3XPHQgWtjFRensxqa85NwP1poUhjAuOa0iHJUMs(wjAKUGGfoHxcB5Zlans4Ol0zsmY01ekUWj8sylF(Z)P2d1SqNjXitxtO4cGzrneQS5ni421iHJUAi6IayIccnKXSfoHxcBm1(LnN4Ou2(HnhcNgQAWM4dyJseaWRiBqv6nBcSnXr2ONesiSbfYwaq2cLTSWz28Z2WM4dyZjKczmLcT(HPooA9dzDAKCeE9EaQWlHoorgkChNgQAaNfWNFALw)44EKOrHcqJeo6klikcGdcjiKAw4eEjSLpF71LCaaVIlToxQroF(ZVJtm6Ahh9gsGVZN59WUFnkz1qX6uQqQYu7x2KGCoS5q40qvd2GQ0B2CcPqgtPqRFylMgBsOlPiSfe2s)iZwqydkKnO(5kLT0tq2c2obrz73raB6nYMyjFRS1ObHw)WuhhT(HSonsocVEpav4LqhNidfUJtdvnGp)ooXOWNFALw)4yjk8874eJUUajOIjF(ZVJtm6AWd4tpOLp)53XjgDn)GoUhjAuiem1XrRFiRtJKJWR3dqfEj0XjYqH740qvd4ZVJtmk85NwP1powIcp)ooXORDC0BiboUhjAuOy6Fa0qlwY3kmaZIAiBqqQsbLk0qiiv3(EaQWlHRDCAOQb8PbOGc)ft)dGgAXs(wHbywudzdcs1nC(p1EOMLykKXuk06NfaZIAiuqPcnecs1TVhGk8s4AhNgQAaFAakOiFEpArXLykKXuk06hypArXfTB(8n0JwuCjMczmLcT(zr7MpV3ti(el5BfgGzrneQiivzQJJw)qwNgjhHxVhGk8sOJtKHc3XPHQgWNFhNyu4ZpTsRFCSefE(DCIrxtjFRWIb64EKOrHIP)bqdTyjFRWamlQHSbbPkfuQqdHGuD77bOcVeU2XPHQgWNgGck8xm9paAOfl5BfgGzrnKniiv3W5)u7HAwe0LuKfaZIAiuqPcnecs1TVhGk8s4AhNgQAaFAakOiF(2Rlc6skYsRZLAKZN37jeFIL8TcdWSOgcveKQm1(LnNqcj3hqiQSj(a22gAIsNq2CAaTRw)WwjY28kBefJKEJn2EaB1WwW25)u7HAy7a5jHm1XrRFiRtJKJWRfti5(acr1Xsui0KNo5vtB5stu6ecJaAxT(jFEYtN8QPT2)uOvcHjFAhhLcFcGOyK0BSTIuYNaAOhTO4AhNgQASOD9LfefbWbHeesnWamlQHiKQ(Ggheid5sRmewF4SWz4ZN5vd28xW85fqd9OffxK7AFr7sHJ1Oiaq7QWvwg2QqrHq4ynkca0UkSC69IKqiCSgfbaAxfUefsE6KxnT1(NcTsim5t74Om1(LnjiNdBoHuiJPuO1pSbvP3S5q40qvd2ccBPFKzliSbfYgu)CLYw6jiBbBNGOS97iGn9gztSKVv2A0GqRFyd6hWwjYMdHtdvnydQkLy78ziBEX5cBHCuZ1fHn9LLtyJTxuKIftDC06hY60i5i8AXuiJPuO1powIcfarXiP3yBbEzA0h0N)tThQzTJtdvnwamlQHqLn6Bpav4LW1oonu1aolGp)0kT(XhkkIhT2r4ZN59WUFnkXFHoWNgazuxALHW6d3k0FiOA(8n0JwuCTJtdvnw0U5Z79eIpXs(wHbywudHkc6akyQJJw)qwNgjhHxlMczmLcT(XXsuOaikgj9gBlWltJ(qrr8O1ocF(mVh29Rrj(l0b(Gwm9paAOfl5BfgGzrnKniOdOGsf6Z)P2d1S99auHxcxIPqgtPqRFGpnafu4Vy6Fa0qlwY3kmaZIAiBqqhSHZ)P2d1S2XPHQglaMf1q2(EaQWlHRDCAOQb8PbOGsf6Z)P2d1S99auHxcxIPqgtPqRFGpnafuqbtTFztcY5WMe6skcBqv6nBoeonu1GTGWw6hz2ccBqHSb1pxPSLEcYwW2jikB)ocytVr2el5BLTgni06hhzZJwzZfGIiGnnaYOsytVdLnOQuITuTJSfkBjmikBqqvctDC06hY60i5i8Ac6skIJLOqbqums6n2wGxMg9b95)u7HAw740qvJfaZIAiubcFAaKrDPvgcRpCRq)HGQ5Z3qpArX1oonu1yr7MpVyjFRWamlQHqfiOkfm1XrRFiRtJKJWRjOlPiowIcfarXiP3yBbEzA0h0IP)bqdTyjFRWamlQHSbiOkfuQN)tThQHc)ft)dGgAXs(wHbywudzdqq1nC(p1EOM1oonu1ybWSOgY23dqfEjCTJtdvnGpnafuQN)tThQHckyQJJw)qwNgjhHxVJtdvnCSefkaIIrsVX2c8Y0OV2RlaTRsdWLwNl1i7tan0JwuCTJtdvnw0U(2dqfEjCTJtdvnGNs(wjAKUGa4ZpTsRF8ThGk8s4AhNgQAaNfWNFALw)4Bpav4LW1oonu1a(874eJcF(PvA9dtTFzZPDMeJmDnHISb1noSnVYgrXiP3yJTyAS596nBomTRsdq2IPXgLiaGxr2caYgTlBIpGT0pYSHZtlFVyQJJw)qwNgjhHxJotIrMUMqrhlrHcGOyK0BSTaVmn6dAb0EDjhaWR4cGIaKChEj0x71fG2vPb4cGzrne)Dqooy7hx4SWzyIloT85BVUa0UknaxamlQHSDQU2S)AaKrDPvgcRpCRqk8Pbqg1LwziS(WTc93bm1(LnP7ANTsKnOq2caYw490kB6ZMtp748zoYwmn2cvXmxLn9zJa5CydQsVztcDjfHnXAIeB3LYwjYguiBq9ZvkBqfefzl7biB6DmSDhjr20BKTZ)P2d1SyQJJw)qwNgjhHxtURDhlrHTxxYba8kU06CPgzFTxxaAxLgGlToxQr2h0c48FQ9qnlc6skYcGrdY85p)NApuZAhNgQASaywudXFieKI85BVUiOlPilToxQrMPooA9dzDAKCeET7R1powIc9OffxEP)BjAIUayC0859EcXNyjFRWamlQHqLns185BOhTO4AhNgQASODzQJJw)qwNgjhHx7L(VblsdG0Xsuyd9Offx740qvJfTltDC06hY60i5i8ApeqqWLAKDSef2qpArX1oonu1yr7YuhhT(HSonsocVwSaOx6)MJLOWg6rlkU2XPHQglAxM64O1pK1PrYr41XCqIcIe8jsjhlrHn0JwuCTJtdvnw0Um1XrRFiRtJKJWRprkbhhT(bove1XjYqH7XuKBhlrHcGOyK0BSTIuYxwqueahesqi1adWSOgIqQYu7x2KGCoSP3iBUG6bLcjBenu28Offztb1Cbv2GQ0B2CiCAOQHJS96ncGQiiB0eKTFy78FQ9qnm1XrRFiRtJKJWRvqnxqfchlrH7bOcVeUuqnxqfMa5CGjPxfcHpOBOhTO4AhNgQASODZN37jeFIL8TcdWSOgcvekivPiFEO3dqfEjCPGAUGkmbY5atsVkuqFcqb1Cb1LGRZ)P2d1Say0GKI85fWEaQWlHlfuZfuHjqohys6vM64O1pK1PrYr41kOMlOkOJLOW9auHxcxkOMlOctGCoWK0Rcf0h0n0JwuCTJtdvnw0U5Z79eIpXs(wHbywudHkcfKQuKpp07bOcVeUuqnxqfMa5CGjPxfcHpbOGAUG6cI15)u7HAwamAqsr(8cypav4LWLcQ5cQWeiNdmj9ktntTF9lBBBbWJYwlYczKTWRsLwiHP2VS50ZooFgBHYMdYHnO3CoSbvP3STTsuWMF2MfBuszzyRcftqY2pSjyoSPbqgvIJSbvP3S5q40qvdhz7bSbvP3SLlLf4kBVEJaOkcYgurPSj(a2iFgYgoiqgYfBBsI8SbvukBLiBoTZez2oFM3Zwry78z1iZgT7IPooA9dz1kaEuH4SJZN5yjkeffXJw7i85Z8Ey3VgL4VqhKJgjC0vdrxeatuqOHmMTWj8syZh0n0JwuCTJtdvnw0U5Z3qpArXf5U2x0U5Z3qpArXLykKXuk06NfTB(84GazixnuSoLsfHcU5CWbbYqUaOmoWNpZRgSLpVa2dqfEjCrQroHWAaKrLcFqlans4Ol0zsmY01ekUWj8sylF(Z)P2d1SqNjXitxtO4cGzrne)fKcM64O1pKvRa4rZr417bOcVe64ezOqAcclwPecCCps0OWZN59WUFnkz1qX6uQ)qKppoiqgYvdfRtPurOGBohCqGmKlakJd85Z8QbB5ZlG9auHxcxKAKtiSgazuzQ9lBBIRBcs2KOSeB6ZwKsSPbqgvcBqv69tRSfS1qpArr2ccBUG6bLcPJS5cqreaQrMnnaYOsyRbznYSr(FqaBHOIa20BKnxqLfaiztdGmQm1XrRFiRwbWJMJWRjiaek2G9(bHjU1f0Xsu4EaQWlHlAcclwPec8jG2RlccaHInyVFqyIBDbHBVU06CPgzM64O1pKvRa4rZr41eeacfBWE)GWe36c64bYtcH1aiJkrieowIc3dqfEjCrtqyXkLqGpb0EDrqaiuSb79dctCRliC71LwNl1iZu7x2CIVXHnb2MWwryBELTqz7UKVzRrdcT(Xr2OjiBsuwIn9zlCDtqYMtHrJnpizZPDoYCtiBnAqnYS5q40qvdhz71Beavrq2UGOlBIGpJTt46wJmBN7aiJeM64O1pKvRa4rZr41eeacfBWE)GWe36c6yjkCpav4LWfnbHfRucb(YcIIa4GqccPgyaMf1qOcvxuY(GwSKVvyaMf1qOIWnNp)5)u7HAweeacfBWE)GWe36cUYcNHp3bqgjB4ChazKalcIJw)ejQiKQlb3C(8KNo5vtBLWOb7bjm6CK5MWfoHxcB(eGhTO4kHrd2dsy05iZnHlAxFn0JwuCTJtdvnw0U5Z7rlkUYca4HcBWYygr)bHX5oMdMHJUODPGP2VSjWHGSjrzj20NncDw2pSjWJ71CfHnNi)MkMQrMTsKniFA2UJDKn9gzJ80jVAAlM64O1pKvRa4rZr41eeacfBWE)GWe36c6yQge(0ecXMDSefsE6KxnT1fCVgc8)BQyQgzFE0IIRl4Ene4)3uXunYR2d1Wu7x2CcXW2lYMa)u7iHTqzdInDoSr04CHW2lYMa3vRHdBuofnKW2dylKJAikBoih20aiJkzXuhhT(HSAfapAocVwmg4xe(Yu7iXXsu4EaQWlHlAcclwPec8bThTO46UAnCG9srdjlIgNl(leInD(8qlaxq9GsHeg8AO1p(iUykbRbqgvYsmg4xe(Yu7iXFHoihIIrsVX2c8Y0ifuWu7x2CcXW2lYMa)u7iHn9zlCDtqYM7xKFiSvISvtC0Ahz7h2Ibs20aiJkBq)a2Ibs28si2QrMnnaYOsydQsVzZfupOuizd8AO1puWwOSTXCzQJJw)qwTcGhnhHxlgd8lcFzQDK44bYtcH1aiJkrieowIcHwaUG6bLcjm41qRFYNV96soaGxXLwNl1iNpF71fG2vPb4sRZLAKPW3EaQWlHlAcclwPec8rCXucwdGmQKLymWVi8LP2rI)c3itDC06hYQva8O5i8A8C)1iddqxqLftZXsu4EaQWlHlAcclwPec8D(p1EOM1oonu1ybWSOgI)qqvM64O1pKvRa4rZr41rMhn52Xsu4EaQWlHlAcclwPec8bDwqueahesqi1adWSOgIqQ6taa6bfFGmUA)N5LIgMpVhTO4YlvtJunCr7sbtTFzl3WBdcmATsHISPpBHRBcs22wmAjizBB(I8dBHYMGSPbqgvctDC06hYQva8O5i86mATsHIoEG8KqynaYOsecHJLOW9auHxcx0eewSsje4J4IPeSgazujlXyGFr4ltTJeHcYuhhT(HSAfapAocVoJwRuOOJLOW9auHxcx0eewSsjeWuZu7x)Y22gzHmY2VJa20kdzl8QuPfsyQ9lBovLvkBe88tlaqYgLiaGxrcBIpGnxq9GsHKnWRHw)WwjYguiB3XoY2g3mB4GazizdGY4W2dyJseaWRiBqvPeBOZUfaz7h20BKnxqLfaiztdGmQm1XrRFiR2Rc3dqfEj0XjYqHKlLl8bYtcHLda4v0X9irJcDb1dkfsyWRHw)4d62Rl5aaEfxamlQHqLZ)P2d1SKda4vC1ObHw)Kp)EaQWlHlakJdmjuAqOyJcMA)YMtvzLYgbp)0caKS5W0UknajSj(a2Cb1dkfs2aVgA9dBLiBqHSDh7iBBCZSHdcKHKnakJdBpGnP7ANTIWgTlB)WMG5MdtDC06hYQ9AocVEpav4LqhNidfsUuUWhipjegq7Q0a0X9irJcDb1dkfsyWRHw)4d6g6rlkUi31(I21hXftjynaYOswIXa)IWxMAhj(ly(87bOcVeUaOmoWKqPbHInkyQ9lBovLvkBomTRsdqcBLiBoeonu1ihP7A)AbwqueW2MqibHudBfHnAx2IPXguiB3XoYMG5Wgbp)0iSLqrLTFytVr2CyAxLgGSTTFUm1XrRFiR2R5i869auHxcDCImui5s5cdODvAa64EKOrHn0JwuCTJtdvnw0U(GUHE0IIlYDTVODZNplikcGdcjiKAGbywudXFQsHV2RlaTRsdWfaZIAi(litTFztYfpvKyJseaWRiBX0yZHPDvAaYgbvAx2Cb1dytF2CANjXitxtOiBNGOm1XrRFiR2R5i8A5aaEfDSefQrchDHotIrMUMqXfoHxcB(ea6mjgz6AcfBl5aaEf91EDjhaWR4YnJoPLBQqavecHVZ)P2d1SqNjXitxtO4cGzrneQiOpIlMsWAaKrLSeJb(fHVm1osecHpqunyChhDfTgzvJ)uAFTxxYba8kUaywudz7uDTzQObqg1LwziS(WTczQJJw)qwTxZr41aAxLgGowIc1iHJUqNjXitxtO4cNWlHnFqJII4rRDe(8zEpS7xJs8x4XfolCgM4ItZ35)u7HAwOZKyKPRjuCbWSOgcvGWx71fG2vPb4cGzrnKTt11MPIgazuxALHW6d3kKcMA)YgLiaGxr2ODVGORJSfjYZMckKWM(Srtq2kLTGWwWgXfpvKytghee6dyt8bSP3iBPGOS5NTHnpu8biBbBI1uKBeWuhhT(HSAVMJWRD)pbdqYtdoOJIpaEqNvHqWuhhT(HSAVMJWRLda4v0Xsuiafbi5o8sOVZN59WUFnkz1qX6uQ)cHWh0Uz0jTCtfcOIqiYNhGzrneQiuRZfyTYqFexmLG1aiJkzjgd8lcFzQDK4VWnsHpOfa6mjgz6AcfB5ZdWSOgcveQ15cSwz42f0hXftjynaYOswIXa)IWxMAhj(lCJu4dAnaYOU0kdH1hUv4gaywudHc)DGVSGOiaoiKGqQbgGzrneHuLPooA9dz1EnhHx7(FcgGKNgCqhfFa8GoRcHGPooA9dz1EnhHxlhaWROJhipjewdGmQeHq4yjkua7bOcVeUixkx4dKNeclhaWROpakcqYD4LqFNpZ7HD)AuYQHI1Pu)fcHpODZOtA5MkeqfHqKppaZIAiurOwNlWALH(iUykbRbqgvYsmg4xe(Yu7iXFHBKcFqla0zsmY01ek2YNhGzrneQiuRZfyTYWTlOpIlMsWAaKrLSeJb(fHVm1os8x4gPWh0AaKrDPvgcRpCRWnaWSOgcf(dHG(YcIIa4GqccPgyaMf1qesvMA)YMFavg5h2YfZCrIY2pSLrN0YnHSPbqgvcBHYMdYHn)SnSb1noSbONPgz2EALTAytWnSzcBbHT0pYSfe2Gcz7o2r2W5PLVzdGY4Wwmn2caoxPSrqvRrMnAx2eFaBoeonu1GPooA9dz1EnhHxFavg5hyfZCrI64bYtcH1aiJkrieowIcjUykbRbqgvI)cf0hkkIhT2r4ZN59WUFnkXFHoWhoiqgYfaLXb(8zE1Gn)fKQ(GwaN)tThQzTJtdvnwamAqMpF71fG2vPb4sRZLAKPWhaZIAiurWC242HM4IPeSgazuj(l0buWu7x2e4r0LnAx2CyAxLgGSfkBoih2(HTiLytdGmQe2GgQBCylv71iZw6hz2W5PLVzlMgBZRSrMWLC)kfm1XrRFiR2R5i8AaTRsdqhlrHcypav4LWf5s5cdODvAa6dffXJw7i85Z8Ey3VgL4Vqh4dGIaKChEj0h0Uz0jTCtfcOIqiYNhGzrneQiuRZfyTYqFexmLG1aiJkzjgd8lcFzQDK4VWnsHpOfa6mjgz6AcfB5ZdWSOgcveQ15cSwz42f0hXftjynaYOswIXa)IWxMAhj(lCJu4tdGmQlTYqy9HBfUbaMf1q8hAhKd0a6bfFGmUAb5UgzyY5PNgatBFZuKd0a6bfFGmUA)N5LIgU9ntroqVhGk8s4cGY4atcLgek22oLMckyQJJw)qwTxZr41aAxLgGoEG8KqynaYOsecHJLOqbShGk8s4ICPCHpqEsimG2vPbOpbShGk8s4ICPCHb0Ukna9HII4rRDe(8zEpS7xJs8xOd8bqrasUdVe6dA3m6KwUPcburie5ZdWSOgcveQ15cSwzOpIlMsWAaKrLSeJb(fHVm1os8x4gPWh0caDMeJmDnHIT85bywudHkc16CbwRmC7c6J4IPeSgazujlXyGFr4ltTJe)fUrk8Pbqg1LwziS(WTc3aaZIAi(dTdYbAa9GIpqgxTGCxJmm580tdGPTVzkYbAa9GIpqgxT)Z8srd3(MPihO3dqfEjCbqzCGjHsdcfBBNstbfm1(LnNqKsEX5cBBY70S5hqLr(HTCXmxKOSbvP3SP3iBKidzl9Y1HTGWw497OJS5rRSvYZdQrMn9gzdheidjBNFALw)qyRezdkKTaGZvkB0KAKzZHPDvAaYuhhT(HSAVMJWRpGkJ8dSIzUirDSefsCXucwdGmQe)fkOpuuepATJWNpZ7HD)AuI)cDGpaMf1qOIG5SXTdnXftjynaYOs8xOdOGP2VS5hqLr(HTCXmxKOS9dBs5YwjYwnS5gtdZQdBX0yBWaKGKTSWz2WbbYqYwmn2kr2C6zhNpJnO(5kLT2Zw2dq2ArwiJS1Or20NTCP81cSnHPooA9dz1EnhHxFavg5hyfZCrI6yjkK4IPeSgazujcHWNaa0dk(azC1cYDnYWKZtpnaM8LfefbWbHeesnWamlQHiKQ(qrr8O1ocF(mVh29Rrj(le6JlCw4mmXfN2gGGcFaueGK7WlH(ea6mjgz6AcfB(Gwan0JwuCrUR9fTRpOXbbYqUAOyDkLkcfCZ5GdcKHCbqzCGpFMxnyJck8Pbqg1LwziS(WTc3aaZIAi(7aMAMA)6x2Kums6n2yBtoA9dHP2VSTvjFt0iDbbS9dBBmxbIn)aQmYpSLlM5IeLPooA9dzrums6n2eEavg5hyfZCrI6yjkuJeo6Ak5BLOr6ccw4eEjS5J4IPeSgazuj(lCJ(oFM3d7(1Oe)f6aFAaKrDPvgcRpCRWnaWSOgI)uAMA)Y2wL8nrJ0feW2pSbrUceBst4sUFLnhM2vPbitDC06hYIOyK0BSLJWRb0UknaDSefQrchDnL8Ts0iDbblCcVe28D(mVh29Rrj(l0b(0aiJ6sRmewF4wHBaGzrne)P0m1(LnjApfbI0YOaX2M46MGKThWMdJIaKCZguLEZMhTOi2yJseaWRiHPooA9dzrums6n2Yr41U)NGbi5Pbh0rXhapOZQqiyQJJw)qwefJKEJTCeETCaaVIoEG8KqynaYOsecHJLOqns4OlcTNIarAzCHt4LWMpObywudHkqiy(8Uz0jTCtfcOIqiOWNgazuxALHW6d3kCdamlQH4VGm1(LnjApfbI0YiB5WMt7mrMTFydICfi2CyueGKB2Oeba8kYwOSP3iB40y7fzJOyK0B20NnzuzllCMTgni06h28qXhGS50otIrMUMqrM64O1pKfrXiP3ylhHx7(FcgGKNgCqhfFa8GoRcHGPooA9dzrums6n2Yr41Yba8k6yjkuJeo6Iq7PiqKwgx4eEjS5tJeo6cDMeJmDnHIlCcVe28fhT2ryCWScjcHWNhTO4Iq7PiqKwgxamlQHqfiwBKPooA9dzrums6n2Yr41z0ALcfDSefQrchDrO9ueislJlCcVe28D(mVh29Rrjur4gzQzQ9RFzZHIPi3m1(LnNqnf5MnOk9MTSWz28Z2WM4dyBRs(wjAKUGahzJEsiHWgnPgz22wm07eKSjDhThkctDC06hYApMIClCpav4LqhNidfoL8Ts0iDbbWhx4ZpTsRFCCps0OqOfaGEqXhiJRgg6DcsyYD0EOi(qrr8O1ocF(mVh29Rrj(l84cNfodtCXPrr(8qdOhu8bY4QHHENGeMChThkIVZN59WUFnkHkcsbtTFzZHIPi3SbvP3S50otKzlh22QKVvIgPliqGytGfoxz0zS5NTHTyAS50otKzdGrds2eFaBd6SYgLWpBltDC06hYApMICNJWR3JPi3owIc1iHJUqNjXitxtO4cNWlHnFAKWrxtjFRensxqWcNWlHnF7bOcVeUMs(wjAKUGa4Jl85NwP1p(o)NApuZcDMeJmDnHIlaMf1qOcem1(LnhkMICZguLEZ2wL8Ts0iDbbSLdBB9S50otKfi2eyHZvgDgB(zBylMgBoeonu1GnAxM64O1pK1Emf5ohHxVhtrUDSefQrchDnL8Ts0iDbblCcVe28jans4Ol0zsmY01ekUWj8syZ3EaQWlHRPKVvIgPlia(4cF(PvA9JVg6rlkU2XPHQglAxM64O1pK1Emf5ohHx7(FcgGKNgCqhfFa8GoRcHWr0zfeWr2tpQqhSzM64O1pK1Emf5ohHxVhtrUDSefQrchDrO9ueislJlCcVe28D(p1EOMLCaaVIlAxFq3EDjhaWR4cGIaKChEjmF(g6rlkU2XPHQglAxFTxxYba8kUCZOtA5MkeqfHqqHVZN59WUFnkz1qX6uQ)cHM4IPeSgazujlXyGFr4ltTJe)f4IdOWhiQgmUJJUIwJSQXFieKP2VS5qXuKB2GQ0B2eybrraBBcHeKAei2CyAxLgG5qjca4vKT5v2QHnakcqYnBGyKrhzRrdQrMnhcNgQAKJ0DTVytcY5WguLEZMe6skcBI1ej2UlLTsKn3NqkVeUyQJJw)qw7XuK7CeE9Emf52Xsui0AKWrxzbrraCqibHuZcNWlHT85b0dk(azCLfGlWViSEJWzbrraCqibHudf(eq71fG2vPb4cGIaKChEj0x71LCaaVIlaMf1q8FJ(AOhTO4AhNgQASOD9bDd9OffxK7AFr7MpFd9Offx740qvJfaZIAiuXb5Z3EDrqxsrwADUuJmf(AVUiOlPilaMf1qOYg7sex803sWnVP7Ax7D]] )


end