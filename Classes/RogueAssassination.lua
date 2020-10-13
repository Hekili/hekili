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


    spec:RegisterPack( "Assassination", 20201013, [[difRgcqirPEesrUesbQnHs(KOcnkuKtHcwfsr9kukZIsYTqPs7sWVevAyQu5yQuwMkrpdLQMMOqxturBtLu5BQKIghkv05efO1HuqVtubQMNOk3dj2hsP)jQa5GifQfQsYdvjvnrKc4IIcYgffq9rvsPgjsbsNuuawjk0lrPcmtvsj3uubStkP(POcugQkPWsrkKNIQMQOKRIuGyRIkOVIsf0yrPcTxH(RidwPdtSyu5XQyYuCzWMvLptvgns1PvSArbKxJIA2u52uQDl1VHA4uvhxuqTCephY0jDDv12rsFxuvJxu05vjSEvQA(uI9l54TywrEJOq06lV7Y7UD3n2hUldY(7yFgJ86f(qK3xomlEqKVfBiYtJribHMw0b3rEF5chwmXSI8i8NCGipDv9r0WCZ1Bu6FUWbBNlAS)orhCFiYtZfn2NCJ8C)XPzaDKlYBefIwF5DxE3T7UX(WDzq2Fh7J8YxPJjrE(X(6J80hJb6ixK3aOtKNMQLgJqccnTOdURLgH9(qXinvBoyhfZbKAVXERQ9Y7U8UiVBqkkMvKhPG4u6GjMv06BXSI8qlCoWeVkYFiJcKrI8Q4Gwd94rxrQ4ygibOfohyQLvThSnho5JNwr1slLAZyTSQvfIhObDSHKItMbQLDRLa2Y0OAPT2RlYlhDWDKN891pbIA06lJzf5Hw4CGjEvK)HjPgYuJwFlYlhDWDK3hJDjcGWFYbIA0A2hZkYdTW5at8Qi)HmkqgjYl3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YQwU)7fqFofiVVhe((1YQwU)7fqFofiVVheiGTmnQ28Q9wG91YQ2SRfHsC)3dmrE5OdUJ8EcHGviQrRZymRip0cNdmXRI8pmj1qMA06BrE5OdUJ8(ySlrae(toquJwNZywrEOfohyIxf5LJo4oY7jecwHi)HmkqgjYRIdAnG(CkqEFpiaTW5atTSQLPAjGTmnQ28Q92L1AXsT(2FNo(Ubi1MhLAVvld1YQwviEGg0XgskozgOw2TwcyltJQL2AVmYFU44GKkepqrrRVf1O1xxmRip0cNdmXRI8hYOazKiVkoO1a6ZPa599Ga0cNdm1YQw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1MDTgSgiFF9tGGohMN2Rww1sviJW5GaAAphKuH4bAKxo6G7ip57RFce1O1xZywrEOfohyIxf5FysQHm1O13I8YrhCh59XyxIai8NCGOgTMDgZkYdTW5at8QiVC0b3rEpHqWke5pKrbYirEvCqRb0NtbY77bbOfohyQLvTY9azuiGOtWFdysO)7HpIo4oaTW5atTSQLPALJouHe0G9aOAPT2B1AXsTzxRkoO1aKjsAV)0IcbOfohyQLHAzvRkepqd6ydjfNmdulT1saBzAuTSQLPAjGTmnQ28Q9g7SwlwQn7ArOe3)9atTme5pxCCqsfIhOOO13IA06mymRip0cNdmXRI8pmj1qMA06BrE5OdUJ8(ySlrae(toquJwF7UywrEOfohyIxf5pKrbYirEvCqRb0NtbY77bbOfohyQLvTQ4GwdqMiP9(tlkeGw4CGPww1khDOcjOb7bq1sP2B1YQwU)7fqFofiVVheiGTmnQ28Q9wG9rE5OdUJ8EcHGviQrnYdie0hafZkA9TywrEOfohyIxf5pKrbYirEObI3fbDSHKIt2sM1sBT3QLvTzxRb4(VxGk0gqvj89RLvTmvB21AWA4G7d0kruWKEoXgsCFsh05W80E1YQ2SRvo6G7Wb3hOvIOGj9CIneMo9CJhDTwlwQ99DUebo0fIhK0XgQnVA9oMGTKzTme5LJo4oYFW9bALikyspNydrnA9LXSI8qlCoWeVkYFiJcKrI8gG7)EbQqBavLW3Vww1YuTgG7)EbpHqWkeGmrs79NwuWuRfl1AaU)7fq0hQHVFTSQ9GT5WjF80kkyG3CgT28Ou7TATyPwdW9FVavOnGQsGa2Y0OAZJsT3URwgQ1ILAFJhDnraBzAuT5rP2B3f5LJo4oYZ5Wytc)skDibnyFruJwZ(ywrEOfohyIxf5pKrbYir(dg7m487avOnGQsGa2Y0OAZRw2xRfl1AaU)7fOcTbuvcF)ATyP234rxteWwMgvBE1Y(7I8YrhCh59(cXmsNWVKCpqWk9OgToJXSI8qlCoWeVkYFiJcKrI8phgtQLPAzQ234rxteWwMgvl7wl7VRwgQn3ALJo4oDWyNbNFxld1sBTphgtQLPAzQ234rxteWwMgvl7wl7VRw2T2dg7m487avOnGQsGa2Y0OAzO2CRvo6G70bJDgC(DTme5LJo4oY79fIzKoHFj5EGGv6rnADoJzf5Hw4CGjEvK)qgfiJe5r(GZLuH4bkk8KoHFjM7HkGQLwk1EzTwSulrgtcOcTgeJbfMUwAR96URww1cnq8UO28Q9AExKxo6G7i)dF(iWKK7bYOqIde7OgT(6Izf5Hw4CGjEvK)qgfiJe5r(GZLuH4bkk8KoHFjM7HkGQLwk1EzTwSulrgtcOcTgeJbfMUwAR96UlYlhDWDK3)tM3ft7L4CcsJA06RzmRip0cNdmXRI8hYOazKip3)9ce4WSdqO0dtoq47xRfl1Y9FVabom7aek9WKdKo4FRajGu5WCT5v7T7I8YrhCh5v6q63C4FBspm5arnAn7mMvKxo6G7ipz89DqA6eYxoqKhAHZbM4vrnADgmMvKxo6G7iF(yIZqfMoraeUL(arEOfohyIxf1O13UlMvKhAHZbM4vr(dzuGmsKhAG4DrT5vBoVRww1MDThm2zW53bQqBavLW3pYlhDWDK3gSXKls4xY9pJjziGyJIA06B3Izf5Hw4CGjEvKxo6G7ipbe)P9spNydOi)HmkqgjYRcXd0Go2qsXjZa1MxT3c5SwlwQLPAzQwviEGgOdItPh8pAT0wl78UATyPwviEGgOdItPh8pAT5rP2lVRwgQLvTmvRC0HkKGgShavlLAVvRfl1QcXd0Go2qsXjZa1sBTxMbRLHAzOwlwQLPAvH4bAqhBiP4K)rtxExT0wl7VRww1YuTYrhQqcAWEauTuQ9wTwSuRkepqd6ydjfNmdulT1MXmwld1YqK)CXXbjviEGIIwFlQrnYBGN8DAmRO13Izf5LJo4oYZ8CyoYdTW5at8QOgT(YywrE5OdUJ8ifeNspYdTW5at8QOgTM9XSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qKhAG4DrGaEqxlB16JheUbtIZbGbvlnx71S2CRLPAVSwAUwKp4Cj6csHAziYtviPwSHip0aX7Ieb8GoDW2CtdMOgToJXSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qKh5doxsfIhOOWt6e(LyUhQaQ28Q9YipvHKAXgI8OP9CqsfIhOrnADoJzf5Hw4CGjEvK)qgfiJe5rkioLoyceS3hI8YrhCh5pIZLKJo4o5gKg5DdstTydrEKcItPdMOgT(6Izf5Hw4CGjEvK)qgfiJe5zQ2SRvfh0AWwqkqsccji00bOfohyQ1ILAnyn4jecwHGohMN2RwgI8YrhCh5pIZLKJo4o5gKg5DdstTydr(Jbf1O1xZywrEOfohyIxf5LJo4oYFeNljhDWDYninY7gKMAXgI8gSg1O1SZywrEOfohyIxf5pKrbYirEU)7fqU5ajPnjZCGabSLPr1MxTQq8anOJnKuCYmqTSQL7)EbKBoqsAtYmhiqaBzAuT5vlt1ERw2Q9GT5WjF80kQwgQLMR9wGDg5LJo4oYJCZbssBsM5arnADgmMvKhAHZbM4vrE5OdUJ8hX5sYrhCNCdsJ8UbPPwSHiVziWrJA06B3fZkYdTW5at8Qi)HmkqgjYdnq8UiyG3CgTwAPu7TCwlB1sviJW5Ga0aX7Ieb8GoDW2CtdMiVC0b3rEHCKgskMqGwJA06B3Izf5LJo4oYlKJ0qY)7qqKhAHZbM4vrnA9TlJzf5LJo4oY7gp6kkLb6B8SHwJ8qlCoWeVkQrRVX(ywrE5OdUJ8CIxc)skzomJI8qlCoWeVkQrnY7tGd2Mt0ywrRVfZkYlhDWDKx89DxK8Xdc3rEOfohyIxf1O1xgZkYdTW5at8QiVC0b3rEBHWmyspmjzarPh5pKrbYirEImMeqfAnigdkmDT0w7TCg59jWbBZjAcbhCBqr(Cg1O1SpMvKxo6G7ipsbXP0J8qlCoWeVkQrRZymRip0cNdmXRI8YrhCh5rU5ajPnjZCGiVpboyBorti4GBdkYFlQrRZzmRip0cNdmXRI8TydrE5EeDHiO0d3Ac)s(48bsKxo6G7iVCpIUqeu6HBnHFjFC(ajQrRVUywrEOfohyIxf5pKrbYirEvCqRbitK0E)PffcqlCoWe5LJo4oY79fIzKoHFj5EGGv6rnQrEZqGJgZkA9TywrEOfohyIxf5pKrbYirEMQ9GT5WjF80kQwAPuBgRLTAvXbTgma4dKesjIkEGDaAHZbMATyP2d2MdN8XtROAPuR0JTCOlepWKo(1YqTSQLPAna3)9cuH2aQkHVFTwSuRb4(VxarFOg((1AXsTqdeVlcg4nNrRnpk1EzoRLTAPkKr4CqaAG4DrIaEqNoyBUPbtTwSuB21sviJW5GaAAphKuH4bATmulRAzQ2SRvfh0AaYejT3FArHa0cNdm1AXsThm2zW53bitK0E)PffceWwMgvlT1EzTme5LJo4oYdnvOX2rnA9LXSI8qlCoWeVkYJ9J8iqJ8YrhCh5PkKr4CqKNQ4(qK)GT5WjF80kkyG3CgTwAR9wTwSul0aX7IGbEZz0AZJsTxMZAzRwQczeoheGgiExKiGh0Pd2MBAWuRfl1MDTufYiCoiGM2ZbjviEGg5PkKul2qK)JG0BCoGe1O1SpMvKhAHZbM4vrE5OdUJ8iGqefmjoCdjK)Wme5pKrbYir(SR1G1acierbtId3qc5pmdbDompTxTwSulvHmcNdcFeKEJZbKAzvlt1khDOcjOb7bq1sP2B1YQwImMeqfAnigdkmDT0w777CjcCOlepiPJnuRfl1EOlepavlT1EzTSQvfIhObDSHKItMbQnVAZzTme5pxCCqsfIhOOO13IA06mgZkYdTW5at8Qi)HmkqgjYtviJW5GWhbP34CaPww1k3dKrHaCOJN2lX5edGcqlCoWulRAr(GZLuH4bkk8KoHFjM7HkGQLwk1EzTSvlt1AaU)7fOcTbuvcF)AP5AzQ2B1YwTmvRCpqgfcWHoEAVeNtmakqKM5APu7TAzOwgQLHiVC0b3r(N0j8lXCpubuuJwNZywrEOfohyIxf5pKrbYirEQczeohe(ii9gNdi1YQwMQL7)Eb6JXaDIZjgafqQCyUwAPu7TmyTwSult1MDT(Kbtg9IebRIo4Uww1I8bNlPcXduu4jDc)sm3dvavlTuQnJ1YwTmvRCpqgfcg8NZbjdgbbI0mxlT1EzTmulB1IuqCkDWeiyVpuld1YqKxo6G7i)t6e(LyUhQakQrRVUywrEOfohyIxf5LJo4oY)KoHFjM7HkGI8hYOazKipvHmcNdcFeKEJZbKAzvlYhCUKkepqrHN0j8lXCpubuT0sPw2h5pxCCqsfIhOOO13IA06RzmRip0cNdmXRI8hYOazKipvHmcNdcFeKEJZbKiVC0b3rE4qhpTxIa(KXwAtuJwZoJzf5Hw4CGjEvK)qgfiJe5PkKr4Cq4JG0BCoGe5LJo4oYl2CFe9OgTodgZkYdTW5at8QiVC0b3rE7VoorHi)HmkqgjYtviJW5GWhbP34CaPww1I8bNlPcXduu4jDc)sm3dvavlLAVmYFU44GKkepqrrRVf1O13UlMvKhAHZbM4vr(dzuGmsKNQqgHZbHpcsVX5asKxo6G7iV9xhNOquJAK)yqXSIwFlMvKhAHZbM4vrE5OdUJ8Y9i6crqPhU1e(L8X5dKi)HmkqgjYNDTifeNshmbX5QLvT2csbssqibHMoraBzAuTuQ9UAzvlt1EWyNbNFhOcTbuvceWwMgvBE5GQLPApySZGZVdi6d1abSLPr1sZ1cz4)47dMGGOtvAaLiY9ys6GjIRwgQLHAZR2B3vlB1E7UAP5AHm8F89btqq0PknGse5EmjDWeXvlRAZUwdW9FVavOnGQs47xlRAZUwdW9FVaI(qn89J8TydrE5EeDHiO0d3Ac)s(48bsuJwFzmRip0cNdmXRI8hYOazKiF21IuqCkDWeeNRww1AWAG891pbc6CyEAVAzvRTGuGKeesqOPteWwMgvlLAVlYlhDWDK)ioxso6G7KBqAK3nin1Ine5bec6dGIA0A2hZkYdTW5at8QiVC0b3rEBHWmyspmjzarPh5pKrbYirEImMeqfAnigdk89RLvTmvRkepqd6ydjfNmduBE1EW2C4KpEAffmWBoJwlnx7TqoR1ILApyBoCYhpTIcg4nNrRLwk1E8t2sMjKp0MAziYFU44GKkepqrrRVf1O1zmMvKhAHZbM4vr(dzuGmsKNiJjbuHwdIXGctxlT1Y(7QLDRLiJjbuHwdIXGcMpr0b31YQ2d2MdN8XtROGbEZz0APLsTh)KTKzc5dTjYlhDWDK3wimdM0dtsgqu6rnADoJzf5LJo4oY)CIh4CIo4oYdTW5at8QOgT(6Izf5Hw4CGjEvK)qgfiJe5na3)9cpN4boNOdUdeWwMgvBE1EzTwSuRb4(Vx45epW5eDWDaPYH5APLsTz8UiVC0b3r(Nt8aNt0b3PJdKgbrnA91mMvKhAHZbM4vrESFKhbAKxo6G7ipvHmcNdI8uf3hI8zxRkoO1a6ZPa599Ga0cNdm1AXsTzxRCpqgfci6e83aMe6)E4JOdUdqlCoWuRfl1AWAWtieScbF7VthF3aKAPT2B1YQwMQf5doxsfIhOOWt6e(LyUhQaQ28Q96Q1ILAZU2dg7m487avPhe9W3VwgI8ufsQfBiYtfAdOQKqFofiVVhKo42m6G7OgTMDgZkYdTW5at8Qip2pYJanYlhDWDKNQqgHZbrEQI7dr(SRvfh0AOhp6ksfhZajaTW5atTwSuB21QIdAnazIK27pTOqaAHZbMATyP2dg7m487aKjsAV)0IcbcyltJQnVAZzTSBTxwlnxRkoO1GbaFGKqkruXdSdqlCoWe5PkKul2qKNk0gqvj1JhDfPIJzGKo42m6G7OgTodgZkYdTW5at8Qip2pYJanYlhDWDKNQqgHZbrEQI7dr(SRfYW)X3hmb5EeDHiO0d3Ac)s(48bsTwSuRCpqgfci6e83aMe6)E4JOdUdqlCoWuRfl1AaU)7fiY9ys6GjIlzaU)7fm487ATyP2dg7m487GGOtvAaLiY9ys6GjIlqaBzAuT5v7T7QLvTmv7bJDgC(DarFOgiGTmnQ28Q9wTwSuRb4(VxarFOg((1YqKNQqsTydrEQqBavL0d3A6GBZOdUJA06B3fZkYdTW5at8Qi)HmkqgjYNDTifeNshmbc27d1YQwdwdKVV(jqqNdZt7vlRAZUwdW9FVavOnGQs47xlRAPkKr4CqGk0gqvjH(CkqEFpiDWTz0b31YQwQczeoheOcTbuvs94rxrQ4ygiPdUnJo4Uww1sviJW5GavOnGQs6HBnDWTz0b3rE5OdUJ8uH2aQkrnA9TBXSI8qlCoWeVkYFiJcKrI8Q4GwdqMiP9(tlkeGw4CGPww1QIdAn0JhDfPIJzGeGw4CGPww1EW2C4KpEAfvlTuQ94NSLmtiFOn1YQ2dg7m487aKjsAV)0IcbcyltJQnVAVf5LJo4oYtv6brpQrRVDzmRip0cNdmXRI8hYOazKiVkoO1qpE0vKkoMbsaAHZbMAzvB21QIdAnazIK27pTOqaAHZbMAzv7bBZHt(4PvuT0sP2JFYwYmH8H2ulRAzQwdW9FVavOnGQs47xRfl1cie0hiqDqdUt4xYhip4OdUdqlCoWuldrE5OdUJ8uLEq0JA06BSpMvKhAHZbM4vrESFKhbAKxo6G7ipvHmcNdI8uf3hI8Y9azuiGOtWFdysO)7HpIo4oaTW5atTSQLPABCNqOe3)9atsfIhOOAPLsT3Q1ILAr(GZLuH4bkk8KoHFjM7HkGQLsTSVwgQLvTmvlcL4(VhysQq8afLeomvi5lTbSNtTuQ9UATyPwKp4CjviEGIcpPt4xI5EOcOAPLsTxxTme5PkKul2qKhHsuLEq0thCBgDWDuJwFlJXSI8qlCoWeVkYlhDWDK3hJDjcGWFYbI8qMkrsIn(3AKpJ5mY)WKudzQrRVf1O13YzmRip0cNdmXRI8hYOazKiVkoO1a6ZPa599Ga0cNdm1YQ2SRfPG4u6GjqWEFOww1EWyNbNFh8ecbRq47xlRAzQwQczeoheqOevPhe90b3MrhCxRfl1MDTY9azuiGOtWFdysO)7HpIo4oaTW5atTSQLPAnyn4jecwHabEearx4CqTwSuRb4(VxGk0gqvj89RLvTgSg8ecbRqW3(70X3naP28Ou7TAzOwgQLvThSnho5JNwrbd8MZO1slLAzQwMQ9wTSv7L1sZ1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YqT0CTiFW5sQq8affEsNWVeZ9qfq1YqT0MdQ2mwlRAjYysavO1GymOW01sBT3UmYlhDWDKNQ0dIEuJwF76Izf5Hw4CGjEvK)qgfiJe5zQwvCqRbBbPajjiKGqthGw4CGPwlwQL8B4HjEqWwimNWVKshs2csbssqibHMoaz4)47dMAzOww1MDTifeNshmbX5QLvT2csbssqibHMoraBzAuT5rP27QLvTzxRbRbY3x)eiqGhbq0fohulRAnyn4jecwHabSLPr1sBTSVww1YuTgG7)EbQqBavLW3Vww1AaU)7fq0hQHVFTSQLPAZUwaHG(abohgBs4xsPdjOb7lc2sgimPwlwQ1aC)3lW5Wytc)skDibnyFr47xld1AXsTacb9bcuh0G7e(L8bYdo6G7a0cNdm1YqKxo6G7ipvPhe9OgT(21mMvKhAHZbM4vr(dzuGmsKp7ArkioLoycIZvlRAL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzvRbRbpHqWkeiWJai6cNdQLvTgSg8ecbRqW3(70X3naP28Ou7TAzv7bBZHt(4PvuWaV5mAT0sP2BrE5OdUJ8i6IbNVn4mrnA9n2zmRip0cNdmXRI8hYOazKiF21IuqCkDWeiyVpulRAzQ2SR1G1GNqiyfce4raeDHZb1YQwdwdKVV(jqGa2Y0OAPT2mwlB1MXAP5Ap(jBjZeYhAtTwSuRbRbY3x)eiqaBzAuT0CT3fYzT0wRkepqd6ydjfNmduld1YQwviEGg0XgskozgOwARnJrE5OdUJ8qMiP9(tlke1O13YGXSI8qlCoWeVkYFiJcKrI8oGk4QLwk1Mt2zTSQ1G1a57RFce05W80E1YQwMQn7AHm8F89btqUhrxick9WTMWVKpoFGuRfl1EWyNbNFhOcTbuvceWwMgvlT1E7UAziYlhDWDKhrFOg1O1xExmRip0cNdmXRI8hYOazKip3)9cCom24(inqa5O1AXsTgG7)EbQqBavLW3pYlhDWDK3hRdUJA06lVfZkYdTW5at8Qi)HmkqgjYBaU)7fOcTbuvcF)iVC0b3rEohgBsVp5IOgT(YlJzf5Hw4CGjEvK)qgfiJe5na3)9cuH2aQkHVFKxo6G7iphqqaH5P9IA06lzFmRip0cNdmXRI8hYOazKiVb4(VxGk0gqvj89J8YrhCh5Fdb4CySjQrRVmJXSI8qlCoWeVkYFiJcKrI8gG7)EbQqBavLW3pYlhDWDKx6dGuI4shX5IA06lZzmRip0cNdmXRI8YrhCh59ehCeNdiOehg3r(dzuGmsKNPAna3)9cuH2aQkHVFTwSult1MDTQ4GwdqMiP9(tlkeGw4CGPww1EWyNbNFhOcTbuvceWwMgvlT1MXCwRfl1QIdAnazIK27pTOqaAHZbMAzvlt1EWyNbNFhGmrs79NwuiqaBzAuT5v71vRfl1EWyNbNFhGmrs79NwuiqaBzAuT0w7L3vlRAFJhDnraBzAuT0w71LZAzOwgQLHAzvB21AaU)7fiFF9tGaKjsAV)0IcMiFl2qK3tCWrCoGGsCyCh1O1xEDXSI8qlCoWeVkYlhDWDKxq0PknGse5EmjDWeXf5pKrbYirEdW9FVarUhtshmrCjdW9FVGbNFxRfl1QcXd0Go2qsXjZa1MxTxExKVfBiYli6uLgqjICpMKoyI4IA06lVMXSI8qlCoWeVkYlhDWDKxq0PknGse5EmjDWeXf5pKrbYirEMQn7AvXbTgGmrs79NwuiaTW5atTwSuB21QIdAnG(CkqEFpiaTW5atTmulRAna3)9cuH2aQkbcyltJQL2AVDxTSBTzSwAUwid)hFFWeK7r0fIGspCRj8l5JZhir(wSHiVGOtvAaLiY9ys6GjIlQrRVKDgZkYdTW5at8QiVC0b3rEbrNQ0akrK7XK0btexK)qgfiJe5zQwvCqRbitK0E)PffcqlCoWulRAvXbTgqFofiVVheGw4CGPwgQLvTgG7)EbQqBavLW3Vww1YuTgG7)EbpHqWkeGmrs79NwuWuRfl1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YQwdwdEcHGvi4B)D647gGulT1ERwgI8TydrEbrNQ0akrK7XK0btexuJwFzgmMvKhAHZbM4vrE5OdUJ8NlooSsW9CsCobPr(dzuGmsK3wqkqsccji00jcyltJQLsT3vlRAZUwdW9FVavOnGQs47xlRAZUwdW9FVaI(qn89RLvTC)3lyd2yYfj8l5(NXKmeqSrbdo)Uww1cnq8UO28QLDExTSQ1G1a57RFceiGTmnQwARnJrE49GJMAXgI8NlooSsW9CsCobPrnAn7VlMvKhAHZbM4vrE5OdUJ8UpHzGGstJgZG)OK380i)HmkqgjYBaU)7fOcTbuvcF)iFl2qK39jmdeuAA0yg8hL8MNg1O1S)wmRip0cNdmXRI8YrhCh5DFKsWFuYd7mqN8DFBXdI8hYOazKiVb4(VxGk0gqvj89J8TydrE3hPe8hL8Wod0jF33w8GOgTM9xgZkYdTW5at8QiVC0b3rEpNygrXeuYgmIZn4oYFiJcKrI8gG7)EbQqBavLW3pYdVhC0ul2qK3ZjMrumbLSbJ4CdUJA0A2Z(ywrEOfohyIxf5LJo4oY75eZikMGsCIXdI8hYOazKiVb4(VxGk0gqvj89J8W7bhn1Ine59CIzeftqjoX4brnAn7ZymRiVC0b3r(pcsJc2Oip0cNdmXRIAuJ8gSgZkA9TywrEOfohyIxf5X(rEeOrE5OdUJ8ufYiCoiYtvCFiY7tgmz0lseSk6G7AzvlYhCUKkepqrHN0j8lXCpubuT0wl7RLvTmvRbRbpHqWkeiGTmnQ28Q9GXodo)o4jecwHG5teDWDTwSuRpEq4gmjohaguT0wBoRLHipvHKAXgI8iMh)05IJdsEcHGviQrRVmMvKhAHZbM4vrESFKhbAKxo6G7ipvHmcNdI8uf3hI8(Kbtg9IebRIo4Uww1I8bNlPcXduu4jDc)sm3dvavlT1Y(Azvlt1AaU)7fq0hQHVFTwSult16JheUbtIZbGbvlT1MZAzvB21k3dKrHa6aTMWVeNdJnbOfohyQLHAziYtviPwSHipI5XpDU44Ge57RFce1O1SpMvKhAHZbM4vrESFKhbAKxo6G7ipvHmcNdI8uf3hI8gG7)EbQqBavLW3Vww1YuTgG7)Ebe9HA47xRfl1AlifijbHeeA6ebSLPr1sBT3vld1YQwdwdKVV(jqGa2Y0OAPT2lJ8ufsQfBiYJyE8tKVV(jquJwNXywrEOfohyIxf5pKrbYirEvCqRbitK0E)PffcqlCoWulRAZUwdW9FVGNqiyfcqMiP9(tlkyQLvTgSg8ecbRqW3(70X3naP28Ou7TAzv7bJDgC(DaYejT3FArHabSLPr1MxTxwlRAr(GZLuH4bkk8KoHFjM7HkGQLsT3QLvTezmjGk0Aqmguy6APT2RRww1AWAWtieScbcyltJQLMR9UqoRnVAvH4bAqhBiP4KzGiVC0b3rEpHqWke1O15mMvKhAHZbM4vr(dzuGmsKxfh0AaYejT3FArHa0cNdm1YQwMQ9GT5WjF80kQwAPu7XpzlzMq(qBQLvThm2zW53bitK0E)PffceWwMgvBE1ERww1AWAG891pbceWwMgvlnx7DHCwBE1QcXd0Go2qsXjZa1YqKxo6G7ip57RFce1O1xxmRip0cNdmXRI8pmj1qMA06BrE5OdUJ8(ySlrae(toquJwFnJzf5Hw4CGjEvK)qgfiJe5jWJai6cNdQLvThSnho5JNwrbd8MZO1slLAVvlB1Y(AP5AzQw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1EWyNbNFhOk9GOh((1YqTSQLPA9T)oD8DdqQnpk1ERwlwQLa2Y0OAZJsT6CyoPJnulRAr(GZLuH4bkk8KoHFjM7HkGQLwk1Y(AzRw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwgQLvTmvB21czIK27pTOGPwlwQLa2Y0OAZJsT6CyoPJnulnx7L1YQwKp4CjviEGIcpPt4xI5EOcOAPLsTSVw2QvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHAzvB21IqjU)7bMAzvlt1QcXd0Go2qsXjZa1YU1saBzAuTmulT1MXAzvlt1AlifijbHeeA6ebSLPr1sP27Q1ILAZUwDompTxTSQvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHiVC0b3rEpHqWke1O1SZywrEOfohyIxf5FysQHm1O13I8YrhCh59XyxIai8NCGOgTodgZkYdTW5at8QiVC0b3rEpHqWke5pKrbYir(SRLQqgHZbbeZJF6CXXbjpHqWkulRAjWJai6cNdQLvThSnho5JNwrbd8MZO1slLAVvlB1Y(AP5AzQw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1EWyNbNFhOk9GOh((1YqTSQLPA9T)oD8DdqQnpk1ERwlwQLa2Y0OAZJsT6CyoPJnulRAr(GZLuH4bkk8KoHFjM7HkGQLwk1Y(AzRw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwgQLvTmvB21czIK27pTOGPwlwQLa2Y0OAZJsT6CyoPJnulnx7L1YQwKp4CjviEGIcpPt4xI5EOcOAPLsTSVw2QvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHAzvB21IqjU)7bMAzvlt1QcXd0Go2qsXjZa1YU1saBzAuTmulT1E7YAzvlt1AlifijbHeeA6ebSLPr1sP27Q1ILAZUwDompTxTSQvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHi)5IJdsQq8affT(wuJwF7UywrEOfohyIxf5pKrbYirEKp4CjviEGIQLwk1EzTSQLa2Y0OAZR2lRLTAzQwKp4CjviEGIQLwk1MZAzOww1EW2C4KpEAfvlTuQnJrE5OdUJ8hYyJWDsbBFaPrnA9TBXSI8qlCoWeVkYFiJcKrI8zxlvHmcNdciMh)e57RFculRAzQ2d2MdN8XtROAPLsTzSww1sGhbq0fohuRfl1MDT6CyEAVAzvlt1QJnulT1E7UATyP2d2MdN8XtROAPLsTxwld1YqTSQLPA9T)oD8DdqQnpk1ERwlwQLa2Y0OAZJsT6CyoPJnulRAr(GZLuH4bkk8KoHFjM7HkGQLwk1Y(AzRw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwgQLvTmvB21czIK27pTOGPwlwQLa2Y0OAZJsT6CyoPJnulnx7L1YQwKp4CjviEGIcpPt4xI5EOcOAPLsTSVw2QvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLHAzvRkepqd6ydjfNmdul7wlbSLPr1sBTzmYlhDWDKN891pbIA06BxgZkYdTW5at8QiVC0b3rEY3x)eiYFiJcKrI8zxlvHmcNdciMh)05IJdsKVV(jqTSQn7APkKr4CqaX84NiFF9tGAzv7bBZHt(4PvuT0sP2mwlRAjWJai6cNdQLvTmvRV93PJVBasT5rP2B1AXsTeWwMgvBEuQvNdZjDSHAzvlYhCUKkepqrHN0j8lXCpubuT0sPw2xlB1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YqTSQLPAZUwitK0E)Pffm1AXsTeWwMgvBEuQvNdZjDSHAP5AVSww1I8bNlPcXduu4jDc)sm3dvavlTuQL91YwTY9azuiGOtWFdysO)7HpIo4oaTW5atTmulRAvH4bAqhBiP4KzGAz3AjGTmnQwARnJr(ZfhhKuH4bkkA9TOgT(g7Jzf5Hw4CGjEvK)qgfiJe5r(GZLuH4bkQwk1ERww1EW2C4KpEAfvlTuQLPAp(jBjZeYhAtTSBT3QLHAzvlbEearx4CqTSQn7AHmrs79NwuWulRAZUwdW9FVaI(qn89RLvT2csbssqibHMoraBzAuTuQ9UAzvB21k3dKrHGM)G0Kshsm3ZdcqlCoWulRAvH4bAqhBiP4KzGAz3AjGTmnQwARnJrE5OdUJ8hYyJWDsbBFaPrnA9TmgZkYlhDWDKhb(Obf5Hw4CGjEvuJAuJ8ubcAWD06lV7Y7UD3TlJ85lKEApuKNDinMgzDgG1xBAyT1MfDO2X2ht0AFysT5iGqqFauowlbYW)HaMAryBOw5RyBrbtTh6s7bOqX41AAO2lPH1E94MkquWuBoczIK27pTOGjWoMJ1Q4AZrdW9FVa7yaYejT3FArbtowlt3YKHqX41AAO2msdR96XnvGOGPw(X(6RfDrRsM1sdUwfx716l1AgQdAWDTyFGikMult5YqTmDzMmekglgzhsJPrwNby91MgwBTzrhQDS9XeT2hMuBoAGN8DAowlbYW)HaMAryBOw5RyBrbtTh6s7bOqX41AAOw2tdR96XnvGOGPw(X(6RfDrRsM1sdUwfx716l1AgQdAWDTyFGikMult5YqTmDltgcfJfJSdPX0iRZaS(AtdRT2SOd1o2(yIw7dtQnhpguowlbYW)HaMAryBOw5RyBrbtTh6s7bOqX41AAO2minS2Rh3ubIcMAZrLmnZGgyhdhm2zW535yTkU2C8GXodo)oWoMJ1Y0TmziumETMgQ9YCsdR96XnvGOGP2CeYejT3FArbtGDmhRvX1MJgG7)Eb2XaKjsAV)0IcMCSwMULjdHIXR10qTxYoPH1E94MkquWuBoczIK27pTOGjWoMJ1Q4AZrdW9FVa7yaYejT3FArbtowlt3YKHqXyXi7qAmnY6maRV20WARnl6qTJTpMO1(WKAZrdwZXAjqg(peWulcBd1kFfBlkyQ9qxApafkgVwtd1MrAyTxpUPcefm1MJqMiP9(tlkycSJ5yTkU2C0aC)3lWogGmrs79NwuWKJ1Y0TmziumwmMby7JjkyQ9AwRC0b316gKIcfJrEKpCIwFzoZGrEFc(noiYtt1sJribHMw0b31sJWEFOyKMQnhSJI5asT3yVv1E5DxExXyXinvBgkt48vWulh8WeO2d2Mt0A5aVPrHAPXNd4ROABCZU0fI977Qvo6GBuT42DrOyuo6GBuWNahSnNOueFF3fjF8GWDXOC0b3OGpboyBorzJsU2cHzWKEysYaIs3kFcCW2CIMqWb3geLCA18OqKXKaQqRbXyqHPP9wolgLJo4gf8jWbBZjkBuYfPG4u6fJYrhCJc(e4GT5eLnk5ICZbssBsM5aw5tGd2Mt0eco42GOCRyuo6GBuWNahSnNOSrj3pcsJc2w1InqrUhrxick9WTMWVKpoFGumkhDWnk4tGd2Mtu2OKR3xiMr6e(LK7bcwPB18OOIdAnazIK27pTOqaAHZbMIXIrAQ2muMW5RGPwGkqUOwDSHAv6qTYrXKAhuTcvzCcNdcfJYrhCJOW8CyUyKMQLgbifeNsV25vRpgHgohultnUwQFxdeHZb1cnypaQ2PR9GT5eLHIr5OdUrSrjxKcItPxmkhDWnInk5sviJW5aRAXgOanq8UirapOthSn30GXkQI7duGgiExeiGh0S5JheUbtIZbGbrZxtAWmDjnJ8bNlrxqkWqXOC0b3i2OKlvHmcNdSQfBGcAAphKuH4bQvuf3hOG8bNlPcXduu4jDc)sm3dvaL3LfJYrhCJyJsUhX5sYrhCNCdsTQfBGcsbXP0bJvZJcsbXP0btGG9(qXOC0b3i2OK7rCUKC0b3j3GuRAXgOCmiRMhfMYwfh0AWwqkqsccji00bOfohySyXG1GNqiyfc6CyEApgkgLJo4gXgLCpIZLKJo4o5gKAvl2afdwlgLJo4gXgLCrU5ajPnjZCaRMhfU)7fqU5ajPnjZCGabSLPr5PcXd0Go2qsXjZaS4(Vxa5MdKK2KmZbceWwMgLht3y7GT5WjF80kIbA(wGDwmkhDWnInk5EeNljhDWDYni1QwSbkMHahTyuo6GBeBuYvihPHKIjeOvRMhfObI3fbd8MZO0s5wozJQqgHZbbObI3fjc4bD6GT5MgmfJYrhCJyJsUc5inK8)oeumkhDWnInk56gp6kkLb6B8SHwlgLJo4gXgLC5eVe(LuYCygvmwmst1E9ySZGZVrfJYrhCJchdIYhbPrbBRAXgOi3JOlebLE4wt4xYhNpqSAEuYgPG4u6GjiohlBbPajjiKGqtNiGTmnIYDSy6GXodo)oqfAdOQeiGTmnkVCqmDWyNbNFhq0hQbcyltJOzid)hFFWeeeDQsdOerUhtshmrCmWqE3UJTB3rZqg(p((Gjii6uLgqjICpMKoyI4yLTb4(VxGk0gqvj89zLTb4(VxarFOg((fJYrhCJchdInk5EeNljhDWDYni1QwSbkacb9bqwnpkzJuqCkDWeeNJLbRbY3x)eiOZH5P9yzlifijbHeeA6ebSLPruURyKMQnd4vRymOAfcu733QAr94d1Q0HAXnuB(JsVwhoFaP1Mvw0aHAPbbb1MpDOR1CX0E1(eKcKAv6sx71FnQ1aV5mATysT5pkD8xRv6lQ96VgHIr5OdUrHJbXgLCTfcZGj9WKKbeLUvNlooiPcXdueLBwnpkezmjGk0Aqmgu47ZIjviEGg0XgskozgiVd2MdN8XtROGbEZzuA(wiNwSCW2C4KpEAffmWBoJslLJFYwYmH8H2WqXinvBgWR2gxRymOAZFCUAnduB(JsF6Av6qTnKPwl7VdzvTFeuBoWJgOwCxlhgHQn)rPJ)ATsFrTx)1iumkhDWnkCmi2OKRTqygmPhMKmGO0TAEuiYysavO1GymOW00Y(7yxImMeqfAnigdky(erhCZ6GT5WjF80kkyG3CgLwkh)KTKzc5dTPyuo6GBu4yqSrj3Nt8aNt0b3fJYrhCJchdInk5(CIh4CIo4oDCG0iWQ5rXaC)3l8CIh4CIo4oqaBzAuExAXIb4(Vx45epW5eDWDaPYHzAPKX7kgPPAZHqBavLADyV5iUAp42m6GBXHQLtqGPwCx75tiqR1I8HtXOC0b3OWXGyJsUufYiCoWQwSbkuH2aQkj0NtbY77bPdUnJo42kQI7duYwfh0Aa95uG8(EqaAHZbglwYwUhiJcbeDc(Batc9Fp8r0b3bOfohySyXG1GNqiyfc(2FNo(Ubi0EJftiFW5sQq8affEsNWVeZ9qfq5DDwSK9bJDgC(DGQ0dIE47ZqXOC0b3OWXGyJsUufYiCoWQwSbkuH2aQkPE8ORivCmdK0b3MrhCBfvX9bkzRIdAn0JhDfPIJzGeGw4CGXILSvXbTgGmrs79NwuiaTW5aJflhm2zW53bitK0E)PffceWwMgLxoz3lPzvCqRbda(ajHuIOIhyhGw4CGPyuo6GBu4yqSrjxQczeohyvl2afQczeohyvl2afQqBavL0d3A6GBZOdUTIQ4(aLSHm8F89btqUhrxick9WTMWVKpoFGyXICpqgfci6e83aMe6)E4JOdUdqlCoWyXIb4(VxGi3JjPdMiUKb4(VxWGZVTyrjtZmObbrNQ0akrK7XK0btex4GXodo)oqaBzAuE3UJfthm2zW53be9HAGa2Y0O8UzXIb4(VxarFOg((mumkhDWnkCmi2OKlvOnGQIvZJs2ifeNshmbc27dSmynq((6NabDompThRSna3)9cuH2aQkHVplQczeoheOcTbuvsOpNcK33dshCBgDWnlQczeoheOcTbuvs94rxrQ4ygiPdUnJo4MfvHmcNdcuH2aQkPhU10b3MrhCxmst1MdLEq0Rn)rPxBgktKxTSvR1JhDfPIJzGqdRnhqYCS)21E9xJAL2uBgktKxTeqmxu7dtQTHm1AV2xpnqXOC0b3OWXGyJsUuLEq0TAEuuXbTgGmrs79NwuiaTW5adlvCqRHE8ORivCmdKa0cNdmSoyBoCYhpTIOLYXpzlzMq(qByDWyNbNFhGmrs79NwuiqaBzAuE3kgPPAZHspi61M)O0R16XJUIuXXmqQLTATgxBgktKhnS2CajZX(Bx71FnQvAtT5qOnGQsTF)Az63oaHQ9JM2R2Ci(AWqXOC0b3OWXGyJsUuLEq0TAEuuXbTg6XJUIuXXmqcqlCoWWkBvCqRbitK0E)PffcqlCoWW6GT5WjF80kIwkh)KTKzc5dTHftgG7)EbQqBavLW33IfaHG(abQdAWDc)s(a5bhDWDaAHZbggkgPPA5bO2335Q9GTTHwRf31sxvFenm3C9gL(NlCW25sJeQqth7mk7M11Nlnc79HCZFyEYLgJqccnTOdUzxA814AXU0iabc5qpumkhDWnkCmi2OKlvHmcNdSQfBGccLOk9GONo42m6GBROkUpqrUhiJcbeDc(Batc9Fp8r0b3bOfohyyXuJ7ecL4(VhysQq8afrlLBwSG8bNlPcXduu4jDc)sm3dvarH9mWIjekX9FpWKuH4bkkjCyQqYxAdyphk3zXcYhCUKkepqrHN0j8lXCpubeTuUogkgLJo4gfogeBuY1hJDjcGWFYbS6HjPgYuPCZkitLijXg)BLsgZzXOC0b3OWXGyJsUuLEq0TAEuuXbTgqFofiVVheGw4CGHv2ifeNshmbc27dSoySZGZVdEcHGvi89zXevHmcNdciuIQ0dIE6GBZOdUTyjB5EGmkeq0j4Vbmj0)9WhrhChGw4CGHftgSg8ecbRqGapcGOlCoWIfdW9FVavOnGQs47ZYG1GNqiyfc(2FNo(Ubi5r5gdmW6GT5WjF80kkyG3CgLwkmX0n2UKML7bYOqarNG)gWKq)3dFeDWDaAHZbggOzKp4CjviEGIcpPt4xI5EOcigOnhugzrKXKaQqRbXyqHPP92LfJ0uT5qPhe9AZFu61Mdiifi1sJribnnnSwRX1IuqCk9AL2uBJRvo6qfQnhGgxl3)9SQwA03x)eO2gR1oDTe4rae9Ajs7bwvR5tM2R2Ci0gqvHTSUITRWAgQwM(TdqOA)OP9QnhIVgmumkhDWnkCmi2OKlvPheDRMhfMuXbTgSfKcKKGqccnDaAHZbglwi)gEyIheSfcZj8lP0HKTGuGKeesqOPdqg(p((GHbwzJuqCkDWeeNJLTGuGKeesqOPteWwMgLhL7yLTbRbY3x)eiqGhbq0fohWYG1GNqiyfceWwMgrl7zXKb4(VxGk0gqvj89zzaU)7fq0hQHVplMYgqiOpqGZHXMe(Lu6qcAW(IGTKbctSyXaC)3lW5Wytc)skDibnyFr47ZGflacb9bcuh0G7e(L8bYdo6G7a0cNdmmumst1Ytxm48TbNP2hMulpDc(BatT8)3dFeDWDXOC0b3OWXGyJsUi6IbNVn4mwnpkzJuqCkDWeeNJLCpqgfci6e83aMe6)E4JOdUdqlCoWWYG1GNqiyfce4raeDHZbSmyn4jecwHGV93PJVBasEuUX6GT5WjF80kkyG3CgLwk3kgPPAZqzIK27pTOqT5th6ABSwlsbXP0btTsBQLdR0RLg991pbQvAtTxBHqWkuRqGA)(1(WKAD42RwOXFp6HIr5OdUrHJbXgLCHmrs79NwuWQ5rjBKcItPdMab79bwmLTbRbpHqWkeiWJai6cNdyzWAG891pbceWwMgrBgzlJ08XpzlzMq(qBSyXG1a57RFceiGTmnIMVlKtAvH4bAqhBiP4KzagyPcXd0Go2qsXjZa0MXIr5OdUrHJbXgLCr0hQwnpkoGk4OLsozNSmynq((6NabDompThlMYgYW)X3hmb5EeDHiO0d3Ac)s(48bIflhm2zW53bQqBavLabSLPr0E7ogkgLJo4gfogeBuY1hRdUTAEu4(VxGZHXg3hPbcih1IfdW9FVavOnGQs47xmkhDWnkCmi2OKlNdJnP3NCHvZJIb4(VxGk0gqvj89lgLJo4gfogeBuYLdiiGW80EwnpkgG7)EbQqBavLW3Vyuo6GBu4yqSrj33qaohgBSAEuma3)9cuH2aQkHVFXOC0b3OWXGyJsUsFaKsex6ioNvZJIb4(VxGk0gqvj89lgLJo4gfogeBuY9JG0OGTvTydu8ehCeNdiOehg3wnpkmzaU)7fOcTbuvcFFlwykBvCqRbitK0E)PffcqlCoWW6GXodo)oqfAdOQeiGTmnI2mMtlwuXbTgGmrs79NwuiaTW5adlMoySZGZVdqMiP9(tlkeiGTmnkVRZILdg7m487aKjsAV)0IcbcyltJO9Y7y9gp6AIa2Y0iAVUCYadmWkBitK0E)PffmbY3x)eOyuo6GBu4yqSrj3pcsJc2w1Inqrq0PknGse5EmjDWeXz18OyaU)7fiY9ys6GjIlzaU)7fm48BlwuH4bAqhBiP4KzG8U8UIr5OdUrHJbXgLC)iinkyBvl2afbrNQ0akrK7XK0bteNvZJctzRIdAnazIK27pTOqaAHZbglwYwfh0Aa95uG8(EqaAHZbggyzaU)7fOcTbuvceWwMgr7T7y3msZqg(p((Gji3JOlebLE4wt4xYhNpqkgLJo4gfogeBuY9JG0OGTvTydueeDQsdOerUhtshmrCwnpkmPIdAnazIK27pTOqaAHZbgwQ4GwdOpNcK33dcqlCoWWaldW9FVavOnGQs47ZIjitK0E)PffmbpHqWkyXICpqgfci6e83aMe6)E4JOdUdqlCoWWYG1GNqiyfc(2FNo(Ubi0EJHIr5OdUrHJbXgLC)iinkyBf8EWrtTyduoxCCyLG75K4CcsTAEuSfKcKKGqccnDIa2Y0ik3XkBdW9FVavOnGQs47ZkBdW9FVaI(qn89zX9FVGnyJjxKWVK7FgtYqaXgfm48BwqdeVlYJDEhldwdKVV(jqGa2Y0iAZyXOC0b3OWXGyJsUFeKgfSTQfBGI7tygiO00OXm4pk5np1Q5rXaC)3lqfAdOQe((fJYrhCJchdInk5(rqAuW2QwSbkUpsj4pk5HDgOt(UVT4bwnpkgG7)EbQqBavLW3Vyuo6GBu4yqSrj3pcsJc2wbVhC0ul2afpNygrXeuYgmIZn42Q5rXaC)3lqfAdOQe((fJYrhCJchdInk5(rqAuW2k49GJMAXgO45eZikMGsCIXdSAEuma3)9cuH2aQkHVFXinvlna8KVtR9johNCyU2hMu7hjCoO2rbBenSwAqqqT4U2dg7m487qXOC0b3OWXGyJsUFeKgfSrfJfJ0uT0adboATgXw8GAfUXn6aOIrAQ2mutfASDTIwBgzRwMYjB1M)O0RLgGNHAV(RrO2maBBWmIcUlQf31EjB1QcXduKv1M)O0RnhcTbuvSQwmP28hLETzDvo41Iv6aj)bb1MVmATpmPwe2gQfAG4DrOwASdHRnFz0ANxTzOmrE1EW2C4AhuThS90E1(9dfJYrhCJcMHahLc0uHgBB18OW0bBZHt(4PveTuYiBQ4Gwdga8bscPerfpWoaTW5aJflhSnho5JNwruKESLdDH4bM0XNbwmzaU)7fOcTbuvcFFlwma3)9ci6d1W33IfObI3fbd8MZO5r5YCYgvHmcNdcqdeVlseWd60bBZnnySyjBQczeoheqt75GKkepqzGftzRIdAnazIK27pTOqaAHZbglwoySZGZVdqMiP9(tlkeiGTmnI2lzOyuo6GBuWme4OSrjxQczeohyvl2aLpcsVX5aIvuf3hOCW2C4KpEAffmWBoJs7nlwGgiExemWBoJMhLlZjBufYiCoianq8UirapOthSn30GXILSPkKr4CqanTNdsQq8aTyuo6GBuWme4OSrjxeqiIcMehUHeYFygS6CXXbjviEGIOCZQ5rjBdwdiGqefmjoCdjK)Wme05W80EwSqviJW5GWhbP34CaHftYrhQqcAWEaeLBSiYysavO1GymOW00((oxIah6cXds6ydwSCOlepar7LSuH4bAqhBiP4KzG8YjdfJ0uTSdhLETzOdD80E1ELtmaYQAZalDT4xTSd6HkGQv0AVKTAvH4bkYQAXKAzp7Mr2QvfIhOOAZNo01MdH2aQk1oOA)(fJYrhCJcMHahLnk5(KoHFjM7HkGSAEuOkKr4Cq4JG0BCoGWsUhiJcb4qhpTxIZjgafGw4CGHfYhCUKkepqrHN0j8lXCpubeTuUKnMma3)9cuH2aQkHVpnZ0n2ysUhiJcb4qhpTxIZjgafisZmLBmWadfJ0uTzGLUw8Rw2b9qfq1kAT3YGSvlsLdZOAXVAPbDmgOR9kNyauTysTINmnsRnJSvlt5KTAZFu61sdG)CoOwAamcyOwviEGIcfJYrhCJcMHahLnk5(KoHFjM7HkGSAEuOkKr4Cq4JG0BCoGWIjU)7fOpgd0joNyauaPYHzAPCldAXctz7tgmz0lseSk6GBwiFW5sQq8affEsNWVeZ9qfq0sjJSXKCpqgfcg8NZbjdgbbI0mt7LmWgsbXP0btGG9(admumst1Mbw6AXVAzh0dvavRIRv89Dxulnaig3f1EnWdc31oVANwo6qfQf31k9f1QcXd0AfTw2xRkepqrHIr5OdUrbZqGJYgLCFsNWVeZ9qfqwDU44GKkepqruUz18OqviJW5GWhbP34CaHfYhCUKkepqrHN0j8lXCpubeTuyFXOC0b3OGziWrzJsUWHoEAVeb8jJT0gRMhfQczeohe(ii9gNdifJYrhCJcMHahLnk5k2CFeDRMhfQczeohe(ii9gNdifJ0uTzjCSBoWxhNOqTkUwX33DrT0aGyCxu71apiCxRO1EzTQq8afvmkhDWnkygcCu2OKR9xhNOGvNlooiPcXdueLBwnpkufYiCoi8rq6nohqyH8bNlPcXduu4jDc)sm3dvar5YIr5OdUrbZqGJYgLCT)64efSAEuOkKr4Cq4JG0BCoGumwmst1sdi2IhulMkqQvhBOwHBCJoaQyKMQ9An2Jw71wieScOAXDTnUzxFYyteYf1QcXduuTpmPwLouRpzWKrVOwcwfDWDTZR2CYwTCoamOAfcuR4iGyUO2VFXOC0b3OGbRuOkKr4CGvTyduqmp(PZfhhK8ecbRGvuf3hO4tgmz0lseSk6GBwiFW5sQq8affEsNWVeZ9qfq0YEwmzWAWtieScbcyltJY7GXodo)o4jecwHG5teDWTfl(4bHBWK4Cayq0MtgkgPPAVwJ9O1sJ((6NaOAXDTnUzxFYyteYf1QcXduuTpmPwLouRpzWKrVOwcwfDWDTZR2CYwTCoamOAfcuR4iGyUO2VFXOC0b3OGbRSrjxQczeohyvl2afeZJF6CXXbjY3x)eWkQI7du8jdMm6fjcwfDWnlKp4CjviEGIcpPt4xI5EOciAzplMma3)9ci6d1W33IfM8Xdc3GjX5aWGOnNSYwUhiJcb0bAnHFjohgBcqlCoWWadfJ0uTxRXE0APrFF9tauTZR2Ci0gqvHnE6d1CZbeKcKAPXiKGqtx7GQ97xR0MAZhQLUqfQ9s2QfbhCBq16GNwlURvPd1sJ((6Na1sdGZQyuo6GBuWGv2OKlvHmcNdSQfBGcI5Xpr((6NawrvCFGIb4(VxGk0gqvj89zXKb4(VxarFOg((wSylifijbHeeA6ebSLPr0EhdSmynq((6NabcyltJO9YIrAQwEF4mIR2RTqiyfQvAtT0OVV(jqTiq)(16tgmPwfxBgktK0E)PffQ9iiTyuo6GBuWGv2OKRNqiyfSAEuuXbTgGmrs79NwuiaTW5adRSHmrs79NwuWe8ecbRaldwdEcHGvi4B)D647gGKhLBSoySZGZVdqMiP9(tlkeiGTmnkVlzH8bNlPcXduu4jDc)sm3dvar5glImMeqfAnigdkmnTxhldwdEcHGviqaBzAenFxiN5PcXd0Go2qsXjZafJYrhCJcgSYgLCjFF9taRMhfvCqRbitK0E)PffcqlCoWWIPd2MdN8XtRiAPC8t2sMjKp0gwhm2zW53bitK0E)PffceWwMgL3nwgSgiFF9tGabSLPr08DHCMNkepqd6ydjfNmdWqXinv71wieSc1(9zgaFRQvCiCTkzauTkU2pcQD0AfuTsTiF4mIRwpObIOysTpmPwLouRtqATx)1Owo4HjqTsTVPheDGumkhDWnkyWkBuY1hJDjcGWFYbS6HjPgYuPCRyuo6GBuWGv2OKRNqiyfSAEuiWJai6cNdyDW2C4KpEAffmWBoJslLBSXEAMj5EGmkeq0j4Vbmj0)9WhrhChGw4CGH1bJDgC(DGQ0dIE47ZalM8T)oD8DdqYJYnlwiGTmnkpk6CyoPJnWc5doxsfIhOOWt6e(LyUhQaIwkSNn5EGmkeq0j4Vbmj0)9WhrhChGw4CGHbwmLnKjsAV)0IcglwiGTmnkpk6CyoPJnqZxYc5doxsfIhOOWt6e(LyUhQaIwkSNn5EGmkeq0j4Vbmj0)9WhrhChGw4CGHbwzJqjU)7bgwmPcXd0Go2qsXjZaSlbSLPrmqBgzXKTGuGKeesqOPteWwMgr5olwYwNdZt7XsUhiJcbeDc(Batc9Fp8r0b3bOfohyyOyuo6GBuWGv2OKRpg7seaH)Kdy1dtsnKPs5wXOC0b3OGbRSrjxpHqWky15IJdsQq8afr5MvZJs2ufYiCoiGyE8tNlooi5jecwbwe4raeDHZbSoyBoCYhpTIcg4nNrPLYn2ypnZKCpqgfci6e83aMe6)E4JOdUdqlCoWW6GXodo)oqv6brp89zGft(2FNo(Ubi5r5MfleWwMgLhfDomN0XgyH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWalMYgYejT3FArbJfleWwMgLhfDomN0XgO5lzH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWaRSrOe3)9adlMuH4bAqhBiP4Kza2La2Y0igO92LSyYwqkqsccji00jcyltJOCNflzRZH5P9yj3dKrHaIob)nGjH(Vh(i6G7a0cNdmmumst1E9KXgH7AZcS9bKwlUR1(70X3b1QcXduuTIwBgzR2R)AuB(0HUwYV7P9Qf)1ANU2lr1Y03VwfxBgRvfIhOigQftQL9OAzkNSvRkepqrmumkhDWnkyWkBuY9qgBeUtky7di1Q5rb5doxsfIhOiAPCjlcyltJY7s2yc5doxsfIhOiAPKtgyDW2C4KpEAfrlLmwmst1Yoaa)A)(1sJ((6Na1kATzKTAXDTIZvRkepqr1Yu(0HUw3qDAVAD42RwOXFp61kTP2gR1IAXhrhRmumkhDWnkyWkBuYL891pbSAEuYMQqgHZbbeZJFI891pbyX0bBZHt(4PveTuYilc8iaIUW5alwYwNdZt7XIjDSbAVDNflhSnho5JNwr0s5sgyGft(2FNo(Ubi5r5MfleWwMgLhfDomN0XgyH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWalMYgYejT3FArbJfleWwMgLhfDomN0XgO5lzH8bNlPcXduu4jDc)sm3dvarlf2ZMCpqgfci6e83aMe6)E4JOdUdqlCoWWalviEGg0XgskozgGDjGTmnI2mwmkhDWnkyWkBuYL891pbS6CXXbjviEGIOCZQ5rjBQczeoheqmp(PZfhhKiFF9tawztviJW5GaI5Xpr((6NaSoyBoCYhpTIOLsgzrGhbq0fohWIjF7VthF3aK8OCZIfcyltJYJIohMt6ydSq(GZLuH4bkk8KoHFjM7HkGOLc7ztUhiJcbeDc(Batc9Fp8r0b3bOfohyyGftzdzIK27pTOGXIfcyltJYJIohMt6yd08LSq(GZLuH4bkk8KoHFjM7HkGOLc7ztUhiJcbeDc(Batc9Fp8r0b3bOfohyyGLkepqd6ydjfNmdWUeWwMgrBglgPPAVEYyJWDTzb2(asRf31YNvTZR2PR1xAdypNAL2u7O1M)4C1AW16aeQwJylEqTkDPRnd1uHgBxR5d1Q4AZ6QCZbOX5MLYoOyuo6GBuWGv2OK7Hm2iCNuW2hqQvZJcYhCUKkepqruUX6GT5WjF80kIwkmD8t2sMjKp0g29gdSiWJai6cNdyLnKjsAV)0IcgwzBaU)7fq0hQHVplBbPajjiKGqtNiGTmnIYDSYwUhiJcbn)bPjLoKyUNheGw4CGHLkepqd6ydjfNmdWUeWwMgrBglgLJo4gfmyLnk5IaF0GkglgPPAZqie0havmkhDWnkaie0har5G7d0kruWKEoXgSAEuGgiExe0Xgskozlzs7nwzBaU)7fOcTbuvcFFwmLTbRHdUpqRerbt65eBiX9jDqNdZt7XkB5OdUdhCFGwjIcM0Zj2qy60ZnE0vlwEFNlrGdDH4bjDSH88oMGTKjdfJ0uT0yx(YfOA)iO2RCySP28hLET5qOnGQsTF)qT0GIDMAFysTzOmrs79NwuiulniiO28hLETzDvTF)A5GhMa1k1(MEq0bsTcQwhU9Qvq1oATKFJQ9Hj1E7ouTMpzAVAZHqBavLqXOC0b3OaGqqFaeBuYLZHXMe(Lu6qcAW(cRMhfdW9FVavOnGQs47ZIjitK0E)PffmbpHqWkyXIb4(VxarFOg((SoyBoCYhpTIcg4nNrZJYnlwma3)9cuH2aQkbcyltJYJYT7yWIL34rxteWwMgLhLB3vmst1sJvfS91AvCTIB86AV2FHygPRn)rPxBoeAdOQuRGQ1HBVAfuTJwB(4oh1Aja670ANUwhgnTxTsTVVZXUuf3hQ9iiTwmvGuRshQLa2Y0t7vR5teDWDT4xTkDO234rxlgLJo4gfaec6dGyJsUEFHygPt4xsUhiyLUvZJYbJDgC(DGk0gqvjqaBzAuES3IfdW9FVavOnGQs47BXYB8ORjcyltJYJ93vmkhDWnkaie0haXgLC9(cXmsNWVKCpqWkDRMhLNdJjmX0B8ORjcyltJyx2Fhd0GpySZGZVzG2NdJjmX0B8ORjcyltJyx2Fh7EWyNbNFhOcTbuvceWwMgXan4dg7m48BgkgLJo4gfaec6dGyJsUp85JatsUhiJcjoqSTAEuq(GZLuH4bkk8KoHFjM7HkGOLYLwSqKXKaQqRbXyqHPP96UJf0aX7I8UM3vmkhDWnkaie0haXgLC9)K5DX0EjoNGuRMhfKp4CjviEGIcpPt4xI5EOciAPCPflezmjGk0AqmguyAAVU7kgLJo4gfaec6dGyJsUkDi9Bo8VnPhMCaRMhfU)7fiWHzhGqPhMCGW33IfU)7fiWHzhGqPhMCG0b)BfibKkhMZ72DfJYrhCJcacb9bqSrjxY477G00jKVCGIr5OdUrbaHG(ai2OKB(yIZqfMoraeUL(afJYrhCJcacb9bqSrjxBWgtUiHFj3)mMKHaInYQ5rbAG4DrE58owzFWyNbNFhOcTbuvcF)IrAQwAqXotT0iq8N2R2mWoXgq1(WKAHmHZxHAjs7b1Ij1Y84C1Y9FpKv1oVA9Xi0W5GqT0yx(YfOAvYf1Q4A9aTwLouRdNpG0ApySZGZVRLtqGPwCxRqvgNW5GAHgShafkgLJo4gfaec6dGyJsUeq8N2l9CInGS6CXXbjviEGIOCZQ5rrfIhObDSHKItMbY7wiNwSWetQq8anqheNsp4FuAzN3zXIkepqd0bXP0d(hnpkxEhdSyso6qfsqd2dGOCZIfviEGg0XgskozgG2lZGmWGflmPcXd0Go2qsXj)JMU8oAz)DSyso6qfsqd2dGOCZIfviEGg0XgskozgG2mMrgyOySyKMQLxbXP0btT04Jo4gvmst1A94rhPIJzGulUR9ww0WA5BXhrhR1sJ((6NafJYrhCJcifeNshmuiFF9taRMhfvCqRHE8ORivCmdKa0cNdmSoyBoCYhpTIOLsgzPcXd0Go2qsXjZaSlbSLPr0EDfJ0uT8FofiVVhulB1YtNG)gWul))9WhrhCtdRnd1OpbQnFO2pcQf3qTEomN4QvX1k((UlQ9AlecwHAvCTkDOwBz6AvH4bATZR2rRDq12yTwul(i6yT2la1QAr4AfNRwSshi1AltxRkepqRv4g3OdGQ1NGFJgkgLJo4gfqkioLoyyJsU(ySlrae(toGvpmj1qMkLBfJYrhCJcifeNshmSrjxpHqWky18Oi3dKrHaIob)nGjH(Vh(i6G7a0cNdmS4(Vxa95uG8(Eq47ZI7)Eb0NtbY77bbcyltJY7wG9SYgHsC)3dmfJ0uT8FofiVVhqdRLg777UOwmPwAe8iaIET5pk9A5(VhyQ9AlecwbuXOC0b3OasbXP0bdBuY1hJDjcGWFYbS6HjPgYuPCRyuo6GBuaPG4u6GHnk56jecwbRoxCCqsfIhOik3SAEuuXbTgqFofiVVheGw4CGHfteWwMgL3TlTyX3(70X3najpk3yGLkepqd6ydjfNmdWUeWwMgr7LfJ0uT8FofiVVhulB1YtNG)gWul))9WhrhCx701YNfnSwASVV7IAbH4UOwA03x)eOwLUO1M)4C1Yb1sGhbq0btTpmPwFPnG9CkgLJo4gfqkioLoyyJsUKVV(jGvZJIkoO1a6ZPa599Ga0cNdmSK7bYOqarNG)gWKq)3dFeDWDaAHZbgwzBWAG891pbc6CyEApwufYiCoiGM2ZbjviEGwmst1Y)5uG8(EqT5NBT80j4Vbm1Y)Fp8r0b30WAPrG477UO2hMulhU)OAV(RrTsBYftQfYuH2aMArT4JOJ1AnFIOdUdfJYrhCJcifeNshmSrjxFm2Liac)jhWQhMKAitLYTIr5OdUrbKcItPdg2OKRNqiyfS6CXXbjviEGIOCZQ5rrfh0Aa95uG8(EqaAHZbgwY9azuiGOtWFdysO)7HpIo4oaTW5adlMKJouHe0G9aiAVzXs2Q4GwdqMiP9(tlkeGw4CGHbwQq8anOJnKuCYmaTeWwMgXIjcyltJY7g70ILSrOe3)9addfJ0uT8FofiVVhulB1MHYe5vlUR9ww0WAPrWJai61ETfcbRqTIwRshQfAtT4xTifeNsVwfxRhO1AlzwR5teDWDTCWdtGAZqzIK27pTOqXOC0b3OasbXP0bdBuY1hJDjcGWFYbS6HjPgYuPCRyuo6GBuaPG4u6GHnk56jecwbRMhfvCqRb0NtbY77bbOfohyyPIdAnazIK27pTOqaAHZbgwYrhQqcAWEaeLBS4(Vxa95uG8(EqGa2Y0O8UfyFuJAmc]] )

end