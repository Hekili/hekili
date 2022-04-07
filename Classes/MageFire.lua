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


    spec:RegisterPack( "Fire", 20220407, [[deLL2eqiIuEeuOlrKk1MuQ6tqbJcIYPGiTkiQQxbrmlOOBPuj2Le)cQKHbrLJPuXYiQ0ZGkIPrKkUgrf2gurY3GkkghevX5uQuX6iQO5Hc5EeX(qH6FOOe6GOOuleQWdHk1errvDruuL2ikk(OsLknsiQsNKivzLejVefL0mvQuUjrQKDII0pHksnuLkPLsKQ6PqyQOiUQsLQ2kurPVIIQySOOYErP)syWkomLflPhJQjdPlJSzL8zvXOvkNM0Qrrj61OGztLBRQ2Tk)wQHRkDCOIQLd65atx46u12HQ(orz8evDEOK1JIsW8HsTFrZUdltyrGAbXYu5ICYvUiN0b5Wzk7S7ix5qoyrey9sSiEnod2dXI4SpXIGzuiXI41WY1gkltyraApKtSi2I4fiN4cxpAS5RfE)Xfq)ENfAFCOTcCb0phxSiQE1fsVJTYIa1cILPYf5KRCroPdYHZu2z3rUYH0b5HfH5JTgYIaH(XnlInffLo2klcucWzrWmkKYr6YEOuQTiEbYjUW1JgB(AH3FCb0V3zH2hhARaxa9ZXvkfZ(fQUCWzWmh5ICYvUPuPu4EZUhciNPu7so7EaLZsF2cbK(MEGCGwSrWCIn7Yjm4dfLq)KiAbQs5SAyoode7cG49HMJvvNgyLJhypeOKsTl5SBDdOlhUbICGeo3Rq6txaYz1WCWD)REqO9LdY0cvWmh0(WqKZw7qZrJCwnmhlNfKaB5iDrb1WC4giqAjLAxYH59SQJYbeqLh5W3iod69KtF5y5Siz5SAidGC0lNyJYHzVR7worNdKq9CkhznKbxBOLuQDjhMnkZspiYXYzxXc2vNbICOlGyLtSzroOnbY56iNFJsUCKroxo6Tlp2NYbza9NtqGGqZXICUohG(C6s52f5W83ve5O)xJhiTKsTl5G7(WtWihZ5YP6xRcZvGKXJCOlGkbYj6CQ(1QWCf)lM5yxoM73Gih9a6ZPlLBxKdZFxrKZJPxo6Ldq)Gsk1UKZUhq5SzquEJsO5G3GQvDeiNOZbsOEoLdU31DFoYAidU2qlSiCkiaSmHfbV)vpi0(e8UDOTSdWYewMUdltyry8q7JfXBhAFSiOZQocLfhSbltLlltyry8q7Jfr11nQy5HyXIGoR6iuwCWgSmfNWYewe0zvhHYIdweCOgeunwev)Av49V6bH2xX)YIW4H2hlIkbbeKb9EydwMkDyzclcJhAFSiwkKQUUrzrqNvDekloydwMkhSmHfHXdTpwe2XjqanNGBohlc6SQJqzXbBWYuCkwMWIGoR6iuwCWIGd1GGQXIa6pA1WhQe0)THMtiZGVf6SQJqZzFov)Avi53mpi0(k(xwegp0(yre6NeYm4lBWYuCgwMWIGoR6iuwCWIW4H2hlca3GarVelOfe8mNaeqDrSi4qniOASiQ(1Qa4gei6LybTGGN5eGaQlsiDk(xweN9jweaUbbIEjwqli4zobiG6IydwMI8WYewe0zvhHYIdwegp0(yr84mu1Igcevd9HyrqRfXdXzFIfXJZqvlAiqun0hInyz6UdltyrqNvDekloyrC2NyrOhGd9HvDKaN7Tl8FbkHx5elcJhAFSi0dWH(WQosGZ92f(VaLWRCInyz6oihltyrqNvDekloyrC2NyrSC2Ne9suTiCelcJhAFSiwo7tIEjQweoInyz6o7WYewe0zvhHYIdweN9jweYmgOJGaXc2hklcJhAFSiKzmqhbbIfSpu2GLP7ixwMWIGoR6iuwCWI4SpXIqpqa98OHabQIxpsujNJfHXdTpwe6bcONhneiqv86rIk5CSblt3bNWYewe0zvhHYIdweN9jwea)vDDJkSpfBybcwegp0(yra8x11nQW(uSHfiydwMUJ0HLjSimEO9XIWdiHg0hWIGoR6iuwCWgSblcuAzExWYewMUdltyrqNvDekloyrWHAqq1yriTCG(Jwn8HkOkGRVo9miwcE))2HwOZQocLfHXdTpwe82FbbbVKZXgSmvUSmHfbDw1rOS4GfHXdTpweGnDf69iEBzeKfbkb4q9n0(yrGZAq1QokNyZICiqOFliqoY2OyJG5GytxHEp5SRTmcMJm15YPs54beAovA1qkhC3)QheAF5OGCGKHIvHfbhQbbvJfr1VwfE)REqO9vqBzxo7ZX4H2xzPqsuDgik8nd(qGCyKKC2jN95iTCqwov)Av0BrWZCcUb4gkv8V5SpNQFTkBDiabKmgkqY4roinN95G3GQvDubSPRqVhXBlJGIkTAij49V6bH2hBWYuCcltyrqNvDekloyry8q7Jfb0qv7cb41GmWIaLaCO(gAFSiqy4PCK(gQAxKdIxdYqoRgMdU7F1dcTpmZP6JC6yJGYuaLJhq5Oro9LdVBhAl7kSi4qniOASiQ(1QW7F1dcTVcAl7YzFoilh8guTQJkH(jr0cE)REqO9LdJZX4H2NG3TdTLD5Sl5ih5Gu2GLPshwMWIGoR6iuwCWIW4H2hlcuYITAdpIfbkb4q9n0(yrW8jl2Qn8OCaBT3HMJ5KzybYPs54beAoY0ylhC3)QheAFLCyE0ylhMpzXgga5WmwS1FmZrJCaBT3HMtLYXdi0Cid6WkhqNtSzromFYITAdpkhzQZLZMHNY53qkhqyCga5G6H69KdU7F1dcTVclcoudcQglIQFTk8(x9Gq7RG2YUC2Nt1VwfO)irVeVTmcwqBzxo7ZbVbvR6OsOFseTG3)QheAF5WOCWBq1QoQW7F1dcTpXlK4gieH(PCqsoK8e3hKi0pLdsYbz5u9RvbLSyR2WJkOEOfAF5Sl5u9RvH3)QheAFfup0cTVCqAoi)CG(Jwn8HkOKfBaXYIT(xOZQocLnyzQCWYewe0zvhHYIdwegp0(yr8viSHarVerd)0fSiqjahQVH2hlIDpGYr6sHWgcYPx5WKg(PlYrMgB5G7(x9Gq7RWIGd1GGQXIaVbvR6OsOFseTG3)QheAF5WOCWBq1QoQW7F1dcTpXlK4gieH(PCqsoK8e3hKi0pLZ(CQ(1QW7F1dcTVcAl7ydwMItXYewe0zvhHYIdwegp0(yr8viSHarVerd)0fSiqjahQVH2hlcMTd054buosxke2qqo9khM0WpDro6LtLczeD5G7(x9Gq7dKJbYX13togihC3)QheAF5itDUCUoYzZWt5eDovkhuYzyrO5898TCwnmhnkSi4qniOASiWBq1QoQe6Nerl49V6bH2xomohJhAFcE3o0w2LZUKdob5Yb5Nd0F0QHpubO3Y7eOKtF2IcDw1rOSbltXzyzclc6SQJqzXblcpGeY2uhj4gi07HLP7WIaLaCO(gAFSiyMgMdolDXgwqmZXdOCSCygfs5GdNbIC4Bg8HYb1d17jhPlfcBiiNELdtA4NUihUbICIohdFRO5WT3x9EYHVzWhcuyry8q7JfXsHKO6mqWIGd1GGQXIW4H2x5RqydbIEjIg(PlkK8e3h69KZ(CwENtaj(MbFirOFkNDjhJhAFLVcHnei6LiA4NUOqYtCFqci9n9a5WOCKo5SphPLZwhcqajJbb4LCoGqpXYPpBro7ZrA5u9RvzRdbiGKXqX)YgSmf5HLjSiOZQocLfhSimEO9XI4XzOQfneiQg6dXIGd1GGQXIaVbvR6OsOFseTG3)QheAF5W4CmEO9j4D7qBzxo7soYblcATiEio7tSiECgQArdbIQH(qSblt3Dyzclc6SQJqzXblcJhAFSiO)lwqYCIgIE2XjweCOgeunwe4nOAvhvc9tIOf8(x9Gq7lhgjjh8guTQJk0)flizordrp74KaLCgw5Sph8guTQJkH(jr0cE)REqO9LdJZbVbvR6Oc9FXcsMt0q0ZoojqjNHvo7soYblIZ(elc6)IfKmNOHONDCInyz6oihltyrqNvDekloyry8q7JfbyZqBzeQOHvrVerd)0fSi4qniOASiqwo4nOAvhvc9tIOf8(x9Gq7lhgjjh8guTQJk8(x9Gq7t8cjUbcrOFkhKKJCZbBSZzPpBHasFtpqomkh8guTQJkH(jr0cE)REqO9LdsZzFov)Av49V6bH2xbTLDSio7tSiaBgAlJqfnSk6LiA4NUGnyz6o7WYewe0zvhHYIdwegp0(yr8a1VG4o9fqSi4qniOASiWBq1QoQe6Nerl49V6bH2xomssoip5Gn25S0NTqaPVPhihgLdEdQw1rLq)KiAbV)vpi0(yrC2Nyr8a1VG4o9fqSblt3rUSmHfbDw1rOS4GfHXdTpwe)UpNgIxOc(Si4qniOASiWBq1QoQe6Nerl49V6bH2xomssoYroyJDol9zleq6B6bYHr5G3GQvDuj0pjIwW7F1dcTpweN9jwe)UpNgIxOc(Sblt3bNWYewe0zvhHYIdwegp0(yr84W6Dt0lHba6xDwO9XIGd1GGQXIaz5u9RvH3)QheAFf0w2LZ(CWBq1QoQe6Nerl49V6bH2xomwso4nOAvhv6t4bKG7JETYbBSZbVbvR6OsFcpGeCF0RvosYb5YbPSio7tSiECy9Uj6LWaa9Rol0(ydwMUJ0HLjSiOZQocLfhSimEO9XI4BCRcjbyJOq89aLZIGd1GGQXIaVbvR6OsOFseTG3)QheAF5Wij5ihSio7tSi(g3Qqsa2ikeFpq5Sblt3royzclc6SQJqzXblcucWH6BO9XIq6TYXd07jhlhqqWwrZPVDXdOC0G(yMJ5KzybYXdOCy(qYqxkKYbNLaaYLt7dGIs50RCWD)REqO9vYbNo2iOmfqyMZluBOgkZcuoEGEp5W8HKHUuiLdolbaKlhzASLdU7F1dcTVC6ZHvo6khP3Ti4zUCWTb4gkLJcYHoR6i0CSdnhlhpWEOCK1hgICQuoUge504jyoXgLdQhAH2xo9kNyJYzPpBrjhMSPGCmuuqowoGV5C5G3CEkNOZj2OC4D7qBzxo9khMpKm0LcPCWzjaGC5iBJUCqB9EYj2uqoCZX9ol0(YPsCZdOC0ihfKJ)GK5aHYZj6CmaW)PCInlYrJCKPoxovkhpGqZ5LGlIhoSYPVC4D7qBzxHfXzFIfbkKm0LcjbEcaihlcoudcQglcKLt1VwfE)REqO9vqBzxo7ZbVbvR6OsOFseTG3)QheAF5Wyj5G3GQvDuPpHhqcUp61khSXoh8guTQJk9j8asW9rVw5ijhKlhKMZ(Cqwov)Av0BrWZCcUb4gkvaHXzihj5u9RvrVfbpZj4gGBOu5BYlaHXzihSXohPLdVpuVgf9we8mNGBaUHsf6SQJqZbBSZbVbvR6OcV)vpi0(e9j8akhSXoh8guTQJkH(jr0cE)REqO9LdJZrVGGVTZccvS0NTqaPVPhihP7CYbz5y8q7tW72H2YUCqso7GC5G0CqklcJhAFSiqHKHUuijWtaa5ydwMUdofltyrqNvDekloyry8q7JfbO9oH(CAqqweCOgeunweilh8guTQJkH(jr0cE)REqO9LdJLKdob5Yb5NdYYbVbvR6OsFcpGeCF0RvomohKlhKMd2yNdYYrA5eq9yGIsStrbfq7Dc950GG5SpNaQhduuIDkEGvDuo7ZjG6XafLyNcVBhAl7kq6B6bYbBSZrA5eq9yGIsi3IckG27e6ZPbbZzFobupgOOeYT4bw1r5SpNaQhduuc5w4D7qBzxbsFtpqoinhKMZ(CqwoslhcN713xcTGcjdDPqsGNaaYLd2yNdVBhAl7kOqYqxkKe4jaGCfi9n9a5W4CKJCqklIZ(elcq7Dc950GGSblt3bNHLjSiOZQocLfhSimEO9XIGBhNCIQFTyrWHAqq1yriTC49H61OO3IGN5eCdWnuQqNvDeAo7Zj0pLdJYroYbBSZP6xRIElcEMtWna3qPcimod5ijNQFTk6Ti4zob3aCdLkFtEbimodSiQ(1sC2NyraAVtOpNgAFSiqjahQVH2hlcMa1NhcMdI27Yr69CAqWCid6WkhzASLJ07we8mxo42aCdLYPH5iBJUC0ihzgiNxiXnquydwMUdYdltyrqNvDekloyrGsaouFdTpwesVG(GCInlYbTZ56iNkD0sJCWD)REqO9LdyR9o0Cyw6brovkhpGqZP9bqrPC6vo4U)vpi0(YXICa9NY5T1lkSio7tSi0dWH(WQosGZ92f(VaLWRCIfbhQbbvJfbHZ967lHwECgQArdbIQH(q5SphKLt1VwfE)REqO9vqBzxo7ZbVbvR6OsOFseTG3)QheAF5Wyj5G3GQvDuPpHhqcUp61khSXoh8guTQJk9j8asW9rVw5ijhKlhKYIW4H2hlc9aCOpSQJe4CVDH)lqj8kNydwMUZUdltyrqNvDekloyry8q7JfXYzFs0lr1IWrSi4qniOASiiCUxFFj0YJZqvlAiqun0hkN95GSCQ(1QW7F1dcTVcAl7YzFo4nOAvhvc9tIOf8(x9Gq7lhgljh8guTQJk9j8asW9rVw5Gn25G3GQvDuPpHhqcUp61khj5GC5GuweN9jwelN9jrVevlchXgSmvUihltyrqNvDekloyry8q7JfHmJb6iiqSG9HYIGd1GGQXIGW5E99LqlpodvTOHar1qFOC2NdYYP6xRcV)vpi0(kOTSlN95G3GQvDuj0pjIwW7F1dcTVCySKCWBq1QoQ0NWdib3h9ALd2yNdEdQw1rL(eEaj4(OxRCKKdYLdszrC2NyriZyGoccelyFOSbltL7oSmHfbDw1rOS4GfHXdTpwe6bcONhneiqv86rIk5CSi4qniOASiiCUxFFj0YJZqvlAiqun0hkN95GSCQ(1QW7F1dcTVcAl7YzFo4nOAvhvc9tIOf8(x9Gq7lhgljh8guTQJk9j8asW9rVw5Gn25G3GQvDuPpHhqcUp61khj5GC5GuweN9jwe6bcONhneiqv86rIk5CSbltLRCzzclc6SQJqzXblcJhAFSia(R66gvyFk2WceSi4qniOASiiCUxFFj0YJZqvlAiqun0hkN95GSCQ(1QW7F1dcTVcAl7YzFo4nOAvhvc9tIOf8(x9Gq7lhgljh8guTQJk9j8asW9rVw5Gn25G3GQvDuPpHhqcUp61khj5GC5GuweN9jwea)vDDJkSpfBybc2GLPYfNWYewe0zvhHYIdwegp0(yra4gei6LybTGGN5eGaQlIfbhQbbvJfr1Vwfa3GarVelOfe8mNaeqDrcPtbTLDSio7tSiaCdce9sSGwqWZCcqa1fXgSmvUshwMWIGoR6iuwCWIGd1GGQXIO6xRcV)vpi0(kOTSlN95G3GQvDuj0pjIwW7F1dcTVCySKCWBq1QoQ0NWdib3h9ALd2yNdEdQw1rL(eEaj4(OxRCKKdYXIW4H2hlcpGeAqFaBWYu5khSmHfbDw1rOS4GfHXdTpwelydcX14nweOeGd13q7JfXUhq5WmWge5W0gVLt05eq95HG5S7cvGdRCKECL7OclcoudcQglcO)OvdFOYduboSekx5oQqNvDeAo7ZP6xRcV)vpi0(kOTSlN95GSCWBq1QoQe6Nerl49V6bH2xomohJhAFcE3o0w2Ld2yNdEdQw1rLq)KiAbV)vpi0(YHr5G3GQvDuH3)QheAFIxiXnqic9t5GKCi5jUpirOFkhKYgSmvU4uSmHfbDw1rOS4GfHXdTpwe82FbbbVKZXIaLaCO(gAFSi2DPiNyJYH5RaU(60ZGyLdU7)3o0CQ(1kh)lM54phba5W7F1dcTVCuqoGUVclcoudcQglcO)OvdFOcQc46RtpdILG3)VDOf6SQJqZzFo8UDOTSRu9RLavbC91PNbXsW7)3o0cKmuSYzFov)AvqvaxFD6zqSe8()TdvyqUDubTLD5SphPLt1VwfufW1xNEgelbV)F7ql(3C2NdYYbVbvR6OsOFseTG3)QheAF5GKCmEO9vwWge12ffUbcrOFkhgNdVBhAl7kv)AjqvaxFD6zqSe8()TdTG6HwO9Ld2yNdEdQw1rLq)KiAbV)vpi0(YHr5ih5Gu2GLPYfNHLjSiOZQocLfhSi4qniOASiG(Jwn8HkOkGRVo9miwcE))2HwOZQocnN95W72H2YUs1VwcufW1xNEgelbV)F7qlqYqXkN95u9RvbvbC91PNbXsW7)3ouHb52rf0w2LZ(CKwov)AvqvaxFD6zqSe8()TdT4FZzFoilh8guTQJkH(jr0cE)REqO9LdsYHKN4(GeH(PCqsogp0(klydIA7Ic3aHi0pLdJZH3TdTLDLQFTeOkGRVo9miwcE))2Hwq9ql0(YbBSZbVbvR6OsOFseTG3)QheAF5WOCKJC2NJ0YjmhDrb6ps0lXBlJGf6SQJqZbPSimEO9XIWGC7ibj)RRbAFSbltLlYdltyrqNvDekloyrWHAqq1yra9hTA4dvqvaxFD6zqSe8()TdTqNvDeAo7ZH3TdTLDLQFTeOkGRVo9miwcE))2HwG030dKdJYHBGqe6NYzFov)AvqvaxFD6zqSe8()TdvSGnikOTSlN95iTCQ(1QGQaU(60ZGyj49)BhAX)MZ(Cqwo4nOAvhvc9tIOf8(x9Gq7lhKKd3aHi0pLdJZH3TdTLDLQFTeOkGRVo9miwcE))2Hwq9ql0(YbBSZbVbvR6OsOFseTG3)QheAF5WOCKJCqklcJhAFSiwWge12fSbltL7UdltyrqNvDekloyrWHAqq1yra9hTA4dvqvaxFD6zqSe8()TdTqNvDeAo7ZH3TdTLDLQFTeOkGRVo9miwcE))2HwGKHIvo7ZP6xRcQc46RtpdILG3)VDOIfSbrbTLD5SphPLt1VwfufW1xNEgelbV)F7ql(3C2NdYYbVbvR6OsOFseTG3)QheAF5W4C4D7qBzxP6xlbQc46RtpdILG3)VDOfup0cTVCWg7CWBq1QoQe6Nerl49V6bH2xomkh5ihKYIW4H2hlIfSbH4A8gBWYuCcYXYewe0zvhHYIdwe9llcafSimEO9XIaVbvR6iweOeGd13q7JfXU2TlhdKZ3oSYHzuiLdoCgia5yGCEBaqRokNvdZb39V6bH2xjhe(AanEKt7JC6voXgLZcA8q7ZC5W7)BF0f50RCInkNZ)RemNELdZOqkhC4mqaYj2SihzQZLZzHhAohw5aj(MbFOCq9q9EYj2OCWD)REqO9LZ7MbOCQe38akN3UD69KJDyfB69KZRbICInlYrM6C5CDKZd0Uih7YHKpGwomJcPCWHZaroOEOEp5G7(x9Gq7RWIaV58elc8guTQJkK8bDOeQG3)QheAFci9n9a5WOCWBq1QoQe6Nerl49V6bH2xo7ZX4H2xzPqsuDgik8nd(qaXcA8q7ZC5GKCqwo4nOAvhvc9tIOf8(x9Gq7lhKKJXdTVcytxHEpI3wgbllVZjGeQNhAF5G8ZbVbvR6OcytxHEpI3wgbfvA1qsW7F1dcTVCqsoilhuQ6xRYxHWgce9sen8txu(M8cqyCgYzxYzNCqAoi)CWBq1QoQ87qaj(MbFiH9B)f5G8ZH34PZUOGNUydlyoi)Cqwo8UDOTSR8viSHarVerd)0ffi9n9a5Wij5G3GQvDuj0pjIwW7F1dcTVCqAoinhCLdVBhAl7klfsIQZarb1dTq7lNDjNDYHr5W72H2YUYsHKO6mqu(M8c(MbFiqoijh8guTQJknEc(2TtSuijQodeGCWvo8UDOTSRSuijQodefup0cTVC2LCqwov)Av49V6bH2xb1dTq7lhCLdVBhAl7klfsIQZarb1dTq7lhKMtos35Sto7ZbVbvR6OsOFseTG3)QheAF5WOCw6ZwiG030dWIWdirVwIhoklt3HfbEdko7tSiwkKevNbcXB3o9Eyr4bKq2M6ib3aHEpSmDh2GLP4KDyzclc6SQJqzXblcoudcQglc8guTQJkH(jr0cE)REqO9LdJKKdYLd2yNt1VwfE)REqO9v8V5Gn25G3GQvDuj0pjIwW7F1dcTVCyuo4nOAvhv49V6bH2N4fsCdeIq)uo7ZH3TdTLDfE)REqO9vG030dKdJYbVbvR6OcV)vpi0(eVqIBGqe6Nyry8q7Jfb3CoHXdTpHtbblcNccXzFIfbV)vpi0(eVBgGydwMItKlltyrqNvDekloyrWHAqq1yru9RvH3)QheAFf0w2LZ(CQ(1Qa9hj6L4TLrWcAl7YzFoslNQFTklfsGOH)cKmEKZ(Cqwo4nOAvhvc9tIOf8(x9Gq7lhgljNQFTkq)rIEjEBzeSG6HwO9LZ(CWBq1QoQe6Nerl49V6bH2xomohJhAFLLcjr1zGOS8oNas8nd(qIq)uoyJDo4nOAvhvc9tIOf8(x9Gq7lhgNZsF2cbK(MEGCqAo7Zbz5iTCG(Jwn8Hka)jyqVhGO6iaqVNcDw1rO5Gn25y8qXtc6OVsGCySKCWBq1QoQSzqub3aHy5SpbcOYaLd2yNt1VwfG)emO3dquDeaO3Jasgkwf)BoyJDov)Ava(tWGEpar1raGEpfiz8ihgljNQFTka)jyqVhGO6iaqVNY3KxacJZqo7so7Kd2yNZsF2cbK(MEGCyuov)AvG(Je9s82Yiyb1dTq7lhKYIW4H2hlcO)irVeVTmcYgSmfNGtyzclc6SQJqzXblcpGeY2uhj4gi07HLP7WIW4H2hlc8guTQJyr0VSiauWIGd1GGQXIqA5G3GQvDuzPqsuDgieVD707jN95a9hTA4dva(tWGEpar1raGEpf6SQJqzr4bKOxlXdhLLP7WIaV58elcazq9Eer75BfJhkEkN95y8q7RSuijQodeLL35eqIVzWhse6NYHX5GtYb5NZdhT8n5zrGsaouFdTpwemBuMLEqKtSr5G3GQvDuoXMf5W7lGTdKdZOqkhC4mqKJhypuorNdWWt5WmkKYbhodeGCKTPokheKb17jhM0E(wokihJhkEkhzASLdc)LdZQEpyaKdoCeaO3tHfbEdko7tSiwkKevNbcXB3o9EydwMItKoSmHfbDw1rOS4Gfbkb4q9n0(yrW8SrxoEGEp5Wmo7tGaQmq5Oxo4U)vpi0(WmhGHNYXa58TdRC4Bg8Ha5yGCEBaqRokNvdZb39V6bH2xoY0yR9roC79vVNclcJhAFSi4MZjmEO9jCkiyracOYdwMUdlcoudcQglIQFTkq)rIEjEBzeS4FZzFov)Av49V6bH2xbTLD5Sph8guTQJkH(jr0cE)REqO9LdJZb5yr4uqio7tSiG9R4DZaeBWYuCICWYewe0zvhHYIdweEajKTPosWnqO3dlt3HfHXdTpwe4nOAvhXIOFzraOGfbhQbbvJfH0YbVbvR6OYsHKO6mqiE72P3to7ZjmhDrb6ps0lXBlJGf6SQJqZzFov)AvG(Je9s82YiybTLDSi8as0RL4HJYY0DyrG3CEIfbYYrA5a9hTA4dva(tWGEpar1raGEpf6SQJqZbBSZP6xRcWFcg07biQoca07PacJZqomoNQFTka)jyqVhGO6iaqVNY3KxacJZqo7so7KdsZzFo8UDOTSRa9hj6L4TLrWcK(MEGCyuogp0(klfsIQZarz5DobK4Bg8HeH(PC2LCmEO9vaB6k07r82Yiyz5DobKq98q7lhKFoilh8guTQJkGnDf69iEBzeuuPvdjbV)vpi0(YzFo8UDOTSRa20vO3J4TLrWcK(MEGCyuo8UDOTSRa9hj6L4TLrWcK(MEGCqAo7ZH3TdTLDfO)irVeVTmcwG030dKdJYzPpBHasFtpalcucWH6BO9XIGzJYS0dICInkh8guTQJYj2SihEFbSDGCygfs5GdNbIC8a7HYj6COd4HuoAaYHVzWhcKJbPCmhOZ5TBhHMZQH5i99hLtVYzxBzeSWIaVbfN9jwelfsIQZaH4TBNEpSbltXj4uSmHfbDw1rOS4GfHhqczBQJeCde69WY0DyrWHAqq1yriTCWBq1QoQSuijQodeI3UD69KZ(CWBq1QoQe6Nerl49V6bH2xomohKlN95y8qXtc6OVsGCySKCWBq1QoQSzqub3aHy5SpbcOYaLZ(CKwolfsGWGbblgpu8uo7ZrA5u9RvzRdbiGKXqX)MZ(Cqwov)Av2il07r4Fl(3C2NJXdTVYYzFceqLbQqYtCFqci9n9a5WOCqUICKd2yNdFZGpeqSGgp0(mxomwsoYnhKYIWdirVwIhoklt3HfHXdTpwelfsIQZablcucWH6BO9XIG5zJUCqEnik3aHEp5Wmo7tGaQmqyMdZOqkhC4mqaYbS1EhAovkhpGqZj6CEOJGwq5G82roicizmaYXo0CIohs(Go0CWHZabbZr6YabblSbltXj4mSmHfbDw1rOS4GfHhqczBQJeCde69WY0DyrWHAqq1yrSuibcdgeSy8qXt5Sph8guTQJkH(jr0cE)REqO9LdJZb5YzFoslh8guTQJklfsIQZaH4TBNEp5SphKLJ0YX4H2xzPqQAoxHKN4(qVNC2NJ0YX4H2x5flyxDgik6jwo9zlYzFov)Av2il07r4FlqY4royJDogp0(klfsvZ5kK8e3h69KZ(CKwov)Av26qacizmuGKXJCWg7CmEO9vEXc2vNbIIEILtF2IC2Nt1VwLnYc9Ee(3cKmEKZ(CKwov)Av26qacizmuGKXJCqklcpGe9AjE4OSmDhwegp0(yrSuijQodeSiqjahQVH2hlcMVhQ3tomJcjqyWGGyMdZOqkhC4mqaYXGuoEaHMdq)QZGoSYj6Cq9q9EYb39V6bH2xjNDx6iO5CyHzoXgHvogKYXdi0CIoNh6iOfuoiVDKdIasgdGCKTrxoCOgGCKPoxoxh5uPCKzGGqZXo0CKPXwo4WzGGG5iDzGGGyMtSryLdyR9o0CQuoGxizO50(iNOZ5B6fME5eBuo4WzGGG5iDzGGG5u9RvHnyzkob5HLjSiOZQocLfhSi8asiBtDKGBGqVhwMUdlcucWH6BO9XIGzJVv0C427REp5WmkKYbhode5W3m4dbYr2M6OC4B2DKtVNCqSPRqVNC21wgbzry8q7JfXsHKO6mqWIGd1GGQXIW4H2xbSPRqVhXBlJGfsEI7d9EYzFolVZjGeFZGpKi0pLdJYX4H2xbSPRqVhXBlJGLq5miGeQNhAFSbltXj7oSmHfbDw1rOS4GfbhQbbvJfbEdQw1rLq)KiAbV)vpi0(YHX5GC5SpNQFTkq)rIEjEBzeSG2YUC2Nt1VwfE)REqO9vqBzhlcJhAFSi4MZjmEO9jCkiyr4uqio7tSiaHDOgeva7WcTp2GLPshKJLjSimEO9XIaWBiFJfbDw1rOS4GnydweVqI3)QfSmHLP7WYewegp0(yryqUDKqVGCoIhSiOZQocLfhSbltLlltyrqNvDekloyrGsaouFdTpwegp0(aLxiX7F1cKibx4nOAvhH5zFssFcpGeCF0RfM4nNNKixKdj4nOAvhvO)lwqYCIgIE2Xjbk5mSWuxsiCUxFFj0c9FXcsMt0q0ZooXIW4H2hlILJaBCOTc2GLP4ewMWIGoR6iuwCWIW4H2hlcq7Dc950GGSi4qniOASiKwo4nOAvhv49V6bH2NOpHhq5SphPLdHZ967lHwqHKHUuijWtaa5YzFoslNWC0fLLcjqyWGGf6SQJqzrC2NyraAVtOpNgeKnyzQ0HLjSiOZQocLfhSio7tSiaBgAlJqfnSk6LiA4NUGfHXdTpweGndTLrOIgwf9sen8txWgSmvoyzclcJhAFSi(ke2qH(ThIfbDw1rOS4GnyzkofltyrqNvDekloyrWHAqq1yriTCEHe(YlwWU6mqWIW4H2hlIxSGD1zGGnydwe8(x9Gq7t8UzaILjSmDhwMWIGoR6iuwCWIOFzraOGfHXdTpwe4nOAvhXIaLaCO(gAFSiyEbH(TGYzRLLJRVNCWD)REqO9LJm15YXzGiNyZoga5eDoi8xomR69Gbqo4WraGEp5eDoOuqWVEuoBTSCygfs5GdNbcqoGT27qZPs54beAHfbEZ5jwev)Av49V6bH2xbsFtpqoijNQFTk8(x9Gq7RG6HwO9LdYphKLdVBhAl7k8(x9Gq7RaPVPhihgLt1VwfE)REqO9vG030dKdszr4bKOxlXdhLLP7WIaVbfN9jweK8bDOeQG3)QheAFci9n9aSi8asiBtDKGBGqVhwMUdBWYu5YYewe0zvhHYIdweEajKTPosWnqO3dlt3Hfbkb4q9n0(yrWSrrb5eBuoOEOfAF50RCInkhe(lhMv9EWaihC4iaqVNCWD)REqO9Lt05eBuo0HMtVYj2OC4EiKUihC3)QheAF5ORCInkhUbICK1EhAoGWGroOEOEp5eBkihC3)QheAFfwe9llcdfLfbhQbbvJfb0F0QHpub4pbd69aevhba69uOZQocnN95GSCQ(1Qa8NGb9EaIQJaa9EeqYqXQ4FZbBSZbVbvR6OcjFqhkHk49V6bH2NasFtpqomoNhoAbsFtpqoijNDkYroi)CE4OLVjFoi)Cqwov)Ava(tWGEpar1raGEpLVjVaegNHC2LCQ(1Qa8NGb9EaIQJaa9EkGW4mKdsZbPSiWBopXIaVbvR6OcGHQa1dTq7JfHhqIETepCuwMUdlcJhAFSiWBq1QoIfbEdko7tSii5d6qjubV)vpi0(eq6B6bydwMItyzclc6SQJqzXblcucWH6BO9XIaNo2iyo8UDOTSdKtSzroGT27qZPs54beAoY0ylhC3)QheAF5a2AVdnN(CyLtLYXdi0CKPXwo2LJXdV5Yb39V6bH2xoCde5yhAoxh5itJTCSCq4VCyw17bdGCWHJaa9EY5f28clcJhAFSi4MZjmEO9jCkiyracOYdwMUdlcoudcQglc8guTQJkK8bDOeQG3)QheAFci9n9a5W4CWBq1QoQayOkq9ql0(yr4uqio7tSi49V6bH2NG3TdTLDa2GLPshwMWIGoR6iuwCWIW4H2hlcU5CcJhAFcNccweofeIZ(elcJhkEseMJUaWgSmvoyzclc6SQJqzXblcJhAFSi42XjNO6xlweCOgeunweslhafIAFEqjuckxKhH05LNZ(CQ(1QW7F1dcTVcAl7YzFov)Ava(tWGEpar1raGEpfqyCgYHX5i3C2Ntyo6Ic0FKOxI3wgbl0zvhHMZ(C4D7qBzxb6ps0lXBlJGfi9n9a5WOCKlYXIO6xlXzFIfbWFcg07biQoca07Hfbkb4q9n0(yri9w5GWF5WSQ3dga5Gdhba69KdimodGCmiLZM(SHzoC74KlNyJ(5uPvdPCWD)REqO9LdOZj2SiNyJYbH)YHzvVhmaYbhoca07jNxyZZHBxovkhGTihw5Gsodlcnh)fQlhBfemhC3)QheAF5itJT2h5avad50RCi5FvOfAFf2GLP4uSmHfbDw1rOS4GfHXdTpwelN9jqavgiweOeGd13q7JfH0BLdU7F1dcTVCuqoOTSdZCEHe3aroG(tXMEp5uPvdPCmEO4TqVNC0OWIGd1GGQXIO6xRcV)vpi0(kOTSlN95W72H2YUcV)vpi0(kq6B6bYHr5Wnqic9t5SphJhkEsqh9vcKdJLKdEdQw1rfE)REqO9jwo7tGaQmqSbltXzyzclc6SQJqzXblcoudcQglIQFTk8(x9Gq7RG2YUC2Nt1VwfG)emO3dquDeaO3Jasgkwf)Bo7ZP6xRcWFcg07biQoca07rajdfRcK(MEGCyCoCdeIq)elcJhAFSiEXc2vNbc2GLPipSmHfbDw1rOS4GfbhQbbvJfr1VwfE)REqO9vqBzxo7ZP6xRYlwWM7mWVajJh5SpNQFTkVybBUZa)cK(MEGCyCoCdeIq)elcJhAFSiEXc2vNbc2GLP7oSmHfbDw1rOS4GfbhQbbvJfr1VwfE)REqO9vqBzxo7ZH3TdTLDfE)REqO9vG030dKdJYHBGqe6NYzFoslhEFOEnklN9jHX5qk0(k0zvhHYIW4H2hlILcPQ5CSblt3b5yzclc6SQJqzXblcoudcQglIQFTk8(x9Gq7RG2YUC2NdVBhAl7k8(x9Gq7RaPVPhihgLd3aHi0pXIW4H2hlcaVH8n2GLP7SdltyrqNvDekloyr4bKq2M6ib3aHEpSmDhweCOgeunweBDiabKmgeGxY5ac9elN(Sf5ijhKlN95u9RvH3)QheAFf0w2LZ(CWBq1QoQe6Nerl49V6bH2xomssoixo7Zbz5iTCG(Jwn8HkOkGRVo9miwcE))2HwOZQocnhSXoNQFTkOkGRVo9miwcE))2Hw8V5Gn25u9RvbvbC91PNbXsW7)3ouXc2GO4FZzFoH5Olkq)rIEjEBzeSqNvDeAo7ZH3TdTLDLQFTeOkGRVo9miwcE))2HwGKHIvoinN95GSCKwoq)rRg(qLhOcCyjuUYDuHoR6i0CWg7CqPQFTkpqf4WsOCL7OI)nhKMZ(CqwoslhEJNo7IYrCy7AiAoyJDo8UDOTSRGswSvB4rfi9n9a5Gn25u9RvbLSyR2WJk(3CqAo7Zbz5iTC4nE6Slk4Pl2WcMd2yNdVBhAl7kFfcBiq0lr0WpDrbsFtpqoinN95GSCmEO9v(uqnSONy50NTiN95y8q7R8PGAyrpXYPpBHasFtpqomsso4nOAvhv49V6bH2NGBGqaPVPhihSXohJhAFfaVH8TcjpX9HEp5SphJhAFfaVH8TcjpX9bjG030dKdJYbVbvR6OcV)vpi0(eCdeci9n9a5Gn25y8q7RSuivnNRqYtCFO3to7ZX4H2xzPqQAoxHKN4(Geq6B6bYHr5G3GQvDuH3)QheAFcUbcbK(MEGCWg7CmEO9vEXc2vNbIcjpX9HEp5SphJhAFLxSGD1zGOqYtCFqci9n9a5WOCWBq1QoQW7F1dcTpb3aHasFtpqoyJDogp0(klN9jqavgOcjpX9HEp5SphJhAFLLZ(eiGkduHKN4(Geq6B6bYHr5G3GQvDuH3)QheAFcUbcbK(MEGCqklcpGe9AjE4OSmDhwegp0(yrW7F1dcTpweOeGd13q7JfbU7F1dcTVCaBT3HMtLYXdi0CKTrxoXgLZlK4giYrb5yUFdICw6PGncTWgSmDh5YYewe0zvhHYIdwegp0(yra9hj6L4TLrqweOeGd13q7JfH03Fuo9kNDTLrWC42LtLYXdi0C0lhC3)QheAF5ORC0ihfKdAl7WmNQpYj2uqoGT27qZPphw5uPCq7JYrx5eBeKYrb58BiLdU7F1dcTVCc9t5eDov6OLg5SG9pNyZUCIncs5iR9o0CQuoly)ZXUCqWSIJCWD)REqO9LJZccwyrWHAqq1yru9Rvb6ps0lXBlJGf0w2LZ(CWBq1QoQqYh0HsOcE)REqO9jG030dKdJZbVbvR6OcGHQa1dTq7Jnyz6o4ewMWIGoR6iuwCWIWdiHSn1rcUbc9Eyz6oSi4qniOASiKwo8(q9Au0BrWZCcUb4gkvOZQocnN95iTCWBq1QoQSuijQodeI3UD69KZ(CqwoslhafIAFEqjuckxKhH05LNd2yNdkv9Rv5RqydbIEjIg(PlkOTSlhSXoNQFTka)jyqVhGO6iaqVhbKmuSkOTSlhSXohJhAFLxSGD1zGOqYtCFO3toinN95u9RvH3)QheAFf)Bo7ZrA5u9RvzPqcen8xGKXJC2NJ0YP6xRYwhcqajJHcKmEKZ(C26qacizmiaVKZbe6jwo9zlYbj5u9RvzJSqVhH)TajJh5G8Zbz58Wrlq6B6bYHX5GC5G0CyuoYLfHhqIETepCuwMUdlcJhAFSiwkKevNbcweOeGd13q7JfbZJgBTpYr6DlcEMlhCBaUHsyMdZspiYXdOCygfs5GdNbcqoY2OlNyJWkhz9HHiNV)4B5WHAaYXo0CKTrxomJcjq0WFokih0w2vydwMUJ0HLjSiOZQocLfhSi8asiBtDKGBGqVhwMUdlcJhAFSiWBq1QoIfr)YIaqblcoudcQglcEJNo7IYPpBHyzelcpGe9AjE4OSmDhwe4nNNyrSuibcdgeSaPVPhihgLdEdQw1rfs(GoucvW7F1dcTpbK(MEGC2NdYYH3hQxJIElcEMtWna3qPcDw1rO5Sph8guTQJkK8VepiuXsHKO6mqaYHr5G3GQvDu5icLqflfsIQZabihKMZ(CqwoslNWC0ffO)irVeVTmcwOZQocnhSXohE3o0w2vG(Je9s82YiybsFtpqomoh8guTQJkK8bDOeQG3)QheAFci9n9a5G0CWg7CmEO4jbD0xjqomwso4nOAvhv49V6bH2NaSPRqVhXBlJGSiqjahQVH2hlIDpGYbXMUc9EYzxBzemhupuVNCWD)REqO9LJSn6Yj2iiLJbPCUoYHU2)SLdZOqkhC4mqaYXWBQZQokNOZz5DoSYHKpOdnh9we8mxoCdWnukh7qZPphw5iBJUCK((JYPx5SRTmcMJcYPVC4D7qBzxHfbEdko7tSi8asa20vO3J4TLrq2GLP7ihSmHfbDw1rOS4GfHhqczBQJeCde69WY0DyrWHAqq1yrW7d1RrrVfbpZj4gGBOuo7ZrA5G3GQvDuzPqsuDgieVD707jN95GSCKwoake1(8GsOeuUipcPZlphSXohuQ6xRYxHWgce9sen8txuqBzxoyJDov)Ava(tWGEpar1raGEpcizOyvqBzxoyJDogp0(kVyb7QZarHKN4(qVNCqAo7Zbz5G3GQvDuHK)L4bHkwkKevNbcqomwso4nOAvhvoIqjuXsHKO6mqaYbBSZP6xRcV)vpi0(kq6B6bYHr58WrlFt(CWg7CWBq1QoQqYh0HsOcE)REqO9jG030dKdJKKt1Vwf9we8mNGBaUHsfup0cTVCWg7CQ(1QO3IGN5eCdWnuQacJZqomkh5Md2yNt1Vwf9we8mNGBaUHsfi9n9a5WOCE4OLVjFoyJDo8UDOTSRa20vO3J4TLrWcKmuSYzFo4nOAvhv8asa20vO3J4TLrWCqAo7ZP6xRcV)vpi0(k(3C2NdYYrA5u9RvzPqcen8xGKXJCWg7CQ(1QO3IGN5eCdWnuQaPVPhihgLdYvKJCqAo7ZrA5u9RvzRdbiGKXqbsgpYzFoBDiabKmgeGxY5ac9elN(Sf5GKCQ(1QSrwO3JW)wGKXJCq(5GSCE4Ofi9n9a5W4CqUCqAomkh5YIWdirVwIhoklt3HfHXdTpwelfsIQZabBWY0DWPyzclc6SQJqzXblcJhAFSiwo7tGaQmqSiqjahQVH2hlceV0HMdYBh5GiGKXaihupuVNCWD)REqO9LJf5SPpB58c1gQbwfweCOgeunweilNQFTkBDiabKmgk(3C2NJXdfpjOJ(kbYHXsYbVbvR6OcV)vpi0(elN9jqavgOCqAoyJDoilNQFTklfsGOH)I)nN95y8qXtc6OVsGCySKCWBq1QoQW7F1dcTpXYzFceqLbkNDjhO)OvdFOYsHeiA4VqNvDeAoiLnyz6o4mSmHfbDw1rOS4GfHXdTpweqdvTleGxdYalcucWH6BO9XIq6BOQDroiEnid5a2AVdnNkLJhqO5itJTCSCqE7ihebKmgYbsgkw5eDoEaLJ()eQAb5WkhBfemNyJYHBGiNLEkyJaLCyYMcYrM6C5Cw4HMZHvoakYX)MJLdYBh5GiGKXqoGx6ICwnmNyJYzPN5YbegNHC6vosFdvTlYbXRbzOWIGd1GGQXIO6xRcV)vpi0(k(3C2NJCZb5Nt1VwLToeGasgdfiz8ihKKt1VwLnYc9Ee(3cKmEKdsYzRdbiGKXGa8sohqONy50NTihj5ix2GLP7G8WYewe0zvhHYIdweCOgeunwev)AvwkKard)f)llcJhAFSiEXc2vNbc2GLP7S7WYewe0zvhHYIdweCOgeunwev)Av26qacizmu8V5SpNQFTk8(x9Gq7R4Fzry8q7JfXlwWU6mqWgSmvUihltyrqNvDekloyrWHAqq1yr8cj8IhoAzNcG3q(wo7ZP6xRYgzHEpc)BX)MZ(CmEO4jbD0xjqomkh8guTQJk8(x9Gq7tSC2NabuzGYzFov)Av49V6bH2xX)YIW4H2hlIxSGD1zGGnyzQC3HLjSiOZQocLfhSimEO9XIaSPRqVhXBlJGSiqjahQVH2hlIDpqVNCqSPRqVNC21wgbZb1d17jhC3)QheAF5eDoqcenKYHzuiLdoCgiYXo0C21TMov(CygN9PC4Bg8Ha5WTlNkLtLoAPC1CyMt1h54bEZ5WkN(CyLtF5WSBM3clcoudcQglc8guTQJkEajaB6k07r82Yiyo7ZP6xRcV)vpi0(k(3C2NJ0YX4H2xzPqsuDgik8nd(qGC2NJXdTVY7wtNkVy5Spbk8nd(qGCyuogp0(kVBnDQ8ILZ(eO8n5f8nd(qa2GLPYvUSmHfbDw1rOS4GfHXdTpweq)rIEjEBzeKfbkb4q9n0(yri9w5y5GWF5WSQ3dga5Gdhba69KZlS55iR9o0CQuoEaHIzosF)r50RC21wgbZbS1EhAovkhpGqZzPqqKJUYj2OCi5vqO3tosF)r50RC21wgbZrM6C5qY)QqkhupuVNCInkhUbIclcoudcQglIQFTka)jyqVhGO6iaqVhbKmuSk(3C2Nt1VwfG)emO3dquDeaO3Jasgkwfi9n9a5W4Ci5jUpirOFkhKKJXdTVYYzFceqLbQWnqic9t5SpNQFTkq)rIEjEBzeSaPVPhihgLJXdTVYYzFceqLbQWnqic9t5SphJhkEsqh9vcKdJLKdEdQw1rfE)REqO9jwo7tGaQmqSbltLloHLjSiOZQocLfhSi4qniOASiQ(1Qa8NGb9EaIQJaa9EeqYqXQ4FZzFov)Ava(tWGEpar1raGEpcizOyvG030dKdJZHBGqe6NYzFogpu8KGo6Reihgljh8guTQJk8(x9Gq7tSC2NabuzGyry8q7JfXYzFceqLbInyzQCLoSmHfbDw1rOS4GfbhQbbvJfr1VwfG)emO3dquDeaO3Jasgkwf)Bo7ZP6xRcWFcg07biQoca07rajdfRcK(MEGCyCoK8e3hKi0pLdsYX4H2x5flyxDgikCdeIq)uo7ZP6xRc0FKOxI3wgblq6B6bYHr5y8q7R8IfSRodefUbcrOFIfHXdTpweq)rIEjEBzeKnyzQCLdwMWIGoR6iuwCWIGd1GGQXIO6xRcWFcg07biQoca07rajdfRI)nN95u9Rvb4pbd69aevhba69iGKHIvbsFtpqomohUbcrOFIfHXdTpweVyb7QZabBWYu5ItXYewe0zvhHYIdwegp0(yr8IfSRodeSiqjahQVH2hlIDflyZDg4NZlS5GCaBT3HMtLYXdi0C0lhC3)QheAF5yroB6ZgbZ5fQnudSYj2SlNDDRPtLphMXzFcKJDO5GG3q(wHfbhQbbvJfr1VwLxSGn3zGFbsgpYzFov)AvEXc2CNb(fi9n9a5W4C4gieH(PC2Nt1VwfE)REqO9vG030dKdJZHBGqe6NYzFogpu8KGo6ReihgLdEdQw1rfE)REqO9jwo7tGaQmq5SphKLJ0YH3hQxJIElcEMtWna3qPcDw1rO5Gn25u9RvrVfbpZj4gGBOubsFtpqomohsEI7dse6NYbBSZP6xRYgzHEpc)BbsgpYbj5S1HaeqYyqaEjNdi0tSC6ZwKdJYrU5Gu2GLPYfNHLjSiOZQocLfhSimEO9XI4DRPtLxSC2NaSiqjahQVH2hlIDpGYzx3A6u5ZHzC2Na5yhAoi4nKVLJE5G7(x9Gq7lNOZzJCV58qhbTGYb5TJCqeqYyaKJSn6YHzuiLdoCgia5yqkNRJCm8M6SQJYPH5CeHMt05uPC49biiEcTWIGd1GGQXIO6xRcV)vpi0(k(3C2Ntan8Kte6NYHr5u9RvH3)QheAFfi9n9a5SpNQFTkBKf69i8Vfiz8ihKKZwhcqajJbb4LCoGqpXYPpBromkh5YgSmvUipSmHfbDw1rOS4GfbhQbbvJfr1VwfE)REqO9vG030dKdJZHBGqe6Nyry8q7JfbG3q(gBWYu5U7WYewe0zvhHYIdwegp0(yr4u869iQ9VYIaLaCO(gAFSiKERCIncs5OGddro01(NTCc9t54OvKJE5G7(x9Gq7lNvdZXYzx3A6u5ZHzC2Na50WCqWBiFlNOZztJC0dOOuo9khC3)QheAFyMJhq5a6pfB69Kd5auHfbhQbbvJfr1VwfE)REqO9vG030dKdJY5HJw(M85SphJhkEsqh9vcKdJZzh2GLP4eKJLjSiOZQocLfhSi4qniOASiQ(1QW7F1dcTVcK(MEGCyuopC0Y3KpN95u9RvH3)QheAFf)llcJhAFSiqH2tFarfswSXgSblcJhkEseMJUaWYewMUdltyrqNvDekloyrWHAqq1yry8qXtc6OVsGCyCo7KZ(CQ(1QW7F1dcTVcAl7YzFoilh8guTQJkH(jr0cE)REqO9LdJZH3TdTLDfNIxVhrT)1cQhAH2xoyJDo4nOAvhvc9tIOf8(x9Gq7lhgjjhKlhKYIW4H2hlcNIxVhrT)v2GLPYLLjSiOZQocLfhSi4qniOASiWBq1QoQe6Nerl49V6bH2xomssoixoyJDov)Av49V6bH2xbsFtpqomoNaA4jNi0pLd2yNdYYH3TdTLDLpfudlOEOfAF5WOCWBq1QoQe6Nerl49V6bH2xo7ZrA5eMJUOa9hj6L4TLrWcDw1rO5G0CWg7CcZrxuG(Je9s82YiyHoR6i0C2Nt1VwfO)irVeVTmcw8V5Sph8guTQJkH(jr0cE)REqO9LdJZX4H2x5tb1WcVBhAl7YbBSZzPpBHasFtpqomkh8guTQJkH(jr0cE)REqO9XIW4H2hlIpfudzdwMItyzclc6SQJqzXblcoudcQglIWC0ffZrYdcObywWaILhIvHoR6i0C2NdYYP6xRcV)vpi0(kOTSlN95iTCQ(1QS1HaeqYyO4FZbPSimEO9XIafAp9bevizXgBWgSiaHDOgeva7WcTpwMWY0Dyzclc6SQJqzXblcoudcQglcJhkEsqh9vcKdJLKdEdQw1rLToeGasgdILZ(eiGkduo7Zbz5u9RvzRdbiGKXqX)Md2yNt1VwLLcjq0WFX)Mdszry8q7JfXYzFceqLbInyzQCzzclc6SQJqzXblcoudcQglIQFTkOKfB1gEuX)MZ(CG(Jwn8HkOKfBaXYIT(xOZQocnN95G3GQvDuj0pjIwW7F1dcTVCyuov)Avqjl2Qn8OcK(MEGC2NJXdfpjOJ(kbYHXsYrUSimEO9XIyPqQAohBWYuCcltyrqNvDekloyrWHAqq1yru9RvzPqcen8x8VSimEO9XI4flyxDgiydwMkDyzclc6SQJqzXblcoudcQglIQFTkBDiabKmgk(3C2Nt1VwLToeGasgdfi9n9a5WOCmEO9vwkKQMZvi5jUpirOFIfHXdTpweVyb7QZabBWYu5GLjSiOZQocLfhSi4qniOASiQ(1QS1HaeqYyO4FZzFoilNxiHx8Wrl7uwkKQMZLd2yNZsHeimyqWIXdfpLd2yNJXdTVYlwWU6mqu0tSC6ZwKdszry8q7JfXlwWU6mqWgSmfNILjSiOZQocLfhSimEO9XIy5SpbcOYaXIaLaCO(gAFSiyceRCIoNhkYbbZkoY5f2Cqo6buukhPFVR58UzacKtdZb39V6bH2xoVBgGa5iBJUCEBaqRoQWIGd1GGQXIW4HINe0rFLa5Wyj5G3GQvDuzZGOcUbcXYzFceqLbkN95u9Rvb4pbd69aevhba69iGKHIvX)MZ(Cqwo8UDOTSRa9hj6L4TLrWcK(MEGCqsogp0(kq)rIEjEBzeSqYtCFqIq)uoijhUbcrOFkhgNt1VwfG)emO3dquDeaO3Jasgkwfi9n9a5Gn25iTCcZrxuG(Je9s82YiyHoR6i0CqAo7ZbVbvR6OsOFseTG3)QheAF5GKC4gieH(PCyCov)Ava(tWGEpar1raGEpcizOyvG030dWgSmfNHLjSiOZQocLfhSi4qniOASiQ(1QS1HaeqYyO4FZzFoaYG69iI2Z3kgpu8elcJhAFSiEXc2vNbc2GLPipSmHfbDw1rOS4GfbhQbbvJfr1VwLxSGn3zGFbsgpYzFoCdeIq)uomkNQFTkVybBUZa)cK(MEGC2NdYYrA5a9hTA4dva(tWGEpar1raGEpf6SQJqZbBSZP6xRYlwWM7mWVaPVPhihgLJXdTVYsHu1CUc3aHi0pLdsYHBGqe6NYb5Nt1VwLxSGn3zGFbsgpYbPSimEO9XI4flyxDgiydwMU7WYewe0zvhHYIdweEajKTPosWnqO3dlt3HfbhQbbvJfH0YzPqcegmiyX4HINYzFoslh8guTQJklfsIQZaH4TBNEp5SpNQFTka)jyqVhGO6iaqVhbKmuSkOTSlN95GSCqwoilhJhAFLLcPQ5CfsEI7d9EYzFoilhJhAFLLcPQ5CfsEI7dsaPVPhihgLdYvKJCWg7CKwoq)rRg(qLLcjq0WFHoR6i0CqAoyJDogp0(kVyb7QZarHKN4(qVNC2NdYYX4H2x5flyxDgikK8e3hKasFtpqomkhKRih5Gn25iTCG(Jwn8HklfsGOH)cDw1rO5G0CqAo7ZP6xRYgzHEpc)BbsgpYbP5Gn25GSCaKb17reTNVvmEO4PC2NdYYP6xRYgzHEpc)BbsgpYzFoslhJhAFfaVH8TcjpX9HEp5Gn25iTCQ(1QS1HaeqYyOajJh5SphPLt1VwLnYc9Ee(3cKmEKZ(CmEO9va8gY3kK8e3h69KZ(CKwoBDiabKmgeGxY5ac9elN(Sf5G0CqAoiLfHhqIETepCuwMUdlcJhAFSiwkKevNbcweOeGd13q7JfbZ3d17jNyJYbe2HAq0CGDyH2hM50NdRC8akhMrHuo4WzGaKJSn6Yj2iSYXGuoxh5uj9EY5TBhHMZQH5i97DnNgMdU7F1dcTVso7EaLdZOqkhC4mqKdPXgbZb1d17jhlhMrHu1CoCTRyb7QZaroCde5iBJUCqEjl07jND)BokihJhkEkNgMdQhQ3toK8e3huoY0ylheKb17jhM0E(wHnyz6oihltyrqNvDekloyrWHAqq1yru9RvzRdbiGKXqX)MZ(CmEO4jbD0xjqomkh8guTQJkBDiabKmgelN9jqavgiwegp0(yr8IfSRodeSblt3zhwMWIGoR6iuwCWIGd1GGQXIqA5G3GQvDu5DRPtLx82TtVNC2NdYYrA5eMJUOSG9xeBKWaBeOqNvDeAoyJDogpu8KGo6ReihgNZo5G0C2NdYYX4HINeODu0NtdkhgLJCZbBSZX4HINe0rFLa5Wyj5G3GQvDuzZGOcUbcXYzFceqLbkhSXohJhkEsqh9vcKdJLKdEdQw1rLToeGasgdILZ(eiGkduoiLfHXdTpweVBnDQ8ILZ(eGnyz6oYLLjSiOZQocLfhSimEO9XIGBoNW4H2NWPGGfHtbH4SpXIW4HINeH5OlaSblt3bNWYewe0zvhHYIdweCOgeunwegpu8KGo6ReihgNZoSimEO9XIafAp9bevizXgBWY0DKoSmHfbDw1rOS4GfbhQbbvJfbGmOEpIO98TIXdfpXIW4H2hlcaVH8n2GLP7ihSmHfbDw1rOS4GfbhQbbvJfHXdfpjOJ(kbYHXsYbVbvR6OIb52rcs(xxd0(YzFoF7SYlpYHXsYbVbvR6OIb52rcs(xxd0(eF7SC2NtyWhkkY0ytVDqowegp0(yryqUDKGK)11aTp2GLP7GtXYewe0zvhHYIdwegp0(yrSC2NabuzGyrGsaouFdTpwempASLdDT)zlNWGpuaWmhnYrb5y58y6Lt05WnqKdZ4SpbcOYaLJbYzPohbZrpqqgAo9khMrHu1CUclcoudcQglcJhkEsqh9vcKdJLKdEdQw1rLndIk4gielN9jqavgi2GLP7GZWYewegp0(yrSuivnNJfbDw1rOS4GnydweW(v8UzaILjSmDhwMWIGoR6iuwCWIW4H2hlILZ(eiGkdelcucWH6BO9XIG5todRCWD)REqO9LZQH5iDPqydb50RCysd)0ffweCOgeunwegpu8KGo6Reihgljh8guTQJkBDiabKmgelN9jqavgOC2NdYYP6xRYwhcqajJHI)nhSXoNQFTklfsGOH)I)nhKYgSmvUSmHfbDw1rOS4GfbhQbbvJfr1VwfuYITAdpQ4FZzFoq)rRg(qfuYInGyzXw)l0zvhHMZ(CWBq1QoQe6Nerl49V6bH2xomkNQFTkOKfB1gEubsFtpqo7ZX4HINe0rFLa5Wyj5ixwegp0(yrSuivnNJnyzkoHLjSiOZQocLfhSi4qniOASimEO4jbD0xjqomwso4nOAvhv2miQGBGqSC2NabuzGYzFov)Ava(tWGEpar1raGEpcizOyv8V5SpNQFTka)jyqVhGO6iaqVhbKmuSkq6B6bYHX5Wnqic9tSimEO9XIy5SpbcOYaXgSmv6WYewe0zvhHYIdweCOgeunwev)Ava(tWGEpar1raGEpcizOyv8V5SpNQFTka)jyqVhGO6iaqVhbKmuSkq6B6bYHX5Wnqic9tSimEO9XI4flyxDgiydwMkhSmHfbDw1rOS4GfbhQbbvJfr1VwLLcjq0WFX)YIW4H2hlIxSGD1zGGnyzkofltyrqNvDekloyrWHAqq1yru9RvzRdbiGKXqX)YIW4H2hlIxSGD1zGGnyzkodltyrqNvDekloyr4bKq2M6ib3aHEpSmDhweCOgeunweslh8guTQJklfsIQZaH4TBNEp5SpNQFTka)jyqVhGO6iaqVhbKmuSkOTSlN95y8qXtc6OVsGCyuo4nOAvhv2miQGBGqSC2NabuzGYzFoslNLcjqyWGGfJhkEkN95GSCKwov)Av2il07r4Fl(3C2NJ0YP6xRYwhcqajJHI)nN95iTCEHeErVwIhoAzPqsuDgiYzFoilhJhAFLLcjr1zGOW3m4dbYHXsYrU5Gn25GSCcZrxumhjpiGgGzbdiwEiwf6SQJqZzFo8UDOTSRGcTN(aIkKSyRajdfRCqAoyJDoaYG69iI2Z3kgpu8uoinhKYIWdirVwIhoklt3HfHXdTpwelfsIQZablcucWH6BO9XIy3dOC6JYHzuiLdoCgiYHmOdRC0lhPFVR5ORCWQ95G2hgIC2m8uoKgBemhKxYc9EYz3)MtdZb5TJCqeqYyihSOih7qZH0yJGYzoiZqAoBgEkNFdPCIn7YjK15yoizOyHzoiRI0C2m8uomBhjpiGgGzbddGCygpeRCGKHIvorNJhqyMtdZbzCKMdcYG69KdtApFlhfKJXdfpvYH53hgICq7CInfKJSn1r5Szq0C4gi07jhMXzFceqLbcKtdZr2gD5GWF5WSQ3dga5Gdhba69KJcYbsgkwf2GLPipSmHfbDw1rOS4GfHhqczBQJeCde69WY0DyrWHAqq1yriTCWBq1QoQSuijQodeI3UD69KZ(CKwolfsGWGbblgpu8uo7ZP6xRcWFcg07biQoca07rajdfRcAl7YzFoilhKLdYYX4H2xzPqQAoxHKN4(qVNC2NdYYX4H2xzPqQAoxHKN4(Geq6B6bYHr5GCf5ihSXohPLd0F0QHpuzPqcen8xOZQocnhKMd2yNJXdTVYlwWU6mqui5jUp07jN95GSCmEO9vEXc2vNbIcjpX9bjG030dKdJYb5kYroyJDoslhO)OvdFOYsHeiA4VqNvDeAoinhKMZ(CQ(1QSrwO3JW)wGKXJCqAoyJDoilhazq9Eer75BfJhkEkN95GSCQ(1QSrwO3JW)wGKXJC2NJ0YX4H2xbWBiFRqYtCFO3toyJDoslNQFTkBDiabKmgkqY4ro7ZrA5u9RvzJSqVhH)TajJh5SphJhAFfaVH8TcjpX9HEp5SphPLZwhcqajJbb4LCoGqpXYPpBroinhKMdszr4bKOxlXdhLLP7WIW4H2hlILcjr1zGGfbkb4q9n0(yrS7buomJcPCWHZaroKgBemhupuVNCSCygfsvZ5W1UIfSRode5WnqKJSn6Yb5LSqVNC29V5OGCmEO4PCAyoOEOEp5qYtCFq5itJTCqqguVNCys75Bf2GLP7oSmHfbDw1rOS4GfHXdTpweCZ5egp0(eofeSiCkieN9jwegpu8KimhDbGnyz6oihltyrqNvDekloyrWHAqq1yru9Rv5flyZDg4xGKXJC2Nd3aHi0pLdJYP6xRYlwWM7mWVaPVPhiN95Wnqic9t5WOCQ(1Qa9hj6L4TLrWcK(MEGC2NdYYrA5a9hTA4dva(tWGEpar1raGEpf6SQJqZbBSZP6xRYlwWM7mWVaPVPhihgLJXdTVYsHu1CUc3aHi0pLdsYHBGqe6NYb5Nt1VwLxSGn3zGFbsgpYbPSimEO9XI4flyxDgiydwMUZoSmHfbDw1rOS4GfbhQbbvJfr1VwLToeGasgdf)Bo7ZbqguVhr0E(wX4HINYzFogpu8KGo6ReihgLdEdQw1rLToeGasgdILZ(eiGkdelcJhAFSiEXc2vNbc2GLP7ixwMWIGoR6iuwCWIGd1GGQXIqA5G3GQvDu5DRPtLx82TtVNC2NdYYX4HINeODu0NtdkhgLJCZbBSZX4HINe0rFLa5Wyj5G3GQvDuzZGOcUbcXYzFceqLbkhSXohJhkEsqh9vcKdJLKdEdQw1rLToeGasgdILZ(eiGkduoiLfHXdTpweVBnDQ8ILZ(eGnyz6o4ewMWIGoR6iuwCWIGd1GGQXIaqguVhr0E(wX4HINyry8q7JfbG3q(gBWY0DKoSmHfbDw1rOS4GfbhQbbvJfHXdfpjOJ(kbYHX5ixwegp0(yrGcTN(aIkKSyJnyz6oYbltyrqNvDekloyrWHAqq1yry8qXtc6OVsGCySKCWBq1QoQyqUDKGK)11aTVC2NZ3oR8YJCySKCWBq1QoQyqUDKGK)11aTpX3olN95eg8HIImn20BhKJfHXdTpwegKBhji5FDnq7Jnyz6o4uSmHfbDw1rOS4GfHXdTpwelN9jqavgiweOeGd13q7JfbZJgB5qx7F2Yjm4dfamZrJCuqowopME5eDoCde5Wmo7tGaQmq5yGCwQZrWC0deKHMtVYHzuivnNRWIGd1GGQXIW4HINe0rFLa5Wyj5G3GQvDuzZGOcUbcXYzFceqLbInyz6o4mSmHfHXdTpwelfsvZ5yrqNvDekloyd2GnyrGNGaTpwMkxKtUYf5KoiNCWIqMbp9EaSiyEy2sFMk9y6URCMtomzJYr)VnmYz1WCWaSFfVBgGWqoqcN7viHMdO)uoMp6VfeAo8n7EiqjLA30JYrUYzo4Up8emi0CWa0F0QHpuH5WqorNdgG(Jwn8HkmxHoR6iumKdY2rEKwsP2n9OCWzKZCWDF4jyqO5GHWC0ffMdd5eDoyimhDrH5k0zvhHIHCq2oYJ0sk1UPhLdYJCMdU7dpbdcnhma9hTA4dvyomKt05GbO)OvdFOcZvOZQocfd5Gm5kpslPu7MEuo7GCYzo4Up8emi0CWa0F0QHpuH5WqorNdgG(Jwn8HkmxHoR6iumKdY2rEKwsPsPyEy2sFMk9y6URCMtomzJYr)VnmYz1WCWakTmVlWqoqcN7viHMdO)uoMp6VfeAo8n7EiqjLA30JYzh5mhC3hEcgeAoya6pA1WhQWCyiNOZbdq)rRg(qfMRqNvDekgYXICyEXP3TCq2oYJ0sk1UPhLJ0roZb39HNGbHMdgG(Jwn8HkmhgYj6CWa0F0QHpuH5k0zvhHIHCSihMxC6DlhKTJ8iTKsTB6r5GtjN5G7(WtWGqZbdq)rRg(qfMdd5eDoya6pA1WhQWCf6SQJqXqowKdZlo9ULdY2rEKwsP2n9OC2roKZCWDF4jyqO5Gq)4ohawxyYNJ0T0DorNZU5TC(nQ35b50Ve0IgMdYKUrAoiBh5rAjLA30JYzh5qoZb39HNGbHMdg49H61OWCyiNOZbd8(q9AuyUcDw1rOyihKTJ8iTKsTB6r5SdoLCMdU7dpbdcnhmeq9yGIYofMdd5eDoyiG6XafLyNcZHHCqgorEKwsP2n9OC2bNsoZb39HNGbHMdgcOEmqrrUfMdd5eDoyiG6XafLqUfMdd5GmCI8iTKsTB6r5SdoJCMdU7dpbdcnhmW7d1RrH5WqorNdg49H61OWCf6SQJqXqoiBh5rAjLA30JYrUYHCMdU7dpbdcnhma9hTA4dvyomKt05GbO)OvdFOcZvOZQocfd5GSDKhPLuQDtpkh5ItjN5G7(WtWGqZbdq)rRg(qfMdd5eDoya6pA1WhQWCf6SQJqXqoiBh5rAjLA30JYrU4mYzo4Up8emi0CWqyo6IcZHHCIohmeMJUOWCf6SQJqXqoiBh5rAjLA30JYrU4mYzo4Up8emi0CWa0F0QHpuH5WqorNdgG(Jwn8HkmxHoR6iumKdY2rEKwsP2n9OCKlYJCMdU7dpbdcnhma9hTA4dvyomKt05GbO)OvdFOcZvOZQocfd5GSDKhPLuQDtpkh5U7iN5G7(WtWGqZbdq)rRg(qfMdd5eDoya6pA1WhQWCf6SQJqXqoiBh5rAjLA30JYbNGCYzo4Up8emi0CqOFCNdaRlm5Zr6oNOZz38woOkEfO9Lt)sqlAyoidxinhKHtKhPLuQDtpkhCcYjN5G7(WtWGqZbH(XDoaSUWKphPBP7CIoNDZB58BuVZdYPFjOfnmhKjDJ0Cq2oYJ0sk1UPhLdorUYzo4Up8emi0CWa0F0QHpuH5WqorNdgG(Jwn8HkmxHoR6iumKdY2rEKwsP2n9OCWj4e5mhC3hEcgeAoya6pA1WhQWCyiNOZbdq)rRg(qfMRqNvDekgYXICyEXP3TCq2oYJ0sk1UPhLdoroKZCWDF4jyqO5GbO)OvdFOcZHHCIohma9hTA4dvyUcDw1rOyihKTJ8iTKsTB6r5GtKd5mhC3hEcgeAoyimhDrH5WqorNdgcZrxuyUcDw1rOyihKTJ8iTKsLsX8WSL(mv6X0Dx5mNCyYgLJ(FByKZQH5GHxiX7F1cmKdKW5EfsO5a6pLJ5J(BbHMdFZUhcusP2n9OCWjYzo4Up8emi0CWqyo6IcZHHCIohmeMJUOWCf6SQJqXqowKdZlo9ULdY2rEKwsPsPyEy2sFMk9y6URCMtomzJYr)VnmYz1WCWaV)vpi0(e8UDOTSdGHCGeo3Rqcnhq)PCmF0Fli0C4B29qGsk1UPhLdoLCMdU7dpbdcnhma9hTA4dvyomKt05GbO)OvdFOcZvOZQocfd5GSDKhPLuQukMhMT0NPspMU7kN5Kdt2OC0)BdJCwnmhmy8qXtIWC0famKdKW5EfsO5a6pLJ5J(BbHMdFZUhcusP2n9OCKRCMdU7dpbdcnhmeMJUOWCyiNOZbdH5OlkmxHoR6iumKdYKR8iTKsTB6r5GtKZCWDF4jyqO5GHWC0ffMdd5eDoyimhDrH5k0zvhHIHCq2oYJ0skvkfZdZw6ZuPht3DLZCYHjBuo6)THroRgMdgaHDOgeva7WcTpmKdKW5EfsO5a6pLJ5J(BbHMdFZUhcusP2n9OCKRCMdU7dpbdcnhma9hTA4dvyomKt05GbO)OvdFOcZvOZQocfd5GSDKhPLuQDtpkhCk5mhC3hEcgeAoyimhDrH5WqorNdgcZrxuyUcDw1rOyihKTJ8iTKsTB6r5G8iN5G7(WtWGqZbdq)rRg(qfMdd5eDoya6pA1WhQWCf6SQJqXqoiBh5rAjLA30JYz3roZb39HNGbHMdgG(Jwn8HkmhgYj6CWa0F0QHpuH5k0zvhHIHCqMCLhPLuQDtpkND2roZb39HNGbHMdgcZrxuyomKt05GHWC0ffMRqNvDekgYbz7ipslPuPumpmBPptLEmD3voZjhMSr5O)3gg5SAyoyG3)QheAFI3ndqyihiHZ9kKqZb0FkhZh93ccnh(MDpeOKsTB6r5ix5mhC3hEcgeAoya6pA1WhQWCyiNOZbdq)rRg(qfMRqNvDekgYbz7ipslPu7MEuoYHCMdU7dpbdcnhmeMJUOWCyiNOZbdH5OlkmxHoR6iumKdY2rEKwsP2n9OC2DKZCWDF4jyqO5GbEFOEnkmhgYj6CWaVpuVgfMRqNvDekgYXICyEXP3TCq2oYJ0sk1UPhLZo7iN5G7(WtWGqZbdH5OlkmhgYj6CWqyo6IcZvOZQocfd5GSDKhPLuQDtpkND2roZb39HNGbHMdgG(Jwn8HkmhgYj6CWa0F0QHpuH5k0zvhHIHCqMCLhPLuQDtpkNDWjYzo4Up8emi0CWaVpuVgfMdd5eDoyG3hQxJcZvOZQocfd5GSDKhPLuQDtpkNDKoYzo4Up8emi0CWqyo6IcZHHCIohmeMJUOWCf6SQJqXqoiBh5rAjLA30JYzhPJCMdU7dpbdcnhmW7d1RrH5WqorNdg49H61OWCf6SQJqXqoiBh5rAjLA30JYzhCk5mhC3hEcgeAoya6pA1WhQWCyiNOZbdq)rRg(qfMRqNvDekgYbz7ipslPu7MEuoYfNsoZb39HNGbHMdg49H61OWCyiNOZbd8(q9AuyUcDw1rOyihKTJ8iTKsLsj9(Vnmi0CWzYX4H2xoofeGskflIxyVuhXIaJymhMrHuosx2dLsHrmMZweVa5ex46rJnFTW7pUa637Sq7JdTvGlG(54kLcJymhM9luD5GZGzoYf5KRCtPsPWigZb3B29qa5mLcJymNDjNDpGYzPpBHasFtpqoql2iyoXMD5eg8HIsOFseTavPCwnmhNbIDbq8(qZXQQtdSYXdShcusPWigZzxYz36gqxoCde5ajCUxH0NUaKZQH5G7(x9Gq7lhKPfQGzoO9HHiNT2HMJg5SAyowolib2Yr6IcQH5WnqG0skfgXyo7somVNvDuoGaQ8ih(gXzqVNC6lhlNfjlNvdzaKJE5eBuom7DD3Yj6CGeQNt5iRHm4AdTKsHrmMZUKdZgLzPhe5y5SRyb7QZaro0fqSYj2Sih0Ma5CDKZVrjxoYiNlh92Lh7t5GmG(ZjiqqO5yroxNdqFoDPC7ICy(7kIC0)RXdKwsPWigZzxYb39HNGroMZLt1VwfMRajJh5qxavcKt05u9RvH5k(xmZXUCm3Vbro6b0Ntxk3UihM)UIiNhtVC0lhG(bLukmIXC2LC29akNndIYBucnh8guTQJa5eDoqc1ZPCW9UU7ZrwdzW1gAjLkLcJymhMx5jUpi0CQ0QHuo8(xTiNk9OhOKdZMZP3aKZ13USzW)Y7YX4H2hiN(CyvsPmEO9bkVqI3)QfircUmi3osOxqohXJukmIXCy276ULdoRbvR6OCWPFdTp5mhP3khaf5eDowoxF7cZceSZbV58eM5eBuo4U)vpi0(YX4H2xo2HMdVBhAl7a5eBwKJbPC49bcOPhHMt050NdRCQuoEaHMJSn6Yb39V6bH2xokih)BoYuNlNRJCQuoEaHMdQhQ3toXgLdq)ENfAFLukmMJXdTpq5fs8(xTajsWfEdQw1ryE2NKGQaR6ibV)vpi0(WSFLajafPuyeJ5WS31DlhCwdQw1r5Gt)gAFYzomztb5G3GQvDuoGxIRlLa5iBJIncMdU7F1dcTVCaBT3HMtLYXdi0Cq9q9EYHzuibcdgeSKsHXCmEO9bkVqI3)QfircUWBq1QocZZ(KKLcjqyWGGcE)REqO9HjkTmVlKSl7GjEZ5jjslmhDr5flyZDg4JPUKG3GQvDuzPqcegmiOG3)QheAFmc5sPWigZHzVR7wo4SguTQJYbN(n0(KZCyYMcYbVbvR6OCaVexxkbYj2OCo)VsWC6voHbFOaKJf5iBt5B5G82roicizmKdZ4SpbcOYabYP9bqrPC6vo4U)vpi0(YbS1EhAovkhpGqlPuymhJhAFGYlK49VAbsKGl8guTQJW8SpjzRdbiGKXGy5SpbcOYaHPUKG3GQvDuzRdbiGKXGy5SpbcOYajb5WeV58Ke5I8dZrxuwo7tIxl4Bir6G8Lwyo6IYYzFs8AbFlLcJymhM9UUB5GZAq1QokhC63q7toZHjBkih8guTQJYb8sCDPeiNyJY58)kbZPx5eg8HcqowKJSnLVLdYRbrZb3giYHzC2NabuzGa50(aOOuo9khC3)QheAF5a2AVdnNkLJhqO5yGCwQZrWskfgZX4H2hO8cjE)RwGej4cVbvR6imp7ts2miQGBGqSC2NabuzGWuxsWBq1QoQSzqub3aHy5SpbcOYajb5WeV58KeCcYpmhDrz5SpjETGVHeCkKV0cZrxuwo7tIxl4BPuyeJ5WS31DlhCwdQw1r5Gt)gAFYzomztb5G3GQvDuoGxIRlLa5eBuoN)xjyo9kNWGpuaYXICKTP8TCqE7ihebKmgYHzC2NabuzGa5yqkhpGqZb1d17jhC3)QheAFLukmMJXdTpq5fs8(xTajsWfEdQw1ryE2NKW7F1dcTpXYzFceqLbctDjbVbvR6OcV)vpi0(elN9jqavgijihM4nNNKGtq(H5OlklN9jXRf8nKGtH8Lwyo6IYYzFs8AbFlLcJymhM9UUB5GZAq1QokhC63q7toZHjBkih8guTQJYb8sCDPeiNyJY58)kbZPx5eg8HcqowKJSnLVLdZgYTJYH5v(xxd0(YP9bqrPC6vo4U)vpi0(YbS1EhAovkhpGqlPuymhJhAFGYlK49VAbsKGl8guTQJW8SpjXGC7ibj)RRbAFyQlj4nOAvhvmi3osqY)6AG2NeKdt8MZts2D2Dq(H5OlklN9jXRf8nKixKV0cZrxuwo7tIxl4BPuyeJ5WS31DlhCwdQw1r5Gt)gAFYzomztb5G3GQvDuoGxIRlLa5eBuoVeKtxypuo9kNVDwovY1YYr2MY3YHzd52r5W8k)RRbAF5itDUCUoYPs54beAjLcJ5y8q7duEHeV)vlqIeCH3GQvDeMN9jjgKBhji5FDnq7t8TZWeLwM3fsKoihM9ReibOiLcJymhM9UUB5GZAq1QokhC63q7toZHjBuoN)xjyo9kNWGpuaYXICKTP8TCqSPRqVNC21wgbZHBxoEaHMdQhQ3to4U)vpi0(kPuymhJhAFGYlK49VAbsKGl8guTQJW8SpjH3)QheAFcWMUc9EeVTmcIPUKG3GQvDuH3)QheAFcWMUc9EeVTmckb5WeV58Ke8guTQJk8(x9Gq7tSC2NabuzGsPWigZHzVR7wo4SguTQJYbN(n0(KZCyYgLtOFkhi9n907jN(YXYHBGihzB0LdU7F1dcTVC42LtLYXdi0C0lhaX7dfusPWyogp0(aLxiX7F1cKibx4nOAvhH5zFscV)vpi0(eCdeci9n9ayIslZ7cjixbNbZ(vcKauKsHrmMdZEx3TCWznOAvhLdo9BO9jN5WKnfKdEdQw1r5aEjUUucKtSr5C(FLG50RCaeVpuqo9khMrHuo4WzGiNyZICaBT3HMtLY5TBhHMZRbICInkhuAzExKJ9B)fLukmMJXdTpq5fs8(xTajsWfEdQw1ryE2NK04j4B3oXsHKO6mqaWeLwM3fsqom7xjqcqrkfgXyom7DD3YbN1GQvDuo40VH2NCMdYBllhxFp5uPvdPCWD)REqO9LdyR9o0CyE)VybjZLdone9SJt5uPC8acLzXukmMJXdTpq5fs8(xTajsWfEdQw1ryE2NKq)xSGK5ene9SJtcuYzyHjkTmVlKSdYdM9ReibOiLcJymhP3khC3)QheAF5OGCqvGvDekM5a4BeQ3r5eBuolfcICWD)REqO9LZYG5yRGG5eBuol9zlYHouqjLcJ5y8q7duEHeV)vlqIeCH3GQvDeMN9jjH(jr0cE)REqO9HjEZ5jjl9zleq6B6bqYoihYHPUKG3GQvDubvbw1rcE)REqO9LsHrmMdt2OCq9ql0(YPx5y5GWF5WSQ3dga5Gdhba69KdU7F1dcTVskfgZX4H2hO8cjE)RwGej4cVbvR6imp7tsamufOEOfAFyI3CEscALxO1I4rb5rUipsh5ICLQbibEZ5PukmMdt2OCo)VsWC6voaI3hkiNELdZOqkhC4mqKdK4Bg8HqZPIvosxke2qqo9khM0WpDrjLcJ5y8q7duEHeV)vlqIeCH3GQvDeMN9jj)oeqIVzWhsy)2FbM4nNNKGw5fATiEuqEWz2rU4msNs1aKaV58ukfgXyompBuSrWCSC8aR6OC0G(54beAorNt1Vw5G7(x9Gq7lhfKdHZ967lHwsPWyogp0(aLxiX7F1cKibx4nOAvhH5zFscV)vpi0(e9j8act8MZtsiCUxFFj0YJZqvlAiqun0hcBSjCUxFFj0Y34wfscWgrH47bkhBSjCUxFFj0IEao0hw1rcCU3UW)fOeELtyJnHZ967lHwa(R66gvyFk2WceyJnHZ967lHwO)lwqYCIgIE2XjSXMW5E99LqllN9jrVevlchHn2eo3RVVeArMXaDeeiwW(qXgBcN713xcTOhiGEE0qGavXRhjQKZHn2eo3RVVeAbSzOTmcv0WQOxIOHF6IukmIXCqEBz5467jNkTAiLdU7F1dcTVCaBT3HMta1Jbka5eBwKta1NhcMJLdyZGeAoClONgIvo8UDOTSlN(YPJncMta1Jbka5CDKtLYXdiuMftPWyogp0(aLxiX7F1cKibx4nOAvhH5zFssFcpGeCF0RfM4nNNKixKdtDjbVbvR6OcV)vpi0(e9j8akLcJ5y8q7duEHeV)vlqIeCH3GQvDeMN9jj9j8asW9rVwyI3CEsICLdm1LecN713xcT8nUvHKaSrui(EGYtPWyogp0(aLxiX7F1cKibx4nOAvhH5zFssFcpGeCF0RfM4nNNKixKdj4nOAvhvO)lwqYCIgIE2Xjbk5mSWuxsiCUxFFj0c9FXcsMt0q0ZooLsz8q7duEHeV)vlqIeCTCeyJdTvKsz8q7duEHeV)vlqIeC5bKqd6J5zFscO9oH(CAqqm1LePH3GQvDuH3)QheAFI(eEaTxAeo3RVVeAbfsg6sHKapbaKBV0cZrxuwkKaHbdcMsz8q7duEHeV)vlqIeC5bKqd6J5zFscyZqBzeQOHvrVerd)0fPugp0(aLxiX7F1cKibxFfcBOq)2dLsz8q7duEHeV)vlqIeC9IfSRodeyQljs7fs4lVyb7QZarkvkfgXyomVYtCFqO5q4jiw5e6NYj2OCmE0WCuqogEtDw1rLukJhAFaj82FbbbVKZHPUKinO)OvdFOcQc46RtpdILG3)VDOPuyeJ5Wus2Q9hAosFc0o8uokihq)PytVNCInlYHBhgICQuo)gLCeAjLcJymhJhAFaKibxhjB1(dvajq7Wty6bKq2M6ib3aHEps2btDjbzv)Av49V6bH2xX)In2v)Ava(tWGEpar1raGEpcizOyvGKXdKUV6xRYrYwT)qfqc0o8ubTLDPuyeJ5WKnkhE)REqO9jc9R3togp0(YXPGihaFJq9ocKJSn6Yb39V6bH2xoYuNlNkLJhqO5yhAoGOHeiNyJYbsaVlYrVCWBq1QoQe6Nerl49V6bH2xjLcJymhJhAFaKibxCZ5egp0(eofeyE2NKW7F1dcTprOF9EsPWyo4SguTQJYj2Sihce63ccKJSnk2iyoi20vO3to7AlJG5itDUCQuoEaHMtLwnKYb39V6bH2xokihizOyvsPWigZX4H2hajsWfEdQw1ryE2NKa20vO3J4TLrqrLwnKe8(x9Gq7dZ(vcGcmXBopjbzgpu8KGo6ReGr4nOAvhv49V6bH2NaSPRqVhXBlJGyJTXdfpjOJ(kbyeEdQw1rfE)REqO9jwo7tGaQmqyJnEdQw1rLq)KiAbV)vpi0(2fJhAFfWMUc9EeVTmcwwENtajupp0(ymVBhAl7kGnDf69iEBzeSG6HwO9H094nOAvhvc9tIOf8(x9Gq7Bx4D7qBzxbSPRqVhXBlJGfi9n9am24H2xbSPRqVhXBlJGLL35eqc1ZdTV9iJ3TdTLDfO)irVeVTmcwG030dSl8UDOTSRa20vO3J4TLrWcK(MEaglhyJT0cZrxuG(Je9s82YiistPmEO9bqIeCb20vO3J4TLrqm1LKQFTk8(x9Gq7RG2YU9gp0(klfsIQZarHVzWhcWij7SxAiR6xRIElcEMtWna3qPI)DF1VwLToeGasgdfiz8aP7XBq1QoQa20vO3J4TLrqrLwnKe8(x9Gq7lLcJ5GWWt5i9nu1UiheVgKHCwnmhC3)QheAFyMt1h50XgbLPakhpGYrJC6lhE3o0w2vsPmEO9bqIeCbnu1UqaEnidyQljv)Av49V6bH2xbTLD7rgEdQw1rLq)KiAbV)vpi0(ymVBhAl72f5aPPuymhMpzXwTHhLdyR9o0CmNmdlqovkhpGqZrMgB5G7(x9Gq7RKdZJgB5W8jl2WaihMXIT(JzoAKdyR9o0CQuoEaHMdzqhw5a6CInlYH5twSvB4r5itDUC2m8uo)gs5acJZaihupuVNCWD)REqO9vsPmEO9bqIeCHswSvB4ryQljv)Av49V6bH2xbTLD7R(1Qa9hj6L4TLrWcAl72J3GQvDuj0pjIwW7F1dcTpgH3GQvDuH3)QheAFIxiXnqic9tiHKN4(GeH(jKGSQFTkOKfB1gEub1dTq7BxQ(1QW7F1dcTVcQhAH2hsr(q)rRg(qfuYInGyzXw)tPWyo7EaLJ0LcHneKtVYHjn8txKJmn2Yb39V6bH2xjLY4H2hajsW1xHWgce9sen8txGPUKG3GQvDuj0pjIwW7F1dcTpgH3GQvDuH3)QheAFIxiXnqic9tiHKN4(GeH(P9v)Av49V6bH2xbTLDPuymhMTd054buosxke2qqo9khM0WpDro6LtLczeD5G7(x9Gq7dKJbYX13togihC3)QheAF5itDUCUoYzZWt5eDovkhuYzyrO5898TCwnmhnkPugp0(aircU(ke2qGOxIOHF6cm1Le8guTQJkH(jr0cE)REqO9XyE3o0w2Tl4eKd5d9hTA4dva6T8obk50NTiLcJ5WmnmhCw6InSGyMJhq5y5WmkKYbhode5W3m4dLdQhQ3tosxke2qqo9khM0WpDroCde5eDog(wrZHBVV69KdFZGpeOKsz8q7dGej4APqsuDgiW0diHSn1rcUbc9EKSdM6sIXdTVYxHWgce9sen8txui5jUp07z)Y7CciX3m4djc9t7IXdTVYxHWgce9sen8txui5jUpibK(MEagjD2lTToeGasgdcWl5CaHEILtF2I9sR6xRYwhcqajJHI)nLY4H2hajsWLhqcnOpM0Ar8qC2NK84mu1Igcevd9HWuxsWBq1QoQe6Nerl49V6bH2hJ5D7qBz3UihPugp0(aircU8asOb9X8SpjH(VybjZjAi6zhNWuxsWBq1QoQe6Nerl49V6bH2hJKG3GQvDuH(VybjZjAi6zhNeOKZWApEdQw1rLq)KiAbV)vpi0(ymEdQw1rf6)IfKmNOHONDCsGsodRDrosPmEO9bqIeC5bKqd6J5zFscyZqBzeQOHvrVerd)0fyQljidVbvR6OsOFseTG3)QheAFmscEdQw1rfE)REqO9jEHe3aHi0pHe5In2l9zleq6B6byeEdQw1rLq)KiAbV)vpi0(q6(QFTk8(x9Gq7RG2YUukJhAFaKibxEaj0G(yE2NK8a1VG4o9fqyQlj4nOAvhvc9tIOf8(x9Gq7JrsqEWg7L(Sfci9n9amcVbvR6OsOFseTG3)QheAFPugp0(aircU8asOb9X8Spj53950q8cvWhtDjbVbvR6OsOFseTG3)QheAFmsICGn2l9zleq6B6byeEdQw1rLq)KiAbV)vpi0(sPmEO9bqIeC5bKqd6J5zFsYJdR3nrVegaOF1zH2hM6scYQ(1QW7F1dcTVcAl72J3GQvDuj0pjIwW7F1dcTpglbVbvR6OsFcpGeCF0Rf2yJ3GQvDuPpHhqcUp61scYH0ukJhAFaKibxEaj0G(yE2NK8nUvHKaSrui(EGYXuxsWBq1QoQe6Nerl49V6bH2hJKihPuymhP3khpqVNCSCabbBfnN(2fpGYrd6JzoMtMHfihpGYH5djdDPqkhCwcaixoTpakkLtVYb39V6bH2xjhC6yJGYuaHzoVqTHAOmlq54b69KdZhsg6sHuo4SeaqUCKPXwo4U)vpi0(YPphw5ORCKE3IGN5Yb3gGBOuokih6SQJqZXo0CSC8a7HYrwFyiYPs54AqKtJNG5eBuoOEOfAF50RCInkNL(SfLCyYMcYXqrb5y5a(MZLdEZ5PCIoNyJYH3TdTLD50RCy(qYqxkKYbNLaaYLJSn6YbT17jNytb5Wnh37Sq7lNkXnpGYrJCuqo(dsMdekpNOZXaa)NYj2SihnYrM6C5uPC8acnNxcUiE4WkN(YH3TdTLDLukJhAFaKibxEaj0G(yE2NKGcjdDPqsGNaaYHPUKGSQFTk8(x9Gq7RG2YU94nOAvhvc9tIOf8(x9Gq7JXsWBq1QoQ0NWdib3h9AHn24nOAvhv6t4bKG7JETKGCiDpYQ(1QO3IGN5eCdWnuQacJZGKQFTk6Ti4zob3aCdLkFtEbimodyJT049H61OO3IGN5eCdWnucBSXBq1QoQW7F1dcTprFcpGWgB8guTQJkH(jr0cE)REqO9Xy9cc(2oliuXsF2cbK(MEaPBPBKX72H2YoKSdYHuKMsHrmMdtjz5GO9UCKEpNgemh6ciwyMdKCkbYPVCaBgKqZrd6NdUz(5O3QHFl0(Yj2SihfKZ1royrroa)7BddcTKtosF61zCcKtSr58cj8A7b540JYr2gD5S8hp0(mxjLY4H2hajsWLhqcnOpMN9jjG27e6ZPbbXuxsqgEdQw1rLq)KiAbV)vpi0(ySeCcYH8rgEdQw1rL(eEaj4(OxlgJCifBSrM0cOEmqrzNIckG27e6ZPbb3hq9yGIYofpWQoAFa1Jbkk7u4D7qBzxbsFtpa2ylTaQhduuKBrbfq7Dc950GG7dOEmqrrUfpWQoAFa1JbkkYTW72H2YUcK(MEaKI09itAeo3RVVeAbfsg6sHKapbaKdBS5D7qBzxbfsg6sHKapbaKRaPVPhGXYbstPWyombQppemheT3LJ0750GG5qg0HvoY0ylhP3Ti4zUCWTb4gkLtdZr2gD5OroYmqoVqIBGOKsz8q7dGej4IBhNCIQFTW8Spjb0ENqFon0(WuxsKgVpuVgf9we8mNGBaUHs7d9tmsoWg7QFTk6Ti4zob3aCdLkGW4miP6xRIElcEMtWna3qPY3KxacJZqkfgZr6f0hKtSzroODoxh5uPJwAKdU7F1dcTVCaBT3HMdZspiYPs54beAoTpakkLtVYb39V6bH2xowKdO)uoVTErjLY4H2hajsWLhqcnOpMN9jj6b4qFyvhjW5E7c)xGs4voHPUKq4CV((sOLhNHQw0qGOAOp0EKv9RvH3)QheAFf0w2ThVbvR6OsOFseTG3)QheAFmwcEdQw1rL(eEaj4(OxlSXgVbvR6OsFcpGeCF0RLeKdPPugp0(aircU8asOb9X8Spjz5Spj6LOAr4im1LecN713xcT84mu1Igcevd9H2JSQFTk8(x9Gq7RG2YU94nOAvhvc9tIOf8(x9Gq7JXsWBq1QoQ0NWdib3h9AHn24nOAvhv6t4bKG7JETKGCinLY4H2hajsWLhqcnOpMN9jjYmgOJGaXc2hkM6scHZ967lHwECgQArdbIQH(q7rw1VwfE)REqO9vqBz3E8guTQJkH(jr0cE)REqO9Xyj4nOAvhv6t4bKG7JETWgB8guTQJk9j8asW9rVwsqoKMsz8q7dGej4YdiHg0hZZ(Ke9ab0ZJgceOkE9irLCom1LecN713xcT84mu1Igcevd9H2JSQFTk8(x9Gq7RG2YU94nOAvhvc9tIOf8(x9Gq7JXsWBq1QoQ0NWdib3h9AHn24nOAvhv6t4bKG7JETKGCinLY4H2hajsWLhqcnOpMN9jja)vDDJkSpfBybcm1LecN713xcT84mu1Igcevd9H2JSQFTk8(x9Gq7RG2YU94nOAvhvc9tIOf8(x9Gq7JXsWBq1QoQ0NWdib3h9AHn24nOAvhv6t4bKG7JETKGCinLY4H2hajsWLhqcnOpMN9jjaUbbIEjwqli4zobiG6IWuxsQ(1Qa4gei6LybTGGN5eGaQlsiDkOTSlLY4H2hajsWLhqcnOpatDjP6xRcV)vpi0(kOTSBpEdQw1rLq)KiAbV)vpi0(ySe8guTQJk9j8asW9rVwyJnEdQw1rL(eEaj4(OxljixkfgZz3dOCygydICyAJ3Yj6CcO(8qWC2DHkWHvospUYDujLY4H2hajsW1c2GqCnEdtDjb6pA1WhQ8avGdlHYvUJ2x9RvH3)QheAFf0w2Thz4nOAvhvc9tIOf8(x9Gq7JX8UDOTSdBSXBq1QoQe6Nerl49V6bH2hJWBq1QoQW7F1dcTpXlK4gieH(jKqYtCFqIq)estPWyo7UuKtSr5W8vaxFD6zqSYb39)BhAov)ALJ)fZC8NJaGC49V6bH2xokihq3xjLY4H2hajsWfV9xqqWl5CyQljq)rRg(qfufW1xNEgelbV)F7q3Z72H2YUs1VwcufW1xNEgelbV)F7qlqYqXAF1VwfufW1xNEgelbV)F7qfgKBhvqBz3EPv9RvbvbC91PNbXsW7)3o0I)DpYWBq1QoQe6Nerl49V6bH2hsmEO9vwWge12ffUbcrOFIX8UDOTSRu9RLavbC91PNbXsW7)3o0cQhAH2h2yJ3GQvDuj0pjIwW7F1dcTpgjhinLY4H2hajsWLb52rcs(xxd0(WuxsG(Jwn8HkOkGRVo9miwcE))2HUN3TdTLDLQFTeOkGRVo9miwcE))2HwGKHI1(QFTkOkGRVo9miwcE))2Hkmi3oQG2YU9sR6xRcQc46RtpdILG3)VDOf)7EKH3GQvDuj0pjIwW7F1dcTpKqYtCFqIq)esmEO9vwWge12ffUbcrOFIX8UDOTSRu9RLavbC91PNbXsW7)3o0cQhAH2h2yJ3GQvDuj0pjIwW7F1dcTpgjh7Lwyo6Ic0FKOxI3wgbrAkLXdTpasKGRfSbrTDbM6sc0F0QHpubvbC91PNbXsW7)3o098UDOTSRu9RLavbC91PNbXsW7)3o0cK(MEagXnqic9t7R(1QGQaU(60ZGyj49)BhQybBquqBz3EPv9RvbvbC91PNbXsW7)3o0I)DpYWBq1QoQe6Nerl49V6bH2hs4gieH(jgZ72H2YUs1VwcufW1xNEgelbV)F7qlOEOfAFyJnEdQw1rLq)KiAbV)vpi0(yKCG0ukJhAFaKibxlydcX14nm1LeO)OvdFOcQc46RtpdILG3)VDO75D7qBzxP6xlbQc46RtpdILG3)VDOfizOyTV6xRcQc46RtpdILG3)VDOIfSbrbTLD7Lw1VwfufW1xNEgelbV)F7ql(39idVbvR6OsOFseTG3)QheAFmM3TdTLDLQFTeOkGRVo9miwcE))2Hwq9ql0(WgB8guTQJkH(jr0cE)REqO9Xi5aPPuymNDTBxogiNVDyLdZOqkhC4mqaYXa582aGwDuoRgMdU7F1dcTVsoi81aA8iN2h50RCInkNf04H2N5YH3)3(OlYPx5eBuoN)xjyo9khMrHuo4WzGaKtSzroYuNlNZcp0CoSYbs8nd(q5G6H69KtSr5G7(x9Gq7lN3ndq5ujU5buoVD707jh7Wk207jNxde5eBwKJm15Y56iNhODro2LdjFaTCygfs5GdNbICq9q9EYb39V6bH2xjLY4H2hajsWfEdQw1ry6bKOxlXdhvYoy6bKq2M6ib3aHEps2bZZ(KKLcjr1zGq82TtVhmXBopjbVbvR6OcjFqhkHk49V6bH2NasFtpaJWBq1QoQe6Nerl49V6bH23EJhAFLLcjr1zGOW3m4dbelOXdTpZHeKH3GQvDuj0pjIwW7F1dcTpKy8q7Ra20vO3J4TLrWYY7CciH65H2hYhVbvR6OcytxHEpI3wgbfvA1qsW7F1dcTpKGmuQ6xRYxHWgce9sen8txu(M8cqyCg2LDqkYhVbvR6OYVdbK4Bg8He2V9xG85nE6Slk4Pl2WcI8rgVBhAl7kFfcBiq0lr0WpDrbsFtpaJKG3GQvDuj0pjIwW7F1dcTpKIuPBE3o0w2vwkKevNbIcQhAH23USdJ4D7qBzxzPqsuDgikFtEbFZGpeaj4nOAvhvA8e8TBNyPqsuDgias38UDOTSRSuijQodefup0cTVDbzv)Av49V6bH2xb1dTq7t6M3TdTLDLLcjr1zGOG6HwO9HuPBP7D2J3GQvDuj0pjIwW7F1dcTpgT0NTqaPVPhiLY4H2hajsWf3CoHXdTpHtbbMN9jj8(x9Gq7t8UzactDjbVbvR6OsOFseTG3)QheAFmscYHn2v)Av49V6bH2xX)In24nOAvhvc9tIOf8(x9Gq7Jr4nOAvhv49V6bH2N4fsCdeIq)0EE3o0w2v49V6bH2xbsFtpaJWBq1QoQW7F1dcTpXlK4gieH(PukJhAFaKibxq)rIEjEBzeetDjP6xRcV)vpi0(kOTSBF1VwfO)irVeVTmcwqBz3EPv9RvzPqcen8xGKXJ9idVbvR6OsOFseTG3)QheAFmws1VwfO)irVeVTmcwq9ql0(2J3GQvDuj0pjIwW7F1dcTpgB8q7RSuijQodeLL35eqIVzWhse6NWgB8guTQJkH(jr0cE)REqO9X4L(Sfci9n9aiDpYKg0F0QHpub4pbd69aevhba69Gn2gpu8KGo6ReGXsWBq1QoQSzqub3aHy5SpbcOYaHn2v)Ava(tWGEpar1raGEpcizOyv8VyJD1VwfG)emO3dquDeaO3tbsgpySKQFTka)jyqVhGO6iaqVNY3KxacJZWUSd2yV0NTqaPVPhGrv)AvG(Je9s82Yiyb1dTq7dPPuymhMnkZspiYj2OCWBq1QokNyZIC49fW2bYHzuiLdoCgiYXdShkNOZby4PCygfs5GdNbcqoY2uhLdcYG69KdtApFlhfKJXdfpLJmn2YbH)YHzvVhmaYbhoca07PKsz8q7dGej4cVbvR6im9as0RL4HJkzhm9asiBtDKGBGqVhj7G5zFsYsHKO6mqiE72P3dM4nNNKaidQ3JiApFRy8qXt7nEO9vwkKevNbIYY7CciX3m4djc9tmgNG8F4OLVjpM6sI0WBq1QoQSuijQodeI3UD69Sh6pA1WhQa8NGb9EaIQJaa9EsPWyo4SguTQJYj2SihEFbSDGC21TMov(CygN9jqoEG9q5eDo0b8qkhna5W3m4dbYXGuoVD7i0CwnmhC3)QheAFLCWPphw54buo76wtNkFomJZ(eiN2hafLYPx5G7(x9Gq7lhzB0LZY7C5W3m4dbYHBxovkNUgMEeAoOEOEp5eBuohjFKdU7F1dcTVskfgXyogp0(aircUWBq1QocZZ(KK3TMovEXB3o9EWuxsmEO4jbD0xjaJWBq1QoQW7F1dcTpXYzFceqLbct8MZtsWBq1QoQe6Nerl49V6bH2hsQ(1QW7F1dcTVcQhAH23UihmY4H2x5DRPtLxSC2NaLL35eqIVzWhse6NqcVBhAl7kVBnDQ8ILZ(eOG6HwO9Tlgp0(kGnDf69iEBzeSS8oNasOEEO9H8XBq1QoQa20vO3J4TLrqrLwnKe8(x9Gq7BpEdQw1rLq)KiAbV)vpi0(y0sF2cbK(MEaSXg6pA1WhQa8NGb9EaIQJaa9EWg7q)eJKJukmMdZZgD54b69KdZ4SpbcOYaLJE5G7(x9Gq7dZCagEkhdKZ3oSYHVzWhcKJbY5TbaT6OCwnmhC3)QheAF5itJT2h5WT3x9EkPuyeJ5y8q7dGej4cVbvR6imp7tsE3A6u5fVD707btDjX4HINe0rFLamwcEdQw1rfE)REqO9jwo7tGaQmqyI3CEscEdQw1rLq)KiAbV)vpi0(yKXdTVY7wtNkVy5SpbklVZjGeFZGpKi0pTlgp0(kGnDf69iEBzeSS8oNasOEEO9H8XBq1QoQa20vO3J4TLrqrLwnKe8(x9Gq7BpEdQw1rLq)KiAbV)vpi0(y0sF2cbK(MEaSXg6pA1WhQa8NGb9EaIQJaa9EWg7q)eJKJukJhAFaKibxCZ5egp0(eofeyE2NKa7xX7Mbimbbu5HKDWuxsQ(1Qa9hj6L4TLrWI)DF1VwfE)REqO9vqBz3E8guTQJkH(jr0cE)REqO9XyKlLcJ5WSrzw6broXgLdEdQw1r5eBwKdVVa2oqomJcPCWHZaroEG9q5eDo0b8qkhna5W3m4dbYXGuoMd0582TJqZz1WCK((JYPx5SRTmcwsPmEO9bqIeCH3GQvDeMEaj61s8WrLSdMEajKTPosWnqO3JKDW8SpjzPqsuDgieVD707bt8MZtsqM0G(Jwn8Hka)jyqVhGO6iaqVhSXU6xRcWFcg07biQoca07PacJZaJR(1Qa8NGb9EaIQJaa9EkFtEbimod7YoiDpVBhAl7kq)rIEjEBzeSaPVPhGrgp0(klfsIQZarz5DobK4Bg8HeH(PDX4H2xbSPRqVhXBlJGLL35eqc1ZdTpKpYWBq1QoQa20vO3J4TLrqrLwnKe8(x9Gq7BpVBhAl7kGnDf69iEBzeSaPVPhGr8UDOTSRa9hj6L4TLrWcK(MEaKUN3TdTLDfO)irVeVTmcwG030dWOL(Sfci9n9ayQljsdVbvR6OYsHKO6mqiE72P3Z(WC0ffO)irVeVTmcUV6xRc0FKOxI3wgblOTSlLcJ5W8SrxoiVgeLBGqVNCygN9jqavgimZHzuiLdoCgia5a2AVdnNkLJhqO5eDop0rqlOCqE7ihebKmga5yhAorNdjFqhAo4WzGGG5iDzGGGLukJhAFaKibxlfsIQZabMEaj61s8WrLSdMEajKTPosWnqO3JKDWuxsKgEdQw1rLLcjr1zGq82TtVN94nOAvhvc9tIOf8(x9Gq7JXi3EJhkEsqh9vcWyj4nOAvhv2miQGBGqSC2NabuzG2lTLcjqyWGGfJhkEAV0Q(1QS1HaeqYyO4F3JSQFTkBKf69i8Vf)7EJhAFLLZ(eiGkduHKN4(Geq6B6byeYvKdSXMVzWhciwqJhAFMJXsKlstPWyomFpuVNCygfsGWGbbXmhMrHuo4WzGaKJbPC8acnhG(vNbDyLt05G6H69KdU7F1dcTVso7U0rqZ5WcZCIncRCmiLJhqO5eDop0rqlOCqE7ihebKmga5iBJUC4qna5itDUCUoYPs5iZabHMJDO5itJTCWHZabbZr6YabbXmNyJWkhWw7DO5uPCaVqYqZP9rorNZ30lm9Yj2OCWHZabbZr6YabbZP6xRskLXdTpasKGRLcjr1zGatpGe9AjE4Os2btpGeY2uhj4gi07rYoyQljlfsGWGbblgpu80E8guTQJkH(jr0cE)REqO9XyKBV0WBq1QoQSuijQodeI3UD69ShzsZ4H2xzPqQAoxHKN4(qVN9sZ4H2x5flyxDgik6jwo9zl2x9RvzJSqVhH)TajJhyJTXdTVYsHu1CUcjpX9HEp7Lw1VwLToeGasgdfiz8aBSnEO9vEXc2vNbIIEILtF2I9v)Av2il07r4FlqY4XEPv9RvzRdbiGKXqbsgpqAkfgZHzJVv0C427REp5WmkKYbhode5W3m4dbYr2M6OC4B2DKtVNCqSPRqVNC21wgbtPmEO9bqIeCTuijQodey6bKq2M6ib3aHEps2btDjX4H2xbSPRqVhXBlJGfsEI7d9E2V8oNas8nd(qIq)eJmEO9vaB6k07r82YiyjuodciH65H2xkLXdTpasKGlU5CcJhAFcNccmp7tsaHDOgeva7WcTpm1Le8guTQJkH(jr0cE)REqO9XyKBF1VwfO)irVeVTmcwqBz3(QFTk8(x9Gq7RG2YUukJhAFaKibxaEd5BPuPugp0(afJhkEseMJUaiXP417ru7FftDjX4HINe0rFLamEN9v)Av49V6bH2xbTLD7rgEdQw1rLq)KiAbV)vpi0(ymVBhAl7kofVEpIA)Rfup0cTpSXgVbvR6OsOFseTG3)QheAFmscYH0ukJhAFGIXdfpjcZrxaqIeC9PGAiM6scEdQw1rLq)KiAbV)vpi0(yKeKdBSR(1QW7F1dcTVcK(MEaghqdp5eH(jSXgz8UDOTSR8PGAyb1dTq7Jr4nOAvhvc9tIOf8(x9Gq7BV0cZrxuG(Je9s82YiisXg7WC0ffO)irVeVTmcUV6xRc0FKOxI3wgbl(394nOAvhvc9tIOf8(x9Gq7JXgp0(kFkOgw4D7qBzh2yV0NTqaPVPhGr4nOAvhvc9tIOf8(x9Gq7lLY4H2hOy8qXtIWC0faKibxOq7PpGOcjl2WuxscZrxumhjpiGgGzbdiwEiw7rw1VwfE)REqO9vqBz3EPv9RvzRdbiGKXqX)I0uQukJhAFGcV)vpi0(e8UDOTSdi5TdTVukJhAFGcV)vpi0(e8UDOTSdGej4Q66gvS8qSsPmEO9bk8(x9Gq7tW72H2YoasKGRkbbeKb9EWuxsQ(1QW7F1dcTVI)nLY4H2hOW7F1dcTpbVBhAl7aircUwkKQUUrtPmEO9bk8(x9Gq7tW72H2YoasKGl74eiGMtWnNlLY4H2hOW7F1dcTpbVBhAl7aircUc9tczg8ftDjb6pA1WhQe0)THMtiZGV7R(1QqYVzEqO9v8VPugp0(afE)REqO9j4D7qBzhajsWLhqcnOpMN9jjaUbbIEjwqli4zobiG6IWuxsQ(1Qa4gei6LybTGGN5eGaQlsiDk(3ukJhAFGcV)vpi0(e8UDOTSdGej4YdiHg0htATiEio7tsECgQArdbIQH(qPugp0(afE)REqO9j4D7qBzhajsWLhqcnOpMN9jj6b4qFyvhjW5E7c)xGs4voLsz8q7du49V6bH2NG3TdTLDaKibxEaj0G(yE2NKSC2Ne9suTiCukLXdTpqH3)QheAFcE3o0w2bqIeC5bKqd6J5zFsImJb6iiqSG9HMsz8q7du49V6bH2NG3TdTLDaKibxEaj0G(yE2NKOhiGEE0qGavXRhjQKZLsz8q7du49V6bH2NG3TdTLDaKibxEaj0G(yE2NKa8x11nQW(uSHfisPmEO9bk8(x9Gq7tW72H2YoasKGlpGeAqFqkvkfgZH5fe63ckNTwwoU(EYb39V6bH2xoYuNlhNbICIn7yaKt05GWF5WSQ3dga5Gdhba69Kt05Gsbb)6r5S1YYHzuiLdoCgia5a2AVdnNkLJhqOLukJhAFGcV)vpi0(eVBgGqIeCH3GQvDeMEaj61s8WrLSdMEajKTPosWnqO3JKDW8SpjHKpOdLqf8(x9Gq7taPVPhat8MZtsQ(1QW7F1dcTVcK(MEaKu9RvH3)QheAFfup0cTpKpY4D7qBzxH3)QheAFfi9n9amQ6xRcV)vpi0(kq6B6bqAkfgZHzJIcYj2OCq9ql0(YPx5eBuoi8xomR69Gbqo4WraGEp5G7(x9Gq7lNOZj2OCOdnNELtSr5W9qiDro4U)vpi0(Yrx5eBuoCde5iR9o0CaHbJCq9q9EYj2uqo4U)vpi0(kPugp0(afE)REqO9jE3maHej4cVbvR6im9as0RL4HJkzhm9asiBtDKGBGqVhj7G5zFscjFqhkHk49V6bH2NasFtpaM9Redfft8MZtsWBq1QoQayOkq9ql0(WuxsG(Jwn8Hka)jyqVhGO6iaqVN9iR6xRcWFcg07biQoca07rajdfRI)fBSXBq1QoQqYh0HsOcE)REqO9jG030dW4hoAbsFtpas2Pihi)hoA5BYJ8rw1VwfG)emO3dquDeaO3t5BYlaHXzyxQ(1Qa8NGb9EaIQJaa9EkGW4mGuKMsHXCWPJncMdVBhAl7a5eBwKdyR9o0CQuoEaHMJmn2Yb39V6bH2xoGT27qZPphw5uPC8acnhzASLJD5y8WBUCWD)REqO9Ld3aro2HMZ1roY0ylhlhe(lhMv9EWaihC4iaqVNCEHnVKsz8q7du49V6bH2N4DZaesKGlU5CcJhAFcNccmp7ts49V6bH2NG3TdTLDambbu5HKDWuxsWBq1QoQqYh0HsOcE)REqO9jG030dWy8guTQJkagQcup0cTVukJhAFGcV)vpi0(eVBgGqIeCXnNty8q7t4uqG5zFsIXdfpjcZrxasPWyosVvoi8xomR69Gbqo4WraGEp5acJZaihds5SPpByMd3oo5Yj2OFovA1qkhC3)QheAF5a6CInlYj2OCq4VCyw17bdGCWHJaa9EY5f28C42LtLYbylYHvoOKZWIqZXFH6YXwbbZb39V6bH2xoY0yR9roqfWqo9khs(xfAH2xjLY4H2hOW7F1dcTpX7MbiKibxC74Ktu9RfMN9jja)jyqVhGO6iaqVhm1LePbOqu7ZdkHsq5I8iKoV89v)Av49V6bH2xbTLD7R(1Qa8NGb9EaIQJaa9EkGW4mWy5UpmhDrb6ps0lXBlJG75D7qBzxb6ps0lXBlJGfi9n9amsUixkfgZr6TYb39V6bH2xokih0w2HzoVqIBGihq)PytVNCQ0QHuogpu8wO3toAusPmEO9bk8(x9Gq7t8UzacjsW1YzFceqLbctDjP6xRcV)vpi0(kOTSBpVBhAl7k8(x9Gq7RaPVPhGrCdeIq)0EJhkEsqh9vcWyj4nOAvhv49V6bH2Ny5SpbcOYaLsz8q7du49V6bH2N4DZaesKGRxSGD1zGatDjP6xRcV)vpi0(kOTSBF1VwfG)emO3dquDeaO3Jasgkwf)7(QFTka)jyqVhGO6iaqVhbKmuSkq6B6bym3aHi0pLsz8q7du49V6bH2N4DZaesKGRxSGD1zGatDjP6xRcV)vpi0(kOTSBF1VwLxSGn3zGFbsgp2x9Rv5flyZDg4xG030dWyUbcrOFkLY4H2hOW7F1dcTpX7MbiKibxlfsvZ5WuxsQ(1QW7F1dcTVcAl72Z72H2YUcV)vpi0(kq6B6bye3aHi0pTxA8(q9Auwo7tcJZHuO9Lsz8q7du49V6bH2N4DZaesKGlaVH8nm1LKQFTk8(x9Gq7RG2YU98UDOTSRW7F1dcTVcK(MEagXnqic9tPuymhC3)QheAF5a2AVdnNkLJhqO5iBJUCInkNxiXnqKJcYXC)ge5S0tbBeAjLY4H2hOW7F1dcTpX7MbiKibx8(x9Gq7dtpGe9AjE4Os2btpGeY2uhj4gi07rYoyQljBDiabKmgeGxY5ac9elN(SfsqU9v)Av49V6bH2xbTLD7XBq1QoQe6Nerl49V6bH2hJKGC7rM0G(Jwn8HkOkGRVo9miwcE))2HIn2v)AvqvaxFD6zqSe8()TdT4FXg7QFTkOkGRVo9miwcE))2HkwWgef)7(WC0ffO)irVeVTmcUN3TdTLDLQFTeOkGRVo9miwcE))2HwGKHIfs3JmPb9hTA4dvEGkWHLq5k3ryJnkv9Rv5bQahwcLRChv8ViDpYKgVXtNDr5ioSDnefBS5D7qBzxbLSyR2WJkq6B6bWg7QFTkOKfB1gEuX)I09itA8gpD2ff80fBybXgBE3o0w2v(ke2qGOxIOHF6IcK(MEaKUhzgp0(kFkOgw0tSC6ZwS34H2x5tb1WIEILtF2cbK(MEagjbVbvR6OcV)vpi0(eCdeci9n9ayJTXdTVcG3q(wHKN4(qVN9gp0(kaEd5BfsEI7dsaPVPhGr4nOAvhv49V6bH2NGBGqaPVPhaBSnEO9vwkKQMZvi5jUp07zVXdTVYsHu1CUcjpX9bjG030dWi8guTQJk8(x9Gq7tWnqiG030dGn2gp0(kVyb7QZarHKN4(qVN9gp0(kVyb7QZarHKN4(Geq6B6byeEdQw1rfE)REqO9j4gieq6B6bWgBJhAFLLZ(eiGkduHKN4(qVN9gp0(klN9jqavgOcjpX9bjG030dWi8guTQJk8(x9Gq7tWnqiG030dG0ukmMJ03Fuo9kNDTLrWC42LtLYXdi0C0lhC3)QheAF5ORC0ihfKdAl7WmNQpYj2uqoGT27qZPphw5uPCq7JYrx5eBeKYrb58BiLdU7F1dcTVCc9t5eDov6OLg5SG9pNyZUCIncs5iR9o0CQuoly)ZXUCqWSIJCWD)REqO9LJZccwsPmEO9bk8(x9Gq7t8UzacjsWf0FKOxI3wgbXuxsQ(1Qa9hj6L4TLrWcAl72J3GQvDuHKpOdLqf8(x9Gq7taPVPhGX4nOAvhvamufOEOfAFPuymhMhn2AFKJ07we8mxo42aCdLWmhMLEqKJhq5WmkKYbhodeGCKTrxoXgHvoY6ddroF)X3YHd1aKJDO5iBJUCygfsGOH)CuqoOTSRKsz8q7du49V6bH2N4DZaesKGRLcjr1zGatpGe9AjE4Os2btpGeY2uhj4gi07rYoyQljsJ3hQxJIElcEMtWna3qP9sdVbvR6OYsHKO6mqiE72P3ZEKjnafIAFEqjuckxKhH05LJn2Ou1VwLVcHnei6LiA4NUOG2YoSXU6xRcWFcg07biQoca07rajdfRcAl7WgBJhAFLxSGD1zGOqYtCFO3ds3x9RvH3)QheAFf)7EPv9RvzPqcen8xGKXJ9sR6xRYwhcqajJHcKmESFRdbiGKXGa8sohqONy50NTajv)Av2il07r4FlqY4bYhzpC0cK(MEagJCiLrYnLcJ5W8OXwosVBrWZC5GBdWnucZCygfs5GdNbIC8akhWw7DO5uPCmuun0(mNdRC49bcOPhHMdOZj2SihnYrb5CDKtLYXdi0C8NJaGCKE3IGN5Yb3gGBOuokihR2(iNOZHK)vHuonmNyJGuogKY53qkNyZUCOR9pB5WmkKYbhodeGCIohs(Go0CKE3IGN5Yb3gGBOuorNtSr5qhAo9khC3)QheAFLukmIXCmEO9bk8(x9Gq7t8UzacjsWfEdQw1ry6bKOxlXdhvYoy6bKq2M6ib3aHEps2bZZ(Kes(xIheQyPqsuDgiay2VsauGjEZ5jjgp0(klfsIQZarHVzWhciwqJhAFMdjidVbvR6OcjFqhkHk49V6bH2NasFtpWUu9RvrVfbpZj4gGBOub1dTq7dPs38UDOTSRSuijQodefup0cTpm1LeEFOEnk6Ti4zob3aCdLsPWigZX4H2hOW7F1dcTpX7MbiKibx4nOAvhHPhqIETepCuj7GPhqczBQJeCde69izhmp7tsoIqjuXsHKO6mqaWSFLaOat8MZts4K6qgEdQw1rfs(GoucvW7F1dcTpbK(MEaPBKv9RvrVfbpZj4gGBOub1dTq7BxE4OLVjpsrkM6scVpuVgf9we8mNGBaUHsPuymNDpGYbXMUc9EYzxBzemhupuVNCWD)REqO9LJSn6Yj2iiLJbPCUoYHU2)SLdZOqkhC4mqaYXWBQZQokNOZz5DoSYHKpOdnh9we8mxoCdWnukh7qZPphw5iBJUCK((JYPx5SRTmcMJcYPVC4D7qBzxjLY4H2hOW7F1dcTpX7MbiKibx4nOAvhHPhqIETepCuj7GPhqczBQJeCde69izhmp7ts8asa20vO3J4TLrqmXBopjzPqcegmiybsFtpaJWBq1QoQqYh0HsOcE)REqO9jG030dShz8(q9Au0BrWZCcUb4gkThVbvR6Ocj)lXdcvSuijQodeagH3GQvDu5icLqflfsIQZabaP7rM0cZrxuG(Je9s82Yii2yZ72H2YUc0FKOxI3wgblq6B6bymEdQw1rfs(GoucvW7F1dcTpbK(MEaKIn2gpu8KGo6ReGXsWBq1QoQW7F1dcTpbytxHEpI3wgbXuxs4nE6SlkN(SfILrPugp0(afE)REqO9jE3maHej4APqsuDgiW0dirVwIhoQKDW0diHSn1rcUbc9EKSdM6scVpuVgf9we8mNGBaUHs7LgEdQw1rLLcjr1zGq82TtVN9itAake1(8GsOeuUipcPZlhBSrPQFTkFfcBiq0lr0WpDrbTLDyJD1VwfG)emO3dquDeaO3Jasgkwf0w2Hn2gp0(kVyb7QZarHKN4(qVhKUhz4nOAvhvi5FjEqOILcjr1zGaWyj4nOAvhvoIqjuXsHKO6mqaWg7QFTk8(x9Gq7RaPVPhGrpC0Y3KhBSXBq1QoQqYh0HsOcE)REqO9jG030dWijv)Av0BrWZCcUb4gkvq9ql0(Wg7QFTk6Ti4zob3aCdLkGW4mWi5In2v)Av0BrWZCcUb4gkvG030dWOhoA5BYJn28UDOTSRa20vO3J4TLrWcKmuS2J3GQvDuXdibytxHEpI3wgbr6(QFTk8(x9Gq7R4F3JmPv9RvzPqcen8xGKXdSXU6xRIElcEMtWna3qPcK(MEagHCf5aP7Lw1VwLToeGasgdfiz8y)whcqajJbb4LCoGqpXYPpBbsQ(1QSrwO3JW)wGKXdKpYE4Ofi9n9amg5qkJKBkfgZbXlDO5G82roicizmaYb1d17jhC3)QheAF5yroB6ZwoVqTHAGvjLY4H2hOW7F1dcTpX7MbiKibxlN9jqavgim1LeKv9RvzRdbiGKXqX)U34HINe0rFLamwcEdQw1rfE)REqO9jwo7tGaQmqifBSrw1VwLLcjq0WFX)U34HINe0rFLamwcEdQw1rfE)REqO9jwo7tGaQmq7c0F0QHpuzPqcen8J0ukmMJ03qv7ICq8AqgYbS1EhAovkhpGqZrMgB5y5G82roicizmKdKmuSYj6C8akh9)ju1cYHvo2kiyoXgLd3arol9uWgbk5WKnfKJm15Y5SWdnNdRCauKJ)nhlhK3oYbrajJHCaV0f5SAyoXgLZspZLdimod50RCK(gQAxKdIxdYqjLY4H2hOW7F1dcTpX7MbiKibxqdvTleGxdYaM6ss1VwfE)REqO9v8V7LlYV6xRYwhcqajJHcKmEGKQFTkBKf69i8Vfiz8ajBDiabKmgeGxY5ac9elN(SfsKBkLXdTpqH3)QheAFI3ndqircUEXc2vNbcm1LKQFTklfsGOH)I)nLY4H2hOW7F1dcTpX7MbiKibxVyb7QZabM6ss1VwLToeGasgdf)7(QFTk8(x9Gq7R4FtPmEO9bk8(x9Gq7t8UzacjsW1lwWU6mqGPUK8cj8IhoAzNcG3q(2(QFTkBKf69i8Vf)7EJhkEsqh9vcWi8guTQJk8(x9Gq7tSC2NabuzG2x9RvH3)QheAFf)BkfgZz3d07jheB6k07jNDTLrWCq9q9EYb39V6bH2xorNdKardPCygfs5GdNbICSdnNDDRPtLphMXzFkh(MbFiqoC7YPs5uPJwkxnhM5u9roEG3CoSYPphw50xom7M5TKsz8q7du49V6bH2N4DZaesKGlWMUc9EeVTmcIPUKG3GQvDuXdibytxHEpI3wgb3x9RvH3)QheAFf)7EPz8q7RSuijQodef(MbFiWEJhAFL3TMovEXYzFcu4Bg8HamY4H2x5DRPtLxSC2NaLVjVGVzWhcKsHXCKERCSCq4VCyw17bdGCWHJaa9EY5f28CK1EhAovkhpGqXmhPV)OC6vo7AlJG5a2AVdnNkLJhqO5SuiiYrx5eBuoK8ki07jhPV)OC6vo7AlJG5itDUCi5FviLdQhQ3toXgLd3arjLY4H2hOW7F1dcTpX7MbiKibxq)rIEjEBzeetDjP6xRcWFcg07biQoca07rajdfRI)DF1VwfG)emO3dquDeaO3Jasgkwfi9n9amMKN4(GeH(jKy8q7RSC2NabuzGkCdeIq)0(QFTkq)rIEjEBzeSaPVPhGrgp0(klN9jqavgOc3aHi0pT34HINe0rFLamwcEdQw1rfE)REqO9jwo7tGaQmqPugp0(afE)REqO9jE3maHej4A5SpbcOYaHPUKu9Rvb4pbd69aevhba69iGKHIvX)UV6xRcWFcg07biQoca07rajdfRcK(MEagZnqic9t7nEO4jbD0xjaJLG3GQvDuH3)QheAFILZ(eiGkdukLXdTpqH3)QheAFI3ndqircUG(Je9s82YiiM6ss1VwfG)emO3dquDeaO3Jasgkwf)7(QFTka)jyqVhGO6iaqVhbKmuSkq6B6bymjpX9bjc9tiX4H2x5flyxDgikCdeIq)0(QFTkq)rIEjEBzeSaPVPhGrgp0(kVyb7QZarHBGqe6NsPmEO9bk8(x9Gq7t8UzacjsW1lwWU6mqGPUKu9Rvb4pbd69aevhba69iGKHIvX)UV6xRcWFcg07biQoca07rajdfRcK(MEagZnqic9tPuymNDflyZDg4NZlS5GCaBT3HMtLYXdi0C0lhC3)QheAF5yroB6ZgbZ5fQnudSYj2SlNDDRPtLphMXzFcKJDO5GG3q(wjLY4H2hOW7F1dcTpX7MbiKibxVyb7QZabM6ss1VwLxSGn3zGFbsgp2x9Rv5flyZDg4xG030dWyUbcrOFAF1VwfE)REqO9vG030dWyUbcrOFAVXdfpjOJ(kbyeEdQw1rfE)REqO9jwo7tGaQmq7rM049H61OO3IGN5eCdWnucBSR(1QO3IGN5eCdWnuQaPVPhGXK8e3hKi0pHn2v)Av2il07r4FlqY4bs26qacizmiaVKZbe6jwo9zlyKCrAkfgZz3dOC21TMov(CygN9jqo2HMdcEd5B5Oxo4U)vpi0(Yj6C2i3Bop0rqlOCqE7ihebKmga5iBJUCygfs5GdNbcqogKY56ihdVPoR6OCAyohrO5eDovkhEFacINqlPugp0(afE)REqO9jE3maHej46DRPtLxSC2NayQljv)Av49V6bH2xX)UpGgEYjc9tmQ6xRcV)vpi0(kq6B6b2x9RvzJSqVhH)TajJhizRdbiGKXGa8sohqONy50NTGrYnLY4H2hOW7F1dcTpX7MbiKibxaEd5ByQljv)Av49V6bH2xbsFtpaJ5gieH(PukmMJ0BLtSrqkhfCyiYHU2)SLtOFkhhTIC0lhC3)QheAF5SAyowo76wtNkFomJZ(eiNgMdcEd5B5eDoBAKJEafLYPx5G7(x9Gq7dZC8akhq)PytVNCihGkPugp0(afE)REqO9jE3maHej4YP417ru7FftDjP6xRcV)vpi0(kq6B6by0dhT8n53B8qXtc6OVsagVtkLXdTpqH3)QheAFI3ndqircUqH2tFarfswSHPUKu9RvH3)QheAFfi9n9am6HJw(M87R(1QW7F1dcTVI)nLkLcJymhKxY9sWCWBq1QokNyZIC49fMEGCInkhJhEZLdbc9BbHMtOFkNyZICInkNJKpYb39V6bH2xoYuNlNkLdKmuSkPuyeJ5y8q7du49V6bH2Ni0VEpsWBq1QoctpGe9AjE4Os2btpGeY2uhj4gi07rYoyE2NKW7F1dcTpbKmuSeH(jmXBopjH3TdTLDfE)REqO9vG030dG8j5FjEqOcg0d1P3JasOEEO9LsHrmMdt2OC4giYj0pLtVYj2OCaVKZLtSzroYuNlNkLZlK4giYrVOZb39V6bH2xjLcJymhJhAFGcV)vpi0(eH(17bjsWfEdQw1ry6bKOxlXdhvYoy6bKq2M6ib3aHEps2bZZ(KeE)REqO9jEHe3aHi0pHjEZ5jjiZ4H2xzPqQAoxHBGqe6Nq(sJ3hQxJYYzFsyCoKcTpKy8q7Ra4nKVv4gieH(jKW7d1Rrz5SpjmohsH2hsr(iZ4HINe0rFLamcVbvR6OcV)vpi0(elN9jqavgiKIeJhAFLLZ(eiGkduHBGqe6Nq(iZ4HINe0rFLamwcEdQw1rfE)REqO9jwo7tGaQmqiDxWBq1QoQW7F1dcTpb3aHasFtpqkfgXyogp0(afE)REqO9jc9R3dsKGl8guTQJW0dirVwIhoQKDW0diHSn1rcUbc9EKSdMN9jjH(jr0cE)REqO9HjEZ5jj4nOAvhv49V6bH2NasgkwIq)ukfgXyomFYzyLdU7F1dcTVCwnmhBfemhMrHeimyqWC8NJaGCWBq1QoQSuibcdgeuW7F1dcTVCuqoakkPuyeJ5y8q7du49V6bH2Ni0VEpircUWBq1QoctpGe9AjE4Os2btpGeY2uhj4gi07rYoyE2NKe6Nerl49V6bH2hM9RKVjpM4nNNKSuibcdgeSaPVPhatDjjmhDrzPqcegmi4EPH3GQvDuzPqcegmiOG3)QheAFPuyeJ5W8jNHvo4U)vpi0(Yz1WCK(gQAxKdIxdYqo6khnYrM6C5W7pLtVw5W72H2YUCaDFLukmIXCmEO9bk8(x9Gq7te6xVhKibx4nOAvhHPhqIETepCuj7GPhqczBQJeCde69izhmp7tsc9tIOf8(x9Gq7dZ(vY3Kht8MZts4D7qBzxbAOQDHa8Aqgkq6B6bWuxs4nE6SlkmGfuTBpVBhAl7kqdvTleGxdYqbsFtpWUSdYXi8guTQJkH(jr0cE)REqO9LsHXCy(KZWkhC3)QheAF5SAyosxke2qqo9khM0WpDrjLcJymhJhAFGcV)vpi0(eH(17bjsWfEdQw1ry6bKOxlXdhvYoy6bKq2M6ib3aHEps2bZZ(KKq)KiAbV)vpi0(WSFL8n5XeV58KeE3o0w2v(ke2qGOxIOHF6IcK(MEam1LeEJNo7IcE6InSG75D7qBzx5RqydbIEjIg(Plkq6B6b2f5khmcVbvR6OsOFseTG3)QheAFPuyeJ5W8jNHvo4U)vpi0(Yz1WCy(KfB1gEujLcJymhJhAFGcV)vpi0(eH(17bjsWfEdQw1ry6bKOxlXdhvYoy6bKq2M6ib3aHEps2bZZ(KKq)KiAbV)vpi0(WSFL8n5XeV58KeE3o0w2vqjl2Qn8OcK(MEaKGSQFTkOKfB1gEub1dTq7BxQ(1QW7F1dcTVcQhAH2hsr(q)rRg(qfuYInGyzXw)Xuxs4nE6SlkhXHTRHO75D7qBzxbLSyR2WJkq6B6b2LDqogH3GQvDuj0pjIwW7F1dcTVukmIXCy(KZWkhC3)QheAF5SAyomFYInmaYHzSyR)5acJZaihDLtSrqkhds5yrooYaroHSoNWGpuakPuyeJ5y8q7du49V6bH2Ni0VEpircUWBq1QoctpGe9AjE4Os2btpGeY2uhj4gi07rYoyE2NKe6Nerl49V6bH2hM9RKVjpM4nNNKu9RvbLSyR2WJkq6B6b2LQFTk8(x9Gq7RG6HwO9HPUKa9hTA4dvqjl2aILfB9FF1VwfuYITAdpQ4F3B8qXtc6OVsaglrUPuyeJ5W8jNHvo4U)vpi0(Yz1WCInkhM3)lwqYC5Gtdrp74uov)ALJUYj2OCEDgwemhfKJhO3toXMf5eq9yGIskfgXyogp0(afE)REqO9jc9R3dsKGl8guTQJW0dirVwIhoQKDW0diHSn1rcUbc9EKSdMN9jjH(jr0cE)REqO9Hz)k5BYJjEZ5jj4nOAvhvO)lwqYCIgIE2Xjbk5mS2fKX72H2YUc9FXcsMt0q0Zoovq9ql0(2fE3o0w2vO)lwqYCIgIE2XPcK(MEaKI8LgVBhAl7k0)flizordrp74ubsgkwyQljeo3RVVeAH(VybjZjAi6zhNsPWigZH5todRCWD)REqO9LZQH5S76mu1IgcYbhg6dHzo(ZraqoAKJS27qZPs5GsodlcnhxFpemNyZUCKlYLdG49HckPuyeJ5y8q7du49V6bH2Ni0VEpircUWBq1QoctpGe9AjE4Os2btpGeY2uhj4gi07rYoyE2NKe6Nerl49V6bH2hM9RKVjpM4nNNKW72H2YUYJZqvlAiqun0hsGtKoYHCLlYtbsFtpaM6scHZ967lHwECgQArdbIQH(q75D7qBzx5XzOQfneiQg6djWjsh5qUYf5PaPVPhyxKlYXi8guTQJkH(jr0cE)REqO9LsHrmMdZNCgw5G7(x9Gq7lh)fQlhC3)QheAF5qY)QqcKJUYrdmaYX)wsPWigZX4H2hOW7F1dcTprOF9EqIeCH3GQvDeMEaj61s8WrLSdMEajKTPosWnqO3JKDW8Spjj0pjIwW7F1dcTpm7xjFtEmXBopjP6xRcV)vpi0(kq6B6bsPWigZH5todRCWD)REqO9LJ)c1LJ0V31Ci5FvibYrx5Obga54FlPuyeJ5y8q7du49V6bH2Ni0VEpircUWBq1QoctpGe9AjE4Os2btpGeY2uhj4gi07rYoyE2NKe6Nerl49V6bH2hM9RKVjpM4nNNKu9Rvb6ps0lXBlJGfi9n9ayQljH5Olkq)rIEjEBzeCF1VwfE)REqO9vqBzxkfgXyomFYzyLdU7F1dcTVCwnmh7YHKpGwosF)r50RC21wgbZrx5eBuosF)r50RC21wgbZrw7DO5W7pLtVw5W72H2YUCSihhzGih5ihaX7dfKtLwnKYb39V6bH2xoYAVdTKsHrmMJXdTpqH3)QheAFIq)69Gej4cVbvR6im9as0RL4HJkzhm9asiBtDKGBGqVhj7G5zFssOFseTG3)QheAFy2Vs(M8yI3CEscVBhAl7kq)rIEjEBzeSaPVPhajv)AvG(Je9s82Yiyb1dTq7dtDjjmhDrb6ps0lXBlJG7R(1QW7F1dcTVcAl72Z72H2YUc0FKOxI3wgblq6B6bqICWi8guTQJkH(jr0cE)REqO9LsHrmMdZNCgw5G7(x9Gq7lhDLdZxbC91PNbXkhC3)VDO5iR9o0CUoYPs5ajdfRCwnmhnYblkkPuyeJ5y8q7du49V6bH2Ni0VEpircUWBq1QoctpGe9AjE4Os2btpGeY2uhj4gi07rYoyE2NKe6Nerl49V6bH2hM9RKVjpM4nNNKW72H2YUs1VwcufW1xNEgelbV)F7qlq6B6bWuxsG(Jwn8HkOkGRVo9miwcE))2HUV6xRcQc46RtpdILG3)VDOf0w2LsHrmMJ03u0CyEXtxaKZCy(KZWkhC3)QheAF5SAyogkAoGxt2bYPx5GtYPH58BiLJHIcYj2SihzQZLJZaroU(EiyoXMD5SJCKdG49Hck5WKncq5G3CEcKJbPddrohXjaWGQdRC63q)Mlh9YXCUC4gGaLukmIXCmEO9bk8(x9Gq7te6xVhKibx4nOAvhHPhqIETepCuj7GPhqczBQJeCde69izhmp7tsc9tIOf8(x9Gq7dZ(vY3Kht8MZtsGMIki80ffdffu0dtDjbAkQGWtxumuuqHKxbbyp0uubHNUOyOOGcV9xWyj4K9qtrfeE6IIHIckOEOfAFmEh5iLcJymhPVPO5W8INUaiN5WSDYmSa54buo4U)vpi0(YrMgB5G37ocAv1Pbw5anfnhcpDbaZCA8eeQOuo2HvoOKZWcKJtbbHMJvB8uorNZ3yGYb4HuoAKZdfGC8acnNncsLukmIXCmEO9bk8(x9Gq7te6xVhKibx4nOAvhHPhqIETepCuj7GPhqczBQJeCde69izhmp7tsc9tIOf8(x9Gq7dt8MZtsGMIki80ff8E3rqR6OIEiFPbnfvq4Plk49UJGw1rf)lM6sc0uubHNUOG37ocAvhvi5vqa2J3GQvDuH3)QheAFcizOyjc9tmcAkQGWtxuW7DhbTQJk6LsHrmMZUhq5eBuohjFKdU7F1dcTVC6lhE3o0w2LJUYrJCK1EhAoxh5uPCi5FjEqO5eDoOKZWkNyJYbW3iuVJqZPpkNgMtSr5a4BeQ3rO50hLJS27qZzZEFPlhhba5eB2LJCrUCaeVpuqovA1qkNyJYzPpBro0HckPuyeJ5y8q7du49V6bH2Ni0VEpircUWBq1QoctpGe9AjE4Os2btpGeY2uhj4gi07rYoyE2NKe6Nerl49V6bH2hM4nNNKG3GQvDuH3)QheAFcizOyjc9tyQlj4nOAvhv49V6bH2NasgkwIq)es4D7qBzxH3)QheAFfup0cTpKpY2zxqgYvWPqcYvKlYpmhDrzPqcegmiisr(H5OlkmOhQtVhKYij4nOAvhvc9tIOf8(x9Gq7dBSXBq1QoQe6Nerl49V6bH2hJx6ZwiG030dSlYf5sPsPmEO9bkW(v8UzasYYzFceqLbctDjX4HINe0rFLamwcEdQw1rLToeGasgdILZ(eiGkd0EKv9RvzRdbiGKXqX)In2v)AvwkKard)f)lstPmEO9bkW(v8UzacjsW1sHu1Com1LKQFTkOKfB1gEuX)Uh6pA1WhQGswSbell26)E8guTQJkH(jr0cE)REqO9XOQFTkOKfB1gEubsFtpWEJhkEsqh9vcWyjYnLY4H2hOa7xX7MbiKibxlN9jqavgim1LeJhkEsqh9vcWyj4nOAvhv2miQGBGqSC2NabuzG2x9Rvb4pbd69aevhba69iGKHIvX)UV6xRcWFcg07biQoca07rajdfRcK(MEagZnqic9tPugp0(afy)kE3maHej46flyxDgiWuxsQ(1Qa8NGb9EaIQJaa9EeqYqXQ4F3x9Rvb4pbd69aevhba69iGKHIvbsFtpaJ5gieH(PukJhAFGcSFfVBgGqIeC9IfSRodeyQljv)AvwkKard)f)BkLXdTpqb2VI3ndqircUEXc2vNbcm1LKQFTkBDiabKmgk(3ukmMZUhq50hLdZOqkhC4mqKdzqhw5Oxos)ExZrx5Gv7ZbTpme5Sz4PCin2iyoiVKf69KZU)nNgMdYBh5GiGKXqoyrro2HMdPXgbLZCqMH0C2m8uo)gs5eB2LtiRZXCqYqXcZCqwfP5Sz4PCy2osEqanaZcgga5WmEiw5ajdfRCIohpGWmNgMdY4inheKb17jhM0E(wokihJhkEQKdZVpme5G25eBkihzBQJYzZGO5WnqO3tomJZ(eiGkdeiNgMJSn6YbH)YHzvVhmaYbhoca07jhfKdKmuSkPugp0(afy)kE3maHej4APqsuDgiW0dirVwIhoQKDW0diHSn1rcUbc9EKSdM6sI0WBq1QoQSuijQodeI3UD69SV6xRcWFcg07biQoca07rajdfRcAl72B8qXtc6OVsagH3GQvDuzZGOcUbcXYzFceqLbAV0wkKaHbdcwmEO4P9itAv)Av2il07r4Fl(39sR6xRYwhcqajJHI)DV0EHeErVwIhoAzPqsuDgi2JmJhAFLLcjr1zGOW3m4dbySe5In2ilmhDrXCK8GaAaMfmGy5HyTN3TdTLDfuO90hquHKfBfizOyHuSXgqguVhr0E(wX4HINqkstPWyo7EaLdZOqkhC4mqKdPXgbZb1d17jhlhMrHu1CoCTRyb7QZaroCde5iBJUCqEjl07jND)BokihJhkEkNgMdQhQ3toK8e3huoY0ylheKb17jhM0E(wjLY4H2hOa7xX7MbiKibxlfsIQZabMEaj61s8WrLSdMEajKTPosWnqO3JKDWuxsKgEdQw1rLLcjr1zGq82TtVN9sBPqcegmiyX4HIN2x9Rvb4pbd69aevhba69iGKHIvbTLD7rgYqMXdTVYsHu1CUcjpX9HEp7rMXdTVYsHu1CUcjpX9bjG030dWiKRihyJT0G(Jwn8HklfsGOHFKIn2gp0(kVyb7QZarHKN4(qVN9iZ4H2x5flyxDgikK8e3hKasFtpaJqUICGn2sd6pA1WhQSuibIg(rks3x9RvzJSqVhH)TajJhifBSrgGmOEpIO98TIXdfpThzv)Av2il07r4FlqY4XEPz8q7Ra4nKVvi5jUp07bBSLw1VwLToeGasgdfiz8yV0Q(1QSrwO3JW)wGKXJ9gp0(kaEd5BfsEI7d9E2lTToeGasgdcWl5CaHEILtF2cKIuKMsz8q7duG9R4DZaesKGlU5CcJhAFcNccmp7tsmEO4jryo6cqkLXdTpqb2VI3ndqircUEXc2vNbcm1LKQFTkVybBUZa)cKmESNBGqe6Nyu1VwLxSGn3zGFbsFtpWEUbcrOFIrv)AvG(Je9s82YiybsFtpWEKjnO)OvdFOcWFcg07biQoca07bBSR(1Q8IfS5od8lq6B6byKXdTVYsHu1CUc3aHi0pHeUbcrOFc5x9Rv5flyZDg4xGKXdKMsz8q7duG9R4DZaesKGRxSGD1zGatDjP6xRYwhcqajJHI)DpGmOEpIO98TIXdfpT34HINe0rFLamcVbvR6OYwhcqajJbXYzFceqLbkLY4H2hOa7xX7MbiKibxVBnDQ8ILZ(eatDjrA4nOAvhvE3A6u5fVD707zpYmEO4jbAhf950GyKCXgBJhkEsqh9vcWyj4nOAvhv2miQGBGqSC2NabuzGWgBJhkEsqh9vcWyj4nOAvhv26qacizmiwo7tGaQmqinLY4H2hOa7xX7MbiKibxaEd5ByQljaYG69iI2Z3kgpu8ukLXdTpqb2VI3ndqircUqH2tFarfswSHPUKy8qXtc6OVsagl3ukJhAFGcSFfVBgGqIeCzqUDKGK)11aTpm1LeJhkEsqh9vcWyj4nOAvhvmi3osqY)6AG23(VDw5LhmwcEdQw1rfdYTJeK8VUgO9j(2z7dd(qrrMgB6TdYLsHXCyE0ylh6A)ZwoHbFOaGzoAKJcYXY5X0lNOZHBGihMXzFceqLbkhdKZsDocMJEGGm0C6vomJcPQ5CLukJhAFGcSFfVBgGqIeCTC2NabuzGWuxsmEO4jbD0xjaJLG3GQvDuzZGOcUbcXYzFceqLbkLY4H2hOa7xX7MbiKibxlfsvZ5sPsPmEO9bkGWoudIkGDyH2NKLZ(eiGkdeM6sIXdfpjOJ(kbySe8guTQJkBDiabKmgelN9jqavgO9iR6xRYwhcqajJHI)fBSR(1QSuibIg(l(xKMsz8q7duaHDOgeva7WcTpKibxlfsvZ5WuxsQ(1QGswSvB4rf)7EO)OvdFOckzXgqSSyR)7XBq1QoQe6Nerl49V6bH2hJQ(1QGswSvB4rfi9n9a7nEO4jbD0xjaJLi3ukJhAFGciSd1GOcyhwO9Hej46flyxDgiWuxsQ(1QSuibIg(l(3ukJhAFGciSd1GOcyhwO9Hej46flyxDgiWuxsQ(1QS1HaeqYyO4F3x9RvzRdbiGKXqbsFtpaJmEO9vwkKQMZvi5jUpirOFkLY4H2hOac7qniQa2HfAFircUEXc2vNbcm1LKQFTkBDiabKmgk(39i7fs4fpC0YoLLcPQ5CyJ9sHeimyqWIXdfpHn2gp0(kVyb7QZarrpXYPpBbstPWyombIvorNZdf5GGzfh58cBoih9akkLJ0V31CE3mabYPH5G7(x9Gq7lN3ndqGCKTrxoVnaOvhvsPmEO9bkGWoudIkGDyH2hsKGRLZ(eiGkdeM6sIXdfpjOJ(kbySe8guTQJkBgevWnqiwo7tGaQmq7R(1Qa8NGb9EaIQJaa9EeqYqXQ4F3JmE3o0w2vG(Je9s82YiybsFtpasmEO9vG(Je9s82YiyHKN4(GeH(jKWnqic9tmU6xRcWFcg07biQoca07rajdfRcK(MEaSXwAH5Olkq)rIEjEBzeeP7XBq1QoQe6Nerl49V6bH2hs4gieH(jgx9Rvb4pbd69aevhba69iGKHIvbsFtpqkLXdTpqbe2HAqubSdl0(qIeC9IfSRodeyQljv)Av26qacizmu8V7bKb17reTNVvmEO4PukJhAFGciSd1GOcyhwO9Hej46flyxDgiWuxsQ(1Q8IfS5od8lqY4XEUbcrOFIrv)AvEXc2CNb(fi9n9a7rM0G(Jwn8Hka)jyqVhGO6iaqVhSXU6xRYlwWM7mWVaPVPhGrgp0(klfsvZ5kCdeIq)es4gieH(jKF1VwLxSGn3zGFbsgpqAkfgZH57H69KtSr5ac7qniAoWoSq7dZC6ZHvoEaLdZOqkhC4mqaYr2gD5eBew5yqkNRJCQKEp582TJqZz1WCK(9UMtdZb39V6bH2xjNDpGYHzuiLdoCgiYH0yJG5G6H69KJLdZOqQAohU2vSGD1zGihUbICKTrxoiVKf69KZU)nhfKJXdfpLtdZb1d17jhsEI7dkhzASLdcYG69KdtApFRKsz8q7duaHDOgeva7WcTpKibxlfsIQZabMEaj61s8WrLSdMEajKTPosWnqO3JKDWuxsK2sHeimyqWIXdfpTxA4nOAvhvwkKevNbcXB3o9E2x9Rvb4pbd69aevhba69iGKHIvbTLD7rgYqMXdTVYsHu1CUcjpX9HEp7rMXdTVYsHu1CUcjpX9bjG030dWiKRihyJT0G(Jwn8HklfsGOHFKIn2gp0(kVyb7QZarHKN4(qVN9iZ4H2x5flyxDgikK8e3hKasFtpaJqUICGn2sd6pA1WhQSuibIg(rks3x9RvzJSqVhH)TajJhifBSrgGmOEpIO98TIXdfpThzv)Av2il07r4FlqY4XEPz8q7Ra4nKVvi5jUp07bBSLw1VwLToeGasgdfiz8yV0Q(1QSrwO3JW)wGKXJ9gp0(kaEd5BfsEI7d9E2lTToeGasgdcWl5CaHEILtF2cKIuKMsz8q7duaHDOgeva7WcTpKibxVyb7QZabM6ss1VwLToeGasgdf)7EJhkEsqh9vcWi8guTQJkBDiabKmgelN9jqavgOukJhAFGciSd1GOcyhwO9Hej46DRPtLxSC2NayQljsdVbvR6OY7wtNkV4TBNEp7rM0cZrxuwW(lInsyGncGn2gpu8KGo6ReGX7G09iZ4HINeODu0NtdIrYfBSnEO4jbD0xjaJLG3GQvDuzZGOcUbcXYzFceqLbcBSnEO4jbD0xjaJLG3GQvDuzRdbiGKXGy5SpbcOYaH0ukJhAFGciSd1GOcyhwO9Hej4IBoNW4H2NWPGaZZ(KeJhkEseMJUaKsz8q7duaHDOgeva7WcTpKibxOq7PpGOcjl2WuxsmEO4jbD0xjaJ3jLY4H2hOac7qniQa2HfAFircUa8gY3WuxsaKb17reTNVvmEO4PukJhAFGciSd1GOcyhwO9Hej4YGC7ibj)RRbAFyQljgpu8KGo6ReGXsWBq1QoQyqUDKGK)11aTV9F7SYlpySe8guTQJkgKBhji5FDnq7t8TZ2hg8HIImn20BhKlLcJ5W8OXwo01(NTCcd(qbaZC0ihfKJLZJPxorNd3aromJZ(eiGkduogiNL6Cemh9abzO50RCygfsvZ5kPugp0(afqyhQbrfWoSq7djsW1YzFceqLbctDjX4HINe0rFLamwcEdQw1rLndIk4gielN9jqavgOukJhAFGciSd1GOcyhwO9Hej4APqQAohlcWlXzzkofoHnydwwa]] )
end
