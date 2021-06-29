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
    -- actions.precombat+=/variable,name=hot_streak_flamestrike,op=set,if=talent.flame_patch,value=2,value_else=3
    spec:RegisterVariable( "hot_streak_flamestrike", function ()
        if talent.flame_patch.enabled then return 2 end
        return 3
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Hard Cast Flamestrikes outside of Combustion should be used as filler.
    -- actions.precombat+=/variable,name=hard_cast_flamestrike,op=set,if=talent.flame_patch,value=2,value_else=3
    spec:RegisterVariable( "hard_cast_flamestrike", function ()
        if talent.flame_patch.enabled then return 2 end
        return 3
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

    -- # APL Variable Option: The number of targets Shifting Power should be used on during Combustion.
    -- actions.precombat+=/variable,name=combustion_shifting_power,default=2,op=reset    
    spec:RegisterVariable( "combustion_shifting_power", function ()
        return 2
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
        if buff.combustion.down then return variable.combustion_time - time end
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
    -- actions+=/variable,name=shifting_power_before_combustion,op=set,value=(active_enemies<variable.combustion_shifting_power|active_enemies<variable.combustion_flamestrike|variable.time_to_combustion-action.shifting_power.full_reduction>cooldown.shifting_power.duration)&variable.time_to_combustion-cooldown.shifting_power.remains>action.shifting_power.full_reduction&(cooldown.rune_of_power.remains-cooldown.shifting_power.remains>5|!talent.rune_of_power)
    spec:RegisterVariable( "shifting_power_before_combustion", function ()
        return ( active_enemies < variable.combustion_shifting_power or active_enemies < variable.combustion_flamestrike or variable.time_to_combustion - action.shifting_power.full_reduction > cooldown.shifting_power.duration ) and variable.time_to_combustion - cooldown.shifting_power.remains > action.shifting_power.full_reduction and ( cooldown.rune_of_power.remains - cooldown.shifting_power.remains > 5 or not talent.rune_of_power.enabled )
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
        if covenant.venthyr and cooldown.mirrors_of_torment.remains - 25 < variable.combustion_time then
            value = max( value, cooldown.mirrors_of_torment.remains )
        end
        
        -- # Delay Combustion for Deathborne.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.deathborne.remains+(buff.deathborne.duration-buff.combustion.duration)*runeforge.deaths_fathom,if=covenant.necrolord&cooldown.deathborne.remains-10<variable.combustion_time
        if covenant.necrolord and cooldown.deathborne.remains - 10 < variable.combustion_time then
            value = max( value, cooldown.deathborne.remains + ( buff.deathborne.duration - buff.combustion.duration ) * runeforge.deaths_fathom.enabled )
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
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 3 ) end
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


    spec:RegisterPack( "Fire", 20210628, [[deLiWeqiIIEeksDjuksBcs8jvPmkvP6uqGvrukEfeYSqrDlIcTlj9lucddfuhtk0Yik5zQsQMgrPQRruW2uLe9nukIXbbjNJOuQ1HIO5Hs09iQ2hkL(heKQoieuwiKKhIcmriO6IqqyJOu4JeLsgjkcCsvjHvIs1lrrqMjksUjeKYoHK6NOuudvvsAPqq0tjYuHqDvueQTsuQ8vueYyrbzVQQ)kvdwXHjTyL8yctgOlJSzaFgsnAvXPPSAueuVwky2O62k1Uv53IgUu64Qsklh0ZHA6uDDj2oe9DPOXRkX5rHwpeKkZhL0(f(34hXFjq1PpQLfdlRgz4xPSqOQY61LLSNHLT)soJT0xQvfnOOPV0PB6lXggK(sTkJ8ub)i(lHZcuqFPh3BXmjlybAZFkRQi3SaB7cxDlpbubCwGTTGfFPvX4(R4(RVeO60h1YIHLvJm8Ruwiuvz96Ys2ZWY6lPf)jHFjjBZGV0Jbcs3F9LajS4lXggKIbHMIMc2FCVfZKSGfOn)PSQICZcSTlC1T8eqfWzb22cweSZE5OyKfcfZXilgwwngShSZGh9qtyMmyxgJHjgtXayOF8oK2QD4yGQ)qWy8h9IXviAYRUTPUNDqJIbiHXWvSlJysKhym6Y4MZymfSIMW1GDzmgMktmDXiuShdKETIbPnDoogGegddY9QGDlVyE3QuL5yaZ7npMNKdgJ5XaKWy0yaGe(jgeAKtjmgHIDeud2LXyqioDXPyWo0eEmIhs0GDOJjVy0yaOMXaKWgWXyxm(dfdc7vzQy8mgibweumntyd8ubRb7YymimqMWfShJgZRYimxCf7XqNdzmg)r9yatchZLEm7eK4X0K48yStgrRBkM3X2ogNWobgJ6XCzmyd9zaMqppge(RkfJTBvHJGAWUmgddYdjb9yuopMvbaOYqviPcpg6COr4y8mMvbaOYq1slZXOxmkFNypg7Wg6ZamHEEmi8xvkg0QDXyxmyBJRFjUHD8hXFjrUxfSB51DBBh6pI)OUXpI)s0Plob(r1xkB)syY)sQWT8(sivOPlo9LqQ8c9LezYbZMxvK7vb7wEviTv7WXiBIHEPLeob2BWoqUDO7qcSiClVVeiHfqR1T8(smbeVLGXGuHMU4um(J6XiYZv7WX4pumQWlkpgc72wDcmg32um(J6X4pumh9IhddY9QGDlVyAACEmlkgiPGmw)sivy)0n9Le5EvWULxhskiJD3203)OwwFe)LOtxCc8JQVu2(LWK)LuHB59LqQqtxC6lHu5f6l9EmQWT8QagKwkNxfk27UTPyKnXiZye5bwmVcW1n1vHasULxLoDXjWyqumQWT8QyrcfpvHI9UBBkgefJipWI5vaUUPUkeqYT8Q0PlobgdcIr2eZ7XOc3qsD6OTr4yyzmivOPlovf5EvWULxhGRBc7qRbkgeedIIrfULxfGRBc7qRbQkuS3DBtXiBI59yuHBiPoD02iCmSvEmivOPlovf5EvWULxhGRBc7qRbkgeeJmgdsfA6ItvrUxfSB51fk27qAR2H)sGewaTw3Y7lH4hkgHI9yCBtXKaX4pum4wIZJXFupMMgNhZIIPfscf7XyNNXWGCVky3YR(LqQW(PB6ljY9QGDlVElKek27UTPV)r9R)r8xIoDXjWpQ(sz7xct(xsfUL3xcPcnDXPVesLxOVesfA6ItvrUxfSB51HKcYy3Tn9LqQW(PB6ljY9QGDlVUBB67Ful7)i(lrNU4e4hvFPS9lT1x(sQWT8(sivOPlo9LqQW(PB6ljY9QGDlVUBB6ljGMtqt)sUYPZRagKWUcDcwPtxCcmguIrMXGuHMU4ufWGe2vOtWUi3Rc2T8(sGewaTw3Y7lHWjUYymmi3Rc2T8IbiHXOaobJHnmiHDf6emMYXjmogKk00fNQagKWUcDc2f5EvWULxmgogm51VesLxOVeGbjSRqNGviTv7WF)JAz4J4VeD6ItGFu9LY2V0wF5lPc3Y7lHuHMU40xcPc7NUPVKi3Rc2T86UTPVKaAobn9ljsK0PNxBGrOPxmOeJitoy28Qqf00Z74wf2qfsB1oCmYymnYWXWYyqQqtxCQkY9QGDlVUBB6lbsyb0ADlVVecN4kJXWGCVky3YlgGegdcPcA65Xi1QWgIXaIX8yAACEmICtXKaaXiYKdMnVyWzE1VesLxOVKitoy28Qqf00Z74wf2qfsB1o83)O(v(r8xIoDXjWpQ(sz7xARV8LuHB59LqQqtxC6lHuH9t30xsK7vb7wED320xsanNGM(Lejs60ZRiPZFyegdkXiYKdMnV62GWeI7jq3t4MoVcPTAhogzmgzjdXWYyqQqtxCQkY9QGDlVUBB6lbsyb0ADlVVecN4kJXWGCVky3YlgGegdcndctioMeigeNWnD(xcPYl0xsKjhmBE1TbHje3tGUNWnDEfsB1o83)OMn5J4VeD6ItGFu9LY2V0wF5lPc3Y7lHuHMU40xcPc7NUPVKi3Rc2T86UTPVKaAobn9ljsK0PNxpsatEcbJbLyezYbZMxfKu)zLWJQqAR2HJrgJPrgogwgdsfA6ItvrUxfSB51DBtFjqclGwRB59Lq4exzmggK7vb7wEXaKWyq4K6pReEu9lHu5f6ljYKdMnVkiP(ZkHhvH0wTdhdII59ywfaGkiP(ZkHhvblq1T8IrgJzvaaQICVky3YRcwGQB5fdcIr2edSCeqcrtvqs9hChq9NCxPtxCc87FuJq9r8xIoDXjWpQ(sz7xARV8LuHB59LqQqtxC6lHuH9t30xsK7vb7wED320xsanNGM(LGLJasiAQcsQ)G7aQ)K7kD6ItGXGsmRcaqfKu)zLWJQL2yqjgv4gsQthTnchdBLhJS(sGewaTw3Y7lHWjUYymmi3Rc2T8IbiHXGWj1FEdhdBO(tUJb7QObCmgqm(dbPyuifJ6XWjf7X4nZyCfIMCC9lHu5f6lTkaavqs9NvcpQcPTAhogzmMvbaOkY9QGDlVkybQUL33)Ow2(J4VeD6ItGFu9LY2V0wF5lPc3Y7lHuHMU40xcPc7NUPVKi3Rc2T86UTPVKaAobn9lrVwXABjWkTBzeskVNqWtpb9LajSaATUL3xcHtCLXyyqUxfSB5fdqcJXFOyqi2TmcjLhdBgcE6jOywfaGymGy8hkMwUYibJXWXuW2Hog)r9yCODnqE9lHu5f6lHuHMU4uL2TmcjL3ti4PNG6GexzmgzmM3JrKjhmBEvA3YiKuEpHGNEcQcwGQB5fJmgJitoy28Q0ULriP8Ecbp9eufsB1oCmiigztmYmgrMCWS5vPDlJqs59ecE6jOkKuqg)(h1nYWFe)LOtxCc8JQVu2(L26lFjv4wEFjKk00fN(sivy)0n9Le5EvWULx3Tn9LeqZjOPFj61kwBlbwrZvqt9eI7lfenfdkXiYKdMnVkAUcAQNqCFPGOP(Rl7LbzjleQkK2QD4yKXyKfdhdlJbPcnDXPQi3Rc2T86UTPVeiHfqR1T8(siCIRmgddY9QGDlVyasymYwCf0upH4yqLcIMyoMYXjmogZJPzw4GXSOyajUYibgdpp0emg)rVyKfdhdMe5bIRFjKkVqFjrMCWS5vrZvqt9eI7lfen1FDzVmilzHqvH0wTd)9pQBSXpI)s0Plob(r1xkB)sB9LVKkClVVesfA6ItFjKkSF6M(sICVky3YR72M(scO5e00VKRC68kSCupb6TztcwPtxCcmguIzvaaQICVky3YRcMnVVeiHfqR1T8(siCIRmgddY9QGDlVykNB8yqiZxng6Lwds4ymGym)nCmL26xcPYl0xAvaaQWYr9eO3MnjyfsB1o83)OUrz9r8xIoDXjWpQ(sz7xARV8LuHB59LqQqtxC6lHuH9t30xsK7vb7wED320xsanNGM(LCLtNxHLJ6jqVnBsWkD6ItGXGsmRcaqvK7vb7wEvWS5fdkXiYKdMnVkSCupb6TztcwH0wTdhdIIrgIHLXGuHMU4uvK7vb7wED320xcKWcO16wEFjeoXvgJHb5EvWULxmajmg9IHEXHAmiKLJIjbI5vZMemgdig)HIbHSCumjqmVA2KGX0mlCWye5MIjbaIrKjhmBEXOEmCsXEmYqmysKhioMfbKqkggK7vb7wEX0mlCW6xcPYl0xsKjhmBEvy5OEc0BZMeScPTAhogefZQaauHLJ6jqVnBsWkybQUL33)OUXx)J4VeD6ItGFu9LY2V0wF5lPc3Y7lHuHMU40xcPc7NUPVKi3Rc2T86UTPVKaAobn9lblhbKq0uf0WcRLBNczSlY9wpWkD6ItGXGsmRcaqf0WcRLBNczSlY9wpWky28(sGewaTw3Y7lHWjUYymmi3Rc2T8IXaIbHByH1YTtHmgddY9wpWyAMfoymx6XSOyGKcYymajmgZJHrYRFjKkVqFjrMCWS5vxfaGoOHfwl3ofYyxK7TEGviTv7WF)J6gL9Fe)LOtxCc8JQVu2(L26lFjv4wEFjKk00fN(sivy)0n9Le5EvWULx3Tn9LeqZjOPFjOAGDcjDEvbbXv6fd74yqjgOAGDcjDEvbbXvrwopg2kpMxpguIbQgyNqsNxvqqCfSav3Ylg2gtJYWxcKWcO16wEFjes1aJbHajDoMjJbHtCLXyyqUxfSB5fdqcJrbbJb3QnpCmjqmVEmjmMDcPyuqqCm(J6X0048y4k2JHNhAcgJ)OxmnkdXGjrEG4Ami(HWumivEHWXOq6EZJ5ibHXk04mgt262w5XyxmkNhJqXeU(LqQ8c9LGQb2jK05vfeexT77Fu3Om8r8xIoDXjWpQ(sz7xct(xsfUL3xcPcnDXPVesf2pDtFjrUxfSB51DBtFjb0CcA6xcQgyNqsNxrw4hb1fNQ0lg2XXGsmivOPlovf5EvWULxhskiJD32umSmgOAGDcjDEfzHFeuxCQA3xcKWcO16wEFjes1aJbHajDoMjJbHXBQmIJPGPyyqUxfSB5fttZFIbzHFeuxg3CgJbQgymes6CmZXKiji0aPy0JXyajUYiogUHDcmgDLiPy8mMT2afdUaPympg0KJJPGjWyEiiv)sivEH(sq1a7es68kYc)iOU4u1UyKnXiZyGQb2jK05vKf(rqDXPAP97Fu34R8J4VeD6ItGFu9LY2VeM8VKkClVVesfA6ItFjKkSF6M(sICVky3YR72M(scO5e00VesfA6ItvrUxfSB51HKcYy3TnfdIIrKjhmBEvrUxfSB5vblq1T8Ir2eZ7X0ymYymVhddxFLXGOyy4QSIr2eJRC68kGbjSRqNGv60fNaJbbXiBIXvoDETb7a52HUsNU4eymiigwkpgKk00fNQICVky3YR72MIHvwJbPcnDXPQi3Rc2T86UTPyyBmag6hVdPTAhogzmgzXWFjqclGwRB59LyIXum(dfZrV4XWGCVky3YlM8IrKjhmBEXyaXyEmnZchmMl9ywum0lTKWjWy8mgqIRmgJ)qXGfpeyHtGXKhftcJXFOyWIhcSWjWyYJIPzw4GX8OTT0fdNW4y8h9IrwmCmysKhioMfbKqkg)HIbWq)4XqhiU(LqQ8c9LqQqtxCQkY9QGDlVoKuqg7UTPV)rDJSjFe)LOtxCc8JQVu2(LuqWVKkClVVesfA6ItFjKkVqFj320xcKWcO16wEFjegiym(dfJOaH05X42MIXZy8hkgS4HalCcmggK7vb7wEX4zmTfpgZJXUy0fo5fNIXTnfdoJXFupgZJXWXGDJZJrfIcuDkgfWjymAmCZDofJBBkMwfJjC9lHuH9t30xsK7vb7wED3203)OUreQpI)s0Plob(r1xkB)syY)sQWT8(sivOPlo9LajSaATUL3xInSt5CgzogrEijOhdam3XOlCYlofJBBkg9aJb7jKIXFOyGexDdjfJBBkg7IbPcnDXPQBBQ7zxK7vb7wE1yyIpU1afJ)qXajShtceJ)qXiuUOWv3YdZCmnFmXtmpABlDXWjmogai9Af6CoJX4zm4wIaJP0gJ)qXGTDHRULhZX4pgoMhTTLoCmjaGmkBXaeEm6bgtZhJtXiuSBh66xcPYl0x69yqQqtxCQkY9QGDlVUBBkgzmg32umiigztmRcaqvK7vb7wEvWS59LkyQNaaD0cWpQB8lHuH9t30xYTn19SlY9QGDlVVubt9MpgN6cf72H(J6g)(3)sICVky3YR3(Oy6J4pQB8J4VeD6ItGFu9LeqZjOPFPvbaOkY9QGDlVky28(sQWT8(sCd9JJ7mHlGO305F)JAz9r8xIoDXjWpQ(sfm1B(yCQluSBh6pQB8lbsyb0ADlVVecb2TT6umpzZy45HoggK7vb7wEX0048y4k2JXF0RbCmEgJu5IHjKDOFdhdQ4egBh6y8mgqYj42okMNSzmSHbPyqfxXoog8tw4GXSOykycS(LY2VeM8VKaAobn9ljYdSyE1oacEkVluSqbPVesLxOV0Qaauf5EvWULxfsB1oCmikMvbaOkY9QGDlVkybQULxmYMyEpgrMCWS5vf5EvWULxfsB1oCmSmMvbaOkY9QGDlVkK2QD4yqWxQGPEca0rla)OUXVKkClVVesfA6ItFjKkSF6M(s0loDGeyxK7vb7wEDiTv7WF)J6x)J4VeD6ItGFu9LkyQ38X4uxOy3o0Fu34xcKWcO16wEFjegiiog)HIbSav3YlMeig)HIrQCXWeYo0VHJbvCcJTdDmmi3Rc2T8IXZy8hkg6aJjbIXFOyefiKopggK7vb7wEXyaX4pumcf7X0mlCWye5ULtofdybAh6y8hdhddY9QGDlV6xkB)ski4xsanNGM(Le5bwmVAhabpL3fkwOGumOeZ7XSkaavC56nyhACFXjm2o0DiPGmwlTXWkRXGuHMU4uLEXPdKa7ICVky3YRdPTAhog2gtJvzigztmOfG1T(smYMyEpMvbaOIlxVb7qJ7loHX2HUU1x6yxfneJmgZQaauXLR3GDOX9fNWy7qxXUkAigeedc(sivEH(sivOPlovXnS6GfO6wEFPcM6jaqhTa8J6g)sQWT8(sivOPlo9LqQW(PB6lrV40bsGDrUxfSB51H0wTd)9pQL9Fe)LOtxCc8JQVKaAobn9lTkaavrUxfSB5vbZM3xsfUL3xAPO7jq3HMOb83)Owg(i(lrNU4e4hvFjb0CcA6xsfUHK60rBJWXW2yAmguIzvaaQICVky3YRcMnVVKkClVVe3qAh6(k3RV)r9R8J4VeD6ItGFu9LkyQ38X4uxOy3o0Fu34xsanNGM(LKzmI8alMxTdGGNY7cfluqQsNU4eymOeJ4rHOjCmSvEmngdkXSkaavrUxfSB5vlTXGsmYmMvbaOcyqc7jCxlTXGsmYmMvbaO(KEh7qsBOwAJbLyEsVJDiPn0XTeNJ721b4g6hpgefZQaauFi1TdDV0wlTXWYyK1xQGPEca0rla)OUXVKkClVVeGbP(IRy)lbsyb0ADlVVetK5pzXJ5vCae8uEmmqXcfKyogMWfShtbtXWggKIbvCf74yA(qxm(dXymnZ7npMD5epXiGMJJrpWyA(qxmSHbjSNWDmgogWS5v)(h1SjFe)LOtxCc8JQVubt9MpgN6cf72H(J6g)sGewaTw3Y7lXez(tmVIdGGNYJHbkwOGeZXWggKIbvCf7XuWum4NSWbJzrXOGGMB5PCoJXiYd7q1ocmgCgJ)OEmMhJHJ5spMfftbtGXuooHXX8koacEkpggOyHcsXy4y0vw8y8mg6LwdsXKWy8hcsXOqkMDcPy8h9IHUSG(jg2WGumOIRyhhJNXqV40bgZR4ai4P8yyGIfkifJNX4pum0bgtceddY9QGDlV6xkB)syY)scO5e00VKipWI5v7ai4P8UqXcfK(sivEH(sQWT8QagK6lUI9Q4rHOjChaQc3Yt5XGOyEpgKk00fNQ0loDGeyxK7vb7wEDiTv7WXiJXSkaav7ai4P8UqXcfKQGfO6wEXGGyyrmIm5GzZRcyqQV4k2RGfO6wEFPcM6jaqhTa8J6g)sQWT8(sivOPlo9LqQW(PB6lrV0scNa7agK6lUID83)OgH6J4VeD6ItGFu9LY2VeM8VKkClVVesfA6ItFPcM6jaqhTa8J6g)sivy)0n9LoIajWoGbP(IRyh)LeqZjOPFjrEGfZR2bqWt5DHIfki9LkyQ38X4uxOy3o0Fu34xcPYl0xsqgpM3JbPcnDXPk9Ithib2f5EvWULxhsB1oCmSiM3JzvaaQ2bqWt5DHIfkivblq1T8IrgJbTaSU1xIbbXGGV)rTS9hXFj60fNa)O6lvWuV5JXPUqXUDO)OUXVKaAobn9ljYdSyE1oacEkVluSqbPyqjgXJcrt4yyR8yAmguI59yqQqtxCQsV0scNa7agK6lUIDCmSvEmivOPlovpIajWoGbP(IRyhhdRSgdsfA6Itv6fNoqcSlY9QGDlVoK2QD4yyP8ywfaGQDae8uExOyHcsvWcuDlVyyL1ywfaGQDae8uExOyHcsvSRIgIHLXiRyyL1ywfaGQDae8uExOyHcsviTv7WXWYyqlaRB9LyyL1yezYbZMxf)yaUDO7TztcwHKcYymOeJkCdj1PJ2gHJHTYJbPcnDXPQi3Rc2T864hdWTdDVnBsWyqjgrIKo986zOF8oGsXGGyqjMvbaOkY9QGDlVAPnguI59yKzmRcaqfWGe2t4UwAJHvwJzvaaQ2bqWt5DHIfkivH0wTdhdlJHHRYqmiiguIrMXSkaa1N07yhsAd1sBmOeZt6DSdjTHoUL4CC3Uoa3q)4XGOywfaG6dPUDO7L2APngwgJS(sfm1taGoAb4h1n(LuHB59Lami1xCf7F)J6gz4pI)s0Plob(r1xsfUL3xsOCExfULxNBy)lXnS3pDtFjv4gsQ7kNoh)9pQBSXpI)s0Plob(r1xQGPEZhJtDHID7q)rDJFjb0CcA6xAvaaQICVky3YRcMnVyqjgKk00fNQUTPUNDrUxfSB5fdlLhddhdkX8EmYmgy5iGeIMQGgwyTC7uiJDrU36bwPtxCcmgwznMvbaOcAyH1YTtHm2f5ERhyT0gdRSgZQaaubnSWA52Pqg7ICV1dSdatSxlTXGsmUYPZRWYr9eO3MnjyLoDXjWyqjgrMCWS5vxfaGoOHfwl3ofYyxK7TEGviPGmgdcIbLyEpgzgdSCeqcrtv0qdZzSBctWPkD6ItGXWkRXasRcaqfn0WCg7MWeCQwAJbbXGsmVhJmJrKiPtpVEKaM8ecgdRSgJitoy28QGK6pReEufsB1oCmSYAmRcaqfKu)zLWJQL2yqqmOeZ7XiZyejs60ZRiPZFyegdRSgJitoy28QBdctiUNaDpHB68kK2QD4yqqmOeZ7XOc3YRUjNsy1Uoa3q)4XGsmQWT8QBYPewTRdWn0pEhsB1oCmSuEmivOPlovf5EvWULxxOyVdPTAhogwzngv4wEvSiHINk9cjkUDOJbLyuHB5vXIekEQ0lKO4uhsB1oCmSmgKk00fNQICVky3YRluS3H0wTdhdRSgJkClVkGbPLY5v6fsuC7qhdkXOc3YRcyqAPCELEHefN6qAR2HJHLXGuHMU4uvK7vb7wEDHI9oK2QD4yyL1yuHB5vBzeMlUI9k9cjkUDOJbLyuHB5vBzeMlUI9k9cjko1H0wTdhdlJbPcnDXPQi3Rc2T86cf7DiTv7WXWkRXOc3YRcW1nHDO1avPxirXTdDmOeJkClVkax3e2HwduLEHefN6qAR2HJHLXGuHMU4uvK7vb7wEDHI9oK2QD4yqWxQGPEca0rla)OUXVKkClVVKi3Rc2T8((h1nkRpI)s0Plob(r1xcKWcO16wEFj2S)qWyezYbZMhog)r9yWpzHdgZIIPGjWyAA(tmmi3Rc2T8Ib)Kfoym5XzmMfftbtGX008Ny0lgv4fLhddY9QGDlVyek2JrpWyU0JPP5pXOXivUyyczh63WXGkoHX2HoMwykQFjv4wEFjHY5Dv4wEDUH9VKaAobn9lTkaavrUxfSB5vH0wTdhdBJbHkgwzngrMCWS5vf5EvWULxfsB1oCmSmgz4lXnS3pDtFjrUxfSB51fzYbZMh(7Fu34R)r8xIoDXjWpQ(scO5e00V07XSkaa1N07yhsAd1sBmOeJkCdj1PJ2gHJHTYJbPcnDXPQi3Rc2T86aCDtyhAnqXGGyyL1yEpMvbaOcyqc7jCxlTXGsmQWnKuNoABeog2kpgKk00fNQICVky3YRdW1nHDO1afJmgdSCeqcrtvadsypH7kD6ItGXGGVKkClVVeax3e2Hwd03)OUrz)hXFj60fNa)O6ljGMtqt)sRcaqfxUEd2Hg3xCcJTdDhskiJ1sBmOeZQaauXLR3GDOX9fNWy7q3HKcYyfsB1oCmSngHI9UBB6lPc3Y7l1YimxCf7F)J6gLHpI)s0Plob(r1xsanNGM(LwfaGkGbjSNWDT0(LuHB59LAzeMlUI9V)rDJVYpI)s0Plob(r1xsanNGM(LwfaGAlJWuWv8UwAJbLywfaGAlJWuWv8UcPTAhog2gJqXE3TnfdkX8EmRcaqvK7vb7wEviTv7WXW2yek27UTPyyL1ywfaGQi3Rc2T8QGzZlgeedkXOc3qsD6OTr4yyzmivOPlovf5EvWULxhGRBc7qRb6lPc3Y7l1YimxCf7F)J6gzt(i(lrNU4e4hvFjb0CcA6xAvaaQpP3XoK0gQL2yqjMvbaOkY9QGDlVAP9lPc3Y7l1YimxCf7F)J6grO(i(lrNU4e4hvFjb0CcA6xQfsi7OfG1gRyrcfpXGsmRcaq9Hu3o09sBT0gdkXOc3qsD6OTr4yyzmivOPlovf5EvWULxhGRBc7qRbkguIzvaaQICVky3YRwA)sQWT8(sTmcZfxX(3)OUrz7pI)s0Plob(r1xsfUL3xc)yaUDO7Tztc(LSZjiS06Dd4lPc3YRcyqQV4k2RIhfIMWYvHB5vbmi1xCf71T(sx8Oq0e(ljGMtqt)sRcaqvK7vb7wE1sBmOeJmJrfULxfWGuFXvSxfpkenHJbLyuHBiPoD02iCmSvEmivOPlovf5EvWULxh)yaUDO7TztcgdkXOc3YR2(K0zV0b46MWvGcN3HK4rHOPUBBkg2gdqHZ7qcSiClVVeiHfqR1T8(smXy7qhJ0Jb42HoMxnBsWyalq7qhddY9QGDlVy8mgiH9esXWggKIbvCf7XOhymV6tsN9smSbx3umIhfIMWXi0lMffZIocWeMYzoMvXJPGlkNZym5XzmM8IbHLie1V)rTSy4pI)s0Plob(r1xsanNGM(LwfaGQi3Rc2T8QL2yqjghQijE3TnfdlJzvaaQICVky3YRcPTAhoguI59yEpgv4wEvads9fxXEv8Oq0eogwgtJXGsmUYPZRTmctbxX7kD6ItGXGsmQWnKuNoABeog5X0ymiigwzngzgJRC68AlJWuWv8UsNU4eymSYAmQWnKuNoABeog2gtJXGGyqjMvbaO(qQBh6EPTwAJbrX8KEh7qsBOJBjoh3TRdWn0pEmSmgz9LuHB59LAFs6Sx6aCDt4V)rTSA8J4VeD6ItGFu9LeqZjOPFPvbaOkY9QGDlVky28IbLyezYbZMxvK7vb7wEviTv7WXWYyek27UTPyqjgv4gsQthTnchdBLhdsfA6ItvrUxfSB51b46MWo0AG(sQWT8(saCDtyhAnqF)JAzjRpI)s0Plob(r1xsanNGM(LwfaGQi3Rc2T8QGzZlguIrKjhmBEvrUxfSB5vH0wTdhdlJrOyV72MIbLyKzmI8alMxb46M6Qqaj3YRsNU4e4xsfUL3xcWG0s58V)rTSE9pI)s0Plob(r1xsanNGM(LwfaGQi3Rc2T8QqAR2HJHTXiuS3DBtXGsmRcaqvK7vb7wE1sBmSYAmRcaqvK7vb7wEvWS5fdkXiYKdMnVQi3Rc2T8QqAR2HJHLXiuS3DBtFjv4wEFjSiHINV)rTSK9Fe)LOtxCc8JQVKaAobn9lTkaavrUxfSB5vH0wTdhdlJbTaSU1xIbLyuHBiPoD02iCmSnMg)sQWT8(sCdPDO7RCV((h1Ysg(i(lrNU4e4hvFjb0CcA6xAvaaQICVky3YRcPTAhogwgdAbyDRVedkXSkaavrUxfSB5vlTFjv4wEFjqOIopCFbj1F((3)sGeGw4(hXFu34hXFj60fNa)O6ljGMtqt)sYmgy5iGeIMQGgwyTC7uiJDrU36bwPtxCc8lPc3Y7ljYY5ee3sC(3)OwwFe)LOtxCc8JQVeiHfqR1T8(si(HIrK7vb7wED322Hogv4wEXWnShdw8qGfoHJP5dDXWGCVky3YlMMgNhZIIPGjWy0dmgSNqchJ)qXajCH7XyxmivOPlovDBtDp7ICVky3YR(LuHB59LekN3vHB515g2)sCd79t30xsK7vb7wED322H(7Fu)6Fe)LOtxCc8JQVu2(LWK)LuHB59LqQqtxC6lHu5f6l9EmQWnKuNoABeogwgdsfA6ItvrUxfSB51XpgGBh6EB2KGXWkRXOc3qsD6OTr4yyzmivOPlovf5EvWULxhGRBc7qRbkgwzngKk00fNQUTPUNDrUxfSB5fJmgJkClVk(XaC7q3BZMeScu48oKalc3Ylg2gJitoy28Q4hdWTdDVnBsWkybQULxmiiguIbPcnDXPQBBQ7zxK7vb7wEXiJXiYKdMnVk(XaC7q3BZMeScPTAhog2gJkClVk(XaC7q3BZMeScu48oKalc3YlguI59yezYbZMxfwoQNa92SjbRqAR2HJrgJrKjhmBEv8Jb42HU3MnjyfsB1oCmSngzigwzngzgJRC68kSCupb6TztcwPtxCcmge8LajSaATUL3xs2PqtxCkg)r9yiSBB1jCmnFi)HGXi9yaUDOJ5vZMemMMgNhZIIPGjWyweqcPyyqUxfSB5fJHJbskiJ1Vesf2pDtFj8Jb42HU3MnjyFrajK6ICVky3Y77Ful7)i(lrNU4e4hvFjb0CcA6xAvaaQICVky3YRcMnVyqjgv4wEvads9fxXEv8Oq0eogwkpMgJbLyKzmVhZQaauTdGGNY7cfluqQwAJbLywfaG6t6DSdjTHkKuHhdcIbLyqQqtxCQIFma3o092Sjb7lciHuxK7vb7wEFjv4wEFj8Jb42HU3Mnj43)Owg(i(lrNU4e4hvFjb0CcA6xAvaaQICVky3YRcMnVyqjM3JbPcnDXPQBBQ7zxK7vb7wEXWYyqQqtxCQkY9QGDlVElKek27UTPyqum0lKO4u3TnfdRSgdsfA6Itv32u3ZUi3Rc2T8IHTXOc3YRlYKdMnVyKXyAKHJbbFjv4wEFjOcA65DCRcB47Fu)k)i(lrNU4e4hvFjb0CcA6xAvaaQICVky3YRcMnVyqjMvbaOclh1tGEB2KGvWS5fdkXGuHMU4u1Tn19SlY9QGDlVyyzmivOPlovf5EvWULxVfscf7D32umikg6fsuCQ72MIbrX8EmRcaqfKu)zLWJQGfO6wEXiJXSkaavrUxfSB5vblq1T8IbbXiBIbwociHOPkiP(dUdO(tUR0Plob(LuHB59Laj1Fwj8OV)rnBYhXFj60fNa)O6ljGMtqt)sivOPlovDBtDp7ICVky3YlgwgdsfA6ItvrUxfSB51BHKqXE3TnfdIIHEHefN6UTPyqjMvbaOkY9QGDlVky28(sQWT8(sBdctiUNaDpHB68V)rnc1hXFj60fNa)O6lvWuV5JXPUqXUDO)OUXVeiHfqR1T8(sSrcJr2rN)WiK5ykykgng2WGumOIRypgXJcrtXawG2HogeAgeMqCmjqmioHB68yek2JXZyuKPbgJqBBTdDmIhfIMW1VKkClVVeGbP(IRy)ljGMtqt)sQWT8QBdctiUNaDpHB68k9cjkUDOJbLyakCEhsIhfIM6UTPyKXyuHB5v3geMqCpb6Ec305v6fsuCQdPTAhogwgJSpguIrMX8KEh7qsBOJBjoh3TRdWn0pEmOeJmJzvaaQpP3XoK0gQL2V)rTS9hXFj60fNa)O6lPc3Y7lHMRGM6je3xkiA6ljGMtqt)sivOPlovDBtDp7ICVky3Ylg2gJkClVUitoy28IrgJrg(seaaj8(PB6lHMRGM6je3xkiA67Fu3id)r8xIoDXjWpQ(sQWT8(s0ULriP8Ecbp9e0xsanNGM(LqQqtxCQ62M6E2f5EvWULxmSuEmivOPlovPDlJqs59ecE6jOoiXvgJbLyqQqtxCQ62M6E2f5EvWULxmSngKk00fNQ0ULriP8Ecbp9euhK4kJXiJXidFPt30xI2TmcjL3ti4PNG((h1n24hXFj60fNa)O6lPc3Y7lHFuWSjb2t4QNaDpHB68VKaAobn9l9EmivOPlovDBtDp7ICVky3YlgwkpgKk00fNQICVky3YR3cjHI9UBBkgefJSIHvwJbWq)4DiTv7WXWYyqQqtxCQ62M6E2f5EvWULxmiiguIzvaaQICVky3YRcMnVV0PB6lHFuWSjb2t4QNaDpHB68V)rDJY6J4VeD6ItGFu9LuHB59LqZzS9PNaDfJTTXv3Y7ljGMtqt)sivOPlovDBtDp7ICVky3Ylg2kpgKk00fNQ51lyQlkEca8LoDtFj0CgBF6jqxXyBBC1T8((h1n(6Fe)LOtxCc8JQVKkClVV0wf6csD8drEFxWM4ljGMtqt)sivOPlovDBtDp7ICVky3Ylgwkpgz4lD6M(sBvOli1Xpe59DbBIV)rDJY(pI)s0Plob(r1xcKWcO16wEFPxbqmfSDOJrJb7emnWyYtglykgZPnZXO8MkJ4ykykgeoKuqadsXi7imM4XKfhBGumjqmmi3Rc2T8QXWM9hc20WeZX0cTeAUHqhftbBh6yq4qsbbmifJSJWyIhttZFIHb5EvWULxm5XzmgdiMxXbqWt5XWafluqkgdhdD6ItGXOhymAmfSIMIPzEV5XSOy4j2JjrsWy8hkgWcuDlVysGy8hkgad9JxJbXpgogfeehJgdERCEmivEHIXZy8hkgrMCWS5ftcedchskiGbPyKDegt8yA(qxmGPDOJXFmCmcLlkC1T8IzrcTGPympgdht5GKYXUjIXZyumUSPy8h1JX8yAACEmlkMcMaJPLGaKW5mgtEXiYKdMnV6x60n9LaHKccyqQJKWyI)LeqZjOPFjKk00fNQUTPUNDrUxfSB5fdBLhdsfA6It186fm1ffpbaIbLyEpMvbaOAhabpL3fkwOGuf7QOHyKhZQaauTdGGNY7cfluqQU1x6yxfnedRSgJmJrKhyX8QDae8uExOyHcsv60fNaJHvwJbPcnDXPQi3Rc2T8651lykgwzngKk00fNQUTPUNDrUxfSB5fdBJXoNGTjxDcSdyOF8oK2QD4yytJjM3JrfULxxKjhmBEXGOyAKHJbbXGGVKkClVVeiKuqadsDKegt8V)rDJYWhXFj60fNa)O6lPc3Y7lHZcVBOpZj4xsanNGM(LEpgKk00fNQUTPUNDrUxfSB5fdBLhZRZWXiBI59yqQqtxCQMxVGPUO4jaqmSnggogeedRSgZ7XiZyCODnqE1BSA4kol8UH(mNGXGsmo0UgiV6nwlyDXPyqjghAxdKx9gRIm5GzZRcPTAhogwzngzgJdTRbYRUSQgUIZcVBOpZjymOeJdTRbYRUSQfSU4umOeJdTRbYRUSQIm5GzZRcPTAhogeedcIbLyEpgzgd9AfRTLaRGqsbbmi1rsymXJHvwJrKjhmBEvqiPGagK6ijmM4viTv7WXW2yKHyqWx60n9LWzH3n0N5e87Fu34R8J4VeD6ItGFu9LuHB59Le6jiEFvaa(scO5e00VKmJrKhyX8QDae8uExOyHcsv60fNaJbLyCBtXWYyKHyyL1ywfaGQDae8uExOyHcsvSRIgIrEmRcaq1oacEkVluSqbP6wFPJDv0WxAvaa6NUPVeol8UH(m3Y7lbsyb0ADlVVeIHgA0emgPSWJ5vG(mNGXqkKZymnn)jMxXbqWt5XWafluqkMegtZh6IX8yAQ4yAHKqXE97Fu3iBYhXFj60fNa)O6lbsyb0ADlVV0RWPnog)r9yaZyU0JzrhbyEmmi3Rc2T8Ib)KfoymmHlypMfftbtGXKfhBGumjqmmi3Rc2T8Ir9yW5MIPnTZRFPt30xYoSawCDXP(Rv0Zl7oiH0e0xsanNGM(LOxRyTTeyfnxbn1tiUVuq0umOedsfA6Itv32u3ZUi3Rc2T8IHTYJbPcnDXPAE9cM6IINaaFjv4wEFj7WcyX1fN6VwrpVS7GestqF)J6grO(i(lrNU4e4hvFjv4wEFjaUUPEc0xQ7C6ljGMtqt)s0RvS2wcSIMRGM6je3xkiAkguIbPcnDXPQBBQ7zxK7vb7wEXWw5XGuHMU4unVEbtDrXtaGV0PB6lbW1n1tG(sDNtF)J6gLT)i(lrNU4e4hvFjv4wEFPMAd0rqChaMh4xsanNGM(LOxRyTTeyfnxbn1tiUVuq0umOedsfA6Itv32u3ZUi3Rc2T8IHTYJbPcnDXPAE9cM6IINaaFPt30xQP2aDee3bG5b(9pQLfd)r8xIoDXjWpQ(sQWT8(s2HDyr4je3bnK2r9fX5Fjb0CcA6xIETI12sGv0Cf0upH4(sbrtXGsmivOPlovDBtDp7ICVky3Ylg2kpgKk00fNQ51lyQlkEca8LoDtFj7WoSi8eI7Ggs7O(I48V)rTSA8J4VeD6ItGFu9LuHB59LWLBXZeSRBYFye7Fjb0CcA6xIETI12sGv0Cf0upH4(sbrtXGsmivOPlovDBtDp7ICVky3Ylg2kpgKk00fNQ51lyQlkEca8LoDtFjC5w8mb76M8hgX(3)OwwY6J4VeD6ItGFu9LeqZjOPFjKk00fNQUTPUNDrUxfSB5fdBLhdsfA6It186fm1ffpba(sQWT8(sfm1nN24V)rTSE9pI)s0Plob(r1xsfUL3xcaMyVFjs9lbsyb0ADlVVetmMIHnGj2Jb1jsngpJXHgA0emgzlOH5mgZRqycov)scO5e00VeSCeqcrtv0qdZzSBctWPkD6ItGXGsmRcaqvK7vb7wEvWS5fdkX8EmivOPlovDBtDp7ICVky3Ylg2gJkClVUitoy28IHvwJbPcnDXPQBBQ7zxK7vb7wEXWYyqQqtxCQkY9QGDlVElKek27UTPyqum0lKO4u3Tnfdc((h1Ys2)r8xIoDXjWpQ(sQWT8(sISCobXTeN)LajSaATUL3xs2I8y8hkgeUHfwl3ofYymmi3B9aJzvaaIP0YCmLJtyCmICVky3YlgdhdoZR(LeqZjOPFjy5iGeIMQGgwyTC7uiJDrU36bwPtxCcmguIrKjhmBE1vbaOdAyH1YTtHm2f5ERhyfskiJXGsmRcaqf0WcRLBNczSlY9wpWUcf6rvWS5fdkXiZywfaGkOHfwl3ofYyxK7TEG1sBmOeZ7XGuHMU4u1Tn19SlY9QGDlVyqumQWT8QaWe7RK7vHI9UBBkg2gJitoy28QRcaqh0WcRLBNczSlY9wpWkybQULxmSYAmivOPlovDBtDp7ICVky3YlgwgJmedc((h1Ysg(i(lrNU4e4hvFjb0CcA6xcwociHOPkOHfwl3ofYyxK7TEGv60fNaJbLyezYbZMxDvaa6GgwyTC7uiJDrU36bwHKcYymOeZQaaubnSWA52Pqg7ICV1dSRqHEufmBEXGsmYmMvbaOcAyH1YTtHm2f5ERhyT0gdkX8EmivOPlovDBtDp7ICVky3Ylgefd9cjko1DBtXGOyuHB5vbGj2xj3Rcf7D32umSngrMCWS5vxfaGoOHfwl3ofYyxK7TEGvWcuDlVyyL1yqQqtxCQ62M6E2f5EvWULxmSmgziguIrMX4kNoVclh1tGEB2KGv60fNaJbbFjv4wEFjfk0J60lT8eB599pQL1R8J4VeD6ItGFu9LeqZjOPFjy5iGeIMQGgwyTC7uiJDrU36bwPtxCcmguIrKjhmBE1vbaOdAyH1YTtHm2f5ERhyfsB1oCmSmgHI9UBBkguIzvaaQGgwyTC7uiJDrU36b2bGj2RGzZlguIrMXSkaavqdlSwUDkKXUi3B9aRL2yqjM3JbPcnDXPQBBQ7zxK7vb7wEXGOyek27UTPyyBmIm5GzZRUkaaDqdlSwUDkKXUi3B9aRGfO6wEXWkRXGuHMU4u1Tn19SlY9QGDlVyyzmYqmi4lPc3Y7lbatSVsU)9pQLfBYhXFj60fNa)O6ljGMtqt)sWYrajenvbnSWA52Pqg7ICV1dSsNU4eymOeJitoy28QRcaqh0WcRLBNczSlY9wpWkKuqgJbLywfaGkOHfwl3ofYyxK7TEGDayI9ky28IbLyKzmRcaqf0WcRLBNczSlY9wpWAPnguI59yqQqtxCQ62M6E2f5EvWULxmSngrMCWS5vxfaGoOHfwl3ofYyxK7TEGvWcuDlVyyL1yqQqtxCQ62M6E2f5EvWULxmSmgzige8LuHB59LaGj27xIu)(h1YcH6J4VeD6ItGFu9LeqZjOPFjKk00fNQUTPUNDrUxfSB5fdlLhddhdRSgdsfA6Itv32u3ZUi3Rc2T8IHLXGuHMU4uvK7vb7wE9wijuS3DBtXGsmIm5GzZRkY9QGDlVkK2QD4yyzmivOPlovf5EvWULxVfscf7D320xsfUL3xsOCExfULxNBy)lXnS3pDtFjrUxfSB51BFum99pQLLS9hXFj60fNa)O6ljGMtqt)sRcaqfwoQNa92SjbRGzZlguIrMXSkaavadsypH7APnguI59yqQqtxCQ62M6E2f5EvWULxmSvEmRcaqfwoQNa92SjbRGfO6wEXGsmivOPlovDBtDp7ICVky3Ylg2gJkClVkGbP(IRyVcu48oKepken1DBtXWkRXGuHMU4u1Tn19SlY9QGDlVyyBmag6hVdPTAhoge8LuHB59LGLJ6jqVnBsWV)r9RZWFe)LOtxCc8JQVu2(LWK)LuHB59LqQqtxC6lbsyb0ADlVV0RMjpgfhZwpgJHnmifdQ4k2XXO4yAtm2wCkgGegddY9QGDlVAmsLLdvHhtw8ysGy8hkgaOkClpLhJi3T5rNhtceJ)qXCL9IGXKaXWggKIbvCf74y8h1JPPX5XCQxGkNZymqs8Oq0umGfODOJXFOyyqUxfSB5ft7JIPywKqlykM2m52Hog9y0FSdDmTk2JXFupMMgNhZLEmOH65XOxm0louJHnmifdQ4k2JbSaTdDmmi3Rc2T8QFjKkVqFjv4wEvads9fxXEv8Oq0eUdavHB5P8yqumVhdsfA6Itv32u3ZUi3Rc2T8IbrXOc3YRIFma3o092SjbRafoVdjWIWT8Ir2edsfA6Itv8Jb42HU3MnjyFrajK6ICVky3YlgeedlIrKjhmBEvads9fxXEfSav3YlgzmMgJHLXiYKdMnVkGbP(IRyVU1x6IhfIMWXGOyqQqtxCQMijyBM8oGbP(IRyhhdlIrKjhmBEvads9fxXEfSav3YlgzmM3JzvaaQICVky3YRcwGQB5fdlIrKjhmBEvads9fxXEfSav3YlgeetmSPX0ymOedsfA6Itv32u3ZUi3Rc2T8IHLXayOF8oK2QD4Vubt9eaOJwa(rDJFjKkSF6M(sagK6lUI9EBMC7q)LkyQ38X4uxOy3o0Fu343)O(1B8J4VeD6ItGFu9LY2VeM8VKkClVVesfA6ItFjKkSF6M(sTpjD2l92m52H(ljGMtqt)sQWnKuNoABeogwgdsfA6ItvrUxfSB51b46MWo0AG(sGewaTw3Y7lj7uOPlofJ)OEmI8CyYXX8QpjD2lXWgCDt4ykyfnfJNXqhUaPymhhJ4rHOjCmkKIPntobgdqcJHb5EvWULxng28XzmMcMI5vFs6SxIHn46MWXKfhBGumjqmmi3Rc2T8IP5dDXau48yepkenHJrOxmlkMC5QDeymGfODOJXFOyo6fpggK7vb7wE1VesLxOVesfA6Itv32u3ZUi3Rc2T8IbrXSkaavrUxfSB5vblq1T8IrgJrgIHLXOc3YR2(K0zV0b46MWvGcN3HK4rHOPUBBkgefJitoy28QTpjD2lDaUUjCfSav3Ylgzmgv4wEv8Jb42HU3MnjyfOW5DibweULxmYMyqQqtxCQIFma3o092Sjb7lciHuxK7vb7wEXGsmivOPlovDBtDp7ICVky3YlgwgdGH(X7qAR2HJHvwJbwociHOPkUC9gSdnUV4egBh6kD6ItGXWkRX42MIHLXidF)J6xxwFe)LOtxCc8JQVu2(LWK)LuHB59LqQqtxC6lHuH9t30xQ9jPZEP3Mj3o0Fjb0CcA6xsfUHK60rBJWXWw5XGuHMU4uvK7vb7wEDaUUjSdTgOVeiHfqR1T8(smrp0ftbBh6yydUUjSdTgOySlggK7vb7wEmhdwrsXO4y26XymIhfIMWXO4yAtm2wCkgGegddY9QGDlVyAA(tw8yeABRDORFjKkVqFjKk00fNQUTPUNDrUxfSB5fdlJrfULxT9jPZEPdW1nHRafoVdjXJcrtD32umYymQWT8Q4hdWTdDVnBsWkqHZ7qcSiClVyKnXGuHMU4uf)yaUDO7Tztc2xeqcPUi3Rc2T8IbLyqQqtxCQ62M6E2f5EvWULxmSmgad9J3H0wTdhdRSgdSCeqcrtvC56nyhACFXjm2o0v60fNaJHvwJXTnfdlJrg((h1V(R)r8xIoDXjWpQ(scO5e00V0QaauHLJ6jqVnBsWAPnguIbPcnDXPQBBQ7zxK7vb7wEXW2yy4Ve2HMW)OUXVKkClVVKq58UkClVo3W(xIByVF6M(sWST3(Oy67Fu)6Y(pI)s0Plob(r1xQGPEZhJtDHID7q)rDJFjqclGwRB59LqyGmHlypg)HIbPcnDXPy8h1JrKNdtoog2WGumOIRypMcwrtX4zm0HlqkgZXXiEuiAchJcPyuooJPntobgdqcJbHSCumjqmVA2KG1Vu2(LWK)LeqZjOPFjzgdsfA6Itvads9fxXEVntUDOJbLyCLtNxHLJ6jqVnBsWkD6ItGXGsmRcaqfwoQNa92SjbRGzZ7lHu5f6ljYKdMnVkSCupb6TztcwH0wTdhdlJrfULxfWGuFXvSxbkCEhsIhfIM6UTPyKXyuHB5vXpgGBh6EB2KGvGcN3Heyr4wEXiBI59yqQqtxCQIFma3o092Sjb7lciHuxK7vb7wEXGsmIm5GzZRIFma3o092SjbRqAR2HJHLXiYKdMnVkSCupb6TztcwH0wTdhdcIbLyezYbZMxfwoQNa92SjbRqAR2HJHLXayOF8oK2QD4Vubt9eaOJwa(rDJFjv4wEFjKk00fN(sivy)0n9Lami1xCf792m52H(7Fu)6YWhXFj60fNa)O6lvWuV5JXPUqXUDO)OUXVKaAobn9ljZyqQqtxCQcyqQV4k27TzYTdDmOedsfA6Itv32u3ZUi3Rc2T8IHTXWWXGsmQWnKuNoABeog2kpgKk00fNQpkeSluS3b46MWo0AGIbLyKzmagKWUcDcwvHBiPyqjgzgZQaauFsVJDiPnulTXGsmVhZQaauFi1TdDV0wlTXGsmQWT8QaCDtyhAnqv6fsuCQdPTAhogwgddxLHyyL1yepkenH7aqv4wEkpg2kpgzfdc(sfm1taGoAb4h1n(LuHB59Lami1xCf7FjqclGwRB59LyIEOlgMafckuSBh6yydUUPyKCO1aXCmSHbPyqfxXoog8tw4GXSOykycmgpJbnDeuDkgMG0JrYHK2aog9aJXZyOxC6aJbvCf7emgeAk2jy97Fu)6VYpI)s0Plob(r1xQGPEZhJtDHID7q)rDJFjb0CcA6xcWGe2vOtWQkCdjfdkXiEuiAchdBLhtJXGsmYmgKk00fNQagK6lUI9EBMC7qhdkX8EmYmgv4wEvadslLZR0lKO42HoguIrMXOc3YR2YimxCf7v76aCd9JhdkXSkaa1hsD7q3lT1sBmSYAmQWT8QagKwkNxPxirXTdDmOeJmJzvaaQpP3XoK0gQL2yyL1yuHB5vBzeMlUI9QDDaUH(XJbLywfaG6dPUDO7L2APnguIrMXSkaa1N07yhsAd1sBmi4lvWupba6OfGFu34xsfUL3xcWGuFXvS)LajSaATUL3xcHxG2Hog2WGe2vOtqMJHnmifdQ4k2XXOqkMcMaJbBBJRqoJX4zmGfODOJHb5EvWULxngzl6iOY5mYCm(dXymkKIPGjWy8mg00rq1PyycspgjhsAd4yA(qxmcO54yAACEmx6XSOyAQyNaJrpWyAA(tmOIRyNGXGqtXobzog)Hymg8tw4GXSOyWTqsbJjlEmEgZwTZv7IXFOyqfxXobJbHMIDcgZQaau)(h1VoBYhXFj60fNa)O6lvWuV5JXPUqXUDO)OUXVeiHfqR1T8(simKPbgJqBBTdDmSHbPyqfxXEmIhfIMWX08X4umIh9oIBh6yKEma3o0X8Qztc(LuHB59Lami1xCf7Fjb0CcA6xsfULxf)yaUDO7TztcwPxirXTdDmOedqHZ7qs8Oq0u3TnfdlJrfULxf)yaUDO7TztcwDt0qhsGfHB5fdkXSkaa1N07yhsAdvWS5fdkX42MIHTX0id)9pQFDeQpI)s0Plob(r1xsanNGM(LqQqtxCQ62M6E2f5EvWULxmSnggoguIzvaaQWYr9eO3MnjyfmBEFjv4wEFjHY5Dv4wEDUH9Ve3WE)0n9LWUEGkeSdtxDlVV)r9RlB)r8xsfUL3xclsO45lrNU4e4hvF)7FPwijY9s9pI)OUXpI)sQWT8(skuOh1TZjoNe(xIoDXjWpQ((h1Y6J4VeD6ItGFu9LY2VeM8VKaAobn9ljZyCLtNxBzeMcUI3v60fNa)sGewaTw3Y7lHWEvMkgzNcnDXPyyZTULhtgdIFmCmivOPlofdULegGr4yA(q(dbJHb5EvWULxm4NSWbJzrXuWeymGfODOJHnmiHDf6eS(LqQW(PB6lbyqc7k0jyxK7vb7wEFjv4wEFjKk00fN(sivEH6ehtFjg(lHu5f6l143)O(1)i(lrNU4e4hvFPS9lHj)ljGMtqt)sUYPZRaCDt9w1fpv60fNa)sGewaTw3Y7lHWEvMkgzNcnDXPyyZTULhtgdIFmCmivOPlofdULegGr4y8hkMRSxemMeigxHOjhhJ6X08XepXWeKEmsoK0gIHn46MWo0AGWXKfhBGumjqmmi3Rc2T8Ib)KfoymlkMcMaRFjKkSF6M(spP3XoK0g6aCDtyhAnqFjv4wEFjKk00fN(sivEH6ehtFPx)lHu5f6ljRV)rTS)J4VeD6ItGFu9LY2VeM8VKaAobn9l5kNoVcW1n1Bvx8uPtxCc8lbsyb0ADlVVec7vzQyKDk00fNIHn36wEmzmi(XWXGuHMU4um4wsyagHJXFOyUYErWysGyCfIMCCmQhtZht8edtGcbJHbk2JHn46MWo0AGWXKfhBGumjqmmi3Rc2T8Ib)KfoymlkMcMaJrXXayCobRFjKkSF6M(spkeSluS3b46MWo0AG(sQWT8(sivOPlo9LqQ8c1joM(sV(xcPYl0xswF)JAz4J4VeD6ItGFu9LY2VeM8VKaAobn9l5kNoVcW1n1Bvx8uPtxCc8lbsyb0ADlVVec7vzQyKDk00fNIHn36wEmzmi(XWXGuHMU4um4wsyagHJXFOyUYErWysGyCfIMCCmQhtZht8edtq6Xi5qsBig2GRBc7qRbchJcPykycmgWc0o0XWGCVky3YR(LqQW(PB6ljY9QGDlVoax3e2Hwd0xsfUL3xcPcnDXPVesLxOoXX0x6v(LqQ8c9LE9V)r9R8J4VeD6ItGFu9LY2VeM8VKaAobn9l5kNoVcW1n1Bvx8uPtxCc8lbsyb0ADlVVec7vzQyKDk00fNIHn36wEmzmi(XWXGuHMU4um4wsyagHJXFOyUYErWysGyCfIMCCmQhtZht8edcdk0JIbH4LwEIT8Ijlo2aPysGyyqUxfSB5fd(jlCWywumfmbw)sivy)0n9LuOqpQtV0YtSL3xsfUL3xcPcnDXPVesLxOoXX0xswFjKkVqFjzBz7V)rnBYhXFj60fNa)O6lLTFjiHj)lPc3Y7lHuHMU40xcPc7NUPVKcf6rD6LwEIT86B90VeibOfU)LK9m8xcKWcO16wEFje2RYuXi7uOPlofdBU1T8yYyq8JHJbPcnDXPyWTKWamchJ)qX0sqbDUIMIjbIzRNgZI4zZyA(yINyqyqHEumieV0YtSLxmnnopMl9ywumfmbw)(h1iuFe)LOtxCc8JQVu2(LGeM8VKkClVVesfA6ItFjKkSF6M(sICVky3YRJFma3o092Sjb)sGeGw4(xswFjqclGwRB59LqyVktfJStHMU4umS5w3YJjJbXpumxzViymjqmUcrtoogPhdWTdDmVA2KGXGFYchmMfftbtGXKxmGfODOJHb5EvWULx97FulB)r8xIoDXjWpQ(sz7xcsyY)sQWT8(sivOPlo9LqQW(PB6ljY9QGDlVUqXEhsB1o8xcKa0c3)smCLn5lbsyb0ADlVVec7vzQyKDk00fNIHn36wEmzmi(HIXTnfdK2QD2HoM8IrJrOypMMp0fddY9QGDlVye6fZIIPGjWySlgmjYdex)(h1nYWFe)LOtxCc8JQVu2(LGeM8VKkClVVesfA6ItFjKkSF6M(sjsc2MjVdyqQV4k2XFjqcqlC)lXWFjqclGwRB59LqyVktfJStHMU4umS5w3YJjJbXpgogKk00fNIb3scdWiCm(dfZv2lcgtcedMe5bIJjbIHnmifdQ4k2JXFupg8tw4GXSOyAZKtGX0Qypg)HIbKa0c3Jr3z5863)OUXg)i(lrNU4e4hvFPS9lbjm5Fjv4wEFjKk00fN(sivy)0n9LODlJqs59ecE6jOoiXvg)sGeGw4(xQreQVeiHfqR1T8(siSxLPIr2PqtxCkg2CRB5XKXWeKnJHNh6yweqcPyyqUxfSB5fd(jlCWyqi2TmcjLhdBgcE6jOywumfmbIq)3)OUrz9r8xIoDXjWpQ(sz7xct(xsfUL3xcPcnDXPVesLxOVKm8LajSaATUL3xcXpumGfO6wEXKaXOXivUyyczh63WXGkoHX2HoggK7vb7wE1Vesf2pDtFjCdRoybQUL33)OUXx)J4VeD6ItGFu9LY2VeM8VKkClVVesfA6ItFjKkVqFj61kwBlbwrZvqt9eI7lfenfdRSgd9AfRTLaRBvOli1Xpe59DbBIyyL1yOxRyTTey1oSawCDXP(Rv0Zl7oiH0eumSYAm0RvS2wcSIl3INjyx3K)Wi2JHvwJHETI12sGvA3YiKuEpHGNEckgwzng61kwBlbwb46M6jqFPUZPyyL1yOxRyTTeyTP2aDee3bG5bgdRSgd9AfRTLaR2HDyr4je3bnK2r9fX5XWkRXqVwXABjWk(rbZMeypHREc09eUPZ)sGewaTw3Y7lXe9q(dbJrJPG1fNIXCAhtbtGX4zmRcaqmmi3Rc2T8IXWXqVwXABjW6xcPc7NUPVKi3Rc2T8651ly67Fu3OS)J4VeD6ItGFu9LY2VeM8VKkClVVesfA6ItFjKkSF6M(s51lyQlkEca8LeqZjOPFjKk00fNQICVky3YRNxVGPVeiHfqR1T8(smbzZy45HoMfbKqkggK7vb7wEXGFYchmghAxdKJJXFupghAOrtWy0yWpkKaJrOoHoHmgJitoy28IjVys)HGX4q7AGCCmx6XSOykyceH(VesLxOVKSy4V)rDJYWhXFj60fNa)O6lLTFjm5Fjv4wEFjKk00fN(sivEH(sYsg(scO5e00Ve9AfRTLaRBvOli1Xpe59DbBIVesf2pDtFP86fm1ffpba((h1n(k)i(lrNU4e4hvFPS9lHj)lPc3Y7lHuHMU40xcPYl0xswmCmikgKk00fNQ0ULriP8Ecbp9euhK4kJFjb0CcA6xIETI12sGvA3YiKuEpHGNEc6lHuH9t30xkVEbtDrXtaGV)rDJSjFe)LOtxCc8JQVKkClVVeol8UH(mNGFjb0CcA6xsMXGuHMU4uvK7vb7wE986fmfdkXiZyOxRyTTeyfeskiGbPoscJjEmOeJmJXvoDEfWGe2vOtWkD6ItGFPt30xcNfE3qFMtWV)rDJiuFe)LuHB59L2geMWUTv00xIoDXjWpQ((h1nkB)r8xIoDXjWpQ(scO5e00VKmJPfsiRTmcZfxX(xsfUL3xQLryU4k2)(3)sICVky3YRlYKdMnp8hXFu34hXFjv4wEFP20T8(s0Plob(r13)OwwFe)LuHB59Lw8mb7afiJFj60fNa)O67Fu)6Fe)LOtxCc8JQVKaAobn9lTkaavrUxfSB5vlTFjv4wEFPfbXeSb7q)9pQL9Fe)LuHB59LamiT4zc(LOtxCc8JQV)rTm8r8xsfUL3xspbHDOY7cLZ)s0Plob(r13)O(v(r8xIoDXjWpQ(scO5e00VeSCeqcrtvN2Tju59MkSTsNU4eymOeZQaauPxE0c2T8QL2VKkClVVKBBQ3uHTF)JA2KpI)s0Plob(r1xsfUL3xcnxbn1tiUVuq00xIaaiH3pDtFj0Cf0upH4(sbrtF)JAeQpI)s0Plob(r1x60n9LSdlGfxxCQ)Af98YUdsinb9LuHB59LSdlGfxxCQ)Af98YUdsinb99pQLT)i(lrNU4e4hvFPt30xcGRBQNa9L6oN(sQWT8(saCDt9eOVu3503)OUrg(J4VeD6ItGFu9LoDtFPMAd0rqChaMh4xsfUL3xQP2aDee3bG5b(9pQBSXpI)s0Plob(r1x60n9LSd7WIWtiUdAiTJ6lIZ)sQWT8(s2HDyr4je3bnK2r9fX5F)J6gL1hXFj60fNa)O6lD6M(s4YT4zc21n5pmI9VKkClVVeUClEMGDDt(dJy)7Fu34R)r8xsfUL3xQGPU50g)LOtxCc8JQV)9VKkCdj1DLtNJ)i(J6g)i(lrNU4e4hvFjb0CcA6xsfUHK60rBJWXW2yAmguIzvaaQICVky3YRcMnVyqjM3JbPcnDXPQBBQ7zxK7vb7wEXW2yezYbZMxLBiTdDFL7vfSav3YlgwzngKk00fNQUTPUNDrUxfSB5fdlLhddhdc(sQWT8(sCdPDO7RCV((h1Y6J4VeD6ItGFu9LeqZjOPFjKk00fNQUTPUNDrUxfSB5fdlLhddhdRSgZ7XiYKdMnV6MCkHvWcuDlVyyzmivOPlovDBtDp7ICVky3YlguIrMX4kNoVclh1tGEB2KGv60fNaJbbXWkRX4kNoVclh1tGEB2KGv60fNaJbLywfaGkSCupb6TztcwlTXGsmivOPlovDBtDp7ICVky3Ylg2gJkClV6MCkHvrMCWS5fdRSgdGH(X7qAR2HJHLXGuHMU4u1Tn19SlY9QGDlVVKkClVV0MCkHF)J6x)J4VeD6ItGFu9LeqZjOPFjx505vLtVGDOIrOtXDGcKXkD6ItGXGsmVhZQaauf5EvWULxfmBEXGsmYmMvbaO(KEh7qsBOwAJbbFjv4wEFjqOIopCFbj1F((3)syxpqfc2HPRUL3hXFu34hXFj60fNa)O6ljGMtqt)sQWnKuNoABeog2kpgKk00fNQpP3XoK0g6aCDtyhAnqXGsmVhZQaauFsVJDiPnulTXWkRXSkaavadsypH7APnge8LuHB59La46MWo0AG((h1Y6J4VeD6ItGFu9LeqZjOPFPvbaOcsQ)Ss4r1sBmOedSCeqcrtvqs9hChq9NCxPtxCcmguIbPcnDXPQBBQ7zxK7vb7wEXWYywfaGkiP(ZkHhvH0wTdhdBLhJS(sQWT8(sagKwkN)9pQF9pI)s0Plob(r1xsanNGM(LwfaGkGbjSNWDT0(LuHB59LAzeMlUI9V)rTS)J4VeD6ItGFu9LeqZjOPFPvbaO(KEh7qsBOwAJbLywfaG6t6DSdjTHkK2QD4yyzmQWT8QagKwkNxPxirXPUBB6lPc3Y7l1YimxCf7F)JAz4J4VeD6ItGFu9LeqZjOPFPvbaO(KEh7qsBOwAJbLyEpMwiHSJwawBScyqAPCEmSYAmagKWUcDcwvHBiPyyL1yuHB5vBzeMlUI9QDDaUH(XJbbFjv4wEFPwgH5IRy)7Fu)k)i(lrNU4e4hvFjv4wEFPwgH5IRy)lbsyb0ADlVVeIHmgJNXGM8yKycHQyAHPahJDydKIbHmF1yAFumHJjHXWGCVky3YlM2hft4yA(qxmTjgBlov)scO5e00V0QaauXLR3GDOX9fNWy7q3HKcYyT0gdkX8EmIm5GzZRclh1tGEB2KGviTv7WXGOyuHB5vHLJ6jqVnBsWk9cjko1DBtXGOyek27UTPyyBmRcaqfxUEd2Hg3xCcJTdDhskiJviTv7WXWkRXiZyCLtNxHLJ6jqVnBsWkD6ItGXGGyqjgKk00fNQUTPUNDrUxfSB5fdIIrOyV72MIHTXSkaavC56nyhACFXjm2o0DiPGmwH0wTd)9pQzt(i(lrNU4e4hvFjb0CcA6xAvaaQpP3XoK0gQL2yqjgmPq7q39SiEQQWnK0xsfUL3xQLryU4k2)(h1iuFe)LOtxCc8JQVKaAobn9lTkaa1wgHPGR4DT0gdkXiuS3DBtXWYywfaGAlJWuWv8UcPTAh(lPc3Y7l1YimxCf7F)JAz7pI)s0Plob(r1xQGPEZhJtDHID7q)rDJFjb0CcA6xsMXayqc7k0jyvfUHKIbLyKzmivOPlovbmi1xCf792m52HoguI59yEpM3JrfULxfWG0s58k9cjkUDOJbLyEpgv4wEvadslLZR0lKO4uhsB1oCmSmggUkdXWkRXiZyGLJasiAQcyqc7jCxPtxCcmgeedRSgJkClVAlJWCXvSxPxirXTdDmOeZ7XOc3YR2YimxCf7v6fsuCQdPTAhogwgddxLHyyL1yKzmWYrajenvbmiH9eUR0PlobgdcIbbXGsmRcaq9Hu3o09sBT0gdcIHvwJ59yWKcTdD3ZI4PQc3qsXGsmVhZQaauFi1TdDV0wlTXGsmYmgv4wEvSiHINk9cjkUDOJHvwJrMXSkaa1N07yhsAd1sBmOeJmJzvaaQpK62HUxARL2yqjgv4wEvSiHINk9cjkUDOJbLyKzmpP3XoK0g64wIZXD76aCd9JhdcIbbXGGVubt9eaOJwa(rDJFjv4wEFjads9fxX(xcKWcO16wEFjeEbAh6y8hkgSRhOcbJbMU6wEmhtECgJPGPyyddsXGkUIDCmnFOlg)HymgfsXCPhZISdDmTzYjWyasymiK5RgtcJHb5EvWULxngMymfdByqkguXvShdz(dbJbSaTdDmAmSHbPLY5S4vzeMlUI9yek2JP5dDXWeqQBh6yyIBJXWXOc3qsXKWyalq7qhd9cjkofttZFIrIuODOJbXzr8u)(h1nYWFe)LOtxCc8JQVKaAobn9lTkaa1N07yhsAd1sBmOeJkCdj1PJ2gHJHLXGuHMU4u9j9o2HK2qhGRBc7qRb6lPc3Y7l1YimxCf7F)J6gB8J4VeD6ItGFu9LeqZjOPFjzgdsfA6It12NKo7LEBMC7qhdkX8EmYmgx505vayU7(d1v8dHR0PlobgdRSgJkCdj1PJ2gHJHTX0ymiiguI59yuHBiPoy6vd9zofdlJrwXWkRXOc3qsD6OTr4yyR8yqQqtxCQ(OqWUqXEhGRBc7qRbkgwzngv4gsQthTnchdBLhdsfA6It1N07yhsAdDaUUjSdTgOyqWxsfUL3xQ9jPZEPdW1nH)(h1nkRpI)s0Plob(r1xsfUL3xsOCExfULxNBy)lXnS3pDtFjv4gsQ7kNoh)9pQB81)i(lrNU4e4hvFjb0CcA6xsfUHK60rBJWXW2yA8lPc3Y7lbcv05H7liP(Z3)OUrz)hXFj60fNa)O6ljGMtqt)sysH2HU7zr8uvHBiPVKkClVVewKqXZ3)OUrz4J4VeD6ItGFu9LeqZjOPFjv4gsQthTnchdBLhdsfA6Itvfk0J60lT8eB5fdkXS1tRTcpg2kpgKk00fNQkuOh1PxA5j2YRV1tJbLyCfIM8AtZFSRrg(lPc3Y7lPqHEuNEPLNylVV)rDJVYpI)s0Plob(r1xsfUL3xcGRBc7qRb6lbsyb0ADlVVetK5pXqxwq)eJRq0KJzogZJXWXOXGwTlgpJrOypg2GRBc7qRbkgfhdGX5emg7WoPGXKaXWggKwkNx)scO5e00VKkCdj1PJ2gHJHTYJbPcnDXP6Jcb7cf7DaUUjSdTgOV)rDJSjFe)LuHB59LamiTuo)lrNU4e4hvF)7Fjy22BFum9r8h1n(r8xIoDXjWpQ(scO5e00VKkCdj1PJ2gHJHTYJbPcnDXP6t6DSdjTHoax3e2HwdumOeZ7XSkaa1N07yhsAd1sBmSYAmRcaqfWGe2t4UwAJbbFjv4wEFjaUUjSdTgOV)rTS(i(lrNU4e4hvFjb0CcA6xAvaaQGK6pReEuT0gdkXalhbKq0ufKu)b3bu)j3v60fNaJbLyqQqtxCQ62M6E2f5EvWULxmSmMvbaOcsQ)Ss4rviTv7WXGsmQWnKuNoABeog2kpgz9LuHB59LamiTuo)7Fu)6Fe)LOtxCc8JQVKaAobn9lTkaavC56nyhACFXjm2o0DiPGmwlTXGsmRcaqfxUEd2Hg3xCcJTdDhskiJviTv7WXW2yek27UTPVKkClVVulJWCXvS)9pQL9Fe)LOtxCc8JQVKaAobn9lTkaavadsypH7AP9lPc3Y7l1YimxCf7F)JAz4J4VeD6ItGFu9LeqZjOPFPvbaO(KEh7qsBOwA)sQWT8(sTmcZfxX(3)O(v(r8xIoDXjWpQ(sfm1B(yCQluSBh6pQB8ljGMtqt)sYmgKk00fNQagK6lUI9EBMC7qhdkXSkaavC56nyhACFXjm2o0DiPGmwbZMxmOeJkCdj1PJ2gHJHLXGuHMU4u9rHGDHI9oax3e2HwdumOeJmJbWGe2vOtWQkCdjfdkX8EmYmMvbaO(qQBh6EPTwAJbLyKzmRcaq9j9o2HK2qT0gdkXiZyAHeYEca0rlaRagK6lUI9yqjM3JrfULxfWGuFXvSxfpkenHJHTYJrwXWkRX8EmUYPZRkNEb7qfJqNI7afiJv60fNaJbLyezYbZMxfeQOZd3xqs9NkKuqgJbbXWkRXGjfAh6UNfXtvfUHKIbbXGGVubt9eaOJwa(rDJFjv4wEFjads9fxX(xcKWcO16wEFjMymftEumSHbPyqfxXEmKc5mgJDXGqMVAmgqmmMLyaZ7npMhfjfdz(dbJHjGu3o0XWe3gtcJHji9yKCiPnedJKhJEGXqM)qqMmM3veeZJIKIzNqkg)rVy8MzmkhskiJmhZ7leeZJIKIbHXPxWouXi0PVHJHnkqgJbskiJX4zmfmXCmjmM3fiigjsH2HogeNfXtmgogv4gsQgdcpV38yaZy8hdhtZhJtX8OqWyek2TdDmSbx3e2HwdeoMegtZh6IrQCXWeYo0VHJbvCcJTdDmgogiPGmw)(h1SjFe)LOtxCc8JQVubt9MpgN6cf72H(J6g)scO5e00VKmJbPcnDXPkGbP(IRyV3Mj3o0XGsmYmgadsyxHobRQWnKumOeZ7X8EmVhJkClVkGbPLY5v6fsuC7qhdkX8EmQWT8QagKwkNxPxirXPoK2QD4yyzmmCvgIHvwJrMXalhbKq0ufWGe2t4UsNU4eymiigwzngv4wE1wgH5IRyVsVqIIBh6yqjM3JrfULxTLryU4k2R0lKO4uhsB1oCmSmggUkdXWkRXiZyGLJasiAQcyqc7jCxPtxCcmgeedcIbLywfaG6dPUDO7L2APngeedRSgZ7XGjfAh6UNfXtvfUHKIbLyEpMvbaO(qQBh6EPTwAJbLyKzmQWT8Qyrcfpv6fsuC7qhdRSgJmJzvaaQpP3XoK0gQL2yqjgzgZQaauFi1TdDV0wlTXGsmQWT8Qyrcfpv6fsuC7qhdkXiZyEsVJDiPn0XTeNJ721b4g6hpgeedcIbbFPcM6jaqhTa8J6g)sQWT8(sagK6lUI9VeiHfqR1T8(smXykg2WGumOIRypgY8hcgdybAh6y0yyddslLZzXRYimxCf7XiuShtZh6IHjGu3o0XWe3gJHJrfUHKIjHXawG2Hog6fsuCkMMM)eJePq7qhdIZI4P(9pQrO(i(lrNU4e4hvFjv4wEFjHY5Dv4wEDUH9Ve3WE)0n9LuHBiPURC6C83)Ow2(J4VeD6ItGFu9LeqZjOPFPvbaO2YimfCfVRL2yqjgHI9UBBkgwgZQaauBzeMcUI3viTv7WXGsmcf7D32umSmMvbaOclh1tGEB2KGviTv7WFjv4wEFPwgH5IRy)7Fu3id)r8xIoDXjWpQ(scO5e00V0QaauFsVJDiPnulTXGsmysH2HU7zr8uvHBiPyqjgv4gsQthTnchdlJbPcnDXP6t6DSdjTHoax3e2Hwd0xsfUL3xQLryU4k2)(h1n24hXFj60fNa)O6ljGMtqt)sYmgKk00fNQTpjD2l92m52HoguIzvaaQpK62HUxARL2yqjgzgZQaauFsVJDiPnulTXGsmVhJkCdj1btVAOpZPyyzmYkgwzngv4gsQthTnchdBLhdsfA6It1hfc2fk27aCDtyhAnqXWkRXOc3qsD6OTr4yyR8yqQqtxCQ(KEh7qsBOdW1nHDO1afdc(sQWT8(sTpjD2lDaUUj83)OUrz9r8xIoDXjWpQ(scO5e00VeMuODO7Ewepvv4gs6lPc3Y7lHfju889pQB81)i(lrNU4e4hvFjb0CcA6xsfUHK60rBJWXW2yK1xsfUL3xceQOZd3xqs9NV)rDJY(pI)s0Plob(r1xsanNGM(LuHBiPoD02iCmSvEmivOPlovvOqpQtV0YtSLxmOeZwpT2k8yyR8yqQqtxCQQqHEuNEPLNylV(wpnguIXviAYRnn)XUgz4VKkClVVKcf6rD6LwEIT8((h1nkdFe)LOtxCc8JQVKkClVVeax3e2Hwd0xcKWcO16wEFjMiZFIHUSG(jgxHOjhZCmMhJHJrJbTAxmEgJqXEmSbx3e2HwdumkogaJZjym2HDsbJjbIHnmiTuoV(LeqZjOPFjv4gsQthTnchdBLhdsfA6It1hfc2fk27aCDtyhAnqF)J6gFLFe)LuHB59LamiTuo)lrNU4e4hvF)7F)lHKGylVpQLfdlRgzyzFJV(xQPcp7qJ)smrimesu)kqTSftgtmi(HIX2Tj0JbiHX8Mi3Rc2T86UTTd9BXaPxRyqcmgCUPy0INB1jWyep6HMW1GDMYokgzXKXWG8qsqNaJ5nrEGfZRm0BX4zmVjYdSyELHQ0Plob(wmVlRxqqnyNPSJIr2ZKXWG8qsqNaJ5nx505vg6Ty8mM3CLtNxzOkD6ItGVfZ7n(ccQb7mLDumSjmzmmipKe0jWyEdwociHOPkd9wmEgZBWYrajenvzOkD6ItGVfJ6XGqWMzQyEVXxqqnyNPSJIbHIjJHb5HKGobgZBWYrajenvzO3IXZyEdwociHOPkdvPtxCc8TyEVXxqqnyNPSJIPXgzYyyqEijOtGX8MRC68kd9wmEgZBUYPZRmuLoDXjW3I59gFbb1GDMYokMgLftgddYdjbDcmM3CLtNxzO3IXZyEZvoDELHQ0Plob(wmV34liOgSZu2rX04RZKXWG8qsqNaJ5ny5iGeIMQm0BX4zmVblhbKq0uLHQ0Plob(wmV34liOgSZu2rX04RKjJHb5HKGobgZBUYPZRm0BX4zmV5kNoVYqv60fNaFlM3L1liOgShSZeHWqir9Ra1YwmzmXG4hkgB3MqpgGegZBWST3(Oy6TyG0Rvmibgdo3umAXZT6eymIh9qt4AWotzhfJSyYyyqEijOtGX8gSCeqcrtvg6Ty8mM3GLJasiAQYqv60fNaFlM3B8feud2zk7OyELmzmmipKe0jWyEZvoDELHElgpJ5nx505vgQsNU4e4BX8EJVGGAWotzhfdBctgddYdjbDcmM3GLJasiAQYqVfJNX8gSCeqcrtvgQsNU4e4BX8USEbb1G9GDMiegcjQFfOw2IjJjge)qXy72e6XaKWyEdKa0c3Flgi9AfdsGXGZnfJw8CRobgJ4rp0eUgSZu2rX0itgddYdjbDcmM3GLJasiAQYqVfJNX8gSCeqcrtvgQsNU4e4BXOEmieSzMkM3B8feud2zk7OyEDMmggKhsc6eymV5kNoVYqVfJNX8MRC68kdvPtxCc8TyEVXxqqnyNPSJI5vYKXWG8qsqNaJ5ny5iGeIMQm0BX4zmVblhbKq0uLHQ0Plob(wmQhdcbBMPI59gFbb1GDMYokMgL9mzmmipKe0jWyKSndIbZ456lXWMYMgJNXWufnMDcw4fCmzlbvpHX8oBkcI59gFbb1GDMYokMgL9mzmmipKe0jWyEtKhyX8kd9wmEgZBI8alMxzOkD6ItGVfZ7n(ccQb7mLDumnkdmzmmipKe0jWyEZH21a51gRm0BX4zmV5q7AG8Q3yLHElM3F9xqqnyNPSJIPrzGjJHb5HKGobgZBo0UgiVkRkd9wmEgZBo0UgiV6YQYqVfZ7V(liOgSZu2rX04RKjJHb5HKGobgZBI8alMxzO3IXZyEtKhyX8kdvPtxCc8TyEVXxqqnyNPSJIrwVotgddYdjbDcmM3GLJasiAQYqVfJNX8gSCeqcrtvgQsNU4e4BX8EJVGGAWotzhfJSK9mzmmipKe0jWyEdwociHOPkd9wmEgZBWYrajenvzOkD6ItGVfZ7n(ccQb7mLDumYsgyYyyqEijOtGX8MRC68kd9wmEgZBUYPZRmuLoDXjW3I59gFbb1GDMYokgzjdmzmmipKe0jWyEdwociHOPkd9wmEgZBWYrajenvzOkD6ItGVfZ7n(ccQb7mLDumY6vYKXWG8qsqNaJ5ny5iGeIMQm0BX4zmVblhbKq0uLHQ0Plob(wmV34liOgSZu2rXil2eMmggKhsc6eymVblhbKq0uLHElgpJ5ny5iGeIMQmuLoDXjW3I59gFbb1GDMYokMxNHzYyyqEijOtGXizBgedMXZ1xIHnngpJHPkAmGgsdB5ft2sq1tymVZceeZ7V(liOgSZu2rX86mmtgddYdjbDcmgjBZGyWmEU(smSPSPX4zmmvrJzNGfEbht2sq1tymVZMIGyEVXxqqnyNPSJI51BKjJHb5HKGobgZBWYrajenvzO3IXZyEdwociHOPkdvPtxCc8TyEVXxqqnyNPSJI51LftgddYdjbDcmM3GLJasiAQYqVfJNX8gSCeqcrtvgQsNU4e4BX8EJVGGAWotzhfZRl7zYyyqEijOtGX8MRC68kd9wmEgZBUYPZRmuLoDXjW3I59gFbb1G9GDMiegcjQFfOw2IjJjge)qXy72e6XaKWyERfsICVu)TyG0Rvmibgdo3umAXZT6eymIh9qt4AWotzhfJSyYyyqEijOtGX8MRC68kd9wmEgZBUYPZRmuLoDXjW3Ir9yqiyZmvmV34liOgSZu2rX86mzmmipKe0jWyEZvoDELHElgpJ5nx505vgQsNU4e4BXOEmieSzMkM3B8feud2zk7OyK9mzmmipKe0jWyEZvoDELHElgpJ5nx505vgQsNU4e4BXOEmieSzMkM3B8feud2zk7OyKbMmggKhsc6eymV5kNoVYqVfJNX8MRC68kdvPtxCc8Tyupgec2mtfZ7n(ccQb7mLDumVsMmggKhsc6eymV5kNoVYqVfJNX8MRC68kdvPtxCc8Tyupgec2mtfZ7n(ccQb7mLDumnYMWKXWG8qsqNaJ5nx505vg6Ty8mM3CLtNxzOkD6ItGVfJ6XGqWMzQyEVXxqqnypyNjcHHqI6xbQLTyYyIbXpum2UnHEmajmM3e5EvWULxxKjhmBE43IbsVwXGeym4CtXOfp3QtGXiE0dnHRb7mLDumVsMmggKhsc6eymVblhbKq0uLHElgpJ5ny5iGeIMQmuLoDXjW3I59gFbb1G9GDMiegcjQFfOw2IjJjge)qXy72e6XaKWyEtfUHK6UYPZXVfdKETIbjWyW5MIrlEUvNaJr8OhAcxd2zk7OyKftgddYdjbDcmM3CLtNxzO3IXZyEZvoDELHQ0Plob(wmVlRxqqnyNPSJI51zYyyqEijOtGX8MRC68kd9wmEgZBUYPZRmuLoDXjW3I59gFbb1G9GDMiegcjQFfOw2IjJjge)qXy72e6XaKWyEd76bQqWomD1T8Elgi9AfdsGXGZnfJw8CRobgJ4rp0eUgSZu2rXilMmggKhsc6eymVblhbKq0uLHElgpJ5ny5iGeIMQmuLoDXjW3I59gFbb1GDMYokMxjtgddYdjbDcmM3CLtNxzO3IXZyEZvoDELHQ0Plob(wmV34liOgSZu2rXiBZKXWG8qsqNaJ5ny5iGeIMQm0BX4zmVblhbKq0uLHQ0Plob(wmVlRxqqnyNPSJIPXgzYyyqEijOtGX8MRC68kd9wmEgZBUYPZRmuLoDXjW3I59gFbb1G9GDMiegcjQFfOw2IjJjge)qXy72e6XaKWyEtK7vb7wE92hftVfdKETIbjWyW5MIrlEUvNaJr8OhAcxd2zk7OyELmzmmipKe0jWyEtKhyX8kd9wmEgZBI8alMxzOkD6ItGVfZ7n(ccQb7mLDumSjmzmmipKe0jWyKSndIbZ456lXWMgJNXWufngqdPHT8IjBjO6jmM3zbcI59gFbb1GDMYokgekMmggKhsc6eyms2MbXGz8C9LyytJXZyyQIgdOH0WwEXKTeu9egZ7SabX8EJVGGAWotzhftJnYKXWG8qsqNaJ5nx505vg6Ty8mM3CLtNxzOkD6ItGVfZ7n(ccQb7mLDumn2itgddYdjbDcmM3GLJasiAQYqVfJNX8gSCeqcrtvgQsNU4e4BX8USEbb1GDMYokMgFDMmggKhsc6eymVblhbKq0uLHElgpJ5ny5iGeIMQmuLoDXjW3I59gFbb1GDMYokgzXWmzmmipKe0jWyEZvoDELHElgpJ5nx505vgQsNU4e4BX8USEbb1GDMYokgzjlMmggKhsc6eymVjYdSyELHElgpJ5nrEGfZRmuLoDXjW3Ir9yqiyZmvmV34liOgShS)k2Tj0jWyqOIrfULxmCd74AW(xQfMagN(smnthdByqkgeAkAkyNPz6yECVfZKSGfOn)PSQICZcSTlC1T8eqfWzb22cweSZ0mDmSxokgzHqXCmYIHLvJb7b7mnthddE0dnHzYGDMMPJrgJHjgtXayOF8oK2QD4yGQ)qWy8h9IXviAYRUTPUNDqJIbiHXWvSlJysKhym6Y4MZymfSIMW1GDMMPJrgJHPYetxmcf7XaPxRyqAtNJJbiHXWGCVky3YlM3TkvzogW8EZJ5j5GXyEmajmgngaiHFIbHg5ucJrOyhb1GDMMPJrgJbH40fNIb7qt4XiEird2HoM8IrJbGAgdqcBahJDX4pumiSxLPIXZyGeyrqX0mHnWtfSgSZ0mDmYymimqMWfShJgZRYimxCf7XqNdzmg)r9yatchZLEm7eK4X0K48yStgrRBkM3X2ogNWobgJ6XCzmyd9zaMqppge(RkfJTBvHJGAWotZ0XiJXWG8qsqpgLZJzvaaQmufsQWJHohAeogpJzvaaQmuT0YCm6fJY3j2JXoSH(matONhdc)vLIbTAxm2fd224AWEWotZ0XGq8cjkobgZIasifJi3l1JzrOTdxJbHjeuRJJ5YtgFu4gOWJrfULhoM84mwd2vHB5HRTqsK7L6isoluOqpQBNtCoj8GDMMPJbH9QmvmYofA6ItXWMBDlpMmMxbqmyYJXZy0yU8Kre6iygdsLxiMJXFOyyqUxfSB5fJkClVy0dmgrMCWS5HJXFupgfsXiYd7q1ocmgpJjpoJXSOykycmMMp0fddY9QGDlVymCmL2yAACEmx6XSOykycmgWc0o0X4pumyBx4QB5vd2zAMogv4wE4AlKe5EPoIKZcKk00fNy(0njh0W6ItDrUxfSB5XC2khsyYd2z6yqyVktfJStHMU4umS5w3YJjJbXpgogKk00fNIb3scdWiCmnFi)HGXWGCVky3Ylg8tw4GXSOykycmgWc0o0XWggKWUcDcwd2vHB5HRTqsK7L6isolqQqtxCI5t3KCadsyxHob7ICVky3YJ5SvoMCMna5Y0voDETLryk4kEZmsLxi5nYmsLxOoXXKCgoyNPJbH9QmvmYofA6ItXWMBDlpMmge)y4yqQqtxCkgCljmaJWX4pumxzViymjqmUcrtoog1JP5JjEIHji9yKCiPnedBW1nHDO1aHJjlo2aPysGyyqUxfSB5fd(jlCWywumfmbwd2vHB5HRTqsK7L6isolqQqtxCI5t3K8N07yhsAdDaUUjSdTgiMZw5yYz2aK7kNoVcW1n1Bvx8WmsLxi5YIzKkVqDIJj5VEWothdc7vzQyKDk00fNIHn36wEmzmi(XWXGuHMU4um4wsyagHJXFOyUYErWysGyCfIMCCmQhtZht8edtGcbJHbk2JHn46MWo0AGWXKfhBGumjqmmi3Rc2T8Ib)KfoymlkMcMaJrXXayCobRb7QWT8W1wijY9sDejNfivOPloX8PBs(Jcb7cf7DaUUjSdTgiMZw5yYz2aK7kNoVcW1n1Bvx8WmsLxi5YIzKkVqDIJj5VEWothdc7vzQyKDk00fNIHn36wEmzmi(XWXGuHMU4um4wsyagHJXFOyUYErWysGyCfIMCCmQhtZht8edtq6Xi5qsBig2GRBc7qRbchJcPykycmgWc0o0XWGCVky3YRgSRc3YdxBHKi3l1rKCwGuHMU4eZNUj5ICVky3YRdW1nHDO1aXC2khtoZgGCx505vaUUPER6IhMrQ8cj)1zgPYluN4ys(RmyNPJbH9QmvmYofA6ItXWMBDlpMmge)y4yqQqtxCkgCljmaJWX4pumxzViymjqmUcrtoog1JP5JjEIbHbf6rXGq8slpXwEXKfhBGumjqmmi3Rc2T8Ib)KfoymlkMcMaRb7QWT8W1wijY9sDejNfivOPloX8PBsUcf6rD6LwEIT8yoBLJjNzdqURC68kax3uVvDXdZivEHKlBlBZmsLxOoXXKCzfSZ0XGWEvMkgzNcnDXPyyZTULhtgdIFmCmivOPlofdULegGr4y8hkMwckOZv0umjqmB90ywepBgtZht8edcdk0JIbH4LwEIT8IPPX5XCPhZIIPGjWAWUkClpCTfsICVuhrYzbsfA6ItmF6MKRqHEuNEPLNylV(wpLzqcqlCxUSNHzoBLdjm5b7mDmiSxLPIr2PqtxCkg2CRB5XKXG4hkMRSxemMeigxHOjhhJ0Jb42HoMxnBsWyWpzHdgZIIPGjWyYlgWc0o0XWGCVky3YRgSRc3YdxBHKi3l1rKCwGuHMU4eZNUj5ICVky3YRJFma3o092SjbzgKa0c3LllMZw5qctEWothdc7vzQyKDk00fNIHn36wEmzmi(HIXTnfdK2QD2HoM8IrJrOypMMp0fddY9QGDlVye6fZIIPGjWySlgmjYdexd2vHB5HRTqsK7L6isolqQqtxCI5t3KCrUxfSB51fk27qAR2HzgKa0c3LZWv2eMZw5qctEWothdc7vzQyKDk00fNIHn36wEmzmi(XWXGuHMU4um4wsyagHJXFOyUYErWysGyWKipqCmjqmSHbPyqfxXEm(J6XGFYchmMfftBMCcmMwf7X4pumGeGw4Em6olNxd2vHB5HRTqsK7L6isolqQqtxCI5t3K8ejbBZK3bmi1xCf7yMbjaTWD5mmZzRCiHjpyNPJbH9QmvmYofA6ItXWMBDlpMmgMGSzm88qhZIasifddY9QGDlVyWpzHdgdcXULriP8yyZqWtpbfZIIPGjqe6d2vHB5HRTqsK7L6isolqQqtxCI5t3KCA3YiKuEpHGNEcQdsCLrMbjaTWD5nIqXC2khsyYd2zAMoMxbqmmi3Rc2T8IXWXaAyDXjqMJblEiWcNIXFOyami2JHb5EvWULxmakmgfWjym(dfdGH(XJHoqCnyNPz6yuHB5HRTqsK7L6isolqQqtxCI5t3KC32u3ZUi3Rc2T8ygPYlKCad9J3H0wTdJOgzygMzdqosfA6ItvqdRlo1f5EvWULxWothdIFOyalq1T8IjbIrJrQCXWeYo0VHJbvCcJTdDmmi3Rc2T8Qb7QWT8W1wijY9sDejNfivOPloX8PBsoUHvhSav3YJ5SvoMCMrQ8cjxgc2z6yyIEi)HGXOXuW6ItXyoTJPGjWy8mMvbaiggK7vb7wEXy4yOxRyTTeynyxfULhU2cjrUxQJi5SaPcnDXjMpDtYf5EvWULxpVEbtmJu5fso9AfRTLaRO5kOPEcX9LcIMyLv61kwBlbw3QqxqQJFiY77c2eSYk9AfRTLaR2HfWIRlo1FTIEEz3bjKMGyLv61kwBlbwXLBXZeSRBYFye7SYk9AfRTLaR0ULriP8Ecbp9eeRSsVwXABjWkax3upb6l1DoXkR0RvS2wcS2uBGocI7aW8azLv61kwBlbwTd7WIWtiUdAiTJ6lIZzLv61kwBlbwXpky2Ka7jC1tGUNWnDEWothdtq2mgEEOJzrajKIHb5EvWULxm4NSWbJXH21a54y8h1JXHgA0emgng8JcjWyeQtOtiJXiYKdMnVyYlM0Fiymo0UgihhZLEmlkMcMarOpyxfULhU2cjrUxQJi5SaPcnDXjMpDtYZRxWuxu8eaG5SvoMCMrQ8cjxwmmZgGCKk00fNQICVky3YRNxVGPGDv4wE4AlKe5EPoIKZcKk00fNy(0njpVEbtDrXtaaMZw5yYzgPYlKCzjdmBaYPxRyTTeyDRcDbPo(HiVVlyteSRc3YdxBHKi3l1rKCwGuHMU4eZNUj551lyQlkEcaWC2khtoZivEHKllggrivOPlovPDlJqs59ecE6jOoiXvgz2aKtVwXABjWkTBzeskVNqWtpbfSRc3YdxBHKi3l1rKCwuWu3CAZ8PBsool8UH(mNGmBaYLjsfA6ItvrUxfSB51ZRxWekYKETI12sGvqiPGagK6ijmM4Oitx505vadsyxHobd2vHB5HRTqsK7L6isol2geMWUTv0uWUkClpCTfsICVuhrYzrlJWCXvSZSbixMTqczTLryU4k2d2d2zAMogeIxirXjWyiKeKXyCBtX4pumQWtymgogfPACDXPAWUkClpSCrwoNG4wIZz2aKlty5iGeIMQGgwyTC7uiJDrU36bgSZ0XG4hkgrUxfSB51DBBh6yuHB5fd3WEmyXdbw4eoMMp0fddY9QGDlVyAACEmlkMcMaJrpWyWEcjCm(dfdKWfUhJDXGuHMU4u1Tn19SlY9QGDlVAWUkClpmIKZcHY5Dv4wEDUHDMpDtYf5EvWULx3TTDOd2z6yKDk00fNIXFupgc72wDchtZhYFiymspgGBh6yE1SjbJPPX5XSOykycmMfbKqkggK7vb7wEXy4yGKcYynyxfULhgrYzbsfA6ItmF6MKJFma3o092Sjb7lciHuxK7vb7wEmNTYXKZmsLxi5VRc3qsD6OTrywIuHMU4uvK7vb7wED8Jb42HU3MnjiRSQc3qsD6OTrywIuHMU4uvK7vb7wEDaUUjSdTgiwzfPcnDXPQBBQ7zxK7vb7wEYOkClVk(XaC7q3BZMeScu48oKalc3YJTIm5GzZRIFma3o092SjbRGfO6wEiafKk00fNQUTPUNDrUxfSB5jJIm5GzZRIFma3o092SjbRqAR2HzRkClVk(XaC7q3BZMeScu48oKalc3YdL3fzYbZMxfwoQNa92SjbRqAR2HLrrMCWS5vXpgGBh6EB2KGviTv7WSvgyLvz6kNoVclh1tGEB2KGiiyxfULhgrYzb(XaC7q3BZMeKzdq(Qaauf5EvWULxfmBEOOc3YRcyqQV4k2RIhfIMWSuEJOiZ3xfaGQDae8uExOyHcs1slkRcaq9j9o2HK2qfsQWrakivOPlovXpgGBh6EB2KG9fbKqQlY9QGDlVGDv4wEyejNfqf00Z74wf2aZgG8vbaOkY9QGDlVky28q5DKk00fNQUTPUNDrUxfSB5XsKk00fNQICVky3YR3cjHI9UBBcr0lKO4u3TnXkRivOPlovDBtDp7ICVky3YJTIm5GzZtgBKHrqWUkClpmIKZcqs9NvcpIzdq(Qaauf5EvWULxfmBEOSkaavy5OEc0BZMeScMnpuqQqtxCQ62M6E2f5EvWULhlrQqtxCQkY9QGDlVElKek27UTjerVqIItD32eIEFvaaQGK6pReEufSav3YtgxfaGQi3Rc2T8QGfO6wEiq2alhbKq0ufKu)b3bu)j3b7QWT8Wisol2geMqCpb6Ec305mBaYrQqtxCQ62M6E2f5EvWULhlrQqtxCQkY9QGDlVElKek27UTjerVqIItD32ekRcaqvK7vb7wEvWS5fSZ0XWgjmgzhD(dJqMJPGPy0yyddsXGkUI9yepkenfdybAh6yqOzqycXXKaXG4eUPZJrOypgpJrrMgymcTT1o0XiEuiAcxd2vHB5HrKCwayqQV4k2zUGPEZhJtDHID7qlVrMna5QWT8QBdctiUNaDpHB68k9cjkUDOrbOW5DijEuiAQ72MKrv4wE1TbHje3tGUNWnDELEHefN6qAR2HzPShfz(KEh7qsBOJBjoh3TRdWn0pokYCvaaQpP3XoK0gQL2GDv4wEyejNffm1nN2mtaaKW7NUj5O5kOPEcX9LcIMy2aKJuHMU4u1Tn19SlY9QGDlp2kYKdMnpzugc2vHB5HrKCwuWu3CAZ8PBsoTBzeskVNqWtpbXSbihPcnDXPQBBQ7zxK7vb7wESuosfA6ItvA3YiKuEpHGNEcQdsCLruqQqtxCQ62M6E2f5EvWULhBrQqtxCQs7wgHKY7je80tqDqIRmkJYqWUkClpmIKZIcM6MtBMpDtYXpky2Ka7jC1tGUNWnDoZgG83rQqtxCQ62M6E2f5EvWULhlLJuHMU4uvK7vb7wE9wijuS3DBtiswSYkGH(X7qAR2HzjsfA6Itv32u3ZUi3Rc2T8qakRcaqvK7vb7wEvWS5fSRc3YdJi5SOGPU50M5t3KC0CgBF6jqxXyBBC1T8y2aKJuHMU4u1Tn19SlY9QGDlp2khPcnDXPAE9cM6IINaab7QWT8WisolkyQBoTz(0njFRcDbPo(HiVVlytWSbihPcnDXPQBBQ7zxK7vb7wESuUmeSZ0X8kaIPGTdDmAmyNGPbgtEYybtXyoTzogL3uzehtbtXGWHKccyqkgzhHXepMS4ydKIjbIHb5EvWULxng2S)qWMgMyoMwOLqZne6Oyky7qhdchskiGbPyKDegt8yAA(tmmi3Rc2T8IjpoJXyaX8koacEkpggOyHcsXy4yOtxCcmg9aJrJPGv0umnZ7npMffdpXEmjscgJ)qXawGQB5ftceJ)qXayOF8Ami(XWXOGG4y0yWBLZJbPYlumEgJ)qXiYKdMnVysGyq4qsbbmifJSJWyIhtZh6IbmTdDm(JHJrOCrHRULxmlsOfmfJ5Xy4ykhKuo2nrmEgJIXLnfJ)OEmMhttJZJzrXuWeymTeeGeoNXyYlgrMCWS5vd2vHB5HrKCwuWu3CAZ8PBsoiKuqadsDKegtCMna5ivOPlovDBtDp7ICVky3YJTYrQqtxCQMxVGPUO4jaakVVkaav7ai4P8UqXcfKQyxfniFvaaQ2bqWt5DHIfkiv36lDSRIgyLvzkYdSyE1oacEkVluSqbjwzfPcnDXPQi3Rc2T8651lyIvwrQqtxCQ62M6E2f5EvWULhBTZjyBYvNa7ag6hVdPTAhMnLn9DrMCWS5HOgzyeGGGDMMPJb1uZyKYcpMxb6ZCcgdDoKrMJbsCJWXKxm4hfsGXyoTJHbi8ySdiHB1T8IXFupgdhZLEmmsEm4sBBcDcSgtmiKulxfeog)HIPfsiTSGJHBhftZh6IbOCc3Yt51GDv4wEyejNffm1nN2mF6MKJZcVBOpZjiZgG83rQqtxCQ62M6E2f5EvWULhBL)6mSS5DKk00fNQ51lyQlkEcaWwggbSY67Y0H21a51gRgUIZcVBOpZjiko0UgiV2yTG1fNqXH21a51gRIm5GzZRcPTAhMvwLPdTRbYRYQA4kol8UH(mNGO4q7AG8QSQfSU4eko0UgiVkRQitoy28QqAR2Hracq5DzsVwXABjWkiKuqadsDKegtCwzvKjhmBEvqiPGagK6ijmM4viTv7WSvgqqWothdIHgA0emgPSWJ5vG(mNGXqkKZymnn)jMxXbqWt5XWafluqkMegtZh6IX8yAQ4yAHKqXEnyxfULhgrYzHqpbX7RcaaZNUj54SW7g6ZClpMna5YuKhyX8QDae8uExOyHcsO42MyPmWkRRcaq1oacEkVluSqbPk2vrdYxfaGQDae8uExOyHcs1T(sh7QOHGDMoMxHtBCm(J6XaMXCPhZIocW8yyqUxfSB5fd(jlCWyycxWEmlkMcMaJjlo2aPysGyyqUxfSB5fJ6XGZnftBANxd2vHB5HrKCwuWu3CAZ8PBsUDybS46It9xRONx2DqcPjiMna50RvS2wcSIMRGM6je3xkiAcfKk00fNQUTPUNDrUxfSB5Xw5ivOPlovZRxWuxu8eaiyxfULhgrYzrbtDZPnZNUj5aCDt9eOVu35eZgGC61kwBlbwrZvqt9eI7lfenHcsfA6Itv32u3ZUi3Rc2T8yRCKk00fNQ51lyQlkEcaeSRc3YdJi5SOGPU50M5t3K8MAd0rqChaMhiZgGC61kwBlbwrZvqt9eI7lfenHcsfA6Itv32u3ZUi3Rc2T8yRCKk00fNQ51lyQlkEcaeSRc3YdJi5SOGPU50M5t3KC7WoSi8eI7Ggs7O(I4CMna50RvS2wcSIMRGM6je3xkiAcfKk00fNQUTPUNDrUxfSB5Xw5ivOPlovZRxWuxu8eaiyxfULhgrYzrbtDZPnZNUj54YT4zc21n5pmIDMna50RvS2wcSIMRGM6je3xkiAcfKk00fNQUTPUNDrUxfSB5Xw5ivOPlovZRxWuxu8eaiyxfULhgrYzrbtDZPnMzdqosfA6Itv32u3ZUi3Rc2T8yRCKk00fNQ51lyQlkEcaeSZ0XWeJPyydyI9yqDIuJXZyCOHgnbJr2cAyoJX8keMGt1GDv4wEyejNfaWe79lrQmBaYHLJasiAQIgAyoJDtycoHYQaauf5EvWULxfmBEO8osfA6Itv32u3ZUi3Rc2T8yRitoy28yLvKk00fNQUTPUNDrUxfSB5XsKk00fNQICVky3YR3cjHI9UBBcr0lKO4u3TnHGGDMogzlYJXFOyq4gwyTC7uiJXWGCV1dmMvbaiMslZXuooHXXiY9QGDlVymCm4mVAWUkClpmIKZcrwoNG4wIZz2aKdlhbKq0uf0WcRLBNczSlY9wpquezYbZMxDvaa6GgwyTC7uiJDrU36bwHKcYikRcaqf0WcRLBNczSlY9wpWUcf6rvWS5HImxfaGkOHfwl3ofYyxK7TEG1slkVJuHMU4u1Tn19SlY9QGDlpePc3YRcatSVsUxfk27UTj2kYKdMnV6Qaa0bnSWA52Pqg7ICV1dScwGQB5XkRivOPlovDBtDp7ICVky3YJLYacc2vHB5HrKCwOqHEuNEPLNylpMna5WYrajenvbnSWA52Pqg7ICV1defrMCWS5vxfaGoOHfwl3ofYyxK7TEGviPGmIYQaaubnSWA52Pqg7ICV1dSRqHEufmBEOiZvbaOcAyH1YTtHm2f5ERhyT0IY7ivOPlovDBtDp7ICVky3Ydr0lKO4u3TnHiv4wEvayI9vY9QqXE3TnXwrMCWS5vxfaGoOHfwl3ofYyxK7TEGvWcuDlpwzfPcnDXPQBBQ7zxK7vb7wESugqrMUYPZRWYr9eO3Mnjicc2vHB5HrKCwaatSVsUZSbihwociHOPkOHfwl3ofYyxK7TEGOiYKdMnV6Qaa0bnSWA52Pqg7ICV1dScPTAhMLcf7D32ekRcaqf0WcRLBNczSlY9wpWoamXEfmBEOiZvbaOcAyH1YTtHm2f5ERhyT0IY7ivOPlovDBtDp7ICVky3Ydrcf7D32eBfzYbZMxDvaa6GgwyTC7uiJDrU36bwblq1T8yLvKk00fNQUTPUNDrUxfSB5Xszabb7QWT8WisolaGj27xIuz2aKdlhbKq0uf0WcRLBNczSlY9wpquezYbZMxDvaa6GgwyTC7uiJDrU36bwHKcYikRcaqf0WcRLBNczSlY9wpWoamXEfmBEOiZvbaOcAyH1YTtHm2f5ERhyT0IY7ivOPlovDBtDp7ICVky3YJTIm5GzZRUkaaDqdlSwUDkKXUi3B9aRGfO6wESYksfA6Itv32u3ZUi3Rc2T8yPmGGGDv4wEyejNfcLZ7QWT86Cd7mF6MKlY9QGDlVE7JIjMna5ivOPlovDBtDp7ICVky3YJLYzywzfPcnDXPQBBQ7zxK7vb7wESePcnDXPQi3Rc2T86TqsOyV72MqrKjhmBEvrUxfSB5vH0wTdZsKk00fNQICVky3YR3cjHI9UBBkyxfULhgrYzbSCupb6TztcYSbiFvaaQWYr9eO3MnjyfmBEOiZvbaOcyqc7jCxlTO8osfA6Itv32u3ZUi3Rc2T8yR8vbaOclh1tGEB2KGvWcuDlpuqQqtxCQ62M6E2f5EvWULhBvHB5vbmi1xCf7vGcN3HK4rHOPUBBIvwrQqtxCQ62M6E2f5EvWULhBbm0pEhsB1omcc2z6yE1m5XO4y26XymSHbPyqfxXoogfhtBIX2ItXaKWyyqUxfSB5vJrQSCOk8yYIhtceJ)qXaavHB5P8ye5Unp68ysGy8hkMRSxemMeig2WGumOIRyhhJ)OEmnnopMt9cu5CgJbsIhfIMIbSaTdDm(dfddY9QGDlVyAFumfZIeAbtX0Mj3o0XOhJ(JDOJPvXEm(J6X0048yU0Jbnuppg9IHEXHAmSHbPyqfxXEmGfODOJHb5EvWULxnyxfULhgrYzbsfA6ItmxWupba6OfGYBK5cM6nFmo1fk2TdT8gz(0njhWGuFXvS3BZKBhAMrQ8cjxfULxfWGuFXvSxfpkenH7aqv4wEkhrVJuHMU4u1Tn19SlY9QGDlpePc3YRIFma3o092SjbRafoVdjWIWT8KnivOPlovXpgGBh6EB2KG9fbKqQlY9QGDlpeWMkYKdMnVkGbP(IRyVcwGQB5jJnYsrMCWS5vbmi1xCf71T(sx8Oq0egrivOPlovtKeSntEhWGuFXvSJztfzYbZMxfWGuFXvSxblq1T8KX3xfaGQi3Rc2T8QGfO6wESPIm5GzZRcyqQV4k2RGfO6wEiGnLnTruqQqtxCQ62M6E2f5EvWULhlbm0pEhsB1oCWothJStHMU4um(J6XiYZHjhhZR(K0zVedBW1nHJPGv0umEgdD4cKIXCCmIhfIMWXOqkM2m5eymajmggK7vb7wE1yyZhNXykykMx9jPZEjg2GRBchtwCSbsXKaXWGCVky3YlMMp0fdqHZJr8Oq0eogHEXSOyYLR2rGXawG2Hog)HI5Ox8yyqUxfSB5vd2vHB5HrKCwGuHMU4eZNUj5TpjD2l92m52HMzdqUkCdj1PJ2gHzjsfA6ItvrUxfSB51b46MWo0AGygPYlKCKk00fNQUTPUNDrUxfSB5HOvbaOkY9QGDlVkybQULNmkdSufULxT9jPZEPdW1nHRafoVdjXJcrtD32eIezYbZMxT9jPZEPdW1nHRGfO6wEYOkClVk(XaC7q3BZMeScu48oKalc3Yt2GuHMU4uf)yaUDO7Tztc2xeqcPUi3Rc2T8qbPcnDXPQBBQ7zxK7vb7wESeWq)4DiTv7WSYkSCeqcrtvC56nyhACFXjm2o0SYQBBILYqWothdt0dDXuW2Hog2GRBc7qRbkg7IHb5EvWULhZXGvKumkoMTEmgJ4rHOjCmkoM2eJTfNIbiHXWGCVky3YlMMM)KfpgH22Ah6AWUkClpmIKZcKk00fNy(0njV9jPZEP3Mj3o0mBaYvHBiPoD02imBLJuHMU4uvK7vb7wEDaUUjSdTgiMrQ8cjhPcnDXPQBBQ7zxK7vb7wESufULxT9jPZEPdW1nHRafoVdjXJcrtD32KmQc3YRIFma3o092SjbRafoVdjWIWT8KnivOPlovXpgGBh6EB2KG9fbKqQlY9QGDlpuqQqtxCQ62M6E2f5EvWULhlbm0pEhsB1omRSclhbKq0ufxUEd2Hg3xCcJTdnRS62MyPmeSRc3YdJi5SqOCExfULxNByN5t3KCy22BFumXm2HMWL3iZgG8vbaOclh1tGEB2KG1slkivOPlovDBtDp7ICVky3YJTmCWothdcdKjCb7X4pumivOPlofJ)OEmI8CyYXXWggKIbvCf7XuWkAkgpJHoCbsXyoogXJcrt4yuifJYXzmTzYjWyasymiKLJIjbI5vZMeSgSRc3YdJi5SaPcnDXjMlyQNaaD0cq5nYCbt9MpgN6cf72HwEJmF6MKdyqQV4k27TzYTdnZzRCm5mJu5fsUitoy28QWYr9eO3MnjyfsB1omlvHB5vbmi1xCf7vGcN3HK4rHOPUBBsgvHB5vXpgGBh6EB2KGvGcN3Heyr4wEYM3rQqtxCQIFma3o092Sjb7lciHuxK7vb7wEOiYKdMnVk(XaC7q3BZMeScPTAhMLIm5GzZRclh1tGEB2KGviTv7WiafrMCWS5vHLJ6jqVnBsWkK2QDywcyOF8oK2QDyMna5YePcnDXPkGbP(IRyV3Mj3o0O4kNoVclh1tGEB2KGOSkaavy5OEc0BZMeScMnVGDMogMOh6IHjqHGcf72Hog2GRBkgjhAnqmhdByqkguXvSJJb)KfoymlkMcMaJXZyqthbvNIHji9yKCiPnGJrpWy8mg6fNoWyqfxXobJbHMIDcwd2vHB5HrKCwayqQV4k2zUGPEca0rlaL3iZfm1B(yCQluSBhA5nYSbixMivOPlovbmi1xCf792m52HgfKk00fNQUTPUNDrUxfSB5Xwggfv4gsQthTncZw5ivOPlovFuiyxOyVdW1nHDO1aHImbmiHDf6eSQc3qsOiZvbaO(KEh7qsBOwAr59vbaO(qQBh6EPTwArrfULxfGRBc7qRbQsVqIItDiTv7WSKHRYaRSkEuiAc3bGQWT8uoBLlleeSZ0XGWlq7qhdByqc7k0jiZXWggKIbvCf74yuiftbtGXGTTXviNXy8mgWc0o0XWGCVky3YRgJSfDeu5Cgzog)HymgfsXuWeymEgdA6iO6ummbPhJKdjTbCmnFOlgb0CCmnnopMl9ywumnvStGXOhymnn)jguXvStWyqOPyNGmhJ)qmgd(jlCWywum4wiPGXKfpgpJzR25QDX4pumOIRyNGXGqtXobJzvaaQb7QWT8Wisolami1xCf7mxWupba6OfGYBK5cM6nFmo1fk2TdT8gz2aKdyqc7k0jyvfUHKqr8Oq0eMTYBefzIuHMU4ufWGuFXvS3BZKBhAuExMQWT8QagKwkNxPxirXTdnkYufULxTLryU4k2R21b4g6hhLvbaO(qQBh6EPTwAzLvv4wEvadslLZR0lKO42HgfzUkaa1N07yhsAd1slRSQc3YR2YimxCf7v76aCd9JJYQaauFi1TdDV0wlTOiZvbaO(KEh7qsBOwArqWothdcdzAGXi02w7qhdByqkguXvShJ4rHOjCmnFmofJ4rVJ42HogPhdWTdDmVA2KGb7QWT8Wisolami1xCf7mxWuV5JXPUqXUDOL3iZgGCv4wEv8Jb42HU3MnjyLEHef3o0Oau48oKepken1DBtSufULxf)yaUDO7TztcwDt0qhsGfHB5HYQaauFsVJDiPnubZMhkUTj22idhSRc3YdJi5SqOCExfULxNByN5t3KCSRhOcb7W0v3YJzdqosfA6Itv32u3ZUi3Rc2T8yldJYQaauHLJ6jqVnBsWky28c2vHB5HrKCwGfju8eShSRc3YdxvHBiPURC6CSCUH0o09vUxmBaYvHBiPoD02imBBeLvbaOkY9QGDlVky28q5DKk00fNQUTPUNDrUxfSB5XwrMCWS5v5gs7q3x5Evblq1T8yLvKk00fNQUTPUNDrUxfSB5Xs5mmcc2vHB5HRQWnKu3voDogrYzXMCkHmBaYrQqtxCQ62M6E2f5EvWULhlLZWSY67Im5GzZRUjNsyfSav3YJLivOPlovDBtDp7ICVky3Ydfz6kNoVclh1tGEB2KGiGvwDLtNxHLJ6jqVnBsquwfaGkSCupb6TztcwlTOGuHMU4u1Tn19SlY9QGDlp2Qc3YRUjNsyvKjhmBESYkGH(X7qAR2HzjsfA6Itv32u3ZUi3Rc2T8c2vHB5HRQWnKu3voDogrYzbiurNhUVGK6pmBaYDLtNxvo9c2HkgHof3bkqgr59vbaOkY9QGDlVky28qrMRcaq9j9o2HK2qT0IGG9GDv4wE4Qi3Rc2T86Im5GzZdlVnDlVGDv4wE4Qi3Rc2T86Im5GzZdJi5SyXZeSduGmgSRc3Ydxf5EvWULxxKjhmBEyejNflcIjyd2HMzdq(Qaauf5EvWULxT0gSRc3Ydxf5EvWULxxKjhmBEyejNfagKw8mbd2vHB5HRICVky3YRlYKdMnpmIKZc9ee2HkVluopyxfULhUkY9QGDlVUitoy28WisolCBt9MkSLzdqoSCeqcrtvN2Tju59MkSfLvbaOsV8OfSB5vlTb7QWT8WvrUxfSB51fzYbZMhgrYzrbtDZPnZeaaj8(PBsoAUcAQNqCFPGOPGDv4wE4Qi3Rc2T86Im5GzZdJi5SOGPU50M5t3KC7WcyX1fN6VwrpVS7Gestqb7QWT8WvrUxfSB51fzYbZMhgrYzrbtDZPnZNUj5aCDt9eOVu35uWUkClpCvK7vb7wEDrMCWS5HrKCwuWu3CAZ8PBsEtTb6iiUdaZdmyxfULhUkY9QGDlVUitoy28WisolkyQBoTz(0nj3oSdlcpH4oOH0oQViopyxfULhUkY9QGDlVUitoy28WisolkyQBoTz(0njhxUfptWUUj)HrShSRc3Ydxf5EvWULxxKjhmBEyejNffm1nN24G9GDv4wE4Qi3Rc2T86TpkMKZn0poUZeUaIEtNZSbiFvaaQICVky3YRcMnVGDMogecSBB1PyEYMXWZdDmmi3Rc2T8IPPX5XWvShJ)Oxd4y8mgPYfdti7q)goguXjm2o0X4zmGKtWTDumpzZyyddsXGkUIDCm4NSWbJzrXuWeynyxfULhUkY9QGDlVE7JIjejNfivOPloXCbt9eaOJwakVrMlyQ38X4uxOy3o0YBK5t3KC6fNoqcSlY9QGDlVoK2QDyMZw5yYzgPYlK8vbaOkY9QGDlVkK2QDyeTkaavrUxfSB5vblq1T8KnVlYKdMnVQi3Rc2T8QqAR2Hz5Qaauf5EvWULxfsB1omcy2aKlYdSyE1oacEkVluSqbPGDMogegiiog)HIbSav3YlMeig)HIrQCXWeYo0VHJbvCcJTdDmmi3Rc2T8IXZy8hkg6aJjbIXFOyefiKopggK7vb7wEXyaX4pumcf7X0mlCWye5ULtofdybAh6y8hdhddY9QGDlVAWUkClpCvK7vb7wE92hftisolqQqtxCI5cM6jaqhTauEJmxWuV5JXPUqXUDOL3iZNUj50loDGeyxK7vb7wEDiTv7WmNTYvqqMrQ8cjhPcnDXPkUHvhSav3YJzdqUipWI5v7ai4P8UqXcfKq59vbaOIlxVb7qJ7loHX2HUdjfKXAPLvwrQqtxCQsV40bsGDrUxfSB51H0wTdZ2gRYGSbTaSU1xKnVVkaavC56nyhACFXjm2o01T(sh7QObzCvaaQ4Y1BWo04(ItySDORyxfnGaeeSRc3Ydxf5EvWULxV9rXeIKZILIUNaDhAIgWmBaYxfaGQi3Rc2T8QGzZlyxfULhUkY9QGDlVE7JIjejNfCdPDO7RCVy2aKRc3qsD6OTry22ikRcaqvK7vb7wEvWS5fSZ0XWez(tw8yEfhabpLhdduSqbjMJHjCb7XuWumSHbPyqfxXooMMp0fJ)qmgtZ8EZJzxoXtmcO54y0dmMMp0fdByqc7jChJHJbmBE1GDv4wE4Qi3Rc2T86TpkMqKCwayqQV4k2zUGPEca0rlaL3iZfm1B(yCQluSBhA5nYSbixMI8alMxTdGGNY7cfluqcfXJcrty2kVruwfaGQi3Rc2T8QLwuK5QaaubmiH9eURLwuK5QaauFsVJDiPnulTO8KEh7qsBOJBjoh3TRdWn0poIwfaG6dPUDO7L2APLLYkyNPJHjY8NyEfhabpLhdduSqbjMJHnmifdQ4k2JPGPyWpzHdgZIIrbbn3Yt5CgJrKh2HQDeym4mg)r9ympgdhZLEmlkMcMaJPCCcJJ5vCae8uEmmqXcfKIXWXORS4X4zm0lTgKIjHX4peKIrHum7esX4p6fdDzb9tmSHbPyqfxXoogpJHEXPdmMxXbqWt5XWafluqkgpJXFOyOdmMeiggK7vb7wE1GDv4wE4Qi3Rc2T86TpkMqKCwGuHMU4eZfm1taGoAbO8gzUGPEZhJtDHID7qlVrMpDtYPxAjHtGDads9fxXoM5SvoMCMrQ8cjxfULxfWGuFXvSxfpkenH7aqv4wEkhrVJuHMU4uLEXPdKa7ICVky3YRdPTAhwgxfaGQDae8uExOyHcsvWcuDlpeWMkYKdMnVkGbP(IRyVcwGQB5XSbixKhyX8QDae8uExOyHcsb7QWT8WvrUxfSB51BFumHi5SaPcnDXjMlyQNaaD0cq5nYCbt9MpgN6cf72HwEJmF6MKFebsGDads9fxXoM5SvoMCMrQ8cjxqg)DKk00fNQ0loDGeyxK7vb7wEDiTv7WSPVVkaav7ai4P8UqXcfKQGfO6wEYiAbyDRVGaeWSbixKhyX8QDae8uExOyHcsb7QWT8WvrUxfSB51BFumHi5SaWGuFXvSZCbt9eaOJwakVrMlyQ38X4uxOy3o0YBKzdqUipWI5v7ai4P8UqXcfKqr8Oq0eMTYBeL3rQqtxCQsV0scNa7agK6lUIDmBLJuHMU4u9icKa7agK6lUIDmRSIuHMU4uLEXPdKa7ICVky3YRdPTAhMLYxfaGQDae8uExOyHcsvWcuDlpwzDvaaQ2bqWt5DHIfkivXUkAGLYIvwxfaGQDae8uExOyHcsviTv7WSeTaSU1xyLvrMCWS5vXpgGBh6EB2KGviPGmIIkCdj1PJ2gHzRCKk00fNQICVky3YRJFma3o092SjbrrKiPtpVEg6hVdOecqzvaaQICVky3YRwAr5DzUkaavadsypH7APLvwxfaGQDae8uExOyHcsviTv7WSKHRYacqrMRcaq9j9o2HK2qT0IYt6DSdjTHoUL4CC3Uoa3q)4iAvaaQpK62HUxARLwwkRGDv4wE4Qi3Rc2T86TpkMqKCwiuoVRc3YRZnSZ8PBsUkCdj1DLtNJd2vHB5HRICVky3YR3(OycrYzHi3Rc2T8yUGPEca0rlaL3iZfm1B(yCQluSBhA5nYSbiFvaaQICVky3YRcMnpuqQqtxCQ62M6E2f5EvWULhlLZWO8UmHLJasiAQcAyH1YTtHm2f5ERhiRSUkaavqdlSwUDkKXUi3B9aRLwwzDvaaQGgwyTC7uiJDrU36b2bGj2RLwuCLtNxHLJ6jqVnBsquezYbZMxDvaa6GgwyTC7uiJDrU36bwHKcYicq5DzclhbKq0ufn0WCg7MWeCIvwbPvbaOIgAyoJDtycovlTiaL3LPirsNEE9ibm5jeKvwfzYbZMxfKu)zLWJQqAR2HzL1vbaOcsQ)Ss4r1slcq5DzksK0PNxrsN)WiKvwfzYbZMxDBqycX9eO7jCtNxH0wTdJauExfULxDtoLWQDDaUH(XrrfULxDtoLWQDDaUH(X7qAR2HzPCKk00fNQICVky3YRluS3H0wTdZkRQWT8Qyrcfpv6fsuC7qJIkClVkwKqXtLEHefN6qAR2HzjsfA6ItvrUxfSB51fk27qAR2HzLvv4wEvadslLZR0lKO42Hgfv4wEvadslLZR0lKO4uhsB1omlrQqtxCQkY9QGDlVUqXEhsB1omRSQc3YR2YimxCf7v6fsuC7qJIkClVAlJWCXvSxPxirXPoK2QDywIuHMU4uvK7vb7wEDHI9oK2QDywzvfULxfGRBc7qRbQsVqIIBhAuuHB5vb46MWo0AGQ0lKO4uhsB1omlrQqtxCQkY9QGDlVUqXEhsB1omcc2z6yyZ(dbJrKjhmBE4y8h1Jb)KfoymlkMcMaJPP5pXWGCVky3Ylg8tw4GXKhNXywumfmbgttZFIrVyuHxuEmmi3Rc2T8IrOypg9aJ5spMMM)eJgJu5IHjKDOFdhdQ4egBh6yAHPOgSRc3Ydxf5EvWULxV9rXeIKZcHY5Dv4wEDUHDMpDtYf5EvWULxxKjhmBEyMna5RcaqvK7vb7wEviTv7WSfHIvwfzYbZMxvK7vb7wEviTv7WSugc2vHB5HRICVky3YR3(OycrYzbax3e2HwdeZgG83xfaG6t6DSdjTHAPffv4gsQthTncZw5ivOPlovf5EvWULxhGRBc7qRbcbSY67RcaqfWGe2t4UwArrfUHK60rBJWSvosfA6ItvrUxfSB51b46MWo0AGKry5iGeIMQagKWEc3iiyxfULhUkY9QGDlVE7JIjejNfTmcZfxXoZgG8vbaOIlxVb7qJ7loHX2HUdjfKXAPfLvbaOIlxVb7qJ7loHX2HUdjfKXkK2QDy2kuS3DBtb7QWT8WvrUxfSB51BFumHi5SOLryU4k2z2aKVkaavadsypH7APnyxfULhUkY9QGDlVE7JIjejNfTmcZfxXoZgG8vbaO2YimfCfVRLwuwfaGAlJWuWv8UcPTAhMTcf7D32ekVVkaavrUxfSB5vH0wTdZwHI9UBBIvwxfaGQi3Rc2T8QGzZdbOOc3qsD6OTrywIuHMU4uvK7vb7wEDaUUjSdTgOGDv4wE4Qi3Rc2T86TpkMqKCw0YimxCf7mBaYxfaG6t6DSdjTHAPfLvbaOkY9QGDlVAPnyxfULhUkY9QGDlVE7JIjejNfTmcZfxXoZgG8wiHSJwawBSIfju8GYQaauFi1TdDV0wlTOOc3qsD6OTrywIuHMU4uvK7vb7wEDaUUjSdTgiuwfaGQi3Rc2T8QL2GDMogMySDOJr6XaC7qhZRMnjymGfODOJHb5EvWULxmEgdKWEcPyyddsXGkUI9y0dmMx9jPZEjg2GRBkgXJcrt4ye6fZIIzrhbyct5mhZQ4XuWfLZzmM84mgtEXGWseIAWUkClpCvK7vb7wE92hftisolWpgGBh6EB2KGmBaYxfaGQi3Rc2T8QLwuKPkClVkGbP(IRyVkEuiAcJIkCdj1PJ2gHzRCKk00fNQICVky3YRJFma3o092SjbrrfULxT9jPZEPdW1nHRafoVdjXJcrtD32eBbkCEhsGfHB5XSDobHLwVBaYvHB5vbmi1xCf7vXJcrty5QWT8QagK6lUI96wFPlEuiAchSRc3Ydxf5EvWULxV9rXeIKZI2NKo7Loax3eMzdq(Qaauf5EvWULxT0IIdvKeV72My5Qaauf5EvWULxfsB1omkV)UkClVkGbP(IRyVkEuiAcZYgrXvoDETLryk4kEJIkCdj1PJ2gHL3icyLvz6kNoV2YimfCfVzLvv4gsQthTncZ2grakRcaq9Hu3o09sBT0ION07yhsAdDClX54UDDaUH(XzPSc2vHB5HRICVky3YR3(OycrYzbax3e2HwdeZgG8vbaOkY9QGDlVky28qrKjhmBEvrUxfSB5vH0wTdZsHI9UBBcfv4gsQthTncZw5ivOPlovf5EvWULxhGRBc7qRbkyxfULhUkY9QGDlVE7JIjejNfagKwkNZSbiFvaaQICVky3YRcMnpuezYbZMxvK7vb7wEviTv7WSuOyV72MqrMI8alMxb46M6Qqaj3YlyxfULhUkY9QGDlVE7JIjejNfyrcfpmBaYxfaGQi3Rc2T8QqAR2HzRqXE3TnHYQaauf5EvWULxT0YkRRcaqvK7vb7wEvWS5HIitoy28QICVky3YRcPTAhMLcf7D32uWUkClpCvK7vb7wE92hftisol4gs7q3x5EXSbiFvaaQICVky3YRcPTAhMLOfG1T(ckQWnKuNoABeMTngSRc3Ydxf5EvWULxV9rXeIKZcqOIopCFbj1Fy2aKVkaavrUxfSB5vH0wTdZs0cW6wFbLvbaOkY9QGDlVAPnypyNPJHjG4TemgKk00fNIXFupgrEUAhog)HIrfEr5Xqy32QtGX42MIXFupg)HI5Ox8yyqUxfSB5fttJZJzrXajfKXAWUkClpCvK7vb7wED322HwosfA6ItmF6MKlY9QGDlVoKuqg7UTjMrQ8cjxKjhmBEvrUxfSB5vH0wTdlBOxAjHtG9gSdKBh6oKalc3YlyNPJbXpumcf7X42MIjbIXFOyWTeNhJ)OEmnnopMfftlKek2JXopJHb5EvWULxnyxfULhUkY9QGDlVUBB7qJi5SaPcnDXjMpDtYf5EvWULxVfscf7D32eZivEHK)UkClVkGbPLY5vHI9UBBs2itrEGfZRaCDtDviGKB5Hiv4wEvSiHINQqXE3TnHirEGfZRaCDtDviGKB5HazZ7QWnKuNoABeMLivOPlovf5EvWULxhGRBc7qRbcbisfULxfGRBc7qRbQkuS3DBtYM3vHBiPoD02imBLJuHMU4uvK7vb7wEDaUUjSdTgieiJivOPlovf5EvWULxxOyVdPTAhoyxfULhUkY9QGDlVUBB7qJi5SaPcnDXjMpDtYf5EvWULx3TnXmsLxi5ivOPlovf5EvWULxhskiJD32uWothdcN4kJXWGCVky3YlgGegJc4emg2WGe2vOtWykhNW4yqQqtxCQcyqc7k0jyxK7vb7wEXy4yWKxd2vHB5HRICVky3YR722o0isolqQqtxCI5t3KCrUxfSB51DBtmNTY36lmJu5fsoGbjSRqNGviTv7WmBaYDLtNxbmiHDf6eefzIuHMU4ufWGe2vOtWUi3Rc2T8c2z6yq4exzmggK7vb7wEXaKWyqivqtppgPwf2qmgqmMhttJZJrKBkMeaigrMCWS5fdoZRgSRc3Ydxf5EvWULx3TTDOrKCwGuHMU4eZNUj5ICVky3YR72MyoBLV1xygPYlKCrMCWS5vHkOPN3XTkSHkK2QDyMna5IejD651gyeA6HIitoy28Qqf00Z74wf2qfsB1oSm2idZsKk00fNQICVky3YR72Mc2z6yq4exzmggK7vb7wEXaKWyqOzqycXXKaXG4eUPZd2vHB5HRICVky3YR722o0isolqQqtxCI5t3KCrUxfSB51DBtmNTY36lmJu5fsUitoy28QBdctiUNaDpHB68kK2QDyMna5IejD65vK05pmcrrKjhmBE1TbHje3tGUNWnDEfsB1oSmklzGLivOPlovf5EvWULx3TnfSZ0XGWjUYymmi3Rc2T8IbiHXGWj1Fwj8OAWUkClpCvK7vb7wED322HgrYzbsfA6ItmF6MKlY9QGDlVUBBI5Sv(wFHzKkVqYfzYbZMxfKu)zLWJQqAR2Hr07RcaqfKu)zLWJQGfO6wEY4Qaauf5EvWULxfSav3YdbYgy5iGeIMQGK6p4oG6p5MzdqUirsNEE9ibm5jeefrMCWS5vbj1Fwj8OkK2QDyzSrgMLivOPlovf5EvWULx3TnfSZ0XGWjUYymmi3Rc2T8IbiHXGWj1FEdhdBO(tUJb7QObCmgqm(dbPyuifJ6XWjf7X4nZyCfIMCCnyxfULhUkY9QGDlVUBB7qJi5SaPcnDXjMpDtYf5EvWULx3TnXC2kFRVWmsLxi5RcaqfKu)zLWJQqAR2HLXvbaOkY9QGDlVkybQULhZgGCy5iGeIMQGK6p4oG6p5gLvbaOcsQ)Ss4r1slkQWnKuNoABeMTYLvWothdcN4kJXWGCVky3YlgGegJ)qXGqSBzeskpg2me80tqXSkaaXyaX4pumTCLrcgJHJPGTdDm(J6X4q7AG8AWUkClpCvK7vb7wED322HgrYzbsfA6ItmF6MKlY9QGDlVUBBI5Sv(wFHzKkVqYrQqtxCQs7wgHKY7je80tqDqIRmkJVlYKdMnVkTBzeskVNqWtpbvblq1T8KrrMCWS5vPDlJqs59ecE6jOkK2QDyeiBKPitoy28Q0ULriP8Ecbp9eufskiJmBaYPxRyTTeyL2TmcjL3ti4PNGc2z6yq4exzmggK7vb7wEXaKWyKT4kOPEcXXGkfenXCmLJtyCmMhtZSWbJzrXasCLrcmgEEOjym(JEXilgogmjYdexd2vHB5HRICVky3YR722o0isolqQqtxCI5t3KCrUxfSB51DBtmNTY36lmJu5fsUitoy28QO5kOPEcX9LcIM6VUSxgKLSqOQqAR2Hz2aKtVwXABjWkAUcAQNqCFPGOjuezYbZMxfnxbn1tiUVuq0u)1L9YGSKfcvfsB1oSmklgMLivOPlovf5EvWULx3TnfSZ0XGWjUYymmi3Rc2T8IPCUXJbHmF1yOxAniHJXaIX83WXuARb7QWT8WvrUxfSB51DBBhAejNfivOPloX8PBsUi3Rc2T86UTjMZw5B9fMrQ8cjFvaaQWYr9eO3MnjyfsB1omZgGCx505vy5OEc0BZMeeLvbaOkY9QGDlVky28c2z6yq4exzmggK7vb7wEXaKWy0lg6fhQXGqwokMeiMxnBsWymGy8hkgeYYrXKaX8QztcgtZSWbJrKBkMeaigrMCWS5fJ6XWjf7XidXGjrEG4yweqcPyyqUxfSB5ftZSWbRb7QWT8WvrUxfSB51DBBhAejNfivOPloX8PBsUi3Rc2T86UTjMZw5B9fMrQ8cjxKjhmBEvy5OEc0BZMeScPTAhgrRcaqfwoQNa92SjbRGfO6wEmBaYDLtNxHLJ6jqVnBsquwfaGQi3Rc2T8QGzZdfrMCWS5vHLJ6jqVnBsWkK2QDyejdSePcnDXPQi3Rc2T86UTPGDMogeoXvgJHb5EvWULxmgqmiCdlSwUDkKXyyqU36bgtZSWbJ5spMffdKuqgJbiHXyEmmsEnyxfULhUkY9QGDlVUBB7qJi5SaPcnDXjMpDtYf5EvWULx3TnXC2kFRVWmsLxi5Im5GzZRUkaaDqdlSwUDkKXUi3B9aRqAR2Hz2aKdlhbKq0uf0WcRLBNczSlY9wpquwfaGkOHfwl3ofYyxK7TEGvWS5fSZ0XGqQgymieiPZXmzmiCIRmgddY9QGDlVyasymkiym4wT5HJjbI51JjHXStifJccIJXFupMMgNhdxXEm88qtWy8h9IPrzigmjYdexJbXpeMIbPYleogfs3BEmhjimwHgNXyYw32kpg7Ir58yekMW1GDv4wE4Qi3Rc2T86UTTdnIKZcKk00fNy(0njxK7vb7wED32eZzR8T(cZivEHKdvdStiPZRkiiUAhZgGCOAGDcjDEvbbXv6fd7yuGQb2jK05vfeexfz5C2k)1rbQgyNqsNxvqqCfSav3YJTnkdb7mDmiKQbgdcbs6CmtgdcJ3uzehtbtXWGCVky3YlMMM)edYc)iOUmU5mgdunWyiK05yMJjrsqObsXOhJXasCLrCmCd7eym6krsX4zmBTbkgCbsXyEmOjhhtbtGX8qqQgSRc3Ydxf5EvWULx3TTDOrKCwGuHMU4eZNUj5ICVky3YR72MygPYlKCOAGDcjDEfzHFeuxCQANSrMq1a7es68kYc)iOU4uT0YSbihQgyNqsNxrw4hb1fNQ0lg2XOGuHMU4uvK7vb7wEDiPGm2DBtSeQgyNqsNxrw4hb1fNQ2fSZ0XWeJPy8hkMJEXJHb5EvWULxm5fJitoy28IXaIX8yAMfoymx6XSOyOxAjHtGX4zmGexzmg)HIblEiWcNaJjpkMegJ)qXGfpeyHtGXKhftZSWbJ5rBBPlgoHXX4p6fJSy4yWKipqCmlciHum(dfdGH(XJHoqCnyxfULhUkY9QGDlVUBB7qJi5SaPcnDXjMpDtYf5EvWULx3TnXmsLxi5ivOPlovf5EvWULxhskiJD32eZgGCKk00fNQICVky3YRdjfKXUBBcrIm5GzZRkY9QGDlVkybQULNS59gLX3z46RermCvwYgx505vadsyxHobrGSXvoDETb7a52HgbSuosfA6ItvrUxfSB51DBtSYksfA6ItvrUxfSB51DBtSfWq)4DiTv7WYOSy4GDMogegiym(dfJOaH05X42MIXZy8hkgS4HalCcmggK7vb7wEX4zmTfpgZJXUy0fo5fNIXTnfdoJXFupgZJXWXGDJZJrfIcuDkgfWjymAmCZDofJBBkMwfJjCnyxfULhUkY9QGDlVUBB7qJi5SaPcnDXjMpDtYf5EvWULx3TnXC2kxbbzgPYlKC32uWothdByNY5mYCmI8qsqpgayUJrx4KxCkg32um6bgd2tifJ)qXajU6gskg32um2fdsfA6Itv32u3ZUi3Rc2T8QXWeFCRbkg)HIbsypMeig)HIrOCrHRULhM5yA(yINyE02w6IHtyCmaq61k05CgJXZyWTebgtPng)HIbB7cxDlpMJXFmCmpABlD4ysaazu2Ibi8y0dmMMpgNIrOy3o01GDv4wE4Qi3Rc2T86UTTdnIKZcKk00fNyUGPEca0rlaL3iZfm1B(yCQluSBhA5nY8PBsUBBQ7zxK7vb7wEmJu5fs(7ivOPlovf5EvWULx3TnjJUTjeiBwfaGQi3Rc2T8QGzZlypyxfULhUcZ2E7JIj5aCDtyhAnqmBaYvHBiPoD02imBLJuHMU4u9j9o2HK2qhGRBc7qRbcL3xfaG6t6DSdjTHAPLvwxfaGkGbjSNWDT0IGGDv4wE4kmB7TpkMqKCwayqAPCoZgG8vbaOcsQ)Ss4r1slkWYrajenvbj1FWDa1FYnkivOPlovDBtDp7ICVky3YJLRcaqfKu)zLWJQqAR2HrrfUHK60rBJWSvUSc2vHB5HRWST3(OycrYzrlJWCXvSZSbiFvaaQ4Y1BWo04(ItySDO7qsbzSwArzvaaQ4Y1BWo04(ItySDO7qsbzScPTAhMTcf7D32uWUkClpCfMT92hftisolAzeMlUIDMna5RcaqfWGe2t4UwAd2vHB5HRWST3(OycrYzrlJWCXvSZSbiFvaaQpP3XoK0gQL2GDMogMymftEumSHbPyqfxXEmKc5mgJDXGqMVAmgqmmMLyaZ7npMhfjfdz(dbJHjGu3o0XWe3gtcJHji9yKCiPnedJKhJEGXqM)qqMmM3veeZJIKIzNqkg)rVy8MzmkhskiJmhZ7leeZJIKIbHXPxWouXi0PVHJHnkqgJbskiJX4zmfmXCmjmM3fiigjsH2HogeNfXtmgogv4gsQgdcpV38yaZy8hdhtZhJtX8OqWyek2TdDmSbx3e2HwdeoMegtZh6IrQCXWeYo0VHJbvCcJTdDmgogiPGmwd2vHB5HRWST3(OycrYzbGbP(IRyN5cM6jaqhTauEJmxWuV5JXPUqXUDOL3iZgGCzIuHMU4ufWGuFXvS3BZKBhAuwfaGkUC9gSdnUV4egBh6oKuqgRGzZdfv4gsQthTncZsKk00fNQpkeSluS3b46MWo0AGqrMagKWUcDcwvHBijuExMRcaq9Hu3o09sBT0IImxfaG6t6DSdjTHAPffz2cjK9eaOJwawbmi1xCf7O8UkClVkGbP(IRyVkEuiAcZw5YIvwF3voDEv50lyhQye6uChOazefrMCWS5vbHk68W9fKu)PcjfKreWkRysH2HU7zr8uvHBijeGGGDMogMymfdByqkguXvShdz(dbJbSaTdDmAmSHbPLY5S4vzeMlUI9yek2JP5dDXWeqQBh6yyIBJXWXOc3qsXKWyalq7qhd9cjkofttZFIrIuODOJbXzr8ud2vHB5HRWST3(OycrYzbGbP(IRyN5cM6jaqhTauEJmxWuV5JXPUqXUDOL3iZgGCzIuHMU4ufWGuFXvS3BZKBhAuKjGbjSRqNGvv4gscL3F)Dv4wEvadslLZR0lKO42HgL3vHB5vbmiTuoVsVqIItDiTv7WSKHRYaRSkty5iGeIMQagKWEc3iGvwvHB5vBzeMlUI9k9cjkUDOr5Dv4wE1wgH5IRyVsVqIItDiTv7WSKHRYaRSkty5iGeIMQagKWEc3iabOSkaa1hsD7q3lT1slcyL13XKcTdD3ZI4PQc3qsO8(QaauFi1TdDV0wlTOitv4wEvSiHINk9cjkUDOzLvzUkaa1N07yhsAd1slkYCvaaQpK62HUxARLwuuHB5vXIekEQ0lKO42Hgfz(KEh7qsBOJBjoh3TRdWn0pocqacc2vHB5HRWST3(OycrYzHq58UkClVo3WoZNUj5QWnKu3voDooyxfULhUcZ2E7JIjejNfTmcZfxXoZgG8vbaO2YimfCfVRLwuek27UTjwUkaa1wgHPGR4DfsB1omkcf7D32elxfaGkSCupb6TztcwH0wTdhSRc3YdxHzBV9rXeIKZIwgH5IRyNzdq(QaauFsVJDiPnulTOGjfAh6UNfXtvfUHKqrfUHK60rBJWSePcnDXP6t6DSdjTHoax3e2HwduWUkClpCfMT92hftisolAFs6Sx6aCDtyMna5YePcnDXPA7tsN9sVntUDOrzvaaQpK62HUxARLwuK5QaauFsVJDiPnulTO8UkCdj1btVAOpZjwklwzvfUHK60rBJWSvosfA6It1hfc2fk27aCDtyhAnqSYQkCdj1PJ2gHzRCKk00fNQpP3XoK0g6aCDtyhAnqiiyxfULhUcZ2E7JIjejNfyrcfpmBaYXKcTdD3ZI4PQc3qsb7QWT8Wvy22BFumHi5SaeQOZd3xqs9hMna5QWnKuNoABeMTYkyxfULhUcZ2E7JIjejNfkuOh1PxA5j2YJzdqUkCdj1PJ2gHzRCKk00fNQkuOh1PxA5j2YdLTEATv4SvosfA6Itvfk0J60lT8eB5136PO4ken51MM)yxJmCWothdtK5pXqxwq)eJRq0KJzogZJXWXOXGwTlgpJrOypg2GRBc7qRbkgfhdGX5emg7WoPGXKaXWggKwkNxd2vHB5HRWST3(OycrYzbax3e2HwdeZgGCv4gsQthTncZw5ivOPlovFuiyxOyVdW1nHDO1afSRc3YdxHzBV9rXeIKZcadslLZd2d2vHB5HRyxpqfc2HPRULNCaUUjSdTgiMna5QWnKuNoABeMTYrQqtxCQ(KEh7qsBOdW1nHDO1aHY7Rcaq9j9o2HK2qT0YkRRcaqfWGe2t4UwArqWUkClpCf76bQqWomD1T8qKCwayqAPCoZgG8vbaOcsQ)Ss4r1slkWYrajenvbj1FWDa1FYnkivOPlovDBtDp7ICVky3YJLRcaqfKu)zLWJQqAR2HzRCzfSRc3YdxXUEGkeSdtxDlpejNfTmcZfxXoZgG8vbaOcyqc7jCxlTb7QWT8WvSRhOcb7W0v3YdrYzrlJWCXvSZSbiFvaaQpP3XoK0gQLwuwfaG6t6DSdjTHkK2QDywQc3YRcyqAPCELEHefN6UTPGDv4wE4k21duHGDy6QB5Hi5SOLryU4k2z2aKVkaa1N07yhsAd1slkV3cjKD0cWAJvadslLZzLvadsyxHobRQWnKeRSQc3YR2YimxCf7v76aCd9JJGGDMogedzmgpJbn5XiXecvX0ctbog7Wgifdcz(QX0(OychtcJHb5EvWULxmTpkMWX08HUyAtm2wCQgSRc3YdxXUEGkeSdtxDlpejNfTmcZfxXoZgG8vbaOIlxVb7qJ7loHX2HUdjfKXAPfL3fzYbZMxfwoQNa92SjbRqAR2HrKkClVkSCupb6TztcwPxirXPUBBcrcf7D32eBxfaGkUC9gSdnUV4egBh6oKuqgRqAR2HzLvz6kNoVclh1tGEB2KGiafKk00fNQUTPUNDrUxfSB5HiHI9UBBITRcaqfxUEd2Hg3xCcJTdDhskiJviTv7Wb7QWT8WvSRhOcb7W0v3YdrYzrlJWCXvSZSbiFvaaQpP3XoK0gQLwuWKcTdD3ZI4PQc3qsb7QWT8WvSRhOcb7W0v3YdrYzrlJWCXvSZSbiFvaaQTmctbxX7APffHI9UBBILRcaqTLryk4kExH0wTdhSZ0XGWlq7qhJ)qXGD9aviymW0v3YJ5yYJZymfmfdByqkguXvSJJP5dDX4peJXOqkMl9ywKDOJPntobgdqcJbHmF1ysymmi3Rc2T8QXWeJPyyddsXGkUI9yiZFiymGfODOJrJHnmiTuoNfVkJWCXvShJqXEmnFOlgMasD7qhdtCBmgogv4gskMegdybAh6yOxirXPyAA(tmsKcTdDmiolINAWUkClpCf76bQqWomD1T8qKCwayqQV4k2zUGPEca0rlaL3iZfm1B(yCQluSBhA5nYSbixMagKWUcDcwvHBijuKjsfA6Itvads9fxXEVntUDOr593FxfULxfWG0s58k9cjkUDOr5Dv4wEvadslLZR0lKO4uhsB1omlz4QmWkRYewociHOPkGbjSNWncyLvv4wE1wgH5IRyVsVqIIBhAuExfULxTLryU4k2R0lKO4uhsB1omlz4QmWkRYewociHOPkGbjSNWncqakRcaq9Hu3o09sBT0Iawz9DmPq7q39SiEQQWnKekVVkaa1hsD7q3lT1slkYufULxflsO4PsVqIIBhAwzvMRcaq9j9o2HK2qT0IImxfaG6dPUDO7L2APffv4wEvSiHINk9cjkUDOrrMpP3XoK0g64wIZXD76aCd9JJaeGGGDv4wE4k21duHGDy6QB5Hi5SOLryU4k2z2aKVkaa1N07yhsAd1slkQWnKuNoABeMLivOPlovFsVJDiPn0b46MWo0AGc2vHB5HRyxpqfc2HPRULhIKZI2NKo7Loax3eMzdqUmrQqtxCQ2(K0zV0BZKBhAuExMUYPZRaWC39hQR4hcZkRQWnKuNoABeMTnIauExfUHK6GPxn0N5elLfRSQc3qsD6OTry2khPcnDXP6Jcb7cf7DaUUjSdTgiwzvfUHK60rBJWSvosfA6It1N07yhsAdDaUUjSdTgieeSRc3YdxXUEGkeSdtxDlpejNfcLZ7QWT86Cd7mF6MKRc3qsDx5054GDv4wE4k21duHGDy6QB5Hi5SaeQOZd3xqs9hMna5QWnKuNoABeMTngSRc3YdxXUEGkeSdtxDlpejNfyrcfpmBaYXKcTdD3ZI4PQc3qsb7QWT8WvSRhOcb7W0v3YdrYzHcf6rD6LwEIT8y2aKRc3qsD6OTry2khPcnDXPQcf6rD6LwEIT8qzRNwBfoBLJuHMU4uvHc9Oo9slpXwE9TEkkUcrtETP5p21idhSZ0XWez(tm0Lf0pX4ken5yMJX8ymCmAmOv7IXZyek2JHn46MWo0AGIrXXayCobJXoStkymjqmSHbPLY51GDv4wE4k21duHGDy6QB5Hi5SaGRBc7qRbIzdqUkCdj1PJ2gHzRCKk00fNQpkeSluS3b46MWo0AGc2vHB5HRyxpqfc2HPRULhIKZcadslLZ)s4ws8r9R81)(3)Fa]] )
end
