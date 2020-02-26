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

    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Assassination", 20200226, [[davS3bqiQipsiYLuvcAtOuFcvsqgfkPtHIAvOs0RqIMfQu3cvc7sWVejnmvL6yOiltKQNrfvttiQRHeyBQkP(gvuQXrffoNQsK1HkP6DOscyEQkCpvv7dL4FQkj5GibzHQk6HOsktuvjXfPII2OQss9rujPgjQKG6KurjwjsYlvvcmtujHUjvus7uizOQkHwksq9uu1ufjUkQKiBvvjQVIkjq7LQ(ROgSshMYIrQhRWKjCzWMv0NfXOrfNwLvJkjQxJKA2eDBHA3s9BidNkDCujjlhXZHA6KUUQSDu47cPgVq48IuwpsO5tf2VK9m5tXZlmf8rL(3P)93PN(xh(2zezN)ntEEnnxWZ7AdQTeWZ3wm45PqySHXxB6HApVRLMezcFkEEm6rgGNNJQUyUEQPMCkNhDyGItfFXpPPhQheBQPIV4rQEE63jvNL2t75fMc(Os)70)(70t)RdF7mIC6uWxYZBpLdI455VyUMNNZjeq7P98cap88rQwkegBy81MEOUwkmk5bfvrQwoQ6I56PMAYPCE0Hbkov8f)KMEOEqSPMk(IhPwufPA)QbAYZiPvB6Fn31M(3P)DrvrvKQLRXX6eaZ1lQIuTCrTuiHae1(fCdQRvr1kGP9KAT2qpuxR8WAOOks1Yf1sHHyedOw1ijGMVzOOks1Yf1sHecqulxjmuRZIcX4Azf9u8jGArZAXkysLdZbpV8Wk2NINhRGjvoGWNIpkM8P45H2OLGW)PNFqofiN55hOyAu2fDTIRLL)AJCTSRL1AvtcTg6lHJIvtsnqcqB0squRdh1QMeAnGF0kqMVeiaTrlbrTSRL1AvtcTgGiWwN8U2uiaTrlbrTSRDGqsbk6oarGTo5DTPqGaX214A)4V20R1HJADQw9guFDsTmxl7AzyKZOLqaFDIeYQrsaTwMRLDTQrsanOxmKvuwCqTCrTei2Ugxll1(1EEBOhQ98KNR(iGx9rLUpfpp0gTee(p98tej3qeQpkM882qpu75DrizMay0JmaV6JY5(u88qB0sq4)0ZpiNcKZ88gfbYPqaZHGEcqKXV5enm9qDaAJwcIAzxl9Bod4hTcK5lbcp3Azxl9Bod4hTcK5lbcei2Ugx7h1YuW51YUwNQfJZ0V5eeEEBOhQ98jgHGuWR(OISpfpp0gTee(p98tej3qeQpkM882qpu75DrizMay0JmaV6JIc8P45H2OLGW)PN3g6HApFIriif88dYPa5mpVAsO1a(rRaz(sGa0gTee1YUwwRLaX214A)OwMsVwhoQ1n(j1ZvEaP2p(RLPAzUw21Qgjb0GEXqwrzXb1Yf1sGy7ACTSuB6E(rAdjKvJKak2hftE1h1x7tXZdTrlbH)tp)GCkqoZZRMeAnGF0kqMVeiaTrlbrTSR1Oiqofcyoe0taIm(nNOHPhQdqB0squl7ADQwbsdKNR(iqqVb1xNul7AzyKZOLqaFDIeYQrsa1ZBd9qTNN8C1hb8QpkNTpfpp0gTee(p98tej3qeQpkM882qpu75DrizMay0JmaV6JYz4tXZdTrlbH)tpVn0d1E(eJqqk45hKtbYzEE1KqRb8JwbY8LabOnAjiQLDTgfbYPqaZHGEcqKXV5enm9qDaAJwcIAzxRAKeqd6fdzfLfhull1sGy7ACTSRL1AjqSDnU2pQLjNrToCuRt1IXz63CcIAz2ZpsBiHSAKeqX(OyYR(O(s(u88qB0sq4)0ZprKCdrO(OyYZBd9qTN3fHKzcGrpYa8QpkM(2NINhAJwcc)NE(b5uGCMNxnj0Aa)OvGmFjqaAJwcIAzxRAsO1aeb26K31McbOnAjiQLDTdeskqr3bicS1jVRnfcei2Ugx7h1YuTSR1LamYjdrGPa55Qpcul7AfinqEU6JabceBxJRLLAPGAPS2ixlxw7WnhBrKXUql882qpu75tmcbPGx9QNhWyOha2NIpkM8P45H2OLGW)PNFqofiN55HgijPf0lgYkkhBrull1YuTSR1PAfa9BodmGwaQAHNBTSRL1ADQwbsddupGwjMcI8uAXqM(r6GEdQVoPw216uT2qpuhgOEaTsmfe5P0IHW15P8s4O16WrTZNuMjWGJrsGSEXqTFuBYqeITiQLzpVn0d1E(bQhqRetbrEkTyWR(Os3NINhAJwcc)NE(b5uGCMNxa0V5mWaAbOQfEU1YUwwR1PAvtcTguue3itlnbeG2OLGOwhoQva0V5mOOiUrMwAci8CRLDTdumnk7IUwXbbmVXP1(XFTmvRdh1ka63CgyaTau1cei2Ugx7h)1Y031YCToCuREXqwrzXb1(XFTm9TN3g6HAppTeHez0mRCGm0qCAE1hLZ9P45H2OLGW)PNFqofiN55hiKuGIUdmGwaQAbceBxJR9JADEToCuRaOFZzGb0cqvl8CR1HJAvJKaAqVyiROS4GA)OwN)TN3g6HApFYZiIZ6mAMnkceKYXR(OISpfpp0gTee(p98dYPa5mp)uIqKAzTwwRvnscOb9IHSIYIdQLlQ15FxlZ1(fwRn0d15bcjfOO7AzUwwQDkrisTSwlR1Qgjb0GEXqwrzXb1Yf168VRLlQDGqsbk6oWaAbOQfiqSDnUwMR9lSwBOhQZdeskqr31YSN3g6HApFYZiIZ6mAMnkceKYXR(OOaFkEEOnAji8F65hKtbYzEESliLz1ijGIdtRZOzM6(ya4Az5V20R1HJAj2jYadO1Gje4W11YsTF931YUwObssA1(rTo7V982qpu75NOXddISrrGCkKPbl2R(O(AFkEEOnAji8F65hKtbYzEESliLz1ijGIdtRZOzM6(ya4Az5V20R1HJAj2jYadO1Gje4W11YsTF93EEBOhQ98UpYnt76KmT0WQx9r5S9P45H2OLGW)PNFqofiN55PFZzGadQLagNNiYacp3AD4Ow63CgiWGAjGX5jImG8a9AfibSAdQR9JAz6BpVn0d1EELdKFnn61I8ergGx9r5m8P45THEO2ZtoxxjKVoJDTb45H2OLGW)Px9r9L8P45THEO2ZhnIifmGRZeaJARhGNhAJwcc)NE1hftF7tXZdTrlbH)tp)GCkqoZZdnqssR2pQLc(Uw216uTdeskqr3bgqlavTWZ1ZBd9qTNpgIrK0YOzw(gNiliGfJ9QpkMyYNINhAJwcc)NE(b5uGCMNxnscOboGjvob3Hwll16m(UwhoQvnscOboGjvob3Hw7h)1M(316WrTQrsanOxmKvu2DO50)UwwQ15F75THEO2ZtaZ96K8uAXa2RE1ZlGP9KQpfFum5tXZdTrlbH)tp)GCkqoZZ7uTyfmPYbebtk982qpu75P(gu7vFuP7tXZBd9qTNhRGjvoEEOnAji8F6vFuo3NINhAJwcc)NEEKRNhdQN3g6HAppdJCgTe88mm5d88qdKK0ceib6APSwx0HrniY0sae4A5YAD21(fwlR1METCzTyxqkZCmSc1YSNNHrYTfdEEObssAzcKaDEGIPVgeE1hvK9P45H2OLGW)PNh565XG65THEO2ZZWiNrlbppdt(app2fKYSAKeqXHP1z0mtDFmaCTFuB6EEggj3wm45XxNiHSAKeq9QpkkWNINhAJwcc)NE(b5uGCMNhRGjvoGiqqjpWZBd9qTNFysz2g6H6S8WQNxEyn3wm45XkysLdi8QpQV2NINhAJwcc)NE(b5uGCMNN1ADQw1KqRHydRajBySHXxhG2OLGOwhoQvG0qIriifc6nO(6KAz2ZBd9qTNFysz2g6H6S8WQNxEyn3wm45hcSx9r5S9P45H2OLGW)PN3g6HAp)WKYSn0d1z5HvpV8WAUTyWZlqQx9r5m8P45H2OLGW)PN3g6HAp)WKYSn0d1z5HvpV8WAUTyWZlocmuV6J6l5tXZdTrlbH)tp)GCkqoZZdnqssliG5noTww(RLjkOwkRLHroJwcbObssAzcKaDEGIPVgeEEBOhQ98gzynKveHaT6vFum9TpfpVn0d1EEJmSgYUpjg88qB0sq4)0R(OyIjFkEEBOhQ98YlHJIZCLFIKyOvpp0gTee(p9QpkMs3NIN3g6HAppTLKrZSsUb1ypp0gTee(p9Qx98UeyGIPn1NIpkM8P45THEO2ZBUUY0YUOdJApp0gTee(p9QpQ09P45H2OLGW)PN3g6HApFSrOge5jIKfGPC88dYPa5mppXorgyaTgmHahUUwwQLjkWZ7sGbkM20mggOwG98uGx9r5CFkEEBOhQ98yfmPYXZdTrlbH)tV6JkY(u88qB0sq4)0Z3wm45nkI5yedNNOwZOz2ffnq882qpu75nkI5yedNNOwZOz2ffnq8QpkkWNIN3g6HApVlspu75H2OLGW)Px9QNxCeyO(u8rXKpfpp0gTee(p98dYPa5mp)aftJYUORvCTS8xBKRLYAvtcTgea4cKmwjMAjqCaAJwcIAzxlR1ka63CgyaTau1cp3AD4Owbq)MZGII4gzAPjGWZTwhoQfAGKKwqaZBCATF8xlR1cndOrXzxesMfW8gNwllFv1YATPtb1szTmmYz0sianqssltGeOZdum91GOwMRL5AD4OwNQLHroJwcb81jsiRgjb0AzUw21YATovRAsO1aeb26K31McbOnAjiQ1HJAhiKuGIUdqeyRtExBkeiqSDnUwwQn9Az2ZBd9qTNhAgqJI9QpQ09P45H2OLGW)PNh565XG65THEO2ZZWiNrlbppdt(ap)aftJYUORvCqaZBCATSult16WrTqdKK0ccyEJtR9J)AtNcQLYAzyKZOLqaAGKKwMajqNhOy6RbrToCuRt1YWiNrlHa(6ejKvJKaQNNHrYTfdE(hgYZtkbIx9r5CFkEEOnAji8F65hKtbYzEEgg5mAjeEyippPei1YUwJIa5uiadoORtY0sta4a0gTee1YUwSliLz1ijGIdtRZOzM6(ya4Az5V20RLYAzTwbq)MZadOfGQw45wlxwlR1YuTuwlR1AueiNcbyWbDDsMwAcahiwtDT)1YuTmxlZ1YSN3g6HAp)06mAMPUpga2R(OISpfpp0gTee(p98dYPa5mppdJCgTecpmKNNucKAzxlR1s)MZaNtiGotlnbGdy1guxll)1Y0xQwhoQL1ADQwxYHiNMwMGutpuxl7AXUGuMvJKakomToJMzQ7JbGRLL)AJCTuwlR1AueiNcbb6rlHSaHHaXAQRLLAtVwMRLYAXkysLdiceuYdQL5Az2ZBd9qTNFADgnZu3hda7vFuuGpfpp0gTee(p982qpu75NwNrZm19XaWE(b5uGCMNNHroJwcHhgYZtkbsTSRf7cszwnscO4W06mAMPUpgaUww(R15E(rAdjKvJKak2hftE1h1x7tXZdTrlbH)tp)GCkqoZZZWiNrlHWdd55jLaPw21YAT0V5mqlVwGpbeEU16WrTovRAsO1adOrXzYdZjaTrlbrTSR1PAnkcKtHGa9OLqwGWqaAJwcIAz2ZBd9qTNNwETaFcWR(OC2(u88qB0sq4)0ZBd9qTNp(PN0uWZpiNcKZ88mmYz0si8WqEEsjqQLDTyxqkZQrsafhMwNrZm19XaW1(xB6E(rAdjKvJKak2hftE1hLZWNINhAJwcc)NE(b5uGCMNNHroJwcHhgYZtkbIN3g6HApF8tpPPGx9QNFiW(u8rXKpfpp0gTee(p982qpu75nkI5yedNNOwZOz2ffnq88dYPa5mpVt1IvWKkhqemPSw21gByfizdJnm(6mbITRX1(x731YUwwRDGqsbk6oWaAbOQfiqSDnU2p(QQDGqsbk6oOOiUrMwAciqGy7ACTmx7h1Y031szTm9DTCzTax17CDbrWWCyynGZeJIisEGiMSw216uTcG(nNbgqlavTWZTw216uTcG(nNbffXnY0staHNRNVTyWZBueZXigoprTMrZSlkAG4vFuP7tXZdTrlbH)tp)GCkqoZZ7uTyfmPYbebtkRLDTcKgipx9rGGEdQVoPw21gByfizdJnm(6mbITRX1(x73EEBOhQ98dtkZ2qpuNLhw98YdR52IbppGXqpaSx9r5CFkEEOnAji8F65THEO2ZhBeQbrEIizbykhp)GCkqoZZtStKbgqRbtiWHNBTSRL1AvJKaAqVyiROS4GA)O2bkMgLDrxR4GaM340A5YAzkqb16WrTdumnk7IUwXbbmVXP1YYFTd3CSfrg7cTOwM98J0gsiRgjbuSpkM8QpQi7tXZdTrlbH)tp)GCkqoZZtStKbgqRbtiWHRRLLAD(31Yf1sStKbgqRbtiWbXJy6H6Azx7aftJYUORvCqaZBCATS8x7WnhBrKXUql882qpu75Jnc1GiprKSamLJx9rrb(u88qB0sq4)0ZJC98yq982qpu75zyKZOLGNNHjFGN3PAvtcTgWpAfiZxceG2OLGOwhoQ1PAnkcKtHaMdb9eGiJFZjAy6H6a0gTee16WrTcKgsmcbPqWn(j1ZvEaPwwQLPAzxlR1IDbPmRgjbuCyADgnZu3hdax7h1(116WrTov7aHKcu0DGH1hMt45wlZEEggj3wm45zaTau1Y4hTcK5lbYdulo9qTx9r91(u88qB0sq4)0ZJC98yq982qpu75zyKZOLGNNHjFGN3PAvtcTg6lHJIvtsnqcqB0squRdh16uTQjHwdqeyRtExBkeG2OLGOwhoQDGqsbk6oarGTo5DTPqGaX214A)OwkOwUO20RLlRvnj0AqaGlqYyLyQLaXbOnAji88mmsUTyWZZaAbOQL7lHJIvtsnqYdulo9qTx9r5S9P45H2OLGW)PNh565XG65THEO2ZZWiNrlbppdt(apVt1cCvVZ1febJIyogXW5jQ1mAMDrrdKAD4OwJIa5uiG5qqpbiY43CIgMEOoaTrlbrToCuRaOFZzGyuerYdeXKzbq)MZGafDxRdh1oqiPafDhmmhgwd4mXOiIKhiIjdei2Ugx7h1Y031YUwwRDGqsbk6oOOiUrMwAciqGy7ACTFult16WrTcG(nNbffXnY0staHNBTm75zyKCBXGNNb0cqvlprTMhOwC6HAV6JYz4tXZdTrlbH)tp)GCkqoZZ7uTyfmPYbebck5b1YUwbsdKNR(iqqVb1xNul7ADQwbq)MZadOfGQw45wl7AzyKZOLqGb0cqvlJF0kqMVeipqT40d11YUwgg5mAjeyaTau1Y9LWrXQjPgi5bQfNEOUw21YWiNrlHadOfGQwEIAnpqT40d1EEBOhQ98mGwaQAE1h1xYNINhAJwcc)NE(b5uGCMNxnj0AaIaBDY7AtHa0gTee1YUwwRvnj0AOVeokwnj1ajaTrlbrToCuRAsO1a(rRaz(sGa0gTee1YUwgg5mAjeWxNiHSAKeqRL5Azx7aftJYUORvCTS8x7WnhBrKXUqlQLDTdeskqr3bicS1jVRnfcei2Ugx7h1YuTSRL1ADQw1KqRb8JwbY8LabOnAjiQ1HJADQwJIa5uiG5qqpbiY43CIgMEOoaTrlbrToCuRaPHeJqqkeCJFs9CLhqQ9J)AzQwM982qpu75zy9H54vFum9Tpfpp0gTee(p98dYPa5mpVAsO1qFjCuSAsQbsaAJwcIAzxRt1QMeAnarGTo5DTPqaAJwcIAzx7aftJYUORvCTS8x7WnhBrKXUqlQLDTcG(nNbgqlavTWZ1ZBd9qTNNH1hMJx9rXet(u88qB0sq4)0ZJC98yq982qpu75zyKZOLGNNHjFGN3Oiqofcyoe0taIm(nNOHPhQdqB0squl7AzT2g1zmot)MtqKvJKakUww(RLPAD4OwSliLz1ijGIdtRZOzM6(ya4A)R151YCTSRL1AX4m9BobrwnscO4SrJyazxRfq8nQ9V2VR1HJAXUGuMvJKakomToJMzQ7JbGRLL)A)6Az2ZZWi52IbppgNzy9H5KhOwC6HAV6JIP09P45H2OLGW)PN3g6HApVlcjZeaJEKb45HiuILTy0RvpFKPap)erYneH6JIjV6JIjN7tXZdTrlbH)tp)GCkqoZZRMeAnGF0kqMVeiaTrlbrTSR1PAXkysLdiceuYdQLDTdeskqr3HeJqqkeEU1YUwwRLHroJwcbmoZW6dZjpqT40d116WrTovRrrGCkeWCiONaez8BordtpuhG2OLGOw21YATcKgsmcbPqGatcG5y0sOwhoQva0V5mWaAbOQfEU1YUwbsdjgHGui4g)K65kpGu7h)1YuTmxlZ1YU2bkMgLDrxR4GaM340Az5VwwRL1AzQwkRn9A5YAnkcKtHaMdb9eGiJFZjAy6H6a0gTee1YCTCzTyxqkZQrsafhMwNrZm19XaW1YCTS8vvBKRLDTe7ezGb0AWecC46AzPwMs3ZBd9qTNNH1hMJx9rXuK9P45H2OLGW)PNFqofiN55vtcTgInScKSHXggFDaAJwcIAzxRt1IvWKkhqemPSw21gByfizdJnm(6mbITRX1(XFTFxl7ADQwbsdKNR(iqGatcG5y0sOw21kqAiXieKcbceBxJRLLADETSRva0V5mWaAbOQfEU1YUwwR1PAvtcTguue3itlnbeG2OLGOwhoQva0V5mOOiUrMwAci8CRL5AzxlR16uTagd9ac0sesKrZSYbYqdXPfInUYisToCuRaOFZzGwIqImAMvoqgAioTWZTwM982qpu75zy9H54vFumrb(u88qB0sq4)0ZpiNcKZ88ovlwbtQCarWKYAzxRrrGCkeWCiONaez8BordtpuhG2OLGOw21kqAiXieKcbcmjaMJrlHAzxRaPHeJqqkeCJFs9CLhqQ9J)AzQw21oqX0OSl6AfheW8gNwll)1YKN3g6HAppMJjqrhdsHx9rX0x7tXZdTrlbH)tp)GCkqoZZlqAG8C1hbcei2Ugxll1g5APS2ixlxw7WnhBrKXUqlQLDTovRaPHeJqqkeiWKayogTe882qpu75HiWwN8U2uWR(OyYz7tXZdTrlbH)tp)GCkqoZZlqAG8C1hbc6nO(6KAzxlR16uTax17CDbrWOiMJrmCEIAnJMzxu0aPwhoQDGqsbk6oWaAbOQfiqSDnUwwQLPVRLzpVn0d1EEffXnY0staE1hftodFkEEOnAji8F65hKtbYzEE63CgOLiKq(WAGa2qR1HJAfa9BodmGwaQAHNRN3g6HApVlspu7vFum9L8P45H2OLGW)PNFqofiN55fa9BodmGwaQAHNRN3g6HAppTeHe55JKMx9rL(3(u88qB0sq4)0ZpiNcKZ88cG(nNbgqlavTWZ1ZBd9qTNNgiyGq91jE1hv6m5tXZdTrlbH)tp)GCkqoZZla63CgyaTau1cpxpVn0d1E(5raAjcj8QpQ0t3NINhAJwcc)NE(b5uGCMNxa0V5mWaAbOQfEUEEBOhQ98wpaSsmzEysPx9rLUZ9P45H2OLGW)PN3g6HApFIjHHjLabNPrO2ZpiNcKZ88deskqr3bgqlavTabITRX1YsTrMc88TfdE(etcdtkbcotJqTx9rLEK9P45H2OLGW)PN3g6HApVH5WWAaNjgfrK8armPNFqofiN55fa9BodeJIisEGiMmla63CgeOO7AD4Owbq)MZadOfGQwGaX214AzPwM(UwUO2ixlxwlWv9oxxqemkI5yedNNOwZOz2ffnqQ1HJAvJKaAqVyiROS4GA)O20)2Z3wm45nmhgwd4mXOiIKhiIj9QpQ0PaFkEEOnAji8F65THEO2ZpsBirkb13itlnS65hKtbYzE(ydRajBySHXxNjqSDnU2)A)Uw216uTcG(nNbgqlavTWZTw216uTcG(nNbffXnY0staHNBTSRL(nNHyigrslJMz5BCISGawmoiqr31YUwObssA1(rToJVRLDTcKgipx9rGabITRX1YsTr2ZdZjm0CBXGNFK2qIucQVrMwAy1R(Os)R9P45H2OLGW)PN3g6HApV8rOgi4814tCOhoNCt1ZpiNcKZ88cG(nNbgqlavTWZ1Z3wm45Lpc1abNVgFId9W5KBQE1hv6oBFkEEOnAji8F65THEO2ZlFyLGE4CcskGo7kFXwc45hKtbYzEEbq)MZadOfGQw4565Blg88YhwjOhoNGKcOZUYxSLaE1hv6odFkEEOnAji8F65THEO2ZNinXzkIGZXGWKYd1E(b5uGCMNxa0V5mWaAbOQfEUEEyoHHMBlg88jstCMIi4CmimP8qTx9rL(xYNINhAJwcc)NEEBOhQ98jstCMIi4mTjsap)GCkqoZZla63CgyaTau1cpxppmNWqZTfdE(ePjotreCM2ejGx9r58V9P45THEO2Z)Wq(uig75H2OLGW)Px9QNxGuFk(OyYNINhAJwcc)NEEKRNhdQN3g6HAppdJCgTe88mm5d88UKdronTmbPMEOUw21IDbPmRgjbuCyADgnZu3hdaxll168AzxlR1kqAiXieKcbceBxJR9JAhiKuGIUdjgHGuiiEetpuxRdh16IomQbrMwcGaxll1sb1YSNNHrYTfdEEm1NBEK2qc5eJqqk4vFuP7tXZdTrlbH)tppY1ZJb1ZBd9qTNNHroJwcEEgM8bEExYHiNMwMGutpuxl7AXUGuMvJKakomToJMzQ7JbGRLLADETSRL1Afa9BodkkIBKPLMacp3AD4OwwR1fDyudImTeabUwwQLcQLDTovRrrGCkeWdO1mAMPLiKiaTrlbrTmxlZEEggj3wm45XuFU5rAdjKjpx9raV6JY5(u88qB0sq4)0ZJC98yq982qpu75zyKZOLGNNHjFGNxa0V5mWaAbOQfEU1YUwwRva0V5mOOiUrMwAci8CR1HJAJnScKSHXggFDMaX214AzP2VRL5AzxRaPbYZvFeiqGy7ACTSuB6EEggj3wm45XuFUzYZvFeWR(OISpfpp0gTee(p98dYPa5mpVAsO1aeb26K31McbOnAjiQLDTSwlR1oqX0OSl6Afxll)1oCZXwezSl0IAzx7aHKcu0DaIaBDY7AtHabITRX1(rTmvlZ16WrTSwRt1Q3G6RtQLDTSwREXqTSultFxRdh1oqX0OSl6Afxll)1METmxlZ1YSN3g6HApp55Qpc4vFuuGpfpp0gTee(p98tej3qeQpkM882qpu75DrizMay0JmaV6J6R9P45H2OLGW)PNFqofiN55zTwNQvnj0Aa)OvGmFjqaAJwcIAD4OwNQL1AhiKuGIUdmS(WCcp3Azx7aHKcu0DGb0cqvlqGy7ACTF8xBKRL5AzUw21oqX0OSl6AfheW8gNwll)1YuTuwRZRLlRL1AnkcKtHaMdb9eGiJFZjAy6H6a0gTee1YU2bcjfOO7adRpmNWZTwMRLDTeysamhJwc1YUwwR1n(j1ZvEaP2p(RLPAD4OwceBxJR9J)A1BqDwVyOw21IDbPmRgjbuCyADgnZu3hdaxll)168APSwJIa5uiG5qqpbiY43CIgMEOoaTrlbrTmxl7AzTwNQfIaBDY7AtbrToCulbITRX1(XFT6nOoRxmulxwB61YUwSliLz1ijGIdtRZOzM6(ya4Az5VwNxlL1AueiNcbmhc6jarg)Mt0W0d1bOnAjiQL5AzxRt1IXz63CcIAzxlR1Qgjb0GEXqwrzXb1Yf1sGy7ACTmxll1g5AzxlR1gByfizdJnm(6mbITRX1(x7316WrTovREdQVoPw21AueiNcbmhc6jarg)Mt0W0d1bOnAjiQLzpVn0d1E(eJqqk4vFuoBFkEEOnAji8F65NisUHiuFum55THEO2Z7IqYmbWOhzaE1hLZWNINhAJwcc)NEEBOhQ98jgHGuWZpiNcKZ88ovldJCgTecyQp38iTHeYjgHGuOw21YATovRAsO1a(rRaz(sGa0gTee16WrTovlR1oqiPafDhyy9H5eEU1YU2bcjfOO7adOfGQwGaX214A)4V2ixlZ1YCTSRDGIPrzx01koiG5noTww(RLPAPSwNxlxwlR1AueiNcbmhc6jarg)Mt0W0d1bOnAjiQLDTdeskqr3bgwFyoHNBTmxl7AjWKayogTeQLDTSwRB8tQNR8asTF8xlt16WrTei2Ugx7h)1Q3G6SEXqTSRf7cszwnscO4W06mAMPUpgaUww(R151szTgfbYPqaZHGEcqKXV5enm9qDaAJwcIAzUw21YATovleb26K31McIAD4OwceBxJR9J)A1BqDwVyOwUS20RLDTyxqkZQrsafhMwNrZm19XaW1YYFToVwkR1Oiqofcyoe0taIm(nNOHPhQdqB0squlZ1YUwNQfJZ0V5ee1YUwwRvnscOb9IHSIYIdQLlQLaX214AzUwwQLP0RLDTSwBSHvGKnm2W4RZei2Ugx7FTFxRdh16uT6nO(6KAzxRrrGCkeWCiONaez8BordtpuhG2OLGOwM98J0gsiRgjbuSpkM8QpQVKpfpp0gTee(p98dYPa5mpp2fKYSAKeqX1YYFTPxl7AjqSDnU2pQn9APSwwRf7cszwnscO4Az5VwkOwMRLDTdumnk7IUwX1YYFTr2ZBd9qTNFqUymQZke7cy1R(Oy6BFkEEOnAji8F65hKtbYzEENQLHroJwcbm1NBM8C1hbQLDTdumnk7IUwX1YYFTrUw21sGjbWCmAjul7AzTw34Nupx5bKA)4VwMQ1HJAjqSDnU2p(RvVb1z9IHAzxl2fKYSAKeqXHP1z0mtDFmaCTS8xRZRLYAnkcKtHaMdb9eGiJFZjAy6H6a0gTee1YCTSRL1ADQwicS1jVRnfe16WrTei2Ugx7h)1Q3G6SEXqTCzTPxl7AXUGuMvJKakomToJMzQ7JbGRLL)ADETuwRrrGCkeWCiONaez8BordtpuhG2OLGOwMRLDTQrsanOxmKvuwCqTCrTei2Ugxll1gzpVn0d1EEYZvFeWR(OyIjFkEEOnAji8F65THEO2ZtEU6JaE(b5uGCMN3PAzyKZOLqat95MhPnKqM8C1hbQLDTovldJCgTecyQp3m55Qpcul7AhOyAu2fDTIRLL)AJCTSRLatcG5y0sOw21YATUXpPEUYdi1(XFTmvRdh1sGy7ACTF8xREdQZ6fd1YUwSliLz1ijGIdtRZOzM6(ya4Az5VwNxlL1AueiNcbmhc6jarg)Mt0W0d1bOnAjiQL5AzxlR16uTqeyRtExBkiQ1HJAjqSDnU2p(RvVb1z9IHA5YAtVw21IDbPmRgjbuCyADgnZu3hdaxll)168APSwJIa5uiG5qqpbiY43CIgMEOoaTrlbrTmxl7AvJKaAqVyiROS4GA5IAjqSDnUwwQnYE(rAdjKvJKak2hftE1RE1ZZai4d1(Os)70)(70zkDpF0gPVob75DwIDrefe16SR1g6H6ALhwXHIkpp2fg(OsNc(sEExcAEsWZhPAPqySHXxB6H6APWOKhuufPA5OQlMRNAQjNY5rhgO4uXx8tA6H6bXMAQ4lEKArvKQ9RgOjpJKwTP)1CxB6FN(3fvfvrQwUghRtamxVOks1Yf1sHecqu7xWnOUwfvRaM2tQ1Ad9qDTYdRHIQivlxulfgIrmGAvJKaA(MHIQivlxulfsiarTCLWqTolkeJRLv0tXNaQfnRfRGjvomhkQkQIuToZiGXtbrT0WerGAhOyAtRLgsUghQLcngGRIRTrnxWXiXZNSwBOhQX1IAzAHIQivRn0d14GlbgOyAt)NsdtDrvKQ1g6HACWLadumTPu(NQ9sIHwn9qDrvKQ1g6HACWLadumTPu(N6eHefvrQw(2CXCqATe7e1s)MtqulwnfxlnmreO2bkM20APHKRX1ATOwxcWfUivVoP2dxRa1qOOks1Ad9qno4sGbkM2uk)tf3MlMdsZy1uCrLn0d14GlbgOyAtP8pvZ1vMw2fDyuxuzd9qno4sGbkM2uk)tn2iudI8erYcWuoC7sGbkM20mggOwG)PaUV5pXorgyaTgmHahUMfMOGIkBOhQXbxcmqX0Ms5FQyfmPYPOYg6HACWLadumTPu(N6dd5tHyUBlg(nkI5yedNNOwZOz2ffnqkQSHEOghCjWaftBkL)P6I0d1fvfvrQwNzeW4PGOwGbqsRw9IHAvoqT2qrKApCTgd7KgTecfvrQwkmGvWKkNAVzTUim(OLqTS2OAz8KnqmAjul0q8b4AVU2bkM2uMlQSHEOg)t9nOM7B(7ewbtQCarWKYIkBOhQXu(NkwbtQCkQSHEOgt5FQmmYz0sG72IHFObssAzcKaDEGIPVgeCZWKp4hAGKKwGajqtPl6WOgezAjacmx6S)cznDUe7cszMJHvG5IkBOhQXu(NkdJCgTe4UTy4hFDIeYQrsaLBgM8b)yxqkZQrsafhMwNrZm19XaWFKErLn0d1yk)tDysz2g6H6S8Wk3Tfd)yfmPYbeCFZFScMu5aIabL8GIkBOhQXu(N6WKYSn0d1z5HvUBlg(hcm338NvNutcTgInScKSHXggFDaAJwcchoeinKyecsHGEdQVoH5IkBOhQXu(N6WKYSn0d1z5HvUBlg(fiTOYg6HAmL)PomPmBd9qDwEyL72IHFXrGHwuzd9qnMY)unYWAiRicbAL7B(dnqssliG5noLLFMOakzyKZOLqaAGKKwMajqNhOy6RbrrLn0d1yk)t1idRHS7tIHIkBOhQXu(NQ8s4O4mx5NijgATOYg6HAmL)PsBjz0mRKBqnUOQOks1Y1qiPafDJlQSHEOghgc8)dd5tHyUBlg(nkI5yedNNOwZOz2ffnq4(M)oHvWKkhqemPKDSHvGKnm2W4RZei2Ug))nBwhiKuGIUdmGwaQAbceBxJ)4RAGqsbk6oOOiUrMwAciqGy7AmZFW03uY03CjWv9oxxqemmhgwd4mXOiIKhiIjz7KaOFZzGb0cqvl8Cz7KaOFZzqrrCJmT0eq45wuzd9qnomeyk)tDysz2g6H6S8Wk3Tfd)agd9aWCFZFNWkysLdicMuYwG0a55Qpce0Bq91jSJnScKSHXggFDMaX214)VlQIuTolZAnHaxRrGAFUCxlUpxOwLdulQHAJ(uo1krrdyT2us5ReQLRegQnAoqxRiTRtQDAyfi1QCSUwU2xSwbmVXP1Ii1g9PCqpTwRtRwU2xmuuzd9qnomeyk)tn2iudI8erYcWuoCpsBiHSAKeqX)mX9n)j2jYadO1Gje4WZLnRQrsanOxmKvuwCWhdumnk7IUwXbbmVXPCjtbkWHJbkMgLDrxR4GaM34uw(hU5ylIm2fAbZfvrQwNLzTnQwtiW1g9jL1koO2OpLZ11QCGABicTwN)nM7AFyOwN15xPwuxlncJRn6t5GEATwNwTCTVyOOYg6HACyiWu(NASrOge5jIKfGPC4(M)e7ezGb0AWecC4AwC(3CbXorgyaTgmHahepIPhQzpqX0OSl6AfheW8gNYY)WnhBrKXUqlkQIuTFzOfGQwTsuYnmzTdulo9qTjX1sByqulQRD8ieO1AXUWOOYg6HACyiWu(NkdJCgTe4UTy4Nb0cqvlJF0kqMVeipqT40d1CZWKp43j1KqRb8JwbY8LabOnAjiC4WjJIa5uiG5qqpbiY43CIgMEOoaTrlbHdhcKgsmcbPqWn(j1ZvEaHfMyZk2fKYSAKeqXHP1z0mtDFma8hFTdhonqiPafDhyy9H5eEUmxuzd9qnomeyk)tLHroJwcC3wm8ZaAbOQL7lHJIvtsnqYdulo9qn3mm5d(Dsnj0AOVeokwnj1ajaTrlbHdhoPMeAnarGTo5DTPqaAJwcchogiKuGIUdqeyRtExBkeiqSDn(dkGlsNlvtcTgea4cKmwjMAjqCaAJwcIIkBOhQXHHat5FQmmYz0sG72IHFgg5mAjWDBXWpdOfGQwEIAnpqT40d1CZWKp43jGR6DUUGiyueZXigoprTMrZSlkAG4WHrrGCkeWCiONaez8BordtpuhG2OLGWHdbq)MZaXOiIKhiIjZcG(nNbbk62HJbcjfOO7GH5WWAaNjgfrK8armzGaX214py6B2SoqiPafDhuue3itlnbeiqSDn(dMC4qa0V5mOOiUrMwAci8CzUOYg6HACyiWu(NkdOfGQg3383jScMu5aIabL8a2cKgipx9rGGEdQVoHTtcG(nNbgqlavTWZLndJCgTecmGwaQAz8JwbY8La5bQfNEOMndJCgTecmGwaQA5(s4Oy1KudK8a1ItpuZMHroJwcbgqlavT8e1AEGAXPhQlQIuTFzRpmNAJ(uo16mJaNulL1YAuxchfRMKAGWDTisT8pAfiZxculQLPvlQRLPuyMRxRZQfXf)IRLR9fR1ArToZiWj1satKwTteP2gIqRLRMR9vkQSHEOghgcmL)PYW6dZH7B(RMeAnarGTo5DTPqaAJwcc2SQMeAn0xchfRMKAGeG2OLGWHd1KqRb8JwbY8LabOnAjiyZWiNrlHa(6ejKvJKakZShOyAu2fDTIz5F4MJTiYyxOfShiKuGIUdqeyRtExBkeiqSDn(dMyZQtQjHwd4hTcK5lbcqB0sq4WHtgfbYPqaZHGEcqKXV5enm9qDaAJwcchoeinKyecsHGB8tQNR8aYh)mXCrvKQ9lB9H5uB0NYP2OUeokwnj1aPwkRnkuToZiWjC9ADwTiU4xCTCTVyTwlQ9ldTau1Q95wuzd9qnomeyk)tLH1hMd338xnj0AOVeokwnj1ajaTrlbbBNutcTgGiWwN8U2uiaTrlbb7bkMgLDrxRyw(hU5ylIm2fAbBbq)MZadOfGQw45wufPA5bO25tkRDGIJHwRf11Yrvxmxp1utoLZJomqXPsHngqZbjfkxKcxlvkmk5bPg9r9LkfcJnm(AtpuZfuOVixrUGcdyWidoHIkBOhQXHHat5FQmmYz0sG72IHFmoZW6dZjpqT40d1CZWKp43Oiqofcyoe0taIm(nNOHPhQdqB0sqWM1g1zmot)MtqKvJKakMLFMC4a7cszwnscO4W06mAMPUpga(35mZMvmot)MtqKvJKakoB0igq21AbeFJ)VD4a7cszwnscO4W06mAMPUpgaML)VM5IkBOhQXHHat5FQUiKmtam6rga3tej3qe6ptCdrOelBXOxR)rMckQSHEOghgcmL)PYW6dZH7B(RMeAnGF0kqMVeiaTrlbbBNWkysLdiceuYdypqiPafDhsmcbPq45YMvgg5mAjeW4mdRpmN8a1Itpu7WHtgfbYPqaZHGEcqKXV5enm9qDaAJwcc2SkqAiXieKcbcmjaMJrlbhoea9BodmGwaQAHNlBbsdjgHGui4g)K65kpG8XptmZm7bkMgLDrxR4GaM34uw(zLvMOmDU0Oiqofcyoe0taIm(nNOHPhQdqB0sqWmxIDbPmRgjbuCyADgnZu3hdaZmlFvrMnXorgyaTgmHahUMfMsVOks1(LT(WCQn6t5uRZQHvGulfcJn81C9AJcvlwbtQCQ1ArTnQwBOhdOwNvkuT0V5K7APWpx9rGABKw711sGjbWCQLyDcWDTIh56KA)Yqlavnkt5tURv8ixNu7NsesulGXqtXAVzTgd7KgTecfv2qpuJddbMY)uzy9H5W9n)vtcTgInScKSHXggFDaAJwcc2oHvWKkhqemPKDSHvGKnm2W4RZei2Ug)X)3SDsG0a55QpceiWKayogTeylqAiXieKcbceBxJzX5Sfa9BodmGwaQAHNlBwDsnj0AqrrCJmT0eqaAJwcchoea9BodkkIBKPLMacpxMzZQtagd9ac0sesKrZSYbYqdXPfInUYiIdhcG(nNbAjcjYOzw5azOH40cpxMlQIuT8Cmbk6yqkQDIi1YZHGEcqul)Bordtpuxuzd9qnomeyk)tfZXeOOJbPG7B(7ewbtQCarWKs2gfbYPqaZHGEcqKXV5enm9qDaAJwcc2cKgsmcbPqGatcG5y0sGTaPHeJqqkeCJFs9CLhq(4Nj2dumnk7IUwXbbmVXPS8ZurvKQ1zgb26K31Mc1gnhORLgPCQLc)C1hbQ1ArTC1gHGuOwJa1(CRDIi1krDsTqJEjCkQSHEOghgcmL)PcrGTo5DTPa338xG0a55QpceiqSDnMLitzK5YHBo2IiJDHwW2jbsdjgHGuiqGjbWCmAjuuzd9qnomeyk)tvrrCJmT0ea338xG0a55Qpce0Bq91jSz1jGR6DUUGiyueZXigoprTMrZSlkAG4WXaHKcu0DGb0cqvlqGy7Amlm9nZfv2qpuJddbMY)uDr6HAUV5p9Bod0sesiFynqaBOoCia63CgyaTau1cp3IkBOhQXHHat5FQ0sesKNpsACFZFbq)MZadOfGQw45wuzd9qnomeyk)tLgiyGq91jCFZFbq)MZadOfGQw45wuzd9qnomeyk)tDEeGwIqcUV5VaOFZzGb0cqvl8ClQSHEOghgcmL)PA9aWkXK5HjLCFZFbq)MZadOfGQw45wuzd9qnomeyk)t9HH8Pqm3Tfd)jMegMuceCMgHAUV5)aHKcu0DGb0cqvlqGy7AmlrMckQSHEOghgcmL)P(Wq(uiM72IHFdZHH1aotmkIi5bIysUV5VaOFZzGyuerYdeXKzbq)MZGafD7WHaOFZzGb0cqvlqGy7Amlm9nxezUe4QENRlicgfXCmIHZtuRz0m7IIgioCOgjb0GEXqwrzXbFK(3fv2qpuJddbMY)uFyiFkeZnmNWqZTfd)J0gsKsq9nY0sdRCFZ)ydRajBySHXxNjqSDn()B2oja63CgyaTau1cpx2oja63Cguue3itlnbeEUSPFZzigIrK0YOzw(gNiliGfJdcu0nBObssAF4m(MTaPbYZvFeiqGy7AmlrUOYg6HACyiWu(N6dd5tHyUBlg(Lpc1abNVgFId9W5KBQCFZFbq)MZadOfGQw45wuzd9qnomeyk)t9HH8Pqm3Tfd)YhwjOhoNGKcOZUYxSLaCFZFbq)MZadOfGQw45wuzd9qnomeyk)t9HH8Pqm3WCcdn3wm8NinXzkIGZXGWKYd1CFZFbq)MZadOfGQw45wuzd9qnomeyk)t9HH8Pqm3WCcdn3wm8NinXzkIGZ0Mib4(M)cG(nNbgqlavTWZTOks1(vGP9KATttkPTb11orKAFyJwc1EkeJ561Yvcd1I6AhiKuGIUdfv2qpuJddbMY)uFyiFkeJlQkQIuTFLJadTwHfBjqTg9jp9aCrvKQ1z2mGgfxRP1gzkRLvkGYAJ(uo1(v4zUwU2xmuRZsCmiotbzA1I6AtNYAvJKakM7AJ(uo1(LHwaQACxlIuB0NYP2u(KRa1Iuoaj6dd1gTDATtePwmkgQfAGKKwOwkKeJQnA70AVzToZiWj1oqX0OApCTdu81j1(Cdfv2qpuJdIJad9hAgqJI5(M)dumnk7IUwXS8hzkvtcTgea4cKmwjMAjqCaAJwcc2Ska63CgyaTau1cpxhoea9BodkkIBKPLMacpxhoGgijPfeW8gN(XpRqZaAuC2fHKzbmVXPS8vXA6uaLmmYz0sianqssltGeOZdum91GGzMD4Wjgg5mAjeWxNiHSAKeqzMnRoPMeAnarGTo5DTPqaAJwcchogiKuGIUdqeyRtExBkeiqSDnML0zUOYg6HACqCeyOu(NkdJCgTe4UTy4)HH88KsGWndt(G)bkMgLDrxR4GaM34uwyYHdObssAbbmVXPF8NofqjdJCgTecqdKK0Yeib68aftFniC4Wjgg5mAjeWxNiHSAKeqlQIuTCf8uo16mhCqxNu7NstayUR9R26ArZA)c6JbGR10AtNYAvJKakM7ArKADoxezkRvnscO4AJMd01(LHwaQA1E4AFUfv2qpuJdIJadLY)uNwNrZm19XaWCFZFgg5mAjeEyippPeiSnkcKtHam4GUojtlnbGdqB0sqWg7cszwnscO4W06mAMPUpgaML)0PKvbq)MZadOfGQw45YLSYeLSAueiNcbyWbDDsMwAcahiwt9ptmZmZfvrQ2VARRfnR9lOpgaUwtRLPVeL1IvBqnUw0SwUcFcb01(P0eaUwePwlXUgR1gzkRLvkGYAJ(uo1(vqpAju7xbHbMRvnscO4qrLn0d14G4iWqP8p1P1z0mtDFmam338NHroJwcHhgYZtkbcBwPFZzGZjeqNPLMaWbSAdQz5NPVKdhS6Kl5qKttltqQPhQzJDbPmRgjbuCyADgnZu3hdaZYFKPKvJIa5uiiqpAjKfimeiwtnlPZmLyfmPYbebck5bmZCrvKQ9R26ArZA)c6JbGRvr1AUUY0Q9RaMqMwTFr0HrDT3S2RTHEmGArDTwNwTQrsaTwtR151QgjbuCOOYg6HACqCeyOu(N606mAMPUpgaM7rAdjKvJKak(NjUV5pdJCgTecpmKNNuce2yxqkZQrsafhMwNrZm19XaWS878IkBOhQXbXrGHs5FQ0YRf4taCFZFgg5mAjeEyippPeiSzL(nNbA51c8jGWZ1HdNutcTgyankotEyobOnAjiy7KrrGCkeeOhTeYcegcqB0sqWCrvKQnfJMlCwF6jnfQvr1AUUY0Q9RaMqMwTFr0HrDTMwB61QgjbuCrLn0d14G4iWqP8p14NEstbUhPnKqwnscO4FM4(M)mmYz0si8WqEEsjqyJDbPmRgjbuCyADgnZu3hda)NErLn0d14G4iWqP8p14NEstbUV5pdJCgTecpmKNNucKIQIQiv7xXITeOwedGuREXqTg9jp9aCrvKQLR4fFATC1gHGuaxlQRTrnx4sUyIrsRw1ijGIRDIi1QCGADjhICAA1sqQPhQR9M1sbuwlTeabUwJa1AscyI0Q95wuzd9qnoiq6pdJCgTe4UTy4ht95MhPnKqoXieKcCZWKp43LCiYPPLji10d1SXUGuMvJKakomToJMzQ7JbGzX5SzvG0qIriifcei2Ug)XaHKcu0DiXieKcbXJy6HAhoCrhg1GitlbqGzHcyUOks1Yv8IpTwk8ZvFeaxlQRTrnx4sUyIrsRw1ijGIRDIi1QCGADjhICAA1sqQPhQR9M1sbuwlTeabUwJa1AscyI0Q95wuzd9qnoiqkL)PYWiNrlbUBlg(XuFU5rAdjKjpx9raUzyYh87soe500YeKA6HA2yxqkZQrsafhMwNrZm19XaWS4C2Ska63Cguue3itlnbeEUoCWQl6WOgezAjacmluaBNmkcKtHaEaTMrZmTeHebOnAjiyM5IQivlxXl(0APWpx9raCT3S2Vm0cqvJYuqrCJA)uAcivNvdRaPwkegBy811E4AFU1ATO2OHA5ymGAtNYAXWa1cCTsyQ1I6AvoqTu4NR(iqTFfukfv2qpuJdcKs5FQmmYz0sG72IHFm1NBM8C1hb4MHjFWVaOFZzGb0cqvl8CzZQaOFZzqrrCJmT0eq456WrSHvGKnm2W4RZei2UgZY3mZwG0a55QpceiqSDnML0lQIuT8UW4mzTu4NR(iqTyqFU1orKADMrGtkQSHEOgheiLY)ujpx9raUV5VAsO1aeb26K31McbOnAjiyZkRdumnk7IUwXS8pCZXwezSl0c2deskqr3bicS1jVRnfcei2Ug)btm7WbRoP3G6RtyZQEXalm9Tdhdumnk7IUwXS8NoZmZCrvKQLR2ieKc1(CPgaxUR1KyuTk5aCTkQ2hgQ90AnCTwTyxyCMS2eObIPisTtePwLduR0WATCTVyT0WerGATANxFyoaPOYg6HACqGuk)t1fHKzcGrpYa4EIi5gIq)zQOYg6HACqGuk)tnXieKcCFZFwDsnj0Aa)OvGmFjqaAJwcchoCI1bcjfOO7adRpmNWZL9aHKcu0DGb0cqvlqGy7A8h)rMzMzpqX0OSl6AfheW8gNYYptu6CUKvJIa5uiG5qqpbiY43CIgMEOoaTrlbb7bcjfOO7adRpmNWZLz2eysamhJwcSz1n(j1ZvEa5JFMC4GaX214p(1BqDwVyGn2fKYSAKeqXHP1z0mtDFmaml)oNsJIa5uiG5qqpbiY43CIgMEOoaTrlbbZSz1jicS1jVRnfeoCqGy7A8h)6nOoRxmWLPZg7cszwnscO4W06mAMPUpgaMLFNtPrrGCkeWCiONaez8BordtpuhG2OLGGz2oHXz63Ccc2SQgjb0GEXqwrzXbCbbITRXmZsKzZASHvGKnm2W4RZei2Ug))TdhoP3G6RtyBueiNcbmhc6jarg)Mt0W0d1bOnAjiyUOYg6HACqGuk)t1fHKzcGrpYa4EIi5gIq)zQOYg6HACqGuk)tnXieKcCpsBiHSAKeqX)mX9n)DIHroJwcbm1NBEK2qc5eJqqkWMvNutcTgWpAfiZxceG2OLGWHdNyDGqsbk6oWW6dZj8CzpqiPafDhyaTau1cei2Ug)XFKzMz2dumnk7IUwXbbmVXPS8ZeLoNlz1Oiqofcyoe0taIm(nNOHPhQdqB0sqWEGqsbk6oWW6dZj8CzMnbMeaZXOLaBwDJFs9CLhq(4NjhoiqSDn(JF9guN1lgyJDbPmRgjbuCyADgnZu3hdaZYVZP0Oiqofcyoe0taIm(nNOHPhQdqB0sqWmBwDcIaBDY7AtbHdhei2Ug)XVEdQZ6fdCz6SXUGuMvJKakomToJMzQ7JbGz535uAueiNcbmhc6jarg)Mt0W0d1bOnAjiyMTtyCM(nNGGnRQrsanOxmKvuwCaxqGy7AmZSWu6Szn2WkqYggBy81zceBxJ))2HdN0Bq91jSnkcKtHaMdb9eGiJFZjAy6H6a0gTeemxufPA5AKlgJ6AtbIDbSwlQLPvlQRn(j1Zvc1QgjbuCTMwBKPSwU2xS2O5aDTKx3xNul6P1EDTPJRL1NBTkQ2ixRAKeqXmxlIuRZX1YkfqzTQrsafZCrLn0d14GaPu(N6GCXyuNvi2fWk338h7cszwnscOyw(tNnbITRXFKoLSIDbPmRgjbuml)uaZShOyAu2fDTIz5pYfvrQ2VaaCR95wlf(5QpcuRP1gzkRf11AszTQrsafxlRrZb6ALhJRtQvI6KAHg9s4uR1IABKwlUnxmhKYCrLn0d14GaPu(Nk55QpcW9n)DIHroJwcbm1NBM8C1hbypqX0OSl6AfZYFKztGjbWCmAjWMv34Nupx5bKp(zYHdceBxJ)4xVb1z9Ib2yxqkZQrsafhMwNrZm19XaWS87CknkcKtHaMdb9eGiJFZjAy6H6a0gTeemZMvNGiWwN8U2uq4WbbITRXF8R3G6SEXaxMoBSliLz1ijGIdtRZOzM6(yayw(DoLgfbYPqaZHGEcqKXV5enm9qDaAJwccMzRgjb0GEXqwrzXbCbbITRXSe5IkBOhQXbbsP8pvYZvFeG7rAdjKvJKak(NjUV5VtmmYz0siGP(CZJ0gsitEU6JaSDIHroJwcbm1NBM8C1hbypqX0OSl6AfZYFKztGjbWCmAjWMv34Nupx5bKp(zYHdceBxJ)4xVb1z9Ib2yxqkZQrsafhMwNrZm19XaWS87CknkcKtHaMdb9eGiJFZjAy6H6a0gTeemZMvNGiWwN8U2uq4WbbITRXF8R3G6SEXaxMoBSliLz1ijGIdtRZOzM6(yayw(DoLgfbYPqaZHGEcqKXV5enm9qDaAJwccMzRgjb0GEXqwrzXbCbbITRXSe5IQIQivRZeJHEa4IkBOhQXbaJHEa4)bQhqRetbrEkTyG7B(dnqsslOxmKvuo2IGfMy7KaOFZzGb0cqvl8CzZQtcKggOEaTsmfe5P0IHm9J0b9guFDcBNSHEOomq9aALykiYtPfdHRZt5LWrD4y(KYmbgCmscK1lg(izicXwemxufPAPqYOT0W1(WqTFkrirTrFkNA)YqlavTAFUHAPqsmQ2hgQn6t5uBkFw7ZTwAyIiqTwTZRpmhGulR3Sw1KqRGG5AnCTsuNuRHR90AjVgx7erQLPVX1kEKRtQ9ldTau1cfv2qpuJdagd9aWu(NkTeHez0mRCGm0qCACFZFbq)MZadOfGQw45YMvNutcTguue3itlnbeG2OLGWHdbq)MZGII4gzAPjGWZL9aftJYUORvCqaZBC6h)m5WHaOFZzGb0cqvlqGy7A8h)m9nZoCOxmKvuwCWh)m9DrvKQLcPke7Q1QOAn5L01Yv)mI4SU2OpLtTFzOfGQwTgUwjQtQ1W1EATrJAUcP1sa8tQ1EDTse(6KATANpPKlyyYhu7WWATigaPwLdulbITRVoPwXJy6H6ArZAvoqTZlHJwuzd9qnoaym0dat5FQjpJioRZOz2OiqqkhUV5)aHKcu0DGb0cqvlqGy7A8ho3Hdbq)MZadOfGQw456WHAKeqd6fdzfLfh8HZ)UOYg6HACaWyOhaMY)utEgrCwNrZSrrGGuoCFZ)PeHiSYQAKeqd6fdzfLfhWfo)BM)chiKuGIUzMLPeHiSYQAKeqd6fdzfLfhWfo)BUyGqsbk6oWaAbOQfiqSDnM5VWbcjfOOBMlQSHEOghamg6bGP8p1jA8WGiBueiNczAWI5(M)yxqkZQrsafhMwNrZm19XaWS8NUdhe7ezGb0AWecC4Aw(6Vzdnqss7dN93fv2qpuJdagd9aWu(NQ7JCZ0UojtlnSY9n)XUGuMvJKakomToJMzQ7JbGz5pDhoi2jYadO1Gje4W1S81Fxuzd9qnoaym0dat5FQkhi)AA0Rf5jImaUV5p9BodeyqTeW48ergq456Wb9BodeyqTeW48ergqEGETcKawTb1FW03fv2qpuJdagd9aWu(Nk5CDLq(6m21gqrLn0d14aGXqpamL)PgnIifmGRZeaJARhqrLn0d14aGXqpamL)PgdXisAz0mlFJtKfeWIXCFZFObssAFqbFZ2PbcjfOO7adOfGQw45wuzd9qnoaym0dat5FQeWCVojpLwmG5(M)QrsanWbmPYj4ouwCgF7WHAKeqdCatQCcUd9J)0)2Hd1ijGg0lgYkk7o0C6FZIZ)UOQOks1YRGjvoGOwk0qpuJlQIuTrDjCWQjPgiCxlIul)JwP0zgboPwuxltPW1RLVnxmhKwlf(5Qpcuuzd9qnoGvWKkhq8tEU6JaCFZ)bkMgLDrxRyw(JmBwvtcTg6lHJIvtsnqcqB0sq4WHAsO1a(rRaz(sGa0gTeeSzvnj0AaIaBDY7AtHa0gTeeShiKuGIUdqeyRtExBkeiqSDn(J)0D4Wj9guFDcZSzyKZOLqaFDIeYQrsaLz2QrsanOxmKvuwCaxqGy7AmlFDrvKQL)rRaz(sGAPSwEoe0taIA5FZjAy6HAUEToZg)iqTrd1(WqTOgQnrIOnzTkQwZ1vMwTC1gHGuOwfvRYbQn2UUw1ijGw7nR90ApCTnsRf3MlMdsRnnq5UwmQwtkRfPCasTX211Qgjb0An6tE6b4ADjO5PHIkBOhQXbScMu5ack)t1fHKzcGrpYa4EIi5gIq)zQOYg6HACaRGjvoGGY)utmcbPa3383Oiqofcyoe0taIm(nNOHPhQdqB0sqWM(nNb8JwbY8LaHNlB63CgWpAfiZxceiqSDn(dMcoNTtyCM(nNGOOks1Y)OvGmFjaxVwkKRRmTArKAPWWKayo1g9PCQL(nNGOwUAJqqkGlQSHEOghWkysLdiO8pvxesMjag9idG7jIKBic9NPIkBOhQXbScMu5ack)tnXieKcCpsBiHSAKeqX)mX9n)vtcTgWpAfiZxceG2OLGGnRei2Ug)btP7WHB8tQNR8aYh)mXmB1ijGg0lgYkkloGliqSDnML0lQIuT8pAfiZxculL1YZHGEcqul)Bordtpux711YNcxVwkKRRmTAbJitRwk8ZvFeOwLJP1g9jL1sd1sGjbWCarTtePwxRfq8nkQSHEOghWkysLdiO8pvYZvFeG7B(RMeAnGF0kqMVeiaTrlbbBJIa5uiG5qqpbiY43CIgMEOoaTrlbbBNeinqEU6Jab9guFDcBgg5mAjeWxNiHSAKeqlQIuT8pAfiZxcuB0Pwlphc6jarT8V5enm9qnxVwkmyUUY0QDIi1sJ6hUwU2xSwRfPIi1crOqlarT42CXCqATIhX0d1HIkBOhQXbScMu5ack)t1fHKzcGrpYa4EIi5gIq)zQOYg6HACaRGjvoGGY)utmcbPa3J0gsiRgjbu8ptCFZF1KqRb8JwbY8LabOnAjiyBueiNcbmhc6jarg)Mt0W0d1bOnAjiyRgjb0GEXqwrzXbSqGy7AmBwjqSDn(dMCgoC4egNPFZjiyUOks1Y)OvGmFjqTuwRZmcCcxVwNjdORfXaiKta1A1IBZfZbP1YvBecsHAjxchTwBQaPwk8ZvFeOwAyIiqToZiWwN8U20d1fv2qpuJdyfmPYbeu(NQlcjZeaJEKbW9erYneH(ZurLn0d14awbtQCabL)PMyecsbUV5VAsO1a(rRaz(sGa0gTeeSvtcTgGiWwN8U2uiaTrlbb7bcjfOO7aeb26K31McbceBxJ)Gj2UeGrozicmfipx9ra2cKgipx9rGabITRXSqbugzUC4MJTiYyxOfE1REpa]] )

end