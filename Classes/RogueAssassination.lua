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


    spec:RegisterPack( "Assassination", 20180819.1401, [[d0KJ0aqivv1JeP4sQkkztOQ(KQIsnkkWPOGwLQQ0RuLmluLUfQc2LI(LiYWeP0XuLAzOqptfjnnrQUgQI2Mks8nrs04urkNtKKwNQI07ejLyEIOUNkSpvrhuvrSqrIhQIunrvvHUiQc9rvvrJuKukNuvvWkvfEPQIkUPQIQ2jk4NQkkAOIKWsfjvpfPMQQkxvKusBvKuSxs(RknyjhMQfJKhRWKf1LbBgv(mPA0OOtR0QvvuPxRIA2u62u0UL63qnCs54IKs1Yr8CitN46O02fHVRQW4vv68QiwVQIcZNcTFHvVv)u0zxafdmM23NwApT3P68D6VtL88TIwordu0A(4SRdk62nbf9NGqocTTllUv0A(jwSNv)u0imlzakAMIOH(0KssFfMSuZb2mj0AYADzX9G4CssO1CKeLftLefNZdzirsAem3Abus)wGW47K(X47BQJ1zH7NGqocTTllUNO1COOPyxR8hAfLIo7cOyGX0((0s7P9ovNVtpTV5jpv0oRWetu00R5PROZaAOO)XCrrTOO8O08XzxhIcZfLpKf3rzxKGIIdtIk1gCET7mEep(XeIIA11bKevg42Xkr5suctiktSj0sulkkHPlr9btOJYK1kRMfIcAWCbuuobIsdViCd5O8ohftpbefLfGmkkxtZUqM3OeMquEoJ7O(yT2OASefhMadhjrjmHO8CELf3UnkObI(jrP7Bd5O4iyZOGgmxaf1jy2OCc0F2suIt0bzB9zur9h6OeMyeefAfwxwCJ4nkcGWSKbWd6Ua5OCQ1UYcOOm9tIcXe)ruEuzW6NeLSMajkHPlrLANDhNTNevMG1qrj4pCsoQ0ov02fji1pfnsa3kmHS6NIH3QFkAODklKvPOOhKvaY6k6b2KcF1WBlOOEEev6rXpkdIsCl0YSxDMcsC7zGmH2PSqokJgJsCl0YeXsjaHJvhMq7uwihf)Oe3cTmHViV1z32fycTtzHCu8JcPbw7vCIoiOjN3xm39CVjauujhfJrz0yu)hLSJZBRhLHrXpkXj6GmL1eUc(MxikEikcy6BJI6zuNII2hYIBfnHvtyjGsumWO6NIgANYczvkk6bzfGSUIEGnPWxn82ckQNhrn0UM(3lsd6SI2hYIBfn0jGgBQefdNQ6NIgANYczvkkAFilUv06oHGfqrpiRaK1v0IBHwMiwkbiCS6WeANYc5O4hfb4iaIPtzHO4hLbr9FuWxK36SB7cKJYOXOiGPVnkQKpIs2X5RSMqu)nkgJYWO4hL4eDqMYAcxbFZlefpefbm9Trr9mkgv0Jtgw4korheKIH3krXq6QFkAODklKvPOO9HS4wrR7ecwaf9GScqwxrlUfAzIyPeGWXQdtODklKJIFueW03gfvYhr9oTrXpkntwRSA2firL8ruVJIFu)hf8f5To72Ua5O4hL4eDqMYAcxbFZlefpefbm9Trr9mkgv0Jtgw4korheKIH3krXapv)u0q7uwiRsrrZHj3g(kkgERO9HS4wrRHX2lbqywYauIIHtr9trdTtzHSkff9GScqwxrlUfAzIyPeGWXQdtODklKJIFuIBHwMWxK36SB7cmH2PSqok(rnWyBg)rpHViV1z32fysatFBuujh17O4hLgbsC1h557jHvtyjqu8JkJLjHvtyjWKaM(2OOEgfpJ6vuPh1FJAODn9VxKg0zfTpKf3kADNqWcOeLOOZaNZAf1pfdVv)u0(qwCROpVJZkAODklKvPOefdmQ(POH2PSqwLIIoHBzbfn0ar)Kjb0HoQxrPHxeUH8LYcqgf1FJkvg1NvugefJr93OqAG1Ez6ibIYqfTpKf3k6eozDklOOt4KB7MGIgAGOFYLa6qFhytQTHSsumCQQFkAODklKvPOOhKvaY6kAKaUvyc5jbRZckAFilUv0d3AV(qwCFTlsu02fj32nbfnsa3kmHSsumKU6NIgANYczvkkAFilUv0d3AV(qwCFTlsu02fj32nbf9iJuIIbEQ(POH2PSqwLII2hYIBf9WT2RpKf3x7IefTDrYTDtqrNXIsumCkQFkAODklKvPOO9HS4wrpCR96dzX91UirrBxKCB3eu05LadrjkgsLQFkAODklKvPOOhKvaY6kAObI(jZmWTJvI65ruV5zuVIkHtwNYctObI(jxcOd9DGnP2gYkAFilUv0oz4nCfmHaTOefdNM6NI2hYIBfTtgEdxnwlcu0q7uwiRsrjkgsv1pfTpKf3kA7QZuq3px2SUj0IIgANYczvkkrjkAncmWMuUO(Py4T6NIgANYczvkkrXaJQFkAODklKvPOefdNQ6NIgANYczvkkrXq6QFkAODklKvPOefd8u9tr7dzXTI210SNC1Wlc3kAODklKvPOefdNI6NI2hYIBfnsa3kmv0q7uwiRsrjkgsLQFkAFilUv0AyzXTIgANYczvkkrXWPP(POH2PSqwLII2hYIBfTPtod5lhMCZGlmv0dYkazDfnX38fsaTm9Cgn3oQNrLEAv0AeyGnPC5IGbUZifnpvIsu05Ladr9tXWB1pfn0oLfYQuu0dYkazDf9aBsHVA4TfuuppIk9OEfL4wOLzganGCrcXfxhmNq7uwihf)OmiQmqXYXntaDgeXNSArz0yuzGILJBk4V74sz9mmz1IYOXOGgi6NmZa3owjQKpIIrEg1ROs4K1PSWeAGOFYLa6qFhytQTHCugngfsdS2R4eDqqtoVVyU75EtaOOEEefJrzyu8JYGO(pkXTqlt4lYBD2TDbMq7uwihLrJrnWyBg)rpHViV1z32fysatFBuupJIXOmur7dzXTIg6eqJnvIIbgv)u0q7uwiRsrrNWTSGIEGnPWxn82cAMbUDSsupJ6Dugngf0ar)Kzg42XkrL8rumYZOEfvcNSoLfMqde9tUeqh67aBsTnKJYOXOqAG1EfNOdcAY59fZDp3Bcaf1ZJOyur7dzXTIoHtwNYck6eo52UjOOzrWLBTwGOefdNQ6NIgANYczvkk6bzfGSUIoHtwNYctweC5wRfirXpkkwoUjIPt0GgYxkRNb0ej(4CuppIIXunk(rzqu(NbqwbMiMordAiFPSEgqtI3NJ65rumgLrJrH0aR9korhe0KZ7lM7EU3eakQKpIk9Omur7dzXTIwdViCd575E5aLOyiD1pfn0oLfYQuu0dYkazDfDcNSoLfMSi4YTwlqIIFugefflh3K5MZqFPSEgqtK4JZr98iQ3PAugngfsdS2R4eDqqtoVVyU75EtaOOEEefJr9kkKaUvyc5jbRZcrz0yuuSCCtHjCZeWZwmjJUzyaRmrIpoh1ZJOymvJYqfTpKf3kAoVVyU75EtaiLOyGNQFkAODklKvPOOhKvaY6k6eozDklmzrWLBTwGef)OmikkwoUjLD7mAZWKvlkJgJ6)Oe3cTmtan28syrmNq7uwihLHkAFilUv0u2TZOndkrXWPO(POH2PSqwLIIEqwbiRROt4K1PSWKfbxU1AbII2hYIBfTjRSwxaLOef9iJu)um8w9trdTtzHSkff9GScqwxrtXYXnPSyC2YIKjb8HeLrJrjorhKPSMWvW38crL8ruNsAJYOXOYaflh3mb0zqeFYQff)OgySnJ)ONj8ErmNeW03gfvYrXtfTpKf3kAnSS4wjkgyu9trdTtzHSkff9GScqwxrNbkwoUzcOZGi(Kvtr7dzXTIMYIX5lhl5eLOy4uv)u0q7uwiRsrrpiRaK1v0zGILJBMa6miIpz1u0(qwCROPacciN3wxjkgsx9trdTtzHSkff9GScqwxrNbkwoUzcOZGi(Kvtr7dzXTIMBjaLfJZkrXapv)u0q7uwiRsrrpiRaK1v0zGILJBMa6miIpz1u0(qwCRO9EaiH427WTwLOy4uu)u0q7uwiRsrrpiRaK1v0It0bzkRjCf8nVqujh1aBsHVA4Tf0mdC7yLO(BuVN8mkJgJYGOi(MVqcOLPNZO52r9mQ0tBu8JAGnPWxn82cAMbUDSsuppIAODn9VxKg05Omur7dzXTI20jNH8LdtUzWfMkrXqQu9trdTtzHSkff9GScqwxrNXYKWQjSeyk74826kAFilUv0jGodI4krXWPP(POH2PSqwLIIEqwbiRROf3cTmHViV1z32fycTtzHCu8JYGOe3cTm7vNPGe3EgitODklKJYOXOe3cTmrSucq4y1Hj0oLfYrXpkKgyTxXj6GGMCEFXC3Z9MaqrLCumgLHrXpQb2KcF1WBlOOEEe1q7A6FVinOZrXpQbgBZ4p6j8f5To72Uatcy6BJIk5OERO9HS4wrNW7fXujkgsv1pfn0oLfYQuu0dYkazDfT4wOLzV6mfK42ZazcTtzHCu8J6)Oe3cTmHViV1z32fycTtzHCu8JAGnPWxn82ckQNhrn0UM(3lsd6Cu8JkduSCCZeqNbr8jRMI2hYIBfDcVxetLOy4DAv)u0q7uwiRsrrpiRaK1v0IBHwMiwkbiCS6WeANYc5O4hLbr9FuIBHwMWxK36SB7cmH2PSqokJgJcPbw7vCIoiOjN3xm39CVjauuppIIXOmmk(r9FuibCRWeYtcwNfIIFudm2MXF0tDNqWcmz1IIFuzSm1DcblWKaCeaX0PSqu8JYGOqAG1EfNOdcAY59fZDp3BcafvYhrDQrXpQb2KcF1WBlOzg42Xkr98iQ3r9kkKgyTxXj6GGMCEFXC3Z9Maqrz0yuinWAVIt0bbn58(I5UN7nbGI65ruPhf)Ogytk8vdVTGMzGBhRe1ZJOspkdv0(qwCROt49IyQefdVFR(POH2PSqwLIIEqwbiRROf3cTmnDKaKRJqocT9eANYc5O4h1)rHeWTctipDRnk(rz6ibixhHCeA7lbm9TrrL8ruPnk(r9FuzSmjSAclbMeGJaiMoLfu0(qwCROt49IyQefdVzu9trdTtzHSkff9GScqwxrNXYKWQjSeysatFBuupJk9OEfv6r93OgAxt)7fPbDok(r9FuzSm1DcblWKaCeaX0PSGI2hYIBfn8f5To72UakrXW7tv9trdTtzHSkff9GScqwxrNXYKWQjSeyk74826kAFilUv0c(7oUuwpdkrjk6mwu)um8w9trdTtzHSkff9GScqwxrlUfAzcFrERZUTlWeANYc5O4hLbrzqudSjf(QH3wqr98iQH210)ErAqNJIFudm2MXF0t4lYBD2TDbMeW03gfvYr9okdJYOXOmiQ)Js2X5T1JIFugeLSMqupJ6DAJYOXOgytk8vdVTGI65rumgLHrzyugQO9HS4wrty1ewcOefdmQ(POH2PSqwLIIMdtUn8vum8wr7dzXTIwdJTxcGWSKbOefdNQ6NIgANYczvkkAFilUv06oHGfqrpiRaK1v0ge1)rjUfAzIyPeGWXQdtODklKJYOXO(pkdIAGX2m(JEMW7fXCYQff)OgySnJ)ONjGodI4tcy6BJIk5JOspkdJYWO4h1aBsHVA4Tf0mdC7yLOEEe17O4hfb4iaIPtzHO4hLbrPzYALvZUajQKpI6Dugngfbm9TrrL8ruYooFL1eIYWO4hLbr9FuWxK36SB7cKJYOXOiGPVnkQKpIs2X5RSMqu)nkgJYWO4hLbrjorhKPSMWvW38crXdrratFBuupJk9O4hfsdS2R4eDqqtoVVyU75EtaOOs(iQ3rz0yuIt0bzkRjCf8nVqu8queW03gf1ZOEZyugQOhNmSWvCIoiifdVvIIH0v)u0q7uwiRsrrpiRaK1v0inWAVIt0bbf1ZJOymk(rratFBuujhfJr9kkdIcPbw7vCIoiOOEEefpJYWO4h1aBsHVA4TfuuppIkDfTpKf3k6bznr4(kGPgGeLOyGNQFkAODklKvPOO9HS4wrty1ewcOOhKvaY6k6b2KcF1WBlOOEEev6rXpkcWraetNYcrXpkdIsZK1kRMDbsujFe17OmAmkcy6BJIk5JOKDC(kRjeLHrXpkdI6)OGViV1z32fihLrJrratFBuujFeLSJZxznHO(BumgLHrXpkXj6GmL1eUc(MxikEikcy6BJI6zuPROhNmSWvCIoiifdVvIsuIIobqqlUvmWyAFFAPnvY4PnFZtEEAk6pCsVTosr)hm1WebYrDkr5dzXDu2fjOz8qrRrWCRfu0PjkE8lmyfihffWHjqudSjLlrrb6BJMr9jJbOjOOACZdmDIjhRnkFilUrrHB7jZ4HpKf3OPgbgytkxo4So6C8WhYIB0uJadSjLlVosYz1nHwCzXD8WhYIB0uJadSjLlVosIdJZXJ0efD7AiMyjkIV5OOy54GCuiXfuuuahMarnWMuUeffOVnkkVZrPraEqdlY26rTOOY4gMXdFilUrtncmWMuU86iju7AiMy5IexqXdFilUrtncmWMuU86ijxtZEYvdViChp8HS4gn1iWaBs5YRJKqc4wHz8WhYIB0uJadSjLlVossdllUJh(qwCJMAeyGnPC51rsMo5mKVCyYndUWKxncmWMuUCrWa3z0bp5D5oi(MVqcOLPNZO52ptpTXJ4rAIIh)cdwbYrbjaYjrjRjeLWeIYhcMe1IIYt4R1PSWmE4dzXn648oohp8HS4g96iPeozDklWB7MWb0ar)Klb0H(oWMuBdzEt4ww4aAGOFYKa6q)sdViCd5lLfGm6VPYpldy8VinWAVmDKaggp8HS4g96iPHBTxFilUV2fj82UjCGeWTctiZ7YDGeWTctipjyDwiE4dzXn61rsd3AV(qwCFTls4TDt4yKrXdFilUrVosA4w71hYI7RDrcVTBchzSep8HS4g96iPHBTxFilUV2fj82UjCKxcmK4HpKf3Oxhj5KH3WvWec0cVl3b0ar)Kzg42XkppEZZxjCY6uwycnq0p5saDOVdSj12qoE4dzXn61rsoz4nC1yTiiE4dzXn61rs2vNPGUFUSzDtOL4r8inrD6ySnJ)OrXdFilUrZrgDOHLf38UChuSCCtklgNTSizsaFignkorhKPSMWvW38cjFCkP1OXmqXYXntaDgeXNSA8hySnJ)ONj8ErmNeW03gLmpJh(qwCJMJm61rsuwmoF5yjNW7YDKbkwoUzcOZGi(KvlE4dzXnAoYOxhjrbeeqoVToVl3rgOy54MjGodI4twT4HpKf3O5iJEDKe3saklgN5D5oYaflh3mb0zqeFYQfp8HS4gnhz0RJK8EaiH427WTwExUJmqXYXntaDgeXNSAXdFilUrZrg96ijtNCgYxom5MbxyY7YDiorhKPSMWvW38cjpWMu4RgEBbnZa3ow5VVN80Ordi(MVqcOLPNZO52ptpT8hytk8vdVTGMzGBhR88yODn9VxKg0zdJh(qwCJMJm61rsjGodI48UChzSmjSAclbMYooVTE8inrLA8ErmJ6Jvygfp(fPh1ROmGHvNPGe3Egi8gfMefnlLaeowDikCBpjkCh17Fg(Pr959VRjRzuNEQikVZrXJFr6rrapFsuCysun8vI6pp9)y8WhYIB0CKrVoskH3lIjVl3H4wOLj8f5To72UatODklK5BG4wOLzV6mfK42ZazcTtzHSrJIBHwMiwkbiCS6WeANYcz(inWAVIt0bbn58(I5UN7nbGsMrd5pWMu4RgEBb98yODn9VxKg0z(dm2MXF0t4lYBD2TDbMeW03gL874rAIk149Iyg1hRWmkgwDMcsC7zGe1ROyahfp(fP)Pr959VRjRzuNEQikVZrLAGodI4rXQfp8HS4gnhz0RJKs49IyY7YDiUfAz2RotbjU9mqMq7uwiZ)FXTqlt4lYBD2TDbMq7uwiZFGnPWxn82c65Xq7A6FVinOZ8Zaflh3mb0zqeFYQfpstuPgVxeZO(yfMrrZsjaHJvhI6vugWaokE8lspkmjkg)9YWpnkgWrHeWTcZKqSucq4y1bEJ6pDcblquPoWraetNYc8gf0ywDMrH08befhMe12dS526r9NoHGfiQtpvep8HS4gnhz0RJKs49IyY7YDiUfAzIyPeGWXQdtODklK5BW)IBHwMWxK36SB7cmH2PSq2OrKgyTxXj6GGMCEFXC3Z9Maqppy0q()JeWTctipjyDwG)aJTz8h9u3jeSatwn(zSm1DcblWKaCeaX0PSaFdqAG1EfNOdcAY59fZDp3BcaL8XPYFGnPWxn82cAMbUDSYZJ3VqAG1EfNOdcAY59fZDp3Bcaz0isdS2R4eDqqtoVVyU75EtaONhPZFGnPWxn82cAMbUDSYZJ0nmEKMOsnEViMr9XkmJ6Z7ibir9jiKJ2(tJIbCuibCRWmkVZr14O8HSjGO(8FsuuSCC8gvQZQjSeiQglrTDueGJaiMrr8whIh(qwCJMJm61rsj8Erm5D5oe3cTmnDKaKRJqocT9eANYcz()JeWTctipDRLVPJeGCDeYrOTVeW03gL8rA5)FgltcRMWsGjb4iaIPtzH4rAIIh)I8wNDBxGO(Gj0rrHfMrL6SAclbIY7Cu)PtiybIYjquSArXHjrzXTEuqJz1zgp8HS4gnhz0RJKGViV1z32fG3L7iJLjHvtyjWKaM(2ONP)k9)o0UM(3lsd6m))ZyzQ7ecwGjb4iaIPtzH4HpKf3O5iJEDKKG)UJlL1ZaVl3rgltcRMWsGPSJZBRhpIhPjQ)4sGHev2nDDikNATRSakEKMO4Xob0yZOCjQ0FfLb88vuFScZO(J0gg1PNkMr9hmnH86cypjkChfJVIsCIoiiEJ6JvygvQb6miIZBuysuFScZO(LsQLOWctG8XIGO(Wxjkomjke2eIcAGOFYmQpXIWr9HVsulxu84xKEudSjfoQff1aBUTEuSAZ4HpKf3OzEjWqoGob0ytExUJb2KcF1WBlONhP)sCl0YmdGgqUiH4IRdMtODklK5BqgOy54MjGodI4twnJgZaflh3uWF3XLY6zyYQz0i0ar)Kzg42XkjFWipFLWjRtzHj0ar)Klb0H(oWMuBdzJgrAG1EfNOdcAY59fZDp3Bca98Grd5BW)IBHwMWxK36SB7cmH2PSq2OXbgBZ4p6j8f5To72Uatcy6BJEYOHXdFilUrZ8sGH86iPeozDklWB7MWblcUCR1ceEt4ww4yGnPWxn82cAMbUDSYZ3gncnq0pzMbUDSsYhmYZxjCY6uwycnq0p5saDOVdSj12q2OrKgyTxXj6GGMCEFXC3Z9MaqppymEKMOsf4fHBih1NtVCquUefJP6ROqIpoJIcZffntNObnKJkfRNb0mQuRArj4OspkXj6GGI6JvygvQ795OEZBuMycefwycKpwemJh(qwCJM5Lad51rsA4fHBiFp3lhW7YDKWjRtzHjlcUCR1ce(uSCCtetNObnKVuwpdOjs8X5NhmMQ8nW)maYkWeX0jAqd5lL1ZaAs8(8ZdgnAePbw7vCIoiOjN3xm39CVjauYhPBy8WhYIB0mVeyiVosIZ7lM7EU3eaI3L7iHtwNYctweC5wRfi8nGILJBYCZzOVuwpdOjs8X5NhVtvJgrAG1EfNOdcAY59fZDp3Bca98GXxibCRWeYtcwNfmAKILJBkmHBMaE2Ijz0nddyLjs8X5NhmMQggp8HS4gnZlbgYRJKOSBNrBg4D5os4K1PSWKfbxU1AbcFdOy54Mu2TZOndtwnJg)xCl0Ymb0yZlHfXCcTtzHSHXdFilUrZ8sGH86ijtwzTUa8UChjCY6uwyYIGl3ATajEepstu)r301HOWjasuYAcr5uRDLfqXJ0efTgmw3gvQZQjSeikeiSArXHjrXJFr6XdFilUrZmwoiSAclb4D5oe3cTmHViV1z32fycTtzHmFdmyGnPWxn82c65Xq7A6FVinOZ8hySnJ)ONWxK36SB7cmjGPVnk53gA0Ob)l748268nqwt4570A04aBsHVA4Tf0Zdgn0qdJhPjQ)0jeSarXQDganEJYTiCuczbuucokwee1kr5OO8OqAWyDBu6qdexWKO4WKOeMquwhjrD6PIOOaombIYJIB7fXeiXdFilUrZmwEDKKggBVeaHzjdGxom52Wx54D8WhYIB0mJLxhjP7ecwaEhNmSWvCIoiOJ38UChg8V4wOLjILsachRomH2PSq2OX)nyGX2m(JEMW7fXCYQXFGX2m(JEMa6miIpjGPVnk5J0n0q(dSjf(QH3wqZmWTJvEE8Mpb4iaIPtzb(gOzYALvZUaj5J3gnsatFBuYhYooFL1emKVb)dFrERZUTlq2Orcy6BJs(q2X5RSMWFz0q(giorhKPSMWvW38c8abm9TrptNpsdS2R4eDqqtoVVyU75EtaOKpEB0O4eDqMYAcxbFZlWdeW03g98nJggpstuNoznr4oQFGPgGKOWT9KOWDuMSwz1SquIt0bbfLlrL(ROo9uruFWe6OiSDVTEuywjQTJIruugWQfLGJk9OeNOdcYWOWKOovuugWZxrjorheKHXdFilUrZmwEDK0GSMiCFfWudqcVl3bsdS2R4eDqqppyKpbm9TrjZ4ldqAG1EfNOdc65bpnK)aBsHVA4Tf0ZJ0JhPjQpha0IIvlQuNvtyjquUev6VIc3r5wBuIt0bbfLbFWe6OSBIT1JYIB9OGgZQZmkVZr1yjku7AiMyXW4HpKf3OzglVosIWQjSeG3XjdlCfNOdc64nVl3XaBsHVA4Tf0ZJ05taocGy6uwGVbAMSwz1Slqs(4TrJeW03gL8HSJZxznbd5BW)WxK36SB7cKnAKaM(2OKpKDC(kRj8xgnKV4eDqMYAcxbFZlWdeW03g9m94r8inrrlGBfMqoQpzilUrXJ0efdRotK42ZaH3OWKOOzPKx84xKEu4oQ3)(0OOBxdXelrL6SAclbsTe1Nyr4OyrquPoRMWsGOWjasu8yNaASzulxuR8zJIQXsuUMMDHCug8zQbnqmmE4dzXnAIeWTctiFqy1ewcW7YDmWMu4RgEBb98iD(giUfAz2RotbjU9mqMq7uwiB0O4wOLjILsachRomH2PSqMV4wOLj8f5To72UatODklK5J0aR9korhe0KZ7lM7EU3eakzgnA8FzhN3w3q(It0bzkRjCf8nVapqatFB0ZtjE4dzXnAIeWTcti)6ijOtan2K3L7yGnPWxn82c65Xq7A6FVinOZXJ0efnlLaeowD4tJ6t00SNefMevQdCeaXmQpwHzuuSCCqoQ)0jeSaO4HpKf3Ojsa3kmH8RJK0DcblaVJtgw4korhe0XBExUdXTqltelLaeowDycTtzHmFcWraetNYc8n4F4lYBD2TDbYgnsatFBuYhYooFL1e(lJgYxCIoitznHRGV5f4bcy6BJEYy8inrrZsjaHJvh(0O(mtaeYMHOAmX0Tr9NoHGfaf1hRWmku7AiMyjQeabT4gfp8HS4gnrc4wHjKFDKKUtiyb4DCYWcxXj6GGoEZ7YDiUfAzIyPeGWXQdtODklK5tatFBuYhVtlFntwRSA2fijF8M))WxK36SB7cK5lorhKPSMWvW38c8abm9TrpzmEKMOOzPeGWXQdr9kkE8ls)tJIhtaDu4eaHSzikpku7AiMyjQ)0jeSarrwDMsuoNaKOsDwnHLarrbCycefp(f5To72US4oE4dzXnAIeWTcti)6ijnm2EjacZsgaVCyYTHVYX74HpKf3Ojsa3kmH8RJK0DcblaVl3H4wOLjILsachRomH2PSqMV4wOLj8f5To72UatODklK5pWyBg)rpHViV1z32fysatFBuYV5RrGex9rE(Esy1ewcWpJLjHvtyjWKaM(2ON88v6)DODn9VxKg0zfnsdgkgyKNPQsuIsb]] )

end