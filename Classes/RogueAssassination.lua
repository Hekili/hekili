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
            id = PTR and 345569 or nil,
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


    spec:RegisterPack( "Assassination", 20201103, [[devXgcqirPEesHUesrKnHs(KOcgfkYPqHwfsr9kuuZIsYTqPs7sWVev1WuPYXuPSmvcpdLQMMOKUMOI2Mkj6BQKeJdLkCorfY6ujPEhkvu18ev5EiX(qk9prjIoisrAHQK6HifyIifHlkkH2OOeKpQssAKOurLtkkbwjk4LifrntvsOBkkrANusnurfQLIuqpfvnvrrxvucQTQsc(kkvuglkvK9k0FfzWkDyIfJkpwftMIld2SQ8zQQrJuDAfRwuIWRrPmBQCBk1UL63qnCQYXfLOwoINdz6KUUQA7iPVlQ04ffoVkrRxLQMpLy)soElMzK3ikeT(I7U4UB3UJ9HlyFoVs2N1iVEPhe59KdBIpe5BXgI80uesqOPfDWDK3tU0HftmZipc)jhiYtxvp0vNF((Js)Zfoy78rJ93j6G7drEA(OX(KFKN7ponlOJCrEJOq06lU7I7UD7o2hUG958kVGDe5LVshtI88JnniYtFmgOJCrEdGorEASwAkcji00Io4UwAi2)dfd0yTwJPc2CaPw2BvTxC3f3f5DdsrXmJ8ifeNshmXmJwFlMzKhAHZbM41r(dzuGmsKxfh0AOhF6ksfhBajaTW5atTSQ9GT5Wjp80kQwAPuBwRLvTQq8bnOJnKuCYmqTSBTeWwMgvlT1ELrE5OdUJ8KVN(jquJwFrmZip0cNdmXRJ8pmj1qgA06BrE5OdUJ8EySlrae(toquJwZ(yMrEOfohyIxh5pKrbYirE5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1Y9FVa6ZPa599HW3Rww1Y9FVa6ZPa599HabSLPr1MxT3cSVww1MDTiuI7)EGjYlhDWDK3xieScrnADwJzg5Hw4CGjEDK)HjPgYqJwFlYlhDWDK3dJDjcGWFYbIA06CgZmYdTW5at86iVC0b3rEFHqWke5pKrbYirEvCqRb0NtbY77dbOfohyQLvTmvlbSLPr1MxT3UOwlwQ1Z(70XZnaP28Ou7TAzSww1QcXh0Go2qsXjZa1YU1saBzAuT0w7fr(ZLhhKuH4dkkA9TOgT(kJzg5Hw4CGjEDK)qgfiJe5vXbTgqFofiVVpeGw4CGPww1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YQ2SR1G1a57PFce05W20(1YQwQczeoheqt77GKkeFqJ8YrhCh5jFp9tGOgT(QeZmYdTW5at86i)dtsnKHgT(wKxo6G7iVhg7seaH)Kde1O1SJyMrEOfohyIxh5LJo4oY7lecwHi)HmkqgjYRIdAnG(CkqEFFiaTW5atTSQvUhiJcbeDc(Batc9Fp8r0b3bOfohyQLvTmvRC0HkKGgShavlT1ERwlwQn7AvXbTgGmqs7)NwuiaTW5atTmwlRAvH4dAqhBiP4KzGAPTwcyltJQLvTmvlbSLPr1MxT3yh1AXsTzxlcL4(VhyQLXi)5YJdsQq8bffT(wuJwNJIzg5Hw4CGjEDK)HjPgYqJwFlYlhDWDK3dJDjcGWFYbIA06B3fZmYdTW5at86i)HmkqgjYRIdAnG(CkqEFFiaTW5atTSQvfh0AaYajT)FArHa0cNdm1YQw5OdvibnypaQwk1ERww1Y9FVa6ZPa599HabSLPr1MxT3cSpYlhDWDK3xieScrnQrEaHG(aOyMrRVfZmYdTW5at86i)HmkqgjYdnq8VmOJnKuCYwYOwAR9wTSQn7Ana3)9cuH2aQkHVxTSQLPAZUwdwdhCFGwjIcM0Zj2qI7t6Goh2M2Vww1MDTYrhCho4(aTsefmPNtSHW0PNB8PR1AXsTVVZLiWHUq8HKo2qT5vR)XeSLmQLXiVC0b3r(dUpqRerbt65eBiQrRViMzKhAHZbM41r(dzuGmsK3aC)3lqfAdOQe(E1YQwMQ1aC)3l4lecwHaKbsA))0IcMATyPwdW9FVaI(qn89QLvThSnho5HNwrbd8MZO1MhLAVvRfl1AaU)7fOcTbuvceWwMgvBEuQ92D1YyTwSu7B8PRjcyltJQnpk1E7UiVC0b3rEohgBs4xsPdjOb7lJA0A2hZmYdTW5at86i)HmkqgjYFWyNbNBhOcTbuvceWwMgvBE1Y(ATyPwdW9FVavOnGQs47vRfl1(gF6AIa2Y0OAZRw2FxKxo6G7iV)xiMr6e(LK7bcwPh1O1znMzKhAHZbM41r(dzuGmsK)5WysTmvlt1(gF6AIa2Y0OAz3Az)D1YyT5xRC0b3Pdg7m4C7AzSwAR95WysTmvlt1(gF6AIa2Y0OAz3Az)D1YU1EWyNbNBhOcTbuvceWwMgvlJ1MFTYrhCNoySZGZTRLXiVC0b3rE)VqmJ0j8lj3deSspQrRZzmZip0cNdmXRJ8hYOazKipYdCUKkeFqrHN0j8lXwpubuT0sP2lQ1ILAjYysavO1GymOW01sBTx5D1YQwObI)L1MxTxL7I8YrhCh5F4ZhbMKCpqgfsCGyh1O1xzmZip0cNdmXRJ8hYOazKipYdCUKkeFqrHN0j8lXwpubuT0sP2lQ1ILAjYysavO1GymOW01sBTx5DrE5OdUJ8EFY8UCA)eNtqAuJwFvIzg5Hw4CGjEDK)qgfiJe55(VxGah2CacLEyYbcFVATyPwU)7fiWHnhGqPhMCG0b)BfibKkh2QnVAVDxKxo6G7iVshs)Md)Bt6HjhiQrRzhXmJ8YrhCh5jJNNdstNqEYbI8qlCoWeVoQrRZrXmJ8YrhCh5ZftCgQW0jcGWT0hiYdTW5at86OgT(2DXmJ8qlCoWeVoYFiJcKrI8qde)lRnVAZ5D1YQ2SR9GXodo3oqfAdOQe(ErE5OdUJ82GnMCzc)sU)zmjdbeBuuJwF7wmZip0cNdmXRJ8YrhCh5jG4nTF65eBaf5pKrbYirEvi(Gg0XgskozgO28Q9wiN1AXsTmvlt1QcXh0aDqCk9G3rRL2Azh3vRfl1QcXh0aDqCk9G3rRnpk1EXD1YyTSQLPALJouHe0G9aOAPu7TATyPwvi(Gg0XgskozgOwAR9ICuTmwlJ1AXsTmvRkeFqd6ydjfN8oA6I7QL2Az)D1YQwMQvo6qfsqd2dGQLsT3Q1ILAvH4dAqhBiP4KzGAPT2SM1AzSwgJ8NlpoiPcXhuu06BrnQrEd8KVtJzgT(wmZiVC0b3rE2MdBrEOfohyIxh1O1xeZmYlhDWDKhPG4u6rEOfohyIxh1O1SpMzKhAHZbM41rESxKhbAKxo6G7ipvHmcNdI8uf3hI8qde)ldeWh6AzUwp8GWnysCoamOAP5AVk1MFTmv7f1sZ1I8aNlrxqkulJrEQcj1Ine5Hgi(xMiGp0Pd2MBAWe1O1znMzKhAHZbM41rESxKhbAKxo6G7ipvHmcNdI8uf3hI8ipW5sQq8bffEsNWVeB9qfq1MxTxe5PkKul2qKhnTVdsQq8bnQrRZzmZip0cNdmXRJ8hYOazKipsbXP0btGG9)qKxo6G7i)rCUKC0b3j3G0iVBqAQfBiYJuqCkDWe1O1xzmZip0cNdmXRJ8hYOazKipt1MDTQ4Gwd2csbssqibHMoaTW5atTwSuRbRbFHqWke05W20(1YyKxo6G7i)rCUKC0b3j3G0iVBqAQfBiYFmOOgT(QeZmYdTW5at86iVC0b3r(J4Cj5OdUtUbPrE3G0ul2qK3G1OgTMDeZmYdTW5at86i)HmkqgjYZ9FVaYnhijTjzMdeiGTmnQ28QvfIpObDSHKItMbQLvTC)3lGCZbssBsM5abcyltJQnVAzQ2B1YCThSnho5HNwr1YyT0CT3cSJiVC0b3rEKBoqsAtYmhiQrRZrXmJ8qlCoWeVoYlhDWDK)ioxso6G7KBqAK3nin1Ine5ndboAuJwF7UyMrEOfohyIxh5pKrbYirEObI)Lbd8MZO1slLAVLZAzUwQczeoheGgi(xMiGp0Pd2MBAWe5LJo4oYlKJ0qsXec0AuJwF7wmZiVC0b3rEHCKgsEFhcI8qlCoWeVoQrRVDrmZiVC0b3rE34txrPSeFJVn0AKhAHZbM41rnA9n2hZmYlhDWDKNt8t4xsjZHnuKhAHZbM41rnQrEpcCW2CIgZmA9TyMrE5OdUJ8INN7YKhEq4oYdTW5at86OgT(IyMrEOfohyIxh5LJo4oYBle2at6Hjjdik9i)HmkqgjYtKXKaQqRbXyqHPRL2AVLZiVhboyBorti4GBdkYNZOgTM9XmJ8YrhCh5rkioLEKhAHZbM41rnADwJzg5Hw4CGjEDKxo6G7ipYnhijTjzMde5pKrbYirEc8iaIUW5GiVhboyBorti4GBdkYFlQrRZzmZip0cNdmXRJ8TydrE5EeDHiO0d3Ac)sE4CbsKxo6G7iVCpIUqeu6HBnHFjpCUajQrRVYyMrEOfohyIxh5pKrbYirEvCqRbidK0()PffcqlCoWe5LJo4oY7)fIzKoHFj5EGGv6rnQrEZqGJgZmA9TyMrEOfohyIxh5pKrbYirEMQ9GT5Wjp80kQwAPuBwRL5AvXbTgma4bKesjIk(GDaAHZbMATyP2d2MdN8WtROAPuR0JTCOleFWKoE1YyTSQLPAna3)9cuH2aQkHVxTwSuRb4(VxarFOg(E1AXsTqde)ldg4nNrRnpk1EroRL5APkKr4CqaAG4FzIa(qNoyBUPbtTwSuB21sviJW5GaAAFhKuH4dATmwlRAzQ2SRvfh0AaYajT)FArHa0cNdm1AXsThm2zW52bidK0()PffceWwMgvlT1ErTmg5LJo4oYdnvOX2rnA9fXmJ8qlCoWeVoYJ9I8iqJ8YrhCh5PkKr4CqKNQ4(qK)GT5Wjp80kkyG3CgTwAR9wTwSul0aX)YGbEZz0AZJsTxKZAzUwQczeoheGgi(xMiGp0Pd2MBAWuRfl1MDTufYiCoiGM23bjvi(Gg5PkKul2qK)JG0BCoGe1O1SpMzKhAHZbM41rE5OdUJ8iGqefmjoCdjK3Wge5pKrbYir(SR1G1acierbtId3qc5nSbbDoSnTFTwSulvHmcNdcFeKEJZbKAzvlt1khDOcjOb7bq1sP2B1YQwImMeqfAnigdkmDT0w777CjcCOleFiPJnuRfl1EOleFavlT1ErTSQvfIpObDSHKItMbQnVAZzTmg5pxECqsfIpOOO13IA06SgZmYdTW5at86i)HmkqgjYtviJW5GWhbP34CaPww1k3dKrHaCOJN2pX5edGcqlCoWulRArEGZLuH4dkk8KoHFj26HkGQLwk1ErTmxlt1AaU)7fOcTbuvcFVAP5AzQ2B1YCTmvRCpqgfcWHoEA)eNtmakqKMTAPu7TAzSwgRLXiVC0b3r(N0j8lXwpubuuJwNZyMrEOfohyIxh5pKrbYirEQczeohe(ii9gNdi1YQwMQL7)Eb6JXaDIZjgafqQCyRwAPu7TCuTwSult1MDTEKbtg9YebRIo4Uww1I8aNlPcXhuu4jDc)sS1dvavlTuQnR1YCTmvRCpqgfcg8NZbjdgbbI0SvlT1ErTmwlZ1IuqCkDWeiy)pulJ1YyKxo6G7i)t6e(LyRhQakQrRVYyMrEOfohyIxh5LJo4oY)KoHFj26HkGI8hYOazKipvHmcNdcFeKEJZbKAzvlYdCUKkeFqrHN0j8lXwpubuT0sPw2h5pxECqsfIpOOO13IA06RsmZip0cNdmXRJ8hYOazKipvHmcNdcFeKEJZbKiVC0b3rE4qhpTFIaEKXwAtuJwZoIzg5Hw4CGjEDK)qgfiJe5PkKr4Cq4JG0BCoGe5LJo4oYl2CFe9OgTohfZmYdTW5at86iVC0b3rE7VoorHi)HmkqgjYtviJW5GWhbP34CaPww1I8aNlPcXhuu4jDc)sS1dvavlLAViYFU84GKkeFqrrRVf1O13UlMzKhAHZbM41r(dzuGmsKNQqgHZbHpcsVX5asKxo6G7iV9xhNOquJAK)yqXmJwFlMzKhAHZbM41rE5OdUJ8Y9i6crqPhU1e(L8W5cKi)HmkqgjYNDTifeNshmbX5QLvT2csbssqibHMoraBzAuTuQ9UAzvlt1EWyNbNBhOcTbuvceWwMgvBEzjRLPApySZGZTdi6d1abSLPr1sZ1cz5)45bMGGOtvAaLiY9ys6GjIRwgRLXAZR2B3vlZ1E7UAP5AHS8F88atqq0PknGse5EmjDWeXvlRAZUwdW9FVavOnGQs47vlRAZUwdW9FVaI(qn89I8TydrE5EeDHiO0d3Ac)sE4CbsuJwFrmZip0cNdmXRJ8hYOazKiF21IuqCkDWeeNRww1AWAG890pbc6CyBA)AzvRTGuGKeesqOPteWwMgvlLAVlYlhDWDK)ioxso6G7KBqAK3nin1Ine5bec6dGIA0A2hZmYdTW5at86iVC0b3rEBHWgyspmjzarPh5pKrbYirEImMeqfAnigdk89QLvTmvRkeFqd6ydjfNmduBE1EW2C4KhEAffmWBoJwlnx7TqoR1ILApyBoCYdpTIcg4nNrRLwk1E8s2sgjKh0MAzmYFU84GKkeFqrrRVf1O1znMzKhAHZbM41r(dzuGmsKNiJjbuHwdIXGctxlT1Y(7QLDRLiJjbuHwdIXGcMpr0b31YQ2d2MdN8WtROGbEZz0APLsThVKTKrc5bTjYlhDWDK3wiSbM0dtsgqu6rnADoJzg5LJo4oY)CIp4CIo4oYdTW5at86OgT(kJzg5Hw4CGjEDK)qgfiJe5na3)9cpN4doNOdUdeWwMgvBE1ErKxo6G7i)Zj(GZj6G70XbsJGOgT(QeZmYdTW5at86ip2lYJanYlhDWDKNQqgHZbrEQI7dr(SRvfh0Aa95uG8((qaAHZbMATyP2SRvUhiJcbeDc(Batc9Fp8r0b3bOfohyQ1ILAnyn4lecwHGN93PJNBasT0w7TAzvlt1I8aNlPcXhuu4jDc)sS1dvavBE1EL1AXsTzx7bJDgCUDGQ0dIE47vlJrEQcj1Ine5PcTbuvsOpNcK33hshCBgDWDuJwZoIzg5Hw4CGjEDKh7f5rGg5LJo4oYtviJW5GipvX9HiF21QIdAn0JpDfPIJnGeGw4CGPwlwQn7AvXbTgGmqs7)NwuiaTW5atTwSu7bJDgCUDaYajT)FArHabSLPr1MxT5Sw2T2lQLMRvfh0AWaGhqsiLiQ4d2bOfohyI8ufsQfBiYtfAdOQK6XNUIuXXgqshCBgDWDuJwNJIzg5Hw4CGjEDKh7f5rGg5LJo4oYtviJW5GipvX9HiF21cz5)45bMGCpIUqeu6HBnHFjpCUaPwlwQvUhiJcbeDc(Batc9Fp8r0b3bOfohyQ1ILAna3)9ce5EmjDWeXLma3)9cgCUDTwSu7bJDgCUDqq0PknGse5EmjDWeXfiGTmnQ28Q92D1YQwMQ9GXodo3oGOpudeWwMgvBE1ERwlwQ1aC)3lGOpudFVAzmYtviPwSHipvOnGQs6HBnDWTz0b3rnA9T7Izg5Hw4CGjEDK)qgfiJe5ZUwKcItPdMab7)HAzvRbRbY3t)eiOZHTP9RLvTzxRb4(VxGk0gqvj89QLvTufYiCoiqfAdOQKqFofiVVpKo42m6G7AzvlvHmcNdcuH2aQkPE8PRivCSbK0b3MrhCxlRAPkKr4CqGk0gqvj9WTMo42m6G7iVC0b3rEQqBavLOgT(2TyMrEOfohyIxh5pKrbYirEvCqRbidK0()PffcqlCoWulRAvXbTg6XNUIuXXgqcqlCoWulRApyBoCYdpTIQLwk1E8s2sgjKh0MAzv7bJDgCUDaYajT)FArHabSLPr1MxT3I8YrhCh5Pk9GOh1O13UiMzKhAHZbM41r(dzuGmsKxfh0AOhF6ksfhBajaTW5atTSQn7AvXbTgGmqs7)NwuiaTW5atTSQ9GT5Wjp80kQwAPu7XlzlzKqEqBQLvTmvRb4(VxGk0gqvj89Q1ILAbec6deOoOb3j8l5bKhC0b3bOfohyQLXiVC0b3rEQspi6rnA9n2hZmYdTW5at86ip2lYJanYlhDWDKNQqgHZbrEQI7drE5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1YuTnUtiuI7)EGjPcXhuuT0sP2B1AXsTipW5sQq8bffEsNWVeB9qfq1sPw2xlJ1YQwMQfHsC)3dmjvi(GIschMkK8K2a2ZPwk1ExTwSulYdCUKkeFqrHN0j8lXwpubuT0sP2RSwgJ8ufsQfBiYJqjQspi6PdUnJo4oQrRVL1yMrEOfohyIxh5LJo4oY7HXUebq4p5arEidLijXg)BnYN1Cg5FysQHm0O13IA06B5mMzKhAHZbM41r(dzuGmsKxfh0Aa95uG8((qaAHZbMAzvB21IuqCkDWeiy)pulRApySZGZTd(cHGvi89QLvTmvlvHmcNdciuIQ0dIE6GBZOdUR1ILAZUw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPww1YuTgSg8fcbRqGapcGOlCoOwlwQ1aC)3lqfAdOQe(E1YQwdwd(cHGvi4z)D645gGuBEuQ9wTmwlJ1YQ2d2MdN8WtROGbEZz0APLsTmvlt1ERwMR9IAP5AL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzSwAUwKh4Cjvi(GIcpPt4xITEOcOAzSwAZswBwRLvTezmjGk0Aqmguy6APT2Bxe5LJo4oYtv6brpQrRVDLXmJ8qlCoWeVoYFiJcKrI8mvRkoO1GTGuGKeesqOPdqlCoWuRfl1s(n8WeFiyle2s4xsPdjBbPajjiKGqthGS8F88atTmwlRAZUwKcItPdMG4C1YQwBbPajjiKGqtNiGTmnQ28Ou7D1YQ2SR1G1a57PFceiWJai6cNdQLvTgSg8fcbRqGa2Y0OAPTw2xlRAzQwdW9FVavOnGQs47vlRAna3)9ci6d1W3Rww1YuTzxlGqqFGaNdJnj8lP0He0G9LbBjlbMuRfl1AaU)7f4CySjHFjLoKGgSVm89QLXATyPwaHG(abQdAWDc)sEa5bhDWDaAHZbMAzmYlhDWDKNQ0dIEuJwF7QeZmYdTW5at86i)HmkqgjYNDTifeNshmbX5QLvTY9azuiGOtWFdysO)7HpIo4oaTW5atTSQ1G1GVqiyfce4raeDHZb1YQwdwd(cHGvi4z)D645gGuBEuQ9wTSQ9GT5Wjp80kkyG3CgTwAPu7TiVC0b3rEeDXGZ1gCMOgT(g7iMzKhAHZbM41r(dzuGmsKp7ArkioLoyceS)hQLvTmvB21AWAWxieScbc8iaIUW5GAzvRbRbY3t)eiqaBzAuT0wBwRL5AZAT0CThVKTKrc5bTPwlwQ1G1a57PFceiGTmnQwAU27c5SwARvfIpObDSHKItMbQLXAzvRkeFqd6ydjfNmdulT1M1iVC0b3rEidK0()PffIA06B5OyMrEOfohyIxh5pKrbYirEhqfC1slLAZj7Oww1AWAG890pbc6CyBA)Azvlt1MDTqw(pEEGji3JOlebLE4wt4xYdNlqQ1ILApySZGZTduH2aQkbcyltJQL2AVDxTmg5LJo4oYJOpuJA06lUlMzKhAHZbM41r(dzuGmsKN7)EbohgBCFKgiGC0ATyPwdW9FVavOnGQs47f5LJo4oY7H1b3rnA9f3Izg5Hw4CGjEDK)qgfiJe5na3)9cuH2aQkHVxKxo6G7ipNdJnP3NCzuJwFXfXmJ8qlCoWeVoYFiJcKrI8gG7)EbQqBavLW3lYlhDWDKNdiiGW20(rnA9fSpMzKhAHZbM41r(dzuGmsK3aC)3lqfAdOQe(ErE5OdUJ8VHaCom2e1O1xK1yMrEOfohyIxh5pKrbYirEdW9FVavOnGQs47f5LJo4oYl9bqkrCPJ4CrnA9f5mMzKhAHZbM41rE5OdUJ8(IdoIZbeuIdJ7i)HmkqgjYZuTgG7)EbQqBavLW3RwlwQLPAZUwvCqRbidK0()PffcqlCoWulRApySZGZTduH2aQkbcyltJQL2AZAoR1ILAvXbTgGmqs7)NwuiaTW5atTSQLPApySZGZTdqgiP9)tlkeiGTmnQ28Q9kR1ILApySZGZTdqgiP9)tlkeiGTmnQwAR9I7QLvTVXNUMiGTmnQwAR9kZzTmwlJ1YyTSQn7Ana3)9cKVN(jqaYajT)FArbtKVfBiY7lo4iohqqjomUJA06lUYyMrEOfohyIxh5LJo4oYli6uLgqjICpMKoyI4I8hYOazKiVb4(VxGi3JjPdMiUKb4(VxWGZTR1ILAvH4dAqhBiP4KzGAZR2lUlY3Ine5feDQsdOerUhtshmrCrnA9fxLyMrEOfohyIxh5LJo4oYli6uLgqjICpMKoyI4I8hYOazKipt1MDTQ4GwdqgiP9)tlkeGw4CGPwlwQn7AvXbTgqFofiVVpeGw4CGPwgRLvTgG7)EbQqBavLabSLPr1sBT3URw2T2SwlnxlKL)JNhycY9i6crqPhU1e(L8W5cKiFl2qKxq0PknGse5EmjDWeXf1O1xWoIzg5Hw4CGjEDKxo6G7iVGOtvAaLiY9ys6GjIlYFiJcKrI8mvRkoO1aKbsA))0IcbOfohyQLvTQ4GwdOpNcK33hcqlCoWulJ1YQwdW9FVavOnGQs47vlRAzQwdW9FVGVqiyfcqgiP9)tlkyQ1ILAL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzvRbRbFHqWke8S)oD8CdqQL2AVvlJr(wSHiVGOtvAaLiY9ys6GjIlQrRVihfZmYdTW5at86iVC0b3r(ZLhhwj4EojoNG0i)HmkqgjYBlifijbHeeA6ebSLPr1sP27QLvTzxRb4(VxGk0gqvj89QLvTzxRb4(VxarFOg(E1YQwU)7fSbBm5Ye(LC)Zysgci2OGbNBxlRAHgi(xwBE1YoURww1AWAG890pbceWwMgvlT1M1ip8EWrtTydr(ZLhhwj4EojoNG0OgTM93fZmYdTW5at86iVC0b3rE3NWgqqPPrJzWFuYFEAK)qgfiJe5na3)9cuH2aQkHVxKVfBiY7(e2acknnAmd(Js(ZtJA0A2FlMzKhAHZbM41rE5OdUJ8Upsj4pk5JDgOtEUVT4dr(dzuGmsK3aC)3lqfAdOQe(Er(wSHiV7Juc(Js(yNb6KN7Bl(quJwZ(lIzg5Hw4CGjEDKxo6G7iVVtmJOyckzdgX5gCh5pKrbYirEdW9FVavOnGQs47f5H3doAQfBiY77eZikMGs2GrCUb3rnAn7zFmZip0cNdmXRJ8YrhCh59DIzeftqjoX4dr(dzuGmsK3aC)3lqfAdOQe(ErE49GJMAXgI8(oXmIIjOeNy8HOgTM9znMzKxo6G7i)hbPrbBuKhAHZbM41rnQrEdwJzgT(wmZip0cNdmXRJ8yVipc0iVC0b3rEQczeohe5PkUpe59idMm6LjcwfDWDTSQf5boxsfIpOOWt6e(LyRhQaQwARL91YQwMQ1G1GVqiyfceWwMgvBE1EWyNbNBh8fcbRqW8jIo4UwlwQ1dpiCdMeNdadQwARnN1YyKNQqsTydrEeBJx6C5XbjFHqWke1O1xeZmYdTW5at86ip2lYJanYlhDWDKNQqgHZbrEQI7drEpYGjJEzIGvrhCxlRArEGZLuH4dkk8KoHFj26HkGQL2AzFTSQLPAna3)9ci6d1W3RwlwQLPA9Wdc3GjX5aWGQL2AZzTSQn7AL7bYOqaDGwt4xIZHXMa0cNdm1YyTmg5PkKul2qKhX24LoxECqI890pbIA0A2hZmYdTW5at86ip2lYJanYlhDWDKNQqgHZbrEQI7drEdW9FVavOnGQs47vlRAzQwdW9FVaI(qn89Q1ILATfKcKKGqccnDIa2Y0OAPT27QLXAzvRbRbY3t)eiqaBzAuT0w7frEQcj1Ine5rSnEjY3t)eiQrRZAmZip0cNdmXRJ8hYOazKiVkoO1aKbsA))0IcbOfohyQLvTzxRb4(VxWxieScbidK0()Pffm1YQwdwd(cHGvi4z)D645gGuBEuQ9wTSQ9GXodo3oazGK2)pTOqGa2Y0OAZR2lQLvTipW5sQq8bffEsNWVeB9qfq1sP2B1YQwImMeqfAnigdkmDT0w7vwlRAnyn4lecwHabSLPr1sZ1ExiN1MxTQq8bnOJnKuCYmqKxo6G7iVVqiyfIA06CgZmYdTW5at86i)HmkqgjYRIdAnazGK2)pTOqaAHZbMAzvlt1EW2C4KhEAfvlTuQ94LSLmsipOn1YQ2dg7m4C7aKbsA))0IcbcyltJQnVAVvlRAnynq(E6NabcyltJQLMR9UqoRnVAvH4dAqhBiP4KzGAzmYlhDWDKN890pbIA06RmMzKhAHZbM41r(hMKAidnA9TiVC0b3rEpm2Liac)jhiQrRVkXmJ8qlCoWeVoYFiJcKrI8e4raeDHZb1YQ2d2MdN8WtROGbEZz0APLsT3QL5AzFT0CTmvRCpqgfci6e83aMe6)E4JOdUdqlCoWulRApySZGZTduLEq0dFVAzSww1YuTE2FNoEUbi1MhLAVvRfl1saBzAuT5rPwDoSL0XgQLvTipW5sQq8bffEsNWVeB9qfq1slLAzFTmxRCpqgfci6e83aMe6)E4JOdUdqlCoWulJ1YQwMQn7AHmqs7)NwuWuRfl1saBzAuT5rPwDoSL0XgQLMR9IAzvlYdCUKkeFqrHN0j8lXwpubuT0sPw2xlZ1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YyTSQn7ArOe3)9atTSQLPAvH4dAqhBiP4KzGAz3AjGTmnQwgRL2AZATSQLPATfKcKKGqccnDIa2Y0OAPu7D1AXsTzxRoh2M2Vww1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YyKxo6G7iVVqiyfIA0A2rmZip0cNdmXRJ8pmj1qgA06BrE5OdUJ8EySlrae(toquJwNJIzg5Hw4CGjEDKxo6G7iVVqiyfI8hYOazKiF21sviJW5GaITXlDU84GKVqiyfQLvTe4raeDHZb1YQ2d2MdN8WtROGbEZz0APLsT3QL5AzFT0CTmvRCpqgfci6e83aMe6)E4JOdUdqlCoWulRApySZGZTduLEq0dFVAzSww1YuTE2FNoEUbi1MhLAVvRfl1saBzAuT5rPwDoSL0XgQLvTipW5sQq8bffEsNWVeB9qfq1slLAzFTmxRCpqgfci6e83aMe6)E4JOdUdqlCoWulJ1YQwMQn7AHmqs7)NwuWuRfl1saBzAuT5rPwDoSL0XgQLMR9IAzvlYdCUKkeFqrHN0j8lXwpubuT0sPw2xlZ1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YyTSQn7ArOe3)9atTSQLPAvH4dAqhBiP4KzGAz3AjGTmnQwgRL2AVDrTSQLPATfKcKKGqccnDIa2Y0OAPu7D1AXsTzxRoh2M2Vww1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YyK)C5Xbjvi(GIIwFlQrRVDxmZip0cNdmXRJ8hYOazKipYdCUKkeFqr1slLAVOww1saBzAuT5v7f1YCTmvlYdCUKkeFqr1slLAZzTmwlRApyBoCYdpTIQLwk1M1iVC0b3r(dzSr4oPGThG0OgT(2TyMrEOfohyIxh5pKrbYir(SRLQqgHZbbeBJxI890pbQLvTmv7bBZHtE4PvuT0sP2SwlRAjWJai6cNdQ1ILAZUwDoSnTFTSQLPA1XgQL2AVDxTwSu7bBZHtE4PvuT0sP2lQLXAzSww1YuTE2FNoEUbi1MhLAVvRfl1saBzAuT5rPwDoSL0XgQLvTipW5sQq8bffEsNWVeB9qfq1slLAzFTmxRCpqgfci6e83aMe6)E4JOdUdqlCoWulJ1YQwMQn7AHmqs7)NwuWuRfl1saBzAuT5rPwDoSL0XgQLMR9IAzvlYdCUKkeFqrHN0j8lXwpubuT0sPw2xlZ1k3dKrHaIob)nGjH(Vh(i6G7a0cNdm1YyTSQvfIpObDSHKItMbQLDRLa2Y0OAPT2Sg5LJo4oYt(E6NarnA9TlIzg5Hw4CGjEDKxo6G7ip57PFce5pKrbYir(SRLQqgHZbbeBJx6C5XbjY3t)eOww1MDTufYiCoiGyB8sKVN(jqTSQ9GT5Wjp80kQwAPuBwRLvTe4raeDHZb1YQwMQ1Z(70XZnaP28Ou7TATyPwcyltJQnpk1QZHTKo2qTSQf5boxsfIpOOWt6e(LyRhQaQwAPul7RL5AL7bYOqarNG)gWKq)3dFeDWDaAHZbMAzSww1YuTzxlKbsA))0IcMATyPwcyltJQnpk1QZHTKo2qT0CTxulRArEGZLuH4dkk8KoHFj26HkGQLwk1Y(AzUw5EGmkeq0j4Vbmj0)9WhrhChGw4CGPwgRLvTQq8bnOJnKuCYmqTSBTeWwMgvlT1M1i)5YJdsQq8bffT(wuJwFJ9XmJ8qlCoWeVoYFiJcKrI8ipW5sQq8bfvlLAVvlRApyBoCYdpTIQLwk1YuThVKTKrc5bTPw2T2B1YyTSQLapcGOlCoOww1MDTqgiP9)tlkyQLvTzxRb4(VxarFOg(E1YQwBbPajjiKGqtNiGTmnQwk1ExTSQn7AL7bYOqqZDqAsPdj265bbOfohyQLvTQq8bnOJnKuCYmqTSBTeWwMgvlT1M1iVC0b3r(dzSr4oPGThG0OgT(wwJzg5LJo4oYJap0GI8qlCoWeVoQrnQrEQabn4oA9f3DXD3U7ISg5Zvi90(Oip7mAkn06SaRVQxDT1MjDO2X2dt0AFysT5aGqqFauoulbYY)HaMAryBOw5RyBrbtTh6s7dOqXWvCAO2lU6APb4MkquWuBoazGK2)pTOGjWoLd1Q4AZbdW9FVa7uaYajT)FArbtoult3YGXqXWvCAO2SE11sdWnvGOGPw(XMgul6YwLmQLMuTkU2R4xQ1muh0G7AXEarumPwMYNXAz6ImymumumWoJMsdTolW6R6vxBTzshQDS9WeT2hMuBoyGN8DAoulbYY)HaMAryBOw5RyBrbtTh6s7dOqXWvCAOw2F11sdWnvGOGPw(XMgul6YwLmQLMuTkU2R4xQ1muh0G7AXEarumPwMYNXAz6wgmgkgkgyNrtPHwNfy9v9QRT2mPd1o2EyIw7dtQnhoguoulbYY)HaMAryBOw5RyBrbtTh6s7dOqXWvCAO2R8QRnlCJ(EEyIcMALJo4U2C45eFW5eDWD64aPrqoekgUItd1MJU6APb4MkquWuBoOKPzd0a7u4GXodo3ohQvX1Mdhm2zW52b2PCOwMULbJHIHR40qTxKZRUwAaUPcefm1MdqgiP9)tlkycSt5qTkU2CWaC)3lWofGmqs7)NwuWKd1Y0TmymumCfNgQ9c2Xvxlna3ubIcMAZbidK0()Pffmb2PCOwfxBoyaU)7fyNcqgiP9)tlkyYHAz6wgmgkgkgyNrtPHwNfy9v9QRT2mPd1o2EyIw7dtQnhmynhQLaz5)qatTiSnuR8vSTOGP2dDP9buOy4konuBwV6APb4MkquWuBoazGK2)pTOGjWoLd1Q4AZbdW9FVa7uaYajT)FArbtoult3YGXqXqXqwGThMOGP2RsTYrhCxRBqkkume59i434GipnwlnfHeeAArhCxlne7)HIbASwRXubBoGul7TQ2lU7I7kgkgOXAZIzaNVcMA5GhMa1EW2CIwlh4pnkuln9CapfvBJB2LUqSFFxTYrhCJQf3UldfdYrhCJcEe4GT5eLI455Um5HheUlgKJo4gf8iWbBZjkZuY3wiSbM0dtsgqu6w5rGd2Mt0eco42GOKtRMhfImMeqfAnigdkmnT3YzXGC0b3OGhboyBorzMs(ifeNsVyqo6GBuWJahSnNOmtjFKBoqsAtYmhWkpcCW2CIMqWb3geLBwnpke4raeDHZbfdYrhCJcEe4GT5eLzk5)rqAuW2QwSbkY9i6crqPhU1e(L8W5cKIb5OdUrbpcCW2CIYmL89)cXmsNWVKCpqWkDRMhfvCqRbidK0()PffcqlCoWumumqJ1MfZaoFfm1cubYL1QJnuRshQvokMu7GQvOkJt4CqOyqo6GBef2MdBfd0yT0qaPG4u61oVA9Wi0W5GAzQX1s97AGiCoOwOb7bq1oDThSnNOmwmihDWnIzk5JuqCk9Ib5OdUrmtjFQczeohyvl2afObI)Ljc4dD6GT5MgmwrvCFGc0aX)Yab8HMzp8GWnysCoamiA(QqtIPlOzKh4Cj6csbglgKJo4gXmL8PkKr4CGvTyduqt77GKkeFqTIQ4(afKh4Cjvi(GIcpPt4xITEOcO8UOyqo6GBeZuY)ioxso6G7KBqQvTyduqkioLoySAEuqkioLoyceS)hkgKJo4gXmL8pIZLKJo4o5gKAvl2aLJbz18OWu2Q4Gwd2csbssqibHMoaTW5aJflgSg8fcbRqqNdBt7ZyXGC0b3iMPK)rCUKC0b3j3GuRAXgOyWAXGC0b3iMPKpYnhijTjzMdy18OW9FVaYnhijTjzMdeiGTmnkpvi(Gg0XgskozgGf3)9ci3CGK0MKzoqGa2Y0O8y6gZhSnho5HNwrmsZ3cSJIb5OdUrmtj)J4Cj5OdUtUbPw1InqXme4OfdYrhCJyMs(c5inKumHaTA18Oanq8VmyG3CgLwk3YjZufYiCoianq8VmraFOthSn30GPyqo6GBeZuYxihPHK33HGIb5OdUrmtjF34txrPSeFJVn0AXGC0b3iMPKpN4NWVKsMdBOIHIbASwAag7m4CBuXGC0b3OWXGO8rqAuW2QwSbkY9i6crqPhU1e(L8W5ceRMhLSrkioLoycIZXYwqkqsccji00jcyltJOChlMoySZGZTduH2aQkbcyltJYlljthm2zW52be9HAGa2Y0iAgYY)XZdmbbrNQ0akrK7XK0btehJmM3T7y(2D0mKL)JNhyccIovPbuIi3JjPdMiowzBaU)7fOcTbuvcFpwzBaU)7fq0hQHVxXGC0b3OWXGyMs(hX5sYrhCNCdsTQfBGcGqqFaKvZJs2ifeNshmbX5yzWAG890pbc6CyBAFw2csbssqibHMoraBzAeL7kgOXAZcE1kgdQwHa1(9SQwupEqTkDOwCd1M7O0R1HZfqATzMjnrO2SWiO2CPdDTMlN2V2NGuGuRsx6APb54AnWBoJwlMuBUJsh)1AL(YAPb54qXGC0b3OWXGyMs(2cHnWKEysYaIs3QZLhhKuH4dkIYnRMhfImMeqfAnigdk89yXKkeFqd6ydjfNmdK3bBZHtE4PvuWaV5mknFlKtlwoyBoCYdpTIcg4nNrPLYXlzlzKqEqBySyGgRnl4vBJRvmguT5ooxTMbQn3rPpDTkDO2gYqRL93HSQ2pcQnl9rtulURLdJq1M7O0XFTwPVSwAqooumihDWnkCmiMPKVTqydmPhMKmGO0TAEuiYysavO1GymOW00Y(7yxImMeqfAnigdky(erhCZ6GT5Wjp80kkyG3CgLwkhVKTKrc5bTPyqo6GBu4yqmtj)Nt8bNt0b3fdYrhCJchdIzk5)CIp4CIo4oDCG0iWQ5rXaC)3l8CIp4CIo4oqaBzAuExumqJ1EfG2aQk16W(ZrC1EWTz0b3IdvlNGatT4U2ZNqGwRf5bNIb5OdUrHJbXmL8PkKr4CGvTyduOcTbuvsOpNcK33hshCBgDWTvuf3hOKTkoO1a6ZPa599Ha0cNdmwSKTCpqgfci6e83aMe6)E4JOdUdqlCoWyXIbRbFHqWke8S)oD8CdqO9glMqEGZLuH4dkk8KoHFj26HkGY7kTyj7dg7m4C7avPhe9W3JXIb5OdUrHJbXmL8PkKr4CGvTyduOcTbuvs94txrQ4ydiPdUnJo42kQI7duYwfh0AOhF6ksfhBajaTW5aJflzRIdAnazGK2)pTOqaAHZbglwoySZGZTdqgiP9)tlkeiGTmnkVCYUxqZQ4Gwdga8ascPerfFWoaTW5atXGC0b3OWXGyMs(ufYiCoWQwSbkufYiCoWQwSbkuH2aQkPhU10b3MrhCBfvX9bkzdz5)45bMGCpIUqeu6HBnHFjpCUaXIf5EGmkeq0j4Vbmj0)9WhrhChGw4CGXIfdW9FVarUhtshmrCjdW9FVGbNBBXIsMMnqdcIovPbuIi3JjPdMiUWbJDgCUDGa2Y0O8UDhlMoySZGZTdi6d1abSLPr5DZIfdW9FVaI(qn89ySyqo6GBu4yqmtjFQqBavfRMhLSrkioLoyceS)hyzWAG890pbc6CyBAFwzBaU)7fOcTbuvcFpwufYiCoiqfAdOQKqFofiVVpKo42m6GBwufYiCoiqfAdOQK6XNUIuXXgqshCBgDWnlQczeoheOcTbuvspCRPdUnJo4UyGgR9ki9GOxBUJsV2Sygi)AzUwRhF6ksfhBa5QRnlvYyS)21sdYX1kTP2Sygi)AjGyUS2hMuBdzO1EvPb0efdYrhCJchdIzk5tv6br3Q5rrfh0AaYajT)FArHa0cNdmSuXbTg6XNUIuXXgqcqlCoWW6GT5Wjp80kIwkhVKTKrc5bTH1bJDgCUDaYajT)FArHabSLPr5DRyGgR9ki9GOxBUJsVwRhF6ksfhBaPwMR1ACTzXmq(xDTzPsgJ93UwAqoUwPn1EfG2aQk1(9QLPF7aeQ2pAA)AVc4CmJfdYrhCJchdIzk5tv6br3Q5rrfh0AOhF6ksfhBajaTW5adRSvXbTgGmqs7)NwuiaTW5adRd2MdN8WtRiAPC8s2sgjKh0gwmzaU)7fOcTbuvcFplwaec6deOoOb3j8l5bKhC0b3bOfohyySyGgRLhGAFFNR2d22gATwCxlDv9qxD(57pk9px4GTZNgkuHMo2zu2ntAq(0qS)hYp3HTjFAkcji00Io4MDPP54Ri7sdbeiKd9qXGC0b3OWXGyMs(ufYiCoWQwSbkiuIQ0dIE6GBZOdUTIQ4(af5EGmkeq0j4Vbmj0)9WhrhChGw4CGHftnUtiuI7)EGjPcXhueTuUzXcYdCUKkeFqrHN0j8lXwpubef2ZilMqOe3)9atsfIpOOKWHPcjpPnG9COCNflipW5sQq8bffEsNWVeB9qfq0s5kzSyqo6GBu4yqmtjFpm2Liac)jhWQhMKAidLYnRGmuIKeB8VvkznNfdYrhCJchdIzk5tv6br3Q5rrfh0Aa95uG8((qaAHZbgwzJuqCkDWeiy)pW6GXodo3o4lecwHW3JftufYiCoiGqjQspi6PdUnJo42ILSL7bYOqarNG)gWKq)3dFeDWDaAHZbgwmzWAWxieScbc8iaIUW5alwma3)9cuH2aQkHVhldwd(cHGvi4z)D645gGKhLBmYiRd2MdN8WtROGbEZzuAPWet3y(cAwUhiJcbeDc(Batc9Fp8r0b3bOfohyyKMrEGZLuH4dkk8KoHFj26HkGyK2SKzLfrgtcOcTgeJbfMM2BxumqJ1EfKEq0Rn3rPxBwQGuGulnfHe00xDTwJRfPG4u61kTP2gxRC0HkuBwknTwU)7zvT0WVN(jqTnwRD6AjWJai61sK2hSQwZNmTFTxbOnGQcZzEnZxJ1SyTm9BhGq1(rt7x7vaNJzSyqo6GBu4yqmtjFQspi6wnpkmPIdAnylifijbHeeA6a0cNdmwSq(n8WeFiyle2s4xsPdjBbPajjiKGqthGS8F88adJSYgPG4u6GjiohlBbPajjiKGqtNiGTmnkpk3XkBdwdKVN(jqGapcGOlCoGLbRbFHqWkeiGTmnIw2ZIjdW9FVavOnGQs47XYaC)3lGOpudFpwmLnGqqFGaNdJnj8lP0He0G9LbBjlbMyXIb4(VxGZHXMe(Lu6qcAW(YW3Jrlwaec6deOoOb3j8l5bKhC0b3bOfohyySyGgRLNUyW5AdotTpmPwE6e83aMA5)Vh(i6G7Ib5OdUrHJbXmL8r0fdoxBWzSAEuYgPG4u6Gjiohl5EGmkeq0j4Vbmj0)9WhrhChGw4CGHLbRbFHqWkeiWJai6cNdyzWAWxieScbp7Vthp3aK8OCJ1bBZHtE4PvuWaV5mkTuUvmqJ1MfZajT)FArHAZLo012yTwKcItPdMAL2ulhwPxln87PFcuR0MAVQcHGvOwHa1(9Q9Hj16WTFTqJ)(0dfdYrhCJchdIzk5dzGK2)pTOGvZJs2ifeNshmbc2)dSykBdwd(cHGviqGhbq0fohWYG1a57PFceiGTmnI2SYCwP5JxYwYiH8G2yXIbRbY3t)eiqaBzAenFxiN0QcXh0Go2qsXjZamYsfIpObDSHKItMbOnRfdYrhCJchdIzk5JOpuTAEuCavWrlLCYoyzWAG890pbc6CyBAFwmLnKL)JNhycY9i6crqPhU1e(L8W5celwoySZGZTduH2aQkbcyltJO92DmwmihDWnkCmiMPKVhwhCB18OW9FVaNdJnUpsdeqoQflgG7)EbQqBavLW3Ryqo6GBu4yqmtjFohgBsVp5sRMhfdW9FVavOnGQs47vmihDWnkCmiMPKphqqaHTP9TAEuma3)9cuH2aQkHVxXGC0b3OWXGyMs(VHaCom2y18OyaU)7fOcTbuvcFVIb5OdUrHJbXmL8L(aiLiU0rCoRMhfdW9FVavOnGQs47vmihDWnkCmiMPK)hbPrbBRAXgO4lo4iohqqjomUTAEuyYaC)3lqfAdOQe(EwSWu2Q4GwdqgiP9)tlkeGw4CGH1bJDgCUDGk0gqvjqaBzAeTznNwSOIdAnazGK2)pTOqaAHZbgwmDWyNbNBhGmqs7)NwuiqaBzAuExPflhm2zW52bidK0()PffceWwMgr7f3X6n(01ebSLPr0EL5KrgzKv2qgiP9)tlkycKVN(jqXGC0b3OWXGyMs(FeKgfSTQfBGIGOtvAaLiY9ys6GjIZQ5rXaC)3lqK7XK0btexYaC)3lyW52wSOcXh0Go2qsXjZa5DXDfdYrhCJchdIzk5)rqAuW2QwSbkcIovPbuIi3JjPdMioRMhfMYwfh0AaYajT)FArHa0cNdmwSKTkoO1a6ZPa599Ha0cNdmmYYaC)3lqfAdOQeiGTmnI2B3XUzLMHS8F88atqUhrxick9WTMWVKhoxGumihDWnkCmiMPK)hbPrbBRAXgOii6uLgqjICpMKoyI4SAEuysfh0AaYajT)FArHa0cNdmSuXbTgqFofiVVpeGw4CGHrwgG7)EbQqBavLW3JftqgiP9)tlkyc(cHGvWIf5EGmkeq0j4Vbmj0)9WhrhChGw4CGHLbRbFHqWke8S)oD8CdqO9gJfdYrhCJchdIzk5)rqAuW2k49GJMAXgOCU84Wkb3ZjX5eKA18OylifijbHeeA6ebSLPruUJv2gG7)EbQqBavLW3Jv2gG7)Ebe9HA47XI7)EbBWgtUmHFj3)mMKHaInkyW52SGgi(xMh74owgSgiFp9tGabSLPr0M1Ib5OdUrHJbXmL8)iinkyBvl2af3NWgqqPPrJzWFuYFEQvZJIb4(VxGk0gqvj89kgKJo4gfogeZuY)JG0OGTvTyduCFKsWFuYh7mqN8CFBXhSAEuma3)9cuH2aQkHVxXGC0b3OWXGyMs(FeKgfSTcEp4OPwSbk(oXmIIjOKnyeNBWTvZJIb4(VxGk0gqvj89kgKJo4gfogeZuY)JG0OGTvW7bhn1InqX3jMrumbL4eJpy18OyaU)7fOcTbuvcFVIbASwAc4jFNw7tCoo5WwTpmP2ps4CqTJc2ORU2SWiOwCx7bJDgCUDOyqo6GBu4yqmtj)pcsJc2OIHIbASwAIHahTwJyl(qTc34gDauXanwBwSPcn2UwrRnRmxlt5K5AZDu61stWZyT0GCCO2SaBBWmIcUlRf31EbZ1QcXhuKv1M7O0R9kaTbuvSQwmP2ChLETzEn781Iv6aj3bb1MRmATpmPwe2gQfAG4FzOwAQdHRnxz0ANxTzXmq(1EW2C4AhuThS90(1(9cfdYrhCJcMHahLc0uHgBB18OW0bBZHtE4PveTuYkZQ4Gwdga8ascPerfFWoaTW5aJflhSnho5HNwruKESLdDH4dM0XJrwmzaU)7fOcTbuvcFplwma3)9ci6d1W3ZIfObI)Lbd8MZO5r5ICYmvHmcNdcqde)lteWh60bBZnnySyjBQczeoheqt77GKkeFqzKftzRIdAnazGK2)pTOqaAHZbglwoySZGZTdqgiP9)tlkeiGTmnI2lySyqo6GBuWme4OmtjFQczeohyvl2aLpcsVX5aIvuf3hOCW2C4KhEAffmWBoJs7nlwGgi(xgmWBoJMhLlYjZufYiCoianq8VmraFOthSn30GXILSPkKr4CqanTVdsQq8bTyqo6GBuWme4OmtjFeqiIcMehUHeYBydS6C5Xbjvi(GIOCZQ5rjBdwdiGqefmjoCdjK3Wge05W20(wSqviJW5GWhbP34CaHftYrhQqcAWEaeLBSiYysavO1GymOW00((oxIah6cXhs6ydwSCOleFar7fSuH4dAqhBiP4KzG8YjJfd0yTSZgLETzXdD80(1ETtmaYQAZcjDT4xT0K7HkGQv0AVG5AvH4dkYQAXKAzp7MvMRvfIpOOAZLo01EfG2aQk1oOA)EfdYrhCJcMHahLzk5)KoHFj26HkGSAEuOkKr4Cq4JG0BCoGWsUhiJcb4qhpTFIZjgafGw4CGHfYdCUKkeFqrHN0j8lXwpubeTuUGzMma3)9cuH2aQkHVhnZ0nMzsUhiJcb4qhpTFIZjgafisZgLBmYiJfd0yTzHKUw8RwAY9qfq1kAT3YrmxlsLdBOAXVAzNBmgOR9ANyauTysTIVmnsRnRmxlt5K5AZDu61stG)CoOwAcmcySwvi(GIcfdYrhCJcMHahLzk5)KoHFj26HkGSAEuOkKr4Cq4JG0BCoGWIjU)7fOpgd0joNyauaPYHnAPClhzXctz7rgmz0lteSk6GBwipW5sQq8bffEsNWVeB9qfq0sjRmZKCpqgfcg8NZbjdgbbI0Sr7fmYmsbXP0btGG9)aJmwmqJ1Mfs6AXVAPj3dvavRIRv88Cxwlnbig3L1MJXdc31oVANwo6qfQf31k9L1QcXh0AfTw2xRkeFqrHIb5OdUrbZqGJYmL8FsNWVeB9qfqwDU84GKkeFqruUz18OqviJW5GWhbP34CaHfYdCUKkeFqrHN0j8lXwpubeTuyFXGC0b3OGziWrzMs(WHoEA)eb8iJT0gRMhfQczeohe(ii9gNdifdYrhCJcMHahLzk5l2CFeDRMhfQczeohe(ii9gNdifd0yTzkCSBw6xhNOqTkUwXZZDzT0eGyCxwBogpiCxRO1ErTQq8bfvmihDWnkygcCuMPKV9xhNOGvNlpoiPcXhueLBwnpkufYiCoi8rq6nohqyH8aNlPcXhuu4jDc)sS1dvar5IIb5OdUrbZqGJYmL8T)64efSAEuOkKr4Cq4JG0BCoGumumqJ1sti2IpulMkqQvhBOwHBCJoaQyGgR9ko2Jw7vvieScOAXDTnUzxpYyteYL1QcXhuuTpmPwLouRhzWKrVSwcwfDWDTZR2CYCTCoamOAfcuR4iGyUS2VxXGC0b3OGbRuOkKr4CGvTyduqSnEPZLhhK8fcbRGvuf3hO4rgmz0lteSk6GBwipW5sQq8bffEsNWVeB9qfq0YEwmzWAWxieScbcyltJY7GXodo3o4lecwHG5teDWTflE4bHBWK4Cayq0MtglgOXAVIJ9O1sd)E6NaOAXDTnUzxpYyteYL1QcXhuuTpmPwLouRhzWKrVSwcwfDWDTZR2CYCTCoamOAfcuR4iGyUS2VxXGC0b3OGbRmtjFQczeohyvl2afeBJx6C5XbjY3t)eWkQI7du8idMm6LjcwfDWnlKh4Cjvi(GIcpPt4xITEOciAzplMma3)9ci6d1W3ZIfM8Wdc3GjX5aWGOnNSYwUhiJcb0bAnHFjohgBcqlCoWWiJfd0yTxXXE0APHFp9tauTZR2Ra0gqvHzE6d18ZsfKcKAPPiKGqtx7GQ97vR0MAZfQLUqfQ9cMRfbhCBq16GNwlURvPd1sd)E6Na1stGZSyqo6GBuWGvMPKpvHmcNdSQfBGcITXlr(E6NawrvCFGIb4(VxGk0gqvj89yXKb4(VxarFOg(EwSylifijbHeeA6ebSLPr0EhJSmynq(E6NabcyltJO9IIbASwEp4mIR2RQqiyfQvAtT0WVN(jqTiq)E16rgmPwfxBwmdK0()PffQ9iiTyqo6GBuWGvMPKVVqiyfSAEuuXbTgGmqs7)NwuiaTW5adRSHmqs7)NwuWe8fcbRaldwd(cHGvi4z)D645gGKhLBSoySZGZTdqgiP9)tlkeiGTmnkVlyH8aNlPcXhuu4jDc)sS1dvar5glImMeqfAnigdkmnTxjldwd(cHGviqaBzAenFxiN5PcXh0Go2qsXjZafdYrhCJcgSYmL8jFp9taRMhfvCqRbidK0()PffcqlCoWWIPd2MdN8WtRiAPC8s2sgjKh0gwhm2zW52bidK0()PffceWwMgL3nwgSgiFp9tGabSLPr08DHCMNkeFqd6ydjfNmdWyXanw7vvieSc1(9ydapRQvCiCTkzauTkU2pcQD0AfuTsTip4mIRwFObIOysTpmPwLouRtqAT0GCCTCWdtGALAFtpi6aPyqo6GBuWGvMPKVhg7seaH)Kdy1dtsnKHs5wXGC0b3OGbRmtjFFHqWky18OqGhbq0fohW6GT5Wjp80kkyG3CgLwk3yM90mtY9azuiGOtWFdysO)7HpIo4oaTW5adRdg7m4C7avPhe9W3Jrwm5z)D645gGKhLBwSqaBzAuEu05WwshBGfYdCUKkeFqrHN0j8lXwpubeTuypZY9azuiGOtWFdysO)7HpIo4oaTW5adJSykBidK0()PffmwSqaBzAuEu05WwshBGMVGfYdCUKkeFqrHN0j8lXwpubeTuypZY9azuiGOtWFdysO)7HpIo4oaTW5adJSYgHsC)3dmSysfIpObDSHKItMbyxcyltJyK2SYIjBbPajjiKGqtNiGTmnIYDwSKToh2M2NLCpqgfci6e83aMe6)E4JOdUdqlCoWWyXGC0b3OGbRmtjFpm2Liac)jhWQhMKAidLYTIb5OdUrbdwzMs((cHGvWQZLhhKuH4dkIYnRMhLSPkKr4CqaX24LoxECqYxieScSiWJai6cNdyDW2C4KhEAffmWBoJslLBmZEAMj5EGmkeq0j4Vbmj0)9WhrhChGw4CGH1bJDgCUDGQ0dIE47XilM8S)oD8CdqYJYnlwiGTmnkpk6CylPJnWc5boxsfIpOOWt6e(LyRhQaIwkSNz5EGmkeq0j4Vbmj0)9WhrhChGw4CGHrwmLnKbsA))0IcglwiGTmnkpk6CylPJnqZxWc5boxsfIpOOWt6e(LyRhQaIwkSNz5EGmkeq0j4Vbmj0)9WhrhChGw4CGHrwzJqjU)7bgwmPcXh0Go2qsXjZaSlbSLPrms7TlyXKTGuGKeesqOPteWwMgr5olwYwNdBt7ZsUhiJcbeDc(Batc9Fp8r0b3bOfohyySyGgRLgqgBeURntW2dqAT4Uw7VthphuRkeFqr1kATzL5APb54AZLo01s(DpTFT4Vw701EbQwM(E1Q4AZATQq8bfXyTysTShvlt5K5AvH4dkIXIb5OdUrbdwzMs(hYyJWDsbBpaPwnpkipW5sQq8bfrlLlyraBzAuExWmtipW5sQq8bfrlLCYiRd2MdN8WtRiAPK1IbASwAYa4v73RwA43t)eOwrRnRmxlURvCUAvH4dkQwMYLo016gQt7xRd3(1cn(7tVwPn12yTwulEi6yLXIb5OdUrbdwzMs(KVN(jGvZJs2ufYiCoiGyB8sKVN(jalMoyBoCYdpTIOLswzrGhbq0fohyXs26CyBAFwmPJnq7T7Sy5GT5Wjp80kIwkxWiJSyYZ(70XZnajpk3SyHa2Y0O8OOZHTKo2alKh4Cjvi(GIcpPt4xITEOciAPWEML7bYOqarNG)gWKq)3dFeDWDaAHZbggzXu2qgiP9)tlkySyHa2Y0O8OOZHTKo2anFblKh4Cjvi(GIcpPt4xITEOciAPWEML7bYOqarNG)gWKq)3dFeDWDaAHZbggzPcXh0Go2qsXjZaSlbSLPr0M1Ib5OdUrbdwzMs(KVN(jGvNlpoiPcXhueLBwnpkztviJW5GaITXlDU84Ge57PFcWkBQczeoheqSnEjY3t)eG1bBZHtE4PveTuYklc8iaIUW5awm5z)D645gGKhLBwSqaBzAuEu05WwshBGfYdCUKkeFqrHN0j8lXwpubeTuypZY9azuiGOtWFdysO)7HpIo4oaTW5adJSykBidK0()PffmwSqaBzAuEu05WwshBGMVGfYdCUKkeFqrHN0j8lXwpubeTuypZY9azuiGOtWFdysO)7HpIo4oaTW5adJSuH4dAqhBiP4Kza2La2Y0iAZAXanwlnGm2iCxBMGThG0AXDT8zw78QD6A9K2a2ZPwPn1oAT5ooxTgCToaHQ1i2IpuRsx6AZInvOX21A(qTkU2mVo)SuAA(zQ0KlgKJo4gfmyLzk5FiJnc3jfS9aKA18OG8aNlPcXhueLBSoyBoCYdpTIOLcthVKTKrc5bTHDVXilc8iaIUW5awzdzGK2)pTOGHv2gG7)Ebe9HA47XYwqkqsccji00jcyltJOChRSL7bYOqqZDqAsPdj265bbOfohyyPcXh0Go2qsXjZaSlbSLPr0M1Ib5OdUrbdwzMs(iWdnOIHIbAS2Sicb9bqfdYrhCJcacb9bquo4(aTsefmPNtSbRMhfObI)LbDSHKIt2sg0EJv2gG7)EbQqBavLW3JftzBWA4G7d0kruWKEoXgsCFsh05W20(SYwo6G7Wb3hOvIOGj9CIneMo9CJpD1IL335se4qxi(qshBip)JjylzWyXanwln1LRCjQ2pcQ9AhgBQn3rPx7vaAdOQu73lul7CyNP2hMuBwmdK0()Pffc1Mfgb1M7O0RnZRR97vlh8WeOwP230dIoqQvq16WTFTcQ2rRL8BuTpmP2B3HQ18jt7x7vaAdOQekgKJo4gfaec6dGyMs(Com2KWVKshsqd2xA18OyaU)7fOcTbuvcFpwmbzGK2)pTOGj4lecwblwma3)9ci6d1W3J1bBZHtE4PvuWaV5mAEuUzXIb4(VxGk0gqvjqaBzAuEuUDhJwS8gF6AIa2Y0O8OC7UIbASwAQQGTNwRIRvCJFx7v9leZiDT5ok9AVcqBavLAfuToC7xRGQD0AZf35GwlbqFNw7016WOP9RvQ99Do2LQ4(qThbP1IPcKAv6qTeWwMEA)AnFIOdURf)QvPd1(gF6AXGC0b3OaGqqFaeZuY3)leZiDc)sY9abR0TAEuoySZGZTduH2aQkbcyltJYJ9wSyaU)7fOcTbuvcFplwEJpDnraBzAuES)UIb5OdUrbaHG(aiMPKV)xiMr6e(LK7bcwPB18O8CymHjMEJpDnraBzAe7Y(7yKM0bJDgCUnJ0(CymHjMEJpDnraBzAe7Y(7y3dg7m4C7avOnGQsGa2Y0igPjDWyNbNBZyXGC0b3OaGqqFaeZuY)HpFeysY9azuiXbITvZJcYdCUKkeFqrHN0j8lXwpubeTuUWIfImMeqfAnigdkmnTx5DSGgi(xM3v5UIb5OdUrbaHG(aiMPKV3NmVlN2pX5eKA18OG8aNlPcXhuu4jDc)sS1dvarlLlSyHiJjbuHwdIXGctt7vExXGC0b3OaGqqFaeZuYxPdPFZH)Tj9WKdy18OW9FVaboS5aek9WKde(EwSW9FVaboS5aek9WKdKo4FRajGu5WwE3URyqo6GBuaqiOpaIzk5tgpphKMoH8KdumihDWnkaie0haXmL8ZftCgQW0jcGWT0hOyqo6GBuaqiOpaIzk5Bd2yYLj8l5(NXKmeqSrwnpkqde)lZlN3Xk7dg7m4C7avOnGQs47vmqJ1Yoh2zQLgcI30(1MfYj2aQ2hMulKbC(kulrAFOwmPw2gNRwU)7HSQ25vRhgHgoheQLM6YvUevRsUSwfxRpO1Q0HAD4CbKw7bJDgCUDTCccm1I7AfQY4eohul0G9aOqXGC0b3OaGqqFaeZuYNaI30(PNtSbKvNlpoiPcXhueLBwnpkQq8bnOJnKuCYmqE3c50IfMysfIpOb6G4u6bVJsl74olwuH4dAGoioLEW7O5r5I7yKftYrhQqcAWEaeLBwSOcXh0Go2qsXjZa0EroIrgTyHjvi(Gg0Xgsko5D00f3rl7VJftYrhQqcAWEaeLBwSOcXh0Go2qsXjZa0M1SYiJfdfd0yT8kioLoyQLME0b3OIbASwRhF6ivCSbKAXDT3Y8QRLVfpeDSwln87PFcumihDWnkGuqCkDWqH890pbSAEuuXbTg6XNUIuXXgqcqlCoWW6GT5Wjp80kIwkzLLkeFqd6ydjfNmdWUeWwMgr7vwmqJ1Y)5uG8((qTmxlpDc(BatT8)3dFeDW9vxBwSrFcuBUqTFeulUHA9DyoXvRIRv88Cxw7vvieSc1Q4Av6qT2Y01QcXh0ANxTJw7GQTXATOw8q0XATxcQv1IW1koxTyLoqQ1wMUwvi(GwRWnUrhavRhb)gnumihDWnkGuqCkDWWmL89WyxIai8NCaREysQHmuk3kgKJo4gfqkioLoyyMs((cHGvWQ5rrUhiJcbeDc(Batc9Fp8r0b3bOfohyyX9FVa6ZPa599HW3Jf3)9cOpNcK33hceWwMgL3Ta7zLncL4(VhykgOXA5)CkqEFF4QRLM655USwmPwAi8iaIET5ok9A5(VhyQ9QkecwbuXGC0b3OasbXP0bdZuY3dJDjcGWFYbS6HjPgYqPCRyqo6GBuaPG4u6GHzk57lecwbRoxECqsfIpOik3SAEuuXbTgqFofiVVpeGw4CGHfteWwMgL3TlSyXZ(70XZnajpk3yKLkeFqd6ydjfNmdWUeWwMgr7ffd0yT8FofiVVpulZ1YtNG)gWul))9WhrhCx701YN5vxln1ZZDzTGqCxwln87PFcuRsx0AZDCUA5GAjWJai6GP2hMuRN0gWEofdYrhCJcifeNshmmtjFY3t)eWQ5rrfh0Aa95uG8((qaAHZbgwY9azuiGOtWFdysO)7HpIo4oaTW5adRSnynq(E6NabDoSnTplQczeoheqt77GKkeFqlgOXA5)CkqEFFO2CZVwE6e83aMA5)Vh(i6G7RUwAiiEEUlR9Hj1YH7pQwAqoUwPn5Jj1czOqBatTOw8q0XATMpr0b3HIb5OdUrbKcItPdgMPKVhg7seaH)Kdy1dtsnKHs5wXGC0b3OasbXP0bdZuY3xieScwDU84GKkeFqruUz18OOIdAnG(CkqEFFiaTW5adl5EGmkeq0j4Vbmj0)9WhrhChGw4CGHftYrhQqcAWEaeT3SyjBvCqRbidK0()PffcqlCoWWilvi(Gg0XgskozgGwcyltJyXebSLPr5DJDyXs2iuI7)EGHXIbASw(pNcK33hQL5AZIzG8Rf31ElZRUwAi8iaIETxvHqWkuRO1Q0HAH2ul(vlsbXP0RvX16dAT2sg1A(erhCxlh8WeO2SygiP9)tlkumihDWnkGuqCkDWWmL89WyxIai8NCaREysQHmuk3kgKJo4gfqkioLoyyMs((cHGvWQ5rrfh0Aa95uG8((qaAHZbgwQ4GwdqgiP9)tlkeGw4CGHLC0HkKGgShar5glU)7fqFofiVVpeiGTmnkVBb2h5rEWjA9f5mhf1OgJa]] )

end