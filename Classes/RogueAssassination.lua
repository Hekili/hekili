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

        potion = "battle_potion_of_agility",

        package = "Assassination",
    } )


    spec:RegisterSetting( "priority_rotation", false, {
        name = "Use Priority Rotation",
        desc = "If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Assassination", 20190710.2315, [[d0e8FbqisjpcvfxIueHnHIgfQItHQ0Qqb1RuvAwcWTqbAxc9lb0WKGCmvvwMkHNHQsttcQRjHY2ujIVHcsJtcv6COGyDQeL3jHkI5PsY9uP2hk0bvjsluc5HOaAIKIuxefGnskI0hjfHgjPiIojPiyLQkEPeQWmvjQ0njfrTtuvnusrYsLqvpfvMkPWvvjQyRQev9vjurAVu6VsAWsDyQwms9yvmzkUmyZi5ZcA0OKtRy1sOI61QQA2KCBjA3k9BOgoPA5iEoKPtCDvz7OuFxLuJNuQZlbwpPOMVaTFrB)z1WYzCbS8FrH(Xqked9xHIxW3FxcFzOwoPaDWYP7N)Eiy5wVeSCxkc5i0SUm41YP7fOWUXQHLdHFKdy5yjIo6YcmWWry9OJhCzGOP8PCzW7H4usGOP8eOLJ(nkrtyT0woJlGL)lk0pgsHyO)ku8c((7s4RLZFclmXYXnLmqlhRXyG1sB5ma6y54t2xkc5i0SUm4n7Ihh(G8dFYMLi6OllWadhH1JoEWLbIMYNYLbVhItjbIMYtG5h(K9NNQGS)vOaY(Ic9JHKndM9f89Y(vS8t(HpzZaz5BiGUS8dFYMbZ(sngWKDXXC(NTGZ2au(tjz7hzWB2QbjX8dFYMbZU4HsmBiBXjHGuhQy(HpzZGzFPgdyY(YbbzRjiqjkBEWpbngiBmv2ibCLWI3OLtnibz1WYHeWvclWy1WY)pRgwoyDAfySfz5oKraY4wUdUKgx1XZkOSz8o7cNnZS5jBXvWkXDczjiXv)bsewNwbMSdgmBXvWkr0Jwac1leIW60kWKnZS5jBXvWkrqBKVHVzDbIW60kWKnZSpySYGVEJG2iFdFZ6cejqPplk7RUZ(ISdgmBTYwMZ)zdZM3SzMnBNmoTcIOzdvqvCsiizZB2mZwCsiirzkHQGRMbYMbZMaL(SOSzm7lXY5hzWRLJ80LhbSIL)lSAy5G1PvGXwKLJctQlOTy5)NLZpYGxlNogRQeaHFKdyfl)81QHLdwNwbgBrwUdzeGmULZ1mqgbIiwe8ZaMk6rrHpUm4ncRtRat2mZM(rrfrpAbiuVqi(0ZMz20pkQi6rlaH6fcrcu6ZIY(QS)f5B2mZwRSrOk9JIcmwo)idETCHoHGfWkw(lSvdlhSoTcm2ISCuysDbTfl))SC(rg8A50XyvLai8JCaRy5VywnSCW60kWylYY5hzWRLl0jeSawUdzeGmULtCfSse9OfGq9cHiSoTcmzZmBEYMaL(SOSVk7FxKDWGzRx(uYORgGK9v3z)lBEZMz2ItcbjktjufC1mq2my2eO0NfLnJzFHL7uWrbvXjHGGS8)Zkw(VeRgwoyDAfySfz5oKraY4woXvWkr0Jwac1leIW60kWKnZSDndKrGiIfb)mGPIEuu4JldEJW60kWKnZS1kBdwIKNU8iquMZ)zdZMz2SDY40kiIMnubvXjHGy58Jm41YrE6YJawXYpd1QHLdwNwbgBrwokmPUG2IL)Fwo)idETC6ySQsae(roGvS8xCTAy5G1PvGXwKLZpYGxlxOtiybSChYiazClN4kyLi6rlaH6fcryDAfyYMz2UMbYiqeXIGFgWurpkk8XLbVryDAfyYMz2ItcbjktjufC1mq2mMnbk9zrzZmBEYMaL(SOSVk7Ff3SdgmBTYgHQ0pkkWKnVwUtbhfufNeccYY)pRy5NHy1WYbRtRaJTilhfMuxqBXY)plNFKbVwoDmwvjac)ihWkw()viRgwoyDAfySfz5oKraY4woXvWkr0Jwac1leIW60kWKnZSfxbRebTr(g(M1ficRtRat2mZ(GXkd(6ncAJ8n8nRlqKaL(SOSVk7FzZmBDcWUgEmXFrYtxEeiBMzBWsK80LhbIeO0NfLnJzxSS)MDHZMHZ(OxlDTRiDynwo)idETCHoHGfWkwXYbieShaz1WY)pRgwo)idETCh8EGviUaMkLYlblhSoTcm2ISIL)lSAy5G1PvGXwKL7qgbiJB5ma9JIkYgwdiIhF6zZmBEYwRSfxbRefS2ZPsRCdeH1PvGj7GbZ2a0pkQOG1EovALBG4tp7GbZ2a0pkQiBynGiEKaL(SOSV6o7FfkBEZoyWSfNecsuMsOk4QzGSV6o7FfYY5hzWRLJwHXMkMQkSGkSqzbwXYpFTAy58Jm41Yf(CIz8TIPQUMbcwyz5G1PvGXwKvS8xyRgwoyDAfySfz5oKraY4woKoOuvXjHGGIu(wXu1)7WgqzZ4D2xKDWGzt8Xub2Wkr3yqXzZMXSVKcz58Jm41YrHppeyQUMbYiqLg8sRy5VywnSCW60kWylYYDiJaKXTCiDqPQItcbbfP8TIPQ)3HnGYMX7SVi7GbZM4JPcSHvIUXGIZMnJzFjfYY5hzWRLt)rgQcMnSsRCKyfl)xIvdlNFKbVwoHfuFln(TMkfMCalhSoTcm2ISILFgQvdlNFKbVwoYORRG6SvKUFalhSoTcm2ISIL)IRvdlNFKbVwURXeLHnmBLai867bSCW60kWylYkw(ziwnSCW60kWylYYDiJaKXTCWcKWcY(QSlwHSC(rg8A5kHsmPGkMQQENXuneWlrwXkwodq5pLy1WY)pRgwoyDAfySfz5oKraY4woTYgjGRewGj6kLLZpYGxl3)583kw(VWQHLZpYGxlhsaxjSSCW60kWylYkw(5RvdlhSoTcm2ISCyDlhcelNFKbVwo2ozCAfy5y7Qhy5GfiHfejqiSz)nBD8GWlyQ0kamOSz4SzOzRjr28K9fzZWzJ0bLQYYrcKnVwo2oPUEjy5GfiHfujqiS1dUKEwWyfl)f2QHLdwNwbgBrwoSULdbILZpYGxlhBNmoTcSCSD1dSCiDqPQItcbbfP8TIPQ)3HnGY(QSVWYX2j11lblhA2qfufNecIvS8xmRgwoyDAfySfz5oKraY4woKaUsybMibh(alNFKbVwUJRuv)idERQbjwo1GK66LGLdjGRewGXkw(VeRgwoyDAfySfz58Jm41YDCLQ6hzWBvniXYPgKuxVeSChdYkw(zOwnSCW60kWylYY5hzWRL74kv1pYG3QAqILtniPUEjy5myXkw(lUwnSCW60kWylYY5hzWRL74kv1pYG3QAqILtniPUEjy5mdboIvS8ZqSAy5G1PvGXwKL7qgbiJB5GfiHfena1CgjBgVZ(xXY(B2SDY40kiclqclOsGqyRhCj9SGXY5hzWRLZjhFHQGjeyfRy5)xHSAy58Jm41Y5KJVqv)PqGLdwNwbgBrwXY)VFwnSC(rg8A5utilbvlo)mHLWkwoyDAfySfzfRy50jWbxs7Ivdl))SAy5G1PvGXwKvS8FHvdlhSoTcm2ISILF(A1WYbRtRaJTiRy5VWwnSCW60kWylYkw(lMvdlNFKbVwoxxxvqvhpi8A5G1PvGXwKvS8FjwnSC(rg8A5qc4kHLLdwNwbgBrwXYpd1QHLZpYGxlNowg8A5G1PvGXwKvS8xCTAy5G1PvGXwKLZpYGxlxPt(dMkfMunGlSSChYiazClhXhtfydReDJbfNnBgZ(xXSC6e4GlPDPIGdEnilxXSIvSCMHahXQHL)FwnSCW60kWylYYDiJaKXTChCjnUQJNvqzZ4D2fo7VzlUcwjAaqhivKqCXdHYiSoTcmzZmBEY2a0pkQiBynGiE8PNDWGzBa6hfvuWApNkTYnq8PNDWGzdlqcliAaQ5ms2xDN9ffl7VzZ2jJtRGiSajSGkbcHTEWL0ZcMSdgmBTYMTtgNwbr0SHkOkojeKS5nBMzZt2ALT4kyLiOnY3W3SUaryDAfyYoyWSpySYGVEJG2iFdFZ6cejqPplkBgZ(IS51Y5hzWRLdw2WIlTIL)lSAy5G1PvGXwKLdRB5qGy58Jm41YX2jJtRalhBx9al3bxsJR64zfu0auZzKSzm7Fzhmy2WcKWcIgGAoJK9v3zFrXY(B2SDY40kiclqclOsGqyRhCj9SGj7GbZwRSz7KXPvqenBOcQItcbXYX2j11lbl3dbvQrPaIvS8ZxRgwoyDAfySfz5oKraY4wo2ozCAfeFiOsnkfqYMz2UMbYiqeoSWZgwPvUbqryDAfyYMz2iDqPQItcbbfP8TIPQ)3HnGYMX7SVWY5hzWRLJY3kMQ(Fh2aYkw(lSvdlhSoTcm2ISChYiazClhBNmoTcIpeuPgLcizZmBEYM(rrfzngdSvALBauej(5F2mEN9pgs2bdMnpzRv26KbtgPGkblUm4nBMzJ0bLQkojeeuKY3kMQ(Fh2akBgVZUWz)nBEY21mqgbIg8JwbvdgbrIV)ZMXSViBEZ(B2ibCLWcmrco8bzZB28A58Jm41Yr5Bftv)VdBazfl)fZQHLdwNwbgBrwo)idETCu(wXu1)7WgqwUdzeGmULJTtgNwbXhcQuJsbKSzMnshuQQ4KqqqrkFRyQ6)DydOSz8oB(A5ofCuqvCsiiil))SIL)lXQHLdwNwbgBrwUdzeGmULJTtgNwbXhcQuJsbKSzMnpzt)OOI0QznOXaXNE2bdMTwzlUcwjYgwCzL8qSIW60kWKnZS1kBxZazeiAWpAfunyeeH1PvGjBETC(rg8A5OvZAqJbSILFgQvdlhSoTcm2ISC(rg8A5kFYOCbSChYiazClhBNmoTcIpeuPgLcizZmBKoOuvXjHGGIu(wXu1)7WgqzFN9fwUtbhfufNeccYY)pRy5V4A1WYbRtRaJTil3Hmcqg3YX2jJtRG4dbvQrPaILZpYGxlx5tgLlGvSIL7yqwnS8)ZQHLdwNwbgBrwUdzeGmULJ(rrfPvySr9qsKa(rYoyWSna9JIkYgwdiIhF6wo)idETC6yzWRvS8FHvdlhSoTcm2ISC(rg8A5upKqWpuneRmWw1vVspeSChYiazClNbOFuur2WAar84t3YTEjy5upKqWpuneRmWw1vVspeSILF(A1WYbRtRaJTil36LGLJTtgNwb1zfyrJuqnCcD2yLuXOZOuUmByLa(rWelNFKbVwo2ozCAfuNvGfnsb1Wj0zJvsfJoJs5YSHvc4hbtSIL)cB1WYbRtRaJTil3Hmcqg3YPv2ibCLWcmrco8bwo)idETCpeuhbkrwXYFXSAy5G1PvGXwKL7qgbiJB5ma9JIkYgwdiIhF6wo)idETC0km2uPEKcSIL)lXQHLdwNwbgBrwUdzeGmULZa0pkQiBynGiE8PB58Jm41Yrdeeq(pBOvS8ZqTAy5G1PvGXwKL7qgbiJB5ma9JIkYgwdiIhF6wo)idETCudbOvySXkw(lUwnSCW60kWylYYDiJaKXTCgG(rrfzdRbeXJpDlNFKbVwoFpasiUQECLYkw(ziwnSCW60kWylYYDiJaKXTCALnsaxjSat0vQSzMTblrYtxEeikZ5)SHzZm7shjaP6iKJqZwjqPplk77SlKLZpYGxl3XvQQFKbVv1GelNAqsD9sWYbieShazfl))kKvdlhSoTcm2ISC(rg8A5kDYFWuPWKQbCHLL7qgbiJB5i(yQaByLOBmO4tpBMzZt2ItcbjktjufC1mq2xL9bxsJR64zfu0auZzKSz4S)flw2bdM9bxsJR64zfu0auZzKSz8o7JET01UI0H1KnVwUtbhfufNeccYY)pRy5)3pRgwoyDAfySfz5oKraY4woIpMkWgwj6gdkoB2mMnFlu2my2eFmvGnSs0ngu08iUm4nBMzFWL04QoEwbfna1CgjBgVZ(OxlDTRiDynwo)idETCLo5pyQuys1aUWYkw()DHvdlhSoTcm2ISChYiazClNwzJeWvclWej4WhKnZSnyjsE6YJarzo)NnmBMzRv2gG(rrfzdRbeXJp9SzMnpzRv2IRGvIOhTaeQxieH1PvGj7GbZwRSDndKrGiIfb)mGPIEuu4JldEJW60kWKDWGzBWsm0jeSar9YNsgD1aKSzm7FzZmBEYgPdkvvCsiiOiLVvmv9)oSbu2xL9LKDWGzRv2hmwzWxVr2(oiwXNE28MnVzZmBEYwRSfxbRe3jKLGex9hiryDAfyYoyWS1kBXvWkrqBKVHVzDbIW60kWKDWGzFWyLbF9gbTr(g(M1fisGsFwu2xLDXYMbZ(ISz4SfxbRenaOdKksiU4HqzewNwbMS51Y5hzWRLJnSgqe3kw()XxRgwoyDAfySfz5oKraY4woXvWkrqBKVHVzDbIW60kWKnZS5jBXvWkXDczjiXv)bsewNwbMSdgmBXvWkr0Jwac1leIW60kWKnZSz7KXPvqenBOcQItcbjBEZMz2hCjnUQJNvqzZ4D2h9APRDfPdRjBMzFWyLbF9gbTr(g(M1fisGsFwu2xL9VSzMnpzRv2IRGvIOhTaeQxieH1PvGj7GbZwRSDndKrGiIfb)mGPIEuu4JldEJW60kWKDWGzBWsm0jeSar9YNsgD1aKSV6o7FzZRLZpYGxlhBFhelRy5)xHTAy5G1PvGXwKL7qgbiJB5exbRe3jKLGex9hiryDAfyYMz2ALT4kyLiOnY3W3SUaryDAfyYMz2hCjnUQJNvqzZ4D2h9APRDfPdRjBMzBa6hfvKnSgqep(0TC(rg8A5y77Gyzfl))kMvdlhSoTcm2ISCyDlhcelNFKbVwo2ozCAfy5y7Qhy5CndKrGiIfb)mGPIEuu4JldEJW60kWKnZS5j7fVveQs)OOatvCsiiOSz8o7Fzhmy2iDqPQItcbbfP8TIPQ)3HnGY(oB(MnVzZmBEYgHQ0pkkWufNeccQ60y2qv3xduoNSVZUqzhmy2iDqPQItcbbfP8TIPQ)3HnGYMX7SVKS51YX2j11lblhcvz77Gyvp41mYGxRy5)3Ly1WYbRtRaJTilNFKbVwoDmwvjac)ihWYbAleV6L43kwUcxmlhfMuxqBXY)pRy5)hd1QHLdwNwbgBrwUdzeGmULtCfSse9OfGq9cHiSoTcmzZmBTYgjGRewGjsWHpiBMzFWyLbF9gdDcblq8PNnZS5jB2ozCAferOkBFheR6bVMrg8MDWGzRv2UMbYiqeXIGFgWurpkk8XLbVryDAfyYMz2gSedDcblqKaueaXYPvq28MnZSp4sACvhpRGIgGAoJKnJ3zZt28K9VS)M9fzZWz7AgiJarelc(zatf9OOWhxg8gH1PvGjBEZMHZgPdkvvCsiiOiLVvmv9)oSbu28MnZSj(yQaByLOBmO4SzZy2)UWY5hzWRLJTVdILvS8)R4A1WYbRtRaJTil3Hmcqg3YjUcwjw6ibivhHCeA2iSoTcmzZmBTYgjGRewGj6kv2mZU0rcqQoc5i0Svcu6ZIY(Q7Slu2mZwRSnyjsE6YJarcqraelNwbzZmBdwIHoHGfisGsFwu2mMnFTC(rg8A5y77Gyzfl))yiwnSCW60kWylYYDiJaKXTCALnsaxjSat0vQSzMTRzGmcerSi4Nbmv0JIcFCzWBewNwbMSzMTblXqNqWcejafbqSCAfKnZSnyjg6ecwGOE5tjJUAas2xDN9VSzM9bxsJR64zfu0auZzKSz8o7Fwo)idETCiwUbFDjOmwXY)ffYQHLdwNwbgBrwUdzeGmULZGLi5PlpcejqPplkBgZUWz)n7cNndN9rVw6Axr6WAYMz2ALTblXqNqWcejafbqSCAfy58Jm41YbAJ8n8nRlGvS8FXpRgwoyDAfySfz5oKraY4wodwIKNU8iquMZ)zdTC(rg8A5eS2ZPsRCdyfRy5myXQHL)FwnSCW60kWylYYH1TCiqSC(rg8A5y7KXPvGLJTREGLtNmyYifujyXLbVzZmBKoOuvXjHGGIu(wXu1)7WgqzZy28nBMzZt2gSedDcblqKaL(SOSVk7dgRm4R3yOtiybIMhXLbVzhmy264bHxWuPvayqzZy2flBETCSDsD9sWYH(p61tbhfudDcblGvS8FHvdlhSoTcm2ISCyDlhcelNFKbVwo2ozCAfy5y7Qhy50jdMmsbvcwCzWB2mZgPdkvvCsiiOiLVvmv9)oSbu2mMnFZMz28KTbOFuurbR9CQ0k3aXNE2bdMnpzRJheEbtLwbGbLnJzxSSzMTwz7AgiJar0bwPIPQ0km2eH1PvGjBEZMxlhBNuxVeSCO)JE9uWrbvYtxEeWkw(5RvdlhSoTcm2ISCyDlhcelNFKbVwo2ozCAfy5y7Qhy5ma9JIkYgwdiIhF6zZmBdq)OOIcw75uPvUbIp9SzMTblrYtxEeisGsFwu2mM9fwo2oPUEjy5q)h9k5Plpcyfl)f2QHLdwNwbgBrwUdzeGmULtCfSse0g5B4BwxGiSoTcmzZmBEYMNSp4sACvhpRGYMX7Sp61sx7kshwt2mZ(GXkd(6ncAJ8n8nRlqKaL(SOSVk7FzZB2bdMnpzRv2YC(pBy2mZMNSLPeYMXS)vOSdgm7dUKgx1XZkOSz8o7lYM3S5nBETC(rg8A5ipD5raRy5VywnSCW60kWylYYrHj1f0wS8)ZY5hzWRLthJvvcGWpYbSIL)lXQHLdwNwbgBrwUdzeGmULJNS1kBXvWkr0Jwac1leIW60kWKDWGzRv28K9bJvg81BKTVdIv8PNnZSpySYGVEJSH1aI4rcu6ZIY(Q7SlC28MnVzZm7dUKgx1XZkOObOMZizZ4D2)Y(B28nBgoBEY21mqgbIiwe8ZaMk6rrHpUm4ncRtRat2mZ(GXkd(6nY23bXk(0ZM3SzMnbOiaILtRGSzMnpzRx(uYORgGK9v3z)l7GbZMaL(SOSV6oBzo)RYuczZmBKoOuvXjHGGIu(wXu1)7WgqzZ4D28n7Vz7AgiJarelc(zatf9OOWhxg8gH1PvGjBEZMz28KTwzdAJ8n8nRlGj7GbZMaL(SOSV6oBzo)RYuczZWzFr2mZgPdkvvCsiiOiLVvmv9)oSbu2mENnFZ(B2UMbYiqeXIGFgWurpkk8XLbVryDAfyYM3SzMTwzJqv6hffyYMz28KT4KqqIYucvbxndKndMnbk9zrzZB2mMDHZMz28KDPJeGuDeYrOzReO0NfL9D2fk7GbZwRSL58F2WS51Y5hzWRLl0jeSawXYpd1QHLdwNwbgBrwokmPUG2IL)Fwo)idETC6ySQsae(roGvS8xCTAy5G1PvGXwKLZpYGxlxOtiybSChYiazClNwzZ2jJtRGi6)OxpfCuqn0jeSazZmBEYwRSfxbRerpAbiuVqicRtRat2bdMTwzZt2hmwzWxVr2(oiwXNE2mZ(GXkd(6nYgwdiIhjqPplk7RUZUWzZB28MnZSp4sACvhpRGIgGAoJKnJ3z)l7VzZ3Sz4S5jBxZazeiIyrWpdyQOhff(4YG3iSoTcmzZm7dgRm4R3iBFheR4tpBEZMz2eGIaiwoTcYMz28KTE5tjJUAas2xDN9VSdgmBcu6ZIY(Q7SL58VktjKnZSr6GsvfNeccks5Bftv)VdBaLnJ3zZ3S)MTRzGmcerSi4Nbmv0JIcFCzWBewNwbMS5nBMzZt2ALnOnY3W3SUaMSdgmBcu6ZIY(Q7SL58VktjKndN9fzZmBKoOuvXjHGGIu(wXu1)7WgqzZ4D28n7Vz7AgiJarelc(zatf9OOWhxg8gH1PvGjBEZMz2ALncvPFuuGjBMzZt2ItcbjktjufC1mq2my2eO0NfLnVzZy2)UiBMzZt2Losas1rihHMTsGsFwu23zxOSdgmBTYwMZ)zdZMxl3PGJcQItcbbz5)NvS8ZqSAy5G1PvGXwKL7qgbiJB5q6GsvfNecckBgVZ(ISzMnbk9zrzFv2xK93S5jBKoOuvXjHGGYMX7Slw28MnZSp4sACvhpRGYMX7SlSLZpYGxl3HmLi8wfOuhqIvS8)RqwnSCW60kWylYYDiJaKXTCALnBNmoTcIO)JEL80LhbYMz2hCjnUQJNvqzZ4D2foBMztakcGy50kiBMzZt26LpLm6QbizF1D2)YoyWSjqPplk7RUZwMZ)QmLq2mZgPdkvvCsiiOiLVvmv9)oSbu2mENnFZ(B2UMbYiqeXIGFgWurpkk8XLbVryDAfyYM3SzMnpzRv2G2iFdFZ6cyYoyWSjqPplk7RUZwMZ)QmLq2mC2xKnZSr6GsvfNeccks5Bftv)VdBaLnJ3zZ3S)MTRzGmcerSi4Nbmv0JIcFCzWBewNwbMS5nBMzlojeKOmLqvWvZazZGztGsFwu2mMDHTC(rg8A5ipD5raRy5)3pRgwoyDAfySfz58Jm41YrE6YJawUdzeGmULtRSz7KXPvqe9F0RNcokOsE6YJazZmBTYMTtgNwbr0)rVsE6YJazZm7dUKgx1XZkOSz8o7cNnZSjafbqSCAfKnZS5jB9YNsgD1aKSV6o7Fzhmy2eO0NfL9v3zlZ5FvMsiBMzJ0bLQkojeeuKY3kMQ(Fh2akBgVZMVz)nBxZazeiIyrWpdyQOhff(4YG3iSoTcmzZB2mZMNS1kBqBKVHVzDbmzhmy2eO0NfL9v3zlZ5FvMsiBgo7lYMz2iDqPQItcbbfP8TIPQ)3HnGYMX7S5B2FZ21mqgbIiwe8ZaMk6rrHpUm4ncRtRat28MnZSfNecsuMsOk4QzGSzWSjqPplkBgZUWwUtbhfufNeccYY)pRyfRy5yde0Gxl)xuOFmKcXqledj(RWwURDYoBiYYPjuQJjcyYMHMTFKbVzRgKGI5hlhshow(VOymelNobtnkWYXNSVueYrOzDzWB2fpo8b5h(Knlr0rxwGbgocRhD8GldenLpLldEpeNscenLNaZp8j7ppvbz)RqbK9ff6hdjBgm7l47L9Ry5N8dFYMbYY3qaDz5h(KndM9LAmGj7IJ58pBbNTbO8NsY2pYG3SvdsI5h(KndMDXdLy2q2ItcbPouX8dFYMbZ(sngWK9LdcYwtqGsu28GFcAmq2yQSrc4kHfVX8t(HpzZa0gopbmztduycK9bxs7s20q4SOy2x65a6ck7fVmilNus9uz7hzWlkB8QkiMF8Jm4ff1jWbxs7YnLYr)Zp(rg8II6e4GlPD57DG(lSewXLbV5h)idErrDcCWL0U89oqkm2KF4t2CRRJyHLSj(yYM(rrbMSrIlOSPbkmbY(GlPDjBAiCwu2(AYwNamOowKzdZEqzBWleZp(rg8II6e4GlPD57DGO11rSWsfjUGYp(rg8II6e4GlPD57DGUUUQGQoEq4n)4hzWlkQtGdUK2LV3bIeWvcR8JFKbVOOobo4sAx(EhOowg8MF8Jm4ff1jWbxs7Y37alDYFWuPWKQbCHva6e4GlPDPIGdEnO7IfWqDt8Xub2Wkr3yqXzz8xXYp5h(KndqB48eWKnWgifKTmLq2cliB)iys2dkBNTpkNwbX8dFYU4bKaUsyL9qLTogHgAfKnploB2p1ceNwbzdluoak7zZ(GlPDH38JFKbVO7)Z5Fad1TwibCLWcmrxPYp(rg8I(EhisaxjSYp(rg8I(EhiBNmoTccy9s4gwGewqLaHWwp4s6zbtaSD1dUHfiHfejqiSF1XdcVGPsRaWGyygQMe8CbdJ0bLQYYrcWB(XpYGx037az7KXPvqaRxc3OzdvqvCsiibW2vp4gPdkvvCsiiOiLVvmv9)oSb0vxKF8Jm4f99oWJRuv)idERQbjbSEjCJeWvclWeWqDJeWvclWej4WhKF8Jm4f99oWJRuv)idERQbjbSEjCFmO8JFKbVOV3bECLQ6hzWBvnijG1lHBdwYp(rg8I(Eh4XvQQFKbVv1GKawVeUndbos(XpYGx037aDYXxOkycbwjGH6gwGewq0auZzegV)vSVSDY40kiclqclOsGqyRhCj9SGj)4hzWl67DGo54lu1FkeKF8Jm4f99oq1eYsq1IZptyjSs(j)WNSzGySYGVEr5h)idErXJbDRJLbVbmu30pkQiTcJnQhsIeWpsWGgG(rrfzdRbeXJp98JFKbVO4XG(Eh4db1rGYawVeUvpKqWpuneRmWw1vVspecyOUna9JIkYgwdiIhF65h(KTMgO8NsYwdYS)bj7hYdHll7lheKnEZ(GXkd(6nMF8Jm4ffpg037aFiOocugW6LWnBNmoTcQZkWIgPGA4e6SXkPIrNrPCz2Wkb8JGj5h)idErXJb99oWhcQJaLOagQBTqc4kHfyIeC4dYp(rg8IIhd67DG0km2uPEKccyOUna9JIkYgwdiIhF65h)idErXJb99oqAGGaY)zddyOUna9JIkYgwdiIhF65h)idErXJb99oqQHa0km2eWqDBa6hfvKnSgqep(0Zp(rg8IIhd67DG(EaKqCv94kvad1TbOFuur2WAar84tp)4hzWlkEmOV3bECLQ6hzWBvnijG1lHBaHG9aOagQBTqc4kHfyIUsX0GLi5PlpceL58F2qMLosas1rihHMTsGsFw0DHYp8jBnbQSDJbLTtGSF6bKnAhDiBHfKnEHSVEewzRWxdijBn0qthZ(YbbzFnlyZ2uWSHzt5ibizlS8nBgOMkBdqnNrYgtY(6ryHFs2(wq2mqnvm)4hzWlkEmOV3bw6K)GPsHjvd4cRaofCuqvCsiiO7Fbmu3eFmvGnSs0ngu8PZKhXjHGeLPeQcUAg4QdUKgx1XZkOObOMZim8VyXcg8GlPXvD8SckAaQ5mcJ3h9APRDfPdRH38dFYwtGk7fNTBmOSVEuQSndK91JWA2Sfwq2lOTKnFlekGSFiiBnzknD24nBAmcL91JWc)KS9TGSzGAQy(XpYGxu8yqFVdS0j)btLctQgWfwbmu3eFmvGnSs0nguCwg5BHyqIpMkWgwj6gdkAEexg8Y8GlPXvD8SckAaQ5mcJ3h9APRDfPdRj)4hzWlkEmOV3bYgwdiIhWqDRfsaxjSatKGdFatdwIKNU8iquMZ)zdzQLbOFuur2WAar84tNjpAjUcwjIE0cqOEHqewNwbMGb1Y1mqgbIiwe8ZaMk6rrHpUm4ncRtRatWGgSedDcblquV8PKrxnaHXFm5bPdkvvCsiiOiLVvmv9)oSb0vxsWGADWyLbF9gz77GyfF68YltE0sCfSsCNqwcsC1FGeH1PvGjyqTexbRebTr(g(M1ficRtRatWGhmwzWxVrqBKVHVzDbIeO0NfDvXyWlyyXvWkrda6aPIeIlEiugH1PvGH38dFY(Y77GyL91JWkBgG2OWS)Mnp8pHSeK4Q)ajGSXKS5E0cqOEHq24vvq24n7FAW7LLTMSR9u(kZMbQPY2xt2maTrHzta3uq2uys2lOTKTMidutNF8Jm4ffpg037az77GyfWqDlUcwjcAJ8n8nRlqewNwbgM8iUcwjUtilbjU6pqIW60kWemO4kyLi6rlaH6fcryDAfyyY2jJtRGiA2qfufNeccVmp4sACvhpRGy8(OxlDTRiDynmpySYGVEJG2iFdFZ6cejqPpl6QFm5rlXvWkr0Jwac1leIW60kWemOwUMbYiqeXIGFgWurpkk8XLbVryDAfycg0GLyOtiybI6LpLm6QbixD)J38dFY(Y77GyL91JWkB(NqwcsC1FGK93S5hNndqBu4LLTMSR9u(kZMbQPY2xt2xEynGiE2p98JFKbVO4XG(EhiBFheRagQBXvWkXDczjiXv)bsewNwbgMAjUcwjcAJ8n8nRlqewNwbgMhCjnUQJNvqmEF0RLU2vKoSgMgG(rrfzdRbeXJp98dFYMdGSPEkv2hCzjSs24nBwIOJUSadmCewp64bxgyX7SHLfwzegudgyGfpo8bbE98Fc8srihHM1LbVm4LQPUCzWIhqGtoSI5h)idErXJb99oq2ozCAfeW6LWncvz77Gyvp41mYG3ay7QhC7AgiJarelc(zatf9OOWhxg8gH1PvGHjplERiuL(rrbMQ4KqqqmE)lyqKoOuvXjHGGIu(wXu1)7Wgq38LxM8Gqv6hffyQItcbbvDAmBOQ7RbkNZDHcgePdkvvCsiiOiLVvmv9)oSbeJ3xcV5h)idErXJb99oqDmwvjac)ihiakmPUG2Y9VaaTfIx9s8BL7cxS8JFKbVO4XG(EhiBFheRagQBXvWkr0Jwac1leIW60kWWulKaUsybMibh(aMhmwzWxVXqNqWceF6m5HTtgNwbreQY23bXQEWRzKbVbdQLRzGmcerSi4Nbmv0JIcFCzWBewNwbgMgSedDcblqKaueaXYPvaVmp4sACvhpRGIgGAoJW4np8877fmSRzGmcerSi4Nbmv0JIcFCzWBewNwbgEzyKoOuvXjHGGIu(wXu1)7Wgq8YK4JPcSHvIUXGIZY4VlYp8j7lVVdIv2xpcRS1KDKaKSVueYrZEzzZpoBKaUsyLTVMSxC2(rg2q2AYxA20pkQaYU4F6YJazVyj7zZMaueaXkBIVHq(XpYGxu8yqFVdKTVdIvad1T4kyLyPJeGuDeYrOzJW60kWWulKaUsybMORumlDKaKQJqocnBLaL(SORUletTmyjsE6YJarcqraelNwbmnyjg6ecwGibk9zrmY38dFYMJLBWxxckt2uys2CSi4NbmzZ9OOWhxg8MF8Jm4ffpg037arSCd(6sqzcyOU1cjGRewGj6kftxZazeiIyrWpdyQOhff(4YG3iSoTcmmnyjg6ecwGibOiaILtRaMgSedDcblquV8PKrxna5Q7Fmp4sACvhpRGIgGAoJW49V8dFYMbOnY3W3SUazFnlyZMglSYU4F6YJaz7RjBnrNqWcKTtGSF6ztHjzRWBy2WIFHSYp(rg8IIhd67DGG2iFdFZ6ceWqDBWsK80LhbIeO0NfXyH)wyg(OxlDTRiDynm1YGLyOtiybIeGIaiwoTcYp(rg8IIhd67DGcw75uPvUbcyOUnyjsE6YJarzo)Nnm)KF4t2A6HahjBJx6Hq2o9Ogzau(HpzZaw2WIlZ2LSl83S5PyFZ(6ryLTMMJ3SzGAQy2AcLLGzCbufKnEZ(IVzlojeeuazF9iSY(YdRbeXdiBmj7RhHv2AuuXjzJfwa56bbzFTps2uys2iCjKnSajSGy2xQcHZ(AFKShQSzaAJcZ(GlPXzpOSp4YzdZ(PhZp(rg8IIMHah5gw2WIldyOUp4sACvhpRGy8UWFfxbRenaOdKksiU4HqzewNwbgM8ya6hfvKnSgqep(0dg0a0pkQOG1EovALBG4tpyqybsybrdqnNrU6(II9LTtgNwbrybsybvcecB9GlPNfmbdQfBNmoTcIOzdvqvCsii8YKhTexbRebTr(g(M1ficRtRatWGhmwzWxVrqBKVHVzDbIeO0NfX4f8MF8Jm4ffndboY37az7KXPvqaRxc3peuPgLcibW2vp4(GlPXvD8SckAaQ5mcJ)cgewGewq0auZzKRUVOyFz7KXPvqewGewqLaHWwp4s6zbtWGAX2jJtRGiA2qfufNecs(HpzxC6iSYMbCyHNnm7IuUbqbKTMuFZgtLDXXoSbu2UK9fFZwCsiiOy(XpYGxu0me4iFVdKY3kMQ(Fh2akGH6MTtgNwbXhcQuJsbeMUMbYiqeoSWZgwPvUbqryDAfyyI0bLQkojeeuKY3kMQ(Fh2aIX7lYp8jBnP(MnMk7IJDydOSDj7FmKVzJe)8hLnMkBnjhJb2Sls5gaLnMKTh6ZIKSl83S5PyFZ(6ryLTMg)Ovq2AAmc4nBXjHGGI5h)idErrZqGJ89oqkFRyQ6)DydOagQB2ozCAfeFiOsnkfqyYd9JIkYAmgyR0k3aOis8ZFgV)XqcgKhT0jdMmsbvcwCzWltKoOuvXjHGGIu(wXu1)7WgqmEx4V84AgiJard(rRGQbJGiX3)mEbVFrc4kHfyIeC4d4L38dFYwtQVzJPYU4yh2akBbNTRRRkiBnn4gvbzRPWdcVzpuzpRFKHnKnEZ23cYwCsiiz7s28nBXjHGGI5h)idErrZqGJ89oqkFRyQ6)DydOaofCuqvCsiiO7Fbmu3SDY40ki(qqLAukGWePdkvvCsiiOiLVvmv9)oSbeJ38n)4hzWlkAgcCKV3bsRM1GgdeWqDZ2jJtRG4dbvQrPactEOFuurA1Sg0yG4tpyqTexbRezdlUSsEiwryDAfyyQLRzGmcen4hTcQgmcIW60kWWB(HpzRHtZGAYpzuUazl4SDDDvbzRPb3OkiBnfEq4nBxY(ISfNecck)4hzWlkAgcCKV3bw(Kr5ceWPGJcQItcbbD)lGH6MTtgNwbXhcQuJsbeMiDqPQItcbbfP8TIPQ)3HnGUVi)4hzWlkAgcCKV3bw(Kr5ceWqDZ2jJtRG4dbvQrPas(j)WNS10EPhczJzdKSLPeY2Ph1idGYp8j7l3PCKS1eDcblakB8M9IxguNmLeNuq2ItcbbLnfMKTWcYwNmyYifKnblUm4n7Hk7I9nBAfagu2obY2veWnfK9tp)4hzWlkAWYnBNmoTccy9s4g9F0RNcokOg6ecwGay7QhCRtgmzKcQeS4YGxMiDqPQItcbbfP8TIPQ)3HnGyKVm5XGLyOtiybIeO0NfD1bJvg81Bm0jeSarZJ4YG3Gb1XdcVGPsRaWGySy8MF4t2xUt5izx8pD5rau24n7fVmOozkjoPGSfNecckBkmjBHfKTozWKrkiBcwCzWB2dv2f7B20kamOSDcKTRiGBki7NE(XpYGxu0GLV3bY2jJtRGawVeUr)h96PGJcQKNU8iqaSD1dU1jdMmsbvcwCzWltKoOuvXjHGGIu(wXu1)7WgqmYxM8ya6hfvuWApNkTYnq8Phmip64bHxWuPvayqmwmMA5AgiJar0bwPIPQ0km2eH1PvGHxEZp8j7l3PCKSl(NU8iak7Hk7lpSgqe)RgyTNt2fPCdK9GY(PNTVMSVgYMLZgY(IVzJGdEnOSvaLKnEZwybzx8pD5rGS10ynYp(rg8IIgS89oq2ozCAfeW6LWn6)OxjpD5rGay7QhCBa6hfvKnSgqep(0zAa6hfvuWApNkTYnq8PZ0GLi5PlpcejqPplIXlYp8jBoD4mUk7I)PlpcKncKNE2uys2maTrH5h)idErrdw(Ehi5PlpceWqDlUcwjcAJ8n8nRlqewNwbgM8WZbxsJR64zfeJ3h9APRDfPdRH5bJvg81Be0g5B4BwxGibk9zrx9J3Gb5rlzo)NnKjpYucm(RqbdEWL04QoEwbX49f8YlV5h(KTMOtiybY(P)ha9aY2viC2czau2co7hcYEKSDu2E2iD4mUk7qybIlys2uys2cliBLJKSzGAQSPbkmbY2ZMA2bXci5h)idErrdw(EhOogRQeaHFKdeafMuxqB5(x(XpYGxu0GLV3bg6ecwGagQBE0sCfSse9OfGq9cHiSoTcmbdQfphmwzWxVr2(oiwXNoZdgRm4R3iBynGiEKaL(SORUlmV8Y8GlPXvD8SckAaQ5mcJ3)(YxgMhxZazeiIyrWpdyQOhff(4YG3iSoTcmmpySYGVEJS9DqSIpDEzsakcGy50kGjp6LpLm6QbixD)lyqcu6ZIU6wMZ)QmLatKoOuvXjHGGIu(wXu1)7WgqmEZ3VUMbYiqeXIGFgWurpkk8XLbVryDAfy4LjpAbAJ8n8nRlGjyqcu6ZIU6wMZ)QmLadFbtKoOuvXjHGGIu(wXu1)7WgqmEZ3VUMbYiqeXIGFgWurpkk8XLbVryDAfy4LPwiuL(rrbgM8iojeKOmLqvWvZamibk9zr8YyHzYtPJeGuDeYrOzReO0NfDxOGb1sMZ)zd5n)4hzWlkAWY37a1XyvLai8JCGaOWK6cAl3)Yp(rg8IIgS89oWqNqWceWPGJcQItcbbD)lGH6wl2ozCAfer)h96PGJcQHoHGfGjpAjUcwjIE0cqOEHqewNwbMGb1INdgRm4R3iBFheR4tN5bJvg81BKnSgqepsGsFw0v3fMxEzEWL04QoEwbfna1CgHX7FF5ldZJRzGmcerSi4Nbmv0JIcFCzWBewNwbgMhmwzWxVr2(oiwXNoVmjafbqSCAfWKh9YNsgD1aKRU)fmibk9zrxDlZ5FvMsGjshuQQ4KqqqrkFRyQ6)DydigV57xxZazeiIyrWpdyQOhff(4YG3iSoTcm8YKhTaTr(g(M1fWemibk9zrxDlZ5FvMsGHVGjshuQQ4KqqqrkFRyQ6)DydigV57xxZazeiIyrWpdyQOhff(4YG3iSoTcm8YuleQs)OOadtEeNecsuMsOk4QzagKaL(SiEz83fm5P0rcqQoc5i0Svcu6ZIUluWGAjZ5)SH8MF4t2mqYuIWB2AaL6asYgVQcYgVzx(uYORGSfNecckBxYUWFZMbQPY(AwWMn5T7SHzJFs2ZM9fOS55PNTGZUWzlojeeeVzJjzZxu28uSVzlojeeeV5h)idErrdw(Eh4HmLi8wfOuhqsad1nshuQQ4KqqqmEFbtcu6ZIU6IV8G0bLQkojeeeJ3fJxMhCjnUQJNvqmEx48dFYU4aa9SF6zx8pD5rGSDj7c)nB8MTRuzlojeeu28CnlyZwnSNnmBfEdZgw8lKv2(AYEXs2O11rSWcV5h)idErrdw(Ehi5PlpceWqDRfBNmoTcIO)JEL80LhbyEWL04QoEwbX4DHzsakcGy50kGjp6LpLm6QbixD)lyqcu6ZIU6wMZ)QmLatKoOuvXjHGGIu(wXu1)7WgqmEZ3VUMbYiqeXIGFgWurpkk8XLbVryDAfy4LjpAbAJ8n8nRlGjyqcu6ZIU6wMZ)QmLadFbtKoOuvXjHGGIu(wXu1)7WgqmEZ3VUMbYiqeXIGFgWurpkk8XLbVryDAfy4LP4KqqIYucvbxndWGeO0NfXyHZp(rg8IIgS89oqYtxEeiGtbhfufNecc6(xad1TwSDY40kiI(p61tbhfujpD5raMAX2jJtRGi6)OxjpD5raMhCjnUQJNvqmExyMeGIaiwoTcyYJE5tjJUAaYv3)cgKaL(SORUL58VktjWePdkvvCsiiOiLVvmv9)oSbeJ389RRzGmcerSi4Nbmv0JIcFCzWBewNwbgEzYJwG2iFdFZ6cycgKaL(SORUL58VktjWWxWePdkvvCsiiOiLVvmv9)oSbeJ389RRzGmcerSi4Nbmv0JIcFCzWBewNwbgEzkojeKOmLqvWvZamibk9zrmw48t(HpzZaqiypak)4hzWlkcieShaDFW7bwH4cyQukVeYp8j7lvDTxak7hcYUifgBY(6ryL9LhwdiIN9tpM9LQq4SFii7RhHv2Auu2p9S5zOYwCfScy4nBhLTcVHz7OShjBYBrztHjz)RqOSnpYSHzF5H1aI4X8JFKbVOiGqWEa037aPvySPIPQclOcluwqad1TbOFuur2WAar84tNjpAjUcwjkyTNtLw5gicRtRatWGgG(rrffS2ZPsRCdeF6bdAa6hfvKnSgqepsGsFw0v3)keVbdkojeKOmLqvWvZaxD)Rq5h)idErraHG9aOV3bg(CIz8TIPQUMbcwyLF8Jm4ffbec2dG(Ehif(8qGP6AgiJavAWldyOUr6GsvfNeccks5Bftv)VdBaX49fbds8Xub2Wkr3yqXzz8sku(XpYGxueqiypa67DG6pYqvWSHvALJKagQBKoOuvXjHGGIu(wXu1)7WgqmEFrWGeFmvGnSs0nguCwgVKcLF8Jm4ffbec2dG(EhOWcQVLg)wtLctoq(XpYGxueqiypa67DGKrxxb1zRiD)a5h)idErraHG9aOV3bEnMOmSHzReaHxFpq(XpYGxueqiypa67DGLqjMuqftvvVZyQgc4LOagQBybsybxvScLFYp8jBobCLWcmzFPhzWlk)WNS5FczHex9hibKnMKn3Jw(Ya0gfMnEZ(Ngxw2CRRJyHLSl(NU8iq(XpYGxuejGRewG5M80LhbcyOUp4sACvhpRGy8UWm5rCfSsCNqwcsC1FGeH1PvGjyqXvWkr0Jwac1leIW60kWWKhXvWkrqBKVHVzDbIW60kWW8GXkd(6ncAJ8n8nRlqKaL(SORUViyqTK58F2qEzY2jJtRGiA2qfufNeccVmfNecsuMsOk4QzagKaL(SigVK8dFYM7rlaH6fcz)nBowe8ZaMS5Euu4JldEVSSzal6rGSVgY(HGSXlKDOct7QSfC2UUUQGS1eDcblq2coBHfKDPpB2Itcbj7Hk7rYEqzVyjB066iwyj7cajGSr4SDLkBSWcizx6ZMT4KqqY2Ph1idGYwNGPgjMF8Jm4ffrc4kHfy(EhOogRQeaHFKdeafMuxqB5(x(XpYGxuejGRewG57DGHoHGfiGH621mqgbIiwe8ZaMk6rrHpUm4ncRtRadt6hfve9OfGq9cH4tNj9JIkIE0cqOEHqKaL(SOR(f5ltTqOk9JIcm5h(Kn3Jwac1leUSSVuDDvbzJjzx8afbqSY(6ryLn9JIcmzRj6ecwau(XpYGxuejGRewG57DG6ySQsae(roqauysDbTL7F5h)idErrKaUsybMV3bg6ecwGaofCuqvCsiiO7Fbmu3IRGvIOhTaeQxieH1PvGHjpeO0NfD1VlcguV8PKrxna5Q7F8YuCsiirzkHQGRMbyqcu6ZIy8I8dFYM7rlaH6fcz)nBowe8ZaMS5Euu4JldEZE2S504YY(s11vfKn4evbzx8pD5rGSfwUK91JsLnnKnbOiaIfyYMctYw3xduoN8JFKbVOisaxjSaZ37ajpD5rGagQBXvWkr0Jwac1leIW60kWW01mqgbIiwe8ZaMk6rrHpUm4ncRtRadtTmyjsE6YJarzo)NnKjBNmoTcIOzdvqvCsii5h(Kn3Jwac1leY(6aZMJfb)mGjBUhff(4YG3ll7IhCDDvbztHjztJ3hkBgOMkBFnbIjzdAlWAat2O11rSWs2MhXLbVX8JFKbVOisaxjSaZ37a1XyvLai8JCGaOWK6cAl3)Yp(rg8IIibCLWcmFVdm0jeSabCk4OGQ4Kqqq3)cyOUfxbRerpAbiuVqicRtRadtxZazeiIyrWpdyQOhff(4YG3iSoTcmmfNecsuMsOk4QzagjqPplIjpeO0NfD1VIBWGAHqv6hffy4n)WNS5E0cqOEHq2FZMbOnk8YYMbWg2SXSbczmq2E2O11rSWs2AIoHGfiBYeYsY2PeGKDX)0LhbYMgOWeiBgG2iFdFZ6YG38JFKbVOisaxjSaZ37a1XyvLai8JCGaOWK6cAl3)Yp(rg8IIibCLWcmFVdm0jeSabmu3IRGvIOhTaeQxieH1PvGHP4kyLiOnY3W3SUaryDAfyyEWyLbF9gbTr(g(M1fisGsFw0v)yQta21WJj(lsE6YJamnyjsE6YJarcu6ZIySyFlmdF0RLU2vKoSgRyfRfa]] )

end