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


    spec:RegisterPack( "Assassination", 20200206, [[dav82bqiQipsiYLuvcAtOuFcvHinkQGtHQ0QqvuVcjzwuHUfQc2LGFjQyyQk1XqrwMQIEgvunnHOUMQsABib6BurPghvu05qcO1HQiEhQcr18ev19uvTpuu)dvHshejOwOQcpKkkmrvLOUiQI0grvi8rufQgjQcr5Kurjwjs0lvvcmtufsUjvus7ui1qvvISuKG8uuzQcjxfvHuBfjaFfvHi2lv9xrgSkhMYIrQhRWKjCzWMv0NfLrJsoTsRgvHIxJKA2eDBHA3s9BidNkDCvLqlhXZHA6KUUQSDu47IknEHW5fvz9iHMpQQ9lzpt(O8CctbF0F(9NF)9NFtbdm91Vz6RoBpNMNl45CTb1wg45Alg8Cuym2W4TnDrTNZ1YtImHpkphg9idWZXsvxmpjNCYwL1JomqX5G34N00f1dIn1CWB8ihph9BLQZs7P9CctbF0F(9NF)9NFtbdm91VzkYotpN9uwiINJBJDgEowRqaTN2Zja8WZfP6OWySHXBB6I66OqOShuugP6yPQlMNKtozRY6rhgO4CWB8tA6I6bXMAo4nEKtrzKQJhbqtEgjV6OGow3NF)53fLfLrQoNblRZampPOms1Xd1rHfcqu3xWoOUofvNaM2tQ1zdDrDDYfRHIYivhpuhfcIrmG6uJKbAANHIYivhpuhfwiarD8OXqDolkeJRZb0tXRaQdnRdRGjvw8g8CYfRyFuEoScMuzbcFu(OzYhLNdAJwcc)hEUbzvGSMNBGIPrjx02kUoM)RlY1XUohQtnj0AO3mwkwnj1ajaTrlbrD85xNAsO1a(rRaz(YGa0gTee1XUohQtnj0AaIaBD2BBtHa0gTee1XUUbcjfOC7aeb26S32McbceBBJRl))6(So(8RZP60Dq92z1XBDSRJHrwJwcb82zsiPgjd064To21Pgjd0GUXqsrjXc1Xd1rGyBBCDmxhf0ZzdDrTNJ8C1hb8Qp6p9r55G2OLGW)HNBIiPgIq9rZKNZg6IApNlcjteaJEKb4vF0o3hLNdAJwcc)hEUbzvGSMNZOiqwfcywe0taIe(nNOHPlQdqB0squh76OFZza)OvGmFzq45wh76OFZza)OvGmFzqGaX2246YVoMcoVo215uDyCI(nNGWZzdDrTNlZieKcE1hDK9r55G2OLGW)HNBIiPgIq9rZKNZg6IApNlcjteaJEKb4vF0F1hLNdAJwcc)hEoBOlQ9CzgHGuWZniRcK18CQjHwd4hTcK5ldcqB0squh76COoceBBJRl)6y6Z64ZVo34Nuxx5cK6Y)VoMQJ36yxNAKmqd6gdjfLeluhpuhbITTX1XCDF65g5nKqsnsgOyF0m5vF0uqFuEoOnAji8F45gKvbYAEo1KqRb8JwbY8LbbOnAjiQJDDgfbYQqaZIGEcqKWV5enmDrDaAJwcI6yxNt1jqAG8C1hbc6oOE7S6yxhdJSgTec4TZKqsnsgOEoBOlQ9CKNR(iGx9r7S9r55G2OLGW)HNBIiPgIq9rZKNZg6IApNlcjteaJEKb4vF0otFuEoOnAji8F45SHUO2ZLzecsbp3GSkqwZZPMeAnGF0kqMVmiaTrlbrDSRZOiqwfcywe0taIe(nNOHPlQdqB0squh76uJKbAq3yiPOKyH6yUoceBBJRJDDouhbITTX1LFDm5mRJp)6CQomor)MtquhVEUrEdjKuJKbk2hntE1hnfOpkph0gTee(p8Ctej1qeQpAM8C2qxu75CrizIay0JmaV6JMPV9r55G2OLGW)HNBqwfiR55utcTgWpAfiZxgeG2OLGOo21PMeAnarGTo7TTPqaAJwcI6yx3aHKcuUDaIaBD2BBtHabITTX1LFDmvh76CjaJu2qeykqEU6Ja1XUobsdKNR(iqGaX2246yUUVwhv1f56456gUPylIe2fAHNZg6IApxMriif8Qx9Cagd9aW(O8rZKpkph0gTee(p8CdYQaznph0ajlVGUXqsrPylI6yUoMQJDDovNaOFZzGb0cqvl8CRJDDouNt1jqAyG6b0kXuqKMslgs0psh0Dq92z1XUoNQZg6I6Wa1dOvIPGinLwme2onLBglTo(8RB(KYebgSmsgK0ngQl)6YgIqSfrD865SHUO2Znq9aALykistPfdE1h9N(O8CqB0sq4)WZniRcK18CcG(nNbgqlavTWZTo215qDovNAsO1GIIyhjAPjGa0gTee1XNFDcG(nNbffXos0staHNBDSRBGIPrjx02koiG5owTU8)RJP64ZVobq)MZadOfGQwGaX2246Y)VoM(UoERJp)60ngskkjwOU8)RJPV9C2qxu75OLiKiHMjLfKGgIZZR(ODUpkph0gTee(p8CdYQaznp3aHKcuUDGb0cqvlqGyBBCD5xNZRJp)6ea9BodmGwaQAHNBD85xNAKmqd6gdjfLelux(158V9C2qxu75YEgrSwNqZKrrGGuwE1hDK9r55G2OLGW)HNBqwfiR55MseIuNd15qDQrYanOBmKuusSqD8qDo)764TUVW6SHUOonqiPaLBxhV1XCDtjcrQZH6COo1izGg0ngskkjwOoEOoN)DD8qDdeskq52bgqlavTabITTX1XBDFH1zdDrDAGqsbk3UoE9C2qxu75YEgrSwNqZKrrGGuwE1h9x9r55G2OLGW)HNBqwfiR55WUGuMuJKbkomToHMjQ7LbGRJ5)6(So(8RJyRibmGwdMqGdBxhZ1rb)Uo21bnqYYRU8RZz)TNZg6IAp3enEyqKmkcKvHenyXE1hnf0hLNdAJwcc)hEUbzvGSMNd7cszsnsgO4W06eAMOUxgaUoM)R7Z64ZVoITIeWaAnycboSDDmxhf8BpNn0f1Eo3hzN5TDwIwAy1R(OD2(O8CqB0sq4)WZniRcK18C0V5mqGb1saJttezaHNBD85xh9BodeyqTeW40ergqAGETcKawTb11LFDm9TNZg6IApNYcsVMg9ArAIidWR(ODM(O8C2qxu75iRRResBNWU2a8CqB0sq4)WR(OPa9r55SHUO2ZLlIifmGTteaJARhGNdAJwcc)hE1hntF7JYZbTrlbH)dp3GSkqwZZbnqYYRU8R7RFxh76CQUbcjfOC7adOfGQw4565SHUO2ZfdXisEj0mjFJvKeeWIXE1hntm5JYZbTrlbH)dp3GSkqwZZPgjd0alWKkRG7qRJ56CMFxhF(1Pgjd0alWKkRG7qRl))6(8764ZVo1izGg0ngskk5o00NFxhZ158V9C2qxu75iG5UDwAkTya7vV65eW0Es1hLpAM8r55G2OLGW)HNBqwfiR55CQoScMuzbIGjLEoBOlQ9CuVdQ9Qp6p9r55SHUO2ZHvWKklph0gTee(p8QpAN7JYZbTrlbH)dphY1ZHb1ZzdDrTNJHrwJwcEogM8bEoObswEbcKbDDuvNlAXOgejAjacCD8CDo76(cRZH6(SoEUoSliLjwgwH641ZXWiP2Ibph0ajlVebYGonqX0BdcV6JoY(O8CqB0sq4)WZHC9Cyq9C2qxu75yyK1OLGNJHjFGNd7cszsnsgO4W06eAMOUxgaUU8R7tphdJKAlg8C4TZKqsnsgOE1h9x9r55G2OLGW)HNBqwfiR55WkysLficeu2d8C2qxu75gMuMSHUOojxS65KlwtTfdEoScMuzbcV6JMc6JYZbTrlbH)dp3GSkqwZZ5qDovNAsO1qSHvGKmm2W4TdqB0squhF(1jqAiZieKcbDhuVDwD865SHUO2ZnmPmzdDrDsUy1ZjxSMAlg8Cdb2R(OD2(O8CqB0sq4)WZzdDrTNByszYg6I6KCXQNtUyn1wm45ei1R(ODM(O8CqB0sq4)WZzdDrTNByszYg6I6KCXQNtUyn1wm45elbgQx9rtb6JYZbTrlbH)dp3GSkqwZZbnqYYliG5owToM)RJPVwhv1XWiRrlHa0ajlVebYGonqX0BdcpNn0f1EoJmSgskIqGw9QpAM(2hLNZg6IApNrgwdj3NedEoOnAji8F4vF0mXKpkpNn0f1Eo5MXsXjEmprwm0QNdAJwcc)hE1hntF6JYZzdDrTNJ2YsOzsj7GASNdAJwcc)hE1hnto3hLNdAJwcc)hEUbzvGSMNd(IV11febyWcTDwIbAf1XNFDWx8TUUGiadwOTZsmqRiHy55SHUO2Zjafg6IAV6vpNlbgOyAt9r5JMjFuEoBOlQ9CMRRmVKlAXO2ZbTrlbH)dV6J(tFuEoOnAji8F45SHUO2ZfBeQbrAIijbyklp3GSkqwZZrSvKagqRbtiWHTRJ56y6REoxcmqX0MMWWa1cSN7RE1hTZ9r55SHUO2ZHvWKklph0gTee(p8Qp6i7JYZbTrlbH)dpxBXGNZOiMLrmCAIAnHMjxuUaXZzdDrTNZOiMLrmCAIAnHMjxuUaXR(O)QpkpNn0f1EoxKUO2ZbTrlbH)dV6vpNyjWq9r5JMjFuEoOnAji8F45gKvbYAEUbkMgLCrBR46y(VUixhv1PMeAniaWfijSsm1YG4a0gTee1XUohQta0V5mWaAbOQfEU1XNFDcG(nNbffXos0staHNBD85xh0ajlVGaM7y16Y)VUp)ADuvhdJSgTecqdKS8seid60aftVniQJp)6CQoggznAjeWBNjHKAKmqRJ36yxNd15uDQjHwdqeyRZEBBkeG2OLGOo(8RBGqsbk3oarGTo7TTPqGaX2246yUUpRJxpNn0f1EoOzank2R(O)0hLNdAJwcc)hEoKRNddQNZg6IAphdJSgTe8Cmm5d8Cdumnk5I2wXbbm3XQ1XCDmvhF(1bnqYYliG5owTU8)R7ZVwhv1XWiRrlHa0ajlVebYGonqX0BdI64ZVoNQJHrwJwcb82zsiPgjduphdJKAlg8CpmKMRuceV6J25(O8CqB0sq4)WZniRcK18CmmYA0si8WqAUsjqQJDDgfbYQqagSqBNLOLMaWbOnAjiQJDDyxqktQrYafhMwNqZe19YaW1X8FDF65SHUO2ZnToHMjQ7LbG9Qp6i7JYZbTrlbH)dp3GSkqwZZXWiRrlHWddP5kLaPo215qD0V5mWAfcOt0sta4awTb11X8FDmrbwhF(15qDovNlzrKvZlrqQPlQRJDDyxqktQrYafhMwNqZe19YaW1X8FDrUoQQZH6mkcKvHGa9OLqsGWqGyn11XCDFwhV1rvDyfmPYcebck7b1XBD865SHUO2ZnToHMjQ7LbG9Qp6V6JYZbTrlbH)dpNn0f1EUP1j0mrDVmaSNBqwfiR55yyK1OLq4HH0CLsGuh76WUGuMuJKbkomToHMjQ7LbGRJ5)6CUNBK3qcj1izGI9rZKx9rtb9r55G2OLGW)HNBqwfiR55yyK1OLq4HH0CLsGuh76COo63CgOLBlWRacp364ZVoNQtnj0AGb0O4e5HzfG2OLGOo215uDgfbYQqqGE0sijqyiaTrlbrD865SHUO2Zrl3wGxb4vF0oBFuEoOnAji8F45SHUO2Zf)0vAk45gKvbYAEoggznAjeEyinxPei1XUoSliLj1izGIdtRtOzI6Eza46(R7tp3iVHesQrYaf7JMjV6J2z6JYZbTrlbH)dp3GSkqwZZXWiRrlHWddP5kLaXZzdDrTNl(PR0uWRE1ZneyFu(OzYhLNdAJwcc)hEoBOlQ9CgfXSmIHttuRj0m5IYfiEUbzvGSMNZP6WkysLficMuwh76InScKKHXggVDIaX2246(R776yxNd1nqiPaLBhyaTau1cei22gxx(8yRBGqsbk3oOOi2rIwAciqGyBBCD8wx(1X031rvDm9DD8CDWx8TUUGiyywmSgWjIrrejnqetwh76CQobq)MZadOfGQw45wh76CQobq)MZGIIyhjAPjGWZ1Z1wm45mkIzzedNMOwtOzYfLlq8Qp6p9r55G2OLGW)HNBqwfiR55CQoScMuzbIGjL1XUobsdKNR(iqq3b1BNvh76InScKKHXggVDIaX2246(R7BpNn0f1EUHjLjBOlQtYfREo5I1uBXGNdWyOha2R(ODUpkph0gTee(p8C2qxu75Inc1GinrKKamLLNBqwfiR55i2ksadO1Gje4WZTo215qDQrYanOBmKuusSqD5x3aftJsUOTvCqaZDSAD8CDmf(AD85x3aftJsUOTvCqaZDSADm)x3WnfBrKWUqlQJxp3iVHesQrYaf7JMjV6JoY(O8CqB0sq4)WZniRcK18CeBfjGb0AWecCy76yUoN)DD8qDeBfjGb0AWecCq8iMUOUo21nqX0OKlABfheWChRwhZ)1nCtXwejSl0cpNn0f1EUyJqnistejjatz5vF0F1hLNdAJwcc)hEoKRNddQNZg6IAphdJSgTe8Cmm5d8CovNAsO1a(rRaz(YGa0gTee1XNFDovNrrGSkeWSiONaej8BordtxuhG2OLGOo(8RtG0qMriifcUXpPUUYfi1XCDmvh76COoSliLj1izGIdtRtOzI6Eza46YVokyD85xNt1nqiPaLBhyy9IzfEU1XRNJHrsTfdEogqlavTe(rRaz(YG0a1Ivxu7vF0uqFuEoOnAji8F45qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5uDQjHwd9MXsXQjPgibOnAjiQJp)6CQo1KqRbicS1zVTnfcqB0squhF(1nqiPaLBhGiWwN922uiqGyBBCD5x3xRJhQ7Z6456utcTgea4cKewjMAzqCaAJwccphdJKAlg8CmGwaQAPEZyPy1KudK0a1Ivxu7vF0oBFuEoOnAji8F45qUEomOEoBOlQ9CmmYA0sWZXWKpWZ5uDWx8TUUGiyueZYigonrTMqZKlkxGuhF(1zueiRcbmlc6jarc)Mt0W0f1bOnAjiQJp)6ea9BodeJIisAGiMmja63CgeOC764ZVUbcjfOC7GHzXWAaNigfrK0armzGaX2246YVoM(Uo215qDdeskq52bffXos0stabceBBJRl)6yQo(8Rta0V5mOOi2rIwAci8CRJxphdJKAlg8CmGwaQAPjQ10a1Ivxu7vF0otFuEoOnAji8F45gKvbYAEoNQdRGjvwGiqqzpOo21jqAG8C1hbc6oOE7S6yxNt1ja63CgyaTau1cp36yxhdJSgTecmGwaQAj8JwbY8LbPbQfRUOUo21XWiRrlHadOfGQwQ3mwkwnj1ajnqTy1f11XUoggznAjeyaTau1stuRPbQfRUO2ZzdDrTNJb0cqvZR(OPa9r55G2OLGW)HNBqwfiR55utcTgGiWwN922uiaTrlbrDSRZH6utcTg6nJLIvtsnqcqB0squhF(1PMeAnGF0kqMVmiaTrlbrDSRJHrwJwcb82zsiPgjd064To21nqX0OKlABfxhZ)1nCtXwejSl0I6yx3aHKcuUDaIaBD2BBtHabITTX1LFDmvh76COoNQtnj0Aa)OvGmFzqaAJwcI64ZVoNQZOiqwfcywe0taIe(nNOHPlQdqB0squhF(1jqAiZieKcb34Nuxx5cK6Y)VoMQJxpNn0f1EogwVywE1hntF7JYZbTrlbH)dp3GSkqwZZPMeAn0BglfRMKAGeG2OLGOo215uDQjHwdqeyRZEBBkeG2OLGOo21nqX0OKlABfxhZ)1nCtXwejSl0I6yxNaOFZzGb0cqvl8C9C2qxu75yy9Iz5vF0mXKpkph0gTee(p8CixphgupNn0f1EoggznAj45yyYh45mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XUohQRrDcJt0V5eej1izGIRJ5)6yQo(8Rd7cszsnsgO4W06eAMOUxgaUU)6CED8wh76COomor)MtqKuJKbkoz0igqY1AbeVJ6(R7764ZVoSliLj1izGIdtRtOzI6Eza46y(VokyD865yyKuBXGNdJtmSEXSsdulwDrTx9rZ0N(O8CqB0sq4)WZzdDrTNZfHKjcGrpYa8CqekXswm61QNlYF1ZnrKudrO(OzYR(OzY5(O8CqB0sq4)WZniRcK18CQjHwd4hTcK5ldcqB0squh76CQoScMuzbIabL9G6yx3aHKcuUDiZieKcHNBDSRZH6yyK1OLqaJtmSEXSsdulwDrDD85xNt1zueiRcbmlc6jarc)Mt0W0f1bOnAjiQJDDcKgYmcbPqGatcGzz0sOoERJDDdumnk5I2wXbbm3XQ1X8FDouNd1XuDuv3N1XZ1zueiRcbmlc6jarc)Mt0W0f1bOnAjiQJ36456WUGuMuJKbkomToHMjQ7LbGRJ36yMhBDrUo21rSvKagqRbtiWHTRJ56y6tpNn0f1EogwVywE1hntr2hLNdAJwcc)hEUbzvGSMNtnj0Ai2WkqsggBy82bOnAjiQJDDovhwbtQSarWKY6yxxSHvGKmm2W4Ttei22gxx()19DDSRZP6einqEU6JabcmjaMLrlH6yxNaPHmJqqkeiqSTnUoMRZ51XUobq)MZadOfGQw45wh76COoNQtnj0AqrrSJeT0eqaAJwcI64ZVobq)MZGIIyhjAPjGWZToERJDDouNt1bym0diqlrircntklibneNxi24XGi1XNFDcG(nNbAjcjsOzszbjOH48cp3641ZzdDrTNJH1lMLx9rZ0x9r55G2OLGW)HNBqwfiR55CQoScMuzbIGjL1XUoJIazviGzrqpbis43CIgMUOoaTrlbrDSRtG0qMriifceysamlJwc1XUobsdzgHGui4g)K66kxGux()1XuDSRBGIPrjx02koiG5owToM)RJjpNn0f1EomltGYngKcV6JMjkOpkph0gTee(p8CdYQaznpNaPbYZvFeiqGyBBCDmxxKRJQ6ICD8CDd3uSfrc7cTOo215uDcKgYmcbPqGatcGzz0sWZzdDrTNdIaBD2BBtbV6JMjNTpkph0gTee(p8CdYQaznpNaPbYZvFeiO7G6TZQJDDouNt1bFX366cIGrrmlJy40e1AcntUOCbsD85x3aHKcuUDGb0cqvlqGyBBCDmxhtFxhVEoBOlQ9CkkIDKOLMa8QpAMCM(O8CqB0sq4)WZniRcK18C0V5mqlriH8H1abSHwhF(1ja63CgyaTau1cpxpNn0f1EoxKUO2R(OzIc0hLNdAJwcc)hEUbzvGSMNta0V5mWaAbOQfEUEoBOlQ9C0sesKMpsEE1h9NF7JYZbTrlbH)dp3GSkqwZZja63CgyaTau1cpxpNn0f1EoAGGbc1BN5vF0FYKpkph0gTee(p8CdYQaznpNaOFZzGb0cqvl8C9C2qxu75MlbOLiKWR(O)8tFuEoOnAji8F45gKvbYAEobq)MZadOfGQw4565SHUO2Zz9aWkXKPHjLE1h9No3hLNdAJwcc)hEoBOlQ9CzMegMuceCIgHAp3GSkqwZZnqiPaLBhyaTau1cei22gxhZ1f5V65Alg8CzMegMuceCIgHAV6J(Zi7JYZbTrlbH)dpNn0f1EodZIH1aormkIiPbIysp3GSkqwZZja63CgigfrK0armzsa0V5miq521XNFDcG(nNbgqlavTabITTX1XCDm9DD8qDrUoEUo4l(wxxqemkIzzedNMOwtOzYfLlqQJp)6uJKbAq3yiPOKyH6YVUp)2Z1wm45mmlgwd4eXOiIKgiIj9Qp6p)Qpkph0gTee(p8C2qxu75g5nKiLG6DKOLgw9CdYQaznpxSHvGKmm2W4Ttei22gx3FDFxh76CQobq)MZadOfGQw45wh76CQobq)MZGIIyhjAPjGWZTo21r)MZqmeJi5LqZK8nwrsqalgheOC76yxh0ajlV6YVoN531XUobsdKNR(iqGaX2246yUUi75G5egAQTyWZnYBirkb17irlnS6vF0Fsb9r55G2OLGW)HNZg6IApN8rOgi4024vSOhoLTt1ZniRcK18CcG(nNbgqlavTWZ1Z1wm45Kpc1abN2gVIf9WPSDQE1h9NoBFuEoOnAji8F45SHUO2ZjFyLGE4ugskGo5kFXwg45gKvbYAEobq)MZadOfGQw4565Alg8CYhwjOhoLHKcOtUYxSLbE1h9NotFuEoOnAji8F45SHUO2ZLjnXAkIGtXGWKYf1EUbzvGSMNta0V5mWaAbOQfEUEoyoHHMAlg8CzstSMIi4umimPCrTx9r)jfOpkph0gTee(p8C2qxu75YKMynfrWjAtKbEUbzvGSMNta0V5mWaAbOQfEUEoyoHHMAlg8CzstSMIi4eTjYaV6J25F7JYZzdDrTN7HH0Qqm2ZbTrlbH)dV6vpNaP(O8rZKpkph0gTee(p8CixphgupNn0f1EoggznAj45yyYh45CjlISAEjcsnDrDDSRd7cszsnsgO4W06eAMOUxgaUoMRZ51XUohQtG0qMriifcei22gxx(1nqiPaLBhYmcbPqq8iMUOUo(8RZfTyudIeTeabUoMR7R1XRNJHrsTfdEom1RBAK3qcPmJqqk4vF0F6JYZbTrlbH)dphY1ZHb1ZzdDrTNJHrwJwcEogM8bEoxYIiRMxIGutxuxh76WUGuMuJKbkomToHMjQ7LbGRJ56CEDSRZH6ea9BodkkIDKOLMacp364ZVohQZfTyudIeTeabUoMR7R1XUoNQZOiqwfc4b0Acnt0seseG2OLGOoERJxphdJKAlg8CyQx30iVHesKNR(iGx9r7CFuEoOnAji8F45qUEomOEoBOlQ9CmmYA0sWZXWKpWZja63CgyaTau1cp36yxNd1ja63Cguue7irlnbeEU1XNFDXgwbsYWydJ3orGyBBCDmx331XBDSRtG0a55QpceiqSTnUoMR7tphdJKAlg8CyQx3e55Qpc4vF0r2hLNdAJwcc)hEUbzvGSMNtnj0AaIaBD2BBtHa0gTee1XUohQZH6gOyAuYfTTIRJ5)6gUPylIe2fArDSRBGqsbk3oarGTo7TTPqGaX2246YVoMQJ364ZVohQZP60Dq92z1XUohQt3yOoMRJPVRJp)6gOyAuYfTTIRJ5)6(SoERJ3641ZzdDrTNJ8C1hb8Qp6V6JYZbTrlbH)dp3ersneH6JMjpNn0f1EoxesMiag9idWR(OPG(O8CqB0sq4)WZniRcK18CouNt1PMeAnGF0kqMVmiaTrlbrD85xNt15qDdeskq52bgwVywHNBDSRBGqsbk3oWaAbOQfiqSTnUU8)RlY1XBD8wh76gOyAuYfTTIdcyUJvRJ5)6yQoQQZ51XZ15qDgfbYQqaZIGEcqKWV5enmDrDaAJwcI6yx3aHKcuUDGH1lMv45whV1XUocmjaMLrlH6yxNd15g)K66kxGux()1XuD85xhbITTX1L)FD6oOoPBmuh76WUGuMuJKbkomToHMjQ7LbGRJ5)6CEDuvNrrGSkeWSiONaej8BordtxuhG2OLGOoERJDDouNt1brGTo7TTPGOo(8RJaX2246Y)VoDhuN0ngQJNR7Z6yxh2fKYKAKmqXHP1j0mrDVmaCDm)xNZRJQ6mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XBDSRZP6W4e9BobrDSRZH6uJKbAq3yiPOKyH64H6iqSTnUoERJ56ICDSRZH6InScKKHXggVDIaX2246(R7764ZVoNQt3b1BNvh76mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XRNZg6IApxMriif8QpANTpkph0gTee(p8Ctej1qeQpAM8C2qxu75CrizIay0JmaV6J2z6JYZbTrlbH)dpNn0f1EUmJqqk45gKvbYAEoNQJHrwJwcbm1RBAK3qcPmJqqkuh76COoNQtnj0Aa)OvGmFzqaAJwcI64ZVoNQZH6giKuGYTdmSEXScp36yx3aHKcuUDGb0cqvlqGyBBCD5)xxKRJ364To21nqX0OKlABfheWChRwhZ)1XuDuvNZRJNRZH6mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XUUbcjfOC7adRxmRWZToERJDDeysamlJwc1XUohQZn(j11vUaPU8)RJP64ZVoceBBJRl))60DqDs3yOo21HDbPmPgjduCyADcntu3ldaxhZ)1586OQoJIazviGzrqpbis43CIgMUOoaTrlbrD8wh76COoNQdIaBD2BBtbrD85xhbITTX1L)FD6oOoPBmuhpx3N1XUoSliLj1izGIdtRtOzI6Eza46y(VoNxhv1zueiRcbmlc6jarc)Mt0W0f1bOnAjiQJ36yxNt1HXj63CcI6yxNd1Pgjd0GUXqsrjXc1Xd1rGyBBCD8whZ1X0N1XUohQl2WkqsggBy82jceBBJR7VUVRJp)6CQoDhuVDwDSRZOiqwfcywe0taIe(nNOHPlQdqB0squhVEUrEdjKuJKbk2hntE1hnfOpkph0gTee(p8CdYQaznph2fKYKAKmqX1X8FDFwh76iqSTnUU8R7Z6OQohQd7cszsnsgO46y(VUVwhV1XUUbkMgLCrBR46y(VUi75SHUO2ZniBmg1jfIDbS6vF0m9Tpkph0gTee(p8CdYQaznpNt1XWiRrlHaM61nrEU6Ja1XUUbkMgLCrBR46y(VUixh76iWKaywgTeQJDDouNB8tQRRCbsD5)xht1XNFDei22gxx()1P7G6KUXqDSRd7cszsnsgO4W06eAMOUxgaUoM)RZ51rvDgfbYQqaZIGEcqKWV5enmDrDaAJwcI64To215qDovheb26S32McI64ZVoceBBJRl))60DqDs3yOoEUUpRJDDyxqktQrYafhMwNqZe19YaW1X8FDoVoQQZOiqwfcywe0taIe(nNOHPlQdqB0squhV1XUo1izGg0ngskkjwOoEOoceBBJRJ56ISNZg6IAph55Qpc4vF0mXKpkph0gTee(p8C2qxu75ipx9rap3GSkqwZZ5uDmmYA0siGPEDtJ8gsirEU6Ja1XUoNQJHrwJwcbm1RBI8C1hbQJDDdumnk5I2wX1X8FDrUo21rGjbWSmAjuh76COo34Nuxx5cK6Y)VoMQJp)6iqSTnUU8)Rt3b1jDJH6yxh2fKYKAKmqXHP1j0mrDVmaCDm)xNZRJQ6mkcKvHaMfb9eGiHFZjAy6I6a0gTee1XBDSRZH6CQoicS1zVTnfe1XNFDei22gxx()1P7G6KUXqD8CDFwh76WUGuMuJKbkomToHMjQ7LbGRJ5)6CEDuvNrrGSkeWSiONaej8BordtxuhG2OLGOoERJDDQrYanOBmKuusSqD8qDei22gxhZ1fzp3iVHesQrYaf7JMjV6vV65yae8IAF0F(9NF)ntFgzpxUgP3od75CwIDrefe15SRZg6I66KlwXHIsph2fg(O)8RuGEoxcAUsWZfP6OWySHXBB6I66OqOShuugP6yPQlMNKtozRY6rhgO4CWB8tA6I6bXMAo4nEKtrzKQJhbqtEgjV6OGow3NF)53fLfLrQoNblRZampPOms1Xd1rHfcqu3xWoOUofvNaM2tQ1zdDrDDYfRHIYivhpuhfcIrmG6uJKbAANHIYivhpuhfwiarD8OXqDolkeJRZb0tXRaQdnRdRGjvw8gkklkJuD80iGXtbrD0WerG6gOyAtRJgY2ghQJcpgGRIRRrnpWYiXZNSoBOlQX1HAzEHIYivNn0f14GlbgOyAt)NsdtDrzKQZg6IACWLadumTPu9NJ9YIHwnDrDrzKQZg6IACWLadumTPu9NZeHefLrQoU2CXSqADeBf1r)MtquhwnfxhnmreOUbkM206OHSTX1zTOoxcWdUiv3oRUfxNa1qOOms1zdDrno4sGbkM2uQ(Zb3MlMfsty1uCrPn0f14GlbgOyAtP6phZ1vMxYfTyuxuAdDrno4sGbkM2uQ(Zj2iudI0erscWuwo6sGbkM20eggOwG))QJ78NyRibmGwdMqGdBZmtFTO0g6IACWLadumTPu9NdwbtQSkkTHUOghCjWaftBkv)58WqAvi2X2IHFJIywgXWPjQ1eAMCr5cKIsBOlQXbxcmqX0Ms1FoUiDrDrzrzKQJNgbmEkiQdyaK8Qt3yOoLfuNnuePUfxNXWwPrlHqrzKQJcbyfmPYQUDwNlcJxAjuNdnQogpzdeJwc1bneVaUUTRBGIPnL3IsBOlQX)uVdQDCN)oHvWKklqemPSO0g6IAmv)5GvWKkRIsBOlQXu9NddJSgTeCSTy4hAGKLxIazqNgOy6TbHJmm5d(Hgiz5fiqg0u5IwmQbrIwcGaZZo7Vqh(KNXUGuMyzyf4TO0g6IAmv)5WWiRrlbhBlg(XBNjHKAKmqDKHjFWp2fKYKAKmqXHP1j0mrDVmaC(FwuAdDrnMQ)CgMuMSHUOojxS6yBXWpwbtQSaHJ78hRGjvwGiqqzpOO0g6IAmv)5mmPmzdDrDsUy1X2IH)Ha74o)DWj1KqRHydRajzySHXBhG2OLGGpFbsdzgHGuiO7G6TZ4TO0g6IAmv)5mmPmzdDrDsUy1X2IHFbslkTHUOgt1Fodtkt2qxuNKlwDSTy4xSeyOfL2qxuJP6phJmSgskIqGwDCN)qdKS8ccyUJvz(NPVsfdJSgTecqdKS8seid60aftVnikkTHUOgt1FogzynKCFsmuuAdDrnMQ)CKBglfN4X8ezXqRfL2qxuJP6phAllHMjLSdQXfL2qxuJP6phbOWqxu74o)HV4BDDbragSqBNLyGwbF(Wx8TUUGiadwOTZsmqRiHyvuwugP6CgiKuGYTXfL2qxuJddb()HH0QqSJTfd)gfXSmIHttuRj0m5IYfioUZFNWkysLficMuYo2WkqsggBy82jceBBJ))MTddeskq52bgqlavTabITTX5ZJDGqsbk3oOOi2rIwAciqGyBBmV5Z03uX038m8fFRRlicgMfdRbCIyuersdeXKSDsa0V5mWaAbOQfEUSDsa0V5mOOi2rIwAci8ClkTHUOghgcmv)5mmPmzdDrDsUy1X2IHFaJHEayh35VtyfmPYcebtkzlqAG8C1hbc6oOE7m2XgwbsYWydJ3orGyBB8)3fLrQoNLzDMqGRZiqDpxhRd3RluNYcQd1qD5UkR6KOCbSwxur9Ld1XJgd1LllORtK32z1nnScK6uwwxNZ4lvNaM7y16qK6YDvwONwN15vNZ4lfkkTHUOghgcmv)5eBeQbrAIijbyklhh5nKqsnsgO4FMCCN)eBfjGb0AWecC45Y2b1izGg0ngskkjwi)bkMgLCrBR4GaM7yvEMPWx5ZFGIPrjx02koiG5owL5)HBk2IiHDHwWBrzKQZzzwxJQZecCD5UszDIfQl3vzTDDklOUgIqRZ5FJDSUhgQZzD(LRd11rJW46YDvwONwN15vNZ4lfkkTHUOghgcmv)5eBeQbrAIijbyklh35pXwrcyaTgmHah2MzN)npqSvKagqRbtiWbXJy6IA2dumnk5I2wXbbm3XQm)pCtXwejSl0IIYivhfa0cqvRojkBhMSUbQfRUO2K46OnmiQd11nEec0ADyxyuuAdDrnomeyQ(ZHHrwJwco2wm8ZaAbOQLWpAfiZxgKgOwS6IAhzyYh87KAsO1a(rRaz(YGa0gTee857KrrGSkeWSiONaej8BordtxuhG2OLGGpFbsdzgHGui4g)K66kxGWmtSDa7cszsnsgO4W06eAMOUxgaoFkiF(onqiPaLBhyy9IzfEU8wuAdDrnomeyQ(ZHHrwJwco2wm8ZaAbOQL6nJLIvtsnqsdulwDrTJmm5d(Dsnj0AO3mwkwnj1ajaTrlbbF(oPMeAnarGTo7TTPqaAJwcc(8hiKuGYTdqeyRZEBBkeiqSTno)VYdFYZQjHwdcaCbscRetTmioaTrlbrrPn0f14WqGP6phggznAj4yBXWpdJSgTeCSTy4Nb0cqvlnrTMgOwS6IAhzyYh87e8fFRRlicgfXSmIHttuRj0m5IYfi85BueiRcbmlc6jarc)Mt0W0f1bOnAji4Zxa0V5mqmkIiPbIyYKaOFZzqGYT5ZFGqsbk3oyywmSgWjIrrejnqetgiqSTnoFM(MTddeskq52bffXos0stabceBBJZNj(8fa9BodkkIDKOLMacpxElkTHUOghgcmv)5WaAbOQ54o)DcRGjvwGiqqzpGTaPbYZvFeiO7G6TZy7KaOFZzGb0cqvl8CzZWiRrlHadOfGQwc)OvGmFzqAGAXQlQzZWiRrlHadOfGQwQ3mwkwnj1ajnqTy1f1SzyK1OLqGb0cqvlnrTMgOwS6I6IYivhfG1lMvD5UkR64PrGZQJQ6Ci6nJLIvtsnqCSoePoUhTcK5ldQd1Y8Qd11Xuu8YtQZz1IyJFX15m(s1zTOoEAe4S6iGjYRUjIuxdrO1XJ7m(YfL2qxuJddbMQ)Cyy9Iz54o)vtcTgGiWwN922uiaTrlbbBhutcTg6nJLIvtsnqcqB0sqWNVAsO1a(rRaz(YGa0gTeeSzyK1OLqaVDMesQrYaLx2dumnk5I2wXm)pCtXwejSl0c2deskq52bicS1zVTnfcei22gNptSDWj1KqRb8JwbY8LbbOnAji4Z3jJIazviGzrqpbis43CIgMUOoaTrlbbF(cKgYmcbPqWn(j11vUaj)FM4TOms1rby9IzvxURYQUO3mwkwnj1aPoQQlAuD80iWz8K6CwTi24xCDoJVuDwlQJcaAbOQv3ZTO0g6IACyiWu9NddRxmlh35VAsO1qVzSuSAsQbsaAJwcc2oPMeAnarGTo7TTPqaAJwcc2dumnk5I2wXm)pCtXwejSl0c2cG(nNbgqlavTWZTOms1XbqDZNuw3afhdTwhQRJLQUyEso5KTkRhDyGIZHczmGMfskuEikNrouiu2dYj3L6nhkmgBy82MUOMhOWFjEu8afcWGrgScfL2qxuJddbMQ)CyyK1OLGJTfd)yCIH1lMvAGAXQlQDKHjFWVrrGSkeWSiONaej8BordtxuhG2OLGGTdnQtyCI(nNGiPgjdumZ)mXNp2fKYKAKmqXHP1j0mrDVma8VZ5LTdyCI(nNGiPgjduCYOrmGKR1ciEh)FZNp2fKYKAKmqXHP1j0mrDVmamZ)uqElkTHUOghgcmv)54IqYebWOhzaoorKudrO)m5ieHsSKfJET(h5VwuAdDrnomeyQ(ZHH1lMLJ78xnj0Aa)OvGmFzqaAJwcc2oHvWKklqeiOShWEGqsbk3oKzecsHWZLTdmmYA0siGXjgwVywPbQfRUOMpFNmkcKvHaMfb9eGiHFZjAy6I6a0gTeeSfinKzecsHabMeaZYOLaVShOyAuYfTTIdcyUJvz(3bhyIQp5zJIazviGzrqpbis43CIgMUOoaTrlbbV8m2fKYKAKmqXHP1j0mrDVmamVmZJnYSj2ksadO1Gje4W2mZ0NfLrQokaRxmR6YDvw15SAyfi1rHXydVnpPUOr1HvWKkR6SwuxJQZg6YaQZzLcxh9BoDSok0ZvFeOUgP1TDDeysamR6iwNbowN4r2oRokaOfGQgvr9HJ1jEKTZQ7djcjQdWyOPyD7SoJHTsJwcHIsBOlQXHHat1FomSEXSCCN)QjHwdXgwbsYWydJ3oaTrlbbBNWkysLficMuYo2WkqsggBy82jceBBJZ))B2ojqAG8C1hbceysamlJwcSfinKzecsHabITTXm7C2cG(nNbgqlavTWZLTdoPMeAnOOi2rIwAciaTrlbbF(cG(nNbffXos0staHNlVSDWjaJHEabAjcjsOzszbjOH48cXgpgeHpFbq)MZaTeHej0mPSGe0qCEHNlVfLrQoowMaLBmif1nrK64yrqpbiQJ7nNOHPlQlkTHUOghgcmv)5GzzcuUXGu44o)DcRGjvwGiysjBJIazviGzrqpbis43CIgMUOoaTrlbbBbsdzgHGuiqGjbWSmAjWwG0qMriifcUXpPUUYfi5)Ze7bkMgLCrBR4GaM7yvM)zQOms1XtJaBD2BBtH6YLf01rJuw1rHEU6Ja1zTOoECJqqkuNrG6EU1nrK6KOoRoOrVmwfL2qxuJddbMQ)CGiWwN922uWXD(lqAG8C1hbcei22gZCKPkY88WnfBrKWUqly7KaPHmJqqkeiWKaywgTekkTHUOghgcmv)5OOi2rIwAcWXD(lqAG8C1hbc6oOE7m2o4e8fFRRlicgfXSmIHttuRj0m5IYfi85pqiPaLBhyaTau1cei22gZmtFZBrPn0f14WqGP6phxKUO2XD(t)MZaTeHeYhwdeWgkF(cG(nNbgqlavTWZTO0g6IACyiWu9NdTeHeP5JKNJ78xa0V5mWaAbOQfEUfL2qxuJddbMQ)CObcgiuVDMJ78xa0V5mWaAbOQfEUfL2qxuJddbMQ)CMlbOLiKWXD(la63CgyaTau1cp3IsBOlQXHHat1FowpaSsmzAysPJ78xa0V5mWaAbOQfEUfL2qxuJddbMQ)CEyiTke7yBXWFMjHHjLabNOrO2XD(pqiPaLBhyaTau1cei22gZCK)ArPn0f14WqGP6pNhgsRcXo2wm8BywmSgWjIrrejnqet64o)fa9BodeJIisAGiMmja63CgeOCB(8fa9BodmGwaQAbceBBJzMPV5HiZZWx8TUUGiyueZYigonrTMqZKlkxGWNVAKmqd6gdjfLelK)NFxuAdDrnomeyQ(Z5HH0QqSJWCcdn1wm8pYBirkb17irlnS64o)JnScKKHXggVDIaX224)Vz7KaOFZzGb0cqvl8Cz7KaOFZzqrrSJeT0eq45YM(nNHyigrYlHMj5BSIKGawmoiq52SHgiz5LVZ8B2cKgipx9rGabITTXmh5IsBOlQXHHat1FopmKwfIDSTy4x(iudeCAB8kw0dNY2P64o)fa9BodmGwaQAHNBrPn0f14WqGP6pNhgsRcXo2wm8lFyLGE4ugskGo5kFXwg44o)fa9BodmGwaQAHNBrPn0f14WqGP6pNhgsRcXocZjm0uBXWFM0eRPicofdctkxu74o)fa9BodmGwaQAHNBrPn0f14WqGP6pNhgsRcXocZjm0uBXWFM0eRPicorBImWXD(la63CgyaTau1cp3IYiv3xgM2tQ1nnPK2gux3erQ7HnAju3QqmMNuhpAmuhQRBGqsbk3ouuAdDrnomeyQ(Z5HH0QqmUOSOms19Lxcm06ewSLb1z0RC1fWfLrQoEAZaAuCDMwxKPQoh(kv1L7QSQ7lZXBDoJVuOoNL4yqSMcY8Qd119jv1PgjduSJ1L7QSQJcaAbOQ5yDisD5UkR6I6dEKxhszbKCxmuxU2Q1nrK6WOyOoObswEH6OWsmQUCTvRBN1XtJaNv3aftJQBX1nqXBNv3ZnuuAdDrnoiwcm0FOzank2XD(pqX0OKlABfZ8FKPsnj0AqaGlqsyLyQLbXbOnAjiy7GaOFZzGb0cqvl8C5Zxa0V5mOOi2rIwAci8C5ZhAGKLxqaZDSA()F(vQyyK1OLqaAGKLxIazqNgOy6TbbF(oXWiRrlHaE7mjKuJKbkVSDWj1KqRbicS1zVTnfcqB0sqWN)aHKcuUDaIaBD2BBtHabITTXm)jVfL2qxuJdILadLQ)CyyK1OLGJTfd)pmKMRucehzyYh8pqX0OKlABfheWChRYmt85dnqYYliG5own))p)kvmmYA0sianqYYlrGmOtdum92GGpFNyyK1OLqaVDMesQrYaTOms1XJKvzvhpDWcTDwDFinbGDSoEewxhAw3xqVmaCDMw3NuvNAKmqXHIsBOlQXbXsGHs1FotRtOzI6Ezayh35pdJSgTecpmKMRuce2gfbYQqagSqBNLOLMaWbOnAjiyJDbPmPgjduCyADcntu3ldaZ8)NfLrQoEewxhAw3xqVmaCDMwhtuGuvhwTb146qZ64r2keqx3hsta46qK6SmBBSwxKPQoh(kv1L7QSQ7lJE0sOUVmcd8wNAKmqXHIsBOlQXbXsGHs1FotRtOzI6Ezayh35pdJSgTecpmKMRuce2oq)MZaRviGorlnbGdy1guZ8ptuG857GtUKfrwnVebPMUOMn2fKYKAKmqXHP1j0mrDVmamZ)rMkhmkcKvHGa9OLqsGWqGyn1m)jVuHvWKklqeiOShWlVfLrQoEewxhAw3xqVmaCDkQoZ1vMxDFzWeY8Q7lHwmQRBN1TTn0LbuhQRZ68QtnsgO1zADoVo1izGIdfL2qxuJdILadLQ)CMwNqZe19YaWooYBiHKAKmqX)m54o)zyK1OLq4HH0CLsGWg7cszsnsgO4W06eAMOUxgaM5FNxuAdDrnoiwcmuQ(ZHwUTaVcWXD(ZWiRrlHWddP5kLaHTd0V5mql3wGxbeEU857KAsO1adOrXjYdZkaTrlbbBNmkcKvHGa9OLqsGWqaAJwccElkJuDrz08GZ6txPPqDkQoZ1vMxDFzWeY8Q7lHwmQRZ06(So1izGIlkTHUOghelbgkv)5e)0vAk44iVHesQrYaf)ZKJ78NHrwJwcHhgsZvkbcBSliLj1izGIdtRtOzI6Eza4)plkTHUOghelbgkv)5e)0vAk44o)zyK1OLq4HH0CLsGuuwugP6(YwSLb1HyaK60ngQZOx5QlGlkJuD8O24vRJh3ieKc46qDDnQ5bxYgtmsE1PgjduCDtePoLfuNlzrKvZRocsnDrDD7SUVsvD0sae46mcuNjjGjYRUNBrPn0f14GaP)mmYA0sWX2IHFm1RBAK3qcPmJqqk4idt(GFxYIiRMxIGutxuZg7cszsnsgO4W06eAMOUxgaMzNZ2bbsdzgHGuiqGyBBC(deskq52HmJqqkeepIPlQ5Z3fTyudIeTeabM5VYBrzKQJh1gVADuONR(iaUouxxJAEWLSXeJKxDQrYafx3erQtzb15swez18QJGutxux3oR7RuvhTeabUoJa1zscyI8Q75wuAdDrnoiqkv)5WWiRrlbhBlg(XuVUPrEdjKipx9rahzyYh87swez18seKA6IA2yxqktQrYafhMwNqZe19YaWm7C2oia63Cguue7irlnbeEU857GlAXOgejAjacmZFLTtgfbYQqapGwtOzIwIqIa0gTee8YBrzKQJh1gVADuONR(iaUUDwhfa0cqvJQOqrSJ6(qAcihNvdRaPokmgBy821T46EU1zTOUCH6yzmG6(KQ6WWa1cCDsyQ1H66uwqDuONR(iqDFzuufL2qxuJdcKs1FommYA0sWX2IHFm1RBI8C1hbCKHjFWVaOFZzGb0cqvl8Cz7GaOFZzqrrSJeT0eq45YNFSHvGKmm2W4Ttei22gZ838YwG0a55QpceiqSTnM5plkJuDCUWynzDuONR(iqDyqFU1nrK64PrGZkkTHUOgheiLQ)Cipx9rah35VAsO1aeb26S32McbOnAjiy7Gddumnk5I2wXm)pCtXwejSl0c2deskq52bicS1zVTnfcei22gNpt8YNVdoP7G6TZy7GUXaZm9nF(dumnk5I2wXm))jV8YBrzKQJh3ieKc19CPgaxhRZKyuDkzbCDkQUhgQB16mCDwDyxySMSUmObIPisDtePoLfuN0WADoJVuD0WerG6S6MBVywaPO0g6IACqGuQ(ZXfHKjcGrpYaCCIiPgIq)zQO0g6IACqGuQ(ZjZieKcoUZFhCsnj0Aa)OvGmFzqaAJwcc(8DYHbcjfOC7adRxmRWZL9aHKcuUDGb0cqvlqGyBBC()rMxEzpqX0OKlABfheWChRY8ptu5CE2bJIazviGzrqpbis43CIgMUOoaTrlbb7bcjfOC7adRxmRWZLx2eysamlJwcSDWn(j11vUaj)FM4ZNaX2248)1DqDs3yGn2fKYKAKmqXHP1j0mrDVmamZ)oNkJIazviGzrqpbis43CIgMUOoaTrlbbVSDWjicS1zVTnfe85tGyBBC()6oOoPBmWZFYg7cszsnsgO4W06eAMOUxgaM5FNtLrrGSkeWSiONaej8BordtxuhG2OLGGx2oHXj63Ccc2oOgjd0GUXqsrjXc8abITTX8YCKz7qSHvGKmm2W4Ttei22g))nF(oP7G6TZyBueiRcbmlc6jarc)Mt0W0f1bOnAji4TO0g6IACqGuQ(ZXfHKjcGrpYaCCIiPgIq)zQO0g6IACqGuQ(ZjZieKcooYBiHKAKmqX)m54o)DIHrwJwcbm1RBAK3qcPmJqqkW2bNutcTgWpAfiZxgeG2OLGGpFNCyGqsbk3oWW6fZk8CzpqiPaLBhyaTau1cei22gN)FK5Lx2dumnk5I2wXbbm3XQm)ZevoNNDWOiqwfcywe0taIe(nNOHPlQdqB0sqWEGqsbk3oWW6fZk8C5LnbMeaZYOLaBhCJFsDDLlqY)Nj(8jqSTno)FDhuN0ngyJDbPmPgjduCyADcntu3ldaZ8VZPYOiqwfcywe0taIe(nNOHPlQdqB0sqWlBhCcIaBD2BBtbbF(ei22gN)VUdQt6gd88NSXUGuMuJKbkomToHMjQ7LbGz(35uzueiRcbmlc6jarc)Mt0W0f1bOnAji4LTtyCI(nNGGTdQrYanOBmKuusSapqGyBBmVmZ0NSDi2WkqsggBy82jceBBJ))MpFN0Dq92zSnkcKvHaMfb9eGiHFZjAy6I6a0gTee8wugP6CgKngJ66IcIDbSwhQL5vhQRl(j11vc1PgjduCDMwxKPQoNXxQUCzbDDKx3BNvh6P1TDDFIRZHNBDkQUixNAKmqX8whIuNZX15WxPQo1izGI5TO0g6IACqGuQ(Zzq2ymQtke7cy1XD(JDbPmPgjdumZ)FYMaX2248)KkhWUGuMuJKbkM5)VYl7bkMgLCrBRyM)JCrzKQ7laa36EU1rHEU6Ja1zADrMQ6qDDMuwNAKmqX15qUSGUo5Yy7S6KOoRoOrVmw1zTOUgP1HBZfZcP8wuAdDrnoiqkv)5qEU6JaoUZFNyyK1OLqat96Mipx9ra2dumnk5I2wXm)hz2eysamlJwcSDWn(j11vUaj)FM4ZNaX2248)1DqDs3yGn2fKYKAKmqXHP1j0mrDVmamZ)oNkJIazviGzrqpbis43CIgMUOoaTrlbbVSDWjicS1zVTnfe85tGyBBC()6oOoPBmWZFYg7cszsnsgO4W06eAMOUxgaM5FNtLrrGSkeWSiONaej8BordtxuhG2OLGGx2QrYanOBmKuusSapqGyBBmZrUO0g6IACqGuQ(ZH8C1hbCCK3qcj1izGI)zYXD(7edJSgTecyQx30iVHesKNR(iaBNyyK1OLqat96Mipx9ra2dumnk5I2wXm)hz2eysamlJwcSDWn(j11vUaj)FM4ZNaX2248)1DqDs3yGn2fKYKAKmqXHP1j0mrDVmamZ)oNkJIazviGzrqpbis43CIgMUOoaTrlbbVSDWjicS1zVTnfe85tGyBBC()6oOoPBmWZFYg7cszsnsgO4W06eAMOUxgaM5FNtLrrGSkeWSiONaej8BordtxuhG2OLGGx2QrYanOBmKuusSapqGyBBmZrUOSOms1XtXyOhaUO0g6IACaWyOha(FG6b0kXuqKMslgCCN)qdKS8c6gdjfLITiyMj2oja63CgyaTau1cpx2o4KaPHbQhqRetbrAkTyir)iDq3b1BNX2jBOlQddupGwjMcI0uAXqy70uUzSu(8NpPmrGblJKbjDJH8ZgIqSfbVfLrQokSmxlpCDpmu3hsesuxURYQokaOfGQwDp3qDuyjgv3dd1L7QSQlQpQ75whnmreOoRU52lMfqQZHDwNAsOvqWBDgUojQZQZW1TADKxJRBIi1X0346epY2z1rbaTau1cfL2qxuJdagd9aWu9NdTeHej0mPSGe0qCEoUZFbq)MZadOfGQw45Y2bNutcTguue7irlnbeG2OLGGpFbq)MZGIIyhjAPjGWZL9aftJsUOTvCqaZDSA()mXNVaOFZzGb0cqvlqGyBBC()m9nV85RBmKuusSq()m9DrzKQJcRke7Q1PO6m5M11XJ)mIyTUUCxLvDuaqlavT6mCDsuNvNHRB16Yf18ivRJa4NuRB76Ki82z1z1nFsjpWWKpOUHH16qmasDklOoceBBVDwDIhX0f11HM1PSG6MBglTO0g6IACaWyOhaMQ)CYEgrSwNqZKrrGGuwoUZ)bcjfOC7adOfGQwGaX2248DoF(cG(nNbgqlavTWZLpF1izGg0ngskkjwiFN)DrPn0f14aGXqpamv)5K9mIyToHMjJIabPSCCN)tjcrCWb1izGg0ngskkjwGhC(38(foqiPaLBZlZtjcrCWb1izGg0ngskkjwGhC(38WaHKcuUDGb0cqvlqGyBBmVFHdeskq528wuAdDrnoaym0dat1Fot04HbrYOiqwfs0Gf74o)XUGuMuJKbkomToHMjQ7LbGz()t(8j2ksadO1Gje4W2mtb)Mn0ajlV8D2FxuAdDrnoaym0dat1FoUpYoZB7SeT0WQJ78h7cszsnsgO4W06eAMOUxgaM5)p5ZNyRibmGwdMqGdBZmf87IsBOlQXbaJHEayQ(ZrzbPxtJETinrKb44o)PFZzGadQLagNMiYacpx(8PFZzGadQLagNMiYasd0RvGeWQnOoFM(UO0g6IACaWyOhaMQ)CiRRResBNWU2akkTHUOghamg6bGP6pNCrePGbSDIayuB9akkTHUOghamg6bGP6pNyigrYlHMj5BSIKGawm2XD(dnqYYl)V(nBNgiKuGYTdmGwaQAHNBrPn0f14aGXqpamv)5qaZD7S0uAXa2XD(Rgjd0alWKkRG7qz2z(nF(QrYanWcmPYk4o08))8B(8vJKbAq3yiPOK7qtF(nZo)7IYIYivhNcMuzbI6OWdDrnUOms1f9MXcRMKAG4yDisDCpALkEAe4S6qDDmffpPoU2CXSqADuONR(iqrPn0f14awbtQSaXp55Qpc44o)hOyAuYfTTIz(pYSDqnj0AO3mwkwnj1ajaTrlbbF(QjHwd4hTcK5ldcqB0sqW2b1KqRbicS1zVTnfcqB0sqWEGqsbk3oarGTo7TTPqGaX2248))KpFN0Dq92z8YMHrwJwcb82zsiPgjduEzRgjd0GUXqsrjXc8abITTXmtblkJuDCpAfiZxguhv1XXIGEcquh3BordtxuZtQJN24hbQlxOUhgQd1qDzseTjRtr1zUUY8QJh3ieKc1PO6uwqDX221Pgjd062zDRw3IRRrAD42CXSqAD5bQJ1Hr1zszDiLfqQl22Uo1izGwNrVYvxaxNlbnxnuuAdDrnoGvWKklqq1FoUiKmram6rgGJtej1qe6ptfL2qxuJdyfmPYceu9NtMriifCCN)gfbYQqaZIGEcqKWV5enmDrDaAJwcc20V5mGF0kqMVmi8Czt)MZa(rRaz(YGabITTX5ZuW5SDcJt0V5eefLrQoUhTcK5ld4j1rHDDL5vhIuhfcMeaZQUCxLvD0V5ee1XJBecsbCrPn0f14awbtQSabv)54IqYebWOhzaoorKudrO)mvuAdDrnoGvWKklqq1FozgHGuWXrEdjKuJKbk(Njh35VAsO1a(rRaz(YGa0gTeeSDGaX2248z6t(8DJFsDDLlqY)NjEzRgjd0GUXqsrjXc8abITTXm)zrzKQJ7rRaz(YG6OQoowe0taI64EZjAy6I662UoUO4j1rHDDL5vhyezE1rHEU6Ja1PSmTUCxPSoAOocmjaMfiQBIi15ATaI3rrPn0f14awbtQSabv)5qEU6JaoUZF1KqRb8JwbY8LbbOnAjiyBueiRcbmlc6jarc)Mt0W0f1bOnAjiy7KaPbYZvFeiO7G6TZyZWiRrlHaE7mjKuJKbArzKQJ7rRaz(YG6YnN64yrqpbiQJ7nNOHPlQ5j1rHaZ1vMxDtePoAu)W15m(s1zTihePoicfAbiQd3MlMfsRt8iMUOouuAdDrnoGvWKklqq1FoUiKmram6rgGJtej1qe6ptfL2qxuJdyfmPYceu9NtMriifCCK3qcj1izGI)zYXD(RMeAnGF0kqMVmiaTrlbbBJIazviGzrqpbis43CIgMUOoaTrlbbB1izGg0ngskkjwGzceBBJz7abITTX5ZKZKpFNW4e9BobbVfLrQoUhTcK5ldQJQ64PrGZ4j1XtzaDDigaHScOoRoCBUywiToECJqqkuhzZyP1ztfi1rHEU6Ja1rdtebQJNgb26S32MUOUO0g6IACaRGjvwGGQ)CCrizIay0JmahNisQHi0FMkkTHUOghWkysLfiO6pNmJqqk44o)vtcTgWpAfiZxgeG2OLGGTAsO1aeb26S32McbOnAjiypqiPaLBhGiWwN922uiqGyBBC(mX2LamszdrGPa55QpcWwG0a55QpceiqSTnM5VsvK55HBk2IiHDHw4vV69a]] )

end