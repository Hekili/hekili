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


    spec:RegisterPack( "Fire", 20220611, [[Hekili:S3tAZTTvs(BX1uwr0wIwI2AYrjPT8yhNjEZHROKzMpzkqWhfXAqao4qYAkv83(2D)UVaaPKtC2ARAMyBcG3r39RV7(9(JF)V((lMN0WE)pn5Ojto6VE8XJp(KJoEYjV)IMBxZE)fRts)qYvWFPizf8FFtwf9J3MxMmh)46Y2Qu4Nw20SU(BE2ZUkRzz7SXPLREwD2Q28KMSYI0QKfn4)o9zV)IzTz5nFFX7N5pZV4KV(4x8(lsABwww9(lUiB1RGroB(Cg)1z1P8LWMl)ryrT5TdDw38232waF1XhFWMlX5BZB382xTmP4kw93S5ThU5YFRgE8ISRw2mTITkjROEZLvjnlzvBUSbEr4)MuDfRzCt2k20MYPZZWpOeECEsDZH1S0YI5BUmzwwEwZTBUSTgwH1JPb)hklRzWqKcVjmSS)DlShwXkAQfdXRkxnRTgx0BUC)SXSXWYCEzXxaV9YYCyyZAeVzc8NvS6LaeG1WWFbh0r855BlsMLdlR6MQSu4lsxYs)qwXvBUehy8tz3qJZhGjod3tlH3(LV7hG)wjUWM3Mc)WnWlG4x(G(Y5)pT4Yg(83DBv5SCAtal(QBjqtdUuzWawuc)1vLZz5WqWYZXP4WRaYgypbyb4Lz1nmeg1GVmSmZUQiBrwAsb8dV(DxaFWkGEtUBEvzX1SkCMXXAw7IfJ)xJRyjPIPpdNuCDlEu7AaQHyQK8vL4AeqIEZWvj4(g))WssGEiC)YKQ5PWIhwFxNuLHaYABWYRE3VzaBE)f5z1n14zGuf2BAAjGUkVPa)9FIoDblx4bWzMs(FYiC083)3EFdq6B(gZYllNpDrB1ToV1ZX3s)lxKwL1WGLiEwc256PhabgdhRQMvHOFCmEH5mTai)OzZzIoX8Lsksb8vvs(0uab48M)1OlPk4GgqHDfBCdB16s87VjPA9yXlV5Y9eim2hxMeyztNVWVaNMV0zA4mHQttQQNwUy6c4ekRQaMcKIFbtpkD8koqVOV50xGRlyr8volc5CCvEY8SKMs4ZNLmh5rYwSGL2mLVk9EmmuFDW9dqNMw12G)60)DlqR2UA6C21zPgBOoEhyCp(OGd8IC4pW92SKMMCJrZ9b4qCCWH4MKpWkakja8a830JGZVJdWKyBUMQ2ucomp76Sc20zmKEYyNf8fWH0LYxG)Bl4NvG)vZYBRBmW7EpchglI)2A2uGcyvTnjDdkFzrsBEJ6OBq67hbmeuK4ZZQtZwNNvKuDlC2F1QKI5skD9mMw2waFD9AX2Yfqf)8mYkHoXWhQX4b3Peh4XPlr5ralQtpdKRrVeS02xC4kRybNwgKoKMmNbKY6tEllBqACwYhKSthrpuY3BC9YSfnaJJPRlVHvbOdy3YMQxxgWBR3KlIUkBn)H)dX4jftaStYwbhYGf9nlzCzRxigaq4cocWtYiU9muckYUGp52IiZqHZSK53oE7ypQaN7BSzLc0tnMGZLqCfd9nxcckobGu69EfE(UaaLRtQ(GZw)IKRH18VWFdyxIVINS(dq8b80seuCtwnFpZf2JRc5CpwXaF72L0dqIv8KoHG0pRZT)Pgp3q426kgQSXu8t2C5tbe6hzPTnm9pij)MZavNMvwvahrARs4J6HIhAUuvpeOaFI1jlCeaUlW)TCL)rk9e4a4FT6bGe(LLTOYtj53KCBTjr1nG(IMyIXBU8Fs)e95Fb8UVHM4d4id5aPhawsvoO(tDPK22CE5KWljsGveXBDdOgnmQW(LO1nMzLC3G42pbOP9cGgaQcnSDvwvvjxMiWugvt1bgt6l9J83cOuxS5YFL)EbaSDRSWUCi85h5qQudm7AZbPH5O67(0k9UFEzoIhBJVRq1fNXAUHHkXR3CWRLa))8seLI)ntEuCIasNyoLaPPk8NW6m5wKgAvB6sbpHSMXHu3bfvDZYmqKpIqrn5abtwAXXfg4SFEdoK)dyLV82QdeBmq7DUHt)nU(7CXhAkYWBCUbl4kp56YS54pSEn9(cXpJnXMcHu(W7XCkq6dbYpaBLdwzXhcbv5HkzCr)CM2YmGY)fsrEAPztjjS1tZkMUGOfKVIRuVW61D)ilp5tGIHGc03cl48PLvZlq9X1ZrGhnW1pQVG6f8gMPe5z)IioFidcbwIREA9Yea8XMdF3mRtNATlI8c6TAFsYT2TDXKCYMlV7opxaCApd)O48tJRt9vvzRMYsZZwxBGrT)1Taz(v7WkVdf2xvwwKN1aqOS6vgCrT)5Ty9DYUU(cR9)v53UEjsnKudMWNX91J5HVGp2IIjQgtDtYBskbKqi3zGTu5If8nySNbF2rOIJklr8b5jPjZaM51lzSMPRARZsna8HE42a(Pj2vfd(eph1IMKJCnRUML7ii57xGspi22jOsmSksiqzXHc9uzOgss1ROF71YreLaHdj86Tn1zZzCrlw6C9ZsfFHrbORkHnv2)HPMZaJLR(f4Ibveldg6VxyZd8CUrpCdfuoEiH8pNWZCONCi)RHIKZj3fvEn3zFCPIc9sX1m9te5lSM)1L4GMmFEnhOSI8o11j5Tcz80BRfnGdqOnYsuxI5L0gTHgZ0K8uHRlXLvAIYya8PTfilwytNkeixx3ISU4QFM14B50Awfk1bbp2wt8zWHbPvyHnwLuxME3WpFvYhNkEhCUEeU5kM3cAr59QkSV1IYqqaF9588is8YqZ4xxc4iqMKd)ShV5sAh5PBaiB5y(w2W2rVdE4zux9KfsjbBpMI(XSbnWwjA06xhU8qeVj0GE)4yPZLyjeQSpbHBa9e)a6)7JhNvp2C6jCPXJHZxZYzU)QI8tbXeOo17mP7bEsWbEsGbEKbbgmbO72xVMnFSlqNVeuFV7J1d45ct)rKePJoswo1f94iNzquL4wH0a5uLCY75rclkilU5)Av2vxr(CbwYa7sjqwyllN1AaMOO1eC2vexg0qhH2tJn8XfQ3x(uCXrGjxLR73tN2sEqh0PdVGWqQzmWMpCrykaqACopkfA2Fre7Wd)qDjc0xdSFBS4hQOvCvs3IH1V3ClhSBGdBgXGDd8N)ac07PHnMyGoQ(phBXW2nSZUs)phB6WMJSvo7)phB0ir143ROAjToDYo4s5pzWMqXNbxJXDnQ2bGGLZ153onlnlnN5hOXq7JEvtkGIC9QH4U5pwdU7alk49kkVojKhxFtfzMYpbpwyPHuG(3raaq4nhcqaUHeH2UcFfbMu6grk8e81P4WOb2HENPjvG6bmn0)rD8YYiv1hg6P6GIHWLzL5nJnaZNpOfV2oVHGCTd)Jvu9SrxFhRryh4RnMvslKvKvO4kc0tbtyH2ICqBtC1QNl0EV6sH3ZN46v4)piM0lqs)bGA57MMKC0JZ2rntbinq)CiXu2hxNxwNX9y1K4Uu(HgvP9IMbKPtuhblFWXCF6XlU8hrYbcy7QS7NoGD)Nl(eaC)DcCYf3GHr3vV6WrFYIr37Gfip0xWI5wRqmjco26Y66SzOv7ob)EmyhA7SMQem)dkPWGRC1wfFfIwHcBG1LfuWOupVOD1muSh(d2Zi3ErrO3sAaytokxugRjD4UOXX0OW1ltqzSk3UTg2zChFwCBZs6VTMhmmZPank9Qkke)yINX(iSFCc0wOq(Er5Aqzowd6928wMHtCHrGvmNn3aXnuxMtevs(ME5jYutG6t7N6tZd2ofpglcE382u(l(eJbQV8groZZz0PJar6ZWZEhsP1Yi7zyvzJoYHjRqrW0lKwEnq5cdW18WEkDWL6euG5sdxpRhGb3HspZy4maWwj4WXCwYbEnCNPYzNNAQm81OpflZNQF56HnzHmIr98EhGrOdlFSm3H6JZHL3ojcwH)V0J9uXzgoNdqZ(PxLo3kI1YjHy34AJR2tsabMq5Bmfl3QGDCKHp0malil3HWFSF13nfzymbbpJgzq4zoQa8z(oilic0Sdjig9Gi56JuAeIQQrQFzAFnePqNfESvKr9r7CEiMsHYaGEXpN7fdrtV8AKpiTftX0EfS3hvTg(B2rbaxoxdAUvWwrPqSLzRyAatY7MsohdnA(dmdIk)bFkpt0KKyrEljixbpd8kEm)ch20orhM5NM5Rq0vUoEyas4Lz)njWucLKsbtllAQkZRDe5jcWgAIAnL6l2cPPzeK(Zs4sg)1skryOWQrOgPVOVOf2q)3W7GjK1FtcLmKEA5SDfk0NJerMmeceLa5A(IdibH12y5YkOa2q0YaP6ZjrqahqeTgGf42XcfXEUURXcp9pjh0lcC6BmjDXKxYkNd54eTsBkPsDQVghPqkQjscOXDXZMxcce9Kd3lBkxZ8sneFT(4iCKf30QY1gSrD9D0NEYDwrDl(KmKoxdxXFkHsYme)I8HiG7Vq1KcQflL7R7mLD32Sgx4GIAFB5GgJbMG515BblUr2IuTxKMC9g2bVd3c1w3FR0C1Cv6m2wwJ3ZozW7xhfUEa4F46rWWhh2kkVEpDQ4zUTcC5QTW1yjPcwrMmHdMsFsDb4pHLqiO21YNiPF0tsW0k8OXIWWgYUjCHpHKX6QHBaEX)DSGI4awloYh4kp0p7IrwjxHrTkPb(T)oAL5f02SwKfleVgYurXWGMd)J0FooycII4)HLDPA8FeG)WW5dG4HZ1X4C9mqkItQIQFH1YApBSD6D6IUf6zjv0RZH2LiY)B3YzTZHTpYMxl8uWB0WDpAfsucNiHNDBuO7rYHa(zyZLFhreLNF7bKiTBTgGUOY4X7hPfQTC2bsJEtIOm(kuzsVdnOA2mjTRxJkkl81do34HUMevzi6mgcWyuQzxxTgMAoWh7iW3jVMdKK0AvwH)DrbJta7u4kV3ppODKs0FoqFAmHxnzPFql8I2(Uo)mUMyd06z1j3USKmKAAwkGb0TfZro6vLnjYf7liplkxH1PLvPlnx8uXxPvDRZYVQBzj6ub3vyY(HfzO0MrBBm(ZJCYrc(a5vQjusoBQImPwxOuPNhjNUnR3OOzeYS6PCy6NDS0ArJHwjSlIG5j2hAqgNeb3oIrIkDVFRP79LmZpRarbj63X(46mU9Y8evxRaGDKOnr9n9wbwFEVxucYWDs8GQ7DwiYiep6Y(NYImeBR6idqJIUbvkUyUuSNoic24QJUVHuFp9oJRR6JO8O7APcbgBk5OAOaZuNQ(uOkQi)mfwac)3pILSD9)jPMkK8WH6AEvYvLfa8PczliJVLiBpd75Jr9R(cLJcLOfTwYqfzxikM)xkFhptTVTSv3FdiVrWY4Ld6FNd)2C5VTMN4HgQLaFhRrO2b)9)gyZNmYUu7enRHBWuKoN2AG2i7pt9wVudJO68RT6wrXKY1kPLYgDCQ3pDuxEPcuV618TWCkRVZ06jGer8JXzok)xBMoLb9VLv1Tgr5NHP7ZwD0jo19apuTV8)1Tw3rFHiMHz5xcnJjDe5JOUESz19n29PDuxgcOtD6OEsmGPQwwrivfKuxYC)iwFrSYyVGmJ0pm6WUx)vt3OHZiWMhG40T0gfrmsrS)Zm6Pi8QnKF2WIrGPRHlnghbku5VyRZQrp9mCvNnuSviZGZOLsnnVIAZrgisPLcZPz0wmKSlvnZ810AMf4fJ4QO92(aGeBEp1)SPDIRz8VEsGHjryLBqX9E1cxxQmqBRo9bFu53bnbi2AkUg5MSmxVSKvK9rxNxiwgZlBgZlybALm5(fKPU)Ui23ycZfRv(ZPnzCv3dbH9muRjqzR1H2)wwqyRPbnuX19SZTUB6wriHvjfjJxldRw03Dk(E0hi6Hti7ISIJnupou2C5vpodCPge7oedk5TGawrz7vlLR16d0LawIS9fH6PWzwAfPhm(nlYYZrwTyQGZD3YcnZwYkuEfSyYACMx)9PjqGPdyw(acOY3c)(kYbtllVrwR8(1jpxaaQ7g69jC)fr5iYvxmanSkRqoOD7o1aPBJRBmuCaFAaxCOcTQtgLej6)rh7rMUSVJ88zyPpHlNRbGkEjvZIXQVXiWBtuLQ6gj)oR(Y02QkkbTSArlQNYfQZXjK6LMzHfsw7LzujZNhoB(6sWMHgv9gJE1r1ot3QZ5HV1K44yu)qDyDL0erMvNODf7TeVrynRCtqS6pmBQe7fGYyGKybCOJfPYpZ1xt1nZKra1puf(fKR8D4fMR7Bs9NT0MwQcZm(kozczBh5OzXBhLUCnO2X2ha6bJ4JaVdN4okWuiVeTJAxsIjrkMPQYGXHUXrBfG)20zLfT1JBYyvt(QPVyDQ2cLOPmuNrXDIqOzpHxEarZCYrXj2WQmpcww23COOwSemc5aKsbR0qI7YQnbBpu6UYtxC2qkiA04eP1jlyibRQ9S0w0KHj36ckyebteIQS6pWzeQDdx8AIShFMfcf1NWgBpf2Pwjg0RBPAjF)c)UVfUOoqvhO86PuKMSsmcTAegXfP)2maiq)m079L(D11QXRaGU3IHSwmMDAM7JilJ45g)deT2J2OQUzEvKMKMwXOpsoTbJJqFwnFVwzbTDzykTQxgD6bKZSIs2wNWsNQ(ExB27UqfuwThTGc68neLNG40YW5NtYF6QMicNaMrQhpCjkY8B73GI4MXiPsM7cwAvzEzL4J1oWoq4S0aa7WOfCGvzjU1W2voIpY0QFaFVI6(UozfqKNz4IXiCKjkyRTIyOc6MUqpZ2pMB1CeXtTHF69yEI5C2ip(Emt(j5J7MQNSaQ)zRpNGgsJydDHjFCsANOeHsw4l6CXlYkYQxs2UQuMqnG945Qaol0N50oQ)RCXyNAX27CNSA0qfl(E3oFu5wkk9WHqTcQRyYno03AI5umMe2xsjBzTm2pwgRssQ4nDprxJa4cUsfGi(3EJgZWFk(Sl(V)B2Jf2WxQgh0zA9jnXqozNDbKbeIgopSW65BWBnaxmo(V)Cyx)EDDKnCppZjCN6yMeiUeHcArNIDL(LXpIgCdWTStx18AoL8fz3PQNuvEV(EYbYoksRt4mQno(ERQnsTQTadpykpJP4Pgf9wVrci0u4rJmHNFwhGxDOOT41fD9ZgmJvnPDo(FilTL(B0jrZUojlhxh8Zqy6kDRoNdZuqRuzxIH2Y8tP8jYJpaU9jt9LYBdMVZAH)KOZfjmLtqmdqzqU1DYvBpH77gWHrJbCnlL3SNmQnlZPSGXM7(Ctvo6wzll1pIy985dDdoAarqW47CBDZjD4ljKo0999ZWypF73hZXyiJ)CYrC)EjCSqfHOCulOiw6O874W9I5PYcoYJI3U0Hd)ocFbPJRv4xl6AmEkZlRPA1UWNgRhrn73H0MHTuPW9p6Ziztrele3ZrrsRX9goBa7ajQsBbhW69zqpSVCPyioH6I1KGh7SuoKuo0TFONcvDuYBnI61G87GyVorhKBFII4i9N2d5IDkw2vpK3T7XhZ57jozjvLvYmbYDxTIHDajY9Mc3zAeAgHTg1QEBPx5ZxJPDfcvCNjy3HRpkRxfnjtsPabxdu2V9MGJk6Xhzdi9d9A0zY36MKm03)S03FXrJpkK2Er8h8bwMtaB0zvzSfc3bVr5uZUCOSaUJ7bzsCTcuMzUcOdI7QBxLjCikOZPWQhUbkPziOdXA4MqbvjLgTxeiyFonm2hhAK9jpkd93W7zRaMyCxjBrLvMbflTkID2EVbe1T4(rf51OQBRUhes2pnsm7vgzGQQDtdi9NVjsFIlomisrigL8ZR)SPhAkJorw(hl8pJEKdxts7aeF4RZ4EjOtXUDAENHFHCtkvdN5yLgkgxwjXEdJ2JGHxC762f534N6gKPp8RXjKPcZj10iZwEhFTisNIn66(q56c9ruP7jARB5Ch528GZYll)wEE(3ZnsYdx4mI23Km8VvGqE0Fvwg973bnagMBJWOm1D4ET8wdka8Gagz6lKeiuj3Rjtib2hZQ5emEFmxYNKlJvVIbHcCK7FqLbWoa4hW8n0yC5ukeD0w(EGbcXOW12HTl03b(6yuPnD2l9EG3TFYdpzhntoA221WqguMXWjMhOGV9TI7y396BAXe36ppsl13S9Q0FQSQG9b5oTlljqKZqRoe7kx3JlTNb5pjTOr6eBB5w1cPzxWJleHUhE4OLbhSk5AwUtQhhcNgqRMTaCzaRSty1ao3SRDPp8cf1VKLVUVABnqD1s6oB44tubC0lnBu3DpOg8SQRXaZ00zhOBqhfcfUAVUW2agttNUessXMlnCTqo2xGVA6myCcibwzde5uBvQOsud5Sfn(W7fIBLupSe(7sKeHuOG8ueQNClVKImYIewEnVrM61NO2Easx6l7LHYnEzJ12vpQYgQL7KAwOmDMJaM99pdK1w1P)oZTVHBI1dK9ObSlOJXTtVuEUdpeH)K0bzNhCC9U50E2m7na)Ol8BvVz2qaTde896dLiuCqS6L7g(0UD3SnkCcFScLlMA0XGkSV97GAls5hoQ7ta(LX92DiyifTGXc)Evu2DsotdZFslSApqqeD66XGKi(5WYfq(ga6M1hDKRz9ylqWM0IHBsKtL8SKFrigm8lMLLwKf2dz9BmafY17U(cPN2mghwvUg7yO1C8MQKRDei4AiCm7JgFxN)Ebud1YL4rd4xReo4(k010u(AiuOwQGbvRXuHRiufXRzVQ0eu2YZgskQ()J8)9c5Vnzv7WQDWiJDpkXFVkJZ)CuzMdRXpRHlXRv8beZ(UPom1sEFZ8Tmsskg9f2966UVG9BnRDN0IBZ0()xo590wSi3WkvmfGNcntpq6b(EYtlTf(Zy04z3kgrXfEnO8p3RK9TVMQDv850EvupgtJ7vPtRLqHzD5uaMonHIbTf3qpT0m6yK7RE8F6Q)A5RULve22ve2h3HbEDve2dUKW3rLR)JOoUJRt32tLmeTt)DQoUjLImzmeSoUX8lh4PL0OmH3bwHxQLWCL2y)PEgvBTf5Jr9y1O)0ZEMeWDasbFwP5D80bugCE2KJEQoP1cFPrFq2IZuxDxDC)xVa0ByzAvYIMqgrVl3CMpkCmikf3pOC5zDCxsUNfBnd9JKRRaMQFpVhSLgFlFpEIoonBvcDPJBInJFC9rCRXhBe0IqC8jIPRzv0PQFAYrtMC0lo6lXmUPQa1Kdi7F5V8tF)p9DFdEVc8ROW6SvRlXY9MKW(fQg83xGXIhGJviFE(fXycqLGDjG5uS3lWlw(nV9hOk8FY3GcLlGzME8xO1J6F9f8tqM)KeydpA)J)4i1O8LoJIanPgc5)o23)v78QyIXOC8r78WWxmBEBpa55SfjT5nBhi(4DDvHXM6B)5FWbw9Ih2H7V(WoChFI94Dr2QxbWOBlAWOf84hZhYFOnblQK5T5TO)dwJbsI6jypEupJ3xidpPA1P(Hyexh7UfBe3UThBqGQVjDXFB)NpKVFsGVFsGV390X2VfM4cfgmwYEy2zKT9WCFpU7na746y3zBynmF9dYW88J6KY3GWhV7q5kNzq5)SroKn9mEB9jPN)WWQ)5pFxhMWmmE(ddPT3WmCAYE56R0c7l2k((UaQbSICbr9U0m0Ks1Mm2Uv59LLqVlrBtT2UfNlj7aaHwAeSdOGHUT8IH39BNTTG9WiVHV)Ey0B7HHZ59qVnl1)2fQLbITnoN9hMs27ohUWiRbPgseT8C1PDBxlEdWWbjwOC3d4dApzVsC1NER3kUdWoSgUVmHJOw12Ss282VNO4Xp8lLoEEZLOpZqcz0thLlYW6w8V8xKET9hXBMN3I)7LnnRR)MN9SRYAw2odnW)z1zRAZjoJKFeW)D6Z4V9BB50ahGDUOjtWjh)5xXp28n8)1Hche7K(hG(nl5LydvN5CpvjdX28mM4elAw9H1mCddBMzz5uE9r3Lq42rmb)qzznDtmqEjsCIgT9VEJ)f00(zJzJpq3zLlXmluvkjjyjUZQxcqfkXt4d6i9C9Teeh9Xo25SqMeS0pqoTLYdr4Zz3qJ1hQ5Pbg5r(x(UFGJ7O7NagMK2vFiVmzUEGLxQsywIP9roSjQ4zYydUKr3VrUNh0veDNYnmmLaYko8kkL83hWoWlZex9en4ldlv0polYsPkm61V7cIRiqzySReKBW3GJh5w8)Lm(f4sG87hU(fpIUuMPUuMOxmGru2Dw4UVd))WYYaDr0dOFdtHnXCTdLQTbrV6D)MfCI)9FlpgaZ3Ok0hUsD4)(kyvmgGKPPS1neKQ4qyEwTOnxEuOMhiey4c5CoxN9XNsc59pelYnx(ZK39GZOyQasv9fUQt4t3)HvvI7O8w2bcCVvEQkopsjNPxJJlHVDkWKycyfmNpYETiokGjU9Akm0foxbj8x3kb91NMr0HcO0HhkNNvJ)dJWEFq56ZGJiSEGo8YK7A1dQxZsb6drgfWp93D))yU)v9Yqx1gEw0CLlC8ZzhESWxRpsiwqfgy0ZQwbN1Fuo9ODEJ34EX8kC7n)S6nlZW0a1Q4bD6k6TnHYmuFG3qHtHJvJfqi8RC2rsVv)ePZCXhoDDst6YN(IN8i)F9tmuJI35RCJtW2a02yetHbdadf(dB4xO3qb(EEiW3F9paWxCIoJldPqxFsddozO5Dmav4x5Zoi1ljzeOGivW5gmf2qHwUbOZco5(qfe6R)6qGOjp8GO1SQuyaPl0rClZJ44mwo2NHJdMciEAxbiuqovSZFXrdwM0aqWE1kjvFJpGhaSlyZyNbSFlfsUNJldy)ZtakUM4MkUAMog2nD2InoLEdxJ86DyVtmcfwbOWFhn(lhmcC4hEflYnU3a(sTTmpCktZf5TxpdlNCAXb7p6cuFO71qxu56n6a3M)DDxapyRBvSY)wrKFHVue6xnI6)AGR3yrywUKp(R2M18k66FruP5Ma4mSKG4wL4vM)QUjgV(v9lGF7oQW)LGoMwiCEkj53KCBTAI5qovQfuYJDlRqIAPjt0(f4n0mr2oXV0(gkQwvu9(6vE04JToxREvPYJbBxSCvTXk2TgmRCEl)s1LPQoxRkkkPAJvFQybpDXyBX5s)uAvS8Tmw)PhF0rwBgFtc47jcRy300JxRYBphuZMSNyDoFw6y2IfGLAJ)QjF1lMC04zj1SP0dPr1JHFCMcYRzqKG92i3pDdCLUQebEIBTqo7Jal4V84jF5lSxWWO)pL2gLq(5GoJL1GnX5w19rjAeUp5JkRlg4Q0GRmp9neRr14Cvo2wsAWMc1SK5xXU7o1JwLKMmRc7jcmwZ0vT1zPgpfiAsRABiIK)DBsrt7kG6)6SuZHOUTywEz5Caab74BRBmEMhtjJNX1IPCbSMAAYnFYnjFalMr82OfWX2RNMQ2uANGrTd0Kauwj3CXeo3r4OKbYnwe8yL18W)(QReysy8jFmNM0WUQe9OJU4OOZkcVHPgclTKgkV8Wztumfme5SZ9yOpXkpKcqtCFg87Bwqf2dp6mIk8ZX1bECtWYXilOWz7rXHJ79OOz90EkfW1(tyqZEmIYqFQzwnf(nu5PeTtSZMjFVRbYljhpsklscyssPqst5MNS8F1(rdyNaS5GtFycmtZG2v3HAoY857Ny3Sa(oy((fwDzoMWVu)mvxIRIlv(eYzT4bcYZNmPJtfZoS9kedfW5LgPd8sq)ZizY77wfGTRV7U(QBd0BP7rVK70WtgFT8pdcda2XvFXWj8Ar71H01MRoJHdjqqd1rwKA4c)nsRuunCf1OVGCpWJBE06jdqSAXtSAT74qFGOLUEAQnCDNNvsUl9qSk1xAFUlphr99CrZJQKckKkyvSpom6eu90(TM6U7gWNyyv1D31bO(q(UO77s)ZJ1J)KA0mAVUMIEUu9pFilH92V7IUQ3j5K7UtYjZAagPycaisFJBDpVHtXEIfSF)r60ZoEVhXpJ61xkAxVxWcWWa21hLdrFFbDhx6254CIuKSfgrIMVjRMjBuCnBSBqRM7ERovx0n)(DGQvekhEYiAX(AvXZQv1qAVt8ByMXGMK0prFoDhEsfVRibR9D9P4givFRGyoV8Z2MxGOY7CKGoerdp0v(BuGb9J2eK0V3bmk4X118weovFxp1SmbFkNAYOiKLN5o0Bbjpm(edHxM1(mHrO4xfY(GqObdGHFhw1s1S77(CVqGxAb)YCeT2gFzNrE4P5gMT8iusFTu1x8V5lQI0tLtyqwMWmUBy4odGowHDYV7dKqFQ45hzGBaz0apouBqY4xCV(gC6(hm6Mlq2XmscEJ1RjEddu4(dJITNZ1FVGvL1wsZjlMIhcwEb6ZUQccBp)l8(d77Zuft3PVyVh1rLKT3JcuTtgBaLUNC7tPkS5mxtahmA6KGdDypo13PGZ6ZqGU4vCEFFCxl1iAGtQroSvCSdUtU7olNSCAhd3OiNSJTQVQkB1uwAE266(HTF1wSqIpLRkllYZAG9yMtmudnNN8GmNxLF76Liwjb0vFvgpS2b1WVp5jNRxUwMIAO2N1VF2rJ6au4BgC)aeI1f6tW2APhpRbJPi2oGCkHIhmu8Tu2p9BVwAQjYZJxHnrcgfOqWpl1K5avtYk7)WuZzGXY)ERJNmcyBc07Uaq4fkEgjjmDjrKSoBK3aaOaICkJrqhLlD1U)fTirFOA2Uj0LYicuwrjOc3FzeVzEFhu7mLfH3iKLwZlfMuIJjyquQixiWLvAIs7okDkkqwfWMovicOUULBjmQBuwJV9oRzviFtzBUmO6H2ukU(j43lA39IOEnPt3zHFM6sAeSbiwRLZykny7XN9oTG6CmHBQwxI3GiyVE3G1WJFSYQLNE8rJgPCBaO2EjMwpFp37mImL6a0(YCkEqCxZXD7g3bQV61OMoGMdReyDbYu6Un6IZVUDnp)5gJ5q6VWwNNKQd8zf76Ssmf9ZPu1JtwTOTGWWj5DGSDDLuN2aCgOLZ(HXFNF0O7UB)hPl(LS6XMJ9E6NWDFSXpOT)JdCr75ufbtSXzI74mXBCgbKuXD)1D3PVsQCEK20sUTo)Q0LPU4wUXjC2rby8G68XXf0jtuvvH0wlmIXvnOlsri6ikT9Eiw60teEkA3o6WzYduekxepVu5P3c(TVtihlZZlqnNMOPBafvtklMxdC6A6GAmUh6TCQQR6F797b7P4RAhx))58s1oweFoVsJeCKpNxYEHo6Z6fBAc3STfyB2K4mGovCH2JirFJPViQM(1r9NYd6(s7VJ3urAT9tLxNiu8sYR(7ORPqGZg)Ek0YOy8JMwaFdUC12TBDZgg06MH5JSo1Qy78Ecxa03rPZlkQ)1gXSG4YsbTqe6vk9NBlWOey6XFzWlC87JBKr6oWi7n0lwsoCl4nzjpDP4aYhf91q)P2fy(PsN0IyXzL5g9b6ZhWIuQvF3iPtSo6ekX3(td4YYPJ)Ua72RF)XRwapuGsUf7QDthGv(9P69fQ(PaU5dHcWKA3brDtT9GawEybg)fmkEL5CN8cF7TED(5ADha0lsjJXK8zwtvcwTi09eO2m(QeHPreFY1LfKRvvp3m1CSNrUcYE3YosFJ6uxdE9Tqdt6vDvjyFjcQ8AJ0a0Wp2xvrXdcZhn2hH9JJBJ7jwhsGm5)xrJ66SJd6nyU2SzUT(n3u8SJRSSUCzw8GRnvJpE6q483z8eFIAa6lOBpD)43XCkRJo84r6rmqgu9e37L4NOJNz87K4t7YXBJg9y1qyaSuHh64td9yJlHfDkQekTp7EW91kv8Ko)Srp(Xh3zOXSRZolJF7jbaOZn96QYJeMaBSWXeO4(OhMMPQXG6rNh5JTI(QPuWToGJCMX6(oifA5UzcFwOXsGP6urC)tO(r(PBxMzHNr)VyevmV8yXnFhoVNYtPVeIPJuMHd2eqMap248UBua6ayYLrjlrsILVChOsrOYIMQY8AhM2c3pJwSutHP0T5hMHdHDReCJvhi8M43hAFA4)hQ7YfGNUpfZ5p)jIo6p5llfo2FM2RlQLG5aKg86DhgyaIzf1T0vJacBvxquufez1jjTJlHUZu6F)ieZxxsxVIcV9VjQkN1iQGsl1ekajQUPEChPHKtFzuge3HN3qUc0diPnMuGdp5ubk35oaZhT)uf)tNxvnwpSIZhU8N7URBUs43Fkp4x)tcFkcfLvJ(Z(U04a55yTQQA6SU0sLFqMupvei)7l2)8(kgN(r)dgh)zpkSpfnun2Ud4voppNicWYxMKxUIT7sy4rpeIh6G3vcLan29cxQ5hOUw0(0ijOpP6XeYscypFaIGhTx35e4PdrSZWOn3F4eN9KiIN29AU39Kf9DVskd5HLy6qAWjdRhzbA2IF2bUAG4NkEiXySRLjYjKe1Q4sMNgg0e6FK(ZUYjPUPe7do055V92o9l37rMT(tHgobYpjHR7TUtqvAcPhoVmH6OXNC3D(28E(zte5uPFNfWdVyu2Z80lHcbjc6d5hGl)ocHLNFlVTpCR1a0fgLRid2PrR9krwE9OjW6C9qDW3QzZKmQEDfVB4Ic7W5gHkOcrcEJoJb3R23lkNaOZUPx6KuB)hzW2XUF2VN8rbUJt2ZLyHmfHB7tKbZLKZ(lg8CezGewT4K9GbsfrTHiypNQGX9xLBk2VlzBOdh0UY0Wtd)jnzPFqZgVFb9EDuT(YzWJIArEi9amxaI7o43Q(nbTNSl1DMXf6va13o(Ee5PGx6yD7geZOe6SqH9c)EUAxC)ImhkmUqXU7odFJzFvI1PJddhobqjVbkde4opaVE4C9GTljdOp8ZU)TJWrXIoX9wbls8Gdi(zKjPLHk(YvE9zRlTxwHEjyXXJwno59)QSQAwfQXwihyzKYUXgaInhoF9(My2WGqgmvvaXo996e64MKQ12HjPHHnCmyqWhXjkyFCzYWxWpKHlFBMUUYZ5Hpk9KonB5a5KHlB5xBN0jB5hhjpq2YrXl1mg83xt1G4Ml)w4vwr6jTux3T(fEax8j2(4KxQ)rk0CsJnGJt1kkL9ObTBnWhhCntgVUdg31rqCew5fHHEuxdze4d)V60iJM0dQZR3enPB7Tu93Ot5wY4d1xM2wvrr2ZQA)upLWvI7LCsnrt)YH(Anui1(ud8lxFwY85U(OXQldyXOZ3sAHKKoDtUAG7yPCo61wjw)4XNi9I7tIn(gMW3PlagXX6)mVKnvN6K(eX30t)e(w(oEDHo6nPwayAtlLnMgFfhJtMTqgZiE7oV567gZ3B4Ru7olhmniWFqK)oSASvkrLt)r2ZYsOJSteV8QpGCGDkMV6acBvKUnGQa966ilVtQOChEDYcgI(uLMvBrtggUFE)djOtsRYQ)a)eU(YORpuKB616rwsEzOM1a6nx0wdA4XQM8vtFX60WQI3T)TMe23m949NjhPqmULMm(vhOsDyRYqxIkiuCc3QmZIAle8WPrNfCh2fNCDasDmCPp)o35QYQnaSnqDftTEEb5PkNueARVRdXSp8(VpCUG)8)rNfB3yuHleUNOtvwMZv3ljnTI1llhUXU3VzMO8dXD3T7IkR2b(5akAOIg96ISIS6L9PKK(NgGKAyl1rDlE2rBD8aaZKTciEOSJsyhDKCVQJNkYFl4yq3CFWbOJeeZoK9wje7D3jsxgRFfThf(gvwWuWsRkZlRMBwFfEx0YYnI5L7S1WisMgJbjEY0aFihNlnHx7wSi)(u)0WXuKDsTrCMedH7LK4EH(DMV3c6BCd4(VWpzhg7axbM7f5r7WO77PBZfFhUbVVzGRDOtKS2eQH)5QwVSm5esmPgLaxtEF9fNxIJVWyakaB1YUiGLLfzu91vAumm8EZMOfHZ)2B08R4pv184mhlSqYQ6Mdv4CfkGtiVpAq(x4DHbsFkVYw6azL9029DYPOYjx1wGzMIiqb8icqV1BKzSKgL0JEjBPZ9Jxuu94f)qk6PyUfGndU07l1J4Vt8ZD(flnWPoCQDf2P971HSiUj5UE))j7By)25hn60jkmFy0UteOz2YHbJsP6rJNWRwTdCTY)YdGon7BznjeP4CtMPcjeP1fJx6CIZwKHi8dM8ZCYoOOtM5Ae9XaZJVhcILVnpmg4VMLYRAuvExA3DGmyYpDajdBhNY52A7vFF6uZujcnqIBIhKIDo6bhQuWyZ7cMKYYYh0w(XrkvyvMfj8uXOr9S)evrKxxJYpwQgm)ueLevEyQrvRiJt5HH16wn9zMI(uUu4Co5sN4tKN8p8Ks4s4(Ha3GpWPjjjB6M6yO6jbVdCe2xNIWF24Z9pMOhCFYfufXqQ3AOMyqRRpFil4rDKoQgVTFNKsR7lPB5IK(TwBBKZfgm()2ExVV22inH)BPuWizh7Z25s54WPqHwUEF5O0s)AZPKi3kohBJL91RqW)T)UZm7V3zxj5Kyh4T0VuILwPD2vZo)4zEMNRhZLLCX1sKgU6gnhIZKFo3UWwolsbpBshk)VJrVz20y)CW7IElxaCGGcTr)Mg(HfRTazSgd00lZ4rxK)uBWWNwJ6SCHhcNcsWaaiGHAA84hDkquz(tdjOAA6dsRHb4GapXy3hKHg)F1dJ0LepQzlwGQl8ACb4oc6Ga0SQQ7UReYRhg8tBYsMIRHmwg1AEgjOCJW27c0Av8Fsa5uVvcfqjHLGhZizvA40e3jrdEJ0eVXjKUt7ZU9JFl2GuruzAhdSM9ISLPTSXE(mh38G2cWMQY5AQ5wfh1ubVwUkcp69skJ8oHM)B3ZWD4qmy)7)uAmm544nvWcbSh47fvM1i03i3xcddJ7(n3wfTmG4VApXgpI110RHWt7S6YBUC8OXgWTgOTW9JKMqqEtPykwWtjG5gl7qYBgphJCeyMRhSiXyjMhNN3XTkUAvc3f3(Hd4Af486rtKH(ja6vbACAuyY9(GMMwXH3kwDVuhQcPKvph5qdlDlGbUstWSjvf4KD17iTnKvPWt5nREx6nBj6HeHNdY6sCu)I0rUYft6k(5K)xTkkoD6vsNUpNy5ak1pJXu8qf)ZjQWxNB5Y)RQMw0cUzsBUYrxNcbb0)FiXh6HNve2Ie3kgEEznjnQSzVVoEkCxSC4rsgCWVRpnzs6yUuBmLVll0m3v7vK(inB8EFpOfHxs92qm1BKwGAUVX9J4SYEx4JALfVQyufuXyOA4prjlOJcPUMRWa9QnTbVXdOYsqUA4dlMdkoB2KxBxSjCMez8FMTk8SKPHRoWjIFRCX6MG4od86rJSSIGdyPg4U6EnzYcM6vU5FBkFJUNgfXaAlaYgdLu8W7oTG7aZABWEf95MA7NX4(RBJny(rwuoFB4sWCzRlnS8j3yw3W1jmUXl5kPsfz5Ab6HYf1LPL7EaSoYCu5kVV6(jjh7qe920WZzEhfB13l2FcApuF)PcJouvyWqinlOqcLjXNJvYMaTmTuge34xdP7Tycssdy0W5UfPy)l7AedTgb8bG7wurYnEA)7RJlKqp9Tlin0Ay8BAybOXR00uJNpCxUAABMFgebSe2n1Ma7tZ5dioP27iSQ3FBo)3o3T6lOFm0vOj1c6Sb9nmiY1N3Vnnwa7GIK0Eo)rRrJDYhYDb44jxHF8f6HyPirBNZSzKErEl5DDOIjYRDRITYKOkNiRg2Rvj)6Rl3(eSbJzUUA9LqXZhnE8GsOWE5Ix8HzMfjfp(b7sLFD6ZUBwrFyoFVfl3kPySJTeXe7F7WvzlC0rO)F(H4rBHkj27y4KXPR2JesTy9NRtLijoQzCKls420Rf33WPx0G0jH4X09goLcLq8i9y2mgCtjKcou9s80BEdxtIutN0WaGxlOTqvl(wWon6y1VdzdNAYONGfcFzTsmetuds0ic7E(Jft8(NMwaIwwW2Zk3Hr6vz8XAaKYY8WkjecDhvdzG4JVG0KoSinratjzeCfMD4jUg5ktoy9sIlsCGlSgLQRNLAf4p0L5KWrmSFoyojgpYX4jUgQ4qb4q5nbC3E6492D)1J8YGw24xVwxD(VEX0P)MTk348bBBhLHtpmTfsW1B)NOGqwRoCh0IiCU84laJ4bvttLpU6dpZMdSHlZY8mMsv1wF3QV3GYEloameFikfvHrCM((H1MnRtfUyVPpKYvJh4WCcKSPX2XagbV9bhTwY3qfAm4Wm7bwvIqAVYLfnw52qjyCo1zIqI))ukTbzus2w17yzoEjLoDMLfq171)ybWdbVdmbT(3tS1)waPHRlWcfd2CFofhjczGfYki0eyak7xUhtm5cRJjG4marwcN2uO)WiBjmztCYJqQIz9ATqEbMfaX2cBYhcXz5P4qMncX0vy7IEemzhvrMf59xX8ov3Z)pJC98RV88GFq9LYRNCb7QXBSBRl(fKLq2TBbeB1RRwGX(EdEZ4WxlodhyFYnve62uL5vn1WjX0MF9kvd66UcGsTueDeeY2T1QWUdMWECK3bcA10t8jF1Y(VG)x2T2BHW63KlhPdtXSyprAsJX(osm(SXdOLl6EkwurCBVSQJXpWOaQj76Ni2dl1WUn8hKd53ke2USeoXOUMX2lpGu417VpwlGPL2ojLM9kgWf9stvopzy24rVAW4rt7hg0LC1FtfCZ8Ku9AhitZHqfcAImTM4YU0lzOrdNNv2ccrYHdajKjQXgFn5mp5bmvEMRNyXCAlXKEweNd58QJ9nQTsdwcG6zusj5MCpxtGA7ExDXRv7UhV(cOsDiQtYbMlYEXdCmn6waOl8hR2H15dCQo1milROAo)9LYIL9ZRjLEoOOd74sOjA01lohmRi3TtJkl)hiqkflipGfx116R6ng(DbdodqYkEab8m6rNDtEkMEvyOYBPPWTyjmGacKyLjypmLPKkp6CtMJnkdNrq7IDxpo232DbNYjHJC69wO53XYQr7PQnjgADXIfh)THTzC1mY61TND(BCHFKqHZ93NfL8Emr3Zj9GuSrYV)EoYZn3k32U7LL7svydsY47GI2F5d6EJUI)kiE9ZEdTnnbVYACKjJxz8M7EUJXUaUfTwSZilliVAMcomYp5X6EVGduVjluYSi)wBg4C(e2dWtMLfLd4tWnuLGjFf8R9uXt1Ft9g7shZFCImmj7lR55roYVDCmr70U7JSf9zrZc(zYiaVlG1r9gjDC(XEM)(iRmXQ(F95ERJiNAceQrPtBwDGS2Uf5bha6eZ3KEKhCpvYFVD12ruh2dkaIIoz0uQRN91oIaZGjford)9ecgdV3LiwjY1qFIol8V4E3vSSy0AGo5JEnxbxtpkflJa1TvlNqinJaPUg(musyK9)Cj20)AbYjMRuQ4D4DAGnPNxTybgYVLcpPrk1CU5iIykYFiggN26FB)sc4zXJU)jbVbpB8tH7nRTMj3U7LbN7ohsWRPZgKEpSNyMf84vdpqKI(N6NIltv9CtPHYFfmghlLEjWmRK4ednZh3kkT21oWiQ)ozDKI91h1WUK2Ut9W8DmRHamlfjU)OdAD1hefJeTD9TdAKQCmNzQ91D9z8i41y72O9tj7tLKTz7s66i2z76o(MS9sdDBtb8uoXe(eRiiyvLVSlnryyGm81L445si)GwQGElYZpF(IDQzN89JX9UhAub(PVFNyF)A3x8PkB327gd7ZQlUZO0kdKWZvIpOUQakK2apuMKFY98HBQ2nxR5gHg9hAs67VT(GXDV)FIpvp6go2Soy4n4lFs8v6nF5VE15FzR4FF5)n]] )
end
