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
            value = 20,
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
        if not this_action then return 0 end

        local a = class.abilities[ this_action ]
        if not a then return 0 end

        local aura = a.aura or this_action
        if not aura then return 0 end

        if debuff[ aura ] and debuff[ aura ].up then
            return debuff[ aura ].pmultiplier or 1
        end

        return 0
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
                local up = cast + 3 < query_time

                local vr = buff.vendetta_regen

                if up then
                    vr.count = 1
                    vr.expires = cast + 3
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

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

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

            disabled = function ()
                return not ( boss and group )
            end,

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


    spec:RegisterPack( "Assassination", 20200614, [[deL1gcqisjpsiQlPsIQnHu9jHsIrHk6uOcRcjjVcP0Sec3sLK2LGFjummvkoMkvltLONrkLPje5AcLABQKW3iLQACcLuNtLezDijvVtLefnpHk3dj2hsX)iLkLdIKOwOkPEiscMisc5IKsfBKuQu9rKKsJuLeLojPufRej1lfkjntsPsCtsPkTtHudvOeTuKe5POQPkKCvKeQ2Qqj8vvsuySiju2Re)vsdwQdtzXO4XQyYKCzWMvLptvnAuQtR0QjLkPxJkz2u52KQDR43qgov54ijflhXZHA6exxvTDuY3fQA8OsDEvcRxLsZNuSFrxUxIQWRmbkrF5nxEZnxX9ifUF59yRTcVCHhu49SdxMpu4hthk8uzm2W4DmzrtH3ZUWHmvjQcpg9jhOWZwepmvpMy8xH9NjCq6XGx9VZKfnhI9KyWR(jMcpZFDI2Zuyk8ktGs0xEZL3CZvCpsH7xEp2xgPcV9f2isHNF1PcfE2RsbtHPWRa8PWh5SPYySHX7yYIMSPsi)pKuh5SzlIhMQhtm(RW(Zeoi9yWR(3zYIMdXEsm4v)etsDKZM6)azFpsrK9L3C5nj1j1roBQaBB8bmvpPoYzF1SPYkfOYowDpCLTGYwbp77KSTJSOjB3ILqsDKZ(QztLaDeliBXi(Gu3xiPoYzF1SPYkfOYMkogYw7raDC2CI(cEvq2Ox2ybmNWMJqsDKZ(QztfqdlGiGkBGBSn()DmbubQyzlOSvijqflaCJTX)VJjGku4DlwWLOk8ybmNWguLOkrFVevHhgJXbQY1f(dzfGSwHxmhmsywF2cwmhxajaJX4av20Z(G0zqvp0ocoBAOKDKYME2Ir8bjiRoufuvTq2xnBcOB7GZMMSVIcVDKfnfEY3t(eOiLOVSevHhgJXbQY1f(hIuhGBPe99cVDKfnfEpeYvjag9jhOiLO1wjQcpmgJduLRl8hYkazTcVDlqwbcy2e0xbQk()EOJjlAcWymoqLn9Sz(Vxa)zeG8((q47Ln9Sz(Vxa)zeG8((qGa62o4SJl77bTLn9S1kBmUY8Fpqv4TJSOPW7BecsGIuIosLOk8WymoqvUUW)qK6aClLOVx4TJSOPW7HqUkbWOp5afPeDSlrv4HXyCGQCDH3oYIMcVVriibk8hYkazTcVyoyKa(Zia599HamgJduztpBoZMa62o4SJl77xMTgnz7P)DY65wGKDCuY(E2CKn9SfJ4dsqwDOkOQAHSVA2eq32bNnnzFzH)CXXbvXi(GGlrFViLOVIsufEymghOkxx4pKvaYAfEXCWib8NraY77dbymghOYME22TazfiGztqFfOQ4)7HoMSOjaJX4av20ZwRSvijq(EYNabzpCTJF20ZMLrwJXbb8o(oOkgXhKcVDKfnfEY3t(eOiLO1(LOk8WymoqvUUW)qK6aClLOVx4TJSOPW7HqUkbWOp5afPeDSUevHhgJXbQY1fE7ilAk8(gHGeOWFiRaK1k8I5Grc4pJaK33hcWymoqLn9STBbYkqaZMG(kqvX)3dDmzrtagJXbQSPNnNzBhzzbvya9fWztt23ZwJMS1kBXCWibGBSn()DmbcWymoqLnhztpBXi(GeKvhQcQQwiBAYMa62o4SPNnNztaDBhC2XL99yD2A0KTwzJXvM)7bQS5OWFU44GQyeFqWLOVxKs0xPsufEymghOkxx4FisDaULs03l82rw0u49qixLay0NCGIuI((nLOk8WymoqvUUWFiRaK1k8I5Grc4pJaK33hcWymoqLn9SfZbJeaUX24)3XeiaJX4av20Z2oYYcQWa6lGZMs23ZME2m)3lG)mcqEFFiqaDBhC2XL99G2k82rw0u49ncbjqrksHhWyyoaUevj67LOk8WymoqvUUWFiRaK1k8Wae)lcYQdvbv1nUZMMSVNn9S1kBfW8FValyuGiw47Ln9S5mBTYwHKWbnhyeIjGQ(CMouz(Kji7HRD8ZME2ALTDKfnHdAoWietav95mDiSt95wF2s2A0K977CvcCyBeFOkRoKDCz7FubDJ7S5OWBhzrtH)GMdmcXeqvFothksj6llrv4HXyCGQCDH)qwbiRv4vaZ)9cSGrbIyHVx20ZMZSvaZ)9c(gHGeiaCJTX)VJjGkBnAYwbm)3liiU3tLXzki89YME2hKodQ6H2rWbf82ZkzhhLSVNTgnzRaM)7fybJceXceq32bNDCuY((nzZr2A0K9B9zlvcOB7GZookzF)McVDKfnfEghcPQOxvydvya9lksjATvIQWdJX4av56c)HScqwRWFqiNcf)eybJceXceq32bNDCzRTS1OjBfW8FValyuGiw47LTgnz)wF2sLa62o4SJlBTDtH3oYIMcV)3iQ1Mk6vTBbcsyxKs0rQevHhgJXbQY1f(dzfGSwH)5qis2CMnNz)wF2sLa62o4SVA2A7MS5i7R8STJSOPEqiNcf)Knhztt2phcrYMZS5m736ZwQeq32bN9vZwB3K9vZ(Gqofk(jWcgfiIfiGUTdoBoY(kpB7ilAQheYPqXpzZrH3oYIMcV)3iQ1Mk6vTBbcsyxKs0XUevHhgJXbQY1f(dzfGSwHh7boxvmIpi4WZMk6v5AwwaoBAOK9LzRrt2eBvvGfmsWukCyNSPj7R4MSPNnmaX)ISJlBT)nzRrt2V1NTujGUTdo74Y((nfE7ilAk8p05Jbv1UfiRavgW0lsj6ROevHhgJXbQY1f(dzfGSwHh7boxvmIpi4WZMk6v5AwwaoBAOK9LzRrt2eBvvGfmsWukCyNSPj7R4MS1Oj736ZwQeq32bNDCzF)McVDKfnfEVpzFxSJFLXzyPiLO1(LOk8WymoqvUUWFiRaK1k8m)3lqGdxoaJRpe5aHVx2A0KnZ)9ce4WLdW46droq9G(JaKawSdxzhx23VPWBhzrtHxyd1)WG(JQ(qKduKs0X6sufE7ilAk8K1ZZb1DQyp7afEymghOkxxKs0xPsufE7ilAk8XJioflyNkbWOXMdu4HXyCGQCDrkrF)MsufEymghOkxx4pKvaYAfEyaI)fzhx2X(MSPNTwzFqiNcf)eybJceXcFVcVDKfnfEDqhrUOIEv3)SQQIaMoUiLOVFVevHhgJXbQY1fE7ilAk8eW82XV(CMoGl8hYkazTcVyeFqcYQdvbvvlKDCzFpe7S1OjBoZMZSfJ4dsGnyoHDW7iztt2X6BYwJMSfJ4dsGnyoHDW7izhhLSV8MS5iB6zZz22rwwqfgqFbC2uY(E2A0KTyeFqcYQdvbvvlKnnzF5vkBoYMJS1OjBoZwmIpibz1HQGQEhPE5nztt2A7MSPNnNzBhzzbvya9fWztj77zRrt2Ir8bjiRoufuvTq20KDKIu2CKnhf(ZfhhufJ4dcUe99IuKcVcE23jLOkrFVevHhgJXbQY1f(dzfGSwHxRSXcyoHnOcMZv4TJSOPWZ1E4QiLOVSevH3oYIMcpwaZjSl8WymoqvUUiLO1wjQcpmgJduLRl8iVcpgKcVDKfnfEwgznghu4zzUpu4Hbi(xeiGpmztB2EOfJgqvzCaOWztvzR9Z(kpBoZ(YSPQSXEGZvzBybYMJcplJuhthk8Wae)lQeWhM6bPZSdOksj6ivIQWdJX4av56cpYRWJbPWBhzrtHNLrwJXbfEwM7dfESh4CvXi(GGdpBQOxLRzzb4SJl7ll8SmsDmDOWJ3X3bvXi(GuKs0XUevHhgJXbQY1f(dzfGSwHhlG5e2Gkqq(FOWBhzrtH)yox1oYIMQBXsH3TyPoMou4XcyoHnOksj6ROevHhgJXbQY1f(dzfGSwHNZS1kBXCWibDdlaPAySHX7eGXyCGkBnAYwHKGVriibcYE4Ah)S5OWBhzrtH)yox1oYIMQBXsH3TyPoMou4pkCrkrR9lrv4HXyCGQCDH3oYIMc)XCUQDKfnv3ILcVBXsDmDOWRqsrkrhRlrv4HXyCGQCDH3oYIMc)XCUQDKfnv3ILcVBXsDmDOWRwcCKIuI(kvIQWdJX4av56c)HScqwRWddq8ViOG3EwjBAOK99yNnTzZYiRX4GamaX)Ikb8HPEq6m7aQcVDKfnfEJCSbQcIqGrksj673uIQWBhzrtH3ihBGQ33HHcpmgJduLRlsj673lrv4TJSOPW7wF2cUQD9R81Hrk8WymoqvUUiLOVFzjQcVDKfnfEgZVIEvHShUWfEymghOkxxKIu49iWbPZysjQs03lrv4TJSOPWBEEUlQEOfJMcpmgJduLRlsj6llrv4HXyCGQCDH3oYIMcVUr4cu1hIuvGjSl8hYkazTcpXwvfybJemLch2jBAY(ESl8Ee4G0zmPIHdAu4cFSlsjATvIQWBhzrtHhlG5e2fEymghOkxxKs0rQevHhgJXbQY1f(X0HcVDlMTrmC9HgPIEvpu8aPWBhzrtH3UfZ2igU(qJurVQhkEGuKs0XUevH3oYIMcVhsw0u4HXyCGQCDrksHxTe4iLOkrFVevHhgJXbQY1f(dzfGSwH)G0zqvp0ocoBAOKDKYM2SfZbJeua4bKkwiMy(GEagJXbQSPNnNzRaM)7fybJceXcFVS1OjBfW8FVGG4EpvgNPGW3lBnAYggG4FrqbV9Ss2Xrj7lJD20MnlJSgJdcWae)lQeWhM6bPZSdOYwJMS1kBwgzngheW747GQyeFqYMJSPNnNzRv2I5Grca3yB8)7yceGXyCGkBnAYwRSvaZ)9cSGrbIyHVx2A0K9bHCku8ta4gBJ)FhtGab0TDWztt2xMnhfE7ilAk8WWcgKErkrFzjQcpmgJduLRl8iVcpgKcVDKfnfEwgznghu4zzUpu4piDgu1dTJGdk4TNvYMMSVNTgnzddq8ViOG3Ewj74OK9LXoBAZMLrwJXbbyaI)fvc4dt9G0z2buzRrt2ALnlJSgJdc4D8DqvmIpifEwgPoMou4)yO(wNdifPeT2krv4HXyCGQCDH)qwbiRv4zzK1yCq4JH6BDoGKn9STBbYkqaoSr74xzCMcWbymghOYME2ypW5QIr8bbhE2urVkxZYcWztdLSVmBAZMZSvaZ)9cSGrbIyHVx2uv2CM99SPnBoZ2UfiRab4WgTJFLXzkahi2Wv2uY(E2CKnhzZrH3oYIMc)ZMk6v5AwwaUiLOJujQcpmgJduLRl8hYkazTcplJSgJdcFmuFRZbKSPNnNzZ8FVa7vPGPY4mfGdyXoCLnnuY((vkBnAYMZS1kBpYIiRCrLGetw0Kn9SXEGZvfJ4dco8SPIEvUMLfGZMgkzhPSPnBoZ2UfiRabf6Z4GQcHHaXgUYMMSVmBoYM2SXcyoHnOceK)hYMJS5OWBhzrtH)ztf9QCnllaxKs0XUevHhgJXbQY1fE7ilAk8pBQOxLRzzb4c)HScqwRWZYiRX4GWhd136CajB6zJ9aNRkgXheC4ztf9QCnllaNnnuYwBf(ZfhhufJ4dcUe99IuI(kkrv4HXyCGQCDH)qwbiRv4zzK1yCq4JH6BDoGKn9S5mBM)7fyC7OWRccFVS1OjBTYwmhmsGfmi9k5JzhGXyCGkB6zRv22TazfiOqFghuvimeGXyCGkBok82rw0u4zC7OWRcksjATFjQcpmgJduLRl82rw0u41)Y6mbk8hYkazTcplJSgJdcFmuFRZbKSPNn2dCUQyeFqWHNnv0RY1SSaC2uY(Yc)5IJdQIr8bbxI(ErkrhRlrv4HXyCGQCDH)qwbiRv4zzK1yCq4JH6BDoGu4TJSOPWR)L1zcuKIu4pkCjQs03lrv4HXyCGQCDH3oYIMcVDlMTrmC9HgPIEvpu8aPWFiRaK1k8ALnwaZjSbvWCUSPNTUHfGunm2W4DQeq32bNnLSVjB6zZz2heYPqXpbwWOarSab0TDWzhN2TS5m7dc5uO4NGG4EpvgNPGab0TDWztvzdun)1ZdubdZMLnaUsSBrK6brmx2CKnhzhx23VjBAZ((nztvzdun)1ZdubdZMLnaUsSBrK6brmx20ZwRSvaZ)9cSGrbIyHVx20ZwRSvaZ)9ccI79uzCMccFVc)y6qH3UfZ2igU(qJurVQhkEGuKs0xwIQWdJX4av56c)HScqwRWRv2ybmNWgubZ5YME2kKeiFp5tGGShU2XpB6zRBybivdJnmENkb0TDWztj7Bk82rw0u4pMZvTJSOP6wSu4DlwQJPdfEaJH5a4IuIwBLOk8WymoqvUUWBhzrtHx3iCbQ6drQkWe2f(dzfGSwHNyRQcSGrcMsHdFVSPNnNzlgXhKGS6qvqv1czhx2hKodQ6H2rWbf82ZkztvzFpe7S1Oj7dsNbv9q7i4GcE7zLSPHs2hVQUXDf7bJkBok8NlooOkgXheCj67fPeDKkrv4HXyCGQCDH)qwbiRv4j2QQalyKGPu4Woztt2A7MSVA2eBvvGfmsWukCq9jMSOjB6zFq6mOQhAhbhuWBpRKnnuY(4v1nURypyufE7ilAk86gHlqvFisvbMWUiLOJDjQcpmgJduLRl8iVcpgKcVDKfnfEwgznghu4zzUpu41kBXCWib8NraY77dbymghOYwJMS1kB7wGSceWSjOVcuv8)9qhtw0eGXyCGkBnAYwHKGVriibcE6FNSEUfiztt23ZME2CMn2dCUQyeFqWHNnv0RY1SSaC2XL9vKTgnzRv2heYPqXpbw2Sy2HVx2Cu4zzK6y6qHNfmkqeRI)mcqEFFOEqJALfnfPe9vuIQWdJX4av56cpYRWJbPWBhzrtHNLrwJXbfEwM7dfETYwmhmsywF2cwmhxajaJX4av2A0KTwzlMdgjaCJTX)VJjqagJXbQS1Oj7dc5uO4NaWn2g))oMabcOB7GZoUSJD2xn7lZMQYwmhmsqbGhqQyHyI5d6bymghOk8SmsDmDOWZcgfiIvN1NTGfZXfqQh0OwzrtrkrR9lrv4HXyCGQCDHh5v4XGu4TJSOPWZYiRX4GcplZ9HcVwzdun)1Zdub7wmBJy46dnsf9QEO4bs2A0KTDlqwbcy2e0xbQk()EOJjlAcWymoqLTgnzRaM)7fi2Tis9GiMRQaM)7fuO4NS1Oj7dc5uO4NGHzZYgaxj2Tis9GiMlqaDBhC2XL99BYME2CM9bHCku8tqqCVNkJZuqGa62o4SJl77zRrt2kG5)EbbX9EQmotbHVx2Cu4zzK6y6qHNfmkqeR(qJupOrTYIMIuIowxIQWdJX4av56c)HScqwRWRv2ybmNWgubcY)dztpBfscKVN8jqq2dx74Nn9S1kBfW8FValyuGiw47Ln9SzzK1yCqGfmkqeRI)mcqEFFOEqJALfnztpBwgzngheybJceXQZ6ZwWI54ci1dAuRSOjB6zZYiRX4GalyuGiw9HgPEqJALfnfE7ilAk8SGrbIyfPe9vQevHhgJXbQY1f(dzfGSwHxmhmsa4gBJ)FhtGamgJduztpBXCWiHz9zlyXCCbKamgJduztp7dsNbv9q7i4SPHs2hVQUXDf7bJkB6zFqiNcf)eaUX24)3XeiqaDBhC2XL99cVDKfnfEw2Sy2fPe99Bkrv4HXyCGQCDH)qwbiRv4fZbJeM1NTGfZXfqcWymoqLn9S1kBXCWibGBSn()DmbcWymoqLn9SpiDgu1dTJGZMgkzF8Q6g3vShmQSPNnNzRaM)7fybJceXcFVS1OjBaJH5abwlErtf9QEa5bhzrtagJXbQS5OWBhzrtHNLnlMDrkrF)EjQcpmgJduLRl8iVcpgKcVDKfnfEwgznghu4zzUpu4TBbYkqaZMG(kqvX)3dDmzrtagJXbQSPNnNzpOPIXvM)7bQQyeFqWztdLSVNTgnzJ9aNRkgXheC4ztf9QCnllaNnLS1w2CKn9S5mBmUY8FpqvfJ4dcUAmiwq1ZgfOVNSPK9nzRrt2ypW5QIr8bbhE2urVkxZYcWztdLSVIS5OWZYi1X0HcpgxzzZIzxpOrTYIMIuI((LLOk8WymoqvUUWBhzrtH3dHCvcGrFYbk8a3cXQMo6psHpsXUW)qK6aClLOVxKs031wjQcpmgJduLRl8hYkazTcVyoyKa(Zia599HamgJduztpBTYglG5e2Gkqq(FiB6zFqiNcf)e8ncbjq47Ln9S5mBwgzngheW4klBwm76bnQvw0KTgnzRv22TazfiGztqFfOQ4)7HoMSOjaJX4av20ZMZSvij4BecsGabEeaZ2yCq2A0KTcy(VxGfmkqel89YME2kKe8ncbjqWt)7K1ZTaj74OK99S5iBoYME2hKodQ6H2rWbf82ZkztdLS5mBoZ(E20M9LztvzB3cKvGaMnb9vGQI)Vh6yYIMamgJduzZr2uv2ypW5QIr8bbhE2urVkxZYcWzZr20ODl7iLn9Sj2QQalyKGPu4Woztt23VSWBhzrtHNLnlMDrkrFpsLOk8WymoqvUUWFiRaK1k8I5Grc6gwas1WydJ3jaJX4av20ZwRSXcyoHnOcMZLn9S1nSaKQHXggVtLa62o4SJJs23Kn9S1kBfscKVN8jqGapcGzBmoiB6zRqsW3ieKabcOB7GZMMS1w20ZMZSvaZ)9cSGrbIyHVx20ZMZS1kBXCWibbX9EQmotbbymghOYwJMSvaZ)9ccI79uzCMccFVS5iB6zZz2ALnGXWCGaJdHuv0RkSHkmG(fbDt7kIKTgnzRaM)7fyCiKQIEvHnuHb0Vi89YMJS1OjBaJH5abwlErtf9QEa5bhzrtagJXbQS5OWBhzrtHNLnlMDrkrFp2LOk8WymoqvUUWFiRaK1k8ALnwaZjSbvWCUSPNTDlqwbcy2e0xbQk()EOJjlAcWymoqLn9Svij4BecsGabEeaZ2yCq20ZwHKGVriibcE6FNSEUfizhhLSVNn9SpiDgu1dTJGdk4TNvYMgkzFVWBhzrtHhZ2uO41bNQiLOVFfLOk8WymoqvUUWFiRaK1k8ALnwaZjSbvGG8)q20ZMZS1kBfsc(gHGeiqGhbWSnghKn9Svijq(EYNabcOB7GZMMSJu20MDKYMQY(4v1nURypyuzRrt2kKeiFp5tGab0TDWztvzFti2ztt2Ir8bjiRoufuvTq2CKn9SfJ4dsqwDOkOQAHSPj7iv4TJSOPWdCJTX)VJjqrkrFx7xIQWdJX4av56c)HScqwRWRqsG89KpbcYE4Ah)SPNnNzRv2avZF98avWUfZ2igU(qJurVQhkEGKTgnzFqiNcf)eybJceXceq32bNnnzF)MS5OWBhzrtHxqCVNkJZuqrkrFpwxIQWdJX4av56c)HScqwRWZ8FVaJdHuUpwceWos2A0KTcy(VxGfmkqel89k82rw0u49qYIMIuI((vQevHhgJXbQY1f(dzfGSwHxbm)3lWcgfiIf(EfE7ilAk8moesvFFYffPe9L3uIQWdJX4av56c)HScqwRWRaM)7fybJceXcFVcVDKfnfEgGGbcx74xKs0xEVevHhgJXbQY1f(dzfGSwHxbm)3lWcgfiIf(EfE7ilAk8VLamoesvKs0xEzjQcpmgJduLRl8hYkazTcVcy(VxGfmkqel89k82rw0u4T5ayHyU6XCUIuI(sTvIQWdJX4av56cVDKfnfEFZbhZ5acUYGqtH)qwbiRv45mBfW8FValyuGiw47LTgnzZz2ALTyoyKaWn2g))oMabymghOYME2heYPqXpbwWOarSab0TDWztt2rk2zRrt2I5Grca3yB8)7yceGXyCGkB6zZz2heYPqXpbGBSn()Dmbceq32bNDCzFfzRrt2heYPqXpbGBSn()Dmbceq32bNnnzF5nztp736ZwQeq32bNnnzFfXoBoYMJS5iB6zRv2kKeiFp5tGaWn2g))oMaQc)y6qH33CWXCoGGRmi0uKs0xgPsufEymghOkxx4TJSOPWBy2SSbWvIDlIupiI5k8hYkazTcVcy(VxGy3Ii1dIyUQcy(VxqHIFYwJMSFRpBPsaDBhC2XL9L3u4hthk8gMnlBaCLy3Ii1dIyUIuI(YyxIQWdJX4av56cVDKfnfEdZMLnaUsSBrK6brmxH)qwbiRv45mBTYwmhmsa4gBJ)FhtGamgJduzRrt2ALTyoyKa(Zia599HamgJduzZr20Zwbm)3lWcgfiIfiGUTdoBAY((nzF1SJu2uv2avZF98avWUfZ2igU(qJurVQhkEGu4hthk8gMnlBaCLy3Ii1dIyUIuI(YROevHhgJXbQY1fE7ilAk8gMnlBaCLy3Ii1dIyUc)HScqwRWZz2I5Grca3yB8)7yceGXyCGkB6zlMdgjG)mcqEFFiaJX4av2CKn9SvaZ)9cSGrbIyHVx20ZMZSvij4BecsGaWn2g))oMaQS1OjB7wGSceWSjOVcuv8)9qhtw0eGXyCGkB6zRqsW3ieKabp9Vtwp3cKSPj77zZrHFmDOWBy2SSbWvIDlIupiI5ksj6l1(LOk8WymoqvUUWBhzrtH)CXXHecA2tLXzyPWFiRaK1k86gwas1WydJ3PsaDBhC2uY(MSPNTwzRaM)7fybJceXcFVSPNTwzRaM)7fee37PY4mfe(EztpBM)7f0bDe5Ik6vD)ZQQkcy64Gcf)Kn9SHbi(xKDCzhRVjB6zRqsG89Kpbceq32bNnnzhPcp8EWrQJPdf(ZfhhsiOzpvgNHLIuI(YyDjQcpmgJduLRl82rw0u4DFcxabx3bVQf9Xv)9jf(dzfGSwHxbm)3lWcgfiIf(Ef(X0HcV7t4ci46o4vTOpU6VpPiLOV8kvIQWdJX4av56cVDKfnfE3hle0hx9rofmvp3x38Hc)HScqwRWRaM)7fybJceXcFVc)y6qH39Xcb9XvFKtbt1Z91nFOiLO12nLOk8WymoqvUUWBhzrtH33zQ1eebx1bL5ClAk8hYkazTcVcy(VxGfmkqel89k8W7bhPoMou49DMAnbrWvDqzo3IMIuIwB3lrv4HXyCGQCDH3oYIMcVVZuRjicUYykFOWFiRaK1k8kG5)EbwWOarSW3RWdVhCK6y6qH33zQ1eebxzmLpuKs0A7YsufE7ilAk8Fmuxb0XfEymghOkxxKIu4viPevj67LOk8WymoqvUUWJ8k8yqk82rw0u4zzK1yCqHNL5(qH3JSiYkxujiXKfnztpBSh4CvXi(GGdpBQOxLRzzb4SPjBTLn9S5mBfsc(gHGeiqaDBhC2XL9bHCku8tW3ieKab1NyYIMS1OjBp0IrdOQmoau4SPj7yNnhfEwgPoMou4XCTE1Zfhhu9ncbjqrkrFzjQcpmgJduLRl8iVcpgKcVDKfnfEwgznghu4zzUpu49ilISYfvcsmzrt20Zg7boxvmIpi4WZMk6v5AwwaoBAYwBztpBoZwbm)3liiU3tLXzki89YwJMS5mBp0IrdOQmoau4SPj7yNn9S1kB7wGSceWhyKk6vzCiKkaJX4av2CKnhfEwgPoMou4XCTE1ZfhhujFp5tGIuIwBLOk8WymoqvUUWJ8k8yqk82rw0u4zzK1yCqHNL5(qHxbm)3lWcgfiIf(EztpBoZwbm)3liiU3tLXzki89YwJMS1nSaKQHXggVtLa62o4SPj7BYMJSPNTcjbY3t(eiqaDBhC20K9LfEwgPoMou4XCTEvY3t(eOiLOJujQcpmgJduLRl8hYkazTcVyoyKaWn2g))oMabymghOYME2ALnWn2g))oMaQSPNTcjbFJqqce80)oz9ClqYookzFpB6zFqiNcf)eaUX24)3XeiqaDBhC2XL9LztpBSh4CvXi(GGdpBQOxLRzzb4SPK99SPNnXwvfybJemLch2jBAY(kYME2kKe8ncbjqGa62o4SPQSVje7SJlBXi(GeKvhQcQQwOWBhzrtH33ieKafPeDSlrv4HXyCGQCDH)qwbiRv4fZbJeaUX24)3XeiaJX4av20ZwRSvij4BecsGabEeaZ2yCq20ZMZSpiDgu1dTJGZMgkzF8Q6g3vShmQSPN9bHCku8ta4gBJ)FhtGab0TDWzhx23ZME2kKeiFp5tGab0TDWztvzFti2zhx2Ir8bjiRoufuvTq2Cu4TJSOPWt(EYNafPe9vuIQWdJX4av56c)drQdWTuI(EH3oYIMcVhc5QeaJ(KduKs0A)sufEymghOkxx4pKvaYAfEc8iaMTX4GSPN9bPZGQEODeCqbV9Ss20qj77ztB2AlBQkBoZ2UfiRabmBc6Ravf)Fp0XKfnbymghOYME2heYPqXpbw2Sy2HVx2CKn9S5mBp9Vtwp3cKSJJs23ZwJMSjGUTdo74OKTShUQYQdztpBSh4CvXi(GGdpBQOxLRzzb4SPHs2AlBAZ2UfiRabmBc6Ravf)Fp0XKfnbymghOYMJSPNnNzRv2a3yB8)7ycOYwJMSjGUTdo74OKTShUQYQdztvzFz20Zg7boxvmIpi4WZMk6v5AwwaoBAOKT2YM2STBbYkqaZMG(kqvX)3dDmzrtagJXbQS5iB6zRv2yCL5)EGkB6zZz2Ir8bjiRoufuvTq2xnBcOB7GZMJSPj7iLn9S5mBDdlaPAySHX7ujGUTdoBkzFt2A0KTwzl7HRD8ZME22TazfiGztqFfOQ4)7HoMSOjaJX4av2Cu4TJSOPW7BecsGIuIowxIQWdJX4av56c)drQdWTuI(EH3oYIMcVhc5QeaJ(KduKs0xPsufEymghOkxx4TJSOPW7BecsGc)HScqwRWRv2SmYAmoiG5A9QNlooO6BecsGSPNnbEeaZ2yCq20Z(G0zqvp0ocoOG3EwjBAOK99SPnBTLnvLnNzB3cKvGaMnb9vGQI)Vh6yYIMamgJduztp7dc5uO4NalBwm7W3lBoYME2CMTN(3jRNBbs2Xrj77zRrt2eq32bNDCuYw2dxvz1HSPNn2dCUQyeFqWHNnv0RY1SSaC20qjBTLnTzB3cKvGaMnb9vGQI)Vh6yYIMamgJduzZr20ZMZS1kBGBSn()DmbuzRrt2eq32bNDCuYw2dxvz1HSPQSVmB6zJ9aNRkgXheC4ztf9QCnllaNnnuYwBztB22TazfiGztqFfOQ4)7HoMSOjaJX4av2CKn9S1kBmUY8FpqLn9S5mBXi(GeKvhQcQQwi7RMnb0TDWzZr20K99lZME2CMTUHfGunm2W4DQeq32bNnLSVjBnAYwRSL9W1o(ztpB7wGSceWSjOVcuv8)9qhtw0eGXyCGkBok8NlooOkgXheCj67fPe99Bkrv4HXyCGQCDH3oYIMc)HS6y0ufq3dWsH)qwbiRv4XEGZvfJ4dcoBAYwBztpBcOB7GZoUSVmBAZMZSXEGZvfJ4dcoBAOKDSZMJSPN9bPZGQEODeC20qj7iv4pxCCqvmIpi4s03lsj673lrv4HXyCGQCDH)qwbiRv41kBwgzngheWCTEvY3t(eiB6zZz2hKodQ6H2rWztdLSJu20ZMapcGzBmoiBnAYwRSL9W1o(ztpBoZwwDiBAY((nzRrt2hKodQ6H2rWztdLSVmBoYMJSPNnNz7P)DY65wGKDCuY(E2A0Knb0TDWzhhLSL9WvvwDiB6zJ9aNRkgXheC4ztf9QCnllaNnnuYwBztB22TazfiGztqFfOQ4)7HoMSOjaJX4av2CKn9S5mBTYg4gBJ)Fhtav2A0Knb0TDWzhhLSL9WvvwDiBQk7lZME2ypW5QIr8bbhE2urVkxZYcWztdLS1w20MTDlqwbcy2e0xbQk()EOJjlAcWymoqLnhztpBXi(GeKvhQcQQwi7RMnb0TDWztt2rQWBhzrtHN89Kpbksj67xwIQWdJX4av56cVDKfnfEY3t(eOWFiRaK1k8ALnlJSgJdcyUwV65IJdQKVN8jq20ZwRSzzK1yCqaZ16vjFp5tGSPN9bPZGQEODeC20qj7iLn9SjWJay2gJdYME2CMTN(3jRNBbs2Xrj77zRrt2eq32bNDCuYw2dxvz1HSPNn2dCUQyeFqWHNnv0RY1SSaC20qjBTLnTzB3cKvGaMnb9vGQI)Vh6yYIMamgJduzZr20ZMZS1kBGBSn()DmbuzRrt2eq32bNDCuYw2dxvz1HSPQSVmB6zJ9aNRkgXheC4ztf9QCnllaNnnuYwBztB22TazfiGztqFfOQ4)7HoMSOjaJX4av2CKn9SfJ4dsqwDOkOQAHSVA2eq32bNnnzhPSPnBoZ2dTy0aQkJdafoBAY(YS5iBQk7ROWFU44GQyeFqWLOVxKs031wjQcpmgJduLRl82rw0u4pKvhJMQa6Eawk8hYkazTcp2dCUQyeFqWztt23ZME2ypW5QIr8bbNDCzhPSPNnb0TDWzhx2xMn9SpiDgu1dTJGZMgkzhPc)5IJdQIr8bbxI(ErkrFpsLOk8WymoqvUUWFiRaK1k8ypW5QIr8bbNnLSVNn9SpiDgu1dTJGZMgkzZz2hVQUXDf7bJk7RM99S5iB6ztGhbWSnghKn9S1kBGBSn()DmbuztpBTYwbm)3liiU3tLXzki89YME26gwas1WydJ3PsaDBhC2uY(MSPNTwzB3cKvGGe)ILQWgQCn7dcWymoqLn9SfJ4dsqwDOkOQAHSVA2eq32bNnnzhPcVDKfnf(dz1XOPkGUhGLIuI(ESlrv4HXyCGQCDH)qwbiRv4XEGZvfJ4dcoBAYMZS1(zF1Sz(VxagwWG0dFVS5iB6zFq6mOQhAhbNnnuYosztB2I5Grcka8asfletmFqpaJX4av20ZwRSvaZ)9cSGrbIyHVx20ZwRSvaZ)9ccI79uzCMccFVSPNTwzB3cKvGGe)ILQWgQCn7dcWymoqLn9SHbi(xeuWBpRKDCuY(YyNnTzZYiRX4GamaX)Ikb8HPEq6m7aQcVDKfnf(dz1XOPkGUhGLIuKIu4zbe8IMs0xEZL3CtS129cF8gz2Xhx4VYGktLIw7jAQwQE2zhfBi7v3drKSFis2XkagdZbWXkztaQM)sav2yKoKT9fKUjGk7dBB8bCiPw7Yoq2xs1ZMkGgwarav2Xka3yB8)7ycOcuXIvYwqzhROaM)7fOIfaUX24)3XeqfRKnN35MJqsDsT2JUhIiGkBTF22rw0KTBXcoKux49iO36GcFKZMkJXggVJjlAYMkH8)qsDKZMTiEyQEmX4Vc7pt4G0JbV6FNjlAoe7jXGx9tmj1roBQ)dK99ifr2xEZL3KuNuh5SPcSTXhWu9K6iN9vZMkRuGk7y19Wv2ckBf8SVtY2oYIMSDlwcj1ro7RMnvc0rSGSfJ4dsDFHK6iN9vZMkRuGkBQ4yiBThb0XzZj6l4vbzJEzJfWCcBocj1ro7RMnvanSaIaQSbUX24)3XeqfOILTGYwHKavSaWn2g))oMaQqsDsDKZw7WnC(cOYMbEicK9bPZys2mG)o4q2u5Zb8eC2dAUkBJO)(USTJSObNnACxesQJC22rw0GdEe4G0zmHYZzyUsQJC22rw0GdEe4G0zmHwkXyFFDyetw0Kuh5STJSObh8iWbPZycTuI5HqQK6iNn)yEy2ijBITQSz(VhOYglMGZMbEicK9bPZys2mG)o4STrLThbUQhsKD8ZEXzRqdesQJC22rw0GdEe4G0zmHwkXGhZdZgjvSycoP2oYIgCWJahKoJj0sjgZZZDr1dTy0KuBhzrdo4rGdsNXeAPeJUr4cu1hIuvGjSJWJahKoJjvmCqJctj2rSpkeBvvGfmsWukCyhAUh7KA7ilAWbpcCq6mMqlLyWcyoHDsTDKfn4GhboiDgtOLsmFmuxb0JymDGIDlMTrmC9HgPIEvpu8ajP2oYIgCWJahKoJj0sjgpKSOjPoPoYzRD4goFbuzdSaYfzlRoKTWgY2ocIK9IZ2yzRZyCqiPoYztLaSaMtyN9(Y2dHXlJdYMZbLnRVBaIX4GSHb0xaN9ozFq6mMWrsTDKfnykCThUIyFu0clG5e2GkyoxsTDKfnyAPedwaZjStQTJSObtlLyyzK1yCqeJPduGbi(xujGpm1dsNzhqfblZ9bkWae)lceWhgA9qlgnGQY4aqHPkT)voNxsvypW5QSnSaCKuBhzrdMwkXWYiRX4GigthOG3X3bvXi(GeblZ9bkypW5QIr8bbhE2urVkxZYcWXDzsTDKfnyAPeZXCUQDKfnv3ILigthOGfWCcBqfX(OGfWCcBqfii)pKuBhzrdMwkXCmNRAhzrt1TyjIX0bkhfoI9rHtTeZbJe0nSaKQHXggVtagJXbknAuij4BecsGGShU2XNJKA7ilAW0sjMJ5Cv7ilAQUflrmMoqrHKKA7ilAW0sjMJ5Cv7ilAQUflrmMoqrTe4ij12rw0GPLsmg5ydufeHaJeX(Oadq8ViOG3EwHgk3JnTSmYAmoiadq8VOsaFyQhKoZoGkP2oYIgmTuIXihBGQ33HHKA7ilAW0sjg36ZwWvTRFLVomssTDKfnyAPedJ5xrVQq2dx4K6K6iNnvaHCku8doP2oYIgC4OWu(yOUcOhXy6af7wmBJy46dnsf9QEO4bse7JIwybmNWgubZ5ORBybivdJnmENkb0TDWuUHoNheYPqXpbwWOarSab0TDWXPDJZdc5uO4NGG4EpvgNPGab0TDWufq18xppqfmmBw2a4kXUfrQheXCCWrC3VH273qvavZF98avWWSzzdGRe7wePEqeZrxlfW8FValyuGiw47rxlfW8FVGG4EpvgNPGW3lP2oYIgC4OW0sjMJ5Cv7ilAQUflrmMoqbWyyoaoI9rrlSaMtydQG5C0vijq(EYNabzpCTJpDDdlaPAySHX7ujGUTdMYnj1roBTNx2MsHZ2iq2FViYgpRhKTWgYgnq2XVc7SDO4bSKDurrffYMkogYoE2WKT6ID8Z(zybizlSTjBQqSmBf82ZkzJizh)kSrFjBBUiBQqSmKuBhzrdoCuyAPeJUr4cu1hIuvGjSJ4CXXbvXi(GGPCpI9rHyRQcSGrcMsHdFp6CkgXhKGS6qvqv1cXDq6mOQhAhbhuWBpRqv3dXwJMdsNbv9q7i4GcE7zfAOC8Q6g3vShmkosQJC2ApVShu2MsHZo(15YwTq2XVc7DYwydzpa3s2A7gCez)Xq2AVpQOSrt2mimo74xHn6lzBZfztfILHKA7ilAWHJctlLy0ncxGQ(qKQcmHDe7JcXwvfybJemLch2HgTDZvj2QQalyKGPu4G6tmzrd9dsNbv9q7i4GcE7zfAOC8Q6g3vShmQK6iNDSagfiILTd5VhZL9bnQvw0yoC2mgguzJMSpFcbgjBShCsQTJSObhokmTuIHLrwJXbrmMoqHfmkqeRI)mcqEFFOEqJALfnrWYCFGIwI5Grc4pJaK33hcWymoqPrJw2TazfiGztqFfOQ4)7HoMSOjaJX4aLgnkKe8ncbjqWt)7K1ZTaHM705e7boxvmIpi4WZMk6v5AwwaoURqJgToiKtHIFcSSzXSdFposQTJSObhokmTuIHLrwJXbrmMoqHfmkqeRoRpBblMJlGupOrTYIMiyzUpqrlXCWiHz9zlyXCCbKamgJduA0OLyoyKaWn2g))oMabymghO0O5Gqofk(jaCJTX)VJjqGa62o44I9vVKQeZbJeua4bKkwiMy(GEagJXbQKA7ilAWHJctlLyyzK1yCqeJPduyzK1yCqeJPduybJceXQp0i1dAuRSOjcwM7du0cOA(RNhOc2Ty2gXW1hAKk6v9qXdenASBbYkqaZMG(kqvX)3dDmzrtagJXbknAuaZ)9ce7wePEqeZvvaZ)9cku8JgnheYPqXpbdZMLnaUsSBrK6brmxGa62o44UFdDopiKtHIFccI79uzCMcceq32bh3DnAuaZ)9ccI79uzCMccFposQTJSObhokmTuIHfmkqelI9rrlSaMtydQab5)b6kKeiFp5tGGShU2XNUwkG5)EbwWOarSW3JolJSgJdcSGrbIyv8NraY77d1dAuRSOHolJSgJdcSGrbIy1z9zlyXCCbK6bnQvw0qNLrwJXbbwWOarS6dns9Gg1klAsQJC2XcBwm7SJFf2zRD4g7NnTzh96ZwWI54ciu9S1EnUx9VE2uHyz22OYw7Wn2pBcyQlY(Hizpa3s2uTubQOKA7ilAWHJctlLyyzZIzhX(OiMdgjaCJTX)VJjqagJXbk6I5GrcZ6ZwWI54cibymghOOFq6mOQhAhbtdLJxv34UI9Grr)Gqofk(jaCJTX)VJjqGa62o44UNuh5SJf2Sy2zh)kSZo61NTGfZXfqYM2SJgLT2HBSpvpBTxJ7v)RNnviwMTnQSJfWOarSS)EzZ5FCagN9hVJF2XcuSKJKA7ilAWHJctlLyyzZIzhX(OiMdgjmRpBblMJlGeGXyCGIUwI5Grca3yB8)7yceGXyCGI(bPZGQEODemnuoEvDJ7k2dgfDovaZ)9cSGrbIyHVNgnagdZbcSw8IMk6v9aYdoYIMamgJduCKuh5S5bi7335Y(G01HrYgnzZwepmvpMy8xH9NjCq6XqLmwWWg5uYvJIkedvc5)HyIF5AJHkJXggVJjlAUkvowQD5Qujadg5WoKuBhzrdoCuyAPedlJSgJdIymDGcgxzzZIzxpOrTYIMiyzUpqXUfiRabmBc6Ravf)Fp0XKfnbymghOOZ5GMkgxz(VhOQIr8bbtdL7A0G9aNRkgXheC4ztf9QCnllatrBCqNtmUY8FpqvfJ4dcUAmiwq1ZgfOVhk3Ord2dCUQyeFqWHNnv0RY1SSamnuUcosQTJSObhokmTuIXdHCvcGrFYbI4Hi1b4wOCpcGBHyvth9hHsKIDsTDKfn4WrHPLsmSSzXSJyFueZbJeWFgbiVVpeGXyCGIUwybmNWgubcY)d0piKtHIFc(gHGei89OZjlJSgJdcyCLLnlMD9Gg1klA0Orl7wGSceWSjOVcuv8)9qhtw0eGXyCGIoNkKe8ncbjqGapcGzBmoqJgfW8FValyuGiw47rxHKGVriibcE6FNSEUfiXr5ohCq)G0zqvp0ocoOG3EwHgkCY5DAVKQSBbYkqaZMG(kqvX)3dDmzrtagJXbkoOkSh4CvXi(GGdpBQOxLRzzbyoOr7wKOtSvvbwWibtPWHDO5(Lj1ro7yHnlMD2XVc7S1EnSaKSPYySH3HQND0OSXcyoHD22OYEqzBhzzbzR9sLZM5)ErKnv67jFcK9GKS3jBc8iaMD2eB8HiYw9j74NDSagfiIrBuxt71ir7KnN)XbyC2F8o(zhlqXsosQTJSObhokmTuIHLnlMDe7JIyoyKGUHfGunm2W4DcWymoqrxlSaMtydQG5C01nSaKQHXggVtLa62o44OCdDTuijq(EYNabc8iaMTX4a6kKe8ncbjqGa62oyA0gDovaZ)9cSGrbIyHVhDo1smhmsqqCVNkJZuqagJXbknAuaZ)9ccI79uzCMccFpoOZPwagdZbcmoesvrVQWgQWa6xe0nTRiIgnkG5)EbghcPQOxvydvya9lcFpo0ObWyyoqG1Ix0urVQhqEWrw0eGXyCGIJK6iNnpBtHIxhCQSFis28SjOVcuzZ)Fp0XKfnj12rw0GdhfMwkXGzBku86GtfX(OOfwaZjSbvWCo62TazfiGztqFfOQ4)7HoMSOjaJX4afDfsc(gHGeiqGhbWSnghqxHKGVriibcE6FNSEUfiXr5o9dsNbv9q7i4GcE7zfAOCpPoYzRD4gBJ)FhtGSJNnmzpijBSaMtydQSTrLndsyNnv67jFcKTnQSPAncbjq2gbY(7L9drY2Hg)SHb99zhsQTJSObhokmTuIb4gBJ)FhtGi2hfTWcyoHnOceK)hOZPwkKe8ncbjqGapcGzBmoGUcjbY3t(eiqaDBhmnrI2irvhVQUXDf7bJsJgfscKVN8jqGa62oyQ6MqSPrmIpibz1HQGQQf4GUyeFqcYQdvbvvlqtKsQTJSObhokmTuIrqCVNkJZuqe7JIcjbY3t(eii7HRD8PZPwavZF98avWUfZ2igU(qJurVQhkEGOrZbHCku8tGfmkqelqaDBhmn3VHJKA7ilAWHJctlLy8qYIMi2hfM)7fyCiKY9XsGa2r0Orbm)3lWcgfiIf(Ej12rw0GdhfMwkXW4qiv99jxeX(OOaM)7fybJceXcFVKA7ilAWHJctlLyyacgiCTJFe7JIcy(VxGfmkqel89sQTJSObhokmTuI5TeGXHqQi2hffW8FValyuGiw47LuBhzrdoCuyAPeJnhaleZvpMZfX(OOaM)7fybJceXcFVKA7ilAWHJctlLy(yOUcOhXy6afFZbhZ5acUYGqte7JcNkG5)EbwWOarSW3tJgo1smhmsa4gBJ)FhtGamgJdu0piKtHIFcSGrbIybcOB7GPjsXwJgXCWibGBSn()DmbcWymoqrNZdc5uO4NaWn2g))oMabcOB7GJ7k0O5Gqofk(jaCJTX)VJjqGa62oyAU8g6V1NTujGUTdMMRi2CWbh01sHKa57jFceaUX24)3XeqLuBhzrdoCuyAPeZhd1va9igthOyy2SSbWvIDlIupiI5IyFuuaZ)9ce7wePEqeZvvaZ)9cku8JgnV1NTujGUTdoUlVjP2oYIgC4OW0sjMpgQRa6rmMoqXWSzzdGRe7wePEqeZfX(OWPwI5Grca3yB8)7yceGXyCGsJgTeZbJeWFgbiVVpeGXyCGId6kG5)EbwWOarSab0TDW0C)MRgjQcOA(RNhOc2Ty2gXW1hAKk6v9qXdKKA7ilAWHJctlLy(yOUcOhXy6afdZMLnaUsSBrK6brmxe7JcNI5Grca3yB8)7yceGXyCGIUyoyKa(Zia599HamgJduCqxbm)3lWcgfiIf(E05uHKGVriibca3yB8)7ycO0OXUfiRabmBc6Ravf)Fp0XKfnbymghOORqsW3ieKabp9Vtwp3ceAUZrsTDKfn4WrHPLsmFmuxb0JaEp4i1X0bkNlooKqqZEQmodlrSpk6gwas1WydJ3PsaDBhmLBORLcy(VxGfmkqel89ORLcy(VxqqCVNkJZuq47rN5)EbDqhrUOIEv3)SQQIaMooOqXp0Hbi(xexS(g6kKeiFp5tGab0TDW0ePKA7ilAWHJctlLy(yOUcOhXy6af3NWfqW1DWRArFC1FFse7JIcy(VxGfmkqel89sQTJSObhokmTuI5JH6kGEeJPduCFSqqFC1h5uWu9CFDZhIyFuuaZ)9cSGrbIyHVxsTDKfn4WrHPLsmFmuxb0JaEp4i1X0bk(otTMGi4QoOmNBrte7JIcy(VxGfmkqel89sQTJSObhokmTuI5JH6kGEeW7bhPoMoqX3zQ1eebxzmLpeX(OOaM)7fybJceXcFVK6iNnve8SVtY(zohJD4k7hIK9hBmoi7vaDmvpBQ4yiB0K9bHCku8tiP2oYIgC4OW0sjMpgQRa64K6K6iNnv0sGJKTY0nFiBJzDRSaoPoYzRDgwWG0Z2KSJeTzZzSPn74xHD2ur8CKnviwgYw7rxhuRjG7ISrt2xsB2Ir8bbhr2XVc7SJfWOarSiYgrYo(vyNDuxFLz2iHnqIFXq2XBRK9drYgJ0HSHbi(xesQTJSObhulbocfyybdspI9r5G0zqvp0ocMgkrIwXCWibfaEaPIfIjMpOhGXyCGIoNkG5)EbwWOarSW3tJgfW8FVGG4EpvgNPGW3tJgyaI)fbf82ZkXr5YytllJSgJdcWae)lQeWhM6bPZSdO0OrlwgzngheW747GQyeFq4GoNAjMdgjaCJTX)VJjqagJXbknA0sbm)3lWcgfiIf(EA0CqiNcf)eaUX24)3XeiqaDBhmnxYrsTDKfn4GAjWrOLsmSmYAmoiIX0bkFmuFRZbKiyzUpq5G0zqvp0ocoOG3EwHM7A0adq8ViOG3EwjokxgBAzzK1yCqagG4FrLa(WupiDMDaLgnAXYiRX4GaEhFhufJ4dssDKZ(kJvyNT25WgTJF2x7mfGJiBT72Kn6LDS6SSaC2MK9L0MTyeFqWrKnIKT2UAKOnBXi(GGZoE2WKDSagfiIL9IZ(7LuBhzrdoOwcCeAPeZZMk6v5AwwaoI9rHLrwJXbHpgQV15acD7wGSceGdB0o(vgNPaCagJXbk6ypW5QIr8bbhE2urVkxZYcW0q5sA5ubm)3lWcgfiIf(EufN3PLt7wGSceGdB0o(vgNPaCGydxuUZbhCKuh5S1UBt2Ox2XQZYcWzBs23Vs0MnwSdx4SrVSVYUkfmzFTZuaoBejBZ32blzhjAZMZytB2XVc7SPIqFghKnvecdCKTyeFqWHKA7ilAWb1sGJqlLyE2urVkxZYcWrSpkSmYAmoi8Xq9TohqOZjZ)9cSxLcMkJZuaoGf7WfnuUFL0OHtT8ilISYfvcsmzrdDSh4CvXi(GGdpBQOxLRzzbyAOejA50UfiRabf6Z4GQcHHaXgUO5soOflG5e2Gkqq(FGdosQJC2A3TjB0l7y1zzb4Sfu2MNN7ISPIat5Ui7yjAXOj79L9o2rwwq2OjBBUiBXi(GKTjzRTSfJ4dcoKuBhzrdoOwcCeAPeZZMk6v5AwwaoIZfhhufJ4dcMY9i2hfwgznghe(yO(wNdi0XEGZvfJ4dco8SPIEvUMLfGPHI2sQTJSObhulbocTuIHXTJcVkiI9rHLrwJXbHpgQV15acDoz(VxGXTJcVki890OrlXCWibwWG0RKpMDagJXbk6Az3cKvGGc9zCqvHWqagJXbkosQJC2rzmxv79lRZeiBbLT555UiBQiWuUlYowIwmAY2KSVmBXi(GGtQTJSObhulbocTuIr)lRZeiIZfhhufJ4dcMY9i2hfwgznghe(yO(wNdi0XEGZvfJ4dco8SPIEvUMLfGPCzsTDKfn4GAjWrOLsm6FzDMarSpkSmYAmoi8Xq9TohqsQtQJC2urMU5dzJybKSLvhY2yw3klGtQJC2Axw9vYMQ1ieKa4Srt2dAUQhz1jg5ISfJ4dco7hIKTWgY2JSiYkxKnbjMSOj79LDSPnBghakC2gbY2CeWuxK93lP2oYIgCqHekSmYAmoiIX0bkyUwV65IJdQ(gHGeicwM7du8ilISYfvcsmzrdDSh4CvXi(GGdpBQOxLRzzbyA0gDovij4BecsGab0TDWXDqiNcf)e8ncbjqq9jMSOrJgp0IrdOQmoauyAInhj1roBTlR(kztL(EYNa4Srt2dAUQhz1jg5ISfJ4dco7hIKTWgY2JSiYkxKnbjMSOj79LDSPnBghakC2gbY2CeWuxK93lP2oYIgCqHeAPedlJSgJdIymDGcMR1REU44Gk57jFceblZ9bkEKfrw5IkbjMSOHo2dCUQyeFqWHNnv0RY1SSamnAJoNkG5)EbbX9EQmotbHVNgnC6HwmAavLXbGcttSPRLDlqwbc4dmsf9QmoesfGXyCGIdosQJC2Axw9vYMk99KpbWzVVSJfWOarmAJcX9EY(ANPGy0EnSaKSPYySHX7K9IZ(7LTnQSJhYMTXcY(sAZgdh0OWz7GNKnAYwydztL(EYNaztfHIkP2oYIgCqHeAPedlJSgJdIymDGcMR1Rs(EYNarWYCFGIcy(VxGfmkqel89OZPcy(VxqqCVNkJZuq47PrJUHfGunm2W4DQeq32btZnCqxHKa57jFceiGUTdMMltQJC28EWznx2uTgHGeiBBuztL(EYNazJb57LThzrKSfu2AhUX24)3Xei7JHLKA7ilAWbfsOLsm(gHGeiI9rrmhmsa4gBJ)FhtGamgJdu01c4gBJ)FhtafDfsc(gHGei4P)DY65wGehL70piKtHIFca3yB8)7yceiGUTdoUlPJ9aNRkgXheC4ztf9QCnllat5oDITQkWcgjykfoSdnxbDfsc(gHGeiqaDBhmvDti2XjgXhKGS6qvqv1cj12rw0GdkKqlLyiFp5tGi2hfXCWibGBSn()DmbcWymoqrxlfsc(gHGeiqGhbWSnghqNZdsNbv9q7iyAOC8Q6g3vShmk6heYPqXpbGBSn()Dmbceq32bh3D6kKeiFp5tGab0TDWu1nHyhNyeFqcYQdvbvvlWrsDKZMQ1ieKaz)94caViY2Cyu2czbC2ck7pgYELSnC2w2yp4SMlBFyaIjis2pejBHnKTZWs2uHyz2mWdrGSTSF7Sy2ajP2oYIgCqHeAPeJhc5QeaJ(KdeXdrQdWTq5EsTDKfn4Gcj0sjgFJqqceX(OqGhbWSnghq)G0zqvp0ocoOG3EwHgk3PvBufN2TazfiGztqFfOQ4)7HoMSOjaJX4af9dc5uO4NalBwm7W3Jd6C6P)DY65wGehL7A0qaDBhCCuK9WvvwDGo2dCUQyeFqWHNnv0RY1SSamnu0gT2TazfiGztqFfOQ4)7HoMSOjaJX4afh05ulGBSn()DmbuA0qaDBhCCuK9WvvwDGQUKo2dCUQyeFqWHNnv0RY1SSamnu0gT2TazfiGztqFfOQ4)7HoMSOjaJX4afh01cJRm)3du05umIpibz1HQGQQfUkb0TDWCqtKOZPUHfGunm2W4DQeq32bt5gnA0s2dx74t3UfiRabmBc6Ravf)Fp0XKfnbymghO4iP2oYIgCqHeAPeJhc5QeaJ(KdeXdrQdWTq5EsTDKfn4Gcj0sjgFJqqceX5IJdQIr8bbt5Ee7JIwSmYAmoiG5A9QNlooO6Becsa6e4ramBJXb0piDgu1dTJGdk4TNvOHYDA1gvXPDlqwbcy2e0xbQk()EOJjlAcWymoqr)Gqofk(jWYMfZo894GoNE6FNSEUfiXr5Ugneq32bhhfzpCvLvhOJ9aNRkgXheC4ztf9QCnllatdfTrRDlqwbcy2e0xbQk()EOJjlAcWymoqXbDo1c4gBJ)FhtaLgneq32bhhfzpCvLvhOQlPJ9aNRkgXheC4ztf9QCnllatdfTrRDlqwbcy2e0xbQk()EOJjlAcWymoqXbDTW4kZ)9afDofJ4dsqwDOkOQAHRsaDBhmh0C)s6CQBybivdJnmENkb0TDWuUrJgTK9W1o(0TBbYkqaZMG(kqvX)3dDmzrtagJXbkosQJC2ubYQJrt2rb6EawYgnzR)DY65GSfJ4dcoBtYos0MnviwMD8SHjBYFMD8Zg9LS3j7lVQ2WzZjJHbv2OjBXi(GK9b9hHJSrt22Cr2Ir8bjP2oYIgCqHeAPeZHS6y0ufq3dWseNlooOkgXhemL7rSpkypW5QIr8bbtJ2OtaDBhCCxslNypW5QIr8bbtdLyZb9dsNbv9q7iyAOePK6iNDSkaEz)9YMk99KpbY2KSJeTzJMSnNlBXi(GGZMZ4zdt2UL1o(z7qJF2WG((SZ2gv2dsYgpMhMns4iP2oYIgCqHeAPed57jFceX(OOflJSgJdcyUwVk57jFcqNZdsNbv9q7iyAOej6e4ramBJXbA0OLShU2XNoNYQd0C)gnAoiDgu1dTJGPHYLCWbDo90)oz9ClqIJYDnAiGUTdookYE4QkRoqh7boxvmIpi4WZMk6v5AwwaMgkAJw7wGSceWSjOVcuv8)9qhtw0eGXyCGId6CQfWn2g))oMaknAiGUTdookYE4QkRoqvxsh7boxvmIpi4WZMk6v5AwwaMgkAJw7wGSceWSjOVcuv8)9qhtw0eGXyCGId6Ir8bjiRoufuvTWvjGUTdMMiLuBhzrdoOqcTuIH89KpbI4CXXbvXi(GGPCpI9rrlwgzngheWCTE1ZfhhujFp5ta6AXYiRX4GaMR1Rs(EYNa0piDgu1dTJGPHsKOtGhbWSnghqNtp9Vtwp3cK4OCxJgcOB7GJJIShUQYQd0XEGZvfJ4dco8SPIEvUMLfGPHI2O1UfiRabmBc6Ravf)Fp0XKfnbymghO4GoNAbCJTX)VJjGsJgcOB7GJJIShUQYQdu1L0XEGZvfJ4dco8SPIEvUMLfGPHI2O1UfiRabmBc6Ravf)Fp0XKfnbymghO4GUyeFqcYQdvbvvlCvcOB7GPjs0YPhAXObuvghakmnxYbvDfj1roBQaz1XOj7OaDpalzJMSVFvTLT(3jRNdYwmIpi4Snj7irB2uHyz2XZgMSj)z2XpB0xYENSVeNnAY2MlYwmIpij12rw0GdkKqlLyoKvhJMQa6EawI4CXXbvXi(GGPCpI9rb7boxvmIpiyAUth7boxvmIpi44IeDcOB7GJ7s6hKodQ6H2rW0qjsj1roBQaz1XOj7OaDpalzJMS5Jk79L9oz7zJc03t22OYELSJFDUSvOSDagNTY0nFiBHTnzRDgwWG0Zw9HSfu2rDDmAVu5yIsIvtQTJSObhuiHwkXCiRognvb09aSeX(OG9aNRkgXhemL70piDgu1dTJGPHcNhVQUXDf7bJ6Q35GobEeaZ2yCaDTaUX24)3XeqrxlfW8FVGG4EpvgNPGW3JUUHfGunm2W4DQeq32bt5g6Az3cKvGGe)ILQWgQCn7dcWymoqrxmIpibz1HQGQQfUkb0TDW0ePK6iNnvWWs2ubYQJrt2rb6EawYgnztLrANS3blGPYg9Yw7mSGbPNTjzR9PnBXi(GGZoE2WKDSagfiIftuxN9IZEqs2FVKA7ilAWbfsOLsmhYQJrtvaDpalrSpkypW5QIr8bbtdNA)RY8FVamSGbPh(ECq)G0zqvp0ocMgkrIwXCWibfaEaPIfIjMpOhGXyCGIUwkG5)EbwWOarSW3JUwkG5)EbbX9EQmotbHVhDTSBbYkqqIFXsvydvUM9bbymghOOddq8ViOG3EwjokxgBAzzK1yCqagG4FrLa(WupiDMDavsDsDKZw7GXWCaCsTDKfn4aGXWCamLdAoWietav95mDiI9rbgG4FrqwDOkOQUXnn3PRLcy(VxGfmkqel89OZPwkKeoO5aJqmbu1NZ0HkZNmbzpCTJpDTSJSOjCqZbgHycOQpNPdHDQp36Zw0O59DUkboSnIpuLvhIZ)Oc6g3CKuh5SPYU4TlWz)Xq2x7qiv2XVc7SJfWOarSS)EHSVYICQSFis2AhUX24)3XeiKnvCmKD8RWo7OUo7Vx2mWdrGSTSF7Sy2ajBdNTdn(zB4SxjBYFWz)qKSVFdoB1NSJF2XcyuGiwiP2oYIgCaWyyoaMwkXW4qivf9QcBOcdOFre7JIcy(VxGfmkqel89OZjWn2g))oMaQGVriib0Orbm)3liiU3tLXzki89OFq6mOQhAhbhuWBpRehL7A0OaM)7fybJceXceq32bhhL73WHgnV1NTujGUTdook3VjPoYztLfb09KSfu2MB9NSPA)grT2KD8RWo7ybmkqelBdNTdn(zB4Sxj74rtSIKnbWFNK9oz7q4D8Z2Y(9DURYYCFi7JHLSrSas2cBiBcOB7SJF2QpXKfnzJEzlSHSFRpBjP2oYIgCaWyyoaMwkX4)nIATPIEv7wGGe2rSpkheYPqXpbwWOarSab0TDWXPnnAuaZ)9cSGrbIyHVNgnV1NTujGUTdooTDtsTDKfn4aGXWCamTuIX)Be1Atf9Q2TabjSJyFuEoeIWjNV1NTujGUTd(QA7goUYpiKtHIF4GMNdHiCY5B9zlvcOB7GVQ2U5QheYPqXpbwWOarSab0TDWCCLFqiNcf)WrsTDKfn4aGXWCamTuI5HoFmOQ2TazfOYaMEe7Jc2dCUQyeFqWHNnv0RY1SSamnuUuJgITQkWcgjykfoSdnxXn0Hbi(xeN2)gnAERpBPsaDBhCC3VjP2oYIgCaWyyoaMwkX49j77ID8RmodlrSpkypW5QIr8bbhE2urVkxZYcW0q5snAi2QQalyKGPu4Wo0Cf3OrZB9zlvcOB7GJ7(nj12rw0GdagdZbW0sjgHnu)dd6pQ6droqe7JcZ)9ce4WLdW46droq47PrdZ)9ce4WLdW46droq9G(JaKawSdxXD)MKA7ilAWbaJH5ayAPedz98CqDNk2ZoqsTDKfn4aGXWCamTuIjEeXPyb7ujagn2CGKA7ilAWbaJH5ayAPeJoOJixurVQ7FwvvrathhX(Oadq8ViUyFdDToiKtHIFcSGrbIyHVxsDKZ(klYPYMkbM3o(zRD3z6ao7hIKnWnC(cKnXgFiBejBUwNlBM)7HJi79LThcJxgheYMk7I3UaNTqUiBbLTpizlSHSDO4bSK9bHCku8t2mgguzJMSnw26mghKnmG(c4qsTDKfn4aGXWCamTuIHaM3o(1NZ0bCeNlooOkgXhemL7rSpkIr8bjiRoufuvTqC3dXwJgo5umIpib2G5e2bVJqtS(gnAeJ4dsGnyoHDW7iXr5YB4GoN2rwwqfgqFbmL7A0igXhKGS6qvqv1c0C5vIdo0OHtXi(GeKvhQcQ6DK6L3qJ2UHoN2rwwqfgqFbmL7A0igXhKGS6qvqv1c0ePiXbhj1j1roBEbmNWguztLpYIgCsDKZo61NnwmhxajB0K99OO6zZpMhMnsYMk99KpbsQTJSObhWcyoHnOOq(EYNarSpkI5GrcZ6ZwWI54cibymghOOFq6mOQhAhbtdLirxmIpibz1HQGQQfUkb0TDW0Cfj1roB(pJaK33hYM2S5ztqFfOYM))EOJjlAO6zRDg8NazhpK9hdzJgiBFhIXCzlOSnpp3fzt1AecsGSfu2cBiBDBNSfJ4ds27l7vYEXzpijB8yEy2ij7lajISXOSnNlBKWgizRB7KTyeFqY2yw3klGZ2JGEResQTJSObhWcyoHnOOLsmEiKRsam6toqepePoa3cL7j12rw0GdybmNWgu0sjgFJqqceX(Oy3cKvGaMnb9vGQI)Vh6yYIMamgJdu0z(Vxa)zeG8((q47rN5)Eb8NraY77dbcOB7GJ7EqB01cJRm)3duj1roB(pJaK33hO6ztL98CxKnIKnvcEeaZo74xHD2m)3duzt1AecsaCsTDKfn4awaZjSbfTuIXdHCvcGrFYbI4Hi1b4wOCpP2oYIgCalG5e2GIwkX4BecsGioxCCqvmIpiyk3JyFueZbJeWFgbiVVpeGXyCGIoNeq32bh39l1OXt)7K1ZTajok35GUyeFqcYQdvbvvlCvcOB7GP5YK6iNn)NraY77dztB28SjOVcuzZ)Fp0XKfnzVt28rr1ZMk755UiBWiUlYMk99KpbYwyBs2XVox2mq2e4ramBqL9drY2ZgfOVNKA7ilAWbSaMtydkAPed57jFceX(OiMdgjG)mcqEFFiaJX4afD7wGSceWSjOVcuv8)9qhtw0eGXyCGIUwkKeiFp5tGGShU2XNolJSgJdc4D8DqvmIpij1roB(pJaK33hYo(yYMNnb9vGkB()7HoMSOHQNnvcmpp3fz)qKSzqZhNnviwMTnQyqKSbUfyuGkB8yEy2ijB1NyYIMqsTDKfn4awaZjSbfTuIXdHCvcGrFYbI4Hi1b4wOCpP2oYIgCalG5e2GIwkX4BecsGioxCCqvmIpiyk3JyFueZbJeWFgbiVVpeGXyCGIUDlqwbcy2e0xbQk()EOJjlAcWymoqrNt7illOcdOVaMM7A0OLyoyKaWn2g))oMabymghO4GUyeFqcYQdvbvvlqdb0TDW05Ka62o44UhR1OrlmUY8FpqXrsDKZM)Zia599HSPnBTd3y)Srt23JIQNnvcEeaZoBQwJqqcKTjzlSHSHrLn6LnwaZjSZwqz7ds26g3zR(etw0Knd8qeiBTd3yB8)7ycKuBhzrdoGfWCcBqrlLy8qixLay0NCGiEisDaUfk3tQTJSObhWcyoHnOOLsm(gHGeiI9rrmhmsa)zeG8((qagJXbk6I5Grca3yB8)7yceGXyCGIUDKLfuHb0xat5oDM)7fWFgbiVVpeiGUTdoU7bTv4XEWPe9LX(kvKIuka]] )

end