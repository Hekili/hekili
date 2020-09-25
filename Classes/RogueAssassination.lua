-- RogueAssassination.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local IterateTargets, ActorHasDebuff = ns.iterateTargets, ns.actorHasDebuff


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

            spend = 40,
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

            spend = 30,
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

            spend = 30,
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

            spend = 35,
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
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = 25,
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

            spend = 35,
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
                return 30
            end,
            recharge = function ()
                if pvptalent.intent_to_kill.enabled and debuff.vendetta.up then return 10 end
                return 30
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
            end,
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


    spec:RegisterPack( "Assassination", 20200924, [[de1TgcqirPEesbxcPiytOKpPskgfkLtHIAvif6viLMfLKBHsf7sOFjQ0WuPYXuPSmvIEgkvnnrrDnrfTnvsPVjQaJdLk15qPswhsr17efH08ev19qI9Hc9prrQCqKIYcvj8qKI0evjvCrrr0gffH6JQKknsrrioPOiLvIcEjsrOzkkcUPOiPDsj1qfvilvLu1trvtvu4QIIu1wfvO(QOirJfPiAVu1FfzWkDyslgvESkMmfxgSzv5ZuPrJuDAfRwuKWRrrMTGBtP2Tu)gQHtfhxubTCephY0jUUQA7iPVlQY4fLCEvswVkvnFkX(LS)MpdpVrfWB9L3D5D3XUUmZXB3y)D5mh45LRCapVJEysDbpFR2GNNMHqkcnTkdU98o6vbSA8z45r4p5aEE6I4GO55MR7i0)CXd2ox0y)dQm4(q0NKlASp5655(tqY0ApNN3Oc4T(Y7U8U7yxxM54TBS)UmZEpV(f6yINNFSPPEE6JXaTNZZBa0XZtd1sZqifHMwLb31E9y3pumqd1YdocyZbKAVmZwv7L3D5DE(WGeKpdppsani0bJpdV138z45Hw5cGXFHN)qgbiJ65fnaTe7XLUGenWeqIqRCbWulRApyBoCYbpTGQLrk1M5AzvROexqIYydjbNmdul7ulbS1Pr1YyTxRNxpYGBpp57iFc4fV1x6ZWZdTYfaJ)cp)dtsnKL4T(MNxpYGBpVdghseaH)Kd4fV1S3NHNhALlag)fE(dzeGmQNxVhiJareDc(Batc9Fp8rLb3rOvUayQLvTC)3lI(CcqEFxi(DQLvTC)3lI(CcqEFxisaBDAuT5x7Ti7RLvTzxlcL4(Vhy886rgC75DvcblGx8wNzFgEEOvUay8x45FysQHSeV13886rgC75DW4qIai8NCaV4ToN(m88qRCbW4VWZRhzWTN3vjeSaE(dzeGmQNx0a0se95eG8(UqeALlaMAzvlB1saBDAuT5x7TlR1ILADS)bzCcdqQnFk1ERwMRLvTIsCbjkJnKeCYmqTStTeWwNgvlJ1EPN)C1jajrjUGG8wFZlERVwFgEEOvUay8x45pKraYOEErdqlr0NtaY77crOvUayQLvT69azeiIOtWFdysO)7HpQm4ocTYfatTSQn7Anyjs(oYNarzomnTBTSQLQsgLlar00UbijkXfepVEKb3EEY3r(eWlERZb(m88qRCbW4VWZ)WKudzjERV551Jm42Z7GXHebq4p5aEXBn72NHNhALlag)fEE9idU98UkHGfWZFiJaKr98IgGwIOpNaK33fIqRCbWulRA17bYiqerNG)gWKq)3dFuzWDeALlaMAzvlB1QhzOcjOb7bq1YyT3Q1ILAZUwrdqlrilK2U)PvbIqRCbWulZ1YQwrjUGeLXgscozgOwgRLa260OAzvlB1saBDAuT5x7n2DTwSuB21IqjU)7bMAz2ZFU6eGKOexqqERV5fV1SlFgEEOvUay8x45FysQHSeV13886rgC75DW4qIai8NCaV4T(2D(m88qRCbW4VWZFiJaKr98IgGwIOpNaK33fIqRCbWulRAfnaTeHSqA7(NwficTYfatTSQvpYqfsqd2dGQLsT3QLvTC)3lI(CcqEFxisaBDAuT5x7Ti7986rgC75DvcblGx8INhqiOpaYNH36B(m88qRCbW4VWZFiJaKr98qde3RIYydjbNS1SQLXAVvlRAZUwdW9FVivOnGiA87ulRAzR2SR1GL4b3hOfIkGj9cQnK4(KokZHPPDRLvTzxREKb3XdUpqlevat6fuBioD6fgx6sTwSu77hcjcCORexijJnuB(16EmrBnRAz2ZRhzWTN)G7d0crfWKEb1g8I36l9z45Hw5cGXFHN)qgbiJ65na3)9IuH2aIOXVtTSQLTAna3)9IUkHGficzH029pTkGPwlwQ1aC)3lIOpuJFNAzv7bBZHto4Pfu0aV5msT5tP2B1AXsTgG7)ErQqBar0ibS1Pr1MpLAVDxTmxRfl1(gx6sIa260OAZNsT3UZZRhzWTNNlGXMe(Le6qcAW(kV4TM9(m88qRCbW4VWZFiJaKr98hmoyW51rQqBar0ibS1Pr1MFTSVwlwQ1aC)3lsfAdiIg)o1AXsTVXLUKiGTonQ28RL93551Jm42Z7(vIz0oHFj9EGGf6EXBDM9z45Hw5cGXFHN)qgbiJ65FbmMulB1YwTVXLUKiGTonQw2Pw2FxTmxlnHA1Jm4oDW4GbNxxlZ1YyTVagtQLTAzR234sxseWwNgvl7ul7VRw2P2dghm486ivOnGiAKa260OAzUwAc1QhzWD6GXbdoVUwM986rgC75D)kXmANWVKEpqWcDV4ToN(m88qRCbW4VWZFiJaKr98ihiesIsCbbfFANWVet9qfq1YiLAVSwlwQLOJjbuHwIQXGItxlJ1ET3vlRAHgiUxvB(1MdUZZRhzWTN)HpFeys69azeiXbQTx8wFT(m88qRCbW4VWZFiJaKr98ihiesIsCbbfFANWVet9qfq1YiLAVSwlwQLOJjbuHwIQXGItxlJ1ET3551Jm42Z78jZ7QPDtCbfjEXBDoWNHNhALlag)fE(dzeGmQNN7)ErcCykaiu6Hjhi(DQ1ILA5(VxKahMcacLEyYbsh8VfGerIEyQ28R92DEE9idU98cDi9Bo8VnPhMCaV4TMD7ZWZRhzWTNNmoobinDc5OhWZdTYfaJ)cV4TMD5ZWZRhzWTNppmjyOctNiac3AFapp0kxam(l8I36B35ZWZdTYfaJ)cp)Hmcqg1ZdnqCVQ28RnN3vlRAZU2dghm486ivOnGiA87451Jm42ZBd2yYvj8lf(NXKmeqTrEXB9TB(m88qRCbW4VWZRhzWTNNaQZ0UPxqTbKN)qgbiJ65fL4csugBij4KzGAZV2BXCwRfl1YwTSvROexqI0bni0JohPwgRLDFxTwSuROexqI0bni0JohP28Pu7L3vlZ1YQw2QvpYqfsqd2dGQLsT3Q1ILAfL4csugBij4KzGAzS2lzx1YCTmxRfl1YwTIsCbjkJnKeCY5iPlVRwgRL93vlRAzRw9idvibnypaQwk1ERwlwQvuIlirzSHKGtMbQLXAZCMRL5Az2ZFU6eGKOexqqERV5fV45nWt)bXNH36B(m886rgC75zAom55Hw5cGXFHx8wFPpdpVEKb3EEKaAqO75Hw5cGXFHx8wZEFgEEOvUay8x45XoEEeiEE9idU98uvYOCbWZtvdFWZdnqCVksaxORL2ADWdc3GjXfaWGQLgRnhulnHAzR2lRLgRf5aHqIUIeOwM98uvsQvBWZdnqCVkraxOthSn30GXlERZSpdpp0kxam(l88yhppcepVEKb3EEQkzuUa45PQHp45roqiKeL4cck(0oHFjM6HkGQn)AV0ZtvjPwTbppAA3aKeL4cIx8wNtFgEEOvUay8x45pKraYOEEKaAqOdMib7(bpVEKb3E(Jgcj9idUtHbjE(WGKuR2GNhjGge6GXlERVwFgEEOvUay8x45pKraYOEE2Qn7AfnaTeTvKaKKIqkcnDeALlaMATyPwdwIUkHGfikZHPPDRLzpVEKb3E(Jgcj9idUtHbjE(WGKuR2GN)yqEXBDoWNHNhALlag)fEE9idU98hnes6rgCNcds88HbjPwTbpVblEXBn72NHNhALlag)fE(dzeGmQNN7)EruyoqsBtYmhisaBDAuT5xROexqIYydjbNmdulRA5(VxefMdK02KmZbIeWwNgvB(1YwT3QL2ApyBoCYbpTGQL5APXAVfz3EE9idU98OWCGK2MKzoGx8wZU8z45Hw5cGXFHNxpYGBp)rdHKEKb3PWGepFyqsQvBWZBgcCeV4T(2D(m88qRCbW4VWZFiJaKr98qde3RIg4nNrQLrk1ElN1sBTuvYOCbicnqCVkraxOthSn30GXZRhzWTNxjhTHKGjeOfV4T(2nFgEE9idU98k5OnKC(be45Hw5cGXFHx8wF7sFgEE9idU98HXLUGszk(gxBOfpp0kxam(l8I36BS3NHNxpYGBppN6MWVKqMdtipp0kxam(l8Ix88oe4GT5uXNH36B(m886rgC75vhNWvjh8GWTNhALlag)fEXB9L(m88qRCbW4VWlERzVpdpp0kxam(l8I36m7ZWZdTYfaJ)cV4ToN(m88qRCbW4VWlERVwFgEE9idU98oyzWTNhALlag)fEXBDoWNHNhALlag)fEE9idU982kHjWKEysYaQq3ZFiJaKr98eDmjGk0sunguC6AzS2B50Z7qGd2MtLeco42G8850lERz3(m886rgC75rcObHUNhALlag)fEXBn7YNHNhALlag)fEE9idU98OWCGK2MKzoGN3HahSnNkjeCWTb55V5fV13UZNHNhALlag)fE(wTbpVEpIUsuu6HBjHFjhCEaXZRhzWTNxVhrxjkk9WTKWVKdopG4fV13U5ZWZdTYfaJ)cp)Hmcqg1ZlAaAjczH029pTkqeALlagpVEKb3EE3VsmJ2j8lP3deSq3lEXZBgcCeFgERV5ZWZdTYfaJ)cp)Hmcqg1ZZwThSnho5GNwq1YiLAZCT0wRObOLObahGKqcrf1fSJqRCbWuRfl1EW2C4KdEAbvlLA1ES1dDL4cM0XPwMRLvTSvRb4(VxKk0gqen(DQ1ILAna3)9Ii6d143PwlwQfAG4Ev0aV5msT5tP2lZzT0wlvLmkxaIqde3RseWf60bBZnnyQ1ILAZUwQkzuUaert7gGKOexqQL5AzvlB1MDTIgGwIqwiTD)tRceHw5cGPwlwQ9GXbdoVoczH029pTkqKa260OAzS2lRLzpVEKb3EEOPcn22lERV0NHNhALlag)fEESJNhbINxpYGBppvLmkxa88u1Wh88hSnho5GNwqrd8MZi1YyT3Q1ILAHgiUxfnWBoJuB(uQ9YCwlT1svjJYfGi0aX9QebCHoDW2CtdMATyP2SRLQsgLlar00UbijkXfeppvLKA1g88FeKEtiaeV4TM9(m88qRCbW4VWZRhzWTNhbeIkGjXHBiHCgMap)Hmcqg1ZNDTgSeraHOcysC4gsiNHjikZHPPDR1ILAPQKr5cq8JG0BcbGulRAzRw9idvibnypaQwk1ERww1s0XKaQqlr1yqXPRLXAF)qirGdDL4cjzSHATyP2dDL4cOAzS2lRLvTIsCbjkJnKeCYmqT5xBoRLzp)5QtasIsCbb5T(Mx8wNzFgEEOvUay8x45pKraYOEEQkzuUae)ii9Mqai1YQw9EGmceHdD80UjUGAaueALlaMAzvlYbcHKOexqqXN2j8lXupubuTmsP2lRL2AzRwdW9FVivOnGiA87ulnwlB1ERwARLTA17bYiqeo0Xt7M4cQbqrI2mvlLAVvlZ1YCTm751Jm42Z)0oHFjM6HkG8I36C6ZWZdTYfaJ)cp)Hmcqg1ZtvjJYfG4hbP3ecaPww1YwTC)3lsFmgOtCb1aOis0dt1YiLAVXUQ1ILAzR2SR1HmyYixLiyrLb31YQwKdecjrjUGGIpTt4xIPEOcOAzKsTzUwARLTA17bYiq0G)CbizWiis0MPAzS2lRL5APTwKaAqOdMib7(HAzUwM986rgC75FANWVet9qfqEXB916ZWZdTYfaJ)cpVEKb3E(N2j8lXupubKN)qgbiJ65PQKr5cq8JG0BcbGulRAroqiKeL4cck(0oHFjM6HkGQLrk1YEp)5QtasIsCbb5T(Mx8wNd8z45Hw5cGXFHN)qgbiJ65PQKr5cq8JG0BcbG451Jm42Zdh64PDteWHm2AB8I3A2Tpdpp0kxam(l88hYiazuppvLmkxaIFeKEtiaepVEKb3EE1M7JO7fV1SlFgEEOvUay8x451Jm42ZB)LjOc45pKraYOEEQkzuUae)ii9Mqai1YQwKdecjrjUGGIpTt4xIPEOcOAPu7LE(ZvNaKeL4ccYB9nV4T(2D(m88qRCbW4VWZFiJaKr98uvYOCbi(rq6nHaq886rgC75T)Yeub8Ix88hdYNH36B(m88qRCbW4VWZRhzWTNxVhrxjkk9WTKWVKdopG45pKraYOE(SRfjGge6GjQHqTSQ1wrcqskcPi00jcyRtJQLsT3vlRAzR2dghm486ivOnGiAKa260OAZptxTSv7bJdgCEDerFOgjGTonQwASwih(hhhWeveDQAdOerVhtshmrd1YCTmxB(1E7UAPT2B3vlnwlKd)JJdyIkIovTbuIO3JjPdMOHAzvB21AaU)7fPcTberJFNAzvB21AaU)7fr0hQXVJNVvBWZR3JORefLE4ws4xYbNhq8I36l9z45Hw5cGXFHN)qgbiJ65ZUwKaAqOdMOgc1YQwdwIKVJ8jquMdtt7wlRATvKaKKIqkcnDIa260OAPu7DEE9idU98hnes6rgCNcds88HbjPwTbppGqqFaKx8wZEFgEEOvUay8x451Jm42ZBReMat6HjjdOcDp)Hmcqg1Zt0XKaQqlr1yqXVtTSQLTAfL4csugBij4KzGAZV2d2MdNCWtlOObEZzKAPXAVfZzTwSu7bBZHto4Pfu0aV5msTmsP2JtYwZkHCG2ulZE(ZvNaKeL4ccYB9nV4ToZ(m88qRCbW4VWZFiJaKr98eDmjGk0sunguC6AzSw2FxTStTeDmjGk0sungu08jQm4Uww1EW2C4KdEAbfnWBoJulJuQ94KS1SsihOnEE9idU982kHjWKEysYaQq3lERZPpdpVEKb3E(xqDHqqLb3EEOvUay8x4fV1xRpdpp0kxam(l88hYiazupp3)9IVG6cHGkdUJeWwNgvB(1YEpVEKb3E(xqDHqqLb3Pta0gbEXBDoWNHNhALlag)fEESJNhbINxpYGBppvLmkxa88u1Wh88zxRObOLi6Zja59DHi0kxam1AXsTzxREpqgbIi6e83aMe6)E4JkdUJqRCbWuRfl1AWs0vjeSarh7FqgNWaKAzS2B1YQw2Qf5aHqsuIliO4t7e(LyQhQaQ28R9AR1ILAZU2dghm486ivThe943PwM98uvsQvBWZtfAdiIMqFobiVVlKo42mYGBV4TMD7ZWZdTYfaJ)cpp2XZJaXZRhzWTNNQsgLlaEEQA4dE(SRv0a0sShx6cs0atajcTYfatTwSuB21kAaAjczH029pTkqeALlaMATyP2dghm486iKfsB3)0QarcyRtJQn)AZzTStTxwlnwRObOLObahGKqcrf1fSJqRCbW45PQKuR2GNNk0gqen1JlDbjAGjGKo42mYGBV4TMD5ZWZdTYfaJ)cpp2XZJaXZRhzWTNNQsgLlaEEQA4dE(SRfYH)XXbmr9EeDLOO0d3sc)so48asTwSuREpqgbIi6e83aMe6)E4JkdUJqRCbWuRfl1AaU)7fj69ys6GjAizaU)7fn486ATyP2dghm486OIOtvBaLi69ys6GjAisaBDAuT5x7T7QLvTSv7bJdgCEDerFOgjGTonQ28R9wTwSuRb4(VxerFOg)o1YSNNQssTAdEEQqBar00d3s6GBZidU9I36B35ZWZdTYfaJ)cp)Hmcqg1ZNDTib0Gqhmrc29d1YQwdwIKVJ8jquMdtt7wlRAZUwdW9FVivOnGiA87ulRAPQKr5cqKk0gqenH(CcqEFxiDWTzKb31YQwQkzuUaePcTbert94sxqIgyciPdUnJm4Uww1svjJYfGivOnGiA6HBjDWTzKb3EE9idU98uH2aIOEXB9TB(m88qRCbW4VWZFiJaKr98IgGwIqwiTD)tRceHw5cGPww1kAaAj2JlDbjAGjGeHw5cGPww1EW2C4KdEAbvlJuQ94KS1SsihOn1YQ2dghm486iKfsB3)0QarcyRtJQn)AV551Jm42Ztv7br3lERVDPpdpp0kxam(l88hYiazupVObOLypU0fKObMaseALlaMAzvB21kAaAjczH029pTkqeALlaMAzv7bBZHto4PfuTmsP2JtYwZkHCG2ulRAzRwdW9FVivOnGiA87uRfl1cie0hisDqdUt4xYbip4idUJqRCbWulZEE9idU98u1Eq09I36BS3NHNhALlag)fEESJNhbINxpYGBppvLmkxa88u1Wh8869azeiIOtWFdysO)7HpQm4ocTYfatTSQLTABCNqOe3)9atsuIliOAzKsT3Q1ILAroqiKeL4cck(0oHFjM6HkGQLsTSVwMRLvTSvlcL4(VhysIsCbbLuomvi5OTbSNtTuQ9UATyPwKdecjrjUGGIpTt4xIPEOcOAzKsTxBTm75PQKuR2GNhHsu1Eq0thCBgzWTx8wFlZ(m88qRCbW4VWZRhzWTN3bJdjcGWFYb88qwcrtQn(3INpZ50Z)WKudzjERV5fV13YPpdpp0kxam(l88hYiazupVObOLi6Zja59DHi0kxam1YQ2SRfjGge6GjsWUFOww1EW4GbNxhDvcblq87ulRAzRwQkzuUaerOevThe90b3MrgCxRfl1MDT69azeiIOtWFdysO)7HpQm4ocTYfatTSQLTAnyj6QecwGibEearx5cqTwSuRb4(VxKk0gqen(DQLvTgSeDvcblq0X(hKXjmaP28Pu7TAzUwMRLvThSnho5GNwqrd8MZi1YiLAzRw2Q9wT0w7L1sJ1Q3dKrGiIob)nGjH(Vh(OYG7i0kxam1YCT0yTihiesIsCbbfFANWVet9qfq1YCTmMPR2mxlRAj6ysavOLOAmO401YyT3U0ZRhzWTNNQ2dIUx8wF7A9z45Hw5cGXFHN)qgbiJ65zRwrdqlrBfjajPiKIqthHw5cGPwlwQL8B4HjUq0wjmLWVKqhs2ksassrifHMoc5W)44aMAzUww1MDTib0GqhmrneQLvT2ksassrifHMoraBDAuT5tP27QLvTzxRblrY3r(eisGhbq0vUaulRAnyj6QecwGibS1Pr1YyTSVww1YwTgG7)ErQqBar043Pww1AaU)7fr0hQXVtTSQLTAZUwaHG(arUagBs4xsOdjOb7RI2AMcmPwlwQ1aC)3lYfWytc)scDibnyFv87ulZ1AXsTacb9bIuh0G7e(LCaYdoYG7i0kxam1YSNxpYGBppvTheDV4T(woWNHNhALlag)fE(dzeGmQNp7ArcObHoyIAiulRA17bYiqerNG)gWKq)3dFuzWDeALlaMAzvRblrxLqWcejWJai6kxaQLvTgSeDvcblq0X(hKXjmaP28Pu7TAzv7bBZHto4Pfu0aV5msTmsP2BEE9idU98i6QbNNnemEXB9n2Tpdpp0kxam(l88hYiazupF21IeqdcDWejy3pulRAzR2SR1GLORsiybIe4raeDLla1YQwdwIKVJ8jqKa260OAzS2mxlT1M5APXApojBnReYbAtTwSuRblrY3r(eisaBDAuT0yT3fZzTmwROexqIYydjbNmdulZ1YQwrjUGeLXgscozgOwgRnZEE9idU98qwiTD)tRc4fV13yx(m88qRCbW4VWZFiJaKr98gSejFh5tGOmhMM2Tww1YwTzxlKd)JJdyI69i6krrPhULe(LCW5bKATyP2dghm486ivOnGiAKa260OAzS2B3vlZEE9idU98i6dvV4T(Y78z45Hw5cGXFHN)qgbiJ655(VxKlGXMWhjrcOhPwlwQ1aC)3lsfAdiIg)oEE9idU98oyzWTx8wF5nFgEEOvUay8x45pKraYOEEdW9FVivOnGiA87451Jm42ZZfWyt69jx5fV1xEPpdpp0kxam(l88hYiazupVb4(VxKk0gqen(D886rgC755accimnTRx8wFj79z45Hw5cGXFHN)qgbiJ65na3)9IuH2aIOXVJNxpYGBp)BiaxaJnEXB9Lz2NHNhALlag)fE(dzeGmQN3aC)3lsfAdiIg)oEE9idU98AFaKq0q6OHGx8wFzo9z45Hw5cGXFHNxpYGBpVRgGJgcabL4W42ZFiJaKr98SvRb4(VxKk0gqen(DQ1ILAzR2SRv0a0seYcPT7FAvGi0kxam1YQ2dghm486ivOnGiAKa260OAzS2mNZATyPwrdqlrilK2U)PvbIqRCbWulRAzR2dghm486iKfsB3)0QarcyRtJQn)AV2ATyP2dghm486iKfsB3)0QarcyRtJQLXAV8UAzv7BCPljcyRtJQLXAV2CwlZ1YCTmxlRAZUwdW9FVi57iFceHSqA7(NwfW45B1g88UAaoAiaeuIdJBV4T(YR1NHNhALlag)fEE9idU98kIovTbuIO3JjPdMObp)Hmcqg1ZBaU)7fj69ys6GjAizaU)7fn486ATyPwrjUGeLXgscozgO28R9Y788TAdEEfrNQ2akr07XK0bt0Gx8wFzoWNHNhALlag)fEE9idU98kIovTbuIO3JjPdMObp)Hmcqg1ZZwTzxRObOLiKfsB3)0QarOvUayQ1ILAZUwrdqlr0NtaY77crOvUayQL5AzvRb4(VxKk0gqensaBDAuTmw7T7QLDQnZ1sJ1c5W)44aMOEpIUsuu6HBjHFjhCEaXZ3Qn45veDQAdOerVhtshmrdEXB9LSBFgEEOvUay8x451Jm42ZRi6u1gqjIEpMKoyIg88hYiazuppB1kAaAjczH029pTkqeALlaMAzvRObOLi6Zja59DHi0kxam1YCTSQ1aC)3lsfAdiIg)o1YQw2Q1aC)3l6QecwGiKfsB3)0QaMATyPw9EGmcer0j4Vbmj0)9WhvgChHw5cGPww1AWs0vjeSarh7FqgNWaKAzS2B1YSNVvBWZRi6u1gqjIEpMKoyIg8I36lzx(m88qRCbW4VWZRhzWTN)C1jGfcUNtIlOiXZFiJaKr982ksassrifHMoraBDAuTuQ9UAzvB21AaU)7fPcTberJFNAzvB21AaU)7fr0hQXVtTSQL7)ErBWgtUkHFPW)mMKHaQnkAW511YQwObI7v1MFTS77QLvTgSejFh5tGibS1Pr1YyTz2ZdVhCKuR2GN)C1jGfcUNtIlOiXlERz)D(m88qRCbW4VWZRhzWTNp8jmbeuAA0yg8hLCNN45pKraYOEEdW9FVivOnGiA8745B1g88HpHjGGstJgZG)OK78eV4TM938z45Hw5cGXFHNxpYGBpF4Jec(JsU4Gb6Kt4BRUGN)qgbiJ65na3)9IuH2aIOXVJNVvBWZh(iHG)OKloyGo5e(2Ql4fV1S)sFgEEOvUay8x451Jm42Z7guZOcMGs2GrdHb3E(dzeGmQN3aC)3lsfAdiIg)oEE49GJKA1g88Ub1mQGjOKny0qyWTx8wZE27ZWZdTYfaJ)cpVEKb3EE3GAgvWeuItnUGN)qgbiJ65na3)9IuH2aIOXVJNhEp4iPwTbpVBqnJkyckXPgxWlERzFM9z451Jm42Z)rqAeWg55Hw5cGXFHx8IN3GfFgERV5ZWZdTYfaJ)cpp2XZJaXZRhzWTNNQsgLlaEEQA4dEEhYGjJCvIGfvgCxlRAroqiKeL4cck(0oHFjM6HkGQLXAzFTSQLTAnyj6QecwGibS1Pr1MFThmoyW51rxLqWcenFIkdUR1ILADWdc3GjXfaWGQLXAZzTm75PQKuR2GNhX04KoxDcqYvjeSaEXB9L(m88qRCbW4VWZJD88iq886rgC75PQKr5cGNNQg(GN3HmyYixLiyrLb31YQwKdecjrjUGGIpTt4xIPEOcOAzSw2xlRAzRwdW9FViI(qn(DQ1ILAzRwh8GWnysCbamOAzS2CwlRAZUw9EGmcerhOLe(L4cySjcTYfatTmxlZEEQkj1Qn45rmnoPZvNaKiFh5taV4TM9(m88qRCbW4VWZJD88iq886rgC75PQKr5cGNNQg(GN3aC)3lsfAdiIg)o1YQw2Q1aC)3lIOpuJFNATyPwBfjajPiKIqtNiGTonQwgR9UAzUww1AWsK8DKpbIeWwNgvlJ1EPNNQssTAdEEetJtI8DKpb8I36m7ZWZdTYfaJ)cp)Hmcqg1ZlAaAjczH029pTkqeALlaMAzvB21AaU)7fDvcblqeYcPT7FAvatTSQ1GLORsiybIo2)GmoHbi1MpLAVvlRApyCWGZRJqwiTD)tRcejGTonQ28R9YAzvlYbcHKOexqqXN2j8lXupubuTuQ9wTSQLOJjbuHwIQXGItxlJ1ET1YQwdwIUkHGfisaBDAuT0yT3fZzT5xROexqIYydjbNmd451Jm42Z7QecwaV4ToN(m88qRCbW4VWZFiJaKr98IgGwIqwiTD)tRceHw5cGPww1YwThSnho5GNwq1YiLApojBnReYbAtTSQ9GXbdoVoczH029pTkqKa260OAZV2B1YQwdwIKVJ8jqKa260OAPXAVlMZAZVwrjUGeLXgscozgOwM986rgC75jFh5taV4T(A9z45Hw5cGXFHN)HjPgYs8wFZZRhzWTN3bJdjcGWFYb8I36CGpdpp0kxam(l88hYiazuppbEearx5cqTSQ9GT5Wjh80ckAG3CgPwgPu7TAPTw2xlnwlB1Q3dKrGiIob)nGjH(Vh(OYG7i0kxam1YQ2dghm486ivThe943PwMRLvTSvRJ9piJtyasT5tP2B1AXsTeWwNgvB(uQvMdtjzSHAzvlYbcHKOexqqXN2j8lXupubuTmsPw2xlT1Q3dKrGiIob)nGjH(Vh(OYG7i0kxam1YCTSQLTAZUwilK2U)Pvbm1AXsTeWwNgvB(uQvMdtjzSHAPXAVSww1ICGqijkXfeu8PDc)sm1dvavlJuQL91sBT69azeiIOtWFdysO)7HpQm4ocTYfatTmxlRAZUwekX9FpWulRAzRwrjUGeLXgscozgOw2PwcyRtJQL5AzS2mxlRAzRwBfjajPiKIqtNiGTonQwk1ExTwSuB21kZHPPDRLvT69azeiIOtWFdysO)7HpQm4ocTYfatTm751Jm42Z7QecwaV4TMD7ZWZdTYfaJ)cp)dtsnKL4T(MNxpYGBpVdghseaH)Kd4fV1SlFgEEOvUay8x451Jm42Z7Qecwap)Hmcqg1ZNDTuvYOCbiIyACsNRobi5QecwGAzvlbEearx5cqTSQ9GT5Wjh80ckAG3CgPwgPu7TAPTw2xlnwlB1Q3dKrGiIob)nGjH(Vh(OYG7i0kxam1YQ2dghm486ivThe943PwMRLvTSvRJ9piJtyasT5tP2B1AXsTeWwNgvB(uQvMdtjzSHAzvlYbcHKOexqqXN2j8lXupubuTmsPw2xlT1Q3dKrGiIob)nGjH(Vh(OYG7i0kxam1YCTSQLTAZUwilK2U)Pvbm1AXsTeWwNgvB(uQvMdtjzSHAPXAVSww1ICGqijkXfeu8PDc)sm1dvavlJuQL91sBT69azeiIOtWFdysO)7HpQm4ocTYfatTmxlRAZUwekX9FpWulRAzRwrjUGeLXgscozgOw2PwcyRtJQL5AzS2BxwlRAzRwBfjajPiKIqtNiGTonQwk1ExTwSuB21kZHPPDRLvT69azeiIOtWFdysO)7HpQm4ocTYfatTm75pxDcqsuIliiV138I36B35ZWZdTYfaJ)cp)Hmcqg1ZJCGqijkXfeuTmsP2lRLvTeWwNgvB(1EzT0wlB1ICGqijkXfeuTmsP2CwlZ1YQ2d2MdNCWtlOAzKsTz2ZRhzWTN)qgBeUtcy7aiXlERVDZNHNhALlag)fE(dzeGmQNp7APQKr5cqeX04KiFh5tGAzvlB1EW2C4KdEAbvlJuQnZ1YQwc8iaIUYfGATyP2SRvMdtt7wlRAzRwzSHAzS2B3vRfl1EW2C4KdEAbvlJuQ9YAzUwMRLvTSvRJ9piJtyasT5tP2B1AXsTeWwNgvB(uQvMdtjzSHAzvlYbcHKOexqqXN2j8lXupubuTmsPw2xlT1Q3dKrGiIob)nGjH(Vh(OYG7i0kxam1YCTSQLTAZUwilK2U)Pvbm1AXsTeWwNgvB(uQvMdtjzSHAPXAVSww1ICGqijkXfeu8PDc)sm1dvavlJuQL91sBT69azeiIOtWFdysO)7HpQm4ocTYfatTmxlRAfL4csugBij4KzGAzNAjGTonQwgRnZEE9idU98KVJ8jGx8wF7sFgEEOvUay8x451Jm42Zt(oYNaE(dzeGmQNp7APQKr5cqeX04KoxDcqI8DKpbQLvTzxlvLmkxaIiMgNe57iFculRApyBoCYbpTGQLrk1M5AzvlbEearx5cqTSQLTADS)bzCcdqQnFk1ERwlwQLa260OAZNsTYCykjJnulRAroqiKeL4cck(0oHFjM6HkGQLrk1Y(APTw9EGmcer0j4Vbmj0)9WhvgChHw5cGPwMRLvTSvB21czH029pTkGPwlwQLa260OAZNsTYCykjJnulnw7L1YQwKdecjrjUGGIpTt4xIPEOcOAzKsTSVwARvVhiJareDc(Batc9Fp8rLb3rOvUayQL5AzvROexqIYydjbNmdul7ulbS1Pr1YyTz2ZFU6eGKOexqqERV5fV13yVpdpp0kxam(l88hYiazuppYbcHKOexqq1sP2B1YQ2d2MdNCWtlOAzKsTSv7XjzRzLqoqBQLDQ9wTmxlRAjWJai6kxaQLvTzxlKfsB3)0QaMAzvB21AaU)7fr0hQXVtTSQ1wrcqskcPi00jcyRtJQLsT3vlRAZUw9EGmceL8gKKe6qIPEEqeALlaMAzvROexqIYydjbNmdul7ulbS1Pr1YyTz2ZRhzWTN)qgBeUtcy7aiXlERVLzFgEE9idU98iWbnipp0kxam(l8Ix8INNkqqdU9wF5DxE3DSRB50ZNNs6PDrE(mL0SR36mnRVU08ARnd6qTJTdMi1(WKAVgaHG(aORPwcKd)dbm1IW2qT6xW2QaMAp012fqXIHmHPHAVKMxlnf3ubIaMAVgilK2U)PvbmrAYRPwbx71yaU)7fPjJqwiTD)tRcyUMAz7wwmhlgkgYusZUERZ0S(6sZRT2mOd1o2oyIu7dtQ9Aog01ulbYH)HaMAryBOw9lyBvatTh6A7cOyXqMW0qTSlAET0uCtficyQ9AeY0mbsKMmEW4GbNxFn1k4AVMdghm486in51ulB3YI5yXqMW0qTxMtAET0uCtficyQ9AGSqA7(NwfWePjVMAfCTxJb4(VxKMmczH029pTkG5AQLTBzXCSyityAO2lz308APP4MkqeWu71azH029pTkGjstEn1k4AVgdW9FVinzeYcPT7FAvaZ1ulB3YI5yXqXqMsA21BDMM1xxAET1MbDO2X2btKAFysTxJblxtTeih(hcyQfHTHA1VGTvbm1EORTlGIfdzctd1MzAET0uCtficyQ9AGSqA7(NwfWePjVMAfCTxJb4(VxKMmczH029pTkG5AQLTBzXCSyOyitZ2bteWuBoOw9idURnmibflg88ih44T(YCYU88oe8BcGNNgQLMHqkcnTkdUR96XUFOyGgQLhCeWMdi1EzMTQ2lV7Y7kgkgOHAZKzbNVaMA5GhMa1EW2CQulh4onkwln7CahbvBJB2HUsSF)qT6rgCJQf3HRIfd6rgCJIoe4GT5uHI64eUk5GheUlg0Jm4gfDiWbBZPcTuY9fuetfd6rgCJIoe4GT5uHwk5QFxBOfvgCxmOhzWnk6qGd2MtfAPK7dJnfd0qT8T6GOJLAj6yQL7)EGPwKOcQwo4HjqThSnNk1YbUtJQvBtToeGDCWImTBTdQwdUHyXGEKb3OOdboyBovOLsUOwDq0XscjQGkg0Jm4gfDiWbBZPcTuY1bldUlg0Jm4gfDiWbBZPcTuY1wjmbM0dtsgqf6w5qGd2MtLeco42GOKtRMhfIoMeqfAjQgdkonJ3YzXGEKb3OOdboyBovOLsUib0GqVyqpYGBu0HahSnNk0sjxuyoqsBtYmhWkhcCW2CQKqWb3geLBfd6rgCJIoe4GT5uHwk5(rqAeW2QwTbk69i6krrPhULe(LCW5bKIb9idUrrhcCW2CQqlLCD)kXmANWVKEpqWcDRMhfrdqlrilK2U)PvbIqRCbWumumqd1MjZcoFbm1cubYv1kJnuRqhQvpcMu7GQvPQtq5cqSyqpYGBefMMdtfd0qTxpGeqdc9ANxToyeA4cqTS14AP(dnquUaul0G9aOANU2d2MtfMlg0Jm4grlLCrcObHEXGEKb3iAPKlvLmkxaSQvBGc0aX9QebCHoDW2CtdgROQHpqbAG4EvKaUqtRdEq4gmjUaagenMdOjW2L0iYbcHeDfjaZfd6rgCJOLsUuvYOCbWQwTbkOPDdqsuIliwrvdFGcYbcHKOexqqXN2j8lXupubu(xwmOhzWnIwk5E0qiPhzWDkmiXQwTbkib0Gqhmwnpkib0Gqhmrc29dfd6rgCJOLsUhnes6rgCNcdsSQvBGYXGSAEuylBrdqlrBfjajPiKIqthHw5cGXIfdwIUkHGfikZHPPDzUyqpYGBeTuY9OHqspYG7uyqIvTAdumyPyqpYGBeTuYffMdK02KmZbSAEu4(VxefMdK02KmZbIeWwNgLVOexqIYydjbNmdWI7)EruyoqsBtYmhisaBDAu(SDJ2d2MdNCWtliMPXBr2DXGEKb3iAPK7rdHKEKb3PWGeRA1gOygcCKIb9idUr0sjxLC0gscMqGwSAEuGgiUxfnWBoJWiLB5KwQkzuUaeHgiUxLiGl0Pd2MBAWumOhzWnIwk5QKJ2qY5hqqXGEKb3iAPKByCPlOuMIVX1gAPyqpYGBeTuYLtDt4xsiZHjuXqXanulnfJdgCEnQyqpYGBu8yqu(iincyBvR2af9EeDLOO0d3sc)so48aIvZJs2ib0GqhmrneyzRibijfHueA6ebS1PruUJfBhmoyW51rQqBar0ibS1Pr5NPJTdghm486iI(qnsaBDAenc5W)44aMOIOtvBaLi69ys6GjAGzMZ)2D0E7oAeYH)XXbmrfrNQ2akr07XK0bt0aRSna3)9IuH2aIOXVdRSna3)9Ii6d143PyqpYGBu8yq0sj3Jgcj9idUtHbjw1QnqbqiOpaYQ5rjBKaAqOdMOgcSmyjs(oYNarzomnTllBfjajPiKIqtNiGTonIYDfd0qTzAVAvJbvRsGA)owvlQhhOwHoulUHAZBe61gW5biP2mY46eRntpcQnp6qxR5QPDR9Pibi1k01UwAAoQwd8MZi1Ij1M3i0XFPwTVQwAAokwmOhzWnkEmiAPKRTsycmPhMKmGk0T6C1jajrjUGGOCZQ5rHOJjbuHwIQXGIFhwSjkXfKOm2qsWjZa5FW2C4KdEAbfnWBoJqJ3I50ILd2MdNCWtlOObEZzegPCCs2AwjKd0gMlgOHAZ0E124AvJbvBEtiuRzGAZBe6txRqhQTHSKAz)DiRQ9JGAZuFxNAXDTCyeQ28gHo(l1Q9v1stZrXIb9idUrXJbrlLCTvctGj9WKKbuHUvZJcrhtcOcTevJbfNMr2Fh7q0XKaQqlr1yqrZNOYGBwhSnho5GNwqrd8MZims54KS1SsihOnfd6rgCJIhdIwk5(cQlecQm4UyqpYGBu8yq0sj3xqDHqqLb3Pta0gbwnpkC)3l(cQlecQm4osaBDAu(SVyGgQnhdTberRnGDNJgQ9GBZidU1aQwofbMAXDTNpHaTulYbofd6rgCJIhdIwk5svjJYfaRA1gOqfAdiIMqFobiVVlKo42mYGBROQHpqjBrdqlr0NtaY77crOvUaySyjB9EGmcer0j4Vbmj0)9WhvgChHw5cGXIfdwIUkHGfi6y)dY4egGW4nwSHCGqijkXfeu8PDc)sm1dvaL)1AXs2hmoyW51rQApi6XVdZfd6rgCJIhdIwk5svjJYfaRA1gOqfAdiIM6XLUGenWeqshCBgzWTvu1WhOKTObOLypU0fKObMaseALlaglwYw0a0seYcPT7FAvGi0kxamwSCW4GbNxhHSqA7(NwfisaBDAu(5KDUKgfnaTena4aKesiQOUGDeALlaMIb9idUrXJbrlLCPQKr5cGvTAduOQKr5cGvTAduOcTbertpClPdUnJm42kQA4duYgYH)XXbmr9EeDLOO0d3sc)so48aIfl69azeiIOtWFdysO)7HpQm4ocTYfaJflgG7)ErIEpMKoyIgsgG7)ErdoV2IfHmntGeveDQAdOerVhtshmrdXdghm486ibS1Pr5F7owSDW4GbNxhr0hQrcyRtJY)MflgG7)Ere9HA87WCXGEKb3O4XGOLsUuH2aIOwnpkzJeqdcDWejy3pWYGLi57iFceL5W00USY2aC)3lsfAdiIg)oSOQKr5cqKk0gqenH(CcqEFxiDWTzKb3SOQKr5cqKk0gqen1JlDbjAGjGKo42mYGBwuvYOCbisfAdiIME4wshCBgzWDXanuBow7brV28gHETzYSqU1sBTwpU0fKObMacnV2mvnRX(BxlnnhvR2MAZKzHCRLaQ5QAFysTnKLu71LMEDkg0Jm4gfpgeTuYLQ2dIUvZJIObOLiKfsB3)0QarOvUayyjAaAj2JlDbjAGjGeHw5cGH1bBZHto4PfeJuoojBnReYbAdRdghm486iKfsB3)0QarcyRtJY)wXanuBow7brV28gHETwpU0fKObMasT0wR14AZKzHCP51MPQzn2F7APP5OA12uBogAdiIw73Pw2(DaqOA)OPDRnhJZrmxmOhzWnkEmiAPKlvTheDRMhfrdqlXECPlirdmbKi0kxamSYw0a0seYcPT7FAvGi0kxamSoyBoCYbpTGyKYXjzRzLqoqByXMb4(VxKk0gqen(DSybqiOpqK6GgCNWVKdqEWrgChHw5cGH5IbAOwEaQ99dHApyBBOLAXDT0fXbrZZnx3rO)5IhSDUxVsfA64GryNmOP5E9y3pKBEdttU0mesrOPvzWn7qZYrzcSZ1diqjh6XIb9idUrXJbrlLCPQKr5cGvTAduqOevThe90b3MrgCBfvn8bk69azeiIOtWFdysO)7HpQm4ocTYfadl2ACNqOe3)9atsuIliigPCZIfKdecjrjUGGIpTt4xIPEOcikSNzwSHqjU)7bMKOexqqjLdtfsoABa75q5olwqoqiKeL4cck(0oHFjM6HkGyKY1YCXGEKb3O4XGOLsUoyCirae(toGvpmj1qwcLBwbzjenP24FluYColg0Jm4gfpgeTuYLQ2dIUvZJIObOLi6Zja59DHi0kxamSYgjGge6GjsWUFG1bJdgCED0vjeSaXVdl2OQKr5cqeHsu1Eq0thCBgzWTflzR3dKrGiIob)nGjH(Vh(OYG7i0kxamSyZGLORsiybIe4raeDLlawSyaU)7fPcTberJFhwgSeDvcblq0X(hKXjmajFk3yMzwhSnho5GNwqrd8MZimsHn2Ur7L0OEpqgbIi6e83aMe6)E4JkdUJqRCbWWmnICGqijkXfeu8PDc)sm1dvaXmJz6YmlIoMeqfAjQgdkonJ3USyGgQnhR9GOxBEJqV2mvfjaPwAgcPOPP51AnUwKaAqOxR2MABCT6rgQqTzQ0SA5(VNv1E9Fh5tGABSu701sGhbq0RLOTlyvTMpzA3AZXqBaruAZ4cAValzYAz73baHQ9JM2T2CmohXCXGEKb3O4XGOLsUu1Eq0TAEuyt0a0s0wrcqskcPi00rOvUaySyH8B4HjUq0wjmLWVKqhs2ksassrifHMoc5W)44agMzLnsani0btudbw2ksassrifHMoraBDAu(uUJv2gSejFh5tGibEearx5caldwIUkHGfisaBDAeJSNfBgG7)ErQqBar043HLb4(VxerFOg)oSylBaHG(arUagBs4xsOdjOb7RI2AMcmXIfdW9FVixaJnj8lj0He0G9vXVdZwSaie0hisDqdUt4xYbip4idUJqRCbWWCXanulpD1GZZgcMAFysT80j4Vbm1Y)Fp8rLb3fd6rgCJIhdIwk5IORgCE2qWy18OKnsani0btudbw69azeiIOtWFdysO)7HpQm4ocTYfadldwIUkHGfisGhbq0vUaWYGLORsiybIo2)GmoHbi5t5gRd2MdNCWtlOObEZzegPCRyGgQntMfsB3)0Qa1MhDORTXsTib0Gqhm1QTPwoSqV2R)7iFcuR2MAVUkHGfOwLa1(DQ9Hj1gWTBTqJ)U0Jfd6rgCJIhdIwk5czH029pTkGvZJs2ib0Gqhmrc29dSylBdwIUkHGfisGhbq0vUaWYGLi57iFcejGTonIXmtBMPXJtYwZkHCG2yXIblrY3r(eisaBDAenExmNmkkXfKOm2qsWjZamZsuIlirzSHKGtMbymZfd6rgCJIhdIwk5IOpuTAEumyjs(oYNarzomnTll2YgYH)XXbmr9EeDLOO0d3sc)so48aIflhmoyW51rQqBar0ibS1PrmE7oMlg0Jm4gfpgeTuY1bldUTAEu4(VxKlGXMWhjrcOhXIfdW9FVivOnGiA87umOhzWnkEmiAPKlxaJnP3NCLvZJIb4(VxKk0gqen(Dkg0Jm4gfpgeTuYLdiiGW00UwnpkgG7)ErQqBar043PyqpYGBu8yq0sj33qaUagBSAEuma3)9IuH2aIOXVtXGEKb3O4XGOLsUAFaKq0q6OHGvZJIb4(VxKk0gqen(Dkg0Jm4gfpgeTuY9JG0iGTvTAduC1aC0qaiOehg3wnpkSzaU)7fPcTberJFhlwylBrdqlrilK2U)PvbIqRCbWW6GXbdoVosfAdiIgjGTonIXmNtlwenaTeHSqA7(NwficTYfadl2oyCWGZRJqwiTD)tRcejGTonk)R1ILdghm486iKfsB3)0QarcyRtJy8Y7y9gx6sIa260igV2CYmZmZkBilK2U)PvbmrY3r(eOyqpYGBu8yq0sj3pcsJa2w1Qnqrr0PQnGse9EmjDWeny18OyaU)7fj69ys6GjAizaU)7fn48AlweL4csugBij4KzG8V8UIb9idUrXJbrlLC)iincyBvR2affrNQ2akr07XK0bt0GvZJcBzlAaAjczH029pTkqeALlaglwYw0a0se95eG8(UqeALlagMzzaU)7fPcTberJeWwNgX4T7yNmtJqo8pooGjQ3JORefLE4ws4xYbNhqkg0Jm4gfpgeTuY9JG0iGTvTAduueDQAdOerVhtshmrdwnpkSjAaAjczH029pTkqeALlagwIgGwIOpNaK33fIqRCbWWmldW9FVivOnGiA87WInilK2U)PvbmrxLqWcyXIEpqgbIi6e83aMe6)E4JkdUJqRCbWWYGLORsiybIo2)GmoHbimEJ5Ib9idUrXJbrlLC)iincyBf8EWrsTAduoxDcyHG75K4cksSAEuSvKaKKIqkcnDIa260ik3XkBdW9FVivOnGiA87WkBdW9FViI(qn(DyX9FVOnyJjxLWVu4FgtYqa1gfn48Awqde3RYNDFhldwIKVJ8jqKa260igZCXGEKb3O4XGOLsUFeKgbSTQvBGs4tyciO00OXm4pk5opXQ5rXaC)3lsfAdiIg)ofd6rgCJIhdIwk5(rqAeW2QwTbkHpsi4pk5IdgOtoHVT6cwnpkgG7)ErQqBar043PyqpYGBu8yq0sj3pcsJa2wbVhCKuR2af3GAgvWeuYgmAim42Q5rXaC)3lsfAdiIg)ofd6rgCJIhdIwk5(rqAeW2k49GJKA1gO4guZOcMGsCQXfSAEuma3)9IuH2aIOXVtXanu71bE6pi1(0qGtpmv7dtQ9JuUau7iGnIMxBMEeulUR9GXbdoVowmOhzWnkEmiAPK7hbPraBuXqXanu71ziWrQ1O2QluRYnHrgavmqd1MjBQqJTRvLAZmT1YwoPT28gHETxhEMRLMMJI1MPzBdMrfiCvT4U2lPTwrjUGGSQ28gHET5yOnGiQv1Ij1M3i0RnJlYeTwSqhi5niO280rQ9Hj1IW2qTqde3RI1sZciCT5PJu78QntMfYT2d2Mdx7GQ9GTN2T2VtSyqpYGBu0me4iuGMk0yBRMhf2oyBoCYbpTGyKsMPv0a0s0aGdqsiHOI6c2rOvUaySy5GT5Wjh80cII2JTEORexWKoomZIndW9FVivOnGiA87yXIb4(VxerFOg)owSanqCVkAG3CgjFkxMtAPQKr5cqeAG4EvIaUqNoyBUPbJflztvjJYfGiAA3aKeL4ccZSylBrdqlrilK2U)PvbIqRCbWyXYbJdgCEDeYcPT7FAvGibS1PrmEjZfd6rgCJIMHahHwk5svjJYfaRA1gO8rq6nHaqSIQg(aLd2MdNCWtlOObEZzegVzXc0aX9QObEZzK8PCzoPLQsgLlarObI7vjc4cD6GT5MgmwSKnvLmkxaIOPDdqsuIlifd6rgCJIMHahHwk5IacrfWK4WnKqodtGvNRobijkXfeeLBwnpkzBWsebeIkGjXHBiHCgMGOmhMM21IfQkzuUae)ii9MqaiSytpYqfsqd2dGOCJfrhtcOcTevJbfNMX3pese4qxjUqsgBWILdDL4cigVKLOexqIYydjbNmdKFozUyGgQnt5i0RntEOJN2T2lcQbqwvBMyTRf)QLMypubuTQu7L0wROexqqwvlMul7zNmtBTIsCbbvBE0HU2Cm0gqeT2bv73PyqpYGBu0me4i0sj3N2j8lXupubKvZJcvLmkxaIFeKEtiaew69azeich64PDtCb1aOi0kxamSqoqiKeL4cck(0oHFjM6HkGyKYL0YMb4(VxKk0gqen(DOr2UrlB69azeich64PDtCb1aOirBMOCJzMzUyGgQntS21IF1stShQaQwvQ9g7I2ArIEycvl(vBMiJXaDTxeudGQftQvD1PrsTzM2AzlN0wBEJqV2Rd(ZfGAVoyeWCTIsCbbflg0Jm4gfndbocTuY9PDc)sm1dvaz18OqvjJYfG4hbP3ecaHfBC)3lsFmgOtCb1aOis0dtms5g7YIf2Y2HmyYixLiyrLb3SqoqiKeL4cck(0oHFjM6HkGyKsMPLn9EGmcen4pxasgmcIeTzIXlzMwKaAqOdMib7(bMzUyGgQntS21IF1stShQaQwbxR64eUQ2RdOMWv1MJWdc31oVANwpYqfQf31Q9v1kkXfKAvPw2xROexqqXIb9idUrrZqGJqlLCFANWVet9qfqwDU6eGKOexqquUz18OqvjJYfG4hbP3ecaHfYbcHKOexqqXN2j8lXupubeJuyFXGEKb3OOziWrOLsUWHoEA3ebCiJT2gRMhfQkzuUae)ii9Mqaifd6rgCJIMHahHwk5Q2CFeDRMhfQkzuUae)ii9Mqaifd0qTzOCStM6xMGkqTcUw1XjCvTxhqnHRQnhHheURvLAVSwrjUGGkg0Jm4gfndbocTuY1(ltqfWQZvNaKeL4ccIYnRMhfQkzuUae)ii9MqaiSqoqiKeL4cck(0oHFjM6HkGOCzXGEKb3OOziWrOLsU2FzcQawnpkuvYOCbi(rq6nHaqkgkgOHAVoQT6c1IPcKALXgQv5MWidGkgOHAZeg7rQ96QecwauT4U2g3SJdzSjk5QAfL4ccQ2hMuRqhQ1HmyYixvlblQm4U25vBoPTwUaaguTkbQvdeqnxv73PyqpYGBu0GfkuvYOCbWQwTbkiMgN05QtasUkHGfWkQA4duCidMmYvjcwuzWnlKdecjrjUGGIpTt4xIPEOcigzpl2myj6QecwGibS1Pr5FW4GbNxhDvcblq08jQm42Ifh8GWnysCbamigZjZfd0qTzcJ9i1E9Fh5tauT4U2g3SJdzSjk5QAfL4ccQ2hMuRqhQ1HmyYixvlblQm4U25vBoPTwUaaguTkbQvdeqnxv73PyqpYGBu0GfAPKlvLmkxaSQvBGcIPXjDU6eGe57iFcyfvn8bkoKbtg5QeblQm4MfYbcHKOexqqXN2j8lXupubeJSNfBgG7)Ere9HA87yXcBo4bHBWK4cayqmMtwzR3dKrGi6aTKWVexaJnrOvUayyM5IbAO2mHXEKAV(VJ8jaQ25vBogAdiIslp9HAUzQksasT0mesrOPRDq1(DQvBtT5b1sxPc1EjT1IGdUnOAdWtQf31k0HAV(VJ8jqTxhCgfd6rgCJIgSqlLCPQKr5cGvTAduqmnojY3r(eWkQA4duma3)9IuH2aIOXVdl2ma3)9Ii6d143XIfBfjajPiKIqtNiGTonIX7yMLblrY3r(eisaBDAeJxwmqd1Y7aNrd1EDvcblqTABQ96)oYNa1Ia57uRdzWKAfCTzYSqA7(NwfO2JIKIb9idUrrdwOLsUUkHGfWQ5rr0a0seYcPT7FAvGi0kxamSYgYcPT7FAvat0vjeSaSmyj6QecwGOJ9piJtyas(uUX6GXbdoVoczH029pTkqKa260O8VKfYbcHKOexqqXN2j8lXupubeLBSi6ysavOLOAmO40mETSmyj6QecwGibS1Pr04DXCMVOexqIYydjbNmdumOhzWnkAWcTuYL8DKpbSAEuenaTeHSqA7(NwficTYfadl2oyBoCYbpTGyKYXjzRzLqoqByDW4GbNxhHSqA7(NwfisaBDAu(3yzWsK8DKpbIeWwNgrJ3fZz(IsCbjkJnKeCYmaZfd0qTxxLqWcu73HjaCSQwnGW1kKbq1k4A)iO2rQvr1Q1ICGZOHADHgiQGj1(WKAf6qTbfj1stZr1YbpmbQvR9n9GOdKIb9idUrrdwOLsUoyCirae(toGvpmj1qwcLBfd6rgCJIgSqlLCDvcblGvZJcbEearx5caRd2MdNCWtlOObEZzegPCJw2tJSP3dKrGiIob)nGjH(Vh(OYG7i0kxamSoyCWGZRJu1Eq0JFhMzXMJ9piJtyas(uUzXcbS1Pr5trMdtjzSbwihiesIsCbbfFANWVet9qfqmsH90Q3dKrGiIob)nGjH(Vh(OYG7i0kxammZITSHSqA7(NwfWyXcbS1Pr5trMdtjzSbA8swihiesIsCbbfFANWVet9qfqmsH90Q3dKrGiIob)nGjH(Vh(OYG7i0kxammZkBekX9FpWWInrjUGeLXgscozgGDiGTonIzgZml2SvKaKKIqkcnDIa260ik3zXs2YCyAAxw69azeiIOtWFdysO)7HpQm4ocTYfadZfd6rgCJIgSqlLCDW4qIai8NCaREysQHSek3kg0Jm4gfnyHwk56QecwaRoxDcqsuIliik3SAEuYMQsgLlaretJt6C1jajxLqWcWIapcGORCbG1bBZHto4Pfu0aV5mcJuUrl7Pr207bYiqerNG)gWKq)3dFuzWDeALlagwhmoyW51rQApi6XVdZSyZX(hKXjmajFk3SyHa260O8PiZHPKm2alKdecjrjUGGIpTt4xIPEOcigPWEA17bYiqerNG)gWKq)3dFuzWDeALlagMzXw2qwiTD)tRcySyHa260O8PiZHPKm2anEjlKdecjrjUGGIpTt4xIPEOcigPWEA17bYiqerNG)gWKq)3dFuzWDeALlagMzLncL4(VhyyXMOexqIYydjbNmdWoeWwNgXmJ3UKfB2ksassrifHMoraBDAeL7SyjBzomnTll9EGmcer0j4Vbmj0)9WhvgChHw5cGH5IbAOwAkzSr4U2maBhaj1I7AT)bzCcqTIsCbbvRk1MzARLMMJQnp6qxl5390U1I)sTtx7LOAz77uRGRnZ1kkXfeeZ1Ij1YEuTSLtARvuIliiMlg0Jm4gfnyHwk5EiJnc3jbSDaKy18OGCGqijkXfeeJuUKfbS1Pr5FjTSHCGqijkXfeeJuYjZSoyBoCYbpTGyKsMlgOHAPjcGtTFNAV(VJ8jqTQuBMPTwCxRgc1kkXfeuTSLhDORnmuN2T2aUDRfA83LETABQTXsTOwDq0XcZfd6rgCJIgSqlLCjFh5taRMhLSPQKr5cqeX04KiFh5tawSDW2C4KdEAbXiLmZIapcGORCbWILSL5W00USytgBGXB3zXYbBZHto4PfeJuUKzMzXMJ9piJtyas(uUzXcbS1Pr5trMdtjzSbwihiesIsCbbfFANWVet9qfqmsH90Q3dKrGiIob)nGjH(Vh(OYG7i0kxammZITSHSqA7(NwfWyXcbS1Pr5trMdtjzSbA8swihiesIsCbbfFANWVet9qfqmsH90Q3dKrGiIob)nGjH(Vh(OYG7i0kxammZsuIlirzSHKGtMbyhcyRtJymZfd6rgCJIgSqlLCjFh5taRoxDcqsuIliik3SAEuYMQsgLlaretJt6C1jajY3r(eGv2uvYOCbiIyACsKVJ8jaRd2MdNCWtligPKzwe4raeDLlaSyZX(hKXjmajFk3SyHa260O8PiZHPKm2alKdecjrjUGGIpTt4xIPEOcigPWEA17bYiqerNG)gWKq)3dFuzWDeALlagMzXw2qwiTD)tRcySyHa260O8PiZHPKm2anEjlKdecjrjUGGIpTt4xIPEOcigPWEA17bYiqerNG)gWKq)3dFuzWDeALlagMzjkXfKOm2qsWjZaSdbS1PrmM5IbAOwAkzSr4U2maBhaj1I7A5ZO25v7016OTbSNtTABQDKAZBcHAn4AdacvRrTvxOwHU21MjBQqJTR18HAfCTzCrUzQ0SCZqOjwmOhzWnkAWcTuY9qgBeUtcy7aiXQ5rb5aHqsuIliik3yDW2C4KdEAbXif2oojBnReYbAd7CJzwe4raeDLlaSYgYcPT7FAvadRSna3)9Ii6d143HLTIeGKuesrOPteWwNgr5owzR3dKrGOK3GKKqhsm1ZdIqRCbWWsuIlirzSHKGtMbyhcyRtJymZfd6rgCJIgSqlLCrGdAqfdfd0qTzsec6dGkg0Jm4gfbec6dGOCW9bAHOcysVGAdwnpkqde3RIYydjbNS1Sy8gRSna3)9IuH2aIOXVdl2Y2GL4b3hOfIkGj9cQnK4(KokZHPPDzLTEKb3XdUpqlevat6fuBioD6fgx6IflVFiKiWHUsCHKm2q(Uht0wZI5IbAOwAwip9kuTFeu7fbm2uBEJqV2Cm0gqeT2VtS2mrWbtTpmP2mzwiTD)tRceRntpcQnVrOxBgxu73Pwo4HjqTATVPheDGuRIQnGB3AvuTJul53OAFysT3UdvR5tM2T2Cm0gqenwmOhzWnkcie0harlLC5cySjHFjHoKGgSVYQ5rXaC)3lsfAdiIg)oSydYcPT7FAvat0vjeSawSyaU)7fr0hQXVdRd2MdNCWtlOObEZzK8PCZIfdW9FVivOnGiAKa260O8PC7oMTy5nU0LebS1Pr5t52Dfd0qT0mraBhPwbxRgg3U2R7xjMr7AZBe61MJH2aIO1QOAd42Twfv7i1MhUVgPwcG(bP2PRnGrt7wRw77hcSdvn8HApksQftfi1k0HAjGTo90U1A(evgCxl(vRqhQ9nU0LIb9idUrraHG(aiAPKR7xjMr7e(L07bcwOB18OCW4GbNxhPcTberJeWwNgLp7TyXaC)3lsfAdiIg)owS8gx6sIa260O8z)Dfd6rgCJIacb9bq0sjx3VsmJ2j8lP3deSq3Q5r5fWycBS9gx6sIa260i2H93XmnHdghm48AMz8fWycBS9gx6sIa260i2H93XohmoyW51rQqBar0ibS1Prmtt4GXbdoVM5Ib9idUrraHG(aiAPK7dF(iWK07bYiqIduBRMhfKdecjrjUGGIpTt4xIPEOcigPCPfleDmjGk0sunguCAgV27ybnqCVk)CWDfd6rgCJIacb9bq0sjxNpzExnTBIlOiXQ5rb5aHqsuIliO4t7e(LyQhQaIrkxAXcrhtcOcTevJbfNMXR9UIb9idUrraHG(aiAPKRqhs)Md)Bt6HjhWQ5rH7)ErcCykaiu6Hjhi(DSyH7)ErcCykaiu6HjhiDW)wasej6HP8VDxXGEKb3OiGqqFaeTuYLmoobinDc5OhOyqpYGBueqiOpaIwk5MhMemuHPteaHBTpqXGEKb3OiGqqFaeTuY1gSXKRs4xk8pJjziGAJSAEuGgiUxLFoVJv2hmoyW51rQqBar043PyGgQnteCWu71dQZ0U1MjoO2aQ2hMulKfC(culrBxOwmPwMMqOwU)7HSQ25vRdgHgUaeRLMfYtVcvRqUQwbxRli1k0HAd48aKu7bJdgCEDTCkcm1I7AvQ6euUaul0G9aOyXGEKb3OiGqqFaeTuYLaQZ0UPxqTbKvNRobijkXfeeLBwnpkIsCbjkJnKeCYmq(3I50If2ytuIlir6Gge6rNJWi7(olweL4csKoObHE05i5t5Y7yMfB6rgQqcAWEaeLBwSikXfKOm2qsWjZamEj7IzMTyHnrjUGeLXgsco5CK0L3Xi7VJfB6rgQqcAWEaeLBwSikXfKOm2qsWjZamM5mZmZfdfd0qT8cObHoyQLMDKb3OIbAOwRhx6irdmbKAXDT3YGMxlFRoi6yP2R)7iFcumOhzWnkIeqdcDWqH8DKpbSAEuenaTe7XLUGenWeqIqRCbWW6GT5Wjh80cIrkzMLOexqIYydjbNmdWoeWwNgX41wmqd1Y)5eG8(UqT0wlpDc(BatT8)3dFuzWnnV2mzJ(eO28GA)iOwCd16gWCAOwbxR64eUQ2RRsiybQvW1k0HAT1PRvuIli1oVAhP2bvBJLArT6GOJLAVceRQfHRvdHAXcDGuRToDTIsCbPwLBcJmaQwhc(nsSyqpYGBuejGge6GHwk56GXHebq4p5aw9WKudzjuUvmOhzWnkIeqdcDWqlLCDvcblGvZJIEpqgbIi6e83aMe6)E4JkdUJqRCbWWI7)Er0NtaY77cXVdlU)7frFobiVVlejGTonk)Br2ZkBekX9FpWumqd1Y)5eG8(UanVwAMJt4QAXKAVE4rae9AZBe61Y9FpWu71vjeSaOIb9idUrrKaAqOdgAPKRdghseaH)Kdy1dtsnKLq5wXGEKb3Oisani0bdTuY1vjeSawDU6eGKOexqquUz18OiAaAjI(CcqEFxicTYfadl2iGTonk)BxAXIJ9piJtyas(uUXmlrjUGeLXgscozgGDiGTonIXllgOHA5)CcqEFxOwARLNob)nGPw()7HpQm4U2PRLpdAET0mhNWv1ckjCvTx)3r(eOwHUk1M3ec1Yb1sGhbq0btTpmPwhTnG9Ckg0Jm4gfrcObHoyOLsUKVJ8jGvZJIObOLi6Zja59DHi0kxamS07bYiqerNG)gWKq)3dFuzWDeALlagwzBWsK8DKpbIYCyAAxwuvYOCbiIM2najrjUGumqd1Y)5eG8(UqT5LBT80j4Vbm1Y)Fp8rLb308AVEqDCcxv7dtQLd3FuT00CuTABYftQfYsG2aMArT6GOJLAnFIkdUJfd6rgCJIib0Gqhm0sjxhmoKiac)jhWQhMKAilHYTIb9idUrrKaAqOdgAPKRRsiybS6C1jajrjUGGOCZQ5rr0a0se95eG8(UqeALlagw69azeiIOtWFdysO)7HpQm4ocTYfadl20JmuHe0G9aigVzXs2IgGwIqwiTD)tRceHw5cGHzwIsCbjkJnKeCYmaJeWwNgXIncyRtJY)g72ILSrOe3)9adZfd0qT8FobiVVlulT1MjZc5wlUR9wg08AVE4rae9AVUkHGfOwvQvOd1cTPw8RwKaAqOxRGR1fKAT1SQ18jQm4Uwo4HjqTzYSqA7(NwfOyqpYGBuejGge6GHwk56GXHebq4p5aw9WKudzjuUvmOhzWnkIeqdcDWqlLCDvcblGvZJIObOLi6Zja59DHi0kxamSenaTeHSqA7(NwficTYfadl9idvibnypaIYnwC)3lI(CcqEFxisaBDAu(3IS3lEX7b]] )

end