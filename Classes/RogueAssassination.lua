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


    spec:RegisterPack( "Assassination", 20201024, [[di10gcqirPEesrUesbQnHs(KOcnkuKtHcwfsr9kukZIsYTqPs7sWVev1WuPYXuPSmrLEgkvnnrrDnrfTnvsLVPskACOurNtubwhsb9orrQQ5jQY9qI9Hu6FIIu5GifQfQsYdvjvnrKc4IIIOnkkc1hvjLAKifiDsrrWkrHEjkvGzQsk5MIIu2jLu)uuKQmuvsHLIuipfvnvrjxfPaXwfvqFfLkOXIsfAVc9xrgSshMyXOYJvXKP4YGnRkFMQmAKQtRy1IIqEnkQztLBtP2Tu)gQHtvDCrrYYr8CitN01vvBhj9DvcJxu48QeTEvQA(uI9l54TywrEJOq06CVl37UDxUzoCl3B5Eh7J86L(qK3xomlEqKVfBiYtJribHMw0b3rEF5shwmXSI8i8NCGipDv9r0W8Z3Bu6FUWbBNpAS)orhCFiYtZhn2N8J8C)XPzcDKlYBefIwN7D5E3T7YnZHB5E7wozNrE5R0XKip)yF9rE6JXaDKlYBa0jYtt1sJribHMw0b31sJWEFOyKMQntVJI5asT5MzRQn37Y9UiVBqkkMvKhPG4u6GjMv06BXSI8qlCoWeVkYFiJcKrI8Q4Gwd94rxrQ4ygibOfohyQLvThSnho5JNwr1slLAZCTSQvfIhObDSHKItMbQLDRLa2Y0OAPT2RlYlhDWDKN891pbIA06CJzf5Hw4CGjEvK)HjPgYqJwFlYlhDWDK3hJDjcGWFYbIA0A2hZkYdTW5at8Qi)HmkqgjYl3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YQwU)7fqFofiVVhe((1YQwU)7fqFofiVVheiGTmnQ28Q9wG91YQ2SRfHsC)3dmrE5OdUJ8EcHGviQrRZCmRip0cNdmXRI8pmj1qgA06BrE5OdUJ8(ySlrae(toquJwNZywrEOfohyIxf5LJo4oY7jecwHi)HmkqgjYRIdAnG(CkqEFpiaTW5atTSQLPAjGTmnQ28Q9wU1AXsT(2FNo(Ubi1MhLAVvld1YQwviEGg0XgskozgOw2TwcyltJQL2AZnYFU84GKkepqrrRVf1O1xxmRip0cNdmXRI8hYOazKiVkoO1a6ZPa599Ga0cNdm1YQw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1MDTgSgiFF9tGGohMN2Rww1sviJW5GaAAphKuH4bAKxo6G7ip57RFce1O1xZywrEOfohyIxf5FysQHm0O13I8YrhCh59XyxIai8NCGOgTMDgZkYdTW5at8QiVC0b3rEpHqWke5pKrbYirEvCqRb0NtbY77bbOfohyQLvTY9azuiGOtWFdysO)7HpIo4oaTW5atTSQLPALJouHe0G9aOAPT2B1AXsTzxRkoO1aKbsAV)0IcbOfohyQLHAzvRkepqd6ydjfNmdulT1saBzAuTSQLPAjGTmnQ28Q9g7SwlwQn7ArOe3)9atTme5pxECqsfIhOOO13IA06CqmRip0cNdmXRI8pmj1qgA06BrE5OdUJ8(ySlrae(toquJwF7UywrEOfohyIxf5pKrbYirEvCqRb0NtbY77bbOfohyQLvTQ4GwdqgiP9(tlkeGw4CGPww1khDOcjOb7bq1sP2B1YQwU)7fqFofiVVheiGTmnQ28Q9wG9rE5OdUJ8EcHGviQrnYdie0hafZkA9TywrEOfohyIxf5pKrbYirEObI3LbDSHKIt2sg1sBT3QLvTzxRb4(VxGk0gqvj89RLvTmvB21AWA4G7d0kruWKEoXgsCFsh05W80E1YQ2SRvo6G7Wb3hOvIOGj9CIneMo9CJhDTwlwQ99DUebo0fIhK0XgQnVA9oMGTKrTme5LJo4oYFW9bALikyspNydrnADUXSI8qlCoWeVkYFiJcKrI8gG7)EbQqBavLW3Vww1YuTgG7)EbpHqWkeGmqs79NwuWuRfl1AaU)7fq0hQHVFTSQ9GT5WjF80kkyG3CgT28Ou7TATyPwdW9FVavOnGQsGa2Y0OAZJsT3URwgQ1ILAFJhDnraBzAuT5rP2B3f5LJo4oYZ5Wytc)skDibnyFzuJwZ(ywrEOfohyIxf5pKrbYir(dg7m4l6avOnGQsGa2Y0OAZRw2xRfl1AaU)7fOcTbuvcF)ATyP234rxteWwMgvBE1Y(7I8YrhCh59(cXmsNWVKCpqWk9OgToZXSI8qlCoWeVkYFiJcKrI8phgtQLPAzQ234rxteWwMgvl7wl7VRwgQn)ALJo4oDWyNbFrxld1sBTphgtQLPAzQ234rxteWwMgvl7wl7VRw2T2dg7m4l6avOnGQsGa2Y0OAzO28Rvo6G70bJDg8fDTme5LJo4oY79fIzKoHFj5EGGv6rnADoJzf5Hw4CGjEvK)qgfiJe5r(GZLuH4bkk8KoHFjM7HkGQLwk1MBTwSulrgtcOcTgeJbfMUwAR96URww1cnq8US28Q9AExKxo6G7i)dF(iWKK7bYOqIde7OgT(6Izf5Hw4CGjEvK)qgfiJe5r(GZLuH4bkk8KoHFjM7HkGQLwk1MBTwSulrgtcOcTgeJbfMUwAR96UlYlhDWDK3)tM3Lt7L4CcsJA06RzmRip0cNdmXRI8hYOazKip3)9ce4WSdqO0dtoq47xRfl1Y9FVabom7aek9WKdKo4FRajGu5WCT5v7T7I8YrhCh5v6q63C4FBspm5arnAn7mMvKxo6G7ipz89DqA6eYxoqKhAHZbM4vrnADoiMvKxo6G7i)fyIZqfMoraeUL(arEOfohyIxf1O13UlMvKhAHZbM4vr(dzuGmsKhAG4DzT5vBoVRww1MDThm2zWx0bQqBavLW3pYlhDWDK3gSXKlt4xY9pJjziGyJIA06B3Izf5Hw4CGjEvKxo6G7ipbe)P9spNydOi)HmkqgjYRcXd0Go2qsXjZa1MxT3c5SwlwQLPAzQwviEGgOdItPh8pAT0wl78UATyPwviEGgOdItPh8pAT5rP2CVRwgQLvTmvRC0HkKGgShavlLAVvRfl1QcXd0Go2qsXjZa1sBT5MdQLHAzOwlwQLPAvH4bAqhBiP4K)rt5ExT0wl7VRww1YuTYrhQqcAWEauTuQ9wTwSuRkepqd6ydjfNmdulT1M5mxld1YqK)C5XbjviEGIIwFlQrnYBGN8DAmRO13Izf5LJo4oYZ8CyoYdTW5at8QOgTo3ywrE5OdUJ8ifeNspYdTW5at8QOgTM9XSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qKhAG4DzGaEqxlB16JheUbtIZbGbvlnx71S28RLPAZTwAUwKp4Cj6csHAziYtviPwSHip0aX7Yeb8GoDW2CtdMOgToZXSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qKh5doxsfIhOOWt6e(LyUhQaQ28Qn3ipvHKAXgI8OP9CqsfIhOrnADoJzf5Hw4CGjEvK)qgfiJe5rkioLoyceS3hI8YrhCh5pIZLKJo4o5gKg5DdstTydrEKcItPdMOgT(6Izf5Hw4CGjEvK)qgfiJe5zQ2SRvfh0AWwqkqsccji00bOfohyQ1ILAnyn4jecwHGohMN2RwgI8YrhCh5pIZLKJo4o5gKg5DdstTydr(Jbf1O1xZywrEOfohyIxf5LJo4oYFeNljhDWDYninY7gKMAXgI8gSg1O1SZywrEOfohyIxf5pKrbYirEU)7fqU5ajPnjZCGabSLPr1MxTQq8anOJnKuCYmqTSQL7)EbKBoqsAtYmhiqaBzAuT5vlt1ERw2Q9GT5WjF80kQwgQLMR9wGDg5LJo4oYJCZbssBsM5arnADoiMvKhAHZbM4vrE5OdUJ8hX5sYrhCNCdsJ8UbPPwSHiVziWrJA06B3fZkYdTW5at8Qi)HmkqgjYdnq8UmyG3CgTwAPu7TCwlB1sviJW5Ga0aX7Yeb8GoDW2CtdMiVC0b3rEHCKgskMqGwJA06B3Izf5LJo4oYlKJ0qY)7qqKhAHZbM4vrnA9TCJzf5LJo4oY7gp6kkLj6B8SHwJ8qlCoWeVkQrRVX(ywrE5OdUJ8CIxc)skzomJI8qlCoWeVkQrnY7tGd2Mt0ywrRVfZkYlhDWDKx89DxM8Xdc3rEOfohyIxf1O15gZkYdTW5at8QiVC0b3rEBHWmyspmjzarPh5pKrbYirEImMeqfAnigdkmDT0w7TCg59jWbBZjAcbhCBqr(Cg1O1SpMvKxo6G7ipsbXP0J8qlCoWeVkQrRZCmRip0cNdmXRI8YrhCh5rU5ajPnjZCGi)HmkqgjYtGhbq0fohe59jWbBZjAcbhCBqr(BrnADoJzf5Hw4CGjEvKVfBiYl3JOlebLE4wt4xYhFbqI8YrhCh5L7r0fIGspCRj8l5JVairnA91fZkYdTW5at8Qi)HmkqgjYRIdAnazGK27pTOqaAHZbMiVC0b3rEVVqmJ0j8lj3deSspQrnYBgcC0ywrRVfZkYdTW5at8Qi)HmkqgjYZuThSnho5JNwr1slLAZCTSvRkoO1GbaFGKqkruXdSdqlCoWuRfl1EW2C4KpEAfvlLALESLdDH4bM0XVwgQLvTmvRb4(VxGk0gqvj89R1ILAna3)9ci6d1W3VwlwQfAG4DzWaV5mAT5rP2CZzTSvlvHmcNdcqdeVlteWd60bBZnnyQ1ILAZUwQczeoheqt75GKkepqRLHAzvlt1MDTQ4GwdqgiP9(tlkeGw4CGPwlwQ9GXod(IoazGK27pTOqGa2Y0OAPT2CRLHiVC0b3rEOPcn2oQrRZnMvKhAHZbM4vrESFKhbAKxo6G7ipvHmcNdI8uf3hI8hSnho5JNwrbd8MZO1sBT3Q1ILAHgiExgmWBoJwBEuQn3CwlB1sviJW5Ga0aX7Yeb8GoDW2CtdMATyP2SRLQqgHZbb00EoiPcXd0ipvHKAXgI8FeKEJZbKOgTM9XSI8qlCoWeVkYlhDWDKhbeIOGjXHBiH8hMHi)HmkqgjYNDTgSgqaHikysC4gsi)HziOZH5P9Q1ILAPkKr4Cq4JG0BCoGulRAzQw5OdvibnypaQwk1ERww1sKXKaQqRbXyqHPRL2AFFNlrGdDH4bjDSHATyP2dDH4bOAPT2CRLvTQq8anOJnKuCYmqT5vBoRLHi)5YJdsQq8affT(wuJwN5ywrEOfohyIxf5pKrbYirEQczeohe(ii9gNdi1YQw5EGmkeGdD80EjoNyauaAHZbMAzvlYhCUKkepqrHN0j8lXCpubuT0sP2CRLTAzQwdW9FVavOnGQs47xlnxlt1ERw2QLPAL7bYOqao0Xt7L4CIbqbI0mxlLAVvld1YqTme5LJo4oY)KoHFjM7HkGIA06CgZkYdTW5at8Qi)HmkqgjYtviJW5GWhbP34CaPww1YuTC)3lqFmgOtCoXaOasLdZ1slLAVLdQ1ILAzQ2SR1NmyYOxMiyv0b31YQwKp4CjviEGIcpPt4xI5EOcOAPLsTzUw2QLPAL7bYOqWG)CoizWiiqKM5APT2CRLHAzRwKcItPdMab79HAzOwgI8YrhCh5FsNWVeZ9qfqrnA91fZkYdTW5at8QiVC0b3r(N0j8lXCpubuK)qgfiJe5PkKr4Cq4JG0BCoGulRAr(GZLuH4bkk8KoHFjM7HkGQLwk1Y(i)5YJdsQq8affT(wuJwFnJzf5Hw4CGjEvK)qgfiJe5PkKr4Cq4JG0BCoGe5LJo4oYdh64P9seWNm2sBIA0A2zmRip0cNdmXRI8hYOazKipvHmcNdcFeKEJZbKiVC0b3rEXM7JOh1O15GywrEOfohyIxf5LJo4oYB)1Xjke5pKrbYirEQczeohe(ii9gNdi1YQwKp4CjviEGIcpPt4xI5EOcOAPuBUr(ZLhhKuH4bkkA9TOgT(2DXSI8qlCoWeVkYFiJcKrI8ufYiCoi8rq6nohqI8YrhCh5T)64efIAuJ8hdkMv06BXSI8qlCoWeVkYlhDWDKxUhrxick9WTMWVKp(cGe5pKrbYir(SRfPG4u6GjioxTSQ1wqkqsccji00jcyltJQLsT3vlRAzQ2dg7m4l6avOnGQsGa2Y0OAZltxTmv7bJDg8fDarFOgiGTmnQwAUwit9hFFWeeeDQsdOerUhtshmrC1YqTmuBE1E7UAzR2B3vlnxlKP(JVpyccIovPbuIi3JjPdMiUAzvB21AaU)7fOcTbuvcF)AzvB21AaU)7fq0hQHVFKVfBiYl3JOlebLE4wt4xYhFbqIA06CJzf5Hw4CGjEvK)qgfiJe5ZUwKcItPdMG4C1YQwdwdKVV(jqqNdZt7vlRATfKcKKGqccnDIa2Y0OAPu7DrE5OdUJ8hX5sYrhCNCdsJ8UbPPwSHipGqqFauuJwZ(ywrEOfohyIxf5LJo4oYBleMbt6Hjjdik9i)HmkqgjYtKXKaQqRbXyqHVFTSQLPAvH4bAqhBiP4KzGAZR2d2MdN8XtROGbEZz0AP5AVfYzTwSu7bBZHt(4PvuWaV5mAT0sP2JFYwYiH8H2uldr(ZLhhKuH4bkkA9TOgToZXSI8qlCoWeVkYFiJcKrI8ezmjGk0Aqmguy6APTw2FxTSBTezmjGk0AqmguW8jIo4Uww1EW2C4KpEAffmWBoJwlTuQ94NSLmsiFOnrE5OdUJ82cHzWKEysYaIspQrRZzmRiVC0b3r(Nt8aNt0b3rEOfohyIxf1O1xxmRip0cNdmXRI8hYOazKiVb4(Vx45epW5eDWDGa2Y0OAZR2CR1ILAna3)9cpN4boNOdUdivomxlTuQL93f5LJo4oY)CIh4CIo4oDCG0iiQrRVMXSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qKp7AvXbTgqFofiVVheGw4CGPwlwQn7AL7bYOqarNG)gWKq)3dFeDWDaAHZbMATyPwdwdEcHGvi4B)D647gGulT1ERww1YuTiFW5sQq8affEsNWVeZ9qfq1MxTxxTwSuB21EWyNbFrhOk9GOh((1YqKNQqsTydrEQqBavLe6ZPa599G0b3MrhCh1O1SZywrEOfohyIxf5X(rEeOrE5OdUJ8ufYiCoiYtvCFiYNDTQ4Gwd94rxrQ4ygibOfohyQ1ILAZUwvCqRbidK0E)PffcqlCoWuRfl1EWyNbFrhGmqs79NwuiqaBzAuT5vBoRLDRn3AP5AvXbTgma4dKesjIkEGDaAHZbMipvHKAXgI8uH2aQkPE8ORivCmdK0b3MrhCh1O15GywrEOfohyIxf5X(rEeOrE5OdUJ8ufYiCoiYtvCFiYNDTqM6p((Gji3JOlebLE4wt4xYhFbqQ1ILAL7bYOqarNG)gWKq)3dFeDWDaAHZbMATyPwdW9FVarUhtshmrCjdW9FVGbFrxRfl1EWyNbFrheeDQsdOerUhtshmrCbcyltJQnVAVDxTSQLPApySZGVOdi6d1abSLPr1MxT3Q1ILAna3)9ci6d1W3VwgI8ufsQfBiYtfAdOQKE4wthCBgDWDuJwF7UywrEOfohyIxf5pKrbYir(SRfPG4u6GjqWEFOww1AWAG891pbc6CyEAVAzvB21AaU)7fOcTbuvcF)AzvlvHmcNdcuH2aQkj0NtbY77bPdUnJo4Uww1sviJW5GavOnGQsQhp6ksfhZajDWTz0b31YQwQczeoheOcTbuvspCRPdUnJo4oYlhDWDKNk0gqvjQrRVDlMvKhAHZbM4vr(dzuGmsKxfh0AaYajT3FArHa0cNdm1YQwvCqRHE8ORivCmdKa0cNdm1YQ2d2MdN8XtROAPLsTh)KTKrc5dTPww1EWyNbFrhGmqs79NwuiqaBzAuT5v7TiVC0b3rEQspi6rnA9TCJzf5Hw4CGjEvK)qgfiJe5vXbTg6XJUIuXXmqcqlCoWulRAZUwvCqRbidK0E)PffcqlCoWulRApyBoCYhpTIQLwk1E8t2sgjKp0MAzvlt1AaU)7fOcTbuvcF)ATyPwaHG(abQdAWDc)s(a5bhDWDaAHZbMAziYlhDWDKNQ0dIEuJwFJ9XSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qKxUhiJcbeDc(Batc9Fp8r0b3bOfohyQLvTmvBJ7ecL4(VhysQq8afvlTuQ9wTwSulYhCUKkepqrHN0j8lXCpubuTuQL91YqTSQLPArOe3)9atsfIhOOKWHPcjFPnG9CQLsT3vRfl1I8bNlPcXduu4jDc)sm3dvavlTuQ96QLHipvHKAXgI8iuIQ0dIE6GBZOdUJA06BzoMvKhAHZbM4vrE5OdUJ8(ySlrae(toqKhYqjssSX)wJ8zoNr(hMKAidnA9TOgT(woJzf5Hw4CGjEvK)qgfiJe5vXbTgqFofiVVheGw4CGPww1MDTifeNshmbc27d1YQ2dg7m4l6GNqiyfcF)Azvlt1sviJW5GacLOk9GONo42m6G7ATyP2SRvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLvTmvRbRbpHqWkeiWJai6cNdQ1ILAna3)9cuH2aQkHVFTSQ1G1GNqiyfc(2FNo(Ubi1MhLAVvld1YqTSQ9GT5WjF80kkyG3CgTwAPult1YuT3QLTAZTwAUw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwgQLMRf5doxsfIhOOWt6e(LyUhQaQwgQL2mD1M5AzvlrgtcOcTgeJbfMUwAR9wUrE5OdUJ8uLEq0JA06BxxmRip0cNdmXRI8hYOazKipt1QIdAnylifijbHeeA6a0cNdm1AXsTKFdpmXdc2cH5e(Lu6qYwqkqsccji00bit9hFFWuld1YQ2SRfPG4u6GjioxTSQ1wqkqsccji00jcyltJQnpk1ExTSQn7Anynq((6Nabc8iaIUW5GAzvRbRbpHqWkeiGTmnQwARL91YQwMQ1aC)3lqfAdOQe((1YQwdW9FVaI(qn89RLvTmvB21cie0hiW5Wytc)skDibnyFzWwYeHj1AXsTgG7)EbohgBs4xsPdjOb7ldF)AzOwlwQfqiOpqG6GgCNWVKpqEWrhChGw4CGPwgI8YrhCh5Pk9GOh1O13UMXSI8qlCoWeVkYFiJcKrI8zxlsbXP0btqCUAzvRCpqgfci6e83aMe6)E4JOdUdqlCoWulRAnyn4jecwHabEearx4CqTSQ1G1GNqiyfc(2FNo(Ubi1MhLAVvlRApyBoCYhpTIcg4nNrRLwk1ElYlhDWDKhrxm4lSbNjQrRVXoJzf5Hw4CGjEvK)qgfiJe5ZUwKcItPdMab79HAzvlt1MDTgSg8ecbRqGapcGOlCoOww1AWAG891pbceWwMgvlT1M5AzR2mxlnx7XpzlzKq(qBQ1ILAnynq((6NabcyltJQLMR9UqoRL2AvH4bAqhBiP4KzGAzOww1QcXd0Go2qsXjZa1sBTzoYlhDWDKhYajT3FArHOgT(woiMvKhAHZbM4vr(dzuGmsK3bubxT0sP2CYoRLvTgSgiFF9tGGohMN2Rww1YuTzxlKP(JVpycY9i6crqPhU1e(L8XxaKATyP2dg7m4l6avOnGQsGa2Y0OAPT2B3vldrE5OdUJ8i6d1OgTo37Izf5Hw4CGjEvK)qgfiJe55(VxGZHXg3hPbcihTwlwQ1aC)3lqfAdOQe((rE5OdUJ8(yDWDuJwN7TywrEOfohyIxf5pKrbYirEdW9FVavOnGQs47h5LJo4oYZ5Wyt69jxg1O15MBmRip0cNdmXRI8hYOazKiVb4(VxGk0gqvj89J8YrhCh55accimpTxuJwNl7Jzf5Hw4CGjEvK)qgfiJe5na3)9cuH2aQkHVFKxo6G7i)BiaNdJnrnADUzoMvKhAHZbM4vr(dzuGmsK3aC)3lqfAdOQe((rE5OdUJ8sFaKsex6ioxuJwNBoJzf5Hw4CGjEvKxo6G7iVN4GJ4CabL4W4oYFiJcKrI8mvRb4(VxGk0gqvj89R1ILAzQ2SRvfh0AaYajT3FArHa0cNdm1YQ2dg7m4l6avOnGQsGa2Y0OAPT2mNZATyPwvCqRbidK0E)PffcqlCoWulRAzQ2dg7m4l6aKbsAV)0IcbcyltJQnVAVUATyP2dg7m4l6aKbsAV)0IcbcyltJQL2AZ9UAzv7B8ORjcyltJQL2AVUCwld1YqTmulRAZUwdW9FVa57RFceGmqs79NwuWe5BXgI8EIdoIZbeuIdJ7OgTo3RlMvKhAHZbM4vrE5OdUJ8cIovPbuIi3JjPdMiUi)HmkqgjYBaU)7fiY9ys6GjIlzaU)7fm4l6ATyPwviEGg0XgskozgO28Qn37I8TydrEbrNQ0akrK7XK0btexuJwN71mMvKhAHZbM4vrE5OdUJ8cIovPbuIi3JjPdMiUi)HmkqgjYZuTzxRkoO1aKbsAV)0IcbOfohyQ1ILAZUwvCqRb0NtbY77bbOfohyQLHAzvRb4(VxGk0gqvjqaBzAuT0w7T7QLDRnZ1sZ1czQ)47dMGCpIUqeu6HBnHFjF8fajY3Ine5feDQsdOerUhtshmrCrnADUSZywrEOfohyIxf5LJo4oYli6uLgqjICpMKoyI4I8hYOazKipt1QIdAnazGK27pTOqaAHZbMAzvRkoO1a6ZPa599Ga0cNdm1YqTSQ1aC)3lqfAdOQe((1YQwMQ1aC)3l4jecwHaKbsAV)0IcMATyPw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1AWAWtieScbF7VthF3aKAPT2B1YqKVfBiYli6uLgqjICpMKoyI4IA06CZbXSI8qlCoWeVkYlhDWDK)C5XHvcUNtIZjinYFiJcKrI82csbssqibHMoraBzAuTuQ9UAzvB21AaU)7fOcTbuvcF)AzvB21AaU)7fq0hQHVFTSQL7)EbBWgtUmHFj3)mMKHaInkyWx01YQwObI3L1MxTSZ7QLvTgSgiFF9tGabSLPr1sBTzoYdVhC0ul2qK)C5XHvcUNtIZjinQrRz)DXSI8qlCoWeVkYlhDWDK39jmdeuAA0yg8hL8MNg5pKrbYirEdW9FVavOnGQs47h5BXgI8UpHzGGstJgZG)OK380OgTM93Izf5Hw4CGjEvKxo6G7iV7Juc(JsEyNb6KV7BlEqK)qgfiJe5na3)9cuH2aQkHVFKVfBiY7(iLG)OKh2zGo57(2Ihe1O1Sp3ywrEOfohyIxf5LJo4oY75eZikMGs2GrCUb3r(dzuGmsK3aC)3lqfAdOQe((rE49GJMAXgI8EoXmIIjOKnyeNBWDuJwZE2hZkYdTW5at8QiVC0b3rEpNygrXeuItmEqK)qgfiJe5na3)9cuH2aQkHVFKhEp4OPwSHiVNtmJOyckXjgpiQrRzFMJzf5LJo4oY)rqAuWgf5Hw4CGjEvuJAK3G1ywrRVfZkYdTW5at8Qip2pYJanYlhDWDKNQqgHZbrEQI7drEFYGjJEzIGvrhCxlRAr(GZLuH4bkk8KoHFjM7HkGQL2AzFTSQLPAnyn4jecwHabSLPr1MxThm2zWx0bpHqWkemFIOdUR1ILA9Xdc3GjX5aWGQL2AZzTme5PkKul2qKhX84NoxECqYtieScrnADUXSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qK3NmyYOxMiyv0b31YQwKp4CjviEGIcpPt4xI5EOcOAPTw2xlRAzQwdW9FVaI(qn89R1ILAzQwF8GWnysCoamOAPT2CwlRAZUw5EGmkeqhO1e(L4CySjaTW5atTmuldrEQcj1Ine5rmp(PZLhhKiFF9tGOgTM9XSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qK3aC)3lqfAdOQe((1YQwMQ1aC)3lGOpudF)ATyPwBbPajjiKGqtNiGTmnQwAR9UAzOww1AWAG891pbceWwMgvlT1MBKNQqsTydrEeZJFI891pbIA06mhZkYdTW5at8Qi)HmkqgjYRIdAnazGK27pTOqaAHZbMAzvB21AaU)7f8ecbRqaYajT3FArbtTSQ1G1GNqiyfc(2FNo(Ubi1MhLAVvlRApySZGVOdqgiP9(tlkeiGTmnQ28Qn3AzvlYhCUKkepqrHN0j8lXCpubuTuQ9wTSQLiJjbuHwdIXGctxlT1ED1YQwdwdEcHGviqaBzAuT0CT3fYzT5vRkepqd6ydjfNmde5LJo4oY7jecwHOgToNXSI8qlCoWeVkYFiJcKrI8Q4GwdqgiP9(tlkeGw4CGPww1YuThSnho5JNwr1slLAp(jBjJeYhAtTSQ9GXod(IoazGK27pTOqGa2Y0OAZR2B1YQwdwdKVV(jqGa2Y0OAP5AVlKZAZRwviEGg0XgskozgOwgI8YrhCh5jFF9tGOgT(6Izf5Hw4CGjEvK)HjPgYqJwFlYlhDWDK3hJDjcGWFYbIA06RzmRip0cNdmXRI8hYOazKipbEearx4CqTSQ9GT5WjF80kkyG3CgTwAPu7TAzRw2xlnxlt1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YQ2dg7m4l6avPhe9W3VwgQLvTmvRV93PJVBasT5rP2B1AXsTeWwMgvBEuQvNdZjDSHAzvlYhCUKkepqrHN0j8lXCpubuT0sPw2xlB1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YqTSQLPAZUwidK0E)Pffm1AXsTeWwMgvBEuQvNdZjDSHAP5AZTww1I8bNlPcXduu4jDc)sm3dvavlTuQL91YwTY9azuiGOtWFdysO)7HpIo4oaTW5atTmulRAZUwekX9FpWulRAzQwviEGg0XgskozgOw2TwcyltJQLHAPT2mxlRAzQwBbPajjiKGqtNiGTmnQwk1ExTwSuB21QZH5P9QLvTY9azuiGOtWFdysO)7HpIo4oaTW5atTme5LJo4oY7jecwHOgTMDgZkYdTW5at8Qi)dtsnKHgT(wKxo6G7iVpg7seaH)Kde1O15GywrEOfohyIxf5LJo4oY7jecwHi)HmkqgjYNDTufYiCoiGyE8tNlpoi5jecwHAzvlbEearx4CqTSQ9GT5WjF80kkyG3CgTwAPu7TAzRw2xlnxlt1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YQ2dg7m4l6avPhe9W3VwgQLvTmvRV93PJVBasT5rP2B1AXsTeWwMgvBEuQvNdZjDSHAzvlYhCUKkepqrHN0j8lXCpubuT0sPw2xlB1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YqTSQLPAZUwidK0E)Pffm1AXsTeWwMgvBEuQvNdZjDSHAP5AZTww1I8bNlPcXduu4jDc)sm3dvavlTuQL91YwTY9azuiGOtWFdysO)7HpIo4oaTW5atTmulRAZUwekX9FpWulRAzQwviEGg0XgskozgOw2TwcyltJQLHAPT2B5wlRAzQwBbPajjiKGqtNiGTmnQwk1ExTwSuB21QZH5P9QLvTY9azuiGOtWFdysO)7HpIo4oaTW5atTme5pxECqsfIhOOO13IA06B3fZkYdTW5at8Qi)HmkqgjYJ8bNlPcXduuT0sP2CRLvTeWwMgvBE1MBTSvlt1I8bNlPcXduuT0sP2Cwld1YQ2d2MdN8XtROAPLsTzoYlhDWDK)qgBeUtky7dinQrRVDlMvKhAHZbM4vr(dzuGmsKp7APkKr4CqaX84NiFF9tGAzvlt1EW2C4KpEAfvlTuQnZ1YQwc8iaIUW5GATyP2SRvNdZt7vlRAzQwDSHAPT2B3vRfl1EW2C4KpEAfvlTuQn3AzOwgQLvTmvRV93PJVBasT5rP2B1AXsTeWwMgvBEuQvNdZjDSHAzvlYhCUKkepqrHN0j8lXCpubuT0sPw2xlB1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YqTSQLPAZUwidK0E)Pffm1AXsTeWwMgvBEuQvNdZjDSHAP5AZTww1I8bNlPcXduu4jDc)sm3dvavlTuQL91YwTY9azuiGOtWFdysO)7HpIo4oaTW5atTmulRAvH4bAqhBiP4KzGAz3AjGTmnQwARnZrE5OdUJ8KVV(jquJwFl3ywrEOfohyIxf5LJo4oYt((6Nar(dzuGmsKp7APkKr4CqaX84NoxECqI891pbQLvTzxlvHmcNdciMh)e57RFculRApyBoCYhpTIQLwk1M5AzvlbEearx4CqTSQLPA9T)oD8DdqQnpk1ERwlwQLa2Y0OAZJsT6CyoPJnulRAr(GZLuH4bkk8KoHFjM7HkGQLwk1Y(AzRw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwgQLvTmvB21czGK27pTOGPwlwQLa2Y0OAZJsT6CyoPJnulnxBU1YQwKp4CjviEGIcpPt4xI5EOcOAPLsTSVw2QvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHAzvRkepqd6ydjfNmdul7wlbSLPr1sBTzoYFU84GKkepqrrRVf1O13yFmRip0cNdmXRI8hYOazKipYhCUKkepqr1sP2B1YQ2d2MdN8XtROAPLsTmv7XpzlzKq(qBQLDR9wTmulRAjWJai6cNdQLvTzxlKbsAV)0IcMAzvB21AaU)7fq0hQHVFTSQ1wqkqsccji00jcyltJQLsT3vlRAZUw5EGmke0lgKMu6qI5EEqaAHZbMAzvRkepqd6ydjfNmdul7wlbSLPr1sBTzoYlhDWDK)qgBeUtky7dinQrRVL5ywrE5OdUJ8iWhnOip0cNdmXRIAuJAKNkqqdUJwN7D5E3T7UDDr(lespThkYZoKgtJSotW6RnnS2AZIou7y7JjATpmP2CeqiOpakhRLazQ)qatTiSnuR8vSTOGP2dDP9auOy8AnnuBU0WAVECtfikyQnhHmqs79NwuWeyhZXAvCT5Ob4(VxGDmazGK27pTOGjhRLPBzWqOy8AnnuBMPH1E94MkquWul)yF91IUSvjJAPbxRIR9A9LAnd1bn4UwSpqeftQLP8zOwMYndgcfJfJSdPX0iRZeS(AtdRT2SOd1o2(yIw7dtQnhnWt(onhRLazQ)qatTiSnuR8vSTOGP2dDP9auOy8Annul7PH1E94MkquWul)yF91IUSvjJAPbxRIR9A9LAnd1bn4UwSpqeftQLP8zOwMULbdHIXIr2H0yAK1zcwFTPH1wBw0HAhBFmrR9Hj1MJhdkhRLazQ)qatTiSnuR8vSTOGP2dDP9auOy8AnnuBoGgw71JBQarbtT5OsMMzqdSJHdg7m4l6CSwfxBoEWyNbFrhyhZXAz6wgmekgVwtd1MBoPH1E94MkquWuBoczGK27pTOGjWoMJ1Q4AZrdW9FVa7yaYajT3FArbtowlt3YGHqX41AAO2CzN0WAVECtfikyQnhHmqs79NwuWeyhZXAvCT5Ob4(VxGDmazGK27pTOGjhRLPBzWqOySyKDinMgzDMG1xBAyT1MfDO2X2ht0AFysT5ObR5yTeit9hcyQfHTHALVITffm1EOlThGcfJxRPHAZmnS2Rh3ubIcMAZridK0E)Pffmb2XCSwfxBoAaU)7fyhdqgiP9(tlkyYXAz6wgmekglgZeS9Xefm1EnRvo6G7ADdsrHIXiVpb)ghe5PPAPXiKGqtl6G7APryVpumst1MP3rXCaP2CZSv1M7D5ExXyXinvBMmd48vWulh8WeO2d2Mt0A5aVPrHAPXNd4ROABCZU0fI977Qvo6GBuT42DzOyuo6GBuWNahSnNOueFF3LjF8GWDXOC0b3OGpboyBorzJs(2cHzWKEysYaIs3kFcCW2CIMqWb3geLCA18OqKXKaQqRbXyqHPP9wolgLJo4gf8jWbBZjkBuYhPG4u6fJYrhCJc(e4GT5eLnk5JCZbssBsM5aw5tGd2Mt0eco42GOCZQ5rHapcGOlCoOyuo6GBuWNahSnNOSrj)pcsJc2w1InqrUhrxick9WTMWVKp(cGumkhDWnk4tGd2Mtu2OKV3xiMr6e(LK7bcwPB18OOIdAnazGK27pTOqaAHZbMIXIrAQ2mzgW5RGPwGkqUSwDSHAv6qTYrXKAhuTcvzCcNdcfJYrhCJOW8CyUyKMQLgbifeNsV25vRpgHgohultnUwQFxdeHZb1cnypaQ2PR9GT5eLHIr5OdUrSrjFKcItPxmkhDWnInk5tviJW5aRAXgOanq8UmrapOthSn30GXkQI7duGgiExgiGh0S5JheUbtIZbGbrZxtAWmLlnJ8bNlrxqkWqXOC0b3i2OKpvHmcNdSQfBGcAAphKuH4bQvuf3hOG8bNlPcXduu4jDc)sm3dvaLxUfJYrhCJyJs(hX5sYrhCNCdsTQfBGcsbXP0bJvZJcsbXP0btGG9(qXOC0b3i2OK)rCUKC0b3j3GuRAXgOCmiRMhfMYwfh0AWwqkqsccji00bOfohySyXG1GNqiyfc6CyEApgkgLJo4gXgL8pIZLKJo4o5gKAvl2afdwlgLJo4gXgL8rU5ajPnjZCaRMhfU)7fqU5ajPnjZCGabSLPr5PcXd0Go2qsXjZaS4(Vxa5MdKK2KmZbceWwMgLht3y7GT5WjF80kIbA(wGDwmkhDWnInk5FeNljhDWDYni1QwSbkMHahTyuo6GBeBuYxihPHKIjeOvRMhfObI3Lbd8MZO0s5wozJQqgHZbbObI3Ljc4bD6GT5MgmfJYrhCJyJs(c5inK8)oeumkhDWnInk57gp6kkLj6B8SHwlgLJo4gXgL85eVe(LuYCygvmwmst1E9ySZGVOrfJYrhCJchdIYhbPrbBRAXgOi3JOlebLE4wt4xYhFbqSAEuYgPG4u6GjiohlBbPajjiKGqtNiGTmnIYDSy6GXod(IoqfAdOQeiGTmnkVmDmDWyNbFrhq0hQbcyltJOzit9hFFWeeeDQsdOerUhtshmrCmWqE3UJTB3rZqM6p((Gjii6uLgqjICpMKoyI4yLTb4(VxGk0gqvj89zLTb4(VxarFOg((fJYrhCJchdInk5FeNljhDWDYni1QwSbkacb9bqwnpkzJuqCkDWeeNJLbRbY3x)eiOZH5P9yzlifijbHeeA6ebSLPruURyKMQnt4vRymOAfcu733QAr94d1Q0HAXnu7fJsVwh(caP1Mvw0aHAPbbb1EbDOR1C50E1(eKcKAv6sx71FnQ1aV5mATysTxmkD8xRv6lR96VgHIr5OdUrHJbXgL8TfcZGj9WKKbeLUvNlpoiPcXdueLBwnpkezmjGk0Aqmgu47ZIjviEGg0XgskozgiVd2MdN8XtROGbEZzuA(wiNwSCW2C4KpEAffmWBoJslLJFYwYiH8H2WqXinvBMWR2gxRymOAVyCUAndu7fJsF6Av6qTnKHwl7VdzvTFeuBM2JgOwCxlhgHQ9IrPJ)ATsFzTx)1iumkhDWnkCmi2OKVTqygmPhMKmGO0TAEuiYysavO1GymOW00Y(7yxImMeqfAnigdky(erhCZ6GT5WjF80kkyG3CgLwkh)KTKrc5dTPyuo6GBu4yqSrj)Nt8aNt0b3fJYrhCJchdInk5)CIh4CIo4oDCG0iWQ5rXaC)3l8CIh4CIo4oqaBzAuE5AXIb4(Vx45epW5eDWDaPYHzAPW(7kgPPAZHqBavLADyV5iUAp42m6GBXHQLtqGPwCx75tiqR1I8HtXOC0b3OWXGyJs(ufYiCoWQwSbkuH2aQkj0NtbY77bPdUnJo42kQI7duYwfh0Aa95uG8(EqaAHZbglwYwUhiJcbeDc(Batc9Fp8r0b3bOfohySyXG1GNqiyfc(2FNo(Ubi0EJftiFW5sQq8affEsNWVeZ9qfq5DDwSK9bJDg8fDGQ0dIE47ZqXOC0b3OWXGyJs(ufYiCoWQwSbkuH2aQkPE8ORivCmdK0b3MrhCBfvX9bkzRIdAn0JhDfPIJzGeGw4CGXILSvXbTgGmqs79NwuiaTW5aJflhm2zWx0bidK0E)PffceWwMgLxoz3CPzvCqRbda(ajHuIOIhyhGw4CGPyuo6GBu4yqSrjFQczeohyvl2afQczeohyvl2afQqBavL0d3A6GBZOdUTIQ4(aLSHm1F89btqUhrxick9WTMWVKp(cGyXICpqgfci6e83aMe6)E4JOdUdqlCoWyXIb4(VxGi3JjPdMiUKb4(VxWGVOTyrjtZmObbrNQ0akrK7XK0btex4GXod(IoqaBzAuE3UJfthm2zWx0be9HAGa2Y0O8UzXIb4(VxarFOg((mumkhDWnkCmi2OKpvOnGQIvZJs2ifeNshmbc27dSmynq((6NabDompThRSna3)9cuH2aQkHVplQczeoheOcTbuvsOpNcK33dshCBgDWnlQczeoheOcTbuvs94rxrQ4ygiPdUnJo4MfvHmcNdcuH2aQkPhU10b3MrhCxmst1MdLEq0R9IrPxBMmdKxTSvR1JhDfPIJzGqdRnttYyS)21E9xJAL2uBMmdKxTeqmxw7dtQTHm0AV2xpnqXOC0b3OWXGyJs(uLEq0TAEuuXbTgGmqs79NwuiaTW5adlvCqRHE8ORivCmdKa0cNdmSoyBoCYhpTIOLYXpzlzKq(qByDWyNbFrhGmqs79NwuiqaBzAuE3kgPPAZHspi61EXO0R16XJUIuXXmqQLTATgxBMmdKhnS2mnjJX(Bx71FnQvAtT5qOnGQsTF)Az63oaHQ9JM2R2Ci(AWqXOC0b3OWXGyJs(uLEq0TAEuuXbTg6XJUIuXXmqcqlCoWWkBvCqRbidK0E)PffcqlCoWW6GT5WjF80kIwkh)KTKrc5dTHftgG7)EbQqBavLW33IfaHG(abQdAWDc)s(a5bhDWDaAHZbggkgPPA5bO2335Q9GTTHwRf31sxvFenm)89gL(NlCW25tJeQqth7mk7M11Npnc79H8VyyEYNgJqccnTOdUzxA814AXU0iabc5qpumkhDWnkCmi2OKpvHmcNdSQfBGccLOk9GONo42m6GBROkUpqrUhiJcbeDc(Batc9Fp8r0b3bOfohyyXuJ7ecL4(VhysQq8afrlLBwSG8bNlPcXduu4jDc)sm3dvarH9mWIjekX9FpWKuH4bkkjCyQqYxAdyphk3zXcYhCUKkepqrHN0j8lXCpubeTuUogkgLJo4gfogeBuY3hJDjcGWFYbS6HjPgYqPCZkidLijXg)BLsMZzXOC0b3OWXGyJs(uLEq0TAEuuXbTgqFofiVVheGw4CGHv2ifeNshmbc27dSoySZGVOdEcHGvi89zXevHmcNdciuIQ0dIE6GBZOdUTyjB5EGmkeq0j4Vbmj0)9WhrhChGw4CGHftgSg8ecbRqGapcGOlCoWIfdW9FVavOnGQs47ZYG1GNqiyfc(2FNo(Ubi5r5gdmW6GT5WjF80kkyG3CgLwkmX0n2YLML7bYOqarNG)gWKq)3dFeDWDaAHZbggOzKp4CjviEGIcpPt4xI5EOcigOntxMzrKXKaQqRbXyqHPP9wUfJ0uT5qPhe9AVyu61MPjifi1sJribnnnSwRX1IuqCk9AL2uBJRvo6qfQntJgxl3)9SQwA03x)eO2gR1oDTe4rae9Ajs7bwvR5tM2R2Ci0gqvHTSUITRWAMSwM(TdqOA)OP9QnhIVgmumkhDWnkCmi2OKpvPheDRMhfMuXbTgSfKcKKGqccnDaAHZbglwi)gEyIheSfcZj8lP0HKTGuGKeesqOPdqM6p((GHbwzJuqCkDWeeNJLTGuGKeesqOPteWwMgLhL7yLTbRbY3x)eiqGhbq0fohWYG1GNqiyfceWwMgrl7zXKb4(VxGk0gqvj89zzaU)7fq0hQHVplMYgqiOpqGZHXMe(Lu6qcAW(YGTKjctSyXaC)3lW5Wytc)skDibnyFz47ZGflacb9bcuh0G7e(L8bYdo6G7a0cNdmmumst1Ytxm4lSbNP2hMulpDc(BatT8)3dFeDWDXOC0b3OWXGyJs(i6IbFHn4mwnpkzJuqCkDWeeNJLCpqgfci6e83aMe6)E4JOdUdqlCoWWYG1GNqiyfce4raeDHZbSmyn4jecwHGV93PJVBasEuUX6GT5WjF80kkyG3CgLwk3kgPPAZKzGK27pTOqTxqh6ABSwlsbXP0btTsBQLdR0RLg991pbQvAtTxBHqWkuRqGA)(1(WKAD42RwOXFp6HIr5OdUrHJbXgL8Hmqs79NwuWQ5rjBKcItPdMab79bwmLTbRbpHqWkeiWJai6cNdyzWAG891pbceWwMgrBMzlZ08XpzlzKq(qBSyXG1a57RFceiGTmnIMVlKtAvH4bAqhBiP4KzagyPcXd0Go2qsXjZa0M5Ir5OdUrHJbXgL8r0hQwnpkoGk4OLsozNSmynq((6NabDompThlMYgYu)X3hmb5EeDHiO0d3Ac)s(4laIflhm2zWx0bQqBavLabSLPr0E7ogkgLJo4gfogeBuY3hRdUTAEu4(VxGZHXg3hPbcih1IfdW9FVavOnGQs47xmkhDWnkCmi2OKpNdJnP3NCPvZJIb4(VxGk0gqvj89lgLJo4gfogeBuYNdiiGW80EwnpkgG7)EbQqBavLW3Vyuo6GBu4yqSrj)3qaohgBSAEuma3)9cuH2aQkHVFXOC0b3OWXGyJs(sFaKsex6ioNvZJIb4(VxGk0gqvj89lgLJo4gfogeBuY)JG0OGTvTydu8ehCeNdiOehg3wnpkmzaU)7fOcTbuvcFFlwykBvCqRbidK0E)PffcqlCoWW6GXod(IoqfAdOQeiGTmnI2mNtlwuXbTgGmqs79NwuiaTW5adlMoySZGVOdqgiP9(tlkeiGTmnkVRZILdg7m4l6aKbsAV)0IcbcyltJOn37y9gp6AIa2Y0iAVUCYadmWkBidK0E)PffmbY3x)eOyuo6GBu4yqSrj)pcsJc2w1Inqrq0PknGse5EmjDWeXz18OyaU)7fiY9ys6GjIlzaU)7fm4lAlwuH4bAqhBiP4KzG8Y9UIr5OdUrHJbXgL8)iinkyBvl2afbrNQ0akrK7XK0bteNvZJctzRIdAnazGK27pTOqaAHZbglwYwfh0Aa95uG8(EqaAHZbggyzaU)7fOcTbuvceWwMgr7T7y3mtZqM6p((Gji3JOlebLE4wt4xYhFbqkgLJo4gfogeBuY)JG0OGTvTydueeDQsdOerUhtshmrCwnpkmPIdAnazGK27pTOqaAHZbgwQ4GwdOpNcK33dcqlCoWWaldW9FVavOnGQs47ZIjidK0E)PffmbpHqWkyXICpqgfci6e83aMe6)E4JOdUdqlCoWWYG1GNqiyfc(2FNo(Ubi0EJHIr5OdUrHJbXgL8)iinkyBf8EWrtTyduoxECyLG75K4CcsTAEuSfKcKKGqccnDIa2Y0ik3XkBdW9FVavOnGQs47ZkBdW9FVaI(qn89zX9FVGnyJjxMWVK7FgtYqaXgfm4lAwqdeVlZJDEhldwdKVV(jqGa2Y0iAZCXOC0b3OWXGyJs(FeKgfSTQfBGI7tygiO00OXm4pk5np1Q5rXaC)3lqfAdOQe((fJYrhCJchdInk5)rqAuW2QwSbkUpsj4pk5HDgOt(UVT4bwnpkgG7)EbQqBavLW3Vyuo6GBu4yqSrj)pcsJc2wbVhC0ul2afpNygrXeuYgmIZn42Q5rXaC)3lqfAdOQe((fJYrhCJchdInk5)rqAuW2k49GJMAXgO45eZikMGsCIXdSAEuma3)9cuH2aQkHVFXinvlna8KVtR9johNCyU2hMu7hjCoO2rbBenSwAqqqT4U2dg7m4l6qXOC0b3OWXGyJs(FeKgfSrfJfJ0uT0adboATgXw8GAfUXn6aOIrAQ2mztfASDTIwBMzRwMYjB1EXO0RLgGNHAV(RrO2mbBBWmIcUlRf31MlB1QcXduKv1EXO0RnhcTbuvSQwmP2lgLETzDvM(1Iv6a5Ibb1EHmATpmPwe2gQfAG4DzOwASdHR9cz0ANxTzYmqE1EW2C4AhuThS90E1(9dfJYrhCJcMHahLc0uHgBB18OW0bBZHt(4PveTuYmBQ4Gwdga8bscPerfpWoaTW5aJflhSnho5JNwruKESLdDH4bM0XNbwmzaU)7fOcTbuvcFFlwma3)9ci6d1W33IfObI3Lbd8MZO5rj3CYgvHmcNdcqdeVlteWd60bBZnnySyjBQczeoheqt75GKkepqzGftzRIdAnazGK27pTOqaAHZbglwoySZGVOdqgiP9(tlkeiGTmnI2CzOyuo6GBuWme4OSrjFQczeohyvl2aLpcsVX5aIvuf3hOCW2C4KpEAffmWBoJs7nlwGgiExgmWBoJMhLCZjBufYiCoianq8UmrapOthSn30GXILSPkKr4CqanTNdsQq8aTyuo6GBuWme4OSrjFeqiIcMehUHeYFygS6C5XbjviEGIOCZQ5rjBdwdiGqefmjoCdjK)Wme05W80EwSqviJW5GWhbP34CaHftYrhQqcAWEaeLBSiYysavO1GymOW00((oxIah6cXds6ydwSCOleparBUSuH4bAqhBiP4KzG8YjdfJ0uTSdhLETzYdD80E1ELtmaYQAZelDT4xTSd6HkGQv0AZLTAvH4bkYQAXKAzp7Mz2QvfIhOOAVGo01MdH2aQk1oOA)(fJYrhCJcMHahLnk5)KoHFjM7HkGSAEuOkKr4Cq4JG0BCoGWsUhiJcb4qhpTxIZjgafGw4CGHfYhCUKkepqrHN0j8lXCpubeTuYLnMma3)9cuH2aQkHVpnZ0n2ysUhiJcb4qhpTxIZjgafisZmLBmWadfJ0uTzILUw8Rw2b9qfq1kAT3YbSvlsLdZOAXVAPbDmgOR9kNyauTysTINmnsRnZSvlt5KTAVyu61sdG)CoOwAamcyOwviEGIcfJYrhCJcMHahLnk5)KoHFjM7HkGSAEuOkKr4Cq4JG0BCoGWIjU)7fOpgd0joNyauaPYHzAPClhyXctz7tgmz0lteSk6GBwiFW5sQq8affEsNWVeZ9qfq0sjZSXKCpqgfcg8NZbjdgbbI0mtBUmWgsbXP0btGG9(admumst1Mjw6AXVAzh0dvavRIRv89Dxwlnaig3L1EnWdc31oVANwo6qfQf31k9L1QcXd0AfTw2xRkepqrHIr5OdUrbZqGJYgL8FsNWVeZ9qfqwDU84GKkepqruUz18OqviJW5GWhbP34CaHfYhCUKkepqrHN0j8lXCpubeTuyFXOC0b3OGziWrzJs(WHoEAVeb8jJT0gRMhfQczeohe(ii9gNdifJYrhCJcMHahLnk5l2CFeDRMhfQczeohe(ii9gNdifJ0uTzjCSBM2xhNOqTkUwX33DzT0aGyCxw71apiCxRO1MBTQq8afvmkhDWnkygcCu2OKV9xhNOGvNlpoiPcXdueLBwnpkufYiCoi8rq6nohqyH8bNlPcXduu4jDc)sm3dvarj3Ir5OdUrbZqGJYgL8T)64efSAEuOkKr4Cq4JG0BCoGumwmst1sdi2IhulMkqQvhBOwHBCJoaQyKMQ9An2Jw71wieScOAXDTnUzxFYyteYL1QcXduuTpmPwLouRpzWKrVSwcwfDWDTZR2CYwTCoamOAfcuR4iGyUS2VFXOC0b3OGbRuOkKr4CGvTyduqmp(PZLhhK8ecbRGvuf3hO4tgmz0lteSk6GBwiFW5sQq8affEsNWVeZ9qfq0YEwmzWAWtieScbcyltJY7GXod(Io4jecwHG5teDWTfl(4bHBWK4Cayq0MtgkgPPAVwJ9O1sJ((6NaOAXDTnUzxFYyteYL1QcXduuTpmPwLouRpzWKrVSwcwfDWDTZR2CYwTCoamOAfcuR4iGyUS2VFXOC0b3OGbRSrjFQczeohyvl2afeZJF6C5XbjY3x)eWkQI7du8jdMm6LjcwfDWnlKp4CjviEGIcpPt4xI5EOciAzplMma3)9ci6d1W33IfM8Xdc3GjX5aWGOnNSYwUhiJcb0bAnHFjohgBcqlCoWWadfJ0uTxRXE0APrFF9tauTZR2Ci0gqvHnE6d18Z0eKcKAPXiKGqtx7GQ97xR0MAVaQLUqfQnx2QfbhCBq16GNwlURvPd1sJ((6Na1sdGZQyuo6GBuWGv2OKpvHmcNdSQfBGcI5Xpr((6NawrvCFGIb4(VxGk0gqvj89zXKb4(VxarFOg((wSylifijbHeeA6ebSLPr0EhdSmynq((6NabcyltJOn3IrAQwEF4mIR2RTqiyfQvAtT0OVV(jqTiq)(16tgmPwfxBMmdK0E)PffQ9iiTyuo6GBuWGv2OKVNqiyfSAEuuXbTgGmqs79NwuiaTW5adRSHmqs79NwuWe8ecbRaldwdEcHGvi4B)D647gGKhLBSoySZGVOdqgiP9(tlkeiGTmnkVCzH8bNlPcXduu4jDc)sm3dvar5glImMeqfAnigdkmnTxhldwdEcHGviqaBzAenFxiN5PcXd0Go2qsXjZafJYrhCJcgSYgL8jFF9taRMhfvCqRbidK0E)PffcqlCoWWIPd2MdN8XtRiAPC8t2sgjKp0gwhm2zWx0bidK0E)PffceWwMgL3nwgSgiFF9tGabSLPr08DHCMNkepqd6ydjfNmdWqXinv71wieSc1(9zgaFRQvCiCTkzauTkU2pcQD0AfuTsTiF4mIRwpObIOysTpmPwLouRtqATx)1Owo4HjqTsTVPheDGumkhDWnkyWkBuY3hJDjcGWFYbS6HjPgYqPCRyuo6GBuWGv2OKVNqiyfSAEuiWJai6cNdyDW2C4KpEAffmWBoJslLBSXEAMj5EGmkeq0j4Vbmj0)9WhrhChGw4CGH1bJDg8fDGQ0dIE47ZalM8T)oD8DdqYJYnlwiGTmnkpk6CyoPJnWc5doxsfIhOOWt6e(LyUhQaIwkSNn5EGmkeq0j4Vbmj0)9WhrhChGw4CGHbwmLnKbsAV)0IcglwiGTmnkpk6CyoPJnqZ5Yc5doxsfIhOOWt6e(LyUhQaIwkSNn5EGmkeq0j4Vbmj0)9WhrhChGw4CGHbwzJqjU)7bgwmPcXd0Go2qsXjZaSlbSLPrmqBMzXKTGuGKeesqOPteWwMgr5olwYwNdZt7XsUhiJcbeDc(Batc9Fp8r0b3bOfohyyOyuo6GBuWGv2OKVpg7seaH)Kdy1dtsnKHs5wXOC0b3OGbRSrjFpHqWky15YJdsQq8afr5MvZJs2ufYiCoiGyE8tNlpoi5jecwbwe4raeDHZbSoyBoCYhpTIcg4nNrPLYn2ypnZKCpqgfci6e83aMe6)E4JOdUdqlCoWW6GXod(Ioqv6brp89zGft(2FNo(Ubi5r5MfleWwMgLhfDomN0XgyH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWalMYgYajT3FArbJfleWwMgLhfDomN0XgO5CzH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWaRSrOe3)9adlMuH4bAqhBiP4Kza2La2Y0igO9wUSyYwqkqsccji00jcyltJOCNflzRZH5P9yj3dKrHaIob)nGjH(Vh(i6G7a0cNdmmumst1E9KXgH7AZcS9bKwlUR1(70X3b1QcXduuTIwBMzR2R)Au7f0HUwYV7P9Qf)1ANU2Cr1Y03VwfxBMRvfIhOigQftQL9OAzkNSvRkepqrmumkhDWnkyWkBuY)qgBeUtky7di1Q5rb5doxsfIhOiAPKllcyltJYlx2yc5doxsfIhOiAPKtgyDW2C4KpEAfrlLmxmst1Yoaa)A)(1sJ((6Na1kATzMTAXDTIZvRkepqr1Y0f0HUw3qDAVAD42RwOXFp61kTP2gR1IAXhrhRmumkhDWnkyWkBuYN891pbSAEuYMQqgHZbbeZJFI891pbyX0bBZHt(4PveTuYmlc8iaIUW5alwYwNdZt7XIjDSbAVDNflhSnho5JNwr0sjxgyGft(2FNo(Ubi5r5MfleWwMgLhfDomN0XgyH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWalMYgYajT3FArbJfleWwMgLhfDomN0XgO5CzH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWalviEGg0XgskozgGDjGTmnI2mxmkhDWnkyWkBuYN891pbS6C5XbjviEGIOCZQ5rjBQczeoheqmp(PZLhhKiFF9tawztviJW5GaI5Xpr((6NaSoyBoCYhpTIOLsMzrGhbq0fohWIjF7VthF3aK8OCZIfcyltJYJIohMt6ydSq(GZLuH4bkk8KoHFjM7HkGOLc7ztUhiJcbeDc(Batc9Fp8r0b3bOfohyyGftzdzGK27pTOGXIfcyltJYJIohMt6yd0CUSq(GZLuH4bkk8KoHFjM7HkGOLc7ztUhiJcbeDc(Batc9Fp8r0b3bOfohyyGLkepqd6ydjfNmdWUeWwMgrBMlgPPAVEYyJWDTzb2(asRf31YNvTZR2PR1xAdypNAL2u7O1EX4C1AW16aeQwJylEqTkDPRnt2uHgBxR5d1Q4AZ6Q8Z0OX5NLYoOyuo6GBuWGv2OK)Hm2iCNuW2hqQvZJcYhCUKkepqruUX6GT5WjF80kIwkmD8t2sgjKp0g29gdSiWJai6cNdyLnKbsAV)0IcgwzBaU)7fq0hQHVplBbPajjiKGqtNiGTmnIYDSYwUhiJcb9IbPjLoKyUNheGw4CGHLkepqd6ydjfNmdWUeWwMgrBMlgLJo4gfmyLnk5JaF0GkglgPPAZKie0havmkhDWnkaie0har5G7d0kruWKEoXgSAEuGgiExg0Xgskozlzq7nwzBaU)7fOcTbuvcFFwmLTbRHdUpqRerbt65eBiX9jDqNdZt7XkB5OdUdhCFGwjIcM0Zj2qy60ZnE0vlwEFNlrGdDH4bjDSH88oMGTKbdfJ0uT0y3fYLOA)iO2RCySP2lgLET5qOnGQsTF)qT0GIDMAFysTzYmqs79NwuiulniiO2lgLETzDvTF)A5GhMa1k1(MEq0bsTcQwhU9Qvq1oATKFJQ9Hj1E7ouTMpzAVAZHqBavLqXOC0b3OaGqqFaeBuYNZHXMe(Lu6qcAW(sRMhfdW9FVavOnGQs47ZIjidK0E)PffmbpHqWkyXIb4(VxarFOg((SoyBoCYhpTIcg4nNrZJYnlwma3)9cuH2aQkbcyltJYJYT7yWIL34rxteWwMgLhLB3vmst1sJvfS91AvCTIB86AV2FHygPR9IrPxBoeAdOQuRGQ1HBVAfuTJw7f4oh1Aja670ANUwhgnTxTsTVVZXUuf3hQ9iiTwmvGuRshQLa2Y0t7vR5teDWDT4xTkDO234rxlgLJo4gfaec6dGyJs(EFHygPt4xsUhiyLUvZJYbJDg8fDGk0gqvjqaBzAuES3IfdW9FVavOnGQs47BXYB8ORjcyltJYJ93vmkhDWnkaie0haXgL89(cXmsNWVKCpqWkDRMhLNdJjmX0B8ORjcyltJyx2Fhd0GpySZGVOzG2NdJjmX0B8ORjcyltJyx2Fh7EWyNbFrhOcTbuvceWwMgXan4dg7m4lAgkgLJo4gfaec6dGyJs(p85JatsUhiJcjoqSTAEuq(GZLuH4bkk8KoHFjM7HkGOLsUwSqKXKaQqRbXyqHPP96UJf0aX7Y8UM3vmkhDWnkaie0haXgL89)K5D50EjoNGuRMhfKp4CjviEGIcpPt4xI5EOciAPKRflezmjGk0AqmguyAAVU7kgLJo4gfaec6dGyJs(kDi9Bo8VnPhMCaRMhfU)7fiWHzhGqPhMCGW33IfU)7fiWHzhGqPhMCG0b)BfibKkhMZ72DfJYrhCJcacb9bqSrjFY477G00jKVCGIr5OdUrbaHG(ai2OK)fyIZqfMoraeUL(afJYrhCJcacb9bqSrjFBWgtUmHFj3)mMKHaInYQ5rbAG4DzE58owzFWyNbFrhOcTbuvcF)IrAQwAqXotT0iq8N2R2mXoXgq1(WKAHmGZxHAjs7b1Ij1Y84C1Y9FpKv1oVA9Xi0W5GqT0y3fYLOAvYL1Q4A9aTwLouRdFbG0ApySZGVORLtqGPwCxRqvgNW5GAHgShafkgLJo4gfaec6dGyJs(eq8N2l9CInGS6C5XbjviEGIOCZQ5rrfIhObDSHKItMbY7wiNwSWetQq8anqheNsp4FuAzN3zXIkepqd0bXP0d(hnpk5EhdSyso6qfsqd2dGOCZIfviEGg0XgskozgG2CZbmWGflmPcXd0Go2qsXj)JMY9oAz)DSyso6qfsqd2dGOCZIfviEGg0XgskozgG2mNzgyOySyKMQLxbXP0btT04Jo4gvmst1A94rhPIJzGulUR9ww0WA5BXhrhR1sJ((6NafJYrhCJcifeNshmuiFF9taRMhfvCqRHE8ORivCmdKa0cNdmSoyBoCYhpTIOLsMzPcXd0Go2qsXjZaSlbSLPr0EDfJ0uT8FofiVVhulB1YtNG)gWul))9WhrhCtdRnt2OpbQ9cO2pcQf3qTEomN4QvX1k((UlR9AlecwHAvCTkDOwBz6AvH4bATZR2rRDq12yTwul(i6yT2lb1QAr4AfNRwSshi1AltxRkepqRv4g3OdGQ1NGFJgkgLJo4gfqkioLoyyJs((ySlrae(toGvpmj1qgkLBfJYrhCJcifeNshmSrjFpHqWky18Oi3dKrHaIob)nGjH(Vh(i6G7a0cNdmS4(Vxa95uG8(Eq47ZI7)Eb0NtbY77bbcyltJY7wG9SYgHsC)3dmfJ0uT8FofiVVhqdRLg777USwmPwAe8iaIETxmk9A5(VhyQ9AlecwbuXOC0b3OasbXP0bdBuY3hJDjcGWFYbS6HjPgYqPCRyuo6GBuaPG4u6GHnk57jecwbRoxECqsfIhOik3SAEuuXbTgqFofiVVheGw4CGHfteWwMgL3TCTyX3(70X3najpk3yGLkepqd6ydjfNmdWUeWwMgrBUfJ0uT8FofiVVhulB1YtNG)gWul))9WhrhCx701YNfnSwASVV7YAbH4USwA03x)eOwLUO1EX4C1Yb1sGhbq0btTpmPwFPnG9CkgLJo4gfqkioLoyyJs(KVV(jGvZJIkoO1a6ZPa599Ga0cNdmSK7bYOqarNG)gWKq)3dFeDWDaAHZbgwzBWAG891pbc6CyEApwufYiCoiGM2ZbjviEGwmst1Y)5uG8(EqTxKFT80j4Vbm1Y)Fp8r0b30WAPrG477US2hMulhU)OAV(RrTsBYhtQfYqH2aMArT4JOJ1AnFIOdUdfJYrhCJcifeNshmSrjFFm2Liac)jhWQhMKAidLYTIr5OdUrbKcItPdg2OKVNqiyfS6C5XbjviEGIOCZQ5rrfh0Aa95uG8(EqaAHZbgwY9azuiGOtWFdysO)7HpIo4oaTW5adlMKJouHe0G9aiAVzXs2Q4GwdqgiP9(tlkeGw4CGHbwQq8anOJnKuCYmaTeWwMgXIjcyltJY7g70ILSrOe3)9addfJ0uT8FofiVVhulB1MjZa5vlUR9ww0WAPrWJai61ETfcbRqTIwRshQfAtT4xTifeNsVwfxRhO1AlzuR5teDWDTCWdtGAZKzGK27pTOqXOC0b3OasbXP0bdBuY3hJDjcGWFYbS6HjPgYqPCRyuo6GBuaPG4u6GHnk57jecwbRMhfvCqRb0NtbY77bbOfohyyPIdAnazGK27pTOqaAHZbgwYrhQqcAWEaeLBS4(Vxa95uG8(EqGa2Y0O8UfyFKh5dNO15MZCquJAmca]] )

end