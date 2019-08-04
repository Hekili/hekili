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


    spec:RegisterPack( "Assassination", 20190804, [[daLBYbqiurpsa6sIOcBcf9juiegfQWPqjwfku9kuWSOI6wQkv7IQ(Li0WqcDmKOLHe8mbW0OI01erzBOq03ervghve15qHI1HcjVdfcPMNQc3tv1(qj9puiLoOQsXcvv0dPIGjkIQ6IOqPnsfHQpsfHmsuiKCsQiIvIK8srurZefc1nPIiTtrWqfrLwQQsPNIQMQa1vPIqzROqWxrHq0Ef6VIAWsDyklgPESctMWLbBwrFwKgnk1Pvz1OqkEnsQzt0Tf0Uv63qgov64OqQwoINd10jDDvz7OsFxGmEb05frwVQsMpvy)soszm4iVWuiMafOiLmgk6KPOt9uMmkMmkMSiVMKle5DTb1wke5xleI8FdgBy8TMEOnY7AjjrMigCKhJEKbe5zRQlMrLyIPNY(r7hOWeXx4tA6H2bXMAI4lCKyKN(Ds1jzJ0rEHPqmbkqrkzmu0jtrN6Pmzu0PjJXe5TNYgrI88xOtiYZ(ecyJ0rEbGhr(aw93GXggFRPhAR(BrPpOOkGvZwvxmJkXetpL9J2pqHjIVWN00dTdIn1eXx4iXIQaw938sFyTAN6C1uGIuYyQ(7vtPtzujlzfvfvbSANaBBtbmJQOkGv)9Q)gHaevNCEdQRwrvlGP9KA12qp0wT8WQVOkGv)9Q)wieXfQwnskO5B6lQcy1FV6Vriar1oXWq1ojkeIRMd0tXNaQgnRgRGjv2S4J8YdR4yWrEScMuzdIyWXeOmgCKhwJwcI4Nr(b5uGCwKFGcPrzx0TkUAw)R2PvZSAoQwnjSQFVu2kwnj1aXdRrlbr1oCuTAsyvp(rRaz(sbpSgTeevZSAoQwnjSQhceBB67wtbpSgTeevZS6bcjfOGwpei2203TMcEceA3IR(J)QPq1oCunNvR3G6BtRMLQzwnxJCgTe84BtLqwnskOvZs1mRwnskOE9cHSIYIdQ(7vtGq7wC1SwnJmYBd9qBKN8C1hbIAmbkedoYdRrlbr8Zi)erYleOgtGYiVn0dTrExesMjag9idiQXecqm4ipSgTeeXpJ8dYPa5SiV9fqof8y2e0taIm(nNOHPhA9WA0squnZQPFZPh)OvGmFPG)5wnZQPFZPh)OvGmFPGNaH2T4Q)OAk9bOAMvZz1yCM(nNGiYBd9qBKp1ieKcrnMGtJbh5H1OLGi(zKFIi5fcuJjqzK3g6H2iVlcjZeaJEKbe1ycjlgCKhwJwcI4NrEBOhAJ8PgHGuiYpiNcKZI8QjHv94hTcK5lf8WA0squnZQ5OAceA3IR(JQPKcv7Wr1UHpPEUYdiv)XF1uwnlvZSA1iPG61leYkkloO6VxnbcTBXvZA1uiYpsAiHSAKuqXXeOmQXeyKXGJ8WA0sqe)mYpiNcKZI8QjHv94hTcK5lf8WA0squnZQTVaYPGhZMGEcqKXV5enm9qRhwJwcIQzwnNvlqQN8C1hb86nO(20QzwnxJCgTe84BtLqwnskOrEBOhAJ8KNR(iquJjK8Ibh5H1OLGi(zKFIi5fcuJjqzK3g6H2iVlcjZeaJEKbe1yco5yWrEynAjiIFg5THEOnYNAecsHi)GCkqolYRMew1JF0kqMVuWdRrlbr1mR2(ciNcEmBc6jarg)Mt0W0dTEynAjiQMz1Qrsb1RxiKvuwCq1SwnbcTBXvZSAoQMaH2T4Q)OAkDYv7Wr1CwngNPFZjiQMLi)iPHeYQrsbfhtGYOgtGXedoYdRrlbr8Zi)erYleOgtGYiVn0dTrExesMjag9idiQXeOKIXGJ8WA0sqe)mYpiNcKZI8QjHv94hTcK5lf8WA0squnZQvtcR6HaX2M(U1uWdRrlbr1mREGqsbkO1dbITn9DRPGNaH2T4Q)OAkRMz1UeGBoDi8u6jpx9rGQzwTaPEYZvFeWtGq7wC1SwDYQMHQDA1mE1d3COfyg7cRiYBd9qBKp1ieKcrnQrEaJHDa4yWXeOmgCKhwJwcI4Nr(b5uGCwKhwGKMKxVqiROCOfy1SwnLvZSAoRwa0V50ZfwbOQ5FUvZSAoQMZQfi1pq7awLykiYtPfcz6hz96nO(20QzwnNvBd9qRFG2bSkXuqKNsle83MNYlLTwTdhvpFszMad2gjfY6fcv)r1PdHp0cSAwI82qp0g5hODaRsmfe5P0cHOgtGcXGJ8WA0sqe)mYpiNcKZI8cG(nNEUWkavn)ZTAMvZr1CwTAsyvVIc8gzAPjapSgTeev7Wr1cG(nNEff4nY0sta(NB1mREGcPrzx0Tk2lG5noT6p(RMYQD4OAbq)MtpxyfGQMNaH2T4Q)4VAkPy1SuTdhvRxiKvuwCq1F8xnLumYBd9qBKNwIqImAMv2qgwimPOgtiaXGJ8WA0sqe)mYpiNcKZI8deskqbTEUWkavnpbcTBXv)r1bOAhoQwa0V50ZfwbOQ5FUv7Wr1Qrsb1RxiKvuwCq1FuDaOyK3g6H2iF6ZiIZ2mAMTVacszh1ycongCKhwJwcI4Nr(b5uGCwKFkris1CunhvRgjfuVEHqwrzXbv)9QdafRMLQtoQ2g6HwF6ZiIZ2mAMTVacsz7hiKuGcARMLQzT6PeHivZr1CuTEHqwrzXbv)9QdafR(7vpqiPaf065cRau18ei0UfxnlvNCuTn0dT(0NreNTz0mBFbeKY2pqiPaf0wnlrEBOhAJ8PpJioBZOz2(ciiLDuJjKSyWrEynAjiIFg5hKtbYzrESliLz1iPGI9tBZOzM694c4Qz9VAkuTdhvtStKbUWQEtiW(BRM1QzKuSAMvdlqstQ6pQo5rXiVn0dTr(jA8WGiBFbKtHmnyHrnMaJmgCKhwJwcI4Nr(b5uGCwKh7cszwnskOy)02mAMPEpUaUAw)RMcv7Wr1e7ezGlSQ3ecS)2QzTAgjfJ82qp0g5DFKBM0TPzAPH1Ogti5fdoYdRrlbr8Zi)GCkqolYt)MtpbgulbmoprKb4FUv7Wr10V50tGb1saJZteza5b6Tkq8y1gux9hvtjfJ82qp0g5v2q(T0O3kYtezarnMGtogCK3g6H2ip5CDLq(2m21gqKhwJwcI4NrnMaJjgCKhwJwcI4Nr(b5uGCwKN(nNE5nbAjcj8y1gux9hvhGiVn0dTr(GqePGlCBMay0A7aIAmbkPym4ipSgTeeXpJ8dYPa5SipSajnPQ)O6KrXQzwnNvpqiPaf065cRau18p3iVn0dTr(qierskJMz5BCISGawioQrnYlGP9KAm4ycugdoYdRrlbr8Zi)GCkqolYZz1yfmPYgeEtkJ82qp0g5P(guh1ycuigCK3g6H2ipwbtQSJ8WA0sqe)mQXecqm4ipSgTeeXpJ8i3ipg0iVn0dTrEUg5mAje55AYhe5HfiPj5jqkSvZq1UOdJwqKPLaiWvZ4vN8Qo5OAoQMcvZ4vJDbPmZ2WkunlrEUgjVwie5HfiPjLjqkS5bkK(wqe1ycongCKhwJwcI4NrEKBKhdAK3g6H2ipxJCgTeI8Cn5dI8yxqkZQrsbf7N2MrZm17XfWv)r1uiYZ1i51cHip(2ujKvJKcAuJjKSyWrEynAjiIFg5THEOnYBFHzBedNNOvZOz2ffeqI8dYPa5SipNvJvWKkBq4nPSAMvhAyfizdJnm(2mbcTBXv)xnfRMz1deskqbTEUWkavnpbcTBXv)r1usXQzOAkPy1mE1aJ(7CDbH3WS5AlGZe7lejpqetwnZQ5SAbq)MtpxyfGQM)5wnZQ5SAbq)MtVIc8gzAPja)ZnYVwie5TVWSnIHZt0Qz0m7IccirnMaJmgCKhwJwcI4Nr(b5uGCwKhRGjv2GWtqPpiYBd9qBKFysz2g6H2S8WAKxEynVwie5XkysLniIAmHKxm4ipSgTeeXpJ8dYPa5SiphvZz1QjHv9Hgwbs2WydJV1dRrlbr1oCuTaP(uJqqk41Bq9TPvZs1mRMJQ5SAGr)DUUGWBFHzBedNNOvZOz2ffeqQ2HJQ5S6bcjfOGwV0uy1Srg2A(NB1Se5THEOnYpmPmBd9qBwEynYlpSMxleI8dboQXeCYXGJ8WA0sqe)mYBd9qBKFysz2g6H2S8WAKxEynVwie5finQXeymXGJ8WA0sqe)mYBd9qBKFysz2g6H2S8WAKxEynVwie5fhbgAuJjqjfJbh5H1OLGi(zKFqofiNf5HfiPj5fW8gNwnR)vtzYQMHQ5AKZOLGhwGKMuMaPWMhOq6BbrK3g6H2iVrg2czfriWQrnMaLugdoYBd9qBK3idBHS7tIHipSgTeeXpJAmbkPqm4iVn0dTrE5LYwXzgnprAiSAKhwJwcI4NrnQrExcmqH0MgdoMaLXGJ82qp0g5nxxzszx0HrBKhwJwcI4NrnMafIbh5THEOnY7I0dTrEynAjiIFg1ycbigCKhwJwcI4NrEBOhAJ8HgHAqKNiswaMYoYpiNcKZI8e7ezGlSQ3ecS)2QzTAktwK3LaduiTPzmmqRah5twuJj40yWrEBOhAJ8yfmPYoYdRrlbr8ZOgtizXGJ8WA0sqe)mYVwie5TVWSnIHZt0Qz0m7IccirEBOhAJ82xy2gXW5jA1mAMDrbbKOg1iV4iWqJbhtGYyWrEynAjiIFg5hKtbYzr(bkKgLDr3Q4Qz9VANwndvRMew1laWfizSsm1sHqpSgTeevZSAoQwa0V50ZfwbOQ5FUv7Wr1cG(nNEff4nY0sta(NB1oCunSajnjVaM340Q)4VAoQgwUWIcZUiKmlG5noTAwz0wnhvtHKvndvZ1iNrlbpSajnPmbsHnpqH03cIQzPAwQ2HJQ5SAUg5mAj4X3MkHSAKuqRMLQzwnhvZz1QjHv9qGyBtF3Ak4H1OLGOAhoQEGqsbkO1dbITn9DRPGNaH2T4QzTAkunlrEBOhAJ8WYfwuyuJjqHyWrEynAjiIFg5rUrEmOrEBOhAJ8CnYz0siYZ1KpiYpqH0OSl6wf7fW8gNwnRvtz1oCunSajnjVaM340Q)4VAkKSQzOAUg5mAj4HfiPjLjqkS5bkK(wquTdhvZz1CnYz0sWJVnvcz1iPGg55AK8AHqK)HH88KsGe1ycbigCKhwJwcI4Nr(b5uGCwKNRroJwc(hgYZtkbs1mR2(ciNcEyWgDBAMwAca7H1OLGOAMvJDbPmRgjfuSFABgnZuVhxaxnR)vtHiVn0dTr(PTz0mt9ECbCuJj40yWrEynAjiIFg5hKtbYzrEUg5mAj4FyippPeivZSAoQM(nNE2NqaBMwAca7XQnOUAw)RMsgt1oCunhvZz1UKdronPmbPMEOTAMvJDbPmRgjfuSFABgnZuVhxaxnR)v70QzOAoQ2(ciNcEb6rlHSaHbpXwQRM1QPq1SundvJvWKkBq4jO0hunlvZsK3g6H2i)02mAMPEpUaoQXeswm4ipSgTeeXpJ82qp0g5N2MrZm17XfWr(b5uGCwKNRroJwc(hgYZtkbs1mRg7cszwnskOy)02mAMPEpUaUAw)Roar(rsdjKvJKckoMaLrnMaJmgCKhwJwcI4Nr(b5uGCwKNRroJwc(hgYZtkbs1mRMJQPFZPNwERaFcW)CR2HJQ5SA1KWQEUWIcZKhMThwJwcIQzwnNvBFbKtbVa9OLqwGWGhwJwcIQzjYBd9qBKNwERaFciQXesEXGJ8WA0sqe)mYBd9qBKp8PN0uiYpiNcKZI8CnYz0sW)WqEEsjqQMz1yxqkZQrsbf7N2MrZm17XfWv)xnfI8JKgsiRgjfuCmbkJAmbNCm4ipSgTeeXpJ8dYPa5SipxJCgTe8pmKNNucKiVn0dTr(WNEstHOg1i)qGJbhtGYyWrEynAjiIFg5hKtbYzrEoRgRGjv2GWBsz1mRwGup55Qpc41Bq9TPvZS6qdRajBySHX3MjqODlU6)QPyK3g6H2i)WKYSn0dTz5H1iV8WAETqiYdymSdah1ycuigCKhwJwcI4NrEBOhAJ8HgHAqKNiswaMYoYpiNcKZI8e7ezGlSQ3ecS)5wnZQ5OA1iPG61leYkkloO6pQEGcPrzx0Tk2lG5noTAgVAk9jRAhoQEGcPrzx0Tk2lG5noTAw)RE4MdTaZyxyfvZsKFK0qcz1iPGIJjqzuJjeGyWrEynAjiIFg5hKtbYzrEIDImWfw1Bcb2FB1SwDaOy1FVAIDImWfw1Bcb2lEetp0wnZQhOqAu2fDRI9cyEJtRM1)QhU5qlWm2fwrK3g6H2iFOrOge5jIKfGPSJAmbNgdoYdRrlbr8Zi)GCkqolYZz1yfmPYgeEck9bvZSAbs9KNR(iGxVb13MwnZQ5SAbq)MtpxyfGQM)5wnZQ5OAoRwnjSQh)OvGmFPGhwJwcIQD4OAoR2(ciNcEmBc6jarg)Mt0W0dTEynAjiQ2HJQfi1NAecsbVB4tQNR8as1SwnLvZSAoQg7cszwnskOy)02mAMPEpUaU6pQMrwTdhvZz1deskqbTEU2Ey2(NB1SunlvZSAoQMZQvtcR63lLTIvtsnq8WA0squTdhvZz1QjHv9qGyBtF3Ak4H1OLGOAhoQEGqsbkO1dbITn9DRPGNaH2T4Q)O6Kv93RMcvZ4vRMew1laWfizSsm1sHqpSgTeevZs1mRMJQ5SAGr)DUUGWBFHzBedNNOvZOz2ffeqQ2HJQTVaYPGhZMGEcqKXV5enm9qRhwJwcIQD4OAbq)MtpX(crYdeXKzbq)MtVaf0wTdhvpqiPaf06nmBU2c4mX(crYdeXKEceA3IR(JQPKIvZS6bcjfOGwVIc8gzAPjapbcTBXv)r1uwnlrEBOhAJ8CHvaQArnMqYIbh5H1OLGi(zKFqofiNf5vtcR6HaX2M(U1uWdRrlbr1mRMJQvtcR63lLTIvtsnq8WA0squTdhvRMew1JF0kqMVuWdRrlbr1mRMRroJwcE8TPsiRgjf0QzPAMvpqH0OSl6wfxnR)vpCZHwGzSlSIQzw9aHKcuqRhceBB67wtbpbcTBXv)r1uwnZQ5OAoRwnjSQh)OvGmFPGhwJwcIQD4OAoR2(ciNcEmBc6jarg)Mt0W0dTEynAjiQ2HJQfi1NAecsbVB4tQNR8as1F8xnLvZsK3g6H2ipxBpm7OgtGrgdoYdRrlbr8Zi)GCkqolYRMew1VxkBfRMKAG4H1OLGOAMvZz1QjHv9qGyBtF3Ak4H1OLGOAMvpqH0OSl6wfxnR)vpCZHwGzSlSIQzwTaOFZPNlScqvZ)CJ82qp0g55A7Hzh1ycjVyWrEynAjiIFg5rUrEmOrEBOhAJ8CnYz0siYZ1KpiYBFbKtbpMnb9eGiJFZjAy6HwpSgTeevZSAoQErBgJZ0V5eez1iPGIRM1)QPSAhoQg7cszwnskOy)02mAMPEpUaU6)Qdq1SunZQ5OAmot)MtqKvJKckoB0iUq21wbeEJQ)RMIv7Wr1yxqkZQrsbf7N2MrZm17XfWvZ6F1mYQzjYZ1i51cHipgN5A7HzNhOvC6H2OgtWjhdoYdRrlbr8ZiVn0dTrExesMjag9idiYdbQelBHO3QrENMSi)erYleOgtGYOgtGXedoYdRrlbr8Zi)GCkqolYRMew1JF0kqMVuWdRrlbr1mRMZQXkysLni8eu6dQMz1deskqbT(uJqqk4FUvZSAoQMRroJwcEmoZ12dZopqR40dTv7Wr1CwT9fqof8y2e0taIm(nNOHPhA9WA0squnZQfi1NAecsbpbMeaZ2OLq1SunZQhOqAu2fDRI9cyEJtRM1)Q5OAoQMYQzOAkunJxT9fqof8y2e0taIm(nNOHPhA9WA0squnlvZ4vJDbPmRgjfuSFABgnZuVhxaxnlvZkJ2QDA1mRMyNidCHv9MqG93wnRvtjfI82qp0g55A7Hzh1ycusXyWrEynAjiIFg5hKtbYzrE1KWQ(qdRajBySHX36H1OLGOAMvZz1yfmPYgeEtkRMz1Hgwbs2WydJVntGq7wC1F8xnfRMz1CwTaPEYZvFeWtGjbWSnAjunZQfi1NAecsbpbcTBXvZA1bOAMvla63C65cRau18p3QzwnhvZz1QjHv9kkWBKPLMa8WA0squTdhvla63C6vuG3itlnb4FUvZs1mRMJQ5SAaJHDaEAjcjYOzwzdzyHWK8HgJgePAhoQwa0V50tlrirgnZkBidleMK)5wnlrEBOhAJ8CT9WSJAmbkPmgCKhwJwcI4Nr(b5uGCwKNZQXkysLni8MuwnZQTVaYPGhZMGEcqKXV5enm9qRhwJwcIQzwTaP(uJqqk4jWKay2gTeQMz1cK6tncbPG3n8j1ZvEaP6p(RMYQzw9afsJYUOBvSxaZBCA1S(xnLrEBOhAJ8y2MafuiifrnMaLuigCKhwJwcI4Nr(b5uGCwKxGup55Qpc4jqODlUAwR2PvZq1oTAgV6HBo0cmJDHvunZQ5SAbs9PgHGuWtGjbWSnAje5THEOnYdbITn9DRPquJjqzaIbh5H1OLGi(zKFqofiNf5fi1tEU6JaE9guFBAK3g6H2iVIc8gzAPjGOgtGsNgdoYdRrlbr8Zi)GCkqolYt)MtpTeHeYhw9eWgA1oCuTaOFZPNlScqvZ)CJ82qp0g5Dr6H2OgtGYKfdoYdRrlbr8Zi)GCkqolYla63C65cRau18p3iVn0dTrEAjcjYZhjPOgtGsgzm4ipSgTeeXpJ8dYPa5SiVaOFZPNlScqvZ)CJ82qp0g5PbcgiuFBAuJjqzYlgCKhwJwcI4Nr(b5uGCwKxa0V50ZfwbOQ5FUrEBOhAJ8ZJa0sese1ycu6KJbh5H1OLGi(zKFqofiNf5fa9Bo9CHvaQA(NBK3g6H2iVTdaRetMhMug1ycuYyIbh5H1OLGi(zK3g6H2iFQjHHjLabNPrOnYpiNcKZI8deskqbTEUWkavnpbcTBXvZA1onzr(1cHiFQjHHjLabNPrOnQXeOafJbh5H1OLGi(zK3g6H2iVHzZ1waNj2xisEGiMmYpiNcKZI8cG(nNEI9fIKhiIjZcG(nNEbkOTAhoQwa0V50ZfwbOQ5jqODlUAwRMskw93R2PvZ4vdm6VZ1feE7lmBJy48eTAgnZUOGas1oCuTAKuq96fczfLfhu9hvtbkg5xleI8gMnxBbCMyFHi5bIyYOgtGcugdoYdRrlbr8ZiVn0dTrE5JqnqW5BXN4qpCo9MAKFqofiNf5fa9Bo9CHvaQA(NBKFTqiYlFeQbcoFl(eh6HZP3uJAmbkqHyWrEynAjiIFg5THEOnYlFyLGE4CkskGn7kFHwke5hKtbYzrEbq)MtpxyfGQM)5g5xleI8YhwjOhoNIKcyZUYxOLcrnMafcqm4ipSgTeeXpJ82qp0g5tLM4mfrW5qqys5H2i)GCkqolYla63C65cRau18p3ipmNWqZRfcr(uPjotreCoeeMuEOnQXeOGtJbh5H1OLGi(zK3g6H2iFQ0eNPicotBIuiYpiNcKZI8cG(nNEUWkavn)ZnYdZjm08AHqKpvAIZuebNPnrke1ycuizXGJ8WA0sqe)mYBd9qBKFK0qIucAVrMwAynYpiNcKZI8Hgwbs2WydJVntGq7wC1)vtXQzwnNvla63C65cRau18p3QzwnNvla63C6vuG3itlnb4FUvZSA63C6dHqejPmAMLVXjYccyHyVaf0wnZQHfiPjv9hv7KPy1mRwGup55Qpc4jqODlUAwR2PrEyoHHMxleI8JKgsKsq7nY0sdRrnMafyKXGJ82qp0g5FyiFkeIJ8WA0sqe)mQrnYlqAm4ycugdoYdRrlbr8ZipYnYJbnYBd9qBKNRroJwcrEUM8brExYHiNMuMGutp0wnZQXUGuMvJKck2pTnJMzQ3JlGRM1Qdq1mRMJQfi1NAecsbpbcTBXv)r1deskqbT(uJqqk4fpIPhAR2HJQDrhgTGitlbqGRM1Qtw1Se55AK8AHqKht95MhjnKqo1ieKcrnMafIbh5H1OLGi(zKh5g5XGg5THEOnYZ1iNrlHipxt(GiVl5qKttktqQPhARMz1yxqkZQrsbf7N2MrZm17XfWvZA1bOAMvZr1cG(nNEff4nY0sta(NB1oCunhv7IomAbrMwcGaxnRvNSQzwnNvBFbKtbpEaRMrZmTeHeEynAjiQMLQzjYZ1i51cHipM6ZnpsAiHm55Qpce1ycbigCKhwJwcI4NrEKBKhdAK3g6H2ipxJCgTeI8Cn5dI8cG(nNEUWkavn)ZTAMvZr1cG(nNEff4nY0sta(NB1oCuDOHvGKnm2W4BZei0UfxnRvtXQzPAMvlqQN8C1hb8ei0UfxnRvtHipxJKxleI8yQp3m55Qpce1ycongCKhwJwcI4Nr(b5uGCwKxnjSQhceBB67wtbpSgTeevZSAoQMJQhOqAu2fDRIRM1)QhU5qlWm2fwr1mREGqsbkO1dbITn9DRPGNaH2T4Q)OAkRMLQD4OAoQMZQ1Bq9TPvZSAoQwVqOAwRMskwTdhvpqH0OSl6wfxnR)vtHQzPAwQMLiVn0dTrEYZvFeiQXeswm4ipSgTeeXpJ8tejVqGAmbkJ82qp0g5DrizMay0JmGOgtGrgdoYdRrlbr8Zi)GCkqolYZr1CwTAsyvp(rRaz(sbpSgTeev7Wr1CwnhvpqiPaf065A7Hz7FUvZS6bcjfOGwpxyfGQMNaH2T4Q)4VANwnlvZs1mREGcPrzx0Tk2lG5noTAw)RMYQzO6aunJxnhvBFbKtbpMnb9eGiJFZjAy6HwpSgTeevZS6bcjfOGwpxBpmB)ZTAwQMz1eysamBJwcvZSAoQ2n8j1ZvEaP6p(RMYQD4OAceA3IR(J)Q1BqDwVqOAMvJDbPmRgjfuSFABgnZuVhxaxnR)vhGQzOA7lGCk4XSjONaez8Bordtp06H1OLGOAwQMz1CunNvdbITn9DRPGOAhoQMaH2T4Q)4VA9guN1leQMXRMcvZSASliLz1iPGI9tBZOzM694c4Qz9V6aundvBFbKtbpMnb9eGiJFZjAy6HwpSgTeevZs1mRMZQX4m9Bobr1mRMJQvJKcQxVqiROS4GQ)E1ei0UfxnlvZA1oTAMvZr1Hgwbs2WydJVntGq7wC1)vtXQD4OAoRwVb13MwnZQTVaYPGhZMGEcqKXV5enm9qRhwJwcIQzjYBd9qBKp1ieKcrnMqYlgCKhwJwcI4Nr(jIKxiqnMaLrEBOhAJ8UiKmtam6rgquJj4KJbh5H1OLGi(zK3g6H2iFQriifI8dYPa5SipNvZ1iNrlbpM6ZnpsAiHCQriifQMz1CunNvRMew1JF0kqMVuWdRrlbr1oCunNvZr1deskqbTEU2Ey2(NB1mREGqsbkO1ZfwbOQ5jqODlU6p(R2PvZs1SunZQhOqAu2fDRI9cyEJtRM1)QPSAgQoavZ4vZr12xa5uWJztqpbiY43CIgMEO1dRrlbr1mREGqsbkO1Z12dZ2)CRMLQzwnbMeaZ2OLq1mRMJQDdFs9CLhqQ(J)QPSAhoQMaH2T4Q)4VA9guN1leQMz1yxqkZQrsbf7N2MrZm17XfWvZ6F1bOAgQ2(ciNcEmBc6jarg)Mt0W0dTEynAjiQMLQzwnhvZz1qGyBtF3AkiQ2HJQjqODlU6p(RwVb1z9cHQz8QPq1mRg7cszwnskOy)02mAMPEpUaUAw)RoavZq12xa5uWJztqpbiY43CIgMEO1dRrlbr1SunZQ5SAmot)MtqunZQ5OA1iPG61leYkkloO6VxnbcTBXvZs1SwnLuOAMvZr1Hgwbs2WydJVntGq7wC1)vtXQD4OAoRwVb13MwnZQTVaYPGhZMGEcqKXV5enm9qRhwJwcIQzjYpsAiHSAKuqXXeOmQXeymXGJ8WA0sqe)mYpiNcKZI8yxqkZQrsbfxnR)vtHQzwnbcTBXv)r1uOAgQMJQXUGuMvJKckUAw)RozvZs1mREGcPrzx0TkUAw)R2PrEBOhAJ8dYfIrBwHqxaRrnMaLumgCKhwJwcI4Nr(b5uGCwKNZQ5AKZOLGht95Mjpx9rGQzw9afsJYUOBvC1S(xTtRMz1eysamBJwcvZSAoQ2n8j1ZvEaP6p(RMYQD4OAceA3IR(J)Q1BqDwVqOAMvJDbPmRgjfuSFABgnZuVhxaxnR)vhGQzOA7lGCk4XSjONaez8Bordtp06H1OLGOAwQMz1CunNvdbITn9DRPGOAhoQMaH2T4Q)4VA9guN1leQMXRMcvZSASliLz1iPGI9tBZOzM694c4Qz9V6aundvBFbKtbpMnb9eGiJFZjAy6HwpSgTeevZs1mRwnskOE9cHSIYIdQ(7vtGq7wC1SwTtJ82qp0g5jpx9rGOgtGskJbh5H1OLGi(zK3g6H2ip55Qpce5hKtbYzrEoRMRroJwcEm1NBEK0qczYZvFeOAMvZz1CnYz0sWJP(CZKNR(iq1mREGcPrzx0TkUAw)R2PvZSAcmjaMTrlHQzwnhv7g(K65kpGu9h)vtz1oCunbcTBXv)XF16nOoRxiunZQXUGuMvJKck2pTnJMzQ3JlGRM1)Qdq1muT9fqof8y2e0taIm(nNOHPhA9WA0squnlvZSAoQMZQHaX2M(U1uquTdhvtGq7wC1F8xTEdQZ6fcvZ4vtHQzwn2fKYSAKuqX(PTz0mt9ECbC1S(xDaQMHQTVaYPGhZMGEcqKXV5enm9qRhwJwcIQzPAMvRgjfuVEHqwrzXbv)9QjqODlUAwR2Pr(rsdjKvJKckoMaLrnQrnYZfi4dTXeOafPKXqrNmfdGNske5dYi7TP4iVtsOlIOGO6Kx12qp0wT8Wk2xuf5XUWiMafsgJjY7sqZtcr(aw93GXggFRPhAR(BrPpOOkGvZwvxmJkXetpL9J2pqHjIVWN00dTdIn1eXx4iXIQaw938sFyTAN6C1uGIuYyQ(7vtPtzujlzfvfvbSANaBBtbmJQOkGv)9Q)gHaevNCEdQRwrvlGP9KA12qp0wT8WQVOkGv)9Q)wieXfQwnskO5B6lQcy1FV6Vriar1oXWq1ojkeIRMd0tXNaQgnRgRGjv2S4lQkQcy1m2aHXtbr10WerGQhOqAtRMgsVf7R(BgdWvXvVO97Sns48jR2g6HwC1OvMKVOkGvBd9ql27sGbkK20)P0WuxufWQTHEOf7DjWafsBkd)jAV0qyvtp0wufWQTHEOf7DjWafsBkd)jorirrvaRMFnxmBKwnXor10V5eevJvtXvtdtebQEGcPnTAAi9wC12kQ2LaF3fP6TPvF4QfOf8fvbSABOhAXExcmqH0MYWFI41CXSrAgRMIlQSHEOf7DjWafsBkd)jAUUYKYUOdJ2IkBOhAXExcmqH0MYWFIUi9qBrLn0dTyVlbgOqAtz4pXqJqniYtejlatz7SlbgOqAtZyyGwb(pzoFZFIDImWfw1Bcb2FlRuMSIkBOhAXExcmqH0MYWFIyfmPYUOYg6HwS3LaduiTPm8N4dd5tHqNxle(TVWSnIHZt0Qz0m7IccifvfvbSAgBGW4PGOAGlqsQA9cHQv2q12qrKQpC1gx7KgTe8fvbS6VfWkysLD13SAxegF0sOAowu1CFYfigTeQgwi8aC13w9afsBklfv2qp0I)P(gu78n)5eRGjv2GWBszrLn0dTyg(teRGjv2fv2qp0Iz4prUg5mAj48AHWpSajnPmbsHnpqH03ccN5AYh8dlqstYtGuyzWfDy0cImTeabMXtEjhCqbgh7cszMTHvGLIkBOhAXm8NixJCgTeCETq4hFBQeYQrsb1zUM8b)yxqkZQrsbf7N2MrZm17XfWFqHIkBOhAXm8N4dd5tHqNxle(TVWSnIHZt0Qz0m7IccioFZFoXkysLni8MuYm0WkqYggBy8TzceA3I)PiZbcjfOGwpxyfGQMNaH2T4pOKImqjfzCGr)DUUGWBy2CTfWzI9fIKhiIjzYPaOFZPNlScqvZ)CzYPaOFZPxrbEJmT0eG)5wuzd9qlMH)ehMuMTHEOnlpS68AHWpwbtQSbHZ38hRGjv2GWtqPpOOYg6Hwmd)jomPmBd9qBwEy151cH)Ha78n)5Gt1KWQ(qdRajBySHX36H1OLGWHdbs9PgHGuWR3G6BtzHjhCcm6VZ1feE7lmBJy48eTAgnZUOGaIdhCoqiPaf06LMcRMnYWwZ)CzPOYg6Hwmd)jomPmBd9qBwEy151cHFbslQSHEOfZWFIdtkZ2qp0MLhwDETq4xCeyOfv2qp0Iz4prJmSfYkIqGvD(M)WcK0K8cyEJtz9NYKXaxJCgTe8WcK0KYeif28afsFlikQSHEOfZWFIgzylKDFsmuuzd9qlMH)eLxkBfNz08ePHWQfvfvbSANacjfOGwCrLn0dTy)qG)hMuMTHEOnlpS68AHWpGXWoaSZ38NtScMuzdcVjLmfi1tEU6JaE9guFBkZqdRajBySHX3MjqODl(NIfvbSANKz1MqGR2iq1pxNRgVNluTYgQgTq1bDk7QLOGaSwDWbN89v7eddvheByRwK0TPvpnScKQv22wTti5wTaM340QrKQd6u2ONwTTjvTti56lQSHEOf7hcmd)jgAeQbrEIizbykBNhjnKqwnskO4FkD(M)e7ezGlSQ3ecS)5YKd1iPG61leYkklo4JbkKgLDr3QyVaM34ugNsFYC4yGcPrzx0Tk2lG5noL1)HBo0cmJDHvWsrvaR2jzw9IQ2ecC1bDsz1IdQoOtzFB1kBO6fcuRoaue7C1pmuTt6m5xnARMgHXvh0PSrpTABtQANqY1xuzd9ql2peyg(tm0iudI8erYcWu2oFZFIDImWfw1Bcb2FlRbGIFNyNidCHv9MqG9IhX0dTmhOqAu2fDRI9cyEJtz9F4MdTaZyxyffv2qp0I9dbMH)e5cRau1C(M)CIvWKkBq4jO0hWuGup55Qpc41Bq9TPm5ua0V50ZfwbOQ5FUm5Gt1KWQE8JwbY8LcEynAjiC4Gt7lGCk4XSjONaez8Bordtp06H1OLGWHdbs9PgHGuW7g(K65kpGWkLm5a7cszwnskOy)02mAMPEpUa(dgPdhCoqiPaf065A7Hz7FUSWcto4unjSQFVu2kwnj1aXdRrlbHdhCQMew1dbITn9DRPGhwJwcchogiKuGcA9qGyBtF3Ak4jqODl(JK9DkW4QjHv9caCbsgRetTui0dRrlbblm5GtGr)DUUGWBFHzBedNNOvZOz2ffeqC4W(ciNcEmBc6jarg)Mt0W0dTEynAjiC4qa0V50tSVqK8armzwa0V50lqbToCmqiPaf06nmBU2c4mX(crYdeXKEceA3I)GskYCGqsbkO1ROaVrMwAcWtGq7w8huYsrvaRMrW2dZU6GoLD1m2aXPvZq1CKWLYwXQjPgioxnIun)JwbY8LcvJwzsvJ2QPmywyuv7KAbEHVWQDcj3QTvunJnqCA1eWejv9erQEHa1QDICcj)IkBOhAX(HaZWFICT9WSD(M)QjHv9qGyBtF3Ak4H1OLGGjhQjHv97LYwXQjPgiEynAjiC4qnjSQh)OvGmFPGhwJwccMCnYz0sWJVnvcz1iPGYcZbkKgLDr3Qyw)hU5qlWm2fwbZbcjfOGwpei2203TMcEceA3I)GsMCWPAsyvp(rRaz(sbpSgTeeoCWP9fqof8y2e0taIm(nNOHPhA9WA0sq4WHaP(uJqqk4DdFs9CLhq(4NswkQcy1mc2Ey2vh0PSRoHlLTIvtsnqQMHQtavnJnqCkJQANulWl8fwTti5wTTIQzeGvaQAv)ClQSHEOf7hcmd)jY12dZ25B(RMew1VxkBfRMKAG4H1OLGGjNQjHv9qGyBtF3Ak4H1OLGG5afsJYUOBvmR)d3COfyg7cRGPaOFZPNlScqvZ)ClQcy18au98jLvpqHHWQvJ2QzRQlMrLyIPNY(r7hOWe)wJlSSrsH(9GDcj(TO0hKyqh1xIFdgBy8TMEO97FtYLr83)wadgzW2xuzd9ql2peyg(tKRroJwcoVwi8JXzU2Ey25bAfNEO1zUM8b)2xa5uWJztqpbiY43CIgMEO1dRrlbbtow0MX4m9BobrwnskOyw)P0HdSliLz1iPGI9tBZOzM694c4)aWctoW4m9BobrwnskO4SrJ4czxBfq4n(POdhyxqkZQrsbf7N2MrZm17XfWS(ZizPOYg6HwSFiWm8NOlcjZeaJEKb48erYleO(tPZqGkXYwi6T6VttwrLn0dTy)qGz4prU2Ey2oFZF1KWQE8JwbY8LcEynAjiyYjwbtQSbHNGsFaZbcjfOGwFQriif8pxMCW1iNrlbpgN5A7HzNhOvC6Hwho40(ciNcEmBc6jarg)Mt0W0dTEynAjiykqQp1ieKcEcmjaMTrlbwyoqH0OSl6wf7fW8gNY6phCqjduGXTVaYPGhZMGEcqKXV5enm9qRhwJwccwyCSliLz1iPGI9tBZOzM694cywyLrRtzsStKbUWQEtiW(BzLskuufWQzeS9WSRoOtzxTtQHvGu93GXg(wgv1jGQgRGjv2vBRO6fvTn0JluTt63un9BoDU6V95Qpcu9I0QVTAcmjaMD1eBtbNRw8i3MwnJaScqvJHG)05QfpYTPv)PeHevdymSFv9nR24AN0OLGVOYg6HwSFiWm8NixBpmBNV5VAsyvFOHvGKnm2W4B9WA0sqWKtScMuzdcVjLmdnScKSHXggFBMaH2T4p(Pitofi1tEU6JaEcmjaMTrlbMcK6tncbPGNaH2Tywdatbq)MtpxyfGQM)5YKdovtcR6vuG3itlnb4H1OLGWHdbq)MtVIc8gzAPja)ZLfMCWjGXWoapTeHez0mRSHmSqys(qJrdI4WHaOFZPNwIqImAMv2qgwimj)ZLLIQawnpBtGckeKIQNis18SjONaevZ)Mt0W0dTfv2qp0I9dbMH)eXSnbkOqqkC(M)CIvWKkBq4nPKP9fqof8y2e0taIm(nNOHPhA9WA0sqWuGuFQriif8eysamBJwcmfi1NAecsbVB4tQNR8aYh)uYCGcPrzx0Tk2lG5noL1FklQcy1m2aX2M(U1uO6GydB10iLD1F7ZvFeOABfv7ezecsHQncu9ZT6jIuTeTPvdl6LYUOYg6HwSFiWm8Niei2203TMcoFZFbs9KNR(iGNaH2TywDkdoLXhU5qlWm2fwbtofi1NAecsbpbMeaZ2OLqrLn0dTy)qGz4prff4nY0staoFZFbs9KNR(iGxVb13Mwuzd9ql2peyg(t0fPhAD(M)0V50tlriH8HvpbSH6WHaOFZPNlScqvZ)ClQSHEOf7hcmd)jslrirE(ij58n)fa9Bo9CHvaQA(NBrLn0dTy)qGz4prAGGbc13M68n)fa9Bo9CHvaQA(NBrLn0dTy)qGz4pX5raAjcjC(M)cG(nNEUWkavn)ZTOYg6HwSFiWm8NOTdaRetMhMu68n)fa9Bo9CHvaQA(NBrLn0dTy)qGz4pXhgYNcHoVwi8NAsyysjqWzAeAD(M)deskqbTEUWkavnpbcTBXS60Kvuzd9ql2peyg(t8HH8PqOZRfc)gMnxBbCMyFHi5bIysNV5VaOFZPNyFHi5bIyYSaOFZPxGcAD4qa0V50ZfwbOQ5jqODlMvkP43DkJdm6VZ1feE7lmBJy48eTAgnZUOGaIdhQrsb1RxiKvuwCWhuGIfv2qp0I9dbMH)eFyiFke68AHWV8rOgi48T4tCOhoNEt15B(la63C65cRau18p3IkBOhAX(HaZWFIpmKpfcDETq4x(Wkb9W5uKuaB2v(cTuW5B(la63C65cRau18p3IkBOhAX(HaZWFIpmKpfcDgMtyO51cH)uPjotreCoeeMuEO15B(la63C65cRau18p3IkBOhAX(HaZWFIpmKpfcDgMtyO51cH)uPjotreCM2ePGZ38xa0V50ZfwbOQ5FUfv2qp0I9dbMH)eFyiFke6mmNWqZRfc)JKgsKsq7nY0sdRoFZ)qdRajBySHX3MjqODl(NIm5ua0V50ZfwbOQ5FUm5ua0V50ROaVrMwAcW)Czs)MtFieIijLrZS8norwqale7fOGwMWcK0K(WjtrMcK6jpx9rapbcTBXS60IQawDYhM2tQvpnPK2gux9erQ(HnAju9PqiMrvTtmmunAREGqsbkO1xuzd9ql2peyg(t8HH8PqiUOQOkGvN8pcm0QfwOLcvB0N80dWfvbSAg7Yfwuy1MwTtzOAosgdvh0PSRo5ZZs1oHKRVANKWqqCMcYKQgTvtbgQwnskOyNRoOtzxnJaScqvZ5QrKQd6u2vh8NmIUAKYgibDyO6GStREIivJrHq1WcK0K8v)nsmQ6GStR(MvZydeNw9afsJQ(WvpqH3Mw9Z1xuzd9ql2locm0Fy5clk05B(pqH0OSl6wfZ6VtzqnjSQxaGlqYyLyQLcHEynAjiyYHaOFZPNlScqvZ)CD4qa0V50ROaVrMwAcW)CD4awGKMKxaZBC6h)CalxyrHzxesMfW8gNYkJwoOqYyGRroJwcEybsAszcKcBEGcPVfeSWIdhCY1iNrlbp(2ujKvJKcklm5Gt1KWQEiqSTPVBnf8WA0sq4WXaHKcuqRhceBB67wtbpbcTBXSsbwkQSHEOf7fhbgkd)jY1iNrlbNxle(FyippPeioZ1Kp4FGcPrzx0Tk2lG5noLvkD4awGKMKxaZBC6h)uizmW1iNrlbpSajnPmbsHnpqH03ccho4KRroJwcE8TPsiRgjf0IQawnJipLD1m2bB0TPv)P0ea25QDIBB1Oz1jN7XfWvBA1uGHQvJKck2xuzd9ql2locmug(tCABgnZuVhxa78n)5AKZOLG)HH88KsGW0(ciNcEyWgDBAMwAca7H1OLGGj2fKYSAKuqX(PTz0mt9ECbmR)uOOkGv7e32QrZQto3JlGR20QPKXWq1y1guJRgnRMruNqaB1FknbGRgrQ2sTBXA1oLHQ5izmuDqNYU6Kp6rlHQt(imWs1Qrsbf7lQSHEOf7fhbgkd)joTnJMzQ3JlGD(M)CnYz0sW)WqEEsjqyYb9Bo9SpHa2mT0ea2JvBqnR)uYyC4GdoDjhICAszcsn9qltSliLz1iPGI9tBZOzM694cyw)DkdCyFbKtbVa9OLqwGWGNyl1SsbwyaRGjv2GWtqPpGfwkQcy1oXTTA0S6KZ94c4Qvu1MRRmPQt(GjKjvDYfDy0w9nR(wBOhxOA0wTTjvTAKuqR20Qdq1Qrsbf7lQSHEOf7fhbgkd)joTnJMzQ3JlGDEK0qcz1iPGI)P05B(Z1iNrlb)dd55jLaHj2fKYSAKuqX(PTz0mt9ECbmR)bOOYg6HwSxCeyOm8NiT8wb(eGZ38NRroJwc(hgYZtkbctoOFZPNwERaFcW)CD4Gt1KWQEUWIcZKhMThwJwccMCAFbKtbVa9OLqwGWGhwJwccwkQcy1bB0F3j9PN0uOAfvT56ktQ6KpyczsvNCrhgTvBA1uOA1iPGIlQSHEOf7fhbgkd)jg(0tAk48iPHeYQrsbf)tPZ38NRroJwc(hgYZtkbctSliLz1iPGI9tBZOzM694c4Fkuuzd9ql2locmug(tm8PN0uW5B(Z1iNrlb)dd55jLaPOQOkGvN8TqlfQgXfivRxiuTrFYtpaxufWQzeFHNwTtKriifWvJ2Qx0(DxYfsmssvRgjfuC1tePALnuTl5qKttQAcsn9qB13S6KXq10sae4QncuTjjGjsQ6NBrLn0dTyVaP)CnYz0sW51cHFm1NBEK0qc5uJqqk4mxt(GFxYHiNMuMGutp0Ye7cszwnskOy)02mAMPEpUaM1aWKdbs9PgHGuWtGq7w8hdeskqbT(uJqqk4fpIPhAD4WfDy0cImTeabM1KXsrvaRMr8fEA1F7ZvFeaxnAREr73DjxiXijvTAKuqXvprKQv2q1UKdronPQji10dTvFZQtgdvtlbqGR2iq1MKaMiPQFUfv2qp0I9cKYWFICnYz0sW51cHFm1NBEK0qczYZvFeWzUM8b)UKdronPmbPMEOLj2fKYSAKuqX(PTz0mt9ECbmRbGjhcG(nNEff4nY0sta(NRdhC4IomAbrMwcGaZAYyYP9fqof84bSAgnZ0ses4H1OLGGfwkQcy1mIVWtR(BFU6Ja4QVz1mcWkavngcgf4nQ(tPjGeDsnScKQ)gm2W4BR(Wv)CR2wr1bbvZ24cvtbgQgdd0kWvlHPwnARwzdv)Tpx9rGQt(OGlQSHEOf7fiLH)e5AKZOLGZRfc)yQp3m55Qpc4mxt(GFbq)MtpxyfGQM)5YKdbq)MtVIc8gzAPja)Z1HJqdRajBySHX3MjqODlMvkYctbs9KNR(iGNaH2TywPqrvaRM3fgNjR(BFU6JavJb95w9erQMXgioTOYg6HwSxGug(tK8C1hbC(M)QjHv9qGyBtF3Ak4H1OLGGjhCmqH0OSl6wfZ6)WnhAbMXUWkyoqiPaf06HaX2M(U1uWtGq7w8huYIdhCWPEdQVnLjh6fcSsjfD4yGcPrzx0TkM1FkWclSuufWQDImcbPq1pxQbW15QnjgvTsoaxTIQ(HHQpTAdxTvn2fgNjRofwGykIu9erQwzdvlnSwTti5wnnmreOAR65ThMnqkQSHEOf7fiLH)eDrizMay0JmaNNisEHa1FklQSHEOf7fiLH)etncbPGZ38NdovtcR6XpAfiZxk4H1OLGWHdo5yGqsbkO1Z12dZ2)CzoqiPaf065cRau18ei0Uf)XVtzHfMduink7IUvXEbmVXPS(tjdbGX5W(ciNcEmBc6jarg)Mt0W0dTEynAjiyoqiPaf065A7Hz7FUSWKatcGzB0sGjhUHpPEUYdiF8tPdhei0Uf)XVEdQZ6fcmXUGuMvJKck2pTnJMzQ3JlGz9pamyFbKtbpMnb9eGiJFZjAy6HwpSgTeeSWKdoHaX2M(U1uq4WbbcTBXF8R3G6SEHaJtbMyxqkZQrsbf7N2MrZm17XfWS(hagSVaYPGhZMGEcqKXV5enm9qRhwJwccwyYjgNPFZjiyYHAKuq96fczfLfh8DceA3IzHvNYKJqdRajBySHX3MjqODl(NIoCWPEdQVnLP9fqof8y2e0taIm(nNOHPhA9WA0sqWsrLn0dTyVaPm8NOlcjZeaJEKb48erYleO(tzrLn0dTyVaPm8NyQriifCEK0qcz1iPGI)P05B(ZjxJCgTe8yQp38iPHeYPgHGuGjhCQMew1JF0kqMVuWdRrlbHdhCYXaHKcuqRNRThMT)5YCGqsbkO1ZfwbOQ5jqODl(JFNYclmhOqAu2fDRI9cyEJtz9NsgcaJZH9fqof8y2e0taIm(nNOHPhA9WA0sqWCGqsbkO1Z12dZ2)CzHjbMeaZ2OLatoCdFs9CLhq(4NshoiqODl(JF9guN1leyIDbPmRgjfuSFABgnZuVhxaZ6FayW(ciNcEmBc6jarg)Mt0W0dTEynAjiyHjhCcbITn9DRPGWHdceA3I)4xVb1z9cbgNcmXUGuMvJKck2pTnJMzQ3JlGz9pamyFbKtbpMnb9eGiJFZjAy6HwpSgTeeSWKtmot)MtqWKd1iPG61leYkklo47ei0UfZcRusbMCeAyfizdJnm(2mbcTBX)u0Hdo1Bq9TPmTVaYPGhZMGEcqKXV5enm9qRhwJwccwkQcy1obYfIrB1bdHUawRgTYKQgTvh(K65kHQvJKckUAtR2PmuTti5wDqSHTAYB3BtRg90QVTAkGRMJNB1kQANwTAKuqXSunIuDaWvZrYyOA1iPGIzPOYg6HwSxGug(tCqUqmAZke6cy15B(JDbPmRgjfumR)uGjbcTBXFqbg4a7cszwnskOyw)tglmhOqAu2fDRIz93PfvbS6KtaCR(5w93(C1hbQ20QDkdvJ2QnPSA1iPGIRMJGydB1YJ7TPvlrBA1WIEPSR2wr1lsRgVMlMnszPOYg6HwSxGug(tK8C1hbC(M)CY1iNrlbpM6ZntEU6JamhOqAu2fDRIz93PmjWKay2gTeyYHB4tQNR8aYh)u6WbbcTBXF8R3G6SEHatSliLz1iPGI9tBZOzM694cyw)dad2xa5uWJztqpbiY43CIgMEO1dRrlbblm5GtiqSTPVBnfeoCqGq7w8h)6nOoRxiW4uGj2fKYSAKuqX(PTz0mt9ECbmR)bGb7lGCk4XSjONaez8Bordtp06H1OLGGfMQrsb1RxiKvuwCW3jqODlMvNwuzd9ql2lqkd)jsEU6JaopsAiHSAKuqX)u68n)5KRroJwcEm1NBEK0qczYZvFeGjNCnYz0sWJP(CZKNR(iaZbkKgLDr3Qyw)DktcmjaMTrlbMC4g(K65kpG8XpLoCqGq7w8h)6nOoRxiWe7cszwnskOy)02mAMPEpUaM1)aWG9fqof8y2e0taIm(nNOHPhA9WA0sqWcto4eceBB67wtbHdhei0Uf)XVEdQZ6fcmofyIDbPmRgjfuSFABgnZuVhxaZ6FayW(ciNcEmBc6jarg)Mt0W0dTEynAjiyHPAKuq96fczfLfh8DceA3Iz1PfvfvbSAglgd7aWfv2qp0I9agd7aW)d0oGvjMcI8uAHGZ38hwGKMKxVqiROCOfiRuYKtbq)MtpxyfGQM)5YKdofi1pq7awLykiYtPfcz6hz96nO(2uMCAd9qRFG2bSkXuqKNsle83MNYlLT6WX8jLzcmyBKuiRxi8r6q4dTazPOkGv)nYGSKWv)Wq1Fkrir1bDk7QzeGvaQAv)C9v)nsmQ6hgQoOtzxDWFw9ZTAAyIiq1w1ZBpmBGunh3SA1KWQGGLQnC1s0MwTHR(0QjVfx9erQMskIRw8i3MwnJaScqvZxuzd9ql2dymSdaZWFI0sesKrZSYgYWcHj58n)fa9Bo9CHvaQA(Nlto4unjSQxrbEJmT0eGhwJwcchoea9Bo9kkWBKPLMa8pxMduink7IUvXEbmVXPF8tPdhcG(nNEUWkavnpbcTBXF8tjfzXHd9cHSIYId(4NskwufWQ)gvHqxTAfvTjV0TANONreNTvh0PSRMrawbOQvTHRwI20QnC1NwDqOLreA1ea)KA13wTeHVnTAR65tk)oxt(GQhgwRgXfivRSHQjqOD7TPvlEetp0wnAwTYgQEEPS1IkBOhAXEaJHDayg(tm9zeXzBgnZ2xabPSD(M)deskqbTEUWkavnpbcTBXFeahoea9Bo9CHvaQA(NRdhQrsb1RxiKvuwCWhbGIfv2qp0I9agd7aWm8Ny6ZiIZ2mAMTVacsz78n)NseIWbhQrsb1RxiKvuwCW3dafzj5Wg6HwF6ZiIZ2mAMTVacsz7hiKuGcAzH1PeHiCWHEHqwrzXbFpau87deskqbTEUWkavnpbcTBXSKCyd9qRp9zeXzBgnZ2xabPS9deskqbTSuuzd9ql2dymSdaZWFIt04Hbr2(ciNczAWcD(M)yxqkZQrsbf7N2MrZm17XfWS(tbhoi2jYaxyvVjey)TSYiPitybsAsFK8OyrLn0dTypGXWoamd)j6(i3mPBtZ0sdRoFZFSliLz1iPGI9tBZOzM694cyw)PGdhe7ezGlSQ3ecS)wwzKuSOYg6HwShWyyhaMH)ev2q(T0O3kYtezaoFZF63C6jWGAjGX5jIma)Z1Hd63C6jWGAjGX5jImG8a9wfiESAdQ)Gskwuzd9ql2dymSdaZWFIKZ1vc5BZyxBafv2qp0I9agd7aWm8NyqiIuWfUntamATDaoFZF63C6L3eOLiKWJvBq9hbOOYg6HwShWyyhaMH)edHqejPmAMLVXjYccyHyNV5pSajnPpsgfzY5aHKcuqRNlScqvZ)ClQkQcy18kysLniQ(Bg6HwCrvaRoHlLnwnj1aX5QrKQ5F0kdm2aXPvJ2QPmygv18R5IzJ0Q)2NR(iqrLn0dTypwbtQSbXp55Qpc48n)hOqAu2fDRIz93Pm5qnjSQFVu2kwnj1aXdRrlbHdhQjHv94hTcK5lf8WA0sqWKd1KWQEiqSTPVBnf8WA0sqWCGqsbkO1dbITn9DRPGNaH2T4p(PGdhCQ3G6BtzHjxJCgTe84BtLqwnskOSWunskOE9cHSIYId(obcTBXSYilQcy18pAfiZxkundvZZMGEcqun)Bordtp0YOQMXU4hbQoiO6hgQgTq1PseTjRwrvBUUYKQ2jYieKcvROQv2q1H2TvRgjf0QVz1Nw9HRErA141CXSrA1jbQZvJrvBsz1iLnqQo0UTA1iPGwTrFYtpaxTlbnp1xuzd9ql2JvWKkBqWWFIUiKmtam6rgGZtejVqG6pLfv2qp0I9yfmPYgem8NyQriifC(M)2xa5uWJztqpbiY43CIgMEO1dRrlbbt63C6XpAfiZxk4FUmPFZPh)OvGmFPGNaH2T4pO0haMCIXz63CcIIQawn)JwbY8LcmQQ)gxxzsvJiv)TWKay2vh0PSRM(nNGOANiJqqkGlQSHEOf7XkysLniy4prxesMjag9idW5jIKxiq9NYIkBOhAXEScMuzdcg(tm1ieKcopsAiHSAKuqX)u68n)vtcR6XpAfiZxk4H1OLGGjhei0Uf)bLuWHd3WNupx5bKp(PKfMQrsb1RxiKvuwCW3jqODlMvkuufWQ5F0kqMVuOAgQMNnb9eGOA(3CIgMEOT6BRMpygv1FJRRmPQbJitQ6V95QpcuTY20Qd6KYQPHQjWKay2GO6jIuTRTci8gfv2qp0I9yfmPYgem8Ni55Qpc48n)vtcR6XpAfiZxk4H1OLGGP9fqof8y2e0taIm(nNOHPhA9WA0sqWKtbs9KNR(iGxVb13MYKRroJwcE8TPsiRgjf0IQawn)JwbY8LcvhuIvZZMGEcqun)Bordtp0YOQ(BbZ1vMu1tePAA0(Wv7esUvBRirePAiqfwbiQgVMlMnsRw8iMEO1xuzd9ql2JvWKkBqWWFIUiKmtam6rgGZtejVqG6pLfv2qp0I9yfmPYgem8NyQriifCEK0qcz1iPGI)P05B(RMew1JF0kqMVuWdRrlbbt7lGCk4XSjONaez8Bordtp06H1OLGGPAKuq96fczfLfhWkbcTBXm5GaH2T4pO0j7WbNyCM(nNGGLIQawn)JwbY8LcvZq1m2aXPmQQzSCHTAexGqobuTvnEnxmBKwTtKriifQMCPS1QTPcKQ)2NR(iq10WerGQzSbITn9DRPhAlQSHEOf7XkysLniy4prxesMjag9idW5jIKxiq9NYIkBOhAXEScMuzdcg(tm1ieKcoFZF1KWQE8JwbY8LcEynAjiyQMew1dbITn9DRPGhwJwccMdeskqbTEiqSTPVBnf8ei0Uf)bLmDja3C6q4P0tEU6Jamfi1tEU6JaEceA3Iznzm4ugF4MdTaZyxyfrnQXi]] )
    

end