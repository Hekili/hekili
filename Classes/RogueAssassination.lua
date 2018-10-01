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


    spec:RegisterPack( "Assassination", 20180930.1844, [[dWuycbqia0JqH6suqK2ef6tuqegLePtjrSkjk6vaLzrr5waH2Lq)cvyysu5yavltc1ZacMgkKRjrPTbKkFtIcgNev15KOkRJcsVJcQW8aIUhG2hk4GuuPfkH8qkQYeLOqxKIQ6Juq4KaPkReGEjfuPBcKQANOs(jfeLHsbLLcKYtrPPIk1vPGOARuqvFLcIO9sYFb1GvCyQwmsESKMmLUSQnJuFgvnAu0PvA1uqf9AurZMu3wq7wQFd1Wfy5qEoIPtCDq2of57aW4PaNhiz9uuX8LG9lAf4kUvSwxUIRIlh4LF5kpqOCrWlFgXigvguScOcUInWRC68xX2E4vSMlH4eY2US4wXg4GsJDRIBflbdHQxXYuKaIHYbh8RWeIkwXHCq2qiTllURiNw4GSHvoO0ykoOODq0EtCeGW0R(eomm0bnFTeommqdg0W8qh2CjeNq22Lf3rYgwvSuqRwa9AfLI16YvCvC5aV8lx5bcLlcE5ZOIlhOtX6qctmsXYUHMNIL5ATVvukw7jvflJZXCjeNq22Lf35aAyEONaY4CyksaXq5Gd(vycrfR4qoiBiK2Lf3vKtlCq2WkhuAmfhu0oiAVjocqy6vFchgg6GMVwchggObdAyEOdBUeItiB7YI7izdRjGmoh2hipK6OCaHYzwofxoWl)CaXCaV8n0IzucyciJZX8y6n)jgAciJZbeZXCT2BZXWDRCMJGZXEAhsl54vzXDo6LiXeqgNdiMdO9qSPNJ4i(lWlDuXQxIquCRyjYDTW8wf3kUaxXTI9TtPVvvKITIw5O1vSvCifgoaVTqYHbG5WOCmMtP5iU(Te7LNPqexZ5rX3oL(2CkuihX1VLibIsoIgI)X3oL(2CmMJ463s8gq8MhABxE8TtPVnhJ5uXyTfdGoEdiEZdTTlpIEOVnjhqcmNIZXyoMC06u6hjBZRpS4i(l5uOqoamhzRCUnFoLKJXCehXFjkB4HfmSDFoGyoOh6BtYHHCaDkwVklUvSiOabcDLO4Qyf3k23oL(wvrk2kALJwxXwXHuy4a82cjhgaMtnao0naMe82Qy9QS4wX(20BCOsuCbckUvSVDk9TQIuSEvwCRy5DeclxXwrRC06kwX1VLibIsoIgI)X3oL(2CmMd60Oty6u6NJXCehXFjkB4HfmSDFoGyoOh6BtYHHCkwXwbvvFyXr8xikUaxjkUyKIBf7BNsFRQifRxLf3kwEhHWYvSv0khTUIvC9BjsGOKJOH4F8TtPVnhJ5GEOVnjhqcmhWlxogZjieslBGEpkhqcmhWZXyoIJ4VeLn8Wcg2Uphqmh0d9Tj5WqofRyRGQQpS4i(lefxGRefxLvXTI9TtPVvvKITIw5O1vSIRFlrceLCene)JVDk9T5ymh3CoALhjmryi7TWeiAAC1Lf3X3oL(2CmMdaZXILickqGqpkBLZT5vSEvwCRyrqbce6krXfOtXTI9TtPVvvKI1RYIBflVJqy5k2kALJwxXkU(TejquYr0q8p(2P03MJXCCZ5OvEKWeHHS3ctGOPXvxwChF7u6BZXyoIJ4VeLn8Wcg2UphgYb9qFBIITcQQ(WIJ4VquCbUsuCvguCRyF7u6BvfPyPXi4(gikUaxX6vzXTInaJ1WOtWqO6vIIRYxXTI9TtPVvvKITIw5O1vSIRFlrceLCene)JVDk9T5ymhX1VL4nG4np02U84BNsFBogZPIXAlgaD8gq8MhABxEe9qFBsoGmhWZXyobOBcMVAJGhrqbce65ymhlwIiOabc9i6H(2KCyiNYMdy5WOCkZCQbWHUbWKG3wfRxLf3kwEhHWYvIsuS2t7qArXTIlWvCRyF7u6BvfPyn5AORyFFepOIOZ)ohWYjaVeCFlmL(3sYPmZPmKJH0CknNIZPmZHeCTgMPtKNtjkwVklUvSMC06u6Ryn5i42dVI99r8GcgD(3WvCi123QefxfR4wX(2P03QksXAY1qxXscUwdloI)cjs7nmMgMZEnDsoGmNIvSEvwCRyn5O1P0xXAYrWThEflzBE9HfhXFrjkUabf3kwVklUvSCUvovSVDk9TQIuIIlgP4wX(2P03QksXwrRC06kwICxlmVnIW8qxX6vzXTIT6AnSxLf3W6Likw9se42dVILi31cZBvIIRYQ4wX(2P03QksX6vzXTIT6AnSxLf3W6Likw9se42dVITAjkrXfOtXTI9TtPVvvKI1RYIBfB11AyVklUH1lruS6LiWThEfRflkrXvzqXTI9TtPVvvKI1RYIBfB11AyVklUH1lruS6LiWThEfRDrVkkrXv5R4wX(2P03QksXwrRC06k23hXdQO90BDLCyayoGx2CalhtoADk9JVpIhuWOZ)gUIdP2(wfRxLf3kwhv9(WcgHElkrXv5P4wX6vzXTI1rvVpCaKMCf7BNsFRQiLO4c8YP4wX6vzXTIvV8mfcSHtilF4BrX(2P03QksjkUahCf3k23oL(wvrk2kALJwxXApfenD00B7fXJqbkwVklUvSuAm2ctdHaLsuCbEXkUvSVDk9TQIuSv0khTUI1EkiA6OP32lIhHcuSEvwCRyPoICeNBZRefxGdckUvSVDk9TQIuSv0khTUI1EkiA6OP32lIhHcuSEvwCRy9UEIGCnC11ALOefBa6vCiLlkUvCbUIBf7BNsFRQiLO4Qyf3k23oL(wvrkrXfiO4wX(2P03QksjkUyKIBf7BNsFRQiLO4QSkUvSEvwCRy9GanOGdWlb3k23oL(wvrkrXfOtXTI1RYIBflrURfMk23oL(wvrkrXvzqXTI1RYIBfBawwCRyF7u6BvfPefxLVIBf7BNsFRQifRxLf3k2qhX5TW0yeS9UWuXwrRC06kwKVw4B6TeDRLe3ohgYHrLtXgGEfhs5cm5vCBjk2YQeLOyTl6vrXTIlWvCRyF7u6BvfPyROvoADfBfhsHHdWBlKCyayomkhWYrC9BjA)docMiixC(hgF7u6BZXyoLMJ9uq00rtVTxepcfKtHc5ypfenDuWgSvykTBFekiNcfY59r8GkAp9wxjhqcmNIlBoGLJjhToL(X3hXdky05FdxXHuBFBofkKdaZXKJwNs)izBE9HfhXFjNsYXyoLMdaZrC9BjEdiEZdTTlp(2P03MtHc5uXyTfdGoEdiEZdTTlpIEOVnjhgYP4CkrX6vzXTI9TP34qLO4Qyf3k23oL(wvrkwtUg6k2koKcdhG3wir7P36k5WqoGNtHc58(iEqfTNERRKdibMtXLnhWYXKJwNs)47J4bfm68VHR4qQTVnNcfYbG5yYrRtPFKSnV(WIJ4VOy9QS4wXAYrRtPVI1KJGBp8kwiYHPxT(iLO4ceuCRyF7u6BvfPyROvoADfRjhToL(riYHPxT(OCmMdfenDKW0rbVVfMs72tIeXRCMddaZP4YtX6vzXTInaVeCFlmN9sFLO4IrkUvSVDk9TQIuSv0khTUI1KJwNs)ie5W0RwFuogZP0COGOPJmxR9nmL2TNejIx5mhgaMd4LxofkKdj4AnS4i(lKiT3WyAyo710j5WaWCkohWYHi31cZBJimp0ZPqHCOGOPJcZdBr3TAmYsGTV(vIeXRCMddaZP4YlNsuSEvwCRyP9ggtdZzVMorjkUkRIBf7BNsFRQifBfTYrRRyn5O1P0pcrom9Q1hLJXCknhkiA6iLEBlzTpcfKtHc5aWCex)wIMEJdHrqeMX3oL(2CkrX6vzXTILsVTLS2RefxGof3k23oL(wvrk2kALJwxXAYrRtPFeICy6vRpsX6vzXTIneswTlxjkrXwTef3kUaxXTI9TtPVvvKITIw5O1vSuq00rkngB1qejIUxLCkuihXr8xIYgEybdB3NdibMdORC5uOqo2tbrthn92Er8iuqogZPIXAlgaD0K3lHze9qFBsoGmNYQy9QS4wXgGLf3krXvXkUvSVDk9TQIuSEvwCRy5D9RUwFebMcJBfBfTYrRRyRyS2Ibqhn92Er8i6H(2KCajWCaphJ5uAoamhX1VLibIsoIgI)X3oL(2CkuihlwI8ocHLhdcH0YgO3JYHHCapNsYPqHCQyS2Ibqhn92Er8i6H(2KCyihgvwfB7HxXY76xDT(icmfg3krXfiO4wX6vzXTIfIC4vEirX(2P03QksjkUyKIBf7BNsFRQifBfTYrRRyTNcIMoA6T9I4rOafRxLf3kwkngBHPHqGsjkUkRIBf7BNsFRQifBfTYrRRyTNcIMoA6T9I4rOafRxLf3kwQJihX528krXfOtXTI9TtPVvvKITIw5O1vS2tbrthn92Er8iuGI1RYIBfl9IoLgJTkrXvzqXTI9TtPVvvKITIw5O1vS2tbrthn92Er8iuGI1RYIBfR31teKRHRUwRefxLVIBf7BNsFRQifBfTYrRRyr(AHVP3s0TwsekihJ5uAoIJ4VeLn8Wcg2UphqMtfhsHHdWBlKO90BDLCkZCapw2CkuiNkoKcdhG3wir7P36k5WaWCQbWHUbWKG32CkrX6vzXTIn0rCElmngbBVlmvIIRYtXTI9TtPVvvKITIw5O1vSiFTW30Bj6wljUDomKdiuUCaXCq(AHVP3s0Tws0cHCzXDogZPIdPWWb4Tfs0E6TUsomamNAaCOBamj4TvX6vzXTIn0rCElmngbBVlmvIIlWlNIBf7BNsFRQifBfTYrRRybyoe5UwyEBeH5HEogZXILickqGqpkBLZT5ZXyoLMdaZrC9BjsGOKJOH4F8TtPVnNcfYbG54MZrR8iHjcdzVfMartJRUS4o(2P03MtHc5yXsK3riS8yqiKw2a9EuomKd45uOqoamhEegkiNsuSEvwCRyn92ErCLO4cCWvCRyF7u6BvfPyROvoADfR463sKarjhrdX)4BNsFBogZbG5yXsK3riS8OSvo3MphJ5yYrRtPFKSnV(WIJ4VOy9QS4wXAY7LWujkUaVyf3k23oL(wvrk2kALJwxXkU(TeVbeV5H22LhF7u6BZXyoLMJ463sSxEMcrCnNhfF7u6BZPqHCex)wIeik5iAi(hF7u6BZXyoMC06u6hjBZRpS4i(l5usogZPIdPWWb4TfsomamNAaCOBamj4TnhJ5uXyTfdGoEdiEZdTTlpIEOVnjhqMd45ymNsZbG5iU(TejquYr0q8p(2P03MtHc5aWCCZ5OvEKWeHHS3ctGOPXvxwChF7u6BZPqHCSyjY7iewEmieslBGEpkhqcmhWZPefRxLf3kwtEVeMkrXf4GGIBf7BNsFRQifBfTYrRRyfx)wI9YZuiIR58O4BNsFBogZbG5iU(TeVbeV5H22LhF7u6BZXyovCifgoaVTqYHbG5udGdDdGjbVT5ymh7PGOPJMEBViEekqX6vzXTI1K3lHPsuCboJuCRyF7u6BvfPyROvoADfR463sKarjhrdX)4BNsFBogZP0CayoIRFlXBaXBEOTD5X3oL(2CkuihaMJjhToL(rY286dloI)soLKJXCayoe5UwyEBeH5HEogZPIXAlgaDK3riS8iuqogZXILiVJqy5r0PrNW0P0phJ5uAoKGR1WIJ4VqI0EdJPH5SxtNKdibMdiKJXCQ4qkmCaEBHeTNERRKddaZb8CalhsW1AyXr8xirAVHX0WC2RPtYPqHCibxRHfhXFHeP9ggtdZzVMojhgaMdJYXyovCifgoaVTqI2tV1vYHbG5WOCkrX6vzXTI1K3lHPsuCbEzvCRyF7u6BvfPyROvoADfR463sm0jYrWoH4eY2X3oL(2CmMdaZHi31cZBJUwNJXCcDICeStioHSnm6H(2KCajWCkxogZbG5yXsebfiqOhrNgDctNsFfRxLf3kwtEVeMkrXf4Gof3k23oL(wvrk2kALJwxXAXsebfiqOhrp03MKdd5WOCalhgLtzMtnao0naMe82MJXCayowSe5DeclpIon6eMoL(kwVklUvS3aI38qB7YvIIlWldkUvSVDk9TQIuSv0khTUI1ILickqGqpkBLZT5vSEvwCRyfSbBfMs72ReLOyTyrXTIlWvCRyF7u6BvfPyROvoADfR463s8gq8MhABxE8TtPVnhJ5uAoLMtfhsHHdWBlKCyayo1a4q3aysWBBogZPIXAlgaD8gq8MhABxEe9qFBsoGmhWZPKCkuiNsZbG5iBLZT5ZXyoLMJSHphgYb8YLtHc5uXHuy4a82cjhgaMtX5usoLKtjkwVklUvSiOabcDLO4Qyf3k23oL(wvrkwAmcUVbIIlWvSEvwCRydWynm6emeQELO4ceuCRyF7u6BvfPy9QS4wXY7iewUITIw5O1vSLMdaZrC9BjsGOKJOH4F8TtPVnNcfYbG5uAovmwBXaOJM8EjmJqb5ymNkgRTya0rtVTxepIEOVnjhqcmhgLtj5usogZPIdPWWb4Tfs0E6TUsomamhWZXyoOtJoHPtPFogZP0CccH0YgO3JYbKaZb8Ckuih0d9Tj5asG5iBLtyzdFogZHeCTgwCe)fsK2BymnmN9A6KCyayoGqoGLJBohTYJeMimK9wycennU6YI74BNsFBoLKJXCknhaMZnG4np02UCBofkKd6H(2KCajWCKTYjSSHpNYmNIZXyoKGR1WIJ4VqI0EdJPH5SxtNKddaZbeYbSCCZ5OvEKWeHHS3ctGOPXvxwChF7u6BZPKCmMtP5ioI)su2Wdlyy7(CaXCqp03MKdd5WOCmMdj4AnS4i(lKiT3WyAyo710j5asG5aEofkKJ4i(lrzdpSGHT7ZbeZb9qFBsomKd4fNtjk2kOQ6dloI)crXf4krXfJuCRyF7u6BvfPyROvoADflj4AnS4i(lKCyayofNJXCqp03MKdiZP4CalNsZHeCTgwCe)fsomamNYMtj5ymNkoKcdhG3wi5WaWCyKI1RYIBfBfTHeCdlpm4erjkUkRIBf7BNsFRQifRxLf3kweuGaHUITIw5O1vSvCifgoaVTqYHbG5WOCmMd60Oty6u6NJXCknNGqiTSb69OCajWCapNcfYb9qFBsoGeyoYw5ew2WNJXCibxRHfhXFHeP9ggtdZzVMojhgaMdiKdy54MZrR8iHjcdzVfMartJRUS4o(2P03Mtj5ymNsZbG5CdiEZdTTl3MtHc5GEOVnjhqcmhzRCclB4ZPmZP4CmMdj4AnS4i(lKiT3WyAyo710j5WaWCaHCalh3CoALhjmryi7TWeiAAC1Lf3X3oL(2CkjhJ5ioI)su2Wdlyy7(CaXCqp03MKdd5WifBfuv9HfhXFHO4cCLOeLOynDezXTIRIlh4LF5kpWbpwCXGxSIfaoQ3MNOyb9cdWi52CaD54vzXDo6LiKycOILe8QIRIlB5Pydqy6vFflJZXCjeNq22Lf35aAyEONaY4CyksaXq5Gd(vycrfR4qoiBiK2Lf3vKtlCq2WkhuAmfhu0oiAVjocqy6vFchgg6GMVwchggObdAyEOdBUeItiB7YI7izdRjGmoh2hipK6OCaHYzwofxoWl)CaXCaV8n0IzucyciJZX8y6n)jgAciJZbeZXCT2BZXWDRCMJGZXEAhsl54vzXDo6LiXeqgNdiMdO9qSPNJ4i(lWlDmbmbKX5y(g8kKCBouNgJEovCiLl5qD(TjXCm3A9bcjNg3GithfsdPZXRYIBso4wdQycOxLf3Kya6vCiLlaP1oHZeqVklUjXa0R4qkxadihoeF4BXLf3jGEvwCtIbOxXHuUagqoOXyBciJZHT9actSKdYxBouq003MdrCHKd1PXONtfhs5souNFBsoEBZjaDqmalY285SKCS4(XeqVklUjXa0R4qkxadihK2dimXcmrCHKa6vzXnjgGEfhs5cya5Wdc0GcoaVeCNa6vzXnjgGEfhs5cya5Gi31cZeqVklUjXa0R4qkxadihbyzXDcOxLf3Kya6vCiLlGbKJqhX5TW0yeS9UW0Sa0R4qkxGjVIBlbyznBPbI81cFtVLOBTK42mWOYLaMaY4CmFdEfsUnNB6iqLJSHphH5ZXRcgLZsYXn5R2P0pMa6vzXnbOjhToL(M1E4b((iEqbJo)B4koKA7BnZKRHoW3hXdQi68VblaVeCFlmL(3skZYGH0slUmjbxRHz6e5LKa6vzXnbmGCyYrRtPVzThEGKT51hwCe)fZm5AOdKeCTgwCe)fsK2BymnmN9A6eqwCcOxLf3eWaYbNBLZeqVklUjGbKJQR1WEvwCdRxIyw7HhirURfM3A2sdKi31cZBJimp0ta9QS4MagqoQUwd7vzXnSEjIzThEGvljb0RYIBcya5O6AnSxLf3W6LiM1E4bAXscOxLf3eWaYr11AyVklUH1lrmR9Wd0UOxLeqVklUjGbKdhv9(WcgHElMT0aFFepOI2tV1vyai4LfmtoADk9JVpIhuWOZ)gUIdP2(2eqVklUjGbKdhv9(WbqAYta9QS4Magqo0lptHaB4eYYh(wsa9QS4MagqoO0ySfMgcbkZwAG2tbrthn92Er8iuqcOxLf3eWaYb1rKJ4CBEZwAG2tbrthn92Er8iuqcOxLf3eWaYH31teKRHRUwB2sd0EkiA6OP32lIhHcsatazCoMhgRTya0KeqVklUjXQLamallUnBPbsbrthP0ySvdrKi6EvkuqCe)LOSHhwWW29GeiORCfkypfenD00B7fXJqbgRyS2Ibqhn59sygrp03MaYYMa6vzXnjwTeWaYbe5WR8qZAp8a5D9RUwFebMcJBZwAGvmwBXaOJMEBViEe9qFBcibcUXsbO463sKarjhrdX)4BNsFBHcwSe5DeclpgecPLnqVhXa4LuOqfJ1wma6OP32lIhrp03MWaJkBcOxLf3Ky1sadihqKdVYdjjGEvwCtIvlbmGCqPXylmnecuMT0aTNcIMoA6T9I4rOGeqVklUjXQLagqoOoICeNBZB2sd0EkiA6OP32lIhHcsa9QS4MeRwcya5GErNsJXwZwAG2tbrthn92Er8iuqcOxLf3Ky1sadihExprqUgU6ATzlnq7PGOPJMEBViEekibKX5a6rNJBTKCC0ZbkWSCi9g8CeMphC)CaWkmZrJbWjsoCZDzmMJHCYZbamFNJfuBZNdTtKJYry6DoMNHLJ90BDLCWOCaWkmXqsoEdQCmpdlMa6vzXnjwTeWaYrOJ48wyAmc2ExyA2sde5Rf(MElr3AjrOaJLkoI)su2Wdlyy7EqwXHuy4a82cjAp9wxPmbpw2cfQ4qkmCaEBHeTNERRWaWAaCOBamj4TTKeqgNdOhDonoh3Aj5aGvRZXUphaScZTZry(C6BGKdiuoIz5arEoG(0LXCWDouycjhaSctmKKJ3GkhZZWIjGEvwCtIvlbmGCe6ioVfMgJGT3fMMT0ar(AHVP3s0TwsCBgaHYbIiFTW30Bj6wljAHqUS42yfhsHHdWBlKO90BDfgawdGdDdGjbVTjGmohd)B7fXZbdjK1(CiYDTWmhaScZCanOabc9CGcI5yi5kmZHfIsoIgI)5iU(TKJ32CyzIWq2BZHfIMgxDzXDobyaCuoUgaoOi5arEoayfM5qbrtFBogchHWYJjGEvwCtIvlbmGCy6T9I4MT0abirURfM3gryEOB0ILickqGqpkBLZT5nwkafx)wIeik5iAi(hF7u6BluaGU5C0kpsyIWq2BHjq004QllUJVDk9TfkyXsK3riS8yqiKw2a9EedGxOaa5ryOGssazCoMVbcYZHfIsoIgI)5y49EjmZPIB7klUn0CmKtEoaG57CmeocHLNJfHdcUnhCNd7286Nd3oI)scOxLf3Ky1sadihM8EjmnBPbkU(TejquYr0q8p(2P03AeGwSe5DeclpkBLZT5nAYrRtPFKSnV(WIJ4VKaY4Cm8EVeM5aGvyMJ5BaHphWYPuUwEMcrCnNhzwoyuoSquYr0q8phCRbvo4ohW5UednhqF3GnekmhZZWYXBBoMVbe(Cq3TGkhAmkN(gi5yimVYycOxLf3Ky1sadihM8EjmnBPbkU(TeVbeV5H22LhF7u6BnwQ463sSxEMcrCnNhfF7u6BluqC9BjsGOKJOH4F8TtPV1OjhToL(rY286dloI)sjgR4qkmCaEBHWaWAaCOBamj4T1yfJ1wma64nG4np02U8i6H(2eqcUXsbO463sKarjhrdX)4BNsFBHca0nNJw5rctegYElmbIMgxDzXD8TtPVTqblwI8ocHLhdcH0YgO3JajqWljbKX5y49EjmZbaRWmhUwEMcrCnNhLdy5WfohZ3acVHMdOVBWgcfMJ5zy54Tnhd)B7fXZbkib0RYIBsSAjGbKdtEVeMMT0afx)wI9YZuiIR58O4BNsFRrakU(TeVbeV5H22LhF7u6BnwXHuy4a82cHbG1a4q3aysWBRr7PGOPJMEBViEekibKX5y49EjmZbaRWmhwik5iAi(Ndy5ukx4CmFdi85Gr5um3GvIHMdx4CiYDTWKdceLCene)nlhdHJqy55aANgDctNsFZY5ngINzoKaV(COXOC2UId3MphdHJqy55yEgwcOxLf3Ky1sadihM8EjmnBPbkU(TejquYr0q8p(2P03ASuakU(TeVbeV5H22LhF7u6BluaGMC06u6hjBZRpS4i(lLyeGe5UwyEBeH5HUXkgRTya0rEhHWYJqbgTyjY7iewEeDA0jmDk9nwkj4AnS4i(lKiT3WyAyo710jGeiiySIdPWWb4Tfs0E6TUcdabhmsW1AyXr8xirAVHX0WC2RPtkuGeCTgwCe)fsK2BymnmN9A6egaYiJvCifgoaVTqI2tV1vyaiJkjbKX5y49EjmZbaRWmhqFNihLJ5siozBdnhUW5qK7AHzoEBZPX54vzn9Ca9n3COGOPnlhqdkqGqpNgl5SDoOtJoHzoiV5FcOxLf3Ky1sadihM8EjmnBPbkU(TedDICeStioHSD8TtPV1iajYDTW82OR1gdDICeStioHSnm6H(2eqcSCgbOflreuGaHEeDA0jmDk9tazCoMVbeV5H22LNday(ohkSWmhqdkqGqphVT5yiCeclphh9CGcYHgJYrJB(CEJH4zMa6vzXnjwTeWaYXnG4np02UCZwAGwSerqbce6r0d9TjmWiWyuzwdGdDdGjbVTgbOflrEhHWYJOtJoHPtPFcOxLf3Ky1sadihc2GTctPD7nBPbAXsebfiqOhLTY528jGjGmoNY4IEvYX6Ho)ZXPw9k7jjGmohZVn9ghMJl5WiWYP0YcwoayfM5ugzljhZZWI5a6fgE76Y1GkhCNtXGLJ4i(leZYbaRWmhd)B7fXnlhmkhaScZC4Uidh5GfMhbGL8CaGVso0yuoeC4Z59r8GkMJ5Qj4CaGVsolDoMVbe(CQ4qkColjNkoCB(CGcIjGEvwCtI2f9Qa8TP34qZwAGvCifgoaVTqyaiJatC9BjA)docMiixC(hgF7u6BnwQ9uq00rtVTxepcfuOG9uq00rbBWwHP0U9rOGcfEFepOI2tV1vajWIllyMC06u6hFFepOGrN)nCfhsT9TfkaqtoADk9JKT51hwCe)Lsmwkafx)wI3aI38qB7YJVDk9TfkuXyTfdGoEdiEZdTTlpIEOVnHHIljb0RYIBs0UOxfWaYHjhToL(M1E4bcrom9Q1hzMjxdDGvCifgoaVTqI2tV1vya8cfEFepOI2tV1vajWIllyMC06u6hFFepOGrN)nCfhsT9TfkaqtoADk9JKT51hwCe)LeqgNJHHxcUVnhd3EPFoUKtXLhy5qeVYjjhmDoSmDuW7BZPiTBpjMa6vzXnjAx0Rcya5iaVeCFlmN9sFZwAGMC06u6hHihME16JmsbrthjmDuW7BHP0U9Kir8kNmaS4Ylb0RYIBs0UOxfWaYbT3WyAyo710jMT0an5O1P0pcrom9Q1hzSukiA6iZ1AFdtPD7jrI4vozai4LxHcKGR1WIJ4VqI0EdJPH5SxtNWaWIbJi31cZBJimp0luGcIMokmpSfD3QXilb2(6xjseVYjdalU8kjb0RYIBs0UOxfWaYbLEBlzT3SLgOjhToL(riYHPxT(iJLsbrthP0BBjR9rOGcfaO463s00BCimcIWm(2P03wscOxLf3KODrVkGbKJqiz1UCZwAGMC06u6hHihME16JsatazCoLrp05FoythLJSHphNA1RSNKaY4CydEDDDoGguGaHEoKlqb5qJr5y(gq4ta9QS4MeTybickqGq3SLgO463s8gq8MhABxE8TtPV1yPLwXHuy4a82cHbG1a4q3aysWBRXkgRTya0XBaXBEOTD5r0d9TjGe8skuOuakBLZT5nwQSHNbWlxHcvCifgoaVTqyayXLusjjGmohdHJqy55afW5FGz54AcohbTNKJGZbI8CwjhNKJNdj41115W)(ixWOCOXOCeMphTtKCmpdlhQtJrphph6TxcZJsa9QS4MeTybmGCeGXAy0jyiu9MrJrW9nqacEcOxLf3KOflGbKdEhHWYnRcQQ(WIJ4VqacUzlnWsbO463sKarjhrdX)4BNsFBHcaS0kgRTya0rtEVeMrOaJvmwBXaOJMEBViEe9qFBcibYOskXyfhsHHdWBlKO90BDfgacUr0PrNW0P03yPbHqAzd07rGei4fkGEOVnbKaLTYjSSH3ij4AnS4i(lKiT3WyAyo710jmaeeaZnNJw5rctegYElmbIMgxDzXD8TtPVTeJLcWBaXBEOTD52cfqp03MasGYw5ew2WxMfBKeCTgwCe)fsK2BymnmN9A6egaccG5MZrR8iHjcdzVfMartJRUS4o(2P03wIXsfhXFjkB4HfmSDpiIEOVnHbgzKeCTgwCe)fsK2BymnmN9A6eqce8cfehXFjkB4HfmSDpiIEOVnHbWlUKeqgNJ5H2qcUZH7hgCIKdU1GkhCNtiKw2a9ZrCe)fsoUKdJalhZZWYbamFNdcQ7T5Zbdj5SDoftYPuOGCeComkhXr8xiLKdgLdiqYP0YcwoIJ4Vqkjb0RYIBs0IfWaYrfTHeCdlpm4eXSLgij4AnS4i(legawSr0d9TjGSyWkLeCTgwCe)fcdalBjgR4qkmCaEBHWaqgLaY4CmC)dYbkihqdkqGqphxYHrGLdUZX16CehXFHKtPaG57C0RPT5ZrJB(CEJH4zMJ32CASKdP9actSuscOxLf3KOflGbKdeuGaHUzvqv1hwCe)fcqWnBPbwXHuy4a82cHbGmYi60Oty6u6BS0GqiTSb69iqce8cfqp03MasGYw5ew2WBKeCTgwCe)fsK2BymnmN9A6egaccG5MZrR8iHjcdzVfMartJRUS4o(2P03wIXsb4nG4np02UCBHcOh6BtajqzRCclB4lZInscUwdloI)cjs7nmMgMZEnDcdabbWCZ5OvEKWeHHS3ctGOPXvxwChF7u6BlXO4i(lrzdpSGHT7br0d9TjmWOeWeqgNdRCxlmVnhZTklUjjGmohUwEMeX1CEKz5Gr5WcrjGz(gq4Zb35ao3gAoSThqyILCanOabcDdh5yUAcohiYZb0Gcei0ZbB6OCm)20BCyolDoRyibjNgl54bb692Ck1qwW7Jkjb0RYIBsKi31cZBbIGcei0nBPbwXHuy4a82cHbGmYyPIRFlXE5zkeX1CEu8TtPVTqbX1VLibIsoIgI)X3oL(wJIRFlXBaXBEOTD5X3oL(wJvmwBXaOJ3aI38qB7YJOh6BtajWInAYrRtPFKSnV(WIJ4VuOaaLTY528LyuCe)LOSHhwWW29Gi6H(2egaDjGEvwCtIe5UwyElya54TP34qZwAGvCifgoaVTqyaynao0naMe82MaY4CyHOKJOH4VHMJ5geObvoyuoG2PrNWmhaScZCOGOPVnhdHJqy5KeqVklUjrICxlmVfmGCW7iewUzvqv1hwCe)fcqWnBPbkU(TejquYr0q8p(2P03AeDA0jmDk9nkoI)su2Wdlyy7Eqe9qFBcdfNaY4CyHOKJOH4VHMJHmthHw7ZPXOqxNJHWriSCsoayfM5qApGWel5y6iYIBscOxLf3KirURfM3cgqo4Decl3SkOQ6dloI)cbi4MT0afx)wIeik5iAi(hF7u6BnIEOVnbKabVCgdcH0YgO3JajqWnkoI)su2Wdlyy7Eqe9qFBcdfNaY4CyHOKJOH4FoGLdltegYEBoSq004QllUn0Cm3GanOY5osdQCanOabc9CeMUKdawTohQNd60OtyEBo0yuobEBF4wJjGEvwCtIe5UwyElya5abfiqOB2sduC9BjsGOKJOH4F8TtPV1OBohTYJeMimK9wycennU6YI74BNsFRraAXsebfiqOhLTY528jGmohwik5iAi(Nda4ihwMimK92CyHOPXvxwCBO5aA3dc0GkhAmkhkCdrYX8mSC82MZnqEBVnhs7beMyjhleYLf3jGEvwCtIe5UwyElya5G3riSCZQGQQpS4i(leGGB2sduC9BjsGOKJOH4F8TtPV1OBohTYJeMimK9wycennU6YI74BNsFRrXr8xIYgEybdB3Za6H(2KeqgNdleLCene)ZbSCmFdi8gAoMVP35GnDeATphphs7beMyjhdHJqy55GwEMsooTCuoGguGaHEouNgJEoMVbeV5H22Lf3jGEvwCtIe5UwyElya5iaJ1WOtWqO6nJgJG7BGae8eqVklUjrICxlmVfmGCW7iewUzlnqX1VLibIsoIgI)X3oL(wJIRFlXBaXBEOTD5X3oL(wJvmwBXaOJ3aI38qB7YJOh6Btaj4gdq3emF1gbpIGcei0nAXsebfiqOhrp03MWqzbJrLznao0naMe82QeLOua]] )

end