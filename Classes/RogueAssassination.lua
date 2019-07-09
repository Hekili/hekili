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


    spec:RegisterPack( "Assassination", 20190709.1400, [[d0K(FbqikKhHQIlHQscBcPAuOkofQsRcPOELQsZsaUfsH2Lq)sanmbshtvLLPs0ZeiMgfuxtcLTPsqFdPinojuPZjHQwNkH6DsOIyEQKCpvQ9Hu6GQeYcLqEisbnruvQUisrSruvs6JOQensuvs0jrvjSsvfVucvyMifq3evLu7evvdfvLYsvjWtrLPsbUksbyRifOVkHks7Ls)vsdwQdt1IrXJvXKj1LbBgjFwqJgLCAfRwcvuVwvvZMKBlr7wPFd1WPOLJ45qMoX1vLTJs9DvsnEkuNxGA9uqMVeSFrB)znWYPDbS8Fzq)v8bLMg0Ip(ZWxstVmiwojytWYz6N)Eiy5wVeSCxec5i0SUm41Yz6bRWU2AGLdHFKdy5yjIj6IdmWWry9yIhCzGOP8PCzW7H4usGOP8eOLJ5nkHVyTmwoTlGL)ld6VIpO00Gw8XFg(sA6VIz58NWctSCCtjn0YXA0AyTmwonGowo(K9fHqocnRldEZ(cWHpi)WNSzjIj6IdmWWry9yIhCzGOP8PCzW7H4usGOP8ey(Hpz)5Pco7IpGSVmO)k(SPXS)z4loObn)KF4t20qw(gcOlo)WNSPXSViTg0zxCmN)zl4S1aL)us2(rg8MTAqsm)WNSPXSVaOeZgYwCsii1HkMF4t20y2xKwd6SPbGGS5leOeLnp4NGgnKnMkBKaUsyXB0YPgKGSgy5qc4kHfOTgy5)N1alhSoJc02ISChYiazCl3bxYGRM4zfu20ENTHZME28KT4kyL4oHSeK4Q)ajcRZOaD2fkKT4kyLi6XiaH6fcryDgfOZME28KT4kyLiymY3W3SUaryDgfOZME2hmwPXxVrWyKVHVzDbIeO0NfL9v3zFz2fkKTrzlZ5)SHzZB20ZMTtgNrbr0SHkOkojeKS5nB6zlojeKOmLqvWv9aztJztGsFwu20M9fA58Jm41YrEMYJawXY)LwdSCW6mkqBlYYrHj1fmwS8)ZY5hzWRLZeJvvcGWpYbSIL)GynWYbRZOaTTil3Hmcqg3Y5gciJarelc(PbDf9OOWhxg8gH1zuGoB6zZ8OOIOhJaeQxieFMztpBMhfve9yeGq9cHibk9zrzFv2)IbjB6zBu2iuL5rrbAlNFKbVwUqNqWcyfl)g2AGLdwNrbABrwokmPUGXIL)Fwo)idETCMySQsae(roGvS8xmRbwoyDgfOTfz58Jm41Yf6ecwal3Hmcqg3YjUcwjIEmcqOEHqewNrb6SPNnpztGsFwu2xL9VlZUqHSnlFkzmvdqY(Q7S)LnVztpBXjHGeLPeQcUQhiBAmBcu6ZIYM2SV0YDc(OGQ4Kqqqw()zfl)xO1alhSoJc02ISChYiazClN4kyLi6XiaH6fcryDgfOZME2UHaYiqeXIGFAqxrpkk8XLbVryDgfOZME2gLTglrYZuEeikZ5)SHztpB2ozCgferZgQGQ4KqqSC(rg8A5ipt5raRy5NMAnWYbRZOaTTilhfMuxWyXY)plNFKbVwotmwvjac)ihWkw(lUwdSCW6mkqBlYY5hzWRLl0jeSawUdzeGmULtCfSse9yeGq9cHiSoJc0ztpB3qazeiIyrWpnOROhff(4YG3iSoJc0ztpBXjHGeLPeQcUQhiBAZMaL(SOSPNnpztGsFwu2xL9VIB2fkKTrzJqvMhffOZMxl3j4JcQItcbbz5)NvS8x8wdSCW6mkqBlYYrHj1fmwS8)ZY5hzWRLZeJvvcGWpYbSIL)Fb1AGLdwNrbABrwUdzeGmULtCfSse9yeGq9cHiSoJc0ztpBXvWkrWyKVHVzDbIW6mkqNn9SpySsJVEJGXiFdFZ6cejqPplk7RY(x20Z2KaSRHhD8xK8mLhbYME2ASejpt5rGibk9zrztB2fl7VzB4SP5SpM1s34kYewTLZpYGxlxOtiybSIvSCacb7bqwdS8)ZAGLZpYGxl3bVhyfIlGUsP8sWYbRZOaTTiRy5)sRbwoyDgfOTfz5oKraY4wonW8OOISHvdI4XNz20ZMNSnkBXvWkrbB8CQmkxdryDgfOZUqHS1aZJIkkyJNtLr5Ai(mZUqHS1aZJIkYgwniIhjqPplk7RUZ(xqZM3SluiBXjHGeLPeQcUQhi7RUZ(xqTC(rg8A5yuySUIPQclOclugSvS8heRbwo)idETCHpNOhFRyQQBiGGfwwoyDgfOTfzfl)g2AGLdwNrbABrwUdzeGmULdzckvvCsiiOiLVvmv9)oSbu20EN9LzxOq2eF0vGnSs01AuC2SPn7lmOwo)idETCu4Zdb6QBiGmcuzaV0kw(lM1alhSoJc02ISChYiazClhYeuQQ4KqqqrkFRyQ6)DydOSP9o7lZUqHSj(ORaByLOR1O4SztB2xyqTC(rg8A5mFKHk4zdRmkhjwXY)fAnWY5hzWRLtyb13YGFRUsHjhWYbRZOaTTiRy5NMAnWY5hzWRLJmMMkOoBfz6hWYbRZOaTTiRy5V4AnWY5hzWRL7AmrPzdZwjacV(EalhSoJc02ISIL)I3AGLdwNrbABrwUdzeGmULdwGegC2xLDXcQLZpYGxlxjuIjbxXuv17m6QMaEjYkwXYPbk)PeRbw()znWYbRZOaTTil3Hmcqg3Yzu2ibCLWc0rxPSC(rg8A5(pN)wXY)LwdSC(rg8A5qc4kHLLdwNrbABrwXYFqSgy5G1zuG2wKLdBA5qGy58Jm41YX2jJZOalhBx9alhSajm4ibcHn7VzBIheEbDLrbGgLnnNnnnB(kYMNSVmBAoBKjOuvwosGS51YX2j11lblhSajm4kbcHTEWLmZcARy53WwdSCW6mkqBlYYHnTCiqSC(rg8A5y7KXzuGLJTREGLdzckvvCsiiOiLVvmv9)oSbu2xL9Lwo2oPUEjy5qZgQGQ4KqqSIL)IznWYbRZOaTTil3Hmcqg3YHeWvclqhj4Why58Jm41YDCLQ6hzWBvniXYPgKuxVeSCibCLWc0wXY)fAnWYbRZOaTTilNFKbVwUJRuv)idERQbjwo1GK66LGL7OrwXYpn1AGLdwNrbABrwo)idETChxPQ(rg8wvdsSCQbj11lblNglwXYFX1AGLdwNrbABrwo)idETChxPQ(rg8wvdsSCQbj11lblNEiWrSIL)I3AGLdwNrbABrwUdzeGmULdwGegCuduZzKSP9o7Ffl7VzZ2jJZOGiSajm4kbcHTEWLmZcAlNFKbVwoNC8fQcMqGvSIL)Fb1AGLZpYGxlNto(cvZNcbwoyDgfOTfzfl))(znWY5hzWRLtnHSeuT48thwcRy5G1zuG2wKvSILZKahCjJlwdS8)ZAGLdwNrbABrwXY)LwdSCW6mkqBlYkw(dI1alhSoJc02ISILFdBnWYbRZOaTTiRy5VywdSC(rg8A5CttvWvt8GWRLdwNrbABrwXY)fAnWY5hzWRLdjGRewwoyDgfOTfzfl)0uRbwo)idETCMyzWRLdwNrbABrwXYFX1AGLdwNrbABrwo)idETCLo5pORuysvdUWYYDiJaKXTCeF0vGnSs01AuC2SPn7FfZYzsGdUKXLkco4vJSCfZkwXYPhcCeRbw()znWYbRZOaTTil3Hmcqg3YDWLm4QjEwbLnT3zB4S)MT4kyLOgatGurcXfpekJW6mkqNn9S5jBnW8OOISHvdI4XNz2fkKTgyEuurbB8CQmkxdXNz2fkKnSajm4OgOMZizF1D2xwSS)MnBNmoJcIWcKWGReie26bxYmlOZUqHSnkB2ozCgferZgQGQ4KqqYM3SPNnpzBu2IRGvIGXiFdFZ6ceH1zuGo7cfY(GXkn(6ncgJ8n8nRlqKaL(SOSPn7lZMxlNFKbVwoyzdlU0kw(V0AGLdwNrbABrwoSPLdbILZpYGxlhBNmoJcSCSD1dSChCjdUAINvqrnqnNrYM2S)LDHczdlqcdoQbQ5ms2xDN9Lfl7VzZ2jJZOGiSajm4kbcHTEWLmZc6SluiBJYMTtgNrbr0SHkOkojeelhBNuxVeSCpeuPgLciwXYFqSgy5G1zuG2wKL7qgbiJB5y7KXzuq8HGk1OuajB6z7gciJar4WcpByLr5AafH1zuGoB6zJmbLQkojeeuKY3kMQ(Fh2akBAVZ(slNFKbVwokFRyQ6)DydiRy53WwdSCW6mkqBlYYDiJaKXTCSDY4mki(qqLAukGKn9S5jBMhfvK1O1WwzuUgqrK4N)zt7D2)k(SluiBEY2OSnjdMmsWvcwCzWB20ZgzckvvCsiiOiLVvmv9)oSbu20ENTHZ(B28KTBiGmce14hJcQAmcIeF)NnTzFz28M93Src4kHfOJeC4dYM3S51Y5hzWRLJY3kMQ(Fh2aYkw(lM1alhSoJc02ISC(rg8A5O8TIPQ)3HnGSChYiazClhBNmoJcIpeuPgLciztpBKjOuvXjHGGIu(wXu1)7Wgqzt7D2bXYDc(OGQ4Kqqqw()zfl)xO1alhSoJc02ISChYiazClhBNmoJcIpeuPgLciztpBEYM5rrfzuZQrJgIpZSluiBJYwCfSsKnS4Yk5HyfH1zuGoB6zBu2UHaYiquJFmkOQXiicRZOaD28A58Jm41YXOMvJgnyfl)0uRbwoyDgfOTfz58Jm41Yv(Kr5cy5oKraY4wo2ozCgfeFiOsnkfqYME2itqPQItcbbfP8TIPQ)3HnGY(o7lTCNGpkOkojeeKL)FwXYFX1AGLdwNrbABrwUdzeGmULJTtgNrbXhcQuJsbelNFKbVwUYNmkxaRyfl3rJSgy5)N1alhSoJc02ISChYiazClhZJIkYOWyT6HKib8JKDHczRbMhfvKnSAqep(mTC(rg8A5mXYGxRy5)sRbwoyDgfOTfz58Jm41YPEiHGFOAiwPHTAQELEiy5oKraY4wonW8OOISHvdI4XNPLB9sWYPEiHGFOAiwPHTAQELEiyfl)bXAGLdwNrbABrwU1lblhBNmoJcQZkWIgj4A4e6SXkPIrNrPCz2Wkb8JGjwo)idETCSDY4mkOoRalAKGRHtOZgRKkgDgLYLzdReWpcMyfl)g2AGLdwNrbABrwUdzeGmULZOSrc4kHfOJeC4dSC(rg8A5EiOocuISIL)IznWYbRZOaTTil3Hmcqg3YPbMhfvKnSAqep(mTC(rg8A5yuySUs9ibBfl)xO1alhSoJc02ISChYiazClNgyEuur2WQbr84Z0Y5hzWRLJbiiG8F2qRy5NMAnWYbRZOaTTil3Hmcqg3YPbMhfvKnSAqep(mTC(rg8A5OgcWOWyTvS8xCTgy5G1zuG2wKL7qgbiJB50aZJIkYgwniIhFMwo)idETC(EaKqCv94kLvS8x8wdSCW6mkqBlYYDiJaKXTCgLnsaxjSaD0vQSPNTglrYZuEeikZ5)SHztp7shjaP6iKJqZwjqPplk77SdQLZpYGxl3XvQQFKbVv1GelNAqsD9sWYbieShazfl))cQ1alhSoJc02ISC(rg8A5kDYFqxPWKQgCHLL7qgbiJB5i(ORaByLOR1O4ZmB6zZt2ItcbjktjufCvpq2xL9bxYGRM4zfuuduZzKSP5S)flw2fkK9bxYGRM4zfuuduZzKSP9o7JzT0nUImHvNnVwUtWhfufNeccYY)pRy5)3pRbwoyDgfOTfz5oKraY4woIp6kWgwj6AnkoB20MDqcA20y2eF0vGnSs01Auu)iUm4nB6zFWLm4QjEwbf1a1CgjBAVZ(ywlDJRity1wo)idETCLo5pORuysvdUWYkw()DP1alhSoJc02ISChYiazClNrzJeWvclqhj4WhKn9S1yjsEMYJarzo)NnmB6zBu2AG5rrfzdRgeXJpZSPNnpzBu2IRGvIOhJaeQxieH1zuGo7cfY2OSDdbKrGiIfb)0GUIEuu4JldEJW6mkqNDHczRXsm0jeSarZYNsgt1aKSPn7FztpBEYgzckvvCsiiOiLVvmv9)oSbu2xL9fMDHczBu2hmwPXxVr2(oiwXNz28MnVztpBEY2OSfxbRe3jKLGex9hiryDgfOZUqHSnkBXvWkrWyKVHVzDbIW6mkqNDHczFWyLgF9gbJr(g(M1fisGsFwu2xLDXYMgZ(YSP5SfxbRe1aycKksiU4HqzewNrb6S51Y5hzWRLJnSAqe3kw()feRbwoyDgfOTfz5oKraY4woXvWkrWyKVHVzDbIW6mkqNn9S5jBXvWkXDczjiXv)bsewNrb6SluiBXvWkr0Jrac1leIW6mkqNn9Sz7KXzuqenBOcQItcbjBEZME2hCjdUAINvqzt7D2hZAPBCfzcRoB6zFWyLgF9gbJr(g(M1fisGsFwu2xL9VSPNnpzBu2IRGvIOhJaeQxieH1zuGo7cfY2OSDdbKrGiIfb)0GUIEuu4JldEJW6mkqNDHczRXsm0jeSarZYNsgt1aKSV6o7FzZRLZpYGxlhBFhelRy5)NHTgy5G1zuG2wKL7qgbiJB5exbRe3jKLGex9hiryDgfOZME2gLT4kyLiymY3W3SUaryDgfOZME2hCjdUAINvqzt7D2hZAPBCfzcRoB6zRbMhfvKnSAqep(mTC(rg8A5y77Gyzfl))kM1alhSoJc02ISCytlhcelNFKbVwo2ozCgfy5y7Qhy5CdbKrGiIfb)0GUIEuu4JldEJW6mkqNn9S5j7fVveQY8OOaDvCsiiOSP9o7FzxOq2itqPQItcbbfP8TIPQ)3HnGY(o7GKnVztpBEYgHQmpkkqxfNeccQ6my2q10xnuoNSVZoOzxOq2itqPQItcbbfP8TIPQ)3HnGYM27SVWS51YX2j11lblhcvz77Gyvp4vpYGxRy5)3fAnWYbRZOaTTilNFKbVwotmwvjac)ihWYbgleV6L43kwodxmlhfMuxWyXY)pRy5)hn1AGLdwNrbABrwUdzeGmULtCfSse9yeGq9cHiSoJc0ztpBJYgjGRewGosWHpiB6zFWyLgF9gdDcblq8zMn9S5jB2ozCgferOkBFheR6bV6rg8MDHczBu2UHaYiqeXIGFAqxrpkk8XLbVryDgfOZME2ASedDcblqKaueaXYzuq28Mn9Sp4sgC1epRGIAGAoJKnT3zZt28K9VS)M9LztZz7gciJarelc(PbDf9OOWhxg8gH1zuGoBEZMMZgzckvvCsiiOiLVvmv9)oSbu28MnT3zB4SPNnXhDfydReDTgfNnBAZ(3Lwo)idETCS9DqSSIL)FfxRbwoyDgfOTfz5oKraY4woXvWkXshjaP6iKJqZgH1zuGoB6zBu2ibCLWc0rxPYME2Losas1rihHMTsGsFwu2xDNDqZME2gLTglrYZuEeisakcGy5mkiB6zRXsm0jeSarcu6ZIYM2SdILZpYGxlhBFhelRy5)xXBnWYbRZOaTTil3Hmcqg3Yzu2ibCLWc0rxPYME2UHaYiqeXIGFAqxrpkk8XLbVryDgfOZME2ASedDcblqKaueaXYzuq20ZwJLyOtiybIMLpLmMQbizF1D2)YME2hCjdUAINvqrnqnNrYM27S)z58Jm41YHy5A81LGsBfl)xguRbwoyDgfOTfz5oKraY4wonwIKNP8iqKaL(SOSPnBdN93SnC20C2hZAPBCfzcRoB6zBu2ASedDcblqKaueaXYzuGLZpYGxlhymY3W3SUawXY)L)Sgy5G1zuG2wKL7qgbiJB50yjsEMYJarzo)Nn0Y5hzWRLtWgpNkJY1GvSILtJfRbw()znWYbRZOaTTilh20YHaXY5hzWRLJTtgNrbwo2U6bwotYGjJeCLGfxg8Mn9SrMGsvfNeccks5Bftv)VdBaLnTzhKSPNnpzRXsm0jeSarcu6ZIY(QSpySsJVEJHoHGfiQFexg8MDHczBIheEbDLrbGgLnTzxSS51YX2j11lblh6)ywpbFuqn0jeSawXY)LwdSCW6mkqBlYYHnTCiqSC(rg8A5y7KXzuGLJTREGLZKmyYibxjyXLbVztpBKjOuvXjHGGIu(wXu1)7WgqztB2bjB6zZt2AG5rrffSXZPYOCneFMzxOq28KTjEq4f0vgfaAu20MDXYME2gLTBiGmcerhyLkMQYOWyDewNrb6S5nBETCSDsD9sWYH(pM1tWhfujpt5raRy5piwdSCW6mkqBlYYHnTCiqSC(rg8A5y7KXzuGLJTREGLtdmpkQiBy1GiE8zMn9S1aZJIkkyJNtLr5Ai(mZME2ASejpt5rGibk9zrztB2xA5y7K66LGLd9FmRKNP8iGvS8ByRbwoyDgfOTfz5oKraY4woXvWkrWyKVHVzDbIW6mkqNn9S5jBEY(GlzWvt8SckBAVZ(ywlDJRity1ztp7dgR04R3iymY3W3SUarcu6ZIY(QS)LnVzxOq28KTrzlZ5)SHztpBEYwMsiBAZ(xqZUqHSp4sgC1epRGYM27SVmBEZM3S51Y5hzWRLJ8mLhbSIL)IznWYbRZOaTTilhfMuxWyXY)plNFKbVwotmwvjac)ihWkw(VqRbwoyDgfOTfz5oKraY4woEY2OSfxbRerpgbiuVqicRZOaD2fkKTrzZt2hmwPXxVr2(oiwXNz20Z(GXkn(6nYgwniIhjqPplk7RUZ2WzZB28Mn9Sp4sgC1epRGIAGAoJKnT3z)l7VzhKSP5S5jB3qazeiIyrWpnOROhff(4YG3iSoJc0ztp7dgR04R3iBFheR4ZmBEZME2eGIaiwoJcYME28KTz5tjJPAas2xDN9VSluiBcu6ZIY(Q7SL58VktjKn9SrMGsvfNeccks5Bftv)VdBaLnT3zhKS)MTBiGmcerSi4Ng0v0JIcFCzWBewNrb6S5nB6zZt2gLnymY3W3SUa6SluiBcu6ZIY(Q7SL58VktjKnnN9LztpBKjOuvXjHGGIu(wXu1)7Wgqzt7D2bj7Vz7gciJarelc(PbDf9OOWhxg8gH1zuGoBEZME2gLncvzEuuGoB6zZt2ItcbjktjufCvpq20y2eO0NfLnVztB2goB6zZt2Losas1rihHMTsGsFwu23zh0SluiBJYwMZ)zdZMxlNFKbVwUqNqWcyfl)0uRbwoyDgfOTfz5OWK6cglw()z58Jm41YzIXQkbq4h5awXYFX1AGLdwNrbABrwo)idETCHoHGfWYDiJaKXTCgLnBNmoJcIO)Jz9e8rb1qNqWcKn9S5jBJYwCfSse9yeGq9cHiSoJc0zxOq2gLnpzFWyLgF9gz77GyfFMztp7dgR04R3iBy1GiEKaL(SOSV6oBdNnVzZB20Z(GlzWvt8SckQbQ5ms20EN9VS)MDqYMMZMNSDdbKrGiIfb)0GUIEuu4JldEJW6mkqNn9SpySsJVEJS9DqSIpZS5nB6ztakcGy5mkiB6zZt2MLpLmMQbizF1D2)YUqHSjqPplk7RUZwMZ)QmLq20ZgzckvvCsiiOiLVvmv9)oSbu20ENDqY(B2UHaYiqeXIGFAqxrpkk8XLbVryDgfOZM3SPNnpzBu2GXiFdFZ6cOZUqHSjqPplk7RUZwMZ)QmLq20C2xMn9SrMGsvfNeccks5Bftv)VdBaLnT3zhKS)MTBiGmcerSi4Ng0v0JIcFCzWBewNrb6S5nB6zBu2iuL5rrb6SPNnpzlojeKOmLqvWv9aztJztGsFwu28MnTz)7YSPNnpzx6ibivhHCeA2kbk9zrzFNDqZUqHSnkBzo)NnmBETCNGpkOkojeeKL)FwXYFXBnWYbRZOaTTil3Hmcqg3YHmbLQkojeeu20EN9LztpBcu6ZIY(QSVm7VzZt2itqPQItcbbLnT3zxSS5nB6zFWLm4QjEwbLnT3zBylNFKbVwUdzkr4TkqPjGeRy5)xqTgy5G1zuG2wKL7qgbiJB5mkB2ozCgfer)hZk5zkpcKn9Sp4sgC1epRGYM27SnC20ZMaueaXYzuq20ZMNSnlFkzmvdqY(Q7S)LDHcztGsFwu2xDNTmN)vzkHSPNnYeuQQ4KqqqrkFRyQ6)DydOSP9o7GK93SDdbKrGiIfb)0GUIEuu4JldEJW6mkqNnVztpBEY2OSbJr(g(M1fqNDHcztGsFwu2xDNTmN)vzkHSP5SVmB6zJmbLQkojeeuKY3kMQ(Fh2akBAVZoiz)nB3qazeiIyrWpnOROhff(4YG3iSoJc0zZB20ZwCsiirzkHQGR6bYMgZMaL(SOSPnBdB58Jm41YrEMYJawXY)VFwdSCW6mkqBlYY5hzWRLJ8mLhbSChYiazClNrzZ2jJZOGi6)ywpbFuqL8mLhbYME2gLnBNmoJcIO)JzL8mLhbYME2hCjdUAINvqzt7D2goB6ztakcGy5mkiB6zZt2MLpLmMQbizF1D2)YUqHSjqPplk7RUZwMZ)QmLq20ZgzckvvCsiiOiLVvmv9)oSbu20ENDqY(B2UHaYiqeXIGFAqxrpkk8XLbVryDgfOZM3SPNnpzBu2GXiFdFZ6cOZUqHSjqPplk7RUZwMZ)QmLq20C2xMn9SrMGsvfNeccks5Bftv)VdBaLnT3zhKS)MTBiGmcerSi4Ng0v0JIcFCzWBewNrb6S5nB6zlojeKOmLqvWv9aztJztGsFwu20MTHTCNGpkOkojeeKL)FwXkwXYXgiObVw(VmO)k(GEHxwSyql(Gy5U2j7SHilhFrPjMiGoBAA2(rg8MTAqckMFSCMem1OalhFY(IqihHM1LbVzFb4WhKF4t2SeXeDXbgy4iSEmXdUmq0u(uUm49qCkjq0uEcm)WNS)8ubNDXhq2xg0FfF20y2)m8fh0GMFYp8jBAilFdb0fNF4t20y2xKwd6SloMZ)SfC2AGYFkjB)idEZwnijMF4t20y2xauIzdzlojeK6qfZp8jBAm7lsRbD20aqq28fcuIYMh8tqJgYgtLnsaxjS4nMFYp8jBAIXW5jGoBgGctGSp4sgxYMbcNffZ(IohWuqzV4Lgz5KsQNkB)idErzJxvWX8JFKbVOOjbo4sgxUPuo6F(XpYGxu0KahCjJlFVd0FHLWkUm4n)4hzWlkAsGdUKXLV3bsHX68dFYMBDtelSKnXhD2mpkkqNnsCbLndqHjq2hCjJlzZaHZIY2xD2MeGgnXImBy2dkBnEHy(XpYGxu0KahCjJlFVdeTUjIfwQiXfu(XpYGxu0KahCjJlFVd0nnvbxnXdcV5h)idErrtcCWLmU89oqKaUsyLF8Jm4ffnjWbxY4Y37anXYG38JFKbVOOjbo4sgx(EhyPt(d6kfMu1GlScWKahCjJlveCWRgDxSagQBIp6kWgwj6AnkolT)kw(j)WNSPjgdNNa6Sb2aj4SLPeYwybz7hbtYEqz7S9r5mkiMF4t2xaGeWvcRShQSnXi0WOGS5zXzZ(PwG4mkiByHYbqzpB2hCjJl8MF8Jm4fD)Fo)dyOUncjGRewGo6kv(XpYGx037arc4kHv(XpYGx037az7KXzuqaRxc3WcKWGReie26bxYmlOdGTREWnSajm4ibcH9RjEq4f0vgfaAentt5RGNlPzKjOuvwosaEZp(rg8I(EhiBNmoJccy9s4gnBOcQItcbja2U6b3itqPQItcbbfP8TIPQ)3HnGU6Y8JFKbVOV3bECLQ6hzWBvnijG1lHBKaUsyb6agQBKaUsyb6ibh(G8JFKbVOV3bECLQ6hzWBvnijG1lH7JgLF8Jm4f99oWJRuv)idERQbjbSEjCRXs(XpYGx037apUsv9Jm4TQgKeW6LWTEiWrYp(rg8I(EhOto(cvbtiWkbmu3WcKWGJAGAoJq79VI9LTtgNrbrybsyWvcecB9GlzMf05h)idErFVd0jhFHQ5tHG8JFKbVOV3bQMqwcQwC(PdlHvYp5h(KnneJvA81lk)4hzWlkE0OBtSm4nGH6M5rrfzuySw9qsKa(rkuqdmpkQiBy1GiE8zMF8Jm4ffpA037aFiOocugW6LWT6Hec(HQHyLg2QP6v6Hqad1TgyEuur2WQbr84Zm)WNS57aL)us2gqM9piz)qEiCXztdabzJ3SpySsJVEJ5h)idErXJg99oWhcQJaLbSEjCZ2jJZOG6ScSOrcUgoHoBSsQy0zukxMnSsa)iys(XpYGxu8OrFVd8HG6iqjkGH62iKaUsyb6ibh(G8JFKbVO4rJ(EhiJcJ1vQhj4agQBnW8OOISHvdI4XNz(XpYGxu8OrFVdKbiiG8F2WagQBnW8OOISHvdI4XNz(XpYGxu8OrFVdKAiaJcJ1bmu3AG5rrfzdRgeXJpZ8JFKbVO4rJ(EhOVhajexvpUsfWqDRbMhfvKnSAqep(mZp(rg8IIhn67DGhxPQ(rg8wvdscy9s4gqiypakGH62iKaUsyb6ORu01yjsEMYJarzo)NnKEPJeGuDeYrOzReO0NfDh08dFYMVGkBxRrz7ei7NzazJ2XeYwybzJxi7RhHv2k81asY2ad47XSPbGGSVMfSzRdE2WSPCKaKSfw(MnnKVLTgOMZizJjzF9iSWpjBFdoBAiFlMF8Jm4ffpA037alDYFqxPWKQgCHvaNGpkOkojee09VagQBIp6kWgwj6Ank(mPZJ4KqqIYucvbx1dC1bxYGRM4zfuuduZzeA(xSyfkCWLm4QjEwbf1a1CgH27JzT0nUImHvZB(HpzZxqL9IZ21Au2xpkv26bY(6rynB2cli7fmwYoibffq2peKnFnfFpB8MndgHY(6ryHFs2(gC20q(wm)4hzWlkE0OV3bw6K)GUsHjvn4cRagQBIp6kWgwj6AnkolTbjO0iXhDfydReDTgf1pIldEPFWLm4QjEwbf1a1CgH27JzT0nUImHvNF8Jm4ffpA037azdRgeXdyOUncjGRewGosWHpGUglrYZuEeikZ5)SH0nsdmpkQiBy1GiE8zsNhJexbRerpgbiuVqicRZOaDHcg5gciJarelc(PbDf9OOWhxg8gH1zuGUqbnwIHoHGfiAw(uYyQgGq7p68GmbLQkojeeuKY3kMQ(Fh2a6QlSqbJoySsJVEJS9DqSIptE5LopgjUcwjUtilbjU6pqIW6mkqxOGrIRGvIGXiFdFZ6ceH1zuGUqHdgR04R3iymY3W3SUarcu6ZIUQy04L0S4kyLOgatGurcXfpekJW6mkqZB(Hpztd67GyL91JWkBAIXOWS)Mnp8pHSeK4Q)ajGSXKS5EmcqOEHq24vfC24n7FgW7fNnFTB8u(kZMgY3Y2xD20eJrHztaxhC2uys2lySKnFjnKVNF8Jm4ffpA037az77GyfWqDlUcwjcgJ8n8nRlqewNrbA68iUcwjUtilbjU6pqIW6mkqxOG4kyLi6XiaH6fcryDgfOPZ2jJZOGiA2qfufNeccV0p4sgC1epRGO9(ywlDJRity10pySsJVEJGXiFdFZ6cejqPpl6QF05XiXvWkr0Jrac1leIW6mkqxOGrUHaYiqeXIGFAqxrpkk8XLbVryDgfOluqJLyOtiybIMLpLmMQbixD)J38dFYMg03bXk7RhHv28pHSeK4Q)aj7VzZpoBAIXOWloB(A34P8vMnnKVLTV6SPbHvdI4z)mZp(rg8IIhn67DGS9DqScyOUfxbRe3jKLGex9hiryDgfOPBK4kyLiymY3W3SUaryDgfOPFWLm4QjEwbr79XSw6gxrMWQPRbMhfvKnSAqep(mZp8jBoaYM6PuzFWLLWkzJ3SzjIj6IdmWWry9yIhCzGxGZgwwyLwOrdOHbEb4Whe41Z)jWlcHCeAwxg8sJxeFJginEbacCYHvm)4hzWlkE0OV3bY2jJZOGawVeUrOkBFheR6bV6rg8gaBx9GB3qazeiIyrWpnOROhff(4YG3iSoJc005zXBfHQmpkkqxfNeccI27FfkGmbLQkojeeuKY3kMQ(Fh2a6oi8sNheQY8OOaDvCsiiOQZGzdvtF1q5CUdAHcitqPQItcbbfP8TIPQ)3HnGO9(c5n)4hzWlkE0OV3bAIXQkbq4h5abqHj1fmwU)faySq8QxIFRCB4ILF8Jm4ffpA037az77GyfWqDlUcwjIEmcqOEHqewNrbA6gHeWvclqhj4Whq)GXkn(6ng6ecwG4ZKopSDY4mkiIqv2(oiw1dE1Jm4TqbJCdbKrGiIfb)0GUIEuu4JldEJW6mkqtxJLyOtiybIeGIaiwoJc4L(bxYGRM4zfuuduZzeAV5HNFFVKMDdbKrGiIfb)0GUIEuu4JldEJW6mkqZlnJmbLQkojeeuKY3kMQ(Fh2aIxAVnmDIp6kWgwj6AnkolT)Um)WNSPb9DqSY(6ryLnFTJeGK9fHqoA2loB(XzJeWvcRS9vN9IZ2pYWgYMV(IYM5rrfq2xWZuEei7flzpB2eGIaiwzt8neYp(rg8IIhn67DGS9DqScyOUfxbRelDKaKQJqocnBewNrbA6gHeWvclqhDLIEPJeGuDeYrOzReO0NfD1DqPBKglrYZuEeisakcGy5mkGUglXqNqWcejqPplI2GKF4t2CSCn(6sqPZMctYMJfb)0GoBUhff(4YG38JFKbVO4rJ(EhiILRXxxckDad1TribCLWc0rxPO7gciJarelc(PbDf9OOWhxg8gH1zuGMUglXqNqWcejafbqSCgfqxJLyOtiybIMLpLmMQbixD)J(bxYGRM4zfuuduZzeAV)LF4t20eJr(g(M1fi7RzbB2myHv2xWZuEeiBF1zZx6ecwGSDcK9ZmBkmjBfEdZgw8lKv(XpYGxu8OrFVdemg5B4BwxGagQBnwIKNP8iqKaL(SiAn8xdtZhZAPBCfzcRMUrASedDcblqKaueaXYzuq(XpYGxu8OrFVduWgpNkJY1qad1TglrYZuEeikZ5)SH5N8dFYMVpe4izR9speY2zg1idGYp8jBAYYgwCz2UKTH)Mnpf7B2xpcRS57C8MnnKVfZMVOSe0JlGk4SXB2x(nBXjHGGci7RhHv20GWQbr8aYgtY(6ryLTbfvCs2yHfqUEqq2x7JKnfMKncxczdlqcdoM9fPq4SV2hj7HkBAIXOWSp4sgC2dk7dUC2WSFMX8JFKbVOOEiWrUHLnS4YagQ7dUKbxnXZkiAVn8xXvWkrnaMaPIeIlEiugH1zuGMopAG5rrfzdRgeXJpZcf0aZJIkkyJNtLr5Ai(mluawGegCuduZzKRUVSyFz7KXzuqewGegCLaHWwp4sMzbDHcgX2jJZOGiA2qfufNeccV05XiXvWkrWyKVHVzDbIW6mkqxOWbJvA81Bemg5B4BwxGibk9zr0EjV5h)idErr9qGJ89oq2ozCgfeW6LW9dbvQrPasaSD1dUp4sgC1epRGIAGAoJq7VcfGfiHbh1a1Cg5Q7ll2x2ozCgfeHfiHbxjqiS1dUKzwqxOGrSDY4mkiIMnubvXjHGKF4t2fNocRSPjhw4zdZUiLRbuazZx13SXuzxCSdBaLTlzF53SfNecckMF8Jm4ff1dboY37aP8TIPQ)3HnGcyOUz7KXzuq8HGk1OuaHUBiGmceHdl8SHvgLRbuewNrbA6itqPQItcbbfP8TIPQ)3HnGO9(Y8dFYMVQVzJPYU4yh2akBxY(xX)nBK4N)OSXuzZx5O1WMDrkxdOSXKS9qFwKKTH)Mnpf7B2xpcRS574hJcYMVJraVzlojeeum)4hzWlkQhcCKV3bs5Bftv)VdBafWqDZ2jJZOG4dbvQrPacDEyEuurwJwdBLr5AafrIF(t79VIVqbEmYKmyYibxjyXLbV0rMGsvfNeccks5Bftv)VdBar7TH)YJBiGmce14hJcQAmcIeF)t7L8(fjGRewGosWHpGxEZp8jB(Q(MnMk7IJDydOSfC2UPPk4S57GRvbNnFdpi8M9qL9S(rg2q24nBFdoBXjHGKTlzhKSfNecckMF8Jm4ff1dboY37aP8TIPQ)3HnGc4e8rbvXjHGGU)fWqDZ2jJZOG4dbvQrPacDKjOuvXjHGGIu(wXu1)7Wgq0EhK8JFKbVOOEiWr(EhiJAwnA0qad1nBNmoJcIpeuPgLci05H5rrfzuZQrJgIpZcfmsCfSsKnS4Yk5HyfH1zuGMUrUHaYiquJFmkOQXiicRZOanV5h(KTbodnYx)Kr5cKTGZ2nnvbNnFhCTk4S5B4bH3SDj7lZwCsiiO8JFKbVOOEiWr(Ehy5tgLlqaNGpkOkojee09VagQB2ozCgfeFiOsnkfqOJmbLQkojeeuKY3kMQ(Fh2a6(Y8JFKbVOOEiWr(Ehy5tgLlqad1nBNmoJcIpeuPgLci5N8dFYMV7LEiKnMnqYwMsiBNzuJmak)WNSPboLJKnFPtiybqzJ3Sx8sJMKPK4KGZwCsiiOSPWKSfwq2MKbtgj4SjyXLbVzpuzxSVzZOaqJY2jq2UIaUo4SFM5h)idErrnwUz7KXzuqaRxc3O)Jz9e8rb1qNqWceaBx9GBtYGjJeCLGfxg8shzckvvCsiiOiLVvmv9)oSbeTbHopASedDcblqKaL(SORoySsJVEJHoHGfiQFexg8wOGjEq4f0vgfaAeTfJ38dFYMg4uos2xWZuEeaLnEZEXlnAsMsItcoBXjHGGYMctYwybzBsgmzKGZMGfxg8M9qLDX(MnJcankBNaz7kc46GZ(zMF8Jm4ff1y57DGSDY4mkiG1lHB0)XSEc(OGk5zkpceaBx9GBtYGjJeCLGfxg8shzckvvCsiiOiLVvmv9)oSbeTbHopAG5rrffSXZPYOCneFMfkWJjEq4f0vgfaAeTfJUrUHaYiqeDGvQyQkJcJ1ryDgfO5L38dFYMg4uos2xWZuEeaL9qLnniSAqe)RbyJNt2fPCnK9GY(zMTV6SVgYMLZgY(YVzJGdE1OSvaLKnEZwybzFbpt5rGS57ydYp(rg8IIAS89oq2ozCgfeW6LWn6)ywjpt5rGay7QhCRbMhfvKnSAqep(mPRbMhfvuWgpNkJY1q8zsxJLi5zkpcejqPplI2lZp8jBot4mUk7l4zkpcKncKNz2uys20eJrH5h)idErrnw(Ehi5zkpceWqDlUcwjcgJ8n8nRlqewNrbA68WZbxYGRM4zfeT3hZAPBCfzcRM(bJvA81Bemg5B4BwxGibk9zrx9J3cf4Xizo)NnKopYuc0(lOfkCWLm4QjEwbr79L8YlV5h(KnFPtiybY(z(haZaY2viC2czau2co7hcYEKSDu2E2it4mUk7qybIlys2uys2cliBLJKSPH8TSzakmbY2ZMA2bXci5h)idErrnw(EhOjgRQeaHFKdeafMuxWy5(x(XpYGxuuJLV3bg6ecwGagQBEmsCfSse9yeGq9cHiSoJc0fkyephmwPXxVr2(oiwXNj9dgR04R3iBy1GiEKaL(SORUnmV8s)GlzWvt8SckQbQ5mcT3)(geAMh3qazeiIyrWpnOROhff(4YG3iSoJc00pySsJVEJS9DqSIptEPtakcGy5mkGopMLpLmMQbixD)Rqbcu6ZIU6wMZ)QmLaDKjOuvXjHGGIu(wXu1)7Wgq0EhKVUHaYiqeXIGFAqxrpkk8XLbVryDgfO5LopgbgJ8n8nRlGUqbcu6ZIU6wMZ)QmLanFjDKjOuvXjHGGIu(wXu1)7Wgq0EhKVUHaYiqeXIGFAqxrpkk8XLbVryDgfO5LUriuL5rrbA68iojeKOmLqvWv9a0ibk9zr8sRHPZtPJeGuDeYrOzReO0NfDh0cfmsMZ)zd5n)4hzWlkQXY37anXyvLai8JCGaOWK6cgl3)Yp(rg8IIAS89oWqNqWceWj4JcQItcbbD)lGH62i2ozCgfer)hZ6j4JcQHoHGfGopgjUcwjIEmcqOEHqewNrb6cfmINdgR04R3iBFheR4ZK(bJvA81BKnSAqepsGsFw0v3gMxEPFWLm4QjEwbf1a1CgH27FFdcnZJBiGmcerSi4Ng0v0JIcFCzWBewNrbA6hmwPXxVr2(oiwXNjV0jafbqSCgfqNhZYNsgt1aKRU)vOabk9zrxDlZ5FvMsGoYeuQQ4KqqqrkFRyQ6)DydiAVdYx3qazeiIyrWpnOROhff(4YG3iSoJc08sNhJaJr(g(M1fqxOabk9zrxDlZ5FvMsGMVKoYeuQQ4KqqqrkFRyQ6)DydiAVdYx3qazeiIyrWpnOROhff(4YG3iSoJc08s3ieQY8OOanDEeNecsuMsOk4QEaAKaL(SiEP93L05P0rcqQoc5i0Svcu6ZIUdAHcgjZ5)SH8MF4t20qYuIWB2gaLMasYgVQGZgVzx(uYyQGSfNecckBxY2WFZMgY3Y(AwWMn5T7SHzJFs2ZM9LOS55zMTGZ2WzlojeeeVzJjzheu28uSVzlojeeeV5h)idErrnw(Eh4HmLi8wfO0eqsad1nYeuQQ4Kqqq0EFjDcu6ZIU6YV8GmbLQkojeeeT3fJx6hCjdUAINvq0EB48dFYU4aaZSFMzFbpt5rGSDjBd)nB8MTRuzlojeeu28CnlyZwnSNnmBfEdZgw8lKv2(QZEXs2O1nrSWcV5h)idErrnw(Ehi5zkpceWqDBeBNmoJcIO)JzL8mLhbOFWLm4QjEwbr7THPtakcGy5mkGopMLpLmMQbixD)Rqbcu6ZIU6wMZ)QmLaDKjOuvXjHGGIu(wXu1)7Wgq0EhKVUHaYiqeXIGFAqxrpkk8XLbVryDgfO5LopgbgJ8n8nRlGUqbcu6ZIU6wMZ)QmLanFjDKjOuvXjHGGIu(wXu1)7Wgq0EhKVUHaYiqeXIGFAqxrpkk8XLbVryDgfO5LU4KqqIYucvbx1dqJeO0NfrRHZp(rg8IIAS89oqYZuEeiGtWhfufNecc6(xad1TrSDY4mkiI(pM1tWhfujpt5ra6gX2jJZOGi6)ywjpt5ra6hCjdUAINvq0EBy6eGIaiwoJcOZJz5tjJPAaYv3)kuGaL(SORUL58VktjqhzckvvCsiiOiLVvmv9)oSbeT3b5RBiGmcerSi4Ng0v0JIcFCzWBewNrbAEPZJrGXiFdFZ6cOluGaL(SORUL58VktjqZxshzckvvCsiiOiLVvmv9)oSbeT3b5RBiGmcerSi4Ng0v0JIcFCzWBewNrbAEPlojeKOmLqvWv9a0ibk9zr0A48t(Hpzttqiypak)4hzWlkcieShaDFW7bwH4cORukVeYp8j7lsDThmk7hcYUifgRZ(6ryLnniSAqep7Nzm7lsHWz)qq2xpcRSnOOSFMzZZqLT4kyfqZB2okBfEdZ2rzps2K3IYMctY(xqrzRFKzdZMgewniIhZp(rg8IIacb7bqFVdKrHX6kMQkSGkSqzWbmu3AG5rrfzdRgeXJpt68yK4kyLOGnEovgLRHiSoJc0fkObMhfvuWgpNkJY1q8zwOGgyEuur2WQbr8ibk9zrxD)lO8wOG4KqqIYucvbx1dC19VGMF8Jm4ffbec2dG(Ehy4Zj6X3kMQ6gciyHv(XpYGxueqiypa67DGu4Zdb6QBiGmcuzaVmGH6gzckvvCsiiOiLVvmv9)oSbeT3xwOaXhDfydReDTgfNL2lmO5h)idErraHG9aOV3bA(idvWZgwzuoscyOUrMGsvfNeccks5Bftv)VdBar79Lfkq8rxb2WkrxRrXzP9cdA(XpYGxueqiypa67DGclO(wg8B1vkm5a5h)idErraHG9aOV3bsgttfuNTIm9dKF8Jm4ffbec2dG(Eh41yIsZgMTsaeE99a5h)idErraHG9aOV3bwcLysWvmvv9oJUQjGxIcyOUHfiHbFvXcA(j)WNS5eWvclqN9fDKbVO8dFYM)jKfsC1FGeq2ys2Cpg5lnXyuy24n7FgCXzZTUjIfwY(cEMYJa5h)idErrKaUsyb6BYZuEeiGH6(GlzWvt8ScI2BdtNhXvWkXDczjiXv)bsewNrb6cfexbRerpgbiuVqicRZOanDEexbRebJr(g(M1ficRZOan9dgR04R3iymY3W3SUarcu6ZIU6(YcfmsMZ)zd5LoBNmoJcIOzdvqvCsii8sxCsiirzkHQGR6bOrcu6ZIO9cZp8jBUhJaeQxiK93S5yrWpnOZM7rrHpUm49IZMMSOhbY(Ai7hcYgVq2HkmJRYwWz7MMQGZMV0jeSazl4Sfwq2L(SzlojeKShQShj7bL9ILSrRBIyHLSdgKaYgHZ2vQSXclGKDPpB2ItcbjBNzuJmakBtcMAKy(XpYGxuejGRewG(7DGMySQsae(roqauysDbJL7F5h)idErrKaUsyb6V3bg6ecwGagQB3qazeiIyrWpnOROhff(4YG3iSoJc00zEuur0Jrac1leIpt6mpkQi6XiaH6fcrcu6ZIU6xmi0ncHQmpkkqNF4t2CpgbiuVq4IZ(ImnvbNnMK9faueaXk7RhHv2mpkkqNnFPtiybq5h)idErrKaUsyb6V3bAIXQkbq4h5abqHj1fmwU)LF8Jm4ffrc4kHfO)EhyOtiybc4e8rbvXjHGGU)fWqDlUcwjIEmcqOEHqewNrbA68qGsFw0v)USqbZYNsgt1aKRU)XlDXjHGeLPeQcUQhGgjqPplI2lZp8jBUhJaeQxiK93S5yrWpnOZM7rrHpUm4n7zZMZGlo7lY0ufC2GtubN9f8mLhbYwy5s2xpkv2mq2eGIaiwGoBkmjBtF1q5CYp(rg8IIibCLWc0FVdK8mLhbcyOUfxbRerpgbiuVqicRZOanD3qazeiIyrWpnOROhff(4YG3iSoJc00nsJLi5zkpceL58F2q6SDY4mkiIMnubvXjHGKF4t2CpgbiuVqi7RdmBowe8td6S5Euu4JldEV4SVaWnnvbNnfMKndEFOSPH8TS9vhiMKnySaRg0zJw3eXclzRFexg8gZp(rg8IIibCLWc0FVd0eJvvcGWpYbcGctQlySC)l)4hzWlkIeWvclq)9oWqNqWceWj4JcQItcbbD)lGH6wCfSse9yeGq9cHiSoJc00DdbKrGiIfb)0GUIEuu4JldEJW6mkqtxCsiirzkHQGR6bOLaL(Si68qGsFw0v)kUfkyecvzEuuGM38dFYM7XiaH6fcz)nBAIXOWloBAcByZgZgiKrdz7zJw3eXclzZx6ecwGSjtiljBNsas2xWZuEeiBgGctGSPjgJ8n8nRldEZp(rg8IIibCLWc0FVd0eJvvcGWpYbcGctQlySC)l)4hzWlkIeWvclq)9oWqNqWceWqDlUcwjIEmcqOEHqewNrbA6IRGvIGXiFdFZ6ceH1zuGM(bJvA81Bemg5B4BwxGibk9zrx9JUjbyxdp64Vi5zkpcqxJLi5zkpcejqPplI2I91W08XSw6gxrMWQTCit4y5)YIv8wXkwl]] )

end