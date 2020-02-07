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
            value = -3,
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
        -- Hm, maybe this should be current pmultiplier, not pmultiplier on current application.
        return persistent_multiplier

        --[[if not this_action then return false end
        local aura = this_action == "kidney_shot" and "internal_bleeding" or this_action
        return debuff[ aura ].pmultiplier]]
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
                local up = cast + 3 > query_time

                local vr = buff.vendetta_regen

                if up then
                    vr.count = 1
                    vr.expires = cast + 15
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

            usable = function () return stealthed.all or buff.subterfuge.up end,
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

            usable = function () return boss and group end,

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


    spec:RegisterPack( "Assassination", 20200206.2, [[dafm3bqiQipsiLlPQKInHs9jufsYOOcofQsRcvr9kKKzrf6wOkyxc(LOIHPQuhdfzzIQ6zurzAcP6Aib2MQsY3OIQACurvoNQsQwhQI4DOkKW8uv4EQQ2hkQ)PQe0brcQfQQOhsfvmrvLOUiQI0gvvsPpIQq1irviPojvujRej6LQkbMjQcPUjvuP2Pq0qvvISuKG8uuzQcjxfvHITIQq8vufs0EPQ)kYGv5Wuwms9yfMmHld2SI(SOmAuYPvA1Oku61iPMnr3wO2Tu)gYWPshxvj0Yr8COMoPRRkBhf(UOsJxiCErvwpsO5JQA)s2ZKpkpNWuWhz(FN)3FN)3Fvi)8DMZIUZ8CAEUGNZ1guBzGNRTyWZrHXydJ320f1EoxlpjYe(O8Cy0JmaphlvDX8KCYjBvwp6WafNdEJFstxupi2uZbVXJC8C0VvQoxTN2Zjmf8rM)35)935)9xfYpFNLF(Eo7PSqeph3g7C8CSwHaApTNta4HNlA1rHXydJ320f11rHqzpOOmA1XsvxmpjNCYwL1JomqX5G34N00f1dIn1CWB8iNIYOv3xlqtEgjV6(khRl)VZ)7IYIYOvNZHL1zaMNuugT64H6OWcbiQ7lyhuxNIQtat7j16SHUOUo5I1qrz0QJhQJcbXigqDQrYanTZqrz0QJhQJcleGOoEmyOoNlfIX15a6P4va1HM1HvWKklEdEo5IvSpkphwbtQSaHpkFKm5JYZbTrlbH)tp3GSkqwZZnqX0OKlABfxhZ)1f96yxNd1PMeAn0BglfRMKAGeG2OLGOo(8Rtnj0Aa)OvGmFzqaAJwcI6yxNd1PMeAnarGTo7TTPqaAJwcI6yx3aHKcuUDaIaBD2BBtHabITTX19XFD5xhF(15uD6oOE7S64To21XWiRrlHaE7mjKuJKbAD8wh76uJKbAq3yiPOKyH64H6iqSTnUoMR7R8C2qxu75ipx9raV6JmFFuEoOnAji8F65MisQHiuFKm55SHUO2Z5IqYebWOhzaE1hPZ8r55G2OLGW)PNBqwfiR55mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XUo63CgWpAfiZxgeEU1XUo63CgWpAfiZxgeiqSTnUUpQJPGZQJDDovhgNOFZji8C2qxu75YmcbPGx9rgDFuEoOnAji8F65MisQHiuFKm55SHUO2Z5IqYebWOhzaE1hjf4JYZbTrlbH)tpNn0f1EUmJqqk45gKvbYAEo1KqRb8JwbY8LbbOnAjiQJDDouhbITTX19rDmLFD85xNB8tQRRCbsDF8xht1XBDSRtnsgObDJHKIsIfQJhQJaX2246yUU89CJ8gsiPgjduSpsM8QpYVYhLNdAJwcc)NEUbzvGSMNtnj0Aa)OvGmFzqaAJwcI6yxNrrGSkeWSiONaej8BordtxuhG2OLGOo215uDcKgipx9rGGUdQ3oRo21XWiRrlHaE7mjKuJKbQNZg6IAph55Qpc4vFKoFFuEoOnAji8F65MisQHiuFKm55SHUO2Z5IqYebWOhzaE1hPZZhLNdAJwcc)NEoBOlQ9CzgHGuWZniRcK18CQjHwd4hTcK5ldcqB0squh76mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XUo1izGg0ngskkjwOoMRJaX2246yxNd1rGyBBCDFuhtoV64ZVoNQdJt0V5ee1XRNBK3qcj1izGI9rYKx9r(19r55G2OLGW)PNBIiPgIq9rYKNZg6IApNlcjteaJEKb4vFKm9Tpkph0gTee(p9CdYQaznpNAsO1a(rRaz(YGa0gTee1XUo1KqRbicS1zVTnfcqB0squh76giKuGYTdqeyRZEBBkeiqSTnUUpQJP6yxNlbyKYgIatbYZvFeOo21jqAG8C1hbcei22gxhZ1rb1rvDrVoEUUHBk2IiHDHw45SHUO2ZLzecsbV6vphGXqpaSpkFKm5JYZbTrlbH)tp3GSkqwZZbnqYYlOBmKuuk2IOoMRJP6yxNt1ja63CgyaTau1cp36yxNd15uDcKggOEaTsmfePP0IHe9J0bDhuVDwDSRZP6SHUOomq9aALykistPfdHTtt5MXsRJp)6MpPmrGblJKbjDJH6(OUSHieBruhVEoBOlQ9CdupGwjMcI0uAXGx9rMVpkph0gTee(p9CdYQaznpNaOFZzGb0cqvl8CRJDDouNt1PMeAnOOi2rIwAciaTrlbrD85xNaOFZzqrrSJeT0eq45wh76gOyAuYfTTIdcyUJvR7J)6yQo(8Rta0V5mWaAbOQfiqSTnUUp(RJPVRJ364ZVoDJHKIsIfQ7J)6y6BpNn0f1EoAjcjsOzszbjOH488QpsN5JYZbTrlbH)tp3GSkqwZZnqiPaLBhyaTau1cei22gx3h15S64ZVobq)MZadOfGQw45whF(1Pgjd0GUXqsrjXc19rDo7BpNn0f1EUSNreR1j0mzueiiLLx9rgDFuEoOnAji8F65gKvbYAEUPeHi15qDouNAKmqd6gdjfLeluhpuNZ(UoER7RPoBOlQtdeskq521XBDmx3uIqK6COohQtnsgObDJHKIsIfQJhQZzFxhpu3aHKcuUDGb0cqvlqGyBBCD8w3xtD2qxuNgiKuGYTRJxpNn0f1EUSNreR1j0mzueiiLLx9rsb(O8CqB0sq4)0ZniRcK18CyxqktQrYafhMwNqZe19YaW1X8FD5xhF(1rSvKagqRbtiWHTRJ56(QVRJDDqdKS8Q7J6C(F75SHUO2ZnrJhgejJIazvirdwSx9r(v(O8CqB0sq4)0ZniRcK18CyxqktQrYafhMwNqZe19YaW1X8FD5xhF(1rSvKagqRbtiWHTRJ56(QV9C2qxu75CFKDM32zjAPHvV6J057JYZbTrlbH)tp3GSkqwZZr)MZabgulbmonrKbeEU1XNFD0V5mqGb1saJttezaPb61kqcy1gux3h1X03EoBOlQ9Ckli9AA0RfPjImaV6J055JYZzdDrTNJSUUsiTDc7AdWZbTrlbH)tV6J8R7JYZzdDrTNlxerkyaBNiag1wpaph0gTee(p9QpsM(2hLNdAJwcc)NEUbzvGSMNdAGKLxDFuhf8DDSRZP6giKuGYTdmGwaQAHNRNZg6IApxmeJi5LqZK8nwrsqalg7vFKmXKpkph0gTee(p9CdYQaznpNAKmqdSatQScUdToMRZ59DD85xNAKmqdSatQScUdTUp(Rl)VRJp)6uJKbAq3yiPOK7qt5)DDmxNZ(2ZzdDrTNJaM72zPP0IbSx9QNtat7jvFu(izYhLNdAJwcc)NEUbzvGSMNZP6WkysLficMu65SHUO2Zr9oO2R(iZ3hLNZg6IAphwbtQS8CqB0sq4)0R(iDMpkph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45Ggiz5fiqg01rvDUOfJAqKOLaiW1XZ158R7RPohQl)6456WUGuMyzyfQJxphdJKAlg8CqdKS8seid60aftVni8QpYO7JYZbTrlbH)tphY1ZHb1ZzdDrTNJHrwJwcEogM8bEoSliLj1izGIdtRtOzI6Eza46(OU89CmmsQTyWZH3otcj1izG6vFKuGpkph0gTee(p9CdYQaznphwbtQSarGGYEGNZg6IAp3WKYKn0f1j5IvpNCXAQTyWZHvWKklq4vFKFLpkph0gTee(p9CdYQaznpNd15uDQjHwdXgwbsYWydJ3oaTrlbrD85xNaPHmJqqke0Dq92z1XRNZg6IAp3WKYKn0f1j5IvpNCXAQTyWZneyV6J057JYZbTrlbH)tpNn0f1EUHjLjBOlQtYfREo5I1uBXGNtGuV6J055JYZbTrlbH)tpNn0f1EUHjLjBOlQtYfREo5I1uBXGNtSeyOE1h5x3hLNdAJwcc)NEUbzvGSMNdAGKLxqaZDSADm)xhtuqDuvhdJSgTecqdKS8seid60aftVni8C2qxu75mYWAiPicbA1R(iz6BFuEoBOlQ9CgzynKCFsm45G2OLGW)Px9rYet(O8C2qxu75KBglfN4X(ezXqREoOnAji8F6vFKmLVpkpNn0f1EoAllHMjLSdQXEoOnAji8F6vFKm5mFuEoOnAji8F65gKvbYAEo4l(wxxqeGbl02zjgOvuhF(1bFX366cIamyH2olXaTIeILNZg6IApNauyOlQ9Qx9CUeyGIPn1hLpsM8r55SHUO2ZzUUY8sUOfJAph0gTee(p9QpY89r55G2OLGW)PNZg6IApxSrOgePjIKeGPS8CdYQaznphXwrcyaTgmHah2UoMRJjkWZ5sGbkM20eggOwG9CuGx9r6mFuEoBOlQ9CyfmPYYZbTrlbH)tV6Jm6(O8CqB0sq4)0Z1wm45mkIzzedNMOwtOzYfLlq8C2qxu75mkIzzedNMOwtOzYfLlq8QpskWhLNZg6IApNlsxu75G2OLGW)Px9QNtSeyO(O8rYKpkph0gTee(p9CdYQaznp3aftJsUOTvCDm)xx0RJQ6utcTgea4cKewjMAzqCaAJwcI6yxNd1ja63CgyaTau1cp364ZVobq)MZGIIyhjAPjGWZTo(8RdAGKLxqaZDSADF8xNd1bndOrXjxesMeWChRwhZFH15qD5tb1rvDmmYA0sianqYYlrGmOtdum92GOoERJ364ZVoNQJHrwJwcb82zsiPgjd064To215qDovNAsO1aeb26S32McbOnAjiQJp)6giKuGYTdqeyRZEBBkeiqSTnUoMRl)641ZzdDrTNdAgqJI9QpY89r55G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(ap3aftJsUOTvCqaZDSADmxht1XNFDqdKS8ccyUJvR7J)6YNcQJQ6yyK1OLqaAGKLxIazqNgOy6TbrD85xNt1XWiRrlHaE7mjKuJKbQNJHrsTfdEUhgsZvkbIx9r6mFuEoOnAji8F65gKvbYAEoggznAjeEyinxPei1XUoJIazviadwOTZs0sta4a0gTee1XUoSliLj1izGIdtRtOzI6Eza46y(VU89C2qxu75MwNqZe19YaWE1hz09r55G2OLGW)PNBqwfiR55yyK1OLq4HH0CLsGuh76COo63CgyTcb0jAPjaCaR2G66y(VoM(61XNFDouNt15swez18seKA6I66yxh2fKYKAKmqXHP1j0mrDVmaCDm)xx0RJQ6COoJIazviiqpAjKeimeiwtDDmxx(1XBDuvhwbtQSarGGYEqD8whVEoBOlQ9CtRtOzI6EzayV6JKc8r55G2OLGW)PNZg6IAp306eAMOUxga2ZniRcK18CmmYA0si8WqAUsjqQJDDyxqktQrYafhMwNqZe19YaW1X8FDoZZnYBiHKAKmqX(izYR(i)kFuEoOnAji8F65gKvbYAEoggznAjeEyinxPei1XUohQJ(nNbA52c8kGWZTo(8RZP6utcTgyankorEywbOnAjiQJDDovNrrGSkeeOhTescegcqB0squhVEoBOlQ9C0YTf4vaE1hPZ3hLNdAJwcc)NEoBOlQ9CXpDLMcEUbzvGSMNJHrwJwcHhgsZvkbsDSRd7cszsnsgO4W06eAMOUxgaUU)6Y3ZnYBiHKAKmqX(izYR(iDE(O8CqB0sq4)0ZniRcK18CmmYA0si8WqAUsjq8C2qxu75IF6knf8Qx9Cdb2hLpsM8r55G2OLGW)PNZg6IApNrrmlJy40e1AcntUOCbINBqwfiR55CQoScMuzbIGjL1XUUydRajzySHXBNiqSTnUU)6(Uo215qDdeskq52bgqlavTabITTX19XxyDdeskq52bffXos0stabceBBJRJ36(OoM(UoQQJPVRJNRd(IV11febdZIH1aormkIiPbIyY6yxNt1ja63CgyaTau1cp36yxNt1ja63Cguue7irlnbeEUEU2IbpNrrmlJy40e1AcntUOCbIx9rMVpkph0gTee(p9CdYQaznpNt1HvWKklqemPSo21jqAG8C1hbc6oOE7S6yxxSHvGKmm2W4Ttei22gx3FDF75SHUO2ZnmPmzdDrDsUy1ZjxSMAlg8Cagd9aWE1hPZ8r55G2OLGW)PNZg6IApxSrOgePjIKeGPS8CdYQaznphXwrcyaTgmHahEU1XUohQtnsgObDJHKIsIfQ7J6gOyAuYfTTIdcyUJvRJNRJPafuhF(1nqX0OKlABfheWChRwhZ)1nCtXwejSl0I641ZnYBiHKAKmqX(izYR(iJUpkph0gTee(p9CdYQaznphXwrcyaTgmHah2UoMRZzFxhpuhXwrcyaTgmHahepIPlQRJDDdumnk5I2wXbbm3XQ1X8FDd3uSfrc7cTWZzdDrTNl2iudI0erscWuwE1hjf4JYZbTrlbH)tphY1ZHb1ZzdDrTNJHrwJwcEogM8bEoNQtnj0Aa)OvGmFzqaAJwcI64ZVoNQZOiqwfcywe0taIe(nNOHPlQdqB0squhF(1jqAiZieKcb34Nuxx5cK6yUoMQJDDouh2fKYKAKmqXHP1j0mrDVmaCDFu3xvhF(15uDdeskq52bgwVywHNBD865yyKuBXGNJb0cqvlHF0kqMVminqTy1f1E1h5x5JYZbTrlbH)tphY1ZHb1ZzdDrTNJHrwJwcEogM8bEoNQtnj0AO3mwkwnj1ajaTrlbrD85xNt1PMeAnarGTo7TTPqaAJwcI64ZVUbcjfOC7aeb26S32McbceBBJR7J6OG64H6YVoEUo1KqRbbaUajHvIPwgehG2OLGWZXWiP2IbphdOfGQwQ3mwkwnj1ajnqTy1f1E1hPZ3hLNdAJwcc)NEoKRNddQNZg6IAphdJSgTe8Cmm5d8Covh8fFRRlicgfXSmIHttuRj0m5IYfi1XNFDgfbYQqaZIGEcqKWV5enmDrDaAJwcI64ZVobq)MZaXOiIKgiIjtcG(nNbbk3Uo(8RBGqsbk3oyywmSgWjIrrejnqetgiqSTnUUpQJPVRJDDou3aHKcuUDqrrSJeT0eqGaX2246(OoMQJp)6ea9BodkkIDKOLMacp3641ZXWiP2IbphdOfGQwAIAnnqTy1f1E1hPZZhLNdAJwcc)NEUbzvGSMNZP6WkysLficeu2dQJDDcKgipx9rGGUdQ3oRo215uDcG(nNbgqlavTWZTo21XWiRrlHadOfGQwc)OvGmFzqAGAXQlQRJDDmmYA0siWaAbOQL6nJLIvtsnqsdulwDrDDSRJHrwJwcbgqlavT0e1AAGAXQlQ9C2qxu75yaTau18QpYVUpkph0gTee(p9CdYQaznpNAsO1aeb26S32McbOnAjiQJDDouNAsO1qVzSuSAsQbsaAJwcI64ZVo1KqRb8JwbY8LbbOnAjiQJDDmmYA0siG3otcj1izGwhV1XUUbkMgLCrBR46y(VUHBk2IiHDHwuh76giKuGYTdqeyRZEBBkeiqSTnUUpQJP6yxNd15uDQjHwd4hTcK5ldcqB0squhF(15uDgfbYQqaZIGEcqKWV5enmDrDaAJwcI64ZVobsdzgHGui4g)K66kxGu3h)1XuD865SHUO2ZXW6fZYR(iz6BFuEoOnAji8F65gKvbYAEo1KqRHEZyPy1KudKa0gTee1XUoNQtnj0AaIaBD2BBtHa0gTee1XUUbkMgLCrBR46y(VUHBk2IiHDHwuh76ea9BodmGwaQAHNRNZg6IAphdRxmlV6JKjM8r55G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(apNrrGSkeWSiONaej8BordtxuhG2OLGOo215qDnQtyCI(nNGiPgjduCDm)xht1XNFDyxqktQrYafhMwNqZe19YaW19xNZQJ36yxNd1HXj63CcIKAKmqXjJgXasUwlG4Du3FDFxhF(1HDbPmPgjduCyADcntu3ldaxhZ)19v1XRNJHrsTfdEomoXW6fZknqTy1f1E1hjt57JYZbTrlbH)tpNn0f1EoxesMiag9idWZbrOelzXOxREUOtbEUjIKAic1hjtE1hjtoZhLNdAJwcc)NEUbzvGSMNtnj0Aa)OvGmFzqaAJwcI6yxNt1HvWKklqeiOShuh76giKuGYTdzgHGui8CRJDDouhdJSgTecyCIH1lMvAGAXQlQRJp)6CQoJIazviGzrqpbis43CIgMUOoaTrlbrDSRtG0qMriifceysamlJwc1XBDSRBGIPrjx02koiG5owToM)RZH6COoMQJQ6YVoEUoJIazviGzrqpbis43CIgMUOoaTrlbrD8whpxh2fKYKAKmqXHP1j0mrDVmaCD8whZFH1f96yxhXwrcyaTgmHah2UoMRJP89C2qxu75yy9Iz5vFKmfDFuEoOnAji8F65gKvbYAEo1KqRHydRajzySHXBhG2OLGOo215uDyfmPYcebtkRJDDXgwbsYWydJ3orGyBBCDF8x331XUoNQtG0a55QpceiWKaywgTeQJDDcKgYmcbPqGaX2246yUoNvh76ea9BodmGwaQAHNBDSRZH6CQo1KqRbffXos0stabOnAjiQJp)6ea9BodkkIDKOLMacp364To215qDovhGXqpGaTeHej0mPSGe0qCEHyJhlIuhF(1ja63CgOLiKiHMjLfKGgIZl8CRJxpNn0f1EogwVywE1hjtuGpkph0gTee(p9CdYQaznpNt1HvWKklqemPSo21zueiRcbmlc6jarc)Mt0W0f1bOnAjiQJDDcKgYmcbPqGatcGzz0sOo21jqAiZieKcb34Nuxx5cK6(4VoMQJDDdumnk5I2wXbbm3XQ1X8FDm55SHUO2ZHzzcuUXGu4vFKm9v(O8CqB0sq4)0ZniRcK18CcKgipx9rGabITTX1XCDrVoQQl61XZ1nCtXwejSl0I6yxNt1jqAiZieKcbcmjaMLrlbpNn0f1EoicS1zVTnf8QpsMC((O8CqB0sq4)0ZniRcK18CcKgipx9rGGUdQ3oRo215qDovh8fFRRlicgfXSmIHttuRj0m5IYfi1XNFDdeskq52bgqlavTabITTX1XCDm9DD865SHUO2ZPOi2rIwAcWR(izY55JYZbTrlbH)tp3GSkqwZZr)MZaTeHeYhwdeWgAD85xNaOFZzGb0cqvl8C9C2qxu75Cr6IAV6JKPVUpkph0gTee(p9CdYQaznpNaOFZzGb0cqvl8C9C2qxu75OLiKinFK88QpY8)2hLNdAJwcc)NEUbzvGSMNta0V5mWaAbOQfEUEoBOlQ9C0abdeQ3oZR(iZNjFuEoOnAji8F65gKvbYAEobq)MZadOfGQw4565SHUO2ZnxcqlriHx9rMF((O8CqB0sq4)0ZniRcK18CcG(nNbgqlavTWZ1ZzdDrTNZ6bGvIjtdtk9QpY8DMpkph0gTee(p9C2qxu75YmjmmPei4enc1EUbzvGSMNBGqsbk3oWaAbOQfiqSTnUoMRl6uGNRTyWZLzsyysjqWjAeQ9QpY8JUpkph0gTee(p9C2qxu75mmlgwd4eXOiIKgiIj9CdYQaznpNaOFZzGyuersdeXKjbq)MZGaLBxhF(1ja63CgyaTau1cei22gxhZ1X031Xd1f96456GV4BDDbrWOiMLrmCAIAnHMjxuUaPo(8RtnsgObDJHKIsIfQ7J6Y)BpxBXGNZWSyynGteJIisAGiM0R(iZNc8r55G2OLGW)PNZg6IAp3iVHePeuVJeT0WQNBqwfiR55InScKKHXggVDIaX2246(R776yxNt1ja63CgyaTau1cp36yxNt1ja63Cguue7irlnbeEU1XUo63CgIHyejVeAMKVXksccyX4GaLBxh76Ggiz5v3h158(Uo21jqAG8C1hbcei22gxhZ1fDphmNWqtTfdEUrEdjsjOEhjAPHvV6Jm)VYhLNdAJwcc)NEoBOlQ9CYhHAGGtBJxXIE4u2ovp3GSkqwZZja63CgyaTau1cpxpxBXGNt(iudeCAB8kw0dNY2P6vFK5789r55G2OLGW)PNZg6IApN8Hvc6HtziPa6KR8fBzGNBqwfiR55ea9BodmGwaQAHNRNRTyWZjFyLGE4ugskGo5kFXwg4vFK5788r55G2OLGW)PNZg6IApxM0eRPicofdctkxu75gKvbYAEobq)MZadOfGQw4565G5egAQTyWZLjnXAkIGtXGWKYf1E1hz(FDFuEoOnAji8F65SHUO2ZLjnXAkIGt0Mid8CdYQaznpNaOFZzGb0cqvl8C9CWCcdn1wm45YKMynfrWjAtKbE1hPZ(2hLNZg6IAp3ddPvHySNdAJwcc)NE1REobs9r5JKjFuEoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5swez18seKA6I66yxh2fKYKAKmqXHP1j0mrDVmaCDmxNZQJDDouNaPHmJqqkeiqSTnUUpQBGqsbk3oKzecsHG4rmDrDD85xNlAXOgejAjacCDmxhfuhVEoggj1wm45WuVUPrEdjKYmcbPGx9rMVpkph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45CjlISAEjcsnDrDDSRd7cszsnsgO4W06eAMOUxgaUoMRZz1XUohQta0V5mOOi2rIwAci8CRJp)6COox0Irnis0sae46yUokOo215uDgfbYQqapGwtOzIwIqIa0gTee1XBD865yyKuBXGNdt96Mg5nKqI8C1hb8QpsN5JYZbTrlbH)tphY1ZHb1ZzdDrTNJHrwJwcEogM8bEobq)MZadOfGQw45wh76COobq)MZGIIyhjAPjGWZTo(8Rl2WkqsggBy82jceBBJRJ56(UoERJDDcKgipx9rGabITTX1XCD575yyKuBXGNdt96Mipx9raV6Jm6(O8CqB0sq4)0ZniRcK18CQjHwdqeyRZEBBkeG2OLGOo215qDou3aftJsUOTvCDm)x3WnfBrKWUqlQJDDdeskq52bicS1zVTnfcei22gx3h1XuD8whF(15qDovNUdQ3oRo215qD6gd1XCDm9DD85x3aftJsUOTvCDm)xx(1XBD8whVEoBOlQ9CKNR(iGx9rsb(O8CqB0sq4)0ZnrKudrO(izYZzdDrTNZfHKjcGrpYa8QpYVYhLNdAJwcc)NEUbzvGSMNZH6CQo1KqRb8JwbY8LbbOnAjiQJp)6CQohQBGqsbk3oWW6fZk8CRJDDdeskq52bgqlavTabITTX19XFDrVoERJ36yx3aftJsUOTvCqaZDSADm)xht1rvDoRoEUohQZOiqwfcywe0taIe(nNOHPlQdqB0squh76giKuGYTdmSEXScp364To21rGjbWSmAjuh76COo34Nuxx5cK6(4VoMQJp)6iqSTnUUp(Rt3b1jDJH6yxh2fKYKAKmqXHP1j0mrDVmaCDm)xNZQJQ6mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XBDSRZH6CQoicS1zVTnfe1XNFDei22gx3h)1P7G6KUXqD8CD5xh76WUGuMuJKbkomToHMjQ7LbGRJ5)6CwDuvNrrGSkeWSiONaej8BordtxuhG2OLGOoERJDDovhgNOFZjiQJDDouNAKmqd6gdjfLeluhpuhbITTX1XBDmxx0RJDDouxSHvGKmm2W4Ttei22gx3FDFxhF(15uD6oOE7S6yxNrrGSkeWSiONaej8BordtxuhG2OLGOoE9C2qxu75YmcbPGx9r689r55G2OLGW)PNBIiPgIq9rYKNZg6IApNlcjteaJEKb4vFKopFuEoOnAji8F65SHUO2ZLzecsbp3GSkqwZZ5uDmmYA0siGPEDtJ8gsiLzecsH6yxNd15uDQjHwd4hTcK5ldcqB0squhF(15uDou3aHKcuUDGH1lMv45wh76giKuGYTdmGwaQAbceBBJR7J)6IED8whV1XUUbkMgLCrBR4GaM7y16y(VoMQJQ6CwD8CDouNrrGSkeWSiONaej8BordtxuhG2OLGOo21nqiPaLBhyy9IzfEU1XBDSRJatcGzz0sOo215qDUXpPUUYfi19XFDmvhF(1rGyBBCDF8xNUdQt6gd1XUoSliLj1izGIdtRtOzI6Eza46y(VoNvhv1zueiRcbmlc6jarc)Mt0W0f1bOnAjiQJ36yxNd15uDqeyRZEBBkiQJp)6iqSTnUUp(Rt3b1jDJH6456YVo21HDbPmPgjduCyADcntu3ldaxhZ)15S6OQoJIazviGzrqpbis43CIgMUOoaTrlbrD8wh76CQomor)Mtquh76COo1izGg0ngskkjwOoEOoceBBJRJ36yUoMYVo215qDXgwbsYWydJ3orGyBBCD)19DD85xNt1P7G6TZQJDDgfbYQqaZIGEcqKWV5enmDrDaAJwcI641ZnYBiHKAKmqX(izYR(i)6(O8CqB0sq4)0ZniRcK18CyxqktQrYafxhZ)1LFDSRJaX2246(OU8RJQ6COoSliLj1izGIRJ5)6OG64To21nqX0OKlABfxhZ)1fDpNn0f1EUbzJXOoPqSlGvV6JKPV9r55G2OLGW)PNBqwfiR55CQoggznAjeWuVUjYZvFeOo21nqX0OKlABfxhZ)1f96yxhbMeaZYOLqDSRZH6CJFsDDLlqQ7J)6yQo(8RJaX2246(4VoDhuN0ngQJDDyxqktQrYafhMwNqZe19YaW1X8FDoRoQQZOiqwfcywe0taIe(nNOHPlQdqB0squhV1XUohQZP6GiWwN922uquhF(1rGyBBCDF8xNUdQt6gd1XZ1LFDSRd7cszsnsgO4W06eAMOUxgaUoM)RZz1rvDgfbYQqaZIGEcqKWV5enmDrDaAJwcI64To21Pgjd0GUXqsrjXc1Xd1rGyBBCDmxx09C2qxu75ipx9raV6JKjM8r55G2OLGW)PNZg6IAph55Qpc45gKvbYAEoNQJHrwJwcbm1RBAK3qcjYZvFeOo215uDmmYA0siGPEDtKNR(iqDSRBGIPrjx02kUoM)Rl61XUocmjaMLrlH6yxNd15g)K66kxGu3h)1XuD85xhbITTX19XFD6oOoPBmuh76WUGuMuJKbkomToHMjQ7LbGRJ5)6CwDuvNrrGSkeWSiONaej8BordtxuhG2OLGOoERJDDouNt1brGTo7TTPGOo(8RJaX2246(4VoDhuN0ngQJNRl)6yxh2fKYKAKmqXHP1j0mrDVmaCDm)xNZQJQ6mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XBDSRtnsgObDJHKIsIfQJhQJaX2246yUUO75g5nKqsnsgOyFKm5vV6vphdGGxu7Jm)VZ)7VZ)7VYZLRr6TZWEoNRyxerbrDo)6SHUOUo5IvCOO0Z5sqZvcEUOvhfgJnmEBtxuxhfcL9GIYOvhlvDX8KCYjBvwp6WafNdEJFstxupi2uZbVXJCkkJwDFTan5zK8Q7RCSU8)o)VlklkJwDohwwNbyEsrz0QJhQJcleGOUVGDqDDkQobmTNuRZg6I66KlwdfLrRoEOokeeJya1Pgjd00odfLrRoEOokSqaI64XGH6CUuigxNdONIxbuhAwhwbtQS4nuuwugT64PraJNcI6OHjIa1nqX0MwhnKTnouhfEmaxfxxJAEGLrINpzD2qxuJRd1Y8cfLrRoBOlQXbxcmqX0M(pLgM6IYOvNn0f14GlbgOyAtP6ph7LfdTA6I6IYOvNn0f14GlbgOyAtP6pNjcjkkJwDCT5IzH06i2kQJ(nNGOoSAkUoAyIiqDdumTP1rdzBJRZArDUeGhCrQUDwDlUobQHqrz0QZg6IACWLadumTPu9NdUnxmlKMWQP4IsBOlQXbxcmqX0Ms1FoMRRmVKlAXOUO0g6IACWLadumTPu9NtSrOgePjIKeGPSC0LadumTPjmmqTa)tboUZFITIeWaAnycboSnZmrbfL2qxuJdUeyGIPnLQ)CWkysLvrPn0f14GlbgOyAtP6pNhgsRcXo2wm8BueZYigonrTMqZKlkxGuuAdDrno4sGbkM2uQ(ZXfPlQlklkJwD80iGXtbrDadGKxD6gd1PSG6SHIi1T46mg2knAjekkJwDuiaRGjvw1TZ6Cry8slH6COr1X4jBGy0sOoOH4fW1TDDdumTP8wuAdDrn(N6DqTJ783jScMuzbIGjLfL2qxuJP6phScMuzvuAdDrnMQ)CyyK1OLGJTfd)qdKS8seid60aftVniCKHjFWp0ajlVabYGMkx0Irnis0saeyE25)14q(8m2fKYeldRaVfL2qxuJP6phggznAj4yBXWpE7mjKuJKbQJmm5d(XUGuMuJKbkomToHMjQ7LbG)i)IsBOlQXu9NZWKYKn0f1j5IvhBlg(XkysLfiCCN)yfmPYcebck7bfL2qxuJP6pNHjLjBOlQtYfRo2wm8peyh35VdoPMeAneByfijdJnmE7a0gTee85lqAiZieKcbDhuVDgVfL2qxuJP6pNHjLjBOlQtYfRo2wm8lqArPn0f1yQ(ZzyszYg6I6KCXQJTfd)ILadTO0g6IAmv)5yKH1qsrec0QJ78hAGKLxqaZDSkZ)mrbuXWiRrlHa0ajlVebYGonqX0BdIIsBOlQXu9NJrgwdj3NedfL2qxuJP6ph5MXsXjESprwm0ArPn0f1yQ(ZH2YsOzsj7GACrPn0f1yQ(Zrakm0f1oUZF4l(wxxqeGbl02zjgOvWNp8fFRRlicWGfA7Sed0ksiwfLfLrRoNdcjfOCBCrPn0f14WqG)FyiTke7yBXWVrrmlJy40e1AcntUOCbIJ783jScMuzbIGjLSJnScKKHXggVDIaX224)Vz7WaHKcuUDGb0cqvlqGyBB8hFHdeskq52bffXos0stabceBBJ59dM(MkM(MNHV4BDDbrWWSyynGteJIisAGiMKTtcG(nNbgqlavTWZLTtcG(nNbffXos0staHNBrPn0f14WqGP6pNHjLjBOlQtYfRo2wm8dym0da74o)DcRGjvwGiysjBbsdKNR(iqq3b1BNXo2WkqsggBy82jceBBJ))UOmA15CnRZecCDgbQ756yD4EDH6uwqDOgQl3vzvNeLlG16IkQVCOoEmyOUCzbDDI82oRUPHvGuNYY66CoFP6eWChRwhIuxURYc906SoV6CoFPqrPn0f14WqGP6pNyJqnistejjatz54iVHesQrYaf)ZKJ78NyRibmGwdMqGdpx2oOgjd0GUXqsrjXcFmqX0OKlABfheWChRYZmfOa(8hOyAuYfTTIdcyUJvz(F4MITisyxOf8wugT6CUM11O6mHaxxURuwNyH6YDvwBxNYcQRHi06C23yhR7HH6CUNF56qDD0imUUCxLf6P1zDE15C(sHIsBOlQXHHat1FoXgHAqKMissaMYYXD(tSvKagqRbtiWHTz2zFZdeBfjGb0AWecCq8iMUOM9aftJsUOTvCqaZDSkZ)d3uSfrc7cTOOmA1XJaTau1QtIY2HjRBGAXQlQnjUoAddI6qDDJhHaTwh2fgfL2qxuJddbMQ)CyyK1OLGJTfd)mGwaQAj8JwbY8LbPbQfRUO2rgM8b)oPMeAnGF0kqMVmiaTrlbbF(ozueiRcbmlc6jarc)Mt0W0f1bOnAji4ZxG0qMriifcUXpPUUYfimZeBhWUGuMuJKbkomToHMjQ7LbG)4R4Z3PbcjfOC7adRxmRWZL3IsBOlQXHHat1FommYA0sWX2IHFgqlavTuVzSuSAsQbsAGAXQlQDKHjFWVtQjHwd9MXsXQjPgibOnAji4Z3j1KqRbicS1zVTnfcqB0sqWN)aHKcuUDaIaBD2BBtHabITTXFqb8q(8SAsO1GaaxGKWkXuldIdqB0squuAdDrnomeyQ(ZHHrwJwco2wm8ZWiRrlbhBlg(zaTau1stuRPbQfRUO2rgM8b)obFX366cIGrrmlJy40e1AcntUOCbcF(gfbYQqaZIGEcqKWV5enmDrDaAJwcc(8fa9BodeJIisAGiMmja63CgeOCB(8hiKuGYTdgMfdRbCIyuersdeXKbceBBJ)GPVz7WaHKcuUDqrrSJeT0eqGaX224pyIpFbq)MZGIIyhjAPjGWZL3IsBOlQXHHat1FomGwaQAoUZFNWkysLficeu2dylqAG8C1hbc6oOE7m2oja63CgyaTau1cpx2mmYA0siWaAbOQLWpAfiZxgKgOwS6IA2mmYA0siWaAbOQL6nJLIvtsnqsdulwDrnBggznAjeyaTau1stuRPbQfRUOUOmA1XJy9IzvxURYQoEAe4S6OQohICZyPy1KudehRdrQJ7rRaz(YG6qTmV6qDDmffV8K6CUTi24xCDoNVuDwlQJNgboRocyI8QBIi11qeAD84oNVCrPn0f14WqGP6phgwVywoUZF1KqRbicS1zVTnfcqB0sqW2b1KqRHEZyPy1KudKa0gTee85RMeAnGF0kqMVmiaTrlbbBggznAjeWBNjHKAKmq5L9aftJsUOTvmZ)d3uSfrc7cTG9aHKcuUDaIaBD2BBtHabITTXFWeBhCsnj0Aa)OvGmFzqaAJwcc(8DYOiqwfcywe0taIe(nNOHPlQdqB0sqWNVaPHmJqqkeCJFsDDLlq(4NjElkJwD8iwVyw1L7QSQlYnJLIvtsnqQJQ6IevhpncCgpPoNBlIn(fxNZ5lvN1I64rGwaQA19ClkTHUOghgcmv)5WW6fZYXD(RMeAn0BglfRMKAGeG2OLGGTtQjHwdqeyRZEBBkeG2OLGG9aftJsUOTvmZ)d3uSfrc7cTGTaOFZzGb0cqvl8ClkJwDCau38jL1nqXXqR1H66yPQlMNKtozRY6rhgO4COqgdOzHKcLhIY5KdfcL9GCYDPEZHcJXggVTPlQ5bk8xIhnpqHamyKbRqrPn0f14WqGP6phggznAj4yBXWpgNyy9IzLgOwS6IAhzyYh8BueiRcbmlc6jarc)Mt0W0f1bOnAjiy7qJ6egNOFZjisQrYafZ8pt85JDbPmPgjduCyADcntu3lda)7mEz7agNOFZjisQrYafNmAedi5ATaI3X)385JDbPmPgjduCyADcntu3ldaZ8)xXBrPn0f14WqGP6phxesMiag9idWXjIKAic9NjhHiuILSy0R1)OtbfL2qxuJddbMQ)Cyy9Iz54o)vtcTgWpAfiZxgeG2OLGGTtyfmPYcebck7bShiKuGYTdzgHGui8Cz7adJSgTecyCIH1lMvAGAXQlQ5Z3jJIazviGzrqpbis43CIgMUOoaTrlbbBbsdzgHGuiqGjbWSmAjWl7bkMgLCrBR4GaM7yvM)DWbMOkFE2Oiqwfcywe0taIe(nNOHPlQdqB0sqWlpJDbPmPgjduCyADcntu3ldaZlZFHrNnXwrcyaTgmHah2MzMYVOmA1XJy9IzvxURYQoNBdRaPokmgB4T5j1fjQoScMuzvN1I6AuD2qxgqDo3u46OFZPJ1rHEU6Ja11iTUTRJatcGzvhX6mWX6epY2z1XJaTau1OkQpDSoXJSDwDFkrirDagdnfRBN1zmSvA0siuuAdDrnomeyQ(ZHH1lMLJ78xnj0Ai2WkqsggBy82bOnAjiy7ewbtQSarWKs2XgwbsYWydJ3orGyBB8h)FZ2jbsdKNR(iqGatcGzz0sGTaPHmJqqkeiqSTnMzNXwa0V5mWaAbOQfEUSDWj1KqRbffXos0stabOnAji4Zxa0V5mOOi2rIwAci8C5LTdobym0diqlrircntklibneNxi24XIi85la63CgOLiKiHMjLfKGgIZl8C5TOmA1XXYeOCJbPOUjIuhhlc6jarDCV5enmDrDrPn0f14WqGP6phmltGYngKch35VtyfmPYcebtkzBueiRcbmlc6jarc)Mt0W0f1bOnAjiylqAiZieKcbcmjaMLrlb2cKgYmcbPqWn(j11vUa5JFMypqX0OKlABfheWChRY8ptfLrRoEAeyRZEBBkuxUSGUoAKYQok0ZvFeOoRf1XJBecsH6mcu3ZTUjIuNe1z1bn6LXQO0g6IACyiWu9Ndeb26S32McoUZFbsdKNR(iqGaX22yMJovrNNhUPylIe2fAbBNeinKzecsHabMeaZYOLqrPn0f14WqGP6phffXos0staoUZFbsdKNR(iqq3b1BNX2bNGV4BDDbrWOiMLrmCAIAnHMjxuUaHp)bcjfOC7adOfGQwGaX22yMz6BElkTHUOghgcmv)54I0f1oUZF63CgOLiKq(WAGa2q5Zxa0V5mWaAbOQfEUfL2qxuJddbMQ)COLiKinFK8CCN)cG(nNbgqlavTWZTO0g6IACyiWu9NdnqWaH6TZCCN)cG(nNbgqlavTWZTO0g6IACyiWu9NZCjaTeHeoUZFbq)MZadOfGQw45wuAdDrnomeyQ(ZX6bGvIjtdtkDCN)cG(nNbgqlavTWZTO0g6IACyiWu9NZddPvHyhBlg(ZmjmmPei4enc1oUZ)bcjfOC7adOfGQwGaX22yMJofuuAdDrnomeyQ(Z5HH0QqSJTfd)gMfdRbCIyuersdeXKoUZFbq)MZaXOiIKgiIjtcG(nNbbk3MpFbq)MZadOfGQwGaX22yMz6BEi68m8fFRRlicgfXSmIHttuRj0m5IYfi85Rgjd0GUXqsrjXcFK)3fL2qxuJddbMQ)CEyiTke7imNWqtTfd)J8gsKsq9os0sdRoUZ)ydRajzySHXBNiqSTn()B2oja63CgyaTau1cpx2oja63Cguue7irlnbeEUSPFZzigIrK8sOzs(gRijiGfJdcuUnBObswEF48(MTaPbYZvFeiqGyBBmZrVO0g6IACyiWu9NZddPvHyhBlg(Lpc1abN2gVIf9WPSDQoUZFbq)MZadOfGQw45wuAdDrnomeyQ(Z5HH0QqSJTfd)YhwjOhoLHKcOtUYxSLboUZFbq)MZadOfGQw45wuAdDrnomeyQ(Z5HH0QqSJWCcdn1wm8NjnXAkIGtXGWKYf1oUZFbq)MZadOfGQw45wuAdDrnomeyQ(Z5HH0QqSJWCcdn1wm8NjnXAkIGt0MidCCN)cG(nNbgqlavTWZTOmA19LHP9KADttkPTb11nrK6EyJwc1TkeJ5j1XJbd1H66giKuGYTdfL2qxuJddbMQ)CEyiTkeJlklkJwDF5LadToHfBzqDg9kxDbCrz0QJN2mGgfxNP1fDQQZbkGQ6YDvw19L54ToNZxkuNZvCmiwtbzE1H66YNQ6uJKbk2X6YDvw1XJaTau1CSoePUCxLvDr9jpkQdPSasUlgQlxB16MisDyumuh0ajlVqDuyjgvxU2Q1TZ64PrGZQBGIPr1T46gO4TZQ75gkkTHUOghelbg6p0mGgf74o)hOyAuYfTTIz(p6uPMeAniaWfijSsm1YG4a0gTeeSDqa0V5mWaAbOQfEU85la63Cguue7irlnbeEU85dnqYYliG5ow9JFhGMb0O4KlcjtcyUJvz(l0H8PaQyyK1OLqaAGKLxIazqNgOy6TbbV8YNVtmmYA0siG3otcj1izGYlBhCsnj0AaIaBD2BBtHa0gTee85pqiPaLBhGiWwN922uiqGyBBmZ5ZBrPn0f14GyjWqP6phggznAj4yBXW)ddP5kLaXrgM8b)dumnk5I2wXbbm3XQmZeF(qdKS8ccyUJv)4pFkGkggznAjeGgiz5Liqg0PbkMEBqWNVtmmYA0siG3otcj1izGwugT64r5QSQJNoyH2oRUpLMaWow3xR11HM19f0ldaxNP1Lpv1PgjduCOO0g6IACqSeyOu9NZ06eAMOUxga2XD(ZWiRrlHWddP5kLaHTrrGSkeGbl02zjAPjaCaAJwcc2yxqktQrYafhMwNqZe19YaWm)NFrz0Q7R166qZ6(c6LbGRZ06y6RtvDy1guJRdnRJh1RqaDDFknbGRdrQZYSTXADrNQ6CGcOQUCxLvDFz0Jwc19LryG36uJKbkouuAdDrnoiwcmuQ(ZzADcntu3lda74o)zyK1OLq4HH0CLsGW2b63CgyTcb0jAPjaCaR2GAM)z6RZNVdo5swez18seKA6IA2yxqktQrYafhMwNqZe19YaWm)hDQCWOiqwfcc0JwcjbcdbI1uZC(8sfwbtQSarGGYEaV8wugT6(ATUo0SUVGEza46uuDMRRmV6(YGjK5v3xcTyux3oRBBBOldOouxN15vNAKmqRZ06CwDQrYafhkkTHUOghelbgkv)5mToHMjQ7LbGDCK3qcj1izGI)zYXD(ZWiRrlHWddP5kLaHn2fKYKAKmqXHP1j0mrDVmamZ)oRO0g6IACqSeyOu9NdTCBbEfGJ78NHrwJwcHhgsZvkbcBhOFZzGwUTaVci8C5Z3j1KqRbgqJItKhMvaAJwcc2ozueiRcbb6rlHKaHHa0gTee8wugT6IYO5bN7NUstH6uuDMRRmV6(YGjK5v3xcTyuxNP1LFDQrYafxuAdDrnoiwcmuQ(Zj(PR0uWXrEdjKuJKbk(Njh35pdJSgTecpmKMRuce2yxqktQrYafhMwNqZe19YaW)5xuAdDrnoiwcmuQ(Zj(PR0uWXD(ZWiRrlHWddP5kLaPOSOmA19LTyldQdXai1PBmuNrVYvxaxugT64rVXRwhpUriifW1H66AuZdUKnMyK8QtnsgO46MisDklOoxYIiRMxDeKA6I662zDuav1rlbqGRZiqDMKaMiV6EUfL2qxuJdcK(ZWiRrlbhBlg(XuVUPrEdjKYmcbPGJmm5d(DjlISAEjcsnDrnBSliLj1izGIdtRtOzI6EzayMDgBheinKzecsHabITTXFmqiPaLBhYmcbPqq8iMUOMpFx0Irnis0saeyMPaElkJwD8O34vRJc9C1hbW1H66AuZdUKnMyK8QtnsgO46MisDklOoxYIiRMxDeKA6I662zDuav1rlbqGRZiqDMKaMiV6EUfL2qxuJdcKs1FommYA0sWX2IHFm1RBAK3qcjYZvFeWrgM8b)UKfrwnVebPMUOMn2fKYKAKmqXHP1j0mrDVmamZoJTdcG(nNbffXos0staHNlF(o4IwmQbrIwcGaZmfW2jJIazviGhqRj0mrlriraAJwccE5TOmA1XJEJxTok0ZvFeax3oRJhbAbOQrvuOi2rDFknbKJZTHvGuhfgJnmE76wCDp36SwuxUqDSmgqD5tvDyyGAbUojm16qDDklOok0ZvFeOUVmkQIsBOlQXbbsP6phggznAj4yBXWpM61nrEU6JaoYWKp4xa0V5mWaAbOQfEUSDqa0V5mOOi2rIwAci8C5Zp2WkqsggBy82jceBBJz(BEzlqAG8C1hbcei22gZC(fLrRooxySMSok0ZvFeOomOp36MisD80iWzfL2qxuJdcKs1FoKNR(iGJ78xnj0AaIaBD2BBtHa0gTeeSDWHbkMgLCrBRyM)hUPylIe2fAb7bcjfOC7aeb26S32McbceBBJ)GjE5Z3bN0Dq92zSDq3yGzM(Mp)bkMgLCrBRyM)ZNxE5TOmA1XJBecsH6EUudGRJ1zsmQoLSaUofv3dd1TADgUoRoSlmwtwxg0aXuePUjIuNYcQtAyToNZxQoAyIiqDwDZTxmlGuuAdDrnoiqkv)54IqYebWOhzaoorKudrO)mvuAdDrnoiqkv)5Kzecsbh35VdoPMeAnGF0kqMVmiaTrlbbF(o5WaHKcuUDGH1lMv45YEGqsbk3oWaAbOQfiqSTn(J)OZlVShOyAuYfTTIdcyUJvz(NjQCgp7GrrGSkeWSiONaej8BordtxuhG2OLGG9aHKcuUDGH1lMv45YlBcmjaMLrlb2o4g)K66kxG8Xpt85tGyBB8h)6oOoPBmWg7cszsnsgO4W06eAMOUxgaM5FNrLrrGSkeWSiONaej8BordtxuhG2OLGGx2o4eeb26S32Mcc(8jqSTn(JFDhuN0ng458zJDbPmPgjduCyADcntu3ldaZ8VZOYOiqwfcywe0taIe(nNOHPlQdqB0sqWlBNW4e9BobbBhuJKbAq3yiPOKybEGaX22yEzo6SDi2WkqsggBy82jceBBJ))MpFN0Dq92zSnkcKvHaMfb9eGiHFZjAy6I6a0gTee8wuAdDrnoiqkv)54IqYebWOhzaoorKudrO)mvuAdDrnoiqkv)5Kzecsbhh5nKqsnsgO4FMCCN)oXWiRrlHaM61nnYBiHuMriify7GtQjHwd4hTcK5ldcqB0sqWNVtomqiPaLBhyy9IzfEUShiKuGYTdmGwaQAbceBBJ)4p68Yl7bkMgLCrBR4GaM7yvM)zIkNXZoyueiRcbmlc6jarc)Mt0W0f1bOnAjiypqiPaLBhyy9IzfEU8YMatcGzz0sGTdUXpPUUYfiF8ZeF(ei22g)XVUdQt6gdSXUGuMuJKbkomToHMjQ7LbGz(3zuzueiRcbmlc6jarc)Mt0W0f1bOnAji4LTdobrGTo7TTPGGpFceBBJ)4x3b1jDJbEoF2yxqktQrYafhMwNqZe19YaWm)7mQmkcKvHaMfb9eGiHFZjAy6I6a0gTee8Y2jmor)MtqW2b1izGg0ngskkjwGhiqSTnMxMzkF2oeByfijdJnmE7ebITTX)FZNVt6oOE7m2gfbYQqaZIGEcqKWV5enmDrDaAJwccElkJwDohYgJrDDrbXUawRd1Y8Qd11f)K66kH6uJKbkUotRl6uvNZ5lvxUSGUoYR7TZQd9062UU8X15WZTofvx0RtnsgOyERdrQZz46CGcOQo1izGI5TO0g6IACqGuQ(Zzq2ymQtke7cy1XD(JDbPmPgjdumZ)5ZMaX224pYNkhWUGuMuJKbkM5FkGx2dumnk5I2wXm)h9IYOv3xaaU19CRJc9C1hbQZ06Iov1H66mPSo1izGIRZHCzbDDYLX2z1jrDwDqJEzSQZArDnsRd3MlMfs5TO0g6IACqGuQ(ZH8C1hbCCN)oXWiRrlHaM61nrEU6JaShOyAuYfTTIz(p6SjWKaywgTey7GB8tQRRCbYh)mXNpbITTXF8R7G6KUXaBSliLj1izGIdtRtOzI6EzayM)DgvgfbYQqaZIGEcqKWV5enmDrDaAJwccEz7GtqeyRZEBBki4ZNaX224p(1DqDs3yGNZNn2fKYKAKmqXHP1j0mrDVmamZ)oJkJIazviGzrqpbis43CIgMUOoaTrlbbVSvJKbAq3yiPOKybEGaX22yMJErPn0f14GaPu9Nd55Qpc44iVHesQrYaf)ZKJ783jggznAjeWuVUPrEdjKipx9ra2oXWiRrlHaM61nrEU6JaShOyAuYfTTIz(p6SjWKaywgTey7GB8tQRRCbYh)mXNpbITTXF8R7G6KUXaBSliLj1izGIdtRtOzI6EzayM)DgvgfbYQqaZIGEcqKWV5enmDrDaAJwccEz7GtqeyRZEBBki4ZNaX224p(1DqDs3yGNZNn2fKYKAKmqXHP1j0mrDVmamZ)oJkJIazviGzrqpbis43CIgMUOoaTrlbbVSvJKbAq3yiPOKybEGaX22yMJErzrz0QJNIXqpaCrPn0f14aGXqpa8)a1dOvIPGinLwm44o)Hgiz5f0ngskkfBrWmtSDsa0V5mWaAbOQfEUSDWjbsddupGwjMcI0uAXqI(r6GUdQ3oJTt2qxuhgOEaTsmfePP0IHW2PPCZyP85pFszIadwgjds6gdFKneHylcElkJwDuyzUwE46EyOUpLiKOUCxLvD8iqlavT6EUH6OWsmQUhgQl3vzvxuFw3ZToAyIiqDwDZTxmlGuNd7So1KqRGG36mCDsuNvNHRB16iVgx3erQJPVX1jEKTZQJhbAbOQfkkTHUOghamg6bGP6phAjcjsOzszbjOH48CCN)cG(nNbgqlavTWZLTdoPMeAnOOi2rIwAciaTrlbbF(cG(nNbffXos0staHNl7bkMgLCrBR4GaM7y1p(zIpFbq)MZadOfGQwGaX224p(z6BE5Zx3yiPOKyHp(z67IYOvhfwvi2vRtr1zYnRRJh)zeXADD5UkR64rGwaQA1z46KOoRodx3Q1LlQ5rLwhbWpPw321jr4TZQZQB(KsEGHjFqDddR1HyaK6uwqDei22E7S6epIPlQRdnRtzb1n3mwArPn0f14aGXqpamv)5K9mIyToHMjJIabPSCCN)deskq52bgqlavTabITTXF4m(8fa9BodmGwaQAHNlF(QrYanOBmKuusSWho77IsBOlQXbaJHEayQ(Zj7zeXADcntgfbcsz54o)NseI4GdQrYanOBmKuusSap4SV59RzGqsbk3MxMNseI4GdQrYanOBmKuusSap4SV5HbcjfOC7adOfGQwGaX22yE)AgiKuGYT5TO0g6IACaWyOhaMQ)CMOXddIKrrGSkKObl2XD(JDbPmPgjduCyADcntu3ldaZ8F(85tSvKagqRbtiWHTz(R(Mn0ajlVpC(FxuAdDrnoaym0dat1FoUpYoZB7SeT0WQJ78h7cszsnsgO4W06eAMOUxgaM5)85ZNyRibmGwdMqGdBZ8x9DrPn0f14aGXqpamv)5OSG0RPrVwKMiYaCCN)0V5mqGb1saJttezaHNlF(0V5mqGb1saJttezaPb61kqcy1gu)btFxuAdDrnoaym0dat1FoK11vcPTtyxBafL2qxuJdagd9aWu9NtUiIuWa2oramQTEafL2qxuJdagd9aWu9NtmeJi5LqZK8nwrsqalg74o)Hgiz59bf8nBNgiKuGYTdmGwaQAHNBrPn0f14aGXqpamv)5qaZD7S0uAXa2XD(Rgjd0alWKkRG7qz259nF(QrYanWcmPYk4o0p(Z)B(8vJKbAq3yiPOK7qt5)nZo77IYIYOvhNcMuzbI6OWdDrnUOmA1f5MXcRMKAG4yDisDCpALkEAe4S6qDDmffpPoU2CXSqADuONR(iqrPn0f14awbtQSaXp55Qpc44o)hOyAuYfTTIz(p6SDqnj0AO3mwkwnj1ajaTrlbbF(QjHwd4hTcK5ldcqB0sqW2b1KqRbicS1zVTnfcqB0sqWEGqsbk3oarGTo7TTPqGaX224p(ZNpFN0Dq92z8YMHrwJwcb82zsiPgjduEzRgjd0GUXqsrjXc8abITTXm)vfLrRoUhTcK5ldQJQ64yrqpbiQJ7nNOHPlQ5j1XtB8Ja1Llu3dd1HAOUmjI2K1PO6mxxzE1XJBecsH6uuDklOUyB76uJKbAD7SUvRBX11iToCBUywiTU8a1X6WO6mPSoKYci1fBBxNAKmqRZOx5QlGRZLGMRgkkTHUOghWkysLfiO6phxesMiag9idWXjIKAic9NPIsBOlQXbScMuzbcQ(ZjZieKcoUZFJIazviGzrqpbis43CIgMUOoaTrlbbB63CgWpAfiZxgeEUSPFZza)OvGmFzqGaX224pyk4m2oHXj63CcIIYOvh3JwbY8Lb8K6OWUUY8QdrQJcbtcGzvxURYQo63CcI64XncbPaUO0g6IACaRGjvwGGQ)CCrizIay0JmahNisQHi0FMkkTHUOghWkysLfiO6pNmJqqk44iVHesQrYaf)ZKJ78xnj0Aa)OvGmFzqaAJwcc2oqGyBB8hmLpF(UXpPUUYfiF8ZeVSvJKbAq3yiPOKybEGaX22yMZVOmA1X9OvGmFzqDuvhhlc6jarDCV5enmDrDDBxhxu8K6OWUUY8QdmImV6Oqpx9rG6uwMwxURuwhnuhbMeaZce1nrK6CTwaX7OO0g6IACaRGjvwGGQ)Cipx9rah35VAsO1a(rRaz(YGa0gTeeSnkcKvHaMfb9eGiHFZjAy6I6a0gTeeSDsG0a55Qpce0Dq92zSzyK1OLqaVDMesQrYaTOmA1X9OvGmFzqD5MtDCSiONae1X9Mt0W0f18K6OqG56kZRUjIuhnQF46CoFP6SwKdIuheHcTae1HBZfZcP1jEetxuhkkTHUOghWkysLfiO6phxesMiag9idWXjIKAic9NPIsBOlQXbScMuzbcQ(ZjZieKcooYBiHKAKmqX)m54o)vtcTgWpAfiZxgeG2OLGGTrrGSkeWSiONaej8BordtxuhG2OLGGTAKmqd6gdjfLelWmbITTXSDGaX224pyY5XNVtyCI(nNGG3IYOvh3JwbY8Lb1rvD80iWz8K64PmGUoedGqwbuNvhUnxmlKwhpUriifQJSzS06SPcK6Oqpx9rG6OHjIa1XtJaBD2BBtxuxuAdDrnoGvWKklqq1FoUiKmram6rgGJtej1qe6ptfL2qxuJdyfmPYceu9NtMriifCCN)QjHwd4hTcK5ldcqB0sqWwnj0AaIaBD2BBtHa0gTeeShiKuGYTdqeyRZEBBkeiqSTn(dMy7sagPSHiWuG8C1hbylqAG8C1hbcei22gZmfqv055HBk2IiHDHw45WUWWhz(uWx3RE17ba]] )

end