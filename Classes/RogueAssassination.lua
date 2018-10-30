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

                if stealthed.rogue then
                    applyDebuff( "target", "garrote_silence" ) 

                    if azerite.shrouded_suffocation.enabled then
                        gain( 2, "combo_points" )
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


    spec:RegisterPack( "Assassination", 20181029.2122, [[d0eFfbqiGOhHuYLqve1Mqv9jGqvnkjsNsIyvaH8kGQzrQYTac2Lq)cPQHbKQJbuwMe4zajnnKsDnjO2gqk(gQI04qvGZbKsRJuv6DaHkMha6EaAFifhevrTqjkpucstKuvLlkbXgbcv6JOkOtcekReGEjQIWnjvv1orv6NKQkmuufAPajEkknvsfxLuvrBLuvPVceQYEP0FbzWsDyQwmsESKMmfxw1MrXNjLrJkoTsRgvrKxJuz2KCBbTBf)gYWfy5iEoutN46GA7OsFxIQXtQ05bG1tQkMVeA)I2cMvhlRXLB5TaqhmEayGEbG2ybGvqbGoOXYkai4w2aVsNRDl74H3YYZySJX74YIglBGdafYnwDSSyemPEllhrcW6l90RTchyQyffspEdHvUSOPsCgHE8gwPNsHOONIXbbZ5sFabXSQJPNhjhu81GPNhbfiqbPbFiEgJDmEhxw0eXBy1YsbVkbeBSuwwJl3YBbGoy8aWa9caTXcadmEky8alRdlCqell7gwOwwoRX8XszznhxTS0kBEgJDmEhxw0KnOG0GFciTYMJiby9LE61wHdmvSIcPhVHWkxw0ujoJqpEdR0tPqu0tX4GG5CPpGGyw1X0ZJKdk(AW0ZJGceOG0GpepJXogVJllAI4nSMasRS1pQcI6KSla0Qx2fa6GXdYgeYgm9TWfKnpQ)tataPv2fkhF0owFtaPv2Gq28SXCt28eBLUSfu2MZ4WkjBVklAYwTyjMasRSbHSbLhI4(SfNODbAzIjG0kBqiBE2yUjB9t8ZgetEioAzvlwWwDSSy5Us4CJvhlVGz1XY(XPu3ylZYwjRCY6w2kkKcbfG2rWztdWSPD28ZU0Sfx9rIZQXrWIRO7K4hNsDt2flMT4QpsedtjNWaR94hNsDt28ZwC1hjEDX(ObVJlp(XPu3Kn)SRiKYGkFIxxSpAW74YJKh67GZgGaZUGS5NnxNSoL6r8oAQdjor7s2flMniZw2kD7OLDjzZpBXjAxIYgEibbz2NniKn5H(o4SPjBqJL1RYIgllboqGj3kwElWQJL9JtPUXwMLTsw5K1TSvuifckaTJGZMgGzxdGcDDHWbFmwwVklASSF4(bfAflVGQvhl7hNsDJTmlRxLfnwwnNqqYTSvYkNSULvC1hjIHPKtyG1E8JtPUjB(ztod5yooL6zZpBXjAxIYgEibbz2NniKn5H(o4SPj7cSSvauvhsCI2fSLxWSILxAB1XY(XPu3ylZY6vzrJLvZjeKClBLSYjRBzfx9rIyyk5egyTh)4uQBYMF2Kh67GZgGaZgmqpB(zhecRKnqTNKnabMnyzZpBXjAxIYgEibbz2NniKn5H(o4SPj7cSSvauvhsCI2fSLxWSIL3cB1XY(XPu3ylZYwjRCY6wwXvFKigMsoHbw7XpoL6MS5NTRpNSYJyoeeS5gimmddQ6YIM4hNsDt28ZgKzBqsKahiWKhLTs3oAwwVklASSe4abMCRy5f0y1XY(XPu3ylZY6vzrJLvZjeKClBLSYjRBzfx9rIyyk5egyTh)4uQBYMF2U(CYkpI5qqWMBGWWmmOQllAIFCk1nzZpBXjAxIYgEibbz2NnnztEOVd2YwbqvDiXjAxWwEbZkwE5PwDSSFCk1n2YSSmic0CDflVGzz9QSOXYgGqkiYXiys9wXYlpWQJL9JtPUXwMLTsw5K1TSIR(irmmLCcdS2JFCk1nzZpBXvFK41f7Jg8oU84hNsDt28ZUIqkdQ8jEDX(ObVJlpsEOVdoBaMnyzZp7aY5cPvnrWIe4abM8S5NTbjrcCGatEK8qFhC20KDHZg8SPD2GOSRbqHUUq4GpglRxLfnwwnNqqYTIvSSMZ4WkXQJLxWS6yz9QSOXYs3wPZY(XPu3ylZkwElWQJL1RYIgllwUReow2poL6gBzwXYlOA1XY(XPu3ylZYY1vW3Y(5enaejx7t2GNDaAXO5gik1VbNnikBEA28KZU0SliBqu24GRuqCCS8SlXY6vzrJLLRtwNsDllxNanE4TSFordaqKR9bQIcP25gRy5L2wDSSFCk1n2YSSCDf8TS4GRuqIt0UGJm(aHyGOBwUhNnaZUalRxLfnwwUozDk1TSCDc04H3YI3rtDiXjAxSIL3cB1XY(XPu3ylZYwjRCY6wwSCxjCUjsqAW3Y6vzrJLT6kfKxLfnqQflww1IfOXdVLfl3vcNBSILxqJvhl7hNsDJTmlRxLfnw2QRuqEvw0aPwSyzvlwGgp8w2QbBflV8uRow2poL6gBzwwVklASSvxPG8QSObsTyXYQwSanE4TSgKyflV8aRow2poL6gBzwwVklASSvxPG8QSObsTyXYQwSanE4TSML8QyflVGwRow2poL6gBzw2kzLtw3Y(5enaenNzRRKnnaZgScNn4zZ1jRtPE8ZjAaaICTpqvui1o3yz9QSOXY6KQphsqeYhXkwEbd0T6yz9QSOXY6KQphkawHVL9JtPUXwMvS8cgywDSSEvw0yzvRghbdXtc2Of(rSSFCk1n2YSIvSSbKxrHuUy1XYlywDSSFCk1n2YSIL3cS6yz)4uQBSLzflVGQvhl7hNsDJTmRy5L2wDSSFCk1n2YSIL3cB1XY6vzrJL1dcuaakaTy0yz)4uQBSLzflVGgRowwVklASSy5Us4yz)4uQBSLzflV8uRowwVklASSbizrJL9JtPUXwMvS8YdS6yz)4uQBSLzz9QSOXYg6e6UbIbrGm3fow2kzLtw3Ys81aDUFKOBm44oztt20g0TSbKxrHuUaHFfngSLTWwXkwwZsEvS6y5fmRow2poL6gBzw2kzLtw3YwrHuiOa0ocoBAaMnTZg8Sfx9rIM)GtGWcXfx7HXpoL6MS5NDPzBofmdtK7hZfXJWbzxSy2MtbZWefKUBfIs5MhHdYUyXS)CIgaIMZS1vYgGaZUGcNn4zZ1jRtPE8ZjAaaICTpqvui1o3KDXIzdYS56K1PupI3rtDiXjAxYUKS5NDPzdYSfx9rIxxSpAW74YJFCk1nzxSy2veszqLpXRl2hn4DC5rYd9DWztt2fKDjwwVklASSF4(bfAflVfy1XY(XPu3ylZYY1vW3YwrHuiOa0ocoAoZwxjBAYgSSlwm7pNObGO5mBDLSbiWSlOWzdE2CDY6uQh)CIgaGix7duffsTZnzxSy2GmBUozDk1J4D0uhsCI2flRxLfnwwUozDk1TSCDc04H3YcJpeZQuNyflVGQvhl7hNsDJTmlBLSYjRBz56K1PupcJpeZQuNKn)SPGzyIyooj4Znquk3CCelELUSPby2faATSEvw0yzdqlgn3ar3Sm3kwEPTvhl7hNsDJTmlBLSYjRBz56K1PupcJpeZQuNKn)SlnBkygMiN1y(arPCZXrS4v6YMgGzdgOn7IfZghCLcsCI2fCKXhiedeDZY94SPby20oBWZU0SD95KvE0GGPuhYGWps8HUSPj7cYUKSbpBSCxjCUjsqAWp7sSSEvw0yzz8bcXar3SCp2kwElSvhl7hNsDJTmlBLSYjRBz56K1PupcJpeZQuNKn)SXbxPGeNODbhz8bcXar3SCpoBAaMnOMn)S9QSCpKbjrZDJcaqbOfJMObjzdWS9QSCp0NhUhBz9QSOXYY4deIbIUz5ESvS8cAS6yz)4uQBSLzzRKvozDllxNSoL6ry8HywL6KS5NDPztbZWePu7yWR5r4GSlwmBqMT4QpsK7huiebgZj(XPu3KDjwwVklASSuQDm41CRy5LNA1XY(XPu3ylZYwjRCY6wwUozDk1JW4dXSk1jzZpBCWvkiXjAxWrgFGqmq0nl3JZgy2fKn)S9QSCpKbjrZDJcaqbOfJgidsYgGz7vz5EOppCp2Y6vzrJLnewwLl3kwE5bwDSSFCk1n2YSSvYkNSULLRtwNs9im(qmRsDIL1RYIglBiSSkxUvSILTAWwDS8cMvhl7hNsDJTmlBLSYjRBzPGzyIukeYOGXsKCVkzxSy2It0UeLn8qccYSpBacmBqdONDXIzBofmdtK7hZfXJWbzZp7kcPmOYNixFwmNi5H(o4Sby2f2Y6vzrJLnajlASIL3cS6yz)4uQBSLzz9QSOXYQ5QxDL6emefcnw2kzLtw3YwriLbv(e5(XCr8i5H(o4SbiWSblB(zxA2GmBXvFKigMsoHbw7XpoL6MSlwmBdsIAoHGKhdcHvYgO2tYMMSbl7sYUyXSRiKYGkFIC)yUiEK8qFhC20KnTlSLD8WBz1C1RUsDcgIcHgRy5fuT6yz)4uQBSLzzRKvozDlBfHugu5tK7hZfXJKh67GZgGaZgSS5NDPzdYSfx9rIyyk5egyTh)4uQBYUyXSnijQ5ecsEmiewjBGApjBAYgSSlj7IfZUIqkdQ8jY9J5I4rYd9DWztt20UWwwVklASSW4dTYdXwXYlTT6yz)4uQBSLzzRKvozDlR5uWmmrUFmxepchyz9QSOXYsPqidedmbawXYBHT6yz)4uQBSLzzRKvozDlR5uWmmrUFmxepchyz9QSOXYsDc(e62rZkwEbnwDSSFCk1n2YSSvYkNSUL1CkygMi3pMlIhHdSSEvw0yzzwYPuiKXkwE5PwDSSFCk1n2YSSvYkNSUL1CkygMi3pMlIhHdSSEvw0yz9PESqCfu1vkRy5Lhy1XY(XPu3ylZYwjRCY6wwIVgOZ9JeDJbhHdYMF2LMT4eTlrzdpKGGm7ZgGzxrHuiOa0ocoAoZwxjBqu2GflC2flMDffsHGcq7i4O5mBDLSPby21aOqxxiCWht2Lyz9QSOXYg6e6UbIbrGm3fowXYlO1QJL9JtPUXwMLTsw5K1TSeFnqN7hj6gdoUt20KnOc6zdczt81aDUFKOBm4ObM4YIMS5NDffsHGcq7i4O5mBDLSPby21aOqxxiCWhJL1RYIglBOtO7gigebYCx4yflVGb6wDSSFCk1n2YSSvYkNSULfKzJL7kHZnrcsd(zZpBdsIe4abM8OSv62rlB(zxA2GmBXvFKigMsoHbw7XpoL6MSlwmBqMTRpNSYJyoeeS5gimmddQ6YIM4hNsDt2flMTbjrnNqqYJbHWkzdu7jztt2GLDjwwVklASSC)yUiUvS8cgywDSSFCk1n2YSSvYkNSULvC1hjIHPKtyG1E8JtPUjB(zdYSnijQ5ecsEu2kD7OLn)S56K1PupI3rtDiXjAxSSEvw0yz56ZI5yflVGvGvhl7hNsDJTmlBLSYjRBzfx9rIxxSpAW74YJFCk1nzZp7sZwC1hjoRghblUIUtIFCk1nzxSy2IR(irmmLCcdS2JFCk1nzZpBUozDk1J4D0uhsCI2LSljB(zxrHuiOa0ocoBAaMDnak01fch8XKn)SRiKYGkFIxxSpAW74YJKh67GZgGzdw28ZU0Sbz2IR(irmmLCcdS2JFCk1nzxSy2GmBxFozLhXCiiyZnqyyggu1LfnXpoL6MSlwmBdsIAoHGKhdcHvYgO2tYgGaZgSSlXY6vzrJLLRplMJvS8cgOA1XY(XPu3ylZYwjRCY6wwXvFK4SACeS4k6oj(XPu3Kn)Sbz2IR(iXRl2hn4DC5XpoL6MS5NDffsHGcq7i4SPby21aOqxxiCWht28Z2CkygMi3pMlIhHdSSEvw0yz56ZI5yflVGrBRow2poL6gBzw2kzLtw3YkU6JeXWuYjmWAp(XPu3Kn)SlnBqMT4Qps86I9rdEhxE8JtPUj7IfZgKzZ1jRtPEeVJM6qIt0UKDjzZpBqMnwUReo3ejin4Nn)SRiKYGkFIAoHGKhHdYMF2gKe1Ccbjpsod5yooL6zZp7sZghCLcsCI2fCKXhiedeDZY94SbiWSb1S5NDffsHGcq7i4O5mBDLSPby2GLn4zJdUsbjor7coY4deIbIUz5EC2flMno4kfK4eTl4iJpqigi6ML7XztdWSPD28ZUIcPqqbODeC0CMTUs20amBANDjwwVklASSC9zXCSILxWkSvhl7hNsDJTmlBLSYjRBzfx9rIHowobYXyhJ3j(XPu3Kn)Sbz2y5Us4Ct0vQS5NDOJLtGCm2X4DGip03bNnabMnONn)Sbz2gKejWbcm5rYzihZXPu3Y6vzrJLLRplMJvS8cgOXQJL9JtPUXwMLTsw5K1TSgKejWbcm5rYd9DWztt20oBWZM2zdIYUgaf66cHd(yYMF2GmBdsIAoHGKhjNHCmhNsDlRxLfnw2Rl2hn4DC5wXYly8uRow2poL6gBzw2kzLtw3YAqsKahiWKhLTs3oAwwVklASScs3TcrPCZTIvSSgKy1XYlywDSSFCk1n2YSSvYkNSULvC1hjEDX(ObVJlp(XPu3Kn)Sln7sZUIcPqqbODeC20am7AauORleo4JjB(zxriLbv(eVUyF0G3XLhjp03bNnaZgSSlj7IfZU0Sbz2YwPBhTS5NDPzlB4ZMMSbd0ZUyXSROqkeuaAhbNnnaZUGSlj7sYUelRxLfnwwcCGatUvS8wGvhl7hNsDJTmlldIanxxXYlywwVklASSbiKcICmcMuVvS8cQwDSSFCk1n2YSSEvw0yz1Ccbj3YwjRCY6w2sZgKzlU6JeXWuYjmWAp(XPu3KDXIzdYSln7kcPmOYNixFwmNiCq28ZUIqkdQ8jY9J5I4rYd9DWzdqGzt7Slj7sYMF2vuifckaTJGJMZS1vYMgGzdw28ZMCgYXCCk1ZMF2LMDqiSs2a1Es2aey2GLDXIztEOVdoBacmBzR0bjB4ZMF24GRuqIt0UGJm(aHyGOBwUhNnnaZguZg8SD95KvEeZHGGn3aHHzyqvxw0e)4uQBYUKS5NDPzdYSVUyF0G3XLBYUyXSjp03bNnabMTSv6GKn8zdIYUGS5Nno4kfK4eTl4iJpqigi6ML7XztdWSb1SbpBxFozLhXCiiyZnqyyggu1LfnXpoL6MSljB(zxA2It0UeLn8qccYSpBqiBYd9DWztt20oB(zJdUsbjor7coY4deIbIUz5EC2aey2GLDXIzlor7su2WdjiiZ(SbHSjp03bNnnzdwbzxILTcGQ6qIt0UGT8cMvS8sBRow2poL6gBzw2kzLtw3YIdUsbjor7coBAaMDbzZpBYd9DWzdWSliBWZU0SXbxPGeNODbNnnaZUWzxs28ZUIcPqqbODeC20amBABz9QSOXYwjBignqYddowSIL3cB1XY(XPu3ylZY6vzrJLLahiWKBzRKvozDlBffsHGcq7i4SPby20oB(ztod5yooL6zZp7sZoiewjBGApjBacmBWYUyXSjp03bNnabMTSv6GKn8zZpBCWvkiXjAxWrgFGqmq0nl3JZMgGzdQzdE2U(CYkpI5qqWMBGWWmmOQllAIFCk1nzxs28ZU0Sbz2xxSpAW74YnzxSy2Kh67GZgGaZw2kDqYg(Sbrzxq28ZghCLcsCI2fCKXhiedeDZY94SPby2GA2GNTRpNSYJyoeeS5gimmddQ6YIM4hNsDt2LKn)SfNODjkB4HeeKzF2Gq2Kh67GZMMSPTLTcGQ6qIt0UGT8cMvSIvSSCpbVOXYBbGoy8aWa9ckiwayGbQw2YDYSJg2YcIfgGiYnzdAY2RYIMSvlwWXeqlBabXSQBzPv28mg7y8oUSOjBqbPb)eqALnhrcW6l90RTchyQyffspEdHvUSOPsCgHE8gwPNsHOONIXbbZ5sFabXSQJPNhjhu81GPNhbfiqbPbFiEgJDmEhxw0eXBynbKwzRFufe1jzxaOvVSla0bJhKniKny6BHliBEu)NaMasRSluo(ODS(MasRSbHS5zJ5MS5j2kDzlOSnNXHvs2Evw0KTAXsmbKwzdczdkpeX9zlor7c0YetaPv2Gq28SXCt26N4NniM8qCmbmbKwzxi6(kSCt2uNbrE2vuiLlztDTDWXS55A9bco7bnGahNeYaRY2RYIgC2OrbGycOxLfn4ya5vuiLlazuoMUeqVklAWXaYROqkxahi9oSw4hXLfnjGEvw0GJbKxrHuUaoq6zqitciTYMD8amhKKnXxt2uWmm3KnwCbNn1zqKNDffs5s2uxBhC2(yYoGCqiajYoAzV4SnO5XeqVklAWXaYROqkxahi94XdWCqcewCbNa6vzrdogqEffs5c4aP3dcuaakaTy0Ka6vzrdogqEffs5c4aPhl3vcNeqVklAWXaYROqkxahi9bizrtcOxLfn4ya5vuiLlGdK(qNq3nqmicK5UWrVaYROqkxGWVIgdgyH1Bzas81aDUFKOBm44o0qBqpbmbKwzxi6(kSCt2N7jaiBzdF2cNNTxfej7fNTZ1xLtPEmbKwzdkhl3vcNSxMSdqy8sPE2LoOS5cRMtCk1Z(Zd3JZENSROqkxkjb0RYIgmq62kDjGEvw0Gbhi9y5Us4Ka6vzrdgCG0Z1jRtPUEJhEGFordaqKR9bQIcP25g946k4d8ZjAaisU2hWdqlgn3arP(nyqepLNCPfaIWbxPG44y5LKa6vzrdgCG0Z1jRtPUEJhEG4D0uhsCI2f946k4dehCLcsCI2fCKXhiedeDZY9yawqcOxLfnyWbsF1vkiVklAGulw0B8Wdel3vcNB0BzaIL7kHZnrcsd(jGEvw0Gbhi9vxPG8QSObsTyrVXdpWQbNa6vzrdgCG0xDLcYRYIgi1If9gp8anijb0RYIgm4aPV6kfKxLfnqQfl6nE4bAwYRscOxLfnyWbsVtQ(CibriFe9wgGFordarZz26k0aeScdoxNSoL6XpNObaiY1(avrHu7CtcOxLfnyWbsVtQ(COayf(jGEvw0Gbhi9QvJJGH4jbB0c)ijGjG0k7cfHugu5dob0RYIgCSAWadqYIg9wgGuWmmrkfczuWyjsUxLIffNODjkB4HeeKzpabcAa9IfnNcMHjY9J5I4r4a(veszqLprU(SyorYd9DWaSWjGEvw0GJvdgCG0dJp0kpuVXdpqnx9QRuNGHOqOrVLbyfHugu5tK7hZfXJKh67GbiqW4xkifx9rIyyk5egyTh)4uQBkw0GKOMtii5XGqyLSbQ9eAaRKIfRiKYGkFIC)yUiEK8qFhmn0UWjGEvw0GJvdgCG0dJp0kpeR3YaSIqkdQ8jY9J5I4rYd9DWaeiy8lfKIR(irmmLCcdS2JFCk1nflAqsuZjeK8yqiSs2a1EcnGvsXIveszqLprUFmxepsEOVdMgAx4eqVklAWXQbdoq6PuiKbIbMaa9wgGMtbZWe5(XCr8iCqcOxLfn4y1Gbhi9uNGpHUD00BzaAofmdtK7hZfXJWbjGEvw0GJvdgCG0ZSKtPqiJEldqZPGzyIC)yUiEeoib0RYIgCSAWGdKEFQhlexbvDLsVLbO5uWmmrUFmxepchKasRSbXyY2ngC2o5zdhOx24zdE2cNNnAE2LVcNSvOYpwYwhD0FXS1pXp7Y58jBda2rlBghlNKTWXNSluEmBZz26kzJizx(kCqWs2(aGSluEmMa6vzrdownyWbsFOtO7gigebYCx4O3YaK4Rb6C)ir3yWr4a(Lkor7su2WdjiiZEawrHuiOa0ocoAoZwxbebwSWflwrHuiOa0ocoAoZwxHgG1aOqxxiCWhtjjG0kBqmMShu2UXGZU8vPY2Sp7YxHZozlCE2Z1vYgubDSEzdJF26Fg9x2OjBkegND5RWbblz7daYUq5XycOxLfn4y1Gbhi9HoHUBGyqeiZDHJEldqIVgOZ9JeDJbh3Hgqf0bbIVgOZ9JeDJbhnWexw0WVIcPqqbODeC0CMTUcnaRbqHUUq4GpMeqALT(9J5I4zJGf8AE2y5Us4KD5RWjBqboqGjpB4Gy2G4TcNSzHPKtyG1E2IR(iz7JjBwoeeS5MSzHzyqvxw0KDaQ8tY2vL7aaNnm(zx(kCYMcMH5MS5HoHGKhta9QSObhRgm4aPN7hZfX1BzacsSCxjCUjsqAWNVbjrcCGatEu2kD7OXVuqkU6JeXWuYjmWAp(XPu3uSiiD95KvEeZHGGn3aHHzyqvxw0e)4uQBkw0GKOMtii5XGqyLSbQ9eAaRKeqALDHORq8SzHPKtyG1E26xFwmNSROXSYIg9nB9t8ZUCoFYMh6ecsE2gcki4MSrt2S7OPE264eTljGEvw0GJvdgCG0Z1NfZrVLbO4QpsedtjNWaR94hNsDdFqAqsuZjeK8OSv62rJpxNSoL6r8oAQdjor7sciTYw)6ZI5KD5RWj7crxSw2GNDP8UACeS4k6orVSrKSzHPKtyG1E2OrbGSrt2GPtj6B26Fx3neom7cLhZ2ht2fIUyTSj3naiBgej756kzZdlu9xcOxLfn4y1Gbhi9C9zXC0BzakU6JeVUyF0G3XLh)4uQB4xQ4QpsCwnocwCfDNe)4uQBkwuC1hjIHPKtyG1E8JtPUHpxNSoL6r8oAQdjor7sj8ROqkeuaAhbtdWAauORleo4JHFfHugu5t86I9rdEhxEK8qFhmabJFPGuC1hjIHPKtyG1E8JtPUPyrq66ZjR8iMdbbBUbcdZWGQUSOj(XPu3uSObjrnNqqYJbHWkzdu7jaeiyLKasRS1V(Syozx(kCYM3vJJGfxr3jzdE28IYUq0fRPVzR)DD3q4WSluEmBFmzRF)yUiE2WbjGEvw0GJvdgCG0Z1NfZrVLbO4QpsCwnocwCfDNe)4uQB4dsXvFK41f7Jg8oU84hNsDd)kkKcbfG2rW0aSgaf66cHd(y4BofmdtK7hZfXJWbjG0kB9RplMt2LVcNSzHPKtyG1E2GNDP8IYUq0fRLnIKDb6aEj6B28IYgl3vch6XWuYjmWAxVS5HoHGKNnOCgYXCCk11l7piynozJd86ZMbrYENkkChTS5HoHGKNDHYJjGEvw0GJvdgCG0Z1NfZrVLbO4QpsedtjNWaR94hNsDd)sbP4Qps86I9rdEhxE8JtPUPyrqY1jRtPEeVJM6qIt0UucFqIL7kHZnrcsd(8RiKYGkFIAoHGKhHd4BqsuZjeK8i5mKJ54uQZVuCWvkiXjAxWrgFGqmq0nl3JbiqqLFffsHGcq7i4O5mBDfAacg44GRuqIt0UGJm(aHyGOBwUhxSio4kfK4eTl4iJpqigi6ML7X0aK28ROqkeuaAhbhnNzRRqdqAxsciTYw)6ZI5KD5RWjB9VJLtYMNXyhVJ(MnVOSXYDLWjBFmzpOS9QSCF26FEoBkygg9YguGdeyYZEqs27Kn5mKJ5KnXhTNa6vzrdownyWbspxFwmh9wgGIR(iXqhlNa5ySJX7e)4uQB4dsSCxjCUj6kf)qhlNa5ySJX7arEOVdgGabD(G0GKiboqGjpsod5yooL6jG0k7crxSpAW74YZUCoFYMcjCYguGdeyYZ2ht28qNqqYZ2jpB4GSzqKSvOrl7piynojGEvw0GJvdgCG0FDX(ObVJlxVLbObjrcCGatEK8qFhmn0gCAdIQbqHUUq4Gpg(G0GKOMtii5rYzihZXPupb0RYIgCSAWGdKEbP7wHOuU56TmanijsGdeyYJYwPBhTeWeqALT(BjVkzB8qx7z7uRAL94eqALDHmC)GcZ2LSPn4zxAHbp7YxHt26p2sYUq5Xy2GyHH3SUCfaYgnzxa4zlor7cwVSlFfozRF)yUiUEzJizx(kCYwNYaXjBKW5KYx8ZUCFLSzqKSXOWN9Nt0aqmBEwHrzxUVs2lt2fIUyTSROqku2lo7kkChTSHdIjGEvw0GJML8Qa8d3pOq9wgGvuifckaTJGPbiTbxC1hjA(dobclexCThg)4uQB4xQ5uWmmrUFmxepchuSO5uWmmrbP7wHOuU5r4GIf)CIgaIMZS1vaiWckm4CDY6uQh)CIgaGix7duffsTZnflcsUozDk1J4D0uhsCI2Ls4xkifx9rIxxSpAW74YJFCk1nflwriLbv(eVUyF0G3XLhjp03bttbLKa6vzrdoAwYRc4aPNRtwNsD9gp8aHXhIzvQt0JRRGpWkkKcbfG2rWrZz26k0awXIFordarZz26kaeybfgCUozDk1JFordaqKR9bQIcP25MIfbjxNSoL6r8oAQdjor7sciTYMhrlgn3KnpXSmpBxYUaql4zJfVshoBet2SCCsWNBYUmLBooMa6vzrdoAwYRc4aPpaTy0CdeDZYC9wgGCDY6uQhHXhIzvQt4tbZWeXCCsWNBGOuU54iw8kD0aSaqBcOxLfn4OzjVkGdKEgFGqmq0nl3J1BzaY1jRtPEegFiMvPoHFPuWmmroRX8bIs5MJJyXR0rdqWaTflIdUsbjor7coY4deIbIUz5EmnaPn4L66ZjR8ObbtPoKbHFK4dD0uqjGJL7kHZnrcsd(LKasRSbX1NSrmzZtml3JZwqz7bbkaKT(7UrbGS5r0Irt2lt274vz5(Srt2(aGSfNODjBxYguZwCI2fCcOxLfn4OzjVkGdKEgFGqmq0nl3J1BzaY1jRtPEegFiMvPoHpo4kfK4eTl4iJpqigi6ML7X0aeu57vz5EidsIM7gfaGcqlgnrdsaOxLL7H(8W94eqVklAWrZsEvahi9uQDm41C9wgGCDY6uQhHXhIzvQt4xkfmdtKsTJbVMhHdkweKIR(irUFqHqeymN4hNsDtjjG0kBDCkqq)dlRYLNTGY2dcuaiB93DJcazZJOfJMSDj7cYwCI2fCcOxLfn4OzjVkGdK(qyzvUC9wgGCDY6uQhHXhIzvQt4JdUsbjor7coY4deIbIUz5EmWc47vz5EidsIM7gfaGcqlgnqgKaqVkl3d95H7XjGEvw0GJML8Qaoq6dHLv5Y1BzaY1jRtPEegFiMvPojbmbKwzR)8qx7zJ4Es2Yg(SDQvTYECciTYMn411vzdkWbcm5zJVahKndIKDHOlwlb0RYIgC0GeGe4abMC9wgGIR(iXRl2hn4DC5XpoL6g(LwAffsHGcq7iyAawdGcDDHWbFm8RiKYGkFIxxSpAW74YJKh67GbiyLuSyPGu2kD7OXVuzdpnGb6flwrHuiOa0ocMgGfusjLKasRS5HoHGKNnCaD)b6LTRWOSfYEC2ckBy8ZELSDC2E24GxxxLT2NtCbrYMbrYw48SvowYUq5XSPodI8S9Sz2zXCojb0RYIgC0GeWbsFacPGihJGj1RhdIanxxbiyjGEvw0GJgKaoq61CcbjxVkaQQdjor7cgiy6TmalfKIR(irmmLCcdS2JFCk1nflcYsRiKYGkFIC9zXCIWb8RiKYGkFIC)yUiEK8qFhmabs7skHFffsHGcq7i4O5mBDfAacgFYzihZXPuNFPbHWkzdu7jaeiyflsEOVdgGaLTshKSHNpo4kfK4eTl4iJpqigi6ML7X0aeub31Ntw5rmhcc2CdegMHbvDzrt8JtPUPe(LcYRl2hn4DC5MIfjp03bdqGYwPds2WdIkGpo4kfK4eTl4iJpqigi6ML7X0aeub31Ntw5rmhcc2CdegMHbvDzrt8JtPUPe(Lkor7su2WdjiiZEqG8qFhmn0Mpo4kfK4eTl4iJpqigi6ML7Xaeiyflkor7su2WdjiiZEqG8qFhmnGvqjjG0k7cLSHy0KTopm4yjB0Oaq2Oj7qyLSbQNT4eTl4SDjBAdE2fkpMD5C(KnbEMD0YgblzVt2fGZUu4GSfu20oBXjAxWLKnIKnOIZU0cdE2It0UGljb0RYIgC0GeWbsFLSHy0ajpm4yrVLbio4kfK4eTlyAawaFYd9DWaSaWlfhCLcsCI2fmnalCj8ROqkeuaAhbtdqANasRS5j(dYgoiBqboqGjpBxYM2GNnAY2vQSfNODbNDPLZ5t2QL7oAzRqJw2FqWACY2ht2dsYgpEaMdskjb0RYIgC0GeWbspboqGjxVkaQQdjor7cgiy6TmaROqkeuaAhbtdqAZNCgYXCCk15xAqiSs2a1EcabcwXIKh67GbiqzR0bjB45JdUsbjor7coY4deIbIUz5EmnabvWD95KvEeZHGGn3aHHzyqvxw0e)4uQBkHFPG86I9rdEhxUPyrYd9DWaeOSv6GKn8GOc4JdUsbjor7coY4deIbIUz5EmnabvWD95KvEeZHGGn3aHHzyqvxw0e)4uQBkHV4eTlrzdpKGGm7bbYd9DW0q7eWeqALnRCxjCUjBEUklAWjG0kBExnoyXv0DIEzJizZctjGxi6I1YgnzdMo6B2SJhG5GKSbf4abMCqCYMNvyu2W4NnOahiWKNnI7jzxid3pOWSxMSxbeFC2dsY2dcu7nzxQ(rWNtkjb0RYIgCel3vcNBasGdeyY1BzawrHuiOa0ocMgG0MFPIR(iXz14iyXv0Ds8JtPUPyrXvFKigMsoHbw7XpoL6g(IR(iXRl2hn4DC5XpoL6g(veszqLpXRl2hn4DC5rYd9DWaeyb856K1PupI3rtDiXjAxkweKYwPBhTs4lor7su2WdjiiZEqG8qFhmnGMeqVklAWrSCxjCUbCG0)H7huOEldWkkKcbfG2rW0aSgaf66cHd(ysaPv2SWuYjmWAxFZMNdcuaiBejBq5mKJ5KD5RWjBkygMBYMh6ecsoob0RYIgCel3vcNBahi9AoHGKRxfav1HeNODbdem9wgGIR(irmmLCcdS2JFCk1n8jNHCmhNsD(It0UeLn8qccYSheip03bttbjG0kBwyk5egyTRVzRFW9eYAE2dIe6QS5HoHGKJZU8v4KnE8amhKKn3tWlAWjGEvw0GJy5Us4Cd4aPxZjeKC9QaOQoK4eTlyGGP3YauC1hjIHPKtyG1E8JtPUHp5H(oyacemqNFqiSs2a1EcabcgFXjAxIYgEibbz2dcKh67GPPGeqALnlmLCcdS2Zg8Sz5qqWMBYMfMHbvDzrJ(MnpheOaq23jkaKnOahiWKNTWXLSlFvQSPE2KZqoMZnzZGizh4J5HBnMa6vzrdoIL7kHZnGdKEcCGatUEldqXvFKigMsoHbw7XpoL6g(U(CYkpI5qqWMBGWWmmOQllAIFCk1n8bPbjrcCGatEu2kD7OLasRSzHPKtyG1E2LtF2SCiiyZnzZcZWGQUSOrFZguUheOaq2mis2uObgNDHYJz7Jj7RR8XCt24XdWCqs2gyIllAsa9QSObhXYDLW5gWbsVMtii56vbqvDiXjAxWabtVLbO4QpsedtjNWaR94hNsDdFxFozLhXCiiyZnqyyggu1LfnXpoL6g(It0UeLn8qccYSNgYd9DWjG0kBwyk5egyTNn4zxi6I103SleUFYgX9eYAE2E24XdWCqs28qNqqYZMSACKSDg5KSbf4abM8SPodI8SleDX(ObVJllAsa9QSObhXYDLW5gWbsFacPGihJGj1RhdIanxxbiyjGEvw0GJy5Us4Cd4aPxZjeKC9wgGIR(irmmLCcdS2JFCk1n8fx9rIxxSpAW74YJFCk1n8RiKYGkFIxxSpAW74YJKh67Gbiy8diNlKw1eblsGdeyY5BqsKahiWKhjp03bttHbN2GOAauORleo4JXYIdE1YBbfg0AfRyTa]] )

end