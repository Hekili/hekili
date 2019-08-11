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


    spec:RegisterPack( "Assassination", 20190810, [[dafhYbqiurpsaCjjuuBcf9juiegfQWPqjwfku9kuWSOI6wQkPDrv)scAyiHogs0YuvQNrfPPjaDnjuTnui6BsOW4OIOohveADOqY7qHq08uv4EQQ2hkP)rfb5GQkHfQQOhIcftucLCruO0gPIG6JOqQgjkesDsQiIvIK8sjuKzIcP4MurK2PeyOsOulvvj6POQPkqDvuiuBffc(kkes2Rq)vsdwQdtzXi1JvyYeUmyZk6Zs0OrPoTkRgfsPxJKA2eDBbTBL(nKHtLoovey5iEoutN01vLTJk9DbY4fqNxcz9ibZNkSFrhPmgCKxykel4BksPtKIozkPO)BklEXDAXiYRf5crExBqTvcr(1cHi)xGXggFRPhAJ8UwrsKjIbh5XOhzarE2Q6Izufwy5PSF0(bkSq8f(KMEODqSPwi(chfg5PFNuDs2iDKxykel4BksPtKIozkPO)BklEXDAK3EkBejYZFHmMip7tiGnsh5faEe5dq2FbgBy8TMEOn7Vev(GKQaKnBvDXmQclS8u2pA)afwi(cFstp0oi2uleFHJctQcq2FXR8H1SPKIoN93uKsNy2FnBkPiJIIfpPkPkazZyyBBjGzujvbi7VM9xieGi7IPBqD2kkBbmTNuZ2g6H2SLhw9jvbi7VM9xcHiUq2QrkbTEtFsvaY(Rz)fcbiYMrmgY2jrHqC2CGEk(eq2Oz2yfmPYMfFKxEyfhdoYJvWKkBqedowaLXGJ8WA0sqe)mYpiNcKZI8duinQ6IUvXzZ6F2bmBMzZr2QjHv97vYwXQjPgiEynAjiY2HJSvtcR6XpAfiZxj4H1OLGiBMzZr2QjHv9qGyBlF3Ak4H1OLGiBMzpqiPaf06HaX2w(U1uWtGq7wC2F8N93z7Wr2CMTEdQVTmBwYMz2CnYz0sWJVTucv1iLGMnlzZmB1iLG61leQkQkoi7VMnbcTBXzZA2mYiVn0dTrEYZvFeiQXc(ogCKhwJwcI4Nr(jIuxiqnwaLrEBOhAJ8UiKSsam6rgquJf40yWrEynAjiIFg5hKtbYzrEJca5uWJztqpbiQ43CIgMEO1dRrlbr2mZM(nNE8JwbY8vc(NB2mZM(nNE8JwbY8vcEceA3IZ(JSP070SzMnNzJXv63CcIiVn0dTr(sJqqke1ybbmgCKhwJwcI4Nr(jIuxiqnwaLrEBOhAJ8UiKSsam6rgquJfu8yWrEynAjiIFg5THEOnYxAecsHi)GCkqolYRMew1JF0kqMVsWdRrlbr2mZMJSjqODlo7pYMYVZ2HJSDdFs9CLhqY(J)SPmBwYMz2Qrkb1RxiuvuvCq2FnBceA3IZM1S)oYpkAiHQAKsqXXcOmQXcyKXGJ8WA0sqe)mYpiNcKZI8QjHv94hTcK5Re8WA0sqKnZSnkaKtbpMnb9eGOIFZjAy6HwpSgTeezZmBoZwGup55Qpc41Bq9TLzZmBUg5mAj4X3wkHQAKsqJ82qp0g5jpx9rGOglOyedoYdRrlbr8Zi)erQleOglGYiVn0dTrExeswjag9idiQXcCYXGJ8WA0sqe)mYBd9qBKV0ieKcr(b5uGCwKxnjSQh)OvGmFLGhwJwcISzMTrbGCk4XSjONaev8Bordtp06H1OLGiBMzRgPeuVEHqvrvXbzZA2ei0UfNnZS5iBceA3IZ(JSP0jNTdhzZz2yCL(nNGiBwI8JIgsOQgPeuCSakJASaNym4ipSgTeeXpJ8tePUqGASakJ82qp0g5DrizLay0JmGOglGskgdoYdRrlbr8Zi)GCkqolYRMew1JF0kqMVsWdRrlbr2mZwnjSQhceBB57wtbpSgTeezZm7bcjfOGwpei22Y3TMcEceA3IZ(JSPmBMz7saU1YHWtPN8C1hbYMz2cK6jpx9rapbcTBXzZA2fpBgYoGzZ4zpCRHwGvSlSIiVn0dTr(sJqqke1Og5bmg2bGJbhlGYyWrEynAjiIFg5hKtbYzrEybszrE9cHQIQHwGzZA2uMnZS5mBbq)MtpxyfGQM)5MnZS5iBoZwGu)aTdyvIPGOoLwiuPFK1R3G6BlZMz2CMTn0dT(bAhWQetbrDkTqWFBDkVs2A2oCK98jLvcmyBKsOQxiK9hzxoe(qlWSzjYBd9qBKFG2bSkXuquNsleIASGVJbh5H1OLGi(zKFqofiNf5fa9Bo9CHvaQA(NB2mZMJS5mB1KWQEff4nQ0staEynAjiY2HJSfa9Bo9kkWBuPLMa8p3SzM9afsJQUOBvSxaZBCA2F8NnLz7Wr2cG(nNEUWkavnpbcTBXz)XF2usXSzjBhoYwVqOQOQ4GS)4pBkPyK3g6H2ipTeHev0SQSHkSqyrrnwGtJbh5H1OLGi(zKFqofiNf5hiKuGcA9CHvaQAEceA3IZ(JSDA2oCKTaOFZPNlScqvZ)CZ2HJSvJucQxVqOQOQ4GS)iBNsXiVn0dTr(YNreNTv0SAuaiiLDuJfeWyWrEynAjiIFg5hKtbYzr(PeHizZr2CKTAKsq96fcvfvfhK9xZ2PumBwYUyoBBOhARdeskqbTzZs2SM9uIqKS5iBoYwnsjOE9cHQIQIdY(Rz7ukM9xZEGqsbkO1ZfwbOQ5jqODloBwYUyoBBOhARdeskqbTzZsK3g6H2iF5ZiIZ2kAwnkaeKYoQXckEm4ipSgTeeXpJ8dYPa5Sip2fKYQAKsqX(PTv0Ss9ECbC2S(N93z7Wr2e7evGlSQ3ecS)2SznBgjfZMz2WcKYIY(JSlgumYBd9qBKFIgpmiQgfaYPqLgSWOglGrgdoYdRrlbr8Zi)GCkqolYJDbPSQgPeuSFABfnRuVhxaNnR)z)D2oCKnXorf4cR6nHa7VnBwZMrsXiVn0dTrE3h5MfDBzLwAynQXckgXGJ8WA0sqe)mYpiNcKZI80V50tGb1saJRteza(NB2oCKn9Bo9eyqTeW46ergqDGERcepwTb1z)r2usXiVn0dTrELnuFln6TI6ergquJf4KJbh5THEOnYtoxxjuVTIDTbe5H1OLGi(zuJf4eJbh5H1OLGi(zKFqofiNf5PFZPxEtGwIqcpwTb1z)r2onYBd9qBKpierk4c3wjagT2oGOglGskgdoYdRrlbr8Zi)GCkqolYdlqklk7pYU4umBMzZz2deskqbTEUWkavn)ZnYBd9qBKpecrKIQOzv(gNOkiGfIJAuJ8cyApPgdowaLXGJ8WA0sqe)mYpiNcKZI8CMnwbtQSbH3KYiVn0dTrEQVb1rnwW3XGJ82qp0g5XkysLDKhwJwcI4NrnwGtJbh5H1OLGi(zKh5g5XGg5THEOnYZ1iNrlHipxt(GipSaPSipbkHnBgY2fDy0cIkTeaboBgp7Ir2fZzZr2FNnJNn2fKYkBdRq2Se55AK6AHqKhwGuwuLaLWwhOq6BbruJfeWyWrEynAjiIFg5rUrEmOrEBOhAJ8CnYz0siYZ1KpiYJDbPSQgPeuSFABfnRuVhxaN9hz)DKNRrQRfcrE8TLsOQgPe0OglO4XGJ8WA0sqe)mYBd9qBK3OaMTrmCDIwTIMvxuqajYpiNcKZI8CMnwbtQSbH3KYSzMDOHvGunm2W4BRei0UfN9F2umBMzpqiPaf065cRau18ei0UfN9hztjfZMHSPKIzZ4zdobVZ1feEdZMRTaUsmkGi1bIyYSzMnNzla63C65cRau18p3SzMnNzla63C6vuG3Oslnb4FUr(1cHiVrbmBJy46eTAfnRUOGasuJfWiJbh5H1OLGi(zKFqofiNf5XkysLni8eu5dI82qp0g5hMuwTHEOTkpSg5LhwRRfcrEScMuzdIOglOyedoYdRrlbr8Zi)GCkqolYZr2CMTAsyvFOHvGunm2W4B9WA0sqKTdhzlqQV0ieKcE9guFBz2SKnZS5iBoZgCcENRli8gfWSnIHRt0Qv0S6Icciz7Wr2CM9aHKcuqRxAkSA1idBn)ZnBwI82qp0g5hMuwTHEOTkpSg5LhwRRfcr(Hah1ybo5yWrEynAjiIFg5THEOnYpmPSAd9qBvEynYlpSwxleI8cKg1yboXyWrEynAjiIFg5THEOnYpmPSAd9qBvEynYlpSwxleI8IJadnQXcOKIXGJ8WA0sqe)mYpiNcKZI8WcKYI8cyEJtZM1)SPS4zZq2CnYz0sWdlqklQsGsyRdui9TGiYBd9qBK3idBHQIiey1OglGskJbh5THEOnYBKHTq19jXqKhwJwcI4NrnwaLFhdoYBd9qBKxELSvCLr7tugcRg5H1OLGi(zuJAK3LaduiTPXGJfqzm4iVn0dTrEZ1vwu1fDy0g5H1OLGi(zuJf8Dm4iVn0dTrExKEOnYdRrlbr8ZOglWPXGJ8WA0sqe)mYBd9qBKp0iudI6erQcWu2r(b5uGCwKNyNOcCHv9MqG93MnRztzXJ8UeyGcPnTIHbAf4iFXJASGagdoYBd9qBKhRGjv2rEynAjiIFg1ybfpgCKhwJwcI4Nr(1cHiVrbmBJy46eTAfnRUOGasK3g6H2iVrbmBJy46eTAfnRUOGasuJAKxCeyOXGJfqzm4ipSgTeeXpJ8dYPa5Si)afsJQUOBvC2S(NDaZMHSvtcR6fa4cKkwjMALqOhwJwcISzMnhzla63C65cRau18p3SD4iBbq)MtVIc8gvAPja)ZnBhoYgwGuwKxaZBCA2F8NnhzdlxyrHvxeswfW8gNMnRoHYMJS)U4zZq2CnYz0sWdlqklQsGsyRdui9TGiBwYMLSD4iBoZMRroJwcE8TLsOQgPe0SzjBMzZr2CMTAsyvpei22Y3TMcEynAjiY2HJShiKuGcA9qGyBlF3Ak4jqODloBwZ(7SzjYBd9qBKhwUWIcJASGVJbh5H1OLGi(zKh5g5XGg5THEOnYZ1iNrlHipxt(Gi)afsJQUOBvSxaZBCA2SMnLz7Wr2WcKYI8cyEJtZ(J)S)U4zZq2CnYz0sWdlqklQsGsyRdui9TGiBhoYMZS5AKZOLGhFBPeQQrkbnYZ1i11cHi)dd15jLajQXcCAm4ipSgTeeXpJ8dYPa5SipxJCgTe8pmuNNucKSzMTrbGCk4HbB0TLvAPjaShwJwcISzMn2fKYQAKsqX(PTv0Ss9ECbC2S(N93rEBOhAJ8tBROzL694c4OgliGXGJ8WA0sqe)mYpiNcKZI8CnYz0sW)WqDEsjqYMz2CKn9Bo9SpHa2kT0ea2JvBqD2S(NnLoXSD4iBoYMZSDjhICArvcsn9qB2mZg7cszvnsjOy)02kAwPEpUaoBw)ZoGzZq2CKTrbGCk4fOhTeQceg8eBPoBwZ(7SzjBgYgRGjv2GWtqLpiBwYMLiVn0dTr(PTv0Ss9ECbCuJfu8yWrEynAjiIFg5THEOnYpTTIMvQ3JlGJ8dYPa5SipxJCgTe8pmuNNucKSzMn2fKYQAKsqX(PTv0Ss9ECbC2S(NTtJ8JIgsOQgPeuCSakJASagzm4ipSgTeeXpJ8dYPa5SipxJCgTe8pmuNNucKSzMnhzt)MtpT8wb(eG)5MTdhzZz2QjHv9CHffwjpmBpSgTeezZmBoZ2Oaqof8c0JwcvbcdEynAjiYMLiVn0dTrEA5Tc8jGOglOyedoYdRrlbr8ZiVn0dTr(WNEstHi)GCkqolYZ1iNrlb)dd15jLajBMzJDbPSQgPeuSFABfnRuVhxaN9F2Fh5hfnKqvnsjO4ybug1ybo5yWrEynAjiIFg5hKtbYzrEUg5mAj4FyOopPeirEBOhAJ8Hp9KMcrnQr(HahdowaLXGJ8WA0sqe)mYpiNcKZI8CMnwbtQSbH3KYSzMTaPEYZvFeWR3G6BlZMz2Hgwbs1WydJVTsGq7wC2)ztXiVn0dTr(HjLvBOhARYdRrE5H16AHqKhWyyhaoQXc(ogCKhwJwcI4NrEBOhAJ8HgHAquNisvaMYoYpiNcKZI8e7evGlSQ3ecS)5MnZS5iB1iLG61leQkQkoi7pYEGcPrvx0Tk2lG5nonBgpBk9fpBhoYEGcPrvx0Tk2lG5nonBw)ZE4wdTaRyxyfzZsKFu0qcv1iLGIJfqzuJf40yWrEynAjiIFg5hKtbYzrEIDIkWfw1Bcb2FB2SMTtPy2FnBIDIkWfw1Bcb2lEetp0MnZShOqAu1fDRI9cyEJtZM1)ShU1qlWk2fwrK3g6H2iFOrOge1jIufGPSJASGagdoYdRrlbr8Zi)GCkqolYZz2yfmPYgeEcQ8bzZmBbs9KNR(iGxVb13wMnZS5mBbq)MtpxyfGQM)5MnZS5iBoZwnjSQh)OvGmFLGhwJwcISD4iBoZ2Oaqof8y2e0taIk(nNOHPhA9WA0sqKTdhzlqQV0ieKcE3WNupx5bKSznBkZMz2CKn2fKYQAKsqX(PTv0Ss9ECbC2FKnJmBhoYMZShiKuGcA9CT9WS9p3SzjBwYMz2CKnNzRMew1VxjBfRMKAG4H1OLGiBhoYMZSvtcR6HaX2w(U1uWdRrlbr2oCK9aHKcuqRhceBB57wtbpbcTBXz)r2fp7VM93zZ4zRMew1laWfivSsm1kHqpSgTeezZs2mZMJS5mBWj4DUUGWBuaZ2igUorRwrZQlkiGKTdhzBuaiNcEmBc6jarf)Mt0W0dTEynAjiY2HJSfa9Bo9eJcisDGiMSka63C6fOG2SD4i7bcjfOGwVHzZ1waxjgfqK6armPNaH2T4S)iBkPy2mZEGqsbkO1ROaVrLwAcWtGq7wC2FKnLzZsK3g6H2ipxyfGQwuJfu8yWrEynAjiIFg5hKtbYzrE1KWQEiqSTLVBnf8WA0sqKnZS5iB1KWQ(9kzRy1KudepSgTeez7Wr2QjHv94hTcK5Re8WA0sqKnZS5AKZOLGhFBPeQQrkbnBwYMz2duinQ6IUvXzZ6F2d3AOfyf7cRiBMzpqiPaf06HaX2w(U1uWtGq7wC2FKnLzZmBoYMZSvtcR6XpAfiZxj4H1OLGiBhoYMZSnkaKtbpMnb9eGOIFZjAy6HwpSgTeez7Wr2cK6lncbPG3n8j1ZvEaj7p(ZMYSzjYBd9qBKNRThMDuJfWiJbh5H1OLGi(zKFqofiNf5vtcR63RKTIvtsnq8WA0sqKnZS5mB1KWQEiqSTLVBnf8WA0sqKnZShOqAu1fDRIZM1)ShU1qlWk2fwr2mZwa0V50ZfwbOQ5FUrEBOhAJ8CT9WSJASGIrm4ipSgTeeXpJ8i3ipg0iVn0dTrEUg5mAje55AYhe5nkaKtbpMnb9eGOIFZjAy6HwpSgTeezZmBoYErBfJR0V5eev1iLGIZM1)SPmBhoYg7cszvnsjOy)02kAwPEpUao7)SDA2SKnZS5iBmUs)MtquvJuckUA0iUq11wbeEJS)ZMIz7Wr2yxqkRQrkbf7N2wrZk17XfWzZ6F2mYSzjYZ1i11cHipgx5A7HzxhOvC6H2OglWjhdoYdRrlbr8ZiVn0dTrExeswjag9idiYdbQeRAHO3Qr(aw8i)erQleOglGYOglWjgdoYdRrlbr8Zi)GCkqolYRMew1JF0kqMVsWdRrlbr2mZMZSXkysLni8eu5dYMz2deskqbT(sJqqk4FUzZmBoYMRroJwcEmUY12dZUoqR40dTz7Wr2CMTrbGCk4XSjONaev8Bordtp06H1OLGiBMzlqQV0ieKcEcmjaMTrlHSzjBMzpqH0OQl6wf7fW8gNMnR)zZr2CKnLzZq2FNnJNTrbGCk4XSjONaev8Bordtp06H1OLGiBwYMXZg7cszvnsjOy)02kAwPEpUaoBwYMvNqzhWSzMnXorf4cR6nHa7VnBwZMYVJ82qp0g55A7Hzh1ybusXyWrEynAjiIFg5hKtbYzrE1KWQ(qdRaPAySHX36H1OLGiBMzZz2yfmPYgeEtkZMz2Hgwbs1WydJVTsGq7wC2F8NnfZMz2CMTaPEYZvFeWtGjbWSnAjKnZSfi1xAecsbpbcTBXzZA2onBMzla63C65cRau18p3SzMnhzZz2QjHv9kkWBuPLMa8WA0sqKTdhzla63C6vuG3Oslnb4FUzZs2mZMJS5mBaJHDaEAjcjQOzvzdvyHWI8HgJwejBhoYwa0V50tlrirfnRkBOclewK)5MnlrEBOhAJ8CT9WSJASakPmgCKhwJwcI4Nr(b5uGCwKNZSXkysLni8MuMnZSnkaKtbpMnb9eGOIFZjAy6HwpSgTeezZmBbs9LgHGuWtGjbWSnAjKnZSfi1xAecsbVB4tQNR8as2F8NnLzZm7bkKgvDr3QyVaM340Sz9pBkJ82qp0g5XSnbkOqqkIASak)ogCKhwJwcI4Nr(b5uGCwKxGup55Qpc4jqODloBwZoGzZq2bmBgp7HBn0cSIDHvKnZS5mBbs9LgHGuWtGjbWSnAje5THEOnYdbITT8DRPquJfqPtJbh5H1OLGi(zKFqofiNf5fi1tEU6JaE9guFBzK3g6H2iVIc8gvAPjGOglGYagdoYdRrlbr8Zi)GCkqolYt)MtpTeHeYhw9eWgA2oCKTaOFZPNlScqvZ)CJ82qp0g5Dr6H2OglGYIhdoYdRrlbr8Zi)GCkqolYla63C65cRau18p3iVn0dTrEAjcjQZhPOOglGsgzm4ipSgTeeXpJ8dYPa5SiVaOFZPNlScqvZ)CJ82qp0g5PbcgiuFBzuJfqzXigCKhwJwcI4Nr(b5uGCwKxa0V50ZfwbOQ5FUrEBOhAJ8ZJa0sese1ybu6KJbh5H1OLGi(zKFqofiNf5fa9Bo9CHvaQA(NBK3g6H2iVTdaRetwhMug1ybu6eJbh5H1OLGi(zK3g6H2iFPjHHjLabxPrOnYpiNcKZI8deskqbTEUWkavnpbcTBXzZA2bS4r(1cHiFPjHHjLabxPrOnQXc(MIXGJ8WA0sqe)mYBd9qBK3WS5AlGReJcisDGiMmYpiNcKZI8cG(nNEIrbePoqetwfa9Bo9cuqB2oCKTaOFZPNlScqvZtGq7wC2SMnLum7VMDaZMXZgCcENRli8gfWSnIHRt0Qv0S6Icciz7Wr2Qrkb1RxiuvuvCq2FK93umYVwie5nmBU2c4kXOaIuhiIjJASGVPmgCKhwJwcI4NrEBOhAJ8YhHAGGR3IpXHE4A5n1i)GCkqolYla63C65cRau18p3i)AHqKx(iudeC9w8jo0dxlVPg1ybF)Dm4ipSgTeeXpJ82qp0g5LpSsqpCTejfWwDLVqReI8dYPa5SiVaOFZPNlScqvZ)CJ8RfcrE5dRe0dxlrsbSvx5l0kHOgl4BNgdoYdRrlbr8ZiVn0dTr(sPjotreCneeMuEOnYpiNcKZI8cG(nNEUWkavn)ZnYdZjm06AHqKVuAIZuebxdbHjLhAJASGVdym4ipSgTeeXpJ82qp0g5lLM4mfrWvAtucr(b5uGCwKxa0V50ZfwbOQ5FUrEyoHHwxleI8LstCMIi4kTjkHOgl47IhdoYdRrlbr8ZiVn0dTr(rrdjsjO9gvAPH1i)GCkqolYhAyfivdJnm(2kbcTBXz)NnfZMz2CMTaOFZPNlScqvZ)CZMz2CMTaOFZPxrbEJkT0eG)5MnZSPFZPpecrKIQOzv(gNOkiGfI9cuqB2mZgwGuwu2FKTtMIzZmBbs9KNR(iGNaH2T4Szn7ag5H5egADTqiYpkAirkbT3OslnSg1ybFZiJbh5THEOnY)Wq9uieh5H1OLGi(zuJAKxG0yWXcOmgCKhwJwcI4NrEKBKhdAK3g6H2ipxJCgTeI8Cn5dI8UKdroTOkbPMEOnBMzJDbPSQgPeuSFABfnRuVhxaNnRz70SzMnhzlqQV0ieKcEceA3IZ(JShiKuGcA9LgHGuWlEetp0MTdhz7IomAbrLwcGaNnRzx8SzjYZ1i11cHipM6ZTokAiHAPriifIASGVJbh5H1OLGi(zKh5g5XGg5THEOnYZ1iNrlHipxt(GiVl5qKtlQsqQPhAZMz2yxqkRQrkbf7N2wrZk17XfWzZA2onBMzZr2cG(nNEff4nQ0sta(NB2oCKnhz7IomAbrLwcGaNnRzx8SzMnNzBuaiNcE8awTIMvAjcj8WA0sqKnlzZsKNRrQRfcrEm1NBDu0qcvYZvFeiQXcCAm4ipSgTeeXpJ8i3ipg0iVn0dTrEUg5mAje55AYhe5fa9Bo9CHvaQA(NB2mZMJSfa9Bo9kkWBuPLMa8p3SD4i7qdRaPAySHX3wjqODloBwZMIzZs2mZwGup55Qpc4jqODloBwZ(7ipxJuxleI8yQp3k55Qpce1ybbmgCKhwJwcI4Nr(b5uGCwKxnjSQhceBB57wtbpSgTeezZmBoYMJShOqAu1fDRIZM1)ShU1qlWk2fwr2mZEGqsbkO1dbITT8DRPGNaH2T4S)iBkZMLSD4iBoYMZS1Bq9TLzZmBoYwVqiBwZMskMTdhzpqH0OQl6wfNnR)z)D2SKnlzZsK3g6H2ip55Qpce1ybfpgCKhwJwcI4Nr(jIuxiqnwaLrEBOhAJ8UiKSsam6rgquJfWiJbh5H1OLGi(zKFqofiNf55iBoZwnjSQh)OvGmFLGhwJwcISD4iBoZMJShiKuGcA9CT9WS9p3SzM9aHKcuqRNlScqvZtGq7wC2F8NDaZMLSzjBMzpqH0OQl6wf7fW8gNMnR)ztz2mKTtZMXZMJSnkaKtbpMnb9eGOIFZjAy6HwpSgTeezZm7bcjfOGwpxBpmB)ZnBwYMz2eysamBJwczZmBoY2n8j1ZvEaj7p(ZMYSD4iBceA3IZ(J)S1BqDvVqiBMzJDbPSQgPeuSFABfnRuVhxaNnR)z70SziBJca5uWJztqpbiQ43CIgMEO1dRrlbr2SKnZS5iBoZgceBB57wtbr2oCKnbcTBXz)XF26nOUQxiKnJN93zZmBSliLv1iLGI9tBROzL694c4Sz9pBNMndzBuaiNcEmBc6jarf)Mt0W0dTEynAjiYMLSzMnNzJXv63CcISzMnhzRgPeuVEHqvrvXbz)1SjqODloBwYM1Sdy2mZMJSdnScKQHXggFBLaH2T4S)ZMIz7Wr2CMTEdQVTmBMzBuaiNcEmBc6jarf)Mt0W0dTEynAjiYMLiVn0dTr(sJqqke1ybfJyWrEynAjiIFg5NisDHa1ybug5THEOnY7IqYkbWOhzarnwGtogCKhwJwcI4NrEBOhAJ8LgHGuiYpiNcKZI8CMnxJCgTe8yQp36OOHeQLgHGuiBMzZr2CMTAsyvp(rRaz(kbpSgTeez7Wr2CMnhzpqiPaf065A7Hz7FUzZm7bcjfOGwpxyfGQMNaH2T4S)4p7aMnlzZs2mZEGcPrvx0Tk2lG5nonBw)ZMYSziBNMnJNnhzBuaiNcEmBc6jarf)Mt0W0dTEynAjiYMz2deskqbTEU2Ey2(NB2SKnZSjWKay2gTeYMz2CKTB4tQNR8as2F8NnLz7Wr2ei0UfN9h)zR3G6QEHq2mZg7cszvnsjOy)02kAwPEpUaoBw)Z2PzZq2gfaYPGhZMGEcquXV5enm9qRhwJwcISzjBMzZr2CMnei22Y3TMcISD4iBceA3IZ(J)S1BqDvVqiBgp7VZMz2yxqkRQrkbf7N2wrZk17XfWzZ6F2onBgY2Oaqof8y2e0taIk(nNOHPhA9WA0sqKnlzZmBoZgJR0V5eezZmBoYwnsjOE9cHQIQIdY(RztGq7wC2SKnRzt53zZmBoYo0WkqQggBy8TvceA3IZ(pBkMTdhzZz26nO(2YSzMTrbGCk4XSjONaev8Bordtp06H1OLGiBwI8JIgsOQgPeuCSakJASaNym4ipSgTeeXpJ8dYPa5Sip2fKYQAKsqXzZ6F2FNnZSjqODlo7pY(7SziBoYg7cszvnsjO4Sz9p7INnlzZm7bkKgvDr3Q4Sz9p7ag5THEOnYpixigTvfcDbSg1ybusXyWrEynAjiIFg5hKtbYzrEoZMRroJwcEm1NBL8C1hbYMz2duinQ6IUvXzZ6F2bmBMztGjbWSnAjKnZS5iB3WNupx5bKS)4pBkZ2HJSjqODlo7p(ZwVb1v9cHSzMn2fKYQAKsqX(PTv0Ss9ECbC2S(NTtZMHSnkaKtbpMnb9eGOIFZjAy6HwpSgTeezZs2mZMJS5mBiqSTLVBnfez7Wr2ei0UfN9h)zR3G6QEHq2mE2FNnZSXUGuwvJuck2pTTIMvQ3JlGZM1)SDA2mKTrbGCk4XSjONaev8Bordtp06H1OLGiBwYMz2Qrkb1RxiuvuvCq2FnBceA3IZM1SdyK3g6H2ip55Qpce1ybuszm4ipSgTeeXpJ82qp0g5jpx9rGi)GCkqolYZz2CnYz0sWJP(CRJIgsOsEU6JazZmBoZMRroJwcEm1NBL8C1hbYMz2duinQ6IUvXzZ6F2bmBMztGjbWSnAjKnZS5iB3WNupx5bKS)4pBkZ2HJSjqODlo7p(ZwVb1v9cHSzMn2fKYQAKsqX(PTv0Ss9ECbC2S(NTtZMHSnkaKtbpMnb9eGOIFZjAy6HwpSgTeezZs2mZMJS5mBiqSTLVBnfez7Wr2ei0UfN9h)zR3G6QEHq2mE2FNnZSXUGuwvJuck2pTTIMvQ3JlGZM1)SDA2mKTrbGCk4XSjONaev8Bordtp06H1OLGiBwYMz2Qrkb1RxiuvuvCq2FnBceA3IZM1SdyKFu0qcv1iLGIJfqzuJAuJ8Cbc(qBSGVPiLork6KPyaJ8bzK92sCK3jj0fruqKDXiBBOhAZwEyf7tQI8Ue08KqKpaz)fySHX3A6H2S)su5dsQcq2Sv1fZOkSWYtz)O9duyH4l8jn9q7GytTq8fokmPkaz)fVYhwZMsk6C2FtrkDIz)1SPKImkkw8KQKQaKnJHTTLaMrLufGS)A2FHqaISlMUb1zROSfW0EsnBBOhAZwEy1NufGS)A2FjeI4czRgPe06n9jvbi7VM9xieGiBgXyiBNefcXzZb6P4tazJMzJvWKkBw8jvjvbiBgBGW4PGiBAyIiq2duiTPztdL3I9z)fJb4Q4Sx0(v2gjC(KzBd9qloB0klYNufGSTHEOf7DjWafsB6)uAyQtQcq22qp0I9UeyGcPnLH)cTxziSQPhAtQcq22qp0I9UeyGcPnLH)cNiKiPkazZVMlMnsZMyNiB63CcISXQP4SPHjIazpqH0MMnnuEloBBfz7sGV6Iu92YSpC2c0c(KQaKTn0dTyVlbgOqAtz4Vq8AUy2iTIvtXjv2qp0I9UeyGcPnLH)cnxxzrvx0HrBsLn0dTyVlbgOqAtz4VqxKEOnPYg6HwS3LaduiTPm8xyOrOge1jIufGPSD2LaduiTPvmmqRa)xCNV5pXorf4cR6nHa7VLvklEsLn0dTyVlbgOqAtz4VqScMuzNuzd9ql27sGbkK2ug(l8HH6PqOZRfc)gfWSnIHRt0Qv0S6IccijvjvbiBgBGW4PGiBGlqkkB9cHSv2q22qrKSpC2gx7KgTe8jvbi7VeWkysLD23mBxegF0siBowu2CFYfigTeYgwi8aC23M9afsBkljv2qp0I)P(gu78n)5eRGjv2GWBszsLn0dTyg(leRGjv2jv2qp0Iz4VqUg5mAj48AHWpSaPSOkbkHToqH03ccN5AYh8dlqklYtGsyzWfDy0cIkTeabMXlgfZC8nJJDbPSY2WkWssLn0dTyg(lKRroJwcoVwi8JVTucv1iLG6mxt(GFSliLv1iLGI9tBROzL694c4p(oPYg6Hwmd)f(Wq9ui051cHFJcy2gXW1jA1kAwDrbbeNV5pNyfmPYgeEtkzgAyfivdJnm(2kbcTBX)uK5aHKcuqRNlScqvZtGq7w8husrgOKImo4e8oxxq4nmBU2c4kXOaIuhiIjzYPaOFZPNlScqvZ)CzYPaOFZPxrbEJkT0eG)5Muzd9qlMH)chMuwTHEOTkpS68AHWpwbtQSbHZ38hRGjv2GWtqLpiPYg6Hwmd)fomPSAd9qBvEy151cH)Ha78n)5Gt1KWQ(qdRaPAySHX36H1OLGWHdbs9LgHGuWR3G6BlzHjhCcobVZ1feEJcy2gXW1jA1kAwDrbbeho4CGqsbkO1lnfwTAKHTM)5YssLn0dTyg(lCysz1g6H2Q8WQZRfc)cKMuzd9qlMH)chMuwTHEOTkpS68AHWV4iWqtQSHEOfZWFHgzyluveHaR68n)HfiLf5fW8gNY6pLfNbUg5mAj4HfiLfvjqjS1bkK(wqKuzd9qlMH)cnYWwO6(KyiPYg6Hwmd)fkVs2kUYO9jkdHvtQsQcq2mgeskqbT4KkBOhAX(Ha)pmPSAd9qBvEy151cHFaJHDayNV5pNyfmPYgeEtkzkqQN8C1hb86nO(2sMHgwbs1WydJVTsGq7w8pftQcq2ojZSnHaNTrGSFUoNnEpxiBLnKnAHSd6u2zlrbbyn7GdUy5ZMrmgYoi2WMTOOBlZEAyfizRSTnBgtXoBbmVXPzJizh0PSrpnBBlkBgtX2Nuzd9ql2peyg(lm0iudI6erQcWu2opkAiHQAKsqX)u68n)j2jQaxyvVjey)ZLjhQrkb1RxiuvuvCWhduinQ6IUvXEbmVXPmoL(I7WXafsJQUOBvSxaZBCkR)d3AOfyf7cRGLKQaKTtYm7fLTje4Sd6KYSfhKDqNY(2Sv2q2leOMTtPi25SFyiBN0zXkB0MnncJZoOtzJEA22wu2mMITpPYg6HwSFiWm8xyOrOge1jIufGPSD(M)e7evGlSQ3ecS)wwDkf)kXorf4cR6nHa7fpIPhAzoqH0OQl6wf7fW8gNY6)WTgAbwXUWksQSHEOf7hcmd)fYfwbOQ58n)5eRGjv2GWtqLpGPaPEYZvFeWR3G6BlzYPaOFZPNlScqvZ)CzYbNQjHv94hTcK5Re8WA0sq4WbNgfaYPGhZMGEcquXV5enm9qRhwJwcchoei1xAecsbVB4tQNR8acRuYKdSliLv1iLGI9tBROzL694c4pyKoCW5aHKcuqRNRThMT)5Yclm5Gt1KWQ(9kzRy1KudepSgTeeoCWPAsyvpei22Y3TMcEynAjiC4yGqsbkO1dbITT8DRPGNaH2T4pk(x)MXvtcR6fa4cKkwjMALqOhwJwccwyYbNGtW7CDbH3OaMTrmCDIwTIMvxuqaXHdJca5uWJztqpbiQ43CIgMEO1dRrlbHdhcG(nNEIrbePoqetwfa9Bo9cuqRdhdeskqbTEdZMRTaUsmkGi1bIyspbcTBXFqjfzoqiPaf06vuG3Oslnb4jqODl(dkzjPkazZiy7HzNDqNYoBgBG4YSziBok4kzRy1KudeNZgrYM)rRaz(kHSrRSOSrB2ugmlmQSDsTaVWxy2mMID22kYMXgiUmBcyIIYEIizVqGA2m6mMIvsLn0dTy)qGz4VqU2Ey2oFZF1KWQEiqSTLVBnf8WA0sqWKd1KWQ(9kzRy1KudepSgTeeoCOMew1JF0kqMVsWdRrlbbtUg5mAj4X3wkHQAKsqzH5afsJQUOBvmR)d3AOfyf7cRG5aHKcuqRhceBB57wtbpbcTBXFqjto4unjSQh)OvGmFLGhwJwccho40Oaqof8y2e0taIk(nNOHPhA9WA0sq4WHaP(sJqqk4DdFs9CLhq(4NswsQcq2mc2Ey2zh0PSZUGRKTIvtsnqYMHSlaLnJnqCjJkBNulWl8fMnJPyNTTISzeGvaQAz)CtQSHEOf7hcmd)fY12dZ25B(RMew1VxjBfRMKAG4H1OLGGjNQjHv9qGyBlF3Ak4H1OLGG5afsJQUOBvmR)d3AOfyf7cRGPaOFZPNlScqvZ)CtQcq28aK98jLzpqHHWQzJ2SzRQlMrvyHLNY(r7hOWc)sJlSSrsH(1Gzmf(LOYhuyqh1xHFbgBy8TMEO9RFrXMrZx)sadgzW2Nuzd9ql2peyg(lKRroJwcoVwi8JXvU2Ey21bAfNEO1zUM8b)gfaYPGhZMGEcquXV5enm9qRhwJwccMCSOTIXv63CcIQAKsqXS(tPdhyxqkRQrkbf7N2wrZk17XfW)oLfMCGXv63CcIQAKsqXvJgXfQU2kGWB8trhoWUGuwvJuck2pTTIMvQ3JlGz9NrYssLn0dTy)qGz4Vqxeswjag9idW5jIuxiq9NsNHavIvTq0B1)aw8KkBOhAX(HaZWFHCT9WSD(M)QjHv94hTcK5Re8WA0sqWKtScMuzdcpbv(aMdeskqbT(sJqqk4FUm5GRroJwcEmUY12dZUoqR40dToCWPrbGCk4XSjONaev8Bordtp06H1OLGGPaP(sJqqk4jWKay2gTeyH5afsJQUOBvSxaZBCkR)CWbLm8nJBuaiNcEmBc6jarf)Mt0W0dTEynAjiyHXXUGuwvJuck2pTTIMvQ3JlGzHvNqbKjXorf4cR6nHa7VLvk)oPkazZiy7HzNDqNYoBNudRaj7VaJn8TmQSlaLnwbtQSZ2wr2lkBBOhxiBN0ViB63C6C2F5ZvFei7fPzFB2eysam7Sj2wcoNT4rUTmBgbyfGQgdb)PZzlEKBlZ(tjcjYgWyyPq23mBJRDsJwc(KkBOhAX(HaZWFHCT9WSD(M)QjHv9Hgwbs1WydJV1dRrlbbtoXkysLni8MuYm0WkqQggBy8TvceA3I)4NIm5uGup55Qpc4jWKay2gTeykqQV0ieKcEceA3Iz1Pmfa9Bo9CHvaQA(Nlto4unjSQxrbEJkT0eGhwJwcchoea9Bo9kkWBuPLMa8pxwyYbNagd7a80sesurZQYgQWcHf5dngTiIdhcG(nNEAjcjQOzvzdvyHWI8pxwsQcq28SnbkOqqkYEIizZZMGEcqKn)Bordtp0Muzd9ql2peyg(leZ2eOGcbPW5B(ZjwbtQSbH3KsMgfaYPGhZMGEcquXV5enm9qRhwJwccMcK6lncbPGNatcGzB0sGPaP(sJqqk4DdFs9CLhq(4NsMduinQ6IUvXEbmVXPS(tzsvaYMXgi22Y3TMczheByZMgPSZ(lFU6JazBRiBgDJqqkKTrGSFUzprKSLOTmByrVs2jv2qp0I9dbMH)cHaX2w(U1uW5B(lqQN8C1hb8ei0UfZAaziGm(WTgAbwXUWkyYPaP(sJqqk4jWKay2gTesQSHEOf7hcmd)fQOaVrLwAcW5B(lqQN8C1hb86nO(2YKkBOhAX(HaZWFHUi9qRZ38N(nNEAjcjKpS6jGnuhoea9Bo9CHvaQA(NBsLn0dTy)qGz4VqAjcjQZhPiNV5VaOFZPNlScqvZ)CtQSHEOf7hcmd)fsdemqO(2sNV5VaOFZPNlScqvZ)CtQSHEOf7hcmd)fopcqlriHZ38xa0V50ZfwbOQ5FUjv2qp0I9dbMH)cTDayLyY6WKsNV5VaOFZPNlScqvZ)CtQSHEOf7hcmd)f(Wq9ui051cH)stcdtkbcUsJqRZ38FGqsbkO1ZfwbOQ5jqODlM1aw8KkBOhAX(HaZWFHpmupfcDETq43WS5AlGReJcisDGiM05B(la63C6jgfqK6armzva0V50lqbToCia63C65cRau18ei0UfZkLu8RbKXbNG356ccVrbmBJy46eTAfnRUOGaIdhQrkb1RxiuvuvCWhFtXKkBOhAX(HaZWFHpmupfcDETq4x(iudeC9w8jo0dxlVP68n)fa9Bo9CHvaQA(NBsLn0dTy)qGz4VWhgQNcHoVwi8lFyLGE4AjskGT6kFHwj48n)fa9Bo9CHvaQA(NBsLn0dTy)qGz4VWhgQNcHodZjm06AHWFP0eNPicUgcctkp068n)fa9Bo9CHvaQA(NBsLn0dTy)qGz4VWhgQNcHodZjm06AHWFP0eNPicUsBIsW5B(la63C65cRau18p3KkBOhAX(HaZWFHpmupfcDgMtyO11cH)rrdjsjO9gvAPHvNV5FOHvGunm2W4BRei0Uf)trMCka63C65cRau18pxMCka63C6vuG3Oslnb4FUmPFZPpecrKIQOzv(gNOkiGfI9cuqltybszrF4KPitbs9KNR(iGNaH2TywdysvaYUybt7j1SNMusBdQZEIiz)WgTeY(uieZOYMrmgYgTzpqiPaf06tQSHEOf7hcmd)f(Wq9uieNuLufGSlwhbgA2cl0kHSn6tE6b4KQaKnJD5clkmBtZoGmKnhfNHSd6u2zxS4zjBgtX2NTtsyiiotbzrzJ2S)MHSvJuck25Sd6u2zZiaRau1CoBej7GoLD2b)jJiZgPSbsqhgYoi70SNis2yuiKnSaPSiF2FHeJYoi70SVz2m2aXLzpqH0OSpC2du4TLz)C9jv2qp0I9IJad9hwUWIcD(M)duinQ6IUvXS(hqgutcR6fa4cKkwjMALqOhwJwccMCia63C65cRau18pxhoea9Bo9kkWBuPLMa8pxhoGfiLf5fW8gN(XphWYfwuy1fHKvbmVXPS6eIJVlodCnYz0sWdlqklQsGsyRdui9TGGfwC4GtUg5mAj4X3wkHQAKsqzHjhCQMew1dbITT8DRPGhwJwcchogiKuGcA9qGyBlF3Ak4jqODlM1VzjPYg6HwSxCeyOm8xixJCgTeCETq4)HH68KsG4mxt(G)bkKgvDr3QyVaM34uwP0HdybszrEbmVXPF8)DXzGRroJwcEybszrvcucBDGcPVfeoCWjxJCgTe84BlLqvnsjOjvbiBgrDk7SzSd2OBlZ(tPjaSZz7e22SrZSlM2JlGZ20S)MHSvJuck2Nuzd9ql2locmug(lCABfnRuVhxa78n)5AKZOLG)HH68KsGW0Oaqof8WGn62YkT0ea2dRrlbbtSliLv1iLGI9tBROzL694cyw))oPkaz7e22SrZSlM2JlGZ20SP0jYq2y1guJZgnZMr0NqaB2FknbGZgrY2kTBXA2bKHS5O4mKDqNYo7If6rlHSlwimWs2Qrkbf7tQSHEOf7fhbgkd)foTTIMvQ3JlGD(M)CnYz0sW)WqDEsjqyYb9Bo9SpHa2kT0ea2JvBqnR)u6eD4GdoDjhICArvcsn9qltSliLv1iLGI9tBROzL694cyw)didCyuaiNcEb6rlHQaHbpXwQz9BwyaRGjv2GWtqLpGfwsQcq2oHTnB0m7IP94c4Svu2MRRSOSlwGjKfLDXgDy0M9nZ(wBOhxiB0MTTfLTAKsqZ20SDA2Qrkbf7tQSHEOf7fhbgkd)foTTIMvQ3JlGDEu0qcv1iLGI)P05B(Z1iNrlb)dd15jLaHj2fKYQAKsqX(PTv0Ss9ECbmR)onPYg6HwSxCeyOm8xiT8wb(eGZ38NRroJwc(hgQZtkbctoOFZPNwERaFcW)CD4Gt1KWQEUWIcRKhMThwJwccMCAuaiNcEb6rlHQaHbpSgTeeSKufGSd2O)Qt6tpPPq2kkBZ1vwu2flWeYIYUyJomAZ20S)oB1iLGItQSHEOf7fhbgkd)fg(0tAk48OOHeQQrkbf)tPZ38NRroJwc(hgQZtkbctSliLv1iLGI9tBROzL694c4)VtQSHEOf7fhbgkd)fg(0tAk48n)5AKZOLG)HH68KsGKuLufGSlwwOvczJ4cKS1leY2Op5PhGtQcq2mAUWtZMr3ieKc4SrB2lA)Ql5cjgPOSvJucko7jIKTYgY2LCiYPfLnbPMEOn7BMDXziBAjacC2gbY2KeWefL9ZnPYg6HwSxG0FUg5mAj48AHWpM6ZTokAiHAPriifCMRjFWVl5qKtlQsqQPhAzIDbPSQgPeuSFABfnRuVhxaZQtzYHaP(sJqqk4jqODl(JbcjfOGwFPriif8IhX0dToC4IomAbrLwcGaZAXzjPkazZO5cpn7V85QpcGZgTzVO9RUKlKyKIYwnsjO4SNis2kBiBxYHiNwu2eKA6H2SVz2fNHSPLaiWzBeiBtsatuu2p3KkBOhAXEbsz4VqUg5mAj48AHWpM6ZTokAiHk55Qpc4mxt(GFxYHiNwuLGutp0Ye7cszvnsjOy)02kAwPEpUaMvNYKdbq)MtVIc8gvAPja)Z1HdoCrhgTGOslbqGzT4m50Oaqof84bSAfnR0ses4H1OLGGfwsQcq2mAUWtZ(lFU6Ja4SVz2mcWkavngcgf4nY(tPjGcDsnScKS)cm2W4BZ(Wz)CZ2wr2bbzZ24cz)ndzJHbAf4SLWuZgTzRSHS)YNR(iq2fluWjv2qp0I9cKYWFHCnYz0sW51cHFm1NBL8C1hbCMRjFWVaOFZPNlScqvZ)CzYHaOFZPxrbEJkT0eG)56WrOHvGunm2W4BRei0UfZkfzHPaPEYZvFeWtGq7wmRFNufGS5DHXzYS)YNR(iq2yqFUzprKSzSbIltQSHEOf7fiLH)cjpx9raNV5VAsyvpei22Y3TMcEynAjiyYbhduinQ6IUvXS(pCRHwGvSlScMdeskqbTEiqSTLVBnf8ei0Uf)bLS4WbhCQ3G6BlzYHEHaRusrhogOqAu1fDRIz9)BwyHLKQaKnJUriifY(5snaUoNTjXOSvYb4Svu2pmK9PzB4STSXUW4mz2LWcetrKSNis2kBiBPH1Szmf7SPHjIazBzpV9WSbssLn0dTyVaPm8xOlcjReaJEKb48erQleO(tzsLn0dTyVaPm8xyPriifC(M)CWPAsyvp(rRaz(kbpSgTeeoCWjhdeskqbTEU2Ey2(NlZbcjfOGwpxyfGQMNaH2T4p(dilSWCGcPrvx0Tk2lG5noL1FkzWPmohgfaYPGhZMGEcquXV5enm9qRhwJwccMdeskqbTEU2Ey2(NllmjWKay2gTeyYHB4tQNR8aYh)u6WbbcTBXF8R3G6QEHatSliLv1iLGI9tBROzL694cyw)DkdgfaYPGhZMGEcquXV5enm9qRhwJwccwyYbNqGyBlF3AkiC4GaH2T4p(1BqDvVqGX)Mj2fKYQAKsqX(PTv0Ss9ECbmR)oLbJca5uWJztqpbiQ43CIgMEO1dRrlbblm5eJR0V5eem5qnsjOE9cHQIQId(kbcTBXSWAazYrOHvGunm2W4BRei0Uf)trho4uVb13wY0Oaqof8y2e0taIk(nNOHPhA9WA0sqWssLn0dTyVaPm8xOlcjReaJEKb48erQleO(tzsLn0dTyVaPm8xyPriifCEu0qcv1iLGI)P05B(ZjxJCgTe8yQp36OOHeQLgHGuGjhCQMew1JF0kqMVsWdRrlbHdhCYXaHKcuqRNRThMT)5YCGqsbkO1ZfwbOQ5jqODl(J)aYclmhOqAu1fDRI9cyEJtz9NsgCkJZHrbGCk4XSjONaev8Bordtp06H1OLGG5aHKcuqRNRThMT)5YctcmjaMTrlbMC4g(K65kpG8XpLoCqGq7w8h)6nOUQxiWe7cszvnsjOy)02kAwPEpUaM1FNYGrbGCk4XSjONaev8Bordtp06H1OLGGfMCWjei22Y3TMcchoiqODl(JF9gux1ley8VzIDbPSQgPeuSFABfnRuVhxaZ6VtzWOaqof8y2e0taIk(nNOHPhA9WA0sqWctoX4k9BobbtouJucQxVqOQOQ4GVsGq7wmlSs53m5i0WkqQggBy8TvceA3I)POdhCQ3G6BlzAuaiNcEmBc6jarf)Mt0W0dTEynAjiyjPkazZyixigTzhme6cynB0klkB0MD4tQNReYwnsjO4Snn7aYq2mMID2bXg2SjVDVTmB0tZ(2S)gNnhp3Svu2bmB1iLGIzjBejBNIZMJIZq2QrkbfZssLn0dTyVaPm8x4GCHy0wvi0fWQZ38h7cszvnsjOyw))MjbcTBXF8ndCGDbPSQgPeumR)fNfMduinQ6IUvXS(hWKQaKDXeaUz)CZ(lFU6JazBA2bKHSrB2MuMTAKsqXzZrqSHnB5X92YSLOTmByrVs2zBRi7fPzJxZfZgPSKuzd9ql2lqkd)fsEU6JaoFZFo5AKZOLGht95wjpx9raMduinQ6IUvXS(hqMeysamBJwcm5Wn8j1ZvEa5JFkD4GaH2T4p(1BqDvVqGj2fKYQAKsqX(PTv0Ss9ECbmR)oLbJca5uWJztqpbiQ43CIgMEO1dRrlbblm5GtiqSTLVBnfeoCqGq7w8h)6nOUQxiW4FZe7cszvnsjOy)02kAwPEpUaM1FNYGrbGCk4XSjONaev8Bordtp06H1OLGGfMQrkb1RxiuvuvCWxjqODlM1aMuzd9ql2lqkd)fsEU6JaopkAiHQAKsqX)u68n)5KRroJwcEm1NBDu0qcvYZvFeGjNCnYz0sWJP(CRKNR(iaZbkKgvDr3Qyw)ditcmjaMTrlbMC4g(K65kpG8XpLoCqGq7w8h)6nOUQxiWe7cszvnsjOy)02kAwPEpUaM1FNYGrbGCk4XSjONaev8Bordtp06H1OLGGfMCWjei22Y3TMcchoiqODl(JF9gux1ley8VzIDbPSQgPeuSFABfnRuVhxaZ6VtzWOaqof8y2e0taIk(nNOHPhA9WA0sqWct1iLG61leQkQko4Rei0UfZAatQsQcq2mwmg2bGtQSHEOf7bmg2bG)hODaRsmfe1P0cbNV5pSaPSiVEHqvr1qlqwPKjNcG(nNEUWkavn)ZLjhCkqQFG2bSkXuquNsleQ0pY61Bq9TLm50g6Hw)aTdyvIPGOoLwi4VToLxjB1HJ5tkReyW2iLqvVq4JYHWhAbYssvaY(lKbzfHZ(HHS)uIqISd6u2zZiaRau1Y(56Z(lKyu2pmKDqNYo7G)m7NB20WerGSTSN3Ey2ajBoUz2QjHvbblzB4SLOTmBdN9PztElo7jIKnLueNT4rUTmBgbyfGQMpPYg6HwShWyyhaMH)cPLiKOIMvLnuHfclY5B(la63C65cRau18pxMCWPAsyvVIc8gvAPjapSgTeeoCia63C6vuG3Oslnb4FUmhOqAu1fDRI9cyEJt)4Nshoea9Bo9CHvaQAEceA3I)4NskYIdh6fcvfvfh8XpLumPkaz)fQcHUA2kkBtELB2m6pJioBZoOtzNnJaScqvlBdNTeTLzB4Spn7GqlJi0Sja(j1SVnBjcFBz2w2ZNu(vUM8bzpmSMnIlqYwzdztGq72BlZw8iMEOnB0mBLnK98kzRjv2qp0I9agd7aWm8xy5ZiIZ2kAwnkaeKY25B(pqiPaf065cRau18ei0Uf)HtD4qa0V50ZfwbOQ5FUoCOgPeuVEHqvrvXbF4ukMuzd9ql2dymSdaZWFHLpJioBROz1OaqqkBNV5)uIqeo4qnsjOE9cHQIQId(QtPilfZdeskqbTSW6uIqeo4qnsjOE9cHQIQId(QtP4xhiKuGcA9CHvaQAEceA3IzPyEGqsbkOLLKkBOhAXEaJHDayg(lCIgpmiQgfaYPqLgSqNV5p2fKYQAKsqX(PTv0Ss9ECbmR)F7WbXorf4cR6nHa7VLvgjfzclqkl6JIbftQSHEOf7bmg2bGz4Vq3h5MfDBzLwAy15B(JDbPSQgPeuSFABfnRuVhxaZ6)3oCqStubUWQEtiW(BzLrsXKkBOhAXEaJHDayg(luzd13sJEROorKb48n)PFZPNadQLagxNiYa8pxhoOFZPNadQLagxNiYaQd0BvG4XQnO(dkPysLn0dTypGXWoamd)fsoxxjuVTIDTbKuzd9ql2dymSdaZWFHbHisbx42kbWO12b48n)PFZPxEtGwIqcpwTb1F40KkBOhAXEaJHDayg(lmecrKIQOzv(gNOkiGfID(M)WcKYI(O4uKjNdeskqbTEUWkavn)ZnPkPkazZRGjv2Gi7VyOhAXjvbi7cUs2y1KudeNZgrYM)rRmWydexMnAZMYGzuzZVMlMnsZ(lFU6Jajv2qp0I9yfmPYge)KNR(iGZ38FGcPrvx0TkM1)aYKd1KWQ(9kzRy1KudepSgTeeoCOMew1JF0kqMVsWdRrlbbtoutcR6HaX2w(U1uWdRrlbbZbcjfOGwpei22Y3TMcEceA3I)4)Bho4uVb13wYctUg5mAj4X3wkHQAKsqzHPAKsq96fcvfvfh8vceA3IzLrMufGS5F0kqMVsiBgYMNnb9eGiB(3CIgMEOLrLnJDXpcKDqq2pmKnAHSlLiAtMTIY2CDLfLnJUriifYwrzRSHSdTBZwnsjOzFZSpn7dN9I0SXR5IzJ0SlcuNZgJY2KYSrkBGKDODB2QrkbnBJ(KNEaoBxcAEQpPYg6HwShRGjv2GGH)cDrizLay0JmaNNisDHa1FktQSHEOf7XkysLniy4VWsJqqk48n)nkaKtbpMnb9eGOIFZjAy6HwpSgTeemPFZPh)OvGmFLG)5YK(nNE8JwbY8vcEceA3I)GsVtzYjgxPFZjisQcq28pAfiZxjWOY(lCDLfLnIK9xctcGzNDqNYoB63CcISz0ncbPaoPYg6HwShRGjv2GGH)cDrizLay0JmaNNisDHa1FktQSHEOf7XkysLniy4VWsJqqk48OOHeQQrkbf)tPZ38xnjSQh)OvGmFLGhwJwccMCqGq7w8hu(TdhUHpPEUYdiF8tjlmvJucQxVqOQOQ4GVsGq7wmRFNufGS5F0kqMVsiBgYMNnb9eGiB(3CIgMEOn7BZMpygv2FHRRSOSbJilk7V85QpcKTY20Sd6KYSPHSjWKay2Gi7jIKTRTci8gjv2qp0I9yfmPYgem8xi55Qpc48n)vtcR6XpAfiZxj4H1OLGGPrbGCk4XSjONaev8Bordtp06H1OLGGjNcK6jpx9raVEdQVTKjxJCgTe84BlLqvnsjOjvbiB(hTcK5ReYoOcZMNnb9eGiB(3CIgMEOLrL9xcMRRSOSNis20O9HZMXuSZ2wrHis2qGkScqKnEnxmBKMT4rm9qRpPYg6HwShRGjv2GGH)cDrizLay0JmaNNisDHa1FktQSHEOf7XkysLniy4VWsJqqk48OOHeQQrkbf)tPZ38xnjSQh)OvGmFLGhwJwccMgfaYPGhZMGEcquXV5enm9qRhwJwccMQrkb1RxiuvuvCaRei0UfZKdceA3I)GsNSdhCIXv63CccwsQcq28pAfiZxjKndzZydexYOYMXYf2SrCbc5eq2w241CXSrA2m6gHGuiBYvYwZ2MkqY(lFU6JaztdtebYMXgi22Y3TMEOnPYg6HwShRGjv2GGH)cDrizLay0JmaNNisDHa1FktQSHEOf7XkysLniy4VWsJqqk48n)vtcR6XpAfiZxj4H1OLGGPAsyvpei22Y3TMcEynAjiyoqiPaf06HaX2w(U1uWtGq7w8huY0LaCRLdHNsp55QpcWuGup55Qpc4jqODlM1IZqaz8HBn0cSIDHve5XUWiwW3f3jg1OgJa]] )
    

end