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


    spec:RegisterPack( "Assassination", 20200212, [[da1H2bqiQipsiYLuvcAtOKpHQqiJcvLtHQ0QqvuVcjzwOQ6wOkyxc(Li0WuvQJHISmrKNrfLPje11uvsBdjO(gvuvJJkQY5qcO1HQi9oufcmpvfUNQQ9HI6FQkr5GibzHQk6HOkIjQQe5IurfBuvjQ(iQcvJevHqDsQOswjs0lvvcmtufIUjvuP2PqYqvvcTuKa9uuzQcPUkQcjBfjaFfvHG2lv9xrnyvomLfJupwHjt4YGnROplsJgL60kTAufs9AKuZMOBlu7wQFdz4uPJJQqz5iEoutN01vLTJcFxemEHW5frTEKqZNkSFj7zYhTNtyk4JkPVt67VtIPKcjL0xzkYEonzxWZ5AdQTuWZ1wm45OqySHXBB6IApNRLSezcF0Eom6rgGNJTQUyEAIjMUk7hDyGIteVXpPPlQheBQjI34rIEo63kvNR2t75eMc(Os67K((7KykPqsj9vMCgf2ZzpLnI4542yEINJ9keq7P9Ccap8CrQokegBy82MUOUokik9bfLrQo2Q6I5PjMy6QSF0Hbkor8g)KMUOEqSPMiEJhjwugP6(YbAYZijxhtjXFDj9DsFxuwugP64jSTofW80IYivhpuhfsiarDFb7G66uuDcyApPwNn0f11jxSgkkJuD8qDuqigXaQtnskO5DgkkJuD8qDuiHae1XJcd15CPqmUo(qpfVcOo0SoScMuzZBWZjxSI9r75WkysLni8r7JIjF0EoOnAji8F65gKvbYAEUbkMgLDrBR46y(VUixhR64Ro1KqRHEtzRy1KudKa0gTee15WrDQjHwd4hTcK5lfcqB0squhR64Ro1KqRbicS1PVTnfcqB0squhR6giKuGsOdqeyRtFBBkeiqSTnUUp(RlP6C4OoNQt3b1BNwhV1XQoggznAjeWBNkHSAKuqRJ36yvNAKuqd6gdzfLfluhpuhbITTX1XCDuypNn0f1EoYZvFeWR(OsYhTNdAJwcc)NEUjIKBic1hftEoBOlQ9CUiKmtam6rgGx9r5mF0EoOnAji8F65gKvbYAEoJIazviGztqpbiY43CIgMUOoaTrlbrDSQJ(nNb8JwbY8LcHNBDSQJ(nNb8JwbY8LcbceBBJR7J6yk4S6yvNt1HXz63CccpNn0f1EUuJqqk4vFur2hTNdAJwcc)NEUjIKBic1hftEoBOlQ9CUiKmtam6rgGx9r9vF0EoOnAji8F65SHUO2ZLAecsbp3GSkqwZZPMeAnGF0kqMVuiaTrlbrDSQJV6iqSTnUUpQJPKQZHJ6CJFsDDLlqQ7J)6yQoERJvDQrsbnOBmKvuwSqD8qDei22gxhZ1LKNBK8qcz1iPGI9rXKx9rrH9r75G2OLGW)PNBqwfiR55utcTgWpAfiZxkeG2OLGOow1zueiRcbmBc6jarg)Mt0W0f1bOnAjiQJvDovNaPbYZvFeiO7G6TtRJvDmmYA0siG3ovcz1iPG65SHUO2ZrEU6JaE1hLZ3hTNdAJwcc)NEUjIKBic1hftEoBOlQ9CUiKmtam6rgGx9r588r75G2OLGW)PNZg6IApxQriif8CdYQaznpNAsO1a(rRaz(sHa0gTee1XQoJIazviGztqpbiY43CIgMUOoaTrlbrDSQtnskObDJHSIYIfQJ56iqSTnUow1XxDei22gx3h1XKZRohoQZP6W4m9BobrD865gjpKqwnskOyFum5vFuuG(O9CqB0sq4)0ZnrKCdrO(OyYZzdDrTNZfHKzcGrpYa8QpkM(2hTNdAJwcc)NEUbzvGSMNtnj0Aa)OvGmFPqaAJwcI6yvNAsO1aeb26032McbOnAjiQJvDdeskqj0bicS1PVTnfcei22gx3h1XuDSQZLamYPdrGPa55QpcuhR6einqEU6JabceBBJRJ56(ADuvxKRJNRB4MJTiYyxOfEoBOlQ9CPgHGuWRE1Zbym0da7J2hft(O9CqB0sq4)0ZniRcK18CqdK0Kd6gdzfLJTiQJ56yQow15uDcG(nNbgqlavTWZTow1XxDovNaPHbQhqRetbrEkTyit)iDq3b1BNwhR6CQoBOlQddupGwjMcI8uAXqy78uUPS16C4OU5tkZeyW2iPqw3yOUpQlDicXwe1XRNZg6IAp3a1dOvIPGipLwm4vFuj5J2ZbTrlbH)tp3GSkqwZZja63CgyaTau1cp36yvhF15uDQjHwdkkIDKPLMacqB0squNdh1ja63Cguue7itlnbeEU1XQUbkMgLDrBR4GaM7y16(4VoMQZHJ6ea9BodmGwaQAbceBBJR7J)6y6764TohoQt3yiROSyH6(4VoM(2ZzdDrTNJwIqImAMv2qgAiozV6JYz(O9CqB0sq4)0ZniRcK18Cdeskqj0bgqlavTabITTX19rDoRohoQta0V5mWaAbOQfEU15WrDQrsbnOBmKvuwSqDFuNZ(2ZzdDrTNl9zeXADgnZgfbcsz7vFur2hTNdAJwcc)NEUbzvGSMNBkrisD8vhF1Pgjf0GUXqwrzXc1Xd15SVRJ36(cRZg6I68aHKcucDD8whZ1nLiePo(QJV6uJKcAq3yiROSyH64H6C231Xd1nqiPaLqhyaTau1cei22gxhV19fwNn0f15bcjfOe6641ZzdDrTNl9zeXADgnZgfbcsz7vFuF1hTNdAJwcc)NEUbzvGSMNd7cszwnskO4W06mAMPUxgaUoM)RlP6C4OoITImWaAnycboSDDmxhf(76yvh0ajn56(OoN)3EoBOlQ9Ct04Hbr2OiqwfY0Gf7vFuuyF0EoOnAji8F65gKvbYAEoSliLz1iPGIdtRZOzM6Eza46y(VUKQZHJ6i2kYadO1Gje4W21XCDu4V9C2qxu75CFKDM82PzAPHvV6JY57J2ZbTrlbH)tp3GSkqwZZr)MZabgulbmoprKbeEU15WrD0V5mqGb1saJZteza5b61kqcy1gux3h1X03EoBOlQ9CkBi)AA0Rf5jImaV6JY55J2ZzdDrTNJSUUsiVDg7AdWZbTrlbH)tV6JIc0hTNZg6IApxciIuWa2otamQTEaEoOnAji8F6vFum9TpAph0gTee(p9CdYQaznph0ajn56(OUV(DDSQZP6giKuGsOdmGwaQAHNRNZg6IApxmeJijNrZS8nwrwqalg7vFumXKpAph0gTee(p9CdYQaznpNAKuqdSbtQSdUdToMRZ59DDoCuNAKuqdSbtQSdUdTUp(RlPVRZHJ6uJKcAq3yiROS7qZj9DDmxNZ(2ZzdDrTNJaM72P5P0IbSx9QNtat7jvF0(OyYhTNdAJwcc)NEUbzvGSMNZP6WkysLnicMu65SHUO2Zr9oO2R(OsYhTNZg6IAphwbtQS9CqB0sq4)0R(OCMpAph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45GgiPjhiqk01rvDUOfJAqKPLaiW1XZ158R7lSo(QlP6456WUGuMzByfQJxphdJKBlg8CqdK0KZeif68aftVni8QpQi7J2ZbTrlbH)tphY1ZHb1ZzdDrTNJHrwJwcEogM8bEoSliLz1iPGIdtRZOzM6Eza46(OUK8CmmsUTyWZH3ovcz1iPG6vFuF1hTNdAJwcc)NEUbzvGSMNdRGjv2GiqqPpWZzdDrTNBysz2g6I6SCXQNtUyn3wm45WkysLni8QpkkSpAph0gTee(p9CdYQaznphF15uDQjHwdXgwbs2WydJ3oaTrlbrDoCuNaPHuJqqke0Dq92P1XRNZg6IAp3WKYSn0f1z5IvpNCXAUTyWZneyV6JY57J2ZbTrlbH)tpNn0f1EUHjLzBOlQZYfREo5I1CBXGNtGuV6JY55J2ZbTrlbH)tpNn0f1EUHjLzBOlQZYfREo5I1CBXGNtSeyOE1hffOpAph0gTee(p9CdYQaznph0ajn5GaM7y16y(VoM(ADuvhdJSgTecqdK0KZeif68aftVni8C2qxu75mYWAiRicbA1R(Oy6BF0EoBOlQ9CgzynKDFsm45G2OLGW)Px9rXet(O9C2qxu75KBkBfN5r)ePXqREoOnAji8F6vFumLKpApNn0f1EoAlnJMzLSdQXEoOnAji8F6vV65CjWaftBQpAFum5J2ZzdDrTNZCDLjNDrlg1EoOnAji8F6vFuj5J2ZbTrlbH)tpNn0f1EUyJqniYtejlatz75gKvbYAEoITImWaAnycboSDDmxhtF1Z5sGbkM20mggOwG9CF1R(OCMpApNn0f1EoScMuz75G2OLGW)Px9rfzF0EoOnAji8F65Alg8CgfXSnIHZtuRz0m7IsaiEoBOlQ9CgfXSnIHZtuRz0m7IsaiE1h1x9r75SHUO2Z5I0f1EoOnAji8F6vV65elbgQpAFum5J2ZbTrlbH)tp3GSkqwZZnqX0OSlABfxhZ)1f56OQo1KqRbbaUajJvIPwkehG2OLGOow1XxDcG(nNbgqlavTWZTohoQta0V5mOOi2rMwAci8CRZHJ6GgiPjheWChRw3h)1XxDqZaAuC2fHKzbm3XQ1X8xwD8vxsFToQQJHrwJwcbObsAYzcKcDEGIP3ge1XBD8wNdh15uDmmYA0siG3ovcz1iPGwhV1XQo(QZP6utcTgGiWwN(22uiaTrlbrDoCu3aHKcucDaIaBD6BBtHabITTX1XCDjvhVEoBOlQ9CqZaAuSx9rLKpAph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45gOyAu2fTTIdcyUJvRJ56yQohoQdAGKMCqaZDSADF8xxsFToQQJHrwJwcbObsAYzcKcDEGIP3ge15WrDovhdJSgTec4TtLqwnskOEoggj3wm45EyipxPeiE1hLZ8r75G2OLGW)PNBqwfiR55yyK1OLq4HH8CLsGuhR6mkcKvHamyJ2ontlnbGdqB0squhR6WUGuMvJKckomToJMzQ7LbGRJ5)6sYZzdDrTNBADgnZu3lda7vFur2hTNdAJwcc)NEUbzvGSMNJHrwJwcHhgYZvkbsDSQJV6OFZzG9keqNPLMaWbSAdQRJ5)6yIcSohoQJV6CQoxYIiRMCMGutxuxhR6WUGuMvJKckomToJMzQ7LbGRJ5)6ICDuvhF1zueiRcbb6rlHSaHHaXAQRJ56sQoERJQ6WkysLniceu6dQJ3641ZzdDrTNBADgnZu3lda7vFuF1hTNdAJwcc)NEoBOlQ9CtRZOzM6Ezayp3GSkqwZZXWiRrlHWdd55kLaPow1HDbPmRgjfuCyADgnZu3ldaxhZ)15mp3i5HeYQrsbf7JIjV6JIc7J2ZbTrlbH)tp3GSkqwZZXWiRrlHWdd55kLaPow1XxD0V5mql3wGxbeEU15WrDovNAsO1adOrXzYdZoaTrlbrDSQZP6mkcKvHGa9OLqwGWqaAJwcI641ZzdDrTNJwUTaVcWR(OC((O9CqB0sq4)0ZzdDrTNl(PR0uWZniRcK18CmmYA0si8WqEUsjqQJvDyxqkZQrsbfhMwNrZm19YaW19xxsEUrYdjKvJKck2hftE1hLZZhTNdAJwcc)NEUbzvGSMNJHrwJwcHhgYZvkbINZg6IApx8txPPGx9QNBiW(O9rXKpAph0gTee(p9C2qxu75mkIzBedNNOwZOz2fLaq8CdYQaznpNt1HvWKkBqemPSow1fByfizdJnmE7mbITTX19x331XQo(QBGqsbkHoWaAbOQfiqSTnUUp(YQBGqsbkHoOOi2rMwAciqGyBBCD8w3h1X031rvDm9DD8CDap2BDDbrWWSzynGZeJIisEGiMSow15uDcG(nNbgqlavTWZTow15uDcG(nNbffXoY0staHNRNRTyWZzueZ2igoprTMrZSlkbG4vFuj5J2ZbTrlbH)tp3GSkqwZZ5uDyfmPYgebtkRJvDcKgipx9rGGUdQ3oTow1fByfizdJnmE7mbITTX19x33EoBOlQ9CdtkZ2qxuNLlw9CYfR52IbphGXqpaSx9r5mF0EoOnAji8F65SHUO2ZfBeQbrEIizbykBp3GSkqwZZrSvKbgqRbtiWHNBDSQJV6uJKcAq3yiROSyH6(OUbkMgLDrBR4GaM7y16456yk816C4OUbkMgLDrBR4GaM7y16y(VUHBo2IiJDHwuhVEUrYdjKvJKck2hftE1hvK9r75G2OLGW)PNBqwfiR55i2kYadO1Gje4W21XCDo7764H6i2kYadO1Gje4G4rmDrDDSQBGIPrzx02koiG5owToM)RB4MJTiYyxOfEoBOlQ9CXgHAqKNiswaMY2R(O(QpAph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45CQo1KqRb8JwbY8LcbOnAjiQZHJ6CQoJIazviGztqpbiY43CIgMUOoaTrlbrDoCuNaPHuJqqkeCJFsDDLlqQJ56yQow1XxDyxqkZQrsbfhMwNrZm19YaW19rDu46C4OoNQBGqsbkHoWW6fZo8CRJxphdJKBlg8CmGwaQAz8JwbY8Lc5bQfRUO2R(OOW(O9CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNZP6utcTg6nLTIvtsnqcqB0squNdh15uDQjHwdqeyRtFBBkeG2OLGOohoQBGqsbkHoarGTo9TTPqGaX2246(OUVwhpuxs1XZ1PMeAniaWfizSsm1sH4a0gTeeEoggj3wm45yaTau1Y9MYwXQjPgi5bQfRUO2R(OC((O9CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNZP6aES366cIGrrmBJy48e1AgnZUOeasDoCuNrrGSkeWSjONaez8BordtxuhG2OLGOohoQta0V5mqmkIi5bIyYSaOFZzqGsORZHJ6giKuGsOdgMndRbCMyuerYdeXKbceBBJR7J6y676yvhF1nqiPaLqhuue7itlnbeiqSTnUUpQJP6C4Oobq)MZGIIyhzAPjGWZToE9CmmsUTyWZXaAbOQLNOwZdulwDrTx9r588r75G2OLGW)PNBqwfiR55CQoScMuzdIabL(G6yvNaPbYZvFeiO7G6TtRJvDovNaOFZzGb0cqvl8CRJvDmmYA0siWaAbOQLXpAfiZxkKhOwS6I66yvhdJSgTecmGwaQA5EtzRy1KudK8a1IvxuxhR6yyK1OLqGb0cqvlprTMhOwS6IApNn0f1EogqlavnV6JIc0hTNdAJwcc)NEUbzvGSMNtnj0AaIaBD6BBtHa0gTee1XQo(Qtnj0AO3u2kwnj1ajaTrlbrDoCuNAsO1a(rRaz(sHa0gTee1XQoggznAjeWBNkHSAKuqRJ36yv3aftJYUOTvCDm)x3WnhBrKXUqlQJvDdeskqj0bicS1PVTnfcei22gx3h1XuDSQJV6CQo1KqRb8JwbY8LcbOnAjiQZHJ6CQoJIazviGztqpbiY43CIgMUOoaTrlbrDoCuNaPHuJqqkeCJFsDDLlqQ7J)6yQoE9C2qxu75yy9Iz7vFum9TpAph0gTee(p9CdYQaznpNAsO1qVPSvSAsQbsaAJwcI6yvNt1PMeAnarGTo9TTPqaAJwcI6yv3aftJYUOTvCDm)x3WnhBrKXUqlQJvDcG(nNbgqlavTWZ1ZzdDrTNJH1lMTx9rXet(O9CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNZOiqwfcy2e0taIm(nNOHPlQdqB0squhR64RUg1zmot)MtqKvJKckUoM)RJP6C4OoSliLz1iPGIdtRZOzM6Eza46(RZz1XBDSQJV6W4m9BobrwnskO4SrJyazxRfq8oQ7VUVRZHJ6WUGuMvJKckomToJMzQ7LbGRJ5)6OW1XRNJHrYTfdEomoZW6fZopqTy1f1E1hftj5J2ZbTrlbH)tpNn0f1EoxesMjag9idWZbrOelBXOxREUi)vp3erYneH6JIjV6JIjN5J2ZbTrlbH)tp3GSkqwZZPMeAnGF0kqMVuiaTrlbrDSQZP6WkysLniceu6dQJvDdeskqj0HuJqqkeEU1XQo(QJHrwJwcbmoZW6fZopqTy1f115WrDovNrrGSkeWSjONaez8BordtxuhG2OLGOow1jqAi1ieKcbcmjaMTrlH64Tow1nqX0OSlABfheWChRwhZ)1XxD8vht1rvDjvhpxNrrGSkeWSjONaez8BordtxuhG2OLGOoERJNRd7cszwnskO4W06mAMPUxgaUoERJ5VS6ICDSQJyRidmGwdMqGdBxhZ1XusEoBOlQ9CmSEXS9QpkMISpAph0gTee(p9CdYQaznpNAsO1qSHvGKnm2W4TdqB0squhR6CQoScMuzdIGjL1XQUydRajBySHXBNjqSTnUUp(R776yvNt1jqAG8C1hbceysamBJwc1XQobsdPgHGuiqGyBBCDmxNZQJvDcG(nNbgqlavTWZTow1XxDovNAsO1GIIyhzAPjGa0gTee15WrDcG(nNbffXoY0staHNBD8whR64RoNQdWyOhqGwIqImAMv2qgAio5qSXJgrQZHJ6ea9Bod0sesKrZSYgYqdXjhEU1XRNZg6IAphdRxmBV6JIPV6J2ZbTrlbH)tp3GSkqwZZ5uDyfmPYgebtkRJvDgfbYQqaZMGEcqKXV5enmDrDaAJwcI6yvNaPHuJqqkeiWKay2gTeQJvDcKgsncbPqWn(j11vUaPUp(RJP6yv3aftJYUOTvCqaZDSADm)xhtEoBOlQ9Cy2MaLqmifE1hftuyF0EoOnAji8F65gKvbYAEobsdKNR(iqGaX2246yUUixhv1f56456gU5ylIm2fArDSQZP6einKAecsHabMeaZ2OLGNZg6IApheb26032McE1hftoFF0EoOnAji8F65gKvbYAEobsdKNR(iqq3b1BNwhR64RoNQd4XERRlicgfXSnIHZtuRz0m7Isai15WrDdeskqj0bgqlavTabITTX1XCDm9DD865SHUO2ZPOi2rMwAcWR(OyY55J2ZbTrlbH)tp3GSkqwZZr)MZaTeHeYhwdeWgADoCuNaOFZzGb0cqvl8C9C2qxu75Cr6IAV6JIjkqF0EoOnAji8F65gKvbYAEobq)MZadOfGQw4565SHUO2ZrlrirE(ij7vFuj9TpAph0gTee(p9CdYQaznpNaOFZzGb0cqvl8C9C2qxu75ObcgiuVDQx9rLet(O9CqB0sq4)0ZniRcK18CcG(nNbgqlavTWZ1ZzdDrTNBUeGwIqcV6JkPK8r75G2OLGW)PNBqwfiR55ea9BodmGwaQAHNRNZg6IApN1daRetMhMu6vFuj5mF0EoOnAji8F65SHUO2ZLAsyysjqWzAeQ9CdYQaznp3aHKcucDGb0cqvlqGyBBCDmxxK)QNRTyWZLAsyysjqWzAeQ9QpQKISpAph0gTee(p9C2qxu75mmBgwd4mXOiIKhiIj9CdYQaznpNaOFZzGyuerYdeXKzbq)MZGaLqxNdh1ja63CgyaTau1cei22gxhZ1X031Xd1f56456aES366cIGrrmBJy48e1AgnZUOeasDoCuNAKuqd6gdzfLflu3h1L03EU2IbpNHzZWAaNjgfrK8armPx9rL0x9r75G2OLGW)PNZg6IAp3i5HePeuVJmT0WQNBqwfiR55InScKSHXggVDMaX2246(R776yvNt1ja63CgyaTau1cp36yvNt1ja63Cguue7itlnbeEU1XQo63CgIHyej5mAMLVXkYccyX4GaLqxhR6GgiPjx3h158(Uow1jqAG8C1hbcei22gxhZ1fzphmNWqZTfdEUrYdjsjOEhzAPHvV6JkjkSpAph0gTee(p9C2qxu75Kpc1abN3gVIf9W50DQEUbzvGSMNta0V5mWaAbOQfEUEU2IbpN8rOgi4824vSOhoNUt1R(OsY57J2ZbTrlbH)tpNn0f1Eo5dRe0dNtrsb0zx5l2sbp3GSkqwZZja63CgyaTau1cpxpxBXGNt(Wkb9W5uKuaD2v(ITuWR(OsY55J2ZbTrlbH)tpNn0f1EUuPjwtreCogeMuUO2ZniRcK18CcG(nNbgqlavTWZ1ZbZjm0CBXGNlvAI1uebNJbHjLlQ9QpQKOa9r75G2OLGW)PNZg6IApxQ0eRPicotBIuWZniRcK18CcG(nNbgqlavTWZ1ZbZjm0CBXGNlvAI1uebNPnrk4vFuo7BF0EoBOlQ9CpmKxfIXEoOnAji8F6vV65ei1hTpkM8r75G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(apNlzrKvtotqQPlQRJvDyxqkZQrsbfhMwNrZm19YaW1XCDoRow1XxDcKgsncbPqGaX2246(OUbcjfOe6qQriifcIhX0f115WrDUOfJAqKPLaiW1XCDFToE9CmmsUTyWZHPEDZJKhsiNAecsbV6JkjF0EoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5swez1KZeKA6I66yvh2fKYSAKuqXHP1z0mtDVmaCDmxNZQJvD8vNaOFZzqrrSJmT0eq45wNdh1XxDUOfJAqKPLaiW1XCDFTow15uDgfbYQqapGwZOzMwIqIa0gTee1XBD865yyKCBXGNdt96MhjpKqM8C1hb8QpkN5J2ZbTrlbH)tphY1ZHb1ZzdDrTNJHrwJwcEogM8bEobq)MZadOfGQw45whR64Robq)MZGIIyhzAPjGWZTohoQl2WkqYggBy82zceBBJRJ56(UoERJvDcKgipx9rGabITTX1XCDj55yyKCBXGNdt96Mjpx9raV6JkY(O9CqB0sq4)0ZniRcK18CQjHwdqeyRtFBBkeG2OLGOow1XxD8v3aftJYUOTvCDm)x3WnhBrKXUqlQJvDdeskqj0bicS1PVTnfcei22gx3h1XuD8wNdh1XxDovNUdQ3oTow1XxD6gd1XCDm9DDoCu3aftJYUOTvCDm)xxs1XBD8whVEoBOlQ9CKNR(iGx9r9vF0EoOnAji8F65MisUHiuFum55SHUO2Z5IqYmbWOhzaE1hff2hTNdAJwcc)NEUbzvGSMNJV6CQo1KqRb8JwbY8LcbOnAjiQZHJ6CQo(QBGqsbkHoWW6fZo8CRJvDdeskqj0bgqlavTabITTX19XFDrUoERJ36yv3aftJYUOTvCqaZDSADm)xht1rvDoRoEUo(QZOiqwfcy2e0taIm(nNOHPlQdqB0squhR6giKuGsOdmSEXSdp364Tow1rGjbWSnAjuhR64Ro34Nuxx5cK6(4VoMQZHJ6iqSTnUUp(Rt3b1zDJH6yvh2fKYSAKuqXHP1z0mtDVmaCDm)xNZQJQ6mkcKvHaMnb9eGiJFZjAy6I6a0gTee1XBDSQJV6CQoicS1PVTnfe15WrDei22gx3h)1P7G6SUXqD8CDjvhR6WUGuMvJKckomToJMzQ7LbGRJ5)6CwDuvNrrGSkeWSjONaez8BordtxuhG2OLGOoERJvDovhgNPFZjiQJvD8vNAKuqd6gdzfLfluhpuhbITTX1XBDmxxKRJvD8vxSHvGKnm2W4TZei22gx3FDFxNdh15uD6oOE706yvNrrGSkeWSjONaez8BordtxuhG2OLGOoE9C2qxu75sncbPGx9r589r75G2OLGW)PNBIi5gIq9rXKNZg6IApNlcjZeaJEKb4vFuopF0EoOnAji8F65SHUO2ZLAecsbp3GSkqwZZ5uDmmYA0siGPEDZJKhsiNAecsH6yvhF15uDQjHwd4hTcK5lfcqB0squNdh15uD8v3aHKcucDGH1lMD45whR6giKuGsOdmGwaQAbceBBJR7J)6ICD8whV1XQUbkMgLDrBR4GaM7y16y(VoMQJQ6CwD8CD8vNrrGSkeWSjONaez8BordtxuhG2OLGOow1nqiPaLqhyy9IzhEU1XBDSQJatcGzB0sOow1XxDUXpPUUYfi19XFDmvNdh1rGyBBCDF8xNUdQZ6gd1XQoSliLz1iPGIdtRZOzM6Eza46y(VoNvhv1zueiRcbmBc6jarg)Mt0W0f1bOnAjiQJ36yvhF15uDqeyRtFBBkiQZHJ6iqSTnUUp(Rt3b1zDJH6456sQow1HDbPmRgjfuCyADgnZu3ldaxhZ)15S6OQoJIazviGztqpbiY43CIgMUOoaTrlbrD8whR6CQomot)MtquhR64Ro1iPGg0ngYkklwOoEOoceBBJRJ36yUoMsQow1XxDXgwbs2WydJ3otGyBBCD)19DDoCuNt1P7G6TtRJvDgfbYQqaZMGEcqKXV5enmDrDaAJwcI641ZnsEiHSAKuqX(OyYR(OOa9r75G2OLGW)PNBqwfiR55WUGuMvJKckUoM)RlP6yvhbITTX19rDjvhv1XxDyxqkZQrsbfxhZ)19164Tow1nqX0OSlABfxhZ)1fzpNn0f1EUbzJXOoRqSlGvV6JIPV9r75G2OLGW)PNBqwfiR55CQoggznAjeWuVUzYZvFeOow1nqX0OSlABfxhZ)1f56yvhbMeaZ2OLqDSQJV6CJFsDDLlqQ7J)6yQohoQJaX2246(4VoDhuN1ngQJvDyxqkZQrsbfhMwNrZm19YaW1X8FDoRoQQZOiqwfcy2e0taIm(nNOHPlQdqB0squhV1XQo(QZP6GiWwN(22uquNdh1rGyBBCDF8xNUdQZ6gd1XZ1LuDSQd7cszwnskO4W06mAMPUxgaUoM)RZz1rvDgfbYQqaZMGEcqKXV5enmDrDaAJwcI64Tow1Pgjf0GUXqwrzXc1Xd1rGyBBCDmxxK9C2qxu75ipx9raV6JIjM8r75G2OLGW)PNZg6IAph55Qpc45gKvbYAEoNQJHrwJwcbm1RBEK8qczYZvFeOow15uDmmYA0siGPEDZKNR(iqDSQBGIPrzx02kUoM)RlY1XQocmjaMTrlH6yvhF15g)K66kxGu3h)1XuDoCuhbITTX19XFD6oOoRBmuhR6WUGuMvJKckomToJMzQ7LbGRJ5)6CwDuvNrrGSkeWSjONaez8BordtxuhG2OLGOoERJvD8vNt1brGTo9TTPGOohoQJaX2246(4VoDhuN1ngQJNRlP6yvh2fKYSAKuqXHP1z0mtDVmaCDm)xNZQJQ6mkcKvHaMnb9eGiJFZjAy6I6a0gTee1XBDSQtnskObDJHSIYIfQJhQJaX2246yUUi75gjpKqwnskOyFum5vV6vphdGGxu7JkPVt67Vt6BkCijpxcgP3of75CUIDrefe158RZg6I66KlwXHIspNlbnxj45IuDuim2W4TnDrDDuqu6dkkJuDSv1fZttmX0vz)OdduCI4n(jnDr9Gytnr8gpsSOms19Ld0KNrsUoMsI)6s67K(UOSOms1XtyBDkG5PfLrQoEOokKqaI6(c2b11PO6eW0EsToBOlQRtUynuugP64H6OGqmIbuNAKuqZ7muugP64H6OqcbiQJhfgQZ5sHyCD8HEkEfqDOzDyfmPYM3qrzrzKQZ5ebmEkiQJgMicu3aftBAD0q624qDuOXaCvCDnQ5b2gjE(K1zdDrnUoultouugP6SHUOghCjWaftB6)uAyQlkJuD2qxuJdUeyGIPnLQ)eTxAm0QPlQlkJuD2qxuJdUeyGIPnLQ)eNiKOOms1X1MlMnsRJyROo63CcI6WQP46OHjIa1nqX0MwhnKUnUoRf15saEWfP62P1T46eOgcfLrQoBOlQXbxcmqX0Ms1FI42CXSrAgRMIlkTHUOghCjWaftBkv)jAUUYKZUOfJ6IsBOlQXbxcmqX0Ms1FIXgHAqKNiswaMYMFxcmqX0MMXWa1c8)x5FN)eBfzGb0AWecCyBMz6RfL2qxuJdUeyGIPnLQ)eXkysLDrPn0f14GlbgOyAtP6pXhgYRcX83wm8BueZ2igoprTMrZSlkbGuuAdDrno4sGbkM2uQ(t0fPlQlklkJuDoNiGXtbrDadGKCD6gd1PSH6SHIi1T46mg2knAjekkJuDuqaRGjv21TZ6Cry8slH64Rr1X4jBGy0sOoOH4fW1TDDdumTP8wuAdDrn(N6Dqn)783jScMuzdIGjLfL2qxuJP6prScMuzxuAdDrnMQ)ezyK1OLa)Tfd)qdK0KZeif68aftVni4NHjFWp0ajn5absHMkx0IrniY0saeyE25)fYxs8m2fKYmBdRaVfL2qxuJP6prggznAjWFBXWpE7ujKvJKck)mm5d(XUGuMvJKckomToJMzQ7LbG)iPIsBOlQXu9N4WKYSn0f1z5Iv(Blg(XkysLni4FN)yfmPYgebck9bfL2qxuJP6pXHjLzBOlQZYfR83wm8pey(35pFoPMeAneByfizdJnmE7a0gTeeoCiqAi1ieKcbDhuVDkVfL2qxuJP6pXHjLzBOlQZYfR83wm8lqArPn0f1yQ(tCysz2g6I6SCXk)Tfd)ILadTO0g6IAmv)jAKH1qwrec0k)78hAGKMCqaZDSkZ)m9vQyyK1OLqaAGKMCMaPqNhOy6TbrrPn0f1yQ(t0idRHS7tIHIsBOlQXu9NOCtzR4mp6NingATO0g6IAmv)jsBPz0mRKDqnUOSOms1XtqiPaLqJlkTHUOghgc8)dd5vHy(Blg(nkIzBedNNOwZOz2fLaq4FN)oHvWKkBqemPKvSHvGKnm2W4TZei22g))nl(giKuGsOdmGwaQAbceBBJ)4lBGqsbkHoOOi2rMwAciqGyBBmVFW03uX038mWJ9wxxqemmBgwd4mXOiIKhiIjz5KaOFZzGb0cqvl8Cz5KaOFZzqrrSJmT0eq45wuAdDrnomeyQ(tCysz2g6I6SCXk)Tfd)agd9aW8VZFNWkysLnicMuYsG0a55Qpce0Dq92PSInScKSHXggVDMaX224)VlkJuDoxZ6mHaxNrG6EU8xhUxxOoLnuhQH6syv21jrjayTUOJ(lfQJhfgQlb2qxNi5TtRBAyfi1PSTUoEYxSobm3XQ1Hi1LWQSrpToRtUoEYxmuuAdDrnomeyQ(tm2iudI8erYcWu28psEiHSAKuqX)mX)o)j2kYadO1Gje4WZLfFQrsbnOBmKvuwSWhdumnk7I2wXbbm3XQ8mtHV6WXaftJYUOTvCqaZDSkZ)d3CSfrg7cTG3IYivNZ1SUgvNje46syLY6eluxcRYE76u2qDneHwNZ(gZFDpmuNZ98lvhQRJgHX1LWQSrpToRtUoEYxmuuAdDrnomeyQ(tm2iudI8erYcWu28VZFITImWaAnycboSnZo7BEGyRidmGwdMqGdIhX0f1SgOyAu2fTTIdcyUJvz(F4MJTiYyxOffLrQokaOfGQwDsu6omzDdulwDrTjX1rByquhQRB8ieO16WUWOO0g6IACyiWu9NidJSgTe4VTy4Nb0cqvlJF0kqMVuipqTy1f18ZWKp43j1KqRb8JwbY8LcbOnAjiC4WjJIazviGztqpbiY43CIgMUOoaTrlbHdhcKgsncbPqWn(j11vUaHzMyXh2fKYSAKuqXHP1z0mtDVma8huyhoCAGqsbkHoWW6fZo8C5TO0g6IACyiWu9NidJSgTe4VTy4Nb0cqvl3BkBfRMKAGKhOwS6IA(zyYh87KAsO1qVPSvSAsQbsaAJwcchoCsnj0AaIaBD6BBtHa0gTeeoCmqiPaLqhGiWwN(22uiqGyBB8hFLhsINvtcTgea4cKmwjMAPqCaAJwcIIsBOlQXHHat1FImmYA0sG)2IHFggznAjWFBXWpdOfGQwEIAnpqTy1f18ZWKp43jGh7TUUGiyueZ2igoprTMrZSlkbG4WHrrGSkeWSjONaez8BordtxuhG2OLGWHdbq)MZaXOiIKhiIjZcG(nNbbkH2HJbcjfOe6GHzZWAaNjgfrK8armzGaX224py6Bw8nqiPaLqhuue7itlnbeiqSTn(dMC4qa0V5mOOi2rMwAci8C5TO0g6IACyiWu9NidOfGQg)783jScMuzdIabL(awcKgipx9rGGUdQ3oLLtcG(nNbgqlavTWZLfdJSgTecmGwaQAz8JwbY8Lc5bQfRUOMfdJSgTecmGwaQA5EtzRy1KudK8a1IvxuZIHrwJwcbgqlavT8e1AEGAXQlQlkJuDuawVy21LWQSRZ5eboToQQJVO2u2kwnj1aH)6qK64E0kqMVuOoultUouxhtrZlpToNBlIn(fxhp5lwN1I6CorGtRJaMi56MisDneHwhpop5lvuAdDrnomeyQ(tKH1lMn)78xnj0AaIaBD6BBtHa0gTeeS4tnj0AO3u2kwnj1ajaTrlbHdhQjHwd4hTcK5lfcqB0sqWIHrwJwcb82PsiRgjfuEznqX0OSlABfZ8)WnhBrKXUqlynqiPaLqhGiWwN(22uiqGyBB8hmXIpNutcTgWpAfiZxkeG2OLGWHdNmkcKvHaMnb9eGiJFZjAy6I6a0gTeeoCiqAi1ieKcb34Nuxx5cKp(zI3IYivhfG1lMDDjSk76IAtzRy1KudK6OQUOq15CIaNYtRZ52IyJFX1Xt(I1zTOokaOfGQwDp3IsBOlQXHHat1FImSEXS5FN)QjHwd9MYwXQjPgibOnAjiy5KAsO1aeb26032McbOnAjiynqX0OSlABfZ8)WnhBrKXUqlyja63CgyaTau1cp3IYivhha1nFszDduCm0ADOUo2Q6I5PjMy6QSF0HbkorkOXaA2iPq5HO5jjsbrPpiXewQ3ePqySHXBB6IAEGc9f5rYduqadgzWouuAdDrnomeyQ(tKHrwJwc83wm8JXzgwVy25bQfRUOMFgM8b)gfbYQqaZMGEcqKXV5enmDrDaAJwccw81OoJXz63CcISAKuqXm)ZKdhyxqkZQrsbfhMwNrZm19YaW)oJxw8HXz63CcISAKuqXzJgXaYUwlG4D8)TdhyxqkZQrsbfhMwNrZm19YaWm)tH5TO0g6IACyiWu9NOlcjZeaJEKbW)erYneH(Ze)qekXYwm616FK)ArPn0f14WqGP6prgwVy28VZF1KqRb8JwbY8LcbOnAjiy5ewbtQSbrGGsFaRbcjfOe6qQriifcpxw8XWiRrlHagNzy9IzNhOwS6IAhoCYOiqwfcy2e0taIm(nNOHPlQdqB0sqWsG0qQriifceysamBJwc8YAGIPrzx02koiG5owL5F(4JjQsINnkcKvHaMnb9eGiJFZjAy6I6a0gTee8YZyxqkZQrsbfhMwNrZm19YaW8Y8xwKzrSvKbgqRbtiWHTzMPKkkJuDuawVy21LWQSRZ52WkqQJcHXgEBEADrHQdRGjv21zTOUgvNn0LbuNZnfQo63CYFDuWNR(iqDnsRB76iWKay21rSof4VoXJSDADuaqlavnQI(t(Rt8iBNw3NsesuhGXqtX62zDgdBLgTecfL2qxuJddbMQ)ezy9IzZ)o)vtcTgInScKSHXggVDaAJwccwoHvWKkBqemPKvSHvGKnm2W4TZei22g)X)3SCsG0a55QpceiWKay2gTeyjqAi1ieKcbceBBJz2zSea9BodmGwaQAHNll(Csnj0AqrrSJmT0eqaAJwcchoea9BodkkIDKPLMacpxEzXNtagd9ac0sesKrZSYgYqdXjhInE0iIdhcG(nNbAjcjYOzwzdzOH4KdpxElkJuDCSnbkHyqkQBIi1XXMGEcquh3BordtxuxuAdDrnomeyQ(teZ2eOeIbPG)D(7ewbtQSbrWKswgfbYQqaZMGEcqKXV5enmDrDaAJwccwcKgsncbPqGatcGzB0sGLaPHuJqqkeCJFsDDLlq(4Njwdumnk7I2wXbbm3XQm)ZurzKQZ5eb26032Mc1LaBORJgPSRJc(C1hbQZArD84gHGuOoJa19CRBIi1jrDADqJEPSlkTHUOghgcmv)jcrGTo9TTPa)78xG0a55QpceiqSTnM5itvK55HBo2IiJDHwWYjbsdPgHGuiqGjbWSnAjuuAdDrnomeyQ(turrSJmT0ea)78xG0a55Qpce0Dq92PS4ZjGh7TUUGiyueZ2igoprTMrZSlkbG4WXaHKcucDGb0cqvlqGyBBmZm9nVfL2qxuJddbMQ)eDr6IA(35p9Bod0sesiFynqaBOoCia63CgyaTau1cp3IsBOlQXHHat1FI0sesKNpsY8VZFbq)MZadOfGQw45wuAdDrnomeyQ(tKgiyGq92P8VZFbq)MZadOfGQw45wuAdDrnomeyQ(tCUeGwIqc(35VaOFZzGb0cqvl8ClkTHUOghgcmv)jA9aWkXK5HjL8VZFbq)MZadOfGQw45wuAdDrnomeyQ(t8HH8Qqm)Tfd)PMegMuceCMgHA(35)aHKcucDGb0cqvlqGyBBmZr(RfL2qxuJddbMQ)eFyiVkeZFBXWVHzZWAaNjgfrK8armj)78xa0V5mqmkIi5bIyYSaOFZzqGsOD4qa0V5mWaAbOQfiqSTnMzM(MhImpd8yV11febJIy2gXW5jQ1mAMDrjaehouJKcAq3yiROSyHps67IsBOlQXHHat1FIpmKxfI5hMtyO52IH)rYdjsjOEhzAPHv(35FSHvGKnm2W4TZei22g))nlNea9BodmGwaQAHNllNea9BodkkIDKPLMacpxw0V5medXisYz0mlFJvKfeWIXbbkHMf0ajn5pCEFZsG0a55QpceiqSTnM5ixuAdDrnomeyQ(t8HH8Qqm)Tfd)YhHAGGZBJxXIE4C6ov(35VaOFZzGb0cqvl8ClkTHUOghgcmv)j(WqEviM)2IHF5dRe0dNtrsb0zx5l2sb(35VaOFZzGb0cqvl8ClkTHUOghgcmv)j(WqEviMFyoHHMBlg(tLMynfrW5yqys5IA(35VaOFZzGb0cqvl8ClkTHUOghgcmv)j(WqEviMFyoHHMBlg(tLMynfrWzAtKc8VZFbq)MZadOfGQw45wugP6(sW0EsTUPjL02G66MisDpSrlH6wfIX8064rHH6qDDdeskqj0HIsBOlQXHHat1FIpmKxfIXfLfLrQUV0sGHwNWITuOoJELRUaUOms15CAgqJIRZ06Imv1X3xPQUewLDDFjoERJN8fd15CfhdI1uqMCDOUUKOQo1iPGI5VUewLDDuaqlavn(RdrQlHvzxx0FYJG6qkBGKWIH6sWwTUjIuhgfd1bnqstouhfsIr1LGTAD7SoNte406gOyAuDlUUbkE706EUHIsBOlQXbXsGH(dndOrX8VZ)bkMgLDrBRyM)JmvQjHwdcaCbsgRetTuioaTrlbbl(ea9BodmGwaQAHNRdhcG(nNbffXoY0staHNRdhqdK0KdcyUJv)4NpOzanko7IqYSaM7yvM)Y4lPVsfdJSgTecqdK0KZeif68aftVni4LxhoCIHrwJwcb82PsiRgjfuEzXNtQjHwdqeyRtFBBkeG2OLGWHJbcjfOe6aeb26032McbceBBJzojElkTHUOghelbgkv)jYWiRrlb(Blg(FyipxPei8ZWKp4FGIPrzx02koiG5owLzMC4aAGKMCqaZDS6h)j9vQyyK1OLqaAGKMCMaPqNhOy6TbHdhoXWiRrlHaE7ujKvJKcArzKQJhHRYUoNZGnA706(uAcaZFDF5wxhAw3xqVmaCDMwxsuvNAKuqXHIsBOlQXbXsGHs1FItRZOzM6Ezay(35pdJSgTecpmKNRucewgfbYQqagSrBNMPLMaWbOnAjiyHDbPmRgjfuCyADgnZu3ldaZ8FsfLrQUVCRRdnR7lOxgaUotRJjkqQQdR2GACDOzD8iEfcOR7tPjaCDisDwQTnwRlYuvhFFLQ6syv219LqpAju3xcHbERtnskO4qrPn0f14GyjWqP6pXP1z0mtDVmam)78NHrwJwcHhgYZvkbcl(OFZzG9keqNPLMaWbSAdQz(Njkqho4ZjxYIiRMCMGutxuZc7cszwnskO4W06mAMPUxgaM5)itfFgfbYQqqGE0silqyiqSMAMtIxQWkysLniceu6d4L3IYiv3xU11HM19f0ldaxNIQZCDLjx3xcmHm56(IOfJ662zDBBdDza1H66So56uJKcADMwNZQtnskO4qrPn0f14GyjWqP6pXP1z0mtDVmam)JKhsiRgjfu8pt8VZFggznAjeEyipxPeiSWUGuMvJKckomToJMzQ7LbGz(3zfL2qxuJdILadLQ)ePLBlWRa4FN)mmYA0si8WqEUsjqyXh9Bod0YTf4vaHNRdhoPMeAnWaAuCM8WSdqB0sqWYjJIazviiqpAjKfimeG2OLGG3IYivx0gnp4C)0vAkuNIQZCDLjx3xcmHm56(IOfJ66mTUKQtnskO4IsBOlQXbXsGHs1FIXpDLMc8psEiHSAKuqX)mX)o)zyK1OLq4HH8CLsGWc7cszwnskO4W06mAMPUxga(pPIsBOlQXbXsGHs1FIXpDLMc8VZFggznAjeEyipxPeifLfLrQUVKfBPqDigaPoDJH6m6vU6c4IYivhpYnE164XncbPaUouxxJAEWLSXeJKCDQrsbfx3erQtzd15swez1KRJGutxux3oR7RuvhTeabUoJa1zscyIKR75wuAdDrnoiq6pdJSgTe4VTy4ht96MhjpKqo1ieKc8ZWKp43LSiYQjNji10f1SWUGuMvJKckomToJMzQ7LbGz2zS4tG0qQriifcei22g)XaHKcucDi1ieKcbXJy6IAhoCrlg1GitlbqGz(R8wugP64rUXRwhf85QpcGRd111OMhCjBmXijxNAKuqX1nrK6u2qDUKfrwn56ii10f11TZ6(kv1rlbqGRZiqDMKaMi56EUfL2qxuJdcKs1FImmYA0sG)2IHFm1RBEK8qczYZvFeGFgM8b)UKfrwn5mbPMUOMf2fKYSAKuqXHP1z0mtDVmamZoJfFcG(nNbffXoY0staHNRdh85IwmQbrMwcGaZ8xz5KrrGSkeWdO1mAMPLiKiaTrlbbV8wugP64rUXRwhf85QpcGRBN1rbaTau1OkAue7OUpLMas052WkqQJcHXggVDDlUUNBDwlQlbOo2gdOUKOQommqTaxNeMADOUoLnuhf85Qpcu3xcfDrPn0f14GaPu9NidJSgTe4VTy4ht96Mjpx9ra(zyYh8la63CgyaTau1cpxw8ja63Cguue7itlnbeEUoCeByfizdJnmE7mbITTXm)nVSeinqEU6JabceBBJzoPIYivhNlmwtwhf85Qpcuhg0NBDtePoNte40IsBOlQXbbsP6prYZvFeG)D(RMeAnarGTo9TTPqaAJwccw8X3aftJYUOTvmZ)d3CSfrg7cTG1aHKcucDaIaBD6BBtHabITTXFWeVoCWNt6oOE7uw8PBmWmtF7WXaftJYUOTvmZ)jXlV8wugP64XncbPqDpxQbWL)6mjgvNswaxNIQ7HH6wTodxNvh2fgRjRlfAGykIu3erQtzd1jnSwhp5lwhnmreOoRU52lMnqkkTHUOgheiLQ)eDrizMay0Jma(NisUHi0FMkkTHUOgheiLQ)etncbPa)78NpNutcTgWpAfiZxkeG2OLGWHdN4BGqsbkHoWW6fZo8CznqiPaLqhyaTau1cei22g)XFK5Lxwdumnk7I2wXbbm3XQm)ZevoJN5ZOiqwfcy2e0taIm(nNOHPlQdqB0sqWAGqsbkHoWW6fZo8C5LfbMeaZ2OLal(CJFsDDLlq(4NjhoiqSTn(JFDhuN1ngyHDbPmRgjfuCyADgnZu3ldaZ8VZOYOiqwfcy2e0taIm(nNOHPlQdqB0sqWll(CcIaBD6BBtbHdhei22g)XVUdQZ6gd8CsSWUGuMvJKckomToJMzQ7LbGz(3zuzueiRcbmBc6jarg)Mt0W0f1bOnAji4LLtyCM(nNGGfFQrsbnOBmKvuwSapqGyBBmVmhzw8fByfizdJnmE7mbITTX)F7WHt6oOE7uwgfbYQqaZMGEcqKXV5enmDrDaAJwccElkTHUOgheiLQ)eDrizMay0Jma(NisUHi0FMkkTHUOgheiLQ)etncbPa)JKhsiRgjfu8pt8VZFNyyK1OLqat96MhjpKqo1ieKcS4Zj1KqRb8JwbY8LcbOnAjiC4Wj(giKuGsOdmSEXSdpxwdeskqj0bgqlavTabITTXF8hzE5L1aftJYUOTvCqaZDSkZ)mrLZ4z(mkcKvHaMnb9eGiJFZjAy6I6a0gTeeSgiKuGsOdmSEXSdpxEzrGjbWSnAjWIp34Nuxx5cKp(zYHdceBBJ)4x3b1zDJbwyxqkZQrsbfhMwNrZm19YaWm)7mQmkcKvHaMnb9eGiJFZjAy6I6a0gTee8YIpNGiWwN(22uq4WbbITTXF8R7G6SUXapNelSliLz1iPGIdtRZOzM6EzayM)DgvgfbYQqaZMGEcqKXV5enmDrDaAJwccEz5egNPFZjiyXNAKuqd6gdzfLflWdei22gZlZmLel(InScKSHXggVDMaX224)VD4WjDhuVDklJIazviGztqpbiY43CIgMUOoaTrlbbVfLrQoEczJXOUUOHyxaR1HAzY1H66IFsDDLqDQrsbfxNP1fzQQJN8fRlb2qxh5192P1HEADBxxs46475wNIQlY1PgjfumV1Hi15mCD89vQQtnskOyElkTHUOgheiLQ)ehKngJ6ScXUaw5FN)yxqkZQrsbfZ8FsSiqSTn(JKOIpSliLz1iPGIz()R8YAGIPrzx02kM5)ixugP6(caWTUNBDuWNR(iqDMwxKPQouxNjL1PgjfuCD8LaBORtUm2oTojQtRdA0lLDDwlQRrAD42CXSrkVfL2qxuJdcKs1FIKNR(ia)783jggznAjeWuVUzYZvFeG1aftJYUOTvmZ)rMfbMeaZ2OLal(CJFsDDLlq(4NjhoiqSTn(JFDhuN1ngyHDbPmRgjfuCyADgnZu3ldaZ8VZOYOiqwfcy2e0taIm(nNOHPlQdqB0sqWll(CcIaBD6BBtbHdhei22g)XVUdQZ6gd8CsSWUGuMvJKckomToJMzQ7LbGz(3zuzueiRcbmBc6jarg)Mt0W0f1bOnAji4LLAKuqd6gdzfLflWdei22gZCKlkTHUOgheiLQ)ejpx9ra(hjpKqwnskO4FM4FN)oXWiRrlHaM61npsEiHm55QpcWYjggznAjeWuVUzYZvFeG1aftJYUOTvmZ)rMfbMeaZ2OLal(CJFsDDLlq(4NjhoiqSTn(JFDhuN1ngyHDbPmRgjfuCyADgnZu3ldaZ8VZOYOiqwfcy2e0taIm(nNOHPlQdqB0sqWll(CcIaBD6BBtbHdhei22g)XVUdQZ6gd8CsSWUGuMvJKckomToJMzQ7LbGz(3zuzueiRcbmBc6jarg)Mt0W0f1bOnAji4LLAKuqd6gdzfLflWdei22gZCKlklkJuDohmg6bGlkTHUOghamg6bG)hOEaTsmfe5P0Ib(35p0ajn5GUXqwr5ylcMzILtcG(nNbgqlavTWZLfFojqAyG6b0kXuqKNslgY0psh0Dq92PSCYg6I6Wa1dOvIPGipLwme2opLBkB1HJ5tkZeyW2iPqw3y4J0HieBrWBrzKQJcjtWsgx3dd19PeHe1LWQSRJcaAbOQv3ZnuhfsIr19WqDjSk76I(Z6EU1rdtebQZQBU9IzdK64BN1PMeAfe8wNHRtI606mCDRwh5146MisDm9nUoXJSDADuaqlavTqrPn0f14aGXqpamv)jslrirgnZkBidneNm)78xa0V5mWaAbOQfEUS4Zj1KqRbffXoY0stabOnAjiC4qa0V5mOOi2rMwAci8CznqX0OSlABfheWChR(XptoCia63CgyaTau1cei22g)XptFZRdh6gdzfLfl8XptFxugP6OqQcXUADkQotUPDD84pJiwRRlHvzxhfa0cqvRodxNe1P1z46wTUeqnpI06ia(j162UojcVDADwDZNuYdmm5dQByyToedGuNYgQJaX22BNwN4rmDrDDOzDkBOU5MYwlkTHUOghamg6bGP6pX0NreR1z0mBueiiLn)78FGqsbkHoWaAbOQfiqSTn(dN5WHaOFZzGb0cqvl8CD4qnskObDJHSIYIf(WzFxuAdDrnoaym0dat1FIPpJiwRZOz2OiqqkB(35)uIqe(4tnskObDJHSIYIf4bN9nVFHdeskqj08Y8uIqe(4tnskObDJHSIYIf4bN9npmqiPaLqhyaTau1cei22gZ7x4aHKcucnVfL2qxuJdagd9aWu9N4enEyqKnkcKvHmnyX8VZFSliLz1iPGIdtRZOzM6EzayM)tYHdITImWaAnycboSnZu4Vzbnqst(dN)3fL2qxuJdagd9aWu9NO7JSZK3ontlnSY)o)XUGuMvJKckomToJMzQ7LbGz(pjhoi2kYadO1Gje4W2mtH)UO0g6IACaWyOhaMQ)ev2q(10OxlYteza8VZF63CgiWGAjGX5jImGWZ1Hd63CgiWGAjGX5jImG8a9AfibSAdQ)GPVlkTHUOghamg6bGP6prY66kH82zSRnGIsBOlQXbaJHEayQ(tmberkyaBNjag1wpGIsBOlQXbaJHEayQ(tmgIrKKZOzw(gRiliGfJ5FN)qdK0K)4RFZYPbcjfOe6adOfGQw45wuAdDrnoaym0dat1FIeWC3onpLwmG5FN)QrsbnWgmPYo4ouMDEF7WHAKuqdSbtQSdUd9J)K(2Hd1iPGg0ngYkk7o0CsFZSZ(UOSOms1XPGjv2GOok0qxuJlkJuDrTPSXQjPgi8xhIuh3JwPY5eboTouxhtrZtRJRnxmBKwhf85QpcuuAdDrnoGvWKkBq8tEU6Ja8VZ)bkMgLDrBRyM)Jml(utcTg6nLTIvtsnqcqB0sq4WHAsO1a(rRaz(sHa0gTeeS4tnj0AaIaBD6BBtHa0gTeeSgiKuGsOdqeyRtFBBkeiqSTn(J)KC4WjDhuVDkVSyyK1OLqaVDQeYQrsbLxwQrsbnOBmKvuwSapqGyBBmZu4IYivh3JwbY8Lc1rvDCSjONae1X9Mt0W0f1806Con(rG6saQ7HH6qnuxQerBY6uuDMRRm564XncbPqDkQoLnuxSTDDQrsbTUDw3Q1T46AKwhUnxmBKwxYGYFDyuDMuwhszdK6ITTRtnskO1z0RC1fW15sqZvdfL2qxuJdyfmPYgeu9NOlcjZeaJEKbW)erYneH(ZurPn0f14awbtQSbbv)jMAecsb(35VrrGSkeWSjONaez8BordtxuhG2OLGGf9Bod4hTcK5lfcpxw0V5mGF0kqMVuiqGyBB8hmfCglNW4m9BobrrzKQJ7rRaz(sbEADuixxzY1Hi1rbHjbWSRlHvzxh9BobrD84gHGuaxuAdDrnoGvWKkBqq1FIUiKmtam6rga)tej3qe6ptfL2qxuJdyfmPYgeu9NyQriif4FK8qcz1iPGI)zI)D(RMeAnGF0kqMVuiaTrlbbl(iqSTn(dMsYHd34Nuxx5cKp(zIxwQrsbnOBmKvuwSapqGyBBmZjvugP64E0kqMVuOoQQJJnb9eGOoU3CIgMUOUUTRJlAEADuixxzY1bgrMCDuWNR(iqDkBtRlHvkRJgQJatcGzdI6MisDUwlG4DuuAdDrnoGvWKkBqq1FIKNR(ia)78xnj0Aa)OvGmFPqaAJwccwgfbYQqaZMGEcqKXV5enmDrDaAJwccwojqAG8C1hbc6oOE7uwmmYA0siG3ovcz1iPGwugP64E0kqMVuOUesSoo2e0taI64EZjAy6IAEADuqWCDLjx3erQJg1pCD8KVyDwlserQdIqHwaI6WT5IzJ06epIPlQdfL2qxuJdyfmPYgeu9NOlcjZeaJEKbW)erYneH(ZurPn0f14awbtQSbbv)jMAecsb(hjpKqwnskO4FM4FN)QjHwd4hTcK5lfcqB0sqWYOiqwfcy2e0taIm(nNOHPlQdqB0sqWsnskObDJHSIYIfyMaX22yw8rGyBB8hm58C4Wjmot)MtqWBrzKQJ7rRaz(sH6OQoNte4uEADohgqxhIbqiRaQZQd3MlMnsRJh3ieKc1r2u2AD2ubsDuWNR(iqD0WerG6CorGTo9TTPlQlkTHUOghWkysLniO6prxesMjag9idG)jIKBic9NPIsBOlQXbScMuzdcQ(tm1ieKc8VZF1KqRb8JwbY8LcbOnAjiyPMeAnarGTo9TTPqaAJwccwdeskqj0bicS1PVTnfcei22g)btSCjaJC6qeykqEU6JaSeinqEU6JabceBBJz(RufzEE4MJTiYyxOfEoSlm8rL0xPa9Qx9Ea]] )

end