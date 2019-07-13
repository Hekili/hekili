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


    spec:RegisterPack( "Assassination", 20190712.2325, [[d40kIbqikKhHQkxcfaAtOOrHQ4uOkTkuvYRqIMffQBHcYUe6xsGHjb1XqsTmjKNHQQMMeKRPsOTPscFtLKACQeOZHcuRtLK8ouaG5Ps09uP2hk0)qbvXbvjrluc1drb0evjGlIcKnIcQQpIcQmsuaqNefuALiHxIQsPzIcqUjQkf7KcmuuvQwQkb9uuzQuqxffGAROGIVIcQs7Ls)vsdwQdt1IrQhRIjtQld2SQ6ZcA0OKtRy1OaOxJKmBsUTeTBL(nudNIwoINdz6exxv2ok13vj14fiNxGA9OQy(cy)I2sT1qlN2fWAqrfMAgCHVAQlkwe)l6kkIbB5KGnblNPFOYdbl36LGL7krihHM1LbVwotpyf21wdTCi8JCalhlrmrxvbfeocRhD8GllanLpLldEpe)lfGMYtbwo63Oeg21sB50UawdkQWuZGl8vtDrXI4FrxrrxTLZFclmXYXnLmqlhRrRH1sB50a6y54x2xjc5i0SUm4n7leh(GKc(LnlrmrxvbfeocRhD8GllanLpLldEpe)lfGMYtbjf8lBkEQGZM6Imo7Ikm1m4SzOSlI)xvrxmPiPGFzZaz5BiGUQKc(LndL9vQ1GoB(25qv2coBn89NsY2pYG3SvdsIjf8lBgk7lekXSHSfNecsD(XKc(LndL9vQ1GoBgWiiBgwbkrzZd(jOrdzJ)zJeWvclEJwo1GeK1qlhsaxjSaT1qRbuBn0YbRtRaTTyl3Hmcqg3YDWL04QjEwbLnJ3zxOSzMnpzlUcwjUtilbjUIkGeH1PvGo7abYwCfSse9OfG8FHqewNwb6SzMnpzlUcwjcbH8n8nRlqewNwb6SzM9bJvA81Becc5B4BwxGibk9zrzF5D2fLDGazBu2YCOA2WS5nBMzZ2jJtRGiA2qfufNecs28MnZSfNecsuMsOk4QEGSzOSjqPplkBgZ(kSC(rg8A5ipt5raRynOiRHwoyDAfOTfB5(ysDHGeRbuB58Jm41YzIXQkbq4h5awXAa)TgA5G1PvG2wSL7qgbiJB5C(aKrGiIfb)0GUIE)p(4YG3iSoTc0zZmB63)hrpAbi)xieFMzZmB63)hrpAbi)xiejqPplk7lZM6i)ZMz2gLncvPF)pOTC(rg8A5cDcblGvSguiRHwoyDAfOTfB5(ysDHGeRbuB58Jm41YzIXQkbq4h5awXAWfTgA5G1PvG2wSLZpYGxlxOtiybSChYiazClN4kyLi6rla5)cHiSoTc0zZmBEYMaL(SOSVmBQlk7abY2S8PKXunaj7lVZM6S5nBMzlojeKOmLqvWv9azZqztGsFwu2mMDrwUtWhfufNeccYAa1wXAWvyn0YbRtRaTTyl3Hmcqg3YjUcwjIE0cq(VqicRtRaD2mZ25dqgbIiwe8td6k69)4JldEJW60kqNnZSnkBnwIKNP8iquMdvZgMnZSz7KXPvqenBOcQItcbXY5hzWRLJ8mLhbSI1GR2AOLdwNwbABXwUpMuxiiXAa1wo)idETCMySQsae(roGvSgCbTgA5G1PvG2wSLZpYGxlxOtiybSChYiazClN4kyLi6rla5)cHiSoTc0zZmBNpazeiIyrWpnORO3)JpUm4ncRtRaD2mZwCsiirzkHQGR6bYMXSjqPplkBMzZt2eO0NfL9Lzt9fm7abY2OSrOk97)bD28A5obFuqvCsiiiRbuBfRbmyRHwoyDAfOTfB5(ysDHGeRbuB58Jm41YzIXQkbq4h5awXAa1f2AOLdwNwbABXwUdzeGmULtCfSse9OfG8FHqewNwb6SzMT4kyLieeY3W3SUaryDAfOZMz2hmwPXxVriiKVHVzDbIeO0NfL9LztD2mZ2KaSRHhDK6i5zkpcKnZS1yjsEMYJarcu6ZIYMXSVy2uMDHYMVY(ywl9GQity1wo)idETCHoHGfWkwXYbieShazn0Aa1wdTC(rg8A5o49aRqCb01VYlblhSoTc02ITI1GISgA5G1PvG2wSL7qgbiJB50a97)JSHvdI4XNz2mZMNSnkBXvWkrbh0CQ0kxdryDAfOZoqGS1a97)JcoO5uPvUgIpZSzM9bxsJRM4zfuud)5ms2xENn1zhiq2AG(9)r2WQbr8ibk9zrzF5D2ux4S5n7abYwMsOk4QEGSV8oBQlSLZpYGxlhTcJ1v8VkSGkSqzWwXAa)TgA58Jm41Yf(CIE8TI)vNpablSSCW60kqBl2kwdkK1qlhSoTc02ITChYiazClhYeuQQ4KqqqXVVv8Vs1oSbu2mENDrzhiq2eF0vGnSs01AuC2Szm7ROWzZmBybsyWzFz2xDHTC(rg8A5(4Zdb6QZhGmcuPbV0kwdUO1qlhSoTc02ITChYiazClhYeuQQ4KqqqXVVv8Vs1oSbu2mENDrzhiq2eF0vGnSs01AuC2Szm7ROWwo)idETCMpY8dE2WkTYrIvSgCfwdTC(rg8A5ewq9T043QRFm5awoyDAfOTfBfRbxT1qlNFKbVwoYyAQG6SvKPFalhSoTc02ITI1GlO1qlhSoTc02ITChYiazClh97)JQ5d0kmwhrIFOk7lZM)wo)idETCxJjknBy2kbq413dyfRbmyRHwoyDAfOTfB5oKraY4woybsyWzFz2xSWwo)idETCLqjMeCf)RQ3z0vnb8sKvSILtdF)PeRHwdO2AOLdwNwbABXwUdzeGmULZOSrc4kHfOJUsz58Jm41Yr1COYkwdkYAOLZpYGxlhsaxjSSCW60kqBl2kwd4V1qlhSoTc02ITCytlhcelNFKbVwo2ozCAfy5y7Qhy5GfiHbhjqiSztz2M4bHxqxPvaOrzZxzF1zZay28KDrzZxzJmbLQYYrcKnVwo2oPUEjy5GfiHbxjqiS1dUKEwqBfRbfYAOLdwNwbABXwoSPLdbILZpYGxlhBNmoTcSCSD1dSCitqPQItcbbf)(wX)kv7WgqzFz2fz5y7K66LGLdnBOcQItcbXkwdUO1qlhSoTc02ITChYiazClhsaxjSaDKGdFGLZpYGxl3XvQQFKbVv1GelNAqsD9sWYHeWvclqBfRbxH1qlhSoTc02ITChYiazClNrzlUcwjw6ibivhHCeA2iSoTc0zhiq2ASedDcblquMdvZgA58Jm41YDCLQ6hzWBvniXYPgKuxVeSChnYkwdUARHwoyDAfOTfB58Jm41YDCLQ6hzWBvniXYPgKuxVeSCASyfRbxqRHwoyDAfOTfB58Jm41YDCLQ6hzWBvniXYPgKuxVeSC6HahXkwdyWwdTCW60kqBl2YDiJaKXTCWcKWGJA4pNrYMX7SP(Iztz2SDY40kiclqcdUsGqyRhCj9SG2Y5hzWRLZjhFHQGjeyfRynG6cBn0Y5hzWRLZjhFHQ5tHalhSoTc02ITI1aQP2AOLZpYGxlNAczjOkdWNoSewXYbRtRaTTyRyflNjbo4sAxSgAnGARHwoyDAfOTfBfRbfzn0YbRtRaTTyRynG)wdTCW60kqBl2kwdkK1qlhSoTc02ITI1GlAn0Y5hzWRLZnnvbxnXdcVwoyDAfOTfBfRbxH1qlNFKbVwoKaUsyz5G1PvG2wSvSgC1wdTC(rg8A5mXYGxlhSoTc02ITI1GlO1qlhSoTc02ITC(rg8A5kDcvGU(XKQgCHLL7qgbiJB5i(ORaByLOR1O4SzZy2uFrlNjbo4sAxQi4GxnYYDrRyflNEiWrSgAnGARHwoyDAfOTfB5oKraY4wUdUKgxnXZkOSz8o7cLnLzlUcwjQbWeivKqCXdHYiSoTc0zZmBEYwd0V)pYgwniIhFMzhiq2AG(9)rbh0CQ0kxdXNz2bcKnSajm4Og(ZzKSV8o7IUy2uMnBNmoTcIWcKWGReie26bxsplOZoqGSnkB2ozCAferZgQGQ4KqqYM3SzMnpzBu2IRGvIqqiFdFZ6ceH1PvGo7abY(GXkn(6ncbH8n8nRlqKaL(SOSzm7IYMxlNFKbVwoyzdlU0kwdkYAOLdwNwbABXwoSPLdbILZpYGxlhBNmoTcSCSD1dSChCjnUAINvqrn8NZizZy2uNDGazdlqcdoQH)Cgj7lVZUOlMnLzZ2jJtRGiSajm4kbcHTEWL0Zc6SdeiBJYMTtgNwbr0SHkOkojeelhBNuxVeSCpeu)JsbeRynG)wdTCW60kqBl2YDiJaKXTCSDY40ki(qq9pkfqYMz2oFaYiqeoSWZgwPvUgqryDAfOZMz2itqPQItcbbf)(wX)kv7WgqzZ4D2fz58Jm41Y99TI)vQ2HnGSI1Gczn0YbRtRaTTyl3Hmcqg3YX2jJtRG4db1)OuajBMzZt20V)pYA0AyR0kxdOis8dvzZ4D2uZGZoqGS5jBJY2KmyYibxjyXLbVzZmBKjOuvXjHGGIFFR4FLQDydOSz8o7cLnLzZt2oFaYiquJF0kOQXiis8LQSzm7IYM3SPmBKaUsyb6ibh(GS5nBETC(rg8A5((wX)kv7WgqwXAWfTgA5G1PvG2wSLZpYGxl333k(xPAh2aYYDiJaKXTCSDY40ki(qq9pkfqYMz2itqPQItcbbf)(wX)kv7WgqzZ4D283YDc(OGQ4KqqqwdO2kwdUcRHwoyDAfOTfB5oKraY4wo2ozCAfeFiO(hLcizZmBEYM(9)rA1SA0OH4Zm7abY2OSfxbRezdlUSsEiwryDAfOZMz2gLTZhGmce14hTcQAmcIW60kqNnVwo)idETC0Qz1OrdwXAWvBn0YbRtRaTTylNFKbVwUYNmkxal3Hmcqg3YX2jJtRG4db1)OuajBMzJmbLQkojeeu87Bf)RuTdBaL9D2fz5obFuqvCsiiiRbuBfRbxqRHwoyDAfOTfB5oKraY4wo2ozCAfeFiO(hLciwo)idETCLpzuUawXkwUJgzn0Aa1wdTCW60kqBl2YDiJaKXTCgLnsaxjSaD0vQSzMTglrYZuEeikZHQzdZMz2Losas1rihHMTsGsFwu23zxylNFKbVwUJRuv)idERQbjwo1GK66LGLdqiypaYkwdkYAOLdwNwbABXwo)idETCLoHkqx)ysvdUWYYDiJaKXTCeF0vGnSs01Au8zMnZS5jBXjHGeLPeQcUQhi7lZ(GlPXvt8SckQH)CgjB(kBQJxm7abY(GlPXvt8SckQH)CgjBgVZ(ywl9GQity1zZRL7e8rbvXjHGGSgqTvSgWFRHwoyDAfOTfB5oKraY4woIp6kWgwj6AnkoB2mMn)lC2mu2eF0vGnSs01Auu)iUm4nBMzFWL04QjEwbf1WFoJKnJ3zFmRLEqvKjSAlNFKbVwUsNqfORFmPQbxyzfRbfYAOLdwNwbABXwUdzeGmULZOSrc4kHfOJeC4dYMz2ASejpt5rGOmhQMnmBMzBu2AG(9)r2WQbr84ZmBMzZt2gLT4kyLi6rla5)cHiSoTc0zhiq2gLTZhGmcerSi4Ng0v07)Xhxg8gH1PvGo7abYwJLyOtiybIMLpLmMQbizZy2uNnZS5jBKjOuvXjHGGIFFR4FLQDydOSVm7Ri7abY2OSpySsJVEJS9DqSIpZS5nBEZMz28KTrzlUcwjUtilbjUIkGeH1PvGo7abY2OSfxbReHGq(g(M1ficRtRaD2bcK9bJvA81Becc5B4BwxGibk9zrzFz2xmBgk7IYMVYwCfSsudGjqQiH4IhcLryDAfOZMxlNFKbVwo2WQbrCRyn4IwdTCW60kqBl2YDiJaKXTCIRGvIqqiFdFZ6ceH1PvGoBMzZt2IRGvI7eYsqIROciryDAfOZoqGSfxbRerpAbi)xieH1PvGoBMzZ2jJtRGiA2qfufNecs28MnZSp4sAC1epRGYMX7SpM1spOkYewD2mZ(GXkn(6ncbH8n8nRlqKaL(SOSVmBQZMz28KTrzlUcwjIE0cq(VqicRtRaD2bcKTrz78biJarelc(PbDf9(F8XLbVryDAfOZoqGS1yjg6ecwGOz5tjJPAas2xENn1zZRLZpYGxlhBFhelRyn4kSgA5G1PvG2wSL7qgbiJB5exbRe3jKLGexrfqIW60kqNnZSnkBXvWkriiKVHVzDbIW60kqNnZSp4sAC1epRGYMX7SpM1spOkYewD2mZwd0V)pYgwniIhFMwo)idETCS9DqSSI1GR2AOLdwNwbABXwoSPLdbILZpYGxlhBNmoTcSCSD1dSCoFaYiqeXIGFAqxrV)hFCzWBewNwb6SzMnpzV4TIqv63)d6Q4KqqqzZ4D2uNDGazJmbLQkojeeu87Bf)RuTdBaL9D28pBEZMz28KncvPF)pORItcbbvDAmBOA6RgkNt23zx4SdeiBKjOuvXjHGGIFFR4FLQDydOSz8o7RiBETCSDsD9sWYHqv2(oiw1dE1Jm41kwdUGwdTCW60kqBl2Y5hzWRLZeJvvcGWpYbSCqqcXREj(TILRqx0Y9XK6cbjwdO2kwdyWwdTCW60kqBl2YDiJaKXTCIRGvIOhTaK)leIW60kqNnZSnkBKaUsyb6ibh(GSzM9bJvA81Bm0jeSaXNz2mZMNSz7KXPvqeHQS9DqSQh8QhzWB2bcKTrz78biJarelc(PbDf9(F8XLbVryDAfOZMz2ASedDcblqKaFcGy50kiBEZMz2hCjnUAINvqrn8NZizZ4D28KnpztD2uMDrzZxz78biJarelc(PbDf9(F8XLbVryDAfOZM3S5RSrMGsvfNecck(9TI)vQ2HnGYM3SzKHNSlu2mZM4JUcSHvIUwJIZMnJztDrwo)idETCS9DqSSI1aQlS1qlhSoTc02ITChYiazClN4kyLyPJeGuDeYrOzJW60kqNnZSnkBKaUsyb6ORuzZm7shjaP6iKJqZwjqPplk7lVZUWzZmBJYwJLi5zkpcejWNaiwoTcYMz2ASedDcblqKaL(SOSzmB(NnZS5jBJYgqiypqKwHX6k(xfwqfwOm4yPZaetYoqGSPF)FebGWA2WkXdH4ZmBETC(rg8A5y77GyzfRbutT1qlhSoTc02ITChYiazClNrzJeWvclqhDLkBMz78biJarelc(PbDf9(F8XLbVryDAfOZMz2ASedDcblqKaFcGy50kiBMzRXsm0jeSarZYNsgt1aKSV8oBQZMz2hCjnUAINvqrn8NZizZ4D2uB58Jm41YHy5A81LGsBfRbuxK1qlhSoTc02ITChYiazClNglrYZuEeisGsFwu2mMDHYMYSlu28v2hZAPhufzcRoBMzBu2ASedDcblqKaFcGy50kWY5hzWRLdcc5B4BwxaRynGA(Bn0YbRtRaTTyl3Hmcqg3YPXsK8mLhbIYCOA2qlNFKbVwobh0CQ0kxdwXAa1fYAOLdwNwbABXwUdzeGmULJ(9)rAfgRvpKejGFKSdeiBnq)()iBy1GiE8zA58Jm41YzILbVwXAa1x0AOLdwNwbABXwo)idETCQhsi4hQgIvAyRMQxPhcwUdzeGmULtd0V)pYgwniIhFMwU1lblN6Hec(HQHyLg2QP6v6HGvSgq9vyn0YbRtRaTTyl36LGLJTtgNwb1zfyrJeCnCcD2yLuXOZOuUmByLa(rWelNFKbVwo2ozCAfuNvGfnsW1Wj0zJvsfJoJs5YSHvc4hbtSI1aQVARHwo)idETCpeuhbkrwoyDAfOTfBfRbuFbTgA5G1PvG2wSL7qgbiJB50a97)JSHvdI4XNPLZpYGxlhTcJ11)JeSvSgqnd2AOLdwNwbABXwUdzeGmULtd0V)pYgwniIhFMwo)idETC0abbeQMn0kwdkQWwdTCW60kqBl2YDiJaKXTCAG(9)r2WQbr84Z0Y5hzWRL7peGwHXARynOiQTgA5G1PvG2wSL7qgbiJB50a97)JSHvdI4XNPLZpYGxlNVhajexvpUszfRy50yXAO1aQTgA5G1PvG2wSLdBA5qGy58Jm41YX2jJtRalhBx9alNjzWKrcUsWIldEZMz2itqPQItcbbf)(wX)kv7WgqzZy28pBMzZt2ASedDcblqKaL(SOSVm7dgR04R3yOtiybI6hXLbVzhiq2M4bHxqxPvaOrzZy2xmBETCSDsD9sWYHOAmRNGpkOg6ecwaRynOiRHwoyDAfOTfB5WMwoeiwo)idETCSDY40kWYX2vpWYzsgmzKGReS4YG3SzMnYeuQQ4KqqqXVVv8Vs1oSbu2mMn)ZMz28KTgOF)FuWbnNkTY1q8zMDGazZt2M4bHxqxPvaOrzZy2xmBMzBu2oFaYiqeDGvQ4FLwHX6iSoTc0zZB28A5y7K66LGLdr1ywpbFuqL8mLhbSI1a(Bn0YbRtRaTTylh20YHaXY5hzWRLJTtgNwbwo2U6bwonq)()iBy1GiE8zMnZS1a97)JcoO5uPvUgIpZSzMTglrYZuEeisGsFwu2mMDrwo2oPUEjy5qunMvYZuEeWkwdkK1qlhSoTc02ITChYiazClN4kyLieeY3W3SUaryDAfOZMz28KnpzFWL04QjEwbLnJ3zFmRLEqvKjS6SzM9bJvA81Becc5B4BwxGibk9zrzFz2uNnVzhiq28KTrzlZHQzdZMz28KTmLq2mMn1fo7abY(GlPXvt8SckBgVZUOS5nBEZMxlNFKbVwoYZuEeWkwdUO1qlhSoTc02ITCFmPUqqI1aQTC(rg8A5mXyvLai8JCaRyn4kSgA5G1PvG2wSL7qgbiJB54jBJYwCfSse9OfG8FHqewNwb6SdeiBJYMNSpySsJVEJS9DqSIpZSzM9bJvA81BKnSAqepsGsFwu2xENDHYM3S5nBMzFWL04QjEwbf1WFoJKnJ3ztD2uMn)ZMVYMNSD(aKrGiIfb)0GUIE)p(4YG3iSoTc0zZm7dgR04R3iBFheR4ZmBEZMz2e4taelNwbzZmBEY2S8PKXunaj7lVZM6SdeiBcu6ZIY(Y7SL5qvvMsiBMzJmbLQkojeeu87Bf)RuTdBaLnJ3zZ)SPmBNpazeiIyrWpnORO3)JpUm4ncRtRaD28MnZS5jBJYgcc5B4BwxaD2bcKnbk9zrzF5D2YCOQktjKnFLDrzZmBKjOuvXjHGGIFFR4FLQDydOSz8oB(NnLz78biJarelc(PbDf9(F8XLbVryDAfOZM3SzMTrzJqv63)d6SzMnpzlojeKOmLqvWv9azZqztGsFwu28MnJzxOSzMnpzx6ibivhHCeA2kbk9zrzFNDHZoqGSnkBzounBy2mZ25dqgbIiwe8td6k69)4JldEJW60kqNnVwo)idETCHoHGfWkwdUARHwoyDAfOTfB5(ysDHGeRbuB58Jm41YzIXQkbq4h5awXAWf0AOLdwNwbABXwo)idETCHoHGfWYDiJaKXTCgLnBNmoTcIiQgZ6j4JcQHoHGfiBMzZt2gLT4kyLi6rla5)cHiSoTc0zhiq2gLnpzFWyLgF9gz77GyfFMzZm7dgR04R3iBy1GiEKaL(SOSV8o7cLnVzZB2mZ(GlPXvt8SckQH)CgjBgVZM6SPmB(NnFLnpz78biJarelc(PbDf9(F8XLbVryDAfOZMz2hmwPXxVr2(oiwXNz28MnZSjWNaiwoTcYMz28KTz5tjJPAas2xENn1zhiq2eO0NfL9L3zlZHQQmLq2mZgzckvvCsiiO433k(xPAh2akBgVZM)ztz2oFaYiqeXIGFAqxrV)hFCzWBewNwb6S5nBMzZt2gLneeY3W3SUa6SdeiBcu6ZIY(Y7SL5qvvMsiB(k7IYMz2itqPQItcbbf)(wX)kv7WgqzZ4D28pBkZ25dqgbIiwe8td6k69)4JldEJW60kqNnVzZmBJYgHQ0V)h0zZmBEYwCsiirzkHQGR6bYMHYMaL(SOS5nBgZM6IYMz28KDPJeGuDeYrOzReO0NfL9D2fo7abY2OSL5q1SHzZmBNpazeiIyrWpnORO3)JpUm4ncRtRaD28A5obFuqvCsiiiRbuBfRbmyRHwoyDAfOTfB5oKraY4woKjOuvXjHGGYMX7SlkBMztGsFwu2xMDrztz28KnYeuQQ4KqqqzZ4D2xmBEZMz2hCjnUAINvqzZ4D2fYY5hzWRL7qMseERcuAciXkwdOUWwdTCW60kqBl2YDiJaKXTCgLnBNmoTcIiQgZk5zkpcKnZSp4sAC1epRGYMX7Slu2mZMaFcGy50kiBMzZt2MLpLmMQbizF5D2uNDGaztGsFwu2xENTmhQQYuczZmBKjOuvXjHGGIFFR4FLQDydOSz8oB(NnLz78biJarelc(PbDf9(F8XLbVryDAfOZM3SzMnpzBu2qqiFdFZ6cOZoqGSjqPplk7lVZwMdvvzkHS5RSlkBMzJmbLQkojeeu87Bf)RuTdBaLnJ3zZ)SPmBNpazeiIyrWpnORO3)JpUm4ncRtRaD28MnZSfNecsuMsOk4QEGSzOSjqPplkBgZUqwo)idETCKNP8iGvSgqn1wdTCW60kqBl2Y5hzWRLJ8mLhbSChYiazClNrzZ2jJtRGiIQXSEc(OGk5zkpcKnZSnkB2ozCAferunMvYZuEeiBMzFWL04QjEwbLnJ3zxOSzMnb(eaXYPvq2mZMNSnlFkzmvdqY(Y7SPo7abYMaL(SOSV8oBzouvLPeYMz2itqPQItcbbf)(wX)kv7WgqzZ4D28pBkZ25dqgbIiwe8td6k69)4JldEJW60kqNnVzZmBEY2OSHGq(g(M1fqNDGaztGsFwu2xENTmhQQYuczZxzxu2mZgzckvvCsiiO433k(xPAh2akBgVZM)ztz2oFaYiqeXIGFAqxrV)hFCzWBewNwb6S5nBMzlojeKOmLqvWv9azZqztGsFwu2mMDHSCNGpkOkojeeK1aQTIvSILJnqqdETguuHPMbx4RM6IIfUWfz5U2j7SHilhdBPjMiGo7RoB)idEZwnibftkSCMe8FuGLJFzFLiKJqZ6YG3SVqC4dsk4x2SeXeDvfuq4iSE0XdUSa0u(uUm49q8VuaAkpfKuWVSP4PcoBQlY4SlQWuZGZMHYUi(FvfDXKIKc(LndKLVHa6Qsk4x2mu2xPwd6S5BNdvzl4S1W3FkjB)idEZwnijMuWVSzOSVqOeZgYwCsii15htk4x2mu2xPwd6SzaJGSzyfOeLnp4NGgnKn(NnsaxjS4nMuKuWVSzqbbNNa6SPHpMazFWL0UKnneolkM9vEoGPGYEXldXYjL)NkB)idErzJxvWXKc)idErrtcCWL0UC)voIQKc)idErrtcCWL0Uq5Db(lSewXLbVjf(rg8IIMe4GlPDHY7c(ySoPGFzZTUjIfwYM4JoB63)d6SrIlOSPHpMazFWL0UKnneolkBF1zBsagYelYSHzpOS14fIjf(rg8IIMe4GlPDHY7cqRBIyHLksCbLu4hzWlkAsGdUK2fkVlWnnvbxnXdcVjf(rg8IIMe4GlPDHY7cqc4kHvsHFKbVOOjbo4sAxO8UatSm4nPWpYGxu0KahCjTluExqPtOc01pMu1GlSm2KahCjTlveCWRgDFrJN)nXhDfydReDTgfNLrQVysrsb)YMbfeCEcOZgydKGZwMsiBHfKTFemj7bLTZ2hLtRGysb)Y(cbKaUsyL98Z2eJqdTcYMNfNn7NAbItRGSHfkhaL9SzFWL0UWBsHFKbVOBQMdvgp)BJqc4kHfOJUsLu4hzWlIY7cqc4kHvsHFKbVikVlGTtgNwbgVEjCdlqcdUsGqyRhCj9SG2y2U6b3WcKWGJeiewknXdcVGUsRaqJ4RRMbqEkIVqMGsvz5ib4nPWpYGxeL3fW2jJtRaJxVeUrZgQGQ4KqqmMTREWnYeuQQ4KqqqXVVv8Vs1oSb0LfLu4hzWlIY7coUsv9Jm4TQgKy86LWnsaxjSaTXZ)gjGRewGosWHpiPWpYGxeL3fCCLQ6hzWBvniX41lH7Jgz88VnsCfSsS0rcqQoc5i0SryDAfOdeqJLyOtiybIYCOA2WKc)idEruExWXvQQFKbVv1GeJxVeU1yjPWpYGxeL3fCCLQ6hzWBvniX41lHB9qGJKu4hzWlIY7cCYXxOkycbwX45FdlqcdoQH)CgHXBQViLSDY40kiclqcdUsGqyRhCj9SGoPWpYGxeL3f4KJVq18PqqsHFKbVikVlqnHSeuLb4thwcRKuKuWVSzGySsJVErjf(rg8IIhn6(4kv1pYG3QAqIXRxc3acb7bqgp)BJqc4kHfOJUsXuJLi5zkpceL5q1SHmlDKaKQJqocnBLaL(SO7cNuWVSzy)z7AnkBNaz)mnoB0oMq2cliB8czF9iSYwHVgqs2gA4fiMndyeK91SGnBDWZgM93rcqYwy5B2mq(E2A4pNrYgtY(6ryHFs2(gC2mq(EmPWpYGxu8OruExqPtOc01pMu1GlSm(e8rbvXjHGGUP245Ft8rxb2WkrxRrXNjtEeNecsuMsOk4QEGlp4sAC1epRGIA4pNr4lQJxmqGdUKgxnXZkOOg(ZzegVpM1spOkYewnVjf8lBg2F2loBxRrzF9OuzRhi7RhH1SzlSGSxiijB(xyKXz)qq28n)lq24nBAmcL91JWc)KS9n4SzG89ysHFKbVO4rJO8UGsNqfORFmPQbxyz88Vj(ORaByLOR1O4SmY)cZqeF0vGnSs01Auu)iUm4L5bxsJRM4zfuud)5mcJ3hZAPhufzcRoPWpYGxu8OruExaBy1GiUXZ)2iKaUsyb6ibh(aMASejpt5rGOmhQMnKPrAG(9)r2WQbr84ZKjpgjUcwjIE0cq(VqicRtRaDGag58biJarelc(PbDf9(F8XLbVryDAfOdeqJLyOtiybIMLpLmMQbimsntEqMGsvfNecck(9TI)vQ2HnGU8kceWOdgR04R3iBFheR4ZKxEzYJrIRGvI7eYsqIROciryDAfOdeWiXvWkriiKVHVzDbIW60kqhiWbJvA81Becc5B4BwxGibk9zrxErgQi(sCfSsudGjqQiH4IhcLryDAfO5nPGFzZW47GyL91JWkBguqOWSPmBEmyczjiXvubeJZgtYM7rla5)cHSXRk4SXB2uBiVxv28nEqt5RmBgiFpBF1zZGccfMnbCDWz)XKSxiijBgog4fiPWpYGxu8OruExaBFhelJN)T4kyLieeY3W3SUaryDAfOzYJ4kyL4oHSeK4kQasewNwb6abexbRerpAbi)xieH1PvGMjBNmoTcIOzdvqvCsii8Y8GlPXvt8ScIX7JzT0dQImHvZ8GXkn(6ncbH8n8nRlqKaL(SOlPMjpgjUcwjIE0cq(VqicRtRaDGag58biJarelc(PbDf9(F8XLbVryDAfOdeqJLyOtiybIMLpLmMQbixEtnVjf8lBggFheRSVEewzBWeYsqIROciztz2gGZMbfek8QYMVXdAkFLzZa57z7RoBggy1GiE2pZKc)idErXJgr5DbS9DqSmE(3IRGvI7eYsqIROciryDAfOzAK4kyLieeY3W3SUaryDAfOzEWL04QjEwbX49XSw6bvrMWQzQb63)hzdRgeXJpZKc(Lnhaz)Fkv2hCzjSs24nBwIyIUQckiCewp64bxwWf6SHLfwPfgYqgybxio8bfC9q1uWvIqocnRldEzORKVZaIHUqabo5WkMu4hzWlkE0ikVlGTtgNwbgVEjCJqv2(oiw1dE1Jm41y2U6b3oFaYiqeXIGFAqxrV)hFCzWBewNwbAM8S4TIqv63)d6Q4KqqqmEtDGaitqPQItcbbf)(wX)kv7Wgq38NxM8Gqv63)d6Q4KqqqvNgZgQM(QHY5Cx4abqMGsvfNecck(9TI)vQ2HnGy8(k4nPWpYGxu8OruExGjgRQeaHFKdy8htQleKCtTXqqcXREj(TYDHUysHFKbVO4rJO8Ua2(oiwgp)BXvWkr0JwaY)fcryDAfOzAesaxjSaDKGdFaZdgR04R3yOtiybIptM8W2jJtRGicvz77Gyvp4vpYG3abmY5dqgbIiwe8td6k69)4JldEJW60kqZuJLyOtiybIe4taelNwb8Y8GlPXvt8SckQH)CgHXBE4HAklIVC(aKrGiIfb)0GUIE)p(4YG3iSoTc08YxitqPQItcbbf)(wX)kv7Wgq8YidpfIjXhDfydReDTgfNLrQlkPGFzZW47GyL91JWkB(ghjaj7ReHC0Sxv2gGZgjGRewz7Ro7fNTFKHnKnFZvMn97)no7l8zkpcK9ILSNnBc8jaIv2eFdbJZw)iZgMDXkmwNnGqWYNSNF2oBFuoTcIjf(rg8IIhnIY7cy77Gyz88VfxbRelDKaKQJqocnBewNwbAMgHeWvclqhDLIzPJeGuDeYrOzReO0NfD5DHzAKglrYZuEeisGpbqSCAfWuJLyOtiybIeO0NfXi)zYJracb7bI0kmwxX)QWcQWcLbhlDgGysGa0V)pIaqynByL4Hq8zYBsb)YMJLRXxxckD2FmjBowe8td6S5E)p(4YG3Kc)idErXJgr5DbiwUgFDjO0gp)BJqc4kHfOJUsX05dqgbIiwe8td6k69)4JldEJW60kqZuJLyOtiybIe4taelNwbm1yjg6ecwGOz5tjJPAaYL3uZ8GlPXvt8SckQH)CgHXBQtk4x2mOGq(g(M1fi7RzbB20yHv2x4ZuEeiBF1zZW5ecwGSDcK9Zm7pMKTcVHzdl(fYkPWpYGxu8OruExaeeY3W3SUagp)BnwIKNP8iqKaL(SigleLfIVoM1spOkYewntJ0yjg6ecwGib(eaXYPvqsHFKbVO4rJO8Uabh0CQ0kxdgp)BnwIKNP8iquMdvZgMu4hzWlkE0ikVlWeldEnE(30V)psRWyT6HKib8JeiGgOF)FKnSAqep(mtk8Jm4ffpAeL3f8qqDeO041lHB1dje8dvdXknSvt1R0dbJN)TgOF)FKnSAqep(mtk4x2xa47pLKTHKzPcKSFipeUQSzaJGSXB2hmwPXxVXKc)idErXJgr5DbpeuhbknE9s4MTtgNwb1zfyrJeCnCcD2yLuXOZOuUmByLa(rWKKc)idErXJgr5Dbpeuhbkrjf(rg8IIhnIY7cOvySU(FKGnE(3AG(9)r2WQbr84ZmPWpYGxu8OruExanqqaHQzdnE(3AG(9)r2WQbr84ZmPWpYGxu8OruExWFiaTcJ1gp)Bnq)()iBy1GiE8zMu4hzWlkE0ikVlW3dGeIRQhxPmE(3AG(9)r2WQbr84ZmPiPGFzFbgcCKS1EPhcz70JAKbqjf8lBg0YgwCz2UKDHOmBEUiLzF9iSY(cWXB2mq(EmBg2YsqpUaQGZgVzxeLzlojeeKXzF9iSYMHbwniIBC2ys2xpcRSnSygaKnwybKRheK91(iz)XKSr4siBybsyWXSVsfcN91(izp)SzqbHcZ(GlPXzpOSp4YzdZ(zgtk8Jm4ff1dboYnSSHfxA88Vp4sAC1epRGy8UqukUcwjQbWeivKqCXdHYiSoTc0m5rd0V)pYgwniIhFMbcOb63)hfCqZPsRCneFMbcalqcdoQH)Cg5Y7IUiLSDY40kiclqcdUsGqyRhCj9SGoqaJy7KXPvqenBOcQItcbHxM8yK4kyLieeY3W3SUaryDAfOde4GXkn(6ncbH8n8nRlqKaL(SiglI3Kc)idErr9qGJq5DbSDY40kW41lH7hcQ)rPaIXSD1dUp4sAC1epRGIA4pNryK6abGfiHbh1WFoJC5DrxKs2ozCAfeHfiHbxjqiS1dUKEwqhiGrSDY40kiIMnubvXjHGKuWVSz4DewzZGoSWZgMDXkxdiJZMHVVzJ)zZ3UdBaLTlzxeLzlojeeumPWpYGxuupe4iuExW33k(xPAh2aY45FZ2jJtRG4db1)OuaHPZhGmceHdl8SHvALRbuewNwbAMitqPQItcbbf)(wX)kv7WgqmExusb)YMHVVzJ)zZ3UdBaLTlztndMYSrIFOcLn(NndahTg2Slw5AaLnMKTh6ZIKSleLzZZfPm7RhHv2xa8JwbzFbWiG3SfNecckMu4hzWlkQhcCekVl47Bf)RuTdBaz88Vz7KXPvq8HG6FukGWKh63)hznAnSvALRbuej(HkgVPMbhiapgzsgmzKGReS4YGxMitqPQItcbbf)(wX)kv7WgqmExik5X5dqgbIA8JwbvngbrIVuXyr8sjsaxjSaDKGdFaV8MuWVSz47B24F28T7Wgqzl4SDttvWzFbaxRcoB(oEq4n75N9S(rg2q24nBFdoBXjHGKTlzZ)SfNecckMu4hzWlkQhcCekVl47Bf)RuTdBaz8j4JcQItcbbDtTXZ)MTtgNwbXhcQ)rPactKjOuvXjHGGIFFR4FLQDydigV5FsHFKbVOOEiWrO8UaA1SA0ObJN)nBNmoTcIpeu)JsbeM8q)()iTAwnA0q8zgiGrIRGvISHfxwjpeRiSoTc0mnY5dqgbIA8JwbvngbryDAfO5nPGFzBOtZq8npzuUazl4SDttvWzFbaxRcoB(oEq4nBxYUOSfNecckPWpYGxuupe4iuExq5tgLlGXNGpkOkojee0n1gp)B2ozCAfeFiO(hLcimrMGsvfNecck(9TI)vQ2HnGUlkPWpYGxuupe4iuExq5tgLlGXZ)MTtgNwbXhcQ)rPassrsb)Y(c4LEiKnMnqYwMsiBNEuJmakPGFzZaAkhjBgoNqWcGYgVzV4LHmjtjXjbNT4Kqqqz)XKSfwq2MKbtgj4SjyXLbVzp)SViLztRaqJY2jq2UIaUo4SFMjf(rg8IIASCZ2jJtRaJxVeUrunM1tWhfudDcblGXSD1dUnjdMmsWvcwCzWltKjOuvXjHGGIFFR4FLQDydig5ptE0yjg6ecwGibk9zrxEWyLgF9gdDcblqu)iUm4nqat8GWlOR0ka0igViVjf8lBgqt5izFHpt5rau24n7fVmKjzkjoj4SfNecck7pMKTWcY2KmyYibNnblUm4n75N9fPmBAfaAu2obY2veW1bN9ZmPWpYGxuuJfkVlGTtgNwbgVEjCJOAmRNGpkOsEMYJagZ2vp42KmyYibxjyXLbVmrMGsvfNecck(9TI)vQ2HnGyK)m5rd0V)pk4GMtLw5Ai(mdeGht8GWlOR0ka0igVitJC(aKrGi6aRuX)kTcJ1ryDAfO5L3Kc(LndOPCKSVWNP8iak75NnddSAqeNsdXbnNSlw5Ai7bL9ZmBF1zFnKnlNnKDruMnco4vJYwbFjB8MTWcY(cFMYJazFbWgMu4hzWlkQXcL3fW2jJtRaJxVeUrunMvYZuEeWy2U6b3AG(9)r2WQbr84ZKPgOF)FuWbnNkTY1q8zYuJLi5zkpcejqPplIXIsk4x2CMWzCv2x4ZuEeiBeipZS)ys2mOGqHjf(rg8IIASq5DbKNP8iGXZ)wCfSsecc5B4BwxGiSoTc0m5HNdUKgxnXZkigVpM1spOkYewnZdgR04R3ieeY3W3SUarcu6ZIUKAEdeGhJK5q1SHm5rMsGrQlCGahCjnUAINvqmExeV8YBsb)YMHZjeSaz)mPcatJZ2viC2czau2co7hcYEKSDu2E2it4mUk7qybIlys2FmjBHfKTYrs2mq(E20WhtGS9S)ZoiwajPWpYGxuuJfkVlWeJvvcGWpYbm(Jj1fcsUPoPWpYGxuuJfkVli0jeSagp)BEmsCfSse9OfG8FHqewNwb6abmINdgR04R3iBFheR4ZK5bJvA81BKnSAqepsGsFw0L3fIxEzEWL04QjEwbf1WFoJW4n1uYF(IhNpazeiIyrWpnORO3)JpUm4ncRtRanZdgR04R3iBFheR4ZKxMe4taelNwbm5XS8PKXuna5YBQdeGaL(SOlVL5qvvMsGjYeuQQ4KqqqXVVv8Vs1oSbeJ38NsNpazeiIyrWpnORO3)JpUm4ncRtRanVm5XiiiKVHVzDb0bcqGsFw0L3YCOQktjWxfXezckvvCsiiO433k(xPAh2aIXB(tPZhGmcerSi4Ng0v07)Xhxg8gH1PvGMxMgHqv63)dAM8iojeKOmLqvWv9amebk9zr8YyHyYtPJeGuDeYrOzReO0NfDx4abmsMdvZgY05dqgbIiwe8td6k69)4JldEJW60kqZBsHFKbVOOgluExGjgRQeaHFKdy8htQleKCtDsHFKbVOOgluExqOtiybm(e8rbvXjHGGUP245FBeBNmoTcIiQgZ6j4JcQHoHGfGjpgjUcwjIE0cq(VqicRtRaDGagXZbJvA81BKTVdIv8zY8GXkn(6nYgwniIhjqPpl6Y7cXlVmp4sAC1epRGIA4pNry8MAk5pFXJZhGmcerSi4Ng0v07)Xhxg8gH1PvGM5bJvA81BKTVdIv8zYltc8jaILtRaM8yw(uYyQgGC5n1bcqGsFw0L3YCOQktjWezckvvCsiiO433k(xPAh2aIXB(tPZhGmcerSi4Ng0v07)Xhxg8gH1PvGMxM8yeeeY3W3SUa6abiqPpl6YBzouvLPe4RIyImbLQkojeeu87Bf)RuTdBaX4n)P05dqgbIiwe8td6k69)4JldEJW60kqZltJqOk97)bntEeNecsuMsOk4QEagIaL(SiEzK6IyYtPJeGuDeYrOzReO0NfDx4abmsMdvZgY05dqgbIiwe8td6k69)4JldEJW60kqZBsb)YMbsMseEZ2qO0eqs24vfC24n7YNsgtfKT4Kqqqz7s2fIYSzG89SVMfSztE7oBy24NK9SzxekBEEMzl4Slu2ItcbbXB2ys28hLnpxKYSfNeccI3Kc)idErrnwO8UGdzkr4TkqPjGeJN)nYeuQQ4KqqqmExetcu6ZIUSik5bzckvvCsiiigVViVmp4sAC1epRGy8Uqjf8lB(wamZ(zM9f(mLhbY2LSleLzJ3SDLkBXjHGGYMNRzbB2QH9SHzRWBy2WIFHSY2xD2lwYgTUjIfw4nPWpYGxuuJfkVlG8mLhbmE(3gX2jJtRGiIQXSsEMYJamp4sAC1epRGy8UqmjWNaiwoTcyYJz5tjJPAaYL3uhiabk9zrxElZHQQmLatKjOuvXjHGGIFFR4FLQDydigV5pLoFaYiqeXIGFAqxrV)hFCzWBewNwbAEzYJrqqiFdFZ6cOdeGaL(SOlVL5qvvMsGVkIjYeuQQ4KqqqXVVv8Vs1oSbeJ38NsNpazeiIyrWpnORO3)JpUm4ncRtRanVmfNecsuMsOk4QEagIaL(SiglusHFKbVOOgluExa5zkpcy8j4JcQItcbbDtTXZ)2i2ozCAferunM1tWhfujpt5raMgX2jJtRGiIQXSsEMYJamp4sAC1epRGy8UqmjWNaiwoTcyYJz5tjJPAaYL3uhiabk9zrxElZHQQmLatKjOuvXjHGGIFFR4FLQDydigV5pLoFaYiqeXIGFAqxrV)hFCzWBewNwbAEzYJrqqiFdFZ6cOdeGaL(SOlVL5qvvMsGVkIjYeuQQ4KqqqXVVv8Vs1oSbeJ38NsNpazeiIyrWpnORO3)JpUm4ncRtRanVmfNecsuMsOk4QEagIaL(Siglusrsb)YMbHqWEausHFKbVOiGqWEa09bVhyfIlGU(vEjKuWVSVs11EWOSFii7IvySo7RhHv2mmWQbr8SFMXSVsfcN9dbzF9iSY2WIZ(zMnn8XeiBp7)SdIfqYMN5NT4kyfqZB2okBfEdZ2rzps2K3IY(JjztDHrzRFKzdZMHbwniIhtk8Jm4ffbec2dGO8UaAfgRR4FvybvyHYGnE(3AG(9)r2WQbr84ZKjpgjUcwjk4GMtLw5AicRtRaDGaAG(9)rbh0CQ0kxdXNjZdUKgxnXZkOOg(ZzKlVPoqanq)()iBy1GiEKaL(SOlVPUW8giGmLqvWv9axEtDHtk8Jm4ffbec2dGO8UGWNt0JVv8V68biyHvsHFKbVOiGqWEaeL3f8XNhc0vNpazeOsdEPXZ)gzckvvCsiiO433k(xPAh2aIX7IceG4JUcSHvIUwJIZY4vuyMWcKWGV8QlCsHFKbVOiGqWEaeL3fy(iZp4zdR0khjgp)BKjOuvXjHGGIFFR4FLQDydigVlkqaIp6kWgwj6AnkolJxrHtk8Jm4ffbec2dGO8UaHfuFln(T66htoqsHFKbVOiGqWEaeL3fqgttfuNTIm9dKu4hzWlkcieShar5DbxJjknBy2kbq413dy88VPF)FunFGwHX6is8dvxY)Kc)idErraHG9aikVlOekXKGR4Fv9oJUQjGxImE(3WcKWGV8IfoPiPGFzZjGRewGo7R8idErjf8lBdMqwiXvubeJZgtYM7rluYGccfMnEZMAdVQS5w3eXclzFHpt5rGKc)idErrKaUsyb6BYZuEeW45FFWL04QjEwbX4DHyYJ4kyL4oHSeK4kQasewNwb6abexbRerpAbi)xieH1PvGMjpIRGvIqqiFdFZ6ceH1PvGM5bJvA81Becc5B4BwxGibk9zrxExuGagjZHQzd5LjBNmoTcIOzdvqvCsii8YuCsiirzkHQGR6byicu6ZIy8ksk4x2CpAbi)xiKnLzZXIGFAqNn37)Xhxg8EvzZGw0JazFnK9dbzJxi7qfM2vzl4SDttvWzZW5ecwGSfC2cli7sF2SfNecs2Zp7rYEqzVyjB06Miwyj7GbX4Sr4SDLkBSWcizx6ZMT4KqqY2Ph1idGY2KG)Jetk8Jm4ffrc4kHfOP8Uatmwvjac)ihW4pMuxii5M6Kc)idErrKaUsybAkVli0jeSagp)BNpazeiIyrWpnORO3)JpUm4ncRtRant63)hrpAbi)xieFMmPF)Fe9OfG8FHqKaL(SOlPoYFMgHqv63)d6Kc(Ln3JwaY)fcxv2xPPPk4SXKSVq4taeRSVEewzt)(FqNndNtiybqjf(rg8IIibCLWc0uExGjgRQeaHFKdy8htQleKCtDsHFKbVOisaxjSanL3fe6ecwaJpbFuqvCsiiOBQnE(3IRGvIOhTaK)leIW60kqZKhcu6ZIUK6IceWS8PKXuna5YBQ5LP4KqqIYucvbx1dWqeO0NfXyrjf8lBUhTaK)leYMYS5yrWpnOZM79)4JldEZE2S5m8QY(knnvbNn4evWzFHpt5rGSfwUK91JsLnnKnb(eaXc0z)XKSn9vdLZjPWpYGxuejGRewGMY7cipt5raJN)T4kyLi6rla5)cHiSoTc0mD(aKrGiIfb)0GUIE)p(4YG3iSoTc0mnsJLi5zkpceL5q1SHmz7KXPvqenBOcQItcbjPGFzZ9OfG8FHq2xxq2CSi4Ng0zZ9(F8XLbVxv2xi4MMQGZ(JjztJ3hkBgiFpBF1fGjzdbjWQbD2O1nrSWs26hXLbVXKc)idErrKaUsybAkVlWeJvvcGWpYbm(Jj1fcsUPoPWpYGxuejGRewGMY7ccDcblGXNGpkOkojee0n1gp)BXvWkr0JwaY)fcryDAfOz68biJarelc(PbDf9(F8XLbVryDAfOzkojeKOmLqvWv9amsGsFwetEiqPpl6sQVGbcyecvPF)pO5nPGFzZ9OfG8FHq2uMndkiu4vLndInSzJzdeYOHS9SrRBIyHLSz4Ccblq2KjKLKT)fGK9f(mLhbYMg(ycKndkiKVHVzDzWBsHFKbVOisaxjSanL3fyIXQkbq4h5ag)XK6cbj3uNu4hzWlkIeWvclqt5DbHoHGfW45FlUcwjIE0cq(VqicRtRantXvWkriiKVHVzDbIW60kqZ8GXkn(6ncbH8n8nRlqKaL(SOlPMPjbyxdp6i1rYZuEeGPglrYZuEeisGsFweJxKYcXxhZAPhufzcR2YHmHJ1GIUid2kwXAb]] )
    

end