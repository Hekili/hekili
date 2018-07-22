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
                local exp = state.debuff.garrote.expires                
                local t = state.query_time

                local remaining = ceil( ( exp - t ) / state.debuff.garrote.tick_time )

                return exp - remaining
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
                local exp = state.debuff.internal_bleeding.expires                
                local t = state.query_time

                local remaining = ceil( ( exp - t ) / state.debuff.internal_bleeding.tick_time )

                return exp - remaining
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
                local exp = state.debuff.rupture.expires                
                local t = state.query_time

                local remaining = ceil( ( exp - t ) / state.debuff.rupture.tick_time )

                return exp - remaining
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
            
            -- usable = function () return boss end,
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


    spec:RegisterPack( "Assassination", 20180721.2115, [[dSulWaqifLEKOQCjrvv1MOO(KQIuJII4uKsTkvf1RuLAwKsULQOAxQ4xIsgMOIoMQKLHI6zIkyAkkUgfP2MQi13ufjJJIeDovrP1PkkENOQQyEIkDpfzFkQoOQiSqrPEOOQYevvKCrrf6JuKWifvvjNuuvfRuv4LIQQs3uvr0ovv5NQkcgkfj1svfrpfjtvvvBLIKSxu9xvAWsDyQwms9yfMSixgSzs1NPWOrHtlz1Qkc9AvLMnLUnj2Ts)gQHtshxuvLA5iEoKPtCDuA7IIVRQW4rroVOkZNuSFH5V4)5ujxa(pMZ5ltzoFkMFDy(vomJPFAoLKNkWPu9Xx3a4uRRaCQNaHCeQwxk8YPu98SypX)ZPqywYa4umerf9mzLLrjmyPpdSswOsH16sH3bX1LSqLYilAlMolAD)5jitwQeSEzbuw)lGW8RS(Z8R7tInyH7tGqocvRlfEpOszWPOzlRK)SCAovYfG)J5C(YuMZNI5xhMFLZNLt5ScdmHtrvk5hNkbObN6pJcfDHI2Jw1hFDdiASE0(qk8gTTqckADmj68xW3YwN4r84pdiA6YWaqs0jqVgLeTlrlmGOvWkWkrxOOfgUe9hmGnAfwRuQwiAybLcqr7eiAvCHWlKI23u0m8mq00wasOODvvBbjTIwyar7PeEJ(JYAJEXs06ycmCKeTWaI2tPsk862OHfig5fTHxlKIwNGvIgwqPau05HzJ2jW(PLOfNyasTgNOJo)zJwyGrq0OsyDPWlsROjacZsgWZnCbsr70LTKcqrR45fnIb(JO9OtG1ZlAPuas0cdxIo)nBn(AZl6ebRIIwWF4Ku058epIh)Ws0E0mynGOtGBpCkBHee)pNcjGBfgqI)N)7f)pNcwN2cjE2CkFifE5ugoHGfGtniLaKY5uIBHvoiwAbi6SgWbwN2cPOnhnb0jaIHtBHOnhTjrpB0atiFnyR1fifTgnrtafVwu05ofTuJVxPuGO)C0mhT2rBoAXjgGCKsbUc(Mki6Nhnbu8ArrppAM5uJ8gw4koXaee)3lUW)Xm)pNcwN2cjE2CkFifE5ugoHGfGtniLaKY5uIBHvoiwAbi6SgWbwN2cPOnhnbu8ArrN7u0VYz0MJwvH1kLQTas05of9ROnh9SrdmH81GTwxGu0MJwCIbihPuGRGVPcI(5rtafVwu0ZJMzo1iVHfUItmabX)9Il8F5a)pNcwN2cjE2CQbPeGuoNAGvOXxvCTck65trpt0MJ2KOf3cRC2YGHGe3(fihyDAlKIwJMONnAPgFR1iATJ2C0Itma5iLcCf8nvq0ppAcO41IIEE0pnNYhsHxofHvvyjax4)MH)NtbRtBHepBo1GucqkNtnWk04RkUwbf98POhQxfNPlsf2eNYhsHxofSzGfRWf(ptZ)ZPG1PTqINnNAqkbiLZPMnAXTWkhelTaeDwd4aRtBHu0MJwCIbihPuGRGVPcI(5rtafVwu0ZJEgoLpKcVCkdNqWcWf(VNM)NtbRtBHepBo1GucqkNtHubR9koXaeu0ZNIoh4u(qk8YP099I1VF3kdG4c)3tX)ZP8Hu4LtPWkL1fGtbRtBHepBUWfovc0DwRW)Z)9I)NtLXj31vaofSaXiVlbmG9oWk01cjofSoTfs8S5u(qk8YPY4KYPTaNkJBzbofSaXiVdbmGn63rRIleEH0L2cqcf9NJ(PIo)pAtIM5O)C0ivWAVmCKarRnx4)yM)NtbRtBHepBoLpKcVCQHBTxFifEV2cjCkBHK76kaNAKqCH)lh4)5uW60wiXZMtniLaKY5uibCRWashc2Gf4u(qk8YPiS71hsH3RTqcNYwi5UUcWPqc4wHbK4c)3m8)CkyDAlK4zZP8Hu4LtnCR96dPW71wiHtzlKCxxb4ujSWf(ptZ)ZPG1PTqINnNYhsHxo1WT2RpKcVxBHeoLTqYDDfGtLkcmeUW)908)CkyDAlK4zZPgKsas5CkybIrENeOxJsIE(u0VmD0VJoJtkN2chybIrExcya7DGvORfsCkFifE5uoz4lCfmHaRWf(VNI)Nt5dPWlNYjdFHRkRfbCkyDAlK4zZf(ptj)pNYhsHxoLTmyiO7NiBYqbwHtbRtBHepBUWfoLkbgyfAx4)5)EX)ZPG1PTqINnx4)yM)NtbRtBHepBUW)Ld8)CkyDAlK4zZf(Vz4)5uW60wiXZMl8FMM)Nt5dPWlNkbEYM3vfxi8YPG1PTqINnx4)EA(FoLpKcVCQbPuvT1ACvXfcVCkyDAlK4zZf(VNI)Nt5dPWlNcjGBfgCkyDAlK4zZf(ptj)pNYhsHxoLkwk8YPG1PTqINnx4)Ew(FofSoTfs8S5u(qk8YPuCYxiD1XKBcCHbNAqkbiLZPmj6zJM4v6czGvoEkHoatfsqrRrt0eVsxidSYXtj0P2ONh9m5mAT5uQeyGvOD5IGbEtioLP5cx4uPIadH)N)7f)pNcwN2cjE2CQbPeGuoNAGvOXxvCTck65trpt0VJwClSYjbGkqUiH4IBakhIVFJ2C0MeDcOz11pzGnbI4hw1O1Oj6eqZQRFemt14sB9eCyvJwJMOHfig5DsGEnkj6CNIMzth97OZ4KYPTWbwGyK3LagWEhyf6AHu0A0ensfS2R4edqqhDFVy973TYaOONpfnZrRD0MJ2KONnAXTWkhGjKVgS16cCG1PTqkAnAIEGX2e(J9amH81GTwxGdbu8ArrppAMJwBoLpKcVCkyZalwHl8FmZ)ZPY4K76kaNIfbx9YAbcNcwN2cjE2CkFifE5uzCs50wGtLXTSaNAGvOXxvCTc6Ka9Aus0ZJ(v0A0enSaXiVtc0RrjrN7u0mB6OFhDgNuoTfoWceJ8UeWa27aRqxlKIwJMOrQG1EfNyac6O77fRF)Uvgaf98POzMl8F5a)pNcwN2cjE2CQbPeGuoNkJtkN2chweC1lRfirBoAtIMMvx)WOsjyV0wpbOds8X3ONpf9RNnAnAIgPcw7vCIbiOJUVxS(97wzau0ZNIM5O1OjAAwD9JWaUjc4jlMKq3emGsoiXhFJE(u0m)SrRnNYhsHxoLUVxS(97wzaex4)MH)NtbRtBHepBo1GucqkNtLXjLtBHdlcU6L1cKOnhTjrtZQRFOT1MqvcoSQrRrt0ZgT4wyLtgyXkxclIXbwN2cPO1Mt5dPWlNI2wBcvjGl8FMM)NtbRtBHepBo1GucqkNtLXjLtBHdlcU6L1ceoLpKcVCkfwPSUaCHlCQrcX)Z)9I)NtbRtBHepBo1GucqkNtrZQRFOTyCYYIKdb8HeTgnrloXaKJukWvW3ubrN7u0pDoJwJMOtanRU(jdSjqe)WQgT5OhySnH)ypz8TqmoeqXRffDUrBAoLpKcVCkvSu4Ll8FmZ)ZPG1PTqINnNAqkbiLZPsanRU(jdSjqe)WQYP8Hu4LtrBX40vNLKhx4)Yb(FofSoTfs8S5udsjaPCovcOz11pzGnbI4hwvoLpKcVCkAGGaY3An4c)3m8)CkyDAlK4zZP8Hu4LtP4KVq6QJj3e4cdo1GucqkNtjoXaKJukWvW3ubrNB0dScn(QIRvqNeOxJsI(Zr)6y6O1OjAtI2KONnAIxPlKbw54Pe6amvibfTgnrt8kDHmWkhpLqNAJEE0ZKZO1oAZrpWk04RkUwbDsGEnkj65trpuVkotxKkSPO1MtjoXaKBPZPCIbihPuGRGVPc4c)NP5)5uW60wiXZMtniLaKY5ujSCiSQclbosn(wRbNYhsHxovgytGiox4)EA(FofSoTfs8S5udsjaPCoL4wyLZwgmeK42Va5aRtBHu0MJwClSYbyc5RbBTUahyDAlKI2C0dScn(QIRvqrpFk6H6vXz6IuHnfT5OhySnH)ypatiFnyR1f4qafVwu05g9loLpKcVCQm(wigCH)7P4)5uW60wiXZMtniLaKY5uIBHvoBzWqqIB)cKdSoTfsrBo6zJwClSYbyc5RbBTUahyDAlKI2C0dScn(QIRvqrpFk6H6vXz6IuHnfT5OtanRU(jdSjqe)WQYP8Hu4LtLX3cXGl8FMs(FofSoTfs8S5udsjaPCoL4wyLdILwaIoRbCG1PTqkAZrpB0ibCRWashc2GfI2C0jSCmCcblWHa6eaXWPTq0MJ2KOrQG1EfNyac6O77fRF)UvgafDUtrNdrBo6bwHgFvX1kOtc0RrjrpFk6xr)oAKkyTxXjgGGo6(EX63VBLbqrRrt0ivWAVItmabD099I1VF3kdGIE(u0ZeT5OhyfA8vfxRGojqVgLe98PONjAT5u(qk8YPY4BHyWf(VNL)NtbRtBHepBo1GucqkNtjUfw5O4ibixhHCeQ2dSoTfsrBo6zJgjGBfgq64wB0MJwXrcqUoc5iuTxcO41IIo3POZz0MJE2Oty5qyvfwcCiGobqmCAlWP8Hu4LtLX3cXGl8FVYj)pNcwN2cjE2CQbPeGuoNsLazUgJ051HWQkSeiAZrNWYHWQkSe4qafVwu0ZJEMOFh9mr)5OhQxfNPlsf2u0MJE2Orc4wHbKoeSbleTgnrNWYXWjeSahvfwRuQ2cirpp6xrBo6zJEGX2e(J9KX3cX4WQgT5OPz11piwAbi6SgWHvLt5dPWlNcyc5RbBTUaCH)71l(FofSoTfs8S5udsjaPCovclhcRQWsGJuJV1AWP8Hu4LtjyMQXL26jGlCHtLWc)p)3l(FofSoTfs8S5udsjaPCoL4wyLdWeYxd2ADboW60wifT5OnjAtIEGvOXxvCTck65trpuVkotxKkSPOnh9aJTj8h7byc5RbBTUahcO41IIo3OFfT2rRrt0Me9Srl14BTgrBoAtIwkfi65r)kNrRrt0dScn(QIRvqrpFkAMJw7O1oAT5u(qk8YPiSQclb4c)hZ8)CkyDAlK4zZP0XK7cmj8FV4u(qk8YPuXy7LaimlzaCH)lh4)5uW60wiXZMt5dPWlNYWjeSaCQbPeGuoNYKONnAXTWkhelTaeDwd4aRtBHu0A0e9SrBs0dm2MWFSNm(wighw1Onh9aJTj8h7jdSjqe)qafVwu05of9mrRD0AhT5OhyfA8vfxRGojqVgLe98POFfT5OjGobqmCAleT5OnjAvfwRuQ2cirN7u0VIwJMOjGIxlk6CNIwQX3Rukq0AhT5Onj6zJgyc5RbBTUaPO1OjAcO41IIo3POLA89kLce9NJM5O1oAZrBs0Itma5iLcCf8nvq0ppAcO41IIEE0ZeT5OrQG1EfNyac6O77fRF)UvgafDUtr)kAnAIwCIbihPuGRGVPcI(5rtafVwu0ZJ(fZrRnNAK3WcxXjgGG4)EXf(Vz4)5uW60wiXZMtniLaKY5uivWAVItmabf98POzoAZrtafVwu05gnZr)oAtIgPcw7vCIbiOONpfTPJw7Onh9aRqJVQ4Afu0ZNIEgoLpKcVCQbPuq49kGIkGeUW)zA(FofSoTfs8S5u(qk8YPiSQclb4udsjaPCo1aRqJVQ4Afu0ZNIEMOnhnb0jaIHtBHOnhTjrRQWALs1waj6CNI(v0A0enbu8ArrN7u0sn(ELsbIw7OnhTjrpB0atiFnyR1fifTgnrtafVwu05ofTuJVxPuGO)C0mhT2rBoAXjgGCKsbUc(Mki6Nhnbu8Arrpp6z4uJ8gw4koXaee)3lUWfUWPYaeuHx(pMZ5ltzoFkMFDy(voFwo1hozR1aXP4uivyW)XSPFwoLkbRxwGtLVOZrMGbRaPOPbDmbIEGvODjAAWOw0j6Nymavbf9I3NZWjk6S2O9Hu4ffnET5DIh(qk8IoQeyGvODzs36OVXdFifErhvcmWk0U8EklN1qbwXLcVXdFifErhvcmWk0U8EklDmofpYx0uRRIyGLOjELIMMvxhsrJexqrtd6yce9aRq7s00GrTOO9nfTkbEUkwKAnIUqrNWlCIh(qk8IoQeyGvOD59uwO1vrmWYfjUGIh(qk8IoQeyGvOD59uwjWt28UQ4cH34HpKcVOJkbgyfAxEpL1GuQQ2AnUQ4cH34HpKcVOJkbgyfAxEpLfsa3kmIh(qk8IoQeyGvOD59uwQyPWB8WhsHx0rLadScTlVNYsXjFH0vhtUjWfgAPsGbwH2Llcg4nHMmTwL(KjZs8kDHmWkhpLqhGPcjinAiELUqgyLJNsOtTZNjNAhpIh5l6CKjyWkqkAidqYlAPuGOfgq0(qWKOlu0EgVSoTfoXdFifErtzCs50wqR1vGjybIrExcya7DGvORfsALXTSWeSaXiVdbmG9TkUq4fsxAlaj0NFQ8Fty(ZivWAVmCKaAhp8Hu4f9EkRHBTxFifEV2cjATUcmnsO4HpKcVO3tzry3RpKcVxBHeTwxbMqc4wHbK0Q0Nqc4wHbKoeSblep8Hu4f9EkRHBTxFifEV2cjATUcmLWs8WhsHx07PSgU1E9Hu49AlKO16kWuQiWqIh(qk8IEpLLtg(cxbtiWkAv6tWceJ8ojqVgLmF6LPFNXjLtBHdSaXiVlbmG9oWk01cP4HpKcVO3tz5KHVWvL1IG4HpKcVO3tzzldgc6(jYMmuGvIhXJ8fD(HX2e(Jffp8Hu4fDgj0Kkwk8QvPprZQRFOTyCYYIKdb8HOrJ4edqosPaxbFtfK70tNtnAsanRU(jdSjqe)WQAEGX2e(J9KX3cX4qafVwuUMoE4dPWl6msO3tzrBX40vNLKNwL(ucOz11pzGnbI4hw14HpKcVOZiHEpLfnqqa5BTgAv6tjGMvx)Kb2eiIFyvJh(qk8IoJe69uwko5lKU6yYnbUWqlXjgGCl9jLAFgXjgGCKsbUc(MkqRsFsCIbihPuGRGVPcYDGvOXxvCTc6Ka9AuYNFDmTgnMyYSeVsxidSYXtj0byQqcsJgIxPlKbw54Pe6u78zYP2MhyfA8vfxRGojqVgLmFAOEvCMUivytAhp8Hu4fDgj07PSYaBceX1Q0Nsy5qyvfwcCKA8TwJ4r(I2u5BHye9hLWi6FLbdbjU9lqI(D05itiJNj6pPZuPWQeD(zQJ23u05itiJOjGNYlADmj6fysI2uKFFQ4HpKcVOZiHEpLvgFledTk9jXTWkNTmyiiXTFbYbwN2cjZIBHvoatiFnyR1f4aRtBHK5bwHgFvX1kO5td1RIZ0fPcBY8aJTj8h7byc5RbBTUahcO41IY9v8iFrBQ8TqmI(Jsye9VYGHGe3(fir)o6F4OZrMqgpt0FsNPsHvj68ZuhTVPOnvWMar8OzvJh(qk8IoJe69uwz8Tqm0Q0Ne3cRC2YGHGe3(fihyDAlKmpR4wyLdWeYxd2ADboW60wizEGvOXxvCTcA(0q9Q4mDrQWMmNaAwD9tgytGi(HvnEKVOnv(wigr)rjmIMILwaIoRb8mr)dhnsa3kmYcXslarN1a0kAtHtiybI(jbDcGy40wqROHfZAWiAKQpGO1XKORDGvQ1iAtHtiybIo)m1XdFifErNrc9EkRm(wigAv6tIBHvoiwAbi6SgWbwN2cjZZIeWTcdiDiydwWCclhdNqWcCiGobqmCAly2eKkyTxXjgGGo6(EX63VBLbq5oLdMhyfA8vfxRGojqVgLmF61BKkyTxXjgGGo6(EX63VBLbqA0GubR9koXae0r33lw)(DRmaA(0mMhyfA8vfxRGojqVgLmFAgTJh5lAtLVfIr0FucJO)Kosas0pbc5OAFMO)HJgjGBfgr7Bk6fhTpKkde9N8jIMMvxxROFswvHLarVyj6AJMa6eaXiAIVgq8WhsHx0zKqVNYkJVfIHwL(K4wyLJIJeGCDeYrOApW60wizEwKaUvyaPJBTMvCKaKRJqocv7LakETOCNYP5zty5qyvfwcCiGobqmCAlepYx05itiFnyR1fiAxxas0E06SwB0jwIlfEJ(jzvfwcenMeThnADvgyjAtHtiybIoXsQ1iAelTaeDwdiE4dPWl6msO3tzbmH81GTwxaTk9jvcK5AmsNxhcRQWsaZjSCiSQclboeqXRfnFM3Z85H6vXz6IuHnzEwKaUvyaPdbBWcA0KWYXWjeSahvfwRuQ2ciZFzE2bgBt4p2tgFleJdRQzAwD9dILwaIoRbCyvJh(qk8IoJe69uwcMPACPTEc0Q0Nsy5qyvfwcCKA8TwJ4r8iFr)PkcmKOtUIBar70LTKcqXJ8fDoUzGfReTlrpZ7OnX0VJ(Jsye9NIs7OZpt9j68hffivUa28IgVrZ87OfNyacsRO)OegrBQGnbI4AfnMe9hLWi6)zN)jASWaiFuii6p8sIwhtIgHvGOHfig5DI(jSiC0F4LeDPhDoYeYi6bwHghDHIEGvQ1iAw1t8WhsHx0jveyitWMbwSIwL(0aRqJVQ4Af08PzElUfw5KaqfixKqCXnaLdSoTfsMnjb0S66NmWMar8dRQgnjGMvx)iyMQXL26j4WQQrdSaXiVtc0Rrj5oXSPFNXjLtBHdSaXiVlbmG9oWk01cjnAqQG1EfNyac6O77fRF)UvganFIzTnBYSIBHvoatiFnyR1f4aRtBHKgndm2MWFShGjKVgS16cCiGIxlAoZAhp8Hu4fDsfbgY7PSY4KYPTGwRRatSi4Qxwlq0kJBzHPbwHgFvX1kOtc0RrjZFPrdSaXiVtc0Rrj5oXSPFNXjLtBHdSaXiVlbmG9oWk01cjnAqQG1EfNyac6O77fRF)UvganFI54HpKcVOtQiWqEpLLUVxS(97wzaKwL(ugNuoTfoSi4QxwlqmBcnRU(HrLsWEPTEcqhK4JVZNE9SA0GubR9koXae0r33lw)(DRmaA(eZA0qZQRFegWnrapzXKe6MGbuYbj(478jMFwTJh(qk8IoPIad59uw02AtOkbAv6tzCs50w4WIGREzTaXSj0S66hABTjuLGdRQgnZkUfw5KbwSYLWIyCG1PTqs74HpKcVOtQiWqEpLLcRuwxaTk9PmoPCAlCyrWvVSwGepIh5l6pLR4gq04majAPuGOD6YwsbO4r(IMsfgLBJ(jzvfwcencew1O1XKOZrMqgXdFifErNewMiSQclb0Q0Ne3cRCaMq(AWwRlWbwN2cjZMyYaRqJVQ4Af08PH6vXz6IuHnzEGX2e(J9amH81GTwxGdbu8Ar5(sBnAmzwPgFR1WSjsPaZFLtnAgyfA8vfxRGMpXS2ARD8iFrBkCcblq0SQFbqvRODlchTqkafTGJMfbrxs0okApAKkmk3gTbSaXfmjADmjAHbeT1rs05NPoAAqhtGO9O1RTqmas8WhsHx0jHL3tzPIX2lbqywYa0shtUlWKm9kE4dPWl6KWY7PSmCcblGwJ8gw4koXae00lTk9jtMvClSYbXslarN1aoW60wiPrZSMmWyBc)XEY4BHyCyvnpWyBc)XEYaBceXpeqXRfL70mART5bwHgFvX1kOtc0RrjZNEzMa6eaXWPTGztuvyTsPAlGK70lnAiGIxlk3jPgFVsPaAB2KzbMq(AWwRlqsJgcO41IYDsQX3RukWNzwBZMioXaKJukWvW3ubpNakETO5ZygPcw7vCIbiOJUVxS(97wzauUtV0OrCIbihPuGRGVPcEobu8ArZFXS2XJ8fD(rkfeEJ(pOOcijA8AZlA8gTcRvkvleT4edqqr7s0Z8o68Zuh9hmGnAc7U1AenMvIU2OzgfTjSQrl4ONjAXjgGG0oAmj6CafTjM(D0ItmabPD8WhsHx0jHL3tzniLccVxbuubKOvPpHubR9koXae08jMntafVwuUm)2eKkyTxXjgGGMpzATnpWk04RkUwbnFAM4r(Io)laQrZQg9tYQkSeiAxIEM3rJ3ODRnAXjgGGI2KpyaB02ktTgrBXRr0WIznyeTVPOxSenADvedSOD8WhsHx0jHL3tzryvfwcO1iVHfUItmabn9sRsFAGvOXxvCTcA(0mMjGobqmCAly2evfwRuQ2ci5o9sJgcO41IYDsQX3RukG2MnzwGjKVgS16cK0OHakETOCNKA89kLc8zM12S4edqosPaxbFtf8CcO41IMpt8iEKVOPeWTcdif9tmKcVO4r(IMILwaIoRb8mr)eQQ28IgtI(jbDcGyennRUoKI2u4ecwau8WhsHx0bjGBfgqAYWjeSaAnYByHR4edqqtV0Q0Ne3cRCqS0cq0znGdSoTfsMjGobqmCAly2KzbMq(AWwRlqsJgcO41IYDsQX3RukWNzwBZItma5iLcCf8nvWZjGIxlAoZXJ8fnflTaeDwd4zI(tidqivcIEXef3gTPWjeSaOO)OegrJwxfXalrNbiOcVOOl9Ofgab(0OOLsbIh(qk8IoibCRWasVNYYWjeSaAnYByHR4edqqtV0Q0Ne3cRCqS0cq0znGdSoTfsMjGIxlk3Px50SQcRvkvBbKCNEzEwGjKVgS16cKmloXaKJukWvW3ubpNakETO5mhpYx0)kdgiXTFbYZen16Qigyj6NKvvyjGwr)eweoAwee9tYQkSeiACgGeDoUzGfReDPhDjFAu0lwI2vvTfKI2KpbvybI2XdFifErhKaUvyaP3tzryvfwcOvPpnWk04RkUwbnFAgZMiUfw5SLbdbjU9lqoW60wiPrZSsn(wRH2MfNyaYrkf4k4BQGNtafVw08NoE4dPWl6GeWTcdi9EklyZalwrRsFAGvOXxvCTcA(0q9Q4mDrQWMIh(qk8IoibCRWasVNYYWjeSaAv6tZkUfw5GyPfGOZAahyDAlKmloXaKJukWvW3ubpNakETO5Zep8Hu4fDqc4wHbKEpLLUVxS(97wzaKwL(esfS2R4edqqZNYH4HpKcVOdsa3kmG07PSuyLY6cWfUW5a]] )

end