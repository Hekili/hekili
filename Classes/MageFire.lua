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
    -- actions.precombat+=/variable,name=firestarter_combustion,if=variable.firestarter_combustion<0,value=1*!talent.pyroclasm,value_else=-1
    spec:RegisterVariable( "firestarter_combustion", function ()
        if not talent.pyroclasm.enabled then return 1 end
        return -1
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes outside of Combustion should be used.
    -- actions.precombat+=/variable,name=hot_streak_flamestrike,op=set,if=variable.hot_streak_flamestrike=0,value=2*talent.flame_patch+3*!talent.flame_patch
    spec:RegisterVariable( "hot_streak_flamestrike", function ()
        if talent.flame_patch.enabled then return 2 end
        return 3
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Hard Cast Flamestrikes outside of Combustion should be used as filler.
    -- actions.precombat+=/variable,name=hard_cast_flamestrike,op=set,if=variable.hard_cast_flamestrike=0,value=2*talent.flame_patch+3*!talent.flame_patch
    spec:RegisterVariable( "hard_cast_flamestrike", function ()
        if talent.flame_patch.enabled then return 2 end
        return 3
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes are used during Combustion.
    -- actions.precombat+=/variable,name=combustion_flamestrike,op=set,if=variable.combustion_flamestrike=0,value=3*talent.flame_patch+6*!talent.flame_patch
    spec:RegisterVariable( "combustion_flamestrike", function ()
        if talent.flame_patch.enabled then return 3 end
        return 6
    end )

    -- # APL Variable Option: This variable specifies the number of targets at which Arcane Explosion outside of Combustion should be used.
    -- actions.precombat+=/variable,name=arcane_explosion,op=set,if=variable.arcane_explosion=0,value=99*talent.flame_patch+2*!talent.flame_patch
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
    -- actions.precombat+=/variable,name=combustion_on_use,op=set,value=equipped.gladiators_badge|equipped.macabre_sheet_music|equipped.inscrutable_quantum_device|equipped.sunblood_amethyst|equipped.empyreal_ordnance|equipped.flame_of_battle|equipped.wakeners_frond|equipped.instructors_divine_bell
    spec:RegisterVariable( "combustion_on_use", function ()
        return equipped.gladiators_badge or equipped.macabre_sheet_music or equipped.inscrutable_quantum_device or equipped.sunblood_amethyst or equipped.empyreal_ordnance or equipped.flame_of_battle or equipped.wakeners_frond or equipped.instructors_divine_bell
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

        -- # Delay Combustion for Deathborne.
        -- actions.combustion_timing+=/variable,name=combustion_time,op=max,value=cooldown.deathborne.remains,if=covenant.necrolord&cooldown.deathborne.remains-10<variable.combustion_time
        if covenant.necrolord and cooldown.deathborne.remains - 10 < value then
            value = max( value, cooldown.deathborne.remains )
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
        value = value + time

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


    spec:RegisterPack( "Fire", 20210413, [[dav18cqiOOEKqsDjvjvTjH4tQs1Ouf5uQIAvOej9kOqZsi1TGsIDrYVqHmmOK6yOuTmrv5zIQQMMqs6AOe12qHQ6BOqvghkr4CcjK1jKO5bL4EIk7dk4GcjXcvLYdvLKjQkP4IQsQyJOe8ruIOrcLKCsHeSsukVeLiXmfvvUjkrQDQkXprHkAOOeQLcLK6Pc1uHICvvjL2QQKk9vuOsJffk7fWFj1Gv5WuTyf9yunzO6YiBwHpRQA0QkNMy1cjuVgL0SfCBG2Ts)wYWfLJJsilh0ZHmDkxxKTJI(UQW4fv58OG1Jcvy(qP2VudWoaMaIXDJaEjFyD(yhRJQSN)Q8XowhvZhJpqSXqgbeN5Cw9FciEDqciMfeibeN5mekhhataXOkb5eq8NzzOOKrm6xSV0uXlqgHeWuWnPwo0hgJqciNraXZKeSOWcmbIXDJaEjFyD(yhRJQSN)Q8XowN)5F(de7j7RGaXXc4RaI)eCCAbMaX4eIdeZccK6JL2)P(EcRYH48cNWFUz7ZSmuuYig9l2xAQ4fiJqcyk4Mulh6dJribKZOMTOsguc9XE(hDF5dRZh7nBnBV6Z3FcfLnByL(ETiQVH8)zAib6YI6d62hb7Z(8TpZH)KPmbK0wPXfQVrb7l4idRGiET495tjigd9Lq(pHunByL(YVQq02h3rwFqIfLeibsRH6BuW(EvbotitQTVNefPIUp8AF367Rc49jwFJc2N33asOV(yPjJkyFChzpRA2Wk996S(mq9HmOWT(4FeNvz)7R2(8(g0J(gfKvuFY2N9r9fvyX5xFw1hKWtCQVhfK1q54QMnSsFrf8O4eY6Z7JfZaSMbhz9rRbzOp7ZT(Wlc13wwFGfof67bfc9jlw53bP(EcjG9zeYi8(CRVT6dj)RmeUVwFVgwCCFcyMZTNvnByL(EvTmjO1Nhc9ntJHIXuqY5wF0AqHq9zvFZ0yOymvkl6(8TppawiRpzrY)kdH7R13RHfh33VlBFY2hsarkG4GGmeaMaIHvMo7ZreaMaEHDambetRpdeoWBaXCOyeuCGyNBctstlbkeQpmKRpMou8zGuFLPrgKCw1JGdsidkSs9fPVN6BMgd1xzAKbjNvvkRpSXUVzAmudbsiRGGQuwFpde7CtQfiEeCqczqHvcWaEjFayciMwFgiCG3aI5qXiO4aXZ0yOqPvZQS)i9mqiKS)Ai54mOsz9fPVzAmuO0Qzv2FKEgies2FnKCCguqc0Lf1hg6J7itBcibe7CtQfioJbyndoYamGxYFambetRpdeoWBaXCOyeuCG4zAmudbsiRGGQugqSZnPwG4mgG1m4idWaEjQcGjGyA9zGWbEdiMdfJGIdeptJH6RmnYGKZQkLbe7CtQfioJbyndoYamGxyzambetRpdeoWBaXjePF8jbsZDKj7pWlSdeZHIrqXbIXCFmDO4ZaPgcK0ZGJmDwvbz)7lsFZ0yOqPvZQS)i9mqiKS)Ai54mOWRhBFr6Z5MWK00sGcH6dl9X0HIpdK6ZH4AUJm9i4GeYGcRuFr6dZ9neiHmhAeu5Ctys9fPVN6dZ9ntJH6JCt2FDktLY6lsFyUVzAmuFLPrgKCwvPS(I0hM7ldsm11yO)54QHaj9m4iRVi99uFo3KAvdbs6zWrMI)5WFc1hgY1x(6dBS77P(mpqRP8aLhYGoIXHJ0JeKbfT(mq49fPpEvb86XQWH(FTi9esU9PGKJZqFp3h2y3hICOS)ARs8pLZnHj13Z99mqCcr6Am0)CCGxyhi25Mulq8qGKEgCKbeJtiouYmPwG4xlI6RwQpwqGuFVfCK1h5Wad9jBFy1flUpz0hdvQp8AF367Zzs9rI9rW(WQi3K9VVxBwFfSpSQY6l2GKZAFmqwF(I3hj2hbJY(EYFUVpNj1hybP(SpF7ZEu95bi54meDFpnFUVpNj1xujq5HmOJyC4VJ6Jfsqg6dsood9zvFjefDFfSVN4p3xm5qz)7dtvI)1NG6Z5MWKu99AQ9DRp8Qp7tq994tcuFFoeVpUJmz)7JfcoiHmOWkH6RG994J2(ItBFSuK9)DuFVfies2)(euFqYXzqbyaVW4dGjGyA9zGWbEdioHi9JpjqAUJmz)bEHDGyoumckoqmM7JPdfFgi1qGKEgCKPZQki7FFr6dZ9neiHmhAeu5Ctys9fPVN67P(EQpNBsTQHaPPhckkpINmz)7lsFp1NZnPw1qG00dbfLhXtgPHeOllQpS0hwRy5(Wg7(WCFW0sJc(tQHajKvqqfT(mq499CFyJDFo3KAvzmaRzWrMIYJ4jt2)(I03t95CtQvLXaSMbhzkkpINmsdjqxwuFyPpSwXY9Hn29H5(GPLgf8NudbsiRGGkA9zGW775(EUVi9ntJH6JCt2FDktLY675(Wg7(EQpe5qz)1wL4FkNBctQVi99uFZ0yO(i3K9xNYuPS(I0hM7Z5MuRcXli)tr5r8Kj7FFyJDFyUVzAmuFLPrgKCwvPS(I0hM7BMgd1h5MS)6uMkL1xK(CUj1Qq8cY)uuEepzY(3xK(WCFFLPrgKCw1OmkeqAz1JG8)z99CFp33ZaXjePRXq)ZXbEHDGyNBsTaXdbs6zWrgqmoH4qjZKAbIFTiQpwqGuFVfCK1hj2hb7dpbL9VpVpwqG00dbgXIzawZGJS(4oY67XhT9HvrUj7FFV2S(euFo3eMuFfSp8eu2)(O8iEYO(Ei2xFXKdL9Vpmvj(NcWaEHXdataX06ZaHd8gqSZnPwGyUhcANBsT6GGmG4GGm96GeqSZnHjPnpqRHamGxyjaWeqmT(mq4aVbeZHIrqXbINPXqLXaS4bhbQsz9fPpUJmTjGuFyPVzAmuzmalEWrGkib6YI6lsFChzAtaP(WsFZ0yOGPL01qNvpiOcsGUSiGyNBsTaXzmaRzWrgGb8sueaMaIP1Nbch4nGyoumckoq8mngQVY0idsoRQuwFr6drou2FTvj(NY5MWK6lsFo3eMKMwcuiuFyPpMou8zGuFLPrgKCw1JGdsidkSsaXo3KAbIZyawZGJmad4f2XAambetRpdeoWBaXCOyeuCGym3hthk(mqQSVIwjpDwvbz)7lsFZ0yO(i3K9xNYuPS(I0hM7BMgd1xzAKbjNvvkRVi99uFo3eMKgVmL8VIr9HL(YxFyJDFo3eMKMwcuiuFyixFmDO4ZaP(CiUM7itpcoiHmOWk1h2y3NZnHjPPLafc1hgY1hthk(mqQVY0idsoR6rWbjKbfwP(Egi25MulqC2xrRKNEeCqcbyaVWo7ayciMwFgiCG3aI5qXiO4aXiYHY(RTkX)uo3eMeqSZnPwGyeVG8pad4f2ZhaMaIP1Nbch4nGyoumckoqSZnHjPPLafc1hg6lFaXo3KAbIXH(FTi9esU9byaVWE(dGjGyA9zGWbEdiMdfJGIde7CtysAAjqHq9HHC9X0HIpdKYHCFjnLxwOqsT9fPpqFDvg36dd56JPdfFgiLd5(sAkVSqHKA1G(69fPpZH)KPEi2NSSJ1aXo3KAbIDi3xst5LfkKulGb8c7rvambetRpdeoWBaXo3KAbIhbhKqguyLaIXjehkzMulqmJRyF9rBL()6ZC4pzOO7tS(euFEF)US9zvFChz9XcbhKqguyL6Zr9nKqGG9jlYihVVA0hliqA6HGciMdfJGIde7CtysAAjqHq9HHC9X0HIpdK6ZH4AUJm9i4GeYGcReGb8c7SmaMaIDUj1cepein9qaiMwFgiCG3amadigNgEkyayc4f2bWeqmT(mq4aVbeZHIrqXbIXCFW0sJc(tkCbXLSGSoKbnVab9fxrRpdeoqSZnPwGyELwJGOmkeamGxYhaMaIP1Nbch4nGyoumckoq8mngkEbotitQvHxp2(I0NZnPw1qGKEgCKP4Fo8Nq9HLC9XEFr6dZ99uFZ0yOKDqW1dAUJ4ooPsz9fPVzAmuFLPrgKCwvqY5wFp3xK(y6qXNbsH(KHj7VoREqq9KgfK08cCMqMulqSZnPwGy0Nmmz)1z1dccyaVK)ayciMwFgiCG3aI5qXiO4aXZ0yO4f4mHmPwfE9y7lsFp1hthk(mqktajTvAEbotitQTpS0hthk(mqkEbotitQvNbjUJmTjGuFySpkpINmsBci1h2y3hthk(mqktajTvAEbotitQTpm0NZnPwnVQaE9y7dR0h7yDFpde7CtQfig64IVMgL5qwbmGxIQayciMwFgiCG3aI5qXiO4aXZ0yO4f4mHmPwfE9y7lsFZ0yOGPL01qNvpiOcVES9fPpMou8zGuMasAR08cCMqMuBFyPpMou8zGu8cCMqMuRodsChzAtaP(WyFuEepzK2eqci25Mulqmo523SGlbyaVWYayciMwFgiCG3aI5qXiO4aXmDO4ZaPmbK0wP5f4mHmP2(WsFmDO4ZaP4f4mHmPwDgK4oY0Mas9HX(O8iEYiTjGuFr6BMgdfVaNjKj1QWRhlqSZnPwGyqbclisxdTvqqAnad4fgFambetRpdeoWBaXjePF8jbsZDKj7pWlSdeJtiouYmPwGywOG996sR9Xam6(siQpVpwqGuFVfCK1h)ZH)uF4jOS)9Xslqybr9vJ(WubbP16J7iRpR6ZzwcEFCplt2)(4Fo8NqkGyNBsTaXdbs6zWrgqmhkgbfhi25MuRcuGWcI01qBfeKwtr5r8Kj7FFr6BKcbnK4Fo8N0Mas9Hv6Z5MuRcuGWcI01qBfeKwtr5r8KrAib6YI6dl9fv7lsFyUVVY0idsoRAugfciTS6rq()S(I0hM7BMgd1xzAKbjNvvkdWaEHXdataX06ZaHd8gqSZnPwG4)GJlUvqKE64)eqmhkgbfhiMPdfFgiLjGK2knVaNjKj12hg6Z5MuRMxvaVES9Hv6JLbIPXG4MEDqci(p44IBfePNo(pbyaVWsaGjGyA9zGWbEdi25MulqmbMXaK8GUG4RVCciMdfJGIdeZ0HIpdKYeqsBLMxGZeYKA7dl56JPdfFgifbMXaK8GUG4RVCsJtbNH(I0hthk(mqktajTvAEbotitQTpm0hthk(mqkcmJbi5bDbXxF5KgNcod9Hv6JLbIxhKaIjWmgGKh0feF9LtagWlrrayciMwFgiCG3aIDUj1ce)hyi7txdTJqcOeCtQfiMdfJGIdeZ0HIpdKYeqsBLMxGZeYKA7dd56JPdfFgivT6eI08KvJbq86Geq8FGHSpDn0ocjGsWnPwad4f2XAambetRpdeoWBaXo3KAbIbDUpHKg9rKPbtiHdeZHIrqXbIz6qXNbszciPTsZlWzczsT9HLC9XYaXRdsaXGo3NqsJ(iY0GjKWbmGxyNDambetRpdeoWBaX4eIdLmtQfiokm6lHK9VpVpKrWsW7RwSscr9jgbgDFE4HZaQVeI671ajhFiqQVxxcHOqFvYqco1xn67vf4mHmPwvFmoTpc(qqu09LbLckMW4G6lHK9VVxdKC8HaP(EDjeIc99qSV(EvbotitQTVAdm0Nm6lkSdcUEOVx5iUJt9jO(O1NbcVpFX7Z7lH8FQVh1(U13K6luiRVIjb7Z(O(Wtq3KA7Rg9zFuFd5)Zu9HPpb1NJJJ6Z7db6HqFm9qI6ZQ(SpQpEvb86X2xn671ajhFiqQVxxcHOqFp(OTp8s2)(Spb1h3d8uWnP2(Me3tiQpX6tq9Lwi5bKj8(SQphHsGuF2NB9jwFpKqOVj1xcr49LrWbXTad9vBF8Qc41JvbeVoibeJdjhFiqsZKqikaeZHIrqXbIz6qXNbszciPTsZlWzczsT9HHC9X0HIpdKQwDcrAEYQXOVi99uFZ0yOKDqW1dAUJ4ooPqMZzTVC9ntJHs2bbxpO5oI74Kc0ZtJmNZAFyJDFyUpET4jXuYoi46bn3rChNu06ZaH3h2y3hthk(mqkEbotitQvxRoHO(Wg7(y6qXNbszciPTsZlWzczsT9HH(K1iywfCJW1d5)Z0qc0Lf13RVV(EQpNBsTAEvb86X2hg7JDSUVN77zGyNBsTaX4qYXhcK0mjeIcagWlSNpambetRpdeoWBaXo3KAbIrvkOL)vmcceZHIrqXbIFQpMou8zGuMasAR08cCMqMuBFyixF5pw3hl1(EQpMou8zGu1QtisZtwng9HH(W6(EUpSXUVN6dZ9zqzzLmLXUsqkuLcA5FfJG9fPpdklRKPm2vjKpduFr6ZGYYkzkJDfVQaE9yvqc0Lf1h2y3hM7ZGYYkzklFkbPqvkOL)vmc2xK(mOSSsMYYNkH8zG6lsFguwwjtz5tXRkGxpwfKaDzr99CFp3xK(EQpm3hXIsswgHRWHKJpeiPzsief6dBS7JxvaVESkCi54dbsAMecrbD(hvJIyjyzgpfKaDzr9HH(y5(EgiEDqcigvPGw(xXiiGb8c75paMaIP1Nbch4nGyNBsTaXCF5uqptJbqmhkgbfhigZ9XRfpjMs2bbxpO5oI74KIwFgi8(I0NjGuFyPpwUpSXUVzAmuYoi46bn3rChNuiZ5S2xU(MPXqj7GGRh0ChXDCsb65PrMZzfiEMgd96GeqmQsbT8VIj1ceJtiouYmPwGymbL)Fc2xCLc9ff(xXiyFKddm03dX(6lkSdcUEOVx5iUJt9vW(E8rBFI13dh1xgK4oYuagWlShvbWeqmT(mq4aVbeJtiouYmPwG4OGrGO(Sp36dV6BlRVjT0qS(EvbotitQTp0xLc49ffNqwFtQVeIW7RsgsWP(QrFVQaNjKj12NB9HkqQVSswtbeVoibellIdtMpdKMfL81sGACIPWjGyoumckoqmXIsswgHR(doU4wbr6PJ)t9fPpMou8zGuMasAR08cCMqMuBFyixFmDO4ZaPQvNqKMNSAmaIDUj1cellIdtMpdKMfL81sGACIPWjad4f2zzambetRpdeoWBaXo3KAbIhbhK01qpDZceqmhkgbfhiMyrjjlJWv)bhxCRGi90X)P(I0hthk(mqktajTvAEbotitQTpmKRpMou8zGu1QtisZtwngaXRdsaXJGds6AONUzbcWaEHDgFambetRpdeoWBaXo3KAbIF4Sslbr6bSwCGyoumckoqmXIsswgHR(doU4wbr6PJ)t9fPpMou8zGuMasAR08cCMqMuBFyixFmDO4ZaPQvNqKMNSAmaIxhKaIF4Sslbr6bSwCad4f2z8aWeqmT(mq4aVbe7CtQfiwwKbtCRGinUWuwspPqaiMdfJGIdetSOKKLr4Q)GJlUvqKE64)uFr6JPdfFgiLjGK2knVaNjKj12hgY1hthk(mqQA1jeP5jRgdG41bjGyzrgmXTcI04ctzj9Kcbad4f2zjaWeqmT(mq4aVbe7CtQfigL2zOkCTds2hdidiMdfJGIdetSOKKLr4Q)GJlUvqKE64)uFr6JPdfFgiLjGK2knVaNjKj12hgY1hthk(mqQA1jeP5jRgdG41bjGyuANHQW1oizFmGmad4f2JIaWeqmT(mq4aVbeZHIrqXbIz6qXNbszciPTsZlWzczsT9HHC9X0HIpdKQwDcrAEYQXai25MulqCcrAXiqeGb8s(WAambetRpdeoWBaXo3KAbIhWcz6Ty6aX4eIdLmtQfi(1IO(ybyHS(EPy69zvFgu()jyFSKqbfyOVOax4bsbeZHIrqXbIHPLgf8Nu)qbfyqlCHhifT(mq49fPVzAmu8cCMqMuRcVES9fPVN6JPdfFgiLjGK2knVaNjKj12hg6Z5MuRMxvaVES9Hn29X0HIpdKYeqsBLMxGZeYKA7dl9X0HIpdKIxGZeYKA1zqI7itBci1hg7JYJ4jJ0Mas99mGb8s(yhataX06ZaHd8gqSZnPwGyELwJGOmkeaIXjehkzMulqmljz9zFuFVgbXLSGSoKH(Evbc6lEFZ0y0xkl6(sBGqO(4f4mHmP2(euFOQwfqmhkgbfhigMwAuWFsHliUKfK1HmO5fiOV4kA9zGW7lsF8Qc41JvntJHgxqCjliRdzqZlqqFXvqc0Lf1hw6Z5MuRAalKnRGP4oY0Mas9fPVzAmu4cIlzbzDidAEbc6lU2HCFjfE9y7lsFyUVzAmu4cIlzbzDidAEbc6lUkL1xK(EQpMou8zGuMasAR08cCMqMuBFySpNBsTQbSq2ScMI7itBci1hg6JxvaVESQzAm04cIlzbzDidAEbc6lUcpbDtQTpSXUpMou8zGuMasAR08cCMqMuBFyPpwUVNbmGxYx(aWeqmT(mq4aVbeZHIrqXbIHPLgf8Nu4cIlzbzDidAEbc6lUIwFgi8(I0hVQaE9yvZ0yOXfexYcY6qg08ce0xCfKaDzr9HL(O8iEYiTjGuFySpNBsTQbSq2ScMI7itBci1xK(MPXqHliUKfK1HmO5fiOV4AhY9Lu41JTVi9H5(MPXqHliUKfK1HmO5fiOV4QuwFr67P(y6qXNbszciPTsZlWzczsT9HX(O8iEYiTjGuFySpNBsTQbSq2ScMI7itBci1hg6JxvaVESQzAm04cIlzbzDidAEbc6lUcpbDtQTpSXUpMou8zGuMasAR08cCMqMuBFyPpwUVi9H5(mpqRPGPL01qNvpiOIwFgi8(Egi25MulqSd5(sAkVSqHKAbmGxYx(dGjGyA9zGWbEdiMdfJGIdedtlnk4pPWfexYcY6qg08ce0xCfT(mq49fPpEvb86XQMPXqJliUKfK1HmO5fiOV4kib6YI6dl9XDKPnbK6lsFZ0yOWfexYcY6qg08ce0xC9awitHxp2(I0hM7BMgdfUG4swqwhYGMxGG(IRsz9fPVN6JPdfFgiLjGK2knVaNjKj12hg7J7itBci1hg6JxvaVESQzAm04cIlzbzDidAEbc6lUcpbDtQTpSXUpMou8zGuMasAR08cCMqMuBFyPpwUVNbIDUj1cepGfYMvWamGxYxufataX06ZaHd8gqmhkgbfhigMwAuWFsHliUKfK1HmO5fiOV4kA9zGW7lsF8Qc41JvntJHgxqCjliRdzqZlqqFXvqYXzOVi9ntJHcxqCjliRdzqZlqqFX1dyHmfE9y7lsFyUVzAmu4cIlzbzDidAEbc6lUkL1xK(EQpMou8zGuMasAR08cCMqMuBFyOpEvb86XQMPXqJliUKfK1HmO5fiOV4k8e0nP2(Wg7(y6qXNbszciPTsZlWzczsT9HL(y5(Egi25Mulq8awitVfthWaEjFSmaMaIP1Nbch4nGyoumckoqmthk(mqktajTvAEbotitQTpSKRpSUpSXUpMou8zGuMasAR08cCMqMuBFyPpMou8zGu8cCMqMuRodsChzAtaP(I0hVQaE9yv8cCMqMuRcsGUSO(WsFmDO4ZaP4f4mHmPwDgK4oY0MasaXo3KAbI5EiODUj1QdcYaIdcY0RdsaX8cCMqMuRo7ZreGb8s(y8bWeqmT(mq4aVbeZHIrqXbINPXqbtlPRHoREqqfE9y7lsFyUVzAmudbsiRGGQuwFr67P(y6qXNbszciPTsZlWzczsT9HHC9ntJHcMwsxdDw9GGk8e0nP2(I0hthk(mqktajTvAEbotitQTpm0NZnPw1qGKEgCKPgPqqdj(Nd)jTjGuFyJDFmDO4ZaPmbK0wP5f4mHmP2(WqFd5)Z0qc0Lf13ZaXo3KAbIHPL01qNvpiiGb8s(y8aWeqmT(mq4aVbexzaXiYaIDUj1ceZ0HIpdeqmoH4qjZKAbIzXvf6Zr9b6ld9XccK67TGJmuFoQVScHKzG6BuW(EvbotitQv1xCAAqNB9vjRVA0N9r9nGo3KA9qF8cmRwAT(QrF2h13MaNeSVA0hliqQV3coYq9zFU13dje6BDlb9qGH(Ge)ZH)uF4jOS)9zFuFVQaNjKj12x2NJO(Me3tiQVSQcY(3NVmyFY(3xMJS(Sp367Hec9TL13p0xRpF7JYZGEFSGaP(El4iRp8eu2)(EvbotitQvbeZ0djci25MuRAiqspdoYu8ph(ti9a6CtQ1d9HX(EQpMou8zGuMasAR08cCMqMuBFySpNBsTk0Nmmz)1z1dcQgPqqdj8e3KA7JLAFmDO4ZaPqFYWK9xNvpiOEsJcsAEbotitQTVN7Jr9XRkGxpw1qGKEgCKPWtq3KA7dR0h79HL(4vfWRhRAiqspdoYuGEEA(Nd)juFySpMou8zGuftcMvvqpeiPNbhzO(yuF8Qc41JvneiPNbhzk8e0nP2(Wk99uFZ0yO4f4mHmPwfEc6MuBFmQpEvb86XQgcK0ZGJmfEc6MuBFp3xFV((yVVi9X0HIpdKYeqsBLMxGZeYKA7dl9nK)ptdjqxweqCcr6Am0)CCGxyhiMPd1RdsaXdbs6zWrMoRQGS)aXjePF8jbsZDKj7pWlSdyaVKpwcambetRpdeoWBaXCOyeuCG4zAmuW0s6AOZQheuLY6lsFmDO4ZaPmbK0wP5f4mHmP2(WqFynqmYGc3aEHDGyNBsTaXCpe0o3KA1bbzaXbbz61bjGyyLPZ(CebyaVKVOiambetRpdeoWBaXjePF8jbsZDKj7pWlSdeJtiouYmPwG4OcEuCcz9zFuFmDO4Za1N95wF8Anyfq9XccK67TGJS(si)N6ZQ(OfLGuFIH6J)5WFc1NdP(8aQ6lRQaH33OG9HvNwQVA0hlUEqqfqCLbeJidiMdfJGIdeJ5(y6qXNbsneiPNbhz6SQcY(3xK(mpqRPGPL01qNvpiOIwFgi8(I03mngkyAjDn0z1dcQWRhlqmtpKiGyEvb86XQGPL01qNvpiOcsGUSO(WsFo3KAvdbs6zWrMAKcbnK4Fo8N0Mas9Hv6Z5MuRc9jdt2FDw9GGQrke0qcpXnP2(yP23t9X0HIpdKc9jdt2FDw9GG6jnkiP5f4mHmP2(I0hVQaE9yvOpzyY(RZQheubjqxwuFyPpEvb86XQGPL01qNvpiOcsGUSO(EUVi9XRkGxpwfmTKUg6S6bbvqc0Lf1hw6Bi)FMgsGUSiG4eI01yO)54aVWoqSZnPwGyMou8zGaIz6q96Geq8qGKEgCKPZQki7pGb8s(J1ayciMwFgiCG3aItis)4tcKM7it2FGxyhiMdfJGIdeJ5(y6qXNbsneiPNbhz6SQcY(3xK(y6qXNbszciPTsZlWzczsT9HH(W6(I0NZnHjPPLafc1hgY1hthk(mqQphIR5oY0JGdsidkSs9fPpm33qGeYCOrqLZnHj1xK(WCFZ0yO(ktJmi5SQsz9fPVN6BMgd1h5MS)6uMkL1xK(CUj1QgbhKqguyLuuEepzKgsGUSO(WsFyTIL7dBS7J)5WFcPhqNBsTEOpmKRV813ZaXjePRXq)ZXbEHDGyNBsTaXdbs6zWrgqmoH4qjZKAbIzC)OTpSkhIZDKj7FFSqWbP(InOWkfDFSGaP(El4id1h6Rsb8(MuFjeH3Nv99tlbDJ6dRQS(Ini5SI6Zx8(SQpkpJw8(El4iJG9Xs7iJGkad4L8NDambetRpdeoWBaXjePF8jbsZDKj7pWlSdeZHIrqXbIhcKqMdncQCUjmP(I0h)ZH)eQpmKRp27lsFyUpMou8zGudbs6zWrMoRQGS)9fPVN6dZ95CtQvnein9qqr5r8Kj7FFr6dZ95CtQvLXaSMbhzkz1JG8)z9fPVzAmuFKBY(RtzQuwFyJDFo3KAvdbstpeuuEepzY(3xK(WCFZ0yO(ktJmi5SQsz9Hn295CtQvLXaSMbhzkz1JG8)z9fPVzAmuFKBY(RtzQuwFr6dZ9ntJH6RmnYGKZQkL13ZaXjePRXq)ZXbEHDGyNBsTaXdbs6zWrgqmoH4qjZKAbIFnjOS)9XccKqMdncgDFSGaP(El4id1NdP(sicVpKakbhgyOpR6dpbL9VVxvGZeYKAv9Xsslb9qGHO7Z(ig6ZHuFjeH3Nv99tlbDJ6dRQS(Ini5SI67XhT9XHIH67Hec9TL13K67HJmcVpFX77HyF99wWrgb7JL2rgbJUp7JyOp0xLc49nP(qzqYX7RswFw1hOlR5Y2N9r99wWrgb7JL2rgb7BMgdfGb8s(NpambetRpdeoWBaXjePF8jbsZDKj7pWlSdeJtiouYmPwG4OcZsW7J7zzY(3hliqQV3coY6J)5WFc13Jpjq9X)8DPGS)9f)jdt2)(yX1dcce7CtQfiEiqspdoYaI5qXiO4aXo3KAvOpzyY(RZQheur5r8Kj7FFr6BKcbnK4Fo8N0Mas9HL(CUj1QqFYWK9xNvpiOYeoRAiHN4MuBFr6BMgd1xzAKbjNvfE9y7lsFMas9HH(yhRbmGxY)8hataX06ZaHd8gqmhkgbfhiMPdfFgiLjGK2knVaNjKj12hg6dR7lsFZ0yOGPL01qNvpiOcVESaXo3KAbI5EiODUj1QdcYaIdcY0RdsaXiZxChIRHL5MulGb8s(hvbWeqSZnPwGyeVG8pGyA9zGWbEdWamG4miXlWPBayc4f2bWeqSZnPwGyhY9L0YAuiqCdiMwFgiCG3amGxYhaMaIP1Nbch4nGyNBsTaXOkf0Y)kgbbI5qXiO4aXyUpMou8zGu8cCMqMuRUwDcr9fPpm3hXIsswgHRWHKJpeiPzsief6lsFyUpZd0AQHajK5qJGkA9zGWbIxhKaIrvkOL)vmccyaVK)ayci25MulqmOaHfulG(pbetRpdeoWBagWlrvambetRpdeoWBaXCOyeuCGym3xgKyQYyawZGJmGyNBsTaXzmaRzWrgGbyaX8cCMqMuRo7ZreaMaEHDambetRpdeoWBaXCOyeuCG4zAmu8cCMqMuRcVESaXo3KAbIdY)NH0rXj8FqAnad4L8bGjGyA9zGWbEdiMdfJGIdeptJHIxGZeYKAv41Jfi25Mulq80)11qBqHZkcWaEj)bWeqmT(mq4aVbeZHIrqXbIDUjmjnTeOqO(WqFS3xK(MPXqXlWzczsTk86Xce7CtQfioimL9xplWjGb8sufataX06ZaHd8gqCcr6hFsG0ChzY(d8c7aXCOyeuCGym3hVw8KykzheC9GM7iUJtkA9zGW7lsF8ph(tO(WqU(yVVi9ntJHIxGZeYKAvPS(I0hM7BMgd1qGeYkiOkL1xK(WCFZ0yO(ktJmi5SQsz9fPVVY0idsoRAugfciTS6rq()S(WyFZ0yO(i3K9xNYuPS(WsF5dioHiDng6FooWlSde7CtQfiEiqspdoYaIXjehkzMulqmJRyFvY6lkSdcUEOVx5iUJtr3xuCcz9LquFSGaP(El4id13JpA7Z(ig67rTVB9bMw(xFCOyO(8fVVhF02hliqczfeSpb1hE9yvagWlSmaMaIP1Nbch4nG4eI0p(KaP5oYK9h4f2bI5qXiO4aX8AXtIPKDqW1dAUJ4ooPO1NbcVVi9X)C4pH6dd56J9(I03t9X0HIpdKIYlJ4gHRhcK0ZGJmuFyixFmDO4ZaPwIWjC9qGKEgCKH6dBS7JPdfFgifLNrloHR5f4mHmPwnKaDzr9HLC9ntJHs2bbxpO5oI74KcpbDtQTpSXUVzAmuYoi46bn3rChNuiZ5S2hw6lF9Hn29ntJHs2bbxpO5oI74KcsGUSO(WsF)CCfONxFyJDF8Qc41JvH(KHj7VoREqqfKCCg6lsFo3eMKMwcuiuFyixFmDO4ZaP4f4mHmPwn6tgMS)6S6bb7lsF8IjT(AQv()m9WP(EUVi9ntJHIxGZeYKAvPS(I03t9H5(MPXqneiHSccQsz9Hn29ntJHs2bbxpO5oI74KcsGUSO(WsFyTIL775(I0hM7BMgd1xzAKbjNvvkRVi99vMgzqYzvJYOqaPLvpcY)N1hg7BMgd1h5MS)6uMkL1hw6lFaXjePRXq)ZXbEHDGyNBsTaXdbs6zWrgGb8cJpaMaIP1Nbch4nGyNBsTaXCpe0o3KA1bbzaXbbz61bjGyNBctsBEGwdbyaVW4bGjGyA9zGWbEdioHi9JpjqAUJmz)bEHDGyoumckoq8mngkEbotitQvHxp2(I0hthk(mqktajTvAEbotitQTpSKRpSUVi99uFyUpyAPrb)jfUG4swqwhYGMxGG(IRO1NbcVpSXUVzAmu4cIlzbzDidAEbc6lUkL1h2y33mngkCbXLSGSoKbnVab9fxpGfYuPS(I0N5bAnfmTKUg6S6bbv06ZaH3xK(4vfWRhRAMgdnUG4swqwhYGMxGG(IRGKJZqFp3xK(EQpm3hmT0OG)K6hkOadAHl8aPO1NbcVpSXUpCAMgd1puqbg0cx4bsLY675(I03t9H5(4ftA91ulXHvOG49Hn29XRkGxpwfo523SGlPGeOllQpSXUVzAmu4KBFZcUKkL13Z9fPVN6Z5MuRcKmQGkz1JG8)z9fPpNBsTkqYOcQKvpcY)NPHeOllQpSKRpMou8zGu8cCMqMuRM7itdjqxwuFyJDFo3KAviEb5FkkpINmz)7lsFo3KAviEb5FkkpINmsdjqxwuFyPpMou8zGu8cCMqMuRM7itdjqxwuFyJDFo3KAvdbstpeuuEepzY(3xK(CUj1QgcKMEiOO8iEYinKaDzr9HL(y6qXNbsXlWzczsTAUJmnKaDzr9Hn295CtQvLXaSMbhzkkpINmz)7lsFo3KAvzmaRzWrMIYJ4jJ0qc0Lf1hw6JPdfFgifVaNjKj1Q5oY0qc0Lf1h2y3NZnPw1i4GeYGcRKIYJ4jt2)(I0NZnPw1i4GeYGcRKIYJ4jJ0qc0Lf1hw6JPdfFgifVaNjKj1Q5oY0qc0Lf13ZaXjePRXq)ZXbEHDGyNBsTaX8cCMqMulGb8clbaMaIP1Nbch4nGyCcXHsMj1ceZ40(iyF8Qc41Jf1N95wFOVkfW7Bs9LqeEFpe7RVxvGZeYKA7d9vPaEF1gyOVj1xcr499qSV(8TpNBjp03RkWzczsT9XDK1NV49TL13dX(6Z7loT9Xsr2)3r99wGqiz)7ldwCfqSZnPwGyUhcANBsT6GGmGyoumckoq8mngkEbotitQvbjqxwuFyOpwI(Wg7(4vfWRhRIxGZeYKAvqc0Lf1hw6JLbIdcY0RdsaX8cCMqMuRMxvaVESiad4LOiambetRpdeoWBaXCOyeuCG4N6BMgd1xzAKbjNvvkRVi95CtysAAjqHq9HHC9X0HIpdKIxGZeYKA1JGdsidkSs99CFyJDFp13mngQHajKvqqvkRVi95CtysAAjqHq9HHC9X0HIpdKIxGZeYKA1JGdsidkSs9Hv6dMwAuWFsneiHSccQO1NbcVVNbIDUj1cepcoiHmOWkbyaVWowdGjGyA9zGWbEdiMdfJGIdeptJHcLwnRY(J0ZaHqY(RHKJZGkL1xK(MPXqHsRMvz)r6zGqiz)1qYXzqbjqxwuFyOpUJmTjGeqSZnPwG4mgG1m4idWaEHD2bWeqmT(mq4aVbeZHIrqXbINPXqneiHSccQszaXo3KAbIZyawZGJmad4f2ZhaMaIP1Nbch4nGyoumckoq8mngQmgGfp4iqvkRVi9ntJHkJbyXdocubjqxwuFyOpUJmTjGuFr67P(MPXqXlWzczsTkib6YI6dd9XDKPnbK6dBS7BMgdfVaNjKj1QWRhBFp3xK(CUjmjnTeOqO(WsFmDO4ZaP4f4mHmPw9i4GeYGcReqSZnPwG4mgG1m4idWaEH98hataX06ZaHd8gqmhkgbfhiEMgd1xzAKbjNvvkRVi9ntJHIxGZeYKAvPmGyNBsTaXzmaRzWrgGb8c7rvambetRpdeoWBaXCOyeuCG4miXu)ZXvSRq8cY)6lsFZ0yO(i3K9xNYuPS(I0NZnHjPPLafc1hw6JPdfFgifVaNjKj1QhbhKqguyL6lsFZ0yO4f4mHmPwvkdi25MulqCgdWAgCKbyaVWoldGjGyA9zGWbEdi25Mulqm6tgMS)6S6bbbIL1iimLzAzae7CtQvneiPNbhzk(Nd)juoNBsTQHaj9m4itb65P5Fo8NqaXCOyeuCG4zAmu8cCMqMuRkL1xK(WCFo3KAvdbs6zWrMI)5WFc1xK(CUjmjnTeOqO(WqU(y6qXNbsXlWzczsTA0Nmmz)1z1dc2xK(CUj1QY(kAL80JGdsi1ifcAiX)C4pPnbK6dd9nsHGgs4jUj1ceJtiouYmPwG4xls2)(I)KHj7FFS46bb7dpbL9VVxvGZeYKA7ZQ(GeYki1hliqQV3coY6Zx8(yXFfTsE9XcbhK6J)5WFc1h33(MuFtAPHWfpeDFZK1xcL8qGH(QnWqF12xuPEDuagWlSZ4dGjGyA9zGWbEdiMdfJGIdeptJHIxGZeYKAvPS(I0NbDMuqBci1hw6BMgdfVaNjKj1QGeOllQVi99uFp1NZnPw1qGKEgCKP4Fo8Nq9HL(yVVi9zEGwtLXaS4bhbQO1NbcVVi95CtysAAjqHq9LRp2775(Wg7(WCFMhO1uzmalEWrGkA9zGW7dBS7Z5MWK00sGcH6dd9XEFp3xK(MPXq9rUj7VoLPsz9HX((ktJmi5SQrzuiG0YQhb5)Z6dl9LpGyNBsTaXzFfTsE6rWbjeGb8c7mEayciMwFgiCG3aI5qXiO4aXZ0yO4f4mHmPwfE9y7lsF8Qc41JvXlWzczsTkib6YI6dl9XDKPnbK6lsFo3eMKMwcuiuFyixFmDO4ZaP4f4mHmPw9i4GeYGcReqSZnPwG4rWbjKbfwjad4f2zjaWeqmT(mq4aVbeZHIrqXbINPXqXlWzczsTk86X2xK(4vfWRhRIxGZeYKAvqc0Lf1hw6J7itBci1xK(WCF8AXtIPgbhK0oNdjtQvrRpdeoqSZnPwG4HaPPhcagWlShfbGjGyA9zGWbEdiMdfJGIdeptJHIxGZeYKAvqc0Lf1hg6J7itBci1xK(MPXqXlWzczsTQuwFyJDFZ0yO4f4mHmPwfE9y7lsF8Qc41JvXlWzczsTkib6YI6dl9XDKPnbKaIDUj1ceJ4fK)byaVKpSgataX06ZaHd8gqmhkgbfhiEMgdfVaNjKj1QGeOllQpS03phxb651xK(CUjmjnTeOqO(WqFSde7CtQfioimL9xplWjGb8s(yhataX06ZaHd8gqmhkgbfhiEMgdfVaNjKj1QGeOllQpS03phxb651xK(MPXqXlWzczsTQugqSZnPwGyCO)xlspHKBFagGbe7CtysAZd0Aiamb8c7ayciMwFgiCG3aI5qXiO4aXo3eMKMwcuiuFyOp27lsFZ0yO4f4mHmPwfE9y7lsFp1hthk(mqktajTvAEbotitQTpm0hVQaE9yvbHPS)6zbov4jOBsT9Hn29X0HIpdKYeqsBLMxGZeYKA7dl56dR77zGyNBsTaXbHPS)6zbobmGxYhaMaIP1Nbch4nGyoumckoqmthk(mqktajTvAEbotitQTpSKRpSUpSXUVN6JxvaVESkqYOcQWtq3KA7dl9X0HIpdKYeqsBLMxGZeYKA7lsFyUpZd0AkyAjDn0z1dcQO1NbcVVN7dBS7Z8aTMcMwsxdDw9GGkA9zGW7lsFZ0yOGPL01qNvpiOkL1xK(y6qXNbszciPTsZlWzczsT9HH(CUj1QajJkOIxvaVES9Hn29nK)ptdjqxwuFyPpMou8zGuMasAR08cCMqMulqSZnPwGyqYOccyaVK)ayciMwFgiCG3aI5qXiO4aXMhO1uEGYdzqhX4Wr6rcYGIwFgi8(I03t9ntJHIxGZeYKAv41JTVi9H5(MPXq9vMgzqYzvLY67zGyNBsTaX4q)VwKEcj3(amadigz(I7qCnSm3KAbWeWlSdGjGyA9zGWbEdiMdfJGIde7CtysAAjqHq9HHC9X0HIpdK6RmnYGKZQEeCqczqHvQVi99uFZ0yO(ktJmi5SQsz9Hn29ntJHAiqczfeuLY67zGyNBsTaXJGdsidkSsagWl5dataX06ZaHd8gqmhkgbfhiEMgd1qGeYkiOkLbe7CtQfioJbyndoYamGxYFambetRpdeoWBaXCOyeuCG4zAmuFLPrgKCwvPS(I03mngQVY0idsoRkib6YI6dl95CtQvnein9qqr5r8KrAtajGyNBsTaXzmaRzWrgGb8sufataX06ZaHd8gqmhkgbfhiEMgd1xzAKbjNvvkRVi99uFzqIP(NJRyxnein9qOpSXUVHajK5qJGkNBctQpSXUpNBsTQmgG1m4itjREeK)pRVNbIDUj1ceNXaSMbhzagWlSmaMaIP1Nbch4nGyNBsTaXzmaRzWrgqmoH4qjZKAbIXeKH(SQVFY6lMLYB9LbloQpzrco1hwDXI7l7ZreQVc23RkWzczsT9L95ic13JpA7lRqizgifqmhkgbfhiEMgdfkTAwL9hPNbcHK9xdjhNbvkRVi99uF8Qc41JvbtlPRHoREqqfKaDzr9HX(CUj1QGPL01qNvpiOIYJ4jJ0Mas9HX(4oY0Mas9HH(MPXqHsRMvz)r6zGqiz)1qYXzqbjqxwuFyJDFyUpZd0AkyAjDn0z1dcQO1NbcVVN7lsFmDO4ZaPmbK0wP5f4mHmP2(WyFChzAtaP(WqFZ0yOqPvZQS)i9mqiKS)Ai54mOGeOllcWaEHXhataX06ZaHd8gqmhkgbfhiEMgd1xzAKbjNvvkRVi9Hihk7V2Qe)t5CtysaXo3KAbIZyawZGJmad4fgpambetRpdeoWBaXCOyeuCG4zAmuzmalEWrGQuwFr6J7itBci1hw6BMgdvgdWIhCeOcsGUSiGyNBsTaXzmaRzWrgGb8clbaMaIP1Nbch4nG4eI0p(KaP5oYK9h4f2bI5qXiO4aXyUVHajK5qJGkNBctQVi9H5(y6qXNbsneiPNbhz6SQcY(3xK(EQVN67P(CUj1QgcKMEiOO8iEYK9VVi99uFo3KAvdbstpeuuEepzKgsGUSO(WsFyTIL7dBS7dZ9btlnk4pPgcKqwbbv06ZaH33Z9Hn295CtQvLXaSMbhzkkpINmz)7lsFp1NZnPwvgdWAgCKPO8iEYinKaDzr9HL(WAfl3h2y3hM7dMwAuWFsneiHSccQO1NbcVVN775(I03mngQpYnz)1PmvkRVN7dBS77P(qKdL9xBvI)PCUjmP(I03t9ntJH6JCt2FDktLY6lsFyUpNBsTkeVG8pfLhXtMS)9Hn29H5(MPXq9vMgzqYzvLY6lsFyUVzAmuFKBY(RtzQuwFr6Z5MuRcXli)tr5r8Kj7FFr6dZ99vMgzqYzvJYOqaPLvpcY)N13Z99CFpdeNqKUgd9phh4f2bIDUj1cepeiPNbhzaX4eIdLmtQfi(1KGY(3N9r9HmFXDiEFWYCtQn6(QnWqFje1hliqQV3coYq994J2(SpIH(Ci13wwFts2)(YQkq49nkyFy1flUVc23RkWzczsTQ(ETiQpwqGuFVfCK1hj2hb7dpbL9VpVpwqG00dbgXIzawZGJS(4oY67XhT9HvrUj7FFV2S(euFo3eMuFfSp8eu2)(O8iEYO(Ei2xFXKdL9Vpmvj(NcWaEjkcataX06ZaHd8gqmhkgbfhiEMgd1xzAKbjNvvkRVi95CtysAAjqHq9HL(y6qXNbs9vMgzqYzvpcoiHmOWkbe7CtQfioJbyndoYamGxyhRbWeqmT(mq4aVbeZHIrqXbIXCFmDO4ZaPY(kAL80zvfK9VVi99uFyUpZd0AQbSa12hPD0hHu06ZaH3h2y3NZnHjPPLafc1hg6J9(EUVi99uFo3eMKgVmL8VIr9HL(YxFyJDFo3eMKMwcuiuFyixFmDO4ZaP(CiUM7itpcoiHmOWk1h2y3NZnHjPPLafc1hgY1hthk(mqQVY0idsoR6rWbjKbfwP(Egi25MulqC2xrRKNEeCqcbyaVWo7ayciMwFgiCG3aIDUj1ceZ9qq7CtQvheKbeheKPxhKaIDUjmjT5bAneGb8c75dataX06ZaHd8gqmhkgbfhi25MWK00sGcH6dd9XoqSZnPwGyCO)xlspHKBFagWlSN)ayciMwFgiCG3aI5qXiO4aXiYHY(RTkX)uo3eMeqSZnPwGyeVG8pad4f2JQayciMwFgiCG3aI5qXiO4aXo3eMKMwcuiuFyixFmDO4ZaPCi3xst5LfkKuBFr6d0xxLXT(WqU(y6qXNbs5qUVKMYlluiPwnOVEFr6ZC4pzQhI9jl7ynqSZnPwGyhY9L0uEzHcj1cyaVWoldGjGyA9zGWbEdi25Mulq8i4GeYGcReqmoH4qjZKAbIzCf7RpAR0)xFMd)jdfDFI1NG6Z773LTpR6J7iRpwi4GeYGcRuFoQVHeceSpzrg549vJ(ybbstpeuaXCOyeuCGyNBctstlbkeQpmKRpMou8zGuFoexZDKPhbhKqguyLamGxyNXhataXo3KAbIhcKMEiaetRpdeoWBagGbeZlWzczsTAEvb86XIaWeWlSdGjGyNBsTaXzLj1cetRpdeoWBagWl5dataXo3KAbINHQW1JeKbGyA9zGWbEdWaEj)bWeqmT(mq4aVbeZHIrqXbINPXqXlWzczsTQugqSZnPwG4jbreKvz)bmGxIQayci25Mulq8qG0mufoqmT(mq4aVbyaVWYayci25MulqSVCczqpO5EiaetRpdeoWBagWlm(ayciMwFgiCG3aI5qXiO4aXW0sJc(tkJaZkOh0pCyMIwFgi8(I03mngkkVppHmPwvkdi25MulqSjGK(HdZamGxy8aWeqmT(mq4aVbe7CtQfi(p44IBfePNo(pbetJbXn96Geq8FWXf3kispD8FcWaEHLaataX06ZaHd8gq86GeqSSiomz(mqAwuYxlbQXjMcNaIDUj1cellIdtMpdKMfL81sGACIPWjad4LOiambetRpdeoWBaXRdsaXJGds6AONUzbci25Mulq8i4GKUg6PBwGamGxyhRbWeqmT(mq4aVbeVoibe)WzLwcI0dyT4aXo3KAbIF4Sslbr6bSwCad4f2zhataX06ZaHd8gq86GeqSSidM4wbrACHPSKEsHaqSZnPwGyzrgmXTcI04ctzj9Kcbad4f2ZhaMaIP1Nbch4nG41bjGyuANHQW1oizFmGmGyNBsTaXO0odvHRDqY(yazagWlSN)ayci25MulqCcrAXiqeqmT(mq4aVbyagGbeZKGiPwGxYhwNp2X6OkwN)aXpC4k7pciMXnQGv)su4fwYOSV(W0h1NaMvqRVrb77DyLPZ(Ce9EFqIfLeiH3hQaP(8KvGUr49X)89NqQMT8twQpwok77v1YKGgH337MhO1um279zvFVBEGwtXykA9zGWFVVNypVNvnB5NSuFm(rzFVQwMe0i8(EhMwAuWFsXyV3Nv99omT0OG)KIXu06ZaH)EFpLV8Ew1S1SX4gvWQFjk8clzu2xFy6J6taZkO13OG99oon8uWEVpiXIscKW7dvGuFEYkq3i8(4F((tivZw(jl1h7rzFVQwMe0i8(EhMwAuWFsXyV3Nv99omT0OG)KIXu06ZaH)EFU13RdJZ8RVNypVNvnB5NSuFSZEu23RQLjbncVVyb8v9HyynpV(E9V((SQV8l59bw4Pqc1xLrq3kyFp96FUVNypVNvnB5NSuFSZEu23RQLjbncVV351INetXyV3Nv99oVw8KykgtrRpde(799e759SQzl)KL6J98fL99QAzsqJW77DdklRKPyxXyV3Nv99UbLLvYug7kg79(Ek)Z7zvZw(jl1h75lk77v1YKGgH337guwwjtLpfJ9EFw137guwwjtz5tXyV33t5FEpRA2YpzP(yp)JY(EvTmjOr499oVw8Kykg79(SQV351INetXykA9zGWFVVNypVNvnB5NSuF5dRJY(EvTmjOr499omT0OG)KIXEVpR67DyAPrb)jfJPO1Nbc)9(EI98Ew1SLFYs9Lp2JY(EvTmjOr499omT0OG)KIXEVpR67DyAPrb)jfJPO1Nbc)9(EI98Ew1SLFYs9LV8fL99QAzsqJW77DZd0Akg79(SQV3npqRPymfT(mq4V33tSN3ZQMT8twQV8LVOSVxvltcAeEFVdtlnk4pPyS37ZQ(EhMwAuWFsXykA9zGWFVVNypVNvnB5NSuF5l)JY(EvTmjOr499omT0OG)KIXEVpR67DyAPrb)jfJPO1Nbc)9(EI98Ew1SLFYs9LVOAu23RQLjbncVV3HPLgf8Num279zvFVdtlnk4pPymfT(mq4V33tSN3ZQMT8twQV8X4fL99QAzsqJW7lwaFvFigwZZRVxFFw1x(L8(WfMcsQTVkJGUvW(EIrp33t5FEpRA2YpzP(YhJxu23RQLjbncVVyb8v9HyynpV(E9V((SQV8l59bw4Pqc1xLrq3kyFp96FUVNypVNvnB5NSuF5lkkk77v1YKGgH337MhO1um279zvFVBEGwtXykA9zGWFVVNypVNvnBnBmUrfS6xIcVWsgL91hM(O(eWScA9nkyFVNbjEboD79(GelkjqcVpubs95jRaDJW7J)57pHunB5NSuF5lk77v1YKGgH337MhO1um279zvFVBEGwtXykA9zGWFVp3671HXz(13tSN3ZQMTMng3Ocw9lrHxyjJY(6dtFuFcywbT(gfSV35f4mHmPwnVQaE9yrV3hKyrjbs49HkqQppzfOBeEF8pF)jKQzl)KL6JXpk77v1YKGgH337W0sJc(tkg79(SQV3HPLgf8NumMIwFgi8377j2Z7zvZwZgJBubR(LOWlSKrzF9HPpQpbmRGwFJc237o3eMK28aTg69(GelkjqcVpubs95jRaDJW7J)57pHunB5NSuF5lk77v1YKGgH337MhO1um279zvFVBEGwtXykA9zGWFVVNYxEpRA2YpzP(Y)OSVxvltcAeEFVBEGwtXyV3Nv99U5bAnfJPO1Nbc)9(EI98Ew1S1SX4gvWQFjk8clzu2xFy6J6taZkO13OG99oY8f3H4AyzUj1(EFqIfLeiH3hQaP(8KvGUr49X)89NqQMT8twQpwok77v1YKGgH337MhO1um279zvFVBEGwtXykA9zGWFVVNypVNvnB5NSuFSerzFVQwMe0i8(EhMwAuWFsXyV3Nv99omT0OG)KIXu06ZaH)EFpLV8Ew1SLFYs9XowhL99QAzsqJW77DZd0Akg79(SQV3npqRPymfT(mq4V33tSN3ZQMTMng3Ocw9lrHxyjJY(6dtFuFcywbT(gfSV35f4mHmPwD2NJO37dsSOKaj8(qfi1NNSc0ncVp(NV)es1SLFYs9fvJY(EvTmjOr499oVw8Kykg79(SQV351INetXykA9zGWFVVNypVNvnB5NSuFSCu23RQLjbncVV351INetXyV3Nv99oVw8KykgtrRpde(799e759SQzl)KL6JXlk77v1YKGgH337MhO1um279zvFVBEGwtXykA9zGWFVVNypVNvnB5NSuFmErzFVQwMe0i8(EhMwAuWFsXyV3Nv99omT0OG)KIXu06ZaH)EFpLV8Ew1SLFYs9fffL99QAzsqJW77DyAPrb)jfJ9EFw137W0sJc(tkgtrRpde(799e759SQzl)KL6JDg)OSVxvltcAeEFVBEGwtXyV3Nv99U5bAnfJPO1Nbc)9(EkF59SQzl)KL6JDwIOSVxvltcAeEFVZRfpjMIXEVpR67DET4jXumMIwFgi837ZT(EDyCMF99e759SQzRzlkaMvqJW7JXRpNBsT9feKHunBaXOmId8cJF(deNbRHeiG4OoQ7Jfei1hlT)t99ewLdX5foH)CZwuh199zwgkkzeJ(f7lnv8cKribmfCtQLd9HXiKaYzuZwuh19fvYGsOp2Z)O7lFyD(yVzRzlQJ6(E1NV)ekkB2I6OUpSsFVwe13q()mnKaDzr9bD7JG9zF(2N5WFYuMasAR04c13OG9fCKHvqeVw8(8PeeJH(si)NqQMTOoQ7dR0x(vfI2(4oY6dsSOKajqAnuFJc23RkWzczsT99KOiv09Hx77wFFvaVpX6BuW(8(gqc91hlnzub7J7i7zvZwuh19Hv671z9zG6dzqHB9X)ioRY(3xT959nOh9nkiRO(KTp7J6lQWIZV(SQpiHN4uFpkiRHYXvnBrDu3hwPVOcEuCcz959XIzawZGJS(O1Gm0N95wF4fH6BlRpWcNc99GcH(KfR87GuFpHeW(mczeEFU13w9HK)vgc3xRVxdloUpbmZ52ZQMTOoQ7dR03RQLjbT(8qOVzAmumMcso36JwdkeQpR6BMgdfJPszr3NV95bWcz9jls(xziCFT(EnS44((Dz7t2(qcis1S1Sf1rDFVo5r8Kr49nPrbP(4f40T(M0VSivFrfoNYmuFBTyLphcosH(CUj1I6R2adQMnNBsTivgK4f40nmMJroK7lPL1OqG4wZMZnPwKkds8cC6ggZXOeI0IrGrVoiLdvPGw(xXiy0YihMz6qXNbsXlWzczsT6A1jefbZelkjzzeUchso(qGKMjHquicMnpqRPgcKqMdnc2S5CtQfPYGeVaNUHXCmcuGWcQfq)NA2CUj1IuzqIxGt3WyogLXaSMbhzrlJCyodsmvzmaRzWrwZwZwuh1996KhXtgH3hXKGm0NjGuF2h1NZTc2NG6Zz6sWNbs1S5CtQfLJxP1iikJcHOLromdtlnk4pPWfexYcY6qg08ce0x8MnNBsTimMJrOpzyY(RZQhemAzKBMgdfVaNjKj1QWRhBeNBsTQHaj9m4itX)C4pHWso2JG5NMPXqj7GGRh0ChXDCsLYImtJH6RmnYGKZQcso3Eocthk(mqk0Nmmz)1z1dcQN0OGKMxGZeYKAB2CUj1IWyogbDCXxtJYCiRrlJCZ0yO4f4mHmPwfE9yJ8ethk(mqktajTvAEbotitQflmDO4ZaP4f4mHmPwDgK4oY0MasyKYJ4jJ0MasyJnthk(mqktajTvAEbotitQfd8Qc41JfRWow)CZMZnPwegZXiCYTVzbxkAzKBMgdfVaNjKj1QWRhBKzAmuW0s6AOZQheuHxp2imDO4ZaPmbK0wP5f4mHmPwSW0HIpdKIxGZeYKA1zqI7itBciHrkpINmsBci1S5CtQfHXCmcuGWcI01qBfeKwlAzKJPdfFgiLjGK2knVaNjKj1IfMou8zGu8cCMqMuRodsChzAtajms5r8KrAtaPiZ0yO4f4mHmPwfE9yB2I6(yHc23RlT2hdWO7lHO(8(ybbs99wWrwF8ph(t9HNGY(3hlTaHfe1xn6dtfeKwRpUJS(SQpNzj49X9Smz)7J)5WFcPA2CUj1IWyogneiPNbhzrNqK(XNein3rMS)5ypAzKZ5MuRcuGWcI01qBfeKwtr5r8Kj7FKrke0qI)5WFsBciHvCUj1QafiSGiDn0wbbP1uuEepzKgsGUSiSevJG5VY0idsoRAugfciTS6rq()SiyEMgd1xzAKbjNvvkRzZ5MulcJ5yucrAXiWOPXG4MEDqk3FWXf3kispD8FkAzKJPdfFgiLjGK2knVaNjKj1IbEvb86XIvy5MnNBsTimMJrjePfJaJEDqkhbMXaK8GUG4RVCkAzKJPdfFgiLjGK2knVaNjKj1ILCmDO4ZaPiWmgGKh0feF9LtACk4meHPdfFgiLjGK2knVaNjKj1IbMou8zGueygdqYd6cIV(YjnofCgWkSCZMZnPwegZXOeI0IrGrVoiL7pWq2NUgAhHeqj4MuB0Yihthk(mqktajTvAEbotitQfd5y6qXNbsvRoHinpz1y0S5CtQfHXCmkHiTyey0Rds5aDUpHKg9rKPbtiHhTmYX0HIpdKYeqsBLMxGZeYKAXsowUzlQ7lkm6lHK9VpVpKrWsW7RwSscr9jgbgDFE4HZaQVeI671ajhFiqQVxxcHOqFvYqco1xn67vf4mHmPwvFmoTpc(qqu09LbLckMW4G6lHK9VVxdKC8HaP(EDjeIc99qSV(EvbotitQTVAdm0Nm6lkSdcUEOVx5iUJt9jO(O1NbcVpFX7Z7lH8FQVh1(U13K6luiRVIjb7Z(O(Wtq3KA7Rg9zFuFd5)Zu9HPpb1NJJJ6Z7db6HqFm9qI6ZQ(SpQpEvb86X2xn671ajhFiqQVxxcHOqFp(OTp8s2)(Spb1h3d8uWnP2(Me3tiQpX6tq9Lwi5bKj8(SQphHsGuF2NB9jwFpKqOVj1xcr49LrWbXTad9vBF8Qc41Jv1S5CtQfHXCmkHiTyey0Rds5WHKJpeiPzsiefIwg5y6qXNbszciPTsZlWzczsTyihthk(mqQA1jeP5jRgJipntJHs2bbxpO5oI74KczoN1CZ0yOKDqW1dAUJ4ooPa980iZ5SIn2yMxlEsmLSdcUEqZDe3XjSXMPdfFgifVaNjKj1QRvNqe2yZ0HIpdKYeqsBLMxGZeYKAXGSgbZQGBeUEi)FMgsGUSOx)R)jEvb86XIr2X6NFUzlQJ6(EHE0xCLc9ff(xXiyF0AqgIUpifec1xT9H(CiH3NyeyFV610NSJcc6MuBF2NB9jO(2Y6JbY6dLYYkOr4Q(6dRMYcoNq9zFuFzqIPujuFbzP(E8rBFJ0YnPwpOA2CUj1IWyogLqKwmcm61bPCOkf0Y)kgbJwg5EIPdfFgiLjGK2knVaNjKj1IHC5pwZs9jMou8zGu1QtisZtwngyaRFgBSFcZguwwjtXUsqkuLcA5FfJGrmOSSsMIDvc5ZafXGYYkzk2v8Qc41Jvbjqxwe2yJzdklRKPYNsqkuLcA5FfJGrmOSSsMkFQeYNbkIbLLvYu5tXRkGxpwfKaDzrp)CKNWmXIsswgHRWHKJpeiPzsiefWgBEvb86XQWHKJpeiPzsief05FunkILGLz8uqc0LfHbw(5MTOUpmbL)Fc2xCLc9ff(xXiyFKddm03dX(6lkSdcUEOVx5iUJt9vW(E8rBFI13dh1xgK4oYunBo3KArymhJ4(YPGEMgJOxhKYHQuql)RysTrlJCyMxlEsmLSdcUEqZDe3XPiMasyHLXg7zAmuYoi46bn3rChNuiZ5SMBMgdLSdcUEqZDe3XjfONNgzoN1MTOUVOGrGO(Sp36dV6BlRVjT0qS(EvbotitQTp0xLc49ffNqwFtQVeIW7RsgsWP(QrFVQaNjKj12NB9HkqQVSswt1S5CtQfHXCmkHiTyey0Rds5KfXHjZNbsZIs(AjqnoXu4u0YihXIsswgHR(doU4wbr6PJ)try6qXNbszciPTsZlWzczsTyihthk(mqQA1jeP5jRgJMnNBsTimMJrjePfJaJEDqk3i4GKUg6PBwGIwg5iwusYYiC1FWXf3kispD8Fkcthk(mqktajTvAEbotitQfd5y6qXNbsvRoHinpz1y0S5CtQfHXCmkHiTyey0Rds5E4Sslbr6bSw8OLroIfLKSmcx9hCCXTcI0th)NIW0HIpdKYeqsBLMxGZeYKAXqoMou8zGu1QtisZtwngnBo3KArymhJsislgbg96GuozrgmXTcI04ctzj9KcHOLroIfLKSmcx9hCCXTcI0th)NIW0HIpdKYeqsBLMxGZeYKAXqoMou8zGu1QtisZtwngnBo3KArymhJsislgbg96GuouANHQW1oizFmGSOLroIfLKSmcx9hCCXTcI0th)NIW0HIpdKYeqsBLMxGZeYKAXqoMou8zGu1QtisZtwngnBo3KArymhJsislgbIIwg5y6qXNbszciPTsZlWzczsTyihthk(mqQA1jeP5jRgJMTOUVxlI6JfGfY67LIP3Nv9zq5)NG9XscfuGH(IcCHhivZMZnPwegZXObSqMElME0YihmT0OG)K6hkOadAHl8afzMgdfVaNjKj1QWRhBKNy6qXNbszciPTsZlWzczsTyGxvaVESyJnthk(mqktajTvAEbotitQflmDO4ZaP4f4mHmPwDgK4oY0MasyKYJ4jJ0Masp3Sf19XsswF2h13RrqCjliRdzOVxvGG(I33mng9LYIUV0gieQpEbotitQTpb1hQQv1S5CtQfHXCmIxP1iikJcHOLroyAPrb)jfUG4swqwhYGMxGG(IhHxvaVESQzAm04cIlzbzDidAEbc6lUcsGUSiS4CtQvnGfYMvWuChzAtaPiZ0yOWfexYcY6qg08ce0xCTd5(sk86XgbZZ0yOWfexYcY6qg08ce0xCvklYtmDO4ZaPmbK0wP5f4mHmPwm6CtQvnGfYMvWuChzAtajmWRkGxpw1mngACbXLSGSoKbnVab9fxHNGUj1In2mDO4ZaPmbK0wP5f4mHmPwSWYp3S5CtQfHXCmYHCFjnLxwOqsTrlJCW0sJc(tkCbXLSGSoKbnVab9fpcVQaE9yvZ0yOXfexYcY6qg08ce0xCfKaDzryHYJ4jJ0Masy05MuRAalKnRGP4oY0MasrMPXqHliUKfK1HmO5fiOV4AhY9Lu41JncMNPXqHliUKfK1HmO5fiOV4QuwKNy6qXNbszciPTsZlWzczsTyKYJ4jJ0Masy05MuRAalKnRGP4oY0MasyGxvaVESQzAm04cIlzbzDidAEbc6lUcpbDtQfBSz6qXNbszciPTsZlWzczsTyHLJGzZd0AkyAjDn0z1dc(CZMZnPwegZXObSq2Scw0YihmT0OG)KcxqCjliRdzqZlqqFXJWRkGxpw1mngACbXLSGSoKbnVab9fxbjqxwew4oY0MasrMPXqHliUKfK1HmO5fiOV46bSqMcVESrW8mngkCbXLSGSoKbnVab9fxLYI8ethk(mqktajTvAEbotitQfJChzAtajmWRkGxpw1mngACbXLSGSoKbnVab9fxHNGUj1In2mDO4ZaPmbK0wP5f4mHmPwSWYp3S5CtQfHXCmAalKP3IPhTmYbtlnk4pPWfexYcY6qg08ce0x8i8Qc41JvntJHgxqCjliRdzqZlqqFXvqYXziYmngkCbXLSGSoKbnVab9fxpGfYu41JncMNPXqHliUKfK1HmO5fiOV4QuwKNy6qXNbszciPTsZlWzczsTyGxvaVESQzAm04cIlzbzDidAEbc6lUcpbDtQfBSz6qXNbszciPTsZlWzczsTyHLFUzZ5MulcJ5ye3dbTZnPwDqqw0Rds54f4mHmPwD2NJOOLroMou8zGuMasAR08cCMqMulwYH1yJnthk(mqktajTvAEbotitQflmDO4ZaP4f4mHmPwDgK4oY0Masr4vfWRhRIxGZeYKAvqc0LfHfMou8zGu8cCMqMuRodsChzAtaPMnNBsTimMJrW0s6AOZQhemAzKBMgdfmTKUg6S6bbv41JncMNPXqneiHSccQszrEIPdfFgiLjGK2knVaNjKj1IHCZ0yOGPL01qNvpiOcpbDtQncthk(mqktajTvAEbotitQfdo3KAvdbs6zWrMAKcbnK4Fo8N0MasyJnthk(mqktajTvAEbotitQfdd5)Z0qc0Lf9CZwu3hlUQqFoQpqFzOpwqGuFVfCKH6Zr9LviKmduFJc23RkWzczsTQ(Ittd6CRVkz9vJ(SpQVb05MuRh6JxGz1sR1xn6Z(O(2e4KG9vJ(ybbs99wWrgQp7ZT(EiHqFRBjOhcm0hK4Fo8N6dpbL9Vp7J67vf4mHmP2(Y(Ce13K4Ecr9Lvvq2)(8Lb7t2)(YCK1N95wFpKqOVTS((H(A95BFuEg07Jfei13Bbhz9HNGY(33RkWzczsTQMnNBsTimMJrmDO4ZafDcr6Am0)C8CShDcr6hFsG0ChzY(NJ9OxhKYneiPNbhz6SQcY(hntpKOCo3KAvdbs6zWrMI)5WFcPhqNBsTEaJpX0HIpdKYeqsBLMxGZeYKAXOZnPwf6tgMS)6S6bbvJuiOHeEIBsTSuz6qXNbsH(KHj7VoREqq9KgfK08cCMqMu7ZVEEvb86XQgcK0ZGJmfEc6MulwHDSWRkGxpw1qGKEgCKPa9808ph(timY0HIpdKQysWSQc6Haj9m4id965vfWRhRAiqspdoYu4jOBsTyLNMPXqXlWzczsTk8e0nP2xpVQaE9yvdbs6zWrMcpbDtQ95x)RN9imDO4ZaPmbK0wP5f4mHmPwSmK)ptdjqxwuZMZnPwegZXiUhcANBsT6GGSOxhKYbRmD2NJOOrgu4wo2Jwg5MPXqbtlPRHoREqqvklcthk(mqktajTvAEbotitQfdyDZwu3xubpkoHS(SpQpMou8zG6Z(CRpETgScO(ybbs99wWrwFjK)t9zvF0IsqQpXq9X)C4pH6ZHuFEav9LvvGW7BuW(WQtl1xn6JfxpiOQzZ5MulcJ5yethk(mqrNqKUgd9phph7rNqK(XNein3rMS)5yp61bPCdbs6zWrMoRQGS)rxz5qKfntpKOC8Qc41JvbtlPRHoREqqfKaDzryX5MuRAiqspdoYuJuiOHe)ZH)K2eqcR4CtQvH(KHj7VoREqq1ifcAiHN4Mull1Ny6qXNbsH(KHj7VoREqq9KgfK08cCMqMuBeEvb86XQqFYWK9xNvpiOcsGUSiSWRkGxpwfmTKUg6S6bbvqc0Lf9CeEvb86XQGPL01qNvpiOcsGUSiSmK)ptdjqxwu0YihMz6qXNbsneiPNbhz6SQcY(hX8aTMcMwsxdDw9GGrMPXqbtlPRHoREqqfE9yB2I6(yC)OTpSkhIZDKj7FFSqWbP(InOWkfDFSGaP(El4id1h6Rsb8(MuFjeH3Nv99tlbDJ6dRQS(Ini5SI6Zx8(SQpkpJw8(El4iJG9Xs7iJGQMnNBsTimMJrdbs6zWrw0jePRXq)ZXZXE0jePF8jbsZDKj7Fo2Jwg5Wmthk(mqQHaj9m4itNvvq2)imDO4ZaPmbK0wP5f4mHmPwmG1rCUjmjnTeOqimKJPdfFgi1NdX1Chz6rWbjKbfwPiyEiqczo0iOY5MWKIG5zAmuFLPrgKCwvPSipntJH6JCt2FDktLYI4CtQvncoiHmOWkPO8iEYinKaDzrybRvSm2yZ)C4pH0dOZnPwpGHC575MTOUVxtck7FFSGajK5qJGr3hliqQV3coYq95qQVeIW7djGsWHbg6ZQ(Wtqz)77vf4mHmPwvFSK0sqpeyi6(SpIH(Ci1xcr49zvF)0sq3O(WQkRVydsoRO(E8rBFCOyO(EiHqFBz9nP(E4iJW7Zx8(Ei2xFVfCKrW(yPDKrWO7Z(ig6d9vPaEFtQpugKC8(QK1Nv9b6YAUS9zFuFVfCKrW(yPDKrW(MPXq1S5CtQfHXCmAiqspdoYIoHiDng6FoEo2JoHi9JpjqAUJmz)ZXE0Yi3qGeYCOrqLZnHjfH)5WFcHHCShbZmDO4ZaPgcK0ZGJmDwvbz)J8eMDUj1QgcKMEiOO8iEYK9pcMDUj1QYyawZGJmLS6rq()SiZ0yO(i3K9xNYuPmSX25MuRAiqA6HGIYJ4jt2)iyEMgd1xzAKbjNvvkdBSDUj1QYyawZGJmLS6rq()SiZ0yO(i3K9xNYuPSiyEMgd1xzAKbjNvvk75MTOUVOcZsW7J7zzY(3hliqQV3coY6J)5WFc13Jpjq9X)8DPGS)9f)jdt2)(yX1dc2S5CtQfHXCmAiqspdoYIoHi9JpjqAUJmz)ZXE0YiNZnPwf6tgMS)6S6bbvuEepzY(hzKcbnK4Fo8N0MasyX5MuRc9jdt2FDw9GGkt4SQHeEIBsTrMPXq9vMgzqYzvHxp2iMasyGDSUzZ5MulcJ5ye3dbTZnPwDqqw0Rds5qMV4oexdlZnP2OLroMou8zGuMasAR08cCMqMulgW6iZ0yOGPL01qNvpiOcVESnBo3KArymhJq8cY)A2A2CUj1Iuo3eMK28aTgkxqyk7VEwGZOLroNBctstlbkecdShzMgdfVaNjKj1QWRhBKNy6qXNbszciPTsZlWzczsTyGxvaVESQGWu2F9SaNk8e0nPwSXMPdfFgiLjGK2knVaNjKj1ILCy9ZnBo3KArkNBctsBEGwdHXCmcKmQGrlJCmDO4ZaPmbK0wP5f4mHmPwSKdRXg7N4vfWRhRcKmQGk8e0nPwSW0HIpdKYeqsBLMxGZeYKAJGzZd0AkyAjDn0z1dc(m2yBEGwtbtlPRHoREqWiZ0yOGPL01qNvpiOkLfHPdfFgiLjGK2knVaNjKj1IbNBsTkqYOcQ4vfWRhl2ypK)ptdjqxwewy6qXNbszciPTsZlWzczsTnBo3KArkNBctsBEGwdHXCmch6)1I0ti52x0YiN5bAnLhO8qg0rmoCKEKGme5PzAmu8cCMqMuRcVESrW8mngQVY0idsoRQu2ZnBnBo3KArkEbotitQvZRkGxpwuUSYKAB2CUj1Iu8cCMqMuRMxvaVESimMJrZqv46rcYqZMZnPwKIxGZeYKA18Qc41JfHXCmAsqebzv2)OLrUzAmu8cCMqMuRkL1S5CtQfP4f4mHmPwnVQaE9yrymhJgcKMHQWB2CUj1Iu8cCMqMuRMxvaVESimMJr(YjKb9GM7HqZMZnPwKIxGZeYKA18Qc41JfHXCmYeqs)WHzrlJCW0sJc(tkJaZkOh0pCywKzAmuuEFEczsTQuwZMZnPwKIxGZeYKA18Qc41JfHXCmkHiTyey00yqCtVoiL7p44IBfePNo(p1S5CtQfP4f4mHmPwnVQaE9yrymhJsislgbg96GuozrCyY8zG0SOKVwcuJtmfo1S5CtQfP4f4mHmPwnVQaE9yrymhJsislgbg96GuUrWbjDn0t3Sa1S5CtQfP4f4mHmPwnVQaE9yrymhJsislgbg96GuUhoR0sqKEaRfVzZ5MulsXlWzczsTAEvb86XIWyogLqKwmcm61bPCYImyIBfePXfMYs6jfcnBo3KArkEbotitQvZRkGxpwegZXOeI0IrGrVoiLdL2zOkCTds2hdiRzZ5MulsXlWzczsTAEvb86XIWyogLqKwmce1S1S5CtQfP4f4mHmPwD2NJOCb5)Zq6O4e(piTw0Yi3mngkEbotitQvHxp2MnNBsTifVaNjKj1QZ(CeHXCmA6)6AOnOWzffTmYntJHIxGZeYKAv41JTzZ5MulsXlWzczsT6SphrymhJcctz)1ZcCgTmY5CtysAAjqHqyG9iZ0yO4f4mHmPwfE9yB2I6(yCf7RswFrHDqW1d99khXDCk6(IItiRVeI6Jfei13BbhzO(E8rBF2hXqFpQ9DRpW0Y)6Jdfd1NV4994J2(ybbsiRGG9jO(WRhRQzZ5MulsXlWzczsT6SphrymhJgcK0ZGJSOtisxJH(NJNJ9Otis)4tcKM7it2)CShTmYHzET4jXuYoi46bn3rChNIW)C4pHWqo2JmtJHIxGZeYKAvPSiyEMgd1qGeYkiOkLfbZZ0yO(ktJmi5SQszr(ktJmi5SQrzuiG0YQhb5)ZW4mngQpYnz)1Pmvkdl5RzZ5MulsXlWzczsT6SphrymhJgcK0ZGJSOtisxJH(NJNJ9Otis)4tcKM7it2)CShTmYXRfpjMs2bbxpO5oI74ue(Nd)jegYXEKNy6qXNbsr5LrCJW1dbs6zWrgcd5y6qXNbsTeHt46Haj9m4idHn2mDO4ZaPO8mAXjCnVaNjKj1QHeOllcl5MPXqj7GGRh0ChXDCsHNGUj1In2Z0yOKDqW1dAUJ4ooPqMZzfl5dBSNPXqj7GGRh0ChXDCsbjqxwew(54kqppSXMxvaVESk0Nmmz)1z1dcQGKJZqeNBctstlbkecd5y6qXNbsXlWzczsTA0Nmmz)1z1dcgHxmP1xtTY)NPho9CKzAmu8cCMqMuRkLf5jmptJHAiqczfeuLYWg7zAmuYoi46bn3rChNuqc0LfHfSwXYphbZZ0yO(ktJmi5SQszr(ktJmi5SQrzuiG0YQhb5)ZW4mngQpYnz)1Pmvkdl5RzZ5MulsXlWzczsT6SphrymhJ4EiODUj1QdcYIEDqkNZnHjPnpqRHA2CUj1Iu8cCMqMuRo7ZregZXiEbotitQn6eI01yO)545yp6eI0p(KaP5oYK9ph7rlJCZ0yO4f4mHmPwfE9yJW0HIpdKYeqsBLMxGZeYKAXsoSoYtygMwAuWFsHliUKfK1HmO5fiOV4yJ9mngkCbXLSGSoKbnVab9fxLYWg7zAmu4cIlzbzDidAEbc6lUEalKPszrmpqRPGPL01qNvpiyeEvb86XQMPXqJliUKfK1HmO5fiOV4ki54m8CKNWmmT0OG)K6hkOadAHl8aHn240mngQFOGcmOfUWdKkL9CKNWmVysRVMAjoScfehBS5vfWRhRcNC7BwWLuqc0LfHn2Z0yOWj3(MfCjvk75ip5CtQvbsgvqLS6rq()Sio3KAvGKrfujREeK)ptdjqxwewYX0HIpdKIxGZeYKA1ChzAib6YIWgBNBsTkeVG8pfLhXtMS)rCUj1Qq8cY)uuEepzKgsGUSiSW0HIpdKIxGZeYKA1ChzAib6YIWgBNBsTQHaPPhckkpINmz)J4CtQvnein9qqr5r8KrAib6YIWcthk(mqkEbotitQvZDKPHeOllcBSDUj1QYyawZGJmfLhXtMS)rCUj1QYyawZGJmfLhXtgPHeOllclmDO4ZaP4f4mHmPwn3rMgsGUSiSX25MuRAeCqczqHvsr5r8Kj7FeNBsTQrWbjKbfwjfLhXtgPHeOllclmDO4ZaP4f4mHmPwn3rMgsGUSONB2I6(yCAFeSpEvb86XI6Z(CRp0xLc49nP(sicVVhI913RkWzczsT9H(QuaVVAdm03K6lHi8(Ei2xF(2NZTKh67vf4mHmP2(4oY6Zx8(2Y67HyF959fN2(yPi7)7O(ElqiKS)9LblUQzZ5MulsXlWzczsT6SphrymhJ4EiODUj1QdcYIEDqkhVaNjKj1Q5vfWRhlkAzKBMgdfVaNjKj1QGeOllcdSeyJnVQaE9yv8cCMqMuRcsGUSiSWYnBo3KArkEbotitQvN95icJ5y0i4GeYGcRu0Yi3tZ0yO(ktJmi5SQszrCUjmjnTeOqimKJPdfFgifVaNjKj1QhbhKqguyLEgBSFAMgd1qGeYkiOkLfX5MWK00sGcHWqoMou8zGu8cCMqMuREeCqczqHvcRatlnk4pPgcKqwbbFUzZ5MulsXlWzczsT6SphrymhJYyawZGJSOLrUzAmuO0Qzv2FKEgies2FnKCCguPSiZ0yOqPvZQS)i9mqiKS)Ai54mOGeOllcdChzAtaPMnNBsTifVaNjKj1QZ(CeHXCmkJbyndoYIwg5MPXqneiHSccQsznBo3KArkEbotitQvN95icJ5yugdWAgCKfTmYntJHkJbyXdocuLYImtJHkJbyXdocubjqxweg4oY0MasrEAMgdfVaNjKj1QGeOllcdChzAtajSXEMgdfVaNjKj1QWRh7ZrCUjmjnTeOqiSW0HIpdKIxGZeYKA1JGdsidkSsnBo3KArkEbotitQvN95icJ5yugdWAgCKfTmYntJH6RmnYGKZQkLfzMgdfVaNjKj1QsznBo3KArkEbotitQvN95icJ5yugdWAgCKfTmYLbjM6FoUIDfIxq(xKzAmuFKBY(RtzQuweNBctstlbkeclmDO4ZaP4f4mHmPw9i4GeYGcRuKzAmu8cCMqMuRkL1Sf199ArY(3x8Nmmz)7JfxpiyF4jOS)99QcCMqMuBFw1hKqwbP(ybbs99wWrwF(I3hl(ROvYRpwi4GuF8ph(tO(4(23K6BslneU4HO7BMS(sOKhcm0xTbg6R2(Ik1RJQzZ5MulsXlWzczsT6SphrymhJqFYWK9xNvpiy0Yi3mngkEbotitQvLYIGzNBsTQHaj9m4itX)C4pHI4CtysAAjqHqyihthk(mqkEbotitQvJ(KHj7VoREqWio3KAvzFfTsE6rWbjKAKcbnK4Fo8N0MasyyKcbnKWtCtQnAzncctzMwg5CUj1QgcK0ZGJmf)ZH)ekNZnPw1qGKEgCKPa9808ph(tOMnNBsTifVaNjKj1QZ(CeHXCmk7ROvYtpcoiHIwg5MPXqXlWzczsTQuwed6mPG2eqclZ0yO4f4mHmPwfKaDzrrE6jNBsTQHaj9m4itX)C4pHWc7rmpqRPYyaw8GJaJ4CtysAAjqHq5y)zSXgZMhO1uzmalEWrGyJTZnHjPPLafcHb2FoYmngQpYnz)1PmvkdJFLPrgKCw1OmkeqAz1JG8)zyjFnBo3KArkEbotitQvN95icJ5y0i4GeYGcRu0Yi3mngkEbotitQvHxp2i8Qc41JvXlWzczsTkib6YIWc3rM2eqkIZnHjPPLafcHHCmDO4ZaP4f4mHmPw9i4GeYGcRuZMZnPwKIxGZeYKA1zFoIWyognein9qiAzKBMgdfVaNjKj1QWRhBeEvb86XQ4f4mHmPwfKaDzryH7itBcifbZ8AXtIPgbhK0oNdjtQTzZ5MulsXlWzczsT6SphrymhJq8cY)Iwg5MPXqXlWzczsTkib6YIWa3rM2eqkYmngkEbotitQvLYWg7zAmu8cCMqMuRcVESr4vfWRhRIxGZeYKAvqc0LfHfUJmTjGuZMZnPwKIxGZeYKA1zFoIWyogfeMY(RNf4mAzKBMgdfVaNjKj1QGeOllcl)CCfONxeNBctstlbkecdS3S5CtQfP4f4mHmPwD2NJimMJr4q)VwKEcj3(Iwg5MPXqXlWzczsTkib6YIWYphxb65fzMgdfVaNjKj1QsznBnBo3KArkyLPZ(CeLBeCqczqHvkAzKZ5MWK00sGcHWqoMou8zGuFLPrgKCw1JGdsidkSsrEAMgd1xzAKbjNvvkdBSNPXqneiHSccQszp3S5CtQfPGvMo7ZregZXOmgG1m4ilAzKBMgdfkTAwL9hPNbcHK9xdjhNbvklYmngkuA1Sk7pspdecj7Vgsoodkib6YIWa3rM2eqQzZ5MulsbRmD2NJimMJrzmaRzWrw0Yi3mngQHajKvqqvkRzZ5MulsbRmD2NJimMJrzmaRzWrw0Yi3mngQVY0idsoRQuwZwu33Rfr9vl1hliqQV3coY6JCyGH(KTpS6If3Nm6JHk1hETVB995mP(iX(iyFyvKBY(33RnRVc2hwvz9fBqYzTpgiRpFX7Je7JGrzFp5p33NZK6dSGuF2NV9zpQ(8aKCCgIUVNMp33NZK6lQeO8qg0rmo83r9Xcjid9bjhNH(SQVeIIUVc23t8N7lMCOS)9HPkX)6tq95CtysQ(En1(U1hE1N9jO(E8jbQVphI3h3rMS)9XcbhKqguyLq9vW(E8rBFXPTpwkY()oQV3cecj7FFcQpi54mOA2CUj1IuWktN95icJ5y0qGKEgCKfDcr6Am0)C8CShDcr6hFsG0ChzY(NJ9OLromZ0HIpdKAiqspdoY0zvfK9pYmngkuA1Sk7pspdecj7Vgsoodk86XgX5MWK00sGcHWcthk(mqQphIR5oY0JGdsidkSsrW8qGeYCOrqLZnHjf5jmptJH6JCt2FDktLYIG5zAmuFLPrgKCwvPSiyodsm11yO)54QHaj9m4ilYto3KAvdbs6zWrMI)5WFcHHC5dBSFY8aTMYduEid6ighospsqgIWRkGxpwfo0)RfPNqYTpfKCCgEgBSrKdL9xBvI)PCUjmPNFUzlQ771IO(ybbs99wWrwFKyFeSp8eu2)(8(ybbstpeyelMbyndoY6J7iRVhF02hwf5MS)99AZ6tq95Ctys9vW(Wtqz)7JYJ4jJ67HyF9ftou2)(WuL4FQMnNBsTifSY0zFoIWyogneiPNbhzrNqKUgd9phph7rNqK(XNein3rMS)5ypAzKdZmDO4ZaPgcK0ZGJmDwvbz)JG5HajK5qJGkNBctkYtp9KZnPw1qG00dbfLhXtMS)rEY5MuRAiqA6HGIYJ4jJ0qc0LfHfSwXYyJnMHPLgf8NudbsiRGGpJn2o3KAvzmaRzWrMIYJ4jt2)ip5CtQvLXaSMbhzkkpINmsdjqxwewWAflJn2ygMwAuWFsneiHScc(8ZrMPXq9rUj7VoLPszpJn2pHihk7V2Qe)t5CtysrEAMgd1h5MS)6uMkLfbZo3KAviEb5FkkpINmz)XgBmptJH6RmnYGKZQkLfbZZ0yO(i3K9xNYuPSio3KAviEb5FkkpINmz)JG5VY0idsoRAugfciTS6rq()SNF(5MnNBsTifSY0zFoIWyogX9qq7CtQvheKf96GuoNBctsBEGwd1S5CtQfPGvMo7ZregZXOmgG1m4ilAzKBMgdvgdWIhCeOkLfH7itBciHLzAmuzmalEWrGkib6YIIWDKPnbKWYmngkyAjDn0z1dcQGeOllQzZ5MulsbRmD2NJimMJrzmaRzWrw0Yi3mngQVY0idsoRQuwee5qz)1wL4FkNBctkIZnHjPPLafcHfMou8zGuFLPrgKCw1JGdsidkSsnBo3KArkyLPZ(CeHXCmk7ROvYtpcoiHIwg5Wmthk(mqQSVIwjpDwvbz)JmtJH6JCt2FDktLYIG5zAmuFLPrgKCwvPSip5CtysA8YuY)kgHL8Hn2o3eMKMwcuiegYX0HIpdK6ZH4AUJm9i4GeYGcRe2y7CtysAAjqHqyihthk(mqQVY0idsoR6rWbjKbfwPNB2CUj1IuWktN95icJ5yeIxq(x0YihICOS)ARs8pLZnHj1S5CtQfPGvMo7ZregZXiCO)xlspHKBFrlJCo3eMKMwcuiegYxZMZnPwKcwz6SphrymhJCi3xst5LfkKuB0YiNZnHjPPLafcHHCmDO4ZaPCi3xst5LfkKuBeqFDvg3WqoMou8zGuoK7lPP8YcfsQvd6RhXC4pzQhI9jl7yDZwu3hJRyF9rBL()6ZC4pzOO7tS(euFEF)US9zvFChz9XcbhKqguyL6Zr9nKqGG9jlYihVVA0hliqA6HGQzZ5MulsbRmD2NJimMJrJGdsidkSsrlJCo3eMKMwcuiegYX0HIpdK6ZH4AUJm9i4GeYGcRuZMZnPwKcwz6SphrymhJgcKMEi0S1S5CtQfPqMV4oexdlZnP2CJGdsidkSsrlJCo3eMKMwcuiegYX0HIpdK6RmnYGKZQEeCqczqHvkYtZ0yO(ktJmi5SQszyJ9mngQHajKvqqvk75MnNBsTifY8f3H4AyzUj1IXCmkJbyndoYIwg5MPXqneiHSccQsznBo3KArkK5lUdX1WYCtQfJ5yugdWAgCKfTmYntJH6RmnYGKZQkLfzMgd1xzAKbjNvfKaDzryX5MuRAiqA6HGIYJ4jJ0MasnBo3KArkK5lUdX1WYCtQfJ5yugdWAgCKfTmYntJH6RmnYGKZQkLf5PmiXu)ZXvSRgcKMEiGn2dbsiZHgbvo3eMe2y7CtQvLXaSMbhzkz1JG8)zp3Sf19Hjid9zvF)K1xmlL36ldwCuFYIeCQpS6If3x2NJiuFfSVxvGZeYKA7l7ZreQVhF02xwHqYmqQMnNBsTifY8f3H4AyzUj1IXCmkJbyndoYIwg5MPXqHsRMvz)r6zGqiz)1qYXzqLYI8eVQaE9yvW0s6AOZQheubjqxwegDUj1QGPL01qNvpiOIYJ4jJ0MasyK7itBciHHzAmuO0Qzv2FKEgies2FnKCCguqc0LfHn2y28aTMcMwsxdDw9GGphHPdfFgiLjGK2knVaNjKj1IrUJmTjGegMPXqHsRMvz)r6zGqiz)1qYXzqbjqxwuZMZnPwKcz(I7qCnSm3KAXyogLXaSMbhzrlJCZ0yO(ktJmi5SQszrqKdL9xBvI)PCUjmPMnNBsTifY8f3H4AyzUj1IXCmkJbyndoYIwg5MPXqLXaS4bhbQszr4oY0MasyzMgdvgdWIhCeOcsGUSOMTOUVxtck7FF2h1hY8f3H49blZnP2O7R2ad9LquFSGaP(El4id13JpA7Z(ig6ZHuFBz9njz)7lRQaH33OG9HvxS4(kyFVQaNjKj1Q671IO(ybbs99wWrwFKyFeSp8eu2)(8(ybbstpeyelMbyndoY6J7iRVhF02hwf5MS)99AZ6tq95Ctys9vW(Wtqz)7JYJ4jJ67HyF9ftou2)(WuL4FQMnNBsTifY8f3H4AyzUj1IXCmAiqspdoYIoHiDng6FoEo2JoHi9JpjqAUJmz)ZXE0YihMhcKqMdncQCUjmPiyMPdfFgi1qGKEgCKPZQki7FKNE6jNBsTQHaPPhckkpINmz)J8KZnPw1qG00dbfLhXtgPHeOllclyTILXgBmdtlnk4pPgcKqwbbFgBSDUj1QYyawZGJmfLhXtMS)rEY5MuRkJbyndoYuuEepzKgsGUSiSG1kwgBSXmmT0OG)KAiqczfe85NJmtJH6JCt2FDktLYEgBSFcrou2FTvj(NY5MWKI80mngQpYnz)1PmvklcMDUj1Qq8cY)uuEepzY(Jn2yEMgd1xzAKbjNvvklcMNPXq9rUj7VoLPszrCUj1Qq8cY)uuEepzY(hbZFLPrgKCw1OmkeqAz1JG8)zp)8ZnBo3KArkK5lUdX1WYCtQfJ5yugdWAgCKfTmYntJH6RmnYGKZQkLfX5MWK00sGcHWcthk(mqQVY0idsoR6rWbjKbfwPMnNBsTifY8f3H4AyzUj1IXCmk7ROvYtpcoiHIwg5Wmthk(mqQSVIwjpDwvbz)J8eMnpqRPgWcuBFK2rFecBSDUjmjnTeOqimW(ZrEY5MWK04LPK)vmcl5dBSDUjmjnTeOqimKJPdfFgi1NdX1Chz6rWbjKbfwjSX25MWK00sGcHWqoMou8zGuFLPrgKCw1JGdsidkSsp3S5CtQfPqMV4oexdlZnPwmMJrCpe0o3KA1bbzrVoiLZ5MWK0MhO1qnBo3KArkK5lUdX1WYCtQfJ5yeo0)RfPNqYTVOLroNBctstlbkecdS3S5CtQfPqMV4oexdlZnPwmMJriEb5FrlJCiYHY(RTkX)uo3eMuZMZnPwKcz(I7qCnSm3KAXyog5qUVKMYlluiP2OLroNBctstlbkecd5y6qXNbs5qUVKMYlluiP2iG(6QmUHHCmDO4ZaPCi3xst5LfkKuRg0xpI5WFYupe7tw2X6MTOUpgxX(6J2k9)1N5WFYqr3Ny9jO(8((Dz7ZQ(4oY6JfcoiHmOWk1NJ6BiHab7twKroEF1OpwqG00dbvZMZnPwKcz(I7qCnSm3KAXyogncoiHmOWkfTmY5CtysAAjqHqyihthk(mqQphIR5oY0JGdsidkSsnBo3KArkK5lUdX1WYCtQfJ5y0qG00dbadWaaa]] )
end
