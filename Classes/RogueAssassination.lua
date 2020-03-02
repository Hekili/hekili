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


    spec:RegisterPack( "Assassination", 20200301, [[daLQ4bqiQipsiYLuvIytOIpPQKuAuivDkuIvHskVcjzwuHUfkj2fv9lrLgMQsDmKOLPQWZOIY0eI6AiHSnvLuFtvj04OIQ6CQkjwhvuX7uvsQmprvDpvv7Jk4FQkj5GiHYcvv0drjvnrvLOUikj1gPIkPpIsQ0ivvsQ6KurLALiPEPQsKMjkPIUjkjPDkQyOurvwksO6POQPkKCvusf2QQsWxvvsk2RG)kYGv6WuwmkESctMWLbBwrFwugnk1Pvz1urL41ivMnr3wO2Tu)gYWPshhLKy5iEoutN01vLTJu(UqQXleoVOkRhjy(Os7xYbkdrf4fMcHC(47p((BN9nLEk)6VP8Jpc8AEUqG31g0zzqGVTyiWtXWydJV20d1bExlpjYeHOc8y0JmGapBvDXoNCZn7u2pg)afNl(IFstpupi2uZfFXJCd8mVtQo3DGjWlmfc58X3F893o7Bk9u(1FtjLFLaV9u2isGN)Iz9bE2NqaDGjWla8iWhPAPyySHXxB6H6AP4OShuuhPAzRQl25KBUzNY(X4hO4CXx8tA6H6bXMAU4lEKBrDKQLv1id21sPJ1(X3F8DrDrDKQL1Z26ma7CkQJuTSsTumHae1(LEd6Qvr1kGP9KAT2qpuxR8WQVOos1Yk1sXHyenOw1izGMUPVOos1Yk1sXecqulRdmuRZTcX4APh9u8jGArZAXkysLnl(aV8WkoevGhRGjv2Gievihkdrf4H2yKGi8zGFqofiNf4hOyguYfDTIR1H)AJCTCQL(AvtcT67lJTIvtshq8qBmsqulxU1QMeA1JFmkqMVmWdTXibrTCQL(AvtcT6HiWwN9U2uWdTXibrTCQDGqsbk62drGTo7DTPGNaX214AZ)V2pQLl3ADQw9g0DDwTSulNAPzKZyKGhFDMesQrYaTwwQLtTQrYa1RxmKuusCqTSsTei2UgxRd1(1bEBOhQd8KNR(iqqd58riQap0gJeeHpd8tej1qeAihkd82qpuh4DrizIay0JmGGgYXzHOc8qBmsqe(mWpiNcKZc8gfaYPGhZMGEcqKWV5enm9qThAJrcIA5ulZBo94hJcK5ld8p3A5ulZBo94hJcK5ld8ei2UgxB(1sP3z1YPwNQfJtmV5eebEBOhQd8zgHGuiOHCICiQap0gJeeHpd8tej1qeAihkd82qpuh4DrizIay0JmGGgYHIcrf4H2yKGi8zG3g6H6aFMriifc8dYPa5SaVAsOvp(XOaz(Yap0gJee1YPw6RLaX214AZVwk)OwUCR1n(j1ZvEaP28)RLYAzPwo1QgjduVEXqsrjXb1Yk1sGy7ACTou7hb(rEdjKuJKbkoKdLbnKZxhIkWdTXibr4Za)GCkqolWRMeA1JFmkqMVmWdTXibrTCQ1Oaqof8y2e0taIe(nNOHPhQ9qBmsqulNADQwbs9KNR(iGxVbDxNvlNAPzKZyKGhFDMesQrYanWBd9qDGN8C1hbcAiNVyiQap0gJeeHpd8tej1qeAihkd82qpuh4DrizIay0JmGGgYX5hIkWdTXibr4ZaVn0d1b(mJqqke4hKtbYzbE1KqRE8JrbY8LbEOngjiQLtTgfaYPGhZMGEcqKWV5enm9qThAJrcIA5uRAKmq96fdjfLehuRd1sGy7ACTCQL(AjqSDnU28RLsNFTC5wRt1IXjM3CcIAzjWpYBiHKAKmqXHCOmOHC(kHOc8qBmsqe(mWprKudrOHCOmWBd9qDG3fHKjcGrpYacAihk)oevGhAJrcIWNb(b5uGCwGxnj0Qh)yuGmFzGhAJrcIA5uRAsOvpeb26S31McEOngjiQLtTdeskqr3EicS1zVRnf8ei2UgxB(1szTCQ1La0szdHNsp55QpculNAfi1tEU6JaEceBxJR1HAPOAPQ2ixlRv7WnfBrKWUqlc82qpuh4ZmcbPqqdAGhWyOhaoevihkdrf4H2yKGi8zGFqofiNf4Hgiz551lgskkfBruRd1szTCQ1PAfaZBo90GwaQA(NBTCQL(ADQwbs9dupGwjMcI0uAXqI5rAVEd6UoRwo16uT2qpu7hOEaTsmfePP0Ib)1PP8YyR1YLBTZNuMiWGTrYGKEXqT5xB2q4JTiQLLaVn0d1b(bQhqRetbrAkTyiOHC(ievGhAJrcIWNb(b5uGCwGxamV50tdAbOQ5FU1YPw6R1PAvtcT6vue3iXinb4H2yKGOwUCRvamV50ROiUrIrAcW)CRLtTdumdk5IUwXEbmVXP1M)FTuwlxU1kaM3C6PbTau18ei2UgxB()1s531YsTC5wREXqsrjXb1M)FTu(DG3g6H6apJeHej0mPSHe0qCEbnKJZcrf4H2yKGi8zGFqofiNf4hiKuGIU90GwaQAEceBxJRn)ADwTC5wRayEZPNg0cqvZ)CRLl3AvJKbQxVyiPOK4GAZVwN9DG3g6H6aF2ZiIZ6eAMmkaeKYoOHCICiQap0gJeeHpd8dYPa5Sa)uIqKAPVw6RvnsgOE9IHKIsIdQLvQ1zFxll1(LuRn0d1PbcjfOO7AzPwhQDkrisT0xl91QgjduVEXqsrjXb1Yk16SVRLvQDGqsbk62tdAbOQ5jqSDnUwwQ9lPwBOhQtdeskqr31YsG3g6H6aF2ZiIZ6eAMmkaeKYoOHCOOqubEOngjicFg4hKtbYzbESliLj1izGI9tRtOzIU(Ob4AD4V2pQLl3Aj2jsanOvVjey)116qTF931YPwObswE1MFTFXVd82qpuh4NOXddIKrbGCkKyaloOHC(6qubEOngjicFg4hKtbYzbESliLj1izGI9tRtOzIU(Ob4AD4V2pQLl3Aj2jsanOvVjey)116qTF93bEBOhQd8UpYnZ76SeJ0WAqd58fdrf4H2yKGi8zGFqofiNf4zEZPNad6KagNMiYa8p3A5YTwM3C6jWGojGXPjImG0a9AfiESAd6Qn)AP87aVn0d1bELnKEnd61I0ergqqd548drf4THEOoWtoxxjKUoHDTbe4H2yKGi8zqd58vcrf4THEOoWhnIif0GRteaJARhqGhAJrcIWNbnKdLFhIkWdTXibr4Za)GCkqolWdnqYYR28RLI(Uwo16uTdeskqr3EAqlavn)ZnWBd9qDGpgIrK8sOzs(gNijiGfJdAihkPmevGhAJrcIWNb(b5uGCwGxnsgOE2Gjv2E3HwRd168)UwUCRvnsgOE2Gjv2E3HwB()1(X31YLBTQrYa1RxmKuuYDOPp(UwhQ1zFh4THEOoWtaZ96S0uAXaoObnWlGP9KAiQqougIkWdTXibr4Za)GCkqolW7uTyfmPYgeEtkd82qpuh4P7g0f0qoFeIkWBd9qDGhRGjv2bEOngjicFg0qoolevGhAJrcIWNbEKBGhdAG3g6H6apnJCgJec80m5dc8qdKS88eid6APQwx0Hrnismsae4AzTA)I1(Lul91(rTSwTyxqktSnSc1YsGNMrsTfdbEObswEjcKbDAGIzUgebnKtKdrf4H2yKGi8zGh5g4XGg4THEOoWtZiNXiHapnt(Gap2fKYKAKmqX(P1j0mrxF0aCT5x7hbEAgj1wme4XxNjHKAKmqdAihkkevGhAJrcIWNb(b5uGCwGhRGjv2GWtqzpiWBd9qDGFyszYg6H6K8WAGxEyn1wme4XkysLnicAiNVoevGhAJrcIWNb(b5uGCwGN(ADQw1KqR(ydRajzySHXx7H2yKGOwUCRvGuFMriif86nO76SAzjWBd9qDGFyszYg6H6K8WAGxEyn1wme4hcCqd58fdrf4H2yKGi8zG3g6H6a)WKYKn0d1j5H1aV8WAQTyiWlqAqd548drf4H2yKGi8zG3g6H6a)WKYKn0d1j5H1aV8WAQTyiWlocm0GgY5ReIkWdTXibr4Za)GCkqolWdnqYYZlG5noTwh(RLskQwQQLMroJrcEObswEjcKbDAGIzUgebEBOhQd8gzynKueHaTg0qou(DiQaVn0d1bEJmSgsUpjgc8qBmsqe(mOHCOKYqubEBOhQd8YlJTItoxEISyO1ap0gJeeHpdAihk)ievG3g6H6apJLLqZKsUbD4ap0gJeeHpdAqd8UeyGIzmnevihkdrf4THEOoWBUUY8sUOdJ6ap0gJeeHpdAiNpcrf4H2yKGi8zG3g6H6aFSrOdePjIKeGPSd8dYPa5SapXorcObT6nHa7VUwhQLskkW7sGbkMX0eggOwGd8uuqd54SqubEBOhQd8yfmPYoWdTXibr4ZGgYjYHOc8qBmsqe(mW3wme4nkGzBedNMOwtOzYffnqc82qpuh4nkGzBedNMOwtOzYffnqcAihkkevG3g6H6aVlspuh4H2yKGi8zqdAGxCeyOHOc5qziQap0gJeeHpd8dYPa5Sa)afZGsUORvCTo8xBKRLQAvtcT6fa4cKewjMAzqShAJrcIA5ul91kaM3C6PbTau18p3A5YTwbW8MtVII4gjgPja)ZTwUCRfAGKLNxaZBCAT5)xl91cnnOrXjxesMeW8gNwRdFv1sFTFqr1svT0mYzmsWdnqYYlrGmOtdumZ1GOwwQLLA5YTwNQLMroJrcE81zsiPgjd0AzPwo1sFTovRAsOvpeb26S31McEOngjiQLl3AhiKuGIU9qeyRZExBk4jqSDnUwhQ9JAzjWBd9qDGhAAqJIdAiNpcrf4H2yKGi8zGh5g4XGg4THEOoWtZiNXiHapnt(Ga)afZGsUORvSxaZBCAToulL1YLBTqdKS88cyEJtRn))A)GIQLQAPzKZyKGhAGKLxIazqNgOyMRbrTC5wRt1sZiNXibp(6mjKuJKbAGNMrsTfdb(hgsZtkbsqd54SqubEOngjicFg4hKtbYzbEAg5mgj4FyinpPei1YPwJca5uWdd2ORZsmstayp0gJee1YPwSliLj1izGI9tRtOzIU(Ob4AD4V2pQLQAPVwbW8MtpnOfGQM)5wlRvl91szTuvl91AuaiNcEyWgDDwIrAca7jwtxT)1szTSull1YsG3g6H6a)06eAMORpAaoOHCICiQap0gJeeHpd8dYPa5SapnJCgJe8pmKMNucKA5ul91Y8Mtp7tiGoXinbG9y1g0vRd)1s5xPwUCRL(ADQwxYHiNMxIGutpuxlNAXUGuMuJKbk2pToHMj66JgGR1H)AJCTuvl91AuaiNcEb6XiHKaHbpXA6Q1HA)OwwQLQAXkysLni8eu2dQLLAzjWBd9qDGFADcnt01hnah0qouuiQap0gJeeHpd82qpuh4NwNqZeD9rdWb(b5uGCwGNMroJrc(hgsZtkbsTCQf7cszsnsgOy)06eAMORpAaUwh(R1zb(rEdjKuJKbkoKdLbnKZxhIkWdTXibr4Za)GCkqolWtZiNXib)ddP5jLaPwo1sFTmV50ZiVwGpb4FU1YLBTovRAsOvpnOrXjYdZ2dTXibrTCQ1PAnkaKtbVa9yKqsGWGhAJrcIAzjWBd9qDGNrETaFciOHC(IHOc8qBmsqe(mWBd9qDGp(PN0uiWpiNcKZc80mYzmsW)WqAEsjqQLtTyxqktQrYaf7NwNqZeD9rdW1(x7hb(rEdjKuJKbkoKdLbnKJZpevGhAJrcIWNb(b5uGCwGNMroJrc(hgsZtkbsG3g6H6aF8tpPPqqdAGFiWHOc5qziQap0gJeeHpd82qpuh4nkGzBedNMOwtOzYffnqc8dYPa5SaVt1IvWKkBq4nPSwo1gByfijdJnm(6ebITRX1(x731YPw6RDGqsbk62tdAbOQ5jqSDnU28)QQL(AhiKuGIU9kkIBKyKMa8ei2UgxlRvlWQ8oxxq4nmBAwd4eXOaIKgiIjRLLAzP28RLYVRLQAP87AzTAbwL356ccVHztZAaNigfqK0armzTCQ1PAfaZBo90GwaQA(NBTCQ1PAfaZBo9kkIBKyKMa8p3aFBXqG3OaMTrmCAIAnHMjxu0ajOHC(ievGhAJrcIWNb(b5uGCwG3PAXkysLni8MuwlNAfi1tEU6JaE9g0DDwTCQn2WkqsggBy81jceBxJR9V2Vd82qpuh4hMuMSHEOojpSg4LhwtTfdbEaJHEa4GgYXzHOc8qBmsqe(mWBd9qDGp2i0bI0erscWu2b(b5uGCwGNyNib0Gw9MqG9p3A5ul91QgjduVEXqsrjXb1MFTdumdk5IUwXEbmVXP1YA1sPNIQLl3AhOyguYfDTI9cyEJtR1H)AhUPylIe2fArTSe4h5nKqsnsgO4qoug0qoroevGhAJrcIWNb(b5uGCwGNyNib0Gw9MqG9xxRd16SVRLvQLyNib0Gw9MqG9IhX0d11YP2bkMbLCrxRyVaM340AD4V2HBk2IiHDHwe4THEOoWhBe6arAIijbyk7GgYHIcrf4H2yKGi8zGh5g4XGg4THEOoWtZiNXiHapnt(GaVt1QMeA1JFmkqMVmWdTXibrTC5wRt1AuaiNcEmBc6jarc)Mt0W0d1EOngjiQLl3Afi1NzecsbVB8tQNR8asToulL1YPw6Rf7cszsnsgOy)06eAMORpAaU28R9RRLl3ADQ2bcjfOOBpnRpmB)ZTwwc80msQTyiWtdAbOQLWpgfiZxgKgOwC6H6GgY5Rdrf4H2yKGi8zGh5g4XGg4THEOoWtZiNXiHapnt(GaVt1QMeA13xgBfRMKoG4H2yKGOwUCR1PAvtcT6HiWwN9U2uWdTXibrTC5w7aHKcu0ThIaBD27AtbpbITRX1MFTuuTSsTFulRvRAsOvVaaxGKWkXuldI9qBmsqe4PzKuBXqGNg0cqvl1xgBfRMKoGKgOwC6H6GgY5lgIkWdTXibr4ZapYnWJbnWBd9qDGNMroJrcbEAM8bbENQfyvENRli8gfWSnIHttuRj0m5IIgi1YLBTgfaYPGhZMGEcqKWV5enm9qThAJrcIA5YTwbW8MtpXOaIKgiIjtcG5nNEbk6UwUCRDGqsbk62By20SgWjIrbejnqet6jqSDnU28RLYVRLtT0x7aHKcu0TxrrCJeJ0eGNaX214AZVwkRLl3AfaZBo9kkIBKyKMa8p3AzjWtZiP2IHapnOfGQwAIAnnqT40d1bnKJZpevGhAJrcIWNb(b5uGCwG3PAXkysLni8eu2dQLtTcK6jpx9raVEd6UoRwo16uTcG5nNEAqlavn)ZTwo1sZiNXibpnOfGQwc)yuGmFzqAGAXPhQRLtT0mYzmsWtdAbOQL6lJTIvtshqsdulo9qDTCQLMroJrcEAqlavT0e1AAGAXPhQd82qpuh4PbTau1cAiNVsiQap0gJeeHpd8dYPa5SaVAsOvpeb26S31McEOngjiQLtT0xRAsOvFFzSvSAs6aIhAJrcIA5YTw1KqRE8JrbY8LbEOngjiQLtT0mYzmsWJVotcj1izGwll1YP2bkMbLCrxR4AD4V2HBk2IiHDHwulNAhiKuGIU9qeyRZExBk4jqSDnU28RLYA5ul916uTQjHw94hJcK5ld8qBmsqulxU16uTgfaYPGhZMGEcqKWV5enm9qThAJrcIA5YTwbs9zgHGuW7g)K65kpGuB()1szTSe4THEOoWtZ6dZoOHCO87qubEOngjicFg4hKtbYzbE1KqR((YyRy1K0bep0gJee1YPwNQvnj0QhIaBD27Atbp0gJee1YP2bkMbLCrxR4AD4V2HBk2IiHDHwulNAPVwbW8MtpnOfGQM)5wlxU1cym0dWt7WhQtOzYfityOhQ9qBmsqullbEBOhQd80S(WSdAihkPmevGhAJrcIWNbEKBGhdAG3g6H6apnJCgJec80m5dc8gfaYPGhZMGEcqKWV5enm9qThAJrcIA5ul912OoHXjM3CcIKAKmqX16WFTuwlxU1IDbPmPgjduSFADcnt01hnax7FToRwwQLtT0xlgNyEZjisQrYafNmgeni5ATaIVrT)1(DTC5wl2fKYKAKmqX(P1j0mrxF0aCTo8x7xxllbEAgj1wme4X4enRpm70a1Itpuh0qou(riQap0gJeeHpd82qpuh4DrizIay0JmGapeHsSKfJETg4Jmff4NisQHi0qoug0qou6SqubEOngjicFg4hKtbYzbE1KqRE8JrbY8LbEOngjiQLtTovlwbtQSbHNGYEqTCQDGqsbk62Nzecsb)ZTwo1sFT0mYzmsWJXjAwFy2PbQfNEOUwUCR1PAnkaKtbpMnb9eGiHFZjAy6HAp0gJee1YPw6RvGuFMriif8eysamBJrc1YLBTcG5nNEAqlavn)ZTwo1kqQpZieKcE34Nupx5bKAZ)VwkRLLAzPwo1oqXmOKl6Af7fW8gNwRd)1sFT0xlL1svTFulRvRrbGCk4XSjONaej8Bordtpu7H2yKGOwwQL1Qf7cszsnsgOy)06eAMORpAaUwwQ1HVQAJCTCQLyNib0Gw9MqG9xxRd1s5hbEBOhQd80S(WSdAihkJCiQap0gJeeHpd8dYPa5SaVAsOvFSHvGKmm2W4R9qBmsqulNADQwScMuzdcVjL1YP2ydRajzySHXxNiqSDnU28)R97A5uRt1kqQN8C1hb8eysamBJrc1YPwbs9zgHGuWtGy7ACTouRZQLtT0xRayEZPNg0cqvZ)CRLtT0xRt1QMeA1ROiUrIrAcWdTXibrTC5wRayEZPxrrCJeJ0eG)5wll1YPw6R1PAbmg6b4zKiKiHMjLnKGgIZZhBoxqKA5YTwbW8MtpJeHej0mPSHe0qCE(NBTSulxU1cym0dWt7WhQtOzYfityOhQ9qBmsqullbEBOhQd80S(WSdAihkPOqubEOngjicFg4hKtbYzbENQfRGjv2GWBszTCQ1Oaqof8y2e0taIe(nNOHPhQ9qBmsqulNAfi1NzecsbpbMeaZ2yKqTCQvGuFMriif8UXpPEUYdi1M)FTuwlNAhOyguYfDTI9cyEJtR1H)APmWBd9qDGhZ2eOOJbPiOHCO8Rdrf4H2yKGi8zGFqofiNf4fi1tEU6JaEceBxJR1HAJCTuvBKRL1QD4MITisyxOf1YPwNQvGuFMriif8eysamBJrcbEBOhQd8qeyRZExBke0qou(fdrf4H2yKGi8zGFqofiNf4fi1tEU6JaE9g0DDwTCQL(ADQwGv5DUUGWBuaZ2igonrTMqZKlkAGulxU1oqiPafD7PbTau18ei2UgxRd1s531YsG3g6H6aVII4gjgPjGGgYHsNFiQap0gJeeHpd8dYPa5SapZBo9msesiFy1taBO1YLBTcG5nNEAqlavn)ZnWBd9qDG3fPhQdAihk)kHOc8qBmsqe(mWpiNcKZc8cG5nNEAqlavn)ZnWBd9qDGNrIqI08rYlOHC(47qubEOngjicFg4hKtbYzbEbW8MtpnOfGQM)5g4THEOoWZaemqO76SGgY5dkdrf4H2yKGi8zGFqofiNf4faZBo90GwaQA(NBG3g6H6a)8iaJeHebnKZhFeIkWdTXibr4Za)GCkqolWlaM3C6PbTau18p3aVn0d1bERhawjMmnmPmOHC(WzHOc8qBmsqe(mWBd9qDGpZKWWKsGGtmiuh4hKtbYzb(bcjfOOBpnOfGQMNaX214ADO2itrb(2IHaFMjHHjLabNyqOoOHC(iYHOc8qBmsqe(mWBd9qDG3WSPznGteJcisAGiMmWpiNcKZc8cG5nNEIrbejnqetMeaZBo9cu0DTC5wRayEZPNg0cqvZtGy7ACToulLFxlRuBKRL1QfyvENRli8gfWSnIHttuRj0m5IIgi1YLBTQrYa1RxmKuusCqT5x7hFh4Blgc8gMnnRbCIyuarsdeXKbnKZhuuiQap0gJeeHpd82qpuh4h5nKiLG6BKyKgwd8dYPa5SaFSHvGKmm2W4Rtei2Ugx7FTFxlNADQwbW8MtpnOfGQM)5wlNADQwbW8MtVII4gjgPja)ZTwo1Y8MtFmeJi5LqZK8norsqalg7fOO7A5ul0ajlVAZVwN)31YPwbs9KNR(iGNaX214ADO2ih4H5egAQTyiWpYBirkb13iXinSg0qoF81HOc8qBmsqe(mWBd9qDGx(i0beC6A8jo0dNYUPg4hKtbYzbEbW8MtpnOfGQM)5g4Blgc8YhHoGGtxJpXHE4u2n1GgY5JVyiQap0gJeeHpd82qpuh4LpSsqpCkdjfqNCLVyldc8dYPa5SaVayEZPNg0cqvZ)Cd8TfdbE5dRe0dNYqsb0jx5l2YGGgY5dNFiQap0gJeeHpd82qpuh4ZKM4mfrWPyqys5H6a)GCkqolWlaM3C6PbTau18p3apmNWqtTfdb(mPjotreCkgeMuEOoOHC(4ReIkWdTXibr4ZaVn0d1b(mPjotreCIXezqGFqofiNf4faZBo90GwaQA(NBGhMtyOP2IHaFM0eNPicoXyImiOHCC23HOc82qpuh4FyiDkeJd8qBmsqe(mObnWlqAiQqougIkWdTXibr4ZapYnWJbnWBd9qDGNMroJrcbEAM8bbExYHiNMxIGutpuxlNAXUGuMuJKbk2pToHMj66JgGR1HADwTCQL(Afi1NzecsbpbITRX1MFTdeskqr3(mJqqk4fpIPhQRLl3ADrhg1GiXibqGR1HAPOAzjWtZiP2IHapMUZnnYBiHuMriifcAiNpcrf4H2yKGi8zGh5g4XGg4THEOoWtZiNXiHapnt(GaVl5qKtZlrqQPhQRLtTyxqktQrYaf7NwNqZeD9rdW16qToRwo1sFTcG5nNEffXnsmsta(NBTC5wl916IomQbrIrcGaxRd1sr1YPwNQ1Oaqof84b0Acntmses4H2yKGOwwQLLapnJKAlgc8y6o30iVHesKNR(iqqd54SqubEOngjicFg4rUbEmObEBOhQd80mYzmsiWtZKpiWlaM3C6PbTau18p3A5ul91kaM3C6vue3iXinb4FU1YLBTXgwbsYWydJVorGy7ACTou731YsTCQvGup55Qpc4jqSDnUwhQ9JapnJKAlgc8y6o3e55Qpce0qoroevGhAJrcIWNb(b5uGCwGxnj0QhIaBD27Atbp0gJee1YPw6RL(AhOyguYfDTIR1H)AhUPylIe2fArTCQDGqsbk62drGTo7DTPGNaX214AZVwkRLLA5YTw6R1PA1Bq31z1YPw6RvVyOwhQLYVRLl3AhOyguYfDTIR1H)A)OwwQLLAzjWBd9qDGN8C1hbcAihkkevGhAJrcIWNb(jIKAicnKdLbEBOhQd8UiKmram6rgqqd581HOc8qBmsqe(mWpiNcKZc80xRt1QMeA1JFmkqMVmWdTXibrTC5wRt1sFTdeskqr3EAwFy2(NBTCQDGqsbk62tdAbOQ5jqSDnU28)RnY1YsTSulNAhOyguYfDTI9cyEJtR1H)APSwQQ1z1YA1sFTgfaYPGhZMGEcqKWV5enm9qThAJrcIA5u7aHKcu0TNM1hMT)5wll1YPwcmjaMTXiHA5ul916g)K65kpGuB()1szTC5wlbITRX1M)FT6nOlPxmulNAXUGuMuJKbk2pToHMj66JgGR1H)ADwTuvRrbGCk4XSjONaej8Bordtpu7H2yKGOwwQLtT0xRt1crGTo7DTPGOwUCRLaX214AZ)Vw9g0L0lgQL1Q9JA5ul2fKYKAKmqX(P1j0mrxF0aCTo8xRZQLQAnkaKtbpMnb9eGiHFZjAy6HAp0gJee1YsTCQ1PAX4eZBobrTCQL(AvJKbQxVyiPOK4GAzLAjqSDnUwwQ1HAJCTCQL(AJnScKKHXggFDIaX214A)R97A5YTwNQvVbDxNvlNAnkaKtbpMnb9eGiHFZjAy6HAp0gJee1YsG3g6H6aFMriifcAiNVyiQap0gJeeHpd8tej1qeAihkd82qpuh4DrizIay0JmGGgYX5hIkWdTXibr4ZaVn0d1b(mJqqke4hKtbYzbENQLMroJrcEmDNBAK3qcPmJqqkulNAPVwNQvnj0Qh)yuGmFzGhAJrcIA5YTwNQL(AhiKuGIU90S(WS9p3A5u7aHKcu0TNg0cqvZtGy7ACT5)xBKRLLAzPwo1oqXmOKl6Af7fW8gNwRd)1szTuvRZQL1QL(AnkaKtbpMnb9eGiHFZjAy6HAp0gJee1YP2bcjfOOBpnRpmB)ZTwwQLtTeysamBJrc1YPw6R1n(j1ZvEaP28)RLYA5YTwceBxJRn))A1BqxsVyOwo1IDbPmPgjduSFADcnt01hnaxRd)16SAPQwJca5uWJztqpbis43CIgMEO2dTXibrTSulNAPVwNQfIaBD27AtbrTC5wlbITRX1M)FT6nOlPxmulRv7h1YPwSliLj1izGI9tRtOzIU(Ob4AD4VwNvlv1AuaiNcEmBc6jarc)Mt0W0d1EOngjiQLLA5uRt1IXjM3CcIA5ul91QgjduVEXqsrjXb1Yk1sGy7ACTSuRd1s5h1YPw6Rn2WkqsggBy81jceBxJR9V2VRLl3ADQw9g0DDwTCQ1Oaqof8y2e0taIe(nNOHPhQ9qBmsqullb(rEdjKuJKbkoKdLbnKZxjevGhAJrcIWNb(b5uGCwGh7cszsnsgO4AD4V2pQLtTei2UgxB(1(rTuvl91IDbPmPgjduCTo8xlfvll1YP2bkMbLCrxR4AD4V2ih4THEOoWpixmg1jfIDbSg0qou(DiQap0gJeeHpd8dYPa5SaVt1sZiNXibpMUZnrEU6Ja1YP2bkMbLCrxR4AD4V2ixlNAjWKay2gJeQLtT0xRB8tQNR8asT5)xlL1YLBTei2UgxB()1Q3GUKEXqTCQf7cszsnsgOy)06eAMORpAaUwh(R1z1svTgfaYPGhZMGEcqKWV5enm9qThAJrcIAzPwo1sFTovleb26S31McIA5YTwceBxJRn))A1BqxsVyOwwR2pQLtTyxqktQrYaf7NwNqZeD9rdW16WFToRwQQ1Oaqof8y2e0taIe(nNOHPhQ9qBmsqull1YPw1izG61lgskkjoOwwPwceBxJR1HAJCG3g6H6ap55Qpce0qousziQap0gJeeHpd82qpuh4jpx9rGa)GCkqolW7uT0mYzmsWJP7CtJ8gsirEU6Ja1YPwNQLMroJrcEmDNBI8C1hbQLtTdumdk5IUwX16WFTrUwo1sGjbWSngjulNAPVw34Nupx5bKAZ)VwkRLl3AjqSDnU28)RvVbDj9IHA5ul2fKYKAKmqX(P1j0mrxF0aCTo8xRZQLQAnkaKtbpMnb9eGiHFZjAy6HAp0gJee1YsTCQL(ADQwicS1zVRnfe1YLBTei2UgxB()1Q3GUKEXqTSwTFulNAXUGuMuJKbk2pToHMj66JgGR1H)ADwTuvRrbGCk4XSjONaej8Bordtpu7H2yKGOwwQLtTQrYa1RxmKuusCqTSsTei2UgxRd1g5a)iVHesQrYafhYHYGg0Gg4Pbe8H6qoF89hF)9hF81b(OnsFDgoW7Ch7IikiQ9lwRn0d11kpSI9f1bExcAEsiWhPAPyySHXxB6H6AP4OShuuhPAzRQl25KBUzNY(X4hO4CXx8tA6H6bXMAU4lEKBrDKQLv1id21sPJ1(X3F8DrDrDKQL1Z26ma7CkQJuTSsTumHae1(LEd6Qvr1kGP9KAT2qpuxR8WQVOos1Yk1sXHyenOw1izGMUPVOos1Yk1sXecqulRdmuRZTcX4APh9u8jGArZAXkysLnl(I6I6ivlRocy8uquldmreO2bkMX0AzGSRX(APyJb4Q4ABuZkSns88jR1g6HACTOwMNVOos1Ad9qn27sGbkMX0)P0W0vuhPATHEOg7DjWafZykv)5AVSyOvtpuxuhPATHEOg7DjWafZykv)5orirrDKQLVnxmBKwlXorTmV5ee1IvtX1YatebQDGIzmTwgi7ACTwlQ1LaSIls1RZQ9W1kqn4lQJuT2qpuJ9UeyGIzmLQ)CXT5IzJ0ewnfxuBd9qn27sGbkMXuQ(Z1CDL5LCrhg1f12qpuJ9UeyGIzmLQ)CJncDGinrKKamLTJUeyGIzmnHHbQf4FkYXB(tStKaAqREtiW(RDGskQO2g6HAS3LadumJPu9NlwbtQSlQTHEOg7DjWafZykv)5(Wq6ui2X2IHFJcy2gXWPjQ1eAMCrrdKIABOhQXExcmqXmMs1FUUi9qDrDrDKQLvhbmEkiQfObK8QvVyOwLnuRnueP2dxRrZoPXibFrDKQLIdyfmPYU2BwRlcJpgjul9nQwApzdeJrc1cneFaU2RRDGIzmLLIABOhQX)0Dd6C8M)oHvWKkBq4nPSO2g6HAmv)5IvWKk7IABOhQXu9NlnJCgJeCSTy4hAGKLxIazqNgOyMRbHJ0m5d(Hgiz55jqg0u5IomQbrIrcGaZAFXVe6)G1WUGuMyByfyPO2g6HAmv)5sZiNXibhBlg(XxNjHKAKmqDKMjFWp2fKYKAKmqX(P1j0mrxF0aC(FuuBd9qnMQ)ChMuMSHEOojpS6yBXWpwbtQSbHJ38hRGjv2GWtqzpOO2g6HAmv)5omPmzd9qDsEy1X2IH)Ha74n)P3j1KqR(ydRajzySHXx7H2yKGGlxbs9zgHGuWR3GURZyPO2g6HAmv)5omPmzd9qDsEy1X2IHFbslQTHEOgt1FUdtkt2qpuNKhwDSTy4xCeyOf12qpuJP6pxJmSgskIqGwD8M)qdKS88cyEJtD4NskIkAg5mgj4Hgiz5Liqg0PbkM5AquuBd9qnMQ)CnYWAi5(KyOO2g6HAmv)5kVm2ko5C5jYIHwlQTHEOgt1FUmwwcntk5g0HlQlQJuTSEeskqr34IABOhQX(Ha))Wq6ui2X2IHFJcy2gXWPjQ1eAMCrrdehV5VtyfmPYgeEtk5eByfijdJnm(6ebITRX)FZH(bcjfOOBpnOfGQMNaX2148)QOFGqsbk62ROiUrIrAcWtGy7AmRbSkVZ1feEdZMM1aormkGiPbIyswyjFk)Mkk)M1awL356ccVHztZAaNigfqK0armjhNeaZBo90GwaQA(NlhNeaZBo9kkIBKyKMa8p3IABOhQX(Hat1FUdtkt2qpuNKhwDSTy4hWyOha2XB(7ewbtQSbH3KsocK6jpx9raVEd6UoJtSHvGKmm2W4Rtei2Ug))DrDKQ15EwRje4Ancu7Z1XAX95c1QSHArnuB0NYUwjkAaR1gvuFzFTSoWqTrZg6Af5DDwTtdRaPwLT11Y6DE1kG5noTweP2OpLn6P1ADE1Y6DE(IABOhQX(Hat1FUXgHoqKMissaMY2XrEdjKuJKbk(NshV5pXorcObT6nHa7FUCOxnsgOE9IHKIsIdYFGIzqjx01k2lG5noL1O0trC5oqXmOKl6Af7fW8gN6W)WnfBrKWUqlyPOos16CpRTr1AcbU2OpPSwXb1g9PSVUwLnuBdrO16SVXow7dd1YQo)Y1I6AzqyCTrFkB0tR168QL1788f12qpuJ9dbMQ)CJncDGinrKKamLTJ38NyNib0Gw9MqG9x7GZ(Mvi2jsanOvVjeyV4rm9qnNbkMbLCrxRyVaM34uh(hUPylIe2fArrDKQ9laTau1QvIYUHjRDGAXPhQnjUwgddIArDTJhHaTwl2fgf12qpuJ9dbMQ)CPzKZyKGJTfd)0GwaQAj8JrbY8LbPbQfNEO2rAM8b)oPMeA1JFmkqMVmWdTXibbxUozuaiNcEmBc6jarc)Mt0W0d1EOngji4YvGuFMriif8UXpPEUYdioqjh6XUGuMuJKbk2pToHMj66JgGZ)R5Y1PbcjfOOBpnRpmB)ZLLIABOhQX(Hat1FU0mYzmsWX2IHFAqlavTuFzSvSAs6asAGAXPhQDKMjFWVtQjHw99LXwXQjPdiEOngji4Y1j1KqREicS1zVRnf8qBmsqWL7aHKcu0ThIaBD27AtbpbITRX5trSYhSMAsOvVaaxGKWkXuldI9qBmsquuBd9qn2peyQ(ZLMroJrco2wm8tZiNXibhBlg(PbTau1stuRPbQfNEO2rAM8b)obSkVZ1feEJcy2gXWPjQ1eAMCrrdeUCnkaKtbpMnb9eGiHFZjAy6HAp0gJeeC5kaM3C6jgfqK0armzsamV50lqr3C5oqiPafD7nmBAwd4eXOaIKgiIj9ei2UgNpLFZH(bcjfOOBVII4gjgPjapbITRX5tjxUcG5nNEffXnsmsta(Nllf12qpuJ9dbMQ)CPbTau1C8M)oHvWKkBq4jOShWrGup55Qpc41Bq31zCCsamV50tdAbOQ5FUCOzKZyKGNg0cqvlHFmkqMVminqT40d1COzKZyKGNg0cqvl1xgBfRMKoGKgOwC6HAo0mYzmsWtdAbOQLMOwtdulo9qDrDKQ9ly9HzxB0NYUwwDe4SAPQw6Z5YyRy1K0behRfrQL)XOaz(YGArTmVArDTugfloNAzvTiU4xCTSENxTwlQLvhboRwcyI8QDIi12qeATSUS(VCrTn0d1y)qGP6pxAwFy2oEZF1KqREicS1zVRnf8qBmsqWHE1KqR((YyRy1K0bep0gJeeC5QMeA1JFmkqMVmWdTXibbhAg5mgj4XxNjHKAKmqzHZafZGsUORvSd)d3uSfrc7cTGZaHKcu0ThIaBD27AtbpbITRX5tjh6Dsnj0Qh)yuGmFzGhAJrccUCDYOaqof8y2e0taIe(nNOHPhQ9qBmsqWLRaP(mJqqk4DJFs9CLhqY)NswkQJuTFbRpm7AJ(u21MZLXwXQjPdi1svT5GQLvhboZ5ulRQfXf)IRL178Q1ArTFbOfGQwTp3AP)1saJR9HVoR2VaY5XsrTn0d1y)qGP6pxAwFy2oEZF1KqR((YyRy1K0bep0gJeeCCsnj0QhIaBD27Atbp0gJeeCgOyguYfDTID4F4MITisyxOfCOxamV50tdAbOQ5FUC5cym0dWt7WhQtOzYfityOhQ9qBmsqWsrDKQLhGANpPS2bkogATwuxlBvDXoNCZn7u2pg)afNlf3ObnBKuOSsuS(CP4OShKB0hDxUumm2W4Rn9qnRqXCESozfkoGbJmy7lQTHEOg7hcmv)5sZiNXibhBlg(X4enRpm70a1Itpu7int(GFJca5uWJztqpbis43CIgMEO2dTXibbh6BuNW4eZBobrsnsgOyh(PKlxSliLj1izGI9tRtOzIU(Ob4FNXch6X4eZBobrsnsgO4KXGObjxRfq8n()MlxSliLj1izGI9tRtOzIU(Obyh()AwkQTHEOg7hcmv)56IqYebWOhzaoorKudrO)u6ieHsSKfJET(hzkQO2g6HASFiWu9NlnRpmBhV5VAsOvp(XOaz(Yap0gJeeCCcRGjv2GWtqzpGZaHKcu0TpZieKc(Nlh6PzKZyKGhJt0S(WStdulo9qnxUozuaiNcEmBc6jarc)Mt0W0d1EOngji4qVaP(mJqqk4jWKay2gJe4YvamV50tdAbOQ5FUCei1NzecsbVB8tQNR8as()uYclCgOyguYfDTI9cyEJtD4NE6PKQpynJca5uWJztqpbis43CIgMEO2dTXibblSg2fKYKAKmqX(P1j0mrxF0amlo8vfzoe7ejGg0Q3ecS)AhO8JI6iv7xW6dZU2OpLDTSQgwbsTumm2Wx7CQnhuTyfmPYUwRf12OATHE0GAzvPy1Y8MthRLI)C1hbQTrATxxlbMeaZUwI1zGJ1kEKRZQ9laTau1OkQpP6tKYQRL(xlbmU2h(6SA)ciNhlf12qpuJ9dbMQ)CPz9Hz74n)vtcT6JnScKKHXggFThAJrccooHvWKkBq4nPKtSHvGKmm2W4Rtei2UgN))3CCsGup55Qpc4jWKay2gJe4iqQpZieKcEceBxJDWzCOxamV50tdAbOQ5FUCO3j1KqREffXnsmstaEOngji4YvamV50ROiUrIrAcW)CzHd9obym0dWZirircntkBibneNNp2CUGiC5kaM3C6zKiKiHMjLnKGgIZZ)CzHlxaJHEaEAh(qDcntUazcd9qThAJrccwkQJuT8Snbk6yqkQDIi1YZMGEcqul)BordtpuxuBd9qn2peyQ(ZfZ2eOOJbPWXB(7ewbtQSbH3KsogfaYPGhZMGEcqKWV5enm9qThAJrccocK6ZmcbPGNatcGzBmsGJaP(mJqqk4DJFs9CLhqY)Nsodumdk5IUwXEbmVXPo8tzrDKQLvhb26S31Mc1gnBORLbPSRLI)C1hbQ1ArTSUgHGuOwJa1(CRDIi1krDwTqJEzSlQTHEOg7hcmv)5crGTo7DTPGJ38xGup55Qpc4jqSDn2HitvKzTHBk2IiHDHwWXjbs9zgHGuWtGjbWSngjuuBd9qn2peyQ(ZvrrCJeJ0eGJ38xGup55Qpc41Bq31zCO3jGv5DUUGWBuaZ2igonrTMqZKlkAGWL7aHKcu0TNg0cqvZtGy7ASdu(nlf12qpuJ9dbMQ)CDr6HAhV5pZBo9msesiFy1taBOC5kaM3C6PbTau18p3IABOhQX(Hat1FUmsesKMpsEoEZFbW8MtpnOfGQM)5wuBd9qn2peyQ(ZLbiyGq31zoEZFbW8MtpnOfGQM)5wuBd9qn2peyQ(ZDEeGrIqchV5VayEZPNg0cqvZ)ClQTHEOg7hcmv)5A9aWkXKPHjLoEZFbW8MtpnOfGQM)5wuBd9qn2peyQ(Z9HH0PqSJTfd)zMegMuceCIbHAhV5)aHKcu0TNg0cqvZtGy7ASdrMIkQTHEOg7hcmv)5(Wq6ui2X2IHFdZMM1aormkGiPbIyshV5VayEZPNyuarsdeXKjbW8MtVafDZLRayEZPNg0cqvZtGy7ASdu(nRezwdyvENRli8gfWSnIHttuRj0m5IIgiC5QgjduVEXqsrjXb5)X3f12qpuJ9dbMQ)CFyiDke7imNWqtTfd)J8gsKsq9nsmsdRoEZ)ydRajzySHXxNiqSDn()BoojaM3C6PbTau18pxoojaM3C6vue3iXinb4FUCyEZPpgIrK8sOzs(gNijiGfJ9cu0nhObswE578)MJaPEYZvFeWtGy7ASdrUO2g6HASFiWu9N7ddPtHyhBlg(LpcDabNUgFId9WPSBQoEZFbW8MtpnOfGQM)5wuBd9qn2peyQ(Z9HH0PqSJTfd)YhwjOhoLHKcOtUYxSLboEZFbW8MtpnOfGQM)5wuBd9qn2peyQ(Z9HH0PqSJWCcdn1wm8NjnXzkIGtXGWKYd1oEZFbW8MtpnOfGQM)5wuBd9qn2peyQ(Z9HH0PqSJWCcdn1wm8NjnXzkIGtmMidC8M)cG5nNEAqlavn)ZTOos1(LHP9KATttkzSbD1orKAFyJrc1EkeJDo1Y6ad1I6AhiKuGIU9f12qpuJ9dbMQ)CFyiDkeJlQlQJuTF5JadTwHfBzqTgZjp9aCrDKQLv30GgfxRP1gzQQLEkIQAJ(u21(L5zPwwVZZxRZDCmiotbzE1I6A)GQAvJKbk2XAJ(u21(fGwaQAowlIuB0NYU2O(8RUArkBGe9HHAJ2oT2jIulgfd1cnqYYZxlftIr1gTDAT3SwwDe4SAhOyguThU2bk(6SAFU(IABOhQXEXrGH(dnnOrXoEZ)bkMbLCrxRyh(JmvQjHw9caCbscRetTmi2dTXibbh6faZBo90GwaQA(NlxUcG5nNEffXnsmsta(NlxUqdKS88cyEJtZ)NEOPbnko5IqYKaM34uh(QO)dkIkAg5mgj4Hgiz5Liqg0PbkM5AqWclC56enJCgJe84RZKqsnsgOSWHENutcT6HiWwN9U2uWdTXibbxUdeskqr3EicS1zVRnf8ei2Ug7WhSuuBd9qn2locmuQ(ZLMroJrco2wm8)WqAEsjqCKMjFW)afZGsUORvSxaZBCQduYLl0ajlpVaM3408))GIOIMroJrcEObswEjcKbDAGIzUgeC56enJCgJe84RZKqsnsgOf1rQ2VAoLDTS6bB01z1(P0ea2XADUADTOzTFP9rdW1AATFqvTQrYaf7yTisToJvImv1QgjduCTrZg6A)cqlavTApCTp3IABOhQXEXrGHs1FUtRtOzIU(ObyhV5pnJCgJe8pmKMNuceogfaYPGhgSrxNLyKMaWEOngji4GDbPmPgjduSFADcnt01hna7W)hurVayEZPNg0cqvZ)Czn6PKk6nkaKtbpmyJUolXinbG9eRP7NswyHLI6ivRZvRRfnR9lTpAaUwtRLYVcv1IvBqhUw0S2V6pHa6A)uAcaxlIuRLzxJ1AJmv1spfrvTrFk7A)YOhJeQ9lJWal1QgjduSVO2g6HASxCeyOu9N706eAMORpAa2XB(tZiNXib)ddP5jLaHd9mV50Z(ecOtmstaypwTbDo8t5xHlx6DYLCiYP5Lii10d1CWUGuMuJKbk2pToHMj66JgGD4pYurVrbGCk4fOhJesceg8eRPZHpyHkScMuzdcpbL9awyPOos16C16ArZA)s7JgGRvr1AUUY8Q9ldMqMxTop0HrDT3S2RTHE0GArDTwNxTQrYaTwtR1z1QgjduSVO2g6HASxCeyOu9N706eAMORpAa2XrEdjKuJKbk(NshV5pnJCgJe8pmKMNuceoyxqktQrYaf7NwNqZeD9rdWo87SIABOhQXEXrGHs1FUmYRf4taoEZFAg5mgj4FyinpPeiCON5nNEg51c8ja)ZLlxNutcT6PbnkorEy2EOngji44KrbGCk4fOhJesceg8qBmsqWsrDKQnkJHvyvF6jnfQvr1AUUY8Q9ldMqMxTop0HrDTMw7h1QgjduCrTn0d1yV4iWqP6p34NEstbhh5nKqsnsgO4FkD8M)0mYzmsW)WqAEsjq4GDbPmPgjduSFADcnt01hna))rrTn0d1yV4iWqP6p34NEstbhV5pnJCgJe8pmKMNucKI6I6iv7x2ITmOwenGuREXqTgZjp9aCrDKQL15fFATSUgHGuaxlQRTrnR4sUyIrYRw1izGIRDIi1QSHADjhICAE1sqQPhQR9M1sruvlJeabUwJa1AscyI8Q95wuBd9qn2lq6pnJCgJeCSTy4ht35Mg5nKqkZieKcosZKp43LCiYP5Lii10d1CWUGuMuJKbk2pToHMj66JgGDWzCOxGuFMriif8ei2UgN)aHKcu0TpZieKcEXJy6HAUCDrhg1GiXibqGDGIyPOos1Y68IpTwk(ZvFeaxlQRTrnR4sUyIrYRw1izGIRDIi1QSHADjhICAE1sqQPhQR9M1sruvlJeabUwJa1AscyI8Q95wuBd9qn2lqkv)5sZiNXibhBlg(X0DUPrEdjKipx9rahPzYh87soe508seKA6HAoyxqktQrYaf7NwNqZeD9rdWo4mo0laM3C6vue3iXinb4FUC5sVl6WOgejgjacSduehNmkaKtbpEaTMqZeJeHeEOngjiyHLI6ivlRZl(0AP4px9raCT3S2Va0cqvJQOqrCJA)uAcixwvdRaPwkggBy811E4AFU1ATO2OHAzB0GA)GQAXWa1cCTsyQ1I6Av2qTu8NR(iqTFzuuf12qpuJ9cKs1FU0mYzmsWX2IHFmDNBI8C1hbCKMjFWVayEZPNg0cqvZ)C5qVayEZPxrrCJeJ0eG)5YLBSHvGKmm2W4Rtei2Ug7W3SWrGup55Qpc4jqSDn2HpkQJuT8UW4mzTu8NR(iqTyqFU1orKAz1rGZkQTHEOg7fiLQ)Cjpx9rahV5VAsOvpeb26S31McEOngji4qp9dumdk5IUwXo8pCtXwejSl0codeskqr3EicS1zVRnf8ei2UgNpLSWLl9oP3GURZ4qVEXGdu(nxUdumdk5IUwXo8)blSWsrDKQL11ieKc1(CPdaxhR1KyuTk5aCTkQ2hgQ90AnCTwTyxyCMS2mObIPisTtePwLnuR0WATSENxTmWerGATANxFy2aPO2g6HASxGuQ(Z1fHKjcGrpYaCCIiPgIq)PSO2g6HASxGuQ(ZnZieKcoEZF6Dsnj0Qh)yuGmFzGhAJrccUCDI(bcjfOOBpnRpmB)ZLZaHKcu0TNg0cqvZtGy7AC()rMfw4mqXmOKl6Af7fW8gN6WpLu5mwJEJca5uWJztqpbis43CIgMEO2dTXibbNbcjfOOBpnRpmB)ZLfoeysamBJrcCO3n(j1ZvEaj)Fk5YLaX2148)1BqxsVyGd2fKYKAKmqX(P1j0mrxF0aSd)oJkJca5uWJztqpbis43CIgMEO2dTXibblCO3jicS1zVRnfeC5sGy7AC()6nOlPxmWAFWb7cszsnsgOy)06eAMORpAa2HFNrLrbGCk4XSjONaej8Bordtpu7H2yKGGfooHXjM3Ccco0RgjduVEXqsrjXbScbITRXS4qK5qFSHvGKmm2W4Rtei2Ug))nxUoP3GURZ4yuaiNcEmBc6jarc)Mt0W0d1EOngjiyPO2g6HASxGuQ(Z1fHKjcGrpYaCCIiPgIq)PSO2g6HASxGuQ(ZnZieKcooYBiHKAKmqX)u64n)DIMroJrcEmDNBAK3qcPmJqqkWHENutcT6XpgfiZxg4H2yKGGlxNOFGqsbk62tZ6dZ2)C5mqiPafD7PbTau18ei2UgN)FKzHfodumdk5IUwXEbmVXPo8tjvoJ1O3Oaqof8y2e0taIe(nNOHPhQ9qBmsqWzGqsbk62tZ6dZ2)CzHdbMeaZ2yKah6DJFs9CLhqY)NsUCjqSDno)F9g0L0lg4GDbPmPgjduSFADcnt01hna7WVZOYOaqof8y2e0taIe(nNOHPhQ9qBmsqWch6DcIaBD27AtbbxUei2UgN)VEd6s6fdS2hCWUGuMuJKbk2pToHMj66JgGD43zuzuaiNcEmBc6jarc)Mt0W0d1EOngjiyHJtyCI5nNGGd9QrYa1RxmKuusCaRqGy7Amloq5hCOp2WkqsggBy81jceBxJ))MlxN0Bq31zCmkaKtbpMnb9eGiHFZjAy6HAp0gJeeSuuhPAz9KlgJ6AJcIDbSwlQL5vlQRn(j1Zvc1QgjduCTMwBKPQwwVZR2OzdDTKx3xNvl6P1EDTFGRL(NBTkQ2ixRAKmqXSulIuRZW1spfrvTQrYafZsrTn0d1yVaPu9N7GCXyuNui2fWQJ38h7cszsnsgOyh()GdbITRX5)bv0JDbPmPgjduSd)uelCgOyguYfDTID4pYf1rQ2VuaCR95wlf)5QpcuRP1gzQQf11AszTQrYafxl9rZg6ALhTRZQvI6SAHg9YyxR1IABKwlUnxmBKYsrTn0d1yVaPu9Nl55Qpc44n)DIMroJrcEmDNBI8C1hb4mqXmOKl6Af7WFK5qGjbWSngjWHE34Nupx5bK8)PKlxceBxJZ)xVbDj9IboyxqktQrYaf7NwNqZeD9rdWo87mQmkaKtbpMnb9eGiHFZjAy6HAp0gJeeSWHENGiWwN9U2uqWLlbITRX5)R3GUKEXaR9bhSliLj1izGI9tRtOzIU(Obyh(DgvgfaYPGhZMGEcqKWV5enm9qThAJrccw4OgjduVEXqsrjXbScbITRXoe5IABOhQXEbsP6pxYZvFeWXrEdjKuJKbk(NshV5Vt0mYzmsWJP7CtJ8gsirEU6JaCCIMroJrcEmDNBI8C1hb4mqXmOKl6Af7WFK5qGjbWSngjWHE34Nupx5bK8)PKlxceBxJZ)xVbDj9IboyxqktQrYaf7NwNqZeD9rdWo87mQmkaKtbpMnb9eGiHFZjAy6HAp0gJeeSWHENGiWwN9U2uqWLlbITRX5)R3GUKEXaR9bhSliLj1izGI9tRtOzIU(Obyh(DgvgfaYPGhZMGEcqKWV5enm9qThAJrccw4OgjduVEXqsrjXbScbITRXoe5I6I6ivlRgJHEa4IABOhQXEaJHEa4)bQhqRetbrAkTyWXB(dnqYYZRxmKuuk2IWbk54KayEZPNg0cqvZ)C5qVtcK6hOEaTsmfePP0IHeZJ0E9g0DDghNSHEO2pq9aALykistPfd(Rtt5LXw5YD(KYebgSnsgK0lgYpBi8XweSuuhPAPyYOT8W1(WqTFkrirTrFk7A)cqlavTAFU(APysmQ2hgQn6tzxBuFw7ZTwgyIiqTwTZRpmBGul93Sw1KqRGGLAnCTsuNvRHR90AjVgx7erQLYVX1kEKRZQ9laTau18f12qpuJ9agd9aWu9NlJeHej0mPSHe0qCEoEZFbW8MtpnOfGQM)5YHENutcT6vue3iXinb4H2yKGGlxbW8MtVII4gjgPja)ZLZafZGsUORvSxaZBCA()uYLRayEZPNg0cqvZtGy7AC()u(nlC5QxmKuusCq()u(DrDKQLIPke7Q1QOAn5L11Y6(mI4SU2OpLDTFbOfGQwTgUwjQZQ1W1EATrJ6VA1Aja(j1AVUwjcFDwTwTZNuYk0m5dQDyyTwenGuRYgQLaX21xNvR4rm9qDTOzTkBO25LXwlQTHEOg7bmg6bGP6p3SNreN1j0mzuaiiLTJ38FGqsbk62tdAbOQ5jqSDnoFNXLRayEZPNg0cqvZ)C5YvnsgOE9IHKIsIdY3zFxuBd9qn2dym0dat1FUzpJioRtOzYOaqqkBhV5)uIqe6PxnsgOE9IHKIsIdyfN9nlFjdeskqr3S4WuIqe6PxnsgOE9IHKIsIdyfN9nRmqiPafD7PbTau18ei2UgZYxYaHKcu0nlf12qpuJ9agd9aWu9N7enEyqKmkaKtHedyXoEZFSliLj1izGI9tRtOzIU(Obyh()GlxIDIeqdA1Bcb2FTdF93CGgiz5L)x87IABOhQXEaJHEayQ(Z19rUzExNLyKgwD8M)yxqktQrYaf7NwNqZeD9rdWo8)bxUe7ejGg0Q3ecS)Ah(6VlQTHEOg7bmg6bGP6pxLnKEnd61I0ergGJ38N5nNEcmOtcyCAIidW)C5YL5nNEcmOtcyCAIidinqVwbIhR2GU8P87IABOhQXEaJHEayQ(ZLCUUsiDDc7AdOO2g6HAShWyOhaMQ)CJgrKcAW1jcGrT1dOO2g6HAShWyOhaMQ)CJHyejVeAMKVXjsccyXyhV5p0ajlV8POV540aHKcu0TNg0cqvZ)ClQTHEOg7bmg6bGP6pxcyUxNLMslgWoEZF1izG6zdMuz7DhQdo)V5YvnsgOE2Gjv2E3HM))hFZLRAKmq96fdjfLChA6JVDWzFxuxuhPA5vWKkBqulfBOhQXf1rQ2CUm2y1K0behRfrQL)XOuXQJaNvlQRLYOCo1Y3MlMnsRLI)C1hbkQTHEOg7XkysLni(jpx9rahV5)afZGsUORvSd)rMd9QjHw99LXwXQjPdiEOngji4Yvnj0Qh)yuGmFzGhAJrcco0RMeA1drGTo7DTPGhAJrccodeskqr3EicS1zVRnf8ei2UgN))hC56KEd6UoJfo0mYzmsWJVotcj1izGYch1izG61lgskkjoGviqSDn2HVUOos1Y)yuGmFzqTuvlpBc6jarT8V5enm9qTZPwwDJFeO2OHAFyOwud1MjrmMSwfvR56kZRwwxJqqkuRIQvzd1gBxxRAKmqR9M1EAThU2gP1IBZfZgP1MhOowlgvRjL1Iu2aP2y76AvJKbATgZjp9aCTUe08uFrTn0d1ypwbtQSbbv)56IqYebWOhzaoorKudrO)uwuBd9qn2JvWKkBqq1FUzgHGuWXB(BuaiNcEmBc6jarc)Mt0W0d1EOngji4W8Mtp(XOaz(Ya)ZLdZBo94hJcK5ld8ei2UgNpLENXXjmoX8MtquuhPA5FmkqMVmW5ulfZ1vMxTisTuCysam7AJ(u21Y8MtqulRRriifWf12qpuJ9yfmPYgeu9NRlcjteaJEKb44ersneH(tzrTn0d1ypwbtQSbbv)5Mzecsbhh5nKqsnsgO4FkD8M)QjHw94hJcK5ld8qBmsqWHEceBxJZNYp4Y1n(j1ZvEaj)FkzHJAKmq96fdjfLehWkei2Ug7Whf1rQw(hJcK5ldQLQA5ztqpbiQL)nNOHPhQR96A5JY5ulfZ1vMxTGrK5vlf)5QpcuRY20AJ(KYAzGAjWKay2GO2jIuRR1ci(gf12qpuJ9yfmPYgeu9Nl55Qpc44n)vtcT6XpgfiZxg4H2yKGGJrbGCk4XSjONaej8Bordtpu7H2yKGGJtcK6jpx9raVEd6UoJdnJCgJe84RZKqsnsgOf1rQw(hJcK5ldQn6CRLNnb9eGOw(3CIgMEO25ulfhmxxzE1orKAzq9dxlR35vR1ICrKAHiuOfGOwCBUy2iTwXJy6HAFrTn0d1ypwbtQSbbv)56IqYebWOhzaoorKudrO)uwuBd9qn2JvWKkBqq1FUzgHGuWXrEdjKuJKbk(NshV5VAsOvp(XOaz(Yap0gJeeCmkaKtbpMnb9eGiHFZjAy6HAp0gJeeCuJKbQxVyiPOK4ahiqSDnMd9ei2UgNpLoFUCDcJtmV5eeSuuhPA5FmkqMVmOwQQLvhboZ5ulRMg01IObeYjGATAXT5IzJ0AzDncbPqTKlJTwRnvGulf)5QpculdmreOwwDeyRZExB6H6IABOhQXEScMuzdcQ(Z1fHKjcGrpYaCCIiPgIq)PSO2g6HAShRGjv2GGQ)CZmcbPGJ38xnj0Qh)yuGmFzGhAJrccoQjHw9qeyRZExBk4H2yKGGZaHKcu0ThIaBD27AtbpbITRX5tjhxcqlLneEk9KNR(iahbs9KNR(iGNaX21yhOiQImRnCtXwejSl0Iap2fgHC(GI(kbnOHaa]] )

end