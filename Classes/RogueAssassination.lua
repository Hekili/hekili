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

    -- 587c02a72bd50631ec7949f7b257a3fab1d7100f
    spec:RegisterPack( "Assassination", 20190625.0930, [[d0u8kbqirOhHuXLKiOSjuLrjI6uIiRsIKEfGAwuvClaP2LO(fQkdJQsDmGQLbiEMertdPsxdvQ2gqP6BOsHXjrGZHkLwhvL07aKqnpGI7bK9Hu1bLivlue8qjszIOsrxuIeBuIGQpsvjmsjccNeqIwjaEjqP4MaLs7ev0pLiiAOasAPse6POyQOsUkGeSvQkrFfqczVK8xqgSIdtzXi5XsAYu5YQ2mk9zQYOrkNwPvlrq61OcZMu3wc7wQFd1WfPLJ45qMoX1b12PQ67auJhvvNhGSEGsMVe1(fwbUIlfJZKR4ei(gCU13GDGW9SV52scUVb7kgbqPxXKAvomVRyAR4kMshHmeABtwCRysnaPXMtXLIbHHj1RyOjskYx5JpVvObtLR4c(qBbS2Kf3vIXk8H2IkFkgk4vlaLTIsX4m5kobIVbNB9nyhiCp7BUTKG77sQymyHgMOyy2IstXqBDU3kkfJ7OQIHoXu6iKHqBBYI7ykrSh8daOtm0ejf5R8XN3k0GPYvCbFOTawBYI7kXyf(qBrLVaa6edaW9JbiC3NyaIVbNBJbOJX3CRVwsFhaeaqNyknAw7DKVgaqNya6ykDN7UyaB2khXi4yCN1G1smwvwChJErsoaGoXa0XuIVa7)XigX7c0YMdaOtmaDmLUZDxmafqpgGs5fOysgdlO19yWSXGKBAHwszfJErcsXLIbj30cT7uCP4eCfxkM3gL(ovckMkzLtwtXuXfuyOu82ckg6bfdDJHxmjhJy63sUxpAcsmnhNKFBu67IPC5yet)wYiyk5ewyVNFBu67IHxmjhJy63s(8JS2dEBtE(TrPVlgEXuXyTdd4oF(rw7bVTjptEHTnkgWakgGet5YXKymYw5yBVyskgEX43iRrPFgTTN(qIr8UetsXWlgXiExYYwCibd52hdqhd5f22OyOpgWUIXQYIBfdbovGjxjkobIIlfZBJsFNkbfJvLf3kgpJqWYvmvYkNSMIrm9BjJGPKtyH9E(TrPVlgEXqol5iAgL(XWlgXiExYYwCibd52hdqhd5f22OyOpgGOyQaQQpKyeVlifNGRefNLuXLI5TrPVtLGIXQYIBfJNriy5kMkzLtwtXiM(TKrWuYjSWEp)2O03fdVyiVW2gfdyafd4(ogEXKwaRLnvVNedyafd4XWlgXiExYYwCibd52hdqhd5f22OyOpgGOyQaQQpKyeVlifNGRefN0vXLI5TrPVtLGIPsw5K1umIPFlzemLCclS3ZVnk9DXWlgdSozLNr0iyy3DqiywwC1Kf353gL(Uy4ftIX4WsMaNkWKNLTYX2EkgRklUvme4ubMCLO4K7kUumVnk9DQeumSycuF(ffNGRySQS4wXKIXAiYryys9krXjyxXLI5TrPVtLGIXQYIBfJNriy5kMkzLtwtXiM(TKrWuYjSWEp)2O03fdVymW6KvEgrJGHD3bHGzzXvtwCNFBu67IHxmIr8UKLT4qcgYTpg6JH8cBBum8Ij5yiVW2gfdyIb8sqmLlhtIXGqquWSS3ftskMkGQ6djgX7csXj4krXj3qXLI5TrPVtLGIHftG6ZVO4eCfJvLf3kMumwdrocdtQxjkolbkUumVnk9DQeumvYkNSMIrm9BjJGPKtyH9E(TrPVlgEXiM(TKp)iR9G32KNFBu67IHxmvmw7WaUZNFK1EWBBYZKxyBJIbmXaEm8IjLC)qEvxg8mbovGjpgEX4WsMaNkWKNjVW2gfd9XW9yaog6gtPgtnfQW4hcL(2PySQS4wX4zecwUsuII5i076rkUuCcUIlfJvLf3kMkURVfIj3bXQTIRyEBu67ujOefNarXLIXQYIBfdLgJDqywiH2HE)caPyEBu67ujOefNLuXLIXQYIBfJhSrCR1qywidSobl0umVnk9DQeuIIt6Q4sXyvzXTIHfxHr3bzG1jRCiQBfkM3gL(ovckrXj3vCPySQS4wXKctwwaTTheL2qII5TrPVtLGsuCc2vCPySQS4wXi0oeCtHHBhelMuVI5TrPVtLGsuCYnuCPySQS4wXq20u9H2gcLA1RyEBu67ujOefNLafxkgRklUvmagt0o)FBiYr4266vmVnk9DQeuIItUvXLI5TrPVtLGIPsw5K1umVpXdqXaMy4UVvmwvwCRykEbMaiimlKgUUoih5wbsjkrX4oRbRffxkobxXLI5TrPVtLGIPsw5K1umjgdsUPfA3LnTwXyvzXTIHJTYHsuCcefxkgRklUvmi5MwOPyEBu67ujOefNLuXLI5TrPVtLGIbNQyqxumwvwCRy8BK1O0xX430WxX8(epaLj37DmahtkEr4(oik9VdftPgd3iMsyXKCmajMsngu61AiAgsEmjPy8BeO2kUI59jEacICV3qvCb123PefN0vXLI5TrPVtLGIbNQyqxumwvwCRy8BK1O0xX430WxXGsVwdjgX7ckZAneMfIJE9FumGjgGOy8BeO2kUIbTTN(qIr8UOefNCxXLI5TrPVtLGIPsw5K1umi5MwODxMG9GVIXQYIBft10AiRklUH0lsum6fjqTvCfdsUPfA3PefNGDfxkM3gL(ovckgRklUvmvtRHSQS4gsVirXOxKa1wXvmvhsjko5gkUumVnk9DQeumwvwCRyQMwdzvzXnKErIIrVibQTIRyCyrjkolbkUumVnk9DQeumwvwCRyQMwdzvzXnKErIIrVibQTIRyCl5vrjko5wfxkM3gL(ovckMkzLtwtX8(epaLDNDRRed9GIbCUhdWX43iRrPF(9jEacICV3qvCb123PySQS4wXyKQ1hsWeYBrjkob33kUumwvwCRyms16dLcRrxX82O03PsqjkobhCfxkgRklUvm61JMGGkHc78kElkM3gL(ovckrjkMuYR4cktuCP4eCfxkM3gL(ovckrXjquCPyEBu67ujOefNLuXLI5TrPVtLGsuCsxfxkM3gL(ovckrXj3vCPySQS4wXyPPAabLIxeUvmVnk9DQeuIItWUIlfJvLf3kgKCtl0umVnk9DQeuIItUHIlfJvLf3kMuSS4wX82O03PsqjkolbkUumVnk9DQeumwvwCRykmch3bXIjqUBcnftLSYjRPyi26GU)3s2CouE7yOpg66Bftk5vCbLjqOxXTdPy4UsuIIXTKxffxkobxXLI5TrPVtLGIPsw5K1umvCbfgkfVTGIHEqXq3yaogX0VLS7p9eiKqmX8Er(TrPVlgEXKCmUtbZYM9)2DrSmCAmLlhJ7uWSSzbZ)wHO0M7z40ykxoM3N4bOS7SBDLyadOyac3Jb4y8BK1O0p)(epabrU3BOkUGA77IPC5ysmg)gznk9ZOT90hsmI3LyskgEXKCmjgJy63s(8JS2dEBtE(TrPVlMYLJPIXAhgWD(8JS2dEBtEM8cBBum0hdqIjjfJvLf3kM3(FJluIItGO4sX82O03PsqXGtvmOlkgRklUvm(nYAu6Ry8BA4RyQ4ckmukEBbLDNDRRed9XaEmLlhZ7t8au2D2TUsmGbumaH7XaCm(nYAu6NFFIhGGi37nufxqT9DXuUCmjgJFJSgL(z02E6djgX7IIXVrGAR4kgy0HyxT(eLO4SKkUumVnk9DQeumvYkNSMIXVrwJs)mm6qSRwFsm8IHcMLnJOzK033brPn3rzKyvoIHEqXaeUvXyvzXTIjfViCFheh9YELO4KUkUumVnk9DQeumvYkNSMIXVrwJs)mm6qSRwFsm8Ij5yOGzzZ0wN7neL2ChLrIv5ig6bfd4CBmLlhdk9AnKyeVlOmR1qywio61)rXqpOyOBmahtYXyG1jR8SddtPpKdJEMynhXqFmajMKIb4yqYnTq7Umb7b)yssXyvzXTIH1Aimleh96)iLO4K7kUumVnk9DQeumvYkNSMIXVrwJs)mm6qSRwFsm8IbLETgsmI3fuM1Aimleh96)OyOhumLuXyvzXTIH1Aimleh96)iLO4eSR4sX82O03PsqXujRCYAkg)gznk9ZWOdXUA9jXWlMKJHcMLntP32Hw3ZWPXuUCmjgJy63s2)BCbebgrl)2O03fdVysmgdSozLNDyyk9HCy0ZVnk9DXKKIXQYIBfdLEBhADxjko5gkUumVnk9DQeumvYkNSMIXVrwJs)mm6qSRwFsm8IbLETgsmI3fuM1Aimleh96)OyafdqumwvwCRykGLvBYvIIZsGIlfZBJsFNkbftLSYjRPy8BK1O0pdJoe7Q1NOySQS4wXualR2KReLOyQoKIlfNGR4sX82O03PsqXujRCYAkgkyw2mLgJDAyKKj3QsmLlhJ7uWSSz)VDxeldNQySQS4wXKILf3krXjquCPyEBu67ujOySQS4wX4z6xnT(eeefg3kMkzLtwtXKymi5MwODxMG9GFm8IPIXAhgWD2)B3fXYKxyBJIH(yOl3vmTvCfJNPF106tqquyCRefNLuXLI5TrPVtLGIPsw5K1umjgdsUPfA3Ljyp4hdVyQyS2HbCN9)2DrSm5f22OyOpg6YDfJvLf3kgy0Hw5fiLO4KUkUumVnk9DQeumvYkNSMIXDkyw2S)3UlILHtvmwvwCRyO0ySdIfMaiLO4K7kUumVnk9DQeumvYkNSMIXDkyw2S)3UlILHtvmwvwCRyOobDchB7PefNGDfxkM3gL(ovckMkzLtwtX4ofmlB2)B3fXYWPkgRklUvmSl5uAm2PefNCdfxkM3gL(ovckMkzLtwtX4ofmlB2)B3fXYWPkgRklUvmwxpsiMgQAATsuCwcuCPyEBu67ujOyQKvoznfdXwh09)wYMZHYWPXWlMKJrmI3LSSfhsWqU9XaMyQ4ckmukEBbLDNDRRetPgd4zUht5YXuXfuyOu82ck7o7wxjg6bftnfQW4hcL(2ftskgRklUvmfgHJ7GyXei3nHMsuCYTkUumVnk9DQeumvYkNSMIHyRd6(FlzZ5q5TJH(ykPVJbOJHyRd6(FlzZ5qzhmXKf3XWlMkUGcdLI3wqz3z36kXqpOyQPqfg)qO03ofJvLf3kMcJWXDqSycK7Mqtjkob33kUumVnk9DQeumvYkNSMIjXyqYnTq7Umb7b)y4fJdlzcCQatEw2khB7fdVysmg3PGzzZ(F7UiwgongEXKCmjgJy63sgbtjNWc798BJsFxmLlhtIXyG1jR8mIgbd7UdcbZYIRMS4o)2O03ft5YX4Ws2ZieS8CAbSw2u9Esm0hd4XKum8Ij5ysmgX0VLCVE0eKyAooj)2O03ft5YXKymIPFl5ZpYAp4Tn553gL(UykxoMkgRDya35ZpYAp4Tn5zYlSTrXaMy4EmaDmajMsngX0VLS7p9eiKqmX8Er(TrPVlMKumwvwCRy8)2DrmLO4eCWvCPyEBu67ujOyQKvoznfJy63sgbtjNWc798BJsFxm8IjXyCyj7zecwEw2khB7fdVy8BK1O0pJ22tFiXiExumwvwCRy8B9IOPefNGdefxkM3gL(ovckMkzLtwtXiM(TKp)iR9G32KNFBu67IHxmjhJy63sUxpAcsmnhNKFBu67IPC5yet)wYiyk5ewyVNFBu67IHxm(nYAu6NrB7PpKyeVlXKum8IPIlOWqP4Tfum0dkMAkuHXpek9TlgEXuXyTdd4oF(rw7bVTjptEHTnkgWed4XWlMKJjXyet)wYiyk5ewyVNFBu67IPC5ysmgdSozLNr0iyy3DqiywwC1Kf353gL(UykxoghwYEgHGLNtlG1YMQ3tIbmGIb8yssXyvzXTIXV1lIMsuCcEjvCPyEBu67ujOyQKvoznfJy63sUxpAcsmnhNKFBu67IHxmjgJy63s(8JS2dEBtE(TrPVlgEXuXfuyOu82ckg6bftnfQW4hcL(2fdVyCNcMLn7)T7Iyz4ufJvLf3kg)wViAkrXj40vXLI5TrPVtLGIPsw5K1umIPFlzemLCclS3ZVnk9DXWlMKJjXyet)wYNFK1EWBBYZVnk9DXuUCmjgJFJSgL(z02E6djgX7smjfdVysmgKCtl0UltWEWpgEXuXyTdd4o7zecwEgongEX4Ws2ZieS8m5SKJOzu6hdVysogu61AiXiExqzwRHWSqC0R)JIbmGIPKXWlMkUGcdLI3wqz3z36kXqpOyapgGJbLETgsmI3fuM1Aimleh96)Oykxogu61AiXiExqzwRHWSqC0R)JIHEqXq3y4ftfxqHHsXBlOS7SBDLyOhum0nMKumwvwCRy8B9IOPefNGZDfxkM3gL(ovckMkzLtwtXiM(TKlmKCcKHqgcTD(TrPVlgEXKymi5MwODx206y4ftHHKtGmeYqOTHiVW2gfdyafJVJHxmjgJdlzcCQatEMCwYr0mk9JHxmoSK9mcblptEHTnkg6JPKkgRklUvm(TEr0uIItWb7kUumVnk9DQeumvYkNSMIjXyqYnTq7USP1XWlgdSozLNr0iyy3DqiywwC1Kf353gL(Uy4fJdlzpJqWYZKZsoIMrPFm8IXHLSNriy550cyTSP69KyadOyapgEXuXfuyOu82ck7o7wxjg6bfd4kgRklUvmiAMdd4IRDkrXj4CdfxkM3gL(ovckMkzLtwtX4WsMaNkWKNjVW2gfd9Xq3yaog6gtPgtnfQW4hcL(2fdVysmghwYEgHGLNjNLCenJsFfJvLf3kMZpYAp4Tn5krXj4LafxkM3gL(ovckMkzLtwtX4WsMaNkWKNLTYX2EkgRklUvmcM)TcrPn3vIItW5wfxkM3gL(ovckgRklUvmvtRHSQS4gsVirXOxKa1wXvmhHExpsjkrX4WIIlfNGR4sX82O03PsqXujRCYAkgX0VL85hzTh82M88BJsFxm8Ij5ysoMkUGcdLI3wqXqpOyQPqfg)qO03Uy4ftfJ1omG785hzTh82M8m5f22OyatmGhtsXuUCmjhtIXiBLJT9IHxmjhJSfpg6JbCFht5YXuXfuyOu82ckg6bfdqIjPyskMKumwvwCRyiWPcm5krXjquCPyEBu67ujOyyXeO(8lkobxXyvzXTIjfJ1qKJWWK6vIIZsQ4sX82O03PsqXyvzXTIXZieSCftLSYjRPysoMeJrm9BjJGPKtyH9E(TrPVlMYLJjXysoMkgRDya3z)wViAz40y4ftfJ1omG7S)3UlILjVW2gfdyafdDJjPyskgEXuXfuyOu82ck7o7wxjg6bfd4XWlgYzjhrZO0pgEXKCmPfWAzt17jXagqXaEmLlhd5f22OyadOyKTYbKSfpgEXGsVwdjgX7ckZAneMfIJE9Fum0dkMsgdWXyG1jR8mIgbd7UdcbZYIRMS4o)2O03ftsXWlMKJjXyo)iR9G32K7IPC5yiVW2gfdyafJSvoGKT4XuQXaKy4fdk9AnKyeVlOmR1qywio61)rXqpOykzmahJbwNSYZiAemS7oiemllUAYI78BJsFxmjfdVysmgecIcML9Uy4ftYXigX7sw2Idjyi3(ya6yiVW2gfd9Xq3y4fdk9AnKyeVlOmR1qywio61)rXagqXaEmLlhJyeVlzzloKGHC7JbOJH8cBBum0hd4ajMKIHxmjhtHHKtGmeYqOTHiVW2gfdOy8DmLlhtIXiBLJT9Ijjftfqv9HeJ4DbP4eCLO4KUkUumVnk9DQeumvYkNSMIbLETgsmI3fum0dkgGedVyiVW2gfdyIbiXaCmjhdk9AnKyeVlOyOhumCpMKIHxmvCbfgkfVTGIHEqXqxfJvLf3kMkzlq4gsEr6rIsuCYDfxkM3gL(ovckgRklUvme4ubMCftLSYjRPyQ4ckmukEBbfd9GIHUXWlgYzjhrZO0pgEXKCmPfWAzt17jXagqXaEmLlhd5f22OyadOyKTYbKSfpgEXGsVwdjgX7ckZAneMfIJE9Fum0dkMsgdWXyG1jR8mIgbd7UdcbZYIRMS4o)2O03ftsXWlMKJjXyo)iR9G32K7IPC5yiVW2gfdyafJSvoGKT4XuQXaKy4fdk9AnKyeVlOmR1qywio61)rXqpOykzmahJbwNSYZiAemS7oiemllUAYI78BJsFxmjfdVyeJ4DjlBXHemKBFmaDmKxyBJIH(yORIPcOQ(qIr8UGuCcUsuIsum(pbT4wXjq8n4CRVlj4(o7BFZDUHIbWgP32dPyaklsXe5Uy4gXyvzXDm6fjOCaGIbL(QItGWDUvXKsWSR(kg6etPJqgcTTjlUJPeXEWpaGoXqtKuKVYhFERqdMkxXf8H2cyTjlUReJv4dTfv(caOtmLEkz1XaUpXaeFdo3gdqhJV5wFfCWdacaOtmLgnR9oYxdaOtmaDmLUZDxmGnBLJyeCmUZAWAjgRklUJrVijhaqNya6ykXxG9)yeJ4DbAzZba0jgGoMs35UlgGcOhdqP8cumjJHf06Emy2yqYnTqlPCaqaaDIPu4)vy5UyOolM8yQ4cktIH6EBJYXu616tfumnUbAAgPGfwhJvLf3OyWTgq5aaRklUr5uYR4cktaXQnehbawvwCJYPKxXfuMami(myVI3IjlUdaSQS4gLtjVIlOmbyq8XIXUaa6edtBPiAyjgITUyOGzzVlgKyckgQZIjpMkUGYKyOU32OyS2ftk5aDkwKT9IzrX4W9ZbawvwCJYPKxXfuMami(qTLIOHfiKyckaWQYIBuoL8kUGYeGbXNLMQbeukEr4oaWQYIBuoL8kUGYeGbXhsUPfAbawvwCJYPKxXfuMami(sXYI7aaRklUr5uYR4cktageFfgHJ7GyXei3nHMpPKxXfuMaHEf3oeiU7ZYcIyRd6(FlzZ5q5TPNU(oaiaGoXuk8)kSCxm3)jakgzlEmcThJvfmjMffJ53wTrPFoaGoXuIhj30cTyw2ysXi0sPFmj34y8dR7tmk9J59l2JIz7yQ4cktskaWQYIBeio2kh(SSGsej30cT7YMwhayvzXncyq8HKBAHwaGvLf3iGbXNFJSgL((0wXb9(epabrU3BOkUGA778XVPHpO3N4bOm5EVbofViCFheL(3HkvUrjSKbsPIsVwdrZqYtkaWQYIBeWG4ZVrwJsFFAR4GqB7PpKyeVl(430Whek9AnKyeVlOmR1qywio61)rGbibawvwCJageFvtRHSQS4gsViXN2koiKCtl0UZNLfesUPfA3Ljyp4hayvzXncyq8vnTgYQYIBi9IeFAR4GQouaGvLf3iGbXx10AiRklUH0ls8PTIdYHLaaRklUradIVQP1qwvwCdPxK4tBfhKBjVkbawvwCJageFgPA9HemH8w8zzb9(epaLDNDRRqpiW5oW(nYAu6NFFIhGGi37nufxqT9DbawvwCJageFgPA9HsH1OhayvzXncyq8PxpAccQekSZR4TeaeaqNyknmw7WaUrbawvwCJYvhcukwwC7ZYcIcMLntPXyNggjzYTQuUS7uWSSz)VDxeldNgayvzXnkxDiGbXhm6qR8cFAR4G8m9RMwFccIcJBFwwqjIKBAH2Dzc2d(8QyS2HbCN9)2DrSm5f22i6Pl3daSQS4gLRoeWG4dgDOvEbYNLfuIi5MwODxMG9GpVkgRDya3z)VDxeltEHTnIE6Y9aaRklUr5Qdbmi(O0ySdIfMaiFwwqUtbZYM9)2DrSmCAaGvLf3OC1HageFuNGoHJT98zzb5ofmlB2)B3fXYWPbawvwCJYvhcyq8XUKtPXyNplli3PGzzZ(F7UiwgonaWQYIBuU6qadIpRRhjetdvnT2NLfK7uWSSz)VDxeldNgaqNyakzJXCoumg5XaN6tmOEtFmcThdUFmaEfAXOXa(ijgU4IBMJbOa6XayAVJXbOT9IH1qYjXi0SoMsdOgJ7SBDLyWKya8k0WWsmwdOyknGAoaWQYIBuU6qadIVcJWXDqSycK7MqZNLfeXwh09)wYMZHYWP8swmI3LSSfhsWqU9GPIlOWqP4Tfu2D2TUsPcEM7LlxXfuyOu82ck7o7wxHEq1uOcJFiu6Bxsba0jgGs2yACmMZHIbWRwhJBFmaEfABhJq7X0NFjMs6BKpXaJEmGTSCZyWDmuyekgaVcnmSeJ1akMsdOMdaSQS4gLRoeWG4RWiCChelMa5Uj08zzbrS1bD)VLS5CO820xsFd0eBDq3)BjBohk7GjMS4MxfxqHHsXBlOS7SBDf6bvtHkm(HqPVDba0jgF5B3fXIbdlO19yqYnTqlgaVcTykr4ubM8yGtZXau0k0IHbMsoHf27XiM(TeJ1UyyOrWWU7IHbMLfxnzXDmPyaFsmMgWgGqXaJEmaEfAXqbZYExm(cJqWYZXau0k0IHZ1JMGetZXjXyTlMsHFK1EWBBYJbg9yGtJrWXWDumjxsumaEfAXWnzskgQZIjpgFP1lIwmvCbfohayvzXnkxDiGbXN)3UlI5ZYckrKCtl0UltWEWNNdlzcCQatEw2khB7Xlr3PGzzZ(F7UiwgoLxYjkM(TKrWuYjSWEp)2O03vUCIgyDYkpJOrWWU7GqWSS4QjlUZVnk9DLl7Ws2ZieS8CAbSw2u9Ec9GNeVKtum9Bj3RhnbjMMJtYVnk9DLlNOy63s(8JS2dEBtE(TrPVRC5kgRDya35ZpYAp4Tn5zYlSTrGH7anqkvX0VLS7p9eiKqmX8Er(TrPVlPaa6etPWVqSyyGPKtyH9Em(sRxeTyQ42TYIBFngGcOhdGP9ogFHriy5X4i4007Ib3XWSTN(XWLr8UeayvzXnkxDiGbXNFRxenFwwqIPFlzemLCclS3ZVnk9D8s0HLSNriy5zzRCSThp)gznk9ZOT90hsmI3Laa6eJV06frlgaVcTykf(rEXaCmjZ56rtqIP54eFIbtIHbMsoHf27XGBnGIb3Xaoxj5RXa2A8VfWfXuAa1yS2ftPWpYlgYnhGIHftIPp)sm(IsJBgayvzXnkxDiGbXNFRxenFwwqIPFl5ZpYAp4Tn553gL(oEjlM(TK71JMGetZXj53gL(UYLft)wYiyk5ewyVNFBu67453iRrPFgTTN(qIr8UKeVkUGcdLI3wq0dQMcvy8dHsF74vXyTdd4oF(rw7bVTjptEHTncmGZl5eft)wYiyk5ewyVNFBu67kxordSozLNr0iyy3DqiywwC1Kf353gL(UYLDyj7zecwEoTawlBQEpbmGapPaa6eJV06frlgaVcTy4C9OjiX0CCsmahdN4ykf(rE(AmGTg)BbCrmLgqngRDX4lF7UiwmWPbawvwCJYvhcyq8536frZNLfKy63sUxpAcsmnhNKFBu674LOy63s(8JS2dEBtE(TrPVJxfxqHHsXBli6bvtHkm(HqPVD8CNcMLn7)T7Iyz40aa6eJV06frlgaVcTyyGPKtyH9EmahtYCIJPu4h5fdMedq4c4K81y4ehdsUPfA8HGPKtyH9UpX4lmcblpMs8SKJOzu67tmVXWE0IbLA1hdlMeZ2vCX2EX4lmcblpMsdOgayvzXnkxDiGbXNFRxenFwwqIPFlzemLCclS3ZVnk9D8sorX0VL85hzTh82M88BJsFx5Yj63iRrPFgTTN(qIr8UKeVerYnTq7Umb7bFEvmw7WaUZEgHGLNHt55Ws2ZieS8m5SKJOzu6Zlzu61AiXiExqzwRHWSqC0R)JadOsYRIlOWqP4Tfu2D2TUc9Gahyu61AiXiExqzwRHWSqC0R)JkxgLETgsmI3fuM1Aimleh96)i6brxEvCbfgkfVTGYUZU1vOheDtkaGoX4lTEr0IbWRqlgWwdjNetPJqgABFngoXXGKBAHwmw7IPXXyvz9)yaBl9yOGzz9jMseovGjpMglXSDmKZsoIwmeR9EaGvLf3OC1HageF(TEr08zzbjM(TKlmKCcKHqgcTD(TrPVJxIi5MwODx20AEfgsobYqidH2gI8cBBeya5BEj6WsMaNkWKNjNLCenJsFEoSK9mcblptEHTnI(sgaqNyyOzomGlU2fdlMeddncg2DxmmWSS4QjlUdaSQS4gLRoeWG4drZCyaxCTZNLfuIi5MwODx20AEgyDYkpJOrWWU7GqWSS4QjlUZVnk9D8Cyj7zecwEMCwYr0mk955Ws2ZieS8CAbSw2u9EcyaboVkUGcdLI3wqz3z36k0dc8aa6etPWpYAp4Tn5XayAVJHcl0IPeHtfyYJXAxm(cJqWYJXipg40yyXKy042lM3yypAbawvwCJYvhcyq8D(rw7bVTj3NLfKdlzcCQatEM8cBBe90fy6wQ1uOcJFiu6BhVeDyj7zecwEMCwYr0mk9daSQS4gLRoeWG4tW8VvikT5UpllihwYe4ubM8SSvo22laWQYIBuU6qadIVQP1qwvwCdPxK4tBfh0rO31JcacaSQS4gLpc9UEeOkURVfIj3bXQTIhayvzXnkFe6D9iGbXhLgJDqywiH2HE)cafayvzXnkFe6D9iGbXNhSrCR1qywidSobl0caSQS4gLpc9UEeWG4JfxHr3bzG1jRCiQBfbawvwCJYhHExpcyq8LctwwaTTheL2qsaGvLf3O8rO31JageFcTdb3uy42bXIj1hayvzXnkFe6D9iGbXhztt1hABiuQvFaGvLf3O8rO31JageFagt0o)FBiYr4266daSQS4gLpc9UEeWG4R4fycGGWSqA466GCKBfiFwwqVpXdqGH7(oaiaGoXWnxYRsmoRW8Emg1QxzpkaGoXukT)34Iymjg6cCmjZDGJbWRqlgUjtsXuAa1CmaLff3TMCnGIb3XaeGJrmI3fKpXa4vOfJV8T7Iy(edMedGxHwmCLaqXXGfANa4f9yaSTsmSysmiCXJ59jEakhtPRr4yaSTsmlBmLc)iVyQ4ckCmlkMkUyBVyGtZbawvwCJYUL8Qa6T)34cFwwqvCbfgkfVTGOheDbwm9Bj7(tpbcjetmVxKFBu674LS7uWSSz)VDxeldNwUS7uWSSzbZ)wHO0M7z40YLFFIhGYUZU1vadiGWDG9BK1O0p)(epabrU3BOkUGA77kxor)gznk9ZOT90hsmI3LK4LCIIPFl5ZpYAp4Tn553gL(UYLRyS2HbCNp)iR9G32KNjVW2grpqskaWQYIBu2TKxfGbXNFJSgL((0wXbbJoe7Q1N4JFtdFqvCbfgkfVTGYUZU1vOh8YLFFIhGYUZU1vadiGWDG9BK1O0p)(epabrU3BOkUGA77kxor)gznk9ZOT90hsmI3Laa6edqfViCFxmGn9Y(ymjgGWTahdsSkhOyWSXWqZiPVVlMe0M7OCaGvLf3OSBjVkadIVu8IW9DqC0l79zzb53iRrPFggDi2vRpHhfmlBgrZiPVVdIsBUJYiXQCqpiGWTba0jMs4whdMngWME9FumMed4ClWXGeRYbkgmBmLqSo37ysqBUJIbtIX8STrsm0f4ysM7ahdGxHwmCtmmL(XWnXONumIr8UGYbawvwCJYUL8Qami(yTgcZcXrV(pYNLfKFJSgL(zy0HyxT(eEjtbZYMPTo3BikT5okJeRYb9GaNBlxgLETgsmI3fuM1Aimleh96)i6brxGt2aRtw5zhgMsFihg9mXAoOhijbmsUPfA3Ljyp4NuaaDIPeU1XGzJbSPx)hfJGJXst1akgU5nNgqXauXlc3XSSXSTvL1)Jb3XynGIrmI3LymjMsgJyeVlOCaGvLf3OSBjVkadIpwRHWSqC0R)J8zzb53iRrPFggDi2vRpHhk9AnKyeVlOmR1qywio61)r0dQKbawvwCJYUL8Qami(O0B7qR7(SSG8BK1O0pdJoe7Q1NWlzkyw2mLEBhADpdNwUCIIPFlz)VXfqeyeT8BJsFhVenW6KvE2HHP0hYHrp)2O03LuaaDIHlJcObBHLvBYJrWXyPPAafd38MtdOyaQ4fH7ymjgGeJyeVlOaaRklUrz3sEvageFfWYQn5(SSG8BK1O0pdJoe7Q1NWdLETgsmI3fuM1Aimleh96)iqajaWQYIBu2TKxfGbXxbSSAtUplli)gznk9ZWOdXUA9jbaba0jgUPvyEpgS)tIr2IhJrT6v2JcaOtmmPVUMoMseovGjpg0f40yyXKykf(rEbawvwCJYoSaIaNkWK7ZYcsm9BjF(rw7bVTjp)2O03Xl5KR4ckmukEBbrpOAkuHXpek9TJxfJ1omG785hzTh82M8m5f22iWaEsLlNCIYw5yBpEjlBXPhCFxUCfxqHHsXBli6bbKKskPaa6eJVWieS8yGt54p1NymnchJq2JIrWXaJEmReJHIXIbL(6A6y8EFIjysmSysmcThJ2qsmLgqngQZIjpglg2TxeTtcaSQS4gLDybyq8LIXAiYryys9(WIjq95xabEaGvLf3OSdladIppJqWY9PcOQ(qIr8UGabUpllOKtum9BjJGPKtyH9E(TrPVRC5etUIXAhgWD2V1lIwgoLxfJ1omG7S)3UlILjVW2gbgq0nPK4vXfuyOu82ck7o7wxHEqGZJCwYr0mk95LCAbSw2u9EcyabE5YKxyBJadizRCajBX5HsVwdjgX7ckZAneMfIJE9Fe9GkjWgyDYkpJOrWWU7GqWSS4QjlUZVnk9DjXl5ep)iR9G32K7kxM8cBBeyajBLdizlEPceEO0R1qIr8UGYSwdHzH4Ox)hrpOscSbwNSYZiAemS7oiemllUAYI78BJsFxs8seHGOGzzVJxYIr8UKLT4qcgYThOjVW2grpD5HsVwdjgX7ckZAneMfIJE9FeyabE5YIr8UKLT4qcgYThOjVW2grp4ajjEjxyi5eidHmeABiYlSTrG8D5YjkBLJT9skaGoXuAKTaH7y46fPhjXGBnGIb3XuaRLnv)yeJ4DbfJjXqxGJP0aQXayAVJHa392EXGHLy2ogGGIjz40yeCm0ngXiExqjfdMetjrXKm3bogXiExqjfayvzXnk7WcWG4Rs2ceUHKxKEK4ZYccLETgsmI3fe9GacpYlSTrGbiaNmk9AnKyeVli6bX9K4vXfuyOu82cIEq0naGoXa28NgdCAmLiCQatEmMedDbogChJP1XigX7ckMKbmT3XOx)B7fJg3EX8gd7rlgRDX0yjguBPiAyjPaaRklUrzhwageFe4ubMCFQaQQpKyeVliqG7ZYcQIlOWqP4Tfe9GOlpYzjhrZO0NxYPfWAzt17jGbe4LltEHTncmGKTYbKSfNhk9AnKyeVlOmR1qywio61)r0dQKaBG1jR8mIgbd7UdcbZYIRMS4o)2O03LeVKt88JS2dEBtURCzYlSTrGbKSvoGKT4Lkq4HsVwdjgX7ckZAneMfIJE9Fe9GkjWgyDYkpJOrWWU7GqWSS4QjlUZVnk9DjXtmI3LSSfhsWqU9an5f22i6PBaqaaDIHrUPfA3ftPxLf3Oaa6edNRhnKyAooXNyWKyyGPeGlf(rEXG7yaNlFngM2sr0WsmLiCQatEaGvLf3OmsUPfA3bIaNkWK7ZYcQIlOWqP4Tfe9GOlVKft)wY96rtqIP54K8BJsFx5YIPFlzemLCclS3ZVnk9D8swm9BjF(rw7bVTjp)2O03XRIXAhgWD(8JS2dEBtEM8cBBeyabKYLtu2khB7Lep)gznk9ZOT90hsmI3LK4jgX7sw2Idjyi3EGM8cBBe9G9aa6eddmLCclS391yk90unGIbtIPepl5iAXa4vOfdfml7DX4lmcblhfayvzXnkJKBAH2DadIppJqWY9PcOQ(qIr8UGabUplliX0VLmcMsoHf2753gL(oEKZsoIMrPppXiExYYwCibd52d0KxyBJOhiba0jggyk5ewyV7RXucP)tiR7X0ysHPJXxyecwokgaVcTyqTLIOHLy8FcAXnkaWQYIBugj30cT7ageFEgHGL7tfqv9HeJ4DbbcCFwwqIPFlzemLCclS3ZVnk9D8iVW2gbgqG7BEPfWAzt17jGbe48eJ4DjlBXHemKBpqtEHTnIEGeaqNyyGPKtyH9Emahddncg2DxmmWSS4QjlU91yk90unGI5grdOykr4ubM8yeAMedGxTogQhd5SKJODxmSysmPw7EXwZbawvwCJYi5MwODhWG4JaNkWK7ZYcsm9BjJGPKtyH9E(TrPVJNbwNSYZiAemS7oiemllUAYI78BJsFhVeDyjtGtfyYZYw5yBVaa6eddmLCclS3JbW8fddncg2DxmmWSS4QjlU91ykXBPPAafdlMedfUHrXuAa1yS2XhMeZ5xE7UlguBPiAyjghmXKf35aaRklUrzKCtl0Udyq8LIXAiYryys9(WIjq95xabEaGvLf3OmsUPfA3bmi(8mcbl3NkGQ6djgX7cce4(SSGet)wYiyk5ewyVNFBu674zG1jR8mIgbd7UdcbZYIRMS4o)2O03XtmI3LSSfhsWqU90tEHTnIxYKxyBJad4LGYLteHGOGzzVlPaa6eddmLCclS3Jb4ykf(rE(AmLI)3XG9FczDpglguBPiAyjgFHriy5XqwpAsmgRCsmLiCQatEmuNftEmLc)iR9G32Kf3bawvwCJYi5MwODhWG4lfJ1qKJWWK69HftG6ZVac8aaRklUrzKCtl0Udyq85zecwUplliX0VLmcMsoHf2753gL(oEIPFl5ZpYAp4Tn553gL(oEvmw7WaUZNFK1EWBBYZKxyBJad48sj3pKx1LbptGtfyY55WsMaNkWKNjVW2grp3bMULAnfQW4hcL(2PeLOua]] )

end