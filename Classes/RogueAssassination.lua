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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 120 end,
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


    spec:RegisterPack( "Assassination", 20190310.0057, [[d00YgbqirkpcOYLivOYMqPgLiXPejTkrQYRauZIuPBbGAxI6xKsnmsfDmKuldq8mPeMgqPRHsQTbuL(Miv04aQcNtkrwhPcEhPcfnpGI7bK9HKCqPe1cLs6HIuPjIscxuKQAJKku1hrjrJeaj1jbqQvcqVeOk6MIuHDsk8tsfkmuaelfLKEkQmvsjxfaj2kPc5Raij7LQ(lOgSKdtzXi1JLQjtLlRAZO4ZOQrJeNwPvtQqPxJsmBsUTuSBf)gXWfXYH65qMoX1bz7KQ(oamEsrNhqA9av18LsTFH9u71YZ5m5EnaIoPUL0zlOwNzDQtwdEzn41Zjan5EUeRZIXFp3yn3Z1YiKHq7yYsgpxIbufXCET8CiceUFphfrsq6G2AZVcfi6CN0OnABGuMSKPJngrB0201MwrO1MMXay31RDcMWSQJ0gGGpRARdPnaHvHzvcp0HBzeYqODmzjtgTnDphn0Qea6Xt75CMCVgarNu3s6SfuRZSo1jRbVSUfEodsOqWEoUTjD9CuwN7JN2Z5oQ75axuTmczi0oMSKjkwLWd9aqWfffrsq6G2AZVcfi6CN0OnABGuMSKPJngrB0201oaeCrLomCNsuuRtDJci6K6wkkaokDQtDaSTuayai4IkDPyd)r6qai4IcGJQLDU7Ic8C7SeLqIYDgdsjrzDzjtuQfj5aqWffahfR(gI(hLyy(lWltoaeCrbWr1Yo3Drbqb9OaOL3GIkfcKGw3JIWefsUPekPM9CQfjiVwEoKCtjuUZRLxdQ9A55(y0Q78T6564voEnpxN0qtGti7iOOOcuuGnk2rLsuIP(i5z5PiiXuSCC(JrRUlQ2TJsm1hjJGOLJzG4F(JrRUlk2rLsuIP(i5RjYgEODm55pgT6UOyhvNquocaM81ezdp0oM8m(n2oOOadOOasuTBhvArjBNLD4Jk1OyhLEdVgT6z0o8QdlgM)suPgf7OedZFjlBZHfcSBFuaCu43y7GIIQOaVEoRllz8CyOebcFV41aiET8CFmA1D(w9CwxwY454nmMi3Z1XRC8AEoXuFKmcIwoMbI)5pgT6UOyhf(m4JOy0Qhf7OedZFjlBZHfcSBFuaCu43y7GIIQOaINRd0U6WIH5VG8AqTx8A0cVwEUpgT6oFREoRllz8C8ggtK7564voEnpNyQpsgbrlhZaX)8hJwDxuSJc)gBhuuGbuuuRZOyhvsdKs2e1ECuGbuuuhf7OedZFjlBZHfcSBFuaCu43y7GIIQOaINRd0U6WIH5VG8AqTx8AawVwEUpgT6oFREUoELJxZZjM6JKrq0YXmq8p)XOv3ff7OmW)4vEgrbtGC3bJGyyiDtwYK)y0Q7IIDuPfLJizmuIaHFw2ol7W75SUSKXZHHsei89Ixdw71YZ9XOv35B1ZzDzjJNJ3WyICpxhVYXR55et9rYiiA5ygi(N)y0Q7IIDug4F8kpJOGjqU7GrqmmKUjlzYFmA1DrXokXW8xYY2CyHa72hfvrHFJTdkk2r1jn0e4eYock7oZ2xjkQIIApxhOD1HfdZFb51GAV41a861YZ9XOv35B1ZXqWWZ1u8AqTNZ6YsgpxcHOGXhrGW97fVgPtVwEUpgT6oFREUoELJxZZjM6JKrq0YXmq8p)XOv3ff7Oet9rYxtKn8q7yYZFmA1DrXoQoHOCeam5RjYgEODm5z8BSDqrbMOOok2rLGVEy(UltDgdLiq4hf7OCejJHsei8Z43y7GIIQOyDuahfyJk9IQNa3yAcJs(48CwxwY454nmMi3lEXZ5oJbPeVwEnO2RLN7JrRUZ3QNRJx5418CPffsUPek3LnLYZzDzjJNJLTZIx8AaeVwEoRllz8Ci5MsO45(y0Q78T6fVgTWRLN7JrRUZ3QNtVPGUN7ZX8anJp)NOaoQeYIiZDW0QFhkQ0lQ0zu64IkLOasuPxuOKRuWumK8Os1ZzDzjJNtVHxJwDpNEddpwZ9CFoMhOW4Z)bUtAO35oV41aSET8CFmA1D(w9C6nf09COKRuWIH5VGYm2atyGzzw9hffyIciEoRllz8C6n8A0Q750By4XAUNdTdV6WIH5V4fVgS2RLN7JrRUZ3QNRJx5418Ci5MsOCxgt4HUNZ6Ysgpx3ukyRllzGvls8CQfjWJ1CphsUPek35fVgGxVwEUpgT6oFREoRllz8CDtPGTUSKbwTiXZPwKapwZ9CDhYlEnsNET8CFmA1D(w9CwxwY456MsbBDzjdSArINtTibESM75CeXlEnap8A55(y0Q78T65SUSKXZ1nLc26Ysgy1IepNArc8yn3Z5w87Ix8A0sET8CFmA1D(w9CD8khVMN7ZX8an7oZ2xjkQaff1SokGJsVHxJw98NJ5bkm(8FG7Kg6DUZZzDzjJNZWDBoSqW4pIx8AqTo9A55SUSKXZz4UnhobsHUN7JrRUZ3Qx8Aqn1ET8CwxwY45ulpfbbRJfYX38r8CFmA1D(w9Ix8Cj43jn0M41YRb1ET8CFmA1D(w9IxdG41YZ9XOv35B1lEnAHxlp3hJwDNVvV41aSET8CFmA1D(w9Ixdw71YZzDzjJNZssuafoHSiY45(y0Q78T6fVgGxVwEoRllz8Ci5MsO45(y0Q78T6fVgPtVwEoRllz8CjezjJN7JrRUZ3Qx8AaE41YZ9XOv35B1ZzDzjJNRXWSChmdbd7Uju8CD8khVMNdBRd(6)izZ5q5DIIQOaRo9Cj43jn0MaJENmoKNJ1EXlEo3IFx8A51GAVwEUpgT6oFREUoELJxZZ1jn0e4eYockkQaffyJc4Oet9rYU)KJHrc2eJ)n5pgT6UOyhvkr5onedtw)h3fXYqjr1UDuUtdXWKfIMBhMwzUNHsIQD7O(CmpqZUZS9vIcmGIciSokGJsVHxJw98NJ5bkm(8FG7Kg6DUlQ2TJkTO0B41OvpJ2HxDyXW8xIk1OyhvkrLwuIP(i5RjYgEODm55pgT6UOA3oQoHOCeam5RjYgEODm5z8BSDqrrvuajQu9CwxwY45(O)dPXlEnaIxlp3hJwDNVvpNEtbDpxN0qtGti7iOS7mBFLOOkkQJQD7O(CmpqZUZS9vIcmGIciSokGJsVHxJw98NJ5bkm(8FG7Kg6DUlQ2TJkTO0B41OvpJ2HxDyXW8x8CwxwY450B41Ov3ZP3WWJ1Cphe6WmRsDSx8A0cVwEUpgT6oFREUoELJxZZP3WRrREgcDyMvPook2rrdXWKrumCYN7GPvM7OmsSolrrfOOasl55SUSKXZLqwezUdMLzzUx8AawVwEUpgT6oFREUoELJxZZP3WRrREgcDyMvPook2rLsu0qmmzkRZ9bMwzUJYiX6SefvGII6wkQ2TJcLCLcwmm)fuMXgycdmlZQ)OOOcuuGnkGJkLOmW)4vE2rGOvh2rqpJTHLOOkkGevQrbCui5MsOCxgt4HEuP65SUSKXZXydmHbMLz1FKx8AWAVwEUpgT6oFREUoELJxZZP3WRrREgcDyMvPook2rHsUsblgM)ckZydmHbMLz1FuuubkQw45SUSKXZXydmHbMLz1FKx8AaE9A55(y0Q78T6564voEnpNEdVgT6zi0HzwL64OyhvkrrdXWKPv74qR7zOKOA3oQ0Ism1hjR)dPbgdHOK)y0Q7IIDuPfLb(hVYZoceT6Woc65pgT6UOs1ZzDzjJNJwTJdTU7fVgPtVwEUpgT6oFREUoELJxZZP3WRrREgcDyMvPook2rHsUsblgM)ckZydmHbMLz1FuuGIciEoRllz8CnqYQm5EXRb4Hxlp3hJwDNVvpxhVYXR550B41OvpdHomZQuh75SUSKXZ1ajRYK7fV456oKxlVgu71YZ9XOv35B1Z1XRC8AEoAigMmTIqCkiKKX36suTBhL70qmmz9FCxeldL45SUSKXZLqKLmEXRbq8A55(y0Q78T65SUSKXZXBQ3nL6yemnHmEUoELJxZZLwui5MsOCxgt4HEuSJQtikhbatw)h3fXY43y7GIIQOalR9CJ1CphVPE3uQJrW0eY4fVgTWRLN7JrRUZ3QNRJx5418CPffsUPek3LXeEOhf7O6eIYraWK1)XDrSm(n2oOOOkkWYApN1LLmEoi0Hx5niV41aSET8CFmA1D(w9CD8khVMNZDAigMS(pUlILHs8CwxwY45OveIdMbcduV41G1ET8CFmA1D(w9CD8khVMNZDAigMS(pUlILHs8CwxwY45OpgDml7W7fVgGxVwEUpgT6oFREUoELJxZZ5onedtw)h3fXYqjEoRllz8Cml(0kcX5fVgPtVwEUpgT6oFREUoELJxZZ5onedtw)h3fXYqjEoRllz8C20psWMcUBkLx8AaE41YZ9XOv35B1Z1XRC8AEoSTo4R)JKnNdLHsIIDuPeLyy(lzzBoSqGD7Jcmr1jn0e4eYock7oZ2xjQ0lkQZSoQ2TJQtAOjWjKDeu2DMTVsuubkQEcCJPjmk5JlQu9CwxwY45Amml3bZqWWUBcfV41OL8A55(y0Q78T6564voEnph2wh81)rYMZHY7efvr1cDgfahf2wh81)rYMZHYoiSjlzIIDuDsdnboHSJGYUZS9vIIkqr1tGBmnHrjFCEoRllz8CngML7Gziyy3nHIx8AqTo9A55(y0Q78T6564voEnpxArHKBkHYDzmHh6rXokhrYyOebc)SSDw2Hpk2rLsuPfLyQpsgbrlhZaX)8hJwDxuTBhvArzG)XR8mIcMa5UdgbXWq6MSKj)XOv3fv72r5isM3WyI8CsdKs2e1ECuuff1rLAuSJkLOslkXuFK8S8ueKykwoo)XOv3fv72rLwuIP(i5RjYgEODm55pgT6UOA3oQoHOCeam5RjYgEODm5z8BSDqrbMOyDuaCuajQ0lkXuFKS7p5yyKGnX4Ft(JrRUlQu9CwxwY450)XDrmV41GAQ9A55(y0Q78T6564voEnpNyQpsgbrlhZaX)8hJwDxuSJkTOCejZBymrEw2ol7Whf7O0B41OvpJ2HxDyXW8x8CwxwY450BZIO4fVgudeVwEUpgT6oFREUoELJxZZjM6JKVMiB4H2XKN)y0Q7IIDuPeLyQpsEwEkcsmflhN)y0Q7IQD7Oet9rYiiA5ygi(N)y0Q7IIDu6n8A0QNr7WRoSyy(lrLAuSJQtAOjWjKDeuuubkQEcCJPjmk5Jlk2r1jeLJaGjFnr2WdTJjpJFJTdkkWef1rXoQuIkTOet9rYiiA5ygi(N)y0Q7IQD7Oslkd8pELNruWei3DWiiggs3KLm5pgT6UOA3okhrY8ggtKNtAGuYMO2JJcmGII6Os1ZzDzjJNtVnlIIx8AqDl8A55(y0Q78T6564voEnpNyQpsEwEkcsmflhN)y0Q7IIDuPfLyQps(AISHhAhtE(JrRUlk2r1jn0e4eYockkQafvpbUX0egL8Xff7OCNgIHjR)J7IyzOepN1LLmEo92SikEXRb1G1RLN7JrRUZ3QNRJx5418CIP(izeeTCmde)ZFmA1DrXoQuIkTOet9rYxtKn8q7yYZFmA1Dr1UDuPfLEdVgT6z0o8QdlgM)suPgf7OslkKCtjuUlJj8qpk2r1jeLJaGjZBymrEgkjk2r5isM3WyI8m(m4JOy0Qhf7OsjkuYvkyXW8xqzgBGjmWSmR(JIcmGIQfrXoQoPHMaNq2rqz3z2(krrfOOOokGJcLCLcwmm)fuMXgycdmlZQ)OOA3okuYvkyXW8xqzgBGjmWSmR(JIIkqrb2OyhvN0qtGti7iOS7mBFLOOcuuGnQu9CwxwY450BZIO4fVguZAVwEUpgT6oFREUoELJxZZjM6JKBmKCmSHqgcTt(JrRUlk2rLwui5MsOCx2uQOyhvJHKJHneYqODGXVX2bffyafLoJIDuPfLJizmuIaHFgFg8rumA1JIDuoIK5nmMipJFJTdkkQIQfEoRllz8C6Tzru8IxdQbVET8CFmA1D(w9CD8khVMNlTOqYnLq5USPurXokd8pELNruWei3DWiiggs3KLm5pgT6UOyhLJizEdJjYZ4ZGpIIrREuSJYrKmVHXe55KgiLSjQ94OadOOOok2r1jn0e4eYock7oZ2xjkQaff1EoRllz8CikMJaGMRCEXRb1PtVwEUpgT6oFREUoELJxZZ5isgdLiq4NXVX2bffvrb2OaokWgv6fvpbUX0egL8Xff7OslkhrY8ggtKNXNbFefJwDpN1LLmEURjYgEODm5EXRb1GhET8CFmA1D(w9CD8khVMNZrKmgkrGWplBNLD49CwxwY45eIMBhMwzU7fV45CeXRLxdQ9A55(y0Q78T6564voEnpNyQps(AISHhAhtE(JrRUlk2rLsuPevN0qtGti7iOOOcuu9e4gttyuYhxuSJQtikhbat(AISHhAhtEg)gBhuuGjkQJk1OA3oQuIkTOKTZYo8rXoQuIs2MhfvrrToJQD7O6KgAcCczhbffvGIcirLAuPgvQEoRllz8CyOebcFV41aiET8CFmA1D(w9Cmem8CnfVgu75SUSKXZLqiky8reiC)EXRrl8A55(y0Q78T65SUSKXZXBymrUNRJx5418CPevArjM6JKrq0YXmq8p)XOv3fv72rLwuPevNquocaMSEBweLmusuSJQtikhbatw)h3fXY43y7GIcmGIcSrLAuPgf7O6KgAcCczhbLDNz7RefvGII6Oyhf(m4JOy0Qhf7OsjQKgiLSjQ94OadOOOoQ2TJc)gBhuuGbuuY2zbw2Mhf7OqjxPGfdZFbLzSbMWaZYS6pkkQafvlIc4OmW)4vEgrbtGC3bJGyyiDtwYK)y0Q7Ik1OyhvkrLwuxtKn8q7yYDr1UDu43y7GIcmGIs2olWY28OsVOasuSJcLCLcwmm)fuMXgycdmlZQ)OOOcuuTikGJYa)Jx5zefmbYDhmcIHH0nzjt(JrRUlQuJIDuPffcbtdXWCxuSJkLOedZFjlBZHfcSBFuaCu43y7GIIQOaBuSJcLCLcwmm)fuMXgycdmlZQ)OOadOOOoQ2TJsmm)LSSnhwiWU9rbWrHFJTdkkQIIAGevQrXoQuIQXqYXWgczi0oW43y7GIcuu6mQ2TJkTOKTZYo8rLQNRd0U6WIH5VG8AqTx8AawVwEUpgT6oFREUoELJxZZHsUsblgM)ckkQaffqIIDu43y7GIcmrbKOaoQuIcLCLcwmm)fuuubkkwhvQrXoQoPHMaNq2rqrrfOOaRNZ6YsgpxhVniYalVj5iXlEnyTxlp3hJwDNVvpN1LLmEomuIaHVNRJx5418CDsdnboHSJGIIkqrb2Oyhf(m4JOy0Qhf7OsjQKgiLSjQ94OadOOOoQ2TJc)gBhuuGbuuY2zbw2Mhf7OqjxPGfdZFbLzSbMWaZYS6pkkQafvlIc4OmW)4vEgrbtGC3bJGyyiDtwYK)y0Q7Ik1OyhvkrLwuxtKn8q7yYDr1UDu43y7GIcmGIs2olWY28OsVOasuSJcLCLcwmm)fuMXgycdmlZQ)OOOcuuTikGJYa)Jx5zefmbYDhmcIHH0nzjt(JrRUlQuJIDuIH5VKLT5Wcb2Tpkaok8BSDqrrvuG1Z1bAxDyXW8xqEnO2lEXlEo9hJwY41ai6KAWdQbc16mdKwawG45aGHND4rEoa6MecwUlkWBuwxwYeLArckha65sWeMvDph4IQLridH2XKLmrXQeEOhacUOOiscsh0wB(vOarN7KgTrBdKYKLmDSXiAJ2MU2bGGlQ0HH7uIIADQBuarNu3srbWrPtDQdGTLcadabxuPlfB4pshcabxuaCuTSZDxuGNBNLOesuUZyqkjkRllzIsTijhacUOa4Oy13q0)OedZFbEzYbGGlkaoQw25UlkakOhfaT8guuPqGe06EueMOqYnLqj1Cayai4Ik918Di5UOOpdb)O6KgAtII(87GYr1Y9(teuudzaykgUHbsfL1LLmOOiJcO5aqRllzq5e87KgAtaXOmelbGwxwYGYj43jn0MamiTni(MpIjlzcaTUSKbLtWVtAOnbyqAZqiUaqWff3yjikejkSTUOOHyyUlkKyckk6ZqWpQoPH2KOOp)oOOSXfvc(aCcrKD4JArr5iZZbGwxwYGYj43jn0MamiTrJLGOqeyKycka06Ysguob)oPH2eGbPTLKOakCczrKja06Ysguob)oPH2eGbPnsUPekbGwxwYGYj43jn0MamiTtiYsMaqRllzq5e87KgAtagK2ngML7Gziyy3nHIUj43jn0MaJENmoeiwR7YacBRd(6)izZ5q5DOcS6mamaeCrL(A(oKCxux)XankzBEucLhL1fcoQffLP3wLrREoaeCrXQhj3ucLOwMOsii0sREuPmKO0dPMJnA1J6ZB2JIANO6KgAtsna06Ysgeiw2ol6UmGsdj3ucL7YMsfaADzjdcyqAJKBkHsaO1LLmiGbPTEdVgT66owZb95yEGcJp)h4oPHEN70vVPGoOphZd0m(8FaoHSiYChmT63HsV0PoUuas6HsUsbtXqYtna06YsgeWG0wVHxJwDDhR5Gq7WRoSyy(l6Q3uqhek5kfSyy(lOmJnWegywMv)rGbibGwxwYGagK2DtPGTUSKbwTir3XAoiKCtjuUt3LbesUPek3LXeEOhaADzjdcyqA3nLc26Ysgy1IeDhR5G6ouaO1LLmiGbPD3ukyRllzGvls0DSMdYrKaqRllzqads7UPuWwxwYaRwKO7ynhKBXVlbGwxwYGagK2gUBZHfcg)r0Dza95yEGMDNz7RqfiQznW6n8A0QN)CmpqHXN)dCN0qVZDbGwxwYGagK2gUBZHtGuOhaADzjdcyqARwEkccwhlKJV5JeagacUOsxcr5iayqbGwxwYGYDhcucrwYO7YaIgIHjtRieNccjz8TU0UT70qmmz9FCxeldLeaADzjdk3DiGbPne6WR8gDhR5G4n17MsDmcMMqgDxgqPHKBkHYDzmHh6S7eIYraWK1)XDrSm(n2oiQalRdaTUSKbL7oeWG0gcD4vEds3LbuAi5MsOCxgt4Ho7oHOCeamz9FCxelJFJTdIkWY6aqRllzq5UdbmiTPveIdMbcduDxgqUtdXWK1)XDrSmusaO1LLmOC3HagK20hJoMLD41Dza5onedtw)h3fXYqjbGwxwYGYDhcyqAZS4tRieNUldi3PHyyY6)4Uiwgkja06YsguU7qadsBB6hjytb3nLs3LbK70qmmz9FCxeldLeacUOaOzIYCouug(rbLOBuOztEucLhfzEuayfkrPia4ijkT0IvKJcGc6rbakFIYb0D4JIXqYXrjuSjQ0fGeL7mBFLOi4OaWkuiqsu2a0Osxasoa06YsguU7qads7gdZYDWmemS7Mqr3Lbe2wh81)rYMZHYqjStrmm)LSSnhwiWU9GPtAOjWjKDeu2DMTVs6rDM1TB3jn0e4eYock7oZ2xHkq9e4gttyuYhxQbGGlkaAMOgsuMZHIcaRsfLBFuayfk7eLq5rnxtjQwOtKUrbHEuPdgwruKjkAccffawHcbsIYgGgv6cqYbGwxwYGYDhcyqA3yywUdMHGHD3ek6UmGW26GV(ps2CouEhQAHobySTo4R)JKnNdLDqytwYWUtAOjWjKDeu2DMTVcvG6jWnMMWOKpUaqWfLo6J7IyrrGe06Eui5MsOefawHsuSkuIaHFuqj5OaOAfkrXbrlhZaX)Oet9rIYgxuCuWei3DrXbXWq6MSKjQecaooktbadOOOGqpkaScLOOHyyUlkwPHXe55OaOAfkrPXYtrqIPy54OSXfv6RjYgEODm5rbHEuqjrjKOynkQuAbkkaScLOyfCPgf9zi4hLoYMfrjQoPHMKdaTUSKbL7oeWG0w)h3fX0DzaLgsUPek3LXeEOZ2rKmgkrGWplBNLD4zNsAIP(izeeTCmde)ZFmA1DTBNMb(hVYZikycK7oyeeddPBYsM8hJwDx72oIK5nmMipN0aPKnrThtf1PYoL0et9rYZYtrqIPy548hJwDx72PjM6JKVMiB4H2XKN)y0Q7A3Utikhbat(AISHhAhtEg)gBheyynadK0tm1hj7(toggjytm(3K)y0Q7snaeCrL(AkylkoiA5ygi(hLoYMfrjQozCRSKrhIcGc6rbakFIIvAymrEuomjj5UOituC7WREuAzy(lbGwxwYGYDhcyqAR3Mfrr3LbKyQpsgbrlhZaX)8hJwDh70CejZBymrEw2ol7WZwVHxJw9mAhE1HfdZFjaeCrPJSzruIcaRqjQ0xteFuahvkAS8ueKykwow3Oi4O4GOLJzG4FuKrb0OituuRvQ6quPdtZTbQjQ0fGeLnUOsFnr8rHV5aAumeCuZ1uIIvMUSIaqRllzq5UdbmiT1BZIOO7Yasm1hjFnr2WdTJjp)XOv3XofXuFK8S8ueKykwoo)XOv31UTyQpsgbrlhZaX)8hJwDhB9gEnA1ZOD4vhwmm)Luz3jn0e4eYocIkq9e4gttyuYhh7oHOCeam5RjYgEODm5z8BSDqGHA2PKMyQpsgbrlhZaX)8hJwDx72PzG)XR8mIcMa5UdgbXWq6MSKj)XOv31UTJizEdJjYZjnqkztu7XGbe1PgacUO0r2SikrbGvOeLglpfbjMILJJc4O0Gev6RjIxhIkDyAUnqnrLUaKOSXfLo6J7IyrbLeaADzjdk3DiGbPTEBwefDxgqIP(i5z5PiiXuSCC(JrRUJDAIP(i5RjYgEODm55pgT6o2DsdnboHSJGOcupbUX0egL8XX2DAigMS(pUlILHscabxu6iBweLOaWkuIIdIwoMbI)rbCuPObjQ0xteFueCuarlGtvhIsdsui5MsOOncIwoMbI)6gfR0WyI8Oy1ZGpIIrRUUr9HaXtjkuI1FumeCu70jn7WhfR0WyI8OsxasaO1LLmOC3HagK26Tzru0DzajM6JKrq0YXmq8p)XOv3XoL0et9rYxtKn8q7yYZFmA1DTBNMEdVgT6z0o8QdlgM)sQStdj3ucL7Yycp0z3jeLJaGjZBymrEgkHTJizEdJjYZ4ZGpIIrRo7uqjxPGfdZFbLzSbMWaZYS6pcmGAb7oPHMaNq2rqz3z2(kubIAGrjxPGfdZFbLzSbMWaZYS6pQDBuYvkyXW8xqzgBGjmWSmR(JOceyz3jn0e4eYock7oZ2xHkqGn1aqWfLoYMfrjkaScLOshgsooQwgHm0o6quAqIcj3ucLOSXf1qIY6YQ)rLoA5OOHyy0nkwfkrGWpQHirTtu4ZGpIsuyB4FaO1LLmOC3HagK26Tzru0DzajM6JKBmKCmSHqgcTt(JrRUJDAi5MsOCx2uk2ngsog2qidH2bg)gBheyaPt2P5isgdLiq4NXNbFefJwD2oIK5nmMipJFJTdIQweacUO4OyocaAUYffdbhfhfmbYDxuCqmmKUjlzcaTUSKbL7oeWG0grXCea0CLt3LbuAi5MsOCx2uk2g4F8kpJOGjqU7GrqmmKUjlzYFmA1DSDejZBymrEgFg8rumA1z7isM3WyI8CsdKs2e1Emyarn7oPHMaNq2rqz3z2(kubI6aqWfv6RjYgEODm5rbakFIIMiuIIvHsei8JYgxuSsdJjYJYWpkOKOyi4OuKHpQpeiEkbGwxwYGYDhcyqAFnr2WdTJjx3LbKJizmuIaHFg)gBhevGfyWME9e4gttyuYhh70CejZBymrEgFg8rumA1daTUSKbL7oeWG0wiAUDyAL5UUldihrYyOebc)SSDw2HpamaeCrXkw87suoRX4Fug9QwzpkaeCrL(J(pKMOmjkWcCuPWAGJcaRqjkwbxQrLUaKCua0nn3TMCfqJImrbeGJsmm)fKUrbGvOeLo6J7Iy6gfbhfawHsuA1QoMrrekhdGf9OaGTsumeCuisZJ6ZX8anhvlRqKOaGTsultuPVMi(O6KgAsulkQoPzh(OGsYbGwxwYGYUf)Ua6J(pKgDxgqDsdnboHSJGOceybwm1hj7(toggjytm(3K)y0Q7yNI70qmmz9FCxeldL0UT70qmmzHO52HPvM7zOK2T)CmpqZUZS9vadiGWAG1B41Ovp)5yEGcJp)h4oPHEN7A3on9gEnA1ZOD4vhwmm)LuzNsAIP(i5RjYgEODm55pgT6U2T7eIYraWKVMiB4H2XKNXVX2brfqsna06Ysgu2T43fGbPTEdVgT66owZbbHomZQuhRREtbDqDsdnboHSJGYUZS9vOI62T)CmpqZUZS9vadiGWAG1B41Ovp)5yEGcJp)h4oPHEN7A3on9gEnA1ZOD4vhwmm)LaqWffaHSiYCxuGNZY8OmjkG0sahfsSolOOimrXrXWjFUlQwvM7OCaO1LLmOSBXVlads7eYIiZDWSmlZ1DzaP3WRrREgcDyMvPoMnnedtgrXWjFUdMwzUJYiX6SqfiG0sbGGlkD82efHjkWZz1FuuMef1TeWrHeRZckkctuauVo3NOAvzUJIIGJY4TDqsuGf4OsH1ahfawHsuScceT6rXkiONAuIH5VGYbGwxwYGYUf)UamiTzSbMWaZYS6ps3LbKEdVgT6zi0HzwL6y2PqdXWKPSo3hyAL5okJeRZcvGOULA3gLCLcwmm)fuMXgycdmlZQ)iQabwGtXa)Jx5zhbIwDyhb9m2gwOciPcmsUPek3LXeEONAai4IshVnrryIc8Cw9hfLqIYssuankwXnNcOrbqilImrTmrTJ1Lv)JImrzdqJsmm)LOmjQweLyy(lOCaO1LLmOSBXVladsBgBGjmWSmR(J0DzaP3WRrREgcDyMvPoMnk5kfSyy(lOmJnWegywMv)rubQfbGwxwYGYUf)UamiTPv74qR76UmG0B41OvpdHomZQuhZofAigMmTAhhADpdL0UDAIP(iz9FinWyieL8hJwDh70mW)4vE2rGOvh2rqp)XOv3LAai4IslJgGthqYQm5rjKOSKefqJIvCZPaAuaeYIituMefqIsmm)fuaO1LLmOSBXVlads7gizvMCDxgq6n8A0QNHqhMzvQJzJsUsblgM)ckZydmHbMLz1FeiGeaADzjdk7w87cWG0UbswLjx3LbKEdVgT6zi0HzwL64aWaqWffRWAm(hfr)XrjBZJYOx1k7rbGGlkUK3xtffRcLiq4hf6cusumeCuPVMi(aqRllzqzhraHHsei81DzajM6JKVMiB4H2XKN)y0Q7yNskDsdnboHSJGOcupbUX0egL8XXUtikhbat(AISHhAhtEg)gBheyOo12Ttjnz7SSdp7uKT5urToB3UtAOjWjKDeevGasQPMAai4IIvAymrEuqjS8NOBuMcrIsW7rrjKOGqpQvIYqrzrHsEFnvu8Fo2ecokgcokHYJszijQ0fGef9zi4hLffZolIYXbGwxwYGYoIamiTtiefm(iceUFDziy45AkGOoa06Ysgu2reGbPnVHXe562bAxDyXW8xqGOw3LbukPjM6JKrq0YXmq8p)XOv31UDAP0jeLJaGjR3MfrjdLWUtikhbatw)h3fXY43y7GadiWMAQS7KgAcCczhbLDNz7RqfiQzJpd(ikgT6StjPbsjBIApgmGOUDB8BSDqGbKSDwGLT5SrjxPGfdZFbLzSbMWaZYS6pIkqTayd8pELNruWei3DWiiggs3KLm5pgT6UuzNsAxtKn8q7yYDTBJFJTdcmGKTZcSSnp9acBuYvkyXW8xqzgBGjmWSmR(JOcula2a)Jx5zefmbYDhmcIHH0nzjt(JrRUlv2PHqW0qmm3XofXW8xYY2CyHa72dW43y7GOcSSrjxPGfdZFbLzSbMWaZYS6pcmGOUDBXW8xYY2CyHa72dW43y7GOIAGKk7uAmKCmSHqgcTdm(n2oiq6SD70KTZYo8PgacUOsx82GituA9MKJKOiJcOrrMOAGuYMOEuIH5VGIYKOalWrLUaKOaaLprHHMzh(Oiqsu7efqqrLcusucjkWgLyy(lOuJIGJQfOOsH1ahLyy(lOudaTUSKbLDebyqA3XBdImWYBsos0DzaHsUsblgM)cIkqaHn(n2oiWaeGtbLCLcwmm)fevGyDQS7KgAcCczhbrfiWgacUOap)tIckjkwfkrGWpktIcSahfzIYuQOedZFbfvkaGYNOuR(D4Jsrg(O(qG4PeLnUOgIefASeefIKAaO1LLmOSJiadsBmuIaHVUDG2vhwmm)feiQ1Dza1jn0e4eYocIkqGLn(m4JOy0QZoLKgiLSjQ9yWaI62TXVX2bbgqY2zbw2MZgLCLcwmm)fuMXgycdmlZQ)iQa1cGnW)4vEgrbtGC3bJGyyiDtwYK)y0Q7sLDkPDnr2WdTJj31Un(n2oiWas2olWY280diSrjxPGfdZFbLzSbMWaZYS6pIkqTayd8pELNruWei3DWiiggs3KLm5pgT6UuzlgM)sw2Mdley3Eag)gBhevGnamaeCrXj3ucL7IQL7Ysguai4IsJLNcsmflhRBueCuCq0cWPVMi(OituuRLoef3yjikejkwfkrGWpa06Ysgugj3ucL7aHHsei81Dza1jn0e4eYocIkqGLDkIP(i5z5PiiXuSCC(JrRURDBXuFKmcIwoMbI)5pgT6o2PiM6JKVMiB4H2XKN)y0Q7y3jeLJaGjFnr2WdTJjpJFJTdcmGas72PjBNLD4tLTEdVgT6z0o8QdlgM)sQSfdZFjlBZHfcSBpaJFJTdIkWBai4IIdIwoMbI)6quTCsIcOrrWrXQNbFeLOaWkuIIgIH5UOyLggtKJcaTUSKbLrYnLq5oGbPnVHXe562bAxDyXW8xqGOw3LbKyQpsgbrlhZaX)8hJwDhB8zWhrXOvNTyy(lzzBoSqGD7by8BSDqubKaqWffheTCmde)1HO0Xq)X419OgcUXurXknmMihffawHsuOXsquisu6pgTKbfaADzjdkJKBkHYDadsBEdJjY1Td0U6WIH5VGarTUldiXuFKmcIwoMbI)5pgT6o243y7GadiQ1j7KgiLSjQ9yWaIA2IH5VKLT5Wcb2ThGXVX2brfqcabxuCq0YXmq8pkGJIJcMa5Ulkoiggs3KLm6quTCsIcOrDdRaAuSkuIaHFucftIcaRsff9JcFg8ruUlkgcoQeBCVz75aqRllzqzKCtjuUdyqAJHsei81DzajM6JKrq0YXmq8p)XOv3X2a)Jx5zefmbYDhmcIHH0nzjt(JrRUJDAoIKXqjce(zz7SSdFai4IIdIwoMbI)rbaTJIJcMa5Ulkoiggs3KLm6quS6TKefqJIHGJIMmqOOsxasu24I6AkFC3ffASeefIeLdcBYsMaqRllzqzKCtjuUdyqAZBymrUUDG2vhwmm)feiQ1DzajM6JKrq0YXmq8p)XOv3X2a)Jx5zefmbYDhmcIHH0nzjt(JrRUJTyy(lzzBoSqGD7Pc)gBhe7oPHMaNq2rqz3z2(kurDai4IIdIwoMbI)rbCuPVMiEDiQ0x)NOi6pgVUhLffASeefIefR0WyI8OWlpfjkJrookwfkrGWpk6ZqWpQ0xtKn8q7yYsMaqRllzqzKCtjuUdyqANqiky8reiC)6YqWWZ1uarDaO1LLmOmsUPek3bmiT5nmMix3LbKyQpsgbrlhZaX)8hJwDhBXuFK81ezdp0oM88hJwDh7oHOCeam5RjYgEODm5z8BSDqGHA2j4RhMV7YuNXqjce(SDejJHsei8Z43y7GOI1ad20RNa3yAcJs(48COK39Aaew3sEXlEpa]] )

end