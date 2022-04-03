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


    spec:RegisterPack( "Fire", 20220403, [[de1i2eqiuu9iOqxIkQkBsPQpbIAuGGtbcTkOaEfiYSGsDlLkXUOQFHcAyqbDmLkwgvkEguGMgvkvxtPszBOiv(gvuQghvuvDoLkvSoQOY8qbUhvyFqv5FOiL0bPIcleQIhcvvtKkk5IurrTrOk1hvQuPrcvjCsQOkRKkYlPIImtQuYnPIszNOO8tOkrdvPsAPuPuEkinvuexvPsvBffP4ROivnwuKSxu6VegSIdtzXs6XOAYG6YiBwjFwvA0kLttA1OiL61OqZMOBRQ2Tk)wQHRkoouL0YH8CGPlCDj2ou57ujJNkvNhkz9OiLy(qr7x0S7WYewOWwqSmZnyOBCdg62XqmOFNDh3GHUD3ol0aRhIf6JXz0EjwON9jwO4TIiwOpgwY2GzzcluqxqCIf6wepaNJHm8vJTs1Z7pdb6ViTq7JJSvWqG(5mKfATOYW5DSvwOWwqSmZnyOBCdg62XqmOFNDh3GHUDmiluReBnIfku9JFwOBkmmDSvwOWeGZcfVveLJZM9sPtBr8aCogYWxn2kvpV)meO)I0cTpoYwbdb6NZW0jNXdsL5Sd254gm0nUjDkDc)B29saNlDAxYz3dOCw67wiq030dKdYIncLtSzxoHHEPWh6NerlGvkNvJYrAGyxaeVp4CSQk1aRCka7La(0PDjh3QBaD5WnqKdIWRffrF6cqoRgLd(7FTacTVCGG6jp25a3hKJC2AjCoAKZQr5y5SqeylhNnkOgLd3abe9Pt7sooZNvLuoGaP8ih(gXzuV3C6lhlNf5kNvJyeKJE5eBuooJD1TYj6CqeCHt54QrmkBd2NoTl54mGzAxarowo7kwOUknqKdDbcRCInlYbUjqoxh58BysMJlskZrVD51(uoqaO)CcceeCowKZ15a03txk3UihN1Ucnh9)y8aI(0PDjh83hocf5yszo1YA5zkpImEKdDbsjqorNtTSwEMYxEWoh7YXK)ge5OhqFpDPC7ICCw7k0CEn9YrVCa6h4tN2LC29akNndbZBycohCgsTQKa5eDoicUWPCW)UU7ZXvJyu2gSNfQubbGLjSqr9J4zZaeltyz2oSmHfkDwvsWS4HfQXdTpwOlP9jqGugjwOWeGJ0Nq7JfQZIKgw5G)(xlGq7lNvJYXztrOgbYPx5WKg9Pl8Sq5iniKASqnEO4ibD0xjqo4Zro4mKAvj536qacezmkws7tGaPms5SphiKtTSw(ToeGargJ(YtoyIzo1YA5xkIarJ((YtoqKnyzMByzclu6SQKGzXdluosdcPgl0AzT8WKfB1gDKV8KZ(CqLJwn6L8WKfBaXYIT(7PZQscoN95GZqQvLKp0pjIwW7FTacTVCyqo1YA5Hjl2Qn6ipI(MEGC2NJXdfhjOJ(kbYbFoYXnSqnEO9XcDPiQAsjBWYmmiltyHsNvLemlEyHYrAqi1yHA8qXrc6OVsGCWNJCWzi1QsYVziyb3aHyjTpbcKYiLZ(CQL1YdkNGr9EbIQKaa9EfiYGXYxEYzFo1YA5bLtWOEVarvsaGEVcezWy5r030dKd(YHBGqe6NyHA8q7Jf6sAFceiLrInyzMBNLjSqPZQscMfpSq5iniKASqRL1YdkNGr9EbIQKaa9EfiYGXYxEYzFo1YA5bLtWOEVarvsaGEVcezWy5r030dKd(YHBGqe6NyHA8q7Jf6dwOUknqWgSmB3yzclu6SQKGzXdluosdcPgl0AzT8lfrGOrFF5HfQXdTpwOpyH6Q0abBWYmMowMWcLoRkjyw8WcLJ0GqQXcTwwl)whcqGiJrF5HfQXdTpwOpyH6Q0abBWYmNDwMWcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSq5iniKASqzEo4mKAvj5xkIevPbcXt3s9EZzFo1YA5bLtWOEVarvsaGEVcezWy5HBxxo7ZX4HIJe0rFLa5WGCWzi1QsYVziyb3aHyjTpbcKYiLZ(CyEolfrGWqbH8gpuCuo7Zbc5W8CQL1YVrwO3RO84lp5SphMNtTSw(ToeGargJ(Yto7ZH558GiCIETeVCy)srKOknqKZ(CGqogp0(8lfrIQ0aHNVzOxcKd(CKJBYbtmZbc5eMKUWBsYDqGmatlgqSkiS80zvjbNZ(C4DlHBxNhgzV9bevezXMhrgmw5aXCWeZCaKH07veDHV5nEO4OCGyoqKfAbqIETeVCywMTdluJhAFSqxkIevPbcwOWeGJ0Nq7Jf6Uhq50hLdERikh8inqKdzijw5OxoUTExZrx5GvxYbUpih5Sz4OCin2iuo4fKf69MZU)jNgLdErh5anqKXyoyrro2bNdPXgHCUCGGbXC2mCuo)gr5eB2Lt4QZXKiYGXc7CGqfI5Sz4OCCgsYDqGmatlgKb5G3few5GidgRCIoNcGWoNgLde4qmhOKH07nhM0f(wokihJhkoYNJZQpih5a35eBkihxBQKYzZqW5WnqO3Bo4T0(eiqkJeiNgLJRn6YbA5YXzsVxidYbpsca07nhfKdImyS8SblZC(zzclu6SQKGzXdl0cGeU2ujj4gi07LLz7WcLJ0GqQXcL55GZqQvLKFPisuLgiepDl17nN95W8CwkIaHHcc5nEO4OC2NtTSwEq5emQ3lquLeaO3RargmwE421LZ(CGqoqihiKJXdTp)sru1Ksp5oXlHEV5SphiKJXdTp)sru1Ksp5oXlbjq030dKddYbd97woyIzomphu5OvJEj)sreiA03tNvLeCoqmhmXmhJhAF(hSqDvAGWtUt8sO3Bo7Zbc5y8q7Z)GfQRsdeEYDIxcsGOVPhihgKdg63TCWeZCyEoOYrRg9s(LIiq0OVNoRkj4CGyoqmN95ulRLFJSqVxr5XJiJh5aXCWeZCGqoaYq69kIUW38gpuCuo7Zbc5ulRLFJSqVxr5XJiJh5SphMNJXdTppG3i(MNCN4LqV3CWeZCyEo1YA536qacezm6rKXJC2NdZZPwwl)gzHEVIYJhrgpYzFogp0(8aEJ4BEYDIxc9EZzFompNToeGargJcWdjLaHEILuF3ICGyoqmhiYcTairVwIxomlZ2HfQXdTpwOlfrIQ0abluycWr6tO9XcD3dOCWBfr5GhPbICin2iuoWfKEV5y5G3kIQMuYWDfluxLgiYHBGihxB0LdEbzHEV5S7FYrb5y8qXr50OCGli9EZHCN4LGYXLgB5aLmKEV5WKUW38SblZ2Dyzclu6SQKGzXdluJhAFSq5MukmEO9jKkiyHkvqio7tSqnEO4irys6caBWYSDWqwMWcLoRkjyw8WcLJ0GqQXcTwwl)dwOMlnW3JiJh5SphUbcrOFkhgKtTSw(hSqnxAGVhrFtpqo7ZHBGqe6NYHb5ulRLhvos0lXt7IqEe9n9a5SphiKdZZbvoA1OxYdkNGr9EbIQKaa9E90zvjbNdMyMtTSw(hSqnxAGVhrFtpqomihJhAF(LIOQjLEUbcrOFkhiLd3aHi0pLdgiNAzT8pyHAU0aFpImEKdezHA8q7Jf6dwOUknqWgSmBNDyzclu6SQKGzXdluosdcPgl0AzT8BDiabImg9LNC2NdGmKEVIOl8nVXdfhLZ(CmEO4ibD0xjqomihCgsTQK8BDiabImgflP9jqGugjwOgp0(yH(GfQRsdeSblZ2XnSmHfkDwvsWS4HfkhPbHuJfkZZbNHuRkj)ZwtN6U4PBPEV5SphiKJXdfhjG7WRVNguomih3KdMyMJXdfhjOJ(kbYbFoYbNHuRkj)MHGfCdeIL0(eiqkJuoyIzogpuCKGo6Reih85ihCgsTQK8BDiabImgflP9jqGugPCGiluJhAFSqF2A6u3flP9jaBWYSDWGSmHfkDwvsWS4HfkhPbHuJfkGmKEVIOl8nVXdfhXc14H2hluaVr8n2GLz742zzclu6SQKGzXdluosdcPgluJhkosqh9vcKd(YXnSqnEO9XcfgzV9bevezXgBWYSD2nwMWcLoRkjyw8WcLJ0GqQXc14HIJe0rFLa5Gph5GZqQvLK3qC7ib5(JSbAF5SpNVDM)Hh5Gph5GZqQvLK3qC7ib5(JSbAFIVDwo7Zjm0lfExASP3oyiluJhAFSqne3osqU)iBG2hBWYSDy6yzclu6SQKGzXdluJhAFSqxs7tGaPmsSqHjahPpH2hluMEn2YHUU8ULtyOxkayNJg5OGCSCEn9Yj6C4giYbVL2NabszKYXa5SuPKq5OhiidoNELdERiQAsPNfkhPbHuJfQXdfhjOJ(kbYbFoYbNHuRkj)MHGfCdeIL0(eiqkJeBWYSDC2zzcluJhAFSqxkIQMuYcLoRkjyw8WgSbluyAzfzWYewMTdltyHsNvLemlEyHYrAqi1yHY8CqLJwn6L8WkGRps9mewcE))2b7PZQscMfQXdTpwO8UCbHapKuYgSmZnSmHfkDwvsWS4HfQXdTpwOGnDf69kEAxeIfkmb4i9j0(yHY0yi1QskNyZICiqOFliqoU2OyJq5aDtxHEV5SRTlcLJlvkZPs5uaeCovA1ikh83)AbeAF5OGCqKbJLNfkhPbHuJfATSwEE)RfqO95HBxxo7ZX4H2NFPisuLgi88nd9sGCyGJC2jN95W8CGqo1YA51BrOZKcUb4gm5lp5SpNAzT8BDiabImg9iY4roqmN95GZqQvLKhSPRqVxXt7IqIkTAej49VwaH2hBWYmmiltyHsNvLemlEyHA8q7JfkYGv7cb4XqmYcfMaCK(eAFSqHA4OCCBgSAxKd0hdXyoRgLd(7FTacTpSZPwIC6yJqUuaLtbq5Oro9LdVBjC768Sq5iniKASqRL1YZ7FTacTppC76YzFoqihCgsTQK8H(jr0cE)RfqO9Ld(YX4H2NG3TeUDD5Sl5SB5ar2GLzUDwMWcLoRkjyw8Wc14H2hluyYITAJoIfkmb4i9j0(yH6Sil2Qn6OCaBDrcNJjDzybYPs5uaeCoU0ylh83)AbeAF(Cy61ylhNfzXgKb5G3wS1FSZrJCaBDrcNtLYPai4CidjXkhqNtSzroolYITAJokhxQuMZMHJY53ikhqyCgb5axq69Md(7FTacTppluosdcPgl0AzT88(xlGq7Zd3UUC2NtTSwEu5irVepTlc5HBxxo7ZbNHuRkjFOFseTG3)AbeAF5WGCWzi1QsYZ7FTacTpXdI4gieH(PCGuoK7eVeKi0pLdKYbc5ulRLhMSyR2OJ8WfKfAF5Sl5ulRLN3)AbeAFE4cYcTVCGyoyGCqLJwn6L8WKfBaXYIT(7PZQscMnyz2UXYewO0zvjbZIhwOgp0(yH(veQrarVerJ(0fSqHjahPpH2hl0DpGYXztrOgbYPx5WKg9PlYXLgB5G)(xlGq7ZZcLJ0GqQXcfNHuRkjFOFseTG3)AbeAF5WGCWzi1QsYZ7FTacTpXdI4gieH(PCGuoK7eVeKi0pLZ(CQL1YZ7FTacTppC76ydwMX0XYewO0zvjbZIhwOgp0(yH(veQrarVerJ(0fSqHjahPpH2hluNHe05uauooBkc1iqo9khM0OpDro6LtLcxeD5G)(xlGq7dKJbYr23Bogih83)AbeAF54sLYCUoYzZWr5eDovkhysAyrW58l8TCwnkhn8Sq5iniKASqXzi1QsYh6Nerl49VwaH2xo4lhJhAFcE3s421LZUKdgedZbdKdQC0QrVKhO3QifWKuF3cpDwvsWSblZC2zzclu6SQKGzXdl0cGeU2ujj4gi07LLz7WcfMaCK(eAFSqX7gLdtdDXgwiSZPaOCSCWBfr5GhPbIC4Bg6LYbUG07nhNnfHAeiNELdtA0NUihUbICIohdxRW5WTNh9EZHVzOxc4zHA8q7Jf6srKOknqWcLJ0GqQXc14H2N)RiuJaIEjIg9Pl8K7eVe69MZ(CwfPuGi(MHEjrOFkNDjhJhAF(VIqnci6LiA0NUWtUt8sqce9n9a5WGCC75SphMNZwhcqGiJrb4HKsGqpXsQVBro7ZH55ulRLFRdbiqKXOV8WgSmZ5NLjSqPZQscMfpSqnEO9Xc9vAWQfnciQg8lXcLJ0GqQXcfNHuRkjFOFseTG3)AbeAF5GVCmEO9j4DlHBxxo7so7gluATiEio7tSqFLgSArJaIQb)sSblZ2Dyzclu6SQKGzXdluJhAFSqP)dwiYKIgbF2XjwOCKgesnwO4mKAvj5d9tIOf8(xlGq7lhg4ihCgsTQK80)blezsrJGp74KaMKgw5SphCgsTQK8H(jr0cE)RfqO9Ld(YbNHuRkjp9FWcrMu0i4ZoojGjPHvo7so7gl0Z(elu6)GfImPOrWNDCInyz2oyiltyHsNvLemlEyHA8q7JfkyZGBxeSOrvrVerJ(0fSq5iniKASqHqo4mKAvj5d9tIOf8(xlGq7lhg4ihCgsTQK88(xlGq7t8GiUbcrOFkhiLJBYbtmZzPVBHarFtpqomihCgsTQK8H(jr0cE)RfqO9LdeZzFo1YA559VwaH2NhUDDSqp7tSqbBgC7IGfnQk6LiA0NUGnyz2o7WYewO0zvjbZIhwOgp0(yH(kX6zt0lHba6xLwO9XcLJ0GqQXcfc5ulRLN3)AbeAFE421LZ(CWzi1QsYh6Nerl49VwaH2xo4Zro4mKAvj57tuaKGxIETYbtmZbNHuRkjFFIcGe8s0RvooYbdZbISqp7tSqFLy9Sj6LWaa9Rsl0(ydwMTJByzclu6SQKGzXdluJhAFSq)g3Qisa2ike)cq5Sq5iniKASqXzi1QsYh6Nerl49VwaH2xomWro7gl0Z(el0VXTkIeGnIcXVauoBWYSDWGSmHfkDwvsWS4Hfkmb4i9j0(yH68w5ua69MJLdiiuRW503UuauoAqFSZXKUmSa5uauoolezWlfr5W0qaajZPlbqHPC6vo4V)1ci0(85GxgBeYLciSZ5bPnsdLPfkNcqV3CCwiYGxkIYHPHaasMJln2Yb)9VwaH2xo9jXkhDLJZ7we6mzo43aCdMYrb5qNvLeCo2bNJLtbyVuoU6dYrovkhzdICACekNyJYbUGSq7lNELtSr5S03TWNdt2uqogmmihlhW3KYCWzYcLt05eBuo8ULWTRlNELJZcrg8sruomneaqYCCTrxoWTEV5eBkihUj5fPfAF5ujUvauoAKJcYPCiYKGq55eDogau(uoXMf5OroUuPmNkLtbqW58qOfXdjw50xo8ULWTRZZc9SpXcfgrg8srKahbaKKfkhPbHuJfkeYPwwlpV)1ci0(8WTRlN95GZqQvLKp0pjIwW7FTacTVCWNJCWzi1QsY3NOaibVe9ALdMyMdodPwvs((efaj4LOxRCCKdgMdeZzFoqiNAzT86Ti0zsb3aCdM8GW4mMJJCQL1YR3IqNjfCdWnyY)n3fGW4mMdMyMdZZH3hCrdVElcDMuWna3GjpDwvsW5GjM5GZqQvLKN3)AbeAFI(efaLdMyMdodPwvs(q)KiAbV)1ci0(YbF5OxqONwAbblw67wiq030dKJZxo5aHCmEO9j4DlHBxxoqkNDWWCGyoqKfQXdTpwOWiYGxkIe4iaGKSblZ2XTZYewO0zvjbZIhwOgp0(yHc6IuOVNgeIfkhPbHuJfkeYbNHuRkjFOFseTG3)AbeAF5Gph5GbXWCWa5aHCWzi1QsY3NOaibVe9ALd(YbdZbI5GjM5aHCyEobspgPWh74vGh0fPqFpniuo7Zjq6Xif(yhFbyvjLZ(CcKEmsHp2XZ7wc3UopI(MEGCWeZCyEobspgPWhUXRapOlsH(EAqOC2NtG0Jrk8HB8fGvLuo7Zjq6Xif(WnEE3s4215r030dKdeZbI5SphiKdZZHWRf95HG9WiYGxkIe4iaGK5GjM5W7wc3UopmIm4LIibocaiPhrFtpqo4lNDlhiYc9SpXcf0fPqFpnieBWYSD2nwMWcLoRkjyw8Wc14H2hluUDCskQL1IfkhPbHuJfkZZH3hCrdVElcDMuWna3GjpDwvsW5SpNq)uomiNDlhmXmNAzT86Ti0zsb3aCdM8GW4mMJJCQL1YR3IqNjfCdWnyY)n3fGW4mYcTwwlXzFIfkOlsH(EAO9XcfMaCK(eAFSqzcsFFjuoq7ImhN37PbHYHmKeRCCPXwooVBrOZK5GFdWnykNgLJRn6YrJCCzGCEqe3aHNnyz2omDSmHfkDwvsWS4Hfkmb4i9j0(yH68c6dYj2Sih4oNRJCQ0rlnYb)9VwaH2xoGTUiHZHPDbe5uPCkacoNUeafMYPx5G)(xlGq7lhlYb0FkNNwVWZc9SpXcvpahvcRkjbETyxu(cycNYjwOCKgesnwOeETOppeS)vAWQfnciQg8lLZ(CGqo1YA559VwaH2NhUDD5SphCgsTQK8H(jr0cE)RfqO9Ld(CKdodPwvs((efaj4LOxRCWeZCWzi1QsY3NOaibVe9ALJJCWWCGiluJhAFSq1dWrLWQssGxl2fLVaMWPCInyz2oo7SmHfkDwvsWS4HfQXdTpwOlP9jrVevlcjXcLJ0GqQXcLWRf95HG9VsdwTOrar1GFPC2NdeYPwwlpV)1ci0(8WTRlN95GZqQvLKp0pjIwW7FTacTVCWNJCWzi1QsY3NOaibVe9ALdMyMdodPwvs((efaj4LOxRCCKdgMdezHE2NyHUK2Ne9suTiKeBWYSDC(zzclu6SQKGzXdluJhAFSqDzmshHaIfQpywOCKgesnwOeETOppeS)vAWQfnciQg8lLZ(CGqo1YA559VwaH2NhUDD5SphCgsTQK8H(jr0cE)RfqO9Ld(CKdodPwvs((efaj4LOxRCWeZCWzi1QsY3NOaibVe9ALJJCWWCGil0Z(eluxgJ0riGyH6dMnyz2o7oSmHfkDwvsWS4HfQXdTpwO6bcuHhnciGvC6rIkjLSq5iniKASqj8ArFEiy)R0GvlAequn4xkN95aHCQL1YZ7FTacTppC76YzFo4mKAvj5d9tIOf8(xlGq7lh85ihCgsTQK89jkasWlrVw5GjM5GZqQvLKVprbqcEj61khh5GH5arwON9jwO6bcuHhnciGvC6rIkjLSblZCdgYYewO0zvjbZIhwOgp0(yHckxv2nSW(uSHfiyHYrAqi1yHs41I(8qW(xPbRw0iGOAWVuo7Zbc5ulRLN3)AbeAFE421LZ(CWzi1QsYh6Nerl49VwaH2xo4Zro4mKAvj57tuaKGxIETYbtmZbNHuRkjFFIcGe8s0RvooYbdZbISqp7tSqbLRk7gwyFk2WceSblZCZoSmHfkDwvsWS4HfkhPbHuJfATSwEE)RfqO95HBxxo7ZbNHuRkjFOFseTG3)AbeAF5Gph5GZqQvLKVprbqcEj61khmXmhCgsTQK89jkasWlrVw54ihmKfQXdTpwOfaj0G(a2GLzUXnSmHfkDwvsWS4HfQXdTpwOludcX14mwOWeGJ0Nq7Jf6Uhq5G3Oge5WSgNLt05ei99Lq5S7IuGeRCCECLljpluosdcPgluu5OvJEj)lsbsSekx5sYtNvLeCo7ZPwwlpV)1ci0(8WTRlN95aHCWzi1QsYh6Nerl49VwaH2xo4lhJhAFcE3s421LdMyMdodPwvs(q)KiAbV)1ci0(YHb5GZqQvLKN3)AbeAFIheXnqic9t5aPCi3jEjirOFkhiYgSmZnyqwMWcLoRkjyw8Wc14H2hluExUGqGhskzHctaosFcTpwO7UuKtSr54SuaxFK6ziSYb)9)BhCo1YALt5b7CkNKaGC49VwaH2xokihq3NNfkhPbHuJfkQC0QrVKhwbC9rQNHWsW7)3oypDwvsW5SphE3s4215RL1saRaU(i1Zqyj49)BhShrgmw5SpNAzT8WkGRps9mewcE))2blme3oYd3UUC2NdZZPwwlpSc46JupdHLG3)VDW(Yto7Zbc5GZqQvLKp0pjIwW7FTacTVCGuogp0(8ludIAldp3aHi0pLd(YH3TeUDD(AzTeWkGRps9mewcE))2b7Hlil0(YbtmZbNHuRkjFOFseTG3)AbeAF5WGC2TCGiBWYm342zzclu6SQKGzXdluosdcPgluu5OvJEjpSc46JupdHLG3)VDWE6SQKGZzFo8ULWTRZxlRLawbC9rQNHWsW7)3oypImySYzFo1YA5HvaxFK6ziSe8()TdwyiUDKhUDD5SphMNtTSwEyfW1hPEgclbV)F7G9LNC2NdeYbNHuRkjFOFseTG3)AbeAF5aPCi3jEjirOFkhiLJXdTp)c1GO2YWZnqic9t5GVC4DlHBxNVwwlbSc46JupdHLG3)VDWE4cYcTVCWeZCWzi1QsYh6Nerl49VwaH2xomiNDlN95W8Cctsx4rLJe9s80UiKNoRkj4CGiluJhAFSqne3osqU)iBG2hBWYm3SBSmHfkDwvsWS4HfkhPbHuJfkQC0QrVKhwbC9rQNHWsW7)3oypDwvsW5SphE3s4215RL1saRaU(i1Zqyj49)BhShrFtpqomihUbcrOFkN95ulRLhwbC9rQNHWsW7)3oyXc1GWd3UUC2NdZZPwwlpSc46JupdHLG3)VDW(Yto7Zbc5GZqQvLKp0pjIwW7FTacTVCGuoCdeIq)uo4lhE3s4215RL1saRaU(i1Zqyj49)BhShUGSq7lhmXmhCgsTQK8H(jr0cE)RfqO9LddYz3YbISqnEO9XcDHAquBzWgSmZnmDSmHfkDwvsWS4HfkhPbHuJfkQC0QrVKhwbC9rQNHWsW7)3oypDwvsW5SphE3s4215RL1saRaU(i1Zqyj49)BhShrgmw5SpNAzT8WkGRps9mewcE))2blwOgeE421LZ(CyEo1YA5HvaxFK6ziSe8()Td2xEYzFoqihCgsTQK8H(jr0cE)RfqO9Ld(YH3TeUDD(AzTeWkGRps9mewcE))2b7Hlil0(YbtmZbNHuRkjFOFseTG3)AbeAF5WGC2TCGiluJhAFSqxOgeIRXzSblZCJZoltyHsNvLemlEyH2pSqbuWc14H2hluCgsTQKyHctaosFcTpwO7A3YCmqoF7Wkh8wruo4rAGaKJbY5PbaTkPCwnkh83)AbeAF(CGwQbY4roDjYPx5eBuolKXdTptMdV)p9rxKtVYj2OCUYVsOC6vo4TIOCWJ0abiNyZICCPszoNffKjLyLdI4Bg6LYbUG07nNyJYb)9VwaH2xopBgGYPsCRaOCE6wQ3Bo2HvSP3BopgiYj2SihxQuMZ1roVi7ICSlhY9az5G3kIYbpsde5axq69Md(7FTacTppluCMSqSqXzi1QsYtUh0btWcE)RfqO9jq030dKddYbNHuRkjFOFseTG3)AbeAF5SphJhAF(LIirvAGWZ3m0lbelKXdTptMdKYbc5GZqQvLKp0pjIwW7FTacTVCGuogp0(8GnDf69kEAxeYVksParWfEO9LdgihCgsTQK8GnDf69kEAxesuPvJibV)1ci0(Ybs5aHCGPAzT8FfHAeq0lr0OpDH)BUlaHXzmNDjNDYbI5GbYbNHuRkj)VdbI4Bg6Le2VlxKdgihEJJo7cpo6InSq5GbYbc5W7wc3Uo)xrOgbe9sen6tx4r030dKddCKdodPwvs(q)KiAbV)1ci0(YbI5aXCyyo8ULWTRZVuejQsdeE4cYcTVC2LC2jhgKdVBjC768lfrIQ0aH)BUl4Bg6La5aPCWzi1QsY34i0t3sXsrKOknqaYHH5W7wc3Uo)srKOknq4Hlil0(YzxYbc5ulRLN3)AbeAFE4cYcTVCyyo8ULWTRZVuejQsdeE4cYcTVCGyo548LZo5SphCgsTQK8H(jr0cE)RfqO9LddYzPVBHarFtpal0cGe9AjE5WSmBhwO4mK4SpXcDPisuLgiepDl17LfAbqcxBQKeCde69YYSDydwM5gNFwMWcLoRkjyw8WcLJ0GqQXcfNHuRkjFOFseTG3)AbeAF5Wah5GH5GjM5ulRLN3)AbeAF(YtoyIzo4mKAvj5d9tIOf8(xlGq7lhgKdodPwvsEE)RfqO9jEqe3aHi0pLZ(C4DlHBxNN3)AbeAFEe9n9a5WGCWzi1QsYZ7FTacTpXdI4gieH(jwOgp0(yHYnPuy8q7tivqWcvQGqC2NyHY7FTacTpXZMbi2GLzUz3HLjSqPZQscMfpSq5iniKASqRL1YZ7FTacTppC76YzFo1YA5rLJe9s80UiKhUDD5SphMNtTSw(LIiq0OVhrgpYzFoqihCgsTQK8H(jr0cE)RfqO9Ld(CKtTSwEu5irVepTlc5Hlil0(YzFo4mKAvj5d9tIOf8(xlGq7lh8LJXdTp)srKOknq4xfPuGi(MHEjrOFkhmXmhCgsTQK8H(jr0cE)RfqO9Ld(YzPVBHarFtpqoqmN95aHCyEoOYrRg9sEq5emQ3lquLeaO3RNoRkj4CWeZCmEO4ibD0xjqo4Zro4mKAvj53meSGBGqSK2NabszKYbtmZPwwlpOCcg17fiQsca07vGidglF5jhmXmNAzT8GYjyuVxGOkjaqVxpImEKd(CKtTSwEq5emQ3lquLeaO3R)BUlaHXzmNDjNDYbtmZzPVBHarFtpqomiNAzT8OYrIEjEAxeYdxqwO9LdezHA8q7JfkQCKOxIN2fHydwMHbXqwMWcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSqnEO9XcfNHuRkjwO9dluafSq5iniKASqzEo4mKAvj5xkIevPbcXt3s9EZzFoOYrRg9sEq5emQ3lquLeaO3RNoRkjywOfaj61s8YHzz2oSqXzYcXcfqgsVxr0f(M34HIJYzFogp0(8lfrIQ0aHFvKsbI4Bg6LeH(PCWxoyWCWa58YH9FZDwOWeGJ0Nq7JfQZaMPDbe5eBuo4mKAvjLtSzro8(culb5G3kIYbpsde5ua2lLt05amCuo4TIOCWJ0abihxBQKYbkzi9EZHjDHVLJcYX4HIJYXLgB5aTC54mP3lKb5Ghjba696zHIZqIZ(el0LIirvAGq80TuVx2GLzyWDyzclu6SQKGzXdluycWr6tO9XcLPFJUCka9EZbVL2NabszKYrVCWF)RfqO9HDoadhLJbY5Bhw5W3m0lbYXa580aGwLuoRgLd(7FTacTVCCPXwxIC42ZJEVEwOgp0(yHYnPuy8q7tivqWcfeiLhSmBhwOCKgesnwO1YA5rLJe9s80UiKV8KZ(CQL1YZ7FTacTppC76YzFo4mKAvj5d9tIOf8(xlGq7lh8LdgYcvQGqC2NyHI6hXZMbi2GLzyq3WYewO0zvjbZIhwOfajCTPssWnqO3llZ2HfQXdTpwO4mKAvjXcTFyHcOGfkhPbHuJfkZZbNHuRkj)srKOknqiE6wQ3Bo7ZjmjDHhvos0lXt7IqE6SQKGZzFo1YA5rLJe9s80UiKhUDDSqlas0RL4LdZYSDyHIZKfIfkeYH55GkhTA0l5bLtWOEVarvsaGEVE6SQKGZbtmZPwwlpOCcg17fiQsca071dcJZyo4lNAzT8GYjyuVxGOkjaqVx)3CxacJZyo7so7KdeZzFo8ULWTRZJkhj6L4PDripI(MEGCyqogp0(8lfrIQ0aHFvKsbI4Bg6LeH(PC2LCmEO95bB6k07v80UiKFvKsbIGl8q7lhmqoqihCgsTQK8GnDf69kEAxesuPvJibV)1ci0(YzFo8ULWTRZd20vO3R4PDripI(MEGCyqo8ULWTRZJkhj6L4PDripI(MEGCGyo7ZH3TeUDDEu5irVepTlc5r030dKddYzPVBHarFtpaluycWr6tO9Xc1zaZ0UaICInkhCgsTQKYj2SihEFbQLGCWBfr5GhPbICka7LYj6COduquoAaYHVzOxcKJHOCmjOZ5PBjbNZQr542khLtVYzxBxeYZcfNHeN9jwOlfrIQ0aH4PBPEVSblZWGyqwMWcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSq5iniKASqzEo4mKAvj5xkIevPbcXt3s9EZzFo4mKAvj5d9tIOf8(xlGq7lh8LdgMZ(CmEO4ibD0xjqo4Zro4mKAvj53meSGBGqSK2NabszKYzFompNLIiqyOGqEJhkokN95W8CQL1YV1HaeiYy0xEYzFoqiNAzT8BKf69kkp(Yto7ZX4H2NFjTpbcKYi5j3jEjibI(MEGCyqoyOF3YbtmZHVzOxciwiJhAFMmh85ih3KdezHwaKOxlXlhMLz7Wc14H2hl0LIirvAGGfkmb4i9j0(yHY0Vrxo4fgcMBGqV3CWBP9jqGugjSZbVveLdEKgia5a26IeoNkLtbqW5eDoV0rilOCWl6ihObImgb5yhCorNd5EqhCo4rAGGq54SzGGqE2GLzyq3oltyHsNvLemlEyHwaKW1Mkjb3aHEVSmBhwOCKgesnwOlfrGWqbH8gpuCuo7ZbNHuRkjFOFseTG3)AbeAF5GVCWWC2NdZZbNHuRkj)srKOknqiE6wQ3Bo7Zbc5W8CmEO95xkIQMu6j3jEj07nN95W8CmEO95FWc1vPbcVEILuF3IC2NtTSw(nYc9EfLhpImEKdMyMJXdTp)sru1Ksp5oXlHEV5SphMNtTSw(ToeGargJEez8ihmXmhJhAF(hSqDvAGWRNyj13TiN95ulRLFJSqVxr5XJiJh5SphMNtTSw(ToeGargJEez8ihiYcTairVwIxomlZ2HfQXdTpwOlfrIQ0abluycWr6tO9Xc1zvq69MdERicegkie25G3kIYbpsdeGCmeLtbqW5a0VknKeRCIoh4csV3CWF)RfqO95Zz3LoczsjwyNtSryLJHOCkacoNOZ5LoczbLdErh5anqKXiihxB0LdhPbihxQuMZ1rovkhxgii4CSdohxASLdEKgiiuooBgiie25eBew5a26IeoNkLd4brgCoDjYj6C(MEHPxoXgLdEKgiiuooBgiiuo1YA5zdwMHb3nwMWcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSqHjahPpH2hluNbUwHZHBpp69MdERikh8inqKdFZqVeihxBQKYHVz3rs9EZb6MUc9EZzxBxeIfQXdTpwOlfrIQ0abluosdcPgluJhAFEWMUc9EfpTlc5j3jEj07nN95SksPar8nd9sIq)uomihJhAFEWMUc9EfpTlc5dLZOarWfEO9XgSmddY0XYewO0zvjbZIhwOCKgesnwO4mKAvj5d9tIOf8(xlGq7lh8LdgMZ(CQL1YJkhj6L4PDripC76YzFo1YA559VwaH2NhUDDSqnEO9XcLBsPW4H2NqQGGfQubH4SpXcfe2bBiybQdl0(ydwMHbD2zzcluJhAFSqb8gX3yHsNvLemlEyd2Gf6dI49VAbltyz2oSmHfQXdTpwOgIBhj0liPK4blu6SQKGzXdBWYm3WYewO0zvjbZIhwOWeGJ0Nq7JfQXdTpG)br8(xTasoyiodPwvsyF2NC0NOaibVe9AHnotwihUbdHeodPwvsE6)GfImPOrWNDCsatsdlS1LdcVw0Nhc2t)hSqKjfnc(SJtSqnEO9XcDjjWghzRGnyzggKLjSqPZQscMfpSqnEO9Xcf0fPqFpnieluosdcPgluMNdodPwvsEE)RfqO9j6tuauo7ZH55q41I(8qWEyezWlfrcCeaqYC2NdZZjmjDHFPicegkiKNoRkjywON9jwOGUif67PbHydwM52zzclu6SQKGzXdl0Z(eluWMb3UiyrJQIEjIg9PlyHA8q7JfkyZGBxeSOrvrVerJ(0fSblZ2nwMWc14H2hl0VIqnsOF7LyHsNvLemlEydwMX0XYewO0zvjbZIhwOCKgesnwOmpNheHZ)GfQRsdeSqnEO9Xc9bluxLgiyd2GfkV)1ci0(epBgGyzclZ2HLjSqPZQscMfpSq7hwOakyHA8q7JfkodPwvsSqHjahPpH2hluNzqOFlOC2Ax5i77nh83)AbeAF54sLYCKgiYj2SJrqorNd0YLJZKEVqgKdEKeaO3BorNdmfe6RhLZw7kh8wruo4rAGaKdyRls4CQuofab7zHIZKfIfATSwEE)RfqO95r030dKdKYPwwlpV)1ci0(8WfKfAF5GbYbc5W7wc3UopV)1ci0(8i6B6bYHb5ulRLN3)AbeAFEe9n9a5arwOfaj61s8YHzz2oSqXziXzFIfk5Eqhmbl49VwaH2NarFtpal0cGeU2ujj4gi07LLz7WgSmZnSmHfkDwvsWS4HfAbqcxBQKeCde69YYSDyHctaosFcTpwOodyyqoXgLdCbzH2xo9kNyJYbA5YXzsVxidYbpsca07nh83)AbeAF5eDoXgLdDW50RCInkhEbHOlYb)9VwaH2xo6kNyJYHBGihxDrcNdimuKdCbP3BoXMcYb)9VwaH2NNfA)Wc1GHzHYrAqi1yHIkhTA0l5bLtWOEVarvsaGEVE6SQKGZzFoqiNAzT8GYjyuVxGOkjaqVxbImyS8LNCWeZCWzi1QsYtUh0btWcE)RfqO9jq030dKd(Y5Ld7r030dKdKYzh)ULdgiNxoS)BUNdgihiKtTSwEq5emQ3lquLeaO3R)BUlaHXzmNDjNAzT8GYjyuVxGOkjaqVxpimoJ5aXCGiluCMSqSqXzi1QsYdySkGlil0(yHwaKOxlXlhMLz7Wc14H2hluCgsTQKyHIZqIZ(eluY9GoycwW7FTacTpbI(MEa2GLzyqwMWcLoRkjyw8WcfMaCK(eAFSqXlJncLdVBjC76a5eBwKdyRls4CQuofabNJln2Yb)9VwaH2xoGTUiHZPpjw5uPCkacohxASLJD5y8OyYCWF)RfqO9Ld3aro2bNZ1roU0ylhlhOLlhNj9EHmih8ijaqV3CEqn3Zc14H2hluUjLcJhAFcPccwOGaP8GLz7WcLJ0GqQXcfNHuRkjp5Eqhmbl49VwaH2NarFtpqo4lhCgsTQK8agRc4cYcTpwOsfeIZ(eluE)RfqO9j4DlHBxhGnyzMBNLjSqPZQscMfpSqnEO9XcLBsPW4H2NqQGGfQubH4SpXc14HIJeHjPlaSblZ2nwMWcLoRkjyw8Wc14H2hluUDCskQL1IfkhPbHuJfATSwEE)RfqO95HBxxo7ZPwwlpOCcg17fiQsca071dcJZyo4lh3KZ(Cctsx4rLJe9s80UiKNoRkj4C2NdVBjC768OYrIEjEAxeYJOVPhihgKJBWqwO1YAjo7tSqbLtWOEVarvsaGEVSqHjahPpH2hluN3khOLlhNj9EHmih8ijaqV3CaHXzeKJHOC203nSZHBhNK5eB0pNkTAeLd(7FTacTVCaDoXMf5eBuoqlxoot69czqo4rsaGEV58GAEoC7YPs5aSfjXkhysAyrW5uUqL5yRGq5G)(xlGq7lhxAS1LihKcymNELd5(JISq7ZZgSmJPJLjSqPZQscMfpSqnEO9XcDjTpbcKYiXcfMaCK(eAFSqDERCWF)RfqO9LJcYbUDDyNZdI4giYb0Fk207nNkTAeLJXdfNf69MJgEwOCKgesnwO1YA559VwaH2NhUDD5SphE3s421559VwaH2NhrFtpqomihUbcrOFkN95y8qXrc6OVsGCWNJCWzi1QsYZ7FTacTpXsAFceiLrInyzMZoltyHsNvLemlEyHYrAqi1yHwlRLN3)AbeAFE421LZ(CQL1YdkNGr9EbIQKaa9EfiYGXYxEYzFo1YA5bLtWOEVarvsaGEVcezWy5r030dKd(YHBGqe6NyHA8q7Jf6dwOUknqWgSmZ5NLjSqPZQscMfpSq5iniKASqRL1YZ7FTacTppC76YzFo1YA5FWc1CPb(Eez8iN95ulRL)bluZLg47r030dKd(YHBGqe6NyHA8q7Jf6dwOUknqWgSmB3HLjSqPZQscMfpSq5iniKASqRL1YZ7FTacTppC76YzFo8ULWTRZZ7FTacTppI(MEGCyqoCdeIq)uo7ZH55W7dUOHFjTpjmohrH2NNoRkjywOgp0(yHUuevnPKnyz2oyiltyHsNvLemlEyHYrAqi1yHwlRLN3)AbeAFE421LZ(C4DlHBxNN3)AbeAFEe9n9a5WGC4gieH(jwOgp0(yHc4nIVXgSmBNDyzclu6SQKGzXdl0cGeU2ujj4gi07LLz7WcLJ0GqQXcDRdbiqKXOa8qsjqONyj13Tihh5GH5SpNAzT88(xlGq7Zd3UUC2NdodPwvs(q)KiAbV)1ci0(YHboYbdZzFoqihMNdQC0QrVKhwbC9rQNHWsW7)3oypDwvsW5GjM5ulRLhwbC9rQNHWsW7)3oyF5jhmXmNAzT8WkGRps9mewcE))2blwOge(Yto7ZjmjDHhvos0lXt7IqE6SQKGZzFo8ULWTRZxlRLawbC9rQNHWsW7)3oypImySYbI5SphiKdZZbvoA1OxY)IuGelHYvUK80zvjbNdMyMdmvlRL)fPajwcLRCj5lp5aXC2NdeYH55WBC0zx4pIJAzJGZbtmZH3TeUDDEyYITAJoYJOVPhihmXmNAzT8WKfB1gDKV8KdeZzFoqihMNdVXrNDHhhDXgwOCWeZC4DlHBxN)RiuJaIEjIg9Pl8i6B6bYbI5SphiKJXdTp)NcQrE9elP(Uf5SphJhAF(pfuJ86jws9Dlei6B6bYHboYbNHuRkjpV)1ci0(eCdece9n9a5GjM5y8q7Zd4nIV5j3jEj07nN95y8q7Zd4nIV5j3jEjibI(MEGCyqo4mKAvj559VwaH2NGBGqGOVPhihmXmhJhAF(LIOQjLEYDIxc9EZzFogp0(8lfrvtk9K7eVeKarFtpqomihCgsTQK88(xlGq7tWnqiq030dKdMyMJXdTp)dwOUknq4j3jEj07nN95y8q7Z)GfQRsdeEYDIxcsGOVPhihgKdodPwvsEE)RfqO9j4giei6B6bYbtmZX4H2NFjTpbcKYi5j3jEj07nN95y8q7ZVK2NabszK8K7eVeKarFtpqomihCgsTQK88(xlGq7tWnqiq030dKdezHwaKOxlXlhMLz7Wc14H2hluE)RfqO9XcfMaCK(eAFSqXF)RfqO9LdyRls4CQuofabNJRn6Yj2OCEqe3arokiht(BqKZspfSrWE2GLz74gwMWcLoRkjyw8WcTaiHRnvscUbc9Ezz2oSq5iniKASqzEo8(GlA41BrOZKcUb4gm5PZQscoN95W8CWzi1QsYVuejQsdeINUL69MZ(CQL1YZ7FTacTpF5jN95W8CQL1YVuebIg99iY4ro7ZH55ulRLFRdbiqKXOhrgpYzFoBDiabImgfGhskbc9elP(Uf5aPCQL1YVrwO3RO84rKXJCWa5aHCE5WEe9n9a5GVCWWCGyomih3WcTairVwIxomlZ2HfQXdTpwOlfrIQ0abluycWr6tO9XcLPxJTUe548UfHotMd(na3GjSZHPDbe5uauo4TIOCWJ0abihxB0LtSryLJR(GCKZVC8TC4ina5yhCoU2Olh8wreiA0phfKdC768SblZ2bdYYewO0zvjbZIhwOfajCTPssWnqO3llZ2HfQXdTpwO4mKAvjXcTFyHcOGfkhPbHuJfkVXrNDH)03TqSmIfAbqIETeVCywMTdluCMSqSqxkIaHHcc5r030dKddYbNHuRkjp5Eqhmbl49VwaH2NarFtpqo7Zbc5W7dUOHxVfHotk4gGBWKNoRkj4C2NdodPwvsEY9hIheSyPisuLgia5WGCWzi1QsYFebtWILIirvAGaKdeZzFoqihMNtys6cpQCKOxIN2fH80zvjbNdMyMdVBjC768OYrIEjEAxeYJOVPhih8LdodPwvsEY9GoycwW7FTacTpbI(MEGCGyoyIzogpuCKGo6Reih85ihCgsTQK88(xlGq7ta20vO3R4PDriwOWeGJ0Nq7Jf6Uhq5aDtxHEV5SRTlcLdCbP3Bo4V)1ci0(YX1gD5eBeIYXquoxh5qxxE3YbVveLdEKgia5y4mvAvjLt05Sksjw5qUh0bNJElcDMmhUb4gmLJDW50NeRCCTrxoUTYr50RC212fHYrb50xo8ULWTRZZcfNHeN9jwOfajaB6k07v80UieBWYSDC7SmHfkDwvsWS4HfAbqcxBQKeCde69YYSDyHYrAqi1yHY7dUOHxVfHotk4gGBWuo7ZH55GZqQvLKFPisuLgiepDl17nN95aHCWzi1QsYtU)q8GGflfrIQ0abih85ihCgsTQK8hrWeSyPisuLgia5GjM5ulRLN3)AbeAFEe9n9a5WGCE5W(V5EoyIzo4mKAvj5j3d6GjybV)1ci0(ei6B6bYHboYPwwlVElcDMuWna3GjpCbzH2xoyIzo1YA51BrOZKcUb4gm5bHXzmhgKJBYbtmZPwwlVElcDMuWna3GjpI(MEGCyqoVCy)3CphmXmhE3s4215bB6k07v80UiKhrgmw5SphCgsTQK8fajaB6k07v80UiuoqmN95ulRLN3)AbeAF(Yto7Zbc5W8CQL1YVuebIg99iY4royIzo1YA51BrOZKcUb4gm5r030dKddYbd97woqmN95W8CQL1YV1HaeiYy0JiJh5SpNToeGargJcWdjLaHEILuF3ICGuo1YA53il07vuE8iY4royGCGqoVCypI(MEGCWxoyyoqmhgKJByHwaKOxlXlhMLz7Wc14H2hl0LIirvAGGnyz2o7gltyHsNvLemlEyHA8q7Jf6sAFceiLrIfkmb4i9j0(yHc9Ho4CWl6ihObImgb5axq69Md(7FTacTVCSiNn9DlNhK2inWYZcLJ0GqQXcfc5ulRLFRdbiqKXOV8KZ(CmEO4ibD0xjqo4Zro4mKAvj559VwaH2NyjTpbcKYiLdeZbtmZbc5ulRLFPicen67lp5SphJhkosqh9vcKd(CKdodPwvsEE)RfqO9jws7tGaPms5Sl5GkhTA0l5xkIarJ(E6SQKGZbISblZ2HPJLjSqPZQscMfpSqnEO9XcfzWQDHa8yigzHctaosFcTpwOUndwTlYb6JHymhWwxKW5uPCkacohxASLJLdErh5anqKXyoiYGXkNOZPaOC0)NGvlijw5yRGq5eBuoCde5S0tbBeWNdt2uqoUuPmNZIcYKsSYbqroLNCSCWl6ihObImgZb8qxKZQr5eBuol9mzoGW4mMtVYXTzWQDroqFmeJEwOCKgesnwO1YA559VwaH2NV8KZ(CCtoyGCQL1YV1HaeiYy0JiJh5aPCQL1YVrwO3RO84rKXJCGuoBDiabImgfGhskbc9elP(Uf54ih3WgSmBhNDwMWcLoRkjyw8WcLJ0GqQXcTwwl)sreiA03xEyHA8q7Jf6dwOUknqWgSmBhNFwMWcLoRkjyw8WcLJ0GqQXcTwwl)whcqGiJrF5jN95ulRLN3)AbeAF(YdluJhAFSqFWc1vPbc2GLz7S7WYewO0zvjbZIhwOCKgesnwOpicN4Ld73Xd4nIVLZ(CQL1YVrwO3RO84lp5SphJhkosqh9vcKddYbNHuRkjpV)1ci0(elP9jqGugPC2NtTSwEE)RfqO95lpSqnEO9Xc9bluxLgiydwM5gmKLjSqPZQscMfpSqnEO9XcfSPRqVxXt7IqSqHjahPpH2hl0DpqV3CGUPRqV3C212fHYbUG07nh83)AbeAF5eDoicenIYbVveLdEKgiYXo4C21TMo19CWBP9PC4Bg6La5WTlNkLtLoAPC1KyNtTe5uaftkXkN(KyLtF54mANzpluosdcPgluCgsTQK8fajaB6k07v80Uiuo7ZPwwlpV)1ci0(8LNC2NdZZX4H2NFPisuLgi88nd9sGC2NJXdTp)ZwtN6UyjTpb88nd9sGCyqogp0(8pBnDQ7IL0(eW)n3f8nd9sa2GLzUzhwMWcLoRkjyw8Wc14H2hluu5irVepTlcXcfMaCK(eAFSqHwUCCM07fYGCWJKaa9EZ5b1Cqo9LtSrkkN21LdyRls4CQuoWK0WIGZz1OC2vSqnxAGFopOMdYX1gD580aGwLe25ulroDSrixkGYHBxovkNcGGZrVCWF)RfqO9LJRn6Yj2ieLJHOCaL1s5kDro4TIOCWJ0abWNJZBLJLd0YLJZKEVqgKdEKeaO3BopOMNJRUiHZPs5uaem2542khLtVYzxBxekhWwxKW5uPCkacoNLIaro6kNyJYHCxbHEV542khLtVYzxBxekhxQuMd5(JIOCGli9EZj2OC4gi8Sq5iniKASqRL1YdkNGr9EbIQKaa9EfiYGXYxEYzFoqihCgsTQK8hrWeSyPisuLgia5Wah5GZqQvLKNC)H4bblwkIevPbcqoyIzoWuTSw(VIqnci6LiA0NUWxEYbI5SphJhkosqh9vcKd(CKdodPwvsEE)RfqO9jws7tGaPms5SpNAzT8GYjyuVxGOkjaqVxbImyS8i6B6bYbF5qUt8sqIq)uoqkhJhAF(L0(eiqkJKNBGqe6NydwM5g3WYewO0zvjbZIhwOCKgesnwO1YA5bLtWOEVarvsaGEVcezWy5lp5SphiKdodPwvs(JiycwSuejQsdeGCyGJCWzi1QsYtU)q8GGflfrIQ0abihmXmhyQwwl)xrOgbe9sen6tx4lp5aXC2NJXdfhjOJ(kbYbFoYbNHuRkjpV)1ci0(elP9jqGugPC2NtTSwEq5emQ3lquLeaO3RargmwEe9n9a5GVC4gieH(PC2NdeYH55W7dUOHxVfHotk4gGBWKNoRkj4CWeZCQL1YR3IqNjfCdWnyYJOVPhih8Ld5oXlbjc9t5GjM5ulRLFJSqVxr5XJiJh5aPC26qacezmkapKuce6jws9DlYHb54MCGiluJhAFSqxs7tGaPmsSblZCdgKLjSqPZQscMfpSq5iniKASqRL1YdkNGr9EbIQKaa9EfiYGXYxEYzFoqihMNtys6c)dwOMlnW3tNvLeCoyIzo1YA5FWc1CPb(Eez8iN95ulRL)bluZLg47r030dKd(YHCN4LGeH(PCGuogp0(8pyH6Q0aHNBGqe6NYbtmZbNHuRkj)remblwkIevPbcqomWro4mKAvj5j3FiEqWILIirvAGaKdMyMdmvlRL)RiuJaIEjIg9Pl8LNCGyo7ZPwwlpOCcg17fiQsca07vGidglpI(MEGCWxoK7eVeKi0pLdKYX4H2N)bluxLgi8CdeIq)eluJhAFSqrLJe9s80UieBWYm342zzclu6SQKGzXdluosdcPgl0AzT8GYjyuVxGOkjaqVxbImyS8LNC2NdeYH55eMKUW)GfQ5sd890zvjbNdMyMtTSw(hSqnxAGVhrgpYzFo1YA5FWc1CPb(Ee9n9a5GVC4gieH(PCWeZCWzi1QsYFebtWILIirvAGaKddCKdodPwvsEY9hIheSyPisuLgia5GjM5at1YA5)kc1iGOxIOrF6cF5jhiMZ(CQL1YdkNGr9EbIQKaa9EfiYGXYJOVPhih8Ld3aHi0pLZ(CGqomphEFWfn86Ti0zsb3aCdM80zvjbNdMyMtTSwE9we6mPGBaUbtEe9n9a5GVCi3jEjirOFkhmXmNAzT8BKf69kkpEez8ihiLZwhcqGiJrb4HKsGqpXsQVBromih3KdezHA8q7Jf6dwOUknqWgSmZn7gltyHsNvLemlEyHA8q7Jf6dwOUknqWcfMaCK(eAFSq3vSqnxAGFopOMdYbS1fjCovkNcGGZrVCWF)RfqO9LJf5SPVBekNhK2inWkNyZUC21TMo19CWBP9jqo2bNduEJ4BEwOCKgesnwO1YA5FWc1CPb(Eez8iN95ulRL)bluZLg47r030dKd(YHBGqe6NYzFo1YA559VwaH2NhrFtpqo4lhUbcrOFkN95y8qXrc6OVsGCyqo4mKAvj559VwaH2NyjTpbcKYiLZ(CGqomphEFWfn86Ti0zsb3aCdM80zvjbNdMyMtTSwE9we6mPGBaUbtEe9n9a5GVCi3jEjirOFkhmXmNAzT8BKf69kkpEez8ihiLZwhcqGiJrb4HKsGqpXsQVBromih3KdezdwM5gMowMWcLoRkjyw8Wc14H2hl0NTMo1DXsAFcWcfMaCK(eAFSq39akNDDRPtDph8wAFcKJDW5aL3i(wo6Ld(7FTacTVCIoNns(KZlDeYckh8IoYbAGiJrqoU2Olh8wruo4rAGaKJHOCUoYXWzQ0QskNgLZreCorNtLYH3hGq4iypluosdcPgl0AzT88(xlGq7ZxEYzFobYWrsrOFkhgKtTSwEE)RfqO95r030dKZ(CQL1YVrwO3RO84rKXJCGuoBDiabImgfGhskbc9elP(Uf5WGCCdBWYm34SZYewO0zvjbZIhwOCKgesnwO1YA559VwaH2NhrFtpqo4lhUbcrOFIfQXdTpwOaEJ4BSblZCJZpltyHsNvLemlEyHA8q7JfQuXP3RO2)kluycWr6tO9Xc15TYj2ieLJcoih5qxxE3Yj0pLJKwro6Ld(7FTacTVCwnkhlNDDRPtDph8wAFcKtJYbkVr8TCIoNnnYrpGct50RCWF)RfqO9HDofaLdO)uSP3BoKeqEwOCKgesnwO1YA559VwaH2NhrFtpqomiNxoS)BUNZ(CmEO4ibD0xjqo4lNDydwM5MDhwMWcLoRkjyw8WcLJ0GqQXcTwwlpV)1ci0(8i6B6bYHb58YH9FZ9C2NtTSwEE)RfqO95lpSqnEO9XcfgzV9bevezXgBWgSqnEO4irys6caltyz2oSmHfkDwvsWS4HfkhPbHuJfQXdfhjOJ(kbYbF5Sto7ZPwwlpV)1ci0(8WTRlN95aHCWzi1QsYh6Nerl49VwaH2xo4lhE3s4215Lko9Ef1(x9WfKfAF5GjM5GZqQvLKp0pjIwW7FTacTVCyGJCWWCGiluJhAFSqLko9Ef1(xzdwM5gwMWcLoRkjyw8WcLJ0GqQXcfNHuRkjFOFseTG3)AbeAF5Wah5GH5GjM5ulRLN3)AbeAFEe9n9a5GVCcKHJKIq)uoyIzoqihE3s4215)uqnYdxqwO9LddYbNHuRkjFOFseTG3)AbeAF5SphMNtys6cpQCKOxIN2fH80zvjbNdeZbtmZjmjDHhvos0lXt7IqE6SQKGZzFo1YA5rLJe9s80UiKV8KZ(CWzi1QsYh6Nerl49VwaH2xo4lhJhAF(pfuJ88ULWTRlhmXmNL(Ufce9n9a5WGCWzi1QsYh6Nerl49VwaH2hluJhAFSq)uqnInyzggKLjSqPZQscMfpSq5iniKASqdtsx4nj5oiqgGPfdiwfewE6SQKGZzFoqiNAzT88(xlGq7Zd3UUC2NdZZPwwl)whcqGiJrF5jhiYc14H2hluyK92hqurKfBSbBWcfe2bBiybQdl0(yzclZ2HLjSqPZQscMfpSq5iniKASqnEO4ibD0xjqo4Zro4mKAvj536qacezmkws7tGaPms5SphiKtTSw(ToeGargJ(YtoyIzo1YA5xkIarJ((YtoqKfQXdTpwOlP9jqGugj2GLzUHLjSqPZQscMfpSq5iniKASqRL1YdtwSvB0r(Yto7ZbvoA1OxYdtwSbell26VNoRkj4C2NdodPwvs(q)KiAbV)1ci0(YHb5ulRLhMSyR2OJ8i6B6bYzFogpuCKGo6Reih85ih3Wc14H2hl0LIOQjLSblZWGSmHfkDwvsWS4HfkhPbHuJfATSw(LIiq0OVV8Wc14H2hl0hSqDvAGGnyzMBNLjSqPZQscMfpSq5iniKASqRL1YV1HaeiYy0xEYzFo1YA536qacezm6r030dKddYX4H2NFPiQAsPNCN4LGeH(jwOgp0(yH(GfQRsdeSblZ2nwMWcLoRkjyw8WcLJ0GqQXcTwwl)whcqGiJrF5jN95aHCEqeoXlh2VJFPiQAszoyIzolfrGWqbH8gpuCuoyIzogp0(8pyH6Q0aHxpXsQVBroqKfQXdTpwOpyH6Q0abBWYmMowMWcLoRkjyw8Wc14H2hl0L0(eiqkJeluycWr6tO9XcLjiSYj6CEPihOot4jNhuZb5OhqHPCCB9UMZZMbiqonkh83)AbeAF58SzacKJRn6Y5PbaTkjpluosdcPgluJhkosqh9vcKd(CKdodPwvs(ndbl4gielP9jqGugPC2NtTSwEq5emQ3lquLeaO3Rargmw(Yto7Zbc5W7wc3UopQCKOxIN2fH8i6B6bYbs5y8q7ZJkhj6L4PDrip5oXlbjc9t5aPC4gieH(PCWxo1YA5bLtWOEVarvsaGEVcezWy5r030dKdMyMdZZjmjDHhvos0lXt7IqE6SQKGZbI5SphCgsTQK8H(jr0cE)RfqO9LdKYHBGqe6NYbF5ulRLhuobJ69cevjba69kqKbJLhrFtpaBWYmNDwMWcLoRkjyw8WcLJ0GqQXcTwwl)whcqGiJrF5jN95aidP3Ri6cFZB8qXrSqnEO9Xc9bluxLgiydwM58ZYewO0zvjbZIhwOCKgesnwO1YA5FWc1CPb(Eez8iN95Wnqic9t5WGCQL1Y)GfQ5sd89i6B6bYzFoqihMNdQC0QrVKhuobJ69cevjba696PZQscohmXmNAzT8pyHAU0aFpI(MEGCyqogp0(8lfrvtk9CdeIq)uoqkhUbcrOFkhmqo1YA5FWc1CPb(Eez8ihiYc14H2hl0hSqDvAGGnyz2UdltyHsNvLemlEyHwaKW1Mkjb3aHEVSmBhwOCKgesnwOmpNLIiqyOGqEJhkokN95W8CWzi1QsYVuejQsdeINUL69MZ(CQL1YdkNGr9EbIQKaa9EfiYGXYd3UUC2NdeYbc5aHCmEO95xkIQMu6j3jEj07nN95aHCmEO95xkIQMu6j3jEjibI(MEGCyqoyOF3YbtmZH55GkhTA0l5xkIarJ(E6SQKGZbI5GjM5y8q7Z)GfQRsdeEYDIxc9EZzFoqihJhAF(hSqDvAGWtUt8sqce9n9a5WGCWq)ULdMyMdZZbvoA1OxYVuebIg990zvjbNdeZbI5SpNAzT8BKf69kkpEez8ihiMdMyMdeYbqgsVxr0f(M34HIJYzFoqiNAzT8BKf69kkpEez8iN95W8CmEO95b8gX38K7eVe69MdMyMdZZPwwl)whcqGiJrpImEKZ(CyEo1YA53il07vuE8iY4ro7ZX4H2NhWBeFZtUt8sO3Bo7ZH55S1HaeiYyuaEiPei0tSK67wKdeZbI5arwOfaj61s8YHzz2oSqnEO9XcDPisuLgiyHctaosFcTpwOoRcsV3CInkhqyhSHGZb1HfAFyNtFsSYPaOCWBfr5GhPbcqoU2OlNyJWkhdr5CDKtL07nNNULeCoRgLJBR31CAuo4V)1ci0(85S7buo4TIOCWJ0aroKgBekh4csV3CSCWBfrvtkz4UIfQRsde5WnqKJRn6YbVGSqV3C29p5OGCmEO4OCAuoWfKEV5qUt8sq54sJTCGsgsV3Cysx4BE2GLz7GHSmHfkDwvsWS4HfkhPbHuJfATSw(ToeGargJ(Yto7ZX4HIJe0rFLa5WGCWzi1QsYV1HaeiYyuSK2NabszKyHA8q7Jf6dwOUknqWgSmBNDyzclu6SQKGzXdluosdcPgluMNdodPwvs(NTMo1DXt3s9EZzFoqihMNtys6c)c1FrSrcdSrapDwvsW5GjM5y8qXrc6OVsGCWxo7KdeZzFoqihJhkosa3HxFpnOCyqoUjhmXmhJhkosqh9vcKd(CKdodPwvs(ndbl4gielP9jqGugPCWeZCmEO4ibD0xjqo4Zro4mKAvj536qacezmkws7tGaPms5arwOgp0(yH(S10PUlws7ta2GLz74gwMWcLoRkjyw8Wc14H2hluUjLcJhAFcPccwOsfeIZ(eluJhkoseMKUaWgSmBhmiltyHsNvLemlEyHYrAqi1yHA8qXrc6OVsGCWxo7Wc14H2hluyK92hqurKfBSblZ2XTZYewO0zvjbZIhwOCKgesnwOaYq69kIUW38gpuCeluJhAFSqb8gX3ydwMTZUXYewO0zvjbZIhwOCKgesnwOgpuCKGo6Reih85ihCgsTQK8gIBhji3FKnq7lN958TZ8p8ih85ihCgsTQK8gIBhji3FKnq7t8TZYzFoHHEPW7sJn92bdzHA8q7JfQH42rcY9hzd0(ydwMTdthltyHsNvLemlEyHA8q7Jf6sAFceiLrIfkmb4i9j0(yHY0RXwo01L3TCcd9sba7C0ihfKJLZRPxorNd3aro4T0(eiqkJuogiNLkLekh9abzW50RCWBfrvtk9Sq5iniKASqnEO4ibD0xjqo4Zro4mKAvj53meSGBGqSK2NabszKydwMTJZoltyHA8q7Jf6sru1KswO0zvjbZIh2GnyHY7FTacTpbVBjC76aSmHLz7WYewOgp0(yH(0H2hlu6SQKGzXdBWYm3WYewOgp0(yHwLDdlwfewSqPZQscMfpSblZWGSmHfkDwvsWS4HfkhPbHuJfATSwEE)RfqO95lpSqnEO9XcTsiaHyuVx2GLzUDwMWc14H2hl0LIOQSBywO0zvjbZIh2GLz7gltyHA8q7JfQDCceitk4MuYcLoRkjyw8WgSmJPJLjSqPZQscMfpSq5iniKASqrLJwn6L8b9FAKjfUm0JNoRkj4C2NtTSwEY9nRacTpF5HfQXdTpwOH(jHld9WgSmZzNLjSqPZQscMfpSqnEO9Xc9vAWQfnciQg8lXcLwlIhIZ(el0xPbRw0iGOAWVeBWYmNFwMWcLoRkjyw8Wc9SpXcvpahvcRkjbETyxu(cycNYjwOgp0(yHQhGJkHvLKaVwSlkFbmHt5eBWYSDhwMWcLoRkjyw8Wc9SpXcDjTpj6LOArijwOgp0(yHUK2Ne9suTiKeBWYSDWqwMWcLoRkjyw8Wc9SpXc1LXiDeciwO(GzHA8q7JfQlJr6ieqSq9bZgSmBNDyzclu6SQKGzXdl0Z(elu9abQWJgbeWko9irLKswOgp0(yHQhiqfE0iGawXPhjQKuYgSmBh3WYewO0zvjbZIhwON9jwOGYvLDdlSpfBybcwOgp0(yHckxv2nSW(uSHfiydwMTdgKLjSqnEO9XcTaiHg0hWcLoRkjyw8WgSbBWcfhHaAFSmZnyOB2zNDCdgKfQldD69cyHY07mCBmZ5XSDxNlNCyYgLJ(FAuKZQr5azu)iE2mab5CqeETOicohq)PCSs0Fli4C4B29saF6KBPhLJBCUCWFF4iuqW5azu5OvJEjptb5CIohiJkhTA0l5zkpDwvsWqohiSJ7q0No5w6r54S7C5G)(WrOGGZbYHjPl8mfKZj6CGCys6cpt5PZQscgY5aHDChI(0j3spkhNFNlh83hocfeCoqgvoA1OxYZuqoNOZbYOYrRg9sEMYtNvLemKZbcUXDi6tNCl9OC2bdDUCWFF4iuqW5azu5OvJEjptb5CIohiJkhTA0l5zkpDwvsWqohiSJ7q0NoLoX07mCBmZ5XSDxNlNCyYgLJ(FAuKZQr5azyAzfza5CqeETOicohq)PCSs0Fli4C4B29saF6KBPhLZooxo4VpCeki4CGmQC0QrVKNPGCorNdKrLJwn6L8mLNoRkjyiNJf54mJx6w5aHDChI(0j3spkh3UZLd(7dhHccohiJkhTA0l5zkiNt05azu5OvJEjpt5PZQscgY5yrooZ4LUvoqyh3HOpDYT0JYHPZ5Yb)9HJqbbNdKrLJwn6L8mfKZj6CGmQC0QrVKNP80zvjbd5CSihNz8s3khiSJ7q0No5w6r5Sdg05Yb)9HJqbbNdu9J)CayDH5EooFoF5eDoUvXY53WfzbKt)qilAuoqW5dI5aHDChI(0j3spkNDWGoxo4VpCeki4CGmVp4IgEMcY5eDoqM3hCrdpt5PZQscgY5aHDChI(0j3spkNDC7oxo4VpCeki4CGCG0Jrk874zkiNt05a5aPhJu4JD8mfKZbcyq3HOpDYT0JYzh3UZLd(7dhHccohihi9yKcVB8mfKZj6CGCG0Jrk8HB8mfKZbcyq3HOpDYT0JYzNDZ5Yb)9HJqbbNdK59bx0WZuqoNOZbY8(GlA4zkpDwvsWqohiSJ7q0No5w6r54g34C5G)(WrOGGZbYOYrRg9sEMcY5eDoqgvoA1OxYZuE6SQKGHCoqyh3HOpDYT0JYXnyqNlh83hocfeCoqgvoA1OxYZuqoNOZbYOYrRg9sEMYtNvLemKZbc74oe9PtULEuoUXT7C5G)(WrOGGZbYHjPl8mfKZj6CGCys6cpt5PZQscgY5aHDChI(0j3spkh342DUCWFF4iuqW5azu5OvJEjptb5CIohiJkhTA0l5zkpDwvsWqohiSJ7q0No5w6r54MDZ5Yb)9HJqbbNdKrLJwn6L8mfKZj6CGmQC0QrVKNP80zvjbd5CGWoUdrF6KBPhLJBy6CUCWFF4iuqW5azu5OvJEjptb5CIohiJkhTA0l5zkpDwvsWqohiSJ7q0No5w6r54gNDNlh83hocfeCoq1p(ZbG1fM7548Lt054wflhyfNc0(YPFiKfnkhiWqiMdeWGUdrF6KBPhLJBC2DUCWFF4iuqW5av)4phawxyUNJZNZxorNJBvSC(nCrwa50peYIgLdeC(Gyoqyh3HOpDYT0JYXn7ooxo4VpCeki4CGmQC0QrVKNPGCorNdKrLJwn6L8mLNoRkjyiNde2XDi6tNCl9OCWGyOZLd(7dhHccohiJkhTA0l5zkiNt05azu5OvJEjpt5PZQscgY5yrooZ4LUvoqyh3HOpDYT0JYbd6gNlh83hocfeCoqgvoA1OxYZuqoNOZbYOYrRg9sEMYtNvLemKZbc74oe9PtULEuoyq34C5G)(WrOGGZbYHjPl8mfKZj6CGCys6cpt5PZQscgY5aHDChI(0P0jMENHBJzopMT76C5Kdt2OC0)tJICwnkhi)GiE)Rwa5CqeETOicohq)PCSs0Fli4C4B29saF6KBPhLdg05Yb)9HJqbbNdKdtsx4zkiNt05a5WK0fEMYtNvLemKZXICCMXlDRCGWoUdrF6u6etVZWTXmNhZ2DDUCYHjBuo6)PrroRgLdK59VwaH2NG3TeUDDaiNdIWRffrW5a6pLJvI(BbbNdFZUxc4tNCl9OCy6CUCWFF4iuqW5azu5OvJEjptb5CIohiJkhTA0l5zkpDwvsWqohiSJ7q0NoLoX07mCBmZ5XSDxNlNCyYgLJ(FAuKZQr5azJhkoseMKUaa5CqeETOicohq)PCSs0Fli4C4B29saF6KBPhLJBCUCWFF4iuqW5a5WK0fEMcY5eDoqomjDHNP80zvjbd5CGGBChI(0j3spkhmOZLd(7dhHccohihMKUWZuqoNOZbYHjPl8mLNoRkjyiNde2XDi6tNsNy6DgUnM58y2URZLtomzJYr)pnkYz1OCGmiSd2qWcuhwO9b5CqeETOicohq)PCSs0Fli4C4B29saF6KBPhLJBCUCWFF4iuqW5azu5OvJEjptb5CIohiJkhTA0l5zkpDwvsWqohiSJ7q0No5w6r5W05C5G)(WrOGGZbYHjPl8mfKZj6CGCys6cpt5PZQscgY5aHDChI(0j3spkhNFNlh83hocfeCoqgvoA1OxYZuqoNOZbYOYrRg9sEMYtNvLemKZbc74oe9PtULEuo7ooxo4VpCeki4CGmQC0QrVKNPGCorNdKrLJwn6L8mLNoRkjyiNdeCJ7q0No5w6r5SZooxo4VpCeki4CGCys6cptb5CIohihMKUWZuE6SQKGHCoqyh3HOpDkDIP3z42yMZJz7Uoxo5WKnkh9)0OiNvJYbY8(xlGq7t8SzacY5Gi8ArreCoG(t5yLO)wqW5W3S7La(0j3spkh34C5G)(WrOGGZbYOYrRg9sEMcY5eDoqgvoA1OxYZuE6SQKGHCoqyh3HOpDYT0JYz3CUCWFF4iuqW5a5WK0fEMcY5eDoqomjDHNP80zvjbd5CGWoUdrF6KBPhLZUJZLd(7dhHccohiZ7dUOHNPGCorNdK59bx0WZuE6SQKGHCowKJZmEPBLde2XDi6tNCl9OC2zhNlh83hocfeCoqomjDHNPGCorNdKdtsx4zkpDwvsWqohiSJ7q0No5w6r5SZooxo4VpCeki4CGmQC0QrVKNPGCorNdKrLJwn6L8mLNoRkjyiNdeCJ7q0No5w6r5SJBCUCWFF4iuqW5azEFWfn8mfKZj6CGmVp4IgEMYtNvLemKZbc74oe9PtULEuo7GbDUCWFF4iuqW5a5WK0fEMcY5eDoqomjDHNP80zvjbd5CGWoUdrF6KBPhLZoyqNlh83hocfeCoqM3hCrdptb5CIohiZ7dUOHNP80zvjbd5CGWoUdrF6KBPhLZo7MZLd(7dhHccohiJkhTA0l5zkiNt05azu5OvJEjpt5PZQscgY5aHDChI(0j3spkh34gNlh83hocfeCoqM3hCrdptb5CIohiZ7dUOHNP80zvjbd5CGWoUdrF6KBPhLJBWGoxo4VpCeki4CGCys6cptb5CIohihMKUWZuE6SQKGHCoqyh3HOpDYT0JYXnUDNlh83hocfeCoqomjDHNPGCorNdKdtsx4zkpDwvsWqohiSJ7q0No5w6r54g3UZLd(7dhHccohiZ7dUOHNPGCorNdK59bx0WZuE6SQKGHCoqyh3HOpDYT0JYXn7MZLd(7dhHccohiZ7dUOHNPGCorNdK59bx0WZuE6SQKGHCoqyh3HOpDkDY59FAuqW54SNJXdTVCKkia(0jwOGhIZYmMomil0huVujXcfJymh8wruooB2lLoHrmMZwepaNJHm8vJTs1Z7pdb6ViTq7JJSvWqG(5mmDcJymhNXdsL5Sd254gm0nUjDkDcJymh8Vz3lbCU0jmIXC2LC29akNL(Ufce9n9a5GSyJq5eB2LtyOxk8H(jr0cyLYz1OCKgi2faX7dohRQsnWkNcWEjGpDcJymNDjh3QBaD5WnqKdIWRffrF6cqoRgLd(7FTacTVCGG6jp25a3hKJC2AjCoAKZQr5y5SqeylhNnkOgLd3abe9PtyeJ5Sl54mFwvs5acKYJC4BeNr9EZPVCSCwKRCwnIrqo6LtSr54m2v3kNOZbrWfoLJRgXOSnyF6egXyo7soodyM2fqKJLZUIfQRsde5qxGWkNyZICGBcKZ1ro)gMK54IKYC0BxETpLdea6pNGabbNJf5CDoa990LYTlYXzTRqZr)pgpGOpDcJymNDjh83hocf5yszo1YA5zkpImEKdDbsjqorNtTSwEMYxEWoh7YXK)ge5OhqFpDPC7ICCw7k0CEn9YrVCa6h4tNWigZzxYz3dOC2memVHj4CWzi1QscKt05Gi4cNYb)76UphxnIrzBW(0P0jmIXCCMDN4LGGZPsRgr5W7F1ICQ0REaFoodoNEcqoxF7YMH(RImhJhAFGC6tILpDY4H2hW)GiE)Rwajhm0qC7iHEbjLepsNWigZXzSRUvomngsTQKYbV8j0(CUCCERCauKt05y5C9TlmTqOohCMSqyNtSr5G)(xlGq7lhJhAF5yhCo8ULWTRdKtSzrogIYH3hiqMEeCorNtFsSYPs5uaeCoU2Olh83)AbeAF5OGCkp54sLYCUoYPs5uaeCoWfKEV5eBuoa9xKwO95tNWyogp0(a(heX7F1ci5GH4mKAvjH9zFYbScSQKe8(xlGq7d7(XbIauKoHrmMJZyxDRCyAmKAvjLdE5tO95C5WKnfKdodPwvs5aEiUUucKJRnk2iuo4V)1ci0(YbS1fjCovkNcGGZbUG07nh8wreimuqiF6egZX4H2hW)GiE)RwajhmeNHuRkjSp7towkIaHHccj49VwaH2h2W0YkYWXUSd24mzHCW8WK0f(hSqnxAGp26YbodPwvs(LIiqyOGqcE)RfqO9XammDcJymhNXU6w5W0yi1Qskh8YNq7Z5YHjBkihCgsTQKYb8qCDPeiNyJY5k)kHYPx5eg6LcqowKJRnLVLdErh5anqKXyo4T0(eiqkJeiNUeafMYPx5G)(xlGq7lhWwxKW5uPCkac2NoHXCmEO9b8piI3)QfqYbdXzi1Qsc7Z(KJToeGargJIL0(eiqkJe26YbodPwvs(ToeGargJIL0(eiqkJKdmeBCMSqoCdgimjDHFjTpjESGVbj3ogG5HjPl8lP9jXJf8T0jmIXCCg7QBLdtJHuRkPCWlFcTpNlhMSPGCWzi1QskhWdX1LsGCInkNR8RekNELtyOxka5yroU2u(wo4fgcoh8BGih8wAFceiLrcKtxcGct50RCWF)RfqO9LdyRls4CQuofabNJbYzPsjH8PtymhJhAFa)dI49VAbKCWqCgsTQKW(Sp5yZqWcUbcXsAFceiLrcBD5aNHuRkj)MHGfCdeIL0(eiqkJKdmeBCMSqoWGyGWK0f(L0(K4Xc(gKy6WampmjDHFjTpjESGVLoHrmMJZyxDRCyAmKAvjLdE5tO95C5WKnfKdodPwvs5aEiUUucKtSr5CLFLq50RCcd9sbihlYX1MY3YbVOJCGgiYymh8wAFceiLrcKJHOCkacoh4csV3CWF)RfqO95tNWyogp0(a(heX7F1ci5GH4mKAvjH9zFYbV)1ci0(elP9jqGugjS1LdCgsTQK88(xlGq7tSK2NabszKCGHyJZKfYbgedeMKUWVK2NepwW3GethgG5HjPl8lP9jXJf8T0jmIXCCg7QBLdtJHuRkPCWlFcTpNlhMSPGCWzi1QskhWdX1LsGCInkNR8RekNELtyOxka5yroU2u(woode3okhNz3FKnq7lNUeafMYPx5G)(xlGq7lhWwxKW5uPCkac2NoHXCmEO9b8piI3)QfqYbdXzi1Qsc7Z(KddXTJeK7pYgO9HTUCGZqQvLK3qC7ib5(JSbAFoWqSXzYc5y3z3bdeMKUWVK2NepwW3GKBWampmjDHFjTpjESGVLoHrmMJZyxDRCyAmKAvjLdE5tO95C5WKnfKdodPwvs5aEiUUucKtSr58qioDH9s50RC(2z5ujz7khxBkFlhNbIBhLJZS7pYgO9LJlvkZ56iNkLtbqW(0jmMJXdTpG)br8(xTasoyiodPwvsyF2NCyiUDKGC)r2aTpX3odByAzfz4WTJHy3poqeGI0jmIXCCg7QBLdtJHuRkPCWlFcTpNlhMSr5CLFLq50RCcd9sbihlYX1MY3Yb6MUc9EZzxBxekhUD5uaeCoWfKEV5G)(xlGq7ZNoHXCmEO9b8piI3)QfqYbdXzi1Qsc7Z(KdE)RfqO9jaB6k07v80Uie26YbodPwvsEE)RfqO9jaB6k07v80UiKdmeBCMSqoWzi1QsYZ7FTacTpXsAFceiLrkDcJymhNXU6w5W0yi1Qskh8YNq7Z5YHjBuoH(PCq030tV3C6lhlhUbICCTrxo4V)1ci0(YHBxovkNcGGZrVCaeVpyGpDcJ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh8(xlGq7tWnqiq030dGnmTSImCGHENDS7hhicqr6egXyooJD1TYHPXqQvLuo4LpH2NZLdt2uqo4mKAvjLd4H46sjqoXgLZv(vcLtVYbq8(Gb50RCWBfr5GhPbICInlYbS1fjCovkNNULeCopgiYj2OCGPLvKro2Vlx4tNWyogp0(a(heX7F1ci5GH4mKAvjH9zFYrJJqpDlflfrIQ0abaByAzfz4adXUFCGiafPtyeJ54m2v3khMgdPwvs5Gx(eAFoxo4fTRCK99MtLwnIYb)9VwaH2xoGTUiHZXz()GfImzo4Li4ZooLtLYPaiyMwtNWyogp0(a(heX7F1ci5GH4mKAvjH9zFYb9FWcrMu0i4ZoojGjPHf2W0YkYWXoo)y3poqeGI0jmIXCCERCWF)RfqO9LJcYbwbwvsWyNdGVrWfjLtSr5SueiYb)9VwaH2xoldLJTccLtSr5S03Tih6Gb(0jmMJXdTpG)br8(xTasoyiodPwvsyF2NCe6Nerl49VwaH2h24mzHCS03TqGOVPhas7GHyi26YbodPwvsEyfyvjj49VwaH2x6egXyomzJYbUGSq7lNELJLd0YLJZKEVqgKdEKeaO3Bo4V)1ci0(8PtymhJhAFa)dI49VAbKCWqCgsTQKW(Sp5aWyvaxqwO9HnotwihWvUNwlIhENF34872Ddg6RgGe4mzHsNWyomzJY5k)kHYPx5aiEFWGC6vo4TIOCWJ0aroiIVzOxcoNkw54SPiuJa50RCysJ(0f(0jmMJXdTpG)br8(xTasoyiodPwvsyF2NC87qGi(MHEjH97YfyJZKfYbCL7P1I4H353zFh34S729vdqcCMSqPtyeJ5W0VrXgHYXYPaSQKYrd6NtbqW5eDo1YALd(7FTacTVCuqoeETOppeSpDcJ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh8(xlGq7t0NOaiSXzYc5GWRf95HG9VsdwTOrar1GFjmXKWRf95HG9FJBvejaBefIFbOCmXKWRf95HG96b4OsyvjjWRf7IYxat4uoHjMeETOppeShuUQSByH9PydlqGjMeETOppeSN(pyHitkAe8zhNWetcVw0Nhc2VK2Ne9suTiKeMys41I(8qWExgJ0riGyH6dgtmj8ArFEiyVEGav4rJacyfNEKOssjMys41I(8qWEWMb3UiyrJQIEjIg9PlsNWigZbVODLJSV3CQ0Qruo4V)1ci0(YbS1fjCobspgPaKtSzrobsFFjuowoGndrW5WTGEBew5W7wc3UUC6lNo2iuobspgPaKZ1rovkNcGGzAnDcJ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh9jkasWlrVwyJZKfYHBWqS1LdCgsTQK88(xlGq7t0NOaO0jmMJXdTpG)br8(xTasoyiodPwvsyF2NC0NOaibVe9AHnotwihUz3Wwxoi8ArFEiy)34wfrcWgrH4xakpDcJ5y8q7d4FqeV)vlGKdgIZqQvLe2N9jh9jkasWlrVwyJZKfYHBWqiHZqQvLKN(pyHitkAe8zhNeWK0WcBD5GWRf95HG90)blezsrJGp74u6KXdTpG)br8(xTasoy4ssGnoYwr6KXdTpG)br8(xTasoyybqcnOp2N9jhGUif67PbHWwxoyoodPwvsEE)RfqO9j6tua0EMt41I(8qWEyezWlfrcCeaqY9mpmjDHFPicegkiu6KXdTpG)br8(xTasoyybqcnOp2N9jhGndUDrWIgvf9sen6txKoz8q7d4FqeV)vlGKdg(veQrc9BVu6KXdTpG)br8(xTasoy4dwOUknqGTUCW8heHZ)GfQRsdePtPtyeJ54m7oXlbbNdHJqyLtOFkNyJYX4rJYrb5y4mvAvj5tNmEO9bCW7Yfec8qsj26YbZrLJwn6L8WkGRps9mewcE))2bNoHrmMdZixRUCW542iqlXr5OGCa9NIn9EZj2SihUDqoYPs58ByssW(0jmIXCmEO9bGKdgEKRvxoybIaTehHDbqcxBQKeCde696yhS1LdiulRLN3)AbeAF(YdMywlRLhuobJ69cevjba69kqKbJLhrgpG4(AzT8h5A1LdwGiqlXrE421LoHrmMdt2OC49VwaH2Ni0VEV5y8q7lhPcICa8ncUijqoU2Olh83)AbeAF54sLYCQuofabNJDW5aIgrGCInkhebkYih9YbNHuRkjFOFseTG3)AbeAF(0jmIXCmEO9bGKdgYnPuy8q7tivqG9zFYbV)1ci0(eH(17nDcJ5W0yi1QskNyZICiqOFliqoU2OyJq5aDtxHEV5SRTlcLJlvkZPs5uaeCovA1ikh83)AbeAF5OGCqKbJLpDcJymhJhAFai5GH4mKAvjH9zFYbytxHEVIN2fHevA1isW7FTacTpS7hhakWgNjlKdiy8qXrc6OVsagGZqQvLKN3)AbeAFcWMUc9EfpTlcHjMgpuCKGo6ReGb4mKAvj559VwaH2NyjTpbcKYiHjM4mKAvj5d9tIOf8(xlGq7BxmEO95bB6k07v80UiKFvKsbIGl8q7dF8ULWTRZd20vO3R4PDripCbzH2he3JZqQvLKp0pjIwW7FTacTVDH3TeUDDEWMUc9EfpTlc5r030dGpJhAFEWMUc9EfpTlc5xfPuGi4cp0(2dbE3s4215rLJe9s80UiKhrFtpWUW7wc3UopytxHEVIN2fH8i6B6bW3UHjMmpmjDHhvos0lXt7IqqmDY4H2hasoyiytxHEVIN2fHWwxoQL1YZ7FTacTppC762B8q7ZVuejQsdeE(MHEjadCSZEMdHAzT86Ti0zsb3aCdM8LN91YA536qacezm6rKXdiUhNHuRkjpytxHEVIN2fHevA1isW7FTacTV0jmMdudhLJBZGv7ICG(yigZz1OCWF)RfqO9HDo1sKthBeYLcOCkakhnYPVC4DlHBxNpDY4H2hasoyiYGv7cb4XqmITUCulRLN3)AbeAFE421Thc4mKAvj5d9tIOf8(xlGq7dF8ULWTRBx2niMoHXCCwKfB1gDuoGTUiHZXKUmSa5uPCkacohxASLd(7FTacTpFom9ASLJZISydYGCWBl26p25OroGTUiHZPs5uaeCoKHKyLdOZj2SihNfzXwTrhLJlvkZzZWr58BeLdimoJGCGli9EZb)9VwaH2NpDY4H2hasoyimzXwTrhHTUCulRLN3)AbeAFE421TVwwlpQCKOxIN2fH8WTRBpodPwvs(q)KiAbV)1ci0(yaodPwvsEE)RfqO9jEqe3aHi0pbjYDIxcse6NGeeQL1YdtwSvB0rE4cYcTVDPwwlpV)1ci0(8WfKfAFqedGkhTA0l5Hjl2aILfB9pDcJ5S7buooBkc1iqo9khM0OpDroU0ylh83)AbeAF(0jJhAFai5GHFfHAeq0lr0OpDb26YbodPwvs(q)KiAbV)1ci0(yaodPwvsEE)RfqO9jEqe3aHi0pbjYDIxcse6N2xlRLN3)AbeAFE421LoHXCCgsqNtbq54SPiuJa50RCysJ(0f5OxovkCr0Ld(7FTacTpqogihzFV5yGCWF)RfqO9LJlvkZ56iNndhLt05uPCGjPHfbNZVW3Yz1OC0WNoz8q7dajhm8RiuJaIEjIg9PlWwxoWzi1QsYh6Nerl49VwaH2h(4DlHBx3UGbXqmaQC0QrVKhO3QifWKuF3I0jmMdE3OCyAOl2WcHDofaLJLdERikh8inqKdFZqVuoWfKEV54SPiuJa50RCysJ(0f5WnqKt05y4AfohU98O3Bo8nd9saF6KXdTpaKCWWLIirvAGa7cGeU2ujj4gi071XoyRlhgp0(8FfHAeq0lr0OpDHNCN4LqV39RIukqeFZqVKi0pTlgp0(8FfHAeq0lr0OpDHNCN4LGei6B6byGBFpZ36qacezmkapKuce6jws9Dl2Z8AzT8BDiabImg9LN0jJhAFai5GHfaj0G(ytRfXdXzFYXR0GvlAequn4xcBD5aNHuRkjFOFseTG3)AbeAF4J3TeUDD7YULoz8q7dajhmSaiHg0h7Z(Kd6)GfImPOrWNDCcBD5aNHuRkjFOFseTG3)AbeAFmWbodPwvsE6)GfImPOrWNDCsatsdR94mKAvj5d9tIOf8(xlGq7dF4mKAvj5P)dwiYKIgbF2XjbmjnS2LDlDY4H2hasoyybqcnOp2N9jhGndUDrWIgvf9sen6txGTUCabCgsTQK8H(jr0cE)RfqO9Xah4mKAvj559VwaH2N4brCdeIq)eKCdMyU03TqGOVPhGb4mKAvj5d9tIOf8(xlGq7dI7RL1YZ7FTacTppC76sNmEO9bGKdgwaKqd6J9zFYXReRNnrVegaOFvAH2h26YbeQL1YZ7FTacTppC762JZqQvLKp0pjIwW7FTacTp85aNHuRkjFFIcGe8s0RfMyIZqQvLKVprbqcEj61YbgcX0jJhAFai5GHfaj0G(yF2NC8nUvrKaSrui(fGYXwxoWzi1QsYh6Nerl49VwaH2hdCSBPtymhN3kNcqV3CSCabHAfoN(2LcGYrd6JDoM0LHfiNcGYXzHidEPikhMgcaizoDjakmLtVYb)9VwaH2Nph8YyJqUuaHDopiTrAOmTq5ua69MJZcrg8sruomneaqYCCPXwo4V)1ci0(YPpjw5ORCCE3IqNjZb)gGBWuokih6SQKGZXo4CSCka7LYXvFqoYPs5iBqKtJJq5eBuoWfKfAF50RCInkNL(Uf(CyYMcYXGHb5y5a(MuMdotwOCIoNyJYH3TeUDD50RCCwiYGxkIYHPHaasMJRn6YbU17nNytb5WnjViTq7lNkXTcGYrJCuqoLdrMeekpNOZXaGYNYj2SihnYXLkL5uPCkacoNhcTiEiXkN(YH3TeUDD(0jJhAFai5GHfaj0G(yF2NCaJidEPisGJaasITUCaHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHjM4mKAvj57tuaKGxIETCGHqCpeQL1YR3IqNjfCdWnyYdcJZOJAzT86Ti0zsb3aCdM8FZDbimoJyIjZ59bx0WR3IqNjfCdWnyctmXzi1QsYZ7FTacTprFIcGWetCgsTQK8H(jr0cE)RfqO9Hp9cc90sliyXsF3cbI(MEaNpNpiW7wc3UoiTdgcriMoHrmMdZix5aTlYCCEVNgekh6cewyNdIKkbYPVCaBgIGZrd6Nd(Dw5O3QrFl0(Yj2SihfKZ1royrroGYZtJcc2NtoUn6rACcKtSr58GiCAxa5i1JYX1gD5Skhp0(mPpDY4H2hasoyybqcnOp2N9jhGUif67PbHWwxoGaodPwvs(q)KiAbV)1ci0(WNdmigIbGaodPwvs((efaj4LOxl8HHqetmHaZdKEmsHFhVc8GUif67PbH2hi9yKc)o(cWQsAFG0Jrk8745DlHBxNhrFtpaMyY8aPhJu4DJxbEqxKc990Gq7dKEmsH3n(cWQsAFG0Jrk8UXZ7wc3UopI(MEaicX9qG5eETOppeShgrg8srKahbaKetm5DlHBxNhgrg8srKahbaK0JOVPhaF7getNWyombPVVekhODrMJZ790Gq5qgsIvoU0ylhN3Ti0zYCWVb4gmLtJYX1gD5OroUmqopiIBGWNoz8q7dajhmKBhNKIAzTW(Sp5a0fPqFpn0(WwxoyoVp4IgE9we6mPGBaUbt7d9tmy3WeZAzT86Ti0zsb3aCdM8GW4m6OwwlVElcDMuWna3Gj)3CxacJZy6egZX5f0hKtSzroWDoxh5uPJwAKd(7FTacTVCaBDrcNdt7ciYPs5uaeCoDjakmLtVYb)9VwaH2xowKdO)uopTEHpDY4H2hasoyybqcnOp2N9jh6b4OsyvjjWRf7IYxat4uoHTUCq41I(8qW(xPbRw0iGOAWV0EiulRLN3)AbeAFE421ThNHuRkjFOFseTG3)AbeAF4ZbodPwvs((efaj4LOxlmXeNHuRkjFFIcGe8s0RLdmeIPtgp0(aqYbdlasOb9X(Sp5yjTpj6LOArijS1LdcVw0Nhc2)kny1Igbevd(L2dHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHjM4mKAvj57tuaKGxIETCGHqmDY4H2hasoyybqcnOp2N9jhUmgPJqaXc1hm26YbHxl6Zdb7FLgSArJaIQb)s7HqTSwEE)RfqO95HBx3ECgsTQK8H(jr0cE)RfqO9Hph4mKAvj57tuaKGxIETWetCgsTQK89jkasWlrVwoWqiMoz8q7dajhmSaiHg0h7Z(Kd9abQWJgbeWko9irLKsS1LdcVw0Nhc2)kny1Igbevd(L2dHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHjM4mKAvj57tuaKGxIETCGHqmDY4H2hasoyybqcnOp2N9jhGYvLDdlSpfBybcS1LdcVw0Nhc2)kny1Igbevd(L2dHAzT88(xlGq7Zd3UU94mKAvj5d9tIOf8(xlGq7dFoWzi1QsY3NOaibVe9AHjM4mKAvj57tuaKGxIETCGHqmDY4H2hasoyybqcnOpaBD5OwwlpV)1ci0(8WTRBpodPwvs(q)KiAbV)1ci0(WNdCgsTQK89jkasWlrVwyIjodPwvs((efaj4LOxlhyy6egZz3dOCWBudICywJZYj6CcK((sOC2DrkqIvoopUYLKpDY4H2hasoy4c1GqCnodBD5avoA1OxY)IuGelHYvUK2xlRLN3)AbeAFE421Thc4mKAvj5d9tIOf8(xlGq7dF8ULWTRdtmXzi1QsYh6Nerl49VwaH2hdWzi1QsYZ7FTacTpXdI4gieH(jirUt8sqIq)eetNWyo7UuKtSr54SuaxFK6ziSYb)9)BhCo1YALt5b7CkNKaGC49VwaH2xokihq3NpDY4H2hasoyiVlxqiWdjLyRlhOYrRg9sEyfW1hPEgclbV)F7G3Z7wc3UoFTSwcyfW1hPEgclbV)F7G9iYGXAFTSwEyfW1hPEgclbV)F7GfgIBh5HBx3EMxlRLhwbC9rQNHWsW7)3oyF5zpeWzi1QsYh6Nerl49VwaH2hKmEO95xOge1wgEUbcrOFcF8ULWTRZxlRLawbC9rQNHWsW7)3oypCbzH2hMyIZqQvLKp0pjIwW7FTacTpgSBqmDY4H2hasoyOH42rcY9hzd0(WwxoqLJwn6L8WkGRps9mewcE))2bVN3TeUDD(AzTeWkGRps9mewcE))2b7rKbJ1(AzT8WkGRps9mewcE))2blme3oYd3UU9mVwwlpSc46JupdHLG3)VDW(YZEiGZqQvLKp0pjIwW7FTacTpirUt8sqIq)eKmEO95xOge1wgEUbcrOFcF8ULWTRZxlRLawbC9rQNHWsW7)3oypCbzH2hMyIZqQvLKp0pjIwW7FTacTpgSB7zEys6cpQCKOxIN2fHGy6KXdTpaKCWWfQbrTLb26YbQC0QrVKhwbC9rQNHWsW7)3o498ULWTRZxlRLawbC9rQNHWsW7)3oypI(MEagWnqic9t7RL1YdRaU(i1Zqyj49)BhSyHAq4HBx3EMxlRLhwbC9rQNHWsW7)3oyF5zpeWzi1QsYh6Nerl49VwaH2hK4gieH(j8X7wc3UoFTSwcyfW1hPEgclbV)F7G9WfKfAFyIjodPwvs(q)KiAbV)1ci0(yWUbX0jJhAFai5GHludcX14mS1Ldu5OvJEjpSc46JupdHLG3)VDW75DlHBxNVwwlbSc46JupdHLG3)VDWEezWyTVwwlpSc46JupdHLG3)VDWIfQbHhUDD7zETSwEyfW1hPEgclbV)F7G9LN9qaNHuRkjFOFseTG3)AbeAF4J3TeUDD(AzTeWkGRps9mewcE))2b7Hlil0(WetCgsTQK8H(jr0cE)RfqO9XGDdIPtymNDTBzogiNVDyLdERikh8inqaYXa580aGwLuoRgLd(7FTacTpFoql1az8iNUe50RCInkNfY4H2NjZH3)N(OlYPx5eBuox5xjuo9kh8wruo4rAGaKtSzroUuPmNZIcYKsSYbr8nd9s5axq69MtSr5G)(xlGq7lNNndq5ujUvauopDl17nh7Wk207nNhde5eBwKJlvkZ56iNxKDro2Ld5EGSCWBfr5GhPbICGli9EZb)9VwaH2NpDY4H2hasoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJLIirvAGq80TuVxSXzYc5aNHuRkjp5Eqhmbl49VwaH2NarFtpadWzi1QsYh6Nerl49VwaH23EJhAF(LIirvAGWZ3m0lbelKXdTptcjiGZqQvLKp0pjIwW7FTacTpiz8q7Zd20vO3R4PDri)QiLcebx4H2hgaNHuRkjpytxHEVIN2fHevA1isW7FTacTpibbyQwwl)xrOgbe9sen6tx4)M7cqyCg3LDGigaNHuRkj)VdbI4Bg6Le2VlxGb4no6Sl84Ol2WcHbGaVBjC768FfHAeq0lr0OpDHhrFtpadCGZqQvLKp0pjIwW7FTacTpicrNpE3s4215xkIevPbcpCbzH23USdd4DlHBxNFPisuLgi8FZDbFZqVeas4mKAvj5BCe6PBPyPisuLgiaoF8ULWTRZVuejQsdeE4cYcTVDbc1YA559VwaH2NhUGSq7Z5J3TeUDD(LIirvAGWdxqwO9brNpNVD2JZqQvLKp0pjIwW7FTacTpgS03TqGOVPhiDY4H2hasoyi3KsHXdTpHubb2N9jh8(xlGq7t8SzacBD5aNHuRkjFOFseTG3)AbeAFmWbgIjM1YA559VwaH2NV8GjM4mKAvj5d9tIOf8(xlGq7Jb4mKAvj559VwaH2N4brCdeIq)0EE3s421559VwaH2NhrFtpadWzi1QsYZ7FTacTpXdI4gieH(P0jJhAFai5GHOYrIEjEAxecBD5OwwlpV)1ci0(8WTRBFTSwEu5irVepTlc5HBx3EMxlRLFPicen67rKXJ9qaNHuRkjFOFseTG3)AbeAF4ZrTSwEu5irVepTlc5Hlil0(2JZqQvLKp0pjIwW7FTacTp8z8q7ZVuejQsde(vrkfiIVzOxse6NWetCgsTQK8H(jr0cE)RfqO9HVL(Ufce9n9aqCpeyoQC0QrVKhuobJ69cevjba69IjMgpuCKGo6ReaFoWzi1QsYVziyb3aHyjTpbcKYiHjM1YA5bLtWOEVarvsaGEVcezWy5lpyIzTSwEq5emQ3lquLeaO3RhrgpWNJAzT8GYjyuVxGOkjaqVx)3CxacJZ4USdMyU03TqGOVPhGb1YA5rLJe9s80UiKhUGSq7dIPtymhNbmt7ciYj2OCWzi1QskNyZIC49fOwcYbVveLdEKgiYPaSxkNOZby4OCWBfr5GhPbcqoU2ujLduYq69Mdt6cFlhfKJXdfhLJln2YbA5YXzsVxidYbpsca071Noz8q7dajhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYXsrKOknqiE6wQ3l24mzHCaidP3Ri6cFZB8qXr7nEO95xkIevPbc)QiLceX3m0ljc9t4ddIbE5W(V5o26YbZXzi1QsYVuejQsdeINUL69UhvoA1OxYdkNGr9EbIQKaa9EtNWyomngsTQKYj2SihEFbQLGC21TMo19CWBP9jqofG9s5eDo0bkikhna5W3m0lbYXquopDlj4Cwnkh83)AbeAF(CWlpjw5uauo76wtN6Eo4T0(eiNUeafMYPx5G)(xlGq7lhxB0LZQiL5W3m0lbYHBxovkNUgMEeCoWfKEV5eBuoh5EKd(7FTacTpF6egXyogp0(aqYbdXzi1Qsc7Z(KJNTMo1DXt3s9EXwxomEO4ibD0xjadWzi1QsYZ7FTacTpXsAFceiLrcBCMSqoWzi1QsYh6Nerl49VwaH2hKQL1YZ7FTacTppCbzH23USBmW4H2N)zRPtDxSK2Na(vrkfiIVzOxse6NGeVBjC768pBnDQ7IL0(eWdxqwO9Tlgp0(8GnDf69kEAxeYVksParWfEO9HbWzi1QsYd20vO3R4PDrirLwnIe8(xlGq7BpodPwvs(q)KiAbV)1ci0(yWsF3cbI(MEamXevoA1OxYdkNGr9EbIQKaa9EXeZq)ed2T0jmMdt)gD5ua69MdElTpbcKYiLJE5G)(xlGq7d7CagokhdKZ3oSYHVzOxcKJbY5PbaTkPCwnkh83)AbeAF54sJTUe5WTNh9E9PtyeJ5y8q7dajhmeNHuRkjSp7toE2A6u3fpDl17fBD5W4HIJe0rFLa4ZbodPwvsEE)RfqO9jws7tGaPmsyJZKfYbodPwvs(q)KiAbV)1ci0(yGXdTp)ZwtN6UyjTpb8RIukqeFZqVKi0pTlgp0(8GnDf69kEAxeYVksParWfEO9HbWzi1QsYd20vO3R4PDrirLwnIe8(xlGq7BpodPwvs(q)KiAbV)1ci0(yWsF3cbI(MEamXevoA1OxYdkNGr9EbIQKaa9EXeZq)ed2T0jJhAFai5GHCtkfgp0(esfeyF2NCG6hXZMbiSbbs5HJDWwxoQL1YJkhj6L4PDriF5zFTSwEE)RfqO95HBx3ECgsTQK8H(jr0cE)RfqO9HpmmDcJ54mGzAxaroXgLdodPwvs5eBwKdVVa1sqo4TIOCWJ0arofG9s5eDo0bkikhna5W3m0lbYXquoMe0580TKGZz1OCCBLJYPx5SRTlc5tNmEO9bGKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5yPisuLgiepDl17fBCMSqoGaZrLJwn6L8GYjyuVxGOkjaqVxmXSwwlpOCcg17fiQsca071dcJZi(QL1YdkNGr9EbIQKaa9E9FZDbimoJ7YoqCpVBjC768OYrIEjEAxeYJOVPhGbgp0(8lfrIQ0aHFvKsbI4Bg6LeH(PDX4H2NhSPRqVxXt7Iq(vrkficUWdTpmaeWzi1QsYd20vO3R4PDrirLwnIe8(xlGq7BpVBjC768GnDf69kEAxeYJOVPhGb8ULWTRZJkhj6L4PDripI(MEaiUN3TeUDDEu5irVepTlc5r030dWGL(Ufce9n9ayRlhmhNHuRkj)srKOknqiE6wQ37(WK0fEu5irVepTlcTVwwlpQCKOxIN2fH8WTRlDcJ5W0Vrxo4fgcMBGqV3CWBP9jqGugjSZbVveLdEKgia5a26IeoNkLtbqW5eDoV0rilOCWl6ihObImgb5yhCorNd5EqhCo4rAGGq54SzGGq(0jJhAFai5GHlfrIQ0ab2faj61s8YHDSd2fajCTPssWnqO3RJDWwxoyoodPwvs(LIirvAGq80TuV394mKAvj5d9tIOf8(xlGq7dFy4EJhkosqh9vcGph4mKAvj53meSGBGqSK2NabszK2Z8LIiqyOGqEJhkoApZRL1YV1HaeiYy0xE2dHAzT8BKf69kkp(YZEJhAF(L0(eiqkJKNCN4LGei6B6byag63nmXKVzOxciwiJhAFMeFoCdetNWyooRcsV3CWBfrGWqbHWoh8wruo4rAGaKJHOCkacohG(vPHKyLt05axq69Md(7FTacTpFo7U0ritkXc7CIncRCmeLtbqW5eDoV0rilOCWl6ihObImgb54AJUC4ina54sLYCUoYPs54YabbNJDW54sJTCWJ0abHYXzZabHWoNyJWkhWwxKW5uPCapiYGZPlrorNZ30lm9Yj2OCWJ0abHYXzZabHYPwwlF6KXdTpaKCWWLIirvAGa7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyRlhlfrGWqbH8gpuC0ECgsTQK8H(jr0cE)RfqO9HpmCpZXzi1QsYVuejQsdeINUL69Uhcm34H2NFPiQAsPNCN4LqV39m34H2N)bluxLgi86jws9Dl2xlRLFJSqVxr5XJiJhyIPXdTp)sru1Ksp5oXlHEV7zETSw(ToeGargJEez8atmnEO95FWc1vPbcVEILuF3I91YA53il07vuE8iY4XEMxlRLFRdbiqKXOhrgpGy6egZXzGRv4C42ZJEV5G3kIYbpsde5W3m0lbYX1MkPC4B2DKuV3CGUPRqV3C212fHsNmEO9bGKdgUuejQsdeyxaKW1Mkjb3aHEVo2bBD5W4H2NhSPRqVxXt7IqEYDIxc9E3VksPar8nd9sIq)edmEO95bB6k07v80UiKpuoJcebx4H2x6KXdTpaKCWqUjLcJhAFcPccSp7toaHDWgcwG6WcTpS1LdCgsTQK8H(jr0cE)RfqO9HpmCFTSwEu5irVepTlc5HBx3(AzT88(xlGq7Zd3UU0jJhAFai5GHaEJ4BPtPtgp0(aEJhkoseMKUa4qQ407vu7FfBD5W4HIJe0rFLa4BN91YA559VwaH2NhUDD7HaodPwvs(q)KiAbV)1ci0(WhVBjC768sfNEVIA)RE4cYcTpmXeNHuRkjFOFseTG3)AbeAFmWbgcX0jJhAFaVXdfhjctsxaGKdg(PGAe26YbodPwvs(q)KiAbV)1ci0(yGdmetmRL1YZ7FTacTppI(MEa8fidhjfH(jmXec8ULWTRZ)PGAKhUGSq7Jb4mKAvj5d9tIOf8(xlGq7BpZdtsx4rLJe9s80UieeXeZWK0fEu5irVepTlcTVwwlpQCKOxIN2fH8LN94mKAvj5d9tIOf8(xlGq7dFgp0(8FkOg55DlHBxhMyU03TqGOVPhGb4mKAvj5d9tIOf8(xlGq7lDY4H2hWB8qXrIWK0fai5GHWi7TpGOIil2Wwxoctsx4nj5oiqgGPfdiwfew7HqTSwEE)RfqO95HBx3EMxlRLFRdbiqKXOV8aX0P0jJhAFapV)1ci0(e8ULWTRd44PdTV0jJhAFapV)1ci0(e8ULWTRdajhmSk7gwSkiSsNmEO9b88(xlGq7tW7wc3UoaKCWWkHaeIr9EXwxoQL1YZ7FTacTpF5jDY4H2hWZ7FTacTpbVBjC76aqYbdxkIQYUHtNmEO9b88(xlGq7tW7wc3UoaKCWq74eiqMuWnPmDY4H2hWZ7FTacTpbVBjC76aqYbdd9tcxg6bBD5avoA1OxYh0)PrMu4Yqp7RL1YtUVzfqO95lpPtgp0(aEE)RfqO9j4DlHBxhasoyybqcnOp20Ar8qC2NC8kny1Igbevd(LsNmEO9b88(xlGq7tW7wc3UoaKCWWcGeAqFSp7to0dWrLWQssGxl2fLVaMWPCkDY4H2hWZ7FTacTpbVBjC76aqYbdlasOb9X(Sp5yjTpj6LOAriP0jJhAFapV)1ci0(e8ULWTRdajhmSaiHg0h7Z(KdxgJ0riGyH6doDY4H2hWZ7FTacTpbVBjC76aqYbdlasOb9X(Sp5qpqGk8OrabSItpsujPmDY4H2hWZ7FTacTpbVBjC76aqYbdlasOb9X(Sp5auUQSByH9PydlqKoz8q7d459VwaH2NG3TeUDDai5GHfaj0G(G0P0jmMJZmi0VfuoBTRCK99Md(7FTacTVCCPszosde5eB2XiiNOZbA5YXzsVxidYbpsca07nNOZbMcc91JYzRDLdERikh8inqaYbS1fjCovkNcGG9Ptgp0(aEE)RfqO9jE2mabjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYb5Eqhmbl49VwaH2NarFtpa24mzHCulRLN3)AbeAFEe9n9aqQwwlpV)1ci0(8WfKfAFyaiW7wc3UopV)1ci0(8i6B6byqTSwEE)RfqO95r030daX0jmMJZaggKtSr5axqwO9LtVYj2OCGwUCCM07fYGCWJKaa9EZb)9VwaH2xorNtSr5qhCo9kNyJYHxqi6ICWF)RfqO9LJUYj2OC4giYXvxKW5acdf5axq69MtSPGCWF)RfqO95tNmEO9b88(xlGq7t8SzacsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KdY9GoycwW7FTacTpbI(MEaS7hhgmm24mzHCGZqQvLKhWyvaxqwO9HTUCGkhTA0l5bLtWOEVarvsaGEV7HqTSwEq5emQ3lquLeaO3Rargmw(YdMyIZqQvLKNCpOdMGf8(xlGq7tGOVPhaFVCypI(MEaiTJF3WaVCy)3ChdaHAzT8GYjyuVxGOkjaqVx)3CxacJZ4UulRLhuobJ69cevjba696bHXzeIqmDcJ5GxgBekhE3s421bYj2SihWwxKW5uPCkacohxASLd(7FTacTVCaBDrcNtFsSYPs5uaeCoU0ylh7YX4rXK5G)(xlGq7lhUbICSdoNRJCCPXwowoqlxoot69czqo4rsaGEV58GAUpDY4H2hWZ7FTacTpXZMbii5GHCtkfgp0(esfeyF2NCW7FTacTpbVBjC76aydcKYdh7GTUCGZqQvLKNCpOdMGf8(xlGq7tGOVPhaF4mKAvj5bmwfWfKfAFPtgp0(aEE)RfqO9jE2mabjhmKBsPW4H2NqQGa7Z(KdJhkoseMKUaKoHXCCERCGwUCCM07fYGCWJKaa9EZbegNrqogIYztF3WohUDCsMtSr)CQ0Qruo4V)1ci0(Yb05eBwKtSr5aTC54mP3lKb5Ghjba69MZdQ55WTlNkLdWwKeRCGjPHfbNt5cvMJTccLd(7FTacTVCCPXwxICqkGXC6voK7pkYcTpF6KXdTpGN3)AbeAFINndqqYbd52XjPOwwlSp7toaLtWOEVarvsaGEVyRlh1YA559VwaH2NhUDD7RL1YdkNGr9EbIQKaa9E9GW4mIp3SpmjDHhvos0lXt7Iq75DlHBxNhvos0lXt7IqEe9n9amWnyy6egZX5TYb)9VwaH2xokih421HDopiIBGihq)PytV3CQ0QruogpuCwO3BoA4tNmEO9b88(xlGq7t8Szacsoy4sAFceiLrcBD5OwwlpV)1ci0(8WTRBpVBjC7688(xlGq7ZJOVPhGbCdeIq)0EJhkosqh9vcGph4mKAvj559VwaH2NyjTpbcKYiLoz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5OwwlpV)1ci0(8WTRBFTSwEq5emQ3lquLeaO3Rargmw(YZ(AzT8GYjyuVxGOkjaqVxbImyS8i6B6bWh3aHi0pLoz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5OwwlpV)1ci0(8WTRBFTSw(hSqnxAGVhrgp2xlRL)bluZLg47r030dGpUbcrOFkDY4H2hWZ7FTacTpXZMbii5GHlfrvtkXwxoQL1YZ7FTacTppC762Z7wc3UopV)1ci0(8i6B6bya3aHi0pTN58(GlA4xs7tcJZruO9Loz8q7d459VwaH2N4zZaeKCWqaVr8nS1LJAzT88(xlGq7Zd3UU98ULWTRZZ7FTacTppI(MEagWnqic9tPtymh83)AbeAF5a26IeoNkLtbqW54AJUCInkNheXnqKJcYXK)ge5S0tbBeSpDY4H2hWZ7FTacTpXZMbii5GH8(xlGq7d7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyRlhBDiabImgfGhskbc9elP(UfoWW91YA559VwaH2NhUDD7Xzi1QsYh6Nerl49VwaH2hdCGH7HaZrLJwn6L8WkGRps9mewcE))2bJjM1YA5HvaxFK6ziSe8()Td2xEWeZAzT8WkGRps9mewcE))2blwOge(YZ(WK0fEu5irVepTlcTN3TeUDD(AzTeWkGRps9mewcE))2b7rKbJfe3dbMJkhTA0l5FrkqILq5kxsyIjmvlRL)fPajwcLRCj5lpqCpeyoVXrNDH)ioQLncgtm5DlHBxNhMSyR2OJ8i6B6bWeZAzT8WKfB1gDKV8aX9qG58ghD2fEC0fByHWetE3s4215)kc1iGOxIOrF6cpI(MEaiUhcgp0(8FkOg51tSK67wS34H2N)tb1iVEILuF3cbI(MEag4aNHuRkjpV)1ci0(eCdece9n9ayIPXdTppG3i(MNCN4LqV39gp0(8aEJ4BEYDIxcsGOVPhGb4mKAvj559VwaH2NGBGqGOVPhatmnEO95xkIQMu6j3jEj07DVXdTp)sru1Ksp5oXlbjq030dWaCgsTQK88(xlGq7tWnqiq030dGjMgp0(8pyH6Q0aHNCN4LqV39gp0(8pyH6Q0aHNCN4LGei6B6byaodPwvsEE)RfqO9j4giei6B6bWetJhAF(L0(eiqkJKNCN4LqV39gp0(8lP9jqGugjp5oXlbjq030dWaCgsTQK88(xlGq7tWnqiq030daX0jmMdtVgBDjYX5DlcDMmh8BaUbtyNdt7ciYPaOCWBfr5GhPbcqoU2OlNyJWkhx9b5iNF54B5WrAaYXo4CCTrxo4TIiq0OFokih4215tNmEO9b88(xlGq7t8Szacsoy4srKOknqGDbqIETeVCyh7GDbqcxBQKeCde696yhS1LdMZ7dUOHxVfHotk4gGBW0EMJZqQvLKFPisuLgiepDl17DFTSwEE)RfqO95lp7zETSw(LIiq0OVhrgp2Z8AzT8BDiabImg9iY4X(ToeGargJcWdjLaHEILuF3civlRLFJSqVxr5XJiJhyai8YH9i6B6bWhgcrg4M0jmMdtVgB548UfHotMd(na3GjSZbVveLdEKgiYPaOCaBDrcNtLYXGH1q7ZKsSYH3hiqMEeCoGoNyZIC0ihfKZ1rovkNcGGZPCscaYX5DlcDMmh8BaUbt5OGCSAxICIohY9hfr50OCIncr5yikNFJOCIn7YHUU8ULdERikh8inqaYj6Ci3d6GZX5DlcDMmh8BaUbt5eDoXgLdDW50RCWF)RfqO95tNWigZX4H2hWZ7FTacTpXZMbii5GH4mKAvjHDbqIETeVCyh7GDbqcxBQKeCde696yhSp7toi3FiEqWILIirvAGaGD)4aqb24mzHCy8q7ZVuejQsdeE(MHEjGyHmEO9zsibbCgsTQK8K7bDWeSG3)AbeAFce9n9a7sTSwE9we6mPGBaUbtE4cYcTpi68X7wc3Uo)srKOknq4Hlil0(Wwxo49bx0WR3IqNjfCdWnykDcJymhJhAFapV)1ci0(epBgGGKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp54icMGflfrIQ0aba7(XbGcSXzYc5GtQec4mKAvj5j3d6GjybV)1ci0(ei6B6bC(GqTSwE9we6mPGBaUbtE4cYcTVD5Ld7)M7qeIyRlh8(GlA41BrOZKcUb4gmLoHXC29akhOB6k07nNDTDrOCGli9EZb)9VwaH2xoU2OlNyJquogIY56ih66Y7wo4TIOCWJ0abihdNPsRkPCIoNvrkXkhY9Go4C0BrOZK5Wna3GPCSdoN(KyLJRn6YXTvokNELZU2UiuokiN(YH3TeUDD(0jJhAFapV)1ci0(epBgGGKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5OaibytxHEVIN2fHWgNjlKJLIiqyOGqEe9n9amaNHuRkjp5Eqhmbl49VwaH2NarFtpWEiW7dUOHxVfHotk4gGBW0ECgsTQK8K7pepiyXsrKOknqayaodPwvs(JiycwSuejQsdeaiUhcmpmjDHhvos0lXt7IqyIjVBjC768OYrIEjEAxeYJOVPhaF4mKAvj5j3d6GjybV)1ci0(ei6B6bGiMyA8qXrc6OVsa85aNHuRkjpV)1ci0(eGnDf69kEAxecBD5G34OZUWF67wiwgLoz8q7d459VwaH2N4zZaeKCWWLIirvAGa7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyRlh8(GlA41BrOZKcUb4gmTN54mKAvj5xkIevPbcXt3s9E3dbCgsTQK8K7pepiyXsrKOknqaWNdCgsTQK8hrWeSyPisuLgiayIzTSwEE)RfqO95r030dWGxoS)BUJjM4mKAvj5j3d6GjybV)1ci0(ei6B6byGJAzT86Ti0zsb3aCdM8WfKfAFyIzTSwE9we6mPGBaUbtEqyCgzGBWeZAzT86Ti0zsb3aCdM8i6B6byWlh2)n3XetE3s4215bB6k07v80UiKhrgmw7Xzi1QsYxaKaSPRqVxXt7IqqCFTSwEE)RfqO95lp7HaZRL1YVuebIg99iY4bMywlRLxVfHotk4gGBWKhrFtpadWq)UbX9mVwwl)whcqGiJrpImESFRdbiqKXOa8qsjqONyj13Tas1YA53il07vuE8iY4bgacVCypI(MEa8HHqKbUjDcJ5a9Ho4CWl6ihObImgb5axq69Md(7FTacTVCSiNn9DlNhK2inWYNoz8q7d459VwaH2N4zZaeKCWWL0(eiqkJe26YbeQL1YV1HaeiYy0xE2B8qXrc6OVsa85aNHuRkjpV)1ci0(elP9jqGugjiIjMqOwwl)sreiA03xE2B8qXrc6OVsa85aNHuRkjpV)1ci0(elP9jqGugPDbvoA1OxYVuebIg9Hy6egZXTzWQDroqFmeJ5a26IeoNkLtbqW54sJTCSCWl6ihObImgZbrgmw5eDofaLJ()eSAbjXkhBfekNyJYHBGiNLEkyJa(CyYMcYXLkL5CwuqMuIvoakYP8KJLdErh5anqKXyoGh6ICwnkNyJYzPNjZbegNXC6voUndwTlYb6JHy0Noz8q7d459VwaH2N4zZaeKCWqKbR2fcWJHyeBD5OwwlpV)1ci0(8LN9UbdulRLFRdbiqKXOhrgpGuTSw(nYc9EfLhpImEaPToeGargJcWdjLaHEILuF3chUjDY4H2hWZ7FTacTpXZMbii5GHpyH6Q0ab26YrTSw(LIiq0OVV8Koz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5Owwl)whcqGiJrF5zFTSwEE)RfqO95lpPtgp0(aEE)RfqO9jE2mabjhm8bluxLgiWwxoEqeoXlh2VJhWBeFBFTSw(nYc9EfLhF5zVXdfhjOJ(kbyaodPwvsEE)RfqO9jws7tGaPms7RL1YZ7FTacTpF5jDcJ5S7b69Md0nDf69MZU2UiuoWfKEV5G)(xlGq7lNOZbrGOruo4TIOCWJ0aro2bNZUU10PUNdElTpLdFZqVeihUD5uPCQ0rlLRMe7CQLiNcOysjw50NeRC6lhNr7m7tNmEO9b88(xlGq7t8SzacsoyiytxHEVIN2fHWwxoWzi1QsYxaKaSPRqVxXt7Iq7RL1YZ7FTacTpF5zpZnEO95xkIevPbcpFZqVeyVXdTp)ZwtN6UyjTpb88nd9sagy8q7Z)S10PUlws7ta)3CxW3m0lbsNWyoqlxoot69czqo4rsaGEV58GAoiN(Yj2ifLt76YbS1fjCovkhysAyrW5SAuo7kwOMlnWpNhuZb54AJUCEAaqRsc7CQLiNo2iKlfq5WTlNkLtbqW5Oxo4V)1ci0(YX1gD5eBeIYXquoGYAPCLUih8wruo4rAGa4ZX5TYXYbA5YXzsVxidYbpsca07nNhuZZXvxKW5uPCkacg7CCBLJYPx5SRTlcLdyRls4CQuofabNZsrGihDLtSr5qURGqV3CCBLJYPx5SRTlcLJlvkZHC)rruoWfKEV5eBuoCde(0jJhAFapV)1ci0(epBgGGKdgIkhj6L4PDriS1LJAzT8GYjyuVxGOkjaqVxbImyS8LN9qaNHuRkj)remblwkIevPbcadCGZqQvLKNC)H4bblwkIevPbcaMyct1YA5)kc1iGOxIOrF6cF5bI7nEO4ibD0xja(CGZqQvLKN3)AbeAFIL0(eiqkJ0(AzT8GYjyuVxGOkjaqVxbImyS8i6B6bWh5oXlbjc9tqY4H2NFjTpbcKYi55gieH(P0jJhAFapV)1ci0(epBgGGKdgUK2NabszKWwxoQL1YdkNGr9EbIQKaa9EfiYGXYxE2dbCgsTQK8hrWeSyPisuLgiamWbodPwvsEY9hIheSyPisuLgiayIjmvlRL)RiuJaIEjIg9Pl8LhiU34HIJe0rFLa4ZbodPwvsEE)RfqO9jws7tGaPms7RL1YdkNGr9EbIQKaa9EfiYGXYJOVPhaFCdeIq)0EiWCEFWfn86Ti0zsb3aCdMWeZAzT86Ti0zsb3aCdM8i6B6bWh5oXlbjc9tyIzTSw(nYc9EfLhpImEaPToeGargJcWdjLaHEILuF3cg4giMoz8q7d459VwaH2N4zZaeKCWqu5irVepTlcHTUCulRLhuobJ69cevjba69kqKbJLV8ShcmpmjDH)bluZLg4JjM1YA5FWc1CPb(Eez8yFTSw(hSqnxAGVhrFtpa(i3jEjirOFcsgp0(8pyH6Q0aHNBGqe6NWetCgsTQK8hrWeSyPisuLgiamWbodPwvsEY9hIheSyPisuLgiayIjmvlRL)RiuJaIEjIg9Pl8LhiUVwwlpOCcg17fiQsca07vGidglpI(MEa8rUt8sqIq)eKmEO95FWc1vPbcp3aHi0pLoz8q7d459VwaH2N4zZaeKCWWhSqDvAGaBD5OwwlpOCcg17fiQsca07vGidglF5zpeyEys6c)dwOMlnWhtmRL1Y)GfQ5sd89iY4X(AzT8pyHAU0aFpI(MEa8Xnqic9tyIjodPwvs(JiycwSuejQsdeag4aNHuRkjp5(dXdcwSuejQsdeamXeMQL1Y)veQrarVerJ(0f(Yde3xlRLhuobJ69cevjba69kqKbJLhrFtpa(4gieH(P9qG58(GlA41BrOZKcUb4gmHjM1YA51BrOZKcUb4gm5r030dGpYDIxcse6NWeZAzT8BKf69kkpEez8asBDiabImgfGhskbc9elP(UfmWnqmDcJ5SRyHAU0a)CEqnhKdyRls4CQuofabNJE5G)(xlGq7lhlYztF3iuopiTrAGvoXMD5SRBnDQ75G3s7tGCSdohO8gX38Ptgp0(aEE)RfqO9jE2mabjhm8bluxLgiWwxoQL1Y)GfQ5sd89iY4X(AzT8pyHAU0aFpI(MEa8Xnqic9t7RL1YZ7FTacTppI(MEa8Xnqic9t7nEO4ibD0xjadWzi1QsYZ7FTacTpXsAFceiLrApeyoVp4IgE9we6mPGBaUbtyIzTSwE9we6mPGBaUbtEe9n9a4JCN4LGeH(jmXSwwl)gzHEVIYJhrgpG0whcqGiJrb4HKsGqpXsQVBbdCdetNWyo7EaLZUU10PUNdElTpbYXo4CGYBeFlh9Yb)9VwaH2xorNZgjFY5LoczbLdErh5anqKXiihxB0LdERikh8inqaYXquoxh5y4mvAvjLtJY5icoNOZPs5W7dqiCeSpDY4H2hWZ7FTacTpXZMbii5GHpBnDQ7IL0(eaBD5OwwlpV)1ci0(8LN9bYWrsrOFIb1YA559VwaH2NhrFtpW(AzT8BKf69kkpEez8asBDiabImgfGhskbc9elP(UfmWnPtgp0(aEE)RfqO9jE2mabjhmeWBeFdBD5OwwlpV)1ci0(8i6B6bWh3aHi0pLoHXCCERCIncr5OGdYro01L3TCc9t5iPvKJE5G)(xlGq7lNvJYXYzx3A6u3ZbVL2Na50OCGYBeFlNOZztJC0dOWuo9kh83)AbeAFyNtbq5a6pfB69MdjbKpDY4H2hWZ7FTacTpXZMbii5GHsfNEVIA)RyRlh1YA559VwaH2NhrFtpadE5W(V5(EJhkosqh9vcGVDsNmEO9b88(xlGq7t8SzacsoyimYE7diQiYInS1LJAzT88(xlGq7ZJOVPhGbVCy)3CFFTSwEE)RfqO95lpPtPtyeJ5GxqYhcLdodPwvs5eBwKdVVW0dKtSr5y8OyYCiqOFli4Cc9t5eBwKtSr5CK7ro4V)1ci0(YXLkL5uPCqKbJLpDcJymhJhAFapV)1ci0(eH(171bodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KdE)RfqO9jqKbJLi0pHnotwih8ULWTRZZ7FTacTppI(MEama5(dXdcwWOEWs9EficUWdTV0jmIXCyYgLd3aroH(PC6voXgLd4HKYCInlYXLkL5uPCEqe3aro6fDo4V)1ci0(8PtyeJ5y8q7d459VwaH2Ni0VEVqYbdXzi1Qsc7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyF2NCW7FTacTpXdI4gieH(jSXzYc5acgp0(8lfrvtk9CdeIq)egG58(GlA4xs7tcJZruO9bjJhAFEaVr8np3aHi0pbjEFWfn8lP9jHX5ik0(GigacgpuCKGo6ReGb4mKAvj559VwaH2NyjTpbcKYibriz8q7ZVK2NabszK8CdeIq)egacgpuCKGo6ReaFoWzi1QsYZ7FTacTpXsAFceiLrcI7codPwvsEE)RfqO9j4giei6B6bsNWigZX4H2hWZ7FTacTprOF9EHKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5i0pjIwW7FTacTpSXzYc5aNHuRkjpV)1ci0(eiYGXse6NsNWigZXzrsdRCWF)RfqO9LZQr5yRGq5G3kIaHHccLt5KeaKdodPwvs(LIiqyOGqcE)RfqO9LJcYbqHpDcJymhJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKJLIiqyOGqEe9n9ayRlhHjPl8lfrGWqbH2ZCCgsTQK8lfrGWqbHe8(xlGq7lDcJymhNfjnSYb)9VwaH2xoRgLJBZGv7ICG(yigZrx5OroUuPmhE)PC61khE3s421LdO7ZNoHrmMJXdTpGN3)AbeAFIq)69cjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYrOFseTG3)AbeAFy3po(M7yJZKfYbVBjC768idwTleGhdXOhrFtpa26YbVXrNDHNrSqQD75DlHBxNhzWQDHa8yig9i6B6b2LDWqgGZqQvLKp0pjIwW7FTacTV0jmMJZIKgw5G)(xlGq7lNvJYXztrOgbYPx5WKg9Pl8PtyeJ5y8q7d459VwaH2Ni0VEVqYbdXzi1Qsc7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyF2NCe6Nerl49VwaH2h29JJV5o24mzHCW7wc3Uo)xrOgbe9sen6tx4r030dGTUCWBC0zx4XrxSHfApVBjC768FfHAeq0lr0OpDHhrFtpWU4MDJb4mKAvj5d9tIOf8(xlGq7lDcJymhNfjnSYb)9VwaH2xoRgLJZISyR2OJ8PtyeJ5y8q7d459VwaH2Ni0VEVqYbdXzi1Qsc7cGe9AjE5Wo2b7cGeU2ujj4gi071XoyF2NCe6Nerl49VwaH2h29JJV5o24mzHCW7wc3UopmzXwTrh5r030dajiulRLhMSyR2OJ8WfKfAF7sTSwEE)RfqO95Hlil0(GigavoA1OxYdtwSbell26p26YbVXrNDH)ioQLncEpVBjC768WKfB1gDKhrFtpWUSdgYaCgsTQK8H(jr0cE)RfqO9LoHrmMJZIKgw5G)(xlGq7lNvJYXzrwSbzqo4TfB9phqyCgb5ORCIncr5yikhlYrsgiYjC15eg6LcGpDcJymhJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKJAzT8WKfB1gDKhrFtpWUulRLN3)AbeAFE4cYcTpS1Ldu5OvJEjpmzXgqSSyR)7RL1YdtwSvB0r(YZEJhkosqh9vcGphUjDcJymhNfjnSYb)9VwaH2xoRgLtSr54m)FWcrMmh8se8zhNYPwwRC0voXgLZJ0WIq5OGCka9EZj2SiNaPhJu4tNWigZX4H2hWZ7FTacTprOF9EHKdgIZqQvLe2faj61s8YHDSd2fajCTPssWnqO3RJDW(Sp5i0pjIwW7FTacTpS7hhFZDSXzYc5aNHuRkjp9FWcrMu0i4ZoojGjPH1UabE3s4215P)dwiYKIgbF2XjpCbzH23UW7wc3Uop9FWcrMu0i4Zoo5r030darmaZ5DlHBxNN(pyHitkAe8zhN8iYGXcBD5GWRf95HG90)blezsrJGp74u6egXyoolsAyLd(7FTacTVCwnkNDxPbRw0iqo4XGFjSZPCscaYrJCC1fjCovkhysAyrW5i77Lq5eB2LJBWWCaeVpyGpDcJymhJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKdE3s4215FLgSArJaIQb)scmOBF3CJBC(9i6B6bWwxoi8ArFEiy)R0GvlAequn4xApVBjC768VsdwTOrar1GFjbg0TVBUXno)Ee9n9a7IBWqgGZqQvLKp0pjIwW7FTacTV0jmIXCCwK0Wkh83)AbeAF5uUqL5G)(xlGq7lhY9hfrGC0voAazqoLhF6egXyogp0(aEE)RfqO9jc9R3lKCWqCgsTQKWUairVwIxoSJDWUaiHRnvscUbc9EDSd2N9jhH(jr0cE)RfqO9HD)44BUJnotwih1YA559VwaH2NhrFtpq6egXyoolsAyLd(7FTacTVCkxOYCCB9UMd5(JIiqo6khnGmiNYJpDcJymhJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKJAzT8OYrIEjEAxeYJOVPhaBD5imjDHhvos0lXt7Iq7RL1YZ7FTacTppC76sNWigZXzrsdRCWF)RfqO9LZQr5yxoK7bYYXTvokNELZU2Uiuo6kNyJYXTvokNELZU2UiuoU6IeohE)PC61khE3s421LJf5ijde5SB5aiEFWGCQ0Qruo4V)1ci0(YXvxKW(0jmIXCmEO9b88(xlGq7te6xVxi5GH4mKAvjHDbqIETeVCyh7GDbqcxBQKeCde696yhSp7toc9tIOf8(xlGq7d7(XX3ChBCMSqo4DlHBxNhvos0lXt7IqEe9n9aqQwwlpQCKOxIN2fH8WfKfAFyRlhHjPl8OYrIEjEAxeAFTSwEE)RfqO95HBx3EE3s4215rLJe9s80UiKhrFtpaK2ngGZqQvLKp0pjIwW7FTacTV0jmIXCCwK0Wkh83)AbeAF5ORCCwkGRps9mew5G)()TdohxDrcNZ1rovkhezWyLZQr5OroyrHpDcJymhJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WUFC8n3XgNjlKdE3s4215RL1saRaU(i1Zqyj49)BhShrFtpa26YbQC0QrVKhwbC9rQNHWsW7)3o491YA5HvaxFK6ziSe8()Td2d3UU0jmIXCCBMcNJZmo6cGZLJZIKgw5G)(xlGq7lNvJYXGHZb8yUoqo9khmyonkNFJOCmyyqoXMf54sLYCKgiYr23lHYj2SlND2TCaeVpyGphMSrakhCMSqGCmeDqoY5iobagsLyLt)e63K5OxoMuMd3aeWNoHrmMJXdTpGN3)AbeAFIq)69cjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYrOFseTG3)AbeAFy3po(M7yJZKfYbYuybHJUWBWWaVEyRlhitHfeo6cVbdd8K7kia7rMcliC0fEdgg45D5c85adUhzkSGWrx4nyyGhUGSq7dF7SBPtyeJ542mfohNzC0faNlhNH0LHfiNcGYb)9VwaH2xoU0ylhCf5riRQsnWkhKPW5q4OlayNtJJqifMYXoSYbMKgwGCKkii4CSAJJYj6C(gJuoGcIYrJCEPaKtbqW5SriYNoHrmMJXdTpGN3)AbeAFIq)69cjhmeNHuRkjSlas0RL4Ld7yhSlas4AtLKGBGqVxh7G9zFYrOFseTG3)AbeAFyJZKfYbYuybHJUWJRipczvj51ddWCKPWcchDHhxrEeYQsYxEWwxoqMcliC0fECf5riRkjp5UccWECgsTQK88(xlGq7tGidglrOFIbitHfeo6cpUI8iKvLKxV0jmIXC29akNyJY5i3JCWF)RfqO9LtF5W7wc3UUC0voAKJRUiHZ56iNkLd5(dXdcoNOZbMKgw5eBuoa(gbxKeCo9r50OCInkhaFJGlscoN(OCC1fjCoB2ZdD5ijaiNyZUCCdgMdG49bdYPsRgr5eBuol9DlYHoyGpDcJymhJhAFapV)1ci0(eH(17fsoyiodPwvsyxaKOxlXlh2XoyxaKW1Mkjb3aHEVo2b7Z(KJq)KiAbV)1ci0(WgNjlKdCgsTQK88(xlGq7tGidglrOFcBD5aNHuRkjpV)1ci0(eiYGXse6NGeVBjC7688(xlGq7ZdxqwO9HbGWo7ceWqpthKWqVBWaHjPl8lfrGWqbHGigimjDHNr9GL69crg4aNHuRkjFOFseTG3)AbeAFyIjodPwvs(q)KiAbV)1ci0(W3sF3cbI(MEGDXnyy6u6KXdTpGh1pINndqows7tGaPmsyRlhgpuCKGo6ReaFoWzi1QsYV1HaeiYyuSK2NabszK2dHAzT8BDiabImg9LhmXSwwl)sreiA03xEGy6KXdTpGh1pINndqqYbdxkIQMuITUCulRLhMSyR2OJ8LN9OYrRg9sEyYInGyzXw)3JZqQvLKp0pjIwW7FTacTpgulRLhMSyR2OJ8i6B6b2B8qXrc6OVsa85WnPtgp0(aEu)iE2mabjhmCjTpbcKYiHTUCy8qXrc6OVsa85aNHuRkj)MHGfCdeIL0(eiqkJ0(AzT8GYjyuVxGOkjaqVxbImyS8LN91YA5bLtWOEVarvsaGEVcezWy5r030dGpUbcrOFkDY4H2hWJ6hXZMbii5GHpyH6Q0ab26YrTSwEq5emQ3lquLeaO3Rargmw(YZ(AzT8GYjyuVxGOkjaqVxbImyS8i6B6bWh3aHi0pLoz8q7d4r9J4zZaeKCWWhSqDvAGaBD5Owwl)sreiA03xEsNmEO9b8O(r8Szacsoy4dwOUknqGTUCulRLFRdbiqKXOV8KoHXC29akN(OCWBfr5GhPbICidjXkh9YXT17Ao6khS6soW9b5iNndhLdPXgHYbVGSqV3C29p50OCWl6ihObImgZblkYXo4Cin2iKZLdemiMZMHJY53ikNyZUCcxDoMergmwyNdeQqmNndhLJZqsUdcKbyAXGmih8UGWkhezWyLt05uae250OCGahI5aLmKEV5WKUW3Yrb5y8qXr(CCw9b5ih4oNytb54AtLuoBgcohUbc9EZbVL2NabszKa50OCCTrxoqlxoot69czqo4rsaGEV5OGCqKbJLpDY4H2hWJ6hXZMbii5GHlfrIQ0ab2faj61s8YHDSd2fajCTPssWnqO3RJDWwxoyoodPwvs(LIirvAGq80TuV391YA5bLtWOEVarvsaGEVcezWy5HBx3EJhkosqh9vcWaCgsTQK8BgcwWnqiws7tGaPms7z(sreimuqiVXdfhThcmVwwl)gzHEVIYJV8SN51YA536qacezm6lp7z(dIWj61s8YH9lfrIQ0aXEiy8q7ZVuejQsdeE(MHEja(C4gmXecHjPl8MKCheidW0IbeRccR98ULWTRZdJS3(aIkISyZJidgliIjMaYq69kIUW38gpuCeeHy6egZz3dOCWBfr5GhPbICin2iuoWfKEV5y5G3kIQMuYWDfluxLgiYHBGihxB0LdEbzHEV5S7FYrb5y8qXr50OCGli9EZHCN4LGYXLgB5aLmKEV5WKUW38Ptgp0(aEu)iE2mabjhmCPisuLgiWUairVwIxoSJDWUaiHRnvscUbc9EDSd26YbZXzi1QsYVuejQsdeINUL69UN5lfrGWqbH8gpuC0(AzT8GYjyuVxGOkjaqVxbImyS8WTRBpeGaemEO95xkIQMu6j3jEj07DpemEO95xkIQMu6j3jEjibI(MEagGH(DdtmzoQC0QrVKFPicen6drmX04H2N)bluxLgi8K7eVe69Uhcgp0(8pyH6Q0aHNCN4LGei6B6byag63nmXK5OYrRg9s(LIiq0OpeH4(AzT8BKf69kkpEez8aIyIjeaKH07veDHV5nEO4O9qOwwl)gzHEVIYJhrgp2ZCJhAFEaVr8np5oXlHEVyIjZRL1YV1HaeiYy0JiJh7zETSw(nYc9EfLhpImES34H2NhWBeFZtUt8sO37EMV1HaeiYyuaEiPei0tSK67waricX0jJhAFapQFepBgGGKdgYnPuy8q7tivqG9zFYHXdfhjctsxasNmEO9b8O(r8Szacsoy4dwOUknqGTUCulRL)bluZLg47rKXJ9CdeIq)edQL1Y)GfQ5sd89i6B6b2Znqic9tmOwwlpQCKOxIN2fH8i6B6b2dbMJkhTA0l5bLtWOEVarvsaGEVyIzTSw(hSqnxAGVhrFtpadmEO95xkIQMu65gieH(jiXnqic9tyGAzT8pyHAU0aFpImEaX0jJhAFapQFepBgGGKdg(GfQRsdeyRlh1YA536qacezm6lp7bKH07veDHV5nEO4O9gpuCKGo6ReGb4mKAvj536qacezmkws7tGaPmsPtgp0(aEu)iE2mabjhm8zRPtDxSK2NayRlhmhNHuRkj)ZwtN6U4PBPEV7HGXdfhjG7WRVNgedCdMyA8qXrc6OVsa85aNHuRkj)MHGfCdeIL0(eiqkJeMyA8qXrc6OVsa85aNHuRkj)whcqGiJrXsAFceiLrcIPtgp0(aEu)iE2mabjhmeWBeFdBD5aqgsVxr0f(M34HIJsNmEO9b8O(r8SzacsoyimYE7diQiYInS1LdJhkosqh9vcGp3Koz8q7d4r9J4zZaeKCWqdXTJeK7pYgO9HTUCy8qXrc6OVsa85aNHuRkjVH42rcY9hzd0(2)TZ8p8aFoWzi1QsYBiUDKGC)r2aTpX3oBFyOxk8U0ytVDWW0jmMdtVgB5qxxE3Yjm0lfaSZrJCuqowoVME5eDoCde5G3s7tGaPms5yGCwQusOC0deKbNtVYbVvevnP0Noz8q7d4r9J4zZaeKCWWL0(eiqkJe26YHXdfhjOJ(kbWNdCgsTQK8BgcwWnqiws7tGaPmsPtgp0(aEu)iE2mabjhmCPiQAsz6u6KXdTpGhe2bBiybQdl0(CSK2NabszKWwxomEO4ibD0xja(CGZqQvLKFRdbiqKXOyjTpbcKYiThc1YA536qacezm6lpyIzTSw(LIiq0OVV8aX0jJhAFapiSd2qWcuhwO9bjhmCPiQAsj26YrTSwEyYITAJoYxE2JkhTA0l5Hjl2aILfB9FpodPwvs(q)KiAbV)1ci0(yqTSwEyYITAJoYJOVPhyVXdfhjOJ(kbWNd3Koz8q7d4bHDWgcwG6WcTpi5GHpyH6Q0ab26YrTSw(LIiq0OVV8Koz8q7d4bHDWgcwG6WcTpi5GHpyH6Q0ab26YrTSw(ToeGargJ(YZ(AzT8BDiabImg9i6B6byGXdTp)sru1Ksp5oXlbjc9tPtgp0(aEqyhSHGfOoSq7dsoy4dwOUknqGTUCulRLFRdbiqKXOV8ShcpicN4Ld73XVuevnPetmxkIaHHcc5nEO4imX04H2N)bluxLgi86jws9DlGy6egZHjiSYj6CEPihOot4jNhuZb5OhqHPCCB9UMZZMbiqonkh83)AbeAF58SzacKJRn6Y5PbaTkjF6KXdTpGhe2bBiybQdl0(GKdgUK2NabszKWwxomEO4ibD0xja(CGZqQvLKFZqWcUbcXsAFceiLrAFTSwEq5emQ3lquLeaO3Rargmw(YZEiW7wc3UopQCKOxIN2fH8i6B6bGKXdTppQCKOxIN2fH8K7eVeKi0pbjUbcrOFcF1YA5bLtWOEVarvsaGEVcezWy5r030dGjMmpmjDHhvos0lXt7IqqCpodPwvs(q)KiAbV)1ci0(Ge3aHi0pHVAzT8GYjyuVxGOkjaqVxbImyS8i6B6bsNmEO9b8GWoydblqDyH2hKCWWhSqDvAGaBD5Owwl)whcqGiJrF5zpGmKEVIOl8nVXdfhLoz8q7d4bHDWgcwG6WcTpi5GHpyH6Q0ab26YrTSw(hSqnxAGVhrgp2Znqic9tmOwwl)dwOMlnW3JOVPhypeyoQC0QrVKhuobJ69cevjba69IjM1YA5FWc1CPb(Ee9n9amW4H2NFPiQAsPNBGqe6NGe3aHi0pHbQL1Y)GfQ5sd89iY4betNWyooRcsV3CInkhqyhSHGZb1HfAFyNtFsSYPaOCWBfr5GhPbcqoU2OlNyJWkhdr5CDKtL07nNNULeCoRgLJBR31CAuo4V)1ci0(85S7buo4TIOCWJ0aroKgBekh4csV3CSCWBfrvtkz4UIfQRsde5WnqKJRn6YbVGSqV3C29p5OGCmEO4OCAuoWfKEV5qUt8sq54sJTCGsgsV3Cysx4B(0jJhAFapiSd2qWcuhwO9bjhmCPisuLgiWUairVwIxoSJDWUaiHRnvscUbc9EDSd26YbZxkIaHHcc5nEO4O9mhNHuRkj)srKOknqiE6wQ37(AzT8GYjyuVxGOkjaqVxbImyS8WTRBpeGaemEO95xkIQMu6j3jEj07DpemEO95xkIQMu6j3jEjibI(MEagGH(DdtmzoQC0QrVKFPicen6drmX04H2N)bluxLgi8K7eVe69Uhcgp0(8pyH6Q0aHNCN4LGei6B6byag63nmXK5OYrRg9s(LIiq0OpeH4(AzT8BKf69kkpEez8aIyIjeaKH07veDHV5nEO4O9qOwwl)gzHEVIYJhrgp2ZCJhAFEaVr8np5oXlHEVyIjZRL1YV1HaeiYy0JiJh7zETSw(nYc9EfLhpImES34H2NhWBeFZtUt8sO37EMV1HaeiYyuaEiPei0tSK67waricX0jJhAFapiSd2qWcuhwO9bjhm8bluxLgiWwxoQL1YV1HaeiYy0xE2B8qXrc6OVsagGZqQvLKFRdbiqKXOyjTpbcKYiLoz8q7d4bHDWgcwG6WcTpi5GHpBnDQ7IL0(eaBD5G54mKAvj5F2A6u3fpDl17DpeyEys6c)c1FrSrcdSramX04HIJe0rFLa4BhiUhcgpuCKaUdV(EAqmWnyIPXdfhjOJ(kbWNdCgsTQK8BgcwWnqiws7tGaPmsyIPXdfhjOJ(kbWNdCgsTQK8BDiabImgflP9jqGugjiMoz8q7d4bHDWgcwG6WcTpi5GHCtkfgp0(esfeyF2NCy8qXrIWK0fG0jJhAFapiSd2qWcuhwO9bjhmegzV9bevezXg26YHXdfhjOJ(kbW3oPtgp0(aEqyhSHGfOoSq7dsoyiG3i(g26YbGmKEVIOl8nVXdfhLoz8q7d4bHDWgcwG6WcTpi5GHgIBhji3FKnq7dBD5W4HIJe0rFLa4ZbodPwvsEdXTJeK7pYgO9T)BN5F4b(CGZqQvLK3qC7ib5(JSbAFIVD2(WqVu4DPXME7GHPtymhMEn2YHUU8ULtyOxkayNJg5OGCSCEn9Yj6C4giYbVL2NabszKYXa5SuPKq5OhiidoNELdERiQAsPpDY4H2hWdc7GneSa1HfAFqYbdxs7tGaPmsyRlhgpuCKGo6ReaFoWzi1QsYVziyb3aHyjTpbcKYiLoz8q7d4bHDWgcwG6WcTpi5GHlfrvtkzd2GLf]] )
end
