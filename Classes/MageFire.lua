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


    spec:RegisterPack( "Fire", 20210818, [[deLHYdqiuuEKQkDjfePnPQ0NGs1OGcDkOGvPQc1Ruv0Suv1TOkv2LGFbf1Wqb5ykOwMcspdfQmnOiX1uqyBOqrFJQuuJdfk5CkiI1rvQAEOa3JQyFqv6FkiQ6GqrQfcLYdrr1erHQUikuQnIcQpsvkYiHIiNKQuyLOiVefkyMQQGBQGOStui)ekcgQQkYsHIOEkinvOkUQQkKTcfH(kuK0yPkL2lk9xjgSshM0IL0Jr1Kb1Lr2SI(migTcDAIvJcf61uLmBQCBvz3Q8BrdNQ64QQOwoKNdmDkxxOTdv(UcmEvfopuY6vquz(qvTFPMDyw8WcfwnILrdLHg6WmeJ1WmwHHYqykmUHhkludlFIfQVY9sHqSqp9rSqzybrSq9vSCPcZIhwOGmI4el0rZ8bEpMXmeXgJ1apFygiVOtnjposNgMbYJJzwO1O4mVXXwzHcRgXYOHYqdDygIXAygRWqzimfghdnKWcvJ2yIyHcvEmNf6OadthBLfkmb4Sqzybr9oKPqOMPrZ8bEpMXmeXgJ1apFygiVOtnjposNgMbYJJ5MjmDesey9omJ1)Ehkdn0HBMAMy(OEqiG33m5D9(JauVtbYOvq0tLd0lsTrc1RnQxVMIGqwWKhvSSaluVZe1RtbM3biEEW9QvXjgw9gbkeceAM8UE)Hmb01lxbwVi6NJcIE0zGENjQxMNVAeysE9IrjqH)9cNh2TEhthCVI17mr9Q9oreyS3HmYOe1lxbggcntExVm2NwDuVadjCRx(iX9soi9MxVAVtAqVZe5fOx561gPEX0)0p0RL9Ii4iN6DqI8YLkCOzY76ftdZymcSE1E)jSqz1PaRx6mew9AJQ1lCsGEV069LWKR3bKZ1RCEhe9r9IrG861iGrW9QwVx2lqGCYu46z9Y4)jO9kpFLByi0m5D9Y88WriRx156TgNZG3gqKYTEPZqcb61YERX5m4THO))E1Rx19sG1RCabYjtHRN1lJ)NG2levUELRxG8aHMjVR3FeG6DurW8eMG7fNIeT6iqVw2lIGJCQxM)t)OEhKiVCPchyH6eGbyXdluu6x8hvaXIhwgnmlEyHsNwDeml2yHQCtYJf60PpcyiXlIfkmb4iX3K8yHYWYPohw)7LNhocz9or5RxTcsx0OEn5r9QhCValruV2i1lICQj4OEn5r9kxV4uKOvhfm5rfll88vJatYl07p6CIxuV2i1lIawV5SxBK6LRoE0PMKh4FVdgf(yVJQVpD96iaO3jI(5iDMdRETSxGprW9g971gPEbYl6utY7FV2Oa6Du99Pd0BoNEN3eZz89QhCVdgfh1lxbMCqcSq5iXiKOSqvUj4OcD0tiqV41tV4uKOvhfgtRamePEvMo9radjEr9(Txm2BnoNHX0kadrQxHOFV4JFV14CgMcIawIEHOFVyG1yz0qzXdlu60QJGzXgluosmcjkl0ACodWKAJ1eDui6373ErXJMjccfGj1gbLPAJ5lqNwDeCVF7fNIeT6OGjpQyzHNVAeysE9YGERX5matQnwt0rbe9u5a9(TxLBcoQqh9ec0lE907qzHQCtYJf6uquvDowJLrmow8WcLoT6iywSXcLJeJqIYcTgNZaiEfVKdcOuDeaihKcIuyScr)E)2BnoNbq8kEjheqP6iaqoifePWyfq0tLd0lE7LRaRyYJyHQCtYJfQpwOS6uGXASmctHfpSqPtRocMfBSq5iXiKOSqRX5mmfebSe9crFwOk3K8yH6JfkRofySglJgcw8WcLoT6iywSXcLJeJqIYcTgNZWyAfGHi1Rq0NfQYnjpwO(yHYQtbgRXYigtw8WcLoT6iywSXcncOYGrXrfUcm5GWYOHzHYrIrirzHYSEXPirRokmfevQofyf)mDYbP3V9wJZzaeVIxYbbuQocaKdsbrkmwb4CW173EvUj4OcD0tiqVmOxCks0QJcJkcUWvGvMo9radjEr9(TxM17uqeWuKrOGYnbh173EXyVmR3ACodJKAYbPe9dr)E)2lZ6TgNZWyAfGHi1Rq0V3V9YSE9reUsoNfiC4WuquP6uG173EXyVk3K8ctbrLQtbwGpQiieOx86P3H2l(43lg71uhDwqD0hadPGHCkOmJiSc0Pvhb373E5z6GZbxagPqYduQisTXaIuyS6fd9Ip(9cifjhKILr(yq5MGJ6fd9IbwOravY5SaHdZYOHzHQCtYJf6uquP6uGXcfMaCK4BsESq)raQ38OEzybr9InNcSEjf5WQx56fto)PELzVyLXEHZd7wVJkoQxsSrc1lMePMCq69h53BI6ftkTEHAis9QxSiRx9G7LeBKqEFVyuXqVJkoQ3xIOETr961gK9QoePWy9VxmwXqVJkoQxmTJ(ayifmKtXoOxgoIWQxePWy1RL9gb0)EtuVyKJHEHsksoi9INmYh7va9QCtWrHEz85HDRx4SxBua9oyuCuVJkcUxUcm5G0ld70hbmK4fb6nr9oyKUEHgVEzmiheSd6fBocaKdsVcOxePWyfynwg5nZIhwO0PvhbZInwOravgmkoQWvGjhewgnmluosmcjkluM1lofjA1rHPGOs1PaR4NPtoi9(TxM17uqeWuKrOGYnbh173EXyVySxm2RYnjVWuquvDUa9bXJMCq69BVySxLBsEHPGOQ6Cb6dIhnQGONkhOxg0ldfgIEXh)EzwVO4rZebHctbralrVaDA1rW9IHEXh)EvUj5f8XcLvNcSa9bXJMCq69BVySxLBsEbFSqz1PalqFq8Orfe9u5a9YGEzOWq0l(43lZ6ffpAMiiuykicyj6fOtRocUxm0lg69BV14Cggj1Kdsj6hI(9IHEXh)EXyVasrYbPyzKpguUj4OE)2lg7TgNZWiPMCqkr)q0V3V9YSEvUj5fa8eXhd0hepAYbPx8XVxM1BnoNHX0kadrQxHOFVF7Lz9wJZzyKutoiLOFi6373EvUj5fa8eXhd0hepAYbP3V9YSEhtRamePEva(KZbkYvMobYO1lg6fd9IbwOravY5SaHdZYOHzHQCtYJf6uquP6uGXcfMaCK4BsESq)raQxgwquVyZPaRxsSrc1lCejhKE1Ezybrv15W8pHfkRofy9YvG17Gr66ftIutoi9(J87va9QCtWr9MOEHJi5G0l9bXJg17aXg7fkPi5G0lEYiFmWASmIXIfpSqPtRocMfBSqvUj5XcLRoxr5MKxXjaJfQtaw50hXcv5MGJkM6OZaSglJgsyXdlu60QJGzXgluosmcjkl0ACod(yHsUtbVq0V3V9YvGvm5r9YGERX5m4Jfk5of8ci6PYb69BVCfyftEuVmO3ACodO4rLCw8ZbekGONkhGfQYnjpwO(yHYQtbgRXYOHziw8WcLoT6iywSXcLJeJqIYcTgNZWyAfGHi1Rq0V3V9cifjhKILr(yq5MGJ69BVk3eCuHo6jeOxg0lofjA1rHX0kadrQxLPtFeWqIxeluLBsESq9XcLvNcmwJLrdpmlEyHsNwDeml2yHYrIrirzHYSEXPirRok4pM0jFu8Z0jhKE)2BnoNHrsn5GuI(HOFVF7Lz9wJZzymTcWqK6vi6373EXyVk3eCuboTGa5eJ6Lb9o0EXh)EvUj4OcD0tiqV41tV4uKOvhfgveCHRaRmD6Jags8I6fF87v5MGJk0rpHa9Ixp9ItrIwDuymTcWqK6vz60hbmK4f1lgyHQCtYJfQ)ysN8rz60hbynwgn8qzXdlu60QJGzXgluosmcjkluaPi5GuSmYhdk3eCeluLBsESqb8eXhznwgnmJJfpSqPtRocMfBSq5iXiKOSqvUj4OcD0tiqV4T3HYcv5MKhluyKcjpqPIi1gznwgnmMclEyHsNwDeml2yHYrIrirzHQCtWrf6ONqGEXRNEXPirRokOiUEuH(W3LajVE)27tpn4ZTEXRNEXPirRokOiUEuH(W3LajVYtpT3V9AkcczHbInk3WmeluLBsESqvexpQqF47sGKhRXYOHhcw8WcLoT6iywSXcv5MKhl0PtFeWqIxeluycWrIVj5XcftvSXEPlJqg71ueeYa)7vSEfqVAVqu561YE5kW6LHD6Jags8I6vb9ofNJq9khWifU3C2ldliQQoxGfkhjgHeLfQYnbhvOJEcb6fVE6fNIeT6OWOIGlCfyLPtFeWqIxeRXYOHzmzXdluLBsESqNcIQQZXcLoT6iywSXASgluyAQrNXIhwgnmlEyHsNwDeml2yHYrIrirzHYSErXJMjccfGfax8DYPiSk8890doqNwDemluLBsESq5z8mcb8jNJ1yz0qzXdlu60QJGzXgluLBsESqbJY0KdsXphqiwOWeGJeFtYJfkMOIeT6OETr16LaM8uJa9oyKSrc1l0rzAYbP3FkhqOEhioxVvQ3iGG7TsZer9Y88vJatYRxb0lIuyScSq5iXiKOSqRX5mWZxncmjVaCo469BVk3K8ctbrLQtbwGpQiieOxg4P3H79BVmRxm2BnoNb5Me6uxHRaUctHOFVF7TgNZWyAfGHi1RaIuU1lg69BV4uKOvhfaJY0KdsXphqOsLMjIk88vJatYJ1yzeJJfpSqPtRocMfBSq5iXiKOSqRX5mWZxncmjVaCo469BVySxCks0QJcM8OILfE(QrGj51ld6fNIeT6OapF1iWK8k(iIRaRyYJ69ZEPpiE0OIjpQx8XVxCks0QJcM8OILfE(QrGj51lE7v5MKxHNPdohC96D9omd1lgyHQCtYJfksHf9ScWxrEXASmctHfpSqPtRocMfBSq5iXiKOSqRX5mWZxncmjVaCo469BV14CgqXJk5S4NdiuaohC9(TxCks0QJcM8OILfE(QrGj51ld6fNIeT6OapF1iWK8k(iIRaRyYJ69ZEPpiE0OIjpQ3p7fJ9wJZzaMuBSMOJcWrKAsE96D9wJZzGNVAeysEb4isnjVEXqV)4ErXJMjccfGj1gbLPAJ5lqNwDemluLBsESqHj1gRj6iwJLrdblEyHsNwDeml2yHYrIrirzHItrIwDuWKhvSSWZxncmjVEzqV4uKOvhf45RgbMKxXhrCfyftEuVF2l9bXJgvm5r9(T3ACod88vJatYlaNdowOk3K8yH(eekrGsolwIE0zSglJymzXdlu60QJGzXgl0iGkdgfhv4kWKdclJgMfkmb4iX3K8yHYWjQxmr6SrSq)7ncOE1Ezybr9InNcSE5Jkcc1lCejhKEhYeekrGEZzV4jrp6SE5kW61YEvCPa3lx99LdsV8rfbHabwOk3K8yHofevQofySq5iXiKOSqvUj5fEccLiqjNflrp6Sa9bXJMCq69BVZOZvqeFurqOIjpQxVRxLBsEHNGqjcuYzXs0JolqFq8Orfe9u5a9YGEXu69BVmR3X0kadrQxfGp5CGICLPtGmA9(TxM1BnoNHX0kadrQxHOpRXYiVzw8WcLoT6iywSXcv5MKhluiofwulrGsvHHqSq5iXiKOSqXPirRokyYJkww45RgbMKxV4TxLBsEfEMo4CW1R317qWcLMtIBLtFeluiofwulrGsvHHqSglJySyXdlu60QJGzXgluLBsESqPNpwisDLebF6XjwOCKyesuwO4uKOvhfm5rfll88vJatYRxg4PxCks0QJc0ZhlePUsIGp94ubMCkw9(TxCks0QJcM8OILfE(QrGj51lE7fNIeT6Oa98XcrQRKi4tpovGjNIvVExVdbl0tFelu65JfIuxjrWNECI1yz0qclEyHsNwDeml2yHQCtYJfkyuHZbeCjr1solwIE0zSq5iXiKOSqXyV4uKOvhfm5rfll88vJatYRxg4PxCks0QJc88vJatYR4JiUcSIjpQ3p7DO9Ip(9ofiJwbrpvoqVmOxCks0QJcM8OILfE(QrGj51lg69BV14Cg45RgbMKxaohCSqp9rSqbJkCoGGljQwYzXs0JoJ1yz0WmelEyHsNwDeml2yHQCtYJfkehw(JLCwuaqEItnjpwOCKyesuwO4uKOvhfm5rfll88vJatYRx86PxCks0QJc5vIaQWJwoNSqp9rSqH4WYFSKZIcaYtCQj5XASmA4HzXdlu60QJGzXgluLBsESqFkxRiQagjYkViq4Sq5iXiKOSqXPirRokyYJkww45RgbMKxVmWtVdbl0tFel0NY1kIkGrISYlceoRXYOHhklEyHsNwDeml2yHctaos8njpwOEJzVrGCq6v7fyekf4EZZ7IaQxXO3)Ev3aflqVra1lJhrk8uquVyIeaqUEZObeyQ3C2lZZxncmjVqVyc2iHgia6FV(ijrIjd5OEJa5G0lJhrk8uquVyIeaqUEhi2yVmpF1iWK86nphw9kZE9g3KqN66L5kGRWuVcOx60QJG7vp4E1EJafc17G8WU1BL61LaR3ehH61gPEHJi1K86nN9AJuVtbYOf6fpJcOxfgg0R2l4PoxV4uxK61YETrQxEMo4CW1Bo7LXJifEkiQxmrcaixVdgPRx4uoi9AJcOxU64rNAsE9wjUgbuVI1Ra6nEisDat49AzVkaeFuV2OA9kwVdeNR3k1BeqW96tOjXnhw9MxV8mDW5GlWc90hXcfgrk8uqubhbaKJfkhjgHeLfkofjA1rbtEuXYcpF1iWK86fVE6fNIeT6OqELiGk8OLZzVF7fJ9wJZzqUjHo1v4kGRWuayk3RE90BnoNb5Me6uxHRaUctHN(rbyk3REXh)EzwV88GJIfKBsOtDfUc4kmfOtRocUx8XVxCks0QJc88vJatYRKxjcOEXh)EXPirRokyYJkww45RgbMKxV4Tx5mc5No1i4YuGmAfe9u5a9oK2BVySxLBsEfEMo4CW17N9omd1lg6fdSqvUj5Xcfgrk8uqubhbaKJ1yz0Wmow8WcLoT6iywSXcv5MKhluqgDfbYjgHyHYrIrirzHIXEXPirRokyYJkww45RgbMKxV41tVmogQ3FCVySxCks0QJc5vIaQWJwoN9I3EzOEXqV4JFVySxM1RHKZlYc2Wbbeaz0veiNyeQ3V9Ai58ISGnCic0QJ69BVgsoVilydh4z6GZbxarpvoqV4JFVmRxdjNxKfSHgeqaKrxrGCIrOE)2RHKZlYc2qdrGwDuVF71qY5fzbBObEMo4CWfq0tLd0lg6fd9(Txm2lZ6L(5O47tWbyePWtbrfCeaqUEXh)E5z6GZbxagrk8uqubhbaKlGONkhOx827q0lgyHE6JyHcYORiqoXieRXYOHXuyXdlu60QJGzXgluLBsESq56XjxPgNtwOCKyesuwOmRxEEWrXcYnj0PUcxbCfMc0Pvhb373En5r9YGEhIEXh)ERX5mi3KqN6kCfWvykamL7vVE6TgNZGCtcDQRWvaxHPWt)OamL7fl0AColN(iwOGm6kcKtmjpwOWeGJeFtYJfkEqceieQxOz01R3aYjgH6LuKdREhi2yVEJBsOtD9YCfWvyQ3e17Gr66vSEhOGE9rexbwG1yz0WdblEyHsNwDeml2yHctaos8njpwOEdJEGETr16fo79sR3kD0uSEzE(QrGj51lymJo4EzmgbwVvQ3iGG7nJgqGPEZzVmpF1iWK86vTEb5J61pLZcSqp9rSqLdWrrtRoQ8Zr9S4Rat4eoXcLJeJqIYcL(5O47tWbiofwulrGsvHHq9(TxCks0QJcM8OILfE(QrGj51lE90lofjA1rH8krav4rlNtwOk3K8yHkhGJIMwDu5NJ6zXxbMWjCI1yz0WmMS4HfkDA1rWSyJfQYnjpwOtN(Osolv1mhXcLJeJqIYcL(5O47tWbiofwulrGsvHHq9(TxCks0QJcM8OILfE(QrGj51lE90lofjA1rH8krav4rlNtwON(iwOtN(Osolv1mhXASmAyVzw8WcLoT6iywSXcv5MKhl0bQx0riqzIYdMfkhjgHeLfk9ZrX3NGdqCkSOwIaLQcdH69BV4uKOvhfm5rfll88vJatYRx86PxCks0QJc5vIaQWJwoNSqp9rSqhOErhHaLjkpywJLrdZyXIhwO0PvhbZInwOk3K8yHkhWqrULiqbwWjhvQKZXcLJeJqIYcL(5O47tWbiofwulrGsvHHq9(TxCks0QJcM8OILfE(QrGj51lE90lofjA1rH8krav4rlNtwON(iwOYbmuKBjcuGfCYrLk5CSglJgEiHfpSqPtRocMfBSqvUj5XcfeVQlt4I(iBelGXcLJeJqIYcL(5O47tWbiofwulrGsvHHq9(TxCks0QJcM8OILfE(QrGj51lE90lofjA1rH8krav4rlNtwON(iwOG4vDzcx0hzJybmwJLrdLHyXdlu60QJGzXgluosmcjkluCks0QJcM8OILfE(QrGj51lE90lofjA1rH8krav4rlNtwOk3K8yHgburm6bynwgn0HzXdlu60QJGzXgluLBsESqNOeyLlXPSqHjahj(MKhl0FeG6LHrjW6LrjoTxl71qceieQxVjKaCy1R3GlChfyHYrIrirzHIIhnteekabjahwfHlChfOtRocU3V9wJZzGNVAeysEb4CW173EXyV4uKOvhfm5rfll88vJatYRx82RYnjVcpthCo46fF87fNIeT6OGjpQyzHNVAeysE9YGEXPirRokWZxncmjVIpI4kWkM8OE)Sx6dIhnQyYJ6fdSglJg6qzXdlu60QJGzXgluLBsESq5z8mcb8jNJfkmb4iX3K8yH6nrwV2i1lJxaCX3jNIWQxMNVNEW9wJZzVr))9gphba9YZxncmjVEfqVGmValuosmcjkluu8OzIGqbybWfFNCkcRcpFp9Gd0Pvhb373E5z6GZbxOgNZcSa4IVtofHvHNVNEWbePWy173ERX5malaU47Ktryv457PhCrrC9OaCo469BVmR3ACodWcGl(o5uewfE(E6bhI(9(Txm2lofjA1rbtEuXYcpF1iWK869ZEvUj5fMOey10zbUcSIjpQx82lpthCo4c14CwGfax8DYPiSk8890doahrQj51l(43lofjA1rbtEuXYcpF1iWK86Lb9oe9IbwJLrdLXXIhwO0PvhbZInwOCKyesuwOO4rZebHcWcGl(o5uewfE(E6bhOtRocU3V9YZ0bNdUqnoNfybWfFNCkcRcpFp9GdisHXQ3V9wJZzawaCX3jNIWQWZ3tp4II46rb4CW173EzwV14CgGfax8DYPiSk8890doe979BVySxCks0QJcM8OILfE(QrGj517N9sFq8OrftEuVF2RYnjVWeLaRMolWvGvm5r9I3E5z6GZbxOgNZcSa4IVtofHvHNVNEWb4isnjVEXh)EXPirRokyYJkww45RgbMKxVmO3HO3V9YSEn1rNfqXJk5S4NdiuGoT6i4EXaluLBsESqvexpQqF47sGKhRXYOHIPWIhwO0PvhbZInwOCKyesuwOO4rZebHcWcGl(o5uewfE(E6bhOtRocU3V9YZ0bNdUqnoNfybWfFNCkcRcpFp9Gdi6PYb6Lb9YvGvm5r9(T3ACodWcGl(o5uewfE(E6bxMOeyb4CW173EzwV14CgGfax8DYPiSk8890doe979BVySxCks0QJcM8OILfE(QrGj517N9YvGvm5r9I3E5z6GZbxOgNZcSa4IVtofHvHNVNEWb4isnjVEXh)EXPirRokyYJkww45RgbMKxVmO3HOxmWcv5MKhl0jkbwnDgRXYOHoeS4HfkDA1rWSyJfkhjgHeLfkkE0mrqOaSa4IVtofHvHNVNEWb60QJG79BV8mDW5GluJZzbwaCX3jNIWQWZ3tp4aIuyS69BV14CgGfax8DYPiSk8890dUmrjWcW5GR3V9YSERX5malaU47Ktryv457PhCi6373EXyV4uKOvhfm5rfll88vJatYRx82lpthCo4c14CwGfax8DYPiSk8890doahrQj51l(43lofjA1rbtEuXYcpF1iWK86Lb9oe9IbwOk3K8yHorjWkxItznwgnugtw8WcLoT6iywSXcLJeJqIYcfNIeT6OGjpQyzHNVAeysE9Yap9Yq9Ip(9ItrIwDuWKhvSSWZxncmjVEzqV4uKOvhf45RgbMKxXhrCfyftEuVF7LNPdohCbE(QrGj5fq0tLd0ld6fNIeT6OapF1iWK8k(iIRaRyYJyHQCtYJfkxDUIYnjVItagluNaSYPpIfkpF1iWK8k(JkGynwgnuVzw8WcLoT6iywSXcLJeJqIYcTgNZakEujNf)CaHcW5GR3V9YSERX5mmfebSe9cr)E)2lg7fNIeT6OGjpQyzHNVAeysE9Ixp9wJZzafpQKZIFoGqb4isnjVE)2lofjA1rbtEuXYcpF1iWK86fV9QCtYlmfevQofyHz05kiIpQiiuXKh1l(43lofjA1rbtEuXYcpF1iWK86fV9ofiJwbrpvoqVyGfQYnjpwOO4rLCw8ZbeI1yz0qzSyXdlu60QJGzXgluycWrIVj5XcftDKUEJa5G0ld70hbmK4f1RC9Y88vJatY7FVafh1Rc69Phw9Yhveec0Rc61pbaP6OENjQxMNVAeysE9oqSXmA9YvFF5GeyHQCtYJfkxDUIYnjVItagluGHeUXYOHzHYrIrirzHwJZzafpQKZIFoGqHOFVF7fNIeT6OGjpQyzHNVAeysE9I3EziwOobyLtFeluu6x8hvaXASmAOdjS4HfkDA1rWSyJfAeqLbJIJkCfyYbHLrdZcLJeJqIYcLz9ItrIwDuykiQuDkWk(z6KdsVF7fNIeT6OGjpQyzHNVAeysE9I3EzOE)2RYnbhvOJEcb6fVE6fNIeT6OWOIGlCfyLPtFeWqIxuVF7Lz9ofebmfzekOCtWr9(TxM1BnoNHX0kadrQxHOFVF7fJ9wJZzyKutoiLOFi6373EvUj5fMo9radjErb6dIhnQGONkhOxg0ldfgIEXh)E5JkccbktKYnjp11lE907q7fdSqJaQKZzbchMLrdZcv5MKhl0PGOs1PaJfkmb4iX3K8yHIPosxVyskcMRatoi9YWo9r9c1qIx0)Ezybr9InNcmqVGXm6G7Ts9gbeCVw2le6iKAuVysP1ludrQxGE1dUxl7L(WOdUxS5uGrOEhYuGrOaRXYighdXIhwO0PvhbZInwOravgmkoQWvGjhewgnmluosmcjkl0PGiGPiJqbLBcoQ3V9Yhveec0lE907W9(TxM1lofjA1rHPGOs1PaR4NPtoi9(Txm2lZ6v5MKxykiQQoxG(G4rtoi9(TxM1RYnjVGpwOS6uGfKRmDcKrR3V9wJZzyKutoiLOFi63l(43RYnjVWuquvDUa9bXJMCq69BVmR3ACodJPvagIuVcr)EXh)EvUj5f8XcLvNcSGCLPtGmA9(T3ACodJKAYbPe9dr)E)2lZ6TgNZWyAfGHi1Rq0VxmWcncOsoNfiCywgnmluLBsESqNcIkvNcmwOWeGJeFtYJfkJpIKdsVmSGiGPiJq)7LHfe1l2CkWa9QiQ3iGG7fipXPihw9AzVWrKCq6L55RgbMKxOxVj6iK6Cy9VxBKWQxfr9gbeCVw2le6iKAuVysP1ludrQxGEhmsxVCKyGEhioxVxA9wPEhOaJG7vp4Ehi2yVyZPaJq9oKPaJq)71gjS6fmMrhCVvQxGpIu4EZO1RL9(u5mvUETrQxS5uGrOEhYuGrOERX5mWASmIXnmlEyHsNwDeml2yHgbuzWO4OcxbMCqyz0WSqHjahj(MKhlumnUuG7LR((YbPxgwquVyZPaRx(OIGqGEhmkoQx(OEh5KdsVqhLPjhKE)PCaHyHQCtYJf6uquP6uGXcLJeJqIYcv5MKxamkttoif)CaHc0hepAYbP3V9oJoxbr8rfbHkM8OEzqVk3K8cGrzAYbP4NdiuWeUxfebh5MKxVF7TgNZWyAfGHi1RaCo469BVM8OEXBVdZqSglJyCdLfpSqPtRocMfBSq5iXiKOSqXPirRokyYJkww45RgbMKxV4TxgQ3V9wJZzafpQKZIFoGqb4CWXcv5MKhluU6CfLBsEfNamwOobyLtFeluGPhSIGlO0utYJ1yzeJJXXIhwOk3K8yHc4jIpYcLoT6iywSXASgluFeXZxvnw8WYOHzXdluLBsESqvexpQiNrohXnwO0PvhbZInwJLrdLfpSqPtRocMfBSqHjahj(MKhlumPCqVU8G0BLMjI6L55RgbMKxVGXm6G71qY5fzGETr161qceieQxTxWOIi4E5Qrqsew9YZ0bNdUEZR30gjuVgsoVid07LwVvQ3iGGhYZc90hXcfKrxrGCIriwOCKyesuwOmRxCks0QJc88vJatYRKxjcOE)2lZ6L(5O47tWbyePWtbrfCeaqUE)2lZ61uhDwykicykYiuGoT6iywOk3K8yHcYORiqoXieRXYighlEyHQCtYJf6tqOevKNcHyHsNwDeml2ynwgHPWIhwO0PvhbZInwOCKyesuwOmRxFeHl4JfkRofySqvUj5Xc1hluwDkWynwJfkpF1iWK8k(JkGyXdlJgMfpSqPtRocMfBSq5iXiKOSqRX5mWZxncmjVaCo4yHQCtYJfQtGmAGcJXimKhDgRXYOHYIhwO0PvhbZInwOk3K8yHwviLCwmKW9cWcfMaCK4BsESqX0WWGETrQx4isnjVEZzV2i1l041lJb5GGDqVyZraGCq6L55RgbMKxVw2Rns9shCV5SxBK6Lhri6SEzE(QrGj51Rm71gPE5kW6DqgDW9YZNVJmQx4isoi9AJcOxMNVAeysEbwOCKyesuwO14Cg45RgbMKxaohCSglJyCS4HfkDA1rWSyJfkhjgHeLfQYnbhvOJEcb6fV9oCVF7TgNZapF1iWK8cW5GJfQYnjpwOobNCqk18vznwgHPWIhwO0PvhbZInwOravgmkoQWvGjhewgnmluosmcjkluM1lpp4Oyb5Me6uxHRaUctb60QJG79BV8rfbHa9Ixp9oCVF7TgNZapF1iWK8cr)E)2lZ6TgNZWuqeWs0le979BVmR3ACodJPvagIuVcr)E)27yAfGHi1RcWNCoqrUY0jqgTE)S3ACodJKAYbPe9dr)EzqVdLfAeqLColq4WSmAywOk3K8yHofevQofySqHjahj(MKhlumvXgZO1R34Me6uxVmxbCfM(3lJXiW6ncOEzybr9InNcmqVdgPRxBKWQ3b5HDR3x84J9YrIb6vp4EhmsxVmSGiGLOxVcOx4CWfynwgneS4HfkDA1rWSyJfAeqLbJIJkCfyYbHLrdZcLJeJqIYcLNhCuSGCtcDQRWvaxHPE)2lFurqiqV41tVd373EXyV4uKOvhfOp8jUrWLPGOs1Pad0lE90lofjA1rHJiycUmfevQofyGEXh)EXPirRokqFy0btWfE(QrGj5vq0tLd0ld80BnoNb5Me6uxHRaUctb4isnjVEXh)ERX5mi3KqN6kCfWvykamL7vVmO3H2l(43BnoNb5Me6uxHRaUctbe9u5a9YGEHWHdp9JEXh)E5z6GZbxamkttoif)CaHcisHXQ3V9QCtWrf6ONqGEXRNEXPirRokWZxncmjVcyuMMCqk(5ac173E5jo60ZcNaz0ktL6fd9(T3ACod88vJatYle979BVySxM1BnoNHPGiGLOxi63l(43BnoNb5Me6uxHRaUctbe9u5a9YGEzOWq0lg69BVmR3ACodJPvagIuVcr)E)27yAfGHi1RcWNCoqrUY0jqgTE)S3ACodJKAYbPe9dr)EzqVdLfAeqLColq4WSmAywOk3K8yHofevQofySqHjahj(MKhlumvXg71BCtcDQRxMRaUct)7LHfe1l2CkW6ncOEbJz0b3BL6vHHftYtDoS6LNhWqQCeCVGSxBuTEfRxb07LwVvQ3iGG7nEoca61BCtcDQRxMRaUct9kGE1AgTETSx6dFbr9MOETrcr9QiQ3xIOETr96LUmczSxgwquVyZPad0RL9sFy0b3R34Me6uxVmxbCfM61YETrQx6G7nN9Y88vJatYlWASmIXKfpSqPtRocMfBSqvUj5XcLRoxr5MKxXjaJfQtaw50hXcv5MGJkM6OZaSglJ8MzXdlu60QJGzXgl0iGkdgfhv4kWKdclJgMfkhjgHeLfAnoNbE(QrGj5fGZbxVF7fNIeT6OGjpQyzHNVAeysE9Yap9Yq9(Txm2lZ6ffpAMiiuawaCX3jNIWQWZ3tp4aDA1rW9Ip(9wJZzawaCX3jNIWQWZ3tp4q0Vx8XV3ACodWcGl(o5uewfE(E6bxMOeyHOFVF71uhDwafpQKZIFoGqb60QJG79BV8mDW5GluJZzbwaCX3jNIWQWZ3tp4aIuyS6fd9(Txm2lZ6ffpAMiiuacsaoSkcx4okqNwDeCV4JFVWunoNbiib4WQiCH7Oq0Vxm073EXyVmRxEIJo9SWrCu6seCV4JFV8mDW5GlatQnwt0rbe9u5a9Ip(9wJZzaMuBSMOJcr)EXqVF7fJ9YSE5jo60Zc4OZgXc1l(43lpthCo4cpbHseOKZILOhDwarpvoqVyO3V9IXEvUj5fEKrjkixz6eiJwVF7v5MKx4rgLOGCLPtGmAfe9u5a9Yap9ItrIwDuGNVAeysEfUcScIEQCGEXh)EvUj5fa8eXhd0hepAYbP3V9QCtYla4jIpgOpiE0OcIEQCGEzqV4uKOvhf45RgbMKxHRaRGONkhOx8XVxLBsEHPGOQ6Cb6dIhn5G073EvUj5fMcIQQZfOpiE0OcIEQCGEzqV4uKOvhf45RgbMKxHRaRGONkhOx8XVxLBsEbFSqz1PalqFq8OjhKE)2RYnjVGpwOS6uGfOpiE0OcIEQCGEzqV4uKOvhf45RgbMKxHRaRGONkhOx8XVxLBsEHPtFeWqIxuG(G4rtoi9(TxLBsEHPtFeWqIxuG(G4rJki6PYb6Lb9ItrIwDuGNVAeysEfUcScIEQCGEXal0iGk5CwGWHzz0WSqvUj5XcLNVAeysESglJySyXdlu60QJGzXgluycWrIVj5XcftWgjuV8mDW5Gd0RnQwVGXm6G7Ts9gbeCVdeBSxMNVAeysE9cgZOdU38Cy1BL6nci4Ehi2yV61RYTO66L55RgbMKxVCfy9QhCVxA9oqSXE1EHgVEzmiheSd6fBocaKdsV(OKhyHQCtYJfkxDUIYnjVItagluosmcjkl0ACod88vJatYlGONkhOx82lJvV4JFV8mDW5GlWZxncmjVaIEQCGEzqVdbluNaSYPpIfkpF1iWK8k8mDW5GdWASmAiHfpSqPtRocMfBSq5iXiKOSqXyV14CggtRamePEfI(9(TxLBcoQqh9ec0lE90lofjA1rbE(QrGj5vMo9radjEr9IHEXh)EXyV14CgMcIawIEHOFVF7v5MGJk0rpHa9Ixp9ItrIwDuGNVAeysELPtFeWqIxuVExVO4rZebHctbralrVaDA1rW9IbwOk3K8yHoD6Jags8IynwgnmdXIhwO0PvhbZInwOCKyesuwO14CgaXR4LCqaLQJaa5GuqKcJvi6373ERX5maIxXl5GakvhbaYbPGifgRaIEQCGEXBVCfyftEeluLBsESq9XcLvNcmwJLrdpmlEyHsNwDeml2yHYrIrirzHwJZzykicyj6fI(SqvUj5Xc1hluwDkWynwgn8qzXdlu60QJGzXgluosmcjkl0ACod(yHsUtbVq0V3V9wJZzWhluYDk4fq0tLd0lE7LRaRyYJ69BVyS3ACod88vJatYlGONkhOx82lxbwXKh1l(43BnoNbE(QrGj5fGZbxVyO3V9QCtWrf6ONqGEzqV4uKOvhf45RgbMKxz60hbmK4fXcv5MKhluFSqz1PaJ1yz0Wmow8WcLoT6iywSXcLJeJqIYcTgNZWyAfGHi1Rq0V3V9wJZzGNVAeysEHOpluLBsESq9XcLvNcmwJLrdJPWIhwO0PvhbZInwOCKyesuwO(icxbchomCaWteFS3V9wJZzyKutoiLOFi6373EvUj4OcD0tiqVmOxCks0QJc88vJatYRmD6Jags8I69BV14Cg45RgbMKxi6Zcv5MKhluFSqz1PaJ1yz0WdblEyHsNwDeml2yHQCtYJfkyuMMCqk(5acXcvoJqOOVvKjluLBsEHPGOs1PalWhveec4r5MKxykiQuDkWcp9JcFurqialuosmcjkl0ACod88vJatYle979BVmRxLBsEHPGOs1PalWhveec073EvUj4OcD0tiqV41tV4uKOvhf45RgbMKxbmkttoif)CaH69BVk3K8c(JjDYhLPtFeimJoxbr8rfbHkM8OEXBVZOZvqeCKBsESqHjahj(MKhl0Feqoi9cDuMMCq69NYbeQx4isoi9Y88vJatYRxl7fralruVmSGOEXMtbwV6b37pnM0jF0ld70h1lFurqiqVC96Ts9wPJMcxu3)ERrR3iiQohw9MNdREZRxmDYyhynwgnmJjlEyHsNwDeml2yHYrIrirzHwJZzGNVAeysEHOFVF71qkoYvm5r9YGERX5mWZxncmjVaIEQCGE)2lg7fJ9QCtYlmfevQofyb(OIGqGEzqVd373En1rNf8XcLCNcEb60QJG79BVk3eCuHo6jeOxp9oCVyOx8XVxM1RPo6SGpwOK7uWlqNwDeCV4JFVk3eCuHo6jeOx827W9IHE)2BnoNHrsn5GuI(HOFVF27yAfGHi1RcWNCoqrUY0jqgTEzqVdLfQYnjpwO(JjDYhLPtFeG1yz0WEZS4HfkDA1rWSyJfkhjgHeLfAnoNbE(QrGj5fGZbxVF7LNPdohCbE(QrGj5fq0tLd0ld6LRaRyYJ69BVk3eCuHo6jeOx86PxCks0QJc88vJatYRmD6Jags8IyHQCtYJf60PpcyiXlI1yz0WmwS4HfkDA1rWSyJfkhjgHeLfAnoNbE(QrGj5fGZbxVF7LNPdohCbE(QrGj5fq0tLd0ld6LRaRyYJ69BVmRxEEWrXctN(OIY5iYK8c0PvhbZcv5MKhl0PGOQ6CSglJgEiHfpSqPtRocMfBSq5iXiKOSqRX5mWZxncmjVaIEQCGEXBVCfyftEuVF7TgNZapF1iWK8cr)EXh)ERX5mWZxncmjVaCo469BV8mDW5GlWZxncmjVaIEQCGEzqVCfyftEeluLBsESqb8eXhznwgnugIfpSqPtRocMfBSq5iXiKOSqRX5mWZxncmjVaIEQCGEzqVq4WHN(rVF7v5MGJk0rpHa9I3EhMfQYnjpwOobNCqk18vznwgn0HzXdlu60QJGzXgluosmcjkl0ACod88vJatYlGONkhOxg0leoC4PF073ERX5mWZxncmjVq0NfQYnjpwOWifsEGsfrQnYASgluLBcoQyQJodWIhwgnmlEyHsNwDeml2yHYrIrirzHQCtWrf6ONqGEXBVd373ERX5mWZxncmjVaCo469BVySxCks0QJcM8OILfE(QrGj51lE7LNPdohCbNGtoiLA(Qb4isnjVEXh)EXPirRokyYJkww45RgbMKxVmWtVmuVyGfQYnjpwOobNCqk18vznwgnuw8WcLoT6iywSXcLJeJqIYcfNIeT6OGjpQyzHNVAeysE9Yap9Yq9Ip(9IXE5z6GZbx4rgLOaCePMKxVmOxCks0QJcM8OILfE(QrGj5173EzwVM6OZcO4rLCw8ZbekqNwDeCVyOx8XVxtD0zbu8Osol(5acfOtRocU3V9wJZzafpQKZIFoGqHOFVF7fNIeT6OGjpQyzHNVAeysE9I3EvUj5fEKrjkWZ0bNdUEXh)ENcKrRGONkhOxg0lofjA1rbtEuXYcpF1iWK8yHQCtYJf6JmkrSglJyCS4HfkDA1rWSyJfkhjgHeLfQPo6SG6Opagsbd5uqzgryfOtRocU3V9IXERX5mWZxncmjVaCo469BVmR3ACodJPvagIuVcr)EXaluLBsESqHrkK8aLkIuBK1ynwOatpyfbxqPPMKhlEyz0WS4HfkDA1rWSyJfkhjgHeLfQYnbhvOJEcb6fVE6fNIeT6OWyAfGHi1RY0PpcyiXlQ3V9IXERX5mmMwbyis9ke97fF87TgNZWuqeWs0le97fdSqvUj5XcD60hbmK4fXASmAOS4HfkDA1rWSyJfkhjgHeLfAnoNbysTXAIoke979BVO4rZebHcWKAJGYuTX8fOtRocU3V9ItrIwDuWKhvSSWZxncmjVEzqV14CgGj1gRj6OaIEQCGE)2BnoNbysTXAIokGONkhOx86P3HYcv5MKhl0PGOQ6CSglJyCS4HfkDA1rWSyJfkhjgHeLfAnoNHPGiGLOxi6Zcv5MKhluFSqz1PaJ1yzeMclEyHsNwDeml2yHYrIrirzHwJZzymTcWqK6vi6373ERX5mmMwbyis9kGONkhOxg0RYnjVWuquvDUa9bXJgvm5rSqvUj5Xc1hluwDkWynwgneS4HfkDA1rWSyJfkhjgHeLfAnoNHX0kadrQxHOFVF7fJ96JiCfiC4WWHPGOQ6C9Ip(9ofebmfzekOCtWr9Ip(9QCtYl4JfkRofyb5ktNaz06fdSqvUj5Xc1hluwDkWynwgXyYIhwO0PvhbZInwOk3K8yH6JfkRofySqHjahj(MKhlu8GWQxl7fcz9cLXa261hLCqVYbeyQxm58N61FubeO3e1lZZxncmjVE9hvab6DWiD96NaGuDuGfkhjgHeLfAnoNbq8kEjheqP6iaqoifePWyfI(9(Txm2lpthCo4cO4rLCw8ZbekGONkhO3p7v5MKxafpQKZIFoGqb6dIhnQyYJ69ZE5kWkM8OEXBV14CgaXR4LCqaLQJaa5GuqKcJvarpvoqV4JFVmRxtD0zbu8Osol(5acfOtRocUxm073EXPirRokyYJkww45RgbMKxVF2lxbwXKh1lE7TgNZaiEfVKdcOuDeaihKcIuySci6PYbynwg5nZIhwO0PvhbZInwOCKyesuwO14CggtRamePEfI(9(TxaPi5GuSmYhdk3eCeluLBsESq9XcLvNcmwJLrmwS4HfkDA1rWSyJfkhjgHeLfAnoNbFSqj3PGxi6373E5kWkM8OEzqV14Cg8XcLCNcEbe9u5aSqvUj5Xc1hluwDkWynwgnKWIhwO0PvhbZInwOravgmkoQWvGjhewgnmluosmcjkluM17uqeWuKrOGYnbh173EzwV4uKOvhfMcIkvNcSIFMo5G073EXyVySxm2RYnjVWuquvDUa9bXJMCq69BVySxLBsEHPGOQ6Cb6dIhnQGONkhOxg0ldfgIEXh)EzwVO4rZebHctbralrVaDA1rW9IHEXh)EvUj5f8XcLvNcSa9bXJMCq69BVySxLBsEbFSqz1PalqFq8Orfe9u5a9YGEzOWq0l(43lZ6ffpAMiiuykicyj6fOtRocUxm0lg69BV14Cggj1Kdsj6hI(9IHEXh)EXyVasrYbPyzKpguUj4OE)2lg7TgNZWiPMCqkr)q0V3V9YSEvUj5fa8eXhd0hepAYbPx8XVxM1BnoNHX0kadrQxHOFVF7Lz9wJZzyKutoiLOFi6373EvUj5fa8eXhd0hepAYbP3V9YSEhtRamePEva(KZbkYvMobYO1lg6fd9IbwOravY5SaHdZYOHzHQCtYJf6uquP6uGXcfMaCK4BsESqz8rKCq61gPEbMEWkcUxuAQj59V38Cy1Beq9YWcI6fBofyGEhmsxV2iHvVkI69sR3kjhKE9Z0rW9otuVyY5p1BI6L55RgbMKxO3FeG6LHfe1l2CkW6LeBKq9chrYbPxTxgwquvDom)tyHYQtbwVCfy9oyKUEXKi1KdsV)i)EfqVk3eCuVjQx4isoi9sFq8Or9oqSXEHsksoi9INmYhdSglJgMHyXdlu60QJGzXgluosmcjkl0ACodJPvagIuVcr)E)2RYnbhvOJEcb6Lb9ItrIwDuymTcWqK6vz60hbmK4fXcv5MKhluFSqz1PaJ1yz0WdZIhwO0PvhbZInwOCKyesuwOmRxCks0QJc(JjDYhf)mDYbP3V9IXEzwVM6OZctu(k2ivuWibc0Pvhb3l(43RYnbhvOJEcb6fV9oCVyO3V9IXEvUj4OcCAbbYjg1ld6DO9Ip(9QCtWrf6ONqGEXRNEXPirRokmQi4cxbwz60hbmK4f1l(43RYnbhvOJEcb6fVE6fNIeT6OWyAfGHi1RY0PpcyiXlQxmWcv5MKhlu)XKo5JY0PpcWASmA4HYIhwO0PvhbZInwOk3K8yHYvNROCtYR4eGXc1jaRC6JyHQCtWrftD0zawJLrdZ4yXdlu60QJGzXgluosmcjkluLBcoQqh9ec0lE7DywOk3K8yHcJui5bkveP2iRXYOHXuyXdlu60QJGzXgluosmcjkluaPi5GuSmYhdk3eCeluLBsESqb8eXhznwgn8qWIhwO0PvhbZInwOCKyesuwOk3eCuHo6jeOx86PxCks0QJckIRhvOp8DjqYR3V9(0td(CRx86PxCks0QJckIRhvOp8DjqYR80t79BVMIGqwyGyJYnmdXcv5MKhlufX1Jk0h(Uei5XASmAygtw8WcLoT6iywSXcv5MKhl0PtFeWqIxeluycWrIVj5XcftvSXEPlJqg71ueeYa)7vSEfqVAVqu561YE5kW6LHD6Jags8I6vb9ofNJq9khWifU3C2ldliQQoxGfkhjgHeLfQYnbhvOJEcb6fVE6fNIeT6OWOIGlCfyLPtFeWqIxeRXYOH9MzXdluLBsESqNcIQQZXcLoT6iywSXASgluE(QrGj5v4z6GZbhGfpSmAyw8Wcv5MKhlu)0K8yHsNwDeml2ynwgnuw8Wcv5MKhl0Qlt4YmIWIfkDA1rWSyJ1yzeJJfpSqPtRocMfBSq5iXiKOSqRX5mWZxncmjVq0NfQYnjpwOvcbiKxYbH1yzeMclEyHQCtYJf6uqu1Ljmlu60QJGzXgRXYOHGfpSqvUj5XcvpobmK6kC15yHsNwDeml2ynwgXyYIhwO0PvhbZInwOCKyesuwOO4rZebHcg98tK6kduKFGoT6i4E)2BnoNb6JrncmjVq0NfQYnjpwOM8OYaf5ZASmYBMfpSqPtRocMfBSqvUj5XcfItHf1seOuvyieluAojUvo9rSqH4uyrTebkvfgcXASmIXIfpSqPtRocMfBSqp9rSqLdWrrtRoQ8Zr9S4Rat4eoXcv5MKhlu5aCu00QJk)Cupl(kWeoHtSglJgsyXdlu60QJGzXgl0tFel0PtFujNLQAMJyHQCtYJf60PpQKZsvnZrSglJgMHyXdlu60QJGzXgl0tFel0bQx0riqzIYdMfQYnjpwOduVOJqGYeLhmRXYOHhMfpSqPtRocMfBSqp9rSqLdyOi3seOal4KJkvY5yHQCtYJfQCadf5wIafybNCuPsohRXYOHhklEyHsNwDeml2yHE6JyHcIx1LjCrFKnIfWyHQCtYJfkiEvxMWf9r2iwaJ1yz0Wmow8Wcv5MKhl0iGkIrpalu60QJGzXgRXASgluCeci5XYOHYqdDygIXCOdjSqhOOtoiawOyQyAmzg5nyK3K33BV4zK6vE(jY6DMOEXok9l(JkGWEVi6NJcIG7fKpQxnA5tncUx(OEqiqOz6hKJ6DOEFVmppCeYi4EXokE0mrqOG3I9ETSxSJIhnteek4Tb60QJGXEVyC4pWqOz6hKJ6LX077L55HJqgb3l2n1rNf8wS3RL9IDtD0zbVnqNwDem27fJd)bgcnt)GCuVEZEFVmppCeYi4EXokE0mrqOG3I9ETSxSJIhnteek4Tb60QJGXEVyCOFGHqZuZeMkMgtMrEdg5n5992lEgPELNFISENjQxSdttn6mS3lI(5OGi4Eb5J6vJw(uJG7LpQheceAM(b5OEh277L55HJqgb3l2rXJMjccf8wS3RL9IDu8OzIGqbVnqNwDem27vTEzSXe(HEX4WFGHqZ0pih1lMI33lZZdhHmcUxSJIhnteek4TyVxl7f7O4rZebHcEBGoT6iyS3RA9YyJj8d9IXH)adHMPFqoQ3HhQ33lZZdhHmcUxOYJ59cW6m9JEhshs71YE)HO27lHJUiO30NqQLOEX4qkg6fJd)bgcnt)GCuVdpuVVxMNhoczeCVyNNhCuSG3I9ETSxSZZdokwWBd0PvhbJ9EX4WFGHqZ0pih17WmoVVxMNhoczeCVy3qY5fzHHdEl271YEXUHKZlYc2WbVf79Irg3hyi0m9dYr9omJZ77L55HJqgb3l2nKCErwyObVf79AzVy3qY5fzbBObVf79Irg3hyi0m9dYr9omMI33lZZdhHmcUxSZZdokwWBXEVw2l255bhfl4Tb60QJGXEVyC4pWqOz6hKJ6DOd799Y88WriJG7f7O4rZebHcEl271YEXokE0mrqOG3gOtRocg79IXH)adHMPFqoQ3HouVVxMNhoczeCVyhfpAMiiuWBXEVw2l2rXJMjccf82aDA1rWyVxmo8hyi0m9dYr9ougN33lZZdhHmcUxSBQJol4TyVxl7f7M6OZcEBGoT6iyS3lgh(dmeAM(b5OEhkJZ77L55HJqgb3l2rXJMjccf8wS3RL9IDu8OzIGqbVnqNwDem27fJd)bgcnt)GCuVdftX77L55HJqgb3l2rXJMjccf8wS3RL9IDu8OzIGqbVnqNwDem27fJd)bgcnt)GCuVdDi8(EzEE4iKrW9IDu8OzIGqbVf79AzVyhfpAMiiuWBd0PvhbJ9EX4WFGHqZuZeMkMgtMrEdg5n5992lEgPELNFISENjQxS7JiE(QQH9Er0phfeb3liFuVA0YNAeCV8r9GqGqZ0pih17q9(EzEE4iKrW9IDtD0zbVf79AzVy3uhDwWBd0PvhbJ9EvRxgBmHFOxmo8hyi0m1mHPIPXKzK3GrEtEFV9INrQx55NiR3zI6f788vJatYRWZ0bNdoa27fr)CuqeCVG8r9QrlFQrW9Yh1dcbcnt)GCuVmMEFVmppCeYi4EXokE0mrqOG3I9ETSxSJIhnteek4Tb60QJGXEVyC4pWqOzQzctftJjZiVbJ8M8(E7fpJuVYZprwVZe1l2vUj4OIPo6ma27fr)CuqeCVG8r9QrlFQrW9Yh1dcbcnt)GCuVd177L55HJqgb3l2n1rNf8wS3RL9IDtD0zbVnqNwDem27fJd9dmeAM(b5OEzCEFVmppCeYi4EXUPo6SG3I9ETSxSBQJol4Tb60QJGXEVyC4pWqOzQzctftJjZiVbJ8M8(E7fpJuVYZprwVZe1l2bMEWkcUGstnjpS3lI(5OGi4Eb5J6vJw(uJG7LpQheceAM(b5OEhQ33lZZdhHmcUxSJIhnteek4TyVxl7f7O4rZebHcEBGoT6iyS3lgh(dmeAM(b5OEzm9(EzEE4iKrW9IDtD0zbVf79AzVy3uhDwWBd0PvhbJ9EX4WFGHqZ0pih17qI33lZZdhHmcUxSJIhnteek4TyVxl7f7O4rZebHcEBGoT6iyS3lgh6hyi0m9dYr9o8WEFVmppCeYi4EXUPo6SG3I9ETSxSBQJol4Tb60QJGXEVyC4pWqOzQzctftJjZiVbJ8M8(E7fpJuVYZprwVZe1l255RgbMKxXFube27fr)CuqeCVG8r9QrlFQrW9Yh1dcbcnt)GCuVykEFVmppCeYi4EXopp4OybVf79AzVyNNhCuSG3gOtRocg79IXH)adHMPFqoQxVzVVxMNhoczeCVy3uhDwWBXEVw2l2n1rNf82aDA1rWyVxmo8hyi0m9dYr96n799Y88WriJG7f7O4rZebHcEl271YEXokE0mrqOG3gOtRocg79IXH(bgcnt)GCuVdjEFVmppCeYi4EXokE0mrqOG3I9ETSxSJIhnteek4Tb60QJGXEVyC4pWqOz6hKJ6DygtVVxMNhoczeCVy3uhDwWBXEVw2l2n1rNf82aDA1rWyVxmo0pWqOz6hKJ6DyglVVxMNhoczeCVyNNhCuSG3I9ETSxSZZdokwWBd0PvhbJ9EvRxgBmHFOxmo8hyi0m1m5nE(jYi4E9M7v5MKxVobyGqZeluGpXzzeJjJJfQpkNIJyH(7V9YWcI6DitHqnt)(BVJM5d8EmJziIngRbE(WmqErNAsECKonmdKhhZnt)(BVy6iKiW6DygR)9ougAOd3m1m97V9Y8r9GqaVVz63F71769hbOENcKrRGONkhOxKAJeQxBuVEnfbHSGjpQyzbwOENjQxNcmVdq88G7vRItmS6ncuiei0m97V96D9(dzcORxUcSEr0phfe9OZa9otuVmpF1iWK86fJsGc)7fopSB9oMo4EfR3zI6v7DIiWyVdzKrjQxUcmmeAM(93E9UEzSpT6OEbgs4wV8rI7LCq6nVE1EN0GENjYlqVY1Rns9IP)PFOxl7frWro17Ge5Llv4qZ0V)2R31lMgMXyey9Q9(tyHYQtbwV0ziS61gvRx4Ka9EP17lHjxVdiNRx58oi6J6fJa51RraJG7vTEVSxGa5KPW1Z6LX)tq7vE(k3WqOz63F7176L55HJqwVQZ1BnoNbVnGiLB9sNHec0RL9wJZzWBdr))9QxVQ7LaRx5acKtMcxpRxg)pbTxiQC9kxVa5bcnt)(BVExV)ia17OIG5jmb3lofjA1rGETSxebh5uVm)N(r9oirE5sfo0m1m97V9Yy)bXJgb3BLMjI6LNVQA9wjiYbc9IP5CY3a9E55DJk6nJUEvUj5b6nphwHMjLBsEGGpI45RQ2NEWSI46rf5mY5iU1m97V9IP)PFOxmrfjA1r9Ij4BsEEFVEJzVaY61YE1EV88UHCek7fN6I0)ETrQxMNVAeysE9QCtYRx9G7LNPdohCGETr16vruV88agsLJG71YEZZHvVvQ3iGG7DWiD9Y88vJatYRxb0B0V3bIZ17LwVvQ3iGG7foIKdsV2i1lqErNAsEHMPF)T3F)TxLBsEGGpI45RQ2NEWmofjA1r)p9rEGfGwDuHNVAeysE)tFpicqwZ0V9IP)PFOxmrfjA1r9Ij4BsEEFV4zua9ItrIwDuVaFIltHa9oyKSrc1lZZxncmjVEbJz0b3BL6nci4EHJi5G0ldlicykYiuOz63F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKNPGiGPiJqfE(QrGj59p99ai7Vm9WmtD0zbFSqj3PG3FCQlsEg(po1fPc5aKhgQz63EX0)0p0lMOIeT6OEXe8njpVVx8mkGEXPirRoQxGpXLPqGETrQ3l(QeQ3C2RPiiKb6vTEhmk8XEXKsRxOgIuV6LHD6Jags8Ia9MrdiWuV5SxMNVAeysE9cgZOdU3k1BeqWHMPF)TxLBsEGGpI45RQ2NEWmofjA1r)p9rEgtRamePEvMo9radjEr)tFpaY(ltpM6OZctN(OIVA8X)4uxK8m0)4uxKkKdqEyCnt)2lM(N(HEXevKOvh1lMGVj5599INrb0lofjA1r9c8jUmfc0Rns9EXxLq9MZEnfbHmqVQ17GrHp2lMKIG7L5kW6LHD6Jags8Ia9MrdiWuV5SxMNVAeysE9cgZOdU3k1BeqW9QGENIZrOqZ0V)2RYnjpqWhr88vv7tpygNIeT6O)N(ipJkcUWvGvMo9radjEr)tFpaY(ltpM6OZctN(OIVA8X)4uxK8m0)4uxKkKdqEyCnt)2lM(N(HEXevKOvh1lMGVj5599INrb0lofjA1r9c8jUmfc0Rns9EXxLq9MZEnfbHmqVQ17GrHp2lMuA9c1qK6vVmStFeWqIxeOxfr9gbeCVWrKCq6L55RgbMKxOz63F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKhE(QrGj5vMo9radjEr)tFpaY(ltpM6OZctN(OIVA8X)4uxK8W4(JtDrQqoa5HXSz63EX0)0p0lMOIeT6OEXe8njpVVx8mkGEXPirRoQxGpXLPqGETrQ3l(QeQ3C2RPiiKb6vTEhmk8XEX0iUEuVm2F47sGKxVz0acm1Bo7L55RgbMKxVGXm6G7Ts9gbeCOz63F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKhfX1Jk0h(Uei59p99ai7Vm9yQJolmD6Jk(QXh)JtDrYZqYqYFCQlsfYbipdTz63EX0)0p0lMOIeT6OEXe8njpVVx8mkGEXPirRoQxGpXLPqGETrQxFcXPZuiuV5S3NEAVvYLd6DWOWh7ftJ46r9Yy)HVlbsE9oqCUEV06Ts9gbeCOz63F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKhfX1Jk0h(Uei5vE6P)HPPgDMhmfg6F67braYAM(Txm9p9d9IjQirRoQxmbFtYZ77fpJuVx8vjuV5Sxtrqid0l0rzAYbP3FkhqOEbJz0b3BL6nci4EZRx4isoi9Y88vJatYl0m97V9QCtYde8repFv1(0dMXPirRo6)PpYdpF1iWK8kGrzAYbP4Ndi0FyAQrN5zO)tFpicqwZ0V9IP)PFOxmrfjA1r9Ij4BsEEFV4zK61Kh1lIEQCYbP386v7LRaR3bJ01lZZxncmjVE561BL6nci4ELRxaXZdgeAM(93EvUj5bc(iINVQAF6bZ4uKOvh9)0h5HNVAeysEfUcScIEQCG)W0uJoZddf8M)N(EqeGSMPF7ft)t)qVyIks0QJ6ftW3K88(EXZOa6fNIeT6OEb(exMcb61gPEV4RsOEZzVaINhmO3C2ldliQxS5uG1RnQwVGXm6G7Ts96NPJG71xbwV2i1lmn1OZ6vFz8SqZ0V)2RYnjpqWhr88vv7tpygNIeT6O)N(ipjoc5NPRmfevQofyG)W0uJoZdd9p99Giaznt)2lM(N(HEXevKOvh1lMGVj5599IjLd61LhKER0mruVmpF1iWK86fmMrhCVm2pFSqK66ftabF6XPERuVrabpKVz63F7v5MKhi4JiE(QQ9PhmJtrIwD0)tFKh65JfIuxjrWNECQatofR)W0uJoZZWmw)tFpicqwZ0V)2R3y2lZZxncmjVEfqVWcqRoc(FVa(ibhDuV2i17uqaRxMNVAeysE9ovuV60iuV2i17uGmA9shmi0m97V9(7V9QCtYde8repFv1(0dMXPirRo6)PpYJjpQyzHNVAeysE)XPUi5zkqgTcIEQCGphMHyO)Y0dofjA1rbybOvhv45RgbMKxZ0V9INrQx4isnjVEZzVAVqJxVmgKdc2b9InhbaYbPxMNVAeysEHMPF)TxLBsEGGpI45RQ2NEWmofjA1r)p9rEaEvlWrKAsE)tFpaY(JtDrYZq0m9BVyQJKnsOE1EJaT6OEfJE9gbeCVw2BnoN9Y88vJatYRxb0l9ZrX3NGdnt)(BVk3K8abFeXZxvTp9GzCks0QJ(F6J8WZxncmjVsELiG(JtDrYd9ZrX3NGdqCkSOwIaLQcdHWhF6NJIVpbhEkxRiQagjYkViq44Jp9ZrX3NGdYb4OOPvhv(5OEw8vGjCcNWhF6NJIVpbhaXR6YeUOpYgXcy4Jp9ZrX3NGd0ZhlePUsIGp94e(4t)Cu89j4W0PpQKZsvnZr4Jp9ZrX3NGdduVOJqGYeLhm(4t)Cu89j4GCadf5wIafybNCuPsoh(4t)Cu89j4ayuHZbeCjr1solwIE0znt)2lMuoOxxEq6TsZer9Y88vJatYRxWygDW9Ai58ImqV2OA9Aibcec1R2lyureCVC1iijcRE5z6GZbxV51BAJeQxdjNxKb69sR3k1BeqWd5BM(93EvUj5bc(iINVQAF6bZ4uKOvh9)0h5jVseqfE0Y58F67bq2FCQlsEgkd9xMEWPirRokWZxncmjVsELiGAM(93EvUj5bc(iINVQAF6bZ4uKOvh9)0h5jVseqfE0Y58F67bq2FCQlsEg6q8xMEOFok((eC4PCTIOcyKiR8IaH3m97V9QCtYde8repFv1(0dMXPirRo6)PpYtELiGk8OLZ5)03dGS)4uxK8mug6tCks0QJc0ZhlePUsIGp94ubMCkw)LPh6NJIVpbhONpwisDLebF6XPMjLBsEGGpI45RQ2NEWCeqfXO3)tFKhqgDfbYjgH(ltpmdNIeT6OapF1iWK8k5vIa6lZOFok((eCagrk8uqubhbaK7lZm1rNfMcIaMImc1mPCtYde8repFv1(0dMFccLOI8uiuZKYnjpqWhr88vv7tpy2hluwDkW(ltpmZhr4c(yHYQtbwZuZ0V)2lJ9hepAeCVeocHvVM8OETrQxLBjQxb0RItfNwDuOzs5MKhWdpJNriGp5C)LPhMHIhnteekalaU47Ktryv457PhCZ0V)2lEgPE55RgbMKxXKNCq6v5MKxVoby9c4JeC0rGEhmsxVmpF1iWK86DG4C9wPEJacUx9G7fyjIa9AJuViceDwVY1lofjA1rbtEuXYcpF1iWK8cnt)(BVk3K8aF6bZC15kk3K8koby)p9rE45RgbMKxXKNCqAM(TxmrfjA1r9AJQ1lbm5Pgb6DWizJeQxOJY0KdsV)uoGq9oqCUERuVrab3BLMjI6L55RgbMKxVcOxePWyfAM(93EvUj5b(0dMXPirRo6)PpYdyuMMCqk(5acvQ0mruHNVAeysE)tFpaY(JtDrYdgvUj4OcD0tiadWPirRokWZxncmjVcyuMMCqk(5acHp(k3eCuHo6jeGb4uKOvhf45RgbMKxz60hbmK4fHp(4uKOvhfm5rfll88vJatYZ7uUj5faJY0KdsXphqOWm6Cfebh5MKhE5z6GZbxamkttoif)CaHcWrKAsEy4lofjA1rbtEuXYcpF1iWK88oEMo4CWfaJY0KdsXphqOaIEQCa8QCtYlagLPjhKIFoGqHz05kicoYnjVVyKNPdohCbu8Osol(5acfq0tLd4D8mDW5GlagLPjhKIFoGqbe9u5a4DiWhFMzQJolGIhvYzXphqim0mPCtYd8PhmdgLPjhKIFoGq)LPNACod88vJatYlaNdUVk3K8ctbrLQtbwGpQiieGbEg(lZWynoNb5Me6uxHRaUctHO)3ACodJPvagIuVcis5gg(ItrIwDuamkttoif)CaHkvAMiQWZxncmjVMjLBsEGp9GzKcl6zfGVI86Vm9uJZzGNVAeysEb4CW9fJ4uKOvhfm5rfll88vJatYJb4uKOvhf45RgbMKxXhrCfyftE0N0hepAuXKhHp(4uKOvhfm5rfll88vJatYdV8mDW5GZ7gMHWqZKYnjpWNEWmmP2ynrh9xMEQX5mWZxncmjVaCo4(wJZzafpQKZIFoGqb4CW9fNIeT6OGjpQyzHNVAeysEmaNIeT6OapF1iWK8k(iIRaRyYJ(K(G4rJkM8OpXynoNbysTXAIokahrQj55D14Cg45RgbMKxaoIutYdd)yu8OzIGqbysTrqzQ2y(AMuUj5b(0dMFccLiqjNflrp6S)Y0dofjA1rbtEuXYcpF1iWK8yaofjA1rbE(QrGj5v8rexbwXKh9j9bXJgvm5rFRX5mWZxncmjVaCo4AM(Txgor9IjsNnIf6FVra1R2ldliQxS5uG1lFurqOEHJi5G07qMGqjc0Bo7fpj6rN1lxbwVw2RIlf4E5QVVCq6LpQiiei0mPCtYd8PhmpfevQofy)JaQmyuCuHRatoiEg(Vm9OCtYl8eekrGsolwIE0zb6dIhn5G8DgDUcI4Jkccvm5rENYnjVWtqOebk5Syj6rNfOpiE0OcIEQCagGP8LzJPvagIuVkaFY5af5ktNaz0(YSACodJPvagIuVcr)MjLBsEGp9G5iGkIrV)0CsCRC6J8aXPWIAjcuQkme6Vm9GtrIwDuWKhvSSWZxncmjp8YZ0bNdoVBiAMuUj5b(0dMJaQig9(F6J8qpFSqK6kjc(0Jt)LPhCks0QJcM8OILfE(QrGj5Xap4uKOvhfONpwisDLebF6XPcm5uS(ItrIwDuWKhvSSWZxncmjp8ItrIwDuGE(yHi1vse8PhNkWKtXY7gIMjLBsEGp9G5iGkIrV)N(ipGrfohqWLevl5Syj6rN9xMEWiofjA1rbtEuXYcpF1iWK8yGhCks0QJc88vJatYR4JiUcSIjp6ZHIp(tbYOvq0tLdWaCks0QJcM8OILfE(QrGj5HHV14Cg45RgbMKxaohCntk3K8aF6bZraveJE)p9rEG4WYFSKZIcaYtCQj59xMEWPirRokyYJkww45RgbMKhE9GtrIwDuiVseqfE0Y5Szs5MKh4tpyocOIy07)PpYZt5AfrfWirw5fbc)Vm9GtrIwDuWKhvSSWZxncmjpg4ziAM(TxVXS3iqoi9Q9cmcLcCV55Dra1Ry07FVQBGIfO3iG6LXJifEkiQxmrcaixVz0acm1Bo7L55RgbMKxOxmbBKqdea9VxFKKiXKHCuVrGCq6LXJifEkiQxmrcaixVdeBSxMNVAeysE9MNdRELzVEJBsOtD9YCfWvyQxb0lDA1rW9QhCVAVrGcH6DqEy36Ts96sG1BIJq9AJuVWrKAsE9MZETrQ3Paz0c9INrb0Rcdd6v7f8uNRxCQls9AzV2i1lpthCo46nN9Y4rKcpfe1lMibaKR3bJ01lCkhKETrb0lxD8OtnjVERexJaQxX6va9gpePoGj8ETSxfaIpQxBuTEfR3bIZ1BL6nci4E9j0K4MdREZRxEMo4CWfAMuUj5b(0dMJaQig9(F6J8aJifEkiQGJaaY9xMEWPirRokyYJkww45RgbMKhE9GtrIwDuiVseqfE0Y58lgRX5mi3KqN6kCfWvykamL7LNACodYnj0PUcxbCfMcp9JcWuUx4JpZ45bhfli3KqN6kCfWvycF8XPirRokWZxncmjVsELiGWhFCks0QJcM8OILfE(QrGj5Hx5mc5No1i4YuGmAfe9u5adPdPyKNPdohCFomdHbm0m97V9YiAqVqZORxVbKtmc1lDgcR)9IiNqGEZRxWOIi4EfJE9YCgFVYnt0tnjVETr16va9EP1lwK1li67NiJGd92lMm57uob61gPE9reojJGEDYr9oyKUENXJBsEQl0mPCtYd8Phmhburm69)0h5bKrxrGCIrO)Y0dgXPirRokyYJkww45RgbMKhE9W4yOFmgXPirRokKxjcOcpA5CIxgcd4JpgzMHKZlYcdheqaKrxrGCIrOVgsoVilmCic0QJ(Ai58ISWWbEMo4CWfq0tLdGp(mZqY5fzHHgeqaKrxrGCIrOVgsoVilm0qeOvh91qY5fzHHg4z6GZbxarpvoagWWxmYm6NJIVpbhGrKcpfevWraa5WhFEMo4CWfGrKcpfevWraa5ci6PYbW7qGHMPF7fpibcec1l0m661Ba5eJq9skYHvVdeBSxVXnj0PUEzUc4km1BI6DWiD9kwVduqV(iIRal0mPCtYd8PhmZ1JtUsnoN)p9rEaz0veiNysE)LPhMXZdokwqUjHo1v4kGRW0xtEedgc8XVgNZGCtcDQRWvaxHPaWuUxEQX5mi3KqN6kCfWvyk80pkat5E1m9BVEdJEGETr16fo79sR3kD0uSEzE(QrGj51lymJo4EzmgbwVvQ3iGG7nJgqGPEZzVmpF1iWK86vTEb5J61pLZcntk3K8aF6bZraveJE)p9rEKdWrrtRoQ8Zr9S4Rat4eo9xMEOFok((eCaItHf1seOuvyi0xCks0QJcM8OILfE(QrGj5Hxp4uKOvhfYRebuHhTCoBMuUj5b(0dMJaQig9(F6J8mD6Jk5SuvZC0Fz6H(5O47tWbiofwulrGsvHHqFXPirRokyYJkww45RgbMKhE9GtrIwDuiVseqfE0Y5Szs5MKh4tpyocOIy07)PpYZa1l6ieOmr5b)xMEOFok((eCaItHf1seOuvyi0xCks0QJcM8OILfE(QrGj5Hxp4uKOvhfYRebuHhTCoBMuUj5b(0dMJaQig9(F6J8ihWqrULiqbwWjhvQKZ9xMEOFok((eCaItHf1seOuvyi0xCks0QJcM8OILfE(QrGj5Hxp4uKOvhfYRebuHhTCoBMuUj5b(0dMJaQig9(F6J8aIx1LjCrFKnIfW(ltp0phfFFcoaXPWIAjcuQkme6lofjA1rbtEuXYcpF1iWK8WRhCks0QJc5vIaQWJwoNntk3K8aF6bZraveJEG)Y0dofjA1rbtEuXYcpF1iWK8WRhCks0QJc5vIaQWJwoNnt)27pcq9YWOey9YOeN2RL9Aibcec1R3esaoS61BWfUJcntk3K8aF6bZtucSYL40)Y0dkE0mrqOaeKaCyveUWD03ACod88vJatYlaNdUVyeNIeT6OGjpQyzHNVAeysE4LNPdohC4JpofjA1rbtEuXYcpF1iWK8yaofjA1rbE(QrGj5v8rexbwXKh9j9bXJgvm5ryOz63E9MiRxBK6LXlaU47Ktry1lZZ3tp4ERX5S3O))EJNJaGE55RgbMKxVcOxqMxOzs5MKh4tpyMNXZieWNCU)Y0dkE0mrqOaSa4IVtofHvHNVNEWF5z6GZbxOgNZcSa4IVtofHvHNVNEWbePWy9TgNZaSa4IVtofHvHNVNEWffX1JcW5G7lZQX5malaU47Ktryv457PhCi6)fJ4uKOvhfm5rfll88vJatY7tLBsEHjkbwnDwGRaRyYJWlpthCo4c14CwGfax8DYPiSk8890doahrQj5Hp(4uKOvhfm5rfll88vJatYJbdbgAMuUj5b(0dMvexpQqF47sGK3Fz6bfpAMiiuawaCX3jNIWQWZ3tp4V8mDW5GluJZzbwaCX3jNIWQWZ3tp4aIuyS(wJZzawaCX3jNIWQWZ3tp4II46rb4CW9Lz14CgGfax8DYPiSk8890doe9)IrCks0QJcM8OILfE(QrGj59j9bXJgvm5rFQCtYlmrjWQPZcCfyftEeE5z6GZbxOgNZcSa4IVtofHvHNVNEWb4isnjp8XhNIeT6OGjpQyzHNVAeysEmyi(YmtD0zbu8Osol(5acHHMjLBsEGp9G5jkbwnD2Fz6bfpAMiiuawaCX3jNIWQWZ3tp4V8mDW5GluJZzbwaCX3jNIWQWZ3tp4aIEQCagWvGvm5rFRX5malaU47Ktryv457PhCzIsGfGZb3xMvJZzawaCX3jNIWQWZ3tp4q0)lgXPirRokyYJkww45RgbMK3NCfyftEeE5z6GZbxOgNZcSa4IVtofHvHNVNEWb4isnjp8XhNIeT6OGjpQyzHNVAeysEmyiWqZKYnjpWNEW8eLaRCjo9Vm9GIhnteekalaU47Ktryv457Ph8xEMo4CWfQX5SalaU47Ktryv457PhCarkmwFRX5malaU47Ktryv457PhCzIsGfGZb3xMvJZzawaCX3jNIWQWZ3tp4q0)lgXPirRokyYJkww45RgbMKhE5z6GZbxOgNZcSa4IVtofHvHNVNEWb4isnjp8XhNIeT6OGjpQyzHNVAeysEmyiWqZKYnjpWNEWmxDUIYnjVIta2)tFKhE(QrGj5v8hva9xMEWPirRokyYJkww45RgbMKhd8Wq4JpofjA1rbtEuXYcpF1iWK8yaofjA1rbE(QrGj5v8rexbwXKh9LNPdohCbE(QrGj5fq0tLdWaCks0QJc88vJatYR4JiUcSIjpQzs5MKh4tpygfpQKZIFoGq)LPNACodO4rLCw8ZbekaNdUVmRgNZWuqeWs0le9)IrCks0QJcM8OILfE(QrGj5Hxp14CgqXJk5S4NdiuaoIutY7lofjA1rbtEuXYcpF1iWK8WRYnjVWuquP6uGfMrNRGi(OIGqftEe(4JtrIwDuWKhvSSWZxncmjp8ofiJwbrpvoagAM(T3FktxVkO3NEy1ldliQxS5uGb6vb96NaGuDuVZe1lZZxncmjVqVqJvdPCR3mA9MZETrQ3js5MKN66LNp)8OZ6nN9AJuVx8vjuV5SxgwquVyZPad0RnQwVdeNR3tTisDoS6fr8rfbH6foIKdsV2i1lZZxncmjVE9hva1BL4Aeq96NPtoi9Qhw2OCq61xbwV2OA9oqCUEV06fcspRx96L(WqAVmSGOEXMtbwVWrKCq6L55RgbMKxOz63F7v5MKh4tpygNIeT6O)ravY5SaHd7z4)ravgmkoQWvGjhepd))0h5zkiQuDkWk(z6KdYFCQlsEuUj5fMcIkvNcSaFurqiqzIuUj5PUpXiofjA1rbtEuXYcpF1iWK8(u5MKxamkttoif)CaHcZOZvqeCKBsE)yCks0QJcGrzAYbP4NdiuPsZerfE(QrGj5HHHuEMo4CWfMcIkvNcSaCePMKN3nmd4z6GZbxykiQuDkWcp9JcFurqiWN4uKOvhfsCeYptxzkiQuDkWadP8mDW5GlmfevQofyb4isnjpVdJ14Cg45RgbMKxaoIutYBiLNPdohCHPGOs1PalahrQj5HHH0H0H)ItrIwDuWKhvSSWZxncmjpgmfiJwbrpvoqZ0V9IjQirRoQxBuTE55zO0b69Ngt6Kp6LHD6Ja9gbkeQxl7Loqer9kgOx(OIGqGEve1RFMocU3zI6L55RgbMKxOxmHZHvVra17pnM0jF0ld70hb6nJgqGPEZzVmpF1iWK86DWiD9oJoxV8rfbHa9Y1R3k1BwnvocUx4isoi9AJuVh9H1lZZxncmjVqZ0V)2RYnjpWNEWmofjA1r)p9rE8ht6Kpk(z6KdYFz6r5MGJk0rpHamaNIeT6OapF1iWK8ktN(iGHeVO)4uxK8GtrIwDuWKhvSSWZxncmjVpRX5mWZxncmjVaCePMKN3nemq5MKxWFmPt(OmD6JaHz05kiIpQiiuXKh9jpthCo4c(JjDYhLPtFeiahrQj55Dk3K8cGrzAYbP4NdiuygDUcIGJCtY7hJtrIwDuamkttoif)CaHkvAMiQWZxncmjVV4uKOvhfm5rfll88vJatYJbtbYOvq0tLdGp(O4rZebHcG4v8soiGs1raGCqWhFtEedgIMPF7ftDKUEJa5G0ld70hbmK4f1RC9Y88vJatY7FVafh1Rc69Phw9Yhveec0Rc61pbaP6OENjQxMNVAeysE9oqSXmA9YvFF5GeAM(93EvUj5b(0dMXPirRo6)PpYJ)ysN8rXptNCq(ltpk3eCuHo6jeaVEWPirRokWZxncmjVY0PpcyiXl6po1fjp4uKOvhfm5rfll88vJatYJbk3K8c(JjDYhLPtFeimJoxbr8rfbHkM8iVt5MKxamkttoif)CaHcZOZvqeCKBsE)yCks0QJcGrzAYbP4NdiuPsZerfE(QrGj59fNIeT6OGjpQyzHNVAeysEmykqgTcIEQCa8XhfpAMiiuaeVIxYbbuQocaKdc(4BYJyWq0mPCtYd8PhmZvNROCtYR4eG9)0h5bL(f)rfq)bgs4MNH)ltp14CgqXJk5S4Ndiui6)fNIeT6OGjpQyzHNVAeysE4LHAM(TxmnmJXiW61gPEXPirRoQxBuTE55zO0b6LHfe1l2CkW6ncuiuVw2lDGiI6vmqV8rfbHa9QiQx1bYE9Z0rW9otuVyYXJ6nN9(t5acfAM(93EvUj5b(0dMXPirRo6FeqLColq4WEg(FeqLbJIJkCfyYbXZW)p9rEMcIkvNcSIFMo5G8p99ai7po1fjp8mDW5GlGIhvYzXphqOaIEQCagOCtYlmfevQofyHz05kiIpQiiuXKh5Dk3K8cGrzAYbP4NdiuygDUcIGJCtY7hJrCks0QJcGrzAYbP4NdiuPsZerfE(QrGj59LNPdohCbWOmn5Gu8ZbekGONkhGb8mDW5GlGIhvYzXphqOaIEQCam8LNPdohCbu8Osol(5acfq0tLdWGPaz0ki6PYb(ltpmdNIeT6OWuquP6uGv8Z0jhKVM6OZcO4rLCw8Zbe6BnoNbu8Osol(5acfGZbxZ0V9IPosxVyskcMRatoi9YWo9r9c1qIx0)Ezybr9InNcmqVGXm6G7Ts9gbeCVw2le6iKAuVysP1ludrQxGE1dUxl7L(WOdUxS5uGrOEhYuGrOqZKYnjpWNEW8uquP6uG9pcOsoNfiCypd)pcOYGrXrfUcm5G4z4)Y0dZWPirRokmfevQofyf)mDYb5lofjA1rbtEuXYcpF1iWK8Wld9v5MGJk0rpHa41dofjA1rHrfbx4kWktN(iGHeVOVmBkicykYiuq5MGJ(YSACodJPvagIuVcr)VySgNZWiPMCqkr)q0)RYnjVW0PpcyiXlkqFq8Orfe9u5amGHcdb(4ZhveecuMiLBsEQdVEgkgAM(TxgFejhKEzybratrgH(3ldliQxS5uGb6vruVrab3lqEItroS61YEHJi5G0lZZxncmjVqVEt0ri15W6FV2iHvVkI6nci4ETSxi0ri1OEXKsRxOgIuVa9oyKUE5iXa9oqCUEV06Ts9oqbgb3REW9oqSXEXMtbgH6DitbgH(3Rnsy1lymJo4ERuVaFePW9MrRxl79PYzQC9AJuVyZPaJq9oKPaJq9wJZzOzs5MKh4tpyEkiQuDkW(hbujNZceoSNH)hbuzWO4OcxbMCq8m8Fz6zkicykYiuq5MGJ(YhveecGxpd)Lz4uKOvhfMcIkvNcSIFMo5G8fJmt5MKxykiQQoxG(G4rtoiFzMYnjVGpwOS6uGfKRmDcKr7BnoNHrsn5GuI(HOp(4RCtYlmfevvNlqFq8OjhKVmRgNZWyAfGHi1Rq0hF8vUj5f8XcLvNcSGCLPtGmAFRX5mmsQjhKs0pe9)YSACodJPvagIuVcrFm0m9BVyACPa3lx99LdsVmSGOEXMtbwV8rfbHa9oyuCuV8r9oYjhKEHokttoi9(t5ac1mPCtYd8PhmpfevQofy)JaQmyuCuHRatoiEg(Vm9OCtYlagLPjhKIFoGqb6dIhn5G8DgDUcI4Jkccvm5rmq5MKxamkttoif)CaHcMW9QGi4i3K8(wJZzymTcWqK6vaohCFn5r4DygQzs5MKh4tpyMRoxr5MKxXja7)PpYdW0dwrWfuAQj59xMEWPirRokyYJkww45RgbMKhEzOV14CgqXJk5S4NdiuaohCntk3K8aF6bZaEI4Jntntk3K8abLBcoQyQJod4Xj4KdsPMV6Fz6r5MGJk0rpHa4D4V14Cg45RgbMKxaohCFXiofjA1rbtEuXYcpF1iWK8WlpthCo4cobNCqk18vdWrKAsE4JpofjA1rbtEuXYcpF1iWK8yGhgcdntk3K8abLBcoQyQJod8Phm)iJs0Fz6bNIeT6OGjpQyzHNVAeysEmWddHp(yKNPdohCHhzuIcWrKAsEmaNIeT6OGjpQyzHNVAeysEFzMPo6SakEujNf)CaHWa(4BQJolGIhvYzXphqOV14CgqXJk5S4Ndiui6)fNIeT6OGjpQyzHNVAeysE4v5MKx4rgLOapthCo4Wh)Paz0ki6PYbyaofjA1rbtEuXYcpF1iWK8AMuUj5bck3eCuXuhDg4tpyggPqYduQisTX)Y0JPo6SG6Opagsbd5uqzgry9fJ14Cg45RgbMKxaohCFzwnoNHX0kadrQxHOpgAMAMuUj5bc88vJatYRWZ0bNdoGh)0K8AMuUj5bc88vJatYRWZ0bNdoWNEWC1LjCzgry1mPCtYde45RgbMKxHNPdohCGp9G5kHaeYl5G8xMEQX5mWZxncmjVq0Vzs5MKhiWZxncmjVcpthCo4aF6bZtbrvxMWntk3K8abE(QrGj5v4z6GZbh4tpywpobmK6kC15AMuUj5bc88vJatYRWZ0bNdoWNEWSjpQmqr()LPhu8OzIGqbJE(jsDLbkY)BnoNb6JrncmjVq0Vzs5MKhiWZxncmjVcpthCo4aF6bZraveJE)P5K4w50h5bItHf1seOuvyiuZKYnjpqGNVAeysEfEMo4CWb(0dMJaQig9(F6J8ihGJIMwDu5NJ6zXxbMWjCQzs5MKhiWZxncmjVcpthCo4aF6bZraveJE)p9rEMo9rLCwQQzoQzs5MKhiWZxncmjVcpthCo4aF6bZraveJE)p9rEgOErhHaLjkp4MjLBsEGapF1iWK8k8mDW5Gd8Phmhburm69)0h5roGHIClrGcSGtoQujNRzs5MKhiWZxncmjVcpthCo4aF6bZraveJE)p9rEaXR6YeUOpYgXcyntk3K8abE(QrGj5v4z6GZbh4tpyocOIy0d0m1mPCtYde45RgbMKxXFubKhNaz0afgJryip6S)Y0tnoNbE(QrGj5fGZbxZ0V9Yydm5Pg17yoOxxEq6L55RgbMKxVdeNRxNcSETr98c0RL9cnE9Yyqoiyh0l2CeaihKETSxyYi0toQ3XCqVmSGOEXMtbgOxWygDW9wPEJaco0m97V9QCtYde45RgbMKxXFub0NEWmofjA1r)JaQKZzbch2ZW)JaQmyuCuHRatoiEg()PpYd9Hrhmbx45RgbMKxbrpvoW)03dGS)4uxK8uJZzGNVAeysEbe9u5aFwJZzGNVAeysEb4isnjVFmg5z6GZbxGNVAeysEbe9u5amOgNZapF1iWK8ci6PYbWWFz6HNhCuSGCtcDQRWvaxHPMPF7ftddd61gPEHJi1K86nN9AJuVqJxVmgKdc2b9InhbaYbPxMNVAeysE9AzV2i1lDW9MZETrQxEeHOZ6L55RgbMKxVYSxBK6LRaR3bz0b3lpF(oYOEHJi5G0RnkGEzE(QrGj5fAM(93EvUj5bc88vJatYR4pQa6tpygNIeT6O)ravY5SaHd7z4)ravgmkoQWvGjhepd))0h5H(WOdMGl88vJatYRGONkh4F67rHH)JtDrYdofjA1rbGx1cCePMK3Fz6HNhCuSGCtcDQRWvaxHPVySgNZaiEfVKdcOuDeaihKcIuyScrF8XhNIeT6Oa9Hrhmbx45RgbMKxbrpvoaEhome)yiC4Wt)4hJXACodG4v8soiGs1raGCqcp9JcWuUxExnoNbq8kEjheqP6iaqoibGPCVWagAMuUj5bc88vJatYR4pQa6tpyUQqk5SyiH7f4Vm9uJZzGNVAeysEb4CW1mPCtYde45RgbMKxXFub0NEWStWjhKsnF1)Y0JYnbhvOJEcbW7WFRX5mWZxncmjVaCo4AM(TxmvXgZO1R34Me6uxVmxbCfM(3lJXiW6ncOEzybr9InNcmqVdgPRxBKWQ3b5HDR3x84J9YrIb6vp4EhmsxVmSGiGLOxVcOx4CWfAMuUj5bc88vJatYR4pQa6tpyEkiQuDkW(hbujNZceoSNH)hbuzWO4OcxbMCq8m8Fz6Hz88GJIfKBsOtDfUc4km9LpQiieaVEg(BnoNbE(QrGj5fI(FzwnoNHPGiGLOxi6)Lz14CggtRamePEfI(FhtRamePEva(KZbkYvMobYO9znoNHrsn5GuI(HOpdgAZ0V9IPk2yVEJBsOtD9YCfWvy6FVmSGOEXMtbwVra1lymJo4ERuVkmSysEQZHvV88agsLJG7fK9AJQ1Ry9kGEV06Ts9gbeCVXZraqVEJBsOtD9YCfWvyQxb0RwZO1RL9sF4liQ3e1RnsiQxfr9(se1RnQxV0LriJ9YWcI6fBofyGETSx6dJo4E9g3KqN66L5kGRWuVw2Rns9shCV5SxMNVAeysEHMPF)TxLBsEGapF1iWK8k(JkG(0dMXPirRo6FeqLColq4WEg(FeqLbJIJkCfyYbXZW)p9rEOp8jUrWLPGOs1Pad8p99ai7po1fjpk3K8ctbrLQtbwGpQiieOmrk3K8u3NyeNIeT6Oa9Hrhmbx45RgbMKxbrpvoG3vJZzqUjHo1v4kGRWuaoIutYdddP8mDW5GlmfevQofyb4isnjV)Y0dpp4Oyb5Me6uxHRaUctnt)(BVk3K8abE(QrGj5v8hva9PhmJtrIwD0)iGk5CwGWH9m8)iGkdgfhv4kWKdINH)F6J8CebtWLPGOs1Pad8p99ai7po1fjpCsCyeNIeT6Oa9Hrhmbx45RgbMKxbrpvoWqkgRX5mi3KqN6kCfWvykahrQj55Dq4WHN(bgWWFz6HNhCuSGCtcDQRWvaxHPMjLBsEGapF1iWK8k(JkG(0dMNcIkvNcS)ravY5SaHd7z4)ravgmkoQWvGjhepd)xME45bhfli3KqN6kCfWvy6lFurqiaE9m8xmItrIwDuG(WN4gbxMcIkvNcmaE9GtrIwDu4icMGltbrLQtbgaF8XPirRokqFy0btWfE(QrGj5vq0tLdWap14CgKBsOtDfUc4kmfGJi1K8Wh)ACodYnj0PUcxbCfMcat5EXGHIp(14CgKBsOtDfUc4kmfq0tLdWaiC4Wt)aF85z6GZbxamkttoif)CaHcisHX6RYnbhvOJEcbWRhCks0QJc88vJatYRagLPjhKIFoGqF5jo60ZcNaz0ktLWW3ACod88vJatYle9)IrMvJZzykicyj6fI(4JFnoNb5Me6uxHRaUctbe9u5amGHcdbg(YSACodJPvagIuVcr)VJPvagIuVkaFY5af5ktNaz0(SgNZWiPMCqkr)q0NbdTzs5MKhiWZxncmjVI)OcOp9GzU6CfLBsEfNaS)N(ipk3eCuXuhDgOzs5MKhiWZxncmjVI)OcOp9GzE(QrGj59pcOsoNfiCypd)pcOYGrXrfUcm5G4z4)Y0tnoNbE(QrGj5fGZb3xCks0QJcM8OILfE(QrGj5Xapm0xmYmu8OzIGqbybWfFNCkcRcpFp9GXh)ACodWcGl(o5uewfE(E6bhI(4JFnoNbybWfFNCkcRcpFp9GltucSq0)RPo6SakEujNf)CaH(YZ0bNdUqnoNfybWfFNCkcRcpFp9GdisHXcdFXiZqXJMjccfGGeGdRIWfUJWhFyQgNZaeKaCyveUWDui6JHVyKz8ehD6zHJ4O0Liy8XNNPdohCbysTXAIokGONkhaF8RX5matQnwt0rHOpg(IrMXtC0PNfWrNnIfcF85z6GZbx4jiuIaLCwSe9OZci6PYbWWxmQCtYl8iJsuqUY0jqgTVk3K8cpYOefKRmDcKrRGONkhGbEWPirRokWZxncmjVcxbwbrpvoa(4RCtYla4jIpgOpiE0KdYxLBsEbapr8Xa9bXJgvq0tLdWaCks0QJc88vJatYRWvGvq0tLdGp(k3K8ctbrv15c0hepAYb5RYnjVWuquvDUa9bXJgvq0tLdWaCks0QJc88vJatYRWvGvq0tLdGp(k3K8c(yHYQtbwG(G4rtoiFvUj5f8XcLvNcSa9bXJgvq0tLdWaCks0QJc88vJatYRWvGvq0tLdGp(k3K8ctN(iGHeVOa9bXJMCq(QCtYlmD6Jags8Ic0hepAubrpvoadWPirRokWZxncmjVcxbwbrpvoagAM(TxmbBKq9YZ0bNdoqV2OA9cgZOdU3k1BeqW9oqSXEzE(QrGj51lymJo4EZZHvVvQ3iGG7DGyJ9QxVk3IQRxMNVAeysE9YvG1REW9EP17aXg7v7fA86LXGCqWoOxS5iaqoi96JsEOzs5MKhiWZxncmjVI)OcOp9GzU6CfLBsEfNaS)N(ip88vJatYRWZ0bNdoWFz6PgNZapF1iWK8ci6PYbWlJf(4ZZ0bNdUapF1iWK8ci6PYbyWq0mPCtYde45RgbMKxXFub0NEW80PpcyiXl6Vm9GXACodJPvagIuVcr)Vk3eCuHo6jeaVEWPirRokWZxncmjVY0PpcyiXlcd4JpgRX5mmfebSe9cr)Vk3eCuHo6jeaVEWPirRokWZxncmjVY0PpcyiXlY7qXJMjccfMcIawIEyOzs5MKhiWZxncmjVI)OcOp9GzFSqz1Pa7Vm9uJZzaeVIxYbbuQocaKdsbrkmwHO)3ACodG4v8soiGs1raGCqkisHXkGONkhaVCfyftEuZKYnjpqGNVAeysEf)rfqF6bZ(yHYQtb2Fz6PgNZWuqeWs0le9BMuUj5bc88vJatYR4pQa6tpy2hluwDkW(ltp14Cg8XcLCNcEHO)3ACod(yHsUtbVaIEQCa8YvGvm5rFXynoNbE(QrGj5fq0tLdGxUcSIjpcF8RX5mWZxncmjVaCo4WWxLBcoQqh9ecWaCks0QJc88vJatYRmD6Jags8IAMuUj5bc88vJatYR4pQa6tpy2hluwDkW(ltp14CggtRamePEfI(FRX5mWZxncmjVq0Vzs5MKhiWZxncmjVI)OcOp9GzFSqz1Pa7Vm94JiCfiC4WWbapr8XV14Cggj1Kdsj6hI(FvUj4OcD0tiadWPirRokWZxncmjVY0PpcyiXl6BnoNbE(QrGj5fI(nt)27pcihKEHokttoi9(t5ac1lCejhKEzE(QrGj51RL9IiGLiQxgwquVyZPaRx9G79Ngt6Kp6LHD6J6LpQiieOxUE9wPER0rtHlQ7FV1O1BeevNdREZZHvV51lMozSdntk3K8abE(QrGj5v8hva9PhmdgLPjhKIFoGq)LPNACod88vJatYle9)YmLBsEHPGOs1PalWhveec8v5MGJk0rpHa41dofjA1rbE(QrGj5vaJY0KdsXphqOVk3K8c(JjDYhLPtFeimJoxbr8rfbHkM8i8oJoxbrWrUj59xoJqOOVvKPhLBsEHPGOs1PalWhveec4r5MKxykiQuDkWcp9JcFurqiqZKYnjpqGNVAeysEf)rfqF6bZ(JjDYhLPtFe4Vm9uJZzGNVAeysEHO)xdP4ixXKhXGACod88vJatYlGONkh4lgXOYnjVWuquP6uGf4JkccbyWWFn1rNf8XcLCNcEFvUj4OcD0tiGNHXa(4ZmtD0zbFSqj3PGh(4RCtWrf6ONqa8omg(wJZzyKutoiLOFi6)5yAfGHi1RcWNCoqrUY0jqgngm0MjLBsEGapF1iWK8k(JkG(0dMNo9radjEr)LPNACod88vJatYlaNdUV8mDW5GlWZxncmjVaIEQCagWvGvm5rFvUj4OcD0tiaE9GtrIwDuGNVAeysELPtFeWqIxuZKYnjpqGNVAeysEf)rfqF6bZtbrv15(ltp14Cg45RgbMKxaohCF5z6GZbxGNVAeysEbe9u5amGRaRyYJ(YmEEWrXctN(OIY5iYK8AMuUj5bc88vJatYR4pQa6tpygWteF8Vm9uJZzGNVAeysEbe9u5a4LRaRyYJ(wJZzGNVAeysEHOp(4xJZzGNVAeysEb4CW9LNPdohCbE(QrGj5fq0tLdWaUcSIjpQzs5MKhiWZxncmjVI)OcOp9GzNGtoiLA(Q)LPNACod88vJatYlGONkhGbq4WHN(XxLBcoQqh9ecG3HBMuUj5bc88vJatYR4pQa6tpyggPqYduQisTX)Y0tnoNbE(QrGj5fq0tLdWaiC4Wt)4BnoNbE(QrGj5fI(ntnt)2lMe58juV4uKOvh1RnQwV88mvoqV2i1RYTO66LaM8uJG71Kh1RnQwV2i17rFy9Y88vJatYR3bIZ1BL6frkmwHMPF)TxLBsEGapF1iWK8kM8KdIhCks0QJ(F6J8WZxncmjVcIuySkM8O)4uxK8WZ0bNdUapF1iWK8ci6PYb(X0h(e3i4IxYb7KdsbrWrUj51m9BV4zK6LRaRxtEuV5SxBK6f4toxV2OA9oqCUERuV(iIRaRx5SSxMNVAeysEHMPF)TxLBsEGapF1iWK8kM8KdYNEWmofjA1r)p9rE45RgbMKxXhrCfyftE0FCQlsEWOYnjVWuquvDUaxbwXKh9Jzgpp4OyHPtFur5CezsEFQCtYla4jIpg4kWkM8Op55bhflmD6JkkNJitYdd)ymQCtWrf6ONqagGtrIwDuGNVAeysELPtFeWqIxeg(u5MKxy60hbmK4ff4kWkM8OFmgvUj4OcD0tiaE9GtrIwDuGNVAeysELPtFeWqIxeg8oCks0QJc88vJatYRWvGvq0tLd0m97V9QCtYde45RgbMKxXKNCq(0dMXPirRo6)PpYdpF1iWK8kM8O)4uxK8GtrIwDuGNVAeysEfePWyvm5rnt)2lJNCkw9Y88vJatYR3zI6vNgH6LHfebmfzeQ345iaOxCks0QJctbratrgHk88vJatYRxb0lGSqZ0V)2RYnjpqGNVAeysEftEYb5tpygNIeT6O)N(ip88vJatYRyYJ(N(EE6h)XPUi5zkicykYiuarpvoWFz6XuhDwykicykYi0xMHtrIwDuykicykYiuHNVAeysEnt)2lJNCkw9Y88vJatYR3zI6ftwHf9SEH6RiV6vM9kwVdeNRxE(OEZ5SxEMo4CW1liZl0m97V9QCtYde45RgbMKxXKNCq(0dMXPirRo6)PpYdpF1iWK8kM8O)PVNN(XFCQlsE4z6GZbxaPWIEwb4RiVci6PYb(ltp8ehD6zbVWcj69LNPdohCbKcl6zfGVI8kGONkhW7gMHyaofjA1rbE(QrGj5vm5rnt)2lJNCkw9Y88vJatYR3zI6DitqOeb6nN9INe9OZAM(93EvUj5bc88vJatYRyYtoiF6bZ4uKOvh9)0h5HNVAeysEftE0)03Zt)4po1fjp8mDW5Gl8eekrGsolwIE0zbe9u5a)LPhEIJo9Sao6SrSqF5z6GZbx4jiuIaLCwSe9OZci6PYb8UHoemaNIeT6OapF1iWK8kM8OMPF7LXtofREzE(QrGj517mr9Y4j1gRj6OqZ0V)2RYnjpqGNVAeysEftEYb5tpygNIeT6O)N(ip88vJatYRyYJ(N(EE6h)XPUi5HNPdohCbysTXAIokGONkh4tmwJZzaMuBSMOJcWrKAsEExnoNbE(QrGj5fGJi1K8WWpgfpAMiiuaMuBeuMQnMV)Y0dpXrNEw4iokDjc(lpthCo4cWKAJ1eDuarpvoG3nmdXaCks0QJc88vJatYRyYJAM(Txgp5uS6L55RgbMKxVZe1lJNuBe7GEzy1gZxVat5Eb6vM9AJeI6vruVQ1RJuG1Rni71ueeYaHMPF)TxLBsEGapF1iWK8kM8KdYNEWmofjA1r)p9rE45RgbMKxXKh9p9980p(JtDrYtnoNbysTXAIokGONkhW7QX5mWZxncmjVaCePMK3Fz6bfpAMiiuaMuBeuMQnMVV14CgGj1gRj6Oq0)RYnbhvOJEcbWRNH2m9BVmEYPy1lZZxncmjVENjQxBK6LX(5JfIuxVyci4tpo1BnoN9kZETrQxFNIfH6va9gbYbPxBuTEnKCErwOz63F7v5MKhiWZxncmjVIjp5G8PhmJtrIwD0)tFKhE(QrGj5vm5r)tFpp9J)4uxK8GtrIwDuGE(yHi1vse8PhNkWKtXY7WipthCo4c0ZhlePUsIGp94uaoIutYZ74z6GZbxGE(yHi1vse8PhNci6PYbWWpMz8mDW5GlqpFSqK6kjc(0JtbePWy9xMEOFok((eCGE(yHi1vse8PhNAM(Txgp5uS6L55RgbMKxVZe1R3KtHf1seOxSPWqO)9gphba9kwVdYOdU3k1lm5uSi4ED5bHq9AJ617qzOEbeppyqOz63F7v5MKhiWZxncmjVIjp5G8PhmJtrIwD0)tFKhE(QrGj5vm5r)tFpp9J)4uxK8WZ0bNdUaeNclQLiqPQWqOaIEQCG)Y0d9ZrX3NGdqCkSOwIaLQcdH(YZ0bNdUaeNclQLiqPQWqOaIEQCaVBOmedWPirRokWZxncmjVIjpQz63Ez8KtXQxMNVAeysE9gptC9IjN)uV0h(cIa9kZEfd7GEJ(HMPF)TxLBsEGapF1iWK8kM8KdYNEWmofjA1r)p9rE45RgbMKxXKh9p9980p(JtDrYtnoNbu8Osol(5acfq0tLd8xMEm1rNfqXJk5S4Ndi03ACod88vJatYlaNdUMPF7LXtofREzE(QrGj517mr9QxV0hgs7ftoEuV5S3FkhqOELzV2i1lMC8OEZzV)uoGq9oiJo4E55J6nNZE5z6GZbxVQ1RJuG17q0lG45bd6TsZer9Y88vJatYR3bz0bhAM(93EvUj5bc88vJatYRyYtoiF6bZ4uKOvh9)0h5HNVAeysEftE0)03Zt)4po1fjp8mDW5GlGIhvYzXphqOaIEQCGpRX5mGIhvYzXphqOaCePMK3Fz6XuhDwafpQKZIFoGqFRX5mWZxncmjVaCo4(YZ0bNdUakEujNf)CaHci6PYb(CiyaofjA1rbE(QrGj5vm5rnt)2lJNCkw9Y88vJatYRxz2lJxaCX3jNIWQxMNVNEW9oiJo4EV06Ts9IifgRENjQxX6flYcnt)(BVk3K8abE(QrGj5vm5jhKp9GzCks0QJ(F6J8WZxncmjVIjp6F675PF8hN6IKhEMo4CWfQX5SalaU47Ktryv457PhCarpvoWFz6bfpAMiiuawaCX3jNIWQWZ3tp4V14CgGfax8DYPiSk8890doaNdUMPF7ftwf4EzSXrNb8(Ez8KtXQxMNVAeysE9otuVkmCVaFDWb6nN9Y46nr9(se1Rcdd61gvR3bIZ1RtbwVU8GqOETr96D4HOxaXZdge6fpJeG6fN6IeOxfrh2TEpItaGIehw9M(M8uxVY1R6C9Yvabcnt)(BVk3K8abE(QrGj5vm5jhKp9GzCks0QJ(F6J8WZxncmjVIjp6F675PF8hN6IKhKkWfchDwqHHbb5(ltpivGleo6SGcddc0hcWaFrQaxiC0zbfgge4z8m86HX9fPcCHWrNfuyyqaoIutYdVdpent)2lMSkW9YyJJod499IPDduSa9gbuVmpF1iWK86DGyJ9Il6ocPvXjgw9IubUxchDg4FVjocHeyQx9WQxyYPyb61jaJG7vRjoQxl79PEr9cIiQxX6fczGEJacU3rcrHMPF)TxLBsEGapF1iWK8kM8KdYNEWmofjA1r)p9rE45RgbMKxXKh9hN6IKhKkWfchDwax0DesRoki3pMzivGleo6SaUO7iKwDui6)xMEqQaxiC0zbCr3riT6Oa9HamWxCks0QJc88vJatYRGifgRIjpIbivGleo6SaUO7iKwDuqUMPF79hbOETrQ3J(W6L55RgbMKxV51lpthCo46vM9kwVdYOdU3lTERuV0h(e3i4ETSxyYPy1Rns9c4JeC0rW9Mh1BI61gPEb8rco6i4EZJ6DqgDW9oQ((01RJaGETr96DOmuVaINhmO3knte1Rns9ofiJwV0bdcnt)(BVk3K8abE(QrGj5vm5jhKp9GzCks0QJ(F6J8WZxncmjVIjp6po1fjp4uKOvhf45RgbMKxbrkmwftE0Fz6bNIeT6OapF1iWK8kisHXQyYJ(KNPdohCbE(QrGj5fGJi1K8(XyCyVdJmuGX8tgkm0FSPo6SWuqeWuKrim8Jn1rNf8soyNCqWad8GtrIwDuGNVAeysEftEe(4JtrIwDuGNVAeysEftEeENcKrRGONkhW7gkd1m9BVyAy4ETrQxEeHOZ61Kh1RL9AJuVa(ibhDeCVmpF1iWK861YE9JwVI1RC9Qvq6Ig1RjpQxq2RnQwVI1Ra6fyIZ1RY5rKAuV60iuVAVoXmh1RjpQxFfaiqOz63F7v5MKhiWZxncmjVIjp5G8PhmJtrIwD0)tFKhE(QrGj5vm5r)tFpkm8FCQlsEm5rnt)2ldlN6Cy9VxEE4iK17eLVE1kiDrJ61Kh1REW9cSer9AJuViYPMGJ61Kh1RC9ItrIwDuWKhvSSWZxncmjVqV)OZjEr9AJuVicy9MZETrQxU64rNAsEG)9oyu4J9oQ((01RJaGENi6NJ0zoS61YEb(eb3B0VxBK6fiVOtnjV)9AJcO3r13NoqV5C6DEtmNX3REW9oyuCuVCfyYbj0m97V9QCtYde45RgbMKxXKNCq(0dMXPirRo6FeqLColq4WEg(FeqLbJIJkCfyYbXZW)p9rEm5rfll88vJatY7po1fjpyeNIeT6OapF1iWK8kM8iVZKhHHFCnoNbE(QrGj5fGZbxZuZKYnjpqaL(f)rfqEMo9radjEr)LPhLBcoQqh9ecGxp4uKOvhfgtRamePEvMo9radjErFXynoNHX0kadrQxHOp(4xJZzykicyj6fI(yOzs5MKhiGs)I)OcOp9G5PGOQ6C)LPNACodWKAJ1eDui6)ffpAMiiuaMuBeuMQnMVV4uKOvhfm5rfll88vJatYJb14CgGj1gRj6OaIEQCGVk3eCuHo6jeaVEgAZKYnjpqaL(f)rfqF6bZ(yHYQtb2Fz6PgNZaiEfVKdcOuDeaihKcIuyScr)V14CgaXR4LCqaLQJaa5GuqKcJvarpvoaE5kWkM8OMjLBsEGak9l(JkG(0dM9XcLvNcS)Y0tnoNHPGiGLOxi63mPCtYdeqPFXFub0NEWSpwOS6uG9xMEQX5mmMwbyis9ke9BM(T3FeG6npQxgwquVyZPaRxsroS6vUEXKZFQxz2lwzSx48WU17OIJ6LeBKq9IjrQjhKE)r(9MOEXKsRxOgIuV6flY6vp4EjXgjK33lgvm07OIJ69LiQxBuVETbzVQdrkmw)7fJvm07OIJ6ft7Opagsbd5uSd6LHJiS6frkmw9AzVra9V3e1lg5yOxOKIKdsV4jJ8XEfqVk3eCuOxgFEy36fo71gfqVdgfh17OIG7LRatoi9YWo9radjErGEtuVdgPRxOXRxgdYbb7GEXMJaa5G0Ra6frkmwHMjLBsEGak9l(JkG(0dMNcIkvNcS)ravY5SaHd7z4)ravgmkoQWvGjhepd)xMEygofjA1rHPGOs1PaR4NPtoiFRX5maIxXl5GakvhbaYbPGifgRaCo4(QCtWrf6ONqagGtrIwDuyurWfUcSY0PpcyiXl6lZMcIaMImcfuUj4OVyKz14Cggj1Kdsj6hI(FzwnoNHX0kadrQxHO)xM5JiCLColq4WHPGOs1Pa7lgvUj5fMcIkvNcSaFurqiaE9mu8XhJM6OZcQJ(ayifmKtbLzeH1xEMo4CWfGrkK8aLkIuBmGifglmGp(asrYbPyzKpguUj4imGHMPF79hbOEzybr9InNcSEjXgjuVWrKCq6v7LHfevvNdZ)ewOS6uG1lxbwVdgPRxmjsn5G07pYVxb0RYnbh1BI6foIKdsV0hepAuVdeBSxOKIKdsV4jJ8XqZKYnjpqaL(f)rfqF6bZtbrLQtb2)iGk5CwGWH9m8)iGkdgfhv4kWKdINH)ltpmdNIeT6OWuquP6uGv8Z0jhKVmBkicykYiuq5MGJ(IrmIrLBsEHPGOQ6Cb6dIhn5G8fJk3K8ctbrv15c0hepAubrpvoadyOWqGp(mdfpAMiiuykicyj6Hb8Xx5MKxWhluwDkWc0hepAYb5lgvUj5f8XcLvNcSa9bXJgvq0tLdWagkme4JpZqXJMjccfMcIawIEyadFRX5mmsQjhKs0pe9Xa(4JraPi5GuSmYhdk3eC0xmwJZzyKutoiLOFi6)Lzk3K8caEI4Jb6dIhn5GGp(mRgNZWyAfGHi1Rq0)lZQX5mmsQjhKs0pe9)QCtYla4jIpgOpiE0KdYxMnMwbyis9Qa8jNduKRmDcKrddyadntk3K8abu6x8hva9PhmZvNROCtYR4eG9)0h5r5MGJkM6OZantk3K8abu6x8hva9Phm7JfkRofy)LPNACod(yHsUtbVq0)lxbwXKhXGACod(yHsUtbVaIEQCGVCfyftEedQX5mGIhvYzXphqOaIEQCGMjLBsEGak9l(JkG(0dM9XcLvNcS)Y0tnoNHX0kadrQxHO)xaPi5GuSmYhdk3eC0xLBcoQqh9ecWaCks0QJcJPvagIuVktN(iGHeVOMjLBsEGak9l(JkG(0dM9ht6KpktN(iWFz6Hz4uKOvhf8ht6Kpk(z6KdY3ACodJKAYbPe9dr)VmRgNZWyAfGHi1Rq0)lgvUj4OcCAbbYjgXGHIp(k3eCuHo6jeaVEWPirRokmQi4cxbwz60hbmK4fHp(k3eCuHo6jeaVEWPirRokmMwbyis9QmD6Jags8IWqZKYnjpqaL(f)rfqF6bZaEI4J)LPhaPi5GuSmYhdk3eCuZKYnjpqaL(f)rfqF6bZWifsEGsfrQn(xMEuUj4OcD0tiaEhAZKYnjpqaL(f)rfqF6bZkIRhvOp8DjqY7Vm9OCtWrf6ONqa86bNIeT6OGI46rf6dFxcK8((0td(CdVEWPirRokOiUEuH(W3LajVYtp9RPiiKfgi2OCdZqnt)2lMQyJ9sxgHm2RPiiKb(3Ry9kGE1EHOY1RL9YvG1ld70hbmK4f1Rc6DkohH6voGrkCV5SxgwquvDUqZKYnjpqaL(f)rfqF6bZtN(iGHeVO)Y0JYnbhvOJEcbWRhCks0QJcJkcUWvGvMo9radjErntk3K8abu6x8hva9PhmpfevvNRzQzs5MKhiam9GveCbLMAsEEMo9radjEr)LPhLBcoQqh9ecGxp4uKOvhfgtRamePEvMo9radjErFXynoNHX0kadrQxHOp(4xJZzykicyj6fI(yOzs5MKhiam9GveCbLMAsEF6bZtbrv15(ltp14CgGj1gRj6Oq0)lkE0mrqOamP2iOmvBmFFXPirRokyYJkww45RgbMKhdQX5matQnwt0rbe9u5aFRX5matQnwt0rbe9u5a41ZqBMuUj5bcatpyfbxqPPMK3NEWSpwOS6uG9xMEQX5mmfebSe9cr)MjLBsEGaW0dwrWfuAQj59Phm7JfkRofy)LPNACodJPvagIuVcr)V14CggtRamePEfq0tLdWaLBsEHPGOQ6Cb6dIhnQyYJAMuUj5bcatpyfbxqPPMK3NEWSpwOS6uG9xMEQX5mmMwbyis9ke9)IrFeHRaHdhgomfevvNdF8NcIaMImcfuUj4i8Xx5MKxWhluwDkWcYvMobYOHHMPF7fpiS61YEHqwVqzmGTE9rjh0RCabM6fto)PE9hvab6nr9Y88vJatYRx)rfqGEhmsxV(jaivhfAMuUj5bcatpyfbxqPPMK3NEWSpwOS6uG9xMEQX5maIxXl5GakvhbaYbPGifgRq0)lg5z6GZbxafpQKZIFoGqbe9u5aFQCtYlGIhvYzXphqOa9bXJgvm5rFYvGvm5r4TgNZaiEfVKdcOuDeaihKcIuySci6PYbWhFMzQJolGIhvYzXphqim8fNIeT6OGjpQyzHNVAeysEFYvGvm5r4TgNZaiEfVKdcOuDeaihKcIuySci6PYbAMuUj5bcatpyfbxqPPMK3NEWSpwOS6uG9xMEQX5mmMwbyis9ke9)cifjhKILr(yq5MGJAMuUj5bcatpyfbxqPPMK3NEWSpwOS6uG9xMEQX5m4Jfk5of8cr)VCfyftEedQX5m4Jfk5of8ci6PYbAM(TxgFejhKETrQxGPhSIG7fLMAsE)7nphw9gbuVmSGOEXMtbgO3bJ01Rnsy1RIOEV06TsYbPx)mDeCVZe1lMC(t9MOEzE(QrGj5f69hbOEzybr9InNcSEjXgjuVWrKCq6v7LHfevvNdZ)ewOS6uG1lxbwVdgPRxmjsn5G07pYVxb0RYnbh1BI6foIKdsV0hepAuVdeBSxOKIKdsV4jJ8XqZKYnjpqay6bRi4ckn1K8(0dMNcIkvNcS)ravY5SaHd7z4)ravgmkoQWvGjhepd)xMEy2uqeWuKrOGYnbh9Lz4uKOvhfMcIkvNcSIFMo5G8fJyeJk3K8ctbrv15c0hepAYb5lgvUj5fMcIQQZfOpiE0OcIEQCagWqHHaF8zgkE0mrqOWuqeWs0dd4JVYnjVGpwOS6uGfOpiE0KdYxmQCtYl4JfkRofyb6dIhnQGONkhGbmuyiWhFMHIhnteekmfebSe9Wag(wJZzyKutoiLOFi6Jb8XhJasrYbPyzKpguUj4OVySgNZWiPMCqkr)q0)lZuUj5fa8eXhd0hepAYbbF8zwnoNHX0kadrQxHO)xMvJZzyKutoiLOFi6)v5MKxaWteFmqFq8OjhKVmBmTcWqK6vb4tohOixz6eiJggWagAMuUj5bcatpyfbxqPPMK3NEWSpwOS6uG9xMEQX5mmMwbyis9ke9)QCtWrf6ONqagGtrIwDuymTcWqK6vz60hbmK4f1mPCtYdeaMEWkcUGstnjVp9Gz)XKo5JY0Ppc8xMEygofjA1rb)XKo5JIFMo5G8fJmZuhDwyIYxXgPIcgja(4RCtWrf6ONqa8omg(IrLBcoQaNwqGCIrmyO4JVYnbhvOJEcbWRhCks0QJcJkcUWvGvMo9radjEr4JVYnbhvOJEcbWRhCks0QJcJPvagIuVktN(iGHeVim0mPCtYdeaMEWkcUGstnjVp9GzU6CfLBsEfNaS)N(ipk3eCuXuhDgOzs5MKhiam9GveCbLMAsEF6bZWifsEGsfrQn(xMEuUj4OcD0tiaEhUzs5MKhiam9GveCbLMAsEF6bZaEI4J)LPhaPi5GuSmYhdk3eCuZKYnjpqay6bRi4ckn1K8(0dMvexpQqF47sGK3Fz6r5MGJk0rpHa41dofjA1rbfX1Jk0h(Uei599PNg85gE9GtrIwDuqrC9Oc9HVlbsELNE6xtrqilmqSr5gMHAM(TxmvXg7LUmczSxtrqid8VxX6va9Q9crLRxl7LRaRxg2PpcyiXlQxf07uCoc1RCaJu4EZzVmSGOQ6CHMjLBsEGaW0dwrWfuAQj59PhmpD6Jags8I(ltpk3eCuHo6jeaVEWPirRokmQi4cxbwz60hbmK4f1mPCtYdeaMEWkcUGstnjVp9G5PGOQ6CSgRXYc]] )
end
