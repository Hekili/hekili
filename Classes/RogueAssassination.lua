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
                local app = state.debuff.garrote.applied
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
                local app = state.debuff.internal_bleeding.applied
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
                local app = state.debuff.rupture.applied
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
            local auras = stealth[ k ]
            if not auras then return false end

            for _, aura in pairs( auras ) do
                if state.buff[ aura ].up then return true end
            end

            return false
        end,
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
    local garrotes = {}
    local internal_bleedings = {}
    local ruptures = {}

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
            duration = 8,
            max_stack = 1,
            meta = {
                exsanguinated = function () return debuff.rupture.up and ruptures[ target.unit ] end,
                tick_time = function () return debuff.rupture.exsanguinated and haste or ( 2 * haste ) end,
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
            
            recheck = function () return energy.time_to_40, energy.time_to_50 end,
            handler = function ()
                gain( 1, "combo_points" )
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
                applyDebuff( "target", "rupture", 4 + ( 4 * combo_points.current ) )
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

            nobuff = "wound_poison",

            handler = function ()
                applyBuff( "wound_poison" )
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


    spec:RegisterPack( "Assassination", 20180728.1558, [[d80tXaqivkEKuL6sOuG2ef5tQeXOOOCkkQwfPc9kvvMfPk3sQs2Lk(fPQgMiPoMQslJuPNrQittLW1qP02KQO(MkrzCQevNdLISosf8oPkiMNiv3tQSpvshuKKwOiXdLQiteLc5IsvOpQsKgPufuDsPkWkLQ6LsvqzMOuqUjkfQDQQ4NOuadLurzPIK4PizQQQ6QOuuARKkQ(kkffJvQcs7fv)vvgSIdlSyK6XszYI6YGntkFMcJgLCAjRgLcQxRs1SP0TrXUv63qnCs64OuuTCephY0jUoj2Ui67QuA8OuDErkZxe2pvZ)Y)ZPYHa8p6M6VxEQVmDV8Zx2Y2lp16eNsstf4uQr7EyaCQnyaovQIqbcvBifE5uQrAwCK5)5uiScPbCkwIOI0b913Oewk0NgMrFuXOydPWBJeAI(OIPPpTftRpTw0RmKuFvcwRSas))fq09R()197lvWgkWlvrOaHQnKcVhuX04u0kLv6blNMtLdb4F0n1FV8uFz6E5NVSLT60f9mNkuewycNIQy6jovgqno1FwfYNc5t4JA0UhgGpynFIMu41hBHeKpAyIp9WH7LToEFV)FwGp0LHbGeFYGw1kXNq8ryb(WGzGv8Pq(iScXNBzbRpmkwPuTGpWcmfG8jiGpQ4cHxi7tSzFyfjbFOTaKr(eQQ2cY65JWc8jYz86ZTL16ZIfF0WeOfiXhHf4tKZLu4nS(alqmsZhJOwi7JgbZ4dSatbiFsdR4tqG9seFKGyasTghF8PhS(iSWiWhujkHu4fPNpeaHvinOxgHazFc6YwsbiFyI08bXcFRpHpzWgP5JumaXhHvi(WMRuT7208jtWQiFe8Tbj7tQpCkBHee)pNcjqyfwqM)N)5l)pNc2G2czEkCQgPeGubNsclSYbPqlartXaoWg0wi7JjFiGgbqScAl4JjFmZNB8byhfRHsTHazFsKWhcWe1I8j9oFKQD)jfd4Jo6JU(yUpM8rcIbihPyGNGF5c8Px(qaMOwKpx9rxov0KcVCkJGqWcWPAP1SWtcIbii(NVCH)rx(FofSbTfY8u4unsjaPcoLewyLdsHwaIMIbCGnOTq2ht(qaMOwKpP35Z3u7JjFuzuSsPAlG4t6D(81ht(CJpa7OynuQnei7JjFKGyaYrkg4j4xUaF6LpeGjQf5ZvF0LtfnPWlNYiieSaCQwAnl8KGyacI)5lx4F0j(FofSbTfY8u4unsjaPcovdZqJFQ4AfKpx785cFm5Jz(iHfw5SLblbjH9oqoWg0wi7tIe(CJps1UxRHpM7JjFKGyaYrkg4j4xUaF6LpeGjQf5ZvF6zov0KcVCkIIQOqaUW)Cb)pNc2G2czEkCQgPeGubNQHzOXpvCTcYNRD(0uFmb7pKkSzov0KcVCkytclMHl8pSL)NtbBqBHmpfovJucqQGtDJpsyHvoifAbiAkgWb2G2czFm5JeedqosXapb)Yf4tV8HamrTiFU6ZfCQOjfE5ugbHGfGl8p9m)pNc2G2czEkCQgPeGubNcPcw7tcIbiiFU25JoXPIMu4LtPf7dR9UVvsaXf(NlJ)NtfnPWlNIrrkBiaNc2G2czEkCHlCQmOfkwH)N)5l)pNkAsHxo19QDNtbBqBHmpfUW)Ol)pNkzyvaofSaXiTdbmG1NF(OIleEH8J2cqg5Jo6ZL5dBqFmZhD9rh9bPcw7JvGeWhZ5uWg0wiZtHtfnPWlNkzqQG2cCQKb5TbdWPGfigP9iGbSVgMHUwiZf(hDI)NtbBqBHmpfov0KcVCQwyTVOjfEF2cjCkBHK3gmaNQLrCH)5c(FofSbTfY8u4urtk8YPik7lAsH3NTqcNQrkbivWPqcewHfKpeSHcWPSfsEBWaCkKaHvybzUW)Ww(FofSbTfY8u4urtk8YPAH1(IMu49zlKWPSfsEBWaCQmw4c)tpZ)ZPGnOTqMNcNkAsHxovlS2x0KcVpBHeoLTqYBdgGtLlc0eUW)Cz8)CkydAlK5PWPAKsasfCkybIrANmOvTs85ANpFzRp)8jzqQG2chybIrApcya7RHzORfYCQOjfE5ubPfl8emHaRWf(NlN)NtfnPWlNkiTyHNQIfbCkydAlK5PWf(h2e)pNkAsHxoLTmyjOhByLSbdScNc2G2czEkCHlCkvc0Wm0HW)Z)8L)NtbBqBHmpfUW)Ol)pNc2G2czEkCH)rN4)5uWg0wiZtHl8pxW)ZPGnOTqMNcx4Fyl)pNkAsHxovOQAt7PIleE5uWg0wiZtHl8p9m)pNkAsHxovgISnTNkUq4LtbBqBHmpfUW)Cz8)CQOjfE5unsPQAR14PIleE5uWg0wiZtHl8pxo)pNkAsHxofsGWkS4uWg0wiZtHl8pSj(Fov0KcVCkvSu4LtbBqBHmpfUW)8n18)CkydAlK5PWPAKsasfCksu5hKew5e5m6uRpx95IuZPIMu4LtXeK7q(PHjVmecloLkbAyg6qEiOH3mItXwUWfovUiqt4)5F(Y)ZPGnOTqMNcNQrkbivWPAygA8tfxRG85ANpx4ZpFKWcRCYaOcKhsiHegaZb2G2czFm5Jz(KbAfnTtsyZGiXrr1Nej8jd0kAAhbZE1E02idhfvFsKWhybIrANmOvTs8j9oF0LT(8ZNKbPcAlCGfigP9iGbSVgMHUwi7tIe(GubR9jbXae0rl2hw7DFRKaYNRD(ORpM7JjFmZNB8rclSYbyhfRHsTHahydAlK9jrcFAySnJVDpa7OynuQne4qaMOwKpx9rxFmNtfnPWlNc2KWIz4c)JU8)CQKHvb4unmdn(PIRvqNmOvTs85QpF9jrcFGfigPDYGw1kXN078rx26ZpFsgKkOTWbwGyK2JagW(Ayg6AHSpjs4dsfS2NeedqqhTyFyT39TsciFU25JUCkydAlK5PWPIMu4LtLmivqBbovYG82Gb4uki4Pvwlq4c)JoX)ZPGnOTqMNcNQrkbivWPsgKkOTWrbbpTYAbIpM8XmFOv00oSQCg2hTnYa6GKOD3NRD(8Ln5tIe(GubR9jbXae0rl2hw7DFRKaYNRD(ORpjs4dTIM2rybVmbISftYOxgAqjhKeT7(CTZhDzt(yoNkAsHxoLwSpS27(wjbex4FUG)NtbBqBHmpfovJucqQGtLmivqBHJccEAL1ceFm5Jz(qROPDOT1MrvgokQ(KiHp34JewyLtsyXmpIcI1b2G2czFmNtfnPWlNI2wBgvzGl8pSL)NtbBqBHmpfovJucqQGtLmivqBHJccEAL1ceov0KcVCkgfPSHaCHlCQwgX)Z)8L)NtbBqBHmpfovJucqQGtrROPDOTyC2QGKdbIM4tIe(ibXaKJumWtWVCb(KENp9CQ9jrcFYaTIM2jjSzqK4OO6JjFAySnJVDpjJTqSoeGjQf5t6(Wwov0KcVCkvSu4Ll8p6Y)ZPGnOTqMNcNQrkbivWPYaTIM2jjSzqK4OOYPIMu4LtrBX48ttHKgx4F0j(FofSbTfY8u4unsjaPcovgOv00ojHndIehfvov0KcVCkAGGaY9An4c)Zf8)CkydAlK5PWPAKsasfCkjigGCKIbEc(LlWN09PHzOXpvCTc6KbTQvIp6OpFpS1Nej8XmFirLFqsyLtKZOtT(C1NlsTpM8PHzOXpvCTc6KbTQvIpx78PP(yc2FivyZ(yoNkAsHxoftqUd5NgM8YqiS4usqma5vACkjigGCKIbEc(LlGl8pSL)NtbBqBHmpfovJucqQGtLXYHOOkke4iv7ETgCQOjfE5ujHndIeCH)PN5)5uWg0wiZtHt1iLaKk4usyHvoBzWsqsyVdKdSbTfY(yYhjSWkhGDuSgk1gcCGnOTq2ht(0Wm04NkUwb5Z1oFAQpMG9hsf2SpM8PHX2m(29aSJI1qP2qGdbyIAr(KUpF5urtk8YPsgBHyXf(NlJ)NtbBqBHmpfovJucqQGtjHfw5SLblbjH9oqoWg0wi7JjFUXhjSWkhGDuSgk1gcCGnOTq2ht(0Wm04NkUwb5Z1oFAQpMG9hsf2SpM8jd0kAANKWMbrIJIkNkAsHxovYylelUW)C58)CkydAlK5PWPAKsasfCkjSWkhKcTaenfd4aBqBHSpM85gFqcewHfKpeSHc4JjFYy5yeecwGdb0iaIvqBbFm5Jz(GubR9jbXae0rl2hw7DFRKaYN078rN8XKpnmdn(PIRvqNmOvTs85ANpF95NpivWAFsqmabD0I9H1E33kjG8jrcFqQG1(KGyac6Of7dR9UVvsa5Z1oFUWht(0Wm04NkUwbDYGw1kXNRD(CHpMZPIMu4LtLm2cXIl8pSj(FofSbTfY8u4unsjaPcoLewyLdtGeG8cekqOApWg0wi7JjFUXhKaHvyb5tyT(yYhMaja5fiuGq1(iatulYN078j1(yYNB8jJLdrrvuiWHaAeaXkOTaNkAsHxovYylelUW)8n18)CkydAlK5PWPAKsasfCkvcK8z0YNVhIIQOqaFm5tglhIIQOqGdbyIAr(C1Nl85Npx4Jo6tt9XeS)qQWM9XKp34dsGWkSG8HGnuaFsKWNmwogbHGf4OYOyLs1waXNR(81ht(CJpnm2MX3UNKXwiwhfvFm5dTIM2bPqlartXaokQCQOjfE5ua7OynuQneGl8pF)Y)ZPGnOTqMNcNQrkbivWPYy5quuffcCKQDVwdov0KcVCkbZE1E02idCHlCQmw4)5F(Y)ZPGnOTqMNcNQrkbivWPKWcRCa2rXAOuBiWb2G2czFm5Jz(yMpnmdn(PIRvq(CTZNM6Jjy)HuHn7JjFAySnJVDpa7OynuQne4qaMOwKpP7ZxFm3Nej8XmFUXhPA3R1Wht(yMpsXa(C1NVP2Nej8PHzOXpvCTcYNRD(ORpM7J5(yoNkAsHxofrrvuiax4F0L)NtbBqBHmpfoLgM8wGDH)5lNkAsHxoLkgBFeaHvinGl8p6e)pNc2G2czEkCQgPeGubNYmFUXhjSWkhKcTaenfd4aBqBHSpjs4Zn(yMpnm2MX3UNKXwiwhfvFm5tdJTz8T7jjSzqK4qaMOwKpP35Zf(yUpM7JjFAygA8tfxRGozqRAL4Z1oF(6JjFiGgbqScAl4JjFmZhvgfRuQ2ci(KENpF9jrcFiatulYN078rQ29NumGpM7JjFmZNB8byhfRHsTHazFsKWhcWe1I8j9oFKQD)jfd4Jo6JU(yUpM8XmFKGyaYrkg4j4xUaF6LpeGjQf5ZvFUWht(GubR9jbXae0rl2hw7DFRKaYN0785Rpjs4JeedqosXapb)Yf4tV8HamrTiFU6ZxD9XCov0KcVCkJGqWcWPAP1SWtcIbii(NVCH)5c(FofSbTfY8u4unsjaPcofsfS2Needqq(CTZhD9XKpeGjQf5t6(ORp)8XmFqQG1(KGyacYNRD(WwFm3ht(0Wm04NkUwb5Z1oFUGtfnPWlNQrkgeEFcWOciHl8pSL)NtbBqBHmpfovJucqQGt1Wm04NkUwb5Z1oFUWht(qancGyf0wWht(yMpQmkwPuTfq8j9oF(6tIe(qaMOwKpP35JuT7pPyaFm3ht(yMp34dWokwdLAdbY(KiHpeGjQf5t6D(iv7(tkgWhD0hD9XCFm5JeedqosXapb)Yf4tV8HamrTiFU6ZfCQOjfE5uefvrHaCQwAnl8KGyacI)5lx4cx4ujbcQWl)JUP(7LN6lt3VhD)(LTCQBdYwRbItXMjvtLp9GpxQo4Jp)zb(umQyI4JgM4ZLOsGgMHoKlXhcWMRuei7dcZa(ekcMjei7tJvSga649zdvl4dB1bFyZUifvvmrGSprtk86ZLeQQ20EQ4cH3l5499(Szs1u5tp4ZLQd(4ZFwGpfJkMi(OHj(CjTm6s8HaS5kfbY(GWmGpHIGzcbY(0yfRbGoEF2q1c(CHo4tQam4Kq2hMA1HEO(0ybT7(y2IfFIKrzdAl4tT(amk2qk8AUp9Qx(y2x2n)499(9agvmrGSp9Sprtk86JTqc6495uQeSwzbovV9PhzhAkcK9Hg0WeWNgMHoeFObJArhFs1wdufKplE7fRGWOPy9jAsHxKp41M2X7hnPWl6OsGgMHoKonBGU79JMu4fDujqdZqhYVo9dfdgyLqk869JMu4fDujqdZqhYVo91W4S3V3(qTHkIfw8Hev2hAfnni7dscb5dnOHjGpnmdDi(qdg1I8j2SpQeOxQyrQ1WNc5tgVWX7hnPWl6OsGgMHoKFD6J2qfXclpKecY7hnPWl6OsGgMHoKFD6hQQ20EQ4cHxVF0KcVOJkbAyg6q(1PFgISnTNkUq417hnPWl6OsGgMHoKFD63iLQQTwJNkUq417hnPWl6OsGgMHoKFD6JeiSclVF0KcVOJkbAyg6q(1PVkwk869JMu4fDujqdZqhYVo9zcYDi)0WKxgcHLEQeOHzOd5HGgEZOo2QxP1rIk)GKWkNiNrNAVErQ9(E)E7tpYo0uei7dKeiP5JumGpclWNOjyIpfYNizu2G2chVF0KcVOU7v7U3pAsHx0Vo9tgKkOTGEBWaDWceJ0EeWa2xdZqxlK1lzyvGoybIrAhcya7pvCHWlKF0waYiD8YydAMU6isfS2hRajG5E)OjfEr)60Vfw7lAsH3NTqIEBWaDTmY7hnPWl6xN(eL9fnPW7ZwirVnyGoKaHvybz9kToKaHvyb5dbBOaE)OjfEr)60Vfw7lAsH3NTqIEBWaDzS49JMu4f9Rt)wyTVOjfEF2cj6Tbd0Llc0eVF0KcVOFD6hKwSWtWecSIELwhSaXiTtg0Qwjx7(Y2Fjdsf0w4alqms7radyFnmdDTq27hnPWl6xN(bPfl8uvSiW7hnPWl6xN(2YGLGESHvYgmWkEFVFV9PNWyBgF7I8(rtk8IoTmQtflfE1R06Ov00o0wmoBvqYHartsKqcIbihPyGNGF5csVRNtDIezGwrt7Ke2misCuun1WyBgF7EsgBHyDiatulkD269JMu4fDAz0Vo9PTyC(PPqstVsRld0kAANKWMbrIJIQ3pAsHx0PLr)60NgiiGCVwd9kTUmqROPDscBgejokQE)OjfErNwg9RtFMGChYpnm5LHqyPNeedqELwhtT6GeedqosXapb)YfOxP1jbXaKJumWtWVCbP3Wm04NkUwbDYGw1krh)EyBIeMrIk)GKWkNiNrNAVErQn1Wm04NkUwbDYGw1k5Axt9XeS)qQWMn37hnPWl60YOFD6Ne2misOxP1LXYHOOkke4iv7ETgE)E7Jop2cXYNBlHLpFkdwcsc7DG4ZpF6r2rg6GpSXb7fJcJp9KoZNyZ(0JSJm8HaronF0WeFwGDXNlTNyJ8(rtk8IoTm6xN(jJTqS0R06KWcRC2YGLGKWEhihydAlKnjHfw5aSJI1qP2qGdSbTfYMAygA8tfxRGU21uFmb7pKkSztnm2MX3UhGDuSgk1gcCiatulk9VE)E7Jop2cXYNBlHLpFkdwcsc7DG4ZpF(G9PhzhzOd(WghSxmkm(0t6mFIn7Joh2mis4JIQ3pAsHx0PLr)60pzSfILELwNewyLZwgSeKe27a5aBqBHSPBKWcRCa2rXAOuBiWb2G2cztnmdn(PIRvqx7AQpMG9hsf2SPmqROPDscBgejokQE)E7Jop2cXYNBlHLpuk0cq0umaDWNpyFqcewHL(ifAbiAkgGE(CPbHGfWNub0iaIvqBb98bwSIblFqQrd8rdt8P2gMPwdFU0GqWc4tpPZ8(rtk8IoTm6xN(jJTqS0R06KWcRCqk0cq0umGdSbTfYMUbjqyfwq(qWgkGPmwogbHGf4qancGyf0wWKzivWAFsqmabD0I9H1E33kjGsVtNm1Wm04NkUwbDYGw1k5A33FivWAFsqmabD0I9H1E33kjGsKaPcw7tcIbiOJwSpS27(wjb01Ulm1Wm04NkUwbDYGw1k5A3fM797Tp68ylelFUTew(Wghibi(KQiuGQvh85d2hKaHvy5tSzFwSprtQKGpSXPQp0kAA65tQOOkkeWNfl(uRpeqJaiw(qI1a8(rtk8IoTm6xN(jJTqS0R06KWcRCycKaKxGqbcv7b2G2czt3GeiScliFcR1etGeG8cekqOAFeGjQfLExQnDtglhIIQOqGdb0iaIvqBbVFV9PhzhfRHsTHa(eAcq8j8rtXA9jRqcPWRpPIIQOqaFWeFcFqBOYcl(CPbHGfWNScPwdFqk0cq0umaVF0KcVOtlJ(1PpWokwdLAdb0R06ujqYNrlF(EikQIcbmLXYHOOkke4qaMOw01l(DHo2uFmb7pKkSzt3GeiScliFiydfirImwogbHGf4OYOyLs1wa56xt30WyBgF7EsgBHyDuunrROPDqk0cq0umGJIQ3pAsHx0PLr)60xWSxThTnYGELwxglhIIQOqGJuT71A499(92h2OIanXNCWegGpbDzlPaK3V3(0JBsyXm(eIpx8ZhZy7pFUTew(WgrzUp9Ko74tpGHbYviGnnFWRp6(ZhjigGG0ZNBlHLp6CyZGiHE(Gj(CBjS85Fk9q8blSaYTfc852OeF0WeFqygWhybIrAhFsvlc7ZTrj(uA(0JSJm8PHzOX(uiFAyMAn8rr949JMu4fDYfbAshSjHfZOxP11Wm04NkUwbDT7IFsyHvozaubYdjKqcdG5aBqBHSjZYaTIM2jjSzqK4OOMirgOv00ocM9Q9OTrgokQjsalqms7KbTQvs6D6Y2Fjdsf0w4alqms7radyFnmdDTqorcKkyTpjigGGoAX(WAV7BLeqx701CtMDJewyLdWokwdLAdboWg0wiNirdJTz8T7byhfRHsTHahcWe1IUQR5E)OjfErNCrGM8Rt)KbPcAlO3gmqNccEAL1ce9sgwfORHzOXpvCTc6KbTQvY1Vjsalqms7KbTQvs6D6Y2Fjdsf0w4alqms7radyFnmdDTqorcKkyTpjigGGoAX(WAV7BLeqx7017hnPWl6Klc0KFD6Rf7dR9UVvsaPxP1LmivqBHJccEAL1cetMrROPDyv5mSpABKb0bjr7(1UVSPejqQG1(KGyac6Of7dR9UVvsaDTt3ejOv00ocl4LjqKTysg9Yqdk5GKOD)ANUSjZ9(rtk8Io5Ian5xN(02AZOkd6vADjdsf0w4OGGNwzTaXKz0kAAhABTzuLHJIAIe3iHfw5KewmZJOGyDGnOTq2CVF0KcVOtUiqt(1PpJIu2qa9kTUKbPcAlCuqWtRSwG499(92h2OGjmaFWjbIpsXa(e0LTKcqE)E7dLk0QW6tQOOkkeWheikQ(OHj(0JSJm8(rtk8IozS0ruuffcOxP1jHfw5aSJI1qP2qGdSbTfYMmZSgMHg)uX1kORDn1htW(dPcB2udJTz8T7byhfRHsTHahcWe1Is)R5jsy2ns1UxRHjZKIbU(n1js0Wm04NkUwbDTtxZn3CVFV95sdcblGpkQ3bqvpFclc7Jqka5JG9rbb(uIpbYNWhKk0QW6JbSajemXhnmXhHf4JnqIp9KoZhAqdtaFcF0QTqSaI3pAsHx0jJLFD6RIX2hbqyfsd0tdtElWU0917hnPWl6KXYVo9nccblGET0Aw4jbXaeu3x9kToZUrclSYbPqlartXaoWg0wiNiXnM1WyBgF7EsgBHyDuun1WyBgF7EscBgejoeGjQfLE3fMBUPgMHg)uX1kOtg0Qwjx7(AIaAeaXkOTGjZuzuSsPAlGKE33ejiatulk9oPA3FsXaMBYSBa2rXAOuBiqorccWe1IsVtQ29NumGoQR5MmtcIbihPyGNGF5c6fbyIArxVWesfS2NeedqqhTyFyT39TscO07(MiHeedqosXapb)Yf0lcWe1IU(vxZ9(92NEIumi86ZFGrfqIp41MMp41hgfRuQwWhjigGG8jeFU4Np9KoZNBzbRpeLDR1WhSI4tT(OlYhZuu9rW(CHpsqmabzUpyIp6eYhZy7pFKGyacYCVF0KcVOtgl)60VrkgeEFcWOcirVsRdPcw7tcIbiORD6AIamrTO019NzivWAFsqmabDTJTMBQHzOXpvCTc6A3fE)E7tpmau9rr1NurrvuiGpH4Zf)8bV(ewRpsqmab5Jz3YcwFSvYAn8XIxdFGfRyWYNyZ(SyXh0gQiwyXCVF0KcVOtgl)60NOOkkeqVwAnl8KGyacQ7RELwxdZqJFQ4Af01UlmrancGyf0wWKzQmkwPuTfqsV7BIeeGjQfLENuT7pPyaZnz2na7OynuQneiNibbyIArP3jv7(tkgqh11Ctsqma5ifd8e8lxqViatul66fEFVFV9HsGWkSGSpPAtk8I8(92hkfAbiAkgGo4tQQQAtZhmXNub0iaILp0kAAq2NlnieSaiVF0KcVOdsGWkSGCNrqiyb0RLwZcpjigGG6(QxP1jHfw5GuOfGOPyahydAlKnrancGyf0wWKz3aSJI1qP2qGCIeeGjQfLENuT7pPyaDuxZnjbXaKJumWtWVCb9IamrTOR6697Tpuk0cq0umaDWh2ajbcPYGplMWewFU0GqWcG852sy5dAdvelS4tsGGk8I8P08rybe4sq(ifd49JMu4fDqcewHfK)1PVrqiyb0RLwZcpjigGG6(QxP1jHfw5GuOfGOPyahydAlKnraMOwu6DFtTjvgfRuQ2ciP3910na7OynuQneiBscIbihPyGNGF5c6fbyIArx1173BF(ugSqsyVdeDWhQnurSWIpPIIQOqa98jvTiSpkiWNurrvuiGp4KaXNECtclMXNsZNsUeKplw8juvTfK9Xm2aQWceZ9(rtk8IoibcRWcY)60NOOkkeqVsRRHzOXpvCTc6A3fMmtclSYzldwcsc7DGCGnOTqorIBKQDVwdZnjbXaKJumWtWVCb9IamrTOR9S3pAsHx0bjqyfwq(xN(WMewmJELwxdZqJFQ4Af01UM6Jjy)HuHn79JMu4fDqcewHfK)1PVrqiyb0R06UrclSYbPqlartXaoWg0wiBscIbihPyGNGF5c6fbyIArxVW7hnPWl6GeiScli)RtFTyFyT39Tsci9kToKkyTpjigGGU2PtE)OjfErhKaHvyb5FD6ZOiLneGtHuHg)JUSLnXfUW5a]] )

end