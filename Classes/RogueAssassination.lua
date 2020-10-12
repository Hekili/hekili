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


    spec:RegisterPack( "Assassination", 20201011, [[diL9fcqirPEesbxsLurBcf9jvsXOqPCkusRcPiVcfmlkj3cLkTlb)suvdtLkhtLYYuj6zOu10eL01evyBQKsFtur14qPcNtuISoKIQ3jkrvnprvUhsSpKs)tuIkhePqTqvcpePOmrvsvUOOeSrrjeFuLuPrQsQqNuuIYkrjEjkveZeLkQBkkHANus9trjQYqfvKwksH8uu1uffUQkPc2QOIYxrPI0yvjv1Ef6VImyLomXIrLhRIjtXLbBwv(mv1OrQoTIvlkH0RrHMnvUnLA3s9BOgov54IkILJ45qMoPRRQ2os67IknErrNxLK1RsvZNsSFjhVfZiYBefIwF5DxE3T7UDlC5DxMLYroI86vEqK3tomk(qKVfBiYtJribHMw0b3rEp5khwmXmI8i8NCGipDv9q088Z3Fu6FUWbBNpAS)orhCFiYtZhn2N8J8C)XPzzDKlYBefIwF5DxE3T7UDlYlFLoMe55hBAwKN(ymqh5I8gaDI80qT0yesqOPfDWDT0iS)hkwOHAZY7OyoGu7TBwv7L3D5DrE3GuumJipsbXP0btmJO13Ize5Hw4CGjErK)qgfiJe5vXbTg6XNUIuXXiqcqlCoWulZApyBoCYdpTIQLwk1M1AzwRkeFqd6ydjfNmdul7wlbSLPr1sBTxBKxo6G7ip57PFce1O1xgZiYdTW5at8Ii)dtsnKPgT(wKxo6G7iVhg7seaH)Kde1O1SpMrKhAHZbM4fr(dzuGmsKxUhiJcbeDc(Batc9Fp8r0b3bOfohyQLzTC)3lG(CkqEFFi89QLzTC)3lG(CkqEFFiqaBzAuT5v7Ta7RLzTzxlcL4(VhyI8YrhCh59fcbRquJwN1ygrEOfohyIxe5FysQHm1O13I8YrhCh59WyxIai8NCGOgTohXmI8qlCoWeViYlhDWDK3xieScr(dzuGmsKxfh0Aa95uG8((qaAHZbMAzwlB1saBzAuT5v7TlR1ILA9S)oD8CdqQnpk1ERwwRLzTQq8bnOJnKuCYmqTSBTeWwMgvlT1EzK)C1Xbjvi(GIIwFlQrRV2ygrEOfohyIxe5pKrbYirEvCqRb0NtbY77dbOfohyQLzTY9azuiGOtWFdysO)7HpIo4oaTW5atTmRn7Anynq(E6NabDomoTFTmRLQqgHZbb00(oiPcXh0iVC0b3rEY3t)eiQrRZ5XmI8qlCoWeViY)WKudzQrRVf5LJo4oY7HXUebq4p5arnAn7iMrKhAHZbM4frE5OdUJ8(cHGviYFiJcKrI8Q4GwdOpNcK33hcqlCoWulZAL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzwlB1khDOcjOb7bq1sBT3Q1ILAZUwvCqRbitK0()PffcqlCoWulR1YSwvi(Gg0XgskozgOwARLa2Y0OAzwlB1saBzAuT5v7n2rTwSuB21IqjU)7bMAznYFU64GKkeFqrrRVf1O1zPygrEOfohyIxe5FysQHm1O13I8YrhCh59WyxIai8NCGOgT(2DXmI8qlCoWeViYFiJcKrI8Q4GwdOpNcK33hcqlCoWulZAvXbTgGmrs7)NwuiaTW5atTmRvo6qfsqd2dGQLsT3QLzTC)3lG(CkqEFFiqaBzAuT5v7Ta7J8YrhCh59fcbRquJAKhqiOpakMr06BXmI8qlCoWeViYFiJcKrI8qde)Rc6ydjfNSLmRL2AVvlZAZUwdW9FVavOnGQs47vlZAzR2SR1G1Wb3hOvIOGj9CInK4(KoOZHXP9RLzTzxRC0b3HdUpqRerbt65eBimD65gF6ATwSu777CjcCOleFiPJnuBE16FmbBjZAznYlhDWDK)G7d0kruWKEoXgIA06lJze5Hw4CGjErK)qgfiJe5na3)9cuH2aQkHVxTmRLTAna3)9c(cHGviazIK2)pTOGPwlwQ1aC)3lGOpudFVAzw7bBZHtE4PvuWaV5mAT5rP2B1AXsTgG7)EbQqBavLabSLPr1MhLAVDxTSwRfl1(gF6AIa2Y0OAZJsT3UlYlhDWDKNZHXMe(Lu6qcAW(QOgTM9XmI8qlCoWeViYFiJcKrI8hm2zW52bQqBavLabSLPr1MxTSVwlwQ1aC)3lqfAdOQe(E1AXsTVXNUMiGTmnQ28QL93f5LJo4oY7)fIzKoHFj5EGGv6rnADwJze5Hw4CGjErK)qgfiJe5FomMulB1YwTVXNUMiGTmnQw2Tw2FxTSw71zTYrhCNoySZGZTRL1APT2NdJj1YwTSv7B8PRjcyltJQLDRL93vl7w7bJDgCUDGk0gqvjqaBzAuTSw71zTYrhCNoySZGZTRL1iVC0b3rE)VqmJ0j8lj3deSspQrRZrmJip0cNdmXlI8hYOazKipYdCUKkeFqrHN0j8lXypubuT0sP2lR1ILAjYysavO1GymOW01sBTx7D1YSwObI)v1MxT587I8YrhCh5F4ZhbMKCpqgfsCGyh1O1xBmJip0cNdmXlI8hYOazKipYdCUKkeFqrHN0j8lXypubuT0sP2lR1ILAjYysavO1GymOW01sBTx7DrE5OdUJ8EFY8UAA)eNtqAuJwNZJze5Hw4CGjErK)qgfiJe55(VxGahgDacLEyYbcFVATyPwU)7fiWHrhGqPhMCG0b)BfibKkhgRnVAVDxKxo6G7iVshs)Md)Bt6HjhiQrRzhXmI8YrhCh5jJNNdstNqEYbI8qlCoWeViQrRZsXmI8YrhCh5ZftCgQW0jcGWT0hiYdTW5at8IOgT(2DXmI8qlCoWeViYFiJcKrI8qde)RQnVAZXD1YS2SR9GXodo3oqfAdOQe(ErE5OdUJ82GnMCvc)sU)zmjdbeBuuJwF7wmJip0cNdmXlI8YrhCh5jG4nTF65eBaf5pKrbYirEvi(Gg0XgskozgO28Q9wih1AXsTSvlB1QcXh0aDqCk9G3rRL2Azh3vRfl1QcXh0aDqCk9G3rRnpk1E5D1YATmRLTALJouHe0G9aOAPu7TATyPwvi(Gg0XgskozgOwAR9YSuTSwlR1AXsTSvRkeFqd6ydjfN8oA6Y7QL2Az)D1YSw2Qvo6qfsqd2dGQLsT3Q1ILAvH4dAqhBiP4KzGAPT2SM1AzTwwJ8NRooiPcXhuu06BrnQrEd8KVtJzeT(wmJiVC0b3rEgNdJrEOfohyIxe1O1xgZiYlhDWDKhPG4u6rEOfohyIxe1O1SpMrKhAHZbM4frESxKhbAKxo6G7ipvHmcNdI8uf3hI8qde)RceWh6AzOwp8GWnysCoamOAPPAZ51EDwlB1EzT0uTipW5s0fKc1YAKNQqsTydrEObI)vjc4dD6GT5MgmrnADwJze5Hw4CGjErKh7f5rGg5LJo4oYtviJW5GipvX9HipYdCUKkeFqrHN0j8lXypubuT5v7LrEQcj1Ine5rt77GKkeFqJA06CeZiYdTW5at8Ii)HmkqgjYJuqCkDWeiy)pe5LJo4oYFeNljhDWDYninY7gKMAXgI8ifeNshmrnA91gZiYdTW5at8Ii)HmkqgjYZwTzxRkoO1GTGuGKeesqOPdqlCoWuRfl1AWAWxieScbDomoTFTSg5LJo4oYFeNljhDWDYninY7gKMAXgI8hdkQrRZ5XmI8qlCoWeViYlhDWDK)ioxso6G7KBqAK3nin1Ine5nynQrRzhXmI8qlCoWeViYFiJcKrI8C)3lGCZbssBsM5abcyltJQnVAvH4dAqhBiP4KzGAzwl3)9ci3CGK0MKzoqGa2Y0OAZRw2Q9wTmu7bBZHtE4PvuTSwlnv7Ta7iYlhDWDKh5MdKK2KmZbIA06SumJip0cNdmXlI8YrhCh5pIZLKJo4o5gKg5DdstTydrEZqGJg1O13UlMrKhAHZbM4fr(dzuGmsKhAG4FvWaV5mAT0sP2B5OwgQLQqgHZbbObI)vjc4dD6GT5MgmrE5OdUJ8c5inKumHaTg1O13UfZiYlhDWDKxihPHK33HGip0cNdmXlIA06BxgZiYlhDWDK3n(0vukl634BdTg5Hw4CGjEruJwFJ9XmI8YrhCh55e)e(LuYCyef5Hw4CGjEruJAK3JahSnNOXmIwFlMrKxo6G7iV455Uk5HheUJ8qlCoWeViQrRVmMrKxo6G7iVhwhCh5Hw4CGjEruJwZ(ygrEOfohyIxe5LJo4oYBlegbt6Hjjdik9i)HmkqgjYtKXKaQqRbXyqHPRL2AVLJiVhboyBorti4GBdkYNJOgToRXmI8YrhCh5rkioLEKhAHZbM4frnADoIze5Hw4CGjErKxo6G7ipYnhijTjzMde59iWbBZjAcbhCBqr(BrnA91gZiYdTW5at8IiFl2qKxUhrxick9WTMWVKhoxGe5LJo4oYl3JOlebLE4wt4xYdNlqIA06CEmJip0cNdmXlI8hYOazKiVkoO1aKjsA))0IcbOfohyI8YrhCh59)cXmsNWVKCpqWk9Og1iVziWrJzeT(wmJip0cNdmXlI8hYOazKipB1EW2C4KhEAfvlTuQnR1YqTQ4Gwdga8ascPerfFWoaTW5atTwSu7bBZHtE4PvuTuQv6Xwo0fIpyshVAzTwM1YwTgG7)EbQqBavLW3RwlwQ1aC)3lGOpudFVATyPwObI)vbd8MZO1MhLAVmh1YqTufYiCoianq8VkraFOthSn30GPwlwQn7APkKr4CqanTVdsQq8bTwwRLzTSvB21QIdAnazIK2)pTOqaAHZbMATyP2dg7m4C7aKjsA))0IcbcyltJQL2AVSwwJ8YrhCh5HMk0y7OgT(YygrEOfohyIxe5XErEeOrE5OdUJ8ufYiCoiYtvCFiYFW2C4KhEAffmWBoJwlT1ERwlwQfAG4FvWaV5mAT5rP2lZrTmulvHmcNdcqde)RseWh60bBZnnyQ1ILAZUwQczeoheqt77GKkeFqJ8ufsQfBiY)rq6nohqIA0A2hZiYdTW5at8IiVC0b3rEeqiIcMehUHeYByeI8hYOazKiF21AWAabeIOGjXHBiH8ggHGohgN2VwlwQLQqgHZbHpcsVX5asTmRLTALJouHe0G9aOAPu7TAzwlrgtcOcTgeJbfMUwAR99DUebo0fIpK0XgQ1ILAp0fIpGQL2AVSwM1QcXh0Go2qsXjZa1MxT5OwwJ8NRooiPcXhuu06BrnADwJze5Hw4CGjErK)qgfiJe5PkKr4Cq4JG0BCoGulZAL7bYOqao0Xt7N4CIbqbOfohyQLzTipW5sQq8bffEsNWVeJ9qfq1slLAVSwgQLTAna3)9cuH2aQkHVxT0uTSv7TAzOw2QvUhiJcb4qhpTFIZjgafisZyTuQ9wTSwlR1YAKxo6G7i)t6e(LyShQakQrRZrmJip0cNdmXlI8hYOazKipvHmcNdcFeKEJZbKAzwlB1Y9FVa9XyGoX5edGcivomwlTuQ9wwQwlwQLTAZUwpYGjJEvIGvrhCxlZArEGZLuH4dkk8KoHFjg7HkGQLwk1M1AzOw2QvUhiJcbd(Z5GKbJGarAgRL2AVSwwRLHArkioLoyceS)hQL1AznYlhDWDK)jDc)sm2dvaf1O1xBmJip0cNdmXlI8YrhCh5FsNWVeJ9qfqr(dzuGmsKNQqgHZbHpcsVX5asTmRf5boxsfIpOOWt6e(LyShQaQwAPul7J8NRooiPcXhuu06BrnADopMrKhAHZbM4fr(dzuGmsKNQqgHZbHpcsVX5asKxo6G7ipCOJN2prapYylTjQrRzhXmI8qlCoWeViYFiJcKrI8ufYiCoi8rq6nohqI8YrhCh5fBUpIEuJwNLIze5Hw4CGjErKxo6G7iV9xhNOqK)qgfiJe5PkKr4Cq4JG0BCoGulZArEGZLuH4dkk8KoHFjg7HkGQLsTxg5pxDCqsfIpOOO13IA06B3fZiYdTW5at8Ii)HmkqgjYtviJW5GWhbP34CajYlhDWDK3(RJtuiQrnYFmOygrRVfZiYdTW5at8Ii)HmkqgjYNDTifeNshmbX5QLzT2csbssqibHMoraBzAuTuQ9UAzwlB1EWyNbNBhOcTbuvceWwMgvBEz5QLTApySZGZTdi6d1abSLPr1st1c5K)45bMGGOtvAaLiY9ys6GjIRwwRL1AZR2B3vld1E7UAPPAHCYF88atqq0PknGse5EmjDWeXvlZAZUwdW9FVavOnGQs47vlZAZUwdW9FVaI(qn89I8TydrE5EeDHiO0d3Ac)sE4CbsKxo6G7iVCpIUqeu6HBnHFjpCUajQrRVmMrKhAHZbM4fr(dzuGmsKp7ArkioLoycIZvlZAnynq(E6NabDomoTFTmR1wqkqsccji00jcyltJQLsT3f5LJo4oYFeNljhDWDYninY7gKMAXgI8acb9bqrnAn7Jze5Hw4CGjErKxo6G7iVTqyemPhMKmGO0J8hYOazKiprgtcOcTgeJbf(E1YSw2QvfIpObDSHKItMbQnVApyBoCYdpTIcg4nNrRLMQ9wih1AXsThSnho5HNwrbd8MZO1slLApEjBjZeYdAtTSg5pxDCqsfIpOOO13IA06SgZiYdTW5at8Ii)HmkqgjYtKXKaQqRbXyqHPRL2Az)D1YU1sKXKaQqRbXyqbZNi6G7Azw7bBZHtE4PvuWaV5mAT0sP2JxYwYmH8G2e5LJo4oYBlegbt6Hjjdik9OgTohXmI8YrhCh5FoXhCorhCh5Hw4CGjEruJwFTXmI8qlCoWeViYFiJcKrI8gG7)EHNt8bNt0b3bcyltJQnVAVSwlwQ1aC)3l8CIp4CIo4oGu5WyT0sP2SExKxo6G7i)Zj(GZj6G70XbsJGOgToNhZiYdTW5at8Iip2lYJanYlhDWDKNQqgHZbrEQI7dr(SRvfh0Aa95uG8((qaAHZbMATyP2SRvUhiJcbeDc(Batc9Fp8r0b3bOfohyQ1ILAnyn4lecwHGN93PJNBasT0w7TAzwlB1I8aNlPcXhuu4jDc)sm2dvavBE1ET1AXsTzx7bJDgCUDGQ0dIE47vlRrEQcj1Ine5PcTbuvsOpNcK33hshCBgDWDuJwZoIze5Hw4CGjErKh7f5rGg5LJo4oYtviJW5GipvX9HiF21QIdAn0JpDfPIJrGeGw4CGPwlwQn7AvXbTgGmrs7)NwuiaTW5atTwSu7bJDgCUDaYejT)FArHabSLPr1MxT5Ow2T2lRLMQvfh0AWaGhqsiLiQ4d2bOfohyI8ufsQfBiYtfAdOQK6XNUIuXXiqshCBgDWDuJwNLIze5Hw4CGjErKh7f5rGg5LJo4oYtviJW5GipvX9HiF21c5K)45bMGCpIUqeu6HBnHFjpCUaPwlwQvUhiJcbeDc(Batc9Fp8r0b3bOfohyQ1ILAna3)9ce5EmjDWeXLma3)9cgCUDTwSu7bJDgCUDqq0PknGse5EmjDWeXfiGTmnQ28Q92D1YSw2Q9GXodo3oGOpudeWwMgvBE1ERwlwQ1aC)3lGOpudFVAznYtviPwSHipvOnGQs6HBnDWTz0b3rnA9T7Ize5Hw4CGjErK)qgfiJe5ZUwKcItPdMab7)HAzwRbRbY3t)eiOZHXP9RLzTzxRb4(VxGk0gqvj89QLzTufYiCoiqfAdOQKqFofiVVpKo42m6G7AzwlvHmcNdcuH2aQkPE8PRivCmcK0b3MrhCxlZAPkKr4CqGk0gqvj9WTMo42m6G7iVC0b3rEQqBavLOgT(2TygrEOfohyIxe5pKrbYirEvCqRbitK0()PffcqlCoWulZAvXbTg6XNUIuXXiqcqlCoWulZApyBoCYdpTIQLwk1E8s2sMjKh0MAzw7bJDgCUDaYejT)FArHabSLPr1MxT3I8YrhCh5Pk9GOh1O13UmMrKhAHZbM4fr(dzuGmsKxfh0AOhF6ksfhJajaTW5atTmRn7AvXbTgGmrs7)NwuiaTW5atTmR9GT5Wjp80kQwAPu7XlzlzMqEqBQLzTSvRb4(VxGk0gqvj89Q1ILAbec6deOoOb3j8l5bKhC0b3bOfohyQL1iVC0b3rEQspi6rnA9n2hZiYdTW5at8Iip2lYJanYlhDWDKNQqgHZbrEQI7drE5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwM1YwTnUtiuI7)EGjPcXhuuT0sP2B1AXsTipW5sQq8bffEsNWVeJ9qfq1sPw2xlR1YSw2QfHsC)3dmjvi(GIschMkK8K2a2ZPwk1ExTwSulYdCUKkeFqrHN0j8lXypubuT0sP2RTwwJ8ufsQfBiYJqjQspi6PdUnJo4oQrRVL1ygrEOfohyIxe5HmvIKeB8V1iFwZrK)HjPgYuJwFlYlhDWDK3dJDjcGWFYbIA06B5iMrKhAHZbM4fr(dzuGmsKxfh0Aa95uG8((qaAHZbMAzwB21IuqCkDWeiy)pulZApySZGZTd(cHGvi89QLzTSvlvHmcNdciuIQ0dIE6GBZOdUR1ILAZUw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwM1YwTgSg8fcbRqGapcGOlCoOwlwQ1aC)3lqfAdOQe(E1YSwdwd(cHGvi4z)D645gGuBEuQ9wTSwlR1YS2d2MdN8WtROGbEZz0APLsTSvlB1ERwgQ9YAPPAL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzTwAQwKh4Cjvi(GIcpPt4xIXEOcOAzTwAZYvBwRLzTezmjGk0Aqmguy6APT2Bxg5LJo4oYtv6brpQrRVDTXmI8qlCoWeViYFiJcKrI8SvRkoO1GTGuGKeesqOPdqlCoWuRfl1s(n8WeFiylegt4xsPdjBbPajjiKGqthGCYF88atTSwlZAZUwKcItPdMG4C1YSwBbPajjiKGqtNiGTmnQ28Ou7D1YS2SR1G1a57PFceiWJai6cNdQLzTgSg8fcbRqGa2Y0OAPTw2xlZAzRwdW9FVavOnGQs47vlZAna3)9ci6d1W3RwM1YwTzxlGqqFGaNdJnj8lP0He0G9vbBjlkMuRfl1AaU)7f4CySjHFjLoKGgSVk89QL1ATyPwaHG(abQdAWDc)sEa5bhDWDaAHZbMAznYlhDWDKNQ0dIEuJwFlNhZiYdTW5at8Ii)HmkqgjYNDTifeNshmbX5QLzTY9azuiGOtWFdysO)7HpIo4oaTW5atTmR1G1GVqiyfce4raeDHZb1YSwdwd(cHGvi4z)D645gGuBEuQ9wTmR9GT5Wjp80kkyG3CgTwAPu7TiVC0b3rEeDXGZ1gCMOgT(g7iMrKhAHZbM4fr(dzuGmsKp7ArkioLoyceS)hQLzTSvB21AWAWxieScbc8iaIUW5GAzwRbRbY3t)eiqaBzAuT0wBwRLHAZAT0uThVKTKzc5bTPwlwQ1G1a57PFceiGTmnQwAQ27c5OwARvfIpObDSHKItMbQL1AzwRkeFqd6ydjfNmdulT1M1iVC0b3rEitK0()PffIA06BzPygrEOfohyIxe5pKrbYirEhqfC1slLAZb7OwM1AWAG890pbc6CyCA)AzwlB1MDTqo5pEEGji3JOlebLE4wt4xYdNlqQ1ILApySZGZTduH2aQkbcyltJQL2AVDxTSg5LJo4oYJOpuJA06lVlMrKhAHZbM4fr(dzuGmsKN7)EbohgBCFKgiGC0ATyPwdW9FVavOnGQs47f5LJo4oY7H1b3rnA9L3Ize5Hw4CGjErK)qgfiJe5na3)9cuH2aQkHVxKxo6G7ipNdJnP3NCvuJwF5LXmI8qlCoWeViYFiJcKrI8gG7)EbQqBavLW3lYlhDWDKNdiiGW40(rnA9LSpMrKhAHZbM4fr(dzuGmsK3aC)3lqfAdOQe(ErE5OdUJ8VHaCom2e1O1xM1ygrEOfohyIxe5pKrbYirEdW9FVavOnGQs47f5LJo4oYl9bqkrCPJ4CrnA9L5iMrKhAHZbM4fr(dzuGmsKNTAna3)9cuH2aQkHVxTwSulB1MDTQ4GwdqMiP9)tlkeGw4CGPwM1EWyNbNBhOcTbuvceWwMgvlT1M1CuRfl1QIdAnazIK2)pTOqaAHZbMAzwlB1EWyNbNBhGmrs7)NwuiqaBzAuT5v71wRfl1EWyNbNBhGmrs7)NwuiqaBzAuT0w7L3vlZAFJpDnraBzAuT0w71MJAzTwwRL1AzwB21AaU)7fiFp9tGaKjsA))0IcMiFl2qK3xCWrCoGGsCyCh5LJo4oY7lo4iohqqjomUJA06lV2ygrEOfohyIxe5pKrbYirEdW9FVarUhtshmrCjdW9FVGbNBxRfl1QcXh0Go2qsXjZa1MxTxExKVfBiYli6uLgqjICpMKoyI4I8YrhCh5feDQsdOerUhtshmrCrnA9L58ygrEOfohyIxe5pKrbYirE2Qn7AvXbTgGmrs7)NwuiaTW5atTwSuB21QIdAnG(CkqEFFiaTW5atTSwlZAna3)9cuH2aQkbcyltJQL2AVDxTSBTzTwAQwiN8hppWeK7r0fIGspCRj8l5HZfir(wSHiVGOtvAaLiY9ys6GjIlYlhDWDKxq0PknGse5EmjDWeXf1O1xYoIze5Hw4CGjErK)qgfiJe5zRwvCqRbitK0()PffcqlCoWulZAvXbTgqFofiVVpeGw4CGPwwRLzTgG7)EbQqBavLW3RwM1YwTgG7)EbFHqWkeGmrs7)NwuWuRfl1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YSwdwd(cHGvi4z)D645gGulT1ERwwJ8TydrEbrNQ0akrK7XK0btexKxo6G7iVGOtvAaLiY9ys6GjIlQrRVmlfZiYdTW5at8IiVC0b3r(Zvhhwj4EojoNG0i)HmkqgjYBlifijbHeeA6ebSLPr1sP27QLzTzxRb4(VxGk0gqvj89QLzTzxRb4(VxarFOg(E1YSwU)7fSbBm5Qe(LC)Zysgci2OGbNBxlZAHgi(xvBE1YoURwM1AWAG890pbceWwMgvlT1M1ip8EWrtTydr(Zvhhwj4EojoNG0OgTM93fZiYdTW5at8Ii)HmkqgjYBaU)7fOcTbuvcFViFl2qK39jmceuAA0yg8hL8NNg5LJo4oY7(egbcknnAmd(Js(ZtJA0A2FlMrKhAHZbM4fr(dzuGmsK3aC)3lqfAdOQe(Er(wSHiV7Juc(Js(yNb6KN7Bl(qKxo6G7iV7Juc(Js(yNb6KN7Bl(quJwZ(lJze5Hw4CGjErKxo6G7iVVtmJOyckzdgX5gCh5pKrbYirEdW9FVavOnGQs47f5H3doAQfBiY77eZikMGs2GrCUb3rnAn7zFmJip0cNdmXlI8YrhCh59DIzeftqjoX4dr(dzuGmsK3aC)3lqfAdOQe(ErE49GJMAXgI8(oXmIIjOeNy8HOgTM9znMrKxo6G7i)hbPrbBuKhAHZbM4frnQrEdwJzeT(wmJip0cNdmXlI8yVipc0iVC0b3rEQczeohe5PkUpe59idMm6vjcwfDWDTmRf5boxsfIpOOWt6e(LyShQaQwARL91YSw2Q1G1GVqiyfceWwMgvBE1EWyNbNBh8fcbRqW8jIo4UwlwQ1dpiCdMeNdadQwARnh1YAKNQqsTydrEeJJx6C1XbjFHqWke1O1xgZiYdTW5at8Iip2lYJanYlhDWDKNQqgHZbrEQI7drEpYGjJEvIGvrhCxlZArEGZLuH4dkk8KoHFjg7HkGQL2AzFTmRLTAna3)9ci6d1W3RwlwQLTA9Wdc3GjX5aWGQL2AZrTmRn7AL7bYOqaDGwt4xIZHXMa0cNdm1YATSg5PkKul2qKhX44LoxDCqI890pbIA0A2hZiYdTW5at8Iip2lYJanYlhDWDKNQqgHZbrEQI7drEdW9FVavOnGQs47vlZAzRwdW9FVaI(qn89Q1ILATfKcKKGqccnDIa2Y0OAPT27QL1AzwRbRbY3t)eiqaBzAuT0w7LrEQcj1Ine5rmoEjY3t)eiQrRZAmJip0cNdmXlI8hYOazKiVkoO1aKjsA))0IcbOfohyQLzTzxRb4(VxWxieScbitK0()Pffm1YSwdwd(cHGvi4z)D645gGuBEuQ9wTmR9GXodo3oazIK2)pTOqGa2Y0OAZR2lRLzTipW5sQq8bffEsNWVeJ9qfq1sP2B1YSwImMeqfAnigdkmDT0w71wlZAnyn4lecwHabSLPr1st1Exih1MxTQq8bnOJnKuCYmqKxo6G7iVVqiyfIA06CeZiYdTW5at8Ii)HmkqgjYRIdAnazIK2)pTOqaAHZbMAzwlB1EW2C4KhEAfvlTuQ94LSLmtipOn1YS2dg7m4C7aKjsA))0IcbcyltJQnVAVvlZAnynq(E6NabcyltJQLMQ9UqoQnVAvH4dAqhBiP4KzGAznYlhDWDKN890pbIA06RnMrKhAHZbM4fr(hMKAitnA9TiVC0b3rEpm2Liac)jhiQrRZ5XmI8qlCoWeViYFiJcKrI8e4raeDHZb1YS2d2MdN8WtROGbEZz0APLsT3QLHAzFT0uTSvRCpqgfci6e83aMe6)E4JOdUdqlCoWulZApySZGZTduLEq0dFVAzTwM1YwTE2FNoEUbi1MhLAVvRfl1saBzAuT5rPwDomM0XgQLzTipW5sQq8bffEsNWVeJ9qfq1slLAzFTmuRCpqgfci6e83aMe6)E4JOdUdqlCoWulR1YSw2Qn7AHmrs7)NwuWuRfl1saBzAuT5rPwDomM0XgQLMQ9YAzwlYdCUKkeFqrHN0j8lXypubuT0sPw2xld1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YATmRn7ArOe3)9atTmRLTAvH4dAqhBiP4KzGAz3AjGTmnQwwRL2AZATmRLTATfKcKKGqccnDIa2Y0OAPu7D1AXsTzxRohgN2VwM1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YAKxo6G7iVVqiyfIA0A2rmJip0cNdmXlI8pmj1qMA06BrE5OdUJ8EySlrae(toquJwNLIze5Hw4CGjErKxo6G7iVVqiyfI8hYOazKiF21sviJW5GaIXXlDU64GKVqiyfQLzTe4raeDHZb1YS2d2MdN8WtROGbEZz0APLsT3QLHAzFT0uTSvRCpqgfci6e83aMe6)E4JOdUdqlCoWulZApySZGZTduLEq0dFVAzTwM1YwTE2FNoEUbi1MhLAVvRfl1saBzAuT5rPwDomM0XgQLzTipW5sQq8bffEsNWVeJ9qfq1slLAzFTmuRCpqgfci6e83aMe6)E4JOdUdqlCoWulR1YSw2Qn7AHmrs7)NwuWuRfl1saBzAuT5rPwDomM0XgQLMQ9YAzwlYdCUKkeFqrHN0j8lXypubuT0sPw2xld1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YATmRn7ArOe3)9atTmRLTAvH4dAqhBiP4KzGAz3AjGTmnQwwRL2AVDzTmRLTATfKcKKGqccnDIa2Y0OAPu7D1AXsTzxRohgN2VwM1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YAK)C1Xbjvi(GIIwFlQrRVDxmJip0cNdmXlI8hYOazKipYdCUKkeFqr1slLAVSwM1saBzAuT5v7L1YqTSvlYdCUKkeFqr1slLAZrTSwlZApyBoCYdpTIQLwk1M1iVC0b3r(dzSr4oPGThG0OgT(2TygrEOfohyIxe5pKrbYir(SRLQqgHZbbeJJxI890pbQLzTSv7bBZHtE4PvuT0sP2SwlZAjWJai6cNdQ1ILAZUwDomoTFTmRLTA1XgQL2AVDxTwSu7bBZHtE4PvuT0sP2lRL1AzTwM1YwTE2FNoEUbi1MhLAVvRfl1saBzAuT5rPwDomM0XgQLzTipW5sQq8bffEsNWVeJ9qfq1slLAzFTmuRCpqgfci6e83aMe6)E4JOdUdqlCoWulR1YSw2Qn7AHmrs7)NwuWuRfl1saBzAuT5rPwDomM0XgQLMQ9YAzwlYdCUKkeFqrHN0j8lXypubuT0sPw2xld1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YATmRvfIpObDSHKItMbQLDRLa2Y0OAPT2Sg5LJo4oYt(E6NarnA9TlJze5Hw4CGjErKxo6G7ip57PFce5pKrbYir(SRLQqgHZbbeJJx6C1XbjY3t)eOwM1MDTufYiCoiGyC8sKVN(jqTmR9GT5Wjp80kQwAPuBwRLzTe4raeDHZb1YSw2Q1Z(70XZnaP28Ou7TATyPwcyltJQnpk1QZHXKo2qTmRf5boxsfIpOOWt6e(LyShQaQwAPul7RLHAL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzTwM1YwTzxlKjsA))0IcMATyPwcyltJQnpk1QZHXKo2qT0uTxwlZArEGZLuH4dkk8KoHFjg7HkGQLwk1Y(AzOw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwwRLzTQq8bnOJnKuCYmqTSBTeWwMgvlT1M1i)5QJdsQq8bffT(wuJwFJ9XmI8qlCoWeViYFiJcKrI8ipW5sQq8bfvlLAVvlZApyBoCYdpTIQLwk1YwThVKTKzc5bTPw2T2B1YATmRLapcGOlCoOwM1MDTqMiP9)tlkyQLzTzxRb4(VxarFOg(E1YSwBbPajjiKGqtNiGTmnQwk1ExTmRn7AL7bYOqqZDqAsPdjg75bbOfohyQLzTQq8bnOJnKuCYmqTSBTeWwMgvlT1M1iVC0b3r(dzSr4oPGThG0OgT(wwJze5LJo4oYJap0GI8qlCoWeViQrnQrEQabn4oA9L3D5D3U72TiFUcPN2hf5zNsJPrwNLz91LMxBTzqhQDS9WeT2hMu71aie0haDn1sGCYFiGPwe2gQv(k2wuWu7HU0(akuSWopnu7L08APz4MkquWu71azIK2)pTOGjC9VMAvCTxJb4(Vx46hGmrs7)NwuWCn1Y2TmznuSuSWoLgtJSolZ6RlnV2AZGou7y7HjATpmP2R5yqxtTeiN8hcyQfHTHALVITffm1EOlTpGcflSZtd1MLO51sZWnvGOGP2RrjtZiOHRF4GXodo3(AQvX1Enhm2zW52HR)1ulB3YK1qXc780qTxMdAET0mCtfikyQ9AGmrs7)NwuWeU(xtTkU2RXaC)3lC9dqMiP9)tlkyUMAz7wMSgkwyNNgQ9s2bnVwAgUPcefm1EnqMiP9)tlkycx)RPwfx71yaU)7fU(bitK0()PffmxtTSDltwdflflStPX0iRZYS(6sZRT2mOd1o2EyIw7dtQ9Amy9AQLa5K)qatTiSnuR8vSTOGP2dDP9buOyHDEAO2SsZRLMHBQarbtTxdKjsA))0IcMW1)AQvX1EngG7)EHRFaYejT)FArbZ1ulB3YK1qXsXswMThMOGP2CETYrhCxRBqkkuSe59i434GipnulngHeeAArhCxlnc7)HIfAO2S8okMdi1E7Mv1E5DxExXsXcnuBwit48vWulh8WeO2d2Mt0A5a)PrHAPXNd4POABCZU0fI977Qvo6GBuT42DvOyro6GBuWJahSnNOuepp3vjp8GWDXIC0b3OGhboyBorzGs(EyDWDXIC0b3OGhboyBorzGs(2cHrWKEysYaIs3kpcCW2CIMqWb3geLCy18OqKXKaQqRbXyqHPP9wokwKJo4gf8iWbBZjkduYhPG4u6flYrhCJcEe4GT5eLbk5JCZbssBsM5aw5rGd2Mt0eco42GOCRyro6GBuWJahSnNOmqj)pcsJc2w1InqrUhrxick9WTMWVKhoxGuSihDWnk4rGd2MtugOKV)xiMr6e(LK7bcwPB18OOIdAnazIK2)pTOqaAHZbMILIfAO2SqMW5RGPwGkqUQwDSHAv6qTYrXKAhuTcvzCcNdcflYrhCJOW4CySyHgQLgbifeNsV25vRhgHgohulBnUwQFxdeHZb1cnypaQ2PR9GT5eL1If5OdUrmqjFKcItPxSihDWnIbk5tviJW5aRAXgOanq8VkraFOthSn30GXkQI7duGgi(xfiGp0m4HheUbtIZbGbrt58Rt2UKMqEGZLOlifyTyro6GBeduYNQqgHZbw1InqbnTVdsQq8b1kQI7duqEGZLuH4dkk8KoHFjg7HkGY7YIf5OdUrmqj)J4Cj5OdUtUbPw1InqbPG4u6GXQ5rbPG4u6GjqW(FOyro6GBeduY)ioxso6G7KBqQvTyduogKvZJcBzRIdAnylifijbHeeA6a0cNdmwSyWAWxieScbDomoTpRflYrhCJyGs(hX5sYrhCNCdsTQfBGIbRflYrhCJyGs(i3CGK0MKzoGvZJc3)9ci3CGK0MKzoqGa2Y0O8uH4dAqhBiP4KzaMC)3lGCZbssBsM5abcyltJYJTBmCW2C4KhEAfXknDlWokwKJo4gXaL8pIZLKJo4o5gKAvl2afZqGJwSihDWnIbk5lKJ0qsXec0QvZJc0aX)QGbEZzuAPClhmqviJW5Ga0aX)Qeb8HoDW2CtdMIf5OdUrmqjFHCKgsEFhckwKJo4gXaL8DJpDfLYI(n(2qRflYrhCJyGs(CIFc)skzomIkwkwOHAPzySZGZTrflYrhCJchdIYhbPrbBRAXgOi3JOlebLE4wt4xYdNlqSAEuYgPG4u6GjiohtBbPajjiKGqtNiGTmnIYDmz7GXodo3oqfAdOQeiGTmnkVSCSDWyNbNBhq0hQbcyltJOjiN8hppWeeeDQsdOerUhtshmrCSYAE3UJHB3rtqo5pEEGjii6uLgqjICpMKoyI4yMTb4(VxGk0gqvj89yMTb4(VxarFOg(EflYrhCJchdIbk5FeNljhDWDYni1QwSbkacb9bqwnpkzJuqCkDWeeNJPbRbY3t)eiOZHXP9zAlifijbHeeA6ebSLPruURyHgQnl7vRymOAfcu73ZQAr94b1Q0HAXnuBUJsVwhoxaP1MrgxVqTxhqqT5sh6AnxnTFTpbPaPwLU01sZYP1AG3CgTwmP2ChLo(R1k9v1sZYPHIf5OdUrHJbXaL8TfcJGj9WKKbeLUvNRooiPcXhueLBwnpkezmjGk0Aqmgu47XKnvi(Gg0XgskozgiVd2MdN8WtROGbEZzuA6wihwSCW2C4KhEAffmWBoJslLJxYwYmH8G2WAXcnuBw2R2gxRymOAZDCUAnduBUJsF6Av6qTnKPwl7VdzvTFeuBw876vlURLdJq1M7O0XFTwPVQwAwonuSihDWnkCmigOKVTqyemPhMKmGO0TAEuiYysavO1GymOW00Y(7yxImMeqfAnigdky(erhCZ8GT5Wjp80kkyG3CgLwkhVKTKzc5bTPyro6GBu4yqmqj)Nt8bNt0b3flYrhCJchdIbk5)CIp4CIo4oDCG0iWQ5rXaC)3l8CIp4CIo4oqaBzAuExAXIb4(Vx45eFW5eDWDaPYHrAPK17kwOHAZzqBavLADy)5iUAp42m6GBXHQLtqGPwCx75tiqR1I8GtXIC0b3OWXGyGs(ufYiCoWQwSbkuH2aQkj0NtbY77dPdUnJo42kQI7duYwfh0Aa95uG8((qaAHZbglwYwUhiJcbeDc(Batc9Fp8r0b3bOfohySyXG1GVqiyfcE2FNoEUbi0EJjBipW5sQq8bffEsNWVeJ9qfq5DTwSK9bJDgCUDGQ0dIE47XAXIC0b3OWXGyGs(ufYiCoWQwSbkuH2aQkPE8PRivCmcK0b3MrhCBfvX9bkzRIdAn0JpDfPIJrGeGw4CGXILSvXbTgGmrs7)NwuiaTW5aJflhm2zW52bitK0()PffceWwMgLxoy3lPjvCqRbdaEajHuIOIpyhGw4CGPyro6GBu4yqmqjFQczeohyvl2afQczeohyvl2afQqBavL0d3A6GBZOdUTIQ4(aLSHCYF88atqUhrxick9WTMWVKhoxGyXICpqgfci6e83aMe6)E4JOdUdqlCoWyXIb4(VxGi3JjPdMiUKb4(VxWGZTTyrjtZiObbrNQ0akrK7XK0btex4GXodo3oqaBzAuE3UJjBhm2zW52be9HAGa2Y0O8UzXIb4(VxarFOg(ESwSihDWnkCmigOKpvOnGQIvZJs2ifeNshmbc2)dmnynq(E6NabDomoTpZSna3)9cuH2aQkHVhtQczeoheOcTbuvsOpNcK33hshCBgDWntQczeoheOcTbuvs94txrQ4yeiPdUnJo4MjvHmcNdcuH2aQkPhU10b3MrhCxSqd1MZKEq0Rn3rPxBwitKFTmuR1JpDfPIJrGqZRnlwYCS)21sZYP1kTP2SqMi)AjGyUQ2hMuBdzQ1EDPzxVIf5OdUrHJbXaL8Pk9GOB18OOIdAnazIK2)pTOqaAHZbgMQ4Gwd94txrQ4yeibOfohyyEW2C4KhEAfrlLJxYwYmH8G2W8GXodo3oazIK2)pTOqGa2Y0O8UvSqd1MZKEq0Rn3rPxR1JpDfPIJrGuld1AnU2SqMiFAETzXsMJ93UwAwoTwPn1MZG2aQk1(9QLTF7aeQ2pAA)AZz4CkRflYrhCJchdIbk5tv6br3Q5rrfh0AOhF6ksfhJajaTW5adZSvXbTgGmrs7)NwuiaTW5adZd2MdN8WtRiAPC8s2sMjKh0gMSzaU)7fOcTbuvcFplwaec6deOoOb3j8l5bKhC0b3bOfohyyTyHgQLhGAFFNR2d22gATwCxlDv9q088Z3Fu6FUWbBNpnsOcnDSZOSBg0S8Pry)pKFUdJt(0yesqOPfDWn7sJZPSZSlncqGqo0dflYrhCJchdIbk5tviJW5aRAXgOGqjQspi6PdUnJo42kQI7duK7bYOqarNG)gWKq)3dFeDWDaAHZbgMS14oHqjU)7bMKkeFqr0s5MflipW5sQq8bffEsNWVeJ9qfquypRmzdHsC)3dmjvi(GIschMkK8K2a2ZHYDwSG8aNlPcXhuu4jDc)sm2dvarlLRL1If5OdUrHJbXaL89WyxIai8NCaREysQHmvk3ScYujssSX)wPK1CuSihDWnkCmigOKpvPheDRMhfvCqRb0NtbY77dbOfohyyMnsbXP0btGG9)aZdg7m4C7GVqiyfcFpMSrviJW5GacLOk9GONo42m6GBlwYwUhiJcbeDc(Batc9Fp8r0b3bOfohyyYMbRbFHqWkeiWJai6cNdSyXaC)3lqfAdOQe(Emnyn4lecwHGN93PJNBasEuUXkRmpyBoCYdpTIcg4nNrPLcBSDJHlPj5EGmkeq0j4Vbmj0)9WhrhChGw4CGHvAc5boxsfIpOOWt6e(LyShQaIvAZYLvMezmjGk0AqmguyAAVDzXcnuBot6brV2ChLETzXcsbsT0yesqttZR1ACTifeNsVwPn124ALJouHAZIPX1Y9FpRQLg990pbQTXATtxlbEearVwI0(Gv1A(KP9RnNbTbuvyiJly4cSMfQLTF7aeQ2pAA)AZz4CkRflYrhCJchdIbk5tv6br3Q5rHnvCqRbBbPajjiKGqthGw4CGXIfYVHhM4dbBHWyc)skDizlifijbHeeA6aKt(JNhyyLz2ifeNshmbX5yAlifijbHeeA6ebSLPr5r5oMzBWAG890pbce4raeDHZbmnyn4lecwHabSLPr0YEMSzaU)7fOcTbuvcFpMgG7)Ebe9HA47XKTSbec6de4CySjHFjLoKGgSVkylzrXelwma3)9cCom2KWVKshsqd2xf(ESAXcGqqFGa1bn4oHFjpG8GJo4oaTW5adRfl0qT80fdoxBWzQ9Hj1YtNG)gWul))9WhrhCxSihDWnkCmigOKpIUyW5AdoJvZJs2ifeNshmbX5yk3dKrHaIob)nGjH(Vh(i6G7a0cNdmmnyn4lecwHabEearx4Catdwd(cHGvi4z)D645gGKhLBmpyBoCYdpTIcg4nNrPLYTIfAO2SqMiP9)tlkuBU0HU2gR1IuqCkDWuR0MA5Wk9APrFp9tGAL2u71vieSc1keO2VxTpmPwhU9RfA83NEOyro6GBu4yqmqjFitK0()PffSAEuYgPG4u6GjqW(FGjBzBWAWxieScbc8iaIUW5aMgSgiFp9tGabSLPr0MvgYknD8s2sMjKh0glwmynq(E6NabcyltJOP7c5Gwvi(Gg0XgskozgGvMQq8bnOJnKuCYmaTzTyro6GBu4yqmqjFe9HQvZJIdOcoAPKd2btdwdKVN(jqqNdJt7ZKTSHCYF88atqUhrxick9WTMWVKhoxGyXYbJDgCUDGk0gqvjqaBzAeT3UJ1If5OdUrHJbXaL89W6GBRMhfU)7f4CySX9rAGaYrTyXaC)3lqfAdOQe(EflYrhCJchdIbk5Z5Wyt69jxz18OyaU)7fOcTbuvcFVIf5OdUrHJbXaL85accimoTVvZJIb4(VxGk0gqvj89kwKJo4gfogeduY)neGZHXgRMhfdW9FVavOnGQs47vSihDWnkCmigOKV0haPeXLoIZz18OyaU)7fOcTbuvcFVIf5OdUrHJbXaL8)iinkyBvl2afFXbhX5ackXHXTvZJcBgG7)EbQqBavLW3ZIf2Ywfh0AaYejT)FArHa0cNdmmpySZGZTduH2aQkbcyltJOnR5WIfvCqRbitK0()PffcqlCoWWKTdg7m4C7aKjsA))0IcbcyltJY7ATy5GXodo3oazIK2)pTOqGa2Y0iAV8oMVXNUMiGTmnI2RnhSYkRmZgYejT)FArbtG890pbkwKJo4gfogeduY)JG0OGTvTydueeDQsdOerUhtshmrCwnpkgG7)EbICpMKoyI4sgG7)Ebdo32Ifvi(Gg0XgskozgiVlVRyro6GBu4yqmqj)pcsJc2w1Inqrq0PknGse5EmjDWeXz18OWw2Q4GwdqMiP9)tlkeGw4CGXILSvXbTgqFofiVVpeGw4CGHvMgG7)EbQqBavLabSLPr0E7o2nR0eKt(JNhycY9i6crqPhU1e(L8W5cKIf5OdUrHJbXaL8)iinkyBvl2afbrNQ0akrK7XK0bteNvZJcBQ4GwdqMiP9)tlkeGw4CGHPkoO1a6ZPa599Ha0cNdmSY0aC)3lqfAdOQe(EmzdYejT)FArbtWxieScwSi3dKrHaIob)nGjH(Vh(i6G7a0cNdmmnyn4lecwHGN93PJNBacT3yTyro6GBu4yqmqj)pcsJc2wbVhC0ul2aLZvhhwj4EojoNGuRMhfBbPajjiKGqtNiGTmnIYDmZ2aC)3lqfAdOQe(EmZ2aC)3lGOpudFpMC)3lyd2yYvj8l5(NXKmeqSrbdo3Mj0aX)Q8yh3X0G1a57PFceiGTmnI2SwSihDWnkCmigOK)hbPrbBRAXgO4(egbcknnAmd(Js(ZtTAEuma3)9cuH2aQkHVxXIC0b3OWXGyGs(FeKgfSTQfBGI7Juc(Js(yNb6KN7Bl(GvZJIb4(VxGk0gqvj89kwKJo4gfogeduY)JG0OGTvW7bhn1InqX3jMrumbLSbJ4CdUTAEuma3)9cuH2aQkHVxXIC0b3OWXGyGs(FeKgfSTcEp4OPwSbk(oXmIIjOeNy8bRMhfdW9FVavOnGQs47vSqd1E9GN8DATpX54KdJ1(WKA)iHZb1okyJO51EDab1I7ApySZGZTdflYrhCJchdIbk5)rqAuWgvSuSqd1E9gcC0AnIT4d1kCJB0bqfl0qTzHMk0y7AfT2SYqTSLdgQn3rPx71JN1APz50qTzz22GzefCxvlUR9sgQvfIpOiRQn3rPxBodAdOQyvTysT5ok9AZ4IS8RfR0bsUdcQnxz0AFysTiSnul0aX)QqT0yhcxBUYO1oVAZczI8R9GT5W1oOApy7P9R97fkwKJo4gfmdbokfOPcn22Q5rHTd2MdN8WtRiAPKvguXbTgma4bKesjIk(GDaAHZbglwoyBoCYdpTIOi9ylh6cXhmPJhRmzZaC)3lqfAdOQe(EwSyaU)7fq0hQHVNflqde)Rcg4nNrZJYL5GbQczeoheGgi(xLiGp0Pd2MBAWyXs2ufYiCoiGM23bjvi(GYkt2Ywfh0AaYejT)FArHa0cNdmwSCWyNbNBhGmrs7)NwuiqaBzAeTxYAXIC0b3OGziWrzGs(ufYiCoWQwSbkFeKEJZbeROkUpq5GT5Wjp80kkyG3CgL2BwSanq8VkyG3CgnpkxMdgOkKr4CqaAG4FvIa(qNoyBUPbJflztviJW5GaAAFhKuH4dAXIC0b3OGziWrzGs(iGqefmjoCdjK3Wiy15QJdsQq8bfr5MvZJs2gSgqaHikysC4gsiVHriOZHXP9TyHQqgHZbHpcsVX5act2KJouHe0G9aik3ysKXKaQqRbXyqHPP99DUebo0fIpK0XgSy5qxi(aI2lzQcXh0Go2qsXjZa5LdwlwOHAzNok9AZch64P9R9cNyaKv1Mfr6AXVAzN0dvavRO1Ejd1QcXhuKv1Ij1YE2nRmuRkeFqr1MlDORnNbTbuvQDq1(9kwKJo4gfmdbokduY)jDc)sm2dvaz18OqviJW5GWhbP34CaHPCpqgfcWHoEA)eNtmakaTW5adtKh4Cjvi(GIcpPt4xIXEOciAPCjdSzaU)7fOcTbuvcFpAITBmWMCpqgfcWHoEA)eNtmakqKMrk3yLvwlwOHAZIiDT4xTSt6HkGQv0AVLLyOwKkhgr1IF1EDCmgOR9cNyauTysTIVmnsRnRmulB5GHAZDu61E9WFohu71dJawRvfIpOOqXIC0b3OGziWrzGs(pPt4xIXEOciRMhfQczeohe(ii9gNdimzJ7)Eb6JXaDIZjgafqQCyKwk3YswSWw2EKbtg9QebRIo4MjYdCUKkeFqrHN0j8lXypubeTuYkdSj3dKrHGb)5CqYGrqGinJ0EjRmGuqCkDWeiy)pWkRfl0qTzrKUw8Rw2j9qfq1Q4Afpp3v1E9aX4UQ2CkEq4U25v70YrhQqT4UwPVQwvi(GwRO1Y(AvH4dkkuSihDWnkygcCugOK)t6e(LyShQaYQZvhhKuH4dkIYnRMhfQczeohe(ii9gNdimrEGZLuH4dkk8KoHFjg7HkGOLc7lwKJo4gfmdbokduYho0Xt7NiGhzSL2y18OqviJW5GWhbP34CaPyro6GBuWme4OmqjFXM7JOB18OqviJW5GWhbP34CaPyHgQndHJDZI)64efQvX1kEEURQ96bIXDvT5u8GWDTIw7L1QcXhuuXIC0b3OGziWrzGs(2FDCIcwDU64GKkeFqruUz18OqviJW5GWhbP34CaHjYdCUKkeFqrHN0j8lXypubeLllwKJo4gfmdbokduY3(RJtuWQ5rHQqgHZbHpcsVX5asXsXcnu71tSfFOwmvGuRo2qTc34gDauXcnul78ypATxxHqWkGQf3124MD9iJnrixvRkeFqr1(WKAv6qTEKbtg9QAjyv0b31oVAZbd1Y5aWGQviqTIJaI5QA)EflYrhCJcgSsHQqgHZbw1InqbX44LoxDCqYxieScwrvCFGIhzWKrVkrWQOdUzI8aNlPcXhuu4jDc)sm2dvarl7zYMbRbFHqWkeiGTmnkVdg7m4C7GVqiyfcMpr0b3wS4HheUbtIZbGbrBoyTyHgQLDEShTwA03t)eavlURTXn76rgBIqUQwvi(GIQ9Hj1Q0HA9idMm6v1sWQOdURDE1MdgQLZbGbvRqGAfhbeZv1(9kwKJo4gfmyLbk5tviJW5aRAXgOGyC8sNRooir(E6NawrvCFGIhzWKrVkrWQOdUzI8aNlPcXhuu4jDc)sm2dvarl7zYMb4(VxarFOg(EwSWMhEq4gmjohageT5Gz2Y9azuiGoqRj8lX5WytaAHZbgwzTyHgQLDEShTwA03t)eav78QnNbTbuvyGN(qn)SybPaPwAmcji001oOA)E1kTP2CHAPluHAVKHArWb3guTo4P1I7Av6qT0OVN(jqTxpCgflYrhCJcgSYaL8PkKr4CGvTyduqmoEjY3t)eWkQI7duma3)9cuH2aQkHVht2ma3)9ci6d1W3ZIfBbPajjiKGqtNiGTmnI27yLPbRbY3t)eiqaBzAeTxwSqd1Y7bNrC1EDfcbRqTsBQLg990pbQfb63RwpYGj1Q4AZczIK2)pTOqThbPflYrhCJcgSYaL89fcbRGvZJIkoO1aKjsA))0IcbOfohyyMnKjsA))0IcMGVqiyfyAWAWxieScbp7Vthp3aK8OCJ5bJDgCUDaYejT)FArHabSLPr5DjtKh4Cjvi(GIcpPt4xIXEOcik3ysKXKaQqRbXyqHPP9AzAWAWxieScbcyltJOP7c5ipvi(Gg0XgskozgOyro6GBuWGvgOKp57PFcy18OOIdAnazIK2)pTOqaAHZbgMSDW2C4KhEAfrlLJxYwYmH8G2W8GXodo3oazIK2)pTOqGa2Y0O8UX0G1a57PFceiGTmnIMUlKJ8uH4dAqhBiP4KzawlwOHAVUcHGvO2VhJa4zvTIdHRvjdGQvX1(rqTJwRGQvQf5bNrC16dnqeftQ9Hj1Q0HADcsRLMLtRLdEycuRu7B6brhiflYrhCJcgSYaL89WyxIai8NCaREysQHmvk3kwKJo4gfmyLbk57lecwbRMhfc8iaIUW5aMhSnho5HNwrbd8MZO0s5gdSNMytUhiJcbeDc(Batc9Fp8r0b3bOfohyyEWyNbNBhOk9GOh(ESYKnp7Vthp3aK8OCZIfcyltJYJIohgt6ydmrEGZLuH4dkk8KoHFjg7HkGOLc7zqUhiJcbeDc(Batc9Fp8r0b3bOfohyyLjBzdzIK2)pTOGXIfcyltJYJIohgt6yd00LmrEGZLuH4dkk8KoHFjg7HkGOLc7zqUhiJcbeDc(Batc9Fp8r0b3bOfohyyLz2iuI7)EGHjBQq8bnOJnKuCYma7saBzAeR0MvMSzlifijbHeeA6ebSLPruUZILS15W40(mL7bYOqarNG)gWKq)3dFeDWDaAHZbgwlwKJo4gfmyLbk57HXUebq4p5aw9WKudzQuUvSihDWnkyWkduY3xieScwDU64GKkeFqruUz18OKnvHmcNdcighV05QJds(cHGvGjbEearx4CaZd2MdN8WtROGbEZzuAPCJb2ttSj3dKrHaIob)nGjH(Vh(i6G7a0cNdmmpySZGZTduLEq0dFpwzYMN93PJNBasEuUzXcbSLPr5rrNdJjDSbMipW5sQq8bffEsNWVeJ9qfq0sH9mi3dKrHaIob)nGjH(Vh(i6G7a0cNdmSYKTSHmrs7)NwuWyXcbSLPr5rrNdJjDSbA6sMipW5sQq8bffEsNWVeJ9qfq0sH9mi3dKrHaIob)nGjH(Vh(i6G7a0cNdmSYmBekX9FpWWKnvi(Gg0XgskozgGDjGTmnIvAVDjt2SfKcKKGqccnDIa2Y0ik3zXs26CyCAFMY9azuiGOtWFdysO)7HpIo4oaTW5adRfl0qT0mYyJWDTza2EasRf31A)D645GAvH4dkQwrRnRmulnlNwBU0HUwYV7P9Rf)1ANU2lr1Y23RwfxBwRvfIpOiwRftQL9OAzlhmuRkeFqrSwSihDWnkyWkduY)qgBeUtky7bi1Q5rb5boxsfIpOiAPCjtcyltJY7sgyd5boxsfIpOiAPKdwzEW2C4KhEAfrlLSwSqd1YobaVA)E1sJ(E6Na1kATzLHAXDTIZvRkeFqr1YwU0HUw3qDA)AD42VwOXFF61kTP2gR1IAXdrhRSwSihDWnkyWkduYN890pbSAEuYMQqgHZbbeJJxI890pbyY2bBZHtE4PveTuYktc8iaIUW5alwYwNdJt7ZKnDSbAVDNflhSnho5HNwr0s5swzLjBE2FNoEUbi5r5MfleWwMgLhfDomM0XgyI8aNlPcXhuu4jDc)sm2dvarlf2ZGCpqgfci6e83aMe6)E4JOdUdqlCoWWkt2YgYejT)FArbJfleWwMgLhfDomM0XgOPlzI8aNlPcXhuu4jDc)sm2dvarlf2ZGCpqgfci6e83aMe6)E4JOdUdqlCoWWktvi(Gg0XgskozgGDjGTmnI2SwSihDWnkyWkduYN890pbS6C1Xbjvi(GIOCZQ5rjBQczeoheqmoEPZvhhKiFp9taMztviJW5GaIXXlr(E6NampyBoCYdpTIOLswzsGhbq0fohWKnp7Vthp3aK8OCZIfcyltJYJIohgt6ydmrEGZLuH4dkk8KoHFjg7HkGOLc7zqUhiJcbeDc(Batc9Fp8r0b3bOfohyyLjBzdzIK2)pTOGXIfcyltJYJIohgt6yd00LmrEGZLuH4dkk8KoHFjg7HkGOLc7zqUhiJcbeDc(Batc9Fp8r0b3bOfohyyLPkeFqd6ydjfNmdWUeWwMgrBwlwOHAPzKXgH7AZaS9aKwlURLpJANxTtxRN0gWEo1kTP2rRn3X5Q1GR1biuTgXw8HAv6sxBwOPcn2UwZhQvX1MXf5NftJZpdLDsXIC0b3OGbRmqj)dzSr4oPGThGuRMhfKh4Cjvi(GIOCJ5bBZHtE4PveTuy74LSLmtipOnS7nwzsGhbq0fohWmBitK0()PffmmZ2aC)3lGOpudFpM2csbssqibHMoraBzAeL7yMTCpqgfcAUdstkDiXyppiaTW5adtvi(Gg0XgskozgGDjGTmnI2SwSihDWnkyWkduYhbEObvSuSqd1MfqiOpaQyro6GBuaqiOpaIYb3hOvIOGj9CIny18Oanq8VkOJnKuCYwYK2BmZ2aC)3lqfAdOQe(EmzlBdwdhCFGwjIcM0Zj2qI7t6GohgN2Nz2YrhCho4(aTsefmPNtSHW0PNB8PRwS8(oxIah6cXhs6yd55FmbBjtwlwOHAPXUCLRq1(rqTx4WytT5ok9AZzqBavLA)EHAVoIDMAFysTzHmrs7)Nwuiu71beuBUJsV2mUO2VxTCWdtGALAFtpi6aPwbvRd3(1kOAhTwYVr1(WKAVDhQwZNmTFT5mOnGQsOyro6GBuaqiOpaIbk5Z5Wytc)skDibnyFLvZJIb4(VxGk0gqvj89yYgKjsA))0IcMGVqiyfSyXaC)3lGOpudFpMhSnho5HNwrbd8MZO5r5MflgG7)EbQqBavLabSLPr5r52DSAXYB8PRjcyltJYJYT7kwOHAPXQc2EATkUwXn(DTx3VqmJ01M7O0RnNbTbuvQvq16WTFTcQ2rRnxCFnATea9DATtxRdJM2VwP2335yxQI7d1EeKwlMkqQvPd1saBz6P9R18jIo4Uw8RwLou7B8PRflYrhCJcacb9bqmqjF)VqmJ0j8lj3deSs3Q5r5GXodo3oqfAdOQeiGTmnkp2BXIb4(VxGk0gqvj89Sy5n(01ebSLPr5X(7kwKJo4gfaec6dGyGs((FHygPt4xsUhiyLUvZJYZHXe2y7n(01ebSLPrSl7VJ1RZdg7m4CBwP95WycBS9gF6AIa2Y0i2L93XUhm2zW52bQqBavLabSLPrSEDEWyNbNBZAXIC0b3OaGqqFaeduY)HpFeysY9azuiXbITvZJcYdCUKkeFqrHN0j8lXypubeTuU0IfImMeqfAnigdkmnTx7DmHgi(xLxo)UIf5OdUrbaHG(aigOKV3NmVRM2pX5eKA18OG8aNlPcXhuu4jDc)sm2dvarlLlTyHiJjbuHwdIXGctt71ExXIC0b3OaGqqFaeduYxPdPFZH)Tj9WKdy18OW9FVabom6aek9WKde(EwSW9FVabom6aek9WKdKo4FRajGu5WyE3URyro6GBuaqiOpaIbk5tgpphKMoH8KduSihDWnkaie0haXaL8ZftCgQW0jcGWT0hOyro6GBuaqiOpaIbk5Bd2yYvj8l5(NXKmeqSrwnpkqde)RYlh3Xm7dg7m4C7avOnGQs47vSqd1EDe7m1sJaXBA)AZI4eBav7dtQfYeoFfQLiTpulMulJJZvl3)9qwv78Q1dJqdNdc1sJD5kxHQvjxvRIR1h0Av6qToCUasR9GXodo3UwobbMAXDTcvzCcNdQfAWEauOyro6GBuaqiOpaIbk5taXBA)0Zj2aYQZvhhKuH4dkIYnRMhfvi(Gg0XgskozgiVBHCyXcBSPcXh0aDqCk9G3rPLDCNflQq8bnqheNsp4D08OC5DSYKn5OdvibnypaIYnlwuH4dAqhBiP4KzaAVmlXkRwSWMkeFqd6ydjfN8oA6Y7OL93XKn5OdvibnypaIYnlwuH4dAqhBiP4KzaAZAwzL1ILIfAOwEfeNshm1sJp6GBuXcnuR1JpDKkogbsT4U2BzqZRLVfpeDSwln67PFcuSihDWnkGuqCkDWqH890pbSAEuuXbTg6XNUIuXXiqcqlCoWW8GT5Wjp80kIwkzLPkeFqd6ydjfNmdWUeWwMgr71wSqd1Y)5uG8((qTmulpDc(BatT8)3dFeDWnnV2SqJ(eO2CHA)iOwCd167WCIRwfxR455UQ2RRqiyfQvX1Q0HATLPRvfIpO1oVAhT2bvBJ1ArT4HOJ1AVcuRQfHRvCUAXkDGuRTmDTQq8bTwHBCJoaQwpc(nAOyro6GBuaPG4u6GHbk57HXUebq4p5aw9WKudzQuUvSihDWnkGuqCkDWWaL89fcbRGvZJICpqgfci6e83aMe6)E4JOdUdqlCoWWK7)Eb0NtbY77dHVhtU)7fqFofiVVpeiGTmnkVBb2ZmBekX9FpWuSqd1Y)5uG8((anVwASNN7QAXKAPrWJai61M7O0RL7)EGP2RRqiyfqflYrhCJcifeNshmmqjFpm2Liac)jhWQhMKAitLYTIf5OdUrbKcItPdggOKVVqiyfS6C1Xbjvi(GIOCZQ5rrfh0Aa95uG8((qaAHZbgMSraBzAuE3U0Ifp7Vthp3aK8OCJvMQq8bnOJnKuCYma7saBzAeTxwSqd1Y)5uG8((qTmulpDc(BatT8)3dFeDWDTtxlFg08APXEEURQfeI7QAPrFp9tGAv6IwBUJZvlhulbEearhm1(WKA9K2a2ZPyro6GBuaPG4u6GHbk5t(E6NawnpkQ4GwdOpNcK33hcqlCoWWuUhiJcbeDc(Batc9Fp8r0b3bOfohyyMTbRbY3t)eiOZHXP9zsviJW5GaAAFhKuH4dAXcnul)NtbY77d1MB(1YtNG)gWul))9WhrhCtZRLgbINN7QAFysTC4(JQLMLtRvAt(ysTqMk0gWulQfpeDSwR5teDWDOyro6GBuaPG4u6GHbk57HXUebq4p5aw9WKudzQuUvSihDWnkGuqCkDWWaL89fcbRGvNRooiPcXhueLBwnpkQ4GwdOpNcK33hcqlCoWWuUhiJcbeDc(Batc9Fp8r0b3bOfohyyYMC0HkKGgShar7nlwYwfh0AaYejT)FArHa0cNdmSYufIpObDSHKItMbOLa2Y0iMSraBzAuE3yhwSKncL4(VhyyTyHgQL)ZPa599HAzO2SqMi)AXDT3YGMxlncEearV2RRqiyfQv0Av6qTqBQf)QfPG4u61Q4A9bTwBjZAnFIOdURLdEycuBwitK0()PffkwKJo4gfqkioLoyyGs(EySlrae(toGvpmj1qMkLBflYrhCJcifeNshmmqjFFHqWky18OOIdAnG(CkqEFFiaTW5adtvCqRbitK0()PffcqlCoWWuo6qfsqd2dGOCJj3)9cOpNcK33hceWwMgL3Ta7J8ip4eT(YCKLIAuJr]] )

end