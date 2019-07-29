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


    spec:RegisterPack( "Assassination", 20190729, [[d8KERbqiuv9iQGUKsPk1MqrJcvLtHk1Qeq8kKKzrf6wOsyxc9lbQHHkPJHKAzkf9mQatta11KqSnjK6BOGY4KqsNtPuADOG4DcijnpLsUNs1(qH(NsPQ6GkLkluPWdrLitucjUikOAJciP(iQevJuPuL4KOsuwjs4LkLQyMOGe3uaj2PamubKAPkLINIstvGCvLsvzROGuFvPuL0EPQ)kPbR4Wuwms9yLmzcxgSzv1NLOrJkoTkRgfK0RrIMnr3wq7wQFd1WPshxajXYr8CitN01vLTJQ8DjuJxc68sG1JcmFQO9lAp1(G8SctbFaBYvQ3wUYW2CBJu7ahu0oGH5z1cCbpRRTO0kbpBBHGND7qidHU20d3EwxRaj2e(G8Si8JSaplhvDrmKGdU8uop64chgm6cFstpCVi2xdgDHRG9S0VtQCzTN2Zkmf8bSjxPEB5kdBZTnsTdCqrksr7zTNYbt8SSxixYZY5ecO90EwbGwEwhMZ2HqgcDTPhUZzBWLpiPWH5Wrvxedj4GlpLZJoUWHbJUWN00d3lI91Grx4k4KchMdfpzb5S526yoBYvQ32C4ICO2bmehuKKIKchMdxIJ1LaIHKu4WC4IC2oHae5S9ClkZrX5iGV9KAo2spCNJ8qAmPWH5Wf5SnqiMhKJAKsqR3pMu4WC4IC2oHae5S9HGC4YuieLdF4NIobKd(NdsbtQC4o6zLhsr(G8SifmPYbe(G8bqTpipl0gTee(n8SlYPa5mp7chsJRU4RvuomUNtGZHzo8LJAsO1yFLCuKAskbseAJwcICC6mh1KqRr0JwbY)vcrOnAjiYHzo8LJAsO1iuiY6Y31McrOnAjiYHzolmwkWf3rOqK1LVRnfIei0UgLZw75SzooDMd)5O3IYRlZH7CyMdpJCgTeIORlLqvnsjO5WDomZrnsjOr9cHQIRIdYHlYHaH21OCymNI2ZAl9WTNL8C1hb8QpGn9b5zH2OLGWVHN9Jj1gku9bqTN1w6HBpRlglReaHFKf4vFaoWhKNfAJwcc)gE2f5uGCMN1yaqofIioe8taIk69)4LPhUJqB0sqKdZCOF)Fe9OvG8FLq85MdZCOF)Fe9OvG8FLqKaH21OC2khQJoihM5WFoiuL(9)GWZAl9WTNT0ieScE1hqG9b5zH2OLGWVHN9Jj1gku9bqTN1w6HBpRlglReaHFKf4vFafXhKNfAJwcc)gEwBPhU9SLgHGvWZUiNcKZ8SQjHwJOhTcK)ReIqB0sqKdZC4lhceAxJYzRCOEZCC6mh3WNupx5bKC2AphQZH7CyMJAKsqJ6fcvfxfhKdxKdbcTRr5WyoB6zxfSKqvnsjOiFau7vFafTpipl0gTee(n8SlYPa5mpRAsO1i6rRa5)kHi0gTee5WmhJba5uiI4qWpbiQO3)JxME4ocTrlbromZH)CeynsEU6Jar9wuEDzomZHNroJwcr01LsOQgPeupRT0d3EwYZvFeWR(ayy(G8SqB0sq43WZ(XKAdfQ(aO2ZAl9WTN1fJLvcGWpYc8QpGIQpipl0gTee(n8S2spC7zlncbRGNDrofiN5zvtcTgrpAfi)xjeH2OLGihM5ymaiNcrehc(jarf9(F8Y0d3rOnAjiYHzoQrkbnQxiuvCvCqomMdbcTRr5Wmh(YHaH21OC2khQlQ540zo8NdcvPF)piYHBp7QGLeQQrkbf5dGAV6dyB9b5zH2OLGWVHN9Jj1gku9bqTN1w6HBpRlglReaHFKf4vFauZvFqEwOnAji8B4zxKtbYzEw1KqRr0JwbY)vcrOnAjiYHzoQjHwJqHiRlFxBkeH2OLGihM5SWyPaxChHcrwx(U2uisGq7AuoBLd15WmhxcWRwUerQJKNR(iqomZrG1i55QpcejqODnkhgZPi5qvoboNajNLBn0kSICHw4zTLE42ZwAecwbV6vplGqqVaKpiFau7dYZAl9WTNDH7f0kXuqu)sle8SqB0sq43WR(a20hKNfAJwcc)gE2f5uGCMNva0V)pYdAbOQfFU5Wmh(YH)CutcTgvCH3QslnbeH2OLGihNoZra0V)pQ4cVvLwAci(CZHzolCinU6IVwrrb8V1P5S1EouNJtN5ia63)h5bTau1Iei0UgLZw75qnxZH7CC6mh9cHQIRIdYzR9COMREwBPhU9S0smwuX)QYbQqdHf4vFaoWhKN1w6HBpB5ZiIZ6k(xngaeSYXZcTrlbHFdV6diW(G8SqB0sq43WZUiNcKZ8SixqkRQrkbff)wxX)kL9Xdq5W4EoBMJtN5qStubEqRrtiqXRZHXCkAUMdZCGgiLfKZw5WW4QN1w6HBp7hVEiqungaKtHknyHE1hqr8b5zH2OLGWVHNDrofiN5zrUGuwvJuckk(TUI)vk7JhGYHX9C2mhNoZHyNOc8GwJMqGIxNdJ5u0C1ZAl9WTN19rUFbxxwPLgs9QpGI2hKNfAJwcc)gE2f5uGCMNL(9)rcSOuciu9Jjli(CZXPZCOF)FKalkLacv)yYcQl8RvGerQTOmNTYHAU6zTLE42ZQCG6RPXVwu)yYc8QpagMpipRT0d3EwY56kH61vKRTapl0gTee(n8QpGIQpipl0gTee(n8SlYPa5mpl97)JY7d0smwerQTOmNTYXbEwBPhU9SfJjsbp46kbq426f4vFaBRpipl0gTee(n8SlYPa5mpl0aPSGC2kNIW1CyMd)5SWyPaxCh5bTau1IpxpRT0d3E2qietkOI)v5BDIQGawiYRE1ZkGV9KQpiFau7dYZcTrlbHFdp7ICkqoZZYFoifmPYbertk9S2spC7zP8wu6vFaB6dYZAl9WTNfPGjvoEwOnAji8B4vFaoWhKNfAJwcc)gEwSRNfbQN1w6HBplpJCgTe8S8m5d8SqdKYcIeOe6COkhx8HWniQ0saeOCcKCyy5S9oh(YzZCcKCqUGuw5yifYHBplpJuBle8SqdKYcQeOe66chsFni8QpGa7dYZcTrlbHFdpl21ZIa1ZAl9WTNLNroJwcEwEM8bEwKliLv1iLGIIFRR4FLY(4bOC2kNn9S8msTTqWZIUUucv1iLG6vFafXhKNfAJwcc)gEwBPhU9SgdqCmIHQFCRv8V6IlgiE2f5uGCMNL)CqkysLdiIMuMdZCcnKcKQHqgcDDLaH21OC2ZHR5WmNfglf4I7ipOfGQwKaH21OC2khQ5AomZH)Cea97)J8GwaQAXNBomZH)Cea97)JkUWBvPLMaIpxpBBHGN1yaIJrmu9JBTI)vxCXaXR(akAFqEwOnAji8B4zxKtbYzEwKcMu5aIibx(apRT0d3E2LjLvBPhURYdPEw5H0ABHGNfPGjvoGWR(ayy(G8SqB0sq43WZUiNcKZ8S8Ld)5OMeAngAifivdHme66i0gTee540zocSglncbRquVfLxxMd35Wmh(YH)CGavENRliIgdqCmIHQFCRv8V6Ilgi540zo8NZcJLcCXDuAk0A1ilRT4ZnhU9S2spC7zxMuwTLE4UkpK6zLhsRTfcE2La5vFafvFqEwOnAji8B4zTLE42ZUmPSAl9WDvEi1ZkpKwBle8ScS6vFaBRpipl0gTee(n8S2spC7zxMuwTLE4UkpK6zLhsRTfcEwXrGL6vFauZvFqEwOnAji8B4zxKtbYzEwObszbrb8V1P5W4EouxKCOkhEg5mAjeHgiLfujqj01foK(Aq4zTLE42ZAKL1qvXec0Qx9bqn1(G8S2spC7znYYAO6(KiWZcTrlbHFdV6dG6n9b5zTLE42ZkVsokQYq9jkdHw9SqB0sq43WRE1Z6sGfoK2uFq(aO2hKN1w6HBpR56klO6IpeU9SqB0sq43WR(a20hKN1w6HBpRlwpC7zH2OLGWVHx9b4aFqEwOnAji8B4zTLE42ZgAekbr9Jjvbykhp7ICkqoZZsStubEqRrtiqXRZHXCOUiEwxcSWH0MwrWc3cKNTiE1hqG9b5zTLE42ZIuWKkhpl0gTee(n8QpGI4dYZcTrlbHFdpBBHGN1yaIJrmu9JBTI)vxCXaXZAl9WTN1yaIJrmu9JBTI)vxCXaXRE1ZkocSuFq(aO2hKNfAJwcc)gE2f5uGCMNDHdPXvx81kkhg3ZjW5qvoQjHwJcaCbsfPetTsimcTrlbromZHVCea97)J8GwaQAXNBooDMJaOF)FuXfERkT0eq85MJtN5anqklikG)TonNT2ZHVCGMh04WQlglRkhcG4GLICyC7ph(YzZIKdv5WZiNrlHi0aPSGkbkHUUWH0xdIC4ohUZXPZC4phEg5mAjerxxkHQAKsqZH7CyMdF5WFoQjHwJqHiRlFxBkeH2OLGihNoZzHXsbU4ocfISU8DTPqKaH21OCymNnZHBpRT0d3EwO5bno0R(a20hKNfAJwcc)gEwSRNfbQN1w6HBplpJCgTe8S8m5d8SlCinU6IVwrrb8V1P5WyouNJtN5anqklikG)TonNT2ZzZIKdv5WZiNrlHi0aPSGkbkHUUWH0xdICC6mh(ZHNroJwcr01LsOQgPeuplpJuBle8Speu)NuceV6dWb(G8SqB0sq43WZUiNcKZ8S8mYz0si(qq9FsjqYHzogdaYPqewCWxxwPLMaqrOnAjiYHzoixqkRQrkbff)wxX)kL9Xdq5W4EoB6zTLE42Z(TUI)vk7JhG8QpGa7dYZcTrlbHFdp7ICkqoZZYZiNrlH4db1)jLajhM5Wxo0V)pY5ecOR0staOisTfL5W4EouVT540zo8Ld)54som50cQeSA6H7CyMdYfKYQAKsqrXV1v8VszF8auomUNtGZHQC4lhJba5uikWpAjufyeejwtzomMZM5WDouLdsbtQCarKGlFqoCNd3EwBPhU9SFRR4FLY(4biV6dOi(G8SqB0sq43WZAl9WTN9BDf)Ru2hpa5zxKtbYzEwEg5mAjeFiO(pPei5WmhKliLv1iLGIIFRR4FLY(4bOCyCphh4zxfSKqvnsjOiFau7vFafTpipl0gTee(n8SlYPa5mplpJCgTeIpeu)NucKCyMdF5q)()iT8Ab6eq85MJtN5WFoQjHwJ8GghwjpeNi0gTee5Wmh(ZXyaqofIc8JwcvbgbrOnAjiYHBpRT0d3EwA51c0jaV6dGH5dYZcTrlbHFdpRT0d3E2WNEstbp7ICkqoZZYZiNrlH4db1)jLajhM5GCbPSQgPeuu8BDf)Ru2hpaLZEoB6zxfSKqvnsjOiFau7vFafvFqEwOnAji8B4zxKtbYzEwEg5mAjeFiO(pPeiEwBPhU9SHp9KMcE1RE2La5dYha1(G8SqB0sq43WZUiNcKZ8S8NdsbtQCar0KYCyMJaRrYZvFeiQ3IYRlZHzoHgsbs1qidHUUsGq7Auo75WvpRT0d3E2LjLvBPhURYdPEw5H0ABHGNfqiOxaYR(a20hKNfAJwcc)gEwBPhU9SHgHsqu)ysvaMYXZUiNcKZ8Se7evGh0A0ecu85MdZC4lh1iLGg1leQkUkoiNTYzHdPXvx81kkkG)TonNajhQJfjhNoZzHdPXvx81kkkG)Tonhg3Zz5wdTcRixOf5WTNDvWscv1iLGI8bqTx9b4aFqEwOnAji8B4zxKtbYzEwIDIkWdAnAcbkEDomMJd4AoCroe7evGh0A0ecuu8iME4ohM5SWH04Ql(AfffW)wNMdJ75SCRHwHvKl0cpRT0d3E2qJqjiQFmPkat54vFab2hKNfAJwcc)gE2f5uGCMNL)CqkysLdiIeC5dYHzocSgjpx9rGOElkVUmhM5WFocG(9)rEqlavT4ZnhM5Wxo8NJAsO1i6rRa5)kHi0gTee540zo8NJXaGCkerCi4Naev07)XltpChH2OLGihNoZrG1yPriyfIUHpPEUYdi5WyouNdZC4lhKliLv1iLGIIFRR4FLY(4bOC2kNIohNoZH)CwySuGlUJ8S(qCIp3C4ohUZHzo8Ld)5OMeAn2xjhfPMKsGeH2OLGihNoZH)CutcTgHcrwx(U2uicTrlbrooDMZcJLcCXDekezD57AtHibcTRr5SvofjhUiNnZjqYrnj0AuaGlqQiLyQvcHrOnAjiYHBpRT0d3EwEqlavnV6dOi(G8SqB0sq43WZUiNcKZ8SQjHwJqHiRlFxBkeH2OLGihM5WxoQjHwJ9vYrrQjPeirOnAjiYXPZCutcTgrpAfi)xjeH2OLGihM5WZiNrlHi66sjuvJucAoCNdZCw4qAC1fFTIYHX9CwU1qRWkYfAromZzHXsbU4ocfISU8DTPqKaH21OC2khQZHzo8Ld)5OMeAnIE0kq(VsicTrlbrooDMd)5ymaiNcrehc(jarf9(F8Y0d3rOnAjiYXPZCeynwAecwHOB4tQNR8asoBTNd15WTN1w6HBplpRpehV6dOO9b5zH2OLGWVHNDrofiN5zvtcTg7RKJIutsjqIqB0sqKdZC4ph1KqRrOqK1LVRnfIqB0sqKdZCw4qAC1fFTIYHX9CwU1qRWkYfAromZra0V)pYdAbOQfFUEwBPhU9S8S(qC8QpagMpipl0gTee(n8SyxplcupRT0d3EwEg5mAj4z5zYh4zngaKtHiIdb)eGOIE)pEz6H7i0gTee5Wmh(YPXDfHQ0V)hev1iLGIYHX9COohNoZb5cszvnsjOO436k(xPSpEakN9CCqoCNdZC4lheQs)(FquvJuckQA0yEq11AbeERC2ZHR540zoixqkRQrkbff)wxX)kL9Xdq5W4EofDoC7z5zKABHGNfHQ8S(qCQlClo9WTx9buu9b5zH2OLGWVHN1w6HBpRlglReaHFKf4zHcvIvTq8RvpBGlIN9Jj1gku9bqTx9bST(G8SqB0sq43WZUiNcKZ8SQjHwJOhTcK)ReIqB0sqKdZC4phKcMu5aIibx(GCyMZcJLcCXDS0ieScXNBomZHVC4zKZOLqeHQ8S(qCQlClo9WDooDMd)5ymaiNcrehc(jarf9(F8Y0d3rOnAjiYHzocSglncbRqKaFcG4y0sihUZHzolCinU6IVwrrb8V1P5W4Eo8LdF5qDouLZM5ei5ymaiNcrehc(jarf9(F8Y0d3rOnAjiYH7CcKCqUGuwvJuckk(TUI)vk7JhGYH7CyC7pNaNdZCi2jQapO1OjeO415WyouVPN1w6HBplpRpehV6dGAU6dYZcTrlbHFdp7ICkqoZZQMeAngAifivdHme66i0gTee5Wmh(ZbPGjvoGiAszomZj0qkqQgczi01vceAxJYzR9C4AomZH)CeynsEU6Jarc8jaIJrlHCyMJaRXsJqWkejqODnkhgZXb5Wmh(YH)Caec6fePLySOI)vLduHgcligAmuXKCC6mhbq)()iTeJfv8VQCGk0qybXNBoC7zTLE42ZYZ6dXXR(aOMAFqEwOnAji8B4zxKtbYzEw(ZbPGjvoGiAszomZXyaqofIioe8taIk69)4LPhUJqB0sqKdZCeynwAecwHib(eaXXOLqomZrG1yPriyfIUHpPEUYdi5S1EouNdZCw4qAC1fFTIIc4FRtZHX9CO2ZAl9WTNfXXe4IdbPWR(aOEtFqEwOnAji8B4zxKtbYzEwbwJKNR(iqKaH21OCymNaNdv5e4CcKCwU1qRWkYfAromZH)CeynwAecwHib(eaXXOLGN1w6HBpluiY6Y31McE1ha1oWhKNfAJwcc)gE2f5uGCMNvG1i55Qpce1Br51LEwBPhU9SkUWBvPLMa8QpaQdSpipl0gTee(n8SlYPa5mpl97)J0smwiFinsaBP540zocG(9)rEqlavT4Z1ZAl9WTN1fRhU9QpaQlIpipl0gTee(n8SlYPa5mpRaOF)FKh0cqvl(C9S2spC7zPLySO(FKc8QpaQlAFqEwOnAji8B4zxKtbYzEwbq)()ipOfGQw856zTLE42ZsdeeqO86sV6dGAgMpipl0gTee(n8SlYPa5mpRaOF)FKh0cqvl(C9S2spC7z)hbOLySWR(aOUO6dYZcTrlbHFdp7ICkqoZZka63)h5bTau1IpxpRT0d3EwRxasjMSUmP0R(aOEB9b5zH2OLGWVHN1w6HBpBPjHLjLabvPX42ZUiNcKZ8SlmwkWf3rEqlavTibcTRr5WyobUiE22cbpBPjHLjLabvPX42R(a2KR(G8SqB0sq43WZAl9WTN1qC4znGQeJbysDHjM0ZUiNcKZ8ScG(9)rIXamPUWetwfa97)JcCXDooDMJaOF)FKh0cqvlsGq7AuomMd1CnhNoZrVqOQ4Q4GC2kNn5AouLZcJLcCXDuAk0A1ilRTibcTRrE22cbpRH4WZAavjgdWK6ctmPx9bSj1(G8SqB0sq43WZAl9WTNv(iuceu9A0jo8dvlVV6zxKtbYzEwbq)()ipOfGQw856zBle8SYhHsGGQxJoXHFOA59vV6dyZn9b5zH2OLGWVHN1w6HBpR8Huc(HQLyPa6QR8fALGNDrofiN5zfa97)J8GwaQAXNRNTTqWZkFiLGFOAjwkGU6kFHwj4vFaB6aFqEwOnAji8B4zTLE42ZwknXzkMGQHGWKYd3E2f5uGCMNva0V)pYdAbOQfFUEw4)HLwBle8SLstCMIjOAiimP8WTx9bSzG9b5zH2OLGWVHN1w6HBpBP0eNPycQsBIsWZUiNcKZ8ScG(9)rEqlavT4Z1Zc)pS0ABHGNTuAIZumbvPnrj4vFaBweFqEwOnAji8B4zTLE42Z6Ixuck6yaiQlCO7tn9WDva8Uf4zxKtbYzE2qdPaPAiKHqxxjqODnkN9C4AomZH)Cea97)J8GwaQAXNBomZH)Cea97)JkUWBvPLMaIp3CyMd97)JHqiMuqf)RY36evbbSquuGlUZHzoqdKYcYzRCkQCnhM5iWAK8C1hbIei0UgLdJ5eypl8)WsRTfcE2vbljwj4(wvAPHuV6dyZI2hKN1w6HBp7db1tHqKNfAJwcc)gE1REwbw9b5dGAFqEwOnAji8B4zXUEweOEwBPhU9S8mYz0sWZYZKpWZ6som50cQeSA6H7CyMdYfKYQAKsqrXV1v8VszF8auomMJdYHzo8LJaRXsJqWkejqODnkNTYzHXsbU4owAecwHO4rm9WDooDMJl(q4gevAjacuomMtrYHBplpJuBle8Sikp36QGLeQLgHGvWR(a20hKNfAJwcc)gEwSRNfbQN1w6HBplpJCgTe8S8m5d8SUKdtoTGkbRME4ohM5GCbPSQgPeuu8BDf)Ru2hpaLdJ54GCyMdF5ia63)hvCH3QslnbeFU540zo8LJl(q4gevAjacuomMtrYHzo8NJXaGCkerlO1k(xPLySicTrlbroCNd3EwEgP2wi4zruEU1vbljujpx9raV6dWb(G8SqB0sq43WZID9Siq9S2spC7z5zKZOLGNLNjFGNva0V)pYdAbOQfFU5Wmh(Yra0V)pQ4cVvLwAci(CZXPZCcnKcKQHqgcDDLaH21OCymhUMd35WmhbwJKNR(iqKaH21OCymNn9S8msTTqWZIO8CRKNR(iGx9beyFqEwOnAji8B4zxKtbYzEw1KqRrOqK1LVRnfIqB0sqKdZC4lh(YzHdPXvx81kkhg3Zz5wdTcRixOf5WmNfglf4I7iuiY6Y31McrceAxJYzRCOohUZXPZC4lh(ZrVfLxxMdZC4lh9cHCymhQ5AooDMZchsJRU4RvuomUNZM5WDoCNd3EwBPhU9SKNR(iGx9bueFqEwOnAji8B4z)ysTHcvFau7zTLE42Z6IXYkbq4hzbE1hqr7dYZcTrlbHFdp7ICkqoZZYxo8NJAsO1i6rRa5)kHi0gTee540zo8NdF5SWyPaxCh5z9H4eFU5WmNfglf4I7ipOfGQwKaH21OC2ApNaNd35WDomZzHdPXvx81kkkG)Tonhg3ZH6COkhhKtGKdF5ymaiNcrehc(jarf9(F8Y0d3rOnAjiYHzolmwkWf3rEwFioXNBoCNdZCiWNaiogTeYHzo8LJB4tQNR8asoBTNd1540zoei0UgLZw75O3IYQEHqomZb5cszvnsjOO436k(xPSpEakhg3ZXb5qvogdaYPqeXHGFcqurV)hVm9WDeAJwcIC4ohM5Wxo8NduiY6Y31McICC6mhceAxJYzR9C0BrzvVqiNajNnZHzoixqkRQrkbff)wxX)kL9Xdq5W4EooihQYXyaqofIioe8taIk69)4LPhUJqB0sqKd35Wmh(ZbHQ0V)he5Wmh(YrnsjOr9cHQIRIdYHlYHaH21OC4ohgZjW5Wmh(Yj0qkqQgczi01vceAxJYzphUMJtN5WFo6TO86YCyMJXaGCkerCi4Naev07)XltpChH2OLGihU9S2spC7zlncbRGx9bWW8b5zH2OLGWVHN9Jj1gku9bqTN1w6HBpRlglReaHFKf4vFafvFqEwOnAji8B4zTLE42ZwAecwbp7ICkqoZZYFo8mYz0siIO8CRRcwsOwAecwHCyMdF5WFoQjHwJOhTcK)ReIqB0sqKJtN5WFo8LZcJLcCXDKN1hIt85MdZCwySuGlUJ8GwaQArceAxJYzR9CcCoCNd35WmNfoKgxDXxROOa(360CyCphQZHQCCqobso8LJXaGCkerCi4Naev07)XltpChH2OLGihM5SWyPaxCh5z9H4eFU5WDomZHaFcG4y0sihM5WxoUHpPEUYdi5S1EouNJtN5qGq7AuoBTNJElkR6fc5WmhKliLv1iLGIIFRR4FLY(4bOCyCphhKdv5ymaiNcrehc(jarf9(F8Y0d3rOnAjiYH7CyMdF5WFoqHiRlFxBkiYXPZCiqODnkNT2ZrVfLv9cHCcKC2mhM5GCbPSQgPeuu8BDf)Ru2hpaLdJ754GCOkhJba5uiI4qWpbiQO3)JxME4ocTrlbroCNdZC4pheQs)(FqKdZC4lh1iLGg1leQkUkoihUihceAxJYH7CymhQ3mhM5WxoHgsbs1qidHUUsGq7Auo75W1CC6mh(ZrVfLxxMdZCmgaKtHiIdb)eGOIE)pEz6H7i0gTee5WTNDvWscv1iLGI8bqTx9bST(G8SqB0sq43WZUiNcKZ8SixqkRQrkbfLdJ75SzomZHaH21OC2kNnZHQC4lhKliLv1iLGIYHX9CksoCNdZCw4qAC1fFTIYHX9CcSN1w6HBp7ICHiCxvi0fqQx9bqnx9b5zH2OLGWVHNDrofiN5z5phEg5mAjeruEUvYZvFeihM5SWH04Ql(AfLdJ75e4CyMdb(eaXXOLqomZHVCCdFs9CLhqYzR9COohNoZHaH21OC2Aph9wuw1leYHzoixqkRQrkbff)wxX)kL9Xdq5W4EooihQYXyaqofIioe8taIk69)4LPhUJqB0sqKd35Wmh(YH)CGcrwx(U2uqKJtN5qGq7AuoBTNJElkR6fc5ei5SzomZb5cszvnsjOO436k(xPSpEakhg3ZXb5qvogdaYPqeXHGFcqurV)hVm9WDeAJwcIC4ohM5OgPe0OEHqvXvXb5Wf5qGq7AuomMtG9S2spC7zjpx9raV6dGAQ9b5zH2OLGWVHN1w6HBpl55Qpc4zxKtbYzEw(ZHNroJwcreLNBDvWscvYZvFeihM5WFo8mYz0siIO8CRKNR(iqomZzHdPXvx81kkhg3ZjW5Wmhc8jaIJrlHCyMdF54g(K65kpGKZw75qDooDMdbcTRr5S1Eo6TOSQxiKdZCqUGuwvJuckk(TUI)vk7JhGYHX9CCqouLJXaGCkerCi4Naev07)XltpChH2OLGihUZHzo8Ld)5afISU8DTPGihNoZHaH21OC2Aph9wuw1leYjqYzZCyMdYfKYQAKsqrXV1v8VszF8auomUNJdYHQCmgaKtHiIdb)eGOIE)pEz6H7i0gTee5WDomZrnsjOr9cHQIRIdYHlYHaH21OCymNa7zxfSKqvnsjOiFau7vV6vplpGGoC7dytUs92Yvg2Mf14MC1bfXZwSr6RlrEwUSqxmrbromSCSLE4oh5HuumPWZICHLpGnlY26zDj4)jbpRdZz7qidHU20d35Sn4YhKu4WC4OQlIHeCWLNY5rhx4WGrx4tA6H7fX(AWOlCfCsHdZHINSGC2CBDmNn5k1BBoCrou7agIdkssrsHdZHlXX6saXqskCyoCroBNqaIC2EUfL5O4CeW3EsnhBPhUZrEinMu4WC4IC2gieZdYrnsjO17htkCyoCroBNqaIC2(qqoCzkeIYHp8trNaYb)ZbPGjvoChtkskCyom8cH1tbro0WhtGCw4qAtZHgkVgfZz7wlWvr504Ml4yKW)tMJT0d3OCWTSGysHdZXw6HBu0LalCiTP7FPHOmPWH5yl9Wnk6sGfoK2uQ2d2ELHqRME4oPWH5yl9Wnk6sGfoK2uQ2d(JXIKchMdBBUioynhIDICOF)piYbPMIYHg(ycKZchsBAo0q51OCSwKJlb4cxSQxxMZHYrGBiMu4WCSLE4gfDjWchsBkv7bJAZfXbRvKAkkPWw6HBu0LalCiTPuThS56klO6IpeUtkSLE4gfDjWchsBkv7b7I1d3jf2spCJIUeyHdPnLQ9GdncLGO(XKQamLJJUeyHdPnTIGfUfO9I4493j2jQapO1OjeO41msDrskSLE4gfDjWchsBkv7bJuWKkNKcBPhUrrxcSWH0Ms1EWpeupfcDSTqy3yaIJrmu9JBTI)vxCXajPiPWH5WWlewpfe5a8asb5OxiKJYbYXwkMKZHYX4zN0OLqmPWH5SnasbtQCY5(54IrOJwc5WxJZH3t2aXOLqoqdHhGY56Cw4qAt5oPWw6HB0oL3IshV)o)ifmPYbertktkSLE4gr1EWifmPYjPWw6HBev7bZZiNrlbhBle2HgiLfujqj01foK(Aq4ipt(GDObszbrcucnvU4dHBquPLaiqbcdB7nFBgiixqkRCmKcCNuyl9WnIQ9G5zKZOLGJTfc7ORlLqvnsjOoYZKpyh5cszvnsjOO436k(xPSpEaARntkSLE4gr1EWpeupfcDSTqy3yaIJrmu9JBTI)vxCXaXX7VZpsbtQCar0KsMHgsbs1qidHUUsGq7A0oxzUWyPaxCh5bTau1Iei0UgTf1CLj)cG(9)rEqlavT4ZLj)cG(9)rfx4TQ0staXNBsHT0d3iQ2dEzsz1w6H7Q8qQJTfc7ifmPYbeoE)DKcMu5aIibx(GKcBPhUruTh8YKYQT0d3v5HuhBle2xcKJ3FNp(vtcTgdnKcKQHqgcDDeAJwccNofynwAecwHOElkVUKBM8XpeOY7CDbr0yaIJrmu9JBTI)vxCXaXPt(xySuGlUJstHwRgzzTfFUCNuyl9WnIQ9GxMuwTLE4UkpK6yBHWUaRjf2spCJOAp4LjLvBPhURYdPo2wiSlocS0KcBPhUruThSrwwdvftiqRoE)DObszbrb8V1PmUtDrOINroJwcrObszbvcucDDHdPVgejf2spCJOApyJSSgQUpjcskSLE4gr1EWYRKJIQmuFIYqO1KIKchMdxcJLcCXnkPWw6HBuCjq7ltkR2spCxLhsDSTqyhqiOxaYX7VZpsbtQCar0KsMcSgjpx9rGOElkVUKzOHuGuneYqORRei0UgTZ1KchMdx2phtiq5yeiNNRJ5G6ZfYr5a5GBiNIpLtosCXasZjOGkkXC2(qqofZb6CefCDzoFdPajhLJ15WLc05iG)TonhmjNIpLd(P5yDb5WLc0XKcBPhUrXLar1EWHgHsqu)ysvaMYXXvbljuvJuckANAhV)oXorf4bTgnHafFUm5tnsjOr9cHQIRId2AHdPXvx81kkkG)TonqOoweNox4qAC1fFTIIc4FRtzCF5wdTcRixOfCNu4WC4Y(504CmHaLtXNuMJ4GCk(uoxNJYbYPHc1CCaxroMZdb5eO8lk5G7COXiuofFkh8tZX6cYHlfOJjf2spCJIlbIQ9GdncLGO(XKQamLJJ3FNyNOc8GwJMqGIxZOd4kxqStubEqRrtiqrXJy6HBMlCinU6IVwrrb8V1PmUVCRHwHvKl0IKcBPhUrXLar1EW8GwaQAoE)D(rkysLdiIeC5dykWAK8C1hbI6TO86sM8la63)h5bTau1IpxM8XVAsO1i6rRa5)kHi0gTeeoDYVXaGCkerCi4Naev07)XltpChH2OLGWPtbwJLgHGvi6g(K65kpGWi1m5d5cszvnsjOO436k(xPSpEaARI2Pt(xySuGlUJ8S(qCIpxU5MjF8RMeAn2xjhfPMKsGeH2OLGWPt(vtcTgHcrwx(U2uicTrlbHtNlmwkWf3rOqK1LVRnfIei0UgTvr4Inde1KqRrbaUaPIuIPwjegH2OLGG7KchMddT1hItofFkNCy4fIkZHQC4lGRKJIutsjqCmhmjh2hTcK)ReYb3YcYb35qDqCZqYjqXk8cFH5WLc05yTihgEHOYCiGjkiNpMKtdfQ5WLZLkkjf2spCJIlbIQ9G5z9H44493vtcTgHcrwx(U2uicTrlbbt(utcTg7RKJIutsjqIqB0sq40PAsO1i6rRa5)kHi0gTeem5zKZOLqeDDPeQQrkbLBMlCinU6IVwrmUVCRHwHvKl0cMlmwkWf3rOqK1LVRnfIei0UgTf1m5JF1KqRr0JwbY)vcrOnAjiC6KFJba5uiI4qWpbiQO3)JxME4ocTrlbHtNcSglncbRq0n8j1ZvEazRDQ5oPWH5WqB9H4KtXNYjNaUsoksnjLajhQYjaCom8crLmKCcuScVWxyoCPaDowlYHHgAbOQLZZnPWw6HBuCjquThmpRpehhV)UAsO1yFLCuKAskbseAJwccM8RMeAncfISU8DTPqeAJwccMlCinU6IVwrmUVCRHwHvKl0cMcG(9)rEqlavT4ZnPWH5Wcqo)NuMZchgcTMdUZHJQUigsWbxEkNhDCHddEBmEqZblfkxeexk4Tbx(GGl(O8cE7qidHU20d3CX2fOzOWfBdGaJS4etkSLE4gfxcev7bZZiNrlbhBle2rOkpRpeN6c3ItpC7ipt(GDJba5uiI4qWpbiQO3)JxME4ocTrlbbt(ACxrOk97)brvnsjOig3P2PtKliLv1iLGIIFRR4FLY(4bODhWnt(qOk97)brvnsjOOQrJ5bvxRfq4T25QtNixqkRQrkbff)wxX)kL9XdqmUx0CNuyl9WnkUeiQ2d2fJLvcGWpYcC8Jj1gku3P2rOqLyvle)ADpWfjPWw6HBuCjquThmpRpehhV)UAsO1i6rRa5)kHi0gTeem5hPGjvoGisWLpG5cJLcCXDS0ieScXNlt(4zKZOLqeHQ8S(qCQlClo9WTtN8BmaiNcrehc(jarf9(F8Y0d3rOnAjiykWAS0ieScrc8jaIJrlbUzUWH04Ql(AfffW)wNY4oF8rnvBgigdaYPqeXHGFcqurV)hVm9WDeAJwccUdeKliLv1iLGIIFRR4FLY(4biUzC7pWmj2jQapO1OjeO41ms9MjfomhgARpeNCk(uo5eOyifi5SDiKHUMHKta4CqkysLtowlYPX5yl94b5eOSD5q)(FhZzBEU6Ja50ynNRZHaFcG4KdX6sWXCepY1L5SHeJf5aie0miN7NJXZoPrlHysHT0d3O4sGOApyEwFiooE)D1KqRXqdPaPAiKHqxhH2OLGGj)ifmPYbertkzgAifivdHme66kbcTRrBTZvM8lWAK8C1hbIe4taehJwcmfynwAecwHibcTRrm6aM8XpGqqVGiTeJfv8VQCGk0qybXqJHkM40PaOF)FKwIXIk(xvoqfAiSG4ZL7KchMdlhtGloeKIC(ysoSCi4Nae5W((F8Y0d3jf2spCJIlbIQ9GrCmbU4qqkC8(78JuWKkhqenPKPXaGCkerCi4Naev07)XltpChH2OLGGPaRXsJqWkejWNaiogTeykWAS0ieScr3WNupx5bKT2PM5chsJRU4Rvuua)BDkJ7uNu4WCy4fISU8DTPqofZb6COXkNC2MNR(iqowlYHl3ieSc5yeiNNBoFmjhjUlZbA8RKtsHT0d3O4sGOApyOqK1LVRnfC8(7cSgjpx9rGibcTRrmgyQcCGSCRHwHvKl0cM8lWAS0ieScrc8jaIJrlHKcBPhUrXLar1EWkUWBvPLMaC8(7cSgjpx9rGOElkVUmPWw6HBuCjquThSlwpC7493PF)FKwIXc5dPrcyl1Ptbq)()ipOfGQw85Muyl9WnkUeiQ2dMwIXI6)rkWX7Vla63)h5bTau1Ip3KcBPhUrXLar1EW0abbekVU0X7Vla63)h5bTau1Ip3KcBPhUrXLar1EW)Ja0smw4493fa97)J8GwaQAXNBsHT0d3O4sGOApyRxasjMSUmP0X7Vla63)h5bTau1Ip3KcBPhUrXLar1EWpeupfcDSTqyV0KWYKsGGQ0yC7493xySuGlUJ8GwaQArceAxJymWfjPWw6HBuCjquTh8db1tHqhBle2nehEwdOkXyaMuxyIjD8(7cG(9)rIXamPUWetwfa97)JcCXTtNcG(9)rEqlavTibcTRrmsnxD6uVqOQ4Q4GT2KRuTWyPaxChLMcTwnYYAlsGq7AusHT0d3O4sGOAp4hcQNcHo2wiSlFekbcQEn6eh(HQL3xD8(7cG(9)rEqlavT4ZnPWw6HBuCjquTh8db1tHqhBle2LpKsWpuTelfqxDLVqReC8(7cG(9)rEqlavT4ZnPWw6HBuCjquTh8db1tHqhH)hwATTqyVuAIZumbvdbHjLhUD8(7cG(9)rEqlavT4ZnPWw6HBuCjquTh8db1tHqhH)hwATTqyVuAIZumbvPnrj4493fa97)J8GwaQAXNBsHT0d3O4sGOAp4hcQNcHoc)pS0ABHW(QGLeReCFRkT0qQJ3Fp0qkqQgczi01vceAxJ25kt(fa97)J8GwaQAXNlt(fa97)JkUWBvPLMaIpxM0V)pgcHysbv8VkFRtufeWcrrbU4Mj0aPSGTkQCLPaRrYZvFeisGq7AeJboPWH5uuGV9KAoFtkPTfL58XKCEiJwc5CkeIyi5S9HGCWDolmwkWf3XKcBPhUrXLar1EWpeupfcrjfjfomNIYrGLMJWcTsihJ(KNEakPWH5WWBEqJdZX0Ccmv5WxrOkNIpLtoffwUZHlfOJ5WLfgcIZuqwqo4oNnPkh1iLGICmNIpLtom0qlavnhZbtYP4t5KtqBeOAoyLdqk(qqofBNMZhtYbHdHCGgiLfeZz7KiCofBNMZ9ZHHxiQmNfoKgNZHYzHdVUmNNBmPWw6HBuuCeyP7qZdACOJ3FFHdPXvx81kIX9atLAsO1OaaxGurkXuRecJqB0sqWKpbq)()ipOfGQw8560PaOF)FuXfERkT0eq8560j0aPSGOa(360T25dAEqJdRUySSQCiaIdwkyC7NVnlcv8mYz0sicnqklOsGsORlCi91GGBUD6KFEg5mAjerxxkHQAKsq5MjF8RMeAncfISU8DTPqeAJwccNoxySuGlUJqHiRlFxBkejqODnIXn5oPWw6HBuuCeyPuThmpJCgTeCSTqy)HG6)KsG4ipt(G9foKgxDXxROOa(36ugP2PtObszbrb8V1PBTVzrOINroJwcrObszbvcucDDHdPVgeoDYppJCgTeIORlLqvnsjOjfomNTxpLtom8fh81L5SH0eaYXCcuBDo4FoBp9Xdq5yAoBsvoQrkbfftkSLE4gffhbwkv7b)TUI)vk7JhGC8(78mYz0si(qq9FsjqyAmaiNcryXbFDzLwAcafH2OLGGjYfKYQAKsqrXV1v8VszF8aeJ7BMu4WCcuBDo4FoBp9Xdq5yAouVTuLdsTfLOCW)C2E5ecOZzdPjauoysowPDnsZjWuLdFfHQCk(uo5uuWpAjKtrbJaUZrnsjOOysHT0d3OO4iWsPAp4V1v8VszF8aKJ3FNNroJwcXhcQ)tkbct(OF)FKZjeqxPLMaqrKAlkzCN6T1Pt(43LCyYPfujy10d3mrUGuwvJuckk(TUI)vk7JhGyCpWuXNXaGCkef4hTeQcmcIeRPKXn5MkKcMu5aIibx(aU5oPWH5eO26CW)C2E6JhGYrX5yUUYcYPOaMqwqobA8HWDo3pNRTLE8GCWDowxqoQrkbnhtZXb5OgPeuumPWw6HBuuCeyPuTh836k(xPSpEaYXvbljuvJuckANAhV)opJCgTeIpeu)NuceMixqkRQrkbff)wxX)kL9XdqmU7GKcBPhUrrXrGLs1EW0YRfOtaoE)DEg5mAjeFiO(pPeim5J(9)rA51c0jG4Z1Pt(vtcTg5bnoSsEiorOnAjiyYVXaGCkef4hTeQcmcIqB0sqWDsHdZjiJMlcuE6jnfYrX5yUUYcYPOaMqwqobA8HWDoMMZM5OgPeuusHT0d3OO4iWsPAp4WNEstbhxfSKqvnsjOODQD8(78mYz0si(qq9FsjqyICbPSQgPeuu8BDf)Ru2hpaTVzsHT0d3OO4iWsPAp4WNEstbhV)opJCgTeIpeu)NucKKIKchMtrXcTsihmpGKJEHqog9jp9ausHdZHHYfEAoC5gHGvaLdUZPXnx4sUqIrkih1iLGIY5Jj5OCGCCjhMCAb5qWQPhUZ5(5ueQYHwcGaLJrGCmjbmrb58CtkSLE4gffyDNNroJwco2wiSJO8CRRcwsOwAecwbh5zYhS7som50cQeSA6HBMixqkRQrkbff)wxX)kL9Xdqm6aM8jWAS0ieScrceAxJ2AHXsbU4owAecwHO4rm9WTtNU4dHBquPLaiqmweUtkCyomuUWtZzBEU6JaOCWDonU5cxYfsmsb5OgPeuuoFmjhLdKJl5WKtlihcwn9WDo3pNIqvo0saeOCmcKJjjGjkiNNBsHT0d3OOaRuThmpJCgTeCSTqyhr55wxfSKqL8C1hbCKNjFWUl5WKtlOsWQPhUzICbPSQgPeuu8BDf)Ru2hpaXOdyYNaOF)FuXfERkT0eq8560jFU4dHBquPLaiqmweM8BmaiNcr0cATI)vAjglIqB0sqWn3jfomhgkx4P5Snpx9rauo3phgAOfGQgvbHl8w5SH0eqWbkgsbsoBhczi015COCEU5yTiNIHC4y8GC2KQCqWc3cuos4R5G7CuoqoBZZvFeiNIcoOKcBPhUrrbwPApyEg5mAj4yBHWoIYZTsEU6JaoYZKpyxa0V)pYdAbOQfFUm5ta0V)pQ4cVvLwAci(CD6m0qkqQgczi01vceAxJyKRCZuG1i55QpcejqODnIXntkCyoSUW6mzoBZZvFeiheOp3C(ysom8crLjf2spCJIcSs1EWKNR(iGJ3Fxnj0AekezD57AtHi0gTeem5JVfoKgxDXxRig3xU1qRWkYfAbZfglf4I7iuiY6Y31McrceAxJ2IAUD6Kp(1Br51Lm5tVqGrQ5QtNlCinU6IVwrmUVj3CZDsHdZHl3ieSc58CPeaxhZXKiCok5auokoNhcY50CmuowoixyDMmNsObIPysoFmjhLdKJ0qAoCPaDo0WhtGCSC(xFioajPWw6HBuuGvQ2d2fJLvcGWpYcC8Jj1gku3PoPWw6HBuuGvQ2dU0ieScoE)D(4xnj0Ae9OvG8FLqeAJwccNo5NVfglf4I7ipRpeN4ZL5cJLcCXDKh0cqvlsGq7A0w7bMBUzUWH04Ql(AfffW)wNY4o1u5GaHpJba5uiI4qWpbiQO3)JxME4ocTrlbbZfglf4I7ipRpeN4ZLBMe4taehJwcm5Zn8j1ZvEazRDQD6KaH21OT21BrzvVqGjYfKYQAKsqrXV1v8VszF8aeJ7oGkJba5uiI4qWpbiQO3)JxME4ocTrlbb3m5JFOqK1LVRnfeoDsGq7A0w76TOSQxieiBYe5cszvnsjOO436k(xPSpEaIXDhqLXaGCkerCi4Naev07)XltpChH2OLGGBM8Jqv63)dcM8PgPe0OEHqvXvXbCbbcTRrCZyGzYxOHuGuneYqORRei0UgTZvNo5xVfLxxY0yaqofIioe8taIk69)4LPhUJqB0sqWDsHT0d3OOaRuThSlglReaHFKf44htQnuOUtDsHT0d3OOaRuThCPriyfCCvWscv1iLGI2P2X7VZppJCgTeIikp36QGLeQLgHGvGjF8RMeAnIE0kq(VsicTrlbHtN8Z3cJLcCXDKN1hIt85YCHXsbU4oYdAbOQfjqODnAR9aZn3mx4qAC1fFTIIc4FRtzCNAQCqGWNXaGCkerCi4Naev07)XltpChH2OLGG5cJLcCXDKN1hIt85Yntc8jaIJrlbM85g(K65kpGS1o1oDsGq7A0w76TOSQxiWe5cszvnsjOO436k(xPSpEaIXDhqLXaGCkerCi4Naev07)XltpChH2OLGGBM8XpuiY6Y31MccNojqODnARD9wuw1lecKnzICbPSQgPeuu8BDf)Ru2hpaX4UdOYyaqofIioe8taIk69)4LPhUJqB0sqWnt(rOk97)bbt(uJucAuVqOQ4Q4aUGaH21iUzK6nzYxOHuGuneYqORRei0UgTZvNo5xVfLxxY0yaqofIioe8taIk69)4LPhUJqB0sqWDsHdZHlrUqeUZjii0fqAo4wwqo4oNWNupxjKJAKsqr5yAobMQC4sb6CkMd05qEDFDzo4NMZ15Sjkh(EU5O4CcCoQrkbfXDoysooaLdFfHQCuJuckI7KcBPhUrrbwPAp4f5cr4UQqOlGuhV)oYfKYQAKsqrmUVjtceAxJ2AtQ4d5cszvnsjOig3lc3mx4qAC1fFTIyCpWjfomNThaCZ55MZ28C1hbYX0Ccmv5G7CmPmh1iLGIYHVI5aDoYJ31L5iXDzoqJFLCYXAronwZb1MlIdw5oPWw6HBuuGvQ2dM8C1hbC8(78ZZiNrlHiIYZTsEU6Jamx4qAC1fFTIyCpWmjWNaiogTeyYNB4tQNR8aYw7u70jbcTRrBTR3IYQEHatKliLv1iLGIIFRR4FLY(4big3DavgdaYPqeXHGFcqurV)hVm9WDeAJwccUzYh)qHiRlFxBkiC6KaH21OT21BrzvVqiq2KjYfKYQAKsqrXV1v8VszF8aeJ7oGkJba5uiI4qWpbiQO3)JxME4ocTrlbb3mvJucAuVqOQ4Q4aUGaH21igdCsHT0d3OOaRuThm55Qpc44QGLeQQrkbfTtTJ3FNFEg5mAjeruEU1vbljujpx9raM8ZZiNrlHiIYZTsEU6Jamx4qAC1fFTIyCpWmjWNaiogTeyYNB4tQNR8aYw7u70jbcTRrBTR3IYQEHatKliLv1iLGIIFRR4FLY(4big3DavgdaYPqeXHGFcqurV)hVm9WDeAJwccUzYh)qHiRlFxBkiC6KaH21OT21BrzvVqiq2KjYfKYQAKsqrXV1v8VszF8aeJ7oGkJba5uiI4qWpbiQO3)JxME4ocTrlbb3mvJucAuVqOQ4Q4aUGaH21igdCsrsHdZHHJqqVausHT0d3OiGqqVa0(c3lOvIPGO(LwiKu4WC2ozXwbOCEiiNnKySiNIpLtom0qlavTCEUXC2ojcNZdb5u8PCYjOnY55Mdn8XeihlN)1hIdqYHV7NJAsOvqWDogkhjUlZXq5CAoKxJY5Jj5qnxr5iEKRlZHHgAbOQftkSLE4gfbec6fGOApyAjglQ4Fv5avOHWcC8(7cG(9)rEqlavT4ZLjF8RMeAnQ4cVvLwAcicTrlbHtNcG(9)rfx4TQ0staXNlZfoKgxDXxROOa(360T2P2Ptbq)()ipOfGQwKaH21OT2PMRC70PEHqvXvXbBTtnxtkSLE4gfbec6fGOAp4YNreN1v8VAmaiyLtsHT0d3OiGqqVaev7b)XRhcevJba5uOsdwOJ3Fh5cszvnsjOO436k(xPSpEaIX9nD6KyNOc8GwJMqGIxZyrZvMqdKYc2IHX1KcBPhUrraHGEbiQ2d29rUFbxxwPLgsD8(7ixqkRQrkbff)wxX)kL9XdqmUVPtNe7evGh0A0ecu8AglAUMuyl9Wnkcie0lar1EWkhO(AA8Rf1pMSahV)o97)JeyrPeqO6htwq8560j97)JeyrPeqO6htwqDHFTcKisTfLBrnxtkSLE4gfbec6fGOApyY56kH61vKRTGKcBPhUrraHGEbiQ2dUymrk4bxxjac3wVahV)o97)JY7d0smwerQTOClhKuyl9Wnkcie0lar1EWHqiMuqf)RY36evbbSqKJ3FhAGuwWwfHRm5FHXsbU4oYdAbOQfFUjfjfomhwfmPYbe5SDl9WnkPWH5eWvYbPMKsG4yoysoSpALkgEHOYCWDouhedjh22CrCWAoBZZvFeiPWw6HBuePGjvoGyN8C1hbC8(7lCinU6IVwrmUhyM8PMeAn2xjhfPMKsGeH2OLGWPt1KqRr0JwbY)vcrOnAjiyYNAsO1iuiY6Y31McrOnAjiyUWyPaxChHcrwx(U2uisGq7A0w7B60j)6TO86sUzYZiNrlHi66sjuvJuck3mvJucAuVqOQ4Q4aUGaH21igl6KchMd7JwbY)vc5qvoSCi4Nae5W((F8Y0d3mKCy4n6rGCkgY5HGCWnKtPetBYCuCoMRRSGC4YncbRqokohLdKtODDoQrkbnN7NZP5COCASMdQnxehSMtbG6yoiCoMuMdw5aKCcTRZrnsjO5y0N80dq54sW)tJjf2spCJIifmPYbeuThSlglReaHFKf44htQnuOUtDsHT0d3OisbtQCabv7bxAecwbhV)UXaGCkerCi4Naev07)XltpChH2OLGGj97)JOhTcK)ReIpxM0V)pIE0kq(VsisGq7A0wuhDat(rOk97)brsHdZH9rRa5)kbgsoBNRRSGCWKC2g4taeNCk(uo5q)(FqKdxUriyfqjf2spCJIifmPYbeuThSlglReaHFKf44htQnuOUtDsHT0d3OisbtQCabv7bxAecwbhxfSKqvnsjOODQD8(7QjHwJOhTcK)ReIqB0sqWKpceAxJ2I6nD60n8j1ZvEazRDQ5MPAKsqJ6fcvfxfhWfei0UgX4Mjfomh2hTcK)ReYHQCy5qWpbiYH99)4LPhUZ56CydIHKZ256klihWiYcYzBEU6Ja5OCmnNIpPmhAihc8jaIdiY5Jj54ATacVvsHT0d3OisbtQCabv7btEU6JaoE)D1KqRr0JwbY)vcrOnAjiyAmaiNcrehc(jarf9(F8Y0d3rOnAjiyYVaRrYZvFeiQ3IYRlzYZiNrlHi66sjuvJucAsHdZH9rRa5)kHCko4Cy5qWpbiYH99)4LPhUzi5SnG56kliNpMKdnUFOC4sb6CSwemMKduOcTae5GAZfXbR5iEetpChtkSLE4gfrkysLdiOApyxmwwjac)ilWXpMuBOqDN6KcBPhUrrKcMu5acQ2dU0ieScoUkyjHQAKsqr7u7493vtcTgrpAfi)xjeH2OLGGPXaGCkerCi4Naev07)XltpChH2OLGGPAKsqJ6fcvfxfhWibcTRrm5JaH21OTOUO60j)iuL(9)GG7KchMd7JwbY)vc5qvom8crLmKCy48GohmpGqobKJLdQnxehSMdxUriyfYHCLC0CSVcKC2MNR(iqo0WhtGCy4fISU8DTPhUtkSLE4gfrkysLdiOApyxmwwjac)ilWXpMuBOqDN6KcBPhUrrKcMu5acQ2dU0ieScoE)D1KqRr0JwbY)vcrOnAjiyQMeAncfISU8DTPqeAJwccMlmwkWf3rOqK1LVRnfIei0UgTf1mDjaVA5sePosEU6JamfynsEU6JarceAxJySiuf4az5wdTcRixOfE1REpa]] )
    

end