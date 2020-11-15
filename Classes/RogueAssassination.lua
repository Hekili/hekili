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


    spec:RegisterPack( "Assassination", 20201111, [[de1ThcqiQQ6rij5sQuj1MqjFIQkzuOiNcLYQqsQxHIAwKsUfkvAxc(LOQggsIJPszzQe9muQAAIkCnrfTnvsY3OQs14qPIohvvuRtLK6DuvbQ5Ps4EiX(qH(hvvqDqvQuluLupuLkmrvQexKQkYgPQsjFuLeAKuvPuNeLk0krs9sQQaMPkjQBsvLIDsk1qvjrwQkv0trvtLQsxLQkq2Qkj4RQujzSOub7vO)kYGvCyIfJkpwftMKld2SQ8zrz0ivNwPvtvfKxJcMnvUnPA3s9BidNQCCQQqlhXZHA6uUUQA7iLVlQ04PQ48IQSEvQA(KI9l54TOVrELyqu7lPYLu52TB3cxY(C4NzFK3YZdI8EYHbjdI8TOdr(7gJfmEBXwuh59K8Cirf9nYJrFYbI80nZdF15NF2A0)CHdspF8Q)DITO(qKNLpE1p5h55(RZyh7ixKxjge1(sQCjvUD72TWLSph(5lVQiV8n6isKNF1VJip9vPGoYf5va(e5PQAUBmwW4TfBrDn3jk7df1uvnAJOb6CaPMB30QMlPYLujY7wSHJ(g5XgioJoOI(g1(w03ip0cNduXRJ8hYAazLiVjoOTqVz0nSjogasaAHZbQAyvZbPZHsEOTnCnmsPMCudRAmHKbwWwDizOKAHAy3AiGUSnUggR5QI8YXwuh5jFp7tGOf1(YOVrEOfohOIxh5FisQbFSO23I8YXwuh59qixIay0NCGOf1M9rFJ8qlCoqfVoYFiRbKvI8Y9azniGPtqFfOs4)7HoITOoaTW5avnSQH7)Eb8NZaY7NbHVxnSQH7)Eb8NZaY7NbbcOlBJR5IAUfyFnSQX)AW4e3)9avKxo2I6iFMqiidIwu7Ce9nYdTW5av86i)drsn4Jf1(wKxo2I6iVhc5seaJ(KdeTO25m6BKhAHZbQ41rE5ylQJ8zcHGmiYFiRbKvI8M4G2c4pNbK3pdcqlCoqvdRAyQgcOlBJR5IAUDznA0uJN(3zRNBbsnxqPMB1WwnSQXesgybB1HKHsQfQHDRHa6Y24AySMlJ8N8ooizcjdmCu7BrlQ9vf9nYdTW5av86i)HSgqwjYBIdAlG)CgqE)miaTW5avnSQrUhiRbbmDc6Ravc)Fp0rSf1bOfohOQHvn(xJczbY3Z(eiy7HHTZQHvn0eYkCoiG3oZbjtizGf5LJTOoYt(E2NarlQTFp6BKhAHZbQ41r(hIKAWhlQ9TiVCSf1rEpeYLiag9jhiArTzNrFJ8qlCoqfVoYlhBrDKptieKbr(dznGSsK3eh0wa)5mG8(zqaAHZbQAyvJCpqwdcy6e0xbQe()EOJylQdqlCoqvdRAyQg5ylnibnOVaUggR5wnA0uJ)1yIdAla(GLo7VTyqaAHZbQAyRgw1ycjdSGT6qYqj1c1Wyneqx2gxdRAyQgcOlBJR5IAUXoRrJMA8VgmoX9FpqvdBr(tEhhKmHKbgoQ9TOf12ph9nYdTW5av86i)drsn4Jf1(wKxo2I6iVhc5seaJ(KdeTO23Os03ip0cNduXRJ8hYAazLiVjoOTa(Zza59ZGa0cNdu1WQgtCqBbWhS0z)TfdcqlCoqvdRAKJT0Ge0G(c4AOuZTAyvd3)9c4pNbK3pdceqx2gxZf1ClW(iVCSf1r(mHqqgeTOf5bmg6dGJ(g1(w03ip0cNduXRJ8hYAazLip0ajlVGT6qYqjDXNAySMB1WQg)RrbC)3lqdAfyMe(E1WQgMQX)AuilCq9bAJigOspNOdjUpPd2Eyy7SAyvJ)1ihBrD4G6d0grmqLEorhcBNEUnJUvJgn18(oxIah6cjds2Qd1Crnzhvqx8Pg2I8YXwuh5pO(aTreduPNt0HOf1(YOVrEOfohOIxh5pK1aYkrEfW9FVanOvGzs47vdRAyQgfW9FVqMqiidcGpyPZ(BlgOQrJMAua3)9cy6lTW3Rgw1Cq6COKhABdhuWBpRvZfuQ5wnA0uJc4(VxGg0kWmjqaDzBCnxqPMBuPg2QrJMAEBgDlraDzBCnxqPMBujYlhBrDKNZHqQe6Lm6qcAqpVOf1M9rFJ8qlCoqfVoYFiRbKvI8heYPq52bAqRaZKab0LTX1CrnSVgnAQrbC)3lqdAfyMe(E1OrtnVnJULiGUSnUMlQH9ujYlhBrDKp7le1kDc9sY9abz0Jwu7Ce9nYdTW5av86i)HSgqwjY)CiePgMQHPAEBgDlraDzBCnSBnSNk1Wwn5xJCSf1Pdc5uOC7AyRggR55qisnmvdt182m6wIa6Y24Ay3AypvQHDR5Gqofk3oqdAfyMeiGUSnUg2Qj)AKJTOoDqiNcLBxdBrE5ylQJ8zFHOwPtOxsUhiiJE0IANZOVrEOfohOIxh5pK1aYkrESh4CjtizGHdpPtOxIHEPb4AyKsnxwJgn1qKvLaAqBbrPWHTRHXAUkQudRAGgiz5vZf143PsKxo2I6i)dD(yqLK7bYAqIde9Of1(QI(g5Hw4CGkEDK)qwdiRe5XEGZLmHKbgo8KoHEjg6LgGRHrk1CznA0udrwvcObTfeLch2UggR5QOsKxo2I6iV3NSV82olX5eSfTO2(9OVrEOfohOIxh5pK1aYkrEU)7fiWHbhGXPhICGW3RgnAQH7)EbcCyWbyC6HihiDq)2asaBYHHAUOMBujYlhBrDK3OdPFZH(Tk9qKdeTO2SZOVrE5ylQJ8K1ZZbPTtyp5arEOfohOIxhTO2(5OVrE5ylQJ85Iiofny7ebWOw6de5Hw4CGkED0IAFJkrFJ8qlCoqfVoYFiRbKvI8qdKS8Q5IAYjvQHvn(xZbHCkuUDGg0kWmj89I8YXwuh51bDejVe6LC)ZQskci64Of1(2TOVrEOfohOIxh5LJTOoYtaXB7S0Zj6aoYFiRbKvI8MqYalyRoKmusTqnxuZTqoRrJMAyQgMQXesgyb6G4m6bVJvdJ1WoPsnA0uJjKmWc0bXz0dEhRMlOuZLuPg2QHvnmvJCSLgKGg0xaxdLAUvJgn1ycjdSGT6qYqj1c1Wynx6NRHTAyRgnAQHPAmHKbwWwDizOK3XsxsLAySg2tLAyvdt1ihBPbjOb9fW1qPMB1OrtnMqYalyRoKmusTqnmwtoYrnSvdBr(tEhhKmHKbgoQ9TOfTiVcEY3zrFJAFl6BKxo2I6ipd7HHip0cNduXRJwu7lJ(g5LJTOoYJnqCg9ip0cNduXRJwuB2h9nYdTW5av86ipYlYJblYlhBrDKNMqwHZbrEAI7drEObswEbcKbDnmxJhAXOgujohakCnuDn(9AYVgMQ5YAO6AWEGZLOlydQHTipnHKArhI8qdKS8seid60bPZTnOIwu7Ce9nYdTW5av86ipYlYJblYlhBrDKNMqwHZbrEAI7drESh4CjtizGHdpPtOxIHEPb4AUOMlJ80esQfDiYJ3oZbjtizGfTO25m6BKhAHZbQ41r(dznGSsKhBG4m6GkqqzFiYlhBrDK)ioxso2I6KBXwK3Tyl1Ioe5XgioJoOIwu7Rk6BKhAHZbQ41r(dznGSsKNPA8VgtCqBbDbBajjySGXBhGw4CGQgnAQrHSqMqiidc2Eyy7SAylYlhBrDK)ioxso2I6KBXwK3Tyl1Ioe5pkC0IA73J(g5Hw4CGkEDKxo2I6i)rCUKCSf1j3ITiVBXwQfDiYRqw0IAZoJ(g5Hw4CGkEDK)qwdiRe55(Vxa72dKKwLu7bceqx2gxZf1ycjdSGT6qYqj1c1WQgU)7fWU9ajPvj1EGab0LTX1CrnmvZTAyUMdsNdL8qBB4AyRgQUMBb2zKxo2I6ip2ThijTkP2deTO2(5OVrEOfohOIxh5LJTOoYFeNljhBrDYTylY7wSLArhI8QLahlArTVrLOVrEOfohOIxh5pK1aYkrEObswEbf82ZA1WiLAULZAyUgAczfoheGgiz5Liqg0PdsNBBqf5LJTOoYlKJ0qYqec0w0IAF7w03iVCSf1rEHCKgsEFhgI8qlCoqfVoArTVDz03iVCSf1rE3Mr3Wj)qFvMo0wKhAHZbQ41rlQ9n2h9nYlhBrDKNtYsOxYi7HbCKhAHZbQ41rlArEpcCq6CIf9nQ9TOVrE5ylQJ8INNlVKhAXOoYdTW5av86Of1(YOVrEOfohOIxh5LJTOoYRlegav6Hijfig9i)HSgqwjYtKvLaAqBbrPWHTRHXAULZiVhboiDoXsy4GAfoYNZOf1M9rFJ8YXwuh5XgioJEKhAHZbQ41rlQDoI(g5Hw4CGkEDKxo2I6ip2ThijTkP2de5pK1aYkrEc8iaMUW5GiVhboiDoXsy4GAfoYFlArTZz03ip0cNduXRJ8TOdrE5EmDHi40d1wc9sEOCbsKxo2I6iVCpMUqeC6HAlHEjpuUajArTVQOVrEOfohOIxh5pK1aYkrEtCqBbWhS0z)TfdcqlCoqf5LJTOoYN9fIALoHEj5EGGm6rlArE1sGJf9nQ9TOVrEOfohOIxh5pK1aYkrEMQ5G05qjp02gUggPutoQH5AmXbTfua4bKe2iIjzGEaAHZbQA0OPMdsNdL8qBB4AOuJ0RUCOlKmqLoE1WwnSQHPAua3)9c0GwbMjHVxnA0uJc4(VxatFPf(E1OrtnqdKS8ck4TN1Q5ck1CzoRH5AOjKv4CqaAGKLxIazqNoiDUTbvnA0uJ)1qtiRW5GaE7mhKmHKbwnSvdRAyQg)RXeh0wa8blD2FBXGa0cNdu1OrtnheYPq52bWhS0z)Tfdceqx2gxdJ1CznSf5LJTOoYdnnOr6rlQ9LrFJ8qlCoqfVoYJ8I8yWI8YXwuh5PjKv4CqKNM4(qK)G05qjp02goOG3EwRggR5wnA0ud0ajlVGcE7zTAUGsnxMZAyUgAczfoheGgiz5Liqg0PdsNBBqvJgn14Fn0eYkCoiG3oZbjtizGf5PjKul6qK)JH0BDoGeTO2Sp6BKhAHZbQ41rE5ylQJ8yGqedujoudjS3Yae5pK1aYkrEU)7fWU9ajPvj1EGW3Rgw14FnkKfWaHigOsCOgsyVLbiPqwW2ddBNvJgn182m6wIa6Y24AUGsn5SgnAQ5Gqofk3oGbcrmqL4qnKWEldq4qxizao9iYXwulUAyKsnxg875SgnAQbJ(oUTvbhiQexEjWhr3ZbbOfohOQHvn(xd3)9coqujU8sGpIUNdcFVi)jVJdsMqYadh1(w0IANJOVrEOfohOIxh5pK1aYkrEAczfohe(yi9wNdi1WQg5EGSgeGdD02zjoNOaCaAHZbQAyvd2dCUKjKmWWHN0j0lXqV0aCnmsPMlRH5AyQgfW9FVanOvGzs47vdvxdt1CRgMRHPAK7bYAqao0rBNL4CIcWbI0mudLAUvdB1WwnSf5LJTOoY)KoHEjg6LgGJwu7Cg9nYdTW5av86i)HSgqwjYttiRW5GWhdP36CaPgw1WunC)3lqFvkOtCorb4a2Kdd1WiLAU5NRrJMAyQg)RXJSiYA5LiitSf11WQgSh4CjtizGHdpPtOxIHEPb4AyKsn5OgMRHPAK7bYAqqH(CoiPqyiqKMHAySMlRHTAyUgSbIZOdQabL9HAyRg2I8YXwuh5FsNqVed9sdWrlQ9vf9nYdTW5av86iVCSf1r(N0j0lXqV0aCK)qwdiRe5PjKv4Cq4JH0BDoGudRAWEGZLmHKbgo8KoHEjg6LgGRHrk1W(i)jVJdsMqYadh1(w0IA73J(g5Hw4CGkEDK)qwdiRe5PjKv4Cq4JH0BDoGe5LJTOoYdh6OTZseWJS6sRIwuB2z03ip0cNduXRJ8hYAazLipnHScNdcFmKERZbKiVCSf1rErN7JPhTO2(5OVrEOfohOIxh5LJTOoYR)T1jge5pK1aYkrEAczfohe(yi9wNdi1WQgSh4CjtizGHdpPtOxIHEPb4AOuZLr(tEhhKmHKbgoQ9TOf1(gvI(g5Hw4CGkEDK)qwdiRe5PjKv4Cq4JH0BDoGe5LJTOoYR)T1jgeTOf5pkC03O23I(g5Hw4CGkEDKxo2I6iVCpMUqeC6HAlHEjpuUajYFiRbKvI8(xd2aXz0bvqCUAyvJUGnGKemwW4Tteqx2gxdLAOsnSQHPAoiKtHYTd0GwbMjbcOlBJR5c)W1WunheYPq52bm9LwGa6Y24AO6Aa)4F98avqW0PjnGte5EejDqeXvdB1WwnxuZnQudZ1CJk1q11a(X)65bQGGPttAaNiY9is6GiIRgw14FnkG7)EbAqRaZKW3Rgw14FnkG7)Ebm9Lw47f5BrhI8Y9y6crWPhQTe6L8q5cKOf1(YOVrEOfohOIxh5pK1aYkrE)RbBG4m6GkioxnSQrHSa57zFceS9WW2z1WQgDbBajjySGXBNiGUSnUgk1qLiVCSf1r(J4Cj5ylQtUfBrE3ITul6qKhWyOpaoArTzF03ip0cNduXRJ8YXwuh51fcdGk9qKKceJEK)qwdiRe5jYQsanOTGOu4W3Rgw1WunMqYalyRoKmusTqnxuZbPZHsEOTnCqbV9SwnuDn3c5SgnAQ5G05qjp02goOG3EwRggPuZXlPl(KWEqRQHTi)jVJdsMqYadh1(w0IANJOVrEOfohOIxh5pK1aYkrEISQeqdAlikfoSDnmwd7PsnSBnezvjGg0wqukCq9jITOUgw1Cq6COKhABdhuWBpRvdJuQ54L0fFsypOvrE5ylQJ86cHbqLEissbIrpArTZz03iVCSf1r(NtYaNtSf1rEOfohOIxhTO2xv03ip0cNduXRJ8hYAazLiVc4(Vx45KmW5eBrDGa6Y24AUOMlJ8YXwuh5FojdCoXwuNooqAmeTO2(9OVrEOfohOIxh5rErEmyrE5ylQJ80eYkCoiYttCFiY7FnM4G2c4pNbK3pdcqlCoqvJgn14FnY9azniGPtqFfOs4)7HoITOoaTW5avnA0uJczHmHqqge80)oB9ClqQHXAUvdRAyQgSh4CjtizGHdpPtOxIHEPb4AUOMRQgnAQX)AoiKtHYTd0KEX0dFVAylYttiPw0HipnOvGzsc)5mG8(zq6GA1AlQJwuB2z03ip0cNduXRJ8iVipgSiVCSf1rEAczfohe5PjUpe59VgtCqBHEZOBytCmaKa0cNdu1Ortn(xJjoOTa4dw6S)2IbbOfohOQrJMAoiKtHYTdGpyPZ(BlgeiGUSnUMlQjN1WU1CznuDnM4G2cka8ascBeXKmqpaTW5avKNMqsTOdrEAqRaZKuVz0nSjogas6GA1AlQJwuB)C03ip0cNduXRJ8iVipgSiVCSf1rEAczfohe5PjUpe59VgWp(xppqfK7X0fIGtpuBj0l5HYfi1OrtnY9azniGPtqFfOs4)7HoITOoaTW5avnA0uJc4(VxGi3JiPdIiUKc4(VxqHYTRrJMAoiKtHYTdcMonPbCIi3JiPdIiUab0LTX1Crn3OsnSQHPAoiKtHYTdy6lTab0LTX1Crn3QrJMAua3)9cy6lTW3Rg2I80esQfDiYtdAfyMKEO2shuRwBrD0IAFJkrFJ8qlCoqfVoYFiRbKvI8(xd2aXz0bvGGY(qnSQrHSa57zFceS9WW2z1WQg)RrbC)3lqdAfyMe(E1WQgAczfoheObTcmts4pNbK3pdshuRwBrDnSQHMqwHZbbAqRaZKuVz0nSjogas6GA1AlQRHvn0eYkCoiqdAfyMKEO2shuRwBrDKxo2I6ipnOvGzs0IAF7w03ip0cNduXRJ8hYAazLiVjoOTa4dw6S)2IbbOfohOQHvnM4G2c9Mr3WM4yaibOfohOQHvnhKohk5H22W1WiLAoEjDXNe2dAvnSQ5Gqofk3oa(GLo7VTyqGa6Y24AUOMBrE5ylQJ80KEX0Jwu7Bxg9nYdTW5av86i)HSgqwjYBIdAl0BgDdBIJbGeGw4CGQgw14FnM4G2cGpyPZ(BlgeGw4CGQgw1Cq6COKhABdxdJuQ54L0fFsypOv1WQgMQrbC)3lqdAfyMe(E1Ortnagd9bc0w8I6e6L8aYdo2I6a0cNdu1WwKxo2I6ipnPxm9Of1(g7J(g5Hw4CGkEDKh5f5XGf5LJTOoYttiRW5GipnX9HiVCpqwdcy6e0xbQe()EOJylQdqlCoqvdRAyQMg1jmoX9FpqLmHKbgUggPuZTA0OPgSh4CjtizGHdpPtOxIHEPb4AOud7RHTAyvdt1GXjU)7bQKjKmWWjHdrdsEsRa99udLAOsnA0ud2dCUKjKmWWHN0j0lXqV0aCnmsPMRQg2I80esQfDiYJXjAsVy6PdQvRTOoArTVLJOVrEOfohOIxh5LJTOoY7HqUebWOp5arEWhJijrh9BlYNJCg5FisQbFSO23Iwu7B5m6BKhAHZbQ41r(dznGSsK3eh0wa)5mG8(zqaAHZbQAyvJ)1GnqCgDqfiOSpudRAoiKtHYTdzcHGmi89QHvnmvdnHScNdcyCIM0lME6GA1AlQRrJMA8Vg5EGSgeW0jOVcuj8)9qhXwuhGw4CGQgw1WunkKfYecbzqGapcGPlCoOgnAQrbC)3lqdAfyMe(E1WQgfYczcHGmi4P)D265wGuZfuQ5wnSvdB1WQMdsNdL8qBB4GcE7zTAyKsnmvdt1CRgMR5YAO6AK7bYAqatNG(kqLW)3dDeBrDaAHZbQAyRgQUgSh4CjtizGHdpPtOxIHEPb4AyRgg9dxtoQHvnezvjGg0wqukCy7AySMBxg5LJTOoYtt6ftpArTVDvrFJ8qlCoqfVoYFiRbKvI8mvJjoOTGUGnGKemwW4TdqlCoqvJgn1q(n8qKmiOlegsOxYOdjDbBajjySGXBha)4F98avnSvdRA8VgSbIZOdQG4C1WQgDbBajjySGXBNiGUSnUMlOudvQHvn(xJczbY3Z(eiqGhbW0fohudRAuilKjecYGab0LTX1WynSVgw1WunkG7)EbAqRaZKW3Rgw1OaU)7fW0xAHVxnSQHPA8VgaJH(abohcPsOxYOdjOb98c6IFiePgnAQrbC)3lW5qivc9sgDibnONx47vdB1Ortnagd9bc0w8I6e6L8aYdo2I6a0cNdu1WwKxo2I6ipnPxm9Of1(MFp6BKhAHZbQ41r(dznGSsK3)AWgioJoOcIZvdRAK7bYAqatNG(kqLW)3dDeBrDaAHZbQAyvJczHmHqqgeiWJay6cNdQHvnkKfYecbzqWt)7S1ZTaPMlOuZTAyvZbPZHsEOTnCqbV9SwnmsPMBrE5ylQJ8y6IcLRo4urlQ9n2z03ip0cNduXRJ8hYAazLiV)1GnqCgDqfiOSpudRAyQg)RrHSqMqiidce4ramDHZb1WQgfYcKVN9jqGa6Y24AySMCudZ1KJAO6AoEjDXNe2dAvnA0uJczbY3Z(eiqaDzBCnuDnujKZAySgtizGfSvhsgkPwOg2QHvnMqYalyRoKmusTqnmwtoI8YXwuh5bFWsN93wmiArTV5NJ(g5Hw4CGkEDK)qwdiRe5DanWvdJuQjNSZAyvJczbY3Z(eiy7HHTZQHvnmvJ)1a(X)65bQGCpMUqeC6HAlHEjpuUaPgnAQ5Gqofk3oqdAfyMeiGUSnUggR5gvQHTiVCSf1rEm9Lw0IAFjvI(g5Hw4CGkEDK)qwdiRe55(VxGZHqk3hBbcihRgnAQrbC)3lqdAfyMe(ErE5ylQJ8EiBrD0IAF5TOVrEOfohOIxh5pK1aYkrEfW9FVanOvGzs47f5LJTOoYZ5qiv69j5fTO2xEz03ip0cNduXRJ8hYAazLiVc4(VxGg0kWmj89I8YXwuh55acgimSDw0IAFj7J(g5Hw4CGkEDK)qwdiRe5va3)9c0GwbMjHVxKxo2I6i)BjaNdHurlQ9L5i6BKhAHZbQ41r(dznGSsKxbC)3lqdAfyMe(ErE5ylQJ8sFaSrex6iox0IAFzoJ(g5Hw4CGkEDKxo2I6iFM4GJ4CabN4qOoYFiRbKvI8mvJc4(VxGg0kWmj89QrJMAyQg)RXeh0wa8blD2FBXGa0cNdu1WQMdc5uOC7anOvGzsGa6Y24AySMCKZA0OPgtCqBbWhS0z)TfdcqlCoqvdRAyQMdc5uOC7a4dw6S)2IbbcOlBJR5IAUQA0OPMdc5uOC7a4dw6S)2IbbcOlBJRHXAUKk1WQM3Mr3seqx2gxdJ1Cv5Sg2QHTAyRgw14FnkG7)EbY3Z(eia(GLo7VTyGkY3Ioe5ZehCeNdi4ehc1rlQ9Lxv03ip0cNduXRJ8YXwuh5fmDAsd4erUhrsherCr(dznGSsKxbC)3lqK7rK0brexsbC)3lOq521OrtnMqYalyRoKmusTqnxuZLujY3Ioe5fmDAsd4erUhrsherCrlQ9L(9OVrEOfohOIxh5LJTOoYly60KgWjICpIKoiI4I8hYAazLipt14FnM4G2cGpyPZ(BlgeGw4CGQgnAQX)AmXbTfWFodiVFgeGw4CGQg2QHvnkG7)EbAqRaZKab0LTX1Wyn3OsnSBn5OgQUgWp(xppqfK7X0fIGtpuBj0l5HYfir(w0HiVGPttAaNiY9is6GiIlArTVKDg9nYdTW5av86iVCSf1rEbtNM0aorK7rK0brexK)qwdiRe5zQgtCqBbWhS0z)TfdcqlCoqvdRAmXbTfWFodiVFgeGw4CGQg2QHvnkG7)EbAqRaZKW3Rgw1WunkG7)EHmHqqgeaFWsN93wmqvJgn1i3dK1GaMob9vGkH)Vh6i2I6a0cNdu1WQgfYczcHGmi4P)D265wGudJ1CRg2I8TOdrEbtNM0aorK7rK0brex0IAFPFo6BKhAHZbQ41rE5ylQJ8N8ooKrq9EsCobBr(dznGSsKxxWgqscgly82jcOlBJRHsnuPgw14FnkG7)EbAqRaZKW3Rgw14FnkG7)Ebm9Lw47vdRA4(Vxqh0rK8sOxY9pRkPiGOJdkuUDnSQbAGKLxnxud7Kk1WQgfYcKVN9jqGa6Y24AySMCe5H3dowQfDiYFY74qgb17jX5eSfTO2SNkrFJ8qlCoqfVoYlhBrDK39jmaeCAB8Qw0hNY2Nf5pK1aYkrEfW9FVanOvGzs47f5BrhI8UpHbGGtBJx1I(4u2(SOf1M93I(g5Hw4CGkEDKxo2I6iV7Jnc6JtziNc6KN7RlzqK)qwdiRe5va3)9c0GwbMjHVxKVfDiY7(yJG(4ugYPGo55(6sgeTO2S)YOVrEOfohOIxh5LJTOoYN5e1kgIGt6GsCUf1r(dznGSsKxbC)3lqdAfyMe(ErE49GJLArhI8zorTIHi4KoOeNBrD0IAZE2h9nYdTW5av86iVCSf1r(mNOwXqeCItuzqK)qwdiRe5va3)9c0GwbMjHVxKhEp4yPw0HiFMtuRyicoXjQmiArTzFoI(g5LJTOoY)XqAnqhh5Hw4CGkED0IwKxHSOVrTVf9nYdTW5av86ipYlYJblYlhBrDKNMqwHZbrEAI7drEpYIiRLxIGmXwuxdRAWEGZLmHKbgo8KoHEjg6LgGRHXAyFnSQHPAuilKjecYGab0LTX1CrnheYPq52HmHqqgeuFIylQRrJMA8qlg1GkX5aqHRHXAYznSf5PjKul6qKhZW6Lo5DCqktieKbrlQ9LrFJ8qlCoqfVoYJ8I8yWI8YXwuh5PjKv4CqKNM4(qK3JSiYA5LiitSf11WQgSh4CjtizGHdpPtOxIHEPb4AySg2xdRAyQgfW9FVaM(sl89QrJMAyQgp0IrnOsCoau4AySMCwdRA8Vg5EGSgeWhOTe6L4CiKkaTW5avnSvdBrEAcj1Ioe5XmSEPtEhhKiFp7tGOf1M9rFJ8qlCoqfVoYJ8I8yWI8YXwuh5PjKv4CqKNM4(qKxbC)3lqdAfyMe(E1WQgMQrbC)3lGPV0cFVA0OPgDbBajjySGXBNiGUSnUggRHk1WwnSQrHSa57zFceiGUSnUggR5YipnHKArhI8ygwVe57zFceTO25i6BKhAHZbQ41r(dznGSsK3eh0wa8blD2FBXGa0cNdu1WQg)RrbC)3lKjecYGa4dw6S)2IbQAyvJczHmHqqge80)oB9ClqQ5ck1CRgw1CqiNcLBhaFWsN93wmiqaDzBCnxuZL1WQgSh4CjtizGHdpPtOxIHEPb4AOuZTAyvdrwvcObTfeLch2UggR5QQHvnkKfYecbzqGa6Y24AO6AOsiN1CrnMqYalyRoKmusTqKxo2I6iFMqiidIwu7Cg9nYdTW5av86i)HSgqwjYBIdAla(GLo7VTyqaAHZbQAyvdt1Cq6COKhABdxdJuQ54L0fFsypOv1WQMdc5uOC7a4dw6S)2IbbcOlBJR5IAUvdRAuilq(E2NabcOlBJRHQRHkHCwZf1ycjdSGT6qYqj1c1WwKxo2I6ip57zFceTO2xv03ip0cNduXRJ8pej1Gpwu7BrE5ylQJ8EiKlram6toq0IA73J(g5Hw4CGkEDK)qwdiRe5jWJay6cNdQHvnhKohk5H22Wbf82ZA1WiLAUvdZ1W(AO6AyQg5EGSgeW0jOVcuj8)9qhXwuhGw4CGQgw1CqiNcLBhOj9IPh(E1WwnSQHPA80)oB9ClqQ5ck1CRgnAQHa6Y24AUGsn2EyizRoudRAWEGZLmHKbgo8KoHEjg6LgGRHrk1W(AyUg5EGSgeW0jOVcuj8)9qhXwuhGw4CGQg2QHvnmvJ)1a(GLo7VTyGQgnAQHa6Y24AUGsn2EyizRoudvxZL1WQgSh4CjtizGHdpPtOxIHEPb4AyKsnSVgMRrUhiRbbmDc6Ravc)Fp0rSf1bOfohOQHTAyvJ)1GXjU)7bQAyvdt1ycjdSGT6qYqj1c1WU1qaDzBCnSvdJ1KJAyvdt1OlydijbJfmE7eb0LTX1qPgQuJgn14Fn2Eyy7SAyvJCpqwdcy6e0xbQe()EOJylQdqlCoqvdBrE5ylQJ8zcHGmiArTzNrFJ8qlCoqfVoY)qKud(yrTVf5LJTOoY7HqUebWOp5arlQTFo6BKhAHZbQ41rE5ylQJ8zcHGmiYFiRbKvI8(xdnHScNdcygwV0jVJdszcHGmOgw1qGhbW0fohudRAoiDouYdTTHdk4TN1QHrk1CRgMRH91q11WunY9azniGPtqFfOs4)7HoITOoaTW5avnSQ5Gqofk3oqt6ftp89QHTAyvdt14P)D265wGuZfuQ5wnA0udb0LTX1CbLAS9WqYwDOgw1G9aNlzcjdmC4jDc9sm0lnaxdJuQH91WCnY9azniGPtqFfOs4)7HoITOoaTW5avnSvdRAyQg)Rb8blD2FBXavnA0udb0LTX1CbLAS9WqYwDOgQUMlRHvnypW5sMqYadhEsNqVed9sdW1WiLAyFnmxJCpqwdcy6e0xbQe()EOJylQdqlCoqvdB1WQg)RbJtC)3du1WQgMQXesgybB1HKHsQfQHDRHa6Y24AyRggR52L1WQgMQrxWgqscgly82jcOlBJRHsnuPgnAQX)AS9WW2z1WQg5EGSgeW0jOVcuj8)9qhXwuhGw4CGQg2I8N8ooizcjdmCu7BrlQ9nQe9nYdTW5av86i)HSgqwjYJ9aNlzcjdmCnmsPMlRHvneqx2gxZf1Cznmxdt1G9aNlzcjdmCnmsPMCwdB1WQMdsNdL8qBB4AyKsn5iYlhBrDK)qwDmQtgO7bylArTVDl6BKhAHZbQ41r(dznGSsK3)AOjKv4CqaZW6LiFp7tGAyvdt1Cq6COKhABdxdJuQjh1WQgc8iaMUW5GA0OPg)RX2ddBNvdRAyQgB1HAySMBuPgnAQ5G05qjp02gUggPuZL1WwnSvdRAyQgp9VZwp3cKAUGsn3QrJMAiGUSnUMlOuJThgs2Qd1WQgSh4CjtizGHdpPtOxIHEPb4AyKsnSVgMRrUhiRbbmDc6Ravc)Fp0rSf1bOfohOQHTAyvdt14FnGpyPZ(BlgOQrJMAiGUSnUMlOuJThgs2Qd1q11CznSQb7boxYesgy4Wt6e6LyOxAaUggPud7RH5AK7bYAqatNG(kqLW)3dDeBrDaAHZbQAyRgw1ycjdSGT6qYqj1c1WU1qaDzBCnmwtoI8YXwuh5jFp7tGOf1(2LrFJ8qlCoqfVoYlhBrDKN89SpbI8hYAazLiV)1qtiRW5GaMH1lDY74Ge57zFcudRA8VgAczfoheWmSEjY3Z(eOgw1Cq6COKhABdxdJuQjh1WQgc8iaMUW5GAyvdt14P)D265wGuZfuQ5wnA0udb0LTX1CbLAS9WqYwDOgw1G9aNlzcjdmC4jDc9sm0lnaxdJuQH91WCnY9azniGPtqFfOs4)7HoITOoaTW5avnSvdRAyQg)Rb8blD2FBXavnA0udb0LTX1CbLAS9WqYwDOgQUMlRHvnypW5sMqYadhEsNqVed9sdW1WiLAyFnmxJCpqwdcy6e0xbQe()EOJylQdqlCoqvdB1WQgtizGfSvhsgkPwOg2TgcOlBJRHXAYrK)K3XbjtizGHJAFlArTVX(OVrEOfohOIxh5pK1aYkrESh4CjtizGHRHsn3QHvnhKohk5H22W1WiLAyQMJxsx8jH9Gwvd7wZTAyRgw1qGhbW0fohudRA8VgWhS0z)Tfdu1WQg)RrbC)3lGPV0cFVAyvJUGnGKemwW4Tteqx2gxdLAOsnSQX)AK7bYAqWYDXwYOdjg69bbOfohOQHvnMqYalyRoKmusTqnSBneqx2gxdJ1KJiVCSf1r(dz1XOozGUhGTOf1(woI(g5LJTOoYJbp8IJ8qlCoqfVoArlArEAabVOoQ9Lu5sQC7gvyFKpxH0BNHJ83v39DQn7O2xXRUMA8LouZQ7HiwnpePg)cWyOpa2VQHa(X)savnyKouJ8nKUyGQMdDPZaCOO(kVnuZLxDn3bQPbedu14xGpyPZ(BlgOcSd(vngQg)sbC)3lWoeaFWsN93wmq5x1W0nFyluuFL3gQjhxDn3bQPbedu1WV63rn48At8PM76Amunx5VuJAPT4f11G8aIyisnmLpB1W0L(WwOOUO(U6UVtTzh1(kE11uJV0HAwDpeXQ5Hi14xk4jFN5x1qa)4FjGQgmshQr(gsxmqvZHU0zaouuFL3gQH9xDn3bQPbedu1WV63rn48At8PM76Amunx5VuJAPT4f11G8aIyisnmLpB1W0nFyluuxuFxD33P2SJAFfV6AQXx6qnRUhIy18qKA8l1sGJ5x1qa)4FjGQgmshQr(gsxmqvZHU0zaouu7lDOMhY5q5UDwnYNi4AYfiqnFmOQz7Am6qnYXwuxJBXwnCFRMCbcutJSAEOFRQz7Am6qnIsH6AuIjCcgU6I6Ay3ACGOsC5LaFeDphuuxuFxD33P2SJAFfV6AQXx6qnRUhIy18qKA8RJc7x1qa)4FjGQgmshQr(gsxmqvZHU0zaouuFL3gQXpF11ChOMgqmqvJFzKTzaSa7q4Gqofk32VQXq14xheYPq52b2b)QgMU5dBHI6R82qnxMZRUM7a10aIbQA8lWhS0z)Tfdub2b)QgdvJFPaU)7fyhcGpyPZ(BlgO8RAy6MpSfkQVYBd1Cj78QR5oqnnGyGQg)c8blD2FBXavGDWVQXq14xkG7)Eb2Ha4dw6S)2Ibk)QgMU5dBHI6I67Q7(o1MDu7R4vxtn(shQz19qeRMhIuJFPqMFvdb8J)LaQAWiDOg5BiDXavnh6sNb4qr9vEBOMCC11ChOMgqmqvJFb(GLo7VTyGkWo4x1yOA8lfW9FVa7qa8blD2FBXaLFvdt38HTqrDrn7OUhIyGQg)EnYXwuxJBXgouuh59iO36GipvvZDJXcgVTylQR5orzFOOMQQrBenqNdi1C7Mw1CjvUKkf1f1uvn(jFGZ3avnCWdrGAoiDoXQHdY2ghQ5UphWZW10OMDPle933vJCSf14AqTlVqrTCSf14GhboiDoXOiEEU8sEOfJ6IA5ylQXbpcCq6CIXmL81fcdGk9qKKceJUwEe4G05elHHdQvyk5uR9rHiRkb0G2cIsHdBZ4TCwulhBrno4rGdsNtmMPKp2aXz0lQLJTOgh8iWbPZjgZuYh72dKKwLu7b0YJahKoNyjmCqTct5Mw7JcbEeatx4CqrTCSf14GhboiDoXyMs(FmKwd01QfDGICpMUqeC6HAlHEjpuUaPOwo2IACWJahKoNymtj)SVquR0j0lj3deKrxR9rXeh0wa8blD2FBXGa0cNduf1f1uvn(jFGZ3avnanGKxn2Qd1y0HAKJHi1S4AeAY6eohekQLJTOgtHH9WqrnvvZDcydeNrVM9vJhcJxohudtnQgAFxdeHZb1anOVaUMTR5G05eJTIA5ylQXmtjFSbIZOxulhBrnMzk5ttiRW5aTArhOanqYYlrGmOthKo32GslAI7duGgiz5fiqg0m7HwmQbvIZbGct1(97AMUKQXEGZLOlydyROwo2IAmZuYNMqwHZbA1IoqbVDMdsMqYatlAI7duWEGZLmHKbgo8KoHEjg6LgGV4YIA5ylQXmtj)J4Cj5ylQtUfBA1IoqbBG4m6GsR9rbBG4m6GkqqzFOOwo2IAmZuY)ioxso2I6KBXMwTOduokSw7Jct(BIdAlOlydijbJfmE7a0cNduA0OqwitieKbbBpmSDgBf1YXwuJzMs(hX5sYXwuNCl20QfDGIczf1YXwuJzMs(y3EGK0QKApGw7Jc3)9cy3EGK0QKApqGa6Y24lmHKbwWwDizOKAbwC)3lGD7bssRsQ9abcOlBJVGPBmFq6COKhABdZgvFlWolQLJTOgZmL8pIZLKJTOo5wSPvl6af1sGJvulhBrnMzk5lKJ0qYqec0Mw7Jc0ajlVGcE7zngPClNmttiRW5Ga0ajlVebYGoDq6CBdQIA5ylQXmtjFHCKgsEFhgkQLJTOgZmL8DBgDdN8d9vz6qBf1YXwuJzMs(Cswc9sgzpmGlQlQPQAUdeYPq524IA5ylQXHJct5JH0AGUwTOduK7X0fIGtpuBj0l5HYfiATpk(JnqCgDqfeNJLUGnGKemwW4Tteqx2gtHkSy6Gqofk3oqdAfyMeiGUSn(c)WmDqiNcLBhW0xAbcOlBJPAWp(xppqfemDAsd4erUhrsherCSX2f3OcZ3Ocvd(X)65bQGGPttAaNiY9is6GiIJL)kG7)EbAqRaZKW3JL)kG7)Ebm9Lw47vulhBrnoCuyMPK)rCUKCSf1j3InTArhOaym0haR1(O4p2aXz0bvqCowkKfiFp7tGGThg2oJLUGnGKemwW4Tteqx2gtHkf1uvnSJVAeLcxJqGA(EAvdUxpOgJoudQHAYDn614q5cyRgF99UeQXpimutU0HUgvEBNvZtWgqQXOlDn3XvQgf82ZA1Gi1K7A0rFRgPZRM74kfkQLJTOghokmZuYxximaQ0drskqm6ADY74GKjKmWWuUP1(OqKvLaAqBbrPWHVhlMmHKbwWwDizOKAHloiDouYdTTHdk4TN1O6BHCQrZbPZHsEOTnCqbV9SgJuoEjDXNe2dAfBf1uvnSJVAAunIsHRj315QrTqn5Ug9TRXOd10GpwnSNkyTQ5JHA8BE3LAqDnCimUMCxJo6B1iDE1ChxPqrTCSf14WrHzMs(6cHbqLEissbIrxR9rHiRkb0G2cIsHdBZi7Pc7sKvLaAqBbrPWb1Ni2IAwhKohk5H22Wbf82ZAms54L0fFsypOvf1YXwuJdhfMzk5)Csg4CITOUOwo2IAC4OWmtj)NtYaNtSf1PJdKgdATpkkG7)EHNtYaNtSf1bcOlBJV4YIAQQMRa0kWmPghkBpIRMdQvRTOwC4A4emOQb11C(ec0wnyp4uulhBrnoCuyMPKpnHScNd0QfDGcnOvGzsc)5mG8(zq6GA1AlQ1IM4(af)nXbTfWFodiVFgeGw4CGsJg)L7bYAqatNG(kqLW)3dDeBrDaAHZbknAuilKjecYGGN(3zRNBbcJ3yXe2dCUKjKmWWHN0j0lXqV0a8fxLgn(FqiNcLBhOj9IPh(ESvulhBrnoCuyMPKpnHScNd0QfDGcnOvGzsQ3m6g2ehdajDqTATf1ArtCFGI)M4G2c9Mr3WM4yaibOfohO0OXFtCqBbWhS0z)TfdcqlCoqPrZbHCkuUDa8blD2FBXGab0LTXxKt29sQ2eh0wqbGhqsyJiMKb6bOfohOkQLJTOghokmZuYNMqwHZbA1IoqHMqwHZbA1IoqHg0kWmj9qTLoOwT2IATOjUpqXFWp(xppqfK7X0fIGtpuBj0l5HYfiA0i3dK1GaMob9vGkH)Vh6i2I6a0cNduA0OaU)7fiY9is6GiIlPaU)7fuOCBnAmY2mawqW0PjnGte5EejDqeXfoiKtHYTdeqx2gFXnQWIPdc5uOC7aM(slqaDzB8f30OrbC)3lGPV0cFp2kQLJTOghokmZuYNg0kWmrR9rXFSbIZOdQabL9bwkKfiFp7tGGThg2oJL)kG7)EbAqRaZKW3JfnHScNdc0GwbMjj8NZaY7NbPdQvRTOMfnHScNdc0GwbMjPEZOBytCmaK0b1Q1wuZIMqwHZbbAqRaZK0d1w6GA1AlQlQPQAUcsVy61K7A0RXp5doRgMRr7nJUHnXXaqU6A8BeFw9VEn3XvQgPv14N8bNvdbevE18qKAAWhRMR4DCxkQLJTOghokmZuYNM0lMUw7JIjoOTa4dw6S)2IbbOfohOyzIdAl0BgDdBIJbGeGw4CGI1bPZHsEOTnmJuoEjDXNe2dAfRdc5uOC7a4dw6S)2IbbcOlBJV4wrnvvZvq6ftVMCxJEnAVz0nSjogasnmxJ2OA8t(GZU6A8BeFw9VEn3XvQgPv1CfGwbMj189QHPF7amUMpE7SAUcOReBf1YXwuJdhfMzk5tt6ftxR9rXeh0wO3m6g2ehdajaTW5afl)nXbTfaFWsN93wmiaTW5afRdsNdL8qBBygPC8s6IpjSh0kwmPaU)7fObTcmtcFpnAamg6deOT4f1j0l5bKhCSf1bOfohOyROMQQHhGAEFNRMdsxhARguxdDZ8WxD(5NTg9px4G0Z)ofAqth5ug767DK)DIY(q(5UmS5F3ySGXBl2IA29UVsxz29obmiKd9qrTCSf14WrHzMs(0eYkCoqRw0bkyCIM0lME6GA1AlQ1IM4(af5EGSgeW0jOVcuj8)9qhXwuhGw4CGIftnQtyCI7)EGkzcjdmmJuUPrd2dCUKjKmWWHN0j0lXqV0amf2ZglMW4e3)9avYesgy4KWHObjpPvG(EOqfnAWEGZLmHKbgo8KoHEjg6LgGzKYvXwrTCSf14WrHzMs(EiKlram6toGwpej1GpgLBAb(yejj6OFBuYrolQLJTOghokmZuYNM0lMUw7JIjoOTa(Zza59ZGa0cNduS8hBG4m6GkqqzFG1bHCkuUDitieKbHVhlMOjKv4CqaJt0KEX0thuRwBrTgn(l3dK1GaMob9vGkH)Vh6i2I6a0cNduSysHSqMqiidce4ramDHZbA0OaU)7fObTcmtcFpwkKfYecbzqWt)7S1ZTa5ck3yJnwhKohk5H22Wbf82ZAmsHjMUX8LuTCpqwdcy6e0xbQe()EOJylQdqlCoqXgvJ9aNlzcjdmC4jDc9sm0lnaZgJ(HZblISQeqdAlikfoSnJ3USOMQQ5ki9IPxtURrVg)gbBaPM7gJf82xDnAJQbBG4m61iTQMgvJCSLguJFZDxd3)90QM787zFcutJSA2Ugc8iaMEnePZaTQr9jBNvZvaAfyMWSVxZ81iZpvdt)2byCnF82z1Cfqxj2kQLJTOghokmZuYNM0lMUw7JctM4G2c6c2assWybJ3oaTW5aLgnKFdpejdc6cHHe6Lm6qsxWgqscgly82bWp(xppqXgl)XgioJoOcIZXsxWgqscgly82jcOlBJVGcvy5VczbY3Z(eiqGhbW0fohWsHSqMqiidceqx2gZi7zXKc4(VxGg0kWmj89yPaU)7fW0xAHVhlM8hWyOpqGZHqQe6Lm6qcAqpVGU4hcr0OrbC)3lW5qivc9sgDibnONx47XMgnagd9bc0w8I6e6L8aYdo2I6a0cNduSvutv1WtxuOC1bNQMhIudpDc6Ravn8)3dDeBrDrTCSf14WrHzMs(y6IcLRo4uATpk(JnqCgDqfeNJLCpqwdcy6e0xbQe()EOJylQdqlCoqXsHSqMqiidce4ramDHZbSuilKjecYGGN(3zRNBbYfuUX6G05qjp02goOG3EwJrk3kQPQA8t(GLo7VTyqn5sh6AAKvd2aXz0bvnsRQHdz0R5o)E2Na1iTQMROqiidQriqnFVAEisnouNvd0OFg9qrTCSf14WrHzMs(GpyPZ(BlgO1(O4p2aXz0bvGGY(alM8xHSqMqiidce4ramDHZbSuilq(E2NabcOlBJzmhmNdQ(4L0fFsypOvA0OqwG89Spbceqx2gt1ujKtgnHKbwWwDizOKAb2yzcjdSGT6qYqj1cmMJIA5ylQXHJcZmL8X0xAATpkoGg4yKsozNSuilq(E2NabBpmSDglM8h8J)1Zdub5EmDHi40d1wc9sEOCbIgnheYPq52bAqRaZKab0LTXmEJkSvulhBrnoCuyMPKVhYwuR1(OW9FVaNdHuUp2ceqoMgnkG7)EbAqRaZKW3ROwo2IAC4OWmtjFohcPsVpjpT2hffW9FVanOvGzs47vulhBrnoCuyMPKphqWaHHTZ0AFuua3)9c0GwbMjHVxrTCSf14WrHzMs(VLaCoesP1(OOaU)7fObTcmtcFVIA5ylQXHJcZmL8L(ayJiU0rCoT2hffW9FVanOvGzs47vulhBrnoCuyMPK)hdP1aDTArhOKjo4iohqWjoeQ1AFuysbC)3lqdAfyMe(EA0WK)M4G2cGpyPZ(BlgeGw4CGI1bHCkuUDGg0kWmjqaDzBmJ5iNA0yIdAla(GLo7VTyqaAHZbkwmDqiNcLBhaFWsN93wmiqaDzB8fxLgnheYPq52bWhS0z)Tfdceqx2gZ4LuH1BZOBjcOlBJz8QYjBSXgl)bFWsN93wmqfiFp7tGIA5ylQXHJcZmL8)yiTgORvl6afbtNM0aorK7rK0breNw7JIc4(VxGi3JiPdIiUKc4(VxqHYT1OXesgybB1HKHsQfU4sQuulhBrnoCuyMPK)hdP1aDTArhOiy60KgWjICpIKoiI40AFuyYFtCqBbWhS0z)TfdcqlCoqPrJ)M4G2c4pNbK3pdcqlCoqXglfW9FVanOvGzsGa6Y2ygVrf2nhun4h)RNhOcY9y6crWPhQTe6L8q5cKIA5ylQXHJcZmL8)yiTgORvl6afbtNM0aorK7rK0breNw7JctM4G2cGpyPZ(BlgeGw4CGILjoOTa(Zza59ZGa0cNduSXsbC)3lqdAfyMe(ESyc8blD2FBXavitieKbA0i3dK1GaMob9vGkH)Vh6i2I6a0cNduSuilKjecYGGN(3zRNBbcJ3yROwo2IAC4OWmtj)pgsRb6AbVhCSul6aLtEhhYiOEpjoNGnT2hfDbBajjySGXBNiGUSnMcvy5Vc4(VxGg0kWmj89y5Vc4(VxatFPf(ES4(Vxqh0rK8sOxY9pRkPiGOJdkuUnlObswExWoPclfYcKVN9jqGa6Y2ygZrrTCSf14WrHzMs(FmKwd01QfDGI7tyai4024vTOpoLTptR9rrbC)3lqdAfyMe(Ef1YXwuJdhfMzk5)XqAnqxRw0bkUp2iOpoLHCkOtEUVUKbATpkkG7)EbAqRaZKW3ROwo2IAC4OWmtj)pgsRb6AbVhCSul6aLmNOwXqeCshuIZTOwR9rrbC)3lqdAfyMe(Ef1YXwuJdhfMzk5)XqAnqxl49GJLArhOK5e1kgIGtCIkd0AFuua3)9c0GwbMjHVxrnvvZDbEY3z18eNJtomuZdrQ5JfohuZAGo(QRXpimudQR5Gqofk3ouulhBrnoCuyMPK)hdP1aDCrDrnvvZDzjWXQrj6sguJWTU1waxutv14NAAqJ0RrSAYbZ1WuozUMCxJEn3fE2Q5oUsHAyh11b1kg4YRguxZLmxJjKmWWAvtURrVMRa0kWmrRAqKAYDn61471(bxdYOdKCxmutUYA18qKAWiDOgObswEHAUBhgvtUYA1SVA8t(GZQ5G05q1S4Aoi9TZQ57fkQLJTOghulbogfOPbnsxR9rHPdsNdL8qBBygPKdMnXbTfua4bKe2iIjzGEaAHZbknAoiDouYdTTHPi9Qlh6cjduPJhBSysbC)3lqdAfyMe(EA0OaU)7fW0xAHVNgnqdKS8ck4TN1UGYL5KzAczfoheGgiz5Liqg0PdsNBBqPrJ)0eYkCoiG3oZbjtizGXglM83eh0wa8blD2FBXGa0cNduA0CqiNcLBhaFWsN93wmiqaDzBmJxYwrTCSf14GAjWXyMs(0eYkCoqRw0bkFmKERZbeTOjUpq5G05qjp02goOG3EwJXBA0anqYYlOG3Ew7ckxMtMPjKv4CqaAGKLxIazqNoiDUTbLgn(ttiRW5GaE7mhKmHKbwrTCSf14GAjWXyMs(yGqedujoudjS3YaO1jVJdsMqYadt5Mw7Jc3)9cy3EGK0QKApq47XYFfYcyGqedujoudjS3YaKuily7HHTZ0O5Tz0Teb0LTXxqjNA0CqiNcLBhWaHigOsCOgsyVLbiCOlKmaNEe5ylQfhJuUm43ZPgny03XTTk4arL4Ylb(i6EoiaTW5afl)5(VxWbIkXLxc8r09Cq47vutv1CxTg9A8th6OTZQ5ANOaSw143s6AqVA8d0lnaxJy1CjZ1ycjdmSw1Gi1WE2nhmxJjKmWW1KlDOR5kaTcmtQzX189kQLJTOghulbogZuY)jDc9sm0lnaR1(OqtiRW5GWhdP36CaHLCpqwdcWHoA7SeNtuaoaTW5aflSh4CjtizGHdpPtOxIHEPbygPCjZmPaU)7fObTcmtcFpQMPBmZKCpqwdcWHoA7SeNtuaoqKMbk3yJn2kQPQA8BjDnOxn(b6LgGRrSAU5NzUgSjhgW1GE143EvkOR5ANOaCnisnsMSn2Qjhmxdt5K5AYDn61CxqFohuZDbHb2QXesgy4qrTCSf14GAjWXyMs(pPtOxIHEPbyT2hfAczfohe(yi9wNdiSyI7)Eb6RsbDIZjkahWMCyGrk38ZA0WK)EKfrwlVebzITOMf2dCUKjKmWWHN0j0lXqV0amJuYbZmj3dK1GGc95CqsHWqGindmEjBmJnqCgDqfiOSpWgBf1uvn(TKUg0Rg)a9sdW1yOAeppxE1Cxar5YRMReAXOUM9vZ2YXwAqnOUgPZRgtizGvJy1W(AmHKbgouulhBrnoOwcCmMPK)t6e6LyOxAawRtEhhKmHKbgMYnT2hfAczfohe(yi9wNdiSWEGZLmHKbgo8KoHEjg6LgGzKc7lQLJTOghulbogZuYho0rBNLiGhz1LwP1(OqtiRW5GWhdP36CaPOwo2IACqTe4ymtjFrN7JPR1(OqtiRW5GWhdP36CaPOMQQXxHJD9B(26edQXq1iEEU8Q5UaIYLxnxj0IrDnIvZL1ycjdmCrTCSf14GAjWXyMs(6FBDIbADY74GKjKmWWuUP1(OqtiRW5GWhdP36CaHf2dCUKjKmWWHN0j0lXqV0amLllQLJTOghulbogZuYx)BRtmqR9rHMqwHZbHpgsV15asrDrnvvZDr0LmOgenGuJT6qnc36wBbCrnvvZvE1xRMROqiidW1G6AAuZUEKvNiK8QXesgy4AEisngDOgpYIiRLxneKj2I6A2xn5K5A4CaOW1ieOgXrarLxnFVIA5ylQXbfYOqtiRW5aTArhOGzy9sN8ooiLjecYaTOjUpqXJSiYA5LiitSf1SWEGZLmHKbgo8KoHEjg6LgGzK9SysHSqMqiidceqx2gFXbHCkuUDitieKbb1Ni2IAnA8qlg1GkX5aqHzmNSvutv1CLx91Q5o)E2Na4AqDnnQzxpYQtesE1ycjdmCnpePgJouJhzrK1YRgcYeBrDn7RMCYCnCoau4AecuJ4iGOYRMVxrTCSf14GczmtjFAczfohOvl6afmdRx6K3XbjY3Z(eqlAI7du8ilISwEjcYeBrnlSh4CjtizGHdpPtOxIHEPbygzplMua3)9cy6lTW3tJgM8qlg1GkX5aqHzmNS8xUhiRbb8bAlHEjohcPcqlCoqXgBf1uvnx5vFTAUZVN9jaUM9vZvaAfyMWmp9Lw((nc2asn3ngly821S4A(E1iTQMCHAOl0GAUK5AWWb1kCno4z1G6Am6qn353Z(eOM7cY3IA5ylQXbfYyMs(0eYkCoqRw0bkygwVe57zFcOfnX9bkkG7)EbAqRaZKW3JftkG7)Ebm9Lw47PrJUGnGKemwW4Tteqx2gZivyJLczbY3Z(eiqaDzBmJxwutv1W7bNvC1CffcbzqnsRQ5o)E2Na1Gb77vJhzrKAmun(jFWsN93wmOMJGTIA5ylQXbfYyMs(zcHGmqR9rXeh0wa8blD2FBXGa0cNduS8h8blD2FBXavitieKbSuilKjecYGGN(3zRNBbYfuUX6Gqofk3oa(GLo7VTyqGa6Y24lUKf2dCUKjKmWWHN0j0lXqV0amLBSiYQsanOTGOu4W2mEvSuilKjecYGab0LTXunvc58ctizGfSvhsgkPwOOwo2IACqHmMPKp57zFcO1(OyIdAla(GLo7VTyqaAHZbkwmDq6COKhABdZiLJxsx8jH9GwX6Gqofk3oa(GLo7VTyqGa6Y24lUXsHSa57zFceiGUSnMQPsiNxycjdSGT6qYqj1cSvutv1CffcbzqnFpgaWtRAehgvJrwaxJHQ5JHAwRgbxJud2doR4QjdAGigIuZdrQXOd14eSvZDCLQHdEicuJuZB7fthif1YXwuJdkKXmL89qixIay0NCaTEisQbFmk3kQLJTOghuiJzk5NjecYaT2hfc8iaMUW5awhKohk5H22Wbf82ZAms5gZSNQzsUhiRbbmDc6Ravc)Fp0rSf1bOfohOyDqiNcLBhOj9IPh(ESXIjp9VZwp3cKlOCtJgcOlBJVGIThgs2QdSWEGZLmHKbgo8KoHEjg6LgGzKc7zwUhiRbbmDc6Ravc)Fp0rSf1bOfohOyJft(d(GLo7VTyGsJgcOlBJVGIThgs2Qdu9LSWEGZLmHKbgo8KoHEjg6LgGzKc7zwUhiRbbmDc6Ravc)Fp0rSf1bOfohOyJL)yCI7)EGIftMqYalyRoKmusTa7saDzBmBmMdwmPlydijbJfmE7eb0LTXuOIgn(B7HHTZyj3dK1GaMob9vGkH)Vh6i2I6a0cNduSvulhBrnoOqgZuY3dHCjcGrFYb06HiPg8XOCROwo2IACqHmMPKFMqiid06K3XbjtizGHPCtR9rXFAczfoheWmSEPtEhhKYecbzalc8iaMUW5awhKohk5H22Wbf82ZAms5gZSNQzsUhiRbbmDc6Ravc)Fp0rSf1bOfohOyDqiNcLBhOj9IPh(ESXIjp9VZwp3cKlOCtJgcOlBJVGIThgs2QdSWEGZLmHKbgo8KoHEjg6LgGzKc7zwUhiRbbmDc6Ravc)Fp0rSf1bOfohOyJft(d(GLo7VTyGsJgcOlBJVGIThgs2Qdu9LSWEGZLmHKbgo8KoHEjg6LgGzKc7zwUhiRbbmDc6Ravc)Fp0rSf1bOfohOyJL)yCI7)EGIftMqYalyRoKmusTa7saDzBmBmE7swmPlydijbJfmE7eb0LTXuOIgn(B7HHTZyj3dK1GaMob9vGkH)Vh6i2I6a0cNduSvutv1ChKvhJ6A8f09aSvdQRr)7S1Zb1ycjdmCnIvtoyUM74kvtU0HUgYV7TZQb9TA2UMlX1W03RgdvtoQXesgyy2QbrQH94AykNmxJjKmWWSvulhBrnoOqgZuY)qwDmQtgO7bytR9rb7boxYesgyygPCjlcOlBJV4sMzc7boxYesgyygPKt2yDq6COKhABdZiLCuutv14haaVA(E1CNFp7tGAeRMCWCnOUgX5QXesgy4Aykx6qxJBPTDwnouNvd0OFg9AKwvtJSAWT4HPJm2kQLJTOghuiJzk5t(E2NaATpk(ttiRW5GaMH1lr(E2NaSy6G05qjp02gMrk5GfbEeatx4CGgn(B7HHTZyXKT6aJ3OIgnhKohk5H22Wms5s2yJftE6FNTEUfixq5Mgneqx2gFbfBpmKSvhyH9aNlzcjdmC4jDc9sm0lnaZif2ZSCpqwdcy6e0xbQe()EOJylQdqlCoqXglM8h8blD2FBXaLgneqx2gFbfBpmKSvhO6lzH9aNlzcjdmC4jDc9sm0lnaZif2ZSCpqwdcy6e0xbQe()EOJylQdqlCoqXgltizGfSvhsgkPwGDjGUSnMXCuulhBrnoOqgZuYN89Spb06K3XbjtizGHPCtR9rXFAczfoheWmSEPtEhhKiFp7taw(ttiRW5GaMH1lr(E2NaSoiDouYdTTHzKsoyrGhbW0fohWIjp9VZwp3cKlOCtJgcOlBJVGIThgs2QdSWEGZLmHKbgo8KoHEjg6LgGzKc7zwUhiRbbmDc6Ravc)Fp0rSf1bOfohOyJft(d(GLo7VTyGsJgcOlBJVGIThgs2Qdu9LSWEGZLmHKbgo8KoHEjg6LgGzKc7zwUhiRbbmDc6Ravc)Fp0rSf1bOfohOyJLjKmWc2QdjdLulWUeqx2gZyokQPQAUdYQJrDn(c6Ea2Qb11W7Bn7RMTRXtAfOVNAKwvZA1K76C1Oq14amUgLOlzqngDPRXp10GgPxJ6d1yOA89689BU78918duulhBrnoOqgZuY)qwDmQtgO7bytR9rb7boxYesgyyk3yDq6COKhABdZifMoEjDXNe2dAf7EJnwe4ramDHZbS8h8blD2FBXafl)va3)9cy6lTW3JLUGnGKemwW4Tteqx2gtHkS8xUhiRbbl3fBjJoKyO3heGw4CGILjKmWc2QdjdLulWUeqx2gZyokQLJTOghuiJzk5Jbp8IlQlQPQA8tym0haxulhBrnoaym0hat5G6d0grmqLEorh0AFuGgiz5fSvhsgkPl(W4nw(RaU)7fObTcmtcFpwm5VczHdQpqBeXav65eDiX9jDW2ddBNXYF5ylQdhuFG2iIbQ0Zj6qy70ZTz0nnAEFNlrGdDHKbjB1HlYoQGU4dBf1uvn3TlxjpCnFmuZ1oesvtURrVMRa0kWmPMVxOg)2iNQMhIuJFYhS0z)Tfdc14hegQj31OxJVxxZ3Rgo4HiqnsnVTxmDGuJGRXH6SAeCnRvd534AEisn3OcUg1NSDwnxbOvGzsOOwo2IACaWyOpaMzk5Z5qivc9sgDibnONNw7JIc4(VxGg0kWmj89yXe4dw6S)2IbQqMqiid0OrbC)3lGPV0cFpwhKohk5H22Wbf82ZAxq5MgnkG7)EbAqRaZKab0LTXxq5gvytJM3Mr3seqx2gFbLBuPOMQQ5Und09SAmunIBZ6AUIFHOwPRj31OxZvaAfyMuJGRXH6SAeCnRvtUO2VSAia(7SA2UghcVDwnsnVVZXU0e3hQ5iyRgenGuJrhQHa6Y2BNvJ6teBrDnOxngDOM3Mr3kQLJTOghamg6dGzMs(zFHOwPtOxsUhiiJUw7JYbHCkuUDGg0kWmjqaDzB8fSxJgfW9FVanOvGzs47PrZBZOBjcOlBJVG9uPOwo2IACaWyOpaMzk5N9fIALoHEj5EGGm6ATpkphcryIP3Mr3seqx2gZUSNkSDxFqiNcLBZgJphcryIP3Mr3seqx2gZUSNkS7bHCkuUDGg0kWmjqaDzBmB31heYPq52SvulhBrnoaym0haZmL8FOZhdQKCpqwdsCGOR1(OG9aNlzcjdmC4jDc9sm0lnaZiLl1OHiRkb0G2cIsHdBZ4vrfwqdKS8UWVtLIA5ylQXbaJH(ayMPKV3NSV82olX5eSP1(OG9aNlzcjdmC4jDc9sm0lnaZiLl1OHiRkb0G2cIsHdBZ4vrLIA5ylQXbaJH(ayMPKVrhs)Md9Bv6HihqR9rH7)EbcCyWbyC6Hihi890OH7)EbcCyWbyC6HihiDq)2asaBYHHlUrLIA5ylQXbaJH(ayMPKpz98CqA7e2toqrTCSf14aGXqFamZuYpxeXPObBNiag1sFGIA5ylQXbaJH(ayMPKVoOJi5LqVK7FwvsrarhR1(OanqYY7ICsfw(FqiNcLBhObTcmtcFVIAQQg)2iNQM7eeVTZQXVLt0bCnpePgWh48nOgI0zqnisnmSoxnC)3dRvn7RgpegVCoiuZD7YvYdxJrYRgdvtgy1y0HACOCbSvZbHCkuUDnCcgu1G6AeAY6eohud0G(c4qrTCSf14aGXqFamZuYNaI32zPNt0bSwN8ooizcjdmmLBATpkMqYalyRoKmusTWf3c5uJgMyYesgyb6G4m6bVJXi7KkA0ycjdSaDqCg9G3XUGYLuHnwmjhBPbjOb9fWuUPrJjKmWc2QdjdLulW4L(z2ytJgMmHKbwWwDizOK3XsxsfgzpvyXKCSLgKGg0xat5MgnMqYalyRoKmusTaJ5ihSXwrDrnvvdVbIZOdQAU7JTOgxutv1O9MrhBIJbGudQR5MVxDn8T4HPJSAUZVN9jqrTCSf14a2aXz0bffY3Z(eqR9rXeh0wO3m6g2ehdajaTW5afRdsNdL8qBBygPKdwMqYalyRoKmusTa7saDzBmJxvrnvvd)NZaY7Nb1WCn80jOVcu1W)Fp0rSf1xDn(Pg)jqn5c18XqnOgQjZH4exngQgXZZLxnxrHqqguJHQXOd1OlBxJjKmWQzF1SwnlUMgz1GBXdthz1KhyAvdgvJ4C1Gm6aPgDz7AmHKbwnc36wBbCnEe0BTqrTCSf14a2aXz0bfZuY3dHCjcGrFYb06HiPg8XOCROwo2IACaBG4m6GIzk5NjecYaT2hf5EGSgeW0jOVcuj8)9qhXwuhGw4CGIf3)9c4pNbK3pdcFpwC)3lG)CgqE)miqaDzB8f3cSNL)yCI7)EGQOMQQH)Zza59ZGRUM72ZZLxnisn3j8iaMEn5Ug9A4(VhOQ5kkecYaCrTCSf14a2aXz0bfZuY3dHCjcGrFYb06HiPg8XOCROwo2IACaBG4m6GIzk5NjecYaTo5DCqYesgyyk30AFumXbTfWFodiVFgeGw4CGIfteqx2gFXTl1OXt)7S1ZTa5ck3yJLjKmWc2QdjdLulWUeqx2gZ4Lf1uvn8FodiVFgudZ1WtNG(kqvd))9qhXwuxZ21W77vxZD755YRgqiU8Q5o)E2Na1y0fRMCxNRgoOgc8iaMoOQ5Hi14jTc03trTCSf14a2aXz0bfZuYN89Spb0AFumXbTfWFodiVFgeGw4CGILCpqwdcy6e0xbQe()EOJylQdqlCoqXYFfYcKVN9jqW2ddBNXIMqwHZbb82zoizcjdSIAQQg(pNbK3pdQj38RHNob9vGQg()7HoITO(QR5obXZZLxnpePgou)X1ChxPAKwLpIud4JbTcu1GBXdthz1O(eXwuhkQLJTOghWgioJoOyMs(EiKlram6toGwpej1GpgLBf1YXwuJdydeNrhumtj)mHqqgO1jVJdsMqYadt5Mw7JIjoOTa(Zza59ZGa0cNduSK7bYAqatNG(kqLW)3dDeBrDaAHZbkwmjhBPbjOb9fWmEtJg)nXbTfaFWsN93wmiaTW5afBSmHKbwWwDizOKAbgjGUSnMfteqx2gFXn2Pgn(JXjU)7bk2kQPQA4)CgqE)mOgMRXp5doRguxZnFV6AUt4ram9AUIcHGmOgXQXOd1aTQg0RgSbIZOxJHQjdSA0fFQr9jITOUgo4Hiqn(jFWsN93wmOOwo2IACaBG4m6GIzk57HqUebWOp5aA9qKud(yuUvulhBrnoGnqCgDqXmL8ZecbzGw7JIjoOTa(Zza59ZGa0cNduSmXbTfaFWsN93wmiaTW5afl5ylnibnOVaMYnwC)3lG)CgqE)miqaDzB8f3cSpYJ9Gtu7lZPFoArlgb]] )

end