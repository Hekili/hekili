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
        toxic_blade = 23015, -- 245388
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


    -- Legendary from Legion, shows up in APL still.
    spec:RegisterGear( "mantle_of_the_master_assassin", 144236 )
    spec:RegisterAura( "master_assassins_initiative", {
        id = 235027,
        duration = 3600
    } )

    spec:RegisterStateExpr( "mantle_duration", function ()
        if level > 115 then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 5
        elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
        return 0
    end )

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
            if level < 116 and equipped.mantle_of_the_master_assassin then
                applyBuff( "master_assassins_initiative", 5 )
            end

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
            duration = 14,
            max_stack = 1,
            meta = {
                exsanguinated = function ( t ) return t.up and crimson_tempests[ target.unit ] end,                
                last_tick = function ( t ) return ltCT[ target.unit ] or t.applied end,
                tick_time = function( t ) return t.exsanguinated and haste or ( 2 * haste ) end,
            },                    
        },
        crimson_vial = {
            id = 185311,
            duration = 6,
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
            duration = 4,
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
            duration = 3,
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
        kidney_shot = {
            id = 408,
            duration = 1,
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
            duration = 5,
            max_stack = 3,
        },
        master_assassins_initiative = {
            id = 235027,
            duration = 5,
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
        seal_fate = {
            id = 14190,
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
        sign_of_battle = {
            id = 186403,
            duration = 3600,
            max_stack = 1,
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
        toxic_blade = {
            id = 245389,
            duration = 9,
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
        blind = {
            id = 2094,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = true,
            texture = 136175,

            handler = function ()
                applyDebuff( "target", "blind" )
                -- applies blind (2094)
            end,
        },


        blindside = {
            id = 111240,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.blindside.up and 0 or 30 end,
            spendType = "energy",

            startsCombat = true,
            texture = 236274,

            usable = function () return buff.blindside.up or target.health_pct < 30 end,
            handler = function ()
                gain( 1, "combo_points" )
                removeBuff( "blindside" )
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
            nobuff = "crippling_poison",

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

            nobuff = "deadly_poison",

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

            usable = function () return combo_points.current > 0 end,

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
                    applyDebuff( "target", "garrote_silence" ) 

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
            remains = function () return remains - ( duration * 0.3 ), remains - tick_time, remains - tick_time * 2, remains, cooldown.exsanguinate.remains - 1, 10 - time end,
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

            usable = function () return stealthed.all end,
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


        shroud_of_concealment = {
            id = 114018,
            cast = 0,
            cooldown = 360,
            gcd = "spell",

            startsCombat = false,
            texture = 635350,

            usable = function () return stealthed.all end,
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

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up end,            
            handler = function ()
                applyBuff( "stealth" )
            end,
        },


        toxic_blade = {
            id = 245388,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            spend = 20,
            spendType = "energy",

            startsCombat = true,
            texture = 135697,

            talent = "toxic_blade",

            handler = function ()
                applyDebuff( "target", "toxic_blade" )
                gain( 1, "combo_points" )
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
                return not ( boss and group )
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
            gcd = "spell",

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
            nobuff = "wound_poison",

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
        }


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


    spec:RegisterPack( "Assassination", 20200802, [[deLUicqiuv9iHcxsOOQnHu(eQkQrHcDkuWQqsQxHu1Sec3sLs2LGFjuzyQuCmvQwMqPNHQsttiY1ujPTPscFtikgNqu5CcfL1HQcEhQkKAEcvDpKyFiv(NqushuLszHQK6HQKOjQsPYfrvr2OquIpIKKmsHIKojQkuRej1lfksntHIk3uik1ofsnuHIyPijXtjLPkKCvuvi2Qqu1xrvHKXIKKAVs8xjnyPomLfJspwftMKld2SQ8zQ0OrfNwPvluK41OsMnvDBs1Uv8BidNkoUkLQwoINd10jUUQA7OOVRsy8OsDEvIwpsI5JQSFrxUxIQOPmbkrh7nXEZnrUBIne79iflFJmfn5shOO5yhUmxOOnMou0Unm2W4DmzrtrZXU0JmvjQIgg9jhOOXrehmFiU4CxHZNnCq6XHx9V3KfnhI9K4WR(jUIg7F9cF8uylAktGs0XEtS3CtK7MydXEpsXgBmROzFHdIu00w9RSOXzvkykSfnfGpfTyK9THXggVJjlAYMQGC)qsDmYMJioy(qCX5UcNpB4G0JdV6FVjlAoe7jXHx9tCj1Xi7B77(Xs2Xgr2XEtS3KuNuhJSVso24cy(qsDmY(wzFBkfOYoMEpCLTGYwbp77LSTJSOjB)ILqsDmY(wztvaDetiBXiUGu3xiPogzFRSVnLcuzZhbdzZhlGooBgrFbVkiB0lBSaMx4WqiPogzFRSVs0WeicOYg4gBJ7FhtavGQoBbLTcjbQ6aWn2g3)oMaQqrZVybxIQOHfW8chqvIQe99sufnymwpOkxx0oKvaYAfnX8WiHzD5iyX8CbKamgRhuztl7dsNfvDq7i4SPJs2rkBAzlgXfKGS6qvqv1czFRSjGUTdoB6Y(kkA2rw0u0iFh5tGIuIo2sufnymwpOkxx0EisDaULs03lA2rw0u0CqiFLay0NCGIuIMVLOkAWySEqvUUODiRaK1kAgvaYkqaZHG(kqvX)3dDmzrtagJ1dQSPLn7)9c4pRaK33fcFNSPLn7)9c4pRaK33fceq32bND8zFpW3SPLn)zJXv2)7bQIMDKfnfnxJqqcuKs0rQevrdgJ1dQY1fThIuhGBPe99IMDKfnfnheYxjag9jhOiLOVAjQIgmgRhuLRlA2rw0u0Cncbjqr7qwbiRv0eZdJeWFwbiVVleGXy9GkBAzZy2eq32bND8zFp2S5XlBh9Vxwh)cKSJNs23ZMHSPLTyexqcYQdvbvvlK9TYMa62o4SPl7ylANlpEOkgXfeCj67fPe9vuIQObJX6bv56I2HScqwROjMhgjG)ScqEFxiaJX6bv20Y2Ocqwbcyoe0xbQk()EOJjlAcWySEqLnTS5pBfscKVJ8jqq2dx74MnTSzAK1y9qaVJRhQIrCbPOzhzrtrJ8DKpbksj6itjQIgmgRhuLRlApePoa3sj67fn7ilAkAoiKVsam6toqrkrh5krv0GXy9GQCDrZoYIMIMRriibkAhYkazTIMyEyKa(Zka59DHamgRhuztlBJkazfiG5qqFfOQ4)7HoMSOjaJX6bv20YMXSTJSmHkmG(c4SPl77zZJx28NTyEyKaWn2g3)oMabymwpOYMHSPLTyexqcYQdvbvvlKnDztaDBhC20YMXSjGUTdo74Z(EKlBE8YM)SX4k7)9av2mu0oxE8qvmIli4s03lsj6ywjQIgmgRhuLRlApePoa3sj67fn7ilAkAoiKVsam6toqrkrF)MsufnymwpOkxx0oKvaYAfnX8Wib8NvaY77cbymwpOYMw2I5Hrca3yBC)7yceGXy9GkBAzBhzzcvya9fWztj77ztlB2)7fWFwbiVVleiGUTdo74Z(EGVfn7ilAkAUgHGeOifPObymmhaxIQe99sufnymwpOkxx0oKvaYAfnyaI7Lbz1HQGQ6g3ztx23ZMw28NTcy)VxGjmkqel8DYMw2mMn)zRqs4GMdmcXeqvFEthQSFYeK9W1oUztlB(Z2oYIMWbnhyeIjGQ(8Moe2P(8RlhjBE8Y(99(kboCmIluLvhYo(SDpQGUXD2mu0SJSOPODqZbgHycOQpVPdfPeDSLOkAWySEqvUUODiRaK1kAkG9)EbMWOarSW3jBAzZy2kG9)EbxJqqceaUX24(3XeqLnpEzRa2)7fee37PY6nfe(oztl7dsNfvDq7i4GcE7zLSJNs23ZMhVSva7)9cmHrbIybcOB7GZoEkzF)MSziBE8Y(TUCKkb0TDWzhpLSVFtrZoYIMIgRhHuv0RkCGkmG(LfPenFlrv0GXy9GQCDr7qwbiRv0oiKxHUycmHrbIybcOB7GZo(S5B284LTcy)VxGjmkqel8DYMhVSFRlhPsaDBhC2XNnFVPOzhzrtrZ9Be1Atf9Qgvacs4uKs0rQevrdgJ1dQY1fTdzfGSwr75ris2mMnJz)wxosLa62o4SVv289MSzi7y(STJSOPEqiVcDXKndztx2ppcrYMXSzm736YrQeq32bN9TYMV3K9TY(GqEf6IjWegfiIfiGUTdoBgYoMpB7ilAQheYRqxmzZqrZoYIMIM73iQ1Mk6vnQaeKWPiLOVAjQIgmgRhuLRlAhYkazTIg2b8(QyexqWHNnv0RY1SmbC20rj7yZMhVSj2QQatyKGPu4Woztx2xXnztlByaI7LzhF2rMBYMhVSFRlhPsaDBhC2XN99BkA2rw0u0EOZhdQQrfGScuzbtViLOVIsufnymwpOkxx0oKvaYAfnSd49vXiUGGdpBQOxLRzzc4SPJs2XMnpEztSvvbMWibtPWHDYMUSVIBYMhVSFRlhPsaDBhC2XN99BkA2rw0u0C(K9D5oUvwVHLIuIoYuIQObJX6bv56I2HScqwROX(FVaboC5bmU(qKde(ozZJx2S)3lqGdxEaJRpe5a1d6pcqcyXoCLD8zF)MIMDKfnfnHdu)dl6pQ6droqrkrh5krv0SJSOPOrwhhpu3PIDSdu0GXy9GQCDrkrhZkrv0SJSOPODbI4vmHDQeaJgBoqrdgJ1dQY1fPe99Bkrv0GXy9GQCDr7qwbiRv0GbiUxMD8zF1BYMw28N9bH8k0ftGjmkqel8DkA2rw0u00bDe5Yk6v9)ZQQkcy64IuI((9sufnymwpOkxx0SJSOPOraZzh36ZB6aUODiRaK1kAIrCbjiRoufuvTq2XN99WvZMhVSzmBgZwmIliboG5fobNJKnDzh5UjBE8YwmIliboG5fobNJKD8uYo2BYMHSPLnJzBhzzcvya9fWztj77zZJx2IrCbjiRoufuvTq20LDSXSSziBgYMhVSzmBXiUGeKvhQcQ6CKAS3KnDzZ3BYMw2mMTDKLjuHb0xaNnLSVNnpEzlgXfKGS6qvqv1cztx2rkszZq2mu0oxE8qvmIli4s03lsrkAk4zFVuIQe99sufnymwpOkxx0oKvaYAfn(ZglG5foGkyEFrZoYIMIgx7HRIuIo2sufn7ilAkAybmVWPObJX6bv56IuIMVLOkAWySEqvUUOHCkAyqkA2rw0u0yAK1y9qrJP5)qrdgG4EzGaUWKn9z7GwmAavL1dGcNnvNDKj7y(Szm7yZMQZg7aEFLJHfiBgkAmnsDmDOObdqCVSsaxyQhKo7oGQiLOJujQIgmgRhuLRlAiNIggKIMDKfnfnMgznwpu0yA(pu0WoG3xfJ4cco8SPIEvUMLjGZo(SJTOX0i1X0HIgEhxpufJ4csrkrF1sufnymwpOkxx0oKvaYAfnSaMx4aQab5(HIMDKfnfTJ59v7ilAQ(flfn)IL6y6qrdlG5foGQiLOVIsufnymwpOkxx0oKvaYAfngZM)SfZdJe0nSaKQHXggVtagJ1dQS5XlBfscUgHGeii7HRDCZMHIMDKfnfTJ59v7ilAQ(flfn)IL6y6qr7OWfPeDKPevrdgJ1dQY1fn7ilAkAhZ7R2rw0u9lwkA(fl1X0HIMcjfPeDKRevrdgJ1dQY1fn7ilAkAhZ7R2rw0u9lwkA(fl1X0HIMAjWrksj6ywjQIgmgRhuLRlAhYkazTIgmaX9YGcE7zLSPJs23VA20NntJSgRhcWae3lReWfM6bPZUdOkA2rw0u0mYXgOkicbgPiLOVFtjQIMDKfnfnJCSbQoFpgkAWySEqvUUiLOVFVevrZoYIMIMFD5i4AmLVYvhgPObJX6bv56IuI(ESLOkA2rw0u0yn3k6vfYE4cx0GXy9GQCDrksrZHahKoRjLOkrFVevrZoYIMIM544VS6GwmAkAWySEqvUUiLOJTevrdgJ1dQY1fn7ilAkA6gHlqvFisvbMWPODiRaK1kAeBvvGjmsWukCyNSPl77xTO5qGdsN1KkgoOrHlAxTiLO5BjQIMDKfnfnSaMx4u0GXy9GQCDrkrhPsufnymwpOkxx0gthkAgvWCmIHRp0iv0R6GUaifn7ilAkAgvWCmIHRp0iv0R6GUaifPe9vlrv0SJSOPO5GKfnfnymwpOkxxKIu0ulbosjQs03lrv0GXy9GQCDr7qwbiRv0oiDwu1bTJGZMokzhPSPpBX8WibfaoaPIfIjMlOhGXy9GkBAzZy2kG9)EbMWOarSW3jBE8YwbS)3liiU3tL1Bki8DYMhVSHbiUxguWBpRKD8uYo2RMn9zZ0iRX6HamaX9YkbCHPEq6S7aQS5XlB(ZMPrwJ1db8oUEOkgXfKSziBAzZy28NTyEyKaWn2g3)oMabymwpOYMhVS5pBfW(FVatyuGiw47KnpEzFqiVcDXeaUX24(3XeiqaDBhC20LDSzZqrZoYIMIgmmHbPxKs0XwIQObJX6bv56IgYPOHbPOzhzrtrJPrwJ1dfnMM)dfTdsNfvDq7i4GcE7zLSPl77zZJx2Wae3ldk4TNvYoEkzh7vZM(SzAK1y9qagG4EzLaUWupiD2Dav284Ln)zZ0iRX6HaEhxpufJ4csrJPrQJPdfTpgQV17bsrkrZ3sufnymwpOkxx0oKvaYAfnMgznwpe(yO(wVhiztlBJkazfiahoODCRSEtb4amgRhuztlBSd49vXiUGGdpBQOxLRzzc4SPJs2XMn9zZy2kG9)EbMWOarSW3jBQoBgZ(E20NnJzBubiRab4WbTJBL1Bkahi2Wv2uY(E2mKndzZqrZoYIMI2ZMk6v5AwMaUiLOJujQIgmgRhuLRlAhYkazTIgtJSgRhcFmuFR3dKSPLnJzZ(FVaNvPGPY6nfGdyXoCLnDuY(EmlBE8YMXS5pBhYIiRCzLGetw0KnTSXoG3xfJ4cco8SPIEvUMLjGZMokzhPSPpBgZ2Ocqwbck0N1dvfcdbInCLnDzhB2mKn9zJfW8chqfii3pKndzZqrZoYIMI2ZMk6v5AwMaUiLOVAjQIgmgRhuLRlA2rw0u0E2urVkxZYeWfTdzfGSwrJPrwJ1dHpgQV17bs20Yg7aEFvmIli4WZMk6v5AwMaoB6OKnFlANlpEOkgXfeCj67fPe9vuIQObJX6bv56I2HScqwROX0iRX6HWhd1369ajBAzZy2S)3lW63rHxfe(ozZJx28NTyEyKatyq6vYhZjaJX6bv20YM)SnQaKvGGc9z9qvHWqagJ1dQSzOOzhzrtrJ1VJcVkOiLOJmLOkAWySEqvUUOzhzrtrt)lR3eOODiRaK1kAmnYASEi8Xq9TEpqYMw2yhW7RIrCbbhE2urVkxZYeWztj7ylANlpEOkgXfeCj67fPeDKRevrdgJ1dQY1fTdzfGSwrJPrwJ1dHpgQV17bsrZoYIMIM(xwVjqrksr7OWLOkrFVevrdgJ1dQY1fn7ilAkAgvWCmIHRp0iv0R6GUaifTdzfGSwrJ)SXcyEHdOcM3NnTS1nSaKQHXggVtLa62o4SPK9nztlBgZ(GqEf6IjWegfiIfiGUTdo74JSMnJzFqiVcDXeee37PY6nfeiGUTdoBQoB42)xhhqfmmhM2a4kXOcIupiI5ZMHSzi74Z((nztF23VjBQoB42)xhhqfmmhM2a4kXOcIupiI5ZMw28NTcy)VxGjmkqel8DYMw28NTcy)VxqqCVNkR3uq47u0gthkAgvWCmIHRp0iv0R6GUaifPeDSLOkAWySEqvUUODiRaK1kA8NnwaZlCavW8(SPLTcjbY3r(eii7HRDCZMw26gwas1WydJ3PsaDBhC2uY(MIMDKfnfTJ59v7ilAQ(flfn)IL6y6qrdWyyoaUiLO5BjQIgmgRhuLRlA2rw0u00ncxGQ(qKQcmHtr7qwbiRv0i2QQatyKGPu4W3jBAzZy2IrCbjiRoufuvTq2XN9bPZIQoODeCqbV9Ss2uD23dxnBE8Y(G0zrvh0ocoOG3EwjB6OK9XPQBCxXoWOYMHI25YJhQIrCbbxI(ErkrhPsufnymwpOkxx0oKvaYAfnITQkWegjykfoSt20LnFVj7BLnXwvfycJemLchuFIjlAYMw2hKolQ6G2rWbf82ZkzthLSpovDJ7k2bgvrZoYIMIMUr4cu1hIuvGjCksj6RwIQObJX6bv56IgYPOHbPOzhzrtrJPrwJ1dfnMM)dfn(Zwmpmsa)zfG8(UqagJ1dQS5XlB(Z2Ocqwbcyoe0xbQk()EOJjlAcWySEqLnpEzRqsW1ieKabh9Vxwh)cKSPl77ztlBgZg7aEFvmIli4WZMk6v5AwMao74Z(kYMhVS5p7dc5vOlMatBwmNW3jBgkAmnsDmDOOXegfiIvXFwbiVVlupOrTYIMIuI(kkrv0GXy9GQCDrd5u0WGu0SJSOPOX0iRX6HIgtZ)HIg)zlMhgjmRlhblMNlGeGXy9GkBE8YM)SfZdJeaUX24(3XeiaJX6bv284L9bH8k0fta4gBJ7FhtGab0TDWzhF2xn7BLDSzt1zlMhgjOaWbivSqmXCb9amgRhufnMgPoMou0ycJceXQZ6YrWI55ci1dAuRSOPiLOJmLOkAWySEqvUUOHCkAyqkA2rw0u0yAK1y9qrJP5)qrJ)SHB)FDCavWOcMJrmC9HgPIEvh0fajBE8Y2Ocqwbcyoe0xbQk()EOJjlAcWySEqLnpEzRa2)7figvqK6brmFvbS)3lOqxmzZJx2heYRqxmbdZHPnaUsmQGi1dIy(ab0TDWzhF23VjBAzZy2heYRqxmbbX9EQSEtbbcOB7GZo(SVNnpEzRa2)7fee37PY6nfe(ozZqrJPrQJPdfnMWOarS6dns9Gg1klAksj6ixjQIgmgRhuLRlAhYkazTIg)zJfW8chqfii3pKnTSzmBgZwHKa57iFceK9W1oUztlB(ZwbS)3lWegfiIf(oztlBMgznwpeycJceXQ4pRaK33fQh0Owzrt20YMPrwJ1dbMWOarS6SUCeSyEUas9Gg1klAYMw2mnYASEiWegfiIvFOrQh0Owzrt2mKnpEz)wxosLa62o4SJNs2XEt2mu0SJSOPOXegfiIvKs0XSsufnymwpOkxx0oKvaYAfnX8WibGBSnU)DmbcWySEqLnTSfZdJeM1LJGfZZfqcWySEqLnTSpiDwu1bTJGZMokzFCQ6g3vSdmQSPL9bH8k0fta4gBJ7FhtGab0TDWzhF23lA2rw0u0yAZI5uKs03VPevrdgJ1dQY1fTdzfGSwrtmpmsywxocwmpxajaJX6bv20YM)SfZdJeaUX24(3XeiaJX6bv20Y(G0zrvh0ocoB6OK9XPQBCxXoWOYMw2mMTcy)VxGjmkqel8DYMhVSbmgMdeyU4fnv0R6aKhCKfnbymwpOYMHIMDKfnfnM2SyofPe997LOkAWySEqvUUOHCkAyqkA2rw0u0yAK1y9qrJP5)qrZOcqwbcyoe0xbQk()EOJjlAcWySEqLnTSzm7bnvmUY(FpqvfJ4ccoB6OK99S5XlBSd49vXiUGGdpBQOxLRzzc4SPKnFZMHSPLnJzJXv2)7bQQyexqWvJfXeQo2Oa99KnLSVjBE8Yg7aEFvmIli4WZMk6v5AwMaoB6OK9vKndfnMgPoMou0W4ktBwmN6bnQvw0uKs03JTevrdgJ1dQY1fn7ilAkAoiKVsam6toqrd4wiw10r)rkAr6QfThIuhGBPe99IuI(oFlrv0GXy9GQCDr7qwbiRv0eZdJeWFwbiVVleGXy9GkBAzZF2ybmVWbubcY9dztl7dc5vOlMGRriibcFNSPLnJzZ0iRX6HagxzAZI5upOrTYIMS5XlB(Z2Ocqwbcyoe0xbQk()EOJjlAcWySEqLnTSzmBfscUgHGeiqGhbWCmwpKnpEzRa2)7fycJceXcFNSPLTcjbxJqqceC0)EzD8lqYoEkzFpBgYMHSPLn)zRa2)7fCncbjqa4gBJ7Fhtav20Y(G0zrvh0ocoOG3EwjB6OKnJzZy23ZM(SJnBQoBJkazfiG5qqFfOQ4)7HoMSOjaJX6bv2mKnvNn2b8(QyexqWHNnv0RY1SmbC2mKnDrwZosztlBITQkWegjykfoSt20L99ylA2rw0u0yAZI5uKs03JujQIgmgRhuLRlAhYkazTIMyEyKGUHfGunm2W4DcWySEqLnTS5pBSaMx4aQG59ztlBDdlaPAySHX7ujGUTdo74PK9nztlB(ZwHKa57iFceiWJayogRhYMw2kKeCncbjqGa62o4SPlB(MnTSzmBfW(FVatyuGiw47KnTSzmB(ZwmpmsqqCVNkR3uqagJ1dQS5XlBfW(FVGG4EpvwVPGW3jBgYMw2mMn)zdymmhiW6rivf9QchOcdOFzq3IPGizZJx2kG9)EbwpcPQOxv4avya9ldFNSziBE8YgWyyoqG5Ix0urVQdqEWrw0eGXy9GkBgkA2rw0u0yAZI5uKs03VAjQIgmgRhuLRlAhYkazTIg)zJfW8chqfmVpBAzBubiRabmhc6Ravf)Fp0XKfnbymwpOYMw2kKeCncbjqGapcG5ySEiBAzRqsW1ieKabh9Vxwh)cKSJNs23ZMw2hKolQ6G2rWbf82ZkzthLSVx0SJSOPOH5yk0f6GxvKs03VIsufnymwpOkxx0oKvaYAfn(ZglG5foGkqqUFiBAzZy28NTcjbxJqqceiWJayogRhYMw2kKeiFh5tGab0TDWztx2rkB6Zoszt1zFCQ6g3vSdmQS5XlBfscKVJ8jqGa62o4SP6SVjC1SPlBXiUGeKvhQcQQwiBgYMw2IrCbjiRoufuvTq20LDKkA2rw0u0aUX24(3XeOiLOVhzkrv0GXy9GQCDr7qwbiRv0uijq(oYNabzpCTJB20YMXS5pB42)xhhqfmQG5yedxFOrQOx1bDbqYMhVSpiKxHUycmHrbIybcOB7GZMUSVFt2mu0SJSOPOjiU3tL1BkOiLOVh5krv0GXy9GQCDr7qwbiRv0y)VxG1Jqk)hlbcyhjBE8YwbS)3lWegfiIf(ofn7ilAkAoizrtrkrFpMvIQObJX6bv56I2HScqwROPa2)7fycJceXcFNIMDKfnfnwpcPQVp5YIuIo2Bkrv0GXy9GQCDr7qwbiRv0ua7)9cmHrbIyHVtrZoYIMIglqWaHRDClsj6yVxIQObJX6bv56I2HScqwROPa2)7fycJceXcFNIMDKfnfT3sawpcPksj6yJTevrdgJ1dQY1fTdzfGSwrtbS)3lWegfiIf(ofn7ilAkA2CaSqmF9yEFrkrhlFlrv0GXy9GQCDrZoYIMIMR5HJ59abxzrOPODiRaK1kAmMTcy)VxGjmkqel8DYMhVSzmB(Zwmpmsa4gBJ7FhtGamgRhuztl7dc5vOlMatyuGiwGa62o4SPl7iD1S5XlBX8WibGBSnU)DmbcWySEqLnTSzm7dc5vOlMaWn2g3)oMabcOB7GZo(SVIS5Xl7dc5vOlMaWn2g3)oMabcOB7GZMUSJ9MSPL9BD5ivcOB7GZMUSVIRMndzZq2mKnTSzmB(ZwbS)3lq(oYNabGBSnU)DmbuzZJx28NTcy)VxW1ieKabGBSnU)DmbuztlBfscUgHGei4O)9Y64xGKnDzFpBgkAJPdfnxZdhZ7bcUYIqtrkrhBKkrv0GXy9GQCDrZoYIMIMH5W0gaxjgvqK6brmFr7qwbiRv0ua7)9ceJkis9GiMVQa2)7fuOlMS5Xl736YrQeq32bND8zh7nfTX0HIMH5W0gaxjgvqK6brmFrkrh7vlrv0GXy9GQCDrZoYIMIMH5W0gaxjgvqK6brmFr7qwbiRv0ymB(Zwmpmsa4gBJ7FhtGamgRhuzZJx28NTyEyKa(Zka59DHamgRhuzZq20YwbS)3lWegfiIfiGUTdoB6Y((nzFRSJu2uD2WT)VooGkyubZXigU(qJurVQd6cGu0gthkAgMdtBaCLyubrQheX8fPeDSxrjQIgmgRhuLRlA2rw0u0mmhM2a4kXOcIupiI5lAhYkazTIgJzlMhgjaCJTX9VJjqagJ1dQSPLTyEyKa(Zka59DHamgRhuzZq20YwbS)3lWegfiIf(oztlBgZwHKGRriibca3yBC)7ycOYMhVSnQaKvGaMdb9vGQI)Vh6yYIMamgRhuztlBfscUgHGei4O)9Y64xGKnDzFpBgkAJPdfndZHPnaUsmQGi1dIy(IuIo2itjQIgmgRhuLRlA2rw0u0oxE8iHGM9uz9gwkAhYkazTIMUHfGunm2W4DQeq32bNnLSVjBAzZF2kG9)EbMWOarSW3jBAzZF2kG9)EbbX9EQSEtbHVt20YM9)EbDqhrUSIEv))SQQIaMooOqxmztlByaI7LzhF2rUBYMw2kKeiFh5tGab0TDWztx2rQObVhCK6y6qr7C5XJecA2tL1ByPiLOJnYvIQObJX6bv56IMDKfnfn)NWfqW1DWRArFC1DFsr7qwbiRv0ua7)9cmHrbIyHVtrBmDOO5)eUacUUdEvl6JRU7tksj6yJzLOkAWySEqvUUOzhzrtrZ)Xcb9XvxKxbt1X)1nxOODiRaK1kAkG9)EbMWOarSW3POnMou08FSqqFC1f5vWuD8FDZfksjA(EtjQIgmgRhuLRlA2rw0u0C9MAnbrWvDqzE)IMI2HScqwROPa2)7fycJceXcFNIg8EWrQJPdfnxVPwtqeCvhuM3VOPiLO579sufnymwpOkxx0SJSOPO56n1AcIGRSMYfkAhYkazTIMcy)VxGjmkqel8DkAW7bhPoMou0C9MAnbrWvwt5cfPenFJTevrZoYIMI2hd1vaDCrdgJ1dQY1fPifnfskrvI(EjQIgmgRhuLRlAiNIggKIMDKfnfnMgznwpu0yA(pu0CilISYLvcsmzrt20Yg7aEFvmIli4WZMk6v5AwMaoB6YMVztlBgZwHKGRriibceq32bND8zFqiVcDXeCncbjqq9jMSOjBE8Y2bTy0aQkRhafoB6Y(QzZqrJPrQJPdfnmxRt9C5XdvxJqqcuKs0XwIQObJX6bv56IgYPOHbPOzhzrtrJPrwJ1dfnMM)dfnhYIiRCzLGetw0KnTSXoG3xfJ4cco8SPIEvUMLjGZMUS5B20YMXSva7)9ccI79uz9MccFNS5XlBgZ2bTy0aQkRhafoB6Y(QztlB(Z2Ocqwbc4dmsf9QSEesfGXy9GkBgYMHIgtJuhthkAyUwN65YJhQKVJ8jqrkrZ3sufnymwpOkxx0qofnmifn7ilAkAmnYASEOOX08FOOPa2)7fycJceXcFNSPLnJzRa2)7fee37PY6nfe(ozZJx26gwas1WydJ3PsaDBhC20L9nzZq20YwHKa57iFceiGUTdoB6Yo2IgtJuhthkAyUwNk57iFcuKs0rQevrdgJ1dQY1fTdzfGSwrtmpmsa4gBJ7FhtGamgRhuztlB(Zg4gBJ7Fhtav20YwHKGRriibco6FVSo(fizhpLSVNnTSpiKxHUyca3yBC)7yceiGUTdo74Zo2SPLn2b8(QyexqWHNnv0RY1SmbC2uY(E20YMyRQcmHrcMsHd7KnDzFfztlBfscUgHGeiqaDBhC2uD23eUA2XNTyexqcYQdvbvvlu0SJSOPO5AecsGIuI(QLOkAWySEqvUUODiRaK1kAI5Hrca3yBC)7yceGXy9GkBAzZF2kKeCncbjqGapcG5ySEiBAzZy2hKolQ6G2rWzthLSpovDJ7k2bgv20Y(GqEf6IjaCJTX9VJjqGa62o4SJp77ztlBfscKVJ8jqGa62o4SP6SVjC1SJpBXiUGeKvhQcQQwiBgkA2rw0u0iFh5tGIuI(kkrv0GXy9GQCDr7Hi1b4wkrFVOzhzrtrZbH8vcGrFYbksj6itjQIgmgRhuLRlAhYkazTIgbEeaZXy9q20Y(G0zrvh0ocoOG3EwjB6OK99SPpB(MnvNnJzBubiRabmhc6Ravf)Fp0XKfnbymwpOYMw2heYRqxmbM2SyoHVt2mKnTSzmBh9Vxwh)cKSJNs23ZMhVSjGUTdo74PKTShUQYQdztlBSd49vXiUGGdpBQOxLRzzc4SPJs28nB6Z2Ocqwbcyoe0xbQk()EOJjlAcWySEqLndztlBgZM)SbUX24(3XeqLnpEztaDBhC2XtjBzpCvLvhYMQZo2SPLn2b8(QyexqWHNnv0RY1SmbC20rjB(Mn9zBubiRabmhc6Ravf)Fp0XKfnbymwpOYMHSPLn)zJXv2)7bQSPLnJzlgXfKGS6qvqv1czFRSjGUTdoBgYMUSJu20YMXS1nSaKQHXggVtLa62o4SPK9nzZJx28NTShU2XnBAzBubiRabmhc6Ravf)Fp0XKfnbymwpOYMHIMDKfnfnxJqqcuKs0rUsufnymwpOkxx0EisDaULs03lA2rw0u0CqiFLay0NCGIuIoMvIQObJX6bv56IMDKfnfnxJqqcu0oKvaYAfn(ZMPrwJ1dbmxRt9C5XdvxJqqcKnTSjWJayogRhYMw2hKolQ6G2rWbf82ZkzthLSVNn9zZ3SP6SzmBJkazfiG5qqFfOQ4)7HoMSOjaJX6bv20Y(GqEf6IjW0MfZj8DYMHSPLnJz7O)9Y64xGKD8uY(E284Lnb0TDWzhpLSL9WvvwDiBAzJDaVVkgXfeC4ztf9QCnltaNnDuYMVztF2gvaYkqaZHG(kqvX)3dDmzrtagJ1dQSziBAzZy28NnWn2g3)oMaQS5XlBcOB7GZoEkzl7HRQS6q2uD2XMnTSXoG3xfJ4cco8SPIEvUMLjGZMokzZ3SPpBJkazfiG5qqFfOQ4)7HoMSOjaJX6bv2mKnTS5pBmUY(FpqLnTSzmBXiUGeKvhQcQQwi7BLnb0TDWzZq20L99yZMw2mMTUHfGunm2W4DQeq32bNnLSVjBE8YM)SL9W1oUztlBJkazfiG5qqFfOQ4)7HoMSOjaJX6bv2mu0oxE8qvmIli4s03lsj673uIQObJX6bv56IMDKfnfTdz1XOPkGUdGLI2HScqwROHDaVVkgXfeC20LnFZMw2eq32bND8zhB20NnJzJDaVVkgXfeC20rj7RMndztl7dsNfvDq7i4SPJs2rQODU84HQyexqWLOVxKs03VxIQObJX6bv56I2HScqwROXF2mnYASEiG5ADQKVJ8jq20YMXSpiDwu1bTJGZMokzhPSPLnbEeaZXy9q284Ln)zl7HRDCZMw2mMTS6q20L99BYMhVSpiDwu1bTJGZMokzhB2mKndztlBgZ2r)7L1XVaj74PK99S5XlBcOB7GZoEkzl7HRQS6q20Yg7aEFvmIli4WZMk6v5AwMaoB6OKnFZM(SnQaKvGaMdb9vGQI)Vh6yYIMamgRhuzZq20YMXS5pBGBSnU)DmbuzZJx2eq32bND8uYw2dxvz1HSP6SJnBAzJDaVVkgXfeC4ztf9QCnltaNnDuYMVztF2gvaYkqaZHG(kqvX)3dDmzrtagJ1dQSziBAzlgXfKGS6qvqv1czFRSjGUTdoB6Yosfn7ilAkAKVJ8jqrkrFp2sufnymwpOkxx0SJSOPOr(oYNafTdzfGSwrJ)SzAK1y9qaZ16upxE8qL8DKpbYMw28NntJSgRhcyUwNk57iFcKnTSpiDwu1bTJGZMokzhPSPLnbEeaZXy9q20YMXSD0)EzD8lqYoEkzFpBE8YMa62o4SJNs2YE4QkRoKnTSXoG3xfJ4cco8SPIEvUMLjGZMokzZ3SPpBJkazfiG5qqFfOQ4)7HoMSOjaJX6bv2mKnTSzmB(Zg4gBJ7Fhtav284Lnb0TDWzhpLSL9WvvwDiBQo7yZMw2yhW7RIrCbbhE2urVkxZYeWzthLS5B20NTrfGSceWCiOVcuv8)9qhtw0eGXy9GkBgYMw2IrCbjiRoufuvTq23kBcOB7GZMUSJu20NnJz7GwmAavL1dGcNnDzhB2mKnvN9vu0oxE8qvmIli4s03lsj678TevrdgJ1dQY1fn7ilAkAhYQJrtvaDhalfTdzfGSwrd7aEFvmIli4SPl77ztlBSd49vXiUGGZo(SJu20YMa62o4SJp7yZMw2hKolQ6G2rWzthLSJur7C5XdvXiUGGlrFViLOVhPsufnymwpOkxx0oKvaYAfnSd49vXiUGGZMs23ZMw2hKolQ6G2rWzthLSzm7Jtv34UIDGrL9TY(E2mKnTSjWJayogRhYMw28NnWn2g3)oMaQSPLn)zRa2)7fee37PY6nfe(oztlBDdlaPAySHX7ujGUTdoBkzFt20YM)SnQaKvGGCXILQWbQCn7dcWySEqLnTSfJ4csqwDOkOQAHSVv2eq32bNnDzhPIMDKfnfTdz1XOPkGUdGLIuI((vlrv0GXy9GQCDr7qwbiRv0WoG3xfJ4ccoB6YMXSJmzFRSz)VxagMWG0dFNSziBAzFq6SOQdAhbNnDuYosztF2I5HrckaCasfletmxqpaJX6bv20YM)Sva7)9cmHrbIyHVt20YM)Sva7)9ccI79uz9MccFNSPLn)zBubiRab5IflvHdu5A2heGXy9GkBAzddqCVmOG3Ewj74PKDSxnB6ZMPrwJ1dbyaI7Lvc4ct9G0z3bufn7ilAkAhYQJrtvaDhalfPifPOXei4fnLOJ9MyV5MR4EKkAxyKzhxCrJpQBJQenFC0uv8HSZokoq2RUdIiz)qKS5ZagdZbW85SjWT)VeqLngPdzBFbPBcOY(WXgxahsQJ52bYow(q2xjAycebuzZNbUX24(3XeqfOQ5ZzlOS5ZkG9)EbQ6aWn2g3)oMak(C2mENBgcj1j18rDBuLO5JJMQIpKD2rXbYE1Dqej7hIKnF(OW85SjWT)VeqLngPdzBFbPBcOY(WXgxahsQJ52bY(oF5dzFLOHjqeqLnFg4gBJ7FhtavGQMpNTGYMpRa2)7fOQda3yBC)7ycO4ZzZ4DUziKuhZTdKDS8LpK9vIgMarav28zGBSnU)DmbubQA(C2ckB(Scy)VxGQoaCJTX9VJjGIpNnJXYndHK6KA(yDherav2rMSTJSOjB)IfCiPUO5qqV1dfTyK9THXggVJjlAYMQGC)qsDmYMJioy(qCX5UcNpB4G0JdV6FVjlAoe7jXHx9tCj1Xi7B77(Xs2Xgr2XEtS3KuNuhJSVso24cy(qsDmY(wzFBkfOYoMEpCLTGYwbp77LSTJSOjB)ILqsDmY(wztvaDetiBXiUGu3xiPogzFRSVnLcuzZhbdzZhlGooBgrFbVkiB0lBSaMx4WqiPogzFRSVs0WeicOYg4gBJ7FhtavGQoBbLTcjbQ6aWn2g3)oMaQqsDsDmYMpXnC(cOYMfEicK9bPZAs2SG7o4q2325aoco7bn3IJr0FFF22rw0GZgn(ldj1XiB7ilAWbhcCq6SMq55nmxj1XiB7ilAWbhcCq6SMqpL4SVRomIjlAsQJr22rw0Gdoe4G0znHEkX9qivsDmYwBmhmhKKnXwv2S)3duzJftWzZcpebY(G0znjBwWDhC22OY2Ha3YbjYoUzV4SvObcj1XiB7ilAWbhcCq6SMqpL4WJ5G5GKkwmbNuBhzrdo4qGdsN1e6PeN544VS6GwmAsQTJSObhCiWbPZAc9uIt3iCbQ6drQkWeor4qGdsN1KkgoOrHPC1i2hfITQkWegjykfoSdD3VAsTDKfn4GdboiDwtONsCybmVWjP2oYIgCWHahKoRj0tjUpgQRa6rmMoqXOcMJrmC9HgPIEvh0fajP2oYIgCWHahKoRj0tjohKSOjPoPogzZN4goFbuzdmbYLzlRoKTWbY2ocIK9IZ2yAR3y9qiPogztvaSaMx4K9(Y2bHXlRhYMXbLnZVFaIX6HSHb0xaN9ozFq6SMWqsTDKfnykCThUIyFu4hlG5foGkyEFsTDKfny6PehwaZlCsQTJSObtpL4yAK1y9qeJPduGbiUxwjGlm1dsNDhqfbtZ)bkWae3ldeWfg6DqlgnGQY6bqHP6itmpJXs1yhW7RCmSamKuBhzrdMEkXX0iRX6HigthOG3X1dvXiUGebtZ)bkyhW7RIrCbbhE2urVkxZYeWXhBsTDKfny6Pe3X8(QDKfnv)ILigthOGfW8chqfX(OGfW8chqfii3pKuBhzrdMEkXDmVVAhzrt1VyjIX0bkhfoI9rHr(fZdJe0nSaKQHXggVtagJ1dkE8uij4AecsGGShU2XLHKA7ilAW0tjUJ59v7ilAQ(flrmMoqrHKKA7ilAW0tjUJ59v7ilAQ(flrmMoqrTe4ij12rw0GPNsCg5ydufeHaJeX(OadqCVmOG3EwHok3Vk9mnYASEiadqCVSsaxyQhKo7oGkP2oYIgm9uIZihBGQZ3JHKA7ilAW0tjo)6YrW1ykFLRomssTDKfny6PehR5wrVQq2dx4K6K6yK9vIqEf6IbNuBhzrdoCuykFmuxb0JymDGIrfmhJy46dnsf9QoOlase7Jc)ybmVWbubZ7PPBybivdJnmENkb0TDWuUHgJheYRqxmbMWOarSab0TDWXhzLXdc5vOlMGG4EpvwVPGab0TDWunC7)RJdOcgMdtBaCLyubrQheX8mWq83VH(73q1WT)VooGkyyomTbWvIrfePEqeZtJFfW(FVatyuGiw47qJFfW(FVGG4EpvwVPGW3jP2oYIgC4OW0tjUJ59v7ilAQ(flrmMoqbWyyoaoI9rHFSaMx4aQG590uijq(oYNabzpCTJlnDdlaPAySHX7ujGUTdMYnj1XiB(4x2MsHZ2iq2FNiYgpRdKTWbYgnq2xScNS9OlaSKDurD7czZhbdzFbhyYwD5oUz)mSaKSfo2K9vgtYwbV9Ss2is2xSch0xY2MlZ(kJjHKA7ilAWHJctpL40ncxGQ(qKQcmHteNlpEOkgXfemL7rSpkeBvvGjmsWukC47qJrXiUGeKvhQcQQwi(dsNfvDq7i4GcE7zfQ(E4Q84Dq6SOQdAhbhuWBpRqhLJtv34UIDGrXqsDmYMp(L9GY2ukC2xSEF2QfY(Iv4St2chi7b4wYMV3GJi7pgYoY(D7YgnzZIW4SVyfoOVKTnxM9vgtcj12rw0GdhfMEkXPBeUav9HivfycNi2hfITQkWegjykfoSdD89MBrSvvbMWibtPWb1NyYIgAhKolQ6G2rWbf82Zk0r54u1nURyhyuj1Xi7ipmkqelBpYDpMp7dAuRSOX84SznmOYgnzF(ecms2yh4KuBhzrdoCuy6PehtJSgRhIymDGctyuGiwf)zfG8(Uq9Gg1klAIGP5)af(fZdJeWFwbiVVleGXy9GIhp(nQaKvGaMdb9vGQI)Vh6yYIMamgRhu84PqsW1ieKabh9Vxwh)ce6UtJrSd49vXiUGGdpBQOxLRzzc44VcE84)GqEf6IjW0MfZj8DyiP2oYIgC4OW0tjoMgznwpeXy6afMWOarS6SUCeSyEUas9Gg1klAIGP5)af(fZdJeM1LJGfZZfqcWySEqXJh)I5Hrca3yBC)7yceGXy9GIhVdc5vOlMaWn2g3)oMabcOB7GJ)Q3kwQwmpmsqbGdqQyHyI5c6bymwpOsQTJSObhokm9uIJPrwJ1drmMoqHPrwJ1drmMoqHjmkqeR(qJupOrTYIMiyA(pqHF42)xhhqfmQG5yedxFOrQOx1bDbq4XZOcqwbcyoe0xbQk()EOJjlAcWySEqXJNcy)VxGyubrQheX8vfW(FVGcDXWJ3bH8k0ftWWCyAdGReJkis9GiMpqaDBhC83VHgJheYRqxmbbX9EQSEtbbcOB7GJ)opEkG9)EbbX9EQSEtbHVddj12rw0GdhfMEkXXegfiIfX(OWpwaZlCavGGC)angzuHKa57iFceK9W1oU04xbS)3lWegfiIf(o0yAK1y9qGjmkqeRI)ScqEFxOEqJALfn0yAK1y9qGjmkqeRoRlhblMNlGupOrTYIgAmnYASEiWegfiIvFOrQh0Owzrdd849wxosLa62o44Pe7nmKuhJSJ82SyozFXkCYMpXn2nB6Zo61LJGfZZfq4dzhzBCV6F9SVYys22OYMpXn2nBcyQlZ(Hizpa3s2uvx5TlP2oYIgC4OW0tjoM2SyorSpkI5Hrca3yBC)7yceGXy9GIMyEyKWSUCeSyEUasagJ1dkAhKolQ6G2rW0r54u1nURyhyu0oiKxHUyca3yBC)7yceiGUTdo(7j1Xi7iVnlMt2xScNSJED5iyX8CbKSPp7OrzZN4g7YhYoY24E1)6zFLXKSTrLDKhgfiIL93jBg)JhW4S)4DCZoYJIjmKuBhzrdoCuy6PehtBwmNi2hfX8WiHzD5iyX8CbKamgRhu04xmpmsa4gBJ7FhtGamgRhu0oiDwu1bTJGPJYXPQBCxXoWOOXOcy)VxGjmkqel8D4XdWyyoqG5Ix0urVQdqEWrw0eGXy9GIHK6yKTgaz)(EF2hKUoms2OjBoI4G5dXfN7kC(SHdspoQIXegoiVsUvuxzCufK7hI7ILRnUBdJnmEhtw0CRBlMeZDlQcGbJC4esQTJSObhokm9uIJPrwJ1drmMoqbJRmTzXCQh0Owzrtemn)hOyubiRabmhc6Ravf)Fp0XKfnbymwpOOX4GMkgxz)VhOQIrCbbthL784HDaVVkgXfeC4ztf9QCnltatHVmqJrmUY(FpqvfJ4ccUASiMq1XgfOVhk3WJh2b8(QyexqWHNnv0RY1SmbmDuUcgsQTJSObhokm9uIZbH8vcGrFYbI4Hi1b4wOCpcGBHyvth9hHsKUAsTDKfn4WrHPNsCmTzXCIyFueZdJeWFwbiVVleGXy9GIg)ybmVWbubcY9d0oiKxHUycUgHGei8DOXitJSgRhcyCLPnlMt9Gg1klA4XJFJkazfiG5qqFfOQ4)7HoMSOjaJX6bfngvij4AecsGabEeaZXy9apEkG9)EbMWOarSW3HMcjbxJqqceC0)EzD8lqINYDgyGg)a3yBC)7ycOcUgHGeG2bPZIQoODeCqbV9ScDuyKX70hlvBubiRabmhc6Ravf)Fp0XKfnbymwpOyGQXoG3xfJ4cco8SPIEvUMLjGzGUiRrIgXwvfycJemLch2HU7XMuhJSJ82SyozFXkCYoY2WcqY(2WydVdFi7OrzJfW8cNSTrL9GY2oYYeYoY(2YM9)ErKnv57iFcK9GKS3jBc8iaMt2eBCHiYw9j74MDKhgfiIrFuxt)1iHpLnJ)XdyC2F8oUzh5rXegsQTJSObhokm9uIJPnlMte7JIyEyKGUHfGunm2W4DcWySEqrJFSaMx4aQG5900nSaKQHXggVtLa62o44PCdn(vijq(oYNabc8iaMJX6bAkKeCncbjqGa62oy64lngva7)9cmHrbIyHVdng5xmpmsqqCVNkR3uqagJ1dkE8ua7)9ccI79uz9MccFhgOXi)agdZbcSEesvrVQWbQWa6xg0TykicpEkG9)EbwpcPQOxv4avya9ldFhg4XdWyyoqG5Ix0urVQdqEWrw0eGXy9GIHK6yKTghtHUqh8QSFis2ACiOVcuzR9Fp0XKfnj12rw0GdhfMEkXH5yk0f6GxfX(OWpwaZlCavW8EAgvaYkqaZHG(kqvX)3dDmzrtagJ1dkAkKeCncbjqGapcG5ySEGMcjbxJqqceC0)EzD8lqINYDAhKolQ6G2rWbf82Zk0r5EsDmYMpXn2g3)oMazFbhyYEqs2ybmVWbuzBJkBwKWjBQY3r(eiBBuztvzecsGSncK93j7hIKThnUzdd67YjKuBhzrdoCuy6PehWn2g3)oMarSpk8JfW8chqfii3pqJr(vij4AecsGabEeaZXy9anfscKVJ8jqGa62oy6Ie9rIQpovDJ7k2bgfpEkKeiFh5tGab0TDWu9nHRsNyexqcYQdvbvvlWanXiUGeKvhQcQQwGUiLuBhzrdoCuy6PeNG4EpvwVPGi2hffscKVJ8jqq2dx74sJr(HB)FDCavWOcMJrmC9HgPIEvh0faHhVdc5vOlMatyuGiwGa62oy6UFddj12rw0GdhfMEkX5GKfnrSpkS)3lW6riL)JLabSJWJNcy)VxGjmkqel8DsQTJSObhokm9uIJ1JqQ67tUmI9rrbS)3lWegfiIf(oj12rw0GdhfMEkXXcemq4Ah3i2hffW(FVatyuGiw47KuBhzrdoCuy6Pe3BjaRhHurSpkkG9)EbMWOarSW3jP2oYIgC4OW0tjoBoawiMVEmVpI9rrbS)3lWegfiIf(oj12rw0GdhfMEkX9XqDfqpIX0bkUMhoM3deCLfHMi2hfgva7)9cmHrbIyHVdpEmYVyEyKaWn2g3)oMabymwpOODqiVcDXeycJceXceq32btxKUkpEI5Hrca3yBC)7yceGXy9GIgJheYRqxmbGBSnU)Dmbceq32bh)vWJ3bH8k0fta4gBJ7FhtGab0TDW0f7n0ERlhPsaDBhmDxXvzGbgOXi)a3yBC)7ycOcKVJ8japE8dCJTX9VJjGk4AecsaAkKeCncbjqWr)7L1XVaHU7mKuBhzrdoCuy6Pe3hd1va9igthOyyomTbWvIrfePEqeZhX(OOa2)7figvqK6brmFvbS)3lOqxm849wxosLa62o44J9MKA7ilAWHJctpL4(yOUcOhXy6afdZHPnaUsmQGi1dIy(i2hfg5xmpmsa4gBJ7FhtGamgRhu84XVyEyKa(Zka59DHamgRhumqtbS)3lWegfiIfiGUTdMU73CRir1WT)VooGkyubZXigU(qJurVQd6cGKuBhzrdoCuy6Pe3hd1va9igthOyyomTbWvIrfePEqeZhX(OWOyEyKaWn2g3)oMabymwpOOjMhgjG)ScqEFxiaJX6bfd0ua7)9cmHrbIyHVdngvij4AecsGaWn2g3)oMakE8mQaKvGaMdb9vGQI)Vh6yYIMamgRhu0uij4AecsGGJ(3lRJFbcD3ziP2oYIgC4OW0tjUpgQRa6raVhCK6y6aLZLhpsiOzpvwVHLi2hfDdlaPAySHX7ujGUTdMYn04xbS)3lWegfiIf(o04xbS)3liiU3tL1Bki8DOX(FVGoOJixwrVQ)FwvvrathhuOlgAWae3lJpYDdnfscKVJ8jqGa62oy6IusTDKfn4WrHPNsCFmuxb0JymDGI)t4ci46o4vTOpU6UpjI9rrbS)3lWegfiIf(oj12rw0GdhfMEkX9XqDfqpIX0bk(pwiOpU6I8kyQo(VU5crSpkkG9)EbMWOarSW3jP2oYIgC4OW0tjUpgQRa6raVhCK6y6afxVPwtqeCvhuM3VOjI9rrbS)3lWegfiIf(oj12rw0GdhfMEkX9XqDfqpc49GJuhthO46n1AcIGRSMYfIyFuua7)9cmHrbIyHVtsDmY(2bp77LSFM3ZAhUY(Hiz)XgRhYEfqhZhYMpcgYgnzFqiVcDXesQTJSObhokm9uI7JH6kGooPoPogzF7wcCKSvMU5czBSRFLfWj1XiB(0WegKE2MKDKOpBgVk9zFXkCY(2PXq2xzmjKnFSUoOwta)LzJMSJL(SfJ4ccoISVyfozh5HrbIyrKnIK9fRWj7OUMp6SrchGCXIHSVWwj7hIKngPdzddqCVmKuBhzrdoOwcCekWWegKEe7JYbPZIQoODemDuIe9I5HrckaCasfletmxqpaJX6bfngva7)9cmHrbIyHVdpEkG9)EbbX9EQSEtbHVdpEWae3ldk4TNvINsSxLEMgznwpeGbiUxwjGlm1dsNDhqXJh)mnYASEiG3X1dvXiUGWang5xmpmsa4gBJ7FhtGamgRhu84XVcy)VxGjmkqel8D4X7GqEf6IjaCJTX9VJjqGa62oy6ILHKA7ilAWb1sGJqpL4yAK1y9qeJPdu(yO(wVhirW08FGYbPZIQoODeCqbV9ScD35XdgG4EzqbV9Ss8uI9Q0Z0iRX6HamaX9YkbCHPEq6S7akE84NPrwJ1db8oUEOkgXfKK6yKnFuRWjB(0HdAh3SV2Bkahr2rwSjB0l7y6zzc4Snj7yPpBXiUGGJiBejB(ERirF2IrCbbN9fCGj7ipmkqel7fN93jP2oYIgCqTe4i0tjUNnv0RY1SmbCe7JctJSgRhcFmuFR3deAgvaYkqaoCq74wz9McWbymwpOOHDaVVkgXfeC4ztf9QCnltathLyPNrfW(FVatyuGiw47q1mENEgnQaKvGaC4G2XTY6nfGdeB4IYDgyGHK6yKDKfBYg9YoMEwMaoBtY(EmJ(SXID4cNn6LDm1vPGj7R9McWzJizBU2oyj7irF2mEv6Z(Iv4K9Td9z9q23oegyiBXiUGGdj12rw0GdQLahHEkX9SPIEvUMLjGJyFuyAK1y9q4JH6B9EGqJr2)7f4SkfmvwVPaCal2Hl6OCpMXJhJ87qwezLlReKyYIgAyhW7RIrCbbhE2urVkxZYeW0rjs0ZOrfGSceuOpRhQkegceB4IUyzGESaMx4aQab5(bgyiPogzhzXMSrVSJPNLjGZwqzBoo(lZ(2bMYFz2Xe0Irt27l7DSJSmHSrt22Cz2IrCbjBtYMVzlgXfeCiP2oYIgCqTe4i0tjUNnv0RY1SmbCeNlpEOkgXfemL7rSpkmnYASEi8Xq9TEpqOHDaVVkgXfeC4ztf9QCnltathf(MuBhzrdoOwcCe6PehRFhfEvqe7JctJSgRhcFmuFR3deAmY(FVaRFhfEvq47WJh)I5HrcmHbPxjFmNamgRhu043Ocqwbck0N1dvfcdbymwpOyiPogzhLXERi7VSEtGSfu2MJJ)YSVDGP8xMDmbTy0KTjzhB2IrCbbNuBhzrdoOwcCe6PeN(xwVjqeNlpEOkgXfemL7rSpkmnYASEi8Xq9TEpqOHDaVVkgXfeC4ztf9QCnltatj2KA7ilAWb1sGJqpL40)Y6nbIyFuyAK1y9q4JH6B9EGKuNuhJSVDMU5czJycKSLvhY2yx)klGtQJr2XCR(kztvzecsaC2Oj7bn3YHS6eJCz2IrCbbN9drYw4az7qwezLlZMGetw0K9(Y(Q0NnRhafoBJazBEcyQlZ(7KuBhzrdoOqcfMgznwpeXy6afmxRt9C5XdvxJqqcebtZ)bkoKfrw5YkbjMSOHg2b8(QyexqWHNnv0RY1SmbmD8LgJkKeCncbjqGa62o44piKxHUycUgHGeiO(etw0WJNdAXObuvwpakmDxLHK6yKDm3QVs2uLVJ8jaoB0K9GMB5qwDIrUmBXiUGGZ(HizlCGSDilISYLztqIjlAYEFzFv6ZM1dGcNTrGSnpbm1Lz)DsQTJSObhuiHEkXX0iRX6HigthOG5ADQNlpEOs(oYNarW08FGIdzrKvUSsqIjlAOHDaVVkgXfeC4ztf9QCnltathFPXOcy)VxqqCVNkR3uq47WJhJoOfJgqvz9aOW0DvA8BubiRab8bgPIEvwpcPcWySEqXadj1Xi7yUvFLSPkFh5taC27l7ipmkqeJ(OqCVNSV2BkiUiBdlaj7BdJnmENSxC2FNSTrL9fq2CmMq2XsF2y4GgfoBp8KSrt2chiBQY3r(ei7BhkQKA7ilAWbfsONsCmnYASEiIX0bkyUwNk57iFcebtZ)bkkG9)EbMWOarSW3HgJkG9)EbbX9EQSEtbHVdpE6gwas1WydJ3PsaDBhmD3WanfscKVJ8jqGa62oy6InPogzR5aN18ztvzecsGSTrLnv57iFcKngKVt2oKfrYwqzZN4gBJ7FhtGSpgwsQTJSObhuiHEkX5AecsGi2hfX8WibGBSnU)DmbcWySEqrJFGBSnU)Dmbu0uij4AecsGGJ(3lRJFbs8uUt7GqEf6IjaCJTX9VJjqGa62o44JLg2b8(QyexqWHNnv0RY1SmbmL70i2QQatyKGPu4Wo0Df0uij4AecsGab0TDWu9nHRgVyexqcYQdvbvvlKuBhzrdoOqc9uIJ8DKpbIyFueZdJeaUX24(3XeiaJX6bfn(vij4AecsGabEeaZXy9angpiDwu1bTJGPJYXPQBCxXoWOODqiVcDXeaUX24(3XeiqaDBhC83PPqsG8DKpbceq32bt13eUA8IrCbjiRoufuvTadj1XiBQkJqqcK93HlaCIiBZJrzlKfWzlOS)yi7vY2WzBzJDGZA(SDHbiMGiz)qKSfoq2EdlzFLXKSzHhIazBz)2zXCassTDKfn4Gcj0tjoheYxjag9jhiIhIuhGBHY9KA7ilAWbfsONsCUgHGeiI9rHapcG5ySEG2bPZIQoODeCqbV9ScDuUtpFPAgnQaKvGaMdb9vGQI)Vh6yYIMamgRhu0oiKxHUycmTzXCcFhgOXOJ(3lRJFbs8uUZJhb0TDWXtr2dxvz1bAyhW7RIrCbbhE2urVkxZYeW0rHV0BubiRabmhc6Ravf)Fp0XKfnbymwpOyGgJ8dCJTX9VJjGIhpcOB7GJNIShUQYQduDS0WoG3xfJ4cco8SPIEvUMLjGPJcFP3Ocqwbcyoe0xbQk()EOJjlAcWySEqXan(X4k7)9afngfJ4csqwDOkOQAHBraDBhmd0fjAmQBybivdJnmENkb0TDWuUHhp(L9W1oU0mQaKvGaMdb9vGQI)Vh6yYIMamgRhumKuBhzrdoOqc9uIZbH8vcGrFYbI4Hi1b4wOCpP2oYIgCqHe6PeNRriibI4C5XdvXiUGGPCpI9rHFMgznwpeWCTo1ZLhpuDncbjanc8iaMJX6bAhKolQ6G2rWbf82Zk0r5o98LQz0Ocqwbcyoe0xbQk()EOJjlAcWySEqr7GqEf6IjW0MfZj8DyGgJo6FVSo(fiXt5opEeq32bhpfzpCvLvhOHDaVVkgXfeC4ztf9QCnltathf(sVrfGSceWCiOVcuv8)9qhtw0eGXy9GIbAmYpWn2g3)oMakE8iGUTdoEkYE4QkRoq1Xsd7aEFvmIli4WZMk6v5AwMaMok8LEJkazfiG5qqFfOQ4)7HoMSOjaJX6bfd04hJRS)3du0yumIlibz1HQGQQfUfb0TDWmq39yPXOUHfGunm2W4DQeq32bt5gE84x2dx74sZOcqwbcyoe0xbQk()EOJjlAcWySEqXqsDmY(kjRognzhfO7ayjB0KT(3lRJhYwmIli4Snj7irF2xzmj7l4at2K)m74Mn6lzVt2XEl(IZMrwddQSrt2IrCbj7d6pcdzJMST5YSfJ4cssTDKfn4Gcj0tjUdz1XOPkGUdGLioxE8qvmIliyk3JyFuWoG3xfJ4ccMo(sJa62o44JLEgXoG3xfJ4ccMokxLbAhKolQ6G2rW0rjsj1Xi7yAaCY(7Knv57iFcKTjzhj6ZgnzBEF2IrCbbNnJxWbMS9lZDCZ2Jg3SHb9D5KTnQShKKnEmhmhKWqsTDKfn4Gcj0tjoY3r(eiI9rHFMgznwpeWCTovY3r(eGgJhKolQ6G2rW0rjs0iWJayogRh4XJFzpCTJlngLvhO7(n84Dq6SOQdAhbthLyzGbAm6O)9Y64xGepL784raDBhC8uK9WvvwDGg2b8(QyexqWHNnv0RY1SmbmDu4l9gvaYkqaZHG(kqvX)3dDmzrtagJ1dkgOXi)a3yBC)7ycO4XJa62o44Pi7HRQS6avhlnSd49vXiUGGdpBQOxLRzzcy6OWx6nQaKvGaMdb9vGQI)Vh6yYIMamgRhumqtmIlibz1HQGQQfUfb0TDW0fPKA7ilAWbfsONsCKVJ8jqeNlpEOkgXfemL7rSpk8Z0iRX6HaMR1PEU84Hk57iFcqJFMgznwpeWCTovY3r(eG2bPZIQoODemDuIenc8iaMJX6bAm6O)9Y64xGepL784raDBhC8uK9WvvwDGg2b8(QyexqWHNnv0RY1SmbmDu4l9gvaYkqaZHG(kqvX)3dDmzrtagJ1dkgOXi)a3yBC)7ycO4XJa62o44Pi7HRQS6avhlnSd49vXiUGGdpBQOxLRzzcy6OWx6nQaKvGaMdb9vGQI)Vh6yYIMamgRhumqtmIlibz1HQGQQfUfb0TDW0fj6z0bTy0aQkRhafMUyzGQVIK6yK9vswDmAYokq3bWs2Oj773IVzR)9Y64HSfJ4ccoBtYos0N9vgtY(coWKn5pZoUzJ(s27KDS4Srt22Cz2IrCbjP2oYIgCqHe6Pe3HS6y0ufq3bWseNlpEOkgXfemL7rSpkyhW7RIrCbbt3DAyhW7RIrCbbhFKOraDBhC8Xs7G0zrvh0ocMokrkPogzFLKvhJMSJc0DaSKnAYwlQS3x27KTJnkqFpzBJk7vY(I17ZwHY2dyC2kt3CHSfo2KnFAycdspB1hYwqzh11XfzFBXfLetNuBhzrdoOqc9uI7qwDmAQcO7ayjI9rb7aEFvmIliyk3PDq6SOQdAhbthfgpovDJ7k2bg1TUZanc8iaMJX6bA8dCJTX9VJjGIg)kG9)EbbX9EQSEtbHVdnDdlaPAySHX7ujGUTdMYn043OcqwbcYflwQchOY1SpiaJX6bfnXiUGeKvhQcQQw4weq32btxKsQJr2xPHLSVsYQJrt2rb6oawYgnzFBi(u27GfWuzJEzZNgMWG0Z2KSJm0NTyexqWzFbhyYoYdJceXIlQRZEXzpij7VtsTDKfn4Gcj0tjUdz1XOPkGUdGLi2hfSd49vXiUGGPJXiZTy)VxagMWG0dFhgODq6SOQdAhbthLirVyEyKGcahGuXcXeZf0dWySEqrJFfW(FVatyuGiw47qJFfW(FVGG4EpvwVPGW3Hg)gvaYkqqUyXsv4avUM9bbymwpOObdqCVmOG3EwjEkXEv6zAK1y9qagG4EzLaUWupiD2DavsDsDmYMpHXWCaCsTDKfn4aGXWCamLdAoWietav95nDiI9rbgG4EzqwDOkOQUXnD3PXVcy)VxGjmkqel8DOXi)kKeoO5aJqmbu1N30Hk7NmbzpCTJln(TJSOjCqZbgHycOQpVPdHDQp)6Yr4X799(kboCmIluLvhI39Oc6g3mKuhJSVn)f2L4S)yi7R9iKk7lwHt2rEyuGiw2FNq2XurEv2pejB(e3yBC)7yceYMpcgY(Iv4KDuxN93jBw4Hiq2w2VDwmhGKTHZ2Jg3SnC2RKn5p4SFis23VbNT6t2Xn7ipmkqelKuBhzrdoaymmhatpL4y9iKQIEvHduHb0VmI9rrbS)3lWegfiIf(o0ye4gBJ7FhtavW1ieKa84Pa2)7fee37PY6nfe(o0oiDwu1bTJGdk4TNvINYDE8ua7)9cmHrbIybcOB7GJNY9ByGhV36YrQeq32bhpL73KuhJSVnraDhjBbLT5x3jBQQVruRnzFXkCYoYdJceXY2Wz7rJB2go7vY(c0WNLSja(7LS3jBpcVJB2w2VV3FlMM)dzFmSKnIjqYw4aztaDBNDCZw9jMSOjB0lBHdK9BD5ij12rw0GdagdZbW0tjo3VruRnv0RAubiiHte7JYbH8k0ftGjmkqelqaDBhC88LhpfW(FVatyuGiw47WJ3BD5ivcOB7GJNV3KuBhzrdoaymmhatpL4C)grT2urVQrfGGeorSpkppcryKX36YrQeq32bFl(EddX8heYRqxmmq3ZJqegz8TUCKkb0TDW3IV3CRdc5vOlMatyuGiwGa62oygI5piKxHUyyiP2oYIgCaWyyoaMEkX9qNpguvJkazfOYcMEe7Jc2b8(QyexqWHNnv0RY1SmbmDuILhpITQkWegjykfoSdDxXn0GbiUxgFK5gE8ERlhPsaDBhC83VjP2oYIgCaWyyoaMEkX58j77YDCRSEdlrSpkyhW7RIrCbbhE2urVkxZYeW0rjwE8i2QQatyKGPu4Wo0Df3WJ3BD5ivcOB7GJ)(nj12rw0GdagdZbW0tjoHdu)dl6pQ6droqe7Jc7)9ce4WLhW46droq47WJh7)9ce4WLhW46droq9G(JaKawSdxXF)MKA7ilAWbaJH5ay6PehzDC8qDNk2XoqsTDKfn4aGXWCam9uI7ceXRyc7ujagn2CGKA7ilAWbaJH5ay6PeNoOJixwrVQ)FwvvrathhX(OadqCVm(REdn(piKxHUycmHrbIyHVtsDmYoMkYRYMQaMZoUzhzXB6ao7hIKnWnC(cKnXgxiBejBUwVpB2)7HJi79LTdcJxwpeY(28xyxIZwixMTGY2fKSfoq2E0fawY(GqEf6IjBwddQSrt2gtB9gRhYggqFbCiP2oYIgCaWyyoaMEkXraZzh36ZB6aoIZLhpufJ4ccMY9i2hfXiUGeKvhQcQQwi(7HRYJhJmkgXfKahW8cNGZrOlYDdpEIrCbjWbmVWj4CK4Pe7nmqJr7iltOcdOVaMYDE8eJ4csqwDOkOQAb6InMXad84XOyexqcYQdvbvDosn2BOJV3qJr7iltOcdOVaMYDE8eJ4csqwDOkOQAb6IuKyGHK6K6yKTMaMx4aQSVTJSObNuhJSJED5GfZZfqYgnzFpk(q2AJ5G5GKSPkFh5tGKA7ilAWbSaMx4akkKVJ8jqe7JIyEyKWSUCeSyEUasagJ1dkAhKolQ6G2rW0rjs0eJ4csqwDOkOQAHBraDBhmDxrsDmYw7Zka59DHSPpBnoe0xbQS1(Vh6yYIg(q28Pb)jq2xaz)Xq2ObY21JynF2ckBZXXFz2uvgHGeiBbLTWbYw32jBXiUGK9(YELSxC2dsYgpMdMdsY(sqIiBmkBZ7ZgjCas262ozlgXfKSn21VYc4SDiO3kHKA7ilAWbSaMx4ak6PeNdc5ReaJ(KdeXdrQdWTq5EsTDKfn4awaZlCaf9uIZ1ieKarSpkgvaYkqaZHG(kqvX)3dDmzrtagJ1dkAS)3lG)ScqEFxi8DOX(FVa(Zka59DHab0TDWXFpWxA8JXv2)7bQK6yKT2NvaY77c8HSVnhh)LzJiztvGhbWCY(Iv4Kn7)9av2uvgHGeaNuBhzrdoGfW8chqrpL4CqiFLay0NCGiEisDaUfk3tQTJSObhWcyEHdOONsCUgHGeiIZLhpufJ4ccMY9i2hfX8Wib8NvaY77cbymwpOOXib0TDWXFpwE8C0)EzD8lqINYDgOjgXfKGS6qvqv1c3Ia62oy6InPogzR9zfG8(Uq20NTghc6Rav2A)3dDmzrt27KTwu8HSVnhh)LzdgXFz2uLVJ8jq2chtY(I17ZMfYMapcG5aQSFis2o2Oa99KuBhzrdoGfW8chqrpL4iFh5tGi2hfX8Wib8NvaY77cbymwpOOzubiRabmhc6Ravf)Fp0XKfnbymwpOOXVcjbY3r(eii7HRDCPX0iRX6HaEhxpufJ4cssDmYw7Zka59DHSViUS14qqFfOYw7)EOJjlA4dztvaZXXFz2pejBw08XzFLXKSTrfhIKnWTaJcuzJhZbZbjzR(etw0esQTJSObhWcyEHdOONsCoiKVsam6toqepePoa3cL7j12rw0GdybmVWbu0tjoxJqqceX5YJhQIrCbbt5Ee7JIyEyKa(Zka59DHamgRhu0mQaKvGaMdb9vGQI)Vh6yYIMamgRhu0y0oYYeQWa6lGP7opE8lMhgjaCJTX9VJjqagJ1dkgOjgXfKGS6qvqv1c0raDBhmngjGUTdo(7roE84hJRS)3dumKuhJS1(ScqEFxiB6ZMpXn2nB0K99O4dztvGhbWCYMQYieKazBs2chiByuzJEzJfW8cNSfu2UGKTUXD2QpXKfnzZcpebYMpXn2g3)oMaj12rw0GdybmVWbu0tjoheYxjag9jhiIhIuhGBHY9KA7ilAWbSaMx4ak6PeNRriibIyFueZdJeWFwbiVVleGXy9GIMyEyKaWn2g3)oMabymwpOOzhzzcvya9fWuUtJ9)Eb8NvaY77cbcOB7GJ)EGVfnSdCkrh7vJzfPiLca]] )

end