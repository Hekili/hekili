-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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
    -- actions.precombat+=/variable,name=combustion_on_use,value=equipped.gladiators_badge|equipped.macabre_sheet_music|equipped.inscrutable_quantum_device|equipped.sunblood_amethyst|equipped.empyreal_ordnance|equipped.flame_of_battle|equipped.wakeners_frond|equipped.instructors_divine_bell|equipped.shadowed_orb_of_torment|equipped.the_first_sigil|equipped.neural_synapse_enhancer|equipped.fleshrenders_meathook|equipped.enforcers_stun_grenade
    spec:RegisterVariable( "combustion_on_use", function ()
        return equipped.gladiators_badge or equipped.macabre_sheet_music or equipped.inscrutable_quantum_device or equipped.sunblood_amethyst or equipped.empyreal_ordnance or equipped.flame_of_battle or equipped.wakeners_frond or equipped.instructors_divine_bell or equipped.shadowed_orb_of_torment or equipped.the_first_sigil or equipped.neural_synapse_enhancer or equipped.fleshrenders_meathook or equipped.enforcers_stun_grenade
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


    spec:RegisterPack( "Fire", 20220911, [[Hekili:S336YTXXXc)SWYLGjKiHiafTLDrYtPiz5iDCSvz64KFjWflgqSHl2fN9cPykw4z)B6EUFDxas5i)vPQeljS72Zm90tFV75JJ)4V9XlMN0q(4pp5Ojto67gpE04XhD0l(2pErZDRjF8I1jPxNCf9VuKSI(FFBwf(J3LxMmh(46Y2Qu6pTSPzD93)8NFvwZY2zJslx986SvT5jnzLfPvjlAG)D6Z)4fZAZYBExXhN5FKFXhViPTzzz1hV4ISvVMc5S5ZjSxNuNYMcBU8VrNuBEFFh1nV)cY6gYQzKQnxoE8bBUeg0nVFZ7F9YKIRi1F)M3F4Ml)71uiVi7QLntRiRsYkQ3CzvsZs4RAOVi9)MuDfPzut2kY0MYPZZGpOK(48K6MdRjPLfZ3CzYSS8SM72CzBnDAwpcb(pvwwtOGiL(MuWs()APlKvKIMAoiED5QzT1WmFZL7NnImIonNxw8103EzzofSzn83mH(NvK6Lu0aPHa)ca0HSX5hksMLtNw1nvzP0ViDjj96SIR2Cjay4tj3IW5A6aNbRPL03(vF4NO)TsyInVnL(d3sFbytMb0xn)F1ctB6N)H7QkNLJlc6KV6oe10atvcfGfL0)6QY5KCkii55WqC4vuAh6AIUvqFzsDdbWrnWltNMzxvKTilnPG(dV5dxq)GvuIoXQ51Lf3qQGrgG1S2flg9phvrss5dFgmOW8M)O21uSgStLKVQeMJ0nrNr4QeyDd)F6uIV9G79ltQMNsN8053njvzaIS2eT86p831WnF8I8S6MA4GqQC3B66Lj1e6V9Z4XlcUFm)J)f67uL1qOGfoeqNTQpz08YBlOe(PW)aakLeSE6)QD(vabYhBOhs2rqnl5QPLlMc0cxxda64Gac(KBitjfKviw9C6rLnxoGJAJmzVHsDnDg95a8FHf8lxtzsqAuVVaXYopxLTM9Z)af2RO8daIDk9zEjqXQFK42mGcGr4bhgVMVZCrl9H)V0PWxt)H)cDdRgj2HhnNE6OAvwHaOmwh)fag03TEzzlCSAgboOsGDZBsYBjUOujZGN5bz0wLWMGpLsItpUvspRsrqE)(tD)E5Zg(XlOZc6M1IPxLohiEau1ugFxYNAifu6YPAKz8VK9z3UmlNmfydqx9Wht3koXARW77zUl8Q5ZR5CeulSYf8FkaQwFxcq747sagHYVmTTQIaN)0F3m5tXn1BzBh1uESn4WZ2hxMvR)zJyKujZNRt7w1wqOS0UImQUTykWURE6m(eCehfG0Y7Z3bCFnk(mz(DugiBU8(7vN)hfb1JNrOBwgeiJhDcsla)(QKpjOlcmQWRmLUKtVEZLhg(T4VXqKmHtLkNH1xpBQy3YLiY9Cx)iROeqFJfbKbPYVWKlkO3RfYbSpwbNCBwAUZlENYI87CFtK9DAtBsU5xXitsaclumd)TdsxUUQmDKcbKsfHmL9pMcSTP8LqrKiwsrk17n(a4Fa0C0R2hkrtaE9BTWRIzybHcL8P13vKSUg4etzZLsQ8o7eQGKQHGOtQV5iHQAHagD8FzGX3fdPTy4IhAsYbDwaW8DbbdDGYNc0Y6t99O77KgQGII2A60Nun5LtFX60GIyupi8bc6kEc(ESP1iGpaiVBD5TKkJd(s(YMVIoR5jhXy9ZxWUJQ1jG3TiiPho9O)sciWzjvC(ba5lGwqwERaIEk)kI1XIsXHOySBbYAeASto1jliWPiQkxj3bl22IMm6Wqv(LuzlcLQyDlO9zw91mUZKpToJr5oc2shFuG90f5uCcCE5ABb3awWGREnOl4TfhaZuc7mBD5kcLrom7fRBKCkPb)TSMrDPrJ5EyazRWGnfoyGVTJ(mNPDMv7OP(sdqbBNwBXOs1eP05lPZzXCDe)7uBGtrkaflk6Y9i1g4AHA74AC7uNunnaOKsHYkHo4(EGNfsO5ryTrFKic2d(GI5TusmCFMYElTIGFKyyv04u1dNrzbIZmB9yFmNzQHSoTSkDjoG9tBn10yzzdvXb62W1tRxtT0QEAgqldMoW27JZynQGKtLF)(ikuPE18S60S15zfjv3bFYkQ4yfFwqXjCe9(AcvRc(gtxurTztCEP)S0rM2Ehs8mcQ3KN1Yvu2G53nnlnlfe3RViMtWjP5BaZlDiLwEd9JOtXcsAvzEzf)JLZR5KKMLZkRkik6afcq9WGaM(hnlVRYcSRYQQkRQr76kRwHijPvecWWOWgTcDqWinsJbbFMI1XPbyvIuWglfoOy0XuMrK0wgp9b(FgzQ(jITAmehp9pkwp9bmosou(hi7h)agjnjpbwuoVW2oAESQuQMM8BSKO7ttDnD0xseonskFhK5lC4YISIS6LG50axnBtiedUXPARX)xBbl2bTt(a8unDDyZaWXn22rM1yO5XS2gHPJU2AmVeGp36tqxe41w5Ongtgc6BjQoelqVVvvUs6kq23ERc)WEk8Sl(F)lMWkpHY12vjhtEBU8M3ntqa8UTjgDjnrtozwXcsvb10b6BMMmNyWZDpTbfoYnfpkqxaL5cAxgpm)Q6RXB1dxmgcqYHmOopQ3l2r2HEfaYfUSh)jWAOggFnfAeptjHv7Hrf7k8p0scQz7021IVK5eadFfCokJDiZ0JWhtvyzRJj)dH28VJVHrj5y7y0dam312co100RxYJV3b0UO3Lx1wKsnKgigQ52xZER3kqoQZwSt12gq6N6kXXZdsNbQi8ucrrrqlsi(8dg6Wd2EvsvJLDB974YaU756brUgaxtsBOauTjynKfeYC7NRlkpUsmgI1dyy659DbouDKOpM9uVmBbsK6Jfm6n8l4VHKpSWNCg2ukONqJ6G)d6Bgsrz7vlTj(sUjjlhMim(QlAZbEYSvfWxxqhZ3u4eJmo3SbYr2aqyIohsGg19VfqizTobYxBhx0fZXqen)5KJ4(DsGBqY4JcxoHcyPJ03N93tQGkNiiDozQCeTCyDEhU7GofDhu4xl4Cus9ysTiSFqNNGlnvhIA2pI0M(nvpcCP8WVSLnbXOA7DE0fRXt()vGLXf4mV2pBgWPyGF0aLoZkPNmVZqBQ9DrlCSFFzhQnhLSs33zB7Ha0d1T9ubsPWGHio027tsfMtMNrfts3ytQU2wHz2ZOOq4HHDbFIbMgcQjsDdSIrnfYwTIqHud6prU)d1cqdxZ(6rBU83qvRzHKRiPb80m8nuwCuqT2DKOKJW8dJEncrkSag98ZTa)CZfruhcY3fMGKUbooeMC)zDCq5mGKh2k6Wjz6ufb8V1Ko8VLl5Q7sneOd7GkQzz3ahvhnMB7TcYAyJaKYbSQ0GsERMN2(1s8wDO)bYbOxAGWcppStyQSlx7HpSSKuKr5Z)2Cmnesxc5WrTMvLmZ7sZsYfwo2w3YiOzQEaJYRk)HrEdeJp5brT7qZHfmENJKtjnVmWM1C8U6non0BaXrK)wiAFxm8gCLF8WPzyVlWA5apQK5Y(HUwr3eic4l5tz1S9vNpMXtb9QnrpkWCUqU8fE8C7UWdlmd)FMxVW4X18HdOuNF)oihb3CTTU)Zgk5bpD7X413iyyJeSnc9ZgsieDHsh7DHQWZxh6ukSATTz5Z2Q9ZEWNooKAIQ3YKT0heXwIXdQ2hhgBFck0xeyPi0yu45otjc1C5exWCtTdMDxd5LxPa9)SvpLdVVriUc7vJEyOHdLU8B2EDOygIHA0ECinAnfG5ZbeX2OC3Yb9awsYP07xrXIvyUKzAyHYRwAUKq6YcnNtaQPc29kC)lIHRjv3GzjwNkM2uLCdjNJfJLZxEulBlqWi2T)rY1lTNVqrESTwRIxrpv)C1Cq6mD0PIchaXqc5KfnU7yIKz1zFg(DX2mUTIU3VOoBoxzbfuoGB7IwkgqYRjr3M86gaFY32CjMiDh3)Gbhc0X0xEEvYvuYRPZQGqc(rGjjf7UiPnV5JrZI0Ehzw9G(0wq)AKGcLRSlAN)7CgtISvHYqcZDt2rmwEH5O6otXofhBFjadyujtYsVc4EenPb3jnwOX9(H49PlC01esMhxuXyXaLmLn)18LfsPSdwVFbLzHT5VoPeUWYKsa7EBwnryYEJJ7p7bIB)oI))5cCRmV1q3xCcNLU9XbjHSmK2wlX3iFGs2Ds(Tj3vVjsEcoAZL)d8NWphmg5T0)SC1bSLTRsaKKk0leY0OsFCz0FlrKnlyFIK0Y1OY(Hf9ONxptVc)Y25HtvPNPJINcczTChq5D0dD5YOE4q0xjAClaiupDbIqLSjACtAyXERRZP9jX(VXElgt6FJ9EE2y9Ai9JhMYd)wyJbwEHmlUZL3RYRfUjZ)Imd9MqZTeIHuoqfJAr(Sd)n3CAh1(Gryku3qMmFRAbzGiZaRSKBxoaF8rwKbuD5x0MdkVdQvOth0VaiBGIElml)DwkRielNy5sggdA1zo)4sM)gbKrYnLzZHFy9A895m4h5p(OkSdx0GNqQyMOfqiOOwTWalN85qPKLGFUzAy8cHGMOQSnWR37Pkc0eoJCVkhel0aZHzjZH6W6HraCcDuwSGKksQxh43eoTEjROw8qOsplRMxa5YAVNmgPtKdyyMo2nxZZ7dqyRrE2T7mHBIKHR1ltOOjYC6BpZGnqQEug6)6mg7kEqQSk1St7a8(JYeYzJVIdTgA8KwRssSQSvtjP5zRR3UD0xUdlcXe1yqB8KqQs(YLLf5znuuyw9QTA6DYdy6zoQnEsuv1b07wVeq1j11zRYY5fbqQtKP8ParCYDDIjkreWaMY5PCXcRWQA9mwQBouIP9obB8KHRsuEsAc1uKP1ljKMPRARZs3oeVel6bqnEY0vhljBzoCoburJuHcakloKRVlb0)tO8i(BVbmzybkL53j11qo2x224ZyrQgL)Iqb6dKogk7FtKJPhy5w(kSOcaEZ2j1By2WiD7c6WIeEHGkt4gqcFoMSCL3iJXMN6TcPDLrBlbRnlaPSclgsmRy2OQ4kfJEaa(wiO7pMxMPQRQ0K8uE5YctR0ePrfWtBla2N0fDkxyCDDlMtCOY1znUg1TMubsxebnrZQegjXCXSA6n4K6lHtkclI8BIipcLbZobT63cgRE7moFYjyZpRNhquygyg)6siXcHKZWGj3t2CPwoaRPbauEAhjkJmL7hS2tAIK3M1uBUMcfuBJzDj1LOrypIR95(H3rKPDap67qcur1t8AOKRhpkREK(WZD1M8X0ZyZYj2)Qk9Qeyh(2K8DMehWt8c4jEa8qZu)cQW71RjZhzJGTs5e7hB4OUt0yLBG7B8KKNsN8eSaS6M2CGWLDNkfH(apyywuvY1aJ2tN1)VvLD1vOVJOVeL3Qy3GBwpJpShoUGzhmEBiljWilUgx(Zwrt5nubk1BK1Wo3Amzg)6lxOz5wPIPxaHnSGqa(LKoFOmDBKCbPBUPvTnWeA6)xBsrt7kQ(R3KzQsTK(XwjDdgw)rZTurLfzv04jj7K2RHLHdvHKzjnn5)PyfZ21SN4nrY4PBtUgIbrnurlfZ)ZZA0AE3ejHKOB)nvTP4cyoeyaQv4GtL)tZAn0cOXtQ)if)1wmlVSC(0eiAd3z6ZHVSxUUt9gpjOKCHMMW87XciqAiJDiQJliUrEo0Bo9fM2MgeInrZMP)4rAkSa8eWIdwk1eY1OyvRnTO8MeFUe9TvOM()m9XCL1fI5(rS6YOI0yLxM(IUZIulGJa2zV73PkN7MNyz50yiLjncgLjQ7hHmjenR5nAX1cfVUcnQcw9qUgcoASaYkbq5g10fR8Nslxn3VGLH4W(xBHIDcVf0ysfvxmIARzViVSw(chDNqlXKasRzL5gjGY59AYBMu1DTZlc8tKep6)Vb3gmlW(dezpOh1oIMMymmXuYNwNxwNXCVtK0J6XERs5Anpj)sK689XEN7Z)(YqlM(a5aISdNDwp2i7Upx8za5(he6KjdTXtkI13Ui1hOZswy2OZO7CY1hWYWY66SzG58wryFeK4RZAQsGq)J1vNYpCvSHflnPYvRllWOujFErlRZYb)G5iYmR0jp5fbCYkbx1TDeBIyA(Ktwpr01fppxwNW7fwngrs8QkmpcGmDJ8j66XkcCEJ2TDlfkEP60XM7GizMXuDC5Z6MYtX)1QYC4bUBEBk7fFQgG6ktneJC46UYSRmnwe)C5iSQSrf1WKvGEm4l4w5(wDfSy1UVr4J8Hmyoy65AGtdbBKiaJzSJ98AA5joIgukcFd4pXYCZk9QpdMplBKpVtameCw5tezRtxCnm80zSoMMBP4fUrP5KIIBr0ooYF1W50gX2zDQ1fmOnaEpngai6EgmshEs)RXwyyZwLFHsjo4dcKxmXQ76U4fC(z(HTKuQl6NZ9XyYxga05o35obw0Flgjw3Odgey6emJ6HUrjRDoyK1VsYTo7HDbElbkxIp7ST0nouSuJUDOjE3jF2DYXu)5xIR4EpLqEpQa3(SJeSUZRjjGitknqB6YrSTSas58rmrPvowVJa60Yfz(tg1aqSoeI1tllAQkZRTKHZdNi4nHAmVHSRX)maexWM3qE1Gzreger(SN5mDVv6ZOoyJ24jHynBmbOV45bu9T6KUMja8bIzVsFnPKPOQQP1jZ4jg023M)8q5gOe86PdNqhhPXnTQCTgB0(1DNESi37S1jfGfDWJaBlFTqSvuTTVEZ4zOPiWoRRMoonE4wOq5(BLoL6ZsNYixZg5owj9E9APk0JjtfsrDlMl)a3e1zsSfpG5bjqSHf2hCW0Qg(6d)dBpc6)4WwrZ35Ptjl7TvGltTfMglSUpIMmaVP0Nqxa2t8wZTLD3DNWY(hdvShBNGjowIn9P489XF(Vc96AgY2Gl9bD1NKzKiHQXg05SineVREGGbSo(VH)jgs2J7x2LQ2)dG873EEpiE23UYC90OXuVGQ09mtVt7T7kvtEOtqBte5(TB5OgfS7czZB4oo4TQ9chAfKfbJiHLTzyK7XEXTRBh2C5pIer553DWgEljsdaXOYyH7hOpQn89bqJEBcVdZxiRPalAq5OPtAxVguEM76hySHdInjYoKVfm4OwKAUFTdjtg0w51SNKKwPih9FxuqyeRw1vJ)9Tu78G2sEu35a9PHet2KLETsmjU8d78Z(D(mM9I(ugRNMZsPrlMdC0RkBKz94lqplk(EEnVPn5XIVsP6MNYVsIVd2utEdlvKDQ0nF56(i7nRWcNu5wUNIa1NmiPIykJTXonj6X64M1B1Ckh0zPJ0n7yH1I(AkMbempXK6w0Bw3IRWG(jDVBRP78L(Cxb1wf)EhHl)l71Ir1GBByK1krN0naeS1L0ccM1AHFqSTQJ0dnkIJQK83SPypTxeSHvhDFnP(o6Dgwx19WuM7gHcbAlkbutCSUskLIRkkpNn52Es)VFIogj1)7ekVI2Q78hQlZAFveFlEgG63Xld3n1xWKXa78NgYA5jxiiM)xl)alRUVRSvD17GEOGKXQQ1)kdNU5Y)(AwEhA0LJUJ0Wv7G9(FpfHKm0SOd5np0BH0PohxUuTr2FM8TELcVHv8yB1D2nQPdyd9(PdJ5JhQ6vVHTeMJziEMsFcGWID0oZs5)A9SPmqFGrRiDBCRCPhHJoHPU75HQ9f)V4ADh8fcyg2ED1aVcOUEOrnENeEBg2HXmeqLo1bDKPhtvnSIqOkOtxEMp)cyLXaVmJupmiyh0D10n8HXiWKha)0TWgfEitbkINRDDxXQkr2zddgb6owTudo8TvP3wnoRINEcFfASv3ehof1MLmqF9Wenj7cvZ80rt8)IbCk1GTpaiHg3tDpBAMNzA)RN6bmjCRC9kUVRR4bx5Jrdbqq53E1yp0CkSg56SmfnnflNxWNgZlBgXkqaCMm5HfKP4FxaZr0X5Mn4LgpLrNAr6dd7yOwJNYwlI2)gwq40LnCleTEAiHD6wHBcRsksgTwewTGV7u49WpGFvccSgYkgRPESVS5ky94e2kuwRtq2gwWrR(avXDLiUh8aTkyS2mIvdebMfz55yt2TOUH5CKfkwJBHPR(OXWL13QBnU0gpB7X1cmTqXXAPP5sQTs2FQ)TmZCfVbl9NbDrTER(FlKOBbXmsvnPcyUjTiZyLaJM1aDI(lbfPdOPhuYm2l6ig1O4T2qwTUe((BtQw7gEhYNwM4zAJ2MdFHpdFuN3Ems)Byy7rYF3)IFFRRD9UR3gXG1r1SylG1FjHyES0SwrCe64TIlKqWTsmCKqeVmg0xzHQZbh(XHkvafHHVQiWHNmdmuLQGKjIESVo7QmTzK9d8XlwGGj1lRGurJo5xbmUllVwhn77X(4xY7iaf0toPWlx3qvm5k6NMmxBBlWZLCQCayWBSnbeJClS5uxAIVz5DRjvnlbJAMEBfvVVBROFS(jpWw9rJnSs)zml4hnX7VESXVYnyFquR6z(SHTmdmJGfX3PZstvVe2SW5Yhe6SgTTw5roE4lIuHgqD5QzPhh0AIzBvgR6u)Bwx8PH1FRpW1xoKP7hoJwkh3CovsfYUiFuRMEKHMDNF5SXzxsLaUsZDTLWj(4ZEZArzlBBdI9egSIltVxoOkw1AfWnAdJORzJVWrSDhc6JY3d2(yb4vtYOKZiy(tAac6RpL7W)6b6B3gEajSHS6vysGXVdVI7nzd0A73IHsCwY1zADfx5qMoV92H8Bv3jILBd)MrI3fxZ4n0r0VRy824UF0jp4RfUDrKsypqBpuBzDfPK97ovCuPOUfts7cjYS(uIp8oDRGU4v31PRDD87er1ruF8yKXwgSQ)7wqxV5of4ToAF29ZhybGDhnR6hK7i)ZHhgTTxShHfjqmp6ratItD8FdlYI)Byrm0tkA6DHj7KqzvkoMRT6bI2EvB87uov)0EgbHNzQIcI6DQ7UVKIiZ2hBaB1p(puiausOG7HYPGpwsWBRhdUHo6kPLJ1)joocIxDBJB2wfmHXrmWlwWe6DOnc703OOW)tepIqoo(p5XJ4L6EZky8iGARJY)kr1E2TWvqZzJottBm)uhJQnqqmyupsc9ND2Zft5dak4Zm6vjhGLMXzto6zY1vGUI6bzlot2BA80fxv7DK6LPvjlA8zeTKEnqhGtNfLwaBk590oMSRi9eTbgSW00fsmhc0f0c1gl7r)CvFc54SA(OfUJQAemhwD9onBvcgNc9n9WNQ5zDLsJh)cgqAUBiv4HVFEYrtMC0lNmgcrqvbOWh9S1R(1F(D)8p(9qP0(BG87miYqnCHUFTmFw)AiZDOR4kmbTXotwcLyc6D)ZzPzm0BL38(FkdYtQjFpiNUGoY4J)AL6w)ZVMDmv)Ne7t0hT)4pnucLV1ck8Dyjie)7qF)l35zXenOm(ODgmSjZM33bsMFJnSDO4X76ScQJNF4x(jlC1lECb3384cUXNycVlYw9Ako6UIg4sY4jpHbYFQnbYvU5T5TG7Gwd5)pMUBpzyhW7RfD3q5St(dHiUgBVeB4n4XXAeOQMjj8B7FCF((jE((jE(E7thB)syInwO37sMGzN3SnbZd94Uda2X5XUZ2WamF3Jcyo(OOu(Ae(qaAz6WPr5)8HwKnDaVT(K0XpoS6p(4Dfm(zyC8JdPTdy6pnzNC9LkR91BfFFBevpMr2OOoNA(YAMTBw(qzj05u00ISTBYztY2duOHgb7WwqFxwoH67HTY2w0U)nV(V(EC0B7XHZ5dqVnd1)2fQLEUBB32u2Un7hhwC2i7(V844h7td9spK(PM32pz2DCYKhxDRgBRfXwVuSbW2phMS7NaIPcYwnt28(3HK8Wh(TchuV5sW3AaLm4rKYfzqcW9vFLWtU)nOBc8E4FVSPzD93)8NFvwZY2zGZbEED2k(1oa6Vb4FN(C2BFbzDdH1p1gp(ay9pzcmdGN9A2HNVN9VoK75yRCfHQLZs2TQawPnm3AjIh38mc)ClyC9H1eyvtxrZYYXBiuSjiaRj(a8tLL1yPgJoKIFUg8aqTNUsY(zJiJoqv6qLqTfNjyuKansos9skQbZsfgqhQgRFar7GZ3H(vcWQGKEn6Hxa4WNtUfH111ScwcDv)R(WpX2aXIYLaxYevxNxMmxbyr3GaUQfvopNUiQy3jQnWug8sg63EQgJ4TfbbYFGSIdVkbyHTpDlI(YeETv3aVmuK3xvKTilf74CV5dxG8gPKhARkonh9BWRkcWh6)trWoGPa6Eoy(ZFe2sxHDUK8vyNZfsta7rH5Pq4)tNwABxi9a4EVu6IyUYJu1MOOx)H)UbEI99)al4aZ3iVBczQ2b)7ROZIrumzAkL8eXufhshNvlGovp3ZDSiKqbNpp5z7zq2qIBEQRtXFbDfi9GkClOGxM(WSoHnC)BsvjSIYBjhSXTHbkouI1FMuHpX(BcB5aPckf1bRraYSi6ODd8T08YlJ5zwiohw1yp71nAEHQJ0W2HePeXDMZZWlwbTyKFq56ZOhriDGDy3hk3iFq9AskL(GNMiSt)(AC)UZCTEzqFN1AUMuFMZD)ZzhoM7y294YgKXmgCdRrKCDHYPhTZlCNgrj3d7SZQ3UmdQoqJQv0QS)cDjgyJ86lEYFGDmqc(FLZos4A7Nk8gmMn1RtAsx(Sx809C)1pZynmqOV2oKeBdsBJw4l6nc0xukmXF(Edj67yFOVV5)aOVWeDAD7dF9hK(HN00)oeIY)R8fhM6vOmcqqKmsE9McRVyl7O5zGNSFOed9DFNpu0KhFu0AsvkfGyNOcwYSWtoJKxEBm0KhXt7kcbJiQKD(loQ3YK6XgSZLICkOOZJ4baZM1sOZaMVLCtUJJl9y9ZYwkMM46kUQNNg6eX4Y38s8NPrE9oS2rgHCRaK7Fhn6B79gy)p8YNKBS74ZcTT0pCkY)fr3AMa9DyCYrxFyNdUVRvFDOx1cTNlZ)kCqIDB067g4wmZ)bEyIPFjpoXQnQ)NEoFdfoAXuE8l3M5m7MWLFnFQJGZGBMFMvjlAWdv0Pv7kwEdvOLYXQvmDVTyUiXI0Kp9)WPJXjcJNI4MgKpWmmNmlgkzrWLui2AXbJ3)cH8WrMguSUsvF3QRVEMfYsQx5rJgBCUw(QcLhF3cxv45QAphA5MuZkN3Y6gGemRdb6sJMvusLex2iVhcHvD)px6M)R8PVHX6pB8rhzSyCnjGTMWDfZBiXKGnOITNdkId5qNppNplDeRCdh9YjV8ftoA0SKAYu2LU47)kpm8dZuq0BTac27c0hO65m1tJh3Ze(Bhp5BFH5eMc9)HW2i2fsjEgdQwl9gUgyeUl5Jmlj65SuJRml)p4ZXG3qs3FV8rEU1q1EA4Y0u7LCksrTN5Wus7zwvTP2tmRgtZ5JVIRuFY4pdsyBj9KBmpeYsR5BexHqWTbkLwaDSCsd5QsWJoQkPcpRW9gMeegAj1xE5(t9OqkyWt6NhaOpXiPL8qt8qa(dnLP87Hhv6t5)5IIJKZYrlnMGrBVW4Xb7fmTPgivax5pHEn6(jkXjsOuIYpC1t8j)VHmvMqOBMWtUUEJkmf9kjQjjk9jjfJAnMJG3KKLJij5qDM(LifockNH77wkHnE)m52f0VJoE)kPUmhsty2ngfWWG7tlSv5MiVWEr3IseEvLp60Lxbhuu2YiKoWjv)pdfyVVD9e2U((77QcqaxPoaFj7HHLw)kHJAunuCht3gn30RK7x7trC77Xx0jIqc1lv)L(3qvwbD0LKQUs5Dqp2zKRJac(SfooRu9JH9Pu0zqyZQ18RNJju2tDF8rvTSk7PNLEaD0KNb9vPARY5JSpagvsMEA3MAD)994t0m56(7JGQpKTkI3hRppulPwOUZWbXgIoAO1N3NPWG9Jx(wDoiNC)9c2CgayOKjaDJ01Yx7ZBWqmGpHDl49tpB8G9yNrDUkBBxpWBPCOH76IYbPVVa7WB)kO6dyWWfRtQU2jmshakH1WLBdxu58sUaIJeAZSaBPV6RyWCAnaYGl(9JSvljuo8KH4K9nYYWvPhIWyiTigyD5OpIQMj(t4NJDWoSmG5j6TRFr59FpOPIZo0RpUSZ26Tpp00Q6aElrHpu1qCqKb(JMeK4Vhbh594kiQlHxPyptVGdFgJAsRCMfN5o0zcjom(unHx6vrnUJGb3YNXd(2g0qgU35qg6T9qxNd8HEXj8RWEfFB4PDg6(NMBjMYJaj91c9IH)MROkujwgHbA2cHBHoqsX8uaESkR5HHjuNko(iT9gQmAkpoqvr0YyyT(wy4(DcERpDaFrBF1BzFPF5hPWCwgg4pRMenNvLXssXjlKIhCwEEU5PKLw2a3wa9HD9zYYY70xmyVi1K2G98u3uAlaPIPAn3NZSTpS3BtN4f0(DhvxNcoRlReIXR48U(4yt1iQNhJh(PEngZ4G7K7V3WdmNgbCddCYo0S(QQSvtjP5zRR7g3(YTyIeEixvwwKN1qxJzwby13yEYJYyEv(DRxc7kj1SECp8AE1WVl5jNRMUg2PQP2NXVF2rdJGkCTrUBecY6cCyi)26b8Na1ykKTdvofxXdci(wi7h)T3iSdf45XQFNarQIQqWVi0K5aWBPzLvznz)BICm9alBXzImvaAoVVJRDggrwq9mUlQy5Se30Le51zYTLsl4YX0jb8IUWp8gouu5QZrIObKmh8NhGuwHzVcZzAiV5gMrxspTSW)cbT0AEj3KsaMudIs5jkbmT4xVJIQGRTayvqx0PCra11TmlHbDJYACT3znPc4BcONGQhAsPy7eH)OODheq9AuNUZ8)m51be1garcQz)sAdPgBp2Oh1cQZHSXPADzoKAMtnyn8KNiTA5zJpA4qPBdOQTxc58Z7yUUHNgvha2xMJblI53oMp5yEx91Vb00HQ5Wk(UoFZu4loSTrx3UMLHDJG0m9xjRZtsvrfTICtwjKf)5yY8XiRw0wG7Wj5r2ST9ZuuBaoJQLZ((3)o)OH3F)(7PQpMS6r6WEG6jmFlR9dk7)yixWEozDYecotSHZeh4mKssf23y3FVwxg38rktlz268Bc)PAV3YmoHXoYdJhvVYgpzIxAzmPTg7iPGu)8PafU9Mcx0rqA7bWU0PNW9u0UD0HXKhAlBBKz7N0nWuvAZA871zwsdQ40emxeWqEIj68AkNUMiuJHDFVHhxTv)BWFeSNcpRTIlWxYtvZav8L8mnqKt(sEk7exPVONSHA5QspIeR1Tgst)6G(t5rDDP83XBRqT2(5YBs4kEj4v)JuD(bUZVlnlnNyAuS82ehMUk72Vc)KPz4x416M(5JSOAvSDEpHja6hXC9fe1)gTywGCzXGwWJllMB0Tfquc094Vi4fw(9XoYiXdmYaP0sySIC9ZZWBEV65z5sfdrUxWxd8NAm08ZeoPvCf7RAmtN3JjPqR(4BsNyC0XxwX9Ng0LHth)db3nOB)XlNapwOsMf7Yvte0ko0pyS6Nd8MlgYdtQDhffNA7rbT84Im(kikEL5B0UbGTUpbRJCnapcYaOznWLI5g212NYmETBkt6yUUSaDTQ8565TJ5iYuqM7K5KMw86juLcpwf9GtNQuZKEz)zIUU4bvETwocQ5h7RQW4bbjRg5t01JLBJ7iwhcKm6)xEl)6SXE9gmtB2m7MiND(FYU6oPMeRjaRhUmlCW10U5sFwF48hnEIpvcGUc62Z2FobP094eBP1rhoEOcIEsVQNMwEdPGUbn6gM39FQkEMEGRapfZXBdh(eji0qwYWdn(uFpgMXC8Pk)v8LtOXbURwP8Ne9Zg(KNmoAOXmlcpdJF7ibaWZnD6QYJ4MaRnXHeO4HOhMIPQgqDOZd8XgrFvxk4whWrgZyvhmedTCCMWN5dw8DQOkI7Ec1nYpXDzMX(m4)fTOI5Khl257W5Du7kDLqmrszggAJJzIDVIF4y7OaebzYKr9aVnT)mCf9)zH)VV(uNhE6UumNF8tH(onffJ(YsUh7osdIrT4nhGuO3pWAdGIAiYafh5cl3O)tAgxcv)S0b2b91LW1RGWB5ajRJHYzn8YR0qnHcQev78sosAiz1HhfbXT)5nKTaDpsAdjf4WtoLVLB22f9ST)mj)tRxvcRhxX59x(Z93hNRe89NYc(f7YqNhkkJgoywHvA5WohRuvvrNftlv2bzu9uEG8FO7(N3vL6092FV3J)IFlSlfnK9(UdyLvplNi8WYxKKx2ITJjm8OhdXdr4DLGjqJzh0TTGZvcZ)Xppsc6sQEiHSOa2Z7Hi4HdINtGN2hXo9J2C)(tC2rIiEA85CNRjd67oLu6ZdlH0HuJtguSY8Tzd(zoxv)UPIhqmg6c3hDcjsTI2g6CD4hlNKItj2fEi65VbBN(Ld2tlp5fA44j)K4UU34guwQjKcCozc1rJo5(7DT598ZMWZPs32oGZ(IwnrZsVemeKaQ3NFaU8hXnS887y9eI7maqSDuMImqZiT2P(zzfRgFxNPhQ1(TC00jJQxxX6kVGWoySbScOqeN3OfmyE1(br54z7mo9susT93tJTJzNXFG4rEUTugytSGMIWS9jaWSj5m)IEpgbae3QfRSh0tQiQmebAlvfeM)QStX(DjBdT4Ggltdp1)N0KLETInE3c6DA6ADLZGhf0ICF6bOpbyTSBO2v4)gN2t0i7ot7QbZJ6BJFarEY71xwC3GOhLqRjkDTWUXS2f3ViYHcTRMS7VxZ3yMxkzrDCO)WjqvYRNYaPCN7HxpSUOX2LKb0f)z2j4b8iFsNyF)IfiEWEe)muN0stfFXmV(m2LDA8xIo5u34PD)QYBZuFoWslLDdbaKnhmED(MMx8PD(642bCHLAgMeJB)ugrHXnEANW9XmC5BZWflpN7pu6iDA2sazLHlB5xBM0jB5hhipq2sO4KAgB53hSwh71x79EiDlHH)7E0TeibUUrnC4q)GK)R8t4WG)NOPpfvD3WHccYTJhPjYA7Bb1NT2(gqL9lh)zyYvhGhn6Rb67HATvp9F1o)krQ7hvTcFWywYvyOLQOQcfmXB6ywS9kIGkp(d0)9k0QHLQsu3TmCyktcDArWKcqL)a9Kb0(fQ83QvycSIanU9OJIUW2wxDejKMCFEeq9MGokvlmGUF1PbGMiEcZR3emf07SRwSrLa6OP4YVmTTQcJZTrTVkFkUxDldlJgnP7LAiYd(cW8NBKF56ZsMp32JLgnKddX(U(vIRxv0GgjbCKPY5qmme76JhDIiMgpne81COvuhInKTR)lScywYmr4HqxhX4w(dI3XPHnIVj2TmtBAXCtw7Ry74Or8OP983oijg0KCIVZ3zWCLRod3T2l0V3n)OZMEj7RlZa)g)88JVI5ms5MbiRIMa4vrrRIEMzjvWWbyiJsHkeHsuSkqZ)qwsSXylWASrYaqvNSGaKiYIHSTOjdsWgw78XByjOcvVMXfrDrs2fzGDcT7q6J(1RM0qL9u0wtr8KQjVC6lwN63434EuEIFVH2H)wNCKCJXUzaaF1bYK13OXpi2kWT4eMFq0lJuF4dR(oO3vymPfQusWscDxr6j6SYOXBSnyDjJZoEbXjxRKYBRVNsdO21wUoSUCoD)rRjB8DuUt7EGBNY66GzGvsAAfPt2Am3l9WgzKY3Nee7M9RO(IyNdW8pG33LxKvKvVSlfXu)up0gaSEiCLcF2rBDe4oL(n73rhFH75Qaz7yKNYZys6XG4CFaaejLmntsgJuq)(75jOMXVcEaI(nY8oRGKwvMxwnxVIMCUK0fle9lMDdWWtFnnGeo91OFi3ijUtZuoIoWVp1nX30vliPwlYUCqyFbNoW3VtC9pxxW1Jd39)KDa2EU(Ahe4r7a0DJTK(KpsGN6AeyAGAf74n(6)M2MoikmvUetS1KWSwWvN05La85gCGH0Uw03omSEjdRO1sTYpJ1Qe5DSF23ERIFf7PYE5OoSGs3Skohk)zNNh3()q0s9Ry99euFkNcf8arT01g)UZLxRYRAlGCbJhAowm4W3If2q6jv1wsh6LSLHtlCzi2rCZ8PONK5Mh2mWuVRK9J9oHp352EcOCQ9NmL(dt2GiYIyM9BhVTNUVMnINF0WtNi359VTBLZhet5WudFXkaLLI5gDNFLY)IdGw9EFrvafOC4tMjdclQ1fHvSQ8ZwOHiR()1ExT92g3(W)SeumdFojEXolfddobOaT4F7BwlArXExYUKCU9WFhBdF2Tlab(Z(ej1ZIs3Doo2zBf9nfX3PtIIIIp8JK4bt6mNQGM6HfER49Z8Dc9crmeUTDCIW8IBO80wJ0z36XLLqEx36Xd)8eNYj75dYOwdyO1xHA9XS9xrSZrBDQY0IIBtrtUPOCsJwY)uKKZxJLpP3qYYQz9jZBVG60wi6fSe(PzkrUCEUrDX)J48GajFVH)SuZFQMkKKt62j6dfC)hCsHVOjSn2BGFWRSKPQbUguleCdEI9iOsQfr(S1RhEmXm4HSlGkICQ3APMiR11x0KjCwcaGB90H1UnJUVOULJZR3AT2Cp3)SUMRBYnxlsA4UB0O2psECUzUgDuKsmGbac8)o69MrdJ9ZbZfnlxaa8GuBtptdpyXQlqxwLbQBYCs)ZYEAvyak4eV)1Vh7NCV7U5tkO6(fFGUW7VxaCmn5s1)LFqWuSp4jwyrIrYcX)exD6jNm4xgsCuAS6DXGhEO2WA2NIpSAZCqQ1lA69po2w3XwRYKnp5VtB2o)hLqaO8FIkU4IktoTKaRaGOgOREw33kVr31FziXYAD3kBnmqP)XJm2(b5yJtW0dJ0VeEve1yrel3RzcH76K2GOTvL3DxbaNgmci2nWaY5MshAwPlVxbz5l2Y1G2DM)xcAyelLiWxwNWqDnLD6bqLs3frnUKOUY1QG6oShl7hpl2HPCR6Ww6DD7nz6gN)iEQODKJZEGE1ZIYIX6(LHkAkPcHLCBe(2RLLQ57e6)D7AMg6bejM)8DstIj3hDtjStambFpV0SjHEiXDsyA7hUh6wQkhsiUNxtvbpXgB933cFXJQkUjwAhsxTDLFGpucd0K8aHmUNTQlFVsh3LWpFe4QfNLWv6ri3AZhoaqoGoj9hi9ZBaYMdKS0SvV38bTdTKdoZSYyPUdjwXZ98AdAfPB(bYL5FgErLxsxvTIKQqMGcFLxn7nPfmKO)nfE7jR)VI6eeTBQDt5lv5VM)xTY5CDSutJFahh3ccVpIXU7qb8JP2qJgSkf)vzfTPf8YKuBLxTCYZsqo)M4m4hFiqzRblwoShDgVjePPt6j23RL322gne2s0GnEU(0e24D5wTXCL2SrZ8wnxq6wA14nF3OnHxq9vymo7KuGkUZ4(HxsPxlCOwPzRYH0bjKnkg(tuKbBjrQTadiqUADm41Ebv3e1Uu8JfZqehMn5Z2gD)gjt8SpZMK7w00WDh4gXVwmzEDzqgt2RH6sz5UwqHmWi316A1oOrxXIVvh4cCVnkIIYw5FsmyxgOJrdiCBienc4v03BQvtgdYNUfYHbdDsX4LHBbJLTn8WQtWcZ(gUpHbjAkxflqvl6Tq4uXKQI00DpydhznQCaGV4(bjh7WeMPUHNt9osZ83k4pbPhQZFQyMbjDnmes1cYLyJuCCeb18TR19xin868lrdRTk0YKeWOgdSe7GnN32WdyncKA6WCsf2M4y8PN2Bsc503oHKqRZsot)acvELwMAacJC5QLTz9zG)ZuGBQjrXJwZBqqrS5iSkNo2TuNzwa1q)a9IbLkDnJIUBq)chg55Z61K(2JTZpsQpN)OvRYozhZ9a44j3H3(e9qGtLOLVAygPjYRjJOdfmrgNBLlZMOs7494W(Coz(EvXYNagmM16S5Nd1MMObFdecf2h188boZQij5X3PwkW0qh7UzgDWC8ARIiVScEURPiMa9z7wkBIJoCC))7fFAliiY(ghp4K0jtzcQwSEJ5(IKehICo0fj2660G374HNvd1jb5X0CK2NeLqWhUn71rUX)vH9Xoj(61ZWvhj10OQmO13chBuXyzjONgDT63bOVqn479WgHpTwrgIrQbkAeIDh)XIXV(dttarnly7x0Rqh6Qu(yoKrcsqxiR3s6UzkwG)39estq0I0JEm54vWty4Wt8mYDMSEhK8Hex4c7rP64OP2b(F6Siwyig2UKm3eJx5ySexNxiqg9rXhbm3E4jRT78674TbnTXpDOV60F5SHd)vBrUXl36nDuoE4MjTqMjn2)jYjKvQl3bPicJl39eWiwqv3s5JZ(WZS1aR7YSupJPsqylVB23RryVvj2nemykbvHECMo)WQZM1TcNT20dW5sOlCy2du20a56qgcV9fhnMYxt6yD4MP2dSRePM4l3w0aJDbfhXXuJ)d7Ro7tQnqJswmZ9UwMRSFt3oZwKT186FmhkZpVbubT63sW6FlaR455yMNcm3Ns(rIGbCUmLKnogGI(L71edoZ6AcWpdGNLWLn56p0Zwcv2e38iOQyuVMlOxGAbGVTWEOLGCwSpUKzHGmDvX3WsZIyX2VKulY7VIXDQQJ)FgBLcxC(Pb)G6KYfdoJD34v2Dnn)SVuq7wnb8T61LtqFFVaFzC4Re3Hdf35fLeuwv50zf1pNXOJF9mv)V8UCOIvQQJGGlBxwPC7oOc7UHEhqOvlpXr(YP9oG)xwn3BJW63KBhPDtXOyFrArJ((oIp(Sb)RLj6EcwuECBTSmgGhWihQjBQ2iqJl0ySp8hKd5xZf6UmfUXOQIr3lp8sG1NieE97OdmnXPqobLM9joKZ7LMYMWGJ7Es)xE4j9h2l0PlzQ)MY5MzjRK6TOwvFmKoWgptRRlON7fm0OUZZkAboX2HITGnajKbQXghnzmF5dzsZuxlXIz0wIf9OighYzvh7mQPud26R4ZOGsYT4EUga1MnxDXLvZEhV2URsCiktYbMlYwDhCnnAwail8(zRWK6dUvN61YfLurS4TfYmJ)ZZjHEoOLdBOHOkA0ZlUhSBEMBJ8wMRFGJuYNqwalEQR1p1RmLpn05mqnmZdWFhrF6U3KLQqQluu510s4wmFLqG)rf9qGhMIusPx1svgJnkcNrq7cHunkYqXoB3gSyNeY1P5Tq1VJfvJMxjuLyL1flwCLh1dquCjxrwt3o2XVXf(rcbop8q3O1gpJ39Ccpi5BKShEGR20NzfBBxEzjxQcBqYgQciO9N)G6iIUG4qLnxBgA7QW)mRXrgmELYBU8C7cUaUnTgWz0TBqC1mzxCKFYRO2Eah4DtMv0DJ8BnzGZ4dypadz2Muqq56DbL2NYPGFIMl(Q(m1lSZtu)XjYWKSTNNLf5k)MvqzAM0DFKTOVlAuWptkb49aSgQxBp9GFSh5Zhzfjw1)Rh3SocDQoqOgTBvWkdKv3TiF4aqNyot6vB(7Oc(7TZw2NAGTqAtK3kLMs98St7iemdMu4in8Vtiym8Mlr0sKRF5fDv4)WDUlFAE)5q3Aj6ZCf8mDOqS0he3woDaH0mcl6A4ZqbH5O168KwiS)l5yjNEMseVtBDaAwdJlNmbD53uHL0yfRES5kIycYFmkgNw7FB7sckJX7C7tcMbpBStHBM1u1KB27YGZDNlj4L0zdsVh3xSRf84vdpuNI9V1pvPcx1sRLkk)fqzCSUzibMzPeNyOA(iROuBxBhJO(7K2rQMBs)A4sAkN6Mz7y3ACWSKK4(JoO1vFruSEuHRTDqFkNRWuNIVUTFJTGvJnJr7hu2NkkB96L02rS161T7vz7fMUzb5Wt5ctytSQ(7RY8LvPR6ngidFDboEU97gqkvqR765NnFXU1Sv2(XyE3J1Ra)W2V9STFn7eFQ0ZT5MXW(TAJ5mkPYqf36kXbQRYHeMnWcLbz7DlF4wQTZ0AUrOw7HgK(9BQnyCV7)rSPARR4y9YGHzWLFsCk9Ml)9xE6Llf)7Y)(]] )
end
