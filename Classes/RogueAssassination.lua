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
        local stealth = FindUnitBuffByID( "player", 1784 ) or FindUnitBuffByID( "player", 115191 ) or FindUnitBuffByID( "player", 115192 ) or FindUnitBuffByID( "player", 11327 ) or GetTime() - stealth_dropped < 0.2

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
    
        potion = "battle_potion_of_agility",
        
        package = "Assassination",
    } )


    spec:RegisterPack( "Assassination", 20180911.2212, [[dW0Ibbqia0Jqk5sIOiTjsPpbiOgLivNsuXQePuVcOAwIi3caAxs8lurddaCma1Yev5zaLAAiL6AIuSnGs8naHACIOW5ePK1HkjVdvcL5biDpGSpKIdkIkluuvpuevnraHCruj1hrLGtIkHSsa6LIOOUjGa7Ku4NIOigkQeTuarpfLMkPORcii2kqj9vabP9sP)cQbl1HPAXi5XsAYuCzvBgfFgvnAKQtR0QrLq1RrfMnj3wu2TIFdz4KQLd1ZrmDIRdY2fHVlQ04rL68afRxeLMViz)cBb2QPL14YTAKhaaCYaaslGbUKxEadCAsllRag9Bz19kho)TSJNDlBYrioHSJllASS6oyui3y10Ysqq46TS0frNWvCYj)k0HOkvugNKnds5YIMk2zeojBwLtkfIItkghanpbN6yeZQoHtUeFG0xdHtUeiHbsep0HtocXjKDCzrtHSzvllf0QeUOXszznUCRg5baaNmaG0cyGl5LhWaNhyXY6qcDe2YYUzjVL1Cs1YsROtocXjKDCzrt0ajIh6bG0kA6IOt4ko5KFf6quLkkJtYMbPCzrtf7mcNKnRYjLcrXjfJdGMNGtDmIzvNWjxIpq6RHWjxcKWajIh6WjhH4eYoUSOPq2SAaiTIM96YZOooAGboPOZdaaozenagnWaaxbmWrZLabbGbG0k6KNUp8NWvbG0kAam6KZyUj6K5TYr0ckAZzCiLeTxLfnrRwIucaPv0ay0a5ZqjE0IJ5VaVmLaqAfnagnxpoL6MObRFmxepAbfDUimhrNHWpAeJ8j6CP)jAcsHIoDQxDiYJgmiOOR(aewIgS6ZsOhTRqZZPyzvlriwnTSe5UsOFJvtRgaB10Y(XPu3yZ3YwXRC86w2kkJcbRJ2rirtdOOPD0AJo9Ofx9rkZYtxiIR444YhNsDt0PsfT4QpsHarjhZaX)YhNsDt0AJwC1hPCUj(WdTJlV8XPu3eT2ORiKYGYDkNBIp8q74Yl4N57qIgOGIoVO1gDchVoL6fYo8QdloM)s0PsfnaJw2kh7WhDorRnAXX8xkYMDybbB2hnagn(z(oKOPjAWIL1RYIgllgsxGW3kwnYZQPL9JtPUXMVLTIx541TSvugfcwhTJqIMgqrx1HZCUHj6FmwwVklASSFs8bLzfRgGTvtl7hNsDJnFlRxLfnwwEhJrYTSv8khVULvC1hPqGOKJzG4F5JtPUjATrJpd(e6oL6rRnAXX8xkYMDybbB2hnagn(z(oKOPj68SSvWuvhwCm)fIvdGTIvdAB10Y(XPu3yZ3Y6vzrJLL3XyKClBfVYXRBzfx9rkeik5ygi(x(4uQBIwB04N57qIgOGIgyaiATrRNbPKvxThhnqbfnWrRnAXX8xkYMDybbB2hnagn(z(oKOPj68SSvWuvhwCm)fIvdGTIvJ0y10Y(XPu3yZ3YwXRC86wwXvFKcbIsoMbI)LpoL6MO1gTNShVYle6yeK5gyceddQ6YIMYhNsDt0AJgGrBqsbdPlq4xKTYXo8wwVklASSyiDbcFRy1aSy10Y(XPu3yZ3Y6vzrJLL3XyKClBfVYXRBzfx9rkeik5ygi(x(4uQBIwB0EYE8kVqOJrqMBGjqmmOQllAkFCk1nrRnAXX8xkYMDybbB2hnnrJFMVdXYwbtvDyXX8xiwna2kwnaITAAz)4uQBS5Bzzqy45Clwna2Y6vzrJLvhHuW4tqq46TIvJKHvtl7hNsDJnFlBfVYXRBzfx9rkeik5ygi(x(4uQBIwB0IR(iLZnXhEODC5LpoL6MO1gDfHuguUt5Ct8HhAhxEb)mFhs0anAGJwB064NaMVAkaxWq6ce(rRnAdskyiDbc)c(z(oKOPj60en4rt7Ot7OR6Wzo3We9pglRxLfnwwEhJrYTIvSSMZ4qkXQPvdGTAAz)4uQBS5Bzt4kOBz)Cmpyk4Z)jAWJwhTe0CdmL63qIoTJgio6KPrNE05fDAhnr)kfmDNip6CSSEvw0yzt441Pu3YMWXWJNDl7NJ5bdm(8FGROmQDUXkwnYZQPL9JtPUXMVLnHRGULLOFLcwCm)fsHXhyedmhZM4KObA05zz9QSOXYMWXRtPULnHJHhp7wwYo8QdloM)IvSAa2wnTSEvw0yz5yRCyz)4uQBS5BfRg02QPL9JtPUXMVLTIx541TSe5UsOFtbJ4HUL1RYIglB1vkyVklAGvlrSSQLiWJNDllrURe63yfRgPXQPL9JtPUXMVL1RYIglB1vkyVklAGvlrSSQLiWJNDlB1qSIvdWIvtl7hNsDJnFlRxLfnw2QRuWEvw0aRwIyzvlrGhp7wwdsSIvdGyRMw2poL6gB(wwVklASSvxPG9QSObwTeXYQwIapE2TSMf)QyfRgjdRMw2poL6gB(w2kELJx3Y(5yEWumNzRRennGIg40en4rNWXRtPE5ZX8GbgF(pWvug1o3yz9QSOXY64Qphwqy8hXkwnslRMwwVklASSoU6ZH1HuKBz)4uQBS5BfRgadawnTSEvw0yzvlpDHaZfhYWN9rSSFCk1n28TIvSS64xrzuUy10QbWwnTSFCk1n28TIvJ8SAAz)4uQBS5BfRgGTvtl7hNsDJnFRy1G2wnTSFCk1n28TIvJ0y10Y6vzrJL111vGbwhTe0yz)4uQBS5BfRgGfRMwwVklASSe5UsOBz)4uQBS5BfRgaXwnTSEvw0yz1rYIgl7hNsDJnFRy1izy10Y(XPu3yZ3Y6vzrJLnZXCCdmdcdBUl0TSv8khVULf7Rb(j(if3yiLDIMMOPnayz1XVIYOCbM8kAmelBASIvSSMf)Qy10QbWwnTSFCk1n28TSv8khVULTIYOqW6ODes00akAAhn4rlU6Jum)6hdteSlo)ZkFCk1nrRn60J2CkigMsIpMlIxG0JovQOnNcIHPiiU3kmLYnVaPhDQur)5yEWumNzRRenqbfDEPjAWJoHJxNs9YNJ5bdm(8FGROmQDUj6uPIgGrNWXRtPEHSdV6WIJ5VeDorRn60JgGrlU6Juo3eF4H2XLx(4uQBIovQORiKYGYDkNBIp8q74Yl4N57qIMMOZl6CSSEvw0yz)K4dkZkwnYZQPL9JtPUXMVLnHRGULTIYOqW6ODesXCMTUs00enWrNkv0FoMhmfZz26krduqrNxAIg8Ot441PuV85yEWaJp)h4kkJANBIovQOby0jC86uQxi7WRoS4y(lwwVklASSjC86uQBzt4y4XZULfICyMvPo2kwnaBRMw2poL6gB(w2kELJx3YMWXRtPEbICyMvPooATrtbXWui0DS(NBGPuU5Kcr8khrtdOOZlTSSEvw0yz1rlbn3aZXSm3kwnOTvtl7hNsDJnFlBfVYXRBzt441PuVaromZQuhhT2OtpAkigMc91y(atPCZjfI4voIMgqrdCAfDQurt0VsbloM)cPW4dmIbMJztCs00ak68Ig8OjYDLq)McgXd9OtLkAkigMIq)Wg8DJcHneyZRFLcr8khrtdOOZlTIohlRxLfnwwgFGrmWCmBItSIvJ0y10Y(XPu3yZ3YwXRC86w2eoEDk1lqKdZSk1XrRn60JMcIHPqP2XqwZlq6rNkv0amAXvFKsIpOmymeHE5JtPUj6CSSEvw0yzPu7yiR5wXQbyXQPL9JtPUXMVLTIx541TSjC86uQxGihMzvQJTSEvw0yzZGKv5YTIvSSvdXQPvdGTAAz)4uQBS5BzR4voEDllfedtHsHqgferk47vj6uPIwCm)LISzhwqWM9rduqrdwaGOtLkAZPGyykj(yUiEbspATrxriLbL7us4ZsOxWpZ3HenqJonwwVklASS6izrJvSAKNvtl7hNsDJnFlRxLfnwwEx9QRuhtGPqOXYwXRC86w2kcPmOCNsIpMlIxWpZ3HenqbfnWrRn60JgGrlU6JuiquYXmq8V8XPu3eDQurBqsH3XyK8IEgKswD1EC00enWrNt0PsfDfHuguUtjXhZfXl4N57qIMMOPDASSJNDllVRE1vQJjWui0yfRgGTvtl7hNsDJnFlBfVYXRBznNcIHPK4J5I4fiDlRxLfnwwkfczGzGWGXkwnOTvtl7hNsDJnFlBfVYXRBznNcIHPK4J5I4fiDlRxLfnwwQJjhZXo8wXQrASAAz)4uQBS5BzR4voEDlR5uqmmLeFmxeVaPBz9QSOXYYS4tPqiJvSAawSAAz)4uQBS5BzR4voEDlR5uqmmLeFmxeVaPBz9QSOXY6t9eb7k4QRuwXQbqSvtl7hNsDJnFlBfVYXRBzX(AGFIpsXngsbspATrNE0IJ5VuKn7Wcc2SpAGgDfLrHG1r7iKI5mBDLOt7ObUKMOtLk6kkJcbRJ2rifZz26krtdOOR6Wzo3We9pMOZXY6vzrJLnZXCCdmdcdBUl0TIvJKHvtl7hNsDJnFlBfVYXRBzX(AGFIpsXngszNOPjAWgaIgaJg7Rb(j(if3yifde2LfnrRn6kkJcbRJ2rifZz26krtdOOR6Wzo3We9pglRxLfnw2mhZXnWmimS5Uq3kwnslRMw2poL6gB(w2kELJx3YcWOjYDLq)McgXd9O1gTbjfmKUaHFr2kh7WhT2OtpAagT4QpsHarjhZaX)YhNsDt0PsfnaJ2t2Jx5fcDmcYCdmbIHbvDzrt5JtPUj6uPI2GKcVJXi5f9miLS6Q94OPjAGJovQOby08yeKE05yz9QSOXYM4J5I4wXQbWaGvtl7hNsDJnFlBfVYXRBzfx9rkeik5ygi(x(4uQBIwB0amAdsk8ogJKxKTYXo8rRn6eoEDk1lKD4vhwCm)flRxLfnw2e(Se6wXQbWaB10Y(XPu3yZ3YwXRC86wwXvFKY5M4dp0oU8YhNsDt0AJo9Ofx9rkZYtxiIR444YhNsDt0PsfT4QpsHarjhZaX)YhNsDt0AJoHJxNs9czhE1HfhZFj6CIwB0vugfcwhTJqIMgqrx1HZCUHj6FmrRn6kcPmOCNY5M4dp0oU8c(z(oKObA0ahT2OtpAagT4QpsHarjhZaX)YhNsDt0PsfnaJ2t2Jx5fcDmcYCdmbIHbvDzrt5JtPUj6uPI2GKcVJXi5f9miLS6Q94ObkOObo6CSSEvw0yzt4ZsOBfRgaNNvtl7hNsDJnFlBfVYXRBzfx9rkZYtxiIR444YhNsDt0AJgGrlU6Juo3eF4H2XLx(4uQBIwB0vugfcwhTJqIMgqrx1HZCUHj6FmrRnAZPGyykj(yUiEbs3Y6vzrJLnHplHUvSAamyB10Y(XPu3yZ3YwXRC86wwXvFKcbIsoMbI)LpoL6MO1gD6rdWOfx9rkNBIp8q74YlFCk1nrNkv0am6eoEDk1lKD4vhwCm)LOZjATrdWOjYDLq)McgXd9O1gDfHuguUtH3XyK8cKE0AJ2GKcVJXi5f8zWNq3PupATrNE0e9RuWIJ5Vqkm(aJyG5y2eNenqbfnyhT2OROmkeSoAhHumNzRRennGIg4ObpAI(vkyXX8xifgFGrmWCmBItIovQOj6xPGfhZFHuy8bgXaZXSjojAAafnTJwB0vugfcwhTJqkMZS1vIMgqrt7OZXY6vzrJLnHplHUvSAamTTAAz)4uQBS5BzR4voEDlR4QpsjZjYXWoH4eYoLpoL6MO1gnaJMi3vc9BkUsfT2OZCICmStioHSdm(z(oKObkOObGO1gnaJ2GKcgsxGWVGpd(e6oL6wwVklASSj8zj0TIvdGtJvtl7hNsDJnFlBfVYXRBzniPGH0fi8l4N57qIMMOPD0GhnTJoTJUQdN5Cdt0)yIwB0amAdsk8ogJKxWNbFcDNsDlRxLfnw2ZnXhEODC5wXQbWGfRMw2poL6gB(w2kELJx3YAqsbdPlq4xKTYXo8wwVklASScI7TctPCZTIvSSgKy10QbWwnTSFCk1n28TSv8khVULvC1hPCUj(WdTJlV8XPu3eT2Otp60JUIYOqW6ODes00ak6QoCMZnmr)JjATrxriLbL7uo3eF4H2XLxWpZ3HenqJg4OZj6uPIo9Oby0Yw5yh(O1gD6rlB2JMMObgaIovQOROmkeSoAhHennGIoVOZj6CIohlRxLfnwwmKUaHVvSAKNvtl7hNsDJnFlldcdpNBXQbWwwVklASS6iKcgFcccxVvSAa2wnTSFCk1n28TSEvw0yz5Dmgj3YwXRC86w20JgGrlU6JuiquYXmq8V8XPu3eDQurdWOtp6kcPmOCNscFwc9cKE0AJUIqkdk3PK4J5I4f8Z8Dirduqrt7OZj6CIwB0vugfcwhTJqkMZS1vIMgqrdC0AJgFg8j0Dk1JwB0PhTEgKswD1EC0afu0ahDQurJFMVdjAGckAzRCalB2JwB0e9RuWIJ5Vqkm(aJyG5y2eNennGIgSJg8O9K94vEHqhJGm3atGyyqvxw0u(4uQBIoNO1gD6rdWOp3eF4H2XLBIovQOXpZ3HenqbfTSvoGLn7rN2rNx0AJMOFLcwCm)fsHXhyedmhZM4KOPbu0GD0GhTNShVYle6yeK5gyceddQ6YIMYhNsDt05eT2OtpAXX8xkYMDybbB2hnagn(z(oKOPjAAhT2Oj6xPGfhZFHuy8bgXaZXSjojAGckAGJovQOfhZFPiB2HfeSzF0ay04N57qIMMOboVOZXYwbtvDyXX8xiwna2kwnOTvtl7hNsDJnFlBfVYXRBzj6xPGfhZFHennGIoVO1gn(z(oKObA05fn4rNE0e9RuWIJ5VqIMgqrNMOZjATrxrzuiyD0ocjAAafnTTSEvw0yzR4nJGgy5z6NiwXQrASAAz)4uQBS5Bz9QSOXYIH0fi8TSv8khVULTIYOqW6ODes00akAAhT2OXNbFcDNs9O1gD6rRNbPKvxThhnqbfnWrNkv04N57qIgOGIw2khWYM9O1gnr)kfS4y(lKcJpWigyoMnXjrtdOOb7ObpApzpELxi0XiiZnWeiggu1LfnLpoL6MOZjATrNE0am6ZnXhEODC5MOtLkA8Z8DirduqrlBLdyzZE0PD05fT2Oj6xPGfhZFHuy8bgXaZXSjojAAafnyhn4r7j7XR8cHogbzUbMaXWGQUSOP8XPu3eDorRnAXX8xkYMDybbB2hnagn(z(oKOPjAABzRGPQoS4y(leRgaBfRyflBIJjlASAKhaaCYaaslGbGsEaqAsllBUoE2HNyz5IY0ry5MOblr7vzrt0QLiKsaOLLO)QvJ8stAzz1XiMvDllTIo5ieNq2XLfnrdKiEOhasROPlIoHR4Kt(vOdrvQOmojBgKYLfnvSZiCs2SkNukefNumoaAEco1XiMvDcNCj(aPVgcNCjqcdKiEOdNCeIti74YIMczZQbG0kA2RlpJ64Obg4KIopaa4Kr0ay0adaCfWahnxceeagasROtE6(WFcxfasRObWOtoJ5MOtM3khrlOOnNXHus0Evw0eTAjsjaKwrdGrdKpdL4rloM)c8YucaPv0ay0C94uQBIgS(XCr8Ofu05IWCeDgc)OrmYNOZL(NOjifk60PE1HipAWGGIU6dqyjAWQplHE0UcnpNsayaiTIMR5(vi5MOPodc)OROmkxIM687qkrNC161fs0dAaq6ooJbsfTxLfnKOrJcmLaqVklAifD8ROmkxaXOCchbGEvw0qk64xrzuUaoioDi(SpIllAca9QSOHu0XVIYOCbCqCYGqMaqAfn746e6ijASVMOPGyyUjAI4cjAQZGWp6kkJYLOPo)oKO9XeTo(aOosKD4JEjrBqZlbGEvw0qk64xrzuUaoiojJRtOJeyI4cja0RYIgsrh)kkJYfWbXPRRRadSoAjOja0RYIgsrh)kkJYfWbXjrURe6bGEvw0qk64xrzuUaoio1rYIMaqVklAifD8ROmkxaheNzoMJBGzqyyZDHEs64xrzuUatEfngcO0K0Yac7Rb(j(if3yiLDOH2aqayaiTIMR5(vi5MOFIJbt0YM9Of6pAVkiC0ljApHVkNs9saOxLfneqjC86uQN04zh0NJ5bdm(8FGROmQDUjPeUc6G(Cmpyk4Z)bCD0sqZnWuQFdjTbItMMEEPnr)kfmDNipNaqVklAiGdIZeoEDk1tA8SdISdV6WIJ5VKucxbDqe9RuWIJ5Vqkm(aJyG5y2eNa08ca9QSOHaoio5yRCea6vzrdbCqCwDLc2RYIgy1sKKgp7GiYDLq)MKwgqe5UsOFtbJ4HEaOxLfneWbXz1vkyVklAGvlrsA8SdQAibGEvw0qaheNvxPG9QSObwTejPXZoidsca9QSOHaoioRUsb7vzrdSAjssJNDqMf)Qea6vzrdbCqC64Qphwqy8hjPLb0NJ5btXCMTUcnGaonGNWXRtPE5ZX8GbgF(pWvug1o3ea6vzrdbCqC64QphwhsrEaOxLfneWbXPA5PleyU4qg(SpsayaiTIo5riLbL7qca9QSOHuQgciDKSOjPLbefedtHsHqgferk47vjvkXX8xkYMDybbB2duqGfaivkZPGyykj(yUiEbsxBfHuguUtjHplHEb)mFhcqttaOxLfnKs1qaheNqKdVYZsA8SdI3vV6k1XeykeAsAzavriLbL7us8XCr8c(z(oeGccyTPdqXvFKcbIsoMbI)LpoL6MuPmiPW7ymsErpdsjRUApMgGZjvQkcPmOCNsIpMlIxWpZ3HqdTttaOxLfnKs1qaheNukeYaZaHbtsldiZPGyykj(yUiEbspa0RYIgsPAiGdItQJjhZXo8jTmGmNcIHPK4J5I4fi9aqVklAiLQHaoiozw8PuiKjPLbK5uqmmLeFmxeVaPha6vzrdPuneWbXPp1teSRGRUsL0YaYCkigMsIpMlIxG0daPv0Crmr7gdjAh)OH0tkAYS6pAH(Jgnp6CxHE0kuUNirRPMarLObcH8OZL(NOnGzh(OzCICC0cDFIo55YOnNzRRenchDURqhbjr7dyIo55YsaOxLfnKs1qaheNzoMJBGzqyyZDHEsldiSVg4N4JuCJHuG01MU4y(lfzZoSGGn7bAfLrHG1r7iKI5mBDL0g4sAsLQIYOqW6ODesXCMTUcnGQ6Wzo3We9pMCcaPv0CrmrpOODJHeDURsfTzF05Uc9DIwO)ONZTenydaKKIgI8ObcyaIIgnrtHiKOZDf6iijAFat0jpxwca9QSOHuQgc4G4mZXCCdmdcdBUl0tAzaH91a)eFKIBmKYo0a2aaaI91a)eFKIBmKIbc7YIgTvugfcwhTJqkMZS1vObuvhoZ5gMO)XeasRObRFmxepAeKqwZJMi3vc9OZDf6rdKq6ce(rdPxIgi0vOhnleLCmde)JwC1hjAFmrZshJGm3enleddQ6YIMO1r5EC0UkxhmKOHip6CxHE0uqmm3enxWXyK8saOxLfnKs1qaheNj(yUiEsldiasK7kH(nfmIh6AniPGH0fi8lYw5yhETPdqXvFKcbIsoMbI)LpoL6MuPaONShVYle6yeK5gyceddQ6YIMYhNsDtQugKu4DmgjVONbPKvxThtdWPsbqEmcspNaqAfnxZTG9OzHOKJzG4F0GvFwc9OROXSYIgUkAGqip6CP)jAUGJXi5rBWiD9BIgnrZUdV6rRPJ5Vea6vzrdPuneWbXzcFwc9KwgqIR(ifceLCmde)lFCk1nAbObjfEhJrYlYw5yhETjC86uQxi7WRoS4y(lbG0kAWQplHE05Uc9O5AUj8rdE0PRXYtxiIR444KIgHJMfIsoMbI)rJgfyIgnrdSM5Wvrde4CVzqzrN8Cz0(yIMR5MWhn(UbmrZGWrpNBjAUqYdefa6vzrdPuneWbXzcFwc9KwgqIR(iLZnXhEODC5LpoL6gTPlU6JuMLNUqexXXXLpoL6MuPex9rkeik5ygi(x(4uQB0MWXRtPEHSdV6WIJ5VKJ2kkJcbRJ2ri0aQQdN5Cdt0)y0wriLbL7uo3eF4H2XLxWpZ3HauG1Moafx9rkeik5ygi(x(4uQBsLcGEYE8kVqOJrqMBGjqmmOQllAkFCk1nPszqsH3XyK8IEgKswD1EmqbbCobG0kAWQplHE05Uc9O1y5PleXvCCC0GhTgOO5AUj8Cv0abo3Bguw0jpxgTpMObRFmxepAi9aqVklAiLQHaoiot4ZsON0YasC1hPmlpDHiUIJJlFCk1nAbO4Qps5Ct8HhAhxE5JtPUrBfLrHG1r7ieAav1HZCUHj6FmAnNcIHPK4J5I4fi9aqAfny1NLqp6CxHE0SquYXmq8pAWJoDnqrZ1Ct4JgHJopnbphUkAnqrtK7kHoNeik5ygi(Nu0CbhJrYJgipd(e6oL6jf9heep9Oj6E9rZGWrVtfLTdF0CbhJrYJo55YaqVklAiLQHaoiot4ZsON0YasC1hPqGOKJzG4F5JtPUrB6auC1hPCUj(WdTJlV8XPu3Kkfat441PuVq2HxDyXX8xYrlajYDLq)McgXdDTveszq5ofEhJrYlq6AniPW7ymsEbFg8j0Dk11Mor)kfS4y(lKcJpWigyoMnXjafeyRTIYOqW6ODesXCMTUcnGagCI(vkyXX8xifgFGrmWCmBItsLIOFLcwCm)fsHXhyedmhZM4eAarBTvugfcwhTJqkMZS1vObeTZjaKwrdw9zj0Jo3vOhnqGtKJJo5ieNSdxfTgOOjYDLqpAFmrpOO9QSjE0abjx0uqmmjfnqcPlq4h9GKO3jA8zWNqpASp8pa0RYIgsPAiGdIZe(Se6jTmGex9rkzorog2jeNq2P8XPu3OfGe5UsOFtXvkTzorog2jeNq2bg)mFhcqbbaAbObjfmKUaHFbFg8j0Dk1daPv0Cn3eF4H2XLhDU0)enfsOhnqcPlq4hTpMO5cogJKhTJF0q6rZGWrRqdF0Fqq80da9QSOHuQgc4G48Ct8HhAhxEsldidskyiDbc)c(z(oeAOn40oTR6Wzo3We9pgTa0GKcVJXi5f8zWNq3Pupa0RYIgsPAiGdItbX9wHPuU5jTmGmiPGH0fi8lYw5yh(aWaqAfnq0IFvI24zo)J2Pw1k7jbG0kAUEs8bLfTlrtBWJo90aE05Uc9ObIyZj6KNllrZfLLDZ6YvGjA0eDEGhT4y(lKKIo3vOhny9J5I4jfnchDURqpAnZNlw0iH(X5UKhDU(krZGWrtqzp6phZdMs0jNIGIoxFLOxMO5AUj8rxrzuOOxs0vu2o8rdPxca9QSOHuml(vb0NeFqzjTmGQOmkeSoAhHqdiAdU4QpsX8RFmmrWU48pR8XPu3OnDZPGyykj(yUiEbspvkZPGyykcI7TctPCZlq6Ps95yEWumNzRRauq5LgWt441PuV85yEWaJp)h4kkJANBsLcGjC86uQxi7WRoS4y(l5OnDakU6Juo3eF4H2XLx(4uQBsLQIqkdk3PCUj(WdTJlVGFMVdHM8Yja0RYIgsXS4xfWbXzchVoL6jnE2bbromZQuhNucxbDqvugfcwhTJqkMZS1vOb4uP(CmpykMZS1vakO8sd4jC86uQx(CmpyGXN)dCfLrTZnPsbWeoEDk1lKD4vhwCm)LaqAfnxIwcAUj6K5zzE0UeDEPf4rteVYbjAet0S0DS(NBIoFLBoPea6vzrdPyw8Rc4G4uhTe0CdmhZY8KwgqjC86uQxGihMzvQJ1sbXWui0DS(NBGPuU5Kcr8kh0akV0ka0RYIgsXS4xfWbXjJpWigyoMnXjjTmGs441PuVaromZQuhRnDkigMc91y(atPCZjfI4voObeWPvQue9RuWIJ5Vqkm(aJyG5y2eNqdO8aNi3vc9Bkyep0tLIcIHPi0pSbF3Oqydb286xPqeVYbnGYlTYja0RYIgsXS4xfWbXjLAhdznpPLbuchVoL6fiYHzwL6yTPtbXWuOu7yiR5fi9uPaO4QpsjXhugmgIqV8XPu3KtaOxLfnKIzXVkGdIZmizvU8KwgqjC86uQxGihMzvQJdadaPv0arEMZ)OrjooAzZE0o1QwzpjaKwrZQ)66QObsiDbc)OjxG0JMbHJMR5MWha6vzrdPyqcimKUaHFsldiXvFKY5M4dp0oU8YhNsDJ20tVIYOqW6ODecnGQ6Wzo3We9pgTveszq5oLZnXhEODC5f8Z8Diaf4CsLkDakBLJD41MUSzNgGbGuPQOmkeSoAhHqdO8YjNCcaPv0CbhJrYJgsNJF9KI2veu0cEpjAbfne5rVs0ojApAI(RRRIM)ZXUGWrZGWrl0F0kNirN8Cz0uNbHF0E0m7Se6hha6vzrdPyqc4G4uhHuW4tqq46tIbHHNZTac4aqVklAifdsaheN8ogJKNufmv1HfhZFHac4KwgqPdqXvFKcbIsoMbI)LpoL6MuPay6veszq5oLe(Se6fiDTveszq5oLeFmxeVGFMVdbOGODo5OTIYOqW6ODesXCMTUcnGawl(m4tO7uQRnD9miLS6Q9yGcc4uPWpZ3HauqYw5aw2SRLOFLcwCm)fsHXhyedmhZM4eAab2G7j7XR8cHogbzUbMaXWGQUSOP8XPu3KJ20b45M4dp0oUCtQu4N57qakizRCalB2t780s0VsbloM)cPW4dmIbMJztCcnGaBW9K94vEHqhJGm3atGyyqvxw0u(4uQBYrB6IJ5VuKn7Wcc2ShaXpZ3HqdT1s0VsbloM)cPW4dmIbMJztCcqbbCQuIJ5VuKn7Wcc2ShaXpZ3HqdW5LtaiTIo5XBgbnrR5Z0prIgnkWenAIodsjRU6rloM)cjAxIM2GhDYZLrNl9prJHMzh(Orqs07eDEKOthspAbfnTJwCm)fsorJWrd2KOtpnGhT4y(lKCca9QSOHumibCqCwXBgbnWYZ0prsAzar0VsbloM)cHgq5Pf)mFhcqZd80j6xPGfhZFHqdO0KJ2kkJcbRJ2ri0aI2bG0k6K5F9OH0JgiH0fi8J2LOPn4rJMODLkAXX8xirNEU0)eTAtSdF0k0Wh9heep9O9Xe9GKOjJRtOJKCca9QSOHumibCqCIH0fi8tQcMQ6WIJ5VqabCsldOkkJcbRJ2ri0aI2AXNbFcDNsDTPRNbPKvxThduqaNkf(z(oeGcs2khWYMDTe9RuWIJ5Vqkm(aJyG5y2eNqdiWgCpzpELxi0XiiZnWeiggu1LfnLpoL6MC0Moap3eF4H2XLBsLc)mFhcqbjBLdyzZEANNwI(vkyXX8xifgFGrmWCmBItObeydUNShVYle6yeK5gyceddQ6YIMYhNsDtoAfhZFPiB2HfeSzpaIFMVdHgAhagasROzL7kH(nrNCvzrdjaKwrRXYtNiUIJJtkAeoAwikbCUMBcF0OjAG1KRIMDCDcDKenqcPlq4Zfl6KtrqrdrE0ajKUaHF0Oehhnxpj(GYIEzIEfGWKOhKeTRRR2BIo9Kj6FooNaqVklAifICxj0VbegsxGWpPLbufLrHG1r7ieAarBTPlU6JuMLNUqexXXXLpoL6MuPex9rkeik5ygi(x(4uQB0kU6Juo3eF4H2XLx(4uQB0wriLbL7uo3eF4H2XLxWpZ3Hauq5PnHJxNs9czhE1HfhZFjvkakBLJD4ZrR4y(lfzZoSGGn7bq8Z8Di0awca9QSOHuiYDLq)gWbX5NeFqzjTmGQOmkeSoAhHqdOQoCMZnmr)JjaKwrZcrjhZaXFUk6KtxxbMOr4ObYZGpHE05Uc9OPGyyUjAUGJXi5KaqVklAifICxj0VbCqCY7ymsEsvWuvhwCm)fciGtAzajU6JuiquYXmq8V8XPu3OfFg8j0Dk11koM)sr2SdliyZEae)mFhcn5fasROzHOKJzG4pxfDYKehJxZJEq4mxfnxWXyKCs05Uc9OjJRtOJKOtCmzrdja0RYIgsHi3vc9BaheN8ogJKNufmv1HfhZFHac4KwgqIR(ifceLCmde)lFCk1nAXpZ3HauqadaA1ZGuYQR2JbkiG1koM)sr2SdliyZEae)mFhcn5fasROzHOKJzG4F0GhnlDmcYCt0SqmmOQllA4QOtoDDfyI(owbMObsiDbc)Of6UeDURsfn1JgFg8j0VjAgeoADFmpBRLaqVklAifICxj0VbCqCIH0fi8tAzajU6JuiquYXmq8V8XPu3O1t2Jx5fcDmcYCdmbIHbvDzrt5JtPUrlaniPGH0fi8lYw5yh(aqAfnleLCmde)JoxoJMLogbzUjAwiggu1LfnCv0a5DDDfyIMbHJMcnqKOtEUmAFmrFULpMBIMmUoHosI2aHDzrtaOxLfnKcrURe63aoio5DmgjpPkyQQdloM)cbeWjTmGex9rkeik5ygi(x(4uQB06j7XR8cHogbzUbMaXWGQUSOP8XPu3OvCm)LISzhwqWM90GFMVdjaKwrZcrjhZaX)ObpAUMBcpxfnxN4t0OehJxZJ2JMmUoHosIMl4ymsE04LNUeTZihhnqcPlq4hn1zq4hnxZnXhEODCzrtaOxLfnKcrURe63aoio1rifm(eeeU(Kyqy45ClGaoa0RYIgsHi3vc9BaheN8ogJKN0YasC1hPqGOKJzG4F5JtPUrR4Qps5Ct8HhAhxE5JtPUrBfHuguUt5Ct8HhAhxEb)mFhcqbwRo(jG5RMcWfmKUaHVwdskyiDbc)c(z(oeAsd40oTR6Wzo3We9pgRyfRf]] )

end