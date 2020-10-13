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
                    gain( 5, "energy" )
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
            
            spend = 20,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135428,
            
            handler = function ()
                gain( 1, "combo_points" )
                applyDebuff( "target", "crippling_poison_shiv" )
                applyDebuff( "target", "shiv" )

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
            cooldown = 25,
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
                    max_stack = 25,
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
            cooldown = 45,
            gcd = "off",

            startsCombat = true,
            texture = 3565724,

            toggle = "essences",

            bind = "flagellation",

            usable = function () return IsActiveSpell( 345569 ), "flagellation_cleanse not active" end,

            handler = function ()
                removeBuff( "flagellation" )
                removeDebuff( "target", "flagellation" )
                active_dot.flagellation = 0
                applyBuff( "flagellation_buff" )
                setCooldown( "flagellation", 25 )
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


    spec:RegisterPack( "Assassination", 20201012, [[di16gcqirPEesrUesbQnHs(KOcnkuKtHcTkKI6vOOMfLKBHsL2LGFjQ0WuPYXuPSmvcpdLQMMOKUMOI2MkP03ujfghkv05evG1HuqVtuIQAEIQCpKyFiL(NOevoisHAHQe9qvsvtePaUOOeAJIsq9rvsLgjsbsNuucSsuWlrPcmtvsf3uuIYoPK6NIsuLHQskAPifYtrvtvu0vrkqSvrf0xrPcASOuH2Rq)vKbR0HjTyu5XQyYuCzWMvLptvnAKQtRy1IsqEnkLztLBtP2Tu)gQHtvoUOez5iEoKPtCDv12rsFxuvJxu48QKSEvQA(uI9l54TyMrEJkq06lU7I7UD3TlcxClRx7TBrE5kpiY7Ph2uFiY3Qne5PXiKIqtRYG7iVNELdRMyMrEe(toqKNUiEiAyU56pc9px4GTZfn2FNkdUpe9j5Ig7tUrEU)4KSGoYf5nQarRV4UlU72D3UiCXTSET3XoJ86xOJjrE(X(6J80hJb6ixK3aOtKNMQLgJqkcnTkdURLgH9)qXanvBwEhbZbKAVDZQAV4UlUlY7gKGIzg5rcOoHoyIzgT(wmZip0kNdmXlJ8hYiaz0iVOoOLqp(0fKOo2asaALZbMAzv7bBZHtE4PfuT0sP2SwlRAfL4dsqgBij4KzGAz3AjGTonQwAR9AJ86rgCh5jFp5tGOeT(IyMrEOvohyIxg5FysQHmKO13I86rgCh59WyxIai8NCGOeTM9XmJ8qRCoWeVmYFiJaKrJ869azeiGOtWFdysO)7HpQm4oaTY5atTSQL7)Eb0NtaY77dHVxTSQL7)Eb0NtaY77dbcyRtJQnVAVfyFTSQn7ArOe3)9atKxpYG7iVVsiybIs06SgZmYdTY5at8Yi)dtsnKHeT(wKxpYG7iVhg7seaH)KdeLO15mMzKhALZbM4LrE9idUJ8(kHGfiYFiJaKrJ8I6GwcOpNaK33hcqRCoWulRAzQwcyRtJQnVAVDrTwSuRN93jJNBasT5rP2B1YyTSQvuIpibzSHKGtMbQLDRLa260OAPT2lI8NRooijkXheu06BrjA91gZmYdTY5at8Yi)HmcqgnYlQdAjG(CcqEFFiaTY5atTSQvVhiJabeDc(Batc9Fp8rLb3bOvohyQLvTzxRblbY3t(eiiZHTP9RLvTuvYOCoiGM23bjrj(Ge51Jm4oYt(EYNarjA91iMzKhALZbM4Lr(hMKAidjA9TiVEKb3rEpm2Liac)jhikrRzNXmJ8qRCoWeVmYRhzWDK3xjeSar(dzeGmAKxuh0sa95eG8((qaALZbMAzvREpqgbci6e83aMe6)E4JkdUdqRCoWulRAzQw9idvibnypaQwAR9wTwSuB21kQdAjazG02)pTkqaALZbMAzSww1kkXhKGm2qsWjZa1sBTeWwNgvlRAzQwcyRtJQnVAVXoR1ILAZUwekX9FpWulJr(ZvhhKeL4dckA9TOeToheZmYdTY5at8Yi)dtsnKHeT(wKxpYG7iVhg7seaH)KdeLO13UlMzKhALZbM4Lr(dzeGmAKxuh0sa95eG8((qaALZbMAzvROoOLaKbsB))0QabOvohyQLvT6rgQqcAWEauTuQ9wTSQL7)Eb0NtaY77dbcyRtJQnVAVfyFKxpYG7iVVsiybIsuI8acb9bqXmJwFlMzKhALZbM4Lr(dzeGmAKhAG4FvqgBij4KTMrT0w7TAzvB21AaU)7fOcTberdFVAzvlt1MDTgSeo4(aTqubmPNtTHe3N0bzoSnTFTSQn7A1Jm4oCW9bAHOcyspNAdHPtp34txQ1ILAFFNlrGdDL4djzSHAZRw)JjyRzulJrE9idUJ8hCFGwiQaM0ZP2quIwFrmZip0kNdmXlJ8hYiaz0iVb4(VxGk0gqen89QLvTmvRb4(VxWxjeSabidK2()Pvbm1AXsTgG7)Ebe9HA47vlRApyBoCYdpTGcg4nNrQnpk1ERwlwQ1aC)3lqfAdiIgiGTonQ28Ou7T7QLXATyP234txseWwNgvBEuQ92DrE9idUJ8Com2KWVKqhsqd2xfLO1SpMzKhALZbM4Lr(dzeGmAK)GXodo)oqfAdiIgiGTonQ28QL91AXsTgG7)EbQqBar0W3RwlwQ9n(0LebS1Pr1MxTS)UiVEKb3rE)VsmJ2j8lP3deSqpkrRZAmZip0kNdmXlJ8hYiaz0i)ZHXKAzQwMQ9n(0LebS1Pr1YU1Y(7QLXAZTw9idUthm2zW531YyT0w7ZHXKAzQwMQ9n(0LebS1Pr1YU1Y(7QLDR9GXodo)oqfAdiIgiGTonQwgRn3A1Jm4oDWyNbNFxlJrE9idUJ8(FLygTt4xsVhiyHEuIwNZyMrEOvohyIxg5pKraYOrEKh4Cjrj(GGcpTt4xITEOcOAPLsTxuRfl1s0XKaQqlb1yqHPRL2AV27QLvTqde)RQnVAVg3f51Jm4oY)WNpcmj9EGmcK4a1okrRV2yMrEOvohyIxg5pKraYOrEKh4Cjrj(GGcpTt4xITEOcOAPLsTxuRfl1s0XKaQqlb1yqHPRL2AV27I86rgCh59(K5D10(joNIKOeT(AeZmYdTY5at8Yi)HmcqgnYZ9FVaboS5aek9WKde(E1AXsTC)3lqGdBoaHspm5aPd(3cqcirpSvBE1E7UiVEKb3rEHoK(nh(3M0dtoquIwZoJzg51Jm4oYtgpphKMoH80de5Hw5CGjEzuIwNdIzg51Jm4oYNpM4muHPteaHBTpqKhALZbM4LrjA9T7Izg5Hw5CGjEzK)qgbiJg5Hgi(xvBE1MZ7QLvTzx7bJDgC(DGk0gqen89I86rgCh5TbBm5Qe(LC)ZysgcO2OOeT(2TyMrEOvohyIxg51Jm4oYta1BA)0ZP2akYFiJaKrJ8Is8bjiJnKeCYmqT5v7TqoR1ILAzQwMQvuIpib6G6e6bVJulT1YoVRwlwQvuIpib6G6e6bVJuBEuQ9I7QLXAzvlt1QhzOcjOb7bq1sP2B1AXsTIs8bjiJnKeCYmqT0w7f5GAzSwgR1ILAzQwrj(GeKXgsco5DK0f3vlT1Y(7QLvTmvREKHkKGgShavlLAVvRfl1kkXhKGm2qsWjZa1sBTznR1YyTmg5pxDCqsuIpiOO13IsuI8g4PFNeZmA9TyMrE9idUJ8Snh2I8qRCoWeVmkrRViMzKxpYG7ipsa1j0J8qRCoWeVmkrRzFmZip0kNdmXlJ8yVipcKiVEKb3rEQkzuohe5PQUpe5Hgi(xfiGp01YCTE4bHBWK4Cayq1sZ1EnQn3AzQ2lQLMRf5boxIUIeOwgJ8uvsQvBiYdnq8VkraFOthSn30GjkrRZAmZip0kNdmXlJ8yVipcKiVEKb3rEQkzuohe5PQUpe5rEGZLeL4dck80oHFj26HkGQnVAViYtvjPwTHipAAFhKeL4dsuIwNZyMrEOvohyIxg5pKraYOrEKaQtOdMab7)HiVEKb3r(J6Cj9idUtUbjrE3GKuR2qKhjG6e6GjkrRV2yMrEOvohyIxg5pKraYOrEMQn7Af1bTeSvKaKKIqkcnDaALZbMATyPwdwc(kHGfiiZHTP9RLXiVEKb3r(J6Cj9idUtUbjrE3GKuR2qK)yqrjA91iMzKhALZbM4LrE9idUJ8h15s6rgCNCdsI8UbjPwTHiVblrjAn7mMzKhALZbM4Lr(dzeGmAKN7)EbKBoqsBtYmhiqaBDAuT5vROeFqcYydjbNmdulRA5(Vxa5MdK02KmZbceWwNgvBE1YuT3QL5ApyBoCYdpTGQLXAP5AVfyNrE9idUJ8i3CGK2MKzoquIwNdIzg5Hw5CGjEzKxpYG7i)rDUKEKb3j3GKiVBqsQvBiYBgcCKOeT(2DXmJ8qRCoWeVmYFiJaKrJ8qde)Rcg4nNrQLwk1ElN1YCTuvYOCoianq8VkraFOthSn30GjYRhzWDKxjhTHKGjeOLOeT(2TyMrE9idUJ8k5OnK8(oee5Hw5CGjEzuIwF7IyMrE9idUJ8UXNUGszH(gFBOLip0kNdmXlJs06BSpMzKxpYG7ipN6NWVKqMdBOip0kNdmXlJsuI8Ee4GT5ujMz06BXmJ86rgCh5vpp3vjp8GWDKhALZbM4LrjA9fXmJ86rgCh59WYG7ip0kNdmXlJs0A2hZmYdTY5at8YiVEKb3rEBLWgyspmjzavOh5pKraYOrEIoMeqfAjOgdkmDT0w7TCg59iWbBZPscbhCBqr(CgLO1znMzKxpYG7ipsa1j0J8qRCoWeVmkrRZzmZip0kNdmXlJ86rgCh5rU5ajTnjZCGiVhboyBovsi4GBdkYFlkrRV2yMrEOvohyIxg5B1gI869i6krrPhULe(L8W5dKiVEKb3rE9EeDLOO0d3sc)sE48bsuIwFnIzg5Hw5CGjEzK)qgbiJg5f1bTeGmqA7)NwfiaTY5atKxpYG7iV)xjMr7e(L07bcwOhLOe5ndbosmZO13Izg5Hw5CGjEzK)qgbiJg5zQ2d2MdN8WtlOAPLsTzTwMRvuh0sWaGhqsiHOI6d2bOvohyQ1ILApyBoCYdpTGQLsTAp26HUs8bt64vlJ1YQwMQ1aC)3lqfAdiIg(E1AXsTgG7)Ebe9HA47vRfl1cnq8VkyG3CgP28Ou7f5SwMRLQsgLZbbObI)vjc4dD6GT5Mgm1AXsTzxlvLmkNdcOP9DqsuIpi1YyTSQLPAZUwrDqlbidK2()PvbcqRCoWuRfl1EWyNbNFhGmqA7)NwfiqaBDAuT0w7f1YyKxpYG7ip0uHgBhLO1xeZmYdTY5at8Yip2lYJajYRhzWDKNQsgLZbrEQQ7dr(d2MdN8WtlOGbEZzKAPT2B1AXsTqde)Rcg4nNrQnpk1EroRL5APQKr5CqaAG4FvIa(qNoyBUPbtTwSuB21svjJY5GaAAFhKeL4dsKNQssTAdr(pcsVX5asuIwZ(yMrEOvohyIxg51Jm4oYJacrfWK4WnKqEdBqK)qgbiJg5ZUwdwciGqubmjoCdjK3WgeK5W20(1AXsTuvYOCoi8rq6nohqQLvTmvREKHkKGgShavlLAVvlRAj6ysavOLGAmOW01sBTVVZLiWHUs8HKm2qTwSu7HUs8buT0w7f1YQwrj(GeKXgscozgO28QnN1YyK)C1Xbjrj(GGIwFlkrRZAmZip0kNdmXlJ8hYiaz0ipvLmkNdcFeKEJZbKAzvREpqgbcWHoEA)eNtnakaTY5atTSQf5boxsuIpiOWt7e(LyRhQaQwAPu7f1YCTmvRb4(VxGk0gqen89QLMRLPAVvlZ1YuT69azeiah64P9tCo1aOarB2QLsT3QLXAzSwgJ86rgCh5FANWVeB9qfqrjADoJzg5Hw5CGjEzK)qgbiJg5PQKr5Cq4JG0BCoGulRAzQwU)7fOpgd0joNAauaj6HTAPLsT3Yb1AXsTmvB216rgmzKRseSOYG7AzvlYdCUKOeFqqHN2j8lXwpubuT0sP2SwlZ1YuT69azeiyWFohKmyeeiAZwT0w7f1YyTmxlsa1j0btGG9)qTmwlJrE9idUJ8pTt4xITEOcOOeT(AJzg5Hw5CGjEzKxpYG7i)t7e(LyRhQakYFiJaKrJ8uvYOCoi8rq6nohqQLvTipW5sIs8bbfEANWVeB9qfq1slLAzFK)C1Xbjrj(GGIwFlkrRVgXmJ8qRCoWeVmYFiJaKrJ8uvYOCoi8rq6nohqI86rgCh5HdD80(jc4rgBTnrjAn7mMzKhALZbM4Lr(dzeGmAKNQsgLZbHpcsVX5asKxpYG7iVAZ9r0Js06CqmZip0kNdmXlJ86rgCh5T)Y4ubI8hYiaz0ipvLmkNdcFeKEJZbKAzvlYdCUKOeFqqHN2j8lXwpubuTuQ9Ii)5QJdsIs8bbfT(wuIwF7UyMrEOvohyIxg5pKraYOrEQkzuohe(ii9gNdirE9idUJ82FzCQarjkr(JbfZmA9TyMrEOvohyIxg51Jm4oYR3JORefLE4ws4xYdNpqI8hYiaz0iF21IeqDcDWeuNRww1ARibijfHueA6ebS1Pr1sP27QLvTmv7bJDgC(DGk0gqenqaBDAuT5LLRwMQ9GXodo)oGOpudeWwNgvlnxlKL(JNhyckIovTbuIO3JjPdMOUAzSwgRnVAVDxTmx7T7QLMRfYs)XZdmbfrNQ2akr07XK0btuxTSQn7Ana3)9cuH2aIOHVxTSQn7Ana3)9ci6d1W3lY3Qne517r0vIIspClj8l5HZhirjA9fXmJ8qRCoWeVmYFiJaKrJ8zxlsa1j0btqDUAzvRblbY3t(eiiZHTP9RLvT2ksassrifHMoraBDAuTuQ9UiVEKb3r(J6Cj9idUtUbjrE3GKuR2qKhqiOpakkrRzFmZip0kNdmXlJ86rgCh5TvcBGj9WKKbuHEK)qgbiJg5j6ysavOLGAmOW3Rww1YuTIs8bjiJnKeCYmqT5v7bBZHtE4PfuWaV5msT0CT3c5SwlwQ9GT5Wjp80ckyG3CgPwAPu7XlzRzKqEqBQLXi)5QJdsIs8bbfT(wuIwN1yMrEOvohyIxg5pKraYOrEIoMeqfAjOgdkmDT0wl7VRw2TwIoMeqfAjOgdky(evgCxlRApyBoCYdpTGcg4nNrQLwk1E8s2AgjKh0MiVEKb3rEBLWgyspmjzavOhLO15mMzKxpYG7i)ZP(GZPYG7ip0kNdmXlJs06RnMzKhALZbM4Lr(dzeGmAK3aC)3l8CQp4CQm4oqaBDAuT5v7f1AXsTgG7)EHNt9bNtLb3bKOh2QLwk1M17I86rgCh5Fo1hCovgCNooqBeeLO1xJyMrEOvohyIxg5XErEeirE9idUJ8uvYOCoiYtvDFiYNDTI6GwcOpNaK33hcqRCoWuRfl1MDT69azeiGOtWFdysO)7HpQm4oaTY5atTwSuRblbFLqWce8S)oz8CdqQL2AVvlRAzQwKh4Cjrj(GGcpTt4xITEOcOAZR2RTwlwQn7ApySZGZVdu1Eq0dFVAzmYtvjPwTHipvOnGiAc95eG8((q6GBZidUJs0A2zmZip0kNdmXlJ8yVipcKiVEKb3rEQkzuohe5PQUpe5ZUwrDqlHE8PlirDSbKa0kNdm1AXsTzxROoOLaKbsB))0QabOvohyQ1ILApySZGZVdqgiT9)tRceiGTonQ28QnN1YU1ErT0CTI6Gwcga8ascjevuFWoaTY5atKNQssTAdrEQqBar0up(0fKOo2as6GBZidUJs06CqmZip0kNdmXlJ8yVipcKiVEKb3rEQkzuohe5PQUpe5ZUwil9hppWe07r0vIIspClj8l5HZhi1AXsT69azeiGOtWFdysO)7HpQm4oaTY5atTwSuRb4(VxGO3JjPdMOUKb4(VxWGZVR1ILApySZGZVdkIovTbuIO3JjPdMOUabS1Pr1MxT3URww1YuThm2zW53be9HAGa260OAZR2B1AXsTgG7)Ebe9HA47vlJrEQkj1Qne5PcTbertpClPdUnJm4okrRVDxmZip0kNdmXlJ8hYiaz0iF21IeqDcDWeiy)pulRAnyjq(EYNabzoSnTFTSQn7Ana3)9cuH2aIOHVxTSQLQsgLZbbQqBar0e6Zja599H0b3MrgCxlRAPQKr5CqGk0gqen1JpDbjQJnGKo42mYG7AzvlvLmkNdcuH2aIOPhUL0b3MrgCh51Jm4oYtfAdiIgLO13UfZmYdTY5at8Yi)HmcqgnYlQdAjazG02)pTkqaALZbMAzvROoOLqp(0fKOo2asaALZbMAzv7bBZHtE4PfuT0sP2JxYwZiH8G2ulRApySZGZVdqgiT9)tRceiGTonQ28Q9wKxpYG7ipvThe9OeT(2fXmJ8qRCoWeVmYFiJaKrJ8I6Gwc94txqI6ydibOvohyQLvTzxROoOLaKbsB))0QabOvohyQLvThSnho5HNwq1slLApEjBnJeYdAtTSQLPAna3)9cuH2aIOHVxTwSulGqqFGa1bn4oHFjpG8GJm4oaTY5atTmg51Jm4oYtv7brpkrRVX(yMrEOvohyIxg5XErEeirE9idUJ8uvYOCoiYtvDFiYR3dKrGaIob)nGjH(Vh(OYG7a0kNdm1YQwMQTXDcHsC)3dmjrj(GGQLwk1ERwlwQf5boxsuIpiOWt7e(LyRhQaQwk1Y(AzSww1YuTiuI7)EGjjkXheus5WuHKN2gWEo1sP27Q1ILArEGZLeL4dck80oHFj26HkGQLwk1ET1YyKNQssTAdrEekrv7brpDWTzKb3rjA9TSgZmYdTY5at8YiVEKb3rEpm2Liac)jhiYdzienP24Flr(SMZi)dtsnKHeT(wuIwFlNXmJ8qRCoWeVmYFiJaKrJ8I6GwcOpNaK33hcqRCoWulRAZUwKaQtOdMab7)HAzv7bJDgC(DWxjeSaHVxTSQLPAPQKr5CqaHsu1Eq0thCBgzWDTwSuB21Q3dKrGaIob)nGjH(Vh(OYG7a0kNdm1YQwMQ1GLGVsiybce4raeDLZb1AXsTgG7)EbQqBar0W3Rww1AWsWxjeSabp7Vtgp3aKAZJsT3QLXAzSww1EW2C4KhEAbfmWBoJulTuQLPAzQ2B1YCTxulnxREpqgbci6e83aMe6)E4JkdUdqRCoWulJ1sZ1I8aNljkXheu4PDc)sS1dvavlJ1sBwUAZATSQLOJjbuHwcQXGctxlT1E7IiVEKb3rEQApi6rjA9TRnMzKhALZbM4Lr(dzeGmAKNPAf1bTeSvKaKKIqkcnDaALZbMATyPwYVHhM4dbBLWwc)scDizRibijfHueA6aKL(JNhyQLXAzvB21IeqDcDWeuNRww1ARibijfHueA6ebS1Pr1MhLAVRww1MDTgSeiFp5tGabEearx5CqTSQ1GLGVsiybceWwNgvlT1Y(Azvlt1AaU)7fOcTberdFVAzvRb4(VxarFOg(E1YQwMQn7Abec6de4CySjHFjHoKGgSVkyRzHWKATyPwdW9FVaNdJnj8lj0He0G9vHVxTmwRfl1cie0hiqDqdUt4xYdip4idUdqRCoWulJrE9idUJ8u1Eq0Js06BxJyMrEOvohyIxg5pKraYOr(SRfjG6e6GjOoxTSQvVhiJabeDc(Batc9Fp8rLb3bOvohyQLvTgSe8vcblqGapcGORCoOww1AWsWxjeSabp7Vtgp3aKAZJsT3QLvThSnho5HNwqbd8MZi1slLAVf51Jm4oYJORgC(2GZeLO13yNXmJ8qRCoWeVmYFiJaKrJ8zxlsa1j0btGG9)qTSQLPAZUwdwc(kHGfiqGhbq0vohulRAnyjq(EYNabcyRtJQL2AZATmxBwRLMR94LS1msipOn1AXsTgSeiFp5tGabS1Pr1sZ1ExiN1sBTIs8bjiJnKeCYmqTmwlRAfL4dsqgBij4KzGAPT2Sg51Jm4oYdzG02)pTkquIwFlheZmYdTY5at8Yi)HmcqgnY7aQGRwAPuBozN1YQwdwcKVN8jqqMdBt7xlRAzQ2SRfYs)XZdmb9EeDLOO0d3sc)sE48bsTwSu7bJDgC(DGk0gqenqaBDAuT0w7T7QLXiVEKb3rEe9HAuIwFXDXmJ8qRCoWeVmYFiJaKrJ8C)3lW5WyJ7JKab0JuRfl1AaU)7fOcTberdFViVEKb3rEpSm4okrRV4wmZip0kNdmXlJ8hYiaz0iVb4(VxGk0gqen89I86rgCh55CySj9(KRIs06lUiMzKhALZbM4Lr(dzeGmAK3aC)3lqfAdiIg(ErE9idUJ8Cabbe2M2pkrRVG9XmJ8qRCoWeVmYFiJaKrJ8gG7)EbQqBar0W3lYRhzWDK)neGZHXMOeT(ISgZmYdTY5at8Yi)HmcqgnYBaU)7fOcTberdFViVEKb3rETpasiQlDuNlkrRViNXmJ8qRCoWeVmYRhzWDK3xDWrDoGGsCyCh5pKraYOrEMQ1aC)3lqfAdiIg(E1AXsTmvB21kQdAjazG02)pTkqaALZbMAzv7bJDgC(DGk0gqenqaBDAuT0wBwZzTwSuROoOLaKbsB))0QabOvohyQLvTmv7bJDgC(DaYaPT)FAvGabS1Pr1MxTxBTwSu7bJDgC(DaYaPT)FAvGabS1Pr1sBTxCxTSQ9n(0LebS1Pr1sBTxBoRLXAzSwgRLvTzxRb4(VxG89KpbcqgiT9)tRcyI8TAdrEF1bh15ackXHXDuIwFX1gZmYdTY5at8YiVEKb3rEfrNQ2akr07XK0btuxK)qgbiJg5na3)9ce9EmjDWe1Lma3)9cgC(DTwSuROeFqcYydjbNmduBE1EXDr(wTHiVIOtvBaLi69ys6GjQlkrRV4AeZmYdTY5at8YiVEKb3rEfrNQ2akr07XK0btuxK)qgbiJg5zQ2SRvuh0saYaPT)FAvGa0kNdm1AXsTzxROoOLa6Zja599Ha0kNdm1YyTSQ1aC)3lqfAdiIgiGTonQwAR92D1YU1M1AP5AHS0F88atqVhrxjkk9WTKWVKhoFGe5B1gI8kIovTbuIO3JjPdMOUOeT(c2zmZip0kNdmXlJ86rgCh5veDQAdOerVhtshmrDr(dzeGmAKNPAf1bTeGmqA7)NwfiaTY5atTSQvuh0sa95eG8((qaALZbMAzSww1AaU)7fOcTberdFVAzvlt1AaU)7f8vcblqaYaPT)FAvatTwSuREpqgbci6e83aMe6)E4JkdUdqRCoWulRAnyj4RecwGGN93jJNBasT0w7TAzmY3Qne5veDQAdOerVhtshmrDrjA9f5GyMrEOvohyIxg51Jm4oYFU64Wcb3ZjX5uKe5pKraYOrEBfjajPiKIqtNiGTonQwk1ExTSQn7Ana3)9cuH2aIOHVxTSQn7Ana3)9ci6d1W3Rww1Y9FVGnyJjxLWVK7FgtYqa1gfm487Azvl0aX)QAZRw25D1YQwdwcKVN8jqGa260OAPT2Sg5H3dosQvBiYFU64Wcb3ZjX5uKeLO1S)UyMrEOvohyIxg51Jm4oY7(e2acknnAmd(Js(ZtI8hYiaz0iVb4(VxGk0gqen89I8TAdrE3NWgqqPPrJzWFuYFEsuIwZ(BXmJ8qRCoWeVmYRhzWDK39rcb)rjFSZaDYZ9TvFiYFiJaKrJ8gG7)EbQqBar0W3lY3Qne5DFKqWFuYh7mqN8CFB1hIs0A2FrmZip0kNdmXlJ86rgCh59DQzubtqjBWOo3G7i)HmcqgnYBaU)7fOcTberdFVip8EWrsTAdrEFNAgvWeuYgmQZn4okrRzp7Jzg5Hw5CGjEzKxpYG7iVVtnJkyckXPgFiYFiJaKrJ8gG7)EbQqBar0W3lYdVhCKuR2qK33PMrfmbL4uJpeLO1SpRXmJ86rgCh5)iincyJI8qRCoWeVmkrjYBWsmZO13Izg5Hw5CGjEzKh7f5rGe51Jm4oYtvjJY5Gipv19HiVhzWKrUkrWIkdURLvTipW5sIs8bbfEANWVeB9qfq1sBTSVww1YuTgSe8vcblqGa260OAZR2dg7m487GVsiybcMprLb31AXsTE4bHBWK4Cayq1sBT5SwgJ8uvsQvBiYJyB8sNRooi5RecwGOeT(IyMrEOvohyIxg5XErEeirE9idUJ8uvYOCoiYtvDFiY7rgmzKRseSOYG7AzvlYdCUKOeFqqHN2j8lXwpubuT0wl7RLvTmvRb4(VxarFOg(E1AXsTmvRhEq4gmjohaguT0wBoRLvTzxREpqgbcOd0sc)sCom2eGw5CGPwgRLXipvLKA1gI8i2gV05QJdsKVN8jquIwZ(yMrEOvohyIxg5XErEeirE9idUJ8uvYOCoiYtvDFiYBaU)7fOcTberdFVAzvlt1AaU)7fq0hQHVxTwSuRTIeGKuesrOPteWwNgvlT1ExTmwlRAnyjq(EYNabcyRtJQL2AViYtvjPwTHipITXlr(EYNarjADwJzg5Hw5CGjEzK)qgbiJg5f1bTeGmqA7)NwfiaTY5atTSQn7Ana3)9c(kHGfiazG02)pTkGPww1AWsWxjeSabp7Vtgp3aKAZJsT3QLvThm2zW53bidK2()PvbceWwNgvBE1ErTSQf5boxsuIpiOWt7e(LyRhQaQwk1ERww1s0XKaQqlb1yqHPRL2AV2AzvRblbFLqWceiGTonQwAU27c5S28QvuIpibzSHKGtMbI86rgCh59vcblquIwNZyMrEOvohyIxg5pKraYOrErDqlbidK2()PvbcqRCoWulRAzQ2d2MdN8WtlOAPLsThVKTMrc5bTPww1EWyNbNFhGmqA7)NwfiqaBDAuT5v7TAzvRblbY3t(eiqaBDAuT0CT3fYzT5vROeFqcYydjbNmdulJrE9idUJ8KVN8jquIwFTXmJ8qRCoWeVmY)WKudzirRVf51Jm4oY7HXUebq4p5arjA91iMzKhALZbM4Lr(dzeGmAKNapcGORCoOww1EW2C4KhEAbfmWBoJulTuQ9wTmxl7RLMRLPA17bYiqarNG)gWKq)3dFuzWDaALZbMAzv7bJDgC(DGQ2dIE47vlJ1YQwMQ1Z(7KXZnaP28Ou7TATyPwcyRtJQnpk1kZHTKm2qTSQf5boxsuIpiOWt7e(LyRhQaQwAPul7RL5A17bYiqarNG)gWKq)3dFuzWDaALZbMAzSww1YuTzxlKbsB))0QaMATyPwcyRtJQnpk1kZHTKm2qT0CTxulRArEGZLeL4dck80oHFj26HkGQLwk1Y(AzUw9EGmceq0j4Vbmj0)9WhvgChGw5CGPwgRLvTzxlcL4(VhyQLvTmvROeFqcYydjbNmdul7wlbS1Pr1YyT0wBwRLvTmvRTIeGKuesrOPteWwNgvlLAVRwlwQn7AL5W20(1YQw9EGmceq0j4Vbmj0)9WhvgChGw5CGPwgJ86rgCh59vcblquIwZoJzg5Hw5CGjEzK)HjPgYqIwFlYRhzWDK3dJDjcGWFYbIs06CqmZip0kNdmXlJ86rgCh59vcblqK)qgbiJg5ZUwQkzuoheqSnEPZvhhK8vcblqTSQLapcGORCoOww1EW2C4KhEAbfmWBoJulTuQ9wTmxl7RLMRLPA17bYiqarNG)gWKq)3dFuzWDaALZbMAzv7bJDgC(DGQ2dIE47vlJ1YQwMQ1Z(7KXZnaP28Ou7TATyPwcyRtJQnpk1kZHTKm2qTSQf5boxsuIpiOWt7e(LyRhQaQwAPul7RL5A17bYiqarNG)gWKq)3dFuzWDaALZbMAzSww1YuTzxlKbsB))0QaMATyPwcyRtJQnpk1kZHTKm2qT0CTxulRArEGZLeL4dck80oHFj26HkGQLwk1Y(AzUw9EGmceq0j4Vbmj0)9WhvgChGw5CGPwgRLvTzxlcL4(VhyQLvTmvROeFqcYydjbNmdul7wlbS1Pr1YyT0w7TlQLvTmvRTIeGKuesrOPteWwNgvlLAVRwlwQn7AL5W20(1YQw9EGmceq0j4Vbmj0)9WhvgChGw5CGPwgJ8NRooijkXheu06BrjA9T7Izg5Hw5CGjEzK)qgbiJg5rEGZLeL4dcQwAPu7f1YQwcyRtJQnVAVOwMRLPArEGZLeL4dcQwAPuBoRLXAzv7bBZHtE4PfuT0sP2Sg51Jm4oYFiJnc3jbS9aKeLO13UfZmYdTY5at8Yi)HmcqgnYNDTuvYOCoiGyB8sKVN8jqTSQLPApyBoCYdpTGQLwk1M1AzvlbEearx5CqTwSuB21kZHTP9RLvTmvRm2qT0w7T7Q1ILApyBoCYdpTGQLwk1ErTmwlJ1YQwMQ1Z(7KXZnaP28Ou7TATyPwcyRtJQnpk1kZHTKm2qTSQf5boxsuIpiOWt7e(LyRhQaQwAPul7RL5A17bYiqarNG)gWKq)3dFuzWDaALZbMAzSww1YuTzxlKbsB))0QaMATyPwcyRtJQnpk1kZHTKm2qT0CTxulRArEGZLeL4dck80oHFj26HkGQLwk1Y(AzUw9EGmceq0j4Vbmj0)9WhvgChGw5CGPwgRLvTIs8bjiJnKeCYmqTSBTeWwNgvlT1M1iVEKb3rEY3t(eikrRVDrmZip0kNdmXlJ86rgCh5jFp5tGi)HmcqgnYNDTuvYOCoiGyB8sNRooir(EYNa1YQ2SRLQsgLZbbeBJxI89KpbQLvThSnho5HNwq1slLAZATSQLapcGORCoOww1YuTE2FNmEUbi1MhLAVvRfl1saBDAuT5rPwzoSLKXgQLvTipW5sIs8bbfEANWVeB9qfq1slLAzFTmxREpqgbci6e83aMe6)E4JkdUdqRCoWulJ1YQwMQn7AHmqA7)NwfWuRfl1saBDAuT5rPwzoSLKXgQLMR9IAzvlYdCUKOeFqqHN2j8lXwpubuT0sPw2xlZ1Q3dKrGaIob)nGjH(Vh(OYG7a0kNdm1YyTSQvuIpibzSHKGtMbQLDRLa260OAPT2Sg5pxDCqsuIpiOO13Is06BSpMzKhALZbM4Lr(dzeGmAKh5boxsuIpiOAPu7TAzv7bBZHtE4PfuT0sPwMQ94LS1msipOn1YU1ERwgRLvTe4raeDLZb1YQ2SRfYaPT)FAvatTSQn7Ana3)9ci6d1W3Rww1ARibijfHueA6ebS1Pr1sP27QLvTzxREpqgbcs(dsscDiXwppiaTY5atTSQvuIpibzSHKGtMbQLDRLa260OAPT2Sg51Jm4oYFiJnc3jbS9aKeLO13YAmZiVEKb3rEe4HguKhALZbM4LrjkrjYtfiOb3rRV4UlU72D3Uf5Zxj90(Oip7qAmnY6SaRVU0WARnt6qTJThMi1(WKAZraHG(aOCSwcKL(dbm1IW2qT6xW2QaMAp012hqHIHRZ0qTxqdR96XnvGiGP2CeYaPT)FAvatGDmhRvW1MJgG7)Eb2XaKbsB))0QaMCSwMULbJHIHRZ0qTzLgw71JBQaratT8J91xl6Qw0mQLgCTcU2RZxR1muh0G7AXEarfmPwMYLXAz6ImymumumWoKgtJSolW6RlnS2AZKou7y7HjsTpmP2C0ap97KCSwcKL(dbm1IW2qT6xW2QaMAp012hqHIHRZ0qTSNgw71JBQaratT8J91xl6Qw0mQLgCTcU2RZxR1muh0G7AXEarfmPwMYLXAz6wgmgkgkgyhsJPrwNfy91LgwBTzshQDS9WeP2hMuBoEmOCSwcKL(dbm1IW2qT6xW2QaMAp012hqHIHRZ0qT5aAyTxpUPcebm1MJczA2ajWogoySZGZVZXAfCT54bJDgC(DGDmhRLPBzWyOy46mnu7f5Kgw71JBQaratT5iKbsB))0QaMa7yowRGRnhna3)9cSJbidK2()Pvbm5yTmDldgdfdxNPHAVGDsdR96XnvGiGP2CeYaPT)FAvatGDmhRvW1MJgG7)Eb2XaKbsB))0QaMCSwMULbJHIHIb2H0yAK1zbwFDPH1wBM0HAhBpmrQ9Hj1MJgSKJ1sGS0FiGPwe2gQv)c2wfWu7HU2(akumCDMgQnR0WAVECtficyQnhHmqA7)NwfWeyhZXAfCT5Ob4(VxGDmazG02)pTkGjhRLPBzWyOyOyilW2dteWu71Ow9idUR1nibfkgI8ip4eT(ICMdI8Ee8BCqKNMQLgJqkcnTkdURLgH9)qXanvBwEhbZbKAVDZQAV4UlURyOyGMQnlMbC(cyQLdEycu7bBZPsTCG)0OqT04Zb8euTnUzx6kX(9D1QhzWnQwC7UkumOhzWnk4rGd2MtfkQNN7QKhEq4UyqpYGBuWJahSnNkmtjxpSm4UyqpYGBuWJahSnNkmtjxBLWgyspmjzavOBLhboyBovsi4GBdIsoTAEui6ysavOLGAmOW00ElNfd6rgCJcEe4GT5uHzk5IeqDc9Ib9idUrbpcCW2CQWmLCrU5ajTnjZCaR8iWbBZPscbhCBquUvmOhzWnk4rGd2MtfMPK7hbPraBRA1gOO3JORefLE4ws4xYdNpqkg0Jm4gf8iWbBZPcZuY1)ReZODc)s69abl0TAEue1bTeGmqA7)NwfiaTY5atXqXanvBwmd48fWulqfixvRm2qTcDOw9iysTdQwLQooLZbHIb9idUruyBoSvmqt1sJaKaQtOx78Q1dJqdNdQLPgxl1VRbIY5GAHgShav701EW2CQWyXGEKb3iMPKlsa1j0lg0Jm4gXmLCPQKr5CGvTAduGgi(xLiGp0Pd2MBAWyfv19bkqde)RceWhAM9Wdc3GjX5aWGO5RbnyMUGMrEGZLORibySyqpYGBeZuYLQsgLZbw1QnqbnTVdsIs8bXkQQ7duqEGZLeL4dck80oHFj26HkGY7IIb9idUrmtj3J6Cj9idUtUbjw1QnqbjG6e6GXQ5rbjG6e6GjqW(FOyqpYGBeZuY9OoxspYG7KBqIvTAduogKvZJctzlQdAjyRibijfHueA6a0kNdmwSyWsWxjeSabzoSnTpJfd6rgCJyMsUh15s6rgCNCdsSQvBGIblfd6rgCJyMsUi3CGK2MKzoGvZJc3)9ci3CGK2MKzoqGa260O8eL4dsqgBij4KzawC)3lGCZbsABsM5abcyRtJYJPBmFW2C4KhEAbXinFlWolg0Jm4gXmLCpQZL0Jm4o5gKyvR2afZqGJumOhzWnIzk5QKJ2qsWec0IvZJc0aX)QGbEZzeAPClNmtvjJY5Ga0aX)Qeb8HoDW2CtdMIb9idUrmtjxLC0gsEFhckg0Jm4gXmLCDJpDbLYc9n(2qlfd6rgCJyMsUCQFc)sczoSHkgkgOPAVEm2zW53OIb9idUrHJbr5JG0iGTvTAdu07r0vIIspClj8l5HZhiwnpkzJeqDcDWeuNJLTIeGKuesrOPteWwNgr5owmDWyNbNFhOcTberdeWwNgLxwoMoySZGZVdi6d1abS1Pr0mKL(JNhyckIovTbuIO3JjPdMOogzmVB3X8T7Ozil9hppWeueDQAdOerVhtshmrDSY2aC)3lqfAdiIg(ESY2aC)3lGOpudFVIb9idUrHJbXmLCpQZL0Jm4o5gKyvR2afaHG(aiRMhLSrcOoHoycQZXYGLa57jFceK5W20(SSvKaKKIqkcnDIa260ik3vmqt1Mf8QvnguTkbQ97zvTOE8GAf6qT4gQn)rOxRdNpGKAZmtAGqT0GGGAZNo01AUAA)AFksasTcDTR96VM1AG3CgPwmP28hHo(l1Q9v1E9xZqXGEKb3OWXGyMsU2kHnWKEysYaQq3QZvhhKeL4dcIYnRMhfIoMeqfAjOgdk89yXKOeFqcYydjbNmdK3bBZHtE4PfuWaV5mcnFlKtlwoyBoCYdpTGcg4nNrOLYXlzRzKqEqBySyGMQnl4vBJRvnguT5poxTMbQn)rOpDTcDO2gYqQL93HSQ2pcQnl7rdulURLdJq1M)i0XFPwTVQ2R)Agkg0Jm4gfogeZuY1wjSbM0dtsgqf6wnpkeDmjGk0sqnguyAAz)DSlrhtcOcTeuJbfmFIkdUzDW2C4KhEAbfmWBoJqlLJxYwZiH8G2umOhzWnkCmiMPK7ZP(GZPYG7Ib9idUrHJbXmLCFo1hCovgCNooqBey18OyaU)7fEo1hCovgChiGTonkVlSyXaC)3l8CQp4CQm4oGe9WgTuY6Dfd0uT5qOnGiAToS)CuxThCBgzWT6q1YPiWulUR98jeOLArEWPyqpYGBu4yqmtjxQkzuohyvR2afQqBar0e6Zja599H0b3MrgCBfv19bkzlQdAjG(CcqEFFiaTY5aJflzR3dKrGaIob)nGjH(Vh(OYG7a0kNdmwSyWsWxjeSabp7Vtgp3aeAVXIjKh4Cjrj(GGcpTt4xITEOcO8UwlwY(GXodo)oqv7brp89ySyqpYGBu4yqmtjxQkzuohyvR2afQqBar0up(0fKOo2as6GBZidUTIQ6(aLSf1bTe6XNUGe1XgqcqRCoWyXs2I6GwcqgiT9)tRceGw5CGXILdg7m487aKbsB))0QabcyRtJYlNS7f0SOoOLGbapGKqcrf1hSdqRCoWumOhzWnkCmiMPKlvLmkNdSQvBGcvLmkNdSQvBGcvOnGiA6HBjDWTzKb3wrvDFGs2qw6pEEGjO3JORefLE4ws4xYdNpqSyrVhiJabeDc(Batc9Fp8rLb3bOvohySyXaC)3lq07XK0btuxYaC)3lyW53wSiKPzdKGIOtvBaLi69ys6GjQlCWyNbNFhiGTonkVB3XIPdg7m487aI(qnqaBDAuE3SyXaC)3lGOpudFpglg0Jm4gfogeZuYLk0gqe1Q5rjBKaQtOdMab7)bwgSeiFp5tGGmh2M2Nv2gG7)EbQqBar0W3JfvLmkNdcuH2aIOj0NtaY77dPdUnJm4MfvLmkNdcuH2aIOPE8PlirDSbK0b3MrgCZIQsgLZbbQqBar00d3s6GBZidUlgOPAZHApi61M)i0RnlMbYVwMR16XNUGe1XgqOH1MLPzm2F7AV(RzTABQnlMbYVwcOMRQ9Hj12qgsTx3RNgOyqpYGBu4yqmtjxQApi6wnpkI6GwcqgiT9)tRceGw5CGHLOoOLqp(0fKOo2asaALZbgwhSnho5HNwq0s54LS1msipOnSoySZGZVdqgiT9)tRceiGTonkVBfd0uT5qThe9AZFe61A94txqI6ydi1YCTwJRnlMbYNgwBwMMXy)TR96VM1QTP2Ci0gqeT2VxTm9BhGq1(rt7xBoeFnzSyqpYGBu4yqmtjxQApi6wnpkI6Gwc94txqI6ydibOvohyyLTOoOLaKbsB))0QabOvohyyDW2C4KhEAbrlLJxYwZiH8G2WIjdW9FVavOnGiA47zXcGqqFGa1bn4oHFjpG8GJm4oaTY5adJfd0uT8au777C1EW22ql1I7APlIhIgMBU(Jq)Zfoy7CPrkvOPJDgHDZ86ZLgH9)qU5pSn5sJrifHMwLb3Sln(AEDyxAeGaLCOhkg0Jm4gfogeZuYLQsgLZbw1QnqbHsu1Eq0thCBgzWTvuv3hOO3dKrGaIob)nGjH(Vh(OYG7a0kNdmSyQXDcHsC)3dmjrj(GGOLYnlwqEGZLeL4dck80oHFj26HkGOWEgzXecL4(VhysIs8bbLuomvi5PTbSNdL7Syb5boxsuIpiOWt7e(LyRhQaIwkxlJfd6rgCJchdIzk56HXUebq4p5aw9WKudziuUzfKHq0KAJ)TqjR5SyqpYGBu4yqmtjxQApi6wnpkI6GwcOpNaK33hcqRCoWWkBKaQtOdMab7)bwhm2zW53bFLqWce(ESyIQsgLZbbekrv7brpDWTzKb3wSKTEpqgbci6e83aMe6)E4JkdUdqRCoWWIjdwc(kHGfiqGhbq0vohyXIb4(VxGk0gqen89yzWsWxjeSabp7Vtgp3aK8OCJrgzDW2C4KhEAbfmWBoJqlfMy6gZxqZ69azeiGOtWFdysO)7HpQm4oaTY5adJ0mYdCUKOeFqqHN2j8lXwpubeJ0MLlRSi6ysavOLGAmOW00E7IIbAQ2CO2dIET5pc9AZYuKaKAPXiKIMMgwR14ArcOoHETABQTX1QhzOc1MLrJRL7)Ewvln67jFcuBJLANUwc8iaIETeT9bRQ18jt7xBoeAdiIYCMxY8Lyjlwlt)2biuTF00(1MdXxtglg0Jm4gfogeZuYLQ2dIUvZJctI6Gwc2ksassrifHMoaTY5aJflKFdpmXhc2kHTe(Le6qYwrcqskcPi00bil9hppWWiRSrcOoHoycQZXYwrcqskcPi00jcyRtJYJYDSY2GLa57jFceiWJai6kNdyzWsWxjeSabcyRtJOL9SyYaC)3lqfAdiIg(ESma3)9ci6d1W3Jftzdie0hiW5Wytc)scDibnyFvWwZcHjwSyaU)7f4CySjHFjHoKGgSVk89y0IfaHG(abQdAWDc)sEa5bhzWDaALZbgglgOPA5PRgC(2GZu7dtQLNob)nGPw()7HpQm4UyqpYGBu4yqmtjxeD1GZ3gCgRMhLSrcOoHoycQZXsVhiJabeDc(Batc9Fp8rLb3bOvohyyzWsWxjeSabc8iaIUY5awgSe8vcblqWZ(7KXZnajpk3yDW2C4KhEAbfmWBoJqlLBfd0uTzXmqA7)NwfO28PdDTnwQfjG6e6GPwTn1YHf61sJ(EYNa1QTP2RRsiybQvjqTFVAFysToC7xl04Vp9qXGEKb3OWXGyMsUqgiT9)tRcy18OKnsa1j0btGG9)alMY2GLGVsiybce4raeDLZbSmyjq(EYNabcyRtJOnRmNvA(4LS1msipOnwSyWsG89KpbceWwNgrZ3fYjTIs8bjiJnKeCYmaJSeL4dsqgBij4KzaAZAXGEKb3OWXGyMsUi6dvRMhfhqfC0sjNStwgSeiFp5tGGmh2M2NftzdzP)45bMGEpIUsuu6HBjHFjpC(aXILdg7m487avOnGiAGa260iAVDhJfd6rgCJchdIzk56HLb3wnpkC)3lW5WyJ7JKab0JyXIb4(VxGk0gqen89kg0Jm4gfogeZuYLZHXM07tUYQ5rXaC)3lqfAdiIg(Efd6rgCJchdIzk5YbeeqyBAFRMhfdW9FVavOnGiA47vmOhzWnkCmiMPK7BiaNdJnwnpkgG7)EbQqBar0W3RyqpYGBu4yqmtjxTpasiQlDuNZQ5rXaC)3lqfAdiIg(Efd6rgCJchdIzk5(rqAeW2QwTbk(QdoQZbeuIdJBRMhfMma3)9cuH2aIOHVNflmLTOoOLaKbsB))0QabOvohyyDWyNbNFhOcTberdeWwNgrBwZPflI6GwcqgiT9)tRceGw5CGHfthm2zW53bidK2()PvbceWwNgL31AXYbJDgC(DaYaPT)FAvGabS1Pr0EXDSEJpDjraBDAeTxBozKrgzLnKbsB))0QaMa57jFcumOhzWnkCmiMPK7hbPraBRA1gOOi6u1gqjIEpMKoyI6SAEuma3)9ce9EmjDWe1Lma3)9cgC(TflIs8bjiJnKeCYmqExCxXGEKb3OWXGyMsUFeKgbSTQvBGIIOtvBaLi69ys6GjQZQ5rHPSf1bTeGmqA7)NwfiaTY5aJflzlQdAjG(CcqEFFiaTY5adJSma3)9cuH2aIObcyRtJO92DSBwPzil9hppWe07r0vIIspClj8l5HZhifd6rgCJchdIzk5(rqAeW2QwTbkkIovTbuIO3JjPdMOoRMhfMe1bTeGmqA7)NwfiaTY5adlrDqlb0NtaY77dbOvohyyKLb4(VxGk0gqen89yXeKbsB))0QaMGVsiybSyrVhiJabeDc(Batc9Fp8rLb3bOvohyyzWsWxjeSabp7Vtgp3aeAVXyXGEKb3OWXGyMsUFeKgbSTcEp4iPwTbkNRooSqW9CsCofjwnpk2ksassrifHMoraBDAeL7yLTb4(VxGk0gqen89yLTb4(VxarFOg(ES4(VxWgSXKRs4xY9pJjziGAJcgC(nlObI)v5XoVJLblbY3t(eiqaBDAeTzTyqpYGBu4yqmtj3pcsJa2w1QnqX9jSbeuAA0yg8hL8NNy18OyaU)7fOcTberdFVIb9idUrHJbXmLC)iincyBvR2af3hje8hL8Xod0jp33w9bRMhfdW9FVavOnGiA47vmOhzWnkCmiMPK7hbPraBRG3dosQvBGIVtnJkyckzdg15gCB18OyaU)7fOcTberdFVIb9idUrHJbXmLC)iincyBf8EWrsTAdu8DQzubtqjo14dwnpkgG7)EbQqBar0W3RyGMQLgaE63j1(uNJtpSv7dtQ9Juohu7iGnIgwlniiOwCx7bJDgC(DOyqpYGBu4yqmtj3pcsJa2OIHIbAQwAGHahPwJAR(qTk34gzauXanvBwSPcn2UwvQnRmxlt5K5AZFe61sdWZyTx)1muBwGTnygva3v1I7AVG5AfL4dcYQAZFe61MdH2aIOwvlMuB(JqV2mVml)AXcDGK)GGAZxhP2hMulcBd1cnq8Vkuln2HW1MVosTZR2Sygi)ApyBoCTdQ2d2EA)A)EHIb9idUrbZqGJqbAQqJTTAEuy6GT5Wjp80cIwkzLzrDqlbdaEajHeIkQpyhGw5CGXILd2MdN8WtlikAp26HUs8bt64XilMma3)9cuH2aIOHVNflgG7)Ebe9HA47zXc0aX)QGbEZzK8OCrozMQsgLZbbObI)vjc4dD6GT5MgmwSKnvLmkNdcOP9DqsuIpimYIPSf1bTeGmqA7)NwfiaTY5aJflhm2zW53bidK2()PvbceWwNgr7fmwmOhzWnkygcCeMPKlvLmkNdSQvBGYhbP34CaXkQQ7duoyBoCYdpTGcg4nNrO9Mflqde)Rcg4nNrYJYf5KzQkzuoheGgi(xLiGp0Pd2MBAWyXs2uvYOCoiGM23bjrj(GumOhzWnkygcCeMPKlcievatId3qc5nSbwDU64GKOeFqquUz18OKTblbeqiQaMehUHeYBydcYCyBAFlwOQKr5Cq4JG0BCoGWIj9idvibnypaIYnweDmjGk0sqnguyAAFFNlrGdDL4djzSblwo0vIpGO9cwIs8bjiJnKeCYmqE5KXIbAQw2HJqV2S4HoEA)AV0PgazvTzH1Uw8Rw2b9qfq1QsTxWCTIs8bbzvTysTSNDZkZ1kkXheuT5th6AZHqBar0AhuTFVIb9idUrbZqGJWmLCFANWVeB9qfqwnpkuvYOCoi8rq6nohqyP3dKrGaCOJN2pX5udGcqRCoWWc5boxsuIpiOWt7e(LyRhQaIwkxWmtgG7)EbQqBar0W3JMz6gZmP3dKrGaCOJN2pX5udGceTzJYngzKXIbAQ2SWAxl(vl7GEOcOAvP2B5aMRfj6HnuT4xT0Gogd01EPtnaQwmPw1xNgj1MvMRLPCYCT5pc9APbWFohulnagbmwROeFqqHIb9idUrbZqGJWmLCFANWVeB9qfqwnpkuvYOCoi8rq6nohqyXe3)9c0hJb6eNtnakGe9WgTuULdSyHPS9idMmYvjcwuzWnlKh4Cjrj(GGcpTt4xITEOciAPKvMzsVhiJabd(Z5GKbJGarB2O9cgzgjG6e6GjqW(FGrglgOPAZcRDT4xTSd6HkGQvW1QEEURQLgauJ7QAVM4bH7ANxTtRhzOc1I7A1(QAfL4dsTQul7RvuIpiOqXGEKb3OGziWryMsUpTt4xITEOciRoxDCqsuIpiik3SAEuOQKr5Cq4JG0BCoGWc5boxsuIpiOWt7e(LyRhQaIwkSVyqpYGBuWme4imtjx4qhpTFIaEKXwBJvZJcvLmkNdcFeKEJZbKIb9idUrbZqGJWmLCvBUpIUvZJcvLmkNdcFeKEJZbKIbAQ2mvo2nl7lJtfOwbxR655UQwAaqnURQ9AIheURvLAVOwrj(GGkg0Jm4gfmdbocZuY1(lJtfWQZvhhKeL4dcIYnRMhfQkzuohe(ii9gNdiSqEGZLeL4dck80oHFj26HkGOCrXGEKb3OGziWryMsU2FzCQawnpkuvYOCoi8rq6nohqkgkgOPAPbuB1hQftfi1kJnuRYnUrgavmqt1EDg7rQ96QecwauT4U2g3SRhzSjk5QAfL4dcQ2hMuRqhQ1JmyYixvlblQm4U25vBozUwohaguTkbQvDeqnxv73RyqpYGBuWGfkuvYOCoWQwTbki2gV05QJds(kHGfWkQQ7du8idMmYvjcwuzWnlKh4Cjrj(GGcpTt4xITEOciAzplMmyj4RecwGabS1Pr5DWyNbNFh8vcblqW8jQm42Ifp8GWnysCoamiAZjJfd0uTxNXEKAPrFp5tauT4U2g3SRhzSjk5QAfL4dcQ2hMuRqhQ1JmyYixvlblQm4U25vBozUwohaguTkbQvDeqnxv73RyqpYGBuWGfMPKlvLmkNdSQvBGcITXlDU64Ge57jFcyfv19bkEKbtg5QeblQm4MfYdCUKOeFqqHN2j8lXwpubeTSNftgG7)Ebe9HA47zXctE4bHBWK4Cayq0MtwzR3dKrGa6aTKWVeNdJnbOvohyyKXIbAQ2RZypsT0OVN8jaQ25vBoeAdiIYmp9HAUzzksasT0yesrOPRDq1(9QvBtT5d1sxPc1EbZ1IGdUnOADWtQf31k0HAPrFp5tGAPbWzwmOhzWnkyWcZuYLQsgLZbw1QnqbX24LiFp5taROQUpqXaC)3lqfAdiIg(ESyYaC)3lGOpudFplwSvKaKKIqkcnDIa260iAVJrwgSeiFp5tGabS1Pr0ErXanvlVhCg1v71vjeSa1QTPwA03t(eOweiFVA9idMuRGRnlMbsB))0Qa1EuKumOhzWnkyWcZuY1xjeSawnpkI6GwcqgiT9)tRceGw5CGHv2qgiT9)tRcyc(kHGfGLblbFLqWce8S)oz8CdqYJYnwhm2zW53bidK2()PvbceWwNgL3fSqEGZLeL4dck80oHFj26HkGOCJfrhtcOcTeuJbfMM2RLLblbFLqWceiGTonIMVlKZ8eL4dsqgBij4KzGIb9idUrbdwyMsUKVN8jGvZJIOoOLaKbsB))0QabOvohyyX0bBZHtE4PfeTuoEjBnJeYdAdRdg7m487aKbsB))0QabcyRtJY7gldwcKVN8jqGa260iA(UqoZtuIpibzSHKGtMbySyGMQ96QecwGA)ESbGNv1QoeUwHmaQwbx7hb1osTkQwTwKhCg1vRp0arfmP2hMuRqhQ1PiP2R)Awlh8WeOwT230dIoqkg0Jm4gfmyHzk56HXUebq4p5aw9WKudziuUvmOhzWnkyWcZuY1xjeSawnpke4raeDLZbSoyBoCYdpTGcg4nNrOLYnMzpnZKEpqgbci6e83aMe6)E4JkdUdqRCoWW6GXodo)oqv7brp89yKftE2FNmEUbi5r5MfleWwNgLhfzoSLKXgyH8aNljkXheu4PDc)sS1dvarlf2ZSEpqgbci6e83aMe6)E4JkdUdqRCoWWilMYgYaPT)FAvaJfleWwNgLhfzoSLKXgO5lyH8aNljkXheu4PDc)sS1dvarlf2ZSEpqgbci6e83aMe6)E4JkdUdqRCoWWiRSrOe3)9adlMeL4dsqgBij4Kza2La260igPnRSyYwrcqskcPi00jcyRtJOCNflzlZHTP9zP3dKrGaIob)nGjH(Vh(OYG7a0kNdmmwmOhzWnkyWcZuY1dJDjcGWFYbS6HjPgYqOCRyqpYGBuWGfMPKRVsiybS6C1Xbjrj(GGOCZQ5rjBQkzuoheqSnEPZvhhK8vcblalc8iaIUY5awhSnho5HNwqbd8MZi0s5gZSNMzsVhiJabeDc(Batc9Fp8rLb3bOvohyyDWyNbNFhOQ9GOh(EmYIjp7Vtgp3aK8OCZIfcyRtJYJImh2sYydSqEGZLeL4dck80oHFj26HkGOLc7zwVhiJabeDc(Batc9Fp8rLb3bOvohyyKftzdzG02)pTkGXIfcyRtJYJImh2sYyd08fSqEGZLeL4dck80oHFj26HkGOLc7zwVhiJabeDc(Batc9Fp8rLb3bOvohyyKv2iuI7)EGHftIs8bjiJnKeCYma7saBDAeJ0E7cwmzRibijfHueA6ebS1PruUZILSL5W20(S07bYiqarNG)gWKq)3dFuzWDaALZbgglgOPAVEYyJWDTzc2EasQf31A)DY45GAfL4dcQwvQnRmx71FnRnF6qxl5390(1I)sTtx7fOAz67vRGRnR1kkXheeJ1Ij1YEuTmLtMRvuIpiiglg0Jm4gfmyHzk5EiJnc3jbS9aKy18OG8aNljkXheeTuUGfbS1Pr5DbZmH8aNljkXheeTuYjJSoyBoCYdpTGOLswlgOPAzhaGxTFVAPrFp5tGAvP2SYCT4Uw15QvuIpiOAzkF6qxRBOoTFToC7xl04Vp9A12uBJLArT6HOJfglg0Jm4gfmyHzk5s(EYNawnpkztvjJY5GaITXlr(EYNaSy6GT5Wjp80cIwkzLfbEearx5CGflzlZHTP9zXKm2aT3UZILd2MdN8WtliAPCbJmYIjp7Vtgp3aK8OCZIfcyRtJYJImh2sYydSqEGZLeL4dck80oHFj26HkGOLc7zwVhiJabeDc(Batc9Fp8rLb3bOvohyyKftzdzG02)pTkGXIfcyRtJYJImh2sYyd08fSqEGZLeL4dck80oHFj26HkGOLc7zwVhiJabeDc(Batc9Fp8rLb3bOvohyyKLOeFqcYydjbNmdWUeWwNgrBwlg0Jm4gfmyHzk5s(EYNawDU64GKOeFqquUz18OKnvLmkNdci2gV05QJdsKVN8jaRSPQKr5CqaX24LiFp5tawhSnho5HNwq0sjRSiWJai6kNdyXKN93jJNBasEuUzXcbS1Pr5rrMdBjzSbwipW5sIs8bbfEANWVeB9qfq0sH9mR3dKrGaIob)nGjH(Vh(OYG7a0kNdmmYIPSHmqA7)NwfWyXcbS1Pr5rrMdBjzSbA(cwipW5sIs8bbfEANWVeB9qfq0sH9mR3dKrGaIob)nGjH(Vh(OYG7a0kNdmmYsuIpibzSHKGtMbyxcyRtJOnRfd0uTxpzSr4U2mbBpaj1I7A5ZS25v7016PTbSNtTABQDKAZFCUAn4ADacvRrTvFOwHU21MfBQqJTR18HAfCTzEzUzz04CZuyhumOhzWnkyWcZuY9qgBeUtcy7biXQ5rb5boxsuIpiik3yDW2C4KhEAbrlfMoEjBnJeYdAd7EJrwe4raeDLZbSYgYaPT)FAvadRSna3)9ci6d1W3JLTIeGKuesrOPteWwNgr5owzR3dKrGGK)GKKqhsS1ZdcqRCoWWsuIpibzSHKGtMbyxcyRtJOnRfd6rgCJcgSWmLCrGhAqfdfd0uTzrec6dGkg0Jm4gfaec6dGOCW9bAHOcyspNAdwnpkqde)RcYydjbNS1mO9gRSna3)9cuH2aIOHVhlMY2GLWb3hOfIkGj9CQnK4(KoiZHTP9zLTEKb3HdUpqlevat65uBimD65gF6IflVVZLiWHUs8HKm2qE(htWwZGXIbAQwASlF9kuTFeu7Lom2uB(JqV2Ci0gqeT2VxOwAqXotTpmP2SygiT9)tRceQLgeeuB(JqV2mVS2VxTCWdtGA1AFtpi6aPwfvRd3(1QOAhPwYVr1(WKAVDhQwZNmTFT5qOnGiAOyqpYGBuaqiOpaIzk5Y5Wytc)scDibnyFLvZJIb4(VxGk0gqen89yXeKbsB))0QaMGVsiybSyXaC)3lGOpudFpwhSnho5HNwqbd8MZi5r5MflgG7)EbQqBar0abS1Pr5r52DmAXYB8PljcyRtJYJYT7kgOPAPXIa2EsTcUw1n(DTx3VsmJ21M)i0RnhcTberRvr16WTFTkQ2rQnFCNJsTea9DsTtxRdJM2VwT2335yxQQ7d1EuKulMkqQvOd1saBD6P9R18jQm4Uw8RwHou7B8Plfd6rgCJcacb9bqmtjx)VsmJ2j8lP3deSq3Q5r5GXodo)oqfAdiIgiGTonkp2BXIb4(VxGk0gqen89Sy5n(0LebS1Pr5X(7kg0Jm4gfaec6dGyMsU(FLygTt4xsVhiyHUvZJYZHXeMy6n(0LebS1PrSl7VJrAWhm2zW53ms7ZHXeMy6n(0LebS1PrSl7VJDpySZGZVduH2aIObcyRtJyKg8bJDgC(nJfd6rgCJcacb9bqmtj3h(8rGjP3dKrGehO2wnpkipW5sIs8bbfEANWVeB9qfq0s5clwi6ysavOLGAmOW00ET3XcAG4FvExJ7kg0Jm4gfaec6dGyMsUEFY8UAA)eNtrIvZJcYdCUKOeFqqHN2j8lXwpubeTuUWIfIoMeqfAjOgdkmnTx7Dfd6rgCJcacb9bqmtjxHoK(nh(3M0dtoGvZJc3)9ce4WMdqO0dtoq47zXc3)9ce4WMdqO0dtoq6G)TaKas0dB5D7UIb9idUrbaHG(aiMPKlz88CqA6eYtpqXGEKb3OaGqqFaeZuYnFmXzOctNiac3AFGIb9idUrbaHG(aiMPKRnyJjxLWVK7FgtYqa1gz18Oanq8VkVCEhRSpySZGZVduH2aIOHVxXanvlnOyNPwAeOEt7xBwyNAdOAFysTqgW5lqTeT9HAXKAzBCUA5(VhYQANxTEyeA4CqOwASlF9kuTc5QAfCT(GuRqhQ1HZhqsThm2zW531YPiWulURvPQJt5CqTqd2dGcfd6rgCJcacb9bqmtjxcOEt7NEo1gqwDU64GKOeFqquUz18OikXhKGm2qsWjZa5DlKtlwyIjrj(GeOdQtOh8ocTSZ7SyruIpib6G6e6bVJKhLlUJrwmPhzOcjOb7bquUzXIOeFqcYydjbNmdq7f5agz0IfMeL4dsqgBij4K3rsxChTS)owmPhzOcjOb7bquUzXIOeFqcYydjbNmdqBwZkJmwmumqt1YlG6e6GPwA8rgCJkgOPATE8PJe1XgqQf31EltAyT8T6HOJLAPrFp5tGIb9idUrbKaQtOdgkKVN8jGvZJIOoOLqp(0fKOo2asaALZbgwhSnho5HNwq0sjRSeL4dsqgBij4Kza2La260iAV2IbAQw(pNaK33hQL5A5PtWFdyQL))E4JkdUPH1MfB0Na1Mpu7hb1IBOwFhMtD1k4Avpp3v1EDvcblqTcUwHouRToDTIs8bP25v7i1oOABSulQvpeDSu7vGyvTiCTQZvlwOdKAT1PRvuIpi1QCJBKbq16rWVrcfd6rgCJcibuNqhmmtjxpm2Liac)jhWQhMKAidHYTIb9idUrbKaQtOdgMPKRVsiybSAEu07bYiqarNG)gWKq)3dFuzWDaALZbgwC)3lG(CcqEFFi89yX9FVa6Zja599HabS1Pr5DlWEwzJqjU)7bMIbAQw(pNaK33hOH1sJ98CxvlMulncEearV28hHETC)3dm1EDvcblaQyqpYGBuajG6e6GHzk56HXUebq4p5aw9WKudziuUvmOhzWnkGeqDcDWWmLC9vcblGvNRooijkXheeLBwnpkI6GwcOpNaK33hcqRCoWWIjcyRtJY72fwS4z)DY45gGKhLBmYsuIpibzSHKGtMbyxcyRtJO9IIbAQw(pNaK33hQL5A5PtWFdyQL))E4JkdURD6A5ZKgwln2ZZDvTGsCxvln67jFcuRqxLAZFCUA5GAjWJai6GP2hMuRN2gWEofd6rgCJcibuNqhmmtjxY3t(eWQ5rruh0sa95eG8((qaALZbgw69azeiGOtWFdysO)7HpQm4oaTY5adRSnyjq(EYNabzoSnTplQkzuoheqt77GKOeFqkgOPA5)CcqEFFO28ZTwE6e83aMA5)Vh(OYGBAyT0iq98Cxv7dtQLd3FuTx)1SwTn5Ij1cziqBatTOw9q0XsTMprLb3HIb9idUrbKaQtOdgMPKRhg7seaH)Kdy1dtsnKHq5wXGEKb3Oasa1j0bdZuY1xjeSawDU64GKOeFqquUz18OiQdAjG(CcqEFFiaTY5adl9EGmceq0j4Vbmj0)9WhvgChGw5CGHft6rgQqcAWEaeT3SyjBrDqlbidK2()PvbcqRCoWWilrj(GeKXgscozgGwcyRtJyXebS1Pr5DJDAXs2iuI7)EGHXIbAQw(pNaK33hQL5AZIzG8Rf31EltAyT0i4rae9AVUkHGfOwvQvOd1cTPw8RwKaQtOxRGR1hKAT1mQ18jQm4Uwo4HjqTzXmqA7)NwfOyqpYGBuajG6e6GHzk56HXUebq4p5aw9WKudziuUvmOhzWnkGeqDcDWWmLC9vcblGvZJIOoOLa6Zja599Ha0kNdmSe1bTeGmqA7)NwfiaTY5adl9idvibnypaIYnwC)3lG(CcqEFFiqaBDAuE3cSpkrjgb]] )

end