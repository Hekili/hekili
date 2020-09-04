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
            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
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
            alias = { "deadly_poison_dot", "wound_poison_dot" },
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
            max_stack = 1,
            meta = {
                exsanguinated = function ( t ) return t.up and ruptures[ target.unit ] end,
                last_tick = function ( t ) return ltR[ target.unit ] or t.applied end,
                tick_time = function ( t )
                    --if not talent.exsanguinate.enabled then return 2 * haste end
                    return t.exsanguinated and haste or ( 2 * haste ) end,
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
            duration = 3600,
        },
        nonlethal_poison = {
            alias = { "crippling_poison", "numbing_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600,
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
            
            usable = function () return stealth.all or buff.blindside.up, "requires stealth or blindside proc" end,
            handler = function ()
                gain( 2, "combo_points" )
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

            usable = function () return combo_points.current > 0 end,
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
                applyDebuff( "target", "serrated_bone_spike", nil, debuff.serrated_bone_spike.stack + 1 )
                gain( ( buff.broadside.up and 1 or 0 ) + debuff.serrated_bone_spike.stack, "combo_points" )
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
                removeBuff( "instant_poison" )
                applyBuff( "slaughter_poison" )
                gain( buff.broadside.up and 3 or 2, "combo_points" )
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


    spec:RegisterPack( "Assassination", 20200904, [[deLagcqisjpsIWLqsaBcf9jKePrHk5uOIwfss9kuOzrk1TujPDj4xQegMkfhtLQLPs0ZqLQPjbCnvsSnjI6BsGyCsG05qLsTouPW7qssvZtI09qI9Hc(hQusDqKKyHQK6Hij0ersexevkAJsGs(issYiLaL6KOsjwjsQxkrKmtKKuUPeOyNsidvIiwksI6POQPkbDvjIuBvcu9vKKuzSijq7vO)kPbl1HPSyu6XQyYKCzWMvLptLgns1PvA1Osj51OcZMQUnvSBf)gQHtQooscA5iEoKPtCDv12rkFxIY4LqDEjQwVkLMpPy)IoEpwyKxzcel6YBU8MB423uGWnfuUxaUZ9iVuUoe51TdhMle5hZbI8ufeYqODmzXtKx3k3JnvSWipc)jhiYtxeDe34IlCxH(NnCWoxGwNV3KfphI9KlqRZ5Iip7F9c3YezJ8ktGyrxEZL3Cd3(MceUPGEj3(krE7l0XKip)6qfJ80xLcMiBKxbOtKVeztvqidH2XKfpztLXUFiPUezZd6c4WcKSVRD2xEZL3KuNuxISPI0TXfqCJK6sK9vZMQOuGk7sQ9Wr2coBf8SVxY2oYINS9lscj1Li7RMnvgCW0GSfJ4csDFHK6sK9vZMQOuGk7sAeKn3IaoOS5c)f0QGSXVSrcyEHoNHK6sK9vZMkIhAarav2qXiBC)7ycOcubZwWzRWsGkyakgzJ7FhtaviY7xKGIfg5rcyEHoOIfgl6ESWipmgRhuXRJ8hYkazTiVyEyKWSU0fKyEoasagJ1dQSzM9b7WIR64Deu2mqj7cKnZSfJ4csqwhOk4QAHSVA2eWX2bLndzxYrE7ilEI8KVU8jquIfDzSWipmgRhuXRJ8pmPoqXsSO7rE7ilEI86ySVsae(toquIfX9yHrEymwpOIxh5pKvaYArE7wGSceq0j4Vcuv0)9Whtw8eGXy9GkBMzZ(FVa6Zka59DHWxpBMzZ(FVa6Zka59DHabCSDqzxA23dCpBMzRv2iuL9)EGkYBhzXtK31ieSarjwubIfg5HXy9GkEDK)Hj1bkwIfDpYBhzXtKxhJ9vcGWFYbIsSORelmYdJX6bv86i)HScqwlYlMhgjG(ScqEFxiaJX6bv2mZMRSjGJTdk7sZ((LzRrt26oFVS6(fizxkLSVNnNzZmBXiUGeK1bQcUQwi7RMnbCSDqzZq2xg5TJS4jY7AecwGi)P8JhQIrCbbfl6EuIfvYXcJ8WySEqfVoYFiRaK1I8I5HrcOpRaK33fcWySEqLnZSTBbYkqarNG)kqvr)3dFmzXtagJ1dQSzMTwzRWsG81LpbcYE4yh3SzMnnJSgRhcODC9qvmIlirE7ilEI8KVU8jquIfvqIfg5HXy9GkEDK)Hj1bkwIfDpYBhzXtKxhJ9vcGWFYbIsSOcASWipmgRhuXRJ8hYkazTiVyEyKa6Zka59DHamgRhuzZmB7wGSceq0j4Vcuv0)9Whtw8eGXy9GkBMzZv22rwAqfgWzbu2mK99S1OjBTYwmpmsakgzJ7FhtGamgRhuzZz2mZwmIlibzDGQGRQfYMHSjGJTdkBMzZv2eWX2bLDPzFVGMTgnzRv2iuL9)EGkBoJ82rw8e5DncblqK)u(XdvXiUGGIfDpkXI42XcJ8WySEqfVoY)WK6aflXIUh5TJS4jYRJX(kbq4p5arjw09BIfg5HXy9GkEDK)qwbiRf5fZdJeqFwbiVVleGXy9GkBMzlMhgjafJSX9VJjqagJ1dQSzMTDKLguHbCwaLnLSVNnZSz)Vxa9zfG8(UqGao2oOSln77bUh5TJS4jY7AecwGOeLipGqWCauSWyr3Jfg5HXy9GkEDK)qwbiRf5HbiULhK1bQcU6yfNndzFpBMzRv2kG9)EbAWOarSWxpBMzZv2ALTclHdEoWietav95nhOY(jtq2dh74MnZS1kB7ilEch8CGriMaQ6ZBoqyN6ZVU0LS1Oj7337Re4q3iUqvwhi7sZ29OcowXzZzK3oYINi)bphyeIjGQ(8MdeLyrxglmYdJX6bv86i)HScqwlYRa2)7fObJceXcF9SzMnxzRa2)7fCncblqakgzJ7Fhtav2A0KTcy)VxarFPf(6zZm7d2Hfx1X7iOGcE7zLSlLs23ZwJMSva7)9c0GrbIybc4y7GYUukzF)MS5mBnAY(TU0LkbCSDqzxkLSVFtK3oYINipRhJvv8Rk0HkmGt5rjwe3Jfg5HXy9GkEDK)qwbiRf5pySxHlBc0GrbIybc4y7GYU0S5E2A0KTcy)VxGgmkqel81ZwJMSFRlDPsahBhu2LMn3VjYBhzXtK39Be1Atf)Q2Tabl0JsSOcelmYdJX6bv86i)HScqwlY)8ymjBUYMRSFRlDPsahBhu2xnBUFt2CMnvGSTJS4PEWyVcx2KnNzZq2ppgtYMRS5k736sxQeWX2bL9vZM73K9vZ(GXEfUSjqdgfiIfiGJTdkBoZMkq22rw8upySxHlBYMZiVDKfprE3VruRnv8RA3ceSqpkXIUsSWipmgRhuXRJ8hYkazTipsh8(QyexqqHNnv8RYXS0au2mqj7lZwJMSj2QQanyKGPuOWozZq2L8nzZmByaIB5zxA2fKBYwJMSFRlDPsahBhu2LM99BI82rw8e5F4ZhbQQDlqwbQSG5eLyrLCSWipmgRhuXRJ8hYkazTipsh8(QyexqqHNnv8RYXS0au2mqj7lZwJMSj2QQanyKGPuOWozZq2L8nzRrt2V1LUujGJTdk7sZ((nrE7ilEI86FY(kFh3kR3qsuIfvqIfg5HXy9GkEDK)qwbiRf5z)VxGaho8acvFyYbcF9S1OjB2)7fiWHdpGq1hMCG6b)hbibKyhoYU0SVFtK3oYINiVqhQ)Hf)hv9HjhikXIkOXcJ82rw8e5jRUUhQ7ur62bI8WySEqfVokXI42XcJ82rw8e5ldt8kAWovcGWJnhiYdJX6bv86Oel6(nXcJ8WySEqfVoYFiRaK1I8Wae3YZU0SVYnzZmBTY(GXEfUSjqdgfiIf(6rE7ilEI8oGdMuEf)Q()zvvfbmhuuIfD)ESWipmgRhuXRJ8hYkazTiVyexqcY6avbxvlKDPzFpCLS1OjBUYMRSfJ4csGoyEHEq)izZq2f0BYwJMSfJ4csGoyEHEq)izxkLSV8MS5mBMzZv22rwAqfgWzbu2uY(E2A0KTyexqcY6avbxvlKndzFj3oBoZMZS1OjBUYwmIlibzDGQGR6hPE5nzZq2C)MSzMnxzBhzPbvyaNfqztj77zRrt2IrCbjiRdufCvTq2mKDbkq2CMnNrE7ilEI8eW03XT(8MdGI8NYpEOkgXfeuSO7rjkrEf8SVxIfgl6ESWipmgRhuXRJ8hYkazTiVwzJeW8cDqfmVpYBhzXtKNJ9WruIfDzSWiVDKfprEKaMxOh5HXy9GkEDuIfX9yHrEymwpOIxh5X6rEeirE7ilEI80mYASEiYtZ8FiYddqClpqaxyYMXS1XlcpGQY6bqHYMQZUGKnvGS5k7lZMQZgPdEFLUHeiBoJ80msDmhiYddqClVsaxyQhSd7oGkkXIkqSWipmgRhuXRJ8y9ipcKiVDKfprEAgznwpe5Pz(pe5r6G3xfJ4cck8SPIFvoMLgGYU0SVmYtZi1XCGipAhxpufJ4csuIfDLyHrEymwpOIxh5TJS4jYFmVVAhzXt1VijYFiRaK1I8ibmVqhubc29drE)IK6yoqKhjG5f6GkkXIk5yHrEymwpOIxh5TJS4jYFmVVAhzXt1VijYFiRaK1I8CLTwzlMhgj4yibivdHmeANamgRhuzRrt2kSeCncblqq2dh74MnNrE)IK6yoqK)OqrjwubjwyKhgJ1dQ41rE7ilEI8hZ7R2rw8u9lsI8(fj1XCGiVclrjwubnwyKhgJ1dQ41rE7ilEI8hZ7R2rw8u9lsI8(fj1XCGiVAjWrIsSiUDSWipmgRhuXRJ8hYkazTipmaXT8GcE7zLSzGs23Vs2mMnnJSgRhcWae3YReWfM6b7WUdOI82rw8e5nYXgOkycbgjkXIUFtSWiVDKfprEJCSbQ6FpcI8WySEqfVokXIUFpwyK3oYINiVFDPlOk3QVY1bgjYdJX6bv86Oel6(LXcJ82rw8e5zn3k(vfYE4af5HXy9GkEDuIsKxNahSdRjXcJfDpwyK3oYINiVPR7lVQJxeEI8WySEqfVokXIUmwyK3oYINipsaZl0J8WySEqfVokXI4ESWipmgRhuXRJ8hYkazTipXwvfObJemLcf2jBgY((vI82rw8e5DmchGQ(WKQcmHEKxNahSdRjveCWJcf5VsuIfvGyHrEymwpOIxh5hZbI82Ti6gXq1hEKk(v1XLbKiVDKfprE7weDJyO6dpsf)Q64YasuIfDLyHrE7ilEI86yzXtKhgJ1dQ41rjkrE1sGJelmw09yHrEymwpOIxh5pKvaYAr(d2Hfx1X7iOSzGs2fiBgZwmpmsqbGoqQiHyI5cobymwpOYMz2CLTcy)VxGgmkqel81ZwJMSva7)9ci6lTWxpBnAYggG4wEqbV9Ss2Lsj7lVs2mMnnJSgRhcWae3YReWfM6b7WUdOYwJMS1kBAgznwpeq746HQyexqYMZSzMnxzRv2I5HrcqXiBC)7yceGXy9GkBnAYwRSva7)9c0GrbIyHVE2A0K9bJ9kCztakgzJ7FhtGabCSDqzZq2xMnNrE7ilEI8WqdgStuIfDzSWipmgRhuXRJ8y9ipcKiVDKfprEAgznwpe5Pz(pe5pyhwCvhVJGck4TNvYMHSVNTgnzddqClpOG3Ewj7sPK9LxjBgZMMrwJ1dbyaIB5vc4ct9GDy3buzRrt2ALnnJSgRhcODC9qvmIlirEAgPoMde5)iO(wVhirjwe3Jfg5HXy9GkEDK)qwbiRf5PzK1y9q4JG6B9EGKnZSTBbYkqao0X74wz9McqbymwpOYMz2iDW7RIrCbbfE2uXVkhZsdqzZaLSVmBgZMRSva7)9c0GrbIyHVE2uD2CL99SzmBUY2UfiRab4qhVJBL1Bkafi2Wr2uY(E2CMnNzZzK3oYINi)ZMk(v5ywAakkXIkqSWipmgRhuXRJ8hYkazTipnJSgRhcFeuFR3dKSzMnxzZ(FVa9vPGPY6nfGciXoCKnduY(o3oBnAYMRS1kBDYIjRuELGftw8KnZSr6G3xfJ4cck8SPIFvoMLgGYMbkzxGSzmBUY2UfiRabf(Z6HQcJGaXgoYMHSVmBoZMXSrcyEHoOceS7hYMZS5mYBhzXtK)ztf)QCmlnafLyrxjwyKhgJ1dQ41r(dzfGSwKNMrwJ1dHpcQV17bs2mZgPdEFvmIliOWZMk(v5ywAakBgOKn3J82rw8e5F2uXVkhZsdqr(t5hpufJ4cckw09OelQKJfg5HXy9GkEDK)qwbiRf5PzK1y9q4JG6B9EGKnZS5kB2)7fy97OqRccF9S1OjBTYwmpmsGgmyNk5JOhGXy9GkBMzRv22TazfiOWFwpuvyeeGXy9GkBoJ82rw8e5z97OqRcIsSOcsSWipmgRhuXRJ8hYkazTipnJSgRhcFeuFR3dKSzMnsh8(QyexqqHNnv8RYXS0au2uY(YiVDKfprENVSEtGi)P8JhQIrCbbfl6EuIfvqJfg5HXy9GkEDK)qwbiRf5PzK1y9q4JG6B9EGe5TJS4jY78L1BceLOe5pkuSWyr3Jfg5HXy9GkEDKFmhiYB3IOBedvF4rQ4xvhxgqI82rw8e5TBr0nIHQp8iv8RQJldir(dzfGSwKxRSrcyEHoOcM3NnZSDmKaKQHqgcTtLao2oOSPK9nzZmBUY(GXEfUSjqdgfiIfiGJTdk7s5wNnxzFWyVcx2eq0xAbc4y7GYMQZgOc)RUoOcgIonBauLy3Ij1dMy(S5mBoZU0SVFt2mM99BYMQZgOc)RUoOcgIonBauLy3Ij1dMy(SzMTwzRa2)7fObJceXcF9SzMTwzRa2)7fq0xAHVEuIfDzSWipmgRhuXRJ82rw8e5pM3xTJS4P6xKe5pKvaYArETYgjG5f6GkyEF2mZwHLa5RlFceK9WXoUzZmBhdjaPAiKHq7ujGJTdkBkzFtK3ViPoMde5becMdGIsSiUhlmYdJX6bv86i)HScqwlYtSvvbAWibtPqHVE2mZMRSfJ4csqwhOk4QAHSln7d2Hfx1X7iOGcE7zLSP6SVhUs2A0K9b7WIR64DeuqbV9Ss2mqj7JE1XkUI0HrLnNrE7ilEI8ogHdqvFysvbMqpYFk)4HQyexqqXIUhLyrfiwyKhgJ1dQ41r(dzfGSwKNyRQc0GrcMsHc7KndzZ9BY(QztSvvbAWibtPqb1NyYINSzM9b7WIR64DeuqbV9Ss2mqj7JE1XkUI0Hrf5TJS4jY7yeoav9Hjvfyc9Oel6kXcJ8WySEqfVoYJ1J8iqI82rw8e5PzK1y9qKNM5)qKxRSfZdJeqFwbiVVleGXy9GkBnAYwRSTBbYkqarNG)kqvr)3dFmzXtagJ1dQS1OjBfwcUgHGfiO789YQ7xGKndzFpBMzZv2iDW7RIrCbbfE2uXVkhZsdqzxA2LC2A0KTwzFWyVcx2eOzZIOh(6zZzKNMrQJ5arEAWOarSk6Zka59DH6bpQvw8eLyrLCSWipmgRhuXRJ8y9ipcKiVDKfprEAgznwpe5Pz(pe51kBX8WiHzDPliX8CaKamgRhuzRrt2ALTyEyKaumYg3)oMabymwpOYwJMSpySxHlBcqXiBC)7yceiGJTdk7sZ(kzF1SVmBQoBX8Wibfa6aPIeIjMl4eGXy9GkYtZi1XCGipnyuGiwDwx6csmphaPEWJALfprjwubjwyKhgJ1dQ41rESEKhbsK3oYINipnJSgRhI80m)hI8ALnqf(xDDqfSBr0nIHQp8iv8RQJldizRrt22TazfiGOtWFfOQO)7HpMS4jaJX6bv2A0KTcy)VxGy3Ij1dMy(Qcy)VxqHlBYwJMSpySxHlBcgIonBauLy3Ij1dMy(abCSDqzxA23VjBMzZv2hm2RWLnbe9LwGao2oOSln77zRrt2kG9)Ebe9Lw4RNnNrEAgPoMde5PbJceXQp8i1dEuRS4jkXIkOXcJ8WySEqfVoYFiRaK1I8ALnsaZl0bvGGD)q2mZwHLa5RlFceK9WXoUzZmBTYwbS)3lqdgfiIf(6zZmBAgznwpeObJceXQOpRaK33fQh8OwzXt2mZMMrwJ1dbAWOarS6SU0fKyEoas9Gh1klEYMz20mYASEiqdgfiIvF4rQh8OwzXtK3oYINipnyuGiwuIfXTJfg5HXy9GkEDK)qwbiRf5fZdJeGIr24(3XeiaJX6bv2mZwmpmsywx6csmphajaJX6bv2mZ(GDyXvD8ockBgOK9rV6yfxr6WOYMz2hm2RWLnbOyKnU)DmbceWX2bLDPzFpYBhzXtKNMnlIEuIfD)MyHrEymwpOIxh5pKvaYArEX8WiHzDPliX8CaKamgRhuzZmBTYwmpmsakgzJ7FhtGamgRhuzZm7d2Hfx1X7iOSzGs2h9QJvCfPdJkBMzZv2kG9)EbAWOarSWxpBnAYgqiyoqG2Iw8uXVQoqEWrw8eGXy9GkBoJ82rw8e5PzZIOhLyr3VhlmYdJX6bv86ipwpYJajYBhzXtKNMrwJ1drEAM)drE7wGSceq0j4Vcuv0)9Whtw8eGXy9GkBMzZv2dEQiuL9)EGQkgXfeu2mqj77zRrt2iDW7RIrCbbfE2uXVkhZsdqztjBUNnNzZmBUYgHQS)3duvXiUGGQglMgu1Trbo7jBkzFt2A0Knsh8(QyexqqHNnv8RYXS0au2mqj7soBoJ80msDmhiYJqvA2Si61dEuRS4jkXIUFzSWipmgRhuXRJ8pmPoqXsSO7rE7ilEI86ySVsae(toqKhkwiw1CW)rI8f4krjw0DUhlmYdJX6bv86i)HScqwlYlMhgjG(ScqEFxiaJX6bv2mZwRSrcyEHoOceS7hYMz2hm2RWLnbxJqWce(6zZmBUYMMrwJ1dbeQsZMfrVEWJALfpzRrt2ALTDlqwbci6e8xbQk6)E4JjlEcWySEqLnZS5kBfwcUgHGfiqGhbq0nwpKTgnzRa2)7fObJceXcF9SzMTclbxJqWce0D(Ez19lqYUukzFpBoZMZSzM9b7WIR64DeuqbV9Ss2mqjBUYMRSVNnJzFz2uD22TazfiGOtWFfOQO)7HpMS4jaJX6bv2CMnvNnsh8(QyexqqHNnv8RYXS0au2CMndCRZUazZmBITQkqdgjykfkSt2mK99lJ82rw8e5PzZIOhLyr3lqSWipmgRhuXRJ8hYkazTiVyEyKGJHeGuneYqODcWySEqLnZS1kBKaMxOdQG59zZmBhdjaPAiKHq7ujGJTdk7sPK9nzZmBTYwHLa5RlFceiWJai6gRhYMz2kSeCncblqGao2oOSziBUNnZS5kBfW(FVanyuGiw4RNnZSva7)9ci6lTWxpBMzZv2ALnGqWCGaRhJvv8Rk0HkmGt5bhJBfMKTgnzRa2)7fy9ySQIFvHouHbCkp81ZMZS1OjBaHG5abAlAXtf)Q6a5bhzXtagJ1dQS5mYBhzXtKNMnlIEuIfD)kXcJ8WySEqfVoYFiRaK1I8ALnsaZl0bvW8(SzMTDlqwbci6e8xbQk6)E4JjlEcWySEqLnZSvyj4AecwGabEear3y9q2mZwHLGRriybc6oFVS6(fizxkLSVNnZSpyhwCvhVJGck4TNvYMbkzFpYBhzXtKhr3u4YCaVkkXIUxYXcJ8WySEqfVoYFiRaK1I8ALnsaZl0bvGGD)q2mZMRS1kBfwcUgHGfiqGhbq0nwpKnZSvyjq(6YNabc4y7GYMHSlq2mMDbYMQZ(OxDSIRiDyuzRrt2kSeiFD5tGabCSDqzt1zFt4kzZq2IrCbjiRdufCvTq2CMnZSfJ4csqwhOk4QAHSzi7ce5TJS4jYdfJSX9VJjquIfDVGelmYdJX6bv86i)HScqwlYRWsG81LpbcYE4yh3SzMnxzRv2av4F11bvWUfr3igQ(WJuXVQoUmGKTgnzFWyVcx2eObJceXceWX2bLndzF)MS5mYBhzXtKhrFPfLyr3lOXcJ8WySEqfVoYFiRaK1I8S)3lW6XyL)JKabSJKTgnzRa2)7fObJceXcF9iVDKfprEDSS4jkXIUZTJfg5HXy9GkEDK)qwbiRf5va7)9c0GrbIyHVEK3oYINipRhJv13NuEuIfD5nXcJ8WySEqfVoYFiRaK1I8kG9)EbAWOarSWxpYBhzXtKNfiiGWXoUrjw0L3Jfg5HXy9GkEDK)qwbiRf5va7)9c0GrbIyHVEK3oYINi)BjaRhJvrjw0LxglmYdJX6bv86i)HScqwlYRa2)7fObJceXcF9iVDKfprEBoasiMVEmVpkXIUK7XcJ8WySEqfVoYpMde5DnpCmVhiOklgprE7ilEI8UMhoM3deuLfJNi)HScqwlYZv2kG9)EbAWOarSWxpBnAYMRS1kBX8WibOyKnU)DmbcWySEqLnZSpySxHlBc0GrbIybc4y7GYMHSlWvYwJMSfZdJeGIr24(3XeiaJX6bv2mZMRSpySxHlBcqXiBC)7yceiGJTdk7sZUKZwJMSpySxHlBcqXiBC)7yceiGJTdkBgY(YBYMz2V1LUujGJTdkBgYUKVs2CMnNzZz2mZwRSvyjq(6YNabOyKnU)Dmburjw0LfiwyKhgJ1dQ41r(XCGiVHOtZgavj2Tys9GjMpYBhzXtK3q0PzdGQe7wmPEWeZh5pKvaYArEfW(FVaXUftQhmX8vfW(FVGcx2KTgnz)wx6sLao2oOSln7lVjkXIU8kXcJ8WySEqfVoYpMde5neDA2aOkXUftQhmX8rE7ilEI8gIonBauLy3Ij1dMy(i)HScqwlYZv2ALTyEyKaumYg3)oMabymwpOYwJMS1kBX8Wib0NvaY77cbymwpOYMZSzMTcy)VxGgmkqelqahBhu2mK99BY(QzxGSP6SbQW)QRdQGDlIUrmu9HhPIFvDCzajkXIUSKJfg5HXy9GkEDKFmhiYBi60SbqvIDlMupyI5J82rw8e5neDA2aOkXUftQhmX8r(dzfGSwKNRSfZdJeGIr24(3XeiaJX6bv2mZwmpmsa9zfG8(UqagJ1dQS5mBMzRa2)7fObJceXcF9SzMnxzRWsW1ieSabOyKnU)DmbuzRrt22TazfiGOtWFfOQO)7HpMS4jaJX6bv2mZwHLGRriybc6oFVS6(fizZq23ZMZOel6YcsSWipmgRhuXRJ8hYkazTiVJHeGuneYqODQeWX2bLnLSVjBMzRv2kG9)EbAWOarSWxpBMzRv2kG9)Ebe9Lw4RNnZSz)VxWbCWKYR4x1)pRQQiG5GckCzt2mZggG4wE2LMDb9MSzMTclbYxx(eiqahBhu2mKDbI82rw8e5pLF8yHGN9uz9gsI8W7bhPoMde5pLF8yHGN9uz9gsIsSOllOXcJ8WySEqfVoYpMde59Fchabv3bTQf)rv39jrE7ilEI8(pHdGGQ7Gw1I)OQ7(Ki)HScqwlYRa2)7fObJceXcF9Oel6sUDSWipmgRhuXRJ8J5arE)hje8hvDXEfmvD)3XCHiVDKfprE)hje8hvDXEfmvD)3XCHi)HScqwlYRa2)7fObJceXcF9OelI73elmYdJX6bv86i)HScqwlYRa2)7fObJceXcF9iVDKfprExVPwtWeu1buM3V4jYdVhCK6yoqK31BQ1embvDaL59lEIsSiUFpwyKhgJ1dQ41r(dzfGSwKxbS)3lqdgfiIf(6rE7ilEI8UEtTMGjOkRPCHip8EWrQJ5arExVPwtWeuL1uUquIfX9lJfg5TJS4jY)rqDfWbf5HXy9GkEDuIsKxHLyHXIUhlmYdJX6bv86ipwpYJajYBhzXtKNMrwJ1drEAM)drEDYIjRuELGftw8KnZSr6G3xfJ4cck8SPIFvoMLgGYMHS5E2mZMRSvyj4AecwGabCSDqzxA2hm2RWLnbxJqWceuFIjlEYwJMS1XlcpGQY6bqHYMHSVs2Cg5PzK6yoqKhXXQxpLF8q11ieSarjw0LXcJ8WySEqfVoYJ1J8iqI82rw8e5PzK1y9qKNM5)qKxNSyYkLxjyXKfpzZmBKo49vXiUGGcpBQ4xLJzPbOSziBUNnZS5kBfW(FVaI(sl81ZwJMS5kBD8IWdOQSEauOSzi7RKnZS1kB7wGSceqhyKk(vz9ySkaJX6bv2CMnNrEAgPoMde5rCS61t5hpujFD5tGOelI7XcJ8WySEqfVoYJ1J8iqI82rw8e5PzK1y9qKNM5)qKxbS)3lqdgfiIf(6zZmBUYwbS)3lGOV0cF9S1OjBhdjaPAiKHq7ujGJTdkBgY(MS5mBMzRWsG81LpbceWX2bLndzFzKNMrQJ5arEehREL81LpbIsSOcelmYdJX6bv86i)HScqwlYlMhgjafJSX9VJjqagJ1dQSzMTwzdfJSX9VJjGkBMzRWsW1ieSabDNVxwD)cKSlLs23ZMz2hm2RWLnbOyKnU)DmbceWX2bLDPzFz2mZgPdEFvmIliOWZMk(v5ywAakBkzFpBMztSvvbAWibtPqHDYMHSl5SzMTclbxJqWceiGJTdkBQo7Bcxj7sZwmIlibzDGQGRQfI82rw8e5DncblquIfDLyHrEymwpOIxh5pKvaYArEX8WibOyKnU)DmbcWySEqLnZS1kBfwcUgHGfiqGhbq0nwpKnZS5k7d2Hfx1X7iOSzGs2h9QJvCfPdJkBMzFWyVcx2eGIr24(3XeiqahBhu2LM99SzMTclbYxx(eiqahBhu2uD23eUs2LMTyexqcY6avbxvlKnNrE7ilEI8KVU8jquIfvYXcJ8WySEqfVoY)WK6aflXIUh5TJS4jYRJX(kbq4p5arjwubjwyKhgJ1dQ41r(dzfGSwKNapcGOBSEiBMzFWoS4QoEhbfuWBpRKnduY(E2mMn3ZMQZMRSTBbYkqarNG)kqvr)3dFmzXtagJ1dQSzM9bJ9kCztGMnlIE4RNnNzZmBUYw357Lv3Vaj7sPK99S1OjBc4y7GYUukzl7HJQSoq2mZgPdEFvmIliOWZMk(v5ywAakBgOKn3ZMXSTBbYkqarNG)kqvr)3dFmzXtagJ1dQS5mBMzZv2ALnumYg3)oMaQS1OjBc4y7GYUukzl7HJQSoq2uD2xMnZSr6G3xfJ4cck8SPIFvoMLgGYMbkzZ9SzmB7wGSceq0j4Vcuv0)9Whtw8eGXy9GkBoZMz2ALncvz)VhOYMz2CLTyexqcY6avbxvlK9vZMao2oOS5mBgYUazZmBUY2XqcqQgczi0ovc4y7GYMs23KTgnzRv2YE4yh3SzMTDlqwbci6e8xbQk6)E4JjlEcWySEqLnNrE7ilEI8UgHGfikXIkOXcJ8WySEqfVoY)WK6aflXIUh5TJS4jYRJX(kbq4p5arjwe3owyKhgJ1dQ41r(dzfGSwKxRSPzK1y9qaXXQxpLF8q11ieSazZmBc8iaIUX6HSzM9b7WIR64DeuqbV9Ss2mqj77zZy2CpBQoBUY2UfiRabeDc(Ravf9Fp8XKfpbymwpOYMz2hm2RWLnbA2Si6HVE2CMnZS5kBDNVxwD)cKSlLs23ZwJMSjGJTdk7sPKTShoQY6azZmBKo49vXiUGGcpBQ4xLJzPbOSzGs2CpBgZ2UfiRabeDc(Ravf9Fp8XKfpbymwpOYMZSzMnxzRv2qXiBC)7ycOYwJMSjGJTdk7sPKTShoQY6azt1zFz2mZgPdEFvmIliOWZMk(v5ywAakBgOKn3ZMXSTBbYkqarNG)kqvr)3dFmzXtagJ1dQS5mBMzRv2iuL9)EGkBMzZv2IrCbjiRdufCvTq2xnBc4y7GYMZSzi77xMnZS5kBhdjaPAiKHq7ujGJTdkBkzFt2A0KTwzl7HJDCZMz22TazfiGOtWFfOQO)7HpMS4jaJX6bv2Cg5TJS4jY7AecwGi)P8JhQIrCbbfl6EuIfD)MyHrEymwpOIxh5pKvaYArEKo49vXiUGGYMHS5E2mZMao2oOSln7lZMXS5kBKo49vXiUGGYMbkzFLS5mBMzFWoS4QoEhbLnduYUarE7ilEI8hY6GWtvahDajr(t5hpufJ4cckw09Oel6(9yHrEymwpOIxh5pKvaYArETYMMrwJ1dbehREL81LpbYMz2CL9b7WIR64Deu2mqj7cKnZSjWJai6gRhYwJMS1kBzpCSJB2mZMRSL1bYMHSVFt2A0K9b7WIR64Deu2mqj7lZMZS5mBMzZv26oFVS6(fizxkLSVNTgnztahBhu2LsjBzpCuL1bYMz2iDW7RIrCbbfE2uXVkhZsdqzZaLS5E2mMTDlqwbci6e8xbQk6)E4JjlEcWySEqLnNzZmBUYwRSHIr24(3XeqLTgnztahBhu2LsjBzpCuL1bYMQZ(YSzMnsh8(QyexqqHNnv8RYXS0au2mqjBUNnJzB3cKvGaIob)vGQI(Vh(yYINamgRhuzZz2mZwmIlibzDGQGRQfY(QztahBhu2mKDbI82rw8e5jFD5tGOel6(LXcJ8WySEqfVoYFiRaK1I8ALnnJSgRhciow96P8JhQKVU8jq2mZwRSPzK1y9qaXXQxjFD5tGSzM9b7WIR64Deu2mqj7cKnZSjWJai6gRhYMz2CLTUZ3lRUFbs2Lsj77zRrt2eWX2bLDPuYw2dhvzDGSzMnsh8(QyexqqHNnv8RYXS0au2mqjBUNnJzB3cKvGaIob)vGQI(Vh(yYINamgRhuzZz2mZMRS1kBOyKnU)DmbuzRrt2eWX2bLDPuYw2dhvzDGSP6SVmBMzJ0bVVkgXfeu4ztf)QCmlnaLnduYM7zZy22TazfiGOtWFfOQO)7HpMS4jaJX6bv2CMnZSfJ4csqwhOk4QAHSVA2eWX2bLndzxGSzmBUYwhVi8aQkRhafkBgY(YS5mBQo7soYBhzXtKN81LpbI8NYpEOkgXfeuSO7rjw0DUhlmYdJX6bv86i)HScqwlYJ0bVVkgXfeu2mK99SzMnsh8(QyexqqzxA2fiBMztahBhu2LM9LzZm7d2Hfx1X7iOSzGs2fiYBhzXtK)qwheEQc4OdijYFk)4HQyexqqXIUhLyr3lqSWipmgRhuXRJ8hYkazTipsh8(Qyexqqztj77zZm7d2Hfx1X7iOSzGs2CL9rV6yfxr6WOY(QzFpBoZMz2e4raeDJ1dzZmBTYgkgzJ7Fhtav2mZwRSva7)9ci6lTWxpBMz7yibivdHmeANkbCSDqztj7BYMz2ALTDlqwbcszlsQcDOYXSpiaJX6bv2mZwmIlibzDGQGRQfY(QztahBhu2mKDbI82rw8e5pK1bHNQao6asIsSO7xjwyKhgJ1dQ41r(dzfGSwKhPdEFvmIliOSziBUYUGK9vZM9)EbyObd2j81ZMZSzM9b7WIR64Deu2mqj7cKnJzlMhgjOaqhivKqmXCbNamgRhuzZmBTYwbS)3lqdgfiIf(6zZmBTYwbS)3lGOV0cF9SzMTwzB3cKvGGu2IKQqhQCm7dcWySEqLnZSHbiULhuWBpRKDPuY(YRKnJztZiRX6HamaXT8kbCHPEWoS7aQiVDKfpr(dzDq4PkGJoGKOeLOe5Pbe0INyrxEZL3Cd3(M7r(YmYSJlkYtvhvHkxe3sruvCJSZUq6q2RJoMiz)WKSPsbecMdGOsZMauH)LaQSryhiB7lyhtav2h624cOqsnvTDGSVKBKnvep0aIaQSPsHIr24(3XeqfOcsLMTGZMkvbS)3lqfmafJSX9VJjGIknBUUxmNHK6KAQ6Oku5I4wkIQIBKD2fshYED0Xej7hMKnvQAjWrOsZMauH)LaQSryhiB7lyhtav2h624cOqsnvTDGSlzUr2L0d6RRJjcOY2oYINSPsz97OqRcOsdj1j1Clo6yIaQSlizBhzXt2(fjOqsDKxNGFRhI8LiBQcczi0oMS4jBQm29dj1LiBEqxahwGK9DTZ(YBU8MK6K6sKnvKUnUaIBKuxISVA2ufLcuzxsThoYwWzRGN99s22rw8KTFrsiPUezF1SPYGdMgKTyexqQ7lKuxISVA2ufLcuzxsJGS5weWbLnx4VGwfKn(LnsaZl05mKuxISVA2ur8qdicOYgkgzJ7FhtavGky2coBfwcubdqXiBC)7ycOcj1j1LiBUzXW5lGkBw4Hjq2hSdRjzZcU7Gcztvohqxqzp45Q0nIZ77Z2oYIhu24XxEiPUezBhzXdkOtGd2H1ekpVH4iPUezBhzXdkOtGd2H1egPCH9DDGrmzXtsDjY2oYIhuqNahSdRjms5IhgRsQlr28JPJOJLSj2QYM9)EGkBKyckBw4Hjq2hSdRjzZcU7GY2gv26e4Q6yr2Xn7fLTcpqiPUezBhzXdkOtGd2H1egPCbAmDeDSurIjOKA7ilEqbDcCWoSMWiLlmDDF5vD8IWtsTDKfpOGoboyhwtyKYfibmVqpP2oYIhuqNahSdRjms5chJWbOQpmPQatORToboyhwtQi4GhfIYv0EFui2QQanyKGPuOWomC)kj12rw8Gc6e4GDynHrkx8rqDfWr7XCak2Ti6gXq1hEKk(v1XLbKKA7ilEqbDcCWoSMWiLl0XYINK6K6sKn3Sy48fqLnqdiLNTSoq2cDiB7iys2lkBJMTEJ1dHK6sKnvgqcyEHE27lBDmcTSEiBUgC20((bigRhYggWzbu27K9b7WAcNj12rw8GOWXE4q79rrlKaMxOdQG59j12rw8GyKYfibmVqpP2oYIheJuUGMrwJ1dApMdqbgG4wELaUWupyh2DaL20m)hOadqClpqaxyyuhVi8aQkRhafIQliub46sQgPdEFLUHeGZKA7ilEqms5cAgznwpO9yoaf0oUEOkgXfeTPz(pqbPdEFvmIliOWZMk(v5ywAaQ0ltQTJS4bXiLloM3xTJS4P6xKO9yoafKaMxOdkT3hfKaMxOdQab7(HKA7ilEqms5IJ59v7ilEQ(fjApMdq5OqAVpkCPLyEyKGJHeGuneYqODcWySEqPrJclbxJqWceK9WXoUCMuBhzXdIrkxCmVVAhzXt1Vir7XCakkSKuBhzXdIrkxCmVVAhzXt1Vir7XCakQLahjP2oYIheJuUWihBGQGjeyeT3hfyaIB5bf82Zkmq5(vyKMrwJ1dbyaIB5vc4ct9GDy3buj12rw8GyKYfg5ydu1)EeKuBhzXdIrkx4xx6cQYT6RCDGrsQTJS4bXiLlyn3k(vfYE4aLuNuxISPIySxHlBqj12rw8GchfIYhb1vahThZbOy3IOBedvF4rQ4xvhxgq0EFu0cjG5f6GkyEpthdjaPAiKHq7ujGJTdIYnm56GXEfUSjqdgfiIfiGJTdQuU1CDWyVcx2eq0xAbc4y7GOAGk8V66Gkyi60SbqvIDlMupyI55KZsVFdJ3VHQbQW)QRdQGHOtZgavj2Tys9GjMNPwkG9)EbAWOarSWxNPwkG9)Ebe9Lw4RNuBhzXdkCuigPCXX8(QDKfpv)IeThZbOaiemhaP9(OOfsaZl0bvW8EMkSeiFD5tGGSho2XLPJHeGuneYqODQeWX2br5MK6sKn3YlBtPqzBei7VU2zJMvhYwOdzJhi7YwHE2ECzasYUWcPsczxsJGSlJomzRkFh3SFgsas2cDBYMkwsYwbV9Ss2ys2LTcD8xY2MYZMkwscj12rw8GchfIrkx4yeoav9HjvfycDTpLF8qvmIliik31EFui2QQanyKGPuOWxNjxIrCbjiRdufCvTqPhSdlUQJ3rqbf82Zku99Wv0O5GDyXvD8ockOG3EwHbkh9QJvCfPdJIZK6sKn3Yl7bNTPuOSlB9(SvlKDzRqFNSf6q2duSKn3VbPD2FeKDbZJkjB8KnlgHYUSvOJ)s22uE2uXssiP2oYIhu4Oqms5chJWbOQpmPQatOR9(OqSvvbAWibtPqHDyG73CvITQkqdgjykfkO(etw8W8GDyXvD8ockOG3EwHbkh9QJvCfPdJkPUezxWHrbIyz7XU7X8zFWJALfpMhLnRHav24j7ZNqGrYgPdNKA7ilEqHJcXiLlOzK1y9G2J5auObJceXQOpRaK33fQh8OwzXJ20m)hOOLyEyKa6Zka59DHamgRhuA0OLDlqwbci6e8xbQk6)E4JjlEcWySEqPrJclbxJqWce0D(Ez19lqy4otUq6G3xfJ4cck8SPIFvoMLgGkTK1OrRdg7v4YManBwe9WxNZKA7ilEqHJcXiLlOzK1y9G2J5auObJceXQZ6sxqI55ai1dEuRS4rBAM)du0smpmsywx6csmphajaJX6bLgnAjMhgjafJSX9VJjqagJ1dknAoySxHlBcqXiBC)7yceiGJTdQ0RC1lPAX8Wibfa6aPIeIjMl4eGXy9GkP2oYIhu4Oqms5cAgznwpO9yoafAgznwpO9yoafAWOarS6dps9Gh1klE0MM5)afTaQW)QRdQGDlIUrmu9HhPIFvDCzarJg7wGSceq0j4Vcuv0)9Whtw8eGXy9GsJgfW(FVaXUftQhmX8vfW(FVGcx2OrZbJ9kCztWq0PzdGQe7wmPEWeZhiGJTdQ073WKRdg7v4YMaI(slqahBhuP31OrbS)3lGOV0cFDotQTJS4bfokeJuUGgmkqet79rrlKaMxOdQab7(bMkSeiFD5tGGSho2XLPwkG9)EbAWOarSWxNjnJSgRhc0GrbIyv0NvaY77c1dEuRS4HjnJSgRhc0GrbIy1zDPliX8CaK6bpQvw8WKMrwJ1dbAWOarS6dps9Gh1klEsQlr2fCBwe9SlBf6zZnlg5MnJzx06sxqI55aiCJSlySIxNVt2uXss22OYMBwmYnBcyQYZ(HjzpqXs2uvurQKKA7ilEqHJcXiLlOzZIOR9(OiMhgjafJSX9VJjqagJ1dkMI5HrcZ6sxqI55aibymwpOyEWoS4QoEhbXaLJE1XkUI0HrX8GXEfUSjafJSX9VJjqGao2oOsVNuxISl42Si6zx2k0ZUO1LUGeZZbqYMXSlcNn3SyKl3i7cgR4157KnvSKKTnQSl4WOarSS)6zZ1F8acL9hTJB2fCCjHZKA7ilEqHJcXiLlOzZIOR9(OiMhgjmRlDbjMNdGeGXy9GIPwI5HrcqXiBC)7yceGXy9GI5b7WIR64Deeduo6vhR4kshgftUua7)9c0GrbIyHVUgnacbZbc0w0INk(v1bYdoYINamgRhuCMuxIS5bi7337Z(GDCGrYgpztxeDe34IlCxH(NnCWoxqLnAWqh7vYvlKkEbvg7(HlkB5yVGQGqgcTJjlEUkvPKqv7Quzabg5qpKuBhzXdkCuigPCbnJSgRh0EmhGccvPzZIOxp4rTYIhTPz(pqXUfiRabeDc(Ravf9Fp8XKfpbymwpOyY1GNkcvz)VhOQIrCbbXaL7A0G0bVVkgXfeu4ztf)QCmlnarH7CYKleQY(FpqvfJ4ccQASyAqv3gf4Shk3Ordsh8(QyexqqHNnv8RYXS0aedukzotQTJS4bfokeJuUqhJ9vcGWFYb0(Hj1bkwOCxBOyHyvZb)hHsbUssTDKfpOWrHyKYf0Szr01EFueZdJeqFwbiVVleGXy9GIPwibmVqhubc29dmpySxHlBcUgHGfi81zYfnJSgRhciuLMnlIE9Gh1klE0Orl7wGSceq0j4Vcuv0)9Whtw8eGXy9GIjxkSeCncblqGapcGOBSEqJgfW(FVanyuGiw4RZuHLGRriybc6oFVS6(fiLs5oNCY8GDyXvD8ockOG3EwHbkCX1DgVKQTBbYkqarNG)kqvr)3dFmzXtagJ1dkoPAKo49vXiUGGcpBQ4xLJzPbiozGBDbysSvvbAWibtPqHDy4(Lj1Li7cUnlIE2LTc9SlymKaKSPkiKH2HBKDr4SrcyEHE22OYEWzBhzPbzxWqvYM9)EANnv(RlFcK9GLS3jBc8iaIE2eBCbTZw9j74MDbhgfiIXyHxZ41yHBMnx)Xdiu2F0oUzxWXLeotQTJS4bfokeJuUGMnlIU27JIyEyKGJHeGuneYqODcWySEqXulKaMxOdQG59mDmKaKQHqgcTtLao2oOsPCdtTuyjq(6YNabc8iaIUX6bMkSeCncblqGao2oig4otUua7)9c0GrbIyHVotfW(FVaI(sl81zYLwacbZbcSEmwvXVQqhQWaoLhCmUvyIgnkG9)EbwpgRQ4xvOdvyaNYdFDo1ObqiyoqG2Iw8uXVQoqEWrw8eGXy9GIZK6sKnpDtHlZb8QSFys280j4VcuzZ)Fp8XKfpj12rw8GchfIrkxGOBkCzoGxP9(OOfsaZl0bvW8EM2TazfiGOtWFfOQO)7HpMS4jaJX6bftfwcUgHGfiqGhbq0nwpWuHLGRriybc6oFVS6(fiLs5oZd2Hfx1X7iOGcE7zfgOCpPUezZnlgzJ7FhtGSlJomzpyjBKaMxOdQSTrLnlwONnv(RlFcKTnQSPQmcblq2gbY(RN9dtY2Jh3SHb)DPhsQTJS4bfokeJuUakgzJ7FhtaT3hfTqcyEHoOceS7hyYLwkSeCncblqGapcGOBSEGPclbYxx(eiqahBhedfGXcq1h9QJvCfPdJsJgfwcKVU8jqGao2oiQ(MWvyqmIlibzDGQGRQf4KPyexqcY6avbxvlWqbsQTJS4bfokeJuUarFPP9(OOWsG81LpbcYE4yhxMCPfqf(xDDqfSBr0nIHQp8iv8RQJldiA0CWyVcx2eObJceXceWX2bXW9B4mP2oYIhu4Oqms5cDSS4r79rH9)EbwpgR8FKeiGDenAua7)9c0GrbIyHVEsTDKfpOWrHyKYfSEmwvFFs5AVpkkG9)EbAWOarSWxpP2oYIhu4Oqms5cwGGach74Q9(OOa2)7fObJceXcF9KA7ilEqHJcXiLlElby9ySs79rrbS)3lqdgfiIf(6j12rw8GchfIrkxyZbqcX81J59AVpkkG9)EbAWOarSWxpP2oYIhu4Oqms5IpcQRaoApMdqX18WX8EGGQSy8O9(OWLcy)VxGgmkqel811OHlTeZdJeGIr24(3XeiaJX6bfZdg7v4YManyuGiwGao2oigkWv0OrmpmsakgzJ7FhtGamgRhum56GXEfUSjafJSX9VJjqGao2oOslznAoySxHlBcqXiBC)7yceiGJTdIHlVH5BDPlvc4y7GyOKVcNCYjtTuyjq(6YNabOyKnU)Dmbuj12rw8GchfIrkx8rqDfWr7XCakgIonBauLy3Ij1dMyET3hffW(FVaXUftQhmX8vfW(FVGcx2OrZBDPlvc4y7Gk9YBsQTJS4bfokeJuU4JG6kGJ2J5aumeDA2aOkXUftQhmX8AVpkCPLyEyKaumYg3)oMabymwpO0OrlX8Wib0NvaY77cbymwpO4KPcy)VxGgmkqelqahBhed3V5QfGQbQW)QRdQGDlIUrmu9HhPIFvDCzajP2oYIhu4Oqms5IpcQRaoApMdqXq0PzdGQe7wmPEWeZR9(OWLyEyKaumYg3)oMabymwpOykMhgjG(ScqEFxiaJX6bfNmva7)9c0GrbIyHVotUuyj4AecwGaumYg3)oMaknASBbYkqarNG)kqvr)3dFmzXtagJ1dkMkSeCncblqq357Lv3VaHH7CMuBhzXdkCuigPCXhb1vahTH3dosDmhGYP8Jhle8SNkR3qI27JIJHeGuneYqODQeWX2br5gMAPa2)7fObJceXcFDMAPa2)7fq0xAHVot2)7fCahmP8k(v9)ZQQkcyoOGcx2WegG4wEPf0ByQWsG81LpbceWX2bXqbsQTJS4bfokeJuU4JG6kGJ2J5au8Fchabv3bTQf)rv39jAVpkkG9)EbAWOarSWxpP2oYIhu4Oqms5IpcQRaoApMdqX)rcb)rvxSxbtv3)Dmxq79rrbS)3lqdgfiIf(6j12rw8GchfIrkx8rqDfWrB49GJuhZbO46n1AcMGQoGY8(fpAVpkkG9)EbAWOarSWxpP2oYIhu4Oqms5IpcQRaoAdVhCK6yoafxVPwtWeuL1uUG27JIcy)VxGgmkqel81tQlr2ujWZ(Ej7N59S2HJSFys2FKX6HSxbCqCJSlPrq24j7dg7v4YMqsTDKfpOWrHyKYfFeuxbCqj1j1LiBQKLahjBL5yUq2g76xzbusDjYMBo0Gb7KTjzxagZMRRWy2LTc9SPs45mBQyjjKn3IJdOwtaF5zJNSVKXSfJ4ccs7SlBf6zxWHrbIyANnMKDzRqp7cVMQ(SXcDGu2IGSlZwj7hMKnc7azddqClpKuBhzXdkOwcCekWqdgSJ27JYb7WIR64DeedukaJI5Hrcka0bsfjetmxWjaJX6bftUua7)9c0GrbIyHVUgnkG9)Ebe9Lw4RRrdmaXT8GcE7zLsPC5vyKMrwJ1dbyaIB5vc4ct9GDy3buA0OfnJSgRhcODC9qvmIliCYKlTeZdJeGIr24(3XeiaJX6bLgnAPa2)7fObJceXcFDnAoySxHlBcqXiBC)7yceiGJTdIHl5mP2oYIhuqTe4ims5cAgznwpO9yoaLpcQV17bI20m)hOCWoS4QoEhbfuWBpRWWDnAGbiULhuWBpRukLlVcJ0mYASEiadqClVsaxyQhSd7oGsJgTOzK1y9qaTJRhQIrCbjPUeztv3k0ZMBEOJ3Xn7R9McqANDblBYg)YUKAwAakBtY(sgZwmIliiTZgtYM7xTamMTyexqqzxgDyYUGdJceXYErz)1tQTJS4bfulbocJuU4ztf)QCmlnaP9(OqZiRX6HWhb1369aHPDlqwbcWHoEh3kR3uakaJX6bftKo49vXiUGGcpBQ4xLJzPbigOCjJCPa2)7fObJceXcFDQMR7mYLDlqwbcWHoEh3kR3uakqSHdk35KtotQlr2fSSjB8l7sQzPbOSnj77CBgZgj2Hdu24x2fSxLcMSV2BkaLnMKT5A7GKSlaJzZ1vym7YwHE2uj4pRhYMkbJaoZwmIliOqsTDKfpOGAjWryKYfpBQ4xLJzPbiT3hfAgznwpe(iO(wVhim5I9)Eb6RsbtL1BkafqID4Gbk352A0WLw6KftwP8kblMS4Hjsh8(QyexqqHNnv8RYXS0aedukaJCz3cKvGGc)z9qvHrqGydhmCjNmIeW8cDqfiy3pWjNj1Li7cw2Kn(LDj1S0au2coBtx3xE2ujGP8LNDjbVi8K9(YEh7ilniB8KTnLNTyexqY2KS5E2IrCbbfsQTJS4bfulbocJuU4ztf)QCmlnaP9P8JhQIrCbbr5U27JcnJSgRhcFeuFR3deMiDW7RIrCbbfE2uXVkhZsdqmqH7j12rw8GcQLahHrkxW63rHwfO9(OqZiRX6HWhb1369aHjxS)3lW63rHwfe(6A0OLyEyKanyWovYhrpaJX6bftTSBbYkqqH)SEOQWiiaJX6bfNj1Li7cn2RwW8L1BcKTGZ2019LNnvcykF5zxsWlcpzBs2xMTyexqqj12rw8GcQLahHrkx48L1BcO9P8JhQIrCbbr5U27JcnJSgRhcFeuFR3deMiDW7RIrCbbfE2uXVkhZsdquUmP2oYIhuqTe4ims5cNVSEtaT3hfAgznwpe(iO(wVhij1j1LiBQeZXCHSX0as2Y6azBSRFLfqj1LiBQARZkztvzecwau24j7bpxvNSoeJuE2IrCbbL9dtYwOdzRtwmzLYZMGftw8K9(Y(kmMnRhafkBJazBEcyQYZ(RNuBhzXdkOWcfAgznwpO9yoafehRE9u(XdvxJqWcOnnZ)bk6KftwP8kblMS4Hjsh8(QyexqqHNnv8RYXS0aedCNjxkSeCncblqGao2oOspySxHlBcUgHGfiO(etw8OrJoEr4buvwpakedxHZK6sKnvT1zLSPYFD5tau24j7bpxvNSoeJuE2IrCbbL9dtYwOdzRtwmzLYZMGftw8K9(Y(kmMnRhafkBJazBEcyQYZ(RNuBhzXdkOWcJuUGMrwJ1dApMdqbXXQxpLF8qL81Lpb0MM5)afDYIjRuELGftw8WePdEFvmIliOWZMk(v5ywAaIbUZKlfW(FVaI(sl811OHlD8IWdOQSEauigUctTSBbYkqaDGrQ4xL1JXQamgRhuCYzsDjYMQ26Ss2u5VU8jak79LDbhgfiIXyH4I3t2x7nfCrbJHeGKnvbHmeANSxu2F9STrLDzq20nAq2xYy2i4GhfkBp8KSXt2cDiBQ8xx(eiBQeCHj12rw8GckSWiLlOzK1y9G2J5auqCS6vYxx(eqBAM)duua7)9c0GrbIyHVotUua7)9ci6lTWxxJghdjaPAiKHq7ujGJTdIHB4KPclbYxx(eiqahBhedxMuxIS51HZA(SPQmcblq22OYMk)1LpbYgbYxpBDYIjzl4S5MfJSX9VJjq2hdjj12rw8GckSWiLlCncblG27JIyEyKaumYg3)oMabymwpOyQfumYg3)oMakMkSeCncblqq357Lv3VaPuk3zEWyVcx2eGIr24(3XeiqahBhuPxYePdEFvmIliOWZMk(v5ywAaIYDMeBvvGgmsWukuyhgkzMkSeCncblqGao2oiQ(MWvkvmIlibzDGQGRQfsQTJS4bfuyHrkxq(6YNaAVpkI5HrcqXiBC)7yceGXy9GIPwkSeCncblqGapcGOBSEGjxhSdlUQJ3rqmq5OxDSIRiDyumpySxHlBcqXiBC)7yceiGJTdQ07mvyjq(6YNabc4y7GO6BcxPuXiUGeK1bQcUQwGZK6sKnvLriybY(RZba6ANT5r4SfYcOSfC2FeK9kzBOSTSr6WznF2UWaetWKSFys2cDiBVHKSPILKSzHhMazBz)2zr0bssTDKfpOGclms5cDm2xjac)jhq7hMuhOyHY9KA7ilEqbfwyKYfUgHGfq79rHapcGOBSEG5b7WIR64DeuqbV9ScduUZi3PAUSBbYkqarNG)kqvr)3dFmzXtagJ1dkMhm2RWLnbA2Si6HVoNm5s357Lv3VaPuk31OHao2oOsPi7HJQSoatKo49vXiUGGcpBQ4xLJzPbigOWDgTBbYkqarNG)kqvr)3dFmzXtagJ1dkozYLwqXiBC)7ycO0OHao2oOsPi7HJQSoavFjtKo49vXiUGGcpBQ4xLJzPbigOWDgTBbYkqarNG)kqvr)3dFmzXtagJ1dkozQfcvz)VhOyYLyexqcY6avbxvlCvc4y7G4KHcWKlhdjaPAiKHq7ujGJTdIYnA0OLSho2XLPDlqwbci6e8xbQk6)E4JjlEcWySEqXzsTDKfpOGclms5cDm2xjac)jhq7hMuhOyHY9KA7ilEqbfwyKYfUgHGfq7t5hpufJ4ccIYDT3hfTOzK1y9qaXXQxpLF8q11ieSamjWJai6gRhyEWoS4QoEhbfuWBpRWaL7mYDQMl7wGSceq0j4Vcuv0)9Whtw8eGXy9GI5bJ9kCztGMnlIE4RZjtU0D(Ez19lqkLYDnAiGJTdQukYE4OkRdWePdEFvmIliOWZMk(v5ywAaIbkCNr7wGSceq0j4Vcuv0)9Whtw8eGXy9GItMCPfumYg3)oMaknAiGJTdQukYE4OkRdq1xYePdEFvmIliOWZMk(v5ywAaIbkCNr7wGSceq0j4Vcuv0)9Whtw8eGXy9GItMAHqv2)7bkMCjgXfKGSoqvWv1cxLao2oioz4(Lm5YXqcqQgczi0ovc4y7GOCJgnAj7HJDCzA3cKvGaIob)vGQI(Vh(yYINamgRhuCMuxISPIK1bHNSleC0bKKnEY257Lv3dzlgXfeu2MKDbymBQyjj7YOdt2K)m74Mn(lzVt2xEvUJYMlwdbQSXt2IrCbj7d(pcNzJNSTP8SfJ4cssTDKfpOGclms5IdzDq4PkGJoGeTpLF8qvmIliik31EFuq6G3xfJ4ccIbUZKao2oOsVKrUq6G3xfJ4ccIbkxHtMhSdlUQJ3rqmqPaj1Li7ska0Z(RNnv(RlFcKTjzxagZgpzBEF2IrCbbLnxLrhMS9lTDCZ2Jh3SHb)DPNTnQShSKnAmDeDSWzsTDKfpOGclms5cYxx(eq79rrlAgznwpeqCS6vYxx(eGjxhSdlUQJ3rqmqPamjWJai6gRh0OrlzpCSJltUK1by4(nA0CWoS4QoEhbXaLl5KtMCP789YQ7xGukL7A0qahBhuPuK9WrvwhGjsh8(QyexqqHNnv8RYXS0aedu4oJ2TazfiGOtWFfOQO)7HpMS4jaJX6bfNm5slOyKnU)DmbuA0qahBhuPuK9WrvwhGQVKjsh8(QyexqqHNnv8RYXS0aedu4oJ2TazfiGOtWFfOQO)7HpMS4jaJX6bfNmfJ4csqwhOk4QAHRsahBhedfiP2oYIhuqHfgPCb5RlFcO9P8JhQIrCbbr5U27JIw0mYASEiG4y1RNYpEOs(6YNam1IMrwJ1dbehREL81LpbyEWoS4QoEhbXaLcWKapcGOBSEGjx6oFVS6(fiLs5UgneWX2bvkfzpCuL1byI0bVVkgXfeu4ztf)QCmlnaXafUZODlqwbci6e8xbQk6)E4JjlEcWySEqXjtU0ckgzJ7FhtaLgneWX2bvkfzpCuL1bO6lzI0bVVkgXfeu4ztf)QCmlnaXafUZODlqwbci6e8xbQk6)E4JjlEcWySEqXjtXiUGeK1bQcUQw4QeWX2bXqbyKlD8IWdOQSEauigUKtQUKtQlr2urY6GWt2fco6asYgpzF)QCpBNVxwDpKTyexqqzBs2fGXSPILKSlJomzt(ZSJB24VK9ozFjkB8KTnLNTyexqsQTJS4bfuyHrkxCiRdcpvbC0bKO9P8JhQIrCbbr5U27Jcsh8(QyexqqmCNjsh8(QyexqqLwaMeWX2bv6LmpyhwCvhVJGyGsbsQlr2urY6GWt2fco6asYgpzZxy27l7DYw3gf4SNSTrL9kzx269zRWz7bekBL5yUq2cDBYMBo0Gb7KT6dzl4Sl86lkyOkxuOusLuBhzXdkOWcJuU4qwheEQc4Odir79rbPdEFvmIliik3zEWoS4QoEhbXafUo6vhR4kshg1vVZjtc8iaIUX6bMAbfJSX9VJjGIPwkG9)Ebe9Lw4RZ0XqcqQgczi0ovc4y7GOCdtTSBbYkqqkBrsvOdvoM9bbymwpOykgXfKGSoqvWv1cxLao2oigkqsDjYMkAijBQizDq4j7cbhDajzJNSPkyUz27GeWuzJFzZnhAWGDY2KSlimMTyexqqzxgDyYUGdJceXUOWRZErzpyj7VEsTDKfpOGclms5IdzDq4PkGJoGeT3hfKo49vXiUGGyGRcYvz)VxagAWGDcFDozEWoS4QoEhbXaLcWOyEyKGcaDGurcXeZfCcWySEqXulfW(FVanyuGiw4RZulfW(FVaI(sl81zQLDlqwbcszlsQcDOYXSpiaJX6bftyaIB5bf82ZkLs5YRWinJSgRhcWae3YReWfM6b7WUdOsQtQlr2CtecMdGsQTJS4bfaecMdGOCWZbgHycOQpV5aAVpkWae3YdY6avbxDSIz4otTua7)9c0GrbIyHVotU0sHLWbphyeIjGQ(8Mduz)Kji7HJDCzQLDKfpHdEoWietav95nhiSt95xx6IgnVV3xjWHUrCHQSoqPUhvWXkMZK6sKnvXxMvok7pcY(ApgRYUSvONDbhgfiIL9xpKDbBSxL9dtYMBwmYg3)oMaHSlPrq2LTc9Sl86S)6zZcpmbY2Y(TZIOdKSnu2E84MTHYELSj)bL9dtY((nOSvFYoUzxWHrbIyHKA7ilEqbaHG5aigPCbRhJvv8Rk0HkmGt5AVpkkG9)EbAWOarSWxNjxqXiBC)7ycOcUgHGfqJgfW(FVaI(sl81zEWoS4QoEhbfuWBpRukL7A0Oa2)7fObJceXceWX2bvkL73WPgnV1LUujGJTdQuk3VjPUeztvebC0LSfC2MFDNSPQ(grT2KDzRqp7comkqelBdLThpUzBOSxj7YWdvQKnbqFVK9oz7XODCZ2Y(99(RsZ8Fi7JHKSX0as2cDiBc4y7SJB2QpXKfpzJFzl0HSFRlDjP2oYIhuaqiyoaIrkx4(nIATPIFv7wGGf6AVpkhm2RWLnbAWOarSabCSDqLYDnAua7)9c0GrbIyHVUgnV1LUujGJTdQuUFtsTDKfpOaGqWCaeJuUW9Be1Atf)Q2Tabl01EFuEEmMWfxV1LUujGJTd6QC)goPcCWyVcx2Wjdppgt4IR36sxQeWX2bDvUFZvpySxHlBc0GrbIybc4y7G4KkWbJ9kCzdNj12rw8GcacbZbqms5Ih(8rGQA3cKvGklyoAVpkiDW7RIrCbbfE2uXVkhZsdqmq5snAi2QQanyKGPuOWomuY3WegG4wEPfKB0O5TU0LkbCSDqLE)MKA7ilEqbaHG5aigPCH(NSVY3XTY6nKO9(OG0bVVkgXfeu4ztf)QCmlnaXaLl1OHyRQc0GrcMsHc7WqjFJgnV1LUujGJTdQ073KuBhzXdkaiemhaXiLle6q9pS4)OQpm5aAVpkS)3lqGdhEaHQpm5aHVUgnS)3lqGdhEaHQpm5a1d(pcqciXoCu69BsQTJS4bfaecMdGyKYfKvx3d1DQiD7aj12rw8GcacbZbqms5IYWeVIgStLai8yZbsQTJS4bfaecMdGyKYfoGdMuEf)Q()zvvfbmhK27JcmaXT8sVYnm16GXEfUSjqdgfiIf(6j1Li7c2yVkBQmy674MDblV5aOSFys2qXW5lq2eBCHSXKS5y9(Sz)Vhs7S3x26yeAz9qiBQIVmRCu2cP8SfC2UGKTqhY2Jldqs2hm2RWLnzZAiqLnEY2OzR3y9q2WaolGcj12rw8GcacbZbqms5ccy674wFEZbqAFk)4HQyexqquUR9(OigXfKGSoqvWv1cLEpCfnA4IlXiUGeOdMxOh0pcdf0B0OrmIlib6G5f6b9JukLlVHtMCzhzPbvyaNfquURrJyexqcY6avbxvlWWLCBo5uJgUeJ4csqwhOk4Q(rQxEddC)gMCzhzPbvyaNfquURrJyexqcY6avbxvlWqbkaNCMuNuxIS5fW8cDqLnv5ilEqj1Li7Iwx6iX8CaKSXt23lKBKn)y6i6yjBQ8xx(eiP2oYIhuajG5f6GIc5RlFcO9(OiMhgjmRlDbjMNdGeGXy9GI5b7WIR64DeedukatXiUGeK1bQcUQw4QeWX2bXqjNuxIS5)ScqEFxiBgZMNob)vGkB()7HpMS4HBKn3CqFcKDzq2FeKnEGSD9ywZNTGZ2019LNnvLriybYwWzl0HSDSDYwmIlizVVSxj7fL9GLSrJPJOJLSlheTZgHZ28(SXcDGKTJTt2IrCbjBJD9RSakBDc(TsiP2oYIhuajG5f6GIrkxOJX(kbq4p5aA)WK6afluUNuBhzXdkGeW8cDqXiLlCncblG27JIDlqwbci6e8xbQk6)E4JjlEcWySEqXK9)Eb0NvaY77cHVot2)7fqFwbiVVleiGJTdQ07bUZuleQY(FpqLuxIS5)ScqEFxGBKnvrx3xE2ys2uz4rae9SlBf6zZ(FpqLnvLriybqj12rw8GcibmVqhums5cDm2xjac)jhq7hMuhOyHY9KA7ilEqbKaMxOdkgPCHRriyb0(u(XdvXiUGGOCx79rrmpmsa9zfG8(UqagJ1dkMCrahBhuP3VuJgDNVxwD)cKsPCNtMIrCbjiRdufCvTWvjGJTdIHltQlr28FwbiVVlKnJzZtNG)kqLn))9Whtw8K9ozZxi3iBQIUUV8SbJ4lpBQ8xx(eiBHUjzx269zZcztGhbq0bv2pmjBDBuGZEsQTJS4bfqcyEHoOyKYfKVU8jG27JIyEyKa6Zka59DHamgRhumTBbYkqarNG)kqvr)3dFmzXtagJ1dkMAPWsG81LpbcYE4yhxM0mYASEiG2X1dvXiUGKuxIS5)ScqEFxi7YUiBE6e8xbQS5)Vh(yYIhUr2uzW019LN9dtYMfpFu2uXss22OUatYgkwGrbQSrJPJOJLSvFIjlEcj12rw8GcibmVqhums5cDm2xjac)jhq7hMuhOyHY9KA7ilEqbKaMxOdkgPCHRriyb0(u(XdvXiUGGOCx79rrmpmsa9zfG8(UqagJ1dkM2TazfiGOtWFfOQO)7HpMS4jaJX6bftUSJS0GkmGZcigURrJwI5HrcqXiBC)7yceGXy9GItMIrCbjiRdufCvTadeWX2bXKlc4y7Gk9EbvJgTqOk7)9afNj1LiB(pRaK33fYMXS5MfJCZgpzFVqUr2uz4rae9SPQmcblq2MKTqhYggv24x2ibmVqpBbNTliz7yfNT6tmzXt2SWdtGS5MfJSX9VJjqsTDKfpOasaZl0bfJuUqhJ9vcGWFYb0(Hj1bkwOCpP2oYIhuajG5f6GIrkx4AecwaT3hfX8Wib0NvaY77cbymwpOykMhgjafJSX9VJjqagJ1dkM2rwAqfgWzbeL7mz)Vxa9zfG8(UqGao2oOsVh4EKhPdNyrxEfUDuIsmca]] )

end