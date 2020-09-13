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
        lethal_poison = {
            alias = { "deadly_poison", "wound_poison", "slaughter_poison" },
            aliasMode = "longest",
            aliasType = "debuff",
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
                if buff.deadly_poison.down and buff.wound_poison.down then return class.abilities.deadly_poison.texture end
                if buff.crippling_poison.down then return class.abilities.crippling_poison.texture end
            end,

            usable = function ()
                return ( buff.deadly_poison.down and buff.wound_poison.down and action.deadly_poison.known ) or
                    ( time == 0 and buff.crippling_poison.down and action.crippling_poison.known )
            end,

            handler = function ()
                if buff.deadly_poison.down and buff.wound_poison.down then applyBuff( "deadly_poison" )
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
                echoing_reprimand = {
                    id = 323559,
                    duration = 45,
                    max_stack = 6,
                },                
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
                    max_stack = 3,
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


    spec:RegisterPack( "Assassination", 20200904.1, [[devGfcqisjpsc0LqkOSju4tsKugfQKtHkAvif5vOOMfPu3sLK2LGFPsyyQuCmvQwMkrpdvQMgQuUMkj2MeP8njGmojsLZjbuRtIeENePkAEse3dj2hsP)jbqoisHAHQK6HifyIifKlIuuTrja0hrkknsjsv6KsaQvII8sjsQMPeaCtjazNsidvIKSuKc5POQPkbDvKcQ2Qej6RsKQWyLiv1Ef6VsAWsDyklgLESkMmjxgSzv5ZuPrJuDALwTea1RrfMnvDBs1Uv8BOgovCCKIILJ45qMoX1vvBhj9DjQgVeQZlrz9QuA(KI9l649yHrELjqSOlV5YBUPaFd3c3V8gUXTslYlL5arEh7WH5cr(X0HipngHmeAhtw8e5DSY8ytflmYJWFYbI80fXbvkU4c3vO)zdhS(fOv)7nzXZHyp5c0QFUiYZ(xVuapr2iVYeiw0L3C5n3uGVHBH7xEd34g3I82xOJjrE(vNge5PVkfmr2iVcqNiFbZMgJqgcTJjlEYMgHD)qYubZMhCeqNfizFx7SV8MlVjzkzQGztdOBJlGkfjtfm7RMnnwPav2L67HJSfC2k4zFVKTDKfpz7xKesMky2xnBAeOJPczlgXfK6(cjtfm7RMnnwPav20Wrq2fWcOJYMl8xqRcYg)YgjG5f6CgsMky2xnBAaEOcebuzdfJSX9VJjGku6NTGZwHLqPFakgzJ7FhtaviY7xKGIfg5rcyEHoOIfgl6ESWipmgRhuXRJ8hYkazTiVyEyKWSU0fKyEoasagJ1dQSzK9bRZIRo4Deu20sjBULnJSfJ4csqwDOk4QAHSVA2eq32bLnTzxArE7ilEI8KVJ8jquIfDzSWipmgRhuXRJ8pmPoqXsSO7rE7ilEI8oySVsae(toquIfX9yHrEymwpOIxh5pKvaYArE7wGSceq0j4Vcuv0)9Whtw8eGXy9GkBgzZ(FVa6Zka59DHW3jBgzZ(FVa6Zka59DHab0TDqzxs23dCpBgzRv2iuL9)EGkYBhzXtK31ieSarjwe3Ifg5HXy9GkEDK)Hj1bkwIfDpYBhzXtK3bJ9vcGWFYbIsSORelmYdJX6bv86iVDKfprExJqWce5pKvaYArEX8Wib0NvaY77cbymwpOYMr2CLnb0TDqzxs23VmBnAY2r)7L1XVaj7sOK99S5mBgzlgXfKGS6qvWv1czF1SjGUTdkBAZ(Yi)PSJhQIrCbbfl6EuIfvAXcJ8WySEqfVoYFiRaK1I8I5HrcOpRaK33fcWySEqLnJSTBbYkqarNG)kqvr)3dFmzXtagJ1dQSzKTwzRWsG8DKpbcYE4yh3SzKnvJSgRhcODC9qvmIlirE7ilEI8KVJ8jquIfvGIfg5HXy9GkEDK)Hj1bkwIfDpYBhzXtK3bJ9vcGWFYbIsSOsxSWipmgRhuXRJ82rw8e5DncblqK)qwbiRf5fZdJeqFwbiVVleGXy9GkBgzB3cKvGaIob)vGQI(Vh(yYINamgRhuzZiBUY2oYsfQWa6lGYM2SVNTgnzRv2I5HrcqXiBC)7yceGXy9GkBoZMr2IrCbjiRoufCvTq20Mnb0TDqzZiBUYMa62oOSlj77LUS1OjBTYgHQS)3duzZzK)u2XdvXiUGGIfDpkXIkWXcJ8WySEqfVoY)WK6aflXIUh5TJS4jY7GX(kbq4p5arjw09BIfg5HXy9GkEDK)qwbiRf5fZdJeqFwbiVVleGXy9GkBgzlMhgjafJSX9VJjqagJ1dQSzKTDKLkuHb0xaLnLSVNnJSz)Vxa9zfG8(UqGa62oOSlj77bUh5TJS4jY7AecwGOeLipGqWCauSWyr3Jfg5HXy9GkEDK)qwbiRf5HbiULfKvhQcUQBfNnTzFpBgzRv2kG9)EbQWOarSW3jBgzZv2ALTclHdEoWietav95nDOY(jtq2dh74MnJS1kB7ilEch8CGriMaQ6ZB6qyN6ZVU0LS1Oj7337Re4q3iUqvwDi7sY29Oc6wXzZzK3oYINi)bphyeIjGQ(8MoeLyrxglmYdJX6bv86i)HScqwlYRa2)7fOcJceXcFNSzKnxzRa2)7fCncblqakgzJ7Fhtav2A0KTcy)VxarFPg(ozZi7dwNfxDW7iOGcE7zLSlHs23ZwJMSva7)9cuHrbIybcOB7GYUekzF)MS5mBnAY(TU0Lkb0TDqzxcLSVFtK3oYINipRhJvv8Rk0HkmGEzrjwe3Jfg5HXy9GkEDK)qwbiRf5pySxHlFcuHrbIybcOB7GYUKS5E2A0KTcy)VxGkmkqel8DYwJMSFRlDPsaDBhu2LKn3VjYBhzXtK39Be1Atf)Q2Tabl0JsSiUflmYdJX6bv86i)HScqwlY)8ymjBUYMRSFRlDPsaDBhu2xnBUFt2CMnnSSTJS4PEWyVcx(KnNztB2ppgtYMRS5k736sxQeq32bL9vZM73K9vZ(GXEfU8jqfgfiIfiGUTdkBoZMgw22rw8upySxHlFYMZiVDKfprE3VruRnv8RA3ceSqpkXIUsSWipmgRhuXRJ8hYkazTipYb8(QyexqqHNnv8RYXSubu20sj7lZwJMSj2QQavyKGPuOWoztB2L2nzZiByaIBzzxs2fOBYwJMSFRlDPsaDBhu2LK99BI82rw8e5F4ZhbQQDlqwbQSGPhLyrLwSWipmgRhuXRJ8hYkazTipYb8(QyexqqHNnv8RYXSubu20sj7lZwJMSj2QQavyKGPuOWoztB2L2nzRrt2V1LUujGUTdk7sY((nrE7ilEI8oFY(kBh3kR3qsuIfvGIfg5HXy9GkEDK)qwbiRf5z)VxGaho8acvFyYbcFNS1OjB2)7fiWHdpGq1hMCG6b)hbibKyhoYUKSVFtK3oYINiVqhQ)Hf)hv9HjhikXIkDXcJ82rw8e5jRJJhQ7uro2bI8WySEqfVokXIkWXcJ82rw8e5lht8kQWovcGWJnhiYdJX6bv86Oel6(nXcJ8WySEqfVoYFiRaK1I8Wae3YYUKSVYnzZiBTY(GXEfU8jqfgfiIf(orE7ilEI86GoMuwf)Q()zvvfbmDuuIfD)ESWipmgRhuXRJ82rw8e5jG5SJB95nDaf5pKvaYArEXiUGeKvhQcUQwi7sY(E4kzRrt2CLnxzlgXfKaDW8c9GZrYM2SlD3KTgnzlgXfKaDW8c9GZrYUekzF5nzZz2mYMRSTJSuHkmG(cOSPK99S1OjBXiUGeKvhQcUQwiBAZ(YcC2CMnNzRrt2CLTyexqcYQdvbxDos9YBYM2S5(nzZiBUY2oYsfQWa6lGYMs23ZwJMSfJ4csqwDOk4QAHSPnBUXTS5mBoJ8NYoEOkgXfeuSO7rjkrEf8SVxIfgl6ESWipmgRhuXRJ8hYkazTiVwzJeW8cDqfmVpYBhzXtKNJ9WruIfDzSWiVDKfprEKaMxOh5HXy9GkEDuIfX9yHrEymwpOIxh5XorEeirE7ilEI8unYASEiYt18FiYddqCllqaxyYM5SDWlcpGQY6bqHYMMYUaLnnSS5k7lZMMYg5aEFLUHeiBoJ8unsDmDiYddqClRsaxyQhSo7oGkkXI4wSWipmgRhuXRJ8yNipcKiVDKfprEQgznwpe5PA(pe5roG3xfJ4cck8SPIFvoMLkGYUKSVmYt1i1X0HipAhxpufJ4csuIfDLyHrEymwpOIxh5pKvaYArEKaMxOdQab7(HiVDKfpr(J59v7ilEQ(fjrE)IK6y6qKhjG5f6GkkXIkTyHrEymwpOIxh5pKvaYArEUYwRSfZdJe0nKaKQHqgcTtagJ1dQS1OjBfwcUgHGfii7HJDCZMZiVDKfpr(J59v7ilEQ(fjrE)IK6y6qK)OqrjwubkwyKhgJ1dQ41rE7ilEI8hZ7R2rw8u9lsI8(fj1X0HiVclrjwuPlwyKhgJ1dQ41rE7ilEI8hZ7R2rw8u9lsI8(fj1X0HiVAjWrIsSOcCSWipmgRhuXRJ8hYkazTipmaXTSGcE7zLSPLs23Vs2mNnvJSgRhcWae3YQeWfM6bRZUdOI82rw8e5nYXgOkycbgjkXIUFtSWiVDKfprEJCSbQoFpcI8WySEqfVokXIUFpwyK3oYINiVFDPlOAb4VYvhgjYdJX6bv86Oel6(LXcJ82rw8e5zn3k(vfYE4af5HXy9GkEDuIsK3HahSoRjXcJfDpwyK3oYINiV544lR6GxeEI8WySEqfVokXIUmwyK3oYINipsaZl0J8WySEqfVokXI4ESWipmgRhuXRJ82rw8e51nchGQ(WKQcmHEK)qwbiRf5j2QQavyKGPuOWoztB23VsK3HahSoRjveCWJcf5VsuIfXTyHrEymwpOIxh5hthI82Ti6gXq1hEKk(vDWLdKiVDKfprE7weDJyO6dpsf)Qo4YbsuIfDLyHrE7ilEI8oyzXtKhgJ1dQ41rjkrE1sGJelmw09yHrEymwpOIxh5pKvaYAr(dwNfxDW7iOSPLs2ClBMZwmpmsqbGdqQiHyI5c6bymwpOYMr2CLTcy)VxGkmkqel8DYwJMSva7)9ci6l1W3jBnAYggG4wwqbV9Ss2Lqj7lVs2mNnvJSgRhcWae3YQeWfM6bRZUdOYwJMS1kBQgznwpeq746HQyexqYMZSzKnxzRv2I5HrcqXiBC)7yceGXy9GkBnAYwRSva7)9cuHrbIyHVt2A0K9bJ9kC5takgzJ7FhtGab0TDqztB2xMnNrE7ilEI8WqfgSEuIfDzSWipmgRhuXRJ8yNipcKiVDKfprEQgznwpe5PA(pe5pyDwC1bVJGck4TNvYM2SVNTgnzddqCllOG3Ewj7sOK9LxjBMZMQrwJ1dbyaIBzvc4ct9G1z3buzRrt2ALnvJSgRhcODC9qvmIlirEQgPoMoe5)iO(wVhirjwe3Jfg5HXy9GkEDK)qwbiRf5PAK1y9q4JG6B9EGKnJSTBbYkqao0X74wz9McqbymwpOYMr2ihW7RIrCbbfE2uXVkhZsfqztlLSVmBMZMRSva7)9cuHrbIyHVt20u2CL99SzoBUY2UfiRab4qhVJBL1Bkafi2Wr2uY(E2CMnNzZzK3oYINi)ZMk(v5ywQakkXI4wSWipmgRhuXRJ8hYkazTipvJSgRhcFeuFR3dKSzKnxzZ(FVa9vPGPY6nfGciXoCKnTuY(EboBnAYMRS1kBhYIjRuwLGftw8KnJSroG3xfJ4cck8SPIFvoMLkGYMwkzZTSzoBUY2UfiRabf(Z6HQcJGaXgoYM2SVmBoZM5SrcyEHoOceS7hYMZS5mYBhzXtK)ztf)QCmlvafLyrxjwyKhgJ1dQ41rE7ilEI8pBQ4xLJzPcOi)HScqwlYt1iRX6HWhb1369ajBgzJCaVVkgXfeu4ztf)QCmlvaLnTuYM7r(tzhpufJ4cckw09OelQ0Ifg5HXy9GkEDK)qwbiRf5PAK1y9q4JG6B9EGKnJS5kB2)7fy97OqRccFNS1OjBTYwmpmsGkmy9k5JOhGXy9GkBgzRv22TazfiOWFwpuvyeeGXy9GkBoJ82rw8e5nD2pIEuIfvGIfg5HXy9GkEDK3oYINiV(xwVjqK)qwbiRf5PAK1y9q4JG6B9EGKnJSroG3xfJ4cck8SPIFvoMLkGYMs2xg5pLD8qvmIliOyr3JsSOsxSWipmgRhuXRJ8hYkazTipvJSgRhcFeuFR3dKiVDKfprE9VSEtGOeLi)rHIfgl6ESWipmgRhuXRJ82rw8e5TBr0nIHQp8iv8R6Glhir(dzfGSwKxRSrcyEHoOcM3NnJS1nKaKQHqgcTtLa62oOSPK9nzZiBUY(GXEfU8jqfgfiIfiGUTdk7skaLnxzFWyVcx(eq0xQbcOB7GYMMYgOz(RJdOcgIovBauLy3Ij1dMy(S5mBoZUKSVFt2mN99BYMMYgOz(RJdOcgIovBauLy3Ij1dMy(SzKTwzRa2)7fOcJceXcFNSzKTwzRa2)7fq0xQHVtKFmDiYB3IOBedvF4rQ4x1bxoqIsSOlJfg5HXy9GkEDK)qwbiRf51kBKaMxOdQG59zZiBfwcKVJ8jqq2dh74MnJS1nKaKQHqgcTtLa62oOSPK9nrE7ilEI8hZ7R2rw8u9lsI8(fj1X0HipGqWCauuIfX9yHrEymwpOIxh5TJS4jYRBeoav9Hjvfyc9i)HScqwlYtSvvbQWibtPqHVt2mYMRSfJ4csqwDOk4QAHSlj7dwNfxDW7iOGcE7zLSPPSVhUs2A0K9bRZIRo4DeuqbV9Ss20sj7Jtv3kUICGrLnNr(tzhpufJ4cckw09OelIBXcJ8WySEqfVoYFiRaK1I8eBvvGkmsWukuyNSPnBUFt2xnBITQkqfgjykfkO(etw8KnJSpyDwC1bVJGck4TNvYMwkzFCQ6wXvKdmQiVDKfprEDJWbOQpmPQatOhLyrxjwyKhgJ1dQ41rEStKhbsK3oYINipvJSgRhI8un)hI8ALTyEyKa6Zka59DHamgRhuzRrt2ALTDlqwbci6e8xbQk6)E4JjlEcWySEqLTgnzRWsW1ieSabh9Vxwh)cKSPn77zZiBUYg5aEFvmIliOWZMk(v5ywQak7sYU0YwJMS1k7dg7v4YNavBwe9W3jBoJ8unsDmDiYtfgfiIvrFwbiVVlup4rTYINOelQ0Ifg5HXy9GkEDKh7e5rGe5TJS4jYt1iRX6HipvZ)HiVwzlMhgjmRlDbjMNdGeGXy9GkBnAYwRSfZdJeGIr24(3XeiaJX6bv2A0K9bJ9kC5takgzJ7FhtGab0TDqzxs2xj7RM9LzttzlMhgjOaWbivKqmXCb9amgRhurEQgPoMoe5PcJceXQZ6sxqI55ai1dEuRS4jkXIkqXcJ8WySEqfVoYJDI8iqI82rw8e5PAK1y9qKNQ5)qKxRSbAM)64aQGDlIUrmu9HhPIFvhC5ajBnAY2UfiRabeDc(Ravf9Fp8XKfpbymwpOYwJMSva7)9ce7wmPEWeZxva7)9ckC5t2A0K9bJ9kC5tWq0PAdGQe7wmPEWeZhiGUTdk7sY((nzZiBUY(GXEfU8jGOVudeq32bLDjzFpBnAYwbS)3lGOVudFNS5mYt1i1X0HipvyuGiw9HhPEWJALfprjwuPlwyKhgJ1dQ41r(dzfGSwKxRSrcyEHoOceS7hYMr2kSeiFh5tGGSho2XnBgzRv2kG9)EbQWOarSW3jBgzt1iRX6HavyuGiwf9zfG8(Uq9Gh1klEYMr2unYASEiqfgfiIvN1LUGeZZbqQh8OwzXt2mYMQrwJ1dbQWOarS6dps9Gh1klEI82rw8e5PcJceXIsSOcCSWipmgRhuXRJ8hYkazTiVyEyKaumYg3)oMabymwpOYMr2I5HrcZ6sxqI55aibymwpOYMr2hSolU6G3rqztlLSpovDR4kYbgv2mY(GXEfU8jafJSX9VJjqGa62oOSlj77rE7ilEI8uTzr0JsSO73elmYdJX6bv86i)HScqwlYlMhgjmRlDbjMNdGeGXy9GkBgzRv2I5HrcqXiBC)7yceGXy9GkBgzFW6S4QdEhbLnTuY(4u1TIRihyuzZiBUYwbS)3lqfgfiIf(ozRrt2acbZbcux0INk(vDaYdoYINamgRhuzZzK3oYINipvBwe9Oel6(9yHrEymwpOIxh5XorEeirE7ilEI8unYASEiYt18FiYB3cKvGaIob)vGQI(Vh(yYINamgRhuzZiBUYEWtfHQS)3duvXiUGGYMwkzFpBnAYg5aEFvmIliOWZMk(v5ywQakBkzZ9S5mBgzZv2iuL9)EGQkgXfeu1yXuHQJnkqFpztj7BYwJMSroG3xfJ4cck8SPIFvoMLkGYMwkzxAzZzKNQrQJPdrEeQs1MfrVEWJALfprjw09lJfg5HXy9GkEDK3oYINiVdg7ReaH)Kde5HIfIvnD8FKip3UsK)Hj1bkwIfDpkXIUZ9yHrEymwpOIxh5pKvaYArEX8Wib0NvaY77cbymwpOYMr2ALnsaZl0bvGGD)q2mY(GXEfU8j4AecwGW3jBgzZv2unYASEiGqvQ2Si61dEuRS4jBnAYwRSTBbYkqarNG)kqvr)3dFmzXtagJ1dQSzKnxzRWsW1ieSabc8iaIUX6HS1OjBfW(FVavyuGiw47KnJSvyj4AecwGGJ(3lRJFbs2Lqj77zZz2CMnJSpyDwC1bVJGck4TNvYMwkzZv2CL99Szo7lZMMY2UfiRabeDc(Ravf9Fp8XKfpbymwpOYMZSPPSroG3xfJ4cck8SPIFvoMLkGYMZSPTau2ClBgztSvvbQWibtPqHDYM2SVFzK3oYINipvBwe9Oel6o3Ifg5HXy9GkEDK)qwbiRf5fZdJe0nKaKQHqgcTtagJ1dQSzKTwzJeW8cDqfmVpBgzRBibivdHmeANkb0TDqzxcLSVjBgzRv2kSeiFh5tGabEear3y9q2mYwHLGRriybceq32bLnTzZ9SzKnxzRa2)7fOcJceXcFNSzKTcy)VxarFPg(ozZiBUYwRSbecMdey9ySQIFvHouHb0llOBfGXKS1OjBfW(FVaRhJvv8Rk0HkmGEzHVt2CMTgnzdiemhiqDrlEQ4x1bip4ilEcWySEqLnNrE7ilEI8uTzr0JsSO7xjwyKhgJ1dQ41r(dzfGSwKxRSrcyEHoOcM3NnJSTBbYkqarNG)kqvr)3dFmzXtagJ1dQSzKTclbxJqWceiWJai6gRhYMr2kSeCncblqWr)7L1XVaj7sOK99SzK9bRZIRo4DeuqbV9Ss20sj77rE7ilEI8i6McxUo4vrjw09slwyKhgJ1dQ41r(dzfGSwKxRSrcyEHoOceS7hYMr2CLTwzRWsW1ieSabc8iaIUX6HSzKTclbY3r(eiqaDBhu20Mn3YM5S5w20u2hNQUvCf5aJkBnAYwHLa57iFceiGUTdkBAk7BcxjBAZwmIlibz1HQGRQfYMZSzKTyexqcYQdvbxvlKnTzZTiVDKfprEOyKnU)DmbIsSO7fOyHrEymwpOIxh5pKvaYArEfwcKVJ8jqq2dh74MnJS5kBTYgOz(RJdOc2Ti6gXq1hEKk(vDWLdKS1Oj7dg7v4YNavyuGiwGa62oOSPn773KnNrE7ilEI8i6l1Oel6EPlwyKhgJ1dQ41r(dzfGSwKN9)EbwpgR8FKeiGDKS1OjBfW(FVavyuGiw47e5TJS4jY7GLfprjw09cCSWipmgRhuXRJ8hYkazTiVcy)VxGkmkqel8DI82rw8e5z9ySQ((KYIsSOlVjwyKhgJ1dQ41r(dzfGSwKxbS)3lqfgfiIf(orE7ilEI8Sabbeo2XnkXIU8ESWipmgRhuXRJ8hYkazTiVcy)VxGkmkqel8DI82rw8e5Flby9ySkkXIU8YyHrEymwpOIxh5pKvaYArEfW(FVavyuGiw47e5TJS4jYBZbqcX81J59rjw0LCpwyKhgJ1dQ41rE7ilEI8UMhoM3deuLfJNi)HScqwlYZv2kG9)EbQWOarSW3jBnAYMRS1kBX8WibOyKnU)DmbcWySEqLnJSpySxHlFcuHrbIybcOB7GYM2S52vYwJMSfZdJeGIr24(3XeiaJX6bv2mYMRSpySxHlFcqXiBC)7yceiGUTdk7sYU0YwJMSpySxHlFcqXiBC)7yceiGUTdkBAZ(YBYMr2V1LUujGUTdkBAZU0Us2CMnNzZz2mYwRSvyjq(oYNabOyKnU)Dmbur(X0HiVR5HJ59abvzX4jkXIUKBXcJ8WySEqfVoYBhzXtK3q0PAdGQe7wmPEWeZh5pKvaYArEfW(FVaXUftQhmX8vfW(FVGcx(KTgnz)wx6sLa62oOSlj7lVjYpMoe5neDQ2aOkXUftQhmX8rjw0LxjwyKhgJ1dQ41rE7ilEI8gIovBauLy3Ij1dMy(i)HScqwlYZv2ALTyEyKaumYg3)oMabymwpOYwJMS1kBX8Wib0NvaY77cbymwpOYMZSzKTcy)VxGkmkqelqaDBhu20M99BY(QzZTSPPSbAM)64aQGDlIUrmu9HhPIFvhC5ajYpMoe5neDQ2aOkXUftQhmX8rjw0LLwSWipmgRhuXRJ82rw8e5neDQ2aOkXUftQhmX8r(dzfGSwKNRSfZdJeGIr24(3XeiaJX6bv2mYwmpmsa9zfG8(UqagJ1dQS5mBgzRa2)7fOcJceXcFNSzKnxzRWsW1ieSabOyKnU)DmbuzRrt22TazfiGOtWFfOQO)7HpMS4jaJX6bv2mYwHLGRriybco6FVSo(fiztB23ZMZi)y6qK3q0PAdGQe7wmPEWeZhLyrxwGIfg5HXy9GkEDK3oYINi)PSJhle8SNkR3qsK)qwbiRf51nKaKQHqgcTtLa62oOSPK9nzZiBTYwbS)3lqfgfiIf(ozZiBTYwbS)3lGOVudFNSzKn7)9c6GoMuwf)Q()zvvfbmDuqHlFYMr2Wae3YYUKSlD3KnJSvyjq(oYNabcOB7GYM2S5wKhEp4i1X0Hi)PSJhle8SNkR3qsuIfDzPlwyKhgJ1dQ41rE7ilEI8(pHdGGQ7Gw1I)OQ7(Ki)HScqwlYRa2)7fOcJceXcFNi)y6qK3)jCaeuDh0Qw8hvD3NeLyrxwGJfg5HXy9GkEDK3oYINiV)Jec(JQUyVcMQJ)RBUqK)qwbiRf5va7)9cuHrbIyHVtKFmDiY7)iHG)OQl2RGP64)6MleLyrC)MyHrEymwpOIxh5TJS4jY76n1AcMGQ6GY8(fpr(dzfGSwKxbS)3lqfgfiIf(orE49GJuhthI8UEtTMGjOQoOmVFXtuIfX97XcJ8WySEqfVoYBhzXtK31BQ1embvznLle5pKvaYArEfW(FVavyuGiw47e5H3dosDmDiY76n1AcMGQSMYfIsSiUFzSWiVDKfpr(pcQRa6OipmgRhuXRJsuI8kSelmw09yHrEymwpOIxh5XorEeirE7ilEI8unYASEiYt18FiY7qwmzLYQeSyYINSzKnYb8(QyexqqHNnv8RYXSubu20Mn3ZMr2CLTclbxJqWceiGUTdk7sY(GXEfU8j4AecwGG6tmzXt2A0KTdEr4buvwpaku20M9vYMZipvJuhthI8iowN6PSJhQUgHGfikXIUmwyKhgJ1dQ41rEStKhbsK3oYINipvJSgRhI8un)hI8oKftwPSkblMS4jBgzJCaVVkgXfeu4ztf)QCmlvaLnTzZ9SzKnxzRa2)7fq0xQHVt2A0Knxz7GxeEavL1dGcLnTzFLSzKTwzB3cKvGa6aJuXVkRhJvbymwpOYMZS5mYt1i1X0HipIJ1PEk74Hk57iFceLyrCpwyKhgJ1dQ41rEStKhbsK3oYINipvJSgRhI8un)hI8kG9)EbQWOarSW3jBgzZv2kG9)Ebe9LA47KTgnzRBibivdHmeANkb0TDqztB23KnNzZiBfwcKVJ8jqGa62oOSPn7lJ8unsDmDiYJ4yDQKVJ8jquIfXTyHrEymwpOIxh5pKvaYArEX8WibOyKnU)DmbcWySEqLnJS1kBOyKnU)DmbuzZiBfwcUgHGfi4O)9Y64xGKDjuY(E2mY(GXEfU8jafJSX9VJjqGa62oOSlj7lZMr2ihW7RIrCbbfE2uXVkhZsfqztj77zZiBITQkqfgjykfkSt20MDPLnJSvyj4AecwGab0TDqzttzFt4kzxs2IrCbjiRoufCvTqK3oYINiVRriybIsSORelmYdJX6bv86i)HScqwlYlMhgjafJSX9VJjqagJ1dQSzKTwzRWsW1ieSabc8iaIUX6HSzKnxzFW6S4QdEhbLnTuY(4u1TIRihyuzZi7dg7v4YNaumYg3)oMabcOB7GYUKSVNnJSvyjq(oYNabcOB7GYMMY(MWvYUKSfJ4csqwDOk4QAHS5mYBhzXtKN8DKpbIsSOslwyKhgJ1dQ41r(hMuhOyjw09iVDKfprEhm2xjac)jhikXIkqXcJ8WySEqfVoYFiRaK1I8e4raeDJ1dzZi7dwNfxDW7iOGcE7zLSPLs23ZM5S5E20u2CLTDlqwbci6e8xbQk6)E4JjlEcWySEqLnJSpySxHlFcuTzr0dFNS5mBgzZv2o6FVSo(fizxcLSVNTgnztaDBhu2LqjBzpCuLvhYMr2ihW7RIrCbbfE2uXVkhZsfqztlLS5E2mNTDlqwbci6e8xbQk6)E4JjlEcWySEqLnNzZiBUYwRSHIr24(3XeqLTgnztaDBhu2LqjBzpCuLvhYMMY(YSzKnYb8(QyexqqHNnv8RYXSubu20sjBUNnZzB3cKvGaIob)vGQI(Vh(yYINamgRhuzZz2mYwRSrOk7)9av2mYMRSfJ4csqwDOk4QAHSVA2eq32bLnNztB2ClBgzZv26gsas1qidH2PsaDBhu2uY(MS1OjBTYw2dh74MnJSTBbYkqarNG)kqvr)3dFmzXtagJ1dQS5mYBhzXtK31ieSarjwuPlwyKhgJ1dQ41r(hMuhOyjw09iVDKfprEhm2xjac)jhikXIkWXcJ8WySEqfVoYBhzXtK31ieSar(dzfGSwKxRSPAK1y9qaXX6upLD8q11ieSazZiBc8iaIUX6HSzK9bRZIRo4DeuqbV9Ss20sj77zZC2CpBAkBUY2UfiRabeDc(Ravf9Fp8XKfpbymwpOYMr2hm2RWLpbQ2Si6HVt2CMnJS5kBh9Vxwh)cKSlHs23ZwJMSjGUTdk7sOKTShoQYQdzZiBKd49vXiUGGcpBQ4xLJzPcOSPLs2CpBMZ2UfiRabeDc(Ravf9Fp8XKfpbymwpOYMZSzKnxzRv2qXiBC)7ycOYwJMSjGUTdk7sOKTShoQYQdzttzFz2mYg5aEFvmIliOWZMk(v5ywQakBAPKn3ZM5STBbYkqarNG)kqvr)3dFmzXtagJ1dQS5mBgzRv2iuL9)EGkBgzZv2IrCbjiRoufCvTq2xnBcOB7GYMZSPn77xMnJS5kBDdjaPAiKHq7ujGUTdkBkzFt2A0KTwzl7HJDCZMr22TazfiGOtWFfOQO)7HpMS4jaJX6bv2Cg5pLD8qvmIliOyr3JsSO73elmYdJX6bv86iVDKfpr(dz1r4PkGUdGKi)HScqwlYJCaVVkgXfeu20Mn3ZMr2eq32bLDjzFz2mNnxzJCaVVkgXfeu20sj7RKnNzZi7dwNfxDW7iOSPLs2ClYFk74HQyexqqXIUhLyr3VhlmYdJX6bv86i)HScqwlYRv2unYASEiG4yDQKVJ8jq2mYMRSpyDwC1bVJGYMwkzZTSzKnbEear3y9q2A0KTwzl7HJDCZMr2CLTS6q20M99BYwJMSpyDwC1bVJGYMwkzFz2CMnNzZiBUY2r)7L1XVaj7sOK99S1OjBcOB7GYUekzl7HJQS6q2mYg5aEFvmIliOWZMk(v5ywQakBAPKn3ZM5STBbYkqarNG)kqvr)3dFmzXtagJ1dQS5mBgzZv2ALnumYg3)oMaQS1OjBcOB7GYUekzl7HJQS6q20u2xMnJSroG3xfJ4cck8SPIFvoMLkGYMwkzZ9SzoB7wGSceq0j4Vcuv0)9Whtw8eGXy9GkBoZMr2IrCbjiRoufCvTq2xnBcOB7GYM2S5wK3oYINip57iFceLyr3VmwyKhgJ1dQ41rE7ilEI8KVJ8jqK)qwbiRf51kBQgznwpeqCSo1tzhpujFh5tGSzKTwzt1iRX6HaIJ1Ps(oYNazZi7dwNfxDW7iOSPLs2ClBgztGhbq0nwpKnJS5kBh9Vxwh)cKSlHs23ZwJMSjGUTdk7sOKTShoQYQdzZiBKd49vXiUGGcpBQ4xLJzPcOSPLs2CpBMZ2UfiRabeDc(Ravf9Fp8XKfpbymwpOYMZSzKnxzRv2qXiBC)7ycOYwJMSjGUTdk7sOKTShoQYQdzttzFz2mYg5aEFvmIliOWZMk(v5ywQakBAPKn3ZM5STBbYkqarNG)kqvr)3dFmzXtagJ1dQS5mBgzlgXfKGS6qvWv1czF1SjGUTdkBAZMBzZC2CLTdEr4buvwpaku20M9LzZz20u2LwK)u2XdvXiUGGIfDpkXIUZ9yHrEymwpOIxh5TJS4jYFiRocpvb0DaKe5pKvaYArEKd49vXiUGGYM2SVNnJSroG3xfJ4cck7sYMBzZiBcOB7GYUKSVmBgzFW6S4QdEhbLnTuYMBr(tzhpufJ4cckw09Oel6o3Ifg5HXy9GkEDK)qwbiRf5roG3xfJ4cckBkzFpBgzFW6S4QdEhbLnTuYMRSpovDR4kYbgv2xn77zZz2mYMapcGOBSEiBgzRv2qXiBC)7ycOYMr2ALTcy)VxarFPg(ozZiBDdjaPAiKHq7ujGUTdkBkzFt2mYwRSTBbYkqqkFrsvOdvoM9bbymwpOYMr2IrCbjiRoufCvTq2xnBcOB7GYM2S5wK3oYINi)HS6i8ufq3bqsuIfD)kXcJ8WySEqfVoYFiRaK1I8ihW7RIrCbbLnTzZv2fOSVA2S)3ladvyW6HVt2CMnJSpyDwC1bVJGYMwkzZTSzoBX8WibfaoaPIeIjMlOhGXy9GkBgzRv2kG9)EbQWOarSW3jBgzRv2kG9)Ebe9LA47KnJS1kB7wGSceKYxKuf6qLJzFqagJ1dQSzKnmaXTSGcE7zLSlHs2xELSzoBQgznwpeGbiULvjGlm1dwNDhqf5TJS4jYFiRocpvb0DaKeLOeLipvGGw8el6YBU8MBkW3WTiF5gz2Xff5l9GgtJkQaUiA2sr2zxiDi7v3btKSFys2LAacbZbqLAztaAM)sav2iSoKT9fSUjGk7dDBCbuizQaWoq2xwkYMgGhQarav2LAqXiBC)7ycOcL(LAzl4Sl1ua7)9cL(bOyKnU)DmbuLAzZ19I5mKmLmvaR7GjcOYUaLTDKfpz7xKGcjtrEhc(TEiYxWSPXiKHq7yYINSPry3pKmvWS5bhb0zbs231o7lV5YBsMsMky20a624cOsrYubZ(QztJvkqLDP(E4iBbNTcE23lzBhzXt2(fjHKPcM9vZMgb6yQq2IrCbPUVqYubZ(QztJvkqLnnCeKDbSa6OS5c)f0QGSXVSrcyEHoNHKPcM9vZMgGhQarav2qXiBC)7ycOcL(zl4Svyju6hGIr24(3XeqfsMsMky208IHZxav2SWdtGSpyDwtYMfC3bfYMgFoGJGYEWZvPBe933NTDKfpOSXJVSqYubZ2oYIhuWHahSoRjuEEdXrYubZ2oYIhuWHahSoRjmt5c77QdJyYINKPcMTDKfpOGdboyDwtyMYfpmwLmvWS5hZbrhlztSvLn7)9av2iXeu2SWdtGSpyDwtYMfC3bLTnQSDiWvDWISJB2lkBfEGqYubZ2oYIhuWHahSoRjmt5c0yoi6yPIetqjt2rw8Gcoe4G1znHzkxyoo(YQo4fHNKj7ilEqbhcCW6SMWmLlqcyEHEYKDKfpOGdboyDwtyMYf6gHdqvFysvbMqxBhcCW6SMurWbpkeLRO9(OqSvvbQWibtPqHDO9(vsMSJS4bfCiWbRZAcZuU4JG6kGU2JPduSBr0nIHQp8iv8R6Glhijt2rw8Gcoe4G1znHzkx4GLfpjtjtfmBAEXW5lGkBGkqklBz1HSf6q22rWKSxu2gvB9gRhcjtfmBAeGeW8c9S3x2oyeAz9q2Cn4SP(9dqmwpKnmG(cOS3j7dwN1eotMSJS4brHJ9WH27JIwibmVqhubZ7tMSJS4bXmLlqcyEHEYKDKfpiMPCbvJSgRh0EmDGcmaXTSkbCHPEW6S7akTPA(pqbgG4wwGaUWWSdEr4buvwpakenvGOHX1L0eYb8(kDdjaNjt2rw8GyMYfunYASEq7X0bkODC9qvmIliAt18FGcYb8(QyexqqHNnv8RYXSubujxMmzhzXdIzkxCmVVAhzXt1Vir7X0bkibmVqhuAVpkibmVqhubc29djt2rw8GyMYfhZ7R2rw8u9ls0EmDGYrH0EFu4slX8WibDdjaPAiKHq7eGXy9GsJgfwcUgHGfii7HJDC5mzYoYIheZuU4yEF1oYINQFrI2JPduuyjzYoYIheZuU4yEF1oYINQFrI2JPduulbosYKDKfpiMPCHro2avbtiWiAVpkWae3Yck4TNvOLY9RWmvJSgRhcWae3YQeWfM6bRZUdOsMSJS4bXmLlmYXgO689iizYoYIheZuUWVU0fuTa8x5QdJKmzhzXdIzkxWAUv8RkK9WbkzkzQGztdWyVcx(GsMSJS4bfokeLpcQRa6ApMoqXUfr3igQ(WJuXVQdUCGO9(OOfsaZl0bvW8Eg6gsas1qidH2PsaDBheLByW1bJ9kC5tGkmkqelqaDBhujfG46GXEfU8jGOVudeq32brtanZFDCavWq0PAdGQe7wmPEWeZZjNLC)gMVFdnb0m)1XbubdrNQnaQsSBXK6btmpdTua7)9cuHrbIyHVddTua7)9ci6l1W3jzYoYIhu4Oqmt5IJ59v7ilEQ(fjApMoqbqiyoas79rrlKaMxOdQG59muyjq(oYNabzpCSJldDdjaPAiKHq7ujGUTdIYnjtfm7c4x2MsHY2iq2FhTZgnRdKTqhYgpq2LVc9S94YbKKDHfsdfYMgocYUC6WKTQSDCZ(zibizl0TjBAqPkBf82ZkzJjzx(k0XFjBBklBAqPkKmzhzXdkCuiMPCHUr4au1hMuvGj01(u2XdvXiUGGOCx79rHyRQcuHrcMsHcFhgCjgXfKGS6qvWv1cLCW6S4QdEhbfuWBpRqt3dxrJMdwNfxDW7iOGcE7zfAPCCQ6wXvKdmkotMky2fWVShC2MsHYU817ZwTq2LVc9DYwOdzpqXs2C)gK2z)rq2fqpAOSXt2Syek7YxHo(lzBtzztdkvHKj7ilEqHJcXmLl0nchGQ(WKQcmHU27JcXwvfOcJemLcf2HwUFZvj2QQavyKGPuOG6tmzXdJdwNfxDW7iOGcE7zfAPCCQ6wXvKdmQKPcMDPegfiILTh7UhZN9bpQvw8yEu2SgcuzJNSpFcbgjBKdCsMSJS4bfokeZuUGQrwJ1dApMoqHkmkqeRI(ScqEFxOEWJALfpAt18FGIwI5HrcOpRaK33fcWySEqPrJw2TazfiGOtWFfOQO)7HpMS4jaJX6bLgnkSeCncblqWr)7L1XVaH27m4c5aEFvmIliOWZMk(v5ywQaQKstJgToySxHlFcuTzr0dFhotMSJS4bfokeZuUGQrwJ1dApMoqHkmkqeRoRlDbjMNdGup4rTYIhTPA(pqrlX8WiHzDPliX8CaKamgRhuA0OLyEyKaumYg3)oMabymwpO0O5GXEfU8jafJSX9VJjqGa62oOsUYvVKMeZdJeua4aKksiMyUGEagJ1dQKj7ilEqHJcXmLlOAK1y9G2JPduOAK1y9G2JPduOcJceXQp8i1dEuRS4rBQM)du0cOz(RJdOc2Ti6gXq1hEKk(vDWLdenASBbYkqarNG)kqvr)3dFmzXtagJ1dknAua7)9ce7wmPEWeZxva7)9ckC5Jgnhm2RWLpbdrNQnaQsSBXK6btmFGa62oOsUFddUoySxHlFci6l1ab0TDqLCxJgfW(FVaI(sn8D4mzYoYIhu4Oqmt5cQWOarmT3hfTqcyEHoOceS7hyOWsG8DKpbcYE4yhxgAPa2)7fOcJceXcFhgunYASEiqfgfiIvrFwbiVVlup4rTYIhgunYASEiqfgfiIvN1LUGeZZbqQh8OwzXddQgznwpeOcJceXQp8i1dEuRS4jzQGzxkTzr0ZU8vONnnVyKB2mNDrRlDbjMNdGukYUaYkE1)6ztdkvzBJkBAEXi3SjGPkl7hMK9aflztZsdOHsMSJS4bfokeZuUGQnlIU27JIyEyKaumYg3)oMabymwpOyiMhgjmRlDbjMNdGeGXy9GIXbRZIRo4DeeTuoovDR4kYbgfJdg7v4YNaumYg3)oMabcOB7Gk5EYubZUuAZIOND5Rqp7Iwx6csmphajBMZUiC208IrULISlGSIx9VE20Gsv22OYUucJceXY(7Knx)Xdiu2F0oUzxkXLkotMSJS4bfokeZuUGQnlIU27JIyEyKWSU0fKyEoasagJ1dkgAjMhgjafJSX9VJjqagJ1dkghSolU6G3rq0s54u1TIRihyum4sbS)3lqfgfiIf(oA0aiemhiqDrlEQ4x1bip4ilEcWySEqXzYubZMhGSFFVp7dwxhgjB8KnDrCqLIlUWDf6F2WbRFbnYOcdDSxjxTqAWf0iS7hUO8LJ9cAmczi0oMS45Q04svbGRsJaeyKd9qYKDKfpOWrHyMYfunYASEq7X0bkiuLQnlIE9Gh1klE0MQ5)af7wGSceq0j4Vcuv0)9Whtw8eGXy9GIbxdEQiuL9)EGQkgXfeeTuURrdYb8(QyexqqHNnv8RYXSubefUZjdUqOk7)9avvmIliOQXIPcvhBuG(EOCJgnihW7RIrCbbfE2uXVkhZsfq0sP04mzYoYIhu4Oqmt5chm2xjac)jhq7hMuhOyHYDTHIfIvnD8FekC7kjt2rw8GchfIzkxq1Mfrx79rrmpmsa9zfG8(UqagJ1dkgAHeW8cDqfiy3pW4GXEfU8j4AecwGW3HbxunYASEiGqvQ2Si61dEuRS4rJgTSBbYkqarNG)kqvr)3dFmzXtagJ1dkgCPWsW1ieSabc8iaIUX6bnAua7)9cuHrbIyHVddfwcUgHGfi4O)9Y64xGucL7CYjJdwNfxDW7iOGcE7zfAPWfx3z(sAYUfiRabeDc(Ravf9Fp8XKfpbymwpO4KMqoG3xfJ4cck8SPIFvoMLkG4K2cqCJbXwvfOcJemLcf2H27xMmvWSlL2Si6zx(k0ZUaYqcqYMgJqgANsr2fHZgjG5f6zBJk7bNTDKLkKDbenoB2)7PD20OVJ8jq2dwYENSjWJai6ztSXf0oB1NSJB2LsyuGigZfEnZxJfAE2C9hpGqz)r74MDPexQ4mzYoYIhu4Oqmt5cQ2Si6AVpkI5Hrc6gsas1qidH2jaJX6bfdTqcyEHoOcM3Zq3qcqQgczi0ovcOB7GkHYnm0sHLa57iFceiWJai6gRhyOWsW1ieSabcOB7GOL7m4sbS)3lqfgfiIf(omua7)9ci6l1W3HbxAbiemhiW6Xyvf)QcDOcdOxwq3kaJjA0Oa2)7fy9ySQIFvHouHb0ll8D4uJgaHG5abQlAXtf)Qoa5bhzXtagJ1dkotMky280nfUCDWRY(HjzZtNG)kqLn))9Whtw8KmzhzXdkCuiMPCbIUPWLRdEL27JIwibmVqhubZ7zy3cKvGaIob)vGQI(Vh(yYINamgRhumuyj4AecwGabEear3y9adfwcUgHGfi4O)9Y64xGucL7moyDwC1bVJGck4TNvOLY9KPcMnnVyKnU)DmbYUC6WK9GLSrcyEHoOY2gv2SyHE20OVJ8jq22OYMM1ieSazBei7Vt2pmjBpECZgg83LEizYoYIhu4Oqmt5cOyKnU)Dmb0EFu0cjG5f6GkqWUFGbxAPWsW1ieSabc8iaIUX6bgkSeiFh5tGab0TDq0YnM5gnDCQ6wXvKdmknAuyjq(oYNabcOB7GOPBcxHwXiUGeKvhQcUQwGtgIrCbjiRoufCvTaTClzYoYIhu4Oqmt5ce9LQ27JIclbY3r(eii7HJDCzWLwanZFDCavWUfr3igQ(WJuXVQdUCGOrZbJ9kC5tGkmkqelqaDBheT3VHZKj7ilEqHJcXmLlCWYIhT3hf2)7fy9ySY)rsGa2r0OrbS)3lqfgfiIf(ojt2rw8GchfIzkxW6Xyv99jLP9(OOa2)7fOcJceXcFNKj7ilEqHJcXmLlybcciCSJR27JIcy)VxGkmkqel8DsMSJS4bfokeZuU4TeG1JXkT3hffW(FVavyuGiw47KmzhzXdkCuiMPCHnhajeZxpM3R9(OOa2)7fOcJceXcFNKj7ilEqHJcXmLl(iOUcOR9y6afxZdhZ7bcQYIXJ27JcxkG9)EbQWOarSW3rJgU0smpmsakgzJ7FhtGamgRhumoySxHlFcuHrbIybcOB7GOLBxrJgX8WibOyKnU)DmbcWySEqXGRdg7v4YNaumYg3)oMabcOB7GkP00O5GXEfU8jafJSX9VJjqGa62oiAV8ggV1LUujGUTdI2s7kCYjNm0sHLa57iFceGIr24(3XeqLmzhzXdkCuiMPCXhb1vaDThthOyi6uTbqvIDlMupyI51EFuua7)9ce7wmPEWeZxva7)9ckC5JgnV1LUujGUTdQKlVjzYoYIhu4Oqmt5IpcQRa6ApMoqXq0PAdGQe7wmPEWeZR9(OWLwI5HrcqXiBC)7yceGXy9GsJgTeZdJeqFwbiVVleGXy9GItgkG9)EbQWOarSab0TDq0E)MRYnAcOz(RJdOc2Ti6gXq1hEKk(vDWLdKKj7ilEqHJcXmLl(iOUcOR9y6afdrNQnaQsSBXK6btmV27JcxI5HrcqXiBC)7yceGXy9GIHyEyKa6Zka59DHamgRhuCYqbS)3lqfgfiIf(om4sHLGRriybcqXiBC)7ycO0OXUfiRabeDc(Ravf9Fp8XKfpbymwpOyOWsW1ieSabh9Vxwh)ceAVZzYKDKfpOWrHyMYfFeuxb01gEp4i1X0bkNYoESqWZEQSEdjAVpk6gsas1qidH2PsaDBheLByOLcy)VxGkmkqel8DyOLcy)VxarFPg(omy)Vxqh0XKYQ4x1)pRQQiGPJckC5ddyaIBzLu6UHHclbY3r(eiqaDBheTClzYoYIhu4Oqmt5IpcQRa6ApMoqX)jCaeuDh0Qw8hvD3NO9(OOa2)7fOcJceXcFNKj7ilEqHJcXmLl(iOUcOR9y6af)hje8hvDXEfmvh)x3CbT3hffW(FVavyuGiw47KmzhzXdkCuiMPCXhb1vaDTH3dosDmDGIR3uRjycQQdkZ7x8O9(OOa2)7fOcJceXcFNKj7ilEqHJcXmLl(iOUcORn8EWrQJPduC9MAnbtqvwt5cAVpkkG9)EbQWOarSW3jzQGztdbp77LSFM3ZAhoY(Hjz)rgRhYEfqhvkYMgocYgpzFWyVcx(esMSJS4bfokeZuU4JG6kGokzkzQGztdTe4izRmDZfY2yx)klGsMky208Hkmy9SnjBUXC2CDfMZU8vONnnepNztdkvHSlG11b1Ac4llB8K9LmNTyexqqAND5Rqp7sjmkqet7SXKSlFf6zx41LEMnwOdKYxeKD52kz)WKSryDiByaIBzHKj7ilEqb1sGJqbgQWG11EFuoyDwC1bVJGOLc3ywmpmsqbGdqQiHyI5c6bymwpOyWLcy)VxGkmkqel8D0OrbS)3lGOVudFhnAGbiULfuWBpRucLlVcZunYASEiadqClRsaxyQhSo7oGsJgTOAK1y9qaTJRhQIrCbHtgCPLyEyKaumYg3)oMabymwpO0OrlfW(FVavyuGiw47OrZbJ9kC5takgzJ7FhtGab0TDq0EjNjt2rw8GcQLahHzkxq1iRX6bThthO8rq9TEpq0MQ5)aLdwNfxDW7iOGcE7zfAVRrdmaXTSGcE7zLsOC5vyMQrwJ1dbyaIBzvc4ct9G1z3buA0OfvJSgRhcODC9qvmIlijtfm7spwHE208dD8oUzFT3uas7SlaAt24x2L6ZsfqzBs2xYC2IrCbbPD2ys2C)QCJ5SfJ4cck7YPdt2LsyuGiw2lk7VtYKDKfpOGAjWryMYfpBQ4xLJzPciT3hfQgznwpe(iO(wVhimSBbYkqao0X74wz9McqbymwpOyGCaVVkgXfeu4ztf)QCmlvarlLlzMlfW(FVavyuGiw47qtCDNzUSBbYkqao0X74wz9McqbInCq5oNCYzYubZUaOnzJFzxQplvaLTjzFVaZC2iXoCGYg)YU07QuWK91EtbOSXKSnxBhKKn3yoBUUcZzx(k0ZMgc)z9q20qyeWz2IrCbbfsMSJS4bfulbocZuU4ztf)QCmlvaP9(Oq1iRX6HWhb1369aHbxS)3lqFvkyQSEtbOasSdh0s5EbwJgU0YHSyYkLvjyXKfpmqoG3xfJ4cck8SPIFvoMLkGOLc3yMl7wGSceu4pRhQkmcceB4G2l5KzKaMxOdQab7(bo5mzQGzxa0MSXVSl1NLkGYwWzBoo(YYMgcmLVSSlv4fHNS3x27yhzPczJNSTPSSfJ4cs2MKn3ZwmIliOqYKDKfpOGAjWryMYfpBQ4xLJzPciTpLD8qvmIliik31EFuOAK1y9q4JG6B9EGWa5aEFvmIliOWZMk(v5ywQaIwkCpzYoYIhuqTe4imt5ctN9JOR9(Oq1iRX6HWhb1369aHbxS)3lW63rHwfe(oA0OLyEyKavyW6vYhrpaJX6bfdTSBbYkqqH)SEOQWiiaJX6bfNjtfm7cn2Rwa9L1BcKTGZ2CC8LLnneykFzzxQWlcpzBs2xMTyexqqjt2rw8GcQLahHzkxO)L1BcO9PSJhQIrCbbr5U27JcvJSgRhcFeuFR3degihW7RIrCbbfE2uXVkhZsfquUmzYoYIhuqTe4imt5c9VSEtaT3hfQgznwpe(iO(wVhijtjtfmBAit3CHSXubs2YQdzBSRFLfqjtfm7caR(kztZAecwau24j7bpx1HS6eJuw2IrCbbL9dtYwOdz7qwmzLYYMGftw8K9(Y(kmNnRhafkBJazBEcyQYY(7KmzhzXdkOWcfQgznwpO9y6afehRt9u2XdvxJqWcOnvZ)bkoKftwPSkblMS4HbYb8(QyexqqHNnv8RYXSubeTCNbxkSeCncblqGa62oOsoySxHlFcUgHGfiO(etw8OrJdEr4buvwpakeTxHZKPcMDbGvFLSPrFh5tau24j7bpx1HS6eJuw2IrCbbL9dtYwOdz7qwmzLYYMGftw8K9(Y(kmNnRhafkBJazBEcyQYY(7KmzhzXdkOWcZuUGQrwJ1dApMoqbXX6upLD8qL8DKpb0MQ5)afhYIjRuwLGftw8Wa5aEFvmIliOWZMk(v5ywQaIwUZGlfW(FVaI(sn8D0OHlh8IWdOQSEauiAVcdTSBbYkqaDGrQ4xL1JXQamgRhuCYzYubZUaWQVs20OVJ8jak79LDPegfiIXCH4I3t2x7nfCrbKHeGKnngHmeANSxu2FNSTrLD5q20nQq2xYC2i4GhfkBp8KSXt2cDiBA03r(eiBAiCHjt2rw8GckSWmLlOAK1y9G2JPduqCSovY3r(eqBQM)duua7)9cuHrbIyHVddUua7)9ci6l1W3rJgDdjaPAiKHq7ujGUTdI2B4KHclbY3r(eiqaDBheTxMmvWS5DGZA(SPzncblq22OYMg9DKpbYgbY3jBhYIjzl4SP5fJSX9VJjq2hdjjt2rw8GckSWmLlCncblG27JIyEyKaumYg3)oMabymwpOyOfumYg3)oMakgkSeCncblqWr)7L1XVaPek3zCWyVcx(eGIr24(3XeiqaDBhujxYa5aEFvmIliOWZMk(v5ywQaIYDgeBvvGkmsWukuyhAlngkSeCncblqGa62oiA6MWvkrmIlibz1HQGRQfsMSJS4bfuyHzkxq(oYNaAVpkI5HrcqXiBC)7yceGXy9GIHwkSeCncblqGapcGOBSEGbxhSolU6G3rq0s54u1TIRihyumoySxHlFcqXiBC)7yceiGUTdQK7muyjq(oYNabcOB7GOPBcxPeXiUGeKvhQcUQwGZKPcMnnRriybY(7WbaoANT5r4SfYcOSfC2FeK9kzBOSTSroWznF2UWaetWKSFys2cDiBVHKSPbLQSzHhMazBz)2zr0bsYKDKfpOGclmt5chm2xjac)jhq7hMuhOyHY9Kj7ilEqbfwyMYfUgHGfq79rHapcGOBSEGXbRZIRo4DeuqbV9ScTuUZm3PjUSBbYkqarNG)kqvr)3dFmzXtagJ1dkghm2RWLpbQ2Si6HVdNm4Yr)7L1XVaPek31OHa62oOsOi7HJQS6adKd49vXiUGGcpBQ4xLJzPciAPWDMTBbYkqarNG)kqvr)3dFmzXtagJ1dkozWLwqXiBC)7ycO0OHa62oOsOi7HJQS6anDjdKd49vXiUGGcpBQ4xLJzPciAPWDMTBbYkqarNG)kqvr)3dFmzXtagJ1dkozOfcvz)VhOyWLyexqcYQdvbxvlCvcOB7G4KwUXGlDdjaPAiKHq7ujGUTdIYnA0OLSho2XLHDlqwbci6e8xbQk6)E4JjlEcWySEqXzYKDKfpOGclmt5chm2xjac)jhq7hMuhOyHY9Kj7ilEqbfwyMYfUgHGfq7tzhpufJ4ccIYDT3hfTOAK1y9qaXX6upLD8q11ieSamiWJai6gRhyCW6S4QdEhbfuWBpRqlL7mZDAIl7wGSceq0j4Vcuv0)9Whtw8eGXy9GIXbJ9kC5tGQnlIE47WjdUC0)EzD8lqkHYDnAiGUTdQekYE4OkRoWa5aEFvmIliOWZMk(v5ywQaIwkCNz7wGSceq0j4Vcuv0)9Whtw8eGXy9GItgCPfumYg3)oMaknAiGUTdQekYE4OkRoqtxYa5aEFvmIliOWZMk(v5ywQaIwkCNz7wGSceq0j4Vcuv0)9Whtw8eGXy9GItgAHqv2)7bkgCjgXfKGS6qvWv1cxLa62oioP9(Lm4s3qcqQgczi0ovcOB7GOCJgnAj7HJDCzy3cKvGaIob)vGQI(Vh(yYINamgRhuCMmvWSPbKvhHNSle0DaKKnEYw)7L1XdzlgXfeu2MKn3yoBAqPk7YPdt2K)m74Mn(lzVt2xEvUJYMlwdbQSXt2IrCbj7d(pcNzJNSTPSSfJ4csYKDKfpOGclmt5Idz1r4PkGUdGeTpLD8qvmIliik31EFuqoG3xfJ4ccIwUZGa62oOsUKzUqoG3xfJ4ccIwkxHtghSolU6G3rq0sHBjtfm7sDaCY(7Knn67iFcKTjzZnMZgpzBEF2IrCbbLnxLthMS9l1DCZ2Jh3SHb)DPNTnQShSKnAmheDSWzYKDKfpOGclmt5cY3r(eq79rrlQgznwpeqCSovY3r(eGbxhSolU6G3rq0sHBmiWJai6gRh0OrlzpCSJldUKvhO9(nA0CW6S4QdEhbrlLl5KtgC5O)9Y64xGucL7A0qaDBhujuK9WrvwDGbYb8(QyexqqHNnv8RYXSubeTu4oZ2TazfiGOtWFfOQO)7HpMS4jaJX6bfNm4slOyKnU)DmbuA0qaDBhujuK9WrvwDGMUKbYb8(QyexqqHNnv8RYXSubeTu4oZ2TazfiGOtWFfOQO)7HpMS4jaJX6bfNmeJ4csqwDOk4QAHRsaDBheTClzYoYIhuqHfMPCb57iFcO9PSJhQIrCbbr5U27JIwunYASEiG4yDQNYoEOs(oYNam0IQrwJ1dbehRtL8DKpbyCW6S4QdEhbrlfUXGapcGOBSEGbxo6FVSo(fiLq5Ugneq32bvcfzpCuLvhyGCaVVkgXfeu4ztf)QCmlvarlfUZSDlqwbci6e8xbQk6)E4JjlEcWySEqXjdU0ckgzJ7FhtaLgneq32bvcfzpCuLvhOPlzGCaVVkgXfeu4ztf)QCmlvarlfUZSDlqwbci6e8xbQk6)E4JjlEcWySEqXjdXiUGeKvhQcUQw4Qeq32brl3yMlh8IWdOQSEauiAVKtAQ0sMky20aYQJWt2fc6oasYgpzF)QCpB9VxwhpKTyexqqzBs2CJ5SPbLQSlNomzt(ZSJB24VK9ozFjkB8KTnLLTyexqsMSJS4bfuyHzkxCiRocpvb0DaKO9PSJhQIrCbbr5U27JcYb8(Qyexqq0ENbYb8(QyexqqLWngeq32bvYLmoyDwC1bVJGOLc3sMky20aYQJWt2fc6oasYgpzZxy27l7DY2XgfOVNSTrL9kzx(69zRWz7bekBLPBUq2cDBYMMpuHbRNT6dzl4Sl86lkGOXxuOuQNmzhzXdkOWcZuU4qwDeEQcO7air79rb5aEFvmIliik3zCW6S4QdEhbrlfUoovDR4kYbg1vVZjdc8iaIUX6bgAbfJSX9VJjGIHwkG9)Ebe9LA47Wq3qcqQgczi0ovcOB7GOCddTSBbYkqqkFrsvOdvoM9bbymwpOyigXfKGS6qvWv1cxLa62oiA5wYubZMgyijBAaz1r4j7cbDhajzJNSPXyAE27GeWuzJFztZhQWG1Z2KSlqmNTyexqqzxoDyYUucJceXUOWRZErzpyj7VtYKDKfpOGclmt5Idz1r4PkGUdGeT3hfKd49vXiUGGOLRc0vz)VxagQWG1dFhozCW6S4QdEhbrlfUXSyEyKGcahGurcXeZf0dWySEqXqlfW(FVavyuGiw47WqlfW(FVaI(sn8DyOLDlqwbcs5lsQcDOYXSpiaJX6bfdyaIBzbf82ZkLq5YRWmvJSgRhcWae3YQeWfM6bRZUdOsMsMky20CecMdGsMSJS4bfaecMdGOCWZbgHycOQpVPdAVpkWae3YcYQdvbx1TIP9odTua7)9cuHrbIyHVddU0sHLWbphyeIjGQ(8Mouz)Kji7HJDCzOLDKfpHdEoWietav95nDiSt95xx6IgnVV3xjWHUrCHQS6qjUhvq3kMZKPcMnn2xUvgk7pcY(ApgRYU8vONDPegfiIL93jKDPxSxL9dtYMMxmYg3)oMaHSPHJGSlFf6zx41z)DYMfEycKTL9BNfrhizBOS94XnBdL9kzt(dk7hMK99BqzR(KDCZUucJceXcjt2rw8GcacbZbqmt5cwpgRQ4xvOdvya9Y0EFuua7)9cuHrbIyHVddUGIr24(3XeqfCncblGgnkG9)Ebe9LA47W4G1zXvh8ockOG3EwPek31OrbS)3lqfgfiIfiGUTdQek3VHtnAERlDPsaDBhujuUFtYubZMglcO7izl4Sn)6oztZ(nIATj7YxHE2LsyuGiw2gkBpECZ2qzVs2LJNsnjBcG(Ej7DY2Jr74MTL9779xLQ5)q2hdjzJPcKSf6q2eq32zh3SvFIjlEYg)YwOdz)wx6sYKDKfpOaGqWCaeZuUW9Be1Atf)Q2Tabl01EFuoySxHlFcuHrbIybcOB7GkH7A0Oa2)7fOcJceXcFhnAERlDPsaDBhujC)MKj7ilEqbaHG5aiMPCH73iQ1Mk(vTBbcwOR9(O88ymHlUERlDPsaDBh0v5(nCsd7GXEfU8HtAFEmMWfxV1LUujGUTd6QC)MREWyVcx(eOcJceXceq32bXjnSdg7v4YhotMSJS4bfaecMdGyMYfp85Jav1UfiRavwW01EFuqoG3xfJ4cck8SPIFvoMLkGOLYLA0qSvvbQWibtPqHDOT0UHbmaXTSskq3OrZBDPlvcOB7Gk5(njt2rw8GcacbZbqmt5cNpzFLTJBL1Bir79rb5aEFvmIliOWZMk(v5ywQaIwkxQrdXwvfOcJemLcf2H2s7gnAERlDPsaDBhuj3VjzYoYIhuaqiyoaIzkxi0H6FyX)rvFyYb0EFuy)VxGaho8acvFyYbcFhnAy)VxGaho8acvFyYbQh8FeGeqID4OK73KmzhzXdkaiemhaXmLliRJJhQ7uro2bsMSJS4bfaecMdGyMYfLJjEfvyNkbq4XMdKmzhzXdkaiemhaXmLl0bDmPSk(v9)ZQQkcy6iT3hfyaIBzLCLByO1bJ9kC5tGkmkqel8DsMky2LEXEv20iWC2Xn7cGEthqz)WKSHIHZxGSj24czJjzZX69zZ(FpK2zVVSDWi0Y6Hq20yF5wzOSfszzl4SDbjBHoKThxoGKSpySxHlFYM1qGkB8KTr1wVX6HSHb0xafsMSJS4bfaecMdGyMYfeWC2XT(8MoG0(u2XdvXiUGGOCx79rrmIlibz1HQGRQfk5E4kA0WfxIrCbjqhmVqp4CeAlD3OrJyexqc0bZl0dohPekxEdNm4YoYsfQWa6lGOCxJgXiUGeKvhQcUQwG2llWCYPgnCjgXfKGS6qvWvNJuV8gA5(nm4YoYsfQWa6lGOCxJgXiUGeKvhQcUQwGwUXno5mzkzQGzZlG5f6GkBA8rw8GsMky2fTU0rI55aizJNSVxyPiB(XCq0Xs20OVJ8jqYKDKfpOasaZl0bffY3r(eq79rrmpmsywx6csmphajaJX6bfJdwNfxDW7iiAPWngIrCbjiRoufCvTWvjGUTdI2slzQGzZ)zfG8(Uq2mNnpDc(Rav28)3dFmzXtPiBA(G(ei7YHS)iiB8az76XSMpBbNT544llBAwJqWcKTGZwOdzRB7KTyexqYEFzVs2lk7blzJgZbrhlzxgiANncNT59zJf6ajBDBNSfJ4cs2g76xzbu2oe8BLqYKDKfpOasaZl0bfZuUWbJ9vcGWFYb0(Hj1bkwOCpzYoYIhuajG5f6GIzkx4AecwaT3hf7wGSceq0j4Vcuv0)9Whtw8eGXy9GIb7)9cOpRaK33fcFhgS)3lG(ScqEFxiqaDBhuj3dCNHwiuL9)EGkzQGzZ)zfG8(UqPiBASJJVSSXKSPrWJai6zx(k0ZM9)EGkBAwJqWcGsMSJS4bfqcyEHoOyMYfoySVsae(toG2pmPoqXcL7jt2rw8GcibmVqhumt5cxJqWcO9PSJhQIrCbbr5U27JIyEyKa6Zka59DHamgRhum4Ia62oOsUFPgno6FVSo(fiLq5oNmeJ4csqwDOk4QAHRsaDBheTxMmvWS5)ScqEFxiBMZMNob)vGkB()7HpMS4j7DYMVWsr20yhhFzzdgXxw20OVJ8jq2cDtYU817ZMfYMapcGOdQSFys2o2Oa99KmzhzXdkGeW8cDqXmLliFh5taT3hfX8Wib0NvaY77cbymwpOyy3cKvGaIob)vGQI(Vh(yYINamgRhum0sHLa57iFceK9WXoUmOAK1y9qaTJRhQIrCbjzQGzZ)zfG8(Uq2LFr280j4VcuzZ)Fp8XKfpLISPrG544ll7hMKnlE(OSPbLQSTrDbMKnuSaJcuzJgZbrhlzR(etw8esMSJS4bfqcyEHoOyMYfoySVsae(toG2pmPoqXcL7jt2rw8GcibmVqhumt5cxJqWcO9PSJhQIrCbbr5U27JIyEyKa6Zka59DHamgRhumSBbYkqarNG)kqvr)3dFmzXtagJ1dkgCzhzPcvya9fq0ExJgTeZdJeGIr24(3XeiaJX6bfNmeJ4csqwDOk4QAbAjGUTdIbxeq32bvY9sNgnAHqv2)7bkotMky28FwbiVVlKnZztZlg5MnEY(EHLISPrWJai6ztZAecwGSnjBHoKnmQSXVSrcyEHE2coBxqYw3koB1NyYINSzHhMaztZlgzJ7FhtGKj7ilEqbKaMxOdkMPCHdg7ReaH)KdO9dtQduSq5EYKDKfpOasaZl0bfZuUW1ieSaAVpkI5HrcOpRaK33fcWySEqXqmpmsakgzJ7FhtGamgRhumSJSuHkmG(cik3zW(FVa6Zka59DHab0TDqLCpW9ipYboXIU8kf4OeLyea]] )

end