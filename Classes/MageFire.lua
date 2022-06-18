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
            max_stack = 1,
            meta = {
                expiration_delay_remains = function()
                    return buff.sun_kings_blessing_ready_expiration_delay.remains
                end,
            },
        },

        sun_kings_blessing_ready_expiration_delay = {
            duration = 0.03,
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

    -- # APL Variable Option: How much delay should be inserted after consuming an SKB proc before spending a Hot Streak? The APL will always delay long enough to prevent the SKB stack from being wasted.
    -- actions.precombat+=/variable,name=skb_delay,default=-1,value=0.1,if=variable.skb_delay<0
    spec:RegisterVariable( "skb_delay", function ()
        return 0.1
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

    local ExpireSKB = setfenv( function()
        removeBuff( "sun_kings_blessing_ready" )
    end, state )






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
                        -- removeBuff( "sun_kings_blessing_ready" )
                        applyBuff( "sun_kings_blessing_ready_expiration_delay" )
                        state:QueueAuraExpiration( "sun_kings_blessing_ready_expiration_delay", ExpireSKB, buff.sun_kings_blessing_ready_expiration_delay.expires )
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


    spec:RegisterPack( "Fire", 20220618, [[Hekili:S3ZAZTTrs(BXvkZiAlrlsBf7Kssx51ooB8LnXvu2hFsuGGdfXjqaE4HKvkv83(nDpVFcqk5e7Rsv7gBtamtp90t)U758XN)BNF28KgY5)8KdNm5WVz8Rgn(LJN88V98ZAUDn58ZwNKEvYL0)srYk6)9Dzv4pEBEzYC4JRlBRsP)0YMM11F3ZE2LznlBNnkTC1ZQZw1MN0KvwKwLSOb(3Pp78ZM1ML38JfNpZ)m)YZplPTzzz15NDw2Q3qh5S5ZjSxNuNYaHnx8pOa1M333zDZ7FFBb9Rg)Q93CbmFBE)M3)MLjfxsQ)UnV)Gnx8pRPpEr2LlBMwrwLKvuV5IQKMLKQnx0qFr6)nP6ssZOMSvKPnLtNNbFqj9X5j1nhutsllMV5IKzz5zn3U5I2Akewpch8FQSSMqhIu6BshwY)BlDnSIu0uZhI3uUAwBna0BUyVSrKruWCEzXxtF7LL50HnRH)Mj0)SIuVKIbine4xGbDiBE((IKz5uWQUPklL(fPljPxLvC5MlGbg(uYn44CfDIZG10s6B)6p8t0)wjayZBtP)Wn0xa2Fzd6RN))0cGn9Z)WTvLZYXfbf4RUfrnnaOsOdyrj9VUQCojNoeK8Cyko4skzdDnr3fOVmPUHa4Og4LPGz2LfzlYstkO)WB)Wz0pyfLEtSAEtzX1KkyMHXAw7IfJ(pJQijP8PpdMuaU5pQDnfRb7uj5RkbyKUj6mdxMaRB4)tbj(2dU3VmPAEkf4PW31jvzaIS2eT8Mp8p1WnNFwEwDtnCgivU7nD9YKAc93(z8Kfb3pMF(F78ZkxtpRqAOe3PWlE(zIjHrwxLTM9ZFpDCwrpwaB809Q8sy3tN84MmaBW2eacZR4q5zT0h(Ft3S)A6p83OaFnUXdpAoLsPAvwHyqzNG(BWyqF36LLTaj2mcq0sGv21j5Te4KkfVQwCJKhmEkhNR9S5Tvjma8j0TBkPxjLUT8McVF)XUFV8zdp)mkumTCXIPxMohqKaQAkJ9d5JnKc6E0unuo)lzF2nlZYjtHJe0vp8Xnu(lwBfEFpZDHxpFEn)0HAHvUG)tbq167saAhFxcWuq(LPTvveGwu)DZKpf3uVHTDut530GtpBFCzwT(NnIrsLmFoL(RkJUbNLC(zvuUC0J3xsgv3wmfo6xpDghahXrbBUyaUdH7aUVgfFMm)w6HPnxC3DQZcJIG63CXP0dwPZniqgp6iKwa(9vjFuqxeywHxzkDjNE1Mloi8BXFJHizcNkvcH1xnBQy3YLiY9Cx)iROeqp3IaYGu5xyYie071cEI2hRGtUnln35fVtzr(TUVjYklTPnj38RyKjjaHfYYL)2bPlxxvMosHasPStNY(htbwyu(sO4celPiL69gFa8pm0C0R2hkrtaE9fw41WqO2Gb)(1ujWj5G8tyyok4WuKsYNc0s6lShrX7KMPZklARPsZjvtE10xSofpw4WvJcQQheMGKIgMGVhdSgbNdPuFtxxEdPY4GNKVO5ROZACYHmwV8fS7SArb(JlcU1JGh9xsag(lPA3Spq(aOfKLZkGOJYVGyrwwkiIJXUdiRWrJr5wNSGauXuX)j3cl22IMm60q1bJuzlcJQFxlOjuw9vmUJKpUoJr5mc2s)MaBPlYPOeGC9kB5MasWGPAnOwYnf7dakHDKPUCfHYhfaEXYgPMsAWFlRzKoDsqAHUeTbt2uqnr8T50RKcYkuHLtpr7iJ2jd9Lgfd8slmqpGRUzO35lPFU2Cze)7uBFtX9Ffdc6Q9q1(3AHcKWs8v74segKu6GSsOmOVh4zDeam(2Thm2okGhbFqX8wk9fUjtzTLwrWpsmTkcCQQzZOS)aaB8HFcHm1uwNwwLUeNqBLw9RPKcmww2qfAt3fUAA9AQg)1tZaczWkk2oFCMQYJbcBQs1oaFS873drHkvBMNvNMTopRiP6w4twrffQ4XckTGZO3xtOwtW3y6IkQTdItl9NDoYW27uINqqDw8SwUKYcm)2PzPzPGOw9fXCccKMVbax6JuA510pIcIfK0QY8Yk(hlHR5eQrSZkRkik6afcq9WGdm9pAwEBL1WUkRQQSQgqknLvRqKKudEXWWOWgTcnuDKgPXGGptX444a8jrkyJLcFOy0XuwrK0wgd9b(FgzQ(jITAoehp9plwp9Empsgu(Ni7hFpMjnXobwuoVW2oBESOtQIM8BSeN7tlzn9JxseoVqkChe4lm8Frwrw9sWuwGRMT9FIj34uT18)RO7Iant(a8un9Cyqa4abBB4YAmu7ywBJWSnx98NxcJp3Ypqre41w5Ojgtgc6JdQcelqVavvUs6sk23EJc)WEk8SZ(V)BMJvEcLRTRgoM82C5nVBQ)d4DBZM6sAIMCYSIfKQIKC4nttMtm45(iTjfoYnfpkqxaL5cAxgpm)Q5RXB1dxmgcqYHmOgpQ3l2r2HEfaYfU8i(tG1qnm)A6ZiEMscR2dJk2v4BMLeuT2PTRfFjZaCd70pfLXoKz2r4JPkSS1XK)Tqt(FKVHrj5y7y0dam3g2coxZ0JtYJV3c0UOxox1wKsnIfigQ522YER3jqoQZwSt12gp6N6kXXQFPJ4ueEkHOOiOfjeF(GcD2aBVkPQXYMT(DCza31y9GixBaxtsBOdOAtWAkliK52pxxuECLymeRhWO0t77cCO6irFS5PEz2cKi1hly0RSNXFdjFyH)WmSNuqpHw0b)h0ViKIY2lxAt8LCDswoaim(QlAZbEYSvfWxxqhZ3u4eJmo3SjYr2aqyIoMrGg19TeqizTobYxBNw0fZXqenFzYrCVojWniz8rHlbOaw6i97y)9IjOYjoKoNmvobwoToVd3vqhJUck8RfegLupMulc7h05j4st1HOM9IiTPFG6HG7Ch(5TSj4C1275OZwJN8)7alJZqiV2pBgWHyGp0aLoZkPNmV1qBQ9CrlCSFFzhQbJswP75STDFg0d0T9unKsHbdrCOTVNKkmNmpJkMKUXMuDLTcZSNrrHWdd7(7edmneCnK6gyfJAkKTAfHosnOVe5(oul4iCn7RhT5IFdvTMfoSIKg6juKtoLfhDOw7otuYra(WOOIJiDSag98ZTa)CZfruVbY3fMGKUbooeMC)PDCq5eGKh2k6Whz6ufbCV14o8VLl5Q7snWqpjSdQOMLDnCuD0yUT3QrwdBeGuoGvLguYBfCA7xlXB1H(hihGEPbclmXWoHPYUCTh(WYssrgLp)7YXWHNUeYLGAnRkzM3LMLKlSCSTULrqZu9aMLxx(9J8gIgFYdIA3HMdly8ohjbjnVmWGAoEx9ghh6nGy4XFleTVlgEd(XpEOSmS3fyTSVhvYCz)qxROBcebBL8XSA2(QZhZ4PG(0MOhbwoxix(cpCoDx4HfMH)p1Rxy84y(WbtQZVFhKJGBU2w3)jdLCVb3EmF9n(f2ibBJq)KHecrxO0XExOk881HoLcRwBBw(KTA)Kh6PjHutu9wMSL(Gi0smEq1(4Wy7tqH(IalfHgJcp3zkrOMlN4mMBQDWS7AeV8kfO)NT6PC49mcXvyVA0ddnCO0LFZ2RdfZqmuJ2jH0O1uaMphqeBJYDlh0dyjjNsVFjflwH5XLPHfkVAP5scPll0CobOMky3RW9VigUMuDnMHwDQyAtvY1KCowmw(w5rTSTabJy3(hixV0E(cf5eBTwfVsE21auoJoME0Cq6mD0PIchaXqc5KfnU7yIKQ0zFg(DX2mUTIU3VOoBoxzb1OSp32fT8lGKxtIUn51na(KVT5cmj2EE)dgCOHoM(YZRsUKsEnDwfesWZbMKuS7IK28gFzZOHt77xKz1d6tBb9RrckF5NxV0o)FXzmjYufkdjmVjzhXy5KLJQ7mf7uCS9L8lGrLmjl9kG7r0KgCN0yHg37fI3NUWrxtizECrfJfduYug8R5llFzRwspSE)mkZcBZFDsnzHLjLa29MSAIWK9gh3F2de3EDe))tf4wzoJHUV4iol9q5oMkK2wlX3kFGs2Ds(nj3wVjso6nAZf)B8NWphmg5D0)SC1(SLTRsaKKk0leYuOsFEz0FlrKnlyFIe0Y1OY(Hf9ONxptVc)Y25HtvPNPJINcczTChq5D0dC5YOE4q0xjAClGrOE6ceHkztejH(CDoTpj2)d2BXys)BS3ZZgRxdPF4WuE43cBmXsUToxEVoVw4Mm)lYm0Bcn3qigs5avmQf5so83CZNCu7dgHPqDdzI8TQfKbImdSsrUD5a8Zp0ImGQl)I2Cq5DqTcD6aBT26rIB)oak)xSuwriwoXYLmmg0QZC(XLm)nciJKRlZMd)W6147ZzWpYF8rvyhUObpHuXmrlGqqrTAHnSCYNdKswc(5MPHXlecAIQY2aVEVNQiGN0XtS4Umhel0aWWSK5qPaD)iaoIollwqsfj0RZ47jN8eWczf1Ihcv6zz18cipw7nWyKoroddZ0XU5AEAFge2AKNz5oaSVe7tPXtcfnrMtF7zgSbs1JYq)xNXyxXdsLvjpDChdV)OmHC24R4qRbF5xOKeRkB1usAE266TBh9v7WIqaOgtAS8eAvzzrEwdffMvVARaVJUhGN5S6lFAuhqVD9savNuxNTklNNa(PorMYNceXj31jMOeradykNNYflScRQ1ZyPU5qjM2la6ljoKO8K0eQPitRxsintx1wNLUDiEjw0Za5l87ows2YC4CcOIgPcfauwCaxFxcO)Nq5r83ElyYWcukZ)Iuxd5xFzBJpJfPAu(lcfO3x6yOSFNiNtpJLBPJWIka4nBNuVHzdJ0TlOdls4fKOmHBaj85yYYvETmgBEQ1jK2vgTTeSUOaKYkSO8WSIzJQANum6HbW3cbD)X8YmvnnLMKNYRytaSstKgvapTTayFsx0PCHX11TyoXHkxN14Au3AsfiDre0enRsyKeZfq10RrG6ZHtkclI8BIipcLbZobTANcMRE7moFYjyWN1ZdikmdmJFDjKyHqYzyWK7XBUqlhG10aaknSdfLWLY9dw7jXcLFn1MRPqHD2aEfO)IgH9iU2N7fEhrM2b8OVdjqfvpXRGs)D8OS6r6tp3vBYhtpJnlNy)RQ0RsGD4BtY3zs8bEI3bEINbEOzQFbvA861K5JSrWwPCI9JnCu3rASYnW9XYvGWfFv30MdeUS7yPi075bdZcQsUgy0E6S()TQSlVe9De9LO8wf7gCZ6z8H9WXfm7GXBdzjbgzX14AK344BkVHkqPEJSwQ5wJjZ4xF5cnl3kvm9ciSHfecWVKu4HY0TrYfKU5Mw12aa00)32KIM2vu9xVoZuLAj9JTs6gmS(JMBPIklYQWxQpiTxdldhQcjZsAAY)IyfZ21SbCFjHHyrEtYvqmiQHkAPy(xoRrl4ow(Bq3(BQAtXfWCiWauRWbNk)fZAn0ciw2tu3wmlVSC(0eiAd3A6ZHpVxUUGUVmjqUqtty(9ybeinKXoe1Xfe3iph6nN(ctBtdoI9iy()HI0uyb4jGfh1EdbVKJgu1AtlkVoXNlrFxfQP)ptFmxzDHyUFaRUmQinw5LPVO7Si1c4iGD27(DQY5U5j2Hrd4VrWOmrD)aKjHOznVvlUwO41vOrvWQhY1qWrJfqwjak3OaxSYFkTC1C)cwgId7FTfk2j8wqJjvuDXiQTMhf5L1Yx4O7eAjMeqAnRm3ibuoTxaVzsv31o)rHIL))pe3gmlW(dezpOh1oIMMymmXuYhxNxwNXCVtKed4HERs5Anpj)sK689HEN7t)(YqlM(a5G3mM4thYU7ZfFcqU)bHozYq9LWf9Tdo9bkuYcZgfIU1jxFaldlRRZMbMZBfH9rqIVoRPkbc9pwxDk)WvXMwS0KkxTUSaJsL85fTRMbc0HFWCgzMv6KN8IaozLGR62oInZknFYjRNi66INNlRt49HQgJijEzfMhbqMUr(iD9yfboVr72UD(eVuD6yZDqKmZyQoU8PDt5P4)Avzo8a3nVnL9IprBG6ktneZC46UYSJinwe)C5mSQSrf1WKvGEm4l4w5(wDKRy1UVr4J8Hmyoy6zAdNgc2iragZyh7510YtCenOue(AWFIL5Mv6vFMmFw2iFENdWqWzLpwKToDX1WWtNX6wzULIx4Mu2ZdNIvXHhMjw(QgoNw41oRtTUGbTjW7PXadIUNbJ0DN0)ASv6bOgBlH7HHz4dcKxmXQ76U4fC6j(hBjPux0pN6JXKVmaOZDUtDcSO)wmsSobhmja4emJ6HUIiRDoyK1VsYTo7FCbElbkxIp7SLWnouSuJUDOjE3jF2FE)AqbUI79uc59OcC7ZosW6oVMKaImP0aTPlhX2YciLZhXeLw556DJpN2DiZFYOgaI1HqSEAzrtvzETLmCE4ebVjuJ5nKDn(NbdXzm4gYRgmlIWGiYHEMZ09wPpJ6GnkS7z7UgZgta6lEEavFNoPRzcaVVa6v6RjLmfvvnTUygpXG2(wSNhk3aLGxpD4e64inUPvLR1yJ2Vso)HICVZwNuaw0bpcST81cXwr1Y(6nJNHMIa7SUA6404bBHcL7Tv6uQdLoLrUMnYDSs6961svOhsMkKI6wmx(bUjQZKylEaZdsGydlSp4GPvn81h(h2Ee0)XHTIMVZtNsw2BRaxMAlmnwyDFenzaEtPpHUaSN4TMBl7U7oHL9pgQyp2obaowIn9P489XF(Vd9CzgY2Gl9(D1JIzKiHQXg05SineVREGddyD8)a)tmKSpVFzxQA)paYVF759G4zp7kZ1tJgt9cQs3Zm9oT3URun5HohABIi3VDlN1Od7Uq28wUJdENAVWHwbzrWisyzBgg5ESpy762Hnx8diruE(T7VH3sI0gGyuzSW9d0h1g((aOrVjH3PZlK1uGfnOC20jTRxdkpZD9dm3WbXMezNA3Am4OwKA22vR(PMnzqBLxZEssALIC0)DrbHrSAvxn(33sTZdAl5rDNd0hhsmztw6vkXK4YpSZp735Zy2l6tzSEAolLgTyoWrVQSrM1JVa9SO47518MgWJfFLs1npLFLeFhSPM8wwQi7uPB(Y19r2BwHfoPYTCpfbQpzqsfXugBJDAs0J1XnR3Q5uoOZshPB2XcRf91umdiyEIj1TO3SgU633rP7DBnDNV0N6kO2Q43)dR23)uSwmQg8oQRDDs3aJGTUKwJGzTw4Fi2w1r6HgfXrvs(B2uSh3lc2WQJUNMuFh9odRR6JWuM7AHcbAlkXOM4yDLukfxvuEoBYT9K(F)iDosQ)9ekVI2QB9hQlZAFveFlEgG63Xld3n1xWKXa78NgYA5jxiiM)xl)alRUVTSvDfWGEOGKXQQ1)odNU5I)5AwEhA0LJUL0Wv7G9(FhfHKm0SOd5np0BG0PohxUuTr2BM8TETcVHv8yB1T2nQP9zt9EPdJ5JhQ6vVLTeMJziEMsFcGWID0oZs5)A9SPmqFGrRiDBCRCPhGJoHPU75HQ9e)V4ADh8fcyg2J6QbEfqD9qZA8oj82mTdJziGkDQd6itpMQAyfHqvqNU8mh(cyLXaVmJupm4WoO7QPB49JrGjpa(PBHnk8qMcuept7AxIvvISZggmc0DSAP24W3wLEB14SkE6jusYUL3chD1T691dt0KSlunZthnX)lgWPud2(aGeAEp29SPzEMP9VEINHjHBLRxX9o1cxmvgWLv0qaeu(Txn2dbtH1ixNLPOPPy58coymVSzeRabqizY9litX)UaMJOJZnBWlnEkJo1I0hg2XqTgpLTweT)nSGWPlB4wiA90qc70Tc3ewLuKmATiSAbF3PW7HFa)kTdynKvmwt9yFzZ1o0AnzTobzBybNT69vf3vI4(yd0QGXAZiwnqeywKLNJnz3I6gMZrwOynUfMU6JgdxwVu3ACPnE22JRfyAHIJ1stZLuBLS)u)BzM5kEdw6pd6IA9wD0o1mcRV2WrQQjvaZnPfzgRey2SMOJ0FjOiDan9GsMXErhXOgfV1gYQ1LW3Fts1A3W7q(4YepGnABo8f(m8rDE7Hi9VHPThj)D)l(9TU217UEBetwhvZITaw)LeI5XsZAfXrOJ3kUqocUvIHJeI4LXG(kluDo4WpouPcOim8vfbJni(vjnV95yotcHIlr7TrEyMpwrB7l8SDM(iAMDQ1jR2Q0w0PiO0BjwrDRwFgxFjsKUZym6RyCD6vzwg72CrTA6rA61DsgZMNDjEYCnN6AlHHifqVzbjSL1UVypHnwXzS3lVueRKDc4lLHru4OXNpP3Udb9rdSbBVdH9QoX)V1lX91XID4K1anVzdZGdBnJEzgey(7W1OEJ4SwVFwmvIZsUEuPRGlgY(PTxz0FR6wra9A4xpo8w5zgVR(HoFdd6c3huojdDTW2BrEbDpvaThEusHx7kFmu5PSfts7QjXSifIp9oLSEx8Q7601Uo)DIO6W1)E00ClJyXFTf01BUtrFPJUhA)CesGXUJEF)9YNuFz4MjBJg6HVXd447E4184uh)LVXx8x(g3qpPO54dMXlcLvP4yU2Q7l69rTXVyXunv5zeC8mZxqquVtXx95KB53EheBR(XFs(bwjHcUmcNsXFttWRSfdUHo6kPLOTFb7mzXRUTbpzR8O84ig4fZJY92)2H98xuu4FgoLoK3d)c3P0V6CBx56ZP0qbwr5FLO6r3w4kOdDrH00glx7AFa3abXgJ6rYr)PN8mbiVpqbFIrdRyFm)8pzYHpvUUc0Am3pBXjYguINw5PAVJuVmTkzrJpJOL0RbAdy6SO08AFjVXMXKDfPXynWGfMMUqcyiqRWY(iC82HPAzeUFzA4QEwvBonBvc6fA9DZWhx55uJsvg)C8rIPRjv4PQFEYHtMC43qL)C2njvfGMC0dnV(x)5F8N)HVdkuYFdemNb(9VHln9RLzR4xd5Lbf3wHPFl23PsOujqNzFoljsHoN7M3)tzqwWm57abWf0zgF8xR0J6)81SZF6)KydG(O9g)XHYr5LwJcFRtoeI)DOV)v7mumrBugF4opmmGzZ77ajZ7h)BhkE8UcvqvA89)YpzHREXd7W9npSd34JmhVZYw9gko62Ig4kq4XpMnK)uBcKjuZBZBb)8SgYUBmzME8WogVVw076KqN8hcrCn2Ej2WBFFJ1iqvTkq43275957N457N457TpDS9lHj2yHEVlzom78MT5WCFpU7ma7iCS7SnmgMV9bzyE(HrP81i8HWVXuotJY)zdTiB6y826tsp)HHv)ZF(Uom(zy88hgsBNHP)0KDY1xQf2xVv89Tru9aISrrDcA(YjITdkVVSe6eenn1A7aoBs2EGcn0iyh2c67YYjgE3Vv22I29V51)13dJEBpmCoVh6TzO(3UqT0ZDB7MIXFgB27oho)Bw9snKaA5zRt72clodq)rjgB52hW71AYesS1NERxk2dWoad3xMWbuVBBGKnV)hrkE4dFPWXZBUa8zgqidE6OCrgKDtF1xj8q7)akv83d)7LnnRR)UN9SlZAw2odm6)z1zR49uE0pcW)o9zS3(9T4Q(v7tHzQLUWKd)8ByhB(o2)6aUZGTs)dQ(nlzDlFSckyEQseIT5ze(jwWS6dQjWcMUyMLLJ38JyXTdlh(e8tLL1yjKI(yIFIgS9V2t3MyVSrKr7RkjKsOMrZeSisGgegPEjfRGjEcBqhQMRVhX4G)0H(qbWKGKEf60wyWHpNCdowxvZkef077V(d)eBVdl2scC5buDvEzYC1alQYF4k0t5pC6IOIDxx2aGm44l0v8uDfXBbacKsazfhCzcW8Ap6Ud9Lj8AMTbEzO4DVSiBrwk2jXE7hod5ksPm0wvCYn63GxbaGBX)pI4xaGa6Xna(5pcBvNWoxs(kSJOcr(3Ewyo)d()uWsB7cPhap2LsxeZvozQ2ef9Mp8pnWtSV)7z(7F(g5DohtPo4FFjfkgrXKPPK1niMQ4a68SAb0bY5oJJf0d6W5Z5C2o7JnL4MN6AY7xqV7rpJc3Uf4LKoa1jSP73jvLWkkVLS)g3gbN48iwxrsv9e7VjSLdKIFuuhSgHrMfKgTBwTLMxkvmNTcHUWQ2PzVUrtPtDAg2oKiLiEOCEg2W81c79(LRpHEeH0b2HDpxCT8b1RjPu6dEMFWo97RHS7c5A1OEFHAnVnQd5Ch)CYbJ5(A9rCXcYWadEw1i4SUJYXhUZlCNgmi3P5SZQ3SmdQ6lJQqZQCUc1C6TrE9fp5pwngib)VYjhk8w9teo4fZs21jnPlF6lEYJC)1pXynm2MVXokdBdsBJwej6nc0xGhmXF(Edj675(qFFZFcOVWeDADXbF99H(HN008oeIY)R8zhM61OmcqqKm4C9McRVyl7a0zGNSFOed9TFRpu0KhEu0AsvkDaXomeSKzrCCgjV8MyOjpIN2vecgKtj78xCyVLj1JnyNl72uqrNhWdaMnHJqNbmFl5MChhx6X6NLaumnX1vCvp1l0jIXLV5LZotJ86DyTJmc5wbi3)oC0l79gy)p8YbYn2DYxH2w6hofP0IOl8sG(jlcC01h2ry77A1xNxvTq75Y8VdhKy3YO(UzLfq(3ZJ8l9l5H(vTr9F1t4nueMfGm18UTaMz3WP8RVrDeCgCJRZSkzrdEOIcwTRyPcuHwweRwX092I5ICfst(0)fNogbegpfXnihFIzyozIjuYIDlPqS1ItgVV0bPwJmZMyDBO(UvxF1mlKLuVYdhn24CT8vfkp(JlCvHNRQ9COvksnRCElRlVrWejeOlnAcnjvsCP6(Ldw19)CPBkTYbFdJ1F64dp0yX4AsaBnH7kM38DjbB8aBphuehYhDoCoFw6iwzKn6vtE1lMC4Ozj1KPSltV3)vEy4hMPGONjbeS3gO)(0ti1tdL2da)YXtE5lmby6O)Vf2gXUObXZyqbyP3iTaJWDjFKzIrpHsnUYSu6GdJbV5BU7o5J8CBqQ90WLFN2l5u8zApZHPK2ZSQgpTNywLDMWJVIMthy8N7iSTKEYnMh8yP18nIRgg4wEKslGUuoPHCzj4rhvXrHNv4EdtoegAj1xE5(ZMOqkyWZJN7XqFKrEi5HM4(m433SGYVhEuzeL)NlQ3rolhTmtcMThfgpo4rbZeQbsfWv(tOxZEiIsFFQEwn5)nK5PeUsmZMjxVRrLxIoEevwefWKKIHKgZSVRtYYr8GCQor)()bNbLRU9DbtWMVFMCZc63rNVFLuxMdj3l7Y(b4jWDBf2LttK31QONpjchNYND6YRGpuuoV4iTVtc6FcktEp7QaSD9D31vDBaElDa(s2tdlz8vY)0imO4oM6lAoHxjAV2NU22xbROFcH0GxQHl9VHALcQHlPgDfK7GESZJwhzaCOfoXQ0UJH9PeTzqmXQ1CDNJvs2GUpwLQUnKn4zjQVJ(ZlOskvHuoRI9GHrLAOh3T1u3Dxp(enRQU7UiO6dyRI4TG4td1nHfA0mCqSPOJEr8P9begSx8IUQZj5O7UtWjZyagkzcq3iDnU1(8gmfd4aSYijrhi74tgp4rSZOo3cPTRh4Tam0WDDr5G03NHnNRFf0UbSj4S1jvx5ePO9b9SA4IMH7yAEHsaHkcnlwGT0x9vSXCAnmKbx87fzRwsOCWrdrG9TYINvPQHWEhTGcyDVwpIQjj(t4NJnFmS4D5PNTRRp5TonOFqZo0RpVSZ26D(m06P6aoerHpuv(BqKb(JMeK4Vhbh594kiQlHxFxpvVmbFkJAsRiKfN5oWbGehgFIMWl9AFg3rW4x5Z(aFBdAid3RlgdvZUVRZb(qVia)ASnF3ggSZqp80CdXuEeiPVwO6l83CfvH6PYimqltiCJWbskMZaWJvzn3pmH6uXZpuBVHkJMYJd0gen(fwRVdMU)fbVWE2NVOTV1KSVVM8Juy(ddJTNv)9LZQYyjP4KfsXdolppxAqYccBGB379GU(mzX0D8lg8Oivs2Gh5PAN0wasDp16llNyBcyV3MoY7q73JtDDk4KUmeigVIt76JJbQb0ahvJSFqCOdUtU7odNSCCKHByGt2HG6lRYwnLKMNTUUBC7R2caj8uUQSSipRHUgZSIHQV58OhK58Y8BxVe2vsQzTNC418QHFxYtovbUgMIQP2NXVFYHdJGkCndUBecY6c8ji)IwbCza1ykKTdvofxXdci(wi7h)T3km1e45XQ6MabJIQqWVi0KzFWHOzLvznz)oroNEglBXzIKra6RQEU72rVqXYijUPljYBIIBkLwWLJzmc4OCHR2n8zOYBMJeo8pzo4YoaPSctqfM)YqEZnmJUKotzH)fcAP18sUjLWysnikLNleayXVz(e1UwBbWQGUOt5IaQRBzwcd6gHxn9w27SMub8nb0tq1dnPuS9tWFu0UdcOEnQt3j(FM8MCHAdGi9ZSFjTPuJThB2JAb1Pqc3uTUmhY7YPgSgE8JLwT80XhoCO0Tbu12lH065hzENHNPu7d2xMJXdI5AoMB3yoq9nVf00HQ5Wk(UoFZu4UnSJ)w3UML)CJGCi9xjRZtsvb(SICDwjKI(5yQ6XiRw0wG7Wj5r2STDLuuBaoHQLZE(3)o9WH3D3Epsv8lz1J0h7bQNWCFS2pOS)JHCb75KfbtOXzI94mXzCgsjPc7(R7UtRbrB(iLPLmBD(nHltT3BzgNWyh5HXJQnhJNmX7BkM0wJDKuqQF(uGc3EtHl6iiT9ayx64J4EkA3o6WyYdntTnYe6t6PxQkTzn(DSmlVavCAcMUbyunXSyEnLtxteQXWEO3WPQ2Q)n4pc2tHHAlx))5mOAglIpNH0abh5Zzq2j0rFwdSH6wMspIeRRBgst)6G(t5bDDP83X7QqT2(5YRt4kEj4v)duD(bUZ)yAwAoX0Oy5fbnaUk72Ve)KPz4x416M(5JSOAvSDEpHja6hW05fe1)wTywGCzXGwWd9kM(ZTfquc094Vi4fw(9XoYiXdmYaP0syUICZHZWBDDB6Zn7pWfgEu08tfoP19YY)0EaKcT6JVjDKXrhFj(2xmOldNo(hcUBq3(JxcapuOsMf7Yvte0Q6UR)(Gv)uG3CXqEysT7OO4uBpiOLhwKXxbrX7VUS93(lBFD6ibsg9)lVrDDYyVEdMPnBMDRFZofpJCX9hZLzHdUM2Lo5t7dN)OXt8jYbORGU9096XLZ)bJhQgrpzq1tSVo(FIkEMHVi(poMJ3go8XYHqdzjdp04J99yTlDFvkQ4lTpJp4UALYFs0pB4JF84OHgZSo7mm(TJeaap30PRkpKBcSgGdjqX9rpmftvTb1HopWhBe9vDPGBDahzmJv9Dqm0YXzcFIVXIVtfvrC3tOUr(jUlZm2Nb)VOfvmN8yXoFhoTJYtPReIjskZWqBCmtSRe6dgBhfGiitMmQ75fH8NGBx9pj8)91D58Wt3LI50N)e(1sp6ll5ES7mnig1I3CasHE)aR59jktiduCK7AAJUgPzCjuDHsNXoOVUeUEfeElNizPkuoRHxbLgQjuqLOAN6XrsdjR(YOiiU9pVHSfO7rsBiPahC0X8TCZMLONT9Nk5FA9QYX6HvCE)L)C3DX5kbF)XSGFXUhR5HIYOnbMvyLwoSZXkvvv0zX0sLDqgvpLhi)77U)PDvmoDV93794p73c7srdzJTBFwLZZYjcpS8fj5LTy7ycdp8Hq8W97EY)tIKGUKQhsilkG90EicE4G45e4X9rSt)On3R)eNDKiIhhhM7CnzqF3PKsFEyjKoKACY(Z6g5psojfNsSl8q0ZFd2o9lh8i92bkxdhp5Ne319gx(TsnHudNtMqD4OJU7oxBEp9Kj8CQ8VU971gdMxTVxuoE2oJtVeLuBVhPX2XSF2pq8ip3XjdSjwqtry2(eyWSj5m)IEphbgiUvlwzpONuruzic0ZPkim)vzNI97s2gAXbnwMgES)pPjl9kfB8Uf070r16kNbpmOf5(0dqhaynABO2v4)gN2t0L6or7c9YJ6BJVhrEY7LowC3GOhLqlaLUwy3Zv7I7xe5qH2fk2D3P5BmZRsSOoo0F4eOk51tzGuUZ9WRhwxpy7sYa6I)m7F7aEKd0j23kybIhShXpd1jT0uXxa51NWUNkJ)suGtDzv29RkVik95alTu2n0aGS5G5RZ308oRSZxh3oG7AsZWKyCXvYikmUSk7CCFidx(2mDXYZ5(pkDKonB5azLHlB5xBM0jB5hhipq2YrXj1m693xJ1G4Ml(E6RSc1tAPQUBDl8aM4tO9Xbkrbk5eOqZrn2OCCQwHPShoOX1aFKxygnEDhmUlsqC4w5fGHEqxdPf4d3V64aJMWdQZR3emPB7Su93Os5w04d5xM2wvHr2ZOA)Kpf3RUHHLr1e19lh4RvFHu7tnYVC9jjZNB7JgJUmGbJoxlP5ssI6MC5ahbuof8ARyxF8OJeEX9jHgFnt4J6cGHSD9FHvYMYtDcFI4A6PBcFlEhNUqh(MylamTPfZgtTVITJJMTGgZWF7GKyqN)i(oFNHVsU6mCWuVq)E383bOXuPezo9hynlkHo0oXLuvG2hDGDkKV60nSvb62aYc0l2rwwNur6o86Kfey7twAwTfnzq4(z9peVojTkR(k2jC1LrxxBr2PxRdzj6LHAsdvV5I2AQgEKQjVA6lwN6xv84(3AIFFZ0H3FMCOCJXU0KHVAFzQdBug6ITcCloHzvMErT5dFy1OZ8UcJXjxfGuldx6YVZrHkJ2aW2G1Lm164feNQSsrOT(UoeY(W7)6W6c(Z9hTa247OCxiCp3oLzzotDVK00ksNSCyg7E)MzKY3h3D7UlQOAhyNdWOHYB0RlYkYQx2LssQFQhsQPlPi1T4jhU1XdGAMSraX9LDuC7OdK7vrEkp)TOhdIZ9bgGijiMzi7nsi27UJNUmg)kypk9BKzbtbjTQmVSAUE9v4Crllwi6xUZgddpzA0gKWjtd9dz75ct4vUflWVp1nnC0fzNuRfNj(qyFjjoW3VtC9wqxJRh3)5)j7Wy75kWCqGhTdJURNU1b(iUbVRzGPDOvKS24RH)zRwVOm54smXgLattEx9fNxcJp3yamaB1IUiGHLfzy91vQvmmSEZgVfHZ(2Bu8Rypv2840hlOqYQIZHYFUc5XjK3hni)kwxya1NYPSL2xuzpTXV)n5vo5Q2ciZu4bkGfra8TENiJLuBjDOxYw6C)WffvhEX3NIEsMBEyZaGExPEe7DcFUZTyPPCQ9NAx(DA)GiYIyMKB79)NSNM9BNE4WJNi359VTBfbAIPCyQrPy9OXs4vJ2bUs5FXbqRM9TOMecuCUjZKHec16IWkDo(zl0qe2bt2zorhu0kZC1I(ON5X1dbHY3Mhgd8xtszvnQmVln7oqAm5N2JKHnYPCMT2o13Nk1mLIq9K4MWbPqNJEWXkfeY8y4KuswEVwYpoqPclZSiUNkgoSJ1hVkIC6AuUXsvJ5NKOePY9tnkBfzmkpiSw3QOpZK0NcqHX5KjDInroY)Gtk(lH7hI9g4bwnjjrt3ufdvhj4r2JG(6ua(ZAFU7Xe1G7sUaQi6t9wn1e9AD9P9bGhgjDu1EB3ojLs3xu3YfjDBT22iN7llXC7fDZvdL6U7gmgIhZpo3p3wECGcEwfou)ph9EZXtc9yhyrsY5KoqqH2iHu3dwE1fypVkd0fWC4OJggwHH)V27QT124ii8VLqaHojlvl56qPyhWqcn9lLqcH(nRE2(uYrLLe6KAQbJ(T3DMzFFNDV7KLLm0q(sW6U9UD29MDE5zEM9JbdFEjQZYfEiCkibdaGagQPXJhAvGO66pnKGQPUpiTggGdc8eJTFqgy8)vpmsxs8OMTybQo3RXfG7iOdcqZQkV)(ciVEyWpTjlzkUgYyzuP5zKGYncBVlqRvX)jbKt9AjuaLewcEmJKvPHttCNe14nsD8gNq6oUh72p(Ty9tfrLXTmWA2lYKTk)zCmXFIJFEqFbyvzXun3CRcKAQOxlxgHN9wjNrEVq1)DBzipCiiS)1VlTgM8C82syLa2e898sZIe6CK7lHHIXD)OBTIxgqayTLOJhXcB92VcpXtQkUnw9pqQ3N4hZtLYaTipqjJ73w1b880HCn8XhjV5X3s4Q9iC3AZhoGtvGZLhosgINaiwfOzPzZEV3h0e0soCvXQJL6evi1R65WgAaPBHkWvccM9IQaKSPAdPvHS(eEkxT49PvmKOxreEEhRRVr9)rhHkxSNR4Ht(F1Q430PrjDA9CIzdO8(egtUdvWpLO8EDoKl(3YkArl4MjT2khADk4dqp)UehONE2pylgCRy15LDK0OVM9(A5PTTXcH9KmyNFxFEYy0HCP2yYEBwOzURMRiDpnB8EF3PfHxt9WqmfBKwGkUVX9JSSYUw4JALLTQyrfuzyOA4ptjfOLcP2MtWa9Q1TbV2dO6MGe1WhwmhrC2SjV22y73fseW)f2QTZsMgU6aNi(TIzlRdk7mWOhTLYksnGbzGBPB1KglyrxXQ)PU8k6EAuedLTacBm0qXdJ70cUDm7Sb7v0NBQntgJVVUD1G5bzwX01HlbtLTO0WYKCLzDdxNW4dpNR0jvKIRf4gkMvvKwU7bK6iZrLl7(Q7hLCSdrUBDdpN5DKL5FqS)e0EO((tfUCO6VGHqAwqUeYsIphlLn7zz6NmiRXVwr3AX4JKgWOodSgPs)lBBKbTgbYmD4DsfX24P3VNo(pc903nJ0qRHRVPXeGgVsttnU9WD5QPTz(zY8)Cy3utcGpnN3H4HAVJWQU(T52F7C0QVGEXqrHM8kOZg03q)ixFwVM0abSd(rs758hTAn2jBqD5PD)l0dXmrI2lNzZi9I8oYj6qftKZ5wfvLjHuorqnSNQsUVxvS(zydgZCDXYlHIKpAC3bLqH9SfV4aZmlskE8dQLkp60ND3UG(WC6wl2SvsLyhAjIjg)2HLYw4OJe)F)G4rBH(i27yWOttxvhjKAX6dxhlrsC0X4ixKWQPtdUVbJpVgPtcXJPlnCmfkH4oAF20fCt9Jc2tDs80RFdxDIuthZWauxliSqvf(AWon6y1Vdz9MAMOhHfcFzTsmetuds0ic7o(JftC9hNwaIwwW2Bk3Gb0vz8XsamYY8Tkj(bDNtdzA4dVG0K2RinlatPxeCfMD4jUg5ktgy9sIlsCGlSgLQ7MLAf430LZKWrmSVnyojgpYX4jUgs4qH2q5hbC3E8PBT7YRh4LbTSXVUSMC2pF(4X)ITk348(AthLbJ3nTfsq0B)NOGqwPoCh0IiCU8WlaJ4bvDtLpT4JVWMdSHlZY8mMss1wF3IVxJYElU(lehikfvHrCM((H1MnRtfoFRPFJYvlh4WCeKSPXWrFgbV9bhnwYxtLy0F3m7bwvIqoVYLfnM4wr5rCk1bIqc()ykTbzuswv17yzo(hLoDMLTp171)uoW3aVhmbT6xtS1)oarHlZXccd2CFgfhjcbG5Ykf0eyak7xUhtm6CRJjG4marwcN2uO)WiBjmztCYJqQIz9APqEbMfaX2cBMhcXzXX4qMvcX0eSTqpeMSdljZI8(RyENQ64)NroD(TxEwWpO(s5TJoND14k723IFHxjKDBMbXw9MYzySVxH3mo8vIZWbwMCvjHInv5Cvrnwsm743Sq1iUUphOolfHgbHSDDLkS7GjShg5DGGwn9eFYxoV3R4)Lnl9wiS(n5Yr6WuCrSNinPXyFhjgF24(ZYfDpflQiUTvwDX4hyua1KD3teJHfA41g(dYH8B5cBxMdNyuvXy7LhEj86X3hQfW0sBNKsZEf95IEPPAMhnO7PdFt)thoUxyqxYu)nvWnZssPRTG0mhavcOjY0Ack7sVKHgnCEwzlWj3ouUfSbiHmrn24OjJ5j3NPcZC9elMtBjM0xeX5qoV6yFJAQ0GLONEbLusUj3l1eO2S3vxCz1S7XR))PuhI6KCG5ISN7ahtJUfa6cFyXgSEEGt1PM(yrjvB5FOqwuSFzjP0ZbTCyNvcnrJUEX5GDZZC7OOYY8bcKs(mYdyXvDJ(QUYWJlyWzaYuXdWFNqp6U3MLIrxfgQ8oAkChwQciW)i2xc2dtzkP0J22K5yJYWze0Uy3DJJ9TDBWJCsyhNEVfA(DSSA0CkztIvwxSyXXtBy7exnJSED7yN)gx4hju484JDJsspMO75KEqk2izp(ihj5MzLBB39YYDPkSbjz2Dqr7p9rDpqxXtfe)9zVH2MoGxynoYKXRmEZDp3Hyxa3Iwd2z0TBqE1mfwyKFYJD9Efh4DtwqKDJ8BnzGZ4typadzw2soG3axrv8L8vWVgtfpv)n1RSlrm)XjYWKS)RMLf5i)MXLent7UpYw0NfDrWptgb4DbSoQxl5IZp2x4VpYktSQ)xpU36iYP6aHAuAZMvhiRTBrEWbGoX8nPhjb3rL837wSEi1j9GcDiVvgnL66zFTJiWmysHt0WFpHGXW7DjIvICnUNOZc)lUZ95ZZhUeOn(OxZe4A6qPyziOUTC(icPzew01WNHscJSpNlHG(xZrUVCHsfVd)sdSg90YzZWq(nx4jnsDMtnhretr(tXW40w)B7xsaFkEW9pj4n4fJFkCVzn1m5MDVm4C35qcEnD2G07P9e7AbpE1WdeMO)P(P4SuvV1uAO8xbJXXsMxcmZsjoXqZ8XTIsRDTdmI6VtwhPyz9H1SlPP7u3nFh7wtaMLIe3F0bTU6dIIrw2U(2bnmvogYm1(62(m2dEn2SnA)qY(CjzR3UK2oIT2UUdVjBV2qR2uapLtmHpXkIawv5lBst4fgidFtboEUeVpOLkOhI8YZNVyNA2kF)yCV7PgvGF473r23VM9fFQYZT5UXW(SAJ7mkTYaz7mr8b1KCOGzd8qzu2r3ZhUPA7CTMBeQ1FOrPV)M6dg39()eFQ27gowVoy4n46pl(k92R)J3C21Rf)76)7p]] )
end
