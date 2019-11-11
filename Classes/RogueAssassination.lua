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


    spec:RegisterPack( "Assassination", 20191111, [[da1H1bqiQipsa5siriBcL8jKiumkuvofkvRcLs9kuKzHQQBHePDj0VefnmukogsyzQk5zur10eqDnvfABirPVrfLACQkGZHevwhkL4DirOQ5jk19uvTpuu)tvbQdIerluvrpeLsAIQkOUivuyJurr1hPIImsKiu5KurjwjsYlvvGmtQOOCtQOK2PazOQkilfjkEkQmvrHRIevPTIebFfjcL2lv9xrgSkhMYIrQhRWKjCzWMv0NfvJgv50kTAKOkEnsQzt0Tf0UL63qgov64irvTCephQPt66QY2rHVlqnEb48IswVQsnFQW(LSNcFgEoHPGpOVydfuokOGckIu8vGPCo)JEonlxWZ5AdQTCWZ1wi45OKySHXBB6IApNRLLezcFgEom6rgGNJNQUy2sMzMVkVhDCGcZeVHpPPlQheBQzI3WrMEo63kvNL2t75eMc(G(Inuq5OGckOisXxb(lk(YZzpLhI4542q2QNJ3keq7P9Ccap8CbQokjgBy82MUOUokdk)bfvbQoEQ6IzlzMz(Q8E0Xbkmt8g(KMUOEqSPMjEdhzwufO6ccXacPbsDuqb)19fBOGYvuvufO6yR8SohWSLIQavhLwhLuiarDFq7G66uuDcyApPwNn0f11jxSglQcuDuADugieXaQtnsoOPDglQcuDuADusHae1r5fd15SOqiUo(qpfVcOo0SoScMu5XE0ZjxSI9z45WkysLhi8z4dIcFgEoOnAji8F65gKvbYAEUbkKgLCrBR46y(VUaxhR64Ro1KqRXEZ5Py1KudKi0gTee15WrDQjHwJ4hTcK5lhIqB0squhR64Ro1KqRriaS15VTnfIqB0squhR6giKuGcUJqayRZFBBkejqOTnUUS)R7R6C4OoNQt3b1BNxh71XQoggznAjeXBNlHKAKCqRJ96yvNAKCqJ6gcjfLeluhLwhbcTTX1XCDuwpNn0f1EoYZvFeWR(G(YNHNdAJwcc)NEUjIKAia1hefEoBOlQ9CUiKmram6rgGx9b5CFgEoOnAji8F65gKvbYAEo7BGSkeX8iONaej8BordtxuhH2OLGOow1r)MZi(rRaz(YH4ZTow1r)MZi(rRaz(YHibcTTX1LDDueDEDSQZP6W4e9BobHNZg6IApxUriif8QpOa7ZWZbTrlbH)tp3ersneG6dIcpNn0f1EoxesMiag9idWR(G(Opdph0gTee(p9C2qxu75YncbPGNBqwfiR55utcTgXpAfiZxoeH2OLGOow1XxDei02gxx21rXx15WrDUHpPUUYfi1L9FDuuh71XQo1i5Gg1neskkjwOokToceABJRJ56(YZnYAiHKAKCqX(GOWR(GOS(m8CqB0sq4)0ZniRcK18CQjHwJ4hTcK5lhIqB0squhR6SVbYQqeZJGEcqKWV5enmDrDeAJwcI6yvNt1jqAK8C1hbI6oOE786yvhdJSgTeI4TZLqsnsoOEoBOlQ9CKNR(iGx9b5S9z45G2OLGW)PNBIiPgcq9brHNZg6IApNlcjteaJEKb4vFqFaFgEoOnAji8F65SHUO2ZLBecsbp3GSkqwZZPMeAnIF0kqMVCicTrlbrDSQZ(giRcrmpc6jarc)Mt0W0f1rOnAjiQJvDQrYbnQBiKuusSqDmxhbcTTX1XQo(QJaH2246YUok(a15WrDovhgNOFZjiQJDp3iRHesQrYbf7dIcV6dIY5ZWZbTrlbH)tp3ersneG6dIcpNn0f1EoxesMiag9idWR(GOGn(m8CqB0sq4)0ZniRcK18CQjHwJ4hTcK5lhIqB0squhR6utcTgHaWwN)22uicTrlbrDSQBGqsbk4ocbGTo)TTPqKaH2246YUokQJvDUeGrkFiIuejpx9rG6yvNaPrYZvFeisGqBBCDmx3hRJP6cCDSDDd3uOfqc7cTWZzdDrTNl3ieKcE1REoaJHEayFg(GOWNHNdAJwcc)NEUbzvGSMNdAGKNvu3qiPOuOfqDmxhf1XQoNQta0V5mYaAbOQfFU1XQo(QZP6einoq9aALykistPfcj6hPJ6oOE786yvNt1zdDrDCG6b0kXuqKMsleIBNMYnNNwNdh1nFszIadEgjhs6gc1LDD5drm0cOo29C2qxu75gOEaTsmfePP0cbV6d6lFgEoOnAji8F65gKvbYAEobq)MZidOfGQw85whR64RoNQtnj0AurbSJeT0eqeAJwcI6C4Oobq)MZOIcyhjAPjG4ZTow1nqH0OKlABfhfWChRwx2)1rrDoCuNaOFZzKb0cqvlsGqBBCDz)xhfSPo2RZHJ60neskkjwOUS)RJc245SHUO2ZrlrircntkpibneMLx9b5CFgEoOnAji8F65gKvbYAEUbcjfOG7idOfGQwKaH2246YUoNxNdh1ja63CgzaTau1Ip36C4Oo1i5Gg1neskkjwOUSRZ5SXZzdDrTNl)zeXADcnt23abP88QpOa7ZWZbTrlbH)tp3GSkqwZZnLiePo(QJV6uJKdAu3qiPOKyH6O06CoBQJ96OevNn0f1PbcjfOG76yVoMRBkrisD8vhF1Pgjh0OUHqsrjXc1rP15C2uhLw3aHKcuWDKb0cqvlsGqBBCDSxhLO6SHUOonqiPafCxh7EoBOlQ9C5pJiwRtOzY(giiLNx9b9rFgEoOnAji8F65gKvbYAEoSliLj1i5GIJtRtOzI6Eza46y(VUVQZHJ6i2ksadO1Oje4421XCDuw2uhR6Ggi5zvx215SzJNZg6IAp3enEyqKSVbYQqIgSqV6dIY6ZWZbTrlbH)tp3GSkqwZZHDbPmPgjhuCCADcntu3ldaxhZ)19vDoCuhXwrcyaTgnHah3UoMRJYYgpNn0f1Eo3hzNzTDEIwAy1R(GC2(m8CqB0sq4)0ZniRcK18C0V5msGb1saJttezaXNBDoCuh9BoJeyqTeW40ergqAGETcKiwTb11LDDuWgpNn0f1EoLhKEnn61I0ergGx9b9b8z45SHUO2ZrwxxjK2oHDTb45G2OLGW)Px9br58z45G2OLGW)PNBqwfiR55OFZzuUtGwIqIiwTb11LDDo3ZzdDrTNlyerkyaBNiag1wpaV6dIc24ZWZbTrlbH)tp3GSkqwZZbnqYZQUSR7JSPow15uDdeskqb3rgqlavT4Z1ZzdDrTNlecrKSsOzs(gRijiGfI9Qx9CcyApP6ZWhef(m8CqB0sq4)0ZniRcK18CovhwbtQ8ar0KspNn0f1EoQ3b1E1h0x(m8C2qxu75WkysLNNdAJwcc)NE1hKZ9z45G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(aph0ajpRibYHUoMQZfTyudIeTeabUo2UoNDDuIQJV6(Qo2UoSliLjEgwH6y3ZXWiP2cbph0ajpRebYHonqH0BdcV6dkW(m8CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNd7cszsnsoO4406eAMOUxgaUUSR7lphdJKAle8C4TZLqsnsoOE1h0h9z45G2OLGW)PNBqwfiR55WkysLhiIeu(d8C2qxu75gMuMSHUOojxS65KlwtTfcEoScMu5bcV6dIY6ZWZbTrlbH)tp3GSkqwZZXxDovNAsO1yOHvGKmm2W4TJqB0squNdh1jqAm3ieKcrDhuVDEDS75SHUO2ZnmPmzdDrDsUy1ZjxSMAle8Cdb2R(GC2(m8CqB0sq4)0ZzdDrTNByszYg6I6KCXQNtUyn1wi45ei1R(G(a(m8CqB0sq4)0ZzdDrTNByszYg6I6KCXQNtUyn1wi45elbgQx9br58z45G2OLGW)PNBqwfiR55Ggi5zffWChRwhZ)1rXhRJP6yyK1OLqeAGKNvIa5qNgOq6TbHNZg6IApNrgwdjfriqRE1hefSXNHNZg6IApNrgwdj3NedEoOnAji8F6vFquqHpdpNn0f1Eo5MZtXjkpprEi0QNdAJwcc)NE1REoxcmqH0M6ZWhef(m8C2qxu75mxxzwjx0IrTNdAJwcc)NE1h0x(m8C2qxu75Cr6IAph0gTee(p9QpiN7ZWZbTrlbH)tpNn0f1EUqJqnistejjat555gKvbYAEoITIeWaAnAcboUDDmxhfF0Z5sGbkK20eggOwG9CF0R(GcSpdpNn0f1EoScMu555G2OLGW)Px9b9rFgEoOnAji8F65Ale8C23yEgXWPjQ1eAMCrbdepNn0f1Eo7BmpJy40e1AcntUOGbIx9QNtSeyO(m8brHpdph0gTee(p9CdYQaznp3afsJsUOTvCDm)xxGRJP6utcTgfa4cKewjMA5qyeAJwcI6yvhF1ja63CgzaTau1Ip36C4Oobq)MZOIcyhjAPjG4ZTohoQdAGKNvuaZDSADz)xhF1bndOrHjxesMeWChRwhZFW1XxDF9X6yQoggznAjeHgi5zLiqo0PbkKEBquh71XEDoCuNt1XWiRrlHiE7CjKuJKdADSxhR64RoNQtnj0AecaBD(BBtHi0gTee15WrDdeskqb3riaS15VTnfIei02gxhZ19vDS75SHUO2ZbndOrHE1h0x(m8CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNBGcPrjx02kokG5owToMRJI6C4OoObsEwrbm3XQ1L9FDF9X6yQoggznAjeHgi5zLiqo0PbkKEBquNdh15uDmmYA0siI3oxcj1i5G65yyKuBHGN7HH0CLsG4vFqo3NHNdAJwcc)NEUbzvGSMNJHrwJwcXhgsZvkbsDSQZ(giRcryWdTDEIwAcahH2OLGOow1HDbPmPgjhuCCADcntu3ldaxhZ)19LNZg6IAp306eAMOUxga2R(GcSpdph0gTee(p9CdYQaznphdJSgTeIpmKMRucK6yvhF1r)MZiVviGorlnbGJy1guxhZ)1rbLRohoQJV6CQoxYIiRMvIGutxuxhR6WUGuMuJKdkooToHMjQ7LbGRJ5)6cCDmvhF1zFdKvHOa9OLqsGWqKyn11XCDFvh71XuDyfmPYderck)b1XEDS75SHUO2ZnToHMjQ7LbG9QpOp6ZWZbTrlbH)tpNn0f1EUP1j0mrDVmaSNBqwfiR55yyK1OLq8HH0CLsGuhR6WUGuMuJKdkooToHMjQ7LbGRJ5)6CUNBK1qcj1i5GI9brHx9brz9z45G2OLGW)PNBqwfiR55yyK1OLq8HH0CLsGuhR64Ro63CgPLBlWRaIp36C4OoNQtnj0AKb0OWe5H5fH2OLGOow15uD23azvikqpAjKeimeH2OLGOo29C2qxu75OLBlWRa8QpiNTpdph0gTee(p9C2qxu75cF6knf8CdYQaznphdJSgTeIpmKMRucK6yvh2fKYKAKCqXXP1j0mrDVmaCD)19LNBK1qcj1i5GI9brHx9b9b8z45G2OLGW)PNBqwfiR55yyK1OLq8HH0CLsG45SHUO2Zf(0vAk4vV65gcSpdFqu4ZWZbTrlbH)tp3GSkqwZZ5uDyfmPYdertkRJvDHgwbsYWydJ3orGqBBCD)1XM6yvhF1nqiPafChzaTau1Iei02gxx2FW1nqiPafChvua7irlnbejqOTnUo2Rl76OGn1XuDuWM6y76ak)366cIOH5XWAaNi23isAGiMSow15uDcG(nNrgqlavT4ZTow15uDcG(nNrffWos0staXNRNRTqWZzFJ5zedNMOwtOzYffmq8C2qxu75SVX8mIHttuRj0m5IcgiE1h0x(m8CqB0sq4)0ZniRcK18CovhwbtQ8ar0KY6yvNaPrYZvFeiQ7G6TZRJvDHgwbsYWydJ3orGqBBCD)1XgpNn0f1EUHjLjBOlQtYfREo5I1uBHGNdWyOha2R(GCUpdph0gTee(p9C2qxu75cnc1GinrKKamLNNBqwfiR55i2ksadO1Oje44ZTow1XxDQrYbnQBiKuusSqDzx3afsJsUOTvCuaZDSADSDDue)yDoCu3afsJsUOTvCuaZDSADm)x3WnfAbKWUqlQJDp3iRHesQrYbf7dIcV6dkW(m8CqB0sq4)0ZniRcK18CeBfjGb0A0ecCC76yUoNZM6O06i2ksadO1Oje4O4rmDrDDSQBGcPrjx02kokG5owToM)RB4McTasyxOfEoBOlQ9CHgHAqKMissaMYZR(G(Opdph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45CQo1KqRr8JwbY8LdrOnAjiQZHJ6CQo7BGSkeX8iONaej8BordtxuhH2OLGOohoQtG0yUriifIUHpPUUYfi1XCDuuhR64RoSliLj1i5GIJtRtOzI6Eza46YUokBDoCuNt1nqiPafChzy9I5fFU1XUNJHrsTfcEogqlavTe(rRaz(YH0a1Ivxu7vFquwFgEoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5uDQjHwJ9MZtXQjPgirOnAjiQZHJ6CQo1KqRriaS15VTnfIqB0squNdh1nqiPafChHaWwN)22uisGqBBCDzx3hRJsR7R6y76utcTgfa4cKewjMA5qyeAJwccphdJKAle8CmGwaQAPEZ5Py1KudK0a1Ivxu7vFqoBFgEoOnAji8F65qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5uDaL)BDDbr0(gZZigonrTMqZKlkyGuNdh1zFdKvHiMhb9eGiHFZjAy6I6i0gTee15WrDcG(nNrI9nIKgiIjtcG(nNrbk4UohoQBGqsbk4oAyEmSgWjI9nIKgiIjJei02gxx21rbBQJvD8v3aHKcuWDurbSJeT0eqKaH2246YUokQZHJ6ea9BoJkkGDKOLMaIp36y3ZXWiP2cbphdOfGQwAIAnnqTy1f1E1h0hWNHNdAJwcc)NEUbzvGSMNZP6WkysLhiIeu(dQJvDcKgjpx9rGOUdQ3oVow15uDcG(nNrgqlavT4ZTow1XWiRrlHidOfGQwc)OvGmF5qAGAXQlQRJvDmmYA0siYaAbOQL6nNNIvtsnqsdulwDrDDSQJHrwJwcrgqlavT0e1AAGAXQlQ9C2qxu75yaTau18QpikNpdph0gTee(p9CdYQaznpNAsO1iea26832McrOnAjiQJvD8vNAsO1yV58uSAsQbseAJwcI6C4Oo1KqRr8JwbY8LdrOnAjiQJvDmmYA0siI3oxcj1i5Gwh71XQUbkKgLCrBR46y(VUHBk0ciHDHwuhR6giKuGcUJqayRZFBBkejqOTnUUSRJI6yvhF15uDQjHwJ4hTcK5lhIqB0squNdh15uD23azviI5rqpbis43CIgMUOocTrlbrDoCuNaPXCJqqkeDdFsDDLlqQl7)6OOo29C2qxu75yy9I55vFquWgFgEoOnAji8F65gKvbYAEo1KqRXEZ5Py1KudKi0gTee1XQoNQtnj0AecaBD(BBtHi0gTee1XQUbkKgLCrBR46y(VUHBk0ciHDHwuhR6ea9BoJmGwaQAXNRNZg6IAphdRxmpV6dIck8z45G2OLGW)PNd565WG65SHUO2ZXWiRrlbphdt(apN9nqwfIyEe0taIe(nNOHPlQJqB0squhR64RUg1jmor)MtqKuJKdkUoM)RJI6C4OoSliLj1i5GIJtRtOzI6Eza46(RZ51XEDSQJV6W4e9BobrsnsoO4KrJyajxRfq4oQ7Vo2uNdh1HDbPmPgjhuCCADcntu3ldaxhZ)1rzRJDphdJKAle8CyCIH1lMxAGAXQlQ9Qpik(YNHNdAJwcc)NEoiaLyjle9A1Zf4p65MisQHauFqu45SHUO2Z5IqYebWOhzaE1hefo3NHNdAJwcc)NEUbzvGSMNtnj0Ae)OvGmF5qeAJwcI6yvNt1HvWKkpqejO8huhR6giKuGcUJ5gHGui(CRJvD8vhdJSgTeIyCIH1lMxAGAXQlQRZHJ6CQo7BGSkeX8iONaej8BordtxuhH2OLGOow1jqAm3ieKcrcmjaMNrlH6yVow1nqH0OKlABfhfWChRwhZ)1XxD8vhf1XuDFvhBxN9nqwfIyEe0taIe(nNOHPlQJqB0squh71X21HDbPmPgjhuCCADcntu3ldaxh71X8hCDbUow1rSvKagqRrtiWXTRJ56O4lpNn0f1EogwVyEE1hefb2NHNdAJwcc)NEUbzvGSMNtnj0Am0WkqsggBy82rOnAjiQJvDovhwbtQ8ar0KY6yvxOHvGKmm2W4Ttei02gxx2)1XM6yvNt1jqAK8C1hbIeysampJwc1XQobsJ5gHGuisGqBBCDmxNZRJvDcG(nNrgqlavT4ZTow1XxDovNAsO1OIcyhjAPjGi0gTee15WrDcG(nNrffWos0staXNBDSxhR64RoNQdWyOhqKwIqIeAMuEqcAimRyOr5brQZHJ6ea9BoJ0sesKqZKYdsqdHzfFU1XUNZg6IAphdRxmpV6dIIp6ZWZbTrlbH)tp3GSkqwZZ5uDyfmPYdertkRJvD23azviI5rqpbis43CIgMUOocTrlbrDSQtG0yUriifIeysampJwc1XQobsJ5gHGui6g(K66kxGux2)1rrDSQBGcPrjx02kokG5owToM)RJcpNn0f1EomptGcoeKcV6dIckRpdph0gTee(p9CdYQaznpNaPrYZvFeisGqBBCDmxxGRJP6cCDSDDd3uOfqc7cTOow15uDcKgZncbPqKatcG5z0sWZzdDrTNdcaBD(BBtbV6dIcNTpdph0gTee(p9CdYQaznpNaPrYZvFeiQ7G6TZRJvD8vNt1bu(V11fer7BmpJy40e1AcntUOGbsDoCu3aHKcuWDKb0cqvlsGqBBCDmxhfSPo29C2qxu75uua7irlnb4vFqu8b8z45G2OLGW)PNBqwfiR55OFZzKwIqc5dRrcydTohoQta0V5mYaAbOQfFUEoBOlQ9CUiDrTx9brbLZNHNdAJwcc)NEUbzvGSMNta0V5mYaAbOQfFUEoBOlQ9C0sesKMpswE1h0xSXNHNdAJwcc)NEUbzvGSMNta0V5mYaAbOQfFUEoBOlQ9C0abdeQ3o3R(G(IcFgEoOnAji8F65gKvbYAEobq)MZidOfGQw8565SHUO2ZnxcqlriHx9b91x(m8CqB0sq4)0ZniRcK18CcG(nNrgqlavT4Z1ZzdDrTNZ6bGvIjtdtk9QpOVCUpdph0gTee(p9CdYQaznp3aHKcuWDKb0cqvlsGqBBCDmxxG)ONRTqWZLBsyysjqWjAeQ9C2qxu75YnjmmPei4enc1E1h0xb2NHNdAJwcc)NEUbzvGSMNta0V5msSVrK0armzsa0V5mkqb315WrDcG(nNrgqlavTibcTTX1XCDuWM6O06cCDSDDaL)BDDbr0(gZZigonrTMqZKlkyGuNdh1Pgjh0OUHqsrjXc1LDDFXgpxBHGNZW8yynGte7Bejnqet65SHUO2ZzyEmSgWjI9nIKgiIj9QpOV(Opdph0gTee(p9C2qxu75gznKiLG6DKOLgw9CdYQaznpxOHvGKmm2W4Ttei02gx3FDSPow15uDcG(nNrgqlavT4ZTow15uDcG(nNrffWos0staXNBDSQJ(nNXqierYkHMj5BSIKGawiokqb31XQoObsEw1LDDFa2uhR6einsEU6JarceABJRJ56cSNdMtyOP2cbp3iRHePeuVJeT0WQx9b9fL1NHNdAJwcc)NEUbzvGSMNta0V5mYaAbOQfFUEU2cbpN8rOgi4024vSOhoLVt1ZzdDrTNt(iudeCAB8kw0dNY3P6vFqF5S9z45G2OLGW)PNBqwfiR55ea9BoJmGwaQAXNRNRTqWZjFyLGE4uoskGo5kFHwo45SHUO2ZjFyLGE4uoskGo5kFHwo4vFqF9b8z45G2OLGW)PNZg6IApxU0eRPicofcctkxu75gKvbYAEobq)MZidOfGQw8565G5egAQTqWZLlnXAkIGtHGWKYf1E1h0xuoFgEoOnAji8F65SHUO2ZLlnXAkIGt0Mih8CdYQaznpNaOFZzKb0cqvl(C9CWCcdn1wi45YLMynfrWjAtKdE1hKZzJpdpNn0f1EUhgsRcHyph0gTee(p9Qx9CcK6ZWhef(m8CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNZLSiYQzLii10f11XQoSliLj1i5GIJtRtOzI6Eza46yUoNxhR64RobsJ5gHGuisGqBBCDzx3aHKcuWDm3ieKcrXJy6I66C4Oox0Irnis0sae46yUUpwh7Eoggj1wi45WuVUPrwdjKYncbPGx9b9Lpdph0gTee(p9CixphgupNn0f1EoggznAj45yyYh45CjlISAwjcsnDrDDSQd7cszsnsoO4406eAMOUxgaUoMRZ51XQo(Qta0V5mQOa2rIwAci(CRZHJ64Rox0Irnis0sae46yUUpwhR6CQo7BGSkeXdO1eAMOLiKicTrlbrDSxh7Eoggj1wi45WuVUPrwdjKipx9raV6dY5(m8CqB0sq4)0ZHC9Cyq9C2qxu75yyK1OLGNJHjFGNta0V5mYaAbOQfFU1XQo(Qta0V5mQOa2rIwAci(CRZHJ6cnScKKHXggVDIaH2246yUo2uh71XQobsJKNR(iqKaH2246yUUV8CmmsQTqWZHPEDtKNR(iGx9bfyFgEoOnAji8F65gKvbYAEo1KqRriaS15VTnfIqB0squhR64Ro(QBGcPrjx02kUoM)RB4McTasyxOf1XQUbcjfOG7iea26832McrceABJRl76OOo2RZHJ64RoNQt3b1BNxhR64RoDdH6yUokytDoCu3afsJsUOTvCDm)x3x1XEDSxh7EoBOlQ9CKNR(iGx9b9rFgEoOnAji8F65MisQHauFqu45SHUO2Z5IqYebWOhzaE1heL1NHNdAJwcc)NEUbzvGSMNJV6CQo1KqRr8JwbY8LdrOnAjiQZHJ6CQo(QBGqsbk4oYW6fZl(CRJvDdeskqb3rgqlavTibcTTX1L9FDbUo2RJ96yv3afsJsUOTvCuaZDSADm)xhf1XuDoVo2Uo(QZ(giRcrmpc6jarc)Mt0W0f1rOnAjiQJvDdeskqb3rgwVyEXNBDSxhR6iWKayEgTeQJvD8vNB4tQRRCbsDz)xhf15WrDei02gxx2)1P7G6KUHqDSQd7cszsnsoO4406eAMOUxgaUoM)RZ51XuD23azviI5rqpbis43CIgMUOocTrlbrDSxhR64RoNQdcaBD(BBtbrDoCuhbcTTX1L9FD6oOoPBiuhBx3x1XQoSliLj1i5GIJtRtOzI6Eza46y(VoNxht1zFdKvHiMhb9eGiHFZjAy6I6i0gTee1XEDSQZP6W4e9BobrDSQJV6uJKdAu3qiPOKyH6O06iqOTnUo2RJ56cCDSQJV6cnScKKHXggVDIaH2246(RJn15WrDovNUdQ3oVow1zFdKvHiMhb9eGiHFZjAy6I6i0gTee1XUNZg6IApxUriif8QpiNTpdph0gTee(p9Ctej1qaQpik8C2qxu75CrizIay0JmaV6d6d4ZWZbTrlbH)tpNn0f1EUCJqqk45gKvbYAEoNQJHrwJwcrm1RBAK1qcPCJqqkuhR64RoNQtnj0Ae)OvGmF5qeAJwcI6C4OoNQJV6giKuGcUJmSEX8Ip36yv3aHKcuWDKb0cqvlsGqBBCDz)xxGRJ96yVow1nqH0OKlABfhfWChRwhZ)1rrDmvNZRJTRJV6SVbYQqeZJGEcqKWV5enmDrDeAJwcI6yv3aHKcuWDKH1lMx85wh71XQocmjaMNrlH6yvhF15g(K66kxGux2)1rrDoCuhbcTTX1L9FD6oOoPBiuhR6WUGuMuJKdkooToHMjQ7LbGRJ5)6CEDmvN9nqwfIyEe0taIe(nNOHPlQJqB0squh71XQo(QZP6GaWwN)22uquNdh1rGqBBCDz)xNUdQt6gc1X219vDSQd7cszsnsoO4406eAMOUxgaUoM)RZ51XuD23azviI5rqpbis43CIgMUOocTrlbrDSxhR6CQomor)MtquhR64Ro1i5Gg1neskkjwOokToceABJRJ96yUok(Qow1XxDHgwbsYWydJ3orGqBBCD)1XM6C4OoNQt3b1BNxhR6SVbYQqeZJGEcqKWV5enmDrDeAJwcI6y3ZnYAiHKAKCqX(GOWR(GOC(m8CqB0sq4)0ZniRcK18CyxqktQrYbfxhZ)19vDSQJaH2246YUUVQJP64RoSliLj1i5GIRJ5)6(yDSxhR6gOqAuYfTTIRJ5)6cSNZg6IAp3GSHyuNui0fWQx9brbB8z45G2OLGW)PNBqwfiR55CQoggznAjeXuVUjYZvFeOow1nqH0OKlABfxhZ)1f46yvhbMeaZZOLqDSQJV6CdFsDDLlqQl7)6OOohoQJaH2246Y(VoDhuN0neQJvDyxqktQrYbfhNwNqZe19YaW1X8FDoVoMQZ(giRcrmpc6jarc)Mt0W0f1rOnAjiQJ96yvhF15uDqayRZFBBkiQZHJ6iqOTnUUS)Rt3b1jDdH6y76(Qow1HDbPmPgjhuCCADcntu3ldaxhZ)1586yQo7BGSkeX8iONaej8BordtxuhH2OLGOo2RJvDQrYbnQBiKuusSqDuADei02gxhZ1fypNn0f1EoYZvFeWR(GOGcFgEoOnAji8F65SHUO2ZrEU6JaEUbzvGSMNZP6yyK1OLqet96MgznKqI8C1hbQJvDovhdJSgTeIyQx3e55QpcuhR6gOqAuYfTTIRJ5)6cCDSQJatcG5z0sOow1XxDUHpPUUYfi1L9FDuuNdh1rGqBBCDz)xNUdQt6gc1XQoSliLj1i5GIJtRtOzI6Eza46y(VoNxht1zFdKvHiMhb9eGiHFZjAy6I6i0gTee1XEDSQJV6CQoiaS15VTnfe15WrDei02gxx2)1P7G6KUHqDSDDFvhR6WUGuMuJKdkooToHMjQ7LbGRJ5)6CEDmvN9nqwfIyEe0taIe(nNOHPlQJqB0squh71XQo1i5Gg1neskkjwOokToceABJRJ56cSNBK1qcj1i5GI9brHx9Qx9CmacErTpOVydfuo28bOGnEUGnsVDo2Z5Se6IikiQZzxNn0f11jxSIJfvEoSlm8b91hPCEoxcAUsWZfO6OKySHXBB6I66OmO8huufO64PQlMTKzM5RY7rhhOWmXB4tA6I6bXMAM4nCKzrvGQliediKgi1rbf8x3xSHckxrvrvGQJTYZ6CaZwkQcuDuADusHae19bTdQRtr1jGP9KAD2qxuxNCXASOkq1rP1rzGqedOo1i5GM2zSOkq1rP1rjfcquhLxmuNZIcH464d9u8kG6qZ6WkysLh7XIQIQavNZiay8uquhnmreOUbkK206OH8TXX6OKJb4Q46AutP8ms48jRZg6IACDOwMvSOkq1zdDrno6sGbkK20)P0WuxufO6SHUOghDjWafsBkt)zAV8qOvtxuxufO6SHUOghDjWafsBkt)zorirrvGQJRnxmpKwhXwrD0V5ee1HvtX1rdtebQBGcPnToAiFBCDwlQZLauQls1TZRBX1jqnelQcuD2qxuJJUeyGcPnLP)mXT5I5H0ewnfxuzdDrno6sGbkK2uM(Z0CDLzLCrlg1fv2qxuJJUeyGcPnLP)mDr6I6IkBOlQXrxcmqH0MY0FMHgHAqKMissaMYJFxcmqH0MMWWa1c8)h5FN)eBfjGb0A0ecCCBMP4Jfv2qxuJJUeyGcPnLP)mXkysLxrLn0f14OlbgOqAtz6pZhgsRcH83wi8BFJ5zedNMOwtOzYffmqkQkQcuDoJaGXtbrDadGKvD6gc1P8G6SHIi1T46mg2knAjelQcuDugaRGjvE1TZ6Cry8slH64Rr1X4jBGy0sOoOHWfW1TDDduiTPSxuzdDrn(N6Dqn)783jScMu5bIOjLfv2qxuJz6ptScMu5vuzdDrnMP)mzyK1OLa)Tfc)qdK8Sseih60afsVni4NHjFWp0ajpRibYHMjx0Irnis0saey22ztjIVVyBSliLjEgwb2lQSHUOgZ0FMmmYA0sG)2cHF825siPgjhu(zyYh8JDbPmPgjhuCCADcntu3ldaN9xfv2qxuJz6pZHjLjBOlQtYfR83wi8JvWKkpqW)o)XkysLhiIeu(dkQSHUOgZ0FMdtkt2qxuNKlw5VTq4FiW8VZF(Csnj0Am0WkqsggBy82rOnAjiC4qG0yUriifI6oOE7C2lQSHUOgZ0FMdtkt2qxuNKlw5VTq4xG0IkBOlQXm9N5WKYKn0f1j5Iv(Ble(flbgArLn0f1yM(Z0idRHKIieOv(35p0ajpROaM7yvM)P4JmXWiRrlHi0ajpRebYHonqH0BdIIkBOlQXm9NPrgwdj3Nedfv2qxuJz6pt5MZtXjkpprEi0ArvrvGQJTIqsbk4gxuzdDrnooe4)hgsRcH83wi8BFJ5zedNMOwtOzYffmq4FN)oHvWKkpqenPKvOHvGKmm2W4Ttei02g)Zgw8nqiPafChzaTau1Iei02gN9h8aHKcuWDurbSJeT0eqKaH22y2ZMc2WefSHTbk)366cIOH5XWAaNi23isAGiMKLtcG(nNrgqlavT4ZLLtcG(nNrffWos0staXNBrLn0f144qGz6pZHjLjBOlQtYfR83wi8dym0daZ)o)DcRGjvEGiAsjlbsJKNR(iqu3b1BNZk0WkqsggBy82jceABJ)ztrvGQZzzwNje46mcu3ZL)6W96c1P8G6qnuxWRYRojkyaR1LrgF4yDuEXqDbZd66ezTDEDtdRaPoLN11Xw)q1jG5owToePUGxLh6P1zDw1Xw)qXIkBOlQXXHaZ0FMHgHAqKMissaMYJ)rwdjKuJKdk(Nc(35pXwrcyaTgnHahFUS4tnsoOrDdHKIsIfYEGcPrjx02kokG5owLTPi(rhogOqAuYfTTIJcyUJvz(F4McTasyxOfSxufO6CwM11O6mHaxxWRuwNyH6cEvEBxNYdQRHa06CoBW8x3dd15So)W1H66OryCDbVkp0tRZ6SQJT(HIfv2qxuJJdbMP)mdnc1GinrKKamLh)78NyRibmGwJMqGJBZSZzdLsSvKagqRrtiWrXJy6IAwduink5I2wXrbm3XQm)pCtHwajSl0IIQavhLa0cqvRojkFhMSUbQfRUO2K46OnmiQd11nEec0ADyxyuuzdDrnooeyM(ZKHrwJwc83wi8ZaAbOQLWpAfiZxoKgOwS6IA(zyYh87KAsO1i(rRaz(YHi0gTeeoC4K9nqwfIyEe0taIe(nNOHPlQJqB0sq4WHaPXCJqqkeDdFsDDLlqyMcw8HDbPmPgjhuCCADcntu3ldaNnL1HdNgiKuGcUJmSEX8Ipx2lQSHUOghhcmt)zYWiRrlb(Ble(zaTau1s9MZtXQjPgiPbQfRUOMFgM8b)oPMeAn2BopfRMKAGeH2OLGWHdNutcTgHaWwN)22uicTrlbHdhdeskqb3riaS15VTnfIei02gN9hP0VyB1KqRrbaUajHvIPwoegH2OLGOOYg6IACCiWm9NjdJSgTe4VTq4NHrwJwc83wi8ZaAbOQLMOwtdulwDrn)mm5d(DcO8FRRliI23yEgXWPjQ1eAMCrbdehoSVbYQqeZJGEcqKWV5enmDrDeAJwcchoea9BoJe7BejnqetMea9BoJcuWTdhdeskqb3rdZJH1aorSVrK0armzKaH224SPGnS4BGqsbk4oQOa2rIwAcisGqBBC2u4WHaOFZzurbSJeT0eq85YErLn0f144qGz6ptgqlavn(35VtyfmPYderck)bSeinsEU6JarDhuVDolNea9BoJmGwaQAXNllggznAjezaTau1s4hTcK5lhsdulwDrnlggznAjezaTau1s9MZtXQjPgiPbQfRUOMfdJSgTeImGwaQAPjQ10a1IvxuxufO6OeSEX8Ql4v5vNZiaCEDmvhFbT58uSAsQbc)1Hi1X9OvGmF5qDOwMvDOUokYGD2sDoRwaB4lSo26hQoRf15mcaNxhbmrw1nrK6AiaToNj26hUOYg6IACCiWm9NjdRxmp(35VAsO1iea26832McrOnAjiyXNAsO1yV58uSAsQbseAJwcchoutcTgXpAfiZxoeH2OLGGfdJSgTeI4TZLqsnsoOSZAGcPrjx02kM5)HBk0ciHDHwWAGqsbk4ocbGTo)TTPqKaH224SPGfFoPMeAnIF0kqMVCicTrlbHdhozFdKvHiMhb9eGiHFZjAy6I6i0gTeeoCiqAm3ieKcr3WNuxx5cKS)PG9IQavhLG1lMxDbVkV6cAZ5Py1KudK6yQUGq15mcaNZwQZz1cydFH1Xw)q1zTOokbOfGQwDp3IkBOlQXXHaZ0FMmSEX84FN)QjHwJ9MZtXQjPgirOnAjiy5KAsO1iea26832McrOnAjiynqH0OKlABfZ8)WnfAbKWUqlyja63CgzaTau1Ip3IQavhha1nFszDduyi0ADOUoEQ6IzlzMz(Q8E0XbkmtkJXaAEiPqP0myRzszq5piZGxQ3mPKySHXBB6IAkLs(HCMrPugadgzWlwuzdDrnooeyM(ZKHrwJwc83wi8JXjgwVyEPbQfRUOMFgM8b)23azviI5rqpbis43CIgMUOocTrlbbl(AuNW4e9BobrsnsoOyM)PWHdSliLj1i5GIJtRtOzI6Eza4FNZol(W4e9BobrsnsoO4KrJyajxRfq4o(zJdhyxqktQrYbfhNwNqZe19YaWm)tzzVOYg6IACCiWm9NPlcjteaJEKbW)ersneG(tb)qakXswi616FG)yrLn0f144qGz6ptgwVyE8VZF1KqRr8JwbY8LdrOnAjiy5ewbtQ8arKGYFaRbcjfOG7yUriifIpxw8XWiRrlHigNyy9I5LgOwS6IAhoCY(giRcrmpc6jarc)Mt0W0f1rOnAjiyjqAm3ieKcrcmjaMNrlb2znqH0OKlABfhfWChRY8pF8rbtFX223azviI5rqpbis43CIgMUOocTrlbb7Sn2fKYKAKCqXXP1j0mrDVmam7m)bhyweBfjGb0A0ecCCBMP4RIQavhLG1lMxDbVkV6CwnScK6OKySH3MTuxqO6WkysLxDwlQRr1zdDza15SsjRJ(nN8xhL55QpcuxJ062UocmjaMxDeRZb(Rt8iBNxhLa0cqvJPm(K)6epY2519PeHe1bym0Fx3oRZyyR0OLqSOYg6IACCiWm9NjdRxmp(35VAsO1yOHvGKmm2W4TJqB0sqWYjScMu5bIOjLScnScKKHXggVDIaH224S)zdlNeinsEU6JarcmjaMNrlbwcKgZncbPqKaH22yMDolbq)MZidOfGQw85YIpNutcTgvua7irlnbeH2OLGWHdbq)MZOIcyhjAPjG4ZLDw85eGXqpGiTeHej0mP8Ge0qywXqJYdI4WHaOFZzKwIqIeAMuEqcAimR4ZL9IQavhhptGcoeKI6MisDC8iONae1X9Mt0W0f1fv2qxuJJdbMP)mX8mbk4qqk4FN)oHvWKkpqenPKL9nqwfIyEe0taIe(nNOHPlQJqB0sqWsG0yUriifIeysampJwcSeinMBecsHOB4tQRRCbs2)uWAGcPrjx02kokG5owL5FkkQcuDoJaWwN)22uOUG5bDD0iLxDuMNR(iqDwlQZzYieKc1zeOUNBDtePojQZRdA0lNxrLn0f144qGz6ptiaS15VTnf4FN)cKgjpx9rGibcTTXmhyMcmBpCtHwajSl0cwojqAm3ieKcrcmjaMNrlHIkBOlQXXHaZ0FMkkGDKOLMa4FN)cKgjpx9rGOUdQ3oNfFobu(V11fer7BmpJy40e1AcntUOGbIdhdeskqb3rgqlavTibcTTXmtbByVOYg6IACCiWm9NPlsxuZ)o)PFZzKwIqc5dRrcyd1Hdbq)MZidOfGQw85wuzdDrnooeyM(ZKwIqI08rYI)D(la63CgzaTau1Ip3IkBOlQXXHaZ0FM0abdeQ3oN)D(la63CgzaTau1Ip3IkBOlQXXHaZ0FMZLa0sesW)o)fa9BoJmGwaQAXNBrLn0f144qGz6ptRhawjMmnmPK)D(la63CgzaTau1Ip3IkBOlQXXHaZ0FMpmKwfc5VTq4p3KWWKsGGt0iuZ)o)hiKuGcUJmGwaQArceABJzoWFSOYg6IACCiWm9N5ddPvHq(Ble(nmpgwd4eX(grsdeXK8VZFbq)MZiX(grsdeXKjbq)MZOafC7WHaOFZzKb0cqvlsGqBBmZuWgknWSnq5)wxxqeTVX8mIHttuRj0m5IcgioCOgjh0OUHqsrjXcz)fBkQSHUOghhcmt)z(WqAviKFyoHHMAle(hznKiLG6DKOLgw5FN)HgwbsYWydJ3orGqBB8pBy5KaOFZzKb0cqvl(Cz5KaOFZzurbSJeT0eq85YI(nNXqierYkHMj5BSIKGawiokqb3SGgi5zL9hGnSeinsEU6JarceABJzoWfv2qxuJJdbMP)mFyiTkeYFBHWV8rOgi4024vSOhoLVtL)D(la63CgzaTau1Ip3IkBOlQXXHaZ0FMpmKwfc5VTq4x(Wkb9WPCKuaDYv(cTCG)D(la63CgzaTau1Ip3IkBOlQXXHaZ0FMpmKwfc5hMtyOP2cH)CPjwtreCkeeMuUOM)D(la63CgzaTau1Ip3IkBOlQXXHaZ0FMpmKwfc5hMtyOP2cH)CPjwtreCI2e5a)78xa0V5mYaAbOQfFUfvbQUpmmTNuRBAsjTnOUUjIu3dB0sOUvHqmBPokVyOoux3aHKcuWDSOYg6IACCiWm9N5ddPvHqCrvrvGQ7dVeyO1jSqlhQZOx5QlGlQcuDoJMb0OW6mTUaZuD89rMQl4v5v3hMJ96yRFOyDolHHGynfKzvhQR7lMQtnsoOy(Rl4v5vhLa0cqvJ)6qK6cEvE1LXNuIVoKYdibVyOUGTvRBIi1HrHqDqdK8SI1rjLyuDbBRw3oRZzeaoVUbkKgv3IRBGc3oVUNBSOYg6IACuSeyO)qZaAui)78FGcPrjx02kM5)aZKAsO1OaaxGKWkXulhcJqB0sqWIpbq)MZidOfGQw856WHaOFZzurbSJeT0eq856Wb0ajpROaM7y1S)5dAgqJctUiKmjG5owL5py((6JmXWiRrlHi0ajpRebYHonqH0Bdc2z3HdNyyK1OLqeVDUesQrYbLDw85KAsO1iea26832McrOnAjiC4yGqsbk4ocbGTo)TTPqKaH22yM)I9IkBOlQXrXsGHY0FMmmYA0sG)2cH)hgsZvkbc)mm5d(hOqAuYfTTIJcyUJvzMchoGgi5zffWChRM9)xFKjggznAjeHgi5zLiqo0PbkKEBq4WHtmmYA0siI3oxcj1i5GwufO6Oe7Q8QZzm4H2oVUpLMaW8xNZCRRdnR7dQxgaUotR7lMQtnsoO4yrLn0f14OyjWqz6pZP1j0mrDVmam)78NHrwJwcXhgsZvkbcl7BGSkeHbp025jAPjaCeAJwccwyxqktQrYbfhNwNqZe19YaWm))vrvGQZzU11HM19b1ldaxNP1rbLJP6WQnOgxhAwhL4wHa66(uAcaxhIuNLBBJ16cmt1X3hzQUGxLxDFy0Jwc19HryG96uJKdkowuzdDrnokwcmuM(ZCADcntu3ldaZ)o)zyK1OLq8HH0CLsGWIp63Cg5Tcb0jAPjaCeR2GAM)PGY5WbFo5swez1SseKA6IAwyxqktQrYbfhNwNqZe19YaWm)hyM4Z(giRcrb6rlHKaHHiXAQz(l2zcRGjvEGisq5pGD2lQcuDoZTUo0SUpOEza46uuDMRRmR6(WGjKzv3hcTyux3oRBBBOldOouxN1zvNAKCqRZ06CEDQrYbfhlQSHUOghflbgkt)zoToHMjQ7LbG5FK1qcj1i5GI)PG)D(ZWiRrlH4ddP5kLaHf2fKYKAKCqXXP1j0mrDVmamZ)oVOYg6IACuSeyOm9NjTCBbEfa)78NHrwJwcXhgsZvkbcl(OFZzKwUTaVci(CD4Wj1KqRrgqJctKhMxeAJwccwozFdKvHOa9OLqsGWqeAJwcc2lQcuDzy0uQZ6txPPqDkQoZ1vMvDFyWeYSQ7dHwmQRZ06(Qo1i5GIlQSHUOghflbgkt)zg(0vAkW)iRHesQrYbf)tb)78NHrwJwcXhgsZvkbclSliLj1i5GIJtRtOzI6Eza4)VkQSHUOghflbgkt)zg(0vAkW)o)zyK1OLq8HH0CLsGuuvufO6(WwOLd1HyaK60neQZOx5QlGlQcuDoZ2WvRZzYieKc46qDDnQPuxYgsmsw1PgjhuCDtePoLhuNlzrKvZQocsnDrDD7SUpYuD0sae46mcuNjjGjYQUNBrLn0f14OaP)mmYA0sG)2cHFm1RBAK1qcPCJqqkWpdt(GFxYIiRMvIGutxuZc7cszsnsoO4406eAMOUxgaMzNZIpbsJ5gHGuisGqBBC2deskqb3XCJqqkefpIPlQD4WfTyudIeTeabM5pYErvGQZz2gUADuMNR(iaUouxxJAk1LSHeJKvDQrYbfx3erQt5b15swez1SQJGutxux3oR7JmvhTeabUoJa1zscyISQ75wuzdDrnokqkt)zYWiRrlb(Ble(XuVUPrwdjKipx9ra(zyYh87swez1SseKA6IAwyxqktQrYbfhNwNqZe19YaWm7Cw8ja63Cgvua7irlnbeFUoCWNlAXOgejAjacmZFKLt23azviIhqRj0mrlrireAJwcc2zVOkq15mBdxTokZZvFeax3oRJsaAbOQXugOa2rDFknbKPZQHvGuhLeJnmE76wCDp36SwuxWqD8mgqDFXuDyyGAbUojm16qDDkpOokZZvFeOUpmkJIkBOlQXrbsz6ptggznAjWFBHWpM61nrEU6Ja8ZWKp4xa0V5mYaAbOQfFUS4ta0V5mQOa2rIwAci(CD4i0WkqsggBy82jceABJzMnSZsG0i55QpcejqOTnM5VkQcuDCUWynzDuMNR(iqDyqFU1nrK6CgbGZlQSHUOghfiLP)mjpx9ra(35VAsO1iea26832McrOnAjiyXhFduink5I2wXm)pCtHwajSl0cwdeskqb3riaS15VTnfIei02gNnfS7WbFoP7G6TZzXNUHaZuWghogOqAuYfTTIz()l2zN9IQavNZKriifQ75snaU8xNjXO6uYc46uuDpmu3Q1z46S6WUWynzD5qdetrK6MisDkpOoPH16yRFO6OHjIa1z1n3EX8asrLn0f14OaPm9NPlcjteaJEKbW)ersneG(trrLn0f14OaPm9NzUriif4FN)85KAsO1i(rRaz(YHi0gTeeoC4eFdeskqb3rgwVyEXNlRbcjfOG7idOfGQwKaH224S)dm7SZAGcPrjx02kokG5owL5FkyY5SnF23azviI5rqpbis43CIgMUOocTrlbbRbcjfOG7idRxmV4ZLDweysampJwcS4Zn8j11vUaj7FkC4GaH224S)1DqDs3qGf2fKYKAKCqXXP1j0mrDVmamZ)oNj7BGSkeX8iONaej8BordtxuhH2OLGGDw85eea26832McchoiqOTno7FDhuN0ney7VyHDbPmPgjhuCCADcntu3ldaZ8VZzY(giRcrmpc6jarc)Mt0W0f1rOnAjiyNLtyCI(nNGGfFQrYbnQBiKuusSaLsGqBBm7mhyw8fAyfijdJnmE7ebcTTX)SXHdN0Dq925SSVbYQqeZJGEcqKWV5enmDrDeAJwcc2lQSHUOghfiLP)mDrizIay0Jma(NisQHa0FkkQSHUOghfiLP)mZncbPa)JSgsiPgjhu8pf8VZFNyyK1OLqet96MgznKqk3ieKcS4Zj1KqRr8JwbY8LdrOnAjiC4Wj(giKuGcUJmSEX8Ipxwdeskqb3rgqlavTibcTTXz)hy2zN1afsJsUOTvCuaZDSkZ)uWKZzB(SVbYQqeZJGEcqKWV5enmDrDeAJwccwdeskqb3rgwVyEXNl7SiWKayEgTeyXNB4tQRRCbs2)u4WbbcTTXz)R7G6KUHalSliLj1i5GIJtRtOzI6EzayM)Dot23azviI5rqpbis43CIgMUOocTrlbb7S4ZjiaS15VTnfeoCqGqBBC2)6oOoPBiW2FXc7cszsnsoO4406eAMOUxgaM5FNZK9nqwfIyEe0taIe(nNOHPlQJqB0sqWolNW4e9Bobbl(uJKdAu3qiPOKybkLaH22y2zMIVyXxOHvGKmm2W4Ttei02g)ZghoCs3b1BNZY(giRcrmpc6jarc)Mt0W0f1rOnAjiyVOkq1XwjBig11Lbe6cyToulZQouxx4tQRReQtnsoO46mTUaZuDS1puDbZd66iVU3oVo0tRB76(cxhFp36uuDbUo1i5GIzVoePoNJRJVpYuDQrYbfZErLn0f14OaPm9N5GSHyuNui0fWk)78h7cszsnsoOyM))IfbcTTXz)ft8HDbPmPgjhumZ)FKDwduink5I2wXm)h4IQav3heaU19CRJY8C1hbQZ06cmt1H66mPSo1i5GIRJVG5bDDYLX251jrDEDqJE58QZArDnsRd3MlMhszVOYg6IACuGuM(ZK8C1hb4FN)oXWiRrlHiM61nrEU6JaSgOqAuYfTTIz(pWSiWKayEgTeyXNB4tQRRCbs2)u4WbbcTTXz)R7G6KUHalSliLj1i5GIJtRtOzI6EzayM)Dot23azviI5rqpbis43CIgMUOocTrlbb7S4ZjiaS15VTnfeoCqGqBBC2)6oOoPBiW2FXc7cszsnsoO4406eAMOUxgaM5FNZK9nqwfIyEe0taIe(nNOHPlQJqB0sqWol1i5Gg1neskkjwGsjqOTnM5axuzdDrnokqkt)zsEU6Ja8pYAiHKAKCqX)uW)o)DIHrwJwcrm1RBAK1qcjYZvFeGLtmmYA0siIPEDtKNR(iaRbkKgLCrBRyM)dmlcmjaMNrlbw85g(K66kxGK9pfoCqGqBBC2)6oOoPBiWc7cszsnsoO4406eAMOUxgaM5FNZK9nqwfIyEe0taIe(nNOHPlQJqB0sqWol(CccaBD(BBtbHdhei02gN9VUdQt6gcS9xSWUGuMuJKdkooToHMjQ7LbGz(35mzFdKvHiMhb9eGiHFZjAy6I6i0gTeeSZsnsoOrDdHKIsIfOuceABJzoWfvfvbQoNbgd9aWfv2qxuJJagd9aW)dupGwjMcI0uAHa)78hAGKNvu3qiPOuOfaZuWYjbq)MZidOfGQw85YIpNeinoq9aALykistPfcj6hPJ6oOE7CwozdDrDCG6b0kXuqKMsleIBNMYnNN6WX8jLjcm4zKCiPBiKD(qedTayVOkq1rjLbBzHR7HH6(uIqI6cEvE1rjaTau1Q75gRJskXO6EyOUGxLxDz8zDp36OHjIa1z1n3EX8asD8TZ6utcTcc2RZW1jrDEDgUUvRJ8ACDtePokydUoXJSDEDucqlavTyrLn0f14iGXqpamt)zslrircntkpibneMf)78xa0V5mYaAbOQfFUS4Zj1KqRrffWos0starOnAjiC4qa0V5mQOa2rIwAci(CznqH0OKlABfhfWChRM9pfoCia63CgzaTau1Iei02gN9pfSHDho0neskkjwi7FkytrvGQJsQke6Q1PO6m5M315m9mIyTUUGxLxDucqlavT6mCDsuNxNHRB16cg1uIrRJa4NuRB76Ki8251z1nFsjLYWKpOUHH16qmasDkpOoceABVDEDIhX0f11HM1P8G6MBopTOYg6IACeWyOhaMP)mZFgrSwNqZK9nqqkp(35)aHKcuWDKb0cqvlsGqBBC2o3Hdbq)MZidOfGQw856WHAKCqJ6gcjfLelKTZztrLn0f14iGXqpamt)zM)mIyToHMj7BGGuE8VZ)PeHi8XNAKCqJ6gcjfLelqPoNnStjAGqsbk4MDMNseIWhFQrYbnQBiKuusSaL6C2qPdeskqb3rgqlavTibcTTXStjAGqsbk4M9IkBOlQXraJHEayM(ZCIgpmis23azvirdwi)78h7cszsnsoO4406eAMOUxgaM5)VC4GyRibmGwJMqGJBZmLLnSGgi5zLTZMnfv2qxuJJagd9aWm9NP7JSZS2oprlnSY)o)XUGuMuJKdkooToHMjQ7LbGz()lhoi2ksadO1Oje442mtzztrLn0f14iGXqpamt)zQ8G0RPrVwKMiYa4FN)0V5msGb1saJttezaXNRdh0V5msGb1saJttezaPb61kqIy1guNnfSPOYg6IACeWyOhaMP)mjRRResBNWU2akQSHUOghbmg6bGz6pZGrePGbSDIayuB9a4FN)0V5mk3jqlrireR2G6SDErLn0f14iGXqpamt)zgcHiswj0mjFJvKeeWcX8VZFObsEwz)r2WYPbcjfOG7idOfGQw85wuvufO64uWKkpquhLCOlQXfvbQUG2CEy1Kude(RdrQJ7rRm5mcaNxhQRJImyl1X1MlMhsRJY8C1hbkQSHUOghXkysLhi(jpx9ra(35)afsJsUOTvmZ)bMfFQjHwJ9MZtXQjPgirOnAjiC4qnj0Ae)OvGmF5qeAJwccw8PMeAncbGTo)TTPqeAJwccwdeskqb3riaS15VTnfIei02gN9)xoC4KUdQ3oNDwmmYA0siI3oxcj1i5GYol1i5Gg1neskkjwGsjqOTnMzkBrvGQJ7rRaz(YH6yQooEe0taI64EZjAy6IA2sDoJg)iqDbd19WqDOgQlxIOnzDkQoZ1vMvDotgHGuOofvNYdQl02Uo1i5Gw3oRB16wCDnsRd3MlMhsRllq5VomQotkRdP8asDH221Pgjh06m6vU6c46CjO5QXIkBOlQXrScMu5bcM(Z0fHKjcGrpYa4FIiPgcq)POOYg6IACeRGjvEGGP)mZncbPa)783(giRcrmpc6jarc)Mt0W0f1rOnAjiyr)MZi(rRaz(YH4ZLf9BoJ4hTcK5lhIei02gNnfrNZYjmor)MtquufO64E0kqMVCGTuhL01vMvDisDugysamV6cEvE1r)MtquNZKriifWfv2qxuJJyfmPYdem9NPlcjteaJEKbW)ersneG(trrLn0f14iwbtQ8abt)zMBecsb(hznKqsnsoO4Fk4FN)QjHwJ4hTcK5lhIqB0sqWIpceABJZMIVC4Wn8j11vUaj7FkyNLAKCqJ6gcjfLelqPei02gZ8xfvbQoUhTcK5lhQJP644rqpbiQJ7nNOHPlQRB764YGTuhL01vMvDGrKzvhL55QpcuNYZ06cELY6OH6iWKayEGOUjIuNR1ciChfv2qxuJJyfmPYdem9Nj55QpcW)o)vtcTgXpAfiZxoeH2OLGGL9nqwfIyEe0taIe(nNOHPlQJqB0sqWYjbsJKNR(iqu3b1BNZIHrwJwcr825siPgjh0IQavh3JwbY8Ld1fCM1XXJGEcquh3BordtxuZwQJYaMRRmR6MisD0O(HRJT(HQZArMisDqak0cquhUnxmpKwN4rmDrDSOYg6IACeRGjvEGGP)mDrizIay0Jma(NisQHa0FkkQSHUOghXkysLhiy6pZCJqqkW)iRHesQrYbf)tb)78xnj0Ae)OvGmF5qeAJwccw23azviI5rqpbis43CIgMUOocTrlbbl1i5Gg1neskkjwGzceABJzXhbcTTXztXhWHdNW4e9Bobb7fvbQoUhTcK5lhQJP6CgbGZzl15myaDDigaHScOoRoCBUyEiToNjJqqkuhzZ5P1ztfi1rzEU6Ja1rdtebQZzea26832MUOUOYg6IACeRGjvEGGP)mDrizIay0Jma(NisQHa0FkkQSHUOghXkysLhiy6pZCJqqkW)o)vtcTgXpAfiZxoeH2OLGGLAsO1iea26832McrOnAjiynqiPafChHaWwN)22uisGqBBC2uWYLams5drKIi55QpcWsG0i55QpcejqOTnM5pYuGz7HBk0ciHDHw4vV69]] )

end