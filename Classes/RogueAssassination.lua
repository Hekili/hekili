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


    spec:RegisterPack( "Assassination", 20190712.0020, [[d40)GbqisjpcvLUKQcfTju0OqvCkuLwfQk8kvLMfPu3cfODj0VeOggPihtvvltLWZKGmnjOUMesBtvb(gkGghQkQZHckRtvH8ovfkyEQeDpvQ9Hc9puqvCqvf0cLq9quaMOecDruqSruqv9ruqLrQQqHojki1kvj9suvKMPQcvUjQkIDIQQHkHGLkHONIktLu4QQku1wrbjFffuL2lL(RKgSuhMQfJupwftMIld2ms(SGgnk50kwTQcLETQkZMKBlr7wPFd1WjvlhXZHmDIRRkBhL67QkA8cKZlbwpPOMVa2VOT)TAy5mUaw(Vqt)zyAIb()IOM00f85lyGwoPaDWYP7NFEiy5wVeSCFic5i0SUm41YP7fOWUXQHLdHFKdy5yjIo6Jco4Wry9OJhCzWOP8PCzW7H4usWOP8eSLJ(nkHHET0woJlGL)l00FgMMyG)ViQjnDrH1ed0Y5pHfMy54MsgGLJ1ymWAPTCgaDSC8n7peHCeAwxg8MDrIdFqELVzZseD0hfCWHJW6rhp4YGrt5t5YG3dXPKGrt5j48kFZ(6tvq2)Vq7SVqt)zyzZGzRjn9rxOP8AELVzZay5BiG(O8kFZMbZ(dngWKnF6C(LTGZ2au(tjz7hzWB2QbjX8kFZMbZUiHsmBiBXjHGuhQyELVzZGz)HgdyY(JhbzZqlqjkBEWpbngiBmv2ibCLWI3OLtnibz1WYHeWvclWy1WY)FRgwoyDAfySfB5oKraY4wUdUKgx1XZkOSz8o7cNnZS5jBXvWkXDczjiXv)asewNwbMSdeiBXvWkr0Jwac1leIW60kWKnZS5jBXvWkriiKVHVzDbIW60kWKnZSpySYG)CJqqiFdFZ6cejqPplk7lVZ(ISdeiBTYwMZVzdZM3SzMnBNmoTcIOzdvqvCsiizZB2mZwCsiirzkHQGRMbYMbZMaL(SOSzm7pWY5hzWRLJ80LhbSIL)lSAy5G1PvGXwSLJctQleKy5)VLZpYGxlNogRQeaHFKdyfl)fYQHLdwNwbgBXwUdzeGmULZ1mqgbIiwe8ZaMk6rrHpUm4ncRtRat2mZM(rrfrpAbiuVqi(0ZMz20pkQi6rlaH6fcrcu6ZIY(YS)hlu2mZwRSrOk9JIcmwo)idETCHoHGfWkw(lSvdlhSoTcm2ITCuysDHGel))TC(rg8A50XyvLai8JCaRy5VOwnSCW60kWyl2Y5hzWRLl0jeSawUdzeGmULtCfSse9OfGq9cHiSoTcmzZmBEYMaL(SOSVm7)xKDGazRx(uYORgGK9L3z)pBEZMz2ItcbjktjufC1mq2my2eO0NfLnJzFHL7uWrbvXjHGGS8)3kw()aRgwoyDAfySfB5oKraY4woXvWkr0Jwac1leIW60kWKnZSDndKrGiIfb)mGPIEuu4JldEJW60kWKnZS1kBdwIKNU8iquMZVzdZMz2SDY40kiIMnubvXjHGy58Jm41YrE6YJawXYpd0QHLdwNwbgBXwokmPUqqIL))wo)idETC6ySQsae(roGvS8ZNTAy5G1PvGXwSLZpYGxlxOtiybSChYiazClN4kyLi6rlaH6fcryDAfyYMz2UMbYiqeXIGFgWurpkk8XLbVryDAfyYMz2ItcbjktjufC1mq2mMnbk9zrzZmBEYMaL(SOSVm7)85SdeiBTYgHQ0pkkWKnVwUtbhfufNeccYY)FRy5NHz1WYbRtRaJTylhfMuxiiXY)FlNFKbVwoDmwvjac)ihWkw()RjRgwoyDAfySfB5oKraY4woXvWkr0Jwac1leIW60kWKnZSfxbReHGq(g(M1ficRtRat2mZ(GXkd(ZncbH8n8nRlqKaL(SOSVm7)zZmBDcWUgEmX)rYtxEeiBMzBWsK80LhbIeO0NfLnJzx0S)MDHZMpY(Oxl9GQiDynwo)idETCHoHGfWkwXYbieShaz1WY)FRgwo)idETCh8EGviUaMkLYlblhSoTcm2ITIL)lSAy5G1PvGXwSL7qgbiJB5ma9JIkYgwdiIhF6zZmBEYwRSfxbRefCqZPsRCdeH1PvGj7abY2a0pkQOGdAovALBG4tp7abY2a0pkQiBynGiEKaL(SOSV8o7)AkBEZoqGSfNecsuMsOk4QzGSV8o7)AYY5hzWRLJwHXMkMQkSGkSqzbwXYFHSAy58Jm41Yf(CIz8TIPQUMbcwyz5G1PvGXwSvS8xyRgwoyDAfySfB5oKraY4woKoOuvXjHGGIu(wXu1F7WgqzZ4D2xKDGazt8Xub2Wkr3yqXzZMXS)anz58Jm41YrHppeyQUMbYiqLg8sRy5VOwnSCW60kWyl2YDiJaKXTCiDqPQItcbbfP8TIPQ)2HnGYMX7SVi7abYM4JPcSHvIUXGIZMnJz)bAYY5hzWRLt)rgQcMnSsRCKyfl)FGvdlNFKbVwoHfuFln(TMkfMCalhSoTcm2ITILFgOvdlNFKbVwoYORRG6SvKUFalhSoTcm2ITILF(SvdlNFKbVwUpXeLHnmBLai867bSCW60kWyl2kw(zywnSCW60kWyl2YDiJaKXTCWcKWcY(YSlQMSC(rg8A5kHsmPGkMQQENXuneWlrwXkwodq5pLy1WY)FRgwoyDAfySfB5oKraY4woTYgjGRewGj6kLLZpYGxl3V58Zkw(VWQHLZpYGxlhsaxjSSCW60kWyl2kw(lKvdlhSoTcm2ITCyDlhcelNFKbVwo2ozCAfy5y7Qhy5GfiHfejqiSz)nBD8GWlyQ0kamOS5JSzGz)XmBEY(IS5JSr6Gsvz5ibYMxlhBNuxVeSCWcKWcQeie26bxsplySIL)cB1WYbRtRaJTylhw3YHaXY5hzWRLJTtgNwbwo2U6bwoKoOuvXjHGGIu(wXu1F7WgqzFz2xy5y7K66LGLdnBOcQItcbXkw(lQvdlhSoTcm2ITChYiazClhsaxjSatKGdFGLZpYGxl3XvQQFKbVv1GelNAqsD9sWYHeWvclWyfl)FGvdlhSoTcm2ITChYiazClNwzlUcwjw6ibivhHCeA2iSoTcmzhiq2gSedDcblquMZVzdTC(rg8A5oUsv9Jm4TQgKy5udsQRxcwUJbzfl)mqRgwoyDAfySfB58Jm41YDCLQ6hzWBvniXYPgKuxVeSCgSyfl)8zRgwoyDAfySfB58Jm41YDCLQ6hzWBvniXYPgKuxVeSCMHahXkw(zywnSCW60kWyl2YDiJaKXTCWcKWcIgGAoJKnJ3z)VOz)nB2ozCAfeHfiHfujqiS1dUKEwWy58Jm41Y5KJVqvWecSIvS8)xtwnSC(rg8A5CYXxOQ)uiWYbRtRaJTyRy5))FRgwo)idETCQjKLGQFSptyjSILdwNwbgBXwXkwoDcCWL0Uy1WY)FRgwoyDAfySfBfl)xy1WYbRtRaJTyRy5VqwnSCW60kWyl2kw(lSvdlhSoTcm2ITIL)IA1WY5hzWRLZ11vfu1XdcVwoyDAfySfBfl)FGvdlNFKbVwoKaUsyz5G1PvGXwSvS8ZaTAy58Jm41YPJLbVwoyDAfySfBfl)8zRgwoyDAfySfB58Jm41Yv6KFGPsHjvd4cll3Hmcqg3Yr8Xub2Wkr3yqXzZMXS)xulNobo4sAxQi4GxdYYvuRyflNziWrSAy5)VvdlhSoTcm2ITChYiazCl3bxsJR64zfu2mENDHZ(B2IRGvIga0bsfjex8qOmcRtRat2mZMNSna9JIkYgwdiIhF6zhiq2gG(rrffCqZPsRCdeF6zhiq2WcKWcIgGAoJK9L3zFrrZ(B2SDY40kiclqclOsGqyRhCj9SGj7abYwRSz7KXPvqenBOcQItcbjBEZMz28KTwzlUcwjcbH8n8nRlqewNwbMSdei7dgRm4p3ieeY3W3SUarcu6ZIYMXSViBETC(rg8A5GLnS4sRy5)cRgwoyDAfySfB5W6woeiwo)idETCSDY40kWYX2vpWYDWL04QoEwbfna1CgjBgZ(F2bcKnSajSGObOMZizF5D2xu0S)MnBNmoTcIWcKWcQeie26bxsplyYoqGS1kB2ozCAferZgQGQ4KqqSCSDsD9sWY9qqLAukGyfl)fYQHLdwNwbgBXwUdzeGmULJTtgNwbXhcQuJsbKSzMTRzGmceHdl8SHvALBauewNwbMSzMnshuQQ4KqqqrkFRyQ6VDydOSz8o7lSC(rg8A5O8TIPQ)2HnGSIL)cB1WYbRtRaJTyl3Hmcqg3YX2jJtRG4dbvQrPas2mZMNSPFuurwJXaBLw5gafrIF(LnJ3z)NHLDGazZt2ALTozWKrkOsWIldEZMz2iDqPQItcbbfP8TIPQ)2HnGYMX7SlC2FZMNSDndKrGOb)Ovq1GrqK47VSzm7lYM3S)MnsaxjSatKGdFq28MnVwo)idETCu(wXu1F7WgqwXYFrTAy5G1PvGXwSLZpYGxlhLVvmv93oSbKL7qgbiJB5y7KXPvq8HGk1OuajBMzJ0bLQkojeeuKY3kMQ(Bh2akBgVZUqwUtbhfufNeccYY)FRy5)dSAy5G1PvGXwSL7qgbiJB5y7KXPvq8HGk1OuajBMzZt20pkQiTAwdAmq8PNDGazRv2IRGvISHfxwjpeRiSoTcmzZmBTY21mqgbIg8JwbvdgbryDAfyYMxlNFKbVwoA1Sg0yaRy5NbA1WYbRtRaJTylNFKbVwUYNmkxal3Hmcqg3YX2jJtRG4dbvQrPas2mZgPdkvvCsiiOiLVvmv93oSbu23zFHL7uWrbvXjHGGS8)3kw(5ZwnSCW60kWyl2YDiJaKXTCSDY40ki(qqLAukGy58Jm41Yv(Kr5cyfRy5ogKvdl))TAy5G1PvGXwSL7qgbiJB5OFuurAfgBupKejGFKSdeiBdq)OOISH1aI4XNULZpYGxlNowg8Afl)xy1WYbRtRaJTyl3Hmcqg3Yza6hfvKnSgqep(0TCRxcwo1dje8dvdXkdSvD1R0dblNFKbVwo1dje8dvdXkdSvD1R0dbRy5VqwnSCW60kWyl2YTEjy5y7KXPvqDwbw0ifudNqNnwjvm6mkLlZgwjGFemXY5hzWRLJTtgNwb1zfyrJuqnCcD2yLuXOZOuUmByLa(rWeRy5VWwnSCW60kWyl2YDiJaKXTCALnsaxjSatKGdFGLZpYGxl3db1rGsKvS8xuRgwoyDAfySfB5oKraY4wodq)OOISH1aI4XNULZpYGxlhTcJnvQhPaRy5)dSAy5G1PvGXwSL7qgbiJB5ma9JIkYgwdiIhF6wo)idETC0abbKFZgAfl)mqRgwoyDAfySfB5oKraY4wodq)OOISH1aI4XNULZpYGxlh1qaAfgBSILF(SvdlhSoTcm2ITChYiazClNbOFuur2WAar84t3Y5hzWRLZ3dGeIRQhxPSILFgMvdlhSoTcm2ITChYiazClNwzJeWvclWeDLkBMzBWsK80LhbIYC(nBy2mZU0rcqQoc5i0Svcu6ZIY(oBnz58Jm41YDCLQ6hzWBvniXYPgKuxVeSCacb7bqwXY)Fnz1WYbRtRaJTylNFKbVwUsN8dmvkmPAaxyz5oKraY4woIpMkWgwj6gdk(0ZMz28KT4KqqIYucvbxndK9LzFWL04QoEwbfna1CgjB(i7)XIMDGazFWL04QoEwbfna1CgjBgVZ(Oxl9GQiDynzZRL7uWrbvXjHGGS8)3kw())3QHLdwNwbgBXwUdzeGmULJ4JPcSHvIUXGIZMnJzxinLndMnXhtfydReDJbfnpIldEZMz2hCjnUQJNvqrdqnNrYMX7Sp61spOkshwJLZpYGxlxPt(bMkfMunGlSSIL))xy1WYbRtRaJTyl3Hmcqg3YPv2ibCLWcmrco8bzZmBdwIKNU8iquMZVzdZMz2ALTbOFuur2WAar84tpBMzZt2ALT4kyLi6rlaH6fcryDAfyYoqGS1kBxZazeiIyrWpdyQOhff(4YG3iSoTcmzhiq2gSedDcblquV8PKrxnajBgZ(F2mZMNSr6GsvfNeccks5Bftv)TdBaL9Lz)bzhiq2AL9bJvg8NBKTVdIv8PNnVzZB2mZMNS1kBXvWkXDczjiXv)asewNwbMSdeiBTYwCfSsecc5B4BwxGiSoTcmzhiq2hmwzWFUriiKVHVzDbIeO0NfL9Lzx0SzWSViB(iBXvWkrda6aPIeIlEiugH1PvGjBETC(rg8A5ydRbeXTIL))fYQHLdwNwbgBXwUdzeGmULtCfSsecc5B4BwxGiSoTcmzZmBEYwCfSsCNqwcsC1pGeH1PvGj7abYwCfSse9OfGq9cHiSoTcmzZmB2ozCAferZgQGQ4KqqYM3SzM9bxsJR64zfu2mEN9rVw6bvr6WAYMz2hmwzWFUriiKVHVzDbIeO0NfL9Lz)pBMzZt2ALT4kyLi6rlaH6fcryDAfyYoqGS1kBxZazeiIyrWpdyQOhff(4YG3iSoTcmzhiq2gSedDcblquV8PKrxnaj7lVZ(F28A58Jm41YX23bXYkw()xyRgwoyDAfySfB5oKraY4woXvWkXDczjiXv)asewNwbMSzMTwzlUcwjcbH8n8nRlqewNwbMSzM9bxsJR64zfu2mEN9rVw6bvr6WAYMz2gG(rrfzdRbeXJpDlNFKbVwo2(oiwwXY))IA1WYbRtRaJTylhw3YHaXY5hzWRLJTtgNwbwo2U6bwoxZazeiIyrWpdyQOhff(4YG3iSoTcmzZmBEYEXBfHQ0pkkWufNecckBgVZ(F2bcKnshuQQ4KqqqrkFRyQ6VDydOSVZUqzZB2mZMNSrOk9JIcmvXjHGGQonMnu191aLZj77S1u2bcKnshuQQ4KqqqrkFRyQ6VDydOSz8o7piBETCSDsD9sWYHqv2(oiw1dEnJm41kw())bwnSCW60kWyl2YbbjeV6L43kwUcxulhfMuxiiXY)FlNFKbVwoDmwvjac)ihWkw()ZaTAy5G1PvGXwSL7qgbiJB5exbRerpAbiuVqicRtRat2mZwRSrc4kHfyIeC4dYMz2hmwzWFUXqNqWceF6zZmBEYMTtgNwbreQY23bXQEWRzKbVzhiq2ALTRzGmcerSi4Nbmv0JIcFCzWBewNwbMSzMTblXqNqWcejafbqSCAfKnVzZm7dUKgx1XZkOObOMZizZ4D28Knpz)p7VzFr28r2UMbYiqeXIGFgWurpkk8XLbVryDAfyYM3S5JSr6GsvfNeccks5Bftv)TdBaLnVzZidpzx4SzMnXhtfydReDJbfNnBgZ()fwo)idETCS9DqSSIL))8zRgwoyDAfySfB5oKraY4woXvWkXshjaP6iKJqZgH1PvGjBMzRv2ibCLWcmrxPYMz2Losas1rihHMTsGsFwu2xENTMYMz2ALTblrYtxEeisakcGy50kiBMzBWsm0jeSarcu6ZIYMXSlu2mZMNS1kBaHG9arAfgBQyQQWcQWcLfel9pwmj7abYM(rrfraiSMnSs8qi(0ZMxlNFKbVwo2(oiwwXY)FgMvdlhSoTcm2ITChYiazClNwzJeWvclWeDLkBMz7AgiJarelc(zatf9OOWhxg8gH1PvGjBMzBWsm0jeSarcqraelNwbzZmBdwIHoHGfiQx(uYORgGK9L3z)pBMzFWL04QoEwbfna1CgjBgVZ(VLZpYGxlhILBWFwckJvS8FHMSAy5G1PvGXwSL7qgbiJB5myjsE6YJarcu6ZIYMXSlC2FZUWzZhzF0RLEqvKoSMSzMTwzBWsm0jeSarcqraelNwbwo)idETCqqiFdFZ6cyfl)x83QHLdwNwbgBXwUdzeGmULZGLi5PlpceL58B2qlNFKbVwobh0CQ0k3awXkwodwSAy5)VvdlhSoTcm2ITCyDlhcelNFKbVwo2ozCAfy5y7Qhy50jdMmsbvcwCzWB2mZgPdkvvCsiiOiLVvmv93oSbu2mMDHYMz28KTblXqNqWcejqPplk7lZ(GXkd(Zng6ecwGO5rCzWB2bcKToEq4fmvAfagu2mMDrZMxlhBNuxVeSCOFJE9uWrb1qNqWcyfl)xy1WYbRtRaJTylhw3YHaXY5hzWRLJTtgNwbwo2U6bwoDYGjJuqLGfxg8MnZSr6GsvfNeccks5Bftv)TdBaLnJzxOSzMnpzBa6hfvuWbnNkTYnq8PNDGazZt264bHxWuPvayqzZy2fnBMzRv2UMbYiqeDGvQyQkTcJnryDAfyYM3S51YX2j11lblh63OxpfCuqL80LhbSIL)cz1WYbRtRaJTylhw3YHaXY5hzWRLJTtgNwbwo2U6bwodq)OOISH1aI4XNE2mZ2a0pkQOGdAovALBG4tpBMzBWsK80LhbIeO0NfLnJzFHLJTtQRxcwo0VrVsE6YJawXYFHTAy5G1PvGXwSL7qgbiJB5exbReHGq(g(M1ficRtRat2mZMNS5j7dUKgx1XZkOSz8o7JET0dQI0H1KnZSpySYG)CJqqiFdFZ6cejqPplk7lZ(F28MDGazZt2ALTmNFZgMnZS5jBzkHSzm7)Ak7abY(GlPXvD8SckBgVZ(IS5nBEZMxlNFKbVwoYtxEeWkw(lQvdlhSoTcm2ITCuysDHGel))TC(rg8A50XyvLai8JCaRy5)dSAy5G1PvGXwSL7qgbiJB54jBTYwCfSse9OfGq9cHiSoTcmzhiq2ALnpzFWyLb)5gz77GyfF6zZm7dgRm4p3iBynGiEKaL(SOSV8o7cNnVzZB2mZ(GlPXvD8SckAaQ5ms2mEN9)S)MDHYMpYMNSDndKrGiIfb)mGPIEuu4JldEJW60kWKnZSpySYG)CJS9DqSIp9S5nBMztakcGy50kiBMzZt26LpLm6QbizF5D2)ZoqGSjqPplk7lVZwMZVQmLq2mZgPdkvvCsiiOiLVvmv93oSbu2mENDHY(B2UMbYiqeXIGFgWurpkk8XLbVryDAfyYM3SzMnpzRv2qqiFdFZ6cyYoqGSjqPplk7lVZwMZVQmLq28r2xKnZSr6GsvfNeccks5Bftv)TdBaLnJ3zxOS)MTRzGmcerSi4Nbmv0JIcFCzWBewNwbMS5nBMzRv2iuL(rrbMSzMnpzlojeKOmLqvWvZazZGztGsFwu28MnJzx4SzMnpzx6ibivhHCeA2kbk9zrzFNTMYoqGS1kBzo)MnmBETC(rg8A5cDcblGvS8ZaTAy5G1PvGXwSLJctQleKy5)VLZpYGxlNogRQeaHFKdyfl)8zRgwoyDAfySfB58Jm41Yf6ecwal3Hmcqg3YPv2SDY40kiI(n61tbhfudDcblq2mZMNS1kBXvWkr0Jwac1leIW60kWKDGazRv28K9bJvg8NBKTVdIv8PNnZSpySYG)CJSH1aI4rcu6ZIY(Y7SlC28MnVzZm7dUKgx1XZkOObOMZizZ4D2)Z(B2fkB(iBEY21mqgbIiwe8ZaMk6rrHpUm4ncRtRat2mZ(GXkd(ZnY23bXk(0ZM3SzMnbOiaILtRGSzMnpzRx(uYORgGK9L3z)p7abYMaL(SOSV8oBzo)QYuczZmBKoOuvXjHGGIu(wXu1F7WgqzZ4D2fk7Vz7AgiJarelc(zatf9OOWhxg8gH1PvGjBEZMz28KTwzdbH8n8nRlGj7abYMaL(SOSV8oBzo)QYuczZhzFr2mZgPdkvvCsiiOiLVvmv93oSbu2mENDHY(B2UMbYiqeXIGFgWurpkk8XLbVryDAfyYM3SzMTwzJqv6hffyYMz28KT4KqqIYucvbxndKndMnbk9zrzZB2mM9)lYMz28KDPJeGuDeYrOzReO0NfL9D2Ak7abYwRSL58B2WS51YDk4OGQ4Kqqqw()Bfl)mmRgwoyDAfySfB5oKraY4woKoOuvXjHGGYMX7SViBMztGsFwu2xM9fz)nBEYgPdkvvCsiiOSz8o7IMnVzZm7dUKgx1XZkOSz8o7cB58Jm41YDitjcVvbk1bKyfl))1KvdlhSoTcm2ITChYiazClNwzZ2jJtRGi63OxjpD5rGSzM9bxsJR64zfu2mENDHZMz2eGIaiwoTcYMz28KTE5tjJUAas2xEN9)SdeiBcu6ZIY(Y7SL58RktjKnZSr6GsvfNeccks5Bftv)TdBaLnJ3zxOS)MTRzGmcerSi4Nbmv0JIcFCzWBewNwbMS5nBMzZt2ALneeY3W3SUaMSdeiBcu6ZIY(Y7SL58RktjKnFK9fzZmBKoOuvXjHGGIu(wXu1F7WgqzZ4D2fk7Vz7AgiJarelc(zatf9OOWhxg8gH1PvGjBEZMz2ItcbjktjufC1mq2my2eO0NfLnJzxylNFKbVwoYtxEeWkw())3QHLdwNwbgBXwo)idETCKNU8iGL7qgbiJB50kB2ozCAfer)g96PGJcQKNU8iq2mZwRSz7KXPvqe9B0RKNU8iq2mZ(GlPXvD8SckBgVZUWzZmBcqraelNwbzZmBEYwV8PKrxnaj7lVZ(F2bcKnbk9zrzF5D2YC(vLPeYMz2iDqPQItcbbfP8TIPQ)2HnGYMX7Slu2FZ21mqgbIiwe8ZaMk6rrHpUm4ncRtRat28MnZS5jBTYgcc5B4Bwxat2bcKnbk9zrzF5D2YC(vLPeYMpY(ISzMnshuQQ4KqqqrkFRyQ6VDydOSz8o7cL93SDndKrGiIfb)mGPIEuu4JldEJW60kWKnVzZmBXjHGeLPeQcUAgiBgmBcu6ZIYMXSlSL7uWrbvXjHGGS8)3kwXkwo2abn41Y)fA6pdttmW))JxuOIYNTCF6KD2qKLJHUuhteWKndmB)idEZwnibfZRwoDcMAuGLJVz)HiKJqZ6YG3SlsC4dYR8nBwIOJ(OGdoCewp64bxgmAkFkxg8EioLemAkpbNx5B2xFQcY()fAN9fA6pdlBgmBnPPp6cnLxZR8nBgalFdb0hLx5B2my2FOXaMS5tNZVSfC2gGYFkjB)idEZwnijMx5B2my2fjuIzdzlojeK6qfZR8nBgm7p0yat2F8iiBgAbkrzZd(jOXazJPYgjGRew8gZR5v(Mndji48eWKnnqHjq2hCjTlztdHZIIz)HNdOlOSx8YGSCsj1tLTFKbVOSXRQGyE1pYGxuuNahCjTl3ukh9lV6hzWlkQtGdUK2LV3b7VWsyfxg8Mx9Jm4ff1jWbxs7Y37GPWytELVzZTUoIfwYM4JjB6hffyYgjUGYMgOWei7dUK2LSPHWzrz7RjBDcWG6yrMnm7bLTbVqmV6hzWlkQtGdUK2LV3bJwxhXclvK4ckV6hzWlkQtGdUK2LV3b766QcQ64bH38QFKbVOOobo4sAx(EhmsaxjSYR(rg8II6e4GlPD57DW6yzWBE1pYGxuuNahCjTlFVdU0j)atLctQgWfwARtGdUK2Lkco41GUlQ2d1nXhtfydReDJbfNLX)fnVMx5B2mKGGZtat2aBGuq2YuczlSGS9JGjzpOSD2(OCAfeZR8n7Ieqc4kHv2dv26yeAOvq28S4Sz)ulqCAfKnSq5aOSNn7dUK2fEZR(rg8IU)nNFApu3AHeWvclWeDLkV6hzWl67DWibCLWkV6hzWl67DWSDY40kq71lHBybsybvcecB9GlPNfmAZ2vp4gwGewqKaHW(vhpi8cMkTcadIpyGFm55c(aPdkvLLJeG38QFKbVOV3bZ2jJtRaTxVeUrZgQGQ4Kqq0MTREWnshuQQ4KqqqrkFRyQ6VDydOlViV6hzWl67DWhxPQ(rg8wvds0E9s4gjGRewGr7H6gjGRewGjsWHpiV6hzWl67DWhxPQ(rg8wvds0E9s4(yqApu3AjUcwjw6ibivhHCeA2iSoTcmbcyWsm0jeSarzo)MnmV6hzWl67DWhxPQ(rg8wvds0E9s42GL8QFKbVOV3bFCLQ6hzWBvnir71lHBZqGJKx9Jm4f99oyNC8fQcMqGv0EOUHfiHfena1CgHX7)f9lBNmoTcIWcKWcQeie26bxsplyYR(rg8I(EhSto(cv9Ncb5v)idErFVdwnHSeu9J9zclHvYR5v(MndaJvg8NlkV6hzWlkEmOBDSm4v7H6M(rrfPvySr9qsKa(rceWa0pkQiBynGiE8PNx9Jm4ffpg037GFiOocuQ96LWT6Hec(HQHyLb2QU6v6HG2d1TbOFuur2WAar84tpVY3SlIaL)us2AqM9hiz)qEi8rz)XJGSXB2hmwzWFUX8QFKbVO4XG(Eh8db1rGsTxVeUz7KXPvqDwbw0ifudNqNnwjvm6mkLlZgwjGFemjV6hzWlkEmOV3b)qqDeOeP9qDRfsaxjSatKGdFqE1pYGxu8yqFVdMwHXMk1JuG2d1TbOFuur2WAar84tpV6hzWlkEmOV3btdeeq(nBO2d1TbOFuur2WAar84tpV6hzWlkEmOV3btneGwHXgThQBdq)OOISH1aI4XNEE1pYGxu8yqFVd23dGeIRQhxP0EOUna9JIkYgwdiIhF65v)idErXJb99o4JRuv)idERQbjAVEjCdieShaP9qDRfsaxjSat0vkMgSejpD5rGOmNFZgYS0rcqQoc5i0Svcu6ZIU1uELVzZqtLTBmOSDcK9tx7Sr7OdzlSGSXlK9NJWkBf(tajzRHgfXy2F8ii7pzbB2McMnmBkhjajBHLVzZakczBaQ5ms2ys2Focl8tY23cYMbueI5v)idErXJb99o4sN8dmvkmPAaxyP9PGJcQItcbbD)x7H6M4JPcSHvIUXGIpDM8iojeKOmLqvWvZaxEWL04QoEwbfna1CgHp(hlAGahCjnUQJNvqrdqnNry8(Oxl9GQiDyn8Mx5B2m0uzV4SDJbL9NJsLTzGS)CewZMTWcYEHGKSlKMqAN9dbzZNqveZgVztJrOS)Cew4NKTVfKndOieZR(rg8IIhd67DWLo5hyQuys1aUWs7H6M4JPcSHvIUXGIZYyH0eds8Xub2Wkr3yqrZJ4YGxMhCjnUQJNvqrdqnNry8(Oxl9GQiDyn5v)idErXJb99oy2WAarCThQBTqc4kHfyIeC4dyAWsK80LhbIYC(nBitTma9JIkYgwdiIhF6m5rlXvWkr0Jwac1leIW60kWeiGwUMbYiqeXIGFgWurpkk8XLbVryDAfyceWGLyOtiybI6LpLm6Qbim(NjpiDqPQItcbbfP8TIPQ)2HnGU8dceqRdgRm4p3iBFheR4tNxEzYJwIRGvI7eYsqIR(bKiSoTcmbcOL4kyLieeY3W3SUaryDAfyce4GXkd(ZncbH8n8nRlqKaL(SOllkdEbFiUcwjAaqhivKqCXdHYiSoTcm8Mx5B2mu(oiwz)5iSYMHeekm7VzZd)tilbjU6hq0oBmjBUhTaeQxiKnEvfKnEZ(Vg8(rzZN4bnLVYSzafHS91Kndjiuy2eWnfKnfMK9cbjzZWXakI5v)idErXJb99oy2(oiwApu3IRGvIqqiFdFZ6ceH1PvGHjpIRGvI7eYsqIR(bKiSoTcmbciUcwjIE0cqOEHqewNwbgMSDY40kiIMnubvXjHGWlZdUKgx1XZkigVp61spOkshwdZdgRm4p3ieeY3W3SUarcu6ZIU8ptE0sCfSse9OfGq9cHiSoTcmbcOLRzGmcerSi4Nbmv0JIcFCzWBewNwbMabmyjg6ecwGOE5tjJUAaYL3)5nVY3SzO8DqSY(ZryLn)tilbjU6hqY(B28JZMHeek8JYMpXdAkFLzZakcz7RjBgkynGiE2p98QFKbVO4XG(EhmBFhelThQBXvWkXDczjiXv)asewNwbgMAjUcwjcbH8n8nRlqewNwbgMhCjnUQJNvqmEF0RLEqvKoSgMgG(rrfzdRbeXJp98kFZMdGSPEkv2hCzjSs24nBwIOJ(OGdoCewp64bxgCr6SHLfwzegudgqWfjo8bb)58Bc(drihHM1LbVm4hwe(4yWIeqGtoSI5v)idErXJb99oy2ozCAfO96LWncvz77Gyvp41mYGxTz7QhC7AgiJarelc(zatf9OOWhxg8gH1PvGHjplERiuL(rrbMQ4KqqqmE)pqaKoOuvXjHGGIu(wXu1F7Wgq3fIxM8Gqv6hffyQItcbbvDAmBOQ7RbkNZTMceaPdkvvCsiiOiLVvmv93oSbeJ3FaV5v)idErXJb99oyDmwvjac)ihqBkmPUqqY9FTHGeIx9s8BL7cx08QFKbVO4XG(EhmBFhelThQBXvWkr0Jwac1leIW60kWWulKaUsybMibh(aMhmwzWFUXqNqWceF6m5HTtgNwbreQY23bXQEWRzKbVbcOLRzGmcerSi4Nbmv0JIcFCzWBewNwbgMgSedDcblqKaueaXYPvaVmp4sACvhpRGIgGAoJW4np88)7f8HRzGmcerSi4Nbmv0JIcFCzWBewNwbgE5dKoOuvXjHGGIu(wXu1F7Wgq8YidpfMjXhtfydReDJbfNLX)xKx5B2mu(oiwz)5iSYMpXrcqY(drihn7hLn)4Src4kHv2(AYEXz7hzydzZN8Hzt)OO0o7I8PlpcK9ILSNnBcqraeRSj(gc5v)idErXJb99oy2(oiwApu3IRGvILosas1rihHMncRtRadtTqc4kHfyIUsXS0rcqQoc5i0Svcu6ZIU8wtm1YGLi5PlpcejafbqSCAfW0GLyOtiybIeO0NfXyHyYJwacb7bI0km2uXuvHfuHfkliw6FSysGa0pkQicaH1SHvIhcXNoV5v(Mnhl3G)SeuMSPWKS5yrWpdyYM7rrHpUm4nV6hzWlkEmOV3bJy5g8NLGYO9qDRfsaxjSat0vkMUMbYiqeXIGFgWurpkk8XLbVryDAfyyAWsm0jeSarcqraelNwbmnyjg6ecwGOE5tjJUAaYL3)zEWL04QoEwbfna1CgHX7)5v(MndjiKVHVzDbY(twWMnnwyLDr(0LhbY2xt2mCoHGfiBNaz)0ZMctYwH3WSHf)czLx9Jm4ffpg037GHGq(g(M1fq7H62GLi5PlpcejqPplIXc)TW8XrVw6bvr6WAyQLblXqNqWcejafbqSCAfKx9Jm4ffpg037GfCqZPsRCdO9qDBWsK80LhbIYC(nByEnVY3SlIdbos2gV0dHSD6rnYaO8kFZMHSSHfxMTlzx4VzZtr)M9NJWk7IihVzZakcXSzOllbZ4cOkiB8M9fFZwCsiiiTZ(ZryLndfSgqex7SXKS)CewzRrXFmKnwybKpheK9N(iztHjzJWLq2WcKWcIz)Hkeo7p9rYEOYMHeekm7dUKgN9GY(GlNnm7NEmV6hzWlkAgcCKByzdlUu7H6(GlPXvD8ScIX7c)vCfSs0aGoqQiH4IhcLryDAfyyYJbOFuur2WAar84tpqadq)OOIcoO5uPvUbIp9abGfiHfena1Cg5Y7lk6x2ozCAfeHfiHfujqiS1dUKEwWeiGwSDY40kiIMnubvXjHGWltE0sCfSsecc5B4BwxGiSoTcmbcCWyLb)5gHGq(g(M1fisGsFweJxWBE1pYGxu0me4iFVdMTtgNwbAVEjC)qqLAukGOnBx9G7dUKgx1XZkOObOMZim(pqaybsybrdqnNrU8(II(LTtgNwbrybsybvcecB9GlPNfmbcOfBNmoTcIOzdvqvCsii5v(MndVJWkBgYHfE2WSlw5gaPD2m89nBmv28P7Wgqz7s2x8nBXjHGGI5v)idErrZqGJ89oykFRyQ6VDydiThQB2ozCAfeFiOsnkfqy6AgiJar4WcpByLw5gafH1PvGHjshuQQ4KqqqrkFRyQ6VDydigVViVY3Sz47B2yQS5t3HnGY2LS)ZW(Mns8Zpu2yQS)yCmgyZUyLBau2ys2EOplsYUWFZMNI(n7phHv2fr8JwbzxeXiG3SfNecckMx9Jm4ffndboY37GP8TIPQ)2HnG0EOUz7KXPvq8HGk1OuaHjp0pkQiRXyGTsRCdGIiXp)y8(pdlqaE0sNmyYifujyXLbVmr6GsvfNeccks5Bftv)TdBaX4DH)YJRzGmcen4hTcQgmcIeF)X4f8(fjGRewGjsWHpGxEZR8nBg((MnMkB(0DydOSfC2UUUQGSlIGBufKDrapi8M9qL9S(rg2q24nBFliBXjHGKTlzxOSfNecckMx9Jm4ffndboY37GP8TIPQ)2HnG0(uWrbvXjHGGU)R9qDZ2jJtRG4dbvQrPactKoOuvXjHGGIu(wXu1F7WgqmExO8QFKbVOOziWr(EhmTAwdAmG2d1nBNmoTcIpeuPgLcim5H(rrfPvZAqJbIp9ab0sCfSsKnS4Yk5HyfH1PvGHPwUMbYiq0GF0kOAWiicRtRadV5v(MTgondYN8Kr5cKTGZ211vfKDreCJQGSlc4bH3SDj7lYwCsiiO8QFKbVOOziWr(EhC5tgLlG2NcokOkojee09FThQB2ozCAfeFiOsnkfqyI0bLQkojeeuKY3kMQ(Bh2a6(I8QFKbVOOziWr(EhC5tgLlG2d1nBNmoTcIpeuPgLci518kFZUi6LEiKnMnqYwMsiBNEuJmakVY3S)4MYrYMHZjeSaOSXB2lEzqDYusCsbzlojeeu2uys2cliBDYGjJuq2eS4YG3ShQSl63SPvayqz7eiBxra3uq2p98QFKbVOObl3SDY40kq71lHB0VrVEk4OGAOtiyb0MTREWTozWKrkOsWIldEzI0bLQkojeeuKY3kMQ(Bh2aIXcXKhdwIHoHGfisGsFw0LhmwzWFUXqNqWcenpIldEdeqhpi8cMkTcadIXIYBELVz)XnLJKDr(0LhbqzJ3Sx8YG6KPK4KcYwCsiiOSPWKSfwq26KbtgPGSjyXLbVzpuzx0VztRaWGY2jq2UIaUPGSF65v)idErrdw(EhmBNmoTc0E9s4g9B0RNcokOsE6YJaAZ2vp4wNmyYifujyXLbVmr6GsvfNeccks5Bftv)TdBaXyHyYJbOFuurbh0CQ0k3aXNEGa8OJheEbtLwbGbXyrzQLRzGmcerhyLkMQsRWytewNwbgE5nVY3S)4MYrYUiF6YJaOShQSzOG1aI4F1ah0CYUyLBGShu2p9S91K9Nq2SC2q2x8nBeCWRbLTcOKSXB2cli7I8PlpcKDreRrE1pYGxu0GLV3bZ2jJtRaTxVeUr)g9k5PlpcOnBx9GBdq)OOISH1aI4XNotdq)OOIcoO5uPvUbIpDMgSejpD5rGibk9zrmErELVzZPdNXvzxKpD5rGSrG80ZMctYMHeekmV6hzWlkAWY37GjpD5raThQBXvWkriiKVHVzDbIW60kWWKhEo4sACvhpRGy8(Oxl9GQiDynmpySYG)CJqqiFdFZ6cejqPpl6Y)8giapAjZ53SHm5rMsGX)AkqGdUKgx1XZkigVVGxE5nVY3Sz4Ccblq2p9FaORD2UcHZwidGYwWz)qq2JKTJY2ZgPdNXvzhclqCbtYMctYwybzRCKKndOiKnnqHjq2E2uZoiwajV6hzWlkAWY37G1XyvLai8JCaTPWK6cbj3)ZR(rg8IIgS89o4qNqWcO9qDZJwIRGvIOhTaeQxieH1PvGjqaT45GXkd(ZnY23bXk(0zEWyLb)5gzdRbeXJeO0NfD5DH5LxMhCjnUQJNvqrdqnNry8()3cXh84AgiJarelc(zatf9OOWhxg8gH1PvGH5bJvg8NBKTVdIv8PZltcqraelNwbm5rV8PKrxna5Y7)bcqGsFw0L3YC(vLPeyI0bLQkojeeuKY3kMQ(Bh2aIX7c911mqgbIiwe8ZaMk6rrHpUm4ncRtRadVm5rliiKVHVzDbmbcqGsFw0L3YC(vLPe4JlyI0bLQkojeeuKY3kMQ(Bh2aIX7c911mqgbIiwe8ZaMk6rrHpUm4ncRtRadVm1cHQ0pkkWWKhXjHGeLPeQcUAgGbjqPplIxglmtEkDKaKQJqocnBLaL(SOBnfiGwYC(nBiV5v)idErrdw(EhSogRQeaHFKdOnfMuxii5(FE1pYGxu0GLV3bh6ecwaTpfCuqvCsiiO7)Apu3AX2jJtRGi63OxpfCuqn0jeSam5rlXvWkr0Jwac1leIW60kWeiGw8CWyLb)5gz77GyfF6mpySYG)CJSH1aI4rcu6ZIU8UW8YlZdUKgx1XZkOObOMZimE))BH4dECndKrGiIfb)mGPIEuu4JldEJW60kWW8GXkd(ZnY23bXk(05LjbOiaILtRaM8Ox(uYORgGC59)abiqPpl6YBzo)QYucmr6GsvfNeccks5Bftv)TdBaX4DH(6AgiJarelc(zatf9OOWhxg8gH1PvGHxM8OfeeY3W3SUaMabiqPpl6YBzo)QYuc8Xfmr6GsvfNeccks5Bftv)TdBaX4DH(6AgiJarelc(zatf9OOWhxg8gH1PvGHxMAHqv6hffyyYJ4KqqIYucvbxndWGeO0NfXlJ)VGjpLosas1rihHMTsGsFw0TMceqlzo)MnK38kFZMbqMseEZwdOuhqs24vvq24n7YNsgDfKT4Kqqqz7s2f(B2mGIq2FYc2SjVDNnmB8tYE2SVaLnpp9SfC2foBXjHGG4nBmj7cHYMNI(nBXjHGG4nV6hzWlkAWY37GpKPeH3QaL6as0EOUr6GsvfNeccIX7lysGsFw0Lx8LhKoOuvXjHGGy8UO8Y8GlPXvD8ScIX7cNx5B28PaON9tp7I8PlpcKTlzx4VzJ3SDLkBXjHGGYMNpzbB2QH9SHzRWBy2WIFHSY2xt2lwYgTUoIfw4nV6hzWlkAWY37GjpD5raThQBTy7KXPvqe9B0RKNU8iaZdUKgx1XZkigVlmtcqraelNwbm5rV8PKrxna5Y7)bcqGsFw0L3YC(vLPeyI0bLQkojeeuKY3kMQ(Bh2aIX7c911mqgbIiwe8ZaMk6rrHpUm4ncRtRadVm5rliiKVHVzDbmbcqGsFw0L3YC(vLPe4JlyI0bLQkojeeuKY3kMQ(Bh2aIX7c911mqgbIiwe8ZaMk6rrHpUm4ncRtRadVmfNecsuMsOk4QzagKaL(SiglCE1pYGxu0GLV3btE6YJaAFk4OGQ4Kqqq3)1EOU1ITtgNwbr0VrVEk4OGk5PlpcWul2ozCAfer)g9k5PlpcW8GlPXvD8ScIX7cZKaueaXYPvatE0lFkz0vdqU8(FGaeO0NfD5TmNFvzkbMiDqPQItcbbfP8TIPQ)2HnGy8UqFDndKrGiIfb)mGPIEuu4JldEJW60kWWltE0ccc5B4BwxatGaeO0NfD5TmNFvzkb(4cMiDqPQItcbbfP8TIPQ)2HnGy8UqFDndKrGiIfb)mGPIEuu4JldEJW60kWWltXjHGeLPeQcUAgGbjqPplIXcNxZR8nBgccb7bq5v)idErraHG9aO7dEpWkexatLs5LqELVz)HQp9cqz)qq2fRWyt2FocRSzOG1aI4z)0Jz)Hkeo7hcY(ZryLTgfN9tpBEgQSfxbRagEZ2rzRWBy2ok7rYM8wu2uys2)1ekBZJmBy2muWAar8yE1pYGxueqiypa67DW0km2uXuvHfuHfklq7H62a0pkQiBynGiE8PZKhTexbRefCqZPsRCdeH1PvGjqadq)OOIcoO5uPvUbIp9abma9JIkYgwdiIhjqPpl6Y7)AI3abeNecsuMsOk4QzGlV)RP8QFKbVOiGqWEa037GdFoXm(wXuvxZablSYR(rg8IIacb7bqFVdMcFEiWuDndKrGkn4LApu3iDqPQItcbbfP8TIPQ)2HnGy8(Iabi(yQaByLOBmO4Sm(bAkV6hzWlkcieSha99oy9hzOky2WkTYrI2d1nshuQQ4KqqqrkFRyQ6VDydigVViqaIpMkWgwj6gdkolJFGMYR(rg8IIacb7bqFVdwyb13sJFRPsHjhiV6hzWlkcieSha99oyYORRG6SvKUFG8QFKbVOiGqWEa037G)etug2WSvcGWRVhiV6hzWlkcieSha99o4sOetkOIPQQ3zmvdb8sK2d1nSajSGllQMYR5v(MnNaUsybMS)WJm4fLx5B28pHSqIR(beTZgtYM7rlFzibHcZgVz)xJpkBU11rSWs2f5txEeiV6hzWlkIeWvclWCtE6YJaApu3hCjnUQJNvqmExyM8iUcwjUtilbjU6hqIW60kWeiG4kyLi6rlaH6fcryDAfyyYJ4kyLieeY3W3SUaryDAfyyEWyLb)5gHGq(g(M1fisGsFw0L3xeiGwYC(nBiVmz7KXPvqenBOcQItcbHxMItcbjktjufC1madsGsFweJFqELVzZ9OfGq9cHS)Mnhlc(zat2Cpkk8XLbVFu2mKf9iq2Fcz)qq24fYouHPDv2coBxxxvq2mCoHGfiBbNTWcYU0NnBXjHGK9qL9izpOSxSKnADDelSKDbGOD2iC2UsLnwybKSl9zZwCsiiz70JAKbqzRtWuJeZR(rg8IIibCLWcmFVdwhJvvcGWpYb0MctQleKC)pV6hzWlkIeWvclW89o4qNqWcO9qD7AgiJarelc(zatf9OOWhxg8gH1PvGHj9JIkIE0cqOEHq8PZK(rrfrpAbiuVqisGsFw0L)JfIPwiuL(rrbM8kFZM7rlaH6fcFu2FOUUQGSXKSlsGIaiwz)5iSYM(rrbMSz4CcblakV6hzWlkIeWvclW89oyDmwvjac)ihqBkmPUqqY9)8QFKbVOisaxjSaZ37GdDcblG2NcokOkojee09FThQBXvWkr0Jwac1leIW60kWWKhcu6ZIU8)fbcOx(uYORgGC59FEzkojeKOmLqvWvZamibk9zrmErELVzZ9OfGq9cHS)Mnhlc(zat2Cpkk8XLbVzpB2CA8rz)H66QcYgCIQGSlYNU8iq2clxY(ZrPYMgYMaueaXcmztHjzR7RbkNtE1pYGxuejGRewG57DWKNU8iG2d1T4kyLi6rlaH6fcryDAfyy6AgiJarelc(zatf9OOWhxg8gH1PvGHPwgSejpD5rGOmNFZgYKTtgNwbr0SHkOkojeK8kFZM7rlaH6fcz)zWzZXIGFgWKn3JIcFCzW7hLDrcUUUQGSPWKSPX7dLndOiKTVMGXKSHGeynGjB066iwyjBZJ4YG3yE1pYGxuejGRewG57DW6ySQsae(roG2uysDHGK7)5v)idErrKaUsybMV3bh6ecwaTpfCuqvCsiiO7)Apu3IRGvIOhTaeQxieH1PvGHPRzGmcerSi4Nbmv0JIcFCzWBewNwbgMItcbjktjufC1maJeO0NfXKhcu6ZIU8pFoqaTqOk9JIcm8Mx5B2CpAbiuVqi7VzZqccf(rzZqydB2y2aHmgiBpB066iwyjBgoNqWcKnzczjz7ucqYUiF6YJaztduycKndjiKVHVzDzWBE1pYGxuejGRewG57DW6ySQsae(roG2uysDHGK7)5v)idErrKaUsybMV3bh6ecwaThQBXvWkr0Jwac1leIW60kWWuCfSsecc5B4BwxGiSoTcmmpySYG)CJqqiFdFZ6cejqPpl6Y)m1ja7A4Xe)hjpD5raMgSejpD5rGibk9zrmw0VfMpo61spOkshwJLdPdhl)xuugMvSI1c]] )
    

end