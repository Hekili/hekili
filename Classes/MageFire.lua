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


    spec:RegisterPack( "Fire", 20210829, [[devXleqiuKEeeQlrjfAtQI(euKrbbDkiKvrPiELQqZckClkPQDj0VGszyus0XufSmkfEguu10qrGRrPO2gLuW3OKImoOOKZrPi16OKkZdQK7rj2huQ(heqvhefHwiuPEiLKMiLuYfPKIAJOi6JuksgjeiDskPuRef1lHIkzMqaUjeqzNOG(juuQHcbQLcbKNcrtff4QqGyRqrfFffbnwkjSxu6VcgSshM0IL0Jr1KH0Lr2ScFwvA0kQttSAOOs9AuOztXTvv7wLFl1WvKJdfflh0ZbMovxxITdv9DkvJNsPZdLSEiGkZhQy)IM9bwgWIevDILH2WkTXdwjMLnSPJpynyZ2aZBnXI0XAIyroPCg1xIf5PFIfjtkqIf5KILPvuwgWIe0fiNyro7(eW6Wg2EfFUuJ8(JnG8lg1L(4qD4ydiFo2yrwlIXT2hBLfjQ6eldTHvAJhSsmlBythFWAWMTbM3MzrQfFUHSirkFRYICwqrPJTYIeLaCwKmPaPCrGPVuY8S7taRdBy7v85snY7p2aYVyux6Jd1HJnG85ylzMjwElapxBGzHrU2WkTXdjZjZwDwVxcyDjZwFUiiak3H8o7bi9v5a5cvFMG56Z6LRRWxYJU8PG3buHYD0WCnkWTEaX7dnxTkgXXk3cqFjqmz26Zfb0nGUC5kWZfsyMIaPpDoi3rdZ1Q9VwaU0xUiuIueJCr7dtEUZTbnxXZD0WC1ChqcmNlcmYPgMlxboIIjZwFUwZNwnuUahkCpx(mXzuU3C7lxn3bzp3rdzeKRC56ZuUmremcixVZfsOfoLR9gYOPv0yYS1NltefZDb45Q5IGXc2vJc8CPZHyLRpREUOnbY9Ap3FJsMCTtgtUYz9V6NYfHa5NRtaNqZv9CVoxG8EYq4655ATqWiZv(tk3rumz26Z1Q9HNGEUQXKBTmgrRicjL75sNdfcKR35wlJr0kILjmYvVCvZVbEUYbK3tgcxppxRfcgzUVQC5kxUa5dIjZwFUiiak3zfIYBucnx8ku0QHa56DUqcTWPCTkcgbjx7nKrtROrwKgb4awgWIK3)Ab4sFbE3g02(byzaldFGLbSivUl9XICQDPpwK0PvdHYIBwNLH2GLbSivUl9XISA6gnmkqSyrsNwneklUzDwgI5zzals60QHqzXnlsouCckklYAzmI8(xlax6lwMyrQCx6JfzLGacYOCVSoldzcyzalsL7sFSihcKQMUrzrsNwneklUzDwgAZSmGfPYDPpwK6XjGdvtGRgdls60QHqzXnRZYqRbwgWIKoTAiuwCZIKdfNGIYIewoA0Wxk60FQHQjyxHtr60QHqZ9zU1YyejBN1cWL(ILjwKk3L(yr6YNc2v4eRZYqRjwgWIKoTAiuwCZIu5U0hlYxJIkQ3qqOQOVelsAmiUho9tSiFnkQOEdbHQI(sSoldXSyzals60QHqzXnlYt)els5aCyX1QHcyMIEE5hqj8cNyrQCx6JfPCaoS4A1qbmtrpV8dOeEHtSoldTPzzals60QHqzXnlYt)elYHr)uOhHQ6UHyrQCx6Jf5WOFk0JqvD3qSoldFWkzzals60QHqzXnlYt)els7kJ0rqqya7dLfPYDPpwK2vgPJGGWa2hkRZYWhEGLbSiPtRgcLf3Sip9tSiLd4Wc3BiiGk4LJcvYyyrQCx6JfPCahw4EdbbubVCuOsgdRZYWhSbldyrsNwneklUzrE6Nyrckx10nAq)KpJfWzrQCx6JfjOCvt3Ob9t(mwaN1zz4dyEwgWIu5U0hlYcGcItFals60QHqzXnRZ6SirPHwmoldyz4dSmGfjDA1qOS4MfjhkobfLfjtZfwoA0WxkIkaUmzKtHyf49)RhAKoTAiuwKk3L(yrY7Y5eemrgdRZYqBWYawK0PvdHYIBwKk3L(yrcMLHl3ByQTtqwKOeGdLjx6JfjMJcfTAOC9z1ZLaU8vNa5AFM8zcMlYzz4Y9MlcUTtWCTlgtUvk3cGqZTsJgs5A1(xlax6lxbKlKuuSISi5qXjOOSiRLXiY7FTaCPViAB)Y9zUk3L(IdbsHQrbEKpRWxcKlUSK7d5(mxMMlcZTwgJOCdcEQjWvaxrPyzk3N5wlJrCU9aWHKYyesk3Zfr5(mx8ku0QHIGzz4Y9gMA7emuPrdPaV)1cWL(yDwgI5zzals60QHqzXnlsouCckklYAzmI8(xlax6lI22VCFMlcZfVcfTAOOlFk4DG3)Ab4sF5I9CvUl9f4DBqB7xUwFU2CUiIfPYDPpwKqfv0ZdGjfYiRZYqMawgWIKoTAiuwCZIKdfNGIYISwgJiV)1cWL(IOT9l3N5wlJrewok0JWuBNGr02(L7ZCXRqrRgk6YNcEh49VwaU0xU4kx8ku0QHI8(xlax6lmbjUc8GlFk3hZLSL4fNcU8PCFmxeMBTmgrus95AdpkIwGQl9LR1NBTmgrE)RfGl9frlq1L(Yfr5AtYfwoA0WxkIsQpdcd1N7FKoTAiuwKk3L(yrIsQpxB4rSoldTzwgWIKoTAiuwCZIKdfNGIYIeVcfTAOOlFk4DG3)Ab4sF5IRCXRqrRgkY7FTaCPVWeK4kWdU8PCFmxYwIxCk4YNY9zU1Yye59VwaU0xeTTFSivUl9XI8lqydbHEe8g(PZzDwgAnWYawK0PvdHYIBwKfafSplgkWvGl3lldFGfjkb4qzYL(yrYKnmxmh68zSGyKBbq5Q5YKcKYf3gf45YNv4lLlAbk3BUiWeiSHGC7rUmOHF68C5kWZ17Cv8TGMlxNMK7nx(ScFjqKfPYDPpwKdbsHQrbolsouCckklsL7sFXVaHnee6rWB4Nops2s8Il3BUpZDumMaK4Zk8LcU8PCT(CvUl9f)ce2qqOhbVHF68izlXlofG0xLdKlUYLji3N5Y0CNBpaCiPmgatKXacYfgg5D2Z9zUmn3AzmIZThaoKugJLjwNLHwtSmGfjDA1qOS4MfPYDPpwKVgfvuVHGqvrFjwKCO4euuwK4vOOvdfD5tbVd8(xlax6lxSNRYDPVaVBdAB)Y16Z1MzrsJbX9WPFIf5Rrrf1Biiuv0xI1zziMfldyrsNwneklUzrQCx6Jfj9NWcsQj0q0tpoXIKdfNGIYIeVcfTAOOlFk4DG3)Ab4sF5Ill5IxHIwnuK(tybj1eAi6PhNcOKrXk3N5IxHIwnu0Lpf8oW7FTaCPVCXEU4vOOvdfP)ewqsnHgIE6XPakzuSY16Z1MzrE6Nyrs)jSGKAcne90JtSoldTPzzals60QHqzXnlsL7sFSibZkABNqdnSg6rWB4NoNfjhkobfLfjcZfVcfTAOOlFk4DG3)Ab4sF5Ill5IxHIwnuK3)Ab4sFHjiXvGhC5t5(yU2ixCWj3H8o7bi9v5a5IRCXRqrRgk6YNcEh49VwaU0xUik3N5wlJrK3)Ab4sFr02(XI80pXIemROTDcn0WAOhbVHF6CwNLHpyLSmGfjDA1qOS4MfPYDPpwKVgSMMd9iOaG8fJ6sFSi5qXjOOSiXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrE6Nyr(AWAAo0JGcaYxmQl9X6Sm8Hhyzals60QHqzXnlsL7sFSi)kxRqkaMjYd)cq4Si5qXjOOSiXRqrRgk6YNcEh49VwaU0xU4YsU2mlYt)elYVY1kKcGzI8WVaeoRZYWhSbldyrsNwneklUzrIsaouMCPpwKw7rUfGCV5Q5cCc2cAU9z9faLR40hJCvJDflqUfaLR1csk6qGuUyoeaqMC7Ideuk3EKRv7FTaCPVyUy2(mbTlacJCNGsdfxqGJYTaK7nxRfKu0HaPCXCiaGm5Ax85CTA)RfGl9LBFgSYvg5ATVbbp1KRvvaxrPCfqU0PvdHMREO5Q5wa6lLR9(WKNBLY10ap3gpbZ1NPCrlq1L(YTh56ZuUd5D2J5YGzbKRIIcYvZf8vJjx8QPq56DU(mLlVBdAB)YTh5ATGKIoeiLlMdbaKjx7Z0LlAl3BU(SaYLRgEXOU0xUvIRfaLR45kGClhKudWfEUENRcaLpLRpREUINRDXyYTs5waeAUteCqC3GvU9LlVBdAB)ISip9tSirHKIoeifWtaazyrYHItqrzrIxHIwnu0Lpf8oW7FTaCPVCXULCXRqrRgk2xOaOaV49yK7ZCryU1YyeLBqWtnbUc4kkfbUYzmxl5wlJruUbbp1e4kGROu8R2gaUYzmxCWjxMMlVp0I4r5ge8utGRaUIsr60QHqZfhCYfVcfTAOiV)1cWL(c9fkakxCWjx8ku0QHIU8PG3bE)RfGl9Ll2ZvoNGtTrDcnmK3zpaPVkhixRXCZfH5QCx6lW72G22VCFm3hSYCruUiIfPYDPpwKOqsrhcKc4jaGmSoldFaZZYawK0PvdHYIBwKk3L(yrc6IjiVN4eKfjhkobfLfjcZfVcfTAOOlFk4DG3)Ab4sF5IDl5I5TYCTj5IWCXRqrRgk2xOaOaV49yKl2Z1kZfr5Ido5IWCzAUouogjp6pefqe0ftqEpXjyUpZ1HYXi5r)HybOvdL7ZCDOCmsE0FiY72G22ViK(QCGCXbNCzAUouogjp62ikGiOlMG8EItWCFMRdLJrYJUnIfGwnuUpZ1HYXi5r3grE3g02(fH0xLdKlIYfr5(mxeMltZLWmfzAIqJOqsrhcKc4jaGm5Ido5Y72G22VikKu0HaPaEcaitesFvoqUypxBoxeXI80pXIe0ftqEpXjiRZYWhycyzals60QHqzXnlsL7sFSi56XjtOwgdwKCO4euuwKmnxEFOfXJYni4PMaxbCfLI0PvdHM7ZCD5t5IRCT5CXbNCRLXik3GGNAcCfWvukcCLZyUwYTwgJOCdcEQjWvaxrP4xTnaCLZilYAzmcN(jwKGUycY7jU0hlsucWHYKl9XIKbq59LG5ISlMCT2VN4emxsHgSY1U4Z5ATVbbp1KRvvaxrPCByU2NPlxXZ1UcYDcsCf4rwNLHpyZSmGfjDA1qOS4Mfjkb4qzYL(yrATD6dY1Nvpx0o3R9CR0rdXZ1Q9VwaU0xUG5UyqZfZDb45wPClacn3U4abLYTh5A1(xlax6lx1Zf0Fk3PwopYI80pXIuoahwCTAOaMPONx(bucVWjwKCO4euuwKeMPitteA81OOI6neeQk6lL7ZCXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrQCx6JfPCaoS4A1qbmtrpV8dOeEHtSoldFWAGLbSiPtRgcLf3SivUl9XICy0pf6rOQUBiwKCO4euuwKeMPitteA81OOI6neeQk6lL7ZCXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrE6Nyrom6Nc9iuv3neRZYWhSMyzals60QHqzXnlsL7sFSiTRmshbbHbSpuwKCO4euuwKeMPitteA81OOI6neeQk6lL7ZCXRqrRgk6YNcEh49VwaU0xUy3sU4vOOvdf7luauGx8EmyrE6NyrAxzKocccdyFOSoldFaZILbSiPtRgcLf3SivUl9XIuoGdlCVHGaQGxokujJHfjhkobfLfjHzkY0eHgFnkQOEdbHQI(s5(mx8ku0QHIU8PG3bE)RfGl9Ll2TKlEfkA1qX(cfaf4fVhdwKN(jwKYbCyH7neeqf8YrHkzmSoldFWMMLbSiPtRgcLf3SivUl9XIeuUQPB0G(jFglGZIKdfNGIYIKWmfzAIqJVgfvuVHGqvrFPCFMlEfkA1qrx(uW7aV)1cWL(Yf7wYfVcfTAOyFHcGc8I3JblYt)elsq5QMUrd6N8zSaoRZYqByLSmGfjDA1qOS4MfjhkobfLfjEfkA1qrx(uW7aV)1cWL(Yf7wYfVcfTAOyFHcGc8I3JblsL7sFSilakio9bSoldTXdSmGfjDA1qOS4MfPYDPpwKdyd8W14vwKOeGdLjx6JfjccGYLjHnWZLHnEnxVZ1HY7lbZ1Mckadw5AT5c3qrwKCO4euuwKWYrJg(sXxOamyfeUWnuKoTAi0CFMBTmgrE)RfGl9frB7xUpZfH5IxHIwnu0Lpf8oW7FTaCPVCXEUk3L(c8UnOT9lxCWjx8ku0QHIU8PG3bE)RfGl9LlUYfVcfTAOiV)1cWL(ctqIRap4YNY9XCjBjEXPGlFkxeX6Sm0g2GLbSiPtRgcLf3SivUl9XIK3LZjiyImgwKOeGdLjx6JfPnf556ZuUwlbWLjJCkeRCTA))6HMBTmg5wMWi3YziaixE)RfGl9LRaYf09fzrYHItqrzrclhnA4lfrfaxMmYPqSc8()1dnsNwneAUpZL3TbTTFXAzmcOcGltg5uiwbE))6HgHKIIvUpZTwgJiQa4YKrofIvG3)VEObfY1JIOT9l3N5Y0CRLXiIkaUmzKtHyf49)RhASmL7ZCryU4vOOvdfD5tbVd8(xlax6l3hZv5U0xCaBGxBJh5kWdU8PCXEU8UnOT9lwlJravaCzYiNcXkW7)xp0iAbQU0xU4GtU4vOOvdfD5tbVd8(xlax6lxCLRnNlIyDwgAdmpldyrsNwneklUzrYHItqrzrclhnA4lfrfaxMmYPqSc8()1dnsNwneAUpZL3TbTTFXAzmcOcGltg5uiwbE))6HgHKIIvUpZTwgJiQa4YKrofIvG3)VEObfY1JIOT9l3N5Y0CRLXiIkaUmzKtHyf49)RhASmL7ZCryU4vOOvdfD5tbVd8(xlax6l3hZLSL4fNcU8PCFmxL7sFXbSbETnEKRap4YNYf75Y72G22VyTmgbubWLjJCkeRaV)F9qJOfO6sF5Ido5IxHIwnu0Lpf8oW7FTaCPVCXvU2CUpZLP56QHopclhf6ryQTtWiDA1qO5IiwKk3L(yrQqUEuGSDY0aPpwNLH2GjGLbSiPtRgcLf3Si5qXjOOSiHLJgn8LIOcGltg5uiwbE))6HgPtRgcn3N5Y72G22VyTmgbubWLjJCkeRaV)F9qJq6RYbYfx5YvGhC5t5(m3AzmIOcGltg5uiwbE))6HggWg4r02(L7ZCzAU1YyerfaxMmYPqSc8()1dnwMY9zUimx8ku0QHIU8PG3bE)RfGl9L7J5YvGhC5t5I9C5DBqB7xSwgJaQa4YKrofIvG3)VEOr0cuDPVCXbNCXRqrRgk6YNcEh49VwaU0xU4kxBoxeXIu5U0hlYbSbETnoRZYqByZSmGfjDA1qOS4MfjhkobfLfjSC0OHVuevaCzYiNcXkW7)xp0iDA1qO5(mxE3g02(fRLXiGkaUmzKtHyf49)RhAeskkw5(m3AzmIOcGltg5uiwbE))6HggWg4r02(L7ZCzAU1YyerfaxMmYPqSc8()1dnwMY9zUimx8ku0QHIU8PG3bE)RfGl9Ll2ZL3TbTTFXAzmcOcGltg5uiwbE))6Hgrlq1L(YfhCYfVcfTAOOlFk4DG3)Ab4sF5IRCT5CrelsL7sFSihWg4HRXRSoldTH1aldyrsNwneklUzrYHItqrzrIxHIwnu0Lpf8oW7FTaCPVCXLLCTYCXbNCXRqrRgk6YNcEh49VwaU0xU4kx8ku0QHI8(xlax6lmbjUc8GlFk3N5Y72G22ViV)1cWL(Iq6RYbYfx5IxHIwnuK3)Ab4sFHjiXvGhC5tSivUl9XIKRgtq5U0xWiaNfPraE40pXIK3)Ab4sFHPzfqSoldTH1eldyrsNwneklUzrYHItqrzrwlJrewok0JWuBNGr02(L7ZCzAU1YyehcKaEd)riPCp3N5IWCXRqrRgk6YNcEh49VwaU0xUy3sU1YyeHLJc9im12jyeTavx6l3N5IxHIwnu0Lpf8oW7FTaCPVCXEUk3L(IdbsHQrbECumMaK4Zk8LcU8PCXbNCXRqrRgk6YNcEh49VwaU0xUyp3H8o7bi9v5a5IOCFMlcZLP5clhnA4lfbLlWOCVGq1qaGCVr60QHqZfhCYv5UGNc0rFHa5IDl5IxHIwnuCwHObUc8WWOFc4qHrkxCWj3AzmIGYfyuUxqOAiaqU3aKuuSILPCXbNCRLXickxGr5EbHQHaa5EJqs5EUy3sU1YyebLlWOCVGq1qaGCVXVABa4kNXCT(CFixCWj3H8o7bi9v5a5IRCRLXiclhf6ryQTtWiAbQU0xUiIfPYDPpwKWYrHEeMA7eK1zzOnWSyzals60QHqzXnlYEIfjGCwKk3L(yrIxHIwnelsucWHYKl9XIeb3TjxfK7xpSYLjfiLlUnkWb5QGCNAaqQgk3rdZ1Q9VwaU0xmxKLQdvUNBx8C7rU(mL7aQCx6tn5Y7)uF0552JC9zk3R8Rem3EKltkqkxCBuGdY1Nvpx7IXK7PEbQgdw5cj(ScFPCrlq5EZ1NPCTA)RfGl9L70ScOCRexlak3PUnY9MREy5ZY9M7Kc8C9z1Z1Uym5ETN7luppx9YLS1HAUmPaPCXTrbEUOfOCV5A1(xlax6lYIeVAkelsL7sFXHaPq1OapYNv4lbcdOYDPp1K7J5IWCXRqrRgk6YNcEh49VwaU0xUpMRYDPViywgUCVHP2obJJIXeGeAH7sF5AtYfVcfTAOiywgUCVHP2obdvA0qkW7FTaCPVCruUylxE3g02(fhcKcvJc8iAbQU0xUwFUpKlUYL3TbTTFXHaPq1Oap(vBd8zf(sGCFmx8ku0QHInEco1TjmeifQgf4GCXwU8UnOT9loeifQgf4r0cuDPVCT(CryU1Yye59VwaU0xeTavx6lxSLlVBdAB)IdbsHQrbEeTavx6lxeLBUwJ5(qUpZfVcfTAOOlFk4DG3)Ab4sF5IRChY7ShG0xLdKlo4KlSC0OHVueuUaJY9ccvdbaY9gPtRgcn3N5cifk3BW7cFoQCxWt5(mxL7sFXHaPq1Oapokgtas8zf(sbx(uUypxmFU2KCF5OXVAllYcGc9yeE5OSm8bwK4vy40pXICiqkunkWdtDBK7Lfzbqb7ZIHcCf4Y9YYWhyDwgAdBAwgWIKoTAiuwCZIeLaCOm5sFSizcNPl3cqU3CzsJ(jGdfgPCLlxR2)Ab4sFyKlqXt5QGC)6HvU8zf(sGCvqUtnaivdL7OH5A1(xlax6lx7Ip3fpxUonj3BKfPYDPpwKC1yck3L(cgb4Sibou4oldFGfjhkobfLfzTmgry5OqpctTDcglt5(mx8ku0QHIU8PG3bE)RfGl9Ll2Z1kzrAeGho9tSiH9uyAwbeRZYqmVvYYawK0PvdHYIBwKfafSplgkWvGl3lldFGfPYDPpwK4vOOvdXISNyrciNfjhkobfLfjtZfVcfTAO4qGuOAuGhM62i3BUpZ1vdDEewok0JWuBNGr60QHqZ9zU1YyeHLJc9im12jyeTTFSilak0Jr4LJYYWhyrIxnfIfjVBdAB)IWYrHEeMA7emcPVkhixCLRYDPV4qGuOAuGhhfJjaj(ScFPGlFkxRpxL7sFrWSmC5EdtTDcghfJjaj0c3L(Y1MKlcZfVcfTAOiywgUCVHP2obdvA0qkW7FTaCPVCFMlVBdAB)IGzz4Y9gMA7emcPVkhixCLlVBdAB)IWYrHEeMA7emcPVkhixeL7ZC5DBqB7xewok0JWuBNGri9v5a5IRChY7ShG0xLdWIeLaCOm5sFSizIOyUlapxFMYfVcfTAOC9z1ZL3NdBdixMuGuU42Oap3cqFPC9ox6afiLR4GC5Zk8La5Qqkx1a6CN62qO5oAyUiqLJYTh5IGB7emYIeVcdN(jwKdbsHQrbEyQBJCVSoldX8pWYawK0PvdHYIBwKfafSplgkWvGl3lldFGfjhkobfLfjtZfVcfTAO4qGuOAuGhM62i3BUpZfVcfTAOOlFk4DG3)Ab4sF5I9CTYCFMRYDbpfOJ(cbYf7wYfVcfTAO4ScrdCf4HHr)eWHcJuUpZLP5oeibCf6emQCxWt5(mxMMBTmgX52dahskJXYuUpZfH5wlJrCMuxU3qzkwMY9zUk3L(IdJ(jGdfgPizlXlofG0xLdKlUY1kJ2CU4GtU8zf(sGWaQCx6tn5IDl5AJCrelYcGc9yeE5OSm8bwKk3L(yroeifQgf4SirjahktU0hlsMWz6YfbvHOCf4Y9MltA0pLlshkmsyKltkqkxCBuGdYfm3fdAUvk3cGqZ17CFPJGQt5IG2EUiDiPmcYvp0C9oxYwNo0CXTrbobZfbMcCcgzDwgI5TbldyrsNwneklUzrwauW(SyOaxbUCVSm8bwKCO4euuwKdbsaxHobJk3f8uUpZLpRWxcKl2TK7d5(mxMMlEfkA1qXHaPq1Oapm1TrU3CFMlcZLP5QCx6loeivvJjs2s8Il3BUpZLP5QCx6loHfSRgf4r5cdJ8o75(m3AzmIZK6Y9gktXYuU4GtUk3L(Idbsv1yIKTeV4Y9M7ZCzAU1YyeNBpaCiPmglt5Ido5QCx6loHfSRgf4r5cdJ8o75(m3AzmIZK6Y9gktXYuUpZLP5wlJrCU9aWHKYySmLlIyrwauOhJWlhLLHpWIu5U0hlYHaPq1OaNfjkb4qzYL(yrATkq5EZLjfibCf6eeJCzsbs5IBJcCqUkKYTai0CbYxmk0GvUENlAbk3BUwT)1cWL(I5AtrhbvJblmY1NjSYvHuUfaHMR35(shbvNYfbT9Cr6qszeKR9z6YLdfhKRDXyY9Ap3kLRDf4eAU6HMRDXNZf3gf4emxeykWjig56Zew5cM7Ibn3kLlycskAUDXZ17C)QCUkxU(mLlUnkWjyUiWuGtWCRLXiY6SmeZJ5zzals60QHqzXnlYcGc2Nfdf4kWL7LLHpWIeLaCOm5sFSizI4BbnxUonj3BUmPaPCXTrbEU8zf(sGCTplgkx(SEhzK7nxKZYWL7nxeCBNGSivUl9XICiqkunkWzrYHItqrzrQCx6lcMLHl3ByQTtWizlXlUCV5(m3rXycqIpRWxk4YNYfx5QCx6lcMLHl3ByQTtWOlCgdqcTWDPVCFMBTmgX52dahskJr02(L7ZCD5t5I9CFWkzDwgI5zcyzals60QHqzXnlsouCckkls8ku0QHIU8PG3bE)RfGl9Ll2Z1kZ9zU1YyeHLJc9im12jyeTTFSivUl9XIKRgtq5U0xWiaNfPraE40pXIe46HQq0aSD1L(yDwgI5TzwgWIu5U0hlsaVH8zwK0PvdHYIBwN1zrc7PW0SciwgWYWhyzals60QHqzXnlsL7sFSihg9tahkmsSirjahktU0hlsMuo1yWcJC59HNGEUdy)ZvRG2uCkxx(uU6HMlWBiLRpt5cjJ6cEkxx(uUYLlEfkA1qrx(uW7aV)1cWL(I5IGCgHrkxFMYfsap3EKRpt5YvdVyux6dGrU2Nf(CUZ60eD5Aiai3bKWmf6Cdw56DUGjIqZTmLRpt5cKFXOU0hg56Zci3zDAIoqU9yy92uw1ALREO5AFwmuUCf4Y9gzrYHItqrzrQCxWtb6OVqGCXULCXRqrRgko3Ea4qszmmm6NaouyKY9zUim3AzmIZThaoKugJLPCXbNCRLXioeib8g(JLPCreRZYqBWYawK0PvdHYIBwKCO4euuwK1Yyerj1NRn8Oyzk3N5clhnA4lfrj1NbHH6Z9psNwneAUpZfVcfTAOOlFk4DG3)Ab4sF5IRCRLXiIsQpxB4rri9v5a5(mxL7cEkqh9fcKl2TKRnyrQCx6Jf5qGuvngwNLHyEwgWIKoTAiuwCZIKdfNGIYIu5UGNc0rFHa5IDl5IxHIwnuCwHObUc8WWOFc4qHrk3N5wlJreuUaJY9ccvdbaY9gGKIIvSmL7ZCRLXickxGr5EbHQHaa5EdqsrXkcPVkhixSNlxbEWLpXIu5U0hlYHr)eWHcJeRZYqMawgWIKoTAiuwCZIKdfNGIYISwgJiOCbgL7feQgcaK7najffRyzk3N5wlJreuUaJY9ccvdbaY9gGKIIvesFvoqUypxUc8GlFIfPYDPpwKtyb7QrboRZYqBMLbSiPtRgcLf3Si5qXjOOSiRLXioeib8g(JLjwKk3L(yroHfSRgf4SoldTgyzals60QHqzXnlsouCckklYAzmIZThaoKugJLjwKk3L(yroHfSRgf4SoldTMyzals60QHqzXnlYcGc2Nfdf4kWL7LLHpWIKdfNGIYIKP5IxHIwnuCiqkunkWdtDBK7n3N5wlJreuUaJY9ccvdbaY9gGKIIveTTF5(mxL7cEkqh9fcKlUYfVcfTAO4ScrdCf4HHr)eWHcJuUpZLP5oeibCf6emQCxWt5(mxeMltZTwgJ4mPUCVHYuSmL7ZCzAU1YyeNBpaCiPmglt5(mxMM7eKWh6Xi8YrJdbsHQrbEUpZfH5QCx6loeifQgf4r(ScFjqUy3sU2ixCWjxeMRRg68OAiBboubiWPGWOaXksNwneAUpZL3TbTTFruO(2hiuHK6ZriPOyLlIYfhCYfqkuU3G3f(Cu5UGNYfr5IiwKfaf6Xi8Yrzz4dSivUl9XICiqkunkWzrIsaouMCPpwKiiak3(OCzsbs5IBJc8CjfAWkx5YfbQrW5kJCXQl5I2hM8CNv8uUK4ZemxeusD5EZfbzk3gMlcA75I0HKYyUyrEU6HMlj(mbTUCrOIOCNv8uU)gs56Z6LRBVZvnqsrXcJCryfr5oR4PCzIgYwGdvacCkMa5YKfiw5cjffRC9o3cGWi3gMlc5ikxKKcL7nxg0f(CUcixL7cEkMR1Qpm55I256Zcix7ZIHYDwHO5YvGl3BUmPr)eWHcJei3gMR9z6Yfz5YfZLCVycKlUneai3BUcixiPOyfzDwgIzXYawK0PvdHYIBwKfafSplgkWvGl3lldFGfjhkobfLfjtZfVcfTAO4qGuOAuGhM62i3BUpZLP5oeibCf6emQCxWt5(m3AzmIGYfyuUxqOAiaqU3aKuuSIOT9l3N5IWCryUimxL7sFXHaPQAmrYwIxC5EZ9zUimxL7sFXHaPQAmrYwIxCkaPVkhixCLRvgT5CXbNCzAUWYrJg(sXHajG3WFKoTAi0CruU4GtUk3L(Ityb7QrbEKSL4fxU3CFMlcZv5U0xCclyxnkWJKTeV4uasFvoqU4kxRmAZ5Ido5Y0CHLJgn8LIdbsaVH)iDA1qO5IOCruUpZTwgJ4mPUCVHYuesk3Zfr5Ido5IWCbKcL7n4DHphvUl4PCFMlcZTwgJ4mPUCVHYuesk3Z9zUmnxL7sFraVH85izlXlUCV5Ido5Y0CRLXio3Ea4qszmcjL75(mxMMBTmgXzsD5EdLPiKuUN7ZCvUl9fb8gYNJKTeV4Y9M7ZCzAUZThaoKugdGjYyab5cdJ8o75IOCruUiIfzbqHEmcVCuwg(alsL7sFSihcKcvJcCwKOeGdLjx6JfjccGYLjfiLlUnkWZLeFMG5IwGY9MRMltkqQQgd2qWyb7QrbEUCf45AFMUCrqj1L7nxeKPCfqUk3f8uUnmx0cuU3CjBjEXPCTl(CUijfk3BUmOl85iRZYqBAwgWIKoTAiuwCZIu5U0hlsUAmbL7sFbJaCwKgb4Ht)elsL7cEk4QHohW6Sm8bRKLbSiPtRgcLf3Si5qXjOOSiRLXioHfS5gf8Jqs5EUpZLRap4YNYfx5wlJrCclyZnk4hH0xLdK7ZC5kWdU8PCXvU1YyeHLJc9im12jyesFvoqUpZfH5Y0CHLJgn8LIGYfyuUxqOAiaqU3iDA1qO5Ido5wlJrCclyZnk4hH0xLdKlUYv5U0xCiqQQgtKRap4YNY9XC5kWdU8PCTj5wlJrCclyZnk4hHKY9CrelsL7sFSiNWc2vJcCwNLHp8aldyrsNwneklUzrYHItqrzrwlJrCU9aWHKYySmL7ZCbKcL7n4DHphvUl4PCFMRYDbpfOJ(cbYfx5IxHIwnuCU9aWHKYyyy0pbCOWiXIu5U0hlYjSGD1OaN1zz4d2GLbSiPtRgcLf3Si5qXjOOSizAU4vOOvdfNMB6eBdtDBK7n3N5wlJrCMuxU3qzkwMY9zUmn3AzmIZThaoKugJLPCFMlcZv5UGNcOThL3tCkxCLRnYfhCYv5UGNc0rFHa5IDl5IxHIwnuCwHObUc8WWOFc4qHrkxCWjxL7cEkqh9fcKl2TKlEfkA1qX52dahskJHHr)eWHcJuUiIfPYDPpwKtZnDITHHr)eG1zz4dyEwgWIKoTAiuwCZIKdfNGIYIeqkuU3G3f(Cu5UGNyrQCx6JfjG3q(mRZYWhycyzals60QHqzXnlsouCckklsL7cEkqh9fcKl2Z1gSivUl9XIefQV9bcviP(mRZYWhSzwgWIKoTAiuwCZIKdfNGIYIu5UGNc0rFHa5IDl5IxHIwnuuHC9Oaz7KPbsF5(m3VEACI75IDl5IxHIwnuuHC9Oaz7KPbsFHVEAUpZ1v4l5r7Ipl3dwjlsL7sFSivixpkq2ozAG0hRZYWhSgyzals60QHqzXnlsL7sFSihg9tahkmsSirjahktU0hlsMqXNZLUU8oNRRWxYbyKR45kGC1CFv5Y17C5kWZLjn6NaouyKYvb5oeJHG5khWjfn3EKltkqQQgtKfjhkobfLfPYDbpfOJ(cbYf7wYfVcfTAO4ScrdCf4HHr)eWHcJeRZYWhSMyzalsL7sFSihcKQQXWIKoTAiuwCZ6SolsE)RfGl9fMMvaXYawg(aldyrsNwneklUzrYHItqrzrwlJrK3)Ab4sFr02(XIu5U0hlsJ8o7GaM7c67NoN1zzOnyzals60QHqzXnlsL7sFSiR6BOhbhkCgbSirjahktU0hlsMikkixFMYfTavx6l3EKRpt5ISC5I5sUxmbYf3gcaK7nxR2)Ab4sF56DU(mLlDO52JC9zkxEbcPZZ1Q9VwaU0xUYixFMYLRapx7DXGMlV)tgYPCrlq5EZ1NfqUwT)1cWL(ISi5qXjOOSiRLXiY7FTaCPViAB)yDwgI5zzals60QHqzXnlsouCckklsL7cEkqh9fcKl2Z9HCFMBTmgrE)RfGl9frB7hlsL7sFSincE5Ed1(xzDwgYeWYawK0PvdHYIBwKfafSplgkWvGl3lldFGfjhkobfLfjtZL3hAr8OCdcEQjWvaxrPiDA1qO5(mx(ScFjqUy3sUpK7ZCRLXiY7FTaCPVyzk3N5Y0CRLXioeib8g(JLPCFMltZTwgJ4C7bGdjLXyzk3N5o3Ea4qszmaMiJbeKlmmY7SN7J5wlJrCMuxU3qzkwMYfx5AdwKfaf6Xi8Yrzz4dSivUl9XICiqkunkWzrIsaouMCPpwKmHIp3fpxR9ni4PMCTQc4kkHrUyUlap3cGYLjfiLlUnkWb5AFMUC9zcRCT3hM8C)LJpNlhkoix9qZ1(mD5YKcKaEd)5kGCrB7xK1zzOnZYawK0PvdHYIBwKfafSplgkWvGl3lldFGfjhkobfLfjVp0I4r5ge8utGRaUIs5(mx(ScFjqUy3sUpK7ZCryU4vOOvdfjBNiUtOHHaPq1OahKl2TKlEfkA1qXJiucnmeifQgf4GCXbNCRLXiY7FTaCPViK(QCGCXvUVC04xTnxCWjx8ku0QHIKToDOeAG3)Ab4sFbi9v5a5Ill5wlJruUbbp1e4kGROueTavx6lxCWj3AzmIYni4PMaxbCfLIax5mMlUY1g5Ido5wlJruUbbp1e4kGROuesFvoqU4k3xoA8R2Mlo4KlVBdAB)IGzz4Y9gMA7emcjffRCFMRYDbpfOJ(cbYf7wYfVcfTAOiV)1cWL(cGzz4Y9gMA7em3N5YB80PNhp5D2ddLYfr5(m3AzmI8(xlax6lwMY9zUimxMMBTmgXHajG3WFesk3ZfhCYTwgJOCdcEQjWvaxrPiK(QCGCXvUwz0MZfr5(mxMMBTmgX52dahskJriPCp3N5o3Ea4qszmaMiJbeKlmmY7SN7J5wlJrCMuxU3qzkcjL75IRCTblYcGc9yeE5OSm8bwKk3L(yroeifQgf4SirjahktU0hlsMqXNZ1AFdcEQjxRQaUIsyKltkqkxCBuGNBbq5cM7Ibn3kLRIIkU0NAmyLlVpGdv5i0CbDU(S65kEUci3R9CRuUfaHMB5meaKR1(ge8utUwvbCfLYva5Q1U456DUKTtcKYTH56ZeKYvHuU)gs56Z6LlDD5DoxMuGuU42OahKR35s260HMR1(ge8utUwvbCfLY17C9zkx6qZTh5A1(xlax6lY6Sm0AGLbSiPtRgcLf3SivUl9XIKRgtq5U0xWiaNfPraE40pXIu5UGNcUAOZbSoldTMyzals60QHqzXnlYcGc2Nfdf4kWL7LLHpWIKdfNGIYICU9aWHKYyamrgdiixyyK3zpxl5AL5(m3AzmI8(xlax6lI22VCFMlEfkA1qrx(uW7aV)1cWL(YfxwY1kZ9zUimxMMlSC0OHVuevaCzYiNcXkW7)xp0iDA1qO5Ido5wlJrevaCzYiNcXkW7)xp0yzkxCWj3AzmIOcGltg5uiwbE))6HggWg4XYuUpZ1vdDEewok0JWuBNGr60QHqZ9zU8UnOT9lwlJravaCzYiNcXkW7)xp0iKuuSYfr5(mxeMltZfwoA0Wxk(cfGbRGWfUHI0PvdHMlo4KlkvlJr8fkadwbHlCdflt5IOCFMlcZLP5YB80PNhpIdBtdrZfhCYL3TbTTFrus95AdpkcPVkhixCWj3AzmIOK6Z1gEuSmLlIY9zUimxMMlVXtNEEepD(mwWCXbNC5DBqB7x8lqydbHEe8g(PZJq6RYbYfr5(mxeMRYDPV4NCQHr5cdJ8o75(mxL7sFXp5udJYfgg5D2dq6RYbYfxwYfVcfTAOiV)1cWL(cCf4bi9v5a5Ido5QCx6lc4nKphjBjEXL7n3N5QCx6lc4nKphjBjEXPaK(QCGCXvU4vOOvdf59VwaU0xGRapaPVkhixCWjxL7sFXHaPQAmrYwIxC5EZ9zUk3L(Idbsv1yIKTeV4uasFvoqU4kx8ku0QHI8(xlax6lWvGhG0xLdKlo4KRYDPV4ewWUAuGhjBjEXL7n3N5QCx6loHfSRgf4rYwIxCkaPVkhixCLlEfkA1qrE)RfGl9f4kWdq6RYbYfhCYv5U0xCy0pbCOWifjBjEXL7n3N5QCx6lom6NaouyKIKTeV4uasFvoqU4kx8ku0QHI8(xlax6lWvGhG0xLdKlIyrwauOhJWlhLLHpWIu5U0hlsE)RfGl9X6SmeZILbSiPtRgcLf3SirjahktU0hlsmBFMG5Y72G22pqU(S65cM7Ibn3kLBbqO5Ax85CTA)RfGl9LlyUlg0C7ZGvUvk3cGqZ1U4Z5QxUk3lQjxR2)Ab4sF5YvGNREO5ETNRDXNZvZfz5YfZLCVycKlUneai3BUtWMhzrQCx6JfjxnMGYDPVGraolsouCckklYAzmI8(xlax6lcPVkhixSNlMvU4GtU8UnOT9lY7FTaCPViK(QCGCXvU2mlsJa8WPFIfjV)1cWL(c8UnOT9dW6Sm0MMLbSiPtRgcLf3Si5qXjOOSiryU1YyeNBpaCiPmglt5(mxL7cEkqh9fcKl2TKlEfkA1qrE)RfGl9fgg9tahkms5IOCXbNCryU1YyehcKaEd)XYuUpZv5UGNc0rFHa5IDl5IxHIwnuK3)Ab4sFHHr)eWHcJuUwFUWYrJg(sXHajG3WFKoTAi0CrelsL7sFSihg9tahkmsSoldFWkzzals60QHqzXnlsL7sFSiHkQONhatkKrwKOeGdLjx6JfjcKIk655ICsHmMlyUlg0CRuUfaHMRDXNZvZfbT9Cr6qszmxiPOyLR35wauUY)tOI6KbRC1HtWC9zkxUc8ChYjGzceZLbZcix7IXK7PEbQgdw5cip3YuUAUiOTNlshskJ5cMOZZD0WC9zk3HCQjxGRCgZTh5IaPOIEEUiNuiJrwKCO4euuwK1Yye59VwaU0xSmL7ZCTrU2KCRLXio3Ea4qszmcjL75(yU1YyeNj1L7nuMIqs5EUpM7C7bGdjLXayImgqqUWWiVZEUwY1gSoldF4bwgWIKoTAiuwCZIKdfNGIYISwgJ4qGeWB4pwMyrQCx6Jf5ewWUAuGZ6Sm8bBWYawK0PvdHYIBwKCO4euuwK1YyeNBpaCiPmglt5(m3AzmI8(xlax6lwMyrQCx6Jf5ewWUAuGZ6Sm8bmpldyrsNwneklUzrYHItqrzrobj8HxoA8HiG3q(CUpZTwgJ4mPUCVHYuSmL7ZCvUl4PaD0xiqU4kx8ku0QHI8(xlax6lmm6NaouyKY9zU1Yye59VwaU0xSmXIu5U0hlYjSGD1OaN1zz4dmbSmGfjDA1qOS4MfjhkobfLfzTmgrq5cmk3liuneai3BaskkwXYuUpZTwgJiSCuOhHP2obJq6RYbYfx5QCx6loHfSRgf4rUc8GlFk3N5wlJreuUaJY9ccvdbaY9gGKIIvesFvoqUypxL7sFXjSGD1OapYvGhC5t5(yUKTeV4uWLpXIu5U0hlsy5OqpctTDcY6Sm8bBMLbSiPtRgcLf3SivUl9XIemldxU3WuBNGSirjahktU0hlseeGCV5ICwgUCV5IGB7emx0cuU3CTA)RfGl9LR35cjG3qkxMuGuU42Oapx9qZfbp30j2MltA0pLlFwHVeixUE5wPCR0rdHlQbJCRfp3cOOgdw52NbRC7lxMyBnhzrYHItqrzrwlJrK3)Ab4sFXYuUpZLP5QCx6loeifQgf4r(ScFjqUpZv5UGNc0rFHa5IDl5IxHIwnuK3)Ab4sFbWSmC5EdtTDcM7ZCvUl9fNMB6eBddJ(jqKpRWxcKlUYv5U0xCAUPtSnmm6NaXVABGpRWxcW6Sm8bRbwgWIKoTAiuwCZIKdfNGIYIu5UGNc0rFHa5IDl5IxHIwnuK3)Ab4sFHHr)eWHcJuUpZTwgJiOCbgL7feQgcaK7najffRyzk3N5wlJreuUaJY9ccvdbaY9gGKIIvesFvoqUypxUc8GlFk3N5IWCzAU8(qlIhLBqWtnbUc4kkfPtRgcnxCWj3AzmIYni4PMaxbCfLIq6RYbYf75s2s8Itbx(uU4GtU1YyeNj1L7nuMIqs5EUpM7C7bGdjLXayImgqqUWWiVZEU4kxBKlIyrQCx6Jf5WOFc4qHrI1zz4dwtSmGfjDA1qOS4MfjhkobfLfzTmgrq5cmk3liuneai3BaskkwXYuUpZTwgJiOCbgL7feQgcaK7najffRiK(QCGCXEUCf4bx(uUpZfH5Y0C59Hwepk3GGNAcCfWvuksNwneAU4GtU1YyeLBqWtnbUc4kkfH0xLdKl2ZLSL4fNcU8PCXbNCRLXiotQl3BOmfHKY9CFm352dahskJbWezmGGCHHrEN9CXvU2ixeXIu5U0hlYjSGD1OaN1zz4dywSmGfjDA1qOS4MfjhkobfLfzTmgXjSGn3OGFesk3Z9zU1YyeNWc2CJc(ri9v5a5I9C5kWdU8PCFMlcZTwgJiV)1cWL(Iq6RYbYf75YvGhC5t5Ido5wlJrK3)Ab4sFr02(LlIY9zUk3f8uGo6leixCLlEfkA1qrE)RfGl9fgg9tahkms5(mxeMltZL3hAr8OCdcEQjWvaxrPiDA1qO5Ido5wlJruUbbp1e4kGROuesFvoqUypxYwIxCk4YNYfhCYTwgJ4mPUCVHYuesk3Z9XCNBpaCiPmgatKXacYfgg5D2Zfx5AJCrelsL7sFSiNWc2vJcCwNLHpytZYawK0PvdHYIBwKCO4euuwK1Yye59VwaU0xSmL7ZCDOINmbx(uU4k3AzmI8(xlax6lcPVkhi3N5wlJrCMuxU3qzkcjL75(yUZThaoKugdGjYyab5cdJ8o75IRCTblsL7sFSiNMB6eBddJ(jaRZYqByLSmGfjDA1qOS4MfjhkobfLfzTmgrE)RfGl9frB7xUpZL3TbTTFrE)RfGl9fH0xLdKlUYLRap4YNY9zUk3f8uGo6leixSBjx8ku0QHI8(xlax6lmm6NaouyKyrQCx6Jf5WOFc4qHrI1zzOnEGLbSiPtRgcLf3Si5qXjOOSiRLXiY7FTaCPViAB)Y9zU8UnOT9lY7FTaCPViK(QCGCXvUCf4bx(uUpZLP5Y7dTiECy0pfuohsU0xKoTAiuwKk3L(yroeivvJH1zzOnSbldyrsNwneklUzrYHItqrzrwlJrK3)Ab4sFri9v5a5I9C5kWdU8PCFMBTmgrE)RfGl9flt5Ido5wlJrK3)Ab4sFr02(L7ZC5DBqB7xK3)Ab4sFri9v5a5IRC5kWdU8jwKk3L(yrc4nKpZ6Sm0gyEwgWIKoTAiuwCZIKdfNGIYISwgJiV)1cWL(Iq6RYbYfx5(YrJF12CFMRYDbpfOJ(cbYf75(alsL7sFSincE5Ed1(xzDwgAdMawgWIKoTAiuwCZIKdfNGIYISwgJiV)1cWL(Iq6RYbYfx5(YrJF12CFMBTmgrE)RfGl9fltSivUl9XIefQV9bcviP(mRZ6SivUl4PGRg6Caldyz4dSmGfjDA1qOS4MfjhkobfLfPYDbpfOJ(cbYf75(qUpZTwgJiV)1cWL(IOT9l3N5IWCXRqrRgk6YNcEh49VwaU0xUypxE3g02(fncE5Ed1(xJOfO6sF5Ido5IxHIwnu0Lpf8oW7FTaCPVCXLLCTYCrelsL7sFSincE5Ed1(xzDwgAdwgWIKoTAiuwCZIKdfNGIYIeVcfTAOOlFk4DG3)Ab4sF5Ill5AL5Ido5IWC5DBqB7x8to1WiAbQU0xU4kx8ku0QHIU8PG3bE)RfGl9L7ZCzAUUAOZJWYrHEeMA7emsNwneAUikxCWjxxn05ry5OqpctTDcgPtRgcn3N5wlJrewok0JWuBNGXYuUpZfVcfTAOOlFk4DG3)Ab4sF5I9CvUl9f)KtnmY72G22VCXbNChY7ShG0xLdKlUYfVcfTAOOlFk4DG3)Ab4sFSivUl9XI8to1qwNLHyEwgWIKoTAiuwCZIKdfNGIYI0vdDEunKTahQae4uqyuGyfPtRgcn3N5IWCRLXiY7FTaCPViAB)Y9zUmn3AzmIZThaoKugJLPCrelsL7sFSirH6BFGqfsQpZ6SolsGRhQcrdW2vx6JLbSm8bwgWIKoTAiuwCZIKdfNGIYIu5UGNc0rFHa5IDl5IxHIwnuCU9aWHKYyyy0pbCOWiL7ZCryU1YyeNBpaCiPmglt5Ido5wlJrCiqc4n8hlt5IiwKk3L(yrom6NaouyKyDwgAdwgWIKoTAiuwCZIKdfNGIYISwgJikP(CTHhflt5(mxy5OrdFPikP(mimuFU)r60QHqZ9zU4vOOvdfD5tbVd8(xlax6lxCLBTmgrus95AdpkcPVkhi3N5QCxWtb6OVqGCXULCTblsL7sFSihcKQQXW6SmeZZYawK0PvdHYIBwKCO4euuwK1YyehcKaEd)XYelsL7sFSiNWc2vJcCwNLHmbSmGfjDA1qOS4MfjhkobfLfzTmgX52dahskJXYuUpZTwgJ4C7bGdjLXiK(QCGCXvUk3L(Idbsv1yIKTeV4uWLpXIu5U0hlYjSGD1OaN1zzOnZYawK0PvdHYIBwKCO4euuwK1YyeNBpaCiPmglt5(mxeM7eKWhE5OXhIdbsv1yYfhCYDiqc4k0jyu5UGNYfhCYv5U0xCclyxnkWJYfgg5D2ZfrSivUl9XICclyxnkWzDwgAnWYawK0PvdHYIBwKk3L(yrom6NaouyKyrIsaouMCPpwKmaIvUEN7l55IeZfUZDc2CqUYbeukxeOgbN70SciqUnmxR2)Ab4sF5onRacKR9z6YDQbaPAOilsouCckklsL7cEkqh9fcKl2TKlEfkA1qXzfIg4kWddJ(jGdfgPCFMBTmgrq5cmk3liuneai3BaskkwXYuUpZfH5Y72G22ViSCuOhHP2obJq6RYbY9XCvUl9fHLJc9im12jyKSL4fNcU8PCFmxUc8GlFkxSNBTmgrq5cmk3liuneai3Baskkwri9v5a5Ido5Y0CD1qNhHLJc9im12jyKoTAi0CruUpZfVcfTAOOlFk4DG3)Ab4sF5(yUCf4bx(uUyp3AzmIGYfyuUxqOAiaqU3aKuuSIq6RYbyDwgAnXYawK0PvdHYIBwKCO4euuwK1YyeNBpaCiPmglt5(mxaPq5EdEx4ZrL7cEIfPYDPpwKtyb7QrboRZYqmlwgWIKoTAiuwCZIKdfNGIYISwgJ4ewWMBuWpcjL75(mxUc8GlFkxCLBTmgXjSGn3OGFesFvoqUpZfH5Y0CHLJgn8LIGYfyuUxqOAiaqU3iDA1qO5Ido5wlJrCclyZnk4hH0xLdKlUYv5U0xCiqQQgtKRap4YNY9XC5kWdU8PCTj5wlJrCclyZnk4hHKY9CrelsL7sFSiNWc2vJcCwNLH20SmGfjDA1qOS4Mfzbqb7ZIHcCf4Y9YYWhyrYHItqrzrY0ChcKaUcDcgvUl4PCFMltZfVcfTAO4qGuOAuGhM62i3BUpZTwgJiOCbgL7feQgcaK7najffRiAB)Y9zUimxeMlcZv5U0xCiqQQgtKSL4fxU3CFMlcZv5U0xCiqQQgtKSL4fNcq6RYbYfx5ALrBoxCWjxMMlSC0OHVuCiqc4n8hPtRgcnxeLlo4KRYDPV4ewWUAuGhjBjEXL7n3N5IWCvUl9fNWc2vJc8izlXlofG0xLdKlUY1kJ2CU4GtUmnxy5OrdFP4qGeWB4psNwneAUikxeL7ZCRLXiotQl3BOmfHKY9CruU4GtUimxaPq5EdEx4ZrL7cEk3N5IWCRLXiotQl3BOmfHKY9CFMltZv5U0xeWBiFos2s8Il3BU4GtUmn3AzmIZThaoKugJqs5EUpZLP5wlJrCMuxU3qzkcjL75(mxL7sFraVH85izlXlUCV5(mxMM7C7bGdjLXayImgqqUWWiVZEUikxeLlIyrwauOhJWlhLLHpWIu5U0hlYHaPq1OaNfjkb4qzYL(yrATkq5EZ1NPCbUEOkenxy7Ql9HrU9zWk3cGYLjfiLlUnkWb5AFMUC9zcRCviL71EUvsU3CN62qO5oAyUiqnco3gMRv7FTaCPVyUiiakxMuGuU42Oapxs8zcMlAbk3BUAUmPaPQAmydbJfSRgf45YvGNR9z6YfbLuxU3CrqMYva5QCxWt52WCrlq5EZLSL4fNY1U4Z5IKuOCV5YGUWNJSoldFWkzzals60QHqzXnlsouCckklYAzmIZThaoKugJLPCFMRYDbpfOJ(cbYfx5IxHIwnuCU9aWHKYyyy0pbCOWiXIu5U0hlYjSGD1OaN1zz4dpWYawK0PvdHYIBwKCO4euuwKmnx8ku0QHItZnDITHPUnY9M7ZCryUmnxxn05XbS)bFMckyMar60QHqZfhCYv5UGNc0rFHa5I9CFixeL7ZCryUk3f8uaT9O8EIt5IRCTrU4GtUk3f8uGo6leixSBjx8ku0QHIZkenWvGhgg9tahkms5Ido5QCxWtb6OVqGCXULCXRqrRgko3Ea4qszmmm6NaouyKYfrSivUl9XICAUPtSnmm6NaSoldFWgSmGfjDA1qOS4MfPYDPpwKC1yck3L(cgb4SincWdN(jwKk3f8uWvdDoG1zz4dyEwgWIKoTAiuwCZIKdfNGIYIu5UGNc0rFHa5I9CFGfPYDPpwKOq9TpqOcj1NzDwg(ataldyrsNwneklUzrYHItqrzrcifk3BW7cFoQCxWtSivUl9XIeWBiFM1zz4d2mldyrsNwneklUzrYHItqrzrQCxWtb6OVqGCXULCXRqrRgkQqUEuGSDY0aPVCFM7xpnoX9CXULCXRqrRgkQqUEuGSDY0aPVWxpn3N56k8L8ODXNL7bRKfPYDPpwKkKRhfiBNmnq6J1zz4dwdSmGfjDA1qOS4MfPYDPpwKdJ(jGdfgjwKOeGdLjx6JfjtO4Z5sxxENZ1v4l5amYv8CfqUAUVQC56DUCf45YKg9tahkms5QGChIXqWCLd4KIMBpYLjfivvJjYIKdfNGIYIu5UGNc0rFHa5IDl5IxHIwnuCwHObUc8WWOFc4qHrI1zz4dwtSmGfPYDPpwKdbsv1yyrsNwneklUzDwNf5eK49VQoldyz4dSmGfPYDPpwKkKRhfKZjJH4ols60QHqzXnRZYqBWYawK0PvdHYIBwKOeGdLjx6JfjcABpxtFV5wPrdPCTA)RfGl9LlyUlg0CDOCmsoixFw9CDO8(sWC1CbZkKqZLRo92qSYL3TbTTF52xUTptWCDOCmsoi3R9CRuUfaHIaplYt)elsqxmb59eNGSi5qXjOOSizAU4vOOvdf59VwaU0xOVqbq5(mxMMlHzkY0eHgrHKIoeifWtaazY9zUmnxxn05XHajGRqNGr60QHqzrQCx6JfjOlMG8EItqwNLHyEwgWIKoTAiuwCZI80pXIemROTDcn0WAOhbVHF6CwKk3L(yrcMv02oHgAyn0JG3WpDoRZYqMawgWIu5U0hlYVaHnmiF9LyrsNwneklUzDwgAZSmGfjDA1qOS4MfjhkobfLfjtZDcs4Jtyb7QrbolsL7sFSiNWc2vJcCwN1zDwK4jiq6JLH2WkTXdwjMLnWSyrAxHNCVawKmHmreigATzOnL1LBUmyMYv(tn0ZD0WCXeSNctZkGWuUqcZueiHMlO)uUAX7V6eAU8z9EjqmzgbihLRnSUCTAF4jOtO5Ijy5OrdFPOvGPC9oxmblhnA4lfTIiDA1qOykxe(GTikMmJaKJY1AY6Y1Q9HNGoHMlMC1qNhTcmLR35Ijxn05rRisNwnekMYfHpylIIjZia5OCXSSUCTAF4jOtO5Ijy5OrdFPOvGPC9oxmblhnA4lfTIiDA1qOykxeAdBrumzgbihL7dwP1LRv7dpbDcnxmblhnA4lfTcmLR35Ijy5OrdFPOvePtRgcft5IWhSfrXK5KzMqMicedT2m0MY6Ynxgmt5k)Pg65oAyUycLgAX4ykxiHzkcKqZf0FkxT49xDcnx(SEVeiMmJaKJY9bRlxR2hEc6eAUycwoA0WxkAfykxVZftWYrJg(srRisNwnekMYv9CTMXSra5IWhSfrXKzeGCuUmbwxUwTp8e0j0CXeSC0OHVu0kWuUENlMGLJgn8LIwrKoTAiumLR65AnJzJaYfHpylIIjZia5OCFWgwxUwTp8e0j0CrkFRMlaRZvBZ1A0AmxVZfbu0C)nAXua52teu9gMlcTgruUi8bBrumzgbihL7d2W6Y1Q9HNGoHMlM49HwepAfykxVZft8(qlIhTIiDA1qOykxe(GTikMmJaKJY9bmV1LRv7dpbDcnxm5q5yK84drRat56DUyYHYXi5r)HOvGPCriM3weftMraYr5(aM36Y1Q9HNGoHMlMCOCmsE0grRat56DUyYHYXi5r3grRat5IqmVTikMmJaKJY9bMaRlxR2hEc6eAUyI3hAr8OvGPC9oxmX7dTiE0kI0PvdHIPCr4d2IOyYmcqokxB8G1LRv7dpbDcnxmblhnA4lfTcmLR35Ijy5OrdFPOvePtRgcft5IWhSfrXKzeGCuU2WgwxUwTp8e0j0CXeSC0OHVu0kWuUENlMGLJgn8LIwrKoTAiumLlcFWweftMraYr5AdmV1LRv7dpbDcnxm5QHopAfykxVZftUAOZJwrKoTAiumLlcFWweftMraYr5AdmV1LRv7dpbDcnxmblhnA4lfTcmLR35Ijy5OrdFPOvePtRgcft5IWhSfrXKzeGCuU2GjW6Y1Q9HNGoHMlMGLJgn8LIwbMY17CXeSC0OHVu0kI0PvdHIPCr4d2IOyYmcqokxByZwxUwTp8e0j0CXeSC0OHVu0kWuUENlMGLJgn8LIwrKoTAiumLlcFWweftMraYr5AdRjRlxR2hEc6eAUycwoA0WxkAfykxVZftWYrJg(srRisNwnekMYfHpylIIjZia5OCTbML1LRv7dpbDcnxKY3Q5cW6C12CTgZ17CrafnxubVaK(YTNiO6nmxeIneLlcX82IOyYmcqokxBGzzD5A1(WtqNqZfP8TAUaSoxTnxRrRXC9oxeqrZ93OftbKBprq1ByUi0Aer5IWhSfrXKzeGCuU2aZY6Y1Q9HNGoHMlMGLJgn8LIwbMY17CXeSC0OHVu0kI0PvdHIPCr4d2IOyYmcqokxmVvAD5A1(WtqNqZftUAOZJwbMY17CXKRg68OvePtRgcft5IWhSfrXK5KzMqMicedT2m0MY6Ynxgmt5k)Pg65oAyUyAcs8(xvht5cjmtrGeAUG(t5QfV)QtO5YN17LaXKzeGCuU2W6Y1Q9HNGoHMlMC1qNhTcmLR35Ijxn05rRisNwnekMYv9CTMXSra5IWhSfrXK5KzMqMicedT2m0MY6Ynxgmt5k)Pg65oAyUyI3)Ab4sFbE3g02(bWuUqcZueiHMlO)uUAX7V6eAU8z9EjqmzgbihLR1G1LRv7dpbDcnxmblhnA4lfTcmLR35Ijy5OrdFPOvePtRgcft5IWhSfrXK5KzMqMicedT2m0MY6Ynxgmt5k)Pg65oAyUys5UGNcUAOZbykxiHzkcKqZf0FkxT49xDcnx(SEVeiMmJaKJY1gwxUwTp8e0j0CXKRg68OvGPC9oxm5QHopAfr60QHqXuUi0g2IOyYmcqokxmV1LRv7dpbDcnxm5QHopAfykxVZftUAOZJwrKoTAiumLlcFWweftMtMzczIiqm0AZqBkRl3CzWmLR8NAON7OH5IjGRhQcrdW2vx6dt5cjmtrGeAUG(t5QfV)QtO5YN17LaXKzeGCuU2W6Y1Q9HNGoHMlMGLJgn8LIwbMY17CXeSC0OHVu0kI0PvdHIPCr4d2IOyYmcqokxRbRlxR2hEc6eAUyYvdDE0kWuUENlMC1qNhTIiDA1qOykxe(GTikMmJaKJYfZY6Y1Q9HNGoHMlMGLJgn8LIwbMY17CXeSC0OHVu0kI0PvdHIPCr4d2IOyYmcqokxBARlxR2hEc6eAUycwoA0WxkAfykxVZftWYrJg(srRisNwnekMYfH2WweftMraYr5(WdwxUwTp8e0j0CXKRg68OvGPC9oxm5QHopAfr60QHqXuUi8bBrumzozMjKjIaXqRndTPSUCZLbZuUYFQHEUJgMlM49VwaU0xyAwbeMYfsyMIaj0Cb9NYvlE)vNqZLpR3lbIjZia5OCzcSUCTAF4jOtO5IjEFOfXJwbMY17CXeVp0I4rRisNwnekMYfHpylIIjZia5OCTMSUCTAF4jOtO5Ijxn05rRat56DUyYvdDE0kI0PvdHIPCr4d2IOyYmcqokxRjRlxR2hEc6eAUycwoA0WxkAfykxVZftWYrJg(srRisNwnekMYfH2WweftMraYr5AtBD5A1(WtqNqZftWYrJg(srRat56DUycwoA0WxkAfr60QHqXuUi8bBrumzgbihL7dwdwxUwTp8e0j0CXeVp0I4rRat56DUyI3hAr8OvePtRgcft5IWhSfrXKzeGCuUpynzD5A1(WtqNqZft8(qlIhTcmLR35IjEFOfXJwrKoTAiumLlcFWweftMraYr5(aML1LRv7dpbDcnxmX7dTiE0kWuUENlM49HwepAfr60QHqXuUi8bBrumzgbihLRnEW6Y1Q9HNGoHMlM49HwepAfykxVZft8(qlIhTIiDA1qOykx1Z1AgZgbKlcFWweftMtMT2)Pg6eAUwt5QCx6lxJaCqmzMf5eShIHyrIyeNltkqkxey6lLmJyeN7S7taRdBy7v85snY7p2aYVyux6Jd1HJnG85ylzgXioxMy5Ta8CTbMfg5AdR0gpKmNmJyeNRvN17LawxYmIrCUwFUiiak3H8o7bi9v5a5cvFMG56Z6LRRWxYJU8PG3buHYD0WCnkWTEaX7dnxTkgXXk3cqFjqmzgXioxRpxeq3a6YLRapxiHzkcK(05GChnmxR2)Ab4sF5IqjsrmYfTpm55o3g0Cfp3rdZvZDajWCUiWiNAyUCf4ikMmJyeNR1NR18PvdLlWHc3ZLptCgL7n3(YvZDq2ZD0qgb5kxU(mLltebJaY17CHeAHt5AVHmAAfnMmJyeNR1NltefZDb45Q5IGXc2vJc8CPZHyLRpREUOnbY9Ap3FJsMCTtgtUYz9V6NYfHa5NRtaNqZv9CVoxG8EYq4655ATqWiZv(tk3rumzgXioxRpxR2hEc65QgtU1YyeTIiKuUNlDouiqUENBTmgrRiwMWix9Yvn)g45khqEpziC98CTwiyK5(QYLRC5cKpiMmJyeNR1NlccGYDwHO8gLqZfVcfTAiqUENlKqlCkxRIGrqY1Edz00kAmzozgXioxRzBjEXj0CR0OHuU8(xvp3k9khiMltKZPjhK71N1pRW)OyYv5U0hi3(myftMvUl9bItqI3)Q6pAbBkKRhfKZjJH4EYmIrCUmremcixmhfkA1q5Izp5sFwxUw7rUaYZ17C1CV(SEe4iyNlE1uimY1NPCTA)RfGl9LRYDPVC1dnxE3g02(bY1Nvpxfs5Y7d4qvocnxVZTpdw5wPClacnx7Z0LRv7FTaCPVCfqULPCTlgtUx75wPClacnx0cuU3C9zkxG8lg1L(IjZigX5IyeNRYDPpqCcs8(xv)rlydVcfTAimo9twqfGwnuG3)Ab4sFy0twGeG8KzeNltebJaYfZrHIwnuUy2tU0N1LldMfqU4vOOvdLlyI4YqiqU2NjFMG5A1(xlax6lxWCxmO5wPClacnx0cuU3CzsbsaxHobJjZigX5QCx6deNGeV)v1F0c2WRqrRgcJt)KLHajGRqNGbE)RfGl9HrpzbqogYWctD1qNhNWc2CJc(yGxnfYYdyGxnfkqgazXktMrCUmremcixmhfkA1q5Izp5sFwxUmywa5IxHIwnuUGjIldHa56ZuUx5xjyU9ixxHVKdYv9CTpl85CrqBpxKoKugZLjn6NaouyKa52fhiOuU9ixR2)Ab4sF5cM7Ibn3kLBbqOXKzeJ4CvUl9bItqI3)Q6pAbB4vOOvdHXPFYYC7bGdjLXWWOFc4qHrcJEYcGCmKHfxn05XHr)uysD(mg4vtHSydmWRMcfidGSG5tMrCUmremcixmhfkA1q5Izp5sFwxUmywa5IxHIwnuUGjIldHa56ZuUx5xjyU9ixxHVKdYv9CTpl85CrqviAUwvbEUmPr)eWHcJei3U4abLYTh5A1(xlax6lxWCxmO5wPClacnxfK7qmgcgtMrmIZv5U0hiobjE)RQ)OfSHxHIwnegN(jlZkenWvGhgg9tahkmsy0twaKJHmS4QHopom6NctQZNXaVAkKfBGbE1uOazaKfmFYmIZLjIGra5I5OqrRgkxm7jx6Z6YLbZcix8ku0QHYfmrCzieixFMY9k)kbZTh56k8LCqUQNR9zHpNlcA75I0HKYyUmPr)eWHcJeixfs5waeAUOfOCV5A1(xlax6lMmJyeNRYDPpqCcs8(xv)rlydVcfTAimo9tw49VwaU0xyy0pbCOWiHrpzbqogYWIRg684WOFkmPoFgd8QPqwW8yGxnfkqgazXAizgX5YerWiGCXCuOOvdLlM9Kl9zD5YGzbKlEfkA1q5cMiUmecKRpt5ELFLG52JCDf(soix1Z1(SWNZLjc56r5AnB7KPbsF52fhiOuU9ixR2)Ab4sF5cM7Ibn3kLBbqOXKzeJ4CvUl9bItqI3)Q6pAbB4vOOvdHXPFYIc56rbY2jtdK(WONSaihdzyXvdDECy0pfMuNpJbE1uil2020yGxnfkqgazXgjZioxMicgbKlMJcfTAOCXSNCPpRlxgmlGCXRqrRgkxWeXLHqGC9zk3jcYPZ1xk3EK7xpn3kzA75AFw4Z5YeHC9OCTMTDY0aPVCTlgtUx75wPClacnMmJyeNRYDPpqCcs8(xv)rlydVcfTAimo9twuixpkq2ozAG0x4RNIbkn0IXTWeyLy0twGeG8KzeNltebJaYfZrHIwnuUy2tU0N1LldMPCVYVsWC7rUUcFjhKlYzz4Y9MlcUTtWCbZDXGMBLYTai0C7lx0cuU3CTA)RfGl9ftMrmIZv5U0hiobjE)RQ)OfSHxHIwnegN(jl8(xlax6laMLHl3ByQTtqmqPHwmUfBGrpzbsaYtMrCUmremcixmhfkA1q5Izp5sFwxUmyMY1LpLlK(QCY9MBF5Q5YvGNR9z6Y1Q9VwaU0xUC9YTs5waeAUYLlG49HcIjZigX5QCx6deNGeV)v1F0c2WRqrRgcJt)KfE)RfGl9f4kWdq6RYbWaLgAX4wSYO1eg9KfibipzgX5YerWiGCXCuOOvdLlM9Kl9zD5YGzbKlEfkA1q5cMiUmecKRpt5ELFLG52JCbeVpuqU9ixMuGuU42OapxFw9CbZDXGMBLYDQBdHM7Kc8C9zkxuAOfJNR(7Y5XKzeJ4CvUl9bItqI3)Q6pAbB4vOOvdHXPFYsJNGtDBcdbsHQrboaduAOfJBXkXONSaja5jZioxMicgbKlMJcfTAOCXSNCPpRlxe02EUM(EZTsJgs5A1(xlax6lxWCxmO5An)NWcsQjxmBi6PhNYTs5waekc8jZigX5QCx6deNGeV)v1F0c2WRqrRgcJt)Kf6pHfKutOHONECkGsgflmqPHwmULhWSWONSaja5jZigX5ATh5A1(xlax6lxbKlQa0QHqXixaFMqlgkxFMYDiqGNRv7FTaCPVChkmxD4emxFMYDiVZEU0HcIjZigX5IyeNRYDPpqCcs8(xv)rlydVcfTAimo9twC5tbVd8(xlax6dd8QPqwgY7ShG0xLd84dwPvIHmSGxHIwnuevaA1qbE)RfGl9LmJ4CzWmLlAbQU0xU9ixnxKLlxmxY9IjqU42qaGCV5A1(xlax6lMmJyeNRYDPpqCcs8(xv)rlydVcfTAimo9twamwdOfO6sFy0twaKJbE1uil2CYmIZLjCM8zcMRMBbOvdLR40p3cGqZ17CRLXixR2)Ab4sF5kGCjmtrMMi0yYmIrCUk3L(aXjiX7Fv9hTGn8ku0QHW40pzH3)Ab4sFH(cfaHbE1uileMPitteA81OOI6neeQk6lHdoeMPitteA8RCTcPayMip8laHJdoeMPitteAuoahwCTAOaMPONx(bucVWjCWHWmfzAIqJGYvnDJg0p5ZybCCWHWmfzAIqJ0FcliPMqdrp94eo4qyMImnrOXHr)uOhHQ6UHWbhcZuKPjcnAxzKocccdyFO4GdHzkY0eHgLd4Wc3BiiGk4LJcvYyWbhcZuKPjcncMv02oHgAyn0JG3WpDEYmIZfbTTNRPV3CR0OHuUwT)1cWL(Yfm3fdAUouogjhKRpREUouEFjyUAUGzfsO5YvNEBiw5Y72G22VC7l32NjyUouogjhK71EUvk3cGqrGpzgXioxL7sFG4eK49VQ(JwWgEfkA1qyC6NS0xOaOaV49yGrpzbqog4vtHSydRedzybVcfTAOiV)1cWL(c9fkakzgXioxL7sFG4eK49VQ(JwWgEfkA1qyC6NS0xOaOaV49yGrpzbqog4vtHSydBgdzyHWmfzAIqJFLRvifaZe5HFbi8KzeJ4CvUl9bItqI3)Q6pAbB4vOOvdHXPFYsFHcGc8I3Jbg9Kfa5yGxnfYInSYhXRqrRgks)jSGKAcne90JtbuYOyHHmSqyMImnrOr6pHfKutOHONECkzw5U0hiobjE)RQ)OfSvauqC6JXPFYcOlMG8EItqmKHfMIxHIwnuK3)Ab4sFH(cfa9KPeMPitteAefsk6qGuapbaK5jtD1qNhhcKaUcDcMmRCx6deNGeV)v1F0c2kakio9X40pzbmROTDcn0WAOhbVHF68KzL7sFG4eK49VQ(JwW2xGWggKV(sjZk3L(aXjiX7Fv9hTGTjSGD1OahdzyHPtqcFCclyxnkWtMtMrmIZ1A2wIxCcnxcpbXkxx(uU(mLRY9gMRaYvXRIrRgkMmRCx6dyH3LZjiyImgmKHfMclhnA4lfrfaxMmYPqSc8()1dnzgXioxgs2hD5qZfbIaTbpLRaYf0FYNL7nxFw9C56Hjp3kL7VrjdHgtMrmIZv5U0h4rly7i7JUCObibAdEcJcGc2Nfdf4kWL71YdyidliSwgJiV)1cWL(ILjCWPwgJiOCbgL7feQgcaK7najffRiKuUJON1YyepY(OlhAasG2GNIOT9lzgXioxgmt5Y7FTaCPVGlF5EZv5U0xUgb45c4ZeAXqGCTptxUwT)1cWL(Y1Uym5wPClacnx9qZf4nKa56ZuUqcumEUYLlEfkA1qrx(uW7aV)1cWL(IjZigX5QCx6d8OfSXvJjOCx6lyeGJXPFYcV)1cWL(cU8L7nzgX5I5OqrRgkxFw9CjGlF1jqU2NjFMG5ICwgUCV5IGB7emx7IXKBLYTai0CR0OHuUwT)1cWL(Yva5cjffRyYmIrCUk3L(apAbB4vOOvdHXPFYcywgUCVHP2obdvA0qkW7FTaCPpm6jlaYXaVAkKfeQCxWtb6OVqaCHxHIwnuK3)Ab4sFbWSmC5EdtTDcIdok3f8uGo6leax4vOOvdf59VwaU0xyy0pbCOWiHdo4vOOvdfD5tbVd8(xlax6Z6vUl9fbZYWL7nm12jyCumMaKqlCx6d78UnOT9lcMLHl3ByQTtWiAbQU0hIEIxHIwnu0Lpf8oW7FTaCPpRN3TbTTFrWSmC5EdtTDcgH0xLdGDL7sFrWSmC5EdtTDcghfJjaj0c3L(EIqE3g02(fHLJc9im12jyesFvoG1Z72G22ViywgUCVHP2obJq6RYbWUnJdom1vdDEewok0JWuBNGikzw5U0h4rlydmldxU3WuBNGyidl1Yye59VwaU0xeTTFpvUl9fhcKcvJc8iFwHVeaxwE4jtryTmgr5ge8utGRaUIsXY0ZAzmIZThaoKugJqs5oIEIxHIwnuemldxU3WuBNGHknAif49VwaU0xYSYDPpWJwWgurf98aysHmIHmSulJrK3)Ab4sFr02(9eH4vOOvdfD5tbVd8(xlax6d78UnOT9Z6TzeLmRCx6d8OfSHsQpxB4ryidl1Yye59VwaU0xeTTFpRLXiclhf6ryQTtWiAB)EIxHIwnu0Lpf8oW7FTaCPpCHxHIwnuK3)Ab4sFHjiXvGhC5tps2s8Itbx(0JiSwgJikP(CTHhfrlq1L(S(AzmI8(xlax6lIwGQl9HiBcSC0OHVueLuFgegQp3)KzL7sFGhTGTVaHnee6rWB4NohdzybVcfTAOOlFk4DG3)Ab4sF4cVcfTAOiV)1cWL(ctqIRap4YNEKSL4fNcU8PN1Yye59VwaU0xeTTFjZioxMSH5I5qNpJfeJClakxnxMuGuU42Oapx(ScFPCrlq5EZfbMaHneKBpYLbn8tNNlxbEUENRIVf0C560KCV5YNv4lbIjZk3L(apAbBdbsHQrbogfafSplgkWvGl3RLhWqgwuUl9f)ce2qqOhbVHF68izlXlUCVphfJjaj(ScFPGlFY6vUl9f)ce2qqOhbVHF68izlXlofG0xLdGlMGNmDU9aWHKYyamrgdiixyyK3z)jtRLXio3Ea4qszmwMsMvUl9bE0c2kakio9XGgdI7Ht)KLxJIkQ3qqOQOVegYWcEfkA1qrx(uW7aV)1cWL(WoVBdAB)SEBozw5U0h4rlyRaOG40hJt)Kf6pHfKutOHONECcdzybVcfTAOOlFk4DG3)Ab4sF4YcEfkA1qr6pHfKutOHONECkGsgfRN4vOOvdfD5tbVd8(xlax6d74vOOvdfP)ewqsnHgIE6XPakzuSSEBozw5U0h4rlyRaOG40hJt)KfWSI22j0qdRHEe8g(PZXqgwqiEfkA1qrx(uW7aV)1cWL(WLf8ku0QHI8(xlax6lmbjUc8GlF6rBGdod5D2dq6RYbWfEfkA1qrx(uW7aV)1cWL(q0ZAzmI8(xlax6lI22VKzL7sFGhTGTcGcItFmo9twEnynnh6rqba5lg1L(WqgwWRqrRgk6YNcEh49VwaU0h2TGxHIwnuSVqbqbEX7Xizw5U0h4rlyRaOG40hJt)KLVY1kKcGzI8WVaeogYWcEfkA1qrx(uW7aV)1cWL(WLfBozgX5ATh5waY9MRMlWjylO52N1xauUItFmYvn2vSa5wauUwliPOdbs5I5qaazYTloqqPC7rUwT)1cWL(I5Iz7Ze0UaimYDcknuCbbok3cqU3CTwqsrhcKYfZHaaYKRDXNZ1Q9VwaU0xU9zWkxzKR1(ge8utUwvbCfLYva5sNwneAU6HMRMBbOVuU27dtEUvkxtd8CB8emxFMYfTavx6l3EKRpt5oK3zpMldMfqUkkkixnxWxnMCXRMcLR356ZuU8UnOT9l3EKR1csk6qGuUyoeaqMCTptxUOTCV56ZcixUA4fJ6sF5wjUwauUINRaYTCqsnax456DUkau(uU(S65kEU2fJj3kLBbqO5orWbXDdw52xU8UnOT9lMmRCx6d8OfSvauqC6JXPFYckKu0HaPaEcaidgYWcEfkA1qrx(uW7aV)1cWL(WUf8ku0QHI9fkakWlEpgpryTmgr5ge8utGRaUIsrGRCgTulJruUbbp1e4kGROu8R2gaUYzehCykVp0I4r5ge8utGRaUIs4GdEfkA1qrE)RfGl9f6luaeo4GxHIwnu0Lpf8oW7FTaCPpSlNtWP2OoHggY7ShG0xLdynAnIqE3g02(94dwjIquYmIrCUmKSNlYUyY1A)EItWCPZHyHrUqYiei3(YfmRqcnxXPFUw1ALRCJg(vx6lxFw9CfqUx75If55ckttn0j0yU5IartgLtGC9zk3jiHx6cixJCuU2NPl3r54U0NAIjZk3L(apAbBfafeN(yC6NSa6IjiVN4eedzybH4vOOvdfD5tbVd8(xlax6d7wW8wPnbH4vOOvdf7luauGx8EmWUvIiCWbHm1HYXi5XhIcic6IjiVN4e8PdLJrYJpelaTAONouogjp(qK3TbTTFri9v5a4GdtDOCmsE0grbebDXeK3tCc(0HYXi5rBelaTAONouogjpAJiVBdAB)Iq6RYbqeIEIqMsyMImnrOruiPOdbsb8eaqgCWH3TbTTFruiPOdbsb8eaqMiK(QCaSBZikzgX5YaO8(sWCr2ftUw73tCcMlPqdw5Ax85CT23GGNAY1QkGROuUnmx7Z0LR45Axb5objUc8yYSYDPpWJwWgxpozc1YyGXPFYcOlMG8EIl9HHmSWuEFOfXJYni4PMaxbCfLE6YNWLnJdo1YyeLBqWtnbUc4kkfbUYz0sTmgr5ge8utGRaUIsXVABa4kNXKzeNR12PpixFw9Cr7CV2ZTshnepxR2)Ab4sF5cM7Ibnxm3fGNBLYTai0C7Ideuk3EKRv7FTaCPVCvpxq)PCNA58yYSYDPpWJwWwbqbXPpgN(jlYb4WIRvdfWmf98YpGs4foHHmSqyMImnrOXxJIkQ3qqOQOV0t8ku0QHIU8PG3bE)RfGl9HDl4vOOvdf7luauGx8EmsMvUl9bE0c2kakio9X40pzzy0pf6rOQUBimKHfcZuKPjcn(Auur9gccvf9LEIxHIwnu0Lpf8oW7FTaCPpSBbVcfTAOyFHcGc8I3JrYSYDPpWJwWwbqbXPpgN(jl2vgPJGGWa2hkgYWcHzkY0eHgFnkQOEdbHQI(spXRqrRgk6YNcEh49VwaU0h2TGxHIwnuSVqbqbEX7Xizw5U0h4rlyRaOG40hJt)Kf5aoSW9gccOcE5OqLmgmKHfcZuKPjcn(Auur9gccvf9LEIxHIwnu0Lpf8oW7FTaCPpSBbVcfTAOyFHcGc8I3JrYSYDPpWJwWwbqbXPpgN(jlGYvnDJg0p5ZybCmKHfcZuKPjcn(Auur9gccvf9LEIxHIwnu0Lpf8oW7FTaCPpSBbVcfTAOyFHcGc8I3JrYSYDPpWJwWwbqbXPpadzybVcfTAOOlFk4DG3)Ab4sFy3cEfkA1qX(cfaf4fVhJKzeNlccGYLjHnWZLHnEnxVZ1HY7lbZ1Mckadw5AT5c3qXKzL7sFGhTGTbSbE4A8kgYWcSC0OHVu8fkadwbHlCd9SwgJiV)1cWL(IOT97jcXRqrRgk6YNcEh49VwaU0h25DBqB7ho4GxHIwnu0Lpf8oW7FTaCPpCHxHIwnuK3)Ab4sFHjiXvGhC5tps2s8Itbx(eIsMrCU2uKNRpt5ATeaxMmYPqSY1Q9)RhAU1YyKBzcJClNHaGC59VwaU0xUcixq3xmzw5U0h4rlyJ3LZjiyImgmKHfy5OrdFPiQa4YKrofIvG3)VEOp5DBqB7xSwgJaQa4YKrofIvG3)VEOriPOy9SwgJiQa4YKrofIvG3)VEObfY1JIOT97jtRLXiIkaUmzKtHyf49)RhASm9eH4vOOvdfD5tbVd8(xlax67rL7sFXbSbETnEKRap4YNWoVBdAB)I1YyeqfaxMmYPqSc8()1dnIwGQl9Hdo4vOOvdfD5tbVd8(xlax6dx2mIsMvUl9bE0c2uixpkq2ozAG0hgYWcSC0OHVuevaCzYiNcXkW7)xp0N8UnOT9lwlJravaCzYiNcXkW7)xp0iKuuSEwlJrevaCzYiNcXkW7)xp0Gc56rr02(9KP1YyerfaxMmYPqSc8()1dnwMEIq8ku0QHIU8PG3bE)RfGl99izlXlofC5tpQCx6loGnWRTXJCf4bx(e25DBqB7xSwgJaQa4YKrofIvG3)VEOr0cuDPpCWbVcfTAOOlFk4DG3)Ab4sF4YMFYuxn05ry5OqpctTDcIOKzL7sFGhTGTbSbETnogYWcSC0OHVuevaCzYiNcXkW7)xp0N8UnOT9lwlJravaCzYiNcXkW7)xp0iK(QCaCXvGhC5tpRLXiIkaUmzKtHyf49)RhAyaBGhrB73tMwlJrevaCzYiNcXkW7)xp0yz6jcXRqrRgk6YNcEh49VwaU03JCf4bx(e25DBqB7xSwgJaQa4YKrofIvG3)VEOr0cuDPpCWbVcfTAOOlFk4DG3)Ab4sF4YMruYSYDPpWJwW2a2apCnEfdzybwoA0WxkIkaUmzKtHyf49)Rh6tE3g02(fRLXiGkaUmzKtHyf49)RhAeskkwpRLXiIkaUmzKtHyf49)RhAyaBGhrB73tMwlJrevaCzYiNcXkW7)xp0yz6jcXRqrRgk6YNcEh49VwaU0h25DBqB7xSwgJaQa4YKrofIvG3)VEOr0cuDPpCWbVcfTAOOlFk4DG3)Ab4sF4YMruYSYDPpWJwWgxnMGYDPVGraogN(jl8(xlax6lmnRacdzybVcfTAOOlFk4DG3)Ab4sF4YIvIdo4vOOvdfD5tbVd8(xlax6dx4vOOvdf59VwaU0xycsCf4bx(0tE3g02(f59VwaU0xesFvoaUWRqrRgkY7FTaCPVWeK4kWdU8PKzL7sFGhTGny5OqpctTDcIHmSulJrewok0JWuBNGr02(9KP1YyehcKaEd)riPC)jcXRqrRgk6YNcEh49VwaU0h2TulJrewok0JWuBNGr0cuDPVN4vOOvdfD5tbVd8(xlax6d7k3L(IdbsHQrbECumMaK4Zk8LcU8jCWbVcfTAOOlFk4DG3)Ab4sFyFiVZEasFvoaIEIqMclhnA4lfbLlWOCVGq1qaGCV4GJYDbpfOJ(cbWUf8ku0QHIZkenWvGhgg9tahkms4GtTmgrq5cmk3liuneai3BaskkwXYeo4ulJreuUaJY9ccvdbaY9gHKYDSBPwgJiOCbgL7feQgcaK7n(vBdax5mA9pGdod5D2dq6RYbWvTmgry5OqpctTDcgrlq1L(quYmIZfb3TjxfK7xpSYLjfiLlUnkWb5QGCNAaqQgk3rdZ1Q9VwaU0xmxKLQdvUNBx8C7rU(mL7aQCx6tn5Y7)uF0552JC9zk3R8Rem3EKltkqkxCBuGdY1Nvpx7IXK7PEbQgdw5cj(ScFPCrlq5EZ1NPCTA)RfGl9L70ScOCRexlak3PUnY9MREy5ZY9M7Kc8C9z1Z1Uym5ETN7luppx9YLS1HAUmPaPCXTrbEUOfOCV5A1(xlax6lMmRCx6d8OfSHxHIwnegfaf6Xi8YrT8agfafSplgkWvGl3RLhW40pzziqkunkWdtDBK7fd8QPqwuUl9fhcKcvJc8iFwHVeimGk3L(uZJieVcfTAOOlFk4DG3)Ab4sFpQCx6lcMLHl3ByQTtW4OymbiHw4U0NnbVcfTAOiywgUCVHP2obdvA0qkW7FTaCPpeznY72G22V4qGuOAuGhrlq1L(S(hWfVBdAB)IdbsHQrbE8R2g4Zk8LapIxHIwnuSXtWPUnHHaPq1OahynY72G22V4qGuOAuGhrlq1L(SEewlJrK3)Ab4sFr0cuDPpRrE3g02(fhcKcvJc8iAbQU0hISgTgF4jEfkA1qrx(uW7aV)1cWL(W1qEN9aK(QCaCWbwoA0WxkckxGr5EbHQHaa5EFcifk3BW7cFoQCxWtpvUl9fhcKcvJc84OymbiXNv4lfC5tyhZBtE5OXVABYmIZfZrHIwnuU(S65Y7ZHTbKlcEUPtSnxM0OFcKBbOVuUENlDGcKYvCqU8zf(sGCviL7u3gcn3rdZ1Q9VwaU0xmxm7ZGvUfaLlcEUPtSnxM0OFcKBxCGGs52JCTA)RfGl9LR9z6YDumMC5Zk8La5Y1l3kLBxDvocnx0cuU3C9zk3JS1Z1Q9VwaU0xmzgXioxL7sFGhTGn8ku0QHW40pzzAUPtSnm1TrUxmKHfL7cEkqh9fcGl8ku0QHI8(xlax6lmm6NaouyKWaVAkKf8ku0QHIU8PG3bE)RfGl99yTmgrE)RfGl9frlq1L(SEBgxk3L(ItZnDITHHr)eiokgtas8zf(sbx(0J8UnOT9lon30j2ggg9tGiAbQU0N1RCx6lcMLHl3ByQTtW4OymbiHw4U0NnbVcfTAOiywgUCVHP2obdvA0qkW7FTaCPVN4vOOvdfD5tbVd8(xlax6dxd5D2dq6RYbWbhy5OrdFPiOCbgL7feQgcaK7fhCC5t4YMtMrCUmHZ0LBbi3BUmPr)eWHcJuUYLRv7FTaCPpmYfO4PCvqUF9Wkx(ScFjqUki3PgaKQHYD0WCTA)RfGl9LRDXN7INlxNMK7nMmJyeNRYDPpWJwWgEfkA1qyC6NSmn30j2gM62i3lgYWIYDbpfOJ(cbWUf8ku0QHI8(xlax6lmm6NaouyKWaVAkKf8ku0QHIU8PG3bE)RfGl9HlL7sFXP5MoX2WWOFcehfJjaj(ScFPGlFY6vUl9fbZYWL7nm12jyCumMaKqlCx6ZMGxHIwnuemldxU3WuBNGHknAif49VwaU03t8ku0QHIU8PG3bE)RfGl9HRH8o7bi9v5a4GdSC0OHVueuUaJY9ccvdbaY9IdoU8jCzZjZk3L(apAbBC1yck3L(cgb4yC6NSa7PW0Scimaou4ULhWqgwQLXiclhf6ryQTtWyz6jEfkA1qrx(uW7aV)1cWL(WUvMmJ4CzIOyUlapxFMYfVcfTAOC9z1ZL3NdBdixMuGuU42Oap3cqFPC9ox6afiLR4GC5Zk8La5Qqkx1a6CN62qO5oAyUiqLJYTh5IGB7emMmRCx6d8OfSHxHIwnegfaf6Xi8YrT8agfafSplgkWvGl3RLhW40pzziqkunkWdtDBK7fd8QPqw4DBqB7xewok0JWuBNGri9v5a4s5U0xCiqkunkWJJIXeGeFwHVuWLpz9k3L(IGzz4Y9gMA7emokgtasOfUl9ztqiEfkA1qrWSmC5EdtTDcgQ0OHuG3)Ab4sFp5DBqB7xemldxU3WuBNGri9v5a4I3TbTTFry5OqpctTDcgH0xLdGON8UnOT9lclhf6ryQTtWiK(QCaCnK3zpaPVkhadzyHP4vOOvdfhcKcvJc8Wu3g5EF6QHopclhf6ryQTtWN1YyeHLJc9im12jyeTTFjZioxMWz6YfbvHOCf4Y9MltA0pLlshkmsyKltkqkxCBuGdYfm3fdAUvk3cGqZ17CFPJGQt5IG2EUiDiPmcYvp0C9oxYwNo0CXTrbobZfbMcCcgtMvUl9bE0c2gcKcvJcCmkak0Jr4LJA5bmkakyFwmuGRaxUxlpGHmSWu8ku0QHIdbsHQrbEyQBJCVpXRqrRgk6YNcEh49VwaU0h2TYNk3f8uGo6lea7wWRqrRgkoRq0axbEyy0pbCOWi9KPdbsaxHobJk3f80tMwlJrCU9aWHKYySm9eH1YyeNj1L7nuMILPNk3L(IdJ(jGdfgPizlXlofG0xLdGlRmAZ4GdFwHVeimGk3L(ud2TydeLmJ4CTwfOCV5YKcKaUcDcIrUmPaPCXTrboixfs5waeAUa5lgfAWkxVZfTaL7nxR2)Ab4sFXCTPOJGQXGfg56Zew5Qqk3cGqZ17CFPJGQt5IG2EUiDiPmcY1(mD5YHIdY1Uym5ETNBLY1UcCcnx9qZ1U4Z5IBJcCcMlcmf4eeJC9zcRCbZDXGMBLYfmbjfn3U456DUFvoxLlxFMYf3gf4emxeykWjyU1YyetMvUl9bE0c2gcKcvJcCmkak0Jr4LJA5bmkakyFwmuGRaxUxlpGHmSmeibCf6emQCxWtp5Zk8Lay3YdpzkEfkA1qXHaPq1Oapm1TrU3NiKPk3L(Idbsv1yIKTeV4Y9(KPk3L(Ityb7QrbEuUWWiVZ(ZAzmIZK6Y9gktXYeo4OCx6loeivvJjs2s8Il37tMwlJrCU9aWHKYySmHdok3L(Ityb7QrbEuUWWiVZ(ZAzmIZK6Y9gktXY0tMwlJrCU9aWHKYySmHOKzeNlteFlO5Y1Pj5EZLjfiLlUnkWZLpRWxcKR9zXq5YN17iJCV5ICwgUCV5IGB7emzw5U0h4rlyBiqkunkWXOaOG9zXqbUcC5ET8agYWIYDPViywgUCVHP2obJKTeV4Y9(CumMaK4Zk8LcU8jCPCx6lcMLHl3ByQTtWOlCgdqcTWDPVN1YyeNBpaCiPmgrB73tx(e2FWktMvUl9bE0c24QXeuUl9fmcWX40pzb46HQq0aSD1L(WqgwWRqrRgk6YNcEh49VwaU0h2TYN1YyeHLJc9im12jyeTTFjZk3L(apAbBaEd5ZjZjZk3L(arL7cEk4QHohyXi4L7nu7Ffdzyr5UGNc0rFHay)HN1Yye59VwaU0xeTTFpriEfkA1qrx(uW7aV)1cWL(WoVBdAB)IgbVCVHA)Rr0cuDPpCWbVcfTAOOlFk4DG3)Ab4sF4YIvIOKzL7sFGOYDbpfC1qNdE0c2(KtnedzybVcfTAOOlFk4DG3)Ab4sF4YIvIdoiK3TbTTFXp5udJOfO6sF4cVcfTAOOlFk4DG3)Ab4sFpzQRg68iSCuOhHP2obreo44QHopclhf6ryQTtWN1YyeHLJc9im12jySm9eVcfTAOOlFk4DG3)Ab4sFyx5U0x8to1WiVBdAB)WbNH8o7bi9v5a4cVcfTAOOlFk4DG3)Ab4sFjZk3L(arL7cEk4QHoh8OfSHc13(aHkKuFgdzyXvdDEunKTahQae4uqyuGy9eH1Yye59VwaU0xeTTFpzATmgX52dahskJXYeIsMtMvUl9bI8(xlax6lW72G22pGLP2L(sMvUl9bI8(xlax6lW72G22pWJwWw10nAyuGyLmRCx6de59VwaU0xG3TbTTFGhTGTkbbeKr5EXqgwQLXiY7FTaCPVyzkzw5U0hiY7FTaCPVaVBdAB)apAbBdbsvt3OjZk3L(arE)RfGl9f4DBqB7h4rlytpobCOAcC1ysMvUl9bI8(xlax6lW72G22pWJwWMlFkyxHtyidlWYrJg(srN(tnunb7kC6zTmgrY2zTaCPVyzkzw5U0hiY7FTaCPVaVBdAB)apAbBfafeN(yqJbX9WPFYYRrrf1Biiuv0xkzw5U0hiY7FTaCPVaVBdAB)apAbBfafeN(yC6NSihGdlUwnuaZu0Zl)akHx4uYSYDPpqK3)Ab4sFbE3g02(bE0c2kakio9X40pzzy0pf6rOQUBOKzL7sFGiV)1cWL(c8UnOT9d8OfSvauqC6JXPFYIDLr6iiimG9HMmRCx6de59VwaU0xG3TbTTFGhTGTcGcItFmo9twKd4Wc3BiiGk4LJcvYysMvUl9bI8(xlax6lW72G22pWJwWwbqbXPpgN(jlGYvnDJg0p5Zyb8KzL7sFGiV)1cWL(c8UnOT9d8OfSvauqC6dsMtMvUl9bI8(xlax6lmnRaYIrENDqaZDb99tNJHmSulJrK3)Ab4sFr02(LmJ4CTMbU8vNYDUTNRPV3CTA)RfGl9LRDXyY1OapxFwpgb56DUilxUyUK7ftGCXTHaa5EZ17CrjNGF5OCNB75YKcKYf3gf4GCbZDXGMBLYTai0yYmIrCUk3L(arE)RfGl9fMMva9OfSHxHIwnegfaf6Xi8YrT8agfafSplgkWvGl3RLhW40pzHS1PdLqd8(xlax6laPVkhaJEYcGCmWRMczPwgJiV)1cWL(Iq6RYbESwgJiV)1cWL(IOfO6sF2eeY72G22ViV)1cWL(Iq6RYbWvTmgrE)RfGl9fH0xLdGimKHfEFOfXJYni4PMaxbCfLsMrCUmruuqU(mLlAbQU0xU9ixFMYfz5YfZLCVycKlUneai3BUwT)1cWL(Y17C9zkx6qZTh56ZuU8cesNNRv7FTaCPVCLrU(mLlxbEU27IbnxE)NmKt5IwGY9MRplGCTA)RfGl9ftMrmIZv5U0hiY7FTaCPVW0ScOhTGn8ku0QHWOaOqpgHxoQLhWOaOG9zXqbUcC5ET8agN(jlKToDOeAG3)Ab4sFbi9v5ay0twuuumWRMczbVcfTAOiGXAaTavx6ddzyH3hAr8OCdcEQjWvaxrPNiSwgJiOCbgL7feQgcaK7najffRyzchCWRqrRgks260HsObE)RfGl9fG0xLdG9hI2Sn5LJg)QT2eewlJreuUaJY9ccvdbaY9g)QTbGRCgT(AzmIGYfyuUxqOAiaqU3iWvoJicrjZk3L(arE)RfGl9fMMva9OfSv13qpcou4mcWqgwQLXiY7FTaCPViAB)sMvUl9bI8(xlax6lmnRa6rlyZi4L7nu7Ffdzyr5UGNc0rFHay)HN1Yye59VwaU0xeTTFjZioxMqXN7INR1(ge8utUwvbCfLWixm3fGNBbq5YKcKYf3gf4GCTptxU(mHvU27dtEU)YXNZLdfhKREO5AFMUCzsbsaVH)CfqUOT9lMmRCx6de59VwaU0xyAwb0JwW2qGuOAuGJrbqHEmcVCulpGrbqb7ZIHcCf4Y9A5bmKHfMY7dTiEuUbbp1e4kGRO0t(ScFja2T8WZAzmI8(xlax6lwMEY0AzmIdbsaVH)yz6jtRLXio3Ea4qszmwMEo3Ea4qszmaMiJbeKlmmY7S)yTmgXzsD5EdLPyzcx2izgX5Yek(CUw7BqWtn5AvfWvucJCzsbs5IBJc8ClakxWCxmO5wPCvuuXL(uJbRC59bCOkhHMlOZ1NvpxXZva5ETNBLYTai0ClNHaGCT23GGNAY1QkGROuUcixT2fpxVZLSDsGuUnmxFMGuUkKY93qkxFwVCPRlVZ5YKcKYf3gf4GC9oxYwNo0CT23GGNAY1QkGROuUENRpt5shAU9ixR2)Ab4sFXKzeJ4CvUl9bI8(xlax6lmnRa6rlydVcfTAimkak0Jr4LJA5bmkakyFwmuGRaxUxlpGXPFYcz7eXDcnmeifQgf4am6jlaYXaVAkKfL7sFXHaPq1OapYNv4lbcdOYDPp18icXRqrRgks260HsObE)RfGl9fG0xLdy91YyeLBqWtnbUc4kkfrlq1L(qK1iVBdAB)IdbsHQrbEeTavx6ddzyH3hAr8OCdcEQjWvaxrPKzeJ4CvUl9bI8(xlax6lmnRa6rlydVcfTAimkak0Jr4LJA5bmkakyFwmuGRaxUxlpGXPFYYrekHggcKcvJcCag9Kfa5yGxnfYcNedcXRqrRgks260HsObE)RfGl9fG0xLdynIWAzmIYni4PMaxbCfLIOfO6sFw)lhn(vBreIWqgw49Hwepk3GGNAcCfWvukzw5U0hiY7FTaCPVW0ScOhTGTHaPq1OahJcGc9yeE5OwEaJcGc2Nfdf4kWL71Ydyidl8(qlIhLBqWtnbUc4kk9KpRWxcGDlp8eH4vOOvdfjBNiUtOHHaPq1OahGDl4vOOvdfpIqj0WqGuOAuGdWbNAzmI8(xlax6lcPVkhaxVC04xTfhCWRqrRgks260HsObE)RfGl9fG0xLdGll1YyeLBqWtnbUc4kkfrlq1L(WbNAzmIYni4PMaxbCfLIax5mIlBGdo1YyeLBqWtnbUc4kkfH0xLdGRxoA8R2Ido8UnOT9lcMLHl3ByQTtWiKuuSEQCxWtb6OVqaSBbVcfTAOiV)1cWL(cGzz4Y9gMA7e8jVXtNEE8K3zpmucrpRLXiY7FTaCPVyz6jczATmgXHajG3WFesk3XbNAzmIYni4PMaxbCfLIq6RYbWLvgTze9KP1YyeNBpaCiPmgHKY9NZThaoKugdGjYyab5cdJ8o7pwlJrCMuxU3qzkcjL74YgjZk3L(arE)RfGl9fMMva9OfSXvJjOCx6lyeGJXPFYIYDbpfC1qNdsMvUl9bI8(xlax6lmnRa6rlyJ3)Ab4sFyuauOhJWlh1YdyuauW(SyOaxbUCVwEadzyzU9aWHKYyamrgdiixyyK3z3Iv(SwgJiV)1cWL(IOT97jEfkA1qrx(uW7aV)1cWL(WLfR8jczkSC0OHVuevaCzYiNcXkW7)xpuCWPwgJiQa4YKrofIvG3)VEOXYeo4ulJrevaCzYiNcXkW7)xp0Wa2apwME6QHopclhf6ryQTtWN8UnOT9lwlJravaCzYiNcXkW7)xp0iKuuSq0teYuy5OrdFP4luagSccx4gchCqPAzmIVqbyWkiCHBOyzcrprit5nE60ZJhXHTPHO4GdVBdAB)IOK6Z1gEuesFvoao4ulJreLuFU2WJILje9eHmL34PtppINoFglio4W72G22V4xGWgcc9i4n8tNhH0xLdGONiu5U0x8to1WOCHHrEN9Nk3L(IFYPggLlmmY7ShG0xLdGll4vOOvdf59VwaU0xGRapaPVkhahCuUl9fb8gYNJKTeV4Y9(u5U0xeWBiFos2s8Itbi9v5a4cVcfTAOiV)1cWL(cCf4bi9v5a4GJYDPV4qGuvnMizlXlUCVpvUl9fhcKQQXejBjEXPaK(QCaCHxHIwnuK3)Ab4sFbUc8aK(QCaCWr5U0xCclyxnkWJKTeV4Y9(u5U0xCclyxnkWJKTeV4uasFvoaUWRqrRgkY7FTaCPVaxbEasFvoao4OCx6lom6NaouyKIKTeV4Y9(u5U0xCy0pbCOWifjBjEXPaK(QCaCHxHIwnuK3)Ab4sFbUc8aK(QCaeLmJ4CXS9zcMlVBdAB)a56ZQNlyUlg0CRuUfaHMRDXNZ1Q9VwaU0xUG5UyqZTpdw5wPClacnx7IpNRE5QCVOMCTA)RfGl9LlxbEU6HM71EU2fFoxnxKLlxmxY9IjqU42qaGCV5obBEmzw5U0hiY7FTaCPVW0ScOhTGnUAmbL7sFbJaCmo9tw49VwaU0xG3TbTTFamKHLAzmI8(xlax6lcPVkha7yw4GdVBdAB)I8(xlax6lcPVkhax2CYSYDPpqK3)Ab4sFHPzfqpAbBdJ(jGdfgjmKHfewlJrCU9aWHKYySm9u5UGNc0rFHay3cEfkA1qrE)RfGl9fgg9tahkmsichCqyTmgXHajG3WFSm9u5UGNc0rFHay3cEfkA1qrE)RfGl9fgg9tahkmswpSC0OHVuCiqc4n8JOKzeNlcKIk655ICsHmMlyUlg0CRuUfaHMRDXNZvZfbT9Cr6qszmxiPOyLR35wauUY)tOI6KbRC1HtWC9zkxUc8ChYjGzceZLbZcix7IXK7PEbQgdw5cip3YuUAUiOTNlshskJ5cMOZZD0WC9zk3HCQjxGRCgZTh5IaPOIEEUiNuiJXKzL7sFGiV)1cWL(ctZkGE0c2GkQONhatkKrmKHLAzmI8(xlax6lwMEAdBsTmgX52dahskJriPC)XAzmIZK6Y9gktriPC)X52dahskJbWezmGGCHHrENDl2izw5U0hiY7FTaCPVW0ScOhTGTjSGD1OahdzyPwgJ4qGeWB4pwMsMvUl9bI8(xlax6lmnRa6rlyBclyxnkWXqgwQLXio3Ea4qszmwMEwlJrK3)Ab4sFXYuYSYDPpqK3)Ab4sFHPzfqpAbBtyb7QrbogYWYeKWhE5OXhIaEd5ZpRLXiotQl3BOmfltpvUl4PaD0xiaUWRqrRgkY7FTaCPVWWOFc4qHr6zTmgrE)RfGl9fltjZk3L(arE)RfGl9fMMva9OfSblhf6ryQTtqmKHLAzmIGYfyuUxqOAiaqU3aKuuSILPN1YyeHLJc9im12jyesFvoaUuUl9fNWc2vJc8ixbEWLp9SwgJiOCbgL7feQgcaK7najffRiK(QCaSRCx6loHfSRgf4rUc8GlF6rYwIxCk4YNsMrCUiia5EZf5SmC5EZfb32jyUOfOCV5A1(xlax6lxVZfsaVHuUmPaPCXTrbEU6HMlcEUPtSnxM0OFkx(ScFjqUC9YTs5wPJgcxudg5wlEUfqrngSYTpdw52xUmX2AoMmRCx6de59VwaU0xyAwb0JwWgywgUCVHP2obXqgwQLXiY7FTaCPVyz6jtvUl9fhcKcvJc8iFwHVe4PYDbpfOJ(cbWUf8ku0QHI8(xlax6laMLHl3ByQTtWNk3L(ItZnDITHHr)eiYNv4lbWLYDPV40CtNyByy0pbIF12aFwHVeizw5U0hiY7FTaCPVW0ScOhTGTHr)eWHcJegYWIYDbpfOJ(cbWUf8ku0QHI8(xlax6lmm6NaouyKEwlJreuUaJY9ccvdbaY9gGKIIvSm9SwgJiOCbgL7feQgcaK7najffRiK(QCaSZvGhC5tprit59Hwepk3GGNAcCfWvuchCQLXik3GGNAcCfWvukcPVkha7KTeV4uWLpHdo1YyeNj1L7nuMIqs5(JZThaoKugdGjYyab5cdJ8o74Ygikzw5U0hiY7FTaCPVW0ScOhTGTjSGD1OahdzyPwgJiOCbgL7feQgcaK7najffRyz6zTmgrq5cmk3liuneai3Baskkwri9v5ayNRap4YNEIqMY7dTiEuUbbp1e4kGROeo4ulJruUbbp1e4kGROuesFvoa2jBjEXPGlFchCQLXiotQl3BOmfHKY9hNBpaCiPmgatKXacYfgg5D2XLnquYSYDPpqK3)Ab4sFHPzfqpAbBtyb7QrbogYWsTmgXjSGn3OGFesk3FwlJrCclyZnk4hH0xLdGDUc8GlF6jcRLXiY7FTaCPViK(QCaSZvGhC5t4GtTmgrE)RfGl9frB7hIEQCxWtb6OVqaCHxHIwnuK3)Ab4sFHHr)eWHcJ0teYuEFOfXJYni4PMaxbCfLWbNAzmIYni4PMaxbCfLIq6RYbWozlXlofC5t4GtTmgXzsD5EdLPiKuU)4C7bGdjLXayImgqqUWWiVZoUSbIsMvUl9bI8(xlax6lmnRa6rlyBAUPtSnmm6Nayidl1Yye59VwaU0xSm90HkEYeC5t4QwgJiV)1cWL(Iq6RYbEwlJrCMuxU3qzkcjL7po3Ea4qszmaMiJbeKlmmY7SJlBKmRCx6de59VwaU0xyAwb0JwW2WOFc4qHrcdzyPwgJiV)1cWL(IOT97jVBdAB)I8(xlax6lcPVkhaxCf4bx(0tL7cEkqh9fcGDl4vOOvdf59VwaU0xyy0pbCOWiLmRCx6de59VwaU0xyAwb0JwW2qGuvngmKHLAzmI8(xlax6lI22VN8UnOT9lY7FTaCPViK(QCaCXvGhC5tpzkVp0I4XHr)uq5Ci5sFjZk3L(arE)RfGl9fMMva9OfSb4nKpJHmSulJrK3)Ab4sFri9v5ayNRap4YNEwlJrK3)Ab4sFXYeo4ulJrK3)Ab4sFr02(9K3TbTTFrE)RfGl9fH0xLdGlUc8GlFkzw5U0hiY7FTaCPVW0ScOhTGnJGxU3qT)vmKHLAzmI8(xlax6lcPVkhaxVC04xT9PYDbpfOJ(cbW(djZk3L(arE)RfGl9fMMva9OfSHc13(aHkKuFgdzyPwgJiV)1cWL(Iq6RYbW1lhn(vBFwlJrK3)Ab4sFXYuYCYmIZfbLmtemx8ku0QHY1NvpxEFUkhixFMYv5Ern5sax(QtO56YNY1NvpxFMY9iB9CTA)RfGl9LRDXyYTs5cjffRyYmIrCUk3L(arE)RfGl9fC5l3Rf8ku0QHW40pzH3)Ab4sFbiPOyfC5tyGxnfYcVBdAB)I8(xlax6lcPVkhWMq2orCNqdmkhQrU3aKqlCx6lzgX5YGzkxUc8CD5t52JC9zkxWezm56ZQNRDXyYTs5objUc8CLZ7CTA)RfGl9ftMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fMGexbEWLpHbE1uiliu5U0xCiqQQgtKRap4YNSjmL3hAr84WOFkOCoKCPVhvUl9fb8gYNJCf4bx(0J8(qlIhhg9tbLZHKl9HiBccvUl4PaD0xiaUWRqrRgkY7FTaCPVWWOFc4qHrcrpQCx6lom6NaouyKICf4bx(KnbHk3f8uGo6lea7wWRqrRgkY7FTaCPVWWOFc4qHrcrwpEfkA1qrE)RfGl9f4kWdq6RYbsMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fC5tyGxnfYcEfkA1qrE)RfGl9fGKIIvWLpLmJ4CTwKrXkxR2)Ab4sF5oAyU6WjyUmPajGRqNG5wodba5IxHIwnuCiqc4k0jyG3)Ab4sF5kGCbKhtMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fC5ty0tw(QTyGxnfYYqGeWvOtWiK(QCamKHfxn05XHajGRqNGpzkEfkA1qXHajGRqNGbE)RfGl9LmJ4CTwKrXkxR2)Ab4sF5oAyUiqkQONNlYjfYyUYixXZ1Uym5Y7pLBpg5Y72G22VCbDFXKzeJ4CvUl9bI8(xlax6l4YxU3hTGn8ku0QHW40pzH3)Ab4sFbx(eg9KLVAlg4vtHSW72G22Viurf98aysHmgH0xLdGHmSWB80PNhzelOO3tE3g02(fHkQONhatkKXiK(QCaR)bRex4vOOvdf59VwaU0xWLpLmJ4CTwKrXkxR2)Ab4sF5oAyUiWeiSHGC7rUmOHF68KzeJ4CvUl9bI8(xlax6l4YxU3hTGn8ku0QHW40pzH3)Ab4sFbx(eg9KLVAlg4vtHSW72G22V4xGWgcc9i4n8tNhH0xLdGHmSWB80PNhXtNpJf8jVBdAB)IFbcBii0JG3WpDEesFvoG1BdBgx4vOOvdf59VwaU0xWLpLmJ4CTwKrXkxR2)Ab4sF5oAyUwls95AdpkMmJyeNRYDPpqK3)Ab4sFbx(Y9(OfSHxHIwnegN(jl8(xlax6l4YNWONS8vBXaVAkKfE3g02(frj1NRn8OiK(QCGhryTmgrus95AdpkIwGQl9z91Yye59VwaU0xeTavx6dr2ey5OrdFPikP(mimuFU)yidl8gpD65XJ4W20q0N8UnOT9lIsQpxB4rri9v5aw)dwjUWRqrRgkY7FTaCPVGlFkzgX5ATiJIvUwT)1cWL(YD0WCTwK6ZycKltQ(C)Zf4kNrqUYixFMGuUkKYv9CnKc8CD7DUUcFjhetMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fC5ty0tw(QTyGxnfYsTmgrus95AdpkcPVkhW6RLXiY7FTaCPViAbQU0hgYWcSC0OHVueLuFgegQp3)N1Yyerj1NRn8Oyz6PYDbpfOJ(cbWUfBKmJ4CTwKrXkxR2)Ab4sF5oAyU(mLR18FcliPMCXSHONECk3AzmYvg56ZuUtgflcMRaYTaK7nxFw9CDOCmsEmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimo9tw49VwaU0xWLpHrpz5R2IbE1uil4vOOvdfP)ewqsnHgIE6XPakzuSSEeY72G22Vi9NWcsQj0q0tpofrlq1L(SEE3g02(fP)ewqsnHgIE6XPiK(QCaeztykVBdAB)I0FcliPMqdrp94ueskkwyidleMPitteAK(tybj1eAi6PhNsMrCUwlYOyLRv7FTaCPVChnmxBkJIkQ3qqU4wrFjmYTCgcaYv8CT3fdAUvkxuYOyrO5A67LG56Z6LRnSYCbeVpuqmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimo9tw49VwaU0xWLpHrpz5R2IbE1uil8UnOT9l(Auur9gccvf9LIq6RYbWqgwimtrMMi04Rrrf1Biiuv0x6jVBdAB)IVgfvuVHGqvrFPiK(QCaR3gwjUWRqrRgkY7FTaCPVGlFkzgX5ATiJIvUwT)1cWL(YTCUyYfbQrW5s2ojqcKRmYvCmbYTmftMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fC5ty0tw(QTyGxnfYsTmgry5OqpctTDcgH0xLdGHmS4QHopclhf6ryQTtWN1Yye59VwaU0xeTTFjZioxRfzuSY1Q9VwaU0xUJgMRE5s26qnxeOYr52JCrWTDcMRmY1NPCrGkhLBpYfb32jyU27IbnxE)PC7XixE3g02(LR65Aif45AZ5ciEFOGCR0OHuUwT)1cWL(Y1ExmOXKzeJ4CvUl9bI8(xlax6l4YxU3hTGn8ku0QHW40pzH3)Ab4sFbx(eg9KLVAlg4vtHSW72G22ViSCuOhHP2obJq6RYbESwgJiSCuOhHP2obJOfO6sFyidlUAOZJWYrHEeMA7e8zTmgrE)RfGl9frB73tE3g02(fHLJc9im12jyesFvoWJ2mUWRqrRgkY7FTaCPVGlFkzgX5ATiJIvUwT)1cWL(Yvg5ATeaxMmYPqSY1Q9)RhAU27Ibn3R9CRuUqsrXk3rdZv8CXI8yYmIrCUk3L(arE)RfGl9fC5l37JwWgEfkA1qyC6NSW7FTaCPVGlFcJEYYxTfd8QPqw4DBqB7xSwgJaQa4YKrofIvG3)VEOri9v5ayidlWYrJg(srubWLjJCkeRaV)F9qFwlJrevaCzYiNcXkW7)xp0iAB)sMrCUiqQGMR1mE6CG1LR1Imkw5A1(xlax6l3rdZvrrZfmP2pqU9ixmFUnm3FdPCvuuqU(S65AxmMCnkWZ103lbZ1N1l3hS5CbeVpuqmxgmtakx8QPqGCviDyYZ9iobakumyLBp5Yxn5kxUQXKlxbeiMmJyeNRYDPpqK3)Ab4sFbx(Y9(OfSHxHIwnegN(jl8(xlax6l4YNWONS8vBXaVAkKfOkObcpDEurrbr5WqgwGQGgi805rfffejBfGdEcvbnq4PZJkkkiY7Y5y3cM)juf0aHNopQOOGiAbQU0h2FWMtMrCUiqQGMR1mE6CG1Llt0yxXcKBbq5A1(xlax6lx7IpNl(I5iOwfJ4yLluf0Cj805amYTXtqOGs5Qhw5IsgflqUgb4eAUATXt56DUFLrkxqbs5kEUVKdYTai0CNjiftMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fC5tyGxnfYcuf0aHNopIVyocQvdfLZMWuOkObcpDEeFXCeuRgkwMWqgwGQGgi805r8fZrqTAOizRaCWt8ku0QHI8(xlax6lajffRGlFcxqvqdeE68i(I5iOwnuuUKzeNlccGY1NPCpYwpxR2)Ab4sF52xU8UnOT9lxzKR45AVlg0CV2ZTs5s2orCNqZ17CrjJIvU(mLlGptOfdHMBFuUnmxFMYfWNj0IHqZTpkx7DXGM7SonrxUgcaY1N1lxByL5ciEFOGCR0OHuU(mL7qEN9CPdfetMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fC5tyGxnfYcEfkA1qrE)RfGl9fGKIIvWLpHHmSGxHIwnuK3)Ab4sFbiPOyfC5tpY72G22ViV)1cWL(IOfO6sF2ee(G1JqRmAn8OvgTHnXvdDECiqc4k0jiISjUAOZJmkhQrUxeHll4vOOvdf59VwaU0xWLpHdo4vOOvdf59VwaU0xWLpH9H8o7bi9v5awVnSYKzeNltefnxFMYLxGq68CD5t56DU(mLlGptOfdHMRv7FTaCPVC9o3PINR45kxUAf0MIt56YNYf056ZQNR45kGCbUym5QCEbQoLRoCcMRMRrC3q56YNYDsbacetMrmIZv5U0hiY7FTaCPVGlF5EF0c2WRqrRgcJt)KfE)RfGl9fC5ty0twuuumWRMczXLpLmJ4Czs5uJblmYL3hEc65oG9pxTcAtXPCD5t5QhAUaVHuU(mLlKmQl4PCD5t5kxU4vOOvdfD5tbVd8(xlax6lMlcYzegPC9zkxib8C7rU(mLlxn8IrDPpag5AFw4Z5oRtt0LRHaGChqcZuOZnyLR35cMicn3YuU(mLlq(fJ6sFyKRplGCN1Pj6a52JH1BtzvRvU6HMR9zXq5YvGl3BmzgXioxL7sFGiV)1cWL(cU8L79rlydVcfTAimkak0Jr4LJA5bmkakyFwmuGRaxUxlpGXPFYIlFk4DG3)Ab4sFyGxnfYccXRqrRgkY7FTaCPVGlFY6D5tiYMulJrK3)Ab4sFr02(LmNmRCx6deH9uyAwbKLHr)eWHcJegYWIYDbpfOJ(cbWUf8ku0QHIZThaoKugddJ(jGdfgPNiSwgJ4C7bGdjLXyzchCQLXioeib8g(JLjeLmRCx6deH9uyAwb0JwW2qGuvngmKHLAzmIOK6Z1gEuSm9ewoA0WxkIsQpdcd1N7)t8ku0QHIU8PG3bE)RfGl9HRAzmIOK6Z1gEuesFvoWtL7cEkqh9fcGDl2izw5U0hic7PW0ScOhTGTHr)eWHcJegYWIYDbpfOJ(cbWUf8ku0QHIZkenWvGhgg9tahkmspRLXickxGr5EbHQHaa5EdqsrXkwMEwlJreuUaJY9ccvdbaY9gGKIIvesFvoa25kWdU8PKzL7sFGiSNctZkGE0c2MWc2vJcCmKHLAzmIGYfyuUxqOAiaqU3aKuuSILPN1YyebLlWOCVGq1qaGCVbiPOyfH0xLdGDUc8GlFkzw5U0hic7PW0ScOhTGTjSGD1OahdzyPwgJ4qGeWB4pwMsMvUl9bIWEkmnRa6rlyBclyxnkWXqgwQLXio3Ea4qszmwMsMrCUiiak3(OCzsbs5IBJc8CjfAWkx5YfbQrW5kJCXQl5I2hM8CNv8uUK4ZemxeusD5EZfbzk3gMlcA75I0HKYyUyrEU6HMlj(mbTUCrOIOCNv8uU)gs56Z6LRBVZvnqsrXcJCryfr5oR4PCzIgYwGdvacCkMa5YKfiw5cjffRC9o3cGWi3gMlc5ikxKKcL7nxg0f(CUcixL7cEkMR1Qpm55I256Zcix7ZIHYDwHO5YvGl3BUmPr)eWHcJei3gMR9z6Yfz5YfZLCVycKlUneai3BUcixiPOyftMvUl9bIWEkmnRa6rlyBiqkunkWXOaOqpgHxoQLhWOaOG9zXqbUcC5ET8agYWctXRqrRgkoeifQgf4HPUnY9(SwgJiOCbgL7feQgcaK7najffRiAB)EQCxWtb6OVqaCHxHIwnuCwHObUc8WWOFc4qHr6jthcKaUcDcgvUl4PNiKP1YyeNj1L7nuMILPNmTwgJ4C7bGdjLXyz6jtNGe(qpgHxoACiqkunkWFIqL7sFXHaPq1OapYNv4lbWUfBGdoi0vdDEunKTahQae4uqyuGy9K3TbTTFruO(2hiuHK6ZriPOyHiCWbqkuU3G3f(Cu5UGNqeIsMrCUiiakxMuGuU42Oapxs8zcMlAbk3BUAUmPaPQAmydbJfSRgf45YvGNR9z6YfbLuxU3CrqMYva5QCxWt52WCrlq5EZLSL4fNY1U4Z5IKuOCV5YGUWNJjZk3L(arypfMMva9OfSneifQgf4yuauOhJWlh1YdyuauW(SyOaxbUCVwEadzyHP4vOOvdfhcKcvJc8Wu3g5EFY0HajGRqNGrL7cE6zTmgrq5cmk3liuneai3Baskkwr02(9eHieHk3L(Idbsv1yIKTeV4Y9(eHk3L(Idbsv1yIKTeV4uasFvoaUSYOnJdomfwoA0Wxkoeib8g(reo4OCx6loHfSRgf4rYwIxC5EFIqL7sFXjSGD1Oaps2s8Itbi9v5a4YkJ2mo4Wuy5OrdFP4qGeWB4hri6zTmgXzsD5EdLPiKuUJiCWbHasHY9g8UWNJk3f80tewlJrCMuxU3qzkcjL7pzQYDPViG3q(CKSL4fxUxCWHP1YyeNBpaCiPmgHKY9NmTwgJ4mPUCVHYuesk3FQCx6lc4nKphjBjEXL79jtNBpaCiPmgatKXacYfgg5D2reIquYSYDPpqe2tHPzfqpAbBC1yck3L(cgb4yC6NSOCxWtbxn05GKzL7sFGiSNctZkGE0c2MWc2vJcCmKHLAzmItybBUrb)iKuU)KRap4YNWvTmgXjSGn3OGFesFvoWtUc8GlFcx1YyeHLJc9im12jyesFvoWteYuy5OrdFPiOCbgL7feQgcaK7fhCQLXioHfS5gf8Jq6RYbWLYDPV4qGuvnMixbEWLp9ixbEWLpztQLXioHfS5gf8Jqs5oIsMvUl9bIWEkmnRa6rlyBclyxnkWXqgwQLXio3Ea4qszmwMEcifk3BW7cFoQCxWtpvUl4PaD0xiaUWRqrRgko3Ea4qszmmm6NaouyKsMvUl9bIWEkmnRa6rlyBAUPtSnmm6NayidlmfVcfTAO40CtNyByQBJCVpRLXiotQl3BOmfltpzATmgX52dahskJXY0teQCxWtb02JY7joHlBGdok3f8uGo6lea7wWRqrRgkoRq0axbEyy0pbCOWiHdok3f8uGo6lea7wWRqrRgko3Ea4qszmmm6NaouyKquYSYDPpqe2tHPzfqpAbBaEd5ZyidlasHY9g8UWNJk3f8uYSYDPpqe2tHPzfqpAbBOq9TpqOcj1NXqgwuUl4PaD0xia2TrYSYDPpqe2tHPzfqpAbBkKRhfiBNmnq6ddzyr5UGNc0rFHay3cEfkA1qrfY1JcKTtMgi998RNgN4o2TGxHIwnuuHC9Oaz7KPbsFHVE6txHVKhTl(SCpyLjZioxMqXNZLUU8oNRRWxYbyKR45kGC1CFv5Y17C5kWZLjn6NaouyKYvb5oeJHG5khWjfn3EKltkqQQgtmzw5U0hic7PW0ScOhTGTHr)eWHcJegYWIYDbpfOJ(cbWUf8ku0QHIZkenWvGhgg9tahkmsjZk3L(arypfMMva9OfSneivvJjzozw5U0hicC9qviAa2U6sFwgg9tahkmsyidlk3f8uGo6lea7wWRqrRgko3Ea4qszmmm6NaouyKEIWAzmIZThaoKugJLjCWPwgJ4qGeWB4pwMquYSYDPpqe46HQq0aSD1L(E0c2gcKQQXGHmSulJreLuFU2WJILPNWYrJg(srus9zqyO(C)FIxHIwnu0Lpf8oW7FTaCPpCvlJreLuFU2WJIq6RYbEQCxWtb6OVqaSBXgjZk3L(arGRhQcrdW2vx67rlyBclyxnkWXqgwQLXioeib8g(JLPKzL7sFGiW1dvHOby7Ql99OfSnHfSRgf4yidl1YyeNBpaCiPmgltpRLXio3Ea4qszmcPVkhaxk3L(Idbsv1yIKTeV4uWLpLmRCx6debUEOkenaBxDPVhTGTjSGD1OahdzyPwgJ4C7bGdjLXyz6jcNGe(Wlhn(qCiqQQgdo4meibCf6emQCxWt4GJYDPV4ewWUAuGhLlmmY7SJOKzeNldGyLR35(sEUiXCH7CNGnhKRCabLYfbQrW5onRacKBdZ1Q9VwaU0xUtZkGa5AFMUCNAaqQgkMmRCx6debUEOkenaBxDPVhTGTHr)eWHcJegYWIYDbpfOJ(cbWUf8ku0QHIZkenWvGhgg9tahkmspRLXickxGr5EbHQHaa5EdqsrXkwMEIqE3g02(fHLJc9im12jyesFvoWJk3L(IWYrHEeMA7ems2s8Itbx(0JCf4bx(e2RLXickxGr5EbHQHaa5EdqsrXkcPVkhahCyQRg68iSCuOhHP2obr0t8ku0QHIU8PG3bE)RfGl99ixbEWLpH9AzmIGYfyuUxqOAiaqU3aKuuSIq6RYbsMvUl9bIaxpufIgGTRU03JwW2ewWUAuGJHmSulJrCU9aWHKYySm9eqkuU3G3f(Cu5UGNsMvUl9bIaxpufIgGTRU03JwW2ewWUAuGJHmSulJrCclyZnk4hHKY9NCf4bx(eUQLXioHfS5gf8Jq6RYbEIqMclhnA4lfbLlWOCVGq1qaGCV4GtTmgXjSGn3OGFesFvoaUuUl9fhcKQQXe5kWdU8Ph5kWdU8jBsTmgXjSGn3OGFesk3ruYmIZ1AvGY9MRpt5cC9qviAUW2vx6dJC7ZGvUfaLltkqkxCBuGdY1(mD56Zew5Qqk3R9CRKCV5o1THqZD0WCrGAeCUnmxR2)Ab4sFXCrqauUmPaPCXTrbEUK4Zemx0cuU3C1Czsbsv1yWgcglyxnkWZLRapx7Z0LlckPUCV5IGmLRaYv5UGNYTH5IwGY9MlzlXloLRDXNZfjPq5EZLbDHphtMvUl9bIaxpufIgGTRU03JwW2qGuOAuGJrbqHEmcVCulpGrbqb7ZIHcCf4Y9A5bmKHfMoeibCf6emQCxWtpzkEfkA1qXHaPq1Oapm1TrU3N1YyebLlWOCVGq1qaGCVbiPOyfrB73teIqeQCx6loeivvJjs2s8Il37teQCx6loeivvJjs2s8Itbi9v5a4YkJ2mo4Wuy5OrdFP4qGeWB4hr4GJYDPV4ewWUAuGhjBjEXL79jcvUl9fNWc2vJc8izlXlofG0xLdGlRmAZ4GdtHLJgn8LIdbsaVHFeHON1YyeNj1L7nuMIqs5oIWbhecifk3BW7cFoQCxWtpryTmgXzsD5EdLPiKuU)KPk3L(IaEd5ZrYwIxC5EXbhMwlJrCU9aWHKYyesk3FY0AzmIZK6Y9gktriPC)PYDPViG3q(CKSL4fxU3NmDU9aWHKYyamrgdiixyyK3zhricrjZk3L(arGRhQcrdW2vx67rlyBclyxnkWXqgwQLXio3Ea4qszmwMEQCxWtb6OVqaCHxHIwnuCU9aWHKYyyy0pbCOWiLmRCx6debUEOkenaBxDPVhTGTP5MoX2WWOFcGHmSWu8ku0QHItZnDITHPUnY9(eHm1vdDECa7FWNPGcMjao4OCxWtb6OVqaS)aIEIqL7cEkG2EuEpXjCzdCWr5UGNc0rFHay3cEfkA1qXzfIg4kWddJ(jGdfgjCWr5UGNc0rFHay3cEfkA1qX52dahskJHHr)eWHcJeIsMvUl9bIaxpufIgGTRU03JwWgxnMGYDPVGraogN(jlk3f8uWvdDoizw5U0hicC9qviAa2U6sFpAbBOq9TpqOcj1NXqgwuUl4PaD0xia2Fizw5U0hicC9qviAa2U6sFpAbBaEd5ZyidlasHY9g8UWNJk3f8uYSYDPpqe46HQq0aSD1L(E0c2uixpkq2ozAG0hgYWIYDbpfOJ(cbWUf8ku0QHIkKRhfiBNmnq675xpnoXDSBbVcfTAOOc56rbY2jtdK(cF90NUcFjpAx8z5EWktMrCUmHIpNlDD5DoxxHVKdWixXZva5Q5(QYLR35YvGNltA0pbCOWiLRcYDigdbZvoGtkAU9ixMuGuvnMyYSYDPpqe46HQq0aSD1L(E0c2gg9tahkmsyidlk3f8uGo6lea7wWRqrRgkoRq0axbEyy0pbCOWiLmRCx6debUEOkenaBxDPVhTGTHaPQAmSibteNLHwdyEwN1zzb]] )
end
