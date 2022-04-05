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


    spec:RegisterPack( "Fire", 20220405, [[devMYeqiuu9iOqxIaLAtkv9jOGrbICkqOvbIQEfiywqj3IqP2Le)cQuddeLJPuXYiu8mOIyAei11uQeBdQi13iqjJdev6CkvQQ1rOK5HI09iO9Hc5FOOO0brrPwiuHhcvYejqYfjqHncvuFuPsvgjiQ4KeOQvsaVefL0mvQuUjbkANOi(jurYqvQKwkbQ8uqAQOqDvLkv2kkkYxrrjglbI9Is)LObR4WuwSKEmQMmOUmYMvYNvfJwPCAsRgffvVgfmBQCBv1Uv53snCvPJJIclhYZbMUW1PQTdv9Dcz8eQopu06rrrX8HsTFrZUdlJzHcBbXYeXazIrmqMGgY2LYoqUc6DrqJtyHgy(sSqFnod2dXc9SpXcfNveXc91W01gmlJzHcApItSq3I4fiw4g3pAS5RfE)Xnq)ENfAFCKTcCd0ph3SqRE1fc(JTYcf2cILjIbYeJyGmbnKTlLDGCf07cobYLfQ5JTgXcfQ(Xfl0nfgMo2kluycWzHIZkIYrW0EOuGTiEbIfUX9JgB(AH3FCd0V3zH2hhzRa3a9ZXDkaZ(fPUC2fSYrmqMyetkqkaU2S7HaIvkGyNZUdq5S0NTqIOVPhihKfBekNyZUCcd9qrj0pjJwcRuoRgLJZaHydiEFW5yv1PbM54b2dbkPaIDo7w3a6YHBGiheXm8kI(0fGCwnkhC1)QheAF5ajTqfSYbUpme5S1o4C0iNvJYXYzHiWwocMuqnkhUbciwsbe7CemoR6OCabs5ro8nIZGEp50xowolsuoRgXaih9Yj2OCy276ULt05GiypNYruJyW1gCjfqSZHzdZm3dICSC2vmrD1zGih6ceM5eBwKdCtGCUoY53WKlhrKZLJEI9J9PCGeq)5eeii4CSiNRZbOpNUuUDrocQDfAo6)14belPaIDo4Qp8ekYXCUCQ(1Qiifez8ih6cKsGCIoNQFTkcsX)Ivo2LJ5(niYrpG(C6s52f5iO2vO58y6LJE5a0pOKci25S7auoBgcM3WeCo4nKAvhbYj6CqeSNt5GRDD3LJOgXGRn4cluNccalJzHY7F1dcTpjVBhCl6aSmMLj7WYywOgp0(yH(2H2hlu6SQJGzXbBWYeXWYywOgp0(yHwDDdlxEeMSqPZQocMfhSbltWjSmMfkDw1rWS4GfkhPbHuJfA1VwfE)REqO9v8VSqnEO9XcTsiaHyqVh2GLjcAwgZc14H2hl0LIOQRBywO0zvhbZId2GLj7clJzHA8q7JfQDCceiZj5MZXcLoR6iywCWgSmbNMLXSqPZQocMfhSq5iniKASqr(Jwn6Hkb9FBK5KIm0BHoR6i4C2Nt1Vwfs8nZdcTVI)LfQXdTpwOH(jPid9YgSmrWILXSqPZQocMfhSqnEO9Xc9XzWQfnciRg8dXcLwlIhYZ(el0hNbRw0iGSAWpeBWYeixwgZcLoR6iywCWc9SpXcvpah5dR6ijZWBx4)sycVYjwOgp0(yHQhGJ8HvDKKz4Tl8FjmHx5eBWYKDFwgZcLoR6iywCWc9SpXcD5Spj7LSAr4iwOgp0(yHUC2NK9swTiCeBWYKDGmwgZcLoR6iywCWc9SpXcvKXaDecixO(GzHA8q7JfQiJb6ieqUq9bZgSmzNDyzmlu6SQJGzXbl0Z(elu9abYZJgbKWkE9izLCowOgp0(yHQhiqEE0iGewXRhjRKZXgSmzhXWYywO0zvhbZIdwON9jwOa)vDDdlTpfByccwOgp0(yHc8x11nS0(uSHjiydwMSdoHLXSqnEO9Xc1diPg0hWcLoR6iywCWgSbluyAzExWYywMSdlJzHsNvDemloyHYrAqi1yHY8Cq(Jwn6HkWkGRVo9meMsE))2bxOZQocMfQXdTpwO82FbHaVKZXgSmrmSmMfkDw1rWS4GfQXdTpwOGnDf69iFBreIfkmb4i9n0(yHYmzi1QokNyZICiqOFliqoI2OyJq5aDtxHEp5SRTicLJi15YPs54beCovA1ikhC1)QheAF5OGCqKbJzHfkhPbHuJfA1VwfE)REqO9vGBrxo7ZX4H2xzPiswDgik8nd9qGCyQWC2jN95W8CGuov)Av0BrOZCsUb4gmv8V5SpNQFTkBDibbImgkiY4roqmN95G3qQvDubSPRqVh5BlIqYkTAej59V6bH2hBWYeCclJzHsNvDemloyHA8q7JfkYGv7cj41qmWcfMaCK(gAFSqHA4PCeCgSAxKd0xdXqoRgLdU6F1dcTpSYP6JC6yJqIuaLJhq5Oro9LdVBhCl6kSq5iniKASqR(1QW7F1dcTVcCl6YzFoqkh8gsTQJkH(jz0sE)REqO9LdJYX4H2NK3TdUfD5i25Sl5ar2GLjcAwgZcLoR6iywCWc14H2hluyYITAJoIfkmb4i9n0(yHkOil2Qn6OCaBT3bNJ5ezycYPs54beCoI0ylhC1)QheAFLCyw0ylhbfzXgga5GZwS1FSYrJCaBT3bNtLYXdi4Cid5WmhqNtSzrockYITAJokhrQZLZMHNY53ikhqyCga5a7r69KdU6F1dcTVcluosdcPgl0QFTk8(x9Gq7Ra3IUC2Nt1VwfK)izVKVTicvGBrxo7ZbVHuR6OsOFsgTK3)QheAF5W0CWBi1QoQW7F1dcTp5lI4giKH(PCGqoK4e3hKm0pLdeYbs5u9RvbMSyR2OJkWEKfAF5i25u9RvH3)QheAFfypYcTVCGyoq(Cq(Jwn6HkWKfBa5YIT(xOZQocMnyzYUWYywO0zvhbZIdwOgp0(yH(veQrazVKrJ(0fSqHjahPVH2hl0DhGYrWurOgbYPx5W4g9PlYrKgB5GR(x9Gq7RWcLJ0GqQXcfVHuR6OsOFsgTK3)QheAF5W0CWBi1QoQW7F1dcTp5lI4giKH(PCGqoK4e3hKm0pLZ(CQ(1QW7F1dcTVcCl6ydwMGtZYywO0zvhbZIdwOgp0(yH(veQrazVKrJ(0fSqHjahPVH2hluMTd054buocMkc1iqo9khg3OpDro6LtLcreD5GR(x9Gq7dKJbYX13togihC1)QheAF5isDUCUoYzZWt5eDovkhyYzysW5898TCwnkhnkSq5iniKASqXBi1QoQe6NKrl59V6bH2xomkhJhAFsE3o4w0LJyNdobYYbYNdYF0QrpubO3Y7KWKtF2IcDw1rWSblteSyzmlu6SQJGzXblupGKI2uhj5gi07HLj7WcfMaCK(gAFSqX5gLdZeDXgMiSYXdOCSCWzfr5GdNbIC4Bg6HYb2J07jhbtfHAeiNELdJB0NUihUbICIohdFRW5WT3x9EYHVzOhcuyHA8q7Jf6srKS6mqWcLJ0GqQXc14H2x5RiuJaYEjJg9PlkK4e3h69KZ(CwENtIi(MHEizOFkhXohJhAFLVIqnci7LmA0NUOqItCFqse9n9a5W0Ce05SphMNZwhsqGiJbj4LCoGup5YPpBro7ZH55u9RvzRdjiqKXqX)YgSmbYLLXSqPZQocMfhSqnEO9Xc9XzWQfnciRg8dXcLJ0GqQXcfVHuR6OsOFsgTK3)QheAF5WOCmEO9j5D7GBrxoIDo7cluATiEip7tSqFCgSArJaYQb)qSblt29zzmlu6SQJGzXbluJhAFSqP)lMiYCYgbF2XjwOCKgesnwO4nKAvhvc9tYOL8(x9Gq7lhMkmh8gsTQJk0)ftezozJGp74KeMCgM5Sph8gsTQJkH(jz0sE)REqO9LdJYbVHuR6Oc9FXerMt2i4ZoojHjNHzoIDo7cl0Z(elu6)IjImNSrWNDCInyzYoqglJzHsNvDemloyHA8q7JfkyZGBreSSrvzVKrJ(0fSq5iniKASqHuo4nKAvhvc9tYOL8(x9Gq7lhMkmh8gsTQJk8(x9Gq7t(IiUbczOFkhiKJyYbBSZzPpBHerFtpqomnh8gsTQJkH(jz0sE)REqO9LdeZzFov)Av49V6bH2xbUfDSqp7tSqbBgClIGLnQk7LmA0NUGnyzYo7WYywO0zvhbZIdwOgp0(yH(4W8Dt2lPba6xDwO9XcLJ0GqQXcfs5u9RvH3)QheAFf4w0LZ(CWBi1QoQe6NKrl59V6bH2xomsyo4nKAvhv6t6bKK7JETYbBSZbVHuR6OsFspGKCF0RvocZbYYbISqp7tSqFCy(Uj7L0aa9Rol0(ydwMSJyyzmlu6SQJGzXbluJhAFSq)g3Qisc2ikKFpq5Sq5iniKASqXBi1QoQe6NKrl59V6bH2xomvyo7cl0Z(el0VXTkIKGnIc53duoBWYKDWjSmMfkDw1rWS4Gfkmb4i9n0(yHk4x54b69KJLdiiuRW50Ny7buoAqFSYXCImmb54buockezWlfr5Wmraa5YP9bqHPC6vo4Q)vpi0(k5GtfBesKciSY5fPnsdLzgkhpqVNCeuiYGxkIYHzIaaYLJin2Ybx9V6bH2xo95WmhDLJG)we6mxo4YaCdMYrb5qNvDeCo2bNJLJhypuoI6ddrovkhxdICA8ekNyJYb2JSq7lNELtSr5S0NTOKdJ3uqogmmihlhW3CUCWBopLt05eBuo8UDWTOlNELJGcrg8sruomteaqUCeTrxoWTEp5eBkihU54ENfAF5ujU5buoAKJcYXFiYCGq55eDoga4)uoXMf5OroIuNlNkLJhqW58sOfXdhM50xo8UDWTORWc9SpXcfgrg8srKepbaKJfkhPbHuJfkKYP6xRcV)vpi0(kWTOlN95G3qQvDuj0pjJwY7F1dcTVCyKWCWBi1QoQ0N0dij3h9ALd2yNdEdPw1rL(KEaj5(OxRCeMdKLdeZzFoqkNQFTk6Ti0zoj3aCdMkGW4mKJWCQ(1QO3IqN5KCdWnyQ8nXLGW4mKd2yNdZZH3hSxJIElcDMtYna3GPcDw1rW5Gn25G3qQvDuH3)QheAFY(KEaLd2yNdEdPw1rLq)KmAjV)vpi0(YHr5OxqO32zbblx6Zwir030dKJGDo5aPCmEO9j5D7GBrxoqiNDGSCGyoqKfQXdTpwOWiYGxkIK4jaGCSblt2rqZYywO0zvhbZIdwOgp0(yHcAVtQpNgeIfkhPbHuJfkKYbVHuR6OsOFsgTK3)QheAF5WiH5GtGSCG85aPCWBi1QoQ0N0dij3h9ALdJYbYYbI5Gn25aPCyEobspgOOe7uuqb0ENuFoniuo7Zjq6XafLyNIhyvhLZ(CcKEmqrj2PW72b3IUcI(MEGCWg7CyEobspgOOeIPOGcO9oP(CAqOC2NtG0JbkkHykEGvDuo7Zjq6XafLqmfE3o4w0vq030dKdeZbI5SphiLdZZHygE99LGlWiYGxkIK4jaGC5Gn25W72b3IUcmIm4LIijEcaixbrFtpqomkNDjhiYc9SpXcf0ENuFonieBWYKD2fwgZcLoR6iywCWc14H2hluUDCYjR(1IfkhPbHuJfkZZH3hSxJIElcDMtYna3GPcDw1rW5SpNq)uomnNDjhSXoNQFTk6Ti0zoj3aCdMkGW4mKJWCQ(1QO3IqN5KCdWnyQ8nXLGW4mWcT6xl5zFIfkO9oP(CAO9XcfMaCK(gAFSqzmsFEiuoqBVlhb)ZPbHYHmKdZCePXwoc(BrOZC5GldWnykNgLJOn6YrJCezGCEre3arHnyzYo40SmMfkDw1rWS4Gfkmb4i9n0(yHk4d6dYj2Sih4oNRJCQ0rlnYbx9V6bH2xoGT27GZHzUhe5uPC8acoN2hafMYPx5GR(x9Gq7lhlYb0FkN3wVOWc9SpXcvpah5dR6ijZWBx4)sycVYjwOCKgesnwOeZWRVVeC5XzWQfnciRg8dLZ(CGuov)Av49V6bH2xbUfD5Sph8gsTQJkH(jz0sE)REqO9LdJeMdEdPw1rL(KEaj5(OxRCWg7CWBi1QoQ0N0dij3h9ALJWCGSCGiluJhAFSq1dWr(WQosYm82f(VeMWRCInyzYocwSmMfkDw1rWS4GfQXdTpwOlN9jzVKvlchXcLJ0GqQXcLygE99LGlpodwTOraz1GFOC2NdKYP6xRcV)vpi0(kWTOlN95G3qQvDuj0pjJwY7F1dcTVCyKWCWBi1QoQ0N0dij3h9ALd2yNdEdPw1rL(KEaj5(OxRCeMdKLdezHE2NyHUC2NK9swTiCeBWYKDGCzzmlu6SQJGzXbluJhAFSqfzmqhHaYfQpywOCKgesnwOeZWRVVeC5XzWQfnciRg8dLZ(CGuov)Av49V6bH2xbUfD5Sph8gsTQJkH(jz0sE)REqO9LdJeMdEdPw1rL(KEaj5(OxRCWg7CWBi1QoQ0N0dij3h9ALJWCGSCGil0Z(elurgd0riGCH6dMnyzYo7(SmMfkDw1rWS4GfQXdTpwO6bcKNhnciHv86rYk5CSq5iniKASqjMHxFFj4YJZGvlAeqwn4hkN95aPCQ(1QW7F1dcTVcCl6YzFo4nKAvhvc9tYOL8(x9Gq7lhgjmh8gsTQJk9j9asY9rVw5Gn25G3qQvDuPpPhqsUp61khH5az5arwON9jwO6bcKNhnciHv86rYk5CSbltedKXYywO0zvhbZIdwOgp0(yHc8x11nS0(uSHjiyHYrAqi1yHsmdV((sWLhNbRw0iGSAWpuo7Zbs5u9RvH3)QheAFf4w0LZ(CWBi1QoQe6NKrl59V6bH2xomsyo4nKAvhv6t6bKK7JETYbBSZbVHuR6OsFspGKCF0RvocZbYYbISqp7tSqb(R66gwAFk2WeeSblteZoSmMfkDw1rWS4GfkhPbHuJfA1VwfE)REqO9vGBrxo7ZbVHuR6OsOFsgTK3)QheAF5WiH5G3qQvDuPpPhqsUp61khSXoh8gsTQJk9j9asY9rVw5imhiJfQXdTpwOEaj1G(a2GLjIrmSmMfkDw1rWS4GfQXdTpwOludc514nwOWeGJ03q7Jf6Udq5GZOge5WKgVLt05ei95Hq5S7HuGdZCe8CL7OcluosdcPgluK)OvJEOYdsbomLkx5oQqNvDeCo7ZP6xRcV)vpi0(kWTOlN95aPCWBi1QoQe6NKrl59V6bH2xomkhJhAFsE3o4w0Ld2yNdEdPw1rLq)KmAjV)vpi0(YHP5G3qQvDuH3)QheAFYxeXnqid9t5aHCiXjUpizOFkhiYgSmrm4ewgZcLoR6iywCWc14H2hluE7VGqGxY5yHctaosFdTpwO7EuKtSr5iOuaxFD6zimZbx9)BhCov)ALJ)fRC8NJaGC49V6bH2xokihq3xHfkhPbHuJfkYF0QrpubwbC91PNHWuY7)3o4cDw1rW5SphE3o4w0vQ(1scRaU(60Zqyk59)BhCbrgmM5SpNQFTkWkGRVo9meMsE))2blne3oQa3IUC2NdZZP6xRcSc46RtpdHPK3)VDWf)Bo7Zbs5G3qQvDuj0pjJwY7F1dcTVCGqogp0(kludIA7Ic3aHm0pLdJYH3TdUfDLQFTKWkGRVo9meMsE))2bxG9il0(YbBSZbVHuR6OsOFsgTK3)QheAF5W0C2LCGiBWYeXiOzzmlu6SQJGzXbluosdcPgluK)OvJEOcSc46RtpdHPK3)VDWf6SQJGZzFo8UDWTORu9RLewbC91PNHWuY7)3o4cImymZzFov)AvGvaxFD6zimL8()TdwAiUDubUfD5SphMNt1VwfyfW1xNEgctjV)F7Gl(3C2NdKYbVHuR6OsOFsgTK3)QheAF5aHCiXjUpizOFkhiKJXdTVYc1GO2UOWnqid9t5WOC4D7GBrxP6xljSc46RtpdHPK3)VDWfypYcTVCWg7CWBi1QoQe6NKrl59V6bH2xomnNDjN95W8CcZrxuq(JK9s(2IiuHoR6i4CGiluJhAFSqne3ossI)6AG2hBWYeXSlSmMfkDw1rWS4GfkhPbHuJfkYF0QrpubwbC91PNHWuY7)3o4cDw1rW5SphE3o4w0vQ(1scRaU(60Zqyk59)BhCbrFtpqomnhUbczOFkN95u9RvbwbC91PNHWuY7)3oy5c1GOa3IUC2NdZZP6xRcSc46RtpdHPK3)VDWf)Bo7Zbs5G3qQvDuj0pjJwY7F1dcTVCGqoCdeYq)uomkhE3o4w0vQ(1scRaU(60Zqyk59)BhCb2JSq7lhSXoh8gsTQJkH(jz0sE)REqO9LdtZzxYbISqnEO9XcDHAquBxWgSmrm40SmMfkDw1rWS4GfkhPbHuJfkYF0QrpubwbC91PNHWuY7)3o4cDw1rW5SphE3o4w0vQ(1scRaU(60Zqyk59)BhCbrgmM5SpNQFTkWkGRVo9meMsE))2blxOgef4w0LZ(CyEov)AvGvaxFD6zimL8()TdU4FZzFoqkh8gsTQJkH(jz0sE)REqO9LdJYH3TdUfDLQFTKWkGRVo9meMsE))2bxG9il0(YbBSZbVHuR6OsOFsgTK3)QheAF5W0C2LCGiluJhAFSqxOgeYRXBSblteJGflJzHsNvDemloyH2VSqbuWc14H2hlu8gsTQJyHctaosFdTpwO7A3UCmqoF7WmhCwruo4WzGaKJbY5TbaT6OCwnkhC1)QheAFLCG6RbY4roTpYPx5eBuolKXdTpZLdV)V9rxKtVYj2OCo)VsOC6vo4SIOCWHZabiNyZICePoxoNfEK5CyMdI4Bg6HYb2J07jNyJYbx9V6bH2xoVBgGYPsCZdOCE72P3to2HzSP3toVgiYj2SihrQZLZ1ropi7ICSlhs8az5GZkIYbhode5a7r69KdU6F1dcTVclu8MZtSqXBi1QoQqIh0btWsE)REqO9jr030dKdtZbVHuR6OsOFsgTK3)QheAF5SphJhAFLLIiz1zGOW3m0dbKlKXdTpZLdeYbs5G3qQvDuj0pjJwY7F1dcTVCGqogp0(kGnDf69iFBreQS8oNerWEEO9LdKph8gsTQJkGnDf69iFBreswPvJijV)vpi0(Ybc5aPCGPQFTkFfHAeq2lz0OpDr5BIlbHXzihXoNDYbI5a5ZbVHuR6OYVdjI4Bg6HK2V9xKdKphEJNo7IcE6Inmr5a5Zbs5W72b3IUYxrOgbK9sgn6txuq030dKdtfMdEdPw1rLq)KmAjV)vpi0(YbI5aXCWDo8UDWTORSuejRodefypYcTVCe7C2jhMMdVBhCl6klfrYQZar5BIl5Bg6Ha5aHCWBi1QoQ04j0B3o5srKS6mqaYb35W72b3IUYsrKS6mquG9il0(YrSZbs5u9RvH3)QheAFfypYcTVCWDo8UDWTORSuejRodefypYcTVCGyo5iyNZo5Sph8gsTQJkH(jz0sE)REqO9LdtZzPpBHerFtpalupGK9AjF4WSmzhwO4nK8SpXcDPiswDgiKVD707HfQhqsrBQJKCde69WYKDydwMigixwgZcLoR6iywCWcLJ0GqQXcfVHuR6OsOFsgTK3)QheAF5WuH5az5Gn25u9RvH3)QheAFf)BoyJDo4nKAvhvc9tYOL8(x9Gq7lhMMdEdPw1rfE)REqO9jFre3aHm0pLZ(C4D7GBrxH3)QheAFfe9n9a5W0CWBi1QoQW7F1dcTp5lI4giKH(jwOgp0(yHYnNtA8q7t6uqWc1PGqE2NyHY7F1dcTp57Mbi2GLjIz3NLXSqPZQocMfhSq5iniKASqR(1QW7F1dcTVcCl6YzFov)Avq(JK9s(2IiubUfD5SphMNt1VwLLIiq0OFbrgpYzFoqkh8gsTQJkH(jz0sE)REqO9LdJeMt1VwfK)izVKVTicvG9il0(YzFo4nKAvhvc9tYOL8(x9Gq7lhgLJXdTVYsrKS6mquwENtIi(MHEizOFkhSXoh8gsTQJkH(jz0sE)REqO9LdJYzPpBHerFtpqoqmN95aPCyEoi)rRg9qfG)KmO3dqwDeaO3tHoR6i4CWg7CmEO4jjD0xjqomsyo4nKAvhv2meSKBGqUC2NabszGYbBSZP6xRcWFsg07biRoca07rIidgZI)nhSXoNQFTka)jzqVhGS6iaqVNcImEKdJeMt1VwfG)KmO3dqwDeaO3t5BIlbHXzihXoNDYbBSZzPpBHerFtpqomnNQFTki)rYEjFBreQa7rwO9LdezHA8q7JfkYFKSxY3weHydwMGtGmwgZcLoR6iywCWc1diPOn1rsUbc9EyzYoSqnEO9XcfVHuR6iwO9lluafSq5iniKASqzEo4nKAvhvwkIKvNbc5B3o9EYzFoi)rRg9qfG)KmO3dqwDeaO3tHoR6iywOEaj71s(WHzzYoSqXBopXcfqgsVhz0E(wX4HINYzFogp0(klfrYQZarz5DojI4Bg6HKH(PCyuo4KCG858WHlFtCwOWeGJ03q7JfkZgMzUhe5eBuo4nKAvhLtSzro8(cu7a5GZkIYbhode54b2dLt05am8uo4SIOCWHZabihrBQJYbkzi9EYHXTNVLJcYX4HINYrKgB5a1F5WSQ3dga5Gdhba69uyHI3qYZ(el0LIiz1zGq(2TtVh2GLj4KDyzmlu6SQJGzXbluycWr6BO9XcLzzJUC8a9EYbND2NabszGYrVCWv)REqO9HvoadpLJbY5BhM5W3m0dbYXa582aGwDuoRgLdU6F1dcTVCePXw7JC427REpfwOgp0(yHYnNtA8q7t6uqWcfeiLhSmzhwOCKgesnwOv)Avq(JK9s(2IiuX)MZ(CQ(1QW7F1dcTVcCl6YzFo4nKAvhvc9tYOL8(x9Gq7lhgLdKXc1PGqE2NyHI6x57Mbi2GLj4eXWYywO0zvhbZIdwOEajfTPosYnqO3dlt2HfQXdTpwO4nKAvhXcTFzHcOGfkhPbHuJfkZZbVHuR6OYsrKS6mqiF72P3to7ZjmhDrb5ps2l5BlIqf6SQJGZzFov)Avq(JK9s(2IiubUfDSq9as2RL8HdZYKDyHI3CEIfkKYH55G8hTA0dva(tYGEpaz1raGEpf6SQJGZbBSZP6xRcWFsg07biRoca07PacJZqomkNQFTka)jzqVhGS6iaqVNY3exccJZqoIDo7KdeZzFo8UDWTORG8hj7L8TfrOcI(MEGCyAogp0(klfrYQZarz5DojI4Bg6HKH(PCe7CmEO9vaB6k07r(2Iiuz5DojIG98q7lhiFoqkh8gsTQJkGnDf69iFBreswPvJijV)vpi0(YzFo8UDWTORa20vO3J8TfrOcI(MEGCyAo8UDWTORG8hj7L8TfrOcI(MEGCGyo7ZH3TdUfDfK)izVKVTicvq030dKdtZzPpBHerFtpaluycWr6BO9XcLzdZm3dICInkh8gsTQJYj2SihEFbQDGCWzfr5GdNbIC8a7HYj6COd4ruoAaYHVzOhcKJHOCmhOZ5TBhbNZQr5i48hLtVYzxBreQWcfVHKN9jwOlfrYQZaH8TBNEpSbltWj4ewgZcLoR6iywCWc1diPOn1rsUbc9EyzYoSq5iniKASqzEo4nKAvhvwkIKvNbc5B3o9EYzFo4nKAvhvc9tYOL8(x9Gq7lhgLdKLZ(CmEO4jjD0xjqomsyo4nKAvhv2meSKBGqUC2NabszGYzFompNLIiqyOGqfJhkEkN95W8CQ(1QS1HeeiYyO4FZzFoqkNQFTkBKf69i9Vf)Bo7ZX4H2xz5SpbcKYaviXjUpijI(MEGCyAoqwzxYbBSZHVzOhcixiJhAFMlhgjmhXKdezH6bKSxl5dhMLj7Wc14H2hl0LIiz1zGGfkmb4i9n0(yHYSSrxoqogcMBGqVNCWzN9jqGugiSYbNveLdoCgia5a2AVdoNkLJhqW5eDop0rilOCGC6ihObImga5yhCorNdjEqhCo4WzGGq5iyAGGqf2GLj4ebnlJzHsNvDemloyH6bKu0M6ij3aHEpSmzhwOCKgesnwOlfrGWqbHkgpu8uo7ZbVHuR6OsOFsgTK3)QheAF5WOCGSC2NdZZbVHuR6OYsrKS6mqiF72P3to7Zbs5W8CmEO9vwkIQMZviXjUp07jN95W8CmEO9vEXe1vNbIIEYLtF2IC2Nt1VwLnYc9EK(3cImEKd2yNJXdTVYsru1CUcjoX9HEp5SphMNt1VwLToKGargdfez8ihSXohJhAFLxmrD1zGOONC50NTiN95u9RvzJSqVhP)TGiJh5SphMNt1VwLToKGargdfez8ihiYc1dizVwYhomlt2HfQXdTpwOlfrYQZabluycWr6BO9Xcvq5r69KdoRicegkiew5GZkIYbhodeGCmeLJhqW5a0V6mKdZCIohypsVNCWv)REqO9vYz3JoczohMyLtSryMJHOC8acoNOZ5HoczbLdKth5anqKXaihrB0LdhPbihrQZLZ1rovkhrgii4CSdohrASLdoCgiiuocMgiiew5eBeM5a2AVdoNkLd4frgCoTpYj6C(MEHPxoXgLdoCgiiuocMgiiuov)AvydwMGt2fwgZcLoR6iywCWc1diPOn1rsUbc9EyzYoSqHjahPVH2hluMn(wHZHBVV69KdoRikhC4mqKdFZqpeihrBQJYHVz3ro9EYb6MUc9EYzxBreIfQXdTpwOlfrYQZabluosdcPgluJhAFfWMUc9EKVTicviXjUp07jN95S8oNer8nd9qYq)uomnhJhAFfWMUc9EKVTicvcLZGerWEEO9XgSmbNGtZYywO0zvhbZIdwOCKgesnwO4nKAvhvc9tYOL8(x9Gq7lhgLdKLZ(CQ(1QG8hj7L8TfrOcCl6YzFov)Av49V6bH2xbUfDSqnEO9XcLBoN04H2N0PGGfQtbH8SpXcfe2bBiyjQdl0(ydwMGteSyzmluJhAFSqb8gX3yHsNvDemloyd2GfkQFLVBgGyzmlt2HLXSqPZQocMfhSqnEO9XcD5SpbcKYaXcfMaCK(gAFSqfuKZWmhC1)QheAF5SAuocMkc1iqo9khg3OpDrHfkhPbHuJfQXdfpjPJ(kbYHrcZbVHuR6OYwhsqGiJb5YzFceiLbkN95aPCQ(1QS1HeeiYyO4FZbBSZP6xRYsreiA0V4FZbISbltedlJzHsNvDemloyHYrAqi1yHw9RvbMSyR2OJk(3C2NdYF0QrpubMSydixwS1)cDw1rW5Sph8gsTQJkH(jz0sE)REqO9LdtZP6xRcmzXwTrhvq030dKZ(CmEO4jjD0xjqomsyoIHfQXdTpwOlfrvZ5ydwMGtyzmlu6SQJGzXbluosdcPgluJhkEssh9vcKdJeMdEdPw1rLndbl5giKlN9jqGugOC2Nt1VwfG)KmO3dqwDeaO3JergmMf)Bo7ZP6xRcWFsg07biRoca07rIidgZcI(MEGCyuoCdeYq)eluJhAFSqxo7tGaPmqSblte0SmMfkDw1rWS4GfkhPbHuJfA1VwfG)KmO3dqwDeaO3JergmMf)Bo7ZP6xRcWFsg07biRoca07rIidgZcI(MEGCyuoCdeYq)eluJhAFSqFXe1vNbc2GLj7clJzHsNvDemloyHYrAqi1yHw9RvzPicen6x8VSqnEO9Xc9ftuxDgiydwMGtZYywO0zvhbZIdwOCKgesnwOv)Av26qccezmu8VSqnEO9Xc9ftuxDgiydwMiyXYywO0zvhbZIdwOEajfTPosYnqO3dlt2HfkhPbHuJfkZZbVHuR6OYsrKS6mqiF72P3to7ZP6xRcWFsg07biRoca07rIidgZcCl6YzFogpu8KKo6ReihMMdEdPw1rLndbl5giKlN9jqGugOC2NdZZzPicegkiuX4HINYzFoqkhMNt1VwLnYc9EK(3I)nN95W8CQ(1QS1HeeiYyO4FZzFompNxeHx2RL8HdxwkIKvNbIC2NdKYX4H2xzPiswDgik8nd9qGCyKWCetoyJDoqkNWC0ffZrIdcKbyMXaYLhHzHoR6i4C2NdVBhCl6kWi7PpGSIil2kiYGXmhiMd2yNdGmKEpYO98TIXdfpLdeZbISq9as2RL8HdZYKDyHA8q7Jf6srKS6mqWcfMaCK(gAFSq3DakN(OCWzfr5GdNbICid5Wmh9YrW17Ao6khmBFoW9HHiNndpLdPXgHYbYHSqVNC2DV50OCGC6ihObImgYbtkYXo4Cin2iKyLdKmiMZMHNY53ikNyZUCcrDoMdrgmMyLdKQqmNndpLdZ2rIdcKbyMXWaihC2JWmhezWyMt054bew50OCGehI5aLmKEp5W42Z3Yrb5y8qXtLCeu9HHih4oNytb5iAtDuoBgcohUbc9EYbND2NabszGa50OCeTrxoq9xomR69Gbqo4WraGEp5OGCqKbJzHnyzcKllJzHsNvDemloyH6bKu0M6ij3aHEpSmzhwOCKgesnwOmph8gsTQJklfrYQZaH8TBNEp5SphMNZsreimuqOIXdfpLZ(CQ(1Qa8NKb9EaYQJaa9EKiYGXSa3IUC2NdKYbs5aPCmEO9vwkIQMZviXjUp07jN95aPCmEO9vwkIQMZviXjUpijI(MEGCyAoqwzxYbBSZH55G8hTA0dvwkIarJ(f6SQJGZbI5Gn25y8q7R8IjQRodefsCI7d9EYzFoqkhJhAFLxmrD1zGOqItCFqse9n9a5W0CGSYUKd2yNdZZb5pA1OhQSuebIg9l0zvhbNdeZbI5SpNQFTkBKf69i9Vfez8ihiMd2yNdKYbqgsVhz0E(wX4HINYzFoqkNQFTkBKf69i9Vfez8iN95W8CmEO9va8gX3kK4e3h69Kd2yNdZZP6xRYwhsqGiJHcImEKZ(CyEov)Av2il07r6FliY4ro7ZX4H2xbWBeFRqItCFO3to7ZH55S1HeeiYyqcEjNdi1tUC6ZwKdeZbI5arwOEaj71s(WHzzYoSqnEO9XcDPiswDgiyHctaosFdTpwO7oaLdoRikhC4mqKdPXgHYb2J07jhlhCwru1CoCVRyI6QZaroCde5iAJUCGCil07jND3BokihJhkEkNgLdShP3toK4e3huoI0ylhOKH07jhg3E(wHnyzYUplJzHsNvDemloyHA8q7Jfk3CoPXdTpPtbbluNcc5zFIfQXdfpjdZrxaydwMSdKXYywO0zvhbZIdwOCKgesnwOv)AvEXe1CNb(fez8iN95Wnqid9t5W0CQ(1Q8IjQ5od8li6B6bYzFoCdeYq)uomnNQFTki)rYEjFBreQGOVPhiN95aPCyEoi)rRg9qfG)KmO3dqwDeaO3tHoR6i4CWg7CQ(1Q8IjQ5od8li6B6bYHP5y8q7RSuevnNRWnqid9t5aHC4giKH(PCG85u9Rv5ftuZDg4xqKXJCGiluJhAFSqFXe1vNbc2GLj7SdlJzHsNvDemloyHYrAqi1yHw9RvzRdjiqKXqX)MZ(CaKH07rgTNVvmEO4PC2NJXdfpjPJ(kbYHP5G3qQvDuzRdjiqKXGC5SpbcKYaXc14H2hl0xmrD1zGGnyzYoIHLXSqPZQocMfhSq5iniKASqzEo4nKAvhvE3A6uXLVD707jN95aPCmEO4jjChf950GYHP5iMCWg7CmEO4jjD0xjqomsyo4nKAvhv2meSKBGqUC2NabszGYbBSZX4HINK0rFLa5WiH5G3qQvDuzRdjiqKXGC5SpbcKYaLdezHA8q7Jf67wtNkUC5SpbydwMSdoHLXSqPZQocMfhSq5iniKASqbKH07rgTNVvmEO4jwOgp0(yHc4nIVXgSmzhbnlJzHsNvDemloyHYrAqi1yHA8qXts6OVsGCyuoIHfQXdTpwOWi7PpGSIil2ydwMSZUWYywO0zvhbZIdwOCKgesnwOgpu8KKo6Reihgjmh8gsTQJkgIBhjjXFDnq7lN958TZkV8ihgjmh8gsTQJkgIBhjjXFDnq7t(TZYzFoHHEOOisJn92bYyHA8q7JfQH42rss8xxd0(ydwMSdonlJzHsNvDemloyHA8q7Jf6YzFceiLbIfkmb4i9n0(yHYSOXwo01(NTCcd9qbaRC0ihfKJLZJPxorNd3aro4SZ(eiqkduogiNL6Cekh9abzW50RCWzfrvZ5kSq5iniKASqnEO4jjD0xjqomsyo4nKAvhv2meSKBGqUC2NabszGydwMSJGflJzHA8q7Jf6sru1CowO0zvhbZId2GnyHY7F1dcTp57MbiwgZYKDyzmlu6SQJGzXbl0(LfkGcwOgp0(yHI3qQvDeluycWr6BO9XcvWae63ckNTwuoU(EYbx9V6bH2xoIuNlhNbICIn7yaKt05a1F5WSQ3dga5Gdhba69Kt05atbH(6r5S1IYbNveLdoCgia5a2AVdoNkLJhqWfwO4nNNyHw9RvH3)QheAFfe9n9a5aHCQ(1QW7F1dcTVcShzH2xoq(CGuo8UDWTORW7F1dcTVcI(MEGCyAov)Av49V6bH2xbrFtpqoqKfQhqYETKpCywMSdlu8gsE2NyHsIh0btWsE)REqO9jr030dWc1diPOn1rsUbc9EyzYoSbltedlJzHsNvDemloyH6bKu0M6ij3aHEpSmzhwOWeGJ03q7JfkZgggKtSr5a7rwO9LtVYj2OCG6VCyw17bdGCWHJaa9EYbx9V6bH2xorNtSr5qhCo9kNyJYH7ri6ICWv)REqO9LJUYj2OC4giYru7DW5acdf5a7r69KtSPGCWv)REqO9vyH2VSqnyywOCKgesnwOi)rRg9qfG)KmO3dqwDeaO3tHoR6i4C2NdKYP6xRcWFsg07biRoca07rIidgZI)nhSXoh8gsTQJkK4bDWeSK3)QheAFse9n9a5WOCE4Wfe9n9a5aHC2PSl5a5Z5Hdx(M45a5Zbs5u9Rvb4pjd69aKvhba69u(M4sqyCgYrSZP6xRcWFsg07biRoca07PacJZqoqmhiYcfV58elu8gsTQJkagQsypYcTpwOEaj71s(WHzzYoSqnEO9XcfVHuR6iwO4nK8SpXcLepOdMGL8(x9Gq7tIOVPhGnyzcoHLXSqPZQocMfhSqHjahPVH2hluCQyJq5W72b3IoqoXMf5a2AVdoNkLJhqW5isJTCWv)REqO9LdyR9o4C6ZHzovkhpGGZrKgB5yxogp8MlhC1)QheAF5WnqKJDW5CDKJin2YXYbQ)YHzvVhmaYbhoca07jNxuZlSqnEO9XcLBoN04H2N0PGGfkiqkpyzYoSq5iniKASqXBi1QoQqIh0btWsE)REqO9jr030dKdJYbVHuR6OcGHQe2JSq7JfQtbH8SpXcL3)QheAFsE3o4w0bydwMiOzzmlu6SQJGzXbluJhAFSq5MZjnEO9jDkiyH6uqip7tSqnEO4jzyo6caBWYKDHLXSqPZQocMfhSqnEO9XcLBhNCYQFTyHYrAqi1yHY8CauiR95bLqjKyGCLc6xEo7ZP6xRcV)vpi0(kWTOlN95u9Rvb4pjd69aKvhba69uaHXzihgLJyYzFoH5Olki)rYEjFBreQqNvDeCo7ZH3TdUfDfK)izVKVTicvq030dKdtZrmqgl0QFTKN9jwOa)jzqVhGS6iaqVhwOWeGJ03q7JfQGFLdu)LdZQEpyaKdoCeaO3toGW4maYXquoB6Zgw5WTJtUCIn6NtLwnIYbx9V6bH2xoGoNyZICInkhO(lhMv9EWaihC4iaqVNCErnphUD5uPCa2ICyMdm5mmj4C8xOUCSvqOCWv)REqO9LJin2AFKdsbmKtVYHe)vrwO9vydwMGtZYywO0zvhbZIdwOgp0(yHUC2NabszGyHctaosFdTpwOc(vo4Q)vpi0(Yrb5a3IoSY5frCde5a6pfB69KtLwnIYX4HI3c9EYrJcluosdcPgl0QFTk8(x9Gq7Ra3IUC2NdVBhCl6k8(x9Gq7RGOVPhihMMd3aHm0pLZ(CmEO4jjD0xjqomsyo4nKAvhv49V6bH2NC5SpbcKYaXgSmrWILXSqPZQocMfhSq5iniKASqR(1QW7F1dcTVcCl6YzFov)Ava(tYGEpaz1raGEpsezWyw8V5SpNQFTka)jzqVhGS6iaqVhjImymli6B6bYHr5Wnqid9tSqnEO9Xc9ftuxDgiydwMa5YYywO0zvhbZIdwOCKgesnwOv)Av49V6bH2xbUfD5SpNQFTkVyIAUZa)cImEKZ(CQ(1Q8IjQ5od8li6B6bYHr5Wnqid9tSqnEO9Xc9ftuxDgiydwMS7ZYywO0zvhbZIdwOCKgesnwOv)Av49V6bH2xbUfD5SphE3o4w0v49V6bH2xbrFtpqomnhUbczOFkN95W8C49b71OSC2NKgNJOq7RqNvDemluJhAFSqxkIQMZXgSmzhiJLXSqPZQocMfhSq5iniKASqR(1QW7F1dcTVcCl6YzFo8UDWTORW7F1dcTVcI(MEGCyAoCdeYq)eluJhAFSqb8gX3ydwMSZoSmMfkDw1rWS4GfQhqsrBQJKCde69WYKDyHYrAqi1yHU1HeeiYyqcEjNdi1tUC6ZwKJWCGSC2Nt1VwfE)REqO9vGBrxo7ZbVHuR6OsOFsgTK3)QheAF5WuH5az5SphiLdZZb5pA1OhQaRaU(60Zqyk59)BhCHoR6i4CWg7CQ(1QaRaU(60Zqyk59)BhCX)Md2yNt1VwfyfW1xNEgctjV)F7GLludII)nN95eMJUOG8hj7L8TfrOcDw1rW5SphE3o4w0vQ(1scRaU(60Zqyk59)BhCbrgmM5aXC2NdKYH55G8hTA0dvEqkWHPu5k3rf6SQJGZbBSZbMQ(1Q8GuGdtPYvUJk(3CGyo7Zbs5W8C4nE6SlkhXrTRrW5Gn25W72b3IUcmzXwTrhvq030dKd2yNt1VwfyYITAJoQ4FZbI5SphiLdZZH34PZUOGNUydtuoyJDo8UDWTOR8veQrazVKrJ(0ffe9n9a5aXC2NdKYX4H2x5tb1OIEYLtF2IC2NJXdTVYNcQrf9KlN(Sfse9n9a5WuH5G3qQvDuH3)QheAFsUbcjI(MEGCWg7CmEO9va8gX3kK4e3h69KZ(CmEO9va8gX3kK4e3hKerFtpqomnh8gsTQJk8(x9Gq7tYnqir030dKd2yNJXdTVYsru1CUcjoX9HEp5SphJhAFLLIOQ5CfsCI7dsIOVPhihMMdEdPw1rfE)REqO9j5giKi6B6bYbBSZX4H2x5ftuxDgikK4e3h69KZ(CmEO9vEXe1vNbIcjoX9bjr030dKdtZbVHuR6OcV)vpi0(KCdese9n9a5Gn25y8q7RSC2NabszGkK4e3h69KZ(CmEO9vwo7tGaPmqfsCI7dsIOVPhihMMdEdPw1rfE)REqO9j5giKi6B6bYbISq9as2RL8HdZYKDyHA8q7JfkV)vpi0(yHctaosFdTpwO4Q)vpi0(YbS1EhCovkhpGGZr0gD5eBuoViIBGihfKJ5(niYzPNc2i4cBWYKDedlJzHsNvDemloyHA8q7JfkYFKSxY3weHyHctaosFdTpwOco)r50RC21weHYHBxovkhpGGZrVCWv)REqO9LJUYrJCuqoWTOdRCQ(iNytb5a2AVdoN(CyMtLYbUpkhDLtSrikhfKZVruo4Q)vpi0(Yj0pLt05uPJwAKZc1)CIn7Yj2ieLJO27GZPs5Sq9ph7YbkZkoYbx9V6bH2xooliuHfkhPbHuJfA1VwfK)izVKVTicvGBrxo7ZbVHuR6OcjEqhmbl59V6bH2NerFtpqomkh8gsTQJkagQsypYcTp2GLj7Gtyzmlu6SQJGzXblupGKI2uhj5gi07HLj7WcLJ0GqQXcL55W7d2RrrVfHoZj5gGBWuHoR6i4C2NdZZbVHuR6OYsrKS6mqiF72P3to7Zbs5W8CauiR95bLqjKyGCLc6xEoyJDoWu1VwLVIqnci7LmA0NUOa3IUCWg7CQ(1Qa8NKb9EaYQJaa9EKiYGXSa3IUCWg7CmEO9vEXe1vNbIcjoX9HEp5aXC2Nt1VwfE)REqO9v8V5SphMNt1VwLLIiq0OFbrgpYzFompNQFTkBDibbImgkiY4ro7ZzRdjiqKXGe8sohqQNC50NTihiKt1VwLnYc9EK(3cImEKdKphiLZdhUGOVPhihgLdKLdeZHP5igwOEaj71s(WHzzYoSqnEO9XcDPiswDgiyHctaosFdTpwOmlAS1(ihb)Ti0zUCWLb4gmHvomZ9GihpGYbNveLdoCgia5iAJUCIncZCe1hgIC((JVLdhPbih7GZr0gD5GZkIarJ(5OGCGBrxHnyzYocAwgZcLoR6iywCWc1diPOn1rsUbc9EyzYoSqnEO9XcfVHuR6iwO9lluafSq5iniKASq5nE6SlkN(SfYLrSq9as2RL8HdZYKDyHI3CEIf6sreimuqOcI(MEGCyAo4nKAvhviXd6GjyjV)vpi0(Ki6B6bYzFoqkhEFWEnk6Ti0zoj3aCdMk0zvhbNZ(CWBi1QoQqI)s8GGLlfrYQZabihMMdEdPw1rLJiycwUuejRodeGCGyo7Zbs5W8CcZrxuq(JK9s(2IiuHoR6i4CWg7C4D7GBrxb5ps2l5BlIqfe9n9a5WOCWBi1QoQqIh0btWsE)REqO9jr030dKdeZbBSZX4HINK0rFLa5WiH5G3qQvDuH3)QheAFsWMUc9EKVTicXcfMaCK(gAFSq3DakhOB6k07jNDTfrOCG9i9EYbx9V6bH2xoI2OlNyJquogIY56ih6A)Zwo4SIOCWHZabihdVPoR6OCIoNL35Wmhs8Go4C0BrOZC5Wna3GPCSdoN(CyMJOn6YrW5pkNELZU2IiuokiN(YH3TdUfDfwO4nK8SpXc1dijytxHEpY3weHydwMSZUWYywO0zvhbZIdwOEajfTPosYnqO3dlt2HfkhPbHuJfkVpyVgf9we6mNKBaUbt5SphMNdEdPw1rLLIiz1zGq(2TtVNC2NdKYH55aOqw7ZdkHsiXa5kf0V8CWg7CGPQFTkFfHAeq2lz0OpDrbUfD5Gn25u9Rvb4pjd69aKvhba69irKbJzbUfD5Gn25y8q7R8IjQRodefsCI7d9EYbI5SphiLdEdPw1rfs8xIheSCPiswDgia5WiH5G3qQvDu5icMGLlfrYQZabihSXoNQFTk8(x9Gq7RGOVPhihMMZdhU8nXZbBSZbVHuR6OcjEqhmbl59V6bH2NerFtpqomvyov)Av0BrOZCsUb4gmvG9il0(YbBSZP6xRIElcDMtYna3GPcimod5W0CetoyJDov)Av0BrOZCsUb4gmvq030dKdtZ5Hdx(M45Gn25W72b3IUcytxHEpY3weHkiYGXmN95G3qQvDuXdijytxHEpY3weHYbI5SpNQFTk8(x9Gq7R4FZzFoqkhMNt1VwLLIiq0OFbrgpYbBSZP6xRIElcDMtYna3GPcI(MEGCyAoqwzxYbI5SphMNt1VwLToKGargdfez8iN95S1HeeiYyqcEjNdi1tUC6ZwKdeYP6xRYgzHEps)BbrgpYbYNdKY5Hdxq030dKdJYbYYbI5W0CedlupGK9AjF4WSmzhwOgp0(yHUuejRodeSblt2bNMLXSqPZQocMfhSqnEO9XcD5SpbcKYaXcfMaCK(gAFSqH(shCoqoDKd0argdGCG9i9EYbx9V6bH2xowKZM(SLZlsBKgywyHYrAqi1yHcPCQ(1QS1HeeiYyO4FZzFogpu8KKo6Reihgjmh8gsTQJk8(x9Gq7tUC2NabszGYbI5Gn25aPCQ(1QSuebIg9l(3C2NJXdfpjPJ(kbYHrcZbVHuR6OcV)vpi0(KlN9jqGugOCe7Cq(Jwn6HklfrGOr)cDw1rW5ar2GLj7iyXYywO0zvhbZIdwOgp0(yHImy1UqcEnedSqHjahPVH2hlubNbR2f5a91qmKdyR9o4CQuoEabNJin2YXYbYPJCGgiYyihezWyMt054buo6)tWQfKdZCSvqOCInkhUbICw6PGncuYHXBkihrQZLZzHhzohM5aOih)BowoqoDKd0argd5aEPlYz1OCInkNLEMlhqyCgYPx5i4my1UihOVgIHcluosdcPgl0QFTk8(x9Gq7R4FZzFoIjhiFov)Av26qccezmuqKXJCGqov)Av2il07r6FliY4roqiNToKGargdsWl5CaPEYLtF2ICeMJyydwMSdKllJzHsNvDemloyHYrAqi1yHw9RvzPicen6x8VSqnEO9Xc9ftuxDgiydwMSZUplJzHsNvDemloyHYrAqi1yHw9RvzRdjiqKXqX)MZ(CQ(1QW7F1dcTVI)LfQXdTpwOVyI6QZabBWYeXazSmMfkDw1rWS4GfkhPbHuJf6lIWlF4WLDkaEJ4B5SpNQFTkBKf69i9Vf)Bo7ZX4HINK0rFLa5W0CWBi1QoQW7F1dcTp5YzFceiLbkN95u9RvH3)QheAFf)lluJhAFSqFXe1vNbc2GLjIzhwgZcLoR6iywCWc14H2hluWMUc9EKVTicXcfMaCK(gAFSq3Da9EYb6MUc9EYzxBrekhypsVNCWv)REqO9Lt05Giq0ikhCwruo4WzGih7GZzx3A6uXZbND2NYHVzOhcKd3UCQuov6OLYvZHvovFKJh4nNdZC6ZHzo9LdZUfmkSq5iniKASqXBi1QoQ4bKeSPRqVh5BlIq5SpNQFTk8(x9Gq7R4FZzFomphJhAFLLIiz1zGOW3m0dbYzFogp0(kVBnDQ4YLZ(eOW3m0dbYHP5y8q7R8U10PIlxo7tGY3exY3m0dbydwMigXWYywO0zvhbZIdwOgp0(yHI8hj7L8TfriwOWeGJ03q7JfQGFLJLdu)LdZQEpyaKdoCeaO3toVOMNJO27GZPs54bemw5i48hLtVYzxBrekhWw7DW5uPC8acoNLIaro6kNyJYHexbHEp5i48hLtVYzxBrekhrQZLdj(RIOCG9i9EYj2OC4gikSq5iniKASqR(1Qa8NKb9EaYQJaa9EKiYGXS4FZzFov)Ava(tYGEpaz1raGEpsezWywq030dKdJYHeN4(GKH(PCGqogp0(klN9jqGugOc3aHm0pLZ(CQ(1QG8hj7L8TfrOcI(MEGCyAogp0(klN9jqGugOc3aHm0pLZ(CmEO4jjD0xjqomsyo4nKAvhv49V6bH2NC5SpbcKYaXgSmrm4ewgZcLoR6iywCWcLJ0GqQXcT6xRcWFsg07biRoca07rIidgZI)nN95u9Rvb4pjd69aKvhba69irKbJzbrFtpqomkhUbczOFkN95y8qXts6OVsGCyKWCWBi1QoQW7F1dcTp5YzFceiLbIfQXdTpwOlN9jqGugi2GLjIrqZYywO0zvhbZIdwOCKgesnwOv)Ava(tYGEpaz1raGEpsezWyw8V5SpNQFTka)jzqVhGS6iaqVhjImymli6B6bYHr5qItCFqYq)uoqihJhAFLxmrD1zGOWnqid9t5SpNQFTki)rYEjFBreQGOVPhihMMJXdTVYlMOU6mqu4giKH(jwOgp0(yHI8hj7L8Tfri2GLjIzxyzmlu6SQJGzXbluosdcPgl0QFTka)jzqVhGS6iaqVhjImyml(3C2Nt1VwfG)KmO3dqwDeaO3JergmMfe9n9a5WOC4giKH(jwOgp0(yH(IjQRodeSbltedonlJzHsNvDemloyHA8q7Jf6lMOU6mqWcfMaCK(gAFSq3vmrn3zGFoVOMdYbS1EhCovkhpGGZrVCWv)REqO9LJf5SPpBekNxK2inWmNyZUC21TMov8CWzN9jqo2bNduEJ4BfwOCKgesnwOv)AvEXe1CNb(fez8iN95u9Rv5ftuZDg4xq030dKdJYHBGqg6NYzFov)Av49V6bH2xbrFtpqomkhUbczOFkN95y8qXts6OVsGCyAo4nKAvhv49V6bH2NC5SpbcKYaLZ(CGuomphEFWEnk6Ti0zoj3aCdMk0zvhbNd2yNt1Vwf9we6mNKBaUbtfe9n9a5WOCiXjUpizOFkhSXoNQFTkBKf69i9Vfez8ihiKZwhsqGiJbj4LCoGup5YPpBromnhXKdezdwMigblwgZcLoR6iywCWc14H2hl03TMovC5YzFcWcfMaCK(gAFSq3DakNDDRPtfphC2zFcKJDW5aL3i(wo6LdU6F1dcTVCIoNnY9MZdDeYckhiNoYbAGiJbqoI2OlhCwruo4WzGaKJHOCUoYXWBQZQokNgLZreCorNtLYH3hGq4j4cluosdcPgl0QFTk8(x9Gq7R4FZzFobYWtozOFkhMMt1VwfE)REqO9vq030dKZ(CQ(1QSrwO3J0)wqKXJCGqoBDibbImgKGxY5as9KlN(Sf5W0CedBWYeXa5YYywO0zvhbZIdwOCKgesnwOv)Av49V6bH2xbrFtpqomkhUbczOFIfQXdTpwOaEJ4BSblteZUplJzHsNvDemloyHA8q7JfQtXR3JS2)kluycWr6BO9XcvWVYj2ieLJcome5qx7F2Yj0pLJJwro6LdU6F1dcTVCwnkhlNDDRPtfphC2zFcKtJYbkVr8TCIoNnnYrpGct50RCWv)REqO9HvoEaLdO)uSP3toKdqfwOCKgesnwOv)Av49V6bH2xbrFtpqomnNhoC5BINZ(CmEO4jjD0xjqomkNDydwMGtGmwgZcLoR6iywCWcLJ0GqQXcT6xRcV)vpi0(ki6B6bYHP58WHlFt8C2Nt1VwfE)REqO9v8VSqnEO9Xcfgzp9bKvezXgBWgSqnEO4jzyo6calJzzYoSmMfkDw1rWS4GfkhPbHuJfQXdfpjPJ(kbYHr5Sto7ZP6xRcV)vpi0(kWTOlN95aPCWBi1QoQe6NKrl59V6bH2xomkhE3o4w0vCkE9EK1(xlWEKfAF5Gn25G3qQvDuj0pjJwY7F1dcTVCyQWCGSCGiluJhAFSqDkE9EK1(xzdwMigwgZcLoR6iywCWcLJ0GqQXcfVHuR6OsOFsgTK3)QheAF5WuH5az5Gn25u9RvH3)QheAFfe9n9a5WOCcKHNCYq)uoyJDoqkhE3o4w0v(uqnQa7rwO9LdtZbVHuR6OsOFsgTK3)QheAF5SphMNtyo6IcYFKSxY3weHk0zvhbNdeZbBSZjmhDrb5ps2l5BlIqf6SQJGZzFov)Avq(JK9s(2IiuX)MZ(CWBi1QoQe6NKrl59V6bH2xomkhJhAFLpfuJk8UDWTOlhSXoNL(Sfse9n9a5W0CWBi1QoQe6NKrl59V6bH2hluJhAFSq)uqnInyzcoHLXSqPZQocMfhSq5iniKASqdZrxumhjoiqgGzgdixEeMf6SQJGZzFoqkNQFTk8(x9Gq7Ra3IUC2NdZZP6xRYwhsqGiJHI)nhiYc14H2hluyK90hqwrKfBSbBWcfe2bBiyjQdl0(yzmlt2HLXSqPZQocMfhSq5iniKASqnEO4jjD0xjqomsyo4nKAvhv26qccezmixo7tGaPmq5SphiLt1VwLToKGargdf)BoyJDov)AvwkIarJ(f)BoqKfQXdTpwOlN9jqGugi2GLjIHLXSqPZQocMfhSq5iniKASqR(1QatwSvB0rf)Bo7Zb5pA1OhQatwSbKll26FHoR6i4C2NdEdPw1rLq)KmAjV)vpi0(YHP5u9RvbMSyR2OJki6B6bYzFogpu8KKo6ReihgjmhXWc14H2hl0LIOQ5CSbltWjSmMfkDw1rWS4GfkhPbHuJfA1VwLLIiq0OFX)Yc14H2hl0xmrD1zGGnyzIGMLXSqPZQocMfhSq5iniKASqR(1QS1HeeiYyO4FZzFov)Av26qccezmuq030dKdtZX4H2xzPiQAoxHeN4(GKH(jwOgp0(yH(IjQRodeSblt2fwgZcLoR6iywCWcLJ0GqQXcT6xRYwhsqGiJHI)nN95aPCEreE5dhUStzPiQAoxoyJDolfrGWqbHkgpu8uoyJDogp0(kVyI6QZarrp5YPpBroqKfQXdTpwOVyI6QZabBWYeCAwgZcLoR6iywCWc14H2hl0LZ(eiqkdeluycWr6BO9XcLXimZj6CEOihOmR4iNxuZb5OhqHPCeC9UMZ7MbiqonkhC1)QheAF58UzacKJOn6Y5TbaT6OcluosdcPgluJhkEssh9vcKdJeMdEdPw1rLndbl5giKlN9jqGugOC2Nt1VwfG)KmO3dqwDeaO3JergmMf)Bo7Zbs5W72b3IUcYFKSxY3weHki6B6bYbc5y8q7RG8hj7L8TfrOcjoX9bjd9t5aHC4giKH(PCyuov)Ava(tYGEpaz1raGEpsezWywq030dKd2yNdZZjmhDrb5ps2l5BlIqf6SQJGZbI5Sph8gsTQJkH(jz0sE)REqO9LdeYHBGqg6NYHr5u9Rvb4pjd69aKvhba69irKbJzbrFtpaBWYeblwgZcLoR6iywCWcLJ0GqQXcT6xRYwhsqGiJHI)nN95aidP3JmApFRy8qXtSqnEO9Xc9ftuxDgiydwMa5YYywO0zvhbZIdwOCKgesnwOv)AvEXe1CNb(fez8iN95Wnqid9t5W0CQ(1Q8IjQ5od8li6B6bYzFoqkhMNdYF0Qrpub4pjd69aKvhba69uOZQocohSXoNQFTkVyIAUZa)cI(MEGCyAogp0(klfrvZ5kCdeYq)uoqihUbczOFkhiFov)AvEXe1CNb(fez8ihiYc14H2hl0xmrD1zGGnyzYUplJzHsNvDemloyH6bKu0M6ij3aHEpSmzhwOCKgesnwOmpNLIiqyOGqfJhkEkN95W8CWBi1QoQSuejRodeY3UD69KZ(CQ(1Qa8NKb9EaYQJaa9EKiYGXSa3IUC2NdKYbs5aPCmEO9vwkIQMZviXjUp07jN95aPCmEO9vwkIQMZviXjUpijI(MEGCyAoqwzxYbBSZH55G8hTA0dvwkIarJ(f6SQJGZbI5Gn25y8q7R8IjQRodefsCI7d9EYzFoqkhJhAFLxmrD1zGOqItCFqse9n9a5W0CGSYUKd2yNdZZb5pA1OhQSuebIg9l0zvhbNdeZbI5SpNQFTkBKf69i9Vfez8ihiMd2yNdKYbqgsVhz0E(wX4HINYzFoqkNQFTkBKf69i9Vfez8iN95W8CmEO9va8gX3kK4e3h69Kd2yNdZZP6xRYwhsqGiJHcImEKZ(CyEov)Av2il07r6FliY4ro7ZX4H2xbWBeFRqItCFO3to7ZH55S1HeeiYyqcEjNdi1tUC6ZwKdeZbI5arwOEaj71s(WHzzYoSqnEO9XcDPiswDgiyHctaosFdTpwOckpsVNCInkhqyhSHGZb1HfAFyLtFomZXdOCWzfr5GdNbcqoI2OlNyJWmhdr5CDKtL07jN3UDeCoRgLJGR31CAuo4Q)vpi0(k5S7auo4SIOCWHZaroKgBekhypsVNCSCWzfrvZ5W9UIjQRode5WnqKJOn6YbYHSqVNC2DV5OGCmEO4PCAuoWEKEp5qItCFq5isJTCGsgsVNCyC75Bf2GLj7azSmMfkDw1rWS4GfkhPbHuJfA1VwLToKGargdf)Bo7ZX4HINK0rFLa5W0CWBi1QoQS1HeeiYyqUC2NabszGyHA8q7Jf6lMOU6mqWgSmzNDyzmlu6SQJGzXbluosdcPgluMNdEdPw1rL3TMovC5B3o9EYzFoqkhMNtyo6IYc1FzSrsdSrGcDw1rW5Gn25y8qXts6OVsGCyuo7KdeZzFoqkhJhkEsc3rrFonOCyAoIjhSXohJhkEssh9vcKdJeMdEdPw1rLndbl5giKlN9jqGugOCWg7CmEO4jjD0xjqomsyo4nKAvhv26qccezmixo7tGaPmq5arwOgp0(yH(U10PIlxo7ta2GLj7igwgZcLoR6iywCWc14H2hluU5CsJhAFsNccwOofeYZ(eluJhkEsgMJUaWgSmzhCclJzHsNvDemloyHYrAqi1yHA8qXts6OVsGCyuo7Wc14H2hluyK90hqwrKfBSblt2rqZYywO0zvhbZIdwOCKgesnwOaYq69iJ2Z3kgpu8eluJhAFSqb8gX3ydwMSZUWYywO0zvhbZIdwOCKgesnwOgpu8KKo6Reihgjmh8gsTQJkgIBhjjXFDnq7lN958TZkV8ihgjmh8gsTQJkgIBhjjXFDnq7t(TZYzFoHHEOOisJn92bYyHA8q7JfQH42rss8xxd0(ydwMSdonlJzHsNvDemloyHA8q7Jf6YzFceiLbIfkmb4i9n0(yHYSOXwo01(NTCcd9qbaRC0ihfKJLZJPxorNd3aro4SZ(eiqkduogiNL6Cekh9abzW50RCWzfrvZ5kSq5iniKASqnEO4jjD0xjqomsyo4nKAvhv2meSKBGqUC2NabszGydwMSJGflJzHA8q7Jf6sru1CowO0zvhbZId2GnyH(IiE)RwWYywMSdlJzHA8q7JfQH42rs9cY5iEWcLoR6iywCWgSmrmSmMfkDw1rWS4Gfkmb4i9n0(yHA8q7duEreV)vlGGqCJ3qQvDewN9jH9j9asY9rVwyH3CEsOyGmiG3qQvDuH(VyIiZjBe8zhNKWKZWelDjKygE99LGl0)ftezozJGp74eluJhAFSqxocSXr2kydwMGtyzmlu6SQJGzXbluJhAFSqbT3j1NtdcXcLJ0GqQXcL55G3qQvDuH3)QheAFY(KEaLZ(CyEoeZWRVVeCbgrg8srKepbaKlN95W8CcZrxuwkIaHHccvOZQocMf6zFIfkO9oP(CAqi2GLjcAwgZcLoR6iywCWc9SpXcfSzWTicw2OQSxYOrF6cwOgp0(yHc2m4weblBuv2lz0OpDbBWYKDHLXSqnEO9Xc9RiuJK63EiwO0zvhbZId2GLj40SmMfkDw1rWS4GfkhPbHuJfkZZ5fr4lVyI6QZabluJhAFSqFXe1vNbc2GnydwO4jeq7JLjIbYeJyGmbnKHtyHkYqNEpawOmlmBbhte8mz3tSYjhgVr5O)3gf5SAuoya1VY3ndqyiheXm8kIGZb0FkhZh93ccoh(MDpeOKcSB6r5igXkhC1hEcfeCoya5pA1OhQiiyiNOZbdi)rRg9qfbPqNvDemgYbs7ioelPa7MEuocwIvo4Qp8eki4CWqyo6IIGGHCIohmeMJUOiif6SQJGXqoqAhXHyjfy30JYbYvSYbx9HNqbbNdgq(Jwn6HkccgYj6CWaYF0Qrpurqk0zvhbJHCGKyehILuGDtpkNDGmXkhC1hEcfeCoya5pA1OhQiiyiNOZbdi)rRg9qfbPqNvDemgYbs7ioelPaPamlmBbhte8mz3tSYjhgVr5O)3gf5SAuoyaMwM3fyiheXm8kIGZb0FkhZh93ccoh(MDpeOKcSB6r5SJyLdU6dpHccohmG8hTA0dveemKt05GbK)OvJEOIGuOZQocgd5yrocg4u7woqAhXHyjfy30JYrqlw5GR(WtOGGZbdi)rRg9qfbbd5eDoya5pA1OhQiif6SQJGXqowKJGbo1ULdK2rCiwsb2n9OCWPfRCWvF4juqW5GbK)OvJEOIGGHCIohmG8hTA0dveKcDw1rWyihlYrWaNA3Ybs7ioelPa7MEuo7GteRCWvF4juqW5av)4khaMxyINJGTGDorNZU5TC(nS35b50VeYIgLdKeSHyoqAhXHyjfy30JYzhCIyLdU6dpHccohmW7d2RrrqWqorNdg49b71Oiif6SQJGXqoqAhXHyjfy30JYzhbTyLdU6dpHccohmei9yGIYofbbd5eDoyiq6XafLyNIGGHCGeorCiwsb2n9OC2rqlw5GR(WtOGGZbdbspgOOiMIGGHCIohmei9yGIsiMIGGHCGeorCiwsb2n9OC2zxeRCWvF4juqW5GbEFWEnkccgYj6CWaVpyVgfbPqNvDemgYbs7ioelPa7MEuoIrmIvo4Qp8eki4CWaYF0QrpurqWqorNdgq(Jwn6HkcsHoR6iymKdK2rCiwsb2n9OCedorSYbx9HNqbbNdgq(Jwn6HkccgYj6CWaYF0Qrpurqk0zvhbJHCG0oIdXskWUPhLJye0Ivo4Qp8eki4CWqyo6IIGGHCIohmeMJUOiif6SQJGXqoqAhXHyjfy30JYrmcAXkhC1hEcfeCoya5pA1OhQiiyiNOZbdi)rRg9qfbPqNvDemgYbs7ioelPa7MEuoIzxeRCWvF4juqW5GbK)OvJEOIGGHCIohmG8hTA0dveKcDw1rWyihiTJ4qSKcSB6r5igCAXkhC1hEcfeCoya5pA1OhQiiyiNOZbdi)rRg9qfbPqNvDemgYbs7ioelPa7MEuoIrWsSYbx9HNqbbNdu9JRCayEHjEoc25eDo7M3YbwXRaTVC6xczrJYbs4gI5ajCI4qSKcSB6r5igblXkhC1hEcfeCoq1pUYbG5fM45iylyNt05SBElNFd7DEqo9lHSOr5ajbBiMdK2rCiwsb2n9OCeZUVyLdU6dpHccohmG8hTA0dveemKt05GbK)OvJEOIGuOZQocgd5aPDehILuGDtpkhCcKjw5GR(WtOGGZbdi)rRg9qfbbd5eDoya5pA1OhQiif6SQJGXqowKJGbo1ULdK2rCiwsb2n9OCWjIrSYbx9HNqbbNdgq(Jwn6HkccgYj6CWaYF0Qrpurqk0zvhbJHCG0oIdXskWUPhLdormIvo4Qp8eki4CWqyo6IIGGHCIohmeMJUOiif6SQJGXqoqAhXHyjfifGzHzl4yIGNj7EIvo5W4nkh9)2OiNvJYbdViI3)QfyiheXm8kIGZb0FkhZh93ccoh(MDpeOKcSB6r5GteRCWvF4juqW5GHWC0ffbbd5eDoyimhDrrqk0zvhbJHCSihbdCQDlhiTJ4qSKcKcWSWSfCmrWZKDpXkNCy8gLJ(FBuKZQr5GbE)REqO9j5D7GBrhad5GiMHxreCoG(t5y(O)wqW5W3S7HaLuGDtpkhCAXkhC1hEcfeCoya5pA1OhQiiyiNOZbdi)rRg9qfbPqNvDemgYbs7ioelPaPamlmBbhte8mz3tSYjhgVr5O)3gf5SAuoyW4HINKH5OlayiheXm8kIGZb0FkhZh93ccoh(MDpeOKcSB6r5igXkhC1hEcfeCoyimhDrrqWqorNdgcZrxueKcDw1rWyihijgXHyjfy30JYbNiw5GR(WtOGGZbdH5OlkccgYj6CWqyo6IIGuOZQocgd5aPDehILuGuaMfMTGJjcEMS7jw5KdJ3OC0)BJICwnkhmac7GneSe1HfAFyiheXm8kIGZb0FkhZh93ccoh(MDpeOKcSB6r5igXkhC1hEcfeCoya5pA1OhQiiyiNOZbdi)rRg9qfbPqNvDemgYbs7ioelPa7MEuo40Ivo4Qp8eki4CWqyo6IIGGHCIohmeMJUOiif6SQJGXqoqAhXHyjfy30JYbYvSYbx9HNqbbNdgq(Jwn6HkccgYj6CWaYF0Qrpurqk0zvhbJHCG0oIdXskWUPhLZUVyLdU6dpHccohmG8hTA0dveemKt05GbK)OvJEOIGuOZQocgd5ajXioelPa7MEuo7SJyLdU6dpHccohmeMJUOiiyiNOZbdH5OlkcsHoR6iymKdK2rCiwsbsbywy2coMi4zYUNyLtomEJYr)VnkYz1OCWaV)vpi0(KVBgGWqoiIz4vebNdO)uoMp6VfeCo8n7Eiqjfy30JYrmIvo4Qp8eki4CWaYF0QrpurqWqorNdgq(Jwn6HkcsHoR6iymKdK2rCiwsb2n9OC2fXkhC1hEcfeCoyimhDrrqWqorNdgcZrxueKcDw1rWyihiTJ4qSKcSB6r5S7lw5GR(WtOGGZbd8(G9AueemKt05GbEFWEnkcsHoR6iymKJf5iyGtTB5aPDehILuGDtpkND2rSYbx9HNqbbNdgcZrxueemKt05GHWC0ffbPqNvDemgYbs7ioelPa7MEuo7SJyLdU6dpHccohmG8hTA0dveemKt05GbK)OvJEOIGuOZQocgd5ajXioelPa7MEuo7GteRCWvF4juqW5GbEFWEnkccgYj6CWaVpyVgfbPqNvDemgYbs7ioelPa7MEuo7iOfRCWvF4juqW5GHWC0ffbbd5eDoyimhDrrqk0zvhbJHCG0oIdXskWUPhLZocAXkhC1hEcfeCoyG3hSxJIGGHCIohmW7d2Rrrqk0zvhbJHCG0oIdXskWUPhLZo40Ivo4Qp8eki4CWaYF0QrpurqWqorNdgq(Jwn6HkcsHoR6iymKdK2rCiwsb2n9OCedoTyLdU6dpHccohmW7d2RrrqWqorNdg49b71Oiif6SQJGXqoqAhXHyjfifqW)FBuqW5iyLJXdTVCCkiaLuawOVOEPoIfkgXyo4SIOCemThkfaJymNTiEbIfUX9JgB(AH3FCd0V3zH2hhzRa3a9ZXDkagXyom7xK6YzxWkhXazIrmPaPayeJ5GRn7EiGyLcGrmMJyNZUdq5S0NTqIOVPhihKfBekNyZUCcd9qrj0pjJwcRuoRgLJZaHydiEFW5yv1PbM54b2dbkPayeJ5i25SBDdOlhUbICqeZWRi6txaYz1OCWv)REqO9LdK0cvWkh4(WqKZw7GZrJCwnkhlNfIaB5iysb1OC4giGyjfaJymhXohbJZQokhqGuEKdFJ4mO3to9LJLZIeLZQrmaYrVCInkhM9UUB5eDoic2ZPCe1igCTbxsbWigZrSZHzdZm3dICSC2vmrD1zGih6ceM5eBwKdCtGCUoY53WKlhrKZLJEI9J9PCGeq)5eeii4CSiNRZbOpNUuUDrocQDfAo6)14belPayeJ5i25GR(WtOihZ5YP6xRIGuqKXJCOlqkbYj6CQ(1Qiif)lw5yxoM73Gih9a6ZPlLBxKJGAxHMZJPxo6Ldq)GskagXyoIDo7oaLZMHG5nmbNdEdPw1rGCIoheb75uo4Ax3D5iQrm4AdUKcKcGrmMJGH4e3heCovA1ikhE)RwKtLE0duYHzZ50BaY56tS3m0F5D5y8q7dKtFomlPagp0(aLxeX7F1ciie3gIBhj1liNJ4rkagXyom7DD3YHzYqQvDuo4uVH2NyLJGFLdGICIohlNRpXMzgc15G3CEcRCInkhC1)QheAF5y8q7lh7GZH3TdUfDGCInlYXquo8(abY0JGZj6C6ZHzovkhpGGZr0gD5GR(x9Gq7lhfKJ)nhrQZLZ1rovkhpGGZb2J07jNyJYbOFVZcTVskagZX4H2hO8IiE)RwabH4gVHuR6iSo7tcHvGvDKK3)QheAFy1VcreGIuamIXCy276ULdZKHuR6OCWPEdTpXkhgVPGCWBi1QokhWlX1LsGCeTrXgHYbx9V6bH2xoGT27GZPs54beCoWEKEp5GZkIaHHccvsbWyogp0(aLxeX7F1ciie34nKAvhH1zFs4sreimuqijV)vpi0(WcMwM3fcf7DWcV58KqMhMJUO8IjQ5od8XsxcXBi1QoQSuebcdfesY7F1dcTpMczPayeJ5WS31DlhMjdPw1r5Gt9gAFIvomEtb5G3qQvDuoGxIRlLa5eBuoN)xjuo9kNWqpuaYXICeTP8TCGC6ihObImgYbND2NabszGa50(aOWuo9khC1)QheAF5a2AVdoNkLJhqWLuamMJXdTpq5fr8(xTaccXnEdPw1ryD2NeU1HeeiYyqUC2NabszGWsxcXBi1QoQS1HeeiYyqUC2NabszGeczyH3CEsOyG8H5OlklN9j5Rf8niiOH8mpmhDrz5SpjFTGVLcGrmMdZEx3TCyMmKAvhLdo1BO9jw5W4nfKdEdPw1r5aEjUUucKtSr5C(FLq50RCcd9qbihlYr0MY3YbYXqW5Glde5GZo7tGaPmqGCAFauykNELdU6F1dcTVCaBT3bNtLYXdi4Cmqol15iujfaJ5y8q7duEreV)vlGGqCJ3qQvDewN9jHBgcwYnqixo7tGaPmqyPlH4nKAvhv2meSKBGqUC2NabszGeczyH3CEsiobYhMJUOSC2NKVwW3GaonKN5H5OlklN9j5Rf8TuamIXCy276ULdZKHuR6OCWPEdTpXkhgVPGCWBi1QokhWlX1LsGCInkNZ)RekNELtyOhka5yroI2u(woqoDKd0argd5GZo7tGaPmqGCmeLJhqW5a7r69KdU6F1dcTVskagZX4H2hO8IiE)RwabH4gVHuR6iSo7tc59V6bH2NC5SpbcKYaHLUeI3qQvDuH3)QheAFYLZ(eiqkdKqidl8MZtcXjq(WC0fLLZ(K81c(geWPH8mpmhDrz5SpjFTGVLcGrmMdZEx3TCyMmKAvhLdo1BO9jw5W4nfKdEdPw1r5aEjUUucKtSr5C(FLq50RCcd9qbihlYr0MY3YHzJ42r5iyi(RRbAF50(aOWuo9khC1)QheAF5a2AVdoNkLJhqWLuamMJXdTpq5fr8(xTaccXnEdPw1ryD2NeAiUDKKe)11aTpS0Lq8gsTQJkgIBhjjXFDnq7tiKHfEZ5jH7(7(q(WC0fLLZ(K81c(geedKN5H5OlklN9j5Rf8TuamIXCy276ULdZKHuR6OCWPEdTpXkhgVPGCWBi1QokhWlX1LsGCInkNxcXPlShkNELZ3olNk5Ar5iAt5B5WSrC7OCeme)11aTVCePoxoxh5uPC8acUKcGXCmEO9bkViI3)QfqqiUXBi1QocRZ(KqdXTJKK4VUgO9j)2zybtlZ7cHcAidR(viIauKcGrmMdZEx3TCyMmKAvhLdo1BO9jw5W4nkNZ)RekNELtyOhka5yroI2u(woq30vO3to7AlIq5WTlhpGGZb2J07jhC1)QheAFLuamMJXdTpq5fr8(xTaccXnEdPw1ryD2NeY7F1dcTpjytxHEpY3weHWsxcXBi1QoQW7F1dcTpjytxHEpY3weHeczyH3CEsiEdPw1rfE)REqO9jxo7tGaPmqPayeJ5WS31DlhMjdPw1r5Gt9gAFIvomEJYj0pLdI(ME69KtF5y5WnqKJOn6Ybx9V6bH2xoC7YPs54beCo6LdG49bdkPaymhJhAFGYlI49VAbeeIB8gsTQJW6SpjK3)QheAFsUbcjI(MEaSGPL5DHqiRiyHv)keraksbWigZHzVR7womtgsTQJYbN6n0(eRCy8McYbVHuR6OCaVexxkbYj2OCo)VsOC6voaI3hmiNELdoRikhC4mqKtSzroGT27GZPs582TJGZ51aroXgLdmTmVlYX(T)IskagZX4H2hO8IiE)RwabH4gVHuR6iSo7tcB8e6TBNCPiswDgiaybtlZ7cHqgw9RqebOifaJymhM9UUB5Wmzi1QokhCQ3q7tSYbYPfLJRVNCQ0Qruo4Q)vpi0(YbS1EhCocg)xmrK5YbNcbF2XPCQuoEabZmBkagZX4H2hO8IiE)RwabH4gVHuR6iSo7tcP)lMiYCYgbF2Xjjm5mmXcMwM3fc3bYfR(viIauKcGrmMJGFLdU6F1dcTVCuqoWkWQocgRCa8nc27OCInkNLIaro4Q)vpi0(YzzOCSvqOCInkNL(Sf5qhmOKcGXCmEO9bkViI3)QfqqiUXBi1QocRZ(KWq)KmAjV)vpi0(WcV58KWL(Sfse9n9aqyhidYWsxcXBi1QoQaRaR6ijV)vpi0(sbWigZHXBuoWEKfAF50RCSCG6VCyw17bdGCWHJaa9EYbx9V6bH2xjfaJ5y8q7duEreV)vlGGqCJ3qQvDewN9jHagQsypYcTpSWBopjeUYl0Ar8Oa5kgixbTyGSs1aKeV58ukagZHXBuoN)xjuo9khaX7dgKtVYbNveLdoCgiYbr8nd9qW5uXmhbtfHAeiNELdJB0NUOKcGXCmEO9bkViI3)QfqqiUXBi1QocRZ(KWFhseX3m0djTF7Val8MZtcHR8cTwepkqUcw7igblbDPAasI3CEkfaJymhMLnk2iuowoEGvDuoAq)C8acoNOZP6xRCWv)REqO9LJcYHygE99LGlPaymhJhAFGYlI49VAbeeIB8gsTQJW6SpjK3)QheAFY(KEaHfEZ5jHeZWRVVeC5XzWQfnciRg8dHn2eZWRVVeC5BCRIijyJOq(9aLJn2eZWRVVeCrpah5dR6ijZWBx4)sycVYjSXMygE99LGla)vDDdlTpfByccSXMygE99LGl0)ftezozJGp74e2ytmdV((sWLLZ(KSxYQfHJWgBIz413xcUiYyGocbKluFWyJnXm867lbx0deippAeqcR41JKvY5WgBIz413xcUa2m4weblBuv2lz0OpDrkagXyoqoTOCC99KtLwnIYbx9V6bH2xoGT27GZjq6XafGCInlYjq6ZdHYXYbSzicohUf0tJWmhE3o4w0LtF50XgHYjq6XafGCUoYPs54bemZSPaymhJhAFGYlI49VAbeeIB8gsTQJW6SpjSpPhqsUp61cl8MZtcfdKHLUeI3qQvDuH3)QheAFY(KEaLcGXCmEO9bkViI3)QfqqiUXBi1QocRZ(KW(KEaj5(OxlSWBopjum7cw6siXm867lbx(g3Qisc2ikKFpq5PaymhJhAFGYlI49VAbeeIB8gsTQJW6SpjSpPhqsUp61cl8MZtcfdKbb8gsTQJk0)ftezozJGp74KeMCgMyPlHeZWRVVeCH(VyIiZjBe8zhNsbmEO9bkViI3)QfqqiUxocSXr2ksbmEO9bkViI3)QfqqiU9asQb9X6Spje0ENuFoniew6siZXBi1QoQW7F1dcTpzFspG2ZCIz413xcUaJidEPisINaaYTN5H5OlklfrGWqbHsbmEO9bkViI3)QfqqiU9asQb9X6SpjeSzWTicw2OQSxYOrF6IuaJhAFGYlI49VAbeeI7VIqnsQF7HsbmEO9bkViI3)QfqqiUFXe1vNbcS0LqM)Ii8LxmrD1zGififaJymhbdXjUpi4Ci8ecZCc9t5eBuogpAuokihdVPoR6OskGXdTpGqE7VGqGxY5WsxczoYF0QrpubwbC91PNHWuY7)3o4uamIXCycjA1(dohbhbAhEkhfKdO)uSP3toXMf5WTddrovkNFdtocUKcGrmMJXdTpaeeI7JeTA)blreOD4jS8askAtDKKBGqVhH7GLUecPQFTk8(x9Gq7R4FXg7QFTka)jzqVhGS6iaqVhjImymliY4be3x9Rv5irR2FWsebAhEQa3IUuamIXCy8gLdV)vpi0(KH(17jhJhAF54uqKdGVrWEhbYr0gD5GR(x9Gq7lhrQZLtLYXdi4CSdohq0icKtSr5GiG3f5Oxo4nKAvhvc9tYOL8(x9Gq7RKcGrmMJXdTpaeeIBU5CsJhAFsNccSo7tc59V6bH2Nm0VEpPaymhMjdPw1r5eBwKdbc9BbbYr0gfBekhOB6k07jNDTfrOCePoxovkhpGGZPsRgr5GR(x9Gq7lhfKdImymlPayeJ5y8q7dabH4gVHuR6iSo7tcbB6k07r(2IiKSsRgrsE)REqO9Hv)keqbw4nNNecjJhkEssh9vcWu8gsTQJk8(x9Gq7tc20vO3J8TfriSX24HINK0rFLamfVHuR6OcV)vpi0(KlN9jqGugiSXgVHuR6OsOFsgTK3)QheAFITXdTVcytxHEpY3weHklVZjreSNhAFmI3TdUfDfWMUc9EKVTicvG9il0(G4E8gsTQJkH(jz0sE)REqO9j28UDWTORa20vO3J8TfrOcI(MEagz8q7Ra20vO3J8TfrOYY7Cseb75H23EiX72b3IUcYFKSxY3weHki6B6beBE3o4w0vaB6k07r(2IiubrFtpaJ2fSXM5H5Olki)rYEjFBrecIPagp0(aqqiUbB6k07r(2Iiew6sy1VwfE)REqO9vGBr3EJhAFLLIiz1zGOW3m0dbyQWD2ZCiv9RvrVfHoZj5gGBWuX)UV6xRYwhsqGiJHcImEaX94nKAvhvaB6k07r(2IiKSsRgrsE)REqO9LcGXCGA4PCeCgSAxKd0xdXqoRgLdU6F1dcTpSYP6JC6yJqIuaLJhq5Oro9LdVBhCl6kPagp0(aqqiUrgSAxibVgIbS0LWQFTk8(x9Gq7Ra3IU9qcVHuR6OsOFsgTK3)QheAFmI3TdUfDI9UaXuamMJGISyR2OJYbS1EhCoMtKHjiNkLJhqW5isJTCWv)REqO9vYHzrJTCeuKfByaKdoBXw)XkhnYbS1EhCovkhpGGZHmKdZCaDoXMf5iOil2Qn6OCePoxoBgEkNFJOCaHXzaKdShP3to4Q)vpi0(kPagp0(aqqiUHjl2Qn6iS0LWQFTk8(x9Gq7Ra3IU9v)Avq(JK9s(2IiubUfD7XBi1QoQe6NKrl59V6bH2htXBi1QoQW7F1dcTp5lI4giKH(jiqItCFqYq)eeGu1VwfyYITAJoQa7rwO9j2v)Av49V6bH2xb2JSq7dIqEK)OvJEOcmzXgqUSyR)PaymNDhGYrWurOgbYPx5W4g9PlYrKgB5GR(x9Gq7RKcy8q7dabH4(RiuJaYEjJg9PlWsxcXBi1QoQe6NKrl59V6bH2htXBi1QoQW7F1dcTp5lI4giKH(jiqItCFqYq)0(QFTk8(x9Gq7Ra3IUuamMdZ2b6C8akhbtfHAeiNELdJB0NUih9YPsHiIUCWv)REqO9bYXa5467jhdKdU6F1dcTVCePoxoxh5Sz4PCIoNkLdm5mmj4C(E(woRgLJgLuaJhAFaiie3FfHAeq2lz0OpDbw6siEdPw1rLq)KmAjV)vpi0(yeVBhCl6eBCcKb5r(Jwn6Hka9wENeMC6ZwKcGXCW5gLdZeDXgMiSYXdOCSCWzfr5GdNbIC4Bg6HYb2J07jhbtfHAeiNELdJB0NUihUbICIohdFRW5WT3x9EYHVzOhcusbmEO9bGGqCVuejRodey5bKu0M6ij3aHEpc3blDj04H2x5RiuJaYEjJg9PlkK4e3h69SF5DojI4Bg6HKH(jX24H2x5RiuJaYEjJg9PlkK4e3hKerFtpatf07z(whsqGiJbj4LCoGup5YPpBXEMx9RvzRdjiqKXqX)Mcy8q7dabH42diPg0hlATiEip7tcFCgSArJaYQb)qyPlH4nKAvhvc9tYOL8(x9Gq7Jr8UDWTOtS3LuaJhAFaiie3Eaj1G(yD2Nes)xmrK5Knc(SJtyPlH4nKAvhvc9tYOL8(x9Gq7JPcXBi1QoQq)xmrK5Knc(SJtsyYzyUhVHuR6OsOFsgTK3)QheAFmcVHuR6Oc9FXerMt2i4ZoojHjNHPyVlPagp0(aqqiU9asQb9X6SpjeSzWTicw2OQSxYOrF6cS0LqiH3qQvDuj0pjJwY7F1dcTpMkeVHuR6OcV)vpi0(KViIBGqg6NGGyWg7L(Sfse9n9amfVHuR6OsOFsgTK3)QheAFqCF1VwfE)REqO9vGBrxkGXdTpaeeIBpGKAqFSo7tcFCy(Uj7L0aa9Rol0(WsxcHu1VwfE)REqO9vGBr3E8gsTQJkH(jz0sE)REqO9XiH4nKAvhv6t6bKK7JETWgB8gsTQJk9j9asY9rVwcHmiMcy8q7dabH42diPg0hRZ(KWVXTkIKGnIc53duow6siEdPw1rLq)KmAjV)vpi0(yQWDjfaJ5i4x54b69KJLdiiuRW50Ny7buoAqFSYXCImmb54buockezWlfr5Wmraa5YP9bqHPC6vo4Q)vpi0(k5GtfBesKciSY5fPnsdLzgkhpqVNCeuiYGxkIYHzIaaYLJin2Ybx9V6bH2xo95WmhDLJG)we6mxo4YaCdMYrb5qNvDeCo2bNJLJhypuoI6ddrovkhxdICA8ekNyJYb2JSq7lNELtSr5S0NTOKdJ3uqogmmihlhW3CUCWBopLt05eBuo8UDWTOlNELJGcrg8sruomteaqUCeTrxoWTEp5eBkihU54ENfAF5ujU5buoAKJcYXFiYCGq55eDoga4)uoXMf5OroIuNlNkLJhqW58sOfXdhM50xo8UDWTORKcy8q7dabH42diPg0hRZ(KqyezWlfrs8eaqoS0Lqiv9RvH3)QheAFf4w0ThVHuR6OsOFsgTK3)QheAFmsiEdPw1rL(KEaj5(OxlSXgVHuR6OsFspGKCF0RLqidI7Hu1Vwf9we6mNKBaUbtfqyCgew9RvrVfHoZj5gGBWu5BIlbHXzaBSzoVpyVgf9we6mNKBaUbtyJnEdPw1rfE)REqO9j7t6be2yJ3qQvDuj0pjJwY7F1dcTpgPxqO32zbblx6Zwir030diylydjE3o4w0bHDGmicXuamIXCycjkhOT3LJG)50Gq5qxGWeRCqKtjqo9LdyZqeCoAq)CWLGkh9wn6BH2xoXMf5OGCUoYbtkYb4FFBuqWLCYrWrVoJtGCInkNxeHxBpihNEuoI2OlNL)4H2N5kPagp0(aqqiU9asQb9X6Spje0ENuFoniew6siKWBi1QoQe6NKrl59V6bH2hJeItGmipKWBi1QoQ0N0dij3h9AXiidIyJnKyEG0Jbkk7uuqb0ENuFoni0(aPhduu2P4bw1r7dKEmqrzNcVBhCl6ki6B6bWgBMhi9yGIIykkOaAVtQpNgeAFG0JbkkIP4bw1r7dKEmqrrmfE3o4w0vq030dariUhsmNygE99LGlWiYGxkIK4jaGCyJnVBhCl6kWiYGxkIK4jaGCfe9n9amAxGykagZHXi95Hq5aT9UCe8pNgekhYqomZrKgB5i4VfHoZLdUma3GPCAuoI2OlhnYrKbY5frCdeLuaJhAFaiie3C74Ktw9RfwN9jHG27K6ZPH2hw6siZ59b71OO3IqN5KCdWnyAFOFIP7c2yx9RvrVfHoZj5gGBWubegNbHv)Av0BrOZCsUb4gmv(M4sqyCgsbWyoc(G(GCInlYbUZ56iNkD0sJCWv)REqO9LdyR9o4CyM7brovkhpGGZP9bqHPC6vo4Q)vpi0(YXICa9NY5T1lkPagp0(aqqiU9asQb9X6Spjupah5dR6ijZWBx4)sycVYjS0LqIz413xcU84my1IgbKvd(H2dPQFTk8(x9Gq7Ra3IU94nKAvhvc9tYOL8(x9Gq7JrcXBi1QoQ0N0dij3h9AHn24nKAvhv6t6bKK7JETeczqmfW4H2haccXThqsnOpwN9jHlN9jzVKvlchHLUesmdV((sWLhNbRw0iGSAWp0Eiv9RvH3)QheAFf4w0ThVHuR6OsOFsgTK3)QheAFmsiEdPw1rL(KEaj5(OxlSXgVHuR6OsFspGKCF0RLqidIPagp0(aqqiU9asQb9X6SpjuKXaDecixO(GXsxcjMHxFFj4YJZGvlAeqwn4hApKQ(1QW7F1dcTVcCl62J3qQvDuj0pjJwY7F1dcTpgjeVHuR6OsFspGKCF0Rf2yJ3qQvDuPpPhqsUp61siKbXuaJhAFaiie3Eaj1G(yD2NeQhiqEE0iGewXRhjRKZHLUesmdV((sWLhNbRw0iGSAWp0Eiv9RvH3)QheAFf4w0ThVHuR6OsOFsgTK3)QheAFmsiEdPw1rL(KEaj5(OxlSXgVHuR6OsFspGKCF0RLqidIPagp0(aqqiU9asQb9X6Spje4VQRByP9PydtqGLUesmdV((sWLhNbRw0iGSAWp0Eiv9RvH3)QheAFf4w0ThVHuR6OsOFsgTK3)QheAFmsiEdPw1rL(KEaj5(OxlSXgVHuR6OsFspGKCF0RLqidIPagp0(aqqiU9asQb9byPlHv)Av49V6bH2xbUfD7XBi1QoQe6NKrl59V6bH2hJeI3qQvDuPpPhqsUp61cBSXBi1QoQ0N0dij3h9AjeYsbWyo7oaLdoJAqKdtA8worNtG0NhcLZUhsbomZrWZvUJkPagp0(aqqiUxOgeYRXByPlHi)rRg9qLhKcCykvUYD0(QFTk8(x9Gq7Ra3IU9qcVHuR6OsOFsgTK3)QheAFmI3TdUfDyJnEdPw1rLq)KmAjV)vpi0(ykEdPw1rfE)REqO9jFre3aHm0pbbsCI7dsg6NGykagZz3JICInkhbLc46RtpdHzo4Q)F7GZP6xRC8VyLJ)CeaKdV)vpi0(Yrb5a6(kPagp0(aqqiU5T)ccbEjNdlDje5pA1OhQaRaU(60Zqyk59)Bh8EE3o4w0vQ(1scRaU(60Zqyk59)BhCbrgmM7R(1QaRaU(60Zqyk59)BhS0qC7OcCl62Z8QFTkWkGRVo9meMsE))2bx8V7HeEdPw1rLq)KmAjV)vpi0(GGXdTVYc1GO2UOWnqid9tmI3TdUfDLQFTKWkGRVo9meMsE))2bxG9il0(WgB8gsTQJkH(jz0sE)REqO9X0DbIPagp0(aqqiUne3ossI)6AG2hw6siYF0QrpubwbC91PNHWuY7)3o498UDWTORu9RLewbC91PNHWuY7)3o4cImym3x9RvbwbC91PNHWuY7)3oyPH42rf4w0TN5v)AvGvaxFD6zimL8()TdU4F3dj8gsTQJkH(jz0sE)REqO9bbsCI7dsg6NGGXdTVYc1GO2UOWnqid9tmI3TdUfDLQFTKWkGRVo9meMsE))2bxG9il0(WgB8gsTQJkH(jz0sE)REqO9X0DzpZdZrxuq(JK9s(2IieetbmEO9bGGqCVqniQTlWsxcr(Jwn6HkWkGRVo9meMsE))2bVN3TdUfDLQFTKWkGRVo9meMsE))2bxq030dWuUbczOFAF1VwfyfW1xNEgctjV)F7GLludIcCl62Z8QFTkWkGRVo9meMsE))2bx8V7HeEdPw1rLq)KmAjV)vpi0(Ga3aHm0pXiE3o4w0vQ(1scRaU(60Zqyk59)BhCb2JSq7dBSXBi1QoQe6NKrl59V6bH2ht3fiMcy8q7dabH4EHAqiVgVHLUeI8hTA0dvGvaxFD6zimL8()TdEpVBhCl6kv)AjHvaxFD6zimL8()TdUGidgZ9v)AvGvaxFD6zimL8()TdwUqnikWTOBpZR(1QaRaU(60Zqyk59)BhCX)Uhs4nKAvhvc9tYOL8(x9Gq7Jr8UDWTORu9RLewbC91PNHWuY7)3o4cShzH2h2yJ3qQvDuj0pjJwY7F1dcTpMUlqmfaJ5SRD7YXa58TdZCWzfr5GdNbcqogiN3ga0QJYz1OCWv)REqO9vYbQVgiJh50(iNELtSr5Sqgp0(mxo8()2hDro9kNyJY58)kHYPx5GZkIYbhodeGCInlYrK6C5Cw4rMZHzoiIVzOhkhypsVNCInkhC1)QheAF58UzakNkXnpGY5TBNEp5yhMXMEp58AGiNyZICePoxoxh58GSlYXUCiXdKLdoRikhC4mqKdShP3to4Q)vpi0(kPagp0(aqqiUXBi1QoclpGK9AjF4Wc3blpGKI2uhj5gi07r4oyD2NeUuejRodeY3UD69GfEZ5jH4nKAvhviXd6GjyjV)vpi0(Ki6B6bykEdPw1rLq)KmAjV)vpi0(2B8q7RSuejRodef(MHEiGCHmEO9zoiaj8gsTQJkH(jz0sE)REqO9bbJhAFfWMUc9EKVTicvwENtIiypp0(G84nKAvhvaB6k07r(2IiKSsRgrsE)REqO9bbibtv)Av(kc1iGSxYOrF6IY3exccJZGyVdeH84nKAvhv(DireFZqpK0(T)cipVXtNDrbpDXgMiipK4D7GBrx5RiuJaYEjJg9Plki6B6byQq8gsTQJkH(jz0sE)REqO9brikyZ72b3IUYsrKS6mquG9il0(e7DykVBhCl6klfrYQZar5BIl5Bg6HaqaVHuR6OsJNqVD7KlfrYQZabqWM3TdUfDLLIiz1zGOa7rwO9j2qQ6xRcV)vpi0(kWEKfAFc28UDWTORSuejRodefypYcTpikylyVZE8gsTQJkH(jz0sE)REqO9X0L(Sfse9n9aPagp0(aqqiU5MZjnEO9jDkiW6SpjK3)QheAFY3ndqyPlH4nKAvhvc9tYOL8(x9Gq7JPcHmSXU6xRcV)vpi0(k(xSXgVHuR6OsOFsgTK3)QheAFmfVHuR6OcV)vpi0(KViIBGqg6N2Z72b3IUcV)vpi0(ki6B6bykEdPw1rfE)REqO9jFre3aHm0pLcy8q7dabH4g5ps2l5BlIqyPlHv)Av49V6bH2xbUfD7R(1QG8hj7L8TfrOcCl62Z8QFTklfrGOr)cImEShs4nKAvhvc9tYOL8(x9Gq7JrcR(1QG8hj7L8TfrOcShzH23E8gsTQJkH(jz0sE)REqO9XiJhAFLLIiz1zGOS8oNer8nd9qYq)e2yJ3qQvDuj0pjJwY7F1dcTpgT0NTqIOVPhaI7HeZr(Jwn6Hka)jzqVhGS6iaqVhSX24HINK0rFLamsiEdPw1rLndbl5giKlN9jqGugiSXU6xRcWFsg07biRoca07rIidgZI)fBSR(1Qa8NKb9EaYQJaa9EkiY4bJew9Rvb4pjd69aKvhba69u(M4sqyCge7DWg7L(Sfse9n9amT6xRcYFKSxY3weHkWEKfAFqmfaJ5WSHzM7broXgLdEdPw1r5eBwKdVVa1oqo4SIOCWHZaroEG9q5eDoadpLdoRikhC4mqaYr0M6OCGsgsVNCyC75B5OGCmEO4PCePXwoq9xomR69Gbqo4WraGEpLuaJhAFaiie34nKAvhHLhqYETKpCyH7GLhqsrBQJKCde69iChSo7tcxkIKvNbc5B3o9EWcV58Kqazi9EKr75BfJhkEAVXdTVYsrKS6mquwENtIi(MHEizOFIr4ei)dhU8nXXsxczoEdPw1rLLIiz1zGq(2TtVN9i)rRg9qfG)KmO3dqwDeaO3tkagZHzYqQvDuoXMf5W7lqTdKZUU10PINdo7SpbYXdShkNOZHoGhr5Obih(MHEiqogIY5TBhbNZQr5GR(x9Gq7RKdo15WmhpGYzx3A6uXZbND2Na50(aOWuo9khC1)QheAF5iAJUCwENlh(MHEiqoC7YPs501W0JGZb2J07jNyJY5iXJCWv)REqO9vsbWigZX4H2haccXnEdPw1ryD2Ne(U10PIlF72P3dw6sOXdfpjPJ(kbykEdPw1rfE)REqO9jxo7tGaPmqyH3CEsiEdPw1rLq)KmAjV)vpi0(Gq1VwfE)REqO9vG9il0(e7DHPgp0(kVBnDQ4YLZ(eOS8oNer8nd9qYq)ee4D7GBrx5DRPtfxUC2NafypYcTpX24H2xbSPRqVh5BlIqLL35Kic2ZdTpipEdPw1rfWMUc9EKVTicjR0QrKK3)QheAF7XBi1QoQe6NKrl59V6bH2htx6Zwir030dGn2i)rRg9qfG)KmO3dqwDeaO3d2yh6Ny6UKcGXCyw2OlhpqVNCWzN9jqGugOC0lhC1)QheAFyLdWWt5yGC(2Hzo8nd9qGCmqoVnaOvhLZQr5GR(x9Gq7lhrAS1(ihU9(Q3tjfaJymhJhAFaiie34nKAvhH1zFs47wtNkU8TBNEpyPlHgpu8KKo6ReGrcXBi1QoQW7F1dcTp5YzFceiLbcl8MZtcXBi1QoQe6NKrl59V6bH2htnEO9vE3A6uXLlN9jqz5DojI4Bg6HKH(jX24H2xbSPRqVh5BlIqLL35Kic2ZdTpipEdPw1rfWMUc9EKVTicjR0QrKK3)QheAF7XBi1QoQe6NKrl59V6bH2htx6Zwir030dGn2i)rRg9qfG)KmO3dqwDeaO3d2yh6Ny6UKcy8q7dabH4MBoN04H2N0PGaRZ(Kqu)kF3maHfiqkpeUdw6sy1VwfK)izVKVTicv8V7R(1QW7F1dcTVcCl62J3qQvDuj0pjJwY7F1dcTpgbzPaymhMnmZCpiYj2OCWBi1QokNyZIC49fO2bYbNveLdoCgiYXdShkNOZHoGhr5Obih(MHEiqogIYXCGoN3UDeCoRgLJGZFuo9kNDTfrOskGXdTpaeeIB8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jHlfrYQZaH8TBNEpyH3CEsiKyoYF0Qrpub4pjd69aKvhba69Gn2v)Ava(tYGEpaz1raGEpfqyCgyu1VwfG)KmO3dqwDeaO3t5BIlbHXzqS3bI75D7GBrxb5ps2l5BlIqfe9n9am14H2xzPiswDgiklVZjreFZqpKm0pj2gp0(kGnDf69iFBreQS8oNerWEEO9b5HeEdPw1rfWMUc9EKVTicjR0QrKK3)QheAF75D7GBrxbSPRqVh5BlIqfe9n9amL3TdUfDfK)izVKVTicvq030daX98UDWTORG8hj7L8TfrOcI(MEaMU0NTqIOVPhalDjK54nKAvhvwkIKvNbc5B3o9E2hMJUOG8hj7L8TfrO9v)Avq(JK9s(2IiubUfDPaymhMLn6YbYXqWCde69Kdo7SpbcKYaHvo4SIOCWHZabihWw7DW5uPC8acoNOZ5HoczbLdKth5anqKXaih7GZj6CiXd6GZbhodeekhbtdeeQKcy8q7dabH4EPiswDgiWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdw6siZXBi1QoQSuejRodeY3UD69ShVHuR6OsOFsgTK3)QheAFmcY2B8qXts6OVsagjeVHuR6OYMHGLCdeYLZ(eiqkd0EMVuebcdfeQy8qXt7zE1VwLToKGargdf)7Eiv9RvzJSqVhP)T4F3B8q7RSC2NabszGkK4e3hKerFtpatHSYUGn28nd9qa5cz8q7ZCmsOyGykagZrq5r69KdoRicegkiew5GZkIYbhodeGCmeLJhqW5a0V6mKdZCIohypsVNCWv)REqO9vYz3JoczohMyLtSryMJHOC8acoNOZ5HoczbLdKth5anqKXaihrB0LdhPbihrQZLZ1rovkhrgii4CSdohrASLdoCgiiuocMgiiew5eBeM5a2AVdoNkLd4frgCoTpYj6C(MEHPxoXgLdoCgiiuocMgiiuov)AvsbmEO9bGGqCVuejRodey5bKSxl5dhw4oy5bKu0M6ij3aHEpc3blDjCPicegkiuX4HIN2J3qQvDuj0pjJwY7F1dcTpgbz7zoEdPw1rLLIiz1zGq(2TtVN9qI5gp0(klfrvZ5kK4e3h69SN5gp0(kVyI6QZarrp5YPpBX(QFTkBKf69i9Vfez8aBSnEO9vwkIQMZviXjUp07zpZR(1QS1HeeiYyOGiJhyJTXdTVYlMOU6mqu0tUC6ZwSV6xRYgzHEps)Bbrgp2Z8QFTkBDibbImgkiY4betbWyomB8TcNd3EF17jhCwruo4WzGih(MHEiqoI2uhLdFZUJC69Kd0nDf69KZU2IiukGXdTpaeeI7LIiz1zGalpGKI2uhj5gi07r4oyPlHgp0(kGnDf69iFBreQqItCFO3Z(L35KiIVzOhsg6NyQXdTVcytxHEpY3weHkHYzqIiypp0(sbmEO9bGGqCZnNtA8q7t6uqG1zFsiiSd2qWsuhwO9HLUeI3qQvDuj0pjJwY7F1dcTpgbz7R(1QG8hj7L8TfrOcCl62x9RvH3)QheAFf4w0Lcy8q7dabH4gWBeFlfifW4H2hOy8qXtYWC0faHofVEpYA)RyPlHgpu8KKo6ReGr7SV6xRcV)vpi0(kWTOBpKWBi1QoQe6NKrl59V6bH2hJ4D7GBrxXP417rw7FTa7rwO9Hn24nKAvhvc9tYOL8(x9Gq7JPcHmiMcy8q7dumEO4jzyo6caeeI7pfuJWsxcXBi1QoQe6NKrl59V6bH2htfczyJD1VwfE)REqO9vq030dWOaz4jNm0pHn2qI3TdUfDLpfuJkWEKfAFmfVHuR6OsOFsgTK3)QheAF7zEyo6IcYFKSxY3weHGi2yhMJUOG8hj7L8TfrO9v)Avq(JK9s(2IiuX)UhVHuR6OsOFsgTK3)QheAFmY4H2x5tb1OcVBhCl6Wg7L(Sfse9n9amfVHuR6OsOFsgTK3)QheAFPagp0(afJhkEsgMJUaabH4ggzp9bKvezXgw6syyo6II5iXbbYamZya5YJWCpKQ(1QW7F1dcTVcCl62Z8QFTkBDibbImgk(xiMcKcy8q7du49V6bH2NK3TdUfDaHVDO9Lcy8q7du49V6bH2NK3TdUfDaiie3vx3WYLhHzkGXdTpqH3)QheAFsE3o4w0bGGqCxjeGqmO3dw6sy1VwfE)REqO9v8VPagp0(afE)REqO9j5D7GBrhaccX9sru11nCkGXdTpqH3)QheAFsE3o4w0bGGqCBhNabYCsU5CPagp0(afE)REqO9j5D7GBrhaccXDOFskYqVyPlHi)rRg9qLG(VnYCsrg6DF1Vwfs8nZdcTVI)nfW4H2hOW7F1dcTpjVBhCl6aqqiU9asQb9XIwlIhYZ(KWhNbRw0iGSAWpukGXdTpqH3)QheAFsE3o4w0bGGqC7bKud6J1zFsOEaoYhw1rsMH3UW)LWeELtPagp0(afE)REqO9j5D7GBrhaccXThqsnOpwN9jHlN9jzVKvlchLcy8q7du49V6bH2NK3TdUfDaiie3Eaj1G(yD2NekYyGocbKluFWPagp0(afE)REqO9j5D7GBrhaccXThqsnOpwN9jH6bcKNhnciHv86rYk5CPagp0(afE)REqO9j5D7GBrhaccXThqsnOpwN9jHa)vDDdlTpfBycIuaJhAFGcV)vpi0(K8UDWTOdabH42diPg0hKcKcGXCemaH(TGYzRfLJRVNCWv)REqO9LJi15YXzGiNyZoga5eDoq9xomR69Gbqo4WraGEp5eDoWuqOVEuoBTOCWzfr5GdNbcqoGT27GZPs54beCjfW4H2hOW7F1dcTp57Mbiiie34nKAvhHLhqYETKpCyH7GLhqsrBQJKCde69iChSo7tcjXd6GjyjV)vpi0(Ki6B6bWcV58KWQFTk8(x9Gq7RGOVPhacv)Av49V6bH2xb2JSq7dYdjE3o4w0v49V6bH2xbrFtpatR(1QW7F1dcTVcI(MEaiMcGXCy2WWGCInkhypYcTVC6voXgLdu)LdZQEpyaKdoCeaO3to4Q)vpi0(Yj6CInkh6GZPx5eBuoCpcrxKdU6F1dcTVC0voXgLd3aroIAVdohqyOihypsVNCInfKdU6F1dcTVskGXdTpqH3)QheAFY3ndqqqiUXBi1QoclpGK9AjF4Wc3blpGKI2uhj5gi07r4oyD2NesIh0btWsE)REqO9jr030dGv)k0GHXcV58Kq8gsTQJkagQsypYcTpS0LqK)OvJEOcWFsg07biRoca07zpKQ(1Qa8NKb9EaYQJaa9EKiYGXS4FXgB8gsTQJkK4bDWeSK3)QheAFse9n9am6Hdxq030daHDk7cK)Hdx(M4qEiv9Rvb4pjd69aKvhba69u(M4sqyCge7QFTka)jzqVhGS6iaqVNcimodqeIPaymhCQyJq5W72b3IoqoXMf5a2AVdoNkLJhqW5isJTCWv)REqO9LdyR9o4C6ZHzovkhpGGZrKgB5yxogp8MlhC1)QheAF5WnqKJDW5CDKJin2YXYbQ)YHzvVhmaYbhoca07jNxuZlPagp0(afE)REqO9jF3mabbH4MBoN04H2N0PGaRZ(KqE)REqO9j5D7GBrhalqGuEiChS0Lq8gsTQJkK4bDWeSK3)QheAFse9n9amcVHuR6OcGHQe2JSq7lfW4H2hOW7F1dcTp57Mbiiie3CZ5Kgp0(KofeyD2NeA8qXtYWC0fGuamMJGFLdu)LdZQEpyaKdoCeaO3toGW4maYXquoB6Zgw5WTJtUCIn6NtLwnIYbx9V6bH2xoGoNyZICInkhO(lhMv9EWaihC4iaqVNCErnphUD5uPCa2ICyMdm5mmj4C8xOUCSvqOCWv)REqO9LJin2AFKdsbmKtVYHe)vrwO9vsbmEO9bk8(x9Gq7t(UzacccXn3oo5Kv)AH1zFsiWFsg07biRoca07blDjK5akK1(8GsOesmqUsb9lFF1VwfE)REqO9vGBr3(QFTka)jzqVhGS6iaqVNcimodmsm7dZrxuq(JK9s(2Ii0EE3o4w0vq(JK9s(2IiubrFtpatfdKLcGXCe8RCWv)REqO9LJcYbUfDyLZlI4giYb0Fk207jNkTAeLJXdfVf69KJgLuaJhAFGcV)vpi0(KVBgGGGqCVC2NabszGWsxcR(1QW7F1dcTVcCl62Z72b3IUcV)vpi0(ki6B6byk3aHm0pT34HINK0rFLamsiEdPw1rfE)REqO9jxo7tGaPmqPagp0(afE)REqO9jF3mabbH4(ftuxDgiWsxcR(1QW7F1dcTVcCl62x9Rvb4pjd69aKvhba69irKbJzX)UV6xRcWFsg07biRoca07rIidgZcI(MEagXnqid9tPagp0(afE)REqO9jF3mabbH4(ftuxDgiWsxcR(1QW7F1dcTVcCl62x9Rv5ftuZDg4xqKXJ9v)AvEXe1CNb(fe9n9amIBGqg6NsbmEO9bk8(x9Gq7t(UzacccX9sru1CoS0LWQFTk8(x9Gq7Ra3IU98UDWTORW7F1dcTVcI(MEaMYnqid9t7zoVpyVgLLZ(K04CefAFPagp0(afE)REqO9jF3mabbH4gWBeFdlDjS6xRcV)vpi0(kWTOBpVBhCl6k8(x9Gq7RGOVPhGPCdeYq)ukagZbx9V6bH2xoGT27GZPs54beCoI2OlNyJY5frCde5OGCm3Vbrol9uWgbxsbmEO9bk8(x9Gq7t(UzacccXnV)vpi0(WYdizVwYhoSWDWYdiPOn1rsUbc9EeUdw6s4whsqGiJbj4LCoGup5YPpBHqiBF1VwfE)REqO9vGBr3E8gsTQJkH(jz0sE)REqO9XuHq2EiXCK)OvJEOcSc46RtpdHPK3)VDWyJD1VwfyfW1xNEgctjV)F7Gl(xSXU6xRcSc46RtpdHPK3)VDWYfQbrX)UpmhDrb5ps2l5BlIq75D7GBrxP6xljSc46RtpdHPK3)VDWfezWycX9qI5i)rRg9qLhKcCykvUYDe2ydtv)AvEqkWHPu5k3rf)le3djMZB80zxuoIJAxJGXgBE3o4w0vGjl2Qn6OcI(MEaSXU6xRcmzXwTrhv8VqCpKyoVXtNDrbpDXgMiSXM3TdUfDLVIqnci7LmA0NUOGOVPhaI7HKXdTVYNcQrf9KlN(Sf7nEO9v(uqnQONC50NTqIOVPhGPcXBi1QoQW7F1dcTpj3aHerFtpa2yB8q7Ra4nIVviXjUp07zVXdTVcG3i(wHeN4(GKi6B6bykEdPw1rfE)REqO9j5giKi6B6bWgBJhAFLLIOQ5CfsCI7d9E2B8q7RSuevnNRqItCFqse9n9amfVHuR6OcV)vpi0(KCdese9n9ayJTXdTVYlMOU6mquiXjUp07zVXdTVYlMOU6mquiXjUpijI(MEaMI3qQvDuH3)QheAFsUbcjI(MEaSX24H2xz5SpbcKYaviXjUp07zVXdTVYYzFceiLbQqItCFqse9n9amfVHuR6OcV)vpi0(KCdese9n9aqmfaJ5i48hLtVYzxBrekhUD5uPC8acoh9Ybx9V6bH2xo6khnYrb5a3IoSYP6JCInfKdyR9o4C6ZHzovkh4(OC0voXgHOCuqo)gr5GR(x9Gq7lNq)uorNtLoAProlu)Zj2SlNyJquoIAVdoNkLZc1)CSlhOmR4ihC1)QheAF54SGqLuaJhAFGcV)vpi0(KVBgGGGqCJ8hj7L8TfriS0LWQFTki)rYEjFBreQa3IU94nKAvhviXd6GjyjV)vpi0(Ki6B6byeEdPw1rfadvjShzH2xkagZHzrJT2h5i4VfHoZLdUma3GjSYHzUhe54buo4SIOCWHZabihrB0LtSryMJO(WqKZ3F8TC4ina5yhCoI2OlhCwreiA0phfKdCl6kPagp0(afE)REqO9jF3mabbH4EPiswDgiWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdw6siZ59b71OO3IqN5KCdWnyApZXBi1QoQSuejRodeY3UD69ShsmhqHS2NhucLqIbYvkOF5yJnmv9Rv5RiuJaYEjJg9PlkWTOdBSR(1Qa8NKb9EaYQJaa9EKiYGXSa3IoSX24H2x5ftuxDgikK4e3h69aX9v)Av49V6bH2xX)UN5v)AvwkIarJ(fez8ypZR(1QS1HeeiYyOGiJh736qccezmibVKZbK6jxo9zlGq1VwLnYc9EK(3cImEa5H0dhUGOVPhGrqgezQysbWyomlASLJG)we6mxo4YaCdMWkhCwruo4WzGihpGYbS1EhCovkhdgwdTpZ5WmhEFGaz6rW5a6CInlYrJCuqoxh5uPC8acoh)5iaihb)Ti0zUCWLb4gmLJcYXQTpYj6CiXFveLtJYj2ieLJHOC(nIYj2Slh6A)Zwo4SIOCWHZabiNOZHepOdohb)Ti0zUCWLb4gmLt05eBuo0bNtVYbx9V6bH2xjfaJymhJhAFGcV)vpi0(KVBgGGGqCJ3qQvDewEaj71s(WHfUdwEajfTPosYnqO3JWDW6SpjKe)L4bblxkIKvNbcaw9RqafyH3CEsOXdTVYsrKS6mqu4Bg6HaYfY4H2N5GaKWBi1QoQqIh0btWsE)REqO9jr030di2v)Av0BrOZCsUb4gmvG9il0(GOGnVBhCl6klfrYQZarb2JSq7dlDjK3hSxJIElcDMtYna3GPuamIXCmEO9bk8(x9Gq7t(UzacccXnEdPw1ry5bKSxl5dhw4oy5bKu0M6ij3aHEpc3bRZ(KWJiycwUuejRodeaS6xHakWcV58KqoPoiH3qQvDuHepOdMGL8(x9Gq7tIOVPhqWgsv)Av0BrOZCsUb4gmvG9il0(e7hoC5BIdriILUeY7d2RrrVfHoZj5gGBWukagZz3bOCGUPRqVNC21weHYb2J07jhC1)QheAF5iAJUCIncr5yikNRJCOR9pB5GZkIYbhodeGCm8M6SQJYj6CwENdZCiXd6GZrVfHoZLd3aCdMYXo4C6ZHzoI2OlhbN)OC6vo7AlIq5OGC6lhE3o4w0vsbmEO9bk8(x9Gq7t(UzacccXnEdPw1ry5bKSxl5dhw4oy5bKu0M6ij3aHEpc3bRZ(KqpGKGnDf69iFBrecl8MZtcxkIaHHccvq030dWu8gsTQJkK4bDWeSK3)QheAFse9n9a7HeVpyVgf9we6mNKBaUbt7XBi1QoQqI)s8GGLlfrYQZabGP4nKAvhvoIGjy5srKS6mqaG4EiX8WC0ffK)izVKVTicHn28UDWTORG8hj7L8TfrOcI(MEagH3qQvDuHepOdMGL8(x9Gq7tIOVPhaIyJTXdfpjPJ(kbyKq8gsTQJk8(x9Gq7tc20vO3J8TfriS0LqEJNo7IYPpBHCzukGXdTpqH3)QheAFY3ndqqqiUxkIKvNbcS8as2RL8HdlChS8askAtDKKBGqVhH7GLUeY7d2RrrVfHoZj5gGBW0EMJ3qQvDuzPiswDgiKVD707zpKyoGczTppOekHedKRuq)YXgByQ6xRYxrOgbK9sgn6txuGBrh2yx9Rvb4pjd69aKvhba69irKbJzbUfDyJTXdTVYlMOU6mquiXjUp07bI7HeEdPw1rfs8xIheSCPiswDgiamsiEdPw1rLJiycwUuejRodeaSXU6xRcV)vpi0(ki6B6by6dhU8nXXgB8gsTQJkK4bDWeSK3)QheAFse9n9amvy1Vwf9we6mNKBaUbtfypYcTpSXU6xRIElcDMtYna3GPcimodmvmyJD1Vwf9we6mNKBaUbtfe9n9am9Hdx(M4yJnVBhCl6kGnDf69iFBreQGidgZ94nKAvhv8asc20vO3J8TfriiUV6xRcV)vpi0(k(39qI5v)AvwkIarJ(fez8aBSR(1QO3IqN5KCdWnyQGOVPhGPqwzxG4EMx9RvzRdjiqKXqbrgp2V1HeeiYyqcEjNdi1tUC6ZwaHQFTkBKf69i9Vfez8aYdPhoCbrFtpaJGmiYuXKcGXCG(shCoqoDKd0argdGCG9i9EYbx9V6bH2xowKZM(SLZlsBKgywsbmEO9bk8(x9Gq7t(UzacccX9YzFceiLbclDjesv)Av26qccezmu8V7nEO4jjD0xjaJeI3qQvDuH3)QheAFYLZ(eiqkdeeXgBiv9RvzPicen6x8V7nEO4jjD0xjaJeI3qQvDuH3)QheAFYLZ(eiqkdKyJ8hTA0dvwkIarJ(qmfaJ5i4my1UihOVgIHCaBT3bNtLYXdi4CePXwowoqoDKd0argd5GidgZCIohpGYr)FcwTGCyMJTccLtSr5WnqKZspfSrGsomEtb5isDUCol8iZ5Wmhaf54FZXYbYPJCGgiYyihWlDroRgLtSr5S0ZC5acJZqo9khbNbR2f5a91qmusbmEO9bk8(x9Gq7t(UzacccXnYGv7cj41qmGLUew9RvH3)QheAFf)7EXa5R(1QS1HeeiYyOGiJhqO6xRYgzHEps)BbrgpGWwhsqGiJbj4LCoGup5YPpBHqXKcy8q7du49V6bH2N8DZaeeeI7xmrD1zGalDjS6xRYsreiA0V4FtbmEO9bk8(x9Gq7t(UzacccX9lMOU6mqGLUew9RvzRdjiqKXqX)UV6xRcV)vpi0(k(3uaJhAFGcV)vpi0(KVBgGGGqC)IjQRodeyPlHVicV8Hdx2Pa4nIVTV6xRYgzHEps)BX)U34HINK0rFLamfVHuR6OcV)vpi0(KlN9jqGugO9v)Av49V6bH2xX)McGXC2Da9EYb6MUc9EYzxBrekhypsVNCWv)REqO9Lt05Giq0ikhCwruo4WzGih7GZzx3A6uXZbND2NYHVzOhcKd3UCQuov6OLYvZHvovFKJh4nNdZC6ZHzo9LdZUfmkPagp0(afE)REqO9jF3mabbH4gSPRqVh5BlIqyPlH4nKAvhv8asc20vO3J8TfrO9v)Av49V6bH2xX)UN5gp0(klfrYQZarHVzOhcS34H2x5DRPtfxUC2Naf(MHEiatnEO9vE3A6uXLlN9jq5BIl5Bg6HaPaymhb)khlhO(lhMv9EWaihC4iaqVNCErnphrT3bNtLYXdiySYrW5pkNELZU2IiuoGT27GZPs54beColfbIC0voXgLdjUcc9EYrW5pkNELZU2IiuoIuNlhs8xfr5a7r69KtSr5WnqusbmEO9bk8(x9Gq7t(UzacccXnYFKSxY3weHWsxcR(1Qa8NKb9EaYQJaa9EKiYGXS4F3x9Rvb4pjd69aKvhba69irKbJzbrFtpaJiXjUpizOFccgp0(klN9jqGugOc3aHm0pTV6xRcYFKSxY3weHki6B6byQXdTVYYzFceiLbQWnqid9t7nEO4jjD0xjaJeI3qQvDuH3)QheAFYLZ(eiqkdukGXdTpqH3)QheAFY3ndqqqiUxo7tGaPmqyPlHv)Ava(tYGEpaz1raGEpsezWyw8V7R(1Qa8NKb9EaYQJaa9EKiYGXSGOVPhGrCdeYq)0EJhkEssh9vcWiH4nKAvhv49V6bH2NC5SpbcKYaLcy8q7du49V6bH2N8DZaeeeIBK)izVKVTicHLUew9Rvb4pjd69aKvhba69irKbJzX)UV6xRcWFsg07biRoca07rIidgZcI(MEagrItCFqYq)eemEO9vEXe1vNbIc3aHm0pTV6xRcYFKSxY3weHki6B6byQXdTVYlMOU6mqu4giKH(PuaJhAFGcV)vpi0(KVBgGGGqC)IjQRodeyPlHv)Ava(tYGEpaz1raGEpsezWyw8V7R(1Qa8NKb9EaYQJaa9EKiYGXSGOVPhGrCdeYq)ukagZzxXe1CNb(58IAoihWw7DW5uPC8acoh9Ybx9V6bH2xowKZM(SrOCErAJ0aZCIn7Yzx3A6uXZbND2Na5yhCoq5nIVvsbmEO9bk8(x9Gq7t(UzacccX9lMOU6mqGLUew9Rv5ftuZDg4xqKXJ9v)AvEXe1CNb(fe9n9amIBGqg6N2x9RvH3)QheAFfe9n9amIBGqg6N2B8qXts6OVsaMI3qQvDuH3)QheAFYLZ(eiqkd0EiXCEFWEnk6Ti0zoj3aCdMWg7QFTk6Ti0zoj3aCdMki6B6byejoX9bjd9tyJD1VwLnYc9EK(3cImEaHToKGargdsWl5CaPEYLtF2cMkgiMcGXC2DakNDDRPtfphC2zFcKJDW5aL3i(wo6LdU6F1dcTVCIoNnY9MZdDeYckhiNoYbAGiJbqoI2OlhCwruo4WzGaKJHOCUoYXWBQZQokNgLZreCorNtLYH3hGq4j4skGXdTpqH3)QheAFY3ndqqqiUF3A6uXLlN9jaw6sy1VwfE)REqO9v8V7dKHNCYq)etR(1QW7F1dcTVcI(MEG9v)Av2il07r6FliY4be26qccezmibVKZbK6jxo9zlyQysbmEO9bk8(x9Gq7t(UzacccXnG3i(gw6sy1VwfE)REqO9vq030dWiUbczOFkfaJ5i4x5eBeIYrbhgICOR9pB5e6NYXrRih9Ybx9V6bH2xoRgLJLZUU10PINdo7SpbYPr5aL3i(worNZMg5OhqHPC6vo4Q)vpi0(WkhpGYb0Fk207jhYbOskGXdTpqH3)QheAFY3ndqqqiUDkE9EK1(xXsxcR(1QW7F1dcTVcI(MEaM(WHlFt89gpu8KKo6ReGr7Kcy8q7du49V6bH2N8DZaeeeIByK90hqwrKfByPlHv)Av49V6bH2xbrFtpatF4WLVj((QFTk8(x9Gq7R4FtbsbWigZbYHCVekh8gsTQJYj2SihEFHPhiNyJYX4H3C5qGq)wqW5e6NYj2SiNyJY5iXJCWv)REqO9LJi15YPs5GidgZskagXyogp0(afE)REqO9jd9R3Jq8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jH8(x9Gq7tIidgtzOFcl8MZtc5D7GBrxH3)QheAFfe9n9aqEs8xIheSKb9GD69ireSNhAFPayeJ5W4nkhUbICc9t50RCInkhWl5C5eBwKJi15YPs58IiUbIC0l6CWv)REqO9vsbWigZX4H2hOW7F1dcTpzOF9EGGqCJ3qQvDewEaj71s(WHfUdwEajfTPosYnqO3JWDW6SpjK3)QheAFYxeXnqid9tyH3CEsiKmEO9vwkIQMZv4giKH(jipZ59b71OSC2NKgNJOq7dcgp0(kaEJ4BfUbczOFcc8(G9Auwo7tsJZruO9bripKmEO4jjD0xjatXBi1QoQW7F1dcTp5YzFceiLbcIqW4H2xz5SpbcKYav4giKH(jipKmEO4jjD0xjaJeI3qQvDuH3)QheAFYLZ(eiqkdeefB8gsTQJk8(x9Gq7tYnqir030dKcGrmMJXdTpqH3)QheAFYq)69abH4gVHuR6iS8as2RL8HdlChS8askAtDKKBGqVhH7G1zFsyOFsgTK3)QheAFyH3CEsiEdPw1rfE)REqO9jrKbJPm0pLcGrmMJGICgM5GR(x9Gq7lNvJYXwbHYbNvebcdfekh)5iaih8gsTQJklfrGWqbHK8(x9Gq7lhfKdGIskagXyogp0(afE)REqO9jd9R3deeIB8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jHH(jz0sE)REqO9Hv)k8BIJfEZ5jHlfrGWqbHki6B6bWsxcdZrxuwkIaHHccTN54nKAvhvwkIaHHccj59V6bH2xkagXyockYzyMdU6F1dcTVCwnkhbNbR2f5a91qmKJUYrJCePoxo8(t50Rvo8UDWTOlhq3xjfaJymhJhAFGcV)vpi0(KH(17bccXnEdPw1ry5bKSxl5dhw4oy5bKu0M6ij3aHEpc3bRZ(KWq)KmAjV)vpi0(WQFf(nXXcV58KqE3o4w0vqgSAxibVgIHcI(MEaS0LqEJNo7IcdyIu72Z72b3IUcYGv7cj41qmuq030di27azmfVHuR6OsOFsgTK3)QheAFPaymhbf5mmZbx9V6bH2xoRgLJGPIqncKtVYHXn6txusbWigZX4H2hOW7F1dcTpzOF9EGGqCJ3qQvDewEaj71s(WHfUdwEajfTPosYnqO3JWDW6Spjm0pjJwY7F1dcTpS6xHFtCSWBopjK3TdUfDLVIqnci7LmA0NUOGOVPhalDjK34PZUOGNUydt0EE3o4w0v(kc1iGSxYOrF6IcI(MEaXwm7ctXBi1QoQe6NKrl59V6bH2xkagXyockYzyMdU6F1dcTVCwnkhbfzXwTrhvsbWigZX4H2hOW7F1dcTpzOF9EGGqCJ3qQvDewEaj71s(WHfUdwEajfTPosYnqO3JWDW6Spjm0pjJwY7F1dcTpS6xHFtCSWBopjK3TdUfDfyYITAJoQGOVPhacqQ6xRcmzXwTrhvG9il0(e7QFTk8(x9Gq7Ra7rwO9bripYF0QrpubMSydixwS1FS0LqEJNo7IYrCu7Ae8EE3o4w0vGjl2Qn6OcI(MEaXEhiJP4nKAvhvc9tYOL8(x9Gq7lfaJymhbf5mmZbx9V6bH2xoRgLJGISyddGCWzl26FoGW4maYrx5eBeIYXquowKJJmqKtiQZjm0dfGskagXyogp0(afE)REqO9jd9R3deeIB8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jHH(jz0sE)REqO9Hv)k8BIJfEZ5jHv)AvGjl2Qn6OcI(MEaXU6xRcV)vpi0(kWEKfAFyPlHi)rRg9qfyYInGCzXw)3x9RvbMSyR2OJk(39gpu8KKo6ReGrcftkagXyockYzyMdU6F1dcTVCwnkNyJYrW4)IjImxo4ui4ZooLt1Vw5ORCInkNxNHjHYrb54b69KtSzrobspgOOKcGrmMJXdTpqH3)QheAFYq)69abH4gVHuR6iS8as2RL8HdlChS8askAtDKKBGqVhH7G1zFsyOFsgTK3)QheAFy1Vc)M4yH3CEsiEdPw1rf6)IjImNSrWNDCsctodtXgs8UDWTORq)xmrK5Knc(SJtfypYcTpXM3TdUfDf6)IjImNSrWNDCQGOVPhaIqEMZ72b3IUc9FXerMt2i4ZoovqKbJjw6siXm867lbxO)lMiYCYgbF2XPuamIXCeuKZWmhC1)QheAF5SAuo7EodwTOrGCWHb)qyLJ)CeaKJg5iQ9o4CQuoWKZWKGZX13dHYj2SlhXaz5aiEFWGskagXyogp0(afE)REqO9jd9R3deeIB8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jHH(jz0sE)REqO9Hv)k8BIJfEZ5jH8UDWTOR84my1IgbKvd(HK4eb9UigXa5wq030dGLUesmdV((sWLhNbRw0iGSAWp0EE3o4w0vECgSArJaYQb)qsCIGExeJyGCli6B6beBXazmfVHuR6OsOFsgTK3)QheAFPayeJ5iOiNHzo4Q)vpi0(YXFH6Ybx9V6bH2xoK4VkIa5ORC0adGC8VLuamIXCmEO9bk8(x9Gq7tg6xVhiie34nKAvhHLhqYETKpCyH7GLhqsrBQJKCde69iChSo7tcd9tYOL8(x9Gq7dR(v43ehl8MZtcR(1QW7F1dcTVcI(MEGuamIXCeuKZWmhC1)QheAF54VqD5i46Dnhs8xfrGC0voAGbqo(3skagXyogp0(afE)REqO9jd9R3deeIB8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jHH(jz0sE)REqO9Hv)k8BIJfEZ5jHv)Avq(JK9s(2IiubrFtpaw6syyo6IcYFKSxY3weH2x9RvH3)QheAFf4w0LcGrmMJGICgM5GR(x9Gq7lNvJYXUCiXdKLJGZFuo9kNDTfrOC0voXgLJGZFuo9kNDTfrOCe1EhCo8(t50Rvo8UDWTOlhlYXrgiYzxYbq8(Gb5uPvJOCWv)REqO9LJO27GlPayeJ5y8q7du49V6bH2Nm0VEpqqiUXBi1QoclpGK9AjF4Wc3blpGKI2uhj5gi07r4oyD2Neg6NKrl59V6bH2hw9RWVjow4nNNeY72b3IUcYFKSxY3weHki6B6bGq1VwfK)izVKVTicvG9il0(WsxcdZrxuq(JK9s(2Ii0(QFTk8(x9Gq7Ra3IU98UDWTORG8hj7L8TfrOcI(MEaiSlmfVHuR6OsOFsgTK3)QheAFPayeJ5iOiNHzo4Q)vpi0(Yrx5iOuaxFD6zimZbx9)BhCoIAVdoNRJCQuoiYGXmNvJYrJCWKIskagXyogp0(afE)REqO9jd9R3deeIB8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jHH(jz0sE)REqO9Hv)k8BIJfEZ5jH8UDWTORu9RLewbC91PNHWuY7)3o4cI(MEaS0LqK)OvJEOcSc46RtpdHPK3)VDW7R(1QaRaU(60Zqyk59)BhCbUfDPayeJ5i4mfohbd80faXkhbf5mmZbx9V6bH2xoRgLJbdNd41eDGC6vo4KCAuo)gr5yWWGCInlYrK6C54mqKJRVhcLtSzxo7Sl5aiEFWGsomEJauo4nNNa5yi6WqKZrCcamK6WmN(n0V5YrVCmNlhUbiqjfaJymhJhAFGcV)vpi0(KH(17bccXnEdPw1ry5bKSxl5dhw4oy5bKu0M6ij3aHEpc3bRZ(KWq)KmAjV)vpi0(WQFf(nXXcV58KqKPWscpDrXGHbf9WsxcrMclj80ffdgguiXvqa2Jmfws4PlkgmmOWB)fmsiozpYuyjHNUOyWWGcShzH2hJ2zxsbWigZrWzkCocg4PlaIvomBNidtqoEaLdU6F1dcTVCePXwo49UJqwvDAGzoitHZHWtxaWkNgpHqkmLJDyMdm5mmb54uqqW5y1gpLt058ngOCaEeLJg58qbihpGGZzJqujfaJymhJhAFGcV)vpi0(KH(17bccXnEdPw1ry5bKSxl5dhw4oy5bKu0M6ij3aHEpc3bRZ(KWq)KmAjV)vpi0(WcV58KqKPWscpDrbV3DeYQoQOhKN5itHLeE6IcEV7iKvDuX)ILUeImfws4Plk49UJqw1rfsCfeG94nKAvhv49V6bH2NergmMYq)etrMclj80ff8E3riR6OIEPayeJ5S7auoXgLZrIh5GR(x9Gq7lN(YH3TdUfD5ORC0ihrT3bNZ1rovkhs8xIheCorNdm5mmZj2OCa8nc27i4C6JYPr5eBuoa(gb7DeCo9r5iQ9o4C2S3x6YXraqoXMD5igilhaX7dgKtLwnIYj2OCw6ZwKdDWGskagXyogp0(afE)REqO9jd9R3deeIB8gsTQJWYdizVwYhoSWDWYdiPOn1rsUbc9EeUdwN9jHH(jz0sE)REqO9HfEZ5jH4nKAvhv49V6bH2NergmMYq)ew6siEdPw1rfE)REqO9jrKbJPm0pbbE3o4w0v49V6bH2xb2JSq7dYdPDeBibzfCAiazfXa5dZrxuwkIaHHccbriFyo6Icd6b707bImviEdPw1rLq)KmAjV)vpi0(WgB8gsTQJkH(jz0sE)REqO9XOL(Sfse9n9aITyGSuGuaJhAFGcQFLVBgGeUC2NabszGWsxcnEO4jjD0xjaJeI3qQvDuzRdjiqKXGC5SpbcKYaThsv)Av26qccezmu8VyJD1VwLLIiq0OFX)cXuaJhAFGcQFLVBgGGGqCVuevnNdlDjS6xRcmzXwTrhv8V7r(Jwn6HkWKfBa5YIT(VhVHuR6OsOFsgTK3)QheAFmT6xRcmzXwTrhvq030dS34HINK0rFLamsOysbmEO9bkO(v(UzacccX9YzFceiLbclDj04HINK0rFLamsiEdPw1rLndbl5giKlN9jqGugO9v)Ava(tYGEpaz1raGEpsezWyw8V7R(1Qa8NKb9EaYQJaa9EKiYGXSGOVPhGrCdeYq)ukGXdTpqb1VY3ndqqqiUFXe1vNbcS0LWQFTka)jzqVhGS6iaqVhjImyml(39v)Ava(tYGEpaz1raGEpsezWywq030dWiUbczOFkfW4H2hOG6x57Mbiiie3VyI6QZabw6sy1VwLLIiq0OFX)Mcy8q7duq9R8DZaeeeI7xmrD1zGalDjS6xRYwhsqGiJHI)nfaJ5S7auo9r5GZkIYbhode5qgYHzo6LJGR31C0voy2(CG7ddroBgEkhsJncLdKdzHEp5S7EZPr5a50roqdezmKdMuKJDW5qASriXkhizqmNndpLZVruoXMD5eI6CmhImymXkhivHyoBgEkhMTJeheidWmJHbqo4ShHzoiYGXmNOZXdiSYPr5ajoeZbkzi9EYHXTNVLJcYX4HINk5iO6ddroWDoXMcYr0M6OC2meCoCde69Kdo7SpbcKYabYPr5iAJUCG6VCyw17bdGCWHJaa9EYrb5GidgZskGXdTpqb1VY3ndqqqiUxkIKvNbcS8as2RL8HdlChS8askAtDKKBGqVhH7GLUeYC8gsTQJklfrYQZaH8TBNEp7R(1Qa8NKb9EaYQJaa9EKiYGXSa3IU9gpu8KKo6ReGP4nKAvhv2meSKBGqUC2NabszG2Z8LIiqyOGqfJhkEApKyE1VwLnYc9EK(3I)DpZR(1QS1HeeiYyO4F3Z8xeHx2RL8HdxwkIKvNbI9qY4H2xzPiswDgik8nd9qagjumyJnKcZrxumhjoiqgGzgdixEeM75D7GBrxbgzp9bKvezXwbrgmMqeBSbKH07rgTNVvmEO4jicXuamMZUdq5GZkIYbhode5qASrOCG9i9EYXYbNvevnNd37kMOU6mqKd3aroI2OlhihYc9EYz39MJcYX4HINYPr5a7r69KdjoX9bLJin2Ybkzi9EYHXTNVvsbmEO9bkO(v(UzacccX9srKS6mqGLhqYETKpCyH7GLhqsrBQJKCde69iChS0LqMJ3qQvDuzPiswDgiKVD707zpZxkIaHHccvmEO4P9v)Ava(tYGEpaz1raGEpsezWywGBr3Eibjiz8q7RSuevnNRqItCFO3ZEiz8q7RSuevnNRqItCFqse9n9amfYk7c2yZCK)OvJEOYsreiA0hIyJTXdTVYlMOU6mquiXjUp07zpKmEO9vEXe1vNbIcjoX9bjr030dWuiRSlyJnZr(Jwn6HklfrGOrFicX9v)Av2il07r6FliY4beXgBibidP3JmApFRy8qXt7Hu1VwLnYc9EK(3cImESN5gp0(kaEJ4BfsCI7d9EWgBMx9RvzRdjiqKXqbrgp2Z8QFTkBKf69i9Vfez8yVXdTVcG3i(wHeN4(qVN9mFRdjiqKXGe8sohqQNC50NTaIqeIPagp0(afu)kF3mabbH4MBoN04H2N0PGaRZ(KqJhkEsgMJUaKcy8q7duq9R8DZaeeeI7xmrD1zGalDjS6xRYlMOM7mWVGiJh75giKH(jMw9Rv5ftuZDg4xq030dSNBGqg6NyA1VwfK)izVKVTicvq030dShsmh5pA1OhQa8NKb9EaYQJaa9EWg7QFTkVyIAUZa)cI(MEaMA8q7RSuevnNRWnqid9tqGBGqg6NG8v)AvEXe1CNb(fez8aIPagp0(afu)kF3mabbH4(ftuxDgiWsxcR(1QS1HeeiYyO4F3didP3JmApFRy8qXt7nEO4jjD0xjatXBi1QoQS1HeeiYyqUC2NabszGsbmEO9bkO(v(UzacccX97wtNkUC5SpbWsxczoEdPw1rL3TMovC5B3o9E2djJhkEsc3rrFoniMkgSX24HINK0rFLamsiEdPw1rLndbl5giKlN9jqGugiSX24HINK0rFLamsiEdPw1rLToKGargdYLZ(eiqkdeetbmEO9bkO(v(UzacccXnG3i(gw6siGmKEpYO98TIXdfpLcy8q7duq9R8DZaeeeIByK90hqwrKfByPlHgpu8KKo6ReGrIjfW4H2hOG6x57Mbiiie3gIBhjjXFDnq7dlDj04HINK0rFLamsiEdPw1rfdXTJKK4VUgO9T)BNvE5bJeI3qQvDuXqC7ijj(RRbAFYVD2(WqpuuePXME7azPaymhMfn2YHU2)SLtyOhkayLJg5OGCSCEm9Yj6C4giYbND2NabszGYXa5SuNJq5OhiidoNELdoRiQAoxjfW4H2hOG6x57Mbiiie3lN9jqGugiS0LqJhkEssh9vcWiH4nKAvhv2meSKBGqUC2NabszGsbmEO9bkO(v(UzacccX9sru1CUuGuaJhAFGciSd2qWsuhwO9jC5SpbcKYaHLUeA8qXts6OVsagjeVHuR6OYwhsqGiJb5YzFceiLbApKQ(1QS1HeeiYyO4FXg7QFTklfrGOr)I)fIPagp0(afqyhSHGLOoSq7dccX9sru1CoS0LWQFTkWKfB1gDuX)Uh5pA1OhQatwSbKll26)E8gsTQJkH(jz0sE)REqO9X0QFTkWKfB1gDubrFtpWEJhkEssh9vcWiHIjfW4H2hOac7GneSe1HfAFqqiUFXe1vNbcS0LWQFTklfrGOr)I)nfW4H2hOac7GneSe1HfAFqqiUFXe1vNbcS0LWQFTkBDibbImgk(39v)Av26qccezmuq030dWuJhAFLLIOQ5CfsCI7dsg6NsbmEO9bkGWoydblrDyH2heeI7xmrD1zGalDjS6xRYwhsqGiJHI)DpKEreE5dhUStzPiQAoh2yVuebcdfeQy8qXtyJTXdTVYlMOU6mqu0tUC6ZwaXuamMdJryMt058qroqzwXroVOMdYrpGct5i46DnN3ndqGCAuo4Q)vpi0(Y5DZaeihrB0LZBdaA1rLuaJhAFGciSd2qWsuhwO9bbH4E5SpbcKYaHLUeA8qXts6OVsagjeVHuR6OYMHGLCdeYLZ(eiqkd0(QFTka)jzqVhGS6iaqVhjImyml(39qI3TdUfDfK)izVKVTicvq030dabJhAFfK)izVKVTicviXjUpizOFccCdeYq)eJQ(1Qa8NKb9EaYQJaa9EKiYGXSGOVPhaBSzEyo6IcYFKSxY3weHG4E8gsTQJkH(jz0sE)REqO9bbUbczOFIrv)Ava(tYGEpaz1raGEpsezWywq030dKcy8q7duaHDWgcwI6WcTpiie3VyI6QZabw6sy1VwLToKGargdf)7Eazi9EKr75BfJhkEkfW4H2hOac7GneSe1HfAFqqiUFXe1vNbcS0LWQFTkVyIAUZa)cImESNBGqg6NyA1VwLxmrn3zGFbrFtpWEiXCK)OvJEOcWFsg07biRoca07bBSR(1Q8IjQ5od8li6B6byQXdTVYsru1CUc3aHm0pbbUbczOFcYx9Rv5ftuZDg4xqKXdiMcGXCeuEKEp5eBuoGWoydbNdQdl0(WkN(CyMJhq5GZkIYbhodeGCeTrxoXgHzogIY56iNkP3toVD7i4CwnkhbxVR50OCWv)REqO9vYz3bOCWzfr5GdNbICin2iuoWEKEp5y5GZkIQMZH7DftuxDgiYHBGihrB0LdKdzHEp5S7EZrb5y8qXt50OCG9i9EYHeN4(GYrKgB5aLmKEp5W42Z3kPagp0(afqyhSHGLOoSq7dccX9srKS6mqGLhqYETKpCyH7GLhqsrBQJKCde69iChS0LqMVuebcdfeQy8qXt7zoEdPw1rLLIiz1zGq(2TtVN9v)Ava(tYGEpaz1raGEpsezWywGBr3Eibjiz8q7RSuevnNRqItCFO3ZEiz8q7RSuevnNRqItCFqse9n9amfYk7c2yZCK)OvJEOYsreiA0hIyJTXdTVYlMOU6mquiXjUp07zpKmEO9vEXe1vNbIcjoX9bjr030dWuiRSlyJnZr(Jwn6HklfrGOrFicX9v)Av2il07r6FliY4beXgBibidP3JmApFRy8qXt7Hu1VwLnYc9EK(3cImESN5gp0(kaEJ4BfsCI7d9EWgBMx9RvzRdjiqKXqbrgp2Z8QFTkBKf69i9Vfez8yVXdTVcG3i(wHeN4(qVN9mFRdjiqKXGe8sohqQNC50NTaIqeIPagp0(afqyhSHGLOoSq7dccX9lMOU6mqGLUew9RvzRdjiqKXqX)U34HINK0rFLamfVHuR6OYwhsqGiJb5YzFceiLbkfW4H2hOac7GneSe1HfAFqqiUF3A6uXLlN9jaw6siZXBi1QoQ8U10PIlF72P3ZEiX8WC0fLfQ)YyJKgyJayJTXdfpjPJ(kby0oqCpKmEO4jjChf950GyQyWgBJhkEssh9vcWiH4nKAvhv2meSKBGqUC2NabszGWgBJhkEssh9vcWiH4nKAvhv26qccezmixo7tGaPmqqmfW4H2hOac7GneSe1HfAFqqiU5MZjnEO9jDkiW6Spj04HINKH5OlaPagp0(afqyhSHGLOoSq7dccXnmYE6diRiYInS0LqJhkEssh9vcWODsbmEO9bkGWoydblrDyH2heeIBaVr8nS0Lqazi9EKr75BfJhkEkfW4H2hOac7GneSe1HfAFqqiUne3ossI)6AG2hw6sOXdfpjPJ(kbyKq8gsTQJkgIBhjjXFDnq7B)3oR8YdgjeVHuR6OIH42rss8xxd0(KF7S9HHEOOisJn92bYsbWyomlASLdDT)zlNWqpuaWkhnYrb5y58y6Lt05WnqKdo7SpbcKYaLJbYzPohHYrpqqgCo9khCwru1CUskGXdTpqbe2bBiyjQdl0(GGqCVC2NabszGWsxcnEO4jjD0xjaJeI3qQvDuzZqWsUbc5YzFceiLbkfW4H2hOac7GneSe1HfAFqqiUxkIQMZXcf8sCwMGtJtyd2GLfa]] )
end
