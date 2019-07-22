-- RogueAssassination.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID = ns.FindUnitBuffByID


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

    local snapshots = {
        [121411] = true,
        [703]    = true,
        [154953] = true,
        [1943]   = true
    }


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

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == "SPELL_AURA_REMOVED" then
                if spellID == 115191 or spellID == 1784 then
                    stealth_dropped = GetTime()
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
        return max( active_dot.deadly_poison_dot, active_dot.wound_poison_dot, 0 )
    end )

    spec:RegisterStateExpr( 'poison_remains', function ()
        return debuff.lethal_poison.remains
    end )

    -- Count of bleeds on all active targets.
    spec:RegisterStateExpr( 'bleeds', function ()
        return ns.compositeDebuffCount( "garrote", "internal_bleeding", "rupture", "crimson_tempest" )
    end )

    spec:RegisterStateExpr( "ss_buffed", function ()
        return debuff.garrote.up and ssG[ target.unit ]
    end )

    spec:RegisterStateExpr( "non_ss_buffed_targets", function ()
        local count = active_enemies
        for units, buffed in pairs( ssG ) do
            count = count - 1
            if count == 0 then return 0 end
        end

        return count
    end )

    spec:RegisterStateExpr( "ss_buffed_targets_above_pandemic", function ()
        if not debuff.garrote.refreshable and debuff.garrote.ss_buffed then
            return 1
        end
        return 0 -- we aren't really tracking this right now...
    end )

    
    -- Count of bleeds on all poisoned (Deadly/Wound) targets.
    spec:RegisterStateExpr( 'poisoned_bleeds', function ()
        return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "garrote", "internal_bleeding", "rupture" )
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

        debuff.garrote.ss_buffed               = false
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
                applyDebuff( "target", "garrote" )
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

                if talent.venom_rush.enabled and ( debuff.deadly_poison.up or debuff.wound_poison.up or debuff.crippling_poison.up ) then
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


    spec:RegisterPack( "Assassination", 20190722.0000, [[d803Qbqiuv9iQKCjuKq2ekmkuvofQsRIkP8kKKzrL4wOi1Ue6xcuddvrhdj1YKqEgvkMgvkDnju2MuP03qviJtcvCoPsX6Kkv9ouKGAEsLCpPQ9HI6FOiH6GsLkluQOhIIKMivsvxevb2iksGpIQqzKOkOQtIQq1krcVKkPsZefjQBsLuXoPs1qLqLwQeQ6PO0ufixffjYwrvq(kksq2lv9xjnyLomLfJupwktMWLbBwv9zjA0OItRYQrvq51irZMOBlODR43qgovCCufuz5iEoutN01vLTJk9DPcJxc68sG1JIy(cy)I2tTpipRWuW7Er8K6UHN8OIkkYtEYZIOUB8SAboGN1XAuALGNDSqWZ2DySHX3y6HgpRJvGezcFqEwm6rAGNLJQo4Up4GlpLZJo2qHbJVWN00dnnI91GXxylypl97Kkp(4P9SctbV7fXtQ7gEYJkI6yrUPyfhQ7gpR9uoiINL9czQEwoNqaJN2ZkaCZZ6QC7om2W4Bm9qtUfpQ8bjfUkxoQ6G7(GdU8uop6ydfgm(cFstp00i2xdgFHTGtkCvUu8KfKBru7sUfXtQ7MCz6CPUB6E342KIKcxLltLJnLaU7tkCvUmDUDNqaICDDVgL5QOCfW3EsnxRPhAYvEynMu4QCz6ClEieXfYvnsjO17htkCvUmDUDNqaICzkHHC5XvieNlFONIpbKl6NlwbtQC4n6zLhwX(G8SyfmPYbe(G8UtTpiplmgTee(o9SnYPa5mpBdfsJQoOBuCUm3NRBZLrU8LRAsy04CLCuSAskbsegJwcICdeix1KWOr8JwbY)vcrymAjiYLrU8LRAsy0iui2MY3nMcrymAjiYLrUneskqDmrOqSnLVBmfIei0UbNBx95wuUbcKl)5QxJYBkZL3CzKlxJCgTeI4BkLqvnsjO5YBUmYvnsjOr9cHQIQIdYLPZLaH2n4Czo3U1ZAn9qJNL8C0hb8Q39I8b5zHXOLGW3PN9Ji1bku9UtTN1A6HgpRdcjReaJEKg4vV7UXhKNfgJwccFNE2g5uGCMN1ycqofIyoe0taIk(9)OMPhAIWy0sqKlJCPF)Fe)OvG8FLq85KlJCPF)Fe)OvG8FLqKaH2n4C7kxQJUjxg5YFUyCL(9)GWZAn9qJNT0ieKcE17UB9b5zHXOLGW3PN9Ji1bku9UtTN1A6HgpRdcjReaJEKg4vV7fZhKNfgJwccFNEwRPhA8SLgHGuWZ2iNcKZ8SQjHrJ4hTcK)ReIWy0sqKlJC5lxceA3GZTRCPUOCdeixNWNuph5bKC7QpxQZL3CzKRAKsqJ6fcvfvfhKltNlbcTBW5YCUf5zBf0KqvnsjOyV7u7vV7DRpiplmgTee(o9SnYPa5mpRAsy0i(rRa5)kHimgTee5YixJja5uiI5qqpbiQ43)JAMEOjcJrlbrUmYL)CfinsEo6Jar9AuEtzUmYLRroJwcr8nLsOQgPeupR10dnEwYZrFeWRE35r(G8SWy0sq470Z(rK6afQE3P2ZAn9qJN1bHKvcGrpsd8Q39IJpiplmgTee(o9Swtp04zlncbPGNTrofiN5zvtcJgXpAfi)xjeHXOLGixg5AmbiNcrmhc6jarf)(FuZ0dnrymAjiYLrUQrkbnQxiuvuvCqUmNlbcTBW5Yix(YLaH2n4C7kxQlo5giqU8NlgxPF)piYLxpBRGMeQQrkbf7DNAV6DVB8b5zHXOLGW3PN9Ji1bku9UtTN1A6HgpRdcjReaJEKg4vV7uZtFqEwymAji8D6zBKtbYzEw1KWOr8JwbY)vcrymAjiYLrUQjHrJqHyBkF3ykeHXOLGixg52qiPa1XeHcX2u(UXuisGq7gCUDLl15YixhcWTw2erQJKNJ(iqUmYvG0i55OpcejqODdoxMZTy5svUUnxxl3Mtn0kSIDGr4zTMEOXZwAecsbV6vplGXW0aSpiV7u7dYZAn9qJNTHMgmkXuqu)sle8SWy0sq470RE3lYhKNfgJwccFNE2g5uGCMNva0V)pYfgbOQfFo5Yix(YL)CvtcJgvuHxRslnbeHXOLGi3abYva0V)pQOcVwLwAci(CYLrUnuinQ6GUrXrb8V2P52vFUuNBGa5ka63)h5cJau1Iei0UbNBx95snpZL3Cdeix9cHQIQIdYTR(CPMNEwRPhA8S0sesur)QYbQWaHf4vV7UXhKN1A6HgpB5ZiIZMk6xnMaeKYXZcJrlbHVtV6D3T(G8SWy0sq470Z2iNcKZ8SyhqkRQrkbfh)2ur)kLZXfW5YCFUfLBGa5sStubUWOrtiWXBYL5C7wEMlJCHbiLfKBx5YJ4PN1A6Hgp7h1EyqunMaKtHknyHE17EX8b5zHXOLGW3PNTrofiN5zXoGuwvJucko(TPI(vkNJlGZL5(Clk3abYLyNOcCHrJMqGJ3KlZ52T80ZAn9qJN15rUFb3uwPLgw9Q39U1hKNfgJwccFNE2g5uGCMNL(9)rc0OucyC9Jini(CYnqGCPF)FKankLagx)isdQn0BuGeXQ1Om3UYLAE6zTMEOXZQCG6BOrVru)isd8Q3DEKpipR10dnEwY54iH6nvSJ1aplmgTee(o9Q39IJpiplmgTee(o9SnYPa5mpl97)JY7d0seseXQ1Om3UY1nEwRPhA8SDGisbx4MkbWOXMg4vV7DJpiplmgTee(o9SnYPa5mplmaPSGC7k3IXZCzKl)52qiPa1Xe5cJau1IphpR10dnE2qierkOI(v5RDIQGawi2RE1ZkGV9KQpiV7u7dYZcJrlbHVtpBJCkqoZZYFUyfmPYbertk9Swtp04zP8Au6vV7f5dYZAn9qJNfRGjvoEwymAji8D6vV7UXhKNfgJwccFNEwKJNfdQN1A6HgplxJCgTe8SCn5d8SWaKYcIeOeMCPkxh0HrdiQ0sae4CDTC5r5YuuU8LBr56A5IDaPSYXWkKlVEwUgPowi4zHbiLfujqjm1gkK(gq4vV7U1hKNfgJwccFNEwKJNfdQN1A6HgplxJCgTe8SCn5d8SyhqkRQrkbfh)2ur)kLZXfW52vUf5z5AK6yHGNfFtPeQQrkb1RE3lMpiplmgTee(o9SnYPa5mpl)5IvWKkhqenPmxg5gAyfivdJnm(MkbcTBW52NlpZLrUneskqDmrUWiavTibcTBW52vUuZZCzKl)5ka63)h5cJau1IpNCzKl)5ka63)hvuHxRslnbeFoE2XcbpRXemhJy46hnAf9RoOoaIN1A6HgpRXemhJy46hnAf9RoOoaIx9U3T(G8SWy0sq470Z2iNcKZ8SyfmPYbercQ8bEwRPhA8SntkRwtp0uLhw9SYdR1XcbplwbtQCaHx9UZJ8b5zHXOLGW3PNTrofiN5z5lx(ZvnjmAm0WkqQggBy8nrymAjiYnqGCfinwAecsHOEnkVPmxEZLrU8Ll)5c8W9ohhqenMG5yedx)OrROF1b1bqYnqGC5p3gcjfOoMO0uy0QrA2yXNtU86zTMEOXZ2mPSAn9qtvEy1ZkpSwhle8Snb2RE3lo(G8SWy0sq470ZAn9qJNTzsz1A6HMQ8WQNvEyTowi4zfi1RE37gFqEwymAji8D6zTMEOXZ2mPSAn9qtvEy1ZkpSwhle8SIJan1RE3PMN(G8SWy0sq470Z2iNcKZ8SWaKYcIc4FTtZL5(CPUy5svUCnYz0sicdqklOsGsyQnui9nGWZAn9qJN1inBGQIieyuV6DNAQ9b5zTMEOXZAKMnq15jXGNfgJwccFNE17o1f5dYZAn9qJNvELCuCLh2tugcJ6zHXOLGW3Px9QN1HanuiTP(G8UtTpipR10dnEwZXrwq1bDy04zHXOLGW3Px9UxKpipR10dnEwhKEOXZcJrlbHVtV6D3n(G8SWy0sq470ZAn9qJNn0iucI6hrQcWuoE2g5uGCMNLyNOcCHrJMqGJ3KlZ5sDX8SoeOHcPnTIHgAeypBX8Q3D36dYZAn9qJNfRGjvoEwymAji8D6vV7fZhKNfgJwccFNE2XcbpRXemhJy46hnAf9RoOoaIN1A6HgpRXemhJy46hnAf9RoOoaIx9QNvCeOP(G8UtTpiplmgTee(o9SnYPa5mpBdfsJQoOBuCUm3NRBZLQCvtcJgfa4aKkwjMALqyegJwcICzKlF5ka63)h5cJau1IpNCdeixbq)()OIk8AvAPjG4Zj3abYfgGuwqua)RDAUD1NBrflxQYLRroJwcryaszbvcuctTHcPVbe5giqU8NlxJCgTeI4BkLqvnsjO5YBUmYLVC5px1KWOrOqSnLVBmfIWy0sqKBGa52qiPa1XeHcX2u(UXuisGq7gCUmNBr5YRN1A6HgplmCHbf6vV7f5dYZcJrlbHVtplYXZIb1ZAn9qJNLRroJwcEwUM8bE2gkKgvDq3O4Oa(x70CzoxQZnqGCHbiLfefW)ANMBx95wuXYLQC5AKZOLqegGuwqLaLWuBOq6BarUbcKl)5Y1iNrlHi(MsjuvJucQNLRrQJfcE2hgQ)tkbIx9U7gFqEwymAji8D6zBKtbYzEwUg5mAjeFyO(pPei5YixJja5uicnoOBkR0sta4imgTee5YixSdiLv1iLGIJFBQOFLY54c4CzUp3I8Swtp04z)2ur)kLZXfWE17UB9b5zHXOLGW3PNTrofiN5z5AKZOLq8HH6)KsGKlJC5lx63)h5CcbmvAPjaCeRwJYCzUpxQ7MCdeix(YL)CDihICAbvcsn9qtUmYf7aszvnsjO443Mk6xPCoUaoxM7Z1T5svU8LRXeGCkefOhTeQcegIeBOmxMZTOC5nxQYfRGjvoGisqLpixEZLxpR10dnE2Vnv0Vs5CCbSx9UxmFqEwymAji8D6zTMEOXZ(TPI(vkNJlG9SnYPa5mplxJCgTeIpmu)NucKCzKl2bKYQAKsqXXVnv0Vs5CCbCUm3NRB8STcAsOQgPeuS3DQ9Q39U1hKNfgJwccFNE2g5uGCMNLRroJwcXhgQ)tkbsUmYLVCPF)FKwEJaFci(CYnqGC5px1KWOrUWGcRKhMtegJwcICzKl)5AmbiNcrb6rlHQaHHimgTee5YRN1A6HgplT8gb(eGx9UZJ8b5zHXOLGW3PN1A6HgpB4tpPPGNTrofiN5z5AKZOLq8HH6)KsGKlJCXoGuwvJucko(TPI(vkNJlGZTp3I8STcAsOQgPeuS3DQ9Q39IJpiplmgTee(o9SnYPa5mplxJCgTeIpmu)NucepR10dnE2WNEstbV6vpBtG9b5DNAFqEwymAji8D6zBKtbYzEw(ZfRGjvoGiAszUmYvG0i55Opce1Rr5nL5Yi3qdRaPAySHX3ujqODdo3(C5PN1A6HgpBZKYQ10dnv5HvpR8WADSqWZcymmna7vV7f5dYZcJrlbHVtpR10dnE2qJqjiQFePkat54zBKtbYzEwIDIkWfgnAcbo(CYLrU8LRAKsqJ6fcvfvfhKBx52qH0OQd6gfhfW)ANMRRLl1XILBGa52qH0OQd6gfhfW)ANMlZ952CQHwHvSdmIC51Z2kOjHQAKsqXE3P2RE3DJpiplmgTee(o9SnYPa5mplXorf4cJgnHahVjxMZ1n8mxMoxIDIkWfgnAcbokEetp0KlJCBOqAu1bDJIJc4FTtZL5(CBo1qRWk2bgHN1A6HgpBOrOee1pIufGPC8Q3D36dYZcJrlbHVtpBJCkqoZZYFUyfmPYbercQ8b5YixbsJKNJ(iquVgL3uMlJC5pxbq)()ixyeGQw85KlJC5lx(ZvnjmAe)OvG8FLqegJwcICdeix(Z1ycqofIyoe0taIk(9)OMPhAIWy0sqKBGa5kqAS0ieKcrNWNuph5bKCzoxQZLrU8Ll2bKYQAKsqXXVnv0Vs5CCbCUDLB3MBGa5YFUneskqDmrU2CyoXNtU8MlV5Yix(YL)CvtcJgNRKJIvtsjqIWy0sqKBGa5YFUQjHrJqHyBkF3ykeHXOLGi3abYTHqsbQJjcfITP8DJPqKaH2n4C7k3ILltNBr56A5QMegnkaWbivSsm1kHWimgTee5YRN1A6HgplxyeGQMx9UxmFqEwymAji8D6zBKtbYzEw1KWOrOqSnLVBmfIWy0sqKlJC5lx1KWOX5k5Oy1KucKimgTee5giqUQjHrJ4hTcK)ReIWy0sqKlJC5AKZOLqeFtPeQQrkbnxEZLrUnuinQ6GUrX5YCFUnNAOvyf7aJixg52qiPa1XeHcX2u(UXuisGq7gCUDLl15Yix(YL)CvtcJgXpAfi)xjeHXOLGi3abYL)CnMaKtHiMdb9eGOIF)pQz6HMimgTee5giqUcKglncbPq0j8j1ZrEaj3U6ZL6C51ZAn9qJNLRnhMJx9U3T(G8SWy0sq470Z2iNcKZ8SQjHrJZvYrXQjPeirymAjiYLrU8NRAsy0iui2MY3nMcrymAjiYLrUnuinQ6GUrX5YCFUnNAOvyf7aJixg5ka63)h5cJau1IphpR10dnEwU2CyoE17opYhKNfgJwccFNEwKJNfdQN1A6HgplxJCgTe8SCn5d8SgtaYPqeZHGEcquXV)h1m9qtegJwcICzKlF5oOPIXv63)dIQAKsqX5YCFUuNBGa5IDaPSQgPeuC8Btf9RuohxaNBFUUjxEZLrU8LlgxPF)piQQrkbfxnAexO6yJacVwU95YZCdeixSdiLv1iLGIJFBQOFLY54c4CzUp3UnxE9SCnsDSqWZIXvU2Cyo1gAeNEOXRE3lo(G8SWy0sq470ZcfQeRAHO3OEw3wmp7hrQduO6DNApR10dnEwheswjag9inWRE37gFqEwymAji8D6zBKtbYzEw1KWOr8JwbY)vcrymAjiYLrU8NlwbtQCarKGkFqUmYTHqsbQJjwAecsH4Zjxg5YxUCnYz0siIXvU2Cyo1gAeNEOj3abYL)CnMaKtHiMdb9eGOIF)pQz6HMimgTee5YixbsJLgHGuisGpbWCmAjKlV5Yi3gkKgvDq3O4Oa(x70CzUpx(YLVCPoxQYTOCDTCnMaKtHiMdb9eGOIF)pQz6HMimgTee5YBUUwUyhqkRQrkbfh)2ur)kLZXfW5YBUmZuCUUnxg5sStubUWOrtiWXBYL5CPUipR10dnEwU2CyoE17o180hKNfgJwccFNE2g5uGCMNvnjmAm0WkqQggBy8nrymAjiYLrU8NlwbtQCar0KYCzKBOHvGunm2W4BQei0UbNBx95YZCzKl)5kqAK8C0hbIe4tamhJwc5YixbsJLgHGuisGq7gCUmNRBYLrU8Ll)5cymmnislrirf9RkhOcdewqm04HHi5giqUcG(9)rAjcjQOFv5avyGWcIpNC51ZAn9qJNLRnhMJx9Utn1(G8SWy0sq470Z2iNcKZ8S8NlwbtQCar0KYCzKRXeGCkeXCiONaev87)rntp0eHXOLGixg5kqAS0ieKcrc8jaMJrlHCzKRaPXsJqqkeDcFs9CKhqYTR(CPoxg52qH0OQd6gfhfW)ANMlZ95sTN1A6HgplMJjqDecsHx9UtDr(G8SWy0sq470Z2iNcKZ8ScKgjph9rGibcTBW5YCUUnxQY1T56A52CQHwHvSdmICzKl)5kqAS0ieKcrc8jaMJrlbpR10dnEwOqSnLVBmf8Q3DQDJpiplmgTee(o9SnYPa5mpRaPrYZrFeiQxJYBk9Swtp04zvuHxRslnb4vV7u7wFqEwymAji8D6zBKtbYzEw63)hPLiKq(WAKawtZnqGCfa97)JCHraQAXNJN1A6HgpRdsp04vV7uxmFqEwymAji8D6zBKtbYzEwbq)()ixyeGQw854zTMEOXZslrir9)if4vV7u3T(G8SWy0sq470Z2iNcKZ8ScG(9)rUWiavT4ZXZAn9qJNLgiyGq5nLE17o18iFqEwymAji8D6zBKtbYzEwbq)()ixyeGQw854zTMEOXZ(pcqlriHx9UtDXXhKNfgJwccFNE2g5uGCMNva0V)pYfgbOQfFoEwRPhA8S20aSsmzTzsPx9UtD34dYZcJrlbHVtpBJCkqoZZ2qiPa1Xe5cJau1Iei0UbNlZ562I5zhle8SLMeAMuceCLgHgpR10dnE2stcntkbcUsJqJx9Uxep9b5zHXOLGW3PNTrofiN5zfa97)JeJjisTHiMSka63)hfOoMCdeixbq)()ixyeGQwKaH2n4CzoxQ5zUbcKREHqvrvXb52vUfXZCPk3gcjfOoMO0uy0QrA2yrceA3G9SJfcEwdZHRnaUsmMGi1gIyspR10dnEwdZHRnaUsmMGi1gIysV6DViQ9b5zHXOLGW3PNTrofiN5zfa97)JCHraQAXNJNDSqWZkFekbcUEd(eh6HRL3x9Swtp04zLpcLabxVbFId9W1Y7RE17Erf5dYZcJrlbHVtpBJCkqoZZka63)h5cJau1Iphp7yHGNv(Wkb9W1sKuat1r(cTsWZAn9qJNv(Wkb9W1sKuat1r(cTsWRE3lYn(G8SWy0sq470ZAn9qJNTuAIZuebxdbHjLhA8SnYPa5mpRaOF)FKlmcqvl(C8SW)dnTowi4zlLM4mfrW1qqys5HgV6DVi36dYZcJrlbHVtpR10dnE2sPjotreCL2eLGNTrofiN5zfa97)JCHraQAXNJNf(FOP1XcbpBP0eNPicUsBIsWRE3lQy(G8SWy0sq470ZAn9qJN1b1Oeu8XequBOqNNA6HMQa4EnWZ2iNcKZ8SHgwbs1WydJVPsGq7gCU95YZCzKl)5ka63)h5cJau1IpNCzKl)5ka63)hvuHxRslnbeFo5Yix63)hdHqePGk6xLV2jQccyH4Oa1XKlJCHbiLfKBx5wC4zUmYvG0i55OpcejqODdoxMZ1TEw4)HMwhle8STcAsKsqZ1Q0sdRE17ErDRpipR10dnE2hgQNcHyplmgTee(o9Qx9ScK6dY7o1(G8SWy0sq470ZIC8Syq9Swtp04z5AKZOLGNLRjFGN1HCiYPfuji10dn5YixSdiLv1iLGIJFBQOFLY54c4Czox3KlJC5lxbsJLgHGuisGq7gCUDLBdHKcuhtS0ieKcrXJy6HMCdeixh0HrdiQ0sae4Czo3ILlVEwUgPowi4zXuEo1wbnjulncbPGx9UxKpiplmgTee(o9SihplgupR10dnEwUg5mAj4z5AYh4zDihICAbvcsn9qtUmYf7aszvnsjO443Mk6xPCoUaoxMZ1n5Yix(Yva0V)pQOcVwLwAci(CYnqGC5lxh0HrdiQ0sae4Czo3ILlJC5pxJja5uiIBWOv0VslriregJwcIC5nxE9SCnsDSqWZIP8CQTcAsOsEo6JaE17UB8b5zHXOLGW3PNf54zXG6zTMEOXZY1iNrlbplxt(apRaOF)FKlmcqvl(CYLrUcG(9)rfv41Q0staXNtUmYvG0i55OpcejqODdoxMZTiplxJuhle8SykpNk55Opc4vV7U1hKNfgJwccFNE2g5uGCMNvnjmAekeBt57gtHimgTee5Yix(YLVCBOqAu1bDJIZL5(CBo1qRWk2bgrUmYTHqsbQJjcfITP8DJPqKaH2n4C7kxQZL3Cdeix(YL)C1Rr5nL5Yix(YvVqixMZLAEMBGa52qH0OQd6gfNlZ95wuU8MlV5YRN1A6Hgpl55Opc4vV7fZhKNfgJwccFNE2pIuhOq17o1EwRPhA8SoiKSsam6rAGx9U3T(G8SWy0sq470Z2iNcKZ8S8Ll)5QMegnIF0kq(VsicJrlbrUbcKl)5YxUneskqDmrU2CyoXNtUmYTHqsbQJjYfgbOQfjqODdo3U6Z1T5YBU8MlJCBOqAu1bDJIJc4FTtZL5(CPoxQY1n56A5YxUgtaYPqeZHGEcquXV)h1m9qtegJwcICzKBdHKcuhtKRnhMt85KlV5Yixc8jaMJrlHCzKlF56e(K65ipGKBx95sDUbcKlbcTBW52vFU61OSQxiKlJCXoGuwvJucko(TPI(vkNJlGZL5(CDtUuLRXeGCkeXCiONaev87)rntp0eHXOLGixEZLrU8Ll)5cfITP8DJPGi3abYLaH2n4C7Qpx9Auw1leY11YTOCzKl2bKYQAKsqXXVnv0Vs5CCbCUm3NRBYLQCnMaKtHiMdb9eGOIF)pQz6HMimgTee5YBUmYL)CX4k97)brUmYLVCvJucAuVqOQOQ4GCz6CjqODdoxEZL5CDBUmYLVCdnScKQHXggFtLaH2n4C7ZLN5giqU8NREnkVPmxg5AmbiNcrmhc6jarf)(FuZ0dnrymAjiYLxpR10dnE2sJqqk4vV78iFqEwymAji8D6z)isDGcvV7u7zTMEOXZ6GqYkbWOhPbE17EXXhKNfgJwccFNEwRPhA8SLgHGuWZ2iNcKZ8S8NlxJCgTeIykpNARGMeQLgHGuixg5YxU8NRAsy0i(rRa5)kHimgTee5giqU8NlF52qiPa1Xe5AZH5eFo5Yi3gcjfOoMixyeGQwKaH2n4C7Qpx3MlV5YBUmYTHcPrvh0nkokG)1onxM7ZL6CPkx3KRRLlF5AmbiNcrmhc6jarf)(FuZ0dnrymAjiYLrUneskqDmrU2CyoXNtU8MlJCjWNayogTeYLrU8LRt4tQNJ8asUD1Nl15giqUei0UbNBx95QxJYQEHqUmYf7aszvnsjO443Mk6xPCoUaoxM7Z1n5svUgtaYPqeZHGEcquXV)h1m9qtegJwcIC5nxg5YxU8Nlui2MY3nMcICdeixceA3GZTR(C1RrzvVqixxl3IYLrUyhqkRQrkbfh)2ur)kLZXfW5YCFUUjxQY1ycqofIyoe0taIk(9)OMPhAIWy0sqKlV5Yix(ZfJR0V)he5Yix(YvnsjOr9cHQIQIdYLPZLaH2n4C5nxMZL6IYLrU8LBOHvGunm2W4BQei0UbNBFU8m3abYL)C1Rr5nL5YixJja5uiI5qqpbiQ43)JAMEOjcJrlbrU86zBf0KqvnsjOyV7u7vV7DJpiplmgTee(o9SnYPa5mpl2bKYQAKsqX5YCFUfLlJCjqODdo3UYTOCPkx(Yf7aszvnsjO4CzUp3ILlV5Yi3gkKgvDq3O4CzUpx36zTMEOXZ2ixignvfcDaS6vV7uZtFqEwymAji8D6zBKtbYzEw(ZLRroJwcrmLNtL8C0hbYLrUnuinQ6GUrX5YCFUUnxg5sGpbWCmAjKlJC5lxNWNuph5bKC7QpxQZnqGCjqODdo3U6ZvVgLv9cHCzKl2bKYQAKsqXXVnv0Vs5CCbCUm3NRBYLQCnMaKtHiMdb9eGOIF)pQz6HMimgTee5YBUmYLVC5pxOqSnLVBmfe5giqUei0UbNBx95QxJYQEHqUUwUfLlJCXoGuwvJucko(TPI(vkNJlGZL5(CDtUuLRXeGCkeXCiONaev87)rntp0eHXOLGixEZLrUQrkbnQxiuvuvCqUmDUei0UbNlZ56wpR10dnEwYZrFeWRE3PMAFqEwymAji8D6zTMEOXZsEo6JaE2g5uGCMNL)C5AKZOLqet55uBf0KqL8C0hbYLrU8NlxJCgTeIykpNk55OpcKlJCBOqAu1bDJIZL5(CDBUmYLaFcG5y0sixg5YxUoHpPEoYdi52vFUuNBGa5sGq7gCUD1NREnkR6fc5YixSdiLv1iLGIJFBQOFLY54c4CzUpx3Klv5AmbiNcrmhc6jarf)(FuZ0dnrymAjiYL3CzKlF5YFUqHyBkF3ykiYnqGCjqODdo3U6ZvVgLv9cHCDTClkxg5IDaPSQgPeuC8Btf9RuohxaNlZ956MCPkxJja5uiI5qqpbiQ43)JAMEOjcJrlbrU8MlJCvJucAuVqOQOQ4GCz6CjqODdoxMZ1TE2wbnjuvJuck27o1E1RE1ZYfi4dnE3lINu3n8KhrDrXICtrfZZ2HrMBkXEwE8qherbrU8OCTMEOjx5HvCmPWZ6qq)tcEwxLB3HXggFJPhAYT4rLpiPWv5YrvhC3hCWLNY5rhBOWGXx4tA6HMgX(AW4lSfCsHRYLINSGClIAxYTiEsD3KltNl1Dt37g3MuKu4QCzQCSPeWDFsHRYLPZT7ecqKRR71OmxfLRa(2tQ5An9qtUYdRXKcxLltNBXdHiUqUQrkbTE)ysHRYLPZT7ecqKltjmKlpUcH4C5d9u8jGCr)CXkysLdVXKIKcxLlpOqO9uqKln8rei3gkK20CPHYBWXC7UwdCuCUdAyAogj8)K5An9qdox0iliMu4QCTMEObhDiqdfsBA)xAyktkCvUwtp0GJoeOHcPnLQ(GTxzimQPhAskCvUwtp0GJoeOHcPnLQ(G)iKiPWv5YoMdMdsZLyNix63)dICXQP4CPHpIa52qH0MMlnuEdoxBe56qaM2bP6nL5E4CfObIjfUkxRPhAWrhc0qH0MsvFW4XCWCqAfRMItkSMEObhDiqdfsBkv9bBooYcQoOdJMKcRPhAWrhc0qH0MsvFWoi9qtsH10dn4OdbAOqAtPQp4qJqjiQFePkat54IdbAOqAtRyOHgbUVyUC)EIDIkWfgnAcboEdZuxSKcRPhAWrhc0qH0MsvFWyfmPYjPWA6HgC0HanuiTPu1h8dd1tHqxgle6nMG5yedx)OrROF1b1bqskskCvU8GcH2tbrUaxGuqU6fc5QCGCTMIi5E4CnU2jnAjetkCvUfpGvWKkNCVFUoim(OLqU8nOC5(KdqmAjKlmq4b4CVj3gkK2uEtkSMEOb3t51O0L73ZpwbtQCar0KYKcRPhAWu1hmwbtQCskSMEObtvFWCnYz0sWLXcHEyaszbvcuctTHcPVbeUW1KpOhgGuwqKaLWqLd6WObevAjacSRXJykIVICnSdiLvogwbEtkSMEObtvFWCnYz0sWLXcHE8nLsOQgPeux4AYh0JDaPSQgPeuC8Btf9Ruohxa3vrjfwtp0GPQp4hgQNcHUmwi0BmbZXigU(rJwr)QdQdG4Y975hRGjvoGiAsjJqdRaPAySHX3ujqODdUNNmAiKuG6yICHraQArceA3G7IAEYGFbq)()ixyeGQw85WGFbq)()OIk8AvAPjG4ZjPWA6Hgmv9b3mPSAn9qtvEy1LXcHEScMu5acxUFpwbtQCarKGkFqsH10dnyQ6dUzsz1A6HMQ8WQlJfc9nb2L73Zh)QjHrJHgwbs1WydJVjcJrlbrGacKglncbPquVgL3uYld(4h4H7DooGiAmbZXigU(rJwr)QdQdGeia)neskqDmrPPWOvJ0SXIphEtkSMEObtvFWntkRwtp0uLhwDzSqOxG0KcRPhAWu1hCZKYQ10dnv5Hvxgle6fhbAAsH10dnyQ6d2inBGQIieyuxUFpmaPSGOa(x7uM7PUyuX1iNrlHimaPSGkbkHP2qH03aIKcRPhAWu1hSrA2avNNedjfwtp0GPQpy5vYrXvEyprzimAsrsHRYLPIqsbQJbNuyn9qdo2e4(MjLvRPhAQYdRUmwi0dymmna7Y975hRGjvoGiAsjdbsJKNJ(iquVgL3uYi0WkqQggBy8nvceA3G75zsHRYLh)NRje4CncK7ZXLCXZ5a5QCGCrdKBhNYjxjQdaR5guqU(yUmLWqUDWbMCffCtzUFdRajxLJn5YulU5kG)1onxej3ooLd6P5Atb5YulUXKcRPhAWXMatvFWHgHsqu)isvaMYXLwbnjuvJuckUNAxUFpXorf4cJgnHahFom4tnsjOr9cHQIQId6QHcPrvh0nkokG)1o11OowSabAOqAu1bDJIJc4FTtzUV5udTcRyhye8Mu4QC5X)5oOCnHaNBhNuMR4GC74uo3KRYbYDGc1CDdpXUK7dd5668D95IMCPryCUDCkh0tZ1McYLPwCJjfwtp0GJnbMQ(GdncLGO(rKQamLJl3VNyNOcCHrJMqGJ3WSB4jttStubUWOrtiWrXJy6HggnuinQ6GUrXrb8V2Pm33CQHwHvSdmIKcRPhAWXMatvFWCHraQAUC)E(XkysLdiIeu5dyiqAK8C0hbI61O8Msg8la63)h5cJau1Iphg8XVAsy0i(rRa5)kHimgTeebcWVXeGCkeXCiONaev87)rntp0eHXOLGiqabsJLgHGui6e(K65ipGWm1m4d7aszvnsjO443Mk6xPCoUaURUnqa(BiKuG6yICT5WCIphE5LbF8RMegnoxjhfRMKsGeHXOLGiqa(vtcJgHcX2u(UXuicJrlbrGaneskqDmrOqSnLVBmfIei0Ub3vXy6ICn1KWOrbaoaPIvIPwjegHXOLGG3KcxLlpKnhMtUDCkNC5bfIlZLQC5Z9RKJIvtsjqCjxejx2hTcK)ReYfnYcYfn5sDq829566yfEHVWCzQf3CTrKlpOqCzUeWefK7hrYDGc1C5XyQU(KcRPhAWXMatvFWCT5WCC5(9QjHrJqHyBkF3ykeHXOLGGbFQjHrJZvYrXQjPeirymAjiceqnjmAe)OvG8FLqegJwccgCnYz0siIVPucv1iLGYlJgkKgvDq3OyM7Bo1qRWk2bgbJgcjfOoMiui2MY3nMcrceA3G7IAg8XVAsy0i(rRa5)kHimgTeebcWVXeGCkeXCiONaev87)rntp0eHXOLGiqabsJLgHGui6e(K65ipG0vp18Mu4QC5HS5WCYTJt5KR7xjhfRMKsGKlv56okxEqH4YUpxxhRWl8fMltT4MRnIC5HGraQA5(CskSMEObhBcmv9bZ1MdZXL73RMegnoxjhfRMKsGeHXOLGGb)QjHrJqHyBkF3ykeHXOLGGrdfsJQoOBumZ9nNAOvyf7aJGHaOF)FKlmcqvl(CskCvUSaK7)jL52qHHWO5IMC5OQdU7do4Yt58OJnuyWfVXfgoiPqz6GyQbx8OYheChhLxWDhgBy8nMEOHP7UIltzMU4bmyKgNysH10dn4ytGPQpyUg5mAj4YyHqpgx5AZH5uBOrC6Hgx4AYh0BmbiNcrmhc6jarf)(FuZ0dnrymAjiyW3GMkgxPF)piQQrkbfZCp1bcGDaPSQgPeuC8Btf9Ruohxa37gEzWhgxPF)piQQrkbfxnAexO6yJacVwppdea7aszvnsjO443Mk6xPCoUaM5(UL3KcRPhAWXMatvFWoiKSsam6rAGlFePoqHAp1UafQeRAHO3O9UTyjfwtp0GJnbMQ(G5AZH54Y97vtcJgXpAfi)xjeHXOLGGb)yfmPYbercQ8bmAiKuG6yILgHGui(CyWhxJCgTeIyCLRnhMtTHgXPhAceGFJja5uiI5qqpbiQ43)JAMEOjcJrlbbdbsJLgHGuisGpbWCmAjWlJgkKgvDq3O4Oa(x7uM75JpQPQixZycqofIyoe0taIk(9)OMPhAIWy0sqWRRHDaPSQgPeuC8Btf9RuohxaZlZmf7wge7evGlmA0ecC8gMPUOKcxLlpKnhMtUDCkNCDDmScKC7om2W30956okxScMu5KRnIChuUwtpUqUUoDxU0V)3LCl(NJ(iqUdsZ9MCjWNayo5sSPeCjxXJCtzUDkrirUagddtY9(5ACTtA0siMuyn9qdo2eyQ6dMRnhMJl3VxnjmAm0WkqQggBy8nrymAjiyWpwbtQCar0KsgHgwbs1WydJVPsGq7gCx98Kb)cKgjph9rGib(eaZXOLadbsJLgHGuisGq7gmZUHbF8dymmnislrirf9RkhOcdewqm04HHibcia63)hPLiKOI(vLduHbcli(C4nPWv5YYXeOocbPi3pIKllhc6jarUSV)h1m9qtsH10dn4ytGPQpymhtG6ieKcxUFp)yfmPYbertkzymbiNcrmhc6jarf)(FuZ0dnrymAjiyiqAS0ieKcrc8jaMJrlbgcKglncbPq0j8j1ZrEaPREQz0qH0OQd6gfhfW)ANYCp1jfUkxEqHyBkF3ykKBhCGjxAKYj3I)5OpcKRnIC5XmcbPqUgbY95K7hrYvIMYCHb9k5Kuyn9qdo2eyQ6dgkeBt57gtbxUFVaPrYZrFeisGq7gmZULk36AnNAOvyf7aJGb)cKglncbPqKaFcG5y0siPWA6HgCSjWu1hSIk8AvAPjaxUFVaPrYZrFeiQxJYBktkSMEObhBcmv9b7G0dnUC)E63)hPLiKq(WAKawtdeqa0V)pYfgbOQfFojfwtp0GJnbMQ(GPLiKO(FKcC5(9cG(9)rUWiavT4ZjPWA6HgCSjWu1hmnqWaHYBkD5(9cG(9)rUWiavT4ZjPWA6HgCSjWu1h8)iaTeHeUC)Ebq)()ixyeGQw85Kuyn9qdo2eyQ6d2MgGvIjRntkD5(9cG(9)rUWiavT4ZjPWA6HgCSjWu1h8dd1tHqxgle6lnj0mPei4kncnUC)(gcjfOoMixyeGQwKaH2nyMDBXskSMEObhBcmv9b)Wq9ui0LXcHEdZHRnaUsmMGi1gIysxUFVaOF)FKymbrQneXKvbq)()Oa1XeiGaOF)FKlmcqvlsGq7gmZuZZab0leQkQkoORI4jvneskqDmrPPWOvJ0SXIei0UbNuyn9qdo2eyQ6d(HH6PqOlJfc9YhHsGGR3GpXHE4A59vxUFVaOF)FKlmcqvl(CskSMEObhBcmv9b)Wq9ui0LXcHE5dRe0dxlrsbmvh5l0kbxUFVaOF)FKlmcqvl(CskSMEObhBcmv9b)Wq9ui0f4)HMwhle6lLM4mfrW1qqys5HgxUFVaOF)FKlmcqvl(CskSMEObhBcmv9b)Wq9ui0f4)HMwhle6lLM4mfrWvAtucUC)Ebq)()ixyeGQw85Kuyn9qdo2eyQ6d(HH6PqOlW)dnTowi03kOjrkbnxRslnS6Y97dnScKQHXggFtLaH2n4EEYGFbq)()ixyeGQw85WGFbq)()OIk8AvAPjG4ZHb97)JHqiIuqf9RYx7evbbSqCuG6yyadqklORIdpziqAK8C0hbIei0UbZSBtkCvUUE4BpPM73KsARrzUFej3h2OLqUNcH4UpxMsyix0KBdHKcuhtmPWA6HgCSjWu1h8dd1tHqCsrsHRY11FeOP5kSqReY1Op5PhGtkCvU8GHlmOWCnnx3svU8vmQYTJt5KRRNL3CzQf3yU84HHG4mfKfKlAYTiQYvnsjOyxYTJt5KlpemcqvZLCrKC74uo5guNmfoxKYbiDCyi3oStZ9Ji5IrHqUWaKYcI52Dsmk3oStZ9(5YdkexMBdfsJY9W52qH3uM7ZjMuyn9qdokoc00Ey4cdk0L733qH0OQd6gfZCVBPsnjmAuaGdqQyLyQvcHrymAjiyWNaOF)FKlmcqvl(Cceqa0V)pQOcVwLwAci(CceagGuwqua)RDAx9fvmQ4AKZOLqegGuwqLaLWuBOq6BarGa8Z1iNrlHi(MsjuvJuckVm4JF1KWOrOqSnLVBmfIWy0sqeiqdHKcuhtekeBt57gtHibcTBWmxeVjfwtp0GJIJanLQ(G5AKZOLGlJfc9pmu)Nucex4AYh03qH0OQd6gfhfW)ANYm1bcadqklikG)1oTR(IkgvCnYz0sicdqklOsGsyQnui9nGiqa(5AKZOLqeFtPeQQrkbnPWv5YuOt5KlpOXbDtzUDknbGDjxMcSjx0pxx354c4Cnn3IOkx1iLGIJjfwtp0GJIJanLQ(G)2ur)kLZXfWUC)EUg5mAjeFyO(pPeimmMaKtHi04GUPSslnbGJWy0sqWa7aszvnsjO443Mk6xPCoUaM5(IskCvUmfytUOFUUUZXfW5AAUu3nuLlwTgL4Cr)C5H)ecyYTtPjaCUisUwPDdwZ1TuLlFfJQC74uo566rpAjKRRhHbEZvnsjO4ysH10dn4O4iqtPQp4Vnv0Vs5CCbSl3VNRroJwcXhgQ)tkbcd(OF)FKZjeWuPLMaWrSAnkzUN6Ujqa(43HCiYPfuji10dnmWoGuwvJucko(TPI(vkNJlGzU3TuXNXeGCkefOhTeQcegIeBOK5I4LkScMu5aIibv(aE5nPWv5YuGn5I(566ohxaNRIY1CCKfKRRhmHSGClUOdJMCVFU3yn94c5IMCTPGCvJucAUMMRBYvnsjO4ysH10dn4O4iqtPQp4Vnv0Vs5CCbSlTcAsOQgPeuCp1UC)EUg5mAjeFyO(pPeimWoGuwvJucko(TPI(vkNJlGzU3njfwtp0GJIJanLQ(GPL3iWNaC5(9CnYz0si(Wq9FsjqyWh97)J0YBe4taXNtGa8RMegnYfguyL8WCIWy0sqWGFJja5uikqpAjufimeHXOLGG3KcxLBqgnt7680tAkKRIY1CCKfKRRhmHSGClUOdJMCnn3IYvnsjO4KcRPhAWrXrGMsvFWHp9KMcU0kOjHQAKsqX9u7Y975AKZOLq8HH6)KsGWa7aszvnsjO443Mk6xPCoUaUVOKcRPhAWrXrGMsvFWHp9KMcUC)EUg5mAjeFyO(pPeijfjfUkxxVfALqUiUajx9cHCn6tE6b4KcxLlt5l80C5XmcbPaox0K7GgM2HCHeJuqUQrkbfN7hrYv5a56qoe50cYLGutp0K79ZTyuLlTeaboxJa5AscyIcY95Kuyn9qdokqApxJCgTeCzSqOht55uBf0KqT0ieKcUW1KpO3HCiYPfuji10dnmWoGuwvJucko(TPI(vkNJlGz2nm4tG0yPriifIei0Ub3vdHKcuhtS0ieKcrXJy6HMabCqhgnGOslbqGzUy8Mu4QCzkFHNMBX)C0hbW5IMCh0W0oKlKyKcYvnsjO4C)isUkhixhYHiNwqUeKA6HMCVFUfJQCPLaiW5AeixtsatuqUpNKcRPhAWrbsPQpyUg5mAj4YyHqpMYZP2kOjHk55Opc4cxt(GEhYHiNwqLGutp0Wa7aszvnsjO443Mk6xPCoUaMz3WGpbq)()OIk8AvAPjG4Zjqa(CqhgnGOslbqGzUym43ycqofI4gmAf9R0seseHXOLGGxEtkCvUmLVWtZT4Fo6Ja4CVFU8qWiavnQccv41YTtPjGCpCUpNCTrKBhqUCmUqUfrvUyOHgboxj81CrtUkhi3I)5OpcKRRhfusH10dn4OaPu1hmxJCgTeCzSqOht55ujph9rax4AYh0la63)h5cJau1IphgcG(9)rfv41Q0staXNddbsJKNJ(iqKaH2nyMlkPWv5Y6aTZK5w8ph9rGCXG(CY9Ji5YdkexMuyn9qdokqkv9btEo6JaUC)E1KWOrOqSnLVBmfIWy0sqWGp(AOqAu1bDJIzUV5udTcRyhyemAiKuG6yIqHyBkF3ykejqODdUlQ5nqa(4xVgL3uYGp9cbMPMNbc0qH0OQd6gfZCFr8YlVjfUkxEmJqqkK7ZHsaCCjxtIr5QKdW5QOCFyi3tZ1W5A5IDG2zYClHbiMIi5(rKCvoqUsdR5YulU5sdFebY1Y9FZH5aKKcRPhAWrbsPQpyheswjag9inWLpIuhOqTN6KcRPhAWrbsPQp4sJqqk4Y975JF1KWOr8JwbY)vcrymAjiceGF(AiKuG6yICT5WCIphgneskqDmrUWiavTibcTBWD17wE5LrdfsJQoOBuCua)RDkZ9utLBCn(mMaKtHiMdb9eGOIF)pQz6HMimgTeemAiKuG6yICT5WCIphEzqGpbWCmAjWGpNWNuph5bKU6PoqaceA3G7QxVgLv9cbgyhqkRQrkbfh)2ur)kLZXfWm37gQmMaKtHiMdb9eGOIF)pQz6HMimgTee8YGp(HcX2u(UXuqeiabcTBWD1RxJYQEHGRvedSdiLv1iLGIJFBQOFLY54cyM7DdvgtaYPqeZHGEcquXV)h1m9qtegJwccEzWpgxPF)piyWNAKsqJ6fcvfvfhW0ei0UbZlZULbFHgwbs1WydJVPsGq7gCppdeGF9AuEtjdJja5uiI5qqpbiQ43)JAMEOjcJrlbbVjfwtp0GJcKsvFWoiKSsam6rAGlFePoqHAp1jfwtp0GJcKsvFWLgHGuWLwbnjuvJuckUNAxUFp)CnYz0siIP8CQTcAsOwAecsbg8XVAsy0i(rRa5)kHimgTeebcWpFneskqDmrU2CyoXNdJgcjfOoMixyeGQwKaH2n4U6DlV8YOHcPrvh0nkokG)1oL5EQPYnUgFgtaYPqeZHGEcquXV)h1m9qtegJwccgneskqDmrU2CyoXNdVmiWNayogTeyWNt4tQNJ8asx9uhiabcTBWD1RxJYQEHadSdiLv1iLGIJFBQOFLY54cyM7DdvgtaYPqeZHGEcquXV)h1m9qtegJwccEzWh)qHyBkF3ykiceGaH2n4U61RrzvVqW1kIb2bKYQAKsqXXVnv0Vs5CCbmZ9UHkJja5uiI5qqpbiQ43)JAMEOjcJrlbbVm4hJR0V)hem4tnsjOr9cHQIQIdyAceA3G5LzQlIbFHgwbs1WydJVPsGq7gCppdeGF9AuEtjdJja5uiI5qqpbiQ43)JAMEOjcJrlbbVjfUkxMk5cXOj3GGqhaR5Igzb5IMCdFs9CKqUQrkbfNRP56wQYLPwCZTdoWKl5nZnL5IEAU3KBr4C575KRIY1T5QgPeumV5Ii56gCU8vmQYvnsjOyEtkSMEObhfiLQ(GBKleJMQcHoawD5(9yhqkRQrkbfZCFrmiqODdURIOIpSdiLv1iLGIzUVy8YOHcPrvh0nkM5E3Mu4QCDDbWj3NtUf)ZrFeixtZ1TuLlAY1KYCvJuckox(6Gdm5kpU3uMRenL5cd6vYjxBe5oinx8yoyoiL3KcRPhAWrbsPQpyYZrFeWL73ZpxJCgTeIykpNk55OpcWOHcPrvh0nkM5E3YGaFcG5y0sGbFoHpPEoYdiD1tDGaei0Ub3vVEnkR6fcmWoGuwvJucko(TPI(vkNJlGzU3nuzmbiNcrmhc6jarf)(FuZ0dnrymAji4LbF8dfITP8DJPGiqaceA3G7QxVgLv9cbxRigyhqkRQrkbfh)2ur)kLZXfWm37gQmMaKtHiMdb9eGOIF)pQz6HMimgTee8YqnsjOr9cHQIQIdyAceA3Gz2Tjfwtp0GJcKsvFWKNJ(iGlTcAsOQgPeuCp1UC)E(5AKZOLqet55uBf0KqL8C0hbyWpxJCgTeIykpNk55OpcWOHcPrvh0nkM5E3YGaFcG5y0sGbFoHpPEoYdiD1tDGaei0Ub3vVEnkR6fcmWoGuwvJucko(TPI(vkNJlGzU3nuzmbiNcrmhc6jarf)(FuZ0dnrymAji4LbF8dfITP8DJPGiqaceA3G7QxVgLv9cbxRigyhqkRQrkbfh)2ur)kLZXfWm37gQmMaKtHiMdb9eGOIF)pQz6HMimgTee8YqnsjOr9cHQIQIdyAceA3Gz2TjfjfUkxEagdtdWjfwtp0GJagdtdW9n00GrjMcI6xAHqsHRYT7KDyfGZ9HHC7uIqIC74uo5YdbJau1Y95eZT7KyuUpmKBhNYj3G6m3NtU0WhrGCTC)3Cyoajx(UFUQjHrbbV5A4CLOPmxdN7P5sEdo3pIKl18eNR4rUPmxEiyeGQwmPWA6HgCeWyyAaMQ(GPLiKOI(vLduHbclWL73la63)h5cJau1Iphg8XVAsy0OIk8AvAPjGimgTeebcia63)hvuHxRslnbeFomAOqAu1bDJIJc4FTt7QN6abea97)JCHraQArceA3G7QNAEYBGa6fcvfvfh0vp18mPWA6HgCeWyyAaMQ(GlFgrC2ur)QXeGGuojfwtp0GJagdtdWu1h8h1EyqunMaKtHknyHUC)ESdiLv1iLGIJFBQOFLY54cyM7lkqaIDIkWfgnAcboEdZDlpzadqklOlEeptkSMEObhbmgMgGPQpyNh5(fCtzLwAy1L73JDaPSQgPeuC8Btf9RuohxaZCFrbcqStubUWOrtiWXByUB5zsH10dn4iGXW0amv9bRCG6BOrVru)isdC5(90V)psGgLsaJRFePbXNtGa0V)psGgLsaJRFePb1g6nkqIy1Au2f18mPWA6HgCeWyyAaMQ(GjNJJeQ3uXowdskSMEObhbmgMgGPQp4oqePGlCtLay0ytdC5(90V)pkVpqlrireRwJYUCtsH10dn4iGXW0amv9bhcHisbv0VkFTtufeWcXUC)EyaszbDvmEYG)gcjfOoMixyeGQw85KuKu4QCzvWKkhqKB310dn4KcxLR7xjhSAskbIl5Ii5Y(OvQ4bfIlZfn5sDqDFUSJ5G5G0Cl(NJ(iqsH10dn4iwbtQCarp55Opc4Y97BOqAu1bDJIzU3Tm4tnjmACUsokwnjLajcJrlbrGaQjHrJ4hTcK)ReIWy0sqWGp1KWOrOqSnLVBmfIWy0sqWOHqsbQJjcfITP8DJPqKaH2n4U6lkqa(1Rr5nL8YGRroJwcr8nLsOQgPeuEzOgPe0OEHqvrvXbmnbcTBWm3TjfUkx2hTcK)ReYLQCz5qqpbiYL99)OMPhA6(C5bd(rGC7aY9HHCrdKBPerBYCvuUMJJSGC5XmcbPqUkkxLdKBODtUQrkbn37N7P5E4ChKMlEmhmhKMBbG6sUyuUMuMls5aKCdTBYvnsjO5A0N80dW56qq)tJjfwtp0GJyfmPYbeu1hSdcjReaJEKg4YhrQduO2tDsH10dn4iwbtQCabv9bxAecsbxUFVXeGCkeXCiONaev87)rntp0eHXOLGGb97)J4hTcK)ReIphg0V)pIF0kq(VsisGq7gCxuhDdd(X4k97)brsHRYL9rRa5)kHUp3UZXrwqUisUfp8jaMtUDCkNCPF)piYLhZieKc4KcRPhAWrScMu5acQ6d2bHKvcGrpsdC5Ji1bku7PoPWA6HgCeRGjvoGGQ(GlncbPGlTcAsOQgPeuCp1UC)E1KWOr8JwbY)vcrymAjiyWhbcTBWDrDrbc4e(K65ipG0vp18YqnsjOr9cHQIQIdyAceA3GzUOKcxLl7JwbY)vc5svUSCiONae5Y((FuZ0dn5EtUSb1952DooYcYfmISGCl(NJ(iqUkhtZTJtkZLgYLaFcG5aIC)isUo2iGWRLuyn9qdoIvWKkhqqvFWKNJ(iGl3VxnjmAe)OvG8FLqegJwccggtaYPqeZHGEcquXV)h1m9qtegJwccg8lqAK8C0hbI61O8MsgCnYz0siIVPucv1iLGMu4QCzF0kq(Vsi3ocoxwoe0taICzF)pQz6HMUp3Ihmhhzb5(rKCPrZdNltT4MRnIGrKCHcvyeGix8yoyoinxXJy6HMysH10dn4iwbtQCabv9b7GqYkbWOhPbU8rK6afQ9uNuyn9qdoIvWKkhqqvFWLgHGuWLwbnjuvJuckUNAxUFVAsy0i(rRa5)kHimgTeemmMaKtHiMdb9eGOIF)pQz6HMimgTeemuJucAuVqOQOQ4aMjqODdMbFei0Ub3f1fNab4hJR0V)he8Mu4QCzF0kq(VsixQYLhuiUS7ZLhWfMCrCbc5eqUwU4XCWCqAU8ygHGuixYvYrZ1(kqYT4Fo6Ja5sdFebYLhui2MY3nMEOjPWA6HgCeRGjvoGGQ(GDqizLay0J0ax(isDGc1EQtkSMEObhXkysLdiOQp4sJqqk4Y97vtcJgXpAfi)xjeHXOLGGHAsy0iui2MY3nMcrymAjiy0qiPa1XeHcX2u(UXuisGq7gCxuZWHaCRLnrK6i55OpcWqG0i55OpcejqODdM5IrLBDTMtn0kSIDGr4zXoqZ7ErfRB8Qx9Ea]] )
    

end