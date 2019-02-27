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
                exsanguinated = function () return debuff.crimson_tempest.up and crimson_tempests[ target.unit ] end,
                tick_time = function () return debuff.crimson_tempest.exsanguinated and haste or ( 2 * haste ) end,
                last_tick = function () return ltCT[ target.unit ] or debuff.crimson_tempest.applied end,
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
                exsanguinated = function () return debuff.garrote.up and garrotes[ target.unit ] end,
                tick_time = function () return debuff.garrote.exsanguinated and haste or ( 2 * haste ) end,
                last_tick = function () return ltG[ target.unit ] or debuff.garrote.applied end,
                ss_buffed = function () return debuff.garrote.up and ssG[ target.unit ] end,
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
                exsanguinated = function () return debuff.internal_bleeding.up and internal_bleedings[ target.unit ] end,
                tick_time = function () return debuff.internal_bleeding.exsanguinated and ( 0.5 * haste ) or haste end,
                last_tick = function () return ltIB[ target.unit ] or debuff.internal_bleeding.applied end,
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
                exsanguinated = function () return debuff.rupture.up and ruptures[ target.unit ] end,
                tick_time = function () return debuff.rupture.exsanguinated and haste or ( 2 * haste ) end,
                last_tick = function () return ltR[ target.unit ] or debuff.rupture.applied end,
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
            recheck = function () return debuff.crimson_tempest.remains - ( 2 + ( spell_targets.crimson_tempest > 4 and 1 or 0 ) ) end,
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
            recheck = function () return energy[ "time_to_" .. ( energy.max - ( 25 + ( variable.energy_regen_combined or 0 ) ) ) ], energy[ "time_to_" .. ( energy.max - 25 ) ] end,
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

            recheck = function () return remains - ( duration * 0.3 ), remains - tick_time, remains - tick_time * 2, remains - 10 end,
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

            usable = function () return boss end,
            recheck = function () return master_assassin_remains, cooldown.exsanguinate.remains - 1, cooldown.exsanguinate.remains, debuff.garrote.remains - ( debuff.garrote.duration * 0.3 ) end,
            handler = function ()
                applyBuff( "vanish" )
                applyBuff( "stealth" )
            end,
        },


        vendetta = {
            id = 79140,
            cast = 0,
            cooldown = 120,
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


    spec:RegisterPack( "Assassination", 20181210.2342, [[d80hjbqirupcjXLeHs1MqP(KiusJIkXPOsAvsPIxbsnlrKBba2LO(fvWWaj1Xaulte8maHPHK01KsvBtek(Miu14ajPZHsIwhkP8ousLY8aKUhi2hsQdkcPfcGEiaKjcsIlkLkTrrOeFeLegjkPsCsrOYkbOxcav3eLuXoPc9tusLQHkcXsbe9uuzQurUkauSvusvFfakTxQ6Vi1GLCyklgupwQMmPUSQnJIpJQgnsCALwTiukVgLy2KCBPy3k(nudxKookPsA5iEoKPtCDG2ovQVlLY4PI68GeRhLKMVuY(f2dS3jpN2K7DmbOgyOkWjamuNtaiOAcufi8CcusVNl16Sy83ZnwZ9Cjkczi0oMS4XZLAqrHnT3jphcds63ZrrKueR5Gd8Rqbeo3XnoG2gqLjlE6eJrCaTnDhGvyyhGzmaqF3oKsWmR6ihseYbsB1ihseGKgiX8GNorridH2XKfpz0209CWGRssCJh2ZPn5EhtaQbgQcCcad15eacGaQsvwPNZafkyINJBBaqEokRw)Xd750h19CujQefHmeAhtw8efqI5bFaivIIIiPiwZbh4xHciCUJBCaTnGktw80jgJ4aAB6oaRWWoaZyaG(UDiLGzw1roKiKdK2QroKiajnqI5bpDIIqgcTJjlEYOTPhasLOGkV)g4tIkHKIkbOgyOAuaqujKaRLauhagasLOaquSH)iwlaKkrbarLOA91rbGVDwIsWrPpJbQKOSUS4jk1IKCaivIcaIciFd29Jsmc)f6LjhasLOaGOsuT(6OaWGEujo5nOOCbdkOv)OWmrHKBkHIRzpNArcY7KNdj3ucLR9o5DeyVtEUpgS6Apa9CDYkNSMNRJBGX0P4DeuuudjkQgf7OCjkXuFK8S8ueKykwoj)XGvxhvRwrjM6JKrGWYjmG8p)XGvxhf7OCjkXuFK8Dgzdp4oM88hdwDDuSJQJXknUTjFNr2WdUJjptEJTdkkGcjQeIQvROsokz7SSdFuUgf7OCBK1GvpJ2HxDAXi8xIY1OyhLye(lzzBoTGP17JcaII8gBhuuuhvIXZzDzXJNJaMkGK7fVJj4DYZ9XGvx7bONZ6YIhphVriy5EUozLtwZZjM6JKrGWYjmG8p)XGvxhf7OiNHCefdw9OyhLye(lzzBoTGP17JcaII8gBhuuuhvcEUou6QtlgH)cY7iWEX7iq4DYZ9XGvx7bONZ6YIhphVriy5EUozLtwZZjM6JKrGWYjmG8p)XGvxhf7OiVX2bffqHefWqDuSJkTbujBQApjkGcjkGJIDuIr4VKLT50cMwVpkaikYBSDqrrDuj456qPRoTye(liVJa7fVJu17KN7JbRU2dqpxNSYjR55et9rYiqy5egq(N)yWQRJIDugREYkpJOqWG6RPrGmm4UjlEYFmy11rXoQKJsJLmbmvajplBNLD49Cwxw845iGPci5EX7y79o55(yWQR9a0ZzDzXJNJ3ieSCpxNSYjR55et9rYiqy5egq(N)yWQRJIDugREYkpJOqWG6RPrGmm4UjlEYFmy11rXokXi8xYY2CAbtR3hf1rrEJTdkk2r1XnWy6u8ockRpZ2xjkQJcypxhkD1PfJWFb5DeyV4DmX4DYZ9XGvx7bONJbtON7S4DeypN1LfpEUumwrtocds63lEht8EN8CFmy11Ea656KvoznpNyQpsgbclNWaY)8hdwDDuSJsm1hjFNr2WdUJjp)XGvxhf7O6ySsJBBY3zKn8G7yYZK3y7GIcOrbCuSJkLC308DDg4mbmvajpk2rPXsMaMkGKNjVX2bff1r1(OGokQgv7evpLUXCMgL(r75SUS4XZXBecwUx8INtFgdujEN8ocS3jp3hdwDThGEUozLtwZZLCui5MsOCD2ukpN1LfpEow2olEX7ycEN8Cwxw845qYnLqXZ9XGvx7bOx8oceEN8CFmy11Ea65CBkW75(CcpuYKZ)jkOJkfVi8CnnS6xJIQDIkXhvI9OCjQeIQDIcLELIMIHKhLREoRllE8CUnYAWQ75CBe6XAUN7Zj8qHMC(p0DCd8ox7fVJu17KN7JbRU2dqpNBtbEphk9kfTye(lOmJn0ygAwM19rrb0OsWZzDzXJNZTrwdwDpNBJqpwZ9COD4vNwmc)fV4DS9EN8CFmy11Ea656KvoznphsUPekxNjyEW75SUS4XZ1nLI26YIhA1IepNArc9yn3ZHKBkHY1EX7yIX7KN7JbRU2dqpN1LfpEUUPu0wxw8qRwK45ulsOhR5EUUg5fVJjEVtEUpgS6Apa9Cwxw8456MsrBDzXdTArINtTiHESM750yXlEhHQEN8CFmy11Ea65SUS4XZ1nLI26YIhA1IepNArc9yn3ZPxY7Ix8oYk9o55(yWQR9a0Z1jRCYAEUpNWdLS(mBFLOOgsua3(OGok3gzny1ZFoHhk0KZ)HUJBG35ApN1LfpEoJ0T50cMq(iEX7iWqT3jpN1LfpEoJ0T50PGk09CFmy11Ea6fVJadS3jpN1LfpEo1Ytrq0j2a18nFep3hdwDThGEXlEUuY74gyt8o5DeyVtEUpgS6Apa9I3Xe8o55(yWQR9a0lEhbcVtEUpgS6Apa9I3rQ6DYZ9XGvx7bOx8o2EVtEoRllE8CwAQck0P4fHhp3hdwDThGEX7yIX7KNZ6YIhphsUPekEUpgS6Apa9I3XeV3jpN1LfpEUuSS4XZ9XGvx7bOx8ocv9o55(yWQR9a0ZzDzXJNRXiSCnndMqRVju8CDYkNSMNJyRM(U)iztRr5DII6OOku75sjVJBGnHg9oE0ipx79Ix8C6L8U4DY7iWEN8CFmy11Ea656Kvoznpxh3aJPtX7iOOOgsuunkOJsm1hjR)tpHgjetm(3K)yWQRJIDuUeL(WGmmz3F0xeldMgvRwrPpmidtwWoVDAyLPFgmnQwTI6Zj8qjRpZ2xjkGcjQeAFuqhLBJSgS65pNWdfAY5)q3XnW7CDuTAfvYr52iRbREgTdV60Ir4VeLRrXokxIk5Oet9rY3zKn8G7yYZFmy11r1QvuDmwPXTn57mYgEWDm5zYBSDqrrDujeLREoRllE8CFC)b34fVJj4DYZ9XGvx7bONZTPaVNRJBGX0P4DeuwFMTVsuuhfWr1QvuFoHhkz9z2(krbuirLq7Jc6OCBK1Gvp)5eEOqto)h6oUbENRJQvROsok3gzny1ZOD4vNwmc)fpN1LfpEo3gzny19CUnc9yn3ZbIonZQuN4fVJaH3jp3hdwDThGEUozLtwZZ52iRbREgeDAMvPojk2rbdYWKrums6NRPHvM(OmsSolrrnKOsGv65SUS4XZLIxeEUMMLzzUx8osvVtEUpgS6Apa9CDYkNSMNZTrwdw9mi60mRsDsuSJYLOGbzyYuwT(dnSY0hLrI1zjkQHefWSYOA1kku6vkAXi8xqzgBOXm0SmR7JIIAirr1OGokxIYy1tw5zngewDAng9mXgwII6OsikxJc6OqYnLq56mbZd(OC1ZzDzXJNJXgAmdnlZ6(iV4DS9EN8CFmy11Ea656KvoznpNBJSgS6zq0PzwL6KOyhfk9kfTye(lOmJn0ygAwM19rrrnKOacpN1LfpEogBOXm0SmR7J8I3XeJ3jp3hdwDThGEUozLtwZZ52iRbREgeDAMvPojk2r5suWGmmzy1oA0QFgmnQwTIk5Oet9rYU)GBOjGik5pgS66OyhvYrzS6jR8SgdcRoTgJE(JbRUokx9Cwxw845Gv7OrR(EX7yI37KN7JbRU2dqpxNSYjR55CBK1GvpdIonZQuNef7OqPxPOfJWFbLzSHgZqZYSUpkkirLGNZ6YIhpxdOSktUx8ocv9o55(yWQR9a0Z1jRCYAEo3gzny1ZGOtZSk1jEoRllE8CnGYQm5EXlEUUg5DY7iWEN8CFmy11Ea656KvoznphmidtgwHXAfisYKBDjQwTIsFyqgMS7p6lILbt9Cwxw845sXYIhV4DmbVtEUpgS6Apa9CDYkNSMNl5OqYnLq56mbZd(OyhLlr1XyLg32KD)rFrSm5n2oOOakKOaok2r5sujhLyQpsgbclNWaY)8hdwDDuTAfLglzEJqWYZPnGkztv7jrrDuahLRr1QvuDmwPXTnz3F0xeltEJTdkkQJIQTpkx9CJ1CphVPE3uQtq0Wy845SUS4XZXBQ3nL6eenmgpEX7iq4DYZ9XGvx7bONRtw5K18CjhfsUPekxNjyEWhf7OCjQogR042MS7p6lILjVX2bffqHefWrXokxIk5Oet9rYiqy5egq(N)yWQRJQvRO0yjZBecwEoTbujBQApjkQJc4OCnQwTIQJXknUTj7(J(IyzYBSDqrrDuuT9r5QNZ6YIhphi60R8gKx8osvVtEUpgS6Apa9CDYkNSMNtFyqgMS7p6lILbt9Cwxw845GvySMMbKafV4DS9EN8CFmy11Ea656KvoznpN(WGmmz3F0xeldM65SUS4XZbFc6ew2H3lEhtmEN8CFmy11Ea656KvoznpN(WGmmz3F0xeldM65SUS4XZXSKdRWyTx8oM49o55(yWQR9a0Z1jRCYAEo9HbzyYU)OViwgm1ZzDzXJNZM(rcXu0DtP8I3rOQ3jp3hdwDThGEUozLtwZZrSvtF3FKSP1OmyAuSJYLOeJWFjlBZPfmTEFuanQoUbgtNI3rqz9z2(kr1orbCU9r1QvuDCdmMofVJGY6ZS9vIIAir1tPBmNPrPF0r5QNZ6YIhpxJry5AAgmHwFtO4fVJSsVtEUpgS6Apa9CDYkNSMNJyRM(U)iztRr5DII6OacOokaikITA67(JKnTgL1Getw8ef7O64gymDkEhbL1Nz7Ref1qIQNs3yotJs)O9Cwxw845AmclxtZGj06BcfV4DeyO27KN7JbRU2dqpxNSYjR55sokKCtjuUotW8Gpk2rPXsMaMkGKNLTZYo8rXokxIk5Oet9rYiqy5egq(N)yWQRJQvROsokJvpzLNruiyq910iqggC3Kfp5pgS66OA1kknwY8gHGLNtBavYMQ2tII6OaokxJIDuUevYrjM6JKNLNIGetXYj5pgS66OA1kQKJsm1hjFNr2WdUJjp)XGvxhvRwr1XyLg32KVZiB4b3XKNjVX2bffqJQ9rbarLquTtuIP(iz9F6j0iHyIX)M8hdwDDuU65SUS4XZ5(J(IyEX7iWa7DYZ9XGvx7bONRtw5K18CIP(izeiSCcdi)ZFmy11rXoQKJsJLmVriy5zz7SSdFuSJYTrwdw9mAhE1PfJWFXZzDzXJNZTnlIIx8ocCcEN8CFmy11Ea656KvoznpNyQps(oJSHhChtE(JbRUok2r5suIP(i5z5PiiXuSCs(JbRUoQwTIsm1hjJaHLtya5F(JbRUok2r52iRbREgTdV60Ir4VeLRrXoQoUbgtNI3rqrrnKO6P0nMZ0O0p6OyhvhJvACBt(oJSHhChtEM8gBhuuankGJIDuUevYrjM6JKrGWYjmG8p)XGvxhvRwrLCugREYkpJOqWG6RPrGmm4UjlEYFmy11r1QvuASK5ncblpN2aQKnvTNefqHefWr5QNZ6YIhpNBBwefV4DeyGW7KN7JbRU2dqpxNSYjR55et9rYZYtrqIPy5K8hdwDDuSJk5Oet9rY3zKn8G7yYZFmy11rXoQoUbgtNI3rqrrnKO6P0nMZ0O0p6OyhL(WGmmz3F0xeldM65SUS4XZ52MfrXlEhbMQEN8CFmy11Ea656KvoznpNyQpsgbclNWaY)8hdwDDuSJYLOsokXuFK8Dgzdp4oM88hdwDDuTAfvYr52iRbREgTdV60Ir4VeLRrXoQKJcj3ucLRZemp4JIDuDmwPXTnzEJqWYZGPrXoknwY8gHGLNjNHCefdw9OyhLlrHsVsrlgH)ckZydnMHMLzDFuuafsuaruSJQJBGX0P4DeuwFMTVsuudjkGJc6OqPxPOfJWFbLzSHgZqZYSUpkQwTIcLELIwmc)fuMXgAmdnlZ6(OOOgsuunk2r1XnWy6u8ockRpZ2xjkQHefvJYvpN1LfpEo32SikEX7iWT37KN7JbRU2dqpxNSYjR55et9rYngsoH2qidH2j)XGvxhf7OsokKCtjuUoBkvuSJQXqYj0gczi0o0K3y7GIcOqIcQJIDujhLglzcyQasEMCgYrumy19Cwxw845CBZIO4fVJaNy8o55(yWQR9a0Z1jRCYAEUKJcj3ucLRZMsff7Omw9KvEgrHGb1xtJazyWDtw8K)yWQRJIDuASK5ncblptod5ikgS6rXoknwY8gHGLNtBavYMQ2tIcOqIc4Oyhvh3aJPtX7iOS(mBFLOOgsua75SUS4XZHOyACBnxP9I3rGt8EN8CFmy11Ea656KvoznpNglzcyQasEM8gBhuuuhfvJc6OOAuTtu9u6gZzAu6hDuSJk5O0yjZBecwEMCgYrumy19Cwxw845UZiB4b3XK7fVJadv9o55(yWQR9a0Z1jRCYAEonwYeWubK8SSDw2H3ZzDzXJNtWoVDAyLPVx8INtJfVtEhb27KN7JbRU2dqpxNSYjR55et9rY3zKn8G7yYZFmy11rXokxIYLO64gymDkEhbff1qIQNs3yotJs)OJIDuDmwPXTn57mYgEWDm5zYBSDqrb0OaokxJQvROCjQKJs2ol7Whf7OCjkzBEuuhfWqDuTAfvh3aJPtX7iOOOgsujeLRr5AuU65SUS4XZratfqY9I3Xe8o55(yWQR9a0ZXGj0ZDw8ocSNZ6YIhpxkgROjhHbj97fVJaH3jp3hdwDThGEoRllE8C8gHGL756KvoznpNlrLCuIP(izeiSCcdi)ZFmy11r1QvujhLlr1XyLg32KDBZIOKbtJIDuDmwPXTnz3F0xeltEJTdkkGcjkQgLRr5AuSJQJBGX0P4DeuwFMTVsuudjkGJIDuKZqoIIbREuSJYLOsBavYMQ2tIcOqIc4OA1kkYBSDqrbuirjBNfAzBEuSJcLELIwmc)fuMXgAmdnlZ6(OOOgsuaruqhLXQNSYZikemO(AAeiddUBYIN8hdwDDuUgf7OCjQKJ6oJSHhChtUoQwTII8gBhuuafsuY2zHw2Mhv7evcrXoku6vkAXi8xqzgBOXm0SmR7JIIAirberbDugREYkpJOqWG6RPrGmm4UjlEYFmy11r5AuSJk5OqiAyqgMRJIDuUeLye(lzzBoTGP17JcaII8gBhuuuhfvJIDuO0Ru0Ir4VGYm2qJzOzzw3hffqHefWr1QvuIr4VKLT50cMwVpkaikYBSDqrrDuaNquU656qPRoTye(liVJa7fVJu17KN7JbRU2dqpxNSYjR55qPxPOfJWFbff1qIkHOyhf5n2oOOaAujef0r5suO0Ru0Ir4VGIIAir1(OCnk2r1XnWy6u8ockkQHefv9Cwxw8456KTbHhA5nPhjEX7y79o55(yWQR9a0ZzDzXJNJaMkGK756Kvoznpxh3aJPtX7iOOOgsuunk2rrod5ikgS6rXokxIkTbujBQApjkGcjkGJQvROiVX2bffqHeLSDwOLT5rXoku6vkAXi8xqzgBOXm0SmR7JIIAirberbDugREYkpJOqWG6RPrGmm4UjlEYFmy11r5AuSJYLOsoQ7mYgEWDm56OA1kkYBSDqrbuirjBNfAzBEuTtujef7OqPxPOfJWFbLzSHgZqZYSUpkkQHefqef0rzS6jR8mIcbdQVMgbYWG7MS4j)XGvxhLRrXokXi8xYY2CAbtR3hfaef5n2oOOOokQ656qPRoTye(liVJa7fV4fpN7tqlE8oMaudmufyOobwzobGtibpxBgz2Hh55aWMOaPJjohzfSwur5eLh12KIjsumysujw1l5DjXAuKZ6k4sUokeU5rzGcUXKRJQtXg(JYbGor5rXGvkCB7WhLbsmuuTDYJceDDu7eLq5rzDzXtuQfjrbdkr12jpQblrXGbhDu7eLq5rzAnEIsBIbBOZAbGrbarHOyK0pxtdRm9rbGbGjUMumrUoQetuwxw8eLArckha65sjyMvDphvIkrridH2XKfprbKyEWhasLOOiskI1CWb(vOacN74ghqBdOYKfpDIXioG2MUdWkmSdWmgaOVBhsjyMvDKdjc5aPTAKdjcqsdKyEWtNOiKHq7yYINmAB6bGujkOY7Vb(KOsiPOsaQbgQgfaevcjWAja1bGbGujkaefB4pI1caPsuaqujQwFDua4BNLOeCu6ZyGkjkRllEIsTijhasLOaGOaY3GD)OeJWFHEzYbGujkaiQevRVokamOhvItEdkkxWGcA1pkmtui5MsO4AoamaKkr1Uo)oOCDuWNbtEuDCdSjrbF(Dq5Os0E)PckQbpaafJ0WaQIY6YIhuu4rbLCaO1LfpOCk5DCdSjqyugILaqRllEq5uY74gytGgIdgiFZhXKfpbGwxw8GYPK3XnWManehyWyDaivIIBSuefSefXwDuWGmmxhfsmbff8zWKhvh3aBsuWNFhuu2OJkLCaiflYo8rTOO0455aqRllEq5uY74gytGgIdOXsruWcnsmbfaADzXdkNsEh3aBc0qCWstvqHofVi8eaADzXdkNsEh3aBc0qCaj3ucLaqRllEq5uY74gytGgIdPyzXtaO1LfpOCk5DCdSjqdXHgJWY10mycT(MqjPuY74gytOrVJhncs7tAzGqSvtF3FKSP1O8outvOoamaKkr1Uo)oOCDu39jqjkzBEucLhL1fmjQffL52wLbREoaKkrbKhj3ucLOwMOsXi0cREuUm4OCdQMtmy1J6ZB2JIANO64gytCna06YIheew2oljTmqsgj3ucLRZMsfaADzXdcAioGKBkHsaO1LfpiOH4GBJSgS6jnwZH85eEOqto)h6oUbENRtYTPapKpNWdLm58FGofVi8CnnS6xJANeFIDxsODqPxPOPyi5UgaADzXdcAio42iRbREsJ1CiOD4vNwmc)LKCBkWdbLELIwmc)fuMXgAmdnlZ6(iGMqaO1LfpiOH4q3ukARllEOvlssASMdbj3ucLRtAzGGKBkHY1zcMh8bGwxw8GGgIdDtPOTUS4HwTijPXAoKUgfaADzXdcAio0nLI26YIhA1IKKgR5q0yja06YIhe0qCOBkfT1Lfp0QfjjnwZHOxY7saO1LfpiOH4Gr62CAbtiFKKwgiFoHhkz9z2(kudb42dTBJSgS65pNWdfAY5)q3XnW7CDaO1LfpiOH4Gr62C6uqf6bGwxw8GGgIdQLNIGOtSbQ5B(ibGbGujkaegR042guaO1LfpOCxJGKILfpjTmqGbzyYWkmwRarsMCRlTAPpmidt29h9fXYGPbGwxw8GYDncAioaIo9kVjPXAoeEt9UPuNGOHX4jPLbsYi5MsOCDMG5bpBx6ySsJBBYU)OViwM8gBheqHamBxswm1hjJaHLtya5F(JbRUUvlnwY8gHGLNtBavYMQ2tOgyxB1QJXknUTj7(J(IyzYBSDqut127AaO1LfpOCxJGgIdGOtVYBqjTmqsgj3ucLRZemp4z7shJvACBt29h9fXYK3y7GakeGz7sYIP(izeiSCcdi)ZFmy11TAPXsM3ieS8CAdOs2u1Ec1a7ARwDmwPXTnz3F0xeltEJTdIAQ2ExdaTUS4bL7Ae0qCawHXAAgqcusAzGOpmidt29h9fXYGPbGwxw8GYDncAioaFc6ew2HpPLbI(WGmmz3F0xeldMgaADzXdk31iOH4aZsoScJ1jTmq0hgKHj7(J(IyzW0aqRllEq5UgbnehSPFKqmfD3uQKwgi6ddYWKD)rFrSmyAaivIkXXeLP1OOmYJcmnPOqZM(Oekpk88OABfkrPWTDKeLtobvYrbGb9OAJYNO0qzh(OymKCsucfBIcaLirPpZ2xjkmjQ2wHcguIYgOefakrYbGwxw8GYDncAio0yewUMMbtO13ekjTmqi2QPV7ps20AugmLTlIr4VKLT50cMwVhODCdmMofVJGY6ZS9vAhGZTVvRoUbgtNI3rqz9z2(kudPNs3yotJs)ODnaKkrL4yIAWrzAnkQ2wLkk9(OABfk7eLq5rn3zjkGaQrjffi6rX6WavIcprbJrOOABfkyqjkBGsuaOejhaADzXdk31iOH4qJry5AAgmHwFtOK0YaHyRM(U)iztRr5DOgiGAaGyRM(U)iztRrzniXKfpS74gymDkEhbL1Nz7RqnKEkDJ5mnk9JoaKkrX6)OViwuyqbT6hfsUPekr12kuIcibtfqYJcmnhfa2vOefhiSCcdi)Jsm1hjkB0rXrHGb1xhfhiddUBYINOsXTDsuMQndkOOarpQ2wHsuWGmmxhfRWieS8CuayxHsuoU8ueKykwojkB0r1UoJSHhChtEuGOhfyAucoQ2JIYfGafvBRqjkOcNRrbFgm5rX6TzruIQJBGX5aqRllEq5UgbnehC)rFrSKwgijJKBkHY1zcMh8S1yjtatfqYZY2zzhE2UKSyQpsgbclNWaY)8hdwDDRwjBS6jR8mIcbdQVMgbYWG7MS4j)XGvx3QLglzEJqWYZPnGkztv7judSRSDjzXuFK8S8ueKykwoj)XGvx3QvYIP(i57mYgEWDm55pgS66wT6ySsJBBY3zKn8G7yYZK3y7GaA7bGeAhXuFKS(p9eAKqmX4Ft(JbRU21aqQev76SqSO4aHLtya5FuSEBweLO64rVYIhwlkamOhvBu(efRWieS8O0eCA61rHNO42Hx9OCYi8xcaTUS4bL7Ae0qCWTnlIssldeXuFKmcewoHbK)5pgS6A2jRXsM3ieS8SSDw2HNTBJSgS6z0o8QtlgH)saivII1BZIOevBRqjQ21zeFuqhLloU8ueKykwojPOWKO4aHLtya5Fu4rbLOWtua7KRSwuSoMZBdytuaOejkB0r1UoJ4JICtdLOyWKOM7SefRaabvcaTUS4bL7Ae0qCWTnlIssldeXuFK8Dgzdp4oM88hdwDnBxet9rYZYtrqIPy5K8hdwDDRwIP(izeiSCcdi)ZFmy11SDBK1GvpJ2HxDAXi8xCLDh3aJPtX7iiQH0tPBmNPrPF0S7ySsJBBY3zKn8G7yYZK3y7GakWSDjzXuFKmcewoHbK)5pgS66wTs2y1tw5zefcguFnncKHb3nzXt(JbRUUvlnwY8gHGLNtBavYMQ2takeGDnaKkrX6TzruIQTvOeLJlpfbjMILtIc6OCehv76mIN1II1XCEBaBIcaLirzJokw)h9fXIcmna06YIhuURrqdXb32SikjTmqet9rYZYtrqIPy5K8hdwDn7Kft9rY3zKn8G7yYZFmy11S74gymDkEhbrnKEkDJ5mnk9JMT(WGmmz3F0xeldMgasLOy92Sikr12kuIIdewoHbK)rbDuU4ioQ21zeFuysuj4e0UYAr5iokKCtjuCabclNWaY)KIIvyecwEua5zihrXGvpPO(Gb5Pefk16pkgmjQD64MD4JIvyecwEuaOeja06YIhuURrqdXb32SikjTmqet9rYiqy5egq(N)yWQRz7sYIP(i57mYgEWDm55pgS66wTs2Trwdw9mAhE1PfJWFXv2jJKBkHY1zcMh8S7ySsJBBY8gHGLNbtzRXsM3ieS8m5mKJOyWQZ2fu6vkAXi8xqzgBOXm0SmR7JakeGGDh3aJPtX7iOS(mBFfQHam0O0Ru0Ir4VGYm2qJzOzzw3h1Qfk9kfTye(lOmJn0ygAwM19rudHQS74gymDkEhbL1Nz7RqneQ6AaivII1BZIOevBRqjkwhdjNevIIqgAhwlkhXrHKBkHsu2OJAWrzDzD)OyDs0OGbzyskkGemvajpQblrTtuKZqoIsueB4FaO1LfpOCxJGgIdUTzrusAzGiM6JKBmKCcTHqgcTt(JbRUMDYi5MsOCD2uk2ngsoH2qidH2HM8gBheqHa1StwJLmbmvajptod5ikgS6bGujkokMg3wZv6OyWKO4OqWG6RJIdKHb3nzXtaO1LfpOCxJGgIdikMg3wZv6KwgijJKBkHY1ztPyBS6jR8mIcbdQVMgbYWG7MS4j)XGvxZwJLmVriy5zYzihrXGvNTglzEJqWYZPnGkztv7jafcWS74gymDkEhbL1Nz7RqneGdaPsuTRZiB4b3XKhvBu(efmwOefqcMkGKhLn6OyfgHGLhLrEuGPrXGjrPWdFuFWG8ucaTUS4bL7Ae0qC4oJSHhChtEsldenwYeWubK8m5n2oiQPk0uTD6P0nMZ0O0pA2jRXsM3ieS8m5mKJOyWQhaADzXdk31iOH4GGDE70Wkt)KwgiASKjGPci5zz7SSdFayaivIcQSK3LO0wJX)Om4vTYEuaivIQDh3FWnrzsuuf6OCP9qhvBRqjkOcNRrbGsKCujUMMRxtUckrHNOsa6OeJWFbLuuTTcLOy9F0xelPOWKOABfkr5eazDlkSq5K2w0JQnBLOyWKOq4Mh1Nt4HsoQevHWr1MTsultuTRZi(O64gyCulkQoUzh(OatZbGwxw8GY6L8Ua5J7p4MKwgiDCdmMofVJGOgcvHwm1hjR)tpHgjetm(3K)yWQRz7I(WGmmz3F0xeldM2QL(WGmmzb782PHvM(zW0wT(CcpuY6ZS9vakKeAp0UnYAWQN)CcpuOjN)dDh3aVZ1TALSBJSgS6z0o8QtlgH)IRSDjzXuFK8Dgzdp4oM88hdwDDRwDmwPXTn57mYgEWDm5zYBSDquNGRbGwxw8GY6L8UanehCBK1GvpPXAoeq0PzwL6KKCBkWdPJBGX0P4DeuwFMTVc1a3Q1Nt4HswFMTVcqHKq7H2Trwdw98Nt4Hcn58FO74g4DUUvRKDBK1GvpJ2HxDAXi8xcaPsujcEr456OaWNL5rzsujWkHokKyDwqrHzIIJIrs)CDuauz6JYbGwxw8GY6L8UanehsXlcpxtZYSmpPLbIBJSgS6zq0PzwL6e2WGmmzefJK(5AAyLPpkJeRZc1qsGvgasLOsSytuyMOaWN19rrzsuaZkHokKyDwqrHzII1LvR)efavM(OOWKOmEBhKefvHokxAp0r12kuIcQGbHvpkOcgDxJsmc)fuoa06YIhuwVK3fOH4aJn0ygAwM19rjTmqCBK1GvpdIonZQuNW2fyqgMmLvR)qdRm9rzKyDwOgcWSYwTqPxPOfJWFbLzSHgZqZYSUpIAiufAxmw9KvEwJbHvNwJrptSHfQtWvOrYnLq56mbZdExdaPsujwSjkmtua4Z6(OOeCuwAQckrbvUPvqjQebVi8e1Ye1owxw3pk8eLnqjkXi8xIYKOaIOeJWFbLdaTUS4bL1l5DbAioWydnMHMLzDFuslde3gzny1ZGOtZSk1jSrPxPOfJWFbLzSHgZqZYSUpIAiaraO1LfpOSEjVlqdXby1oA0QFslde3gzny1ZGOtZSk1jSDbgKHjdR2rJw9ZGPTALSyQps29hCdnberj)XGvxZozJvpzLN1yqy1P1y0ZFmy11UgasLOCYGbawhqzvM8OeCuwAQckrbvUPvqjQebVi8eLjrLquIr4VGcaTUS4bL1l5DbAio0akRYKN0YaXTrwdw9mi60mRsDcBu6vkAXi8xqzgBOXm0SmR7JGKqaO1LfpOSEjVlqdXHgqzvM8KwgiUnYAWQNbrNMzvQtcadaPsuqfRX4Fuy3NeLSnpkdEvRShfasLO4sFFnvuajyQasEuOlGPrXGjr1UoJ4daTUS4bL1ybcbmvajpPLbIyQps(oJSHhChtE(JbRUMTlU0XnWy6u8ocIAi9u6gZzAu6hn7ogR042M8Dgzdp4oM8m5n2oiGcSRTA5sYY2zzhE2UiBZPgyOUvRoUbgtNI3rqudjbxD11aqQefRWieS8Oatz5pnPOmfchLq2JIsWrbIEuReLHIYIcL((AQO4)CIjysumysucLhLYqsuaOejk4ZGjpklkMDweLtcaTUS4bL1ybAioKIXkAYryqs)jXGj0ZDwGaCaO1LfpOSglqdXbEJqWYtQdLU60Ir4VGGaCsldexswm1hjJaHLtya5F(JbRUUvRKDPJXknUTj72MfrjdMYUJXknUTj7(J(IyzYBSDqafcvD1v2DCdmMofVJGY6ZS9vOgcWSjNHCefdwD2UK2aQKnvTNauia3Qf5n2oiGcr2ol0Y2C2O0Ru0Ir4VGYm2qJzOzzw3hrneGaAJvpzLNruiyq910iqggC3Kfp5pgS6Axz7sY3zKn8G7yY1TArEJTdcOqKTZcTSnVDsGnk9kfTye(lOmJn0ygAwM19rudbiG2y1tw5zefcguFnncKHb3nzXt(JbRU2v2jJq0WGmmxZ2fXi8xYY2CAbtR3daK3y7GOMQSrPxPOfJWFbLzSHgZqZYSUpcOqaUvlXi8xYY2CAbtR3daK3y7GOg4eCnaKkrbGiBdcpr50BspsIcpkOefEIQbujBQ6rjgH)ckktIIQqhfakrIQnkFIIaoZo8rHbLO2jQeqr5cyAucokQgLye(lixJctIciqr5s7HokXi8xqUgaADzXdkRXc0qCOt2geEOL3KEKK0YabLELIwmc)fe1qsGn5n2oiGMa0UGsVsrlgH)cIAiT3v2DCdmMofVJGOgcvdaPsua4)PrbMgfqcMkGKhLjrrvOJcprzkvuIr4VGIYL2O8jk16Eh(Ou4HpQpyqEkrzJoQblrHglfrblUgaADzXdkRXc0qCGaMkGKNuhkD1PfJWFbbb4KwgiDCdmMofVJGOgcvztod5ikgS6SDjTbujBQApbOqaUvlYBSDqafISDwOLT5SrPxPOfJWFbLzSHgZqZYSUpIAiab0gREYkpJOqWG6RPrGmm4UjlEYFmy11UY2LKVZiB4b3XKRB1I8gBheqHiBNfAzBE7KaBu6vkAXi8xqzgBOXm0SmR7JOgcqaTXQNSYZikemO(AAeiddUBYIN8hdwDTRSfJWFjlBZPfmTEpaqEJTdIAQgagasLO4KBkHY1rLODzXdkaKkr54YtbjMILtskkmjkoqyb621zeFu4jkGDI1IIBSuefSefqcMkGKhaADzXdkJKBkHY1qiGPci5jTmq64gymDkEhbrneQY2fXuFK8S8ueKykwoj)XGvx3QLyQpsgbclNWaY)8hdwDnBxet9rY3zKn8G7yYZFmy11S7ySsJBBY3zKn8G7yYZK3y7GakKeA1kzz7SSdVRSDBK1GvpJ2HxDAXi8xCLTye(lzzBoTGP17baYBSDquNycaPsuCGWYjmG8N1IkrttvqjkmjkG8mKJOevBRqjkyqgMRJIvyecwoka06YIhugj3ucLRHgId8gHGLNuhkD1PfJWFbbb4KwgiIP(izeiSCcdi)ZFmy11SjNHCefdwD2Ir4VKLT50cMwVhaiVX2brDcbGujkoqy5egq(ZArX6U7tiR(rnysJPIIvyecwokQ2wHsuOXsruWsuUpbT4bfaADzXdkJKBkHY1qdXbEJqWYtQdLU60Ir4VGGaCsldeXuFKmcewoHbK)5pgS6A2K3y7GakeGHA2PnGkztv7jafcWSfJWFjlBZPfmTEpaqEJTdI6ecaPsuCGWYjmG8pkOJIJcbdQVokoqggC3KfpSwujAAQckrDJOGsuajyQasEucftIQTvPIc(rrod5ikxhfdMevQn63S9CaO1LfpOmsUPekxdnehiGPci5jTmqet9rYiqy5egq(N)yWQRzBS6jR8mIcbdQVMgbYWG7MS4j)XGvxZoznwYeWubK8SSDw2HpaKkrXbclNWaY)OAZHO4OqWG6RJIdKHb3nzXdRffqElnvbLOyWKOGXdikkauIeLn6OUZYh91rHglfrblrPbjMS4ja06YIhugj3ucLRHgId8gHGLNuhkD1PfJWFbbb4KwgiIP(izeiSCcdi)ZFmy11Snw9KvEgrHGb1xtJazyWDtw8K)yWQRzlgH)sw2MtlyA9EQjVX2bXUJBGX0P4DeuwFMTVc1ahasLO4aHLtya5Fuqhv76mIN1IQDD)jkS7tiR(rzrHglfrblrXkmcblpkYYtrIYyKtIcibtfqYJc(myYJQDDgzdp4oMS4ja06YIhugj3ucLRHgIdPySIMCegK0Fsmyc9CNfiahaADzXdkJKBkHY1qdXbEJqWYtAzGiM6JKrGWYjmG8p)XGvxZwm1hjFNr2WdUJjp)XGvxZUJXknUTjFNr2WdUJjptEJTdcOaZoLC308DDg4mbmvajNTglzcyQasEM8gBhe1ThAQ2o9u6gZzAu6hTNdL(U3XeApR0lEX7b]] )

end