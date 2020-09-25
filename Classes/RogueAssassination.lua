-- RogueAssassination.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID = ns.FindUnitBuffByID
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

        -- Rogue - Venthyr   - 323654 - slaughter            (Slaughter)
        slaughter = {
            id = 323654,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 50,
            spendType = "energy",
            
            startsCombat = true,
            texture = 3565724,

            -- toggle = "essences", -- no reason to restrict this one.

            usable = function ()
                return stealthed.all, "requires stealth"
            end,
            
            handler = function ()
                applyBuff( "slaughter_poison" )
                gain( buff.broadside.up and 3 or 2, "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,

            auras = {
                slaughter_poison = {
                    id = 323658,
                    duration = 300,
                    max_stack = 1,        
                },
                slaughter_poison_dot = {
                    id = 323659,
                    duration = 12,
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


    spec:RegisterPack( "Assassination", 20200915, [[devtgcqirPEesfUesLGnHs(KkP0OqPCkuuRcPIEfsvZIsYTqPIDj0VevzyQu5yQuwMkjpdLQMMOcxturBtuu9nrrX4qPsohkvQ1HuP8orrinprvDpKyFOq)tuKkhePs1cvj8qKkPjQsQ4IIIOnkkc1hvjvAKIIqCsrrkRef8sKkHMPOi4MIIK2jLudvLuyPQKQEkQAQIcxvuKQ2QkPOVkks0yrQeTxQ6VImyLomPfJkpwftMIld2SQ8zQ0OrkNwXQffj8AuKzl42uQDl1VHA4uXXffLwoINdz6exxvTDK03fvA8IsoVkrRxLQMpLy)s2FZNHN3Oc4T(Q7U6U7y33Yz8g7I9zo7ZCpVCPd45D0dtQl45B1g880DesrOPvzWTN3rVmGvJpdppc)jhWZtteheDlV8ChH2NlEW25Hg7FqLb3hI(K8qJ9jppp3FcsMw7588gvaV1xD3v3Dh7(woJ3yxSpZVlZ986xOHjEE(XMU65Pngd0EopVbqhppDulDhHueAAvgCx71JD)qXaDulp4iGnhqQ9woTQ2RU7Q788HbjiFgEEKaAqObgFgERV5ZWZdTYfaJ)cp)Hmcqg1ZlAaAj2JlnbjAGjGeHw5cGPww1EW2C4KdEAbvlJuQnh1YQwrjUGeLXgscozgOw2PwcyRtJQLXAZCpVEKb3EEY3r(eWlERVYNHNhALlag)fE(hMKAilXB9npVEKb3EEhmoKiac)jhWlERzVpdpp0kxam(l88hYiazupVEpqgbIiAe83aMe6)E4JkdUJqRCbWulRA5(Vxe95eG8(Uq87ulRA5(Vxe95eG8(UqKa260OAZV2Br2xlRAZUwekX9FpW451Jm42Z7QecwaV4Toh(m88qRCbW4VWZ)WKudzjERV551Jm42Z7GXHebq4p5aEXBDo9z45Hw5cGXFHNxpYGBpVRsiyb88hYiazupVObOLi6Zja59DHi0kxam1YQw2QLa260OAZV2BxvRfl16y)dY4egGuB(uQ9wTmxlRAfL4csugBij4KzGAzNAjGTonQwgR9kp)5YtasIsCbb5T(Mx8wN5(m88qRCbW4VWZFiJaKr98IgGwIOpNaK33fIqRCbWulRA17bYiqerJG)gWKq)3dFuzWDeALlaMAzvB21AWsK8DKpbIYCyAA3AzvlvLmkxaIOPDdqsuIliEE9idU98KVJ8jGx8wNz8z45Hw5cGXFHN)HjPgYs8wFZZRhzWTN3bJdjcGWFYb8I3A2Lpdpp0kxam(l886rgC75DvcblGN)qgbiJ65fnaTerFobiVVleHw5cGPww1Q3dKrGiIgb)nGjH(Vh(OYG7i0kxam1YQw2QvpYqfsqd2dGQLXAVvRfl1MDTIgGwIqwiTD)tRceHw5cGPwMRLvTIsCbjkJnKeCYmqTmwlbS1Pr1YQw2QLa260OAZV2BSRATyP2SRfHsC)3dm1YSN)C5jajrjUGG8wFZlERz3(m88qRCbW4VWZ)WKudzjERV551Jm42Z7GXHebq4p5aEXB9T78z45Hw5cGXFHN)qgbiJ65fnaTerFobiVVleHw5cGPww1kAaAjczH029pTkqeALlaMAzvREKHkKGgShavlLAVvlRA5(Vxe95eG8(UqKa260OAZV2Br2751Jm42Z7QecwaV4fppGqqFaKpdV138z45Hw5cGXFHN)qgbiJ65HgiUxgLXgscozRzvlJ1ERww1MDTgG7)ErQqBar043Pww1YwTzxRblXdUpqlevat6fuBiX9jDuMdtt7wlRAZUw9idUJhCFGwiQaM0lO2qC60lmU0KATyP23pese4qtjUqsgBO28R19yI2Aw1YSNxpYGBp)b3hOfIkGj9cQn4fV1x5ZWZdTYfaJ)cp)Hmcqg1ZBaU)7fPcTberJFNAzvlB1AaU)7fDvcblqeYcPT7FAvatTwSuRb4(VxerBOg)o1YQ2d2MdNCWtlOObEZzKAZNsT3Q1ILAna3)9IuH2aIOrcyRtJQnFk1E7UAzUwlwQ9nU0KebS1Pr1MpLAVDNNxpYGBppxaJnj8lj0Ge0G9LEXBn79z45Hw5cGXFHN)qgbiJ65pyCWGZTJuH2aIOrcyRtJQn)AzFTwSuRb4(VxKk0gqen(DQ1ILAFJlnjraBDAuT5xl7VZZRhzWTN39ReZODc)s69abl08I36C4ZWZdTYfaJ)cp)Hmcqg1Z)cymPw2QLTAFJlnjraBDAuTStTS)UAzUw6c1QhzWD6GXbdo3UwMRLXAFbmMulB1YwTVXLMKiGTonQw2Pw2FxTStThmoyW52rQqBar0ibS1Pr1YCT0fQvpYG70bJdgCUDTm751Jm42Z7(vIz0oHFj9EGGfAEXBDo9z45Hw5cGXFHN)qgbiJ65roqiKeL4cck(0oHFjM6HkGQLrk1EvTwSulrhtcOcTevJbfNUwgRnZVRww1cnqCVS28RnZCNNxpYGBp)dF(iWK07bYiqIduBV4ToZ9z45Hw5cGXFHN)qgbiJ65roqiKeL4cck(0oHFjM6HkGQLrk1EvTwSulrhtcOcTevJbfNUwgRnZVZZRhzWTN35tM3Lt7M4cks8I36mJpdpp0kxam(l88hYiazupp3)9Ie4WuaqO0dtoq87uRfl1Y9FVibomfaek9WKdKo4FlajIe9WuT5x7T7886rgC75fAq63C4FBspm5aEXBn7YNHNxpYGBppzCCcqA6eYrpGNhALlag)fEXBn72NHNxpYGBpFUysWqfMoraeU1(aEEOvUay8x4fV13UZNHNhALlag)fE(dzeGmQNhAG4EzT5xBoVRww1MDThmoyW52rQqBar043XZRhzWTN3gSXKlt4xk8pJjziGAJ8I36B38z45Hw5cGXFHNxpYGBppbuNPDtVGAdip)Hmcqg1ZlkXfKOm2qsWjZa1MFT3I5SwlwQLTAzRwrjUGePbAqOfDosTmwl76UATyPwrjUGePbAqOfDosT5tP2RURwMRLvTSvREKHkKGgShavlLAVvRfl1kkXfKOm2qsWjZa1YyTxXURL5AzUwlwQLTAfL4csugBij4KZrsxDxTmwl7VRww1YwT6rgQqcAWEauTuQ9wTwSuROexqIYydjbNmdulJ1MJCulZ1YSN)C5jajrjUGG8wFZlEXZBGN(dIpdV138z451Jm42ZZ0CyYZdTYfaJ)cV4T(kFgEE9idU98ib0GqZZdTYfaJ)cV4TM9(m88qRCbW4VWZJD88iq886rgC75PQKr5cGNNQg(GNhAG4EzKaUqxl916GheUbtIlaGbvlDwBMPw6c1YwTxvlDwlYbcHenfjqTm75PQKuR2GNhAG4EzIaUqNoyBUPbJx8wNdFgEEOvUay8x45XoEEeiEE9idU98uvYOCbWZtvdFWZJCGqijkXfeu8PDc)sm1dvavB(1ELNNQssTAdEE00UbijkXfeV4ToN(m88qRCbW4VWZFiJaKr98ib0Gqdmrc29dEE9idU98hnes6rgCNcds88HbjPwTbppsani0aJx8wN5(m88qRCbW4VWZFiJaKr98SvB21kAaAjARibijfHueA6i0kxam1AXsTgSeDvcblquMdtt7wlZEE9idU98hnes6rgCNcds88HbjPwTbp)XG8I36mJpdpp0kxam(l886rgC75pAiK0Jm4ofgK45ddssTAdEEdw8I3A2Lpdpp0kxam(l88hYiazupp3)9IOWCGK2MKzoqKa260OAZVwrjUGeLXgscozgOww1Y9FVikmhiPTjzMdejGTonQ28RLTAVvl91EW2C4KdEAbvlZ1sN1ElYU886rgC75rH5ajTnjZCaV4TMD7ZWZdTYfaJ)cpVEKb3E(Jgcj9idUtHbjE(WGKuR2GN3me4iEXB9T78z45Hw5cGXFHN)qgbiJ65HgiUxgnWBoJulJuQ9woRL(APQKr5cqeAG4EzIaUqNoyBUPbJNxpYGBpVsoAdjbtiqlEXB9TB(m886rgC75vYrBi58diWZdTYfaJ)cV4T(2v(m886rgC75dJlnbLYu8nU2qlEEOvUay8x4fV13yVpdpVEKb3EEo1nHFjHmhMqEEOvUay8x4fV45DiWbBZPIpdV138z451Jm42ZRooHlto4bHBpp0kxam(l8I36R8z45Hw5cGXFHx8wZEFgEEOvUay8x4fV15WNHNhALlag)fEXBDo9z45Hw5cGXFHx8wN5(m886rgC75DWYGBpp0kxam(l8I36mJpdpp0kxam(l886rgC75TvctGj9WKKbuHMN)qgbiJ65j6ysavOLOAmO401YyT3YPN3HahSnNkjeCWTb55ZPx8wZU8z451Jm42ZJeqdcnpp0kxam(l8I3A2Tpdpp0kxam(l886rgC75rH5ajTnjZCapVdboyBovsi4GBdYZFZlERVDNpdpp0kxam(l88TAdEE9EenLOO0d3sc)so4CbINxpYGBpVEpIMsuu6HBjHFjhCUaXlERVDZNHNhALlag)fE(dzeGmQNx0a0seYcPT7FAvGi0kxamEE9idU98UFLygTt4xsVhiyHMx8IN3me4i(m8wFZNHNhALlag)fE(dzeGmQNNTApyBoCYbpTGQLrk1MJAPVwrdqlrdaoajHeIkQlyhHw5cGPwlwQ9GT5Wjh80cQwk1Q9yRhAkXfmPJtTmxlRAzRwdW9FVivOnGiA87uRfl1AaU)7fr0gQXVtTwSul0aX9YObEZzKAZNsTxLZAPVwQkzuUaeHgiUxMiGl0Pd2MBAWuRfl1MDTuvYOCbiIM2najrjUGulZ1YQw2Qn7AfnaTeHSqA7(NwficTYfatTwSu7bJdgCUDeYcPT7FAvGibS1Pr1YyTxvlZEE9idU98qtfASTx8wFLpdpp0kxam(l88yhppcepVEKb3EEQkzuUa45PQHp45pyBoCYbpTGIg4nNrQLXAVvRfl1cnqCVmAG3CgP28Pu7v5Sw6RLQsgLlarObI7Ljc4cD6GT5Mgm1AXsTzxlvLmkxaIOPDdqsuIliEEQkj1Qn45)ii9MqaiEXBn79z45Hw5cGXFHNxpYGBppcievatId3qc5mmbE(dzeGmQNp7AnyjIacrfWK4WnKqodtquMdtt7wRfl1svjJYfG4hbP3ecaPww1YwT6rgQqcAWEauTuQ9wTSQLOJjbuHwIQXGItxlJ1((HqIahAkXfsYyd1AXsThAkXfq1YyTxvlRAfL4csugBij4KzGAZV2CwlZE(ZLNaKeL4ccYB9nV4Toh(m88qRCbW4VWZFiJaKr98uvYOCbi(rq6nHaqQLvT69azeichA4PDtCb1aOi0kxam1YQwKdecjrjUGGIpTt4xIPEOcOAzKsTxvl91YwTgG7)ErQqBar043Pw6Sw2Q9wT0xlB1Q3dKrGiCOHN2nXfudGIeTzQwk1ERwMRL5Az2ZRhzWTN)PDc)sm1dva5fV150NHNhALlag)fE(dzeGmQNNQsgLlaXpcsVjeasTSQLTA5(VxK2ymqN4cQbqrKOhMQLrk1EJDxRfl1YwTzxRdzWKrUmrWIkdURLvTihiesIsCbbfFANWVet9qfq1YiLAZrT0xlB1Q3dKrGOb)5cqYGrqKOnt1YyTxvlZ1sFTib0Gqdmrc29d1YCTm751Jm42Z)0oHFjM6HkG8I36m3NHNhALlag)fEE9idU98pTt4xIPEOcip)Hmcqg1ZtvjJYfG4hbP3ecaPww1ICGqijkXfeu8PDc)sm1dvavlJuQL9E(ZLNaKeL4ccYB9nV4ToZ4ZWZdTYfaJ)cp)Hmcqg1ZtvjJYfG4hbP3ecaXZRhzWTNho0Wt7MiGdzS124fV1SlFgEEOvUay8x45pKraYOEEQkzuUae)ii9MqaiEE9idU98OG(DPjaXlERz3(m88qRCbW4VWZFiJaKr98uvYOCbi(rq6nHaq886rgC75vBUpIMx8wF7oFgEEOvUay8x451Jm42ZB)LjOc45pKraYOEEQkzuUae)ii9Mqai1YQwKdecjrjUGGIpTt4xIPEOcOAPu7vE(ZLNaKeL4ccYB9nV4T(2nFgEEOvUay8x45pKraYOEEQkzuUae)ii9MqaiEE9idU982FzcQaEXlE(Jb5ZWB9nFgEEOvUay8x451Jm42ZR3JOPefLE4ws4xYbNlq88hYiazupF21IeqdcnWe1qOww1ARibijfHueA6ebS1Pr1sP27QLvTSv7bJdgCUDKk0gqensaBDAuT5NPRw2Q9GXbdo3oIOnuJeWwNgvlDwlKz)JJdyIkIgvTbuIO3JjPdMOHAzUwMRn)AVDxT0x7T7QLoRfYS)XXbmrfrJQ2akr07XK0bt0qTSQn7Ana3)9IuH2aIOXVtTSQn7Ana3)9IiAd143XZ3Qn4517r0uIIspClj8l5GZfiEXB9v(m88qRCbW4VWZFiJaKr98zxlsani0atudHAzvRblrY3r(eikZHPPDRLvT2ksassrifHMoraBDAuTuQ9opVEKb3E(Jgcj9idUtHbjE(WGKuR2GNhqiOpaYlERzVpdpp0kxam(l886rgC75TvctGj9WKKbuHMN)qgbiJ65j6ysavOLOAmO43Pww1YwTIsCbjkJnKeCYmqT5x7bBZHto4Pfu0aV5msT0zT3I5SwlwQ9GT5Wjh80ckAG3CgPwgPu7XjzRzLqoqBQLzp)5YtasIsCbb5T(Mx8wNdFgEEOvUay8x45pKraYOEEIoMeqfAjQgdkoDTmwl7VRw2PwIoMeqfAjQgdkA(evgCxlRApyBoCYbpTGIg4nNrQLrk1ECs2AwjKd0gpVEKb3EEBLWeyspmjzavO5fV150NHNhALlag)fEESJNhbINxpYGBppvLmkxa88u1Wh88zxRObOLi6Zja59DHi0kxam1AXsTzxREpqgbIiAe83aMe6)E4JkdUJqRCbWuRfl1AWs0vjeSarh7FqgNWaKAzS2B1YQw2Qf5aHqsuIliO4t7e(LyQhQaQ28RnZR1ILAZU2dghm4C7ivTheT43PwM98uvsQvBWZtfAdiIMqFobiVVlKo42mYGBV4ToZ9z45Hw5cGXFHNh745rG451Jm42ZtvjJYfappvn8bpF21kAaAj2JlnbjAGjGeHw5cGPwlwQn7AfnaTeHSqA7(NwficTYfatTwSu7bJdgCUDeYcPT7FAvGibS1Pr1MFT5Sw2P2RQLoRv0a0s0aGdqsiHOI6c2rOvUay88uvsQvBWZtfAdiIM6XLMGenWeqshCBgzWTx8wNz8z45Hw5cGXFHNh745rG451Jm42ZtvjJYfappvn8bpF21cz2)44aMOEpIMsuu6HBjHFjhCUaPwlwQvVhiJarenc(Batc9Fp8rLb3rOvUayQ1ILAna3)9Ie9EmjDWenKma3)9IgCUDTwSu7bJdgCUDur0OQnGse9EmjDWenejGTonQ28R92D1YQw2Q9GXbdo3oIOnuJeWwNgvB(1ERwlwQ1aC)3lIOnuJFNAz2ZtvjPwTbppvOnGiA6HBjDWTzKb3EXBn7YNHNhALlag)fE(dzeGmQNp7ArcObHgyIeS7hQLvTgSejFh5tGOmhMM2Tww1MDTgG7)ErQqBar043Pww1svjJYfGivOnGiAc95eG8(Uq6GBZidURLvTuvYOCbisfAdiIM6XLMGenWeqshCBgzWDTSQLQsgLlarQqBar00d3s6GBZidU986rgC75PcTber9I3A2Tpdpp0kxam(l88hYiazupVObOLiKfsB3)0QarOvUayQLvTIgGwI94stqIgycirOvUayQLvThSnho5GNwq1YiLApojBnReYbAtTSQ9GXbdo3oczH029pTkqKa260OAZV2BEE9idU98u1Eq08I36B35ZWZdTYfaJ)cp)Hmcqg1ZlAaAj2JlnbjAGjGeHw5cGPww1MDTIgGwIqwiTD)tRceHw5cGPww1EW2C4KdEAbvlJuQ94KS1SsihOn1YQw2Q1aC)3lsfAdiIg)o1AXsTacb9bIuh0G7e(LCaYdoYG7i0kxam1YSNxpYGBppvThenV4T(2nFgEEOvUay8x45XoEEeiEE9idU98uvYOCbWZtvdFWZR3dKrGiIgb)nGjH(Vh(OYG7i0kxam1YQw2QTXDcHsC)3dmjrjUGGQLrk1ERwlwQf5aHqsuIliO4t7e(LyQhQaQwk1Y(AzUww1YwTiuI7)EGjjkXfeus5WuHKJ2gWEo1sP27Q1ILAroqiKeL4cck(0oHFjM6HkGQLrk1M51YSNNQssTAdEEekrv7brlDWTzKb3EXB9TR8z45Hw5cGXFHNxpYGBpVdghseaH)Kd45HSeIMuB8VfpFoYPN)HjPgYs8wFZlERVXEFgEEOvUay8x45pKraYOEErdqlr0NtaY77crOvUayQLvTzxlsani0atKGD)qTSQ9GXbdo3o6QecwG43Pww1YwTuvYOCbiIqjQApiAPdUnJm4UwlwQn7A17bYiqerJG)gWKq)3dFuzWDeALlaMAzvlB1AWs0vjeSarc8iaIMYfGATyPwdW9FVivOnGiA87ulRAnyj6QecwGOJ9piJtyasT5tP2B1YCTmxlRApyBoCYbpTGIg4nNrQLrk1YwTSv7TAPV2RQLoRvVhiJarenc(Batc9Fp8rLb3rOvUayQL5APZAroqiKeL4cck(0oHFjM6HkGQL5AzmtxT5Oww1s0XKaQqlr1yqXPRLXAVDLNxpYGBppvThenV4T(wo8z45Hw5cGXFHN)qgbiJ65zRwrdqlrBfjajPiKIqthHw5cGPwlwQL8B4HjUq0wjmLWVKqds2ksassrifHMocz2)44aMAzUww1MDTib0GqdmrneQLvT2ksassrifHMoraBDAuT5tP27QLvTzxRblrY3r(eisGhbq0uUaulRAnyj6QecwGibS1Pr1YyTSVww1YwTgG7)ErQqBar043Pww1AaU)7fr0gQXVtTSQLTAZUwaHG(arUagBs4xsObjOb7lJ2AMcmPwlwQ1aC)3lYfWytc)scnibnyFz87ulZ1AXsTacb9bIuh0G7e(LCaYdoYG7i0kxam1YSNxpYGBppvThenV4T(wo9z45Hw5cGXFHN)qgbiJ65ZUwKaAqObMOgc1YQw9EGmcer0i4Vbmj0)9WhvgChHw5cGPww1AWs0vjeSarc8iaIMYfGAzvRblrxLqWceDS)bzCcdqQnFk1ERww1EW2C4KdEAbfnWBoJulJuQ9MNxpYGBppIMAW5AdbJx8wFlZ9z45Hw5cGXFHN)qgbiJ65ZUwKaAqObMib7(HAzvlB1MDTgSeDvcblqKapcGOPCbOww1AWsK8DKpbIeWwNgvlJ1MJAPV2CulDw7XjzRzLqoqBQ1ILAnyjs(oYNarcyRtJQLoR9UyoRLXAfL4csugBij4KzGAzUww1kkXfKOm2qsWjZa1YyT5WZRhzWTNhYcPT7FAvaV4T(wMXNHNhALlag)fE(dzeGmQN3GLi57iFceL5W00U1YQw2Qn7AHm7FCCatuVhrtjkk9WTKWVKdoxGuRfl1EW4GbNBhPcTberJeWwNgvlJ1E7UAz2ZRhzWTNhrBO6fV13yx(m88qRCbW4VWZFiJaKr98C)3lYfWyt4JKib0JuRfl1AaU)7fPcTberJFhpVEKb3EEhSm42lERVXU9z45Hw5cGXFHN)qgbiJ65na3)9IuH2aIOXVJNxpYGBppxaJnP3NCPx8wF1D(m88qRCbW4VWZFiJaKr98gG7)ErQqBar043XZRhzWTNNdiiGW00UEXB9v38z45Hw5cGXFHN)qgbiJ65na3)9IuH2aIOXVJNxpYGBp)BiaxaJnEXB9vx5ZWZdTYfaJ)cp)Hmcqg1ZBaU)7fPcTberJFhpVEKb3EETpasiAiD0qWlERVI9(m88qRCbW4VWZRhzWTN3vdWrdbGGsCyC75pKraYOEE2Q1aC)3lsfAdiIg)o1AXsTSvB21kAaAjczH029pTkqeALlaMAzv7bJdgCUDKk0gqensaBDAuTmwBoYzTwSuRObOLiKfsB3)0QarOvUayQLvTSv7bJdgCUDeYcPT7FAvGibS1Pr1MFTzETwSu7bJdgCUDeYcPT7FAvGibS1Pr1YyTxDxTSQ9nU0KebS1Pr1YyTzEoRL5AzUwMRLvTzxRb4(VxK8DKpbIqwiTD)tRcy88TAdEExnahneackXHXTx8wFvo8z45Hw5cGXFHNxpYGBpVIOrvBaLi69ys6GjAWZFiJaKr98gG7)ErIEpMKoyIgsgG7)Erdo3UwlwQvuIlirzSHKGtMbQn)AV6opFR2GNxr0OQnGse9EmjDWen4fV1xLtFgEEOvUay8x451Jm42ZRiAu1gqjIEpMKoyIg88hYiazuppB1MDTIgGwIqwiTD)tRceHw5cGPwlwQn7AfnaTerFobiVVleHw5cGPwMRLvTgG7)ErQqBar0ibS1Pr1YyT3URw2P2CulDwlKz)JJdyI69iAkrrPhULe(LCW5cepFR2GNxr0OQnGse9EmjDWen4fV1xL5(m88qRCbW4VWZRhzWTNxr0OQnGse9EmjDWen45pKraYOEE2Qv0a0seYcPT7FAvGi0kxam1YQwrdqlr0NtaY77crOvUayQL5AzvRb4(VxKk0gqen(DQLvTSvRb4(Vx0vjeSarilK2U)Pvbm1AXsT69azeiIOrWFdysO)7HpQm4ocTYfatTSQ1GLORsiybIo2)GmoHbi1YyT3QLzpFR2GNxr0OQnGse9EmjDWen4fV1xLz8z45Hw5cGXFHNxpYGBp)5YtaleCpNexqrIN)qgbiJ65TvKaKKIqkcnDIa260OAPu7D1YQ2SR1aC)3lsfAdiIg)o1YQ2SR1aC)3lIOnuJFNAzvl3)9I2GnMCzc)sH)zmjdbuBu0GZTRLvTqde3lRn)Azx3vlRAnyjs(oYNarcyRtJQLXAZHNhEp4iPwTbp)5YtaleCpNexqrIx8wFf7YNHNhALlag)fEE9idU98HpHjGGstJgZG)OK78ep)Hmcqg1ZBaU)7fPcTberJFhpFR2GNp8jmbeuAA0yg8hLCNN4fV1xXU9z45Hw5cGXFHNxpYGBpF4Jec(JsU4Gb6Kt4BRUGN)qgbiJ65na3)9IuH2aIOXVJNVvBWZh(iHG)OKloyGo5e(2Ql4fV1S)oFgEEOvUay8x451Jm42Z7guZOcMGs2GrdHb3E(dzeGmQN3aC)3lsfAdiIg)oEE49GJKA1g88Ub1mQGjOKny0qyWTx8wZ(B(m88qRCbW4VWZRhzWTN3nOMrfmbL4uJl45pKraYOEEdW9FVivOnGiA8745H3dosQvBWZ7guZOcMGsCQXf8I3A2FLpdpVEKb3E(pcsJa2ipp0kxam(l8Ix88gS4ZWB9nFgEEOvUay8x45XoEEeiEE9idU98uvYOCbWZtvdFWZ7qgmzKlteSOYG7AzvlYbcHKOexqqXN2j8lXupubuTmwl7RLvTSvRblrxLqWcejGTonQ28R9GXbdo3o6QecwGO5tuzWDTwSuRdEq4gmjUaaguTmwBoRLzppvLKA1g88iMgN05YtasUkHGfWlERVYNHNhALlag)fEESJNhbINxpYGBppvLmkxa88u1Wh88oKbtg5YeblQm4Uww1ICGqijkXfeu8PDc)sm1dvavlJ1Y(AzvlB1AaU)7fr0gQXVtTwSulB16GheUbtIlaGbvlJ1MZAzvB21Q3dKrGi6aTKWVexaJnrOvUayQL5Az2ZtvjPwTbppIPXjDU8eGe57iFc4fV1S3NHNhALlag)fEESJNhbINxpYGBppvLmkxa88u1Wh88gG7)ErQqBar043Pww1YwTgG7)EreTHA87uRfl1ARibijfHueA6ebS1Pr1YyT3vlZ1YQwdwIKVJ8jqKa260OAzS2R88uvsQvBWZJyACsKVJ8jGx8wNdFgEEOvUay8x45pKraYOEErdqlrilK2U)PvbIqRCbWulRAZUwdW9FVORsiybIqwiTD)tRcyQLvTgSeDvcblq0X(hKXjmaP28Pu7TAzv7bJdgCUDeYcPT7FAvGibS1Pr1MFTxvlRAroqiKeL4cck(0oHFjM6HkGQLsT3QLvTeDmjGk0sunguC6AzS2mVww1AWs0vjeSarcyRtJQLoR9UyoRn)AfL4csugBij4KzapVEKb3EExLqWc4fV150NHNhALlag)fE(dzeGmQNx0a0seYcPT7FAvGi0kxam1YQw2Q9GT5Wjh80cQwgPu7XjzRzLqoqBQLvThmoyW52rilK2U)PvbIeWwNgvB(1ERww1AWsK8DKpbIeWwNgvlDw7DXCwB(1kkXfKOm2qsWjZa1YSNxpYGBpp57iFc4fV1zUpdpp0kxam(l88pmj1qwI36BEE9idU98oyCirae(toGx8wNz8z45Hw5cGXFHN)qgbiJ65jWJaiAkxaQLvThSnho5GNwqrd8MZi1YiLAVvl91Y(APZAzRw9EGmcer0i4Vbmj0)9WhvgChHw5cGPww1EW4GbNBhPQ9GOf)o1YCTSQLTADS)bzCcdqQnFk1ERwlwQLa260OAZNsTYCykjJnulRAroqiKeL4cck(0oHFjM6HkGQLrk1Y(APVw9EGmcer0i4Vbmj0)9WhvgChHw5cGPwMRLvTSvB21czH029pTkGPwlwQLa260OAZNsTYCykjJnulDw7v1YQwKdecjrjUGGIpTt4xIPEOcOAzKsTSVw6RvVhiJarenc(Batc9Fp8rLb3rOvUayQL5AzvB21IqjU)7bMAzvlB1kkXfKOm2qsWjZa1Yo1saBDAuTmxlJ1MJAzvlB1ARibijfHueA6ebS1Pr1sP27Q1ILAZUwzomnTBTSQvVhiJarenc(Batc9Fp8rLb3rOvUayQLzpVEKb3EExLqWc4fV1SlFgEEOvUay8x45FysQHSeV13886rgC75DW4qIai8NCaV4TMD7ZWZdTYfaJ)cpVEKb3EExLqWc45pKraYOE(SRLQsgLlaretJt6C5jajxLqWculRAjWJaiAkxaQLvThSnho5GNwqrd8MZi1YiLAVvl91Y(APZAzRw9EGmcer0i4Vbmj0)9WhvgChHw5cGPww1EW4GbNBhPQ9GOf)o1YCTSQLTADS)bzCcdqQnFk1ERwlwQLa260OAZNsTYCykjJnulRAroqiKeL4cck(0oHFjM6HkGQLrk1Y(APVw9EGmcer0i4Vbmj0)9WhvgChHw5cGPwMRLvTSvB21czH029pTkGPwlwQLa260OAZNsTYCykjJnulDw7v1YQwKdecjrjUGGIpTt4xIPEOcOAzKsTSVw6RvVhiJarenc(Batc9Fp8rLb3rOvUayQL5AzvB21IqjU)7bMAzvlB1kkXfKOm2qsWjZa1Yo1saBDAuTmxlJ1E7QAzvlB1ARibijfHueA6ebS1Pr1sP27Q1ILAZUwzomnTBTSQvVhiJarenc(Batc9Fp8rLb3rOvUayQLzp)5YtasIsCbb5T(Mx8wF7oFgEEOvUay8x45pKraYOEEKdecjrjUGGQLrk1EvTSQLa260OAZV2RQL(AzRwKdecjrjUGGQLrk1MZAzUww1EW2C4KdEAbvlJuQnhEE9idU98hYyJWDsaBhajEXB9TB(m88qRCbW4VWZFiJaKr98zxlvLmkxaIiMgNe57iFculRAzR2d2MdNCWtlOAzKsT5Oww1sGhbq0uUauRfl1MDTYCyAA3AzvlB1kJnulJ1E7UATyP2d2MdNCWtlOAzKsTxvlZ1YCTSQLTADS)bzCcdqQnFk1ERwlwQLa260OAZNsTYCykjJnulRAroqiKeL4cck(0oHFjM6HkGQLrk1Y(APVw9EGmcer0i4Vbmj0)9WhvgChHw5cGPwMRLvTSvB21czH029pTkGPwlwQLa260OAZNsTYCykjJnulDw7v1YQwKdecjrjUGGIpTt4xIPEOcOAzKsTSVw6RvVhiJarenc(Batc9Fp8rLb3rOvUayQL5AzvROexqIYydjbNmdul7ulbS1Pr1YyT5WZRhzWTNN8DKpb8I36Bx5ZWZdTYfaJ)cpVEKb3EEY3r(eWZFiJaKr98zxlvLmkxaIiMgN05YtasKVJ8jqTSQn7APQKr5cqeX04KiFh5tGAzv7bBZHto4PfuTmsP2CulRAjWJaiAkxaQLvTSvRJ9piJtyasT5tP2B1AXsTeWwNgvB(uQvMdtjzSHAzvlYbcHKOexqqXN2j8lXupubuTmsPw2xl91Q3dKrGiIgb)nGjH(Vh(OYG7i0kxam1YCTSQLTAZUwilK2U)Pvbm1AXsTeWwNgvB(uQvMdtjzSHAPZAVQww1ICGqijkXfeu8PDc)sm1dvavlJuQL91sFT69azeiIOrWFdysO)7HpQm4ocTYfatTmxlRAfL4csugBij4KzGAzNAjGTonQwgRnhE(ZLNaKeL4ccYB9nV4T(g79z45Hw5cGXFHN)qgbiJ65roqiKeL4ccQwk1ERww1EW2C4KdEAbvlJuQLTApojBnReYbAtTStT3QL5AzvlbEeart5cqTSQn7AHSqA7(NwfWulRAZUwdW9FViI2qn(DQLvT2ksassrifHMoraBDAuTuQ9UAzvB21Q3dKrGOK7GKKqdsm1ZdIqRCbWulRAfL4csugBij4KzGAzNAjGTonQwgRnhEE9idU98hYyJWDsaBhajEXB9TC4ZWZRhzWTNhboOb55Hw5cGXFHx8Ix88ubcAWT36RU7Q7UJDFxoI3885QKEAxKNptjD)6TotZ6RlDR2AZGgu7y7GjsTpmP2RfqiOpa6ARLaz2)qatTiSnuR(fSTkGP2dnTDbuSyityAO2ROB1sxXnvGiGP2RfYcPT7FAvatKU8ARvW1ETgG7)Er6YiKfsB3)0QaMRTw2ULfZXIHIHmL09R36mnRVU0TARndAqTJTdMi1(WKAV2JbDT1sGm7FiGPwe2gQv)c2wfWu7HM2UakwmKjmnuBMHUvlDf3ubIaMAVwHmntGePlJhmoyW52xBTcU2R9GXbdo3osxET1Y2TSyowmKjmnu7vSNUvlDf3ubIaMAVwilK2U)Pvbmr6YRTwbx71AaU)7fPlJqwiTD)tRcyU2Az7wwmhlgYeMgQ9QmNUvlDf3ubIaMAVwilK2U)Pvbmr6YRTwbx71AaU)7fPlJqwiTD)tRcyU2Az7wwmhlgkgYus3VERZ0S(6s3QT2mOb1o2oyIu7dtQ9Any5ARLaz2)qatTiSnuR(fSTkGP2dnTDbuSyityAO2Cq3QLUIBQaratTxlKfsB3)0QaMiD51wRGR9Ana3)9I0LrilK2U)PvbmxBTSDllMJfdfdzA2oyIaMAZm1QhzWDTHbjOyXGNh5ahV1xLt2TN3HGFta880rT0DesrOPvzWDTxp29dfd0rT8GJa2CaP2B50QAV6URURyOyGoQntMfC(cyQLdEycu7bBZPsTCG70OyT09ZbCeuTnUzhAkX(9d1QhzWnQwChUmwmOhzWnk6qGd2MtfkQJt4YKdEq4UyqpYGBu0HahSnNk0tjVxqrmvmOhzWnk6qGd2Mtf6PKN(DTHwuzWDXGEKb3OOdboyBovONsEpm2umqh1Y3QdIgwQLOJPwU)7bMArIkOA5GhMa1EW2CQulh4onQwTn16qa2XblY0U1oOAn4gIfd6rgCJIoe4GT5uHEk5HA1brdljKOcQyqpYGBu0HahSnNk0tjphSm4UyqpYGBu0HahSnNk0tjpBLWeyspmjzavOzLdboyBovsi4GBdIsoTAEui6ysavOLOAmO40mElNfd6rgCJIoe4GT5uHEk5HeqdcTIb9idUrrhcCW2CQqpL8qH5ajTnjZCaRCiWbBZPscbhCBquUvmOhzWnk6qGd2Mtf6PK3hbPraBRA1gOO3JOPefLE4ws4xYbNlqkg0Jm4gfDiWbBZPc9uYZ9ReZODc)s69abl0SAEuenaTeHSqA7(NwficTYfatXqXaDuBMml48fWulqfixwRm2qTcnOw9iysTdQwLQobLlaXIb9idUruyAomvmqh1E9asani0QDE16GrOHla1YwJRL6p0ar5cqTqd2dGQD6ApyBovyUyqpYGBe9uYdjGgeAfd6rgCJONsEuvYOCbWQwTbkqde3lteWf60bBZnnySIQg(afObI7Lrc4cn9o4bHBWK4cayq0zMHUaBxrNihies0uKamxmOhzWnIEk5rvjJYfaRA1gOGM2najrjUGyfvn8bkihiesIsCbbfFANWVet9qfq5FvXGEKb3i6PK3rdHKEKb3PWGeRA1gOGeqdcnWy18OGeqdcnWejy3pumOhzWnIEk5D0qiPhzWDkmiXQwTbkhdYQ5rHTSfnaTeTvKaKKIqkcnDeALlaglwmyj6QecwGOmhMM2L5Ib9idUr0tjVJgcj9idUtHbjw1QnqXGLIb9idUr0tjpuyoqsBtYmhWQ5rH7)EruyoqsBtYmhisaBDAu(IsCbjkJnKeCYmalU)7frH5ajTnjZCGibS1Pr5Z2n6pyBoCYbpTGyMoVfzxfd6rgCJONsEhnes6rgCNcdsSQvBGIziWrkg0Jm4grpL8uYrBijycbAXQ5rbAG4Ez0aV5mcJuULt6PQKr5cqeAG4EzIaUqNoyBUPbtXGEKb3i6PKNsoAdjNFabfd6rgCJONsEHXLMGszk(gxBOLIb9idUr0tjpo1nHFjHmhMqfdfd0rT0vmoyW52OIb9idUrXJbr5JG0iGTvTAdu07r0uIIspClj8l5GZfiwnpkzJeqdcnWe1qGLTIeGKuesrOPteWwNgr5owSDW4GbNBhPcTberJeWwNgLFMo2oyCWGZTJiAd1ibS1Pr0jKz)JJdyIkIgvTbuIO3JjPdMObMzo)B3r)T7OtiZ(hhhWevenQAdOerVhtshmrdSY2aC)3lsfAdiIg)oSY2aC)3lIOnuJFNIb9idUrXJbrpL8oAiK0Jm4ofgKyvR2afaHG(aiRMhLSrcObHgyIAiWYGLi57iFceL5W00USSvKaKKIqkcnDIa260ik3vmqh1MP9QvnguTkbQ97yvTOECGAfAqT4gQn3rOvBaNlGKAZiJRtS2m9iO2CPbDTMlN2T2NIeGuRqt7APRxJAnWBoJulMuBUJqd)LA1(YAPRxJyXGEKb3O4XGONsE2kHjWKEysYaQqZQZLNaKeL4ccIYnRMhfIoMeqfAjQgdk(DyXMOexqIYydjbNmdK)bBZHto4Pfu0aV5mcDElMtlwoyBoCYbpTGIg4nNryKYXjzRzLqoqByUyGoQnt7vBJRvnguT5oHqTMbQn3rOnDTcnO2gYsQL93HSQ2pcQnt9DDQf31YHrOAZDeA4VuR2xwlD9Aelg0Jm4gfpge9uYZwjmbM0dtsgqfAwnpkeDmjGk0sunguCAgz)DSdrhtcOcTevJbfnFIkdUzDW2C4KdEAbfnWBoJWiLJtYwZkHCG2umqh1EnH2aIO1gWUZrd1EWTzKb3AavlNIatT4U2ZNqGwQf5aNIb9idUrXJbrpL8OQKr5cGvTAduOcTbertOpNaK33fshCBgzWTvu1WhOKTObOLi6Zja59DHi0kxamwSKTEpqgbIiAe83aMe6)E4JkdUJqRCbWyXIblrxLqWceDS)bzCcdqy8gl2qoqiKeL4cck(0oHFjM6HkGYpZTyj7dghm4C7ivTheT43H5Ib9idUrXJbrpL8OQKr5cGvTAduOcTbert94stqIgyciPdUnJm42kQA4duYw0a0sShxAcs0atajcTYfaJflzlAaAjczH029pTkqeALlaglwoyCWGZTJqwiTD)tRcejGTonk)CYoxrNIgGwIgaCascjevuxWocTYfatXGEKb3O4XGONsEuvYOCbWQwTbkuvYOCbWQwTbkuH2aIOPhUL0b3MrgCBfvn8bkzdz2)44aMOEpIMsuu6HBjHFjhCUaXIf9EGmcer0i4Vbmj0)9WhvgChHw5cGXIfdW9FVirVhtshmrdjdW9FVObNBBXIqMMjqIkIgvTbuIO3JjPdMOH4bJdgCUDKa260O8VDhl2oyCWGZTJiAd1ibS1Pr5FZIfdW9FViI2qn(DyUyqpYGBu8yq0tjpQqBaruRMhLSrcObHgyIeS7hyzWsK8DKpbIYCyAAxwzBaU)7fPcTberJFhwuvYOCbisfAdiIMqFobiVVlKo42mYGBwuvYOCbisfAdiIM6XLMGenWeqshCBgzWnlQkzuUaePcTbertpClPdUnJm4UyGoQ9AQ9GOvBUJqR2mzwi3APVwRhxAcs0ataHUvBMQM1y)TRLUEnQvBtTzYSqU1sa1CzTpmP2gYsQ96sxVofd6rgCJIhdIEk5rv7brZQ5rr0a0seYcPT7FAvGi0kxamSenaTe7XLMGenWeqIqRCbWW6GT5Wjh80cIrkhNKTMvc5aTH1bJdgCUDeYcPT7FAvGibS1Pr5FRyGoQ9AQ9GOvBUJqRwRhxAcs0ataPw6R1ACTzYSqU0TAZu1Sg7VDT01RrTABQ9AcTberR97ulB)oaiuTF00U1EnXxdMlg0Jm4gfpge9uYJQ2dIMvZJIObOLypU0eKObMaseALlagwzlAaAjczH029pTkqeALlagwhSnho5GNwqms54KS1SsihOnSyZaC)3lsfAdiIg)owSaie0hisDqdUt4xYbip4idUJqRCbWWCXaDulpa1((HqThSTn0sT4UwAI4GOB5LN7i0(CXd2oVRxPcnnCWiStg018UES7hYl3HPjp6ocPi00Qm4MDO7xJmb256beOKdTyXGEKb3O4XGONsEuvYOCbWQwTbkiuIQ2dIw6GBZidUTIQg(af9EGmcer0i4Vbmj0)9WhvgChHw5cGHfBnUtiuI7)EGjjkXfeeJuUzXcYbcHKOexqqXN2j8lXupubef2Zml2qOe3)9atsuIliOKYHPcjhTnG9COCNflihiesIsCbbfFANWVet9qfqmsjZzUyqpYGBu8yq0tjphmoKiac)jhWQhMKAilHYnRGSeIMuB8Vfk5iNfd6rgCJIhdIEk5rv7brZQ5rr0a0se95eG8(UqeALlagwzJeqdcnWejy3pW6GXbdo3o6QecwG43HfBuvYOCbiIqjQApiAPdUnJm42ILS17bYiqerJG)gWKq)3dFuzWDeALlagwSzWs0vjeSarc8iaIMYfalwma3)9IuH2aIOXVdldwIUkHGfi6y)dY4egGKpLBmZmRd2MdNCWtlOObEZzegPWgB3O)k6uVhiJarenc(Batc9Fp8rLb3rOvUayyMoroqiKeL4cck(0oHFjM6HkGyMXmD5GfrhtcOcTevJbfNMXBxvmqh1En1Eq0Qn3rOvBMQIeGulDhHu000TATgxlsani0QvBtTnUw9idvO2mv6ETC)3ZQAV(VJ8jqTnwQD6AjWJaiA1s02fSQwZNmTBTxtOnGik9zCb9xGLmzTS97aGq1(rt7w71eFnyUyqpYGBu8yq0tjpQApiAwnpkSjAaAjARibijfHueA6i0kxamwSq(n8WexiAReMs4xsObjBfjajPiKIqthHm7FCCadZSYgjGgeAGjQHalBfjajPiKIqtNiGTonkFk3XkBdwIKVJ8jqKapcGOPCbGLblrxLqWcejGTonIr2ZIndW9FVivOnGiA87WYaC)3lIOnuJFhwSLnGqqFGixaJnj8lj0Ge0G9LrBntbMyXIb4(VxKlGXMe(LeAqcAW(Y43Hzlwaec6dePoOb3j8l5aKhCKb3rOvUayyUyGoQLNMAW5AdbtTpmPwEAe83aMA5)Vh(OYG7Ib9idUrXJbrpL8q0udoxBiySAEuYgjGgeAGjQHal9EGmcer0i4Vbmj0)9WhvgChHw5cGHLblrxLqWcejWJaiAkxayzWs0vjeSarh7FqgNWaK8PCJ1bBZHto4Pfu0aV5mcJuUvmqh1MjZcPT7FAvGAZLg012yPwKaAqObMA12ulhwOv71)DKpbQvBtTxxLqWcuRsGA)o1(WKAd42TwOXFxAXIb9idUrXJbrpL8GSqA7(NwfWQ5rjBKaAqObMib7(bwSLTblrxLqWcejWJaiAkxayzWsK8DKpbIeWwNgXyoOph05XjzRzLqoqBSyXGLi57iFcejGTonIoVlMtgfL4csugBij4KzaMzjkXfKOm2qsWjZamMJIb9idUrXJbrpL8q0gQwnpkgSejFh5tGOmhMM2LfBzdz2)44aMOEpIMsuu6HBjHFjhCUaXILdghm4C7ivOnGiAKa260igVDhZfd6rgCJIhdIEk55GLb3wnpkC)3lYfWyt4JKib0JyXIb4(VxKk0gqen(Dkg0Jm4gfpge9uYJlGXM07tU0Q5rXaC)3lsfAdiIg)ofd6rgCJIhdIEk5XbeeqyAAxRMhfdW9FVivOnGiA87umOhzWnkEmi6PK3BiaxaJnwnpkgG7)ErQqBar043PyqpYGBu8yq0tjpTpasiAiD0qWQ5rXaC)3lsfAdiIg)ofd6rgCJIhdIEk59rqAeW2QwTbkUAaoAiaeuIdJBRMhf2ma3)9IuH2aIOXVJflSLTObOLiKfsB3)0QarOvUayyDW4GbNBhPcTberJeWwNgXyoYPflIgGwIqwiTD)tRceHw5cGHfBhmoyW52rilK2U)PvbIeWwNgLFMBXYbJdgCUDeYcPT7FAvGibS1PrmE1DSEJlnjraBDAeJzEozMzMzLnKfsB3)0QaMi57iFcumOhzWnkEmi6PK3hbPraBRA1gOOiAu1gqjIEpMKoyIgSAEuma3)9Ie9EmjDWenKma3)9IgCUTflIsCbjkJnKeCYmq(xDxXGEKb3O4XGONsEFeKgbSTQvBGIIOrvBaLi69ys6GjAWQ5rHTSfnaTeHSqA7(NwficTYfaJflzlAaAjI(CcqEFxicTYfadZSma3)9IuH2aIOrcyRtJy82DStoOtiZ(hhhWe17r0uIIspClj8l5GZfifd6rgCJIhdIEk59rqAeW2QwTbkkIgvTbuIO3JjPdMObRMhf2enaTeHSqA7(NwficTYfadlrdqlr0NtaY77crOvUayyMLb4(VxKk0gqen(DyXgKfsB3)0QaMORsiybSyrVhiJarenc(Batc9Fp8rLb3rOvUayyzWs0vjeSarh7FqgNWaegVXCXGEKb3O4XGONsEFeKgbSTcEp4iPwTbkNlpbSqW9CsCbfjwnpk2ksassrifHMoraBDAeL7yLTb4(VxKk0gqen(DyLTb4(VxerBOg)oS4(Vx0gSXKlt4xk8pJjziGAJIgCUnlObI7L5ZUUJLblrY3r(eisaBDAeJ5OyqpYGBu8yq0tjVpcsJa2w1Qnqj8jmbeuAA0yg8hLCNNy18OyaU)7fPcTberJFNIb9idUrXJbrpL8(iincyBvR2aLWhje8hLCXbd0jNW3wDbRMhfdW9FVivOnGiA87umOhzWnkEmi6PK3hbPraBRG3dosQvBGIBqnJkyckzdgnegCB18OyaU)7fPcTberJFNIb9idUrXJbrpL8(iincyBf8EWrsTAduCdQzubtqjo14cwnpkgG7)ErQqBar043PyGoQ96ap9hKAFAiWPhMQ9Hj1(rkxaQDeWgr3QntpcQf31EW4GbNBhlg0Jm4gfpge9uY7JG0iGnQyOyGoQ96me4i1AuB1fQv5MWidGkgOJAZKnvOX21QsT5G(AzlN0xBUJqR2RdpZ1sxVgXAZ0STbZOceUSwCx7v0xROexqqwvBUJqR2Rj0gqe1QAXKAZDeA1MXfzIwlwObKCheuBU6i1(WKAryBOwObI7LXAP7beU2C1rQDE1MjZc5w7bBZHRDq1EW2t7w73jwmOhzWnkAgcCekqtfASTvZJcBhSnho5GNwqmsjh0lAaAjAaWbijKqurDb7i0kxamwSCW2C4KdEAbrr7Xwp0uIlyshhMzXMb4(VxKk0gqen(DSyXaC)3lIOnuJFhlwGgiUxgnWBoJKpLRYj9uvYOCbicnqCVmraxOthSn30GXILSPQKr5cqenTBasIsCbHzwSLTObOLiKfsB3)0QarOvUaySy5GXbdo3oczH029pTkqKa260igVI5Ib9idUrrZqGJqpL8OQKr5cGvTAdu(ii9MqaiwrvdFGYbBZHto4Pfu0aV5mcJ3SybAG4Ez0aV5ms(uUkN0tvjJYfGi0aX9YebCHoDW2CtdglwYMQsgLlar00UbijkXfKIb9idUrrZqGJqpL8qaHOcysC4gsiNHjWQZLNaKeL4ccIYnRMhLSnyjIacrfWK4WnKqodtquMdtt7AXcvLmkxaIFeKEtiaewSPhzOcjOb7bquUXIOJjbuHwIQXGItZ47hcjcCOPexijJnyXYHMsCbeJxXsuIlirzSHKGtMbYpNmxmqh1MPCeA1Mjp0Wt7w7fb1aiRQntS21IF1sxShQaQwvQ9k6RvuIliiRQftQL9StoOVwrjUGGQnxAqx71eAdiIw7GQ97umOhzWnkAgcCe6PK3t7e(LyQhQaYQ5rHQsgLlaXpcsVjeacl9EGmceHdn80UjUGAaueALlagwihiesIsCbbfFANWVet9qfqms5k6zZaC)3lsfAdiIg)o0jB3ONn9EGmceHdn80UjUGAauKOntuUXmZmxmqh1Mjw7AXVAPl2dvavRk1EJDtFTirpmHQf)QntKXyGU2lcQbq1Ij1QU60iP2CqFTSLt6Rn3rOv71b)5cqTxhmcyUwrjUGGIfd6rgCJIMHahHEk590oHFjM6HkGSAEuOQKr5cq8JG0BcbGWInU)7fPngd0jUGAauej6HjgPCJDBXcBz7qgmzKlteSOYGBwihiesIsCbbfFANWVet9qfqmsjh0ZMEpqgbIg8NlajdgbrI2mX4vmtpsani0atKGD)aZmxmqh1Mjw7AXVAPl2dvavRGRvDCcxw71but4YAVg4bH7ANxTtRhzOc1I7A1(YAfL4csTQul7RvuIliOyXGEKb3OOziWrONsEpTt4xIPEOciRoxEcqsuIliik3SAEuOQKr5cq8JG0BcbGWc5aHqsuIliO4t7e(LyQhQaIrkSVyqpYGBu0me4i0tjp4qdpTBIaoKXwBJvZJcvLmkxaIFeKEtiaKIb9idUrrZqGJqpL8qb97staIvZJcvLmkxaIFeKEtiaKIb9idUrrZqGJqpL8uBUpIMvZJcvLmkxaIFeKEtiaKIb6O2muo2jt9ltqfOwbxR64eUS2RdOMWL1EnWdc31QsTxvROexqqfd6rgCJIMHahHEk5z)LjOcy15YtasIsCbbr5MvZJcvLmkxaIFeKEtiaewihiesIsCbbfFANWVet9qfquUQyqpYGBu0me4i0tjp7VmbvaRMhfQkzuUae)ii9Mqaifdfd0rTxh1wDHAXubsTYyd1QCtyKbqfd0rTzcJ9i1EDvcblaQwCxBJB2XHm2eLCzTIsCbbv7dtQvOb16qgmzKlRLGfvgCx78QnN0xlxaadQwLa1QbcOMlR97umOhzWnkAWcfQkzuUayvR2afetJt6C5jajxLqWcyfvn8bkoKbtg5YeblQm4MfYbcHKOexqqXN2j8lXupubeJSNfBgSeDvcblqKa260O8pyCWGZTJUkHGfiA(evgCBXIdEq4gmjUaageJ5K5Ib6O2mHXEKAV(VJ8jaQwCxBJB2XHm2eLCzTIsCbbv7dtQvOb16qgmzKlRLGfvgCx78QnN0xlxaadQwLa1QbcOMlR97umOhzWnkAWc9uYJQsgLlaw1QnqbX04KoxEcqI8DKpbSIQg(afhYGjJCzIGfvgCZc5aHqsuIliO4t7e(LyQhQaIr2ZIndW9FViI2qn(DSyHnh8GWnysCbamigZjRS17bYiqeDGws4xIlGXMi0kxammZCXaDuBMWypsTx)3r(eav78Q9AcTberPNN2qnVmvfjaPw6ocPi001oOA)o1QTP2CHAPPuHAVI(ArWb3guTb4j1I7AfAqTx)3r(eO2RdoJIb9idUrrdwONsEuvYOCbWQwTbkiMgNe57iFcyfvn8bkgG7)ErQqBar043HfBgG7)EreTHA87yXITIeGKuesrOPteWwNgX4DmZYGLi57iFcejGTonIXRkgOJA5DGZOHAVUkHGfOwTn1E9Fh5tGArG8DQ1HmysTcU2mzwiTD)tRcu7rrsXGEKb3OObl0tjpxLqWcy18OiAaAjczH029pTkqeALlagwzdzH029pTkGj6QecwawgSeDvcblq0X(hKXjmajFk3yDW4GbNBhHSqA7(NwfisaBDAu(xXc5aHqsuIliO4t7e(LyQhQaIYnweDmjGk0sunguCAgZCwgSeDvcblqKa260i68UyoZxuIlirzSHKGtMbkg0Jm4gfnyHEk5r(oYNawnpkIgGwIqwiTD)tRceHw5cGHfBhSnho5GNwqms54KS1SsihOnSoyCWGZTJqwiTD)tRcejGTonk)BSmyjs(oYNarcyRtJOZ7I5mFrjUGeLXgscozgG5Ib6O2RRsiybQ97WeaowvRgq4AfYaOAfCTFeu7i1QOA1AroWz0qTUqdevWKAFysTcnO2GIKAPRxJA5GhMa1Q1(MEq0asXGEKb3OObl0tjphmoKiac)jhWQhMKAilHYTIb9idUrrdwONsEUkHGfWQ5rHapcGOPCbG1bBZHto4Pfu0aV5mcJuUrp7Pt207bYiqerJG)gWKq)3dFuzWDeALlagwhmoyW52rQApiAXVdZSyZX(hKXjmajFk3SyHa260O8PiZHPKm2alKdecjrjUGGIpTt4xIPEOcigPWE617bYiqerJG)gWKq)3dFuzWDeALlagMzXw2qwiTD)tRcySyHa260O8PiZHPKm2aDEflKdecjrjUGGIpTt4xIPEOcigPWE617bYiqerJG)gWKq)3dFuzWDeALlagMzLncL4(VhyyXMOexqIYydjbNmdWoeWwNgXmJ5GfB2ksassrifHMoraBDAeL7SyjBzomnTll9EGmcer0i4Vbmj0)9WhvgChHw5cGH5Ib9idUrrdwONsEoyCirae(toGvpmj1qwcLBfd6rgCJIgSqpL8CvcblGvNlpbijkXfeeLBwnpkztvjJYfGiIPXjDU8eGKRsiybyrGhbq0uUaW6GT5Wjh80ckAG3CgHrk3ON90jB69azeiIOrWFdysO)7HpQm4ocTYfadRdghm4C7ivTheT43HzwS5y)dY4egGKpLBwSqaBDAu(uK5WusgBGfYbcHKOexqqXN2j8lXupubeJuyp969azeiIOrWFdysO)7HpQm4ocTYfadZSylBilK2U)PvbmwSqaBDAu(uK5WusgBGoVIfYbcHKOexqqXN2j8lXupubeJuyp969azeiIOrWFdysO)7HpQm4ocTYfadZSYgHsC)3dmSytuIlirzSHKGtMbyhcyRtJyMXBxXInBfjajPiKIqtNiGTonIYDwSKTmhMM2LLEpqgbIiAe83aMe6)E4JkdUJqRCbWWCXaDulDLm2iCxBgGTdGKAXDT2)GmobOwrjUGGQvLAZb91sxVg1MlnORL87EA3AXFP2PR9kuTS9DQvW1MJAfL4ccI5AXKAzpQw2Yj91kkXfeeZfd6rgCJIgSqpL8oKXgH7Ka2oasSAEuqoqiKeL4ccIrkxXIa260O8VIE2qoqiKeL4ccIrk5KzwhSnho5GNwqmsjhfd0rT0fbWP2VtTx)3r(eOwvQnh0xlURvdHAfL4ccQw2YLg01ggQt7wBa3U1cn(7sRwTn12yPwuRoiAyH5Ib9idUrrdwONsEKVJ8jGvZJs2uvYOCbiIyACsKVJ8jal2oyBoCYbpTGyKsoyrGhbq0uUayXs2YCyAAxwSjJnW4T7Sy5GT5Wjh80cIrkxXmZSyZX(hKXjmajFk3SyHa260O8PiZHPKm2alKdecjrjUGGIpTt4xIPEOcigPWE617bYiqerJG)gWKq)3dFuzWDeALlagMzXw2qwiTD)tRcySyHa260O8PiZHPKm2aDEflKdecjrjUGGIpTt4xIPEOcigPWE617bYiqerJG)gWKq)3dFuzWDeALlagMzjkXfKOm2qsWjZaSdbS1PrmMJIb9idUrrdwONsEKVJ8jGvNlpbijkXfeeLBwnpkztvjJYfGiIPXjDU8eGe57iFcWkBQkzuUaermnojY3r(eG1bBZHto4PfeJuYblc8iaIMYfawS5y)dY4egGKpLBwSqaBDAu(uK5WusgBGfYbcHKOexqqXN2j8lXupubeJuyp969azeiIOrWFdysO)7HpQm4ocTYfadZSylBilK2U)PvbmwSqaBDAu(uK5WusgBGoVIfYbcHKOexqqXN2j8lXupubeJuyp969azeiIOrWFdysO)7HpQm4ocTYfadZSeL4csugBij4Kza2Ha260igZrXaDulDLm2iCxBgGTdGKAXDT8zu78QD6AD02a2ZPwTn1osT5oHqTgCTbaHQ1O2QluRqt7AZKnvOX21A(qTcU2mUiVmv6EEzi0flg0Jm4gfnyHEk5DiJnc3jbSDaKy18OGCGqijkXfeeLBSoyBoCYbpTGyKcBhNKTMvc5aTHDUXmlc8iaIMYfawzdzH029pTkGHv2gG7)EreTHA87WYwrcqskcPi00jcyRtJOChRS17bYiquYDqssObjM65brOvUayyjkXfKOm2qsWjZaSdbS1PrmMJIb9idUrrdwONsEiWbnOIHIb6O2mjcb9bqfd6rgCJIacb9bquo4(aTqubmPxqTbRMhfObI7LrzSHKGt2AwmEJv2gG7)ErQqBar043HfBzBWs8G7d0crfWKEb1gsCFshL5W00USYwpYG74b3hOfIkGj9cQneNo9cJlnXIL3pese4qtjUqsgBiF3JjARzXCXaDulDpKREjQ2pcQ9IagBQn3rOv71eAdiIw73jwBMi4GP2hMuBMmlK2U)PvbI1MPhb1M7i0QnJlQ97ulh8WeOwT230dIgqQvr1gWTBTkQ2rQL8BuTpmP2B3HQ18jt7w71eAdiIglg0Jm4gfbec6dGONsECbm2KWVKqdsqd2xA18OyaU)7fPcTberJFhwSbzH029pTkGj6Qecwalwma3)9IiAd143H1bBZHto4Pfu0aV5ms(uUzXIb4(VxKk0gqensaBDAu(uUDhZwS8gxAsIa260O8PC7UIb6Ow6UiGTJuRGRvdJBx719ReZODT5ocTAVMqBar0AvuTbC7wRIQDKAZf3xRulbq)Gu701gWOPDRvR99db2HQg(qThfj1IPcKAfAqTeWwNEA3AnFIkdURf)QvOb1(gxAsXGEKb3OiGqqFae9uYZ9ReZODc)s69abl0SAEuoyCWGZTJuH2aIOrcyRtJYN9wSyaU)7fPcTberJFhlwEJlnjraBDAu(S)UIb9idUrraHG(ai6PKN7xjMr7e(L07bcwOz18O8cymHn2EJlnjraBDAe7W(7yMUWbJdgCUnZm(cymHn2EJlnjraBDAe7W(7yNdghm4C7ivOnGiAKa260iMPlCW4GbNBZCXGEKb3OiGqqFae9uY7HpFeys69azeiXbQTvZJcYbcHKOexqqXN2j8lXupubeJuUYIfIoMeqfAjQgdkonJz(DSGgiUxMFM5UIb9idUrraHG(ai6PKNZNmVlN2nXfuKy18OGCGqijkXfeu8PDc)sm1dvaXiLRSyHOJjbuHwIQXGItZyMFxXGEKb3OiGqqFae9uYtObPFZH)Tj9WKdy18OW9FVibomfaek9WKde)owSW9FVibomfaek9WKdKo4FlajIe9Wu(3URyqpYGBueqiOpaIEk5rghNaKMoHC0dumOhzWnkcie0harpL8YftcgQW0jcGWT2hOyqpYGBueqiOpaIEk5zd2yYLj8lf(NXKmeqTrwnpkqde3lZpN3Xk7dghm4C7ivOnGiA87umqh1MjcoyQ96b1zA3AZehuBav7dtQfYcoFbQLOTlulMulttiul3)9qwv78Q1bJqdxaI1s3d5QxIQvixwRGR1fKAfAqTbCUasQ9GXbdo3UwofbMAXDTkvDckxaQfAWEauSyqpYGBueqiOpaIEk5ra1zA30lO2aYQZLNaKeL4ccIYnRMhfrjUGeLXgscozgi)BXCAXcBSjkXfKinqdcTOZryKDDNflIsCbjsd0Gql6CK8PC1DmZIn9idvibnypaIYnlweL4csugBij4KzagVIDZmZwSWMOexqIYydjbNCos6Q7yK93XIn9idvibnypaIYnlweL4csugBij4KzagZroyM5IHIb6OwEb0Gqdm1s3pYGBuXaDuR1JlnKObMasT4U2Bzq3QLVvhenSu71)DKpbkg0Jm4gfrcObHgyOq(oYNawnpkIgGwI94stqIgycirOvUayyDW2C4KdEAbXiLCWsuIlirzSHKGtMbyhcyRtJymZlgOJA5)CcqEFxOw6RLNgb)nGPw()7HpQm4MUvBMSrFcuBUqTFeulUHADdyonuRGRvDCcxw71vjeSa1k4AfAqT2601kkXfKANxTJu7GQTXsTOwDq0WsTxcIv1IW1QHqTyHgqQ1wNUwrjUGuRYnHrgavRdb)gjwmOhzWnkIeqdcnWqpL8CW4qIai8NCaREysQHSek3kg0Jm4gfrcObHgyONsEUkHGfWQ5rrVhiJarenc(Batc9Fp8rLb3rOvUayyX9FVi6Zja59DH43Hf3)9IOpNaK33fIeWwNgL)Ti7zLncL4(VhykgOJA5)CcqEFxGUvlD3XjCzTysTxp8iaIwT5ocTA5(VhyQ96QecwauXGEKb3Oisani0ad9uYZbJdjcGWFYbS6HjPgYsOCRyqpYGBuejGgeAGHEk55QecwaRoxEcqsuIliik3SAEuenaTerFobiVVleHw5cGHfBeWwNgL)TRSyXX(hKXjmajFk3yMLOexqIYydjbNmdWoeWwNgX4vfd0rT8FobiVVlul91YtJG)gWul))9WhvgCx701YNbDRw6UJt4YAbLeUS2R)7iFcuRqtLAZDcHA5GAjWJaiAGP2hMuRJ2gWEofd6rgCJIib0Gqdm0tjpY3r(eWQ5rr0a0se95eG8(UqeALlagw69azeiIOrWFdysO)7HpQm4ocTYfadRSnyjs(oYNarzomnTllQkzuUaert7gGKOexqkgOJA5)CcqEFxO2CZRwEAe83aMA5)Vh(OYGB6wTxpOooHlR9Hj1YH7pQw661OwTn5Hj1czjqBatTOwDq0WsTMprLb3XIb9idUrrKaAqObg6PKNdghseaH)Kdy1dtsnKLq5wXGEKb3Oisani0ad9uYZvjeSawDU8eGKOexqquUz18OiAaAjI(CcqEFxicTYfadl9EGmcer0i4Vbmj0)9WhvgChHw5cGHfB6rgQqcAWEaeJ3SyjBrdqlrilK2U)PvbIqRCbWWmlrjUGeLXgscozgGrcyRtJyXgbS1Pr5FJDzXs2iuI7)EGH5Ib6Ow(pNaK33fQL(AZKzHCRf31Eld6wTxp8iaIwTxxLqWcuRk1k0GAH2ul(vlsani0QvW16csT2Aw1A(evgCxlh8WeO2mzwiTD)tRcumOhzWnkIeqdcnWqpL8CW4qIai8NCaREysQHSek3kg0Jm4gfrcObHgyONsEUkHGfWQ5rr0a0se95eG8(UqeALlagwIgGwIqwiTD)tRceHw5cGHLEKHkKGgShar5glU)7frFobiVVlejGTonk)Br27fV49]] )

end