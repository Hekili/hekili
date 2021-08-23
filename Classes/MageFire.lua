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
            max_stack =8
        },

        sun_kings_blessing_ready = {
            id = 333315,
            duration = 15,
            max_stack = 5
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
        if talent.pyroclasm.enabled and runeforge.sun_kings_blessing.enabled then return 1 end
        return 3
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

    -- # If Combustion is disabled, schedule the first Combustion far after the fight ends.
    -- actions.precombat+=/variable,name=time_to_combustion,value=fight_remains+100,if=variable.disable_combustion
    -- # Finally, convert from absolute time and store the relative time in variable.time_to_combustion. Unlike the rest of the calculations, which happen less frequently to speed up the simulation, this happens off-GCD and while casting.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=(variable.combustion_time-time)*buff.combustion.down
    spec:RegisterVariable( "time_to_combustion", function ()
        if buff.combustion.down then return variable.combustion_time end
        return 0
    end )

    -- # The duration of a Sun King's Blessing Combustion.
    -- actions.precombat+=/variable,name=skb_duration,op=set,value=5
    spec:RegisterVariable( "skb_duration", function ()
        return 5
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
    -- actions.combustion_timing=variable,name=combustion_ready_time,value=cooldown.combustion.remains*expected_kindling_reduction
    spec:RegisterVariable( "combustion_ready_time", function ()
        return cooldown.combustion.remains * expected_kindling_reduction
    end )

    -- # The cast time of the spell that will be precast into Combustion.
    -- actions.combustion_timing+=/variable,name=combustion_precast_time,value=(action.fireball.cast_time*!conduit.flame_accretion+action.scorch.cast_time+conduit.flame_accretion)*(active_enemies<variable.combustion_flamestrike)+action.flamestrike.cast_time*(active_enemies>=variable.combustion_flamestrike)-variable.combustion_cast_remains
    spec:RegisterVariable( "combustion_precast_time", function ()
        return ( ( not conduit.flame_accretion.enabled and action.fireball.cast_time or 0 ) + action.scorch.cast_time + ( conduit.flame_accretion.enabled and 1 or 0 ) ) * ( ( active_enemies < variable.combustion_flamestrike ) and 1 or 0 ) + ( ( active_enemies >= variable.combustion_flamestrike ) and action.flamestrike.cast_time or 0 ) - variable.combustion_cast_remains
    end )

    spec:RegisterVariable( "combustion_time", function ()
        -- 20210628: Final value is 0 if combustion is up (see last comment in function), so we can shortcut here.
        if buff.combustion.up then return 0 end

        -- actions.combustion_timing+=/variable,name=combustion_time,value=variable.combustion_ready_time
        local value = variable.combustion_ready_time

        -- # Delay Combustion for after Firestarter unless variable.firestarter_combustion is set.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=firestarter.remains,if=talent.firestarter&!variable.firestarter_combustion
        if talent.firestarter.enabled and not variable.firestarter_combustion then
            value = max( value, firestarter.remains )
        end

        -- # Delay Combustion for Radiant Spark if it will come off cooldown soon.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.radiant_spark.remains,if=covenant.kyrian&cooldown.radiant_spark.remains-10<variable.combustion_time
        if covenant.kyrian and cooldown.radiant_spark.remains - 10 < value then
            value = max( value, cooldown.radiant_spark.remains )
        end

        -- # Delay Combustion for Mirrors of Torment
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.mirrors_of_torment.remains,if=covenant.venthyr&cooldown.mirrors_of_torment.remains-25<variable.combustion_time
        if covenant.venthyr and cooldown.mirrors_of_torment.remains - 25 < value then
            value = max( value, cooldown.mirrors_of_torment.remains )
        end

        -- # Delay Combustion for Deathborne.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.deathborne.remains+(buff.deathborne.duration-buff.combustion.duration)*runeforge.deaths_fathom,if=covenant.necrolord&cooldown.deathborne.remains-10<variable.combustion_time
        if covenant.necrolord and cooldown.deathborne.remains - 10 < value then
            value = max( value, cooldown.deathborne.remains + ( buff.deathborne.duration - buff.combustion.duration ) * ( runeforge.deaths_fathom.enabled and 1 or 0 ) )
        end

        -- # Delay Combustion for Death's Fathom stacks if there are at least two targets.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=buff.deathborne.remains-buff.combustion.duration,if=runeforge.deaths_fathom&buff.deathborne.up&active_enemies>=2
        if runeforge.deaths_fathom.enabled and buff.deathborne.up and active_enemies >= 2 then
            value = max( value, buff.deathborne.remains - buff.combustion.duration )
        end

        -- # Delay Combustion for the Empyreal Ordnance buff if the player is using that trinket.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=variable.empyreal_ordnance_delay-(cooldown.empyreal_ordnance.duration-cooldown.empyreal_ordnance.remains)*!cooldown.empyreal_ordnance.ready,if=equipped.empyreal_ordnance
        if equipped.empyreal_ordnance then
            value = max( value, variable.empyreal_ordnance_delay - ( not cooldown.empyreal_ordnance.ready and ( cooldown.empyreal_ordnance.duration - cooldown.empyreal_ordnance.remains ) or 0 ) )
        end

        -- # Delay Combustion for Gladiators Badge, unless it would be delayed longer than 20 seconds.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.gladiators_badge_345228.remains,if=equipped.gladiators_badge&cooldown.gladiators_badge_345228.remains-20<variable.combustion_time
        if equipped.gladiators_badge and cooldown.gladiators_badge.remains - 20 < value then
            value = max( value, cooldown.gladiators_badge.remains)
        end

        -- # Delay Combustion until RoP expires if it's up.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=buff.rune_of_power.remains,if=talent.rune_of_power&buff.combustion.down
        if talent.rune_of_power.enabled and buff.combustion.down then
            value = max( value, buff.rune_of_power.remains )
        end

        -- # Delay Combustion for an extra Rune of Power if the Rune of Power would come off cooldown at least 5 seconds before Combustion would.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.rune_of_power.remains+buff.rune_of_power.duration,if=talent.rune_of_power&buff.combustion.down&cooldown.rune_of_power.remains+5<variable.combustion_time
        if talent.rune_of_power.enabled and buff.combustion.down and cooldown.rune_of_power.remains + 5 < value then
            value = max( value, cooldown.rune_of_power.remains )
        end

        -- # Delay Combustion if Disciplinary Command would not be ready for it yet.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.buff_disciplinary_command.remains,if=runeforge.disciplinary_command&buff.disciplinary_command.down
        if runeforge.disciplinary_command.enabled and buff.disciplinary_command.down then
            value = max( value, cooldown.buff_disciplinary_command.remains )
        end

        -- # Raid Events: Delay Combustion for add spawns of 3 or more adds that will last longer than 15 seconds. These values aren't necessarily optimal in all cases.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=raid_event.adds.in,if=raid_event.adds.exists&raid_event.adds.count>=3&raid_event.adds.duration>15
        -- Unsupported, don't bother.

        -- # Raid Events: Always use Combustion with vulnerability raid events, override any delays listed above to make sure it gets used here.
        -- actions.combustion_timing+=/variable,name=combustion_time,value=raid_event.vulnerable.in*!raid_event.vulnerable.up,if=raid_event.vulnerable.exists&variable.combustion_ready_time<raid_event.vulnerable.in
        -- Unsupported, don't bother.

        -- # Use the next Combustion on cooldown if it would not be expected to delay the scheduled one or the scheduled one would happen less than 20 seconds before the fight ends.
        -- actions.combustion_timing+=/variable,name=combustion_time,value=variable.combustion_ready_time,if=variable.combustion_ready_time+cooldown.combustion.duration*(1-(0.6+0.2*talent.firestarter)*talent.kindling)<=variable.combustion_time|variable.combustion_time>fight_remains-20
        if variable.combustion_ready_time + cooldown.combustion.duration * ( 1 - ( 0.6 + 0.2 * ( talent.firestarter.enabled and 1 or 0 ) ) * ( talent.kindling.enabled and 1 or 0 ) ) <= value or value > fight_remains - 20 then
            value = variable.combustion_ready_time
        end

        -- # Add the current time to the scheduled Combustion to put it in absolute time so that it is still accurate after a little time passes.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=add,value=time
        -- value = value + time
        -- Skipping this because it ultimately gets used with time subtracted again.

        -- # Finally, convert from absolute time and store the relative time in variable.time_to_combustion. Unlike the rest of the calculations, which happen less frequently to speed up the simulation, this happens off-GCD and while casting.
        -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=(variable.combustion_time-time)*buff.combustion.down
        -- No need to check that Combustion is down because we shortcut this at the top of the function.
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
                    else removeBuff( "hot_streak" ) end

                    if legendary.sun_kings_blessing.enabled then
                        addStack( "sun_kings_blessing", nil, 1 )
                        if buff.sun_kings_blessing.stack == 8 then
                            removeBuff( "sun_kings_blessing" )
                            applyBuff( "sun_kings_blessing_ready" )
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
                        else removeBuff( "hot_streak" ) end
                        if legendary.sun_kings_blessing.enabled then
                            addStack( "sun_kings_blessing", nil, 1 )
                            if buff.sun_kings_blessing.stack == 12 then
                                removeBuff( "sun_kings_blessing" )
                                applyBuff( "sun_kings_blessing_ready" )
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


    spec:RegisterPack( "Fire", 20210823.1, [[devxleqiuKEeeQlrjfSjvrFckyuqqNcczvukKxPk0SGIUfLc2Lq)ckLHrjrhtvWYOu0ZGcLPbfQ6AusvBJsHY3OKkmoOqY5OuOADusP5bvY9Oe7dkv)dcOQdIIqleQupKsstKsk6IusH2ikI(iLurJecKojLuPvII6LOiqZecWnHak7ef0pHcvgkeOwkeqEkenvuGRcbITcfs9vue0yPKWErP)kyWkDyslwspgvtgsxgzZk8zvPrROonXQrraVgfA2uCBv1Uv53snCf54qHy5GEoW0P66sSDOQVtPA8ukDEOK1dbuz(qf7x0SpWYawKOQtSm0MwPnFWkXOSjgl(agL1B9wVnolshRjIf5KYzuFjwKN(jwKmPajwKtkwMwrzzalsqxGCIf5S7taRfBy7v85snY7p2aYVyux6Jd1HJnG85yJfzTig36ESvwKOQtSm0MwPnFWkXOSjgl(agL1B9y8pWIul(CdzrIu(wLf5SGIshBLfjkb4Sizsbs5IatFPK5z3Nawl2W2R4ZLAK3FSbKFXOU0hhQdhBa5ZXwYmtS8waEU2eJHzU20kT5djZjZwDwVxcyTjZ2qUiiak3H8o7bi9v5a5cvFMG56Z6LRRWxYJU8PG3buHYD0WCnkWTbaX7dnxTkgXXk3cqFjqmz2gYfb0nGUC5kWZfsyKIaPpDoi3rdZ1Q9VwaU0xUiuIueZCr7ddEUZTbnxXZD0WC1ChqcmNlcmYPgMlxboIIjZ2qUwJNwnuUahkCpx(mXzuU3C7lxn3bzp3rdzeKRC56ZuUmremcixVZfsOfoLR9gYOPv0yYSnKlteLjqb45Q5IGXc2vJc8CPZHyLRpREUOnbY9Ap3FJsMCTtgtUYzdV6NYfHa5NRtaNqZv9CVoxG8EYq4655AnrWiZv(tk3rumz2gY1Q9HNGEUQXKBTmgrRicjL75sNdfcKR35wlJr0kILjmZvVCvZVbEUYbK3tgcxppxRjcgzUVQC5kxUa5dIjZ2qUiiak3zfIYBucnx8ku0QHa56DUqcTWPCTkcgbjx7nKrtROrwKgb4awgWIK3)Ab4sFbE3g02(byzaldFGLbSivUl9XICQDPpwK0PvdHYIBwNLH2KLbSivUl9XISA6gnmkqSyrsNwneklUzDwgIXyzals60QHqzXnlsouCckklYAzmI8(xlax6lwMyrQCx6JfzLGacYOCVSoldX4zzalsL7sFSihcKQMUrzrsNwneklUzDwgA9SmGfPYDPpwK6XjGdvtGRgdls60QHqzXnRZYqBmwgWIKoTAiuwCZIKdfNGIYIewoA0Wxk60FQHQjyxHtr60QHqZ9zU1YyejBN1cWL(ILjwKk3L(yr6YNc2v4eRZYqRdwgWIKoTAiuwCZIu5U0hlYxJIkQ3qqOQOVelsAmiUho9tSiFnkQOEdbHQI(sSoldXOyzals60QHqzXnlYt)els5aCyX1QHcyKIEE5hqj8cNyrQCx6JfPCaoS4A1qbmsrpV8dOeEHtSoldTXzzals60QHqzXnlYt)elYHr)uOhHQ6UHyrQCx6Jf5WOFk0JqvD3qSoldFWkzzals60QHqzXnlYt)els7kJ0rqqya7dLfPYDPpwK2vgPJGGWa2hkRZYWhEGLbSiPtRgcLf3Sip9tSiLd4Wc3BiiGk4LJcvYyyrQCx6JfPCahw4EdbbubVCuOsgdRZYWhSjldyrsNwneklUzrE6Nyrckx10nAq)KpJfWzrQCx6JfjOCvt3Ob9t(mwaN1zz4dymwgWIu5U0hlYcGcItFals60QHqzXnRZ6SirPHwmoldyz4dSmGfjDA1qOS4MfjhkobfLfjtZfwoA0WxkIkaUmzKtHyf49)RhAKoTAiuwKk3L(yrY7Y5eemrgdRZYqBYYawK0PvdHYIBwKk3L(yrcMLHl3ByQTtqwKOeGdLjx6JfjgTcfTAOC9z1ZLaU8vNa5AFM8zcMlYzz4Y9MlcUTtWCTlgtUvk3cGqZTsJgs5A1(xlax6lxbKlKuuSISi5qXjOOSiRLXiY7FTaCPViAB)Y9zUk3L(IdbsHQrbEKpRWxcKlUSK7d5(mxMMlcZTwgJOCdcEQjWvaxrPyzk3N5wlJrCU9aWHKYyesk3Zfr5(mx8ku0QHIGzz4Y9gMA7emuPrdPaV)1cWL(yDwgIXyzals60QHqzXnlsouCckklYAzmI8(xlax6lI22VCFMlcZfVcfTAOOlFk4DG3)Ab4sF5I9CvUl9f4DBqB7xU2qUwFUiIfPYDPpwKqfv0ZdGjfYiRZYqmEwgWIKoTAiuwCZIKdfNGIYISwgJiV)1cWL(IOT9l3N5wlJrewok0JWuBNGr02(L7ZCXRqrRgk6YNcEh49VwaU0xU4kx8ku0QHI8(xlax6lmbjUc8GlFk3hZLSL4fNcU8PCFmxeMBTmgrus95AdpkIwGQl9LRnKBTmgrE)RfGl9frlq1L(Yfr5AJYfwoA0WxkIsQpdcd1N7FKoTAiuwKk3L(yrIsQpxB4rSoldTEwgWIKoTAiuwCZIKdfNGIYIeVcfTAOOlFk4DG3)Ab4sF5IRCXRqrRgkY7FTaCPVWeK4kWdU8PCFmxYwIxCk4YNY9zU1Yye59VwaU0xeTTFSivUl9XI8lqydbHEe8g(PZzDwgAJXYawK0PvdHYIBwKfafSplgkWvGl3lldFGfjkb4qzYL(yrYKnmxmA68zSGyMBbq5Q5YKcKYf3gf45YNv4lLlAbk3BUiWeiSHGC7rUmOHF68C5kWZ17Cv8TGMlxNMK7nx(ScFjqKfPYDPpwKdbsHQrbolsouCckklsL7sFXVaHnee6rWB4Nops2s8Il3BUpZDumMaK4Zk8LcU8PCTHCvUl9f)ce2qqOhbVHF68izlXlofG0xLdKlUYfJp3N5Y0CNBpaCiPmgatKXacYfgg5D2Z9zUmn3AzmIZThaoKugJLjwNLHwhSmGfjDA1qOS4MfPYDPpwKVgfvuVHGqvrFjwKCO4euuwK4vOOvdfD5tbVd8(xlax6lxSNRYDPVaVBdAB)Y1gY16zrsJbX9WPFIf5Rrrf1Biiuv0xI1zzigfldyrsNwneklUzrQCx6Jfj9NWcsQj0q0tpoXIKdfNGIYIeVcfTAOOlFk4DG3)Ab4sF5Ill5IxHIwnuK(tybj1eAi6PhNcOKrXk3N5IxHIwnu0Lpf8oW7FTaCPVCXEU4vOOvdfP)ewqsnHgIE6XPakzuSY1gY16zrE6Nyrs)jSGKAcne90JtSoldTXzzals60QHqzXnlsL7sFSibZkABNqdnSg6rWB4NoNfjhkobfLfjcZfVcfTAOOlFk4DG3)Ab4sF5Ill5IxHIwnuK3)Ab4sFHjiXvGhC5t5(yU2mxCWj3H8o7bi9v5a5IRCXRqrRgk6YNcEh49VwaU0xUik3N5wlJrK3)Ab4sFr02(XI80pXIemROTDcn0WAOhbVHF6CwNLHpyLSmGfjDA1qOS4MfPYDPpwKVgSMMd9iOaG8fJ6sFSi5qXjOOSiXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrE6Nyr(AWAAo0JGcaYxmQl9X6Sm8Hhyzals60QHqzXnlsL7sFSi)kxRqkaMjYd)cq4Si5qXjOOSiXRqrRgk6YNcEh49VwaU0xU4YsUwplYt)elYVY1kKcGzI8WVaeoRZYWhSjldyrsNwneklUzrIsaouMCPpwKw3rUfGCV5Q5cCc2cAU9zdfaLR40hZCvJDflqUfaLR1esk6qGuUy0eaqMC7Ideuk3EKRv7FTaCPVyUyC(mbTlacZCNGsdfxqGJYTaK7nxRjKu0HaPCXOjaGm5Ax85CTA)RfGl9LBFgSYvg5ADVbbp1KRvvaxrPCfqU0PvdHMREO5Q5wa6lLR9(WGNBLY10ap3gpbZ1NPCrlq1L(YTh56ZuUd5D2J5YGzbKRIIcYvZf8vJjx8QPq56DU(mLlVBdAB)YTh5AnHKIoeiLlgnbaKjx7Z0LlAl3BU(SaYLRgEXOU0xUvIRfaLR45kGClhKudWfEUENRcaLpLRpREUINRDXyYTs5waeAUteCqC3GvU9LlVBdAB)ISip9tSirHKIoeifWtaazyrYHItqrzrIxHIwnu0Lpf8oW7FTaCPVCXULCXRqrRgk2xOaOaV49yK7ZCryU1YyeLBqWtnbUc4kkfbUYzmxl5wlJruUbbp1e4kGROu8R2gaUYzmxCWjxMMlVp0I4r5ge8utGRaUIsr60QHqZfhCYfVcfTAOiV)1cWL(c9fkakxCWjx8ku0QHIU8PG3bE)RfGl9Ll2ZvoNGtTrDcnmK3zpaPVkhixRHCZfH5QCx6lW72G22VCFm3hSYCruUiIfPYDPpwKOqsrhcKc4jaGmSoldFaJXYawK0PvdHYIBwKk3L(yrc6IjiVN4eKfjhkobfLfjcZfVcfTAOOlFk4DG3)Ab4sF5IDl5IXSYCTr5IWCXRqrRgk2xOaOaV49yKl2Z1kZfr5Ido5IWCzAUouogjp6pefqe0ftqEpXjyUpZ1HYXi5r)HybOvdL7ZCDOCmsE0FiY72G22ViK(QCGCXbNCzAUouogjp62mkGiOlMG8EItWCFMRdLJrYJUnJfGwnuUpZ1HYXi5r3MrE3g02(fH0xLdKlIYfr5(mxeMltZLWifzAIqJOqsrhcKc4jaGm5Ido5Y72G22VikKu0HaPaEcaitesFvoqUypxRpxeXI80pXIe0ftqEpXjiRZYWhW4zzals60QHqzXnlsL7sFSi56XjtOwgdwKCO4euuwKmnxEFOfXJYni4PMaxbCfLI0PvdHM7ZCD5t5IRCT(CXbNCRLXik3GGNAcCfWvukcCLZyUwYTwgJOCdcEQjWvaxrP4xTnaCLZilYAzmcN(jwKGUycY7jU0hlsucWHYKl9XIKbq59LG5ISlMCTUVN4emxsHgSY1U4Z5ADVbbp1KRvvaxrPCByU2NPlxXZ1UcYDcsCf4rwNLHpy9SmGfjDA1qOS4Mfjkb4qzYL(yrADD6dY1Nvpx0o3R9CR0rdXZ1Q9VwaU0xUG5UyqZLjqb45wPClacn3U4abLYTh5A1(xlax6lx1Zf0Fk3PwopYI80pXIuoahwCTAOagPONx(bucVWjwKCO4euuwKegPitteA81OOI6neeQk6lL7ZCXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrQCx6JfPCaoS4A1qbmsrpV8dOeEHtSoldFWgJLbSiPtRgcLf3SivUl9XICy0pf6rOQUBiwKCO4euuwKegPitteA81OOI6neeQk6lL7ZCXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrE6Nyrom6Nc9iuv3neRZYWhSoyzals60QHqzXnlsL7sFSiTRmshbbHbSpuwKCO4euuwKegPitteA81OOI6neeQk6lL7ZCXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrE6NyrAxzKocccdyFOSoldFaJILbSiPtRgcLf3SivUl9XIuoGdlCVHGaQGxokujJHfjhkobfLfjHrkY0eHgFnkQOEdbHQI(s5(mx8ku0QHIU8PG3bE)RfGl9Ll2TKlEfkA1qX(cfaf4fVhdwKN(jwKYbCyH7neeqf8YrHkzmSoldFWgNLbSiPtRgcLf3SivUl9XIeuUQPB0G(jFglGZIKdfNGIYIKWifzAIqJVgfvuVHGqvrFPCFMlEfkA1qrx(uW7aV)1cWL(Yf7wYfVcfTAOyFHcGc8I3JblYt)elsq5QMUrd6N8zSaoRZYqBALSmGfjDA1qOS4MfjhkobfLfjEfkA1qrx(uW7aV)1cWL(Yf7wYfVcfTAOyFHcGc8I3JblsL7sFSilakio9bSoldT5dSmGfjDA1qOS4MfPYDPpwKdyd8W14vwKOeGdLjx6JfjccGYLjHnWZLHnEnxVZ1HY7lbZ16ekadw5AD5c3qrwKCO4euuwKWYrJg(sXxOamyfeUWnuKoTAi0CFMBTmgrE)RfGl9frB7xUpZfH5IxHIwnu0Lpf8oW7FTaCPVCXEUk3L(c8UnOT9lxCWjx8ku0QHIU8PG3bE)RfGl9LlUYfVcfTAOiV)1cWL(ctqIRap4YNY9XCjBjEXPGlFkxeX6Sm0M2KLbSiPtRgcLf3SivUl9XIK3LZjiyImgwKOeGdLjx6JfP1j556ZuUwtbWLjJCkeRCTA))6HMBTmg5wMWm3YziaixE)RfGl9LRaYf09fzrYHItqrzrclhnA4lfrfaxMmYPqSc8()1dnsNwneAUpZL3TbTTFXAzmcOcGltg5uiwbE))6HgHKIIvUpZTwgJiQa4YKrofIvG3)VEObfY1JIOT9l3N5Y0CRLXiIkaUmzKtHyf49)RhASmL7ZCryU4vOOvdfD5tbVd8(xlax6l3hZv5U0xCaBGxBJh5kWdU8PCXEU8UnOT9lwlJravaCzYiNcXkW7)xp0iAbQU0xU4GtU4vOOvdfD5tbVd8(xlax6lxCLR1NlIyDwgAtmgldyrsNwneklUzrYHItqrzrclhnA4lfrfaxMmYPqSc8()1dnsNwneAUpZL3TbTTFXAzmcOcGltg5uiwbE))6HgHKIIvUpZTwgJiQa4YKrofIvG3)VEObfY1JIOT9l3N5Y0CRLXiIkaUmzKtHyf49)RhASmL7ZCryU4vOOvdfD5tbVd8(xlax6l3hZLSL4fNcU8PCFmxL7sFXbSbETnEKRap4YNYf75Y72G22VyTmgbubWLjJCkeRaV)F9qJOfO6sF5Ido5IxHIwnu0Lpf8oW7FTaCPVCXvUwFUpZLP56QHopclhf6ryQTtWiDA1qO5IiwKk3L(yrQqUEuGSDY0aPpwNLH2eJNLbSiPtRgcLf3Si5qXjOOSiHLJgn8LIOcGltg5uiwbE))6HgPtRgcn3N5Y72G22VyTmgbubWLjJCkeRaV)F9qJq6RYbYfx5YvGhC5t5(m3AzmIOcGltg5uiwbE))6HggWg4r02(L7ZCzAU1YyerfaxMmYPqSc8()1dnwMY9zUimx8ku0QHIU8PG3bE)RfGl9L7J5YvGhC5t5I9C5DBqB7xSwgJaQa4YKrofIvG3)VEOr0cuDPVCXbNCXRqrRgk6YNcEh49VwaU0xU4kxRpxeXIu5U0hlYbSbETnoRZYqBA9SmGfjDA1qOS4MfjhkobfLfjSC0OHVuevaCzYiNcXkW7)xp0iDA1qO5(mxE3g02(fRLXiGkaUmzKtHyf49)RhAeskkw5(m3AzmIOcGltg5uiwbE))6HggWg4r02(L7ZCzAU1YyerfaxMmYPqSc8()1dnwMY9zUimx8ku0QHIU8PG3bE)RfGl9Ll2ZL3TbTTFXAzmcOcGltg5uiwbE))6Hgrlq1L(YfhCYfVcfTAOOlFk4DG3)Ab4sF5IRCT(CrelsL7sFSihWg4HRXRSoldTPngldyrsNwneklUzrYHItqrzrIxHIwnu0Lpf8oW7FTaCPVCXLLCTYCXbNCXRqrRgk6YNcEh49VwaU0xU4kx8ku0QHI8(xlax6lmbjUc8GlFk3N5Y72G22ViV)1cWL(Iq6RYbYfx5IxHIwnuK3)Ab4sFHjiXvGhC5tSivUl9XIKRgtq5U0xWiaNfPraE40pXIK3)Ab4sFHPzfqSoldTP1bldyrsNwneklUzrYHItqrzrwlJrewok0JWuBNGr02(L7ZCzAU1YyehcKaEd)riPCp3N5IWCXRqrRgk6YNcEh49VwaU0xUy3sU1YyeHLJc9im12jyeTavx6l3N5IxHIwnu0Lpf8oW7FTaCPVCXEUk3L(IdbsHQrbECumMaK4Zk8LcU8PCXbNCXRqrRgk6YNcEh49VwaU0xUyp3H8o7bi9v5a5IOCFMlcZLP5clhnA4lfbLlWOCVGq1qaGCVr60QHqZfhCYTwgJiOCbgL7feQgcaK7najffRyzkxCWj3AzmIGYfyuUxqOAiaqU3iKuUNl2TKBTmgrq5cmk3liuneai3B8R2gaUYzmxBi3hYfhCYDiVZEasFvoqU4k3AzmIWYrHEeMA7emIwGQl9LlIyrQCx6JfjSCuOhHP2obzDwgAtmkwgWIKoTAiuwCZISNyrciNfPYDPpwK4vOOvdXIeLaCOm5sFSirWDBYvb5(1dRCzsbs5IBJcCqUki3PgaKQHYD0WCTA)RfGl9fZfzP6qL752fp3EKRpt5oGk3L(utU8(p1hDEU9ixFMY9k)kbZTh5YKcKYf3gf4GC9z1Z1Uym5EQxGQXGvUqIpRWxkx0cuU3C9zkxR2)Ab4sF5onRak3kX1cGYDQBJCV5Qhw(SCV5oPapxFw9CTlgtUx75(c1ZZvVCjBDOMltkqkxCBuGNlAbk3BUwT)1cWL(ISiXRMcXIu5U0xCiqkunkWJ8zf(sGWaQCx6tn5(yUimx8ku0QHIU8PG3bE)RfGl9L7J5QCx6lcMLHl3ByQTtW4OymbiHw4U0xU2OCXRqrRgkcMLHl3ByQTtWqLgnKc8(xlax6lxeLl2YL3TbTTFXHaPq1OapIwGQl9LRnK7d5IRC5DBqB7xCiqkunkWJF12aFwHVei3hZfVcfTAOyJNGtDBcdbsHQrboixSLlVBdAB)IdbsHQrbEeTavx6lxBixeMBTmgrE)RfGl9frlq1L(YfB5Y72G22V4qGuOAuGhrlq1L(Yfr5MR1qUpK7ZCXRqrRgk6YNcEh49VwaU0xU4k3H8o7bi9v5a5Ido5clhnA4lfbLlWOCVGq1qaGCVr60QHqZ9zUasHY9g8UWNJk3f8uUpZv5U0xCiqkunkWJJIXeGeFwHVuWLpLl2ZfJLRnk3xoA8R2YISaOqpgHxokldFGfjEfgo9tSihcKcvJc8Wu3g5EzrwauW(SyOaxbUCVSm8bwNLH20gNLbSiPtRgcLf3SirjahktU0hlsMWz6YTaK7nxM0OFc4qHrkx5Y1Q9VwaU0hM5cu8uUki3VEyLlFwHVeixfK7udas1q5oAyUwT)1cWL(Y1U4ZDXZLRttY9gzrQCx6JfjxnMGYDPVGraolsGdfUZYWhyrYHItqrzrwlJrewok0JWuBNGXYuUpZfVcfTAOOlFk4DG3)Ab4sF5I9CTswKgb4Ht)elsypfMMvaX6SmeJzLSmGfjDA1qOS4Mfzbqb7ZIHcCf4Y9YYWhyrQCx6JfjEfkA1qSi7jwKaYzrYHItqrzrY0CXRqrRgkoeifQgf4HPUnY9M7ZCD1qNhHLJc9im12jyKoTAi0CFMBTmgry5OqpctTDcgrB7hlYcGc9yeE5OSm8bwK4vtHyrY72G22ViSCuOhHP2obJq6RYbYfx5QCx6loeifQgf4XrXycqIpRWxk4YNY1gYv5U0xemldxU3WuBNGXrXycqcTWDPVCTr5IWCXRqrRgkcMLHl3ByQTtWqLgnKc8(xlax6l3N5Y72G22ViywgUCVHP2obJq6RYbYfx5Y72G22ViSCuOhHP2obJq6RYbYfr5(mxE3g02(fHLJc9im12jyesFvoqU4k3H8o7bi9v5aSirjahktU0hlsMiktGcWZ1NPCXRqrRgkxFw9C595W2aYLjfiLlUnkWZTa0xkxVZLoqbs5koix(ScFjqUkKYvnGo3PUneAUJgMlcu5OC7rUi42obJSiXRWWPFIf5qGuOAuGhM62i3lRZYqm2dSmGfjDA1qOS4Mfzbqb7ZIHcCf4Y9YYWhyrYHItqrzrY0CXRqrRgkoeifQgf4HPUnY9M7ZCXRqrRgk6YNcEh49VwaU0xUypxRm3N5QCxWtb6OVqGCXULCXRqrRgkoRq0axbEyy0pbCOWiL7ZCzAUdbsaxHobJk3f8uUpZLP5wlJrCU9aWHKYySmL7ZCryU1YyeNj1L7nuMILPCFMRYDPV4WOFc4qHrks2s8Itbi9v5a5IRCTYO1Nlo4KlFwHVeimGk3L(utUy3sU2mxeXISaOqpgHxokldFGfPYDPpwKdbsHQrbolsucWHYKl9XIKjCMUCrqvikxbUCV5YKg9t5I0HcJeM5YKcKYf3gf4GCbZDXGMBLYTai0C9o3x6iO6uUiOTNlshskJGC1dnxVZLS1PdnxCBuGtWCrGPaNGrwNLHymBYYawK0PvdHYIBwKfafSplgkWvGl3lldFGfjhkobfLf5qGeWvOtWOYDbpL7ZC5Zk8La5IDl5(qUpZLP5IxHIwnuCiqkunkWdtDBK7n3N5IWCzAUk3L(Idbsv1yIKTeV4Y9M7ZCzAUk3L(Ityb7QrbEuUWWiVZEUpZTwgJ4mPUCVHYuSmLlo4KRYDPV4qGuvnMizlXlUCV5(mxMMBTmgX52dahskJXYuU4GtUk3L(Ityb7QrbEuUWWiVZEUpZTwgJ4mPUCVHYuSmL7ZCzAU1YyeNBpaCiPmglt5IiwKfaf6Xi8Yrzz4dSivUl9XICiqkunkWzrIsaouMCPpwKwZcuU3CzsbsaxHobXmxMuGuU42OahKRcPClacnxG8fJcnyLR35IwGY9MRv7FTaCPVyUwN0rq1yWcZC9zcRCviLBbqO56DUV0rq1PCrqBpxKoKugb5AFMUC5qXb5AxmMCV2ZTs5AxboHMREO5Ax85CXTrbobZfbMcCcIzU(mHvUG5UyqZTs5cMGKIMBx8C9o3VkNRYLRpt5IBJcCcMlcmf4em3AzmISoldXyymwgWIKoTAiuwCZISaOG9zXqbUcC5Ezz4dSirjahktU0hlsMi(wqZLRttY9MltkqkxCBuGNlFwHVeix7ZIHYLpR3rg5EZf5SmC5EZfb32jilsL7sFSihcKcvJcCwKCO4euuwKk3L(IGzz4Y9gMA7ems2s8Il3BUpZDumMaK4Zk8LcU8PCXvUk3L(IGzz4Y9gMA7em6cNXaKqlCx6l3N5wlJrCU9aWHKYyeTTF5(mxx(uUyp3hSswNLHymmEwgWIKoTAiuwCZIKdfNGIYIeVcfTAOOlFk4DG3)Ab4sF5I9CTYCFMBTmgry5OqpctTDcgrB7hlsL7sFSi5QXeuUl9fmcWzrAeGho9tSibUEOkenaBxDPpwNLHymRNLbSivUl9XIeWBiFMfjDA1qOS4M1zDwKWEkmnRaILbSm8bwgWIKoTAiuwCZIu5U0hlYHr)eWHcJelsucWHYKl9XIKjLtngSWmxEF4jON7a2)C1kOnfNY1LpLREO5c8gs56ZuUqYOUGNY1LpLRC5IxHIwnu0Lpf8oW7FTaCPVyUiiNryKY1NPCHeWZTh56ZuUC1Wlg1L(ayMR9zHpN7SonrxUgcaYDajmsHo3GvUENlyIi0Clt56ZuUa5xmQl9HzU(SaYDwNMOdKBpg2G1PvTM5QhAU2NfdLlxbUCVrwKCO4euuwKk3f8uGo6leixSBjx8ku0QHIZThaoKugddJ(jGdfgPCFMlcZTwgJ4C7bGdjLXyzkxCWj3AzmIdbsaVH)yzkxeX6Sm0MSmGfjDA1qOS4MfjhkobfLfzTmgrus95AdpkwMY9zUWYrJg(srus9zqyO(C)J0PvdHM7ZCXRqrRgk6YNcEh49VwaU0xU4k3AzmIOK6Z1gEuesFvoqUpZv5UGNc0rFHa5IDl5AtwKk3L(yroeivvJH1zzigJLbSiPtRgcLf3Si5qXjOOSivUl4PaD0xiqUy3sU4vOOvdfNviAGRapmm6NaouyKY9zU1YyebLlWOCVGq1qaGCVbiPOyflt5(m3AzmIGYfyuUxqOAiaqU3aKuuSIq6RYbYf75YvGhC5tSivUl9XICy0pbCOWiX6SmeJNLbSiPtRgcLf3Si5qXjOOSiRLXickxGr5EbHQHaa5EdqsrXkwMY9zU1YyebLlWOCVGq1qaGCVbiPOyfH0xLdKl2ZLRap4YNyrQCx6Jf5ewWUAuGZ6Sm06zzals60QHqzXnlsouCckklYAzmIdbsaVH)yzIfPYDPpwKtyb7QrboRZYqBmwgWIKoTAiuwCZIKdfNGIYISwgJ4C7bGdjLXyzIfPYDPpwKtyb7QrboRZYqRdwgWIKoTAiuwCZISaOG9zXqbUcC5Ezz4dSi5qXjOOSizAU4vOOvdfhcKcvJc8Wu3g5EZ9zU1YyebLlWOCVGq1qaGCVbiPOyfrB7xUpZv5UGNc0rFHa5IRCXRqrRgkoRq0axbEyy0pbCOWiL7ZCzAUdbsaxHobJk3f8uUpZfH5Y0CRLXiotQl3BOmflt5(mxMMBTmgX52dahskJXYuUpZLP5obj8HEmcVC04qGuOAuGN7ZCryUk3L(IdbsHQrbEKpRWxcKl2TKRnZfhCYfH56QHopQgYwGdvacCkimkqSI0PvdHM7ZC5DBqB7xefQV9bcviP(Ceskkw5IOCXbNCbKcL7n4DHphvUl4PCruUiIfzbqHEmcVCuwg(alsL7sFSihcKcvJcCwKOeGdLjx6JfjccGYTpkxMuGuU42OapxsHgSYvUCrGAeCUYixS6sUO9Hbp3zfpLlj(mbZfbLuxU3CrqMYTH5IG2EUiDiPmMlwKNREO5sIptqRnxeQik3zfpL7VHuU(SE5627CvdKuuSWmxewruUZkEkxMOHSf4qfGaNIbqUmzbIvUqsrXkxVZTaimZTH5IqoIYfjPq5EZLbDHpNRaYv5UGNI5An7ddEUODU(SaY1(SyOCNviAUCf4Y9MltA0pbCOWibYTH5AFMUCrwUCzck3lga5IBdbaY9MRaYfskkwrwNLHyuSmGfjDA1qOS4Mfzbqb7ZIHcCf4Y9YYWhyrYHItqrzrY0CXRqrRgkoeifQgf4HPUnY9M7ZCzAUdbsaxHobJk3f8uUpZTwgJiOCbgL7feQgcaK7najffRiAB)Y9zUimxeMlcZv5U0xCiqQQgtKSL4fxU3CFMlcZv5U0xCiqQQgtKSL4fNcq6RYbYfx5ALrRpxCWjxMMlSC0OHVuCiqc4n8hPtRgcnxeLlo4KRYDPV4ewWUAuGhjBjEXL7n3N5IWCvUl9fNWc2vJc8izlXlofG0xLdKlUY1kJwFU4GtUmnxy5OrdFP4qGeWB4psNwneAUikxeL7ZCRLXiotQl3BOmfHKY9CruU4GtUimxaPq5EdEx4ZrL7cEk3N5IWCRLXiotQl3BOmfHKY9CFMltZv5U0xeWBiFos2s8Il3BU4GtUmn3AzmIZThaoKugJqs5EUpZLP5wlJrCMuxU3qzkcjL75(mxL7sFraVH85izlXlUCV5(mxMM7C7bGdjLXayImgqqUWWiVZEUikxeLlIyrwauOhJWlhLLHpWIu5U0hlYHaPq1OaNfjkb4qzYL(yrIGaOCzsbs5IBJc8CjXNjyUOfOCV5Q5YKcKQQXGnemwWUAuGNlxbEU2NPlxeusD5EZfbzkxbKRYDbpLBdZfTaL7nxYwIxCkx7IpNlssHY9Mld6cFoY6Sm0gNLbSiPtRgcLf3SivUl9XIKRgtq5U0xWiaNfPraE40pXIu5UGNcUAOZbSoldFWkzzals60QHqzXnlsouCckklYAzmItybBUrb)iKuUN7ZC5kWdU8PCXvU1YyeNWc2CJc(ri9v5a5(mxUc8GlFkxCLBTmgry5OqpctTDcgH0xLdK7ZCryUmnxy5OrdFPiOCbgL7feQgcaK7nsNwneAU4GtU1YyeNWc2CJc(ri9v5a5IRCvUl9fhcKQQXe5kWdU8PCFmxUc8GlFkxBuU1YyeNWc2CJc(riPCpxeXIu5U0hlYjSGD1OaN1zz4dpWYawK0PvdHYIBwKCO4euuwK1YyeNBpaCiPmglt5(mxaPq5EdEx4ZrL7cEk3N5QCxWtb6OVqGCXvU4vOOvdfNBpaCiPmggg9tahkmsSivUl9XICclyxnkWzDwg(Gnzzals60QHqzXnlsouCckklsMMlEfkA1qXP5MoX2Wu3g5EZ9zU1YyeNj1L7nuMILPCFMltZTwgJ4C7bGdjLXyzk3N5IWCvUl4PaA7r59eNYfx5AZCXbNCvUl4PaD0xiqUy3sU4vOOvdfNviAGRapmm6NaouyKYfhCYv5UGNc0rFHa5IDl5IxHIwnuCU9aWHKYyyy0pbCOWiLlIyrQCx6Jf50CtNyByy0pbyDwg(agJLbSiPtRgcLf3Si5qXjOOSibKcL7n4DHphvUl4jwKk3L(yrc4nKpZ6Sm8bmEwgWIKoTAiuwCZIKdfNGIYIu5UGNc0rFHa5I9CTjlsL7sFSirH6BFGqfsQpZ6Sm8bRNLbSiPtRgcLf3Si5qXjOOSivUl4PaD0xiqUy3sU4vOOvdfvixpkq2ozAG0xUpZ9RNgN4EUy3sU4vOOvdfvixpkq2ozAG0x4RNM7ZCDf(sE0U4ZY9GvYIu5U0hlsfY1JcKTtMgi9X6Sm8bBmwgWIKoTAiuwCZIu5U0hlYHr)eWHcJelsucWHYKl9XIKju85CPRlVZ56k8LCaM5kEUcixn3xvUC9oxUc8CzsJ(jGdfgPCvqUdXyiyUYbCsrZTh5YKcKQQXezrYHItqrzrQCxWtb6OVqGCXULCXRqrRgkoRq0axbEyy0pbCOWiX6Sm8bRdwgWIu5U0hlYHaPQAmSiPtRgcLf3SoRZIK3)Ab4sFHPzfqSmGLHpWYawK0PvdHYIBwKCO4euuwK1Yye59VwaU0xeTTFSivUl9XI0iVZoiWeOG((PZzDwgAtwgWIKoTAiuwCZIu5U0hlYQ(g6rWHcNralsucWHYKl9XIKjIIcY1NPCrlq1L(YTh56ZuUilxUmbL7fdGCXTHaa5EZ1Q9VwaU0xUENRpt5shAU9ixFMYLxGq68CTA)RfGl9LRmY1NPC5kWZ1ExmO5Y7)KHCkx0cuU3C9zbKRv7FTaCPVilsouCckklYAzmI8(xlax6lI22pwNLHymwgWIKoTAiuwCZIKdfNGIYIu5UGNc0rFHa5I9CFi3N5wlJrK3)Ab4sFr02(XIu5U0hlsJGxU3qT)vwNLHy8SmGfjDA1qOS4Mfzbqb7ZIHcCf4Y9YYWhyrYHItqrzrY0C59Hwepk3GGNAcCfWvuksNwneAUpZLpRWxcKl2TK7d5(m3AzmI8(xlax6lwMY9zUmn3AzmIdbsaVH)yzk3N5Y0CRLXio3Ea4qszmwMY9zUZThaoKugdGjYyab5cdJ8o75(yU1YyeNj1L7nuMILPCXvU2KfzbqHEmcVCuwg(alsL7sFSihcKcvJcCwKOeGdLjx6JfjtO4ZDXZ16EdcEQjxRQaUIsyMltGcWZTaOCzsbs5IBJcCqU2NPlxFMWkx79Hbp3F54Z5YHIdYvp0CTptxUmPajG3WFUcix02(fzDwgA9SmGfjDA1qOS4Mfzbqb7ZIHcCf4Y9YYWhyrYHItqrzrY7dTiEuUbbp1e4kGROuUpZLpRWxcKl2TK7d5(mxeMlEfkA1qrY2jI7eAyiqkunkWb5IDl5IxHIwnu8icLqddbsHQrboixCWj3AzmI8(xlax6lcPVkhixCL7lhn(vBZfhCYfVcfTAOizRthkHg49VwaU0xasFvoqU4YsU1YyeLBqWtnbUc4kkfrlq1L(YfhCYTwgJOCdcEQjWvaxrPiWvoJ5IRCTzU4GtU1YyeLBqWtnbUc4kkfH0xLdKlUY9LJg)QT5Ido5Y72G22ViywgUCVHP2obJqsrXk3N5QCxWtb6OVqGCXULCXRqrRgkY7FTaCPVaywgUCVHP2obZ9zU8gpD65XtEN9WqPCruUpZTwgJiV)1cWL(ILPCFMlcZLP5wlJrCiqc4n8hHKY9CXbNCRLXik3GGNAcCfWvukcPVkhixCLRvgT(CruUpZLP5wlJrCU9aWHKYyesk3Z9zUZThaoKugdGjYyab5cdJ8o75(yU1YyeNj1L7nuMIqs5EU4kxBYISaOqpgHxokldFGfPYDPpwKdbsHQrbolsucWHYKl9XIKju85CTU3GGNAY1QkGROeM5YKcKYf3gf45wauUG5UyqZTs5QOOIl9Pgdw5Y7d4qvocnxqNRpREUINRaY9Ap3kLBbqO5wodba5ADVbbp1KRvvaxrPCfqUATlEUENlz7KaPCByU(mbPCviL7VHuU(SE5sxxENZLjfiLlUnkWb56DUKToDO5ADVbbp1KRvvaxrPC9oxFMYLo0C7rUwT)1cWL(ISoldTXyzals60QHqzXnlsL7sFSi5QXeuUl9fmcWzrAeGho9tSivUl4PGRg6CaRZYqRdwgWIKoTAiuwCZISaOG9zXqbUcC5Ezz4dSi5qXjOOSiNBpaCiPmgatKXacYfgg5D2Z1sUwzUpZTwgJiV)1cWL(IOT9l3N5IxHIwnu0Lpf8oW7FTaCPVCXLLCTYCFMlcZLP5clhnA4lfrfaxMmYPqSc8()1dnsNwneAU4GtU1YyerfaxMmYPqSc8()1dnwMYfhCYTwgJiQa4YKrofIvG3)VEOHbSbESmL7ZCD1qNhHLJc9im12jyKoTAi0CFMlVBdAB)I1YyeqfaxMmYPqSc8()1dncjffRCruUpZfH5Y0CHLJgn8LIVqbyWkiCHBOiDA1qO5Ido5Is1YyeFHcWGvq4c3qXYuUik3N5IWCzAU8gpD65XJ4W20q0CXbNC5DBqB7xeLuFU2WJIq6RYbYfhCYTwgJikP(CTHhflt5IOCFMlcZLP5YB80PNhXtNpJfmxCWjxE3g02(f)ce2qqOhbVHF68iK(QCGCruUpZfH5QCx6l(jNAyuUWWiVZEUpZv5U0x8to1WOCHHrEN9aK(QCGCXLLCXRqrRgkY7FTaCPVaxbEasFvoqU4GtUk3L(IaEd5ZrYwIxC5EZ9zUk3L(IaEd5ZrYwIxCkaPVkhixCLlEfkA1qrE)RfGl9f4kWdq6RYbYfhCYv5U0xCiqQQgtKSL4fxU3CFMRYDPV4qGuvnMizlXlofG0xLdKlUYfVcfTAOiV)1cWL(cCf4bi9v5a5Ido5QCx6loHfSRgf4rYwIxC5EZ9zUk3L(Ityb7QrbEKSL4fNcq6RYbYfx5IxHIwnuK3)Ab4sFbUc8aK(QCGCXbNCvUl9fhg9tahkmsrYwIxC5EZ9zUk3L(IdJ(jGdfgPizlXlofG0xLdKlUYfVcfTAOiV)1cWL(cCf4bi9v5a5IiwKfaf6Xi8Yrzz4dSivUl9XIK3)Ab4sFSoldXOyzals60QHqzXnlsucWHYKl9XIeJZNjyU8UnOT9dKRpREUG5UyqZTs5waeAU2fFoxR2)Ab4sF5cM7Ibn3(myLBLYTai0CTl(CU6LRY9IAY1Q9VwaU0xUCf45QhAUx75Ax85C1CrwUCzck3lga5IBdbaY9M7eS5rwKk3L(yrYvJjOCx6lyeGZIKdfNGIYISwgJiV)1cWL(Iq6RYbYf75IrLlo4KlVBdAB)I8(xlax6lcPVkhixCLR1ZI0iapC6NyrY7FTaCPVaVBdAB)aSoldTXzzals60QHqzXnlsouCckklseMBTmgX52dahskJXYuUpZv5UGNc0rFHa5IDl5IxHIwnuK3)Ab4sFHHr)eWHcJuUikxCWjxeMBTmgXHajG3WFSmL7ZCvUl4PaD0xiqUy3sU4vOOvdf59VwaU0xyy0pbCOWiLRnKlSC0OHVuCiqc4n8hPtRgcnxeXIu5U0hlYHr)eWHcJeRZYWhSswgWIKoTAiuwCZIu5U0hlsOIk65bWKczKfjkb4qzYL(yrIaPOIEEUiNuiJ5cM7Ibn3kLBbqO5Ax85C1CrqBpxKoKugZfskkw56DUfaLR8)eQOozWkxD4emxFMYLRap3HCcyMaXCzWSaY1Uym5EQxGQXGvUaYZTmLRMlcA75I0HKYyUGj68ChnmxFMYDiNAYf4kNXC7rUiqkQONNlYjfYyKfjhkobfLfzTmgrE)RfGl9flt5(mxBMRnk3AzmIZThaoKugJqs5EUpMBTmgXzsD5EdLPiKuUN7J5o3Ea4qszmaMiJbeKlmmY7SNRLCTjRZYWhEGLbSiPtRgcLf3Si5qXjOOSiRLXioeib8g(JLjwKk3L(yroHfSRgf4SoldFWMSmGfjDA1qOS4MfjhkobfLfzTmgX52dahskJXYuUpZTwgJiV)1cWL(ILjwKk3L(yroHfSRgf4SoldFaJXYawK0PvdHYIBwKCO4euuwKtqcF4LJgFic4nKpN7ZCRLXiotQl3BOmflt5(mxL7cEkqh9fcKlUYfVcfTAOiV)1cWL(cdJ(jGdfgPCFMBTmgrE)RfGl9fltSivUl9XICclyxnkWzDwg(agpldyrsNwneklUzrYHItqrzrwlJreuUaJY9ccvdbaY9gGKIIvSmL7ZCRLXiclhf6ryQTtWiK(QCGCXvUk3L(Ityb7QrbEKRap4YNY9zU1YyebLlWOCVGq1qaGCVbiPOyfH0xLdKl2Zv5U0xCclyxnkWJCf4bx(uUpMlzlXlofC5tSivUl9XIewok0JWuBNGSoldFW6zzals60QHqzXnlsL7sFSibZYWL7nm12jilsucWHYKl9XIebbi3BUiNLHl3BUi42obZfTaL7nxR2)Ab4sF56DUqc4nKYLjfiLlUnkWZvp0CrWZnDIT5YKg9t5YNv4lbYLRxUvk3kD0q4IAWm3AXZTakQXGvU9zWk3(YLj2wJrwKCO4euuwK1Yye59VwaU0xSmL7ZCzAUk3L(IdbsHQrbEKpRWxcK7ZCvUl4PaD0xiqUy3sU4vOOvdf59VwaU0xamldxU3WuBNG5(mxL7sFXP5MoX2WWOFce5Zk8La5IRCvUl9fNMB6eBddJ(jq8R2g4Zk8LaSoldFWgJLbSiPtRgcLf3Si5qXjOOSivUl4PaD0xiqUy3sU4vOOvdf59VwaU0xyy0pbCOWiL7ZCRLXickxGr5EbHQHaa5EdqsrXkwMY9zU1YyebLlWOCVGq1qaGCVbiPOyfH0xLdKl2ZLRap4YNY9zUimxMMlVp0I4r5ge8utGRaUIsr60QHqZfhCYTwgJOCdcEQjWvaxrPiK(QCGCXEUKTeV4uWLpLlo4KBTmgXzsD5EdLPiKuUN7J5o3Ea4qszmaMiJbeKlmmY7SNlUY1M5IiwKk3L(yrom6NaouyKyDwg(G1bldyrsNwneklUzrYHItqrzrwlJreuUaJY9ccvdbaY9gGKIIvSmL7ZCRLXickxGr5EbHQHaa5EdqsrXkcPVkhixSNlxbEWLpL7ZCryUmnxEFOfXJYni4PMaxbCfLI0PvdHMlo4KBTmgr5ge8utGRaUIsri9v5a5I9CjBjEXPGlFkxCWj3AzmIZK6Y9gktriPCp3hZDU9aWHKYyamrgdiixyyK3zpxCLRnZfrSivUl9XICclyxnkWzDwg(agfldyrsNwneklUzrYHItqrzrwlJrCclyZnk4hHKY9CFMBTmgXjSGn3OGFesFvoqUypxUc8GlFk3N5IWCRLXiY7FTaCPViK(QCGCXEUCf4bx(uU4GtU1Yye59VwaU0xeTTF5IOCFMRYDbpfOJ(cbYfx5IxHIwnuK3)Ab4sFHHr)eWHcJuUpZfH5Y0C59Hwepk3GGNAcCfWvuksNwneAU4GtU1YyeLBqWtnbUc4kkfH0xLdKl2ZLSL4fNcU8PCXbNCRLXiotQl3BOmfHKY9CFm352dahskJbWezmGGCHHrEN9CXvU2mxeXIu5U0hlYjSGD1OaN1zz4d24SmGfjDA1qOS4MfjhkobfLfzTmgrE)RfGl9flt5(mxhQ4jtWLpLlUYTwgJiV)1cWL(Iq6RYbY9zU1YyeNj1L7nuMIqs5EUpM7C7bGdjLXayImgqqUWWiVZEU4kxBYIu5U0hlYP5MoX2WWOFcW6Sm0MwjldyrsNwneklUzrYHItqrzrwlJrK3)Ab4sFr02(L7ZC5DBqB7xK3)Ab4sFri9v5a5IRC5kWdU8PCFMRYDbpfOJ(cbYf7wYfVcfTAOiV)1cWL(cdJ(jGdfgjwKk3L(yrom6NaouyKyDwgAZhyzals60QHqzXnlsouCckklYAzmI8(xlax6lI22VCFMlVBdAB)I8(xlax6lcPVkhixCLlxbEWLpL7ZCzAU8(qlIhhg9tbLZHKl9fPtRgcLfPYDPpwKdbsv1yyDwgAtBYYawK0PvdHYIBwKCO4euuwK1Yye59VwaU0xesFvoqUypxUc8GlFk3N5wlJrK3)Ab4sFXYuU4GtU1Yye59VwaU0xeTTF5(mxE3g02(f59VwaU0xesFvoqU4kxUc8GlFIfPYDPpwKaEd5ZSoldTjgJLbSiPtRgcLf3Si5qXjOOSiRLXiY7FTaCPViK(QCGCXvUVC04xTn3N5QCxWtb6OVqGCXEUpWIu5U0hlsJGxU3qT)vwNLH2eJNLbSiPtRgcLf3Si5qXjOOSiRLXiY7FTaCPViK(QCGCXvUVC04xTn3N5wlJrK3)Ab4sFXYelsL7sFSirH6BFGqfsQpZ6SolsL7cEk4QHohWYawg(aldyrsNwneklUzrYHItqrzrQCxWtb6OVqGCXEUpK7ZCRLXiY7FTaCPViAB)Y9zUimx8ku0QHIU8PG3bE)RfGl9Ll2ZL3TbTTFrJGxU3qT)1iAbQU0xU4GtU4vOOvdfD5tbVd8(xlax6lxCzjxRmxeXIu5U0hlsJGxU3qT)vwNLH2KLbSiPtRgcLf3Si5qXjOOSiXRqrRgk6YNcEh49VwaU0xU4YsUwzU4GtUimxE3g02(f)KtnmIwGQl9LlUYfVcfTAOOlFk4DG3)Ab4sF5(mxMMRRg68iSCuOhHP2obJ0PvdHMlIYfhCY1vdDEewok0JWuBNGr60QHqZ9zU1YyeHLJc9im12jySmL7ZCXRqrRgk6YNcEh49VwaU0xUypxL7sFXp5udJ8UnOT9lxCWj3H8o7bi9v5a5IRCXRqrRgk6YNcEh49VwaU0hlsL7sFSi)KtnK1zzigJLbSiPtRgcLf3Si5qXjOOSiD1qNhvdzlWHkabofegfiwr60QHqZ9zUim3AzmI8(xlax6lI22VCFMltZTwgJ4C7bGdjLXyzkxeXIu5U0hlsuO(2hiuHK6ZSoRZIe46HQq0aSD1L(yzaldFGLbSiPtRgcLf3Si5qXjOOSivUl4PaD0xiqUy3sU4vOOvdfNBpaCiPmggg9tahkms5(mxeMBTmgX52dahskJXYuU4GtU1YyehcKaEd)XYuUiIfPYDPpwKdJ(jGdfgjwNLH2KLbSiPtRgcLf3Si5qXjOOSiRLXiIsQpxB4rXYuUpZfwoA0WxkIsQpdcd1N7FKoTAi0CFMlEfkA1qrx(uW7aV)1cWL(Yfx5wlJreLuFU2WJIq6RYbY9zUk3f8uGo6leixSBjxBYIu5U0hlYHaPQAmSoldXySmGfjDA1qOS4MfjhkobfLfzTmgXHajG3WFSmXIu5U0hlYjSGD1OaN1zzigpldyrsNwneklUzrYHItqrzrwlJrCU9aWHKYySmL7ZCRLXio3Ea4qszmcPVkhixCLRYDPV4qGuvnMizlXlofC5tSivUl9XICclyxnkWzDwgA9SmGfjDA1qOS4MfjhkobfLfzTmgX52dahskJXYuUpZfH5obj8HxoA8H4qGuvnMCXbNChcKaUcDcgvUl4PCXbNCvUl9fNWc2vJc8OCHHrEN9CrelsL7sFSiNWc2vJcCwNLH2ySmGfjDA1qOS4MfPYDPpwKdJ(jGdfgjwKOeGdLjx6JfjdGyLR35(sEUizcI7CNGnhKRCabLYfbQrW5onRacKBdZ1Q9VwaU0xUtZkGa5AFMUCNAaqQgkYIKdfNGIYIu5UGNc0rFHa5IDl5IxHIwnuCwHObUc8WWOFc4qHrk3N5wlJreuUaJY9ccvdbaY9gGKIIvSmL7ZCryU8UnOT9lclhf6ryQTtWiK(QCGCFmxL7sFry5OqpctTDcgjBjEXPGlFk3hZLRap4YNYf75wlJreuUaJY9ccvdbaY9gGKIIvesFvoqU4GtUmnxxn05ry5OqpctTDcgPtRgcnxeL7ZCXRqrRgk6YNcEh49VwaU0xUpMlxbEWLpLl2ZTwgJiOCbgL7feQgcaK7najffRiK(QCawNLHwhSmGfjDA1qOS4MfjhkobfLfzTmgX52dahskJXYuUpZfqkuU3G3f(Cu5UGNyrQCx6Jf5ewWUAuGZ6SmeJILbSiPtRgcLf3Si5qXjOOSiRLXioHfS5gf8Jqs5EUpZLRap4YNYfx5wlJrCclyZnk4hH0xLdK7ZCryUmnxy5OrdFPiOCbgL7feQgcaK7nsNwneAU4GtU1YyeNWc2CJc(ri9v5a5IRCvUl9fhcKQQXe5kWdU8PCFmxUc8GlFkxBuU1YyeNWc2CJc(riPCpxeXIu5U0hlYjSGD1OaN1zzOnoldyrsNwneklUzrwauW(SyOaxbUCVSm8bwKCO4euuwKmn3HajGRqNGrL7cEk3N5Y0CXRqrRgkoeifQgf4HPUnY9M7ZCRLXickxGr5EbHQHaa5EdqsrXkI22VCFMlcZfH5IWCvUl9fhcKQQXejBjEXL7n3N5IWCvUl9fhcKQQXejBjEXPaK(QCGCXvUwz06ZfhCYLP5clhnA4lfhcKaEd)r60QHqZfr5Ido5QCx6loHfSRgf4rYwIxC5EZ9zUimxL7sFXjSGD1Oaps2s8Itbi9v5a5IRCTYO1Nlo4KltZfwoA0Wxkoeib8g(J0PvdHMlIYfr5(m3AzmIZK6Y9gktriPCpxeLlo4KlcZfqkuU3G3f(Cu5UGNY9zUim3AzmIZK6Y9gktriPCp3N5Y0CvUl9fb8gYNJKTeV4Y9Mlo4KltZTwgJ4C7bGdjLXiKuUN7ZCzAU1YyeNj1L7nuMIqs5EUpZv5U0xeWBiFos2s8Il3BUpZLP5o3Ea4qszmaMiJbeKlmmY7SNlIYfr5IiwKfaf6Xi8Yrzz4dSivUl9XICiqkunkWzrIsaouMCPpwKwZcuU3C9zkxGRhQcrZf2U6sFyMBFgSYTaOCzsbs5IBJcCqU2NPlxFMWkxfs5ETNBLK7n3PUneAUJgMlcuJGZTH5A1(xlax6lMlccGYLjfiLlUnkWZLeFMG5IwGY9MRMltkqQQgd2qWyb7QrbEUCf45AFMUCrqj1L7nxeKPCfqUk3f8uUnmx0cuU3CjBjEXPCTl(CUijfk3BUmOl85iRZYWhSswgWIKoTAiuwCZIKdfNGIYISwgJ4C7bGdjLXyzk3N5QCxWtb6OVqGCXvU4vOOvdfNBpaCiPmggg9tahkmsSivUl9XICclyxnkWzDwg(WdSmGfjDA1qOS4MfjhkobfLfjtZfVcfTAO40CtNyByQBJCV5(mxeMltZ1vdDECa7FWNPGcMjqKoTAi0CXbNCvUl4PaD0xiqUyp3hYfr5(mxeMRYDbpfqBpkVN4uU4kxBMlo4KRYDbpfOJ(cbYf7wYfVcfTAO4ScrdCf4HHr)eWHcJuU4GtUk3f8uGo6leixSBjx8ku0QHIZThaoKugddJ(jGdfgPCrelsL7sFSiNMB6eBddJ(jaRZYWhSjldyrsNwneklUzrQCx6JfjxnMGYDPVGraolsJa8WPFIfPYDbpfC1qNdyDwg(agJLbSiPtRgcLf3Si5qXjOOSivUl4PaD0xiqUyp3hyrQCx6JfjkuF7deQqs9zwNLHpGXZYawK0PvdHYIBwKCO4euuwKasHY9g8UWNJk3f8elsL7sFSib8gYNzDwg(G1ZYawK0PvdHYIBwKCO4euuwKk3f8uGo6leixSBjx8ku0QHIkKRhfiBNmnq6l3N5(1tJtCpxSBjx8ku0QHIkKRhfiBNmnq6l81tZ9zUUcFjpAx8z5EWkzrQCx6JfPc56rbY2jtdK(yDwg(GngldyrsNwneklUzrQCx6Jf5WOFc4qHrIfjkb4qzYL(yrYek(CU01L35CDf(soaZCfpxbKRM7RkxUENlxbEUmPr)eWHcJuUki3Hymemx5aoPO52JCzsbsv1yISi5qXjOOSivUl4PaD0xiqUy3sU4vOOvdfNviAGRapmm6NaouyKyDwg(G1bldyrQCx6Jf5qGuvngwK0PvdHYIBwN1zrobjE)RQZYawg(aldyrQCx6JfPc56rb5CYyiUZIKoTAiuwCZ6Sm0MSmGfjDA1qOS4Mfjkb4qzYL(yrIG22Z103BUvA0qkxR2)Ab4sF5cM7IbnxhkhJKdY1NvpxhkVVemxnxWScj0C5QtVneRC5DBqB7xU9LB7ZemxhkhJKdY9Ap3kLBbqOiWZI80pXIe0ftqEpXjilsouCckklsMMlEfkA1qrE)RfGl9f6luauUpZLP5syKImnrOruiPOdbsb8eaqMCFMltZ1vdDECiqc4k0jyKoTAiuwKk3L(yrc6IjiVN4eK1zzigJLbSiPtRgcLf3Sip9tSibZkABNqdnSg6rWB4NoNfPYDPpwKGzfTTtOHgwd9i4n8tNZ6SmeJNLbSivUl9XI8lqyddYxFjwK0PvdHYIBwNLHwpldyrsNwneklUzrYHItqrzrY0CNGe(4ewWUAuGZIu5U0hlYjSGD1OaN1zDwNfjEccK(yzOnTsB(GvIr9agfls7k8K7fWIKjKjIaXqRldToT2CZLbZuUYFQHEUJgMlgG9uyAwbegYfsyKIaj0Cb9NYvlE)vNqZLpR3lbIjZia5OCTP1MRv7dpbDcnxmalhnA4lfTcmKR35Iby5OrdFPOvePtRgcfd5IWhSfrXKzeGCuUwhwBUwTp8e0j0CXGRg68OvGHC9oxm4QHopAfr60QHqXqUi8bBrumzgbihLlgL1MRv7dpbDcnxmalhnA4lfTcmKR35Iby5OrdFPOvePtRgcfd5IqBAlIIjZia5OCFWkT2CTAF4jOtO5Iby5OrdFPOvGHC9oxmalhnA4lfTIiDA1qOyixe(GTikMmNmZeYerGyO1LHwNwBU5YGzkx5p1qp3rdZfdO0qlghd5cjmsrGeAUG(t5QfV)QtO5YN17LaXKzeGCuUpyT5A1(WtqNqZfdWYrJg(srRad56DUyawoA0WxkAfr60QHqXqUQNR1ighcixe(GTikMmJaKJYfJ3AZ1Q9HNGoHMlgGLJgn8LIwbgY17CXaSC0OHVu0kI0PvdHIHCvpxRrmoeqUi8bBrumzgbihL7d20AZ1Q9HNGoHMls5B1CbyDUABUwdwd56DUiGIM7VrlMci3EIGQ3WCrO1aIYfHpylIIjZia5OCFWMwBUwTp8e0j0CXaVp0I4rRad56DUyG3hAr8OvePtRgcfd5IWhSfrXKzeGCuUpGXS2CTAF4jOtO5IbhkhJKhFiAfyixVZfdouogjp6peTcmKlcXy2IOyYmcqok3hWywBUwTp8e0j0CXGdLJrYJ2mAfyixVZfdouogjp62mAfyixeIXSfrXKzeGCuUpGXBT5A1(WtqNqZfd8(qlIhTcmKR35IbEFOfXJwrKoTAiumKlcFWweftMraYr5AZhS2CTAF4jOtO5Iby5OrdFPOvGHC9oxmalhnA4lfTIiDA1qOyixe(GTikMmJaKJY1M20AZ1Q9HNGoHMlgGLJgn8LIwbgY17CXaSC0OHVu0kI0PvdHIHCr4d2IOyYmcqokxBIXS2CTAF4jOtO5Ibxn05rRad56DUyWvdDE0kI0PvdHIHCr4d2IOyYmcqokxBIXS2CTAF4jOtO5Iby5OrdFPOvGHC9oxmalhnA4lfTIiDA1qOyixe(GTikMmJaKJY1My8wBUwTp8e0j0CXaSC0OHVu0kWqUENlgGLJgn8LIwrKoTAiumKlcFWweftMraYr5AtR3AZ1Q9HNGoHMlgGLJgn8LIwbgY17CXaSC0OHVu0kI0PvdHIHCr4d2IOyYmcqokxBADyT5A1(WtqNqZfdWYrJg(srRad56DUyawoA0WxkAfr60QHqXqUi8bBrumzgbihLRnXOS2CTAF4jOtO5Iu(wnxawNR2MR1qUENlcOO5Ik4fG0xU9ebvVH5IqSHOCrigZweftMraYr5AtmkRnxR2hEc6eAUiLVvZfG15QT5AnynKR35IakAU)gTykGC7jcQEdZfHwdikxe(GTikMmJaKJY1MyuwBUwTp8e0j0CXaSC0OHVu0kWqUENlgGLJgn8LIwrKoTAiumKlcFWweftMraYr5IXSsRnxR2hEc6eAUyWvdDE0kWqUENlgC1qNhTIiDA1qOyixe(GTikMmNmZeYerGyO1LHwNwBU5YGzkx5p1qp3rdZfdtqI3)Q6yixiHrkcKqZf0FkxT49xDcnx(SEVeiMmJaKJY1MwBUwTp8e0j0CXGRg68OvGHC9oxm4QHopAfr60QHqXqUQNR1ighcixe(GTikMmNmZeYerGyO1LHwNwBU5YGzkx5p1qp3rdZfd8(xlax6lW72G22pagYfsyKIaj0Cb9NYvlE)vNqZLpR3lbIjZia5OCTXS2CTAF4jOtO5Iby5OrdFPOvGHC9oxmalhnA4lfTIiDA1qOyixe(GTikMmNmZeYerGyO1LHwNwBU5YGzkx5p1qp3rdZfdk3f8uWvdDoad5cjmsrGeAUG(t5QfV)QtO5YN17LaXKzeGCuU20AZ1Q9HNGoHMlgC1qNhTcmKR35Ibxn05rRisNwnekgYfH20weftMraYr5IXS2CTAF4jOtO5Ibxn05rRad56DUyWvdDE0kI0PvdHIHCr4d2IOyYCYmtitebIHwxgADAT5MldMPCL)ud9ChnmxmaC9qviAa2U6sFyixiHrkcKqZf0FkxT49xDcnx(SEVeiMmJaKJY1MwBUwTp8e0j0CXaSC0OHVu0kWqUENlgGLJgn8LIwrKoTAiumKlcFWweftMraYr5AJzT5A1(WtqNqZfdUAOZJwbgY17CXGRg68OvePtRgcfd5IWhSfrXKzeGCuUyuwBUwTp8e0j0CXaSC0OHVu0kWqUENlgGLJgn8LIwrKoTAiumKlcFWweftMraYr5AJBT5A1(WtqNqZfdWYrJg(srRad56DUyawoA0WxkAfr60QHqXqUi0M2IOyYmcqok3hEWAZ1Q9HNGoHMlgC1qNhTcmKR35Ibxn05rRisNwnekgYfHpylIIjZjZmHmreigADzO1P1MBUmyMYv(tn0ZD0WCXaV)1cWL(ctZkGWqUqcJueiHMlO)uUAX7V6eAU8z9EjqmzgbihLlgV1MRv7dpbDcnxmW7dTiE0kWqUENlg49HwepAfr60QHqXqUi8bBrumzgbihLR1H1MRv7dpbDcnxm4QHopAfyixVZfdUAOZJwrKoTAiumKlcFWweftMraYr5ADyT5A1(WtqNqZfdWYrJg(srRad56DUyawoA0WxkAfr60QHqXqUi0M2IOyYmcqokxBCRnxR2hEc6eAUyawoA0WxkAfyixVZfdWYrJg(srRisNwnekgYfHpylIIjZia5OCFWgZAZ1Q9HNGoHMlg49HwepAfyixVZfd8(qlIhTIiDA1qOyixe(GTikMmJaKJY9bRdRnxR2hEc6eAUyG3hAr8OvGHC9oxmW7dTiE0kI0PvdHIHCr4d2IOyYmcqok3hWOS2CTAF4jOtO5IbEFOfXJwbgY17CXaVp0I4rRisNwnekgYfHpylIIjZia5OCT5dwBUwTp8e0j0CXaVp0I4rRad56DUyG3hAr8OvePtRgcfd5QEUwJyCiGCr4d2IOyYCYS19p1qNqZ16ixL7sF5AeGdIjZSiNG9qmelseJ4Czsbs5IatFPKzeJ4CNDFcyTydBVIpxQrE)Xgq(fJ6sFCOoCSbKphBjZigX5YelVfGNRnXyyMRnTsB(qYCYmIrCUwDwVxcyTjZigX5Ad5IGaOChY7ShG0xLdKlu9zcMRpRxUUcFjp6YNcEhqfk3rdZ1Oa3gaeVp0C1QyehRCla9LaXKzeJ4CTHCraDdOlxUc8CHegPiq6tNdYD0WCTA)RfGl9LlcLifXmx0(WGN7CBqZv8Chnmxn3bKaZ5IaJCQH5YvGJOyYmIrCU2qUwJNwnuUahkCpx(mXzuU3C7lxn3bzp3rdzeKRC56ZuUmremcixVZfsOfoLR9gYOPv0yYmIrCU2qUmruMafGNRMlcglyxnkWZLohIvU(S65I2ei3R9C)nkzY1ozm5kNn8QFkxecKFUobCcnx1Z96CbY7jdHRNNR1ebJmx5pPChrXKzeJ4CTHCTAF4jONRAm5wlJr0kIqs5EU05qHa56DU1YyeTIyzcZC1lx18BGNRCa59KHW1ZZ1AIGrM7RkxUYLlq(GyYmIrCU2qUiiak3zfIYBucnx8ku0QHa56DUqcTWPCTkcgbjx7nKrtROXK5KzeJ4CTgTL4fNqZTsJgs5Y7Fv9CR0RCGyUmroNMCqUxF2WSc)JIjxL7sFGC7ZGvmzw5U0hiobjE)RQ)OfSPqUEuqoNmgI7jZigX5YerWiGCXOvOOvdLlg3Kl9zT5ADh5cipxVZvZ96ZgqGJGDU4vtHWmxFMY1Q9VwaU0xUk3L(Yvp0C5DBqB7hixFw9CviLlVpGdv5i0C9o3(myLBLYTai0CTptxUwT)1cWL(Yva5wMY1Uym5ETNBLYTai0Crlq5EZ1NPCbYVyux6lMmJyeNlIrCUk3L(aXjiX7Fv9hTGn8ku0QHW80pzbvaA1qbE)RfGl9HzpzbsaYtMrCUmremcixmAfkA1q5IXn5sFwBUmywa5IxHIwnuUGjIldHa5AFM8zcMRv7FTaCPVCbZDXGMBLYTai0Crlq5EZLjfibCf6emMmJyeNRYDPpqCcs8(xv)rlydVcfTAimp9twgcKaUcDcg49VwaU0hM9Kfa5ykdlm1vdDECclyZnk4JjE1uilpGjE1uOazaKfRmzgX5YerWiGCXOvOOvdLlg3Kl9zT5YGzbKlEfkA1q5cMiUmecKRpt5ELFLG52JCDf(soix1Z1(SWNZfbT9Cr6qszmxM0OFc4qHrcKBxCGGs52JCTA)RfGl9LlyUlg0CRuUfaHgtMrmIZv5U0hiobjE)RQ)OfSHxHIwneMN(jlZThaoKugddJ(jGdfgjm7jlaYXugwC1qNhhg9tHj15ZyIxnfYInXeVAkuGmaYcglzgX5YerWiGCXOvOOvdLlg3Kl9zT5YGzbKlEfkA1q5cMiUmecKRpt5ELFLG52JCDf(soix1Z1(SWNZfbvHO5Avf45YKg9tahkmsGC7Ideuk3EKRv7FTaCPVCbZDXGMBLYTai0CvqUdXyiymzgXioxL7sFG4eK49VQ(JwWgEfkA1qyE6NSmRq0axbEyy0pbCOWiHzpzbqoMYWIRg684WOFkmPoFgt8QPqwSjM4vtHcKbqwWyjZioxMicgbKlgTcfTAOCX4MCPpRnxgmlGCXRqrRgkxWeXLHqGC9zk3R8Rem3EKRRWxYb5QEU2Nf(CUiOTNlshskJ5YKg9tahkmsGCviLBbqO5IwGY9MRv7FTaCPVyYmIrCUk3L(aXjiX7Fv9hTGn8ku0QHW80pzH3)Ab4sFHHr)eWHcJeM9Kfa5ykdlUAOZJdJ(PWK68zmXRMczbJHjE1uOazaKfBSKzeNltebJaYfJwHIwnuUyCtU0N1MldMfqU4vOOvdLlyI4YqiqU(mL7v(vcMBpY1v4l5GCvpx7ZcFoxMiKRhLR1OTtMgi9LBxCGGs52JCTA)RfGl9LlyUlg0CRuUfaHgtMrmIZv5U0hiobjE)RQ)OfSHxHIwneMN(jlkKRhfiBNmnq6dZEYcGCmLHfxn05XHr)uysD(mM4vtHSyJBJJjE1uOazaKfBMmJ4CzIiyeqUy0ku0QHYfJBYL(S2CzWSaYfVcfTAOCbtexgcbY1NPCNiiNoxFPC7rUF90CRKPTNR9zHpNlteY1JY1A02jtdK(Y1Uym5ETNBLYTai0yYmIrCUk3L(aXjiX7Fv9hTGn8ku0QHW80pzrHC9Oaz7KPbsFHVEkMO0qlg3cgVvIzpzbsaYtMrCUmremcixmAfkA1q5IXn5sFwBUmyMY9k)kbZTh56k8LCqUiNLHl3BUi42obZfm3fdAUvk3cGqZTVCrlq5EZ1Q9VwaU0xmzgXioxL7sFG4eK49VQ(JwWgEfkA1qyE6NSW7FTaCPVaywgUCVHP2obXeLgAX4wSjM9KfibipzgX5YerWiGCXOvOOvdLlg3Kl9zT5YGzkxx(uUq6RYj3BU9LRMlxbEU2NPlxR2)Ab4sF5Y1l3kLBbqO5kxUaI3hkiMmJyeNRYDPpqCcs8(xv)rlydVcfTAimp9tw49VwaU0xGRapaPVkhatuAOfJBXkJwhy2twGeG8KzeNltebJaYfJwHIwnuUyCtU0N1MldMfqU4vOOvdLlyI4YqiqU(mL7v(vcMBpYfq8(qb52JCzsbs5IBJc8C9z1Zfm3fdAUvk3PUneAUtkWZ1NPCrPHwmEU6VlNhtMrmIZv5U0hiobjE)RQ)OfSHxHIwneMN(jlnEco1TjmeifQgf4amrPHwmUfReZEYcKaKNmJ4CzIiyeqUy0ku0QHYfJBYL(S2CrqB75A67n3knAiLRv7FTaCPVCbZDXGMR14FcliPMCX4GONECk3kLBbqOiWNmJyeNRYDPpqCcs8(xv)rlydVcfTAimp9twO)ewqsnHgIE6XPakzuSWeLgAX4wEaJcZEYcKaKNmJyeNR1DKRv7FTaCPVCfqUOcqRgcfZCb8zcTyOC9zk3HabEUwT)1cWL(YDOWC1HtWC9zk3H8o75shkiMmJyeNlIrCUk3L(aXjiX7Fv9hTGn8ku0QHW80pzXLpf8oW7FTaCPpmXRMczziVZEasFvoWJpyLwjMYWcEfkA1qrubOvdf49VwaU0xYmIZLbZuUOfO6sF52JC1CrwUCzck3lga5IBdbaY9MRv7FTaCPVyYmIrCUk3L(aXjiX7Fv9hTGn8ku0QHW80pzbWynGwGQl9HzpzbqoM4vtHSy9jZioxMWzYNjyUAUfGwnuUIt)ClacnxVZTwgJCTA)RfGl9LRaYLWifzAIqJjZigX5QCx6deNGeV)v1F0c2WRqrRgcZt)KfE)RfGl9f6luaeM4vtHSqyKImnrOXxJIkQ3qqOQOVeo4qyKImnrOXVY1kKcGzI8WVaeoo4qyKImnrOr5aCyX1QHcyKIEE5hqj8cNWbhcJuKPjcnckx10nAq)KpJfWXbhcJuKPjcns)jSGKAcne90Jt4GdHrkY0eHghg9tHEeQQ7gchCimsrMMi0ODLr6iiimG9HIdoegPitteAuoGdlCVHGaQGxokujJbhCimsrMMi0iywrB7eAOH1qpcEd)05jZioxe02EUM(EZTsJgs5A1(xlax6lxWCxmO56q5yKCqU(S656q59LG5Q5cMviHMlxD6THyLlVBdAB)YTVCBFMG56q5yKCqUx75wPClacfb(KzeJ4CvUl9bItqI3)Q6pAbB4vOOvdH5PFYsFHcGc8I3JbM9Kfa5yIxnfYInTsmLHf8ku0QHI8(xlax6l0xOaOKzeJ4CvUl9bItqI3)Q6pAbB4vOOvdH5PFYsFHcGc8I3JbM9Kfa5yIxnfYInTEmLHfcJuKPjcn(vUwHuamtKh(fGWtMrmIZv5U0hiobjE)RQ)OfSHxHIwneMN(jl9fkakWlEpgy2twaKJjE1uil20kFeVcfTAOi9NWcsQj0q0tpofqjJIfMYWcHrkY0eHgP)ewqsnHgIE6XPKzL7sFG4eK49VQ(JwWwbqbXPpMN(jlGUycY7jobXugwykEfkA1qrE)RfGl9f6lua0tMsyKImnrOruiPOdbsb8eaqMNm1vdDECiqc4k0jyYSYDPpqCcs8(xv)rlyRaOG40hZt)KfWSI22j0qdRHEe8g(PZtMvUl9bItqI3)Q6pAbBFbcByq(6lLmRCx6deNGeV)v1F0c2MWc2vJcCmLHfMobj8XjSGD1OapzozgXioxRrBjEXj0Cj8eeRCD5t56ZuUk3ByUcixfVkgTAOyYSYDPpGfExoNGGjYyWugwykSC0OHVuevaCzYiNcXkW7)xp0KzeJ4CzizF0Ldnxeic0g8uUcixq)jFwU3C9z1ZLRhg8CRuU)gLmeAmzgXioxL7sFGhTGTJSp6YHgGeOn4jmlakyFwmuGRaxUxlpGPmSGWAzmI8(xlax6lwMWbNAzmIGYfyuUxqOAiaqU3aKuuSIqs5oIEwlJr8i7JUCObibAdEkI22VKzeJ4CzWmLlV)1cWL(cU8L7nxL7sF5AeGNlGptOfdbY1(mD5A1(xlax6lx7IXKBLYTai0C1dnxG3qcKRpt5cjqX45kxU4vOOvdfD5tbVd8(xlax6lMmJyeNRYDPpWJwWgxnMGYDPVGraoMN(jl8(xlax6l4YxU3KzeNlgTcfTAOC9z1ZLaU8vNa5AFM8zcMlYzz4Y9MlcUTtWCTlgtUvk3cGqZTsJgs5A1(xlax6lxbKlKuuSIjZigX5QCx6d8OfSHxHIwneMN(jlGzz4Y9gMA7emuPrdPaV)1cWL(WSNSaiht8QPqwqOYDbpfOJ(cbWfEfkA1qrE)RfGl9faZYWL7nm12jio4OCxWtb6OVqaCHxHIwnuK3)Ab4sFHHr)eWHcJeo4GxHIwnu0Lpf8oW7FTaCPpBq5U0xemldxU3WuBNGXrXycqcTWDPpSZ72G22ViywgUCVHP2obJOfO6sFi6jEfkA1qrx(uW7aV)1cWL(SbE3g02(fbZYWL7nm12jyesFvoa2vUl9fbZYWL7nm12jyCumMaKqlCx67jc5DBqB7xewok0JWuBNGri9v5a2aVBdAB)IGzz4Y9gMA7emcPVkha7wpo4Wuxn05ry5OqpctTDcIOKzL7sFGhTGnWSmC5EdtTDcIPmSulJrK3)Ab4sFr02(9u5U0xCiqkunkWJ8zf(saCz5HNmfH1YyeLBqWtnbUc4kkfltpRLXio3Ea4qszmcjL7i6jEfkA1qrWSmC5EdtTDcgQ0OHuG3)Ab4sFjZk3L(apAbBqfv0ZdGjfYiMYWsTmgrE)RfGl9frB73teIxHIwnu0Lpf8oW7FTaCPpSZ72G22pBW6ruYSYDPpWJwWgkP(CTHhHPmSulJrK3)Ab4sFr02(9SwgJiSCuOhHP2obJOT97jEfkA1qrx(uW7aV)1cWL(WfEfkA1qrE)RfGl9fMGexbEWLp9izlXlofC5tpIWAzmIOK6Z1gEueTavx6ZgQLXiY7FTaCPViAbQU0hISrWYrJg(srus9zqyO(C)tMvUl9bE0c2(ce2qqOhbVHF6CmLHf8ku0QHIU8PG3bE)RfGl9Hl8ku0QHI8(xlax6lmbjUc8GlF6rYwIxCk4YNEwlJrK3)Ab4sFr02(LmJ4CzYgMlgnD(mwqmZTaOC1Czsbs5IBJc8C5Zk8LYfTaL7nxeyce2qqU9ixg0WpDEUCf456DUk(wqZLRttY9MlFwHVeiMmRCx6d8OfSneifQgf4ywauW(SyOaxbUCVwEatzyr5U0x8lqydbHEe8g(PZJKTeV4Y9(CumMaK4Zk8LcU8jBq5U0x8lqydbHEe8g(PZJKTeV4uasFvoaUW4FY052dahskJbWezmGGCHHrEN9NmTwgJ4C7bGdjLXyzkzw5U0h4rlyRaOG40htAmiUho9twEnkQOEdbHQI(sykdl4vOOvdfD5tbVd8(xlax6d78UnOT9ZgS(KzL7sFGhTGTcGcItFmp9twO)ewqsnHgIE6XjmLHf8ku0QHIU8PG3bE)RfGl9Hll4vOOvdfP)ewqsnHgIE6XPakzuSEIxHIwnu0Lpf8oW7FTaCPpSJxHIwnuK(tybj1eAi6PhNcOKrXYgS(KzL7sFGhTGTcGcItFmp9twaZkABNqdnSg6rWB4NohtzybH4vOOvdfD5tbVd8(xlax6dxwWRqrRgkY7FTaCPVWeK4kWdU8PhTjo4mK3zpaPVkhax4vOOvdfD5tbVd8(xlax6drpRLXiY7FTaCPViAB)sMvUl9bE0c2kakio9X80pz51G10COhbfaKVyux6dtzybVcfTAOOlFk4DG3)Ab4sFy3cEfkA1qX(cfaf4fVhJKzL7sFGhTGTcGcItFmp9tw(kxRqkaMjYd)cq4ykdl4vOOvdfD5tbVd8(xlax6dxwS(KzeNR1DKBbi3BUAUaNGTGMBF2qbq5ko9Xmx1yxXcKBbq5AnHKIoeiLlgnbaKj3U4abLYTh5A1(xlax6lMlgNptq7cGWm3jO0qXfe4OCla5EZ1AcjfDiqkxmAcaitU2fFoxR2)Ab4sF52NbRCLrUw3BqWtn5AvfWvukxbKlDA1qO5QhAUAUfG(s5AVpm45wPCnnWZTXtWC9zkx0cuDPVC7rU(mL7qEN9yUmywa5QOOGC1CbF1yYfVAkuUENRpt5Y72G22VC7rUwtiPOdbs5IrtaazY1(mD5I2Y9MRplGC5QHxmQl9LBL4Abq5kEUci3Ybj1aCHNR35Qaq5t56ZQNR45AxmMCRuUfaHM7ebhe3nyLBF5Y72G22VyYSYDPpWJwWwbqbXPpMN(jlOqsrhcKc4jaGmykdl4vOOvdfD5tbVd8(xlax6d7wWRqrRgk2xOaOaV49y8eH1YyeLBqWtnbUc4kkfbUYz0sTmgr5ge8utGRaUIsXVABa4kNrCWHP8(qlIhLBqWtnbUc4kkHdo4vOOvdf59VwaU0xOVqbq4GdEfkA1qrx(uW7aV)1cWL(WUCobNAJ6eAyiVZEasFvoG1G1ac5DBqB73JpyLicrjZigX5YqYEUi7IjxR77jobZLohIfM5cjJqGC7lxWScj0CfN(5AvRzUYnA4xDPVC9z1Zva5ETNlwKNlOmn1qNqJ5MlcenzuobY1NPCNGeEPlGCnYr5AFMUChLJ7sFQjMmRCx6d8OfSvauqC6J5PFYcOlMG8EItqmLHfeIxHIwnu0Lpf8oW7FTaCPpSBbJzL2ieIxHIwnuSVqbqbEX7Xa7wjIWbheYuhkhJKhFikGiOlMG8EItWNouogjp(qSa0QHE6q5yK84drE3g02(fH0xLdGdom1HYXi5rBgfqe0ftqEpXj4thkhJKhTzSa0QHE6q5yK8OnJ8UnOT9lcPVkhari6jczkHrkY0eHgrHKIoeifWtaazWbhE3g02(frHKIoeifWtaazIq6RYbWU1JOKzeNldGY7lbZfzxm5ADFpXjyUKcnyLRDXNZ16EdcEQjxRQaUIs52WCTptxUINRDfK7eK4kWJjZk3L(apAbBC94KjulJbMN(jlGUycY7jU0hMYWct59Hwepk3GGNAcCfWvu6PlFcxwpo4ulJruUbbp1e4kGROue4kNrl1YyeLBqWtnbUc4kkf)QTbGRCgtMrCUwxN(GC9z1ZfTZ9Ap3kD0q8CTA)RfGl9LlyUlg0CzcuaEUvk3cGqZTloqqPC7rUwT)1cWL(Yv9Cb9NYDQLZJjZk3L(apAbBfafeN(yE6NSihGdlUwnuaJu0Zl)akHx4eMYWcHrkY0eHgFnkQOEdbHQI(spXRqrRgk6YNcEh49VwaU0h2TGxHIwnuSVqbqbEX7Xizw5U0h4rlyRaOG40hZt)KLHr)uOhHQ6UHWugwimsrMMi04Rrrf1Biiuv0x6jEfkA1qrx(uW7aV)1cWL(WUf8ku0QHI9fkakWlEpgjZk3L(apAbBfafeN(yE6NSyxzKocccdyFOykdlegPitteA81OOI6neeQk6l9eVcfTAOOlFk4DG3)Ab4sFy3cEfkA1qX(cfaf4fVhJKzL7sFGhTGTcGcItFmp9twKd4Wc3BiiGk4LJcvYyWugwimsrMMi04Rrrf1Biiuv0x6jEfkA1qrx(uW7aV)1cWL(WUf8ku0QHI9fkakWlEpgjZk3L(apAbBfafeN(yE6NSakx10nAq)KpJfWXugwimsrMMi04Rrrf1Biiuv0x6jEfkA1qrx(uW7aV)1cWL(WUf8ku0QHI9fkakWlEpgjZk3L(apAbBfafeN(amLHf8ku0QHIU8PG3bE)RfGl9HDl4vOOvdf7luauGx8EmsMrCUiiakxMe2apxg241C9oxhkVVemxRtOamyLR1LlCdftMvUl9bE0c2gWg4HRXRykdlWYrJg(sXxOamyfeUWn0ZAzmI8(xlax6lI22VNieVcfTAOOlFk4DG3)Ab4sFyN3TbTTF4GdEfkA1qrx(uW7aV)1cWL(WfEfkA1qrE)RfGl9fMGexbEWLp9izlXlofC5tikzgX5ADsEU(mLR1uaCzYiNcXkxR2)VEO5wlJrULjmZTCgcaYL3)Ab4sF5kGCbDFXKzL7sFGhTGnExoNGGjYyWugwGLJgn8LIOcGltg5uiwbE))6H(K3TbTTFXAzmcOcGltg5uiwbE))6HgHKII1ZAzmIOcGltg5uiwbE))6HguixpkI22VNmTwgJiQa4YKrofIvG3)VEOXY0teIxHIwnu0Lpf8oW7FTaCPVhvUl9fhWg4124rUc8GlFc78UnOT9lwlJravaCzYiNcXkW7)xp0iAbQU0ho4GxHIwnu0Lpf8oW7FTaCPpCz9ikzw5U0h4rlytHC9Oaz7KPbsFykdlWYrJg(srubWLjJCkeRaV)F9qFY72G22VyTmgbubWLjJCkeRaV)F9qJqsrX6zTmgrubWLjJCkeRaV)F9qdkKRhfrB73tMwlJrevaCzYiNcXkW7)xp0yz6jcXRqrRgk6YNcEh49VwaU03JKTeV4uWLp9OYDPV4a2aV2gpYvGhC5tyN3TbTTFXAzmcOcGltg5uiwbE))6Hgrlq1L(Wbh8ku0QHIU8PG3bE)RfGl9HlR)jtD1qNhHLJc9im12jiIsMvUl9bE0c2gWg4124ykdlWYrJg(srubWLjJCkeRaV)F9qFY72G22VyTmgbubWLjJCkeRaV)F9qJq6RYbWfxbEWLp9SwgJiQa4YKrofIvG3)VEOHbSbEeTTFpzATmgrubWLjJCkeRaV)F9qJLPNieVcfTAOOlFk4DG3)Ab4sFpYvGhC5tyN3TbTTFXAzmcOcGltg5uiwbE))6Hgrlq1L(Wbh8ku0QHIU8PG3bE)RfGl9HlRhrjZk3L(apAbBdyd8W14vmLHfy5OrdFPiQa4YKrofIvG3)VEOp5DBqB7xSwgJaQa4YKrofIvG3)VEOriPOy9SwgJiQa4YKrofIvG3)VEOHbSbEeTTFpzATmgrubWLjJCkeRaV)F9qJLPNieVcfTAOOlFk4DG3)Ab4sFyN3TbTTFXAzmcOcGltg5uiwbE))6Hgrlq1L(Wbh8ku0QHIU8PG3bE)RfGl9HlRhrjZk3L(apAbBC1yck3L(cgb4yE6NSW7FTaCPVW0ScimLHf8ku0QHIU8PG3bE)RfGl9Hllwjo4GxHIwnu0Lpf8oW7FTaCPpCHxHIwnuK3)Ab4sFHjiXvGhC5tp5DBqB7xK3)Ab4sFri9v5a4cVcfTAOiV)1cWL(ctqIRap4YNsMvUl9bE0c2GLJc9im12jiMYWsTmgry5OqpctTDcgrB73tMwlJrCiqc4n8hHKY9NieVcfTAOOlFk4DG3)Ab4sFy3sTmgry5OqpctTDcgrlq1L(EIxHIwnu0Lpf8oW7FTaCPpSRCx6loeifQgf4XrXycqIpRWxk4YNWbh8ku0QHIU8PG3bE)RfGl9H9H8o7bi9v5ai6jczkSC0OHVueuUaJY9ccvdbaY9Ido1YyebLlWOCVGq1qaGCVbiPOyflt4GtTmgrq5cmk3liuneai3Besk3XULAzmIGYfyuUxqOAiaqU34xTnaCLZOn8ao4mK3zpaPVkhax1YyeHLJc9im12jyeTavx6drjZioxeC3MCvqUF9WkxMuGuU42OahKRcYDQbaPAOChnmxR2)Ab4sFXCrwQou5EUDXZTh56ZuUdOYDPp1KlV)t9rNNBpY1NPCVYVsWC7rUmPaPCXTrboixFw9CTlgtUN6fOAmyLlK4Zk8LYfTaL7nxFMY1Q9VwaU0xUtZkGYTsCTaOCN62i3BU6HLpl3BUtkWZ1Nvpx7IXK71EUVq98C1lxYwhQ5YKcKYf3gf45IwGY9MRv7FTaCPVyYSYDPpWJwWgEfkA1qywauOhJWlh1YdywauW(SyOaxbUCVwEaZt)KLHaPq1Oapm1TrUxmXRMczr5U0xCiqkunkWJ8zf(sGWaQCx6tnpIq8ku0QHIU8PG3bE)RfGl99OYDPViywgUCVHP2obJJIXeGeAH7sF2i8ku0QHIGzz4Y9gMA7emuPrdPaV)1cWL(qK1aVBdAB)IdbsHQrbEeTavx6ZgEax8UnOT9loeifQgf4XVABGpRWxc8iEfkA1qXgpbN62egcKcvJcCG1aVBdAB)IdbsHQrbEeTavx6ZgqyTmgrE)RfGl9frlq1L(Sg4DBqB7xCiqkunkWJOfO6sFiYAWA4HN4vOOvdfD5tbVd8(xlax6dxd5D2dq6RYbWbhy5OrdFPiOCbgL7feQgcaK79jGuOCVbVl85OYDbp9u5U0xCiqkunkWJJIXeGeFwHVuWLpHDmMn6LJg)QTjZioxmAfkA1q56ZQNlVph2gqUi45MoX2CzsJ(jqUfG(s56DU0bkqkxXb5YNv4lbYvHuUtDBi0ChnmxR2)Ab4sFXCX4odw5wauUi45MoX2CzsJ(jqUDXbckLBpY1Q9VwaU0xU2NPl3rXyYLpRWxcKlxVCRuUD1v5i0Crlq5EZ1NPCpYwpxR2)Ab4sFXKzeJ4CvUl9bE0c2WRqrRgcZt)KLP5MoX2Wu3g5EXugwuUl4PaD0xiaUWRqrRgkY7FTaCPVWWOFc4qHrct8QPqwWRqrRgk6YNcEh49VwaU03J1Yye59VwaU0xeTavx6ZgSECPCx6lon30j2ggg9tG4OymbiXNv4lfC5tpY72G22V40CtNyByy0pbIOfO6sF2GYDPViywgUCVHP2obJJIXeGeAH7sF2i8ku0QHIGzz4Y9gMA7emuPrdPaV)1cWL(EIxHIwnu0Lpf8oW7FTaCPpCnK3zpaPVkhahCGLJgn8LIGYfyuUxqOAiaqUxCWXLpHlRpzgX5YeotxUfGCV5YKg9tahkms5kxUwT)1cWL(WmxGINYvb5(1dRC5Zk8La5QGCNAaqQgk3rdZ1Q9VwaU0xU2fFUlEUCDAsU3yYmIrCUk3L(apAbB4vOOvdH5PFYY0CtNyByQBJCVykdlk3f8uGo6lea7wWRqrRgkY7FTaCPVWWOFc4qHrct8QPqwWRqrRgk6YNcEh49VwaU0hUuUl9fNMB6eBddJ(jqCumMaK4Zk8LcU8jBq5U0xemldxU3WuBNGXrXycqcTWDPpBeEfkA1qrWSmC5EdtTDcgQ0OHuG3)Ab4sFpXRqrRgk6YNcEh49VwaU0hUgY7ShG0xLdGdoWYrJg(srq5cmk3liuneai3lo44YNWL1NmRCx6d8OfSXvJjOCx6lyeGJ5PFYcSNctZkGWe4qH7wEatzyPwgJiSCuOhHP2obJLPN4vOOvdfD5tbVd8(xlax6d7wzYmIZLjIYeOa8C9zkx8ku0QHY1NvpxEFoSnGCzsbs5IBJc8Cla9LY17CPduGuUIdYLpRWxcKRcPCvdOZDQBdHM7OH5Iavok3EKlcUTtWyYSYDPpWJwWgEfkA1qywauOhJWlh1YdywauW(SyOaxbUCVwEaZt)KLHaPq1Oapm1TrUxmXRMczH3TbTTFry5OqpctTDcgH0xLdGlL7sFXHaPq1Oapokgtas8zf(sbx(KnOCx6lcMLHl3ByQTtW4OymbiHw4U0NncH4vOOvdfbZYWL7nm12jyOsJgsbE)RfGl99K3TbTTFrWSmC5EdtTDcgH0xLdGlE3g02(fHLJc9im12jyesFvoaIEY72G22ViSCuOhHP2obJq6RYbW1qEN9aK(QCamLHfMIxHIwnuCiqkunkWdtDBK79PRg68iSCuOhHP2obFwlJrewok0JWuBNGr02(LmJ4CzcNPlxeufIYvGl3BUmPr)uUiDOWiHzUmPaPCXTrboixWCxmO5wPClacnxVZ9LocQoLlcA75I0HKYiix9qZ17CjBD6qZf3gf4emxeykWjymzw5U0h4rlyBiqkunkWXSaOqpgHxoQLhWSaOG9zXqbUcC5ET8aMYWctXRqrRgkoeifQgf4HPUnY9(eVcfTAOOlFk4DG3)Ab4sFy3kFQCxWtb6OVqaSBbVcfTAO4ScrdCf4HHr)eWHcJ0tMoeibCf6emQCxWtpzATmgX52dahskJXY0tewlJrCMuxU3qzkwMEQCx6lom6NaouyKIKTeV4uasFvoaUSYO1Jdo8zf(sGWaQCx6tny3InruYmIZ1AwGY9Mltkqc4k0jiM5YKcKYf3gf4GCviLBbqO5cKVyuObRC9ox0cuU3CTA)RfGl9fZ16KocQgdwyMRptyLRcPClacnxVZ9LocQoLlcA75I0HKYiix7Z0Llhkoix7IXK71EUvkx7kWj0C1dnx7IpNlUnkWjyUiWuGtqmZ1NjSYfm3fdAUvkxWeKu0C7INR35(v5CvUC9zkxCBuGtWCrGPaNG5wlJrmzw5U0h4rlyBiqkunkWXSaOqpgHxoQLhWSaOG9zXqbUcC5ET8aMYWYqGeWvOtWOYDbp9KpRWxcGDlp8KP4vOOvdfhcKcvJc8Wu3g5EFIqMQCx6loeivvJjs2s8Il37tMQCx6loHfSRgf4r5cdJ8o7pRLXiotQl3BOmflt4GJYDPV4qGuvnMizlXlUCVpzATmgX52dahskJXYeo4OCx6loHfSRgf4r5cdJ8o7pRLXiotQl3BOmfltpzATmgX52dahskJXYeIsMrCUmr8TGMlxNMK7nxMuGuU42Oapx(ScFjqU2NfdLlFwVJmY9MlYzz4Y9MlcUTtWKzL7sFGhTGTHaPq1OahZcGc2Nfdf4kWL71Ydykdlk3L(IGzz4Y9gMA7ems2s8Il37ZrXycqIpRWxk4YNWLYDPViywgUCVHP2obJUWzmaj0c3L(EwlJrCU9aWHKYyeTTFpD5ty)bRmzw5U0h4rlyJRgtq5U0xWiahZt)KfGRhQcrdW2vx6dtzybVcfTAOOlFk4DG3)Ab4sFy3kFwlJrewok0JWuBNGr02(LmRCx6d8OfSb4nKpNmNmRCx6devUl4PGRg6CGfJGxU3qT)vmLHfL7cEkqh9fcG9hEwlJrK3)Ab4sFr02(9eH4vOOvdfD5tbVd8(xlax6d78UnOT9lAe8Y9gQ9Vgrlq1L(Wbh8ku0QHIU8PG3bE)RfGl9HllwjIsMvUl9bIk3f8uWvdDo4rly7to1qmLHf8ku0QHIU8PG3bE)RfGl9Hllwjo4GqE3g02(f)KtnmIwGQl9Hl8ku0QHIU8PG3bE)RfGl99KPUAOZJWYrHEeMA7eer4GJRg68iSCuOhHP2obFwlJrewok0JWuBNGXY0t8ku0QHIU8PG3bE)RfGl9HDL7sFXp5udJ8UnOT9dhCgY7ShG0xLdGl8ku0QHIU8PG3bE)RfGl9LmRCx6devUl4PGRg6CWJwWgkuF7deQqs9zmLHfxn05r1q2cCOcqGtbHrbI1tewlJrK3)Ab4sFr02(9KP1YyeNBpaCiPmgltikzozw5U0hiY7FTaCPVaVBdAB)awMAx6lzw5U0hiY7FTaCPVaVBdAB)apAbBvt3OHrbIvYSYDPpqK3)Ab4sFbE3g02(bE0c2QeeqqgL7ftzyPwgJiV)1cWL(ILPKzL7sFGiV)1cWL(c8UnOT9d8OfSneivnDJMmRCx6de59VwaU0xG3TbTTFGhTGn94eWHQjWvJjzw5U0hiY7FTaCPVaVBdAB)apAbBU8PGDfoHPmSalhnA4lfD6p1q1eSRWPN1YyejBN1cWL(ILPKzL7sFGiV)1cWL(c8UnOT9d8OfSvauqC6Jjnge3dN(jlVgfvuVHGqvrFPKzL7sFGiV)1cWL(c8UnOT9d8OfSvauqC6J5PFYICaoS4A1qbmsrpV8dOeEHtjZk3L(arE)RfGl9f4DBqB7h4rlyRaOG40hZt)KLHr)uOhHQ6UHsMvUl9bI8(xlax6lW72G22pWJwWwbqbXPpMN(jl2vgPJGGWa2hAYSYDPpqK3)Ab4sFbE3g02(bE0c2kakio9X80pzroGdlCVHGaQGxokujJjzw5U0hiY7FTaCPVaVBdAB)apAbBfafeN(yE6NSakx10nAq)KpJfWtMvUl9bI8(xlax6lW72G22pWJwWwbqbXPpizozw5U0hiY7FTaCPVW0Scilg5D2bbMaf03pDoMYWsTmgrE)RfGl9frB7xYmIZ1Ae4YxDk352EUM(EZ1Q9VwaU0xU2fJjxJc8C9z9yeKR35ISC5YeuUxmaYf3gcaK7nxVZfLCc(LJYDUTNltkqkxCBuGdYfm3fdAUvk3cGqJjZigX5QCx6de59VwaU0xyAwb0JwWgEfkA1qywauOhJWlh1YdywauW(SyOaxbUCVwEaZt)KfYwNoucnW7FTaCPVaK(QCam7jlaYXeVAkKLAzmI8(xlax6lcPVkh4XAzmI8(xlax6lIwGQl9zJqiVBdAB)I8(xlax6lcPVkhax1Yye59VwaU0xesFvoaIWugw49Hwepk3GGNAcCfWvukzgX5Yerrb56ZuUOfO6sF52JC9zkxKLlxMGY9IbqU42qaGCV5A1(xlax6lxVZ1NPCPdn3EKRpt5YlqiDEUwT)1cWL(Yvg56ZuUCf45AVlg0C59FYqoLlAbk3BU(SaY1Q9VwaU0xmzgXioxL7sFGiV)1cWL(ctZkGE0c2WRqrRgcZcGc9yeE5OwEaZcGc2Nfdf4kWL71YdyE6NSq260HsObE)RfGl9fG0xLdGzpzrrrXeVAkKf8ku0QHIagRb0cuDPpmLHfEFOfXJYni4PMaxbCfLEIWAzmIGYfyuUxqOAiaqU3aKuuSILjCWbVcfTAOizRthkHg49VwaU0xasFvoa2FiA92OxoA8R2AJqyTmgrq5cmk3liuneai3B8R2gaUYz0gQLXickxGr5EbHQHaa5EJax5mIieLmRCx6de59VwaU0xyAwb0JwWwvFd9i4qHZiatzyPwgJiV)1cWL(IOT9lzw5U0hiY7FTaCPVW0ScOhTGnJGxU3qT)vmLHfL7cEkqh9fcG9hEwlJrK3)Ab4sFr02(LmJ4CzcfFUlEUw3BqWtn5AvfWvucZCzcuaEUfaLltkqkxCBuGdY1(mD56Zew5AVpm45(lhFoxouCqU6HMR9z6YLjfib8g(Zva5I22VyYSYDPpqK3)Ab4sFHPzfqpAbBdbsHQrboMfaf6Xi8YrT8aMfafSplgkWvGl3RLhWugwykVp0I4r5ge8utGRaUIsp5Zk8Lay3YdpRLXiY7FTaCPVyz6jtRLXioeib8g(JLPNmTwgJ4C7bGdjLXyz65C7bGdjLXayImgqqUWWiVZ(J1YyeNj1L7nuMILjCzZKzeNltO4Z5ADVbbp1KRvvaxrjmZLjfiLlUnkWZTaOCbZDXGMBLYvrrfx6tngSYL3hWHQCeAUGoxFw9CfpxbK71EUvk3cGqZTCgcaY16EdcEQjxRQaUIs5kGC1Ax8C9oxY2jbs52WC9zcs5Qqk3FdPC9z9YLUU8oNltkqkxCBuGdY17CjBD6qZ16EdcEQjxRQaUIs56DU(mLlDO52JCTA)RfGl9ftMrmIZv5U0hiY7FTaCPVW0ScOhTGn8ku0QHWSaOqpgHxoQLhWSaOG9zXqbUcC5ET8aMN(jlKTte3j0WqGuOAuGdWSNSaiht8QPqwuUl9fhcKcvJc8iFwHVeimGk3L(uZJieVcfTAOizRthkHg49VwaU0xasFvoGnulJruUbbp1e4kGROueTavx6drwd8UnOT9loeifQgf4r0cuDPpmLHfEFOfXJYni4PMaxbCfLsMrmIZv5U0hiY7FTaCPVW0ScOhTGn8ku0QHWSaOqpgHxoQLhWSaOG9zXqbUcC5ET8aMN(jlhrOeAyiqkunkWby2twaKJjE1uilCsmieVcfTAOizRthkHg49VwaU0xasFvoG1acRLXik3GGNAcCfWvukIwGQl9zdVC04xTfrictzyH3hAr8OCdcEQjWvaxrPKzL7sFGiV)1cWL(ctZkGE0c2gcKcvJcCmlak0Jr4LJA5bmlakyFwmuGRaxUxlpGPmSW7dTiEuUbbp1e4kGRO0t(ScFja2T8WteIxHIwnuKSDI4oHggcKcvJcCa2TGxHIwnu8icLqddbsHQrboahCQLXiY7FTaCPViK(QCaC9YrJF1wCWbVcfTAOizRthkHg49VwaU0xasFvoaUSulJruUbbp1e4kGROueTavx6dhCQLXik3GGNAcCfWvukcCLZiUSjo4ulJruUbbp1e4kGROuesFvoaUE5OXVAlo4W72G22ViywgUCVHP2obJqsrX6PYDbpfOJ(cbWUf8ku0QHI8(xlax6laMLHl3ByQTtWN8gpD65XtEN9Wqje9SwgJiV)1cWL(ILPNiKP1YyehcKaEd)riPChhCQLXik3GGNAcCfWvukcPVkhaxwz06r0tMwlJrCU9aWHKYyesk3Fo3Ea4qszmaMiJbeKlmmY7S)yTmgXzsD5EdLPiKuUJlBMmRCx6de59VwaU0xyAwb0JwWgxnMGYDPVGraoMN(jlk3f8uWvdDoizw5U0hiY7FTaCPVW0ScOhTGnE)RfGl9HzbqHEmcVCulpGzbqb7ZIHcCf4Y9A5bmLHL52dahskJbWezmGGCHHrENDlw5ZAzmI8(xlax6lI22VN4vOOvdfD5tbVd8(xlax6dxwSYNiKPWYrJg(srubWLjJCkeRaV)F9qXbNAzmIOcGltg5uiwbE))6Hglt4GtTmgrubWLjJCkeRaV)F9qddyd8yz6PRg68iSCuOhHP2obFY72G22VyTmgbubWLjJCkeRaV)F9qJqsrXcrpritHLJgn8LIVqbyWkiCHBiCWbLQLXi(cfGbRGWfUHILje9eHmL34PtppEeh2MgIIdo8UnOT9lIsQpxB4rri9v5a4GtTmgrus95AdpkwMq0teYuEJNo98iE68zSG4GdVBdAB)IFbcBii0JG3WpDEesFvoaIEIqL7sFXp5udJYfgg5D2FQCx6l(jNAyuUWWiVZEasFvoaUSGxHIwnuK3)Ab4sFbUc8aK(QCaCWr5U0xeWBiFos2s8Il37tL7sFraVH85izlXlofG0xLdGl8ku0QHI8(xlax6lWvGhG0xLdGdok3L(Idbsv1yIKTeV4Y9(u5U0xCiqQQgtKSL4fNcq6RYbWfEfkA1qrE)RfGl9f4kWdq6RYbWbhL7sFXjSGD1Oaps2s8Il37tL7sFXjSGD1Oaps2s8Itbi9v5a4cVcfTAOiV)1cWL(cCf4bi9v5a4GJYDPV4WOFc4qHrks2s8Il37tL7sFXHr)eWHcJuKSL4fNcq6RYbWfEfkA1qrE)RfGl9f4kWdq6RYbquYmIZfJZNjyU8UnOT9dKRpREUG5UyqZTs5waeAU2fFoxR2)Ab4sF5cM7Ibn3(myLBLYTai0CTl(CU6LRY9IAY1Q9VwaU0xUCf45QhAUx75Ax85C1CrwUCzck3lga5IBdbaY9M7eS5XKzL7sFGiV)1cWL(ctZkGE0c24QXeuUl9fmcWX80pzH3)Ab4sFbE3g02(bWugwQLXiY7FTaCPViK(QCaSJrHdo8UnOT9lY7FTaCPViK(QCaCz9jZk3L(arE)RfGl9fMMva9OfSnm6NaouyKWugwqyTmgX52dahskJXY0tL7cEkqh9fcGDl4vOOvdf59VwaU0xyy0pbCOWiHiCWbH1YyehcKaEd)XY0tL7cEkqh9fcGDl4vOOvdf59VwaU0xyy0pbCOWizdWYrJg(sXHajG3WpIsMrCUiqkQONNlYjfYyUG5UyqZTs5waeAU2fFoxnxe02ZfPdjLXCHKIIvUENBbq5k)pHkQtgSYvhobZ1NPC5kWZDiNaMjqmxgmlGCTlgtUN6fOAmyLlG8Clt5Q5IG2EUiDiPmMlyIop3rdZ1NPChYPMCbUYzm3EKlcKIk655ICsHmgtMvUl9bI8(xlax6lmnRa6rlydQOIEEamPqgXugwQLXiY7FTaCPVyz6PnTr1YyeNBpaCiPmgHKY9hRLXiotQl3BOmfHKY9hNBpaCiPmgatKXacYfgg5D2TyZKzL7sFGiV)1cWL(ctZkGE0c2MWc2vJcCmLHLAzmIdbsaVH)yzkzw5U0hiY7FTaCPVW0ScOhTGTjSGD1OahtzyPwgJ4C7bGdjLXyz6zTmgrE)RfGl9fltjZk3L(arE)RfGl9fMMva9OfSnHfSRgf4ykdltqcF4LJgFic4nKp)SwgJ4mPUCVHYuSm9u5UGNc0rFHa4cVcfTAOiV)1cWL(cdJ(jGdfgPN1Yye59VwaU0xSmLmRCx6de59VwaU0xyAwb0JwWgSCuOhHP2obXugwQLXickxGr5EbHQHaa5EdqsrXkwMEwlJrewok0JWuBNGri9v5a4s5U0xCclyxnkWJCf4bx(0ZAzmIGYfyuUxqOAiaqU3aKuuSIq6RYbWUYDPV4ewWUAuGh5kWdU8PhjBjEXPGlFkzgX5IGaK7nxKZYWL7nxeCBNG5IwGY9MRv7FTaCPVC9oxib8gs5YKcKYf3gf45QhAUi45MoX2CzsJ(PC5Zk8La5Y1l3kLBLoAiCrnyMBT45waf1yWk3(myLBF5YeBRXyYSYDPpqK3)Ab4sFHPzfqpAbBGzz4Y9gMA7eetzyPwgJiV)1cWL(ILPNmv5U0xCiqkunkWJ8zf(sGNk3f8uGo6lea7wWRqrRgkY7FTaCPVaywgUCVHP2obFQCx6lon30j2ggg9tGiFwHVeaxk3L(ItZnDITHHr)ei(vBd8zf(sGKzL7sFGiV)1cWL(ctZkGE0c2gg9tahkmsykdlk3f8uGo6lea7wWRqrRgkY7FTaCPVWWOFc4qHr6zTmgrq5cmk3liuneai3BaskkwXY0ZAzmIGYfyuUxqOAiaqU3aKuuSIq6RYbWoxbEWLp9eHmL3hAr8OCdcEQjWvaxrjCWPwgJOCdcEQjWvaxrPiK(QCaSt2s8Itbx(eo4ulJrCMuxU3qzkcjL7po3Ea4qszmaMiJbeKlmmY7SJlBIOKzL7sFGiV)1cWL(ctZkGE0c2MWc2vJcCmLHLAzmIGYfyuUxqOAiaqU3aKuuSILPN1YyebLlWOCVGq1qaGCVbiPOyfH0xLdGDUc8GlF6jczkVp0I4r5ge8utGRaUIs4GtTmgr5ge8utGRaUIsri9v5ayNSL4fNcU8jCWPwgJ4mPUCVHYuesk3FCU9aWHKYyamrgdiixyyK3zhx2erjZk3L(arE)RfGl9fMMva9OfSnHfSRgf4ykdl1YyeNWc2CJc(riPC)zTmgXjSGn3OGFesFvoa25kWdU8PNiSwgJiV)1cWL(Iq6RYbWoxbEWLpHdo1Yye59VwaU0xeTTFi6PYDbpfOJ(cbWfEfkA1qrE)RfGl9fgg9tahkmsprit59Hwepk3GGNAcCfWvuchCQLXik3GGNAcCfWvukcPVkha7KTeV4uWLpHdo1YyeNj1L7nuMIqs5(JZThaoKugdGjYyab5cdJ8o74YMikzw5U0hiY7FTaCPVW0ScOhTGTP5MoX2WWOFcGPmSulJrK3)Ab4sFXY0thQ4jtWLpHRAzmI8(xlax6lcPVkh4zTmgXzsD5EdLPiKuU)4C7bGdjLXayImgqqUWWiVZoUSzYSYDPpqK3)Ab4sFHPzfqpAbBdJ(jGdfgjmLHLAzmI8(xlax6lI22VN8UnOT9lY7FTaCPViK(QCaCXvGhC5tpvUl4PaD0xia2TGxHIwnuK3)Ab4sFHHr)eWHcJuYSYDPpqK3)Ab4sFHPzfqpAbBdbsv1yWugwQLXiY7FTaCPViAB)EY72G22ViV)1cWL(Iq6RYbWfxbEWLp9KP8(qlIhhg9tbLZHKl9LmRCx6de59VwaU0xyAwb0JwWgG3q(mMYWsTmgrE)RfGl9fH0xLdGDUc8GlF6zTmgrE)RfGl9flt4GtTmgrE)RfGl9frB73tE3g02(f59VwaU0xesFvoaU4kWdU8PKzL7sFGiV)1cWL(ctZkGE0c2mcE5Ed1(xXugwQLXiY7FTaCPViK(QCaC9YrJF12Nk3f8uGo6lea7pKmRCx6de59VwaU0xyAwb0JwWgkuF7deQqs9zmLHLAzmI8(xlax6lcPVkhaxVC04xT9zTmgrE)RfGl9fltjZjZioxeuYmrWCXRqrRgkxFw9C595QCGC9zkxL7f1KlbC5RoHMRlFkxFw9C9zk3JS1Z1Q9VwaU0xU2fJj3kLlKuuSIjZigX5QCx6de59VwaU0xWLVCVwWRqrRgcZt)KfE)RfGl9fGKIIvWLpHjE1uil8UnOT9lY7FTaCPViK(QCaBez7eXDcnWOCOg5EdqcTWDPVKzeNldMPC5kWZ1LpLBpY1NPCbtKXKRpREU2fJj3kL7eK4kWZvoVZ1Q9VwaU0xmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xycsCf4bx(eM4vtHSGqL7sFXHaPQAmrUc8GlFYgXuEFOfXJdJ(PGY5qYL(Eu5U0xeWBiFoYvGhC5tpY7dTiECy0pfuohsU0hISriu5UGNc0rFHa4cVcfTAOiV)1cWL(cdJ(jGdfgje9OYDPV4WOFc4qHrkYvGhC5t2ieQCxWtb6OVqaSBbVcfTAOiV)1cWL(cdJ(jGdfgjezd4vOOvdf59VwaU0xGRapaPVkhizgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xWLpHjE1uil4vOOvdf59VwaU0xaskkwbx(uYmIZ1AsgfRCTA)RfGl9L7OH5QdNG5YKcKaUcDcMB5meaKlEfkA1qXHajGRqNGbE)RfGl9LRaYfqEmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xWLpHzpz5R2IjE1uildbsaxHobJq6RYbWugwC1qNhhcKaUcDc(KP4vOOvdfhcKaUcDcg49VwaU0xYmIZ1AsgfRCTA)RfGl9L7OH5IaPOIEEUiNuiJ5kJCfpx7IXKlV)uU9yKlVBdAB)Yf09ftMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcZt)KfE)RfGl9fC5ty2tw(QTyIxnfYcVBdAB)Iqfv0ZdGjfYyesFvoaMYWcVXtNEEKrSGIEp5DBqB7xeQOIEEamPqgJq6RYbSHhSsCHxHIwnuK3)Ab4sFbx(uYmIZ1AsgfRCTA)RfGl9L7OH5IatGWgcYTh5YGg(PZtMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcZt)KfE)RfGl9fC5ty2tw(QTyIxnfYcVBdAB)IFbcBii0JG3WpDEesFvoaMYWcVXtNEEepD(mwWN8UnOT9l(fiSHGqpcEd)05ri9v5a2GnTECHxHIwnuK3)Ab4sFbx(uYmIZ1AsgfRCTA)RfGl9L7OH5Anj1NRn8OyYmIrCUk3L(arE)RfGl9fC5l37JwWgEfkA1qyE6NSW7FTaCPVGlFcZEYYxTft8QPqw4DBqB7xeLuFU2WJIq6RYbEeH1Yyerj1NRn8OiAbQU0NnulJrK3)Ab4sFr0cuDPpezJGLJgn8LIOK6ZGWq95(JPmSWB80PNhpIdBtdrFY72G22VikP(CTHhfH0xLdydpyL4cVcfTAOiV)1cWL(cU8PKzeNR1Kmkw5A1(xlax6l3rdZ1AsQpJbqUmP6Z9pxGRCgb5kJC9zcs5Qqkx1Z1qkWZ1T356k8LCqmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xWLpHzpz5R2IjE1uil1Yyerj1NRn8OiK(QCaBOwgJiV)1cWL(IOfO6sFykdlWYrJg(srus9zqyO(C)FwlJreLuFU2WJILPNk3f8uGo6lea7wSzYmIZ1AsgfRCTA)RfGl9L7OH56ZuUwJ)jSGKAYfJdIE6XPCRLXixzKRpt5ozuSiyUci3cqU3C9z1Z1HYXi5XKzeJ4CvUl9bI8(xlax6l4YxU3hTGn8ku0QHW80pzH3)Ab4sFbx(eM9KLVAlM4vtHSGxHIwnuK(tybj1eAi6PhNcOKrXYgqiVBdAB)I0FcliPMqdrp94ueTavx6Zg4DBqB7xK(tybj1eAi6PhNIq6RYbqKnIP8UnOT9ls)jSGKAcne90JtriPOyHPmSqyKImnrOr6pHfKutOHONECkzgX5AnjJIvUwT)1cWL(YD0WCTonkQOEdb5IBf9LWm3YziaixXZ1ExmO5wPCrjJIfHMRPVxcMRpRxU20kZfq8(qbXKzeJ4CvUl9bI8(xlax6l4YxU3hTGn8ku0QHW80pzH3)Ab4sFbx(eM9KLVAlM4vtHSW72G22V4Rrrf1Biiuv0xkcPVkhatzyHWifzAIqJVgfvuVHGqvrFPN8UnOT9l(Auur9gccvf9LIq6RYbSbBAL4cVcfTAOiV)1cWL(cU8PKzeNR1Kmkw5A1(xlax6l3Y5IjxeOgbNlz7KajqUYixXXai3YumzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xWLpHzpz5R2IjE1uil1YyeHLJc9im12jyesFvoaMYWIRg68iSCuOhHP2obFwlJrK3)Ab4sFr02(LmJ4CTMKrXkxR2)Ab4sF5oAyU6LlzRd1CrGkhLBpYfb32jyUYixFMYfbQCuU9ixeCBNG5AVlg0C59NYThJC5DBqB7xUQNRHuGNR1NlG49HcYTsJgs5A1(xlax6lx7DXGgtMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcZt)KfE)RfGl9fC5ty2tw(QTyIxnfYcVBdAB)IWYrHEeMA7emcPVkh4XAzmIWYrHEeMA7emIwGQl9HPmS4QHopclhf6ryQTtWN1Yye59VwaU0xeTTFp5DBqB7xewok0JWuBNGri9v5apA94cVcfTAOiV)1cWL(cU8PKzeNR1Kmkw5A1(xlax6lxzKR1uaCzYiNcXkxR2)VEO5AVlg0CV2ZTs5cjffRChnmxXZflYJjZigX5QCx6de59VwaU0xWLVCVpAbB4vOOvdH5PFYcV)1cWL(cU8jm7jlF1wmXRMczH3TbTTFXAzmcOcGltg5uiwbE))6HgH0xLdGPmSalhnA4lfrfaxMmYPqSc8()1d9zTmgrubWLjJCkeRaV)F9qJOT9lzgX5IaPcAUwJ4PZbwBUwtYOyLRv7FTaCPVChnmxffnxWKA)a52JCXy52WC)nKYvrrb56ZQNRDXyY1OapxtFVemxFwVCFW6Zfq8(qbXCzWmbOCXRMcbYvH0Hbp3J4eaOqXGvU9KlF1KRC5QgtUCfqGyYmIrCUk3L(arE)RfGl9fC5l37JwWgEfkA1qyE6NSW7FTaCPVGlFcZEYYxTft8QPqwGQGgi805rfffeLdtzybQcAGWtNhvuuqKSvao4juf0aHNopQOOGiVlNJDlySNqvqdeE68OIIcIOfO6sFy)bRpzgX5IaPcAUwJ4PZbwBUmrJDflqUfaLRv7FTaCPVCTl(CU4lMJGAvmIJvUqvqZLWtNdWm3gpbHckLREyLlkzuSa5AeGtO5Q1gpLR35(vgPCbfiLR45(soi3cGqZDMGumzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xWLpHjE1uilqvqdeE68i(I5iOwnuuoBetHQGgi805r8fZrqTAOyzctzybQcAGWtNhXxmhb1QHIKTcWbpXRqrRgkY7FTaCPVaKuuScU8jCbvbnq4PZJ4lMJGA1qr5sMrCUiiakxFMY9iB9CTA)RfGl9LBF5Y72G22VCLrUINR9UyqZ9Ap3kLlz7eXDcnxVZfLmkw56ZuUa(mHwmeAU9r52WC9zkxaFMqlgcn3(OCT3fdAUZ60eD5AiaixFwVCTPvMlG49HcYTsJgs56ZuUd5D2ZLouqmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xWLpHjE1uil4vOOvdf59VwaU0xaskkwbx(eMYWcEfkA1qrE)RfGl9fGKIIvWLp9iVBdAB)I8(xlax6lIwGQl9zJq4d2acTYOn2Jwz0M2ixn05XHajGRqNGiYg5QHopYOCOg5EreUSGxHIwnuK3)Ab4sFbx(eo4GxHIwnuK3)Ab4sFbx(e2hY7ShG0xLdyd20ktMrCUmru0C9zkxEbcPZZ1LpLR356ZuUa(mHwmeAUwT)1cWL(Y17CNkEUINRC5QvqBkoLRlFkxqNRpREUINRaYf4IXKRY5fO6uU6WjyUAUgXDdLRlFk3jfaiqmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimp9tw49VwaU0xWLpHzpzrrrXeVAkKfx(uYmIZLjLtngSWmxEF4jON7a2)C1kOnfNY1LpLREO5c8gs56ZuUqYOUGNY1LpLRC5IxHIwnu0Lpf8oW7FTaCPVyUiiNryKY1NPCHeWZTh56ZuUC1Wlg1L(ayMR9zHpN7SonrxUgcaYDajmsHo3GvUENlyIi0Clt56ZuUa5xmQl9HzU(SaYDwNMOdKBpg2G1PvTM5QhAU2NfdLlxbUCVXKzeJ4CvUl9bI8(xlax6l4YxU3hTGn8ku0QHWSaOqpgHxoQLhWSaOG9zXqbUcC5ET8aMN(jlU8PG3bE)RfGl9HjE1uilieVcfTAOiV)1cWL(cU8jBWLpHiBuTmgrE)RfGl9frB7xYCYSYDPpqe2tHPzfqwgg9tahkmsykdlk3f8uGo6lea7wWRqrRgko3Ea4qszmmm6NaouyKEIWAzmIZThaoKugJLjCWPwgJ4qGeWB4pwMquYSYDPpqe2tHPzfqpAbBdbsv1yWugwQLXiIsQpxB4rXY0ty5OrdFPikP(mimuFU)pXRqrRgk6YNcEh49VwaU0hUQLXiIsQpxB4rri9v5apvUl4PaD0xia2TyZKzL7sFGiSNctZkGE0c2gg9tahkmsykdlk3f8uGo6lea7wWRqrRgkoRq0axbEyy0pbCOWi9SwgJiOCbgL7feQgcaK7najffRyz6zTmgrq5cmk3liuneai3Baskkwri9v5ayNRap4YNsMvUl9bIWEkmnRa6rlyBclyxnkWXugwQLXickxGr5EbHQHaa5EdqsrXkwMEwlJreuUaJY9ccvdbaY9gGKIIvesFvoa25kWdU8PKzL7sFGiSNctZkGE0c2MWc2vJcCmLHLAzmIdbsaVH)yzkzw5U0hic7PW0ScOhTGTjSGD1OahtzyPwgJ4C7bGdjLXyzkzgX5IGaOC7JYLjfiLlUnkWZLuObRCLlxeOgbNRmYfRUKlAFyWZDwXt5sIptWCrqj1L7nxeKPCByUiOTNlshskJ5If55QhAUK4Ze0AZfHkIYDwXt5(BiLRpRxUU9ox1ajfflmZfHveL7SINYLjAiBboubiWPyaKltwGyLlKuuSY17ClacZCByUiKJOCrskuU3Czqx4Z5kGCvUl4PyUwZ(WGNlANRplGCTplgk3zfIMlxbUCV5YKg9tahkmsGCByU2NPlxKLlxMGY9IbqU42qaGCV5kGCHKIIvmzw5U0hic7PW0ScOhTGTHaPq1OahZcGc9yeE5OwEaZcGc2Nfdf4kWL71YdykdlmfVcfTAO4qGuOAuGhM62i37ZAzmIGYfyuUxqOAiaqU3aKuuSIOT97PYDbpfOJ(cbWfEfkA1qXzfIg4kWddJ(jGdfgPNmDiqc4k0jyu5UGNEIqMwlJrCMuxU3qzkwMEY0AzmIZThaoKugJLPNmDcs4d9yeE5OXHaPq1Oa)jcvUl9fhcKcvJc8iFwHVea7wSjo4Gqxn05r1q2cCOcqGtbHrbI1tE3g02(frH6BFGqfsQphHKIIfIWbhaPq5EdEx4ZrL7cEcrikzgX5IGaOCzsbs5IBJc8CjXNjyUOfOCV5Q5YKcKQQXGnemwWUAuGNlxbEU2NPlxeusD5EZfbzkxbKRYDbpLBdZfTaL7nxYwIxCkx7IpNlssHY9Mld6cFoMmRCx6deH9uyAwb0JwW2qGuOAuGJzbqHEmcVCulpGzbqb7ZIHcCf4Y9A5bmLHfMIxHIwnuCiqkunkWdtDBK79jthcKaUcDcgvUl4PN1YyebLlWOCVGq1qaGCVbiPOyfrB73teIqeQCx6loeivvJjs2s8Il37teQCx6loeivvJjs2s8Itbi9v5a4YkJwpo4Wuy5OrdFP4qGeWB4hr4GJYDPV4ewWUAuGhjBjEXL79jcvUl9fNWc2vJc8izlXlofG0xLdGlRmA94GdtHLJgn8LIdbsaVHFeHON1YyeNj1L7nuMIqs5oIWbhecifk3BW7cFoQCxWtpryTmgXzsD5EdLPiKuU)KPk3L(IaEd5ZrYwIxC5EXbhMwlJrCU9aWHKYyesk3FY0AzmIZK6Y9gktriPC)PYDPViG3q(CKSL4fxU3NmDU9aWHKYyamrgdiixyyK3zhricrjZk3L(arypfMMva9OfSXvJjOCx6lyeGJ5PFYIYDbpfC1qNdsMvUl9bIWEkmnRa6rlyBclyxnkWXugwQLXioHfS5gf8Jqs5(tUc8GlFcx1YyeNWc2CJc(ri9v5ap5kWdU8jCvlJrewok0JWuBNGri9v5apritHLJgn8LIGYfyuUxqOAiaqUxCWPwgJ4ewWMBuWpcPVkhaxk3L(Idbsv1yICf4bx(0JCf4bx(KnQwgJ4ewWMBuWpcjL7ikzw5U0hic7PW0ScOhTGTjSGD1OahtzyPwgJ4C7bGdjLXyz6jGuOCVbVl85OYDbp9u5UGNc0rFHa4cVcfTAO4C7bGdjLXWWOFc4qHrkzw5U0hic7PW0ScOhTGTP5MoX2WWOFcGPmSWu8ku0QHItZnDITHPUnY9(SwgJ4mPUCVHYuSm9KP1YyeNBpaCiPmgltprOYDbpfqBpkVN4eUSjo4OCxWtb6OVqaSBbVcfTAO4ScrdCf4HHr)eWHcJeo4OCxWtb6OVqaSBbVcfTAO4C7bGdjLXWWOFc4qHrcrjZk3L(arypfMMva9OfSb4nKpJPmSaifk3BW7cFoQCxWtjZk3L(arypfMMva9OfSHc13(aHkKuFgtzyr5UGNc0rFHay3MjZk3L(arypfMMva9OfSPqUEuGSDY0aPpmLHfL7cEkqh9fcGDl4vOOvdfvixpkq2ozAG03ZVEACI7y3cEfkA1qrfY1JcKTtMgi9f(6PpDf(sE0U4ZY9GvMmJ4CzcfFox66Y7CUUcFjhGzUINRaYvZ9vLlxVZLRapxM0OFc4qHrkxfK7qmgcMRCaNu0C7rUmPaPQAmXKzL7sFGiSNctZkGE0c2gg9tahkmsykdlk3f8uGo6lea7wWRqrRgkoRq0axbEyy0pbCOWiLmRCx6deH9uyAwb0JwW2qGuvnMK5KzL7sFGiW1dvHOby7Ql9zzy0pbCOWiHPmSOCxWtb6OVqaSBbVcfTAO4C7bGdjLXWWOFc4qHr6jcRLXio3Ea4qszmwMWbNAzmIdbsaVH)yzcrjZk3L(arGRhQcrdW2vx67rlyBiqQQgdMYWsTmgrus95AdpkwMEclhnA4lfrj1NbHH6Z9)jEfkA1qrx(uW7aV)1cWL(WvTmgrus95AdpkcPVkh4PYDbpfOJ(cbWUfBMmRCx6debUEOkenaBxDPVhTGTjSGD1OahtzyPwgJ4qGeWB4pwMsMvUl9bIaxpufIgGTRU03JwW2ewWUAuGJPmSulJrCU9aWHKYySm9SwgJ4C7bGdjLXiK(QCaCPCx6loeivvJjs2s8Itbx(uYSYDPpqe46HQq0aSD1L(E0c2MWc2vJcCmLHLAzmIZThaoKugJLPNiCcs4dVC04dXHaPQAm4GZqGeWvOtWOYDbpHdok3L(Ityb7QrbEuUWWiVZoIsMrCUmaIvUEN7l55IKjiUZDc2CqUYbeukxeOgbN70SciqUnmxR2)Ab4sF5onRacKR9z6YDQbaPAOyYSYDPpqe46HQq0aSD1L(E0c2gg9tahkmsykdlk3f8uGo6lea7wWRqrRgkoRq0axbEyy0pbCOWi9SwgJiOCbgL7feQgcaK7najffRyz6jc5DBqB7xewok0JWuBNGri9v5apQCx6lclhf6ryQTtWizlXlofC5tpYvGhC5tyVwgJiOCbgL7feQgcaK7najffRiK(QCaCWHPUAOZJWYrHEeMA7eerpXRqrRgk6YNcEh49VwaU03JCf4bx(e2RLXickxGr5EbHQHaa5EdqsrXkcPVkhizw5U0hicC9qviAa2U6sFpAbBtyb7QrboMYWsTmgX52dahskJXY0taPq5EdEx4ZrL7cEkzw5U0hicC9qviAa2U6sFpAbBtyb7QrboMYWsTmgXjSGn3OGFesk3FYvGhC5t4QwgJ4ewWMBuWpcPVkh4jczkSC0OHVueuUaJY9ccvdbaY9Ido1YyeNWc2CJc(ri9v5a4s5U0xCiqQQgtKRap4YNEKRap4YNSr1YyeNWc2CJc(riPChrjZioxRzbk3BU(mLlW1dvHO5cBxDPpmZTpdw5wauUmPaPCXTrboix7Z0LRptyLRcPCV2ZTsY9M7u3gcn3rdZfbQrW52WCTA)RfGl9fZfbbq5YKcKYf3gf45sIptWCrlq5EZvZLjfivvJbBiySGD1OapxUc8CTptxUiOK6Y9MlcYuUcixL7cEk3gMlAbk3BUKTeV4uU2fFoxKKcL7nxg0f(Cmzw5U0hicC9qviAa2U6sFpAbBdbsHQrboMfaf6Xi8YrT8aMfafSplgkWvGl3RLhWugwy6qGeWvOtWOYDbp9KP4vOOvdfhcKcvJc8Wu3g5EFwlJreuUaJY9ccvdbaY9gGKIIveTTFpricrOYDPV4qGuvnMizlXlUCVprOYDPV4qGuvnMizlXlofG0xLdGlRmA94GdtHLJgn8LIdbsaVHFeHdok3L(Ityb7QrbEKSL4fxU3Niu5U0xCclyxnkWJKTeV4uasFvoaUSYO1JdomfwoA0Wxkoeib8g(reIEwlJrCMuxU3qzkcjL7ichCqiGuOCVbVl85OYDbp9eH1YyeNj1L7nuMIqs5(tMQCx6lc4nKphjBjEXL7fhCyATmgX52dahskJriPC)jtRLXiotQl3BOmfHKY9Nk3L(IaEd5ZrYwIxC5EFY052dahskJbWezmGGCHHrENDeHieLmRCx6debUEOkenaBxDPVhTGTjSGD1OahtzyPwgJ4C7bGdjLXyz6PYDbpfOJ(cbWfEfkA1qX52dahskJHHr)eWHcJuYSYDPpqe46HQq0aSD1L(E0c2MMB6eBddJ(jaMYWctXRqrRgkon30j2gM62i37teYuxn05XbS)bFMckyMa4GJYDbpfOJ(cbW(di6jcvUl4PaA7r59eNWLnXbhL7cEkqh9fcGDl4vOOvdfNviAGRapmm6NaouyKWbhL7cEkqh9fcGDl4vOOvdfNBpaCiPmggg9tahkmsikzw5U0hicC9qviAa2U6sFpAbBC1yck3L(cgb4yE6NSOCxWtbxn05GKzL7sFGiW1dvHOby7Ql99OfSHc13(aHkKuFgtzyr5UGNc0rFHay)HKzL7sFGiW1dvHOby7Ql99OfSb4nKpJPmSaifk3BW7cFoQCxWtjZk3L(arGRhQcrdW2vx67rlytHC9Oaz7KPbsFykdlk3f8uGo6lea7wWRqrRgkQqUEuGSDY0aPVNF904e3XUf8ku0QHIkKRhfiBNmnq6l81tF6k8L8ODXNL7bRmzgX5Yek(CU01L35CDf(soaZCfpxbKRM7RkxUENlxbEUmPr)eWHcJuUki3Hymemx5aoPO52JCzsbsv1yIjZk3L(arGRhQcrdW2vx67rlyBy0pbCOWiHPmSOCxWtb6OVqaSBbVcfTAO4ScrdCf4HHr)eWHcJuYSYDPpqe46HQq0aSD1L(E0c2gcKQQXWIemrCwgAJHXyDwNLf]] )
end
