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

        potion = "potion_of_focused_resolve",

        package = "Assassination",
    } )


    spec:RegisterSetting( "priority_rotation", false, {
        name = "Use Priority Rotation",
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


    spec:RegisterPack( "Assassination", 20190803.1200, [[d8ewVbqiurpIkQUevuOSjuyuOcNcL0QqjQxHImlQi3cLGDrv)suXWqI6yiHLPQKNjGmnbuxtvH2gsK8nvfKXrffDouc16qIuVJkkunprvDpvv7df1)OIc5GiryHQk6HOePjQQaDruIyJQkO4JurjgPQck1jPIsALijVKkkvZeLqQBsfLYofidvvbSuKi6POQPkqDvvfuTvucXxvvqj7vO)kYGvCyklgPESuMmHld2Su9zrz0OuNwLvJsi51iPMnr3wq7wPFdz4uPJtffSCephQPt66QY2rL(UOkJxaoVOsRxvPMpvy)sosrm4iVWuig0xuMcwmLDMuoqEkO4JS4VCMrEnxxiY7AnQTmiYVwie5PeySHX3A6H2iVRLRezIyWrEm6rAqKNTQUykDo5KDk7hTVHcZbFHpPPhABeRR5GVWworE63jvN1nsh5fMcXG(IYuWIPSZKYbYtbfbkWu(JrE7PSrKip)fYsJ8SpHa2iDKxa4wK351qjWydJV10dT1qjrzpOOY51WwvxmLoNCYoL9J23qH5GVWN00dTnI11CWxylNIkNxdL4L9WAnbYPA(IYuWIRHfQHcktP)IYfvfvoVgwkBBZamLUOY51Wc1qjecquJZ(1OUgfvJa62tQ1yn9qBnYdR(IkNxdludLecrCHAuJKbA66(IkNxdludLqiarnF4yOgNvfcX1Wb6P4ta1G61GvWKkBw9rE5HvCm4ipwbtQSbrm4yquedoYdRrlbr8ZiFJCkqolY3qH0OKl6wfxdZ)1e4Ayudh1OMew1VxgBfRMKAG4H1OLGOghoQrnjSQh)OvG0FzGhwJwcIAyudh1OMew1dbGTn7DRPGhwJwcIAyutdHKcuERhcaBB27wtbpbcTBX1K)FnFvJdh1Wzn61O(2SAyTgg1W1iNrlbp(2mjKuJKbAnSwdJAuJKbQxVqiPOK4GAyHAiqODlUgMRHsf5TMEOnYtEU6Jarng0xXGJ8WA0sqe)mY3rK0cbOXGOiYBn9qBK3fHKjcGrpsdIAmOafdoYdRrlbr8ZiFJCkqolYBFdKtbpMnb9eGiHF9oQz6HwpSgTee1WOg6xV7XpAfi9xg4FU1WOg6xV7XpAfi9xg4jqODlUM8RHcFGQHrnCwdgNOF9oiI8wtp0g5ZmcbPquJbf4yWrEynAjiIFg57isAHa0yque5TMEOnY7IqYebWOhPbrng0hJbh5H1OLGi(zKVrofiNf5vtcR6XpAfi9xg4H1OLGOgg1Wrnei0Ufxt(1qXx14WrnUHpPEUYdi1K)FnuudR1WOg1izG61leskkjoOgwOgceA3IRH5A(kYBn9qBKpZieKcr(wUnjKuJKbkogefrngeLkgCKhwJwcI4Nr(g5uGCwKxnjSQh)OvG0FzGhwJwcIAyuJ9nqof8y2e0taIe(17OMPhA9WA0squdJA4Sgbs9KNR(iGxVg13MvdJA4AKZOLGhFBMesQrYanYBn9qBKN8C1hbIAmOpum4ipSgTeeXpJ8DejTqaAmikI8wtp0g5DrizIay0J0GOgdYzgdoYdRrlbr8ZiFJCkqolYRMew1JF0kq6VmWdRrlbrnmQX(giNcEmBc6jarc)6DuZ0dTEynAjiQHrnQrYa1RxiKuusCqnmxdbcTBX1WOgoQHaH2T4AYVgkCM14WrnCwdgNOF9oiQH1iV10dTr(mJqqke5B52KqsnsgO4yque1yqS4yWrEynAjiIFg57isAHa0yque5TMEOnY7IqYebWOhPbrngefuogCKhwJwcI4Nr(g5uGCwKxnjSQh)OvG0FzGhwJwcIAyuJAsyvpea22S3TMcEynAjiQHrnneskq5TEiaSTzVBnf8ei0Ufxt(1qrnmQXLaCtznHNcp55QpcudJAei1tEU6JaEceA3IRH5A(ynmvtGRHLRP5McTasyxyfrERPhAJ8zgHGuiQrnYdymSnahdogefXGJ8WA0sqe)mY3iNcKZI8WcKSC96fcjfLcTaQH5AOOgg1WzncG(17EUWkavn)ZTgg1WrnCwJaP(gABWQetbrQlTqir)iRxVg13MvdJA4SgRPhA9n02GvjMcIuxAHG)2uxEzS1AC4OM(tkteOX2izqsVqOM8RjRj8Hwa1WAK3A6H2iFdTnyvIPGi1Lwie1yqFfdoYdRrlbr8ZiFJCkqolYla6xV75cRau18p3Ayudh1WznQjHv9kkGRLOLMa8WA0squJdh1ia6xV7vuaxlrlnb4FU1WOMgkKgLCr3QyVa6x70AY)VgkQXHJAea9R39CHvaQAEceA3IRj))AOGY1WAnoCuJEHqsrjXb1K)Fnuq5iV10dTrEAjcjsOEszdjyHWCJAmOafdoYBn9qBKp7zeXzBc1t23abPSJ8WA0sqe)mQXGcCm4ipSgTeeXpJ8nYPa5Sip2fKYKAKmqX(UTjupr9ECbCnm)xZx14Wrne7ejGlSQ3ecS)2AyUgkfLRHrnWcKSCRj)A(quoYBn9qBKVJApmis23a5uirdwyuJb9XyWrEynAjiIFg5BKtbYzrESliLj1izGI9DBtOEI694c4Ay(VMVQXHJAi2jsaxyvVjey)T1WCnukkh5TMEOnY7(ixp3BZs0sdRrngeLkgCKhwJwcI4Nr(g5uGCwKN(17Ec0OwcyCQJinW)CRXHJAOF9UNanQLagN6isdsn0BvG4XQ1OUM8RHckh5TMEOnYRSH0BPrVvK6isdIAmOpum4iV10dTrEY56kH0TjSR1GipSgTeeXpJAmiNzm4ipSgTeeXpJ8nYPa5Sip9R39YRd0ses4XQ1OUM8RjqrERPhAJ85Hisbx42ebWO12ge1yqS4yWrEynAjiIFg5BKtbYzrEybswU1KFnFKY1WOgoRPHqsbkV1ZfwbOQ5FUrERPhAJ8HqiIKBc1tYx7ejbbSqCuJAKxaD7j1yWXGOigCKhwJwcI4Nr(g5uGCwKNZAWkysLni8Mug5TMEOnYt91OoQXG(kgCK3A6H2ipwbtQSJ8WA0sqe)mQXGcum4ipSgTeeXpJ8i3ipg0iV10dTrEUg5mAje55AYhe5Hfiz56jqgS1WunUOdJwqKOLaiW1WY18HQXzSA4OMVQHLRb7cszITHvOgwJ8CnsATqiYdlqYYnrGmytnui9TGiQXGcCm4ipSgTeeXpJ8i3ipg0iV10dTrEUg5mAje55AYhe5XUGuMuJKbk23TnH6jQ3JlGRj)A(kYZ1iP1cHip(2mjKuJKbAuJb9XyWrEynAjiIFg5xleI823y2gXWPoA1eQNCr5bKiV10dTrE7BmBJy4uhTAc1tUO8asKVrofiNf55SgScMuzdcVjL1WOMqdRajzySHX3MiqODlUM)AOCnmQPHqsbkV1ZfwbOQ5jqODlUM8RHckxdt1qbLRHLRbCgENRli8gMnxBbCIyFJiPgIyYAyudN1ia6xV75cRau18p3AyudN1ia6xV7vuaxlrlnb4FUrngeLkgCKhwJwcI4NrERPhAJ8ntktwtp0MKhwJ8nYPa5SipwbtQSbHNGYEqKxEynTwie5XkysLniIAmOpum4ipSgTeeXpJ8wtp0g5BMuMSMEOnjpSg5BKtbYzrEoQHZAutcR6dnScKKHXggFRhwJwcIAC4Ogbs9zgHGuWRxJ6BZQH1Ayudh1WznGZW7CDbH3(gZ2igo1rRMq9KlkpGuJdh1Wznneskq5TEPPWQjJ0S18p3AynYlpSMwleI8nboQXGCMXGJ8WA0sqe)mYBn9qBKVzszYA6H2K8WAKxEynTwie5finQXGyXXGJ8WA0sqe)mYBn9qBKVzszYA6H2K8WAKxEynTwie5fhbAAuJbrbLJbh5H1OLGi(zKVrofiNf5Hfiz56fq)ANwdZ)1qXhRHPA4AKZOLGhwGKLBIazWMAOq6BbrK3A6H2iVrA2cjfriWQrngefuedoYBn9qBK3inBHK7tIHipSgTeeXpJAmik(kgCK3A6H2iV8YyR4elQNilewnYdRrlbr8ZOg1iVlbAOqAtJbhdIIyWrERPhAJ8MRRm3Kl6WOnYdRrlbr8ZOgd6RyWrERPhAJ8Ui9qBKhwJwcI4NrnguGIbh5H1OLGi(zKVrofiNf5j2jsaxyvVjey)T1WCnu8XiV10dTr(qJqnisDejjatzh5DjqdfsBAcdn0kWr(pg1yqbogCK3A6H2ipwbtQSJ8WA0sqe)mQXG(ym4ipSgTeeXpJ8RfcrE7BmBJy4uhTAc1tUO8asK3A6H2iV9nMTrmCQJwnH6jxuEajQrnYloc00yWXGOigCKhwJwcI4Nr(g5uGCwKVHcPrjx0TkUgM)RjW1WunQjHv9caCbscRetTmi0dRrlbrnmQHJAea9R39CHvaQA(NBnoCuJaOF9UxrbCTeT0eG)5wJdh1alqYY1lG(1oTM8)RHJAGLlSOWKlcjtcOFTtRHzNr1WrnF9XAyQgUg5mAj4Hfiz5MiqgSPgkK(wqudR1WAnoCudN1W1iNrlbp(2mjKuJKbAnSwdJA4OgoRrnjSQhcaBB27wtbpSgTee14Wrnneskq5TEiaSTzVBnf8ei0UfxdZ18vnSg5TMEOnYdlxyrHrng0xXGJ8WA0sqe)mYJCJ8yqJ8wtp0g55AKZOLqKNRjFqKVHcPrjx0Tk2lG(1oTgMRHIAC4OgybswUEb0V2P1K)FnF9XAyQgUg5mAj4Hfiz5MiqgSPgkK(wquJdh1WznCnYz0sWJVntcj1izGg55AK0AHqK)HHu)KsGe1yqbkgCKhwJwcI4Nr(g5uGCwKNRroJwc(hgs9tkbsnmQX(giNcEOXgDBwIwAca7H1OLGOgg1GDbPmPgjduSVBBc1tuVhxaxdZ)18vK3A6H2iF32eQNOEpUaoQXGcCm4ipSgTeeXpJ8nYPa5SipxJCgTe8pmK6NucKAyudh1q)6Dp7tiGnrlnbG9y1AuxdZ)1qblUghoQHJA4SgxYHiNMBIGutp0wdJAWUGuMuJKbk23TnH6jQ3JlGRH5)AcCnmvdh1yFdKtbVa9OLqsGWGNyl11WCnFvdR1WunyfmPYgeEck7b1WAnSg5TMEOnY3TnH6jQ3JlGJAmOpgdoYdRrlbr8ZiFJCkqolYZ1iNrlb)ddP(jLaPgg1GDbPmPgjduSVBBc1tuVhxaxdZ)1eOiV10dTr(UTjupr9ECbCKVLBtcj1izGIJbrruJbrPIbh5H1OLGi(zKVrofiNf55AKZOLG)HHu)KsGudJA4Og6xV7PL3kWNa8p3AC4OgoRrnjSQNlSOWe5Hz7H1OLGOgg1Wzn23a5uWlqpAjKeim4H1OLGOgwJ8wtp0g5PL3kWNaIAmOpum4ipSgTeeXpJ8nYPa5SipxJCgTe8pmK6NucKAyud2fKYKAKmqX(UTjupr9ECbCn)18vK3A6H2iF4tpPPqKVLBtcj1izGIJbrruJb5mJbh5H1OLGi(zKVrofiNf55AKZOLG)HHu)KsGe5TMEOnYh(0tAke1Og5BcCm4yquedoYdRrlbr8ZiV10dTr(MjLjRPhAtYdRr(g5uGCwKNZAWkysLni8MuwdJAei1tEU6JaE9AuFBwnmQj0WkqsggBy8TjceA3IR5Vgkh5LhwtRfcrEaJHTb4Ogd6RyWrEynAjiIFg5BKtbYzrEIDIeWfw1Bcb2)CRHrnCuJAKmq96fcjfLehut(10qH0OKl6wf7fq)ANwdlxdf(pwJdh10qH0OKl6wf7fq)ANwdZ)10CtHwajSlSIAynYBn9qBKp0iudIuhrscWu2r(wUnjKuJKbkogefrnguGIbh5H1OLGi(zKVrofiNf5j2jsaxyvVjey)T1WCnbIY1Wc1qStKaUWQEtiWEXJy6H2AyutdfsJsUOBvSxa9RDAnm)xtZnfAbKWUWkI8wtp0g5dnc1Gi1rKKamLDuJbf4yWrEynAjiIFg5BKtbYzrEoRbRGjv2GWtqzpOgg1iqQN8C1hb861O(2SAyudN1ia6xV75cRau18p3Ayudh1WznQjHv94hTcK(ld8WA0squJdh1Wzn23a5uWJztqpbis4xVJAMEO1dRrlbrnoCuJaP(mJqqk4DdFs9CLhqQH5AOOgg1WrnyxqktQrYaf772Mq9e17XfW1KFnuQAC4OgoRPHqsbkV1Z12dZ2)CRH1AyTgg1WrnCwJAsyv)EzSvSAsQbIhwJwcIAC4OgoRrnjSQhcaBB27wtbpSgTee14Wrnneskq5TEiaSTzVBnf8ei0Ufxt(18XAyHA(QgwUg1KWQEbaUajHvIPwge6H1OLGOgwRHrnCudN1aodVZ1feE7BmBJy4uhTAc1tUO8asnoCuJ9nqof8y2e0taIe(17OMPhA9WA0squJdh1ia6xV7j23isQHiMmja6xV7fO82AC4OMgcjfO8wVHzZ1waNi23isQHiM0tGq7wCn5xdfuUgg10qiPaL36vuaxlrlnb4jqODlUM8RHIAynYBn9qBKNlScqvlQXG(ym4ipSgTeeXpJ8nYPa5SiVAsyvpea22S3TMcEynAjiQHrnCuJAsyv)EzSvSAsQbIhwJwcIAC4Og1KWQE8Jwbs)LbEynAjiQHrnCnYz0sWJVntcj1izGwdR1WOMgkKgLCr3Q4Ay(VMMBk0ciHDHvudJAAiKuGYB9qayBZE3Ak4jqODlUM8RHIAyudh1WznQjHv94hTcK(ld8WA0squJdh1Wzn23a5uWJztqpbis4xVJAMEO1dRrlbrnoCuJaP(mJqqk4DdFs9CLhqQj))AOOgwJ8wtp0g55A7Hzh1yquQyWrEynAjiIFg5BKtbYzrE1KWQ(9YyRy1KudepSgTee1WOgoRrnjSQhcaBB27wtbpSgTee1WOMgkKgLCr3Q4Ay(VMMBk0ciHDHvudJAea9R39CHvaQA(NBK3A6H2ipxBpm7Ogd6dfdoYdRrlbr8ZipYnYJbnYBn9qBKNRroJwcrEUM8brE7BGCk4XSjONaej8R3rntp06H1OLGOgg1WrnlAtyCI(17GiPgjduCnm)xdf14WrnyxqktQrYaf772Mq9e17XfW18xtGQH1Ayudh1GXj6xVdIKAKmqXjJgXfsU2kGWRvZFnuUghoQb7cszsnsgOyF32eQNOEpUaUgM)RHsvdRrEUgjTwie5X4exBpm7udTItp0g1yqoZyWrEynAjiIFg57isAHa0yque5TMEOnY7IqYebWOhPbrEiaLyjle9wnYh4pg1yqS4yWrEynAjiIFg5BKtbYzrE1KWQE8Jwbs)LbEynAjiQHrnCwdwbtQSbHNGYEqnmQPHqsbkV1Nzecsb)ZTgg1WrnCnYz0sWJXjU2Ey2PgAfNEOTghoQHZASVbYPGhZMGEcqKWVEh1m9qRhwJwcIAyuJaP(mJqqk4jqNay2gTeQH1AyutdfsJsUOBvSxa9RDAnm)xdh1Wrnuudt18vnSCn23a5uWJztqpbis4xVJAMEO1dRrlbrnSwdlxd2fKYKAKmqX(UTjupr9ECbCnSwdZoJQjW1WOgIDIeWfw1Bcb2FBnmxdfFf5TMEOnYZ12dZoQXGOGYXGJ8WA0sqe)mY3iNcKZI8QjHv9HgwbsYWydJV1dRrlbrnmQHZAWkysLni8MuwdJAcnScKKHXggFBIaH2T4AY)VgkxdJA4Sgbs9KNR(iGNaDcGzB0sOgg1iqQpZieKcEceA3IRH5AcunmQra0VE3ZfwbOQ5FU1WOgoQHZAutcR6vuaxlrlnb4H1OLGOghoQra0VE3ROaUwIwAcW)CRH1Ayudh1WznagdBd80sesKq9KYgsWcH56dnwuisnoCuJaOF9UNwIqIeQNu2qcwimx)ZTgwJ8wtp0g55A7Hzh1yquqrm4ipSgTeeXpJ8nYPa5SipN1GvWKkBq4nPSgg1yFdKtbpMnb9eGiHF9oQz6HwpSgTee1WOgbs9zgHGuWtGobWSnAjudJAei1NzecsbVB4tQNR8asn5)xdf1WOMgkKgLCr3QyVa6x70Ay(VgkI8wtp0g5XSnbkVqqkIAmik(kgCKhwJwcI4Nr(g5uGCwKxGup55Qpc4jqODlUgMRjW1WunbUgwUMMBk0ciHDHvudJA4Sgbs9zgHGuWtGobWSnAje5TMEOnYdbGTn7DRPquJbrrGIbh5H1OLGi(zKVrofiNf5fi1tEU6JaE9AuFBwK3A6H2iVIc4AjAPjGOgdIIahdoYdRrlbr8ZiFJCkqolYt)6DpTeHeYhw9eWAAnoCuJaOF9UNlScqvZ)CJ8wtp0g5Dr6H2OgdIIpgdoYdRrlbr8ZiFJCkqolYla6xV75cRau18p3iV10dTrEAjcjs9hj3OgdIckvm4ipSgTeeXpJ8nYPa5SiVaOF9UNlScqvZ)CJ8wtp0g5PbcgiuFBwuJbrXhkgCKhwJwcI4Nr(g5uGCwKxa0VE3ZfwbOQ5FUrERPhAJ89Ja0sese1yqu4mJbh5H1OLGi(zKVrofiNf5fa9R39CHvaQA(NBK3A6H2iVTnaRetMAMug1yquWIJbh5H1OLGi(zKFTqiYNzsOzsjqWjAeAJ8wtp0g5Zmj0mPei4encTr(g5uGCwKVHqsbkV1ZfwbOQ5jqODlUgMRjWFmQXG(IYXGJ8WA0sqe)mYVwie5nmBU2c4eX(grsneXKrERPhAJ8gMnxBbCIyFJiPgIyYiFJCkqolYla6xV7j23isQHiMmja6xV7fO82AC4Ogbq)6DpxyfGQMNaH2T4AyUgkOCnSqnbUgwUgWz4DUUGWBFJzBedN6OvtOEYfLhqQXHJAuJKbQxVqiPOK4GAYVMVOCuJb9ffXGJ8WA0sqe)mYVwie5Lpc1abNUfFId9WPSRRrERPhAJ8YhHAGGt3IpXHE4u211iFJCkqolYla6xV75cRau18p3Ogd6RVIbh5H1OLGi(zKFTqiYlFyLGE4ugskGn5kFHwge5TMEOnYlFyLGE4ugskGn5kFHwge5BKtbYzrEbq)6DpxyfGQM)5g1yqFfOyWrEynAjiIFg5BKtbYzrEbq)6DpxyfGQM)5g5TMEOnYNjnXzkIGtHGWKYdTrEO3HMMwleI8zstCMIi4uiimP8qBuJb9vGJbh5H1OLGi(zKVrofiNf5fa9R39CHvaQA(NBK3A6H2iFM0eNPicorBImiYd9o000AHqKptAIZuebNOnrge1yqF9XyWrEynAjiIFg5BKtbYzr(qdRajzySHX3MiqODlUM)AOCnmQHZAea9R39CHvaQA(NBnmQHZAea9R39kkGRLOLMa8p3Ayud9R39HqiIKBc1tYx7ejbbSqSxGYBRHrnWcKSCRj)ACMuUgg1iqQN8C1hb8ei0UfxdZ1e4iV10dTr(wUnjsjO9AjAPH1ip07qttRfcr(wUnjsjO9AjAPH1Ogd6lkvm4iV10dTr(hgsNcH4ipSgTeeXpJAuJ8cKgdogefXGJ8WA0sqe)mYJCJ8yqJ8wtp0g55AKZOLqKNRjFqK3LCiYP5Mii10dT1WOgSliLj1izGI9DBtOEI694c4AyUMavdJA4Ogbs9zgHGuWtGq7wCn5xtdHKcuERpZieKcEXJy6H2AC4Ogx0Hrlis0sae4AyUMpwdRrEUgjTwie5XuFUPwUnjKYmcbPquJb9vm4ipSgTeeXpJ8i3ipg0iV10dTrEUg5mAje55AYhe5DjhICAUjcsn9qBnmQb7cszsnsgOyF32eQNOEpUaUgMRjq1WOgoQra0VE3ROaUwIwAcW)CRXHJA4Ogx0Hrlis0sae4AyUMpwdJA4Sg7BGCk4Xny1eQNOLiKWdRrlbrnSwdRrEUgjTwie5XuFUPwUnjKipx9rGOgdkqXGJ8WA0sqe)mYJCJ8yqJ8wtp0g55AKZOLqKNRjFqKxa0VE3ZfwbOQ5FU1WOgoQra0VE3ROaUwIwAcW)CRXHJAcnScKKHXggFBIaH2T4AyUgkxdR1WOgbs9KNR(iGNaH2T4AyUMVI8CnsATqiYJP(CtKNR(iquJbf4yWrEynAjiIFg5BKtbYzrE1KWQEiaSTzVBnf8WA0squdJA4OgoQPHcPrjx0TkUgM)RP5McTasyxyf1WOMgcjfO8wpea22S3TMcEceA3IRj)AOOgwRXHJA4OgoRrVg13MvdJA4Og9cHAyUgkOCnoCutdfsJsUOBvCnm)xZx1WAnSwdRrERPhAJ8KNR(iquJb9XyWrEynAjiIFg57isAHa0yque5TMEOnY7IqYebWOhPbrngeLkgCKhwJwcI4Nr(g5uGCwKNJA4Sg1KWQE8Jwbs)LbEynAjiQXHJA4SgoQPHqsbkV1Z12dZ2)CRHrnneskq5TEUWkavnpbcTBX1K)FnbUgwRH1AyutdfsJsUOBvSxa9RDAnm)xdf1WunbQgwUgoQX(giNcEmBc6jarc)6DuZ0dTEynAjiQHrnneskq5TEU2Ey2(NBnSwdJAiqNay2gTeQHrnCuJB4tQNR8asn5)xdf14Wrnei0Ufxt()1OxJ6KEHqnmQb7cszsnsgOyF32eQNOEpUaUgM)Rjq1Wun23a5uWJztqpbis4xVJAMEO1dRrlbrnSwdJA4OgoRbcaBB27wtbrnoCudbcTBX1K)Fn61OoPxiudlxZx1WOgSliLj1izGI9DBtOEI694c4Ay(VMavdt1yFdKtbpMnb9eGiHF9oQz6HwpSgTee1WAnmQHZAW4e9R3brnmQHJAuJKbQxVqiPOK4GAyHAiqODlUgwRH5AcCnmQHJAcnScKKHXggFBIaH2T4A(RHY14WrnCwJEnQVnRgg1yFdKtbpMnb9eGiHF9oQz6HwpSgTee1WAK3A6H2iFMriifIAmOpum4ipSgTeeXpJ8DejTqaAmikI8wtp0g5DrizIay0J0GOgdYzgdoYdRrlbr8ZiFJCkqolYZznCnYz0sWJP(CtTCBsiLzecsHAyudh1WznQjHv94hTcK(ld8WA0squJdh1WznCutdHKcuERNRThMT)5wdJAAiKuGYB9CHvaQAEceA3IRj))AcCnSwdR1WOMgkKgLCr3QyVa6x70Ay(VgkQHPAcunSCnCuJ9nqof8y2e0taIe(17OMPhA9WA0squdJAAiKuGYB9CT9WS9p3AyTgg1qGobWSnAjudJA4Og3WNupx5bKAY)VgkQXHJAiqODlUM8)RrVg1j9cHAyud2fKYKAKmqX(UTjupr9ECbCnm)xtGQHPASVbYPGhZMGEcqKWVEh1m9qRhwJwcIAyTgg1WrnCwdea22S3TMcIAC4OgceA3IRj))A0RrDsVqOgwUMVQHrnyxqktQrYaf772Mq9e17XfW1W8FnbQgMQX(giNcEmBc6jarc)6DuZ0dTEynAjiQH1AyudN1GXj6xVdIAyudh1OgjduVEHqsrjXb1Wc1qGq7wCnSwdZ1qXx1WOgoQj0WkqsggBy8TjceA3IR5VgkxJdh1Wzn61O(2SAyuJ9nqof8y2e0taIe(17OMPhA9WA0squdRrERPhAJ8zgHGuiY3YTjHKAKmqXXGOiQXGyXXGJ8WA0sqe)mY3iNcKZI8yxqktQrYafxdZ)18vnmQHaH2T4AYVMVQHPA4OgSliLj1izGIRH5)A(ynSwdJAAOqAuYfDRIRH5)AcCK3A6H2iFJCHy0Mui0fWAuJbrbLJbh5H1OLGi(zKVrofiNf55SgUg5mAj4XuFUjYZvFeOgg10qH0OKl6wfxdZ)1e4Ayudb6eaZ2OLqnmQHJACdFs9CLhqQj))AOOghoQHaH2T4AY)Vg9AuN0leQHrnyxqktQrYaf772Mq9e17XfW1W8FnbQgMQX(giNcEmBc6jarc)6DuZ0dTEynAjiQH1Ayudh1WznqayBZE3AkiQXHJAiqODlUM8)RrVg1j9cHAy5A(Qgg1GDbPmPgjduSVBBc1tuVhxaxdZ)1eOAyQg7BGCk4XSjONaej8R3rntp06H1OLGOgwRHrnQrYa1RxiKuusCqnSqnei0UfxdZ1e4iV10dTrEYZvFeiQXGOGIyWrEynAjiIFg5BKtbYzrEoRHRroJwcEm1NBQLBtcjYZvFeOgg1WznCnYz0sWJP(CtKNR(iqnmQPHcPrjx0TkUgM)RjW1WOgc0jaMTrlHAyudh14g(K65kpGut()1qrnoCudbcTBX1K)Fn61OoPxiudJAWUGuMuJKbk23TnH6jQ3JlGRH5)AcunmvJ9nqof8y2e0taIe(17OMPhA9WA0squdR1WOgoQHZAGaW2M9U1uquJdh1qGq7wCn5)xJEnQt6fc1WY18vnmQb7cszsnsgOyF32eQNOEpUaUgM)Rjq1Wun23a5uWJztqpbis4xVJAMEO1dRrlbrnSwdJAuJKbQxVqiPOK4GAyHAiqODlUgMRjWrERPhAJ8KNR(iqKVLBtcj1izGIJbrruJAuJ8Cbc(qBmOVOmfSyk7mPCGI85zK92mCK3zn0fruquZhQgRPhARrEyf7lQI8Ueu)KqK351qjWydJV10dT1qjrzpOOY51WwvxmLoNCYoL9J23qH5GVWN00dTnI11CWxylNIkNxdL4L9WAnbYPA(IYuWIRHfQHcktP)IYfvfvoVgwkBBZamLUOY51Wc1qjecquJZ(1OUgfvJa62tQ1yn9qBnYdR(IkNxdludLecrCHAuJKbA66(IkNxdludLqiarnF4yOgNvfcX1Wb6P4ta1G61GvWKkBw9fvfvoVgwsaq7PGOgAOJiqnnuiTP1qdz3I91qjAnWvX1SOLfyBKW(twJ10dT4AqRmxFrLZRXA6HwS3LanuiTP)DPHPUOY51yn9ql27sGgkK2uM(ZXEzHWQMEOTOY51yn9ql27sGgkK2uM(ZPJqIIkNxd)AUy2iTgIDIAOF9oiQbRMIRHg6icutdfsBAn0q2T4ASvuJlbybxKQ3MvZHRrGwWxu58ASMEOf7DjqdfsBkt)5GxZfZgPjSAkUOYA6HwS3LanuiTPm9NJ56kZn5IomAlQSMEOf7DjqdfsBkt)54I0dTfvwtp0I9UeOHcPnLP)Ccnc1Gi1rKKamLTtUeOHcPnnHHgAf4)p601)j2jsaxyvVjey)TmtXhlQSMEOf7DjqdfsBkt)5GvWKk7IkRPhAXExc0qH0MY0FopmKofcDATq43(gZ2igo1rRMq9KlkpGuuvu58AyjbaTNcIAaUaj3A0leQrzd1ynfrQ5W1yCTtA0sWxu58AOKawbtQSR5614IW4Jwc1WXIQH7tUaXOLqnWcHhGR52AAOqAtzTOYA6Hw8p1xJANU(pNyfmPYgeEtklQSMEOfZ0FoyfmPYUOYA6Hwmt)5W1iNrlbNwle(Hfiz5MiqgSPgkK(wq4ext(GFybswUEcKbltUOdJwqKOLaiWS8hYzmo(ILXUGuMyByfyTOYA6Hwmt)5W1iNrlbNwle(X3MjHKAKmqDIRjFWp2fKYKAKmqX(UTjupr9ECbC(Fvuzn9qlMP)CEyiDke60AHWV9nMTrmCQJwnH6jxuEaXPR)ZjwbtQSbH3KsgHgwbsYWydJVnrGq7w8pLz0qiPaL365cRau18ei0UfNpfuMjkOmldodVZ1feEdZMRTaorSVrKudrmjdofa9R39CHvaQA(Nldofa9R39kkGRLOLMa8p3IkRPhAXm9NtZKYK10dTj5HvNwle(XkysLniC66)yfmPYgeEck7bfvwtp0Iz6pNMjLjRPhAtYdRoTwi83eyNU(phCQMew1hAyfijdJnm(wpSgTeeoCiqQpZieKcE9AuFBgRm4GtWz4DUUGWBFJzBedN6OvtOEYfLhqC4GZgcjfO8wV0uy1KrA2A(NlRfvwtp0Iz6pNMjLjRPhAtYdRoTwi8lqArL10dTyM(ZPzszYA6H2K8WQtRfc)IJanTOYA6Hwmt)5yKMTqsrecSQtx)hwGKLRxa9RDkZ)u8rM4AKZOLGhwGKLBIazWMAOq6BbrrL10dTyM(ZXinBHK7tIHIkRPhAXm9NJ8YyR4elQNilewTOQOY51WsriPaL3IlQSMEOf7Bc8FZKYK10dTj5HvNwle(bmg2gGD66)CIvWKkBq4nPKHaPEYZvFeWRxJ6BZyeAyfijdJnm(2ebcTBX)uUOY514S2RXecCngbQ556un49CHAu2qnOfQjVtzxJeLhG1Aco4pOVMpCmutESHTgrU3Mvt3WkqQrzBBnS0pqncOFTtRbrQjVtzJEAn2MBnS0pGVOYA6HwSVjWm9NtOrOgePoIKeGPSDQLBtcj1izGI)PWPR)tStKaUWQEtiW(NldouJKbQxVqiPOK4G8BOqAuYfDRI9cOFTtzzk8F0HJgkKgLCr3QyVa6x7uM)BUPqlGe2fwbRfvoVgN1EnlQgtiW1K3jL1ioOM8oL9T1OSHAwiaTMarzSt18WqnoB9pynOTgAegxtENYg90ASn3AyPFaFrL10dTyFtGz6pNqJqnisDejjatz701)j2jsaxyvVjey)TmhikZce7ejGlSQ3ecSx8iMEOLrdfsJsUOBvSxa9RDkZ)n3uOfqc7cROOYA6HwSVjWm9NdxyfGQMtx)NtScMuzdcpbL9agcK6jpx9raVEnQVnJbNcG(17EUWkavn)ZLbhCQMew1JF0kq6VmWdRrlbHdhCAFdKtbpMnb9eGiHF9oQz6HwpSgTeeoCiqQpZieKcE3WNupx5beMPGbhyxqktQrYaf772Mq9e17XfW5tPC4GZgcjfO8wpxBpmB)ZLvwzWbNQjHv97LXwXQjPgiEynAjiC4Gt1KWQEiaSTzVBnf8WA0sq4WrdHKcuERhcaBB27wtbpbcTBX5)rw4lwwnjSQxaGlqsyLyQLbHEynAjiyLbhCcodVZ1feE7BmBJy4uhTAc1tUO8aIdh23a5uWJztqpbis4xVJAMEO1dRrlbHdhcG(17EI9nIKAiIjtcG(17EbkV1HJgcjfO8wVHzZ1waNi23isQHiM0tGq7wC(uqzgneskq5TEffW1s0staEceA3IZNcwlQCEnSi2Ey21K3PSRHLeaoRgMQHJGUm2kwnj1aXPAqKA4F0kq6VmOg0kZTg0wdfbZkLUgNnlGl8fwdl9duJTIAyjbGZQHaMi3A6isnleGwJZcl9dwuzn9ql23eyM(ZHRThMTtx)xnjSQhcaBB27wtbpSgTeem4qnjSQFVm2kwnj1aXdRrlbHdhQjHv94hTcK(ld8WA0sqWGRroJwcE8TzsiPgjduwz0qH0OKl6wfZ8FZnfAbKWUWky0qiPaL36HaW2M9U1uWtGq7wC(uWGdovtcR6XpAfi9xg4H1OLGWHdoTVbYPGhZMGEcqKWVEh1m9qRhwJwcchoei1NzecsbVB4tQNR8as()uWArLZRHfX2dZUM8oLDnbDzSvSAsQbsnmvtqOAyjbGZO014SzbCHVWAyPFGASvudlcScqvRMNBrL10dTyFtGz6phU2Ey2oD9F1KWQ(9YyRy1KudepSgTeem4unjSQhcaBB27wtbpSgTeemAOqAuYfDRIz(V5McTasyxyfmea9R39CHvaQA(NBrLZRHhGA6pPSMgkmewTg0wdBvDXu6CYj7u2pAFdfMdL04clBKuOSqWS0COKOShKtEh1xoucm2W4Bn9qllqj(aSOzbkjGbJ0y7lQSMEOf7Bcmt)5W1iNrlbNwle(X4exBpm7udTItp06ext(GF7BGCk4XSjONaej8R3rntp06H1OLGGbhlAtyCI(17GiPgjdumZ)u4Wb2fKYKAKmqX(UTjupr9ECb8FGyLbhyCI(17GiPgjduCYOrCHKRTci8A)u2HdSliLj1izGI9DBtOEI694cyM)PuSwuzn9ql23eyM(ZXfHKjcGrpsdCQJiPfcq)PWjiaLyjle9w9pWFSOYA6HwSVjWm9NdxBpmBNU(VAsyvp(rRaP)YapSgTeem4eRGjv2GWtqzpGrdHKcuERpZieKc(Nldo4AKZOLGhJtCT9WStn0ko9qRdhCAFdKtbpMnb9eGiHF9oQz6HwpSgTeemei1Nzecsbpb6eaZ2OLaRmAOqAuYfDRI9cOFTtz(NdoOGPVyz7BGCk4XSjONaej8R3rntp06H1OLGGvwg7cszsnsgOyF32eQNOEpUaMvMDgfyge7ejGlSQ3ecS)wMP4RIkNxdlIThMDn5Dk7AC2mScKAOeySHVLsxtqOAWkysLDn2kQzr1yn94c14SrjQH(17ovdL85QpcuZI0AUTgc0jaMDneBZaNQr8i3MvdlcScqvJPG)0PAepYTz18PeHe1aymSFxZ1RX4AN0OLGVOYA6HwSVjWm9NdxBpmBNU(VAsyvFOHvGKmm2W4B9WA0sqWGtScMuzdcVjLmcnScKKHXggFBIaH2T48)Pmdofi1tEU6JaEc0jaMTrlbgcK6ZmcbPGNaH2TyMdedbq)6DpxyfGQM)5YGdovtcR6vuaxlrlnb4H1OLGWHdbq)6DVIc4AjAPja)ZLvgCWjGXW2apTeHejupPSHeSqyU(qJffI4WHaOF9UNwIqIeQNu2qcwimx)ZL1IkNxdpBtGYleKIA6isn8SjONae1W)6DuZ0dTfvwtp0I9nbMP)CWSnbkVqqkC66)CIvWKkBq4nPKH9nqof8y2e0taIe(17OMPhA9WA0sqWqGuFMriif8eOtamBJwcmei1NzecsbVB4tQNR8as()uWOHcPrjx0Tk2lG(1oL5FkkQCEnSKaW2M9U1uOM8ydBn0iLDnuYNR(iqn2kQXzXieKc1yeOMNBnDePgjAZQbw0lJDrL10dTyFtGz6phiaSTzVBnfC66)cK6jpx9rapbcTBXmhyMcml3CtHwajSlScgCkqQpZieKcEc0jaMTrlHIkRPhAX(MaZ0FokkGRLOLMaC66)cK6jpx9raVEnQVnROYA6HwSVjWm9NJlsp0601)PF9UNwIqc5dREcyn1Hdbq)6DpxyfGQM)5wuzn9ql23eyM(ZHwIqIu)rY1PR)la6xV75cRau18p3IkRPhAX(MaZ0Fo0abdeQVnZPR)la6xV75cRau18p3IkRPhAX(MaZ0Fo9Ja0ses401)fa9R39CHvaQA(NBrL10dTyFtGz6phBBawjMm1mP0PR)la6xV75cRau18p3IkRPhAX(MaZ0FopmKofcDATq4pZKqZKsGGt0i0601)BiKuGYB9CHvaQAEceA3IzoWFSOYA6HwSVjWm9NZddPtHqNwle(nmBU2c4eX(grsneXKoD9Fbq)6DpX(grsneXKjbq)6DVaL36WHaOF9UNlScqvZtGq7wmZuqzwiWSm4m8oxxq4TVXSnIHtD0Qjup5IYdioCOgjduVEHqsrjXb5)fLlQSMEOf7Bcmt)58Wq6ui0P1cHF5JqnqWPBXN4qpCk76Qtx)xa0VE3ZfwbOQ5FUfvwtp0I9nbMP)CEyiDke60AHWV8Hvc6HtziPa2KR8fAzGtx)xa0VE3ZfwbOQ5FUfvwtp0I9nbMP)CEyiDke6e07qttRfc)zstCMIi4uiimP8qRtx)xa0VE3ZfwbOQ5FUfvwtp0I9nbMP)CEyiDke6e07qttRfc)zstCMIi4eTjYaNU(VaOF9UNlScqvZ)ClQSMEOf7Bcmt)58Wq6ui0jO3HMMwle(B52KiLG2RLOLgwD66)HgwbsYWydJVnrGq7w8pLzWPaOF9UNlScqvZ)CzWPaOF9UxrbCTeT0eG)5YG(17(qierYnH6j5RDIKGawi2lq5TmGfiz5MVZKYmei1tEU6JaEceA3IzoWfvoVMpi0TNuRPBsjT1OUMoIuZdB0sOMtHqmLUMpCmudARPHqsbkV1xuzn9ql23eyM(Z5HH0PqiUOQOY518bpc00AewOLb1y0N80dWfvoVgwYYfwuynMwtGzQgo(it1K3PSR5dYZAnS0pGVgN1WqqCMcYCRbT18ft1OgjduSt1K3PSRHfbwbOQ5unisn5Dk7Ac(tNXRbPSbsEhgQjp70A6isnyuiudSajlxFnucjgvtE2P1C9AyjbGZQPHcPr1C4AAOWBZQ556lQSMEOf7fhbA6pSCHff601)BOqAuYfDRIz(pWmPMew1laWfijSsm1YGqpSgTeem4qa0VE3ZfwbOQ5FUoCia6xV7vuaxlrlnb4FUoCalqYY1lG(1on)FoGLlSOWKlcjtcOFTtz2zehF9rM4AKZOLGhwGKLBIazWMAOq6BbbRS6WbNCnYz0sWJVntcj1izGYkdo4unjSQhcaBB27wtbpSgTeeoC0qiPaL36HaW2M9U1uWtGq7wmZFXArL10dTyV4iqtz6phUg5mAj40AHW)ddP(jLaXjUM8b)nuink5IUvXEb0V2PmtHdhWcKSC9cOFTtZ))RpYexJCgTe8WcKSCteid2udfsFliC4GtUg5mAj4X3MjHKAKmqlQCEnFyDk7Ayjn2OBZQ5tPjaSt18HX2Aq9AC23JlGRX0A(IPAuJKbk2xuzn9ql2loc0uM(ZPBBc1tuVhxa701)5AKZOLG)HHu)KsGWW(giNcEOXgDBwIwAca7H1OLGGb2fKYKAKmqX(UTjupr9ECbmZ)Fvu58A(WyBnOEno77XfW1yAnuWIzQgSAnQX1G618H9jeWwZNsta4AqKASm7wSwtGzQgo(it1K3PSR5dIE0sOMpicdSwJAKmqX(IkRPhAXEXrGMY0FoDBtOEI694cyNU(pxJCgTe8pmK6NucegCq)6Dp7tiGnrlnbG9y1AuZ8pfSyho4GtxYHiNMBIGutp0Ya7cszsnsgOyF32eQNOEpUaM5)aZeh23a5uWlqpAjKeim4j2snZFXktyfmPYgeEck7bSYArLZR5dJT1G614SVhxaxJIQXCDL5wZhemHm3A(aOdJ2AUEn3An94c1G2ASn3AuJKbAnMwtGQrnsgOyFrL10dTyV4iqtz6pNUTjupr9ECbStTCBsiPgjdu8pfoD9FUg5mAj4Fyi1pPeimWUGuMuJKbk23TnH6jQ3JlGz(pqfvwtp0I9IJanLP)COL3kWNaC66)CnYz0sW)WqQFsjqyWb9R390YBf4ta(NRdhCQMew1ZfwuyI8WS9WA0sqWGt7BGCk4fOhTesceg8WA0sqWArLZRjyJMfC2E6jnfQrr1yUUYCR5dcMqMBnFa0HrBnMwZx1OgjduCrL10dTyV4iqtz6pNWNEstbNA52KqsnsgO4FkC66)CnYz0sW)WqQFsjqyGDbPmPgjduSVBBc1tuVhxa))vrL10dTyV4iqtz6pNWNEstbNU(pxJCgTe8pmK6NucKIQIkNxZh0cTmOgexGuJEHqng9jp9aCrLZRHf9fEAnolgHGuaxdARzrll4sUqIrYTg1izGIRPJi1OSHACjhICAU1qqQPhAR5618rMQHwcGaxJrGAmjbmrU18ClQSMEOf7fi9NRroJwcoTwi8JP(CtTCBsiLzecsbN4AYh87soe50CteKA6HwgyxqktQrYaf772Mq9e17XfWmhigCiqQpZieKcEceA3IZVHqsbkV1NzecsbV4rm9qRdhUOdJwqKOLaiWm)rwlQCEnSOVWtRHs(C1hbW1G2Aw0YcUKlKyKCRrnsgO4A6isnkBOgxYHiNMBneKA6H2AUEnFKPAOLaiW1yeOgtsatKBnp3IkRPhAXEbsz6phUg5mAj40AHWpM6Zn1YTjHe55Qpc4ext(GFxYHiNMBIGutp0Ya7cszsnsgOyF32eQNOEpUaM5aXGdbq)6DVIc4AjAPja)Z1HdoCrhgTGirlbqGz(Jm40(giNcECdwnH6jAjcj8WA0sqWkRfvoVgw0x4P1qjFU6Ja4AUEnSiWkavnMcgfW1Q5tPjGCC2mScKAOeySHX3wZHR55wJTIAYdQHTXfQ5lMQbdn0kW1iHUwdARrzd1qjFU6Ja18brbxuzn9ql2lqkt)5W1iNrlbNwle(XuFUjYZvFeWjUM8b)cG(17EUWkavn)ZLbhcG(17EffW1s0sta(NRdhHgwbsYWydJVnrGq7wmZuMvgcK6jpx9rapbcTBXm)vrLZRH3fANjRHs(C1hbQbd6ZTMoIudljaCwrL10dTyVaPm9Nd55Qpc401)vtcR6HaW2M9U1uWdRrlbbdo4OHcPrjx0TkM5)MBk0ciHDHvWOHqsbkV1dbGTn7DRPGNaH2T48PGvho4Gt9AuFBgdo0leyMck7WrdfsJsUOBvmZ)FXkRSwu58ACwmcbPqnpxQbW1PAmjgvJsoaxJIQ5HHAoTgdxJvd2fANjRjdwGykIuthrQrzd1inSwdl9dudn0reOgRM(ThMnqkQSMEOf7fiLP)CCrizIay0J0aN6isAHa0FkkQSMEOf7fiLP)CYmcbPGtx)NdovtcR6XpAfi9xg4H1OLGWHdo5OHqsbkV1Z12dZ2)Cz0qiPaL365cRau18ei0UfN)FGzLvgnuink5IUvXEb0V2Pm)tbtbIL5W(giNcEmBc6jarc)6DuZ0dTEynAjiy0qiPaL365A7Hz7FUSYGaDcGzB0sGbhUHpPEUYdi5)tHdhei0UfN)VEnQt6fcmWUGuMuJKbk23TnH6jQ3JlGz(pqmzFdKtbpMnb9eGiHF9oQz6HwpSgTeeSYGdoHaW2M9U1uq4WbbcTBX5)RxJ6KEHal)fdSliLj1izGI9DBtOEI694cyM)det23a5uWJztqpbis4xVJAMEO1dRrlbbRm4eJt0VEhem4qnsgOE9cHKIsIdybceA3IzL5aZGJqdRajzySHX3MiqODl(NYoCWPEnQVnJH9nqof8y2e0taIe(17OMPhA9WA0sqWArL10dTyVaPm9NJlcjteaJEKg4uhrsleG(trrL10dTyVaPm9NtMriifCQLBtcj1izGI)PWPR)ZjxJCgTe8yQp3ul3MeszgHGuGbhCQMew1JF0kq6VmWdRrlbHdhCYrdHKcuERNRThMT)5YOHqsbkV1ZfwbOQ5jqODlo))aZkRmAOqAuYfDRI9cOFTtz(NcMcelZH9nqof8y2e0taIe(17OMPhA9WA0sqWOHqsbkV1Z12dZ2)CzLbb6eaZ2OLadoCdFs9CLhqY)NchoiqODlo)F9AuN0leyGDbPmPgjduSVBBc1tuVhxaZ8FGyY(giNcEmBc6jarc)6DuZ0dTEynAjiyLbhCcbGTn7DRPGWHdceA3IZ)xVg1j9cbw(lgyxqktQrYaf772Mq9e17XfWm)hiMSVbYPGhZMGEcqKWVEh1m9qRhwJwccwzWjgNOF9oiyWHAKmq96fcjfLehWcei0UfZkZu8fdocnScKKHXggFBIaH2T4Fk7WbN61O(2mg23a5uWJztqpbis4xVJAMEO1dRrlbbRfvoVgwk5cXOTMGHqxaR1GwzU1G2AcFs9CLqnQrYafxJP1eyMQHL(bQjp2Wwd5T7Tz1GEAn3wZx4A445wJIQjW1OgjdumR1Gi1eiCnC8rMQrnsgOywlQSMEOf7fiLP)CAKleJ2KcHUawD66)yxqktQrYafZ8)xmiqODlo)VyIdSliLj1izGIz()JSYOHcPrjx0TkM5)axu58AC2bWTMNBnuYNR(iqnMwtGzQg0wJjL1OgjduCnCKhByRrECVnRgjAZQbw0lJDn2kQzrAn41CXSrkRfvwtp0I9cKY0FoKNR(iGtx)NtUg5mAj4XuFUjYZvFeGrdfsJsUOBvmZ)bMbb6eaZ2OLadoCdFs9CLhqY)NchoiqODlo)F9AuN0leyGDbPmPgjduSVBBc1tuVhxaZ8FGyY(giNcEmBc6jarc)6DuZ0dTEynAjiyLbhCcbGTn7DRPGWHdceA3IZ)xVg1j9cbw(lgyxqktQrYaf772Mq9e17XfWm)hiMSVbYPGhZMGEcqKWVEh1m9qRhwJwccwzOgjduVEHqsrjXbSabcTBXmh4IkRPhAXEbsz6phYZvFeWPwUnjKuJKbk(NcNU(pNCnYz0sWJP(CtTCBsirEU6Jam4KRroJwcEm1NBI8C1hby0qH0OKl6wfZ8FGzqGobWSnAjWGd3WNupx5bK8)PWHdceA3IZ)xVg1j9cbgyxqktQrYaf772Mq9e17XfWm)hiMSVbYPGhZMGEcqKWVEh1m9qRhwJwccwzWbNqayBZE3AkiC4GaH2T48)1RrDsVqGL)Ib2fKYKAKmqX(UTjupr9ECbmZ)bIj7BGCk4XSjONaej8R3rntp06H1OLGGvgQrYa1RxiKuusCalqGq7wmZbUOQOY51WsWyyBaUOYA6HwShWyyBa(VH2gSkXuqK6sleC66)WcKSC96fcjfLcTayMcgCka6xV75cRau18pxgCWPaP(gABWQetbrQlTqir)iRxVg13MXGtRPhA9n02GvjMcIuxAHG)2uxEzSvho6pPmrGgBJKbj9cH8ZAcFOfaRfvoVgkHmplxCnpmuZNsesutENYUgweyfGQwnpxFnucjgvZdd1K3PSRj4pR55wdn0reOgRM(ThMnqQHJRxJAsyvqWAngUgjAZQXW1CAnK3IRPJi1qbLX1iEKBZQHfbwbOQ5lQSMEOf7bmg2gGz6phAjcjsOEszdjyHWCD66)cG(17EUWkavn)ZLbhCQMew1ROaUwIwAcWdRrlbHdhcG(17EffW1s0sta(NlJgkKgLCr3QyVa6x708)PWHdbq)6DpxyfGQMNaH2T48)PGYS6WHEHqsrjXb5)tbLlQSMEOf7bmg2gGz6pNSNreNTjupzFdeKYUOYA6HwShWyyBaMP)C6O2ddIK9nqofs0Gf601)XUGuMuJKbk23TnH6jQ3JlGz()lhoi2jsaxyvVjey)TmtPOmdybswU5)HOCrL10dTypGXW2amt)54(ixp3BZs0sdRoD9FSliLj1izGI9DBtOEI694cyM))YHdIDIeWfw1Bcb2FlZukkxuzn9ql2dymSnaZ0FokBi9wA0BfPoI0aNU(p9R39eOrTeW4uhrAG)56Wb9R39eOrTeW4uhrAqQHERcepwTg15tbLlQSMEOf7bmg2gGz6phY56kH0TjSR1GIkRPhAXEaJHTbyM(Zjperk4c3MiagT22aNU(p9R39YRd0ses4XQ1Oo)avuzn9ql2dymSnaZ0FoHqiIKBc1tYx7ejbbSqStx)hwGKLB(FKYm4SHqsbkV1ZfwbOQ5FUfvfvoVgEfmPYge1qjA6HwCrLZRjOlJnwnj1aXPAqKA4F0ktSKaWz1G2AOiykDn8R5IzJ0AOKpx9rGIkRPhAXEScMuzdIFYZvFeWPR)3qH0OKl6wfZ8FGzWHAsyv)EzSvSAsQbIhwJwcchoutcR6XpAfi9xg4H1OLGGbhQjHv9qayBZE3Ak4H1OLGGrdHKcuERhcaBB27wtbpbcTBX5))LdhCQxJ6BZyLbxJCgTe84BZKqsnsgOSYqnsgOE9cHKIsIdybceA3IzMsvu58A4F0kq6VmOgMQHNnb9eGOg(xVJAMEOLsxdlzXpcutEqnpmudAHAYKiAtwJIQXCDL5wJZIriifQrr1OSHAcTBRrnsgO1C9AoTMdxZI0AWR5IzJ0AYfuNQbJQXKYAqkBGutODBnQrYaTgJ(KNEaUgxcQFQVOYA6HwShRGjv2GGP)CCrizIay0J0aN6isAHa0FkkQSMEOf7XkysLniy6pNmJqqk401)TVbYPGhZMGEcqKWVEh1m9qRhwJwccg0VE3JF0kq6VmW)Czq)6Dp(rRaP)YapbcTBX5tHpqm4eJt0VEhefvoVg(hTcK(ldO01qjCDL5wdIudLe6eaZUM8oLDn0VEhe14SyecsbCrL10dTypwbtQSbbt)54IqYebWOhPbo1rK0cbO)uuuzn9ql2JvWKkBqW0FozgHGuWPwUnjKuJKbk(NcNU(VAsyvp(rRaP)YapSgTeem4GaH2T48P4lhoCdFs9CLhqY)NcwzOgjduVEHqsrjXbSabcTBXm)vrLZRH)rRaP)YGAyQgE2e0taIA4F9oQz6H2AUTg(GP01qjCDL5wdyezU1qjFU6Ja1OSnTM8oPSgAOgc0jaMniQPJi14ARacVwrL10dTypwbtQSbbt)5qEU6JaoD9F1KWQE8Jwbs)LbEynAjiyyFdKtbpMnb9eGiHF9oQz6HwpSgTeem4uGup55Qpc41Rr9Tzm4AKZOLGhFBMesQrYaTOY51W)OvG0Fzqn5Ltn8SjONae1W)6DuZ0dTu6AOKG56kZTMoIudnAF4AyPFGASvKdIudeGcRae1GxZfZgP1iEetp06lQSMEOf7XkysLniy6phxesMiag9inWPoIKwia9NIIkRPhAXEScMuzdcM(ZjZieKco1YTjHKAKmqX)u401)vtcR6XpAfi9xg4H1OLGGH9nqof8y2e0taIe(17OMPhA9WA0sqWqnsgOE9cHKIsIdyMaH2TygCqGq7wC(u4mD4Gtmor)6DqWArLZRH)rRaP)YGAyQgwsa4mkDnSeUWwdIlqiNaQXQbVMlMnsRXzXieKc1qUm2AnwxbsnuYNR(iqn0qhrGAyjbGTn7DRPhAlQSMEOf7XkysLniy6phxesMiag9inWPoIKwia9NIIkRPhAXEScMuzdcM(ZjZieKcoD9F1KWQE8Jwbs)LbEynAjiyOMew1dbGTn7DRPGhwJwccgneskq5TEiaSTzVBnf8ei0UfNpfmCja3uwt4PWtEU6Jamei1tEU6JaEceA3Iz(JmfywU5McTasyxyfrESl0Ib91hzXrnQXia]] )
    

end