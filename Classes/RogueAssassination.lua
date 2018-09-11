-- RogueAssassination.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State


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
        deadly_brew = 134, -- 197044
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

    local calculate_multiplier = setfenv( function( spellID )
        local mult = 1
        local stealth = FindUnitBuffByID( "player", 1784 ) or FindUnitBuffByID( "player", 115191 ) or FindUnitBuffByID( "player", 11327 ) or GetTime() - stealth_dropped < 0.2

        if stealth then
            if talent.nightstalker.enabled then
                mult = mult * 1.5
            end

            if talent.subterfuge.enabled and spellID == 703 then
                mult = mult * 2
            end
        end

        return mult
    end, state )

    
    -- index: unitGUID; value: isExsanguinated (t/f)
    local crimson_tempests = {}
    local ltCT = {}

    local garrotes = {}
    local ltG = {}

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
                mult = mult * 2
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
        return active_dot.deadly_poison or 0
    end )

    spec:RegisterStateExpr( 'poison_remains', function ()
        return debuff.lethal_poison.remains
    end )

    -- Count of bleeds on all active targets.
    spec:RegisterStateExpr( 'bleeds', function ()
        return ns.compositeDebuffCount( "garrote", "internal_bleeding", "rupture", "crimson_tempest" )
    end )

    -- Count of bleeds on all poisoned (Deadly/Wound) targets.
    spec:RegisterStateExpr( 'poisoned_bleeds', function ()
        return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "garrote", "internal_bleeding", "rupture" )
    end )

    spec:RegisterStateExpr( "pmultiplier", function ()
        if not this_action then return false end
        local aura = this_action == "kidney_shot" and "internal_bleeding" or this_action
        return debuff[ aura ].pmultiplier
    end )


    spec:RegisterHook( "reset_precast", function ()
        debuff.crimson_tempest.pmultiplier   = nil
        debuff.garrote.pmultiplier           = nil
        debuff.internal_bleeding.pmultiplier = nil
        debuff.rupture.pmultiplier           = nil
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
        sharpened_blades = {
            id = 272916,
            duration = 20,
            max_stack = 30,
        },       
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
            
            usable = function () return combo_points.current > 0 end,
            recheck = function () return debuff.crimson_tempest.remains - ( 2 + ( spell_targets.crimson_tempest > 4 and 1 or 0 ) ) end,
            handler = function ()
                applyDebuff( "target", "crimson_tempest", 2 + ( combo_points.current * 2 ) )
                debuff.crimson_tempest.pmultiplier = persistent_multiplier
                
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
                applyDebuff( "target", "envenom", 1 + combo_points.current )
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
                if debuff.crimson_tempest.up then debuff.crimson_tempest.expires = query_time + ( debuff.crimson_tempest.remains / 2 ) end
                if debuff.garrote.up then debuff.garrote.expires = query_time + ( debuff.garrote.remains / 2 ) end
                if debuff.internal_bleeding.up then debuff.internal_bleeding.expires = query_time + ( debuff.internal_bleeding.remains / 2 ) end
                if debuff.rupture.up then debuff.rupture.expires = query_time + ( debuff.rupture.expires / 2 ) end
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
            
            recheck = function () return remains - ( duration * 0.3 ), remains - tick_time, remains - tick_time * 2, remains - 10 end,
            handler = function ()
                applyDebuff( "target", "garrote" )
                debuff.garrote.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )

                if stealthed.rogue then applyDebuff( "target", "garrote_silence" ) end
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

            usable = function () return target.casting end,
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
            
            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.internal_bleeding.enabled then
                    applyDebuff( "target", "internal_bleeding" )
                    debuff.internal_bleeding.pmultiplier = persistent_multiplier
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
                removeBuff( "sharpened_blades" )
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
            
            usable = function () return combo_points.current > 0 end,
            remains = function () return remains - ( duration * 0.3 ), remains - tick_time, remains - tick_time * 2, remains, cooldown.exsanguinate.remains - 1, 10 - time end,
            handler = function ()
                applyDebuff( "target", "rupture", min( dot.rupture.remains, class.auras.rupture.duration * 0.3 ) + 4 + ( 4 * combo_points.current ) )
                debuff.rupture.pmultiplier = persistent_multiplier

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
            cooldown = 30,
            recharge = 30,
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
            
            usable = function () return buff.stealth.down and buff.vanish.down end,
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
            
            handler = function ()
                applyDebuff( "target", "vendetta" )
                applyBuff( "vendetta_regen" )
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
                    ( buff.crippling_poison.down and action.crippling_poison.known )
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
    
        package = "Assassination",
    } )


    spec:RegisterPack( "Assassination", 20180910.2059, [[dWuRabqiGWJqk1LqLuLnrI(eQKkmkjItjHAvsi1RakZIKQBjrPDj0VqfnmskogsXYKi9mGuMgsjxtIITbKkFdiknoujLZHkrRdvsEhQKQAEaO7bO9buDqsk1cLO6HsizIarLlkHWhbsvNeiQALa0ljPeDtGOyNKGFssjyOOsyParEkknvsORssj0wjPK(kQKkAVu8xqnyPomvlgjpwstMsxw1MrXNrvJgP60kTAujv61OcZMu3wq7wXVHA4cSCiphX0jUoiBNK8Day8OsDEGK1lHO5lb7x0gAmkAyTUCJcLQgA4AQHlPrnXsvtz4YsbndRaQGByd8kho)nSJhEdRAtioHSJllEmSboO0y3Au0WsWqO6nS0fjGWvCYj)k0HOIvCiNKnes7YINkYzeojByLtknMItkgVS2RIZaeMz1NWjxGoi5RLWjxasWGeMh6WQnH4eYoUS4js2WQHLcA1ci)yOmSwxUrHsvdnCn1WL0OMyPQPmCjnCPH1He6yKHLDdlkdR9KQHL2zR2eIti74YINSbjmp0taPD20fjGWvCYj)k0HOIvCiNKnes7YINkYzeojByLtknMItkgVS2RIZaeMz1NWjxGoi5RLWjxasWGeMh6WQnH4eYoUS4js2WAciTZM9bYdPokBAuJ6zxQAOHRLDzZMl5k1OMS5cqMeWeqANDrr3h(t4QeqANDzZwTT2BZwTCRCKTGZ2Eghslz7vzXt26LiXeqANDzZgKEiw1ZwCe)f4LjAy1lrigfnSe5UwOFRrrJc0yu0W(XP03Ak3WwrRC06g2koKcdhG3rizdoWSPv2kZUKSfx)rIZYtxiIR54O4hNsFB2fkKT46psKarjhXaX)4hNsFB2kZwC9hjEUj(WdTJlp(XP03MTYSRyS2IbWep3eF4H2XLhrp03HKnabMDPzRmBvoADk9JKD41hwCe)LSluiBqKTSvo2Hp7IZwz2IJ4VeLn8Wcg2Up7YMn6H(oKSbpBqNH1RYIhdlckqGq3igfk1OOH9JtPV1uUHTIw5O1nSvCifgoaVJqYgCGzxdGdDUHjbFSgwVklEmSFu9bhAeJcGMrrd7hNsFRPCdRxLfpgwEhHWYnSv0khTUHvC9hjsGOKJyG4F8JtPVnBLzJod6e6oL(zRmBXr8xIYgEybdB3NDzZg9qFhs2GNDPg2kOQ6dloI)cXOangXOaTmkAy)4u6BnLBy9QS4XWY7iewUHTIw5O1nSIR)irceLCede)JFCk9TzRmB0d9DizdqGztJAYwz2bHqAzd07rzdqGztt2kZwCe)LOSHhwWW29zx2Srp03HKn4zxQHTcQQ(WIJ4VqmkqJrmkugJIg2poL(wt5g2kALJw3WkU(JejquYrmq8p(XP03MTYS9I8OvEKqhHHS3ctGyyWvxw8e)4u6BZwz2GiBlwIiOabc9OSvo2H3W6vzXJHfbfiqOBeJcGoJIg2poL(wt5gwVklEmS8ocHLByROvoADdR46psKarjhXaX)4hNsFB2kZ2lYJw5rcDegYElmbIHbxDzXt8JtPVnBLzloI)su2Wdlyy7(SbpB0d9Dig2kOQ6dloI)cXOangXOaiRrrd7hNsFRPCdldgbpNBXOangwVklEmSbySggDcgcvVrmkW1mkAy)4u6BnLByROvoADdR46psKarjhXaX)4hNsFB2kZwC9hjEUj(WdTJlp(XP03MTYSRyS2IbWep3eF4H2XLhrp03HKnaZMMSvMDa6QG5R2inreuGaHE2kZ2ILickqGqpIEOVdjBWZUmzdw20k7Io7AaCOZnmj4J1W6vzXJHL3riSCJyedR9moKwmkAuGgJIg2poL(wt5gwvUg6g2phXdQi68FYgSSdWlbp3ctP)TKSl6SbzZMRx2LKDPzx0ztcUwdt3jYZUydRxLfpgwvoADk9nSQCe84H3W(5iEqbJo)h4koKANBnIrHsnkAy)4u6BnLByv5AOByjbxRHfhXFHez8bgZaZXSQojBaMDPgwVklEmSQC06u6Byv5i4XdVHLSdV(WIJ4VyeJcGMrrdRxLfpgwo2khg2poL(wt5gXOaTmkAy)4u6BnLByROvoADdlrURf63gryEOBy9QS4XWwDTg2RYIhy9sedREjc84H3WsK7AH(TgXOqzmkAy)4u6BnLBy9QS4XWwDTg2RYIhy9sedREjc84H3WwTeJyua0zu0W(XP03Ak3W6vzXJHT6AnSxLfpW6Ligw9se4XdVH1IfJyuaK1OOH9JtPV1uUH1RYIhdB11AyVklEG1lrmS6LiWJhEdRDrVkgXOaxZOOH9JtPV1uUHTIw5O1nSFoIhur7z26kzdoWSPPmzdw2QC06u6h)CepOGrN)dCfhsTZTgwVklEmSoQ6ZHfmc9rmIrbU0OOH1RYIhdRJQ(C4ain5g2poL(wt5gXOanQXOOH1RYIhdRE5PleyUUqw(WpIH9JtPV1uUrmIHna9koKYfJIgfOXOOH9JtPV1uUrmkuQrrd7hNsFRPCJyua0mkAy)4u6BnLBeJc0YOOH9JtPV1uUrmkugJIgwVklEmSEqGguWb4LGhd7hNsFRPCJyua0zu0W6vzXJHLi31cDd7hNsFRPCJyuaK1OOH1RYIhdBaww8yy)4u6BnLBeJcCnJIg2poL(wt5gwVklEmSHoIJBHzWiy7DHUHTIw5O1nSiFTWx1hj6wljUt2GNnTuJHna9koKYfyYR4XsmSLXigXWAx0RIrrJc0yu0W(XP03Ak3WwrRC06g2koKcdhG3rizdoWSPv2GLT46ps0(hCemrqU48pm(XP03MTYSljB7PGyyIQ(yViEeki7cfY2EkigMOG5ERWuA3(iuq2fkK9NJ4bv0EMTUs2aey2LwMSblBvoADk9JFoIhuWOZ)bUIdP252SluiBqKTkhToL(rYo86dloI)s2fNTYSljBqKT46ps8Ct8HhAhxE8JtPVn7cfYUIXAlgat8Ct8HhAhxEe9qFhs2GNDPzxSH1RYIhd7hvFWHgXOqPgfnSFCk9TMYnSQCn0nSvCifgoaVJqI2ZS1vYg8SPj7cfY(Zr8GkApZwxjBacm7slt2GLTkhToL(XphXdky05)axXHu7CB2fkKniYwLJwNs)izhE9HfhXFXW6vzXJHvLJwNsFdRkhbpE4nSqKdZSA9rgXOaOzu0W(XP03Ak3WwrRC06gwvoADk9JqKdZSA9rzRmBkigMiHUJc(ClmL2TNejIx5iBWbMDPCPH1RYIhdBaEj45wyoML5gXOaTmkAy)4u6BnLByROvoADdRkhToL(riYHzwT(OSvMDjztbXWePVw7hykTBpjseVYr2GdmBA4YSluiBsW1AyXr8xirgFGXmWCmRQtYgCGzxA2GLnrURf63gryEONDHcztbXWef6h2IUB1yKLaBF9RejIx5iBWbMDPCz2fBy9QS4XWY4dmMbMJzvDIrmkugJIg2poL(wt5g2kALJw3WQYrRtPFeICyMvRpkBLzxs2uqmmrk9owYAFeki7cfYgezlU(Jev9bhcJGi0JFCk9TzxSH1RYIhdlLEhlzT3igfaDgfnSFCk9TMYnSv0khTUHvLJwNs)ie5WmRwFKH1RYIhdBiKSAxUrmIHTAjgfnkqJrrd7hNsFRPCdBfTYrRByPGyyIuAm2QHiseDVkzxOq2IJ4VeLn8Wcg2UpBacmBqNAYUqHSTNcIHjQ6J9I4rOGSvMDfJ1wmaMOkFwc9i6H(oKSby2LXW6vzXJHnallEmIrHsnkAy)4u6BnLBy9QS4XWY76xDT(icmfgpg2kALJw3WwXyTfdGjQ6J9I4r0d9DizdqGztt2kZUKSbr2IR)irceLCede)JFCk9TzxOq2wSe5DeclpgecPLnqVhLn4ztt2fNDHczxXyTfdGjQ6J9I4r0d9DizdE20Qmg2XdVHL31V6A9reykmEmIrbqZOOH9JtPV1uUHTIw5O1nS2tbXWev9XEr8iuGH1RYIhdlLgJTWmqiqzeJc0YOOH9JtPV1uUHTIw5O1nS2tbXWev9XEr8iuGH1RYIhdl1rKJ4yhEJyuOmgfnSFCk9TMYnSv0khTUH1EkigMOQp2lIhHcmSEvw8yyzw0P0yS1igfaDgfnSFCk9TMYnSv0khTUH1EkigMOQp2lIhHcmSEvw8yy9PEIGCnC11AJyuaK1OOH9JtPV1uUHTIw5O1nSiFTWx1hj6wljcfKTYSljBXr8xIYgEybdB3NnaZUIdPWWb4Des0EMTUs2fD20elt2fkKDfhsHHdW7iKO9mBDLSbhy21a4qNBysWhB2fBy9QS4XWg6ioUfMbJGT3f6gXOaxZOOH9JtPV1uUHTIw5O1nSiFTWx1hj6wljUt2GNnOPMSlB2iFTWx1hj6wljAHqUS4jBLzxXHuy4a8ocjApZwxjBWbMDnao05gMe8XAy9QS4XWg6ioUfMbJGT3f6gXOaxAu0W(XP03Ak3WwrRC06gwqKnrURf63gryEONTYSTyjIGcei0JYw5yh(SvMDjzdISfx)rIeik5igi(h)4u6BZUqHSbr2ErE0kpsOJWq2BHjqmm4QllEIFCk9TzxOq2wSe5DeclpgecPLnqVhLn4ztt2fBy9QS4XWQ6J9I4gXOanQXOOH9JtPV1uUHTIw5O1nSIR)irceLCede)JFCk9TzRmBqKTflrEhHWYJYw5yh(SvMTkhToL(rYo86dloI)IH1RYIhdRkFwcDJyuGgAmkAy)4u6BnLByROvoADdR46ps8Ct8HhAhxE8JtPVnBLzxs2IR)iXz5PleX1CCu8JtPVn7cfYwC9hjsGOKJyG4F8JtPVnBLzRYrRtPFKSdV(WIJ4VKDXzRm7koKcdhG3rizdoWSRbWHo3WKGp2SvMDfJ1wmaM45M4dp0oU8i6H(oKSby20KTYSljBqKT46psKarjhXaX)4hNsFB2fkKniY2lYJw5rcDegYElmbIHbxDzXt8JtPVn7cfY2ILiVJqy5XGqiTSb69OSbiWSPj7InSEvw8yyv5ZsOBeJc0uQrrd7hNsFRPCdBfTYrRByfx)rIZYtxiIR54O4hNsFB2kZgezlU(Jep3eF4H2XLh)4u6BZwz2vCifgoaVJqYgCGzxdGdDUHjbFSzRmB7PGyyIQ(yViEekWW6vzXJHvLplHUrmkqdOzu0W(XP03Ak3WwrRC06gwX1FKibIsoIbI)XpoL(2SvMDjzdISfx)rINBIp8q74YJFCk9TzxOq2GiBvoADk9JKD41hwCe)LSloBLzdISjYDTq)2icZd9SvMDfJ1wmaMiVJqy5rOGSvMTflrEhHWYJOZGoHUtPF2kZUKSjbxRHfhXFHez8bgZaZXSQojBacmBqlBLzxXHuy4a8ocjApZwxjBWbMnnzdw2KGR1WIJ4VqIm(aJzG5ywvNKDHcztcUwdloI)cjY4dmMbMJzvDs2GdmBALTYSR4qkmCaEhHeTNzRRKn4aZMwzxSH1RYIhdRkFwcDJyuGgAzu0W(XP03Ak3WwrRC06gwX1FKyOtKJGDcXjKDIFCk9TzRmBqKnrURf63gDToBLzh6e5iyNqCczhy0d9DizdqGzRMSvMniY2ILickqGqpIod6e6oL(gwVklEmSQ8zj0nIrbAkJrrd7hNsFRPCdBfTYrRByTyjIGcei0JOh67qYg8SPv2GLnTYUOZUgah6Cdtc(yZwz2GiBlwI8ocHLhrNbDcDNsFdRxLfpg2ZnXhEODC5gXOanGoJIg2poL(wt5g2kALJw3WAXsebfiqOhLTYXo8gwVklEmScM7TctPD7nIrmSwSyu0OangfnSFCk9TMYnSv0khTUHvC9hjEUj(WdTJlp(XP03MTYSlj7sYUIdPWWb4Des2Gdm7AaCOZnmj4JnBLzxXyTfdGjEUj(WdTJlpIEOVdjBaMnnzxC2fkKDjzdISLTYXo8zRm7sYw2WNn4ztJAYUqHSR4qkmCaEhHKn4aZU0Slo7IZUydRxLfpgweuGaHUrmkuQrrd7hNsFRPCdldgbpNBXOangwVklEmSbySggDcgcvVrmkaAgfnSFCk9TMYnSEvw8yy5Decl3WwrRC06g2sYgezlU(JejquYrmq8p(XP03MDHczdISlj7kgRTyamrv(Se6rOGSvMDfJ1wmaMOQp2lIhrp03HKnabMnTYU4SloBLzxXHuy4a8ocjApZwxjBWbMnnzRmB0zqNq3P0pBLzxs2bHqAzd07rzdqGztt2fkKn6H(oKSbiWSLTYbSSHpBLztcUwdloI)cjY4dmMbMJzvDs2GdmBqlBWY2lYJw5rcDegYElmbIHbxDzXt8JtPVn7IZwz2LKniY(Ct8HhAhxUn7cfYg9qFhs2aey2Yw5aw2WNDrNDPzRmBsW1AyXr8xirgFGXmWCmRQtYgCGzdAzdw2ErE0kpsOJWq2BHjqmm4QllEIFCk9TzxC2kZUKSfhXFjkB4HfmSDF2LnB0d9DizdE20kBLztcUwdloI)cjY4dmMbMJzvDs2aey20KDHczloI)su2Wdlyy7(SlB2Oh67qYg8SPP0Sl2WwbvvFyXr8xigfOXigfOLrrd7hNsFRPCdBfTYrRByjbxRHfhXFHKn4aZU0SvMn6H(oKSby2LMnyzxs2KGR1WIJ4VqYgCGzxMSloBLzxXHuy4a8ocjBWbMnTmSEvw8yyROnKGhy5HbNigXOqzmkAy)4u6BnLBy9QS4XWIGcei0nSv0khTUHTIdPWWb4Des2GdmBALTYSrNbDcDNs)SvMDjzhecPLnqVhLnabMnnzxOq2Oh67qYgGaZw2khWYg(SvMnj4AnS4i(lKiJpWygyoMv1jzdoWSbTSblBVipALhj0ryi7TWeiggC1LfpXpoL(2SloBLzxs2Gi7ZnXhEODC52SluiB0d9DizdqGzlBLdyzdF2fD2LMTYSjbxRHfhXFHez8bgZaZXSQojBWbMnOLnyz7f5rR8iHocdzVfMaXWGRUS4j(XP03MDXzRmBXr8xIYgEybdB3NDzZg9qFhs2GNnTmSvqv1hwCe)fIrbAmIrmIHv1rKfpgfkvn0W1udxQMsJLcA0c0mSaWrZo8edliFyagj3MnOlBVklEYwVeHetanSbimZQVHL2zR2eIti74YINSbjmp0taPD20fjGWvCYj)k0HOIvCiNKnes7YINkYzeojByLtknMItkgVS2RIZaeMz1NWjxGoi5RLWjxasWGeMh6WQnH4eYoUS4js2WAciTZM9bYdPokBAuJ6zxQAOHRLDzZMl5k1OMS5cqMeWeqANDrr3h(t4QeqANDzZwTT2BZwTCRCKTGZ2Eghslz7vzXt26LiXeqANDzZgKEiw1ZwCe)f4LjMaMas7SlcUFfsUnBQZGrp7koKYLSPo)oKy2QDT(aHK9GNYs3rHmq6S9QS4HKnE0GkMa6vzXdjgGEfhs5cqgTt4ib0RYIhsma9koKYfWaYPdXh(rCzXtcOxLfpKya6vCiLlGbKtgm2Mas7SzhpGqhlzJ81MnfedZTztexiztDgm6zxXHuUKn153HKTp2SdqVSbyr2Hp7LKTfppMa6vzXdjgGEfhs5cya5KmEaHowGjIlKeqVklEiXa0R4qkxadiNEqGguWb4LGNeqVklEiXa0R4qkxadiNe5UwONa6vzXdjgGEfhs5cya5mallEsa9QS4HedqVIdPCbmGCg6ioUfMbJGT3f6QhGEfhs5cm5v8yjalJ6ldqKVw4R6JeDRLe3bCAPMeWeqANDrW9RqYTzFvhbQSLn8zl0F2EvWOSxs2UkF1oL(XeqVklEiav5O1P0x9XdpWphXdky05)axXHu7CR6QCn0b(5iEqfrN)dyb4LGNBHP0)wsrdYY1RKslAsW1Ay6orEXjGEvw8qadiNQC06u6R(4HhizhE9HfhXFrDvUg6ajbxRHfhXFHez8bgZaZXSQobGLMa6vzXdbmGCYXw5ib0RYIhcya5S6AnSxLfpW6LiQpE4bsK7AH(TQVmajYDTq)2icZd9eqVklEiGbKZQR1WEvw8aRxIO(4Hhy1ssa9QS4HagqoRUwd7vzXdSEjI6JhEGwSKa6vzXdbmGCwDTg2RYIhy9se1hp8aTl6vjb0RYIhcya50rvFoSGrOpI6ldWphXdQO9mBDfWbstzatLJwNs)4NJ4bfm68FGR4qQDUnb0RYIhcya50rvFoCaKM8eqVklEiGbKt9YtxiWCDHS8HFKeWeqANDrHXAlgadjb0RYIhsSAjadWYIh1xgGuqmmrkngB1qejIUxLcfehXFjkB4HfmSDpabc6utHc2tbXWev9XEr8iuGYkgRTyamrv(Se6r0d9DiaSmjGEvw8qIvlbmGCcro8kpu9XdpqEx)QR1hrGPW4r9LbyfJ1wmaMOQp2lIhrp03HaqG0OSeqiU(JejquYrmq8p(XP03wOGflrEhHWYJbHqAzd07rGttXfkuXyTfdGjQ6J9I4r0d9DiGtRYKa6vzXdjwTeWaYjLgJTWmqiqP(Ya0EkigMOQp2lIhHcsa9QS4HeRwcya5K6iYrCSdV6ldq7PGyyIQ(yViEekib0RYIhsSAjGbKtMfDkngBvFzaApfedtu1h7fXJqbjGEvw8qIvlbmGC6t9eb5A4QR1QVmaTNcIHjQ6J9I4rOGeqANnipt2U1sY2rpBOa1ZMmBWZwO)SXZZgaRqpBngaNizROIGCXSvlsE2aG(NSTGAh(SzCICu2cDFYUO4ISTNzRRKngLnawHogsY2hqLDrXfXeqVklEiXQLagqodDeh3cZGrW27cD1xgGiFTWx1hj6wljcfOSeXr8xIYgEybdB3dWkoKcdhG3rir7z26kfnnXYuOqfhsHHdW7iKO9mBDfWbwdGdDUHjbFSfNas7Sb5zYEWz7wljBaSAD229zdGvOVt2c9N9CULSbn1qupBiYZgKHbKlB8KnfMqYgaRqhdjz7dOYUO4IycOxLfpKy1sadiNHoIJBHzWiy7DHU6ldqKVw4R6JeDRLe3bCqtnLf5Rf(Q(ir3AjrleYLfpkR4qkmCaEhHeTNzRRaoWAaCOZnmj4JnbK2zRw)yViE2yiHS2NnrURf6zdGvONnibfiqONnuqmBUoxHE2SquYrmq8pBX1FKS9XMnlDegYEB2Sqmm4QllEYoadGJY21aWbfjBiYZgaRqpBkigMBZg07iewEmb0RYIhsSAjGbKtvFSxex9LbiiiYDTq)2icZdDLwSerqbce6rzRCSdVYsaH46psKarjhXaX)4hNsFBHcGWlYJw5rcDegYElmbIHbxDzXt8JtPVTqblwI8ocHLhdcH0YgO3JaNMItaPD2fb3cYZMfIsoIbI)zRw9zj0ZUIh7klE4QSvlsE2aG(NSb9ocHLNTfHdcUnB8Kn7o86NTIoI)scOxLfpKy1sadiNQ8zj0vFzakU(JejquYrmq8p(XP03QeewSe5DeclpkBLJD4vQYrRtPFKSdV(WIJ4VKas7SvR(Se6zdGvONDrWnHpBWYUefwE6crCnhhPE2yu2SquYrmq8pB8Obv24jBAuSyUkBqgN7nekm7IIlY2hB2fb3e(Sr3TGkBgmk75Clzd6lkqUeqVklEiXQLagqov5ZsOR(YauC9hjEUj(WdTJlp(XP03QSeX1FK4S80fI4Aook(XP03wOG46psKarjhXaX)4hNsFRsvoADk9JKD41hwCe)LIvwXHuy4a8ocbCG1a4qNBysWhRYkgRTyamXZnXhEODC5r0d9DiaKgLLacX1FKibIsoIbI)XpoL(2cfaHxKhTYJe6imK9wyceddU6YIN4hNsFBHcwSe5DeclpgecPLnqVhbqG0uCciTZwT6ZsONnawHE2kS80fI4AookBWYwbC2fb3eEUkBqgN7nekm7IIlY2hB2Q1p2lINnuqcOxLfpKy1sadiNQ8zj0vFzakU(JeNLNUqexZXrXpoL(wLGqC9hjEUj(WdTJlp(XP03QSIdPWWb4Dec4aRbWHo3WKGpwL2tbXWev9XEr8iuqciTZwT6ZsONnawHE2SquYrmq8pBWYUefWzxeCt4ZgJYUufbRyUkBfWztK7AHoNeik5igi(RE2GEhHWYZgKod6e6oL(QN9hmep9SjbE9zZGrzVtfhUdF2GEhHWYZUO4IeqVklEiXQLagqov5ZsOR(YauC9hjsGOKJyG4F8JtPVvzjGqC9hjEUj(WdTJlp(XP03wOaiu5O1P0ps2HxFyXr8xkwjiiYDTq)2icZdDLvmwBXayI8ocHLhHcuAXsK3riS8i6mOtO7u6RSesW1AyXr8xirgFGXmWCmRQtaiqqtzfhsHHdW7iKO9mBDfWbsdyKGR1WIJ4VqIm(aJzG5ywvNuOaj4AnS4i(lKiJpWygyoMv1jGdKwkR4qkmCaEhHeTNzRRaoqAvCciTZwT6ZsONnawHE2GmorokB1MqCYoCv2kGZMi31c9S9XM9GZ2RYQ6zdYO2ztbXWOE2GeuGaHE2dwYENSrNbDc9Sr(W)eqVklEiXQLagqov5ZsOR(YauC9hjg6e5iyNqCczN4hNsFRsqqK7AH(TrxRvg6e5iyNqCczhy0d9DiaeOAucclwIiOabc9i6mOtO7u6Nas7SlcUj(WdTJlpBaq)t2uyHE2GeuGaHE2(yZg07iewE2o6zdfKndgLTgp8z)bdXtpb0RYIhsSAjGbKZZnXhEODC5QVmaTyjIGcei0JOh67qaNwGrRIUgah6Cdtc(yvcclwI8ocHLhrNbDcDNs)eqVklEiXQLagqofm3BfMs72R(Ya0ILickqGqpkBLJD4tataPD2GCl6vjBRh68pBNA1RSNKas7SlIr1hCy2UKnTal7skdyzdGvONnihBXzxuCrmBq(WWBxxUguzJNSlfSSfhXFHOE2ayf6zRw)yViU6zJrzdGvONTILZ1pBSq)iaSKNna8vYMbJYMGdF2FoIhuXSvBnbNna8vYEzYUi4MWNDfhsHZEjzxXH7WNnuqmb0RYIhs0UOxfGFu9bhQ(YaSIdPWWb4Dec4aPfyIR)ir7FWrWeb5IZ)W4hNsFRYsSNcIHjQ6J9I4rOGcfSNcIHjkyU3kmL2TpcfuOWNJ4bv0EMTUcabwAzatLJwNs)4NJ4bfm68FGR4qQDUTqbqOYrRtPFKSdV(WIJ4VuSYsaH46ps8Ct8HhAhxE8JtPVTqHkgRTyamXZnXhEODC5r0d9DiGxAXjGEvw8qI2f9Qagqov5O1P0x9XdpqiYHzwT(i1v5AOdSIdPWWb4Des0EMTUc40uOWNJ4bv0EMTUcabwAzatLJwNs)4NJ4bfm68FGR4qQDUTqbqOYrRtPFKSdV(WIJ4VKas7S5c8sWZTzRwolZZ2LSlLlblBI4voizJzYMLUJc(CB2LRD7jXeqVklEir7IEvadiNb4LGNBH5ywMR(YauLJwNs)ie5WmRwFKskigMiHUJc(ClmL2TNejIx5aCGLYLjGEvw8qI2f9Qagqoz8bgZaZXSQor9LbOkhToL(riYHzwT(iLLqbXWePVw7hykTBpjseVYb4aPHlluGeCTgwCe)fsKXhymdmhZQ6eWbwkye5UwOFBeH5HEHcuqmmrH(HTO7wngzjW2x)krI4voahyPCzXjGEvw8qI2f9QagqoP07yjR9QVmav5O1P0pcromZQ1hPSekigMiLEhlzTpcfuOaiex)rIQ(GdHrqe6XpoL(2Ita9QS4HeTl6vbmGCgcjR2LR(YauLJwNs)ie5WmRwFucyciTZgKZdD(Nnw1rzlB4Z2Pw9k7jjG0oB2GxxxNnibfiqONn5cuq2myu2fb3e(eqVklEirlwaIGcei0vFzakU(Jep3eF4H2XLh)4u6BvwsjvCifgoaVJqahynao05gMe8XQSIXAlgat8Ct8HhAhxEe9qFhcaPP4cfkbeYw5yhELLiB4bNg1uOqfhsHHdW7ieWbwAXfxCciTZg07iewE2qbC8hOE2UMGZwq7jzl4SHip7vY2jz7ztcEDDD28FoYfmkBgmkBH(Zw7ej7IIlYM6my0Z2ZMzNLq)OeqVklEirlwadiNbySggDcgcvV6mye8CUfG0Ka6vzXdjAXcya5K3riSC1RGQQpS4i(leG0O(YaSeqiU(JejquYrmq8p(XP03wOaikPIXAlgatuLplHEekqzfJ1wmaMOQp2lIhrp03HaqG0Q4IvwXHuy4a8ocjApZwxbCG0OeDg0j0Dk9vwsqiKw2a9EeabstHcOh67qaiqzRCalB4vscUwdloI)cjY4dmMbMJzvDc4abnW8I8OvEKqhHHS3ctGyyWvxw8e)4u6BlwzjG4Ct8HhAhxUTqb0d9DiaeOSvoGLn8fDPkjbxRHfhXFHez8bgZaZXSQobCGGgyErE0kpsOJWq2BHjqmm4QllEIFCk9TfRSeXr8xIYgEybdB3xw0d9DiGtlLKGR1WIJ4VqIm(aJzG5ywvNaqG0uOG4i(lrzdpSGHT7ll6H(oeWPP0ItaPD2ffAdj4jBfFyWjs24rdQSXt2HqAzd0pBXr8xiz7s20cSSlkUiBaq)t2iOz2HpBmKK9ozxkj7sGcYwWztRSfhXFHuC2yu2Ggj7skdyzloI)cP4eqVklEirlwadiNv0gsWdS8WGte1xgGKGR1WIJ4VqahyPkrp03HaWsbResW1AyXr8xiGdSmfRSIdPWWb4Dec4aPvciTZwT8piBOGSbjOabc9SDjBAbw24jBxRZwCe)fs2Laa6FYwVQ2HpBnE4Z(dgINE2(yZEWs2KXdi0XsXjGEvw8qIwSagqorqbce6QxbvvFyXr8xiaPr9LbyfhsHHdW7ieWbslLOZGoHUtPVYsccH0YgO3JaiqAkua9qFhcabkBLdyzdVssW1AyXr8xirgFGXmWCmRQtahiObMxKhTYJe6imK9wyceddU6YIN4hNsFBXklbeNBIp8q74YTfkGEOVdbGaLTYbSSHVOlvjj4AnS4i(lKiJpWygyoMv1jGde0aZlYJw5rcDegYElmbIHbxDzXt8JtPVTyLIJ4VeLn8Wcg2UVSOh67qaNwjGjG0oBw5UwOFB2QDvw8qsaPD2kS80jIR54i1ZgJYMfIsaRi4MWNnEYMgf5QSzhpGqhlzdsqbce6C9ZwT1eC2qKNnibfiqONnw1rzxeJQp4WSxMSxHRds2dwY2dc07TzxIAHGphvCcOxLfpKirURf63cebfiqOR(YaSIdPWWb4Dec4aPLYsex)rIZYtxiIR54O4hNsFBHcIR)irceLCede)JFCk9Tkfx)rINBIp8q74YJFCk9TkRyS2IbWep3eF4H2XLhrp03HaqGLQuLJwNs)izhE9HfhXFPqbqiBLJD4lwP4i(lrzdpSGHT7ll6H(oeWbDjGEvw8qIe5UwOFlya58JQp4q1xgGvCifgoaVJqahynao05gMe8XMas7SzHOKJyG4pxLTAheObv2yu2G0zqNqpBaSc9SPGyyUnBqVJqy5KeqVklEirICxl0VfmGCY7iewU6vqv1hwCe)fcqAuFzakU(JejquYrmq8p(XP03QeDg0j0Dk9vkoI)su2Wdlyy7(YIEOVdb8staPD2SquYrmq8NRYwTGQJqR9zpyuORZg07iewojBaSc9SjJhqOJLSvDezXdjb0RYIhsKi31c9BbdiN8ocHLREfuv9HfhXFHaKg1xgGIR)irceLCede)JFCk9Tkrp03HaqG0OgLbHqAzd07raeinkfhXFjkB4HfmSDFzrp03HaEPjG0oBwik5igi(NnyzZshHHS3MnleddU6YIhUkB1oiqdQSVJ0GkBqckqGqpBHUlzdGvRZM6zJod6e63MndgLDGp2hU1ycOxLfpKirURf63cgqorqbce6QVmafx)rIeik5igi(h)4u6Bv6f5rR8iHocdzVfMaXWGRUS4j(XP03QeewSerqbce6rzRCSdFciTZMfIsoIbI)zdaoZMLocdzVnBwiggC1LfpCv2G09GanOYMbJYMcpqKSlkUiBFSzFULp2BZMmEaHowY2cHCzXtcOxLfpKirURf63cgqo5Declx9kOQ6dloI)cbinQVmafx)rIeik5igi(h)4u6Bv6f5rR8iHocdzVfMaXWGRUS4j(XP03QuCe)LOSHhwWW29GJEOVdjbK2zZcrjhXaX)Sbl7IGBcpxLDrO6t2yvhHw7Z2ZMmEaHowYg07iewE2OLNUKTZihLnibfiqONn1zWONDrWnXhEODCzXtcOxLfpKirURf63cgqodWynm6emeQE1zWi45ClaPjb0RYIhsKi31c9BbdiN8ocHLR(YauC9hjsGOKJyG4F8JtPVvP46ps8Ct8HhAhxE8JtPVvzfJ1wmaM45M4dp0oU8i6H(oeasJYa0vbZxTrAIiOabcDLwSerqbce6r0d9DiGxgWOvrxdGdDUHjbFSgwsWRgfkTmCPrmIXaa]] )

end