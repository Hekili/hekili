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


    spec:RegisterPack( "Fire", 20210629, [[deLtYdqiuKEKQkDjfePnPQ0NGs1OGcDkOGvPQc1Ruv0Suv1TOkv2LGFbf1WGQIJPGAzki9muuQPHIICnfe2guK03Okf14uqeNdkszDuLQMhuvDpQI9bvP)PGOQdIIclekLhIIQjIIsUikkQncvL(ivPiJekICsQsHvIc9sOivMPQk4Mkik7efXpHIGHQQISuOiQNcIPcvXvvvHSvOi0xHIeJLQuAVO0FLyWkDyslwspgvtguxgzZk6ZG0OvOttSAOiv9AQsMnvUTQSBv(TOHtvDCvvulhYZbMoLRl02HkFxbgVQcNhkz9kiQmFuW(LA2HzXdley1iwMmu8zOdJpyQdftlGpyA4dM2qhMfIHLpXcXx5EPqjwiN(iwi4RGiwi(kwUuHzXdleqgrCIfYOz(aVhZygQyJXAGNpmdKx0PMKhhPtdZa5XXmlKAuCM34yRSqGvJyzYqXNHom(GPoumTa(GPHpyAdpeSq0OnMiwiqKhZzHmkWW0XwzHataole8vquVdzkuQzC0mFG3JzmdvSXynWZhMbYl6utYJJ0PHzG84yUzKX4r9oumT)9ou8zOd3m2mY8r9GsaVVz0769hbOENc0rRGONkhOxKAJeQxBuVEnfbLSGjpQyzbwOENjQxNcmVdq88G7vRItmS6ncuOei0m6D9(dzcORxUcSEr0phfe9OZa9otuVmpF1iWK86fJsGc)7fopSB9oMo4EfR3zI6v7DIiWyVdzKrjQxUcmmeAg9UEzMpT6OEbgs4wV8rI7LCq7nVE1EN0GENjYlqVY1Rns9Ym(PFOxl7frWro17Ge5Llv4qZO31lZagtFey9Q9(tyHYQtbwV0ziS61gvRx4Ka9EP17lHjxVdiNRx58oO6J6fJa51RraJG7vTEVSxGa9KPW1Z6Lz9tq6vE(k3WqOz076L55HJqwVQZ1BnoNbVnGiLB9sNHec0RL9wJZzWBdr))9QxVQ7LaRx5ac0tMcxpRxM1pbPxOQC9kxVa5bcnJExV)ia17OIG5jmb3lofjA1rGETSxebh5uVm)N(r9oirE5sfoWcXjadWIhwi88vJatYRWZ0bNdoalEyzYWS4HfIYnjpwi(Pj5XcHoT6iywSXASmzOS4HfIYnjpwivxMWLzeHfle60QJGzXgRXYeMnlEyHqNwDeml2yHWrIrirzHuJZzGNVAeysEHOpleLBsESqQecqiVKdkRXYeMjw8Wcr5MKhlKPGOQltywi0PvhbZInwJLjdblEyHOCtYJfIECcyi1v4QZXcHoT6iywSXASmbtLfpSqOtRocMfBSq4iXiKOSqqXJMjckfm65Ni1vgOi)aDA1rW9(T3ACod0hJAeysEHOpleLBsESqm5rLbkYN1yzI3mlEyHqNwDeml2yHOCtYJfcuNclQLiqPQWqjwi0CsCRC6JyHa1PWIAjcuQkmuI1yzYqclEyHqNwDeml2yHC6JyHihGJIMwDu5NJ6zXxbMWjCIfIYnjpwiYb4OOPvhv(5OEw8vGjCcNynwMGPXIhwi0PvhbZInwiN(iwitN(Osolv1mhXcr5MKhlKPtFujNLQAMJynwMmm(WIhwi0PvhbZInwiN(iwiduVOJqGYeLhmleLBsESqgOErhHaLjkpywJLjdpmlEyHqNwDeml2yHC6JyHihWqrULiqbwWjhvQKZXcr5MKhle5agkYTebkWco5OsLCowJLjdpuw8WcHoT6iywSXc50hXcbeVQlt4I(iBelGXcr5MKhleq8QUmHl6JSrSagRXYKHz2S4HfIYnjpwiraveJEawi0PvhbZInwJ1yHattn6mw8WYKHzXdle60QJGzXgleosmcjkleM2lkE0mrqPaSa4IVtofHvHNVNEWb60QJGzHOCtYJfcpJNriGp5CSgltgklEyHqNwDeml2yHOCtYJfcyuMMCql(5acXcbMaCK4BsESqWevKOvh1RnQwVeWKNAeO3bJKnsOEHmkttoO9(t5ac17aX56Ts9gbeCVvAMiQxMNVAeysE9kGErKcJvGfchjgHeLfsnoNbE(QrGj5fGZbxVF7v5MKxykiQuDkWc8rfbLa9IFp9oCVF7LP9IXERX5mi3KqN6kCfWvyke979BV14CggtRamePEfqKYTEXqVF7fNIeT6OayuMMCql(5acvQ0mruHNVAeysESglty2S4HfcDA1rWSyJfchjgHeLfsnoNbE(QrGj5fGZbxVF7fJ9ItrIwDuWKhvSSWZxncmjVEXFV4uKOvhf45RgbMKxXhrCfyftEuVF2l9bXJgvm5r9Yad9ItrIwDuWKhvSSWZxncmjVEXBVk3K8k8mDW5GRxVR3HXNEXaleLBsESqqkSONva(kYlwJLjmtS4HfcDA1rWSyJfchjgHeLfsnoNbE(QrGj5fGZbxVF7TgNZakEujNf)CaHcW5GR3V9ItrIwDuWKhvSSWZxncmjVEXFV4uKOvhf45RgbMKxXhrCfyftEuVF2l9bXJgvm5r9(zVyS3ACodWKAJ1eDuaoIutYRxVR3ACod88vJatYlahrQj51lg69h3lkE0mrqPamP2iOmvBmFb60QJGzHOCtYJfcmP2ynrhXASmziyXdle60QJGzXgleosmcjkleCks0QJcM8OILfE(QrGj51l(7fNIeT6OapF1iWK8k(iIRaRyYJ69ZEPpiE0OIjpQ3V9wJZzGNVAeysEb4CWXcr5MKhlKNGqjcuYzXs0JoJ1yzcMklEyHqNwDeml2yHebuzWO4OcxbMCqzzYWSqGjahj(MKhle8nr9IjsNnIf6FVra1R2l(kiQxS5uG1lFurqPEHJi5G27qMGqjc0Bo7fpj6rN1lxbwVw2RIlf4E5QVVCq7LpQiOeiWcr5MKhlKPGOs1PaJfchjgHeLfIYnjVWtqOebk5Syj6rNfOpiE0KdAVF7DgDUcI4Jkckvm5r96D9QCtYl8eekrGsolwIE0zb6dIhnQGONkhOx83lZuVF7LP9oMwbyis9Qa8jNduKRmDc0rR3V9Y0ERX5mmMwbyis9ke9znwM4nZIhwi0PvhbZInwik3K8yHa1PWIAjcuQkmuIfchjgHeLfcofjA1rbtEuXYcpF1iWK86fV9QCtYRWZ0bNdUE9UEhcwi0CsCRC6JyHa1PWIAjcuQkmuI1yzYqclEyHqNwDeml2yHOCtYJfc98XcrQRKi4tpoXcHJeJqIYcbNIeT6OGjpQyzHNVAeysE9IFp9ItrIwDuGE(yHi1vse8PhNkWKtXQ3V9ItrIwDuWKhvSSWZxncmjVEXBV4uKOvhfONpwisDLebF6XPcm5uS6176DiyHC6JyHqpFSqK6kjc(0JtSgltW0yXdle60QJGzXgleLBsESqaJkCoGGljQwYzXs0JoJfchjgHeLfcg7fNIeT6OGjpQyzHNVAeysE9IFp9ItrIwDuGNVAeysEfFeXvGvm5r9(zVdTxgyO3PaD0ki6PYb6f)9ItrIwDuWKhvSSWZxncmjVEXqVF7TgNZapF1iWK8cW5GJfYPpIfcyuHZbeCjr1solwIE0zSgltggFyXdle60QJGzXgleLBsESqG6WYFSKZIcaYtCQj5XcHJeJqIYcbNIeT6OGjpQyzHNVAeysE9Ixp9ItrIwDuiVseqfE0Y5KfYPpIfcuhw(JLCwuaqEItnjpwJLjdpmlEyHqNwDeml2yHOCtYJfYt5AfrfWirw5fbcNfchjgHeLfcofjA1rbtEuXYcpF1iWK86f)E6DiyHC6JyH8uUwrubmsKvErGWznwMm8qzXdle60QJGzXgleycWrIVj5XcXBm7ncKdAVAVaJqPa3BEExeq9kg9(3R6gOyb6ncOEzwisHNcI6ftKaaY1BgnGat9MZEzE(QrGj5f6ftWgj0abq)71hjjsmzih1Beih0EzwisHNcI6ftKaaY17aXg7L55RgbMKxV55WQxz2R34Me6uxVmxbCfM6va9sNwDeCV6b3R2BeOqPEhKh2TERuVUey9M4iuV2i1lCePMKxV5SxBK6DkqhTqV4zua9QWWGE1Ebp156fN6IuVw2Rns9YZ0bNdUEZzVmlePWtbr9Ijsaa56DWiD9cNYbTxBua9Yvhp6utYR3kX1iG6vSEfqVXdrQdycVxl7vbG4J61gvRxX6DG4C9wPEJacUxFcnjU5WQ386LNPdohCbwiN(iwiWisHNcIk4iaGCSq4iXiKOSqWPirRokyYJkww45RgbMKxV41tV4uKOvhfYRebuHhTCo79BVyS3ACodYnj0PUcxbCfMcat5E1RNERX5mi3KqN6kCfWvyk80pkat5E1ldm0lt7LNhCuSGCtcDQRWvaxHPaDA1rW9Yad9ItrIwDuGNVAeysEL8kra1ldm0lofjA1rbtEuXYcpF1iWK86fV9kNri)0PgbxMc0rRGONkhO3H0E7fJ9QCtYRWZ0bNdUE)S3HXNEXqVyGfIYnjpwiWisHNcIk4iaGCSgltgMzZIhwi0PvhbZInwik3K8yHaYORiqpXieleosmcjklem2lofjA1rbtEuXYcpF1iWK86fVE6LzJp9(J7fJ9ItrIwDuiVseqfE0Y5Sx82l(0lg6Lbg6fJ9Y0EnKCErwWgoiGaiJUIa9eJq9(TxdjNxKfSHdrGwDuVF71qY5fzbB4apthCo4ci6PYb6Lbg6LP9Ai58ISGn0GacGm6kc0tmc173EnKCErwWgAic0QJ69BVgsoVilydnWZ0bNdUaIEQCGEXqVyO3V9IXEzAV0phfFFcoaJifEkiQGJaaY1ldm0lpthCo4cWisHNcIk4iaGCbe9u5a9I3EhIEXalKtFeleqgDfb6jgHynwMmmZelEyHqNwDeml2yHOCtYJfcxpo5k14CYcHJeJqIYcHP9YZdokwqUjHo1v4kGRWuGoT6i4E)2RjpQx837q0ldm0BnoNb5Me6uxHRaUctbGPCV61tV14CgKBsOtDfUc4kmfE6hfGPCVyHuJZz50hXcbKrxrGEIj5XcbMaCK4BsESqWdsGcLq9cjJUE9gqpXiuVKICy17aXg71BCtcDQRxMRaUct9MOEhmsxVI17af0RpI4kWcSgltgEiyXdle60QJGzXgleycWrIVj5XcXBy0d0RnQwVWzVxA9wPJMI1lZZxncmjVEbJz0b3lM(iW6Ts9gbeCVz0acm1Bo7L55RgbMKxVQ1liFuV(PCwGfYPpIfICaokAA1rLFoQNfFfycNWjwiCKyesuwi0phfFFcoa1PWIAjcuQkmuQ3V9ItrIwDuWKhvSSWZxncmjVEXRNEXPirRokKxjcOcpA5CYcr5MKhle5aCu00QJk)Cupl(kWeoHtSgltggtLfpSqOtRocMfBSquUj5Xcz60hvYzPQM5iwiCKyesuwi0phfFFcoa1PWIAjcuQkmuQ3V9ItrIwDuWKhvSSWZxncmjVEXRNEXPirRokKxjcOcpA5CYc50hXcz60hvYzPQM5iwJLjd7nZIhwi0PvhbZInwik3K8yHmq9IocbktuEWSq4iXiKOSqOFok((eCaQtHf1seOuvyOuVF7fNIeT6OGjpQyzHNVAeysE9Ixp9ItrIwDuiVseqfE0Y5KfYPpIfYa1l6ieOmr5bZASmz4Hew8WcHoT6iywSXcr5MKhle5agkYTebkWco5OsLCowiCKyesuwi0phfFFcoa1PWIAjcuQkmuQ3V9ItrIwDuWKhvSSWZxncmjVEXRNEXPirRokKxjcOcpA5CYc50hXcroGHIClrGcSGtoQujNJ1yzYWyAS4HfcDA1rWSyJfIYnjpwiG4vDzcx0hzJybmwiCKyesuwi0phfFFcoa1PWIAjcuQkmuQ3V9ItrIwDuWKhvSSWZxncmjVEXRNEXPirRokKxjcOcpA5CYc50hXcbeVQlt4I(iBelGXASmzO4dlEyHqNwDeml2yHWrIrirzHGtrIwDuWKhvSSWZxncmjVEXRNEXPirRokKxjcOcpA5CYcr5MKhlKiGkIrpaRXYKHomlEyHqNwDeml2yHOCtYJfYeLaRCjoLfcmb4iX3K8yH8JauV4lkbwVmjXP9AzVgsGcLq96nHeGdRE9gCH7Oaleosmcjkleu8OzIGsbOib4WQiCH7OaDA1rW9(T3ACod88vJatYlaNdUE)2lg7fNIeT6OGjpQyzHNVAeysE9I3EvUj5v4z6GZbxVmWqV4uKOvhfm5rfll88vJatYRx83lofjA1rbE(QrGj5v8rexbwXKh17N9sFq8OrftEuVyG1yzYqhklEyHqNwDeml2yHOCtYJfcpJNriGp5CSqGjahj(MKhleVjY61gPEzwcGl(o5uew9Y8890dU3ACo7n6)V345iaOxE(QrGj51Ra6fK5fyHWrIrirzHGIhnteukalaU47Ktryv457PhCGoT6i4E)2lpthCo4c14CwGfax8DYPiSk8890doGifgRE)2BnoNbybWfFNCkcRcpFp9GlkIRhfGZbxVF7LP9wJZzawaCX3jNIWQWZ3tp4q0V3V9IXEXPirRokyYJkww45RgbMKxVF2RYnjVWeLaRMolWvGvm5r9I3E5z6GZbxOgNZcSa4IVtofHvHNVNEWb4isnjVEzGHEXPirRokyYJkww45RgbMKxV4V3HOxmWASmzOmBw8WcHoT6iywSXcHJeJqIYcbfpAMiOuawaCX3jNIWQWZ3tp4aDA1rW9(TxEMo4CWfQX5SalaU47Ktryv457PhCarkmw9(T3ACodWcGl(o5uewfE(E6bxuexpkaNdUE)2lt7TgNZaSa4IVtofHvHNVNEWHOFVF7fJ9ItrIwDuWKhvSSWZxncmjVE)Sx6dIhnQyYJ69ZEvUj5fMOey10zbUcSIjpQx82lpthCo4c14CwGfax8DYPiSk8890doahrQj51ldm0lofjA1rbtEuXYcpF1iWK86f)9oe9(TxM2RPo6SakEujNf)CaHc0Pvhb3lgyHOCtYJfII46rf6dFxcK8ynwMmuMjw8WcHoT6iywSXcHJeJqIYcbfpAMiOuawaCX3jNIWQWZ3tp4aDA1rW9(TxEMo4CWfQX5SalaU47Ktryv457PhCarpvoqV4VxUcSIjpQ3V9wJZzawaCX3jNIWQWZ3tp4YeLalaNdUE)2lt7TgNZaSa4IVtofHvHNVNEWHOFVF7fJ9ItrIwDuWKhvSSWZxncmjVE)SxUcSIjpQx82lpthCo4c14CwGfax8DYPiSk8890doahrQj51ldm0lofjA1rbtEuXYcpF1iWK86f)9oe9Ibwik3K8yHmrjWQPZynwMm0HGfpSqOtRocMfBSq4iXiKOSqqXJMjckfGfax8DYPiSk8890doqNwDeCVF7LNPdohCHAColWcGl(o5uewfE(E6bhqKcJvVF7TgNZaSa4IVtofHvHNVNEWLjkbwaohC9(TxM2BnoNbybWfFNCkcRcpFp9Gdr)E)2lg7fNIeT6OGjpQyzHNVAeysE9I3E5z6GZbxOgNZcSa4IVtofHvHNVNEWb4isnjVEzGHEXPirRokyYJkww45RgbMKxV4V3HOxmWcr5MKhlKjkbw5sCkRXYKHIPYIhwi0PvhbZInwiCKyesuwi4uKOvhfm5rfll88vJatYRx87Px8PxgyOxCks0QJcM8OILfE(QrGj51l(7fNIeT6OapF1iWK8k(iIRaRyYJ69BV8mDW5GlWZxncmjVaIEQCGEXFV4uKOvhf45RgbMKxXhrCfyftEeleLBsESq4QZvuUj5vCcWyH4eGvo9rSq45RgbMKxXFubeRXYKH6nZIhwi0PvhbZInwiCKyesuwi14CgqXJk5S4NdiuaohC9(TxM2BnoNHPGiGLOxi6373EXyV4uKOvhfm5rfll88vJatYRx86P3ACodO4rLCw8ZbekahrQj5173EXPirRokyYJkww45RgbMKxV4TxLBsEHPGOs1PalmJoxbr8rfbLkM8OEzGHEXPirRokyYJkww45RgbMKxV4T3PaD0ki6PYb6fdSquUj5XcbfpQKZIFoGqSgltg6qclEyHqNwDeml2yHataos8njpwiykJ01Beih0EXxN(iGHeVOELRxMNVAeysE)7fO4OEvqVp9WQx(OIGsGEvqV(jaivh17mr9Y88vJatYR3bInMrRxU67lh0aleLBsESq4QZvuUj5vCcWyHamKWnwMmmleosmcjklKACodO4rLCw8Zbeke979BV4uKOvhfm5rfll88vJatYRx82l(WcXjaRC6JyHGs)I)OciwJLjdftJfpSqOtRocMfBSqIaQmyuCuHRatoOSmzywiCKyesuwimTxCks0QJctbrLQtbwXptNCq79BV4uKOvhfm5rfll88vJatYRx82l(073EvUj4OcD0tiqV41tV4uKOvhfgveCHRaRmD6Jags8I69BVmT3PGiGPiJqbLBcoQ3V9Y0ERX5mmMwbyis9ke979BVyS3ACodJKAYbTe9dr)E)2RYnjVW0PpcyiXlkqFq8Orfe9u5a9I)EXNWq0ldm0lFurqjqzIuUj5PUEXRNEhAVyGfseqLColq5WSmzywik3K8yHmfevQofySqGjahj(MKhlemLr66ftsrWCfyYbTx81PpQxigs8I(3l(kiQxS5uGb6fmMrhCVvQ3iGG71YEHshHuJ6ftkTEHyis9c0REW9AzV0hgDW9InNcmc17qMcmcfynwMWSXhw8WcHoT6iywSXcjcOYGrXrfUcm5GYYKHzHWrIrirzHmfebmfzekOCtWr9(Tx(OIGsGEXRNEhU3V9Y0EXPirRokmfevQofyf)mDYbT3V9IXEzAVk3K8ctbrv15c0hepAYbT3V9Y0EvUj5f8XcLvNcSGCLPtGoA9(T3ACodJKAYbTe9dr)EzGHEvUj5fMcIQQZfOpiE0KdAVF7LP9wJZzymTcWqK6vi63ldm0RYnjVGpwOS6uGfKRmDc0rR3V9wJZzyKutoOLOFi6373EzAV14CggtRamePEfI(9IbwiravY5SaLdZYKHzHOCtYJfYuquP6uGXcbMaCK4BsESqywrKCq7fFfebmfze6FV4RGOEXMtbgOxfr9gbeCVa5jof5WQxl7foIKdAVmpF1iWK8c96nrhHuNdR)9AJew9QiQ3iGG71YEHshHuJ6ftkTEHyis9c07Gr66LJed07aX569sR3k17afyeCV6b37aXg7fBofyeQ3Hmfye6FV2iHvVGXm6G7Ts9c8rKc3BgTETS3NkNPY1Rns9InNcmc17qMcmc1BnoNbwJLjm7HzXdle60QJGzXglKiGkdgfhv4kWKdkltgMfcmb4iX3K8yHWmWLcCVC13xoO9IVcI6fBofy9Yhveuc07GrXr9Yh17iNCq7fYOmn5G27pLdieleLBsESqMcIkvNcmwiCKyesuwik3K8cGrzAYbT4NdiuG(G4rtoO9(T3z05kiIpQiOuXKh1l(7v5MKxamkttoOf)CaHcMW9QGi4i3K869BV14CggtRamePEfGZbxVF71Kh1lE7Dy8H1yzcZEOS4HfcDA1rWSyJfchjgHeLfcofjA1rbtEuXYcpF1iWK86fV9Ip9(T3ACodO4rLCw8ZbekaNdowik3K8yHWvNROCtYR4eGXcXjaRC6JyHam9GveCbLMAsESglty2mBw8Wcr5MKhleapr8rwi0PvhbZInwJ1yHGs)I)Ociw8WYKHzXdle60QJGzXgleLBsESqMo9radjErSqGjahj(MKhle8vo15W6FV88WriR3jkF9Qvq6Ig1RjpQx9G7fyjI61gPErKtnbh1RjpQx56fNIeT6OGjpQyzHNVAeysEHE)rNt8I61gPEreW6nN9AJuVC1XJo1K8a)7DWOWh7Du99PRxhba9or0phPZCy1RL9c8jcU3OFV2i1lqErNAsE)71gfqVJQVpDGEZ5078MyoZQx9G7DWO4OE5kWKdAGfchjgHeLfIYnbhvOJEcb6fVE6fNIeT6OWyAfGHi1RY0PpcyiXlQ3V9IXERX5mmMwbyis9ke97Lbg6TgNZWuqeWs0le97fdSgltgklEyHqNwDeml2yHWrIrirzHuJZzaMuBSMOJcr)E)2lkE0mrqPamP2iOmvBmFb60QJG79BV4uKOvhfm5rfll88vJatYRx83BnoNbysTXAIokGONkhO3V9QCtWrf6ONqGEXRNEhkleLBsESqMcIQQZXASmHzZIhwi0PvhbZInwiCKyesuwi14CgaXR4LCqbLQJaa5GwqKcJvi6373ERX5maIxXl5GckvhbaYbTGifgRaIEQCGEXBVCfyftEeleLBsESq8XcLvNcmwJLjmtS4HfcDA1rWSyJfchjgHeLfsnoNHPGiGLOxi6Zcr5MKhleFSqz1PaJ1yzYqWIhwi0PvhbZInwiCKyesuwi14CggtRamePEfI(SquUj5XcXhluwDkWynwMGPYIhwi0PvhbZInwiravgmkoQWvGjhuwMmmleosmcjkleM2lofjA1rHPGOs1PaR4NPtoO9(T3ACodG4v8soOGs1raGCqlisHXkaNdUE)2RYnbhvOJEcb6f)9ItrIwDuyurWfUcSY0PpcyiXlQ3V9Y0ENcIaMImcfuUj4OE)2lg7LP9wJZzyKutoOLOFi6373EzAV14CggtRamePEfI(9(TxM2RpIWvY5SaLdhMcIkvNcSE)2lg7v5MKxykiQuDkWc8rfbLa9Ixp9o0EzGHEXyVM6OZcQJ(ayifmKtbLzeHvGoT6i4E)2lpthCo4cWifAEGsfrQngqKcJvVyOxgyOxaPi5GwSmYhdk3eCuVyOxmWcjcOsoNfOCywMmmleLBsESqMcIkvNcmwiWeGJeFtYJfYpcq9Mh1l(kiQxS5uG1lPihw9kxVyY5p1Rm7fRm2lCEy36DuXr9sInsOEXKi1KdAV)i)EtuVysP1ledrQx9Ifz9QhCVKyJeY77fJkg6DuXr9(se1RnQxV2GSx1HifgR)9IXkg6DuXr9YmC0hadPGHCk2b9IVrew9IifgRETS3iG(3BI6fJCm0lesrYbTx8Kr(yVcOxLBcok0lZkpSB9cN9AJcO3bJIJ6DurW9YvGjh0EXxN(iGHeViqVjQ3bJ01lK41lMo5GIDqVyZraGCq7va9IifgRaRXYeVzw8WcHoT6iywSXcjcOYGrXrfUcm5GYYKHzHWrIrirzHW0EXPirRokmfevQofyf)mDYbT3V9Y0ENcIaMImcfuUj4OE)2lg7fJ9IXEvUj5fMcIQQZfOpiE0KdAVF7fJ9QCtYlmfevvNlqFq8Orfe9u5a9I)EXNWq0ldm0lt7ffpAMiOuykicyj6fOtRocUxm0ldm0RYnjVGpwOS6uGfOpiE0KdAVF7fJ9QCtYl4JfkRofyb6dIhnQGONkhOx83l(egIEzGHEzAVO4rZebLctbralrVaDA1rW9IHEXqVF7TgNZWiPMCqlr)q0Vxm0ldm0lg7fqksoOflJ8XGYnbh173EXyV14Cggj1KdAj6hI(9(TxM2RYnjVaGNi(yG(G4rtoO9Yad9Y0ERX5mmMwbyis9ke979BVmT3ACodJKAYbTe9dr)E)2RYnjVaGNi(yG(G4rtoO9(TxM27yAfGHi1RcWNCoqrUY0jqhTEXqVyOxmWcjcOsoNfOCywMmmleLBsESqMcIkvNcmwiWeGJeFtYJfYpcq9IVcI6fBofy9sInsOEHJi5G2R2l(kiQQohM)jSqz1PaRxUcSEhmsxVysKAYbT3FKFVcOxLBcoQ3e1lCejh0EPpiE0OEhi2yVqifjh0EXtg5JbwJLjdjS4HfcDA1rWSyJfIYnjpwiC15kk3K8kobySqCcWkN(iwik3eCuXuhDgG1yzcMglEyHqNwDeml2yHWrIrirzHuJZzWhluYDk4fI(9(TxUcSIjpQx83BnoNbFSqj3PGxarpvoqVF7LRaRyYJ6f)9wJZzafpQKZIFoGqbe9u5aSquUj5XcXhluwDkWynwMmm(WIhwi0PvhbZInwiCKyesuwi14CggtRamePEfI(9(TxaPi5GwSmYhdk3eCuVF7v5MGJk0rpHa9I)EXPirRokmMwbyis9QmD6Jags8IyHOCtYJfIpwOS6uGXASmz4HzXdle60QJGzXgleosmcjkleM2lofjA1rb)XKo5JIFMo5G273ERX5mmsQjh0s0pe979BVmT3ACodJPvagIuVcr)E)2lg7v5MGJkWPfeONyuV4V3H2ldm0RYnbhvOJEcb6fVE6fNIeT6OWOIGlCfyLPtFeWqIxuVmWqVk3eCuHo6jeOx86PxCks0QJcJPvagIuVktN(iGHeVOEXaleLBsESq8ht6KpktN(iaRXYKHhklEyHqNwDeml2yHWrIrirzHaifjh0ILr(yq5MGJyHOCtYJfcGNi(iRXYKHz2S4HfcDA1rWSyJfchjgHeLfIYnbhvOJEcb6fV9ouwik3K8yHaJuO5bkveP2iRXYKHzMyXdle60QJGzXgleosmcjkleLBcoQqh9ec0lE90lofjA1rbfX1Jk0h(Uei5173EF6PbFU1lE90lofjA1rbfX1Jk0h(Uei5vE6P9(TxtrqjlmqSr5ggFyHOCtYJfII46rf6dFxcK8ynwMm8qWIhwi0PvhbZInwik3K8yHmD6Jags8IyHataos8njpwiykIn2lDze6yVMIGsg4FVI1Ra6v7fQkxVw2lxbwV4RtFeWqIxuVkO3P4CeQx5agPW9MZEXxbrv15cSq4iXiKOSquUj4OcD0tiqV41tV4uKOvhfgveCHRaRmD6Jags8IynwMmmMklEyHOCtYJfYuquvDowi0PvhbZInwJ1yHWZxncmjVI)Ociw8WYKHzXdle60QJGzXgleosmcjklKACod88vJatYlaNdowik3K8yH4eOJgOGPpcd9rNXASmzOS4HfcDA1rWSyJfIYnjpwivfAjNfdjCVaSqGjahj(MKhleMbmmOxBK6foIutYR3C2Rns9cjE9IPtoOyh0l2Ceaih0EzE(QrGj51RL9AJuV0b3Bo71gPE5reIoRxMNVAeysE9kZETrQxUcSEhKrhCV8857iJ6foIKdAV2Oa6L55RgbMKxGfchjgHeLfsnoNbE(QrGj5fGZbhRXYeMnlEyHqNwDeml2yHWrIrirzHOCtWrf6ONqGEXBVd373ERX5mWZxncmjVaCo4yHOCtYJfItWjh0snFvwJLjmtS4HfcDA1rWSyJfseqLbJIJkCfyYbLLjdZcHJeJqIYcHP9YZdokwqUjHo1v4kGRWuGoT6i4E)2lFurqjqV41tVd373ERX5mWZxncmjVq0V3V9Y0ERX5mmfebSe9cr)E)2lt7TgNZWyAfGHi1Rq0V3V9oMwbyis9Qa8jNduKRmDc0rR3p7TgNZWiPMCqlr)q0Vx837qzHebujNZcuomltgMfIYnjpwitbrLQtbgleycWrIVj5XcbtrSXmA96nUjHo11lZvaxHP)9IPpcSEJaQx8vquVyZPad07Gr661gjS6DqEy369fp(yVCKyGE1dU3bJ01l(kicyj61Ra6fohCbwJLjdblEyHqNwDeml2yHebuzWO4OcxbMCqzzYWSq4iXiKOSq45bhfli3KqN6kCfWvyQ3V9Yhveuc0lE907W9(Txm2lofjA1rb6dFIBeCzkiQuDkWa9Ixp9ItrIwDu4icMGltbrLQtbgOxgyOxCks0QJc0hgDWeCHNVAeysEfe9u5a9IFp9wJZzqUjHo1v4kGRWuaoIutYRxgyO3ACodYnj0PUcxbCfMcat5E1l(7DO9Yad9wJZzqUjHo1v4kGRWuarpvoqV4VxOC4Wt)OxgyOxEMo4CWfaJY0KdAXphqOaIuyS69BVk3eCuHo6jeOx86PxCks0QJc88vJatYRagLPjh0IFoGq9(TxEIJo9SWjqhTYuPEXqVF7TgNZapF1iWK8cr)E)2lg7LP9wJZzykicyj6fI(9Yad9wJZzqUjHo1v4kGRWuarpvoqV4Vx8jme9IHE)2lt7TgNZWyAfGHi1Rq0V3V9oMwbyis9Qa8jNduKRmDc0rR3p7TgNZWiPMCqlr)q0Vx837qzHebujNZcuomltgMfIYnjpwitbrLQtbgleycWrIVj5XcbtrSXE9g3KqN66L5kGRW0)EXxbr9InNcSEJaQxWygDW9wPEvyyXK8uNdRE55bmKkhb3li71gvRxX6va9EP1BL6nci4EJNJaGE9g3KqN66L5kGRWuVcOxTMrRxl7L(WxquVjQxBKquVkI69LiQxBuVEPlJqh7fFfe1l2CkWa9AzV0hgDW96nUjHo11lZvaxHPETSxBK6Lo4EZzVmpF1iWK8cSgltWuzXdle60QJGzXgleLBsESq4QZvuUj5vCcWyH4eGvo9rSquUj4OIPo6maRXYeVzw8WcHoT6iywSXcjcOYGrXrfUcm5GYYKHzHWrIrirzHuJZzGNVAeysEb4CW173EXPirRokyYJkww45RgbMKxV43tV4tVF7fJ9Y0ErXJMjckfGfax8DYPiSk8890doqNwDeCVmWqV14CgGfax8DYPiSk8890doe97Lbg6TgNZaSa4IVtofHvHNVNEWLjkbwi6373En1rNfqXJk5S4NdiuGoT6i4E)2lpthCo4c14CwGfax8DYPiSk8890doGifgREXqVF7fJ9Y0ErXJMjckfGIeGdRIWfUJc0Pvhb3ldm0lmvJZzaksaoSkcx4oke97fd9(Txm2lt7LN4OtplCehLUeb3ldm0lpthCo4cWKAJ1eDuarpvoqVmWqV14CgGj1gRj6Oq0Vxm073EXyVmTxEIJo9Sao6SrSq9Yad9YZ0bNdUWtqOebk5Syj6rNfq0tLd0lg69BVySxLBsEHhzuIcYvMob6O173EvUj5fEKrjkixz6eOJwbrpvoqV43tV4uKOvhf45RgbMKxHRaRGONkhOxgyOxLBsEbapr8Xa9bXJMCq79BVk3K8caEI4Jb6dIhnQGONkhOx83lofjA1rbE(QrGj5v4kWki6PYb6Lbg6v5MKxykiQQoxG(G4rtoO9(TxLBsEHPGOQ6Cb6dIhnQGONkhOx83lofjA1rbE(QrGj5v4kWki6PYb6Lbg6v5MKxWhluwDkWc0hepAYbT3V9QCtYl4JfkRofyb6dIhnQGONkhOx83lofjA1rbE(QrGj5v4kWki6PYb6Lbg6v5MKxy60hbmK4ffOpiE0KdAVF7v5MKxy60hbmK4ffOpiE0OcIEQCGEXFV4uKOvhf45RgbMKxHRaRGONkhOxmWcjcOsoNfOCywMmmleLBsESq45RgbMKhRXYKHew8WcHoT6iywSXcbMaCK4BsESqWeSrc1lpthCo4a9AJQ1lymJo4ERuVrab37aXg7L55RgbMKxVGXm6G7nphw9wPEJacU3bIn2RE9QClQUEzE(QrGj51lxbwV6b37LwVdeBSxTxiXRxmDYbf7GEXMJaa5G2Rpk5bwik3K8yHWvNROCtYR4eGXcHJeJqIYcPgNZapF1iWK8ci6PYb6fV9oK0ldm0lpthCo4c88vJatYlGONkhOx837qWcXjaRC6JyHWZxncmjVcpthCo4aSgltW0yXdle60QJGzXgleosmcjklem2BnoNHX0kadrQxHOFVF7v5MGJk0rpHa9Ixp9ItrIwDuGNVAeysELPtFeWqIxuVyOxgyOxm2BnoNHPGiGLOxi6373EvUj4OcD0tiqV41tV4uKOvhf45RgbMKxz60hbmK4f1R31lkE0mrqPWuqeWs0lqNwDeCVyGfIYnjpwitN(iGHeViwJLjdJpS4HfcDA1rWSyJfchjgHeLfsnoNbq8kEjhuqP6iaqoOfePWyfI(9(T3ACodG4v8soOGs1raGCqlisHXkGONkhOx82lxbwXKhXcr5MKhleFSqz1PaJ1yzYWdZIhwi0PvhbZInwiCKyesuwi14CgMcIawIEHOpleLBsESq8XcLvNcmwJLjdpuw8WcHoT6iywSXcHJeJqIYcPgNZGpwOK7uWle979BV14Cg8XcLCNcEbe9u5a9I3E5kWkM8OE)2lg7TgNZapF1iWK8ci6PYb6fV9YvGvm5r9Yad9wJZzGNVAeysEb4CW1lg69BVk3eCuHo6jeOx83lofjA1rbE(QrGj5vMo9radjErSquUj5XcXhluwDkWynwMmmZMfpSqOtRocMfBSq4iXiKOSqQX5mmMwbyis9ke979BV14Cg45RgbMKxi6Zcr5MKhleFSqz1PaJ1yzYWmtS4HfcDA1rWSyJfchjgHeLfIpIWvGYHddha8eXh79BV14Cggj1KdAj6hI(9(TxLBcoQqh9ec0l(7fNIeT6OapF1iWK8ktN(iGHeVOE)2BnoNbE(QrGj5fI(SquUj5XcXhluwDkWynwMm8qWIhwi0PvhbZInwik3K8yHagLPjh0IFoGqSqKZiek6BfzYcr5MKxykiQuDkWc8rfbLaEuUj5fMcIkvNcSWt)OWhveucWcHJeJqIYcPgNZapF1iWK8cr)E)2lt7v5MKxykiQuDkWc8rfbLa9(TxLBcoQqh9ec0lE90lofjA1rbE(QrGj5vaJY0KdAXphqOE)2RYnjVG)ysN8rz60hbcZOZvqeFurqPIjpQx827m6Cfebh5MKhleycWrIVj5Xc5hbKdAVqgLPjh0E)PCaH6foIKdAVmpF1iWK861YEreWse1l(kiQxS5uG1REW9(tJjDYh9IVo9r9Yhveuc0lxVERuVv6OPWf19V3A06ncIQZHvV55WQ386LzKmZbwJLjdJPYIhwi0PvhbZInwiCKyesuwi14Cg45RgbMKxi6373EnKIJCftEuV4V3ACod88vJatYlGONkhO3V9IXEXyVk3K8ctbrLQtbwGpQiOeOx837W9(TxtD0zbFSqj3PGxGoT6i4E)2RYnbhvOJEcb61tVd3lg6Lbg6LP9AQJol4Jfk5of8c0Pvhb3ldm0RYnbhvOJEcb6fV9oCVyO3V9wJZzyKutoOLOFi637N9oMwbyis9Qa8jNduKRmDc0rRx837qzHOCtYJfI)ysN8rz60hbynwMmS3mlEyHqNwDeml2yHWrIrirzHuJZzGNVAeysEb4CW173E5z6GZbxGNVAeysEbe9u5a9I)E5kWkM8OE)2RYnbhvOJEcb6fVE6fNIeT6OapF1iWK8ktN(iGHeViwik3K8yHmD6Jags8IynwMm8qclEyHqNwDeml2yHWrIrirzHuJZzGNVAeysEb4CW173E5z6GZbxGNVAeysEbe9u5a9I)E5kWkM8OE)2lt7LNhCuSW0PpQOCoImjVaDA1rWSquUj5XczkiQQohRXYKHX0yXdle60QJGzXgleosmcjklKACod88vJatYlGONkhOx82lxbwXKh173ERX5mWZxncmjVq0VxgyO3ACod88vJatYlaNdUE)2lpthCo4c88vJatYlGONkhOx83lxbwXKhXcr5MKhleapr8rwJLjdfFyXdle60QJGzXgleosmcjklKACod88vJatYlGONkhOx83luoC4PF073EvUj4OcD0tiqV4T3HzHOCtYJfItWjh0snFvwJLjdDyw8WcHoT6iywSXcHJeJqIYcPgNZapF1iWK8ci6PYb6f)9cLdhE6h9(T3ACod88vJatYle9zHOCtYJfcmsHMhOurKAJSgRXcr5MGJkM6OZaS4HLjdZIhwi0PvhbZInwiCKyesuwik3eCuHo6jeOx827W9(T3ACod88vJatYlaNdUE)2lg7fNIeT6OGjpQyzHNVAeysE9I3E5z6GZbxWj4KdAPMVAaoIutYRxgyOxCks0QJcM8OILfE(QrGj51l(90l(0lgyHOCtYJfItWjh0snFvwJLjdLfpSqOtRocMfBSq4iXiKOSqWPirRokyYJkww45RgbMKxV43tV4tVmWqVySxEMo4CWfEKrjkahrQj51l(7fNIeT6OGjpQyzHNVAeysE9(TxM2RPo6SakEujNf)CaHc0Pvhb3lg6Lbg61uhDwafpQKZIFoGqb60QJG79BV14CgqXJk5S4Ndiui6373EXPirRokyYJkww45RgbMKxV4TxLBsEHhzuIc8mDW5GRxgyO3PaD0ki6PYb6f)9ItrIwDuWKhvSSWZxncmjpwik3K8yH8iJseRXYeMnlEyHqNwDeml2yHWrIrirzHyQJolOo6dGHuWqofuMrewb60QJG79BVyS3ACod88vJatYlaNdUE)2lt7TgNZWyAfGHi1Rq0VxmWcr5MKhleyKcnpqPIi1gznwJfcW0dwrWfuAQj5XIhwMmmlEyHqNwDeml2yHWrIrirzHOCtWrf6ONqGEXRNEXPirRokmMwbyis9QmD6Jags8I69BVyS3ACodJPvagIuVcr)EzGHERX5mmfebSe9cr)EXaleLBsESqMo9radjErSgltgklEyHqNwDeml2yHWrIrirzHuJZzaMuBSMOJcr)E)2lkE0mrqPamP2iOmvBmFb60QJG79BV4uKOvhfm5rfll88vJatYRx83BnoNbysTXAIokGONkhOx86P3HYcr5MKhlKPGOQ6CSglty2S4HfcDA1rWSyJfchjgHeLfsnoNHPGiGLOxi6Zcr5MKhleFSqz1PaJ1yzcZelEyHqNwDeml2yHWrIrirzHuJZzymTcWqK6vi6373ERX5mmMwbyis9kGONkhOx83RYnjVWuquvDUa9bXJgvm5rSquUj5XcXhluwDkWynwMmeS4HfcDA1rWSyJfchjgHeLfsnoNHX0kadrQxHOFVF7fJ96JiCfOC4WWHPGOQ6C9Yad9ofebmfzekOCtWr9Yad9QCtYl4JfkRofyb5ktNaD06fdSquUj5XcXhluwDkWynwMGPYIhwi0PvhbZInwik3K8yH4JfkRofySqGjahj(MKhle8GWQxl7fkz9cbth261hLCqVYbeyQxm58N61FubeO3e1lZZxncmjVE9hvab6DWiD96NaGuDuGfchjgHeLfsnoNbq8kEjhuqP6iaqoOfePWyfI(9(Txm2lpthCo4cO4rLCw8ZbekGONkhO3p7v5MKxafpQKZIFoGqb6dIhnQyYJ69ZE5kWkM8OEXBV14CgaXR4LCqbLQJaa5GwqKcJvarpvoqVmWqVmTxtD0zbu8Osol(5acfOtRocUxm073EXPirRokyYJkww45RgbMKxVF2lxbwXKh1lE7TgNZaiEfVKdkOuDeaih0cIuySci6PYbynwM4nZIhwi0PvhbZInwiCKyesuwi14CggtRamePEfI(9(TxaPi5GwSmYhdk3eCeleLBsESq8XcLvNcmwJLjdjS4HfcDA1rWSyJfchjgHeLfsnoNbFSqj3PGxi6373E5kWkM8OEXFV14Cg8XcLCNcEbe9u5aSquUj5XcXhluwDkWynwMGPXIhwi0PvhbZInwiravgmkoQWvGjhuwMmmleosmcjkleM27uqeWuKrOGYnbh173EzAV4uKOvhfMcIkvNcSIFMo5G273EXyVySxm2RYnjVWuquvDUa9bXJMCq79BVySxLBsEHPGOQ6Cb6dIhnQGONkhOx83l(egIEzGHEzAVO4rZebLctbralrVaDA1rW9IHEzGHEvUj5f8XcLvNcSa9bXJMCq79BVySxLBsEbFSqz1PalqFq8Orfe9u5a9I)EXNWq0ldm0lt7ffpAMiOuykicyj6fOtRocUxm0lg69BV14Cggj1KdAj6hI(9IHEzGHEXyVasrYbTyzKpguUj4OE)2lg7TgNZWiPMCqlr)q0V3V9Y0EvUj5fa8eXhd0hepAYbTxgyOxM2BnoNHX0kadrQxHOFVF7LP9wJZzyKutoOLOFi6373EvUj5fa8eXhd0hepAYbT3V9Y0EhtRamePEva(KZbkYvMob6O1lg6fd9IbwiravY5SaLdZYKHzHOCtYJfYuquP6uGXcbMaCK4BsESqywrKCq71gPEbMEWkcUxuAQj59V38Cy1Beq9IVcI6fBofyGEhmsxV2iHvVkI69sR3kjh0E9Z0rW9otuVyY5p1BI6L55RgbMKxO3FeG6fFfe1l2CkW6LeBKq9chrYbTxTx8vquvDom)tyHYQtbwVCfy9oyKUEXKi1KdAV)i)EfqVk3eCuVjQx4isoO9sFq8Or9oqSXEHqksoO9INmYhdSgltggFyXdle60QJGzXgleosmcjklKACodJPvagIuVcr)E)2RYnbhvOJEcb6f)9ItrIwDuymTcWqK6vz60hbmK4fXcr5MKhleFSqz1PaJ1yzYWdZIhwi0PvhbZInwiCKyesuwimTxCks0QJc(JjDYhf)mDYbT3V9IXEzAVM6OZctu(k2ivuWibc0Pvhb3ldm0RYnbhvOJEcb6fV9oCVyO3V9IXEvUj4OcCAbb6jg1l(7DO9Yad9QCtWrf6ONqGEXRNEXPirRokmQi4cxbwz60hbmK4f1ldm0RYnbhvOJEcb6fVE6fNIeT6OWyAfGHi1RY0PpcyiXlQxmWcr5MKhle)XKo5JY0PpcWASmz4HYIhwi0PvhbZInwik3K8yHWvNROCtYR4eGXcXjaRC6JyHOCtWrftD0zawJLjdZSzXdle60QJGzXgleosmcjkleLBcoQqh9ec0lE7Dywik3K8yHaJuO5bkveP2iRXYKHzMyXdle60QJGzXgleosmcjkleaPi5GwSmYhdk3eCeleLBsESqa8eXhznwMm8qWIhwi0PvhbZInwiCKyesuwik3eCuHo6jeOx86PxCks0QJckIRhvOp8DjqYR3V9(0td(CRx86PxCks0QJckIRhvOp8DjqYR80t79BVMIGswyGyJYnm(Wcr5MKhlefX1Jk0h(Uei5XASmzymvw8WcHoT6iywSXcr5MKhlKPtFeWqIxeleycWrIVj5XcbtrSXEPlJqh71ueuYa)7vSEfqVAVqv561YE5kW6fFD6Jags8I6vb9ofNJq9khWifU3C2l(kiQQoxGfchjgHeLfIYnbhvOJEcb6fVE6fNIeT6OWOIGlCfyLPtFeWqIxeRXYKH9MzXdleLBsESqMcIQQZXcHoT6iywSXASgleFeXZxvnw8WYKHzXdleLBsESquexpQiNrohXnwi0PvhbZInwJLjdLfpSqOtRocMfBSqGjahj(MKhlemPCqVU8G2BLMjI6L55RgbMKxVGXm6G71qY5fzGETr161qcuOeQxTxWOIi4E5Qrqtew9YZ0bNdUEZR30gjuVgsoVid07LwVvQ3iGGhYZc50hXcbKrxrGEIriwiCKyesuwimTxCks0QJc88vJatYRKxjcOE)2lt7L(5O47tWbyePWtbrfCeaqUE)2lt71uhDwykicykYiuGoT6iywik3K8yHaYORiqpXieRXYeMnlEyHOCtYJfYtqOevKNcLyHqNwDeml2ynwMWmXIhwi0PvhbZInwiCKyesuwimTxFeHl4JfkRofySquUj5XcXhluwDkWynwJ1yHGJqajpwMmu8zOdJpyQdDiHfYafDYbfWcbtHzGjZeVbt8M8(E7fpJuVYZprwVZe1l2rPFXFube27fr)CuqeCVG8r9QrlFQrW9Yh1dkbcnJ)GCuVd177L55HJqgb3l2rXJMjckf8wS3RL9IDu8OzIGsbVnqNwDem27fJd)bgcnJ)GCuVyQEFVmppCeYi4EXUPo6SG3I9ETSxSBQJol4Tb60QJGXEVyC4pWqOz8hKJ61B277L55HJqgb3l2rXJMjckf8wS3RL9IDu8OzIGsbVnqNwDem27fJd9dmeAgBgXuygyYmXBWeVjVV3EXZi1R88tK17mr9IDyAQrNH9Er0phfeb3liFuVA0YNAeCV8r9GsGqZ4pih17WEFVmppCeYi4EXokE0mrqPG3I9ETSxSJIhnteuk4Tb60QJGXEVQ1lZmMWp0lgh(dmeAg)b5OEzM8(EzEE4iKrW9IDu8OzIGsbVf79AzVyhfpAMiOuWBd0PvhbJ9EvRxMzmHFOxmo8hyi0m(dYr9o8q9(EzEE4iKrW9crEmVxawNPF07q6qAVw27pe1EFjC0fb9M(esTe1lghsXqVyC4pWqOz8hKJ6D4H699Y88WriJG7f788GJIf8wS3RL9IDEEWrXcEBGoT6iyS3lgh(dmeAg)b5OEhMz799Y88WriJG7f7gsoVilmCWBXEVw2l2nKCErwWgo4TyVxmYS)adHMXFqoQ3Hz2EFVmppCeYi4EXUHKZlYcdn4TyVxl7f7gsoVilydn4TyVxmYS)adHMXFqoQ3HzM8(EzEE4iKrW9IDEEWrXcEl271YEXopp4OybVnqNwDem27fJd)bgcnJ)GCuVdDyVVxMNhoczeCVyhfpAMiOuWBXEVw2l2rXJMjckf82aDA1rWyVxmo8hyi0m(dYr9o0H699Y88WriJG7f7O4rZebLcEl271YEXokE0mrqPG3gOtRocg79IXH)adHMXFqoQ3HYS9(EzEE4iKrW9IDtD0zbVf79AzVy3uhDwWBd0PvhbJ9EX4WFGHqZ4pih17qz2EFVmppCeYi4EXokE0mrqPG3I9ETSxSJIhnteuk4Tb60QJGXEVyC4pWqOz8hKJ6DOmtEFVmppCeYi4EXokE0mrqPG3I9ETSxSJIhnteuk4Tb60QJGXEVyC4pWqOz8hKJ6DOdH33lZZdhHmcUxSJIhnteuk4TyVxl7f7O4rZebLcEBGoT6iyS3lgh(dmeAgBgXuygyYmXBWeVjVV3EXZi1R88tK17mr9IDFeXZxvnS3lI(5OGi4Eb5J6vJw(uJG7LpQhuceAg)b5OEhQ33lZZdhHmcUxSBQJol4TyVxl7f7M6OZcEBGoT6iyS3RA9YmJj8d9IXH)adHMXMrmfMbMmt8gmXBY77Tx8ms9kp)ez9otuVyNNVAeysEfEMo4CWbWEVi6NJcIG7fKpQxnA5tncUx(OEqjqOz8hKJ6ft177L55HJqgb3l2rXJMjckf8wS3RL9IDu8OzIGsbVnqNwDem27fJd)bgcnJnJykmdmzM4nyI3K33BV4zK6vE(jY6DMOEXUYnbhvm1rNbWEVi6NJcIG7fKpQxnA5tncUx(OEqjqOz8hKJ6DOEFVmppCeYi4EXUPo6SG3I9ETSxSBQJol4Tb60QJGXEVyCOFGHqZ4pih1lZ277L55HJqgb3l2n1rNf8wS3RL9IDtD0zbVnqNwDem27fJd)bgcnJnJykmdmzM4nyI3K33BV4zK6vE(jY6DMOEXoW0dwrWfuAQj5H9Er0phfeb3liFuVA0YNAeCV8r9GsGqZ4pih17q9(EzEE4iKrW9IDu8OzIGsbVf79AzVyhfpAMiOuWBd0PvhbJ9EX4WFGHqZ4pih1lMQ33lZZdhHmcUxSBQJol4TyVxl7f7M6OZcEBGoT6iyS3lgh(dmeAg)b5OEX08(EzEE4iKrW9IDu8OzIGsbVf79AzVyhfpAMiOuWBd0PvhbJ9EX4q)adHMXFqoQ3Hh277L55HJqgb3l2n1rNf8wS3RL9IDtD0zbVnqNwDem27fJd)bgcnJnJykmdmzM4nyI3K33BV4zK6vE(jY6DMOEXopF1iWK8k(JkGWEVi6NJcIG7fKpQxnA5tncUx(OEqjqOz8hKJ6LzY77L55HJqgb3l255bhfl4TyVxl7f788GJIf82aDA1rWyVxmo8hyi0m(dYr96n799Y88WriJG7f7M6OZcEl271YEXUPo6SG3gOtRocg79IXH)adHMXFqoQxVzVVxMNhoczeCVyhfpAMiOuWBXEVw2l2rXJMjckf82aDA1rWyVxmo0pWqOz8hKJ6ftZ77L55HJqgb3l2rXJMjckf8wS3RL9IDu8OzIGsbVnqNwDem27fJd)bgcnJ)GCuVdJP699Y88WriJG7f7M6OZcEl271YEXUPo6SG3gOtRocg79IXH(bgcnJ)GCuVdpK499Y88WriJG7f788GJIf8wS3RL9IDEEWrXcEBGoT6iyS3RA9YmJj8d9IXH)adHMXMrVXZprgb3R3CVk3K861jadeAgzH4JYP4iwi)(BV4RGOEhYuOuZ4V)27Oz(aVhZygQyJXAGNpmdKx0PMKhhPtdZa5XXCZ4V)2lJXJ6DOyA)7DO4ZqhUzSz83F7L5J6bLaEFZ4V)2R317pcq9ofOJwbrpvoqVi1gjuV2OE9AkckzbtEuXYcSq9otuVofyEhG45b3RwfNyy1BeOqjqOz83F71769hYeqxVCfy9IOFoki6rNb6DMOEzE(QrGj51lgLaf(3lCEy36DmDW9kwVZe1R27erGXEhYiJsuVCfyyi0m(7V96D9YmFA1r9cmKWTE5Je3l5G2BE9Q9oPb9otKxGELRxBK6Lz8t)qVw2lIGJCQ3bjYlxQWHMXF)TxVRxMbmM(iW6v79NWcLvNcSEPZqy1RnQwVWjb69sR3xctUEhqoxVY5Dq1h1lgbYRxJagb3RA9EzVab6jtHRN1lZ6NG0R88vUHHqZ4V)2R31lZZdhHSEvNR3ACodEBark36LodjeOxl7TgNZG3gI()7vVEv3lbwVYbeONmfUEwVmRFcsVqv56vUEbYdeAg)93E9UE)raQ3rfbZtycUxCks0QJa9AzVicoYPEz(p9J6DqI8YLkCOzSz83F7Lz(dIhncU3knte1lpFv16TsqLde6LzW5KVb69YZ7gv0BgD9QCtYd0BEoScnJk3K8abFeXZxvTp9GzfX1JkYzKZrCRz83F7Lz8t)qVyIks0QJ6ftW3K88(E9gZEbK1RL9Q9E55Dd5iu2lo1fP)9AJuVmpF1iWK86v5MKxV6b3lpthCo4a9AJQ1RIOE55bmKkhb3RL9MNdRERuVrab37Gr66L55RgbMKxVcO3OFVdeNR3lTERuVrab3lCejh0ETrQxG8Io1K8cnJ)(BV)(BVk3K8abFeXZxvTp9GzCks0QJ(F6J8alaT6OcpF1iWK8(N(EqeGSMXF7Lz8t)qVyIks0QJ6ftW3K88(EXZOa6fNIeT6OEb(exMcb6DWizJeQxMNVAeysE9cgZOdU3k1BeqW9chrYbTx8vqeWuKrOqZ4V)2RYnjpqWhr88vv7tpygNIeT6O)N(iptbratrgHk88vJatY7F67bq2Fz6HPM6OZc(yHsUtbV)4uxK8m8FCQlsfYbip4tZ4V9Ym(PFOxmrfjA1r9Ij4BsEEFV4zua9ItrIwDuVaFIltHa9AJuVx8vjuV5Sxtrqjd0RA9oyu4J9IjLwVqmePE1l(60hbmK4fb6nJgqGPEZzVmpF1iWK86fmMrhCVvQ3iGGdnJ)(BVk3K8abFeXZxvTp9GzCks0QJ(F6J8mMwbyis9QmD6Jags8I(N(EaK9xMEm1rNfMo9rfF14J)XPUi5zO)XPUivihG8WSBg)TxMXp9d9IjQirRoQxmbFtYZ77fpJcOxCks0QJ6f4tCzkeOxBK69IVkH6nN9AkckzGEvR3bJcFSxmjfb3lZvG1l(60hbmK4fb6nJgqGPEZzVmpF1iWK86fmMrhCVvQ3iGG7vb9ofNJqHMXF)TxLBsEGGpI45RQ2NEWmofjA1r)p9rEgveCHRaRmD6Jags8I(N(EaK9xMEm1rNfMo9rfF14J)XPUi5zO)XPUivihG8WSBg)TxMXp9d9IjQirRoQxmbFtYZ77fpJcOxCks0QJ6f4tCzkeOxBK69IVkH6nN9AkckzGEvR3bJcFSxmP06fIHi1REXxN(iGHeViqVkI6nci4EHJi5G2lZZxncmjVqZ4V)2RYnjpqWhr88vv7tpygNIeT6O)N(ip88vJatYRmD6Jags8I(N(EaK9xMEm1rNfMo9rfF14J)XPUi5Hz)hN6IuHCaYdMAZ4V9Ym(PFOxmrfjA1r9Ij4BsEEFV4zua9ItrIwDuVaFIltHa9AJuVx8vjuV5Sxtrqjd0RA9oyu4J9YmqC9OEzM)W3LajVEZObeyQ3C2lZZxncmjVEbJz0b3BL6nci4qZ4V)2RYnjpqWhr88vv7tpygNIeT6O)N(ipkIRhvOp8DjqY7F67bq2Fz6XuhDwy60hv8vJp(hN6IKhmnmT)4uxKkKdqEgAZ4V9Ym(PFOxmrfjA1r9Ij4BsEEFV4zua9ItrIwDuVaFIltHa9AJuV(eItNPqPEZzVp90ERKlh07GrHp2lZaX1J6Lz(dFxcK86DG4C9EP1BL6nci4qZ4V)2RYnjpqWhr88vv7tpygNIeT6O)N(ipkIRhvOp8DjqYR80t)dttn6mpmt4Z)03dIaK1m(BVmJF6h6fturIwDuVyc(MKN33lEgPEV4RsOEZzVMIGsgOxiJY0KdAV)uoGq9cgZOdU3k1BeqW9MxVWrKCq7L55RgbMKxOz83F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKhE(QrGj5vaJY0KdAXphqO)W0uJoZZq)N(EqeGSMXF7Lz8t)qVyIks0QJ6ftW3K88(EXZi1RjpQxe9u5KdAV51R2lxbwVdgPRxMNVAeysE9Y1R3k1BeqW9kxVaINhmi0m(7V9QCtYde8repFv1(0dMXPirRo6)PpYdpF1iWK8kCfyfe9u5a)HPPgDMh8j4n)p99GiaznJ)2lZ4N(HEXevKOvh1lMGVj5599INrb0lofjA1r9c8jUmfc0Rns9EXxLq9MZEbeppyqV5Sx8vquVyZPaRxBuTEbJz0b3BL61pthb3RVcSETrQxyAQrN1R(Y4zHMXF)TxLBsEGGpI45RQ2NEWmofjA1r)p9rEsCeYptxzkiQuDkWa)HPPgDMh85F67braYAg)TxMXp9d9IjQirRoQxmbFtYZ77ftkh0RlpO9wPzIOEzE(QrGj51lymJo4EzMF(yHi11lMac(0Jt9wPEJacEiFZ4V)2RYnjpqWhr88vv7tpygNIeT6O)N(ip0ZhlePUsIGp94ubMCkw)HPPgDMNHhs(N(EqeGSMXF)TxVXSxMNVAeysE9kGEHfGwDe8)Eb8rco6OETrQ3PGawVmpF1iWK86DQOE1PrOETrQ3PaD06LoyqOz83F793F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKhtEuXYcpF1iWK8(JtDrYZuGoAfe9u5aFom(Gp)LPhCks0QJcWcqRoQWZxncmjVMXF7fpJuVWrKAsE9MZE1EHeVEX0jhuSd6fBocaKdAVmpF1iWK8cnJ)(BVk3K8abFeXZxvTp9GzCks0QJ(F6J8a8QwGJi1K8(N(EaK9hN6IKNHOz83EXugjBKq9Q9gbA1r9kg96nci4ETS3ACo7L55RgbMKxVcOx6NJIVpbhAg)93EvUj5bc(iINVQAF6bZ4uKOvh9)0h5HNVAeysEL8kra9hN6IKh6NJIVpbhG6uyrTebkvfgkXad0phfFFco8uUwrubmsKvErGWzGb6NJIVpbhKdWrrtRoQ8Zr9S4Rat4eoXad0phfFFcoaIx1LjCrFKnIfWyGb6NJIVpbhONpwisDLebF6XjgyG(5O47tWHPtFujNLQAMJyGb6NJIVpbhgOErhHaLjkpygyG(5O47tWb5agkYTebkWco5OsLCogyG(5O47tWbWOcNdi4sIQLCwSe9OZAg)TxmPCqVU8G2BLMjI6L55RgbMKxVGXm6G71qY5fzGETr161qcuOeQxTxWOIi4E5Qrqtew9YZ0bNdUEZR30gjuVgsoVid07LwVvQ3iGGhY3m(7V9QCtYde8repFv1(0dMXPirRo6)PpYtELiGk8OLZ5)03dGS)4uxK8mu85Vm9GtrIwDuGNVAeysEL8kra1m(7V9QCtYde8repFv1(0dMXPirRo6)PpYtELiGk8OLZ5)03dGS)4uxK8m0H4Vm9q)Cu89j4Wt5AfrfWirw5fbcVz83F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKN8krav4rlNZ)PVhaz)XPUi5zO4ZN4uKOvhfONpwisDLebF6XPcm5uS(ltp0phfFFcoqpFSqK6kjc(0JtnJk3K8abFeXZxvTp9G5iGkIrV)N(ipGm6kc0tmc9xMEykofjA1rbE(QrGj5vYReb0xMs)Cu89j4amIu4PGOcocai3xMAQJolmfebmfzeQzu5MKhi4JiE(QQ9Phm)eekrf5PqPMrLBsEGGpI45RQ2NEWSpwOS6uG9xMEyQpIWf8XcLvNcSMXMXF)TxM5piE0i4EjCecREn5r9AJuVk3suVcOxfNkoT6OqZOYnjpGhEgpJqaFY5(ltpmffpAMiOuawaCX3jNIWQWZ3tp4MXF)Tx8ms9YZxncmjVIjp5G2RYnjVEDcW6fWhj4OJa9oyKUEzE(QrGj517aX56Ts9gbeCV6b3lWseb61gPErei6SELRxCks0QJcM8OILfE(QrGj5fAg)93EvUj5b(0dM5QZvuUj5vCcW(F6J8WZxncmjVIjp5G2m(BVyIks0QJ61gvRxcyYtnc07GrYgjuVqgLPjh0E)PCaH6DG4C9wPEJacU3knte1lZZxncmjVEfqVisHXk0m(7V9QCtYd8PhmJtrIwD0)tFKhWOmn5Gw8ZbeQuPzIOcpF1iWK8(N(EaK9hN6IKhmQCtWrf6ONqa8JtrIwDuGNVAeysEfWOmn5Gw8ZbeIbguUj4OcD0tia(XPirRokWZxncmjVY0PpcyiXlIbgWPirRokyYJkww45RgbMKN3PCtYlagLPjh0IFoGqHz05kicoYnjp8YZ0bNdUayuMMCql(5acfGJi1K8WWxCks0QJcM8OILfE(QrGj55D8mDW5GlagLPjh0IFoGqbe9u5a4v5MKxamkttoOf)CaHcZOZvqeCKBsEFXipthCo4cO4rLCw8ZbekGONkhW74z6GZbxamkttoOf)CaHci6PYbW7qWadm1uhDwafpQKZIFoGqyOzu5MKh4tpygmkttoOf)CaH(ltp14Cg45RgbMKxaohCFvUj5fMcIkvNcSaFurqja(9m8xMIXACodYnj0PUcxbCfMcr)V14CggtRamePEfqKYnm8fNIeT6OayuMMCql(5acvQ0mruHNVAeysEnJk3K8aF6bZifw0ZkaFf51Fz6PgNZapF1iWK8cW5G7lgXPirRokyYJkww45RgbMKh(XPirRokWZxncmjVIpI4kWkM8OpPpiE0OIjpIbgWPirRokyYJkww45RgbMKhE5z6GZbN3nm(GHMrLBsEGp9GzysTXAIo6Vm9uJZzGNVAeysEb4CW9TgNZakEujNf)CaHcW5G7lofjA1rbtEuXYcpF1iWK8WpofjA1rbE(QrGj5v8rexbwXKh9j9bXJgvm5rFIXACodWKAJ1eDuaoIutYZ7QX5mWZxncmjVaCePMKhg(XO4rZebLcWKAJGYuTX81mQCtYd8Phm)eekrGsolwIE0z)LPhCks0QJcM8OILfE(QrGj5HFCks0QJc88vJatYR4JiUcSIjp6t6dIhnQyYJ(wJZzGNVAeysEb4CW1m(BV4BI6ftKoBel0)EJaQxTx8vquVyZPaRx(OIGs9chrYbT3HmbHseO3C2lEs0JoRxUcSETSxfxkW9YvFF5G2lFurqjqOzu5MKh4tpyEkiQuDkW(hbuzWO4OcxbMCq9m8Fz6r5MKx4jiuIaLCwSe9OZc0hepAYb97m6CfeXhveuQyYJ8oLBsEHNGqjcuYzXs0JolqFq8Orfe9u5a4Nz6lthtRamePEva(KZbkYvMob6O9LP14CggtRamePEfI(nJk3K8aF6bZraveJE)P5K4w50h5bQtHf1seOuvyO0Fz6bNIeT6OGjpQyzHNVAeysE4LNPdohCE3q0mQCtYd8Phmhburm69)0h5HE(yHi1vse8PhN(ltp4uKOvhfm5rfll88vJatYd)EWPirRokqpFSqK6kjc(0JtfyYPy9fNIeT6OGjpQyzHNVAeysE4fNIeT6Oa98XcrQRKi4tpovGjNIL3nenJk3K8aF6bZraveJE)p9rEaJkCoGGljQwYzXs0Jo7Vm9GrCks0QJcM8OILfE(QrGj5HFp4uKOvhf45RgbMKxXhrCfyftE0NdLbgMc0rRGONkha)4uKOvhfm5rfll88vJatYddFRX5mWZxncmjVaCo4AgvUj5b(0dMJaQig9(F6J8a1HL)yjNffaKN4utY7Vm9GtrIwDuWKhvSSWZxncmjp86bNIeT6OqELiGk8OLZzZOYnjpWNEWCeqfXO3)tFKNNY1kIkGrISYlce(Fz6bNIeT6OGjpQyzHNVAeysE43Zq0m(BVEJzVrGCq7v7fyekf4EZZ7IaQxXO3)Ev3aflqVra1lZcrk8uquVyIeaqUEZObeyQ3C2lZZxncmjVqVyc2iHgia6FV(ijrIjd5OEJa5G2lZcrk8uquVyIeaqUEhi2yVmpF1iWK86nphw9kZE9g3KqN66L5kGRWuVcOx60QJG7vp4E1EJafk17G8WU1BL61LaR3ehH61gPEHJi1K86nN9AJuVtb6Of6fpJcOxfgg0R2l4PoxV4uxK61YETrQxEMo4CW1Bo7LzHifEkiQxmrcaixVdgPRx4uoO9AJcOxU64rNAsE9wjUgbuVI1Ra6nEisDat49AzVkaeFuV2OA9kwVdeNR3k1BeqW96tOjXnhw9MxV8mDW5Gl0mQCtYd8Phmhburm69)0h5bgrk8uqubhbaK7Vm9GtrIwDuWKhvSSWZxncmjp86bNIeT6OqELiGk8OLZ5xmwJZzqUjHo1v4kGRWuayk3lp14CgKBsOtDfUc4kmfE6hfGPCVyGbMYZdokwqUjHo1v4kGRWedmGtrIwDuGNVAeysEL8kraXad4uKOvhfm5rfll88vJatYdVYzeYpDQrWLPaD0ki6PYbgshsXipthCo4(Cy8bdyOz83F7Lj0GEHKrxVEdONyeQx6mew)7froHa9MxVGrfrW9kg96L5mRELBMONAsE9AJQ1Ra69sRxSiRxq03prgbh6TxmzY3PCc0Rns96JiCsgb96KJ6DWiD9oJh3K8uxOzu5MKh4tpyocOIy07)PpYdiJUIa9eJq)LPhmItrIwDuWKhvSSWZxncmjp86HzJp)ymItrIwDuiVseqfE0Y5eV4dgyGbmYudjNxKfgoiGaiJUIa9eJqFnKCErwy4qeOvh91qY5fzHHd8mDW5GlGONkhGbgyQHKZlYcdniGaiJUIa9eJqFnKCErwyOHiqRo6RHKZlYcdnWZ0bNdUaIEQCamGHVyKP0phfFFcoaJifEkiQGJaaYXad8mDW5GlaJifEkiQGJaaYfq0tLdG3HadnJ)2lEqcuOeQxiz01R3a6jgH6LuKdREhi2yVEJBsOtD9YCfWvyQ3e17Gr66vSEhOGE9rexbwOzu5MKh4tpyMRhNCLACo)F6J8aYORiqpXK8(ltpmLNhCuSGCtcDQRWvaxHPVM8i8pemWqnoNb5Me6uxHRaUctbGPCV8uJZzqUjHo1v4kGRWu4PFuaMY9Qz83E9gg9a9AJQ1lC27LwVv6OPy9Y88vJatYRxWygDW9IPpcSERuVrab3BgnGat9MZEzE(QrGj51RA9cYh1RFkNfAgvUj5b(0dMJaQig9(F6J8ihGJIMwDu5NJ6zXxbMWjC6Vm9q)Cu89j4auNclQLiqPQWqPV4uKOvhfm5rfll88vJatYdVEWPirRokKxjcOcpA5C2mQCtYd8Phmhburm69)0h5z60hvYzPQM5O)Y0d9ZrX3NGdqDkSOwIaLQcdL(ItrIwDuWKhvSSWZxncmjp86bNIeT6OqELiGk8OLZzZOYnjpWNEWCeqfXO3)tFKNbQx0riqzIYd(Vm9q)Cu89j4auNclQLiqPQWqPV4uKOvhfm5rfll88vJatYdVEWPirRokKxjcOcpA5C2mQCtYd8Phmhburm69)0h5roGHIClrGcSGtoQujN7Vm9q)Cu89j4auNclQLiqPQWqPV4uKOvhfm5rfll88vJatYdVEWPirRokKxjcOcpA5C2mQCtYd8Phmhburm69)0h5beVQlt4I(iBelG9xMEOFok((eCaQtHf1seOuvyO0xCks0QJcM8OILfE(QrGj5Hxp4uKOvhfYRebuHhTCoBgvUj5b(0dMJaQig9a)LPhCks0QJcM8OILfE(QrGj5Hxp4uKOvhfYRebuHhTCoBg)T3FeG6fFrjW6LjjoTxl71qcuOeQxVjKaCy1R3GlChfAgvUj5b(0dMNOeyLlXP)LPhu8OzIGsbOib4WQiCH7OV14Cg45RgbMKxaohCFXiofjA1rbtEuXYcpF1iWK8WlpthCo4yGbCks0QJcM8OILfE(QrGj5HFCks0QJc88vJatYR4JiUcSIjp6t6dIhnQyYJWqZ4V96nrwV2i1lZsaCX3jNIWQxMNVNEW9wJZzVr))9gphba9YZxncmjVEfqVGmVqZOYnjpWNEWmpJNriGp5C)LPhu8OzIGsbybWfFNCkcRcpFp9G)YZ0bNdUqnoNfybWfFNCkcRcpFp9GdisHX6BnoNbybWfFNCkcRcpFp9GlkIRhfGZb3xMwJZzawaCX3jNIWQWZ3tp4q0)lgXPirRokyYJkww45RgbMK3Nk3K8ctucSA6SaxbwXKhHxEMo4CWfQX5SalaU47Ktryv457PhCaoIutYJbgWPirRokyYJkww45RgbMKh(hcm0mQCtYd8PhmRiUEuH(W3LajV)Y0dkE0mrqPaSa4IVtofHvHNVNEWF5z6GZbxOgNZcSa4IVtofHvHNVNEWbePWy9TgNZaSa4IVtofHvHNVNEWffX1JcW5G7ltRX5malaU47Ktryv457PhCi6)fJ4uKOvhfm5rfll88vJatY7t6dIhnQyYJ(u5MKxyIsGvtNf4kWkM8i8YZ0bNdUqnoNfybWfFNCkcRcpFp9GdWrKAsEmWaofjA1rbtEuXYcpF1iWK8W)q8LPM6OZcO4rLCw8ZbecdnJk3K8aF6bZtucSA6S)Y0dkE0mrqPaSa4IVtofHvHNVNEWF5z6GZbxOgNZcSa4IVtofHvHNVNEWbe9u5a4NRaRyYJ(wJZzawaCX3jNIWQWZ3tp4YeLalaNdUVmTgNZaSa4IVtofHvHNVNEWHO)xmItrIwDuWKhvSSWZxncmjVp5kWkM8i8YZ0bNdUqnoNfybWfFNCkcRcpFp9GdWrKAsEmWaofjA1rbtEuXYcpF1iWK8W)qGHMrLBsEGp9G5jkbw5sC6Fz6bfpAMiOuawaCX3jNIWQWZ3tp4V8mDW5GluJZzbwaCX3jNIWQWZ3tp4aIuyS(wJZzawaCX3jNIWQWZ3tp4YeLalaNdUVmTgNZaSa4IVtofHvHNVNEWHO)xmItrIwDuWKhvSSWZxncmjp8YZ0bNdUqnoNfybWfFNCkcRcpFp9GdWrKAsEmWaofjA1rbtEuXYcpF1iWK8W)qGHMrLBsEGp9GzU6CfLBsEfNaS)N(ip88vJatYR4pQa6Vm9GtrIwDuWKhvSSWZxncmjp87bFyGbCks0QJcM8OILfE(QrGj5HFCks0QJc88vJatYR4JiUcSIjp6lpthCo4c88vJatYlGONkha)4uKOvhf45RgbMKxXhrCfyftEuZOYnjpWNEWmkEujNf)CaH(ltp14CgqXJk5S4NdiuaohCFzAnoNHPGiGLOxi6)fJ4uKOvhfm5rfll88vJatYdVEQX5mGIhvYzXphqOaCePMK3xCks0QJcM8OILfE(QrGj5HxLBsEHPGOs1PalmJoxbr8rfbLkM8igyaNIeT6OGjpQyzHNVAeysE4DkqhTcIEQCam0m(BV)uMUEvqVp9WQx8vquVyZPad0Rc61pbaP6OENjQxMNVAeysEHEHeRgs5wVz06nN9AJuVtKYnjp11lpF(5rN1Bo71gPEV4RsOEZzV4RGOEXMtbgOxBuTEhioxVNArK6Cy1lI4Jkck1lCejh0ETrQxMNVAeysE96pQaQ3kX1iG61ptNCq7vpSSr5G2RVcSETr16DG4C9EP1luKEwV61l9HH0EXxbr9InNcSEHJi5G2lZZxncmjVqZ4V)2RYnjpWNEWmofjA1r)JaQKZzbkh2ZW)JaQmyuCuHRatoOEg()PpYZuquP6uGv8Z0jh0)4uxK8OCtYlmfevQofyb(OIGsGYePCtYtDFIrCks0QJcM8OILfE(QrGj59PYnjVayuMMCql(5acfMrNRGi4i3K8(X4uKOvhfaJY0KdAXphqOsLMjIk88vJatYdddP8mDW5GlmfevQofyb4isnjpVBy8ZZ0bNdUWuquP6uGfE6hf(OIGsGpXPirRokK4iKFMUYuquP6uGbgs5z6GZbxykiQuDkWcWrKAsEEhgRX5mWZxncmjVaCePMK3qkpthCo4ctbrLQtbwaoIutYdddPdPd)fNIeT6OGjpQyzHNVAeysE4FkqhTcIEQCGMXF7fturIwDuV2OA9YZZqPd07pnM0jF0l(60hb6ncuOuVw2lDGiI6vmqV8rfbLa9QiQx)mDeCVZe1lZZxncmjVqVycNdREJaQ3FAmPt(Ox81Ppc0BgnGat9MZEzE(QrGj517Gr66DgDUE5Jkckb6LRxVvQ3SAQCeCVWrKCq71gPEp6dRxMNVAeysEHMXF)TxLBsEGp9GzCks0QJ(F6J84pM0jFu8Z0jh0)Y0JYnbhvOJEcbWpofjA1rbE(QrGj5vMo9radjEr)XPUi5bNIeT6OGjpQyzHNVAeysEFwJZzGNVAeysEb4isnjpVBiWVYnjVG)ysN8rz60hbcZOZvqeFurqPIjp6tEMo4CWf8ht6KpktN(iqaoIutYZ7uUj5faJY0KdAXphqOWm6Cfebh5MK3pgNIeT6OayuMMCql(5acvQ0mruHNVAeysEFXPirRokyYJkww45RgbMKh(Nc0rRGONkhGbgqXJMjckfaXR4LCqbLQJaa5GYadM8i8penJ)2lMYiD9gbYbTx81PpcyiXlQx56L55RgbMK3)EbkoQxf07tpS6LpQiOeOxf0RFcas1r9otuVmpF1iWK86DGyJz06LR((Ybn0m(7V9QCtYd8PhmJtrIwD0)tFKh)XKo5JIFMo5G(xMEuUj4OcD0tiaE9GtrIwDuGNVAeysELPtFeWqIx0FCQlsEWPirRokyYJkww45RgbMKh(vUj5f8ht6KpktN(iqygDUcI4Jkckvm5rENYnjVayuMMCql(5acfMrNRGi4i3K8(X4uKOvhfaJY0KdAXphqOsLMjIk88vJatY7lofjA1rbtEuXYcpF1iWK8W)uGoAfe9u5amWakE0mrqPaiEfVKdkOuDeaihugyWKhH)HOzu5MKh4tpyMRoxr5MKxXja7)PpYdk9l(JkG(dmKWnpd)xMEQX5mGIhvYzXphqOq0)lofjA1rbtEuXYcpF1iWK8Wl(0m(BVmdym9rG1Rns9ItrIwDuV2OA9YZZqPd0l(kiQxS5uG1BeOqPETSx6are1RyGE5Jkckb6vruVQdK96NPJG7DMOEXKJh1Bo79NYbek0m(7V9QCtYd8PhmJtrIwD0)iGk5CwGYH9m8)iGkdgfhv4kWKdQNH)F6J8mfevQofyf)mDYb9F67bq2FCQlsE4z6GZbxafpQKZIFoGqbe9u5a4x5MKxykiQuDkWcZOZvqeFurqPIjpY7uUj5faJY0KdAXphqOWm6Cfebh5MK3pgJ4uKOvhfaJY0KdAXphqOsLMjIk88vJatY7lpthCo4cGrzAYbT4Ndiuarpvoa(5z6GZbxafpQKZIFoGqbe9u5ay4lpthCo4cO4rLCw8ZbekGONkha)tb6Ovq0tLd8xMEykofjA1rHPGOs1PaR4NPtoOFn1rNfqXJk5S4Ndi03ACodO4rLCw8ZbekaNdUMXF7ftzKUEXKuemxbMCq7fFD6J6fIHeVO)9IVcI6fBofyGEbJz0b3BL6nci4ETSxO0ri1OEXKsRxigIuVa9QhCVw2l9HrhCVyZPaJq9oKPaJqHMrLBsEGp9G5PGOs1Pa7FeqLColq5WEg(FeqLbJIJkCfyYb1ZW)LPhMItrIwDuykiQuDkWk(z6Kd6xCks0QJcM8OILfE(QrGj5Hx85RYnbhvOJEcbWRhCks0QJcJkcUWvGvMo9radjErFz6uqeWuKrOGYnbh9LP14CggtRamePEfI(FXynoNHrsn5GwI(HO)xLBsEHPtFeWqIxuG(G4rJki6PYbWp(egcgyGpQiOeOmrk3K8uhE9mum0m(BVmRisoO9IVcIaMImc9Vx8vquVyZPad0RIOEJacUxG8eNICy1RL9chrYbTxMNVAeysEHE9MOJqQZH1)ETrcREve1BeqW9AzVqPJqQr9IjLwVqmePEb6DWiD9YrIb6DG4C9EP1BL6DGcmcUx9G7DGyJ9InNcmc17qMcmc9VxBKWQxWygDW9wPEb(isH7nJwVw27tLZu561gPEXMtbgH6DitbgH6TgNZqZOYnjpWNEW8uquP6uG9pcOsoNfOCypd)pcOYGrXrfUcm5G6z4)Y0ZuqeWuKrOGYnbh9LpQiOeaVEg(ltXPirRokmfevQofyf)mDYb9lgzQYnjVWuquvDUa9bXJMCq)YuLBsEbFSqz1Palixz6eOJ23ACodJKAYbTe9drFgyq5MKxykiQQoxG(G4rtoOFzAnoNHX0kadrQxHOpdmOCtYl4JfkRofyb5ktNaD0(wJZzyKutoOLOFi6)LP14CggtRamePEfI(yOz83Ezg4sbUxU67lh0EXxbr9InNcSE5Jkckb6DWO4OE5J6DKtoO9czuMMCq79NYbeQzu5MKh4tpyEkiQuDkW(hbuzWO4OcxbMCq9m8Fz6r5MKxamkttoOf)CaHc0hepAYb97m6CfeXhveuQyYJWVYnjVayuMMCql(5acfmH7vbrWrUj59TgNZWyAfGHi1RaCo4(AYJW7W4tZOYnjpWNEWmxDUIYnjVIta2)tFKhGPhSIGlO0utY7Vm9GtrIwDuWKhvSSWZxncmjp8IpFRX5mGIhvYzXphqOaCo4AgvUj5b(0dMb8eXhBgBgvUj5bck3eCuXuhDgWJtWjh0snF1)Y0JYnbhvOJEcbW7WFRX5mWZxncmjVaCo4(IrCks0QJcM8OILfE(QrGj5HxEMo4CWfCco5GwQ5RgGJi1K8yGbCks0QJcM8OILfE(QrGj5HFp4dgAgvUj5bck3eCuXuhDg4tpy(rgLO)Y0dofjA1rbtEuXYcpF1iWK8WVh8HbgWipthCo4cpYOefGJi1K8WpofjA1rbtEuXYcpF1iWK8(YutD0zbu8Osol(5acHbgyWuhDwafpQKZIFoGqFRX5mGIhvYzXphqOq0)lofjA1rbtEuXYcpF1iWK8WRYnjVWJmkrbEMo4CWXadtb6Ovq0tLdGFCks0QJcM8OILfE(QrGj51mQCtYdeuUj4OIPo6mWNEWmmsHMhOurKAJ)LPhtD0zb1rFamKcgYPGYmIW6lgRX5mWZxncmjVaCo4(Y0ACodJPvagIuVcrFm0m2mQCtYde45RgbMKxHNPdohCap(Pj51mQCtYde45RgbMKxHNPdohCGp9G5Qlt4YmIWQzu5MKhiWZxncmjVcpthCo4aF6bZvcbiKxYb9Vm9uJZzGNVAeysEHOFZOYnjpqGNVAeysEfEMo4CWb(0dMNcIQUmHBgvUj5bc88vJatYRWZ0bNdoWNEWSECcyi1v4QZ1mQCtYde45RgbMKxHNPdohCGp9GztEuzGI8)ltpO4rZebLcg98tK6kduK)3ACod0hJAeysEHOFZOYnjpqGNVAeysEfEMo4CWb(0dMJaQig9(tZjXTYPpYduNclQLiqPQWqPMrLBsEGapF1iWK8k8mDW5Gd8Phmhburm69)0h5roahfnT6OYph1ZIVcmHt4uZOYnjpqGNVAeysEfEMo4CWb(0dMJaQig9(F6J8mD6Jk5SuvZCuZOYnjpqGNVAeysEfEMo4CWb(0dMJaQig9(F6J8mq9IocbktuEWnJk3K8abE(QrGj5v4z6GZbh4tpyocOIy07)PpYJCadf5wIafybNCuPsoxZOYnjpqGNVAeysEfEMo4CWb(0dMJaQig9(F6J8aIx1LjCrFKnIfWAgvUj5bc88vJatYRWZ0bNdoWNEWCeqfXOhOzSzu5MKhiWZxncmjVI)Ocipob6Obky6JWqF0z)LPNACod88vJatYlaNdUMXF7LzgyYtnQ3XCqVU8G2lZZxncmjVEhioxVofy9AJ65fOxl7fs86ftNCqXoOxS5iaqoO9AzVWKrONCuVJ5GEXxbr9InNcmqVGXm6G7Ts9gbeCOz83F7v5MKhiWZxncmjVI)OcOp9GzCks0QJ(hbujNZcuoSNH)hbuzWO4OcxbMCq9m8)tFKh6dJoycUWZxncmjVcIEQCG)PVhaz)XPUi5PgNZapF1iWK8ci6PYb(SgNZapF1iWK8cWrKAsE)ymYZ0bNdUapF1iWK8ci6PYbWFnoNbE(QrGj5fq0tLdGH)Y0dpp4Oyb5Me6uxHRaUctnJ)2lZagg0Rns9chrQj51Bo71gPEHeVEX0jhuSd6fBocaKdAVmpF1iWK861YETrQx6G7nN9AJuV8icrN1lZZxncmjVELzV2i1lxbwVdYOdUxE(8DKr9chrYbTxBua9Y88vJatYl0m(7V9QCtYde45RgbMKxXFub0NEWmofjA1r)JaQKZzbkh2ZW)JaQmyuCuHRatoOEg()PpYd9Hrhmbx45RgbMKxbrpvoW)03Jcd)hN6IKhCks0QJcaVQf4isnjV)Y0dpp4Oyb5Me6uxHRaUctFXynoNbq8kEjhuqP6iaqoOfePWyfI(mWaofjA1rb6dJoycUWZxncmjVcIEQCa8oCyi(Xq5WHN(XpgJ14CgaXR4LCqbLQJaa5GgE6hfGPCV8UACodG4v8soOGs1raGCqdat5EHbm0mQCtYde45RgbMKxXFub0NEWCvHwYzXqc3lWFz6PgNZapF1iWK8cW5GRzu5MKhiWZxncmjVI)OcOp9GzNGtoOLA(Q)LPhLBcoQqh9ecG3H)wJZzGNVAeysEb4CW1m(BVykInMrRxVXnj0PUEzUc4km9Vxm9rG1Beq9IVcI6fBofyGEhmsxV2iHvVdYd7wVV4Xh7LJed0REW9oyKUEXxbralrVEfqVW5Gl0mQCtYde45RgbMKxXFub0NEW8uquP6uG9pcOsoNfOCypd)pcOYGrXrfUcm5G6z4)Y0dt55bhfli3KqN6kCfWvy6lFurqjaE9m83ACod88vJatYle9)Y0ACodtbralrVq0)ltRX5mmMwbyis9ke9)oMwbyis9Qa8jNduKRmDc0r7ZACodJKAYbTe9drF8p0MXF7ftrSXE9g3KqN66L5kGRW0)EXxbr9InNcSEJaQxWygDW9wPEvyyXK8uNdRE55bmKkhb3li71gvRxX6va9EP1BL6nci4EJNJaGE9g3KqN66L5kGRWuVcOxTMrRxl7L(WxquVjQxBKquVkI69LiQxBuVEPlJqh7fFfe1l2CkWa9AzV0hgDW96nUjHo11lZvaxHPETSxBK6Lo4EZzVmpF1iWK8cnJ)(BVk3K8abE(QrGj5v8hva9PhmJtrIwD0)iGk5CwGYH9m8)iGkdgfhv4kWKdQNH)F6J8qF4tCJGltbrLQtbg4F67bq2FCQlsEuUj5fMcIkvNcSaFurqjqzIuUj5PUpXiofjA1rb6dJoycUWZxncmjVcIEQCaVRgNZGCtcDQRWvaxHPaCePMKhggs5z6GZbxykiQuDkWcWrKAsE)LPhEEWrXcYnj0PUcxbCfMAg)93EvUj5bc88vJatYR4pQa6tpygNIeT6O)ravY5SaLd7z4)ravgmkoQWvGjhupd))0h55icMGltbrLQtbg4F67bq2FCQlsE4K4WiofjA1rb6dJoycUWZxncmjVcIEQCGHumwJZzqUjHo1v4kGRWuaoIutYZ7GYHdp9dmGH)Y0dpp4Oyb5Me6uxHRaUctnJk3K8abE(QrGj5v8hva9PhmpfevQofy)JaQKZzbkh2ZW)JaQmyuCuHRatoOEg(Vm9WZdokwqUjHo1v4kGRW0x(OIGsa86z4VyeNIeT6Oa9HpXncUmfevQofya86bNIeT6OWrembxMcIkvNcmadmGtrIwDuG(WOdMGl88vJatYRGONkha)EQX5mi3KqN6kCfWvykahrQj5Xad14CgKBsOtDfUc4kmfaMY9c)dLbgQX5mi3KqN6kCfWvykGONkha)q5WHN(bdmWZ0bNdUayuMMCql(5acfqKcJ1xLBcoQqh9ecGxp4uKOvhf45RgbMKxbmkttoOf)CaH(YtC0PNfob6OvMkHHV14Cg45RgbMKxi6)fJmTgNZWuqeWs0le9zGHACodYnj0PUcxbCfMci6PYbWp(egcm8LP14CggtRamePEfI(FhtRamePEva(KZbkYvMob6O9znoNHrsn5GwI(HOp(hAZOYnjpqGNVAeysEf)rfqF6bZC15kk3K8koby)p9rEuUj4OIPo6mqZOYnjpqGNVAeysEf)rfqF6bZ88vJatY7FeqLColq5WEg(FeqLbJIJkCfyYb1ZW)LPNACod88vJatYlaNdUV4uKOvhfm5rfll88vJatYd)EWNVyKPO4rZebLcWcGl(o5uewfE(E6bZad14CgGfax8DYPiSk8890doe9zGHACodWcGl(o5uewfE(E6bxMOeyHO)xtD0zbu8Osol(5ac9LNPdohCHAColWcGl(o5uewfE(E6bhqKcJfg(IrMIIhnteukafjahwfHlChXadWunoNbOib4WQiCH7Oq0hdFXit5jo60ZchXrPlrWmWapthCo4cWKAJ1eDuarpvoadmuJZzaMuBSMOJcrFm8fJmLN4OtplGJoBeledmWZ0bNdUWtqOebk5Syj6rNfq0tLdGHVyu5MKx4rgLOGCLPtGoAFvUj5fEKrjkixz6eOJwbrpvoa(9GtrIwDuGNVAeysEfUcScIEQCagyq5MKxaWteFmqFq8Ojh0Vk3K8caEI4Jb6dIhnQGONkha)4uKOvhf45RgbMKxHRaRGONkhGbguUj5fMcIQQZfOpiE0Kd6xLBsEHPGOQ6Cb6dIhnQGONkha)4uKOvhf45RgbMKxHRaRGONkhGbguUj5f8XcLvNcSa9bXJMCq)QCtYl4JfkRofyb6dIhnQGONkha)4uKOvhf45RgbMKxHRaRGONkhGbguUj5fMo9radjErb6dIhn5G(v5MKxy60hbmK4ffOpiE0OcIEQCa8JtrIwDuGNVAeysEfUcScIEQCam0m(BVyc2iH6LNPdohCGETr16fmMrhCVvQ3iGG7DGyJ9Y88vJatYRxWygDW9MNdRERuVrab37aXg7vVEvUfvxVmpF1iWK86LRaRx9G79sR3bIn2R2lK41lMo5GIDqVyZraGCq71hL8qZOYnjpqGNVAeysEf)rfqF6bZC15kk3K8koby)p9rE45RgbMKxHNPdohCG)Y0tnoNbE(QrGj5fq0tLdG3HegyGNPdohCbE(QrGj5fq0tLdG)HOzu5MKhiWZxncmjVI)OcOp9G5PtFeWqIx0Fz6bJ14CggtRamePEfI(FvUj4OcD0tiaE9GtrIwDuGNVAeysELPtFeWqIxegyGbmwJZzykicyj6fI(FvUj4OcD0tiaE9GtrIwDuGNVAeysELPtFeWqIxK3HIhnteukmfebSe9WqZOYnjpqGNVAeysEf)rfqF6bZ(yHYQtb2Fz6PgNZaiEfVKdkOuDeaih0cIuyScr)V14CgaXR4LCqbLQJaa5GwqKcJvarpvoaE5kWkM8OMrLBsEGapF1iWK8k(JkG(0dM9XcLvNcS)Y0tnoNHPGiGLOxi63mQCtYde45RgbMKxXFub0NEWSpwOS6uG9xMEQX5m4Jfk5of8cr)V14Cg8XcLCNcEbe9u5a4LRaRyYJ(IXACod88vJatYlGONkhaVCfyftEedmuJZzGNVAeysEb4CWHHVk3eCuHo6jea)4uKOvhf45RgbMKxz60hbmK4f1mQCtYde45RgbMKxXFub0NEWSpwOS6uG9xMEQX5mmMwbyis9ke9)wJZzGNVAeysEHOFZOYnjpqGNVAeysEf)rfqF6bZ(yHYQtb2Fz6Xhr4kq5WHHdaEI4JFRX5mmsQjh0s0pe9)QCtWrf6ONqa8JtrIwDuGNVAeysELPtFeWqIx03ACod88vJatYle9Bg)T3FeqoO9czuMMCq79NYbeQx4isoO9Y88vJatYRxl7fralruV4RGOEXMtbwV6b37pnM0jF0l(60h1lFurqjqVC96Ts9wPJMcxu3)ERrR3iiQohw9MNdREZRxMrYmhAgvUj5bc88vJatYR4pQa6tpygmkttoOf)CaH(ltp14Cg45RgbMKxi6)LPk3K8ctbrLQtbwGpQiOe4RYnbhvOJEcbWRhCks0QJc88vJatYRagLPjh0IFoGqFvUj5f8ht6KpktN(iqygDUcI4Jkckvm5r4DgDUcIGJCtY7VCgHqrFRitpk3K8ctbrLQtbwGpQiOeWJYnjVWuquP6uGfE6hf(OIGsGMrLBsEGapF1iWK8k(JkG(0dM9ht6KpktN(iWFz6PgNZapF1iWK8cr)VgsXrUIjpc)14Cg45RgbMKxarpvoWxmIrLBsEHPGOs1PalWhveucG)H)AQJol4Jfk5of8(QCtWrf6ONqapdJbgyGPM6OZc(yHsUtbpgyq5MGJk0rpHa4Dym8TgNZWiPMCqlr)q0)ZX0kadrQxfGp5CGICLPtGoA4FOnJk3K8abE(QrGj5v8hva9PhmpD6Jags8I(ltp14Cg45RgbMKxaohCF5z6GZbxGNVAeysEbe9u5a4NRaRyYJ(QCtWrf6ONqa86bNIeT6OapF1iWK8ktN(iGHeVOMrLBsEGapF1iWK8k(JkG(0dMNcIQQZ9xMEQX5mWZxncmjVaCo4(YZ0bNdUapF1iWK8ci6PYbWpxbwXKh9LP88GJIfMo9rfLZrKj51mQCtYde45RgbMKxXFub0NEWmGNi(4Fz6PgNZapF1iWK8ci6PYbWlxbwXKh9TgNZapF1iWK8crFgyOgNZapF1iWK8cW5G7lpthCo4c88vJatYlGONkha)CfyftEuZOYnjpqGNVAeysEf)rfqF6bZobNCql18v)ltp14Cg45RgbMKxarpvoa(HYHdp9JVk3eCuHo6jeaVd3mQCtYde45RgbMKxXFub0NEWmmsHMhOurKAJ)LPNACod88vJatYlGONkha)q5WHN(X3ACod88vJatYle9BgBg)TxmjY5tOEXPirRoQxBuTE55zQCGETrQxLBr11lbm5Pgb3RjpQxBuTETrQ3J(W6L55RgbMKxVdeNR3k1lIuyScnJ)(BVk3K8abE(QrGj5vm5jhup4uKOvh9)0h5HNVAeysEfePWyvm5r)XPUi5HNPdohCbE(QrGj5fq0tLd8JPp8jUrWfVKd2jh0cIGJCtYRz83EXZi1lxbwVM8OEZzV2i1lWNCUETr16DG4C9wPE9rexbwVYzzVmpF1iWK8cnJ)(BVk3K8abE(QrGj5vm5jh0p9GzCks0QJ(F6J8WZxncmjVIpI4kWkM8O)4uxK8GrLBsEHPGOQ6CbUcSIjp6hZuEEWrXctN(OIY5iYK8(u5MKxaWteFmWvGvm5rFYZdokwy60hvuohrMKhg(Xyu5MGJk0rpHa4hNIeT6OapF1iWK8ktN(iGHeVim8PYnjVW0PpcyiXlkWvGvm5r)ymQCtWrf6ONqa86bNIeT6OapF1iWK8ktN(iGHeVim4D4uKOvhf45RgbMKxHRaRGONkhOz83F7v5MKhiWZxncmjVIjp5G(PhmJtrIwD0)tFKhE(QrGj5vm5r)XPUi5bNIeT6OapF1iWK8kisHXQyYJAg)TxMf5uS6L55RgbMKxVZe1Ronc1l(kicykYiuVXZraqV4uKOvhfMcIaMImcv45RgbMKxVcOxazHMXF)TxLBsEGapF1iWK8kM8Kd6NEWmofjA1r)p9rE45RgbMKxXKh9p9980p(JtDrYZuqeWuKrOaIEQCG)Y0JPo6SWuqeWuKrOVmfNIeT6OWuqeWuKrOcpF1iWK8Ag)TxMf5uS6L55RgbMKxVZe1lMScl6z9cXxrE1Rm7vSEhioxV88r9MZzV8mDW5GRxqMxOz83F7v5MKhiWZxncmjVIjp5G(PhmJtrIwD0)tFKhE(QrGj5vm5r)tFpp9J)4uxK8WZ0bNdUasHf9ScWxrEfq0tLd8xME4jo60ZcEHfs07lpthCo4cifw0ZkaFf5varpvoG3nm(GFCks0QJc88vJatYRyYJAg)TxMf5uS6L55RgbMKxVZe17qMGqjc0Bo7fpj6rN1m(7V9QCtYde45RgbMKxXKNCq)0dMXPirRo6)PpYdpF1iWK8kM8O)PVNN(XFCQlsE4z6GZbx4jiuIaLCwSe9OZci6PYb(ltp8ehD6zbC0zJyH(YZ0bNdUWtqOebk5Syj6rNfq0tLd4DdDiWpofjA1rbE(QrGj5vm5rnJ)2lZICkw9Y88vJatYR3zI6LzrQnwt0rHMXF)TxLBsEGapF1iWK8kM8Kd6NEWmofjA1r)p9rE45RgbMKxXKh9p9980p(JtDrYdpthCo4cWKAJ1eDuarpvoWNySgNZamP2ynrhfGJi1K88UACod88vJatYlahrQj5HHFmkE0mrqPamP2iOmvBmF)LPhEIJo9SWrCu6se8xEMo4CWfGj1gRj6OaIEQCaVBy8b)4uKOvhf45RgbMKxXKh1m(BVmlYPy1lZZxncmjVENjQxMfP2i2b9IVQnMVEbMY9c0Rm71gje1RIOEvRxhPaRxBq2RPiOKbcnJ)(BVk3K8abE(QrGj5vm5jh0p9GzCks0QJ(F6J8WZxncmjVIjp6F675PF8hN6IKNACodWKAJ1eDuarpvoG3vJZzGNVAeysEb4isnjV)Y0dkE0mrqPamP2iOmvBmFFRX5matQnwt0rHO)xLBcoQqh9ecGxpdTz83EzwKtXQxMNVAeysE9otuV2i1lZ8ZhlePUEXeqWNECQ3ACo7vM9AJuV(oflc1Ra6ncKdAV2OA9Ai58ISqZ4V)2RYnjpqGNVAeysEftEYb9tpygNIeT6O)N(ip88vJatYRyYJ(N(EE6h)XPUi5bNIeT6Oa98XcrQRKi4tpovGjNIL3HrEMo4CWfONpwisDLebF6XPaCePMKN3XZ0bNdUa98XcrQRKi4tpofq0tLdGHFmt5z6GZbxGE(yHi1vse8PhNcisHX6Vm9q)Cu89j4a98XcrQRKi4tpo1m(BVmlYPy1lZZxncmjVENjQxVjNclQLiqVytHHs)7nEoca6vSEhKrhCVvQxyYPyrW96YdkH61g1R3HIp9ciEEWGqZ4V)2RYnjpqGNVAeysEftEYb9tpygNIeT6O)N(ip88vJatYRyYJ(N(EE6h)XPUi5HNPdohCbOofwulrGsvHHsbe9u5a)LPh6NJIVpbhG6uyrTebkvfgk9LNPdohCbOofwulrGsvHHsbe9u5aE3qXh8JtrIwDuGNVAeysEftEuZ4V9YSiNIvVmpF1iWK86nEM46fto)PEPp8feb6vM9kg2b9g9dnJ)(BVk3K8abE(QrGj5vm5jh0p9GzCks0QJ(F6J8WZxncmjVIjp6F675PF8hN6IKNACodO4rLCw8ZbekGONkh4Vm9yQJolGIhvYzXphqOV14Cg45RgbMKxaohCnJ)2lZICkw9Y88vJatYR3zI6vVEPpmK2lMC8OEZzV)uoGq9kZETrQxm54r9MZE)PCaH6DqgDW9YZh1BoN9YZ0bNdUEvRxhPaR3HOxaXZdg0BLMjI6L55RgbMKxVdYOdo0m(7V9QCtYde45RgbMKxXKNCq)0dMXPirRo6)PpYdpF1iWK8kM8O)PVNN(XFCQlsE4z6GZbxafpQKZIFoGqbe9u5aFwJZzafpQKZIFoGqb4isnjV)Y0JPo6SakEujNf)CaH(wJZzGNVAeysEb4CW9LNPdohCbu8Osol(5acfq0tLd85qGFCks0QJc88vJatYRyYJAg)TxMf5uS6L55RgbMKxVYSxMLa4IVtofHvVmpFp9G7DqgDW9EP1BL6frkmw9otuVI1lwKfAg)93EvUj5bc88vJatYRyYtoOF6bZ4uKOvh9)0h5HNVAeysEftE0)03Zt)4po1fjp8mDW5GluJZzbwaCX3jNIWQWZ3tp4aIEQCG)Y0dkE0mrqPaSa4IVtofHvHNVNEWFRX5malaU47Ktryv457PhCaohCnJ)2lMSkW9YmJJod499YSiNIvVmpF1iWK86DMOEvy4Eb(6Gd0Bo7Lz3BI69LiQxfgg0RnQwVdeNRxNcSED5bLq9AJ617WdrVaINhmi0lEgja1lo1fjqVkIoSB9EeNaafjoS6n9n5PUELRx156LRaceAg)93EvUj5bc88vJatYRyYtoOF6bZ4uKOvh9)0h5HNVAeysEftE0)03Zt)4po1fjpivGleo6SGcddcY9xMEqQaxiC0zbfggeOpeGb(IubUq4OZckmmiWZ4z41dZ(lsf4cHJolOWWGaCePMKhEhEiAg)TxmzvG7LzghDgW77Lz4gOyb6ncOEzE(QrGj517aXg7fx0DesRItmS6fPcCVeo6mW)EtCecjWuV6HvVWKtXc0Rtagb3RwtCuVw27t9I6feruVI1luYa9gbeCVJeIcnJ)(BVk3K8abE(QrGj5vm5jh0p9GzCks0QJ(F6J8WZxncmjVIjp6po1fjpivGleo6SaUO7iKwDuqUFmtrQaxiC0zbCr3riT6Oq0)Vm9GubUq4OZc4IUJqA1rb6dbyGV4uKOvhf45RgbMKxbrkmwftEe(rQaxiC0zbCr3riT6OGCnJ)27pcq9AJuVh9H1lZZxncmjVEZRxEMo4CW1Rm7vSEhKrhCVxA9wPEPp8jUrW9AzVWKtXQxBK6fWhj4OJG7npQ3e1Rns9c4JeC0rW9Mh17Gm6G7Du99PRxhba9AJ617qXNEbeppyqVvAMiQxBK6DkqhTEPdgeAg)93EvUj5bc88vJatYRyYtoOF6bZ4uKOvh9)0h5HNVAeysEftE0FCQlsEWPirRokWZxncmjVcIuySkM8O)Y0dofjA1rbE(QrGj5vqKcJvXKh9jpthCo4c88vJatYlahrQj59JX4WEhgXNaM6N4tyO)ytD0zHPGiGPiJqy4hBQJol4LCWo5GIb87bNIeT6OapF1iWK8kM8igyaNIeT6OapF1iWK8kM8i8ofOJwbrpvoG3nu8Pz83EzgWW9AJuV8icrN1RjpQxl71gPEb8rco6i4EzE(QrGj51RL96hTEfRx56vRG0fnQxtEuVGSxBuTEfRxb0lWeNRxLZJi1OE1PrOE1EDIzoQxtEuV(kaqGqZ4V)2RYnjpqGNVAeysEftEYb9tpygNIeT6O)N(ip88vJatYRyYJ(N(Euy4)4uxK8yYJAg)Tx8vo15W6FV88WriR3jkF9Qvq6Ig1RjpQx9G7fyjI61gPErKtnbh1RjpQx56fNIeT6OGjpQyzHNVAeysEHE)rNt8I61gPEreW6nN9AJuVC1XJo1K8a)7DWOWh7Du99PRxhba9or0phPZCy1RL9c8jcU3OFV2i1lqErNAsE)71gfqVJQVpDGEZ5078MyoZQx9G7DWO4OE5kWKdAOz83F7v5MKhiWZxncmjVIjp5G(PhmJtrIwD0)iGk5CwGYH9m8)iGkdgfhv4kWKdQNH)F6J8yYJkww45RgbMK3FCQlsEWiofjA1rbE(QrGj5vm5rENjpcd)4ACod88vJatYlaNdUMXMrLBsEGak9l(JkG8mD6Jags8I(ltpk3eCuHo6jeaVEWPirRokmMwbyis9QmD6Jags8I(IXACodJPvagIuVcrFgyOgNZWuqeWs0le9XqZOYnjpqaL(f)rfqF6bZtbrv15(ltp14CgGj1gRj6Oq0)lkE0mrqPamP2iOmvBmFFXPirRokyYJkww45RgbMKh(RX5matQnwt0rbe9u5aFvUj4OcD0tiaE9m0MrLBsEGak9l(JkG(0dM9XcLvNcS)Y0tnoNbq8kEjhuqP6iaqoOfePWyfI(FRX5maIxXl5GckvhbaYbTGifgRaIEQCa8YvGvm5rnJk3K8abu6x8hva9Phm7JfkRofy)LPNACodtbralrVq0Vzu5MKhiGs)I)OcOp9GzFSqz1Pa7Vm9uJZzymTcWqK6vi63m(BV)ia1BEuV4RGOEXMtbwVKICy1RC9IjN)uVYSxSYyVW5HDR3rfh1lj2iH6ftIutoO9(J87nr9IjLwVqmePE1lwK1REW9sInsiVVxmQyO3rfh17lruV2OE9AdYEvhIuyS(3lgRyO3rfh1lZWrFamKcgYPyh0l(gry1lIuyS61YEJa6FVjQxmYXqVqifjh0EXtg5J9kGEvUj4OqVmR8WU1lC2RnkGEhmkoQ3rfb3lxbMCq7fFD6Jags8Ia9MOEhmsxVqIxVy6Kdk2b9InhbaYbTxb0lIuyScnJk3K8abu6x8hva9PhmpfevQofy)JaQKZzbkh2ZW)JaQmyuCuHRatoOEg(Vm9WuCks0QJctbrLQtbwXptNCq)wJZzaeVIxYbfuQocaKdAbrkmwb4CW9v5MGJk0rpHa4hNIeT6OWOIGlCfyLPtFeWqIx0xMofebmfzekOCtWrFXitRX5mmsQjh0s0pe9)Y0ACodJPvagIuVcr)Vm1hr4k5CwGYHdtbrLQtb2xmQCtYlmfevQofyb(OIGsa86zOmWagn1rNfuh9bWqkyiNckZicRV8mDW5GlaJuO5bkveP2yarkmwyGbgaKIKdAXYiFmOCtWryadnJ)27pcq9IVcI6fBofy9sInsOEHJi5G2R2l(kiQQohM)jSqz1PaRxUcSEhmsxVysKAYbT3FKFVcOxLBcoQ3e1lCejh0EPpiE0OEhi2yVqifjh0EXtg5JHMrLBsEGak9l(JkG(0dMNcIkvNcS)ravY5SaLd7z4)ravgmkoQWvGjhupd)xMEykofjA1rHPGOs1PaR4NPtoOFz6uqeWuKrOGYnbh9fJyeJk3K8ctbrv15c0hepAYb9lgvUj5fMcIQQZfOpiE0OcIEQCa8JpHHGbgykkE0mrqPWuqeWs0ddmWGYnjVGpwOS6uGfOpiE0Kd6xmQCtYl4JfkRofyb6dIhnQGONkha)4tyiyGbMIIhnteukmfebSe9Wag(wJZzyKutoOLOFi6JbgyaJasrYbTyzKpguUj4OVySgNZWiPMCqlr)q0)ltvUj5fa8eXhd0hepAYbLbgyAnoNHX0kadrQxHO)xMwJZzyKutoOLOFi6)v5MKxaWteFmqFq8Ojh0VmDmTcWqK6vb4tohOixz6eOJggWagAgvUj5bcO0V4pQa6tpyMRoxr5MKxXja7)PpYJYnbhvm1rNbAgvUj5bcO0V4pQa6tpy2hluwDkW(ltp14Cg8XcLCNcEHO)xUcSIjpc)14Cg8XcLCNcEbe9u5aF5kWkM8i8xJZzafpQKZIFoGqbe9u5anJk3K8abu6x8hva9Phm7JfkRofy)LPNACodJPvagIuVcr)VasrYbTyzKpguUj4OVk3eCuHo6jea)4uKOvhfgtRamePEvMo9radjErnJk3K8abu6x8hva9Phm7pM0jFuMo9rG)Y0dtXPirRok4pM0jFu8Z0jh0V14Cggj1KdAj6hI(FzAnoNHX0kadrQxHO)xmQCtWrf40cc0tmc)dLbguUj4OcD0tiaE9GtrIwDuyurWfUcSY0PpcyiXlIbguUj4OcD0tiaE9GtrIwDuymTcWqK6vz60hbmK4fHHMrLBsEGak9l(JkG(0dMb8eXh)ltpasrYbTyzKpguUj4OMrLBsEGak9l(JkG(0dMHrk08aLkIuB8Vm9OCtWrf6ONqa8o0MrLBsEGak9l(JkG(0dMvexpQqF47sGK3Fz6r5MGJk0rpHa41dofjA1rbfX1Jk0h(Uei599PNg85gE9GtrIwDuqrC9Oc9HVlbsELNE6xtrqjlmqSr5ggFAg)TxmfXg7LUmcDSxtrqjd8VxX6va9Q9cvLRxl7LRaRx81PpcyiXlQxf07uCoc1RCaJu4EZzV4RGOQ6CHMrLBsEGak9l(JkG(0dMNo9radjEr)LPhLBcoQqh9ecGxp4uKOvhfgveCHRaRmD6Jags8IAgvUj5bcO0V4pQa6tpyEkiQQoxZyZOYnjpqay6bRi4ckn1K88mD6Jags8I(ltpk3eCuHo6jeaVEWPirRokmMwbyis9QmD6Jags8I(IXACodJPvagIuVcrFgyOgNZWuqeWs0le9XqZOYnjpqay6bRi4ckn1K8(0dMNcIQQZ9xMEQX5matQnwt0rHO)xu8OzIGsbysTrqzQ2y((ItrIwDuWKhvSSWZxncmjp8xJZzaMuBSMOJci6PYbWRNH2mQCtYdeaMEWkcUGstnjVp9GzFSqz1Pa7Vm9uJZzykicyj6fI(nJk3K8abGPhSIGlO0utY7tpy2hluwDkW(ltp14CggtRamePEfI(FRX5mmMwbyis9kGONkha)k3K8ctbrv15c0hepAuXKh1mQCtYdeaMEWkcUGstnjVp9GzFSqz1Pa7Vm9uJZzymTcWqK6vi6)fJ(icxbkhomCykiQQohdmmfebmfzekOCtWrmWGYnjVGpwOS6uGfKRmDc0rddnJ)2lEqy1RL9cLSEHGPdB96JsoOx5acm1lMC(t96pQac0BI6L55RgbMKxV(JkGa9oyKUE9taqQok0mQCtYdeaMEWkcUGstnjVp9GzFSqz1Pa7Vm9uJZzaeVIxYbfuQocaKdAbrkmwHO)xmYZ0bNdUakEujNf)CaHci6PYb(u5MKxafpQKZIFoGqb6dIhnQyYJ(KRaRyYJWBnoNbq8kEjhuqP6iaqoOfePWyfq0tLdWadm1uhDwafpQKZIFoGqy4lofjA1rbtEuXYcpF1iWK8(KRaRyYJWBnoNbq8kEjhuqP6iaqoOfePWyfq0tLd0mQCtYdeaMEWkcUGstnjVp9GzFSqz1Pa7Vm9uJZzymTcWqK6vi6)fqksoOflJ8XGYnbh1mQCtYdeaMEWkcUGstnjVp9GzFSqz1Pa7Vm9uJZzWhluYDk4fI(F5kWkM8i8xJZzWhluYDk4fq0tLd0m(BVmRisoO9AJuVatpyfb3lkn1K8(3BEoS6ncOEXxbr9InNcmqVdgPRxBKWQxfr9EP1BLKdAV(z6i4ENjQxm58N6nr9Y88vJatYl07pcq9IVcI6fBofy9sInsOEHJi5G2R2l(kiQQohM)jSqz1PaRxUcSEhmsxVysKAYbT3FKFVcOxLBcoQ3e1lCejh0EPpiE0OEhi2yVqifjh0EXtg5JHMrLBsEGaW0dwrWfuAQj59PhmpfevQofy)JaQKZzbkh2ZW)JaQmyuCuHRatoOEg(Vm9W0PGiGPiJqbLBco6ltXPirRokmfevQofyf)mDYb9lgXigvUj5fMcIQQZfOpiE0Kd6xmQCtYlmfevvNlqFq8Orfe9u5a4hFcdbdmWuu8OzIGsHPGiGLOhgyGbLBsEbFSqz1PalqFq8Ojh0Vyu5MKxWhluwDkWc0hepAubrpvoa(XNWqWadmffpAMiOuykicyj6Hbm8TgNZWiPMCqlr)q0hdmWagbKIKdAXYiFmOCtWrFXynoNHrsn5GwI(HO)xMQCtYla4jIpgOpiE0KdkdmW0ACodJPvagIuVcr)VmTgNZWiPMCqlr)q0)RYnjVaGNi(yG(G4rtoOFz6yAfGHi1RcWNCoqrUY0jqhnmGbm0mQCtYdeaMEWkcUGstnjVp9GzFSqz1Pa7Vm9uJZzymTcWqK6vi6)v5MGJk0rpHa4hNIeT6OWyAfGHi1RY0PpcyiXlQzu5MKhiam9GveCbLMAsEF6bZ(JjDYhLPtFe4Vm9WuCks0QJc(JjDYhf)mDYb9lgzQPo6SWeLVInsffmsagyq5MGJk0rpHa4Dym8fJk3eCuboTGa9eJW)qzGbLBcoQqh9ecGxp4uKOvhfgveCHRaRmD6Jags8IyGbLBcoQqh9ecGxp4uKOvhfgtRamePEvMo9radjEryOzu5MKhiam9GveCbLMAsEF6bZC15kk3K8koby)p9rEuUj4OIPo6mqZOYnjpqay6bRi4ckn1K8(0dMHrk08aLkIuB8Vm9OCtWrf6ONqa8oCZOYnjpqay6bRi4ckn1K8(0dMb8eXh)ltpasrYbTyzKpguUj4OMrLBsEGaW0dwrWfuAQj59PhmRiUEuH(W3LajV)Y0JYnbhvOJEcbWRhCks0QJckIRhvOp8DjqY77tpn4Zn86bNIeT6OGI46rf6dFxcK8kp90VMIGswyGyJYnm(0m(BVykIn2lDze6yVMIGsg4FVI1Ra6v7fQkxVw2lxbwV4RtFeWqIxuVkO3P4CeQx5agPW9MZEXxbrv15cnJk3K8abGPhSIGlO0utY7tpyE60hbmK4f9xMEuUj4OcD0tiaE9GtrIwDuyurWfUcSY0PpcyiXlQzu5MKhiam9GveCbLMAsEF6bZtbrv15yHa8joltWuz2SgRXYc]] )
end
