-- MageArcane.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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

                return app + floor( t - app )
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
            duration = 8,
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
    -- actions.precombat+=/variable,name=aoe_target_count,op=reset,default=3
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

    -- actions.precombat+=/variable,name=have_opened,op=set,if=active_enemies>=variable.aoe_target_count,value=1,value_else=0
    -- actions.calculations=variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&prev_gcd.1.evocation&!(runeforge.siphon_storm|runeforge.temporal_warp)
    -- actions.calculations+=/variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&buff.arcane_power.down&cooldown.arcane_power.remains&(runeforge.siphon_storm|runeforge.temporal_warp)
    spec:RegisterVariable( "have_opened", function ()
        if active_enemies >= variable.aoe_target_count then
            return 1
        elseif prev_gcd[1].evocation and not ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            return 1
        elseif buff.arcane_power.down and cooldown.arcane_power.remains > 0 and ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            return 1
        end

        return 0
    end )

    -- actions.precombat+=/variable,name=final_burn,op=set,value=0   
    -- actions.calculations+=/variable,name=final_burn,op=set,value=1,if=buff.arcane_charge.stack=buff.arcane_charge.max_stack&!buff.rule_of_threes.up&fight_remains<=((mana%action.arcane_blast.cost)*action.arcane_blast.execute_time)
    spec:RegisterVariable( "final_burn", function ()
        if buff.arcane_charge.stack == buff.arcane_charge.max_stack and not buff.rule_of_threes.up and fight_remains <= ( ( mana.percent * action.arcane_blast.execute_time ) ) then
            return 1
        end

        return 0
    end )

    
    -- actions.precombat+=/variable,name=harmony_stack_time,op=reset,default=9
    spec:RegisterVariable( "harmony_stack_time", function ()
        return 9
    end )

    -- actions.precombat+=/variable,name=always_sync_cooldowns,op=reset,default=0
    spec:RegisterVariable( "always_sync_cooldowns", function ()
        return 0
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

    -- actions.precombat+=/variable,name=fishing_opener,op=set,value=1*(equipped.empyreal_ordnance|(talent.rune_of_power&(talent.arcane_echo|!covenant.kyrian)&(!covenant.necrolord|active_enemies=1|runeforge.siphon_storm)&!covenant.venthyr))
    spec:RegisterVariable( "fishing_opener", function ()
        if equipped.empyreal_ordnance or ( talent.rune_of_power.enabled and ( talent.arcane_echo.enabled or not covenant.kyrian ) and ( not covenant.necrolord or active_enemies == 1 or runeforge.siphon_storm.enabled ) and not covenant.venthyr ) then
            return 1
        end

        return 0
    end )

    -- actions.precombat+=/variable,name=ap_on_use,op=set,value=equipped.macabre_sheet_music|equipped.gladiators_badge|equipped.gladiators_medallion|equipped.darkmoon_deck_putrescence|equipped.inscrutable_quantum_device|equipped.soulletting_ruby|equipped.sunblood_amethyst|equipped.wakeners_frond|equipped.flame_of_battle
    spec:RegisterVariable( "ap_on_use", function ()
        return equipped.macabre_sheet_music or equipped.gladiators_badge or equipped.gladiators_medallion or equipped.darkmoon_deck_putrescence or equipped.inscrutable_quantum_device or equipped.soulletting_ruby or equipped.sunblood_amethyst or equipped.wakeners_frond or equipped.flame_of_battle
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
        return ( prev_gcd[1].radiant_spark or prev_gcd[2].radiant_spark or prev_gcd[3].radiant_spark ) and action.radiant_spark.lastCast < gcd.max * 4
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

    -- actions.calculations+=/variable,name=stack_harmony,op=set,value=runeforge.arcane_harmony&((covenant.kyrian&cooldown.radiant_spark.remains<variable.harmony_stack_time))
    spec:RegisterVariable( "stack_harmony", function ()
        return runeforge.arcane_harmony.enabled and ( covenant.kyrian and cooldown.radiant_spark.remains < variable.harmony_stack_time )
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

            x:RegisterHook( "reset_precast", function ()
                if now - __last_arcane < 10 then applyBuff( "disciplinary_command_arcane", 10 - ( now - __last_arcane ) ) end
                if now - __last_fire   < 10 then applyBuff( "disciplinary_command_fire",   10 - ( now - __last_fire ) ) end
                if now - __last_frost  < 10 then applyBuff( "disciplinary_command_frost",  10 - ( now - __last_frost ) ) end
        
                if now - __last_disciplinary_command < 30 then
                    setCooldown( "buff_disciplinary_command", 30 - ( now - __last_disciplinary_command ) )
                end
            end )

            x:RegisterStateFunction( "update_disciplinary_command", function( elem )
                if not legendary.disciplinary_command.enabled or cooldown.buff_disciplinary_command.remains > 0 then return end

                if elem == "arcane" then applyBuff( "disciplinary_command_arcane" ) end
                if elem == "fire"   then applyBuff( "disciplinary_command_fire" ) end
                if elem == "frost"  then applyBuff( "disciplinary_command_frost" ) end
        
                if cooldown.buff_disciplinary_command.remains == 0 and buff.disciplinary_command_arcane.up and buff.disciplinary_command_fire.up and buff.disciplinary_command_frost.up then
                    applyBuff( "disciplinary_command" )
                    setCooldown( "buff_disciplinary_command", 30 )
                end
            end )
        
            x:RegisterHook( "runHandler", function( action )
                local a = class.abilities[ action ]
        
                if a then
                    update_disciplinary_command( a.discipline or state.spec.key )
                end
            end )

            x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
                if sourceGUID == GUID then
                    if subtype == "SPELL_CAST_SUCCESS" then
                        local ability = class.abilities[ spellID ]
        
                        if ability then
                            if ability.discipline == "frost" then
                                __last_frost  = GetTime()
                            elseif ability.discipline == "fire" then
                                __last_fire   = GetTime()
                            else
                                __last_arcane = GetTime()
                            end
                        end
                    elseif subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.disciplinary_command.id then
                        __last_disciplinary_command = GetTime()
                    end
                end
            end )

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

        f = CreateFrame("Frame"),
        fRegistered = false,

        reset = setfenv( function ()
            if talent.incanters_flow.enabled then
                if not incanters_flow.fRegistered then
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

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_CAST_SUCCESS" then
                if spellID == 12042 then
                    burn_info.__start = GetTime()
                    Hekili:Print( "Burn phase started." )
                elseif spellID == 12051 and burn_info.__start > 0 then
                    burn_info.__average = burn_info.__average * burn_info.__n
                    burn_info.__average = burn_info.__average + ( query_time - burn_info.__start )
                    burn_info.__n = burn_info.__n + 1

                    burn_info.__average = burn_info.__average / burn_info.__n
                    burn_info.__start = 0
                    Hekili:Print( "Burn phase ended." )
                end
            
            elseif subtype == "SPELL_AURA_REMOVED" and ( spellID == 276743 or spellID == 263725 ) then
                -- Clearcasting was consumed.
                clearcasting_consumed = GetTime()
            end
        end
    end )


    spec:RegisterVariable( "have_opened", function ()
        local val = 0
        
        if active_enemies > 2 then
            val = 1
        end

        -- actions.calculations=variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&prev_gcd.1.evocation&!(runeforge.siphon_storm|runeforge.temporal_warp)
        if val == 0 and prev_gcd[1].evocation and not ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            val = 1
        end
        
        -- actions.calculations+=/variable,name=have_opened,op=set,value=1,if=variable.have_opened=0&buff.arcane_power.down&cooldown.arcane_power.remains&(runeforge.siphon_storm|runeforge.temporal_warp)
        if val == 0 and buff.arcane_power.down and cooldown.arcane_power.remains > 0 and ( runeforge.siphon_storm.enabled or runeforge.temporal_warp.enabled ) then
            val = 1
        end

        return val
    end )


    spec:RegisterStateExpr( "tick_reduction", function ()
        return action.shifting_power.cdr / 4
    end )

    spec:RegisterStateExpr( "full_reduction", function ()
        return action.shifting_power.cdr
    end )


    local abs = math.abs

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

        fake_mana_gem = nil

        incanters_flow.reset()
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

                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end                
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
                if azerite.equipoise.enabled and mana.pct < 70 then return ( mana.modmax * mult ) - 190 end
                return mana.modmax * mult
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

                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
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
                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
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
            gcd = "spell",
            
            spend = 0.18,
            spendType = "mana",
            
            startsCombat = false,
            texture = 134132,
            
            usable = function ()
                if GetItemCount( 36799 ) ~= 0 or fake_mana_gem then return false, "already has a mana_gem" end
                return true
            end,

            handler = function ()
                fake_mana_gem = true
            end,
        },


        mana_gem = {
            -- name = "|cff00ccff[Mana Gem]|r",
            known = function ()
                return IsUsableItem( 36799 ) or state.fake_mana_gem
            end,
            cast = 0,
            cooldown = 120,
            gcd = "off",
    
            startsCombat = false,
            texture = 134132,

            item = 36799,
            bagItem = true,
    
            usable = function ()
                if GetItemCount( 36799 ) == 0 and not fake_mana_gem then return false, "requires mana_gem in bags" end
                return true
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
                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
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
                if debuff.radiant_spark.up then
                    if debuff.radiant_spark_vulnerability.stack > 3 then removeDebuff( "target", "radiant_spark_vulnerability" )
                    else addStack( "radiant_spark_vulnerability", nil, 1 ) end
                end
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
                    max_stack = 4
                }
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


    spec:RegisterPack( "Arcane", 20211113, [[de1rbhqivj5rsf5suOcWMijFcbgfc1PqiRsQOYRuLYSOqUffQk7cv)cbzyuOCmsOLjvWZib10ibQRrcyBuOsFtvQW4OqvoNuHQ1rcY7OqfqnpvjUhqTpsQCqPczHKO8qvj1ePqfYfjbsBKcvG8rkubnskuH6KQsfTsskVKcvazMQsv3uQqzNKO6NKaHHkvuwQQujpvvmveuxvvQuBLcvG6RuOIgljvTxK8xsnyLomXIrQhJYKbCzOnlLptjJMsDAqRMcvvVgiMTIUnI2nv)wy4u0XLkQA5IEUctxLRRQ2of8DPQXtICEPsRNeiA(aP9lzkfPim1dGCiLY7GX6GIkQOIkmxrJPOXtrfm1Z11ePEmfgiIfs94cjs90rjtCK6Xu6odbGIWupJ4NmK6X(oZHcriczbp7pnNfKeAaj)t5GHZsPDeAajzeI6H(dN370POPEaKdPuEhmwhuurfvuH5kAmfFhk(oOEgMiJs5g3oq9ydbaqNIM6bahmQNoMyH12rjtCSut5HbKKgZAvuHnQ2oySoOyPwP2RTf3chkuPMXxTV7bw711eYKzTpqYxxRT4atOBvB0QLzlUJZAH(Hz(npy41c9XHcqTrRwcyIZWPwyhmCc4LAgF1(ABXTWALKjoQHEd6WRBTxuRKmXrTTKKH3TwIHxToAaZA7r)QDcnG1kJALKjoQTLKm8UeXl1m(Q14OWj4Qvb1qWKdRf612rkiuqR14)pUAPrM8hyTDJpbjwB8VAJwTP4wyTIduRhxT)b0TQTJsM4yTkOkzoJbmCEPMXxTDeGX)FC1AMWiHx3AVO2)aRTJsM4yTDw0JjbJAXwdzh0awllIjq071sldeO2WR91gh9UQfBnKDdEPMXxTV7bw74si7Q1mdgogq3Q2lQnrGpdR91D27U2dsI1c8XAVO2V7idhdj7wBh1zVV2wKGm4LAgF12XcdiqTgKek0tCqiMmz)PCWWh1ErTV)l1sga)jw7f1MiWNH1(6o7Dx7bjro1ZeoUbfHPESLKm8UueMs5ksryQh0f6jcqPmQhHDWWPEqdbtoy4upa4GLqZdgo1Z7Sv7m6Rn8AjfxQvCGAzrmbIEFuRKyTSGe6w1(nnQwROwXgfGAfhOw0qq9Ws4HjuOEifx4MSR2xaxRcBSAvvRbjHc9e5X)gqauhnnlIjq07JAvvlX1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAFPwfnwTerDukVdueM6bDHEIaukJ6bahSeAEWWPEmoXA7f)Q9IAhNWaPwBjjdVBTT)C2LxlHTXA)dS2OvRIg3AhNWazuRnMyTWrTxuRWyX3VABrw7zJ1Eqgi1oX2vB41E2yTmBXDCwR4a1E2yTKWXaoXAHETTj0Y(4upSeEycfQhIR1GKqHEI8Xjmq02ssgE3Abf0Apijw7l1QOXQLOAvvl9V14sYeh12ssgEx(4egi1(sTkACPEy2c0PEuK6ryhmCQhjzIJAs4yaN4G6OuUctryQh0f6jcqPmQhHDWWPEKKjoQjHJbCIdQhaCWsO5bdN6X40g9A)dOBvRckPz3eLzTkisaxCgAuTmzC1k12W(ArLUuQLeogWjoQT3goXA7f4bDRABrw7zJ1s)BTALR2ZgRDCsE1gTApBS2g0Y(OEyj8WekupyN)dnnraosA2nrzQJeWfNH1QQ2dsI1(sTkSXQvvTxyznrolIjq07JAvvllIjq07CK0SBIYuhjGlod5jskqFuR6QvrJRXRwv1(QAf2bdNJKMDtuM6ibCXzihaoe6jcqDukxbtryQh0f6jcqPmQhHDWWPEgXFoX7GULo)0DPEyj8Wekup0)wJljtCuBg9yY)M1QQ2tsl84aWXjodR9fW1QOXOECHePEgXFoX7GULo)0DPokLRaueM6bDHEIaukJ6ryhmCQNr8Nt8oOBPZpDxQhwcpmHc1JbjHc9e5iPz0JjcOPLmflSwv1YIyce9o)IpZwhn9zJAsXcYtKuG(O2xaxlQeY(hQpijwRQAzrmbIENljtCuBg9yYtKuG(O2xaxlX1IkHS)H6dsI125QTd1suTQQ9K0cpoaCCIZWAvxTkAmQhxirQNr8Nt8oOBPZpDxQJs5gxkct9GUqprakLr9Ws4HjuOEmijuONihjnJEmranTKPyH1QQwwetGO35x8z26OPpButkwqEIKc0h1(c4ArLq2)q9bjXAvvllIjq07CjzIJAZOhtEIKc0h1(c4AjUwujK9puFqsS2oxTDOwIQvvTex7RQf78FOPjcWhXFoX7GULo)0DRfuqRLfoWhECjzIJAZmaGwD5P4GuR6axRculOGwlX1YIyce9oFe)5eVd6w68t3LNiPa9rTQRwfv0y1QQ2tsl84aWXjodRvD1QOXQLOAbf0AjUwwetGO35J4pN4Dq3sNF6U8ejfOpQ9fW1IkHS)H6dsI1QQ2tsl84aWXjodR9fW1QOXQLOAjI6ryhmCQNuaGIF6HPKGqDuk)DqryQh0f6jcqPmQhwcpmHc1JbjHc9e5g))XP)deqpmLeKAvvllIjq07CjzIJAZOhtEIKc0h1(c4ArLq2)q9bjXAvvlX1(QAXo)hAAIa8r8Nt8oOBPZpD3Abf0AzHd8HhxsM4O2mdaOvxEkoi1QoW1Qa1ckO1sCTSiMarVZhXFoX7GULo)0D5jskqFuR6QvrfnwTQQ9K0cpoaCCIZWAvxTkASAjQwqbTwIRLfXei6D(i(ZjEh0T05NUlprsb6JAFbCTOsi7FO(GKyTQQ9K0cpoaCCIZWAFbCTkASAjQwIOEe2bdN65IpZwhn9zJAsXcsDuk34rryQh0f6jcqPmQhwcpmHc1JzIg0wmaUI8l(mBD00NnQjfli1JWoy4upsYeh1MrpMuhLY74ueM6bDHEIaukJ6HLWdtOq9yqsOqprosAg9yIaAAjtXcRvvTSiMarVZtbak(PhMsccprsb6JAFbCTOsi7FO(GKyTQQ1GKqHEI8dsI6VFWPwmRvDGRTdgRwv1sCTVQww4aF4XLKjoQnZaaA1LJUqprGAbf0AFvTgKek0tKlZEP7qp66mnlIjq07JAbf0AzrmbIENFXNzRJM(SrnPyb5jskqFu7lGRL4ArLq2)q9bjXA7C12HAjQwIOEe2bdN6j)oQJM2m6XK6OuUIgJIWupOl0teGszupSeEycfQhdscf6jYrsZOhteqtlzkwyTQQ1mrdAlgaxrE(DuhnTz0Jj1JWoy4upPaaf)0dtjbH6OuUIksryQh0f6jcqPmQhwcpmHc1JbjHc9e5g))XP)deqpmLeKAvv7RQ1GKqHEIC7ycaDl9fhj1JWoy4upx8z26OPpButkwqQJs5k2bkct9GUqprakLr9iSdgo1JKmXrnTKPyHupa4GLqZdgo1Z7EG12bhOwjzIJ1slzkwyTqV2oQZE7DPGOZQn8z3AHTAv2mcG5FC1koqTYv7eLXvBhQ91VEuRzgmgcq9Ws4HjuOEO)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwv1s)BnE(DuhnTz0Jj)BwRQAP)TgxsM4O2m6XK)nRvvT0)wJljtCuBljz4D5JtyGuR6axRIg3Avvl9V14sYeh1MrpM8ejfOpQ9fW1kSdgoxsM4OMwYuSqoQeY(hQpijwRQAP)TgNEgbW8po(3K6OuUIkmfHPEqxONiaLYOEe2bdN6j)oQJM2m6XK6bahSeAEWWPEE3dS2o4a1(UIoRwOxBh1z1g(SBTWwTkBgbW8pUAfhO2ou7RF9OwZmyupSeEycfQh6FRXZVJ6OPnJEm5arVxRQAP)TgNEgbW8po(3Swv1sCTgKek0tKFqsu)9do1IzTQRwf2y1ckO1YIyce9opfaO4NEykji8ejfOpQvD1QyhQLOAvvlX1s)BnUKmXrTTKKH3LpoHbsTQdCTkQa1ckO1s)BnoBIsYKXbDl(4egi1QoW1QyTevRQAjU2xvllCGp84sYeh1MzaaT6YrxONiqTGcATVQwdscf6jYLzV0DOhDDMMfXei69rTerDukxrfmfHPEqxONiaLYOEyj8Wekup0)wJljtCuBg9yYbIEVwv1sCTgKek0tKFqsu)9do1IzTQRwf2y1ckO1YIyce9opfaO4NEykji8ejfOpQvD1QyhQLOAvvlX1(QAzHd8HhxsM4O2mdaOvxo6c9ebQfuqR9v1AqsOqprUm7LUd9ORZ0SiMarVpQLiQhHDWWPEYVJ6OPnJEmPokLROcqryQh0f6jcqPmQhwcpmHc1JbjHc9e5iPz0JjcOPLmflSwv1sCT0)wJljtCuZSL0c5JtyGuR6axBhQfuqRLfXei6DUKmXrDK08efGU1suTQQL4AFvTNmr)453rD00MrpMC0f6jculOGwllIjq07887OoAAZOhtEIKc0h1QUAvGAjQwv1YIyce9oxsM4O2m6XKNiPa9HgvYezhcuR6axRcBSAvvlX1(QAzHd8HhxsM4O2mdaOvxo6c9ebQfuqR9v1AqsOqprUm7LUd9ORZ0SiMarVpQLiQhHDWWPEsbak(PhMscc1rPCfnUueM6bDHEIaukJ6ryhmCQNl(mBD00NnQjfli1daoyj08GHt9yCAJET53DOBvRzgaqRUgv7FG1EXrwlD3AH3aNTAHETrcGzTxuRmHwETWR2E4zxRys9Ws4HjuOEmijuONi)GKO(7hCQfZAFPwfWy1QQwdscf6jYpijQ)(bNAXSw1vRcBSAvvlX1(QAXo)hAAIa8r8Nt8oOBPZpD3Abf0AzHd8HhxsM4O2mdaOvxEkoi1QoW1Qa1se1rPCfFhueM6bDHEIaukJ6HLWdtOq9yqsOqprUX)FC6)ab0dtjbPwv1s)BnUKmXrnZwslKpoHbsTVul9V14sYeh1mBjTqoPOKECcdeQhHDWWPEKKjoQJKM6OuUIgpkct9GUqprakLr9Ws4HjuOEaq6FRXtbak(PhMscI2WF6yk0Wj86YhNWaPwW1cG0)wJNcau8tpmLeeTH)0XuOHt41LtkkPhNWaH6ryhmCQhjzIJAAjtXcPokLRyhNIWupOl0teGszupSeEycfQhdscf6jYn()Jt)hiGEykji1ckO1sCTai9V14Paaf)0dtjbrB4pDmfA4eED5FZAvvlas)BnEkaqXp9Wusq0g(thtHgoHxx(4egi1(sTai9V14Paaf)0dtjbrB4pDmfA4eED5KIs6XjmqQLiQhHDWWPEKKjoQPNY4OokL3bJrryQh0f6jcqPmQhHDWWPEKKjoQPLmflK6bahSeAEWWPEE3dSwsOdRvzsMIfwlnE9i61Mcau8R2HPKGmQf2Q97aywRYEFT9WZo(xTa4u6cDRAFxcau8R2htjbPwiakZzxQhwcpmHc1d9V1453rD00MrpM8VzTQQL(3ACjzIJAZOhtoq071QQw6FRXPNram)JJ)nRvvTSiMarVZtbak(PhMsccprsb6JAFbCTkASAvvl9V14sYeh12ssgEx(4egi1QoW1QOXL6OuEhuKIWupOl0teGszupc7GHt9ijtCuhjn1daoyj08GHt98UhyTrsxB41YaQ97tCmQvmRfoQLfKq3Q2VzTJiCQhwcpmHc1d9V14sYeh1mBjTq(4egi1(sTkCTQQ1GKqHEI8dsI6VFWPwmRvD1QOXQvvTexllIjq078l(mBD00NnQjfliprsb6JAvxTkqTGcATVQww4aF4XLKjoQnZaaA1LJUqprGAjI6OuEh6afHPEqxONiaLYOEe2bdN6rsM4OMeogWjoOEy2c0PEuK6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvT0)wJljtCuBg9yY)MuhLY7GctryQh0f6jcqPmQhHDWWPEKKjoQPLmflK6bahSeAEWWPEENTA7XATWRwZOhZAHE7pGHxlWpHUvTZ)4QThjyoR1wmG1IE8TSR1wghw7f1AHxTrRvRu74YWTQLwYuSWAb(j0TQ9SXAZWKqIzT9qhi6PEyj8Wekup0)wJNFh1rtBg9yY)M1QQw6FRXZVJ6OPnJEm5jskqFu7lGRvyhmCUKmXrnjCmGtCWrLq2)q9bjXAvvl9V14sYeh1MrpM8VzTQQL(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoPOKECcdKAvvl9V14sYeh12ssgEx(4egi1QQw6FRXnJEm1qV9hWW5FZAvvl9V140ZiaM)XX)MuhLY7GcMIWupOl0teGszupc7GHt9ijtCutpLXr9aGdwcnpy4upVZwT9yTw4vRz0JzTqV9hWWRf4Nq3Q25FC12JemN1AlgWArp(w21AlJdR9IATWR2O1QvQDCz4w1slzkwyTa)e6w1E2yTzysiXS2EOde9gv7iQThjyoRn8z3A)dSw0JVLDT0tzCJAHo8GYC2T2lQ1cVAVO2w8ZAz2sAHdQhwcpmHc1d9V14MjoqNH6OPjHoa)BwRQAjUw6FRXLKjoQz2sAH8XjmqQ9LAP)TgxsM4OMzlPfYjfL0JtyGulOGw7RQL4AP)Tg3m6Xud92FadN)nRvvT0)wJtpJay(hh)Bwlr1se1rP8oOaueM6bDHEIaukJ6ryhmCQhZehOZqD00KqhG6bahSeAEWWPEiSnwlnoUA)dS2OvRzqwlCu7f1(hyTWR2lQTZ)HmqMDRL(dNa1YSL0ch1c8tOBvRywR0omR9SXU1AHxTaFsteOw6U1E2yT2ssgE3APLmflK6HLWdtOq9q)BnUKmXrnZwslKpoHbsTVul9V14sYeh1mBjTqoPOKECcdKAvvl9V14sYeh1MrpM8Vj1rP8oyCPim1d6c9ebOug1daoyj08GHt9yCI12l(v7f1ooHbsT2ssgE3AB)5SlVwcBJ1(hyTrRwfnU1ooHbYOwBmXAHJAVOwHXIVF12IS2ZgR9GmqQDITR2WR9SXAz2I74SwXbQ9SXAjHJbCI1c9ABtOL9XPEe2bdN6rsM4OMeogWjoOEG(Hz(npQhfPEy2c0PEuK6HLWdtOq9q)BnUKmXrTTKKH3LpoHbsTVuRIgxQhOFyMFZtBndAzs9Oi1rP8o8oOim1d6c9ebOug1dlHhMqH6H(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoPOKECcdKAvvRbjHc9e5iPz0JjcOPLmflK6ryhmCQhjzIJAAjtXcPokL3bJhfHPEqxONiaLYOEyj8WekupKIlCt2v7l1QOcq9iSdgo1dAiyYbdN6OuEh64ueM6bDHEIaukJ6ryhmCQhjzIJA6PmoQhaCWsO5bdN6rbHp7w7FG1spLXv7f1s)HtGAz2sAHJAHTA7XALzIcq3ATfdyTJGeRTLbzTrst9Ws4HjuOEO)TgxsM4OMzlPfYhNWaPwv1s)BnUKmXrnZwslKpoHbsTVul9V14sYeh1mBjTqoPOKECcdeQJs5kSXOim1d6c9ebOug1daoyj08GHt9yCqW5S2E4zxRqw73N4yuRywlCulliHUvTFZAfhO2EKGeRDg91gETKIlupc7GHt9ijtCutchd4ehupq)Wm)Mh1JIupmBb6upks9Ws4HjuOEEvTexRbjHc9e5hKe1F)GtTyw7lGRvrJvRQAjfx4MSR2xQvHnwTer9a9dZ8BEARzqltQhfPokLRWksryQh0f6jcqPmQhaCWsO5bdN6PZYObN4O2E4zx7m6RLughMDnQwBOLDT2Y4qJQnYAPJZUwsPBTEC1AlgWArp(w21skUu7f1o(MMrE1Ah91skUul0p0hqdyTPaaf)QDykji1YeVwA0OAhrT9ibZzT)bwBdMyT0tzC1koqTTmghDmVA7TrV2z0xB41skUq9iSdgo1tdMOMEkJJ6OuUc3bkct9iSdgo1tlJXrhZJ6bDHEIaukJ6OoQNgCydDlDyIoMueMs5ksryQh0f6jcqPmQhHDWWPEqdbtoy4upa4GLqZdgo1JXPn61MF3HUvTi8SXS2ZgR95P2iRLWgN1orl0bKeIdJQThRTx8R2lQvb1quln2IeR9SXAjCCDmc1rDwT9qhi651(UhyTWRwzu7icVwzu77k6SATLrTnOdh2iqTXpRThjWaw7We9R24N1YSL0chupSeEycfQhIRn)o2I0c5hsAgPm19sAYrxONiqTGcATexB(DSfPfYhqt7W1Jlsso6c9ebQvvTVQwdscf6jYnt08pNA0qul4AvSwIQLOAvvlX1s)BnE(DuhnTz0Jjhi69Abf0Ant0G2IbWvKljtCutlzkwyTevRQAzrmbIENNFh1rtBg9yYtKuG(G6OuEhOim1d6c9ebOug1JWoy4upOHGjhmCQhaCWsO5bdN65D2QThjWawBd6WHncuB8ZAzrmbIEV2EOde9JAfhO2Hj6xTXpRLzlPfomQwZegj8GkiXAvqne1ggWSw0aMDpBOBvlohi1dlHhMqH65Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIKc0h1QQwwetGO35sYeh1MrpM8ejfOpQvvT0)wJljtCuBg9yYbIEVwv1s)BnE(DuhnTz0Jjhi69AvvRzIg0wmaUICjzIJAAjtXcPokLRWueM6bDHEIaukJ6HLWdtOq9KFhBrAHCa4GbnNqxYUAwqskoahDHEIa1QQw6FRXbGdg0CcDj7QzbjP4a6wgJJ)nPEe2bdN6PbtutpLXrDukxbtryQh0f6jcqPmQhwcpmHc1t(DSfPfYTs4y2vdzq2e5Ol0teOwv1skUWnzxTQR2oUcq9iSdgo1tlJXP9WGqDukxbOim1d6c9ebOug1JWoy4upsYeh1KWXaoXb1dZwGo1JIupSeEycfQN87ylslKljtCuBljz4D5Ol0teOwv1s)BnUKmXrTTKKH3LpoHbsTVul9V14sYeh12ssgExoPOKECcdKAvvlX1sCT0)wJljtCuBg9yYbIEVwv1YIyce9oxsM4O2m6XKNOa0TwIQfuqRfaP)Tg)IpZwhn9zJAsXcY)M1se1rPCJlfHPEqxONiaLYOEyj8Wekup53XwKwiFanTdxpUij5Ol0teG6ryhmCQN87OoAAZOhtQJs5Vdkct9GUqprakLr9Ws4HjuOEyrmbIENNFh1rtBg9yYtua6s9iSdgo1JKmXrDK0uhLYnEueM6bDHEIaukJ6HLWdtOq9WIyce9op)oQJM2m6XKNOa0Twv1s)BnUKmXrnZwslKpoHbsTVul9V14sYeh1mBjTqoPOKECcdeQhHDWWPEKKjoQPNY4OokL3XPim1d6c9ebOug1dlHhMqH65v1MFhBrAH8djnJuM6Ejn5Ol0teOwqbTww4aF4XTGTthn9zJ6jKzZrxONia1JWoy4upaOC20r6i1rPCfngfHPEe2bdN6j)oQJM2m6XK6bDHEIaukJ6OuUIksryQh0f6jcqPmQhHDWWPEKKjoQjHJbCIdQhaCWsO5bdN65D2QThjiXALRwsrPAhNWazuB0Q91VUwXbQThR1wmGobxT)bcuBhliCTDXZOA)dSwP2XjmqQ9IAnt0a6xTKFNzdDRA)(ehJAZV7q3Q2ZgR14yjjdVBTt0cDaj7s9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQw6FRXztusMmoOBXhNWaPwW1s)BnoBIsYKXbDloPOKECcdKAvvllmGU4h3a6ND3Swv1YIyce9oNeMzKdD00xKKOF8efGU1QQ2xvRbjHc9e5iPz0JjcOPLmflSwv1YIyce9oxsM4O2m6XKNOa0L6OuUIDGIWupOl0teGszupSeEycfQNxvB(DSfPfYpK0mszQ7L0KJUqprGAvvlX1(QAZVJTiTq(aAAhUECrsYrxONiqTGcATexRbjHc9e5MjA(NtnAiQfCTkwRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQLiQhaCWsO5bdN6r5rskZz3A7XAnfywRzCWWR9pWA7HNDTDuNzuT0)Rw4vBpCoRDkJR2z4w1IE8TSRTfzT0Xzx7zJ1(UIoRwXbQTJ6SA7Hoq0pQ97tCmQn)UdDRApBS2NNAJSwcBCw7eTqhqsioOEe2bdN6Xmoy4uhLYvuHPim1d6c9ebOug1dlHhMqH6H(3A887OoAAZOhtoq071ckO1AMObTfdGRixsM4OMwYuSqQhHDWWPEaq5SPJ0rQJs5kQGPim1d6c9ebOug1dlHhMqH6H(3A887OoAAZOhtoq071ckO1AMObTfdGRixsM4OMwYuSqQhHDWWPEsbak(PhMscc1rPCfvakct9GUqprakLr9Ws4HjuOEO)Tgp)oQJM2m6XKNiPa9rTVulX1ACR9TA7qTDUAZVJTiTq(aAAhUECrsYrxONiqTer9iSdgo1djmZih6OPVijr)OokLROXLIWupOl0teGszupc7GHt9ijtCuBg9ys9aGdwcnpy4upgN2OxB(Dh6w1E2yTghljz4DRDIwOdizxJQ9pWA7OoRwASfjwlHJRJv7f1c8jnRvQT9NZU1ooHbcculTKPyHupSeEycfQhdscf6jYrsZOhteqtlzkwyTQQL(3A887OoAAZOht(3Swv1sCTKIlCt2v7l1sCTDqbQ9TAjUwfnwTDUAzHb0f)4G0nHIxlr1suTGcAT0)wJZMOKmzCq3IpoHbsTGRL(3AC2eLKjJd6wCsrj94egi1se1rPCfFhueM6bDHEIaukJ6HLWdtOq9yqsOqprosAg9yIaAAjtXcRvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGuRQAP)TgxsM4O2m6XK)nPEe2bdN6rsM4OMwYuSqQJs5kA8Oim1d6c9ebOug1JWoy4upJ4pN4Dq3sNF6UupSeEycfQh6FRXZVJ6OPnJEm5arVxlOGwRzIg0wmaUICjzIJAAjtXcRfuqR1mrdAlgaxrEkaqXp9WusqQfuqRL4Ant0G2IbWvKdGYzthPJ1QQ2xvB(DSfPfYhqt7W1Jlsso6c9ebQLiQhxirQNr8Nt8oOBPZpDxQJs5k2XPim1d6c9ebOug1dlHhMqH6H(3A887OoAAZOhtoq071ckO1AMObTfdGRixsM4OMwYuSWAbf0Ant0G2IbWvKNcau8tpmLeKAbf0AjUwZenOTyaCf5aOC20r6yTQQ9v1MFhBrAH8b00oC94IKKJUqprGAjI6ryhmCQNl(mBD00NnQjfli1rP8oymkct9GUqprakLr9Ws4HjuOEmt0G2IbWvKFXNzRJM(SrnPybPEe2bdN6rsM4O2m6XK6OuEhuKIWupOl0teGszupc7GHt9yM4aDgQJMMe6aupa4GLqZdgo1Z7EG12zrhR2lQD05)iQGeRv8ArLUuQTJsM4yTkBkJRwGFcDRApBSwchxhJqDuNvBp0bI(A)(ehJAZV7q3Q2okzIJ1QGYSdETVZwTDuYehRvbLzh1ch1EYe9dbmQ2ESwM4eC1(hyTDw0XQThE2qV2ZgRLWX1Xiuh1z12dDGOV2VpXXO2ESwOFyMFZR2ZgRTJ6y1YSf3XPr1oIA7rcMZAhIbSw4XPEyj8WekupVQ2tMOFCjzIJAKzhC0f6jcuRQAbq6FRXV4ZS1rtF2OMuSG8VzTQQfaP)Tg)IpZwhn9zJAsXcYtKuG(O2xaxlX1kSdgoxsM4OMEkJJJkHS)H6dsI125QL(3ACZehOZqD00KqhGtkkPhNWaPwIOokL3HoqryQh0f6jcqPmQhHDWWPEmtCGod1rttcDaQhaCWsO5bdN65D2QTZIowT2YWj4QLgrV2)abQf4Nq3Q2ZgRLWX1XQTh6arVr12JemN1(hyTWR2lQD05)iQGeRv8ArLUuQTJsM4yTkBkJRwOx7zJ1(UIoJqDuNvBp0bIEo1dlHhMqH6H(3ACjzIJAZOht(3Swv1s)BnE(DuhnTz0Jjprsb6JAFbCTexRWoy4CjzIJA6PmooQeY(hQpijwBNRw6FRXntCGod1rttcDaoPOKECcdKAjI6OuEhuykct9GUqprakLr9Ws4HjuOEaIJNcau8tpmLeeEIKc0h1QUAvGAbf0Abq6FRXtbak(PhMscI2WF6yk0Wj86YhNWaPw1vRXOEe2bdN6rsM4OMEkJJ6OuEhuWueM6bDHEIaukJ6ryhmCQhjzIJAAjtXcPEaWblHMhmCQhJtS2EXVAVOwsbeS2XpXA7XATfdyTOhFl7AjfxQTfzTNnwl6hmXA7OoR2EOde9gvlAa9AHTApBmrcg1oo4Cw7bjXAtKuGo0TQn8AFxrNXR9DEemQn8z3APX7WS2lQL(NETxuRcsmJAfhOwfudrTWwT53DOBv7zJ1(8uBK1syJZANOf6ascXbN6HLWdtOq9WIyce9oxsM4O2m6XKNOa0Twv1skUWnzxTVulX1QGnwTVvlX1QOXQTZvllmGU4hhKUju8AjQwIQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGuRQAjU2xvB(DSfPfYhqt7W1Jlsso6c9ebQfuqR1GKqHEICZen)ZPgne1cUwfRLOAvv7RQn)o2I0c5hsAgPm19sAYrxONiqTQQ9v1MFhBrAHCjzIJABjjdVlhDHEIauhLY7GcqryQh0f6jcqPmQhHDWWPEKKjoQPLmflK6bahSeAEWWPEuMKPyH1oSJ)eOwpUAPXA)deOw5Q9SXArhO2OvBh1z1cB1QGAiyYbdVw4O2efGU1kJAbYW0e6w1YSL0ch12dNZAjfqWAHxTNacw7mClmR9IAP)Px7zNX3YU2ejfOdDRAjfxOEyj8Wekup0)wJljtCuBg9yY)M1QQw6FRXLKjoQnJEm5jskqFu7lGR1IbuRQAzrmbIENJgcMCWW5jskqFqDukVdgxkct9GUqprakLr9iSdgo1JKmXrnTKPyHupa4GLqZdgo1JYKmflS2HD8Na1kZEP7OwAS2ZgRDkJRwMmUAHETNnw77k6SA7Hoq0xRmQLWX1XQThoN1M44IeR9SXAz2sAHJAhMOFupSeEycfQh6FRXZVJ6OPnJEm5FZAvvl9V14sYeh1MrpMCGO3RvvT0)wJNFh1rtBg9yYtKuG(O2xaxRfdOwv1(QAZVJTiTqUKmXrTTKKH3LJUqpraQJs5D4DqryQh0f6jcqPmQhMTaDQhfPEqjND1mBb6AyJ6H(3AC2eLKjJd6wAMT4oo5arVRIy6FRXLKjoQnJEm5FtqbL4xDYe9JhgW0m6Xeburm9V1453rD00MrpM8VjOGYIyce9ohnem5GHZtua6serer9Ws4HjuOEaq6FRXV4ZS1rtF2OMuSG8VzTQQ9Kj6hxsM4Ogz2bhDHEIa1QQwIRL(3ACauoB6iDKde9ETGcATc7Ggqn6ijeh1cUwfRLOAvvlas)Bn(fFMToA6Zg1KIfKNiPa9rTQRwHDWW5sYeh1KWXaoXbhvcz)d1hKePEe2bdN6rsM4OMeogWjoOokL3bJhfHPEqxONiaLYOEe2bdN6rsM4OMeogWjoOEaWblHMhmCQN3zR2EKGeR1a6ND30OAHKKiauoC2T2)aR91VU2EB0RLjMMiqTxuRhxT9Y4WAnZGnQTLbzTDSGWupSeEycfQhwyaDXpUb0p7UzTQQL(3AC2eLKjJd6w8XjmqQfCT0)wJZMOKmzCq3ItkkPhNWaH6OuEh64ueM6bDHEIaukJ6bahSeAEWWPEEojVA)dOBv7RFDTDuhR2EB0RTJ6SATLrT0i61(hia1dlHhMqH6H(3AC2eLKjJd6w8ef2vRQAzrmbIENljtCuBg9yYtKuG(Owv1sCT0)wJNFh1rtBg9yY)M1ckO1s)BnUKmXrTz0Jj)BwlrupmBb6upks9iSdgo1JKmXrnjCmGtCqDukxHngfHPEqxONiaLYOEyj8Wekup0)wJljtCuZSL0c5JtyGu7lGR1GKqHEI8losnPOKMzlPfoOEe2bdN6rsM4OosAQJs5kSIueM6bDHEIaukJ6HLWdtOq9q)BnE(DuhnTz0Jj)BwlOGwlP4c3KD1QUAvubOEe2bdN6rsM4OMEkJJ6OuUc3bkct9GUqprakLr9iSdgo1dAiyYbdN6b6hM5380Wg1dP4c3KDQdSXtbOEG(Hz(npnKKebGYHupks9Ws4HjuOEO)Tgp)oQJM2m6XKde9ETQQL(3ACjzIJAZOhtoq07uhLYvyfMIWupc7GHt9ijtCutlzkwi1d6c9ebOug1rDupzCYbdNIWukxrkct9GUqprakLr9iSdgo1dAiyYbdN6bahSeAEWWPEE3dSw0qulSvBpsqI1oJ(AdVwsXLAfhOwwetGO3h1kjwRqh)R2lQLgR9Bs9Ws4HjuOEEvT53XwKwiFanTdxpUij5Ol0teOwv1skUWnzxTVaUwdscf6jYrdH2KD1QQwIRLfXei6D(fFMToA6Zg1KIfKNiPa9rTVaUwHDWW5OHGjhmCoQeY(hQpijwlOGwllIjq07CjzIJAZOhtEIKc0h1(c4Af2bdNJgcMCWW5Osi7FO(GKyTGcATex7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejfOpQ9fW1kSdgohnem5GHZrLq2)q9bjXAjQwIQvvT0)wJNFh1rtBg9yYbIEVwv1s)BnUKmXrTz0Jjhi69Avvlas)Bn(fFMToA6Zg1KIfKde9ETQQ9v1AMObTfdGRi)IpZwhn9zJAsXcsDukVdueM6bDHEIaukJ6HLWdtOq9KFhBrAH8b00oC94IKKJUqprGAvv7RQLfgqx8JBa9ZUBwRQAzrmbIENljtCuBg9yYtKuG(O2xaxRWoy4C0qWKdgohvcz)d1hKePEe2bdN6bnem5GHtDukxHPim1d6c9ebOug1dlHhMqH6j)o2I0c5dOPD46XfjjhDHEIa1QQwwyaDXpUb0p7UzTQQLfXei6DojmZih6OPVijr)4jskqFu7lGRvyhmCoAiyYbdNJkHS)H6dsI1QQwwetGO35x8z26OPpButkwqEIKc0h1(c4AjUwdscf6jYjJtBMidra9fhPMUBTVvRWoy4C0qWKdgohvcz)d1hKeR9TAv4AjQwv1YIyce9oxsM4O2m6XKNiPa9rTVaUwIR1GKqHEICY40MjYqeqFXrQP7w7B1kSdgohnem5GHZrLq2)q9bjXAFRwfUwIOEe2bdN6bnem5GHtDukxbtryQh0f6jcqPmQhHDWWPEKKjoQPLmflK6bahSeAEWWPEuMKPyH1cB1cpcg1EqsS2lQ9pWAV4iRvCGA7XATfdyTxe1skE3Az2sAHdQhwcpmHc1dlIjq078l(mBD00NnQjfliprbOBTQQL4AP)TgxsM4OMzlPfYhNWaPw1vRbjHc9e5xCKAsrjnZwslCuRQAzrmbIENljtCuBg9yYtKuG(O2xaxlQeY(hQpijwRQAjfx4MSRw1vRbjHc9e5IPMe6qYpPMuCrBYUAvvl9V1453rD00MrpMCGO3RLiQJs5kafHPEqxONiaLYOEyj8WekupSiMarVZV4ZS1rtF2OMuSG8efGU1QQwIRL(3ACjzIJAMTKwiFCcdKAvxTgKek0tKFXrQjfL0mBjTWrTQQ9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIKc0h1(c4ArLq2)q9bjXAvvRbjHc9e5hKe1F)GtTywR6Q1GKqHEI8losnPOKgaNsxDlsTywlrupc7GHt9ijtCutlzkwi1rPCJlfHPEqxONiaLYOEyj8WekupSiMarVZV4ZS1rtF2OMuSG8efGU1QQwIRL(3ACjzIJAMTKwiFCcdKAvxTgKek0tKFXrQjfL0mBjTWrTQQL4AFvTNmr)453rD00MrpMC0f6jculOGwllIjq07887OoAAZOhtEIKc0h1QUAnijuONi)IJutkkPbWP0v3IuNHzTevRQAnijuONi)GKO(7hCQfZAvxTgKek0tKFXrQjfL0a4u6QBrQfZAjI6ryhmCQhjzIJAAjtXcPokL)oOim1d6c9ebOug1dlHhMqH6baP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdKAbxlas)BnEkaqXp9Wusq0g(thtHgoHxxoPOKECcdKAvvlX1s)BnUKmXrTz0Jjhi69Abf0AP)TgxsM4O2m6XKNiPa9rTVaUwlgqTevRQAjUw6FRXZVJ6OPnJEm5arVxlOGwl9V1453rD00MrpM8ejfOpQ9fW1AXaQLiQhHDWWPEKKjoQPLmflK6OuUXJIWupOl0teGszupSeEycfQhdscf6jYn()Jt)hiGEykji1ckO1sCTai9V14Paaf)0dtjbrB4pDmfA4eED5FZAvvlas)BnEkaqXp9Wusq0g(thtHgoHxx(4egi1(sTai9V14Paaf)0dtjbrB4pDmfA4eED5KIs6XjmqQLiQhHDWWPEKKjoQPNY4OokL3XPim1d6c9ebOug1dlHhMqH6H(3ACZehOZqD00KqhG)nRvvTai9V14x8z26OPpButkwq(3Swv1cG0)wJFXNzRJM(SrnPyb5jskqFu7lGRvyhmCUKmXrn9ughhvcz)d1hKePEe2bdN6rsM4OMEkJJ6OuUIgJIWupOl0teGszupmBb6upks9Gso7Qz2c01Wg1d9V14Sjkjtgh0T0mBXDCYbIExfX0)wJljtCuBg9yY)MGckXV6Kj6hpmGPz0JjcOIy6FRXZVJ6OPnJEm5FtqbLfXei6DoAiyYbdNNOa0LiIiI6HLWdtOq9aG0)wJFXNzRJM(SrnPyb5FZAvv7jt0pUKmXrnYSdo6c9ebQvvTexl9V14aOC20r6ihi69Abf0Af2bnGA0rsioQfCTkwlr1QQwIRfaP)Tg)IpZwhn9zJAsXcYtKuG(Ow1vRWoy4CjzIJAs4yaN4GJkHS)H6dsI1ckO1YIyce9o3mXb6muhnnj0b4jskqFulOGwllmGU4hhKUju8AjI6ryhmCQhjzIJAs4yaN4G6OuUIksryQh0f6jcqPmQhHDWWPEKKjoQjHJbCIdQhaCWsO5bdN651Hp(KyTNnwlQKP4aiqTMXH(bLzT0)wRwziM1ErTEC1oJbwRzCOFqzwRzgSb1dlHhMqH6H(3AC2eLKjJd6w8ef2vRQAP)TghvYuCaeqBgh6huM8Vj1rPCf7afHPEqxONiaLYOEe2bdN6rsM4OMeogWjoOEy2c0PEuK6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvTexl9V14sYeh1MrpM8VzTGcAT0)wJNFh1rtBg9yY)M1ckO1cG0)wJFXNzRJM(SrnPyb5jskqFuR6QvyhmCUKmXrnjCmGtCWrLq2)q9bjXAjI6OuUIkmfHPEqxONiaLYOEe2bdN6rsM4OMeogWjoOEy2c0PEuK6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvT0)wJZMOKmzCq3IpoHbsTGRL(3AC2eLKjJd6wCsrj94egiuhLYvubtryQh0f6jcqPmQhaCWsO5bdN6PJM9s3rTx2T2lQLwCqQ91VU2wK1YIyce9ET9qhi6h1s)VAb(KM1E2izTWwTNn2LGeRvOJ)v7f1IkzctK6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvT0)wJZMOKmzCq3INiPa9rTVaUwIRL4AP)TgNnrjzY4GUfFCcdKA7C1kSdgoxsM4OMeogWjo4Osi7FO(GKyTev7B1AXa4KIs1se1dZwGo1JIupc7GHt9ijtCutchd4ehuhLYvubOim1d6c9ebOug1dlHhMqH6H4AtSL4WwONyTGcATVQ2dYab6w1suTQQL(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoPOKECcdKAvvl9V14sYeh1MrpMCGO3RvvTai9V14x8z26OPpButkwqoq07upc7GHt944zJP(qstCCuhLYv04sryQh0f6jcqPmQhwcpmHc1d9V14sYeh1mBjTq(4egi1(c4AnijuONi)IJutkkPz2sAHdQhHDWWPEKKjoQJKM6OuUIVdkct9GUqprakLr9Ws4HjuOEmijuONip(3acG6OPzrmbIEFuRQAjfx4MSR2xaxBhxbOEe2bdN6z8nX0ddc1rPCfnEueM6bDHEIaukJ6HLWdtOq9q)BnE(NOoA6ZorCW)M1QQw6FRXLKjoQz2sAH8XjmqQvD1QWupc7GHt9ijtCutpLXrDukxXoofHPEqxONiaLYOEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6X4OpPzTmBjTWrTWwT9yTnzoRLgNrFTNnwll8bMgWAjfxQ9StCyhtGAfhOw0qWKdgETWrTJdoN1gETSiMarVt9Ws4HjuOEEvT53XwKwiFanTdxpUij5Ol0teOwv1AqsOqprE8Vbea1rtZIyce9(Owv1s)BnUKmXrnZwslKpoHbsTGRL(3ACjzIJAMTKwiNuuspoHbsTQQ9Kj6hxsM4OosAo6c9ebQvvTSiMarVZLKjoQJKMNiPa9rTVaUwlgqTQQLuCHBYUAFbCTDCJvRQAzrmbIENJgcMCWW5jskqFqDukVdgJIWupOl0teGszupSeEycfQN87ylslKpGM2HRhxKKC0f6jcuRQAnijuONip(3acG6OPzrmbIEFuRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwv1EYe9JljtCuhjnhDHEIa1QQwwetGO35sYeh1rsZtKuG(O2xaxRfdOwv1skUWnzxTVaU2oUXQvvTSiMarVZrdbtoy48ejfOpQ9LAvyJr9iSdgo1JKmXrnTKPyHuhLY7GIueM6bDHEIaukJ6ryhmCQhjzIJAAjtXcPEaWblHMhmCQhJJ(KM1YSL0ch1cB1gjDTWrTjkaDPEyj8WekupgKek0tKh)BabqD00SiMarVpQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGuRQApzI(XLKjoQJKMJUqprGAvvllIjq07CjzIJ6iP5jskqFu7lGR1IbuRQAjfx4MSR2xaxBh3y1QQwwetGO35OHGjhmCEIKc0h1QQwIR9v1MFhBrAH8b00oC94IKKJUqprGAbf0AP)TgFanTdxpUij5jskqFu7lGRvrJxTerDukVdDGIWupOl0teGszupc7GHt9ijtCutlzkwi1daoyj08GHt90rjtCSwLjzkwyTd74pbQ1cDmL5SBT0yTNnw7ugxTmzC1gTApBS2oQZQTh6arp1dlHhMqH6H(3ACjzIJAZOht(3Swv1s)BnUKmXrTz0Jjprsb6JAFbCTwmGAvvl9V14sYeh1mBjTq(4egi1cUw6FRXLKjoQz2sAHCsrj94egi1QQwIRLfXei6DoAiyYbdNNiPa9rTGcAT53XwKwixsM4O2wsYW7YrxONiqTerDukVdkmfHPEqxONiaLYOEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6PJsM4yTktYuSWAh2XFcuRf6ykZz3APXApBS2PmUAzY4QnA1E2yTVROZQTh6arp1dlHhMqH6H(3A887OoAAZOht(3Swv1s)BnUKmXrTz0Jjhi69Avvl9V1453rD00MrpM8ejfOpQ9fW1AXaQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGuRQAjUwwetGO35OHGjhmCEIKc0h1ckO1MFhBrAHCjzIJABjjdVlhDHEIa1se1rP8oOGPim1d6c9ebOug1JWoy4upsYeh10sMIfs9aGdwcnpy4upDuYehRvzsMIfw7Wo(tGAPXApBS2PmUAzY4QnA1E2yTeoUowT9qhi6Rf2QfE1ch16Xv7FGa12dp7AFxrNvBK12rDg1dlHhMqH6H(3ACjzIJAZOhtoq071QQw6FRXZVJ6OPnJEm5arVxRQAbq6FRXV4ZS1rtF2OMuSG8VzTQQfaP)Tg)IpZwhn9zJAsXcYtKuG(O2xaxRfdOwv1s)BnUKmXrnZwslKpoHbsTGRL(3ACjzIJAMTKwiNuuspoHbc1rP8oOaueM6bDHEIaukJ6ryhmCQhjzIJAAjtXcPEaWblHMhmCQhJtB0R9SXApjTWRw4OwOxlQeY(hwBkUfwR4a1E2yI1ch1sgjw7zlETHJ1Ios21OA)dSwAjtXcRvg1oIWRvg12n(1AlgWArp(w21YSL0ch1ErT2WRwzoRfDKeIJAHTApBS2okzIJ1QSGKwsas0VANOf6as2Tw4OwSZ)HMMia1dlHhMqH6XGKqHEICK0m6Xeb00sMIfwRQAP)TgxsM4OMzlPfYhNWaPw1bUwIRvyh0aQrhjH4OwJVAvSwIQvvTc7Ggqn6ijeh1QUAvSwv1s)BnoakNnDKoYbIEN6OuEhmUueM6bDHEIaukJ6HLWdtOq9yqsOqprosAg9yIaAAjtXcRvvT0)wJljtCuZSL0c5JtyGu7l1s)BnUKmXrnZwslKtkkPhNWaPwv1kSdAa1OJKqCuR6QvXAvvl9V14aOC20r6ihi6DQhHDWWPEKKjoQrLmNXago1rP8o8oOim1JWoy4upsYeh10tzCupOl0teGszuhLY7GXJIWupOl0teGszupSeEycfQhdscf6jYJ)nGaOoAAwetGO3hupc7GHt9GgcMCWWPokL3HoofHPEe2bdN6rsM4OMwYuSqQh0f6jcqPmQJ6OEaWM8NhfHPuUIueM6ryhmCQhw89dZHjoNupOl0teGszuhLY7afHPEqxONiaLYOEyj8Wekupex7jt0po6tOL9HocWrxONiqTQQLuCHBYUAFbCTgpJvRQAjfx4MSRw1bUwJRculr1ckO1sCTVQ2tMOFC0Nql7dDeGJUqprGAvvlP4c3KD1(c4AnEkqTer9iSdgo1dP4I2cjPokLRWueM6bDHEIaukJ6HLWdtOq9q)BnUKmXrTz0Jj)Bs9iSdgo1JzCWWPokLRGPim1d6c9ebOug1dlHhMqH6j)o2I0c5hsAgPm19sAYrxONiqTQQL(3ACujB5poy48VzTQQL4AzrmbIENljtCuBg9yYtua6wlOGwlDmg1QQ2g0Y(0jskqFu7lGRvbBSAjI6ryhmCQNdsI6EjnPokLRaueM6bDHEIaukJ6HLWdtOq9q)BnUKmXrTz0Jjhi69Avvl9V1453rD00MrpMCGO3RvvTai9V14x8z26OPpButkwqoq07upc7GHt9mHw23qB8)bSir)OokLBCPim1d6c9ebOug1dlHhMqH6H(3ACjzIJAZOhtoq071QQw6FRXZVJ6OPnJEm5arVxRQAbq6FRXV4ZS1rtF2OMuSGCGO3PEe2bdN6HwS0rtFjKbYG6Ou(7GIWupOl0teGszupSeEycfQh6FRXLKjoQnJEm5FtQhHDWWPEOXCGjiq3I6OuUXJIWupOl0teGszupSeEycfQh6FRXLKjoQnJEm5FtQhHDWWPEONraOB)Sl1rP8oofHPEqxONiaLYOEyj8Wekup0)wJljtCuBg9yY)Mupc7GHt90GjspJaG6OuUIgJIWupOl0teGszupSeEycfQh6FRXLKjoQnJEm5FtQhHDWWPEeNHJlLPMjZj1rPCfvKIWupOl0teGszupSeEycfQh6FRXLKjoQnJEm5FtQhHDWWPE(dudpKCqDukxXoqryQh0f6jcqPmQhHDWWPESMcauUihAAbWcPEyj8Wekup0)wJljtCuBg9yY)M1ckO1YIyce9oxsM4O2m6XKNiPa9rTQdCTkGcuRQAbq6FRXV4ZS1rtF2OMuSG8Vj1d2Ai70UqIupwtbakxKdnTayHuhLYvuHPim1d6c9ebOug1JWoy4upiPz3eLPosaxCgs9Ws4HjuOEyrmbIENljtCuBg9yYtKuG(O2xaxRIkqTQQLfXei6D(fFMToA6Zg1KIfKNiPa9rTVaUwfvaQhxirQhK0SBIYuhjGlodPokLROcMIWupOl0teGszupc7GHt9aKOa0GjQnGJboPEyj8WekupSiMarVZLKjoQnJEm5jskqFuR6axBhmwTGcATVQwdscf6jYftD46)aRfCTkwlOGwlX1EqsSwW1ASAvvRbjHc9e5n4Wg6w6WeDmRfCTkwRQAZVJTiTq(aAAhUECrsYrxONiqTer94cjs9aKOa0GjQnGJboPokLROcqryQh0f6jcqPmQhHDWWPEgXFQHwo8WK6HLWdtOq9WIyce9oxsM4O2m6XKNiPa9rTQdCTkSXQfuqR9v1AqsOqprUyQdx)hyTGRvrQhxirQNr8NAOLdpmPokLROXLIWupOl0teGszupc7GHt9yn7AARJMwgdijCkhmCQhwcpmHc1dlIjq07CjzIJAZOhtEIKc0h1QoW12bJvlOGw7RQ1GKqHEICXuhU(pWAbxRI1ckO1sCThKeRfCTgRwv1AqsOqprEdoSHULomrhZAbxRI1QQ287ylslKpGM2HRhxKKC0f6jculrupUqIupwZUM26OPLXascNYbdN6OuUIVdkct9GUqprakLr9iSdgo1dPWe6e1dBepn5FazupSeEycfQhwetGO35sYeh1MrpM8ejfOpQ9fW1Qa1QQwIR9v1AqsOqprEdoSHULomrhZAbxRI1ckO1EqsSw1vRcBSAjI6XfsK6HuycDI6HnINM8pGmQJs5kA8Oim1d6c9ebOug1JWoy4upKctOtupSr80K)bKr9Ws4HjuOEyrmbIENljtCuBg9yYtKuG(O2xaxRcuRQAnijuONiVbh2q3shMOJzTGRvXAvvl9V1453rD00MrpM8VzTQQL(3A887OoAAZOhtEIKc0h1(c4AjUwfnwTgF1Qa125Qn)o2I0c5dOPD46XfjjhDHEIa1suTQQ9GKyTVuRcBmQhxirQhsHj0jQh2iEAY)aYOokLRyhNIWupOl0teGszupc7GHt9mSfGOhb0rsRJM(IKe9J6HLWdtOq9CqsSwW1ASAbf0AjUwdscf6jYJ)nGaOoAAwetGO3h1QQwIRL4AzHb0f)4G0nHIxRQAzrmbIENNcau8tpmLeeEIKc0h1(c4A7qTQQLfXei6DUKmXrTz0Jjprsb6JAFbCTkqTQQLfXei6D(fFMToA6Zg1KIfKNiPa9rTVaUwfOwIQfuqRLfXei6DUKmXrTz0Jjprsb6JAFbCTDOwqbT2g0Y(0jskqFu7l1YIyce9oxsM4O2m6XKNiPa9rTevlrupUqIupdBbi6raDK06OPVijr)OokL3bJrryQh0f6jcqPmQhaCWsO5bdN6rb4g3AHJApBS2HjIa1gTApBS2N4pN4Dq3Q231NUBTMzy8JSdorQhxirQNr8Nt8oOBPZpDxQhwcpmHc1dX1AqsOqpr(bjr93p4ulM1(wTexRWoy48uaGIF6HPKGWrLq2)q9bjXA7C1YcdOl(XbPBcfVwIQ9TAjUwHDWW5aOC20r6ihvcz)d1hKeRTZvllmGU4h3rwgZibQLOAFRwHDWW5x8z26OPpButkwqoQeY(hQpijw7l1EsAHhhaooXzyTeQwfGBCRLOAvvlX1AqsOqprUTya1Hj6iqTGcATexllmGU4hhKUju8AvvB(DSfPfYLKjoQHEd6WRlhDHEIa1suTevRQApjTWJdahN4mSw1vBhuaQhHDWWPEgXFoX7GULo)0DPokL3bfPim1d6c9ebOug1dlHhMqH6ryh0aQrhjH4Ow1bUwdscf6jYLa1NKw4PzX3pQNXLq2rPCfPEe2bdN6HjZPwyhmC9eooQNjCCAxirQhjqQJs5DOdueM6bDHEIaukJ6HLWdtOq9WcdOl(XbPBcfVwv1MFhBrAHCjzIJABjjdVlhDHEIaupJlHSJs5ks9iSdgo1dtMtTWoy46jCCupt440UqIup2ssgExQJs5DqHPim1d6c9ebOug1dlHhMqH6XGKqHEICBXaQdt0rGAbxRXQvvTgKek0tK3GdBOBPdt0XSwv1(QAjUwwyaDXpoiDtO41QQ287ylslKljtCuBljz4D5Ol0teOwIOEgxczhLYvK6ryhmCQhMmNAHDWW1t44OEMWXPDHePEAWHn0T0Hj6ysDukVdkykct9GUqprakLr9Ws4HjuOEmijuONi3wmG6WeDeOwW1ASAvv7RQL4AzHb0f)4G0nHIxRQAZVJTiTqUKmXrTTKKH3LJUqprGAjI6zCjKDukxrQhHDWWPEyYCQf2bdxpHJJ6zchN2fsK6jmrhtQJs5DqbOim1d6c9ebOug1dlHhMqH65v1sCTSWa6IFCq6MqXRvvT53XwKwixsM4O2wsYW7YrxONiqTer9mUeYokLRi1JWoy4upmzo1c7GHRNWXr9mHJt7cjs9WIyce9(G6OuEhmUueM6bDHEIaukJ6HLWdtOq9yqsOqprEd6Yut)tVwW1ASAvv7RQL4AzHb0f)4G0nHIxRQAZVJTiTqUKmXrTTKKH3LJUqprGAjI6zCjKDukxrQhHDWWPEyYCQf2bdxpHJJ6zchN2fsK6jJtoy4uhLY7W7GIWupOl0teGszupSeEycfQhdscf6jYBqxMA6F61cUwfRvvTVQwIRLfgqx8Jds3ekETQQn)o2I0c5sYeh12ssgExo6c9ebQLiQNXLq2rPCfPEe2bdN6HjZPwyhmC9eooQNjCCAxirQNg0LPM(No1rDupMjYcsA5OimLYvKIWupc7GHt9ijtCud9dNtKDupOl0teGszuhLY7afHPEe2bdN6z8jjdxljtCu3es4ekj1d6c9ebOug1rPCfMIWupc7GHt9Wc34)NOMuCrBHKupOl0teGszuhLYvWueM6ryhmCQhsyMrQHKIfs9GUqprakLrDukxbOim1d6c9ebOug1dlHhMqH6ze)jn0b4gIPCWjQhX0a6hhDHEIa1ckO1oI)Kg6aCZ)4(tuJ538GHZrxONia1JWoy4upTjoSzP0oQJs5gxkct9GUqprakLr9Ws4HjuOEyHb0f)4G0nHIxRQAZVJTiTqUKmXrTTKKH3LJUqprGAvvllCGp84sYeh1MzaaT6YrxONiqTQQ1GKqHEICz2lDh6rxNPzrmbIEFuRQAf2bnGA0rsioQ9LAnijuONixcuFsAHNMfF)OEe2bdN6j)oQJM2m6XK6Ou(7GIWupOl0teGszupSeEycfQNxvRbjHc9e5MjA(NtnAiQfCTkwRQAZVJTiTqoaCWGMtOlzxnlijfhGJUqpraQhHDWWPEAzmo6yEuhLYnEueM6bDHEIaukJ6HLWdtOq98QAnijuONi3mrZ)CQrdrTGRvXAvv7RQn)o2I0c5aWbdAoHUKD1SGKuCao6c9ebQvvTex7RQLfgqx8JBa9ZUBwlOGwRbjHc9e5n4Wg6w6WeDmRLiQhHDWWPEKKjoQPNY4OokL3XPim1d6c9ebOug1dlHhMqH65v1AqsOqprUzIM)5uJgIAbxRI1QQ2xvB(DSfPfYbGdg0CcDj7QzbjP4aC0f6jcuRQAzHb0f)4gq)S7M1QQ2xvRbjHc9e5n4Wg6w6WeDmPEe2bdN6HeMzKdD00xKKOFuhLYv0yueM6bDHEIaukJ6HLWdtOq9yqsOqprUzIM)5uJgIAbxRIupc7GHt9GgcMCWWPoQJ6rcKIWukxrkct9GUqprakLr9Ws4HjuOEYVJTiTqoaCWGMtOlzxnlijfhGJUqprGAvvllIjq07C6FRPbGdg0CcDj7QzbjP4a8efGU1QQw6FRXbGdg0CcDj7QzbjP4a6wgJJde9ETQQL4AP)TgxsM4O2m6XKde9ETQQL(3A887OoAAZOhtoq071QQwaK(3A8l(mBD00NnQjflihi69AjQwv1YIyce9o)IpZwhn9zJAsXcYtKuG(OwW1ASAvvlX1s)BnUKmXrnZwslKpoHbsTVaUwdscf6jYLa1xCKAsrjnZwslCuRQAjUwIR9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIKc0h1(c4ATya1QQwwetGO35sYeh1MrpM8ejfOpQvD1AqsOqpr(fhPMuusdGtPRUfPwmRLOAbf0AjU2xv7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO35sYeh1MrpM8ejfOpQvD1AqsOqpr(fhPMuusdGtPRUfPwmRLOAbf0AzrmbIENljtCuBg9yYtKuG(O2xaxRfdOwIQLiQhHDWWPEAzmo6yEuhLY7afHPEqxONiaLYOEyj8WekupexB(DSfPfYbGdg0CcDj7QzbjP4aC0f6jcuRQAzrmbIENt)BnnaCWGMtOlzxnlijfhGNOa0Twv1s)BnoaCWGMtOlzxnlijfhq3GjYbIEVwv1AMObTfdGRiVLX4OJ5vlr1ckO1sCT53XwKwihaoyqZj0LSRMfKKIdWrxONiqTQQ9GKyTGR1y1se1JWoy4upnyIA6PmoQJs5kmfHPEqxONiaLYOEyj8Wekup53XwKwi3kHJzxnKbztKJUqprGAvvllIjq07CjzIJAZOhtEIKc0h1QUAvyJvRQAzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL4AP)TgxsM4OMzlPfYhNWaP2xaxRbjHc9e5sG6losnPOKMzlPfoQvvTexlX1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAFbCTwmGAvvllIjq07CjzIJAZOhtEIKc0h1QUAnijuONi)IJutkkPbWP0v3IulM1suTGcATex7RQ9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07CjzIJAZOhtEIKc0h1QUAnijuONi)IJutkkPbWP0v3IulM1suTGcATSiMarVZLKjoQnJEm5jskqFu7lGR1Ibulr1se1JWoy4upTmgN2ddc1rPCfmfHPEqxONiaLYOEyj8Wekup53XwKwi3kHJzxnKbztKJUqprGAvvllIjq07CjzIJAZOhtEIKc0h1cUwJvRQAjUwIRL4AzrmbIENFXNzRJM(SrnPyb5jskqFuR6Q1GKqHEICXutkkPbWP0v3IuFXrwRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQfuqRL4AzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKlbQV4i1KIsAMTKw4OwIQLOAvvl9V1453rD00MrpMCGO3RLiQhHDWWPEAzmoThgeQJs5kafHPEqxONiaLYOEe2bdN6rsM4OMeogWjoOEy2c0PEuK6HLWdtOq9WcdOl(XbPBcfVwv1MFhBrAHCjzIJABjjdVlhDHEIa1QQw6FRXLKjoQTLKm8U8XjmqQ9LAvubQvvTSiMarVZtbak(PhMsccprsb6JAFbCTgKek0tKBljz4D1JtyGOpijw7B1IkHS)H6dsI1QQwwetGO35x8z26OPpButkwqEIKc0h1(c4AnijuONi3wsYW7QhNWarFqsS23Qfvcz)d1hKeR9TAf2bdNNcau8tpmLeeoQeY(hQpijwRQAzrmbIENljtCuBg9yYtKuG(O2xaxRbjHc9e52ssgEx94egi6dsI1(wTOsi7FO(GKyTVvRWoy48uaGIF6HPKGWrLq2)q9bjXAFRwHDWW5x8z26OPpButkwqoQeY(hQpijsDuk34sryQh0f6jcqPmQhHDWWPEKKjoQjHJbCIdQhMTaDQhfPEyj8WekupSWa6IFCdOF2DZAvvB(DSfPfYLKjoQHEd6WRlhDHEIa1QQw6FRXLKjoQTLKm8U8XjmqQ9LAvubQvvTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ9fW1AqsOqprUTKKH3vpoHbI(GKyTVvlQeY(hQpijwRQAzrmbIENljtCuBg9yYtKuG(O2xaxRbjHc9e52ssgEx94egi6dsI1(wTOsi7FO(GKyTVvRWoy48l(mBD00NnQjflihvcz)d1hKePokL)oOim1d6c9ebOug1dlHhMqH6Hfgqx8JBa9ZUBwRQApzI(XLKjoQrMDWrxONiqTQQ9GKyTVuRIgRwv1YIyce9oNeMzKdD00xKKOF8ejfOpQvvT0)wJZMOKmzCq3IpoHbsTVuRct9iSdgo1JKmXrn9ugh1rPCJhfHPEqxONiaLYOEe2bdN6ze)5eVd6w68t3L6HLWdtOq9KFhBrAH8b00oC94IKKJUqprGAvvRzIg0wmaUIC0qWKdgo1JlKi1Zi(ZjEh0T05NUl1rP8oofHPEqxONiaLYOEyj8Wekup53XwKwiFanTdxpUij5Ol0teOwv1AMObTfdGRihnem5GHt9iSdgo1ZfFMToA6Zg1KIfK6OuUIgJIWupOl0teGszupSeEycfQN87ylslKpGM2HRhxKKC0f6jcuRQAjUwZenOTyaCf5OHGjhm8Abf0Ant0G2IbWvKFXNzRJM(SrnPybRLiQhHDWWPEKKjoQnJEmPokLROIueM6bDHEIaukJ6HLWdtOq9KFhBrAHCjzIJAO3Go86YrxONiqTQQLfXei6D(fFMToA6Zg1KIfKNiPa9rTVaUwfnwTQQLfXei6DUKmXrTz0Jjprsb6JAFbCTkQaupc7GHt9qcZmYHoA6lss0pQJs5k2bkct9GUqprakLr9Ws4HjuOEyrmbIENljtCuBg9yYtKuG(O2xaxRXRwv1YIyce9o)IpZwhn9zJAsXcYtKuG(O2xaxRXRwv1sCT0)wJljtCuZSL0c5JtyGu7lGR1GKqHEICjq9fhPMuusZSL0ch1QQwIRL4ApzI(XZVJ6OPnJEm5Ol0teOwv1YIyce9op)oQJM2m6XKNiPa9rTVaUwlgqTQQLfXei6DUKmXrTz0Jjprsb6JAvxTkqTevlOGwlX1(QApzI(XZVJ6OPnJEm5Ol0teOwv1YIyce9oxsM4O2m6XKNiPa9rTQRwfOwIQfuqRLfXei6DUKmXrTz0Jjprsb6JAFbCTwmGAjQwIOEe2bdN6HeMzKdD00xKKOFuhLYvuHPim1d6c9ebOug1dlHhMqH65GKyTQRwf2y1QQ287ylslKpGM2HRhxKKC0f6jcuRQAzHb0f)4gq)S7M1QQwZenOTyaCf5KWmJCOJM(IKe9J6ryhmCQh0qWKdgo1rPCfvWueM6bDHEIaukJ6HLWdtOq9CqsSw1vRcBSAvvB(DSfPfYhqt7W1Jlsso6c9ebQvvT0)wJljtCuZSL0c5JtyGu7lGR1GKqHEICjq9fhPMuusZSL0ch1QQwwetGO35x8z26OPpButkwqEIKc0h1cUwJvRQAzrmbIENljtCuBg9yYtKuG(O2xaxRfdG6ryhmCQh0qWKdgo1rPCfvakct9GUqprakLr9iSdgo1dAiyYbdN6b6hM5380Wg1d9V14dOPD46XfjjFCcdeW0)wJpGM2HRhxKKCsrj94egiupq)Wm)MNgssIaq5qQhfPEyj8WekuphKeRvD1QWgRwv1MFhBrAH8b00oC94IKKJUqprGAvvllIjq07CjzIJAZOhtEIKc0h1cUwJvRQAjUwIRL4AzrmbIENFXNzRJM(SrnPyb5jskqFuR6Q1GKqHEICXutkkPbWP0v3IuFXrwRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQfuqRL4AzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKlbQV4i1KIsAMTKw4OwIQLOAvvl9V1453rD00MrpMCGO3RLiQJs5kACPim1d6c9ebOug1dlHhMqH6HfXei6D(fFMToA6Zg1KIfKNiPa9rTVulQeY(hQpijwRQAjUwIR9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIKc0h1(c4ATya1QQwwetGO35sYeh1MrpM8ejfOpQvD1AqsOqpr(fhPMuusdGtPRUfPwmRLOAbf0AjU2xv7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO35sYeh1MrpM8ejfOpQvD1AqsOqpr(fhPMuusdGtPRUfPwmRLOAbf0AzrmbIENljtCuBg9yYtKuG(O2xaxRfdOwIOEe2bdN6jfaO4NEykjiuhLYv8DqryQh0f6jcqPmQhwcpmHc1dlIjq07CjzIJAZOhtEIKc0h1(sTOsi7FO(GKyTQQL4AjUwIRLfXei6D(fFMToA6Zg1KIfKNiPa9rTQRwdscf6jYftnPOKgaNsxDls9fhzTQQL(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoPOKECcdKAjQwqbTwIRLfXei6D(fFMToA6Zg1KIfKNiPa9rTGR1y1QQw6FRXLKjoQz2sAH8XjmqQ9fW1AqsOqprUeO(IJutkkPz2sAHJAjQwIQvvT0)wJNFh1rtBg9yYbIEVwIOEe2bdN6jfaO4NEykjiuhLYv04rryQh0f6jcqPmQhwcpmHc1dlIjq07CjzIJAZOhtEIKc0h1cUwJvRQAjUwIRL4AzrmbIENFXNzRJM(SrnPyb5jskqFuR6Q1GKqHEICXutkkPbWP0v3IuFXrwRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQfuqRL4AzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKlbQV4i1KIsAMTKw4OwIQLOAvvl9V1453rD00MrpMCGO3RLiQhHDWWPEaq5SPJ0rQJs5k2XPim1d6c9ebOug1JWoy4upJ4pN4Dq3sNF6UupSeEycfQhIRL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKlbQV4i1KIsAMTKw4OwqbTwZenOTyaCf5Paaf)0dtjbPwIQvvTexlX1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAFbCTwmGAvvllIjq07CjzIJAZOhtEIKc0h1QUAnijuONi)IJutkkPbWP0v3IulM1suTGcATex7RQ9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07CjzIJAZOhtEIKc0h1QUAnijuONi)IJutkkPbWP0v3IulM1suTGcATSiMarVZLKjoQnJEm5jskqFu7lGR1IbulrupUqIupJ4pN4Dq3sNF6UuhLY7GXOim1d6c9ebOug1dlHhMqH6Hfgqx8JBa9ZUBwRQAZVJTiTqUKmXrn0BqhED5Ol0teOwv1YIyce9oNeMzKdD00xKKOF8ejfOpQ9fW1QagJ6ryhmCQNl(mBD00NnQjfli1rP8oOifHPEqxONiaLYOEyj8WekupSWa6IFCdOF2DZAvvB(DSfPfYLKjoQHEd6WRlhDHEIa1QQw6FRXjHzg5qhn9fjj6hprsb6JAFbCTDWy1QQwwetGO35sYeh1MrpM8ejfOpQ9fW1AXaOEe2bdN65IpZwhn9zJAsXcsDukVdDGIWupOl0teGszupSeEycfQhIRL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKlbQV4i1KIsAMTKw4OwqbTwZenOTyaCf5Paaf)0dtjbPwIQvvTexlX1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAFbCTwmGAvvllIjq07CjzIJAZOhtEIKc0h1QUAnijuONi)IJutkkPbWP0v3IulM1suTGcATex7RQ9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07CjzIJAZOhtEIKc0h1QUAnijuONi)IJutkkPbWP0v3IulM1suTGcATSiMarVZLKjoQnJEm5jskqFu7lGR1Ibulrupc7GHt9CXNzRJM(SrnPybPokL3bfMIWupOl0teGszupSeEycfQhIRL4AzrmbIENFXNzRJM(SrnPyb5jskqFuR6Q1GKqHEICXutkkPbWP0v3IuFXrwRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQfuqRL4AzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKlbQV4i1KIsAMTKw4OwIQLOAvvl9V1453rD00MrpMCGO3PEe2bdN6rsM4O2m6XK6OuEhuWueM6bDHEIaukJ6HLWdtOq9q)BnE(DuhnTz0Jjhi69AvvlX1sCTSiMarVZV4ZS1rtF2OMuSG8ejfOpQvD12bJvRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQfuqRL4AzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKlbQV4i1KIsAMTKw4OwIQLOAvvlX1YIyce9oxsM4O2m6XKNiPa9rTQRwf7qTGcATai9V14x8z26OPpButkwq(3SwIOEe2bdN6j)oQJM2m6XK6OuEhuakct9GUqprakLr9Ws4HjuOEyrmbIENljtCuhjnprsb6JAvxTkqTGcATVQ2tMOFCjzIJ6iP5Ol0teG6ryhmCQNHnSDq3sBg9ysDukVdgxkct9GUqprakLr9Ws4HjuOEyHb0f)4G0nHIxRQAZVJTiTqUKmXrTTKKH3LJUqprGAvvl9V14sYeh1MrpM8VzTQQfaP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdKAbxRcUwv1AMObTfdGRixsM4Oos6AvvRWoObuJoscXrTVu77G6ryhmCQhjzIJA6PmoQJs5D4DqryQh0f6jcqPmQhwcpmHc1dlmGU4hhKUju8AvvB(DSfPfYLKjoQTLKm8UC0f6jcuRQAP)TgxsM4O2m6XK)nRvvTai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGul4AvWupc7GHt9ijtCutlzkwi1rP8oy8Oim1d6c9ebOug1dlHhMqH6Hfgqx8Jds3ekETQQn)o2I0c5sYeh12ssgExo6c9ebQvvT0)wJljtCuBg9yY)M1QQwIRfioEkaqXp9Wusq4jskqFuR6Q14wlOGwlas)BnEkaqXp9Wusq0g(thtHgoHxx(3SwIQvvTai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGu7l1QGRvvTc7Ggqn6ijeh1cUwfM6ryhmCQhjzIJA6PmoQJs5DOJtryQh0f6jcqPmQhwcpmHc1dlmGU4hhKUju8AvvB(DSfPfYLKjoQTLKm8UC0f6jcuRQAP)TgxsM4O2m6XK)nRvvTai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGul4AvyQhHDWWPEKKjoQJKM6OuUcBmkct9GUqprakLr9Ws4HjuOEyHb0f)4G0nHIxRQAZVJTiTqUKmXrTTKKH3LJUqprGAvvl9V14sYeh1MrpM8VzTQQfaP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdKAbxBhOEe2bdN6rsM4OMwYuSqQJs5kSIueM6bDHEIaukJ6HLWdtOq9WcdOl(XbPBcfVwv1MFhBrAHCjzIJABjjdVlhDHEIa1QQw6FRXLKjoQnJEm5FZAvvRzIg0wmaEh4Paaf)0dtjbPwv1kSdAa1OJKqCuR6QvHPEe2bdN6rsM4OgvYCgdy4uhLYv4oqryQh0f6jcqPmQhwcpmHc1dlmGU4hhKUju8AvvB(DSfPfYLKjoQTLKm8UC0f6jcuRQAP)TgxsM4O2m6XK)nRvvTai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGul4AvSwv1kSdAa1OJKqCuR6QvHPEe2bdN6rsM4OgvYCgdy4uhLYvyfMIWupOl0teGszupSeEycfQh6FRXbq5SPJ0r(3Swv1cG0)wJFXNzRJM(SrnPyb5FZAvvlas)Bn(fFMToA6Zg1KIfKNiPa9rTVaUw6FRXntCGod1rttcDaoPOKECcdKA7C1kSdgoxsM4OMEkJJJkHS)H6dsI1QQwIRL4ApzI(XtCeU4mKJUqprGAvvRWoObuJoscXrTVuRcUwIQfuqRvyh0aQrhjH4O2xQvbQLOAvvlX1(QAZVJTiTqUKmXrnDqsljaj6hhDHEIa1ckO1EsAHh3gL5zZnzxTQRwfwbQLiQhHDWWPEmtCGod1rttcDaQJs5kScMIWupOl0teGszupSeEycfQh6FRXbq5SPJ0r(3Swv1sCTex7jt0pEIJWfNHC0f6jcuRQAf2bnGA0rsioQ9LAvW1suTGcATc7Ggqn6ijeh1(sTkqTevRQAjU2xvB(DSfPfYLKjoQPdsAjbir)4Ol0teOwqbT2tsl842OmpBUj7QvD1QWkqTer9iSdgo1JKmXrn9ugh1rPCfwbOim1JWoy4upJVjMEyqOEqxONiaLYOokLRWgxkct9GUqprakLr9Ws4HjuOEO)TgxsM4OMzlPfYhNWaPw1bUwIRvyh0aQrhjH4OwJVAvSwIQvvT53XwKwixsM4OMoiPLeGe9JJUqprGAvv7jPfECBuMNn3KD1(sTkScq9iSdgo1JKmXrnTKPyHuhLYv43bfHPEqxONiaLYOEyj8Wekup0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGq9iSdgo1JKmXrnTKPyHuhLYvyJhfHPEqxONiaLYOEyj8Wekup0)wJljtCuZSL0c5JtyGul4AnwTQQL4AzrmbIENljtCuBg9yYtKuG(Ow1vRIkqTGcATVQwIRLfgqx8Jds3ekETQQn)o2I0c5sYeh12ssgExo6c9ebQLOAjI6ryhmCQhjzIJ6iPPokLRWDCkct9GUqprakLr9Ws4HjuOEiU2eBjoSf6jwlOGw7RQ9GmqGUvTevRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaH6ryhmCQhhpBm1hsAIJJ6OuUc2yueM6bDHEIaukJ6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvT53XwKwixsM4O2wsYW7YrxONiqTQQL4AjU2tMOFCH0CcBqMCWW5Ol0teOwv1kSdAa1OJKqCu7l1A8QLOAbf0Af2bnGA0rsioQ9LAvGAjI6ryhmCQhjzIJAs4yaN4G6OuUcwrkct9GUqprakLr9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQ2tMOFCjzIJAKzhC0f6jcuRQAbq6FRXV4ZS1rtF2OMuSG8VzTQQL4ApzI(XfsZjSbzYbdNJUqprGAbf0Af2bnGA0rsioQ9LA741se1JWoy4upsYeh1KWXaoXb1rPCfChOim1d6c9ebOug1dlHhMqH6H(3AC2eLKjJd6w8ef2vRQApzI(XfsZjSbzYbdNJUqprGAvvRWoObuJoscXrTVuRcM6ryhmCQhjzIJAs4yaN4G6OuUcwHPim1d6c9ebOug1dlHhMqH6H(3ACjzIJAMTKwiFCcdKAFPw6FRXLKjoQz2sAHCsrj94egiupc7GHt9ijtCuJkzoJbmCQJs5kyfmfHPEqxONiaLYOEyj8Wekup0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGuRQAnt0G2IbWvKljtCutlzkwi1JWoy4upsYeh1OsMZyadN6OoQhwetGO3hueMs5ksryQh0f6jcqPmQhHDWWPEAzmoThgeQhaCWsO5bdN6PZsyKWdQGeR9pGUvTwjCm7wlKbztS2E4zxRyYR9DpWAHxT9WZU2loYAJZgZE4a5upSeEycfQN87ylslKBLWXSRgYGSjYrxONiqTQQLfXei6DUKmXrTz0Jjprsb6JAvxTkSXQvvTSiMarVZV4ZS1rtF2OMuSG8efGU1QQwIRL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKFXrQjfL0mBjTWrTQQL4AjU2tMOF887OoAAZOhto6c9ebQvvTSiMarVZZVJ6OPnJEm5jskqFu7lGR1IbuRQAzrmbIENljtCuBg9yYtKuG(Ow1vRbjHc9e5xCKAsrjnaoLU6wKAXSwIQfuqRL4AFvTNmr)453rD00MrpMC0f6jcuRQAzrmbIENljtCuBg9yYtKuG(Ow1vRbjHc9e5xCKAsrjnaoLU6wKAXSwIQfuqRLfXei6DUKmXrTz0Jjprsb6JAFbCTwmGAjQwIOokL3bkct9GUqprakLr9Ws4HjuOEYVJTiTqUvchZUAidYMihDHEIa1QQwwetGO35sYeh1MrpM8efGU1QQwIR9v1EYe9JJ(eAzFOJaC0f6jculOGwlX1EYe9JJ(eAzFOJaC0f6jcuRQAjfx4MSRw1bU23HXQLOAjQwv1sCTexllIjq078l(mBD00NnQjfliprsb6JAvxTkASAvvl9V14sYeh1mBjTq(4egi1cUw6FRXLKjoQz2sAHCsrj94egi1suTGcATexllIjq078l(mBD00NnQjfliprsb6JAbxRXQvvT0)wJljtCuZSL0c5JtyGul4AnwTevlr1QQw6FRXZVJ6OPnJEm5arVxRQAjfx4MSRw1bUwdscf6jYftnj0HKFsnP4I2KDupc7GHt90YyCApmiuhLYvykct9GUqprakLr9Ws4HjuOEYVJTiTqoaCWGMtOlzxnlijfhGJUqprGAvvllIjq07C6FRPbGdg0CcDj7QzbjP4a8efGU1QQw6FRXbGdg0CcDj7QzbjP4a6wgJJde9ETQQL4AP)TgxsM4O2m6XKde9ETQQL(3A887OoAAZOhtoq071QQwaK(3A8l(mBD00NnQjflihi69AjQwv1YIyce9o)IpZwhn9zJAsXcYtKuG(OwW1ASAvvlX1s)BnUKmXrnZwslKpoHbsTVaUwdscf6jYV4i1KIsAMTKw4Owv1sCTex7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejfOpQ9fW1AXaQvvTSiMarVZLKjoQnJEm5jskqFuR6Q1GKqHEI8losnPOKgaNsxDlsTywlr1ckO1sCTVQ2tMOF887OoAAZOhto6c9ebQvvTSiMarVZLKjoQnJEm5jskqFuR6Q1GKqHEI8losnPOKgaNsxDlsTywlr1ckO1YIyce9oxsM4O2m6XKNiPa9rTVaUwlgqTevlrupc7GHt90YyC0X8OokLRGPim1d6c9ebOug1dlHhMqH6j)o2I0c5aWbdAoHUKD1SGKuCao6c9ebQvvTSiMarVZP)TMgaoyqZj0LSRMfKKIdWtua6wRQAP)TghaoyqZj0LSRMfKKIdOBWe5arVxRQAnt0G2IbWvK3YyC0X8OEe2bdN6PbtutpLXrDukxbOim1d6c9ebOug1JWoy4upKWmJCOJM(IKe9J6bahSeAEWWPE6mbM12XccxBp8SRTJ6SAHTAHhbJAzbj0TQ9Bw7icNx77Svl8QThoN1sJ1(hiqT9WZUwchxhZOAzY4QfE1oMql7B2TwASfjs9Ws4HjuOEiU2xvB(DSfPfYhqt7W1Jlsso6c9ebQfuqRL(3A8b00oC94IKK)nRLOAvvllIjq078l(mBD00NnQjfliprsb6JAFPwdscf6jYjJtBMidra9fhPMUBTGcATexRbjHc9e5hKe1F)GtTywR6Q1GKqHEICY40KIsAaCkD1Ti1IzTQQLfXei6D(fFMToA6Zg1KIfKNiPa9rTQRwdscf6jYjJttkkPbWP0v3IuFXrwlruhLYnUueM6bDHEIaukJ6HLWdtOq9WIyce9oxsM4O2m6XKNOa0Twv1sCTVQ2tMOFC0Nql7dDeGJUqprGAbf0AjU2tMOFC0Nql7dDeGJUqprGAvvlP4c3KD1QoW1(omwTevlr1QQwIRL4AzrmbIENFXNzRJM(SrnPyb5jskqFuR6Q1GKqHEICXutkkPbWP0v3IuFXrwRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQfuqRL4AzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL(3ACjzIJAMTKwiFCcdKAbxRXQLOAjQwv1s)BnE(DuhnTz0Jjhi69AvvlP4c3KD1QoW1AqsOqprUyQjHoK8tQjfx0MSJ6ryhmCQhsyMro0rtFrsI(rDuk)DqryQh0f6jcqPmQhwcpmHc1JbjHc9e5X)gqauhnnlIjq07JAvvlX1oI)Kg6aCdXuo4e1JyAa9JJUqprGAbf0AhXFsdDaU5FC)jQX8BEWW5Ol0teOwIOEe2bdN6PnXHnlL2rDuk34rryQh0f6jcqPmQhHDWWPEaq5SPJ0rQhaCWsO5bdN6PJM9s3rT)bwlakNnDKowBp8SRvm51(oB1EXrwlCuBIcq3ALrT94CAuTKciyTJFI1ErTmzC1cVAPXwKyTxCKCQhwcpmHc1dlIjq078l(mBD00NnQjfliprbOBTQQL(3ACjzIJAMTKwiFCcdKAFbCTgKek0tKFXrQjfL0mBjTWrTQQLfXei6DUKmXrTz0Jjprsb6JAFbCTwmaQJs5DCkct9GUqprakLr9Ws4HjuOEyrmbIENljtCuBg9yYtua6wRQAjU2xv7jt0po6tOL9HocWrxONiqTGcATex7jt0po6tOL9HocWrxONiqTQQLuCHBYUAvh4AFhgRwIQLOAvvlX1sCTSiMarVZV4ZS1rtF2OMuSG8ejfOpQvD1QOXQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGulr1ckO1sCTSiMarVZV4ZS1rtF2OMuSG8efGU1QQw6FRXLKjoQz2sAH8XjmqQfCTgRwIQLOAvvl9V1453rD00MrpMCGO3RvvTKIlCt2vR6axRbjHc9e5IPMe6qYpPMuCrBYoQhHDWWPEaq5SPJ0rQJs5kAmkct9GUqprakLr9iSdgo1tkaqXp9WusqOEaWblHMhmCQN39aRDykji1cB1EXrwR4a1kM1kjwB41YaQvCGA7dNGRwAS2VzTTiRDgUfM1E2Ix7zJ1skkvlaoLUgvlPac0TQD8tS2ESwBXawRC1orzC1E9rTsYehRLzlPfoQvCGApB5Q9IJS2Ez4eC1A8)hxT)bcWPEyj8WekupSiMarVZV4ZS1rtF2OMuSG8ejfOpQvD1AqsOqprEo0KIsAaCkD1Ti1xCK1QQwwetGO35sYeh1MrpM8ejfOpQvD1AqsOqprEo0KIsAaCkD1Ti1IzTQQL4ApzI(XZVJ6OPnJEm5Ol0teOwv1sCTSiMarVZZVJ6OPnJEm5jskqFu7l1IkHS)H6dsI1ckO1YIyce9op)oQJM2m6XKNiPa9rTQRwdscf6jYZHMuusdGtPRUfPodZAjQwqbT2xv7jt0pE(DuhnTz0JjhDHEIa1suTQQL(3ACjzIJAMTKwiFCcdKAvxTDOwv1cG0)wJFXNzRJM(SrnPyb5arVxRQAP)Tgp)oQJM2m6XKde9ETQQL(3ACjzIJAZOhtoq07uhLYvurkct9GUqprakLr9iSdgo1tkaqXp9WusqOEaWblHMhmCQN39aRDykji12dp7AfZA7TrVwZymG0tKx77Sv7fhzTWrTjkaDRvg12JZPr1skGG1o(jw7f1YKXvl8QLgBrI1EXrYPEyj8WekupSiMarVZV4ZS1rtF2OMuSG8ejfOpQ9LArLq2)q9bjXAvvl9V14sYeh1mBjTq(4egi1(c4AnijuONi)IJutkkPz2sAHJAvvllIjq07CjzIJAZOhtEIKc0h1(sTexlQeY(hQpijw7B1kSdgo)IpZwhn9zJAsXcYrLq2)q9bjXAjI6OuUIDGIWupOl0teGszupSeEycfQhwetGO35sYeh1MrpM8ejfOpQ9LArLq2)q9bjXAvvlX1sCTVQ2tMOFC0Nql7dDeGJUqprGAbf0AjU2tMOFC0Nql7dDeGJUqprGAvvlP4c3KD1QoW1(omwTevlr1QQwIRL4AzrmbIENFXNzRJM(SrnPyb5jskqFuR6Q1GKqHEICXutkkPbWP0v3IuFXrwRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwIQfuqRL4AzrmbIENFXNzRJM(SrnPyb5jskqFul4AnwTQQL(3ACjzIJAMTKwiFCcdKAbxRXQLOAjQwv1s)BnE(DuhnTz0Jjhi69AvvlP4c3KD1QoW1AqsOqprUyQjHoK8tQjfx0MSRwIOEe2bdN6jfaO4NEykjiuhLYvuHPim1d6c9ebOug1JWoy4upJ4pN4Dq3sNF6UupSeEycfQhIR9v1MFhBrAH8b00oC94IKKJUqprGAbf0AP)TgFanTdxpUij5FZAjQwv1s)BnUKmXrnZwslKpoHbsTVaUwdscf6jYV4i1KIsAMTKw4Owv1YIyce9oxsM4O2m6XKNiPa9rTVaUwujK9puFqsSwv1skUWnzxTQRwdscf6jYftnj0HKFsnP4I2KD1QQw6FRXZVJ6OPnJEm5arVt94cjs9mI)CI3bDlD(P7sDukxrfmfHPEqxONiaLYOEe2bdN65IpZwhn9zJAsXcs9aGdwcnpy4upV7bw7fhzT9WZUwXSwyRw4rWO2E4zd9ApBSwsrPAbWP0Lx77SvRhNr1(hyT9WZU2mmRf2Q9SXApzI(vlCu7jGGUr1koqTWJGrT9WZg61E2yTKIs1cGtPlN6HLWdtOq9qCTVQ287ylslKpGM2HRhxKKC0f6jculOGwl9V14dOPD46Xfjj)Bwlr1QQw6FRXLKjoQz2sAH8XjmqQ9fW1AqsOqpr(fhPMuusZSL0ch1QQwwetGO35sYeh1MrpM8ejfOpQ9fW1IkHS)H6dsI1QQwsXfUj7QvD1AqsOqprUyQjHoK8tQjfx0MSRwv1s)BnE(DuhnTz0Jjhi6DQJs5kQaueM6bDHEIaukJ6HLWdtOq9q)BnUKmXrnZwslKpoHbsTVaUwdscf6jYV4i1KIsAMTKw4Owv1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAFbCTOsi7FO(GKyTQQ1GKqHEI8dsI6VFWPwmRvD1AqsOqpr(fhPMuusdGtPRUfPwmPEe2bdN65IpZwhn9zJAsXcsDukxrJlfHPEqxONiaLYOEyj8Wekup0)wJljtCuZSL0c5JtyGu7lGR1GKqHEI8losnPOKMzlPfoQvvTex7RQ9Kj6hp)oQJM2m6XKJUqprGAbf0AzrmbIENNFh1rtBg9yYtKuG(Ow1vRbjHc9e5xCKAsrjnaoLU6wK6mmRLOAvvRbjHc9e5hKe1F)GtTywR6Q1GKqHEI8losnPOKgaNsxDlsTys9iSdgo1ZfFMToA6Zg1KIfK6OuUIVdkct9GUqprakLr9iSdgo1JKmXrTz0Jj1daoyj08GHt98UhyTIzTWwTxCK1ch1gETmGAfhO2(Wj4QLgR9BwBlYANHBHzTNT41E2yTKIs1cGtPRr1skGaDRAh)eR9SLR2ESwBXawl6X3YUwsXLAfhO2ZwUApBmXAHJA94QvMjkaDRvQn)owB0Q1m6XSwGO35upSeEycfQhwetGO35x8z26OPpButkwqEIKc0h1QUAnijuONixm1KIsAaCkD1Ti1xCK1QQwIR9v1YcdOl(XnG(z3nRfuqRLfXei6DojmZih6OPVijr)4jskqFuR6Q1GKqHEICXutkkPbWP0v3IutgxTevRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtkkPhNWaPwv1s)BnE(DuhnTz0Jjhi69AvvlP4c3KD1QoW1AqsOqprUyQjHoK8tQjfx0MSJ6OuUIgpkct9GUqprakLr9iSdgo1t(DuhnTz0Jj1daoyj08GHt98UhyTzywlSv7fhzTWrTHxldOwXbQTpCcUAPXA)M12IS2z4wyw7zlETNnwlPOuTa4u6AuTKciq3Q2XpXApBmXAHdNGRwzMOa0TwP287yTarVxR4a1E2YvRywBF4eC1sJSGeRvmiWPqpXAb(j0TQn)oYPEyj8Wekup0)wJljtCuBg9yYbIEVwv1sCTSiMarVZV4ZS1rtF2OMuSG8ejfOpQvD1AqsOqprEgMAsrjnaoLU6wK6loYAbf0AzrmbIENljtCuBg9yYtKuG(O2xaxRbjHc9e5xCKAsrjnaoLU6wKAXSwIQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjfL0JtyGuRQAzrmbIENljtCuBg9yYtKuG(Ow1vRIgRwv1YIyce9o)IpZwhn9zJAsXcYtKuG(Ow1vRIgJ6OuUIDCkct9GUqprakLr9Ws4HjuOEmijuONip(3acG6OPzrmbIEFq9iSdgo1ZWg2oOBPnJEmPokL3bJrryQh0f6jcqPmQhHDWWPEmtCGod1rttcDaQhaCWsO5bdN65DpWAndYAVO2rN)JOcsSwXRfv6sPwHUwOx7zJ16OsxTSiMarVxBp0bIEJQ97tCmQfKUju8ApB0Rn8z3Ab(j0TQvsM4yTMrpM1c8XAVOw7OVwsXLAT)Uv2T2uaGIF1omLeKAHdQhwcpmHc1Zjt0pE(DuhnTz0JjhDHEIa1QQw6FRXLKjoQnJEm5FZAvvl9V1453rD00MrpM8ejfOpQ9LATyaCsrjQJs5Dqrkct9GUqprakLr9Ws4HjuOEaq6FRXV4ZS1rtF2OMuSG8VzTQQfaP)Tg)IpZwhn9zJAsXcYtKuG(O2xQvyhmCUKmXrnjCmGtCWrLq2)q9bjXAvv7RQLfgqx8Jds3eko1JWoy4upMjoqNH6OPjHoa1rP8o0bkct9GUqprakLr9Ws4HjuOEO)Tgp)oQJM2m6XK)nRvvT0)wJNFh1rtBg9yYtKuG(O2xQ1IbWjfLQvvTSiMarVZrdbtoy48efGU1QQwwetGO35x8z26OPpButkwqEIKc0h1QQ2xvllmGU4hhKUjuCQhHDWWPEmtCGod1rttcDaQJ6OEct0XKIWukxrkct9GUqprakLr9Ws4HjuOEYVJTiTqoaCWGMtOlzxnlijfhGJUqprGAvvl9V14aWbdAoHUKD1SGKuCaDlJXX)Mupc7GHt90GjQPNY4OokL3bkct9GUqprakLr9Ws4HjuOEYVJTiTqUvchZUAidYMihDHEIa1QQwsXfUj7QvD12XvaQhHDWWPEAzmoThgeQJs5kmfHPEqxONiaLYOECHePEgXFoX7GULo)0DPEe2bdN6ze)5eVd6w68t3L6OuUcMIWupc7GHt9aGYzthPJupOl0teGszuhLYvakct9GUqprakLr9Ws4HjuOEifx4MSRw1vRc2yupc7GHt9Kcau8tpmLeeQJs5gxkct9iSdgo1djmZih6OPVijr)OEqxONiaLYOokL)oOim1d6c9ebOug1dlHhMqH6H(3ACjzIJAZOhtoq071QQwwetGO35sYeh1MrpM8ejfOpOEe2bdN6zydBh0T0MrpMuhLYnEueM6bDHEIaukJ6HLWdtOq9WIyce9oxsM4O2m6XKNOa0Twv1s)BnUKmXrnZwslKpoHbsTVul9V14sYeh1mBjTqoPOKECcdeQhHDWWPEKKjoQJKM6OuEhNIWupOl0teGszupSeEycfQhwyaDXpUb0p7UzTQQLfXei6DojmZih6OPVijr)4jskqFuR6Q14PGPEe2bdN6rsM4OMEkJJ6OuUIgJIWupc7GHt9CXNzRJM(SrnPybPEqxONiaLYOokLROIueM6ryhmCQhjzIJAZOhtQh0f6jcqPmQJs5k2bkct9GUqprakLr9Ws4HjuOEO)TgxsM4O2m6XKde9o1JWoy4up53rD00MrpMuhLYvuHPim1d6c9ebOug1JWoy4upMjoqNH6OPjHoa1daoyj08GHt98UhyTDw0XQ9IAhD(pIkiXAfVwuPlLA7OKjowRYMY4Qf4Nq3Q2ZgRLWX1Xiuh1z12dDGOV2VpXXO287o0TQTJsM4yTkOm7Gx77SvBhLmXXAvqz2rTWrTNmr)qaJQThRLjobxT)bwBNfDSA7HNn0R9SXAjCCDmc1rDwT9qhi6R97tCmQThRf6hM538Q9SXA7OowTmBXDCAuTJO2EKG5S2HyaRfECQhwcpmHc1ZRQ9Kj6hxsM4Ogz2bhDHEIa1QQwaK(3A8l(mBD00NnQjfli)BwRQAbq6FRXV4ZS1rtF2OMuSG8ejfOpQ9fW1sCTc7GHZLKjoQPNY44Osi7FO(GKyTDUAP)Tg3mXb6muhnnj0b4KIs6XjmqQLiQJs5kQGPim1d6c9ebOug1JWoy4upMjoqNH6OPjHoa1daoyj08GHt98oB12zrhRwBz4eC1sJOx7FGa1c8tOBv7zJ1s446y12dDGO3OA7rcMZA)dSw4v7f1o68FevqI1kETOsxk12rjtCSwLnLXvl0R9SXAFxrNrOoQZQTh6arpN6HLWdtOq9q)BnUKmXrTz0Jj)BwRQAP)Tgp)oQJM2m6XKNiPa9rTVaUwIRvyhmCUKmXrn9ughhvcz)d1hKeRTZvl9V14MjoqNH6OPjHoaNuuspoHbsTerDukxrfGIWupOl0teGszupSeEycfQhG44Paaf)0dtjbHNiPa9rTQRwfOwqbTwaK(3A8uaGIF6HPKGOn8NoMcnCcVU8XjmqQvD1AmQhHDWWPEKKjoQPNY4OokLROXLIWupOl0teGszupc7GHt9ijtCutlzkwi1daoyj08GHt90rZEP7OwLjzkwyTYv7zJ1IoqTrR2oQZQT3g9AZV7q3Q2ZgRTJsM4yTghljz4DRDIwOdizxQhwcpmHc1d9V14sYeh1MrpM8VzTQQL(3ACjzIJAZOhtEIKc0h1(sTwmGAvvB(DSfPfYLKjoQTLKm8UC0f6jcqDukxX3bfHPEqxONiaLYOEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6PJM9s3rTktYuSWALR2ZgRfDGAJwTNnw77k6SA7Hoq0xBVn61MF3HUvTNnwBhLmXXAnowsYW7w7eTqhqYUupSeEycfQh6FRXZVJ6OPnJEm5FZAvvl9V14sYeh1MrpMCGO3RvvT0)wJNFh1rtBg9yYtKuG(O2xaxRfdOwv1MFhBrAHCjzIJABjjdVlhDHEIauhLYv04rryQh0f6jcqPmQhMTaDQhfPEqjND1mBb6AyJ6H(3AC2eLKjJd6wAMT4oo5arVRIy6FRXLKjoQnJEm5FtqbL4xDYe9JhgW0m6Xeburm9V1453rD00MrpM8VjOGYIyce9ohnem5GHZtua6serer9Ws4HjuOEaq6FRXV4ZS1rtF2OMuSG8VzTQQ9Kj6hxsM4Ogz2bhDHEIa1QQwIRL(3ACauoB6iDKde9ETGcATc7Ggqn6ijeh1cUwfRLOAvvlas)Bn(fFMToA6Zg1KIfKNiPa9rTQRwHDWW5sYeh1KWXaoXbhvcz)d1hKePEe2bdN6rsM4OMeogWjoOokLRyhNIWupOl0teGszupSeEycfQh6FRXztusMmoOBXhNWaPwW1s)BnoBIsYKXbDloPOKECcdKAvvllmGU4h3a6ND3K6ryhmCQhjzIJAs4yaN4G6OuEhmgfHPEqxONiaLYOEe2bdN6rsM4OMeogWjoOEy2c0PEuK6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvTSiMarVZLKjoQnJEm5jskqFuRQAjUw6FRXZVJ6OPnJEm5FZAbf0AP)TgxsM4O2m6XK)nRLiQJs5Dqrkct9GUqprakLr9Ws4HjuOEO)TgxsM4OMzlPfYhNWaP2xaxRbjHc9e5xCKAsrjnZwslCq9iSdgo1JKmXrDK0uhLY7qhOim1d6c9ebOug1dlHhMqH6H(3A887OoAAZOht(3SwqbTwsXfUj7QvD1QOcq9iSdgo1JKmXrn9ugh1rP8oOWueM6bDHEIaukJ6ryhmCQh0qWKdgo1d0pmZV5PHnQhsXfUj7uhyJNcq9a9dZ8BEAijjcaLdPEuK6HLWdtOq9q)BnE(DuhnTz0Jjhi69Avvl9V14sYeh1MrpMCGO3PokL3bfmfHPEe2bdN6rsM4OMwYuSqQh0f6jcqPmQJ6OEAqxMA6F6ueMs5ksryQh0f6jcqPmQhHDWWPEKKjoQjHJbCIdQhMTaDQhfPEyj8Wekup0)wJZMOKmzCq3INOWoQJs5DGIWupc7GHt9ijtCutpLXr9GUqprakLrDukxHPim1JWoy4upsYeh10sMIfs9GUqprakLrDuh1r9yaZbmCkL3bJ1bfnMXtHvK6Pxsh6wdQhJZo6DP83PYnouHQTwcBJ1cjnJ8QTfzTeeMOJjb1MyN)dteO2rqI1k)liLdbQLzlUfo4LAVh6yTkQq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRTdkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAvuHvOAFD4gW8qGAj4Kj6hx9eu7f1sWjt0pU65Ol0teGGAjwrLiIxQ9EOJ1QOXvHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQvUAvqvq8(AjwrLiIxQ9EOJ1Q47qHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQvUAvqvq8(AjwrLiIxQ9EOJ1QOXtHQ91HBaZdbQLGtMOFC1tqTxulbNmr)4QNJUqpracQLyfvIiEPwPMXzh9Uu(7u5ghQq1wlHTXAHKMrE12ISwcAWHn0T0Hj6ysqTj25)WebQDeKyTY)cs5qGAz2IBHdEP27HowRIkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTe3bLiIxQ9EOJ12bfQ2xhUbmpeOwcozI(Xvpb1ErTeCYe9JREo6c9ebiOwIvujI4LAVh6yTkScv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDSwfScv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDSwfqHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowRXvHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQvUAvqvq8(AjwrLiIxQ9EOJ12XvOAFD4gW8qGAji)o2I0c5QNGAVOwcYVJTiTqU65Ol0teGGAjwrLiIxQ9EOJ12XvOAFD4gW8qGAjGfoWhEC1tqTxulbSWb(WJREo6c9ebiOw5QvbvbX7RLyfvIiEP27HowRIDqHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQL4oOer8sT3dDSwfvafQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTkA8uOAFD4gW8qGAji)o2I0c5QNGAVOwcYVJTiTqU65Ol0teGGAjwrLiIxQ9EOJ1QyhxHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowBhuuHQ91HBaZdbQLGtMOFC1tqTxulbNmr)4QNJUqpracQLyfvIiEP27HowBhuWkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTe3bLiIxQ9EOJ12bfScv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeuRC1QGQG491sSIkreVu79qhRTdgxfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOw5QvbvbX7RLyfvIiEP27HowBhEhkuTVoCdyEiqTeCYe9JREcQ9IAj4Kj6hx9C0f6jcqqTeROseXl1k1mo7O3LYFNk34qfQ2AjSnwlK0mYR2wK1sqgNCWWjO2e78FyIa1ocsSw5FbPCiqTmBXTWbVu79qhRvrfQ2xhUbmpeOwcozI(Xvpb1ErTeCYe9JREo6c9ebiOwIvujI4LAVh6yTkQq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRTdkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAvyfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTkGcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXkQer8sT3dDSwJRcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXkQer8sT3dDSwfnMcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXkQer8sT3dDSwf74kuTVoCdyEiqTeCYe9JREcQ9IAj4Kj6hx9C0f6jcqqTeROseXl1Ep0XAvSJRq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRTdgtHQ91HBaZdbQLGtMOFC1tqTxulbNmr)4QNJUqpracQLyfvIiEP27HowBhmMcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDS2oOOcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXkQer8sT3dDS2oOOcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDS2o0bfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTDqHvOAFD4gW8qGAji)o2I0c5QNGAVOwcYVJTiTqU65Ol0teGGAjwrLiIxQvQzC2rVlL)ovUXHkuT1syBSwiPzKxTTiRLaaSj)5rqTj25)WebQDeKyTY)cs5qGAz2IBHdEP27HowBhuOAFD4gW8qGAj4Kj6hx9eu7f1sWjt0pU65Ol0teGGAjUdkreVu79qhRvbRq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRvrfScv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDSwfnUkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAv04Pq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRTdgtHQ91HBaZdbQ9bs(6AhD9tuQwJdO2lQ99FPwaOb4agETHjMYfzTetiIQLyfvIiEP27HowBhmMcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDS2o0bfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOw5QvbvbX7RLyfvIiEP27HowBhuyfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTDqbRq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRTdkGcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDS2oyCvOAFD4gW8qGAji)o2I0c5QNGAVOwcYVJTiTqU65Ol0teGGAjwrLiIxQ9EOJ12H3Hcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sTsnJZo6DP83PYnouHQTwcBJ1cjnJ8QTfzTeyMiliPLJGAtSZ)Hjcu7iiXAL)fKYHa1YSf3ch8sT3dDSwfqHQ91HBaZdbQLGr8N0qhGREcQ9IAjye)jn0b4QNJUqpracQLyfvIiEP27HowRcOq1(6WnG5Ha1sWi(tAOdWvpb1ErTemI)Kg6aC1ZrxONiab1kxTkOkiEFTeROseXl1Ep0XAnUkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAnUkuTVoCdyEiqTeWch4dpU6jO2lQLaw4aF4XvphDHEIaeulXkQer8sT3dDS23Hcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeuRC1QGQG491sSIkreVu79qhR14Pq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRTJRq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVuRuZ4SJExk)DQCJdvOARLW2yTqsZiVABrwlbsGeuBID(pmrGAhbjwR8VGuoeOwMT4w4GxQ9EOJ1QOcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXDqjI4LAVh6yTkQq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRTdkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTe3bLiIxQ9EOJ1QWkuTVoCdyEiqTeCYe9JREcQ9IAj4Kj6hx9C0f6jcqqTe3bLiIxQ9EOJ1QWkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAvWkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAvafQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTgxfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTVdfQ2xhUbmpeOwcozI(Xvpb1ErTeCYe9JREo6c9ebiOwIvujI4LAVh6yTgpfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTDCfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTkAmfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTkQOcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDSwf7Gcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXDqjI4LAVh6yTkQWkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAvubRq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRvrfqHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowRIgxfQ2xhUbmpeOwcozI(Xvpb1ErTeCYe9JREo6c9ebiOwI7GseXl1Ep0XAvSJRq1(6WnG5Ha1sWjt0pU6jO2lQLGtMOFC1ZrxONiab1sChuIiEP27HowBhmMcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDS2oOOcv7Rd3aMhculb53XwKwix9eu7f1sq(DSfPfYvphDHEIaeulXkQer8sT3dDS2o0bfQ2xhUbmpeOwcozI(Xvpb1ErTeCYe9JREo6c9ebiOwI7GseXl1Ep0XA7GcOq1(6WnG5Ha1sWjt0pU6jO2lQLGtMOFC1ZrxONiab1kxTkOkiEFTeROseXl1Ep0XA7GXvHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowBhEhkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XA7GXtHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowBh64kuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XAvyJPq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRvHvuHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowRc3bfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTkScRq1(6WnG5Ha1sWjt0pU6jO2lQLGtMOFC1ZrxONiab1sSIkreVu79qhRvHvyfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTkScwHQ91HBaZdbQLGtMOFC1tqTxulbNmr)4QNJUqpracQLyfvIiEP27HowRcRGvOAFD4gW8qGAji)o2I0c5QNGAVOwcYVJTiTqU65Ol0teGGAjwrLiIxQ9EOJ1QWgxfQ2xhUbmpeOwcYVJTiTqU6jO2lQLG87ylslKREo6c9ebiOwIvujI4LAVh6yTkSXtHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowRc2ykuTVoCdyEiqTeCYe9JREcQ9IAj4Kj6hx9C0f6jcqqTeROseXl1Ep0XAvWgtHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowRcwrfQ2xhUbmpeOwcozI(Xvpb1ErTeCYe9JREo6c9ebiOwI7GseXl1Ep0XAvWDqHQ91HBaZdbQLGtMOFC1tqTxulbNmr)4QNJUqpracQLyfvIiEPwPMXzh9Uu(7u5ghQq1wlHTXAHKMrE12ISwcSLKm8UeuBID(pmrGAhbjwR8VGuoeOwMT4w4GxQ9EOJ1QOcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXkQer8sT3dDSwJRcv7Rd3aMhculbxcDqWJl0molIjq07eu7f1salIjq07CHMrqTe3bLiIxQ9EOJ1(ouOAFD4gW8qGAj4sOdcECHMXzrmbIENGAVOwcyrmbIENl0mcQL4oOer8sT3dDS2oUcv7Rd3aMhculbSWb(WJREcQ9IAjGfoWhEC1ZrxONiab1sSIkreVu79qhRvrfwHQ91HBaZdbQLaw4aF4Xvpb1ErTeWch4dpU65Ol0teGGAjwrLiIxQ9EOJ1QOcwHQ91HBaZdbQLaw4aF4Xvpb1ErTeWch4dpU65Ol0teGGAjwrLiIxQ9EOJ1QOcOq1(6WnG5Ha1sWjt0pU6jO2lQLGtMOFC1ZrxONiab1sSIkreVu79qhRvrfqHQ91HBaZdbQLaw4aF4Xvpb1ErTeWch4dpU65Ol0teGGAjwrLiIxQ9EOJ12bfvOAFD4gW8qGAjGfoWhEC1tqTxulbSWb(WJREo6c9ebiOwIvujI4LALAgND07s5VtLBCOcvBTe2gRfsAg5vBlYAjGfXei69bb1MyN)dteO2rqI1k)liLdbQLzlUfo4LAVh6yTkQq1(6WnG5Ha1sWjt0pU6jO2lQLGtMOFC1ZrxONiab1sChuIiEP27HowRIkuTVoCdyEiqTeKFhBrAHC1tqTxulb53XwKwix9C0f6jcqqTeROseXl1Ep0XA7Gcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXDqjI4LAVh6yTDqHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowRcRq1(6WnG5Ha1sWjt0pU6jO2lQLGtMOFC1ZrxONiab1sChuIiEP27HowRcRq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRvbRq1(6WnG5Ha1sq(DSfPfYvpb1ErTeKFhBrAHC1ZrxONiab1sSIkreVu79qhRvbuOAFD4gW8qGAji)o2I0c5QNGAVOwcYVJTiTqU65Ol0teGGAjwrLiIxQ9EOJ1ACvOAFD4gW8qGAj4Kj6hx9eu7f1sWjt0pU65Ol0teGGAjUdkreVu79qhR9DOq1(6WnG5Ha1sWi(tAOdWvpb1ErTemI)Kg6aC1ZrxONiab1sChuIiEP27HowBhxHQ91HBaZdbQLGtMOFC1tqTxulbNmr)4QNJUqpracQL4oOer8sT3dDSwfnMcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXDqjI4LAVh6yTk2bfQ2xhUbmpeOwcozI(Xvpb1ErTeCYe9JREo6c9ebiOwI7GseXl1Ep0XAvuHvOAFD4gW8qGAji)o2I0c5QNGAVOwcYVJTiTqU65Ol0teGGAjwrLiIxQ9EOJ1QOcwHQ91HBaZdbQLG87ylslKREcQ9IAji)o2I0c5QNJUqpracQLyfvIiEP27HowRIkGcv7Rd3aMhculbNmr)4QNGAVOwcozI(XvphDHEIaeulXkQer8sT3dDSwfnUkuTVoCdyEiqTeCYe9JREcQ9IAj4Kj6hx9C0f6jcqqTeROseXl1Ep0XA7GXuOAFD4gW8qGAj4Kj6hx9eu7f1sWjt0pU65Ol0teGGAjwrLiIxQvQ9ojnJ8qGA741kSdgETt44g8snQh5F2rs98aj)t5GH)6uAh1Jzgn4ePE6uNQTJjwyTDuYehl16uNQv5HbKKgZAvuHnQ2oySoOyPwPwN6uTV2wClCOqLADQt1A8v77EG1EDnHmzw7dK811AloWe6w1gTAz2I74SwOFyMFZdgETqFCOauB0QLaM4mCQf2bdNaEPwN6uTgF1(ABXTWALKjoQHEd6WRBTxuRKmXrTTKKH3TwIHxToAaZA7r)QDcnG1kJALKjoQTLKm8UeXl16uNQ14RwJJcNGRwfudbtoSwOxBhPGqbTwJ))4QLgzYFG12n(eKyTX)QnA1MIBH1koqTEC1(hq3Q2okzIJ1QGQK5mgWW5LADQt1A8vBhby8)hxTMjms41T2lQ9pWA7OKjowBNf9ysWOwS1q2bnG1YIyce9ET0YabQn8AFTXrVRAXwdz3GxQ1PovRXxTV7bw74si7Q1mdgogq3Q2lQnrGpdR91D27U2dsI1c8XAVO2V7idhdj7wBh1zVV2wKGm4LADQt1A8vBhlmGa1AqsOqpXbHyYK9NYbdFu7f1((Vulza8NyTxuBIaFgw7R7S3DThKe5LALAc7GHp4MjYcsA5EdmHKKjoQH(HZjYUsnHDWWhCZezbjTCVbMqsYeh1nHeoHswQjSdg(GBMiliPL7nWeIfUX)prnP4I2cjl16uNQvyhm8b3mrwqsl3BGjKbjHc9enYfseSeO(K0cpnl((zuycoXbEgbGn5ppWkCPwN6uTc7GHp4MjYcsA5EdmHmijuONOrUqIGrdH2KDgfMGtCGNrayt(ZdSIkqPwN6uTc7GHp4MjYcsA5EdmHmijuONOrUqIGnt08pNA0qyuycEGNrWgyIZVJTiTq(aAAhUECrsQIywyaDXpUb0p7UjOGYcdOl(XDKLXmsaqbLfoWhECjzIJAZmaGwDjIiJmiZpcwrJmiZpQX5abBSsTo1PAf2bdFWntKfK0Y9gyczqsOqprJCHebBlgqDyIocyuycEGNrWgyHDqdOgDKeId1b2GKqHEICjq9jPfEAw89ZidY8JGv0idY8JACoqWgRuRtDQwHDWWhCZezbjTCVbMqgKek0t0ixirWnOltn9pDJctWd8mYGm)iyJvQ1PovRWoy4dUzISGKwU3atidscf6jAKlKiyBjjdVRECcde9bjrJctWjoWZiaSj)5bUJxQ1PovRWoy4dUzISGKwU3atidscf6jAKlKiyz2lDh6rxNPzrmbIEFyuycoXbEgbGn5ppWgRuRtDQwHDWWhCZezbjTCVbMqgKek0t0ixirW5qtkkPbWP0v3IuFXrAuycoXbEgbGn5ppWkqPwN6uTc7GHp4MjYcsA5EdmHmijuONOrUqIGZHMuusdGtPRUfPodtJctWjoWZiaSj)5bwbk16uNQvyhm8b3mrwqsl3BGjKbjHc9enYfseCo0KIsAaCkD1Ti1IPrHj4eh4zea2K)8a3bJvQ1PovRWoy4dUzISGKwU3atidscf6jAKlKiyY40MjYqeqFXrQP7AuycoXbEgbGn5ppWgVsTo1PAf2bdFWntKfK0Y9gyczqsOqprJCHebtgNMuusdGtPRUfP(IJ0OWeCId8mcaBYFEGv0yLADQt1kSdg(GBMiliPL7nWeYGKqHEIg5cjcMmonPOKgaNsxDlsTyAuycoXbEgbGn5ppWkQaLADQt1kSdg(GBMiliPL7nWeYGKqHEIg5cjcwm1KIsAaCkD1Ti1xCKgfMGtCGNrWgyw4aF4XLKjoQnZaaA11idY8JGvyJzKbz(rnohiyfnwPwN6uTc7GHp4MjYcsA5EdmHmijuONOrUqIGftnPOKgaNsxDls9fhPrHj4eh4zea2K)8a3bJvQ1PovRWoy4dUzISGKwU3atidscf6jAKlKiyXutkkPbWP0v3IutgNrHj4eh4zea2K)8a3bJvQ1PovRWoy4dUzISGKwU3atidscf6jAKlKi4mm1KIsAaCkD1Ti1xCKgfMGh4zKbz(rWDWygFeRaDow4aF4XLKjoQnZaaA1LOsTo1PAf2bdFWntKfK0Y9gyczqsOqprJCHebFXrQjfL0a4u6QBrQftJctWd8mYGm)iyf4ToySohXSWa6IFChAzF6MGGckXSWb(WJljtCuBMba0QRkHDqdOgDKeIJxmijuONixcuFsAHNMfF)iIO3uub6CeZcdOl(XbPBcfxv(DSfPfYLKjoQTLKm8UQe2bnGA0rsiouhydscf6jYLa1NKw4PzX3pIk16uNQvyhm8b3mrwqsl3BGjKbjHc9enYfse8fhPMuusdGtPRUfPodtJctWd8mYGm)i4oymJpInEDow4aF4XLKjoQnZaaA1LOsTo1PAf2bdFWntKfK0Y9gyczqsOqprJCHebtlzkwOMuCrBYoJctWd8mc2aZcdOl(XDOL9PBcAKbz(rWgxJz8rmPmom7QniZp25u0ygJOsTo1PAf2bdFWntKfK0Y9gyczqsOqprJCHebtlzkwOMuCrBYoJctWd8mc2aZcdOl(XbPBcf3idY8JG74kGXhXKY4WSR2Gm)yNtrJzmIk16uNQvyhm8b3mrwqsl3BGjKbjHc9enYfsemTKPyHAsXfTj7mkmbpWZiydSbjHc9e50sMIfQjfx0MSdSXmYGm)iyJNXm(iMughMD1gK5h7CkAmJruPwN6uTc7GHp4MjYcsA5EdmHmijuONOrUqIGftnj0HKFsnP4I2KDgfMGtCGNrayt(ZdSIkqPwN6uTc7GHp4MjYcsA5EdmHmijuONOrUqIGV4i1KIsAMTKw4WOWeCId8mcaBYFEG7qPwN6uTc7GHp4MjYcsA5EdmHmijuONOrUqIGLa1xCKAsrjnZwslCyuycoXbEgbGn5ppWDOuRtDQwHDWWhCZezbjTCVbMqgKek0t0ixirWn4Wg6w6WeDmnkmbpWZidY8JGvSZrm25)qtteGJKMDtuM6ibCXziOGs8jt0pE(DuhnTz0JPkIpzI(XLKjoQrMDakOVIfgqx8Jds3ekorQi(vSWa6IFChzzmJeauqf2bnGA0rsioaRiOGMFhBrAH8b00oC94IKKivVIfgqx8JBa9ZUBserLADQt1kSdg(GBMiliPL7nWeYGKqHEIg5cjcwm1HR)d0OWe8apJmiZpcg78FOPjcWjfMqNOEyJ4Pj)diduqXo)hAAIaCRPaaLlYHMwaSqqbf78FOPjcWTMcauUihAseqMty4Gck25)qtteGdijiKr4AaKbI28FjoyOZqqbf78FOPjcWH(GL)tONOUZ)f)(KAa0aKHGck25)qtteGpI)CI3bDlD(P7ckOyN)dnnra(470Zia0cjE2DhhOGID(p00eb49ciOJ5q3YWbafuSZ)HMMiaVnfsuhnnTC3el1e2bdFWntKfK0Y9gycrcZmsnKuSWsnHDWWhCZezbjTCVbMqTjoSzP0oJGnWJ4pPHoa3qmLdor9iMgq)af0r8N0qhGB(h3FIAm)Mhm8snHDWWhCZezbjTCVbMq53rD00MrpMgbBGzHb0f)4G0nHIRk)o2I0c5sYeh12ssgExvSWb(WJljtCuBMba0QRkdscf6jYLzV0DOhDDMMfXei69HkHDqdOgDKeIJxmijuONixcuFsAHNMfF)k1e2bdFWntKfK0Y9gyc1YyC0X8mc2a)kdscf6jYnt08pNA0qawrv53XwKwihaoyqZj0LSRMfKKIduQjSdg(GBMiliPL7nWessM4OMEkJZiyd8RmijuONi3mrZ)CQrdbyfv9Q87ylslKdahmO5e6s2vZcssXbur8RyHb0f)4gq)S7MGcQbjHc9e5n4Wg6w6WeDmjQutyhm8b3mrwqsl3BGjejmZih6OPVijr)mc2a)kdscf6jYnt08pNA0qawrvVk)o2I0c5aWbdAoHUKD1SGKuCavSWa6IFCdOF2DtvVYGKqHEI8gCydDlDyIoMLAc7GHp4MjYcsA5EdmHqdbtoy4gbBGnijuONi3mrZ)CQrdbyfl1k1e2bdF8gycXIVFyomX5Sutyhm8XBGj0FGAsXfTfsAeSbM4tMOFC0Nql7dDeqfP4c3KDVa24zmvKIlCt2PoWgxfGiqbL4xDYe9JJ(eAzFOJaQifx4MS7fWgpfGOsnHDWWhVbMqMXbd3iydm9V14sYeh1MrpM8VzPMWoy4J3atOdsI6Ejnnc2aNFhBrAH8djnJuM6Ejnvr)BnoQKT8hhmC(3ufXSiMarVZLKjoQnJEm5jkaDbfu6ymu1Gw2Norsb6JxaRGngrLAc7GHpEdmHMql7BOn()awKOFgbBGP)TgxsM4O2m6XKde9Uk6FRXZVJ6OPnJEm5arVRcaP)Tg)IpZwhn9zJAsXcYbIEVutyhm8XBGjeTyPJM(sidKHrWgy6FRXLKjoQnJEm5arVRI(3A887OoAAZOhtoq07Qaq6FRXV4ZS1rtF2OMuSGCGO3l1e2bdF8gycrJ5atqGULrWgy6FRXLKjoQnJEm5FZsnHDWWhVbMq0Zia0TF21iydm9V14sYeh1MrpM8VzPMWoy4J3atOgmr6zeagbBGP)TgxsM4O2m6XK)nl1e2bdF8gycjodhxktntMtJGnW0)wJljtCuBg9yY)MLAc7GHpEdmH(dudpKCyeSbM(3ACjzIJAZOht(3Sutyhm8XBGj0FGA4HKgHTgYoTlKiyRPaaLlYHMwaSqJGnW0)wJljtCuBg9yY)MGcklIjq07CjzIJAZOhtEIKc0hQdScOaQaq6FRXV4ZS1rtF2OMuSG8VzPMWoy4J3atO)a1WdjnYfsemsA2nrzQJeWfNHgbBGzrmbIENljtCuBg9yYtKuG(4fWkQaQyrmbIENFXNzRJM(SrnPyb5jskqF8cyfvGsnHDWWhVbMq)bQHhsAKlKiyGefGgmrTbCmWPrWgywetGO35sYeh1MrpM8ejfOpuh4oymqb9vgKek0tKlM6W1)bcwrqbL4dsIGnMkdscf6jYBWHn0T0Hj6ycwrv53XwKwiFanTdxpUijjQutyhm8XBGj0FGA4HKg5cjcEe)PgA5WdtJGnWSiMarVZLKjoQnJEm5jskqFOoWkSXaf0xzqsOqprUyQdx)hiyfl1e2bdF8gyc9hOgEiPrUqIGTMDnT1rtlJbKeoLdgUrWgywetGO35sYeh1MrpM8ejfOpuh4oymqb9vgKek0tKlM6W1)bcwrqbL4dsIGnMkdscf6jYBWHn0T0Hj6ycwrv53XwKwiFanTdxpUijjQutyhm8XBGj0FGA4HKg5cjcMuycDI6HnINM8pGmJGnWSiMarVZLKjoQnJEm5jskqF8cyfqfXVYGKqHEI8gCydDlDyIoMGveuqpijQof2yevQjSdg(4nWe6pqn8qsJCHebtkmHor9WgXtt(hqMrWgywetGO35sYeh1MrpM8ejfOpEbScOYGKqHEI8gCydDlDyIoMGvuf9V1453rD00MrpM8VPk6FRXZVJ6OPnJEm5jskqF8cyIv0ygFkqNl)o2I0c5dOPD46XfjjrQoij(IcBSsnHDWWhVbMq)bQHhsAKlKi4HTae9iGosAD00xKKOFgbBGpijc2yGckXgKek0tKh)BabqD00SiMarVpurmXSWa6IFCq6MqXvXIyce9opfaO4NEykji8ejfOpEbChuXIyce9oxsM4O2m6XKNiPa9XlGvavSiMarVZV4ZS1rtF2OMuSG8ejfOpEbScqeOGYIyce9oxsM4O2m6XKNiPa9XlG7aOG2Gw2Norsb6JxyrmbIENljtCuBg9yYtKuG(GiIk16uTka34wlCu7zJ1omreO2Ov7zJ1(e)5eVd6w1(U(0DR1mdJFKDWjwQjSdg(4nWe6pqn8qsJCHebpI)CI3bDlD(P7AeSbMydscf6jYpijQ)(bNAX8nIf2bdNNcau8tpmLeeoQeY(hQpij25yHb0f)4G0nHIt0BelSdgohaLZMosh5Osi7FO(GKyNJfgqx8J7ilJzKae9MWoy48l(mBD00NnQjflihvcz)d1hKeF5K0cpoaCCIZqJdqb4gxIurSbjHc9e52IbuhMOJaGckXSWa6IFCq6MqXvLFhBrAHCjzIJAO3Go86serQojTWJdahN4muDDqbk16uNQvyhm8XBGjKJ9T47a6ehX0aA0FG6EB4e1mzCq3cSIgbBGP)TgxsM4O2m6XK)nbfuaK(3A8l(mBD00NnQjfli)BckOaXXtbak(PhMscc)GmqGUvPwN6uTc7GHpEdmHyYCQf2bdxpHJZixirWmzY(t5GHpk1e2bdF8gycXK5ulSdgUEchNrUqIGLanACjKDGv0iydSWoObuJoscXH6aBqsOqprUeO(K0cpnl((vQjSdg(4nWeIjZPwyhmC9eooJCHebBljz4DnACjKDGv0iydmlmGU4hhKUjuCv53XwKwixsM4O2wsYW7wQjSdg(4nWeIjZPwyhmC9eooJCHeb3GdBOBPdt0X0OXLq2bwrJGnWgKek0tKBlgqDyIoca2yQmijuONiVbh2q3shMOJPQxrmlmGU4hhKUjuCv53XwKwixsM4O2wsYW7suPMWoy4J3atiMmNAHDWW1t44mYfseCyIoMgnUeYoWkAeSb2GKqHEICBXaQdt0raWgt1RiMfgqx8Jds3ekUQ87ylslKljtCuBljz4DjQutyhm8XBGjetMtTWoy46jCCg5cjcMfXei69HrJlHSdSIgbBGFfXSWa6IFCq6MqXvLFhBrAHCjzIJABjjdVlrLAc7GHpEdmHyYCQf2bdxpHJZixirWzCYbd3OXLq2bwrJGnWgKek0tK3GUm10)0bBmvVIywyaDXpoiDtO4QYVJTiTqUKmXrTTKKH3LOsnHDWWhVbMqmzo1c7GHRNWXzKlKi4g0LPM(NUrJlHSdSIgbBGnijuONiVbDzQP)PdwrvVIywyaDXpoiDtO4QYVJTiTqUKmXrTTKKH3LOsTsnHDWWhCjqWTmghDmpJGnW53XwKwihaoyqZj0LSRMfKKIdOIfXei6Do9V10aWbdAoHUKD1SGKuCaEIcqxv0)wJdahmO5e6s2vZcssXb0Tmghhi6Dvet)BnUKmXrTz0Jjhi6Dv0)wJNFh1rtBg9yYbIExfas)Bn(fFMToA6Zg1KIfKde9orQyrmbIENFXNzRJM(SrnPyb5jskqFa2yQiM(3ACjzIJAMTKwiFCcdKxaBqsOqprUeO(IJutkkPz2sAHdvet8jt0pE(DuhnTz0JPkwetGO3553rD00MrpM8ejfOpEbSfdqflIjq07CjzIJAZOhtEIKc0hQZGKqHEI8losnPOKgaNsxDlsTyseOGs8RozI(XZVJ6OPnJEmvXIyce9oxsM4O2m6XKNiPa9H6mijuONi)IJutkkPbWP0v3IulMebkOSiMarVZLKjoQnJEm5jskqF8cylgarevQjSdg(Glb(gyc1GjQPNY4mc2atC(DSfPfYbGdg0CcDj7QzbjP4aQyrmbIENt)BnnaCWGMtOlzxnlijfhGNOa0vf9V14aWbdAoHUKD1SGKuCaDdMihi6DvMjAqBXa4kYBzmo6yEebkOeNFhBrAHCa4GbnNqxYUAwqskoGQdsIGngrLAc7GHp4sGVbMqTmgN2ddIrWg487ylslKBLWXSRgYGSjQIfXei6DUKmXrTz0Jjprsb6d1PWgtflIjq078l(mBD00NnQjfliprsb6dWgtfX0)wJljtCuZSL0c5JtyG8cydscf6jYLa1xCKAsrjnZwslCOIyIpzI(XZVJ6OPnJEmvXIyce9op)oQJM2m6XKNiPa9XlGTyaQyrmbIENljtCuBg9yYtKuG(qDgKek0tKFXrQjfL0a4u6QBrQftIafuIF1jt0pE(DuhnTz0JPkwetGO35sYeh1MrpM8ejfOpuNbjHc9e5xCKAsrjnaoLU6wKAXKiqbLfXei6DUKmXrTz0Jjprsb6JxaBXaiIOsnHDWWhCjW3atOwgJt7HbXiydC(DSfPfYTs4y2vdzq2evXIyce9oxsM4O2m6XKNiPa9byJPIyIjMfXei6D(fFMToA6Zg1KIfKNiPa9H6mijuONixm1KIsAaCkD1Ti1xCKQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoPOKECcdeIafuIzrmbIENFXNzRJM(SrnPyb5jskqFa2yQO)TgxsM4OMzlPfYhNWa5fWgKek0tKlbQV4i1KIsAMTKw4GiIur)BnE(DuhnTz0Jjhi6DIk1e2bdFWLaFdmHKKjoQjHJbCIdJGnWSWa6IFCq6MqXvLFhBrAHCjzIJABjjdVRk6FRXLKjoQTLKm8U8XjmqErrfqflIjq078uaGIF6HPKGWtKuG(4fWgKek0tKBljz4D1JtyGOpij(gQeY(hQpijQIfXei6D(fFMToA6Zg1KIfKNiPa9XlGnijuONi3wsYW7QhNWarFqs8nujK9puFqs8nHDWW5Paaf)0dtjbHJkHS)H6dsIQyrmbIENljtCuBg9yYtKuG(4fWgKek0tKBljz4D1JtyGOpij(gQeY(hQpij(MWoy48uaGIF6HPKGWrLq2)q9bjX3e2bdNFXNzRJM(SrnPyb5Osi7FO(GKOrmBb6GvSutyhm8bxc8nWessM4OMeogWjomc2aZcdOl(XnG(z3nvLFhBrAHCjzIJAO3Go86QI(3ACjzIJABjjdVlFCcdKxuubuXIyce9o)IpZwhn9zJAsXcYtKuG(4fWgKek0tKBljz4D1JtyGOpij(gQeY(hQpijQIfXei6DUKmXrTz0Jjprsb6JxaBqsOqprUTKKH3vpoHbI(GK4BOsi7FO(GK4Bc7GHZV4ZS1rtF2OMuSGCujK9puFqs0iMTaDWkwQjSdg(Glb(gycjjtCutpLXzeSbMfgqx8JBa9ZUBQ6Kj6hxsM4Ogz2HQdsIVOOXuXIyce9oNeMzKdD00xKKOF8ejfOpur)BnoBIsYKXbDl(4egiVOWLAc7GHp4sGVbMq)bQHhsAKlKi4r8Nt8oOBPZpDxJGnW53XwKwiFanTdxpUijvzMObTfdGRihnem5GHxQjSdg(Glb(gycDXNzRJM(SrnPybnc2aNFhBrAH8b00oC94IKuLzIg0wmaUIC0qWKdgEPMWoy4dUe4BGjKKmXrTz0JPrWg487ylslKpGM2HRhxKKQi2mrdAlgaxroAiyYbdhuqnt0G2IbWvKFXNzRJM(SrnPybjQutyhm8bxc8nWeIeMzKdD00xKKOFgbBGZVJTiTqUKmXrn0BqhEDvXIyce9o)IpZwhn9zJAsXcYtKuG(4fWkAmvSiMarVZLKjoQnJEm5jskqF8cyfvGsnHDWWhCjW3atisyMro0rtFrsI(zeSbMfXei6DUKmXrTz0Jjprsb6JxaB8uXIyce9o)IpZwhn9zJAsXcYtKuG(4fWgpvet)BnUKmXrnZwslKpoHbYlGnijuONixcuFXrQjfL0mBjTWHkIj(Kj6hp)oQJM2m6XuflIjq07887OoAAZOhtEIKc0hVa2IbOIfXei6DUKmXrTz0Jjprsb6d1PaebkOe)QtMOF887OoAAZOhtvSiMarVZLKjoQnJEm5jskqFOofGiqbLfXei6DUKmXrTz0Jjprsb6JxaBXaiIOsnHDWWhCjW3ati0qWKdgUrWg4dsIQtHnMQ87ylslKpGM2HRhxKKQyHb0f)4gq)S7MQmt0G2IbWvKtcZmYHoA6lss0VsnHDWWhCjW3ati0qWKdgUrWg4dsIQtHnMQ87ylslKpGM2HRhxKKQO)TgxsM4OMzlPfYhNWa5fWgKek0tKlbQV4i1KIsAMTKw4qflIjq078l(mBD00NnQjfliprsb6dWgtflIjq07CjzIJAZOhtEIKc0hVa2IbuQjSdg(Glb(gycHgcMCWWnc2aFqsuDkSXuLFhBrAH8b00oC94IKuflIjq07CjzIJAZOhtEIKc0hGnMkIjMywetGO35x8z26OPpButkwqEIKc0hQZGKqHEICXutkkPbWP0v3IuFXrQI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5KIs6XjmqicuqjMfXei6D(fFMToA6Zg1KIfKNiPa9byJPI(3ACjzIJAMTKwiFCcdKxaBqsOqprUeO(IJutkkPz2sAHdIisf9V1453rD00MrpMCGO3jYiOFyMFZtdBGP)TgFanTdxpUij5JtyGaM(3A8b00oC94IKKtkkPhNWaXiOFyMFZtdjjraOCiyfl1e2bdFWLaFdmHsbak(PhMscIrWgywetGO35x8z26OPpButkwqEIKc0hVGkHS)H6dsIQiM4tMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jskqF8cylgGkwetGO35sYeh1MrpM8ejfOpuNbjHc9e5xCKAsrjnaoLU6wKAXKiqbL4xDYe9JNFh1rtBg9yQIfXei6DUKmXrTz0Jjprsb6d1zqsOqpr(fhPMuusdGtPRUfPwmjcuqzrmbIENljtCuBg9yYtKuG(4fWwmaIk1e2bdFWLaFdmHsbak(PhMscIrWgywetGO35sYeh1MrpM8ejfOpEbvcz)d1hKevrmXeZIyce9o)IpZwhn9zJAsXcYtKuG(qDgKek0tKlMAsrjnaoLU6wK6losv0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNuuspoHbcrGckXSiMarVZV4ZS1rtF2OMuSG8ejfOpaBmv0)wJljtCuZSL0c5JtyG8cydscf6jYLa1xCKAsrjnZwslCqerQO)Tgp)oQJM2m6XKde9orLAc7GHp4sGVbMqaOC20r6OrWgywetGO35sYeh1MrpM8ejfOpaBmvetmXSiMarVZV4ZS1rtF2OMuSG8ejfOpuNbjHc9e5IPMuusdGtPRUfP(IJuf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGqeOGsmlIjq078l(mBD00NnQjfliprsb6dWgtf9V14sYeh1mBjTq(4egiVa2GKqHEICjq9fhPMuusZSL0cherKk6FRXZVJ6OPnJEm5arVtuPMWoy4dUe4BGj0FGA4HKg5cjcEe)5eVd6w68t31iydmX0)wJljtCuZSL0c5JtyG8cydscf6jYLa1xCKAsrjnZwslCakOMjAqBXa4kYtbak(PhMsccrQiM4tMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jskqF8cylgGkwetGO35sYeh1MrpM8ejfOpuNbjHc9e5xCKAsrjnaoLU6wKAXKiqbL4xDYe9JNFh1rtBg9yQIfXei6DUKmXrTz0Jjprsb6d1zqsOqpr(fhPMuusdGtPRUfPwmjcuqzrmbIENljtCuBg9yYtKuG(4fWwmaIk1e2bdFWLaFdmHU4ZS1rtF2OMuSGgbBGzHb0f)4gq)S7MQYVJTiTqUKmXrn0BqhEDvXIyce9oNeMzKdD00xKKOF8ejfOpEbScySsnHDWWhCjW3atOl(mBD00NnQjflOrWgywyaDXpUb0p7UPQ87ylslKljtCud9g0Hxxv0)wJtcZmYHoA6lss0pEIKc0hVaUdgtflIjq07CjzIJAZOhtEIKc0hVa2IbuQjSdg(Glb(gycDXNzRJM(SrnPybnc2atm9V14sYeh1mBjTq(4egiVa2GKqHEICjq9fhPMuusZSL0chGcQzIg0wmaUI8uaGIF6HPKGqKkIj(Kj6hp)oQJM2m6XuflIjq07887OoAAZOhtEIKc0hVa2IbOIfXei6DUKmXrTz0Jjprsb6d1zqsOqpr(fhPMuusdGtPRUfPwmjcuqj(vNmr)453rD00MrpMQyrmbIENljtCuBg9yYtKuG(qDgKek0tKFXrQjfL0a4u6QBrQftIafuwetGO35sYeh1MrpM8ejfOpEbSfdGOsnHDWWhCjW3atijzIJAZOhtJGnWetmlIjq078l(mBD00NnQjfliprsb6d1zqsOqprUyQjfL0a4u6QBrQV4ivr)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCsrj94egiebkOeZIyce9o)IpZwhn9zJAsXcYtKuG(aSXur)BnUKmXrnZwslKpoHbYlGnijuONixcuFXrQjfL0mBjTWbrePI(3A887OoAAZOhtoq07LAc7GHp4sGVbMq53rD00MrpMgbBGP)Tgp)oQJM2m6XKde9UkIjMfXei6D(fFMToA6Zg1KIfKNiPa9H66GXur)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCsrj94egiebkOeZIyce9o)IpZwhn9zJAsXcYtKuG(aSXur)BnUKmXrnZwslKpoHbYlGnijuONixcuFXrQjfL0mBjTWbrePIywetGO35sYeh1MrpM8ejfOpuNIDauqbq6FRXV4ZS1rtF2OMuSG8VjrLAc7GHp4sGVbMqdBy7GUL2m6X0iydmlIjq07CjzIJ6iP5jskqFOofauqF1jt0pUKmXrDK0LAc7GHp4sGVbMqsYeh10tzCgbBGzHb0f)4G0nHIRk)o2I0c5sYeh12ssgExv0)wJljtCuBg9yY)MQaq6FRXtbak(PhMscI2WF6yk0Wj86YhNWabScwLzIg0wmaUICjzIJ6iPvjSdAa1OJKqC8Y7Outyhm8bxc8nWessM4OMwYuSqJGnWSWa6IFCq6MqXvLFhBrAHCjzIJABjjdVRk6FRXLKjoQnJEm5Ftvai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGawbxQjSdg(Glb(gycjjtCutpLXzeSbMfgqx8Jds3ekUQ87ylslKljtCuBljz4Dvr)BnUKmXrTz0Jj)BQIyG44Paaf)0dtjbHNiPa9H6mUGckas)BnEkaqXp9Wusq0g(thtHgoHxx(3Kivai9V14Paaf)0dtjbrB4pDmfA4eED5JtyG8IcwLWoObuJoscXbyfUutyhm8bxc8nWessM4OosAJGnWSWa6IFCq6MqXvLFhBrAHCjzIJABjjdVRk6FRXLKjoQnJEm5Ftvai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGawHl1e2bdFWLaFdmHKKjoQPLmfl0iydmlmGU4hhKUjuCv53XwKwixsM4O2wsYW7QI(3ACjzIJAZOht(3ufas)BnEkaqXp9Wusq0g(thtHgoHxx(4egiG7qPMWoy4dUe4BGjKKmXrnQK5mgWWnc2aZcdOl(XbPBcfxv(DSfPfYLKjoQTLKm8UQO)TgxsM4O2m6XK)nvzMObTfdG3bEkaqXp9WusqujSdAa1OJKqCOofUutyhm8bxc8nWessM4OgvYCgdy4gbBGzHb0f)4G0nHIRk)o2I0c5sYeh12ssgExv0)wJljtCuBg9yY)MQaq6FRXtbak(PhMscI2WF6yk0Wj86YhNWabSIQe2bnGA0rsiouNcxQjSdg(Glb(gyczM4aDgQJMMe6agbBGP)TghaLZMosh5Ftvai9V14x8z26OPpButkwq(3ufas)Bn(fFMToA6Zg1KIfKNiPa9XlGP)Tg3mXb6muhnnj0b4KIs6Xjmq6Cc7GHZLKjoQPNY44Osi7FO(GKOkIj(Kj6hpXr4IZqvc7Ggqn6ijehVOGjcuqf2bnGA0rsioErbisfXVk)o2I0c5sYeh10bjTKaKOFGc6jPfECBuMNn3KDQtHvaIk1e2bdFWLaFdmHKKjoQPNY4mc2at)BnoakNnDKoY)MQiM4tMOF8ehHlodvjSdAa1OJKqC8IcMiqbvyh0aQrhjH44ffGive)Q87ylslKljtCuthK0scqI(bkONKw4XTrzE2Ct2PofwbiQutyhm8bxc8nWeA8nX0ddsPMWoy4dUe4BGjKKmXrnTKPyHgbBGP)TgxsM4OMzlPfYhNWarDGjwyh0aQrhjH4W4trIuLFhBrAHCjzIJA6GKwsas0pvNKw4XTrzE2Ct29IcRaLAc7GHp4sGVbMqsYeh10sMIfAeSbM(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5KIs6Xjmqk1e2bdFWLaFdmHKKjoQJK2iydm9V14sYeh1mBjTq(4egiGnMkIzrmbIENljtCuBg9yYtKuG(qDkQaGc6RiMfgqx8Jds3ekUQ87ylslKljtCuBljz4DjIOsnHDWWhCjW3atihpBm1hsAIJZiydmXj2sCyl0teuqF1bzGaDlIur)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCsrj94egiLAc7GHp4sGVbMqsYeh1KWXaoXHrWgy6FRXztusMmoOBXtuyNQ87ylslKljtCuBljz4DvrmXNmr)4cP5e2Gm5GHRsyh0aQrhjH44fJhrGcQWoObuJoscXXlkarLAc7GHp4sGVbMqsYeh1KWXaoXHrWgy6FRXztusMmoOBXtuyNQtMOFCjzIJAKzhQaq6FRXV4ZS1rtF2OMuSG8VPkIpzI(XfsZjSbzYbdhuqf2bnGA0rsioEPJtuPMWoy4dUe4BGjKKmXrnjCmGtCyeSbM(3AC2eLKjJd6w8ef2P6Kj6hxinNWgKjhmCvc7Ggqn6ijehVOGl1e2bdFWLaFdmHKKjoQrLmNXagUrWgy6FRXLKjoQz2sAH8XjmqEH(3ACjzIJAMTKwiNuuspoHbsPMWoy4dUe4BGjKKmXrnQK5mgWWnc2at)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCsrj94egiQmt0G2IbWvKljtCutlzkwyPwN6uTc7GHp4sGVbMqOHGjhmCJG(Hz(npnSbMuCHBYo1b24Pagb9dZ8BEAijjcaLdbRyPwPwN6uTe2ghyTmzY(t5GHpQThtSwYWacul0VO2ZgRvaacV2lQLy7WeB)5Slr1cDwIYaRfBnidIoRlVuRtDQwHDWWhCMmz)PCWWhGnijuONOrUqIGTfdOomrhbmkmbpWZidY8JGv0iydSbjHc9e52IbuhMOJaGnMkZenOTyaCf5OHGjhmCvVI487ylslKpGM2HRhxKKGcA(DSfPfYpK0mszQ7L0KOsTo1PAf2bdFWzYK9NYbdF8gyczqsOqprJCHebBlgqDyIocyuycEGNrgK5hbROrWgydscf6jYTfdOomrhbaBmv0)wJljtCuBg9yYbIExflIjq07CjzIJAZOhtEIKc0hQio)o2I0c5dOPD46XfjjOGMFhBrAH8djnJuM6EjnjQuRtDQwHDWWhCMmz)PCWWhVbMqgKek0t0ixirWnOltn9pDJctWd8mYGm)iyfnc2at)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCsrj94egiQEf9V145FI6OPp7eXb)BQQbTSpDIKc0hVaMyIjfxmoaHDWW5sYeh10tzCCwmoI6Cc7GHZLKjoQPNY44Osi7FO(GKirLADQt1QGcpBmRvQT9NZU1ooHbccuRTKKH3T2iRf61IkHS)H1MIBH12dp7Avwqsljaj6xPwN6uTc7GHp4mzY(t5GHpEdmHmijuONOrUqIGrsZOhteqtlzkwOrHj4bEgzqMFem9V14sYeh12ssgEx(4egiQdSIkaOGsC(DSfPfYLKjoQPdsAjbir)uDsAHh3gL5zZnz3lkScquPwN6uTc7GHp4mzY(t5GHpEdmHmijuONOrUqIGNY40IP(pqJaWM8NhyJzuycEGNrWgy6FRXLKjoQnJEm5FtveBqsOqpr(ugNwm1)bc2yGc6bjr1b2GKqHEI8PmoTyQ)d8nfvaImYGm)i4dsILADQt12rjtCS2oldaOv3ATGgWrTsTgKek0tSwHm((vB0QLbKgvl9)QThjyoR9pWALABt5QfhhKuoy41AJjYRLW2yTdijRwZmmabqGAtKuG(qJkzISdbQfvYmXXagETaboQ1JR2(ibP2ECoRTfzTMzaaT6wlWhR9IApBSw6FoUU16Y9tS2Ov7zJ1YasEPwN6uTc7GHp4mzY(t5GHpEdmHmijuONOrUqIGXXbjLdb0IPMfXei6DJctWd8mYGm)iyIzrmbIENljtCuBg9yYb(PCWW7CeROXhXgJBmfUZXch4dpUKmXrTzgaqRU8uCqiIiIm(i(GKOXNbjHc9e5tzCAXu)hirLADQt1kSdg(GZKj7pLdg(4nWeYGKqHEIg5cjc(GKO(7hCQftJctWd8mc2aZch4dpUKmXrTzgaqRUgzqMFemlIjq07CjzIJAZOhtEIKc0hAujtKDiqPwN6uTc7GHp4mzY(t5GHpEdmHmijuONOrUqIGpijQ)(bNAX0OWe8apJGnWVIfoWhECjzIJAZmaGwDnYGm)iywetGO35sYeh1MrpM8ejfOpk16uNQ14ejyoRfaNs3A7OoR2VzTxuBhm2az12ISwchxhRuRtDQwHDWWhCMmz)PCWWhVbMqgKek0t0ixirWhKe1F)GtTyAuycMuuYidY8JGzrmbIENFXNzRJM(SrnPyb5jskqFyeSbMywetGO35x8z26OPpButkwqEIKc0hgFgKek0tKFqsu)9do1IjrV0bJvQ1Pov7d0zyTVRpD3AHJAhFMDTsTMrpMT)S2lHoi4vBlYAnoqDtO4gvBpsWCw74GmqQ9IApBS2RpQLe6)dRL1LnXA)(bN12J1AHxTsT2ql7Arp(w21MIdsTrRwZmaGwDl16uNQvyhm8bNjt2Fkhm8XBGjKbjHc9enYfse8bjr93p4ulMgfMGjfLmYGm)i4lHoi4XhXFoX7GULo)0D5SiMarVZtKuG(WiydmlCGp84sYeh1MzaaT6QIfoWhECjzIJAZmaGwD5P4G8IcOc78FOPjcWhXFoX7GULo)0DvXcdOl(XbPBcfxv(DSfPfYLKjoQTLKm8ULADQt1ACIemN1cGtPBTeoUowTFZAVO2oySbYQTfzTDuNvQ1PovRWoy4dotMS)uoy4J3atidscf6jAKlKiy7ycaDl9fhPrHj4bEgzqMFemlIjq078l(mBD00NnQjfliprbORkdscf6jYpijQ)(bNAX8LoySsTo1PAFxcau8R2htjbPwGah16XvlKKebGYHZU1A(VA)M1E2yTg(thtHgoHx3Abq6FRv7iQfE1YeVwASwayRbz)5v7f1cahmm9ApB5QThjiXALR2ZgRvbjMXzxRH)0XuOHt41T2Xjmqk16uNQvyhm8bNjt2Fkhm8XBGjKbjHc9enYfseSX)FC6)ab0dtjbXOWe8apJmiZpcMyZenOTyaCf5Paaf)0dtjbbuqnt0G2IbW7apfaO4NEykjiGcQzIg0wmaUcZtbak(PhMsccrQe2bdNNcau8tpmLee(bjr9a6m8flgaNuuQZPGl16uNQvbrcTGUmR9bs(6Az2ideeOwaK(3A8uaGIF6HPKGOn8NoMcnCcVUCGO3nQw6)v7zlxTaboCcUA7JeKA7TrV2ZgRvaacVwX0CcXrTVRhJdUwOpoXVzxEPwN6uTc7GHp4mzY(t5GHpEdmHmijuONOrUqIGn()Jt)hiGEykjigfMGh4zKbz(rWeBMObTfdGRipfaO4NEykjiGcQzIg0wmaEh4Paaf)0dtjbbuqnt0G2IbWvyEkaqXp9Wusqisfas)BnEkaqXp9Wusq0g(thtHgoHxxoq07LADQt1kSdg(GZKj7pLdg(4nWeYGKqHEIg5cjco(3acG6OPzrmbIEFyuycEGNrgK5hbt)BnUKmXrTz0Jjhi6Dv0)wJNFh1rtBg9yYbIExfas)Bn(fFMToA6Zg1KIfKde9UQxzqsOqprUX)FC6)ab0dtjbrfas)BnEkaqXp9Wusq0g(thtHgoHxxoq07LADQt1kSdg(GZKj7pLdg(4nWeYGKqHEIg5cjcECcdeTTKKH31OWe8apJmiZpco)o2I0c5sYeh12ssgExvetmlmGU4hhKUjuCvSiMarVZtbak(PhMsccprsb6JxmijuONi3wsYW7QhNWarFqsKiIk1k16uTDwcJeEqfKyT)b0TQ1kHJz3AHmiBI12dp7AftETV7bwl8QThE21EXrwBC2y2dhiVutyhm8bNfXei69b4wgJt7HbXiydC(DSfPfYTs4y2vdzq2evXIyce9oxsM4O2m6XKNiPa9H6uyJPIfXei6D(fFMToA6Zg1KIfKNOa0vfX0)wJljtCuZSL0c5JtyG8cydscf6jYV4i1KIsAMTKw4qfXeFYe9JNFh1rtBg9yQIfXei6DE(DuhnTz0Jjprsb6JxaBXauXIyce9oxsM4O2m6XKNiPa9H6mijuONi)IJutkkPbWP0v3IulMebkOe)QtMOF887OoAAZOhtvSiMarVZLKjoQnJEm5jskqFOodscf6jYV4i1KIsAaCkD1Ti1IjrGcklIjq07CjzIJAZOhtEIKc0hVa2IbqerLAc7GHp4SiMarVpEdmHAzmoThgeJGnW53XwKwi3kHJzxnKbztuflIjq07CjzIJAZOhtEIcqxve)QtMOFC0Nql7dDeauqj(Kj6hh9j0Y(qhburkUWnzN6a)omgrePIyIzrmbIENFXNzRJM(SrnPyb5jskqFOofnMk6FRXLKjoQz2sAH8Xjmqat)BnUKmXrnZwslKtkkPhNWaHiqbLywetGO35x8z26OPpButkwqEIKc0hGnMk6FRXLKjoQz2sAH8XjmqaBmIisf9V1453rD00MrpMCGO3vrkUWnzN6aBqsOqprUyQjHoK8tQjfx0MSRutyhm8bNfXei69XBGjulJXrhZZiydC(DSfPfYbGdg0CcDj7QzbjP4aQyrmbIENt)BnnaCWGMtOlzxnlijfhGNOa0vf9V14aWbdAoHUKD1SGKuCaDlJXXbIExfX0)wJljtCuBg9yYbIExf9V1453rD00MrpMCGO3vbG0)wJFXNzRJM(SrnPyb5arVtKkwetGO35x8z26OPpButkwqEIKc0hGnMkIP)TgxsM4OMzlPfYhNWa5fWgKek0tKFXrQjfL0mBjTWHkIj(Kj6hp)oQJM2m6XuflIjq07887OoAAZOhtEIKc0hVa2IbOIfXei6DUKmXrTz0Jjprsb6d1zqsOqpr(fhPMuusdGtPRUfPwmjcuqj(vNmr)453rD00MrpMQyrmbIENljtCuBg9yYtKuG(qDgKek0tKFXrQjfL0a4u6QBrQftIafuwetGO35sYeh1MrpM8ejfOpEbSfdGiIk1e2bdFWzrmbIEF8gyc1GjQPNY4mc2aNFhBrAHCa4GbnNqxYUAwqskoGkwetGO350)wtdahmO5e6s2vZcssXb4jkaDvr)BnoaCWGMtOlzxnlijfhq3GjYbIExLzIg0wmaUI8wgJJoMxPwNQTZeywBhliCT9WZU2oQZQf2QfEemQLfKq3Q2VzTJiCETVZwTWR2E4Cwlnw7FGa12dp7AjCCDmJQLjJRw4v7ycTSVz3APXwKyPMWoy4dolIjq07J3atisyMro0rtFrsI(zeSbM4xLFhBrAH8b00oC94IKeuqP)TgFanTdxpUij5FtIuXIyce9o)IpZwhn9zJAsXcYtKuG(4fdscf6jYjJtBMidra9fhPMUlOGsSbjHc9e5hKe1F)GtTyQodscf6jYjJttkkPbWP0v3IulMQyrmbIENFXNzRJM(SrnPyb5jskqFOodscf6jYjJttkkPbWP0v3IuFXrsuPMWoy4dolIjq07J3atisyMro0rtFrsI(zeSbMfXei6DUKmXrTz0JjprbORkIF1jt0po6tOL9HocakOeFYe9JJ(eAzFOJaQifx4MStDGFhgJiIurmXSiMarVZV4ZS1rtF2OMuSG8ejfOpuNbjHc9e5IPMuusdGtPRUfP(IJuf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGqeOGsmlIjq078l(mBD00NnQjfliprsb6dWgtf9V14sYeh1mBjTq(4egiGngrePI(3A887OoAAZOhtoq07Qifx4MStDGnijuONixm1Kqhs(j1KIlAt2vQjSdg(GZIyce9(4nWeQnXHnlL2zeSb2GKqHEI84FdiaQJMMfXei69HkIhXFsdDaUHykhCI6rmnG(bkOJ4pPHoa38pU)e1y(npy4evQ1PA7OzV0Du7FG1cGYzthPJ12dp7AftETVZwTxCK1ch1MOa0TwzuBpoNgvlPacw74NyTxultgxTWRwASfjw7fhjVutyhm8bNfXei69XBGjeakNnDKoAeSbMfXei6D(fFMToA6Zg1KIfKNOa0vf9V14sYeh1mBjTq(4egiVa2GKqHEI8losnPOKMzlPfouXIyce9oxsM4O2m6XKNiPa9XlGTyaLAc7GHp4SiMarVpEdmHaq5SPJ0rJGnWSiMarVZLKjoQnJEm5jkaDvr8RozI(XrFcTSp0raqbL4tMOFC0Nql7dDeqfP4c3KDQd87WyerKkIjMfXei6D(fFMToA6Zg1KIfKNiPa9H6u0yQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoPOKECcdeIafuIzrmbIENFXNzRJM(SrnPyb5jkaDvr)BnUKmXrnZwslKpoHbcyJrerQO)Tgp)oQJM2m6XKde9UksXfUj7uhydscf6jYftnj0HKFsnP4I2KDLADQ239aRDykji1cB1EXrwR4a1kM1kjwB41YaQvCGA7dNGRwAS2VzTTiRDgUfM1E2Ix7zJ1skkvlaoLUgvlPac0TQD8tS2ESwBXawRC1orzC1E9rTsYehRLzlPfoQvCGApB5Q9IJS2Ez4eC1A8)hxT)bcWl1e2bdFWzrmbIEF8gycLcau8tpmLeeJGnWSiMarVZV4ZS1rtF2OMuSG8ejfOpuNbjHc9e55qtkkPbWP0v3IuFXrQIfXei6DUKmXrTz0Jjprsb6d1zqsOqprEo0KIsAaCkD1Ti1IPkIpzI(XZVJ6OPnJEmvrmlIjq07887OoAAZOhtEIKc0hVGkHS)H6dsIGcklIjq07887OoAAZOhtEIKc0hQZGKqHEI8COjfL0a4u6QBrQZWKiqb9vNmr)453rD00MrpMePI(3ACjzIJAMTKwiFCcde11bvai9V14x8z26OPpButkwqoq07QO)Tgp)oQJM2m6XKde9Uk6FRXLKjoQnJEm5arVxQ1PAF3dS2HPKGuBp8SRvmRT3g9AnJXasprETVZwTxCK1ch1MOa0TwzuBpoNgvlPacw74NyTxultgxTWRwASfjw7fhjVutyhm8bNfXei69XBGjukaqXp9Wusqmc2aZIyce9o)IpZwhn9zJAsXcYtKuG(4fujK9puFqsuf9V14sYeh1mBjTq(4egiVa2GKqHEI8losnPOKMzlPfouXIyce9oxsM4O2m6XKNiPa9XleJkHS)H6dsIVjSdgo)IpZwhn9zJAsXcYrLq2)q9bjrIk1e2bdFWzrmbIEF8gycLcau8tpmLeeJGnWSiMarVZLKjoQnJEm5jskqF8cQeY(hQpijQIyIF1jt0po6tOL9HocakOeFYe9JJ(eAzFOJaQifx4MStDGFhgJiIurmXSiMarVZV4ZS1rtF2OMuSG8ejfOpuNbjHc9e5IPMuusdGtPRUfP(IJuf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGqeOGsmlIjq078l(mBD00NnQjfliprsb6dWgtf9V14sYeh1mBjTq(4egiGngrePI(3A887OoAAZOhtoq07Qifx4MStDGnijuONixm1Kqhs(j1KIlAt2ruPMWoy4dolIjq07J3atO)a1WdjnYfse8i(ZjEh0T05NURrWgyIFv(DSfPfYhqt7W1JlssqbL(3A8b00oC94IKK)njsf9V14sYeh1mBjTq(4egiVa2GKqHEI8losnPOKMzlPfouXIyce9oxsM4O2m6XKNiPa9XlGrLq2)q9bjrvKIlCt2Podscf6jYftnj0HKFsnP4I2KDQO)Tgp)oQJM2m6XKde9EPwNQ9DpWAV4iRThE21kM1cB1cpcg12dpBOx7zJ1skkvlaoLU8AFNTA94mQ2)aRThE21MHzTWwTNnw7jt0VAHJApbe0nQwXbQfEemQThE2qV2ZgRLuuQwaCkD5LAc7GHp4SiMarVpEdmHU4ZS1rtF2OMuSGgbBGj(v53XwKwiFanTdxpUijbfu6FRXhqt7W1Jlss(3Kiv0)wJljtCuZSL0c5JtyG8cydscf6jYV4i1KIsAMTKw4qflIjq07CjzIJAZOhtEIKc0hVagvcz)d1hKevrkUWnzN6mijuONixm1Kqhs(j1KIlAt2PI(3A887OoAAZOhtoq07LAc7GHp4SiMarVpEdmHU4ZS1rtF2OMuSGgbBGP)TgxsM4OMzlPfYhNWa5fWgKek0tKFXrQjfL0mBjTWHQtMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jskqF8cyujK9puFqsuLbjHc9e5hKe1F)GtTyQodscf6jYV4i1KIsAaCkD1Ti1IzPMWoy4dolIjq07J3atOl(mBD00NnQjflOrWgy6FRXLKjoQz2sAH8XjmqEbSbjHc9e5xCKAsrjnZwslCOI4xDYe9JNFh1rtBg9yckOSiMarVZZVJ6OPnJEm5jskqFOodscf6jYV4i1KIsAaCkD1Ti1zysKkdscf6jYpijQ)(bNAXuDgKek0tKFXrQjfL0a4u6QBrQfZsTov77EG1kM1cB1EXrwlCuB41YaQvCGA7dNGRwAS2VzTTiRDgUfM1E2Ix7zJ1skkvlaoLUgvlPac0TQD8tS2ZwUA7XATfdyTOhFl7AjfxQvCGApB5Q9SXeRfoQ1JRwzMOa0TwP287yTrRwZOhZAbIENxQjSdg(GZIyce9(4nWessM4O2m6X0iydmlIjq078l(mBD00NnQjfliprsb6d1zqsOqprUyQjfL0a4u6QBrQV4ivr8RyHb0f)4gq)S7MGcklIjq07CsyMro0rtFrsI(XtKuG(qDgKek0tKlMAsrjnaoLU6wKAY4isf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGOI(3A887OoAAZOhtoq07Qifx4MStDGnijuONixm1Kqhs(j1KIlAt2vQ1PAF3dS2mmRf2Q9IJSw4O2WRLbuR4a12hobxT0yTFZABrw7mClmR9SfV2ZgRLuuQwaCkDnQwsbeOBv74NyTNnMyTWHtWvRmtua6wRuB(DSwGO3RvCGApB5QvmRTpCcUAPrwqI1kge4uONyTa)e6w1MFh5LAc7GHp4SiMarVpEdmHYVJ6OPnJEmnc2at)BnUKmXrTz0Jjhi6DveZIyce9o)IpZwhn9zJAsXcYtKuG(qDgKek0tKNHPMuusdGtPRUfP(IJeuqzrmbIENljtCuBg9yYtKuG(4fWgKek0tKFXrQjfL0a4u6QBrQftIur)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCsrj94egiQyrmbIENljtCuBg9yYtKuG(qDkAmvSiMarVZV4ZS1rtF2OMuSG8ejfOpuNIgRutyhm8bNfXei69XBGj0Wg2oOBPnJEmnc2aBqsOqprE8Vbea1rtZIyce9(OuRt1(UhyTMbzTxu7OZ)rubjwR41IkDPuRqxl0R9SXADuPRwwetGO3RTh6arVr1(9jog1cs3ekETNn61g(SBTa)e6w1kjtCSwZOhZAb(yTxuRD0xlP4sT2F3k7wBkaqXVAhMscsTWrPMWoy4dolIjq07J3atiZehOZqD00KqhWiyd8jt0pE(DuhnTz0JPk6FRXLKjoQnJEm5Ftv0)wJNFh1rtBg9yYtKuG(4flgaNuuQutyhm8bNfXei69XBGjKzId0zOoAAsOdyeSbgaP)Tg)IpZwhn9zJAsXcY)MQaq6FRXV4ZS1rtF2OMuSG8ejfOpEryhmCUKmXrnjCmGtCWrLq2)q9bjrvVIfgqx8Jds3ekEPMWoy4dolIjq07J3atiZehOZqD00KqhWiydm9V1453rD00MrpM8VPk6FRXZVJ6OPnJEm5jskqF8IfdGtkkPIfXei6DoAiyYbdNNOa0vflIjq078l(mBD00NnQjfliprsb6dvVIfgqx8Jds3ekEPwPMWoy4dEd6Yut)thSKmXrnjCmGtCyeSbM(3AC2eLKjJd6w8ef2zeZwGoyfl1e2bdFWBqxMA6F6VbMqsYeh10tzCLAc7GHp4nOltn9p93atijzIJAAjtXcl1k16uTgN2OxB(Dh6w1IWZgZApBS2NNAJSwcBCw7eTqhqsiomQ2ES2EXVAVOwfudrT0ylsS2ZgRLWX1Xiuh1z12dDGONx77EG1cVALrTJi8ALrTVROZQ1wg12GoCyJa1g)S2EKadyTdt0VAJFwlZwslCuQjSdg(G3GdBOBPdt0XemAiyYbd3iydmX53XwKwi)qsZiLPUxstqbL487ylslKpGM2HRhxKKQELbjHc9e5MjA(NtnAiaRirePIy6FRXZVJ6OPnJEm5arVdkOMjAqBXa4kYLKjoQPLmflKivSiMarVZZVJ6OPnJEm5jskqFuQ1PAFNTA7rcmG12GoCyJa1g)SwwetGO3RTh6ar)OwXbQDyI(vB8ZAz2sAHdJQ1mHrcpOcsSwfudrTHbmRfnGz3Zg6w1IZbwQjSdg(G3GdBOBPdt0X8nWecnem5GHBeSb(Kj6hp)oQJM2m6XuflIjq07887OoAAZOhtEIKc0hQyrmbIENljtCuBg9yYtKuG(qf9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjhi6DvMjAqBXa4kYLKjoQPLmflSutyhm8bVbh2q3shMOJ5BGjudMOMEkJZiydC(DSfPfYbGdg0CcDj7QzbjP4aQO)TghaoyqZj0LSRMfKKIdOBzmo(3Sutyhm8bVbh2q3shMOJ5BGjulJXP9WGyeSbo)o2I0c5wjCm7QHmiBIQifx4MStDDCfOutyhm8bVbh2q3shMOJ5BGjKKmXrnjCmGtCyeSbo)o2I0c5sYeh12ssgExv0)wJljtCuBljz4D5JtyG8c9V14sYeh12ssgExoPOKECcdevetm9V14sYeh1MrpMCGO3vXIyce9oxsM4O2m6XKNOa0LiqbfaP)Tg)IpZwhn9zJAsXcY)MezeZwGoyfl1e2bdFWBWHn0T0Hj6y(gycLFh1rtBg9yAeSbo)o2I0c5dOPD46XfjzPMWoy4dEdoSHULomrhZ3atijzIJ6iPnc2aZIyce9op)oQJM2m6XKNOa0Tutyhm8bVbh2q3shMOJ5BGjKKmXrn9ugNrWgywetGO3553rD00MrpM8efGUQO)TgxsM4OMzlPfYhNWa5f6FRXLKjoQz2sAHCsrj94egiLAc7GHp4n4Wg6w6WeDmFdmHaq5SPJ0rJGnWVk)o2I0c5hsAgPm19sAckOSWb(WJBbBNoA6Zg1tiZUutyhm8bVbh2q3shMOJ5BGju(DuhnTz0JzPwNQ9D2QThjiXALRwsrPAhNWazuB0Q91VUwXbQThR1wmGobxT)bcuBhliCTDXZOA)dSwP2XjmqQ9IAnt0a6xTKFNzdDRA)(ehJAZV7q3Q2ZgR14yjjdVBTt0cDaj7wQjSdg(G3GdBOBPdt0X8nWessM4OMeogWjomc2at)BnoBIsYKXbDlEIc7ur)BnoBIsYKXbDl(4egiGP)TgNnrjzY4GUfNuuspoHbIkwyaDXpUb0p7UPkwetGO35KWmJCOJM(IKe9JNOa0v1RmijuONihjnJEmranTKPyHQyrmbIENljtCuBg9yYtua6wQ1PAvEKKYC2T2ESwtbM1Aghm8A)dS2E4zxBh1zgvl9)QfE12dNZANY4QDgUvTOhFl7ABrwlDC21E2yTVROZQvCGA7OoR2EOde9JA)(ehJAZV7q3Q2ZgR95P2iRLWgN1orl0bKeIJsnHDWWh8gCydDlDyIoMVbMqMXbd3iyd8RYVJTiTq(HKMrktDVKMQi(v53XwKwiFanTdxpUijbfuInijuONi3mrZ)CQrdbyfvr)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCsrj94egieruPMWoy4dEdoSHULomrhZ3atiauoB6iD0iydm9V1453rD00MrpMCGO3bfuZenOTyaCf5sYeh10sMIfwQjSdg(G3GdBOBPdt0X8nWekfaO4NEykjigbBGP)Tgp)oQJM2m6XKde9oOGAMObTfdGRixsM4OMwYuSWsnHDWWh8gCydDlDyIoMVbMqKWmJCOJM(IKe9Ziydm9V1453rD00MrpM8ejfOpEHyJ7BDOZLFhBrAH8b00oC94IKKOsTovRXPn61MF3HUvTNnwRXXssgE3ANOf6as21OA)dS2oQZQLgBrI1s446y1ErTaFsZALAB)5SBTJtyGGa1slzkwyPMWoy4dEdoSHULomrhZ3atijzIJAZOhtJGnWgKek0tKJKMrpMiGMwYuSqv0)wJNFh1rtBg9yY)MQiMuCHBYUxiUdkWBeROX6CSWa6IFCq6MqXjIiqbL(3AC2eLKjJd6w8Xjmqat)BnoBIsYKXbDloPOKECcdeIk1e2bdFWBWHn0T0Hj6y(gycjjtCutlzkwOrWgydscf6jYrsZOhteqtlzkwOk6FRXLKjoQz2sAH8Xjmqat)BnUKmXrnZwslKtkkPhNWarf9V14sYeh1MrpM8VzPMWoy4dEdoSHULomrhZ3atO)a1WdjnYfse8i(ZjEh0T05NURrWgy6FRXZVJ6OPnJEm5arVdkOMjAqBXa4kYLKjoQPLmfleuqnt0G2IbWvKNcau8tpmLeeqbLyZenOTyaCf5aOC20r6OQxLFhBrAH8b00oC94IKKOsnHDWWh8gCydDlDyIoMVbMqx8z26OPpButkwqJGnW0)wJNFh1rtBg9yYbIEhuqnt0G2IbWvKljtCutlzkwiOGAMObTfdGRipfaO4NEykjiGckXMjAqBXa4kYbq5SPJ0rvVk)o2I0c5dOPD46XfjjrLAc7GHp4n4Wg6w6WeDmFdmHKKjoQnJEmnc2aBMObTfdGRi)IpZwhn9zJAsXcwQ1PAF3dS2ol6y1ErTJo)hrfKyTIxlQ0LsTDuYehRvztzC1c8tOBv7zJ1s446yeQJ6SA7Hoq0x73N4yuB(Dh6w12rjtCSwfuMDWR9D2QTJsM4yTkOm7Ow4O2tMOFiGr12J1YeNGR2)aRTZIowT9WZg61E2yTeoUogH6OoR2EOde91(9jog12J1c9dZ8BE1E2yTDuhRwMT4oonQ2ruBpsWCw7qmG1cpEPMWoy4dEdoSHULomrhZ3atiZehOZqD00KqhWiyd8RozI(XLKjoQrMDOcaP)Tg)IpZwhn9zJAsXcY)MQaq6FRXV4ZS1rtF2OMuSG8ejfOpEbmXc7GHZLKjoQPNY44Osi7FO(GKyNJ(3ACZehOZqD00KqhGtkkPhNWaHOsTov77SvBNfDSATLHtWvlnIET)bculWpHUvTNnwlHJRJvBp0bIEJQThjyoR9pWAHxTxu7OZ)rubjwR41IkDPuBhLmXXAv2ugxTqV2ZgR9DfDgH6OoR2EOde98snHDWWh8gCydDlDyIoMVbMqMjoqNH6OPjHoGrWgy6FRXLKjoQnJEm5Ftv0)wJNFh1rtBg9yYtKuG(4fWelSdgoxsM4OMEkJJJkHS)H6dsIDo6FRXntCGod1rttcDaoPOKECcdeIk1e2bdFWBWHn0T0Hj6y(gycjjtCutpLXzeSbgioEkaqXp9Wusq4jskqFOofauqbq6FRXtbak(PhMscI2WF6yk0Wj86YhNWarDgRuRt1ACI12l(v7f1skGG1o(jwBpwRTyaRf94BzxlP4sTTiR9SXAr)GjwBh1z12dDGO3OArdOxlSv7zJjsWO2XbNZApijwBIKc0HUvTHx77k6mETVZJGrTHp7wlnEhM1ErT0)0R9IAvqIzuR4a1QGAiQf2Qn)UdDRApBS2NNAJSwcBCw7eTqhqsio4LAc7GHp4n4Wg6w6WeDmFdmHKKjoQPLmfl0iydmlIjq07CjzIJAZOhtEIcqxvKIlCt29cXkyJ9gXkASohlmGU4hhKUjuCIisf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGOI4xLFhBrAH8b00oC94IKeuqnijuONi3mrZ)CQrdbyfjs1RYVJTiTq(HKMrktDVKMQEv(DSfPfYLKjoQTLKm8ULADQwLjzkwyTd74pbQ1JRwAS2)abQvUApBSw0bQnA12rDwTWwTkOgcMCWWRfoQnrbOBTYOwGmmnHUvTmBjTWrT9W5SwsbeSw4v7jGG1od3cZAVOw6F61E2z8TSRnrsb6q3QwsXLsnHDWWh8gCydDlDyIoMVbMqsYeh10sMIfAeSbM(3ACjzIJAZOht(3uf9V14sYeh1MrpM8ejfOpEbSfdqflIjq07C0qWKdgoprsb6JsTovRYKmflS2HD8Na1kZEP7OwAS2ZgRDkJRwMmUAHETNnw77k6SA7Hoq0xRmQLWX1XQThoN1M44IeR9SXAz2sAHJAhMOFLAc7GHp4n4Wg6w6WeDmFdmHKKjoQPLmfl0iydm9V1453rD00MrpM8VPk6FRXLKjoQnJEm5arVRI(3A887OoAAZOhtEIKc0hVa2IbO6v53XwKwixsM4O2wsYW7wQjSdg(G3GdBOBPdt0X8nWessM4OMeogWjomc2adG0)wJFXNzRJM(SrnPyb5FtvNmr)4sYeh1iZourm9V14aOC20r6ihi6Dqbvyh0aQrhjH4aSIePcaP)Tg)IpZwhn9zJAsXcYtKuG(qDc7GHZLKjoQjHJbCIdoQeY(hQpijAeZwGoyfncLC2vZSfORHnW0)wJZMOKmzCq3sZSf3Xjhi6Dvet)BnUKmXrTz0Jj)BckOe)QtMOF8WaMMrpMiGkIP)Tgp)oQJM2m6XK)nbfuwetGO35OHGjhmCEIcqxIiIOsTov77SvBpsqI1Aa9ZUBAuTqsseakho7w7FG1(6xxBVn61YetteO2lQ1JR2EzCyTMzWg12YGS2owq4snHDWWh8gCydDlDyIoMVbMqsYeh1KWXaoXHrWgywyaDXpUb0p7UPk6FRXztusMmoOBXhNWabm9V14Sjkjtgh0T4KIs6Xjmqk16uTpNKxT)b0TQ91VU2oQJvBVn612rDwT2YOwAe9A)deOutyhm8bVbh2q3shMOJ5BGjKKmXrnjCmGtCyeSbM(3AC2eLKjJd6w8ef2PIfXei6DUKmXrTz0Jjprsb6dvet)BnE(DuhnTz0Jj)BckO0)wJljtCuBg9yY)MezeZwGoyfl1e2bdFWBWHn0T0Hj6y(gycjjtCuhjTrWgy6FRXLKjoQz2sAH8XjmqEbSbjHc9e5xCKAsrjnZwslCuQjSdg(G3GdBOBPdt0X8nWessM4OMEkJZiydm9V1453rD00MrpM8VjOGskUWnzN6uubk1e2bdFWBWHn0T0Hj6y(gycHgcMCWWnc2at)BnE(DuhnTz0Jjhi6Dv0)wJljtCuBg9yYbIE3iOFyMFZtdBGjfx4MStDGnEkGrq)Wm)MNgssIaq5qWkwQjSdg(G3GdBOBPdt0X8nWessM4OMwYuSWsTsTo1PAF3(4BAg5Ha1YeNHtTWoy4gh4Avqnem5GHxBpCoRLgR1L7NYC2Tw6mab9AHTAzHdapy4JALeRLepEPwN6uTc7GHp42ssgExWmXz4ulSdgUrWgyHDWW5OHGjhmCoZwChNq3sfP4c3KDQdChxbk16uTVZwTZOV2WRLuCPwXbQLfXei69rTsI1YcsOBv730OATIAfBuaQvCGArdrPMWoy4dUTKKH39nWecnem5GHBeSbMuCHBYUxaRWgtLbjHc9e5X)gqauhnnlIjq07dveFYe9JNFh1rtBg9yQIfXei6DE(DuhnTz0Jjprsb6Jxu0yevQ1PAnoXA7f)Q9IAhNWaPwBjjdVBTT)C2LxlHTXA)dS2OvRIg3AhNWazuRnMyTWrTxuRWyX3VABrw7zJ1Eqgi1oX2vB41E2yTmBXDCwR4a1E2yTKWXaoXAHETTj0Y(4LAc7GHp42ssgE33atijzIJAs4yaN4WiydmXgKek0tKpoHbI2wsYW7ckOhKeFrrJrKk6FRXLKjoQTLKm8U8XjmqErrJRrmBb6GvSuRt1ACAJET)b0TQvbL0SBIYSwfejGlodnQwMmUALAByFTOsxk1schd4eh12BdNyT9c8GUvTTiR9SXAP)TwTYv7zJ1oojVAJwTNnwBdAzFLAc7GHp42ssgE33atijzIJAs4yaN4Wiydm25)qtteGJKMDtuM6ibCXzOQdsIVOWgt1fwwtKZIyce9(qflIjq07CK0SBIYuhjGlod5jskqFOofnUgpvVsyhmCosA2nrzQJeWfNHCa4qONiqPMWoy4dUTKKH39nWe6pqn8qsJCHebpI)CI3bDlD(P7AeSbM(3ACjzIJAZOht(3u1jPfECa44eNHVawrJvQjSdg(GBljz4DFdmH(dudpK0ixirWJ4pN4Dq3sNF6UgbBGnijuONihjnJEmranTKPyHQyrmbIENFXNzRJM(SrnPyb5jskqF8cyujK9puFqsuflIjq07CjzIJAZOhtEIKc0hVaMyujK9puFqsSZ1bIuDsAHhhaooXzO6u0yLAc7GHp42ssgE33atOuaGIF6HPKGyeSb2GKqHEICK0m6Xeb00sMIfQIfXei6D(fFMToA6Zg1KIfKNiPa9XlGrLq2)q9bjrvSiMarVZLKjoQnJEm5jskqF8cyIrLq2)q9bjXoxhisfXVc78FOPjcWhXFoX7GULo)0Dbfuw4aF4XLKjoQnZaaA1LNIdI6aRaGckXxcDqWJpI)CI3bDlD(P7YzrmbIENNiPa9H6uurJP6K0cpoaCCIZq1POXicuqj(sOdcE8r8Nt8oOBPZpDxolIjq078ejfOpEbmQeY(hQpijQ6K0cpoaCCIZWxaROXiIOsnHDWWhCBjjdV7BGj0fFMToA6Zg1KIf0iydSbjHc9e5g))XP)deqpmLeevSiMarVZLKjoQnJEm5jskqF8cyujK9puFqsufXVc78FOPjcWhXFoX7GULo)0Dbfuw4aF4XLKjoQnZaaA1LNIdI6aRaGckXxcDqWJpI)CI3bDlD(P7YzrmbIENNiPa9H6uurJP6K0cpoaCCIZq1POXicuqj(sOdcE8r8Nt8oOBPZpDxolIjq078ejfOpEbmQeY(hQpijQ6K0cpoaCCIZWxaROXiIOsnHDWWhCBjjdV7BGjKKmXrTz0JPrWgyZenOTyaCf5x8z26OPpButkwWsnHDWWhCBjjdV7BGju(DuhnTz0JPrWgydscf6jYrsZOhteqtlzkwOkwetGO35Paaf)0dtjbHNiPa9XlGrLq2)q9bjrvgKek0tKFqsu)9do1IP6a3bJPI4xXch4dpUKmXrTzgaqRUGc6RmijuONixM9s3HE01zAwetGO3hGcklIjq078l(mBD00NnQjfliprsb6JxatmQeY(hQpij256arevQjSdg(GBljz4DFdmHsbak(PhMscIrWgydscf6jYrsZOhteqtlzkwOkZenOTyaCf553rD00MrpMLAc7GHp42ssgE33atOl(mBD00NnQjflOrWgydscf6jYn()Jt)hiGEykjiQELbjHc9e52Xea6w6loYsTov77EG12bhOwjzIJ1slzkwyTqV2oQZE7DPGOZQn8z3AHTAv2mcG5FC1koqTYv7eLXvBhQ91VEuRzgmgcuQjSdg(GBljz4DFdmHKKjoQPLmfl0iydm9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGOI(3A887OoAAZOht(3uf9V14sYeh1MrpM8VPk6FRXLKjoQTLKm8U8XjmquhyfnUQO)TgxsM4O2m6XKNiPa9XlGf2bdNljtCutlzkwihvcz)d1hKevr)Bno9mcG5FC8VzPwNQ9DpWA7Gdu77k6SAHETDuNvB4ZU1cB1QSzeaZ)4QvCGA7qTV(1JAnZGvQjSdg(GBljz4DFdmHYVJ6OPnJEmnc2at)BnE(DuhnTz0Jjhi6Dv0)wJtpJay(hh)BQIydscf6jYpijQ)(bNAXuDkSXafuwetGO35Paaf)0dtjbHNiPa9H6uSdePIy6FRXLKjoQTLKm8U8XjmquhyfvaqbL(3AC2eLKjJd6w8XjmquhyfjsfXVIfoWhECjzIJAZmaGwDbf0xzqsOqprUm7LUd9ORZ0SiMarVpiQutyhm8b3wsYW7(gycLFh1rtBg9yAeSbM(3ACjzIJAZOhtoq07Qi2GKqHEI8dsI6VFWPwmvNcBmqbLfXei6DEkaqXp9Wusq4jskqFOof7arQi(vSWb(WJljtCuBMba0QlOG(kdscf6jYLzV0DOhDDMMfXei69brLAc7GHp42ssgE33atOuaGIF6HPKGyeSb2GKqHEICK0m6Xeb00sMIfQIy6FRXLKjoQz2sAH8Xjmquh4oakOSiMarVZLKjoQJKMNOa0Live)QtMOF887OoAAZOhtqbLfXei6DE(DuhnTz0Jjprsb6d1PaePIfXei6DUKmXrTz0Jjprsb6dnQKjYoeqDGvyJPI4xXch4dpUKmXrTzgaqRUGc6RmijuONixM9s3HE01zAwetGO3hevQ1PAnoTrV287o0TQ1mdaOvxJQ9pWAV4iRLUBTWBGZwTqV2ibWS2lQvMqlVw4vBp8SRvml1e2bdFWTLKm8UVbMqx8z26OPpButkwqJGnWgKek0tKFqsu)9do1I5lkGXuzqsOqpr(bjr93p4ulMQtHnMkIFf25)qtteGpI)CI3bDlD(P7ckOSWb(WJljtCuBMba0Qlpfhe1bwbiQutyhm8b3wsYW7(gycjjtCuhjTrWgydscf6jYn()Jt)hiGEykjiQO)TgxsM4OMzlPfYhNWa5f6FRXLKjoQz2sAHCsrj94egiLAc7GHp42ssgE33atijzIJAAjtXcnc2adG0)wJNcau8tpmLeeTH)0XuOHt41LpoHbcyaK(3A8uaGIF6HPKGOn8NoMcnCcVUCsrj94egiLAc7GHp42ssgE33atijzIJA6PmoJGnWgKek0tKB8)hN(pqa9WusqafuIbq6FRXtbak(PhMscI2WF6yk0Wj86Y)MQaq6FRXtbak(PhMscI2WF6yk0Wj86YhNWa5faK(3A8uaGIF6HPKGOn8NoMcnCcVUCsrj94egievQ1PAF3dSwsOdRvzsMIfwlnE9i61Mcau8R2HPKGmQf2Q97aywRYEFT9WZo(xTa4u6cDRAFxcau8R2htjbPwiakZz3snHDWWhCBjjdV7BGjKKmXrnTKPyHgbBGP)Tgp)oQJM2m6XK)nvr)BnUKmXrTz0Jjhi6Dv0)wJtpJay(hh)BQIfXei6DEkaqXp9Wusq4jskqF8cyfnMk6FRXLKjoQTLKm8U8XjmquhyfnULADQ239aRns6AdVwgqTFFIJrTIzTWrTSGe6w1(nRDeHxQjSdg(GBljz4DFdmHKKjoQJK2iydm9V14sYeh1mBjTq(4egiVOWQmijuONi)GKO(7hCQft1POXurmlIjq078l(mBD00NnQjfliprsb6d1PaGc6RyHd8HhxsM4O2mdaOvxIk1e2bdFWTLKm8UVbMqsYeh1KWXaoXHrWgy6FRXztusMmoOBXtuyNk6FRXLKjoQnJEm5FtJy2c0bRyPwNQ9D2QThR1cVAnJEmRf6T)agETa)e6w1o)JR2EKG5SwBXawl6X3YUwBzCyTxuRfE1gTwTsTJld3QwAjtXcRf4Nq3Q2ZgRndtcjM12dDGOVutyhm8b3wsYW7(gycjjtCutlzkwOrWgy6FRXZVJ6OPnJEm5Ftv0)wJNFh1rtBg9yYtKuG(4fWc7GHZLKjoQjHJbCIdoQeY(hQpijQI(3ACjzIJAZOht(3uf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGOI(3ACjzIJABjjdVlFCcdev0)wJBg9yQHE7pGHZ)MQO)TgNEgbW8po(3SuRt1(oB12J1AHxTMrpM1c92FadVwGFcDRAN)XvBpsWCwRTyaRf94BzxRTmoS2lQ1cVAJwRwP2XLHBvlTKPyH1c8tOBv7zJ1MHjHeZA7Hoq0BuTJO2EKG5S2WNDR9pWArp(w21spLXnQf6WdkZz3AVOwl8Q9IABXpRLzlPfok1e2bdFWTLKm8UVbMqsYeh10tzCgbBGP)Tg3mXb6muhnnj0b4Ftvet)BnUKmXrnZwslKpoHbYl0)wJljtCuZSL0c5KIs6Xjmqaf0xrm9V14MrpMAO3(dy48VPk6FRXPNram)JJ)njIOsTovlHTXAPXXv7FG1gTAndYAHJAVO2)aRfE1ErTD(pKbYSBT0F4eOwMTKw4OwGFcDRAfZAL2HzTNn2Twl8Qf4tAIa1s3T2ZgR1wsYW7wlTKPyHLAc7GHp42ssgE33atiZehOZqD00KqhWiydm9V14sYeh1mBjTq(4egiVq)BnUKmXrnZwslKtkkPhNWarf9V14sYeh1MrpM8VzPwNQ14eRTx8R2lQDCcdKATLKm8U12(ZzxETe2gR9pWAJwTkACRDCcdKrT2yI1ch1ErTcJfF)QTfzTNnw7bzGu7eBxTHx7zJ1YSf3XzTIdu7zJ1schd4eRf612Mql7JxQjSdg(GBljz4DFdmHKKjoQjHJbCIdJGnW0)wJljtCuBljz4D5JtyG8IIgxJy2c0bROrq)Wm)Mhyfnc6hM5380wZGwMGvSutyhm8b3wsYW7(gycjjtCutlzkwOrWgy6FRXLKjoQz2sAH8Xjmqat)BnUKmXrnZwslKtkkPhNWarLbjHc9e5iPz0JjcOPLmflSutyhm8b3wsYW7(gycHgcMCWWnc2atkUWnz3lkQaLADQwfe(SBT)bwl9ugxTxul9hobQLzlPfoQf2QThRvMjkaDR1wmG1ocsS2wgK1gjDPMWoy4dUTKKH39nWessM4OMEkJZiydm9V14sYeh1mBjTq(4egiQO)TgxsM4OMzlPfYhNWa5f6FRXLKjoQz2sAHCsrj94egiLADQwJdcoN12dp7AfYA)(ehJAfZAHJAzbj0TQ9BwR4a12JeKyTZOV2WRLuCPutyhm8b3wsYW7(gycjjtCutchd4ehgbBGFfXgKek0tKFqsu)9do1I5lGv0yQifx4MS7ff2yezeZwGoyfnc6hM538aROrq)Wm)MN2Ag0YeSILADQ2olJgCIJA7HNDTZOVwszCy21OATHw21AlJdnQ2iRLoo7AjLU16XvRTyaRf94BzxlP4sTxu74BAg5vRD0xlP4sTq)qFanG1Mcau8R2HPKGult8APrJQDe12JemN1(hyTnyI1spLXvR4a12YyC0X8QT3g9ANrFTHxlP4sPMWoy4dUTKKH39nWeQbtutpLXvQjSdg(GBljz4DFdmHAzmo6yELALAc7GHp4Hj6ycUbtutpLXzeSbo)o2I0c5aWbdAoHUKD1SGKuCav0)wJdahmO5e6s2vZcssXb0Tmgh)BwQjSdg(GhMOJ5BGjulJXP9WGyeSbo)o2I0c5wjCm7QHmiBIQifx4MStDDCfOutyhm8bpmrhZ3atO)a1WdjnYfse8i(ZjEh0T05NUBPMWoy4dEyIoMVbMqaOC20r6yPMWoy4dEyIoMVbMqPaaf)0dtjbXiydmP4c3KDQtbBSsnHDWWh8WeDmFdmHiHzg5qhn9fjj6xPMWoy4dEyIoMVbMqdBy7GUL2m6X0iydm9V14sYeh1MrpMCGO3vXIyce9oxsM4O2m6XKNiPa9rPMWoy4dEyIoMVbMqsYeh1rsBeSbMfXei6DUKmXrTz0JjprbORk6FRXLKjoQz2sAH8XjmqEH(3ACjzIJAMTKwiNuuspoHbsPMWoy4dEyIoMVbMqsYeh10tzCgbBGzHb0f)4gq)S7MQyrmbIENtcZmYHoA6lss0pEIKc0hQZ4PGl1e2bdFWdt0X8nWe6IpZwhn9zJAsXcwQjSdg(GhMOJ5BGjKKmXrTz0JzPMWoy4dEyIoMVbMq53rD00MrpMgbBGP)TgxsM4O2m6XKde9EPwNQ9DpWA7SOJv7f1o68FevqI1kETOsxk12rjtCSwLnLXvlWpHUvTNnwlHJRJrOoQZQTh6arFTFFIJrT53DOBvBhLmXXAvqz2bV23zR2okzIJ1QGYSJAHJApzI(HagvBpwltCcUA)dS2ol6y12dpBOx7zJ1s446yeQJ6SA7Hoq0x73N4yuBpwl0pmZV5v7zJ12rDSAz2I740OAhrT9ibZzTdXawl84LAc7GHp4Hj6y(gyczM4aDgQJMMe6agbBGF1jt0pUKmXrnYSdvai9V14x8z26OPpButkwq(3ufas)Bn(fFMToA6Zg1KIfKNiPa9XlGjwyhmCUKmXrn9ughhvcz)d1hKe7C0)wJBM4aDgQJMMe6aCsrj94egievQ1PAFNTA7SOJvRTmCcUAPr0R9pqGAb(j0TQ9SXAjCCDSA7Hoq0BuT9ibZzT)bwl8Q9IAhD(pIkiXAfVwuPlLA7OKjowRYMY4Qf61E2yTVROZiuh1z12dDGONxQjSdg(GhMOJ5BGjKzId0zOoAAsOdyeSbM(3ACjzIJAZOht(3uf9V1453rD00MrpM8ejfOpEbmXc7GHZLKjoQPNY44Osi7FO(GKyNJ(3ACZehOZqD00KqhGtkkPhNWaHOsnHDWWh8WeDmFdmHKKjoQPNY4mc2adehpfaO4NEykji8ejfOpuNcakOai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGOoJvQ1PA7OzV0DuRYKmflSw5Q9SXArhO2OvBh1z12BJET53DOBv7zJ12rjtCSwJJLKm8U1orl0bKSBPMWoy4dEyIoMVbMqsYeh10sMIfAeSbM(3ACjzIJAZOht(3uf9V14sYeh1MrpM8ejfOpEXIbOk)o2I0c5sYeh12ssgE3sTovBhn7LUJAvMKPyH1kxTNnwl6a1gTApBS23v0z12dDGOV2EB0Rn)UdDRApBS2okzIJ1ACSKKH3T2jAHoGKDl1e2bdFWdt0X8nWessM4OMwYuSqJGnW0)wJNFh1rtBg9yY)MQO)TgxsM4O2m6XKde9Uk6FRXZVJ6OPnJEm5jskqF8cylgGQ87ylslKljtCuBljz4Dl1e2bdFWdt0X8nWessM4OMeogWjomc2adG0)wJFXNzRJM(SrnPyb5FtvNmr)4sYeh1iZourm9V14aOC20r6ihi6Dqbvyh0aQrhjH4aSIePcaP)Tg)IpZwhn9zJAsXcYtKuG(qDc7GHZLKjoQjHJbCIdoQeY(hQpijAeZwGoyfncLC2vZSfORHnW0)wJZMOKmzCq3sZSf3Xjhi6Dvet)BnUKmXrTz0Jj)BckOe)QtMOF8WaMMrpMiGkIP)Tgp)oQJM2m6XK)nbfuwetGO35OHGjhmCEIcqxIiIOsnHDWWh8WeDmFdmHKKjoQjHJbCIdJGnW0)wJZMOKmzCq3IpoHbcy6FRXztusMmoOBXjfL0JtyGOIfgqx8JBa9ZUBwQjSdg(GhMOJ5BGjKKmXrnjCmGtCyeSbM(3AC2eLKjJd6w8ef2PIfXei6DUKmXrTz0Jjprsb6dvet)BnE(DuhnTz0Jj)BckO0)wJljtCuBg9yY)MezeZwGoyfl1e2bdFWdt0X8nWessM4OosAJGnW0)wJljtCuZSL0c5JtyG8cydscf6jYV4i1KIsAMTKw4Outyhm8bpmrhZ3atijzIJA6PmoJGnW0)wJNFh1rtBg9yY)MGckP4c3KDQtrfOutyhm8bpmrhZ3ati0qWKdgUrWgy6FRXZVJ6OPnJEm5arVRI(3ACjzIJAZOhtoq07gb9dZ8BEAydmP4c3KDQdSXtbmc6hM5380qsseakhcwXsnHDWWh8WeDmFdmHKKjoQPLmflSuRuRtDQwHDWWh8mo5GHdMjodNAHDWWnc2alSdgohnem5GHZz2I74e6wQifx4MStDG74kGkIFv(DSfPfYhqt7W1JlssqbL(3A8b00oC94IKKpoHbcy6FRXhqt7W1JlssoPOKECcdeIk16uTV7bwlAiQf2QThjiXANrFTHxlP4sTIdullIjq07JALeRvOJ)v7f1sJ1(nl1e2bdFWZ4Kdg(BGjeAiyYbd3iyd8RYVJTiTq(aAAhUECrsQIuCHBYUxaBqsOqproAi0MStfXSiMarVZV4ZS1rtF2OMuSG8ejfOpEbSWoy4C0qWKdgohvcz)d1hKebfuwetGO35sYeh1MrpM8ejfOpEbSWoy4C0qWKdgohvcz)d1hKebfuIpzI(XZVJ6OPnJEmvXIyce9op)oQJM2m6XKNiPa9XlGf2bdNJgcMCWW5Osi7FO(GKirePI(3A887OoAAZOhtoq07QO)TgxsM4O2m6XKde9UkaK(3A8l(mBD00NnQjflihi6DvVYmrdAlgaxr(fFMToA6Zg1KIfSutyhm8bpJtoy4VbMqOHGjhmCJGnW53XwKwiFanTdxpUijv9kwyaDXpUb0p7UPkwetGO35sYeh1MrpM8ejfOpEbSWoy4C0qWKdgohvcz)d1hKel1e2bdFWZ4Kdg(BGjeAiyYbd3iydC(DSfPfYhqt7W1JlssvSWa6IFCdOF2DtvSiMarVZjHzg5qhn9fjj6hprsb6JxalSdgohnem5GHZrLq2)q9bjrvSiMarVZV4ZS1rtF2OMuSG8ejfOpEbmXgKek0tKtgN2mrgIa6losnD33e2bdNJgcMCWW5Osi7FO(GK4BkmrQyrmbIENljtCuBg9yYtKuG(4fWeBqsOqprozCAZezicOV4i10DFtyhmCoAiyYbdNJkHS)H6dsIVPWevQ1PAvMKPyH1cB1cpcg1EqsS2lQ9pWAV4iRvCGA7XATfdyTxe1skE3Az2sAHJsnHDWWh8mo5GH)gycjjtCutlzkwOrWgywetGO35x8z26OPpButkwqEIcqxvet)BnUKmXrnZwslKpoHbI6mijuONi)IJutkkPz2sAHdvSiMarVZLKjoQnJEm5jskqF8cyujK9puFqsufP4c3KDQZGKqHEICXutcDi5NutkUOnzNk6FRXZVJ6OPnJEm5arVtuPMWoy4dEgNCWWFdmHKKjoQPLmfl0iydmlIjq078l(mBD00NnQjfliprbORkIP)TgxsM4OMzlPfYhNWarDgKek0tKFXrQjfL0mBjTWHQtMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jskqF8cyujK9puFqsuLbjHc9e5hKe1F)GtTyQodscf6jYV4i1KIsAaCkD1Ti1IjrLAc7GHp4zCYbd)nWessM4OMwYuSqJGnWSiMarVZV4ZS1rtF2OMuSG8efGUQiM(3ACjzIJAMTKwiFCcde1zqsOqpr(fhPMuusZSL0chQi(vNmr)453rD00MrpMGcklIjq07887OoAAZOhtEIKc0hQZGKqHEI8losnPOKgaNsxDlsDgMePYGKqHEI8dsI6VFWPwmvNbjHc9e5xCKAsrjnaoLU6wKAXKOsnHDWWh8mo5GH)gycjjtCutlzkwOrWgyaK(3A8uaGIF6HPKGOn8NoMcnCcVU8XjmqadG0)wJNcau8tpmLeeTH)0XuOHt41LtkkPhNWarfX0)wJljtCuBg9yYbIEhuqP)TgxsM4O2m6XKNiPa9XlGTyaePIy6FRXZVJ6OPnJEm5arVdkO0)wJNFh1rtBg9yYtKuG(4fWwmaIk1e2bdFWZ4Kdg(BGjKKmXrn9ugNrWgydscf6jYn()Jt)hiGEykjiGckXai9V14Paaf)0dtjbrB4pDmfA4eED5Ftvai9V14Paaf)0dtjbrB4pDmfA4eED5JtyG8cas)BnEkaqXp9Wusq0g(thtHgoHxxoPOKECcdeIk1e2bdFWZ4Kdg(BGjKKmXrn9ugNrWgy6FRXntCGod1rttcDa(3ufas)Bn(fFMToA6Zg1KIfK)nvbG0)wJFXNzRJM(SrnPyb5jskqF8cyHDWW5sYeh10tzCCujK9puFqsSutyhm8bpJtoy4VbMqsYeh1KWXaoXHrWgyaK(3A8l(mBD00NnQjfli)BQ6Kj6hxsM4Ogz2HkIP)TghaLZMosh5arVdkOc7Ggqn6ijehGvKivedG0)wJFXNzRJM(SrnPyb5jskqFOoHDWW5sYeh1KWXaoXbhvcz)d1hKebfuwetGO35MjoqNH6OPjHoaprsb6dqbLfgqx8Jds3ekorgXSfOdwrJqjND1mBb6Aydm9V14Sjkjtgh0T0mBXDCYbIExfX0)wJljtCuBg9yY)MGckXV6Kj6hpmGPz0JjcOIy6FRXZVJ6OPnJEm5FtqbLfXei6DoAiyYbdNNOa0LiIiQuRt1(6WhFsS2ZgRfvYuCaeOwZ4q)GYSw6FRvRmeZAVOwpUANXaR1mo0pOmR1md2Outyhm8bpJtoy4VbMqsYeh1KWXaoXHrWgy6FRXztusMmoOBXtuyNk6FRXrLmfhab0MXH(bLj)BwQjSdg(GNXjhm83atijzIJAs4yaN4Wiydm9V14Sjkjtgh0T4jkStfX0)wJljtCuBg9yY)MGck9V1453rD00MrpM8VjOGcG0)wJFXNzRJM(SrnPyb5jskqFOoHDWW5sYeh1KWXaoXbhvcz)d1hKejYiMTaDWkwQjSdg(GNXjhm83atijzIJAs4yaN4Wiydm9V14Sjkjtgh0T4jkStf9V14Sjkjtgh0T4JtyGaM(3AC2eLKjJd6wCsrj94egigXSfOdwXsTovBhn7LUJAVSBTxulT4Gu7RFDTTiRLfXei69A7Hoq0pQL(F1c8jnR9SrYAHTApBSlbjwRqh)R2lQfvYeMyPMWoy4dEgNCWWFdmHKKjoQjHJbCIdJGnW0)wJZMOKmzCq3INOWov0)wJZMOKmzCq3INiPa9XlGjMy6FRXztusMmoOBXhNWaPZjSdgoxsM4OMeogWjo4Osi7FO(GKirVzXa4KIsezeZwGoyfl1e2bdFWZ4Kdg(BGjKJNnM6djnXXzeSbM4eBjoSf6jckOV6GmqGUfrQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoPOKECcdev0)wJljtCuBg9yYbIExfas)Bn(fFMToA6Zg1KIfKde9EPMWoy4dEgNCWWFdmHKKjoQJK2iydm9V14sYeh1mBjTq(4egiVa2GKqHEI8losnPOKMzlPfok1e2bdFWZ4Kdg(BGj04BIPhgeJGnWgKek0tKh)BabqD00SiMarVpurkUWnz3lG74kqPMWoy4dEgNCWWFdmHKKjoQPNY4mc2at)BnE(NOoA6ZorCW)MQO)TgxsM4OMzlPfYhNWarDkCPwNQ14OpPzTmBjTWrTWwT9yTnzoRLgNrFTNnwll8bMgWAjfxQ9StCyhtGAfhOw0qWKdgETWrTJdoN1gETSiMarVxQjSdg(GNXjhm83atijzIJAAjtXcnc2a)Q87ylslKpGM2HRhxKKQmijuONip(3acG6OPzrmbIEFOI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5KIs6XjmquDYe9JljtCuhjTkwetGO35sYeh1rsZtKuG(4fWwmavKIlCt29c4oUXuXIyce9ohnem5GHZtKuG(Outyhm8bpJtoy4VbMqsYeh10sMIfAeSbo)o2I0c5dOPD46XfjPkdscf6jYJ)nGaOoAAwetGO3hQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoPOKECcdevNmr)4sYeh1rsRIfXei6DUKmXrDK08ejfOpEbSfdqfP4c3KDVaUJBmvSiMarVZrdbtoy48ejfOpErHnwPwNQ14OpPzTmBjTWrTWwTrsxlCuBIcq3snHDWWh8mo5GH)gycjjtCutlzkwOrWgydscf6jYJ)nGaOoAAwetGO3hQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoPOKECcdevNmr)4sYeh1rsRIfXei6DUKmXrDK08ejfOpEbSfdqfP4c3KDVaUJBmvSiMarVZrdbtoy48ejfOpur8RYVJTiTq(aAAhUECrsckO0)wJpGM2HRhxKK8ejfOpEbSIgpIk16uTDuYehRvzsMIfw7Wo(tGATqhtzo7wlnw7zJ1oLXvltgxTrR2ZgRTJ6SA7Hoq0xQjSdg(GNXjhm83atijzIJAAjtXcnc2at)BnUKmXrTz0Jj)BQI(3ACjzIJAZOhtEIKc0hVa2IbOI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5KIs6XjmqurmlIjq07C0qWKdgoprsb6dqbn)o2I0c5sYeh12ssgExIk16uTDuYehRvzsMIfw7Wo(tGATqhtzo7wlnw7zJ1oLXvltgxTrR2ZgR9DfDwT9qhi6l1e2bdFWZ4Kdg(BGjKKmXrnTKPyHgbBGP)Tgp)oQJM2m6XK)nvr)BnUKmXrTz0Jjhi6Dv0)wJNFh1rtBg9yYtKuG(4fWwmav0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNuuspoHbIkIzrmbIENJgcMCWW5jskqFakO53XwKwixsM4O2wsYW7suPwNQTJsM4yTktYuSWAh2XFculnw7zJ1oLXvltgxTrR2ZgRLWX1XQTh6arFTWwTWRw4OwpUA)deO2E4zx77k6SAJS2oQZk1e2bdFWZ4Kdg(BGjKKmXrnTKPyHgbBGP)TgxsM4O2m6XKde9Uk6FRXZVJ6OPnJEm5arVRcaP)Tg)IpZwhn9zJAsXcY)MQaq6FRXV4ZS1rtF2OMuSG8ejfOpEbSfdqf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjfL0JtyGuQ1PAnoTrV2ZgR9K0cVAHJAHETOsi7FyTP4wyTIdu7zJjwlCulzKyTNT41gowl6izxJQ9pWAPLmflSwzu7icVwzuB34xRTyaRf94BzxlZwslCu7f1AdVAL5Sw0rsioQf2Q9SXA7OKjowRYcsAjbir)QDIwOdiz3AHJAXo)hAAIaLAc7GHp4zCYbd)nWessM4OMwYuSqJGnWgKek0tKJKMrpMiGMwYuSqv0)wJljtCuZSL0c5JtyGOoWelSdAa1OJKqCy8PirQe2bnGA0rsiouNIQO)TghaLZMosh5arVxQjSdg(GNXjhm83atijzIJAujZzmGHBeSb2GKqHEICK0m6Xeb00sMIfQI(3ACjzIJAMTKwiFCcdKxO)TgxsM4OMzlPfYjfL0JtyGOsyh0aQrhjH4qDkQI(3ACauoB6iDKde9EPMWoy4dEgNCWWFdmHKKjoQPNY4k1e2bdFWZ4Kdg(BGjeAiyYbd3iydSbjHc9e5X)gqauhnnlIjq07JsnHDWWh8mo5GH)gycjjtCutlzkwi1rDuua]] )

    
end