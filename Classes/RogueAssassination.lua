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


    spec:RegisterPack( "Assassination", 20200330, [[de164bqisPEevfUKKQK2eQ0NKuLyuiLofsXQqHQxHKAwKsUfke7sOFjP0Wuf1XqswMQqpdvKPrvrxdjW2qHuFtsvX4qfvDojvPwhku6DOIkvZtvW9uL2hQW)KuvQdIeuluvKhIkkMOKQkxevuAJOIk5JOqrJefsWjrfvSsKOxkPQKzIcj6MOqHDsvPHkPkSuKG8uu1uPQQRIcjzRsQI(kQOszSOqcTxb)vIbl1HPSyu6XkmzsUmyZk6ZsYOrrNwLvJcj1RrbZMk3MQSBL(nKHtQoUKQQwoINd10jUUQA7ivFxsX4PQY5Luz9iHMpPy)IoqvW)aVYei47Jp)4ZpZjo9C8XNFKcEKtbEPoDiWRBdgSkiWVMhe4PWySHX3AYH2aVUvNdzQG)bEm6tgqGNPi6ygBT1wDcZpBCG8QfFEFNjhAheBk1IpVrTbE2)5eoNnWg4vMabFF85hF(zoXPNJp(8J(0Nm6aV9fMisGN)84mbEMNsbBGnWRa8iW7JSPWySHX3AYH2SPqOQpKu6JSzkIoMXwBTvNW8ZghiVAXN33zYH2bXMsT4ZBuBsPpYMXWidMzZPN1k7hF(XNtktk9r2CgM2wbygBsPpYMrYMcRuGk76RBWq2ckBfmTVtY2gYH2SDhwIjL(iBgjBke4HOdzlgPcKYnJjL(iBgjBkSsbQSzuHHS5CeWdNnTOVGpfKnAMnwaZjmPjg4DhwWb)d8ybmNWeub)d(svW)apSgRduHNc8dYja5SaVyoyL4EvmfSyogasewJ1bQS5M9a5XIk6OBfC2C8MTpZMB2IrQajkNhueurDq2ms2eWZUfNnhzZOd82qo0g4jFD5tGGe89XG)bEynwhOcpf4Niszb)KGVuf4THCOnWRJqUcbWOpzabj4lNc(h4H1yDGk8uGFqobiNf4nkcKtGiMjb9vGQG)ZjAyYH2iSgRduzZnB2)CgXFwbiZFfe)6zZnB2)CgXFwbiZFfejGNDlo7hYMQiNYMB2ANngxy)ZjOc82qo0g4Rmcbjqqc(6ZG)bEynwhOcpf4Niszb)KGVuf4THCOnWRJqUcbWOpzabj4lfe8pWdRX6av4Pa)GCcqolWlMdwjI)ScqM)kicRX6av2CZM2SjGNDlo7hYMQhZwJMS19(o50DhqY(H3SPkBAYMB2IrQajkNhueurDq2ms2eWZUfNnhz)yG3gYH2aFLriibc8J6goOigPceCWxQcsWxgDW)apSgRduHNc8dYja5SaVyoyLi(Zkaz(RGiSgRduzZnBJIa5eiIzsqFfOk4)CIgMCOncRX6av2CZw7Svijs(6YNar5gmCBv2CZMUroJ1br8TvoOigPcKaVnKdTbEYxx(eiibFRpb)d8WASoqfEkWprKYc(jbFPkWBd5qBGxhHCfcGrFYacsWxoFW)apSgRduHNc8dYja5SaVyoyLi(Zkaz(RGiSgRduzZnBJIa5eiIzsqFfOk4)CIgMCOncRX6av2CZM2STHC0HcSG3b4S5iBQYwJMS1oBXCWkrWpSTv)BnbIWASoqLnnzZnBXivGeLZdkcQOoiBoYMaE2T4S5MnTztap7wC2pKnvC(S1OjBTZgJlS)5euzttG3gYH2aFLriibc8J6goOigPceCWxQcsW36DW)apSgRduHNc8tePSGFsWxQc82qo0g41rixHay0NmGGe8LQNd(h4H1yDGk8uGFqobiNf4fZbReXFwbiZFfeH1yDGkBUzlMdwjc(HTT6FRjqewJ1bQS5MTnKJouGf8oaN9B2uLn3Sz)Zze)zfGm)vqKaE2T4SFiBQICkWBd5qBGVYieKabjibEaJHDa4G)bFPk4FGhwJ1bQWtb(b5eGCwGhwGuvxuopOiOIN5x2CKnvzZnBTZwbS)5mshwfiIf)6zZnBAZw7Svijoq7awHycOktN5bf2pzJYny42QS5MT2zBd5qBCG2bScXeqvMoZdI3wMURIPKTgnzp)oxHadMgPckY5bz)q2vdv0Z8lBAc82qo0g4hODaRqmbuLPZ8GGe89XG)bEynwhOcpf4hKtaYzbEfW(NZiDyvGiw8RNn3SPnBfW(NZyLriibIGFyBR(3AcOYwJMSva7FoJcYVBuyDMcIF9S5M9a5XIk6OBfCubZBCs2p8MnvzRrt2kG9pNr6WQarSib8SBXz)WB2u9C20KTgnzlNhueurDq2p8Mnvph4THCOnWZ6qivbnlctOal4vxqc(YPG)bEynwhOcpf4hKtaYzb(bc5uOA2iDyvGiwKaE2T4SFiBoLTgnzRa2)CgPdRceXIF9S1OjBXivGeLZdkcQOoi7hYMtph4THCOnWx9nI6STGMfJIabjmdsWxFg8pWdRX6av4Pa)GCcqolWpDiejBAZM2SfJubsuopOiOI6GSzKS50Zztt21RzBd5qBzGqofQMnBAYMJSNoeIKnTztB2IrQajkNhueurDq2ms2C65SzKShiKtHQzJ0HvbIyrc4z3IZMMSRxZ2gYH2YaHCkunB20e4THCOnWx9nI6STGMfJIabjmdsWxki4FGhwJ1bQWtb(b5eGCwGhRdoxrmsfi4402cAwyyp6aoBoEZ(XS1OjBIDQcqhwjAkfoEB2CKnJ(5S5MnSaPQUSFi76ZZbEBihAd8t04JbvXOiqobkSG5fKGVm6G)bEynwhOcpf4hKtaYzbESo4CfXivGGJtBlOzHH9Od4S54n7hZwJMSj2PkaDyLOPu44TzZr2m6Nd82qo0g41)KBw3TvfwNHLGe8T(e8pWdRX6av4Pa)GCcqolWZ(NZibgm4amUmrKbe)6zRrt2S)5msGbdoaJltezaLb6VcqIyXgmK9dzt1ZbEBihAd8ctO8xw0FvLjImGGe8LZh8pWBd5qBGNC66oOCBbRBdiWdRX6av4PGe8TEh8pWBd5qBGVgeXPOd3wiagT2oGapSgRduHNcsWxQEo4FGhwJ1bQWtb(b5eGCwGhwGuvx2pKnf8C2CZw7ShiKtHQzJ0HvbIyXVEG3gYH2aVh4Hi1vqZI7povrraZdhKGVurvW)apSgRduHNc8dYja5SaVyKkqIY5bfbvuhK9dztvKcYwJMSPnBAZwmsfirMG5eMr9HKnhzZ5FoBnAYwmsfirMG5eMr9HK9dVz)4Zztt2CZM2STHC0HcSG3b4SFZMQS1OjBXivGeLZdkcQOoiBoY(X6D20KnnzRrt20MTyKkqIY5bfbv0hs5XNZMJS50ZzZnBAZ2gYrhkWcEhGZ(nBQYwJMSfJubsuopOiOI6GS5iBF6ZSPjBAc82qo0g4jGPFBvz6mpah4h1nCqrmsfi4GVufKGe4vW0(oj4FWxQc(h4H1yDGk8uGFqobiNf41oBSaMtycQO5CbEBihAd8mCdgcsW3hd(h4THCOnWJfWCcZapSgRduHNcsWxof8pWdRX6av4PapspWJbjWBd5qBGNUroJ1bbE6M7dbEybsvDrcubB2uNTo6WOfufwhakC2mE21NSRxZM2SFmBgpBSo4CfMgwGSPjWt3iL18GapSaPQUcbQGTmqES3cQGe81Nb)d8WASoqfEkWJ0d8yqc82qo0g4PBKZyDqGNU5(qGhRdoxrmsfi4402cAwyyp6ao7hY(XapDJuwZdc84BRCqrmsfibj4lfe8pWdRX6av4PaVnKdTb(H5CfBihAlUdlb(b5eGCwGhlG5eMGksqvFiW7oSuwZdc8ybmNWeubj4lJo4FGhwJ1bQWtbEBihAd8dZ5k2qo0wChwc8dYja5SapTzRD2I5GvIEgwasXWydJVncRX6av2A0KTcjXkJqqceLBWWTvzttG3DyPSMhe4hkCqc(wFc(h4H1yDGk8uG3gYH2a)WCUInKdTf3HLaV7WsznpiWRqsqc(Y5d(h4H1yDGk8uG3gYH2a)WCUInKdTf3HLaV7WsznpiWRocmKGe8TEh8pWdRX6av4Pa)GCcqolWdlqQQlQG5nojBoEZMkkiBQZMUroJ1brybsvDfcubBzG8yVfubEBihAd8gzylueeHaReKGVu9CW)aVnKdTbEJmSfk6Fhgc8WASoqfEkibFPIQG)bEBihAd8URIPGlmQ)QkpyLapSgRduHNcsWxQEm4FG3gYH2apRvvqZIqUbd4apSgRduHNcsqc86eyG8ynj4FWxQc(h4THCOnWB66U6k6OdJ2apSgRduHNcsW3hd(h4H1yDGk8uGFqobiNf4j2PkaDyLOPu44TzZr2urbbEBihAd8EgHbqvMisrbMWmWRtGbYJ1KcggOvHd8uqqc(YPG)bEBihAd8ybmNWmWdRX6av4PGe81Nb)d8WASoqfEkWVMhe4nkIzAedxMOvkOzrhvdqc82qo0g4nkIzAedxMOvkOzrhvdqcsWxki4FG3gYH2aVoso0g4H1yDGk8uqcsGxDeyib)d(svW)apSgRduHNc8dYja5Sa)a5XIk6OBfC2C8MTpZM6SfZbRevaOdKcwiMyvGxewJ1bQS5MnTzRa2)CgPdRceXIF9S1OjBfW(NZOG87gfwNPG4xpBnAYgwGuvxubZBCs2p8MnTzdlDyrEfDeYvuW8gNKnh13ztB2psbztD20nYzSoiclqQQRqGkyldKh7TGkBAYMMS1OjBTZMUroJ1br8TvoOigPcKSPjBUztB2ANTyoyLi4h22Q)TMarynwhOYwJMShiKtHQzJGFyBR(3AcejGNDloBoY(XSPjWBd5qBGhw6WI8csW3hd(h4H1yDGk8uGhPh4XGe4THCOnWt3iNX6GapDZ9Ha)a5XIk6OBfCubZBCs2CKnvzRrt2WcKQ6IkyEJtY(H3SFKcYM6SPBKZyDqewGuvxHavWwgip2Bbv2A0KT2zt3iNX6Gi(2khueJubsGNUrkR5bb(pgkZZ5asqc(YPG)bEynwhOcpf4hKtaYzbE6g5mwhe)yOmpNdizZnBJIa5eicdMOBRkSotb4iSgRduzZnBSo4CfXivGGJtBlOzHH9Od4S54n7hZM6SPnBfW(NZiDyvGiw8RNnJNnTztv2uNnTzBueiNaryWeDBvH1zkahj2Yq2Vztv20KnnzttG3gYH2a)02cAwyyp6aoibF9zW)apSgRduHNc8dYja5SapDJCgRdIFmuMNZbKS5MnTzZ(NZiZtPGTW6mfGJyXgmKnhVztv9oBnAYM2S1oBDYHiNuxHGeto0Mn3SX6GZveJubcooTTGMfg2JoGZMJ3S9z2uNnTzBueiNarf6Z6GIcHHiXwgYMJSFmBAYM6SXcyoHjOIeu1hYMMSPjWBd5qBGFABbnlmShDahKGVuqW)apSgRduHNc8dYja5SapDJCgRdIFmuMNZbKS5MnwhCUIyKkqWXPTf0SWWE0bC2C8MnNc82qo0g4N2wqZcd7rhWb(rDdhueJubco4lvbj4lJo4FGhwJ1bQWtb(b5eGCwGNUroJ1bXpgkZZ5as2CZM2Sz)ZzK1DRcFki(1ZwJMS1oBXCWkr6WI8kKpMzewJ1bQS5MT2zBueiNarf6Z6GIcHHiSgRduzttG3gYH2apR7wf(uqqc(wFc(h4H1yDGk8uGFqobiNf4PBKZyDq8JHY8CoGKn3SX6GZveJubcooTTGMfg2JoGZ(n7hd82qo0g49(Y5mbc8J6goOigPceCWxQcsWxoFW)apSgRduHNc8dYja5SapDJCgRdIFmuMNZbKaVnKdTbEVVCotGGeKa)qHd(h8LQG)bEynwhOcpf4xZdc8gfXmnIHlt0kf0SOJQbibEBihAd8gfXmnIHlt0kf0SOJQbib(b5eGCwGx7SXcyoHjOIMZLn3S9mSaKIHXggFBHaE2T4SFZ(5S5MnTzpqiNcvZgPdRceXIeWZUfN9d13ztB2deYPq1Srb53nkSotbrc4z3IZMXZgQ))txhurdZKUTaUqmkIiLbIyUSPjBAY(HSP65SPoBQEoBgpBO()pDDqfnmt62c4cXOiIugiI5YMB2ANTcy)ZzKoSkqel(1ZMB2ANTcy)Zzuq(DJcRZuq8RhKGVpg8pWdRX6av4PaVnKdTb(H5CfBihAlUdlb(b5eGCwGx7SXcyoHjOIMZLn3Svijs(6YNar5gmCBv2CZ2ZWcqkggBy8Tfc4z3IZ(n7Nd8UdlL18GapGXWoaCqc(YPG)bEynwhOcpf4hKtaYzbEIDQcqhwjAkfo(1ZMB20MTyKkqIY5bfbvuhK9dzpqESOIo6wbhvW8gNKnJNnvrkiBnAYEG8yrfD0TcoQG5nojBoEZEOx8m)kyDyvzttG3gYH2aVNryauLjIuuGjmd8J6goOigPceCWxQcsWxFg8pWdRX6av4Pa)GCcqolWtStva6WkrtPWXBZMJS50ZzZiztStva6WkrtPWr1NyYH2S5M9a5XIk6OBfCubZBCs2C8M9qV4z(vW6WQc82qo0g49mcdGQmrKIcmHzqc(sbb)d8WASoqfEkWJ0d8yqc82qo0g4PBKZyDqGNU5(qGx7SfZbReXFwbiZFfeH1yDGkBnAYw7SnkcKtGiMjb9vGQG)ZjAyYH2iSgRduzRrt2kKeRmcbjqu377Kt3DajBoYMQS5MnTzJ1bNRigPceCCABbnlmShDaN9dzZOZwJMS1o7bc5uOA2iDBpmZ4xpBAc80nsznpiWthwfiIvWFwbiZFfugOvDYH2Ge8Lrh8pWdRX6av4PapspWJbjWBd5qBGNUroJ1bbE6M7dbETZwmhSsCVkMcwmhdajcRX6av2A0KT2zlMdwjc(HTT6FRjqewJ1bQS1Oj7bc5uOA2i4h22Q)TMarc4z3IZ(HSPGSzKSFmBgpBXCWkrfa6aPGfIjwf4fH1yDGkWt3iL18GapDyvGiwzVkMcwmhdaPmqR6KdTbj4B9j4FGhwJ1bQWtbEKEGhdsG3gYH2apDJCgRdc80n3hc8ANnu))NUoOIgfXmnIHlt0kf0SOJQbizRrt2gfbYjqeZKG(kqvW)5enm5qBewJ1bQS1OjBfW(NZiXOiIugiI5kkG9pNrfQMnBnAYEGqofQMnAyM0TfWfIrrePmqeZfjGNDlo7hYMQNZMB20M9aHCkunBuq(DJcRZuqKaE2T4SFiBQYwJMSva7FoJcYVBuyDMcIF9SPjWt3iL18GapDyvGiwzIwPmqR6KdTbj4lNp4FGhwJ1bQWtb(b5eGCwGx7SXcyoHjOIeu1hYMB2kKejFD5tGOCdgUTkBUzRD2kG9pNr6WQarS4xpBUzt3iNX6GiDyvGiwb)zfGm)vqzGw1jhAZMB20nYzSoishwfiIv2RIPGfZXaqkd0Qo5qB2CZMUroJ1br6WQarSYeTszGw1jhAd82qo0g4PdRceXcsW36DW)apSgRduHNc8dYja5SaVyoyLi4h22Q)TMarynwhOYMB2I5GvI7vXuWI5yairynwhOYMB2dKhlQOJUvWzZXB2d9IN5xbRdRkBUzpqiNcvZgb)W2w9V1eisap7wC2pKnvbEBihAd80T9WmdsWxQEo4FGhwJ1bQWtb(b5eGCwGxmhSsCVkMcwmhdajcRX6av2CZw7SfZbReb)W2w9V1eicRX6av2CZEG8yrfD0TcoBoEZEOx8m)kyDyvzZnBAZwbS)5mshwfiIf)6zRrt2agd7aI0p8H2cAw0bYegYH2iSgRduzttG3gYH2apDBpmZGe8LkQc(h4H1yDGk8uGhPh4XGe4THCOnWt3iNX6GapDZ9HaVrrGCceXmjOVcuf8Fordto0gH1yDGkBUztB2lAlyCH9pNGQigPceC2C8MnvzRrt2yDW5kIrQabhN2wqZcd7rhWz)MnNYMMS5MnTzJXf2)CcQIyKkqWfJfrhk62QaVBK9B2pNTgnzJ1bNRigPceCCABbnlmShDaNnhVzZOZMMapDJuwZdc8yCHUThMzzGw1jhAdsWxQEm4FGhwJ1bQWtb(jIuwWpj4lvbEBihAd86iKRqam6tgqGh8tiwX8q)vc8(KccsWxQ4uW)apSgRduHNc8dYja5SaVyoyLi(Zkaz(RGiSgRduzZnBTZglG5eMGksqvFiBUzpqiNcvZgRmcbjq8RNn3SPnB6g5mwheX4cDBpmZYaTQto0MTgnzRD2gfbYjqeZKG(kqvW)5enm5qBewJ1bQS5MnTzRqsSYieKarcmjaMPX6GS1OjBfW(NZiDyvGiw8RNn3SvijwzecsGOU33jNU7as2p8Mnvztt20Kn3ShipwurhDRGJkyEJtYMJ3SPnBAZMQSPo7hZMXZ2OiqobIyMe0xbQc(pNOHjhAJWASoqLnnzZ4zJ1bNRigPceCCABbnlmShDaNnnzZr9D2(mBUztStva6WkrtPWXBZMJSP6XaVnKdTbE62EyMbj4lv(m4FGhwJ1bQWtb(b5eGCwGxmhSs0ZWcqkggBy8TrynwhOYMB2ANnwaZjmbv0CUS5MTNHfGumm2W4BleWZUfN9dVz)C2CZw7Svijs(6YNarcmjaMPX6GS5MTcjXkJqqcejGNDloBoYMtzZnBAZwbS)5mshwfiIf)6zZnBAZw7SfZbRefKF3OW6mfeH1yDGkBnAYwbS)5mki)UrH1zki(1ZMMS5MnTzRD2agd7aISoesvqZIWekWcE1f9mg1is2A0KTcy)ZzK1HqQcAweMqbwWRU4xpBAYwJMSbmg2bePF4dTf0SOdKjmKdTrynwhOYMMaVnKdTbE62EyMbj4lvuqW)apSgRduHNc8dYja5SaV2zJfWCctqfnNlBUzBueiNarmtc6Ravb)Nt0WKdTrynwhOYMB2kKeRmcbjqKatcGzASoiBUzRqsSYieKarDVVtoD3bKSF4nBQYMB2dKhlQOJUvWrfmVXjzZXB2uf4THCOnWJzAkunEGtfKGVuXOd(h4H1yDGk8uGFqobiNf41oBSaMtycQibv9HS5MT2zRqsSYieKarcmjaMPX6GS5MTcjrYxx(eisap7wC2CKTpZM6S9z2mE2d9IN5xbRdRkWBd5qBGh8dBB1)wtGGe8LQ6tW)apSgRduHNc8dYja5SaVcjrYxx(eik3GHBRYMB20MT2zd1))PRdQOrrmtJy4YeTsbnl6OAas2A0K9aHCkunBKoSkqelsap7wC2CKnvpNnnbEBihAd8cYVBuyDMccsWxQ48b)d8WASoqfEkWpiNaKZc8S)5mY6qiL7JLibSHKTgnzRa2)CgPdRceXIF9aVnKdTbEDKCOnibFPQEh8pWdRX6av4Pa)GCcqolWRa2)CgPdRceXIF9aVnKdTbEwhcPkZpPUGe89XNd(h4H1yDGk8uGFqobiNf4va7FoJ0HvbIyXVEG3gYH2aplqWaHHBRcsW3hPk4FGhwJ1bQWtb(b5eGCwGxbS)5mshwfiIf)6bEBihAd8ZJaSoesfKGVp(yW)apSgRduHNc8dYja5SaVcy)ZzKoSkqel(1d82qo0g4TDayHyUYWCUGe89rof8pWdRX6av4Pa)AEqGVYCWWCoGGlSi0g4THCOnWxzoyyohqWfweAd8dYja5Sa)aHCkunBKoSkqelsap7wC2CKTpPGGe89rFg8pWdRX6av4Pa)AEqG3WmPBlGleJIiszGiMlWBd5qBG3WmPBlGleJIiszGiMlWpiNaKZc8kG9pNrIrrePmqeZvua7FoJkunB2A0KTcy)ZzKoSkqelsap7wC2CKnvpNnJKTpZMXZgQ))txhurJIyMgXWLjALcAw0r1aKS1OjBXivGeLZdkcQOoi7hY(XNdsW3hPGG)bEynwhOcpf4hKtaYzbEpdlaPyySHX3wiGNDlo73SFoBUzRD2kG9pNr6WQarS4xpBUzRD2kG9pNrb53nkSotbXVE2CZM9pNrpWdrQRGMf3FCQIIaMhoQq1SzZnBybsvDz)q2C(NZMB2kKejFD5tGib8SBXzZr2(mWBd5qBGFu3WHecAVrH1zyjWdZjmKYAEqGFu3WHecAVrH1zyjibFFKrh8pWdRX6av4Pa)AEqG39jmaeC5w8Po0hxQUPe4THCOnW7(egacUCl(uh6Jlv3uc8dYja5SaVcy)ZzKoSkqel(1dsW3hRpb)d8WASoqfEkWVMhe4DFSqqFCPc5uWw0DFpRcc82qo0g4DFSqqFCPc5uWw0DFpRcc8dYja5SaVcy)ZzKoSkqel(1dsW3h58b)d8WASoqfEkWpiNaKZc8kG9pNr6WQarS4xpWBd5qBGVYzQZeebx8aL5ChAd8WCcdPSMhe4RCM6mbrWfpqzo3H2Ge89X6DW)apSgRduHNc8dYja5SaVcy)ZzKoSkqel(1d82qo0g4RCM6mbrWfwtvbbEyoHHuwZdc8votDMGi4cRPQGGe8Ltph8pWBd5qBG)JHYjGhoWdRX6av4PGeKaVcjb)d(svW)apSgRduHNc8i9apgKaVnKdTbE6g5mwhe4PBUpe41jhICsDfcsm5qB2CZgRdoxrmsfi4402cAwyyp6aoBoYMtzZnBAZwHKyLriibIeWZUfN9dzpqiNcvZgRmcbjqu9jMCOnBnAYwhDy0cQcRdafoBoYMcYMMapDJuwZdc8ygo9YOUHdkvgHGeiibFFm4FGhwJ1bQWtbEKEGhdsG3gYH2apDJCgRdc80n3hc86KdroPUcbjMCOnBUzJ1bNRigPceCCABbnlmShDaNnhzZPS5MnTzRa2)CgfKF3OW6mfe)6zRrt20MTo6WOfufwhakC2CKnfKn3S1oBJIa5eiIhWkf0SW6qivewJ1bQSPjBAc80nsznpiWJz40lJ6goOq(6YNabj4lNc(h4H1yDGk8uGhPh4XGe4THCOnWt3iNX6GapDZ9HaVcy)ZzKoSkqel(1ZMB20MTcy)Zzuq(DJcRZuq8RNTgnz7zybifdJnm(2cb8SBXzZr2pNnnzZnBfsIKVU8jqKaE2T4S5i7hd80nsznpiWJz40lKVU8jqqc(6ZG)bEynwhOcpf4hKtaYzbEXCWkrWpSTv)BnbIWASoqLn3SPnBAZEG8yrfD0TcoBoEZEOx8m)kyDyvzZn7bc5uOA2i4h22Q)TMarc4z3IZ(HSPkBAYwJMSPnBTZwUbd3wLn3SPnB58GS5iBQEoBnAYEG8yrfD0TcoBoEZ(XSPjBAYMMaVnKdTbEYxx(eiibFPGG)bEynwhOcpf4Niszb)KGVuf4THCOnWRJqUcbWOpzabj4lJo4FGhwJ1bQWtb(b5eGCwGN2S1oBXCWkr8NvaY8xbrynwhOYwJMS1oBAZEGqofQMns32dZm(1ZMB2deYPq1Sr6WQarSib8SBXz)WB2(mBAYMMS5M9a5XIk6OBfCubZBCs2C8MnvztD2CkBgpBAZ2OiqobIyMe0xbQc(pNOHjhAJWASoqLn3ShiKtHQzJ0T9WmJF9SPjBUztGjbWmnwhKn3SPnBDVVtoD3bKSF4nBQYwJMSjGNDlo7hEZwUbdf58GS5MnwhCUIyKkqWXPTf0SWWE0bC2C8MnNYM6SnkcKtGiMjb9vGQG)ZjAyYH2iSgRduztt2CZM2S1oBWpSTv)BnbuzRrt2eWZUfN9dVzl3GHICEq2mE2pMn3SX6GZveJubcooTTGMfg2JoGZMJ3S5u2uNTrrGCceXmjOVcuf8Fordto0gH1yDGkBAYMB2ANngxy)ZjOYMB20MTyKkqIY5bfbvuhKnJKnb8SBXztt2CKTpZMB20MTNHfGumm2W4BleWZUfN9B2pNTgnzRD2Yny42QS5MTrrGCceXmjOVcuf8Fordto0gH1yDGkBAc82qo0g4Rmcbjqqc(wFc(h4H1yDGk8uGFIiLf8tc(svG3gYH2aVoc5keaJ(KbeKGVC(G)bEynwhOcpf4hKtaYzbETZMUroJ1brmdNEzu3WbLkJqqcKn3SPnBTZwmhSse)zfGm)vqewJ1bQS1OjBTZM2ShiKtHQzJ0T9WmJF9S5M9aHCkunBKoSkqelsap7wC2p8MTpZMMSPjBUzpqESOIo6wbhvW8gNKnhVztv2uNnNYMXZM2SnkcKtGiMjb9vGQG)ZjAyYH2iSgRduzZn7bc5uOA2iDBpmZ4xpBAYMB2eysamtJ1bzZnBAZw377Kt3Daj7hEZMQS1OjBc4z3IZ(H3SLBWqropiBUzJ1bNRigPceCCABbnlmShDaNnhVzZPSPoBJIa5eiIzsqFfOk4)CIgMCOncRX6av20Kn3SPnBTZg8dBB1)wtav2A0Knb8SBXz)WB2YnyOiNhKnJN9JzZnBSo4CfXivGGJtBlOzHH9Od4S54nBoLn1zBueiNarmtc6Ravb)Nt0WKdTrynwhOYMMS5MT2zJXf2)CcQS5MnTzlgPcKOCEqrqf1bzZiztap7wC20Knhzt1JzZnBAZ2ZWcqkggBy8Tfc4z3IZ(n7NZwJMS1oB5gmCBv2CZ2OiqobIyMe0xbQc(pNOHjhAJWASoqLnnbEBihAd8vgHGeiWpQB4GIyKkqWbFPkibFR3b)d8WASoqfEkWpiNaKZc8yDW5kIrQabNnhVz)y2CZMaE2T4SFi7hZM6SPnBSo4CfXivGGZMJ3SPGSPjBUzpqESOIo6wbNnhVz7ZaVnKdTb(b58WOTiGNoGLGe8LQNd(h4H1yDGk8uGFqobiNf41oB6g5mwheXmC6fYxx(eiBUzpqESOIo6wbNnhVz7ZS5MnbMeaZ0yDq2CZM2S19(o50DhqY(H3SPkBnAYMaE2T4SF4nB5gmuKZdYMB2yDW5kIrQabhN2wqZcd7rhWzZXB2CkBQZ2OiqobIyMe0xbQc(pNOHjhAJWASoqLnnzZnBAZw7Sb)W2w9V1eqLTgnztap7wC2p8MTCdgkY5bzZ4z)y2CZgRdoxrmsfi4402cAwyyp6aoBoEZMtztD2gfbYjqeZKG(kqvW)5enm5qBewJ1bQSPjBUzlgPcKOCEqrqf1bzZiztap7wC2CKTpd82qo0g4jFD5tGGe8LkQc(h4H1yDGk8uGFqobiNf41oB6g5mwheXmC6LrDdhuiFD5tGS5MT2zt3iNX6GiMHtVq(6YNazZn7bYJfv0r3k4S54nBFMn3SjWKayMgRdYMB20MTU33jNU7as2p8MnvzRrt2eWZUfN9dVzl3GHICEq2CZgRdoxrmsfi4402cAwyyp6aoBoEZMtztD2gfbYjqeZKG(kqvW)5enm5qBewJ1bQSPjBUztB2ANn4h22Q)TMaQS1OjBc4z3IZ(H3SLBWqropiBgp7hZMB2yDW5kIrQabhN2wqZcd7rhWzZXB2CkBQZ2OiqobIyMe0xbQc(pNOHjhAJWASoqLnnzZnBXivGeLZdkcQOoiBgjBc4z3IZMJS9zG3gYH2ap5RlFce4h1nCqrmsfi4GVufKGeKapDGGp0g89XNF85N5eNEoWxJr2BRWbEo3OWuiF5C8LXKXMD2(ZeY(80rej7jIKD9cGXWoaC9s2eO()pcOYgJ8GSTVG8mbuzpyABfGJjLmkVfY(rgB2Cg0shicOYUEb8dBB1)wtavKrX6LSfu21lkG9pNrgfJGFyBR(3AcOQxYMwQ8JMyszsjNJNoIiGk76t22qo0MT7WcoMug41jO55GaVpYMcJXggFRjhAZMcHQ(qsPpYMPi6ygBT1wDcZpBCG8QfFEFNjhAheBk1IpVrTjL(iBgdJmyMnNEwRSF85hFoPmP0hzZzyABfGzSjL(iBgjBkSsbQSRVUbdzlOSvW0(ojBBihAZ2DyjMu6JSzKSPqGhIoKTyKkqk3mMu6JSzKSPWkfOYMrfgYMZrapC20I(c(uq2Oz2ybmNWKMyszsPpYMZ6hm(cOYMfMicK9a5XAs2Sq1T4y2u4Xa0fC2lAzeMgXB(DzBd5qloB06QlMu6JSTHCOfh1jWa5XAY70zygsk9r22qo0IJ6eyG8ynH63ATFLhSIjhAtk9r22qo0IJ6eyG8ynH63ANiKkP0hzZVMoMjsYMyNkB2)CcQSXIj4SzHjIazpqESMKnluDloBBvzRtagrhjYTvzF4SvOfIjL(iBBihAXrDcmqESMq9BT410XmrsblMGtkTHCOfh1jWa5XAc1V1A66U6k6OdJ2KsBihAXrDcmqESMq9BTEgHbqvMisrbMWulDcmqESMuWWaTk8lfO1nFj2PkaDyLOPu44TCqffKuAd5qloQtGbYJ1eQFRflG5eMjL2qo0IJ6eyG8ynH63A)yOCc4P1AEWRrrmtJy4YeTsbnl6OAassPnKdT4OobgipwtO(TwDKCOnPmP0hzZz9dgFbuzd0bsDzlNhKTWeY2gcIK9HZ2OBNZyDqmP0hztHaSaMtyM9nZwhHXhRdYM2fLn9VBbIX6GSHf8oaN9TzpqESMqtsPnKdT4xgUbdADZxTXcyoHjOIMZLuAd5qlM63AXcyoHzsPnKdTyQFRLUroJ1bATMh8clqQQRqGkyldKh7TGsl6M7dVWcKQ6IeOcwQ1rhgTGQW6aqHz86t9kTpY4yDW5kmnSa0KuAd5qlM63APBKZyDGwR5bV4BRCqrmsfiAr3CF4fRdoxrmsfi4402cAwyyp6a(HhtkTHCOft9BTdZ5k2qo0wChw0Anp4flG5eMGsRB(IfWCctqfjOQpKuAd5qlM63AhMZvSHCOT4oSO1AEW7qH16MV0QTyoyLONHfGumm2W4BJWASoqPrJcjXkJqqceLBWWTv0KuAd5qlM63AhMZvSHCOT4oSO1AEWRcjjL2qo0IP(T2H5CfBihAlUdlATMh8QocmKKsBihAXu)wRrg2cfbriWkADZxybsvDrfmVXjC8sffqnDJCgRdIWcKQ6keOc2Ya5XElOskTHCOft9BTgzylu0)omKuAd5qlM63ADxftbxyu)vvEWkjL2qo0IP(TwwRQGMfHCdgWjLjL(iBodc5uOAwCsPnKdT44qHF)yOCc4P1AEWRrrmtJy4YeTsbnl6OAaIw38vBSaMtycQO5CC9mSaKIHXggFBHaE2T43N5s7aHCkunBKoSkqelsap7w8d130oqiNcvZgfKF3OW6mfejGNDlMXH6))01bv0WmPBlGleJIiszGiMJgAEGQNPMQNzCO()pDDqfnmt62c4cXOiIugiI54QTcy)ZzKoSkqel(15QTcy)Zzuq(DJcRZuq8RNuAd5qloouyQFRDyoxXgYH2I7WIwR5bVagd7aWADZxTXcyoHjOIMZXvHKi5RlFceLBWWTvC9mSaKIHXggFBHaE2T43Ntk9r2CoZSnLcNTrGS)6ALnEpDiBHjKnAHSR5eMz7q1ayjB)9V(fZMrfgYUgMWMTQUBRYEAybizlmTnBot9iBfmVXjzJizxZjmrFjBBRlBot9iMuAd5qloouyQFR1ZimaQYerkkWeMAnQB4GIyKkqWVuP1nFj2PkaDyLOPu44xNlTIrQajkNhueurDWddKhlQOJUvWrfmVXjmovrkqJMbYJfv0r3k4OcM34eoEh6fpZVcwhwfnjL(iBoNz2lkBtPWzxZ5CzRoi7AoH5TzlmHSxWpjBo9mwRS)yiBgJz9lB0MnlcJZUMtyI(s22wx2CM6rmP0gYHwCCOWu)wRNryauLjIuuGjm16MVe7ufGoSs0ukC8wo40ZmcXovbOdRenLchvFIjhA5oqESOIo6wbhvW8gNWX7qV4z(vW6WQsk9r21tyvGiw2ou1nmx2d0Qo5qR5WzZAyqLnAZE8jeyLSX6WiP0gYHwCCOWu)wlDJCgRd0Anp4LoSkqeRG)ScqM)kOmqR6KdTAr3CF4vBXCWkr8NvaY8xbrynwhO0OrBJIa5eiIzsqFfOk4)CIgMCOncRX6aLgnkKeRmcbjqu377Kt3DaHdQ4slwhCUIyKkqWXPTf0SWWE0b8dmAnA0EGqofQMns32dZm(1PjP0gYHwCCOWu)wlDJCgRd0Anp4LoSkqeRSxftblMJbGugOvDYHwTOBUp8QTyoyL4EvmfSyogasewJ1bknA0wmhSse8dBB1)wtGiSgRduA0mqiNcvZgb)W2w9V1eisap7w8duaJ8iJlMdwjQaqhifSqmXQaViSgRdujL2qo0IJdfM63APBKZyDGwR5bV0nYzSoqR18Gx6WQarSYeTszGw1jhA1IU5(WR2q9)F66GkAueZ0igUmrRuqZIoQgGOrJrrGCceXmjOVcuf8Fordto0gH1yDGsJgfW(NZiXOiIugiI5kkG9pNrfQMvJMbc5uOA2OHzs3waxigfrKYarmxKaE2T4hO6zU0oqiNcvZgfKF3OW6mfejGNDl(bQ0OrbS)5mki)UrH1zki(1PjP0gYHwCCOWu)wlDyvGiMw38vBSaMtycQibv9bUkKejFD5tGOCdgUTIR2kG9pNr6WQarS4xNlDJCgRdI0HvbIyf8NvaY8xbLbAvNCOLlDJCgRdI0HvbIyL9QykyXCmaKYaTQto0YLUroJ1br6WQarSYeTszGw1jhAtk9r21tBpmZSR5eMzZz9dxLn1z77vXuWI5yaim2Szmm)oVVx2CM6r22QYMZ6hUkBcyQ6YEIizVGFs2mMCM6xsPnKdT44qHP(Tw62EyMADZxXCWkrWpSTv)BnbIWASoqXvmhSsCVkMcwmhdajcRX6af3bYJfv0r3kyoEh6fpZVcwhwf3bc5uOA2i4h22Q)TMarc4z3IFGQKsFKD902dZm7AoHz2(EvmfSyogas2uNTVOS5S(HRySzZyy(DEFVS5m1JSTvLD9ewfiIL9xpBA)RdW4S)4BRYUEIQh0KuAd5qloouyQFRLUThMPw38vmhSsCVkMcwmhdajcRX6afxTfZbReb)W2w9V1eicRX6af3bYJfv0r3kyoEh6fpZVcwhwfxAva7FoJ0HvbIyXVUgnagd7aI0p8H2cAw0bYegYH2iSgRdu0Ku6JS5bi7535YEG88GvYgTzZueDmJT2ARoH5NnoqE1sHm6WYe5ucJ4pNPwkeQ6d1wZXWvlfgJnm(wto0Yiu46bJsgHcbyWidMXKsBihAXXHct9BT0nYzSoqR18GxmUq32dZSmqR6KdTAr3CF41OiqobIyMe0xbQc(pNOHjhAJWASoqXL2fTfmUW(NtqveJubcMJxQ0ObRdoxrmsfi4402cAwyyp6a(Lt0WLwmUW(NtqveJubcUySi6qr3wf4DJ3N1ObRdoxrmsfi4402cAwyyp6aMJxgnnjL2qo0IJdfM63A1rixHay0NmaTMiszb)KxQ0c8tiwX8q)vE9jfKuAd5qloouyQFRLUThMPw38vmhSse)zfGm)vqewJ1bkUAJfWCctqfjOQpWDGqofQMnwzecsG4xNlT0nYzSoiIXf62EyMLbAvNCOvJgTnkcKtGiMjb9vGQG)ZjAyYH2iSgRduCPvHKyLriibIeysamtJ1bA0Oa2)CgPdRceXIFDUkKeRmcbjqu377Kt3Da5HxQOHgUdKhlQOJUvWrfmVXjC8slTur9JmUrrGCceXmjOVcuf8Fordto0gH1yDGIgghRdoxrmsfi4402cAwyyp6aMgoQV9jxIDQcqhwjAkfoElhu9ysPpYUEA7HzMDnNWmBgddlajBkmgB4BzSz7lkBSaMtyMTTQSxu22qo6q2mgu4Sz)ZPwztH(6YNazVij7BZMatcGzMnX2kqRSvFYTvzxpHvbIyu7)tu)es4Szt7FDagN9hFBv21tu9GMKsBihAXXHct9BT0T9Wm16MVI5GvIEgwasXWydJVncRX6afxTXcyoHjOIMZX1ZWcqkggBy8Tfc4z3IF49zUARqsK81LpbIeysamtJ1bCvijwzecsGib8SBXCWjU0Qa2)CgPdRceXIFDU0QTyoyLOG87gfwNPGiSgRduA0Oa2)CgfKF3OW6mfe)60WLwTbmg2bezDiKQGMfHjuGf8Ql6zmQrenAua7FoJSoesvqZIWekWcE1f)60OrdGXWoGi9dFOTGMfDGmHHCOncRX6afnjL(iBEMMcvJh4uzprKS5zsqFfOYM)pNOHjhAtkTHCOfhhkm1V1IzAkunEGtP1nF1glG5eMGkAohxJIa5eiIzsqFfOk4)CIgMCOncRX6afxfsIvgHGeisGjbWmnwhWvHKyLriibI6EFNC6Udip8sf3bYJfv0r3k4OcM34eoEPkP0hzZz9dBB1)wtGSRHjSzVijBSaMtycQSTvLnlsyMnf6RlFcKTTQSzmncbjq2gbY(RN9erY2H2QSHf9RygtkTHCOfhhkm1V1c(HTT6FRjGw38vBSaMtycQibv9bUARqsSYieKarcmjaMPX6aUkKejFD5tGib8SBXC4tQ9jJp0lEMFfSoSQKsBihAXXHct9BTcYVBuyDMc06MVkKejFD5tGOCdgUTIlTAd1))PRdQOrrmtJy4YeTsbnl6OAaIgndeYPq1Sr6WQarSib8SBXCq1Z0KuAd5qloouyQFRvhjhA16MVS)5mY6qiL7JLibSHOrJcy)ZzKoSkqel(1tkTHCOfhhkm1V1Y6qivz(j1P1nFva7FoJ0HvbIyXVEsPnKdT44qHP(TwwGGbcd3wP1nFva7FoJ0HvbIyXVEsPnKdT44qHP(T25rawhcP06MVkG9pNr6WQarS4xpP0gYHwCCOWu)wRTdaleZvgMZP1nFva7FoJ0HvbIyXVEsPnKdT44qHP(T2pgkNaEATMh8wzoyyohqWfweA16MVdeYPq1Sr6WQarSib8SBXC4tkiP0gYHwCCOWu)w7hdLtapTwZdEnmt62c4cXOiIugiI506MVkG9pNrIrrePmqeZvua7FoJkunRgnkG9pNr6WQarSib8SBXCq1ZmIpzCO()pDDqfnkIzAedxMOvkOzrhvdq0Ormsfir58GIGkQdE4XNtkTHCOfhhkm1V1(Xq5eWtlyoHHuwZdEh1nCiHG2BuyDgw06MVEgwasXWydJVTqap7w87ZC1wbS)5mshwfiIf)6C1wbS)5mki)UrH1zki(15Y(NZOh4Hi1vqZI7povrraZdhvOAwUWcKQ6EGZ)mxfsIKVU8jqKaE2Tyo8zsPnKdT44qHP(T2pgkNaEATMh86(egacUCl(uh6Jlv3u06MVkG9pNr6WQarS4xpP0gYHwCCOWu)w7hdLtapTwZdEDFSqqFCPc5uWw0DFpRc06MVkG9pNr6WQarS4xpP0gYHwCCOWu)w7hdLtapTG5egsznp4TYzQZeebx8aL5ChA16MVkG9pNr6WQarS4xpP0gYHwCCOWu)w7hdLtapTG5egsznp4TYzQZeebxynvfO1nFva7FoJ0HvbIyXVEsPpYU(bt77KSNMZXAdgYEIiz)XgRdY(eWdZyZMrfgYgTzpqiNcvZgtkTHCOfhhkm1V1(Xq5eWdNuMu6JSRFhbgs2kZZQGSn2ZDYb4KsFKnNDPdlYlBtY2NuNnTua1zxZjmZU(Xtt2CM6rmBohppqDMaU6YgTz)i1zlgPceSwzxZjmZUEcRceX0kBej7AoHz2()eN7zJeMaPMddzxJDs2tejBmYdYgwGuvxmBkSdJYUg7KSVz2Cw)WvzpqESOSpC2dK3Tvz)1JjL2qo0IJQJad5fw6WI806MVdKhlQOJUvWC86tQfZbRevaOdKcwiMyvGxewJ1bkU0Qa2)CgPdRceXIFDnAua7FoJcYVBuyDMcIFDnAGfiv1fvW8gN8WlTWshwKxrhHCffmVXjCuFt7Jua10nYzSoiclqQQRqGkyldKh7TGIgA0OrB6g5mwheX3w5GIyKkqOHlTAlMdwjc(HTT6FRjqewJ1bknAgiKtHQzJGFyBR(3AcejGNDlMJhPjP0gYHwCuDeyiu)wlDJCgRd0Anp49JHY8CoGOfDZ9H3bYJfv0r3k4OcM34eoOsJgybsvDrfmVXjp8(ifqnDJCgRdIWcKQ6keOc2Ya5XElO0OrB6g5mwheX3w5GIyKkqsk9r2CUDcZS5SdMOBRY(jNPaSwzZ5Y2SrZSRV2JoGZ2KSFK6SfJubcwRSrKS5eJ4tQZwmsfi4SRHjSzxpHvbIyzF4S)6jL2qo0IJQJadH63AN2wqZcd7rhWADZx6g5mwhe)yOmpNdiCnkcKtGimyIUTQW6mfGJWASoqXfRdoxrmsfi4402cAwyyp6aMJ3hPMwfW(NZiDyvGiw8RZ40sf10AueiNaryWeDBvH1zkahj2YWlv0qdnjL(iBox2MnAMD91E0bC2MKnv1BQZgl2GbC2Oz2mkCkfSz)KZuaoBejBRYUflz7tQZMwkG6SR5eMzx)qFwhKD9dHbAYwmsfi4ysPnKdT4O6iWqO(T2PTf0SWWE0bSw38LUroJ1bXpgkZZ5acxAz)ZzK5PuWwyDMcWrSydg44LQ6Tgn0QTo5qKtQRqqIjhA5I1bNRigPceCCABbnlmShDaZXRpPMwJIa5eiQqFwhuuimej2Yahpsd1ybmNWeurcQ6d0qtsPpYMZLTzJMzxFThDaNTGY201D1LD9dmLRUSRhOdJ2SVz23Ad5OdzJ2STTUSfJubs2MKnNYwmsfi4ysPnKdT4O6iWqO(T2PTf0SWWE0bSwJ6goOigPce8lvADZx6g5mwhe)yOmpNdiCX6GZveJubcooTTGMfg2JoG54LtjL2qo0IJQJadH63AzD3QWNc06MV0nYzSoi(XqzEohq4sl7FoJSUBv4tbXVUgnAlMdwjshwKxH8XmJWASoqXvBJIa5eiQqFwhuuimeH1yDGIMKsFKT)glJWy8LZzcKTGY201D1LD9dmLRUSRhOdJ2Snj7hZwmsfi4KsBihAXr1rGHq9BTEF5CMaAnQB4GIyKkqWVuP1nFPBKZyDq8JHY8CoGWfRdoxrmsfi4402cAwyyp6a(9XKsBihAXr1rGHq9BTEF5CMaADZx6g5mwhe)yOmpNdijLjL(i76N5zvq2i6ajB58GSn2ZDYb4KsFKnJYZ7KSzmncbjaoB0M9IwgrNCEeJux2IrQabN9erYwyczRtoe5K6YMGeto0M9nZMcOoBwhakC2gbY2CeWu1L9xpP0gYHwCuHKx6g5mwhO1AEWlMHtVmQB4GsLriib0IU5(WRo5qKtQRqqIjhA5I1bNRigPceCCABbnlmShDaZbN4sRcjXkJqqcejGNDl(Hbc5uOA2yLriibIQpXKdTA0OJomAbvH1bGcZbfqtsPpYMr55Ds2uOVU8jaoB0M9IwgrNCEeJux2IrQabN9erYwyczRtoe5K6YMGeto0M9nZMcOoBwhakC2gbY2CeWu1L9xpP0gYHwCuHeQFRLUroJ1bATMh8Iz40lJ6goOq(6YNaAr3CF4vNCiYj1viiXKdTCX6GZveJubcooTTGMfg2JoG5GtCPvbS)5mki)UrH1zki(11OHwD0HrlOkSoauyoOaUABueiNar8awPGMfwhcPIWASoqrdnjL(iBgLN3jztH(6YNa4SVz21tyvGig1(J87gz)KZuqTmggwas2uym2W4BZ(Wz)1Z2wv21azZ0Odz)i1zJHbAv4SDWuYgTzlmHSPqFD5tGSRFi)tkTHCOfhviH63APBKZyDGwR5bVygo9c5RlFcOfDZ9HxfW(NZiDyvGiw8RZLwfW(NZOG87gfwNPG4xxJgpdlaPyySHX3wiGNDlMJNPHRcjrYxx(eisap7wmhpMu6JS51HXzUSPqFD5tGSXG81ZEIizZz9dxLuAd5qloQqc1V1s(6YNaADZxXCWkrWpSTv)BnbIWASoqXLwAhipwurhDRG54DOx8m)kyDyvChiKtHQzJGFyBR(3AcejGNDl(bQOrJgA1wUbd3wXLw58aoO6znAgipwurhDRG549rAOHMKsFKnJPriibY(RZaa6ALT5WOSfYb4Sfu2FmK9jzB4STSX6W4mx2vWcetqKSNis2ctiBNHLS5m1JSzHjIazBzpV9WmbssPnKdT4Ocju)wRoc5keaJ(KbO1erkl4N8svsPnKdT4Ocju)wBLriib06MV0QTyoyLi(Zkaz(RGiSgRduA0OnTdeYPq1Sr62EyMXVo3bc5uOA2iDyvGiwKaE2T4hE9jn0WDG8yrfD0TcoQG5noHJxQOMtmoTgfbYjqeZKG(kqvW)5enm5qBewJ1bkUdeYPq1Sr62EyMXVonCjWKayMgRd4sRU33jNU7aYdVuPrdb8SBXp8k3GHICEaxSo4CfXivGGJtBlOzHH9OdyoE5e1gfbYjqeZKG(kqvW)5enm5qBewJ1bkA4sR2GFyBR(3AcO0OHaE2T4hELBWqropGXFKlwhCUIyKkqWXPTf0SWWE0bmhVCIAJIa5eiIzsqFfOk4)CIgMCOncRX6afnC1gJlS)5euCPvmsfir58GIGkQdyec4z3IPHdFYLwpdlaPyySHX3wiGNDl(9znA0wUbd3wX1OiqobIyMe0xbQc(pNOHjhAJWASoqrtsPnKdT4Ocju)wRoc5keaJ(KbO1erkl4N8svsPnKdT4Ocju)wBLriib0Au3WbfXivGGFPsRB(QnDJCgRdIygo9YOUHdkvgHGeGlTAlMdwjI)ScqM)kicRX6aLgnAt7aHCkunBKUThMz8RZDGqofQMnshwfiIfjGNDl(HxFsdnChipwurhDRGJkyEJt44LkQ5eJtRrrGCceXmjOVcuf8Fordto0gH1yDGI7aHCkunBKUThMz8RtdxcmjaMPX6aU0Q79DYP7oG8WlvA0qap7w8dVYnyOiNhWfRdoxrmsfi4402cAwyyp6aMJxorTrrGCceXmjOVcuf8Fordto0gH1yDGIgU0Qn4h22Q)TMaknAiGNDl(Hx5gmuKZdy8h5I1bNRigPceCCABbnlmShDaZXlNO2OiqobIyMe0xbQc(pNOHjhAJWASoqrdxTX4c7FobfxAfJubsuopOiOI6agHaE2TyA4GQh5sRNHfGumm2W4BleWZUf)(SgnAl3GHBR4AueiNarmtc6Ravb)Nt0WKdTrynwhOOjP0hzZziNhgTz7p4PdyjB06QlB0MT33jNUdYwmsfi4SnjBFsD2CM6r21We2Sj)DVTkB0xY(2SFeNnTF9Sfu2(mBXivGGPjBejBoHZMwkG6SfJubcMMKsBihAXrfsO(T2b58WOTiGNoGfTU5lwhCUIyKkqWC8(ixc4z3IF4rQPfRdoxrmsfiyoEPaA4oqESOIo6wbZXRptk9r21xaON9xpBk0xx(eiBtY2NuNnAZ2CUSfJubcoBARHjSz7o63wLTdTvzdl6xXmBBvzVijB8A6yMiHMKsBihAXrfsO(TwYxx(eqRB(QnDJCgRdIygo9c5RlFcWDG8yrfD0TcMJxFYLatcGzASoGlT6EFNC6Udip8sLgneWZUf)WRCdgkY5bCX6GZveJubcooTTGMfg2JoG54LtuBueiNarmtc6Ravb)Nt0WKdTrynwhOOHlTAd(HTT6FRjGsJgc4z3IF4vUbdf58ag)rUyDW5kIrQabhN2wqZcd7rhWC8YjQnkcKtGiMjb9vGQG)ZjAyYH2iSgRdu0Wvmsfir58GIGkQdyec4z3I5WNjL2qo0IJkKq9BTKVU8jGwJ6goOigPce8lvADZxTPBKZyDqeZWPxg1nCqH81Lpb4QnDJCgRdIygo9c5RlFcWDG8yrfD0TcMJxFYLatcGzASoGlT6EFNC6Udip8sLgneWZUf)WRCdgkY5bCX6GZveJubcooTTGMfg2JoG54LtuBueiNarmtc6Ravb)Nt0WKdTrynwhOOHlTAd(HTT6FRjGsJgc4z3IF4vUbdf58ag)rUyDW5kIrQabhN2wqZcd7rhWC8YjQnkcKtGiMjb9vGQG)ZjAyYH2iSgRdu0Wvmsfir58GIGkQdyec4z3I5WNjLjL(iBolgd7aWjL2qo0IJagd7aWVd0oGviMaQY0zEGw38fwGuvxuopOiOIN5hhuXvBfW(NZiDyvGiw8RZLwTvijoq7awHycOktN5bf2pzJYny42kUABd5qBCG2bScXeqvMoZdI3wMURIPOrZ87CfcmyAKkOiNh8q1qf9m)OjP0hztHD1y1HZ(JHSFYHqQSR5eMzxpHvbIyz)1JzZOaYPYEIizZz9dBB1)wtGy2mQWq21CcZS9)PS)6zZctebY2YEE7HzcKSnC2o0wLTHZ(KSj)fN9erYMQNXzR(KBRYUEcRceXIjL2qo0IJagd7aWu)wlRdHuf0SimHcSGxDADZxfW(NZiDyvGiw8RZLwWpSTv)BnbuXkJqqcOrJcy)Zzuq(DJcRZuq8RZDG8yrfD0TcoQG5no5HxQ0OrbS)5mshwfiIfjGNDl(HxQEMgnAKZdkcQOo4HxQEoP0hztHfb80LSfu2M7Q2Szm)grD2MDnNWm76jSkqelBdNTdTvzB4Spj7AqB9IKnbWFNK9Tz7q4BRY2YE(DogHU5(q2ddlzJOdKSfMq2eWZU92QSvFIjhAZgnZwyczpVkMssPnKdT4iGXWoam1V1w9nI6STGMfJIabjm16MVdeYPq1Sr6WQarSib8SBXpWjnAua7FoJ0HvbIyXVUgnIrQajkNhueurDWdC65KsBihAXraJHDayQFRT6Be1zBbnlgfbcsyQ1nFNoeIqlTIrQajkNhueurDaJWPNPPEDGqofQMLgoMoeIqlTIrQajkNhueurDaJWPNzKbc5uOA2iDyvGiwKaE2TyAQxhiKtHQzPjP0gYHwCeWyyhaM63ANOXhdQIrrGCcuybZtRB(I1bNRigPceCCABbnlmShDaZX7JA0qStva6WkrtPWXB5Gr)mxybsvDpuFEoP0gYHwCeWyyhaM63A1)KBw3TvfwNHfTU5lwhCUIyKkqWXPTf0SWWE0bmhVpQrdXovbOdRenLchVLdg9ZjL2qo0IJagd7aWu)wRWek)Lf9xvzIidqRB(Y(NZibgm4amUmrKbe)6A0W(NZibgm4amUmrKbugO)kajIfBWWdu9CsPnKdT4iGXWoam1V1soDDhuUTG1TbKuAd5qlocymSdat9BT1GiofD42cbWO12bKuAd5qlocymSdat9BTEGhIuxbnlU)4uffbmpSw38fwGuv3duWZC1EGqofQMnshwfiIf)6jL(iBgfqov2uiW0VTkBoxoZdWzprKSb)GXxGSj2wbzJizZW5CzZ(NtSwzFZS1ry8X6Gy2uyxnwD4SfsDzlOSRajBHjKTdvdGLShiKtHQzZM1WGkB0MTr3oNX6GSHf8oahtkTHCOfhbmg2bGP(Twcy63wvMoZdWAnQB4GIyKkqWVuP1nFfJubsuopOiOI6GhOksbA0qlTIrQajYemNWmQpeo48pRrJyKkqImbZjmJ6d5H3hFMgU0Ad5OdfybVdWVuPrJyKkqIY5bfbvuhWXJ1BAOrJgAfJubsuopOiOI(qkp(mhC6zU0Ad5OdfybVdWVuPrJyKkqIY5bfbvuhWHp9jn0KuMu6JS5fWCctqLnfEihAXjL(iBFVkMyXCmaKSrB2u5pJnB(10Xmrs2uOVU8jqsPnKdT4iwaZjmb1l5RlFcO1nFfZbRe3RIPGfZXaqIWASoqXDG8yrfD0TcMJxFYvmsfir58GIGkQdyec4z3I5GrNu6JS5)ScqM)kiBQZMNjb9vGkB()CIgMCOLXMnNDXFcKDnq2FmKnAHSRCiwZLTGY201D1LnJPriibYwqzlmHS9SBZwmsfizFZSpj7dN9IKSXRPJzIKSRdeTYgJY2CUSrctGKTNDB2IrQajBJ9CNCaoBDcAEsmP0gYHwCelG5eMGI63A1rixHay0NmaTMiszb)KxQskTHCOfhXcyoHjOO(T2kJqqcO1nFnkcKtGiMjb9vGQG)ZjAyYH2iSgRduCz)Zze)zfGm)vq8RZL9pNr8NvaY8xbrc4z3IFGQiN4Qngxy)ZjOsk9r28FwbiZFfWyZMcRR7QlBejBkemjaMz21CcZSz)ZjOYMX0ieKa4KsBihAXrSaMtyckQFRvhHCfcGrFYa0AIiLf8tEPkP0gYHwCelG5eMGI63ARmcbjGwJ6goOigPce8lvADZxXCWkr8NvaY8xbrynwhO4slb8SBXpq1JA0O79DYP7oG8Wlv0Wvmsfir58GIGkQdyec4z3I54XKsFKn)NvaY8xbztD28mjOVcuzZ)Nt0WKdTzFB28(ZyZMcRR7QlBWiU6YMc91LpbYwyAs21Cox2Sq2eysamtqL9erYw3wf4DJKsBihAXrSaMtyckQFRL81Lpb06MVI5GvI4pRaK5VcIWASoqX1OiqobIyMe0xbQc(pNOHjhAJWASoqXvBfsIKVU8jquUbd3wXLUroJ1br8TvoOigPcKKsFKn)NvaY8xbzxtTzZZKG(kqLn)Fordto0YyZMcbMUURUSNis2SO9JZMZupY2wvTis2GFcSkqLnEnDmtKKT6tm5qBmP0gYHwCelG5eMGI63A1rixHay0NmaTMiszb)KxQskTHCOfhXcyoHjOO(T2kJqqcO1OUHdkIrQab)sLw38vmhSse)zfGm)vqewJ1bkUgfbYjqeZKG(kqvW)5enm5qBewJ1bkU0Ad5OdfybVdWCqLgnAlMdwjc(HTT6FRjqewJ1bkA4kgPcKOCEqrqf1bCqap7wmxAjGNDl(bQ48A0Ongxy)ZjOOjP0hzZ)zfGm)vq2uNnN1pCv2OnBQ8NXMnfcMeaZmBgtJqqcKTjzlmHSHvLnAMnwaZjmZwqzxbs2EMFzR(eto0MnlmreiBoRFyBR(3AcKuAd5qloIfWCctqr9BT6iKRqam6tgGwtePSGFYlvjL2qo0IJybmNWeuu)wBLriib06MVI5GvI4pRaK5VcIWASoqXvmhSse8dBB1)wtGiSgRduCTHC0HcSG3b4xQ4Y(NZi(Zkaz(RGib8SBXpqvKtbESomc((ifuVdsqcb]] )

end