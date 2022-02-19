-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] controlled_destruction
-- [-] flame_accretion -- adds to "fireball" buff
-- [-] master_flame
-- [x] infernal_cascade


if UnitClassBase( "player" ) == "MAGE" then
    local spec = Hekili:NewSpecialization( 63, true )

    -- spec:RegisterResource( Enum.PowerType.ArcaneCharges )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        firestarter = 22456, -- 205026
        pyromaniac = 22459, -- 205020
        searing_touch = 22462, -- 269644

        blazing_soul = 23071, -- 235365
        shimmer = 22443, -- 212653
        blast_wave = 23074, -- 157981

        incanters_flow = 22444, -- 1463
        focus_magic = 22445, -- 321358
        rune_of_power = 22447, -- 116011

        flame_on = 22450, -- 205029
        alexstraszas_fury = 22465, -- 235870
        from_the_ashes = 22468, -- 342344

        frenetic_speed = 22904, -- 236058
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        flame_patch = 22451, -- 205037
        conflagration = 23362, -- 205023
        living_bomb = 22472, -- 44457

        kindling = 21631, -- 155148
        pyroclasm = 22220, -- 269650
        meteor = 21633, -- 153561
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        controlled_burn = 645, -- 280450
        flamecannon = 647, -- 203284
        greater_pyroblast = 648, -- 203286
        netherwind_armor = 53, -- 198062
        prismatic_cloak = 828, -- 198064
        pyrokinesis = 646, -- 203283
        ring_of_fire = 5389, -- 353082
        tinder = 643, -- 203275
        world_in_flames = 644, -- 203280
    } )

    -- Auras
    spec:RegisterAuras( {
        alexstraszas_fury = {
            id = 334277,
            duration = 15,
            max_stack = 1,
        },
        alter_time = {
            id = 110909,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        blast_wave = {
            id = 157981,
            duration = 6,
            max_stack = 1,
        },
        blazing_barrier = {
            id = 235313,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        blink = {
            id = 1953,
        },
        cauterize = {
            id = 86949,
        },
        chilled = {
            id = 205708,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        combustion = {
            id = 190319,
            duration = function () return ( level > 55 and 12 or 10) + ( set_bonus.tier28_2pc > 0 and 2 or 0 ) end,
            type = "Magic",
            max_stack = 1,
        },
        conflagration = {
            id = 226757,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        critical_mass = {
            id = 117216,
        },
        dragons_breath = {
            id = 31661,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        fireball = {
            id = 157644,
            duration = 15,
            type = "Magic",
            max_stack = 10,
        },
        flamestrike = {
            id = 2120,
            duration = 8,
            max_stack = 1,
        },
        frenetic_speed = {
            id = 236060,
            duration = 3,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        frostbolt = {
            id = 59638,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        heating_up = {
            id = 48107,
            duration = 10,
            max_stack = 1,
        },
        hot_streak = {
            id = 48108,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        ignite = {
            id = 12654,
            duration = 9,
            type = "Magic",
            max_stack = 1,
            meta = {
                tick_dmg = function( t )
                    return t.v1
                end,
            }
        },
        incanters_flow = {
            id = 116267,
            duration = 3600,
            max_stack = 5,
        },
        preinvisibility = {
            id = 66,
            duration = 3,
            max_stack = 1,
        },
        invisibility = {
            id = 32612,
            duration = 20,
            max_stack = 1
        },
        living_bomb = {
            id = 217694,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        living_bomb_spread = {
            id = 244813,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        meteor_burn = {
            id = 155158,
            duration = 3600,
            max_stack = 1,
        },
        mirror_image = {
            id = 55342,
            duration = 40,
            max_stack = 3,
            generate = function ()
                local mi = buff.mirror_image

                if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                    mi.count = 1
                    mi.applied = action.mirror_image.lastCast
                    mi.expires = mi.applied + 40
                    mi.caster = "player"
                    return
                end

                mi.count = 0
                mi.applied = 0
                mi.expires = 0
                mi.caster = "nobody"
            end,
        },
        pyroblast = {
            id = 321712,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        pyroclasm = {
            id = 269651,
            duration = 15,
            max_stack = 2,
        },
        ring_of_frost = {
            id = 321329,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        rune_of_power = {
            id = 116014,
            duration = 12,
            max_stack = 1,
        },
        shimmer = {
            id = 212653,
        },
        slow_fall = {
            id = 130,
            duration = 30,
            max_stack = 1,
        },
        temporal_displacement = {
            id = 80354,
            duration = 600,
            max_stack = 1,
        },

        -- Azerite Powers
        blaster_master = {
            id = 274598,
            duration = 3,
            max_stack = 3,
        },

        wildfire = {
            id = 288800,
            duration = 10,
            max_stack = 1,
        },


        -- Legendaries
        fevered_incantation = {
            id = 333049,
            duration = 6,
            max_stack = 5
        },
    
        firestorm = {
            id = 333100,
            duration = 4,
            max_stack = 1
        },

        molten_skyfall = {
            id = 333170,
            duration = 30,
            max_stack = 18
        },

        molten_skyfall_ready = {
            id = 333182,
            duration = 30,
            max_stack = 1
        },
        
        sun_kings_blessing = {
            id = 333314,
            duration = 30,
            max_stack = 8
        },

        sun_kings_blessing_ready = {
            id = 333315,
            duration = 15,
            max_stack = 1
        },

    } )


    spec:RegisterStateTable( "firestarter", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.firestarter.enabled and target.health.pct > 90
            elseif k == "remains" then
                if not talent.firestarter.enabled or target.health.pct <= 90 then return 0 end
                return target.time_to_pct_90
            end
        end, state )
    } ) )

    spec:RegisterStateTable( "searing_touch", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.searing_touch.enabled and target.health.pct < 30
            elseif k == "remains" then
                if not talent.searing_touch.enabled or target.health.pct < 30 then return 0 end
                return target.time_to_die
            end
        end, state )
    } ) )

    spec:RegisterTotem( "rune_of_power", 609815 )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364476, "tier28_4pc", 363500 )
    -- 2-Set - Fiery Rush - Increases the duration of Combustion by 2 sec.
    -- 4-Set - Fiery Rush - While Combustion is active your Fire Blast and Phoenix Flames recharge 50% faster.


    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        incanters_flow.reset()
    end )

    spec:RegisterHook( "advance", function ( time )
        if Hekili.ActiveDebug then Hekili:Debug( "\n*** Hot Streak (Advance) ***\n    Heating Up:  %.2f\n    Hot Streak:  %.2f\n", state.buff.heating_up.remains, state.buff.hot_streak.remains ) end
    end )

    spec:RegisterStateFunction( "hot_streak", function( willCrit )
        willCrit = willCrit or buff.combustion.up or stat.crit >= 100

        if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK (Cast/Impact) ***\n    Heating Up: %s, %.2f\n    Hot Streak: %s, %.2f\n    Crit: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains, willCrit and "Yes" or "No", stat.crit ) end

        if willCrit then
            if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
            elseif buff.hot_streak.down then applyBuff( "heating_up" ) end
            
            if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK END ***\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
            return true
        end
        
        -- Apparently it's safe to not crit within 0.2 seconds.
        if buff.heating_up.up then
            if query_time - buff.heating_up.applied > 0.2 then
                if Hekili.ActiveDebug then Hekili:Debug( "May not crit; Heating Up was applied %.2f ago, so removing Heating Up..", query_time - buff.heating_up.applied ) end
                removeBuff( "heating_up" )
            else
                if Hekili.ActiveDebug then Hekili:Debug( "May not crit; Heating Up was applied %.2f ago, so ignoring the non-crit impact.", query_time - buff.heating_up.applied ) end
            end
        end

        if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK END ***\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f\n***", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
    end )


    local hot_streak_spells = {
        -- "dragons_breath",
        "fireball",
        -- "fire_blast",
        "phoenix_flames",
        "pyroblast",
        -- "scorch",        
    }
    spec:RegisterStateExpr( "hot_streak_spells_in_flight", function ()
        local count = 0

        for i, spell in ipairs( hot_streak_spells ) do
            if state:IsInFlight( spell ) then count = count + 1 end
        end

        return count
    end )

    spec:RegisterStateExpr( "expected_kindling_reduction", function ()
        -- This only really works well in combat; we'll use the old APL value instead of dynamically updating for now.
        return 0.4
    end )


    Hekili:EmbedDisciplinaryCommand( spec )


    -- # APL Variable Option: This variable specifies whether Combustion should be used during Firestarter.
    -- actions.precombat+=/variable,name=firestarter_combustion,op=set,if=!talent.pyroclasm,value=1,value_else=0
    spec:RegisterVariable( "firestarter_combustion", function ()
        if not talent.pyroclasm.enabled then return 1 end
        return -1
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes outside of Combustion should be used.
    -- actions.precombat+=/variable,name=hot_streak_flamestrike,op=set,if=talent.flame_patch,value=2,value_else=4
    spec:RegisterVariable( "hot_streak_flamestrike", function ()
        if talent.flame_patch.enabled then return 2 end
        return 4
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Hard Cast Flamestrikes outside of Combustion should be used as filler.
    -- actions.precombat+=/variable,name=hard_cast_flamestrike,op=set,if=talent.flame_patch,value=3,value_else=6
    spec:RegisterVariable( "hard_cast_flamestrike", function ()
        if talent.flame_patch.enabled then return 3 end
        return 6
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes are used during Combustion.
    -- actions.precombat+=/variable,name=combustion_flamestrike,op=set,if=talent.flame_patch,value=3,value_else=6
    spec:RegisterVariable( "combustion_flamestrike", function ()
        if talent.flame_patch.enabled then return 3 end
        return 6
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Arcane Explosion outside of Combustion should be used.
    -- actions.precombat+=/variable,name=arcane_explosion,op=set,if=talent.flame_patch,value=99,value_else=2
    spec:RegisterVariable( "arcane_explosion", function ()
        if talent.flame_patch.enabled then return 99 end
        return 2
    end )

    -- # APL Variable Option: This variable specifies the percentage of mana below which Arcane Explosion will not be used.
    -- actions.precombat+=/variable,name=arcane_explosion_mana,default=40,op=reset
    spec:RegisterVariable( "arcane_explosion_mana", function ()
        return 40
    end )

    -- # APL Variable Option: The number of targets at which Shifting Power can used during Combustion.
    -- actions.precombat+=/variable,name=combustion_shifting_power,if=variable.combustion_shifting_power=0,value=1*talent.pyroclasm*runeforge.sun_kings_blessing+3*(!runeforge.sun_kings_blessing|!talent.pyroclasm)
    spec:RegisterVariable( "combustion_shifting_power", function ()
        if talent.flame_patch.enabled then return 3 end
        return 6
    end )

    -- # APL Variable Option: The time remaining on a cast when Combustion can be used in seconds.
    -- actions.precombat+=/variable,name=combustion_cast_remains,default=0.7,op=reset
    spec:RegisterVariable( "combustion_cast_remains", function ()
        return 0.7
    end )

    -- # APL Variable Option: This variable specifies the number of seconds of Fire Blast that should be pooled past the default amount.
    -- actions.precombat+=/variable,name=overpool_fire_blasts,default=0,op=reset
    spec:RegisterVariable( "overpool_fire_blasts", function ()
        return 0
    end )

    -- # APL Variable Option: How long before Combustion should Empyreal Ordnance be used?
    -- actions.precombat+=/variable,name=empyreal_ordnance_delay,default=18,op=reset
    spec:RegisterVariable( "empyreal_ordnance_delay", function ()
        return 18 
    end )

    -- # The duration of a Sun King's Blessing Combustion.
    -- actions.precombat+=/variable,name=skb_duration,op=set,value=5
    spec:RegisterVariable( "skb_duration", function ()
        return 5
    end )

    -- # The number of seconds of Fire Blast recharged by Mirrors of Torment
    -- actions.precombat+=/variable,name=mot_recharge_amount,value=dbc.effect.871274.base_value
    spec:RegisterVariable( "mot_recharge_amount", function ()
        return 6
    end )


    -- # Whether a usable item used to buff Combustion is equipped.
    -- actions.precombat+=/variable,name=combustion_on_use,value=equipped.gladiators_badge|equipped.macabre_sheet_music|equipped.inscrutable_quantum_device|equipped.sunblood_amethyst|equipped.empyreal_ordnance|equipped.flame_of_battle|equipped.wakeners_frond|equipped.instructors_divine_bell|equipped.shadowed_orb_of_torment
    spec:RegisterVariable( "combustion_on_use", function ()
        return equipped.gladiators_badge or equipped.macabre_sheet_music or equipped.inscrutable_quantum_device or equipped.sunblood_amethyst or equipped.empyreal_ordnance or equipped.flame_of_battle or equipped.wakeners_frond or equipped.instructors_divine_bell or equipped.shadowed_orb_of_torment
    end )

    -- # How long before Combustion should trinkets that trigger a shared category cooldown on other trinkets not be used?
    -- actions.precombat+=/variable,name=on_use_cutoff,op=set,value=20,if=variable.combustion_on_use
    -- actions.precombat+=/variable,name=on_use_cutoff,op=set,value=25,if=equipped.macabre_sheet_music
    -- actions.precombat+=/variable,name=on_use_cutoff,op=set,value=20+variable.empyreal_ordnance_delay,if=equipped.empyreal_ordnance
    spec:RegisterVariable( "on_use_cutoff", function ()
        if equipped.empyreal_ordnance then return 20 + variable.empyreal_ordnance_delay end
        if equipped.macabre_sheet_music then return 25 end
        if variable.combustion_on_use then return 20 end
        return 0
    end )

    -- # Variable that estimates whether Shifting Power will be used before Combustion is ready.
    -- actions+=/variable,name=shifting_power_before_combustion,value=variable.time_to_combustion-cooldown.shifting_power.remains>action.shifting_power.full_reduction&(cooldown.rune_of_power.remains-cooldown.shifting_power.remains>5|!talent.rune_of_power)
    spec:RegisterVariable( "shifting_power_before_combustion", function ()
        return ( variable.time_to_combustion - cooldown.shifting_power.remains ) > action.shifting_power.full_reduction and ( cooldown.rune_of_power.remains - cooldown.shifting_power.remains > 5 or not talent.rune_of_power )
    end )

    -- fire_blast_pooling relies on the flow of the APL for differing values before/after rop_phase.

    -- # Variable that controls Phoenix Flames usage to ensure its charges are pooled for Combustion. Only use Phoenix Flames outside of Combustion when full charges can be obtained during the next Combustion.
    -- actions+=/variable,name=phoenix_pooling,if=active_enemies<variable.combustion_flamestrike,value=variable.time_to_combustion+buff.combustion.duration-5<action.phoenix_flames.full_recharge_time+cooldown.phoenix_flames.duration-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|runeforge.sun_kings_blessing|time<5
    -- # When using Flamestrike in Combustion, save as many charges as possible for Combustion without capping.
    -- actions+=/variable,name=phoenix_pooling,if=active_enemies>=variable.combustion_flamestrike,value=variable.time_to_combustion<action.phoenix_flames.full_recharge_time-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|runeforge.sun_kings_blessing|time<5
    spec:RegisterVariable( "phoenix_pooling", function ()
        if active_enemies < variable.combustion_flamestrike then
            return variable.time_to_combustion + buff.combustion.duration - 5 < action.phoenix_flames.full_recharge_time + cooldown.phoenix_flames.duration - ( variable.shifting_power_before_combustion and action.shifting_power.full_reduction or 0 ) and variable.time_to_combustion < fight_remains or runeforge.sun_kings_blessing.enabled or time < 5
        end
        return variable.time_to_combustion < action.phoenix_flames.full_recharge_time - ( variable.shifting_power_before_combustion and action.shifting_power.full_reduction or 0 ) and variable.time_to_combustion < fight_remains or runeforge.sun_kings_blessing.enabled or time < 5
    end )

    -- # Estimate how long Combustion will last thanks to Sun King's Blessing to determine how Fire Blasts should be used.
    -- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=extended_combustion_remains,op=set,value=buff.combustion.remains+buff.combustion.duration*(cooldown.combustion.remains<buff.combustion.remains),if=conduit.infernal_cascade
    -- # Adds the duration of the Sun King's Blessing Combustion to the end of the current Combustion if the cast would complete during this Combustion.
    -- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=extended_combustion_remains,op=add,value=variable.skb_duration,if=conduit.infernal_cascade&(buff.sun_kings_blessing_ready.up|variable.extended_combustion_remains>1.5*gcd.max*(buff.sun_kings_blessing.max_stack-buff.sun_kings_blessing.stack))
    spec:RegisterVariable( "extended_combustion_remains", function ()
        local value = 0
        if conduit.infernal_cascade.enabled then
            value = buff.combustion.remains
            if cooldown.combustion.remains < buff.combustion.remains then value = value + buff.combustion.duration end
        end
        if conduit.infernal_cascade.enabled and ( buff.sun_kings_blessing_ready.up or value > 1.5 * gcd.max * ( buff.sun_kings_blessing.max_stack - buff.sun_kings_blessing.stack ) ) then
            value = value + variable.skb_duration
        end
        return value
    end )

    -- # With Infernal Cascade, Fire Blast use should be additionally constrained so that it is not be used unless Infernal Cascade is about to expire or there are more than enough Fire Blasts to extend Infernal Cascade to the end of Combustion.
    -- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=expected_fire_blasts,op=set,value=action.fire_blast.charges_fractional+(variable.extended_combustion_remains-buff.infernal_cascade.duration)%cooldown.fire_blast.duration,if=conduit.infernal_cascade
    spec:RegisterVariable( "expected_fire_blasts", function ()
        if not conduit.infernal_cascade.enabled then return 0 end
        return action.fire_blast.charges_fractional + ( variable.extended_combustion_remains - buff.infernal_cascade.duration ) / cooldown.fire_blast.duration
    end )
    -- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=needed_fire_blasts,op=set,value=ceil(variable.extended_combustion_remains%(buff.infernal_cascade.duration-gcd.max)),if=conduit.infernal_cascade
    spec:RegisterVariable( "needed_fire_blasts", function ()
        if not conduit.infernal_cascade.enabled then return 0 end
        return ceil( variable.extended_combustion_remains / ( buff.infernal_cascade.duration - gcd.max ) )
    end )

    -- # Helper variable that contains the actual estimated time that the next Combustion will be ready.
    -- actions.combustion_timing=variable,use_off_gcd=1,use_while_casting=1,name=combustion_ready_time,value=cooldown.combustion.remains*expected_kindling_reduction
    spec:RegisterVariable( "combustion_ready_time", function ()
        return cooldown.combustion.remains * expected_kindling_reduction
    end )

    -- # The cast time of the spell that will be precast into Combustion.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=combustion_precast_time,value=(action.fireball.cast_time*!conduit.flame_accretion+action.scorch.cast_time+conduit.flame_accretion)*(active_enemies<variable.combustion_flamestrike)+action.flamestrike.cast_time*(active_enemies>=variable.combustion_flamestrike)-variable.combustion_cast_remains
    spec:RegisterVariable( "combustion_precast_time", function ()
        return ( ( not conduit.flame_accretion.enabled and action.fireball.cast_time or 0 ) + action.scorch.cast_time + ( conduit.flame_accretion.enabled and 1 or 0 ) ) * ( ( active_enemies < variable.combustion_flamestrike ) and 1 or 0 ) + ( ( active_enemies >= variable.combustion_flamestrike ) and action.flamestrike.cast_time or 0 ) - variable.combustion_cast_remains
    end )

    spec:RegisterVariable( "time_to_combustion", function ()
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=variable.combustion_ready_time
        local value = variable.combustion_ready_time

        -- # Use the next Combustion on cooldown if it would not be expected to delay the scheduled one or the scheduled one would happen less than 20 seconds before the fight ends.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=variable.combustion_ready_time,if=variable.combustion_ready_time+cooldown.combustion.duration*(1-(0.6+0.2*talent.firestarter)*talent.kindling)<=variable.time_to_combustion|variable.time_to_combustion>fight_remains-20
        if variable.combustion_ready_time + cooldown.combustion.duration * ( 1 - ( 0.6 + 0.2 * ( talent.firestarter.enabled and 1 or 0 ) ) * ( talent.kindling.enabled and 1 or 0 ) ) <= value or boss and value > fight_remains - 20 then
            return value
        end

        -- # Delay Combustion for after Firestarter unless variable.firestarter_combustion is set.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=firestarter.remains,if=talent.firestarter&!variable.firestarter_combustion
        if talent.firestarter.enabled and not variable.firestarter_combustion then
            value = max( value, firestarter.remains )
        end

        -- # Delay Combustion for Radiant Spark if it will come off cooldown soon.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.radiant_spark.remains,if=covenant.kyrian&cooldown.radiant_spark.remains-10<variable.time_to_combustion
        if covenant.kyrian then
            value = max( value, cooldown.radiant_spark.remains )
        end
        
        -- # Delay Combustion for Mirrors of Torment
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.mirrors_of_torment.remains,if=covenant.venthyr&cooldown.mirrors_of_torment.remains-25<variable.time_to_combustion
        if covenant.venthyr and cooldown.mirrors_of_torment.remains - 25 < value then
            value = max( value, cooldown.mirrors_of_torment.remains )
        end
        
        -- # Delay Combustion for Deathborne.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.deathborne.remains+(buff.deathborne.duration-buff.combustion.duration)*runeforge.deaths_fathom,if=covenant.necrolord&cooldown.deathborne.remains-10<variable.time_to_combustion
        if covenant.necrolord and cooldown.deathborne.remains - 10 < value then
            value = max( value, cooldown.deathborne.remains + ( buff.deathborne.duration - buff.combustion.duration ) * ( runeforge.deaths_fathom.enabled and 1 or 0 ) )
        end
        
        -- # Delay Combustion for Death's Fathom stacks if there are at least two targets.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.deathborne.remains-buff.combustion.duration,if=runeforge.deaths_fathom&buff.deathborne.up&active_enemies>=2
        if runeforge.deaths_fathom.enabled and buff.deathborne.up and active_enemies > 1 then
            value = max( value, buff.deathborne.remains - buff.combustion.duration )
        end
        
        -- # Delay Combustion for the Empyreal Ordnance buff if the player is using that trinket.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=variable.empyreal_ordnance_delay-(cooldown.empyreal_ordnance.duration-cooldown.empyreal_ordnance.remains)*!cooldown.empyreal_ordnance.ready,if=equipped.empyreal_ordnance
        if equipped.empyreal_ordnance then
            value = max( value, variable.empyreal_ordnance_delay - ( cooldown.empyreal_ordnance.duration - cooldown.empyreal_ordnance.remains ) * ( cooldown.empyreal_ordnance.ready and 0 or 1 ) )
        end
        
        -- # Delay Combustion for Gladiators Badge, unless it would be delayed longer than 20 seconds.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.gladiators_badge_345228.remains,if=equipped.gladiators_badge&cooldown.gladiators_badge_345228.remains-20<variable.time_to_combustion
        if equipped.gladiators_badge and cooldown.gladiators_badge.remains - 20 < value then
            value = max( value, cooldown.gladiators_badge.remains )
        end
        
        -- # Delay Combustion until Combustion expires if it's up.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.combustion.remains
        value = max( value, buff.combustion.remains )        
        
        -- # Delay Combustion until RoP expires if it's up.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.rune_of_power.remains,if=talent.rune_of_power&buff.combustion.down
        if talent.rune_of_power.enabled and buff.combustion.down then
            value = max( value, buff.rune_of_power.remains )
        end
        
        -- # Delay Combustion for an extra Rune of Power if the Rune of Power would come off cooldown at least 5 seconds before Combustion would.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.rune_of_power.remains+buff.rune_of_power.duration,if=talent.rune_of_power&buff.combustion.down&cooldown.rune_of_power.remains+5<variable.time_to_combustion
        if talent.rune_of_power.enabled and buff.combustion.down and cooldown.rune_of_power.remains + 5 < value then
            value = max( value, cooldown.rune_of_power.remains + buff.rune_of_power.duration )
        end
        
        -- # Delay Combustion if Disciplinary Command would not be ready for it yet.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.buff_disciplinary_command.remains,if=runeforge.disciplinary_command&buff.disciplinary_command.down
        if runeforge.disciplinary_command.enabled and buff.disciplinary_command.down then
            value = max( value, cooldown.buff_disciplinary_command.remains )
        end
        
        -- # Raid Events: Delay Combustion for add spawns of 3 or more adds that will last longer than 15 seconds. These values aren't necessarily optimal in all cases.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=raid_event.adds.in,if=raid_event.adds.exists&raid_event.adds.count>=3&raid_event.adds.duration>15
        -- Unsupported, don't bother.
        
        -- # Raid Events: Always use Combustion with vulnerability raid events, override any delays listed above to make sure it gets used here.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=raid_event.vulnerable.in*!raid_event.vulnerable.up,if=raid_event.vulnerable.exists&variable.combustion_ready_time<raid_event.vulnerable.in
        -- Unsupported, don't bother.
        
        return value
    end )
    


    -- Abilities
    spec:RegisterAbilities( {
        alter_time = {
            id = function () return buff.alter_time.down and 342247 or 342245 end,
            cast = 0,
            cooldown = function () return talent.master_of_time.enabled and 30 or 60 end,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 609811,
            
            handler = function ()
                if buff.alter_time.down then
                    applyBuff( "alter_time" )
                else
                    removeBuff( "alter_time" )                   
                    if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
                end
            end,

            copy = 342247,
        },
        
        
        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,

            startsCombat = false,
            texture = 135932,

            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },


        blast_wave = {
            id = 157981,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 135903,

            talent = "blast_wave",

            usable = function () return target.distance < 8 end,
            handler = function ()
                applyDebuff( "target", "blast_wave" )
            end,
        },


        blazing_barrier = {
            id = 235313,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            defensive = true,

            spend = 0.03,
            spendType = "mana",

            startsCombat = false,
            texture = 132221,

            handler = function ()
                applyBuff( "blazing_barrier" )
                if legendary.triune_ward.enabled then
                    applyBuff( "ice_barrier" )
                    applyBuff( "prismatic_barrier" )
                end
            end,
        },


        blink = {
            id = function () return talent.shimmer.enabled and 212653 or 1953 end,
            cast = 0,
            charges = function () return talent.shimmer.enabled and 2 or nil end,
            cooldown = function () return ( talent.shimmer.enabled and 20 or 15 ) - conduit.flow_of_time.mod * 0.001 end,
            recharge = function () return ( talent.shimmer.enabled and ( 20 - conduit.flow_of_time.mod * 0.001 ) or nil ) end,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

            handler = function ()
                if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
                if talent.blazing_soul.enabled then applyBuff( "blazing_barrier" ) end
            end,

            copy = { 212653, 1953, "shimmer" }
        },


        combustion = {
            id = 190319,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.1,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135824,

            usable = function () return time > 0, "must already be in combat" end,
            handler = function ()
                applyBuff( "combustion" )
                stat.crit = stat.crit + 100

                if azerite.wildfire.enabled then applyBuff( "wildfire" ) end
                if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
            end,
        },


        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 134029,

            handler = function ()
            end,
        }, ]]


        counterspell = {
            id = 2139,
            cast = 0,
            cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end,
            gcd = "off",

            discipline = "arcane",

            interrupt = true,
            toggle = "interrupts",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = function () return not runeforge.disciplinary_command.enabled and "casting" or nil end,
            readyTime = function () if debuff.casting.up then return state.timeToInterrupt() end end,

            handler = function ()
                interrupt()
            end,
        },


        dragons_breath = {
            id = 31661,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 134153,

            usable = function () return target.within12, "target must be within 12 yds" end,
            
            handler = function ()
                hot_streak( talent.alexstraszas_fury.enabled )
                applyDebuff( "target", "dragons_breath" )
                if talent.alexstraszas_fury.enabled then applyBuff( "alexstraszas_fury" ) end
            end,
        },


        fire_blast = {
            id = 108853,
            cast = 0,
            charges = function () return ( talent.flame_on.enabled and 3 or 2 ) end,
            cooldown = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * ( set_bonus.tier28_4pc > 0 and buff.combustion.up and 0.5 or 1 ) * haste end,
            recharge = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * ( set_bonus.tier28_4pc > 0 and buff.combustion.up and 0.5 or 1 ) * haste end,
            icd = 0.5,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            usable = function ()
                if time == 0 then return false, "no fire_blast out of combat" end
                return true
            end,

            handler = function ()
                hot_streak( true )
                applyDebuff( "target", "ignite" )

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                if azerite.blaster_master.enabled then addStack( "blaster_master", nil, 1 ) end
                if conduit.infernal_cascade.enabled and buff.combustion.up then addStack( "infernal_cascade" ) end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            end,

            auras = {
                -- Conduit
                infernal_cascade = {
                    id = 336832,
                    duration = 5,
                    max_stack = 3
                }
            }
        },


        fireball = {
            id = 133,
            cast = 2.25,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135812,

            velocity = 45,
            usable = function ()
                if moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
                return true
            end,

            handler = function ()
                removeBuff( "molten_skyfall_ready" )
            end,

            impact = function ()
                if hot_streak( firestarter.active or stat.crit + buff.fireball.stack * 10 >= 100 ) then
                    removeBuff( "fireball" )
                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    addStack( "fireball", nil, 1 )
                    if conduit.flame_accretion.enabled then addStack( "flame_accretion" ) end
                end

                if legendary.molten_skyfall.enabled and buff.molten_skyfall_ready.down then
                    addStack( "molten_skyfall" )
                    if buff.molten_skyfall.stack == 18 then
                        removeBuff( "molten_skyfall" )
                        applyBuff( "molten_skyfall_ready" )
                    end
                end

                applyDebuff( "target", "ignite" )
            end,
        },


        flamestrike = {
            id = 2120,
            cast = function () return ( buff.hot_streak.up or buff.firestorm.up ) and 0 or 4 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135826,

            handler = function ()
                if not hardcast then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else
                        removeBuff( "hot_streak" )
                        if legendary.sun_kings_blessing.enabled then
                            addStack( "sun_kings_blessing", nil, 1 )
                            if buff.sun_kings_blessing.stack == 8 then
                                removeBuff( "sun_kings_blessing" )
                                applyBuff( "sun_kings_blessing_ready" )
                            end
                        end
                    end
                end

                applyDebuff( "target", "ignite" )
                applyDebuff( "target", "flamestrike" )
                removeBuff( "alexstraszas_fury" )
            end,
        },


        focus_magic = {
            id = 321358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            discipline = "arcane",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135754,

            talent = "focus_magic",
            
            usable = function () return active_dot.focus_magic == 0 and group, "can apply one in a group" end,
            handler = function ()
                applyBuff( "focus_magic" )
            end,
        },
        
        
        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = function () return talent.ice_ward.enabled and 30 or nil end,
            gcd = "spell",

            discipline = "frost",

            defensive = true,

            spend = 0.02,
            spendType = "mana",

            startsCombat = false,
            texture = 135848,

            handler = function ()
                applyDebuff( "target", "frost_nova" )
                if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
            end,
        },


        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) end,
            gcd = "spell",

            discipline = "frost",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 135841,

            handler = function ()
                applyBuff( "ice_block" )
                applyDebuff( "player", "hypothermia" )
            end,
        },


        invisibility = {
            id = 66,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            discipline = "arcane",

            spend = 0.03,
            spendType = "mana",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132220,

            handler = function ()
                applyBuff( "preinvisibility" )
                applyBuff( "invisibility", 23 )
                if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
            end,
        },


        living_bomb = {
            id = 44457,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 236220,

            handler = function ()
                applyDebuff( "target", "living_bomb" )
            end,
        },


        meteor = {
            id = 153561,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = false,
            texture = 1033911,

            flightTime = 1,

            impact = function ()
                applyDebuff( "target", "meteor_burn" )
            end,
        },


        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            discipline = "arcane",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            handler = function ()
                applyBuff( "mirror_image" )
            end,
        },


        phoenix_flames = {
            id = 257541,
            cast = 0,
            charges = 3,
            cooldown = function () return 25 * ( set_bonus.tier28_4pc > 0 and buff.combustion.up and 0.5 or 1 ) * haste end,
            recharge = function () return 25 * ( set_bonus.tier28_4pc > 0 and buff.combustion.up and 0.5 or 1 ) * haste end,
            gcd = "spell",

            startsCombat = true,
            texture = 1392549,

            velocity = 50,

            impact = function ()
                if hot_streak( firestarter.active ) and talent.kindling.enabled then
                    setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                end

                applyDebuff( "target", "ignite" )
                if active_dot.ignite < active_enemies then active_dot.ignite = active_enemies end
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            discipline = "arcane",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 136071,

            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },


        pyroblast = {
            id = 11366,
            cast = function () return ( buff.hot_streak.up or buff.firestorm.up ) and 0 or 4.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135808,

            usable = function ()
                if action.pyroblast.cast > 0 then
                    if moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
                    if combat == 0 and not boss and not settings.pyroblast_pull then return false, "opener pyroblast disabled and/or target is not a boss" end
                end
                return true
            end,

            handler = function ()
                if hardcast then
                    removeStack( "pyroclasm" )
                    if buff.sun_kings_blessing_ready.up then
                        applyBuff( "combustion", 6 )
                        removeBuff( "sun_kings_blessing_ready" )
                    end
                else
                    if buff.hot_streak.up then
                        if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                        else
                            removeBuff( "hot_streak" )
                            if legendary.sun_kings_blessing.enabled then
                                addStack( "sun_kings_blessing", nil, 1 )
                                if buff.sun_kings_blessing.stack == 12 then
                                    removeBuff( "sun_kings_blessing" )
                                    applyBuff( "sun_kings_blessing_ready" )
                                end
                            end
                        end
                    end
                end

                removeBuff( "molten_skyfall_ready" )
            end,

            velocity = 35,

            impact = function ()
                if hot_streak( firestarter.active or buff.firestorm.up ) then
                    if talent.kindling.enabled then
                        setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
                    end
                end

                if legendary.molten_skyfall.enabled and buff.molten_skyfall_ready.down then
                    addStack( "molten_skyfall" )
                    if buff.molten_skyfall.stack == 18 then
                        removeBuff( "molten_skyfall" )
                        applyBuff( "molten_skyfall_ready" )
                    end
                end

                applyDebuff( "target", "ignite" )
                removeBuff( "alexstraszas_fury" )
            end,
        },


        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            discipline = "arcane",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136082,

            debuff = "dispellable_curse",
            handler = function ()
                removeDebuff( "player", "dispellable_curse" )
            end,
        },


        ring_of_frost = {
            id = 113724,
            cast = 2,
            cooldown = 45,
            gcd = "spell",

            discipline = "frost",

            spend = 0.08,
            spendType = "mana",

            startsCombat = true,
            texture = 464484,

            talent = "ring_of_frost",

            handler = function ()                
            end,
        },


        rune_of_power = {
            id = 116011,
            cast = 1.5,
            cooldown = 45,
            gcd = "spell",

            discipline = "arcane",

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",

            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },


        scorch = {
            id = 2948,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135827,

            handler = function ()
                if talent.frenetic_speed.enabled then applyBuff( "frenetic_speed" ) end
                hot_streak( talent.searing_touch.enabled and target.health_pct < 30 )
                applyDebuff( "target", "ignite" )
            end,
        },


        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            discipline = "arcane",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135992,

            handler = function ()
                applyBuff( "slow_fall" )
            end,
        },


        spellsteal = {
            id = 30449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            discipline = "arcane",

            spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135729,

            debuff = "stealable_magic",
            handler = function ()
                removeDebuff( "target", "stealable_magic" )
            end,
        },


        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",

            discipline = "arcane",

            spend = 0.04,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,

            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
        gcdSync = false,
        -- canCastWhileCasting = true,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "spectral_intellect",

        package = "Fire",
    } )


    --[[ spec:RegisterSetting( "fire_at_will", false, {
        name = "Accept Fire Disclaimer",
        desc = "The Fire Mage module is disabled by default, as it tends to require *much* more CPU usage than any other specialization module.  If you wish to use the Fire module, " ..
            "can check this box and reload your UI (|cFFFFD100/reload|r) and the module will be available again.",
        type = "toggle",
        width = "full"
    } ) ]]

    spec:RegisterSetting( "pyroblast_pull", false, {
        name = "Allow |T135808:0|t Pyroblast Hardcast Pre-Pull",
        desc = "If checked, the addon will recommend an opener |T135808:0|t Pyroblast against bosses, if included in the current priority.",
        type = "toggle",
        width = "full"
    } )
    
    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent |T135808:0|t Pyroblast and |T135812:0|t Fireball Hardcasts While Moving",
        desc = "If checked, the addon will not recommend |T135808:0|t Pyroblast or |T135812:0|t Fireball if they have a cast time and you are moving.\n\n" ..
            "Instant |T135808:0|t Pyroblasts will not be affected.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Fire", 20211123, [[dev51eqiuu9iOOUevuv2KsvFce1OabNceAvqr0RarMfuQBrLsTlQ6xOGgguKoMsflJkfpdkcttPsvxtPsABurP8nQOiJJkQQoNsLkToQOY8qbUhvyFqv5FOis6GurjleQIhcvvtKkkCrQOO2iuL6JkvQyKqvcNKkQYkPI8suevZKkLCtQOuTtuu(juLOHQujwQsLINcstffPRQuP0wrreFffrzSOiSxu6VegSIdtzXs6XOAYG6YiBwjFwvA0kLttA1Ois9AuOzt0Tvv7wLFl1WvfhhQsA5qEoW0fUUeBhQ8DQKXtLQZdLSEuejMpuy)IMDhwMYcf2cILzUbtDZo7SJBWeE3SdMatSR7kl0aRhIf6JXz0EjwON9jwO4TIiwOpgwY2GzzkluqxqCIf6wepaNJHm8vJTs1Z7pdb6ViTq7JJSvWqG(5mKfATOYW5DSvwOWwqSmZnyQB2zNDCdMW7MDWe74gNjwOwj2AeluO6h)Sq3uyy6yRSqHjaNfkERikhND7LsN2I4b4CmKHVASvQEE)ziq)fPfAFCKTcgc0pNHPtmRXr)kHYXnycSZXnyQB2jDkDc)B29saNlDYTZz3cOCw67wiq030dKdYIncLtSzxoHHEPWh6NerlGvkNvJYrAGWTbeVp4CSQk1aRCka7La(0j3oh3QBaD5WnqKdIWRffrF6cqoRgLd(7FTacTVCGG6jp25a3hKJC2AjCoAKZQr5y5SqeylhNDkOgLd3abe9PtUDooZNvLuoGaP8ih(gXzuV3C6lhlNf5kNvJyeKJE5eBuooRDXTYj6CqeCHt54QrmkBd2No5254SGzsxarowo7cwOUknqKdDbcRCInlYbUjqoxh58BysMJlskZrp3(1(uoqaO)CcceeCowKZ15a03txk3UihNXUanh9)y8aI(0j3oh83hocf5yszo1YA5zcpImEKdDbsjqorNtTSwEMWxEWoh7YXK)ge5OhqFpDPC7ICCg7c0CEn9YrVCa6h4tNC7C2TakNndbZBycohCgsTQKa5eDoicUWPCW)USBZXvJyu2gSNfQubbGLPSqFqeV)vlyzklZ2HLPSqnEO9Xc1qC7iHEbjLepyHsNvLemlEydwM5gwMYcLoRkjyw8WcfMaCK(eAFSqnEO9b8piI3)QfqYbdXzi1Qsc7Z(KJ(efaj4LOxlSXzYc5WnykKWzi1QsYt)hSqKjfnc(SJtcysAyHTUCq41I(8qWE6)GfImPOrWNDCIf6zFIfkOlsH(EAqiwOCKgesnwOmphCgsTQK88(xlGq7t0NOaOC2NdZZHWRf95HG9WiYGxkIe4iaGK5SphMNtys6c)sreimuqipDwvsWSqnEO9Xcf0fPqFpnieBWYmmbltzHsNvLemlEyHE2NyHc2m42fblAuv0lr0OpDbluJhAFSqbBgC7IGfnQk6LiA0NUGnyz2UNLPSqnEO9Xc9RiuJe63EjwO0zvjbZIh2GLz7kltzHsNvLemlEyHYrAqi1yHY8CEqeo)dwOUknqWc14H2hl0hSqDvAGGnydwOW0YkYGLPSmBhwMYcLoRkjyw8WcLJ0GqQXcL55GkhTA0l5HvaxFK6ziSe8()Td2tNvLemluJhAFSq5D5ccbEiPKnyzMByzklu6SQKGzXdluJhAFSqbB6k07v80UieluycWr6tO9XcLjXqQvLuoXMf5qGq)wqGCCTrXgHYb6MUc9EZzxAxekhxQuMtLYPai4CQ0Qruo4V)1ci0(Yrb5GidglpluosdcPgl0AzT88(xlGq7Zd3UUC2NJXdTp)srKOknq45Bg6La5Wah5Sto7ZH55aHCQL1YR3IqNjfCdWnyYxEYzFo1YA536qacezm6rKXJCGyo7ZbNHuRkjpytxHEVIN2fHevA1isW7FTacTp2GLzycwMYcLoRkjyw8Wc14H2hluKbR2fcWJHyKfkmb4i9j0(yHc1Wr5SBmy1UihOpgIXCwnkh83)AbeAFyNtTe50XgHCPakNcGYrJC6lhE3s4215zHYrAqi1yHwlRLN3)AbeAFE421LZ(CGqo4mKAvj5d9tIOf8(xlGq7lh8LJXdTpbVBjC76YXTZzxZbISblZ29SmLfkDwvsWS4HfQXdTpwOWKfB1gDeluycWr6tO9Xc1zqwSvB0r5a26Ieoht6YWcKtLYPai4CCPXwo4V)1ci0(85WKPXwoodYInidYbVTyR)yNJg5a26IeoNkLtbqW5qgsIvoGoNyZICCgKfB1gDuoUuPmNndhLZVruoGW4mcYbUG07nh83)AbeAFEwOCKgesnwO1YA559VwaH2NhUDD5SpNAzT8OYrIEjEAxeYd3UUC2NdodPwvs(q)KiAbV)1ci0(YHb5GZqQvLKN3)AbeAFIheXnqic9t5aPCi3jEjirOFkhiLdeYPwwlpmzXwTrh5Hlil0(YXTZPwwlpV)1ci0(8WfKfAF5aXCWK5GkhTA0l5Hjl2aILfB93tNvLemBWYSDLLPSqPZQscMfpSqnEO9Xc9RiuJaIEjIg9PlyHctaosFcTpwO7waLJZUIqncKtVYHPn6txKJln2Yb)9VwaH2NNfkhPbHuJfkodPwvs(q)KiAbV)1ci0(YHb5GZqQvLKN3)AbeAFIheXnqic9t5aPCi3jEjirOFkN95ulRLN3)AbeAFE421XgSmZzJLPSqPZQscMfpSqnEO9Xc9RiuJaIEjIg9PlyHctaosFcTpwOoljOZPaOCC2veQrGC6vomTrF6IC0lNkfUi6Yb)9VwaH2hihdKJSV3Cmqo4V)1ci0(YXLkL5CDKZMHJYj6CQuoWK0WIGZ5x4B5SAuoA4zHYrAqi1yHIZqQvLKp0pjIwW7FTacTVCWxogp0(e8ULWTRlh3ohmbMMdMmhu5OvJEjpqVvrkGjP(UfE6SQKGzdwM5mXYuwO0zvjbZIhwOfajCTPssWnqO3llZ2Hfkmb4i9j0(yHI3nkhMe6InSqyNtbq5y5G3kIYbpsde5W3m0lLdCbP3Boo7kc1iqo9khM2OpDroCde5eDogUwHZHBpp69MdFZqVeWZc14H2hl0LIirvAGGfkhPbHuJfQXdTp)xrOgbe9sen6tx4j3jEj07nN95SksPar8nd9sIq)uoUDogp0(8FfHAeq0lr0OpDHNCN4LGei6B6bYHb5S7ZzFompNToeGargJcWdjLaHEILuF3IC2NdZZPwwl)whcqGiJrF5HnyzMZpltzHsNvLemlEyHA8q7Jf6R0GvlAequn4xIfkhPbHuJfkodPwvs(q)KiAbV)1ci0(YbF5y8q7tW7wc3UUCC7C2vwO0Ar8qC2NyH(kny1Igbevd(LydwMT7YYuwO0zvjbZIhwOgp0(yHs)hSqKjfnc(SJtSq5iniKASqXzi1QsYh6Nerl49VwaH2xomWro4mKAvj5P)dwiYKIgbF2XjbmjnSYzFo4mKAvj5d9tIOf8(xlGq7lh8LdodPwvsE6)GfImPOrWNDCsatsdRCC7C2vwON9jwO0)blezsrJGp74eBWYSDWuwMYcLoRkjyw8Wc14H2hluWMb3UiyrJQIEjIg9PlyHYrAqi1yHcHCWzi1QsYh6Nerl49VwaH2xomWro4mKAvj559VwaH2N4brCdeIq)uoqkh3KdgyKZsF3cbI(MEGCyqo4mKAvj5d9tIOf8(xlGq7lhiMZ(CQL1YZ7FTacTppC76yHE2NyHc2m42fblAuv0lr0OpDbBWYSD2HLPSqPZQscMfpSqnEO9Xc9vI1ZMOxcda0VkTq7JfkhPbHuJfkeYPwwlpV)1ci0(8WTRlN95GZqQvLKp0pjIwW7FTacTVCWNJCWzi1QsY3NOaibVe9ALdgyKdodPwvs((efaj4LOxRCCKdMMdezHE2NyH(kX6zt0lHba6xLwO9XgSmBh3WYuwO0zvjbZIhwOgp0(yH(nUvrKaSrui(fGYzHYrAqi1yHIZqQvLKp0pjIwW7FTacTVCyGJC2vwON9jwOFJBvejaBefIFbOC2GLz7Gjyzklu6SQKGzXdluycWr6tO9Xc15TYPa07nhlhqqOwHZPp3UaOC0G(yNJjDzybYPaOCCgiYGxkIYHjHaasMtxcGct50RCWF)RfqO95ZbVm2iKlfqyNZdsBKgktkuofGEV54mqKbVueLdtcbaKmhxASLd(7FTacTVC6tIvo6khN3Ti0zYCWVb4gmLJcYHoRkj4CSdohlNcWEPCC1hKJCQuoYge504iuoXgLdCbzH2xo9kNyJYzPVBHphMUPGCmyyqowoGVjL5GZKfkNOZj2OC4DlHBxxo9khNbIm4LIOCysiaGK54AJUCGB9EZj2uqoCtYlsl0(YPsCRaOC0ihfKt5qKjbHYZj6CmaO8PCInlYrJCCPszovkNcGGZ5HqlIhsSYPVC4DlHBxNNf6zFIfkmIm4LIibocaijluosdcPgluiKtTSwEE)RfqO95HBxxo7ZbNHuRkjFOFseTG3)AbeAF5Gph5GZqQvLKVprbqcEj61khmWihCgsTQK89jkasWlrVw54ihmnhiMZ(CGqo1YA51BrOZKcUb4gm5bHXzmhh5ulRLxVfHotk4gGBWK)BUlaHXzmhmWihMNdVp4IgE9we6mPGBaUbtE6SQKGZbdmYbNHuRkjpV)1ci0(e9jkakhmWihCgsTQK8H(jr0cE)RfqO9Ld(YrVGqpT0ccwS03TqGOVPhihNVCYbc5y8q7tW7wc3UUCGuo7GP5aXCGiluJhAFSqHrKbVuejWraajzdwMTZUNLPSqPZQscMfpSqnEO9Xcf0fPqFpnieluosdcPgluiKdodPwvs(q)KiAbV)1ci0(YbFoYbtGP5GjZbc5GZqQvLKVprbqcEj61kh8LdMMdeZbdmYbc5W8CcKEmsHp2XRapOlsH(EAqOC2NtG0Jrk8Xo(cWQskN95ei9yKcFSJN3TeUDDEe9n9a5Gbg5W8CcKEmsHpCJxbEqxKc990Gq5SpNaPhJu4d34laRkPC2NtG0Jrk8HB88ULWTRZJOVPhihiMdeZzFoqihMNdHxl6Zdb7HrKbVuejWraajZbdmYH3TeUDDEyezWlfrcCeaqspI(MEGCWxo7AoqKf6zFIfkOlsH(EAqi2GLz7SRSmLfkDwvsWS4HfQXdTpwOC74KuulRfluosdcPgluMNdVp4IgE9we6mPGBaUbtE6SQKGZzFoH(PCyqo7AoyGro1YA51BrOZKcUb4gm5bHXzmhh5ulRLxVfHotk4gGBWK)BUlaHXzKfATSwIZ(eluqxKc990q7Jfkmb4i9j0(yHYuK((sOCG2fzooV3tdcLdzijw54sJTCCE3IqNjZb)gGBWuonkhxB0LJg54Ya58GiUbcpBWYSDC2yzklu6SQKGzXdluycWr6tO9Xc15f0hKtSzroWDoxh5uPJwAKd(7FTacTVCaBDrcNdt6ciYPs5uaeCoDjakmLtVYb)9VwaH2xowKdO)uopTEHNf6zFIfQEaoQewvsc8AXUO8fWeoLtSq5iniKASqj8ArFEiy)R0GvlAequn4xkN95aHCQL1YZ7FTacTppC76YzFo4mKAvj5d9tIOf8(xlGq7lh85ihCgsTQK89jkasWlrVw5Gbg5GZqQvLKVprbqcEj61khh5GP5arwOgp0(yHQhGJkHvLKaVwSlkFbmHt5eBWYSDCMyzklu6SQKGzXdluJhAFSqxs7tIEjQwesIfkhPbHuJfkHxl6Zdb7FLgSArJaIQb)s5SphiKtTSwEE)RfqO95HBxxo7ZbNHuRkjFOFseTG3)AbeAF5Gph5GZqQvLKVprbqcEj61khmWihCgsTQK89jkasWlrVw54ihmnhiYc9SpXcDjTpj6LOArij2GLz748ZYuwO0zvjbZIhwOgp0(yH6YyKocbeluFWSq5iniKASqj8ArFEiy)R0GvlAequn4xkN95aHCQL1YZ7FTacTppC76YzFo4mKAvj5d9tIOf8(xlGq7lh85ihCgsTQK89jkasWlrVw5Gbg5GZqQvLKVprbqcEj61khh5GP5arwON9jwOUmgPJqaXc1hmBWYSD2Dzzklu6SQKGzXdluJhAFSq1deOcpAeqaR40JevskzHYrAqi1yHs41I(8qW(xPbRw0iGOAWVuo7Zbc5ulRLN3)AbeAFE421LZ(CWzi1QsYh6Nerl49VwaH2xo4Zro4mKAvj57tuaKGxIETYbdmYbNHuRkjFFIcGe8s0RvooYbtZbISqp7tSq1deOcpAeqaR40JevskzdwM5gmLLPSqPZQscMfpSqnEO9XcfuUQSByH9PydlqWcLJ0GqQXcLWRf95HG9VsdwTOrar1GFPC2NdeYPwwlpV)1ci0(8WTRlN95GZqQvLKp0pjIwW7FTacTVCWNJCWzi1QsY3NOaibVe9ALdgyKdodPwvs((efaj4LOxRCCKdMMdezHE2NyHckxv2nSW(uSHfiydwM5MDyzklu6SQKGzXdluosdcPgl0AzT88(xlGq7Zd3UUC2NdodPwvs(q)KiAbV)1ci0(YbFoYbNHuRkjFFIcGe8s0RvoyGro4mKAvj57tuaKGxIETYXroykluJhAFSqlasOb9bSblZCJByzklu6SQKGzXdluJhAFSqxOgeIRXzSqHjahPpH2hl0DlGYbVrniYHznolNOZjq67lHYz3bPajw5484kxsEwOCKgesnwOOYrRg9s(xKcKyjuUYLKNoRkj4C2NtTSwEE)RfqO95HBxxo7Zbc5GZqQvLKp0pjIwW7FTacTVCWxogp0(e8ULWTRlhmWihCgsTQK8H(jr0cE)RfqO9LddYbNHuRkjpV)1ci0(epiIBGqe6NYbs5qUt8sqIq)uoqKnyzMBWeSmLfkDwvsWS4HfQXdTpwO8UCbHapKuYcfMaCK(eAFSq3DOiNyJYXzOaU(i1ZqyLd(7)3o4CQL1kNYd25uojba5W7FTacTVCuqoGUppluosdcPgluu5OvJEjpSc46JupdHLG3)VDWE6SQKGZzFo8ULWTRZxlRLawbC9rQNHWsW7)3oypImySYzFo1YA5HvaxFK6ziSe8()TdwyiUDKhUDD5SphMNtTSwEyfW1hPEgclbV)F7G9LNC2NdeYbNHuRkjFOFseTG3)AbeAF5aPCmEO95xOge1wgEUbcrOFkh8LdVBjC7681YAjGvaxFK6ziSe8()Td2dxqwO9LdgyKdodPwvs(q)KiAbV)1ci0(YHb5SR5ar2GLzUz3ZYuwO0zvjbZIhwOCKgesnwOOYrRg9sEyfW1hPEgclbV)F7G90zvjbNZ(C4DlHBxNVwwlbSc46JupdHLG3)VDWEezWyLZ(CQL1YdRaU(i1Zqyj49)BhSWqC7ipC76YzFompNAzT8WkGRps9mewcE))2b7lp5SphiKdodPwvs(q)KiAbV)1ci0(Ybs5qUt8sqIq)uoqkhJhAF(fQbrTLHNBGqe6NYbF5W7wc3UoFTSwcyfW1hPEgclbV)F7G9WfKfAF5Gbg5GZqQvLKp0pjIwW7FTacTVCyqo7Ao7ZH55eMKUWJkhj6L4PDripDwvsW5arwOgp0(yHAiUDKGC)r2aTp2GLzUzxzzklu6SQKGzXdluosdcPgluu5OvJEjpSc46JupdHLG3)VDWE6SQKGZzFo8ULWTRZxlRLawbC9rQNHWsW7)3oypI(MEGCyqoCdeIq)uo7ZPwwlpSc46JupdHLG3)VDWIfQbHhUDD5SphMNtTSwEyfW1hPEgclbV)F7G9LNC2NdeYbNHuRkjFOFseTG3)AbeAF5aPC4gieH(PCWxo8ULWTRZxlRLawbC9rQNHWsW7)3oypCbzH2xoyGro4mKAvj5d9tIOf8(xlGq7lhgKZUMdezHA8q7Jf6c1GO2YGnyzMBC2yzklu6SQKGzXdluosdcPgluu5OvJEjpSc46JupdHLG3)VDWE6SQKGZzFo8ULWTRZxlRLawbC9rQNHWsW7)3oypImySYzFo1YA5HvaxFK6ziSe8()TdwSqni8WTRlN95W8CQL1YdRaU(i1Zqyj49)BhSV8KZ(CGqo4mKAvj5d9tIOf8(xlGq7lh8LdVBjC7681YAjGvaxFK6ziSe8()Td2dxqwO9LdgyKdodPwvs(q)KiAbV)1ci0(YHb5SR5arwOgp0(yHUqniexJZydwM5gNjwMYcLoRkjyw8WcTFyHcOGfQXdTpwO4mKAvjXcfMaCK(eAFSq3LUL5yGC(2Hvo4TIOCWJ0abihdKZtdaAvs5SAuo4V)1ci0(85aTudKXJC6sKtVYj2OCwiJhAFMmhE)F6JUiNELtSr5CLFLq50RCWBfr5GhPbcqoXMf54sLYColkitkXkheX3m0lLdCbP3BoXgLd(7FTacTVCE2maLtL4wbq580TuV3CSdRytV3CEmqKtSzroUuPmNRJCEr2f5yxoK7bYYbVveLdEKgiYbUG07nh83)AbeAFEwO4mzHyHIZqQvLKNCpOdMGf8(xlGq7tGOVPhihgKdodPwvs(q)KiAbV)1ci0(YzFogp0(8lfrIQ0aHNVzOxciwiJhAFMmhiLdeYbNHuRkjFOFseTG3)AbeAF5aPCmEO95bB6k07v80UiKFvKsbIGl8q7lhmzo4mKAvj5bB6k07v80UiKOsRgrcE)RfqO9LdKYbc5at1YA5)kc1iGOxIOrF6c)3CxacJZyoUDo7KdeZbtMdodPwvs(FhceX3m0ljSFxUihmzo8ghD2fEC0fByHYbtMdeYH3TeUDD(VIqnci6LiA0NUWJOVPhihg4ihCgsTQK8H(jr0cE)RfqO9LdeZbI5WWC4DlHBxNFPisuLgi8WfKfAF5425StomihE3s4215xkIevPbc)3CxW3m0lbYbs5GZqQvLKVXrONULILIirvAGaKddZH3TeUDD(LIirvAGWdxqwO9LJBNdeYPwwlpV)1ci0(8WfKfAF5WWC4DlHBxNFPisuLgi8WfKfAF5aXCYX5lNDYzFo4mKAvj5d9tIOf8(xlGq7lhgKZsF3cbI(MEawOfaj61s8YHzz2oSqXziXzFIf6srKOknqiE6wQ3ll0cGeU2ujj4gi07LLz7WgSmZno)SmLfkDwvsWS4HfkhPbHuJfkodPwvs(q)KiAbV)1ci0(YHboYbtZbdmYPwwlpV)1ci0(8LNCWaJCWzi1QsYh6Nerl49VwaH2xomihCgsTQK88(xlGq7t8GiUbcrOFkN95W7wc3UopV)1ci0(8i6B6bYHb5GZqQvLKN3)AbeAFIheXnqic9tSqnEO9XcLBsPW4H2NqQGGfQubH4SpXcL3)AbeAFINndqSblZCZUlltzHsNvLemlEyHYrAqi1yHwlRLN3)AbeAFE421LZ(CQL1YJkhj6L4PDripC76YzFompNAzT8lfrGOrFpImEKZ(CGqo4mKAvj5d9tIOf8(xlGq7lh85iNAzT8OYrIEjEAxeYdxqwO9LZ(CWzi1QsYh6Nerl49VwaH2xo4lhJhAF(LIirvAGWVksPar8nd9sIq)uoyGro4mKAvj5d9tIOf8(xlGq7lh8LZsF3cbI(MEGCGyo7Zbc5W8CqLJwn6L8GYjyuVxGOkjaqVxpDwvsW5Gbg5y8qXrc6OVsGCWNJCWzi1QsYVziyb3aHyjTpbcKYiLdgyKtTSwEq5emQ3lquLeaO3Rargmw(YtoyGro1YA5bLtWOEVarvsaGEVEez8ih85iNAzT8GYjyuVxGOkjaqVx)3CxacJZyoUDo7KdgyKZsF3cbI(MEGCyqo1YA5rLJe9s80UiKhUGSq7lhiYc14H2hluu5irVepTlcXgSmdtGPSmLfkDwvsWS4HfAbqcxBQKeCde69YYSDyHA8q7JfkodPwvsSq7hwOakyHYrAqi1yHY8CWzi1QsYVuejQsdeINUL69MZ(CqLJwn6L8GYjyuVxGOkjaqVxpDwvsWSqlas0RL4LdZYSDyHIZKfIfkGmKEVIOl8nVXdfhLZ(CmEO95xkIevPbc)QiLceX3m0ljc9t5GVCWe5GjZ5Ld7)M7SqHjahPpH2hluNfmt6ciYj2OCWzi1QskNyZIC49fOwcYbVveLdEKgiYPaSxkNOZby4OCWBfr5GhPbcqoU2ujLduYq69Mdt7cFlhfKJXdfhLJln2YbA5YHjxVxidYbpsca071ZcfNHeN9jwOlfrIQ0aH4PBPEVSblZWe7WYuwO0zvjbZIhwOWeGJ0Nq7Jfkt2gD5ua69MdElTpbcKYiLJE5G)(xlGq7d7CagokhdKZ3oSYHVzOxcKJbY5PbaTkPCwnkh83)AbeAF54sJTUe5WTNh9E9SqnEO9XcLBsPW4H2NqQGGfkiqkpyz2oSq5iniKASqRL1YJkhj6L4PDriF5jN95ulRLN3)AbeAFE421LZ(CWzi1QsYh6Nerl49VwaH2xo4lhmLfQubH4SpXcf1pINndqSblZWeUHLPSqPZQscMfpSqlas4AtLKGBGqVxwMTdluJhAFSqXzi1QsIfA)WcfqbluosdcPgluMNdodPwvs(LIirvAGq80TuV3C2Ntys6cpQCKOxIN2fH80zvjbNZ(CQL1YJkhj6L4PDripC76yHwaKOxlXlhMLz7WcfNjleluiKdZZbvoA1OxYdkNGr9EbIQKaa9E90zvjbNdgyKtTSwEq5emQ3lquLeaO3RhegNXCWxo1YA5bLtWOEVarvsaGEV(V5UaegNXCC7C2jhiMZ(C4DlHBxNhvos0lXt7IqEe9n9a5WGCmEO95xkIevPbc)QiLceX3m0ljc9t5425y8q7Zd20vO3R4PDri)QiLcebx4H2xoyYCGqo4mKAvj5bB6k07v80UiKOsRgrcE)RfqO9LZ(C4DlHBxNhSPRqVxXt7IqEe9n9a5WGC4DlHBxNhvos0lXt7IqEe9n9a5aXC2NdVBjC768OYrIEjEAxeYJOVPhihgKZsF3cbI(MEawOWeGJ0Nq7JfQZcMjDbe5eBuo4mKAvjLtSzro8(culb5G3kIYbpsde5ua2lLt05qhOGOC0aKdFZqVeihdr5ysqNZt3scoNvJYz3uokNELZU0UiKNfkodjo7tSqxkIevPbcXt3s9EzdwMHjWeSmLfkDwvsWS4HfAbqcxBQKeCde69YYSDyHYrAqi1yHY8CWzi1QsYVuejQsdeINUL69MZ(CWzi1QsYh6Nerl49VwaH2xo4lhmnN95y8qXrc6OVsGCWNJCWzi1QsYVziyb3aHyjTpbcKYiLZ(CyEolfrGWqbH8gpuCuo7ZH55ulRLFRdbiqKXOV8KZ(CGqo1YA53il07vuE8LNC2NJXdTp)sAFceiLrYtUt8sqce9n9a5WGCWu)UMdgyKdFZqVeqSqgp0(mzo4ZroUjhiYcTairVwIxomlZ2HfQXdTpwOlfrIQ0abluycWr6tO9XcLjBJUCWlmem3aHEV5G3s7tGaPmsyNdERikh8inqaYbS1fjCovkNcGGZj6CEPJqwq5Gx0roqdezmcYXo4CIohY9Go4CWJ0abHYXz3abH8SblZWe7EwMYcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSq5iniKASqxkIaHHcc5nEO4OC2NdodPwvs(q)KiAbV)1ci0(YbF5GP5SphMNdodPwvs(LIirvAGq80TuV3C2NdeYH55y8q7ZVuevnP0tUt8sO3Bo7ZH55y8q7Z)GfQRsdeE9elP(Uf5SpNAzT8BKf69kkpEez8ihmWihJhAF(LIOQjLEYDIxc9EZzFompNAzT8BDiabImg9iY4royGrogp0(8pyH6Q0aHxpXsQVBro7ZPwwl)gzHEVIYJhrgpYzFompNAzT8BDiabImg9iY4roqKfAbqIETeVCywMTdluJhAFSqxkIevPbcwOWeGJ0Nq7JfQZOG07nh8wreimuqiSZbVveLdEKgia5yikNcGGZbOFvAijw5eDoWfKEV5G)(xlGq7ZNZUdDeYKsSWoNyJWkhdr5uaeCorNZlDeYckh8IoYbAGiJrqoU2OlhosdqoUuPmNRJCQuoUmqqW5yhCoU0ylh8inqqOCC2nqqiSZj2iSYbS1fjCovkhWdIm4C6sKt058n9ctVCInkh8inqqOCC2nqqOCQL1YZgSmdtSRSmLfkDwvsWS4HfAbqcxBQKeCde69YYSDyHctaosFcTpwOolCTcNd3EE07nh8wruo4rAGih(MHEjqoU2ujLdFZUJK69Md0nDf69MZU0UieluJhAFSqxkIevPbcwOCKgesnwOgp0(8GnDf69kEAxeYtUt8sO3Bo7ZzvKsbI4Bg6LeH(PCyqogp0(8GnDf69kEAxeYhkNrbIGl8q7JnyzgMWzJLPSqPZQscMfpSq5iniKASqXzi1QsYh6Nerl49VwaH2xo4lhmnN95ulRLhvos0lXt7IqE421LZ(CQL1YZ7FTacTppC76yHA8q7Jfk3KsHXdTpHubbluPccXzFIfkiSd2qWcuhwO9XgSmdt4mXYuwOgp0(yHc4nIVXcLoRkjyw8WgSbluu)iE2maXYuwMTdltzHsNvLemlEyHA8q7Jf6sAFceiLrIfkmb4i9j0(yH6miPHvo4V)1ci0(Yz1OCC2veQrGC6vomTrF6cpluosdcPgluJhkosqh9vcKd(CKdodPwvs(ToeGargJIL0(eiqkJuo7Zbc5ulRLFRdbiqKXOV8KdgyKtTSw(LIiq0OVV8KdezdwM5gwMYcLoRkjyw8WcLJ0GqQXcTwwlpmzXwTrh5lp5Sphu5OvJEjpmzXgqSSyR)E6SQKGZzFo4mKAvj5d9tIOf8(xlGq7lhgKtTSwEyYITAJoYJOVPhiN95y8qXrc6OVsGCWNJCCdluJhAFSqxkIQMuYgSmdtWYuwO0zvjbZIhwOCKgesnwOgpuCKGo6Reih85ihCgsTQK8BgcwWnqiws7tGaPms5SpNAzT8GYjyuVxGOkjaqVxbImyS8LNC2NtTSwEq5emQ3lquLeaO3RargmwEe9n9a5GVC4gieH(jwOgp0(yHUK2NabszKydwMT7zzklu6SQKGzXdluosdcPgl0AzT8GYjyuVxGOkjaqVxbImyS8LNC2NtTSwEq5emQ3lquLeaO3RargmwEe9n9a5GVC4gieH(jwOgp0(yH(GfQRsdeSblZ2vwMYcLoRkjyw8WcLJ0GqQXcTwwl)sreiA03xEyHA8q7Jf6dwOUknqWgSmZzJLPSqPZQscMfpSq5iniKASqRL1YV1HaeiYy0xEyHA8q7Jf6dwOUknqWgSmZzILPSqPZQscMfpSqlas4AtLKGBGqVxwMTdluosdcPgluMNdodPwvs(LIirvAGq80TuV3C2NtTSwEq5emQ3lquLeaO3RargmwE421LZ(CmEO4ibD0xjqomihCgsTQK8BgcwWnqiws7tGaPms5SphMNZsreimuqiVXdfhLZ(CGqompNAzT8BKf69kkp(Yto7ZH55ulRLFRdbiqKXOV8KZ(CyEopicNOxlXlh2VuejQsde5SphiKJXdTp)srKOknq45Bg6La5Gph54MCWaJCGqoHjPl8MKCheidWKIbeRcclpDwvsW5SphE3s4215Hr2BFarfrwS5rKbJvoqmhmWihazi9Efrx4BEJhkokhiMdezHwaKOxlXlhMLz7Wc14H2hl0LIirvAGGfkmb4i9j0(yHUBbuo9r5G3kIYbpsde5qgsIvo6LZUP3LC0voy1LCG7dYroBgokhsJncLdEbzHEV5SBFYPr5Gx0roqdezmMdwuKJDW5qASriNlhiyqmNndhLZVruoXMD5eU6CmjImySWohiuHyoBgokhNLKCheidWKIbzqo4DbHvoiYGXkNOZPaiSZPr5aboeZbkzi9EZHPDHVLJcYX4HIJ854m6dYroWDoXMcYX1MkPC2meCoCde69MdElTpbcKYibYPr54AJUCGwUCyY17fYGCWJKaa9EZrb5GidglpBWYmNFwMYcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSq5iniKASqzEo4mKAvj5xkIevPbcXt3s9EZzFompNLIiqyOGqEJhkokN95ulRLhuobJ69cevjba69kqKbJLhUDD5SphiKdeYbc5y8q7ZVuevnP0tUt8sO3Bo7Zbc5y8q7ZVuevnP0tUt8sqce9n9a5WGCWu)UMdgyKdZZbvoA1OxYVuebIg990zvjbNdeZbdmYX4H2N)bluxLgi8K7eVe69MZ(CGqogp0(8pyH6Q0aHNCN4LGei6B6bYHb5GP(DnhmWihMNdQC0QrVKFPicen67PZQscohiMdeZzFo1YA53il07vuE8iY4roqmhmWihiKdGmKEVIOl8nVXdfhLZ(CGqo1YA53il07vuE8iY4ro7ZH55y8q7Zd4nIV5j3jEj07nhmWihMNtTSw(ToeGargJEez8iN95W8CQL1YVrwO3RO84rKXJC2NJXdTppG3i(MNCN4LqV3C2NdZZzRdbiqKXOa8qsjqONyj13TihiMdeZbISqlas0RL4LdZYSDyHA8q7Jf6srKOknqWcfMaCK(eAFSq3Takh8wruo4rAGihsJncLdCbP3Bowo4TIOQjLmCxWc1vPbIC4giYX1gD5GxqwO3Bo72NCuqogpuCuonkh4csV3Ci3jEjOCCPXwoqjdP3BomTl8npBWYSDxwMYcLoRkjyw8Wc14H2hluUjLcJhAFcPccwOsfeIZ(eluJhkoseMKUaWgSmBhmLLPSqPZQscMfpSq5iniKASqRL1Y)GfQ5sd89iY4ro7ZHBGqe6NYHb5ulRL)bluZLg47r030dKZ(C4gieH(PCyqo1YA5rLJe9s80UiKhrFtpqo7Zbc5W8CqLJwn6L8GYjyuVxGOkjaqVxpDwvsW5Gbg5ulRL)bluZLg47r030dKddYX4H2NFPiQAsPNBGqe6NYbs5Wnqic9t5GjZPwwl)dwOMlnW3JiJh5arwOgp0(yH(GfQRsdeSblZ2zhwMYcLoRkjyw8WcLJ0GqQXcTwwl)whcqGiJrF5jN95aidP3Ri6cFZB8qXr5SphJhkosqh9vcKddYbNHuRkj)whcqGiJrXsAFceiLrIfQXdTpwOpyH6Q0abBWYSDCdltzHsNvLemlEyHYrAqi1yHY8CWzi1QsY)S10PUlE6wQ3Bo7Zbc5y8qXrc4o867PbLddYXn5Gbg5y8qXrc6OVsGCWNJCWzi1QsYVziyb3aHyjTpbcKYiLdgyKJXdfhjOJ(kbYbFoYbNHuRkj)whcqGiJrXsAFceiLrkhiYc14H2hl0NTMo1DXsAFcWgSmBhmbltzHsNvLemlEyHYrAqi1yHcidP3Ri6cFZB8qXrSqnEO9XcfWBeFJnyz2o7EwMYcLoRkjyw8WcLJ0GqQXc14HIJe0rFLa5GVCCdluJhAFSqHr2BFarfrwSXgSmBNDLLPSqPZQscMfpSq5iniKASqnEO4ibD0xjqo4Zro4mKAvj5ne3osqU)iBG2xo7Z5BN5F4ro4Zro4mKAvj5ne3osqU)iBG2N4BNLZ(Ccd9sH3LgB6TdMYc14H2hludXTJeK7pYgO9XgSmBhNnwMYcLoRkjyw8Wc14H2hl0L0(eiqkJeluycWr6tO9XcLjtJTCORlVB5eg6Lca25OrokihlNxtVCIohUbICWBP9jqGugPCmqolvkjuo6bcYGZPx5G3kIQMu6zHYrAqi1yHA8qXrc6OVsGCWNJCWzi1QsYVziyb3aHyjTpbcKYiXgSmBhNjwMYc14H2hl0LIOQjLSqPZQscMfpSbBWcL3)AbeAFINndqSmLLz7WYuwO0zvjbZIhwO9dluafSqnEO9XcfNHuRkjwOWeGJ0Nq7JfQZmi0VfuoBTRCK99Md(7FTacTVCCPszosde5eB2XiiNOZbA5YHjxVxidYbpsca07nNOZbMcc91JYzRDLdERikh8inqaYbS1fjCovkNcGG9SqXzYcXcTwwlpV)1ci0(8i6B6bYbs5ulRLN3)AbeAFE4cYcTVCWK5aHC4DlHBxNN3)AbeAFEe9n9a5WGCQL1YZ7FTacTppI(MEGCGil0cGe9AjE5WSmBhwO4mK4SpXcLCpOdMGf8(xlGq7tGOVPhGfAbqcxBQKeCde69YYSDydwM5gwMYcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSqHjahPpH2hluNfmmiNyJYbUGSq7lNELtSr5aTC5WKR3lKb5Ghjba69Md(7FTacTVCIoNyJYHo4C6voXgLdVGq0f5G)(xlGq7lhDLtSr5WnqKJRUiHZbegkYbUG07nNytb5G)(xlGq7ZZcTFyHAWWSq5iniKASqrLJwn6L8GYjyuVxGOkjaqVxpDwvsW5SphiKtTSwEq5emQ3lquLeaO3Rargmw(YtoyGro4mKAvj5j3d6GjybV)1ci0(ei6B6bYbF58YH9i6B6bYbs5SJFxZbtMZlh2)n3ZbtMdeYPwwlpOCcg17fiQsca071)n3fGW4mMJBNtTSwEq5emQ3lquLeaO3RhegNXCGyoqKfkotwiwO4mKAvj5bmwfWfKfAFSqlas0RL4LdZYSDyHA8q7JfkodPwvsSqXziXzFIfk5Eqhmbl49VwaH2NarFtpaBWYmmbltzHsNvLemlEyHctaosFcTpwO4LXgHYH3TeUDDGCInlYbS1fjCovkNcGGZXLgB5G)(xlGq7lhWwxKW50NeRCQuofabNJln2YXUCmEumzo4V)1ci0(YHBGih7GZ56ihxASLJLd0YLdtUEVqgKdEKeaO3BopOM7zHA8q7Jfk3KsHXdTpHubbluqGuEWYSDyHYrAqi1yHIZqQvLKNCpOdMGf8(xlGq7tGOVPhih8LdodPwvsEaJvbCbzH2hluPccXzFIfkV)1ci0(e8ULWTRdWgSmB3ZYuwO0zvjbZIhwOgp0(yHYnPuy8q7tivqWcvQGqC2NyHA8qXrIWK0fa2GLz7kltzHsNvLemlEyHA8q7Jfk3oojf1YAXcLJ0GqQXcTwwlpV)1ci0(8WTRlN95ulRLhuobJ69cevjba696bHXzmh8LJBYzFoHjPl8OYrIEjEAxeYtNvLeCo7ZH3TeUDDEu5irVepTlc5r030dKddYXnykl0AzTeN9jwOGYjyuVxGOkjaqVxwOWeGJ0Nq7JfQZBLd0YLdtUEVqgKdEKeaO3BoGW4mcYXquoB67g25WTJtYCIn6NtLwnIYb)9VwaH2xoGoNyZICInkhOLlhMC9EHmih8ijaqV3CEqnphUD5uPCa2IKyLdmjnSi4CkxOYCSvqOCWF)RfqO9LJln26sKdsbmMtVYHC)rrwO95zdwM5SXYuwO0zvjbZIhwOgp0(yHUK2NabszKyHctaosFcTpwOoVvo4V)1ci0(Yrb5a3UoSZ5brCde5a6pfB69MtLwnIYX4HIZc9EZrdpluosdcPgl0AzT88(xlGq7Zd3UUC2NdVBjC7688(xlGq7ZJOVPhihgKd3aHi0pLZ(CmEO4ibD0xjqo4Zro4mKAvj559VwaH2NyjTpbcKYiXgSmZzILPSqPZQscMfpSq5iniKASqRL1YZ7FTacTppC76YzFo1YA5bLtWOEVarvsaGEVcezWy5lp5SpNAzT8GYjyuVxGOkjaqVxbImyS8i6B6bYbF5Wnqic9tSqnEO9Xc9bluxLgiydwM58ZYuwO0zvjbZIhwOCKgesnwO1YA559VwaH2NhUDD5SpNAzT8pyHAU0aFpImEKZ(CQL1Y)GfQ5sd89i6B6bYbF5Wnqic9tSqnEO9Xc9bluxLgiydwMT7YYuwO0zvjbZIhwOCKgesnwO1YA559VwaH2NhUDD5SphE3s421559VwaH2NhrFtpqomihUbcrOFkN95W8C49bx0WVK2NegNJOq7ZtNvLemluJhAFSqxkIQMuYgSmBhmLLPSqPZQscMfpSq5iniKASqRL1YZ7FTacTppC76YzFo8ULWTRZZ7FTacTppI(MEGCyqoCdeIq)eluJhAFSqb8gX3ydwMTZoSmLfkDwvsWS4HfAbqcxBQKeCde69YYSDyHYrAqi1yHU1HaeiYyuaEiPei0tSK67wKJJCW0C2NtTSwEE)RfqO95HBxxo7ZbNHuRkjFOFseTG3)AbeAF5Wah5GP5SphiKdZZbvoA1OxYdRaU(i1Zqyj49)BhSNoRkj4CWaJCQL1YdRaU(i1Zqyj49)BhSV8KdgyKtTSwEyfW1hPEgclbV)F7GfludcF5jN95eMKUWJkhj6L4PDripDwvsW5SphE3s4215RL1saRaU(i1Zqyj49)BhShrgmw5aXC2NdeYH55GkhTA0l5FrkqILq5kxsE6SQKGZbdmYbMQL1Y)IuGelHYvUK8LNCGyo7Zbc5W8C4no6Sl8hXrTSrW5Gbg5W7wc3UopmzXwTrh5r030dKdgyKtTSwEyYITAJoYxEYbI5SphiKdZZH34OZUWJJUydluoyGro8ULWTRZ)veQrarVerJ(0fEe9n9a5aXC2NdeYX4H2N)tb1iVEILuF3IC2NJXdTp)NcQrE9elP(Ufce9n9a5Wah5GZqQvLKN3)AbeAFcUbcbI(MEGCWaJCmEO95b8gX38K7eVe69MZ(CmEO95b8gX38K7eVeKarFtpqomihCgsTQK88(xlGq7tWnqiq030dKdgyKJXdTp)sru1Ksp5oXlHEV5SphJhAF(LIOQjLEYDIxcsGOVPhihgKdodPwvsEE)RfqO9j4giei6B6bYbdmYX4H2N)bluxLgi8K7eVe69MZ(CmEO95FWc1vPbcp5oXlbjq030dKddYbNHuRkjpV)1ci0(eCdece9n9a5Gbg5y8q7ZVK2NabszK8K7eVe69MZ(CmEO95xs7tGaPmsEYDIxcsGOVPhihgKdodPwvsEE)RfqO9j4giei6B6bYbISqlas0RL4LdZYSDyHA8q7JfkV)1ci0(yHctaosFcTpwO4V)1ci0(YbS1fjCovkNcGGZX1gD5eBuopiIBGihfKJj)niYzPNc2iypBWYSDCdltzHsNvLemlEyHwaKW1Mkjb3aHEVSmBhwOCKgesnwOmphEFWfn86Ti0zsb3aCdM80zvjbNZ(CyEo4mKAvj5xkIevPbcXt3s9EZzFo1YA559VwaH2NV8KZ(CyEo1YA5xkIarJ(Eez8iN95W8CQL1YV1HaeiYy0JiJh5SpNToeGargJcWdjLaHEILuF3ICGuo1YA53il07vuE8iY4royYCGqoVCypI(MEGCWxoyAoqmhgKJByHwaKOxlXlhMLz7Wc14H2hl0LIirvAGGfkmb4i9j0(yHYKPXwxICCE3IqNjZb)gGBWe25WKUaICkakh8wruo4rAGaKJRn6Yj2iSYXvFqoY5xo(woCKgGCSdohxB0LdERicen6NJcYbUDDE2GLz7Gjyzklu6SQKGzXdl0cGeU2ujj4gi07LLz7Wc14H2hluCgsTQKyH2pSqbuWcLJ0GqQXcL34OZUWF67wiwgXcTairVwIxomlZ2HfkotwiwOlfrGWqbH8i6B6bYHb5GZqQvLKNCpOdMGf8(xlGq7tGOVPhiN95aHC49bx0WR3IqNjfCdWnyYtNvLeCo7ZbNHuRkjp5(dXdcwSuejQsdeGCyqo4mKAvj5pIGjyXsrKOknqaYbI5SphiKdZZjmjDHhvos0lXt7IqE6SQKGZbdmYH3TeUDDEu5irVepTlc5r030dKd(YbNHuRkjp5Eqhmbl49VwaH2NarFtpqoqmhmWihJhkosqh9vcKd(CKdodPwvsEE)RfqO9jaB6k07v80UieluycWr6tO9XcD3cOCGUPRqV3C2L2fHYbUG07nh83)AbeAF54AJUCIncr5yikNRJCORlVB5G3kIYbpsdeGCmCMkTQKYj6CwfPeRCi3d6GZrVfHotMd3aCdMYXo4C6tIvoU2OlNDt5OC6vo7s7Iq5OGC6lhE3s4215zHIZqIZ(el0cGeGnDf69kEAxeInyz2o7EwMYcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSq5iniKASq59bx0WR3IqNjfCdWnykN95W8CWzi1QsYVuejQsdeINUL69MZ(CGqo4mKAvj5j3FiEqWILIirvAGaKd(CKdodPwvs(JiycwSuejQsdeGCWaJCQL1YZ7FTacTppI(MEGCyqoVCy)3CphmWihCgsTQK8K7bDWeSG3)AbeAFce9n9a5Wah5ulRLxVfHotk4gGBWKhUGSq7lhmWiNAzT86Ti0zsb3aCdM8GW4mMddYXn5Gbg5ulRLxVfHotk4gGBWKhrFtpqomiNxoS)BUNdgyKdVBjC768GnDf69kEAxeYJidgRC2NdodPwvs(cGeGnDf69kEAxekhiMZ(CQL1YZ7FTacTpF5jN95aHCyEo1YA5xkIarJ(Eez8ihmWiNAzT86Ti0zsb3aCdM8i6B6bYHb5GP(DnhiMZ(CyEo1YA536qacezm6rKXJC2NZwhcqGiJrb4HKsGqpXsQVBroqkNAzT8BKf69kkpEez8ihmzoqiNxoShrFtpqo4lhmnhiMddYXnSqlas0RL4LdZYSDyHA8q7Jf6srKOknqWgSmBNDLLPSqPZQscMfpSqnEO9XcDjTpbcKYiXcfMaCK(eAFSqH(qhCo4fDKd0argJGCGli9EZb)9VwaH2xowKZM(ULZdsBKgy5zHYrAqi1yHcHCQL1YV1HaeiYy0xEYzFogpuCKGo6Reih85ihCgsTQK88(xlGq7tSK2NabszKYbI5Gbg5aHCQL1YVuebIg99LNC2NJXdfhjOJ(kbYbFoYbNHuRkjpV)1ci0(elP9jqGugPCC7CqLJwn6L8lfrGOrFpDwvsW5ar2GLz74SXYuwO0zvjbZIhwOgp0(yHImy1UqaEmeJSqHjahPpH2hl0DJbR2f5a9XqmMdyRls4CQuofabNJln2YXYbVOJCGgiYymhezWyLt05uauo6)tWQfKeRCSvqOCInkhUbICw6PGnc4ZHPBkihxQuMZzrbzsjw5aOiNYtowo4fDKd0argJ5aEOlYz1OCInkNLEMmhqyCgZPx5SBmy1UihOpgIrpluosdcPgl0AzT88(xlGq7ZxEYzFoUjhmzo1YA536qacezm6rKXJCGuo1YA53il07vuE8iY4roqkNToeGargJcWdjLaHEILuF3ICCKJBydwMTJZeltzHsNvLemlEyHYrAqi1yHwlRLFPicen67lpSqnEO9Xc9bluxLgiydwMTJZpltzHsNvLemlEyHYrAqi1yHwlRLFRdbiqKXOV8KZ(CQL1YZ7FTacTpF5HfQXdTpwOpyH6Q0abBWYSD2Dzzklu6SQKGzXdluosdcPgl0heHt8YH974b8gX3YzFo1YA53il07vuE8LNC2NJXdfhjOJ(kbYHb5GZqQvLKN3)AbeAFIL0(eiqkJuo7ZPwwlpV)1ci0(8LhwOgp0(yH(GfQRsdeSblZCdMYYuwO0zvjbZIhwOgp0(yHc20vO3R4PDriwOWeGJ0Nq7Jf6UfO3Boq30vO3Bo7s7Iq5axq69Md(7FTacTVCIohebIgr5G3kIYbpsde5yhCo7YwtN6Eo4T0(uo8nd9sGC42LtLYPshTuUAsSZPwICkGIjLyLtFsSYPVCCwTZSNfkhPbHuJfkodPwvs(cGeGnDf69kEAxekN95ulRLN3)AbeAF(Yto7ZH55y8q7ZVuejQsdeE(MHEjqo7ZX4H2N)zRPtDxSK2NaE(MHEjqomihJhAF(NTMo1DXsAFc4)M7c(MHEjaBWYm3SdltzHsNvLemlEyHA8q7JfkQCKOxIN2fHyHctaosFcTpwOqlxom569czqo4rsaGEV58GAoiN(Yj2ifLt76YbS1fjCovkhysAyrW5SAuo7cwOMlnWpNhuZb54AJUCEAaqRsc7CQLiNo2iKlfq5WTlNkLtbqW5Oxo4V)1ci0(YX1gD5eBeIYXquoGYAPCLUih8wruo4rAGa4ZX5TYXYbA5YHjxVxidYbpsca07nNhuZZXvxKW5uPCkacg7C2nLJYPx5SlTlcLdyRls4CQuofabNZsrGihDLtSr5qURGqV3C2nLJYPx5SlTlcLJlvkZHC)rruoWfKEV5eBuoCdeEwOCKgesnwO1YA5bLtWOEVarvsaGEVcezWy5lp5SphiKdodPwvs(JiycwSuejQsdeGCyGJCWzi1QsYtU)q8GGflfrIQ0abihmWihyQwwl)xrOgbe9sen6tx4lp5aXC2NJXdfhjOJ(kbYbFoYbNHuRkjpV)1ci0(elP9jqGugPC2NtTSwEq5emQ3lquLeaO3RargmwEe9n9a5GVCi3jEjirOFkhiLJXdTp)sAFceiLrYZnqic9tSblZCJByzklu6SQKGzXdluosdcPgl0AzT8GYjyuVxGOkjaqVxbImyS8LNC2NdeYbNHuRkj)remblwkIevPbcqomWro4mKAvj5j3FiEqWILIirvAGaKdgyKdmvlRL)RiuJaIEjIg9Pl8LNCGyo7ZX4HIJe0rFLa5Gph5GZqQvLKN3)AbeAFIL0(eiqkJuo7ZPwwlpOCcg17fiQsca07vGidglpI(MEGCWxoCdeIq)uo7Zbc5W8C49bx0WR3IqNjfCdWnyYtNvLeCoyGro1YA51BrOZKcUb4gm5r030dKd(YHCN4LGeH(PCWaJCQL1YVrwO3RO84rKXJCGuoBDiabImgfGhskbc9elP(Uf5WGCCtoqKfQXdTpwOlP9jqGugj2GLzUbtWYuwO0zvjbZIhwOCKgesnwO1YA5bLtWOEVarvsaGEVcezWy5lp5SphiKdZZjmjDH)bluZLg47PZQscohmWiNAzT8pyHAU0aFpImEKZ(CQL1Y)GfQ5sd89i6B6bYbF5qUt8sqIq)uoqkhJhAF(hSqDvAGWZnqic9t5Gbg5GZqQvLK)icMGflfrIQ0abihg4ihCgsTQK8K7pepiyXsrKOknqaYbdmYbMQL1Y)veQrarVerJ(0f(YtoqmN95ulRLhuobJ69cevjba69kqKbJLhrFtpqo4lhYDIxcse6NYbs5y8q7Z)GfQRsdeEUbcrOFIfQXdTpwOOYrIEjEAxeInyzMB29SmLfkDwvsWS4HfkhPbHuJfATSwEq5emQ3lquLeaO3Rargmw(Yto7Zbc5W8Cctsx4FWc1CPb(E6SQKGZbdmYPwwl)dwOMlnW3JiJh5SpNAzT8pyHAU0aFpI(MEGCWxoCdeIq)uoyGro4mKAvj5pIGjyXsrKOknqaYHboYbNHuRkjp5(dXdcwSuejQsdeGCWaJCGPAzT8FfHAeq0lr0OpDHV8KdeZzFo1YA5bLtWOEVarvsaGEVcezWy5r030dKd(YHBGqe6NYzFoqihMNdVp4IgE9we6mPGBaUbtE6SQKGZbdmYPwwlVElcDMuWna3GjpI(MEGCWxoK7eVeKi0pLdgyKtTSw(nYc9EfLhpImEKdKYzRdbiqKXOa8qsjqONyj13TihgKJBYbISqnEO9Xc9bluxLgiydwM5MDLLPSqPZQscMfpSqnEO9Xc9bluxLgiyHctaosFcTpwO7cwOMlnWpNhuZb5a26IeoNkLtbqW5Oxo4V)1ci0(YXIC203ncLZdsBKgyLtSzxo7YwtN6Eo4T0(eih7GZbkVr8npluosdcPgl0AzT8pyHAU0aFpImEKZ(CQL1Y)GfQ5sd89i6B6bYbF5Wnqic9t5SpNAzT88(xlGq7ZJOVPhih8Ld3aHi0pLZ(CmEO4ibD0xjqomihCgsTQK88(xlGq7tSK2NabszKYzFoqihMNdVp4IgE9we6mPGBaUbtE6SQKGZbdmYPwwlVElcDMuWna3GjpI(MEGCWxoK7eVeKi0pLdgyKtTSw(nYc9EfLhpImEKdKYzRdbiqKXOa8qsjqONyj13TihgKJBYbISblZCJZgltzHsNvLemlEyHA8q7Jf6ZwtN6UyjTpbyHctaosFcTpwO7waLZUS10PUNdElTpbYXo4CGYBeFlh9Yb)9VwaH2xorNZgjFY5LoczbLdErh5anqKXiihxB0LdERikh8inqaYXquoxh5y4mvAvjLtJY5icoNOZPs5W7dqiCeSNfkhPbHuJfATSwEE)RfqO95lp5SpNaz4iPi0pLddYPwwlpV)1ci0(8i6B6bYzFo1YA53il07vuE8iY4roqkNToeGargJcWdjLaHEILuF3ICyqoUHnyzMBCMyzklu6SQKGzXdluosdcPgl0AzT88(xlGq7ZJOVPhih8Ld3aHi0pXc14H2hluaVr8n2GLzUX5NLPSqPZQscMfpSqnEO9XcvQ407vu7FLfkmb4i9j0(yH68w5eBeIYrbhKJCORlVB5e6NYrsRih9Yb)9VwaH2xoRgLJLZUS10PUNdElTpbYPr5aL3i(worNZMg5OhqHPC6vo4V)1ci0(WoNcGYb0Fk207nhscipluosdcPgl0AzT88(xlGq7ZJOVPhihgKZlh2)n3ZzFogpuCKGo6Reih8LZoSblZCZUlltzHsNvLemlEyHYrAqi1yHwlRLN3)AbeAFEe9n9a5WGCE5W(V5Eo7ZPwwlpV)1ci0(8LhwOgp0(yHcJS3(aIkISyJnydwOgpuCKimjDbGLPSmBhwMYcLoRkjyw8WcLJ0GqQXc14HIJe0rFLa5GVC2jN95ulRLN3)AbeAFE421LZ(CGqo4mKAvj5d9tIOf8(xlGq7lh8LdVBjC768sfNEVIA)RE4cYcTVCWaJCWzi1QsYh6Nerl49VwaH2xomWroyAoqKfQXdTpwOsfNEVIA)RSblZCdltzHsNvLemlEyHYrAqi1yHIZqQvLKp0pjIwW7FTacTVCyGJCW0CWaJCQL1YZ7FTacTppI(MEGCWxobYWrsrOFkhmWihiKdVBjC768FkOg5Hlil0(YHb5GZqQvLKp0pjIwW7FTacTVC2NdZZjmjDHhvos0lXt7IqE6SQKGZbI5Gbg5eMKUWJkhj6L4PDripDwvsW5SpNAzT8OYrIEjEAxeYxEYzFo4mKAvj5d9tIOf8(xlGq7lh8LJXdTp)NcQrEE3s421LdgyKZsF3cbI(MEGCyqo4mKAvj5d9tIOf8(xlGq7JfQXdTpwOFkOgXgSmdtWYuwO0zvjbZIhwOCKgesnwOHjPl8MKCheidWKIbeRcclpDwvsW5SphiKtTSwEE)RfqO95HBxxo7ZH55ulRLFRdbiqKXOV8KdezHA8q7JfkmYE7diQiYIn2GnyHcc7GneSa1HfAFSmLLz7WYuwO0zvjbZIhwOCKgesnwOgpuCKGo6Reih85ihCgsTQK8BDiabImgflP9jqGugPC2NdeYPwwl)whcqGiJrF5jhmWiNAzT8lfrGOrFF5jhiYc14H2hl0L0(eiqkJeBWYm3WYuwO0zvjbZIhwOCKgesnwO1YA5Hjl2Qn6iF5jN95GkhTA0l5Hjl2aILfB93tNvLeCo7ZbNHuRkjFOFseTG3)AbeAF5WGCQL1YdtwSvB0rEe9n9a5SphJhkosqh9vcKd(CKJByHA8q7Jf6sru1Ks2GLzycwMYcLoRkjyw8WcLJ0GqQXcTwwl)sreiA03xEyHA8q7Jf6dwOUknqWgSmB3ZYuwO0zvjbZIhwOCKgesnwO1YA536qacezm6lp5SpNAzT8BDiabImg9i6B6bYHb5y8q7ZVuevnP0tUt8sqIq)eluJhAFSqFWc1vPbc2GLz7kltzHsNvLemlEyHYrAqi1yHwlRLFRdbiqKXOV8KZ(CGqopicN4Ld73XVuevnPmhmWiNLIiqyOGqEJhkokhmWihJhAF(hSqDvAGWRNyj13TihiYc14H2hl0hSqDvAGGnyzMZgltzHsNvLemlEyHA8q7Jf6sAFceiLrIfkmb4i9j0(yHYuew5eDoVuKduMC8KZdQ5GC0dOWuo7MExY5zZaeiNgLd(7FTacTVCE2mabYX1gD580aGwLKNfkhPbHuJfQXdfhjOJ(kbYbFoYbNHuRkj)MHGfCdeIL0(eiqkJuo7ZPwwlpOCcg17fiQsca07vGidglF5jN95aHC4DlHBxNhvos0lXt7IqEe9n9a5aPCmEO95rLJe9s80UiKNCN4LGeH(PCGuoCdeIq)uo4lNAzT8GYjyuVxGOkjaqVxbImyS8i6B6bYbdmYH55eMKUWJkhj6L4PDripDwvsW5aXC2NdodPwvs(q)KiAbV)1ci0(Ybs5Wnqic9t5GVCQL1YdkNGr9EbIQKaa9EfiYGXYJOVPhGnyzMZeltzHsNvLemlEyHYrAqi1yHwlRLFRdbiqKXOV8KZ(CaKH07veDHV5nEO4iwOgp0(yH(GfQRsdeSblZC(zzklu6SQKGzXdluosdcPgl0AzT8pyHAU0aFpImEKZ(C4gieH(PCyqo1YA5FWc1CPb(Ee9n9a5SphiKdZZbvoA1OxYdkNGr9EbIQKaa9E90zvjbNdgyKtTSw(hSqnxAGVhrFtpqomihJhAF(LIOQjLEUbcrOFkhiLd3aHi0pLdMmNAzT8pyHAU0aFpImEKdezHA8q7Jf6dwOUknqWgSmB3LLPSqPZQscMfpSqlas4AtLKGBGqVxwMTdluosdcPgluMNZsreimuqiVXdfhLZ(CyEo4mKAvj5xkIevPbcXt3s9EZzFo1YA5bLtWOEVarvsaGEVcezWy5HBxxo7Zbc5aHCGqogp0(8lfrvtk9K7eVe69MZ(CGqogp0(8lfrvtk9K7eVeKarFtpqomihm1VR5Gbg5W8CqLJwn6L8lfrGOrFpDwvsW5aXCWaJCmEO95FWc1vPbcp5oXlHEV5SphiKJXdTp)dwOUknq4j3jEjibI(MEGCyqoyQFxZbdmYH55GkhTA0l5xkIarJ(E6SQKGZbI5aXC2NtTSw(nYc9EfLhpImEKdeZbdmYbc5aidP3Ri6cFZB8qXr5SphiKtTSw(nYc9EfLhpImEKZ(CyEogp0(8aEJ4BEYDIxc9EZbdmYH55ulRLFRdbiqKXOhrgpYzFompNAzT8BKf69kkpEez8iN95y8q7Zd4nIV5j3jEj07nN95W8C26qacezmkapKuce6jws9DlYbI5aXCGil0cGe9AjE5WSmBhwOgp0(yHUuejQsdeSqHjahPpH2hluNrbP3BoXgLdiSd2qW5G6WcTpSZPpjw5uauo4TIOCWJ0abihxB0LtSryLJHOCUoYPs69MZt3scoNvJYz307sonkh83)AbeAF(C2Takh8wruo4rAGihsJncLdCbP3Bowo4TIOQjLmCxWc1vPbIC4giYX1gD5GxqwO3Bo72NCuqogpuCuonkh4csV3Ci3jEjOCCPXwoqjdP3BomTl8npBWYSDWuwMYcLoRkjyw8WcLJ0GqQXcTwwl)whcqGiJrF5jN95y8qXrc6OVsGCyqo4mKAvj536qacezmkws7tGaPmsSqnEO9Xc9bluxLgiydwMTZoSmLfkDwvsWS4HfkhPbHuJfkZZbNHuRkj)ZwtN6U4PBPEV5SphiKdZZjmjDHFH6Vi2iHb2iGNoRkj4CWaJCmEO4ibD0xjqo4lNDYbI5SphiKJXdfhjG7WRVNguomih3KdgyKJXdfhjOJ(kbYbFoYbNHuRkj)MHGfCdeIL0(eiqkJuoyGrogpuCKGo6Reih85ihCgsTQK8BDiabImgflP9jqGugPCGiluJhAFSqF2A6u3flP9jaBWYSDCdltzHsNvLemlEyHA8q7Jfk3KsHXdTpHubbluPccXzFIfQXdfhjctsxaydwMTdMGLPSqPZQscMfpSq5iniKASqnEO4ibD0xjqo4lNDyHA8q7JfkmYE7diQiYIn2GLz7S7zzklu6SQKGzXdluosdcPgluazi9Efrx4BEJhkoIfQXdTpwOaEJ4BSblZ2zxzzklu6SQKGzXdluosdcPgluJhkosqh9vcKd(CKdodPwvsEdXTJeK7pYgO9LZ(C(2z(hEKd(CKdodPwvsEdXTJeK7pYgO9j(2z5SpNWqVu4DPXME7GPSqnEO9Xc1qC7ib5(JSbAFSblZ2XzJLPSqPZQscMfpSqnEO9XcDjTpbcKYiXcfMaCK(eAFSqzY0ylh66Y7woHHEPaGDoAKJcYXY510lNOZHBGih8wAFceiLrkhdKZsLscLJEGGm4C6vo4TIOQjLEwOCKgesnwOgpuCKGo6Reih85ihCgsTQK8BgcwWnqiws7tGaPmsSblZ2XzILPSqnEO9XcDPiQAsjlu6SQKGzXdBWgSq59VwaH2NG3TeUDDawMYYSDyzkluJhAFSqF6q7JfkDwvsWS4HnyzMByzkluJhAFSqRYUHfRcclwO0zvjbZIh2GLzycwMYcLoRkjyw8WcLJ0GqQXcTwwlpV)1ci0(8LhwOgp0(yHwjeGqmQ3lBWYSDpltzHA8q7Jf6sruv2nmlu6SQKGzXdBWYSDLLPSqnEO9Xc1oobcKjfCtkzHsNvLemlEydwM5SXYuwO0zvjbZIhwOCKgesnwOOYrRg9s(G(pnYKcxg6XtNvLeCo7ZPwwlp5(MvaH2NV8Wc14H2hl0q)KWLHEydwM5mXYuwO0zvjbZIhwOgp0(yH(kny1Igbevd(LyHsRfXdXzFIf6R0GvlAequn4xInyzMZpltzHsNvLemlEyHE2NyHQhGJkHvLKaVwSlkFbmHt5eluJhAFSq1dWrLWQssGxl2fLVaMWPCInyz2UlltzHsNvLemlEyHE2NyHUK2Ne9suTiKeluJhAFSqxs7tIEjQwesInyz2oykltzHsNvLemlEyHE2NyH6YyKocbeluFWSqnEO9Xc1LXiDeciwO(GzdwMTZoSmLfkDwvsWS4Hf6zFIfQEGav4rJacyfNEKOssjluJhAFSq1deOcpAeqaR40JevskzdwMTJByzklu6SQKGzXdl0Z(eluq5QYUHf2NInSabluJhAFSqbLRk7gwyFk2WceSblZ2btWYuwOgp0(yHwaKqd6dyHsNvLemlEyd2GnyHIJqaTpwM5gm1n7SZoy6oSqDzOtVxaluMmN1UHzopMT74C5Kdt3OC0)tJICwnkhiJ6hXZMbiiNdIWRffrW5a6pLJvI(BbbNdFZUxc4tNCl9OCCJZLd(7dhHccohiJkhTA0l5zciNt05azu5OvJEjpt4PZQscgY5aHDChI(0j3spkhNjNlh83hocfeCoqomjDHNjGCorNdKdtsx4zcpDwvsWqohiSJ7q0No5w6r5487C5G)(WrOGGZbYOYrRg9sEMaY5eDoqgvoA1OxYZeE6SQKGHCoqWnUdrF6KBPhLZoyQZLd(7dhHccohiJkhTA0l5zciNt05azu5OvJEjpt4PZQscgY5aHDChI(0P0jMmN1UHzopMT74C5Kdt3OC0)tJICwnkhidtlRidiNdIWRffrW5a6pLJvI(BbbNdFZUxc4tNCl9OC2X5Yb)9HJqbbNdKrLJwn6L8mbKZj6CGmQC0QrVKNj80zvjbd5CSihNz8s3khiSJ7q0No5w6r5S7DUCWFF4iuqW5azu5OvJEjpta5CIohiJkhTA0l5zcpDwvsWqohlYXzgV0TYbc74oe9PtULEuooBoxo4VpCeki4CGmQC0QrVKNjGCorNdKrLJwn6L8mHNoRkjyiNJf54mJx6w5aHDChI(0j3spkNDWeoxo4VpCeki4CGQF8NdaRlm3ZX5Z5lNOZXTkwo)gUilGC6hczrJYbcoFqmhiSJ7q0No5w6r5SdMW5Yb)9HJqbbNdK59bx0WZeqoNOZbY8(GlA4zcpDwvsWqohiSJ7q0No5w6r5SZU35Yb)9HJqbbNdKdKEmsHFhpta5CIohihi9yKcFSJNjGCoqat4oe9PtULEuo7S7DUCWFF4iuqW5a5aPhJu4DJNjGCorNdKdKEmsHpCJNjGCoqat4oe9PtULEuo7SRoxo4VpCeki4CGmVp4IgEMaY5eDoqM3hCrdpt4PZQscgY5aHDChI(0j3spkh34gNlh83hocfeCoqgvoA1OxYZeqoNOZbYOYrRg9sEMWtNvLemKZbc74oe9PtULEuoUbt4C5G)(WrOGGZbYOYrRg9sEMaY5eDoqgvoA1OxYZeE6SQKGHCoqyh3HOpDYT0JYXn7ENlh83hocfeCoqomjDHNjGCorNdKdtsx4zcpDwvsWqohiSJ7q0No5w6r54MDVZLd(7dhHccohiJkhTA0l5zciNt05azu5OvJEjpt4PZQscgY5aHDChI(0j3spkh3SRoxo4VpCeki4CGmQC0QrVKNjGCorNdKrLJwn6L8mHNoRkjyiNde2XDi6tNCl9OCCJZMZLd(7dhHccohiJkhTA0l5zciNt05azu5OvJEjpt4PZQscgY5aHDChI(0j3spkh34m5C5G)(WrOGGZbQ(XFoaSUWCphNVCIoh3Qy5aR4uG2xo9dHSOr5abgcXCGaMWDi6tNCl9OCCJZKZLd(7dhHccohO6h)5aW6cZ9CC(C(Yj6CCRILZVHlYciN(Hqw0OCGGZheZbc74oe9PtULEuoUz315Yb)9HJqbbNdKrLJwn6L8mbKZj6CGmQC0QrVKNj80zvjbd5CGWoUdrF6KBPhLdMatDUCWFF4iuqW5azu5OvJEjpta5CIohiJkhTA0l5zcpDwvsWqohlYXzgV0TYbc74oe9PtULEuoyc34C5G)(WrOGGZbYOYrRg9sEMaY5eDoqgvoA1OxYZeE6SQKGHCoqyh3HOpDYT0JYbt4gNlh83hocfeCoqomjDHNjGCorNdKdtsx4zcpDwvsWqohiSJ7q0NoLoXK5S2nmZ5XSDhNlNCy6gLJ(FAuKZQr5a5heX7F1ciNdIWRffrW5a6pLJvI(BbbNdFZUxc4tNCl9OCCJZLd(7dhHccohihMKUWZeqoNOZbYHjPl8mHNoRkjyiNJf54mJx6w5aHDChI(0P0jMmN1UHzopMT74C5Kdt3OC0)tJICwnkhiZ7FTacTpbVBjC76aqoheHxlkIGZb0FkhRe93ccoh(MDVeWNo5w6r54S5C5G)(WrOGGZbYOYrRg9sEMaY5eDoqgvoA1OxYZeE6SQKGHCoqyh3HOpDkDIjZzTByMZJz7ooxo5W0nkh9)0OiNvJYbYgpuCKimjDbaY5Gi8ArreCoG(t5yLO)wqW5W3S7La(0j3spkh34C5G)(WrOGGZbYHjPl8mbKZj6CGCys6cpt4PZQscgY5ab34oe9PtULEuoycNlh83hocfeCoqomjDHNjGCorNdKdtsx4zcpDwvsWqohiSJ7q0NoLoXK5S2nmZ5XSDhNlNCy6gLJ(FAuKZQr5azqyhSHGfOoSq7dY5Gi8ArreCoG(t5yLO)wqW5W3S7La(0j3spkh34C5G)(WrOGGZbYOYrRg9sEMaY5eDoqgvoA1OxYZeE6SQKGHCoqyh3HOpDYT0JYXzZ5Yb)9HJqbbNdKdtsx4zciNt05a5WK0fEMWtNvLemKZbc74oe9PtULEuoo)oxo4VpCeki4CGmQC0QrVKNjGCorNdKrLJwn6L8mHNoRkjyiNde2XDi6tNCl9OC2DDUCWFF4iuqW5azu5OvJEjpta5CIohiJkhTA0l5zcpDwvsWqohi4g3HOpDYT0JYzNDCUCWFF4iuqW5a5WK0fEMaY5eDoqomjDHNj80zvjbd5CGWoUdrF6u6etMZA3WmNhZ2DCUCYHPBuo6)PrroRgLdK59VwaH2N4zZaeKZbr41IIi4Ca9NYXkr)TGGZHVz3lb8PtULEuoUX5Yb)9HJqbbNdKrLJwn6L8mbKZj6CGmQC0QrVKNj80zvjbd5CGWoUdrF6KBPhLZU6C5G)(WrOGGZbYHjPl8mbKZj6CGCys6cpt4PZQscgY5aHDChI(0j3spkNDxNlh83hocfeCoqM3hCrdpta5CIohiZ7dUOHNj80zvjbd5CSihNz8s3khiSJ7q0No5w6r5SZooxo4VpCeki4CGCys6cpta5CIohihMKUWZeE6SQKGHCoqyh3HOpDYT0JYzNDCUCWFF4iuqW5azu5OvJEjpta5CIohiJkhTA0l5zcpDwvsWqohi4g3HOpDYT0JYzh34C5G)(WrOGGZbY8(GlA4zciNt05azEFWfn8mHNoRkjyiNde2XDi6tNCl9OC2bt4C5G)(WrOGGZbYHjPl8mbKZj6CGCys6cpt4PZQscgY5aHDChI(0j3spkNDWeoxo4VpCeki4CGmVp4IgEMaY5eDoqM3hCrdpt4PZQscgY5aHDChI(0j3spkND2vNlh83hocfeCoqgvoA1OxYZeqoNOZbYOYrRg9sEMWtNvLemKZbc74oe9PtULEuoUXnoxo4VpCeki4CGmVp4IgEMaY5eDoqM3hCrdpt4PZQscgY5aHDChI(0j3spkh3GjCUCWFF4iuqW5a5WK0fEMaY5eDoqomjDHNj80zvjbd5CGWoUdrF6KBPhLJB29oxo4VpCeki4CGCys6cpta5CIohihMKUWZeE6SQKGHCoqyh3HOpDYT0JYXn7ENlh83hocfeCoqM3hCrdpta5CIohiZ7dUOHNj80zvjbd5CGWoUdrF6KBPhLJB2vNlh83hocfeCoqM3hCrdpta5CIohiZ7dUOHNj80zvjbd5CGWoUdrF6u6KZ7)0OGGZXzkhJhAF5ivqa8PtSqbpeNLzoBycwOpOEPsIfkMXCo4TIOCC2TxkDcZyoNTiEaohdz4RgBLQN3Fgc0FrAH2hhzRGHa9Zzy6eMXComRXr)kHYXnycSZXnyQB2jDkDcZyoh8Vz3lbCU0jmJ5CC7C2TakNL(Ufce9n9a5GSyJq5eB2LtyOxk8H(jr0cyLYz1OCKgiCBaX7dohRQsnWkNcWEjGpDcZyoh3oh3QBaD5WnqKdIWRffrF6cqoRgLd(7FTacTVCGG6jp25a3hKJC2AjCoAKZQr5y5SqeylhNDkOgLd3abe9PtygZ54254mFwvs5acKYJC4BeNr9EZPVCSCwKRCwnIrqo6LtSr54S2f3kNOZbrWfoLJRgXOSnyF6eMXCoUDoolyM0fqKJLZUGfQRsde5qxGWkNyZICGBcKZ1ro)gMK54IKYC0ZTFTpLdea6pNGabbNJf5CDoa990LYTlYXzSlqZr)pgpGOpDcZyoh3oh83hocf5yszo1YA5zcpImEKdDbsjqorNtTSwEMWxEWoh7YXK)ge5OhqFpDPC7ICCg7c0CEn9YrVCa6h4tNWmMZXTZz3cOC2memVHj4CWzi1QscKt05Gi4cNYb)7YUnhxnIrzBW(0P0jmJ5CCMDN4LGGZPsRgr5W7F1ICQ0REaFooloNEcqoxFU9MH(RImhJhAFGC6tILpDY4H2hW)GiE)Rwajhm0qC7iHEbjLepsNWmMZXzTlUvomjgsTQKYbV8j0(CUCCERCauKt05y5C952mPqOohCMSqyNtSr5G)(xlGq7lhJhAF5yhCo8ULWTRdKtSzrogIYH3hiqMEeCorNtFsSYPs5uaeCoU2Olh83)AbeAF5OGCkp54sLYCUoYPs5uaeCoWfKEV5eBuoa9xKwO95tNWCogp0(a(heX7F1ci5GH4mKAvjH9zFYbScSQKe8(xlGq7d7(XbIauKoHzmNJZAxCRCysmKAvjLdE5tO95C5W0nfKdodPwvs5aEiUUucKJRnk2iuo4V)1ci0(YbS1fjCovkNcGGZbUG07nh8wreimuqiF6eMZX4H2hW)GiE)RwajhmeNHuRkjSp7towkIaHHccj49VwaH2h2W0YkYWHBVd24mzHCW8WK0f(hSqnxAGp26YbodPwvs(LIiqyOGqcE)RfqO9XamnDcZyohN1U4w5WKyi1Qskh8YNq7Z5YHPBkihCgsTQKYb8qCDPeiNyJY5k)kHYPx5eg6LcqowKJRnLVLdErh5anqKXyo4T0(eiqkJeiNUeafMYPx5G)(xlGq7lhWwxKW5uPCkac2NoH5CmEO9b8piI3)QfqYbdXzi1Qsc7Z(KJToeGargJIL0(eiqkJe26YbodPwvs(ToeGargJIL0(eiqkJKdmfBCMSqoCdMmmjDHFjTpjESGVbPDpMK5HjPl8lP9jXJf8T0jmJ5CCw7IBLdtIHuRkPCWlFcTpNlhMUPGCWzi1QskhWdX1LsGCInkNR8RekNELtyOxka5yroU2u(wo4fgcoh8BGih8wAFceiLrcKtxcGct50RCWF)RfqO9LdyRls4CQuofabNJbYzPsjH8PtyohJhAFa)dI49VAbKCWqCgsTQKW(Sp5yZqWcUbcXsAFceiLrcBD5aNHuRkj)MHGfCdeIL0(eiqkJKdmfBCMSqoWeyYWK0f(L0(K4Xc(gKC2WKmpmjDHFjTpjESGVLoHzmNJZAxCRCysmKAvjLdE5tO95C5W0nfKdodPwvs5aEiUUucKtSr5CLFLq50RCcd9sbihlYX1MY3YbVOJCGgiYymh8wAFceiLrcKJHOCkacoh4csV3CWF)RfqO95tNWCogp0(a(heX7F1ci5GH4mKAvjH9zFYbV)1ci0(elP9jqGugjS1LdCgsTQK88(xlGq7tSK2NabszKCGPyJZKfYbMatgMKUWVK2NepwW3GKZgMK5HjPl8lP9jXJf8T0jmJ5CCw7IBLdtIHuRkPCWlFcTpNlhMUPGCWzi1QskhWdX1LsGCInkNR8RekNELtyOxka5yroU2u(woole3okhNz3FKnq7lNUeafMYPx5G)(xlGq7lhWwxKW5uPCkac2NoH5CmEO9b8piI3)QfqYbdXzi1Qsc7Z(KddXTJeK7pYgO9HTUCGZqQvLK3qC7ib5(JSbAFoWuSXzYc5y3D3ftgMKUWVK2NepwW3GKBWKmpmjDHFjTpjESGVLoHzmNJZAxCRCysmKAvjLdE5tO95C5W0nfKdodPwvs5aEiUUucKtSr58qioDH9s50RC(2z5ujz7khxBkFlhNfIBhLJZS7pYgO9LJlvkZ56iNkLtbqW(0jmNJXdTpG)br8(xTasoyiodPwvsyF2NCyiUDKGC)r2aTpX3odByAzfz4y3JPy3poqeGI0jmJ5CCw7IBLdtIHuRkPCWlFcTpNlhMUr5CLFLq50RCcd9sbihlYX1MY3Yb6MUc9EZzxAxekhUD5uaeCoWfKEV5G)(xlGq7ZNoH5CmEO9b8piI3)QfqYbdXzi1Qsc7Z(KdE)RfqO9jaB6k07v80Uie26YbodPwvsEE)RfqO9jaB6k07v80UiKdmfBCMSqoWzi1QsYZ7FTacTpXsAFceiLrkDcZyohN1U4w5WKyi1Qskh8YNq7Z5YHPBuoH(PCq030tV3C6lhlhUbICCTrxo4V)1ci0(YHBxovkNcGGZrVCaeVpyGpDcZ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh8(xlGq7tWnqiq030dGnmTSImCGPENjS7hhicqr6eMXCooRDXTYHjXqQvLuo4LpH2NZLdt3uqo4mKAvjLd4H46sjqoXgLZv(vcLtVYbq8(Gb50RCWBfr5GhPbICInlYbS1fjCovkNNULeCopgiYj2OCGPLvKro2Vlx4tNWCogp0(a(heX7F1ci5GH4mKAvjH9zFYrJJqpDlflfrIQ0abaByAzfz4atXUFCGiafPtygZ54S2f3khMedPwvs5Gx(eAFoxo4fTRCK99MtLwnIYb)9VwaH2xoGTUiHZXz()GfImzo4Li4ZooLtLYPaiyMutNWCogp0(a(heX7F1ci5GH4mKAvjH9zFYb9FWcrMu0i4ZoojGjPHf2W0YkYWXoo)y3poqeGI0jmJ5CCERCWF)RfqO9LJcYbwbwvsWyNdGVrWfjLtSr5SueiYb)9VwaH2xoldLJTccLtSr5S03Tih6Gb(0jmNJXdTpG)br8(xTasoyiodPwvsyF2NCe6Nerl49VwaH2h24mzHCS03TqGOVPhas7GPyk26YbodPwvsEyfyvjj49VwaH2x6eMXComDJYbUGSq7lNELJLd0YLdtUEVqgKdEKeaO3Bo4V)1ci0(8PtyohJhAFa)dI49VAbKCWqCgsTQKW(Sp5aWyvaxqwO9HnotwihWvUNwlIhENF348V7DdM6RgGe4mzHsNWComDJY5k)kHYPx5aiEFWGC6vo4TIOCWJ0aroiIVzOxcoNkw54SRiuJa50RCyAJ(0f(0jmNJXdTpG)br8(xTasoyiodPwvsyF2NC87qGi(MHEjH97YfyJZKfYbCL7P1I4H353zAh34mT79vdqcCMSqPtygZ5WKTrXgHYXYPaSQKYrd6NtbqW5eDo1YALd(7FTacTVCuqoeETOppeSpDcZ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh8(xlGq7t0NOaiSXzYc5GWRf95HG9VsdwTOrar1GFjmWGWRf95HG9FJBvejaBefIFbOCmWGWRf95HG96b4OsyvjjWRf7IYxat4uoHbgeETOppeShuUQSByH9PydlqGbgeETOppeSN(pyHitkAe8zhNWadcVw0Nhc2VK2Ne9suTiKegyq41I(8qWExgJ0riGyH6dgdmi8ArFEiyVEGav4rJacyfNEKOssjgyq41I(8qWEWMb3UiyrJQIEjIg9PlsNWmMZbVODLJSV3CQ0Qruo4V)1ci0(YbS1fjCobspgPaKtSzrobsFFjuowoGndrW5WTGEBew5W7wc3UUC6lNo2iuobspgPaKZ1rovkNcGGzsnDcZ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh9jkasWlrVwyJZKfYHBWuS1LdCgsTQK88(xlGq7t0NOaO0jmNJXdTpG)br8(xTasoyiodPwvsyF2NC0NOaibVe9AHnotwihUzxXwxoi8ArFEiy)34wfrcWgrH4xakpDcZ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh9jkasWlrVwyJZKfYHBWuiHZqQvLKN(pyHitkAe8zhNeWK0WcBD5GWRf95HG90)blezsrJGp74u6KXdTpG)br8(xTasoyybqcnOp2N9jhGUif67PbHWwxoyoodPwvsEE)RfqO9j6tua0EMt41I(8qWEyezWlfrcCeaqY9mpmjDHFPicegkiu6KXdTpG)br8(xTasoyybqcnOp2N9jhGndUDrWIgvf9sen6txKoz8q7d4FqeV)vlGKdg(veQrc9BVu6KXdTpG)br8(xTasoy4dwOUknqGTUCW8heHZ)GfQRsdePtPtygZ54m7oXlbbNdHJqyLtOFkNyJYX4rJYrb5y4mvAvj5tNmEO9bCW7Yfec8qsj26YbZrLJwn6L8WkGRps9mewcE))2bNoHzmNdZixRUCW5SBiqlXr5OGCa9NIn9EZj2SihUDqoYPs58ByssW(0jmJ5CmEO9bGKdgEKRvxoybIaTehHDbqcxBQKeCde696yhS1LdiulRLN3)AbeAF(YdgyulRLhuobJ69cevjba69kqKbJLhrgpG4(AzT8h5A1LdwGiqlXrE421LoHzmNdt3OC49VwaH2Ni0VEV5y8q7lhPcICa8ncUijqoU2Olh83)AbeAF54sLYCQuofabNJDW5aIgrGCInkhebkYih9YbNHuRkjFOFseTG3)AbeAF(0jmJ5CmEO9bGKdgYnPuy8q7tivqG9zFYbV)1ci0(eH(17nDcZ5WKyi1QskNyZICiqOFliqoU2OyJq5aDtxHEV5SlTlcLJlvkZPs5uaeCovA1ikh83)AbeAF5OGCqKbJLpDcZyohJhAFai5GH4mKAvjH9zFYbytxHEVIN2fHevA1isW7FTacTpS7hhakWgNjlKdiy8qXrc6OVsagGZqQvLKN3)AbeAFcWMUc9EfpTlcHbggpuCKGo6ReGb4mKAvj559VwaH2NyjTpbcKYiHbg4mKAvj5d9tIOf8(xlGq7ZTnEO95bB6k07v80UiKFvKsbIGl8q7dF8ULWTRZd20vO3R4PDripCbzH2he3JZqQvLKp0pjIwW7FTacTp3M3TeUDDEWMUc9EfpTlc5r030dGpJhAFEWMUc9EfpTlc5xfPuGi4cp0(2dbE3s4215rLJe9s80UiKhrFtpGBZ7wc3UopytxHEVIN2fH8i6B6bW3UIbgmpmjDHhvos0lXt7IqqmDY4H2hasoyiytxHEVIN2fHWwxoQL1YZ7FTacTppC762B8q7ZVuejQsdeE(MHEjadCSZEMdHAzT86Ti0zsb3aCdM8LN91YA536qacezm6rKXdiUhNHuRkjpytxHEVIN2fHevA1isW7FTacTV0jmNdudhLZUXGv7ICG(yigZz1OCWF)RfqO9HDo1sKthBeYLcOCkakhnYPVC4DlHBxNpDY4H2hasoyiYGv7cb4XqmITUCulRLN3)AbeAFE421Thc4mKAvj5d9tIOf8(xlGq7dF8ULWTRZT3viMoH5CCgKfB1gDuoGTUiHZXKUmSa5uPCkacohxASLd(7FTacTpFomzASLJZGSydYGCWBl26p25OroGTUiHZPs5uaeCoKHKyLdOZj2SihNbzXwTrhLJlvkZzZWr58BeLdimoJGCGli9EZb)9VwaH2NpDY4H2hasoyimzXwTrhHTUCulRLN3)AbeAFE421TVwwlpQCKOxIN2fH8WTRBpodPwvs(q)KiAbV)1ci0(yaodPwvsEE)RfqO9jEqe3aHi0pbjYDIxcse6NGeeQL1YdtwSvB0rE4cYcTp3UwwlpV)1ci0(8WfKfAFqetIkhTA0l5Hjl2aILfB9pDcZ5SBbuoo7kc1iqo9khM2OpDroU0ylh83)AbeAF(0jJhAFai5GHFfHAeq0lr0OpDb26YbodPwvs(q)KiAbV)1ci0(yaodPwvsEE)RfqO9jEqe3aHi0pbjYDIxcse6N2xlRLN3)AbeAFE421LoH5CCwsqNtbq54SRiuJa50RCyAJ(0f5OxovkCr0Ld(7FTacTpqogihzFV5yGCWF)RfqO9LJlvkZ56iNndhLt05uPCGjPHfbNZVW3Yz1OC0WNoz8q7dajhm8RiuJaIEjIg9PlWwxoWzi1QsYh6Nerl49VwaH2h(4DlHBxNBJjWumjQC0QrVKhO3QifWKuF3I0jmNdE3OCysOl2WcHDofaLJLdERikh8inqKdFZqVuoWfKEV54SRiuJa50RCyAJ(0f5WnqKt05y4AfohU98O3Bo8nd9saF6KXdTpaKCWWLIirvAGa7cGeU2ujj4gi071XoyRlhgp0(8FfHAeq0lr0OpDHNCN4LqV39RIukqeFZqVKi0p52gp0(8FfHAeq0lr0OpDHNCN4LGei6B6byWUFpZ36qacezmkapKuce6jws9Dl2Z8AzT8BDiabImg9LN0jJhAFai5GHfaj0G(ytRfXdXzFYXR0GvlAequn4xcBD5aNHuRkjFOFseTG3)AbeAF4J3TeUDDU9UMoz8q7dajhmSaiHg0h7Z(Kd6)GfImPOrWNDCcBD5aNHuRkjFOFseTG3)AbeAFmWbodPwvsE6)GfImPOrWNDCsatsdR94mKAvj5d9tIOf8(xlGq7dF4mKAvj5P)dwiYKIgbF2XjbmjnSC7DnDY4H2hasoyybqcnOp2N9jhGndUDrWIgvf9sen6txGTUCabCgsTQK8H(jr0cE)RfqO9Xah4mKAvj559VwaH2N4brCdeIq)eKCdgyS03TqGOVPhGb4mKAvj5d9tIOf8(xlGq7dI7RL1YZ7FTacTppC76sNmEO9bGKdgwaKqd6J9zFYXReRNnrVegaOFvAH2h26YbeQL1YZ7FTacTppC762JZqQvLKp0pjIwW7FTacTp85aNHuRkjFFIcGe8s0RfgyGZqQvLKVprbqcEj61YbMcX0jJhAFai5GHfaj0G(yF2NC8nUvrKaSrui(fGYXwxoWzi1QsYh6Nerl49VwaH2hdCSRPtyohN3kNcqV3CSCabHAfoN(C7cGYrd6JDoM0LHfiNcGYXzGidEPikhMecaizoDjakmLtVYb)9VwaH2Nph8YyJqUuaHDopiTrAOmPq5ua69MJZarg8sruomjeaqYCCPXwo4V)1ci0(YPpjw5ORCCE3IqNjZb)gGBWuokih6SQKGZXo4CSCka7LYXvFqoYPs5iBqKtJJq5eBuoWfKfAF50RCInkNL(Uf(Cy6McYXGHb5y5a(MuMdotwOCIoNyJYH3TeUDD50RCCgiYGxkIYHjHaasMJRn6YbU17nNytb5WnjViTq7lNkXTcGYrJCuqoLdrMeekpNOZXaGYNYj2SihnYXLkL5uPCkacoNhcTiEiXkN(YH3TeUDD(0jJhAFai5GHfaj0G(yF2NCaJidEPisGJaasITUCaHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHbg4mKAvj57tuaKGxIETCGPqCpeQL1YR3IqNjfCdWnyYdcJZOJAzT86Ti0zsb3aCdM8FZDbimoJyGbZ59bx0WR3IqNjfCdWnycdmWzi1QsYZ7FTacTprFIcGWadCgsTQK8H(jr0cE)RfqO9Hp9cc90sliyXsF3cbI(MEaNpNpiW7wc3UoiTdMcriMoHzmNdZix5aTlYCCEVNgekh6cewyNdIKkbYPVCaBgIGZrd6Nd(Dg5O3QrFl0(Yj2SihfKZ1royrroGYZtJcc2Nto7g6rACcKtSr58GiCAxa5i1JYX1gD5Skhp0(mPpDY4H2hasoyybqcnOp2N9jhGUif67PbHWwxoGaodPwvs(q)KiAbV)1ci0(WNdmbMIjHaodPwvs((efaj4LOxl8HPqedmGaZdKEmsHFhVc8GUif67PbH2hi9yKc)o(cWQsAFG0Jrk8745DlHBxNhrFtpagyW8aPhJu4DJxbEqxKc990Gq7dKEmsH3n(cWQsAFG0Jrk8UXZ7wc3UopI(MEaicX9qG5eETOppeShgrg8srKahbaKedm4DlHBxNhgrg8srKahbaK0JOVPhaF7ketNWComfPVVekhODrMJZ790Gq5qgsIvoU0ylhN3Ti0zYCWVb4gmLtJYX1gD5OroUmqopiIBGWNoz8q7dajhmKBhNKIAzTW(Sp5a0fPqFpn0(WwxoyoVp4IgE9we6mPGBaUbt7d9tmyxXaJAzT86Ti0zsb3aCdM8GW4m6OwwlVElcDMuWna3Gj)3CxacJZy6eMZX5f0hKtSzroWDoxh5uPJwAKd(7FTacTVCaBDrcNdt6ciYPs5uaeCoDjakmLtVYb)9VwaH2xowKdO)uopTEHpDY4H2hasoyybqcnOp2N9jh6b4OsyvjjWRf7IYxat4uoHTUCq41I(8qW(xPbRw0iGOAWV0EiulRLN3)AbeAFE421ThNHuRkjFOFseTG3)AbeAF4ZbodPwvs((efaj4LOxlmWaNHuRkjFFIcGe8s0RLdmfIPtgp0(aqYbdlasOb9X(Sp5yjTpj6LOArijS1LdcVw0Nhc2)kny1Igbevd(L2dHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHbg4mKAvj57tuaKGxIETCGPqmDY4H2hasoyybqcnOp2N9jhUmgPJqaXc1hm26YbHxl6Zdb7FLgSArJaIQb)s7HqTSwEE)RfqO95HBx3ECgsTQK8H(jr0cE)RfqO9Hph4mKAvj57tuaKGxIETWadCgsTQK89jkasWlrVwoWuiMoz8q7dajhmSaiHg0h7Z(Kd9abQWJgbeWko9irLKsS1LdcVw0Nhc2)kny1Igbevd(L2dHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHbg4mKAvj57tuaKGxIETCGPqmDY4H2hasoyybqcnOp2N9jhGYvLDdlSpfBybcS1LdcVw0Nhc2)kny1Igbevd(L2dHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHbg4mKAvj57tuaKGxIETCGPqmDY4H2hasoyybqcnOpaBD5OwwlpV)1ci0(8WTRBpodPwvs(q)KiAbV)1ci0(WNdCgsTQK89jkasWlrVwyGbodPwvs((efaj4LOxlhyA6eMZz3cOCWBudICywJZYj6CcK((sOC2DqkqIvoopUYLKpDY4H2hasoy4c1GqCnodBD5avoA1OxY)IuGelHYvUK2xlRLN3)AbeAFE421Thc4mKAvj5d9tIOf8(xlGq7dF8ULWTRddmWzi1QsYh6Nerl49VwaH2hdWzi1QsYZ7FTacTpXdI4gieH(jirUt8sqIq)eetNWCo7ouKtSr54muaxFK6ziSYb)9)BhCo1YALt5b7CkNKaGC49VwaH2xokihq3NpDY4H2hasoyiVlxqiWdjLyRlhOYrRg9sEyfW1hPEgclbV)F7G3Z7wc3UoFTSwcyfW1hPEgclbV)F7G9iYGXAFTSwEyfW1hPEgclbV)F7GfgIBh5HBx3EMxlRLhwbC9rQNHWsW7)3oyF5zpeWzi1QsYh6Nerl49VwaH2hKmEO95xOge1wgEUbcrOFcF8ULWTRZxlRLawbC9rQNHWsW7)3oypCbzH2hgyGZqQvLKp0pjIwW7FTacTpgSRqmDY4H2hasoyOH42rcY9hzd0(WwxoqLJwn6L8WkGRps9mewcE))2bVN3TeUDD(AzTeWkGRps9mewcE))2b7rKbJ1(AzT8WkGRps9mewcE))2blme3oYd3UU9mVwwlpSc46JupdHLG3)VDW(YZEiGZqQvLKp0pjIwW7FTacTpirUt8sqIq)eKmEO95xOge1wgEUbcrOFcF8ULWTRZxlRLawbC9rQNHWsW7)3oypCbzH2hgyGZqQvLKp0pjIwW7FTacTpgSR7zEys6cpQCKOxIN2fHGy6KXdTpaKCWWfQbrTLb26YbQC0QrVKhwbC9rQNHWsW7)3o498ULWTRZxlRLawbC9rQNHWsW7)3oypI(MEagWnqic9t7RL1YdRaU(i1Zqyj49)BhSyHAq4HBx3EMxlRLhwbC9rQNHWsW7)3oyF5zpeWzi1QsYh6Nerl49VwaH2hK4gieH(j8X7wc3UoFTSwcyfW1hPEgclbV)F7G9WfKfAFyGbodPwvs(q)KiAbV)1ci0(yWUcX0jJhAFai5GHludcX14mS1Ldu5OvJEjpSc46JupdHLG3)VDW75DlHBxNVwwlbSc46JupdHLG3)VDWEezWyTVwwlpSc46JupdHLG3)VDWIfQbHhUDD7zETSwEyfW1hPEgclbV)F7G9LN9qaNHuRkjFOFseTG3)AbeAF4J3TeUDD(AzTeWkGRps9mewcE))2b7Hlil0(WadCgsTQK8H(jr0cE)RfqO9XGDfIPtyoNDPBzogiNVDyLdERikh8inqaYXa580aGwLuoRgLd(7FTacTpFoql1az8iNUe50RCInkNfY4H2NjZH3)N(OlYPx5eBuox5xjuo9kh8wruo4rAGaKtSzroUuPmNZIcYKsSYbr8nd9s5axq69MtSr5G)(xlGq7lNNndq5ujUvauopDl17nh7Wk207nNhde5eBwKJlvkZ56iNxKDro2Ld5EGSCWBfr5GhPbICGli9EZb)9VwaH2NpDY4H2hasoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJLIirvAGq80TuVxSXzYc5aNHuRkjp5Eqhmbl49VwaH2NarFtpadWzi1QsYh6Nerl49VwaH23EJhAF(LIirvAGWZ3m0lbelKXdTptcjiGZqQvLKp0pjIwW7FTacTpiz8q7Zd20vO3R4PDri)QiLcebx4H2hMeNHuRkjpytxHEVIN2fHevA1isW7FTacTpibbyQwwl)xrOgbe9sen6tx4)M7cqyCgD7DGiMeNHuRkj)VdbI4Bg6Le2VlxGj5no6Sl84Ol2WcHjHaVBjC768FfHAeq0lr0OpDHhrFtpadCGZqQvLKp0pjIwW7FTacTpicrNpE3s4215xkIevPbcpCbzH2NBVdd4DlHBxNFPisuLgi8FZDbFZqVeas4mKAvj5BCe6PBPyPisuLgiaoF8ULWTRZVuejQsdeE4cYcTp3gc1YA559VwaH2NhUGSq7Z5J3TeUDD(LIirvAGWdxqwO9brNpNVD2JZqQvLKp0pjIwW7FTacTpgS03TqGOVPhiDY4H2hasoyi3KsHXdTpHubb2N9jh8(xlGq7t8SzacBD5aNHuRkjFOFseTG3)AbeAFmWbMIbg1YA559VwaH2NV8Gbg4mKAvj5d9tIOf8(xlGq7Jb4mKAvj559VwaH2N4brCdeIq)0EE3s421559VwaH2NhrFtpadWzi1QsYZ7FTacTpXdI4gieH(P0jJhAFai5GHOYrIEjEAxecBD5OwwlpV)1ci0(8WTRBFTSwEu5irVepTlc5HBx3EMxlRLFPicen67rKXJ9qaNHuRkjFOFseTG3)AbeAF4ZrTSwEu5irVepTlc5Hlil0(2JZqQvLKp0pjIwW7FTacTp8z8q7ZVuejQsde(vrkfiIVzOxse6NWadCgsTQK8H(jr0cE)RfqO9HVL(Ufce9n9aqCpeyoQC0QrVKhuobJ69cevjba69IbggpuCKGo6ReaFoWzi1QsYVziyb3aHyjTpbcKYiHbg1YA5bLtWOEVarvsaGEVcezWy5lpyGrTSwEq5emQ3lquLeaO3RhrgpWNJAzT8GYjyuVxGOkjaqVx)3CxacJZOBVdgyS03TqGOVPhGb1YA5rLJe9s80UiKhUGSq7dIPtyohNfmt6ciYj2OCWzi1QskNyZIC49fOwcYbVveLdEKgiYPaSxkNOZby4OCWBfr5GhPbcqoU2ujLduYq69Mdt7cFlhfKJXdfhLJln2YbA5YHjxVxidYbpsca071Noz8q7dajhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYXsrKOknqiE6wQ3l24mzHCaidP3Ri6cFZB8qXr7nEO95xkIevPbc)QiLceX3m0ljc9t4dtGjF5W(V5o26YbZXzi1QsYVuejQsdeINUL69UhvoA1OxYdkNGr9EbIQKaa9EtNWComjgsTQKYj2SihEFbQLGC2LTMo19CWBP9jqofG9s5eDo0bkikhna5W3m0lbYXquopDlj4Cwnkh83)AbeAF(CWlpjw5uauo7YwtN6Eo4T0(eiNUeafMYPx5G)(xlGq7lhxB0LZQiL5W3m0lbYHBxovkNUgMEeCoWfKEV5eBuoh5EKd(7FTacTpF6eMXCogp0(aqYbdXzi1Qsc7Z(KJNTMo1DXt3s9EXwxomEO4ibD0xjadWzi1QsYZ7FTacTpXsAFceiLrcBCMSqoWzi1QsYh6Nerl49VwaH2hKQL1YZ7FTacTppCbzH2NBVRmW4H2N)zRPtDxSK2Na(vrkfiIVzOxse6NGeVBjC768pBnDQ7IL0(eWdxqwO952gp0(8GnDf69kEAxeYVksParWfEO9HjXzi1QsYd20vO3R4PDrirLwnIe8(xlGq7BpodPwvs(q)KiAbV)1ci0(yWsF3cbI(MEamWavoA1OxYdkNGr9EbIQKaa9EXaJq)ed210jmNdt2gD5ua69MdElTpbcKYiLJE5G)(xlGq7d7CagokhdKZ3oSYHVzOxcKJbY5PbaTkPCwnkh83)AbeAF54sJTUe5WTNh9E9PtygZ5y8q7dajhmeNHuRkjSp7toE2A6u3fpDl17fBD5W4HIJe0rFLa4ZbodPwvsEE)RfqO9jws7tGaPmsyJZKfYbodPwvs(q)KiAbV)1ci0(yGXdTp)ZwtN6UyjTpb8RIukqeFZqVKi0p52gp0(8GnDf69kEAxeYVksParWfEO9HjXzi1QsYd20vO3R4PDrirLwnIe8(xlGq7BpodPwvs(q)KiAbV)1ci0(yWsF3cbI(MEamWavoA1OxYdkNGr9EbIQKaa9EXaJq)ed210jJhAFai5GHCtkfgp0(esfeyF2NCG6hXZMbiSbbs5HJDWwxoQL1YJkhj6L4PDriF5zFTSwEE)RfqO95HBx3ECgsTQK8H(jr0cE)RfqO9HpmnDcZ54SGzsxaroXgLdodPwvs5eBwKdVVa1sqo4TIOCWJ0arofG9s5eDo0bkikhna5W3m0lbYXquoMe0580TKGZz1OC2nLJYPx5SlTlc5tNmEO9bGKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5yPisuLgiepDl17fBCMSqoGaZrLJwn6L8GYjyuVxGOkjaqVxmWOwwlpOCcg17fiQsca071dcJZi(QL1YdkNGr9EbIQKaa9E9FZDbimoJU9oqCpVBjC768OYrIEjEAxeYJOVPhGbgp0(8lfrIQ0aHFvKsbI4Bg6LeH(j324H2NhSPRqVxXt7Iq(vrkficUWdTpmjeWzi1QsYd20vO3R4PDrirLwnIe8(xlGq7BpVBjC768GnDf69kEAxeYJOVPhGb8ULWTRZJkhj6L4PDripI(MEaiUN3TeUDDEu5irVepTlc5r030dWGL(Ufce9n9ayRlhmhNHuRkj)srKOknqiE6wQ37(WK0fEu5irVepTlcTVwwlpQCKOxIN2fH8WTRlDcZ5WKTrxo4fgcMBGqV3CWBP9jqGugjSZbVveLdEKgia5a26IeoNkLtbqW5eDoV0rilOCWl6ihObImgb5yhCorNd5EqhCo4rAGGq54SBGGq(0jJhAFai5GHlfrIQ0ab2faj61s8YHDSd2fajCTPssWnqO3RJDWwxoyoodPwvs(LIirvAGq80TuV394mKAvj5d9tIOf8(xlGq7dFy6EJhkosqh9vcGph4mKAvj53meSGBGqSK2NabszK2Z8LIiqyOGqEJhkoApZRL1YV1HaeiYy0xE2dHAzT8BKf69kkp(YZEJhAF(L0(eiqkJKNCN4LGei6B6byaM63vmWGVzOxciwiJhAFMeFoCdetNWCooJcsV3CWBfrGWqbHWoh8wruo4rAGaKJHOCkacohG(vPHKyLt05axq69Md(7FTacTpFo7o0ritkXc7CIncRCmeLtbqW5eDoV0rilOCWl6ihObImgb54AJUC4ina54sLYCUoYPs54YabbNJDW54sJTCWJ0abHYXz3abHWoNyJWkhWwxKW5uPCapiYGZPlrorNZ30lm9Yj2OCWJ0abHYXz3abHYPwwlF6KXdTpaKCWWLIirvAGa7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyRlhlfrGWqbH8gpuC0ECgsTQK8H(jr0cE)RfqO9HpmDpZXzi1QsYVuejQsdeINUL69Uhcm34H2NFPiQAsPNCN4LqV39m34H2N)bluxLgi86jws9Dl2xlRLFJSqVxr5XJiJhyGHXdTp)sru1Ksp5oXlHEV7zETSw(ToeGargJEez8admmEO95FWc1vPbcVEILuF3I91YA53il07vuE8iY4XEMxlRLFRdbiqKXOhrgpGy6eMZXzHRv4C42ZJEV5G3kIYbpsde5W3m0lbYX1MkPC4B2DKuV3CGUPRqV3C2L2fHsNmEO9bGKdgUuejQsdeyxaKW1Mkjb3aHEVo2bBD5W4H2NhSPRqVxXt7IqEYDIxc9E3VksPar8nd9sIq)edmEO95bB6k07v80UiKpuoJcebx4H2x6KXdTpaKCWqUjLcJhAFcPccSp7toaHDWgcwG6WcTpS1LdCgsTQK8H(jr0cE)RfqO9HpmDFTSwEu5irVepTlc5HBx3(AzT88(xlGq7Zd3UU0jJhAFai5GHaEJ4BPtPtgp0(aEJhkoseMKUa4qQ407vu7FfBD5W4HIJe0rFLa4BN91YA559VwaH2NhUDD7HaodPwvs(q)KiAbV)1ci0(WhVBjC768sfNEVIA)RE4cYcTpmWaNHuRkjFOFseTG3)AbeAFmWbMcX0jJhAFaVXdfhjctsxaGKdg(PGAe26YbodPwvs(q)KiAbV)1ci0(yGdmfdmQL1YZ7FTacTppI(MEa8fidhjfH(jmWac8ULWTRZ)PGAKhUGSq7Jb4mKAvj5d9tIOf8(xlGq7BpZdtsx4rLJe9s80UieeXaJWK0fEu5irVepTlcTVwwlpQCKOxIN2fH8LN94mKAvj5d9tIOf8(xlGq7dFgp0(8FkOg55DlHBxhgyS03TqGOVPhGb4mKAvj5d9tIOf8(xlGq7lDY4H2hWB8qXrIWK0fai5GHWi7TpGOIil2Wwxoctsx4nj5oiqgGjfdiwfew7HqTSwEE)RfqO95HBx3EMxlRLFRdbiqKXOV8aX0P0jJhAFapV)1ci0(e8ULWTRd44PdTV0jJhAFapV)1ci0(e8ULWTRdajhmSk7gwSkiSsNmEO9b88(xlGq7tW7wc3UoaKCWWkHaeIr9EXwxoQL1YZ7FTacTpF5jDY4H2hWZ7FTacTpbVBjC76aqYbdxkIQYUHtNmEO9b88(xlGq7tW7wc3UoaKCWq74eiqMuWnPmDY4H2hWZ7FTacTpbVBjC76aqYbdd9tcxg6bBD5avoA1OxYh0)PrMu4Yqp7RL1YtUVzfqO95lpPtgp0(aEE)RfqO9j4DlHBxhasoyybqcnOp20Ar8qC2NC8kny1Igbevd(LsNmEO9b88(xlGq7tW7wc3UoaKCWWcGeAqFSp7to0dWrLWQssGxl2fLVaMWPCkDY4H2hWZ7FTacTpbVBjC76aqYbdlasOb9X(Sp5yjTpj6LOAriP0jJhAFapV)1ci0(e8ULWTRdajhmSaiHg0h7Z(KdxgJ0riGyH6doDY4H2hWZ7FTacTpbVBjC76aqYbdlasOb9X(Sp5qpqGk8OrabSItpsujPmDY4H2hWZ7FTacTpbVBjC76aqYbdlasOb9X(Sp5auUQSByH9PydlqKoz8q7d459VwaH2NG3TeUDDai5GHfaj0G(G0P0jmNJZmi0VfuoBTRCK99Md(7FTacTVCCPszosde5eB2XiiNOZbA5YHjxVxidYbpsca07nNOZbMcc91JYzRDLdERikh8inqaYbS1fjCovkNcGG9Ptgp0(aEE)RfqO9jE2mabjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYb5Eqhmbl49VwaH2NarFtpa24mzHCulRLN3)AbeAFEe9n9aqQwwlpV)1ci0(8WfKfAFysiW7wc3UopV)1ci0(8i6B6byqTSwEE)RfqO95r030daX0jmNJZcggKtSr5axqwO9LtVYj2OCGwUCyY17fYGCWJKaa9EZb)9VwaH2xorNtSr5qhCo9kNyJYHxqi6ICWF)RfqO9LJUYj2OC4giYXvxKW5acdf5axq69MtSPGCWF)RfqO95tNmEO9b88(xlGq7t8SzacsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KdY9GoycwW7FTacTpbI(MEaS7hhgmm24mzHCGZqQvLKhWyvaxqwO9HTUCGkhTA0l5bLtWOEVarvsaGEV7HqTSwEq5emQ3lquLeaO3Rargmw(YdgyGZqQvLKNCpOdMGf8(xlGq7tGOVPhaFVCypI(MEaiTJFxXKVCy)3ChtcHAzT8GYjyuVxGOkjaqVx)3CxacJZOBxlRLhuobJ69cevjba696bHXzeIqmDcZ5GxgBekhE3s421bYj2SihWwxKW5uPCkacohxASLd(7FTacTVCaBDrcNtFsSYPs5uaeCoU0ylh7YX4rXK5G)(xlGq7lhUbICSdoNRJCCPXwowoqlxom569czqo4rsaGEV58GAUpDY4H2hWZ7FTacTpXZMbii5GHCtkfgp0(esfeyF2NCW7FTacTpbVBjC76aydcKYdh7GTUCGZqQvLKNCpOdMGf8(xlGq7tGOVPhaF4mKAvj5bmwfWfKfAFPtgp0(aEE)RfqO9jE2mabjhmKBsPW4H2NqQGa7Z(KdJhkoseMKUaKoH5CCERCGwUCyY17fYGCWJKaa9EZbegNrqogIYztF3WohUDCsMtSr)CQ0Qruo4V)1ci0(Yb05eBwKtSr5aTC5WKR3lKb5Ghjba69MZdQ55WTlNkLdWwKeRCGjPHfbNt5cvMJTccLd(7FTacTVCCPXwxICqkGXC6voK7pkYcTpF6KXdTpGN3)AbeAFINndqqYbd52XjPOwwlSp7toaLtWOEVarvsaGEVyRlh1YA559VwaH2NhUDD7RL1YdkNGr9EbIQKaa9E9GW4mIp3SpmjDHhvos0lXt7Iq75DlHBxNhvos0lXt7IqEe9n9amWnyA6eMZX5TYb)9VwaH2xokih421HDopiIBGihq)PytV3CQ0QruogpuCwO3BoA4tNmEO9b88(xlGq7t8Szacsoy4sAFceiLrcBD5OwwlpV)1ci0(8WTRBpVBjC7688(xlGq7ZJOVPhGbCdeIq)0EJhkosqh9vcGph4mKAvj559VwaH2NyjTpbcKYiLoz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5OwwlpV)1ci0(8WTRBFTSwEq5emQ3lquLeaO3Rargmw(YZ(AzT8GYjyuVxGOkjaqVxbImyS8i6B6bWh3aHi0pLoz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5OwwlpV)1ci0(8WTRBFTSw(hSqnxAGVhrgp2xlRL)bluZLg47r030dGpUbcrOFkDY4H2hWZ7FTacTpXZMbii5GHlfrvtkXwxoQL1YZ7FTacTppC762Z7wc3UopV)1ci0(8i6B6bya3aHi0pTN58(GlA4xs7tcJZruO9Loz8q7d459VwaH2N4zZaeKCWqaVr8nS1LJAzT88(xlGq7Zd3UU98ULWTRZZ7FTacTppI(MEagWnqic9tPtyoh83)AbeAF5a26IeoNkLtbqW54AJUCInkNheXnqKJcYXK)ge5S0tbBeSpDY4H2hWZ7FTacTpXZMbii5GH8(xlGq7d7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyRlhBDiabImgfGhskbc9elP(UfoW091YA559VwaH2NhUDD7Xzi1QsYh6Nerl49VwaH2hdCGP7HaZrLJwn6L8WkGRps9mewcE))2bJbg1YA5HvaxFK6ziSe8()Td2xEWaJAzT8WkGRps9mewcE))2blwOge(YZ(WK0fEu5irVepTlcTN3TeUDD(AzTeWkGRps9mewcE))2b7rKbJfe3dbMJkhTA0l5FrkqILq5kxsyGbmvlRL)fPajwcLRCj5lpqCpeyoVXrNDH)ioQLncgdm4DlHBxNhMSyR2OJ8i6B6bWaJAzT8WKfB1gDKV8aX9qG58ghD2fEC0fByHWadE3s4215)kc1iGOxIOrF6cpI(MEaiUhcgp0(8FkOg51tSK67wS34H2N)tb1iVEILuF3cbI(MEag4aNHuRkjpV)1ci0(eCdece9n9ayGHXdTppG3i(MNCN4LqV39gp0(8aEJ4BEYDIxcsGOVPhGb4mKAvj559VwaH2NGBGqGOVPhadmmEO95xkIQMu6j3jEj07DVXdTp)sru1Ksp5oXlbjq030dWaCgsTQK88(xlGq7tWnqiq030dGbggp0(8pyH6Q0aHNCN4LqV39gp0(8pyH6Q0aHNCN4LGei6B6byaodPwvsEE)RfqO9j4giei6B6bWadJhAF(L0(eiqkJKNCN4LqV39gp0(8lP9jqGugjp5oXlbjq030dWaCgsTQK88(xlGq7tWnqiq030daX0jmNdtMgBDjYX5DlcDMmh8BaUbtyNdt6ciYPaOCWBfr5GhPbcqoU2OlNyJWkhx9b5iNF54B5WrAaYXo4CCTrxo4TIiq0OFokih4215tNmEO9b88(xlGq7t8Szacsoy4srKOknqGDbqIETeVCyh7GDbqcxBQKeCde696yhS1LdMZ7dUOHxVfHotk4gGBW0EMJZqQvLKFPisuLgiepDl17DFTSwEE)RfqO95lp7zETSw(LIiq0OVhrgp2Z8AzT8BDiabImg9iY4X(ToeGargJcWdjLaHEILuF3civlRLFJSqVxr5XJiJhysi8YH9i6B6bWhMcrg4M0jmNdtMgB548UfHotMd(na3GjSZbVveLdEKgiYPaOCaBDrcNtLYXGH1q7ZKsSYH3hiqMEeCoGoNyZIC0ihfKZ1rovkNcGGZPCscaYX5DlcDMmh8BaUbt5OGCSAxICIohY9hfr50OCIncr5yikNFJOCIn7YHUU8ULdERikh8inqaYj6Ci3d6GZX5DlcDMmh8BaUbt5eDoXgLdDW50RCWF)RfqO95tNWmMZX4H2hWZ7FTacTpXZMbii5GH4mKAvjHDbqIETeVCyh7GDbqcxBQKeCde696yhSp7toi3FiEqWILIirvAGaGD)4aqb24mzHCy8q7ZVuejQsdeE(MHEjGyHmEO9zsibbCgsTQK8K7bDWeSG3)AbeAFce9n9aUDTSwE9we6mPGBaUbtE4cYcTpi68X7wc3Uo)srKOknq4Hlil0(Wwxo49bx0WR3IqNjfCdWnykDcZyohJhAFapV)1ci0(epBgGGKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp54icMGflfrIQ0aba7(XbGcSXzYc5GtQec4mKAvj5j3d6GjybV)1ci0(ei6B6bC(GqTSwE9we6mPGBaUbtE4cYcTp3(Ld7)M7qeIyRlh8(GlA41BrOZKcUb4gmLoH5C2TakhOB6k07nNDPDrOCGli9EZb)9VwaH2xoU2OlNyJquogIY56ih66Y7wo4TIOCWJ0abihdNPsRkPCIoNvrkXkhY9Go4C0BrOZK5Wna3GPCSdoN(KyLJRn6Yz3uokNELZU0UiuokiN(YH3TeUDD(0jJhAFapV)1ci0(epBgGGKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5OaibytxHEVIN2fHWgNjlKJLIiqyOGqEe9n9amaNHuRkjp5Eqhmbl49VwaH2NarFtpWEiW7dUOHxVfHotk4gGBW0ECgsTQK8K7pepiyXsrKOknqayaodPwvs(JiycwSuejQsdeaiUhcmpmjDHhvos0lXt7IqyGbVBjC768OYrIEjEAxeYJOVPhaF4mKAvj5j3d6GjybV)1ci0(ei6B6bGigyy8qXrc6OVsa85aNHuRkjpV)1ci0(eGnDf69kEAxecBD5G34OZUWF67wiwgLoz8q7d459VwaH2N4zZaeKCWWLIirvAGa7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyRlh8(GlA41BrOZKcUb4gmTN54mKAvj5xkIevPbcXt3s9E3dbCgsTQK8K7pepiyXsrKOknqaWNdCgsTQK8hrWeSyPisuLgiayGrTSwEE)RfqO95r030dWGxoS)BUJbg4mKAvj5j3d6GjybV)1ci0(ei6B6byGJAzT86Ti0zsb3aCdM8WfKfAFyGrTSwE9we6mPGBaUbtEqyCgzGBWaJAzT86Ti0zsb3aCdM8i6B6byWlh2)n3XadE3s4215bB6k07v80UiKhrgmw7Xzi1QsYxaKaSPRqVxXt7IqqCFTSwEE)RfqO95lp7HaZRL1YVuebIg99iY4bgyulRLxVfHotk4gGBWKhrFtpadWu)UcX9mVwwl)whcqGiJrpImESFRdbiqKXOa8qsjqONyj13Tas1YA53il07vuE8iY4bMecVCypI(MEa8HPqKbUjDcZ5a9Ho4CWl6ihObImgb5axq69Md(7FTacTVCSiNn9DlNhK2inWYNoz8q7d459VwaH2N4zZaeKCWWL0(eiqkJe26YbeQL1YV1HaeiYy0xE2B8qXrc6OVsa85aNHuRkjpV)1ci0(elP9jqGugjiIbgqOwwl)sreiA03xE2B8qXrc6OVsa85aNHuRkjpV)1ci0(elP9jqGugj3gvoA1OxYVuebIg9Hy6eMZz3yWQDroqFmeJ5a26IeoNkLtbqW54sJTCSCWl6ihObImgZbrgmw5eDofaLJ()eSAbjXkhBfekNyJYHBGiNLEkyJa(Cy6McYXLkL5CwuqMuIvoakYP8KJLdErh5anqKXyoGh6ICwnkNyJYzPNjZbegNXC6vo7gdwTlYb6JHy0Noz8q7d459VwaH2N4zZaeKCWqKbR2fcWJHyeBD5OwwlpV)1ci0(8LN9UbtwlRLFRdbiqKXOhrgpGuTSw(nYc9EfLhpImEaPToeGargJcWdjLaHEILuF3chUjDY4H2hWZ7FTacTpXZMbii5GHpyH6Q0ab26YrTSw(LIiq0OVV8Koz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5Owwl)whcqGiJrF5zFTSwEE)RfqO95lpPtgp0(aEE)RfqO9jE2mabjhm8bluxLgiWwxoEqeoXlh2VJhWBeFBFTSw(nYc9EfLhF5zVXdfhjOJ(kbyaodPwvsEE)RfqO9jws7tGaPms7RL1YZ7FTacTpF5jDcZ5SBb69Md0nDf69MZU0UiuoWfKEV5G)(xlGq7lNOZbrGOruo4TIOCWJ0aro2bNZUS10PUNdElTpLdFZqVeihUD5uPCQ0rlLRMe7CQLiNcOysjw50NeRC6lhNv7m7tNmEO9b88(xlGq7t8SzacsoyiytxHEVIN2fHWwxoWzi1QsYxaKaSPRqVxXt7Iq7RL1YZ7FTacTpF5zpZnEO95xkIevPbcpFZqVeyVXdTp)ZwtN6UyjTpb88nd9sagy8q7Z)S10PUlws7ta)3CxW3m0lbsNWCoqlxom569czqo4rsaGEV58GAoiN(Yj2ifLt76YbS1fjCovkhysAyrW5SAuo7cwOMlnWpNhuZb54AJUCEAaqRsc7CQLiNo2iKlfq5WTlNkLtbqW5Oxo4V)1ci0(YX1gD5eBeIYXquoGYAPCLUih8wruo4rAGa4ZX5TYXYbA5YHjxVxidYbpsca07nNhuZZXvxKW5uPCkacg7C2nLJYPx5SlTlcLdyRls4CQuofabNZsrGihDLtSr5qURGqV3C2nLJYPx5SlTlcLJlvkZHC)rruoWfKEV5eBuoCde(0jJhAFapV)1ci0(epBgGGKdgIkhj6L4PDriS1LJAzT8GYjyuVxGOkjaqVxbImyS8LN9qaNHuRkj)remblwkIevPbcadCGZqQvLKNC)H4bblwkIevPbcagyat1YA5)kc1iGOxIOrF6cF5bI7nEO4ibD0xja(CGZqQvLKN3)AbeAFIL0(eiqkJ0(AzT8GYjyuVxGOkjaqVxbImyS8i6B6bWh5oXlbjc9tqY4H2NFjTpbcKYi55gieH(P0jJhAFapV)1ci0(epBgGGKdgUK2NabszKWwxoQL1YdkNGr9EbIQKaa9EfiYGXYxE2dbCgsTQK8hrWeSyPisuLgiamWbodPwvsEY9hIheSyPisuLgiayGbmvlRL)RiuJaIEjIg9Pl8LhiU34HIJe0rFLa4ZbodPwvsEE)RfqO9jws7tGaPms7RL1YdkNGr9EbIQKaa9EfiYGXYJOVPhaFCdeIq)0EiWCEFWfn86Ti0zsb3aCdMWaJAzT86Ti0zsb3aCdM8i6B6bWh5oXlbjc9tyGrTSw(nYc9EfLhpImEaPToeGargJcWdjLaHEILuF3cg4giMoz8q7d459VwaH2N4zZaeKCWqu5irVepTlcHTUCulRLhuobJ69cevjba69kqKbJLV8ShcmpmjDH)bluZLg4Jbg1YA5FWc1CPb(Eez8yFTSw(hSqnxAGVhrFtpa(i3jEjirOFcsgp0(8pyH6Q0aHNBGqe6NWadCgsTQK8hrWeSyPisuLgiamWbodPwvsEY9hIheSyPisuLgiayGbmvlRL)RiuJaIEjIg9Pl8LhiUVwwlpOCcg17fiQsca07vGidglpI(MEa8rUt8sqIq)eKmEO95FWc1vPbcp3aHi0pLoz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5OwwlpOCcg17fiQsca07vGidglF5zpeyEys6c)dwOMlnWhdmQL1Y)GfQ5sd89iY4X(AzT8pyHAU0aFpI(MEa8Xnqic9tyGbodPwvs(JiycwSuejQsdeag4aNHuRkjp5(dXdcwSuejQsdeamWaMQL1Y)veQrarVerJ(0f(Yde3xlRLhuobJ69cevjba69kqKbJLhrFtpa(4gieH(P9qG58(GlA41BrOZKcUb4gmHbg1YA51BrOZKcUb4gm5r030dGpYDIxcse6NWaJAzT8BKf69kkpEez8asBDiabImgfGhskbc9elP(UfmWnqmDcZ5SlyHAU0a)CEqnhKdyRls4CQuofabNJE5G)(xlGq7lhlYztF3iuopiTrAGvoXMD5SlBnDQ75G3s7tGCSdohO8gX38Ptgp0(aEE)RfqO9jE2mabjhm8bluxLgiWwxoQL1Y)GfQ5sd89iY4X(AzT8pyHAU0aFpI(MEa8Xnqic9t7RL1YZ7FTacTppI(MEa8Xnqic9t7nEO4ibD0xjadWzi1QsYZ7FTacTpXsAFceiLrApeyoVp4IgE9we6mPGBaUbtyGrTSwE9we6mPGBaUbtEe9n9a4JCN4LGeH(jmWOwwl)gzHEVIYJhrgpG0whcqGiJrb4HKsGqpXsQVBbdCdetNWCo7waLZUS10PUNdElTpbYXo4CGYBeFlh9Yb)9VwaH2xorNZgjFY5LoczbLdErh5anqKXiihxB0LdERikh8inqaYXquoxh5y4mvAvjLtJY5icoNOZPs5W7dqiCeSpDY4H2hWZ7FTacTpXZMbii5GHpBnDQ7IL0(eaBD5OwwlpV)1ci0(8LN9bYWrsrOFIb1YA559VwaH2NhrFtpW(AzT8BKf69kkpEez8asBDiabImgfGhskbc9elP(UfmWnPtgp0(aEE)RfqO9jE2mabjhmeWBeFdBD5OwwlpV)1ci0(8i6B6bWh3aHi0pLoH5CCERCIncr5OGdYro01L3TCc9t5iPvKJE5G)(xlGq7lNvJYXYzx2A6u3ZbVL2Na50OCGYBeFlNOZztJC0dOWuo9kh83)AbeAFyNtbq5a6pfB69MdjbKpDY4H2hWZ7FTacTpXZMbii5GHsfNEVIA)RyRlh1YA559VwaH2NhrFtpadE5W(V5(EJhkosqh9vcGVDsNmEO9b88(xlGq7t8SzacsoyimYE7diQiYInS1LJAzT88(xlGq7ZJOVPhGbVCy)3CFFTSwEE)RfqO95lpPtPtygZ5GxqYhcLdodPwvs5eBwKdVVW0dKtSr5y8OyYCiqOFli4Cc9t5eBwKtSr5CK7ro4V)1ci0(YXLkL5uPCqKbJLpDcZyohJhAFapV)1ci0(eH(171bodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KdE)RfqO9jqKbJLi0pHnotwih8ULWTRZZ7FTacTppI(MEamj5(dXdcwWOEWs9EficUWdTV0jmJ5Cy6gLd3aroH(PC6voXgLd4HKYCInlYXLkL5uPCEqe3aro6fDo4V)1ci0(8PtygZ5y8q7d459VwaH2Ni0VEVqYbdXzi1Qsc7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyF2NCW7FTacTpXdI4gieH(jSXzYc5acgp0(8lfrvtk9CdeIq)eMK58(GlA4xs7tcJZruO9bjJhAFEaVr8np3aHi0pbjEFWfn8lP9jHX5ik0(GiMecgpuCKGo6ReGb4mKAvj559VwaH2NyjTpbcKYibriz8q7ZVK2NabszK8CdeIq)eMecgpuCKGo6ReaFoWzi1QsYZ7FTacTpXsAFceiLrcIUnodPwvsEE)RfqO9j4giei6B6bsNWmMZX4H2hWZ7FTacTprOF9EHKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5i0pjIwW7FTacTpSXzYc5aNHuRkjpV)1ci0(eiYGXse6NsNWmMZXzqsdRCWF)RfqO9LZQr5yRGq5G3kIaHHccLt5KeaKdodPwvs(LIiqyOGqcE)RfqO9LJcYbqHpDcZyohJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKJLIiqyOGqEe9n9ayRlhHjPl8lfrGWqbH2ZCCgsTQK8lfrGWqbHe8(xlGq7lDcZyohNbjnSYb)9VwaH2xoRgLZUXGv7ICG(yigZrx5OroUuPmhE)PC61khE3s421LdO7ZNoHzmNJXdTpGN3)AbeAFIq)69cjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYrOFseTG3)AbeAFy3po(M7yJZKfYbVBjC768idwTleGhdXOhrFtpa26YbVXrNDHNrSqQD75DlHBxNhzWQDHa8yig9i6B6bC7DWugGZqQvLKp0pjIwW7FTacTV0jmNJZGKgw5G)(xlGq7lNvJYXzxrOgbYPx5W0g9Pl8PtygZ5y8q7d459VwaH2Ni0VEVqYbdXzi1Qsc7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyF2NCe6Nerl49VwaH2h29JJV5o24mzHCW7wc3Uo)xrOgbe9sen6tx4r030dGTUCWBC0zx4XrxSHfApVBjC768FfHAeq0lr0OpDHhrFtpGB7MDLb4mKAvj5d9tIOf8(xlGq7lDcZyohNbjnSYb)9VwaH2xoRgLJZGSyR2OJ8PtygZ5y8q7d459VwaH2Ni0VEVqYbdXzi1Qsc7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyF2NCe6Nerl49VwaH2h29JJV5o24mzHCW7wc3UopmzXwTrh5r030dajiulRLhMSyR2OJ8WfKfAFUDTSwEE)RfqO95Hlil0(GiMevoA1OxYdtwSbell26p26YbVXrNDH)ioQLncEpVBjC768WKfB1gDKhrFtpGBVdMYaCgsTQK8H(jr0cE)RfqO9LoHzmNJZGKgw5G)(xlGq7lNvJYXzqwSbzqo4TfB9phqyCgb5ORCIncr5yikhlYrsgiYjC15eg6LcGpDcZyohJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKJAzT8WKfB1gDKhrFtpGBxlRLN3)AbeAFE4cYcTpS1Ldu5OvJEjpmzXgqSSyR)7RL1YdtwSvB0r(YZEJhkosqh9vcGphUjDcZyohNbjnSYb)9VwaH2xoRgLtSr54m)FWcrMmh8se8zhNYPwwRC0voXgLZJ0WIq5OGCka9EZj2SiNaPhJu4tNWmMZX4H2hWZ7FTacTprOF9EHKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5i0pjIwW7FTacTpS7hhFZDSXzYc5aNHuRkjp9FWcrMu0i4ZoojGjPHLBdbE3s4215P)dwiYKIgbF2XjpCbzH2NBZ7wc3Uop9FWcrMu0i4Zoo5r030darmjZ5DlHBxNN(pyHitkAe8zhN8iYGXcBD5GWRf95HG90)blezsrJGp74u6eMXCoodsAyLd(7FTacTVCwnkNDhPbRw0iqo4XGFjSZPCscaYrJCC1fjCovkhysAyrW5i77Lq5eB2LJBW0CaeVpyGpDcZyohJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKdE3s4215FLgSArJaIQb)scmXUFxDJBC(9i6B6bWwxoi8ArFEiy)R0GvlAequn4xApVBjC768VsdwTOrar1GFjbMy3VRUXno)Ee9n9aUTBWugGZqQvLKp0pjIwW7FTacTV0jmJ5CCgK0Wkh83)AbeAF5uUqL5G)(xlGq7lhY9hfrGC0voAazqoLhF6eMXCogp0(aEE)RfqO9jc9R3lKCWqCgsTQKWUairVwIxoSJDWUaiHRnvscUbc9EDSd2N9jhH(jr0cE)RfqO9HD)44BUJnotwih1YA559VwaH2NhrFtpq6eMXCoodsAyLd(7FTacTVCkxOYC2n9UKd5(JIiqo6khnGmiNYJpDcZyohJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKJAzT8OYrIEjEAxeYJOVPhaBD5imjDHhvos0lXt7Iq7RL1YZ7FTacTppC76sNWmMZXzqsdRCWF)RfqO9LZQr5yxoK7bYYz3uokNELZU0Uiuo6kNyJYz3uokNELZU0UiuoU6IeohE)PC61khE3s421LJf5ijde5SR5aiEFWGCQ0Qruo4V)1ci0(YXvxKW(0jmJ5CmEO9b88(xlGq7te6xVxi5GH4mKAvjHDbqIETeVCyh7GDbqcxBQKeCde696yhSp7toc9tIOf8(xlGq7d7(XX3ChBCMSqo4DlHBxNhvos0lXt7IqEe9n9aqQwwlpQCKOxIN2fH8WfKfAFyRlhHjPl8OYrIEjEAxeAFTSwEE)RfqO95HBx3EE3s4215rLJe9s80UiKhrFtpaK2vgGZqQvLKp0pjIwW7FTacTV0jmJ5CCgK0Wkh83)AbeAF5ORCCgkGRps9mew5G)()TdohxDrcNZ1rovkhezWyLZQr5OroyrHpDcZyohJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKdE3s4215RL1saRaU(i1Zqyj49)BhShrFtpa26YbQC0QrVKhwbC9rQNHWsW7)3o491YA5HvaxFK6ziSe8()Td2d3UU0jmJ5C2nMcNJZmo6cGZLJZGKgw5G)(xlGq7lNvJYXGHZb8yUoqo9khmronkNFJOCmyyqoXMf54sLYCKgiYr23lHYj2SlND21CaeVpyGphMUrakhCMSqGCmeDqoY5iobagsLyLt)e63K5OxoMuMd3aeWNoHzmNJXdTpGN3)AbeAFIq)69cjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYrOFseTG3)AbeAFy3po(M7yJZKfYbYuybHJUWBWWaVEyRlhitHfeo6cVbdd8K7kia7rMcliC0fEdgg45D5c85atShzkSGWrx4nyyGhUGSq7dF7SRPtygZ5SBmfohNzC0faNlhNL0LHfiNcGYb)9VwaH2xoU0ylhCf5riRQsnWkhKPW5q4OlayNtJJqifMYXoSYbMKgwGCKkii4CSAJJYj6C(gJuoGcIYrJCEPaKtbqW5SriYNoHzmNJXdTpGN3)AbeAFIq)69cjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYrOFseTG3)AbeAFyJZKfYbYuybHJUWJRipczvj51dtYCKPWcchDHhxrEeYQsYxEWwxoqMcliC0fECf5riRkjp5UccWECgsTQK88(xlGq7tGidglrOFIbitHfeo6cpUI8iKvLKxV0jmJ5C2TakNyJY5i3JCWF)RfqO9LtF5W7wc3UUC0voAKJRUiHZ56iNkLd5(dXdcoNOZbMKgw5eBuoa(gbxKeCo9r50OCInkhaFJGlscoN(OCC1fjCoB2ZdD5ijaiNyZUCCdMMdG49bdYPsRgr5eBuol9DlYHoyGpDcZyohJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WgNjlKdCgsTQK88(xlGq7tGidglrOFcBD5aNHuRkjpV)1ci0(eiYGXse6NGeVBjC7688(xlGq7ZdxqwO9HjHWoUneWuVZgKWuVBWKHjPl8lfrGWqbHGiMmmjDHNr9GL69crg4aNHuRkjFOFseTG3)AbeAFyGbodPwvs(q)KiAbV)1ci0(W3sF3cbI(MEa32nyA6u6KXdTpGh1pINndqows7tGaPmsyRlhgpuCKGo6ReaFoWzi1QsYV1HaeiYyuSK2NabszK2dHAzT8BDiabImg9LhmWOwwl)sreiA03xEGy6KXdTpGh1pINndqqYbdxkIQMuITUCulRLhMSyR2OJ8LN9OYrRg9sEyYInGyzXw)3JZqQvLKp0pjIwW7FTacTpgulRLhMSyR2OJ8i6B6b2B8qXrc6OVsa85WnPtgp0(aEu)iE2mabjhmCjTpbcKYiHTUCy8qXrc6OVsa85aNHuRkj)MHGfCdeIL0(eiqkJ0(AzT8GYjyuVxGOkjaqVxbImyS8LN91YA5bLtWOEVarvsaGEVcezWy5r030dGpUbcrOFkDY4H2hWJ6hXZMbii5GHpyH6Q0ab26YrTSwEq5emQ3lquLeaO3Rargmw(YZ(AzT8GYjyuVxGOkjaqVxbImyS8i6B6bWh3aHi0pLoz8q7d4r9J4zZaeKCWWhSqDvAGaBD5Owwl)sreiA03xEsNmEO9b8O(r8Szacsoy4dwOUknqGTUCulRLFRdbiqKXOV8KoH5C2TakN(OCWBfr5GhPbICidjXkh9Yz307so6khS6soW9b5iNndhLdPXgHYbVGSqV3C2Tp50OCWl6ihObImgZblkYXo4Cin2iKZLdemiMZMHJY53ikNyZUCcxDoMergmwyNdeQqmNndhLJZssUdcKbysXGmih8UGWkhezWyLt05uae250OCGahI5aLmKEV5W0UW3Yrb5y8qXr(CCg9b5ih4oNytb54AtLuoBgcohUbc9EZbVL2NabszKa50OCCTrxoqlxom569czqo4rsaGEV5OGCqKbJLpDY4H2hWJ6hXZMbii5GHlfrIQ0ab2faj61s8YHDSd2fajCTPssWnqO3RJDWwxoyoodPwvs(LIirvAGq80TuV391YA5bLtWOEVarvsaGEVcezWy5HBx3EJhkosqh9vcWaCgsTQK8BgcwWnqiws7tGaPms7z(sreimuqiVXdfhThcmVwwl)gzHEVIYJV8SN51YA536qacezm6lp7z(dIWj61s8YH9lfrIQ0aXEiy8q7ZVuejQsdeE(MHEja(C4gmWacHjPl8MKCheidWKIbeRccR98ULWTRZdJS3(aIkISyZJidgliIbgaYq69kIUW38gpuCeeHy6eMZz3cOCWBfr5GhPbICin2iuoWfKEV5y5G3kIQMuYWDbluxLgiYHBGihxB0LdEbzHEV5SBFYrb5y8qXr50OCGli9EZHCN4LGYXLgB5aLmKEV5W0UW38Ptgp0(aEu)iE2mabjhmCPisuLgiWUairVwIxoSJDWUaiHRnvscUbc9EDSd26YbZXzi1QsYVuejQsdeINUL69UN5lfrGWqbH8gpuC0(AzT8GYjyuVxGOkjaqVxbImyS8WTRBpeGaemEO95xkIQMu6j3jEj07DpemEO95xkIQMu6j3jEjibI(MEagGP(DfdmyoQC0QrVKFPicen6drmWW4H2N)bluxLgi8K7eVe69Uhcgp0(8pyH6Q0aHNCN4LGei6B6byaM63vmWG5OYrRg9s(LIiq0OpeH4(AzT8BKf69kkpEez8aIyGbeaKH07veDHV5nEO4O9qOwwl)gzHEVIYJhrgp2ZCJhAFEaVr8np5oXlHEVyGbZRL1YV1HaeiYy0JiJh7zETSw(nYc9EfLhpImES34H2NhWBeFZtUt8sO37EMV1HaeiYyuaEiPei0tSK67waricX0jJhAFapQFepBgGGKdgYnPuy8q7tivqG9zFYHXdfhjctsxasNmEO9b8O(r8Szacsoy4dwOUknqGTUCulRL)bluZLg47rKXJ9CdeIq)edQL1Y)GfQ5sd89i6B6b2Znqic9tmOwwlpQCKOxIN2fH8i6B6b2dbMJkhTA0l5bLtWOEVarvsaGEVyGrTSw(hSqnxAGVhrFtpadmEO95xkIQMu65gieH(jiXnqic9tyYAzT8pyHAU0aFpImEaX0jJhAFapQFepBgGGKdg(GfQRsdeyRlh1YA536qacezm6lp7bKH07veDHV5nEO4O9gpuCKGo6ReGb4mKAvj536qacezmkws7tGaPmsPtgp0(aEu)iE2mabjhm8zRPtDxSK2NayRlhmhNHuRkj)ZwtN6U4PBPEV7HGXdfhjG7WRVNgedCdgyy8qXrc6OVsa85aNHuRkj)MHGfCdeIL0(eiqkJegyy8qXrc6OVsa85aNHuRkj)whcqGiJrXsAFceiLrcIPtgp0(aEu)iE2mabjhmeWBeFdBD5aqgsVxr0f(M34HIJsNmEO9b8O(r8SzacsoyimYE7diQiYInS1LdJhkosqh9vcGp3Koz8q7d4r9J4zZaeKCWqdXTJeK7pYgO9HTUCy8qXrc6OVsa85aNHuRkjVH42rcY9hzd0(2)TZ8p8aFoWzi1QsYBiUDKGC)r2aTpX3oBFyOxk8U0ytVDW00jmNdtMgB5qxxE3Yjm0lfaSZrJCuqowoVME5eDoCde5G3s7tGaPms5yGCwQusOC0deKbNtVYbVvevnP0Noz8q7d4r9J4zZaeKCWWL0(eiqkJe26YHXdfhjOJ(kbWNdCgsTQK8BgcwWnqiws7tGaPmsPtgp0(aEu)iE2mabjhmCPiQAsz6u6KXdTpGhe2bBiybQdl0(CSK2NabszKWwxomEO4ibD0xja(CGZqQvLKFRdbiqKXOyjTpbcKYiThc1YA536qacezm6lpyGrTSw(LIiq0OVV8aX0jJhAFapiSd2qWcuhwO9bjhmCPiQAsj26YrTSwEyYITAJoYxE2JkhTA0l5Hjl2aILfB9FpodPwvs(q)KiAbV)1ci0(yqTSwEyYITAJoYJOVPhyVXdfhjOJ(kbWNd3Koz8q7d4bHDWgcwG6WcTpi5GHpyH6Q0ab26YrTSw(LIiq0OVV8Koz8q7d4bHDWgcwG6WcTpi5GHpyH6Q0ab26YrTSw(ToeGargJ(YZ(AzT8BDiabImg9i6B6byGXdTp)sru1Ksp5oXlbjc9tPtgp0(aEqyhSHGfOoSq7dsoy4dwOUknqGTUCulRLFRdbiqKXOV8ShcpicN4Ld73XVuevnPedmwkIaHHcc5nEO4imWW4H2N)bluxLgi86jws9DlGy6eMZHPiSYj6CEPihOm54jNhuZb5OhqHPC2n9UKZZMbiqonkh83)AbeAF58SzacKJRn6Y5PbaTkjF6KXdTpGhe2bBiybQdl0(GKdgUK2NabszKWwxomEO4ibD0xja(CGZqQvLKFZqWcUbcXsAFceiLrAFTSwEq5emQ3lquLeaO3Rargmw(YZEiW7wc3UopQCKOxIN2fH8i6B6bGKXdTppQCKOxIN2fH8K7eVeKi0pbjUbcrOFcF1YA5bLtWOEVarvsaGEVcezWy5r030dGbgmpmjDHhvos0lXt7IqqCpodPwvs(q)KiAbV)1ci0(Ge3aHi0pHVAzT8GYjyuVxGOkjaqVxbImyS8i6B6bsNmEO9b8GWoydblqDyH2hKCWWhSqDvAGaBD5Owwl)whcqGiJrF5zpGmKEVIOl8nVXdfhLoz8q7d4bHDWgcwG6WcTpi5GHpyH6Q0ab26YrTSw(hSqnxAGVhrgp2Znqic9tmOwwl)dwOMlnW3JOVPhypeyoQC0QrVKhuobJ69cevjba69Ibg1YA5FWc1CPb(Ee9n9amW4H2NFPiQAsPNBGqe6NGe3aHi0pHjRL1Y)GfQ5sd89iY4betNWCooJcsV3CInkhqyhSHGZb1HfAFyNtFsSYPaOCWBfr5GhPbcqoU2OlNyJWkhdr5CDKtL07nNNULeCoRgLZUP3LCAuo4V)1ci0(85SBbuo4TIOCWJ0aroKgBekh4csV3CSCWBfrvtkz4UGfQRsde5WnqKJRn6YbVGSqV3C2Tp5OGCmEO4OCAuoWfKEV5qUt8sq54sJTCGsgsV3CyAx4B(0jJhAFapiSd2qWcuhwO9bjhmCPisuLgiWUairVwIxoSJDWUaiHRnvscUbc9EDSd26YbZxkIaHHcc5nEO4O9mhNHuRkj)srKOknqiE6wQ37(AzT8GYjyuVxGOkjaqVxbImyS8WTRBpeGaemEO95xkIQMu6j3jEj07DpemEO95xkIQMu6j3jEjibI(MEagGP(DfdmyoQC0QrVKFPicen6drmWW4H2N)bluxLgi8K7eVe69Uhcgp0(8pyH6Q0aHNCN4LGei6B6byaM63vmWG5OYrRg9s(LIiq0OpeH4(AzT8BKf69kkpEez8aIyGbeaKH07veDHV5nEO4O9qOwwl)gzHEVIYJhrgp2ZCJhAFEaVr8np5oXlHEVyGbZRL1YV1HaeiYy0JiJh7zETSw(nYc9EfLhpImES34H2NhWBeFZtUt8sO37EMV1HaeiYyuaEiPei0tSK67waricX0jJhAFapiSd2qWcuhwO9bjhm8bluxLgiWwxoQL1YV1HaeiYy0xE2B8qXrc6OVsagGZqQvLKFRdbiqKXOyjTpbcKYiLoz8q7d4bHDWgcwG6WcTpi5GHpBnDQ7IL0(eaBD5G54mKAvj5F2A6u3fpDl17DpeyEys6c)c1FrSrcdSramWW4HIJe0rFLa4BhiUhcgpuCKaUdV(EAqmWnyGHXdfhjOJ(kbWNdCgsTQK8BgcwWnqiws7tGaPmsyGHXdfhjOJ(kbWNdCgsTQK8BDiabImgflP9jqGugjiMoz8q7d4bHDWgcwG6WcTpi5GHCtkfgp0(esfeyF2NCy8qXrIWK0fG0jJhAFapiSd2qWcuhwO9bjhmegzV9bevezXg26YHXdfhjOJ(kbW3oPtgp0(aEqyhSHGfOoSq7dsoyiG3i(g26YbGmKEVIOl8nVXdfhLoz8q7d4bHDWgcwG6WcTpi5GHgIBhji3FKnq7dBD5W4HIJe0rFLa4ZbodPwvsEdXTJeK7pYgO9T)BN5F4b(CGZqQvLK3qC7ib5(JSbAFIVD2(WqVu4DPXME7GPPtyohMmn2YHUU8ULtyOxkayNJg5OGCSCEn9Yj6C4giYbVL2NabszKYXa5SuPKq5OhiidoNELdERiQAsPpDY4H2hWdc7GneSa1HfAFqYbdxs7tGaPmsyRlhgpuCKGo6ReaFoWzi1QsYVziyb3aHyjTpbcKYiLoz8q7d4bHDWgcwG6WcTpi5GHlfrvtkzd2GLf]] )
end
