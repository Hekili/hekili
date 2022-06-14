-- MageArcane.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local GetItemCooldown = _G.GetItemCooldown


-- Conduits
-- [x] arcane_prodigy
-- [-] artifice_of_the_archmage
-- [-] magis_brand
-- [x] nether_precision

-- Covenant
-- [-] ire_of_the_ascended
-- [x] siphoned_malice
-- [x] gift_of_the_lich
-- [x] discipline_of_the_grove

-- Endurance
-- [-] cryofreeze
-- [-] diverted_energy
-- [x] tempest_barrier

-- Finesse
-- [x] flow_of_time
-- [x] incantation_of_swiftness
-- [x] winters_protection
-- [x] grounding_surge


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 62, true )

    spec:RegisterResource( Enum.PowerType.ArcaneCharges, {
        arcane_orb = {
            aura = "arcane_orb",

            last = function ()
                local app = state.buff.arcane_orb.applied
                local t = state.query_time

                return app + floor( ( t - app ) * 2 ) * 0.5
            end,

            interval = 0.5,
            value = function () return state.active_enemies end,
        },
    } )

    spec:RegisterResource( Enum.PowerType.Mana ) --[[, {
        evocation = {
            aura = "evocation",

            last = function ()
                local app = state.buff.evocation.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.1,
            value = function () return state.mana.regen * 0.1 end,
        }
    } ) ]]

    -- Talents
    spec:RegisterTalents( {
        amplification = 22458, -- 236628
        rule_of_threes = 22461, -- 264354
        arcane_familiar = 22464, -- 205022

        master_of_time = 23072, -- 342249
        shimmer = 22443, -- 212653
        slipstream = 16025, -- 236457

        incanters_flow = 22444, -- 1463
        focus_magic = 22445, -- 321358
        rune_of_power = 22447, -- 116011

        resonance = 22453, -- 205028
        arcane_echo = 22467, -- 342231
        nether_tempest = 22470, -- 114923

        chrono_shift = 22907, -- 235711
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        reverberate = 22455, -- 281482
        arcane_orb = 22449, -- 153626
        supernova = 22474, -- 157980

        overpowered = 21630, -- 155147
        time_anomaly = 21144, -- 210805
        enlightened = 21145, -- 321387
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {
        arcane_empowerment = 61, -- 276741
        arcanosphere = 5397, -- 353128
        kleptomania = 3529, -- 198100
        mass_invisibility = 637, -- 198158
        master_of_escape = 635, -- 210476
        netherwind_armor = 3442, -- 198062
        prismatic_cloak = 3531, -- 198064
        temporal_shield = 3517, -- 198111
        torment_the_weak = 62, -- 198151
    } )

    -- Auras
    spec:RegisterAuras( {
        alter_time = {
            id = 342246,
            duration = 10,
            max_stack = 1,
        },
        arcane_charge = {
            duration = 3600,
            max_stack = 4,
            generate = function ()
                local ac = buff.arcane_charge

                if arcane_charges.current > 0 then
                    ac.count = arcane_charges.current
                    ac.applied = query_time
                    ac.expires = query_time + 3600
                    ac.caster = "player"
                    return
                end

                ac.count = 0
                ac.applied = 0
                ac.expires = 0
                ac.caster = "nobody"
            end,
        },
        arcane_familiar = {
            id = 210126,
            duration = 3600,
            max_stack = 1,
        },
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        arcane_orb = {
            duration = 2.5,
            max_stack = 1,
            --[[ generate = function ()
                local last = action.arcane_orb.lastCast
                local ao = buff.arcane_orb

                if query_time - last < 2.5 then
                    ao.count = 1
                    ao.applied = last
                    ao.expires = last + 2.5
                    ao.caster = "player"
                    return
                end

                ao.count = 0
                ao.applied = 0
                ao.expires = 0
                ao.caster = "nobody"
            end, ]]
        },
        arcane_power = {
            id = 12042,
            duration = function () return level > 55 and 15 or 10 end,
            type = "Magic",
            max_stack = 1,
        },
        blink = {
            id = 1953,
        },
        chilled = {
            id = 205708,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        chrono_shift_buff = {
            id = 236298,
            duration = 5,
            max_stack = 1,
        },
        chrono_shift = {
            id = 236299,
            duration = 5,
            max_stack = 1,
        },
        clearcasting = {
            id = function () return pvptalent.arcane_empowerment.enabled and 276743 or 263725 end,
            duration = 15,
            type = "Magic",
            max_stack = function ()
                return 1 + ( level > 31 and 2 or 0 ) + ( pvptalent.arcane_empowerment.enabled and 2 or 0 )
            end,
            copy = { 263725, 276743 }
        },
        enlightened = {
            id = 321390,
            duration = 3600,
            max_stack = 1,
        },
        evocation = {
            id = 12051,
            duration = function () return 6 * haste end,
            tick_time = function () return haste end,
            max_stack = 1,
        },
        focus_magic = {
            id = 321358,
            duration = 1800,
            max_stack = 1,
            friendly = true,
        },
        focus_magic_buff = {
            id = 321363,
            duration = 10,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        greater_invisibility = {
            id = 110960,
            duration = 20,
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
        incanters_flow = {
            id = 116267,
            duration = 3600,
            max_stack = 5,
            meta = {
                stack = function() return state.incanters_flow_stacks end,
                stacks = function() return state.incanters_flow_stacks end,
            }
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
        mirrors_of_torment = {
            id = 314793,
            duration = 20,
            type = "Magic",
            max_stack = 3,
        },
        nether_tempest = {
            id = 114923,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        presence_of_mind = {
            id = 205025,
            duration = 3600,
            max_stack = function () return level > 53 and 3 or 2 end,
        },
        prismatic_barrier = {
            id = 235450,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        radiant_spark = {
            id = 307443,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        radiant_spark_vulnerability = {
            id = 307454,
            duration = 3.707,
            max_stack = 4,
        },
        ring_of_frost = {
            id = 82691,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        rule_of_threes = {
            id = 264774,
            duration = 15,
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
        slow = {
            id = 31589,
            duration = 15,
            type = "Magic",
            max_stack = 1,
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
        touch_of_the_magi = {
            id = 210824,
            duration = function () return set_bonus.tier28_4pc > 0 and 12 or 8 end,
            max_stack = 1,
        },


        -- Azerite Powers
        brain_storm = {
            id = 273330,
            duration = 30,
            max_stack = 1,
        },

        equipoise = {
            id = 264352,
            duration = 3600,
            max_stack = 1,
        },


        -- Conduits
        nether_precision = {
            id = 336889,
            duration = 10,
            max_stack = 2
        },


        -- Legendaries
        grisly_icicle = {
            id = 348007,
            duration = 8,
            max_stack = 1
        }
    } )


    -- Variables from APL (11/13/2021)
    -- actions.precombat+=/variable,name=aoe_target_count,op=set,value=3+(1*covenant.kyrian)
    spec:RegisterVariable( "aoe_target_count", function ()
        return 3
    end )

    -- actions.precombat+=/variable,name=evo_pct,op=reset,default=15
    spec:RegisterVariable( "evo_pct", function ()
        return 15
    end )

    -- actions.precombat+=/variable,name=prepull_evo,op=set,if=(runeforge.siphon_storm&(covenant.venthyr|covenant.necrolord|conduit.arcane_prodigy)),value=1,value_else=0
    spec:RegisterVariable( "prepull_evo", function ()
        if ( equipped.siphon_storm and ( covenant.venthyr or covenant.necrolord or conduit.arcane_prodigy.enabled ) ) then
            return 1
        else
            return 0
        end
    end )


    local opener_completed = false

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        opener_completed = false
        -- Hekili:Print( "Opener reset (out of combat).")
    end )


    -- actions.precombat+=/variable,name=have_opened,op=set,if=active_enemies>=variable.aoe_target_count,value=1,value_else=0
    -- actions.calculations=variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&prev_gcd.1.evocation&!(runeforge.siphon_storm|runeforge.temporal_warp)
    -- actions.calculations+=/variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&buff.arcane_power.down&cooldown.arcane_power.remains&(runeforge.siphon_storm|runeforge.temporal_warp)
    -- TODO:  This needs to be updated so that have_opened stays at 1 once it has been set to 1.
    spec:RegisterVariable( "have_opened", function ()
        return opener_completed
    end )

    -- actions.precombat+=/variable,name=final_burn,op=set,value=0
    -- actions.calculations+=/variable,name=final_burn,op=set,value=1,if=buff.arcane_charge.stack=buff.arcane_charge.max_stack&!buff.rule_of_threes.up&fight_remains<=((mana%action.arcane_blast.cost)*action.arcane_blast.execute_time)
    spec:RegisterVariable( "final_burn", function ()
        if buff.arcane_charge.stack == buff.arcane_charge.max_stack and not buff.rule_of_threes.up and fight_remains <= ( mana.current / action.arcane_blast.cost ) * action.arcane_blast.execute_time then
            return 1
        end

        return 0
    end )


    -- actions.precombat+=/variable,name=harmony_stack_time,op=reset,default=9
    spec:RegisterVariable( "harmony_stack_time", function ()
        return 9
    end )

    -- + actions.precombat+=/variable,name=always_sync_cooldowns,op=reset,default=1
    spec:RegisterVariable( "always_sync_cooldowns", function ()
        return 1
    end )

    -- actions.precombat+=/variable,name=rs_max_delay_for_totm,op=reset,default=5
    spec:RegisterVariable( "rs_max_delay_for_totm", function ()
        return 5
    end )

    -- actions.precombat+=/variable,name=rs_max_delay_for_rop,op=reset,default=5
    spec:RegisterVariable( "rs_max_delay_for_rop", function ()
        return 5
    end )

    -- actions.precombat+=/variable,name=rs_max_delay_for_ap,op=reset,default=20
    spec:RegisterVariable( "rs_max_delay_for_ap", function ()
        return 20
    end )

    -- actions.precombat+=/variable,name=mot_preceed_totm_by,op=reset,default=8
    spec:RegisterVariable( "mot_preceed_totm_by", function ()
        return 8
    end )

    -- actions.precombat+=/variable,name=mot_max_delay_for_totm,op=reset,default=10
    spec:RegisterVariable( "mot_max_delay_for_totm", function ()
        return 10
    end )

    -- actions.precombat+=/variable,name=mot_max_delay_for_ap,op=reset,default=15
    spec:RegisterVariable( "mot_max_delay_for_ap", function ()
        return 15
    end )

    -- actions.precombat+=/variable,name=ap_max_delay_for_totm,default=-1,op=set,if=variable.ap_max_delay_for_totm=-1,value=10+(20*conduit.arcane_prodigy)
    spec:RegisterVariable( "ap_max_delay_for_totm", function ()
        if conduit.arcane_prodigy.enabled then
            return 30
        end

        return 10
    end )

    -- actions.precombat+=/variable,name=ap_max_delay_for_mot,op=reset,default=20
    spec:RegisterVariable( "ap_max_delay_for_mot", function ()
        return 20
    end )

    -- actions.precombat+=/variable,name=rop_max_delay_for_totm,op=set,value=20-(5*conduit.arcane_prodigy)
    spec:RegisterVariable( "rop_max_delay_for_totm", function ()
        if conduit.arcane_prodigy.enabled then
            return 15
        end

        return 20
    end )

    -- actions.precombat+=/variable,name=totm_max_delay_for_ap,op=set,value=5+20*(covenant.night_fae|(conduit.arcane_prodigy&active_enemies<variable.aoe_target_count))+15*(covenant.kyrian&runeforge.arcane_harmony&active_enemies>=variable.aoe_target_count)
    spec:RegisterVariable( "totm_max_delay_for_ap", function ()
        local value = 5

        if ( covenant.night_fae or ( conduit.arcane_prodigy.enabled and active_enemies < variable.aoe_target_count ) ) then
            value = value + 20
        end

        if ( covenant.kyrian and runeforge.arcane_harmony.enabled and active_enemies >= variable.aoe_target_count ) then
            value = value + 15
        end

        return value
    end )

    -- actions.precombat+=/variable,name=totm_max_delay_for_rop,op=set,value=20-(8*conduit.arcane_prodigy)
    spec:RegisterVariable( "totm_max_delay_for_rop", function ()
        if conduit.arcane_prodigy.enabled then
            return 12
        end

        return 20
    end )

    -- actions.precombat+=/variable,name=barrage_mana_pct,op=set,if=covenant.night_fae,value=60-(mastery_value*100)
    -- actions.precombat+=/variable,name=barrage_mana_pct,op=set,if=covenant.kyrian,value=95-(mastery_value*100)
    -- actions.precombat+=/variable,name=barrage_mana_pct,op=set,if=variable.barrage_mana_pct=0,value=80-(mastery_value*100)
    spec:RegisterVariable( "barrage_mana_pct", function ()
        if covenant.night_fae then return 60 - mastery_value * 100 end
        if covenant.kyrian then return 95 - mastery_value * 100 end
        return 80 - mastery_value * 100
    end )

    -- actions.precombat+=/variable,name=ap_minimum_mana_pct,op=reset,default=15
    spec:RegisterVariable( "ap_minimum_mana_pct", function ()
        return 15
    end )

    -- actions.precombat+=/variable,name=totm_max_charges,op=reset,default=2
    spec:RegisterVariable( "totm_max_charges", function ()
        return 2
    end )

    -- actions.precombat+=/variable,name=aoe_totm_max_charges,op=reset,default=2
    spec:RegisterVariable( "aoe_totm_max_charges", function ()
        return 2
    end )

    -- actions.precombat+=/variable,name=fishing_opener,default=-1,op=set,if=variable.fishing_opener=-1,value=1*(equipped.empyreal_ordnance|(talent.rune_of_power&(talent.arcane_echo|!covenant.kyrian)&(!covenant.necrolord|active_enemies=1|runeforge.siphon_storm)&!covenant.venthyr))|(covenant.venthyr&equipped.moonlit_prism)
    spec:RegisterVariable( "fishing_opener", function ()
        if ( equipped.empyreal_ordnance or ( talent.rune_of_power.enabled and ( talent.arcane_echo.enabled or not covenant.kyrian ) and ( not covenant.necrolord or active_enemies == 1 or runeforge.siphon_storm.enabled ) and not covenant.venthyr ) ) or ( covenant.venthyr and equipped.moonlit_prism ) then
            return 1
        end

        return 0
    end )

    -- actions.precombat+=/variable,name=ap_on_use,op=set,value=equipped.macabre_sheet_music|equipped.gladiators_badge|equipped.gladiators_medallion|equipped.darkmoon_deck_putrescence|equipped.inscrutable_quantum_device|equipped.soulletting_ruby|equipped.sunblood_amethyst|equipped.wakeners_frond|equipped.flame_of_battle
    spec:RegisterVariable( "ap_on_use", function ()
        return equipped.macabre_sheet_music or equipped.gladiators_badge or equipped.gladiators_medallion or equipped.darkmoon_deck_putrescence or equipped.inscrutable_quantum_device or equipped.soulletting_ruby or equipped.sunblood_amethyst or equipped.wakeners_frond or equipped.flame_of_battle
    end )

    -- actions.precombat+=/variable,name=aoe_spark_target_count,op=reset,default=8+(2*runeforge.harmonic_echo)
    -- actions.precombat+=/variable,name=aoe_spark_target_count,op=max,value=variable.aoe_target_count
    spec:RegisterVariable( "aoe_spark_target_count", function ()
        return max( variable.aoe_target_count, 8 + ( runeforge.harmonic_echo.enabled and 2 or 0 ) )
    end )

    -- # Either a fully stacked harmony or in execute range with Bombardment
    -- actions.calculations+=/variable,name=empowered_barrage,op=set,value=buff.arcane_harmony.stack>=15|(runeforge.arcane_bombardment&target.health.pct<35)
    spec:RegisterVariable( "empowered_barrage", function ()
        return buff.arcane_harmony.stack >= 15 or ( runeforge.arcane_bombardment.enabled and target.health.pct < 35 )
    end )

    -- ## actions.calculations+=/variable,name=last_ap_use,default=0,op=set,if=buff.arcane_power.up&(variable.last_ap_use=0|time>=variable.last_ap_use+15),value=time
    -- ## Arcane Prodigy gives a variable amount of cdr, but we'll use a flat estimation here. The simc provided remains_expected expression does not work well for prodigy due to the bursty nature of the cdr.
    -- ## actions.calculations+=/variable,name=estimated_ap_cooldown,op=set,value=(cooldown.arcane_power.duration*(1-(0.03*conduit.arcane_prodigy.rank)))-(time-variable.last_ap_use)

    -- actions.calculations+=/variable,name=time_until_ap,op=set,if=conduit.arcane_prodigy,value=cooldown.arcane_power.remains_expected
    -- actions.calculations+=/variable,name=time_until_ap,op=set,if=!conduit.arcane_prodigy,value=cooldown.arcane_power.remains
    -- # We'll delay AP up to 20sec for TotM
    -- actions.calculations+=/variable,name=time_until_ap,op=max,value=cooldown.touch_of_the_magi.remains,if=(cooldown.touch_of_the_magi.remains-variable.time_until_ap)<20
    -- # Since Ruby is such a powerful trinket for Kyrian, we'll stick to the two minute cycle until we get a high enough rank of prodigy
    -- actions.calculations+=/variable,name=time_until_ap,op=max,value=trinket.soulletting_ruby.cooldown.remains,if=conduit.arcane_prodigy&conduit.arcane_prodigy.rank<5&equipped.soulletting_ruby&covenant.kyrian&runeforge.arcane_harmony
    spec:RegisterVariable( "time_until_ap", function ()
        local value = 0

        if conduit.arcane_prodigy.enabled then
            value = cooldown.arcane_power.remains_expected
        else
            value = cooldown.arcane_power.remains
        end

        if ( cooldown.touch_of_the_magi.remains - value ) < 20 then
            value = max( value, cooldown.touch_of_the_magi.remains )
        end

        if conduit.arcane_prodigy.enabled and conduit.arcane_prodigy.rank < 5 and equipped.soulletting_ruby and covenant.kyrian and runeforge.arcane_harmony.enabled then
            value = max( value, trinket.soulletting_ruby.cooldown.remains )
        end

        return value
    end )

    -- # We'll delay TotM up to 20sec for AP
    -- actions.calculations+=/variable,name=holding_totm,op=set,value=cooldown.touch_of_the_magi.ready&variable.time_until_ap<20
    spec:RegisterVariable( "holding_totm", function ()
        return cooldown.touch_of_the_magi.ready and variable.time_until_ap < 20
    end )

    -- # Radiant Spark does not immediately put up the vulnerability debuff so it can be difficult to discern that we're at the zeroth vulnerability stack
    -- actions.calculations+=/variable,name=just_used_spark,op=set,value=(prev_gcd.1.radiant_spark|prev_gcd.2.radiant_spark|prev_gcd.3.radiant_spark)&action.radiant_spark.time_since<gcd.max*4
    spec:RegisterVariable( "just_used_spark", function ()
        return ( prev_gcd[1].radiant_spark or prev_gcd[2].radiant_spark or prev_gcd[3].radiant_spark ) and action.radiant_spark.time_since < gcd.max * 4
    end )

    -- ## Original SimC checked debuff.radiant_spark_vulnerability.down, but that doesn't work when the addon applies RSV instantly.
    -- ## actions.calculations+=/variable,name=just_used_spark,op=set,value=(prev_gcd.1.radiant_spark|prev_gcd.2.radiant_spark|prev_gcd.3.radiant_spark)&debuff.radiant_spark_vulnerability.down
    spec:RegisterVariable( "just_used_spark_vulnerability", function ()
        return ( prev_gcd[1].radiant_spark or prev_gcd[2].radiant_spark or prev_gcd[3].radiant_spark ) and debuff.radiant_spark_vulnerability.down
    end )

    -- actions.calculations+=/variable,name=outside_of_cooldowns,op=set,value=buff.arcane_power.down&buff.rune_of_power.down&debuff.touch_of_the_magi.down&!variable.just_used_spark&debuff.radiant_spark_vulnerability.down
    spec:RegisterVariable( "outside_of_cooldowns", function ()
        return buff.arcane_power.down and buff.rune_of_power.down and debuff.touch_of_the_magi.down and not variable.just_used_spark and debuff.radiant_spark_vulnerability.down
    end )

    -- actions.calculations+=/variable,name=stack_harmony,op=set,value=runeforge.arcane_infinity&((covenant.kyrian&cooldown.touch_of_the_magi.remains<variable.harmony_stack_time))
    spec:RegisterVariable( "stack_harmony", function ()
        return runeforge.arcane_harmony.enabled and ( covenant.kyrian and cooldown.touch_of_the_magi.remains < variable.harmony_stack_time )
    end )


    do
        -- Builds Disciplinary Command; written so that it can be ported to the other two Mage specs.

        function Hekili:EmbedDisciplinaryCommand( x )
            local file_id = x.id

            x:RegisterAuras( {
                disciplinary_command = {
                    id = 327371,
                    duration = 20,
                },

                disciplinary_command_arcane = {
                    duration = 10,
                    max_stack = 1,
                },

                disciplinary_command_frost = {
                    duration = 10,
                    max_stack = 1,
                },

                disciplinary_command_fire = {
                    duration = 10,
                    max_stack = 1,
                }
            } )

            local __last_arcane, __last_fire, __last_frost, __last_disciplinary_command = 0, 0, 0, 0
            local __last_arcSpell, __last_firSpell, __last_froSpell

            x:RegisterHook( "reset_precast", function ()
                if not legendary.disciplinary_command.enabled then return end

                if now - __last_arcane < 10 then applyBuff( "disciplinary_command_arcane", 10 - ( now - __last_arcane ) ) end
                if now - __last_fire   < 10 then applyBuff( "disciplinary_command_fire",   10 - ( now - __last_fire ) ) end
                if now - __last_frost  < 10 then applyBuff( "disciplinary_command_frost",  10 - ( now - __last_frost ) ) end

                if now - __last_disciplinary_command < 30 then
                    setCooldown( "buff_disciplinary_command", 30 - ( now - __last_disciplinary_command ) )
                end

                Hekili:Debug( "Disciplinary Command:\n - Arcane: %.2f, %s\n - Fire  : %.2f, %s\n - Frost : %.2f, %s\n - ICD   : %.2f", buff.disciplinary_command_arcane.remains, __last_arcSpell or "None", buff.disciplinary_command_fire.remains, __last_firSpell or "None", buff.disciplinary_command_frost.remains, __last_froSpell or "None", cooldown.buff_disciplinary_command.remains )
            end )

            x:RegisterStateFunction( "update_disciplinary_command", function( action )
                local ability = class.abilities[ action ]

                if not ability then return end
                if ability.item or ability.from == 0 then return end

                if     ability.discipline == "arcane" then applyBuff( "disciplinary_command_arcane" )
                elseif ability.discipline == "fire"   then applyBuff( "disciplinary_command_fire"   )
                elseif ability.discipline == "frost"  then applyBuff( "disciplinary_command_frost"  )
                else
                    local sAction = x.abilities[ action ]
                    local sDiscipline = sAction and sAction.discipline

                    if sDiscipline then
                        if     sDiscipline == "arcane" then applyBuff( "disciplinary_command_arcane" )
                        elseif sDiscipline == "fire"   then applyBuff( "disciplinary_command_fire"   )
                        elseif sDiscipline == "frost"  then applyBuff( "disciplinary_command_frost"  ) end
                    else applyBuff( "disciplinary_command_" .. state.spec.key ) end
                end

                if buff.disciplinary_command_arcane.up and buff.disciplinary_command_fire.up and buff.disciplinary_command_frost.up then
                    applyBuff( "disciplinary_command" )
                    setCooldown( "buff_disciplinary_command", 30 )
                    removeBuff( "disciplinary_command_arcane" )
                    removeBuff( "disciplinary_command_fire" )
                    removeBuff( "disciplinary_command_frost" )
                end
            end )

            x:RegisterHook( "runHandler", function( action )
                if not legendary.disciplinary_command.enabled or cooldown.buff_disciplinary_command.remains > 0 then return end
                update_disciplinary_command( action )
            end )

            local triggerEvents = {
                SPELL_CAST_SUCCESS = true,
                SPELL_HEAL = true,
                SPELL_SUMMON= true
            }

            local spellChanges = {
                [108853] = 319836,
                [212653] = 1953,
                [342130] = 116011,
                [337137] = 1,
            }

            local spellSchools = {
                [4] = "fire",
                [16] = "frost",
                [64] = "arcane"
            }

            x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName, spellSchool )
                if sourceGUID == GUID then
                    if triggerEvents[ subtype ] then
                        spellID = spellChanges[ spellID ] or spellID
                        if not IsSpellKnown( spellID, false ) then return end

                        local school = spellSchools[ spellSchool ]
                        if not school then return end

                        if     school == "arcane" then __last_arcane = GetTime(); __last_arcSpell = spellName
                        elseif school == "fire"   then __last_fire   = GetTime(); __last_firSpell = spellName
                        elseif school == "frost"  then __last_frost  = GetTime(); __last_froSpell = spellName end
                        return
                    elseif subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.disciplinary_command.id then
                        __last_disciplinary_command = GetTime()
                        __last_arcane = 0
                        __last_fire = 0
                        __last_frost = 0
                    end
                end
            end, false )

            x:RegisterAbility( "buff_disciplinary_command", {
                cooldown_special = function ()
                    local remains = ( now + offset ) - __last_disciplinary_command

                    if remains < 30 then
                        return __last_disciplinary_command, 30
                    end

                    return 0, 0
                end,
                unlisted = true,

                cast = 0,
                cooldown = 30,
                gcd = "off",

                handler = function()
                    applyBuff( "disciplinary_command" )
                end,
            } )
        end

        Hekili:EmbedDisciplinaryCommand( spec )
    end


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then
                removeBuff( "arcane_charge" )
            else
                applyBuff( "arcane_charge", nil, arcane_charges.current )
            end

        elseif resource == "mana" then
            if azerite.equipoise.enabled and mana.percent < 70 then
                removeBuff( "equipoise" )
            end
        end
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then
                removeBuff( "arcane_charge" )
            else
                if talent.rule_of_threes.enabled and arcane_charges.current >= 3 and arcane_charges.current - amt < 3 then
                    applyBuff( "rule_of_threes" )
                end
                applyBuff( "arcane_charge", nil, arcane_charges.current )
            end
        end
    end )


    spec:RegisterStateTable( "burn_info", setmetatable( {
        __start = 0,
        start = 0,
        __average = 20,
        average = 20,
        n = 1,
        __n = 1,
    }, {
        __index = function( t, k )
            if k == "active" then
                return t.start > 0
            end
        end,
    } ) )


    spec:RegisterTotem( "rune_of_power", 609815 )


    spec:RegisterStateTable( "incanters_flow", {
        changed = 0,
        count = 0,
        direction = 0,

        startCount = 0,
        startTime = 0,
        startIndex = 0,

        values = {
            [0] = { 0, 1 },
            { 1, 1 },
            { 2, 1 },
            { 3, 1 },
            { 4, 1 },
            { 5, 0 },
            { 5, -1 },
            { 4, -1 },
            { 3, -1 },
            { 2, -1 },
            { 1, 0 }
        },

        f = CreateFrame( "Frame" ),
        fRegistered = false,

        reset = setfenv( function ()
            if talent.incanters_flow.enabled then
                if not incanters_flow.fRegistered then
                    Hekili:ProfileFrame( "Incanters_Flow_Arcane", incanters_flow.f )
                    -- One-time setup.
                    incanters_flow.f:RegisterUnitEvent( "UNIT_AURA", "player" )
                    incanters_flow.f:SetScript( "OnEvent", function ()
                        -- Check to see if IF changed.
                        if state.talent.incanters_flow.enabled then
                            local flow = state.incanters_flow
                            local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )
                            local now = GetTime()

                            if name then
                                if count ~= flow.count then
                                    if count == 1 then flow.direction = 0
                                    elseif count == 5 then flow.direction = 0
                                    else flow.direction = ( count > flow.count ) and 1 or -1 end

                                    flow.changed = GetTime()
                                    flow.count = count
                                end
                            else
                                flow.count = 0
                                flow.changed = GetTime()
                                flow.direction = 0
                            end
                        end
                    end )

                    incanters_flow.fRegistered = true
                end

                if now - incanters_flow.changed >= 1 then
                    if incanters_flow.count == 1 and incanters_flow.direction == 0 then
                        incanters_flow.direction = 1
                        incanters_flow.changed = incanters_flow.changed + 1
                    elseif incanters_flow.count == 5 and incanters_flow.direction == 0 then
                        incanters_flow.direction = -1
                        incanters_flow.changed = incanters_flow.changed + 1
                    end
                end

                if incanters_flow.count == 0 then
                    incanters_flow.startCount = 0
                    incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                    incanters_flow.startIndex = 0
                else
                    incanters_flow.startCount = incanters_flow.count
                    incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                    incanters_flow.startIndex = 0

                    for i, val in ipairs( incanters_flow.values ) do
                        if val[1] == incanters_flow.count and val[2] == incanters_flow.direction then incanters_flow.startIndex = i; break end
                    end
                end
            else
                incanters_flow.count = 0
                incanters_flow.changed = 0
                incanters_flow.direction = 0
            end
        end, state ),
    } )

    spec:RegisterStateExpr( "incanters_flow_stacks", function ()
        if not talent.incanters_flow.enabled then return 0 end

        local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
        if index > 10 then index = index % 10 end

        return incanters_flow.values[ index ][ 1 ]
    end )

    spec:RegisterStateExpr( "incanters_flow_dir", function()
        if not talent.incanters_flow.enabled then return 0 end

        local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
        if index > 10 then index = index % 10 end

        return incanters_flow.values[ index ][ 2 ]
    end )

    -- Seemingly, a very silly way to track Incanter's Flow...
    local incanters_flow_time_obj = setmetatable( { __stack = 0 }, {
        __index = function( t, k )
            if not state.talent.incanters_flow.enabled then return 0 end

            local stack = t.__stack
            local ticks = #state.incanters_flow.values

            local start = state.incanters_flow.startIndex + floor( state.offset + state.delay )

            local low_pos, high_pos

            if k == "up" then low_pos = 5
            elseif k == "down" then high_pos = 6 end

            local time_since = ( state.query_time - state.incanters_flow.changed ) % 1

            for i = 0, 10 do
                local index = ( start + i )
                if index > 10 then index = index % 10 end

                local values = state.incanters_flow.values[ index ]

                if values[ 1 ] == stack and ( not low_pos or index <= low_pos ) and ( not high_pos or index >= high_pos ) then
                    return max( 0, i - time_since )
                end
            end

            return 0
        end
    } )

    spec:RegisterStateTable( "incanters_flow_time_to", setmetatable( {}, {
        __index = function( t, k )
            incanters_flow_time_obj.__stack = tonumber( k ) or 0
            return incanters_flow_time_obj
        end
    } ) )


    spec:RegisterStateExpr( "fake_mana_gem", function ()
        return false
    end )


    spec:RegisterStateFunction( "start_burn_phase", function ()
        burn_info.start = query_time
    end )


    spec:RegisterStateFunction( "stop_burn_phase", function ()
        if burn_info.start > 0 then
            burn_info.average = burn_info.average * burn_info.n
            burn_info.average = burn_info.average + ( query_time - burn_info.start )
            burn_info.n = burn_info.n + 1

            burn_info.average = burn_info.average / burn_info.n
            burn_info.start = 0
        end
    end )


    spec:RegisterStateExpr( "burn_phase", function ()
        return burn_info.start > 0
    end )

    spec:RegisterStateExpr( "average_burn_length", function ()
        return burn_info.average or 15
    end )


    local clearcasting_consumed = 0


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_CAST_SUCCESS" then
                if spellID == 12042 then
                    burn_info.__start = GetTime()
                    -- Hekili:Print( "Burn phase started." )
                elseif spellID == 12051 and burn_info.__start > 0 then
                    burn_info.__average = burn_info.__average * burn_info.__n
                    burn_info.__average = burn_info.__average + ( query_time - burn_info.__start )
                    burn_info.__n = burn_info.__n + 1

                    burn_info.__average = burn_info.__average / burn_info.__n
                    burn_info.__start = 0
                    -- Hekili:Print( "Burn phase ended." )

                    -- Setup for opener_done variable.
                    if not ( state.runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
                        opener_completed = true
                        -- Hekili:Print( "Opener completed (evocation)." )
                    end
                end

            elseif subtype == "SPELL_AURA_REMOVED" and ( spellID == 276743 or spellID == 263725 ) then
                -- Clearcasting was consumed.
                clearcasting_consumed = GetTime()
            end
        end
    end, false )


    spec:RegisterStateExpr( "tick_reduction", function ()
        return action.shifting_power.cdr / 4
    end )

    spec:RegisterStateExpr( "full_reduction", function ()
        return action.shifting_power.cdr
    end )


    local abs = math.abs

    local ExpireArcaneLucidity = setfenv( function()
        mana.regen = mana.regen / 1.25
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        if burn_info.__start > 0 and ( ( state.time == 0 and now - player.casttime > ( gcd.execute * 4 ) ) or ( now - burn_info.__start >= 45 ) ) and ( ( cooldown.evocation.remains == 0 and cooldown.arcane_power.remains < action.evocation.cooldown - 45 ) or ( cooldown.evocation.remains > cooldown.arcane_power.remains + 45 ) ) then
            -- Hekili:Print( "Burn phase ended to avoid Evocation and Arcane Power desynchronization (%.2f seconds).", now - burn_info.__start )
            burn_info.__start = 0
        end

        if buff.casting.up and buff.casting.v1 == 5143 and abs( action.arcane_missiles.lastCast - clearcasting_consumed ) < 0.15 then
            applyBuff( "clearcasting_channel", buff.casting.remains )
        end

        burn_info.start = burn_info.__start
        burn_info.average = burn_info.__average
        burn_info.n = burn_info.__n

        if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

        fake_mana_gem = GetItemCount( 36799 ) > 0

        incanters_flow.reset()

        -- This will set the opener to be completed, which persists while in combat.  For opener_done.
        if not opener_completed and InCombatLockdown() then
            if true_active_enemies > variable.aoe_target_count then
                opener_completed = true
                -- Hekili:Print( "Opener completed (aoe)." )
            elseif buff.arcane_power.down and cooldown.arcane_power.true_remains > 0 and ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
                opener_completed = true
                -- Hekili:Print( "Opener completed (Arcane Power)." )
            end
        end

        -- Tier 28
        if buff.arcane_lucidity.up then
            state:QueueAuraExpiration( "arcane_lucidity", ExpireArcaneLucidity, buff.arcane_lucidity.expires )
        end
    end )


    spec:RegisterStateFunction( "handle_radiant_spark", function()
        if debuff.radiant_spark_vulnerability.down then applyDebuff( "target", "radiant_spark_vulnerability" )
        else
            debuff.radiant_spark_vulnerability.count = debuff.radiant_spark_vulnerability.count + 1

            -- Implemented with max of 5 stacks (application of 5th stack makes the debuff expire in 0.1 seconds, to give us time to Arcane Barrage).
            if debuff.radiant_spark_vulnerability.stack == debuff.radiant_spark_vulnerability.max_stack then
                debuff.radiant_spark_vulnerability.expires = query_time + 0.1
                applyBuff( "radiant_spark_consumed", debuff.radiant_spark.remains )
            end
        end
    end )


    -- Tier 28
	spec:RegisterGear( "tier28", 188845, 188844, 188843, 188842, 188839 )
    spec:RegisterSetBonuses( "tier28_2pc", 364539, "tier28_4pc", 363682 )
    -- 2-Set - Arcane Lucidity - Increases your Arcane damage dealt to enemies affected by Touch of the Magi by %10%.
    -- 4-Set - Arcane Lucidity - Touch of the Magi's duration is increased by 4 sec and grants 25% mana regeneration for 12 sec.
    spec:RegisterAura( "arcane_lucidity", {
        id = 363685,
        duration = 12,
        max_stack = 1,
    } )


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


        arcane_barrage = {
            id = 44425,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 236205,

            -- velocity = 24, -- ignore this, bc charges are consumed on cast.

            handler = function ()
                if level > 51 then gain( 0.02 * mana.max * arcane_charges.current, "mana" ) end

                spend( arcane_charges.current, "arcane_charges" )
                removeBuff( "arcane_harmony" )

                if talent.chrono_shift.enabled then
                    applyBuff( "chrono_shift_buff" )
                    applyDebuff( "target", "chrono_shift" )
                end

                if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
            end,
        },


        arcane_blast = {
            id = 30451,
            cast = function ()
                if buff.presence_of_mind.up then return 0 end
                return 2.25 * ( 1 - ( 0.08 * arcane_charges.current ) ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.rule_of_threes.up then return 0 end
                local mult = 0.0275 * ( 1 + arcane_charges.current ) * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
                -- if azerite.equipoise.enabled and mana.pct < 70 then return ( mana.modmax * mult ) - 190 end
                return mana.modmax * mult, "mana"
            end,
            spendType = "mana",

            startsCombat = true,
            texture = 135735,

            handler = function ()
                if buff.presence_of_mind.up then
                    removeStack( "presence_of_mind" )
                    if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
                end
                removeBuff( "rule_of_threes" )
                removeStack( "nether_precision" )
                gain( 1, "arcane_charges" )

                if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
            end,
        },


        arcane_explosion = {
            id = 1449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            discipline = "arcane",

            spend = function ()
                if not pvptalent.arcane_empowerment.enabled and buff.clearcasting.up then return 0 end
                return 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 )
            end,
            spendType = "mana",

            startsCombat = true,
            texture = 136116,

            usable = function () return not state.spec.arcane or target.distance < 10, "target out of range" end,
            handler = function ()
                if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                else
                    removeStack( "clearcasting" )
                    if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
                end
                gain( 1, "arcane_charges" )
            end,
        },


        summon_arcane_familiar = {
            id = 205022,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = false,
            texture = 1041232,

            nobuff = "arcane_familiar",
            essential = true,

            handler = function ()
                if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
                applyBuff( "arcane_familiar" )
            end,

            copy = "arcane_familiar"
        },


        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,

            startsCombat = false,
            texture = 135932,

            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },


        arcane_missiles = {
            id = 5143,
            cast = function () return ( buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
            channeled = true,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.rule_of_threes.up or buff.clearcasting.up then return 0 end
                return 0.15 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            aura = function () return buff.clearcasting_channel.up and "clearcasting_channel" or "casting" end,
            breakchannel = function ()
                removeBuff( "clearcasting_channel" )
            end,

            tick_time = function ()
                if buff.clearcasting_channel.up then return buff.clearcasting_channel.tick_time end
                return 0.5 * haste
            end,

            start = function ()
                if buff.clearcasting.up then
                    removeStack( "clearcasting" )
                    if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
                    applyBuff( "clearcasting_channel" )
                elseif buff.rule_of_threes.up then removeBuff( "rule_of_threes" ) end

                if buff.expanded_potential.up then removeBuff( "expanded_potential" ) end

                if conduit.arcane_prodigy.enabled and cooldown.arcane_power.remains > 0 then
                    reduceCooldown( "arcane_power", conduit.arcane_prodigy.mod * 0.1 )
                end
            end,

            tick = function ()
                if legendary.arcane_harmony.enabled then addStack( "arcane_harmony", nil, 1 ) end
                if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
            end,

            auras = {
                arcane_harmony = {
                    id = 332777,
                    duration = 3600,
                    max_stack = 18
                },
                clearcasting_channel = {
                    duration = function () return 2.5 * haste end,
                    tick_time = function () return ( 2.5 / 6 ) * haste end,
                    max_stack = 1,
                }
            }
        },


        arcane_orb = {
            id = 153626,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 1033906,

            talent = "arcane_orb",

            handler = function ()
                gain( 1, "arcane_charges" )
                applyBuff( "arcane_orb" )
            end,
        },


        arcane_power = {
            id = 12042,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",

            toggle = "cooldowns",
            nobuff = "arcane_power", -- don't overwrite a free proc.

            startsCombat = true,
            texture = 136048,

            handler = function ()
                applyBuff( "arcane_power" )
                if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
                start_burn_phase()
            end,
        },


        blink = {
            id = function () return talent.shimmer.enabled and 212653 or 1953 end,
            cast = 0,
            charges = function () return talent.shimmer.enabled and 2 or nil end,
            cooldown = function () return ( talent.shimmer.enabled and 20 or 15 ) - conduit.flow_of_time.mod * 0.001 end,
            recharge = function () return ( talent.shimmer.enabled and ( 20 - conduit.flow_of_time.mod * 0.001 ) or nil ) end,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

            handler = function ()
                if conduit.tempest_barrier.enabled then applyBuff( "tempest_barrier" ) end
            end,

            copy = { 212653, 1953, "shimmer", "blink_any" },

            auras = {
                tempest_barrier = {
                    id = 337299,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        conjure_mana_gem = {
            id = 759,
            cast = 3,
            cooldown = 0,
            icd = 10, -- Probably don't want to recast within 10 seconds.
            gcd = "spell",

            spend = 0.18,
            spendType = "mana",

            startsCombat = false,
            texture = 134132,

            usable = function ()
                if fake_mana_gem then return false, "already has a mana_gem" end
                return true
            end,

            handler = function ()
                fake_mana_gem = true
            end,
        },


        mana_gem = {
            name = "|cff00ccff[Mana Gem]|r",
            known = function ()
                return state.fake_mana_gem
            end,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 134132,

            item = 36799,
            bagItem = true,

            usable = function ()
                return fake_mana_gem, "requires mana_gem in bags"
            end,

            readyTime = function ()
                local start, duration = GetItemCooldown( 36799 )
                return max( 0, start + duration - query_time )
            end,

            handler = function ()
                gain( 0.25 * health.max, "health" )
            end,

            copy = "use_mana_gem"
        },


        --[[ shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 135739,

            talent = "shimmer",

            handler = function ()
                -- applies shimmer (212653)
            end,
        }, ]]


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
            cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end, -- Assume always successful.
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        evocation = {
            id = 12051,
            cast = function () return 6 * haste end,
            charges = 1,
            cooldown = 90,
            recharge = 90,
            gcd = "spell",

            channeled = true,
            fixedCast = true,

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136075,

            aura = "evocation",
            tick_time = function () return haste end,

            start = function ()
                stop_burn_phase()
                applyBuff( "evocation" )
                if azerite.brain_storm.enabled then
                    gain( 2, "arcane_charges" )
                    applyBuff( "brain_storm" )
                end

                if legendary.siphon_storm.enabled then
                    applyBuff( "siphon_storm" )
                end

                mana.regen = mana.regen * 8.5 / haste
            end,

            tick = function ()
                if legendary.siphon_storm.enabled then
                    addStack( "siphon_storm", nil, 1 )
                end
            end,

            finish = function ()
                mana.regen = mana.regen / 8.5 * haste
            end,

            breakchannel = function ()
                removeBuff( "evocation" )
                mana.regen = mana.regen / 8.5 * haste
            end,

            auras = {
                -- Legendary
                siphon_storm = {
                    id = 332934,
                    duration = 30,
                    max_stack = 5
                }
            }
        },


        fire_blast = {
            id = 319836,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            discipline = "fire",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135807,

            handler = function ()
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
                if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
            end,
        },


        focus_magic = {
            id = 321358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

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


        frostbolt = {
            id = 116,
            cast = 1.874,
            cooldown = 0,
            gcd = "spell",

            discipline = "frost",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135846,

            handler = function ()
                applyDebuff( "target", "chilled" )
                if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
            end,
        },


        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            discipline = "frost",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135848,

            handler = function ()
                applyDebuff( "target", "frost_nova" )
                if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
            end,
        },


        greater_invisibility = {
            id = 110959,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 575584,

            handler = function ()
                applyBuff( "greater_invisibility" )
                if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
            end,

            auras = {
                -- Conduit
                incantation_of_swiftness = {
                    id = 337278,
                    duration = 6,
                    max_stack = 1
                }
            }
        },


        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) end,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 135841,

            handler = function ()
                applyBuff( "ice_block" )
                applyDebuff( "player", "hypothermia" )
            end,
        },


        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            handler = function ()
                applyBuff( "mirror_image", nil, 3 )
            end,
        },


        nether_tempest = {
            id = 114923,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 610471,

            handler = function ()
                applyDebuff( "target", "nether_tempest" )
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 136071,

            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },


        presence_of_mind = {
            id = 205025,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136031,

            nobuff = "presence_of_mind",

            handler = function ()
                applyBuff( "presence_of_mind", nil, level > 53 and 3 or 2 )
            end,
        },


        prismatic_barrier = {
            id = 235450,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            defensive = true,

            spend = function() return 0.03 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 135991,

            handler = function ()
                applyBuff( "prismatic_barrier" )
                if legendary.triune_ward.enabled then
                    applyBuff( "blazing_barrier" )
                    applyBuff( "ice_barrier" )
                end
            end,
        },


        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
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

            spend = function () return 0.08 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
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
            charges = 2,
            cooldown = 40,
            recharge = 40,
            gcd = "spell",

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",

            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },


        slow = {
            id = 31589,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136091,

            handler = function ()
                applyDebuff( "target", "slow" )
            end,
        },


        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
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

            spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135729,

            debuff = "stealable_magic",
            handler = function ()
                removeDebuff( "target", "stealable_magic" )
            end,
        },


        supernova = {
            id = 157980,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 1033912,

            talent = "supernova",

            handler = function ()
            end,
        },


        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.5 or 0.7 ) or 1 ) end,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,

            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },


        touch_of_the_magi = {
            id = 321507,
            cast = 1.5,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 1033909,

            handler = function ()
                applyDebuff( "target", "touch_of_the_magi" )
                if set_bonus.tier28_4pc > 0 then
                    applyBuff( "arcane_lucidity" )
                    mana.regen = mana.regen * 1.25
                    state:QueueAuraExpiration( "arcane_lucidity", ExpireArcaneLucidity, buff.arcane_lucidity.expires )
                end
                if level > 45 then gain( 4, "arcane_charges" ) end
            end,
        },


        -- Mage - Kyrian    - 307443 - radiant_spark        (Radiant Spark)
        -- TODO: Increase vulnerability stack on direct damage spells.
        radiant_spark = {
            id = 307443,
            cast = 1.5,
            cooldown = 30,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 3565446,

            toggle = "essences",

            handler = function ()
                applyBuff( "radiant_spark" )
                applyDebuff( "target", "radiant_spark" )
                -- applyDebuff( "target", "radiant_spark_vulnerability" )
                -- RSV doesn't apply until the next hit.
            end,

            auras = {
                radiant_spark = {
                    id = 307443,
                    duration = 10,
                    max_stack = 1
                },
                radiant_spark_vulnerability = {
                    id = 307454,
                    duration = 8,
                    max_stack = 5
                },
                radiant_spark_consumed = {
                    id = 307747,
                    duration = 10,
                    max_stack = 1
                },
            }
        },

        -- Mage - Necrolord - 324220 - deathborne           (Deathborne)
        deathborne = {
            id = 324220,
            cast = 1.5,
            cooldown = 180,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3578226,

            toggle = "essences", -- maybe should be cooldowns.

            handler = function ()
                applyBuff( "deathborne" )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                deathborne = {
                    id = 324220,
                    duration = function () return 20 + ( conduit.gift_of_the_lich.mod * 0.001 ) end,
                    max_stack = 1,
                },
            }
        },

        -- Mage - Night Fae - 314791 - shifting_power       (Shifting Power)
        shifting_power = {
            id = 314791,
            cast = function () return 4 * haste end,
            channeled = true,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3636841,

            toggle = "essences",

            -- -action.shifting_power.execute_time%action.shifting_power.new_tick_time*(dbc.effect.815503.base_value%1000+conduit.discipline_of_the_grove.time_value)
            cdr = function ()
                return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
            end,

            full_reduction = function ()
                return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
            end,

            start = function ()
                applyBuff( "shifting_power" )
            end,

            tick  = function ()
                -- TODO: Identify which abilities have their CDs reduced.
            end,

            finish = function ()
                removeBuff( "shifting_power" )
            end,

            auras = {
                shifting_power = {
                    id = 314791,
                    duration = function () return 4 * haste end,
                    tick_time = function () return haste end,
                    max_stack = 1,
                },
                heart_of_the_fae = {
                    id = 356881,
                    duration = 15,
                    max_stack = 1,
                }
            }
        },

        -- Mage - Venthyr   - 314793 - mirrors_of_torment   (Mirrors of Torment)
        -- TODO:  Get spell ID of the snare, root, silence.
        mirrors_of_torment = {
            id = 314793,
            cast = 1.5,
            cooldown = 90,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 3565720,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "mirrors_of_torment", nil, 3 )
            end,

            auras = {
                mirrors_of_torment = {
                    id = 314793,
                    duration = 20,
                    max_stack = 3, -- ???
                },
                -- Conduit
                siphoned_malice = {
                    id = 337090,
                    duration = 10,
                    max_stack = 3
                }
            },
        },
    } )


    spec:RegisterSetting( "arcane_info", nil, {
        type = "description",
        name = "The Arcane Mage module treats combat as one of two phases.  The 'Burn' phase begins when you have used Arcane Power and begun aggressively burning mana.  The 'Conserve' phase starts when you've completed a burn phase and used Evocation to refill your mana bar.  This phase is less " ..
            "aggressive with mana expenditure, so that you will be ready when it is time to start another burn phase.",
        width = "full",
        fontSize = "medium",
        order = 1,
    } )

    --[[ spec:RegisterSetting( "am_spam", 0, {
        type = "toggle",
        name = "Use |T136096:0|t Arcane Missiles Spam",
        icon = 136096,
        width = "full",
        get = function () return Hekili.DB.profile.specs[ 62 ].settings.am_spam == 1 end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 62 ].settings.am_spam = val and 1 or 0
        end,
        order = 2,
    } ) ]]


    --[[ spec:RegisterSetting( "conserve_mana", 75, { -- NYI
            type = "range",
            name = "Minimum Mana (Conserve Phase)",
            desc = "Specify the amount of mana (%) that should be conserved when conserving mana before a burn phase.",

            min = 25,
            max = 100,
            step = 1,

            width = "full",
            order = 2,
        }
    } ) ]]


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "spectral_intellect",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20220613, [[Hekili:S3ZAZTTrs(BXF4SKsCKLOKCS3YYv5413TBQ4exrzR9(KibbhkIyqag8qYAlx83(nDppWmdMxaKkX5I)WM1IayME6UN(90Z1NE9VC9vlsAix)JtozYKtE2PND8KtNC(5NF9vn3VHC9vBss)qYn0)rrYA6)91vPjf4pFFEzYc4ZRlBRsP)0QMMn1)TN(0BYAw1o)40Y1pToBDBEstwzrAvYYg4VtF61xnVnlV5FwC9CRZ9zpJoMBiPx)JpBcDuZwSGWEvsD61x9okWSDgdm2(9FFl9)o70ZEY2zWyS973(9VzvsXnK6)22V)B2o7FvtFmDHKLMKVD2vzRFZ2z0NVipR4MTZkxUDwk9pli0hMv0qQQA3aql8x1nKKfS35a6KLsYNMKcp8GJXHMnpBNLGGY0SILzfzn3tNUs5pUkPADzb93omRz7ScYTKQTZUJuq)J8SBHpU28DpIn6)D68qFR3EBzkfdbWdDr)tVD7SFTTM(7ZjPjTWA7(Y2dQO))LTnmyTIdvfuyVOK(JT14ALJXM92pUjVSMUmyZZRxWgWnvzLvsWhhAXx8(Y7ivhqbuYYLekgaG70YY8fL3rbQ5j1eanr)NV5V)ZIxQ(4o0FDtvwkofLPKAg0atsfzrBk95V59)l6pKTM(px0s4aaLMaVCsffIE97)HTZwww9b(O(UYBHP82KQSK55K6NsjUPC(SA23)dTjBNTUCrBoXXKD81xLNv3udCW3MusO)))iUBGuad6IR)URVkLIri0jHUxabVxUD23E9vmUGRVQIY7nTC50na(56gkx8G(CozVSAo8TNnMVLiOLWiCUXiiE31LLf5zntPu461Qd8MkYTtVjDXXNE86SQQYQAy10uwTgzqFmLRD7ShrPO)wB2MnKfh3SImDzwvDZ06SBYOBz(0N64emF6XvK1jza94iHSdDiHcYx4Cr3nQLTPRq4Io8RtUjRBCF5LieYwNhtWDk4)6JK02gYugI7RbXduGaxqYHLJars3ygXZXLLaflFtyr9SauYxTD2Z0bMaRXxGV982LlpUoBZQYIP1ar642nke5Eeqau(wNGcoACKavcy1nKJRBOs63o7s(uP)W1jFCk)fSclsa(vGGy8LOColi4B2h40GDBmZp3jK7BmX5vUF50Z6nhZZtQrmZlgX43TgP4OtFrK0q3WWPNef5HXJYe2g1mY4A05zdZ7tjCuaYTWTtdjCeXkNfZuzcEDZAV1eoZHKRsb9Zy8CkI00xabMb3sFvgX(FQjPTdzzkm(3PDENBSZRppcqw8V170DxQ8Z15c0ifoLTnACscAtYusbzDgPg36tfW(nOO8t3o7ROwGqAMoVSOT(4Mms1KNpDYMunb492A2ti(kkmF9vNs)XKQ87NI)90SLC6zAobgI6gQXnt5wuIO6hRdCV8zQOtla(lIcWXLTtsmxoOZNRYXWv1Xx)RZOMNrnO6y77onElerfqfJkIHoX0rY)W5wUVxEKtIrSdiH7cx2FDQBncsHmNEYEGBnM9qmtV8SxNYPm5cM9x9FRbPQaLAFQ1ndjvvGJFGHTXPPshz8s)id)cHM4wBZUH(vKNBSo9bpuU2Lz1RGD3LBO7xRS5TqFRbrxwRY2W(J)9kcLUqfgwGUarOUjdUds)VuptVI6cf9p(L)n1ZqYnKIfuNBi1pb8wK()sadYb3yO(dco)rDgIW)YFPS5Dp91VN(szfuI9XCNUa)nbNlRlbpZG)1px(EW3x6)cCuTEf61wl6p6bGlDuxUHzb)jgQRwfTFic6WmtXPnK1BkRsYNExs1MJ54ag)O27PXxkFnMkkH7BhtjjBAZZNsG12LOOVJec5eBd0vHW4WHzZj5SNf)wvczZRTqKX)5sjkZar25umJwuZDd3cM9jspUZ(peozTeJoaeJG7BwXyrYRjAsIsYrdr1wkQO1qQCdlK0q(MHXNoPfE3z5192oMLfz1PzBYZkOo9pnTC9AkYtB1HZUT3A6YQYADNkOEIQOp3T5yDt)nuVsPA2ZsZOkT0Mx6uKC8gieguLaVqrfcoTtlkVnXM3SU0ZPymHn4G)68Wb1hby8C7sBfpvx43HDBOStFDXCKS4ECdfSLZRDhh53d40YIfTznhFt2YgX3MNLUQdzTGK0SAEzvbXVdS(LX4Xpg3wy4CZdD17YSb3wn4B0cygXq1CgJhLD(ODbgbd3MyEUHTX2dTqp3bLVURWnze9Jh6ylX8A0oBGcCBZ7pNBCTPhaueN0acj(ieQtk9PMfi238gU4Fqd(QKBjyaDBXOL(UYFz7S7jnpHhQ1e(NYuYdssrngRBlszAcAlOaqTI1dOU))Hi8YctgUpcdW7y(0EMHnuApZ0cwk0rTi5yaixDFLUKdRborWZRQ2hmHGsmil6uz7xcuahRFuegOi57czIc3sgF2OSBEcCeY7QXq9Juiijp)EghZMKmkMDtj8moxYDulgHOH)eyWBy24DxwoDZciaG(FlrJgkkBVzfgWC67vcFcYSG2)HmKDwlw7IZYH9OD7nyawG4fmot3CPmOVt57TjQkzrgLJEA9MKQpeJFTUcPbY18muc7eu8AigTWcAnvyznMtE90WHScHWhGDq4sb4nbti0I21BqbtlBrEsKVfGyjYRdLeypTfmgpgfhQACfd5nPt)0jigukU5d3tNLcHZbsFFhJuSJc4YFmlOXTV3Q91wIgUpVVfVADjL0qAWGov1oVVW)bVJO3J12yiflQ8cDBrfc4JGJNPYUh4hHF)FUUIeKeRHxEI7aypUWlpXLfl0HRMuKIOO1uj8gYfWid8(s(o86FRLqaVpHnvKp2uL0LZ3VJPrzrBvNeeJinyr1HmhZPRkpE7mWcj1FIQXI(2mNyjl4X2G(yUDrCqd0Ybz72)CcFQmJ98x(1VtMo)Nar(aTpdupwNaERt97WWEbU)0C0lbGAvtf29iSQNqrvZ1nYP4xXflysa7j0AIR08gG0d0ce9UkPgr4ZjKcH5O9iZc89tKOWwrqLIKZrsbPMDOgEkxrYttTGxvS7FuQBdywu2OlWqlAYxO5qS27n9228csvY8mQtjsN0PFZjU9EBIP9noujyORNOgFW1jFG(31TGUCHFhDMec6A5ggI0gkZFg8MD0NNGbGcQ)LL47urGc)GQ)e4by4vggGv)mfi9f2Q3aVh1fS7boRMgmWMqOkBRky)R)dPQKB)jgTlycIYMZJT6vTTau84(wtC(jXznXoRupE3kce3ttvoU9Kr714WMruJq2kttzJIT67eQpRxrvtlQLO5eHiJKgjpeViPaMiGO(wrCtzI750giUZlQk3SbP38OGkCFHX1IsxW)f4iJbh0QkglSc3hqRJxCIbdJI0eQ6xDxp7k8d1WehWo8irJj53LCFndtI4pM4Y0Ecn7u5bOoHqzaBrLN10f)FjQeJYCadMCIq8fHxRiRyz(6zJ9ytK6H2iVF6th(iUsCi65CB15VR5s)tFYkfMYEE0rhPj1pGE)aMnicXANHKkgQcCnQ58vDFFy7j2dzS9mxEty(UoJ2fpSpuvfzRxtOk9AiGyF0cbiOx3HEFMMaX1JThgLDChLQsyvbiKdQQY1yCW0LUBjYsJ0jpCTA6nH2s6QMKQU6JeGCWasg0)ArUY6mtk2qRfobl2tQfWCjDQTNySJu364J862xd3k4Gn2s1snLnRNcOrzsaTh67ZCNthpRoTCPyjD8sRHoZLHUk5Lt6aakarm0V6YNFH2ZeCPgPCXPdLoLqIW1fQXv2u4Fh8IjnUQSHbQEsxSx9hOhBeH9s8nG5Gwbq)kZEo0MkbxhKZrmK0ZXkcg1GckT3OUYTxwjbdTRh1cUR2mFEhTD2zABiSYC(kp8MQIJ1HovbYDFof6M2sn6nFAYghJ8csEY9tP61WxH5GGtgDMvF2rNa3(JSHspkmcsyo7UHygyz4zyaT6WNSbCDkBDlmjfjt3OMgbBBH8wojUfC85n(miJ2O2PStCNEWYUZuYN3yzg05hxRLCqhi7a4pQViIf1dffWtCfIoKbxgv8f65lQll8TBGrFl8JR6BIYzbVOi3P0rI5HZNYuWamJq2gbArpoDrGTFzuVSwaKCAatGmi1lSuHcQyONRH5dfEm3GDV6J4loS50HTdJHCeNpBgY06XDiho2RzgelV(ey6dECE89MYI621IWmq(4gQDMacBtzde3q480blDi(eGKqPFE5LGnRkVf6XxSEpHptmztLJcKISglf4IZLITASY38AvMPMlz29Nz)r)z5KmGxcJFb2)zr7gDVdGHgFYR5r0QPIF4bNNu8bM)0yKMTuvKy1lWsWmfFTwgT57pWW1fkJqwfz8lrZSgCOh8WxflDcJOmKZoSKFI1XCpNXKdHy6TKUJFf8qPnynzPFadnX(i(0UmiWNgf0Lx5AQGa5dykepAcVCZgZPCzuXAWtnMihlkttD2cClQIZWAU0GN4eLyou3UHujkFZWLxsoHHEQiuMclHsTNHUEoaA9kWKOchWFh3ZiTwMfta6(SeiUWZjyGbyrfMk8Mub5(HfJaaORxvIrGgcxarpi98e8a)Pa3DTEQsdLzdvZODsj2nwyDT4uod7(EP8CRrU2GDW4OJyn2)Eowk)LfVWcFJL0z2zCFVcSzS84uywjzsdB3)FoXTpEizuexfooOqG5QpxehRawpzNEitSVzQSUboimScw0A2SkxY)XU0l7sfXysx3Uryp0p(hqRHYVLaRoQa7U7yvLCegrS39BcGLp6ZBCURdTZ4W5(r0QfedtEeKPAqCeV)AaGfR2CrAcy07RFVFwDFy(WgMnOqbSZ0oeHhOg5DuBkyU0qKydmMC0wwHmmO69ReSGtyVZAEgUbVBlbIg4aUSKvLf3N(rC7(YwZsErQhbCNyfEQ4alDKUZNjfsjyokxth9fSEGHSwzzaL40kyvd0qlv0xDPSqMuJVW3OeFbZN9kTcp3iCfizYTf5JgodCAugbGAY8OFYpTMFn0SzTSR1VCPI0QGRTKjXgrzY4ITwDMHJWCO(ftNCSGNQnPiraxn16RBCOH8Ce4KYo8ed4Xk1H9grKhaUWNlfNlBV5dqZFqkEDQRKcCyOKc84W5eWA5(y3uJyc(Vmw0btyX(C(IiTEIy4RexqK)yEzEtWmA(haVBwfX6bjvc0Qi7baFSi2WyevXfAho0yoBQUpCOHjRNDYx2Y8N3TmYJ37UDgIdabQe(d1Tu2FOL1srV2YhWi7MHFQKRyah5IyNyD1li3afxWE8eyBT2x65pIOn)PrCvxVR6DUSp9IO3)RHE4JeJw017XgAJDA4J5xlJeEFqvljIEtGRv8zGmX117UmKz6RDCjia2cQ)l9gewxXG13bRkuaz0vGPuSAUp0t7u0fTpzIvI1ZJK7Z9weZ3H2NYENZQEZSTSuISQwtSNnyY3wWy3DzYy5EpJAXjg5zGxL5p44)8bb3p)p1MfCX(xZ)f7OYDhK0471CrSxXQiqVTDthoN6j5HJaS2vwOy4zVmYMYfN64ADp4IagxBARCCPDz)FVl(wruRWJal)fl(ILLkgl(SLe4yux3jhZ4y8j8knMLjNjLLW)WKwLx3NAFpjCokGYIPG)HiCpsFW2Bs(JC(IJiPPtyiTbIqdVtQtKBT(l7oDpuJi6DtFry7(Key0awCLpFFcG3vtwnCRWO9nC0xe7nwXE40(ieab63COktjlx2wdzYjPiBDY0K0usoPkHABJgW2z9dlEczPgUY7VhF42xVDigmrfQay1FXjbCp2tpizhGpCtqiyBY4Sz2(YWBq()YEYbaB768fh98HFpPF(fVfOAK6O(lQkZFxOAQmpbs2VpaDqeZjHqFFEtWom4EpOsfMeOu(B3873wtnIwx9qeLrVALF4RK9NMEn6iLYyuXgUvzlr10DZSB)t37yannb2B4oaD3(ryQpoZTBBpeqUx1Pqz(mXqnqGqnyEUqC7ruVMsYd7c1Lo)qAwCNWHhyOSp44uAAV(IHTmq4EsJ4yd2jXS)jfrReO612kggOC4q63DtmFHhhwqyFDs6GVBdpJb8heMSFY9IS7u44ien(ocxparRRCeqvTsfYfQ2od9Cnjj474RbO17qpzRtQ9ytR5j1LfWnINgUbghJBZKZLQ)T8WluusBRBcnVRqm7MhySyLs6XRij5nRK9QGZUqJXSx7WRr06ogcv4pDlBvQiUKrD4sD8YZ7KcwaERXCrHfr9Rg3I7XwxBqM7T0Eyu6IeJ8UIXN5QENp3AX8oFNmalr7SydFFJt5Rnm6QE1hVn(bUqXZDRJ7Wh2ZGyhe1)yeEEGE(Qdr1HrfMBGtwVjpBzM4s9Z)M4NhAtSxb(NhOnmfq9Zqa0Z9dib0dALyo0lGa97HYXCQqd6g5JJQpEBbEAGOyVmPnV5ArfBlE70YwiXV1Bi55gse9g7movIuKNDZQgkTqVOt1pSxp)eJFeKB(mhferKdPo7h2rEUHG36bXrTzsEuTzPRDUhtzo6UNuIZc5JRsARrE3o9OUK(H5HfqeZlH(67JHBvhkkyQMDmNRx)UyFAbMBaGdOuxB6KbbXxasI88qJuQ6P)A7IBevpsGtq8dgOmp5g8PvuP14U(40N3NnyoD3aPcK4dJsCkyTmk5LLlMUSTcd3FCQn7pkqrAJJemid6UYuZyCQ9A1naVAAcDxEJ3Q2Y)q1wtMsFZ1SJeSPecE(ostyH3Fj13vQTw05fU(JxQiJY9R0yPqFeF1n5G)qnqYdMNS4M(9ebdWoQapJxhmxeYFdk8G3PZtzlXEqsJN60X5TbJnJBIim5MLVxCv7htg7d4DnJRktX5Y)r2nVlcmWWU7GzVTz1lDOJE8LdRD0J2kAQ(uu3PURmpG4xxDgBQEO7PQqYPg4UaDn7ApHh1g70WknBOKqzGy)jUXtpDybOMdp0j3sQRj5dakXWhEI0EC1KRuwmfpmKxIECXTLq9eV8yL3x)6lu8rpoCLSjPk9wenwQidPqUY28Pz3uaRYbUApl8Qvn7YYzPXtbkCt(9Bq6Ac1Y41z58shCqW1Nhub7RKgphU)1jPjZPuT6ve6(21T1zPdyLJzmxztEGLcgOcvPnDBQTagnEo987lWomU3IbyXFpeaAy(gCUI5Y(rrAmV7z4h546yUt9sNU4jlah7rXvIQhUdbPYcY5kLOcNnlJdDg4HyYoZKy1HnmPUdQsV5PAX0hIGF7rkSQUWUnwssU25D)IJFg)oobor5u)kbIUSpcCvxTWSD2p3o)ES1O9RulROoR7SGz0D9SRGd0BvLFTmwCLMKOE3kg2Uce0(EL4G6(JliPvL5u1FIVN)X9jM6JXlLr7Brg13EQQZTZEkLidOoP1ekNxjQTi4o2fk5roI4I1VgCKjfU30d55(cDDx9Qzj3UfhOMGCwF4bs1GPDyGkiNgIrbAW5pqfOs4nOo8mL9htZZGZpp8F5wXFlCe2B8ME5bbbimpG4wAH(m8fHyneXHqBaXqD4WbFaqyXTR32zQdBKWWqS9di8Wxpg311nEt0CGL1VZGUci7oWd)odtsDSye6ChjdfoaiQaSB(K)OqKYwxFJ3es7cMp9pcyUdgyb(DtfjfY4u)q)kLc1qOY6t71BruF3621uiBk)twMqT6olX8sK9m1ViTS4xBRa1F8iZQ)UNR(USscDA26E9zepr2uw2e3wcEaKtTCSm)2EPmu(ABARBG2xiboKtzD5uqjAB5K6vPvjldeiZXrlrR9yx9ZcZVQkxKDJ(R0PCbBPOtRVVi1WavtDs(Ior3IRxbc5wiTQlowUGM0wT(A)ekyw1gVHBXOHN4hf7ClSIYzmECQQXtMK9knDVc5wnOYTRNMBL6DKoJqGBpWwjetkNhXgvz5EUspu6kb6oi8EL78F(9odRLrqDBa7zeIgjwYMJ3o7FjUZ9y)gR8zlH0NExwnr7ErRd9o6wqrKDQKOAY)A1O5Nphd5ilx7d)8T8WdCFKSlSbke2ajKueKRyZzj44W3EYwTYY9W48))vYy4Vd5oEVxcYSxjQYcxhlOvB8gxOkwfF0ex7jkczQ8foaR7qJA6)p0KX(I8O9P8i725etve87gtBWUlMYIqRZG5mTEw6Bd665XlV)3v(lDxA)IohkCpPsHmu3peMzO7vYVRK7Up)7UNnzFo0csFYwXTej9)vJYCznjwk2KyypweHFkMnxaL(fy8TpeVQU(kl3AqNd3AqhfddOiHSrmC(9bjIvhYnO9uEi9)8EzhWu2iITKVq7VV8AuFBVMJJUYhOYbj2(ThbMdn1REDf7GH9gmJFnUqzVJ68(t0V0JH28A32e2Md2xBE5FhbxuSmlMPr2dJWZ87lveaL)g(KXj223rT9lMb61bN)Wm)ZGe6YjtJtGt)Rns(b6itU7b7XYGEE8gIeVShwW)17k5xk8mLslHEyT8wygBcZykSwdnaf0Mb22oulM5TnEc24KX9Gn3b353ioCBxRyM3RNXRqAeWUJFN0dx1xmfF2V0VJ8GNsLB64GNoatK6nijYszmOLyhgHHIMhZlndVC8rEHpXfANOYT9cKHkN7xjYMBad1dW(B37aKT2vQTJLTwOFqCJ9UPSUodqmpi6lIHf0wlFzxCjjK6eKpBCDUrUjwEARyHNChNrOpRuAOjW9Z)ZI(dIILTEpbPoRCZafIqegqHf1Tv7Wdj9z33BC5d1vBR3g6L7e2ecxnaJnpuUhV7o0ONuGtptJSR3u98CUUh0fdTNy)e7IzOnZw0qqpj2Xtd7AyRn1tqR2KiNBRh1zpTOQHn)dKbpey52JJXDAP90dFychg1Tl8FPLR4La6PNeTd47Dbtf0i4qgZAfx2nNzd7Qyoe(7b5oCFxWFXeu3H6tGfmZ(4AUoeU9b5(C3JYLin4sZBPs7gagz4UJiW5HmSZVPKHf98QbD4xcPNmMlki)xEow6xmUcxEVZIVfV62uUM5mw9V1siq(XHGoq(ytvc9FoNDPrHXGOG(JDibXfZfCZqvKtGJqOOYuAq)cllGOKVOTcJvHiweiqd)m3fWvWv71A8QYCvBXnWf(e3u5U4OODhghu8xF(3ykQ8UghBJ36ACp0Eim78doUUBFS(UugY1dTTXBnqAzXpi0I(gaJBf8O3Dm81utxrE6PUpuIhRghoeqc8UzfI5gJldJbMse6XqY1Lxik78nqOZwrxxBLxzRQys9Je8zg1qQV0aeK1nKkh(9ZG1Arq)(FdIliUhc3zZe1XXJBNTK6b19hVD2Va7QX4)dLk)PpJ)M0jQ76Gd((KuELgJrNeLfaTNaiyJlBy4w8htz3c9Y4mcXTKXBZKISeJ5WXg6PKOoCYNkHYUt0Iyz3B79Q(x5hptGSbwdFfSgR92Oxj1ALOLDkj13U0yU1PdCT954QFNDV9XlqP3YpQBBN9t8Z6MmtKu(4LK7KIPfJgesoeBFxsg70o0rXa8gleX4FsrzvnkNrc8CBOszKhQWEN4oMvODNLgdrdMVUUUXN9CHuaHV09E)fz1m0ML0zhtqsCQaO35pGLHqFrwymD(CjhK9l8VyKtogp05HOO3bhzIyNJTJFH)vFex0FFMTgz29k5Dnxuc7oTwrSv41NpE0S7hFrZrsNRMBGODmS14v6E8SIxCW6U1Ouq6fLXisCnK7h4KuUqPrKfbzWwuO)RmQ3QhAUdk14I(J7Ojf7gYi7XJ6g1y636LY(t6HCd68xI5Cpo70)AVmZ18jmCWyDifWxp9mMss2ocmCyj7hH)io8g228PIPwrXgaFk4(BOqnoQRMz0hWjy(P5EOjx1GjBV(9F9p)tVx4mhKr7Vd6mi5y(IzP1UlPZu8)BEtnE4kttjlCPtE4EOhW5fNo7z3mrG9LBNy)pxJjt3pnoIPVBA4OmxGxGg3HTu8zNP0f1aVqRzuaFyFvuEa39KrXPh4k2j7jovIEdqi5iGuxvLXHidxOevzBxJC4lPRCFpjS5iRjHZNvKQHb7bavTpxAEKa6ovzbKaEOV4SzRz7YFrwZrgJsG6ADVeawzpD0RblqBjJK2aJ7RUSxVyzVJY7PhWvtuXIIFlEdsx9fOVCCytCvSZIJkyyvwtnjFjtCb1lkS0Ha32PUBxOEowGakBHCBWcdDzVt8R)3ahUhS57Oa5q0RctpzdWVYLE6i5TRrpjtCynjxe8mJerVJZD)qr4eWC1Nv8QJNXhTOe5IqV9FD5BLHxTMs(iSGlGxJ)ScHgzXKXIrexizOEQjavTBmylzGRJUgW4tiEdPie53USSTQz1OrQtgns1w6tnrGS77E3bL5FWBFYBN920vLuC2R5Mn9D5Onq1RO7bGLnrui5ubqnyWeHyTiE73kAuIQHObBotM407II4nASP5rRCLZ2d9yX4UTcEea6yactASwtZ0t(j92QU3)aI7K5ni8ueVSB5FkDD3ysuvpHXCxTJag0txselTxg1lRwKyo2C7lHzHDvckTa6MDHqT5KM7iOwATKwvZSwVTavg)D)atdCzBdViEXnZ)S4tUINNRfKK88(HYmshFcyFFiZrfr1igFNSMJmlASSG)O)CxfqlsCiyubKSbZJNtCEq(sHIwp2R01pcJjadVs9k8iKfIhznZBoJ3FQLBa9(U)01zIT5HloJUoXhE5HHeIbfmoQLghoqbfCdqa0erYAzoyEh5aWsawTLtkkBVzf8xuTzkA6lXSkaARQkHpvQUxmwOkRQYnpfRyymLXdGd3tjSO7CU7KOgvicgzmjSVjr8uC2MkqVAtRz0c61ZuIWUKplOLpb2PkhFwGkqBhftcc5G8WISMmq(MYec)dWAWTIJOqpoJExHcDrRy0w9l3zF4WOtB7kq4hfacUuRKJ7Ti0SQbLF0R50iO)bkHdmfUZj8tVbZgtSIoe5UTv0kdG)G6Nw6hWZUyBgyKQSSOKvPbDrMSSHD4ti3ZjtlAxVbK0bo0HSas)cKczIuo9G2vPTz10ElV9FKglDoh9TofcZOZAAXchO(jqK0O)67y4UnYggby5(TagbBaeGv6uFCReYF6ZY6qoEqdg1nvmUKmpQq(AFXl3SN0ySPeojh3KuTGPRg4Wm8lmoYFmcvhgsQXYTnJttSTylIfNXGdRc3xmgvoRpYYWLoCVeU7PN7YSWU8UoD)rGMIzxYWrtMgZ)NPQfXPPuYBpEM5uUmSYUsASyruVb6VjVCEsomanHVXAgnhU7GS6ZzSZCNjELYrAl2NKfJI2rpO3fnte2x8tDkZNZcUbqEnvDKXTcjjNhKxMng1LG5xlRaDrORaXGa3Py51y5MPrB98FJb2Ihk01(9(GD2mjham2Afq2oXo(iV5oqXdmnIkVB(6It10YrJ(Eu5sELbHR7Cw5wsfFvbbsEvM0oWNa0jkkUeET1juczrzJPfJSsOdLs0UztjubrkfWjaHfWDjx)A4mfQl05eDRfrwlOXpizWq0US7qic(LdcGElJGDf7iFwxhMOd1GvtiV3vzPyc7OtDHdlyRYazj90YwmVyfuccretV7MjK2zF4fxySYD2dBC1RBfFTTQasRR5P2pbuXSE6zEAG65QfhTzMsIO73Xlw9RDNHRVvfCT1Wq0a7HCvBiJWI3SnPGm7vP2URFdxdz4dfFi5IUsLWaVmWLaOVRsBkb(59VwKKS8NQ1kiTK(lnsZPAndsv8I5loKlFhyn4H7X5XYmMAP)9LVBRZAP3irbA(udTzMNcz6N5uDNUjzY)K2QcHLNDsRv)jU5xyovjlEctLm9XhiCmebnqhGSC(DoN3ryIYrLnICo8oPbB6YWRr9dznMn5JXFFo6)5MfbuIwuGSDjk(vU8cxlwXnwsnEKKEGwGO3v8UPWCclHrWAThzwjWjQQbfUOhbNJKc(ZLVxHaESF((iJQ2EgL65Guu24PYi4HFnIi(lcm92zN4rWtiZFT6OSOf58DQUgJyEsHiFEVxyKICNkB)cNK9peErLtUH(ru7dINkzt5Yw(rYaFRo7emCXrSqBSKk791kxWb2j)yhXdJknhE4KhewQNIzP17KKkQfy4FpnBPLy8mLlxeHShFOnA6N(0HpIlqecLe3Xp(7AUU)0NCDmBo6OJUUFAbDkdnGiyramvU0by4wyJNzeguldRWYMFvurN3TRunEpNZ9OaM(FR9mZZ6Nl7iTbdUoUr9C9BOj1jq9vRqD6VRqwVC9eCWYevGlat72qEPNtnRlli9KXApGUM3aNA5IMv6FKllXuoSxD(edBnfd9RU85xO9S1RjWnNgXgfYxrs23WXgrYJDjgLO7TPsJr3ZXxBx4NKUsAfpQBO8zXd50pLkPcJCkDV4KjNCXjtU(Q7sQaH7ui8F)6F(h)N)4)ZFB7mEKbZwZIhag1VdyEzFae64FRL627creHsABkxNG1Ihi3KYED82V)hYaDeNshS3uwqNw8Xh0j4()9aMXrQ)Kqwg9rhE6hpsokt2lJYPNBmmCHPYXq83ohGVDSWbOQ9T)0pyoEpFppEVy0lWTFFaIVEBc)3lMGjEycIFXX((ZgnuOokM8qJBuUyVmk7B2rt6ud1nNpqOwBmp9yH2nXa3PTBEAWnArdyAe8XVDtx4Xj7NHz8CXAdJjB4qzJN8Srdht2ldJDMNj7zzztEaLLjUnwoyNKIfpazx(Zq)(Dv7LjbAOFFVTJ78aenlIFTMdgognR6(sBRJbyCWXNlY3cUTdUL0g2wUES8dwHuqGIFD2pm4AmMImzVBerF7zhm6HpqMMJm6bApTdFpTXyx5OTRX(QS1VHYJCFrd0bv(Vyd0p0MSD2ISBZyLCc1k5k4w9Moup9OqwamsWAx1h0BagjCSFSLDVBpY(HvC8M143AMXnmNTFe1F2UUXiOuv5Df3bdsUQjRKS55lbRUFX1IBKJHDUOrZu6DuevFUCmK)GRry0mZ2xw7hM6DLNoix0GTxymMOR5X5oUISBDq8JIkSmg3f899XdfNU3Tuz)OIWCBumyK9YMO4278)XExRp322iX)BXtMYs6xvpIYLEJONPxA)qZD30oX9U7BvMwcYI1uporj7ZD04)2VDbabbiaiGiPBYKMpLyrYflwSyFbGF4OOsBN7W1x7g)b6f(XdjRY8MMRYRWhDJoBlk)KczAI(MIuPjjiwlbAyhPkz80LOQrTUrvRRIjVTzGPrGoIpAKOTBu71itJ4LUzUJgzAeVOLwQ7bzljd0nXXPrMg1R6g3qAKPr8s34mtJmnIx6gJDAKPj8YNk5zXjt3yRAytIOuHaTTIdAeOHDKgyxOEc0q(OBMjpSBu8FDtcIRwc0q(OjUMzeWzcH8D51x)INuOChslmWJO4OYHCOT8jnKovvxo(QjOfNDdir1PYnGeTDASgboEEORIQTnv4XPwVasQE517F5lgYXYfDKVVwYfDte6DJ7VUX5v3erCtdcvw22nXG2nor1kOYXQO0(sP0wv1UQ6hDJAwxzGTjIvfc0e7qkeO5ERE(9)i1Eo(z4zbLTznF(MS08DO56F9AWk(I1B)1RVoD5(m6wt5D07a4R3WoQN)61V6vpFZ)KUR957((3J)Y73Zuzohf0dgGnf(ZVJ5j4VY(RlE(g6bzA3tBsNIippBbmH3zwgDt9J78FXb3wSdBPSOYHI)RNIyLC2eg))1xkipR9EMJ2SiOBGadchuqu3G(GqbpvmRipGhe)hj4XjnJE6sXtPV67gv2cFp7gv9hO7syc)e8)t)qXLC6TKPj0tCZtR3tpEVuuzc55TCodpHd0Z(khY30GjGY267MXikhTi4DJ9YGlWpJBEy8UhNmFoHUR6l3(3iQlqpLqO87DF)hkEP8lvhoYH4)MUJHYRKCgxHne4CFpIi1V7N)xpZrKFXfRYEymcF5e8kv57(5)bncH7LO8)C9dytxSTVZ)gyaFkxLIFu(PRu9Y1Z2NrS0Guvw2GC(LIvY7S4Vrm(UJKLbDPAFR5jltZst2A(LG4H(T9BjSBZR7ilz9atVzrF5C8yUgxfieoF9My8alT7C(g5iEOVKI8WA8EetNc9h5ljGNSzFw2eGuizqIKopoS0GM8LQwqy1dQaEQq4)cmUUDD26TZWFZe2uffD(djz7jX9z)7eswojUNVCkEKVz7D3zsCQ6jc5QyR4nrRA7Y9lFrtZOM3eGBpGDKpOhZe9bTV1xIzeSx1PN3mNX7hzD65ToLPRI4UKCjgO2aV7TlxVBc(uczgTJo52N0j3BpgQ5JWR)rXFU7V(pd34vDBjbH5qMNUYvXh2tEgJ)Ddhn7XpUPrqqq1g6z(kGtD(9GExeo6ulMZ8THmEhXP2oJoBqVtlnUUcHygW9d5WHqZnEGQDVXwn7ffDw)rsKMD3wfuAFxnGLaVTN2MUp3EGQC(TTvoZpYqtkUEnL8sOlz5n8BGgMJ7itO)YP971RtBrMaN3CF7OxOMtmmv9DI5tFJFBR6PgU9sBJnPQNLpdZJ9Luu9YUJCQhsivT0(NgA)6NcMQYZFcNBjo6Ebf)Q05D9WHtQOEefeEIPaPuNng3)WbZbMffCs1iZIoMXwGoq2bQ9wrxDzY0KBHaDZxqGj)lH0pME4G4P3LHNc(Di0BCBYS7iMF0sYSKSmGrKE8SKT3VCn00ZiqmrB2VdgYMsOIsX7azVnD7(DiZo5)Uh6EGc4mYdPkVuv0Hr(r7xrXkXjqhfKk57KE2Jj3JJX5iK4SAM0dMNbVnoccsRDqoggd)NH3itsxIP0A8nMdzVSykMfmodvufPhwJjZa9N81z4y1HdIhTbYAdsQzcPi7vJ0vr)YGTg7g3T4lP0gVPal92vJfPqbKhHC6jIpwkVJ4(sCSjmlQ2K0OhO06O9j1tC5zEIKAeKs1CquDQcYqptB4NQCtWjw4gZmJ4yiR4wqHfKso(mmp29ybtY3azel)7GbbrUT0Cc5gYiROiGhMhwqXrBEm4EjO8Co)MrrsylGLpyuKCRTzDbpB8qKl9Mu4j7XKTBWxUuwUdrUUTGbz8rbuIq(FlsGzuPuWtfZD1kwgD4WTRZZdO32Gt4N39XXVUNcls7f5t(T9ZURym28XXoWYj4oWkefqR6IutDBYD0NVnD695VOnemWt2EpOu5JONzkD((Tp5ZBJ4kg9l85LrxO57WXVPGJcF(cu)mfg1TiFm)YmpE5ttytxNVnbu9XC7XAznNy8tyf)Ac9lR6TZwBlHwgv02O6wxfpAK9bP6yD0HzwkMbBA(stg)RTDhdjWf4gQXPVw4jchI4ZP3cetYtVln7WHIf(TYdUSen3zek6i6ivJjYvp5nE1rEtaAV4QH9mAN3xxBrV0sdTWjzdT1puoYljagvUTMDgA9JI)FpqYZjzoB1RGu1GWxlfufXoIXMgII64Ebw8xP4Nxj61AMPcHgnj9UviAt4bZn0gZzVfUl7PnujxsEE6Y0mHVZpPKdgIb3jpooEeO2ALja9w2mJxGM1Ep3ieSy6xfulSFVlgDQT8EW(W4H9QrdArcWQKzi8Wujcn2WemEjyxtxUYbHAvpPCITjKcBC8ax2U8BMlgfLdcn4Wb1GwQ99P5e(8nJU8nCG5JENjTHqMjbEwxxMn1Z38b61LfKOWVHlsuMzhKIzQYjHrdzuiyvWu2ZczePI4tgeMoTAcYIVrcxOm)bI0NJoJ)j6Iy5VCCLBs1VcepG9EbRlTUd0YX5ixRILomc0nvj8vduRpcicxrECo4Fzgm8rZg8CuMsVSSNWrtN4(2dXOMaiGhQbKDiCxJdQv4bmEl(cIobxpx2WPYQU9ExVnEUOpNTCGmgwljgllOKEXr8VcKUzRQCL3Ko4KJyG2nFWZ)2SeYrs7UPELswj3iMuIT7yYNEDXcB7MT8ND60MTCbXKB5oTjkaFdZ9TY1kSR7AsRcPRwU)X1YLLsaMjeRuYgNvRG7VbnfnXiUutZWM5IVgePMM3QbykS555g5Htwyik0g(ZnUI9HkfzgIlWybFldoWC8m3nDw9HhCvPxttRCKCPvS0YnJQoc1a47OifffEo(LLGl8paLfObzJ9BkV6RfkSOSXbpWc6tVJiWNCvLEfOo3HeEOp5w)fnUwQX1(bkCiim09q1vYP3PVuXb2ggJn8abEFgrdI0vtdSydvsG4oTyTutuYjEb(o6iUTkH9OWFlKVetg7zHjKIgO6MJ5m5a0DLmLV0XV0boNcYLsvmqvyjS1PjPmekln9c5kUzhK6zItD4JD8WQmI70USeRTKbtXIeuL4AYMwsp5rSAivOjAD4G0VQXyAAZMxfg76V(OIkp2zw5tQ6A1YhoiZB9IDE7NGUog1uVdEuDdJoauwGRII7ArVsBsQKgL(4uBAPMoU4Eyp2PoicP4TG1)IVsd(kpxgdNzmPSqtM5v(DbVFUbGEw3RIBJ5LZqRuRrmoz3chQ2bYvEOeHVwvguPvv4h7nPIZ7xmdpoJUSrwLCsv3Irnlw2LHgPrfXNhZa(CBYxvbyznFDk9(ZQ9QJ3WstdLqjSmfv7O)mozp4KqX(3ImhVREFGmjzv6YKjjtNsYyOOOKVxwwkPtPPiOnUzma8JiRmps1yC8OEDDZs1LQRjh0KOymYvFrV1nvDlQ7A9w5gIok5HHWpZSb3XsuLgqSiGgAwVe1dS3H)yloTUX8yCE)b1UsNDTIS6TJOP4nwV9wbZn6WHtul8d8uNJKTGFdSMpaFUTYvIMRarBdJy1o8v4UsWToJkR6NJW2WV2S(7Yswh1MA9hlTR4QbxT6vQ013lGoRLX0Rwj0MidSjiE0a1hv3UAuVwoLZz6KERwTs50xUc3usPFFfzQ8T(Sbn5n0Mkx5GIwsA7QSFtDu0(ZeZxOpVAlvAQ(uE9T5Db9BirPWCi5RPBZWQBU)xhPTPihHB(rTi)Uf3V5BNHb5D4aFJUSGKKTBbDlGpCKTXArb0niE(OYF573q2IRRKngNDYQeSUrlFHQm3f9J0dAwI1c04SXd1kOS)TFTEYRFUNvs2ZP)z0hO)B2an5(kcOPdr8rwUHuSmYK5GgWcmOb0)kBFlf1SayAHjbB9Hs90KLBYsNNYk1AvD13AsxTfSJpT5R9XEV1q1AGC0lcx7aKStsvvD1dWws1cBlxGw57ypBvELrUFzbbXUcvuLa0NjiKsqHEc4ZxZ3lKjZMHyGb(3HlwVHmFFw2tr4Rmfgtq6abfKonfmi)0LQSRCdicbUy7GPHKbfGtqQ1njLPvidc9TuhvUm0YNtqLdgtKDM8mpaCb3SP8iTuok1Acj4LSxyd6g02xL(RWEcptSmcZp9wcjhDFv54dfgIALFLjVYtxNVlYP)AE38hsrdKq395BO6FiWRaSbQQUOasAquwlLE1mt)CbQXGxT2pFZFR0JZri5qjooXyMW1JIauweTqE9)VkgDjeE0(9oMrvuwnjzd9uRkW7cPZdTUAigEHqNv6ZXnaoDbYIn90Z6pQa1syjuHCOadDyNFYNV5oWeCoDaQGgWFSKUhvzqt0STNJ3DN7uVCTXb0meUFb)Eqgfypfgsbj(LCq0lpD5u6UV(H0z4Wnx1cn6sMsbJj4)TfHEh8lNTgzckeb94AiVgOTWMAoQBSPGvfaXd1(gmTihHhOvj72tbDOInboWX1yptxvH1bavfqSvmxxvDXsueZ2VLsZtd7FryVl7n0ckaar)V6(OOOlOhUIlmnwDm6pk7hDLJTFnqHrTgXkhuApxCsZzdwR)FyAz06PXUnWX75wCyFqVCYuUsb9EFVfClyrSklzn7fACDUFTYbwLwlACbUECn46LuCUeWZWqoqj6ujQyamqc9t25XI3l)7mayqm1lhJNuAoWUhH)hKjf1S50NMItEPTl(fWCBKqa5xag3X7z817X)f1gztxkMz1jYXItsw11Rr7OKzxxnOM5pJhfy9qZh4Be8M0WOAsg1XaDp)LmlGojYp6aXsTAo4kHBwVrO28bwTda9hAjFKTvkIre9SUbTrt7hOQHsngkUHXrClf(QDymKiuPHOBwkgfi4dI1)X9DkKkjsKeMjF02Q4UQ)3jBxJELRqDEu2ElSqiEdn7nJxopvRT2lDJTk3i9KHvxFeEKkvppjGKohNpoMV5bo91m()N2MEhg2vbq9nDbHfVIhvYH65G7SKj)WXkk25X9QrVp)LdppzdKreoE(HR)3ma)diEwDbK)rvy6Pq4i4EthBn7bRjfwopq2vvxsHA3x9sasqfX2lqxJoROW0JAFQM0ZpYdSNuUmv3bPr0thXRWG9OyPy6VteiWiBlhdAC09CCrW2jBUKJpIOnc2VHg0a3fyC8pMMJWtOOZxmEf3bBSzN7aD0sPpRF6FCBFqNlL5hTfinYWG0zTD)NthamamgLOhKj0Y4Q4)spCHY8iaQR6)XAH(I7vZsJw2tuwZ3kqkvns8VCCK(Y0tVMEQCGK(dqBP2ZJeZZrs6wexB)LcVby(yPZr)dia8cuI6nbJ6mFncJV38JZlCEGXyFl1Jdg(e7ZXGTphJ(eH4x81YPwmqpr3I9wIzjJfukYCP38qxDC83Er4Wtb)XtUD9Q95q8GKTdE7KxVzAKR96t)Ew)0JH5TW70rlLDL7(nFQ1HubhmXecZaqqtWoSiQU33rr0lE9MkxSnLyvqTnwaky(0uf(NPyznw)iqrBzY9yTOOfictVPuXJRUr)AtX0Cw1TUzB02KpvrwgeEJp8GfwO(tZIDY9zONEHfVxkV8VQaaXzjJNkuaPGCEcyimHwnYvyHi5)6Jm8tNAmCdV4czRxDhwzCipXIucxI3O1uVjmnxQPvMUlwnhCXkyPINrOQX0Q)W6NuiKhDNYBrw2Nmg7XewkOmCvhTgBrFVb7x(s3HgbIzF9LAaMKdSajLoIlqEniK8fB8LRP93UgDLBm(a7RL7vdCK8PnDpZHQPPRvy3ROocBwNNNIS)lSDWgOxOEqaAsyH1BVm84pCKwCM1Ud4WlQrsfdrFQSft7aJOwgj8yB)BXh8HdMcBY(e1MR3PSV)k7U11BTjSmleuo8BTiIJcihsqpL5cN1FOTPdY8jYdAXfoyZ0aTDxVLKn9Ht9)4sFv)EMzAZ73sVyC5YJk3178g6i0Rm32YFh2S(T)mDY9HNyI)LH5zEpqDRQ9z60V2kIAsxUrL)qrqyEbKCuQIpDeaMRdJ)rVzO7HXV1LIfnZInuKizB0d3WsbOA8cFWzXMCuSQMfcHtJ0Ey23QPC9JWqT1xOmg5)F7DT3BBCCe)ZIqbuiRvDiPEuBurby76I2I6gJ4cK)lk8XjXdHINkFyfbeOp7DNz237SpUt0okUg(FOPoU3UZo7883m7Tn3qM2U5)URQcY0XeetrBxpr8XPeeJq3Swj(s7lmQ7Qxj(WrqMZxwTryZmL4f8PxbEYTeXEYA0DmL7wKscdKuw0ChyL9kiB77wDnCdrTwL3wLRIB4xYC4VMvMqiJu62pzqzrN7T(OG4T0Gd58tbkuxqC73NClFQXSmlAXB4fnwcvA9NZmDntyRgwM3swpDdXbBydAXmmpZfM5zEefktXda)aYOkOdRqE0kjO7qU9p8bcHD)NFaIBW1vRMlopjMKumfUdzqbg43(XglNbHFjeR2VfI3lDaXoZGGNLq8EPp99nVhIoH4tqfvUzb2so3HxWCFZhr3xRq0KbFLkmfwRoNUSQJ9Vw4WZbdLoi0ZX04inUEWJRi2b4uALUu3(z0cJ0EWZB560B17lHrfBggYXr677omhT4ErdEh9b3uF3VDbTVUCtvmcNVRdDWOI0Y1JPglMRGjqgD0vqRsac(ItKfm7cDj8nvuMq1gy(Yttmwmh)ndO8pQsVVnrCHtJNI7Vyu52lw68ITNjKW1pDThYjlYBL5hTycCwxl0qRgSL1ZwKyacmBI)yBEIRSspIYadX7k7Gy1)RIpmXTGnLnrjE58P)HGT7PpR3WCzEjyaZ0l6Xr(S9CtFpZwRTKqfEXWOzJeNneAdFZBuHdxgmBmQ0u2bXmmEF12JmWlMOROUjqwckZ8MDRMrYcv2QPv6HQS(7kmLR00vaxrbQTpm87Tmt257TTsoweay71aaRNr7va(1tDqhP()BXinbrypqEVfZBlDXKijPQ83QaOMjjTO5gycjmGefZrXueRFiLf1XJ7Eglc2eBBiInhj2lmxHkherNFIOp0JxPF38UPFkMExbIT3IIuNN8Jd9ED05fcLW85EN9SrXAC9C2Cg54N68mW0OmUKaClc20D3C7dC1gs(fK9PahVedp5W76qpLY9Z7ncedpiOTT3xgxR2DUpf7J72vjt72Y9Y6JyX6s4I5E7zdJ3SsSR96Hw1p7HroANIwYgOQNQtwFU10XUvfsJ338U4H0qvipVMKERIpbNNBmIP1xa3Zw0itFO9xjVIfqFiQMl9vu8NLkSLtnqJIoQkrFNWpvxvJYh(vVtFNNFeHjDvboG54wyKzkDfmHh4G2vc85JMHobk22o6ERnGJq8sAVV2OiKyTqMf(PvvRuw9eSPzfmk7ITQEBX8b69dHcBhN3Bh9KtmsQOTSxix5o(OTFp8(HqfwXt1(8KTJlCXaspwLDuqSZtUbZfkJIO47HMgH0ybhx96kBtIoc9yFLexiq9WbWKtOIa2lXC7ileoCFhSntSpbhar40rHACQqcmg(MgSi3K1Wlu5fslWWWdaVGIS6k1wFOcPeMzAUa86DYaEnMDuPvCt7IeoNdJALyy3uyHU0FehsK2v8tBwiu1nxwfngqkQRZLQvYRvgfEhFRgxv(iSy(6MBVf3f0qWHmRM4LWZU4N0i(XSVUyTSKSm8eipwB2XIFu1BluEs1b4S2bf1etRaY0eju8akfsFiHnZce5ye)dKgLinGAio4V1eBrnPIcgwRxVbMZfj8iPezbeIeSl5Ms2(nMsvdJMjkyow9peYif4nAFJ52pRAQlCL6Yg0DvCEosyT6Y7Ve)FxY5R7LsnYrXpoC18OZvheEsPjRSXw15Ee0l279733pIbsNKpYRM2q1FqGdiepnBceqd6ievSWIPEfwiJZGWpVgsceelHwT7XJMH2z2pUE(W2jR3QlXgyAdg6qt9xPIrULbaTAwg(YPytKoQTX2A42DljKGYFsMoVsIS9MFSD7YoHtDDuzhMkQSordpIFbrKA0(2Zr2LKv6AaR7xTz3TcLwyzWpd6vqQBmN)IJMgdg6XICNcVZ01n)SYcdiKS14Rwc70BQ26v6Gs5zJDEnanrk6WC0uE8xm)TWXfe5B5j1LGyDyArMbHMIysel9(nfeG4K81Gblleh4LpS4vzivY5L)oL2gJXhBDxpXdT8oKJJZhoOpJzFYynQK9tXJq1jdqzqGTadpZeqZfyxxb9scwLZOB1llBdPk1Ez1vBjIMsThqI1G0f2XOJ4KA0Rqad(CoQeJebtCVWzLs1f1tiGvAI0nm8Sd963tU3GOKzZ23RywgJXTDyj8qhDiPGW3kVGqHIRvEdHQSDamNU6oTZmQvhi0ejk3nPMUm)mewynzzP2gsMRU7pGnYKcjGXVr8v3nJwwk5)igOmC2lo8a1PPGNAE9gGMnNBkvy0x8nUZ7U5dQGJUn6LeU59cY9e(h64l4OWlyq(1qqur)TCkBLsLWRT)eTUGlgd9uMI7pcxmC4agYt)2mgERugog74CBO3SrvttZ9lz6meqxSs)LpXZMkKpkFmm7(zlTeM9cALQXach0yR7fPFT4CbbJE)D5M7xnZiVVS2KQ)ziw6wBoKNhVUDLz2SETBLhMOXocRVhKizsqbQ1(vV)zF)39Ev4Ba7YEnC1XVeR3gQSG2QlANrGJbBixwMXRwiIpVm2zxqUakWtzVVCHxdX6SurtW1bu5u(5Hv)XuffbZhHdnfdBqT0fP40qBcxrNEsA0V985Wi31Vxaxj3PpODXWr9DDv2N6DA0SiDb4HFNp)XFsILge4GZJEbVFN0T44FHnUzJxQYao0vmgFAMQNv35SG7V9hfDjmLQQoNL0deQ8UWwh12nvlVIoZiSZuftXjcNhw9GvN7WgmZLkv0HF48thet3bUA7Sg9uQpLHwiQC6OXCiLSW8VVstBW4JtFlph64K1E78MAD46FvZB1qdEJGswr(fDFZoLJ)42U2NuLNNANj3ubezZyyWlJQVFPEcT2k9V9QMDR3UOmLpftzg1bkJVVIeecQNr5HurpMBI3NYLDbbdWETo9xQLOto18soMmE1QuZq(VFJmQ0qo1AGhMMHSrrrqFapspsqyhp45doPvKNHCyIeMyTLSD0YAGfF(4rNg6SDab0JgOcPVjPhcXyBXG00yNfyvVX121BeRy(mC3veNDkwnDA9kNsAcB)c56TGlGDogWOZkNMdClMzFIMbXAwxT)99)th56vWtQ1r42WZtYxn05i4EviAbpyjA10hQIPhv4qCbVkdujYoZpVGh0dCeOpaqb7zXmnTA7DygsClFMnet0UvO5oV(Fr240aazelPjKb0VtjwpVcJzEr7qL6TueFiY5qUxhViWjldbbUfw09pcfkAGQ(ho643XDYBytu7LooMTDdhuuXPDkwTBCM5LY8UssPfNlQoHxMsCO0qhY)FHAm4kobBMWs5rKZJsG04IKJfuEd1gl1GXug0PTgHb7uwzBRBU9BX2VaLJ7hlBvK8s76snFHuXrH6i4lIYvs)fC0VurC1VMa)5FsSL4cMmkwcOv0QxckweKLSQEBnLpn9le(Wv8fPuCXRenYhvtqmf6KFkW1rrPK9(W1hv09CP4MGPM0ofsamMFRPvY(cdzbiwiLQeB5a)mH3EZ(zmfK7Qbti1G4qxCKaAEVARS2ZUxsxbu(IG69E5EM2LMay(AOZ5aLwXuu(JkU6ZDt9vGVB)JvkBAR3UJ61NhzsVF9g7I3AUQWTWgMjyYSWX41ARAEKcgtASNJlcoslzN)6ZtqWjD57)P1vxpz9CsZdWt47eA5s(AT4OIxIgfMm(SaaTq6Ycr)RdPbEE(Gm1iBS)QvgoL3PsozHMS3n212T()sin2rvaD(WZ0Gxsd8c7pF51lBMozPncm2)mKXJgj3BLhmddjh1)oJcjQgFLyb0vAATut6KLsugs6j30aOhLG4KZf1xgLtml4UgdnXs4VHrMsgFXBsBFQSyVq8D5cEKYymoisyQrJP102Jh0VyUK)aEXxCLeIb4Iyjv4(cbby1QqTkF0wKJi40sfb1nqRIh9hMdsW4HpcspoTcayoScU39c7gaZOgWURfliRXviMILmiin00toLrBjl10ujTS)vtp(08Njmln(twn4QXe1JO2BlSUvy(bw9pYW)yqgi0V8tgW94(zzXhaHm)MWcWI5H2e08lcnEbD)mzojygy5J5xfTE)69q1VgflFTSAijpmFXjmJCIuPZwVnLSbYtMF4RvIJtL481kWPK9)8vGZt3kV5Zsf3O6RVV22bKTbvDXDmfyQIuNQoVZv6aS0wo5OqlKj1njtrRefNG504NQ1vRcDzIsIiFfr81kHy)wjeLqxdMJ2UUuyhiORVPpd1zWNI6lyVuxb)2wpbzQJa1JTUzlo16oi)BvVD0IZZ575YUtLQwfz9dKVicMmfZRd6BCf6k5)0FLYkgSLnIZiYa5HiCC7uoobOKIYLY30hJKpMWrXPl(vi1PfDSWKR6K3dpjwXTbSWpQo75VxiiDP8vkcxVFzWV0re7LAX39UcAPeTsnfUKh0Q(O51RWPD12uUun9UmwbME9(KhBbfm3XXJlXDpoNwZ5mwQ52Nd7O7LBjuIH0whcdOGYHbEe3MdWtvRVfwQ8gX(Xoi66KVB)YTcZsGOdCBZwOfpavUgmYqALMiVNqXqbVSH68S6NIQd5c3Idw42OFqnjUup6ppTDqLmYrOLrOA7dofgt972up87Z6)JtoqvUQVDTmL)tXBbxijUyYUuSipy6TzyxsJArvIL(nAuSD)34zKQyVQEDXNSlFfAcXtVil))yjBbpt2kCtVxSQcsy9Lq30OIKq2BD1vIt3laj8WDHs9m4gPPR94dEvyPVWusrs3hEiAnQB2DB1Avoj0)u26o2uIY2PMiNQMWRC)yt9log5y)RiN3m)ScE1eQMWrhPOSXkE9vRHO1ktg1cyxRzPvzxB36sKnJgeGzkM(YmUj2nGvAYv3yxC1Xj2Sd8FGkUdRaxzTVmizhoPOf7xeR1ZpEqmEjeLHMwztzeLFFT6Bvqnma18fKrbbWCwHC(RHyYi7fdkBgSb7SoSVw5GPmYlN65eXNgPfDJO3lov7x)1yraEFrxSdhElim7RaC)0HILMmzNoQhKx6M0rw04ZDwxRMifvDL1xofTiAxA10f5uuNP6wL3cssK1jaseQXmWH25aORyfM)fjEKIwObGNq6kQZGaUnpy1o7XYFWfLhAjNG5ElWoGpOdv6xL2YqRT6MBeJ(Cmp)wjZbNuQQMRWDQ44pkUfeJ96ThqPn4(nxiBpUEUmMAo5aUTomRAfU3A)0ZdTlwpGtO7tQcRGTeBiZ8Xjn0v5U(0c8gWwhYF29PcSBn9d5qQJ8O7s3gWTQ1SqewSV7o4YPKdHUGqNxWTuwUWgNBeojCwMOHSFwjb8F8lpm08bBNZtSx2jPGmVoLl4JgC4bs5Vm4Oj(KYVM7y)XutWz4XpIbrnphp8LfqAdErbNTIO2k)q3Mw)ItVOrotyRAAKNz8WJZXKYhaWSJ8XdkODx4ULOjuL17r(CYPEIMtnNZ(r4Ykzt(fztGYl7MLi(vmWz)jUBUHro3CdURd7ya5nyVm6G9Om8QKa01XOY6tnkzrhmKuGVYOOm6U1GChIpnkhLX4k8CwxVmQlqSJmKRSEAo6uo)qluEMqSZWOSAfDqUqeD2HronrlARy)h3k(3p()(]] )


end