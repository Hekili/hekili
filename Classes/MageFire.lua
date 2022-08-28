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
            dual_cast = true,

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
            dual_cast = true,

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
        -- can_dual_cast = true,

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


    spec:RegisterPack( "Fire", 20220821, [[Hekili:S336YTTrYc)S4AlRiAlrlrBN4KssNYRDs24tU4kk7M9xMceCijwbcWfxKS2sfF2)6UN7dMzaOKCwNV6u1UX2ea9mtp9037E(WXF43(W5ZtAyF4NNC0Kjh9Qjhp(4V(5F1ZFXhoV5MnSpC(MK0ltwc)LIK1W)97YQOF8M8YK54hxx2wLc)0QMMn1FZZE2YSMvTZgNwU(z1zRBZtAYklsRsw0G)70N9HZN1ML38dfFyMVr(LtE1hopPTzvz1ho)8S1VbGC285m(RZQt5tHTx8tWKA77g6OU9DVUDzBDZ2lMC8bW)bgXTVB77EZQKILS6Vz77oC7f)9AaSlYwUQzAfBDswr92lQsAwXQ2Erd8IW)nPAjRzCt2A20MYPZZWpOeECEsDZH1S0YI5BVizwwEwZnBVOTgMJ1JjG)JLL1maePj4KOI9VBHvXAwrtTaeVPC9mycct7TxSF2y2yyAoVS4lG3Evzoa2SgXBMa)zfREfGdynm8xqGoIpoFBrYSCyAv3uLLcFr6kw6Lzfl3Ebcy8tzxtW5syGZW10k4TF97)r4VvItS5TPWpCn8c4omhOVE()IWDWN)(BQkNLtlcyYxDdHAAWPkdayrj8xxxoNLdGGLNJdXHlbchynb7dWlZQByioQbFzyAMTSiBrwAsb8dV99NdFWAGItUAEtzXvSkCKrynRDXIX)ZXvSKuXWNHdkoVfpQDdG1WDQK81L4Ce2e7mcltW1n()HPKy7H27xLunpfM8W87QKQmerwBJwEZ7)7g4MpCEEwDtnEkivT7nnTe2UkVUa)9FMoFbtx4bWPMs(FYO9O5F4V(HgG438nMLxwoF6I2QBCERNJVL(xopTkRHbtr80eSY1dpGcmahRQMvHB)imEH5iTai)OrZzGEP5lLuKc7xvj5ttHnaN38ldoLQAlyaf2s24g26nL43FDs1MXIxE7f7j2WyFCvINPnD(c)cCy(kNHr(s1Pjv1tlxmDbCgLvvadcsZVG1b5e8nN(cAy5m2cdpys8QatIL5jZZsAkHVCwYCKljBXcwAZuom78yauFTdO4VjqNMw12G)60)DlqR2UE6C2vziNv5Gf5Da4E8rEb8IC4pWL1SKMMCdO5(aeeh7fexNCjRaOKamdWFtdbNFhbWKqlUMQ2ucpmp7QSc20zmKEYyL59fqq6s5l2TAl4NvG)vZQBQBmim68iemVWlyaMFtHtc1ntb2ezgZi3hGG4LbqWaR4kwXCetSMbYlklV0en77Xi4Cp)WbhRao5KIVCDtBX0LWNMm3yBlWZra6EsHdWcwlEaS(MIKn1SPSIv4P6kned9ciidr3VcunOQbwxjZNEDfWe86k4Jnp5TPID14JhJSzMkKx80Txq)6eV)6ZT(1Zofestmk4dPXdhNUcfddCMH35i5YmWmcxeFTjlTwyjcZX112CZAqLlwK0M3O4A7L12JazbkUBZZQtZ2KNvKuDdW2F96KI5sMC6rmTSTa(66nckA3Zik62vzlAaw1t3uEnU)Gk7uLTH)W)HqEKuClWwoBnWNcWcxVIX1r5CbaaH0ieGNKrsnzOMiiB3z48MzRQrgQKdG0UzCmHkO8S(2nob2ooMEjajTVGdFwXcoVuqfLuGqfy4Qz)VQSb5XYsUuktFe9qPW3X2OKP85)u98YNKrj6Scz9wadWMKQlDWMNNCfGg(v(Baio8v6Og2b4SeEAjIDVoRMJg56HHyoPC(HH423yzj1Fm1yF4mjUvP)W2la9sEjGtuYU9SkNJCuMvwvWCwIVv9aqnNvLTOgKj5xNCtTjfX1GAZMR5XBV43PFI(8VaE3Vd5yT(a(Ywcinayjv5GoG1LsctZXLt)TIq2RjkV6gWAcaQZBRicvJrEqyr6b4bquWfruOFwu07jgp3qxnGZdQ78u8tiwrSpYsBBy6FqsiRr0JHjFchQhkEO5uv9qGw(jwClqiacljeQInHuLlp7TRZQQk56KasgrBfC2JjLw)j(Bb0Kl2EXVXFppBSMO3pbyQ98GjGngF6jo4L3RZrYQ2Wlsuf(zSMRzOHv61k8AjW)pVePWW)Mj)oonjzNcNWKSEa(tWMLKBqs61TPRemdYAgoElWb4NFKdzqnWsSnhuClhT00KoWv(nkQ66vzG2EiMhvIhemzJI(oCw(paKXQBQoqGRaJ04wi)x5Is5mO1N58Jl52LIiJKRkZMJ)WMn07lyWp222bo3FtSJq0q3T1XCsfcyaDcS6ZbdS5Gvq(COsYsWpNPnkhirFHuqJwgYuscB90SIPliCR8vCL10Uz3uP)(ra8Y7GnbkL9wV5gykNpTSAEbQv2GNmOWy1l0bmtjI9(5AE2qacFnk0ETZe2NLjAnEsa0eBo82ZSydOxK9j20ADgJDfOm5T32X9oN0d4hfMZM0qKaRbFMtPiXQYwpLLMNb6BVt7OV6oSiKtuRb1NTAk(YLLf5znakmRE9on9E59y6zpQ(m8tFa9MnRquDsDD26mUR(COzcQarCYDtIjGiczadCEkxSGVWc9m0oeupnjM27e0NrOkuEsAYmGNA9kgRz6626S0DdXRWIEaKptxTeI8dlqjhe75eufnwfjaOS4qH(Umu)pPYJ0V9w0KHfKuM)bRUgD3xzBtD2CgxSILgL)Iub6dqt9YkH1v2)HPgtpWYv7fCYGQzMbG(hewuapNBsb3ggM03sjKlyfoFfDwh5cvucFo5rWYR4(ZLlruORgoNPFIODH58VTcbAY851CKYAYbKxLK3kuzGEBnJEea(wiRqvtMxsl0gcMPj5Pc)tJtR0eLrf4tBlq2NWIovimUUUf5GXvUoRPRrDGzVO0fe94yvcNKyUCwn9kAs95WjfPfr(nrKmsGEx)pFDYhNkEhCSEeUOlM3ckR15vvufwtkd5e85NZZdikmdnJFtjS3bS7DyY94TxqROoAaaIEoMVKhzy1M7EIp)bPKsc2CnfDIDd6vGHlAe3JeAFUF4DKZK7iigyFcB2a6jEjgMJJhNvp2C4P9nJhdNXMLZC)vfjOc7i2MuVZK4aEIxapXdGhzqmbdagvLnByZh7IG5tb137(ynaptyYTu6UjU3Np2uo5bv2jFksW64UO(PnXfjPMYjkrO3ZdgClON6Ug40EMS()TQSLljFhbVeWBvUBimRNZh2dhx0SdoVnILeAKLqJRXE9BOT8g09B64gjSgBgdSqcHMjBFPdh4HFsZ0lGWgECLQlrK5gGPBZ4H4FD92LI(XvjDlgw)rZTCWraiKzeDIbWN)Ry)bVa9EAiJjCJsXFwwJDJIYKq2nemok)zzTgjoptc6w8Ur65pllxVrIAsi7AEycOPLTPXcP5exJrgG7x)KH08fFgCogY1OWzfW4(IYRs85s0VRI00)NHhluwxkM77bRlrbB)qAwkmt8h06L0lnnJ)oMIPFq9UFVQCE38elfUGjHuM0kyu2OUVN1imR5TgX1IeVUMmQcx9GaymflAlYbfNqLB0tx08L6shxnpSGLr4qL2zKUlEFDkqv6DcFVZ0KkqxmMER5rrEzz0O6B77P6aFHKwZkZBgBShC2GM8ARnhYoVmWptC148)pe32jOl)xazZxnnj5OhNTJWKcrAOjghtmL9Xn5L1zC37mXvR3pDBvAxRzGzIU1r4Yh8DUp97lJCy6JKdeY2vz3pDi7(px8ja5(he6KldfdJURE1LBafiyg5vJe6oInEpml5HzdMr3yf7jrG42uwxNndnN3jc7Jb7oBN1uLGH(VKI1UYpCv8HfT6ewfBklOOuPEEr76zOaD8hShrUzLIW8L0G52ckXxgWjDCWi4yA74MvjO2dkFYTbwzCVIwCtZk6VTHhLmZHaTDDzfLhbyIhY(iSECIaN3ODt(s0W3UWhIzj0CJnTH6dDIGsYZStMzm1ex(0(P808FTt)IXIa3nVnL)IpXaq9LPgYrEoJoz4jkFgE17qkrsgzpcRlB0rnmznQhd9cPLxbuTaaUIhguPdVuNE8mwA86P9Gm4oy6zgGZabBLiahZzh751WvMklzEQPIWxH(tSmFQ(LRh2G5ZYg1Z7faJqNv(yz260hxdlpDYvqh0BF6Y05u8OHpx4Oj9ynvC0jqmSr2nHtXQ4ZhUjwkFKzGaqgRdHly)6uBkyWya8EAmaqm9miCQrO8pMUW8KgwGYm)AK7dHACTeEagMrpiqEXiLgHBp14jazYwnePqN6h2ksP(OFoZhJjFzaqV7CN1jWIME(1i)kAlMIz8CnmyGnkWFZoka405kmnhzRPSh3YSvmdWjk1PKRNqRLVKzqU1f4t5jpNK4lWBjr5k8PNxPddq)Xsn62HH4DRxHORCD8G)8lPR4ELMaw(1wHZ6ESN2xgYoIpUjKuXAwckYeObAtxnMVLfqkNpIjGw55KCaaSiE1nXIeLZaPbGCDifRNww0uvMx7idxeor0Bc1uEdzR1bHhb1z4ZBmVAOSiIcIOy2ZDM(5TW20)l8oyY19xL4JEyJI7EUURXAf97KV4fbu97mjDXCKYkNg5ZET(AkjtrvvJp9jD0ejg04yS44vFcTJ6W9YMY1mBq9XxRpochzXnTQCJbBuxFh9PLCpULJHzrh8iWUYxleBfblLZ2bgpJSfbApPn5fnStJhUdkuU)oPtP5S0b2w2i3ZkzWRxhvHEizQWkQBXNKHCt0NjXFkHYdsKyd3RPdM)AlMFTOXpuQEpe(hUEe0)XHDIMV3tNkw27QaxUAlCnwsQGzKPmaVP0Nuxa(tyjePq7g5tKuQ6bXBAfE0yray9z7KOMeg19iRYKAJeJ0d)5)gwFzCKTfx6dCLM0npRrsKLyCIsAGF7VHgDEoT0Rfz8crdrMqkadAD8pr)jfs2NpSSlvV)ha5pS98bq8W5VzWbzgifXjvr1VWgzzho2o9oD3Uf6zjv0lkODjI6(T74OgfS3fYM3kCCW3P3l6qRqSi4ej8SnJICpso4XTdBV47jIO88BoGyvDJfaIrLXd3psFuB57dKg96ervDwOQPahAq1OzsAxVbvEw46hCSXdInjQQs1bgculrn76Qv)uZ2mODYRzpjjTwro4FxuW4eRo1vJ)9Tu38G2rEu)5a9jHet2KLEPwmjT8d78ZHD(mM9I(ugBGMZc0OfZro6vLnQSE8fKNfLFFDAzv6kZjpv8vAv38u(vk8TMLzNQDHsfzt9vj5K(Y19XUBwHfoPZTCxPt77xgKsrmTX24pZJKtCZ6nkWeHmREkDK(zhlTw0a0kHDbempXM6gzCseCbN73rP79BnDVVKzoB5jkib)o2h3KXTxMNb7AfaSJeTj1wt3kWYnM8FwVwucYWvIRHroRets3aqiCPF39qraqSRQJmankIJQu83CPypzqeSHvhDFdP(D07mSUQpIx3RsfcSQ(19mYLuV1APqvuroBkS9e(VFeRw)6)tsn1db8hQR5vjllla8tfYwqgFlrgG63XlJUBQVqjJrjAPILSwrYfII5)1Y3ZZQ7BkB1T7cYdfSmEvT(3440Tx833WZ7qd1sGVJ1iu7G)(FdGqsgzx0HIE3X1y6uNtlxqBK9NPERxRXBufp2wDJOMy5AL0szUoo07NokMpEa1RElFjmNYq8mT(eiHf)ODMJY)1MztPxVdzvKUnDRCPhGJoHPUh4HQ9L)V4ADh8fcygMLhq0mM0rKpG66Hgv334UpSJIziGoDQd6itpMQAzfHuvqsDjZ1Jy(fWkJ98Yms)WGGDV(RMUr3pgb28aeNUL2Oiczksr8mJwmdVQe5NnSyey6y1sd4i2wvEB16SkD6jusYgvXwHmdoJwExfWnE5oYarkTuyrygTfdj7svZmFnTMzEEXaoLAVDpaiHg3t6E20opZm(xpXdysew56vCFNAHlMkd0YkAiack)2Rg7HMtH1i3KL5MvLSISp668cX0yEzZyEbcqZKj3VGmf)7cyoIjoxmx5pNwKHvD3hgUJHAnEkBTiA)BzbHTMgeOcR7z0LUB6wrBcRtksgVrgwTGV7u89Opq0(UqwdzfhBOESVS5ky94e2kuERtGvu2UCLC0QpqxCxjYEpfQvbN1MvSAWiWSilphzmIPkn35il0Sg3btx9rJrlRVY0ACLnEU2J3jW0r7kkXDzaj(OE6)QD(szPXUBH4wdQzjlP84Okl9Y6D0Wuz(o03K9k8mXm45(S6BOzf13cWEn5fTvLxl7fbD7dbCPCOcQOl2qYIaAas(ZJblT1zfsGg3NX6umYDbR44)upidvOKDYIMa5brqy7rnbDikIKRtHtzKHfppNyYG1VzOA9maQ2CxsvPNKF1vFzABvfLpAwDsh1t5kTW3oivQnt6mKrGvIGHKujZTQyLHjm3qlYEZlbfJHOPz2z8iMBsGCmQtSos6s6IaJQtSed9wI3GRnPBIWvF5SPYDRW6AQp3nmYkpETWIu5x46JQAEFYi31numDloz57Wlsz33KAhHPnTub0z8vCYeY2vYr6I3oiD5gqvRDpO7dEJpa(3FYkPqt(CLJCggSZJnCVv)Lh1xBmZJ9WHXqr1OpSHbHkTtqqaiOOOTgM(SQjVA6l2KguetmRPncs)eHMk9Knbdiy1toYUmq7mQEAdabi9KTTjkurRaX5hGKViAHy5TER3wlMUPqfJDlswtqJFYPozbdpfPAhpTfnzycgVGIaK3msPkR(so3zT)qh71iT(1H7hw0T)OHi6duv4kVatfjeSCDtKtc7tD6Aqbjg6t2QTJGJQUNXrtx992nT2gGpF(8ZH2rmKl(A0Nr6Hmp2CHeAEm8U06DKi4rBv1toV2ytstRy0hjh2U62h3eU7)mZRnJdtBn90iQNNo1kUL7CIIDI67D9vs8cer5TKGfYr03quwiIZldNLoX0owTO4pXxdu2I4uuK192VbfysdiPsK(cwAvzEzL4J1boWtye1ia7Wx6fWQm03cSXYp)rMEBb2Vxtn8ANSXiWZmCTBawLefS1srakVUh13ZS9F8ongb8qU)NEpgNqofpWJVhJu3KRYDr1t2x1)OfX5Z6VXrIUpn1n0rN8TmPGIs(o5RgrdeFrwrw9k0C6y(eYozRThFNC1Zqxh(mWodD52rk9yKqZdQpKYnDSRTgZPiSjS(KsHWAzKVSmLLKHW72HIoTbWFATk8y8V9An(H)u8zN))(xTHf2cCQ6QKtGek5EAcIYPv7G0ed5Kr77kdi0yCEy(v13G3QhUyCeq)1oG(9IDK1FROZjmZ6yv5jEq(cwuuXUs)d1nssCNay5RavJe6eYhW7CmI(DP28DA3mhi7)lToHrQ2447nQw9162cmSSiXqTW(A(B9DsKJ(SL)UvZ9itX1crjrqlsybtWBZaU6Lly0Jl7jCp3aiYna4gwkV5vzuVzMdzbJn395MIYJReJLy9agME2qxGJgqerm(UODpBk(JDAp2DZpsd6jYOo8)q(Mr6tFNuV8QKSCCIW5RIj13n6SWntrhNkBBseXiNZnFG6iBajmjNdjrJM(3cjKCwNi5RRJl6J5yiIM)CYrC)EjWTiz8rHRMqbS0r57ZH7j1tKf6vNtM2LST)3r4oiD8e9)AbNJHlkczTSRwfDPP6ruZ(rK2mSPkLMfJ(8w2utKonvyNhD(g6KVDIt7Jnd6um0pAQgIPD73pq2LU3WzhAhGyv6O4STDFa6H9LJmeomuQ8gR7872x(d5c(eNCbRYkLTaEPRxZWMcf5prH)dncqJqZ(Av3(StpdOgtUmeh5osa5io)Oumw02qjg9IZTi)C7fruhck2fMOtRIUhhctU)0EoOqj1BJNgSv6oN2NDADvP9LehDxQHaDyhurzjjEC(yHT3Ai7VoFcLCiHOK3P5zOosvp6FqCagKgi8RBkCNG5KZuK2dVNNHhImhyRUWfuwvYnVlnljxA5yBDlNGMR6bokVU8B93A79jpiQDhgoSWnlvn8YGvEPyCNHe6nm6zceA)Uy4n6k)4HtZYExK1YbEujRl7Nf4fdKraFzFmRMVV25J58uiVAZCA9iixOU8fE4C7EWUQKHxy84A((R2ZGF)DqocT5gUfx9aJsU3t3bmEdncgUiHWnpQhyKqi6cTo23fQcpFDOtPnr7EtpWR2p5bFQtJtQ7B50WKKXwIZdQ2hhgxFck1xezPi1yu65oBjc1c5eNZDtDhm7DnKxELcm8Zwduo8(wH4kE78Uhdn6qPR(MDxhQtef(BJNgxJA72o1l94aIyBuD3Yr9awXY30xfz6PAqjxwy4Ccunv0U3TQl7gadxZQUIYsSEvmTPk5kwUt(i7JkWJAz7acMWUdpsUEP98fkYo99e5RyMQFD1Cq5mDYPIQK6Kqc5SfnD3XwiUCw7SpJ)UCBM2wj37x4RdwlVeFmsXawEnl62Kx3a4t(22l49EPHhm4qGoM(YDY63MozBt0Kj13027GAw8j9LirkpIySPVtDpVtD7f3ojkAyc3Ha3OEG6mNJGcB51bqLh4t9Q5KEwm7naF5k8zqVrT2J2bc2g9TLiuCqm7LRg(WUJxHmY9eoSiA8GBhdQy52pc1wGs6Bu8taDln6D7qWqkeaJj(qRl5GQJgNfXFslw5oOGa601ddYa(5WYRnDnBYnI(rsKOEQqxVn(ed3Kihk5zPUf2NxxRBwQxbMy7Enr8BvcxYTeDMgfjzHwVsbGunGsfzGquzNEYPsxhz7P6EwhedWuanETVaAPnGYHjPRzwgkihUzm5AbdUrneE19D66Uo(9IO6XMPMUPh8oAQ3)3wqFV5DYS1EC3WWQhVaWUhJ7VxLg5FoQ2rxFc0xizdx)1diESXPom1sEFZCPlqcOf8fU71kDFbY1AuJNqA7YW()vI27q638wtxtlvwfWXcTvpqg8GEYbhT)hMXi4z326qr9D6b4FovD49LU89hr2t6vr9qmnUxLJSwcfM3Etb830ek6MwCd7ORKr)ECF1J)txnnlF1DSIF2TcB(4ig4fRWMhCzwhUR6eff(FJAJoujF9N8AJMukYKvP3AJgZtyG)vsJYeEhCfErrcZ00g7pTJr1wiiomQhRG(tp9zYP8bif8PLM3Bshqzr4Pto6P6esY)n08bzlovDpz55gLwV3XQxLwLSOXNr0k61a3gLpYVd(lf3VMCzxrUFg3ZIfMHUqY5qGBKr3JWXVvM1lJWxBZV0ChLNeBtZwNG3e4w7MHpU(iU14JnIaKpo(eX0vSk6u1pp5Ojto6lbsWZVoPQa1Kdo086F9N)HF(7)gSF9)BOG5S1BkXYjMKM(fQMM3xGPmaGBRq(88R)WeGkbla95ukcuGxG7BF3psfp(KVbfaxaJm94VqRh1)8l4N)m)j5ga8O9p(JJuq5RCGIyRtbc5)o03)Q78SyIbuo(O7my4tMTVRhK8C2IK28MDdfF8DDwHb67B)LF0bx9IhwW9LpSG74xAdVZZw)gahDtrdgTGh)yoi)X2eSSeM3M3I(5zdgslQNA94r9aVVqgpq1St9dHiUo2Dj2iUfzp2GavFJ1I)2(pFiF)epF)epFV7PJDFjmXflm4DjBWCN3STbZ994EhaChNh3D2gwG5RFqaZZpkkLVbHpEBxYvoZGY)zJCiB6bE78jPN)WWQ)5p)Ucg)mmE(ddPDhWmCAYE56R0c7l2j((UiQbmJCrr9o1m0Us1gg2Tz59LLqVtrBtT2TjNlj7aqHwAeCh2cg6YQtm8UFRSDfT7FZB4RVhg92Ey4CEp0BZs9V7c1Ya3TnoNDhuY(HHfNlYE4lpb(X90WG0dzyQ5T7tM7oozYdRUvh7QfXoVuCbWUphMC3pbetfKDAMS9D)arYJF4xj9882lqNMHuYORokxKHL64F5ViDr7pHxzjVd)3RAA2u)np7zlZAw1odT6)z1zRBZjwJKJeW)D6Z4V9RBx2IE1zYXhGl(jtWHhFWB4NC(g()6qH)GDYaeqfNv863GkwzUZQKrzBEgtCOfTS(WAgUKHLZSSCkpjPRzfCbjgGFSSSMUmdi3mjouJM)x75EpA)SXSXhOBoXLyMAM1Ot3RfvS6vaEHY9eoqhPhRVLW5Ol1XMZeYNGLEj53wkVoHpNDnbRlR5zug5a(x)(FKV7rT9FgMN6vxMxMmxdy59ndMWzAxIdlIkEMH2Gtz03xK34b1frVSCndZkGSIdxsfpW(W(d8YmXT3qd(YWufDVYISuQ8vE77pNymc0ggRkbbh8ni8ipJ)pLHWaNcKt3W5V4r0Lgn1iSeLvpg8F3rH7)p8)dtlJTlIEaDAxkSiMR9ZuTnk6nV)VBHN4F)3YD5)8TQw1dxVo8FVeMfJbmzAkBtdHPkoegN1lAZLhgQ5X9aaNp)Z56VpbLoU59petYTx8lKd(GtPywfsLueoRt4d3)HvvIRO8w2bI9ER8(vCIKYu0o9MSe(YbVu9buhUgri3PlKrXhXTNgHrVW5w8G)6w1OG(8mUDOqkrCs58SA8Fye57dk3CkCeH1d2HxdwxPEq9gwkqFis(d(P)4TYH5DVTug6S2WHJMZCHVFo9WJfUB9rcbdQibJox1k(SDHYjhDNx4nUx1Tc)MZpRE9QmmJsTQmnNglEBJVKmTlYBO4j)HRXcj4)vo9iPdRFI0hV4dNUjPjD1tFXtEu3F9tmwJcV5BCd0WUG02AeuIbJa9f7bB8NV3qH(EUp03x(Fb0xyIoJ7tiF3arddpzO8DieL)x5Zom1RjzeOGiv85gmf2qXwUXOZcp5(qfg6R)AFOOjp8OOnSQuaG0DDhUK5bDCglh7ITHrtEepDxriuCovSZFXrdwM0a2G7uvNuLy(aEaWUCmdDgW(TuBY9CCzaRFEoqX1e3uXvZSVWUVMwS1PuM4AKxFhw7eJqHvaQ9VJg)vdEdC4hEftYTU3P8B90jyLz1I8(GNHD9cAYbRp6UjFORvF3b46f6axM)nDpM2BJ4umZ)wrWFHVue9x9g1)ZaNVHcYSCkF8R2L58A6guzo)27YebNH1Ne3QeEH7JQ52UMNnqfgjsSEfJfL)Cz6cziF6)rqhtteopLK8RtUPwnWCmNk3ek5HVLvi3APbtuB)8UILi5M437DdDRM6QvwilLELhn(yRZ1QxvQ8O32skxvBSOLRbZkN3YVVrzQcu2Q4KsQ2A1eewWZym2oCUSBwTkM(wgR)0Jp6iRftxtc4RjAxXUVChUCT3DoOMnrmX8C(S0XSflal1g)QjV6ftoA8SKA2u6Heu7WWpmtb5T3hsWEtGBAUbotxxIipXLbiN9HNj8xD8KV6f2tya6)U02OeYph0zSSgSL82QUshrJW7s(OsgJboln4kZZQdXCubNL5ypVOb75pZsMVKD7TQhTojnzwf2zbySMPRBRZsnEkq0Kw12qej)72KIM21a1)vzPMGOUTywEz5CabbR4BQBmEwhMsgpJRft5cyo10KB(KRtUeRSs8sEf2JTNpnvTP0kbdChOjbOSsU5KXF6JW3sgi3yr8JvwZd)7Llf7Ka8j3mNM0WwwIE0rxFu0zfH3WuGWslPHYl3FcffsbdrQ8Cpa9lTsfjp0e3hGFFtek)E4rNuu(FoopWJBcwogjNeoApkmECVhfmzO2tPaU2FcdA0dru67tntSj)VHkvLOvIDcn117AG8sYXJKYIKaMKukQ0uY9jRfzTF0a2jaBo40hMdZ0iOD2TVEFlF8(z21lGVdgVFLvxMJ53l1um1vlR4(2oHCwlEGG88jt64uXOdlVcbOaoVeKoOto6FkjtEF3cbSDZT32xPBGElDp6LChgE(4RL)zqya4oU6lgUHxlAV2NU2C1zmCibIAOEhJudx4VrALIQHROg7kiVd6XnvA7idqmBXtSAT74yFGOLU8tQnCDxhRKCN6(yvQV37CNEoI675MIhvjfuivWQyFem6Sd9K(TM62BhWNyyv1T3gbvFiFve)YW)SqTWnPgnJ2l2q0ZTI)zdzkS3(XR7QEhKxE7TsozwayKIjaSr214w3ZB4qSNyc3TldDYPhV3J4Nr70liA3SN3AWWa31hLdrFFoDnr62wYCIuKSzlrIMVoRMj7cznBT7OJMRER2GwWf)(r2Qvekh(Yr0K9TQ6NvRQH0ENWxIjJbnjPFI(C6AWKQFxrgA311NIlXt9D8G54YpBBEhCkVbj86qen(qx8Vbrg0pAtqs)EeCK3JRB4D7zQeVEQzLc(uo1KrDilpZDyNjK8W4tmeEzw(Z0ocf)kF2h4BBWaz0TbAAPA29DDUNp0lnHFDoUT2gEANrE4P5AMT8iusFTu1x8V1vufPNkNWGSmHzCtFWDgaDSkR5(Hj0NkE(rg7nGmAGhhQniz8lUw)oC4(hmQX0lB(gjEVC41eV(rkC)HrX2Z5MMxWQYAjP5KfsXdblppTrvvnHTx37r(d77Zu1t3jVyVhfPyY27rEk4jJfGs3tU9Pur2CQRjGdEB6LEbTFpo13PGt7ZqGy8koRVpo2unGg4KAKdBgh6G7KBV1YjlNebCJcCYo0SEzv26PS08Sn19JBF1omrcpKRlllYZAG1yMtmu9nMV8bzmxMFZMv4UscOR(6mEyT9QHFFYtotpDTmf1qTpRF)0Jgfbv01m4(rieRl0NGT1spEwdgtrSDa5ucfpyO4BPSF63ER0utKNhVWBcemkqHGFrQjZbQMow2)HPgtpWQ7vJgpzeWoLyN26UWlu8Cssy6sIizD2kBM7OaICkJrqhLlD1E37YpI(q1jxtO79pePSMsqfU)YiEZ8wVO2zkl8VqilTMxkmPeHjyquQixiWPvAIs7okDkkqwfWIovicOUULBjmQBuwtx7D2WQq(MYgYPx1dTPuC9tWFu0U7fq9AsNUt9)m19aiydqO25MXqAW2Jp6rTG6mmHBQ2uIxdfyR82G1WJFSYQLNE8rJgPCBaO2EjMwp)a37mImL6a0(YCkEqCxZXD7g3bQV5TOMoGMdRf76IntP72O7E(62n8mOBmMgP)kBtEsQoWNvSRYkXS0pNswpoz1I2cAhojpYMTRRKIAdWPGwo77F)7SJgD7T7)iD9VKvp2e27PFc39Xg)G2(poYfTNtvhmHGZex4mPdCgbKuHD)1T3QVXHCEK20sUTo)M0LPU7TCJt4SJ8W4rFH7tNmrvvfsBT2rmU5)C3ueIocsBVhUlDYlfEk6UD0HZKhOiuUiEEPYtVf8RWfFowMNxGAonbt3akQMuImVb401eHAmSh6TCQQR6F79hb7PWZAhx))58u1oweFoptdeCKpNNYDcD0N1t20eUzBlWE(jXzaDQ4cThrc(gtFrqn9Rd6pLh01L2FhFxfP12pxEvIqXljV6VNUf6aoB8RHolJIXpAAb8n40vB3U1fxNxRBgMpYIQvXU59eUaOVNsNxuu)BnIzbXLLcAHi0Ru6p3wGrjW0J)YGx443h3iJepWi7n07nqoEZ7fvipDP4iYhf81q)Pgdn)uPtAXDXzL5gTc6ZgWKuQvF8nPxAD0XxIV9Ng0LLth)db3Tx)(JxnbEOqLCl2vRMiOv(1L59fR(PaV1fd5Hj1DhffNA7bbT8WIm(lyu8kZ5o5f(2B60gQR1nRXorkzmMKpZAQsWQfHUY30MXxLimnI4tUPSGCTQ65MPMJ9iYvqUZv4I03Oo11qNwmPHj9QgReSUebvEJrAaA4h7Lvu8GW8rJ9ry94424EI1Hejt()v0RUo9yVEdMRnBMB3FZnfpJCJufZLzHdU2u9(XthcN)OXt8jka0xq3E6(HVcXuwhD4XJ0q0tgu9e3RD2NOJNz4RC2tI54TrJEScegilv4Ho(eFp24QmrNIk(s7Z4aVRwPINe9Zg94hFC0qJzxNDwg)2tcaqNB61vLhjmb2yIJjqX9rpmntvdG2HopWhBf9vtPG7Cah5mJ1TEqk0YXzcFQpyj2PIQiE3tODJ8tCxMzTpJ(FXiQyDYJf38D4SEkpL(siMiPmdhTjWmEESX5D3OaebzYLrjlrsILVCfOsrOYIMQY8AhM2c3pJwSutHP0TxhMHGWUZbU1QHdk6TG(sJ1pn8)91G58WtVlfZzp)jIM6p5ll1EC3rAVyulEZbin6TZ1HGbkMvu3s3YciUvDRqrvqKvJJ0oUe6grz3RAHq(6s66vu4D37mRYznIkO0snHcqIQBQhhjnKCAnJYG4o88gYvGUhjTHKcC4lprSL7CtA1DB)Pk(NoVQcwpSIZhU8NBVnoxj87pHh8RFN2pfHIYQtbAFTCCG8CSwvvnDwmTu5hKj1tfbY)(U7FwFfJt)B)dEp(Z(TW(u0q1B7oGx588CIWdlFzsE5k2oMWWJEiepeH3vcLan2T(22cbxjk)h)0ijOpP6HeYscypBaIGhTx8Cc8KHi2zy0M7pCIZEseXtIpN7DnzrF3RKsFEyjKoKgCYW6rwSnBXp7axnq6MkEiXyO7ikYjKe1Q4wPMadAc9pr)zSCskoLyF4HON)2B30VCVhz2rqfA44j)KeUU36AbvPjKgCDYeQJg)YBVTRnVND6erov2TZc0zFXOSN5Pxcfcse17Zpax890gwE(n82(Wnwai2okxrgSzJw3Pez51JMyxNRhQZ(TA0mjJQ3uXBNUOWoCSrScQqKG3Odm4E1(Er54z7mo9susT9FKbBh7wA)EYh55AozpxIfYueUTpbaMljN9xm4XiaGewT4K9GEsfrTHiyBNQGX9xLBk2FxY2qhoOXY0Wt8)jnzPxQzJ3VG(onvT(YzWJcArUp9amNaIRp43P(nbTNSr1DQXD6Lh13o(Ee5jV37yXDdIzucDMOWAHFvxDxC)ImhkmUtXU9wdFJzFBIf1XH(dNaOK3aLbcCNhGxpCUHWUljdyx8NDlChXJIjDI7fdwG4b7r8Zitsldv8LZ86t3uApT89sWKJhTACW7)vzv1SkuJnFoWYiLDdbaInhoE9(My2WGygmvvaXo99602X1jvBSdtsddB5yaqWhXjkyFCvYWNWpKHlFxgUy558WHspPtZociNmCzh)A7Kozh)4a5bYocLoPMXo(9G(jOl0bLbQZwMTRJovDNvymtGfXAKrqz5L7imyygcMIaOUbSDAjaomhZ2nGuWWawnT(MIKn1OeNv4HTklhommiT6MnSQMvOcDtVUcKYEDfas8WG)NyOpfOUB4qbH52Xd0eHkL0JngJNs)YKo)YZ)em5QdWJM81a8EKwB1t)xTZxktD)OQv4dgZswsHwQcufkyI30ZSy3veHuE8BH)9AYQHv6QqVBz4WvMeBMIOjfOk)bA7cK9lG83Q1ucSsanU9OJJUW2vxDejKMcFEeq9MGok1imGD)Qtcanz8eMxVnykO3BJRyRob0jtXvFzABvffNBRAFv9uAV6AowMmAY0l1yKh8fG5p1i)YnNMmFURhlT65gwI976xjHEvrdAKcWrMkNHXWqURF84xkJPXtcbFdhAf1HyJ476)cVaMvmtKEiSRJy6w(dY3PtpzKEtQHyM20s5MSXxX3XjJ4jt7fVDqsmSp4eFNV3G5QwDwUBDqOFVB(rNnds2xFMb(L(55hFflyKkmdqvfnbWRYIwL8mdE97FafYOuScraII1b6VhQsIngBbEVlsfaQ6KfmKervmKTfnzyc2W7ypEdlbiu9soxe9nazFKbUj0EhsFYVE1Sgq2trBnG4zvtE10xSj1VXVX9O8e)EdTh)To5i1gJBZaa)QdujRVvJFqUvqBXjC)GywgP(WhoTwqVRWysl0PKGJe6(I0t0zLvJ3yxW6kgN98cYtUojL3oFbJgqTRDCD4CRA29hDMSX3rfoT7EUDQQRdUbwjPPvSEzRXDV09BKjkFFsqC7NVY6lIFoGY)arRvErwrw9Q(uet)tdqBa06HWvk8PhTZrG7e4B2VNo(IWZvbY2XipvKXKWXG4CFqaejLmTtsgRuq)2BfjOM1VIEac(gvENvWsRkZlRMBwrtDUDZLleZBuDlWisFndGeo91GpuyKKWPzAhrh43N2nX3mvliP2iYUcq4EZKUNVFN11)C9bxpoC3)tUdW2Z9o7EbE0Da6DJTK5KpsGN6Be4AG6e74T(AXMUMoilmvHetQ1KWTwORoPZlr4lm4GcPDTSVDyz9sgvrRLgLFgVBikAk)8V9An)k(tvTRrtyHLUzvCou(ZoppU9)(OL6FH33ti9P6uOGhiRLU24x6TIAvEDBbMlyIqZXJbh9w8WgcNu1Bj9OxYogoTWLHypXnZNIEkMBEyZGt9(s2p(7e(Cx32taWP2FYu6pmz7frwe3SF34T9K9nSr8SJgDYe1oV)TDNC(Gzlhgm8LQauEkMB1a(1k)lpa60E9LvbuGYHpzMkiSKwxmEXQkoBrgIWpyYpZj7zPo5cVr8(9moAVq8)R9UA7TnU9H)zjOyg(Cs8IDwkggCcqbAX)23Sw0II9UKDj5C7H)o2g(SBxac8N9jsQNfLU7CCSZ2k6BkIVtNefffF4hjvEHigc32ooryEXnuEARr6SB94YsiVRB94HFEIt5K98bzuRbm06RqT(y2(Ri25OTovzArXTPOj3uuoPrl5FksY5RXYN0Bizz1S(K5TxqDAle9cwc)0mLixop3OU4)rCEqGKV3WFwQ5pvtfsYjD7e9HcU)doPWx0e2g7nWp4vwYuL5wdQfcUbpXEeuj1IiF261dpMyg8q2fqfro1BTutK166lAYeolbaWTE6WA3Mr3xu3YX51BTwBUN7FwxZ1n5MRfjnC3nAu7hjpo3mxJoksjgWaab(Fh9EZOHX(5G5IMLlaaEqQTPNPHhSy1fOlRYa1nzoP)zzpTkmafCI3)63J9lU3D38jfuD)Ipqx493laoMMCP6)Ypiyk2h8elSiXizH4FIRo9Ktg8ldjoknw9UyWdpuByn7tXhwTzoi16fn9(hhBR7yRvLWMN83PnBN)Jsiau(prfxCrLjNwsGvaqud0vpR7BL3O76VmKyzTUBLTggO0)4rgB)GCSXjy6Hr6xcVkIASiIL71VGWDDsBq02QY7URaGtdgbe7Eua5CtPdnR0L3RGS8f7QAqhnZ)lb9eILse4lRtyOUMYM5aOsP7IOgxsux5AvqDh2JL9JNf7WuUvDyl9UU9MmDJZFepv0oYXzpq74zrzXyDlXqfnLuHWsUncF71Ys18Dc9)UDntp7aIeZF(oPjXK7JUPe2jaMGVNxA2KqpK4ojmD2d3dDlvLdje3ZRPQGNyJT(7BHV4rvf3elTdPR2UYpWhkHbAsEGqg3Zw1LVxPJ7s4NpcC1IZs4k9iKBT5dhaihqNK(dK(5nazZbswA2Q3B(G2HwYbNzwzSudGeR45EETbTI0n)a5Y8pdVOYlPRQwrsvitqHVYRM9M0cgs0IMcV9K1)xrDcI2n1UP8LQ8xZ)Rw5CUowQPXpGJJBbH3hXy3DOa(XuNMrdwLI)QSI20cEzsQTYRwo5zjiNFtCg8JpeOS1Gflh2JoJ3eI00j9e771YBBBJgcBjAWgpxFAcB8UCR2yUsB2OzERMliDlTA8MVB0MWlOwhmgNDskqf3zC)WlP0RfouR0Sv5q6GeYgfd)jkYGTKi1wGbeixTog8AVGQBIAxk(XIziIdZM8zBJUFJKjE2NztYDlAA4UdCJ4xlMmVUmiJj71qDPSCxlOqgyK7ADTAh0ORyX3QdCbU3gfrrzR8pjgSld0XObeUneIgb8k67n1QjJb5t3L4WGHoPy8YWTGXYodEy1jyHzFd3NWGenLRIfOQf9wiCQysvrA6UhSHJSgvoaWxC)GKJDycZu3WZPEhPz(Bf8NG0d15pvmZGKUggcPAb5sSrkooIGA(216(lKgED(LOH1wfAzscyuJbwIDWMZBB4bSgbsnDyoPcBtCm(0t7njHC6BNqsO1zjNPFaHkVsltnaHrUC1Y2S(mW)zkWn1KO4rR5niOi2CewLth7wQZmlGAOFGEXGsLUMrr3nOFHdJ88z9AsF7X25hj1NZF0QvzNSJ5EaC8K7WBFIEiWPs0vxnmJ0e51Kr0HcMiJZTYLztuPD8ECyRmNmFVQy5tadgZAD28ZHAtt0GVbcHcBvAE(aNzvKK847ulfyAOJD3mJoyoETvrKxwbp31uetG(SDlLnXrhoU))9IpTfeezFJJhCs6KPmbvlw7VCFrsIdroh6IeBDDAW7D8WZQH6KG8yAos7tIsi4d3M96i34)QW(yNeF96z4QJKAAuvg06BHJnQySSe0tJUw97a0xOE49EyJWNwRidXi1afncXUJ)yX4x)HPjGOMfSTe6vOdDvkFmhYibjOlK1BjDdlflW)7EcPjiAr6rpMC8k4jmC4jEg5otwVds(qIlCH9Ounv0u7a)pDwelmedBxsMBIXRCmwIRZleiJ(O4JaMBp8K12nx9D82GM24No0xD6VC2WH)QTi34LB9MokhpCZKwiZKg7)e5eYk1L7GueHXL7EcyelOQBP8XzF4z2AG1DzwQNXujiSL3n771iS3Qe7gcgmLGQqpotNFy1zZ6wHZwBAZ3Cj0fom7bkBAGCDidH3(IJgt5RjDSoCZu7b2vIut8LBlAGXUGIJ4yQX)H9vN9j1gOrjlM5ExlZv2VPBNzlY2AE9pMdL5N3aQGw9Bjy9VfGv88CmZtbM7tj)irWaoxMsYghdqr)Y9AIbNzDnb4NbWZs4YMC9h6zlHkBIBEeuvmQxZf0lqTaW3wyp0sqol2hxYSqqMUQ4ByPzrSy7xsQf59xX4ov1X)pJTsHlo)0GFqDs5IbNXUB8k7UMMF2xkODRMa(w96YjOVVxGVmo8vI7WHI78IsckRQC6SI6NZy0XVEMQ)xExouXkv1rqWLTlRuUDhuHD3qVdi0QLN4iF50EhW)lRM7Try9BYTJ0UPyuSViTOrFFhXhF2G)1YeDpblkpUTwwgdWdyKd1KnvBeOXfAm2h(dYH8R5cDxMc3yuvXO7LhEjW6tecV(D0bMM4uiNGsZ(ehY59stztyWXDpP)lp8K(d7f60Lm1Ft5CZSKvs9wuRQpgshyJNP11f0Z9cgAu35zfTaNy7qXwWgGeYa1yJJMmMV8HmPzQRLyXmAlXIEueJd5SQJDg1uQbB9v8zuqj5wCpxdGAZMRU4YQzVJxB3vjoeLj5aZfzRUdUMgnlaKfE)Svys9b3Qt9A5IsQiw82czMX)55Kqph0YHn0qufn65f3d2npZTrElZ1pWrk5tilGfp116N6vMYNg6CgOgM5b4VJOpD3BYsvi1fkQ8AAjClMVsiW)OIEiWdtrkP0RAPkJXgfHZiODHqQgfzOyNTBdwStc5608wO63XIQrZReQsSY6IflUYJ6bikUKRiRPBh7434c)iHaNhEOB0AJNX7EoHhK8ns2dpWvB6ZSITTlVSKlvHnizdvbe0(ZFqDerxqCOYMRndTDv4FM14idgVs5nxEUDbxa3Mwd4m62niUAMSloYp5vuBpGd8UjZk6Ur(TMmWz8bShGHmBtkiOC9UGs7t5uWprZfFvFM6f25jQ)4ezys22ZZYICLFZkOmnt6UpYw03fnk4NjLa8Eawd1RTNEWp2J85JSIeR6)1JBwhHovhiuJ2TkyLbYQ7wKpCaOtmNj9Qn)Dub)92zl7tnWwiTjYBLstPEE2PDecMbtkCKg(3jemgEZLiAjY1V8IUk8F4o3LpnV)COBTe9zUcEMouiw6dIBlNoGqAgHfDn8zOGWC0ADEsle2)LCSKtptjI3PToanRHXLtMGU8BQWsASIvp2Cfrmb5pgfJtR9VTDjbLX4DU9jbZGNn2PWnZAQAYn7DzW5UZLe8s6SbP3J7l21cE8QHhQtX(36NQuHRAP1sfL)cOmow3mKaZSuItmunFKvuQTRTJru)Ds7ivZnPFnCjnLtDZSDSBnoywssC)rh06QVikwpQW12oOpLZvyQtXx32VXwWQXMXO9dk7tfLTE9sA7i2A9629QS9ct3SGC4PCHjSjwv)9vz(YQ0v9gdKHVUahp3(DdiLkO1D98ZMVy3A2kB)ymV7X6vGFy73E22VMDIpv652CZyy)wTXCgLuzOIBDL4a1v5qcZgyHYGS9ULpCl12zAn3iuR9qds)(n1gmU39)i2uT1vCSEzWWm4YpjoLEZL)(lp9YLI)D5F)d]] )
end
