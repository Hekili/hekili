-- RogueAssassination.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID = ns.FindUnitBuffByID
local IterateTargets, ActorHasDebuff = ns.iterateTargets, ns.actorHasDebuff


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
            value = 20,
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
        alacrity = 23015, -- 193539
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


    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not talent.master_assassin.enabled then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 3
        elseif buff.master_assassin.up then return buff.master_assassin.remains end
        return 0
    end )



    local stealth_dropped = 0


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

    local snapshots = {
        [121411] = true,
        [703]    = true,
        [154953] = true,
        [1943]   = true
    }

    local death_events = {
        UNIT_DIED               = true,
        UNIT_DESTROYED          = true,
        UNIT_DISSIPATES        = true,
        PARTY_KILL              = true,
        SPELL_INSTAKILL         = true,
    }


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == 'SPELL_AURA_REMOVED' or subtype == 'SPELL_AURA_BROKEN' or subtype == 'SPELL_AURA_BROKEN_SPELL' then
                if spellID == 115191 or spellID == 1784 then
                    stealth_dropped = GetTime()
                
                elseif spellID == 703 then
                    ssG[ destGUID ] = nil

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

        if death_events[ subtype ] then
            ssG[ destGUID ] = nil
        end
    end )

    spec:RegisterHook( "UNIT_ELIMINATED", function( guid )
        ssG[ guid ] = nil
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
        return debuff.garrote.ss_buffed or false
    end )

    spec:RegisterStateExpr( "non_ss_buffed_targets", function ()
        local count = ( debuff.garrote.down or not debuff.garrote.exsanguinated ) and 1 or 0

        for guid, counted in ns.iterateTargets() do
            if guid ~= target.unit and counted and ( not ns.actorHasDebuff( guid, 703 ) or not ssG[ guid ] ) then
                count = count + 1
            end
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
        if not this_action then return 0 end

        local a = class.abilities[ this_action ]
        if not a then return 0 end

        local aura = a.aura or this_action
        if not aura then return 0 end

        if debuff[ aura ] and debuff[ aura ].up then
            return debuff[ aura ].pmultiplier or 1
        end

        return 0
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

        debuff.garrote.ss_buffed               = nil
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
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
            duration = function () return talent.deeper_stratagem.enabled and 14 or 12 end,
            max_stack = 1,
            meta = {
                exsanguinated = function ( t ) return t.up and crimson_tempests[ target.unit ] end,                
                last_tick = function ( t ) return ltCT[ target.unit ] or t.applied end,
                tick_time = function( t ) return t.exsanguinated and haste or ( 2 * haste ) end,
            },                    
        },
        crimson_vial = {
            id = 185311,
            duration = 4,
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
            duration = function () return talent.deeper_stratagem.enabled and 7 or 6 end,
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
            duration = function () return talent.iron_wire.enabled and 6 or 3 end,
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
        iron_wire = {
            id = 256148,
            duration = 8,
            max_stack = 1,
        },
        kidney_shot = {
            id = 408,
            duration = function () return talent.deeper_stratagem.enabled and 7 or 6 end,
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
            duration = 3,
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
        slice_and_dice = {
            id = 315496,
            duration = function () return talent.deeper_stratagem.enabled and 42 or 36 end,
            max_stack = 1
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
                local up = cast + 3 < query_time

                local vr = buff.vendetta_regen

                if up then
                    vr.count = 1
                    vr.expires = cast + 3
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

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

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

            toggle = "defensives",

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

            usable = function () return combo_points.current > 0, "requires combo_points" end,

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
                applyDebuff( "target", "garrote", min( debuff.garrote.remains + debuff.garrote.duration, 1.3 * debuff.garrote.duration ) )
                debuff.garrote.pmultiplier = persistent_multiplier
                debuff.garrote.exsanguinated = false

                gain( 1, "combo_points" )

                if stealthed.rogue then
                    applyDebuff( "target", "garrote_silence" )
                    if talent.iron_wire.enabled then applyDebuff( "target", "iron_wire" ) end

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

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
            end,

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

            usable = function () return stealthed.all, "requires stealth" end,
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
        

        shiv = {
            id = 5938,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            spend = 20,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135428,
            
            handler = function ()
                gain( 1, "combo_points" )
                applyDebuff( "target", "crippling_poison_shiv" )
                applyDebuff( "target", "shiv" )
            end,

            auras = {
                crippling_poison_shiv = {
                    id = 319504,
                    duration = 9,
                    max_stack = 1,        
                },
                shiv = {
                    id = 319504,
                    duration = 9,
                    max_stack = 1,
                },
            }
        },


        shroud_of_concealment = {
            id = 114018,
            cast = 0,
            cooldown = 360,
            gcd = "spell",

            startsCombat = false,
            texture = 635350,

            usable = function () return stealthed.all, "requires stealth" end,
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

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up, "requires out of combat and not stealthed" end,            
            handler = function ()
                applyBuff( "stealth" )
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

            disabled = function ()
                return not ( boss and group ), "can only vanish in a boss encounter or with a group"
            end,

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
        },


        -- Covenant Abilities
        -- Rogue - Kyrian    - 323547 - echoing_reprimand    (Echoing Reprimand)
        echoing_reprimand = {
            id = 323547,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 3565450,

            toggle = "essences",

            handler = function ()
                -- Can't predict the Animacharge.
                gain( buff.broadside.up and 4 or 3, "combo_points" )
            end,

            auras = {
                echoing_reprimand = {
                    id = 323559,
                    duration = 45,
                    max_stack = 6,
                },                
            }
        },

        -- Rogue - Necrolord - 328547 - serrated_bone_spike  (Serrated Bone Spike)
        serrated_bone_spike = {
            id = 328547,
            cast = 0,
            charges = 3,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 3578230,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "serrated_bone_spike", nil, debuff.serrated_bone_spike.stack + 1 )
                gain( ( buff.broadside.up and 1 or 0 ) + debuff.serrated_bone_spike.stack, "combo_points" )
                -- TODO:  Odd behavior on target dummies.
            end,

            auras = {
                serrated_bone_spike = {
                    id = 324073,
                    duration = 3600,
                    max_stack = 3,
                },
            }
        },

        -- Rogue - Night Fae - 328305 - sepsis               (Sepsis)
        sepsis = {
            id = 313347,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 3636848,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "sepsis" )
            end,

            auras = {
                sepsis = {
                    id = 328305,
                    duration = 10,
                    max_stack = 1,
                }
            }
        },

        -- Rogue - Venthyr   - 323654 - slaughter            (Slaughter)
        slaughter = {
            id = 323654,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 50,
            spendType = "energy",
            
            startsCombat = true,
            texture = 3565724,

            -- toggle = "essences", -- no reason to restrict this one.

            usable = function ()
                return stealthed.all, "requires stealth"
            end,
            
            handler = function ()
                removeBuff( "instant_poison" )
                applyBuff( "slaughter_poison" )
                gain( buff.broadside.up and 3 or 2, "combo_points" )
            end,

            auras = {
                slaughter_poison = {
                    id = 323658,
                    duration = 300,
                    max_stack = 1,        
                },
                slaughter_poison_dot = {
                    id = 323659,
                    duration = 12,
                    max_stack = 1,
                },
            }
        },
        

    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_unbridled_fury",

        package = "Assassination",
    } )


    spec:RegisterSetting( "priority_rotation", false, {
        name = "Funnel AOE -> Target",
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

    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Assassination", 20200901, [[deLticqisjpsuHlHkfytOOpPsbnkujNcvyvij1RqHMfPu3sLq7sKFPs0WuP0XuPAzQK8muPAAIsCnrfTnvc6BIssJtLaohQuQ1HKKEhQuuAEIQCpKyFOG)HkfvhuLIAHQK6HijXevPqDruPKnkkj4JQuiJevkkojQuOvIK6LQuaZevkIBkkjANIIgQOKQLQsrEkQAQIcxfvkOTkkP8vuPinwvkq7vI)kPbl1HPSyu6XQyYKCzWMvLptLgns50kTArjHEnQOztv3MuTBf)gQHtfhxLaTCephY0jUUQA7ivFxuQXlQ05fv16rsmFsX(fUCVKrHxzcuY8QBV62B523EpDNBNZCY9Rk8s(oqH3XoCAUqHFmDOWFZiKHq7yYINcVJLVhBQsgfEe(toqHNMioiQ6Lx6UcTpB6G1VeT6FVjlEoe7jxIw9ZLfE2)6fUXPWw4vMaLmV62RU9wU9T3t3525mNxX9cV9fAysHNF1PkfEARsbtHTWRa0PWNJOVzeYqODmzXt03e29db15iAEWraDwGe9DTJ(QBV62G6G6CenvHMnUaIQguNJOVy03SsbQOVb2dNrl4OvWZ(EjA7ilEI2VijfuNJOVy03eOJPdrlgXfK6(sb15i6lg9nRuGkAUHiiAUrb0rrZf(lOvbrJFrJeW8cnosb15i6lgnvbp0bIaQOHCr24(3XeqLUbJwWrRWs6gmb5ISX9VJjGkv49lsqLmk8ibmVqduLmkzEVKrHhgJ1dQY1f(dzfGSwHxmpmsAwxAcsmpNajbJX6bv0mJ(G1zXvh8ockAgOeDwIMz0IrCbjjRoufCvTq0xmAcOB7GIMHOVWcVDKfpfEY3r(eOiLmVQKrHhgJ1dQY1f(hMuhixPK59cVDKfpfEhm2xjac)jhOiLm5EjJcpmgRhuLRl8hYkazTcVrfGScKq0i4Vcuv0)9Whtw8KGXy9GkAMrZ(FVe6Zka59DH03jAMrZ(FVe6Zka59DHeb0TDqrNx03tCpAMrRv0iuL9)EGQWBhzXtH31ieSafPKzwkzu4HXy9GQCDH)Hj1bYvkzEVWBhzXtH3bJ9vcGWFYbksjZCwYOWdJX6bv56cVDKfpfExJqWcu4pKvaYAfEX8Wij0NvaY77cjymwpOIMz0Cfnb0TDqrNx03VkAnAI2r)7L1XVaj68Oe99O5iAMrlgXfKKS6qvWv1crFXOjGUTdkAgI(Qc)j)JhQIrCbbvY8ErkzEHLmk8WySEqvUUWFiRaK1k8I5HrsOpRaK33fsWySEqfnZOnQaKvGeIgb)vGQI(Vh(yYINemgRhurZmATIwHLe57iFcKK9W5oUrZmA6gznwpKq746HQyexqk82rw8u4jFh5tGIuYmRwYOWdJX6bv56c)dtQdKRuY8EH3oYINcVdg7ReaH)KduKsMxGsgfEymwpOkxx4TJS4PW7AecwGc)HScqwRWlMhgjH(ScqEFxibJX6bv0mJ2OcqwbsiAe8xbQk6)E4JjlEsWySEqfnZO5kA7ilDOcdOVakAgI(E0A0eTwrlMhgjb5ISX9VJjqcgJ1dQO5iAMrlgXfKKS6qvWv1crZq0eq32bfnZO5kAcOB7GIoVOVFbIwJMO1kAeQY(Fpqfnhf(t(hpufJ4ccQK59IuYKBxYOWdJX6bv56c)dtQdKRuY8EH3oYINcVdg7ReaH)KduKsM3VTKrHhgJ1dQY1f(dzfGSwHxmpmsc9zfG8(UqcgJ1dQOzgTyEyKeKlYg3)oMajymwpOIMz02rw6qfgqFbu0uI(E0mJM9)Ej0NvaY77cjcOB7GIoVOVN4EH3oYINcVRriybksrk8acbZbqLmkzEVKrHhgJ1dQY1f(dzfGSwHhgG4MFswDOk4QULB0me99OzgTwrRa2)7LOdJceXsFNOzgnxrRv0kSKo45aJqmbu1N30Hk7NmjzpCUJB0mJwROTJS4jDWZbgHycOQpVPdPDQp)6stIwJMOFFVVsGdnJ4cvz1HOZlA3JkPB5gnhfE7ilEk8h8CGriMaQ6ZB6qrkzEvjJcpmgRhuLRl8hYkazTcVcy)VxIomkqel9DIMz0CfTcy)VxY1ieSajixKnU)DmburRrt0kG9)EjeTLE67enZOpyDwC1bVJGsk4TNvIopkrFpAnAIwbS)3lrhgfiILiGUTdk68Oe99BJMJO1Oj636stQeq32bfDEuI((TfE7ilEk8SEmwvXVQqdQWa65xKsMCVKrHhgJ1dQY1f(dzfGSwH)GXEfo7jrhgfiILiGUTdk68IM7rRrt0kG9)Ej6WOarS03jAnAI(TU0Kkb0TDqrNx0C)2cVDKfpfE3VruRnv8RAubiyHwrkzMLsgfEymwpOkxx4pKvaYAf(NhJjrZv0Cf9BDPjvcOB7GI(IrZ9BJMJO5geTDKfp1dg7v4SNO5iAgI(5Xys0Cfnxr)wxAsLa62oOOVy0C)2OVy0hm2RWzpj6WOarSeb0TDqrZr0CdI2oYIN6bJ9kC2t0Cu4TJS4PW7(nIATPIFvJkabl0ksjZCwYOWdJX6bv56c)HScqwRWJCaVVkgXfeu6ztf)QColDafnduI(QO1OjAITQkqhgjzkfkTt0me9fEB0mJggG4MF05fDw92O1Oj636stQeq32bfDErF)2cVDKfpf(h(8rGQAubiRavwW0lsjZlSKrHhgJ1dQY1f(dzfGSwHh5aEFvmIliO0ZMk(v5Cw6akAgOe9vrRrt0eBvvGomsYukuANOzi6l82O1Oj636stQeq32bfDErF)2cVDKfpfENpzF5VJBL1BiPiLmZQLmk8WySEqvUUWFiRaK1k8S)3lrGdNEaHQpm5aPVt0A0en7)9se4WPhqO6dtoq9G)JaKesSdNrNx03VTWBhzXtHxOb1)WI)JQ(WKduKsMxGsgfE7ilEk8K1XXd1DQih7afEymwpOkxxKsMC7sgfE7ilEk8zJjEfDyNkbq4XMdu4HXy9GQCDrkzE)2sgfEymwpOkxx4pKvaYAfEyaIB(rNx0582OzgTwrFWyVcN9KOdJceXsFNcVDKfpfEDqhtYVIFv))SQQIaMoQiLmVFVKrHhgJ1dQY1fE7ilEk8eWC2XT(8MoGk8hYkazTcVyexqsYQdvbxvleDErFpLZO1OjAUIMROfJ4csIgyEHwY5irZq0xGBJwJMOfJ4csIgyEHwY5irNhLOV62O5iAMrZv02rw6qfgqFbu0uI(E0A0eTyexqsYQdvbxvlendrFf3oAoIMJO1OjAUIwmIlijz1HQGRohPE1TrZq0C)2OzgnxrBhzPdvya9fqrtj67rRrt0IrCbjjRoufCvTq0meDwYs0Cenhf(t(hpufJ4ccQK59IuKcVcE23lLmkzEVKrHhgJ1dQY1f(dzfGSwHxROrcyEHgOsM3x4TJS4PWZ5E4SiLmVQKrH3oYINcpsaZl0k8WySEqvUUiLm5EjJcpmgRhuLRl8yNcpcKcVDKfpfE6gznwpu4PB(pu4HbiU5NiGlmrZy0o4fHhqvz9aOqrt1rNvJMBq0Cf9vrt1rJCaVVsZqcenhfE6gPoMou4HbiU5xjGlm1dwNDhqvKsMzPKrHhgJ1dQY1fEStHhbsH3oYINcpDJSgRhk80n)hk8ihW7RIrCbbLE2uXVkNZshqrNx0xv4PBK6y6qHhTJRhQIrCbPiLmZzjJcpmgRhuLRl8hYkazTcpsaZl0avIGD)qH3oYINc)X8(QDKfpv)IKcVFrsDmDOWJeW8cnqvKsMxyjJcpmgRhuLRl8hYkazTcpxrRv0I5Hrs6gsas1qidH2jbJX6bv0A0eTcljxJqWcKK9W5oUrZrH3oYINc)X8(QDKfpv)IKcVFrsDmDOWFuOIuYmRwYOWdJX6bv56cVDKfpf(J59v7ilEQ(fjfE)IK6y6qHxHLIuY8cuYOWdJX6bv56cVDKfpf(J59v7ilEQ(fjfE)IK6y6qHxTe4ifPKj3UKrHhgJ1dQY1f(dzfGSwHhgG4MFsbV9Ss0mqj675mAgJMUrwJ1djyaIB(vc4ct9G1z3bufE7ilEk8g5ydufmHaJuKsM3VTKrH3oYINcVro2avNVhbfEymwpOkxxKsM3VxYOWBhzXtH3VU0eunR4x5QdJu4HXy9GQCDrkzE)QsgfE7ilEk8SMBf)QczpCIk8WySEqvUUifPW7qGdwN1KsgLmVxYOWBhzXtH3CC85xDWlcpfEymwpOkxxKsMxvYOWdJX6bv56cVDKfpfEDJWjOQpmPQatOv4pKvaYAfEITQkqhgjzkfkTt0me99Cw4DiWbRZAsfbh8Oqf(CwKsMCVKrH3oYINcpsaZl0k8WySEqvUUiLmZsjJcpmgRhuLRl8JPdfEJkiAgXq1hEKk(vDWzdKcVDKfpfEJkiAgXq1hEKk(vDWzdKIuYmNLmk82rw8u4DWYINcpmgRhuLRlsrk8QLahPKrjZ7Lmk8WySEqvUUWFiRaK1k8hSolU6G3rqrZaLOZs0mgTyEyKKcahGurcXeZf0tWySEqfnZO5kAfW(FVeDyuGiw67eTgnrRa2)7Lq0w6PVt0A0enmaXn)KcE7zLOZJs0xLZOzmA6gznwpKGbiU5xjGlm1dwNDhqfTgnrRv00nYASEiH2X1dvXiUGenhrZmAUIwROfZdJKGCr24(3XeibJX6bv0A0eTwrRa2)7LOdJceXsFNO1Oj6dg7v4SNeKlYg3)oMajcOB7GIMHOVkAok82rw8u4HHomy9IuY8QsgfEymwpOkxx4XofEeifE7ilEk80nYASEOWt38FOWFW6S4QdEhbLuWBpRendrFpAnAIggG4MFsbV9Ss05rj6RYz0mgnDJSgRhsWae38ReWfM6bRZUdOIwJMO1kA6gznwpKq746HQyexqk80nsDmDOW)rq9TEpqksjtUxYOWdJX6bv56c)HScqwRWt3iRX6H0hb1369ajAMrBubiRaj4qdVJBL1BkaLGXy9GkAMrJCaVVkgXfeu6ztf)QColDafnduI(QOzmAUIwbS)3lrhgfiIL(ort1rZv03JMXO5kAJkazfibhA4DCRSEtbOeXgoJMs03JMJO5iAok82rw8u4F2uXVkNZshqfPKzwkzu4HXy9GQCDH)qwbiRv4PBK1y9q6JG6B9EGenZO5kA2)7LOTkfmvwVPaucj2HZOzGs0352rRrt0CfTwr7qwmzL8ReSyYINOzgnYb8(QyexqqPNnv8RY5S0bu0mqj6SenJrZv0gvaYkqsH)SEOQWiirSHZOzi6RIMJOzmAKaMxObQeb7(HO5iAok82rw8u4F2uXVkNZshqfPKzolzu4HXy9GQCDH3oYINc)ZMk(v5Cw6aQWFiRaK1k80nYASEi9rq9TEpqIMz0ihW7RIrCbbLE2uXVkNZshqrZaLO5EH)K)XdvXiUGGkzEViLmVWsgfEymwpOkxx4pKvaYAfE6gznwpK(iO(wVhirZmAUIM9)Ejw)ok0QG03jAnAIwROfZdJKOddwVs(iAjymwpOIMz0AfTrfGScKu4pRhQkmcsWySEqfnhfE7ilEk8S(DuOvbfPKzwTKrHhgJ1dQY1fE7ilEk86Fz9Maf(dzfGSwHNUrwJ1dPpcQV17bs0mJg5aEFvmIliO0ZMk(v5Cw6akAkrFvH)K)XdvXiUGGkzEViLmVaLmk8WySEqvUUWFiRaK1k80nYASEi9rq9TEpqk82rw8u41)Y6nbksrk8hfQKrjZ7Lmk8WySEqvUUWBhzXtH3OcIMrmu9HhPIFvhC2aPWFiRaK1k8AfnsaZl0avY8(OzgTUHeGuneYqODQeq32bfnLOVnAMrZv0hm2RWzpj6WOarSeb0TDqrNh38O5k6dg7v4SNeI2spraDBhu0uD0Wf8VooGkziA0TbqvIrfmPEWeZhnhrZr05f99BJMXOVFB0uD0Wf8VooGkziA0TbqvIrfmPEWeZhnZO1kAfW(FVeDyuGiw67enZO1kAfW(FVeI2sp9Dk8JPdfEJkiAgXq1hEKk(vDWzdKIuY8QsgfEymwpOkxx4pKvaYAfETIgjG5fAGkzEF0mJwHLe57iFcKK9W5oUrZmADdjaPAiKHq7ujGUTdkAkrFBH3oYINc)X8(QDKfpv)IKcVFrsDmDOWdiemhavKsMCVKrHhgJ1dQY1fE7ilEk86gHtqvFysvbMqRWFiRaK1k8eBvvGomsYuku67enZO5kAXiUGKKvhQcUQwi68I(G1zXvh8ockPG3EwjAQo67PCgTgnrFW6S4QdEhbLuWBpRenduI(4u1TCRihyurZrH)K)XdvXiUGGkzEViLmZsjJcpmgRhuLRl8hYkazTcpXwvfOdJKmLcL2jAgIM73g9fJMyRQc0HrsMsHsQpXKfprZm6dwNfxDW7iOKcE7zLOzGs0hNQULBf5aJQWBhzXtHx3iCcQ6dtQkWeAfPKzolzu4HXy9GQCDHh7u4rGu4TJS4PWt3iRX6HcpDZ)HcVwrlMhgjH(ScqEFxibJX6bv0A0eTwrBubiRajenc(Ravf9Fp8XKfpjymwpOIwJMOvyj5AecwGKJ(3lRJFbs0me99OzgnxrJCaVVkgXfeu6ztf)QColDafDErFHrRrt0Af9bJ9kC2tIUnlIw67enhfE6gPoMou4PdJceXQOpRaK33fQh8OwzXtrkzEHLmk8WySEqvUUWJDk8iqk82rw8u4PBK1y9qHNU5)qHxROfZdJKM1LMGeZZjqsWySEqfTgnrRv0I5HrsqUiBC)7ycKGXy9GkAnAI(GXEfo7jb5ISX9VJjqIa62oOOZl6Cg9fJ(QOP6OfZdJKua4aKksiMyUGEcgJ1dQcpDJuhthk80HrbIy1zDPjiX8CcK6bpQvw8uKsMz1sgfEymwpOkxx4XofEeifE7ilEk80nYASEOWt38FOWRv0Wf8VooGkzubrZigQ(WJuXVQdoBGeTgnrBubiRajenc(Ravf9Fp8XKfpjymwpOIwJMOva7)9seJkys9GjMVQa2)7Lu4SNO1Oj6dg7v4SNKHOr3gavjgvWK6btmFIa62oOOZl673gnZO5k6dg7v4SNeI2spraDBhu05f99O1OjAfW(FVeI2sp9DIMJcpDJuhthk80HrbIy1hEK6bpQvw8uKsMxGsgfEymwpOkxx4pKvaYAfETIgjG5fAGkrWUFiAMrRWsI8DKpbsYE4Ch3OzgTwrRa2)7LOdJceXsFNOzgnDJSgRhs0HrbIyv0NvaY77c1dEuRS4jAMrt3iRX6HeDyuGiwDwxAcsmpNaPEWJALfprZmA6gznwpKOdJceXQp8i1dEuRS4PWBhzXtHNomkqeRiLm52Lmk8WySEqvUUWFiRaK1k8I5HrsqUiBC)7ycKGXy9GkAMrlMhgjnRlnbjMNtGKGXy9GkAMrFW6S4QdEhbfnduI(4u1TCRihyurZm6dg7v4SNeKlYg3)oMajcOB7GIoVOVx4TJS4PWt3MfrRiLmVFBjJcpmgRhuLRl8hYkazTcVyEyK0SU0eKyEobscgJ1dQOzgTwrlMhgjb5ISX9VJjqcgJ1dQOzg9bRZIRo4Deu0mqj6Jtv3YTICGrfnZO5kAfW(FVeDyuGiw67eTgnrdiemhirFrlEQ4x1bip4ilEsWySEqfnhfE7ilEk80Tzr0ksjZ73lzu4HXy9GQCDHh7u4rGu4TJS4PWt3iRX6HcpDZ)HcVrfGScKq0i4Vcuv0)9Whtw8KGXy9GkAMrZv0dEQiuL9)EGQkgXfeu0mqj67rRrt0ihW7RIrCbbLE2uXVkNZshqrtjAUhnhrZmAUIgHQS)3duvXiUGGQglMouDSrb67jAkrFB0A0enYb8(QyexqqPNnv8RY5S0bu0mqj6lmAok80nsDmDOWJqv62SiA1dEuRS4PiLmVFvjJcpmgRhuLRl82rw8u4DWyFLai8NCGcpKRqSQPJ)Ju4Zsol8pmPoqUsjZ7fPK5DUxYOWdJX6bv56c)HScqwRWlMhgjH(ScqEFxibJX6bv0mJwROrcyEHgOseS7hIMz0hm2RWzpjxJqWcK(orZmAUIMUrwJ1djeQs3MfrREWJALfprRrt0AfTrfGScKq0i4Vcuv0)9Whtw8KGXy9GkAMrZv0kSKCncblqIapcGOzSEiAnAIwbS)3lrhgfiIL(orZmAfwsUgHGfi5O)9Y64xGeDEuI(E0CenhrZm6dwNfxDW7iOKcE7zLOzGs0CfnxrFpAgJ(QOP6OnQaKvGeIgb)vGQI(Vh(yYINemgRhurZr0uD0ihW7RIrCbbLE2uXVkNZshqrZr0mWnp6SenZOj2QQaDyKKPuO0orZq03VQWBhzXtHNUnlIwrkzEplLmk8WySEqvUUWFiRaK1k8I5Hrs6gsas1qidH2jbJX6bv0mJwROrcyEHgOsM3hnZO1nKaKQHqgcTtLa62oOOZJs03gnZO1kAfwsKVJ8jqIapcGOzSEiAMrRWsY1ieSajcOB7GIMHO5E0mJMROva7)9s0HrbIyPVt0mJwbS)3lHOT0tFNO5iAMrZv0AfnGqWCGeRhJvv8Rk0GkmGE(jDlRiMeTgnrRa2)7Ly9ySQIFvHguHb0Zp9DIMJO1OjAaHG5aj6lAXtf)Qoa5bhzXtcgJ1dQO5OWBhzXtHNUnlIwrkzEpNLmk8WySEqvUUWFiRaK1k8AfnsaZl0avY8(OzgTrfGScKq0i4Vcuv0)9Whtw8KGXy9GkAMrRWsY1ieSajc8iaIMX6HOzgTcljxJqWcKC0)EzD8lqIopkrFpAMrFW6S4QdEhbLuWBpRenduI(EH3oYINcpIMPWzRdEvrkzE)clzu4HXy9GQCDH)qwbiRv41kAKaMxObQeb7(HOzgnxrRv0kSKCncblqIapcGOzSEiAMrRWsI8DKpbseq32bfndrNLOzm6Senvh9XPQB5wroWOIwJMOvyjr(oYNajcOB7GIMQJ(2uoJMHOfJ4csswDOk4QAHO5iAMrlgXfKKS6qvWv1crZq0zPWBhzXtHhYfzJ7FhtGIuY8EwTKrHhgJ1dQY1f(dzfGSwHxHLe57iFcKK9W5oUrZmAUIwROHl4FDCavYOcIMrmu9HhPIFvhC2ajAnAI(GXEfo7jrhgfiILiGUTdkAgI((TrZrH3oYINcpI2sViLmVFbkzu4HXy9GQCDH)qwbiRv4z)VxI1JXk)hjjcyhjAnAIwbS)3lrhgfiIL(ofE7ilEk8oyzXtrkzENBxYOWdJX6bv56c)HScqwRWRa2)7LOdJceXsFNcVDKfpfEwpgRQVpj)IuY8QBlzu4HXy9GQCDH)qwbiRv4va7)9s0HrbIyPVtH3oYINcplqqaHZDClsjZRUxYOWdJX6bv56c)HScqwRWRa2)7LOdJceXsFNcVDKfpf(3sawpgRksjZRUQKrHhgJ1dQY1f(dzfGSwHxbS)3lrhgfiIL(ofE7ilEk82CaKqmF9yEFrkzEf3lzu4HXy9GQCDH3oYINcVR5HJ59abvzX4PWFiRaK1k8CfTcy)VxIomkqel9DIwJMO5kATIwmpmscYfzJ7FhtGemgRhurZm6dg7v4SNeDyuGiwIa62oOOzi6SKZO1OjAX8WijixKnU)DmbsWySEqfnZO5k6dg7v4SNeKlYg3)oMajcOB7GIoVOVWO1Oj6dg7v4SNeKlYg3)oMajcOB7GIMHOV62Ozg9BDPjvcOB7GIMHOVWCgnhrZr0CenZO1kAfwsKVJ8jqcYfzJ7FhtavHFmDOW7AE4yEpqqvwmEksjZRYsjJcpmgRhuLRl82rw8u4nen62aOkXOcMupyI5l8hYkazTcVcy)VxIyubtQhmX8vfW(FVKcN9eTgnr)wxAsLa62oOOZl6RUTWpMou4nen62aOkXOcMupyI5lsjZRYzjJcpmgRhuLRl82rw8u4nen62aOkXOcMupyI5l8hYkazTcpxrRv0I5HrsqUiBC)7ycKGXy9GkAnAIwROfZdJKqFwbiVVlKGXy9GkAoIMz0kG9)Ej6WOarSeb0TDqrZq03Vn6lgDwIMQJgUG)1XbujJkiAgXq1hEKk(vDWzdKc)y6qH3q0OBdGQeJkys9GjMViLmV6clzu4HXy9GQCDH3oYINcVHOr3gavjgvWK6btmFH)qwbiRv45kAX8WijixKnU)DmbsWySEqfnZOfZdJKqFwbiVVlKGXy9GkAoIMz0kG9)Ej6WOarS03jAMrZv0kSKCncblqcYfzJ7Fhtav0A0eTrfGScKq0i4Vcuv0)9Whtw8KGXy9GkAMrRWsY1ieSajh9Vxwh)cKOzi67rZrHFmDOWBiA0TbqvIrfmPEWeZxKsMxLvlzu4HXy9GQCDH3oYINc)j)Jhle8SNkR3qsH)qwbiRv41nKaKQHqgcTtLa62oOOPe9TrZmATIwbS)3lrhgfiIL(orZmATIwbS)3lHOT0tFNOzgn7)9s6GoMKFf)Q()zvvfbmDusHZEIMz0Wae38JoVOVa3gnZOvyjr(oYNajcOB7GIMHOZsHhEp4i1X0Hc)j)Jhle8SNkR3qsrkzE1fOKrHhgJ1dQY1fE7ilEk8(pHtGGQ7Gw1I)OQ7(Kc)HScqwRWRa2)7LOdJceXsFNc)y6qH3)jCceuDh0Qw8hvD3NuKsMxXTlzu4HXy9GQCDH3oYINcV)Jec(JQUyVcMQJ)RBUqH)qwbiRv4va7)9s0HrbIyPVtHFmDOW7)iHG)OQl2RGP64)6MluKsMC)2sgfEymwpOkxx4TJS4PW76n1AcMGQ6GY8(fpf(dzfGSwHxbS)3lrhgfiIL(ofE49GJuhthk8UEtTMGjOQoOmVFXtrkzY97Lmk8WySEqvUUWBhzXtH31BQ1embvznLlu4pKvaYAfEfW(FVeDyuGiw67u4H3dosDmDOW76n1AcMGQSMYfksjtUFvjJcVDKfpf(pcQRa6OcpmgRhuLRlsrk8kSuYOK59sgfEymwpOkxx4XofEeifE7ilEk80nYASEOWt38FOW7qwmzL8ReSyYINOzgnYb8(QyexqqPNnv8RY5S0bu0men3JMz0CfTcljxJqWcKiGUTdk68I(GXEfo7j5AecwGK6tmzXt0A0eTdEr4buvwpaku0meDoJMJcpDJuhthk8ioxN6j)JhQUgHGfOiLmVQKrHhgJ1dQY1fEStHhbsH3oYINcpDJSgRhk80n)hk8oKftwj)kblMS4jAMrJCaVVkgXfeu6ztf)QColDafndrZ9OzgnxrRa2)7Lq0w6PVt0A0enxr7GxeEavL1dGcfndrNZOzgTwrBubiRaj0bgPIFvwpgRsWySEqfnhrZrHNUrQJPdfEeNRt9K)XdvY3r(eOiLm5EjJcpmgRhuLRl8yNcpcKcVDKfpfE6gznwpu4PB(pu4va7)9s0HrbIyPVt0mJMROva7)9siAl903jAnAIw3qcqQgczi0ovcOB7GIMHOVnAoIMz0kSKiFh5tGeb0TDqrZq0xv4PBK6y6qHhX56ujFh5tGIuYmlLmk8WySEqvUUWFiRaK1k8I5HrsqUiBC)7ycKGXy9GkAMrRv0qUiBC)7ycOIMz0kSKCncblqYr)7L1XVaj68Oe99Ozg9bJ9kC2tcYfzJ7FhtGeb0TDqrNx0xfnZOroG3xfJ4cck9SPIFvoNLoGIMs03JMz0eBvvGomsYukuANOzi6lmAMrRWsY1ieSajcOB7GIMQJ(2uoJoVOfJ4csswDOk4QAHcVDKfpfExJqWcuKsM5SKrHhgJ1dQY1f(dzfGSwHxmpmscYfzJ7FhtGemgRhurZmATIwHLKRriybse4raenJ1drZmAUI(G1zXvh8ockAgOe9XPQB5wroWOIMz0hm2RWzpjixKnU)Dmbseq32bfDErFpAMrRWsI8DKpbseq32bfnvh9TPCgDErlgXfKKS6qvWv1crZrH3oYINcp57iFcuKsMxyjJcpmgRhuLRl8pmPoqUsjZ7fE7ilEk8oySVsae(toqrkzMvlzu4HXy9GQCDH)qwbiRv4jWJaiAgRhIMz0hSolU6G3rqjf82ZkrZaLOVhnJrZ9OP6O5kAJkazfiHOrWFfOQO)7HpMS4jbJX6bv0mJ(GXEfo7jr3Mfrl9DIMJOzgnxr7O)9Y64xGeDEuI(E0A0enb0TDqrNhLOL9WzvwDiAMrJCaVVkgXfeu6ztf)QColDafnduIM7rZy0gvaYkqcrJG)kqvr)3dFmzXtcgJ1dQO5iAMrZv0AfnKlYg3)oMaQO1OjAcOB7GIopkrl7HZQS6q0uD0xfnZOroG3xfJ4cck9SPIFvoNLoGIMbkrZ9OzmAJkazfiHOrWFfOQO)7HpMS4jbJX6bv0CenZO1kAeQY(FpqfnZO5kAXiUGKKvhQcUQwi6lgnb0TDqrZr0meDwIMz0CfTUHeGuneYqODQeq32bfnLOVnAnAIwROL9W5oUrZmAJkazfiHOrWFfOQO)7HpMS4jbJX6bv0Cu4TJS4PW7AecwGIuY8cuYOWdJX6bv56c)dtQdKRuY8EH3oYINcVdg7ReaH)KduKsMC7sgfEymwpOkxx4TJS4PW7AecwGc)HScqwRWRv00nYASEiH4CDQN8pEO6AecwGOzgnbEearZy9q0mJ(G1zXvh8ockPG3EwjAgOe99OzmAUhnvhnxrBubiRajenc(Ravf9Fp8XKfpjymwpOIMz0hm2RWzpj62SiAPVt0CenZO5kAh9Vxwh)cKOZJs03JwJMOjGUTdk68OeTShoRYQdrZmAKd49vXiUGGspBQ4xLZzPdOOzGs0CpAgJ2OcqwbsiAe8xbQk6)E4JjlEsWySEqfnhrZmAUIwROHCr24(3XeqfTgnrtaDBhu05rjAzpCwLvhIMQJ(QOzgnYb8(QyexqqPNnv8RY5S0bu0mqjAUhnJrBubiRajenc(Ravf9Fp8XKfpjymwpOIMJOzgTwrJqv2)7bQOzgnxrlgXfKKS6qvWv1crFXOjGUTdkAoIMHOVFv0mJMRO1nKaKQHqgcTtLa62oOOPe9TrRrt0AfTSho3XnAMrBubiRajenc(Ravf9Fp8XKfpjymwpOIMJc)j)JhQIrCbbvY8ErkzE)2sgfEymwpOkxx4TJS4PWFiRocpvb0DaKu4pKvaYAfEKd49vXiUGGIMHO5E0mJMa62oOOZl6RIMXO5kAKd49vXiUGGIMbkrNZO5iAMrFW6S4QdEhbfnduIolf(t(hpufJ4ccQK59IuY8(9sgfEymwpOkxx4pKvaYAfETIMUrwJ1djeNRtL8DKpbIMz0Cf9bRZIRo4Deu0mqj6SenZOjWJaiAgRhIwJMO1kAzpCUJB0mJMROLvhIMHOVFB0A0e9bRZIRo4Deu0mqj6RIMJO5iAMrZv0o6FVSo(firNhLOVhTgnrtaDBhu05rjAzpCwLvhIMz0ihW7RIrCbbLE2uXVkNZshqrZaLO5E0mgTrfGScKq0i4Vcuv0)9Whtw8KGXy9GkAoIMz0CfTwrd5ISX9VJjGkAnAIMa62oOOZJs0YE4SkRoenvh9vrZmAKd49vXiUGGspBQ4xLZzPdOOzGs0CpAgJ2OcqwbsiAe8xbQk6)E4JjlEsWySEqfnhrZmAXiUGKKvhQcUQwi6lgnb0TDqrZq0zPWBhzXtHN8DKpbksjZ7xvYOWdJX6bv56cVDKfpfEY3r(eOWFiRaK1k8AfnDJSgRhsioxN6j)JhQKVJ8jq0mJwROPBK1y9qcX56ujFh5tGOzg9bRZIRo4Deu0mqj6SenZOjWJaiAgRhIMz0CfTJ(3lRJFbs05rj67rRrt0eq32bfDEuIw2dNvz1HOzgnYb8(QyexqqPNnv8RY5S0bu0mqjAUhnJrBubiRajenc(Ravf9Fp8XKfpjymwpOIMJOzgnxrRv0qUiBC)7ycOIwJMOjGUTdk68OeTShoRYQdrt1rFv0mJg5aEFvmIliO0ZMk(v5Cw6akAgOen3JMXOnQaKvGeIgb)vGQI(Vh(yYINemgRhurZr0mJwmIlijz1HQGRQfI(IrtaDBhu0meDwIMXO5kAh8IWdOQSEauOOzi6RIMJOP6OVWc)j)JhQIrCbbvY8ErkzEN7Lmk8WySEqvUUWBhzXtH)qwDeEQcO7aiPWFiRaK1k8ihW7RIrCbbfndrFpAMrJCaVVkgXfeu05fDwIMz0eq32bfDErFv0mJ(G1zXvh8ockAgOeDwk8N8pEOkgXfeujZ7fPK59SuYOWdJX6bv56c)HScqwRWJCaVVkgXfeu0uI(E0mJ(G1zXvh8ockAgOenxrFCQ6wUvKdmQOVy03JMJOzgnbEearZy9q0mJwROHCr24(3XeqfnZO1kAfW(FVeI2sp9DIMz06gsas1qidH2PsaDBhu0uI(2OzgTwrBubiRajj7fjvHgu5C2hKGXy9GkAMrlgXfKKS6qvWv1crFXOjGUTdkAgIolfE7ilEk8hYQJWtvaDhajfPK59CwYOWdJX6bv56c)HScqwRWJCaVVkgXfeu0menxrNvJ(IrZ(FVem0HbRN(orZr0mJ(G1zXvh8ockAgOeDwIMXOfZdJKua4aKksiMyUGEcgJ1dQOzgTwrRa2)7LOdJceXsFNOzgTwrRa2)7Lq0w6PVt0mJwROnQaKvGKK9IKQqdQCo7dsWySEqfnZOHbiU5NuWBpReDEuI(QCgnJrt3iRX6HemaXn)kbCHPEW6S7aQcVDKfpf(dz1r4PkGUdGKIuKIu4Pde0INsMxD7v3E7fEplf(SnYSJlQWZn9MVPm5gZ8grvJo6mObrV6oyIe9dtI(gciemhaDdJMaxW)sav0iSoeT9fSUjGk6dnBCbukOMBYoq0xrvJMQGh6arav03qixKnU)DmbuPBWBy0co6BOcy)Vx6gmb5ISX9VJjG6ggnx3ZLJuqDg0GOFyVhN9oUrBFIHIoBGar)rGk6DIwObrBhzXt0(fjrZ(LOZgiq0dwI(H)Jk6DIwObrBkfEIwzIXAiGQguh9fJgrBPhuhuZn9MVPm5gZ8grvJo6mObrV6oyIe9dtI(gQwcCKBy0e4c(xcOIgH1HOTVG1nburFOzJlGsb1zqdI(H9EC274gT9jgk6Sbce9hbQO3jAHgeTDKfpr7xKen7xIoBGarpyj6h(pQO3jAHgeTPu4jALjgRHaQAqD0xmAeTLEqDqn30B(MYKBmZBevn6OZGge9Q7Gjs0pmj6B4rHUHrtGl4FjGkAewhI2(cw3eqf9HMnUakfuNbni6h27XzVJB02NyOOZgiq0FeOIENOfAq02rw8eTFrs0SFj6Sbce9GLOF4)OIENOfAq0MsHNOvMySgcOQb1rFXOr0w6b1b1CtV5BktUXmVru1OJodAq0RUdMir)WKOVHkSCdJMaxW)sav0iSoeT9fSUjGk6dnBCbukOodAq0pS3JZEh3OTpXqrNnqGO)iqf9orl0GOTJS4jA)IKOz)s0zdei6blr)W)rf9orl0GOnLcprRmXyneqvdQJ(IrJOT0dQdQ5g1DWeburNvJ2oYINO9lsqPG6cpYboLmVkNC7cVdb)wpu4Zr03mczi0oMS4j6Bc7(HG6Cenp4iGolqI(U2rF1TxDBqDqDoIMQqZgxarvdQZr0xm6BwPav03a7HZOfC0k4zFVeTDKfpr7xKKcQZr0xm6Bc0X0HOfJ4csDFPG6Ce9fJ(Mvkqfn3qeen3Oa6OO5c)f0QGOXVOrcyEHghPG6Ce9fJMQGh6arav0qUiBC)7ycOs3Grl4OvyjDdMGCr24(3XeqLcQdQZr0CRCHZxav0SWdtGOpyDwtIMfC3bLI(MphWrqrp45I0mI(77J2oYIhu04XNFkOohrBhzXdk5qGdwN1ekpVH4mOohrBhzXdk5qGdwN1egPCP9D1HrmzXtqDoI2oYIhuYHahSoRjms5YhgRcQZr08J5GOHLOj2QIM9)EGkAKyckAw4Hjq0hSoRjrZcU7GI2gv0oe4Ioyr2Xn6ffTcpqkOohrBhzXdk5qGdwN1egPCjAmhenSurIjOGA7ilEqjhcCW6SMWiLlnhhF(vh8IWtqTDKfpOKdboyDwtyKYL6gHtqvFysvbMqtBhcCW6SMurWbpkeLCQ9(OqSvvb6WijtPqPDy4EodQTJS4bLCiWbRZAcJuUejG5fAb12rw8Gsoe4G1znHrkx(rqDfqx7X0bkgvq0mIHQp8iv8R6GZgib12rw8Gsoe4G1znHrkx6GLfpb1b15iAUvUW5lGkAGoqYpAz1HOfAq02rWKOxu0gDB9gRhsb15i6BcqcyEHw07lAhmcTSEiAUgC00)(bigRhIggqFbu07e9bRZAchb12rw8GOW5E4u79rrlKaMxObQK59b12rw8GyKYLibmVqlO2oYIheJuUKUrwJ1dApMoqbgG4MFLaUWupyD2DaL20n)hOadqCZpraxyy0bVi8aQkRhafIQZQCd46kQg5aEFLMHeGJGA7ilEqms5s6gznwpO9y6af0oUEOkgXfeTPB(pqb5aEFvmIliO0ZMk(v5Cw6akVRcQTJS4bXiLlpM3xTJS4P6xKO9y6afKaMxObkT3hfKaMxObQeb7(HGA7ilEqms5YJ59v7ilEQ(fjApMoq5OqAVpkCPLyEyKKUHeGuneYqODsWySEqPrJcljxJqWcKK9W5oUCeuBhzXdIrkxEmVVAhzXt1Vir7X0bkkSeuBhzXdIrkxEmVVAhzXt1Vir7X0bkQLahjO2oYIheJuU0ihBGQGjeyeT3hfyaIB(jf82Zkmq5EozKUrwJ1djyaIB(vc4ct9G1z3bub12rw8GyKYLg5yduD(EeeuBhzXdIrkx6xxAcQMv8RC1HrcQTJS4bXiLlzn3k(vfYE4efuhuNJOPkySxHZEqb12rw8GshfIYhb1vaDThthOyubrZigQ(WJuXVQdoBGO9(OOfsaZl0avY8EM6gsas1qidH2PsaDBheLBzY1bJ9kC2tIomkqelraDBhuECZ56GXEfo7jHOT0teq32br1Wf8VooGkziA0TbqvIrfmPEWeZZbh5D)wgVFlvdxW)64aQKHOr3gavjgvWK6btmptTua7)9s0HrbIyPVdtTua7)9siAl903jO2oYIhu6Oqms5YJ59v7ilEQ(fjApMoqbqiyoas79rrlKaMxObQK59mvyjr(oYNajzpCUJltDdjaPAiKHq7ujGUTdIYTb15iAUXx0MsHI2iq0FhTJgnRdeTqdIgpq0zVcTO94SbKeDgzCJtrZnebrNnnyIwL)oUr)mKaKOfA2envjRhTcE7zLOXKOZEfA4VeTn5hnvjRNcQTJS4bLokeJuUu3iCcQ6dtQkWeAAFY)4HQyexqquUR9(OqSvvb6WijtPqPVdtUeJ4csswDOk4QAH8oyDwC1bVJGsk4TNvO67PCQrZbRZIRo4DeusbV9ScduoovDl3kYbgfhb15iAUXx0doAtPqrN969rRwi6SxH2orl0GOhixjAUFls7O)ii6SY3noA8enlgHIo7vOH)s02KF0uLSEkO2oYIhu6Oqms5sDJWjOQpmPQatOP9(OqSvvb6WijtPqPDyG73ErITQkqhgjzkfkP(etw8W8G1zXvh8ockPG3EwHbkhNQULBf5aJkOohrN1GrbIyr7XU7X8rFWJALfpMhfnRHav04j6ZNqGrIg5aNGA7ilEqPJcXiLlPBK1y9G2JPduOdJceXQOpRaK33fQh8OwzXJ20n)hOOLyEyKe6Zka59DHemgRhuA0OLrfGScKq0i4Vcuv0)9Whtw8KGXy9GsJgfwsUgHGfi5O)9Y64xGWWDMCHCaVVkgXfeu6ztf)QColDaL3fQrJwhm2RWzpj62SiAPVdhb12rw8GshfIrkxs3iRX6bThthOqhgfiIvN1LMGeZZjqQh8OwzXJ20n)hOOLyEyK0SU0eKyEobscgJ1dknA0smpmscYfzJ7FhtGemgRhuA0CWyVcN9KGCr24(3XeiraDBhuE58Ixr1I5HrskaCasfjetmxqpbJX6bvqTDKfpO0rHyKYL0nYASEq7X0bk0nYASEq7X0bk0HrbIy1hEK6bpQvw8OnDZ)bkAbxW)64aQKrfenJyO6dpsf)Qo4SbIgngvaYkqcrJG)kqvr)3dFmzXtcgJ1dknAua7)9seJkys9GjMVQa2)7Lu4ShnAoySxHZEsgIgDBauLyubtQhmX8jcOB7GY7(Tm56GXEfo7jHOT0teq32bL3DnAua7)9siAl903HJGA7ilEqPJcXiLlPdJceX0EFu0cjG5fAGkrWUFGPcljY3r(eij7HZDCzQLcy)VxIomkqel9Dys3iRX6HeDyuGiwf9zfG8(Uq9Gh1klEys3iRX6HeDyuGiwDwxAcsmpNaPEWJALfpmPBK1y9qIomkqeR(WJup4rTYING6CeDwZMfrl6SxHw0CRCrUrZy0zUU0eKyEobcvn6Ssl3v)RhnvjRhTnQO5w5ICJMaMk)OFys0dKRe9nIQCJdQTJS4bLokeJuUKUnlIM27JIyEyKeKlYg3)oMajymwpOykMhgjnRlnbjMNtGKGXy9GI5bRZIRo4DeeduoovDl3kYbgfZdg7v4SNeKlYg3)oMajcOB7GY7EqDoIoRzZIOfD2Rql6mxxAcsmpNajAgJotC0CRCrUu1OZkTCx9VE0uLSE02OIoRbJceXI(7enx)Xdiu0F0oUrN1WzDocQTJS4bLokeJuUKUnlIM27JIyEyK0SU0eKyEobscgJ1dkMAjMhgjb5ISX9VJjqcgJ1dkMhSolU6G3rqmq54u1TCRihyum5sbS)3lrhgfiIL(oA0aiemhirFrlEQ4x1bip4ilEsWySEqXrqDoIMhGOFFVp6dwxhgjA8ennrCqu1lV0DfAF20bRF5nz0HHg2RKlMbv5YBc7(HlZE5CV8MridH2XKfpx8MZ6CtU4nbiWihAPGA7ilEqPJcXiLlPBK1y9G2JPduqOkDBweT6bpQvw8OnDZ)bkgvaYkqcrJG)kqvr)3dFmzXtcgJ1dkMCn4PIqv2)7bQQyexqqmq5UgnihW7RIrCbbLE2uXVkNZshqu4ohm5cHQS)3duvXiUGGQglMouDSrb67HYTA0GCaVVkgXfeu6ztf)QColDaXaLlKJGA7ilEqPJcXiLlDWyFLai8NCaTFysDGCfk31gYviw10X)rOKLCguBhzXdkDuigPCjDBwenT3hfX8Wij0NvaY77cjymwpOyQfsaZl0avIGD)aZdg7v4SNKRriybsFhMCr3iRX6HecvPBZIOvp4rTYIhnA0YOcqwbsiAe8xbQk6)E4JjlEsWySEqXKlfwsUgHGfirGhbq0mwpOrJcy)VxIomkqel9DyQWsY1ieSajh9Vxwh)cK8OCNdoyEW6S4QdEhbLuWBpRWafU46oJxr1gvaYkqcrJG)kqvr)3dFmzXtcgJ1dkoOAKd49vXiUGGspBQ4xLZzPdioyGBEwysSvvb6WijtPqPDy4(vb15i6SMnlIw0zVcTOZknKaKOVzeYq7qvJotC0ibmVqlABurp4OTJS0HOZkV5Oz)VN2rFtFh5tGOhSe9ortGhbq0IMyJlOD0Qpzh3OZAWOarmgZ4AgVglCRO56pEaHI(J2Xn6SgoRZrqTDKfpO0rHyKYL0Tzr00EFueZdJK0nKaKQHqgcTtcgJ1dkMAHeW8cnqLmVNPUHeGuneYqODQeq32bLhLBzQLcljY3r(eirGhbq0mwpWuHLKRriybseq32bXa3zYLcy)VxIomkqel9DyQa2)7Lq0w6PVdhm5slaHG5ajwpgRQ4xvObvya98t6wwrmrJgfW(FVeRhJvv8Rk0GkmGE(PVdhA0aiemhirFrlEQ4x1bip4ilEsWySEqXrqDoIMNMPWzRdEv0pmjAEAe8xbQO5)Vh(yYINGA7ilEqPJcXiLlr0mfoBDWR0EFu0cjG5fAGkzEptJkazfiHOrWFfOQO)7HpMS4jbJX6bftfwsUgHGfirGhbq0mwpWuHLKRriybso6FVSo(fi5r5oZdwNfxDW7iOKcE7zfgOCpOohrZTYfzJ7FhtGOZMgmrpyjAKaMxObQOTrfnlwOf9n9DKpbI2gv03iJqWceTrGO)or)WKO94XnAyWFxAPGA7ilEqPJcXiLlHCr24(3Xeq79rrlKaMxObQeb7(bMCPLcljxJqWcKiWJaiAgRhyQWsI8DKpbseq32bXqwymlu9XPQB5wroWO0OrHLe57iFcKiGUTdIQVnLtgeJ4csswDOk4QAboykgXfKKS6qvWv1cmKLGA7ilEqPJcXiLlr0w6AVpkkSKiFh5tGKSho3XLjxAbxW)64aQKrfenJyO6dpsf)Qo4SbIgnhm2RWzpj6WOarSeb0TDqmC)wocQTJS4bLokeJuU0bllE0EFuy)VxI1JXk)hjjcyhrJgfW(FVeDyuGiw67euBhzXdkDuigPCjRhJv13NKV27JIcy)VxIomkqel9DcQTJS4bLokeJuUKfiiGW5oUAVpkkG9)Ej6WOarS03jO2oYIhu6Oqms5Y3sawpgR0EFuua7)9s0HrbIyPVtqTDKfpO0rHyKYL2CaKqmF9yEV27JIcy)VxIomkqel9DcQTJS4bLokeJuU8JG6kGU2JPduCnpCmVhiOklgpAVpkCPa2)7LOdJceXsFhnA4slX8WijixKnU)DmbsWySEqX8GXEfo7jrhgfiILiGUTdIHSKtnAeZdJKGCr24(3XeibJX6bftUoySxHZEsqUiBC)7ycKiGUTdkVluJMdg7v4SNeKlYg3)oMajcOB7Gy4QBz(wxAsLa62oigUWCYbhCWulfwsKVJ8jqcYfzJ7FhtavqTDKfpO0rHyKYLFeuxb01EmDGIHOr3gavjgvWK6btmV27JIcy)VxIyubtQhmX8vfW(FVKcN9OrZBDPjvcOB7GY7QBdQTJS4bLokeJuU8JG6kGU2JPdumen62aOkXOcMupyI51EFu4slX8WijixKnU)DmbsWySEqPrJwI5HrsOpRaK33fsWySEqXbtfW(FVeDyuGiwIa62oigUF7fZcvdxW)64aQKrfenJyO6dpsf)Qo4SbsqTDKfpO0rHyKYLFeuxb01EmDGIHOr3gavjgvWK6btmV27JcxI5HrsqUiBC)7ycKGXy9GIPyEyKe6Zka59DHemgRhuCWubS)3lrhgfiIL(om5sHLKRriybsqUiBC)7ycO0OXOcqwbsiAe8xbQk6)E4JjlEsWySEqXuHLKRriybso6FVSo(fimCNJGA7ilEqPJcXiLl)iOUcORn8EWrQJPduo5F8yHGN9uz9gs0EFu0nKaKQHqgcTtLa62oik3YulfW(FVeDyuGiw67WulfW(FVeI2sp9DyY(FVKoOJj5xXVQ)FwvvrathLu4ShMWae38Z7cCltfwsKVJ8jqIa62oigYsqTDKfpO0rHyKYLFeuxb01EmDGI)t4eiO6oOvT4pQ6Upr79rrbS)3lrhgfiIL(ob12rw8GshfIrkx(rqDfqx7X0bk(psi4pQ6I9kyQo(VU5cAVpkkG9)Ej6WOarS03jO2oYIhu6Oqms5YpcQRa6AdVhCK6y6afxVPwtWeuvhuM3V4r79rrbS)3lrhgfiIL(ob12rw8GshfIrkx(rqDfqxB49GJuhthO46n1AcMGQSMYf0EFuua7)9s0HrbIyPVtqDoI(gdp77LOFM3ZAhoJ(Hjr)rgRhIEfqhrvJMBicIgprFWyVcN9KcQTJS4bLokeJuU8JG6kGokOoOohrFJxcCKOvMU5crBSRFLfqb15iAU1qhgSE0MeDwymAUYjJrN9k0I(gZZr0uLSEkAUrDDqTMa(8JgprFfJrlgXfeK2rN9k0IoRbJceX0oAmj6SxHw0zCn3SrJfAaj7fbrNTTs0pmjAewhIggG4MFkO2oYIhusTe4iuGHomyDT3hLdwNfxDW7iigOKfgfZdJKua4aKksiMyUGEcgJ1dkMCPa2)7LOdJceXsFhnAua7)9siAl903rJgyaIB(jf82Zk5r5QCYiDJSgRhsWae38ReWfM6bRZUdO0Orl6gznwpKq746HQyexq4GjxAjMhgjb5ISX9VJjqcgJ1dknA0sbS)3lrhgfiIL(oA0CWyVcN9KGCr24(3XeiraDBhedxXrqTDKfpOKAjWryKYL0nYASEq7X0bkFeuFR3deTPB(pq5G1zXvh8ockPG3EwHH7A0adqCZpPG3EwjpkxLtgPBK1y9qcgG4MFLaUWupyD2DaLgnAr3iRX6HeAhxpufJ4csqDoIMB6k0IMBDOH3Xn6R9McqAhDwbBIg)I(gyw6akAtI(kgJwmIliiTJgtIM7xmlmgTyexqqrNnnyIoRbJceXIErr)DcQTJS4bLulbocJuU8ztf)QColDaP9(Oq3iRX6H0hb1369aHPrfGScKGdn8oUvwVPaucgJ1dkMihW7RIrCbbLE2uXVkNZshqmq5kg5sbS)3lrhgfiIL(ounx3zKlJkazfibhA4DCRSEtbOeXgoPCNdo4iOohrNvWMOXVOVbMLoGI2KOVZTzmAKyhorrJFrZnZQuWe91EtbOOXKOnxBhKeDwymAUYjJrN9k0I(gJ)SEi6BmgbCeTyexqqPGA7ilEqj1sGJWiLlF2uXVkNZshqAVpk0nYASEi9rq9TEpqyYf7)9s0wLcMkR3uakHe7WjduUZT1OHlTCilMSs(vcwmzXdtKd49vXiUGGspBQ4xLZzPdigOKfg5YOcqwbsk8N1dvfgbjInCYWvCWisaZl0avIGD)ahCeuNJOZkyt04x03aZshqrl4OnhhF(rFJbt5Zp6SoEr4j69f9o2rw6q04jABYpAXiUGeTjrZ9OfJ4cckfuBhzXdkPwcCegPC5ZMk(v5Cw6as7t(hpufJ4ccIYDT3hf6gznwpK(iO(wVhimroG3xfJ4cck9SPIFvoNLoGyGc3dQTJS4bLulbocJuUK1VJcTkq79rHUrwJ1dPpcQV17bctUy)VxI1VJcTki9D0OrlX8Wij6WG1RKpIwcgJ1dkMAzubiRajf(Z6HQcJGemgRhuCeuNJOZWyVyw5xwVjq0coAZXXNF03yWu(8JoRJxeEI2KOVkAXiUGGcQTJS4bLulbocJuUu)lR3eq7t(hpufJ4ccIYDT3hf6gznwpK(iO(wVhimroG3xfJ4cck9SPIFvoNLoGOCvqTDKfpOKAjWryKYL6Fz9MaAVpk0nYASEi9rq9TEpqcQdQZr03yt3CHOX0bs0YQdrBSRFLfqb15iAUjR(krFJmcblakA8e9GNl6qwDIrYpAXiUGGI(Hjrl0GODilMSs(rtWIjlEIEFrNtgJM1dGcfTrGOnpbmv(r)DcQTJS4bLuyHcDJSgRh0EmDGcIZ1PEY)4HQRriyb0MU5)afhYIjRKFLGftw8We5aEFvmIliO0ZMk(v5Cw6aIbUZKlfwsUgHGfiraDBhuEhm2RWzpjxJqWcKuFIjlE0OXbVi8aQkRhafIHCYrqDoIMBYQVs0303r(eafnEIEWZfDiRoXi5hTyexqqr)WKOfAq0oKftwj)OjyXKfprVVOZjJrZ6bqHI2iq0MNaMk)O)ob12rw8GskSWiLlPBK1y9G2JPduqCUo1t(hpujFh5taTPB(pqXHSyYk5xjyXKfpmroG3xfJ4cck9SPIFvoNLoGyG7m5sbS)3lHOT0tFhnA4YbVi8aQkRhafIHCYulJkazfiHoWiv8RY6XyvcgJ1dko4iOohrZnz1xj6B67iFcGIEFrN1GrbIymMbo39e91EtbxMvAibirFZiKHq7e9II(7eTnQOZgIMMrhI(kgJgbh8Oqr7HNenEIwObrFtFh5tGOVX4mcQTJS4bLuyHrkxs3iRX6bThthOG4CDQKVJ8jG20n)hOOa2)7LOdJceXsFhMCPa2)7Lq0w6PVJgn6gsas1qidH2PsaDBhed3YbtfwsKVJ8jqIa62oigUkOohrZ7aN18rFJmcblq02OI(M(oYNarJa57eTdzXKOfC0CRCr24(3Xei6JHKGA7ilEqjfwyKYLUgHGfq79rrmpmscYfzJ7FhtGemgRhum1cYfzJ7FhtaftfwsUgHGfi5O)9Y64xGKhL7mpySxHZEsqUiBC)7ycKiGUTdkVRyICaVVkgXfeu6ztf)QColDar5otITQkqhgjzkfkTddxitfwsUgHGfiraDBhevFBkN5jgXfKKS6qvWv1cb12rw8GskSWiLljFh5taT3hfX8WijixKnU)DmbsWySEqXulfwsUgHGfirGhbq0mwpWKRdwNfxDW7iigOCCQ6wUvKdmkMhm2RWzpjixKnU)Dmbseq32bL3DMkSKiFh5tGeb0TDqu9TPCMNyexqsYQdvbxvlWrqDoI(gzecwGO)oCcGJ2rBEeoAHSakAbh9hbrVs0gkAlAKdCwZhTlmaXemj6hMeTqdI2BijAQswpAw4Hjq0w0VDwenGeuBhzXdkPWcJuU0bJ9vcGWFYb0(Hj1bYvOCpO2oYIhusHfgPCPRriyb0EFuiWJaiAgRhyEW6S4QdEhbLuWBpRWaL7mYDQMlJkazfiHOrWFfOQO)7HpMS4jbJX6bfZdg7v4SNeDBweT03HdMC5O)9Y64xGKhL7A0qaDBhuEuK9WzvwDGjYb8(QyexqqPNnv8RY5S0bedu4oJgvaYkqcrJG)kqvr)3dFmzXtcgJ1dkoyYLwqUiBC)7ycO0OHa62oO8Oi7HZQS6avFftKd49vXiUGGspBQ4xLZzPdigOWDgnQaKvGeIgb)vGQI(Vh(yYINemgRhuCWuleQY(FpqXKlXiUGKKvhQcUQw4Ieq32bXbdzHjx6gsas1qidH2PsaDBheLB1OrlzpCUJltJkazfiHOrWFfOQO)7HpMS4jbJX6bfhb12rw8GskSWiLlDWyFLai8NCaTFysDGCfk3dQTJS4bLuyHrkx6AecwaTp5F8qvmIliik31EFu0IUrwJ1djeNRt9K)XdvxJqWcWKapcGOzSEG5bRZIRo4DeusbV9ScduUZi3PAUmQaKvGeIgb)vGQI(Vh(yYINemgRhumpySxHZEs0Tzr0sFhoyYLJ(3lRJFbsEuURrdb0TDq5rr2dNvz1bMihW7RIrCbbLE2uXVkNZshqmqH7mAubiRajenc(Ravf9Fp8XKfpjymwpO4GjxAb5ISX9VJjGsJgcOB7GYJIShoRYQdu9vmroG3xfJ4cck9SPIFvoNLoGyGc3z0OcqwbsiAe8xbQk6)E4JjlEsWySEqXbtTqOk7)9aftUeJ4csswDOk4QAHlsaDBhehmC)kMCPBibivdHmeANkb0TDquUvJgTK9W5oUmnQaKvGeIgb)vGQI(Vh(yYINemgRhuCeuNJOPkKvhHNOZa0DaKenEIw)7L1XdrlgXfeu0MeDwymAQswp6SPbt0K)m74gn(lrVt0xDrUJIMlwdbQOXt0IrCbj6d(pchrJNOTj)OfJ4csqTDKfpOKclms5Ydz1r4PkGUdGeTp5F8qvmIliik31EFuqoG3xfJ4ccIbUZKa62oO8UIrUqoG3xfJ4ccIbk5KdMhSolU6G3rqmqjlb15i6BaaCI(7e9n9DKpbI2KOZcJrJNOnVpAXiUGGIMRSPbt0(L(oUr7XJB0WG)U0I2gv0dwIgnMdIgw4iO2oYIhusHfgPCj57iFcO9(OOfDJSgRhsioxNk57iFcWKRdwNfxDW7iigOKfMe4raenJ1dA0OLSho3XLjxYQdmC)wnAoyDwC1bVJGyGYvCWbtUC0)EzD8lqYJYDnAiGUTdkpkYE4SkRoWe5aEFvmIliO0ZMk(v5Cw6aIbkCNrJkazfiHOrWFfOQO)7HpMS4jbJX6bfhm5slixKnU)DmbuA0qaDBhuEuK9WzvwDGQVIjYb8(QyexqqPNnv8RY5S0bedu4oJgvaYkqcrJG)kqvr)3dFmzXtcgJ1dkoykgXfKKS6qvWv1cxKa62oigYsqTDKfpOKclms5sY3r(eq7t(hpufJ4ccIYDT3hfTOBK1y9qcX56up5F8qL8DKpbyQfDJSgRhsioxNk57iFcW8G1zXvh8ocIbkzHjbEearZy9atUC0)EzD8lqYJYDnAiGUTdkpkYE4SkRoWe5aEFvmIliO0ZMk(v5Cw6aIbkCNrJkazfiHOrWFfOQO)7HpMS4jbJX6bfhm5slixKnU)DmbuA0qaDBhuEuK9WzvwDGQVIjYb8(QyexqqPNnv8RY5S0bedu4oJgvaYkqcrJG)kqvr)3dFmzXtcgJ1dkoykgXfKKS6qvWv1cxKa62oigYcJC5GxeEavL1dGcXWvCq1xyqDoIMQqwDeEIodq3bqs04j67xK7rR)9Y64HOfJ4cckAtIolmgnvjRhD20GjAYFMDCJg)LO3j6RqrJNOTj)OfJ4csqTDKfpOKclms5Ydz1r4PkGUdGeTp5F8qvmIliik31EFuqoG3xfJ4ccIH7mroG3xfJ4cckVSWKa62oO8UI5bRZIRo4DeeduYsqDoIMQqwDeEIodq3bqs04jA(mIEFrVt0o2Oa99eTnQOxj6SxVpAfoApGqrRmDZfIwOzt0CRHomy9OvFiAbhDgxFzw5nFzgYnqqTDKfpOKclms5Ydz1r4PkGUdGeT3hfKd49vXiUGGOCN5bRZIRo4Deedu464u1TCRihyux8ohmjWJaiAgRhyQfKlYg3)oMakMAPa2)7Lq0w6PVdtDdjaPAiKHq7ujGUTdIYTm1YOcqwbss2lsQcnOY5SpibJX6bftXiUGKKvhQcUQw4Ieq32bXqwcQZr0ufdjrtviRocprNbO7aijA8e9nJ5wrVdsatfn(fn3AOddwpAtIoRYy0IrCbbfD20Gj6Sgmkqe7YmUo6ff9GLO)ob12rw8GskSWiLlpKvhHNQa6oas0EFuqoG3xfJ4ccIbUYQxK9)EjyOddwp9D4G5bRZIRo4DeeduYcJI5HrskaCasfjetmxqpbJX6bftTua7)9s0HrbIyPVdtTua7)9siAl903HPwgvaYkqsYErsvObvoN9bjymwpOycdqCZpPG3EwjpkxLtgPBK1y9qcgG4MFLaUWupyD2DavqDqDoIMBHqWCauqTDKfpOeGqWCaeLdEoWietav95nDq79rbgG4MFswDOk4QULld3zQLcy)VxIomkqel9DyYLwkSKo45aJqmbu1N30Hk7NmjzpCUJltTSJS4jDWZbgHycOQpVPdPDQp)6st0O599(kbo0mIluLvhYZ9Os6wUCeuNJOVzF2w(OO)ii6R9ySk6SxHw0znyuGiw0FNu0CZG9QOFys0CRCr24(3Xeifn3qeeD2Rql6mUo6Vt0SWdtGOTOF7SiAajAdfThpUrBOOxjAYFqr)WKOVFlkA1NSJB0znyuGiwkO2oYIhucqiyoaIrkxY6Xyvf)QcnOcdONV27JIcy)VxIomkqel9DyYfKlYg3)oMaQKRriyb0OrbS)3lHOT0tFhMhSolU6G3rqjf82Zk5r5UgnkG9)Ej6WOarSeb0TDq5r5(TCOrZBDPjvcOB7GYJY9BdQZr03SiGUJeTGJ28R7e9n6Be1At0zVcTOZAWOarSOnu0E84gTHIELOZgp3qjAcG(Ej6DI2Jr74gTf9779xKU5)q0hdjrJPdKOfAq0eq32zh3OvFIjlEIg)IwObr)wxAsqTDKfpOeGqWCaeJuU09Be1Atf)QgvacwOP9(OCWyVcN9KOdJceXseq32bLh31OrbS)3lrhgfiIL(oA08wxAsLa62oO84(Tb12rw8GsacbZbqms5s3VruRnv8RAubiyHM27JYZJXeU46TU0Kkb0TDqxK73Yb3Gdg7v4Shoy45XycxC9wxAsLa62oOlY9BV4bJ9kC2tIomkqelraDBhehCdoySxHZE4iO2oYIhucqiyoaIrkx(WNpcuvJkazfOYcMU27JcYb8(QyexqqPNnv8RY5S0beduUsJgITQkqhgjzkfkTddx4TmHbiU5Nxw9wnAERlnPsaDBhuE3VnO2oYIhucqiyoaIrkx68j7l)DCRSEdjAVpkihW7RIrCbbLE2uXVkNZshqmq5knAi2QQaDyKKPuO0omCH3QrZBDPjvcOB7GY7(Tb12rw8GsacbZbqms5sHgu)dl(pQ6dtoG27Jc7)9se4WPhqO6dtoq67Ord7)9se4WPhqO6dtoq9G)JaKesSdN5D)2GA7ilEqjaHG5aigPCjzDC8qDNkYXoqqTDKfpOeGqWCaeJuUmBmXROd7ujacp2CGGA7ilEqjaHG5aigPCPoOJj5xXVQ)FwvvrathP9(OadqCZpVCEltToySxHZEs0HrbIyPVtqDoIMBgSxf9nbMZoUrNvWB6ak6hMenKlC(cenXgxiAmjAoxVpA2)7H0o69fTdgHwwpKI(M9zB5JIwi5hTGJ2fKOfAq0EC2asI(GXEfo7jAwdbQOXt0gDB9gRhIggqFbukO2oYIhucqiyoaIrkxsaZzh36ZB6as7t(hpufJ4ccIYDT3hfXiUGKKvhQcUQwiV7PCQrdxCjgXfKenW8cTKZry4cCRgnIrCbjrdmVql5CK8OC1TCWKl7ilDOcdOVaIYDnAeJ4csswDOk4QAbgUIBZbhA0WLyexqsYQdvbxDos9QBzG73YKl7ilDOcdOVaIYDnAeJ4csswDOk4QAbgYsw4GJG6G6CenVaMxObQOV5JS4bfuNJOZCDPHeZZjqIgprFpdQA08J5GOHLOVPVJ8jqqTDKfpOesaZl0affY3r(eq79rrmpmsAwxAcsmpNajbJX6bfZdwNfxDW7iigOKfMIrCbjjRoufCvTWfjGUTdIHlmOohrZ)zfG8(Uq0mgnpnc(Rav08)3dFmzXdvnAU1G(ei6SHO)iiA8ar76XSMpAbhT544Zp6BKriybIwWrl0GO1TDIwmIlirVVOxj6ff9GLOrJ5GOHLOZheTJgHJ28(OXcnGeTUTt0IrCbjAJD9RSakAhc(TskO2oYIhucjG5fAGIrkx6GX(kbq4p5aA)WK6a5kuUhuBhzXdkHeW8cnqXiLlDncblG27JIrfGScKq0i4Vcuv0)9Whtw8KGXy9GIj7)9sOpRaK33fsFhMS)3lH(ScqEFxiraDBhuE3tCNPwiuL9)EGkOohrZ)zfG8(Uavn6B2XXNF0ys03e8iaIw0zVcTOz)VhOI(gzecwauqTDKfpOesaZl0afJuU0bJ9vcGWFYb0(Hj1bYvOCpO2oYIhucjG5fAGIrkx6AecwaTp5F8qvmIliik31EFueZdJKqFwbiVVlKGXy9GIjxeq32bL39R0OXr)7L1XVajpk35GPyexqsYQdvbxvlCrcOB7Gy4QG6Cen)NvaY77crZy080i4VcurZ)Fp8XKfprVt08zqvJ(MDC85hnyeF(rFtFh5tGOfAMeD2R3hnlenbEeardur)WKODSrb67jO2oYIhucjG5fAGIrkxs(oYNaAVpkI5HrsOpRaK33fsWySEqX0OcqwbsiAe8xbQk6)E4JjlEsWySEqXulfwsKVJ8jqs2dN74YKUrwJ1dj0oUEOkgXfKG6Cen)NvaY77crN9LrZtJG)kqfn))9Whtw8qvJ(MaZXXNF0pmjAw88rrtvY6rBJ6smjAixbgfOIgnMdIgwIw9jMS4jfuBhzXdkHeW8cnqXiLlDWyFLai8NCaTFysDGCfk3dQTJS4bLqcyEHgOyKYLUgHGfq7t(hpufJ4ccIYDT3hfX8Wij0NvaY77cjymwpOyAubiRajenc(Ravf9Fp8XKfpjymwpOyYLDKLouHb0xaXWDnA0smpmscYfzJ7FhtGemgRhuCWumIlijz1HQGRQfyGa62oiMCraDBhuE3VaA0Ofcvz)VhO4iOohrZ)zfG8(Uq0mgn3kxKB04j67zqvJ(MGhbq0I(gzecwGOnjAHgenmQOXVOrcyEHw0coAxqIw3YnA1NyYINOzHhMarZTYfzJ7FhtGGA7ilEqjKaMxObkgPCPdg7ReaH)KdO9dtQdKRq5EqTDKfpOesaZl0afJuU01ieSaAVpkI5HrsOpRaK33fsWySEqXumpmscYfzJ7FhtGemgRhumTJS0HkmG(cik3zY(FVe6Zka59DHeb0TDq5DpX9IuKsb]] )

end