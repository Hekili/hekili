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
            duration = function () return level > 55 and 12 or 10 end,
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
            cooldown = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste end,
            recharge = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste end,
            icd = 0.5,
            gcd = "off",
            castableWhileCasting = true,

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            usable = function ()
                if time == 0 then return false, "no fire_blast out of combat" end
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
            cooldown = 25,
            recharge = 25,
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


    spec:RegisterPack( "Fire", 20211101, [[deLZVeqiuu9iOuUKsbYMuk9jquJceCkqOvHIuEfiYSGIULsrSlk9luiddQchJOQLrKQNbvrMgufLRPuK2grk4BkffnoLIcNtPa16isP5bvL7re7dQs)dfjOdsKIwiuQEikIjQuiUirk0gHQQ(OsrLgPsrPtQuaRKi5LOivMPsbDtLIk2jku)eQIQHQuOwQsH0tbPPIIYvvkQAROirFffPQXcvv2lk9xcdwXHPAXs6XOAYG6YiBwjFwvA0QIttA1OiHEnky2uCBv1Uv53snCLQJJIKwoKNdmDHRlX2HkFNOmEIkNhkz9OibMpuy)IMvEwMXcf2dILXshpKU8YlpEiVv6sx6BWsx6SqdS2jwO7oNb)LyHE(NyHI)kIyHU7yzAhMLzSqbDbXjwOprSdKwgXOxnEkvlV)mcO)IXdTpoYxbJa6NZiwO1IAInWXwzHc7bXYyPJhsxE5LhpK3kDPl9ny5LoluVepnIfku9ZewOpkmmDSvwOWeGZcf)veLZMJ)sPuprSdKwgXOxnEkvlV)mcO)IXdTpoYxbJa6NZOukg34OFLq5ipM5iD8q6YNsLsXKh)EjG0MsTj5S5buol99jei676bYb5XdHYjE8lNWrVuyd9tIOfWkLZQr5yCqSjaI3hCoEvnAGvofG)saBk1MKZg2nGUC4oiYbrm1IIOpDbiNvJYHj9VwaH2xoqqTKfZCG7dYropTbohnYz1OC8Cwic8KZMdfuJYH7GaI2uQnjhPXZRgkhqGuEKd)H4mO3Bo9LJNZIKLZQrmaYrVCIhkhP5gVH5eDoicUWPCK1igmTdBtP2KCKMWmflGihpNngluxnoiYHUaHvoXJh5a3eiNRJC(nmzYrgzm5O3M86Fkhia0FobbccohpY56Ca67PlL7xKZgzJHMJ(3DEarBk1MKdt6dhHICCJjNAzTS4NfropYHUaPeiNOZPwwll(zl7yMJF54MFdIC0dOVNUuUFroBKngAoVUE5Oxoa9dSPuBsoBEaLZJJG5nmbNdohPE1qGCIohebx4uomzJ385iRrmyAh2Yc1OGaWYmwO7iI3)QhSmJLXYZYmwOop0(yH6iUFKqVGmgIhSqPZRgcMf7SblJLolZyHsNxneml2zHctaos3dTpwOB2wwoM(EZPsRgr5WK(xlGq7lhWtxmW5ei9yGcqoXJh5ei99Lq545aECebNd3d6TryLdVBdCl7YPVC64Hq5ei9yGcqoxh5uPCkacMPqwON)jwOGUye67PbHyHYrAqi1zHY8CW5i1RgYY7FTacTprFIcGYzBomphIPw09Dc2cJihEPisGJaaYKZ2CyEoHBOlSlfrGWrbHS05vdbZc15H2hluqxmc990GqSblJXtSmJfkDE1qWSyNf65FIfk4XHBzeSOrvrVerJ(0fSqDEO9Xcf84WTmcw0OQOxIOrF6c2GLX4zSmJfQZdTpwOFfHAKq)(lXcLoVAiywSZgSmEtzzglu68QHGzXoluosdcPoluMNZoIWz3Xc1vJdcwOop0(yHUJfQRgheSbBWcfMwEXeSmJLXYZYmwO05vdbZIDwOCKgesDwOmphu5OvJEjlSc46UrphHLG3)VFWw68QHGzH68q7JfkVlxqiWozmSblJLolZyHsNxneml2zH68q7Jfk4rxHEVI9wgHyHctaos3dTpwOmLos9QHYjE8ihce63dcKJShkEiuoqF0vO3BoBClJq5itnMCQuofabNtLwnIYHj9VwaH2xokihe5WyzzHYrAqi1zHwlRLL3)AbeAFw4w2LZ2CCEO9zxkIevJdcl)XrVeih8jjh5ZzBomphiKtTSww9we6CJG7aUdt2YEoBZPwwl7thcqGiNblICEKdeZzBo4CK6vdzbp6k07vS3YiKOsRgrcE)RfqO9XgSmgpXYmwO05vdbZIDwOCKgesDwO1YAz59VwaH2NfULD5SnhiKdohPE1q2q)KiAbV)1ci0(YbV548q7tW72a3YUC2KC20CGiluNhAFSqroS6xia7oIb2GLX4zSmJfkDE1qWSyNfkhPbHuNfATSwwE)RfqO9zHBzxoBZPwwllQCKOxI9wgHSWTSlNT5GZrQxnKn0pjIwW7FTacTVCWxo4CK6vdz59VwaH2NyhrCheIq)uoqkhsoIxcse6NYbs5aHCQL1YctE8uB0rw4cYdTVC2KCQL1YY7FTacTplCb5H2xoqmhMwoOYrRg9swyYJhGy5Xt)T05vdbZc15H2hluyYJNAJoInyz8MYYmwO05vdbZIDwOCKgesDwO4CK6vdzd9tIOf8(xlGq7lh8LdohPE1qwE)RfqO9j2re3bHi0pLdKYHKJ4LGeH(PC2MtTSwwE)RfqO9zHBzhluNhAFSq)kc1iGOxIOrF6c2GLXsdSmJfkDE1qWSyNfAbqczpQHeChe69YYy5zHctaos3dTpwO4FJYHPKU4bleM5uauoEo4VIOCWUXbro8hh9s5axq69MZMJIqncKtVYHzn6txKd3brorNJJRv4C4((UEV5WFC0lbSSqDEO9XcDPisunoiyHYrAqi1zH68q7Z(veQrarVerJ(0fwsoIxc9EZzBoRIXiqe)XrVKi0pLZMKJZdTp7xrOgbe9sen6txyj5iEjibI(UEGCWxo4z5SnhMNZthcqGiNbbyNmgGqpXYOVproBZH55ulRL9PdbiqKZGTSZgSmEZKLzSqPZRgcMf7SqDEO9Xc914WQhnciQo8lXcLJ0GqQZcfNJuVAiBOFseTG3)AbeAF5G3CCEO9j4DBGBzxoBsoBkluATiEio)tSqFnoS6rJaIQd)sSblJ3myzglu68QHGzXoluNhAFSqP)owiYnIgbF(XjwOCKgesDwO4CK6vdzd9tIOf8(xlGq7lh8jjhCos9QHS0Fhle5grJGp)4KaMmow5SnhCos9QHSH(jr0cE)RfqO9LdEZbNJuVAil93XcrUr0i4ZpojGjJJvoBsoBkl0Z)elu6VJfICJOrWNFCInyz8gmlZyHsNxneml2zH68q7Jfk4XHBzeSOrvrVerJ(0fSq5iniK6SqHqo4CK6vdzd9tIOf8(xlGq7lh8jjhCos9QHS8(xlGq7tSJiUdcrOFkhiLJ0ZbdmYzPVpHarFxpqo4lhCos9QHSH(jr0cE)RfqO9LdeZzBo1YAz59VwaH2NfULDSqp)tSqbpoClJGfnQk6LiA0NUGnyzS84blZyHsNxneml2zH68q7Jf6RbR9hrVeoaOF14H2hluosdcPoluiKtTSwwE)RfqO9zHBzxoBZbNJuVAiBOFseTG3)AbeAF5Gxj5GZrQxnKTprbqcEj61khmWihCos9QHS9jkasWlrVw5ijh8ihiYc98pXc91G1(JOxcha0VA8q7JnyzS8YZYmwO05vdbZIDwOop0(yH(DUxrKa8qui(fGYzHYrAqi1zHIZrQxnKn0pjIwW7FTacTVCWNKC2uwON)jwOFN7vejapefIFbOC2GLXYlDwMXcLoVAiywSZcfMaCKUhAFSq3aRCka9EZXZbeeQv4C6BtkakhnOpM54gzowGCkakNncIC4LIOCykjaGm50LaOWuo9khM0)AbeAF2CWZJhcjtbeM5SJ0gPHYuaLtbO3BoBee5Wlfr5WusaazYrMgp5WK(xlGq7lN(myLJUYzdClcDUjhM4aUdt5OGCOZRgcoh)GZXZPa8xkhz9b5iNkLJPbronocLt8q5axqEO9LtVYjEOCw67tyZHzpkihhggKJNd47gto4CtHYj6CIhkhE3g4w2LtVYzJGihEPikhMscaitoYEOlh4wV3CIhfKd3n8IXdTVCQe3lakhnYrb5uoe5gqO8CIohhakFkN4XJC0ihzQXKtLYPai4C2j0I4HbRC6lhE3g4w2zzHE(NyHcJihEPisGJaaYWcLJ0GqQZcfc5ulRLL3)AbeAFw4w2LZ2CW5i1RgYg6Nerl49VwaH2xo4vso4CK6vdz7tuaKGxIETYbdmYbNJuVAiBFIcGe8s0RvosYbpYbI5SnhiKtTSww9we6CJG7aUdtwq4CgYrso1YAz1BrOZncUd4omz)UCcq4CgYbdmYH55W7dUOHvVfHo3i4oG7WKLoVAi4CWaJCW5i1RgYY7FTacTprFIcGYbdmYbNJuVAiBOFseTG3)AbeAF5G3C0li0EB8GGfl99jei676bYzdkNCGqoop0(e8UnWTSlhiLJ84roqmhiYc15H2hluye5WlfrcCeaqg2GLXYJNyzglu68QHGzXoluNhAFSqbDXi03tdcXcLJ0GqQZcfc5GZrQxnKn0pjIwW7FTacTVCWRKCWt4romTCGqo4CK6vdz7tuaKGxIETYbV5Gh5aXCWaJCGqompNaPhduyd5TkWc6IrOVNgekNT5ei9yGcBiVTa8QHYzBobspgOWgYB5DBGBzNfrFxpqoyGrompNaPhduydPBvGf0fJqFpniuoBZjq6Xaf2q62cWRgkNT5ei9yGcBiDlVBdCl7Si676bYbI5aXC2MdeYH55qm1IUVtWwye5WlfrcCeaqMCWaJC4DBGBzNfgro8srKahbaKXIOVRhih8MZMMdezHE(NyHc6IrOVNgeInyzS84zSmJfkDE1qWSyNfQZdTpwOC)4KrulRfluosdcPoluMNdVp4Igw9we6CJG7aUdtw68QHGZzBoH(PCWxoBAoyGro1YAz1BrOZncUd4omzbHZzihj5ulRLvVfHo3i4oG7WK97YjaHZzGfATSwIZ)eluqxmc990q7Jfkmb4iDp0(yHYmK((sOCG2ftoBG3tdcLd5idw5itJNC2a3IqNBYHjoG7Wuonkhzp0LJg5iZb5SJiUdclBWYy53uwMXcLoVAiywSZcfMaCKUhAFSq3ab9b5epEKdCNZ1rov6OLg5WK(xlGq7lhWtxmW5WuSaICQuofabNtxcGct50RCys)RfqO9LJh5a6pLZERxyzHE(NyHQhGJkHxnKGPw8lkFbmHt5eluosdcPoluIPw09Dc2(ACy1Jgbevh(LYzBoqiNAzTS8(xlGq7Zc3YUC2MdohPE1q2q)KiAbV)1ci0(YbVsYbNJuVAiBFIcGe8s0RvoyGro4CK6vdz7tuaKGxIETYrso4roqKfQZdTpwO6b4Os4vdjyQf)IYxat4uoXgSmwEPbwMXcLoVAiywSZc15H2hl0LX)KOxIQhHHyHYrAqi1zHsm1IUVtW2xJdRE0iGO6WVuoBZbc5ulRLL3)AbeAFw4w2LZ2CW5i1RgYg6Nerl49VwaH2xo4vso4CK6vdz7tuaKGxIETYbdmYbNJuVAiBFIcGe8s0RvosYbpYbISqp)tSqxg)tIEjQEegInyzS8BMSmJfkDE1qWSyNfQZdTpwOYCgOJqaXc1hmluosdcPoluIPw09Dc2(ACy1Jgbevh(LYzBoqiNAzTS8(xlGq7Zc3YUC2MdohPE1q2q)KiAbV)1ci0(YbVsYbNJuVAiBFIcGe8s0RvoyGro4CK6vdz7tuaKGxIETYrso4roqKf65FIfQmNb6ieqSq9bZgSmw(ndwMXcLoVAiywSZc15H2hlu9abQWJgbeWko9irLmgwOCKgesDwOetTO77eS914WQhnciQo8lLZ2CGqo1YAz59VwaH2NfULD5SnhCos9QHSH(jr0cE)RfqO9LdELKdohPE1q2(efaj4LOxRCWaJCW5i1RgY2NOaibVe9ALJKCWJCGil0Z)elu9abQWJgbeWko9irLmg2GLXYVbZYmwO05vdbZIDwOop0(yHckx10nSW)u8GfiyHYrAqi1zHsm1IUVtW2xJdRE0iGO6WVuoBZbc5ulRLL3)AbeAFw4w2LZ2CW5i1RgYg6Nerl49VwaH2xo4vso4CK6vdz7tuaKGxIETYbdmYbNJuVAiBFIcGe8s0RvosYbpYbISqp)tSqbLRA6gw4FkEWceSblJLoEWYmwO05vdbZIDwOCKgesDwO1YAz59VwaH2NfULD5SnhCos9QHSH(jr0cE)RfqO9LdELKdohPE1q2(efaj4LOxRCWaJCW5i1RgY2NOaibVe9ALJKCWdwOop0(yHwaKqd6dydwglD5zzglu68QHGzXoluNhAFSqxOgeIRX5SqHjahP7H2hl0npGYb)rniYHXnopNOZjq67lHYzZfPadw5Sb4k3qwwOCKgesDwOOYrRg9s2xKcmyjuUYnKLoVAi4C2MtTSwwE)RfqO9zHBzxoBZbc5GZrQxnKn0pjIwW7FTacTVCWBoop0(e8UnWTSlhmWihCos9QHSH(jr0cE)RfqO9Ld(YbNJuVAilV)1ci0(e7iI7Gqe6NYbs5qYr8sqIq)uoqKnyzS0LolZyHsNxneml2zH68q7JfkVlxqiWozmSqHjahP7H2hl0nxkYjEOC2ikGR7g9Cew5WK()9doNAzTYPSJzoLZqaqo8(xlGq7lhfKdO7ZYcLJ0GqQZcfvoA1OxYcRaUUB0Zryj49)7hSLoVAi4C2MdVBdCl7S1YAjGvax3n65iSe8()9d2IihgRC2MtTSwwyfW1DJEoclbV)F)GfoI7hzHBzxoBZH55ulRLfwbCD3ONJWsW7)3pyBzpNT5aHCW5i1RgYg6Nerl49VwaH2xoqkhNhAF2fQbrTnHL7Gqe6NYbV5W72a3YoBTSwcyfW1DJEoclbV)F)GTWfKhAF5Gbg5GZrQxnKn0pjIwW7FTacTVCWxoBAoqKnyzS0XtSmJfkDE1qWSyNfkhPbHuNfkQC0QrVKfwbCD3ONJWsW7)3pylDE1qW5SnhE3g4w2zRL1saRaUUB0Zryj49)7hSfromw5SnNAzTSWkGR7g9CewcE))(blCe3pYc3YUC2MdZZPwwllSc46UrphHLG3)VFW2YEoBZbc5GZrQxnKn0pjIwW7FTacTVCGuoKCeVeKi0pLdKYX5H2NDHAquBty5oieH(PCWBo8UnWTSZwlRLawbCD3ONJWsW7)3pylCb5H2xoyGro4CK6vdzd9tIOf8(xlGq7lh8LZMMZ2CyEoHBOlSOYrIEj2BzeYsNxneCoqKfQZdTpwOoI7hji52nnq7JnyzS0XZyzglu68QHGzXoluosdcPoluu5OvJEjlSc46UrphHLG3)VFWw68QHGZzBo8UnWTSZwlRLawbCD3ONJWsW7)3pylI(UEGCWxoCheIq)uoBZPwwllSc46UrphHLG3)VFWIfQbHfULD5SnhMNtTSwwyfW1DJEoclbV)F)GTL9C2MdeYbNJuVAiBOFseTG3)AbeAF5aPC4oieH(PCWBo8UnWTSZwlRLawbCD3ONJWsW7)3pylCb5H2xoyGro4CK6vdzd9tIOf8(xlGq7lh8LZMMdezH68q7Jf6c1GO2MGnyzS03uwMXcLoVAiywSZcLJ0GqQZcfvoA1OxYcRaUUB0Zryj49)7hSLoVAi4C2MdVBdCl7S1YAjGvax3n65iSe8()9d2IihgRC2MtTSwwyfW1DJEoclbV)F)GfludclCl7YzBompNAzTSWkGR7g9CewcE))(bBl75SnhiKdohPE1q2q)KiAbV)1ci0(YbV5W72a3YoBTSwcyfW1DJEoclbV)F)GTWfKhAF5Gbg5GZrQxnKn0pjIwW7FTacTVCWxoBAoqKfQZdTpwOludcX14C2GLXsxAGLzSqPZRgcMf7Sq7DwOakyH68q7JfkohPE1qSqHjahP7H2hl0nUBtooiNVFyLd(RikhSBCqaYXb5S3aGwnuoRgLdt6FTacTpBoql1a58iNUe50RCIhkNfY5H2NBYH3)9(OlYPx5epuox5xjuo9kh8xruoy34GaKt84roYuJjNZJcYngSYbr8hh9s5axq69Mt8q5WK(xlGq7lN9hhq5ujUxauo7DB07nh)WkE07nNDhe5epEKJm1yY56iNxKFro(LdjxG8CWFfr5GDJdICGli9EZHj9VwaH2NLfko3uiwO4CK6vdzj5c6GjybV)1ci0(ei676bYbF5GZrQxnKn0pjIwW7FTacTVC2MJZdTp7srKOACqy5po6LaIfY5H2NBYbs5aHCW5i1RgYg6Nerl49VwaH2xoqkhNhAFwWJUc9Ef7TmczxfJrGi4cp0(YHPLdohPE1qwWJUc9Ef7TmcjQ0QrKG3)AbeAF5aPCGqoWuTSw2VIqnci6LiA0NUW(D5eGW5mKZMKJ85aXCyA5GZrQxnK93Har8hh9sc)3LlYHPLdVXrNFHfhDXdwOCyA5aHC4DBGBzN9RiuJaIEjIg9PlSi676bYbFsYbNJuVAiBOFseTG3)AbeAF5aXCGyomkhE3g4w2zxkIevJdclCb5H2xoBsoYNd(YH3TbULD2LIir14GW(D5e8hh9sGCGuo4CK6vdzBCeAVBJyPisunoia5WOC4DBGBzNDPisunoiSWfKhAF5Sj5aHCQL1YY7FTacTplCb5H2xomkhE3g4w2zxkIevJdclCb5H2xoqmNC2GYr(C2MdohPE1q2q)KiAbV)1ci0(YbF5S03NqGOVRhGfAbqIETeVCywglpluCosC(NyHUuejQgheI9Un69YcTaiHSh1qcUdc9EzzS8SblJL(MjlZyHsNxneml2zHYrAqi1zHIZrQxnKn0pjIwW7FTacTVCWNKCWJCWaJCQL1YY7FTacTpBzphmWihCos9QHSH(jr0cE)RfqO9Ld(YbNJuVAilV)1ci0(e7iI7Gqe6NYzBo8UnWTSZY7FTacTplI(UEGCWxo4CK6vdz59VwaH2NyhrCheIq)eluNhAFSq5UXiCEO9jmkiyHAuqio)tSq59VwaH2Ny)XbeBWYyPVzWYmwO05vdbZIDwOCKgesDwO1YAz59VwaH2NfULD5SnNAzTSOYrIEj2BzeYc3YUC2MdZZPwwl7sreiA03IiNh5SnhiKdohPE1q2q)KiAbV)1ci0(YbVsYPwwllQCKOxI9wgHSWfKhAF5SnhCos9QHSH(jr0cE)RfqO9LdEZX5H2NDPisunoiSRIXiqe)XrVKi0pLdgyKdohPE1q2q)KiAbV)1ci0(YbV5S03NqGOVRhihiMZ2CGqomphu5OvJEjlOCcg07fiQgca071sNxneCoyGroopuCKGo6Reih8kjhCos9QHSpocwWDqiwg)tGaPmq5Gbg5ulRLfuobd69cevdba69kqKdJLTSNdgyKtTSwwq5emO3lquneaO3RfropYbVsYPwwllOCcg07fiQgca071(D5eGW5mKZMKJ85Gbg5S03NqGOVRhih8LtTSwwu5irVe7TmczHlip0(YbISqDEO9Xcfvos0lXElJqSblJL(gmlZyHsNxneml2zHwaKq2JAib3bHEVSmwEwOop0(yHIZrQxnel0ENfkGcwOCKgesDwOmphCos9QHSlfrIQXbHyVBJEV5Snhu5OvJEjlOCcg07fiQgca071sNxneml0cGe9AjE5WSmwEwO4CtHyHcihP3Ri6c)X68qXr5SnhNhAF2LIir14GWUkgJar8hh9sIq)uo4nh8uomTCE5W2VlhluycWr6EO9XcvAcZuSaICIhkhCos9QHYjE8ihEFbQnGCWFfr5GDJdICka)LYj6Caookh8xruoy34GaKJSh1q5aLCKEV5WSUWFYrb548qXr5itJNCGwUCy607fYGCWUHaa9ETSqX5iX5FIf6srKOACqi272O3lBWYy8eEWYmwO05vdbZIDwOWeGJ09q7Jfkt)dD5ua69Md(B8pbcKYaLJE5WK(xlGq7dZCaookhhKZ3pSYH)4OxcKJdYzVbaTAOCwnkhM0)AbeAF5itJNUe5W99D9ETSqDEO9XcL7gJW5H2NWOGGfkiqkpyzS8Sq5iniK6SqRL1YIkhj6LyVLriBzpNT5ulRLL3)AbeAFw4w2LZ2CW5i1RgYg6Nerl49VwaH2xo4nh8GfQrbH48pXcf17I9hhqSblJXtYZYmwO05vdbZIDwOfajK9OgsWDqO3llJLNfQZdTpwO4CK6vdXcT3zHcOGfkhPbHuNfkZZbNJuVAi7srKOACqi272O3BoBZjCdDHfvos0lXElJqw68QHGZzBo1YAzrLJe9sS3YiKfULDSqlas0RL4LdZYy5zHIZnfIfkeYH55GkhTA0lzbLtWGEVar1qaGEVw68QHGZbdmYPwwllOCcg07fiQgca071ccNZqo4nNAzTSGYjyqVxGOAiaqVx73LtacNZqoBsoYNdeZzBo8UnWTSZIkhj6LyVLrilI(UEGCWxoop0(SlfrIQXbHDvmgbI4po6LeH(PC2KCCEO9zbp6k07vS3YiKDvmgbIGl8q7lhMwoqihCos9QHSGhDf69k2BzesuPvJibV)1ci0(YzBo8UnWTSZcE0vO3RyVLrilI(UEGCWxo8UnWTSZIkhj6LyVLrilI(UEGCGyoBZH3TbULDwu5irVe7Tmczr031dKd(YzPVpHarFxpaluycWr6EO9XcvAcZuSaICIhkhCos9QHYjE8ihEFbQnGCWFfr5GDJdICka)LYj6COduquoAaYH)4OxcKJJOCCdOZzVBdbNZQr5SrlhLtVYzJBzeYYcfNJeN)jwOlfrIQXbHyVBJEVSblJXtsNLzSqPZRgcMf7Sqlasi7rnKG7GqVxwglpluosdcPoluMNdohPE1q2LIir14GqS3TrV3C2MdohPE1q2q)KiAbV)1ci0(YbV5Gh5SnhNhkosqh9vcKdELKdohPE1q2hhbl4oielJ)jqGugOC2MdZZzPiceokiK15HIJYzBompNAzTSpDiabICgSL9C2MdeYPwwl7d5HEVIYUTSNZ2CCEO9zxg)tGaPmqwsoIxcsGOVRhih8LdEy30CWaJC4po6LaIfY5H2NBYbVsYr65arwOfaj61s8YHzzS8SqDEO9XcDPisunoiyHctaos3dTpwOm9p0LZM1rWChe69Md(B8pbcKYaHzo4VIOCWUXbbihWtxmW5uPCkacoNOZ5Loc5bLZMTJCGgiYzaKJFW5eDoKCbDW5GDJdccLZMJdcczzdwgJNWtSmJfkDE1qWSyNfAbqczpQHeChe69YYy5zHYrAqi1zHUuebchfeY68qXr5SnhCos9QHSH(jr0cE)RfqO9LdEZbpYzBomphCos9QHSlfrIQXbHyVBJEV5SnhiKdZZX5H2NDPiQ6gJLKJ4LqV3C2MdZZX5H2NDhluxnoiS6jwg99jYzBo1YAzFip07vu2TiY5royGroop0(Slfrv3ySKCeVe69MZ2CyEo1YAzF6qace5myrKZJCWaJCCEO9z3Xc1vJdcREILrFFIC2MtTSw2hYd9EfLDlICEKZ2CyEo1YAzF6qace5myrKZJCGil0cGe9AjE5WSmwEwOop0(yHUuejQgheSqHjahP7H2hl0nsbP3Bo4VIiq4OGqyMd(RikhSBCqaYXruofabNdq)QXrgSYj6CGli9EZHj9VwaH2NnNnx6iKBmyHzoXdHvooIYPai4CIoNx6iKhuoB2oYbAGiNbqoYEOlhosdqoYuJjNRJCQuoYCqqW54hCoY04jhSBCqqOC2CCqqimZjEiSYb80fdCovkhWoIC4C6sKt058D9cxVCIhkhSBCqqOC2CCqqOCQL1YYgSmgpHNXYmwO05vdbZIDwOfajK9OgsWDqO3llJLNfkmb4iDp0(yHknX1kCoCFFxV3CWFfr5GDJdIC4po6La5i7rnuo8h)oYO3BoqF0vO3BoBClJqSqDEO9XcDPisunoiyHYrAqi1zH68q7ZcE0vO3RyVLriljhXlHEV5SnNvXyeiI)4Oxse6NYbF548q7ZcE0vO3RyVLriBOCgeicUWdTp2GLX4PnLLzSqPZRgcMf7Sq5iniK6SqX5i1RgYg6Nerl49VwaH2xo4nh8iNT5ulRLfvos0lXElJqw4w2LZ2CQL1YY7FTacTplCl7yH68q7Jfk3ngHZdTpHrbbluJccX5FIfki8d2rWcuhEO9XgSmgpjnWYmwOop0(yHc4nI)WcLoVAiywSZgSbluuVl2FCaXYmwglplZyHsNxneml2zH68q7Jf6Y4FceiLbIfkmb4iDp0(yHUriJJvomP)1ci0(Yz1OC2CueQrGC6vomRrF6cwOCKgesDwOopuCKGo6Reih8kjhCos9QHSpDiabICgelJ)jqGugOC2MdeYPwwl7thcqGiNbBzphmWiNAzTSlfrGOrFBzphiYgSmw6SmJfkDE1qWSyNfkhPbHuNfATSwwyYJNAJoYw2ZzBoOYrRg9swyYJhGy5Xt)T05vdbNZ2CW5i1RgYg6Nerl49VwaH2xo4lNAzTSWKhp1gDKfrFxpqoBZX5HIJe0rFLa5Gxj5iDwOop0(yHUuevDJHnyzmEILzSqPZRgcMf7Sq5iniK6SqDEO4ibD0xjqo4vso4CK6vdzFCeSG7GqSm(NabszGYzBo1YAzbLtWGEVar1qaGEVce5Wyzl75SnNAzTSGYjyqVxGOAiaqVxbICySSi676bYbV5WDqic9tSqDEO9XcDz8pbcKYaXgSmgpJLzSqPZRgcMf7Sq5iniK6SqRL1YckNGb9EbIQHaa9EfiYHXYw2ZzBo1YAzbLtWGEVar1qaGEVce5Wyzr031dKdEZH7Gqe6NyH68q7Jf6owOUACqWgSmEtzzglu68QHGzXoluosdcPol0AzTSlfrGOrFBzNfQZdTpwO7yH6QXbbBWYyPbwMXcLoVAiywSZcLJ0GqQZcTwwl7thcqGiNbBzNfQZdTpwO7yH6QXbbBWY4ntwMXcLoVAiywSZcTaiHSh1qcUdc9EzzS8Sq5iniK6SqzEo4CK6vdzxkIevJdcXE3g9EZzBo1YAzbLtWGEVar1qaGEVce5WyzHBzxoBZX5HIJe0rFLa5GVCW5i1RgY(4iyb3bHyz8pbcKYaLZ2CyEolfrGWrbHSopuCuoBZbc5W8CQL1Y(qEO3ROSBl75SnhMNtTSw2NoeGarod2YEoBZH55SJiCIETeVCy7srKOACqKZ2CGqoop0(SlfrIQXbHL)4OxcKdELKJ0ZbdmYbc5eUHUW6gsoqGCatboqSkiSS05vdbNZ2C4DBGBzNfg5V9beve5XJfromw5aXCWaJCaKJ07veDH)yDEO4OCGyoqKfAbqIETeVCywglpluNhAFSqxkIevJdcwOWeGJ09q7Jf6Mhq50hLd(RikhSBCqKd5idw5OxoB0EJZrx5GvxYbUpih5844OCinEiuoBwYd9EZzZVNtJYzZ2roqde5mKdwuKJFW5qA8qiPnhi4qmNhhhLZVruoXJF5eY6CCdICySWmhiuHyopookhPPHKdeihWuGdzqo4FbHvoiYHXkNOZPaimZPr5aboeZbk5i9EZHzDH)KJcYX5HIJS5Sr6dYroWDoXJcYr2JAOCECeCoChe69Md(B8pbcKYabYPr5i7HUCGwUCy607fYGCWUHaa9EZrb5GihgllBWY4ndwMXcLoVAiywSZcTaiHSh1qcUdc9EzzS8Sq5iniK6SqzEo4CK6vdzxkIevJdcXE3g9EZzBompNLIiq4OGqwNhkokNT5ulRLfuobd69cevdba69kqKdJLfULD5SnhiKdeYbc548q7ZUuevDJXsYr8sO3BoBZbc548q7ZUuevDJXsYr8sqce9D9a5GVCWd7MMdgyKdZZbvoA1OxYUuebIg9T05vdbNdeZbdmYX5H2NDhluxnoiSKCeVe69MZ2CGqoop0(S7yH6QXbHLKJ4LGei676bYbF5Gh2nnhmWihMNdQC0QrVKDPicen6BPZRgcohiMdeZzBo1YAzFip07vu2TiY5roqmhmWihiKdGCKEVIOl8hRZdfhLZ2CGqo1YAzFip07vu2TiY5roBZH5548q7Zc4nI)yj5iEj07nhmWihMNtTSw2NoeGarodwe58iNT5W8CQL1Y(qEO3ROSBrKZJC2MJZdTplG3i(JLKJ4LqV3C2MdZZ5PdbiqKZGaStgdqONyz03NihiMdeZbISqlas0RL4LdZYy5zH68q7Jf6srKOACqWcfMaCKUhAFSq38akh8xruoy34GihsJhcLdCbP3BoEo4VIOQBmmAJXc1vJdIC4oiYr2dD5Szjp07nNn)EokihNhkokNgLdCbP3BoKCeVeuoY04jhOKJ07nhM1f(JLnyz8gmlZyHsNxneml2zH68q7Jfk3ngHZdTpHrbbluJccX5FIfQZdfhjc3qxaydwglpEWYmwO05vdbZIDwOCKgesDwO1YAz3Xc1CJd(we58iNT5WDqic9t5GVCQL1YUJfQ5gh8Ti676bYzBoCheIq)uo4lNAzTSOYrIEj2BzeYIOVRhiNT5aHCyEoOYrRg9swq5emO3lquneaO3RLoVAi4CWaJCQL1YUJfQ5gh8Ti676bYbF548q7ZUuevDJXYDqic9t5aPC4oieH(PCyA5ulRLDhluZno4BrKZJCGiluNhAFSq3Xc1vJdc2GLXYlplZyHsNxneml2zHYrAqi1zHwlRL9PdbiqKZGTSNZ2CaKJ07veDH)yDEO4OC2MJZdfhjOJ(kbYbF5GZrQxnK9PdbiqKZGyz8pbcKYaXc15H2hl0DSqD14GGnyzS8sNLzSqPZRgcMf7Sq5iniK6SqzEo4CK6vdz3FA6u5e7DB07nNT5ulRL9H8qVxrz3w2ZzBompNAzTSpDiabICgSL9C2MdeYX5HIJeWDy13tdkh8LJ0ZbdmYX5HIJe0rFLa5Gxj5GZrQxnK9XrWcUdcXY4FceiLbkhmWihNhkosqh9vcKdELKdohPE1q2NoeGarodILX)eiqkduoqKfQZdTpwO7pnDQCILX)eGnyzS84jwMXcLoVAiywSZcLJ0GqQZcfqosVxr0f(J15HIJyH68q7JfkG3i(dBWYy5XZyzglu68QHGzXoluosdcPoluNhkosqh9vcKdEZr6SqDEO9Xcfg5V9beve5XdBWYy53uwMXcLoVAiywSZcLJ0GqQZc15HIJe0rFLa5Gxj5GZrQxnK1rC)ibj3UPbAF5SnNVFUDNh5Gxj5GZrQxnK1rC)ibj3UPbAFIVFEoBZjC0lfwzA8ON84bluNhAFSqDe3psqYTBAG2hBWYy5Lgyzglu68QHGzXoluNhAFSqxg)tGaPmqSqHjahP7H2hluMEnEYHUU8(Kt4OxkayMJg5OGC8CED9Yj6C4oiYb)n(NabszGYXb5SuJHq5OhiihoNELd(RiQ6gJLfkhPbHuNfQZdfhjOJ(kbYbVsYbNJuVAi7JJGfCheILX)eiqkdeBWYy53mzzgluNhAFSqxkIQUXWcLoVAiywSZgSbluE)RfqO9j4DBGBzhGLzSmwEwMXc15H2hl09o0(yHsNxneml2zdwglDwMXc15H2hl0QPByXQGWIfkDE1qWSyNnyzmEILzSqPZRgcMf7Sq5iniK6SqRL1YY7FTacTpBzNfQZdTpwOvcbied69YgSmgpJLzSqDEO9XcDPiQA6gMfkDE1qWSyNnyz8MYYmwOop0(yH6hNabYncUBmSqPZRgcMf7SblJLgyzglu68QHGzXoluosdcPoluu5OvJEjBq)9g5gHmhTBPZRgcoNT5ulRLLK7XlGq7Zw2zH68q7JfAOFsiZr7SblJ3mzzglu68QHGzXoluNhAFSqFnoS6rJaIQd)sSqP1I4H48pXc914WQhnciQo8lXgSmEZGLzSqPZRgcMf7Sqp)tSq1dWrLWRgsWul(fLVaMWPCIfQZdTpwO6b4Os4vdjyQf)IYxat4uoXgSmEdMLzSqPZRgcMf7Sqp)tSqxg)tIEjQEegIfQZdTpwOlJ)jrVevpcdXgSmwE8GLzSqPZRgcMf7Sqp)tSqL5mqhHaIfQpywOop0(yHkZzGocbeluFWSblJLxEwMXcLoVAiywSZc98pXcvpqGk8OrabSItpsujJHfQZdTpwO6bcuHhnciGvC6rIkzmSblJLx6SmJfkDE1qWSyNf65FIfkOCvt3Wc)tXdwGGfQZdTpwOGYvnDdl8pfpybc2GLXYJNyzgluNhAFSqlasOb9bSqPZRgcMf7SbBWc15HIJeHBOlaSmJLXYZYmwO05vdbZIDwOCKgesDwOopuCKGo6Reih8MJ85SnNAzTS8(xlGq7Zc3YUC2MdeYbNJuVAiBOFseTG3)AbeAF5G3C4DBGBzN1O407vu7F1cxqEO9LdgyKdohPE1q2q)KiAbV)1ci0(YbFsYbpYbISqDEO9Xc1O407vu7FLnyzS0zzglu68QHGzXoluosdcPoluCos9QHSH(jr0cE)RfqO9Ld(KKdEKdgyKtTSwwE)RfqO9zr031dKdEZjqooYic9t5Gbg5aHC4DBGBzN9tb1ilCb5H2xo4lhCos9QHSH(jr0cE)RfqO9LZ2CyEoHBOlSOYrIEj2BzeYsNxneCoqmhmWiNWn0fwu5irVe7TmczPZRgcoNT5ulRLfvos0lXElJq2YEoBZbNJuVAiBOFseTG3)AbeAF5G3CCEO9z)uqnYY72a3YUCWaJCw67tiq031dKd(YbNJuVAiBOFseTG3)AbeAFSqDEO9Xc9tb1i2GLX4jwMXcLoVAiywSZcLJ0GqQZcnCdDH1nKCGa5aMcCGyvqyzPZRgcoNT5aHCQL1YY7FTacTplCl7YzBompNAzTSpDiabICgSL9CGiluNhAFSqHr(BFarfrE8WgSbluq4hSJGfOo8q7JLzSmwEwMXcLoVAiywSZcLJ0GqQZc15HIJe0rFLa5Gxj5GZrQxnK9PdbiqKZGyz8pbcKYaLZ2CGqo1YAzF6qace5myl75Gbg5ulRLDPicen6Bl75arwOop0(yHUm(NabszGydwglDwMXcLoVAiywSZcLJ0GqQZcTwwllm5XtTrhzl75Snhu5OvJEjlm5XdqS84P)w68QHGZzBo4CK6vdzd9tIOf8(xlGq7lh8LtTSwwyYJNAJoYIOVRhiNT548qXrc6OVsGCWRKCKoluNhAFSqxkIQUXWgSmgpXYmwO05vdbZIDwOCKgesDwO1YAzxkIarJ(2YoluNhAFSq3Xc1vJdc2GLX4zSmJfkDE1qWSyNfkhPbHuNfATSw2NoeGarod2YEoBZPwwl7thcqGiNblI(UEGCWxoop0(Slfrv3ySKCeVeKi0pXc15H2hl0DSqD14GGnyz8MYYmwO05vdbZIDwOCKgesDwO1YAzF6qace5myl75SnhiKZoIWjE5Ww5Tlfrv3yYbdmYzPiceokiK15HIJYbdmYX5H2NDhluxnoiS6jwg99jYbISqDEO9XcDhluxnoiydwglnWYmwO05vdbZIDwOop0(yHUm(NabszGyHctaos3dTpwOmdHvorNZlf5aLPd75SJAoih9akmLZgT34C2FCabYPr5WK(xlGq7lN9hhqGCK9qxo7naOvdzzHYrAqi1zH68qXrc6OVsGCWRKCW5i1RgY(4iyb3bHyz8pbcKYaLZ2CQL1YckNGb9EbIQHaa9EfiYHXYw2ZzBoqihE3g4w2zrLJe9sS3YiKfrFxpqoqkhNhAFwu5irVe7Tmczj5iEjirOFkhiLd3bHi0pLdEZPwwllOCcg07fiQgca07vGihgllI(UEGCWaJCyEoHBOlSOYrIEj2BzeYsNxneCoqmNT5GZrQxnKn0pjIwW7FTacTVCGuoCheIq)uo4nNAzTSGYjyqVxGOAiaqVxbICySSi676bydwgVzYYmwO05vdbZIDwOCKgesDwO1YAzF6qace5myl75Snha5i9Efrx4pwNhkoIfQZdTpwO7yH6QXbbBWY4ndwMXcLoVAiywSZcLJ0GqQZcTwwl7owOMBCW3IiNh5SnhUdcrOFkh8LtTSw2DSqn34GVfrFxpqoBZbc5W8CqLJwn6LSGYjyqVxGOAiaqVxlDE1qW5Gbg5ulRLDhluZno4Br031dKd(YX5H2NDPiQ6gJL7Gqe6NYbs5WDqic9t5W0YPwwl7owOMBCW3IiNh5arwOop0(yHUJfQRgheSblJ3Gzzglu68QHGzXol0cGeYEudj4oi07LLXYZcLJ0GqQZcL55SuebchfeY68qXr5SnhMNdohPE1q2LIir14GqS3TrV3C2MtTSwwq5emO3lquneaO3Raromww4w2LZ2CGqoqihiKJZdTp7sru1ngljhXlHEV5SnhiKJZdTp7sru1ngljhXlbjq031dKd(YbpSBAoyGromphu5OvJEj7sreiA03sNxneCoqmhmWihNhAF2DSqD14GWsYr8sO3BoBZbc548q7ZUJfQRghewsoIxcsGOVRhih8LdEy30CWaJCyEoOYrRg9s2LIiq0OVLoVAi4CGyoqmNT5ulRL9H8qVxrz3IiNh5aXCWaJCGqoaYr69kIUWFSopuCuoBZbc5ulRL9H8qVxrz3IiNh5SnhMNJZdTplG3i(JLKJ4LqV3CWaJCyEo1YAzF6qace5myrKZJC2MdZZPwwl7d5HEVIYUfropYzBoop0(SaEJ4pwsoIxc9EZzBompNNoeGarodcWozmaHEILrFFICGyoqmhiYcTairVwIxomlJLNfQZdTpwOlfrIQXbbluycWr6EO9XcDJuq69Mt8q5ac)GDeCoOo8q7dZC6ZGvofaLd(RikhSBCqaYr2dD5epew54ikNRJCQKEV5S3THGZz1OC2O9gNtJYHj9VwaH2NnNnpGYb)veLd2noiYH04Hq5axq69MJNd(RiQ6gdJ2ySqD14GihUdICK9qxoBwYd9EZzZVNJcYX5HIJYPr5axq69MdjhXlbLJmnEYbk5i9EZHzDH)yzdwglpEWYmwO05vdbZIDwOCKgesDwO1YAzF6qace5myl75SnhNhkosqh9vcKd(YbNJuVAi7thcqGiNbXY4FceiLbIfQZdTpwO7yH6QXbbBWYy5LNLzSqPZRgcMf7Sq5iniK6SqzEo4CK6vdz3FA6u5e7DB07nNT5aHCyEoHBOlSlu)fXdjCWdbS05vdbNdgyKJZdfhjOJ(kbYbV5iFoqmNT5aHCCEO4ibChw990GYbF5i9CWaJCCEO4ibD0xjqo4vso4CK6vdzFCeSG7GqSm(NabszGYbdmYX5HIJe0rFLa5Gxj5GZrQxnK9PdbiqKZGyz8pbcKYaLdezH68q7Jf6(ttNkNyz8pbydwglV0zzglu68QHGzXoluNhAFSq5UXiCEO9jmkiyHAuqio)tSqDEO4ir4g6caBWYy5XtSmJfkDE1qWSyNfkhPbHuNfQZdfhjOJ(kbYbV5ipluNhAFSqHr(BFarfrE8WgSmwE8mwMXcLoVAiywSZcLJ0GqQZcfqosVxr0f(J15HIJyH68q7JfkG3i(dBWYy53uwMXcLoVAiywSZcLJ0GqQZc15HIJe0rFLa5Gxj5GZrQxnK1rC)ibj3UPbAF5SnNVFUDNh5Gxj5GZrQxnK1rC)ibj3UPbAFIVFEoBZjC0lfwzA8ON84bluNhAFSqDe3psqYTBAG2hBWYy5Lgyzglu68QHGzXoluNhAFSqxg)tGaPmqSqHjahP7H2hluMEnEYHUU8(Kt4OxkayMJg5OGC8CED9Yj6C4oiYb)n(NabszGYXb5SuJHq5OhiihoNELd(RiQ6gJLfkhPbHuNfQZdfhjOJ(kbYbVsYbNJuVAi7JJGfCheILX)eiqkdeBWYy53mzzgluNhAFSqxkIQUXWcLoVAiywSZgSbluE)RfqO9j2FCaXYmwglplZyHsNxneml2zH27SqbuWc15H2hluCos9QHyHctaos3dTpwOsJGq)Eq580YYX03BomP)1ci0(YrMAm5yCqKt84hdGCIohOLlhMo9EHmihSBiaqV3CIohyki0xpkNNwwo4VIOCWUXbbihWtxmW5uPCkac2YcfNBkel0AzTS8(xlGq7ZIOVRhihiLtTSwwE)RfqO9zHlip0(YHPLdeYH3TbULDwE)RfqO9zr031dKd(YPwwllV)1ci0(Si676bYbISqlas0RL4LdZYy5zHIZrIZ)elusUGoycwW7FTacTpbI(UEawOfajK9OgsWDqO3llJLNnyzS0zzglu68QHGzXol0cGeYEudj4oi07LLXYZcfMaCKUhAFSqLMWWGCIhkh4cYdTVC6voXdLd0YLdtNEVqgKd2neaO3BomP)1ci0(Yj6CIhkh6GZPx5epuo8ccrxKdt6FTacTVC0voXdLd3broY6Ibohq4Oih4csV3CIhfKdt6FTacTpll0ENfQddZcLJ0GqQZcfvoA1OxYckNGb9EbIQHaa9ET05vdbNZ2CGqo1YAzbLtWGEVar1qaGEVce5Wyzl75Gbg5GZrQxnKLKlOdMGf8(xlGq7tGOVRhih8MZlh2IOVRhihiLJ82nnhMwoVCy73LlhMwoqiNAzTSGYjyqVxGOAiaqVx73LtacNZqoBso1YAzbLtWGEVar1qaGEVwq4CgYbI5arwO4CtHyHIZrQxnKfWqvaxqEO9XcTairVwIxomlJLNfQZdTpwO4CK6vdXcfNJeN)jwOKCbDWeSG3)AbeAFce9D9aSblJXtSmJfkDE1qWSyNfkmb4iDp0(yHINhpekhE3g4w2bYjE8ihWtxmW5uPCkacohzA8Kdt6FTacTVCapDXaNtFgSYPs5uaeCoY04jh)YX5rXn5WK(xlGq7lhUdIC8doNRJCKPXtoEoqlxomD69czqoy3qaGEV5SJAULfQZdTpwOC3yeop0(egfeSqbbs5blJLNfkhPbHuNfkohPE1qwsUGoycwW7FTacTpbI(UEGCWBo4CK6vdzbmufWfKhAFSqnkieN)jwO8(xlGq7tW72a3YoaBWYy8mwMXcLoVAiywSZc15H2hluUBmcNhAFcJccwOgfeIZ)eluNhkoseUHUaWgSmEtzzglu68QHGzXoluNhAFSq5(XjJOwwlwOCKgesDwO1YAz59VwaH2NfULD5SnNAzTSGYjyqVxGOAiaqVxliCod5G3CKEoBZjCdDHfvos0lXElJqw68QHGZzBo8UnWTSZIkhj6LyVLrilI(UEGCWxoshpyHwlRL48pXcfuobd69cevdba69YcfMaCKUhAFSq3aRCGwUCy607fYGCWUHaa9EZbeoNbqooIY5rFFWmhUFCYKt8q)CQ0QruomP)1ci0(Yb05epEKt8q5aTC5W0P3lKb5GDdba69MZoQ55W9lNkLdWxKbRCGjJJfbNt5c1KJVccLdt6FTacTVCKPXtxICqkGHC6voKC7kYdTplBWYyPbwMXcLoVAiywSZc15H2hl0LX)eiqkdeluycWr6EO9XcDdSYHj9VwaH2xokih4w2Hzo7iI7Gihq)P4rV3CQ0QruoopuCEO3BoAyzHYrAqi1zHwlRLL3)AbeAFw4w2LZ2C4DBGBzNL3)AbeAFwe9D9a5GVC4oieH(PC2MJZdfhjOJ(kbYbVsYbNJuVAilV)1ci0(elJ)jqGugi2GLXBMSmJfkDE1qWSyNfkhPbHuNfATSwwE)RfqO9zHBzxoBZPwwllOCcg07fiQgca07vGihglBzpNT5ulRLfuobd69cevdba69kqKdJLfrFxpqo4nhUdcrOFIfQZdTpwO7yH6QXbbBWY4ndwMXcLoVAiywSZcLJ0GqQZcTwwllV)1ci0(SWTSlNT5ulRLDhluZno4BrKZJC2MtTSw2DSqn34GVfrFxpqo4nhUdcrOFIfQZdTpwO7yH6QXbbBWY4nywMXcLoVAiywSZcLJ0GqQZcTwwllV)1ci0(SWTSlNT5W72a3YolV)1ci0(Si676bYbF5WDqic9t5SnhMNdVp4Ig2LX)KW5CefAFw68QHGzH68q7Jf6sru1ng2GLXYJhSmJfkDE1qWSyNfkhPbHuNfATSwwE)RfqO9zHBzxoBZH3TbULDwE)RfqO9zr031dKd(YH7Gqe6NyH68q7JfkG3i(dBWYy5LNLzSqPZRgcMf7Sqlasi7rnKG7GqVxwglpluosdcPol0NoeGarodcWozmaHEILrFFICKKdEKZ2CQL1YY7FTacTplCl7YzBo4CK6vdzd9tIOf8(xlGq7lh8jjh8iNT5aHCyEoOYrRg9swyfW1DJEoclbV)F)GT05vdbNdgyKtTSwwyfW1DJEoclbV)F)GTL9CWaJCQL1YcRaUUB0Zryj49)7hSyHAqyl75SnNWn0fwu5irVe7TmczPZRgcoNT5W72a3YoBTSwcyfW1DJEoclbV)F)GTiYHXkhiMZ2CGqomphu5OvJEj7lsbgSekx5gYsNxneCoyGroWuTSw2xKcmyjuUYnKTSNdeZzBoqihMNdVXrNFH9ioQnncohmWihE3g4w2zHjpEQn6ilI(UEGCWaJCQL1YctE8uB0r2YEoqmNT5aHCyEo8ghD(fwC0fpyHYbdmYH3TbULD2VIqnci6LiA0NUWIOVRhihiMZ2CGqoop0(SFkOgz1tSm67tKZ2CCEO9z)uqnYQNyz03NqGOVRhih8jjhCos9QHS8(xlGq7tWDqiq031dKdgyKJZdTplG3i(JLKJ4LqV3C2MJZdTplG3i(JLKJ4LGei676bYbF5GZrQxnKL3)AbeAFcUdcbI(UEGCWaJCCEO9zxkIQUXyj5iEj07nNT548q7ZUuevDJXsYr8sqce9D9a5GVCW5i1RgYY7FTacTpb3bHarFxpqoyGroop0(S7yH6QXbHLKJ4LqV3C2MJZdTp7owOUACqyj5iEjibI(UEGCWxo4CK6vdz59VwaH2NG7GqGOVRhihmWihNhAF2LX)eiqkdKLKJ4LqV3C2MJZdTp7Y4FceiLbYsYr8sqce9D9a5GVCW5i1RgYY7FTacTpb3bHarFxpqoqKfAbqIETeVCywglpluNhAFSq59VwaH2hluycWr6EO9XcLj9VwaH2xoGNUyGZPs5uaeCoYEOlN4HYzhrChe5OGCCZVbrol9uWdbBzdwglV0zzglu68QHGzXol0cGeYEudj4oi07LLXYZcLJ0GqQZcL55W7dUOHvVfHo3i4oG7WKLoVAi4C2MdZZbNJuVAi7srKOACqi272O3BoBZPwwllV)1ci0(SL9C2MdZZPwwl7sreiA03IiNh5SnhMNtTSw2NoeGarodwe58iNT580HaeiYzqa2jJbi0tSm67tKdKYPwwl7d5HEVIYUfropYHPLdeY5LdBr031dKdEZbpYbI5GVCKol0cGe9AjE5WSmwEwOop0(yHUuejQgheSqHjahP7H2hluMEnE6sKZg4we6CtomXbChMWmhMIfqKtbq5G)kIYb7gheGCK9qxoXdHvoY6dYro)YXFYHJ0aKJFW5i7HUCWFfrGOr)CuqoWTSZYgSmwE8elZyHsNxneml2zHwaKq2JAib3bHEVSmwEwOop0(yHIZrQxnel0ENfkGcwOCKgesDwO8ghD(f2tFFcXYjwOfaj61s8YHzzS8SqX5McXcDPiceokiKfrFxpqo4lhCos9QHSKCbDWeSG3)AbeAFce9D9a5SnhiKdVp4Igw9we6CJG7aUdtw68QHGZzBo4CK6vdzj52jEqWILIir14GaKd(YbNJuVAi7remblwkIevJdcqoqmNT5aHCyEoHBOlSOYrIEj2BzeYsNxneCoyGro8UnWTSZIkhj6LyVLrilI(UEGCWBo4CK6vdzj5c6GjybV)1ci0(ei676bYbI5Gbg548qXrc6OVsGCWRKCW5i1RgYY7FTacTpb4rxHEVI9wgHyHctaos3dTpwOBEaLd0hDf69MZg3YiuoWfKEV5WK(xlGq7lhzp0Lt8qikhhr5CDKdDD59jh8xruoy34GaKJJZvJxnuorNZQymyLdjxqhCo6Ti05MC4oG7Wuo(bNtFgSYr2dD5SrlhLtVYzJBzekhfKtF5W72a3YolluCosC(NyHwaKa8ORqVxXElJqSblJLhpJLzSqPZRgcMf7Sqlasi7rnKG7GqVxwglpluosdcPoluEFWfnS6Ti05gb3bChMYzBomphCos9QHSlfrIQXbHyVBJEV5SnhiKdohPE1qwsUDIheSyPisunoia5Gxj5GZrQxnK9icMGflfrIQXbbihmWiNAzTS8(xlGq7ZIOVRhih8LZlh2(D5YbdmYbNJuVAiljxqhmbl49VwaH2NarFxpqo4tso1YAz1BrOZncUd4omzHlip0(YbdmYPwwlRElcDUrWDa3HjliCod5GVCKEoyGro1YAz1BrOZncUd4omzr031dKd(Y5LdB)UC5Gbg5W72a3Yol4rxHEVI9wgHSiYHXkNT5GZrQxnKTaib4rxHEVI9wgHYbI5SnNAzTS8(xlGq7Zw2ZzBoqihMNtTSw2LIiq0OVfropYbdmYPwwlRElcDUrWDa3HjlI(UEGCWxo4HDtZbI5SnhMNtTSw2NoeGarodwe58iNT580HaeiYzqa2jJbi0tSm67tKdKYPwwl7d5HEVIYUfropYHPLdeY5LdBr031dKdEZbpYbI5GVCKol0cGe9AjE5WSmwEwOop0(yHUuejQgheSblJLFtzzglu68QHGzXoluNhAFSqxg)tGaPmqSqHjahP7H2hluO70bNZMTJCGgiYzaKdCbP3BomP)1ci0(YXJCE03NC2rAJ0allluosdcPoluiKtTSw2NoeGarod2YEoBZX5HIJe0rFLa5Gxj5GZrQxnKL3)AbeAFILX)eiqkduoqmhmWihiKtTSw2LIiq0OVTSNZ2CCEO4ibD0xjqo4vso4CK6vdz59VwaH2Nyz8pbcKYaLZMKdQC0QrVKDPicen6BPZRgcohiYgSmwEPbwMXcLoVAiywSZc15H2hluKdR(fcWUJyGfkmb4iDp0(yHUrDy1VihO7oIHCapDXaNtLYPai4CKPXtoEoB2oYbAGiNHCqKdJvorNtbq5O)pbREqgSYXxbHYjEOC4oiYzPNcEiGnhM9OGCKPgtoNhfKBmyLdGICk7545Sz7ihObICgYbStxKZQr5epuol9CtoGW5mKtVYzJ6WQFroq3DedwwOCKgesDwO1YAz59VwaH2NTSNZ2CKEomTCQL1Y(0HaeiYzWIiNh5aPCQL1Y(qEO3ROSBrKZJCGuopDiabICgeGDYyac9elJ((e5ijhPZgSmw(ntwMXcLoVAiywSZcLJ0GqQZcTwwl7sreiA03w2zH68q7Jf6owOUACqWgSmw(ndwMXcLoVAiywSZcLJ0GqQZcTwwl7thcqGiNbBzpNT5ulRLL3)AbeAF2YoluNhAFSq3Xc1vJdc2GLXYVbZYmwO05vdbZIDwOCKgesDwO7icN4LdBL3c4nI)KZ2CQL1Y(qEO3ROSBl75SnhNhkosqh9vcKd(YbNJuVAilV)1ci0(elJ)jqGugOC2MtTSwwE)RfqO9zl7SqDEO9XcDhluxnoiydwglD8GLzSqPZRgcMf7SqDEO9Xcf8ORqVxXElJqSqHjahP7H2hl0npqV3CG(ORqV3C24wgHYbUG07nhM0)AbeAF5eDoicenIYb)veLd2noiYXp4C24NMovUCWFJ)PC4po6La5W9lNkLtLoAPC1nyMtTe5uaf3yWkN(myLtF5inBPrlluosdcPoluCos9QHSfajap6k07vS3YiuoBZPwwllV)1ci0(SL9C2MdZZX5H2NDPisunoiS8hh9sGC2MJZdTp7(ttNkNyz8pbS8hh9sGCWxoop0(S7pnDQCILX)eW(D5e8hh9sa2GLXsxEwMXcLoVAiywSZc15H2hluu5irVe7TmcXcfMaCKUhAFSqHwUCy607fYGCWUHaa9EZzh1Cqo9Lt8qkkNw2Ld4Plg4CQuoWKXXIGZz1OC2ySqn34GFo7OMdYr2dD5S3aGwneM5ulroD8qizkGYH7xovkNcGGZrVCys)RfqO9LJSh6YjEieLJJOCaL1s5kDro4VIOCWUXbbWMZgyLJNd0YLdtNEVqgKd2neaO3Bo7OMNJSUyGZPs5uaemM5SrlhLtVYzJBzekhWtxmW5uPCkacoNLIaro6kN4HYHKtbHEV5SrlhLtVYzJBzekhzQXKdj3UIOCGli9EZjEOC4oiSSq5iniK6SqRL1YckNGb9EbIQHaa9EfiYHXYw2ZzBoqihCos9QHShrWeSyPisunoia5Gpj5GZrQxnKLKBN4bblwkIevJdcqoyGroWuTSw2VIqnci6LiA0NUWw2ZbI5SnhNhkosqh9vcKdELKdohPE1qwE)RfqO9jwg)tGaPmq5SnNAzTSGYjyqVxGOAiaqVxbICySSi676bYbV5qYr8sqIq)uoqkhNhAF2LX)eiqkdKL7Gqe6NydwglDPZYmwO05vdbZIDwOCKgesDwO1YAzbLtWGEVar1qaGEVce5Wyzl75SnhiKdohPE1q2JiycwSuejQgheGCWNKCW5i1RgYsYTt8GGflfrIQXbbihmWihyQwwl7xrOgbe9sen6txyl75aXC2MJZdfhjOJ(kbYbVsYbNJuVAilV)1ci0(elJ)jqGugOC2MtTSwwq5emO3lquneaO3Raromwwe9D9a5G3C4oieH(PC2MdeYH55W7dUOHvVfHo3i4oG7WKLoVAi4CWaJCQL1YQ3IqNBeChWDyYIOVRhih8MdjhXlbjc9t5Gbg5ulRL9H8qVxrz3IiNh5aPCE6qace5mia7KXae6jwg99jYbF5i9CGiluNhAFSqxg)tGaPmqSblJLoEILzSqPZRgcMf7Sq5iniK6SqRL1YckNGb9EbIQHaa9EfiYHXYw2ZzBoqihMNt4g6c7owOMBCW3sNxneCoyGro1YAz3Xc1CJd(we58iNT5ulRLDhluZno4Br031dKdEZHKJ4LGeH(PCGuoop0(S7yH6QXbHL7Gqe6NYbdmYbNJuVAi7remblwkIevJdcqo4tso4CK6vdzj52jEqWILIir14GaKdgyKdmvlRL9RiuJaIEjIg9PlSL9CGyoBZPwwllOCcg07fiQgca07vGihgllI(UEGCWBoKCeVeKi0pLdKYX5H2NDhluxnoiSCheIq)eluNhAFSqrLJe9sS3YieBWYyPJNXYmwO05vdbZIDwOCKgesDwO1YAzbLtWGEVar1qaGEVce5Wyzl75SnhiKdZZjCdDHDhluZno4BPZRgcohmWiNAzTS7yHAUXbFlICEKZ2CQL1YUJfQ5gh8Ti676bYbV5WDqic9t5Gbg5GZrQxnK9icMGflfrIQXbbih8jjhCos9QHSKC7epiyXsrKOACqaYbdmYbMQL1Y(veQrarVerJ(0f2YEoqmNT5ulRLfuobd69cevdba69kqKdJLfrFxpqo4nhUdcrOFkNT5aHCyEo8(GlAy1BrOZncUd4omzPZRgcohmWiNAzTS6Ti05gb3bChMSi676bYbV5qYr8sqIq)uoyGro1YAzFip07vu2TiY5roqkNNoeGarodcWozmaHEILrFFICWxosphiYc15H2hl0DSqD14GGnyzS03uwMXcLoVAiywSZc15H2hl0DSqD14GGfkmb4iDp0(yHUXyHAUXb)C2rnhKd4Plg4CQuofabNJE5WK(xlGq7lhpY5rFFiuo7iTrAGvoXJF5SXpnDQC5G)g)tGC8dohO8gXFSSq5iniK6SqRL1YUJfQ5gh8TiY5roBZPwwl7owOMBCW3IOVRhih8Md3bHi0pLZ2CQL1YY7FTacTplI(UEGCWBoCheIq)uoBZX5HIJe0rFLa5GVCW5i1RgYY7FTacTpXY4FceiLbkNT5aHCyEo8(GlAy1BrOZncUd4omzPZRgcohmWiNAzTS6Ti05gb3bChMSi676bYbV5qYr8sqIq)uoyGro1YAzFip07vu2TiY5roqkNNoeGarodcWozmaHEILrFFICWxosphiYgSmw6sdSmJfkDE1qWSyNfQZdTpwO7pnDQCILX)eGfkmb4iDp0(yHU5buoB8ttNkxo4VX)eih)GZbkVr8NC0lhM0)AbeAF5eDopKzpNx6iKhuoB2oYbAGiNbqoYEOlh8xruoy34GaKJJOCUoYXX5QXRgkNgLZreCorNtLYH3hGq4iylluosdcPol0AzTS8(xlGq7Zw2ZzBobYXrgrOFkh8LtTSwwE)RfqO9zr031dKZ2CQL1Y(qEO3ROSBrKZJCGuopDiabICgeGDYyac9elJ((e5GVCKoBWYyPVzYYmwO05vdbZIDwOCKgesDwO1YAz59VwaH2NfrFxpqo4nhUdcrOFIfQZdTpwOaEJ4pSblJL(MblZyHsNxneml2zH68q7JfQrXP3RO2)kluycWr6EO9XcDdSYjEieLJcoih5qxxEFYj0pLJHwro6Ldt6FTacTVCwnkhpNn(PPtLlh834FcKtJYbkVr8NCIoNhnYrpGct50RCys)RfqO9HzofaLdO)u8O3BoKbqwwOCKgesDwO1YAz59VwaH2NfrFxpqo4lNxoS97YLZ2CCEO4ibD0xjqo4nh5zdwgl9nywMXcLoVAiywSZcLJ0GqQZcTwwllV)1ci0(Si676bYbF58YHTFxUC2MtTSwwE)RfqO9zl7SqDEO9Xcfg5V9beve5XdBWgSbluCecO9XYyPJhsxE8yZq6BWSqL5OtVxaluMEP5gLXBagV5kT5KdZEOC0)EJICwnkhiJ6DX(JdiiNdIyQffrW5a6pLJxI(7bbNd)XVxcytP2q9OCKU0Mdt6dhHccohiJkhTA0lzXpiNt05azu5OvJEjl(zPZRgcgY5ab5LdI2uQnupkNntPnhM0hocfeCoqoCdDHf)GCorNdKd3qxyXplDE1qWqohiiVCq0MsTH6r5SziT5WK(WrOGGZbYOYrRg9sw8dY5eDoqgvoA1OxYIFw68QHGHCoqq6YbrBk1gQhLJ84H0Mdt6dhHccohiJkhTA0lzXpiNt05azu5OvJEjl(zPZRgcgY5ab5LdI2uQukMEP5gLXBagV5kT5KdZEOC0)EJICwnkhidtlVyciNdIyQffrW5a6pLJxI(7bbNd)XVxcytP2q9OCKxAZHj9HJqbbNdKrLJwn6LS4hKZj6CGmQC0QrVKf)S05vdbd5C8ihPr88nmhiiVCq0MsTH6r5GNjT5WK(WrOGGZbYOYrRg9sw8dY5eDoqgvoA1OxYIFw68QHGHCoEKJ0iE(gMdeKxoiAtP2q9OCKx6sBomPpCeki4CGQFMKdaRlC5YzdAdkNOZzdlEo)gUykGC6Dc5rJYbcBqqmhiiVCq0MsTH6r5iV0L2CysF4iuqW5azEFWfnS4hKZj6CGmVp4Igw8ZsNxnemKZbcYlheTPuBOEuoYJNK2CysF4iuqW5a5aPhduyL3IFqoNOZbYbspgOWgYBXpiNdeWtYbrBk1gQhLJ84jPnhM0hocfeCoqoq6XafwPBXpiNt05a5aPhduydPBXpiNdeWtYbrBk1gQhLJ84zsBomPpCeki4CGmVp4Igw8dY5eDoqM3hCrdl(zPZRgcgY5ab5LdI2uQnupkhPlV0Mdt6dhHccohiJkhTA0lzXpiNt05azu5OvJEjl(zPZRgcgY5ab5LdI2uQnupkhPlDPnhM0hocfeCoqgvoA1OxYIFqoNOZbYOYrRg9sw8ZsNxnemKZbcYlheTPuBOEuoshpjT5WK(WrOGGZbYHBOlS4hKZj6CGC4g6cl(zPZRgcgY5ab5LdI2uQnupkhPJNK2CysF4iuqW5azu5OvJEjl(b5CIohiJkhTA0lzXplDE1qWqohiiVCq0MsTH6r5iD8mPnhM0hocfeCoqgvoA1OxYIFqoNOZbYOYrRg9sw8ZsNxnemKZbcYlheTPuBOEuosFtL2CysF4iuqW5azu5OvJEjl(b5CIohiJkhTA0lzXplDE1qWqohiiVCq0MsTH6r5iDPbPnhM0hocfeCoq1ptYbG1fUC5SbLt05SHfphyfNc0(YP3jKhnkhiWiiMdeWtYbrBk1gQhLJ0LgK2CysF4iuqW5av)mjhawx4YLZg0guorNZgw8C(nCXua507eYJgLde2GGyoqqE5GOnLAd1JYr6BgsBomPpCeki4CGmQC0QrVKf)GCorNdKrLJwn6LS4NLoVAiyiNdeKxoiAtP2q9OCK(gS0Mdt6dhHccohiJkhTA0lzXpiNt05azu5OvJEjl(zPZRgcgY54rosJ45ByoqqE5GOnLAd1JYbpjV0Mdt6dhHccohiJkhTA0lzXpiNt05azu5OvJEjl(zPZRgcgY5ab5LdI2uQnupkh8K8sBomPpCeki4CGC4g6cl(b5CIohihUHUWIFw68QHGHCoqqE5GOnLkLIPxAUrz8gGXBUsBo5WShkh9V3OiNvJYbY7iI3)QhqoheXulkIGZb0FkhVe93dcoh(JFVeWMsTH6r5iDPnhM0hocfeCoqoCdDHf)GCorNdKd3qxyXplDE1qWqohpYrAepFdZbcYlheTPuPum9sZnkJ3amEZvAZjhM9q5O)9gf5SAuoqM3)AbeAFcE3g4w2bGCoiIPwuebNdO)uoEj6VheCo8h)EjGnLAd1JYrAqAZHj9HJqbbNdKrLJwn6LS4hKZj6CGmQC0QrVKf)S05vdbd5CGG8YbrBkvkftV0CJY4naJ3CL2CYHzpuo6FVrroRgLdKDEO4ir4g6caKZbrm1IIi4Ca9NYXlr)9GGZH)43lbSPuBOEuosxAZHj9HJqbbNdKd3qxyXpiNt05a5Wn0fw8ZsNxnemKZbcsxoiAtP2q9OCWtsBomPpCeki4CGC4g6cl(b5CIohihUHUWIFw68QHGHCoqqE5GOnLkLIPxAUrz8gGXBUsBo5WShkh9V3OiNvJYbYGWpyhblqD4H2hKZbrm1IIi4Ca9NYXlr)9GGZH)43lbSPuBOEuosxAZHj9HJqbbNdKrLJwn6LS4hKZj6CGmQC0QrVKf)S05vdbd5CGG8YbrBk1gQhLJ0G0Mdt6dhHccohihUHUWIFqoNOZbYHBOlS4NLoVAiyiNdeKxoiAtP2q9OC2mK2CysF4iuqW5azu5OvJEjl(b5CIohiJkhTA0lzXplDE1qWqohiiVCq0MsTH6r5SblT5WK(WrOGGZbYOYrRg9sw8dY5eDoqgvoA1OxYIFw68QHGHCoqq6YbrBk1gQhLJ8YlT5WK(WrOGGZbYHBOlS4hKZj6CGC4g6cl(zPZRgcgY5ab5LdI2uQukMEP5gLXBagV5kT5KdZEOC0)EJICwnkhiZ7FTacTpX(JdiiNdIyQffrW5a6pLJxI(7bbNd)XVxcytP2q9OCKU0Mdt6dhHccohiJkhTA0lzXpiNt05azu5OvJEjl(zPZRgcgY5ab5LdI2uQnupkNnvAZHj9HJqbbNdKd3qxyXpiNt05a5Wn0fw8ZsNxnemKZbcYlheTPuBOEuoBWsBomPpCeki4CGmVp4Igw8dY5eDoqM3hCrdl(zPZRgcgY54rosJ45ByoqqE5GOnLAd1JYrE5L2CysF4iuqW5a5Wn0fw8dY5eDoqoCdDHf)S05vdbd5CGG8YbrBk1gQhLJ8YlT5WK(WrOGGZbYOYrRg9sw8dY5eDoqgvoA1OxYIFw68QHGHCoqq6YbrBk1gQhLJ8sxAZHj9HJqbbNdK59bx0WIFqoNOZbY8(GlAyXplDE1qWqohiiVCq0MsTH6r5ipEsAZHj9HJqbbNdKd3qxyXpiNt05a5Wn0fw8ZsNxnemKZbcYlheTPuBOEuoYJNK2CysF4iuqW5azEFWfnS4hKZj6CGmVp4Igw8ZsNxnemKZbcYlheTPuBOEuoYVPsBomPpCeki4CGmQC0QrVKf)GCorNdKrLJwn6LS4NLoVAiyiNdeKxoiAtP2q9OCKU0L2CysF4iuqW5azEFWfnS4hKZj6CGmVp4Igw8ZsNxnemKZbcYlheTPuBOEuoshpjT5WK(WrOGGZbYHBOlS4hKZj6CGC4g6cl(zPZRgcgY5ab5LdI2uQnupkhPJNjT5WK(WrOGGZbYHBOlS4hKZj6CGC4g6cl(zPZRgcgY5ab5LdI2uQnupkhPJNjT5WK(WrOGGZbY8(GlAyXpiNt05azEFWfnS4NLoVAiyiNdeKxoiAtP2q9OCK(MkT5WK(WrOGGZbY8(GlAyXpiNt05azEFWfnS4NLoVAiyiNdeKxoiAtPsP2a)9gfeCoBM548q7lhJccGnLIfkyN4SmwAapXcDh1l1qSqXg2Yb)veLZMJ)sPuydB58eXoqAzeJE14PuT8(ZiG(lgp0(4iFfmcOFoJsPWg2YHXno6xjuoYJzoshpKU8PuPuydB5WKh)EjG0MsHnSLZMKZMhq5S03NqGOVRhihKhpekN4XVCch9sHn0pjIwaRuoRgLJXbXMaiEFW54v1Obw5ua(lbSPuydB5Sj5SHDdOlhUdICqetTOi6txaYz1OCys)RfqO9LdeulzXmh4(GCKZtBGZrJCwnkhpNfIap5S5qb1OC4oiGOnLcBylNnjhPXZRgkhqGuEKd)H4mO3Bo9LJNZIKLZQrmaYrVCIhkhP5gVH5eDoicUWPCK1igmTdBtPWg2YztYrAcZuSaIC8C2ySqD14Gih6cew5epEKdCtGCUoY53WKjhzKXKJEBYR)PCGaq)5eeii4C8iNRZbOVNUuUFroBKngAo6F35beTPuydB5Sj5WK(WrOih3yYPwwll(zrKZJCOlqkbYj6CQL1YIF2YoM54xoU53Gih9a67PlL7xKZgzJHMZRRxo6Ldq)aBkf2WwoBsoBEaLZJJG5nmbNdohPE1qGCIohebx4uomzJ385iRrmyAh2MsLsHnSLJ0OCeVeeCovA1ikhE)REKtLE1dyZrAY50EaY56BtEC0Fvm548q7dKtFgSSPuop0(a2DeX7F1dijHroI7hj0liJH4rkf2WwosZnEdZHP0rQxnuo457H2N0MZgyLdGICIohpNRVnHPac15GZnfcZCIhkhM0)AbeAF548q7lh)GZH3TbULDGCIhpYXruo8(abY1JGZj6C6ZGvovkNcGGZr2dD5WK(xlGq7lhfKtzphzQXKZ1rovkNcGGZbUG07nN4HYbO)IXdTpBkf2WwoydB548q7dy3reV)vpGKegHZrQxneMN)jjWkWRgsW7FTacTpm7Djicqrkf2YrAUXByomLos9QHYbpFp0(K2Cy2JcYbNJuVAOCa7exxkbYr2dfpekhM0)AbeAF5aE6IboNkLtbqW5axq69Md(RiceokiKnLcBylhNhAFa7oI49V6bKKWiCos9QHW88pjzPiceokiKG3)AbeAFy27sauGPUKW8Wn0f2DSqn34GpM4CtHKipM4CtHeKbqsWJukSLJ0CJ3WCykDK6vdLdE(EO9jT5WShfKdohPE1q5a2jUUucKt8q5CLFLq50RCch9sbihpYr2JYFYzZ2roqde5mKd(B8pbcKYabYPlbqHPC6vomP)1ci0(Yb80fdCovkNcGGTPuydB548q7dy3reV)vpGKegHZrQxneMN)jjpDiabICgelJ)jqGugim7DjakWuxsc3qxyxg)tIDp4pyIZnfsI0XeNBkKGmascEkLcB5in34nmhMshPE1q5GNVhAFsBom7rb5GZrQxnuoGDIRlLa5epuox5xjuo9kNWrVuaYXJCK9O8NC2SocohM4Gih834FceiLbcKtxcGct50RCys)RfqO9Ld4Plg4CQuofabNJdYzPgdHSPuydB548q7dy3reV)vpGKegHZrQxneMN)jjpocwWDqiwg)tGaPmqy27sauGPUKeUHUWUm(Ne7EWFWeNBkKePJjo3uibzaKe8ukf2YrAUXByomLos9QHYbpFp0(K2Cy2JcYbNJuVAOCa7exxkbYjEOCUYVsOC6voHJEPaKJh5i7r5p5Sz7ihObICgYb)n(NabszGa54ikNcGGZbUG07nhM0)AbeAF2ukSHTCCEO9bS7iI3)QhqscJW5i1RgcZZ)KeE)RfqO9jwg)tGaPmqy27sauGPUKeUHUWUm(Ne7EWFWeNBkKe8eM4CtHeKbqsKgsPWwosZnEdZHP0rQxnuo457H2N0MdZEuqo4CK6vdLdyN46sjqoXdLZv(vcLtVYjC0lfGC8ihzpk)jhPjI7hLJ0OC7MgO9LtxcGct50RCys)RfqO9Ld4Plg4CQuofabBtPWg2YX5H2hWUJiE)REajjmcNJuVAimp)tsCe3psqYTBAG2hM9UeafyQljHBOlSlJ)jXUh8hmX5McjzdEdgtCUPqcYaijspLcB5in34nmhMshPE1q5GNVhAFsBom7rb5GZrQxnuoGDIRlLa5epuo7eItx4Vuo9kNVFEovY0YYr2JYFYrAI4(r5ink3UPbAF5itnMCUoYPs5uaeSnLcBylhNhAFa7oI49V6bKKWiCos9QHW88pjXrC)ibj3UPbAFIVFoMW0YlMqcEgEGzVlbraksPWwosZnEdZHP0rQxnuo457H2N0MdZEOCUYVsOC6voHJEPaKd0hDf69MZg3YiuoGNUyGZPs5uaeCo9LdCbP3BomP)1ci0(SPuydB548q7dy3reV)vpGKegHZrQxneMN)jj8(xlGq7taE0vO3RyVLrimHPLxmHePJzVlbraksPWwosZnEdZHP0rQxnuo457H2N0MdZEOCc9t5GOVRNEV50xoEoChe5i7HUCys)RfqO9Ld3VCQuofabNJE5aiEFWaBkf2Wwoop0(a2DeX7F1dijHr4CK6vdH55FscV)1ci0(eChece9D9ayctlVycj4HDZeZExcIauKsHTCKMB8gMdtPJuVAOCWZ3dTpPnhM9OGCW5i1RgkhWoX1LsGCIhkNR8RekNELdG49bdYPx5G)kIYb7ghe5epEKd4Plg4CQuo7DBi4C2DqKt8q5atlVyIC8FxUWMsHnSLJZdTpGDhr8(x9assyeohPE1qyE(NK04i0E3gXsrKOACqaWeMwEXesWdm7Djicqrkf2YrAUXByomLos9QHYbpFp0(K2C2STSCm99MtLwnIYHj9VwaH2xoGNUyGZrA8VJfICto45i4ZpoLtLYPaiyMctPWg2YX5H2hWUJiE)REajjmcNJuVAimp)tsO)owiYnIgbF(XjbmzCSWeMwEXesKFZaZExcIauKsHnSLZgyLdt6FTacTVCuqoWkWRgcgZCa8hcUyOCIhkNLIaromP)1ci0(Yz5OC8vqOCIhkNL((e5qhmWMsHnSLd2Wwoop0(a2DeX7F1dijHr4CK6vdH55FssOFseTG3)AbeAFyIZnfsYsFFcbI(UEaijpEGhyQlj4CK6vdzHvGxnKG3)AbeAFPuylhM9q5axqEO9LtVYXZbA5YHPtVxidYb7gca07nhM0)AbeAF2ukSHTCCEO9bS7iI3)QhqscJW5i1RgcZZ)KeadvbCb5H2hM9UeafyIZnfsYMMsHTCy6FO4Hq545uaE1q5Ob9ZPai4CIoNAzTYHj9VwaH2xokihIPw09Dc2MsHnSLJZdTpGDhr8(x9assyeohPE1qyE(NKW7FTacTprFIcGWeNBkKeIPw09Dc2(ACy1Jgbevh(LWadIPw09Dc2(DUxrKa8qui(fGYXadIPw09Dc2QhGJkHxnKGPw8lkFbmHt5egyqm1IUVtWwq5QMUHf(NIhSabgyqm1IUVtWw6VJfICJOrWNFCcdmiMAr33jy7Y4Fs0lr1JWqyGbXul6(obBL5mqhHaIfQpymWGyQfDFNGT6bcuHhnciGvC6rIkzmyGbXul6(obBbpoClJGfnQk6LiA0NUiLcB5SzBz5y67nNkTAeLdt6FTacTVCapDXaNtG0Jbka5epEKtG03xcLJNd4XreCoCpO3gHvo8UnWTSlN(YPJhcLtG0Jbka5CDKtLYPaiyMctPWg2YX5H2hWUJiE)REajjmcNJuVAimp)ts6tuaKGxIETWS3LaOatCUPqsKoEGPUKGZrQxnKL3)AbeAFI(efaLsHnSLJZdTpGDhr8(x9assyeohPE1qyE(NK0NOaibVe9AHzVlbqbM4CtHKi9nftDjHyQfDFNGTFN7vejapefIFbO8ukSHTCCEO9bS7iI3)QhqscJW5i1RgcZZ)KK(efaj4LOxlm7DjakWeNBkKePJhqcNJuVAil93XcrUr0i4ZpojGjJJfM6scXul6(obBP)owiYnIgbF(XPukNhAFa7oI49V6bKKWOcGeAqFmp)tsaDXi03tdcHPUKWCCos9QHS8(xlGq7t0NOaOTmNyQfDFNGTWiYHxkIe4iaGmBzE4g6c7sreiCuqOukNhAFa7oI49V6bKKWOcGeAqFmp)tsapoClJGfnQk6LiA0NUiLY5H2hWUJiE)REajjm6RiuJe63FPukNhAFa7oI49V6bKKWODSqD14GatDjH57icNDhluxnoisPsPWg2YrAuoIxccohchHWkNq)uoXdLJZJgLJcYXX5QXRgYMs58q7diH3LlieyNmgm1LeMJkhTA0lzHvax3n65iSe8()9doLcBylhgtYwD5GZzJsG2GJYrb5a6pfp69Mt84roC)GCKtLY53WKHGTPuydB548q7dajjm6izRUCWcebAdocZcGeYEudj4oi07vI8yQljqOwwllV)1ci0(SLDmWOwwllOCcg07fiQgca07vGihgllICEaXT1YAzps2QlhSarG2GJSWTSlLcBylhM9q5W7FTacTprOF9EZX5H2xogfe5a4peCXqGCK9qxomP)1ci0(YrMAm5uPCkacoh)GZbenIa5epuoicumro6LdohPE1q2q)KiAbV)1ci0(SPuydB548q7dajjmI7gJW5H2NWOGaZZ)KeE)RfqO9jc9R3Bkf2YHP0rQxnuoXJh5qGq)EqGCK9qXdHYb6JUc9EZzJBzekhzQXKtLYPai4CQ0QruomP)1ci0(Yrb5GihglBkf2Wwoop0(aqscJW5i1RgcZZ)KeWJUc9Ef7TmcjQ0QrKG3)AbeAFy27sauGjo3uijqW5HIJe0rFLa4dNJuVAilV)1ci0(eGhDf69k2BzecdmCEO4ibD0xja(W5i1RgYY7FTacTpXY4FceiLbcdmW5i1RgYg6Nerl49VwaH23M48q7ZcE0vO3RyVLri7Qymcebx4H2hE5DBGBzNf8ORqVxXElJqw4cYdTpiUfNJuVAiBOFseTG3)AbeAFBcVBdCl7SGhDf69k2BzeYIOVRhaVop0(SGhDf69k2BzeYUkgJarWfEO9Tfc8UnWTSZIkhj6LyVLrilI(UEGnH3TbULDwWJUc9Ef7Tmczr031dG3nfdmyE4g6clQCKOxI9wgHGykLZdTpaKKWiWJUc9Ef7TmcHPUKulRLL3)AbeAFw4w2T15H2NDPisunoiS8hh9sa8jr(Tmhc1YAz1BrOZncUd4omzl7BRL1Y(0HaeiYzWIiNhqClohPE1qwWJUc9Ef7TmcjQ0QrKG3)AbeAFPuop0(aqscJqoS6xia7oIbm1LKAzTS8(xlGq7Zc3YUTqaNJuVAiBOFseTG3)AbeAF4L3TbULDBYMcXukNhAFaijHrWKhp1gDeM6ssTSwwE)RfqO9zHBz32AzTSOYrIEj2BzeYc3YUT4CK6vdzd9tIOf8(xlGq7dF4CK6vdz59VwaH2NyhrCheIq)eKi5iEjirOFcsqOwwllm5XtTrhzHlip0(2KAzTS8(xlGq7ZcxqEO9brMgQC0QrVKfM84biwE80)ukNhAFaijHrFfHAeq0lr0OpDbM6scohPE1q2q)KiAbV)1ci0(WhohPE1qwE)RfqO9j2re3bHi0pbjsoIxcse6N2wlRLL3)AbeAFw4w2LsHTCW)gLdtjDXdwimZPaOC8CWFfr5GDJdIC4po6LYbUG07nNnhfHAeiNELdZA0NUihUdICIohhxRW5W99D9EZH)4OxcytPCEO9bGKegTuejQgheywaKq2JAib3bHEVsKhtDjX5H2N9RiuJaIEjIg9PlSKCeVe69UDvmgbI4po6LeH(PnX5H2N9RiuJaIEjIg9PlSKCeVeKarFxpa(WZ2Y8NoeGarodcWozmaHEILrFFITmVwwl7thcqGiNbBzpLY5H2hassyubqcnOpM0Ar8qC(NK8ACy1Jgbevh(LWuxsW5i1RgYg6Nerl49VwaH2hE5DBGBz3MSPPuop0(aqscJkasOb9X88pjH(7yHi3iAe85hNWuxsW5i1RgYg6Nerl49VwaH2h(KGZrQxnKL(7yHi3iAe85hNeWKXXAlohPE1q2q)KiAbV)1ci0(WlohPE1qw6VJfICJOrWNFCsatghRnzttPCEO9bGKegvaKqd6J55Fsc4XHBzeSOrvrVerJ(0fyQljqaNJuVAiBOFseTG3)AbeAF4tcohPE1qwE)RfqO9j2re3bHi0pbjPJbgl99jei676bWhohPE1q2q)KiAbV)1ci0(G42AzTS8(xlGq7Zc3YUukNhAFaijHrfaj0G(yE(NK8AWA)r0lHda6xnEO9HPUKaHAzTS8(xlGq7Zc3YUT4CK6vdzd9tIOf8(xlGq7dVsW5i1RgY2NOaibVe9AHbg4CK6vdz7tuaKGxIETKGhqmLY5H2hassyubqcnOpMN)jjFN7vejapefIFbOCm1LeCos9QHSH(jr0cE)RfqO9HpjBAkf2YzdSYPa07nhphqqOwHZPVnPaOC0G(yMJBK5ybYPaOC2iiYHxkIYHPKaaYKtxcGct50RCys)RfqO9zZbppEiKmfqyMZosBKgktbuofGEV5SrqKdVueLdtjbaKjhzA8Kdt6FTacTVC6ZGvo6kNnWTi05MCyId4omLJcYHoVAi4C8dohpNcWFPCK1hKJCQuoMge504iuoXdLdCb5H2xo9kN4HYzPVpHnhM9OGCCyyqoEoGVBm5GZnfkNOZjEOC4DBGBzxo9kNncIC4LIOCykjaGm5i7HUCGB9EZjEuqoC3Wlgp0(YPsCVaOC0ihfKt5qKBaHYZj6CCaO8PCIhpYrJCKPgtovkNcGGZzNqlIhgSYPVC4DBGBzNnLY5H2hassyubqcnOpMN)jjWiYHxkIe4iaGmyQljqOwwllV)1ci0(SWTSBlohPE1q2q)KiAbV)1ci0(WReCos9QHS9jkasWlrVwyGbohPE1q2(efaj4LOxlj4be3cHAzTS6Ti05gb3bChMSGW5miPwwlRElcDUrWDa3Hj73LtacNZagyWCEFWfnS6Ti05gb3bChMWadCos9QHS8(xlGq7t0NOaimWaNJuVAiBOFseTG3)AbeAF4vVGq7TXdcwS03NqGOVRhydAdcc8UnWTSdsYJhqeIPuydB5Wyswoq7IjNnW7PbHYHUaHfM5GiJsGC6lhWJJi4C0G(5WKnso6TA03dTVCIhpYrb5CDKdwuKdOSV3OGGT5KZgL2noNa5epuo7icN2fqog9OCK9qxoRYXdTp3ytPCEO9bGKegvaKqd6J55FscOlgH(EAqim1LeiGZrQxnKn0pjIwW7FTacTp8kbpHhmniGZrQxnKTprbqcEj61cV4beXadiW8aPhduyL3QalOlgH(EAqOTbspgOWkVTa8QH2gi9yGcR8wE3g4w2zr031dGbgmpq6XafwPBvGf0fJqFpni02aPhduyLUTa8QH2gi9yGcR0T8UnWTSZIOVRhaIqCleyoXul6(obBHrKdVuejWraazWadE3g4w2zHrKdVuejWraazSi676bW7McXukSLdZq67lHYbAxm5SbEpniuoKJmyLJmnEYzdClcDUjhM4aUdt50OCK9qxoAKJmhKZoI4oiSPuop0(aqscJ4(XjJOwwlmp)tsaDXi03tdTpm1LeMZ7dUOHvVfHo3i4oG7W02q)e(2umWOwwlRElcDUrWDa3HjliCodsQL1YQ3IqNBeChWDyY(D5eGW5mKsHTC2ab9b5epEKdCNZ1rov6OLg5WK(xlGq7lhWtxmW5WuSaICQuofabNtxcGct50RCys)RfqO9LJh5a6pLZERxytPCEO9bGKegvaKqd6J55FsIEaoQeE1qcMAXVO8fWeoLtyQljetTO77eS914WQhnciQo8lTfc1YAz59VwaH2NfULDBX5i1RgYg6Nerl49VwaH2hELGZrQxnKTprbqcEj61cdmW5i1RgY2NOaibVe9AjbpGykLZdTpaKKWOcGeAqFmp)tswg)tIEjQEegctDjHyQfDFNGTVghw9Orar1HFPTqOwwllV)1ci0(SWTSBlohPE1q2q)KiAbV)1ci0(WReCos9QHS9jkasWlrVwyGbohPE1q2(efaj4LOxlj4betPCEO9bGKegvaKqd6J55FsImNb6ieqSq9bJPUKqm1IUVtW2xJdRE0iGO6WV0wiulRLL3)AbeAFw4w2TfNJuVAiBOFseTG3)AbeAF4vcohPE1q2(efaj4LOxlmWaNJuVAiBFIcGe8s0RLe8aIPuop0(aqscJkasOb9X88pjrpqGk8OrabSItpsujJbtDjHyQfDFNGTVghw9Orar1HFPTqOwwllV)1ci0(SWTSBlohPE1q2q)KiAbV)1ci0(WReCos9QHS9jkasWlrVwyGbohPE1q2(efaj4LOxlj4betPCEO9bGKegvaKqd6J55FscOCvt3Wc)tXdwGatDjHyQfDFNGTVghw9Orar1HFPTqOwwllV)1ci0(SWTSBlohPE1q2q)KiAbV)1ci0(WReCos9QHS9jkasWlrVwyGbohPE1q2(efaj4LOxlj4betPCEO9bGKegvaKqd6dWuxsQL1YY7FTacTplCl72IZrQxnKn0pjIwW7FTacTp8kbNJuVAiBFIcGe8s0RfgyGZrQxnKTprbqcEj61scEKsHTC28akh8h1Gihg348CIoNaPVVekNnxKcmyLZgGRCdztPCEO9bGKegTqniexJZXuxsqLJwn6LSVifyWsOCLBOT1YAz59VwaH2NfULDBHaohPE1q2q)KiAbV)1ci0(WlVBdCl7WadCos9QHSH(jr0cE)RfqO9HpCos9QHS8(xlGq7tSJiUdcrOFcsKCeVeKi0pbXukSLZMlf5epuoBefW1DJEocRCys))(bNtTSw5u2XmNYziaihE)RfqO9LJcYb09ztPCEO9bGKegX7YfecStgdM6scQC0QrVKfwbCD3ONJWsW7)3p4T8UnWTSZwlRLawbCD3ONJWsW7)3pylICyS2wlRLfwbCD3ONJWsW7)3pyHJ4(rw4w2TL51YAzHvax3n65iSe8()9d2w23cbCos9QHSH(jr0cE)RfqO9bjNhAF2fQbrTnHL7Gqe6NWlVBdCl7S1YAjGvax3n65iSe8()9d2cxqEO9Hbg4CK6vdzd9tIOf8(xlGq7dFBketPCEO9bGKeg5iUFKGKB30aTpm1Leu5OvJEjlSc46UrphHLG3)VFWB5DBGBzNTwwlbSc46UrphHLG3)VFWwe5WyTTwwllSc46UrphHLG3)VFWchX9JSWTSBlZRL1YcRaUUB0Zryj49)7hSTSVfc4CK6vdzd9tIOf8(xlGq7dsKCeVeKi0pbjNhAF2fQbrTnHL7Gqe6NWlVBdCl7S1YAjGvax3n65iSe8()9d2cxqEO9Hbg4CK6vdzd9tIOf8(xlGq7dFB6wMhUHUWIkhj6LyVLriiMs58q7dajjmAHAquBtGPUKGkhTA0lzHvax3n65iSe8()9dElVBdCl7S1YAjGvax3n65iSe8()9d2IOVRhaFCheIq)02AzTSWkGR7g9CewcE))(blwOgew4w2TL51YAzHvax3n65iSe8()9d2w23cbCos9QHSH(jr0cE)RfqO9bjUdcrOFcV8UnWTSZwlRLawbCD3ONJWsW7)3pylCb5H2hgyGZrQxnKn0pjIwW7FTacTp8TPqmLY5H2hassy0c1GqCnohtDjbvoA1OxYcRaUUB0Zryj49)7h8wE3g4w2zRL1saRaUUB0Zryj49)7hSfromwBRL1YcRaUUB0Zryj49)7hSyHAqyHBz3wMxlRLfwbCD3ONJWsW7)3pyBzFleW5i1RgYg6Nerl49VwaH2hE5DBGBzNTwwlbSc46UrphHLG3)VFWw4cYdTpmWaNJuVAiBOFseTG3)AbeAF4BtHykf2YzJ72KJdY57hw5G)kIYb7gheGCCqo7naOvdLZQr5WK(xlGq7ZMd0snqopYPlro9kN4HYzHCEO95MC49FVp6IC6voXdLZv(vcLtVYb)veLd2noia5epEKJm1yY58OGCJbRCqe)XrVuoWfKEV5epuomP)1ci0(Yz)XbuovI7faLZE3g9EZXpSIh9EZz3broXJh5itnMCUoY5f5xKJF5qYfiph8xruoy34Gih4csV3Cys)RfqO9ztPCEO9bGKegHZrQxneMfaj61s8YHLipMfajK9OgsWDqO3Re5X88pjzPisunoie7DB07ftCUPqsW5i1RgYsYf0btWcE)RfqO9jq031dGpCos9QHSH(jr0cE)RfqO9T15H2NDPisunoiS8hh9saXc58q7Znqcc4CK6vdzd9tIOf8(xlGq7dsop0(SGhDf69k2BzeYUkgJarWfEO9X0W5i1RgYcE0vO3RyVLrirLwnIe8(xlGq7dsqaMQL1Y(veQrarVerJ(0f2VlNaeoNHnrEiY0W5i1RgY(7qGi(JJEjH)7YfmnEJJo)clo6IhSqmniW72a3Yo7xrOgbe9sen6txyr031dGpj4CK6vdzd9tIOf8(xlGq7dIqCdI3TbULD2LIir14GWcxqEO9TjYJpE3g4w2zxkIevJdc73LtWFC0lbGeohPE1q2ghH272iwkIevJdcWgeVBdCl7SlfrIQXbHfUG8q7BtGqTSwwE)RfqO9zHlip0(2G4DBGBzNDPisunoiSWfKhAFqCdAds(T4CK6vdzd9tIOf8(xlGq7dFl99jei676bsPCEO9bGKegXDJr48q7tyuqG55FscV)1ci0(e7poGWuxsW5i1RgYg6Nerl49VwaH2h(KGhyGrTSwwE)RfqO9zl7yGbohPE1q2q)KiAbV)1ci0(WhohPE1qwE)RfqO9j2re3bHi0pTL3TbULDwE)RfqO9zr031dGpCos9QHS8(xlGq7tSJiUdcrOFkLY5H2hassyeQCKOxI9wgHWuxsQL1YY7FTacTplCl72wlRLfvos0lXElJqw4w2TL51YAzxkIarJ(we58yleW5i1RgYg6Nerl49VwaH2hELulRLfvos0lXElJqw4cYdTVT4CK6vdzd9tIOf8(xlGq7dVop0(SlfrIQXbHDvmgbI4po6LeH(jmWaNJuVAiBOFseTG3)AbeAF4DPVpHarFxpae3cbMJkhTA0lzbLtWGEVar1qaGEVyGHZdfhjOJ(kbWReCos9QHSpocwWDqiwg)tGaPmqyGrTSwwq5emO3lquneaO3Raromw2YogyulRLfuobd69cevdba69ArKZd8kPwwllOCcg07fiQgca071(D5eGW5mSjYJbgl99jei676bWxTSwwu5irVe7TmczHlip0(Gykf2YrAcZuSaICIhkhCos9QHYjE8ihEFbQnGCWFfr5GDJdICka)LYj6Caookh8xruoy34GaKJSh1q5aLCKEV5WSUWFYrb548qXr5itJNCGwUCy607fYGCWUHaa9ETPuop0(aqscJW5i1RgcZcGe9AjE5WsKhZcGeYEudj4oi07vI8yE(NKSuejQgheI9Un69Ijo3uijaYr69kIUWFSopuC0wNhAF2LIir14GWUkgJar8hh9sIq)eEXtmTxoS97YHPUKWCCos9QHSlfrIQXbHyVBJEVBrLJwn6LSGYjyqVxGOAiaqV3ukSLdtPJuVAOCIhpYH3xGAdiNn(PPtLlh834FcKtb4VuorNdDGcIYrdqo8hh9sGCCeLZE3gcoNvJYHj9VwaH2Nnh88ZGvofaLZg)00PYLd(B8pbYPlbqHPC6vomP)1ci0(Yr2dD5Skgto8hh9sGC4(LtLYPRHRhbNdCbP3BoXdLZrYf5WK(xlGq7ZMsHnSLJZdTpaKKWiCos9QHW88pjz)PPtLtS3TrVxm1LeNhkosqh9vcGpCos9QHS8(xlGq7tSm(NabszGWeNBkKeCos9QHSH(jr0cE)RfqO9bPAzTS8(xlGq7ZcxqEO9TjBk(CEO9z3FA6u5elJ)jGDvmgbI4po6LeH(jiX72a3Yo7(ttNkNyz8pbSWfKhAFBIZdTpl4rxHEVI9wgHSRIXiqeCHhAFmnCos9QHSGhDf69k2BzesuPvJibV)1ci0(2IZrQxnKn0pjIwW7FTacTp8T03NqGOVRhadmqLJwn6LSGYjyqVxGOAiaqVxmWi0pHVnnLcB5W0)qxofGEV5G)g)tGaPmq5OxomP)1ci0(WmhGJJYXb589dRC4po6La54GC2BaqRgkNvJYHj9VwaH2xoY04PlroCFFxVxBkf2Wwoop0(aqscJW5i1RgcZZ)KK9NMovoXE3g9EXuxsCEO4ibD0xjaELGZrQxnKL3)AbeAFILX)eiqkdeM4CtHKGZrQxnKn0pjIwW7FTacTp858q7ZU)00PYjwg)ta7QymceXFC0ljc9tBIZdTpl4rxHEVI9wgHSRIXiqeCHhAFmnCos9QHSGhDf69k2BzesuPvJibV)1ci0(2IZrQxnKn0pjIwW7FTacTp8T03NqGOVRhadmqLJwn6LSGYjyqVxGOAiaqVxmWi0pHVnnLY5H2hassye3ngHZdTpHrbbMN)jjOExS)4actqGuEirEm1LKAzTSOYrIEj2BzeYw23wlRLL3)AbeAFw4w2TfNJuVAiBOFseTG3)AbeAF4fpsPWwostyMIfqKt8q5GZrQxnuoXJh5W7lqTbKd(RikhSBCqKtb4VuorNdDGcIYrdqo8hh9sGCCeLJBaDo7DBi4CwnkNnA5OC6voBClJq2ukNhAFaijHr4CK6vdHzbqIETeVCyjYJzbqczpQHeChe69krEmp)tswkIevJdcXE3g9EXeNBkKeiWCu5OvJEjlOCcg07fiQgca07fdmQL1YckNGb9EbIQHaa9ETGW5mG3AzTSGYjyqVxGOAiaqVx73LtacNZWMipe3Y72a3YolQCKOxI9wgHSi676bWNZdTp7srKOACqyxfJrGi(JJEjrOFAtCEO9zbp6k07vS3YiKDvmgbIGl8q7JPbbCos9QHSGhDf69k2BzesuPvJibV)1ci0(2Y72a3Yol4rxHEVI9wgHSi676bWhVBdCl7SOYrIEj2BzeYIOVRhaIB5DBGBzNfvos0lXElJqwe9D9a4BPVpHarFxpaM6scZX5i1RgYUuejQgheI9Un69UnCdDHfvos0lXElJqBRL1YIkhj6LyVLrilCl7sPWwom9p0LZM1rWChe69Md(B8pbcKYaHzo4VIOCWUXbbihWtxmW5uPCkacoNOZ5Loc5bLZMTJCGgiYzaKJFW5eDoKCbDW5GDJdccLZMJdccztPCEO9bGKegTuejQgheywaKOxlXlhwI8ywaKq2JAib3bHEVsKhtDjH54CK6vdzxkIevJdcXE3g9E3IZrQxnKn0pjIwW7FTacTp8IhBDEO4ibD0xjaELGZrQxnK9XrWcUdcXY4FceiLbAlZxkIaHJcczDEO4OTmVwwl7thcqGiNbBzFleQL1Y(qEO3ROSBl7BDEO9zxg)tGaPmqwsoIxcsGOVRhaF4HDtXad(JJEjGyHCEO95g8kr6qmLcB5Srki9EZb)vebchfecZCWFfr5GDJdcqooIYPai4Ca6xnoYGvorNdCbP3BomP)1ci0(S5S5shHCJblmZjEiSYXruofabNt058shH8GYzZ2roqde5maYr2dD5WrAaYrMAm5CDKtLYrMdccoh)GZrMgp5GDJdccLZMJdccHzoXdHvoGNUyGZPs5a2rKdNtxICIoNVRx46Lt8q5GDJdccLZMJdccLtTSw2ukNhAFaijHrlfrIQXbbMfaj61s8YHLipMfajK9OgsWDqO3Re5XuxswkIaHJcczDEO4OT4CK6vdzd9tIOf8(xlGq7dV4XwMJZrQxnKDPisunoie7DB07DleyUZdTp7sru1ngljhXlHEVBzUZdTp7owOUACqy1tSm67tSTwwl7d5HEVIYUfropWadNhAF2LIOQBmwsoIxc9E3Y8AzTSpDiabICgSiY5bgy48q7ZUJfQRghew9elJ((eBRL1Y(qEO3ROSBrKZJTmVwwl7thcqGiNblICEaXukSLJ0exRW5W99D9EZb)veLd2noiYH)4OxcKJSh1q5WF87iJEV5a9rxHEV5SXTmcLs58q7dajjmAPisunoiWSaiHSh1qcUdc9ELipM6sIZdTpl4rxHEVI9wgHSKCeVe69UDvmgbI4po6LeH(j858q7ZcE0vO3RyVLriBOCgeicUWdTVukNhAFaijHrC3yeop0(egfeyE(NKac)GDeSa1HhAFyQlj4CK6vdzd9tIOf8(xlGq7dV4X2AzTSOYrIEj2BzeYc3YUT1YAz59VwaH2NfULDPuop0(aqscJa8gXFsPsPCEO9bSopuCKiCdDbqIrXP3RO2)kM6sIZdfhjOJ(kbWR8BRL1YY7FTacTplCl72cbCos9QHSH(jr0cE)RfqO9HxE3g4w2znko9Ef1(xTWfKhAFyGbohPE1q2q)KiAbV)1ci0(WNe8aIPuop0(awNhkoseUHUaajjm6tb1im1LeCos9QHSH(jr0cE)RfqO9Hpj4bgyulRLL3)AbeAFwe9D9a4nqooYic9tyGbe4DBGBzN9tb1ilCb5H2h(W5i1RgYg6Nerl49VwaH23wMhUHUWIkhj6LyVLriiIbgHBOlSOYrIEj2BzeABTSwwu5irVe7Tmczl7BX5i1RgYg6Nerl49VwaH2hEDEO9z)uqnYY72a3YomWyPVpHarFxpa(W5i1RgYg6Nerl49VwaH2xkLZdTpG15HIJeHBOlaqscJGr(BFarfrE8GPUKeUHUW6gsoqGCatboqSkiS2cHAzTS8(xlGq7Zc3YUTmVwwl7thcqGiNbBzhIPuPuop0(awE)RfqO9j4DBGBzhqYEhAFPuop0(awE)RfqO9j4DBGBzhassyu10nSyvqyLs58q7dy59VwaH2NG3TbULDaijHrvcbied69IPUKulRLL3)AbeAF2YEkLZdTpGL3)AbeAFcE3g4w2bGKegTuevnDdNs58q7dy59VwaH2NG3TbULDaijHr(XjqGCJG7gtkLZdTpGL3)AbeAFcE3g4w2bGKegf6NeYC0oM6scQC0QrVKnO)EJCJqMJ23wlRLLK7XlGq7Zw2tPCEO9bS8(xlGq7tW72a3YoaKKWOcGeAqFmP1I4H48pj514WQhnciQo8lLs58q7dy59VwaH2NG3TbULDaijHrfaj0G(yE(NKOhGJkHxnKGPw8lkFbmHt5ukLZdTpGL3)AbeAFcE3g4w2bGKegvaKqd6J55FsYY4Fs0lr1JWqPuop0(awE)RfqO9j4DBGBzhassyubqcnOpMN)jjYCgOJqaXc1hCkLZdTpGL3)AbeAFcE3g4w2bGKegvaKqd6J55FsIEGav4rJacyfNEKOsgtkLZdTpGL3)AbeAFcE3g4w2bGKegvaKqd6J55FscOCvt3Wc)tXdwGiLY5H2hWY7FTacTpbVBdCl7aqscJkasOb9bPuPuylhPrqOFpOCEAz5y67nhM0)AbeAF5itnMCmoiYjE8JbqorNd0YLdtNEVqgKd2neaO3BorNdmfe6RhLZtllh8xruoy34GaKd4Plg4CQuofabBtPCEO9bS8(xlGq7tS)4acssyeohPE1qywaKOxlXlhwI8ywaKq2JAib3bHEVsKhZZ)KesUGoycwW7FTacTpbI(UEamX5McjPwwllV)1ci0(Si676bGuTSwwE)RfqO9zHlip0(yAqG3TbULDwE)RfqO9zr031dGVAzTS8(xlGq7ZIOVRhaIPuylhPjmmiN4HYbUG8q7lNELt8q5aTC5W0P3lKb5GDdba69Mdt6FTacTVCIoN4HYHo4C6voXdLdVGq0f5WK(xlGq7lhDLt8q5WDqKJSUyGZbeokYbUG07nN4rb5WK(xlGq7ZMs58q7dy59VwaH2Ny)XbeKKWiCos9QHWSairVwIxoSe5XSaiHSh1qcUdc9ELipMN)jjKCbDWeSG3)AbeAFce9D9ay27sCyymX5McjbNJuVAilGHQaUG8q7dtDjbvoA1OxYckNGb9EbIQHaa9E3cHAzTSGYjyqVxGOAiaqVxbICySSLDmWaNJuVAiljxqhmbl49VwaH2NarFxpaEF5Wwe9D9aqsE7MY0E5W2Vlhtdc1YAzbLtWGEVar1qaGEV2VlNaeoNHnPwwllOCcg07fiQgca071ccNZaeHykf2YbppEiuo8UnWTSdKt84roGNUyGZPs5uaeCoY04jhM0)AbeAF5aE6IboN(myLtLYPai4CKPXto(LJZJIBYHj9VwaH2xoChe54hCoxh5itJNC8CGwUCy607fYGCWUHaa9EZzh1CBkLZdTpGL3)AbeAFI9hhqqscJ4UXiCEO9jmkiW88pjH3)AbeAFcE3g4w2bWeeiLhsKhtDjbNJuVAiljxqhmbl49VwaH2NarFxpaEX5i1RgYcyOkGlip0(sPCEO9bS8(xlGq7tS)4acssye3ngHZdTpHrbbMN)jjopuCKiCdDbiLcB5Sbw5aTC5W0P3lKb5GDdba69MdiCodGCCeLZJ((GzoC)4KjN4H(5uPvJOCys)RfqO9LdOZjE8iN4HYbA5YHPtVxidYb7gca07nNDuZZH7xovkhGVidw5atghlcoNYfQjhFfekhM0)AbeAF5itJNUe5Guad50RCi52vKhAF2ukNhAFalV)1ci0(e7poGGKegX9JtgrTSwyE(NKakNGb9EbIQHaa9EXuxsQL1YY7FTacTplCl72wlRLfuobd69cevdba69AbHZzaVsFB4g6clQCKOxI9wgH2Y72a3YolQCKOxI9wgHSi676bWN0XJukSLZgyLdt6FTacTVCuqoWTSdZC2re3broG(tXJEV5uPvJOCCEO48qV3C0WMs58q7dy59VwaH2Ny)XbeKKWOLX)eiqkdeM6ssTSwwE)RfqO9zHBz3wE3g4w2z59VwaH2NfrFxpa(4oieH(PTopuCKGo6ReaVsW5i1RgYY7FTacTpXY4FceiLbkLY5H2hWY7FTacTpX(JdiijHr7yH6QXbbM6ssTSwwE)RfqO9zHBz32AzTSGYjyqVxGOAiaqVxbICySSL9T1YAzbLtWGEVar1qaGEVce5Wyzr031dGxUdcrOFkLY5H2hWY7FTacTpX(JdiijHr7yH6QXbbM6ssTSwwE)RfqO9zHBz32AzTS7yHAUXbFlICESTwwl7owOMBCW3IOVRhaVCheIq)ukLZdTpGL3)AbeAFI9hhqqscJwkIQUXGPUKulRLL3)AbeAFw4w2TL3TbULDwE)RfqO9zr031dGpUdcrOFAlZ59bx0WUm(NeoNJOq7lLY5H2hWY7FTacTpX(JdiijHraEJ4pyQlj1YAz59VwaH2NfULDB5DBGBzNL3)AbeAFwe9D9a4J7Gqe6NsPWwomP)1ci0(Yb80fdCovkNcGGZr2dD5epuo7iI7GihfKJB(niYzPNcEiyBkLZdTpGL3)AbeAFI9hhqqscJ49VwaH2hMfaj61s8YHLipMfajK9OgsWDqO3Re5XuxsE6qace5mia7KXae6jwg99jKGhBRL1YY7FTacTplCl72IZrQxnKn0pjIwW7FTacTp8jbp2cbMJkhTA0lzHvax3n65iSe8()9dgdmQL1YcRaUUB0Zryj49)7hSTSJbg1YAzHvax3n65iSe8()9dwSqniSL9THBOlSOYrIEj2BzeAlVBdCl7S1YAjGvax3n65iSe8()9d2IihgliUfcmhvoA1OxY(IuGblHYvUHWadyQwwl7lsbgSekx5gYw2H4wiWCEJJo)c7rCuBAemgyW72a3Yolm5XtTrhzr031dGbg1YAzHjpEQn6iBzhIBHaZ5no68lS4OlEWcHbg8UnWTSZ(veQrarVerJ(0fwe9D9aqCleCEO9z)uqnYQNyz03NyRZdTp7NcQrw9elJ((ece9D9a4tcohPE1qwE)RfqO9j4oiei676bWadNhAFwaVr8hljhXlHEVBDEO9zb8gXFSKCeVeKarFxpa(W5i1RgYY7FTacTpb3bHarFxpagy48q7ZUuevDJXsYr8sO37wNhAF2LIOQBmwsoIxcsGOVRhaF4CK6vdz59VwaH2NG7GqGOVRhadmCEO9z3Xc1vJdcljhXlHEVBDEO9z3Xc1vJdcljhXlbjq031dGpCos9QHS8(xlGq7tWDqiq031dGbgop0(SlJ)jqGugiljhXlHEVBDEO9zxg)tGaPmqwsoIxcsGOVRhaF4CK6vdz59VwaH2NG7GqGOVRhaIPuylhMEnE6sKZg4we6CtomXbChMWmhMIfqKtbq5G)kIYb7gheGCK9qxoXdHvoY6dYro)YXFYHJ0aKJFW5i7HUCWFfrGOr)CuqoWTSZMs58q7dy59VwaH2Ny)XbeKKWOLIir14GaZcGe9AjE5WsKhZcGeYEudj4oi07vI8yQljmN3hCrdRElcDUrWDa3HPTmhNJuVAi7srKOACqi272O372AzTS8(xlGq7Zw23Y8AzTSlfrGOrFlICESL51YAzF6qace5myrKZJTpDiabICgeGDYyac9elJ((eqQwwl7d5HEVIYUfropyAq4LdBr031dGx8aI4t6PuylhMEnEYzdClcDUjhM4aUdtyMd(RikhSBCqKtbq5aE6IboNkLJddRH2NBmyLdVpqGC9i4CaDoXJh5OrokiNRJCQuofabNt5meaKZg4we6CtomXbChMYrb541Ue5eDoKC7kIYPr5epeIYXruo)gr5ep(LdDD59jh8xruoy34GaKt05qYf0bNZg4we6CtomXbChMYj6CIhkh6GZPx5WK(xlGq7ZMsHnSLJZdTpGL3)AbeAFI9hhqqscJW5i1RgcZcGe9AjE5WsKhZcGeYEudj4oi07vI8yE(NKqYTt8GGflfrIQXbbaZExcGcmX5McjX5H2NDPisunoiS8hh9saXc58q7Znqcc4CK6vdzj5c6GjybV)1ci0(ei676b2KAzTS6Ti05gb3bChMSWfKhAFqCdI3TbULD2LIir14GWcxqEO9HPUKW7dUOHvVfHo3i4oG7Wukf2Wwoop0(awE)RfqO9j2FCabjjmcNJuVAimlas0RL4LdlrEmlasi7rnKG7GqVxjYJ55FsYremblwkIevJdcaM9UeafyIZnfscNudeW5i1RgYsYf0btWcE)RfqO9jq031dSbbHAzTS6Ti05gb3bChMSWfKhAFBYlh2(D5GieXuxs49bx0WQ3IqNBeChWDykLcB5S5buoqF0vO3BoBClJq5axq69Mdt6FTacTVCK9qxoXdHOCCeLZ1ro01L3NCWFfr5GDJdcqoooxnE1q5eDoRIXGvoKCbDW5O3IqNBYH7aUdt54hCo9zWkhzp0LZgTCuo9kNnULrOCuqo9LdVBdCl7SPuop0(awE)RfqO9j2FCabjjmcNJuVAimlas0RL4LdlrEmlasi7rnKG7GqVxjYJ55FssbqcWJUc9Ef7TmcHjo3uijlfrGWrbHSi676bWhohPE1qwsUGoycwW7FTacTpbI(UEGTqG3hCrdRElcDUrWDa3HPT4CK6vdzj52jEqWILIir14GaGpCos9QHShrWeSyPisunoiaqCleyE4g6clQCKOxI9wgHWadE3g4w2zrLJe9sS3YiKfrFxpaEX5i1RgYsYf0btWcE)RfqO9jq031darmWW5HIJe0rFLa4vcohPE1qwE)RfqO9jap6k07vS3YieM6scVXrNFH903NqSCkLY5H2hWY7FTacTpX(JdiijHrlfrIQXbbMfaj61s8YHLipMfajK9OgsWDqO3Re5Xuxs49bx0WQ3IqNBeChWDyAlZX5i1RgYUuejQgheI9Un69Ufc4CK6vdzj52jEqWILIir14GaGxj4CK6vdzpIGjyXsrKOACqaWaJAzTS8(xlGq7ZIOVRhaFVCy73LddmW5i1RgYsYf0btWcE)RfqO9jq031dGpj1YAz1BrOZncUd4omzHlip0(WaJAzTS6Ti05gb3bChMSGW5mGpPJbg1YAz1BrOZncUd4omzr031dGVxoS97YHbg8UnWTSZcE0vO3RyVLrilICyS2IZrQxnKTaib4rxHEVI9wgHG42AzTS8(xlGq7Zw23cbMxlRLDPicen6BrKZdmWOwwlRElcDUrWDa3HjlI(UEa8Hh2nfIBzETSw2NoeGarodwe58y7thcqGiNbbyNmgGqpXYOVpbKQL1Y(qEO3ROSBrKZdMgeE5Wwe9D9a4fpGi(KEkf2Yb6oDW5Sz7ihObICga5axq69Mdt6FTacTVC8iNh99jNDK2inWYMs58q7dy59VwaH2Ny)XbeKKWOLX)eiqkdeM6sceQL1Y(0HaeiYzWw2368qXrc6OVsa8kbNJuVAilV)1ci0(elJ)jqGugiiIbgqOwwl7sreiA03w2368qXrc6OVsa8kbNJuVAilV)1ci0(elJ)jqGugOnbvoA1OxYUuebIg9Hykf2YzJ6WQFroq3Ded5aE6IboNkLtbqW5itJNC8C2SDKd0arod5GihgRCIoNcGYr)Fcw9GmyLJVccLt8q5WDqKZspf8qaBom7rb5itnMCopki3yWkhaf5u2ZXZzZ2roqde5mKdyNUiNvJYjEOCw65MCaHZziNELZg1Hv)ICGU7igSPuop0(awE)RfqO9j2FCabjjmc5WQFHaS7igWuxsQL1YY7FTacTpBzFR0zA1YAzF6qace5myrKZdivlRL9H8qVxrz3IiNhq6PdbiqKZGaStgdqONyz03NqI0tPCEO9bS8(xlGq7tS)4acssy0owOUACqGPUKulRLDPicen6Bl7Puop0(awE)RfqO9j2FCabjjmAhluxnoiWuxsQL1Y(0HaeiYzWw23wlRLL3)AbeAF2YEkLZdTpGL3)AbeAFI9hhqqscJ2Xc1vJdcm1LKDeHt8YHTYBb8gXF2wlRL9H8qVxrz3w2368qXrc6OVsa8HZrQxnKL3)AbeAFILX)eiqkd02AzTS8(xlGq7Zw2tPWwoBEGEV5a9rxHEV5SXTmcLdCbP3BomP)1ci0(Yj6CqeiAeLd(RikhSBCqKJFW5SXpnDQC5G)g)t5WFC0lbYH7xovkNkD0s5QBWmNAjYPakUXGvo9zWkN(YrA2sJ2ukNhAFalV)1ci0(e7poGGKegbE0vO3RyVLrim1LeCos9QHSfajap6k07vS3Yi02AzTS8(xlGq7Zw23YCNhAF2LIir14GWYFC0lb268q7ZU)00PYjwg)tal)XrVeaFop0(S7pnDQCILX)eW(D5e8hh9sGukSLd0YLdtNEVqgKd2neaO3Bo7OMdYPVCIhsr50YUCapDXaNtLYbMmoweCoRgLZgJfQ5gh8Zzh1CqoYEOlN9ga0QHWmNAjYPJhcjtbuoC)YPs5uaeCo6Ldt6FTacTVCK9qxoXdHOCCeLdOSwkxPlYb)veLd2noia2C2aRC8CGwUCy607fYGCWUHaa9EZzh18CK1fdCovkNcGGXmNnA5OC6voBClJq5aE6IboNkLtbqW5SueiYrx5epuoKCki07nNnA5OC6voBClJq5itnMCi52veLdCbP3BoXdLd3bHnLY5H2hWY7FTacTpX(JdiijHrOYrIEj2BzectDjPwwllOCcg07fiQgca07vGihglBzFleW5i1RgYEebtWILIir14GaGpj4CK6vdzj52jEqWILIir14GaGbgWuTSw2VIqnci6LiA0NUWw2H4wNhkosqh9vcGxj4CK6vdz59VwaH2Nyz8pbcKYaTTwwllOCcg07fiQgca07vGihgllI(UEa8sYr8sqIq)eKCEO9zxg)tGaPmqwUdcrOFkLY5H2hWY7FTacTpX(JdiijHrlJ)jqGugim1LKAzTSGYjyqVxGOAiaqVxbICySSL9TqaNJuVAi7remblwkIevJdca(KGZrQxnKLKBN4bblwkIevJdcagyat1YAz)kc1iGOxIOrF6cBzhIBDEO4ibD0xjaELGZrQxnKL3)AbeAFILX)eiqkd02AzTSGYjyqVxGOAiaqVxbICySSi676bWl3bHi0pTfcmN3hCrdRElcDUrWDa3HjmWOwwlRElcDUrWDa3HjlI(UEa8sYr8sqIq)egyulRL9H8qVxrz3IiNhq6PdbiqKZGaStgdqONyz03NaFshIPuop0(awE)RfqO9j2FCabjjmcvos0lXElJqyQlj1YAzbLtWGEVar1qaGEVce5Wyzl7BHaZd3qxy3Xc1CJd(yGrTSw2DSqn34GVfrop2wlRLDhluZno4Br031dGxsoIxcse6NGKZdTp7owOUACqy5oieH(jmWaNJuVAi7remblwkIevJdca(KGZrQxnKLKBN4bblwkIevJdcagyat1YAz)kc1iGOxIOrF6cBzhIBRL1YckNGb9EbIQHaa9EfiYHXYIOVRhaVKCeVeKi0pbjNhAF2DSqD14GWYDqic9tPuop0(awE)RfqO9j2FCabjjmAhluxnoiWuxsQL1YckNGb9EbIQHaa9EfiYHXYw23cbMhUHUWUJfQ5gh8XaJAzTS7yHAUXbFlICESTwwl7owOMBCW3IOVRhaVCheIq)egyGZrQxnK9icMGflfrIQXbbaFsW5i1RgYsYTt8GGflfrIQXbbadmGPAzTSFfHAeq0lr0OpDHTSdXT1YAzbLtWGEVar1qaGEVce5Wyzr031dGxUdcrOFAleyoVp4Igw9we6CJG7aUdtyGrTSww9we6CJG7aUdtwe9D9a4LKJ4LGeH(jmWOwwl7d5HEVIYUfropG0thcqGiNbbyNmgGqpXYOVpb(KoetPWwoBmwOMBCWpNDuZb5aE6IboNkLtbqW5OxomP)1ci0(YXJCE03hcLZosBKgyLt84xoB8ttNkxo4VX)eih)GZbkVr8hBkLZdTpGL3)AbeAFI9hhqqscJ2Xc1vJdcm1LKAzTS7yHAUXbFlICESTwwl7owOMBCW3IOVRhaVCheIq)02AzTS8(xlGq7ZIOVRhaVCheIq)0wNhkosqh9vcGpCos9QHS8(xlGq7tSm(NabszG2cbMZ7dUOHvVfHo3i4oG7WegyulRLvVfHo3i4oG7WKfrFxpaEj5iEjirOFcdmQL1Y(qEO3ROSBrKZdi90HaeiYzqa2jJbi0tSm67tGpPdXukSLZMhq5SXpnDQC5G)g)tGC8dohO8gXFYrVCys)RfqO9Lt058qM9CEPJqEq5Sz7ihObICga5i7HUCWFfr5GDJdcqooIY56ihhNRgVAOCAuohrW5eDovkhEFacHJGTPuop0(awE)RfqO9j2FCabjjmA)PPtLtSm(NayQlj1YAz59VwaH2NTSVnqooYic9t4RwwllV)1ci0(Si676b2wlRL9H8qVxrz3IiNhq6PdbiqKZGaStgdqONyz03NaFspLY5H2hWY7FTacTpX(JdiijHraEJ4pyQlj1YAz59VwaH2NfrFxpaE5oieH(PukSLZgyLt8qikhfCqoYHUU8(KtOFkhdTIC0lhM0)AbeAF5SAuoEoB8ttNkxo4VX)eiNgLduEJ4p5eDopAKJEafMYPx5WK(xlGq7dZCkakhq)P4rV3CidGSPuop0(awE)RfqO9j2FCabjjmYO407vu7FftDjPwwllV)1ci0(Si676bW3lh2(D5268qXrc6OVsa8kFkLZdTpGL3)AbeAFI9hhqqscJGr(BFarfrE8GPUKulRLL3)AbeAFwe9D9a47LdB)UCBRL1YY7FTacTpBzpLkLcBylNnlz2juo4CK6vdLt84ro8(cxpqoXdLJZJIBYHaH(9GGZj0pLt84roXdLZrYf5WK(xlGq7lhzQXKtLYbromw2ukSHTCCEO9bS8(xlGq7te6xVxj4CK6vdHzbqIETeVCyjYJzbqczpQHeChe69krEmp)ts49VwaH2NaromwIq)eM4CtHKW72a3YolV)1ci0(Si676byAKC7epiybd6bB07vGi4cp0(sPWg2YHzpuoChe5e6NYPx5epuoGDYyYjE8ihzQXKtLYzhrChe5Ox05WK(xlGq7ZMsHnSLJZdTpGL3)AbeAFIq)69cjjmcNJuVAimlas0RL4LdlrEmlasi7rnKG7GqVxjYJ55FscV)1ci0(e7iI7Gqe6NWeNBkKei48q7ZUuevDJXYDqic9tmnMZ7dUOHDz8pjCohrH2hKCEO9zb8gXFSCheIq)eK49bx0WUm(NeoNJOq7dImni48qXrc6OVsa8HZrQxnKL3)AbeAFILX)eiqkdeeHKZdTp7Y4FceiLbYYDqic9tmni48qXrc6OVsa8kbNJuVAilV)1ci0(elJ)jqGugiiUj4CK6vdz59VwaH2NG7GqGOVRhiLcBylhNhAFalV)1ci0(eH(17fssyeohPE1qywaKOxlXlhwI8ywaKq2JAib3bHEVsKhZZ)KKq)KiAbV)1ci0(WeNBkKeCos9QHS8(xlGq7tGihglrOFkLcBylNnczCSYHj9VwaH2xoRgLJVccLd(RiceokiuoLZqaqo4CK6vdzxkIaHJccj49VwaH2xokihaf2ukSHTCCEO9bS8(xlGq7te6xVxijHr4CK6vdHzbqIETeVCyjYJzbqczpQHeChe69krEmp)tsc9tIOf8(xlGq7dZExY3LdtCUPqswkIaHJcczr031dGPUKeUHUWUuebchfeAlZX5i1RgYUuebchfesW7FTacTVukSHTC2iKXXkhM0)AbeAF5SAuoBuhw9lYb6UJyihDLJg5itnMC49NYPxRC4DBGBzxoGUpBkf2Wwoop0(awE)RfqO9jc9R3lKKWiCos9QHWSairVwIxoSe5XSaiHSh1qcUdc9ELipMN)jjH(jr0cE)RfqO9HzVl57YHjo3uij8UnWTSZICy1Vqa2Dedwe9D9ayQlj8ghD(fwgWcP(TL3TbULDwKdR(fcWUJyWIOVRhytKhpWhohPE1q2q)KiAbV)1ci0(sPWwoBeY4yLdt6FTacTVCwnkNnhfHAeiNELdZA0NUiLcBylhNhAFalV)1ci0(eH(17fssyeohPE1qywaKOxlXlhwI8ywaKq2JAib3bHEVsKhZZ)KKq)KiAbV)1ci0(WS3L8D5WeNBkKeE3g4w2z)kc1iGOxIOrF6clI(UEam1LeEJJo)clo6IhSqB5DBGBzN9RiuJaIEjIg9PlSi676b2ePVP4dNJuVAiBOFseTG3)AbeAFPuydB5SriJJvomP)1ci0(Yz1OC2iKhp1gDKnLcBylhNhAFalV)1ci0(eH(17fssyeohPE1qywaKOxlXlhwI8ywaKq2JAib3bHEVsKhZZ)KKq)KiAbV)1ci0(WS3L8D5WeNBkKeE3g4w2zHjpEQn6ilI(UEaibHAzTSWKhp1gDKfUG8q7BtQL1YY7FTacTplCb5H2hezAOYrRg9swyYJhGy5Xt)Xuxs4no68lShXrTPrWB5DBGBzNfM84P2OJSi676b2e5Xd8HZrQxnKn0pjIwW7FTacTVukSHTC2iKXXkhM0)AbeAF5SAuoBeYJhidYb)94P)5acNZaihDLt8qikhhr54rogYbroHSoNWrVuaSPuydB548q7dy59VwaH2Ni0VEVqscJW5i1RgcZcGe9AjE5WsKhZcGeYEudj4oi07vI8yE(NKe6Nerl49VwaH2hM9UKVlhM4CtHKulRLfM84P2OJSi676b2KAzTS8(xlGq7ZcxqEO9HPUKGkhTA0lzHjpEaILhp9FBTSwwyYJNAJoYw2368qXrc6OVsa8kr6PuydB5SriJJvomP)1ci0(Yz1OCIhkhPX)owiYn5GNJGp)4uo1YALJUYjEOC2nowekhfKtbO3BoXJh5ei9yGcBkf2Wwoop0(awE)RfqO9jc9R3lKKWiCos9QHWSairVwIxoSe5XSaiHSh1qcUdc9ELipMN)jjH(jr0cE)RfqO9HzVl57YHjo3uij4CK6vdzP)owiYnIgbF(XjbmzCS2eiW72a3Yol93XcrUr0i4ZpozHlip0(2eE3g4w2zP)owiYnIgbF(XjlI(UEaiY0yoVBdCl7S0Fhle5grJGp)4KfromwyQljetTO77eSL(7yHi3iAe85hNsPWg2YzJqghRCys)RfqO9LZQr5S5ACy1JgbYb7o8lHzoLZqaqoAKJSUyGZPs5atghlcohtFVekN4XVCKoEKdG49bdSPuydB548q7dy59VwaH2Ni0VEVqscJW5i1RgcZcGe9AjE5WsKhZcGeYEudj4oi07vI8yE(NKe6Nerl49VwaH2hM9UKVlhM4CtHKW72a3Yo7RXHvpAequD4xsGNWZ2uPl9ndlI(UEam1LeIPw09Dc2(ACy1Jgbevh(L2Y72a3Yo7RXHvpAequD4xsGNWZ2uPl9ndlI(UEGnr64b(W5i1RgYg6Nerl49VwaH2xkf2WwoBeY4yLdt6FTacTVCkxOMCys)RfqO9Ldj3UIiqo6khnGmiNYUnLcBylhNhAFalV)1ci0(eH(17fssyeohPE1qywaKOxlXlhwI8ywaKq2JAib3bHEVsKhZZ)KKq)KiAbV)1ci0(WS3L8D5WeNBkKKAzTS8(xlGq7ZIOVRhiLcBylNnczCSYHj9VwaH2xoLlutoB0EJZHKBxreihDLJgqgKtz3MsHnSLJZdTpGL3)AbeAFIq)69cjjmcNJuVAimlas0RL4LdlrEmlasi7rnKG7GqVxjYJ55FssOFseTG3)AbeAFy27s(UCyIZnfssTSwwu5irVe7Tmczr031dGPUKeUHUWIkhj6LyVLrOT1YAz59VwaH2NfULDPuydB5SriJJvomP)1ci0(Yz1OC8lhsUa55SrlhLtVYzJBzekhDLt8q5SrlhLtVYzJBzekhzDXaNdV)uo9ALdVBdCl7YXJCmKdIC20CaeVpyqovA1ikhM0)AbeAF5iRlgyBkf2Wwoop0(awE)RfqO9jc9R3lKKWiCos9QHWSairVwIxoSe5XSaiHSh1qcUdc9ELipMN)jjH(jr0cE)RfqO9HzVl57YHjo3uij8UnWTSZIkhj6LyVLrilI(UEaivlRLfvos0lXElJqw4cYdTpm1LKWn0fwu5irVe7TmcTTwwllV)1ci0(SWTSBlVBdCl7SOYrIEj2BzeYIOVRhasBk(W5i1RgYg6Nerl49VwaH2xkf2WwoBeY4yLdt6FTacTVC0voBefW1DJEocRCys))(bNJSUyGZ56iNkLdICySYz1OC0ihSOWMsHnSLJZdTpGL3)AbeAFIq)69cjjmcNJuVAimlas0RL4LdlrEmlasi7rnKG7GqVxjYJ55FssOFseTG3)AbeAFy27s(UCyIZnfscVBdCl7S1YAjGvax3n65iSe8()9d2IOVRhatDjbvoA1OxYcRaUUB0Zryj49)7h82AzTSWkGR7g9CewcE))(bBHBzxkf2WwoBuxHZrAehDbqAZzJqghRCys)RfqO9LZQr54WW5a2DzhiNELdEkNgLZVruoommiN4XJCKPgtoghe5y67Lq5ep(LJ8BAoaI3hmWMdZEiaLdo3uiqooIoih5CeNaahPgSYP3d97MC0lh3yYH7acytPWg2YX5H2hWY7FTacTprOF9EHKegHZrQxneMfaj61s8YHLipMfajK9OgsWDqO3Re5X88pjj0pjIwW7FTacTpm7DjFxomX5Mcjb5kSGWrxyDyyGvpm1LeKRWcchDH1HHbwsofeGTixHfeo6cRdddS8UCbELGN2ICfwq4OlSommWcxqEO9Hx530ukSHTC2OUcNJ0io6cG0MJ00iZXcKtbq5WK(xlGq7lhzA8KdUI5iKxvJgyLdYv4CiC0famZPXriKct54hw5atghlqogfeeCoETXr5eDoFNbkhqbr5OroVuaYPai4CEieztPWg2YX5H2hWY7FTacTprOF9EHKegHZrQxneMfaj61s8YHLipMfajK9OgsWDqO3Re5X88pjj0pjIwW7FTacTpmX5Mcjb5kSGWrxyXvmhH8QHS6X0yoYvybHJUWIRyoc5vdzl7yQljixHfeo6clUI5iKxnKLKtbbylohPE1qwE)RfqO9jqKdJLi0pHpKRWcchDHfxXCeYRgYQxkf2WwoBEaLt8q5CKCromP)1ci0(YPVC4DBGBzxo6khnYrwxmW5CDKtLYHKBN4bbNt05atghRCIhkha)HGlgcoN(OCAuoXdLdG)qWfdbNtFuoY6IboNhFFNUCmeaKt84xoshpYbq8(Gb5uPvJOCIhkNL((e5qhmWMsHnSLJZdTpGL3)AbeAFIq)69cjjmcNJuVAimlas0RL4LdlrEmlasi7rnKG7GqVxjYJ55FssOFseTG3)AbeAFyIZnfscohPE1qwE)RfqO9jqKdJLi0pHPUKGZrQxnKL3)AbeAFce5Wyjc9tqI3TbULDwE)RfqO9zHlip0(yAqq(nbc4HvAas4Hv6mTWn0f2LIiq4OGqqKPfUHUWYGEWg9EHi(KGZrQxnKn0pjIwW7FTacTpmWaNJuVAiBOFseTG3)AbeAF4DPVpHarFxpWMiD8iLkLY5H2hWI6DX(JdijlJ)jqGugim1LeNhkosqh9vcGxj4CK6vdzF6qace5miwg)tGaPmqBHqTSw2NoeGarod2YogyulRLDPicen6Bl7qmLY5H2hWI6DX(JdiijHrlfrv3yWuxsQL1YctE8uB0r2Y(wu5OvJEjlm5XdqS84P)BX5i1RgYg6Nerl49VwaH2h(QL1YctE8uB0rwe9D9aBDEO4ibD0xjaELi9ukNhAFalQ3f7poGGKegTm(NabszGWuxsCEO4ibD0xjaELGZrQxnK9XrWcUdcXY4FceiLbABTSwwq5emO3lquneaO3Raromw2Y(2AzTSGYjyqVxGOAiaqVxbICySSi676bWl3bHi0pLs58q7dyr9Uy)XbeKKWODSqD14GatDjPwwllOCcg07fiQgca07vGihglBzFBTSwwq5emO3lquneaO3Raromwwe9D9a4L7Gqe6NsPCEO9bSOExS)4acssy0owOUACqGPUKulRLDPicen6Bl7Puop0(awuVl2FCabjjmAhluxnoiWuxsQL1Y(0HaeiYzWw2tPWwoBEaLtFuo4VIOCWUXbroKJmyLJE5Sr7nohDLdwDjh4(GCKZJJJYH04Hq5Szjp07nNn)EonkNnBh5anqKZqoyrro(bNdPXdHK2CGGdXCECCuo)gr5ep(LtiRZXniYHXcZCGqfI5844OCKMgsoqGCatboKb5G)few5GihgRCIoNcGWmNgLde4qmhOKJ07nhM1f(tokihNhkoYMZgPpih5a35epkihzpQHY5XrW5WDqO3Bo4VX)eiqkdeiNgLJSh6YbA5YHPtVxidYb7gca07nhfKdICySSPuop0(awuVl2FCabjjmAPisunoiWSairVwIxoSe5XSaiHSh1qcUdc9ELipM6scZX5i1RgYUuejQgheI9Un69UTwwllOCcg07fiQgca07vGihgllCl7268qXrc6OVsa8HZrQxnK9XrWcUdcXY4FceiLbAlZxkIaHJcczDEO4OTqG51YAzFip07vu2TL9TmVwwl7thcqGiNbBzFlZ3reorVwIxoSDPisunoi2cbNhAF2LIir14GWYFC0lbWRePJbgqiCdDH1nKCGa5aMcCGyvqyTL3TbULDwyK)2hqurKhpwe5WybrmWaqosVxr0f(J15HIJGietPWwoBEaLd(RikhSBCqKdPXdHYbUG07nhph8xru1nggTXyH6QXbroChe5i7HUC2SKh69MZMFphfKJZdfhLtJYbUG07nhsoIxckhzA8KduYr69MdZ6c)XMs58q7dyr9Uy)XbeKKWOLIir14GaZcGe9AjE5WsKhZcGeYEudj4oi07vI8yQljmhNJuVAi7srKOACqi272O37wMVuebchfeY68qXrBRL1YckNGb9EbIQHaa9EfiYHXYc3YUTqacqW5H2NDPiQ6gJLKJ4LqV3TqW5H2NDPiQ6gJLKJ4LGei676bWhEy3umWG5OYrRg9s2LIiq0OpeXadNhAF2DSqD14GWsYr8sO37wi48q7ZUJfQRghewsoIxcsGOVRhaF4HDtXadMJkhTA0lzxkIarJ(qeIBRL1Y(qEO3ROSBrKZdiIbgqaqosVxr0f(J15HIJ2cHAzTSpKh69kk7we58ylZDEO9zb8gXFSKCeVe69IbgmVwwl7thcqGiNblICESL51YAzFip07vu2TiY5XwNhAFwaVr8hljhXlHEVBz(thcqGiNbbyNmgGqpXYOVpbeHietPCEO9bSOExS)4acssye3ngHZdTpHrbbMN)jjopuCKiCdDbiLY5H2hWI6DX(JdiijHr7yH6QXbbM6ssTSw2DSqn34GVfrop2YDqic9t4Rwwl7owOMBCW3IOVRhyl3bHi0pHVAzTSOYrIEj2BzeYIOVRhyleyoQC0QrVKfuobd69cevdba69Ibg1YAz3Xc1CJd(we9D9a4Z5H2NDPiQ6gJL7Gqe6NGe3bHi0pX0QL1YUJfQ5gh8TiY5betPCEO9bSOExS)4acssy0owOUACqGPUKulRL9PdbiqKZGTSVfqosVxr0f(J15HIJ268qXrc6OVsa8HZrQxnK9PdbiqKZGyz8pbcKYaLs58q7dyr9Uy)XbeKKWO9NMovoXY4FcGPUKWCCos9QHS7pnDQCI9Un69UTwwl7d5HEVIYUTSVL51YAzF6qace5myl7BHGZdfhjG7WQVNge(Kogy48qXrc6OVsa8kbNJuVAi7JJGfCheILX)eiqkdegy48qXrc6OVsa8kbNJuVAi7thcqGiNbXY4FceiLbcIPuop0(awuVl2FCabjjmcWBe)btDjbqosVxr0f(J15HIJsPCEO9bSOExS)4acssyemYF7diQiYJhm1LeNhkosqh9vcGxPNs58q7dyr9Uy)XbeKKWihX9JeKC7MgO9HPUK48qXrc6OVsa8kbNJuVAiRJ4(rcsUDtd0(2(9ZT78aVsW5i1RgY6iUFKGKB30aTpX3pFB4OxkSY04rp5XJukSLdtVgp5qxxEFYjC0lfamZrJCuqoEoVUE5eDoChe5G)g)tGaPmq54GCwQXqOC0deKdNtVYb)vevDJXMs58q7dyr9Uy)XbeKKWOLX)eiqkdeM6sIZdfhjOJ(kbWReCos9QHSpocwWDqiwg)tGaPmqPuop0(awuVl2FCabjjmAPiQ6gtkvkLZdTpGfe(b7iybQdp0(KSm(NabszGWuxsCEO4ibD0xjaELGZrQxnK9PdbiqKZGyz8pbcKYaTfc1YAzF6qace5myl7yGrTSw2LIiq0OVTSdXukNhAFali8d2rWcuhEO9bjjmAPiQ6gdM6ssTSwwyYJNAJoYw23IkhTA0lzHjpEaILhp9FlohPE1q2q)KiAbV)1ci0(WxTSwwyYJNAJoYIOVRhyRZdfhjOJ(kbWRePNs58q7dybHFWocwG6WdTpijHr7yH6QXbbM6ssTSw2LIiq0OVTSNs58q7dybHFWocwG6WdTpijHr7yH6QXbbM6ssTSw2NoeGarod2Y(2AzTSpDiabICgSi676bWNZdTp7sru1ngljhXlbjc9tPuop0(awq4hSJGfOo8q7dssy0owOUACqGPUKulRL9PdbiqKZGTSVfc7icN4LdBL3UuevDJbdmwkIaHJcczDEO4imWW5H2NDhluxnoiS6jwg99jGykf2YHziSYj6CEPihOmDypNDuZb5OhqHPC2O9gNZ(JdiqonkhM0)AbeAF5S)4acKJSh6YzVbaTAiBkLZdTpGfe(b7iybQdp0(GKegTm(NabszGWuxsCEO4ibD0xjaELGZrQxnK9XrWcUdcXY4FceiLbABTSwwq5emO3lquneaO3Raromw2Y(wiW72a3YolQCKOxI9wgHSi676bGKZdTplQCKOxI9wgHSKCeVeKi0pbjUdcrOFcV1YAzbLtWGEVar1qaGEVce5Wyzr031dGbgmpCdDHfvos0lXElJqqClohPE1q2q)KiAbV)1ci0(Ge3bHi0pH3AzTSGYjyqVxGOAiaqVxbICySSi676bsPCEO9bSGWpyhblqD4H2hKKWODSqD14GatDjPwwl7thcqGiNbBzFlGCKEVIOl8hRZdfhLs58q7dybHFWocwG6WdTpijHr7yH6QXbbM6ssTSw2DSqn34GVfrop2YDqic9t4Rwwl7owOMBCW3IOVRhyleyoQC0QrVKfuobd69cevdba69Ibg1YAz3Xc1CJd(we9D9a4Z5H2NDPiQ6gJL7Gqe6NGe3bHi0pX0QL1YUJfQ5gh8TiY5betPWwoBKcsV3CIhkhq4hSJGZb1HhAFyMtFgSYPaOCWFfr5GDJdcqoYEOlN4HWkhhr5CDKtL07nN9UneCoRgLZgT34CAuomP)1ci0(S5S5buo4VIOCWUXbroKgpekh4csV3C8CWFfrv3yy0gJfQRghe5WDqKJSh6YzZsEO3BoB(9CuqoopuCuonkh4csV3Ci5iEjOCKPXtoqjhP3BomRl8hBkLZdTpGfe(b7iybQdp0(GKegTuejQgheywaKOxlXlhwI8ywaKq2JAib3bHEVsKhtDjH5lfrGWrbHSopuC0wMJZrQxnKDPisunoie7DB07DBTSwwq5emO3lquneaO3Raromww4w2Tfcqacop0(Slfrv3ySKCeVe69Ufcop0(Slfrv3ySKCeVeKarFxpa(Wd7MIbgmhvoA1OxYUuebIg9Higy48q7ZUJfQRghewsoIxc9E3cbNhAF2DSqD14GWsYr8sqce9D9a4dpSBkgyWCu5OvJEj7sreiA0hIqCBTSw2hYd9EfLDlICEarmWacaYr69kIUWFSopuC0wiulRL9H8qVxrz3IiNhBzUZdTplG3i(JLKJ4LqVxmWG51YAzF6qace5myrKZJTmVwwl7d5HEVIYUfrop268q7Zc4nI)yj5iEj07DlZF6qace5mia7KXae6jwg99jGieHykLZdTpGfe(b7iybQdp0(GKegTJfQRgheyQlj1YAzF6qace5myl7BDEO4ibD0xja(W5i1RgY(0HaeiYzqSm(NabszGsPCEO9bSGWpyhblqD4H2hKKWO9NMovoXY4FcGPUKWCCos9QHS7pnDQCI9Un69UfcmpCdDHDH6ViEiHdEiagy48qXrc6OVsa8kpe3cbNhkosa3HvFpni8jDmWW5HIJe0rFLa4vcohPE1q2hhbl4oielJ)jqGugimWW5HIJe0rFLa4vcohPE1q2NoeGarodILX)eiqkdeetPCEO9bSGWpyhblqD4H2hKKWiUBmcNhAFcJccmp)tsCEO4ir4g6cqkLZdTpGfe(b7iybQdp0(GKegbJ83(aIkI84btDjX5HIJe0rFLa4v(ukNhAFali8d2rWcuhEO9bjjmcWBe)btDjbqosVxr0f(J15HIJsPCEO9bSGWpyhblqD4H2hKKWihX9JeKC7MgO9HPUK48qXrc6OVsa8kbNJuVAiRJ4(rcsUDtd0(2(9ZT78aVsW5i1RgY6iUFKGKB30aTpX3pFB4OxkSY04rp5XJukSLdtVgp5qxxEFYjC0lfamZrJCuqoEoVUE5eDoChe5G)g)tGaPmq54GCwQXqOC0deKdNtVYb)vevDJXMs58q7dybHFWocwG6WdTpijHrlJ)jqGugim1LeNhkosqh9vcGxj4CK6vdzFCeSG7GqSm(NabszGsPCEO9bSGWpyhblqD4H2hKKWOLIOQBmSbBWYc]] )
end
