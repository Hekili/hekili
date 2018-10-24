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


    spec:RegisterPack( "Assassination", 20181022.2113, [[d00sfbqiaLhHuQlHQiQnHQ6taQs1OKioLePvbqYRakZIuLBbqSlH(fQOHbq5yifltc1ZaOAAiLCnjK2gQc8nufPXbOQohaPwhPQ4DaQsmpa09aY(aQoiPQ0cLO8qjenrsvvUOecBeqvsFevbDsavXkbKxIQiCtsvvTtsf)KuvHHIQqlfqLNIstfvPRsQQOTsQQ0xbuLYEP0FbzWsDyQwmsESKMmfxw1MrXNjLrJuDALwnQIiVgvy2KCBbTBf)gYWfy5iEoutN46GA7OsFxIQXtQ05bG1JQOMVeSFrBPXYRL14YT6umGrdWNgaR4IJftdnaoGvulRaGGBzd8khU2TSJhElR(IXogVJllASSboaui3y51YIrWK6TS0fjaRpCYP2k0HPIvuiN4new5YIMkXzeoXByLtkfIItkghqmNlNbeeZQoMtEKCGZxdMtEe4GaoKg8H0xm2X4DCzrteVHvllf8QeGNXszznUCRofdy0a8PbWkU4yX0qtXfLNAzDyHoIyzz3WI0YsFnMpwklR54QLL2zRVySJX74YIMSboKg8tGOD20fjaRpCYP2k0HPIvuiN4new5YIMkXzeoXByLtkfIItkghqmNlNbeeZQoMtEKCGZxdMtEe4GaoKg8H0xm2X4DCzrteVH1eiANT(rvquNKDXfRx2fdy0a8ZgqYgqRpagGoBEu)NaLar7Sls6(ODS(Kar7SbKS1xJ5MS5j2khzlOSnNXHvs2Evw0KTAXsmbI2zdizdCpeX9zlor7c0YetGOD2as26RXCt26N4NnWJ8qC0YQwSGT8AzXYDLq)glVwDOXYRL9JtPUXwMLTsw5K1TSvuifckaTJGZgCqztRS5NDjzlU6JeNvJUGfxXXjXpoL6MSluiBXvFKigMsoHbw7XpoL6MS5NT4Qps86I9rdEhxE8JtPUjB(zxriLbv(eVUyF0G3XLhjp03bNnabLDXzZpBUozDk1J4D0uhsCI2LSluiBGLTSvo2rl7sZMF2It0UeLn8qccYSpBajBYd9DWzdE28alRxLfnwwcCGatUvS6uSLxl7hNsDJTmlBLSYjRBzROqkeuaAhbNn4GYUgaf66cHd(ySSEvw0yz)W9dk0kwDaClVw2poL6gBzwwVklASSAoHGKBzRKvozDlR4QpsedtjNWaR94hNsDt28ZMCgYX0Dk1ZMF2It0UeLn8qccYSpBajBYd9DWzdE2fBzRaOQoK4eTlyRo0yfRo0YYRL9JtPUXwML1RYIglRMtii5w2kzLtw3YkU6JeXWuYjmWAp(XPu3Kn)Sjp03bNnabLnnaw28ZoiewjBGApjBackBAYMF2It0UeLn8qccYSpBajBYd9DWzdE2fBzRaOQoK4eTlyRo0yfRof1YRL9JtPUXwMLTsw5K1TSIR(irmmLCcdS2JFCk1nzZpBNNpzLhX0jiyZnqyyggu1LfnXpoL6MS5NnWY2GKiboqGjpkBLJD0SSEvw0yzjWbcm5wXQdpWYRL9JtPUXwML1RYIglRMtii5w2kzLtw3YkU6JeXWuYjmWAp(XPu3Kn)SDE(KvEetNGGn3aHHzyqvxw0e)4uQBYMF2It0UeLn8qccYSpBWZM8qFhSLTcGQ6qIt0UGT6qJvS6WtT8Az)4uQBSLzzzqeO56kwDOXY6vzrJLnaHuqKJrWK6TIvhGVLxl7hNsDJTmlBLSYjRBzfx9rIyyk5egyTh)4uQBYMF2IR(iXRl2hn4DC5XpoL6MS5NDfHugu5t86I9rdEhxEK8qFhC2amBAYMF2bKZfsRAI0ejWbcm5zZpBdsIe4abM8i5H(o4Sbp7IMnyztRSbuzxdGcDDHWbFmwwVklASSAoHGKBfRyznNXHvILxRo0y51Y6vzrJLfl3vcDl7hNsDJTmRy1PylVw2poL6gBzwwUUc(w2pNObGi5AFYgSSdqlgn3arP(n4SbuzZtZMNC2LKDXzdOYghCLcIUJLNDPwwVklASSCDY6uQBz56eOXdVL9ZjAaaICTpqvui1o3yfRoaULxl7hNsDJTmllxxbFllo4kfK4eTl4iJpqigioML7XzdWSl2Y6vzrJLLRtwNsDllxNanE4TS4D0uhsCI2fRy1HwwETSFCk1n2YSSvYkNSULfl3vc9BIeKg8TSEvw0yzRUsb5vzrdKAXILvTybA8WBzXYDLq)gRy1POwETSFCk1n2YSSEvw0yzRUsb5vzrdKAXILvTybA8WBzRgSvS6WdS8Az)4uQBSLzz9QSOXYwDLcYRYIgi1IflRAXc04H3YAqIvS6WtT8Az)4uQBSLzz9QSOXYwDLcYRYIgi1IflRAXc04H3YAwYRIvS6a8T8Az)4uQBSLzzRKvozDl7Nt0aq0CMTUs2GdkBAkA2GLnxNSoL6XpNObaiY1(avrHu7CJL1RYIglRtQ(CibriFeRy1bqB51Y6vzrJL1jvFouaScFl7hNsDJTmRy1HgaZYRL1RYIglRA1OlyiEsWgTWpIL9JtPUXwMvSILnG8kkKYflVwDOXYRL9JtPUXwMvS6uSLxl7hNsDJTmRy1bWT8Az)4uQBSLzfRo0YYRL9JtPUXwMvS6uulVwwVklASSEqGcaqbOfJgl7hNsDJTmRy1Hhy51Y6vzrJLfl3vcDl7hNsDJTmRy1HNA51Y6vzrJLnajlASSFCk1n2YSIvhGVLxl7hNsDJTmlRxLfnw2qNWXnqmicK5Uq3YwjRCY6wwIVgOZ9JeDJbh3jBWZMwaMLnG8kkKYfi8ROXGTSf1kwXYAwYRILxRo0y51Y(XPu3ylZYwjRCY6w2kkKcbfG2rWzdoOSPv2GLT4Qps08hCcewiU4Apm(XPu3Kn)SljBZPGzyIC)yUiEeoi7cfY2CkygMOG0DRquk38iCq2fkK9Nt0aq0CMTUs2aeu2fx0SblBUozDk1JFordaqKR9bQIcP25MSluiBGLnxNSoL6r8oAQdjor7s2LMn)SljBGLT4Qps86I9rdEhxE8JtPUj7cfYUIqkdQ8jEDX(ObVJlpsEOVdoBWZU4Sl1Y6vzrJL9d3pOqRy1PylVw2poL6gBzwwUUc(w2kkKcbfG2rWrZz26kzdE20KDHcz)5enaenNzRRKnabLDXfnBWYMRtwNs94Nt0aae5AFGQOqQDUj7cfYgyzZ1jRtPEeVJM6qIt0Uyz9QSOXYY1jRtPULLRtGgp8wwy8HywL6eRy1bWT8Az)4uQBSLzzRKvozDllxNSoL6ry8HywL6KS5Nnfmdtet3jbFUbIs5MJJyXRCKn4GYUyaTL1RYIglBaAXO5gioML5wXQdTS8Az)4uQBSLzzRKvozDllxNSoL6ry8HywL6KS5NDjztbZWePVgZhikLBooIfVYr2GdkBAa0zxOq24GRuqIt0UGJm(aHyG4ywUhNn4GYMwzdw2LKTZZNSYJgemL6qge(rIpCKn4zxC2LMnyzJL7kH(nrcsd(zxQL1RYIgllJpqigioML7XwXQtrT8Az)4uQBSLzzRKvozDllxNSoL6ry8HywL6KS5Nno4kfK4eTl4iJpqigioML7XzdoOSb8S5NTxLL7HmijAUBuaakaTy0enijBaMTxLL7H(8W9ylRxLfnwwgFGqmqCml3JTIvhEGLxl7hNsDJTmlBLSYjRBz56K1PupcJpeZQuNKn)SljBkygMiLAhdEnpchKDHczdSSfx9rIC)GcHiWy6XpoL6MSl1Y6vzrJLLsTJbVMBfRo8ulVw2poL6gBzw2kzLtw3YY1jRtPEegFiMvPojB(zJdUsbjor7coY4deIbIJz5EC2GYU4S5NTxLL7HmijAUBuaakaTy0azqs2amBVkl3d95H7XwwVklASSHWYQC5wXQdW3YRL9JtPUXwMLTsw5K1TSCDY6uQhHXhIzvQtSSEvw0yzdHLv5YTIvSSvd2YRvhAS8Az)4uQBSLzzRKvozDllfmdtKsHqgfmwIK7vj7cfYwCI2LOSHhsqqM9zdqqzZdaSSluiBZPGzyIC)yUiEeoiB(zxriLbv(e56ZIPhjp03bNnaZUOwwVklASSbizrJvS6uSLxl7hNsDJTmlRxLfnwwnx9QRuNGHOqOXYwjRCY6w2kcPmOYNi3pMlIhjp03bNnabLnnzZp7sYgyzlU6JeXWuYjmWAp(XPu3KDHczBqsuZjeK8yqiSs2a1Es2GNnnzxA2fkKDfHugu5tK7hZfXJKh67GZg8SPvrTSJhElRMRE1vQtWqui0yfRoaULxl7hNsDJTmlBLSYjRBzRiKYGkFIC)yUiEK8qFhC2aeu20Kn)SljBGLT4QpsedtjNWaR94hNsDt2fkKTbjrnNqqYJbHWkzdu7jzdE20KDPzxOq2veszqLprUFmxepsEOVdoBWZMwf1Y6vzrJLfgFOvEi2kwDOLLxl7hNsDJTmlBLSYjRBznNcMHjY9J5I4r4alRxLfnwwkfczGyGjaWkwDkQLxl7hNsDJTmlBLSYjRBznNcMHjY9J5I4r4alRxLfnwwQtWNWXoAwXQdpWYRL9JtPUXwMLTsw5K1TSMtbZWe5(XCr8iCGL1RYIgllZsoLcHmwXQdp1YRL9JtPUXwMLTsw5K1TSMtbZWe5(XCr8iCGL1RYIglRp1JfIRGQUszfRoaFlVw2poL6gBzw2kzLtw3Ys81aDUFKOBm4iCq28ZUKSfNODjkB4HeeKzF2am7kkKcbfG2rWrZz26kzdOYMMyrZUqHSROqkeuaAhbhnNzRRKn4GYUgaf66cHd(yYUulRxLfnw2qNWXnqmicK5Uq3kwDa0wETSFCk1n2YSSvYkNSULL4Rb6C)ir3yWXDYg8SbCalBajBIVgOZ9JeDJbhnWexw0Kn)SROqkeuaAhbhnNzRRKn4GYUgaf66cHd(ySSEvw0yzdDch3aXGiqM7cDRy1HgaZYRL9JtPUXwMLTsw5K1TSalBSCxj0VjsqAWpB(zBqsKahiWKhLTYXoAzZp7sYgyzlU6JeXWuYjmWAp(XPu3KDHczdSSDE(KvEetNGGn3aHHzyqvxw0e)4uQBYUqHSnijQ5ecsEmiewjBGApjBWZMMSl1Y6vzrJLL7hZfXTIvhAOXYRL9JtPUXwMLTsw5K1TSIR(irmmLCcdS2JFCk1nzZpBGLTbjrnNqqYJYw5yhTS5NnxNSoL6r8oAQdjor7IL1RYIgllxFwmDRy1HMIT8Az)4uQBSLzzRKvozDlR4Qps86I9rdEhxE8JtPUjB(zxs2IR(iXz1OlyXvCCs8JtPUj7cfYwC1hjIHPKtyG1E8JtPUjB(zZ1jRtPEeVJM6qIt0UKDPzZp7kkKcbfG2rWzdoOSRbqHUUq4GpMS5NDfHugu5t86I9rdEhxEK8qFhC2amBAYMF2LKnWYwC1hjIHPKtyG1E8JtPUj7cfYgyz788jR8iMobbBUbcdZWGQUSOj(XPu3KDHczBqsuZjeK8yqiSs2a1Es2aeu20KDPwwVklASSC9zX0TIvhAaClVw2poL6gBzw2kzLtw3YkU6JeNvJUGfxXXjXpoL6MS5NnWYwC1hjEDX(ObVJlp(XPu3Kn)SROqkeuaAhbNn4GYUgaf66cHd(yYMF2MtbZWe5(XCr8iCGL1RYIgllxFwmDRy1HgAz51Y(XPu3ylZYwjRCY6wwXvFKigMsoHbw7XpoL6MS5NDjzdSSfx9rIxxSpAW74YJFCk1nzxOq2alBUozDk1J4D0uhsCI2LSlnB(zdSSXYDLq)MibPb)S5NDfHugu5tuZjeK8iCq28Z2GKOMtii5rYziht3PupB(zxs24GRuqIt0UGJm(aHyG4ywUhNnabLnGNn)SROqkeuaAhbhnNzRRKn4GYMMSblBCWvkiXjAxWrgFGqmqCml3JZUqHSXbxPGeNODbhz8bcXaXXSCpoBWbLnTYMF2vuifckaTJGJMZS1vYgCqztRSl1Y6vzrJLLRplMUvS6qtrT8Az)4uQBSLzzRKvozDlR4Qpsm0XYjqog7y8oXpoL6MS5NnWYgl3vc9BIUsLn)SdDSCcKJXogVde5H(o4SbiOSbSS5NnWY2GKiboqGjpsod5y6oL6wwVklASSC9zX0TIvhA4bwETSFCk1n2YSSvYkNSUL1GKiboqGjpsEOVdoBWZMwzdw20kBav21aOqxxiCWht28ZgyzBqsuZjeK8i5mKJP7uQBz9QSOXYEDX(ObVJl3kwDOHNA51Y(XPu3ylZYwjRCY6wwdsIe4abM8OSvo2rZY6vzrJLvq6UvikLBUvSIL1GelVwDOXYRL9JtPUXwMLTsw5K1TSIR(iXRl2hn4DC5XpoL6MS5NDjzxs2vuifckaTJGZgCqzxdGcDDHWbFmzZp7kcPmOYN41f7Jg8oU8i5H(o4Sby20KDPzxOq2LKnWYw2kh7OLn)SljBzdF2GNnnaw2fkKDffsHGcq7i4Sbhu2fNDPzxA2LAz9QSOXYsGdeyYTIvNIT8Az)4uQBSLzzzqeO56kwDOXY6vzrJLnaHuqKJrWK6TIvha3YRL9JtPUXwML1RYIglRMtii5w2kzLtw3Yws2alBXvFKigMsoHbw7XpoL6MSluiBGLDjzxriLbv(e56ZIPhHdYMF2veszqLprUFmxepsEOVdoBackBALDPzxA28ZUIcPqqbODeC0CMTUs2GdkBAYMF2KZqoMUtPE28ZUKSdcHvYgO2tYgGGYMMSluiBYd9DWzdqqzlBLdizdF28ZghCLcsCI2fCKXhiedehZY94Sbhu2aE2GLTZZNSYJy6eeS5gimmddQ6YIM4hNsDt2LMn)SljBGL91f7Jg8oUCt2fkKn5H(o4SbiOSLTYbKSHpBav2fNn)SXbxPGeNODbhz8bcXaXXSCpoBWbLnGNnyz788jR8iMobbBUbcdZWGQUSOj(XPu3KDPzZp7sYwCI2LOSHhsqqM9zdiztEOVdoBWZMwzZpBCWvkiXjAxWrgFGqmqCml3JZgGGYMMSluiBXjAxIYgEibbz2NnGKn5H(o4SbpBAko7sTSvauvhsCI2fSvhASIvhAz51Y(XPu3ylZYwjRCY6wwCWvkiXjAxWzdoOSloB(ztEOVdoBaMDXzdw2LKno4kfK4eTl4Sbhu2fn7sZMF2vuifckaTJGZgCqztllRxLfnw2kzdXObsEyWXIvS6uulVw2poL6gBzwwVklASSe4abMClBLSYjRBzROqkeuaAhbNn4GYMwzZpBYziht3PupB(zxs2bHWkzdu7jzdqqztt2fkKn5H(o4SbiOSLTYbKSHpB(zJdUsbjor7coY4deIbIJz5EC2GdkBapBWY255tw5rmDcc2CdegMHbvDzrt8JtPUj7sZMF2LKnWY(6I9rdEhxUj7cfYM8qFhC2aeu2Yw5as2WNnGk7IZMF24GRuqIt0UGJm(aHyG4ywUhNn4GYgWZgSSDE(KvEetNGGn3aHHzyqvxw0e)4uQBYU0S5NT4eTlrzdpKGGm7ZgqYM8qFhC2GNnTSSvauvhsCI2fSvhASIvSILL7j4fnwDkgWOb4dyaAahWI0a8PfTSSL7KzhnSLf4jmarKBYMhKTxLfnzRwSGJjqw2acIzv3Ys7S1xm2X4DCzrt2ahsd(jq0oB6IeG1ho5uBf6WuXkkKt8gcRCzrtL4mcN4nSYjLcrXjfJdiMZLZacIzvhZjpsoW5RbZjpcCqahsd(q6lg7y8oUSOjI3WAceTZw)OkiQtYU4I1l7IbmAa(zdizdO1hadqNnpQ)tGsGOD2fjDF0owFsGOD2as26RXCt28eBLJSfu2MZ4WkjBVklAYwTyjMar7SbKSbUhI4(SfNODbAzIjq0oBajB91yUjB9t8Zg4rEioMaLar7SlcDFfwUjBQZGip7kkKYLSPU2o4y26BT(abN9GgaHUtczGvz7vzrdoB0OaqmbYRYIgCmG8kkKYfqmkhZrcKxLfn4ya5vuiLlGbIthwl8J4YIMeiVklAWXaYROqkxadeNmiKjbI2zZoEaMosYM4RjBkygMBYglUGZM6miYZUIcPCjBQRTdoBFmzhqoGeGezhTSxC2g08ycKxLfn4ya5vuiLlGbIt84by6ibclUGtG8QSObhdiVIcPCbmqC6bbkaafGwmAsG8QSObhdiVIcPCbmqCIL7kHEcKxLfn4ya5vuiLlGbIZaKSOjbYRYIgCmG8kkKYfWaXzOt44gigebYCxORxa5vuiLlq4xrJbdQO6TmGi(AGo3ps0ngCChWPfGLaLar7SlcDFfwUj7Z9eaKTSHpBH(Z2RcIK9IZ256RYPupMar7SbUJL7kHE2lt2bimEPup7sgu2CHvZjoL6z)5H7XzVt2vuiLlLMa5vzrdgewURe6jqEvw0GbdeNCDY6uQR34Hh0Nt0aae5AFGQOqQDUrpUUc(G(CIgaIKR9bSa0IrZnquQFdgqXt5jxsXakCWvki6owEPjqEvw0GbdeNCDY6uQR34HheEhn1HeNODrpUUc(GWbxPGeNODbhz8bcXaXXSCpgGfNa5vzrdgmqCwDLcYRYIgi1If9gp8GWYDLq)g9wgqy5UsOFtKG0GFcKxLfnyWaXz1vkiVklAGulw0B8WdQAWjqEvw0GbdeNvxPG8QSObsTyrVXdpidssG8QSObdgioRUsb5vzrdKAXIEJhEqML8QKa5vzrdgmqC6KQphsqeYhrVLb0Nt0aq0CMTUc4GOPOGX1jRtPE8ZjAaaICTpqvui1o3Ka5vzrdgmqC6KQphkawHFcKxLfnyWaXPA1OlyiEsWgTWpscuceTZUiriLbv(GtG8QSObhRgmOaKSOrVLbefmdtKsHqgfmwIK7vPqbXjAxIYgEibbz2dqq8aaRqbZPGzyIC)yUiEeoGFfHugu5tKRplMEK8qFhmalAcKxLfn4y1GbdeNW4dTYd1B8WdsZvV6k1jyikeA0BzavriLbv(e5(XCr8i5H(oyacIg(LamXvFKigMsoHbw7XpoL6McfmijQ5ecsEmiewjBGApbCAkTqHkcPmOYNi3pMlIhjp03bdoTkAcKxLfn4y1GbdeNW4dTYdX6TmGQiKYGkFIC)yUiEK8qFhmabrd)saM4QpsedtjNWaR94hNsDtHcgKe1CcbjpgecRKnqTNaonLwOqfHugu5tK7hZfXJKh67GbNwfnbYRYIgCSAWGbItkfczGyGjaqVLbK5uWmmrUFmxepchKa5vzrdownyWaXj1j4t4yhn9wgqMtbZWe5(XCr8iCqcKxLfn4y1GbdeNml5ukeYO3YaYCkygMi3pMlIhHdsG8QSObhRgmyG40N6XcXvqvxP0BzazofmdtK7hZfXJWbjq0oBGhMSDJbNTtE2Wb6LnE2GNTq)zJMND5RqpBfQ8JLS5Lx9xmB9t8ZUC6FY2aGD0YMXXYjzl09j7IKhZ2CMTUs2is2LVcDeSKTpai7IKhJjqEvw0GJvdgmqCg6eoUbIbrGm3f66TmGi(AGo3ps0ngCeoGFjIt0UeLn8qccYShGvuifckaTJGJMZS1vau0elAHcvuifckaTJGJMZS1vahunak01fch8XuAceTZg4Hj7bLTBm4SlFvQSn7ZU8vOVt2c9N9CDLSbCadRx2W4NT(Nr)LnAYMcHXzx(k0rWs2(aGSlsEmMa5vzrdownyWaXzOt44gigebYCxOR3YaI4Rb6C)ir3yWXDahWbmaH4Rb6C)ir3yWrdmXLfn8ROqkeuaAhbhnNzRRaoOAauORleo4JjbI2zRF)yUiE2iybVMNnwURe6zx(k0Zg4GdeyYZgoiMnWBRqpBwyk5egyTNT4Qps2(yYMLobbBUjBwyggu1LfnzhGk)KSDv5oaWzdJF2LVc9SPGzyUjBEOtii5XeiVklAWXQbdgio5(XCrC9wgqadl3vc9BIeKg85BqsKahiWKhLTYXoA8lbyIR(irmmLCcdS2JFCk1nfkamNNpzLhX0jiyZnqyyggu1LfnXpoL6McfmijQ5ecsEmiewjBGApbCAknbI2zxe6kepBwyk5egyTNT(1Nftp7kAmRSOrFYw)e)SlN(NS5HoHGKNTHGccUjB0Kn7oAQNnVor7scKxLfn4y1GbdeNC9zX01BzajU6JeXWuYjmWAp(XPu3WhygKe1CcbjpkBLJD04Z1jRtPEeVJM6qIt0UKar7S1V(Sy6zx(k0ZUi0fRLnyzxIoRgDblUIJt0lBejBwyk5egyTNnAuaiB0Knn8wQ(KT(31DdHdZUi5XS9XKDrOlwlBYDdaYMbrYEUUs28WIu)La5vzrdownyWaXjxFwmD9wgqIR(iXRl2hn4DC5XpoL6g(LiU6JeNvJUGfxXXjXpoL6Mcfex9rIyyk5egyTh)4uQB4Z1jRtPEeVJM6qIt0Uuk)kkKcbfG2rWGdQgaf66cHd(y4xriLbv(eVUyF0G3XLhjp03bdqA4xcWex9rIyyk5egyTh)4uQBkuayopFYkpIPtqWMBGWWmmOQllAIFCk1nfkyqsuZjeK8yqiSs2a1EcabrtPjq0oB9RplME2LVc9S1z1OlyXvCCs2GLToOSlcDXA6t26Fx3neom7IKhZ2ht263pMlINnCqcKxLfn4y1GbdeNC9zX01BzajU6JeNvJUGfxXXjXpoL6g(atC1hjEDX(ObVJlp(XPu3WVIcPqqbODem4GQbqHUUq4Gpg(MtbZWe5(XCr8iCqceTZw)6ZIPND5RqpBwyk5egyTNnyzxIoOSlcDXAzJizxmVGvQ(KToOSXYDLqNtmmLCcdS21lBEOtii5zdCNHCmDNsD9Y(dcwJE24aV(SzqKS3PIc3rlBEOtii5zxK8ycKxLfn4y1GbdeNC9zX01BzajU6JeXWuYjmWAp(XPu3WVeGjU6JeVUyF0G3XLh)4uQBkuayCDY6uQhX7OPoK4eTlLYhyy5UsOFtKG0Gp)kcPmOYNOMtii5r4a(gKe1Ccbjpsod5y6oL68lbhCLcsCI2fCKXhiedehZY9yaccW5xrHuiOa0ocoAoZwxbCq0ago4kfK4eTl4iJpqigioML7XfkGdUsbjor7coY4deIbIJz5Em4GOf)kkKcbfG2rWrZz26kGdIwLMar7S1V(Sy6zx(k0Zw)7y5KS1xm2X7OpzRdkBSCxj0Z2ht2dkBVkl3NT(xFZMcMHrVSbo4abM8ShKK9oztod5y6zt8r7jqEvw0GJvdgmqCY1NftxVLbK4Qpsm0XYjqog7y8oXpoL6g(adl3vc9BIUsXp0XYjqog7y8oqKh67GbiiaJpWmijsGdeyYJKZqoMUtPEceTZUi0f7Jg8oU8SlN(NSPqc9Sbo4abM8S9XKnp0jeK8SDYZgoiBgejBfA0Y(dcwJEcKxLfn4y1GbdeNxxSpAW74Y1BzazqsKahiWKhjp03bdoTaJwaQAauORleo4JHpWmijQ5ecsEKCgYX0Dk1tG8QSObhRgmyG4uq6UvikLBUEldidsIe4abM8OSvo2rlbkbI2zR)wYRs2gp01E2o1QwzpobI2zxed3pOWSDjBAbw2LuuWYU8vONT(JT0SlsEmMnWty4nRlxbGSrt2fdw2It0UG1l7YxHE263pMlIRx2is2LVc9S5TmGxYgj0pP8f)Sl3xjBgejBmk8z)5enaeZwFvyu2L7RK9YKDrOlwl7kkKcL9IZUIc3rlB4GycKxLfn4OzjVkG(W9dkuVLbuffsHGcq7iyWbrlWex9rIM)GtGWcXfx7HXpoL6g(LyofmdtK7hZfXJWbfkyofmdtuq6UvikLBEeoOqHpNObGO5mBDfacQ4IcgxNSoL6XpNObaiY1(avrHu7CtHcaJRtwNs9iEhn1HeNODPu(LamXvFK41f7Jg8oU84hNsDtHcveszqLpXRl2hn4DC5rYd9DWGxCPjqEvw0GJML8Qagio56K1PuxVXdpiy8HywL6e946k4dQIcPqqbODeC0CMTUc40uOWNt0aq0CMTUcabvCrbJRtwNs94Nt0aae5AFGQOqQDUPqbGX1jRtPEeVJM6qIt0UKar7S5r0IrZnzZtmlZZ2LSlgqdw2yXRCGZgXKnlDNe85MSlt5MJJjqEvw0GJML8Qagiodqlgn3aXXSmxVLbexNSoL6ry8HywL6e(uWmmrmDNe85gikLBooIfVYb4GkgqNa5vzrdoAwYRcyG4KXhiedehZY9y9wgqCDY6uQhHXhIzvQt4xcfmdtK(AmFGOuU54iw8khGdIgaDHc4GRuqIt0UGJm(aHyG4ywUhdoiAbwjopFYkpAqWuQdzq4hj(Wb4fxkyy5UsOFtKG0GFPjq0oBGx9jBet28eZY94Sfu2EqGcazR)UBuaiBEeTy0K9YK9oEvwUpB0KTpaiBXjAxY2LSb8SfNODbNa5vzrdoAwYRcyG4KXhiedehZY9y9wgqCDY6uQhHXhIzvQt4JdUsbjor7coY4deIbIJz5Em4GaC(EvwUhYGKO5UrbaOa0Irt0Gea6vz5EOppCpobYRYIgC0SKxfWaXjLAhdEnxVLbexNSoL6ry8HywL6e(LqbZWePu7yWR5r4GcfaM4QpsK7huiebgtp(XPu3uAceTZMxNcq0)WYQC5zlOS9GafaYw)D3Oaq28iAXOjBxYU4SfNODbNa5vzrdoAwYRcyG4mewwLlxVLbexNSoL6ry8HywL6e(4GRuqIt0UGJm(aHyG4ywUhdQy(EvwUhYGKO5UrbaOa0IrdKbja0RYY9qFE4ECcKxLfn4OzjVkGbIZqyzvUC9wgqCDY6uQhHXhIzvQtsGsGOD26pp01E2iUNKTSHpBNAvRShNar7SzdEDDv2ahCGatE24lWbzZGizxe6I1sG8QSObhnibeboqGjxVLbK4Qps86I9rdEhxE8JtPUHFjLurHuiOa0ocgCq1aOqxxiCWhd)kcPmOYN41f7Jg8oU8i5H(oyastPfkucWKTYXoA8lr2WdonawHcvuifckaTJGbhuXLwAPjq0oBEOtii5zdhWXFGEz7kmkBHShNTGYgg)SxjBhNTNno411vzR95exqKSzqKSf6pBLJLSlsEmBQZGipBpBMDwm9tsG8QSObhnibmqCgGqkiYXiys96XGiqZ1vartcKxLfn4ObjGbItnNqqY1RcGQ6qIt0UGbrJEldOsaM4QpsedtjNWaR94hNsDtHcaRKkcPmOYNixFwm9iCa)kcPmOYNi3pMlIhjp03bdqq0Q0s5xrHuiOa0ocoAoZwxbCq0WNCgYX0Dk15xsqiSs2a1EcabrtHcKh67GbiizRCajB45JdUsbjor7coY4deIbIJz5Em4GaCWCE(KvEetNGGn3aHHzyqvxw0e)4uQBkLFja76I9rdEhxUPqbYd9DWaeKSvoGKn8aQI5JdUsbjor7coY4deIbIJz5Em4GaCWCE(KvEetNGGn3aHHzyqvxw0e)4uQBkLFjIt0UeLn8qccYShqip03bdoT4JdUsbjor7coY4deIbIJz5EmabrtHcIt0UeLn8qccYShqip03bdonfxAceTZUijBignzZ7ddowYgnkaKnAYoewjBG6zlor7coBxYMwGLDrYJzxo9pztGNzhTSrWs27KDX4SlboiBbLnTYwCI2fCPzJizd44SlPOGLT4eTl4stG8QSObhnibmqCwjBignqYddow0BzaHdUsbjor7cgCqfZN8qFhmalgSsWbxPGeNODbdoOIwk)kkKcbfG2rWGdIwjq0oBEI)GSHdYg4GdeyYZ2LSPfyzJMSDLkBXjAxWzxs50)KTA5UJw2k0OL9heSg9S9XK9GKSXJhGPJKstG8QSObhnibmqCsGdeyY1RcGQ6qIt0UGbrJEldOkkKcbfG2rWGdIw8jNHCmDNsD(LeecRKnqTNaqq0uOa5H(oyacs2khqYgE(4GRuqIt0UGJm(aHyG4ywUhdoiahmNNpzLhX0jiyZnqyyggu1LfnXpoL6Ms5xcWUUyF0G3XLBkuG8qFhmabjBLdizdpGQy(4GRuqIt0UGJm(aHyG4ywUhdoiahmNNpzLhX0jiyZnqyyggu1LfnXpoL6Ms5lor7su2WdjiiZEaH8qFhm40kbkbI2zZk3vc9BYwFRYIgCceTZwNvJowCfhNOx2is2SWucyfHUyTSrt20WR(Kn74by6ijBGdoqGjh4LS1xfgLnm(zdCWbcm5zJ4Es2fXW9dkm7Lj7vaEhN9GKS9Ga1Et2LOFe85KstG8QSObhXYDLq)gqe4abMC9wgqvuifckaTJGbheT4xI4QpsCwn6cwCfhNe)4uQBkuqC1hjIHPKtyG1E8JtPUHV4Qps86I9rdEhxE8JtPUHFfHugu5t86I9rdEhxEK8qFhmabvmFUozDk1J4D0uhsCI2LcfaMSvo2rRu(It0UeLn8qccYShqip03bdopibYRYIgCel3vc9BadeNF4(bfQ3YaQIcPqqbODem4GQbqHUUq4GpMeiANnlmLCcdS21NS13GafaYgrYg4od5y6zx(k0ZMcMH5MS5HoHGKJtG8QSObhXYDLq)gWaXPMtii56vbqvDiXjAxWGOrVLbK4QpsedtjNWaR94hNsDdFYziht3PuNV4eTlrzdpKGGm7beYd9DWGxCceTZMfMsoHbw76t26hCpHSMN9GiHUkBEOtii54SlFf6zJhpathjzZ9e8IgCcKxLfn4iwURe63agio1CcbjxVkaQQdjor7cgen6TmGex9rIyyk5egyTh)4uQB4tEOVdgGGObW4hecRKnqTNaqq0WxCI2LOSHhsqqM9ac5H(oyWlobI2zZctjNWaR9SblBw6eeS5MSzHzyqvxw0OpzRVbbkaK9DIcazdCWbcm5zl0Dj7YxLkBQNn5mKJPFt2mis2b(yE4wJjqEvw0GJy5UsOFdyG4KahiWKR3YasC1hjIHPKtyG1E8JtPUHVZZNSYJy6eeS5gimmddQ6YIM4hNsDdFGzqsKahiWKhLTYXoAjq0oBwyk5egyTND5CMnlDcc2Ct2SWmmOQllA0NSbU7bbkaKndIKnfAGXzxK8y2(yY(6kFm3KnE8amDKKTbM4YIMeiVklAWrSCxj0VbmqCQ5ecsUEvauvhsCI2fmiA0BzajU6JeXWuYjmWAp(XPu3W355tw5rmDcc2CdegMHbvDzrt8JtPUHV4eTlrzdpKGGm7bN8qFhCceTZMfMsoHbw7zdw2fHUyn9j7IG7NSrCpHSMNTNnE8amDKKnp0jeK8SjRgDjBNrojBGdoqGjpBQZGip7IqxSpAW74YIMeiVklAWrSCxj0VbmqCgGqkiYXiys96XGiqZ1vartcKxLfn4iwURe63agio1CcbjxVLbK4QpsedtjNWaR94hNsDdFXvFK41f7Jg8oU84hNsDd)kcPmOYN41f7Jg8oU8i5H(oyasd)aY5cPvnrAIe4abMC(gKejWbcm5rYd9DWGxuWOfGQgaf66cHd(ySS4GxT6uCrb0wXkwla]] )

end