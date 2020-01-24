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


    spec:RegisterPack( "Assassination", 20200124, [[da1Z1bqiQipIkQUKQcuBcL8jKakgfQkNcvPvHQOEfsQzHQQBHe0Ue8lrLggsOJHKSmvL8mQOmnHOUMQcTnuf03eIuJtvbCoHizDOkuVdjGQMNOQUNQQ9HI6FibKdIQaluvrpevrmrvfuxevrAJcrO(OqemsKaQCsHiYkrIEPQcKzkeHCtHiQDkQyOQkilfjqpfvMQqQRIQq0wrcWxrcO0EPQ)kYGv5Wuwms9yfMmHld2SI(SOmAuQtR0Qrvi8AuKzt0TfQDl1VHmCQ0XrviTCephQPt66QY2rHVlKmEHW5fvz9Qk18Pc7xYEQ8r75eMc(C(IIFrrks1xroqXi1hDwKJSNtZZf8CU2Gjld8CTfdEoEagBy82MUO2Z5A5jrMWhTNdJEKb45yRQlMhNBUzRY(rhgO4CXB8tA6I6bXMAU4nEKRNJ(TsnsQ90EoHPGpNVOivrkQOIkQ8C2tzJiEoUnMN45yVcb0EApNaWdpNZRJhGXggVTPlQRJcIYEqrPZRJTQUyECU5MTk7hDyGIZfVXpPPlQheBQ5I34rUfLoVokT(zK8Q7lQ4VUVO4xuSOSO051XtyBDgG5XfLoVokSoEGqaI6(G2bt1PO6eW0EsToBOlQRtUynuu686OW6OGqmIbuNAKmqt7muu686OW64bcbiQJhjgQlssHyCD8HEkEfqDOzDyfmPYM3GNtUyf7J2ZHvWKkBq4J2Ndv(O9CqB0sq4)0ZniRcK18Cdumnk5I2wX1X8FDrUow1XxDQjHwd9MXwXQjzcibOnAjiQZHJ6utcTgWpAfiZxgeG2OLGOow1XxDQjHwdqeyRZEBBkeG2OLGOow1nqiPafvhGiWwN922uiqGyBBCD5)x3x15WrDovNUdM2oRoERJvDmmYA0siG3otcj1izGwhV1XQo1izGg0ngskkjwOokSoceBBJRJ564HEoBOlQ9CKNR(iGx958LpAph0gTee(p9Ctej1qeQphQ8C2qxu75CrizIay0JmaV6ZXz(O9CqB0sq4)0ZniRcK18C23azviGztqpbis43CIgMUOoaTrlbrDSQJ(nNb8JwbY8LbHNBDSQJ(nNb8JwbY8LbbceBBJRl)6Ok4S6yvNt1HXj63CccpNn0f1EUmJqqk4vFor2hTNdAJwcc)NEUjIKAic1NdvEoBOlQ9CUiKmram6rgGx958rF0EoOnAji8F65gKvbYAEo1KqRb8JwbY8LbbOnAjiQJvD8vhbITTX1LFDu9vDoCuNB8tQRRCbsD5)xhv1XBDSQtnsgObDJHKIsIfQJcRJaX2246yUUV8C2qxu75YmcbPGNBK3qcj1izGI95qLx95Wd9r75G2OLGW)PNBqwfiR55utcTgWpAfiZxgeG2OLGOow1zFdKvHaMnb9eGiHFZjAy6I6a0gTee1XQoNQtG0a55Qpce0DW02z1XQoggznAjeWBNjHKAKmq9C2qxu75ipx9raV6Zjs7J2ZbTrlbH)tp3ersneH6ZHkpNn0f1EoxesMiag9idWR(C(a(O9CqB0sq4)0ZniRcK18CQjHwd4hTcK5ldcqB0squhR6SVbYQqaZMGEcqKWV5enmDrDaAJwcI6yvNAKmqd6gdjfLeluhZ1rGyBBCDSQJV6iqSTnUU8RJQpqDoCuNt1HXj63CcI641ZzdDrTNlZieKcEUrEdjKuJKbk2NdvE1NtKYhTNdAJwcc)NEUjIKAic1NdvEoBOlQ9CUiKmram6rgGx95qff9r75G2OLGW)PNBqwfiR55utcTgWpAfiZxgeG2OLGOow1PMeAnarGTo7TTPqaAJwcI6yv3aHKcuuDaIaBD2BBtHabITTX1LFDuvhR6CjaJu2qeOkqEU6Ja1XQobsdKNR(iqGaX2246yUUpwh11f56456gUPylIe2fAHNZg6IApxMriif8Qx9Cagd9aW(O95qLpAph0gTee(p9CdYQaznph0ajlVGUXqsrPylI6yUoQQJvDovNaOFZzGb0cqvl8CRJvD8vNt1jqAyG6b0kXuqKMslgs0psh0DW02z1XQoNQZg6I6Wa1dOvIPGinLwme2onLBgBTohoQB(KYebgSnsgK0ngQl)6YgIqSfrD865SHUO2Znq9aALykistPfdE1NZx(O9CqB0sq4)0ZniRcK18CcG(nNbgqlavTWZTow1XxDovNAsO1GIIyhjAPjGa0gTee15WrDcG(nNbffXos0staHNBDSQBGIPrjx02koiG5owTU8)RJQ6C4Oobq)MZadOfGQwGaX2246Y)VoQOyD8wNdh1PBmKuusSqD5)xhvu0ZzdDrTNJwIqIeAMu2qcAiopV6ZXz(O9CqB0sq4)0ZniRcK18Cdeskqr1bgqlavTabITTX1LFDoRohoQta0V5mWaAbOQfEU15WrDQrYanOBmKuusSqD5xNZOONZg6IApx2ZiI16eAMSVbcsz7vFor2hTNdAJwcc)NEUbzvGSMNBkrisD8vhF1Pgjd0GUXqsrjXc1rH15mkwhV19bxNn0f1PbcjfOO664ToMRBkrisD8vhF1Pgjd0GUXqsrjXc1rH15mkwhfw3aHKcuuDGb0cqvlqGyBBCD8w3hCD2qxuNgiKuGIQRJxpNn0f1EUSNreR1j0mzFdeKY2R(C(OpAph0gTee(p9CdYQaznph2fKYKAKmqXHP1j0mXuVmaCDm)x3x15WrDeBfjGb0AWecCy76yUoEifRJvDqdKS8Ql)6I0u0ZzdDrTNBIgpmis23azvirdwSx95Wd9r75G2OLGW)PNBqwfiR55WUGuMuJKbkomToHMjM6LbGRJ5)6(QohoQJyRibmGwdMqGdBxhZ1XdPONZg6IApN7JSZ82olrlnS6vForAF0EoOnAji8F65gKvbYAEo63CgiWGjjGXPjImGWZTohoQJ(nNbcmyscyCAIidinqVwbsaR2GP6YVoQOONZg6IApNYgsVMg9ArAIidWR(C(a(O9C2qxu75iRRResBNWU2a8CqB0sq4)0R(CIu(O9CqB0sq4)0ZniRcK18C0V5mi3jqlriraR2GP6YVoN55SHUO2ZffIifmGTteaJARhGx95qff9r75G2OLGW)PNBqwfiR55Ggiz5vx(19rkwhR6CQUbcjfOO6adOfGQw4565SHUO2ZfdXisEj0mjFJvKeeWIXE1REobmTNu9r7ZHkF0EoOnAji8F65gKvbYAEoNQdRGjv2GiysPNZg6IApht7GjV6Z5lF0EoBOlQ9CyfmPY2ZbTrlbH)tV6ZXz(O9CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNdAGKLxGazqxh115IwmQbrIwcGaxhpxxKUUp464RUVQJNRd7cszITHvOoE9CmmsQTyWZbnqYYlrGmOtdum92GWR(CISpAph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45WUGuMuJKbkomToHMjM6LbGRl)6(YZXWiP2IbphE7mjKuJKbQx958rF0EoOnAji8F65SHUO2ZnmPmzdDrDsUy1ZniRcK18CyfmPYgebck7bEo5I1uBXGNdRGjv2GWR(C4H(O9CqB0sq4)0ZzdDrTNByszYg6I6KCXQNBqwfiR554RoNQtnj0Ai2WkqsggBy82bOnAjiQZHJ6einKzecsHGUdM2oRoE9CYfRP2Ibp3qG9QpNiTpAph0gTee(p9C2qxu75gMuMSHUOojxS65KlwtTfdEobs9QpNpGpAph0gTee(p9C2qxu75gMuMSHUOojxS65KlwtTfdEoXsGH6vForkF0EoOnAji8F65gKvbYAEoObswEbbm3XQ1X8FDu9X6OUoggznAjeGgiz5Liqg0PbkMEBq45SHUO2ZzKH1qsrec0Qx95qff9r75SHUO2ZzKH1qY9jXGNdAJwcc)NE1Ndvu5J2ZzdDrTNtUzSvCIhXtKfdT65G2OLGW)Px9QNZLadumTP(O95qLpApNn0f1EoZ1vMxYfTyu75G2OLGW)Px958LpApNn0f1EoxKUO2ZbTrlbH)tV6ZXz(O9CqB0sq4)0ZniRcK18CeBfjGb0AWecCy76yUoQ(ONZg6IApxSrycePjIKeGPS9CUeyGIPnnHHbQfyp3h9QpNi7J2ZzdDrTNdRGjv2EoOnAji8F6vFoF0hTNdAJwcc)NEU2IbpN9nMTrmCAIAnHMjxuuaXZzdDrTNZ(gZ2igonrTMqZKlkkG4vV65elbgQpAFou5J2ZbTrlbH)tp3GSkqwZZnqX0OKlABfxhZ)1f56OUo1KqRbbaUajHvIPwgehG2OLGOow1XxDcG(nNbgqlavTWZTohoQta0V5mOOi2rIwAci8CRZHJ6Ggiz5feWChRwx()1XxDqZaAuCYfHKjbm3XQ1XmfO64RUV(yDuxhdJSgTecqdKS8seid60aftVniQJ364TohoQZP6yyK1OLqaVDMesQrYaToERJvD8vNt1PMeAnarGTo7TTPqaAJwcI6C4OUbcjfOO6aeb26S32McbceBBJRJ56(QoE9C2qxu75GMb0OyV6Z5lF0EoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZnqX0OKlABfheWChRwhZ1rvDoCuh0ajlVGaM7y16Y)VUV(yDuxhdJSgTecqdKS8seid60aftVniQZHJ6CQoggznAjeWBNjHKAKmq9CmmsQTyWZ9WqAUsjq8QphN5J2ZbTrlbH)tp3GSkqwZZXWiRrlHWddP5kLaPow1zFdKvHamyJ2olrlnbGdqB0squhR6WUGuMuJKbkomToHMjM6LbGRJ5)6(YZzdDrTNBADcntm1lda7vFor2hTNdAJwcc)NEUbzvGSMNJHrwJwcHhgsZvkbsDSQJV6OFZzG9keqNOLMaWbSAdMQJ5)6OksvNdh1XxDovNlzrKvZlrqQPlQRJvDyxqktQrYafhMwNqZet9YaW1X8FDrUoQRJV6SVbYQqqGE0sijqyiqSMP6yUUVQJ36OUoScMuzdIabL9G64ToE9C2qxu75MwNqZet9YaWE1NZh9r75G2OLGW)PNBqwfiR55yyK1OLq4HH0CLsGuhR6WUGuMuJKbkomToHMjM6LbGRJ5)6CMNZg6IAp306eAMyQxga2ZnYBiHKAKmqX(COYR(C4H(O9CqB0sq4)0ZniRcK18CmmYA0si8WqAUsjqQJvD8vh9Bod0YTf4vaHNBDoCuNt1PMeAnWaAuCI8WSdqB0squhR6CQo7BGSkeeOhTescegcqB0squhVEoBOlQ9C0YTf4vaE1NtK2hTNdAJwcc)NEUbzvGSMNJHrwJwcHhgsZvkbsDSQd7cszsnsgO4W06eAMyQxgaUU)6(YZzdDrTNl(PR0uWZnYBiHKAKmqX(COYR(C(a(O9CqB0sq4)0ZniRcK18CmmYA0si8WqAUsjq8C2qxu75IF6knf8Qx9Cdb2hTphQ8r75G2OLGW)PNRTyWZzFJzBedNMOwtOzYfffq8C2qxu75SVXSnIHttuRj0m5IIciEUbzvGSMNZP6WkysLnicMuwhR6InScKKHXggVDIaX2246(RJI1XQo(QBGqsbkQoWaAbOQfiqSTnUU8Pav3aHKcuuDqrrSJeT0eqGaX22464TU8RJkkwh11rffRJNRd4rFRRlicgMndRbCIyFJiPbIyY6yvNt1ja63CgyaTau1cp36yvNt1ja63Cguue7irlnbeEUE1NZx(O9CqB0sq4)0ZzdDrTNByszYg6I6KCXQNBqwfiR55CQoScMuzdIGjL1XQobsdKNR(iqq3btBNvhR6InScKKHXggVDIaX2246(RJIEo5I1uBXGNdWyOha2R(CCMpAph0gTee(p9CdYQaznphXwrcyaTgmHahEU1XQo(QtnsgObDJHKIsIfQl)6gOyAuYfTTIdcyUJvRJNRJQWhRZHJ6gOyAuYfTTIdcyUJvRJ5)6gUPylIe2fArD865SHUO2ZfBeMarAIijbykBp3iVHesQrYaf7ZHkV6ZjY(O9CqB0sq4)0ZniRcK18CeBfjGb0AWecCy76yUoNrX6OW6i2ksadO1Gje4G4rmDrDDSQBGIPrjx02koiG5owToM)RB4MITisyxOfEoBOlQ9CXgHjqKMissaMY2R(C(OpAph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45CQo1KqRb8JwbY8LbbOnAjiQZHJ6CQo7BGSkeWSjONaej8BordtxuhG2OLGOohoQtG0qMriifcUXpPUUYfi1XCDuvhR64RoSliLj1izGIdtRtOzIPEza46YVoEyDoCuNt1nqiPafvhyy9IzhEU1XRNJHrsTfdEogqlavTe(rRaz(YG0a1Ivxu7vFo8qF0EoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5uDQjHwd9MXwXQjzcibOnAjiQZHJ6CQo1KqRbicS1zVTnfcqB0squNdh1nqiPafvhGiWwN922uiqGyBBCD5x3hRJcR7R6456utcTgea4cKewjMAzqCaAJwccphdJKAlg8CmGwaQAPEZyRy1KmbK0a1Ivxu7vForAF0EoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5uDap6BDDbrW(gZ2igonrTMqZKlkkGuNdh1zFdKvHaMnb9eGiHFZjAy6I6a0gTee15WrDcG(nNbI9nIKgiIjtcG(nNbbkQUohoQBGqsbkQoyy2mSgWjI9nIKgiIjdei22gxx(1rffRJvD8v3aHKcuuDqrrSJeT0eqGaX2246YVoQQZHJ6ea9BodkkIDKOLMacp3641ZXWiP2IbphdOfGQwAIAnnqTy1f1E1NZhWhTNdAJwcc)NEUbzvGSMNZP6WkysLniceu2dQJvDcKgipx9rGGUdM2oRow15uDcG(nNbgqlavTWZTow1XWiRrlHadOfGQwc)OvGmFzqAGAXQlQRJvDmmYA0siWaAbOQL6nJTIvtYeqsdulwDrDDSQJHrwJwcbgqlavT0e1AAGAXQlQ9C2qxu75yaTau18QpNiLpAph0gTee(p9CdYQaznpNAsO1aeb26S32McbOnAjiQJvD8vNAsO1qVzSvSAsMasaAJwcI6C4Oo1KqRb8JwbY8LbbOnAjiQJvDmmYA0siG3otcj1izGwhV1XQUbkMgLCrBR46y(VUHBk2IiHDHwuhR6giKuGIQdqeyRZEBBkeiqSTnUU8RJQ6yvhF15uDQjHwd4hTcK5ldcqB0squNdh15uD23azviGztqpbis43CIgMUOoaTrlbrDoCuNaPHmJqqkeCJFsDDLlqQl))6OQoE9C2qxu75yy9Iz7vFourrF0EoOnAji8F65gKvbYAEo1KqRHEZyRy1KmbKa0gTee1XQoNQtnj0AaIaBD2BBtHa0gTee1XQUbkMgLCrBR46y(VUHBk2IiHDHwuhR6ea9BodmGwaQAHNRNZg6IAphdRxmBV6ZHkQ8r75G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(apN9nqwfcy2e0taIe(nNOHPlQdqB0squhR64RUg1jmor)MtqKuJKbkUoM)RJQ6C4OoSliLj1izGIdtRtOzIPEza46(RZz1XBDSQJV6W4e9BobrsnsgO4KrJyajxRfq8oQ7VokwNdh1HDbPmPgjduCyADcntm1ldaxhZ)1XdRJxphdJKAlg8CyCIH1lMDAGAXQlQ9QphQ(YhTNdAJwcc)NEUjIKAic1NdvEoBOlQ9CUiKmram6rgGNdIqjwYIrVw9Cr(JE1NdvoZhTNdAJwcc)NEUbzvGSMNtnj0Aa)OvGmFzqaAJwcI6yvNt1HvWKkBqeiOShuhR6giKuGIQdzgHGui8CRJvD8vhdJSgTecyCIH1lMDAGAXQlQRZHJ6CQo7BGSkeWSjONaej8BordtxuhG2OLGOow1jqAiZieKcbcmjaMTrlH64Tow1nqX0OKlABfheWChRwhZ)1XxD8vhv1rDDFvhpxN9nqwfcy2e0taIe(nNOHPlQdqB0squhV1XZ1HDbPmPgjduCyADcntm1ldaxhV1XmfO6ICDSQJyRibmGwdMqGdBxhZ1r1xEoBOlQ9CmSEXS9QphQISpAph0gTee(p9CdYQaznpNAsO1qSHvGKmm2W4TdqB0squhR6CQoScMuzdIGjL1XQUydRajzySHXBNiqSTnUU8)RJI1XQoNQtG0a55QpceiWKay2gTeQJvDcKgYmcbPqGaX2246yUoNvhR6ea9BodmGwaQAHNBDSQJV6CQo1KqRbffXos0stabOnAjiQZHJ6ea9BodkkIDKOLMacp364Tow1XxDovhGXqpGaTeHej0mPSHe0qCEHyJhbIuNdh1ja63CgOLiKiHMjLnKGgIZl8CRJxpNn0f1EogwVy2E1NdvF0hTNdAJwcc)NEUbzvGSMNZP6WkysLnicMuwhR6SVbYQqaZMGEcqKWV5enmDrDaAJwcI6yvNaPHmJqqkeiWKay2gTeQJvDcKgYmcbPqWn(j11vUaPU8)RJQ6yv3aftJsUOTvCqaZDSADm)xhvEoBOlQ9Cy2MafvmifE1Ndv8qF0EoOnAji8F65gKvbYAEobsdKNR(iqGaX2246yUUixh11f56456gUPylIe2fArDSQZP6einKzecsHabMeaZ2OLGNZg6IApheb26S32McE1NdvrAF0EoOnAji8F65gKvbYAEobsdKNR(iqq3btBNvhR64RoNQd4rFRRlic23y2gXWPjQ1eAMCrrbK6C4OUbcjfOO6adOfGQwGaX2246yUoQOyD865SHUO2ZPOi2rIwAcWR(CO6d4J2ZbTrlbH)tp3GSkqwZZr)MZaTeHeYhwdeWgADoCuNaOFZzGb0cqvl8C9C2qxu75Cr6IAV6ZHQiLpAph0gTee(p9CdYQaznpNaOFZzGb0cqvl8C9C2qxu75OLiKinFK88QpNVOOpAph0gTee(p9CdYQaznpNaOFZzGb0cqvl8C9C2qxu75ObcgimTDMx958fv(O9CqB0sq4)0ZniRcK18CcG(nNbgqlavTWZ1ZzdDrTNBUeGwIqcV6Z5RV8r75G2OLGW)PNBqwfiR55ea9BodmGwaQAHNRNZg6IApN1daRetMgMu6vFoF5mF0EoOnAji8F65Alg8CzMegMuceCIgHApNn0f1EUmtcdtkbcorJqTNBqwfiR55giKuGIQdmGwaQAbceBBJRJ56I8h9QpNVISpAph0gTee(p9CTfdEodZMH1aorSVrK0armPNZg6IApNHzZWAaNi23isAGiM0ZniRcK18CcG(nNbI9nIKgiIjtcG(nNbbkQUohoQta0V5mWaAbOQfiqSTnUoMRJkkwhfwxKRJNRd4rFRRlic23y2gXWPjQ1eAMCrrbK6C4Oo1izGg0ngskkjwOU8R7lk6vFoF9rF0EoOnAji8F65gKvbYAEUydRajzySHXBNiqSTnUU)6OyDSQZP6ea9BodmGwaQAHNBDSQZP6ea9BodkkIDKOLMacp36yvh9BodXqmIKxcntY3yfjbbSyCqGIQRJvDqdKS8Ql)6(auSow1jqAG8C1hbcei22gxhZ1fzpNn0f1EUrEdjsjOEhjAPHvphmNWqtTfdEUrEdjsjOEhjAPHvV6Z5lEOpAph0gTee(p9CTfdEo5JWeqWPTXRyrpCkBNQNZg6IApN8ryci4024vSOhoLTt1ZniRcK18CcG(nNbgqlavTWZ1R(C(ks7J2ZbTrlbH)tpxBXGNt(Wkb9WPmKuaDYv(ITmWZzdDrTNt(Wkb9WPmKuaDYv(ITmWZniRcK18CcG(nNbgqlavTWZ1R(C(6d4J2ZbTrlbH)tp3GSkqwZZja63CgyaTau1cpxpNn0f1EUmPjwtreCkgeMuUO2ZbZjm0uBXGNltAI1uebNIbHjLlQ9QpNVIu(O9CqB0sq4)0ZniRcK18CcG(nNbgqlavTWZ1ZzdDrTNltAI1uebNOnrg45G5egAQTyWZLjnXAkIGt0Mid8QphNrrF0EoBOlQ9CpmKwfIXEoOnAji8F6vV65ei1hTphQ8r75G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(apNlzrKvZlrqQPlQRJvDyxqktQrYafhMwNqZet9YaW1XCDoRow1XxDcKgYmcbPqGaX2246YVUbcjfOO6qMriifcIhX0f115WrDUOfJAqKOLaiW1XCDFSoE9CmmsQTyWZHzADtJ8gsiLzecsbV6Z5lF0EoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5swez18seKA6I66yvh2fKYKAKmqXHP1j0mXuVmaCDmxNZQJvD8vNaOFZzqrrSJeT0eq45wNdh1XxDUOfJAqKOLaiW1XCDFSow15uD23azviGhqRj0mrlriraAJwcI64ToE9CmmsQTyWZHzADtJ8gsirEU6JaE1NJZ8r75G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(apNaOFZzGb0cqvl8CRJvD8vNaOFZzqrrSJeT0eq45wNdh1fByfijdJnmE7ebITTX1XCDuSoERJvDcKgipx9rGabITTX1XCDF55yyKuBXGNdZ06Mipx9raV6ZjY(O9CqB0sq4)0ZniRcK18CQjHwdqeyRZEBBkeG2OLGOow1XxD8v3aftJsUOTvCDm)x3WnfBrKWUqlQJvDdeskqr1bicS1zVTnfcei22gxx(1rvD8wNdh1XxDovNUdM2oRow1XxD6gd1XCDurX6C4OUbkMgLCrBR46y(VUVQJ364ToE9C2qxu75ipx9raV6Z5J(O9CqB0sq4)0ZnrKudrO(COYZzdDrTNZfHKjcGrpYa8QphEOpAph0gTee(p9CdYQaznphF15uDQjHwd4hTcK5ldcqB0squNdh15uD8v3aHKcuuDGH1lMD45whR6giKuGIQdmGwaQAbceBBJRl))6ICD8whV1XQUbkMgLCrBR4GaM7y16y(VoQQJ66CwD8CD8vN9nqwfcy2e0taIe(nNOHPlQdqB0squhR6giKuGIQdmSEXSdp364Tow1rGjbWSnAjuhR64Ro34Nuxx5cK6Y)VoQQZHJ6iqSTnUU8)Rt3btjDJH6yvh2fKYKAKmqXHP1j0mXuVmaCDm)xNZQJ66SVbYQqaZMGEcqKWV5enmDrDaAJwcI64Tow1XxDovheb26S32McI6C4OoceBBJRl))60DWus3yOoEUUVQJvDyxqktQrYafhMwNqZet9YaW1X8FDoRoQRZ(giRcbmBc6jarc)Mt0W0f1bOnAjiQJ36yvNt1HXj63CcI6yvhF1Pgjd0GUXqsrjXc1rH1rGyBBCD8whZ1f56yvhF1fByfijdJnmE7ebITTX19xhfRZHJ6CQoDhmTDwDSQZ(giRcbmBc6jarc)Mt0W0f1bOnAjiQJxpNn0f1EUmJqqk4vForAF0EoOnAji8F65MisQHiuFou55SHUO2Z5IqYebWOhzaE1NZhWhTNdAJwcc)NEUbzvGSMNZP6yyK1OLqaZ06Mg5nKqkZieKc1XQo(QZP6utcTgWpAfiZxgeG2OLGOohoQZP64RUbcjfOO6adRxm7WZTow1nqiPafvhyaTau1cei22gxx()1f564ToERJvDdumnk5I2wXbbm3XQ1X8FDuvh115S64564Ro7BGSkeWSjONaej8BordtxuhG2OLGOow1nqiPafvhyy9IzhEU1XBDSQJatcGzB0sOow1XxDUXpPUUYfi1L)FDuvNdh1rGyBBCD5)xNUdMs6gd1XQoSliLj1izGIdtRtOzIPEza46y(VoNvh11zFdKvHaMnb9eGiHFZjAy6I6a0gTee1XBDSQJV6CQoicS1zVTnfe15WrDei22gxx()1P7GPKUXqD8CDFvhR6WUGuMuJKbkomToHMjM6LbGRJ5)6CwDuxN9nqwfcy2e0taIe(nNOHPlQdqB0squhV1XQoNQdJt0V5ee1XQo(QtnsgObDJHKIsIfQJcRJaX22464ToMRJQVQJvD8vxSHvGKmm2W4Ttei22gx3FDuSohoQZP60DW02z1XQo7BGSkeWSjONaej8BordtxuhG2OLGOoE9C2qxu75YmcbPGNBK3qcj1izGI95qLx95eP8r75G2OLGW)PNBqwfiR55WUGuMuJKbkUoM)R7R6yvhbITTX1LFDFvh11XxDyxqktQrYafxhZ)19X64Tow1nqX0OKlABfxhZ)1fzpNn0f1EUbzJXOoPqSlGvV6ZHkk6J2ZbTrlbH)tp3GSkqwZZ5uDmmYA0siGzADtKNR(iqDSQBGIPrjx02kUoM)RlY1XQocmjaMTrlH6yvhF15g)K66kxGux()1rvDoCuhbITTX1L)FD6oykPBmuhR6WUGuMuJKbkomToHMjM6LbGRJ5)6CwDuxN9nqwfcy2e0taIe(nNOHPlQdqB0squhV1XQo(QZP6GiWwN922uquNdh1rGyBBCD5)xNUdMs6gd1XZ19vDSQd7cszsnsgO4W06eAMyQxgaUoM)RZz1rDD23azviGztqpbis43CIgMUOoaTrlbrD8whR6uJKbAq3yiPOKyH6OW6iqSTnUoMRlYEoBOlQ9CKNR(iGx95qfv(O9CqB0sq4)0ZniRcK18CovhdJSgTecyMw30iVHesKNR(iqDSQZP6yyK1OLqaZ06Mipx9rG6yv3aftJsUOTvCDm)xxKRJvDeysamBJwc1XQo(QZn(j11vUaPU8)RJQ6C4OoceBBJRl))60DWus3yOow1HDbPmPgjduCyADcntm1ldaxhZ)15S6OUo7BGSkeWSjONaej8BordtxuhG2OLGOoERJvD8vNt1brGTo7TTPGOohoQJaX2246Y)VoDhmL0ngQJNR7R6yvh2fKYKAKmqXHP1j0mXuVmaCDm)xNZQJ66SVbYQqaZMGEcqKWV5enmDrDaAJwcI64Tow1Pgjd0GUXqsrjXc1rH1rGyBBCDmxxK9C2qxu75ipx9rap3iVHesQrYaf7ZHkV6vV65yae8IAFoFrrQIuurfvu55IYi92zypxKuSlIOGOUiDD2qxuxNCXkouu65CjO5kbpNZRJhGXggVTPlQRJcIYEqrPZRJTQUyECU5MTk7hDyGIZfVXpPPlQheBQ5I34rUfLoVokT(zK8Q7lQ4VUVO4xuSOSO051XtyBDgG5XfLoVokSoEGqaI6(G2bt1PO6eW0EsToBOlQRtUynuu686OW6OGqmIbuNAKmqt7muu686OW64bcbiQJhjgQlssHyCD8HEkEfqDOzDyfmPYM3qrzrPZRJNgbmEkiQJgMicu3aftBAD0q224qD8GXaCvCDnQPq2gjE(K1zdDrnUoulZluu686SHUOghCjWaftB6)uAyMkkDED2qxuJdUeyGIPnL6)CTxwm0QPlQlkDED2qxuJdUeyGIPnL6)CNiKOO051X1MlMnsRJyROo63CcI6WQP46OHjIa1nqX0MwhnKTnUoRf15sak0fP62z1T46eOgcfLoVoBOlQXbxcmqX0Ms9FU42CXSrAcRMIlkTHUOghCjWaftBk1)5AUUY8sUOfJ6IsBOlQXbxcmqX0Ms9FUXgHjqKMissaMYMFxcmqX0MMWWa1c8)h5FN)eBfjGb0AWecCyBMP6JfL2qxuJdUeyGIPnL6)CXkysLDrPn0f14GlbgOyAtP(p3hgsRcX83wm8BFJzBedNMOwtOzYfffqkkTHUOghCjWaftBk1)56I0f1fLfLoVoEAeW4PGOoGbqYRoDJH6u2qD2qrK6wCDgdBLgTecfLoVokiGvWKk762zDUimEPLqD81O6y8KnqmAjuh0q8c462UUbkM2uElkTHUOg)Z0oyI)D(7ewbtQSbrWKYIsBOlQXu)NlwbtQSlkTHUOgt9FUmmYA0sG)2IHFObswEjcKbDAGIP3ge8ZWKp4hAGKLxGazqtTlAXOgejAjacmphP)G57lEg7cszITHvG3IsBOlQXu)NldJSgTe4VTy4hVDMesQrYaLFgM8b)yxqktQrYafhMwNqZet9YaW5)vrPn0f1yQ)ZDyszYg6I6KCXk)Tfd)yfmPYge8VZFScMuzdIabL9GIsBOlQXu)N7WKYKn0f1j5Iv(Blg(hcm)78NpNutcTgInScKKHXggVDaAJwcchoeinKzecsHGUdM2oJ3IsBOlQXu)N7WKYKn0f1j5Iv(Blg(fiTO0g6IAm1)5omPmzdDrDsUyL)2IHFXsGHwuAdDrnM6)CnYWAiPicbAL)D(dnqYYliG5owL5FQ(i1mmYA0sianqYYlrGmOtdum92GOO0g6IAm1)5AKH1qY9jXqrPn0f1yQ)ZvUzSvCIhXtKfdTwuAdDrnM6)CPTSeAMuYoycxuwu6864jiKuGIQXfL2qxuJddb()HH0Qqm)Tfd)23y2gXWPjQ1eAMCrrbe(35VtyfmPYgebtkzfByfijdJnmE7ebITTX)uKfFdeskqr1bgqlavTabITTX5tbAGqsbkQoOOi2rIwAciqGyBBmV5tffPMkkYZap6BDDbrWWSzynGte7BejnqetYYjbq)MZadOfGQw45YYjbq)MZGIIyhjAPjGWZTO0g6IACyiWu)N7WKYKn0f1j5Iv(Blg(bmg6bG5FN)oHvWKkBqemPKLaPbYZvFeiO7GPTZyfByfijdJnmE7ebITTX)uSO051fjnRZecCDgbQ75YFD4EDH6u2qDOgQlQvzxNeffG16Io6pCOoEKyOUOydDDI82oRUPHvGuNY2664jFO6eWChRwhIuxuRYg906SoV64jFOqrPn0f14WqGP(p3yJWeistejjatzZ)iVHesQrYaf)tf)78NyRibmGwdMqGdpxw8Pgjd0GUXqsrjXc5pqX0OKlABfheWChRYZuf(Odhdumnk5I2wXbbm3XQm)pCtXwejSl0cElkDEDrsZ6AuDMqGRlQvkRtSqDrTk7TRtzd11qeADoJIy(R7HH6IKNF46qDD0imUUOwLn6P1zDE1Xt(qHIsBOlQXHHat9FUXgHjqKMissaMYM)D(tSvKagqRbtiWHTz2zuKcj2ksadO1Gje4G4rmDrnRbkMgLCrBR4GaM7yvM)hUPylIe2fArrPZRJcaAbOQvNeLTdtw3a1IvxuBsCD0gge1H66gpcbAToSlmkkTHUOghgcm1)5YWiRrlb(Blg(zaTau1s4hTcK5ldsdulwDrn)mm5d(Dsnj0Aa)OvGmFzqaAJwcchoCY(giRcbmBc6jarc)Mt0W0f1bOnAjiC4qG0qMriifcUXpPUUYfimtfl(WUGuMuJKbkomToHMjM6LbGZNh6WHtdeskqr1bgwVy2HNlVfL2qxuJddbM6)CzyK1OLa)Tfd)mGwaQAPEZyRy1KmbK0a1IvxuZpdt(GFNutcTg6nJTIvtYeqcqB0sq4WHtQjHwdqeyRZEBBkeG2OLGWHJbcjfOO6aeb26S32McbceBBJZ)Ju4x8SAsO1GaaxGKWkXuldIdqB0squuAdDrnomeyQ)ZLHrwJwc83wm8ZWiRrlb(Blg(zaTau1stuRPbQfRUOMFgM8b)ob8OV11feb7BmBJy40e1AcntUOOaIdh23azviGztqpbis43CIgMUOoaTrlbHdhcG(nNbI9nIKgiIjtcG(nNbbkQ2HJbcjfOO6GHzZWAaNi23isAGiMmqGyBBC(urrw8nqiPafvhuue7irlnbeiqSTnoFQC4qa0V5mOOi2rIwAci8C5TO0g6IACyiWu)NldOfGQg)783jScMuzdIabL9awcKgipx9rGGUdM2oJLtcG(nNbgqlavTWZLfdJSgTecmGwaQAj8JwbY8LbPbQfRUOMfdJSgTecmGwaQAPEZyRy1KmbK0a1IvxuZIHrwJwcbgqlavT0e1AAGAXQlQlkDEDuawVy21f1QSRJNgboRoQRJVC2m2kwnjtaH)6qK64E0kqMVmOoulZRouxhvrZlpUUizlIn(fxhp5dvN1I64PrGZQJaMiV6MisDneHwxKap5dxuAdDrnomeyQ)ZLH1lMn)78xnj0AaIaBD2BBtHa0gTeeS4tnj0AO3m2kwnjtajaTrlbHdhQjHwd4hTcK5ldcqB0sqWIHrwJwcb82zsiPgjduEznqX0OKlABfZ8)WnfBrKWUqlynqiPafvhGiWwN922uiqGyBBC(uXIpNutcTgWpAfiZxgeG2OLGWHdNSVbYQqaZMGEcqKWV5enmDrDaAJwcchoeinKzecsHGB8tQRRCbs()uXBrPZRJcW6fZUUOwLDD5SzSvSAsMasDuxxoO64PrGZ4X1fjBrSXV464jFO6Swuhfa0cqvRUNBrPn0f14WqGP(pxgwVy28VZF1KqRHEZyRy1KmbKa0gTeeSCsnj0AaIaBD2BBtHa0gTeeSgOyAuYfTTIz(F4MITisyxOfSea9BodmGwaQAHNBrPZRJdG6MpPSUbkogATouxhBvDX84CZnBv2p6WafNlf0yanBKuOuy08KCPGOShKBultBU8am2W4TnDrnfYd(qrIOqkiGbJmyhkkTHUOghgcm1)5YWiRrlb(Blg(X4edRxm70a1IvxuZpdt(GF7BGSkeWSjONaej8BordtxuhG2OLGGfFnQtyCI(nNGiPgjdumZ)u5Wb2fKYKAKmqXHP1j0mXuVma8VZ4LfFyCI(nNGiPgjduCYOrmGKR1ciEh)u0HdSliLj1izGIdtRtOzIPEzayM)5H8wuAdDrnomeyQ)Z1fHKjcGrpYa4FIiPgIq)PIFicLyjlg9A9pYFSO0g6IACyiWu)NldRxmB(35VAsO1a(rRaz(YGa0gTeeSCcRGjv2GiqqzpG1aHKcuuDiZieKcHNll(yyK1OLqaJtmSEXStdulwDrTdhozFdKvHaMnb9eGiHFZjAy6I6a0gTeeSeinKzecsHabMeaZ2OLaVSgOyAuYfTTIdcyUJvz(Np(OI6V4z7BGSkeWSjONaej8BordtxuhG2OLGGxEg7cszsnsgO4W06eAMyQxgaMxMPafzweBfjGb0AWecCyBMP6RIsNxhfG1lMDDrTk76IKnScK64bySH3MhxxoO6WkysLDDwlQRr1zdDza1fjZdQJ(nN8xhf85QpcuxJ062UocmjaMDDeRZa(Rt8iBNvhfa0cqvJ6O)K)6epY2z19PeHe1bym0Fx3oRZyyR0OLqOO0g6IACyiWu)NldRxmB(35VAsO1qSHvGKmm2W4TdqB0sqWYjScMuzdIGjLSInScKKHXggVDIaX2248)PilNeinqEU6JabcmjaMTrlbwcKgYmcbPqGaX22yMDglbq)MZadOfGQw45YIpNutcTguue7irlnbeG2OLGWHdbq)MZGIIyhjAPjGWZLxw85eGXqpGaTeHej0mPSHe0qCEHyJhbI4WHaOFZzGwIqIeAMu2qcAioVWZL3IsNxhhBtGIkgKI6MisDCSjONae1X9Mt0W0f1fL2qxuJddbM6)CXSnbkQyqk4FN)oHvWKkBqemPKL9nqwfcy2e0taIe(nNOHPlQdqB0sqWsG0qMriifceysamBJwcSeinKzecsHGB8tQRRCbs()uXAGIPrjx02koiG5owL5FQkkDED80iWwN922uOUOydDD0iLDDuWNR(iqDwlQlsWieKc1zeOUNBDtePojQZQdA0lJDrPn0f14WqGP(pxicS1zVTnf4FN)cKgipx9rGabITTXmhzQJmppCtXwejSl0cwojqAiZieKcbcmjaMTrlHIsBOlQXHHat9FUkkIDKOLMa4FN)cKgipx9rGGUdM2oJfFob8OV11feb7BmBJy40e1AcntUOOaIdhdeskqr1bgqlavTabITTXmtff5TO0g6IACyiWu)NRlsxuZ)o)PFZzGwIqc5dRbcyd1Hdbq)MZadOfGQw45wuAdDrnomeyQ)ZLwIqI08rYJ)D(la63CgyaTau1cp3IsBOlQXHHat9FU0abdeM2oJ)D(la63CgyaTau1cp3IsBOlQXHHat9FUZLa0sesW)o)fa9BodmGwaQAHNBrPn0f14WqGP(pxRhawjMmnmPK)D(la63CgyaTau1cp3IsBOlQXHHat9FUpmKwfI5VTy4pZKWWKsGGt0iuZ)o)hiKuGIQdmGwaQAbceBBJzoYFSO0g6IACyiWu)N7ddPvHy(Blg(nmBgwd4eX(grsdeXK8VZFbq)MZaX(grsdeXKjbq)MZGafv7WHaOFZzGb0cqvlqGyBBmZurrkmY8mWJ(wxxqeSVXSnIHttuRj0m5IIcioCOgjd0GUXqsrjXc5)fflkTHUOghgcm1)5(WqAviMFyoHHMAlg(h5nKiLG6DKOLgw5FN)XgwbsYWydJ3orGyBB8pfz5KaOFZzGb0cqvl8Cz5KaOFZzqrrSJeT0eq45YI(nNHyigrYlHMj5BSIKGawmoiqr1SGgiz5L)hGISeinqEU6JabceBBJzoYfL2qxuJddbM6)CFyiTkeZFBXWV8ryci4024vSOhoLTtL)D(la63CgyaTau1cp3IsBOlQXHHat9FUpmKwfI5VTy4x(Wkb9WPmKuaDYv(ITmG)D(la63CgyaTau1cp3IsBOlQXHHat9FUpmKwfI5hMtyOP2IH)mPjwtreCkgeMuUOM)D(la63CgyaTau1cp3IsBOlQXHHat9FUpmKwfI5hMtyOP2IH)mPjwtreCI2eza)78xa0V5mWaAbOQfEUfLoVUpmmTNuRBAsjTnyQUjIu3dB0sOUvHympUoEKyOoux3aHKcuuDOO0g6IACyiWu)N7ddPvHyCrzrPZR7dVeyO1jSyldQZOx5QlGlkDED80Mb0O46mTUitDD89rQRlQvzx3hMJ364jFOqDrsXXGynfK5vhQR7lQRtnsgOy(RlQvzxhfa0cqvJ)6qK6IAv21f9NuGVoKYgirTyOUOSvRBIi1HrXqDqdKS8c1XdKyuDrzRw3oRJNgboRUbkMgv3IRBGI3oRUNBOO0g6IACqSeyO)qZaAum)78FGIPrjx02kM5)itTAsO1GaaxGKWkXuldIdqB0sqWIpbq)MZadOfGQw456WHaOFZzqrrSJeT0eq456Wb0ajlVGaM7y18))6JuZWiRrlHa0ajlVebYGonqX0BdchoCIHrwJwcb82zsiPgjduEzXNtQjHwdqeyRZEBBkeG2OLGWHJbcjfOO6aeb26S32McbceBBJz(lElkTHUOghelbgk1)5YWiRrlb(Blg(FyinxPei8ZWKp4FGIPrjx02koiG5owLzQC4aAGKLxqaZDSA()F9rQzyK1OLqaAGKLxIazqNgOy6TbHdhoXWiRrlHaE7mjKuJKbArPZRJcSRYUoE6GnA7S6(uAcaZFDrITUo0SUpOEza46mTUVOUo1izGIdfL2qxuJdILadL6)CNwNqZet9YaW8VZFggznAjeEyinxPeiSSVbYQqagSrBNLOLMaWbOnAjiyHDbPmPgjduCyADcntm1ldaZ8)xfLoVUiXwxhAw3huVmaCDMwhvrkQRdR2GjCDOzDuGBfcOR7tPjaCDisDwMTnwRlYuxhFFK66IAv219HrpAju3hgHbERtnsgO4qrPn0f14GyjWqP(p3P1j0mXuVmam)78NHrwJwcHhgsZvkbcl(OFZzG9keqNOLMaWbSAdMy(NQiLdh85KlzrKvZlrqQPlQzHDbPmPgjduCyADcntm1ldaZ8FKPMp7BGSkeeOhTescegceRzI5V4LAScMuzdIabL9aE5TO051fj266qZ6(G6LbGRtr1zUUY8Q7ddMqMxDFi0IrDD7SUTTHUmG6qDDwNxDQrYaTotRZz1PgjduCOO0g6IACqSeyOu)N706eAMyQxgaM)rEdjKuJKbk(Nk(35pdJSgTecpmKMRucewyxqktQrYafhMwNqZet9YaWm)7SIsBOlQXbXsGHs9FU0YTf4va8VZFggznAjeEyinxPeiS4J(nNbA52c8kGWZ1HdNutcTgyankorEy2bOnAjiy5K9nqwfcc0JwcjbcdbOnAji4TO051fTrtHrYpDLMc1PO6mxxzE19HbtiZRUpeAXOUotR7R6uJKbkUO0g6IACqSeyOu)NB8txPPa)J8gsiPgjdu8pv8VZFggznAjeEyinxPeiSWUGuMuJKbkomToHMjM6LbG))QO0g6IACqSeyOu)NB8txPPa)78NHrwJwcHhgsZvkbsrzrPZR7dBXwguhIbqQt3yOoJELRUaUO051fjAJxTUibJqqkGRd111OMcDjBmXi5vNAKmqX1nrK6u2qDUKfrwnV6ii10f11TZ6(i11rlbqGRZiqDMKaMiV6EUfL2qxuJdcK(ZWiRrlb(Blg(XmTUPrEdjKYmcbPa)mm5d(DjlISAEjcsnDrnlSliLj1izGIdtRtOzIPEzayMDgl(einKzecsHabITTX5pqiPafvhYmcbPqq8iMUO2Hdx0Irnis0saeyM)iVfLoVUirB8Q1rbFU6Ja46qDDnQPqxYgtmsE1PgjduCDtePoLnuNlzrKvZRocsnDrDD7SUpsDD0sae46mcuNjjGjYRUNBrPn0f14GaPu)NldJSgTe4VTy4hZ06Mg5nKqI8C1hb4NHjFWVlzrKvZlrqQPlQzHDbPmPgjduCyADcntm1ldaZSZyXNaOFZzqrrSJeT0eq456WbFUOfJAqKOLaiWm)rwozFdKvHaEaTMqZeTeHebOnAji4L3IsNxxKOnE16OGpx9raCD7SokaOfGQg1rJIyh19P0eqUrYgwbsD8am2W4TRBX19CRZArDrb1X2ya19f11HHbQf46KWuRd11PSH6OGpx9rG6(WOOlkTHUOgheiL6)CzyK1OLa)Tfd)yMw3e55QpcWpdt(GFbq)MZadOfGQw45YIpbq)MZGIIyhjAPjGWZ1HJydRajzySHXBNiqSTnMzkYllbsdKNR(iqGaX22yM)QO051X5cJ1K1rbFU6Ja1Hb95w3erQJNgboRO0g6IACqGuQ)ZL8C1hb4FN)QjHwdqeyRZEBBkeG2OLGGfF8nqX0OKlABfZ8)WnfBrKWUqlynqiPafvhGiWwN922uiqGyBBC(uXRdh85KUdM2oJfF6gdmtffD4yGIPrjx02kM5)V4LxElkDEDrcgHGuOUNlta4YFDMeJQtjlGRtr19WqDRwNHRZQd7cJ1K1LbnqmfrQBIi1PSH6KgwRJN8HQJgMicuNv3C7fZgifL2qxuJdcKs9FUUiKmram6rga)tej1qe6pvfL2qxuJdcKs9FUzgHGuG)D(ZNtQjHwd4hTcK5ldcqB0sq4WHt8nqiPafvhyy9IzhEUSgiKuGIQdmGwaQAbceBBJZ)pY8YlRbkMgLCrBR4GaM7yvM)PIANXZ8zFdKvHaMnb9eGiHFZjAy6I6a0gTeeSgiKuGIQdmSEXSdpxEzrGjbWSnAjWIp34Nuxx5cK8)PYHdceBBJZ)x3btjDJbwyxqktQrYafhMwNqZet9YaWm)7mQTVbYQqaZMGEcqKWV5enmDrDaAJwccEzXNtqeyRZEBBkiC4GaX2248)1DWus3yGN)If2fKYKAKmqXHP1j0mXuVmamZ)oJA7BGSkeWSjONaej8BordtxuhG2OLGGxwoHXj63Cccw8Pgjd0GUXqsrjXcuibITTX8YCKzXxSHvGKmm2W4Ttei22g)trhoCs3btBNXY(giRcbmBc6jarc)Mt0W0f1bOnAji4TO0g6IACqGuQ)Z1fHKjcGrpYa4FIiPgIq)PQO0g6IACqGuQ)ZnZieKc8pYBiHKAKmqX)uX)o)DIHrwJwcbmtRBAK3qcPmJqqkWIpNutcTgWpAfiZxgeG2OLGWHdN4BGqsbkQoWW6fZo8CznqiPafvhyaTau1cei22gN)FK5Lxwdumnk5I2wXbbm3XQm)tf1oJN5Z(giRcbmBc6jarc)Mt0W0f1bOnAjiynqiPafvhyy9IzhEU8YIatcGzB0sGfFUXpPUUYfi5)tLdhei22gN)VUdMs6gdSWUGuMuJKbkomToHMjM6LbGz(3zuBFdKvHaMnb9eGiHFZjAy6I6a0gTee8YIpNGiWwN922uq4WbbITTX5)R7GPKUXap)flSliLj1izGIdtRtOzIPEzayM)Dg123azviGztqpbis43CIgMUOoaTrlbbVSCcJt0V5eeS4tnsgObDJHKIsIfOqceBBJ5LzQ(IfFXgwbsYWydJ3orGyBB8pfD4WjDhmTDgl7BGSkeWSjONaej8BordtxuhG2OLGG3IsNxhpHSXyuxx0qSlG16qTmV6qDDXpPUUsOo1izGIRZ06Im11Xt(q1ffBORJ86E7S6qpTUTR7lCD89CRtr1f56uJKbkM36qK6CgUo((i11PgjdumVfL2qxuJdcKs9FUdYgJrDsHyxaR8VZFSliLj1izGIz()lwei22gN)xuZh2fKYKAKmqXm))rEznqX0OKlABfZ8FKlkDEDFqa4w3ZTok4ZvFeOotRlYuxhQRZKY6uJKbkUo(IIn01jxgBNvNe1z1bn6LXUoRf11iToCBUy2iL3IsBOlQXbbsP(pxYZvFeG)D(7edJSgTecyMw3e55QpcWAGIPrjx02kM5)iZIatcGzB0sGfFUXpPUUYfi5)tLdhei22gN)VUdMs6gdSWUGuMuJKbkomToHMjM6LbGz(3zuBFdKvHaMnb9eGiHFZjAy6I6a0gTee8YIpNGiWwN922uq4WbbITTX5)R7GPKUXap)flSliLj1izGIdtRtOzIPEzayM)Dg123azviGztqpbis43CIgMUOoaTrlbbVSuJKbAq3yiPOKybkKaX22yMJCrPn0f14GaPu)Nl55QpcW)iVHesQrYaf)tf)783jggznAjeWmTUPrEdjKipx9rawoXWiRrlHaMP1nrEU6JaSgOyAuYfTTIz(pYSiWKay2gTeyXNB8tQRRCbs()u5WbbITTX5)R7GPKUXalSliLj1izGIdtRtOzIPEzayM)Dg123azviGztqpbis43CIgMUOoaTrlbbVS4ZjicS1zVTnfeoCqGyBBC()6oykPBmWZFXc7cszsnsgO4W06eAMyQxgaM5FNrT9nqwfcy2e0taIe(nNOHPlQdqB0sqWll1izGg0ngskkjwGcjqSTnM5ixuwu6864Pym0daxuAdDrnoaym0da)pq9aALykistPfd8VZFObswEbDJHKIsXwemtflNea9BodmGwaQAHNll(CsG0Wa1dOvIPGinLwmKOFKoO7GPTZy5Kn0f1HbQhqRetbrAkTyiSDAk3m2QdhZNuMiWGTrYGKUXq(zdri2IG3IsNxhpqgLLhUUhgQ7tjcjQlQvzxhfa0cqvRUNBOoEGeJQ7HH6IAv21f9N19CRJgMicuNv3C7fZgi1X3oRtnj0ki4TodxNe1z1z46wToYRX1nrK6OII46epY2z1rbaTau1cfL2qxuJdagd9aWu)NlTeHej0mPSHe0qCE8VZFbq)MZadOfGQw45YIpNutcTguue7irlnbeG2OLGWHdbq)MZGIIyhjAPjGWZL1aftJsUOTvCqaZDSA()u5WHaOFZzGb0cqvlqGyBBC()urrED4q3yiPOKyH8)PIIfLoVoEGQqSRwNIQZKBwxxKWZiI166IAv21rbaTau1QZW1jrDwDgUUvRlkutbgTocGFsTUTRtIWBNvNv38jLuidt(G6ggwRdXai1PSH6iqST92z1jEetxuxhAwNYgQBUzS1IsBOlQXbaJHEayQ)Zn7zeXADcnt23abPS5FN)deskqr1bgqlavTabITTX57mhoea9BodmGwaQAHNRdhQrYanOBmKuusSq(oJIfL2qxuJdagd9aWu)NB2ZiI16eAMSVbcszZ)o)NseIWhFQrYanOBmKuusSaf6mkY7h8aHKcuunVmpLieHp(uJKbAq3yiPOKybk0zuKchiKuGIQdmGwaQAbceBBJ59dEGqsbkQM3IsBOlQXbaJHEayQ)ZDIgpmis23azvirdwm)78h7cszsnsgO4W06eAMyQxgaM5)VC4GyRibmGwdMqGdBZmpKISGgiz5LFKMIfL2qxuJdagd9aWu)NR7JSZ82olrlnSY)o)XUGuMuJKbkomToHMjM6LbGz()lhoi2ksadO1Gje4W2mZdPyrPn0f14aGXqpam1)5QSH0RPrVwKMiYa4FN)0V5mqGbtsaJttezaHNRdh0V5mqGbtsaJttezaPb61kqcy1gmLpvuSO0g6IACaWyOhaM6)CjRRResBNWU2akkTHUOghamg6bGP(p3OqePGbSDIayuB9akkTHUOghamg6bGP(p3yigrYlHMj5BSIKGawmM)D(dnqYYl)psrwonqiPafvhyaTau1cp3IsBOlQXbaJHEayQ)ZLaM72zPP0Ibm)78xnsgOb2Gjv2b3HY8hGIoCOgjd0aBWKk7G7qZ))lk6WHAKmqd6gdjfLChA6lkYSZOyrzrPZRJtbtQSbrD8GHUOgxu686YzZyJvtYeq4VoePoUhTsnpncCwDOUoQIMhxhxBUy2iTok4ZvFeOO0g6IACaRGjv2G4N8C1hb4FN)dumnk5I2wXm)hzw8PMeAn0BgBfRMKjGeG2OLGWHd1KqRb8JwbY8LbbOnAjiyXNAsO1aeb26S32McbOnAjiynqiPafvhGiWwN922uiqGyBBC()F5WHt6oyA7mEzXWiRrlHaE7mjKuJKbkVSuJKbAq3yiPOKybkKaX22yM5HfLoVoUhTcK5ldQJ664ytqpbiQJ7nNOHPlQ5X1XtB8Ja1ffu3dd1HAOUmjI2K1PO6mxxzE1fjyecsH6uuDkBOUyB76uJKbAD7SUvRBX11iToCBUy2iTU8aL)6WO6mPSoKYgi1fBBxNAKmqRZOx5QlGRZLGMRgkkTHUOghWkysLniO(pxxesMiag9idG)jIKAic9NQIsBOlQXbScMuzdcQ)ZnZieKc8VZF7BGSkeWSjONaej8BordtxuhG2OLGGf9Bod4hTcK5ldcpxw0V5mGF0kqMVmiqGyBBC(ufCglNW4e9BobrrPZRJ7rRaz(YaECD8axxzE1Hi1rbHjbWSRlQvzxh9BobrDrcgHGuaxuAdDrnoGvWKkBqq9FUUiKmram6rga)tej1qe6pvfL2qxuJdyfmPYgeu)NBMriif4FK3qcj1izGI)PI)D(RMeAnGF0kqMVmiaTrlbbl(iqSTnoFQ(YHd34Nuxx5cK8)PIxwQrYanOBmKuusSafsGyBBmZFvu6864E0kqMVmOoQRJJnb9eGOoU3CIgMUOUUTRJlAECD8axxzE1bgrMxDuWNR(iqDkBtRlQvkRJgQJatcGzdI6MisDUwlG4DuuAdDrnoGvWKkBqq9FUKNR(ia)78xnj0Aa)OvGmFzqaAJwccw23azviGztqpbis43CIgMUOoaTrlbblNeinqEU6JabDhmTDglggznAjeWBNjHKAKmqlkDEDCpAfiZxguxu5whhBc6jarDCV5enmDrnpUokiyUUY8QBIi1rJ6hUoEYhQoRf5Ii1brOqlarD42CXSrADIhX0f1HIsBOlQXbScMuzdcQ)Z1fHKjcGrpYa4FIiPgIq)PQO0g6IACaRGjv2GG6)CZmcbPa)J8gsiPgjdu8pv8VZF1KqRb8JwbY8LbbOnAjiyzFdKvHaMnb9eGiHFZjAy6I6a0gTeeSuJKbAq3yiPOKybMjqSTnMfFei22gNpvFahoCcJt0V5ee8wu6864E0kqMVmOoQRJNgboJhxhpLb01HyaeYkG6S6WT5IzJ06IemcbPqDKnJTwNnvGuhf85QpcuhnmreOoEAeyRZEBB6I6IsBOlQXbScMuzdcQ)Z1fHKjcGrpYa4FIiPgIq)PQO0g6IACaRGjv2GG6)CZmcbPa)78xnj0Aa)OvGmFzqaAJwccwQjHwdqeyRZEBBkeG2OLGG1aHKcuuDaIaBD2BBtHabITTX5tflxcWiLnebQcKNR(ialbsdKNR(iqGaX22yM)i1rMNhUPylIe2fAHNd7cdFoF9XiLx9Q3d]] )

end