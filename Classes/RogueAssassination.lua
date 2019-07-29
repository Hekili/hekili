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


    spec:RegisterPack( "Assassination", 20190728.2035, [[d8uCRbqiuv9iQqDjLsj1MqrJcvLtHkAvuH4vijZIk4wOcSlH(La1Wqf6yOGLPuYZeGMMa4AsuSnKuX3qfuJtPu15qsLwNsPY7ukLeZtPO7PuTpuO)HKQWbvkfluPWdrfKjkrjUisQQnsfsvFKkKyKuHuPtsfsALiHxQukXmvkLYnPcPStb0qLOKwQeL6PO0ufixfjvrBfjvPVQukjTxQ6VsAWkomLfJupwjtMWLbBwv9zjmAuPtRYQvkLQxJenBIUTG2Tu)gQHtLoovivSCephY0jDDvz7OkFxIQXlr68seRhjL5tfTFr7zWhKNvyk4dCloYa1LJC4T2(4wCmGLjauxpRwIl4zDTfLwb4zBle8SBdczi01ME42Z6ALiXMWhKNfHFKf4z5QQlA7co4It5(OJlCyWOl8jn9W9IyFny0fUc2Zs)oP6O2EApRWuWh4wCKbQlh5WBT9XT4yaltaPUEw7PCXepl7fYH8SCpHaApTNvaOLN1X5SniKHqxB6H7CkBCXdskCCoCv1fTDbhCXPCF0Xfomy0f(KME4ErSVgm6cxbNu44CO4jljNT2EhYzloYa1nhoihg2(TlabiPiPWX5WH4ADbG2UKchNdhKZ2ieGiNTLBrzokohb8TNuZXw6H7CKhsJjfoohoiNYgcX8GCuJuaA9(XKchNdhKZ2ieGihQNiihhvfcr5Wh(POta5G)5GuWKkxoJEw5HuKpiplsbtQCbHpiFGm4dYZcTrlbHFdp7ICkqoZZUWH04Ql(AfLdJ75eGCyMdF5OMeAn2xbxfPMKsGeH2OLGihNoZrnj0Ae9OvG8FfqeAJwcICyMdF5OMeAncLISU4DTPqeAJwcICyMZcJLcC5DekfzDX7AtHibcTRr5S5EoBLJtN5WFo6TO86IC4mhM5WZiNrlHi66cjuvJuaAoCMdZCuJuaAuVqOQ4Q4GC4GCiqODnkhgZH64zTLE42ZsEU6JaE1h4w(G8SqB0sq43WZ(XKAdLQ(azWZAl9WTN1fJLvcGWpYc8QpWa6dYZcTrlbHFdp7ICkqoZZAudiNcrexc(jarf9(F8Y0d3rOnAjiYHzo0V)pIE0kq(Vci(CZHzo0V)pIE0kq(VcisGq7AuoBMddXaMdZC4pheQs)(Fq4zTLE42ZwyecwbV6dma(G8SqB0sq43WZ(XKAdLQ(azWZAl9WTN1fJLvcGWpYc8QpWY4dYZcTrlbHFdpRT0d3E2cJqWk4zxKtbYzEw1KqRr0JwbY)varOnAjiYHzo8LdbcTRr5SzomSvooDMJB4tQNR8asoBUNdd5WzomZrnsbOr9cHQIRIdYHdYHaH21OCymNT8SRswsOQgPauKpqg8QpqQJpipl0gTee(n8SlYPa5mpRAsO1i6rRa5)kGi0gTee5WmhJAa5uiI4sWpbiQO3)JxME4ocTrlbromZH)CeynsEU6Jar9wuEDromZHNroJwcr01fsOQgPaupRT0d3EwYZvFeWR(a5W(G8SqB0sq43WZ(XKAdLQ(azWZAl9WTN1fJLvcGWpYc8QpWT3hKNfAJwcc)gEwBPhU9SfgHGvWZUiNcKZ8SQjHwJOhTcK)RaIqB0sqKdZCmQbKtHiIlb)eGOIE)pEz6H7i0gTee5Wmh1ifGg1leQkUkoihgZHaH21OCyMdF5qGq7AuoBMddBFooDMd)5Gqv63)dIC40ZUkzjHQAKcqr(azWR(aPU(G8SqB0sq43WZ(XKAdLQ(azWZAl9WTN1fJLvcGWpYc8Qpqg4Opipl0gTee(n8SlYPa5mpRAsO1i6rRa5)kGi0gTee5Wmh1KqRrOuK1fVRnfIqB0sqKdZCwySuGlVJqPiRlExBkejqODnkNnZHHCyMJlb4vlwIidrYZvFeihM5iWAK8C1hbIei0UgLdJ5uMCOkNaKJJKZYTgALwrUql8S2spC7zlmcbRGx9QNfqiOxaYhKpqg8b5zTLE42ZUW9cALykiQFPfcEwOnAji8B4vFGB5dYZcTrlbHFdp7ICkqoZZka63)h5bTau1Ip3CyMdF5WFoQjHwJkU0BvPLMaIqB0sqKJtN5ia63)hvCP3QslnbeFU5WmNfoKgxDXxROOa(360C2CphgYXPZCea97)J8GwaQArceAxJYzZ9CyGJ5WzooDMJEHqvXvXb5S5EomWrpRT0d3EwAjglQ4Fv5cvOHWs8QpWa6dYZAl9WTNT4zeXzDf)Rg1acw56zH2OLGWVHx9bgaFqEwOnAji8B4zxKtbYzEwKliLv1ifGIIFRR4FLY(4bOCyCpNTYXPZCi2jQapO1OjeO415WyouhoMdZCGgifLKZM5WH5ON1w6HBp7hVEiqunQbKtHknyHE1hyz8b5zH2OLGWVHNDrofiN5zrUGuwvJuakk(TUI)vk7JhGYHX9C2khNoZHyNOc8GwJMqGIxNdJ5qD4ON1w6HBpR7JC)sUUOslnK6vFGuhFqEwOnAji8B4zxKtbYzEw63)hjWIsjGq1pMSG4ZnhNoZH(9)rcSOuciu9JjlOUWVwbseP2IYC2mhg4ON1w6HBpRYfQVMg)Ar9JjlWR(a5W(G8S2spC7zjNRReQxxrU2c8SqB0sq43WR(a3EFqEwOnAji8B4zxKtbYzEw63)hL3hOLySiIuBrzoBMta9S2spC7zlhtKcEW1vcGWT1lWR(aPU(G8SqB0sq43WZUiNcKZ8SqdKIsYzZCkdhZHzo8NZcJLcC5DKh0cqvl(C9S2spC7zdHqmPKk(xLV1jQccyHiV6vpRa(2tQ(G8bYGpipl0gTee(n8SlYPa5mpl)5GuWKkxqenP0ZAl9WTNLYBrPx9bULpipRT0d3EwKcMu56zH2OLGWVHx9bgqFqEwOnAji8B4zXUEweOEwBPhU9S8mYz0sWZYZKpWZcnqkkjsGcOZHQCCXhc3GOslbqGYXrYHdNZ26C4lNTYXrYb5cszLRHuiho9S8msTTqWZcnqkkPsGcORlCi91GWR(adGpipl0gTee(n8SyxplcupRT0d3EwEg5mAj4z5zYh4zrUGuwvJuakk(TUI)vk7JhGYzZC2YZYZi12cbpl66cjuvJuaQx9bwgFqEwOnAji8B4zTLE42ZAudX1igQ(XTwX)QlUCG4zxKtbYzEw(ZbPGjvUGiAszomZj0qkqQgczi01vceAxJYzphoMdZCwySuGlVJ8GwaQArceAxJYzZCyGJ5Wmh(Zra0V)pYdAbOQfFU5Wmh(Zra0V)pQ4sVvLwAci(C9STfcEwJAiUgXq1pU1k(xDXLdeV6dK64dYZcTrlbHFdp7ICkqoZZIuWKkxqej4Ih4zTLE42ZUmPSAl9WDvEi1ZkpKwBle8SifmPYfeE1hih2hKNfAJwcc)gE2f5uGCMNLVC4ph1KqRXqdPaPAiKHqxhH2OLGihNoZrG1yHriyfI6TO86IC4mhM5Wxo8Nd4OZ7CDbr0OgIRrmu9JBTI)vxC5ajhNoZH)CwySuGlVJstHwRgzzTfFU5WPN1w6HBp7YKYQT0d3v5HupR8qATTqWZUeiV6dC79b5zH2OLGWVHN1w6HBp7YKYQT0d3v5HupR8qATTqWZkWQx9bsD9b5zH2OLGWVHN1w6HBp7YKYQT0d3v5HupR8qATTqWZkocSuV6dKbo6dYZcTrlbHFdp7ICkqoZZcnqkkjkG)Tonhg3ZHHYKdv5WZiNrlHi0aPOKkbkGUUWH0xdcpRT0d3EwJSSgQkMqGw9QpqgyWhKN1w6HBpRrwwdv3NebEwOnAji8B4vFGmSLpipRT0d3Ew5vWvr1T9NOieA1ZcTrlbHFdV6vpRlbw4qAt9b5dKbFqEwBPhU9SMRRSKQl(q42ZcTrlbHFdV6dClFqEwBPhU9SUy9WTNfAJwcc)gE1hya9b5zH2OLGWVHN1w6HBpBOrOee1pMufGPC9SlYPa5mplXorf4bTgnHafVohgZHHY4zDjWchsBAfblClqE2Y4vFGbWhKN1w6HBplsbtQC9SqB0sq43WR(alJpipl0gTee(n8STfcEwJAiUgXq1pU1k(xDXLdepRT0d3EwJAiUgXq1pU1k(xDXLdeV6vpR4iWs9b5dKbFqEwOnAji8B4zxKtbYzE2foKgxDXxROCyCpNaKdv5OMeAnkaWfivKsm1kGWi0gTee5Wmh(Yra0V)pYdAbOQfFU540zocG(9)rfx6TQ0staXNBooDMd0aPOKOa(360C2Cph(YbAEqJdRUySSkG)TonNnPEKdF5SvzYHQC4zKZOLqeAGuusLafqxx4q6RbroCMdN540zo8NdpJCgTeIORlKqvnsbO5WzomZHVC4ph1KqRrOuK1fVRnfIqB0sqKJtN5SWyPaxEhHsrwx8U2uisGq7AuomMZw5WPN1w6HBpl08Ggh6vFGB5dYZcTrlbHFdpl21ZIa1ZAl9WTNLNroJwcEwEM8bE2foKgxDXxROOa(360CymhgYXPZCGgifLefW)wNMZM75SvzYHQC4zKZOLqeAGuusLafqxx4q6RbrooDMd)5WZiNrlHi66cjuvJuaQNLNrQTfcE2hcQ)tkbIx9bgqFqEwOnAji8B4zxKtbYzEwEg5mAjeFiO(pPei5WmhJAa5uiclU4RlQ0staOi0gTee5WmhKliLv1ifGIIFRR4FLY(4bOCyCpNT8S2spC7z)wxX)kL9XdqE1hya8b5zH2OLGWVHNDrofiN5z5zKZOLq8HG6)KsGKdZC4lh63)h5Ecb0vAPjaueP2IYCyCphgOU540zo8Ld)54som50sQeSA6H7CyMdYfKYQAKcqrXV1v8VszF8auomUNtaYHQC4lhJAa5uikWpAjufyeejwtzomMZw5WzouLdsbtQCbrKGlEqoCMdNEwBPhU9SFRR4FLY(4biV6dSm(G8SqB0sq43WZAl9WTN9BDf)Ru2hpa5zxKtbYzEwEg5mAjeFiO(pPei5WmhKliLv1ifGIIFRR4FLY(4bOCyCpNa6zxLSKqvnsbOiFGm4vFGuhFqEwOnAji8B4zxKtbYzEwEg5mAjeFiO(pPei5Wmh(YH(9)rA51c0jG4ZnhNoZH)CutcTg5bnoSsEiUrOnAjiYHzo8NJrnGCkef4hTeQcmcIqB0sqKdNEwBPhU9S0YRfOtaE1hih2hKNfAJwcc)gEwBPhU9SHp9KMcE2f5uGCMNLNroJwcXhcQ)tkbsomZb5cszvnsbOO436k(xPSpEakN9C2YZUkzjHQAKcqr(azWR(a3EFqEwOnAji8B4zxKtbYzEwEg5mAjeFiO(pPeiEwBPhU9SHp9KMcE1RE2La5dYhid(G8SqB0sq43WZUiNcKZ8S8NdsbtQCbr0KYCyMJaRrYZvFeiQ3IYRlYHzoHgsbs1qidHUUsGq7Auo75WrpRT0d3E2LjLvBPhURYdPEw5H0ABHGNfqiOxaYR(a3YhKNfAJwcc)gEwBPhU9SHgHsqu)ysvaMY1ZUiNcKZ8Se7evGh0A0ecu85MdZC4lh1ifGg1leQkUkoiNnZzHdPXvx81kkkG)TonhhjhgILjhNoZzHdPXvx81kkkG)Tonhg3Zz5wdTsRixOf5WPNDvYscv1ifGI8bYGx9bgqFqEwOnAji8B4zxKtbYzEwIDIkWdAnAcbkEDomMta5yoCqoe7evGh0A0ecuu8iME4ohM5SWH04Ql(AfffW)wNMdJ75SCRHwPvKl0cpRT0d3E2qJqjiQFmPkat56vFGbWhKNfAJwcc)gE2f5uGCMNL)CqkysLliIeCXdYHzocSgjpx9rGOElkVUihM5WFocG(9)rEqlavT4ZnhM5Wxo8NJAsO1i6rRa5)kGi0gTee540zo8NJrnGCkerCj4Naev07)XltpChH2OLGihNoZrG1yHriyfIUHpPEUYdi5WyomKdZC4lhKliLv1ifGIIFRR4FLY(4bOC2mhQtooDMd)5SWyPaxEh5z9H4gFU5WzoCMdZC4lh(Zrnj0ASVcUksnjLajcTrlbrooDMd)5OMeAncLISU4DTPqeAJwcICC6mNfglf4Y7iukY6I31McrceAxJYzZCktoCqoBLJJKJAsO1OaaxGurkXuRacJqB0sqKdNEwBPhU9S8GwaQAE1hyz8b5zH2OLGWVHNDrofiN5zvtcTgHsrwx8U2uicTrlbromZHVCutcTg7RGRIutsjqIqB0sqKJtN5OMeAnIE0kq(VcicTrlbromZHNroJwcr01fsOQgPa0C4mhM5SWH04Ql(AfLdJ75SCRHwPvKl0ICyMZcJLcC5DekfzDX7AtHibcTRr5SzomKdZC4lh(Zrnj0Ae9OvG8FfqeAJwcICC6mh(ZXOgqofIiUe8taIk69)4LPhUJqB0sqKJtN5iWASWieScr3WNupx5bKC2CphgYHtpRT0d3EwEwFiUE1hi1XhKNfAJwcc)gE2f5uGCMNvnj0ASVcUksnjLajcTrlbromZH)CutcTgHsrwx8U2uicTrlbromZzHdPXvx81kkhg3Zz5wdTsRixOf5Wmhbq)()ipOfGQw856zTLE42ZYZ6dX1R(a5W(G8SqB0sq43WZID9Siq9S2spC7z5zKZOLGNLNjFGN1OgqofIiUe8taIk69)4LPhUJqB0sqKdZC4lNg3veQs)(FquvJuakkhg3ZHHCC6mhKliLv1ifGIIFRR4FLY(4bOC2ZjG5WzomZHVCqOk97)brvnsbOOQrJ5bvxRfq4TYzphoMJtN5GCbPSQgPauu8BDf)Ru2hpaLdJ75qDYHtplpJuBle8SiuLN1hIBDHBXPhU9QpWT3hKNfAJwcc)gEwBPhU9SUySSsae(rwGNfkvjw1cXVw9SbOmE2pMuBOu1hidE1hi11hKNfAJwcc)gE2f5uGCMNvnj0Ae9OvG8FfqeAJwcICyMd)5GuWKkxqej4IhKdZCwySuGlVJfgHGvi(CZHzo8LdpJCgTeIiuLN1hIBDHBXPhUZXPZC4phJAa5uiI4sWpbiQO3)JxME4ocTrlbromZrG1yHriyfIe4taexJwc5WzomZzHdPXvx81kkkG)Tonhg3ZHVC4lhgYHQC2khhjhJAa5uiI4sWpbiQO3)JxME4ocTrlbroCMJJKdYfKYQAKcqrXV1v8VszF8auoCMdJupYja5WmhIDIkWdAnAcbkEDomMddB5zTLE42ZYZ6dX1R(azGJ(G8SqB0sq43WZUiNcKZ8SQjHwJHgsbs1qidHUocTrlbromZH)CqkysLliIMuMdZCcnKcKQHqgcDDLaH21OC2CphoMdZC4phbwJKNR(iqKaFcG4A0sihM5iWASWieScrceAxJYHXCcyomZHVC4phaHGEbrAjglQ4Fv5cvOHWsIH22oMKJtN5ia63)hPLySOI)vLluHgclj(CZHtpRT0d3EwEwFiUE1hidm4dYZcTrlbHFdp7ICkqoZZYFoifmPYfertkZHzog1aYPqeXLGFcqurV)hVm9WDeAJwcICyMJaRXcJqWkejWNaiUgTeYHzocSglmcbRq0n8j1ZvEajNn3ZHHCyMZchsJRU4Rvuua)BDAomUNddEwBPhU9SiUMaxEiifE1hidB5dYZcTrlbHFdp7ICkqoZZkWAK8C1hbIei0UgLdJ5eGCOkNaKJJKZYTgALwrUqlYHzo8NJaRXcJqWkejWNaiUgTe8S2spC7zHsrwx8U2uWR(aziG(G8SqB0sq43WZUiNcKZ8ScSgjpx9rGOElkVUWZAl9WTNvXLERkT0eGx9bYqa8b5zH2OLGWVHNDrofiN5zPF)FKwIXc5dPrcylnhNoZra0V)pYdAbOQfFUEwBPhU9SUy9WTx9bYqz8b5zH2OLGWVHNDrofiN5zfa97)J8GwaQAXNRN1w6HBplTeJf1)JuIx9bYa1XhKNfAJwcc)gE2f5uGCMNva0V)pYdAbOQfFUEwBPhU9S0abbekVUWR(azGd7dYZcTrlbHFdp7ICkqoZZka63)h5bTau1IpxpRT0d3E2)raAjgl8Qpqg2EFqEwOnAji8B4zxKtbYzEwbq)()ipOfGQw856zTLE42ZA9cqkXK1LjLE1hiduxFqEwOnAji8B4zTLE42ZwysyzsjqqvAmU9SlYPa5mp7cJLcC5DKh0cqvlsGq7AuomMtakJNTTqWZwysyzsjqqvAmU9QpWT4Opipl0gTee(n8S2spC7znexEwdOkXOgMuxyIj9SlYPa5mpRaOF)FKyudtQlmXKvbq)()OaxENJtN5ia63)h5bTau1Iei0UgLdJ5WahZXPZC0leQkUkoiNnZzloMdv5SWyPaxEhLMcTwnYYAlsGq7AKNTTqWZAiU8SgqvIrnmPUWet6vFGBXGpipl0gTee(n8S2spC7zLpcLabvVgDId)q1I7RE2f5uGCMNva0V)pYdAbOQfFUE22cbpR8rOeiO61OtC4hQwCF1R(a3AlFqEwOnAji8B4zTLE42ZkFiLGFOAbwkGU6kFHwb4zxKtbYzEwbq)()ipOfGQw856zBle8SYhsj4hQwGLcORUYxOvaE1h4wb0hKNfAJwcc)gEwBPhU9SfstCMIjOAiimP8WTNDrofiN5zfa97)J8GwaQAXNRNf(FyP12cbpBH0eNPycQgcctkpC7vFGBfaFqEwOnAji8B4zTLE42ZwinXzkMGQ0MOa8SlYPa5mpRaOF)FKh0cqvl(C9SW)dlT2wi4zlKM4mftqvAtuaE1h4wLXhKNfAJwcc)gEwBPhU9SU4fLGIoQbI6ch6(utpCxfaVBbE2f5uGCMNn0qkqQgczi01vceAxJYzphoMdZC4phbq)()ipOfGQw85MdZC4phbq)()OIl9wvAPjG4ZnhM5q)()yieIjLuX)Q8Torvqaleff4Y7CyMd0aPOKC2mNTNJ5WmhbwJKNR(iqKaH21OCymNa4zH)hwATTqWZUkzjXkb33QslnK6vFGBrD8b5zTLE42Z(qq9uie5zH2OLGWVHx9QNvGvFq(azWhKNfAJwcc)gEwSRNfbQN1w6HBplpJCgTe8S8m5d8SUKdtoTKkbRME4ohM5GCbPSQgPauu8BDf)Ru2hpaLdJ5eWCyMdF5iWASWieScrceAxJYzZCwySuGlVJfgHGvikEetpCNJtN54IpeUbrLwcGaLdJ5uMC40ZYZi12cbplIYZTUkzjHAHriyf8QpWT8b5zH2OLGWVHNf76zrG6zTLE42ZYZiNrlbplpt(apRl5WKtlPsWQPhUZHzoixqkRQrkaff)wxX)kL9Xdq5WyobmhM5WxocG(9)rfx6TQ0staXNBooDMdF54IpeUbrLwcGaLdJ5uMCyMd)5yudiNcr0cATI)vAjglIqB0sqKdN5WPNLNrQTfcEweLNBDvYscvYZvFeWR(adOpipl0gTee(n8SyxplcupRT0d3EwEg5mAj4z5zYh4zfa97)J8GwaQAXNBomZHVCea97)JkU0BvPLMaIp3CC6mNqdPaPAiKHqxxjqODnkhgZHJ5WzomZrG1i55QpcejqODnkhgZzlplpJuBle8Sikp3k55Qpc4vFGbWhKNfAJwcc)gE2f5uGCMNvnj0AekfzDX7AtHi0gTee5Wmh(YHVCw4qAC1fFTIYHX9CwU1qR0kYfAromZzHXsbU8ocLISU4DTPqKaH21OC2mhgYHZCC6mh(YH)C0Br51f5Wmh(YrVqihgZHboMJtN5SWH04Ql(AfLdJ75SvoCMdN5WPN1w6HBpl55Qpc4vFGLXhKNfAJwcc)gE2pMuBOu1hidEwBPhU9SUySSsae(rwGx9bsD8b5zH2OLGWVHNDrofiN5z5lh(Zrnj0Ae9OvG8FfqeAJwcICC6mh(ZHVCwySuGlVJ8S(qCJp3CyMZcJLcC5DKh0cqvlsGq7AuoBUNtaYHZC4mhM5SWH04Ql(AfffW)wNMdJ75WqouLtaZXrYHVCmQbKtHiIlb)eGOIE)pEz6H7i0gTee5WmNfglf4Y7ipRpe34ZnhoZHzoe4taexJwc5Wmh(YXn8j1ZvEajNn3ZHHCC6mhceAxJYzZ9C0BrzvVqihM5GCbPSQgPauu8BDf)Ru2hpaLdJ75eWCOkhJAa5uiI4sWpbiQO3)JxME4ocTrlbroCMdZC4lh(ZbkfzDX7AtbrooDMdbcTRr5S5Eo6TOSQxiKJJKZw5WmhKliLv1ifGIIFRR4FLY(4bOCyCpNaMdv5yudiNcrexc(jarf9(F8Y0d3rOnAjiYHZCyMd)5Gqv63)dICyMdF5OgPa0OEHqvXvXb5Wb5qGq7AuoCMdJ5eGCyMdF5eAifivdHme66kbcTRr5SNdhZXPZC4ph9wuEDromZXOgqofIiUe8taIk69)4LPhUJqB0sqKdNEwBPhU9SfgHGvWR(a5W(G8SqB0sq43WZ(XKAdLQ(azWZAl9WTN1fJLvcGWpYc8QpWT3hKNfAJwcc)gEwBPhU9SfgHGvWZUiNcKZ8S8NdpJCgTeIikp36QKLeQfgHGvihM5Wxo8NJAsO1i6rRa5)kGi0gTee540zo8NdF5SWyPaxEh5z9H4gFU5WmNfglf4Y7ipOfGQwKaH21OC2CpNaKdN5WzomZzHdPXvx81kkkG)Tonhg3ZHHCOkNaMJJKdF5yudiNcrexc(jarf9(F8Y0d3rOnAjiYHzolmwkWL3rEwFiUXNBoCMdZCiWNaiUgTeYHzo8LJB4tQNR8asoBUNdd540zoei0UgLZM75O3IYQEHqomZb5cszvnsbOO436k(xPSpEakhg3ZjG5qvog1aYPqeXLGFcqurV)hVm9WDeAJwcIC4mhM5Wxo8NdukY6I31McICC6mhceAxJYzZ9C0BrzvVqihhjNTYHzoixqkRQrkaff)wxX)kL9Xdq5W4EobmhQYXOgqofIiUe8taIk69)4LPhUJqB0sqKdN5Wmh(ZbHQ0V)he5Wmh(YrnsbOr9cHQIRIdYHdYHaH21OC4mhgZHHTYHzo8LtOHuGuneYqORRei0UgLZEoCmhNoZH)C0Br51f5WmhJAa5uiI4sWpbiQO3)JxME4ocTrlbroC6zxLSKqvnsbOiFGm4vFGuxFqEwOnAji8B4zxKtbYzEwKliLv1ifGIYHX9C2khM5qGq7AuoBMZw5qvo8LdYfKYQAKcqr5W4EoLjhoZHzolCinU6IVwr5W4EobWZAl9WTNDrUqeURke6ci1R(azGJ(G8SqB0sq43WZUiNcKZ8S8NdpJCgTeIikp3k55QpcKdZCw4qAC1fFTIYHX9CcqomZHaFcG4A0sihM5WxoUHpPEUYdi5S5EomKJtN5qGq7AuoBUNJElkR6fc5WmhKliLv1ifGIIFRR4FLY(4bOCyCpNaMdv5yudiNcrexc(jarf9(F8Y0d3rOnAjiYHZCyMdF5WFoqPiRlExBkiYXPZCiqODnkNn3ZrVfLv9cHCCKC2khM5GCbPSQgPauu8BDf)Ru2hpaLdJ75eWCOkhJAa5uiI4sWpbiQO3)JxME4ocTrlbroCMdZCuJuaAuVqOQ4Q4GC4GCiqODnkhgZjaEwBPhU9SKNR(iGx9bYad(G8SqB0sq43WZAl9WTNL8C1hb8SlYPa5mpl)5WZiNrlHiIYZTUkzjHk55QpcKdZC4phEg5mAjeruEUvYZvFeihM5SWH04Ql(AfLdJ75eGCyMdb(eaX1OLqomZHVCCdFs9CLhqYzZ9CyihNoZHaH21OC2Cph9wuw1leYHzoixqkRQrkaff)wxX)kL9Xdq5W4EobmhQYXOgqofIiUe8taIk69)4LPhUJqB0sqKdN5Wmh(YH)CGsrwx8U2uqKJtN5qGq7AuoBUNJElkR6fc54i5SvomZb5cszvnsbOO436k(xPSpEakhg3ZjG5qvog1aYPqeXLGFcqurV)hVm9WDeAJwcIC4mhM5OgPa0OEHqvXvXb5Wb5qGq7AuomMta8SRswsOQgPauKpqg8Qx9QNLhqqhU9bUfhzG6Yro8wBVNTCJ0xxG8SoQHUyIcIC4W5yl9WDoYdPOysHN1LG)Ne8SooNTbHme6AtpCNtzJlEqsHJZHRQUOTl4GloL7JoUWHbJUWN00d3lI91Grx4k4KchNdfpzj5S127qoBXrgOU5Wb5WW2VDbiajfjfoohoexRla02Lu44C4GC2gHae5STClkZrX5iGV9KAo2spCNJ8qAmPWX5Wb5u2qiMhKJAKcqR3pMu44C4GC2gHae5q9eb54OQqikh(WpfDcih8phKcMu5YzmPiPWX5q9lfwpfe5qdFmbYzHdPnnhAO4AumNTzTaxfLtJBoGRrc)pzo2spCJYb3YsIjfoohBPhUrrxcSWH0MU)LgIYKchNJT0d3OOlbw4qAtPApy7vecTA6H7KchNJT0d3OOlbw4qAtPAp4pglskCCoST5I4I1Ci2jYH(9)GihKAkkhA4JjqolCiTP5qdfxJYXAroUeGdCXQEDrohkhbUHysHJZXw6HBu0LalCiTPuThmQnxexSwrQPOKcBPhUrrxcSWH0Ms1EWMRRSKQl(q4oPWw6HBu0LalCiTPuThSlwpCNuyl9Wnk6sGfoK2uQ2do0iucI6htQcWuUo4sGfoK20kcw4wG2lJd3FNyNOc8GwJMqGIxZidLjPWw6HBu0LalCiTPuThmsbtQCtkSLE4gfDjWchsBkv7b)qq9ui0H2cHDJAiUgXq1pU1k(xDXLdKKIKchNd1Vuy9uqKdWdiLKJEHqokxihBPysohkhJNDsJwcXKchNtzdifmPYnN7NJlgHoAjKdFnohEpzdeJwc5aneEakNRZzHdPnLZKcBPhUr7uElkD4(78JuWKkxqenPmPWw6HBev7bJuWKk3KcBPhUruThmpJCgTeCOTqyhAGuusLafqxx4q6RbHd8m5d2HgifLejqb0u5IpeUbrLwcGa5iC4T18TLJGCbPSY1qkWzsHT0d3iQ2dMNroJwco0wiSJUUqcv1ifG6apt(GDKliLv1ifGIIFRR4FLY(4bOn3kPWw6HBev7b)qq9ui0H2cHDJAiUgXq1pU1k(xDXLdehU)o)ifmPYfertkzgAifivdHme66kbcTRr7CK5cJLcC5DKh0cqvlsGq7A0MmWrM8la63)h5bTau1IpxM8la63)hvCP3QslnbeFUjf2spCJOAp4LjLvBPhURYdPo0wiSJuWKkxq4W93rkysLliIeCXdskSLE4gr1EWltkR2spCxLhsDOTqyFjqoC)D(4xnj0Am0qkqQgczi01rOnAjiC6uG1yHriyfI6TO86cozYh)GJoVZ1ferJAiUgXq1pU1k(xDXLdeNo5FHXsbU8oknfATAKL1w85YzsHT0d3iQ2dEzsz1w6H7Q8qQdTfc7cSMuyl9WnIQ9GxMuwTLE4UkpK6qBHWU4iWstkSLE4gr1EWgzznuvmHaT6W93HgifLefW)wNY4odLHkEg5mAjeHgifLujqb01foK(AqKuyl9WnIQ9GnYYAO6(KiiPWw6HBev7blVcUkQUT)efHqRjfjfoohoeglf4YBusHT0d3O4sG2xMuwTLE4UkpK6qBHWoGqqVaKd3FNFKcMu5cIOjLmfynsEU6Jar9wuEDbZqdPaPAiKHqxxjqODnANJjfoohh1FoMqGYXiqopxhYb1NlKJYfYb3qoLFk3CK4YbKMtqbvwI5q9eb5uoxOZruY1f58nKcKCuUwNdhQSMJa(360CWKCk)uU4NMJ1LKdhQSgtkSLE4gfxcev7bhAekbr9JjvbykxhwLSKqvnsbOODgC4(7e7evGh0A0ecu85YKp1ifGg1leQkUkoyZfoKgxDXxROOa(36uhHHyzC6CHdPXvx81kkkG)ToLX9LBn0kTICHwWzsHJZXr9NtJZXecuoLFszoIdYP8t5EDokxiNgkvZjGCe5qopeKJJ2VSKdUZHgJq5u(PCXpnhRljhouznMuyl9WnkUeiQ2do0iucI6htQcWuUoC)DIDIkWdAnAcbkEnJbKJCaXorf4bTgnHaffpIPhUzUWH04Ql(AfffW)wNY4(YTgALwrUqlskSLE4gfxcev7bZdAbOQ5W935hPGjvUGisWfpGPaRrYZvFeiQ3IYRlyYVaOF)FKh0cqvl(CzYh)QjHwJOhTcK)RaIqB0sq40j)g1aYPqeXLGFcqurV)hVm9WDeAJwccNofynwyecwHOB4tQNR8acJmWKpKliLv1ifGIIFRR4FLY(4bOnPooDY)cJLcC5DKN1hIB85YjNm5JF1KqRX(k4Qi1KucKi0gTeeoDYVAsO1iukY6I31McrOnAjiC6CHXsbU8ocLISU4DTPqKaH21OnldhSLJOMeAnkaWfivKsm1kGWi0gTeeCMu44COET(qCZP8t5Md1VuurouLdFbEfCvKAskbId5Gj5W(OvG8Ffqo4wwso4ohgcIZTlhhnR0l8fMdhQSMJ1ICO(LIkYHaMOKC(ysonuQMJJchQSKuyl9WnkUeiQ2dMN1hIRd3Fxnj0AekfzDX7AtHi0gTeem5tnj0ASVcUksnjLajcTrlbHtNQjHwJOhTcK)RaIqB0sqWKNroJwcr01fsOQgPauozUWH04Ql(AfX4(YTgALwrUqlyUWyPaxEhHsrwx8U2uisGq7A0MmWKp(vtcTgrpAfi)xbeH2OLGWPt(nQbKtHiIlb)eGOIE)pEz6H7i0gTeeoDkWASWieScr3WNupx5bKn3zGZKchNd1R1hIBoLFk3Cc8k4Qi1KucKCOkNaX5q9lfvSD54OzLEHVWC4qL1CSwKd1l0cqvlNNBsHT0d3O4sGOApyEwFiUoC)D1KqRX(k4Qi1KucKi0gTeem5xnj0AekfzDX7AtHi0gTeemx4qAC1fFTIyCF5wdTsRixOfmfa97)J8GwaQAXNBsHJZHfGC(pPmNfomeAnhCNdxvDrBxWbxCk3hDCHddUSnEqZflfkheehk4Ygx8GGl)O8cEBqidHU20d3CW2uw324GYgqGrwCJjf2spCJIlbIQ9G5zKZOLGdTfc7iuLN1hIBDHBXPhUDGNjFWUrnGCkerCj4Naev07)XltpChH2OLGGjFnURiuL(9)GOQgPaueJ7m40jYfKYQAKcqrXV1v8VszF8a0Ea5KjFiuL(9)GOQgPauu1OX8GQR1ci8w7C0PtKliLv1ifGIIFRR4FLY(4big3PoCMuyl9WnkUeiQ2d2fJLvcGWpYcC4Jj1gkv3zWbOuLyvle)ADpaLjPWw6HBuCjquThmpRpexhU)UAsO1i6rRa5)kGi0gTeem5hPGjvUGisWfpG5cJLcC5DSWieScXNlt(4zKZOLqeHQ8S(qCRlClo9WTtN8BudiNcrexc(jarf9(F8Y0d3rOnAjiykWASWieScrc8jaIRrlbozUWH04Ql(AfffW)wNY4oF8XavB5ig1aYPqeXLGFcqurV)hVm9WDeAJwccoDeKliLv1ifGIIFRR4FLY(4biozK6raysStubEqRrtiqXRzKHTskCCouVwFiU5u(PCZXrZqkqYzBqidD92LtG4CqkysLBowlYPX5yl94b54OTn5q)(FhYPSFU6Ja50ynNRZHaFcG4MdX6cWHCepY1f5SHeJf5aie0ulN7NJXZoPrlHysHT0d3O4sGOApyEwFiUoC)D1KqRXqdPaPAiKHqxhH2OLGGj)ifmPYfertkzgAifivdHme66kbcTRrBUZrM8lWAK8C1hbIe4taexJwcmfynwyecwHibcTRrmgqM8XpGqqVGiTeJfv8VQCHk0qyjXqBBhtC6ua0V)pslXyrf)RkxOcnews85YzsHJZHLRjWLhcsroFmjhwUe8taICyF)pEz6H7KcBPhUrXLar1EWiUMaxEiifoC)D(rkysLliIMuY0OgqofIiUe8taIk69)4LPhUJqB0sqWuG1yHriyfIe4taexJwcmfynwyecwHOB4tQNR8aYM7mWCHdPXvx81kkkG)ToLXDgskCCou)srwx8U2uiNY5cDo0yLBoL9ZvFeihRf54OyecwHCmcKZZnNpMKJe3f5an(vWnPWw6HBuCjquThmukY6I31McoC)DbwJKNR(iqKaH21igdavbWrwU1qR0kYfAbt(fynwyecwHib(eaX1OLqsHT0d3O4sGOApyfx6TQ0staoC)DbwJKNR(iquVfLxxKuyl9WnkUeiQ2d2fRhUD4(70V)pslXyH8H0ibSL60PaOF)FKh0cqvl(CtkSLE4gfxcev7btlXyr9)iL4W93fa97)J8GwaQAXNBsHT0d3O4sGOApyAGGacLxx4W93fa97)J8GwaQAXNBsHT0d3O4sGOAp4)raAjglC4(7cG(9)rEqlavT4ZnPWw6HBuCjquThS1laPetwxMu6W93fa97)J8GwaQAXNBsHT0d3O4sGOAp4hcQNcHo0wiSxysyzsjqqvAmUD4(7lmwkWL3rEqlavTibcTRrmgGYKuyl9WnkUeiQ2d(HG6PqOdTfc7gIlpRbuLyudtQlmXKoC)Dbq)()iXOgMuxyIjRcG(9)rbU82Ptbq)()ipOfGQwKaH21igzGJoDQxiuvCvCWMBXrQwySuGlVJstHwRgzzTfjqODnkPWw6HBuCjquTh8db1tHqhAle2LpcLabvVgDId)q1I7RoC)Dbq)()ipOfGQw85Muyl9WnkUeiQ2d(HG6PqOdTfc7Yhsj4hQwGLcORUYxOvaoC)Dbq)()ipOfGQw85Muyl9WnkUeiQ2d(HG6PqOdW)dlT2wiSxinXzkMGQHGWKYd3oC)Dbq)()ipOfGQw85Muyl9WnkUeiQ2d(HG6PqOdW)dlT2wiSxinXzkMGQ0MOaC4(7cG(9)rEqlavT4ZnPWw6HBuCjquTh8db1tHqhG)hwATTqyFvYsIvcUVvLwAi1H7VhAifivdHme66kbcTRr7CKj)cG(9)rEqlavT4ZLj)cG(9)rfx6TQ0staXNlt63)hdHqmPKk(xLV1jQccyHOOaxEZeAGuuYMBphzkWAK8C1hbIei0UgXyaskCCoLf4BpPMZ3KsABrzoFmjNhYOLqoNcHOTlhQNiihCNZcJLcC5DmPWw6HBuCjquTh8db1tHqusrsHJZPSCeyP5iSqRaYXOp5PhGskCCou)Mh04WCmnNaqvo8vgQYP8t5MtzHLZC4qL1yooQHHG4mfKLKdUZzlQYrnsbOihYP8t5Md1l0cqvZHCWKCk)uU5e0gBRKdw5cKYpeKt52P58XKCq4qihObsrjXC2gjcNt52P5C)CO(LIkYzHdPX5COCw4WRlY55gtkSLE4gffhbw6o08Ggh6W93x4qAC1fFTIyCpauPMeAnkaWfivKsm1kGWi0gTeem5ta0V)pYdAbOQfFUoDka63)hvCP3QslnbeFUoDcnqkkjkG)ToDZD(GMh04WQlglRc4FRt3K6bFBvgQ4zKZOLqeAGuusLafqxx4q6RbbNC60j)8mYz0siIUUqcv1ifGYjt(4xnj0AekfzDX7AtHi0gTeeoDUWyPaxEhHsrwx8U2uisGq7AeJBXzsHT0d3OO4iWsPApyEg5mAj4qBHW(db1)jLaXbEM8b7lCinU6IVwrrb8V1PmYGtNqdKIsIc4FRt3CFRYqfpJCgTeIqdKIsQeOa66chsFniC6KFEg5mAjerxxiHQAKcqtkCCoBREk3CO(lU4RlYzdPjaKd54O36CW)C2w6JhGYX0C2IQCuJuakkMuyl9WnkkocSuQ2d(BDf)Ru2hpa5W935zKZOLq8HG6)KsGW0OgqofIWIl(6IkT0eakcTrlbbtKliLv1ifGIIFRR4FLY(4big33kPWX54O36CW)C2w6JhGYX0CyG6svoi1wuIYb)ZXr3tiGoNnKMaq5Gj5yf21inNaqvo8vgQYP8t5Mtzb)OLqoLfmc4mh1ifGIIjf2spCJIIJalLQ9G)wxX)kL9XdqoC)DEg5mAjeFiO(pPeim5J(9)rUNqaDLwAcafrQTOKXDgOUoDYh)UKdtoTKkbRME4MjYfKYQAKcqrXV1v8VszF8aeJ7bGk(mQbKtHOa)OLqvGrqKynLmUfNuHuWKkxqej4IhWjNjfoohh9wNd(NZ2sF8auokohZ1vwsoLfWeYsYPSIpeUZ5(5CTT0JhKdUZX6sYrnsbO5yAobmh1ifGIIjf2spCJIIJalLQ9G)wxX)kL9XdqoSkzjHQAKcqr7m4W935zKZOLq8HG6)KsGWe5cszvnsbOO436k(xPSpEaIX9aMuyl9WnkkocSuQ2dMwETaDcWH7VZZiNrlH4db1)jLaHjF0V)pslVwGobeFUoDYVAsO1ipOXHvYdXncTrlbbt(nQbKtHOa)OLqvGrqeAJwccotkCCobz0CGJ2tpPPqokohZ1vwsoLfWeYsYPSIpeUZX0C2kh1ifGIskSLE4gffhbwkv7bh(0tAk4WQKLeQQrkafTZGd3FNNroJwcXhcQ)tkbctKliLv1ifGIIFRR4FLY(4bO9TskSLE4gffhbwkv7bh(0tAk4W935zKZOLq8HG6)KsGKuKu44CklwOva5G5bKC0leYXOp5PhGskCCoBBx4P54Oyecwbuo4oNg3CGl5cjgPKCuJuakkNpMKJYfYXLCyYPLKdbRME4oN7NtzOkhAjacuogbYXKeWeLKZZnPWw6HBuuG1DEg5mAj4qBHWoIYZTUkzjHAHriyfCGNjFWUl5WKtlPsWQPhUzICbPSQgPauu8BDf)Ru2hpaXyazYNaRXcJqWkejqODnAZfglf4Y7yHriyfIIhX0d3oD6IpeUbrLwcGaXyz4mPWX5STDHNMtz)C1hbq5G7CACZbUKlKyKsYrnsbOOC(ysokxihxYHjNwsoeSA6H7CUFoLHQCOLaiq5yeihtsatusop3KcBPhUrrbwPApyEg5mAj4qBHWoIYZTUkzjHk55Qpc4apt(GDxYHjNwsLGvtpCZe5cszvnsbOO436k(xPSpEaIXaYKpbq)()OIl9wvAPjG4Z1Pt(CXhc3GOslbqGySmm53OgqofIOf0Af)R0smweH2OLGGtotkCCoBBx4P5u2px9rauo3phQxOfGQgvbHl9w5SH0eqWoAgsbsoBdczi015COCEU5yTiNYHC4A8GC2IQCqWc3cuos4R5G7CuUqoL9ZvFeiNYcoOKcBPhUrrbwPApyEg5mAj4qBHWoIYZTsEU6JaoWZKpyxa0V)pYdAbOQfFUm5ta0V)pQ4sVvLwAci(CD6m0qkqQgczi01vceAxJyKJCYuG1i55QpcejqODnIXTskCCoSUW6mzoL9ZvFeiheOp3C(ysou)srfjf2spCJIcSs1EWKNR(iGd3Fxnj0AekfzDX7AtHi0gTeem5JVfoKgxDXxRig3xU1qR0kYfAbZfglf4Y7iukY6I31McrceAxJ2KboD6Kp(1Br51fm5tVqGrg4OtNlCinU6IVwrmUVfNCYzsHJZXrXieSc58CPeaxhYXKiCok5auokoNhcY50CmuowoixyDMmNcObIPysoFmjhLlKJ0qAoCOYAo0WhtGCSC(xFiUajPWw6HBuuGvQ2d2fJLvcGWpYcC4Jj1gkv3ziPWw6HBuuGvQ2dUWieScoC)D(4xnj0Ae9OvG8FfqeAJwccNo5NVfglf4Y7ipRpe34ZL5cJLcC5DKh0cqvlsGq7A0M7bGtozUWH04Ql(AfffW)wNY4odufqhHpJAa5uiI4sWpbiQO3)JxME4ocTrlbbZfglf4Y7ipRpe34ZLtMe4taexJwcm5Zn8j1ZvEazZDgC6KaH21On31BrzvVqGjYfKYQAKcqrXV1v8VszF8aeJ7bKkJAa5uiI4sWpbiQO3)JxME4ocTrlbbNm5JFOuK1fVRnfeoDsGq7A0M76TOSQxi4iBXe5cszvnsbOO436k(xPSpEaIX9asLrnGCkerCj4Naev07)XltpChH2OLGGtM8Jqv63)dcM8PgPa0OEHqvXvXbCabcTRrCYyayYxOHuGuneYqORRei0UgTZrNo5xVfLxxW0OgqofIiUe8taIk69)4LPhUJqB0sqWzsHT0d3OOaRuThSlglReaHFKf4WhtQnuQUZqsHT0d3OOaRuThCHriyfCyvYscv1ifGI2zWH7VZppJCgTeIikp36QKLeQfgHGvGjF8RMeAnIE0kq(VcicTrlbHtN8Z3cJLcC5DKN1hIB85YCHXsbU8oYdAbOQfjqODnAZ9aWjNmx4qAC1fFTIIc4FRtzCNbQcOJWNrnGCkerCj4Naev07)XltpChH2OLGG5cJLcC5DKN1hIB85Yjtc8jaIRrlbM85g(K65kpGS5odoDsGq7A0M76TOSQxiWe5cszvnsbOO436k(xPSpEaIX9asLrnGCkerCj4Naev07)XltpChH2OLGGtM8XpukY6I31MccNojqODnAZD9wuw1leCKTyICbPSQgPauu8BDf)Ru2hpaX4EaPYOgqofIiUe8taIk69)4LPhUJqB0sqWjt(rOk97)bbt(uJuaAuVqOQ4Q4aoGaH21iozKHTyYxOHuGuneYqORRei0UgTZrNo5xVfLxxW0OgqofIiUe8taIk69)4LPhUJqB0sqWzsHJZHdrUqeUZjii0fqAo4wwso4oNWNupxjKJAKcqr5yAobGQC4qL1CkNl05qEDFDro4NMZ15Sfkh(EU5O4CcqoQrkafXzoysobeLdFLHQCuJuakIZKcBPhUrrbwPAp4f5cr4UQqOlGuhU)oYfKYQAKcqrmUVftceAxJ2ClQ4d5cszvnsbOig3ldNmx4qAC1fFTIyCpajfooNTfaCZ55Mtz)C1hbYX0Ccav5G7CmPmh1ifGIYHVY5cDoYJ31f5iXDroqJFfCZXAronwZb1MlIlw5mPWw6HBuuGvQ2dM8C1hbC4(78ZZiNrlHiIYZTsEU6Jamx4qAC1fFTIyCpamjWNaiUgTeyYNB4tQNR8aYM7m40jbcTRrBUR3IYQEHatKliLv1ifGIIFRR4FLY(4big3divg1aYPqeXLGFcqurV)hVm9WDeAJwccozYh)qPiRlExBkiC6KaH21On31BrzvVqWr2IjYfKYQAKcqrXV1v8VszF8aeJ7bKkJAa5uiI4sWpbiQO3)JxME4ocTrlbbNmvJuaAuVqOQ4Q4aoGaH21igdqsHT0d3OOaRuThm55Qpc4WQKLeQQrkafTZGd3FNFEg5mAjeruEU1vjljujpx9raM8ZZiNrlHiIYZTsEU6Jamx4qAC1fFTIyCpamjWNaiUgTeyYNB4tQNR8aYM7m40jbcTRrBUR3IYQEHatKliLv1ifGIIFRR4FLY(4big3divg1aYPqeXLGFcqurV)hVm9WDeAJwccozYh)qPiRlExBkiC6KaH21On31BrzvVqWr2IjYfKYQAKcqrXV1v8VszF8aeJ7bKkJAa5uiI4sWpbiQO3)JxME4ocTrlbbNmvJuaAuVqOQ4Q4aoGaH21igdqsrsHJZH6JqqVausHT0d3OiGqqVa0(c3lOvIPGO(LwiKu44C2gz5wjOCEiiNnKySiNYpLBouVqlavTCEUXC2gjcNZdb5u(PCZjOnY55Mdn8XeihlN)1hIlqYHV7NJAsOvqWzogkhjUlYXq5CAoKxJY5Jj5Wahr5iEKRlYH6fAbOQftkSLE4gfbec6fGOApyAjglQ4Fv5cvOHWsC4(7cG(9)rEqlavT4ZLjF8RMeAnQ4sVvLwAcicTrlbHtNcG(9)rfx6TQ0staXNlZfoKgxDXxROOa(360n3zWPtbq)()ipOfGQwKaH21On3zGJC60PEHqvXvXbBUZahtkSLE4gfbec6fGOAp4INreN1v8VAudiyLBsHT0d3OiGqqVaev7b)XRhcevJAa5uOsdwOd3Fh5cszvnsbOO436k(xPSpEaIX9TC6KyNOc8GwJMqGIxZi1HJmHgifLSjhMJjf2spCJIacb9cquThS7JC)sUUOslnK6W93rUGuwvJuakk(TUI)vk7JhGyCFlNoj2jQapO1OjeO41msD4ysHT0d3OiGqqVaev7bRCH6RPXVwu)yYcC4(70V)psGfLsaHQFmzbXNRtN0V)psGfLsaHQFmzb1f(1kqIi1wuUjdCmPWw6HBueqiOxaIQ9GjNRReQxxrU2cskSLE4gfbec6fGOAp4YXePGhCDLaiCB9cC4(70V)pkVpqlXyreP2IYndysHT0d3OiGqqVaev7bhcHysjv8VkFRtufeWcroC)DObsrjBwgoYK)fglf4Y7ipOfGQw85MuKu44CyvWKkxqKZ2S0d3OKchNtGxbxKAskbId5Gj5W(OvQO(LIkYb35WqqBxoST5I4I1Ck7NR(iqsHT0d3OisbtQCbXo55Qpc4W93x4qAC1fFTIyCpam5tnj0ASVcUksnjLajcTrlbHtNQjHwJOhTcK)RaIqB0sqWKp1KqRrOuK1fVRnfIqB0sqWCHXsbU8ocLISU4DTPqKaH21On33YPt(1Br51fCYKNroJwcr01fsOQgPauozQgPa0OEHqvXvXbCabcTRrmsDskCCoSpAfi)xbKdv5WYLGFcqKd77)XltpCVD5q9B0Ja5uoKZdb5GBiNcjM2K5O4Cmxxzj54OyecwHCuCokxiNq76CuJuaAo3pNtZ5q50ynhuBUiUynNsa1HCq4CmPmhSYfi5eAxNJAKcqZXOp5PhGYXLG)NgtkSLE4gfrkysLliOApyxmwwjac)ilWHpMuBOuDNHKcBPhUrrKcMu5ccQ2dUWieScoC)DJAa5uiI4sWpbiQO3)JxME4ocTrlbbt63)hrpAfi)xbeFUmPF)Fe9OvG8FfqKaH21OnzigqM8Jqv63)dIKchNd7JwbY)vaBxoBJRRSKCWKCkB4tae3Ck)uU5q)(FqKJJIriyfqjf2spCJIifmPYfeuThSlglReaHFKf4WhtQnuQUZqsHT0d3OisbtQCbbv7bxyecwbhwLSKqvnsbOODgC4(7QjHwJOhTcK)RaIqB0sqWKpceAxJ2KHTC60n8j1ZvEazZDg4KPAKcqJ6fcvfxfhWbei0UgX4wjfooh2hTcK)RaYHQCy5sWpbiYH99)4LPhUZ56CydA7YzBCDLLKdyezj5u2px9rGCuUMMt5NuMdnKdb(eaXfe58XKCCTwaH3kPWw6HBuePGjvUGGQ9Gjpx9rahU)UAsO1i6rRa5)kGi0gTeemnQbKtHiIlb)eGOIE)pEz6H7i0gTeem5xG1i55Qpce1Br51fm5zKZOLqeDDHeQQrkanPWX5W(OvG8FfqoLhCoSCj4Nae5W((F8Y0d3BxoLnyUUYsY5Jj5qJ7hkhouznhRfbJj5aLQqlaroO2CrCXAoIhX0d3XKcBPhUrrKcMu5ccQ2d2fJLvcGWpYcC4Jj1gkv3ziPWw6HBuePGjvUGGQ9GlmcbRGdRswsOQgPau0odoC)D1KqRr0JwbY)varOnAjiyAudiNcrexc(jarf9(F8Y0d3rOnAjiyQgPa0OEHqvXvXbmsGq7Aet(iqODnAtg2ENo5hHQ0V)heCMu44CyF0kq(VcihQYH6xkQy7YH6Zd6CW8ac5eqowoO2CrCXAookgHGvihYvWvZX(kqYPSFU6Ja5qdFmbYH6xkY6I31ME4oPWw6HBuePGjvUGGQ9GDXyzLai8JSah(ysTHs1DgskSLE4gfrkysLliOAp4cJqWk4W93vtcTgrpAfi)xbeH2OLGGPAsO1iukY6I31McrOnAjiyUWyPaxEhHsrwx8U2uisGq7A0MmW0La8QflrKHi55QpcWuG1i55QpcejqODnIXYqvaCKLBn0kTICHw4zrUWYh4wLH66vV69a]] )
    

end