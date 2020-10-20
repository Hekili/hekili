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


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld" }
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
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains )
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
            alias = { "deadly_poison", "wound_poison" },
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
            
            usable = function () return stealthed.all or buff.blindside.up, "requires stealth or blindside proc" end,
            handler = function ()
                gain( 2, "combo_points" )
                removeBuff( "blindside" )
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
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

            handler = function ()
                applyDebuff( "target", "cheap_shot" )
                gain( 2, "combo_points" )

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

                -- if legendary.doomblade.enabled then -- need aura id.
                    -- applyDebuff( "target", "doomblade" )
                -- end
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

            usable = function () return stealthed.all, "requires stealth" end,
            handler = function ()
                applyDebuff( "target", "sap" )
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
            
            spend = function () return legendary.tiny_toxic_blades.enabled and 0 or 20 end,
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
                        if cd.remains > 0 then reduceCooldown( name, 15 ) end
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
                if buff.lethal_poison.down then
                    return state.spec.assassination and class.abilities.deadly_poison.texture or class.abilities.instant_poison.texture
                end
                if buff.nonlethal_poison.down then return class.abilities.crippling_poison.texture end
            end,

            usable = function ()
                return buff.lethal_poison.down or buff.nonlethal_poison.down, "requires missing poison"
            end,

            handler = function ()
                if buff.lethal_poison.down then
                    applyBuff( state.spec.assassination and "deadly_poison" or "instant_poison" )
                else applyBuff( "crippling_poison" ) end
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
                    max_stack = 40,
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

                flagellation_buff = {
                    id = 345569,
                    duration = 25,
                    max_stack = 1,
                }
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


    spec:RegisterPack( "Assassination", 20201016, [[di10gcqirPEesrUesbQnHs(KOImkuKtHcwfsr9kukZIsYTqPs7sWVevzyQu5yQuwMkHNHsvttuORPsITjQGVjQOACOurNtuHSoKc5DIcQQ5jQQ7He7dP0)efu5GifQfQsQhQssnrKc4IIc0gffq9rvssJePaPtkkaRef6LOubMPkjXnffu2jLu)uuqvgQOIYsrkONIQMQOKRIuGyRIkuFfLkOXIsfAVc9xrgSshMyXOYJvXKP4YGnRkFMQmAKQtRy1IciVgf1SPYTPu7wQFd1WPQoUOGSCephY0jDDv12rsFxuPXlk68QeTEvQA(uI9l54TywrEJOq06lU7I7UD3TCiCXTmMd3YyKxV0hI8(YHzXdI8TydrEAmcji00Io4oY7lx6WIjMvKhH)Kde5PRQpIgLxEEJs)Zfoy78qJ93j6G7drEAEOX(KxKN7pondOJCrEJOq06lU7I7UD3TCiCXTmMd3yFKx(kDmjYZp2xDKN(ymqh5I8gaDI80uT0yesqOPfDWDT0qS3hkgPPAZW7OyoGu7TCWQAV4UlUlY7gKIIzf5rkioLoyIzfT(wmRip0cNdmXRJ8hYOazKiVkoO1qpE0vKkoMbsaAHZbMAzv7bBZHt(4PvuT0sP2mwlRAvH4bAqhBiP4KzGAz3AjGTmnQwARnhI8YrhCh5jFF9tGOgT(IywrEOfohyIxh5FysQHm1O13I8YrhCh59XyxIai8NCGOgTM9XSI8qlCoWeVoYFiJcKrI8Y9azuiGOtWFdysO)7HpIo4oaTW5atTSQL7)Eb0NtbY77bHVFTSQL7)Eb0NtbY77bbcyltJQn)AVfyFTSQn7ArOe3)9atKxo6G7iVNqiyfIA06mgZkYdTW5at86i)dtsnKPgT(wKxo6G7iVpg7seaH)Kde1O1xjMvKhAHZbM41rE5OdUJ8EcHGviYFiJcKrI8Q4GwdOpNcK33dcqlCoWulRAzQwcyltJQn)AVDrTwSuRV93PJVBasT5tP2B1YqTSQvfIhObDSHKItMbQLDRLa2Y0OAPT2lI8NlpoiPcXduu06BrnADoeZkYdTW5at86i)HmkqgjYRIdAnG(CkqEFpiaTW5atTSQvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLvTzxRbRbY3x)eiOZH5P9QLvTufYiCoiGM2ZbjviEGg5LJo4oYt((6NarnADopMvKhAHZbM41r(hMKAitnA9TiVC0b3rEFm2Liac)jhiQrRzNXSI8qlCoWeVoYlhDWDK3tieScr(dzuGmsKxfh0Aa95uG8(EqaAHZbMAzvRCpqgfci6e83aMe6)E4JOdUdqlCoWulRAzQw5OdvibnypaQwAR9wTwSuB21QIdAnazIK27pTOqaAHZbMAzOww1QcXd0Go2qsXjZa1sBTeWwMgvlRAzQwcyltJQn)AVXoR1ILAZUwekX9FpWuldr(ZLhhKuH4bkkA9TOgTohfZkYdTW5at86i)dtsnKPgT(wKxo6G7iVpg7seaH)Kde1O13UlMvKhAHZbM41r(dzuGmsKxfh0Aa95uG8(EqaAHZbMAzvRkoO1aKjsAV)0IcbOfohyQLvTYrhQqcAWEauTuQ9wTSQL7)Eb0NtbY77bbcyltJQn)AVfyFKxo6G7iVNqiyfIAuJ8acb9bqXSIwFlMvKhAHZbM41r(dzuGmsKhAG4DzqhBiP4KTKzT0w7TAzvB21AaU)7fOcTbuvcF)Azvlt1MDTgSgo4(aTsefmPNtSHe3N0bDompTxTSQn7ALJo4oCW9bALikyspNydHPtp34rxR1ILAFFNlrGdDH4bjDSHAZVwVJjylzwldrE5OdUJ8hCFGwjIcM0Zj2quJwFrmRip0cNdmXRJ8hYOazKiVb4(VxGk0gqvj89RLvTmvRb4(VxWtieScbitK0E)Pffm1AXsTgG7)Ebe9HA47xlRApyBoCYhpTIcg4nNrRnFk1ERwlwQ1aC)3lqfAdOQeiGTmnQ28Pu7T7QLHATyP234rxteWwMgvB(uQ92DrE5OdUJ8Com2KWVKshsqd2xg1O1SpMvKhAHZbM41r(dzuGmsK)GXodo3oqfAdOQeiGTmnQ28RL91AXsTgG7)EbQqBavLW3VwlwQ9nE01ebSLPr1MFTS)UiVC0b3rEVVqmJ0j8lj3deSspQrRZymRip0cNdmXRJ8hYOazKi)ZHXKAzQwMQ9nE01ebSLPr1YU1Y(7QLHAZRw5OdUthm2zW521YqT0w7ZHXKAzQwMQ9nE01ebSLPr1YU1Y(7QLDR9GXodo3oqfAdOQeiGTmnQwgQnVALJo4oDWyNbNBxldrE5OdUJ8EFHygPt4xsUhiyLEuJwFLywrEOfohyIxh5pKrbYirEKp4CjviEGIcpPt4xI5EOcOAPLsTxuRfl1sKXKaQqRbXyqHPRL2AZH7QLvTqdeVlRn)AZ53f5LJo4oY)WNpcmj5EGmkK4aXoQrRZHywrEOfohyIxh5pKrbYirEKp4CjviEGIcpPt4xI5EOcOAPLsTxuRfl1sKXKaQqRbXyqHPRL2AZH7I8YrhCh59)K5D50EjoNG0OgToNhZkYdTW5at86i)HmkqgjYZ9FVabom7aek9WKde((1AXsTC)3lqGdZoaHspm5aPd(3kqcivomxB(1E7UiVC0b3rELoK(nh(3M0dtoquJwZoJzf5LJo4oYtgFFhKMoH8Lde5Hw4CGjEDuJwNJIzf5LJo4oYNlM4muHPteaHBPpqKhAHZbM41rnA9T7Izf5Hw4CGjEDK)qgfiJe5HgiExwB(1EL7QLvTzx7bJDgCUDGk0gqvj89J8YrhCh5TbBm5Ye(LC)Zysgci2OOgT(2TywrEOfohyIxh5LJo4oYtaXFAV0Zj2akYFiJcKrI8Qq8anOJnKuCYmqT5x7TWvQ1ILAzQwMQvfIhOb6G4u6b)JwlT1YoVRwlwQvfIhOb6G4u6b)JwB(uQ9I7QLHAzvlt1khDOcjOb7bq1sP2B1AXsTQq8anOJnKuCYmqT0w7f5OAzOwgQ1ILAzQwviEGg0Xgsko5F00f3vlT1Y(7QLvTmvRC0HkKGgShavlLAVvRfl1QcXd0Go2qsXjZa1sBTzmJ1YqTme5pxECqsfIhOOO13IAuJ8g4jFNgZkA9TywrE5OdUJ8mphMJ8qlCoWeVoQrRViMvKxo6G7ipsbXP0J8qlCoWeVoQrRzFmRip0cNdmXRJ8y)ipc0iVC0b3rEQczeohe5PkUpe5HgiExgiGh01YwT(4bHBWK4Cayq1sZ1MZRnVAzQ2lQLMRf5doxIUGuOwgI8ufsQfBiYdnq8UmrapOthSn30GjQrRZymRip0cNdmXRJ8y)ipc0iVC0b3rEQczeohe5PkUpe5r(GZLuH4bkk8KoHFjM7HkGQn)AViYtviPwSHipAAphKuH4bAuJwFLywrEOfohyIxh5pKrbYirEKcItPdMab79HiVC0b3r(J4Cj5OdUtUbPrE3G0ul2qKhPG4u6GjQrRZHywrEOfohyIxh5pKrbYirEMQn7AvXbTgSfKcKKGqccnDaAHZbMATyPwdwdEcHGviOZH5P9QLHiVC0b3r(J4Cj5OdUtUbPrE3G0ul2qK)yqrnADopMvKhAHZbM41rE5OdUJ8hX5sYrhCNCdsJ8UbPPwSHiVbRrnAn7mMvKhAHZbM41r(dzuGmsKN7)EbKBoqsAtYmhiqaBzAuT5xRkepqd6ydjfNmdulRA5(Vxa5MdKK2KmZbceWwMgvB(1YuT3QLTApyBoCYhpTIQLHAP5AVfyNrE5OdUJ8i3CGK0MKzoquJwNJIzf5Hw4CGjEDKxo6G7i)rCUKC0b3j3G0iVBqAQfBiYBgcC0OgT(2DXSI8qlCoWeVoYFiJcKrI8qdeVldg4nNrRLwk1E7k1YwTufYiCoianq8UmrapOthSn30GjYlhDWDKxihPHKIjeO1OgT(2TywrE5OdUJ8c5inK8)oee5Hw4CGjEDuJwF7IywrE5OdUJ8UXJUIszG(gpBO1ip0cNdmXRJA06BSpMvKxo6G7ipN4LWVKsMdZOip0cNdmXRJAuJ8(e4GT5enMv06BXSI8YrhCh5fFF3LjF8GWDKhAHZbM41rnA9fXSI8qlCoWeVoYlhDWDK3wimdM0dtsgqu6r(dzuGmsKNiJjbuHwdIXGctxlT1E7krEFcCW2CIMqWb3guK)krnAn7Jzf5LJo4oYJuqCk9ip0cNdmXRJA06mgZkYdTW5at86iVC0b3rEKBoqsAtYmhiYFiJcKrI8e4raeDHZbrEFcCW2CIMqWb3guK)wuJwFLywrEOfohyIxh5BXgI8Y9i6crqPhU1e(L8X5cKiVC0b3rE5EeDHiO0d3Ac)s(4CbsuJwNdXSI8qlCoWeVoYFiJcKrI8Q4GwdqMiP9(tlkeGw4CGjYlhDWDK37leZiDc)sY9abR0JAuJ8MHahnMv06BXSI8qlCoWeVoYFiJcKrI8mv7bBZHt(4PvuT0sP2mwlB1QIdAnyaWhijKsev8a7a0cNdm1AXsThSnho5JNwr1sPwPhB5qxiEGjD8RLHAzvlt1AaU)7fOcTbuvcF)ATyPwdW9FVaI(qn89R1ILAHgiExgmWBoJwB(uQ9IRulB1sviJW5Ga0aX7Yeb8GoDW2CtdMATyP2SRLQqgHZbb00EoiPcXd0AzOww1YuTzxRkoO1aKjsAV)0IcbOfohyQ1ILApySZGZTdqMiP9(tlkeiGTmnQwAR9IAziYlhDWDKhAQqJTJA06lIzf5Hw4CGjEDKh7h5rGg5LJo4oYtviJW5GipvX9Hi)bBZHt(4PvuWaV5mAT0w7TATyPwObI3Lbd8MZO1MpLAV4k1YwTufYiCoianq8UmrapOthSn30GPwlwQn7APkKr4CqanTNdsQq8anYtviPwSHi)hbP34CajQrRzFmRip0cNdmXRJ8YrhCh5raHikysC4gsi)HziYFiJcKrI8zxRbRbeqiIcMehUHeYFygc6CyEAVATyPwQczeohe(ii9gNdi1YQwMQvo6qfsqd2dGQLsT3QLvTezmjGk0Aqmguy6APT2335se4qxiEqshBOwlwQ9qxiEaQwAR9IAzvRkepqd6ydjfNmduB(1ELAziYFU84GKkepqrrRVf1O1zmMvKhAHZbM41r(dzuGmsKNQqgHZbHpcsVX5asTSQvUhiJcb4qhpTxIZjgafGw4CGPww1I8bNlPcXduu4jDc)sm3dvavlTuQ9IAzRwMQ1aC)3lqfAdOQe((1sZ1YuT3QLTAzQw5EGmkeGdD80EjoNyauGinZ1sP2B1YqTmuldrE5OdUJ8pPt4xI5EOcOOgT(kXSI8qlCoWeVoYFiJcKrI8ufYiCoi8rq6nohqQLvTmvl3)9c0hJb6eNtmakGu5WCT0sP2B5OATyPwMQn7A9jdMm6LjcwfDWDTSQf5doxsfIhOOWt6e(LyUhQaQwAPuBgRLTAzQw5EGmkem4pNdsgmccePzUwAR9IAzOw2QfPG4u6GjqWEFOwgQLHiVC0b3r(N0j8lXCpubuuJwNdXSI8qlCoWeVoYlhDWDK)jDc)sm3dvaf5pKrbYirEQczeohe(ii9gNdi1YQwKp4CjviEGIcpPt4xI5EOcOAPLsTSpYFU84GKkepqrrRVf1O158ywrEOfohyIxh5pKrbYirEQczeohe(ii9gNdirE5OdUJ8WHoEAVeb8jJT0MOgTMDgZkYdTW5at86i)HmkqgjYtviJW5GWhbP34CajYlhDWDKxS5(i6rnADokMvKhAHZbM41rE5OdUJ82FDCIcr(dzuGmsKNQqgHZbHpcsVX5asTSQf5doxsfIhOOWt6e(LyUhQaQwk1ErK)C5XbjviEGIIwFlQrRVDxmRip0cNdmXRJ8hYOazKipvHmcNdcFeKEJZbKiVC0b3rE7VoorHOg1i)XGIzfT(wmRip0cNdmXRJ8YrhCh5L7r0fIGspCRj8l5JZfir(dzuGmsKp7ArkioLoycIZvlRATfKcKKGqccnDIa2Y0OAPu7D1YQwMQ9GXodo3oqfAdOQeiGTmnQ28ZWvlt1EWyNbNBhq0hQbcyltJQLMRfYq)X3hmbbrNQ0akrK7XK0btexTmuld1MFT3URw2Q92D1sZ1czO)47dMGGOtvAaLiY9ys6GjIRww1MDTgG7)EbQqBavLW3Vww1MDTgG7)Ebe9HA47h5BXgI8Y9i6crqPhU1e(L8X5cKOgT(IywrEOfohyIxh5pKrbYir(SRfPG4u6GjioxTSQ1G1a57RFce05W80E1YQwBbPajjiKGqtNiGTmnQwk1ExKxo6G7i)rCUKC0b3j3G0iVBqAQfBiYdie0haf1O1SpMvKhAHZbM41rE5OdUJ82cHzWKEysYaIspYFiJcKrI8ezmjGk0Aqmgu47xlRAzQwviEGg0XgskozgO28R9GT5WjF80kkyG3CgTwAU2BHRuRfl1EW2C4KpEAffmWBoJwlTuQ94NSLmtiFOn1YqK)C5XbjviEGIIwFlQrRZymRip0cNdmXRJ8hYOazKiprgtcOcTgeJbfMUwARL93vl7wlrgtcOcTgeJbfmFIOdURLvThSnho5JNwrbd8MZO1slLAp(jBjZeYhAtKxo6G7iVTqygmPhMKmGO0JA06ReZkYlhDWDK)5epW5eDWDKhAHZbM41rnADoeZkYdTW5at86i)HmkqgjYBaU)7fEoXdCorhChiGTmnQ28R9IATyPwdW9FVWZjEGZj6G7asLdZ1slLAZ4DrE5OdUJ8pN4boNOdUthhincIA06CEmRip0cNdmXRJ8y)ipc0iVC0b3rEQczeohe5PkUpe5ZUwvCqRb0NtbY77bbOfohyQ1ILAZUw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwlwQ1G1GNqiyfc(2FNo(Ubi1sBT3QLvTmvlYhCUKkepqrHN0j8lXCpubuT5xBouRfl1MDThm2zW52bQspi6HVFTme5PkKul2qKNk0gqvjH(CkqEFpiDWTz0b3rnAn7mMvKhAHZbM41rESFKhbAKxo6G7ipvHmcNdI8uf3hI8zxRkoO1qpE0vKkoMbsaAHZbMATyP2SRvfh0AaYejT3FArHa0cNdm1AXsThm2zW52bitK0E)PffceWwMgvB(1ELAz3AVOwAUwvCqRbda(ajHuIOIhyhGw4CGjYtviPwSHipvOnGQsQhp6ksfhZajDWTz0b3rnADokMvKhAHZbM41rESFKhbAKxo6G7ipvHmcNdI8uf3hI8zxlKH(JVpycY9i6crqPhU1e(L8X5cKATyPw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwlwQ1aC)3lqK7XK0btexYaC)3lyW521AXsThm2zW52bbrNQ0akrK7XK0btexGa2Y0OAZV2B3vlRAzQ2dg7m4C7aI(qnqaBzAuT5x7TATyPwdW9FVaI(qn89RLHipvHKAXgI8uH2aQkPhU10b3MrhCh1O13UlMvKhAHZbM41r(dzuGmsKp7ArkioLoyceS3hQLvTgSgiFF9tGGohMN2Rww1MDTgG7)EbQqBavLW3Vww1sviJW5GavOnGQsc95uG8(Eq6GBZOdURLvTufYiCoiqfAdOQK6XJUIuXXmqshCBgDWDTSQLQqgHZbbQqBavL0d3A6GBZOdUJ8YrhCh5PcTbuvIA06B3Izf5Hw4CGjEDK)qgfiJe5vXbTgGmrs79NwuiaTW5atTSQvfh0AOhp6ksfhZajaTW5atTSQ9GT5WjF80kQwAPu7XpzlzMq(qBQLvThm2zW52bitK0E)PffceWwMgvB(1ElYlhDWDKNQ0dIEuJwF7IywrEOfohyIxh5pKrbYirEvCqRHE8ORivCmdKa0cNdm1YQ2SRvfh0AaYejT3FArHa0cNdm1YQ2d2MdN8XtROAPLsTh)KTKzc5dTPww1YuTgG7)EbQqBavLW3VwlwQfqiOpqG6GgCNWVKpqEWrhChGw4CGPwgI8YrhCh5Pk9GOh1O13yFmRip0cNdmXRJ8y)ipc0iVC0b3rEQczeohe5PkUpe5L7bYOqarNG)gWKq)3dFeDWDaAHZbMAzvlt124oHqjU)7bMKkepqr1slLAVvRfl1I8bNlPcXduu4jDc)sm3dvavlLAzFTmulRAzQwekX9FpWKuH4bkkjCyQqYxAdypNAPu7D1AXsTiFW5sQq8affEsNWVeZ9qfq1slLAZHAziYtviPwSHipcLOk9GONo42m6G7OgT(wgJzf5Hw4CGjEDKxo6G7iVpg7seaH)Kde5HmvIKeB8V1iFgVsK)HjPgYuJwFlQrRVDLywrEOfohyIxh5pKrbYirEvCqRb0NtbY77bbOfohyQLvTzxlsbXP0btGG9(qTSQ9GXodo3o4jecwHW3Vww1YuTufYiCoiGqjQspi6PdUnJo4UwlwQn7AL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzvlt1AWAWtieScbc8iaIUW5GATyPwdW9FVavOnGQs47xlRAnyn4jecwHGV93PJVBasT5tP2B1YqTmulRApyBoCYhpTIcg4nNrRLwk1YuTmv7TAzR2lQLMRvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHAP5Ar(GZLuH4bkk8KoHFjM7HkGQLHAPndxTzSww1sKXKaQqRbXyqHPRL2AVDrKxo6G7ipvPhe9OgT(woeZkYdTW5at86i)HmkqgjYZuTQ4Gwd2csbssqibHMoaTW5atTwSul53Wdt8GGTqyoHFjLoKSfKcKKGqccnDaYq)X3hm1YqTSQn7ArkioLoycIZvlRATfKcKKGqccnDIa2Y0OAZNsT3vlRAZUwdwdKVV(jqGapcGOlCoOww1AWAWtieScbcyltJQL2AzFTSQLPAna3)9cuH2aQkHVFTSQ1aC)3lGOpudF)Azvlt1MDTacb9bcCom2KWVKshsqd2xgSLmqysTwSuRb4(VxGZHXMe(Lu6qcAW(YW3VwgQ1ILAbec6deOoOb3j8l5dKhC0b3bOfohyQLHiVC0b3rEQspi6rnA9TCEmRip0cNdmXRJ8hYOazKiF21IuqCkDWeeNRww1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YQwdwdEcHGviqGhbq0fohulRAnyn4jecwHGV93PJVBasT5tP2B1YQ2d2MdN8XtROGbEZz0APLsT3I8YrhCh5r0fdoxBWzIA06BSZywrEOfohyIxh5pKrbYir(SRfPG4u6GjqWEFOww1YuTzxRbRbpHqWkeiWJai6cNdQLvTgSgiFF9tGabSLPr1sBTzSw2QnJ1sZ1E8t2sMjKp0MATyPwdwdKVV(jqGa2Y0OAP5AVlCLAPTwviEGg0XgskozgOwgQLvTQq8anOJnKuCYmqT0wBgJ8YrhCh5Hmrs79NwuiQrRVLJIzf5Hw4CGjEDK)qgfiJe5DavWvlTuQ9kSZAzvRbRbY3x)eiOZH5P9QLvTmvB21czO)47dMGCpIUqeu6HBnHFjFCUaPwlwQ9GXodo3oqfAdOQeiGTmnQwAR92D1YqKxo6G7ipI(qnQrRV4UywrEOfohyIxh5pKrbYirEU)7f4CySX9rAGaYrR1ILAna3)9cuH2aQkHVFKxo6G7iVpwhCh1O1xClMvKhAHZbM41r(dzuGmsK3aC)3lqfAdOQe((rE5OdUJ8Com2KEFYLrnA9fxeZkYdTW5at86i)HmkqgjYBaU)7fOcTbuvcF)iVC0b3rEoGGacZt7f1O1xW(ywrEOfohyIxh5pKrbYirEdW9FVavOnGQs47h5LJo4oY)gcW5WytuJwFrgJzf5Hw4CGjEDK)qgfiJe5na3)9cuH2aQkHVFKxo6G7iV0haPeXLoIZf1O1xCLywrEOfohyIxh5LJo4oY7jo4iohqqjomUJ8hYOazKipt1AaU)7fOcTbuvcF)ATyPwMQn7AvXbTgGmrs79NwuiaTW5atTSQ9GXodo3oqfAdOQeiGTmnQwARnJxPwlwQvfh0AaYejT3FArHa0cNdm1YQwMQ9GXodo3oazIK27pTOqGa2Y0OAZV2COwlwQ9GXodo3oazIK27pTOqGa2Y0OAPT2lURww1(gp6AIa2Y0OAPT2C4k1YqTmuld1YQ2SR1aC)3lq((6NabitK0E)Pffmr(wSHiVN4GJ4CabL4W4oQrRVihIzf5Hw4CGjEDKxo6G7iVGOtvAaLiY9ys6GjIlYFiJcKrI8gG7)EbICpMKoyI4sgG7)Ebdo3UwlwQvfIhObDSHKItMbQn)AV4UiFl2qKxq0PknGse5EmjDWeXf1O1xKZJzf5Hw4CGjEDKxo6G7iVGOtvAaLiY9ys6GjIlYFiJcKrI8mvB21QIdAnazIK27pTOqaAHZbMATyP2SRvfh0Aa95uG8(EqaAHZbMAzOww1AaU)7fOcTbuvceWwMgvlT1E7UAz3AZyT0CTqg6p((Gji3JOlebLE4wt4xYhNlqI8TydrEbrNQ0akrK7XK0btexuJwFb7mMvKhAHZbM41rE5OdUJ8cIovPbuIi3JjPdMiUi)HmkqgjYZuTQ4GwdqMiP9(tlkeGw4CGPww1QIdAnG(CkqEFpiaTW5atTmulRAna3)9cuH2aQkHVFTSQLPAna3)9cEcHGviazIK27pTOGPwlwQvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLvTgSg8ecbRqW3(70X3naPwAR9wTme5BXgI8cIovPbuIi3JjPdMiUOgT(ICumRip0cNdmXRJ8YrhCh5pxECyLG75K4CcsJ8hYOazKiVTGuGKeesqOPteWwMgvlLAVRww1MDTgG7)EbQqBavLW3Vww1MDTgG7)Ebe9HA47xlRA5(VxWgSXKlt4xY9pJjziGyJcgCUDTSQfAG4DzT5xl78UAzvRbRbY3x)eiqaBzAuT0wBgJ8W7bhn1Ine5pxECyLG75K4CcsJA0A2FxmRip0cNdmXRJ8YrhCh5DFcZabLMgnMb)rjV5Pr(dzuGmsK3aC)3lqfAdOQe((r(wSHiV7tygiO00OXm4pk5npnQrRz)TywrEOfohyIxh5LJo4oY7(iLG)OKh2zGo57(2Ihe5pKrbYirEdW9FVavOnGQs47h5BXgI8Upsj4pk5HDgOt(UVT4brnAn7ViMvKhAHZbM41rE5OdUJ8EoXmIIjOKnyeNBWDK)qgfiJe5na3)9cuH2aQkHVFKhEp4OPwSHiVNtmJOyckzdgX5gCh1O1SN9XSI8qlCoWeVoYlhDWDK3ZjMrumbL4eJhe5pKrbYirEdW9FVavOnGQs47h5H3doAQfBiY75eZikMGsCIXdIA0A2NXywrE5OdUJ8FeKgfSrrEOfohyIxh1Og5nynMv06BXSI8qlCoWeVoYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qK3NmyYOxMiyv0b31YQwKp4CjviEGIcpPt4xI5EOcOAPTw2xlRAzQwdwdEcHGviqaBzAuT5x7bJDgCUDWtieScbZNi6G7ATyPwF8GWnysCoamOAPT2RuldrEQcj1Ine5rmp(PZLhhK8ecbRquJwFrmRip0cNdmXRJ8y)ipc0iVC0b3rEQczeohe5PkUpe59jdMm6LjcwfDWDTSQf5doxsfIhOOWt6e(LyUhQaQwARL91YQwMQ1aC)3lGOpudF)ATyPwMQ1hpiCdMeNdadQwAR9k1YQ2SRvUhiJcb0bAnHFjohgBcqlCoWuld1YqKNQqsTydrEeZJF6C5XbjY3x)eiQrRzFmRip0cNdmXRJ8y)ipc0iVC0b3rEQczeohe5PkUpe5na3)9cuH2aQkHVFTSQLPAna3)9ci6d1W3VwlwQ1wqkqsccji00jcyltJQL2AVRwgQLvTgSgiFF9tGabSLPr1sBTxe5PkKul2qKhX84NiFF9tGOgToJXSI8qlCoWeVoYFiJcKrI8Q4GwdqMiP9(tlkeGw4CGPww1MDTgG7)EbpHqWkeGmrs79NwuWulRAnyn4jecwHGV93PJVBasT5tP2B1YQ2dg7m4C7aKjsAV)0IcbcyltJQn)AVOww1I8bNlPcXduu4jDc)sm3dvavlLAVvlRAjYysavO1GymOW01sBT5qTSQ1G1GNqiyfceWwMgvlnx7DHRuB(1QcXd0Go2qsXjZarE5OdUJ8EcHGviQrRVsmRip0cNdmXRJ8hYOazKiVkoO1aKjsAV)0IcbOfohyQLvTmv7bBZHt(4PvuT0sP2JFYwYmH8H2ulRApySZGZTdqMiP9(tlkeiGTmnQ28R9wTSQ1G1a57RFceiGTmnQwAU27cxP28RvfIhObDSHKItMbQLHiVC0b3rEY3x)eiQrRZHywrEOfohyIxh5FysQHm1O13I8YrhCh59XyxIai8NCGOgToNhZkYdTW5at86i)HmkqgjYtGhbq0fohulRApyBoCYhpTIcg4nNrRLwk1ERw2QL91sZ1YuTY9azuiGOtWFdysO)7HpIo4oaTW5atTSQ9GXodo3oqv6brp89RLHAzvlt16B)D647gGuB(uQ9wTwSulbSLPr1MpLA15WCshBOww1I8bNlPcXduu4jDc)sm3dvavlTuQL91YwTY9azuiGOtWFdysO)7HpIo4oaTW5atTmulRAzQ2SRfYejT3FArbtTwSulbSLPr1MpLA15WCshBOwAU2lQLvTiFW5sQq8affEsNWVeZ9qfq1slLAzFTSvRCpqgfci6e83aMe6)E4JOdUdqlCoWuld1YQ2SRfHsC)3dm1YQwMQvfIhObDSHKItMbQLDRLa2Y0OAzOwARnJ1YQwMQ1wqkqsccji00jcyltJQLsT3vRfl1MDT6CyEAVAzvRCpqgfci6e83aMe6)E4JOdUdqlCoWuldrE5OdUJ8EcHGviQrRzNXSI8qlCoWeVoY)WKudzQrRVf5LJo4oY7JXUebq4p5arnADokMvKhAHZbM41rE5OdUJ8EcHGviYFiJcKrI8zxlvHmcNdciMh)05YJdsEcHGvOww1sGhbq0fohulRApyBoCYhpTIcg4nNrRLwk1ERw2QL91sZ1YuTY9azuiGOtWFdysO)7HpIo4oaTW5atTSQ9GXodo3oqv6brp89RLHAzvlt16B)D647gGuB(uQ9wTwSulbSLPr1MpLA15WCshBOww1I8bNlPcXduu4jDc)sm3dvavlTuQL91YwTY9azuiGOtWFdysO)7HpIo4oaTW5atTmulRAzQ2SRfYejT3FArbtTwSulbSLPr1MpLA15WCshBOwAU2lQLvTiFW5sQq8affEsNWVeZ9qfq1slLAzFTSvRCpqgfci6e83aMe6)E4JOdUdqlCoWuld1YQ2SRfHsC)3dm1YQwMQvfIhObDSHKItMbQLDRLa2Y0OAzOwAR92f1YQwMQ1wqkqsccji00jcyltJQLsT3vRfl1MDT6CyEAVAzvRCpqgfci6e83aMe6)E4JOdUdqlCoWuldr(ZLhhKuH4bkkA9TOgT(2DXSI8qlCoWeVoYFiJcKrI8iFW5sQq8afvlTuQ9IAzvlbSLPr1MFTxulB1YuTiFW5sQq8afvlTuQ9k1YqTSQ9GT5WjF80kQwAPuBgJ8YrhCh5pKXgH7Kc2(asJA06B3Izf5Hw4CGjEDK)qgfiJe5ZUwQczeoheqmp(jY3x)eOww1YuThSnho5JNwr1slLAZyTSQLapcGOlCoOwlwQn7A15W80E1YQwMQvhBOwAR92D1AXsThSnho5JNwr1slLAVOwgQLHAzvlt16B)D647gGuB(uQ9wTwSulbSLPr1MpLA15WCshBOww1I8bNlPcXduu4jDc)sm3dvavlTuQL91YwTY9azuiGOtWFdysO)7HpIo4oaTW5atTmulRAzQ2SRfYejT3FArbtTwSulbSLPr1MpLA15WCshBOwAU2lQLvTiFW5sQq8affEsNWVeZ9qfq1slLAzFTSvRCpqgfci6e83aMe6)E4JOdUdqlCoWuld1YQwviEGg0XgskozgOw2TwcyltJQL2AZyKxo6G7ip57RFce1O13UiMvKhAHZbM41rE5OdUJ8KVV(jqK)qgfiJe5ZUwQczeoheqmp(PZLhhKiFF9tGAzvB21sviJW5GaI5Xpr((6Na1YQ2d2MdN8XtROAPLsTzSww1sGhbq0fohulRAzQwF7VthF3aKAZNsT3Q1ILAjGTmnQ28PuRohMt6yd1YQwKp4CjviEGIcpPt4xI5EOcOAPLsTSVw2QvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHAzvlt1MDTqMiP9(tlkyQ1ILAjGTmnQ28PuRohMt6yd1sZ1ErTSQf5doxsfIhOOWt6e(LyUhQaQwAPul7RLTAL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzOww1QcXd0Go2qsXjZa1YU1saBzAuT0wBgJ8NlpoiPcXduu06BrnA9n2hZkYdTW5at86i)HmkqgjYJ8bNlPcXduuTuQ9wTSQ9GT5WjF80kQwAPult1E8t2sMjKp0MAz3AVvld1YQwc8iaIUW5GAzvB21czIK27pTOGPww1MDTgG7)Ebe9HA47xlRATfKcKKGqccnDIa2Y0OAPu7D1YQ2SRvUhiJcbn3bPjLoKyUNheGw4CGPww1QcXd0Go2qsXjZa1YU1saBzAuT0wBgJ8YrhCh5pKXgH7Kc2(asJA06BzmMvKxo6G7ipc8rdkYdTW5at86Og1Og5Pce0G7O1xC3f3D7UBSpYNRq6P9qrE2H0yAO1zawFvPr1wBw0HAhBFmrR9Hj1Mtacb9bq5uTeid9hcyQfHTHALVITffm1EOlThGcfJxLPHAVGgv7vJBQarbtT5eKjsAV)0IcMa7yovRIRnNma3)9cSJbitK0E)Pffm5uTmDltgcfJxLPHAZinQ2Rg3ubIcMA5h7RUw0LTkzwln4AvCTxLVuRzOoOb31I9bIOysTmLhd1Y0fzYqOySyKDinMgADgG1xvAuT1MfDO2X2ht0AFysT5KbEY3P5uTeid9hcyQfHTHALVITffm1EOlThGcfJxLPHAzpnQ2Rg3ubIcMA5h7RUw0LTkzwln4AvCTxLVuRzOoOb31I9bIOysTmLhd1Y0TmziumwmYoKgtdTodW6RknQ2AZIou7y7JjATpmP2C6yq5uTeid9hcyQfHTHALVITffm1EOlThGcfJxLPHAZr0OAVACtfikyQnNuY0mdAGDmCWyNbNBNt1Q4AZPdg7m4C7a7yovlt3YKHqX4vzAO2lUcnQ2Rg3ubIcMAZjitK0E)Pffmb2XCQwfxBozaU)7fyhdqMiP9(tlkyYPAz6wMmekgVktd1Eb7Kgv7vJBQarbtT5eKjsAV)0IcMa7yovRIRnNma3)9cSJbitK0E)Pffm5uTmDltgcfJfJSdPX0qRZaS(QsJQT2SOd1o2(yIw7dtQnNmynNQLazO)qatTiSnuR8vSTOGP2dDP9auOy8QmnuBgPr1E14MkquWuBobzIK27pTOGjWoMt1Q4AZjdW9FVa7yaYejT3FArbtovlt3YKHqXyXygGTpMOGP2CETYrhCxRBqkkumg59j434GipnvlngHeeAArhCxlne79HIrAQ2m8okMdi1ElhSQ2lU7I7kglgPPAZGzcNVcMA5GhMa1EW2CIwlh4nnkuln(CaFfvBJB2LUqSFFxTYrhCJQf3UldfJYrhCJc(e4GT5eLI477Um5JheUlgLJo4gf8jWbBZjkBuYZwimdM0dtsgqu6w5tGd2Mt0eco42GOCfRMhfImMeqfAnigdkmnT3UsXOC0b3OGpboyBorzJsEifeNsVyuo6GBuWNahSnNOSrjpKBoqsAtYmhWkFcCW2CIMqWb3geLBwnpke4raeDHZbfJYrhCJc(e4GT5eLnk59rqAuW2QwSbkY9i6crqPhU1e(L8X5cKIr5OdUrbFcCW2CIYgL88(cXmsNWVKCpqWkDRMhfvCqRbitK0E)PffcqlCoWumwmst1MbZeoFfm1cubYL1QJnuRshQvokMu7GQvOkJt4CqOyuo6GBefMNdZfJ0uT0qaPG4u61oVA9Xi0W5GAzQX1s97AGiCoOwOb7bq1oDThSnNOmumkhDWnInk5HuqCk9Ir5OdUrSrjpQczeohyvl2afObI3Ljc4bD6GT5MgmwrvCFGc0aX7Yab8GMnF8GWnysCoamiAoNtdMPlOzKp4Cj6csbgkgLJo4gXgL8OkKr4CGvTyduqt75GKkepqTIQ4(afKp4CjviEGIcpPt4xI5EOcO8VOyuo6GBeBuY7ioxso6G7KBqQvTyduqkioLoySAEuqkioLoyceS3hkgLJo4gXgL8oIZLKJo4o5gKAvl2aLJbz18OWu2Q4Gwd2csbssqibHMoaTW5aJflgSg8ecbRqqNdZt7XqXOC0b3i2OK3rCUKC0b3j3GuRAXgOyWAXOC0b3i2OKhYnhijTjzMdy18OW9FVaYnhijTjzMdeiGTmnkFviEGg0XgskozgGf3)9ci3CGK0MKzoqGa2Y0O8z6gBhSnho5JNwrmqZ3cSZIr5OdUrSrjVJ4Cj5OdUtUbPw1InqXme4OfJYrhCJyJsEc5inKumHaTA18Oanq8UmyG3CgLwk3UcBufYiCoianq8UmrapOthSn30GPyuo6GBeBuYtihPHK)3HGIr5OdUrSrjp34rxrPmqFJNn0AXOC0b3i2OKhN4LWVKsMdZOIXIrAQ2RgJDgCUnQyuo6GBu4yqu(iinkyBvl2af5EeDHiO0d3Ac)s(4CbIvZJs2ifeNshmbX5yzlifijbHeeA6ebSLPruUJfthm2zW52bQqBavLabSLPr5NHJPdg7m4C7aI(qnqaBzAendzO)47dMGGOtvAaLiY9ys6GjIJbgY)2DSD7oAgYq)X3hmbbrNQ0akrK7XK0btehRSna3)9cuH2aQkHVpRSna3)9ci6d1W3Vyuo6GBu4yqSrjVJ4Cj5OdUtUbPw1InqbqiOpaYQ5rjBKcItPdMG4CSmynq((6NabDompThlBbPajjiKGqtNiGTmnIYDfJ0uTzaVAfJbvRqGA)(wvlQhFOwLoulUHAZDu616W5ciT2SYIgiulniiO2CPdDTMlN2R2NGuGuRsx6AV6CwTg4nNrRftQn3rPJ)ATsFzTxDolumkhDWnkCmi2OKNTqygmPhMKmGO0T6C5XbjviEGIOCZQ5rHiJjbuHwdIXGcFFwmPcXd0Go2qsXjZa5FW2C4KpEAffmWBoJsZ3cxXILd2MdN8XtROGbEZzuAPC8t2sMjKp0ggkgPPAZaE124AfJbvBUJZvRzGAZDu6txRshQTHm1Az)DiRQ9JGAZWE0a1I7A5WiuT5okD8xRv6lR9QZzHIr5OdUrHJbXgL8SfcZGj9WKKbeLUvZJcrgtcOcTgeJbfMMw2Fh7sKXKaQqRbXyqbZNi6GBwhSnho5JNwrbd8MZO0s54NSLmtiFOnfJYrhCJchdInk59CIh4CIo4Uyuo6GBu4yqSrjVNt8aNt0b3PJdKgbwnpkgG7)EHNt8aNt0b3bcyltJY)clwma3)9cpN4boNOdUdivomtlLmExXinvBogAdOQuRd7nhXv7b3MrhClouTCccm1I7ApFcbATwKpCkgLJo4gfogeBuYJQqgHZbw1InqHk0gqvjH(CkqEFpiDWTz0b3wrvCFGs2Q4GwdOpNcK33dcqlCoWyXs2Y9azuiGOtWFdysO)7HpIo4oaTW5aJflgSg8ecbRqW3(70X3naH2BSyc5doxsfIhOOWt6e(LyUhQak)CWILSpySZGZTduLEq0dFFgkgLJo4gfogeBuYJQqgHZbw1InqHk0gqvj1JhDfPIJzGKo42m6GBROkUpqjBvCqRHE8ORivCmdKa0cNdmwSKTkoO1aKjsAV)0IcbOfohySy5GXodo3oazIK27pTOqGa2Y0O8Vc7EbnRIdAnyaWhijKsev8a7a0cNdmfJYrhCJchdInk5rviJW5aRAXgOqviJW5aRAXgOqfAdOQKE4wthCBgDWTvuf3hOKnKH(JVpycY9i6crqPhU1e(L8X5celwK7bYOqarNG)gWKq)3dFeDWDaAHZbglwma3)9ce5EmjDWeXLma3)9cgCUTflkzAMbnii6uLgqjICpMKoyI4chm2zW52bcyltJY)2DSy6GXodo3oGOpudeWwMgL)nlwma3)9ci6d1W3NHIr5OdUrHJbXgL8OcTbuvSAEuYgPG4u6GjqWEFGLbRbY3x)eiOZH5P9yLTb4(VxGk0gqvj89zrviJW5GavOnGQsc95uG8(Eq6GBZOdUzrviJW5GavOnGQsQhp6ksfhZajDWTz0b3SOkKr4CqGk0gqvj9WTMo42m6G7IrAQ2CS0dIET5ok9AZGzI8QLTATE8ORivCmdeAuTzysMJ93U2RoNvR0MAZGzI8QLaI5YAFysTnKPw7v9QPbkgLJo4gfogeBuYJQ0dIUvZJIkoO1aKjsAV)0IcbOfohyyPIdAn0JhDfPIJzGeGw4CGH1bBZHt(4PveTuo(jBjZeYhAdRdg7m4C7aKjsAV)0IcbcyltJY)wXinvBow6brV2ChLETwpE0vKkoMbsTSvR14AZGzI8Or1MHjzo2F7AV6CwTsBQnhdTbuvQ97xlt)2biuTF00E1MJX5mgkgLJo4gfogeBuYJQ0dIUvZJIkoO1qpE0vKkoMbsaAHZbgwzRIdAnazIK27pTOqaAHZbgwhSnho5JNwr0s54NSLmtiFOnSyYaC)3lqfAdOQe((wSaie0hiqDqdUt4xYhip4OdUdqlCoWWqXinvlpa1((oxThSTn0AT4Uw6Q6JOr5LN3O0)CHd2opAOqfA6yNrz3SU68OHyVpKxUdZtE0yesqOPfDWn7sJZzxf2Lgciqih6HIr5OdUrHJbXgL8OkKr4CGvTyduqOevPhe90b3MrhCBfvX9bkY9azuiGOtWFdysO)7HpIo4oaTW5adlMACNqOe3)9atsfIhOiAPCZIfKp4CjviEGIcpPt4xI5EOcikSNbwmHqjU)7bMKkepqrjHdtfs(sBa75q5olwq(GZLuH4bkk8KoHFjM7HkGOLsoWqXOC0b3OWXGyJsE(ySlrae(toGvpmj1qMkLBwbzQejj24FRuY4vkgLJo4gfogeBuYJQ0dIUvZJIkoO1a6ZPa599Ga0cNdmSYgPG4u6GjqWEFG1bJDgCUDWtieScHVplMOkKr4CqaHsuLEq0thCBgDWTflzl3dKrHaIob)nGjH(Vh(i6G7a0cNdmSyYG1GNqiyfce4raeDHZbwSyaU)7fOcTbuvcFFwgSg8ecbRqW3(70X3najFk3yGbwhSnho5JNwrbd8MZO0sHjMUX2f0SCpqgfci6e83aMe6)E4JOdUdqlCoWWanJ8bNlPcXduu4jDc)sm3dvaXaTz4YilImMeqfAnigdkmnT3UOyKMQnhl9GOxBUJsV2mmbPaPwAmcjOPPr1AnUwKcItPxR0MABCTYrhQqTzy04A5(VNv1sd)(6Na12yT2PRLapcGOxlrApWQAnFY0E1MJH2aQkSL11SDnwZG1Y0VDacv7hnTxT5yCoJHIr5OdUrHJbXgL8Ok9GOB18OWKkoO1GTGuGKeesqOPdqlCoWyXc53Wdt8GGTqyoHFjLoKSfKcKKGqccnDaYq)X3hmmWkBKcItPdMG4CSSfKcKKGqccnDIa2Y0O8PChRSnynq((6Nabc8iaIUW5awgSg8ecbRqGa2Y0iAzplMma3)9cuH2aQkHVpldW9FVaI(qn89zXu2acb9bcCom2KWVKshsqd2xgSLmqyIflgG7)EbohgBs4xsPdjOb7ldFFgSybqiOpqG6GgCNWVKpqEWrhChGw4CGHHIrAQwE6IbNRn4m1(WKA5PtWFdyQL))E4JOdUlgLJo4gfogeBuYdrxm4CTbNXQ5rjBKcItPdMG4CSK7bYOqarNG)gWKq)3dFeDWDaAHZbgwgSg8ecbRqGapcGOlCoGLbRbpHqWke8T)oD8DdqYNYnwhSnho5JNwrbd8MZO0s5wXinvBgmtK0E)PffQnx6qxBJ1ArkioLoyQvAtTCyLET0WVV(jqTsBQ9QkecwHAfcu73V2hMuRd3E1cn(7rpumkhDWnkCmi2OKhKjsAV)0IcwnpkzJuqCkDWeiyVpWIPSnyn4jecwHabEearx4CaldwdKVV(jqGa2Y0iAZiBzKMp(jBjZeYhAJflgSgiFF9tGabSLPr08DHRqRkepqd6ydjfNmdWalviEGg0XgskozgG2mwmkhDWnkCmi2OKhI(q1Q5rXbubhTuUc7KLbRbY3x)eiOZH5P9yXu2qg6p((Gji3JOlebLE4wt4xYhNlqSy5GXodo3oqfAdOQeiGTmnI2B3XqXOC0b3OWXGyJsE(yDWTvZJc3)9cCom24(inqa5OwSyaU)7fOcTbuvcF)Ir5OdUrHJbXgL84CySj9(KlTAEuma3)9cuH2aQkHVFXOC0b3OWXGyJsECabbeMN2ZQ5rXaC)3lqfAdOQe((fJYrhCJchdInk59gcW5WyJvZJIb4(VxGk0gqvj89lgLJo4gfogeBuYt6dGuI4shX5SAEuma3)9cuH2aQkHVFXOC0b3OWXGyJsEFeKgfSTQfBGIN4GJ4CabL4W42Q5rHjdW9FVavOnGQs47BXctzRIdAnazIK27pTOqaAHZbgwhm2zW52bQqBavLabSLPr0MXRyXIkoO1aKjsAV)0IcbOfohyyX0bJDgCUDaYejT3FArHabSLPr5NdwSCWyNbNBhGmrs79NwuiqaBzAeTxChR34rxteWwMgrBoCfgyGbwzdzIK27pTOGjq((6NafJYrhCJchdInk59rqAuW2QwSbkcIovPbuIi3JjPdMioRMhfdW9FVarUhtshmrCjdW9FVGbNBBXIkepqd6ydjfNmdK)f3vmkhDWnkCmi2OK3hbPrbBRAXgOii6uLgqjICpMKoyI4SAEuykBvCqRbitK0E)PffcqlCoWyXs2Q4GwdOpNcK33dcqlCoWWaldW9FVavOnGQsGa2Y0iAVDh7MrAgYq)X3hmb5EeDHiO0d3Ac)s(4CbsXOC0b3OWXGyJsEFeKgfSTQfBGIGOtvAaLiY9ys6GjIZQ5rHjvCqRbitK0E)PffcqlCoWWsfh0Aa95uG8(EqaAHZbggyzaU)7fOcTbuvcFFwmbzIK27pTOGj4jecwblwK7bYOqarNG)gWKq)3dFeDWDaAHZbgwgSg8ecbRqW3(70X3naH2BmumkhDWnkCmi2OK3hbPrbBRG3doAQfBGY5YJdReCpNeNtqQvZJITGuGKeesqOPteWwMgr5owzBaU)7fOcTbuvcFFwzBaU)7fq0hQHVplU)7fSbBm5Ye(LC)Zysgci2OGbNBZcAG4Dz(SZ7yzWAG891pbceWwMgrBglgLJo4gfogeBuY7JG0OGTvTyduCFcZabLMgnMb)rjV5PwnpkgG7)EbQqBavLW3Vyuo6GBu4yqSrjVpcsJc2w1InqX9rkb)rjpSZaDY39TfpWQ5rXaC)3lqfAdOQe((fJYrhCJchdInk59rqAuW2k49GJMAXgO45eZikMGs2GrCUb3wnpkgG7)EbQqBavLW3Vyuo6GBu4yqSrjVpcsJc2wbVhC0ul2afpNygrXeuItmEGvZJIb4(VxGk0gqvj89lgPPAPbGN8DATpX54KdZ1(WKA)iHZb1okyJOr1sdccQf31EWyNbNBhkgLJo4gfogeBuY7JG0OGnQySyKMQLgyiWrR1i2IhuRWnUrhavmst1MbBQqJTRv0AZiB1Y0vyR2ChLET0a8mu7vNZc1MbyBdMruWDzT4U2lyRwviEGISQ2ChLET5yOnGQIv1Ij1M7O0RnRRZWVwSshi5oiO2CLrR9Hj1IW2qTqdeVld1sJDiCT5kJw78QndMjYR2d2Mdx7GQ9GTN2R2VFOyuo6GBuWme4OuGMk0yBRMhfMoyBoCYhpTIOLsgztfh0AWaGpqsiLiQ4b2bOfohySy5GT5WjF80kII0JTCOlepWKo(mWIjdW9FVavOnGQs47BXIb4(VxarFOg((wSanq8UmyG3CgnFkxCf2OkKr4CqaAG4DzIaEqNoyBUPbJflztviJW5GaAAphKuH4bkdSykBvCqRbitK0E)PffcqlCoWyXYbJDgCUDaYejT3FArHabSLPr0EbdfJYrhCJcMHahLnk5rviJW5aRAXgO8rq6nohqSIQ4(aLd2MdN8XtROGbEZzuAVzXc0aX7YGbEZz08PCXvyJQqgHZbbObI3Ljc4bD6GT5MgmwSKnvHmcNdcOP9CqsfIhOfJYrhCJcMHahLnk5HacruWK4WnKq(dZGvNlpoiPcXdueLBwnpkzBWAabeIOGjXHBiH8hMHGohMN2ZIfQczeohe(ii9gNdiSyso6qfsqd2dGOCJfrgtcOcTgeJbfMM2335se4qxiEqshBWILdDH4biAVGLkepqd6ydjfNmdK)vyOyKMQLD4O0RndEOJN2R2RDIbqwvBgyPRf)QLDqpubuTIw7fSvRkepqrwvlMul7z3mYwTQq8afvBU0HU2Cm0gqvP2bv73Vyuo6GBuWme4OSrjVN0j8lXCpubKvZJcvHmcNdcFeKEJZbewY9azuiah64P9sCoXaOa0cNdmSq(GZLuH4bkk8KoHFjM7HkGOLYfSXKb4(VxGk0gqvj89PzMUXgtY9azuiah64P9sCoXaOarAMPCJbgyOyKMQndS01IF1YoOhQaQwrR9woITArQCygvl(vlnOJXaDTx7edGQftQv8KPrATzKTAz6kSvBUJsVwAa8NZb1sdGrad1QcXduuOyuo6GBuWme4OSrjVN0j8lXCpubKvZJcvHmcNdcFeKEJZbewmX9FVa9XyGoX5edGcivomtlLB5ilwykBFYGjJEzIGvrhCZc5doxsfIhOOWt6e(LyUhQaIwkzKnMK7bYOqWG)CoizWiiqKMzAVGb2qkioLoyceS3hyGHIrAQ2mWsxl(vl7GEOcOAvCTIVV7YAPbaX4US2CgEq4U25v70YrhQqT4UwPVSwviEGwRO1Y(AvH4bkkumkhDWnkygcCu2OK3t6e(LyUhQaYQZLhhKuH4bkIYnRMhfQczeohe(ii9gNdiSq(GZLuH4bkk8KoHFjM7HkGOLc7lgLJo4gfmdbokBuYdo0Xt7LiGpzSL2y18OqviJW5GWhbP34CaPyuo6GBuWme4OSrjpXM7JOB18OqviJW5GWhbP34CaPyKMQnlHJDZW(64efQvX1k((UlRLgaeJ7YAZz4bH7AfT2lQvfIhOOIr5OdUrbZqGJYgL8S)64efS6C5XbjviEGIOCZQ5rHQqgHZbHpcsVX5aclKp4CjviEGIcpPt4xI5EOcikxumkhDWnkygcCu2OKN9xhNOGvZJcvHmcNdcFeKEJZbKIXIrAQwAaXw8GAXubsT6yd1kCJB0bqfJ0uTxLXE0AVQcHGvavlURTXn76tgBIqUSwviEGIQ9Hj1Q0HA9jdMm6L1sWQOdURDE1Ef2QLZbGbvRqGAfhbeZL1(9lgLJo4gfmyLcvHmcNdSQfBGcI5XpDU84GKNqiyfSIQ4(afFYGjJEzIGvrhCZc5doxsfIhOOWt6e(LyUhQaIw2ZIjdwdEcHGviqaBzAu(hm2zW52bpHqWkemFIOdUTyXhpiCdMeNdadI2RWqXinv7vzShTwA43x)eavlURTXn76tgBIqUSwviEGIQ9Hj1Q0HA9jdMm6L1sWQOdURDE1Ef2QLZbGbvRqGAfhbeZL1(9lgLJo4gfmyLnk5rviJW5aRAXgOGyE8tNlpoir((6NawrvCFGIpzWKrVmrWQOdUzH8bNlPcXduu4jDc)sm3dvarl7zXKb4(VxarFOg((wSWKpEq4gmjohageTxHv2Y9azuiGoqRj8lX5WytaAHZbggyOyKMQ9Qm2Jwln87RFcGQDE1MJH2aQkSXtFOMxgMGuGulngHeeA6AhuTF)AL2uBUqT0fQqTxWwTi4GBdQwh80AXDTkDOwA43x)eOwAaCwfJYrhCJcgSYgL8OkKr4CGvTyduqmp(jY3x)eWkQI7duma3)9cuH2aQkHVplMma3)9ci6d1W33IfBbPajjiKGqtNiGTmnI27yGLbRbY3x)eiqaBzAeTxumst1Y7dNrC1EvfcbRqTsBQLg(91pbQfb63VwFYGj1Q4AZGzIK27pTOqThbPfJYrhCJcgSYgL88ecbRGvZJIkoO1aKjsAV)0IcbOfohyyLnKjsAV)0IcMGNqiyfyzWAWtieScbF7VthF3aK8PCJ1bJDgCUDaYejT3FArHabSLPr5FblKp4CjviEGIcpPt4xI5EOcik3yrKXKaQqRbXyqHPPnhyzWAWtieScbcyltJO57cxjFviEGg0XgskozgOyuo6GBuWGv2OKh57RFcy18OOIdAnazIK27pTOqaAHZbgwmDW2C4KpEAfrlLJFYwYmH8H2W6GXodo3oazIK27pTOqGa2Y0O8VXYG1a57RFceiGTmnIMVlCL8vH4bAqhBiP4KzagkgPPAVQcHGvO2VpZa4BvTIdHRvjdGQvX1(rqTJwRGQvQf5dNrC16bnqeftQ9Hj1Q0HADcsR9QZz1YbpmbQvQ9n9GOdKIr5OdUrbdwzJsE(ySlrae(toGvpmj1qMkLBfJYrhCJcgSYgL88ecbRGvZJcbEearx4CaRd2MdN8XtROGbEZzuAPCJn2tZmj3dKrHaIob)nGjH(Vh(i6G7a0cNdmSoySZGZTduLEq0dFFgyXKV93PJVBas(uUzXcbSLPr5trNdZjDSbwiFW5sQq8affEsNWVeZ9qfq0sH9Sj3dKrHaIob)nGjH(Vh(i6G7a0cNdmmWIPSHmrs79NwuWyXcbSLPr5trNdZjDSbA(cwiFW5sQq8affEsNWVeZ9qfq0sH9Sj3dKrHaIob)nGjH(Vh(i6G7a0cNdmmWkBekX9FpWWIjviEGg0XgskozgGDjGTmnIbAZilMSfKcKKGqccnDIa2Y0ik3zXs26CyEApwY9azuiGOtWFdysO)7HpIo4oaTW5addfJYrhCJcgSYgL88XyxIai8NCaREysQHmvk3kgLJo4gfmyLnk55jecwbRoxECqsfIhOik3SAEuYMQqgHZbbeZJF6C5XbjpHqWkWIapcGOlCoG1bBZHt(4PvuWaV5mkTuUXg7PzMK7bYOqarNG)gWKq)3dFeDWDaAHZbgwhm2zW52bQspi6HVpdSyY3(70X3najFk3SyHa2Y0O8POZH5Ko2alKp4CjviEGIcpPt4xI5EOciAPWE2K7bYOqarNG)gWKq)3dFeDWDaAHZbggyXu2qMiP9(tlkySyHa2Y0O8POZH5Ko2anFblKp4CjviEGIcpPt4xI5EOciAPWE2K7bYOqarNG)gWKq)3dFeDWDaAHZbggyLncL4(VhyyXKkepqd6ydjfNmdWUeWwMgXaT3UGft2csbssqibHMoraBzAeL7SyjBDompThl5EGmkeq0j4Vbmj0)9WhrhChGw4CGHHIrAQ2RMm2iCxBwGTpG0AXDT2FNo(oOwviEGIQv0AZiB1E15SAZLo01s(DpTxT4Vw701EbQwM((1Q4AZyTQq8afXqTysTShvltxHTAvH4bkIHIr5OdUrbdwzJsEhYyJWDsbBFaPwnpkiFW5sQq8afrlLlyraBzAu(xWgtiFW5sQq8afrlLRWaRd2MdN8XtRiAPKXIrAQw2ba4x73VwA43x)eOwrRnJSvlURvCUAvH4bkQwMYLo016gQt7vRd3E1cn(7rVwPn12yTwul(i6yLHIr5OdUrbdwzJsEKVV(jGvZJs2ufYiCoiGyE8tKVV(jalMoyBoCYhpTIOLsgzrGhbq0fohyXs26CyEApwmPJnq7T7Sy5GT5WjF80kIwkxWadSyY3(70X3najFk3SyHa2Y0O8POZH5Ko2alKp4CjviEGIcpPt4xI5EOciAPWE2K7bYOqarNG)gWKq)3dFeDWDaAHZbggyXu2qMiP9(tlkySyHa2Y0O8POZH5Ko2anFblKp4CjviEGIcpPt4xI5EOciAPWE2K7bYOqarNG)gWKq)3dFeDWDaAHZbggyPcXd0Go2qsXjZaSlbSLPr0MXIr5OdUrbdwzJsEKVV(jGvNlpoiPcXdueLBwnpkztviJW5GaI5XpDU84Ge57RFcWkBQczeoheqmp(jY3x)eG1bBZHt(4PveTuYilc8iaIUW5awm5B)D647gGKpLBwSqaBzAu(u05WCshBGfYhCUKkepqrHN0j8lXCpubeTuypBY9azuiGOtWFdysO)7HpIo4oaTW5addSykBitK0E)PffmwSqaBzAu(u05WCshBGMVGfYhCUKkepqrHN0j8lXCpubeTuypBY9azuiGOtWFdysO)7HpIo4oaTW5addSuH4bAqhBiP4Kza2La2Y0iAZyXinv7vtgBeURnlW2hqAT4Uw(SQDE1oDT(sBa75uR0MAhT2ChNRwdUwhGq1AeBXdQvPlDTzWMk0y7AnFOwfxBwxNxggnoVSu2bfJYrhCJcgSYgL8oKXgH7Kc2(asTAEuq(GZLuH4bkIYnwhSnho5JNwr0sHPJFYwYmH8H2WU3yGfbEearx4CaRSHmrs79NwuWWkBdW9FVaI(qn89zzlifijbHeeA6ebSLPruUJv2Y9azuiO5oinP0HeZ98Ga0cNdmSuH4bAqhBiP4Kza2La2Y0iAZyXOC0b3OGbRSrjpe4JguXyXinvBgeHG(aOIr5OdUrbaHG(aikhCFGwjIcM0Zj2GvZJc0aX7YGo2qsXjBjtAVXkBdW9FVavOnGQs47ZIPSnynCW9bALikyspNydjUpPd6CyEApwzlhDWD4G7d0kruWKEoXgctNEUXJUAXY77CjcCOlepiPJnKV3XeSLmzOyKMQLg7YvUev7hb1ETdJn1M7O0RnhdTbuvQ97hQLguSZu7dtQndMjsAV)0IcHAPbbb1M7O0RnRRR97xlh8WeOwP230dIoqQvq16WTxTcQ2rRL8BuTpmP2B3HQ18jt7vBogAdOQekgLJo4gfaec6dGyJsECom2KWVKshsqd2xA18OyaU)7fOcTbuvcFFwmbzIK27pTOGj4jecwblwma3)9ci6d1W3N1bBZHt(4PvuWaV5mA(uUzXIb4(VxGk0gqvjqaBzAu(uUDhdwS8gp6AIa2Y0O8PC7UIrAQwASQGTVwRIRvCJxx7v9leZiDT5ok9AZXqBavLAfuToC7vRGQD0AZf35KwlbqFNw7016WOP9QvQ99Do2LQ4(qThbP1IPcKAv6qTeWwMEAVAnFIOdURf)QvPd1(gp6AXOC0b3OaGqqFaeBuYZ7leZiDc)sY9abR0TAEuoySZGZTduH2aQkbcyltJYN9wSyaU)7fOcTbuvcFFlwEJhDnraBzAu(S)UIr5OdUrbaHG(ai2OKN3xiMr6e(LK7bcwPB18O8CymHjMEJhDnraBzAe7Y(7yGg8bJDgCUnd0(CymHjMEJhDnraBzAe7Y(7y3dg7m4C7avOnGQsGa2Y0igObFWyNbNBZqXOC0b3OaGqqFaeBuY7HpFeysY9azuiXbITvZJcYhCUKkepqrHN0j8lXCpubeTuUWIfImMeqfAnigdkmnT5WDSGgiExMFo)UIr5OdUrbaHG(ai2OKN)NmVlN2lX5eKA18OG8bNlPcXduu4jDc)sm3dvarlLlSyHiJjbuHwdIXGcttBoCxXOC0b3OaGqqFaeBuYtPdPFZH)Tj9WKdy18OW9FVabom7aek9WKde((wSW9FVabom7aek9WKdKo4FRajGu5WC(3URyuo6GBuaqiOpaInk5rgFFhKMoH8LdumkhDWnkaie0haXgL8YftCgQW0jcGWT0hOyuo6GBuaqiOpaInk5zd2yYLj8l5(NXKmeqSrwnpkqdeVlZ)k3Xk7dg7m4C7avOnGQs47xmst1sdk2zQLgcI)0E1Mb2j2aQ2hMulKjC(kulrApOwmPwMhNRwU)7HSQ25vRpgHgoheQLg7YvUevRsUSwfxRhO1Q0HAD4CbKw7bJDgCUDTCccm1I7AfQY4eohul0G9aOqXOC0b3OaGqqFaeBuYJaI)0EPNtSbKvNlpoiPcXdueLBwnpkQq8anOJnKuCYmq(3cxXIfMysfIhOb6G4u6b)Jsl78olwuH4bAGoioLEW)O5t5I7yGftYrhQqcAWEaeLBwSOcXd0Go2qsXjZa0EroIbgSyHjviEGg0Xgsko5F00f3rl7VJftYrhQqcAWEaeLBwSOcXd0Go2qsXjZa0MXmYadfJfJ0uT8kioLoyQLgF0b3OIrAQwRhp6ivCmdKAXDT3YIgvlFl(i6yTwA43x)eOyuo6GBuaPG4u6GHc57RFcy18OOIdAn0JhDfPIJzGeGw4CGH1bBZHt(4PveTuYilviEGg0XgskozgGDjGTmnI2COyKMQL)ZPa599GAzRwE6e83aMA5)Vh(i6GBAuTzWg9jqT5c1(rqT4gQ1ZH5exTkUwX33DzTxvHqWkuRIRvPd1AltxRkepqRDE1oATdQ2gR1IAXhrhR1EjOwvlcxR4C1Iv6aPwBz6AvH4bATc34gDauT(e8B0qXOC0b3OasbXP0bdBuYZhJDjcGWFYbS6HjPgYuPCRyuo6GBuaPG4u6GHnk55jecwbRMhf5EGmkeq0j4Vbmj0)9WhrhChGw4CGHf3)9cOpNcK33dcFFwC)3lG(CkqEFpiqaBzAu(3cSNv2iuI7)EGPyKMQL)ZPa599aAuT0yFF3L1Ij1sdHhbq0Rn3rPxl3)9atTxvHqWkGkgLJo4gfqkioLoyyJsE(ySlrae(toGvpmj1qMkLBfJYrhCJcifeNshmSrjppHqWky15YJdsQq8afr5MvZJIkoO1a6ZPa599Ga0cNdmSyIa2Y0O8VDHfl(2FNo(Ubi5t5gdSuH4bAqhBiP4Kza2La2Y0iAVOyKMQL)ZPa599GAzRwE6e83aMA5)Vh(i6G7ANUw(SOr1sJ99Dxwlie3L1sd)(6Na1Q0fT2ChNRwoOwc8iaIoyQ9Hj16lTbSNtXOC0b3OasbXP0bdBuYJ891pbSAEuuXbTgqFofiVVheGw4CGHLCpqgfci6e83aMe6)E4JOdUdqlCoWWkBdwdKVV(jqqNdZt7XIQqgHZbb00EoiPcXd0IrAQw(pNcK33dQn38QLNob)nGPw()7HpIo4MgvlneeFF3L1(WKA5W9hv7vNZQvAtEysTqMk0gWulQfFeDSwR5teDWDOyuo6GBuaPG4u6GHnk55JXUebq4p5aw9WKudzQuUvmkhDWnkGuqCkDWWgL88ecbRGvNlpoiPcXdueLBwnpkQ4GwdOpNcK33dcqlCoWWsUhiJcbeDc(Batc9Fp8r0b3bOfohyyXKC0HkKGgShar7nlwYwfh0AaYejT3FArHa0cNdmmWsfIhObDSHKItMbOLa2Y0iwmraBzAu(3yNwSKncL4(VhyyOyKMQL)ZPa599GAzR2myMiVAXDT3YIgvlneEearV2RQqiyfQv0Av6qTqBQf)QfPG4u61Q4A9aTwBjZAnFIOdURLdEycuBgmtK0E)PffkgLJo4gfqkioLoyyJsE(ySlrae(toGvpmj1qMkLBfJYrhCJcifeNshmSrjppHqWky18OOIdAnG(CkqEFpiaTW5adlvCqRbitK0E)PffcqlCoWWso6qfsqd2dGOCJf3)9cOpNcK33dceWwMgL)Ta7J8iF4eT(IRKJIAuJra]] )

end