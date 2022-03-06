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
        return covenant.kyrian and 4 or 3
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


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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
    end )


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


    spec:RegisterPack( "Arcane", 20220226, [[dev0whqivj5rsf5sKGq0MijFsvQrHqofcAvab8kGOzrH6wsfu2fQ(fc0WOq6yKilJKkptQatdiORHaSnsq5BQsQmoPcY5KkeRdb07ibHaZtvI7bu7JcXbLkulKevpuQOMijOsDrsqQnsccPpscQKrscc1jbc0kjP8ssqi0mbcDtPcPDssv)KeemuvjLLscsEQQyQKaxLeeTvsqiOVscQASKOSxK8xsnyLomXIrQhJYKbCzOnlLptjJMsDAqRwQGQxdKMTIUnI2nv)wy4u0XvLu1Yf9CfMUkxxvTDk47svJNe68sLwpjOI5JqTFjtPeLcOEaKdPuV6mQ6uNrvN6uyC1PoqO6iaqi1Z11ePEmfgOIfs94cjs90XjtCK6Xu6odbGsbupJ4NmK6X(oZbbsqcAbp7pnNfKeCaj)t5GHZsPDeCajzeK6H(dNhiOtrt9aihsPE1zu1PoJQo1PW4QtDGq1raQJ6zyImk1RWuh1JneaaDkAQhaCWOE6OIfwBhNmXXsnfII05xYU1QocW4AvNrvN6k1k16ST4w4Gal16WQvHCG1EDnHmzw7dKSZ1AloWe6w1gTAz2I74SwOFyMFZdgETqFCOauB0Q9ntCgo1c7GH)MxQ1HvBNTf3cRvsM4Og6nOdVU1ErTsYeh12ssgE3AjcE16ObmRTh9R2j0awRmQvsM4O2wsYW7siVuRdRwfUd)9vRcTHGjhwl0RTJviOqxBh(FC1sJm5pWA7g)3jwB8VAJwTP4wyTIduRhxT)b0TQTJtM4yTk0kAoJbmCEPwhwTDmqh(FC1AMWiHx3AVO2)aRTJtM4yTVw0J57rTyRHSdAaRLfXei69APLbcuB412zfUvOQfBnKDdEPwhwTkKdS2XLq2vRzgmCmGUvTxuBIaFgwBNFnfYApijwlWhR9IA)UJmCmKSBTD8RbI12Ie0bVuRdR2oAyabQ1GKqHEIdcYKj7pLdg(O2lQfe)sTKbWFI1ErTjc8zyTD(1uiR9GKiN6zch3Gsbup2ssgExkfqPELOua1d6c9ebOuo1JWoy4upOHGjhmCQhaCWsO5bdN6beSv7m6Rn8AjfxQvCGAzrmbIEFuRKyTSGe6w1(nnUwROwXgfGAfhOw0qq9Ws4HjuOEifx4MSR2xaxBhy0AvvRbjHc9e5X)gqauhnnlIjq07JAvvlr1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAFPwLmATesDuQxDukG6bDHEIaukN6bahSeAEWWPEu4XA7f)Q9IAhNWaTwBjjdVBTT)C2LxRcSXA)dS2OvRskSAhNWaDuRnMyTWrTxuRWyX3VABrw7zJ1EqgO1oX2vB41E2yTmBXDCwR4a1E2yTKWXaoXAHETTj0Y(4upSeEycfQhIQ1GKqHEI8Xjmq12ssgE3AjM4Apijw7l1QKrRLWAvvl9V14sYeh12ssgEx(4egO1(sTkPWOEy2c0PEuI6ryhmCQhjzIJAs4yaN4G6OuFhqPaQh0f6jcqPCQhHDWWPEKKjoQjHJbCIdQhaCWsO5bdN6rH3g9A)dOBvRcnPz3eLzTkesaxCgACTmzC1k12W(ArfVuQLeogWjoQT3goXA7f4bDRABrw7zJ1s)BTALR2ZgRDCsE1gTApBS2g0Y(OEyj8Wekup4R)dnnraosA2nrzQJeWfNH1QQ2dsI1(sTDGrRvvTSiMarVZrsZUjktDKaU4mKNiPa9rTgPwLuyDOAvv7RQvyhmCosA2nrzQJeWfNHCa4qONia1rPEqiLcOEqxONiaLYPEe2bdN6ze)5eVd6w68t3L6HLWdtOq9q)BnUKmXrTz0Jj)BwRQApjTWJdahN4mS2xaxRsgL6XfsK6ze)5eVd6w68t3L6OupbqPaQh0f6jcqPCQhHDWWPEgXFoX7GULo)0DPEyj8WekupgKek0tKJKMrpMiGMwYuSWAvvllIjq078l(mBD00NnQjfliprsb6JAFbCTOIi7FO(GKyTQQLfXei6DUKmXrTz0Jjprsb6JAFbCTevlQiY(hQpijwliqTQRwcRvvTNKw4XbGJtCgwRrQvjJs94cjs9mI)CI3bDlD(P7sDuQxHrPaQh0f6jcqPCQhwcpmHc1JbjHc9e5iPz0JjcOPLmflSwv1YIyce9o)IpZwhn9zJAsXcYtKuG(O2xaxlQiY(hQpijwRQAzrmbIENljtCuBg9yYtKuG(O2xaxlr1IkIS)H6dsI1ccuR6QLWAvvlr1(QAXx)hAAIa8r8Nt8oOBPZpD3AjM4AzHd8HhxsM4O2mdaOvxEkoO1AeW1sa1smX1suTSiMarVZhXFoX7GULo)0D5jskqFuRrQvjLmATQQ9K0cpoaCCIZWAnsTkz0AjSwIjUwIQLfXei6D(i(ZjEh0T05NUlprsb6JAFbCTOIi7FO(GKyTQQ9K0cpoaCCIZWAFbCTkz0AjSwcPEe2bdN6jfaO4NEykjOuhL6FDukG6bDHEIaukN6HLWdtOq9yqsOqprEh(FC6)ab0dtjbTwv1YIyce9oxsM4O2m6XKNiPa9rTVaUwurK9puFqsSwv1suTVQw81)HMMiaFe)5eVd6w68t3TwIjUww4aF4XLKjoQnZaaA1LNIdATgbCTeqTetCTevllIjq078r8Nt8oOBPZpDxEIKc0h1AKAvsjJwRQApjTWJdahN4mSwJuRsgTwcRLyIRLOAzrmbIENpI)CI3bDlD(P7YtKuG(O2xaxlQiY(hQpijwRQApjTWJdahN4mS2xaxRsgTwcRLqQhHDWWPEU4ZS1rtF2OMuSGuhL67qukG6bDHEIaukN6HLWdtOq9yMObTfdGRe)IpZwhn9zJAsXcs9iSdgo1JKmXrTz0Jj1rP(ocLcOEqxONiaLYPEyj8WekupgKek0tKJKMrpMiGMwYuSWAvvllIjq078uaGIF6HPKGYtKuG(O2xaxlQiY(hQpijwRQAnijuONi)GKO(7hCQfZAnc4AvNrRvvTev7RQLfoWhECjzIJAZmaGwD5Ol0teOwIjU2xvRbjHc9e5YSx6o0JUotZIyce9(OwIjUwwetGO35x8z26OPpButkwqEIKc0h1(c4AjQwurK9puFqsSwqGAvxTewlHupc7GHt9KFh1rtBg9ysDuQxjJsPaQh0f6jcqPCQhwcpmHc1JbjHc9e5iPz0JjcOPLmflSwv1AMObTfdGRep)oQJM2m6XK6ryhmCQNuaGIF6HPKGsDuQxjLOua1d6c9ebOuo1dlHhMqH6XGKqHEI8o8)40)bcOhMscATQQ9v1AqsOqprUDmbGUL(IJK6ryhmCQNl(mBD00NnQjfli1rPELuhLcOEqxONiaLYPEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6rHCG1QohOwjzIJ1slzkwyTqV2o(1aPcLcHxR2WNDRf2Qv5ZiaM)XvR4a1kxTtugxTQR2o35rTMzWyia1dlHhMqH6H(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0Avvl9V1453rD00MrpM8VzTQQL(3ACjzIJAZOht(3Swv1s)BnUKmXrTTKKH3LpoHbATgbCTkPWQvvT0)wJljtCuBg9yYtKuG(O2xaxRWoy4CjzIJAAjtXc5OIi7FO(GKyTQQL(3AC6zeaZ)44FtQJs9k1bukG6bDHEIaukN6ryhmCQN87OoAAZOhtQhaCWsO5bdN6rHCG1QohOwfQ41Qf612XVwTHp7wlSvRYNram)JRwXbQvD125opQ1mdg1dlHhMqH6H(3A887OoAAZOhtoq071QQw6FRXPNram)JJ)nRvvTevRbjHc9e5hKe1F)GtTywRrQTdmATetCTSiMarVZtbak(PhMsckprsb6JAnsTkPUAjSwv1suT0)wJljtCuBljz4D5JtyGwRraxRseqTetCT0)wJZMOKmzCq3IpoHbATgbCTkvlH1QQwIQ9v1Ych4dpUKmXrTzgaqRUC0f6jculXex7RQ1GKqHEICz2lDh6rxNPzrmbIEFulHuhL6vcesPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1MrpMCGO3RvvTevRbjHc9e5hKe1F)GtTywRrQTdmATetCTSiMarVZtbak(PhMsckprsb6JAnsTkPUAjSwv1suTVQww4aF4XLKjoQnZaaA1LJUqprGAjM4AFvTgKek0tKlZEP7qp66mnlIjq07JAjK6ryhmCQN87OoAAZOhtQJs9kraukG6bDHEIaukN6HLWdtOq9yqsOqprosAg9yIaAAjtXcRvvTevl9V14sYeh1mBjTq(4egO1AeW1QUAjM4AzrmbIENljtCuhjnprbOBTewRQAjQ2xv7jt0pE(DuhnTz0JjhDHEIa1smX1YIyce9op)oQJM2m6XKNiPa9rTgPwcOwcRvvTSiMarVZLKjoQnJEm5jskqFOrfnr2Ha1AeW12bgTwv1suTVQww4aF4XLKjoQnZaaA1LJUqprGAjM4AFvTgKek0tKlZEP7qp66mnlIjq07JAjK6ryhmCQNuaGIF6HPKGsDuQxjfgLcOEqxONiaLYPEe2bdN65IpZwhn9zJAsXcs9aGdwcnpy4upk82OxB(Dh6w1AMba0QRX1(hyTxCK1s3Tw4nWzRwOxBKayw7f1ktOLxl8QThE21kMupSeEycfQhdscf6jYpijQ)(bNAXS2xQLamATQQ1GKqHEI8dsI6VFWPwmR1i12bgTwv1suTVQw81)HMMiaFe)5eVd6w68t3TwIjUww4aF4XLKjoQnZaaA1LNIdATgbCTeqTesDuQxPxhLcOEqxONiaLYPEyj8WekupgKek0tK3H)hN(pqa9WusqRvvT0)wJljtCuZSL0c5JtyGw7l1s)BnUKmXrnZwslKtkkQhNWaL6ryhmCQhjzIJ6iPPok1RuhIsbupOl0teGs5upSeEycfQhaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqRfCTai9V14Paaf)0dtjbvB4pDmfA4eED5KII6XjmqPEe2bdN6rsM4OMwYuSqQJs9k1rOua1d6c9ebOuo1dlHhMqH6XGKqHEI8o8)40)bcOhMscATetCTevlas)BnEkaqXp9Wusq1g(thtHgoHxx(3Swv1cG0)wJNcau8tpmLeuTH)0XuOHt41LpoHbATVulas)BnEkaqXp9Wusq1g(thtHgoHxxoPOOECcd0AjK6ryhmCQhjzIJA6PmoQJs9QZOukG6bDHEIaukN6ryhmCQhjzIJAAjtXcPEaWblHMhmCQhfYbwlj0H1QCjtXcRLgVEe9Atbak(v7Wusqh1cB1(DamRv5GyT9WZo(xTa4u6cDRAvOeaO4xTpMscATqauMZUupSeEycfQh6FRXZVJ6OPnJEm5FZAvvl9V14sYeh1MrpMCGO3RvvT0)wJtpJay(hh)BwRQAzrmbIENNcau8tpmLeuEIKc0h1(c4AvYO1QQw6FRXLKjoQTLKm8U8XjmqR1iGRvjfg1rPE1PeLcOEqxONiaLYPEe2bdN6rsM4OosAQhaCWsO5bdN6rHCG1gjDTHxldO2VpXXOwXSw4OwwqcDRA)M1oIWPEyj8Wekup0)wJljtCuZSL0c5JtyGw7l12b1QQwdscf6jYpijQ)(bNAXSwJuRsgTwv1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ1i1sa1smX1(QAzHd8HhxsM4O2mdaOvxo6c9ebQLqQJs9QtDukG6bDHEIaukN6ryhmCQhjzIJAs4yaN4G6HzlqN6rjQhwcpmHc1d9V14Sjkjtgh0T4jkSRwv1s)BnUKmXrTz0Jj)BsDuQxDDaLcOEqxONiaLYPEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6beSvBpwRfE1Ag9ywl0B)bm8Ab(j0TQD(hxT9475SwBXawl6X3YUwBzCyTxuRfE1gTwTsTJld3QwAjtXcRf4Nq3Q2ZgRndtckM12dDGON6HLWdtOq9q)BnE(DuhnTz0Jj)BwRQAP)Tgp)oQJM2m6XKNiPa9rTVaUwHDWW5sYeh1KWXaoXbhvez)d1hKeRvvT0)wJljtCuBg9yY)M1QQw6FRXLKjoQz2sAH8XjmqRfCT0)wJljtCuZSL0c5KII6XjmqRvvT0)wJljtCuBljz4D5JtyGwRQAP)Tg3m6Xud92FadN)nRvvT0)wJtpJay(hh)BsDuQxDGqkfq9GUqprakLt9iSdgo1JKmXrn9ugh1daoyj08GHt9ac2QThR1cVAnJEmRf6T)agETa)e6w1o)JR2E89CwRTyaRf94BzxRTmoS2lQ1cVAJwRwP2XLHBvlTKPyH1c8tOBv7zJ1MHjbfZA7Hoq0BCTJO2E89CwB4ZU1(hyTOhFl7APNY4g1cD4bL5SBTxuRfE1ErTT4N1YSL0chupSeEycfQh6FRXntCGod1rttcDa(3Swv1suT0)wJljtCuZSL0c5JtyGw7l1s)BnUKmXrnZwslKtkkQhNWaTwIjU2xvlr1s)BnUz0JPg6T)ago)BwRQAP)TgNEgbW8po(3SwcRLqQJs9QJaOua1d6c9ebOuo1JWoy4upMjoqNH6OPjHoa1daoyj08GHt9OaBSwACC1(hyTrRwZGSw4O2lQ9pWAHxTxu7R)dzGo7wl9hobQLzlPfoQf4Nq3QwXSwPDyw7zJDR1cVAb(KMiqT0DR9SXATLKm8U1slzkwi1dlHhMqH6H(3ACjzIJAMTKwiFCcd0AFPw6FRXLKjoQz2sAHCsrr94egO1QQw6FRXLKjoQnJEm5FtQJs9QtHrPaQh0f6jcqPCQhaCWsO5bdN6rHhRTx8R2lQDCcd0ATLKm8U12(ZzxETkWgR9pWAJwTkPWQDCcd0rT2yI1ch1ErTcJfF)QTfzTNnw7bzGw7eBxTHx7zJ1YSf3XzTIdu7zJ1schd4eRf612Mql7Jt9iSdgo1JKmXrnjCmGtCq9a9dZ8BEupkr9WSfOt9Oe1dlHhMqH6H(3ACjzIJABjjdVlFCcd0AFPwLuyupq)Wm)MN2Ag0YK6rjQJs9Q71rPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1mBjTq(4egO1cUw6FRXLKjoQz2sAHCsrr94egO1QQwdscf6jYrsZOhteqtlzkwi1JWoy4upsYeh10sMIfsDuQxDDikfq9GUqprakLt9Ws4HjuOEifx4MSR2xQvjcG6ryhmCQh0qWKdgo1rPE11rOua1d6c9ebOuo1JWoy4upsYeh10tzCupa4GLqZdgo1JcbF2T2)aRLEkJR2lQL(dNa1YSL0ch1cB12J1kZefGU1AlgWAhbjwBldYAJKM6HLWdtOq9q)BnUKmXrnZwslKpoHbATQQL(3ACjzIJAMTKwiFCcd0AFPw6FRXLKjoQz2sAHCsrr94egOuhL67aJsPaQh0f6jcqPCQhaCWsO5bdN6rHOW5S2E4zxRqw73N4yuRywlCulliHUvTFZAfhO2E8DI1oJ(AdVwsXfQhHDWWPEKKjoQjHJbCIdQhOFyMFZJ6rjQhMTaDQhLOEyj8WekupVQwIQ1GKqHEI8dsI6VFWPwmR9fW1QKrRvvTKIlCt2v7l12bgTwcPEG(Hz(npT1mOLj1JsuhL67aLOua1d6c9ebOuo1daoyj08GHt98Az0GtCuBp8SRDg91skJdZUgxRn0YUwBzCOX1gzT0XzxlP0TwpUATfdyTOhFl7AjfxQ9IAhFtZiVATJ(AjfxQf6h6dObS2uaGIF1omLe0AzIxlnACTJO2E89Cw7FG12Gjwl9ugxTIduBlJXrhZR2EB0RDg91gETKIlupc7GHt90GjQPNY4Ook13bQJsbupc7GHt90YyC0X8OEqxONiaLYPoQJ6Pbh2q3shMOJjLcOuVsukG6bDHEIaukN6ryhmCQh0qWKdgo1daoyj08GHt9OWBJET53DOBvlcpBmR9SXAFEQnYAvGcFTt0cDajH4W4A7XA7f)Q9IAvOne1sJTiXApBSwfexhLGD8RvBp0bIEETkKdSw4vRmQDeHxRmQvHkETATLrTnOdh2iqTXpRThFBaRDyI(vB8ZAz2sAHdQhwcpmHc1dr1MFhBrAH8djnJuM6Ejn5Ol0teOwIjUwIQn)o2I0c5dOPD46XfjjhDHEIa1QQ2xvRbjHc9e5MjA(NtnAiQfCTkvlH1syTQQLOAP)Tgp)oQJM2m6XKde9ETetCTMjAqBXa4kXLKjoQPLmflSwcRvvTSiMarVZZVJ6OPnJEm5jskqFqDuQxDukG6bDHEIaukN6ryhmCQh0qWKdgo1daoyj08GHt9ac2QThFBaRTbD4WgbQn(zTSiMarVxBp0bI(rTIdu7We9R24N1YSL0chgxRzcJeEqfoyTk0gIAddywlAaZUNn0TQfNdK6HLWdtOq9CYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAvvllIjq07CjzIJAZOhtEIKc0h1QQw6FRXLKjoQnJEm5arVxRQAP)Tgp)oQJM2m6XKde9ETQQ1mrdAlgaxjUKmXrnTKPyHuhL67akfq9GUqprakLt9Ws4HjuOEYVJTiTqoaCWGMtOlzxnlijfhGJUqprGAvvl9V14aWbdAoHUKD1SGKuCaDlJXX)Mupc7GHt90GjQPNY4Ook1dcPua1d6c9ebOuo1dlHhMqH6j)o2I0c5wjCm7QHmiBIC0f6jcuRQAjfx4MSRwJuBhHaOEe2bdN6PLX40EyqOok1taukG6bDHEIaukN6ryhmCQhjzIJAs4yaN4G6HzlqN6rjQhwcpmHc1t(DSfPfYLKjoQTLKm8UC0f6jcuRQAP)TgxsM4O2wsYW7YhNWaT2xQL(3ACjzIJABjjdVlNuuupoHbATQQLOAjQw6FRXLKjoQnJEm5arVxRQAzrmbIENljtCuBg9yYtua6wlH1smX1cG0)wJFXNzRJM(SrnPyb5FZAjK6OuVcJsbupOl0teGs5upSeEycfQN87ylslKpGM2HRhxKKC0f6jcq9iSdgo1t(DuhnTz0Jj1rP(xhLcOEqxONiaLYPEyj8WekupSiMarVZZVJ6OPnJEm5jkaDPEe2bdN6rsM4OosAQJs9Dikfq9GUqprakLt9Ws4HjuOEyrmbIENNFh1rtBg9yYtua6wRQAP)TgxsM4OMzlPfYhNWaT2xQL(3ACjzIJAMTKwiNuuupoHbk1JWoy4upsYeh10tzCuhL67iukG6bDHEIaukN6HLWdtOq98QAZVJTiTq(HKMrktDVKMC0f6jculXexllCGp84wW2PJM(Sr9eYS5Ol0teG6ryhmCQhauoB6iDK6OuVsgLsbupc7GHt9KFh1rtBg9ys9GUqprakLtDuQxjLOua1d6c9ebOuo1JWoy4upsYeh1KWXaoXb1daoyj08GHt9ac2QThFNyTYvlPOyTJtyGoQnA125oxR4a12J1Algq)9v7FGa12rdfuBx8mU2)aRvQDCcd0AVOwZenG(vl53z2q3Q2VpXXO287o0TQ9SXAviwsYW7w7eTqhqYUupSeEycfQh6FRXztusMmoOBXtuyxTQQL(3AC2eLKjJd6w8XjmqRfCT0)wJZMOKmzCq3ItkkQhNWaTwv1YcdOl(XnG(z3nRvvTSiMarVZjHzg5qhn9fjj6hprbOBTQQ9v1AqsOqprosAg9yIaAAjtXcRvvTSiMarVZLKjoQnJEm5jkaDPok1RK6Oua1d6c9ebOuo1dlHhMqH65v1MFhBrAH8djnJuM6Ejn5Ol0teOwv1suTVQ287ylslKpGM2HRhxKKC0f6jculXexlr1AqsOqprUzIM)5uJgIAbxRs1QQw6FRXLKjoQz2sAH8XjmqRfCT0)wJljtCuZSL0c5KII6XjmqRLWAjK6bahSeAEWWPEuFKKYC2T2ESwtbM1Aghm8A)dS2E4zxBh)Agxl9)QfE12dNZANY4QDgUvTOhFl7ABrwlDC21E2yTkuXRvR4a12XVwT9qhi6h1(9jog1MF3HUvTNnw7ZtTrwRcu4RDIwOdijehupc7GHt9yghmCQJs9k1bukG6bDHEIaukN6HLWdtOq9q)BnE(DuhnTz0Jjhi69AjM4Ant0G2IbWvIljtCutlzkwi1JWoy4upaOC20r6i1rPELaHukG6bDHEIaukN6HLWdtOq9q)BnE(DuhnTz0Jjhi69AjM4Ant0G2IbWvIljtCutlzkwi1JWoy4upPaaf)0dtjbL6OuVseaLcOEqxONiaLYPEyj8Wekup0)wJNFh1rtBg9yYtKuG(O2xQLOAvy1cYAvxTGa1MFhBrAH8b00oC94IKKJUqprGAjK6ryhmCQhsyMro0rtFrsI(rDuQxjfgLcOEqxONiaLYPEe2bdN6rsM4O2m6XK6bahSeAEWWPEu4TrV287o0TQ9SXAviwsYW7w7eTqhqYUgx7FG12XVwT0ylsSwfexhT2lQf4tAwRuB7pNDRDCcdueOwAjtXcPEyj8WekupgKek0tKJKMrpMiGMwYuSWAvvl9V1453rD00MrpM8VzTQQLOAjfx4MSR2xQLOAvhbuliRLOAvYO1ccullmGU4hh0Uju8AjSwcRLyIRL(3AC2eLKjJd6w8XjmqRfCT0)wJZMOKmzCq3ItkkQhNWaTwcPok1R0RJsbupOl0teGs5upSeEycfQhdscf6jYrsZOhteqtlzkwyTQQL(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0Avvl9V14sYeh1MrpM8Vj1JWoy4upsYeh10sMIfsDuQxPoeLcOEqxONiaLYPEe2bdN6ze)5eVd6w68t3L6HLWdtOq9q)BnE(DuhnTz0Jjhi69AjM4Ant0G2IbWvIljtCutlzkwyTetCTMjAqBXa4kXtbak(PhMscATetCTevRzIg0wmaUsCauoB6iDSwv1(QAZVJTiTq(aAAhUECrsYrxONiqTes94cjs9mI)CI3bDlD(P7sDuQxPocLcOEqxONiaLYPEyj8Wekup0)wJNFh1rtBg9yYbIEVwIjUwZenOTyaCL4sYeh10sMIfwlXexRzIg0wmaUs8uaGIF6HPKGwlXexlr1AMObTfdGRehaLZMoshRvvTVQ287ylslKpGM2HRhxKKC0f6jculHupc7GHt9CXNzRJM(SrnPybPok1RoJsPaQh0f6jcqPCQhwcpmHc1JzIg0wmaUs8l(mBD00NnQjfli1JWoy4upsYeh1MrpMuhL6vNsukG6bDHEIaukN6ryhmCQhZehOZqD00KqhG6bahSeAEWWPEuihyTVw0rR9IAhV(pIkCWAfVwuXlLA74KjowRYNY4Qf4Nq3Q2ZgRvbX1rjyh)A12dDGOV2VpXXO287o0TQTJtM4yTk0m7GxliyR2oozIJ1QqZSJAHJApzI(HagxBpwlt83xT)bw7RfD0A7HNn0R9SXAvqCDuc2XVwT9qhi6R97tCmQThRf6hM538Q9SXA74oATmBXDCACTJO2E89Cw7qmG1cpo1dlHhMqH65v1EYe9JljtCuJm7GJUqprGAvvlas)Bn(fFMToA6Zg1KIfK)nRvvTai9V14x8z26OPpButkwqEIKc0h1(c4AjQwHDWW5sYeh10tzCCurK9puFqsSwqGAP)Tg3mXb6muhnnj0b4KII6XjmqRLqQJs9QtDukG6bDHEIaukN6ryhmCQhZehOZqD00KqhG6bahSeAEWWPEabB1(ArhTwBz4VVAPr0R9pqGAb(j0TQ9SXAvqCD0A7Hoq0BCT9475S2)aRfE1ErTJx)hrfoyTIxlQ4LsTDCYehRv5tzC1c9ApBSwfQ41iyh)A12dDGONt9Ws4HjuOEO)TgxsM4O2m6XK)nRvvT0)wJNFh1rtBg9yYtKuG(O2xaxlr1kSdgoxsM4OMEkJJJkIS)H6dsI1ccul9V14MjoqNH6OPjHoaNuuupoHbATesDuQxDDaLcOEqxONiaLYPEyj8WekupaXXtbak(PhMsckprsb6JAnsTeqTetCTai9V14Paaf)0dtjbvB4pDmfA4eED5JtyGwRrQ1Oupc7GHt9ijtCutpLXrDuQxDGqkfq9GUqprakLt9iSdgo1JKmXrnTKPyHupa4GLqZdgo1JcpwBV4xTxulPakw74NyT9yT2IbSw0JVLDTKIl12IS2ZgRf9dMyTD8RvBp0bIEJRfnGETWwTNnM47rTJdoN1EqsS2ejfOdDRAdVwfQ4141ccEVh1g(SBT04Dyw7f1s)tV2lQvHdMrTIduRcTHOwyR287o0TQ9SXAFEQnYAvGcFTt0cDajH4Gt9Ws4HjuOEyrmbIENljtCuBg9yYtua6wRQAjfx4MSR2xQLOAbHgTwqwlr1QKrRfeOwwyaDXpoODtO41syTewRQAP)TgxsM4OMzlPfYhNWaTwW1s)BnUKmXrnZwslKtkkQhNWaTwv1suTVQ287ylslKpGM2HRhxKKC0f6jculXexRbjHc9e5MjA(NtnAiQfCTkvlH1QQ2xvB(DSfPfYpK0mszQ7L0KJUqprGAvv7RQn)o2I0c5sYeh12ssgExo6c9ebOok1RocGsbupOl0teGs5upc7GHt9ijtCutlzkwi1daoyj08GHt9OCjtXcRDyh)jqTEC1sJ1(hiqTYv7zJ1IoqTrR2o(1Qf2QvH2qWKdgETWrTjkaDRvg1cKHPj0TQLzlPfoQThoN1skGI1cVApbuS2z4wyw7f1s)tV2ZoJVLDTjskqh6w1skUq9Ws4HjuOEO)TgxsM4O2m6XK)nRvvT0)wJljtCuBg9yYtKuG(O2xaxRfdOwv1YIyce9ohnem5GHZtKuG(G6OuV6uyukG6bDHEIaukN6ryhmCQhjzIJAAjtXcPEaWblHMhmCQhLlzkwyTd74pbQvM9s3rT0yTNnw7ugxTmzC1c9ApBSwfQ41QTh6arFTYOwfexhT2E4CwBIJlsS2ZgRLzlPfoQDyI(r9Ws4HjuOEO)Tgp)oQJM2m6XK)nRvvT0)wJljtCuBg9yYbIEVwv1s)BnE(DuhnTz0Jjprsb6JAFbCTwmGAvv7RQn)o2I0c5sYeh12ssgExo6c9ebOok1RUxhLcOEqxONiaLYPEy2c0PEuI6bLC2vZSfORHnQh6FRXztusMmoOBPz2I74Kde9UkIO)TgxsM4O2m6XK)njMyIE1jt0pEyatZOhteqfr0)wJNFh1rtBg9yY)MetmlIjq07C0qWKdgoprbOlHesi1dlHhMqH6baP)Tg)IpZwhn9zJAsXcY)M1QQ2tMOFCjzIJAKzhC0f6jcuRQAjQw6FRXbq5SPJ0roq071smX1kSdAa1OJKqCul4AvQwcRvvTai9V14x8z26OPpButkwqEIKc0h1AKAf2bdNljtCutchd4ehCurK9puFqsK6ryhmCQhjzIJAs4yaN4G6OuV66qukG6bDHEIaukN6ryhmCQhjzIJAs4yaN4G6bahSeAEWWPEabB12JVtSwdOF2DtJRfssIaq5Wz3A)dS2o35A7TrVwMyAIa1ErTEC12lJdR1md2O2wgK12rdfq9Ws4HjuOEyHb0f)4gq)S7M1QQw6FRXztusMmoOBXhNWaTwW1s)BnoBIsYKXbDloPOOECcduQJs9QRJqPaQh0f6jcqPCQhaCWsO5bdN655K8Q9pGUvTDUZ12XD0A7TrV2o(1Q1wg1sJOx7FGaupSeEycfQh6FRXztusMmoOBXtuyxTQQLfXei6DUKmXrTz0Jjprsb6JAvvlr1s)BnE(DuhnTz0Jj)BwlXexl9V14sYeh1MrpM8VzTes9WSfOt9Oe1JWoy4upsYeh1KWXaoXb1rP(oWOukG6bDHEIaukN6HLWdtOq9q)BnUKmXrnZwslKpoHbATVaUwdscf6jYV4i1KIIAMTKw4G6ryhmCQhjzIJ6iPPok13bkrPaQh0f6jcqPCQhwcpmHc1d9V1453rD00MrpM8VzTetCTKIlCt2vRrQvjcG6ryhmCQhjzIJA6PmoQJs9DG6Oua1d6c9ebOuo1JWoy4upOHGjhmCQhOFyMFZtdBupKIlCt2zeWDicG6b6hM5380qsseakhs9Oe1dlHhMqH6H(3A887OoAAZOhtoq071QQw6FRXLKjoQnJEm5arVtDuQVd6akfq9iSdgo1JKmXrnTKPyHupOl0teGs5uh1r9KXjhmCkfqPELOua1d6c9ebOuo1JWoy4upOHGjhmCQhaCWsO5bdN6rHCG1IgIAHTA7X3jw7m6Rn8AjfxQvCGAzrmbIEFuRKyTcD8VAVOwAS2Vj1dlHhMqH65v1MFhBrAH8b00oC94IKKJUqprGAvvlP4c3KD1(c4AnijuONihneAt2vRQAjQwwetGO35x8z26OPpButkwqEIKc0h1(c4Af2bdNJgcMCWW5OIi7FO(GKyTetCTSiMarVZLKjoQnJEm5jskqFu7lGRvyhmCoAiyYbdNJkIS)H6dsI1smX1suTNmr)453rD00MrpMC0f6jcuRQAzrmbIENNFh1rtBg9yYtKuG(O2xaxRWoy4C0qWKdgohvez)d1hKeRLWAjSwv1s)BnE(DuhnTz0Jjhi69Avvl9V14sYeh1MrpMCGO3RvvTai9V14x8z26OPpButkwqoq071QQ2xvRzIg0wmaUs8l(mBD00NnQjfli1rPE1rPaQh0f6jcqPCQhwcpmHc1t(DSfPfYhqt7W1Jlsso6c9ebQvvTVQwwyaDXpUb0p7UzTQQLfXei6DUKmXrTz0Jjprsb6JAFbCTc7GHZrdbtoy4CurK9puFqsK6ryhmCQh0qWKdgo1rP(oGsbupOl0teGs5upSeEycfQN87ylslKpGM2HRhxKKC0f6jcuRQAzHb0f)4gq)S7M1QQwwetGO35KWmJCOJM(IKe9JNiPa9rTVaUwHDWW5OHGjhmCoQiY(hQpijwRQAzrmbIENFXNzRJM(SrnPyb5jskqFu7lGRLOAnijuONiNmoTzImeb0xCKA6U1cYAf2bdNJgcMCWW5OIi7FO(GKyTGS2oOwcRvvTSiMarVZLKjoQnJEm5jskqFu7lGRLOAnijuONiNmoTzImeb0xCKA6U1cYAf2bdNJgcMCWW5OIi7FO(GKyTGS2oOwcPEe2bdN6bnem5GHtDuQhesPaQh0f6jcqPCQhHDWWPEKKjoQPLmflK6bahSeAEWWPEuUKPyH1cB1cV3JApijw7f1(hyTxCK1koqT9yT2IbS2lIAjfVBTmBjTWb1dlHhMqH6HfXei6D(fFMToA6Zg1KIfKNOa0Twv1suT0)wJljtCuZSL0c5JtyGwRrQ1GKqHEI8losnPOOMzlPfoQvvTSiMarVZLKjoQnJEm5jskqFu7lGRfvez)d1hKeRvvTKIlCt2vRrQ1GKqHEICXutcDi5NutkUOnzxTQQL(3A887OoAAZOhtoq071si1rPEcGsbupOl0teGs5upSeEycfQhwetGO35x8z26OPpButkwqEIcq3Avvlr1s)BnUKmXrnZwslKpoHbATgPwdscf6jYV4i1KIIAMTKw4Owv1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprsb6JAFbCTOIi7FO(GKyTQQ1GKqHEI8dsI6VFWPwmR1i1AqsOqpr(fhPMuuudGtPRUfPwmRLqQhHDWWPEKKjoQPLmflK6OuVcJsbupOl0teGs5upSeEycfQhwetGO35x8z26OPpButkwqEIcq3Avvlr1s)BnUKmXrnZwslKpoHbATgPwdscf6jYV4i1KIIAMTKw4Owv1suTVQ2tMOF887OoAAZOhto6c9ebQLyIRLfXei6DE(DuhnTz0Jjprsb6JAnsTgKek0tKFXrQjff1a4u6QBrQZWSwcRvvTgKek0tKFqsu)9do1IzTgPwdscf6jYV4i1KIIAaCkD1Ti1IzTes9iSdgo1JKmXrnTKPyHuhL6FDukG6bDHEIaukN6HLWdtOq9aG0)wJNcau8tpmLeuTH)0XuOHt41LpoHbATGRfaP)TgpfaO4NEykjOAd)PJPqdNWRlNuuupoHbATQQLOAP)TgxsM4O2m6XKde9ETetCT0)wJljtCuBg9yYtKuG(O2xaxRfdOwcRvvTevl9V1453rD00MrpMCGO3RLyIRL(3A887OoAAZOhtEIKc0h1(c4ATya1si1JWoy4upsYeh10sMIfsDuQVdrPaQh0f6jcqPCQhwcpmHc1JbjHc9e5D4)XP)deqpmLe0AjM4AjQwaK(3A8uaGIF6HPKGQn8NoMcnCcVU8VzTQQfaP)TgpfaO4NEykjOAd)PJPqdNWRlFCcd0AFPwaK(3A8uaGIF6HPKGQn8NoMcnCcVUCsrr94egO1si1JWoy4upsYeh10tzCuhL67iukG6bDHEIaukN6HLWdtOq9q)BnUzId0zOoAAsOdW)M1QQwaK(3A8l(mBD00NnQjfli)BwRQAbq6FRXV4ZS1rtF2OMuSG8ejfOpQ9fW1kSdgoxsM4OMEkJJJkIS)H6dsIupc7GHt9ijtCutpLXrDuQxjJsPaQh0f6jcqPCQhMTaDQhLOEqjND1mBb6AyJ6H(3AC2eLKjJd6wAMT4oo5arVRIi6FRXLKjoQnJEm5FtIjMOxDYe9JhgW0m6Xebure9V1453rD00MrpM8VjXeZIyce9ohnem5GHZtua6siHes9Ws4HjuOEaq6FRXV4ZS1rtF2OMuSG8VzTQQ9Kj6hxsM4Ogz2bhDHEIa1QQwIQL(3ACauoB6iDKde9ETetCTc7Ggqn6ijeh1cUwLQLWAvvlr1cG0)wJFXNzRJM(SrnPyb5jskqFuRrQvyhmCUKmXrnjCmGtCWrfr2)q9bjXAjM4AzrmbIENBM4aDgQJMMe6a8ejfOpQLyIRLfgqx8JdA3ekETes9iSdgo1JKmXrnjCmGtCqDuQxjLOua1d6c9ebOuo1JWoy4upsYeh1KWXaoXb1daoyj08GHt905WhFsS2ZgRfv0uCaeOwZ4q)GYSw6FRvRmeZAVOwpUANXaR1mo0pOmR1md2G6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvT0)wJJkAkoacOnJd9dkt(3K6OuVsQJsbupOl0teGs5upc7GHt9ijtCutchd4ehupmBb6upkr9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQwIQL(3ACjzIJAZOht(3SwIjUw6FRXZVJ6OPnJEm5FZAjM4Abq6FRXV4ZS1rtF2OMuSG8ejfOpQ1i1kSdgoxsM4OMeogWjo4OIi7FO(GKyTesDuQxPoGsbupOl0teGs5upc7GHt9ijtCutchd4ehupmBb6upkr9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQw6FRXztusMmoOBXhNWaTwW1s)BnoBIsYKXbDloPOOECcduQJs9kbcPua1d6c9ebOuo1daoyj08GHt90XZEP7O2l7w7f1sloO125oxBlYAzrmbIEV2EOde9JAP)xTaFsZApBKSwyR2Zg7(oXAf64F1ErTOIMWePEyj8Wekup0)wJZMOKmzCq3INOWUAvvl9V14Sjkjtgh0T4jskqFu7lGRLOAjQw6FRXztusMmoOBXhNWaTwqGAf2bdNljtCutchd4ehCurK9puFqsSwcRfK1AXa4KII1si1dZwGo1Jsupc7GHt9ijtCutchd4ehuhL6vIaOua1d6c9ebOuo1dlHhMqH6HOAtSL4WwONyTetCTVQ2dYaf6w1syTQQL(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0Avvl9V14sYeh1MrpMCGO3RvvTai9V14x8z26OPpButkwqoq07upc7GHt944zJP(qstCCuhL6vsHrPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1mBjTq(4egO1(c4AnijuONi)IJutkkQz2sAHdQhHDWWPEKKjoQJKM6OuVsVokfq9GUqprakLt9Ws4HjuOEmijuONip(3acG6OPzrmbIEFuRQAjfx4MSR2xaxBhHaOEe2bdN6z8nX0ddc1rPEL6qukG6bDHEIaukN6HLWdtOq9q)BnE(NOoA6ZorCW)M1QQw6FRXLKjoQz2sAH8XjmqR1i12bupc7GHt9ijtCutpLXrDuQxPocLcOEqxONiaLYPEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6rH7pPzTmBjTWrTWwT9yTnzoRLgNrFTNnwll8bMgWAjfxQ9StCyhtGAfhOw0qWKdgETWrTJdoN1gETSiMarVt9Ws4HjuOEEvT53XwKwiFanTdxpUij5Ol0teOwv1AqsOqprE8Vbea1rtZIyce9(Owv1s)BnUKmXrnZwslKpoHbATGRL(3ACjzIJAMTKwiNuuupoHbATQQ9Kj6hxsM4OosAo6c9ebQvvTSiMarVZLKjoQJKMNiPa9rTVaUwlgqTQQLuCHBYUAFbCTDeJwRQAzrmbIENJgcMCWW5jskqFqDuQxDgLsbupOl0teGs5upSeEycfQN87ylslKpGM2HRhxKKC0f6jcuRQAnijuONip(3acG6OPzrmbIEFuRQAP)TgxsM4OMzlPfYhNWaTwW1s)BnUKmXrnZwslKtkkQhNWaTwv1EYe9JljtCuhjnhDHEIa1QQwwetGO35sYeh1rsZtKuG(O2xaxRfdOwv1skUWnzxTVaU2oIrRvvTSiMarVZrdbtoy48ejfOpQ9LA7aJs9iSdgo1JKmXrnTKPyHuhL6vNsukG6bDHEIaukN6ryhmCQhjzIJAAjtXcPEaWblHMhmCQhfU)KM1YSL0ch1cB1gjDTWrTjkaDPEyj8WekupgKek0tKh)BabqD00SiMarVpQvvT0)wJljtCuZSL0c5JtyGwl4AP)TgxsM4OMzlPfYjff1JtyGwRQApzI(XLKjoQJKMJUqprGAvvllIjq07CjzIJ6iP5jskqFu7lGR1IbuRQAjfx4MSR2xaxBhXO1QQwwetGO35OHGjhmCEIKc0h1QQwIQ9v1MFhBrAH8b00oC94IKKJUqprGAjM4AP)TgFanTdxpUij5jskqFu7lGRvPouTesDuQxDQJsbupOl0teGs5upc7GHt9ijtCutlzkwi1daoyj08GHt90XjtCSwLlzkwyTd74pbQ1cDmL5SBT0yTNnw7ugxTmzC1gTApBS2o(1QTh6arp1dlHhMqH6H(3ACjzIJAZOht(3Swv1s)BnUKmXrTz0Jjprsb6JAFbCTwmGAvvl9V14sYeh1mBjTq(4egO1cUw6FRXLKjoQz2sAHCsrr94egO1QQwIQLfXei6DoAiyYbdNNiPa9rTetCT53XwKwixsM4O2wsYW7YrxONiqTesDuQxDDaLcOEqxONiaLYPEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6PJtM4yTkxYuSWAh2XFcuRf6ykZz3APXApBS2PmUAzY4QnA1E2yTkuXRvBp0bIEQhwcpmHc1d9V1453rD00MrpM8VzTQQL(3ACjzIJAZOhtoq071QQw6FRXZVJ6OPnJEm5jskqFu7lGR1IbuRQAP)TgxsM4OMzlPfYhNWaTwW1s)BnUKmXrnZwslKtkkQhNWaTwv1suTSiMarVZrdbtoy48ejfOpQLyIRn)o2I0c5sYeh12ssgExo6c9ebQLqQJs9QdesPaQh0f6jcqPCQhHDWWPEKKjoQPLmflK6bahSeAEWWPE64KjowRYLmflS2HD8Na1sJ1E2yTtzC1YKXvB0Q9SXAvqCD0A7Hoq0xlSvl8QfoQ1JR2)abQThE21QqfVwTrwBh)AupSeEycfQh6FRXLKjoQnJEm5arVxRQAP)Tgp)oQJM2m6XKde9ETQQfaP)Tg)IpZwhn9zJAsXcY)M1QQwaK(3A8l(mBD00NnQjfliprsb6JAFbCTwmGAvvl9V14sYeh1mBjTq(4egO1cUw6FRXLKjoQz2sAHCsrr94egOuhL6vhbqPaQh0f6jcqPCQhHDWWPEKKjoQPLmflK6bahSeAEWWPEu4TrV2ZgR9K0cVAHJAHETOIi7FyTP4wyTIdu7zJjwlCulzKyTNT41gowl6izxJR9pWAPLmflSwzu7icVwzuB34xRTyaRf94BzxlZwslCu7f1AdVAL5Sw0rsioQf2Q9SXA74KjowRYdsAjbir)QDIwOdiz3AHJAXx)hAAIaupSeEycfQhdscf6jYrsZOhteqtlzkwyTQQL(3ACjzIJAMTKwiFCcd0Anc4AjQwHDqdOgDKeIJA7WQvPAjSwv1kSdAa1OJKqCuRrQvPAvvl9V14aOC20r6ihi6DQJs9QtHrPaQh0f6jcqPCQhwcpmHc1JbjHc9e5iPz0JjcOPLmflSwv1s)BnUKmXrnZwslKpoHbATVul9V14sYeh1mBjTqoPOOECcd0AvvRWoObuJoscXrTgPwLQvvT0)wJdGYzthPJCGO3PEe2bdN6rsM4Ogv0Cgdy4uhL6v3RJsbupc7GHt9ijtCutpLXr9GUqprakLtDuQxDDikfq9GUqprakLt9Ws4HjuOEmijuONip(3acG6OPzrmbIEFq9iSdgo1dAiyYbdN6OuV66iukG6ryhmCQhjzIJAAjtXcPEqxONiaLYPoQJ6baBYFEukGs9krPaQhHDWWPEyX3pmhM4Cs9GUqprakLtDuQxDukG6bDHEIaukN6HLWdtOq9quTNmr)4OpHw2h6iahDHEIa1QQwsXfUj7Q9fW12HmATQQLuCHBYUAnc4AvyeqTewlXexlr1(QApzI(XrFcTSp0rao6c9ebQvvTKIlCt2v7lGRTdra1si1JWoy4upKIlAlKK6OuFhqPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1MrpM8Vj1JWoy4upMXbdN6OupiKsbupOl0teGs5upSeEycfQN87ylslKFiPzKYu3lPjhDHEIa1QQw6FRXrfTL)4GHZ)M1QQwIQLfXei6DUKmXrTz0JjprbOBTetCT0XyuRQABql7tNiPa9rTVaUwqOrRLqQhHDWWPEoijQ7L0K6OupbqPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1MrpMCGO3RvvT0)wJNFh1rtBg9yYbIEVwv1cG0)wJFXNzRJM(SrnPyb5arVt9iSdgo1ZeAzFdDh(hWIe9J6OuVcJsbupOl0teGs5upSeEycfQh6FRXLKjoQnJEm5arVxRQAP)Tgp)oQJM2m6XKde9ETQQfaP)Tg)IpZwhn9zJAsXcYbIEN6ryhmCQhAXshn9LqgOdQJs9Vokfq9GUqprakLt9Ws4HjuOEO)TgxsM4O2m6XK)nPEe2bdN6HgZbMGcDlQJs9Dikfq9GUqprakLt9Ws4HjuOEO)TgxsM4O2m6XK)nPEe2bdN6HEgbGU9ZUuhL67iukG6bDHEIaukN6HLWdtOq9q)BnUKmXrTz0Jj)Bs9iSdgo1tdMi9mcaQJs9kzukfq9GUqprakLt9Ws4HjuOEO)TgxsM4O2m6XK)nPEe2bdN6rCgoUuMAMmNuhL6vsjkfq9GUqprakLt9Ws4HjuOEO)TgxsM4O2m6XK)nPEe2bdN65pqn8qYb1rPELuhLcOEqxONiaLYPEe2bdN6XAkaq5ICOPfalK6HLWdtOq9q)BnUKmXrTz0Jj)BwlXexllIjq07CjzIJAZOhtEIKc0h1AeW1saeqTQQfaP)Tg)IpZwhn9zJAsXcY)MupyRHSt7cjs9ynfaOCro00cGfsDuQxPoGsbupOl0teGs5upc7GHt9qgHpHN2mHdsQhwcpmHc1dlmGU4hh0Uju8AvvllIjq07CjzIJAZOhtEIKc0h1(c4AvYO1QQwwetGO35x8z26OPpButkwqEIKc0h1(c4AvYOupUqIupKr4t4Pnt4GK6OuVsGqkfq9GUqprakLt9iSdgo1dze(eEAZeoiPEyj8WekupVQwwyaDXpoODtO41QQwwetGO35sYeh1MrpM8ejfOpQ9fW1QWQvvTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ9fW1QWOECHePEiJWNWtBMWbj1rPELiakfq9GUqprakLt9iSdgo1dsA2nrzQJeWfNHupSeEycfQhwetGO35sYeh1MrpM8ejfOpQ9fW1QebuRQAzrmbIENFXNzRJM(SrnPyb5jskqFu7lGRvjcG6XfsK6bjn7MOm1rc4IZqQJs9kPWOua1d6c9ebOuo1JWoy4upajkanyIAd4yGtQhwcpmHc1dlIjq07CjzIJAZOhtEIKc0h1AeW1QoJwlXex7RQ1GKqHEICXuhU(pWAbxRs1smX1suThKeRfCTgTwv1AqsOqprEdoSHULomrhZAbxRs1QQ287ylslKpGM2HRhxKKC0f6jculHupUqIupajkanyIAd4yGtQJs9k96Oua1d6c9ebOuo1JWoy4upJ4p1qlhEys9Ws4HjuOEyrmbIENljtCuBg9yYtKuG(OwJaU2oWO1smX1(QAnijuONixm1HR)dSwW1Qe1JlKi1Zi(tn0YHhMuhL6vQdrPaQh0f6jcqPCQhHDWWPESMDnT1rtlJbKeoLdgo1dlHhMqH6HfXei6DUKmXrTz0Jjprsb6JAnc4AvNrRLyIR9v1AqsOqprUyQdx)hyTGRvPAjM4AjQ2dsI1cUwJwRQAnijuONiVbh2q3shMOJzTGRvPAvvB(DSfPfYhqt7W1Jlsso6c9ebQLqQhxirQhRzxtBD00YyajHt5GHtDuQxPocLcOEqxONiaLYPEe2bdN6HuycDI6HnINM8pGmQhwcpmHc1dlIjq07CjzIJAZOhtEIKc0h1(c4AjGAvvlr1(QAnijuONiVbh2q3shMOJzTGRvPAjM4ApijwRrQTdmATes94cjs9qkmHor9WgXtt(hqg1rPE1zukfq9GUqprakLt9iSdgo1dPWe6e1dBepn5FazupSeEycfQhwetGO35sYeh1MrpM8ejfOpQ9fW1sa1QQwdscf6jYBWHn0T0Hj6ywl4AvQwv1s)BnE(DuhnTz0Jj)BwRQAP)Tgp)oQJM2m6XKNiPa9rTVaUwIQvjJwBhwTeqTGa1MFhBrAH8b00oC94IKKJUqprGAjSwv1EqsS2xQTdmk1JlKi1dPWe6e1dBepn5FazuhL6vNsukG6bDHEIaukN6ryhmCQNHTae9iGosAD00xKKOFupSeEycfQNdsI1cUwJwlXexlr1AqsOqprE8Vbea1rtZIyce9(Owv1suTevllmGU4hh0Uju8AvvllIjq078uaGIF6HPKGYtKuG(O2xaxR6QvvTSiMarVZLKjoQnJEm5jskqFu7lGRLaQvvTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ9fW1sa1syTetCTSiMarVZLKjoQnJEm5jskqFu7lGRvD1smX12Gw2Norsb6JAFPwwetGO35sYeh1MrpM8ejfOpQLWAjK6XfsK6zylarpcOJKwhn9fjj6h1rPE1Pokfq9GUqprakLt9aGdwcnpy4upeaxHvlCu7zJ1omreO2Ov7zJ1(e)5eVd6w1Qq9P7wRzgD4i7GtK6XfsK6ze)5eVd6w68t3L6HLWdtOq9quTgKek0tKFqsu)9do1IzTGSwIQvyhmCEkaqXp9Wusq5OIi7FO(GKyTGa1YcdOl(XbTBcfVwcRfK1suTc7GHZbq5SPJ0roQiY(hQpijwliqTSWa6IFChzzmJeOwcRfK1kSdgo)IpZwhn9zJAsXcYrfr2)q9bjXAFP2tsl84aWXjodRLG1saCfwTewRQAjQwdscf6jYTfdOomrhbQLyIRLOAzHb0f)4G2nHIxRQAZVJTiTqUKmXrn0BqhED5Ol0teOwcRLWAvv7jPfECa44eNH1AKAvhbq9iSdgo1Zi(ZjEh0T05NUl1rPE11bukG6bDHEIaukN6HLWdtOq9iSdAa1OJKqCuRraxRbjHc9e5sG6tsl80S47h1Z4si7OuVsupc7GHt9WK5ulSdgUEchh1ZeooTlKi1Jei1rPE1bcPua1d6c9ebOuo1dlHhMqH6Hfgqx8JdA3ekETQQn)o2I0c5sYeh12ssgExo6c9ebOEgxczhL6vI6ryhmCQhMmNAHDWW1t44OEMWXPDHePESLKm8UuhL6vhbqPaQh0f6jcqPCQhwcpmHc1JbjHc9e52IbuhMOJa1cUwJwRQAnijuONiVbh2q3shMOJzTQQ9v1suTSWa6IFCq7MqXRvvT53XwKwixsM4O2wsYW7YrxONiqTes9mUeYok1Re1JWoy4upmzo1c7GHRNWXr9mHJt7cjs90GdBOBPdt0XK6OuV6uyukG6bDHEIaukN6HLWdtOq9yqsOqprUTya1Hj6iqTGR1O1QQ2xvlr1YcdOl(XbTBcfVwv1MFhBrAHCjzIJABjjdVlhDHEIa1si1Z4si7OuVsupc7GHt9WK5ulSdgUEchh1ZeooTlKi1tyIoMuhL6v3RJsbupOl0teGs5upSeEycfQNxvlr1YcdOl(XbTBcfVwv1MFhBrAHCjzIJABjjdVlhDHEIa1si1Z4si7OuVsupc7GHt9WK5ulSdgUEchh1ZeooTlKi1dlIjq07dQJs9QRdrPaQh0f6jcqPCQhwcpmHc1JbjHc9e5nOltn9p9AbxRrRvvTVQwIQLfgqx8JdA3ekETQQn)o2I0c5sYeh12ssgExo6c9ebQLqQNXLq2rPELOEe2bdN6HjZPwyhmC9eooQNjCCAxirQNmo5GHtDuQxDDekfq9GUqprakLt9Ws4HjuOEmijuONiVbDzQP)Pxl4AvQwv1(QAjQwwyaDXpoODtO41QQ287ylslKljtCuBljz4D5Ol0teOwcPEgxczhL6vI6ryhmCQhMmNAHDWW1t44OEMWXPDHePEAqxMA6F6uh1r9yMiliPLJsbuQxjkfq9iSdgo1JKmXrn0pCor2r9GUqprakLtDuQxDukG6ryhmCQNXNKmCTKmXrDtiHtOKupOl0teGs5uhL67akfq9iSdgo1dl8o8FIAsXfTfss9GUqprakLtDuQhesPaQhHDWWPEiHzgPgskwi1d6c9ebOuo1rPEcGsbupOl0teGs5upSeEycfQNr8N0qhGBiMYbNOEetdOFC0f6jculXex7i(tAOdWn)J7prnMFZdgohDHEIaupc7GHt90M4WMLs7Ook1RWOua1d6c9ebOuo1dlHhMqH6Hfgqx8JdA3ekETQQn)o2I0c5sYeh12ssgExo6c9ebQvvTSWb(WJljtCuBMba0QlhDHEIa1QQwdscf6jYLzV0DOhDDMMfXei69rTQQvyh0aQrhjH4O2xQ1GKqHEICjq9jPfEAw89J6ryhmCQN87OoAAZOhtQJs9Vokfq9GUqprakLt9Ws4HjuOEEvTgKek0tKBMO5Fo1OHOwW1QuTQQn)o2I0c5aWbdAoHUKD1SGKuCao6c9ebOEe2bdN6PLX4OJ5rDuQVdrPaQh0f6jcqPCQhwcpmHc1ZRQ1GKqHEICZen)ZPgne1cUwLQvvTVQ287ylslKdahmO5e6s2vZcssXb4Ol0teOwv1suTVQwwyaDXpUb0p7UzTetCTgKek0tK3GdBOBPdt0XSwcPEe2bdN6rsM4OMEkJJ6OuFhHsbupOl0teGs5upSeEycfQNxvRbjHc9e5MjA(NtnAiQfCTkvRQAFvT53XwKwihaoyqZj0LSRMfKKIdWrxONiqTQQLfgqx8JBa9ZUBwRQAFvTgKek0tK3GdBOBPdt0XK6ryhmCQhsyMro0rtFrsI(rDuQxjJsPaQh0f6jcqPCQhwcpmHc1JbjHc9e5MjA(NtnAiQfCTkr9iSdgo1dAiyYbdN6OoQhjqkfqPELOua1d6c9ebOuo1dlHhMqH6j)o2I0c5aWbdAoHUKD1SGKuCao6c9ebQvvTSiMarVZP)TMgaoyqZj0LSRMfKKIdWtua6wRQAP)TghaoyqZj0LSRMfKKIdOBzmooq071QQwIQL(3ACjzIJAZOhtoq071QQw6FRXZVJ6OPnJEm5arVxRQAbq6FRXV4ZS1rtF2OMuSGCGO3RLWAvvllIjq078l(mBD00NnQjfliprsb6JAbxRrRvvTevl9V14sYeh1mBjTq(4egO1(c4AnijuONixcuFXrQjff1mBjTWrTQQLOAjQ2tMOF887OoAAZOhto6c9ebQvvTSiMarVZZVJ6OPnJEm5jskqFu7lGR1IbuRQAzrmbIENljtCuBg9yYtKuG(OwJuRbjHc9e5xCKAsrrnaoLU6wKAXSwcRLyIRLOAFvTNmr)453rD00MrpMC0f6jcuRQAzrmbIENljtCuBg9yYtKuG(OwJuRbjHc9e5xCKAsrrnaoLU6wKAXSwcRLyIRLfXei6DUKmXrTz0Jjprsb6JAFbCTwmGAjSwcPEe2bdN6PLX4OJ5rDuQxDukG6bDHEIaukN6HLWdtOq9quT53XwKwihaoyqZj0LSRMfKKIdWrxONiqTQQLfXei6Do9V10aWbdAoHUKD1SGKuCaEIcq3Avvl9V14aWbdAoHUKD1SGKuCaDdMihi69AvvRzIg0wmaUs8wgJJoMxTewlXexlr1MFhBrAHCa4GbnNqxYUAwqskoahDHEIa1QQ2dsI1cUwJwlHupc7GHt90GjQPNY4Ook13bukG6bDHEIaukN6HLWdtOq9KFhBrAHCReoMD1qgKnro6c9ebQvvTSiMarVZLKjoQnJEm5jskqFuRrQTdmATQQLfXei6D(fFMToA6Zg1KIfKNiPa9rTGR1O1QQwIQL(3ACjzIJAMTKwiFCcd0AFbCTgKek0tKlbQV4i1KIIAMTKw4Owv1suTev7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejfOpQ9fW1AXaQvvTSiMarVZLKjoQnJEm5jskqFuRrQ1GKqHEI8losnPOOgaNsxDlsTywlH1smX1suTVQ2tMOF887OoAAZOhto6c9ebQvvTSiMarVZLKjoQnJEm5jskqFuRrQ1GKqHEI8losnPOOgaNsxDlsTywlH1smX1YIyce9oxsM4O2m6XKNiPa9rTVaUwlgqTewlHupc7GHt90YyCApmiuhL6bHukG6bDHEIaukN6HLWdtOq9KFhBrAHCReoMD1qgKnro6c9ebQvvTSiMarVZLKjoQnJEm5jskqFul4AnATQQLOAjQwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTgPwdscf6jYftnPOOgaNsxDls9fhzTQQL(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0AjSwIjUwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTGR1O1QQw6FRXLKjoQz2sAH8XjmqR9fW1AqsOqprUeO(IJutkkQz2sAHJAjSwcRvvT0)wJNFh1rtBg9yYbIEVwcPEe2bdN6PLX40EyqOok1taukG6bDHEIaukN6ryhmCQhjzIJAs4yaN4G6HzlqN6rjQhwcpmHc1dlmGU4hh0Uju8AvvB(DSfPfYLKjoQTLKm8UC0f6jcuRQAP)TgxsM4O2wsYW7YhNWaT2xQvjcOwv1YIyce9opfaO4NEykjO8ejfOpQ9fW1AqsOqprUTKKH3vpoHbQ(GKyTGSwurK9puFqsSwv1YIyce9o)IpZwhn9zJAsXcYtKuG(O2xaxRbjHc9e52ssgEx94egO6dsI1cYArfr2)q9bjXAbzTc7GHZtbak(PhMsckhvez)d1hKeRvvTSiMarVZLKjoQnJEm5jskqFu7lGR1GKqHEICBjjdVRECcdu9bjXAbzTOIi7FO(GKyTGSwHDWW5Paaf)0dtjbLJkIS)H6dsI1cYAf2bdNFXNzRJM(SrnPyb5OIi7FO(GKi1rPEfgLcOEqxONiaLYPEe2bdN6rsM4OMeogWjoOEy2c0PEuI6HLWdtOq9WcdOl(XnG(z3nRvvT53XwKwixsM4Og6nOdVUC0f6jcuRQAP)TgxsM4O2wsYW7YhNWaT2xQvjcOwv1YIyce9o)IpZwhn9zJAsXcYtKuG(O2xaxRbjHc9e52ssgEx94egO6dsI1cYArfr2)q9bjXAvvllIjq07CjzIJAZOhtEIKc0h1(c4AnijuONi3wsYW7QhNWavFqsSwqwlQiY(hQpijwliRvyhmC(fFMToA6Zg1KIfKJkIS)H6dsIuhL6FDukG6bDHEIaukN6HLWdtOq9WcdOl(XnG(z3nRvvTNmr)4sYeh1iZo4Ol0teOwv1EqsS2xQvjJwRQAzrmbIENtcZmYHoA6lss0pEIKc0h1QQw6FRXztusMmoOBXhNWaT2xQTdOEe2bdN6rsM4OMEkJJ6OuFhIsbupOl0teGs5upc7GHt9mI)CI3bDlD(P7s9Ws4HjuOEYVJTiTq(aAAhUECrsYrxONiqTQQ1mrdAlgaxjoAiyYbdN6XfsK6ze)5eVd6w68t3L6OuFhHsbupOl0teGs5upSeEycfQN87ylslKpGM2HRhxKKC0f6jcuRQAnt0G2IbWvIJgcMCWWPEe2bdN65IpZwhn9zJAsXcsDuQxjJsPaQh0f6jcqPCQhwcpmHc1t(DSfPfYhqt7W1Jlsso6c9ebQvvTevRzIg0wmaUsC0qWKdgETetCTMjAqBXa4kXV4ZS1rtF2OMuSG1si1JWoy4upsYeh1MrpMuhL6vsjkfq9GUqprakLt9Ws4HjuOEYVJTiTqUKmXrn0BqhED5Ol0teOwv1YIyce9o)IpZwhn9zJAsXcYtKuG(O2xaxRsgTwv1YIyce9oxsM4O2m6XKNiPa9rTVaUwLiaQhHDWWPEiHzg5qhn9fjj6h1rPELuhLcOEqxONiaLYPEyj8WekupSiMarVZLKjoQnJEm5jskqFu7lGRTdvRQAzrmbIENFXNzRJM(SrnPyb5jskqFu7lGRTdvRQAjQw6FRXLKjoQz2sAH8XjmqR9fW1AqsOqprUeO(IJutkkQz2sAHJAvvlr1suTNmr)453rD00MrpMC0f6jcuRQAzrmbIENNFh1rtBg9yYtKuG(O2xaxRfdOwv1YIyce9oxsM4O2m6XKNiPa9rTgPwcOwcRLyIRLOAFvTNmr)453rD00MrpMC0f6jcuRQAzrmbIENljtCuBg9yYtKuG(OwJulbulH1smX1YIyce9oxsM4O2m6XKNiPa9rTVaUwlgqTewlHupc7GHt9qcZmYHoA6lss0pQJs9k1bukG6bDHEIaukN6HLWdtOq9CqsSwJuBhy0AvvB(DSfPfYhqt7W1Jlsso6c9ebQvvTSWa6IFCdOF2DZAvvRzIg0wmaUsCsyMro0rtFrsI(r9iSdgo1dAiyYbdN6OuVsGqkfq9GUqprakLt9Ws4HjuOEoijwRrQTdmATQQn)o2I0c5dOPD46XfjjhDHEIa1QQw6FRXLKjoQz2sAH8XjmqR9fW1AqsOqprUeO(IJutkkQz2sAHJAvvllIjq078l(mBD00NnQjfliprsb6JAbxRrRvvTSiMarVZLKjoQnJEm5jskqFu7lGR1Ibq9iSdgo1dAiyYbdN6OuVseaLcOEqxONiaLYPEe2bdN6bnem5GHt9a9dZ8BEAyJ6H(3A8b00oC94IKKpoHbky6FRXhqt7W1JlssoPOOECcduQhOFyMFZtdjjraOCi1JsupSeEycfQNdsI1AKA7aJwRQAZVJTiTq(aAAhUECrsYrxONiqTQQLfXei6DUKmXrTz0Jjprsb6JAbxRrRvvTevlr1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ1i1AqsOqprUyQjff1a4u6QBrQV4iRvvT0)wJljtCuZSL0c5JtyGwl4AP)TgxsM4OMzlPfYjff1JtyGwlH1smX1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQfCTgTwv1s)BnUKmXrnZwslKpoHbATVaUwdscf6jYLa1xCKAsrrnZwslCulH1syTQQL(3A887OoAAZOhtoq071si1rPELuyukG6bDHEIaukN6ryhmCQNr8Nt8oOBPZpDxQhwcpmHc1dlIjq078uaGIF6HPKGYtua6wRQAzrmbIENFXNzRJM(SrnPyb5jskqFu7lGR1IbWjffRvvTSiMarVZLKjoQnJEm5jskqFu7lGR1IbWjffPECHePEgXFoX7GULo)0DPok1R0RJsbupOl0teGs5upSeEycfQhwetGO35x8z26OPpButkwqEIKc0h1(sTOIi7FO(GKyTQQLOAjQ2tMOF887OoAAZOhto6c9ebQvvTSiMarVZZVJ6OPnJEm5jskqFu7lGR1IbuRQAzrmbIENljtCuBg9yYtKuG(OwJuRbjHc9e5xCKAsrrnaoLU6wKAXSwcRLyIRLOAFvTNmr)453rD00MrpMC0f6jcuRQAzrmbIENljtCuBg9yYtKuG(OwJuRbjHc9e5xCKAsrrnaoLU6wKAXSwcRLyIRLfXei6DUKmXrTz0Jjprsb6JAFbCTwmGAjK6ryhmCQNuaGIF6HPKGsDuQxPoeLcOEqxONiaLYPEyj8WekupSiMarVZLKjoQnJEm5jskqFu7l1IkIS)H6dsI1QQwIQLOAjQwwetGO35x8z26OPpButkwqEIKc0h1AKAnijuONixm1KIIAaCkD1Ti1xCK1QQw6FRXLKjoQz2sAH8XjmqRfCT0)wJljtCuZSL0c5KII6XjmqRLWAjM4AjQwwetGO35x8z26OPpButkwqEIKc0h1cUwJwRQAP)TgxsM4OMzlPfYhNWaT2xaxRbjHc9e5sG6losnPOOMzlPfoQLWAjSwv1s)BnE(DuhnTz0Jjhi69AjK6ryhmCQNuaGIF6HPKGsDuQxPocLcOEqxONiaLYPEyj8WekupSiMarVZLKjoQnJEm5jskqFul4AnATQQLOAjQwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTgPwdscf6jYftnPOOgaNsxDls9fhzTQQL(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0AjSwIjUwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTGR1O1QQw6FRXLKjoQz2sAH8XjmqR9fW1AqsOqprUeO(IJutkkQz2sAHJAjSwcRvvT0)wJNFh1rtBg9yYbIEVwcPEe2bdN6baLZMoshPok1RoJsPaQh0f6jcqPCQhHDWWPEgXFoX7GULo)0DPEyj8Wekupevl9V14sYeh1mBjTq(4egO1(c4AnijuONixcuFXrQjff1mBjTWrTetCTMjAqBXa4kXtbak(PhMscATewRQAjQwIQ9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIKc0h1(c4ATya1QQwwetGO35sYeh1MrpM8ejfOpQ1i1AqsOqpr(fhPMuuudGtPRUfPwmRLWAjM4AjQ2xv7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO35sYeh1MrpM8ejfOpQ1i1AqsOqpr(fhPMuuudGtPRUfPwmRLWAjM4AzrmbIENljtCuBg9yYtKuG(O2xaxRfdOwcRvvTVQwIQDe)jn0b4yR9hqdOwCiPOfgdNykxKC0f6jcuRQAZVJTiTqUTKKHdzAKzhC0f6jculHupUqIupJ4pN4Dq3sNF6UuhL6vNsukG6bDHEIaukN6HLWdtOq9WcdOl(XnG(z3nRvvT53XwKwixsM4Og6nOdVUC0f6jcuRQAzrmbIENtcZmYHoA6lss0pEIKc0h1(c4AjaJs9iSdgo1ZfFMToA6Zg1KIfK6OuV6uhLcOEqxONiaLYPEyj8WekupSWa6IFCdOF2DZAvvB(DSfPfYLKjoQHEd6WRlhDHEIa1QQw6FRXjHzg5qhn9fjj6hprsb6JAFbCTQZO1QQwwetGO35sYeh1MrpM8ejfOpQ9fW1AXaOEe2bdN65IpZwhn9zJAsXcsDuQxDDaLcOEqxONiaLYPEyj8Wekupevl9V14sYeh1mBjTq(4egO1(c4AnijuONixcuFXrQjff1mBjTWrTetCTMjAqBXa4kXtbak(PhMscATewRQAjQwIQ9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIKc0h1(c4ATya1QQwwetGO35sYeh1MrpM8ejfOpQ1i1AqsOqpr(fhPMuuudGtPRUfPwmRLWAjM4AjQ2xv7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO35sYeh1MrpM8ejfOpQ1i1AqsOqpr(fhPMuuudGtPRUfPwmRLWAjM4AzrmbIENljtCuBg9yYtKuG(O2xaxRfdOwcRvvTVQwIQDe)jn0b4yR9hqdOwCiPOfgdNykxKC0f6jcuRQAZVJTiTqUTKKHdzAKzhC0f6jculHupc7GHt9CXNzRJM(SrnPybPok1RoqiLcOEqxONiaLYPEyj8Wekupevlr1YIyce9o)IpZwhn9zJAsXcYtKuG(OwJuRbjHc9e5IPMuuudGtPRUfP(IJSwv1s)BnUKmXrnZwslKpoHbATGRL(3ACjzIJAMTKwiNuuupoHbATewlXexlr1YIyce9o)IpZwhn9zJAsXcYtKuG(OwW1A0Avvl9V14sYeh1mBjTq(4egO1(c4AnijuONixcuFXrQjff1mBjTWrTewlH1QQw6FRXZVJ6OPnJEm5arVxRQAFvTev7i(tAOdWXw7pGgqT4qsrlmgoXuUi5Ol0teOwv1MFhBrAHCBjjdhY0iZo4Ol0teOwcPEe2bdN6rsM4O2m6XK6OuV6iakfq9GUqprakLt9Ws4HjuOEO)Tgp)oQJM2m6XKde9ETQQLOAjQwwetGO35x8z26OPpButkwqEIKc0h1AKAvNrRvvT0)wJljtCuZSL0c5JtyGwl4AP)TgxsM4OMzlPfYjff1JtyGwlH1smX1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQfCTgTwv1s)BnUKmXrnZwslKpoHbATVaUwdscf6jYLa1xCKAsrrnZwslCulH1syTQQLOAzrmbIENljtCuBg9yYtKuG(OwJuRsQRwIjUwaK(3A8l(mBD00NnQjfli)BwlH1QQ2xvlr1oI)Kg6aCS1(dObuloKu0cJHtmLlso6c9ebQvvT53XwKwi3wsYWHmnYSdo6c9ebQLqQhHDWWPEYVJ6OPnJEmPok1RofgLcOEqxONiaLYPEyj8WekupSiMarVZLKjoQJKMNiPa9rTgPwcOwIjU2xv7jt0pUKmXrDK0C0f6jcq9iSdgo1ZWg2oOBPnJEmPok1RUxhLcOEqxONiaLYPEyj8WekupJ4pPHoahBT)aAa1IdjfTWy4et5IKJUqprGAvvB(DSfPfYTLKmCitJm7GJUqprGAvvllIjq078uaGIF6HPKGYtKuG(O2xaxlQiY(hQpijs9iSdgo1t(DuhnTz0Jj1rPE11HOua1d6c9ebOuo1dlHhMqH6ze)jn0b4yR9hqdOwCiPOfgdNykxKC0f6jcuRQAZVJTiTqUTKKHdzAKzhC0f6jcuRQAjQw6FRXLKjoQz2sAH8XjmqR1iGRvD1smX1YIyce9o)IpZwhn9zJAsXcYtKuG(O2xaxlQiY(hQpijwlHupc7GHt9Kcau8tpmLeuQJs9QRJqPaQh0f6jcqPCQhwcpmHc1Zi(tAOdWXw7pGgqT4qsrlmgoXuUi5Ol0teOwv1MFhBrAHCBjjdhY0iZo4Ol0teOwv1AMObTfdGRepfaO4NEykjOupc7GHt9CXNzRJM(SrnPybPok13bgLsbupOl0teGs5upSeEycfQNr8N0qhGJT2FanGAXHKIwymCIPCrYrxONiqTQQn)o2I0c52ssgoKPrMDWrxONiqTQQ1mrdAlgaxj(fFMToA6Zg1KIfK6ryhmCQhjzIJAZOhtQJs9DGsukG6bDHEIaukN6HLWdtOq9WcdOl(XbTBcfVwv1MFhBrAHCjzIJAO3Go86YrxONiqTQQL(3ACjzIJAZOht(3Swv1cG0)wJNcau8tpmLeuTH)0XuOHt41LpoHbATGRfewRQAnt0G2IbWvIljtCuhjDTQQvyh0aQrhjH4O2xQ91vRQAFvT53XwKwi3wsYWHmnYSdo6c9ebOEe2bdN6rsM4OMEkJJ6OuFhOokfq9GUqprakLt9Ws4HjuOEyHb0f)4G2nHIxRQAZVJTiTqUKmXrn0BqhED5Ol0teOwv1s)BnUKmXrTz0Jj)BwRQAbq6FRXtbak(PhMscQ2WF6yk0Wj86YhNWaTwW1ccPEe2bdN6rsM4OMwYuSqQJs9DqhqPaQh0f6jcqPCQhwcpmHc1dlmGU4hh0Uju8AvvB(DSfPfYLKjoQHEd6WRlhDHEIa1QQw6FRXLKjoQnJEm5FZAvvlr1cehpfaO4NEykjO8ejfOpQ1i1QWQLyIRfaP)TgpfaO4NEykjOAd)PJPqdNWRl)BwlH1QQwaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqR9LAbH1QQwHDqdOgDKeIJAFPwcG6ryhmCQhjzIJA6PmoQJs9DaiKsbupOl0teGs5upSeEycfQhwyaDXpoODtO41QQ287ylslKljtCuBljz4D5Ol0teOwv1s)BnUKmXrTz0Jj)BwRQAbq6FRXtbak(PhMscQ2WF6yk0Wj86YhNWaTwW12bupc7GHt9ijtCuhjn1rP(oGaOua1d6c9ebOuo1dlHhMqH6Hfgqx8JdA3ekETQQn)o2I0c5sYeh12ssgExo6c9ebQvvT0)wJljtCuBg9yY)M1QQwaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqRfCTQJ6ryhmCQhjzIJAAjtXcPok13bkmkfq9GUqprakLt9Ws4HjuOEyHb0f)4G2nHIxRQAZVJTiTqUKmXrTTKKH3LJUqprGAvvl9V14sYeh1MrpM8VzTQQ1mrdAlgaxD8uaGIF6HPKGwRQAf2bnGA0rsioQ1i12bupc7GHt9ijtCuJkAoJbmCQJs9DWRJsbupOl0teGs5upSeEycfQhwyaDXpoODtO41QQ287ylslKljtCuBljz4D5Ol0teOwv1s)BnUKmXrTz0Jj)BwRQAbq6FRXtbak(PhMscQ2WF6yk0Wj86YhNWaTwW1QuTQQvyh0aQrhjH4OwJuBhq9iSdgo1JKmXrnQO5mgWWPok13bDikfq9GUqprakLt9Ws4HjuOEYVJTiTqUTKKHdzAKzhC0f6jcuRQAbq6FRXtbak(PhMscQ2WF6yk0Wj86YhNWaTwW1Qe1JWoy4upsYeh1OIMZyadN6OuFh0rOua1d6c9ebOuo1dlHhMqH6j)o2I0c52ssgoKPrMDWrxONiqTQQLOAnt0G2IbWvINcau8tpmLe0AjM4AjQwZenOTyaC1Xtbak(PhMscATQQfaP)Tg)IpZwhn9zJAsXcY)M1syTes9iSdgo1JKmXrnQO5mgWWPok1dcnkLcOEqxONiaLYPEyj8Wekup53XwKwi3wsYWHmnYSdo6c9ebQvvTai9V14Paaf)0dtjbvB4pDmfA4eED5JtyGwl4A7aQhHDWWPEKKjoQJKM6Oupiujkfq9GUqprakLt9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQ2tMOFCjzIJAKzhC0f6jcuRQAbq6FRXV4ZS1rtF2OMuSG8Vj1JWoy4upsYeh1KWXaoXb1rPEqO6Oua1d6c9ebOuo1dlHhMqH6H(3ACauoB6iDK)nRvvTai9V14x8z26OPpButkwq(3Swv1cG0)wJFXNzRJM(SrnPyb5jskqFu7lGRL(3ACZehOZqD00KqhGtkkQhNWaTwqGAf2bdNljtCutpLXXrfr2)q9bjXAvvlr1suTNmr)4jocxCgYrxONiqTQQvyh0aQrhjH4O2xQfewlH1smX1kSdAa1OJKqCu7l1sa1syTQQLOAFvT53XwKwixsM4OMoiPLeGe9JJUqprGAjM4ApjTWJBJY8S5MSRwJuBhqa1si1JWoy4upMjoqNH6OPjHoa1rPEqyhqPaQh0f6jcqPCQhwcpmHc1d9V14aOC20r6i)BwRQAjQwIQ9Kj6hpXr4IZqo6c9ebQvvTc7Ggqn6ijeh1(sTGWAjSwIjUwHDqdOgDKeIJAFPwcOwcRvvTev7RQn)o2I0c5sYeh10bjTKaKOFC0f6jculXex7jPfECBuMNn3KD1AKA7acOwcPEe2bdN6rsM4OMEkJJ6OupieesPaQhHDWWPEgFtm9WGq9GUqprakLtDuQhesaukG6bDHEIaukN6HLWdtOq9q)BnUKmXrnZwslKpoHbATgbCTevRWoObuJoscXrTDy1QuTewRQAZVJTiTqUKmXrnDqsljaj6hhDHEIa1QQ2tsl842OmpBUj7Q9LA7acG6ryhmCQhjzIJAAjtXcPok1dcvyukG6bDHEIaukN6HLWdtOq9q)BnUKmXrnZwslKpoHbATGRL(3ACjzIJAMTKwiNuuupoHbk1JWoy4upsYeh10sMIfsDuQhe(6Oua1d6c9ebOuo1dlHhMqH6H(3ACjzIJAMTKwiFCcd0AbxRrRvvTevllIjq07CjzIJAZOhtEIKc0h1AKAvIaQLyIR9v1suTSWa6IFCq7MqXRvvT53XwKwixsM4O2wsYW7YrxONiqTewlHupc7GHt9ijtCuhjn1rPEqyhIsbupOl0teGs5upSeEycfQhIQnXwIdBHEI1smX1(QApiduOBvlH1QQw6FRXLKjoQz2sAH8XjmqRfCT0)wJljtCuZSL0c5KII6XjmqPEe2bdN6XXZgt9HKM44Ook1dc7iukG6bDHEIaukN6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvT53XwKwixsM4O2wsYW7YrxONiqTQQLOAjQ2tMOFCH0CcBqMCWW5Ol0teOwv1kSdAa1OJKqCu7l12HQLWAjM4Af2bnGA0rsioQ9LAjGAjK6ryhmCQhjzIJAs4yaN4G6Oupbyukfq9GUqprakLt9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQ2tMOFCH0CcBqMCWW5Ol0teOwv1kSdAa1OJKqCu7l1ccPEe2bdN6rsM4OMeogWjoOok1takrPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1mBjTq(4egO1(sT0)wJljtCuZSL0c5KII6XjmqPEe2bdN6rsM4Ogv0Cgdy4uhL6ja1rPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1mBjTq(4egO1cUw6FRXLKjoQz2sAHCsrr94egO1QQwZenOTyaCL4sYeh10sMIfs9iSdgo1JKmXrnQO5mgWWPoQJ6HfXei69bLcOuVsukG6bDHEIaukN6ryhmCQNwgJt7HbH6bahSeAEWWPEETegj8GkCWA)dOBvRvchZU1czq2eRThE21kM8AvihyTWR2E4zx7fhzTXzJzpCGCQhwcpmHc1t(DSfPfYTs4y2vdzq2e5Ol0teOwv1YIyce9oxsM4O2m6XKNiPa9rTgP2oWO1QQwwetGO35x8z26OPpButkwqEIcq3Avvlr1s)BnUKmXrnZwslKpoHbATVaUwdscf6jYV4i1KIIAMTKw4Owv1suTev7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejfOpQ9fW1AXaQvvTSiMarVZLKjoQnJEm5jskqFuRrQ1GKqHEI8losnPOOgaNsxDlsTywlH1smX1suTVQ2tMOF887OoAAZOhto6c9ebQvvTSiMarVZLKjoQnJEm5jskqFuRrQ1GKqHEI8losnPOOgaNsxDlsTywlH1smX1YIyce9oxsM4O2m6XKNiPa9rTVaUwlgqTewlHuhL6vhLcOEqxONiaLYPEyj8Wekup53XwKwi3kHJzxnKbztKJUqprGAvvllIjq07CjzIJAZOhtEIcq3Avvlr1(QApzI(XrFcTSp0rao6c9ebQLyIRLOApzI(XrFcTSp0rao6c9ebQvvTKIlCt2vRrax7RZO1syTewRQAjQwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTgPwLmATQQL(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0AjSwIjUwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTGR1O1QQw6FRXLKjoQz2sAH8XjmqRfCTgTwcRLWAvvl9V1453rD00MrpMCGO3RvvTKIlCt2vRraxRbjHc9e5IPMe6qYpPMuCrBYoQhHDWWPEAzmoThgeQJs9DaLcOEqxONiaLYPEyj8Wekup53XwKwihaoyqZj0LSRMfKKIdWrxONiqTQQLfXei6Do9V10aWbdAoHUKD1SGKuCaEIcq3Avvl9V14aWbdAoHUKD1SGKuCaDlJXXbIEVwv1suT0)wJljtCuBg9yYbIEVwv1s)BnE(DuhnTz0Jjhi69Avvlas)Bn(fFMToA6Zg1KIfKde9ETewRQAzrmbIENFXNzRJM(SrnPyb5jskqFul4AnATQQLOAP)TgxsM4OMzlPfYhNWaT2xaxRbjHc9e5xCKAsrrnZwslCuRQAjQwIQ9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIKc0h1(c4ATya1QQwwetGO35sYeh1MrpM8ejfOpQ1i1AqsOqpr(fhPMuuudGtPRUfPwmRLWAjM4AjQ2xv7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO35sYeh1MrpM8ejfOpQ1i1AqsOqpr(fhPMuuudGtPRUfPwmRLWAjM4AzrmbIENljtCuBg9yYtKuG(O2xaxRfdOwcRLqQhHDWWPEAzmo6yEuhL6bHukG6bDHEIaukN6HLWdtOq9KFhBrAHCa4GbnNqxYUAwqskoahDHEIa1QQwwetGO350)wtdahmO5e6s2vZcssXb4jkaDRvvT0)wJdahmO5e6s2vZcssXb0nyICGO3RvvTMjAqBXa4kXBzmo6yEupc7GHt90GjQPNY4Ook1taukG6bDHEIaukN6ryhmCQhsyMro0rtFrsI(r9aGdwcnpy4upVMaZA7OHcQThE212XVwTWwTW79OwwqcDRA)M1oIW51cc2QfE12dNZAPXA)deO2E4zxRcIRJACTmzC1cVAhtOL9n7wln2IePEyj8Wekupev7RQn)o2I0c5dOPD46XfjjhDHEIa1smX1s)Bn(aAAhUECrsY)M1syTQQLfXei6D(fFMToA6Zg1KIfKNiPa9rTVuRbjHc9e5KXPntKHiG(IJut3TwIjUwIQ1GKqHEI8dsI6VFWPwmR1i1AqsOqprozCAsrrnaoLU6wKAXSwv1YIyce9o)IpZwhn9zJAsXcYtKuG(OwJuRbjHc9e5KXPjff1a4u6QBrQV4iRLqQJs9kmkfq9GUqprakLt9Ws4HjuOEyrmbIENljtCuBg9yYtua6wRQAjQ2xv7jt0po6tOL9HocWrxONiqTetCTev7jt0po6tOL9HocWrxONiqTQQLuCHBYUAnc4AFDgTwcRLWAvvlr1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ1i1AqsOqprUyQjff1a4u6QBrQV4iRvvT0)wJljtCuZSL0c5JtyGwl4AP)TgxsM4OMzlPfYjff1JtyGwlH1smX1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQfCTgTwv1s)BnUKmXrnZwslKpoHbATGR1O1syTewRQAP)Tgp)oQJM2m6XKde9ETQQLuCHBYUAnc4AnijuONixm1Kqhs(j1KIlAt2r9iSdgo1djmZih6OPVijr)Ook1)6Oua1d6c9ebOuo1dlHhMqH6XGKqHEI84FdiaQJMMfXei69rTQQLOAhXFsdDaUHykhCI6rmnG(XrxONiqTetCTJ4pPHoa38pU)e1y(npy4C0f6jculHupc7GHt90M4WMLs7Ook13HOua1d6c9ebOuo1JWoy4upaOC20r6i1daoyj08GHt90XZEP7O2)aRfaLZMoshRThE21kM8AbbB1EXrwlCuBIcq3ALrT94CACTKcOyTJFI1ErTmzC1cVAPXwKyTxCKCQhwcpmHc1dlIjq078l(mBD00NnQjfliprbOBTQQL(3ACjzIJAMTKwiFCcd0AFbCTgKek0tKFXrQjff1mBjTWrTQQLfXei6DUKmXrTz0Jjprsb6JAFbCTwmaQJs9Dekfq9GUqprakLt9Ws4HjuOEyrmbIENljtCuBg9yYtua6wRQAjQ2xv7jt0po6tOL9HocWrxONiqTetCTev7jt0po6tOL9HocWrxONiqTQQLuCHBYUAnc4AFDgTwcRLWAvvlr1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ1i1QKrRvvT0)wJljtCuZSL0c5JtyGwl4AP)TgxsM4OMzlPfYjff1JtyGwlH1smX1suTSiMarVZV4ZS1rtF2OMuSG8efGU1QQw6FRXLKjoQz2sAH8XjmqRfCTgTwcRLWAvvl9V1453rD00MrpMCGO3RvvTKIlCt2vRraxRbjHc9e5IPMe6qYpPMuCrBYoQhHDWWPEaq5SPJ0rQJs9kzukfq9GUqprakLt9iSdgo1tkaqXp9WusqPEaWblHMhmCQhfYbw7WusqRf2Q9IJSwXbQvmRvsS2WRLbuR4a12h(7RwAS2VzTTiRDgUfM1E2Ix7zJ1skkwlaoLUgxlPak0TQD8tS2ESwBXawRC1orzC1E9rTsYehRLzlPfoQvCGApB5Q9IJS2Ez4VVA7W)JR2)ab4upSeEycfQhwetGO35x8z26OPpButkwqEIKc0h1AKAnijuONiphAsrrnaoLU6wK6loYAvvllIjq07CjzIJAZOhtEIKc0h1AKAnijuONiphAsrrnaoLU6wKAXSwv1suTNmr)453rD00MrpMC0f6jcuRQAjQwwetGO3553rD00MrpM8ejfOpQ9LArfr2)q9bjXAjM4AzrmbIENNFh1rtBg9yYtKuG(OwJuRbjHc9e55qtkkQbWP0v3IuNHzTewlXex7RQ9Kj6hp)oQJM2m6XKJUqprGAjSwv1s)BnUKmXrnZwslKpoHbATgPw1vRQAbq6FRXV4ZS1rtF2OMuSGCGO3RvvT0)wJNFh1rtBg9yYbIEVwv1s)BnUKmXrTz0Jjhi6DQJs9kPeLcOEqxONiaLYPEe2bdN6jfaO4NEykjOupa4GLqZdgo1Jc5aRDykjO12dp7AfZA7TrVwZymG0tKxliyR2loYAHJAtua6wRmQThNtJRLuafRD8tS2lQLjJRw4vln2IeR9IJKt9Ws4HjuOEyrmbIENFXNzRJM(SrnPyb5jskqFu7l1IkIS)H6dsI1QQw6FRXLKjoQz2sAH8XjmqR9fW1AqsOqpr(fhPMuuuZSL0ch1QQwwetGO35sYeh1MrpM8ejfOpQ9LAjQwurK9puFqsSwqwRWoy48l(mBD00NnQjflihvez)d1hKeRLqQJs9kPokfq9GUqprakLt9Ws4HjuOEyrmbIENljtCuBg9yYtKuG(O2xQfvez)d1hKeRvvTevlr1(QApzI(XrFcTSp0rao6c9ebQLyIRLOApzI(XrFcTSp0rao6c9ebQvvTKIlCt2vRrax7RZO1syTewRQAjQwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTgPwdscf6jYftnPOOgaNsxDls9fhzTQQL(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0AjSwIjUwIQLfXei6D(fFMToA6Zg1KIfKNiPa9rTGR1O1QQw6FRXLKjoQz2sAH8XjmqRfCTgTwcRLWAvvl9V1453rD00MrpMCGO3RvvTKIlCt2vRraxRbjHc9e5IPMe6qYpPMuCrBYUAjK6ryhmCQNuaGIF6HPKGsDuQxPoGsbupOl0teGs5upc7GHt9mI)CI3bDlD(P7s9Ws4HjuOEiQ2xvB(DSfPfYhqt7W1Jlsso6c9ebQLyIRL(3A8b00oC94IKK)nRLWAvvl9V14sYeh1mBjTq(4egO1(c4AnijuONi)IJutkkQz2sAHJAvvllIjq07CjzIJAZOhtEIKc0h1(c4Arfr2)q9bjXAvvlP4c3KD1AKAnijuONixm1Kqhs(j1KIlAt2vRQAP)Tgp)oQJM2m6XKde9o1JlKi1Zi(ZjEh0T05NUl1rPELaHukG6bDHEIaukN6ryhmCQNl(mBD00NnQjfli1daoyj08GHt9OqoWAV4iRThE21kM1cB1cV3JA7HNn0R9SXAjffRfaNsxETGGTA94mU2)aRThE21MHzTWwTNnw7jt0VAHJApbu0nUwXbQfEVh12dpBOx7zJ1skkwlaoLUCQhwcpmHc1dr1(QAZVJTiTq(aAAhUECrsYrxONiqTetCT0)wJpGM2HRhxKK8VzTewRQAP)TgxsM4OMzlPfYhNWaT2xaxRbjHc9e5xCKAsrrnZwslCuRQAzrmbIENljtCuBg9yYtKuG(O2xaxlQiY(hQpijwRQAjfx4MSRwJuRbjHc9e5IPMe6qYpPMuCrBYUAvvl9V1453rD00MrpMCGO3Pok1RebqPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1mBjTq(4egO1(c4AnijuONi)IJutkkQz2sAHJAvv7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejfOpQ9fW1IkIS)H6dsI1QQwdscf6jYpijQ)(bNAXSwJuRbjHc9e5xCKAsrrnaoLU6wKAXK6ryhmCQNl(mBD00NnQjfli1rPELuyukG6bDHEIaukN6HLWdtOq9q)BnUKmXrnZwslKpoHbATVaUwdscf6jYV4i1KIIAMTKw4Owv1suTVQ2tMOF887OoAAZOhto6c9ebQLyIRLfXei6DE(DuhnTz0Jjprsb6JAnsTgKek0tKFXrQjff1a4u6QBrQZWSwcRvvTgKek0tKFqsu)9do1IzTgPwdscf6jYV4i1KIIAaCkD1Ti1Ij1JWoy4upx8z26OPpButkwqQJs9k96Oua1d6c9ebOuo1JWoy4upsYeh1MrpMupa4GLqZdgo1Jc5aRvmRf2Q9IJSw4O2WRLbuR4a12h(7RwAS2VzTTiRDgUfM1E2Ix7zJ1skkwlaoLUgxlPak0TQD8tS2ZwUA7XATfdyTOhFl7AjfxQvCGApB5Q9SXeRfoQ1JRwzMOa0TwP287yTrRwZOhZAbIENt9Ws4HjuOEyrmbIENFXNzRJM(SrnPyb5jskqFuRrQ1GKqHEICXutkkQbWP0v3IuFXrwRQAjQ2xvllmGU4h3a6ND3SwIjUwwetGO35KWmJCOJM(IKe9JNiPa9rTgPwdscf6jYftnPOOgaNsxDlsnzC1syTQQL(3ACjzIJAMTKwiFCcd0Abxl9V14sYeh1mBjTqoPOOECcd0Avvl9V1453rD00MrpMCGO3RvvTKIlCt2vRraxRbjHc9e5IPMe6qYpPMuCrBYoQJs9k1HOua1d6c9ebOuo1JWoy4up53rD00MrpMupa4GLqZdgo1Jc5aRndZAHTAV4iRfoQn8Aza1koqT9H)(QLgR9BwBlYANHBHzTNT41E2yTKII1cGtPRX1skGcDRAh)eR9SXeRfo83xTYmrbOBTsT53XAbIEVwXbQ9SLRwXS2(WFF1sJSGeRvmiWPqpXAb(j0TQn)oYPEyj8Wekup0)wJljtCuBg9yYbIEVwv1suTSiMarVZV4ZS1rtF2OMuSG8ejfOpQ1i1AqsOqprEgMAsrrnaoLU6wK6loYAjM4AzrmbIENljtCuBg9yYtKuG(O2xaxRbjHc9e5xCKAsrrnaoLU6wKAXSwcRvvT0)wJljtCuZSL0c5JtyGwl4AP)TgxsM4OMzlPfYjff1JtyGwRQAzrmbIENljtCuBg9yYtKuG(OwJuRsgTwv1YIyce9o)IpZwhn9zJAsXcYtKuG(OwJuRsgL6OuVsDekfq9GUqprakLt9Ws4HjuOEmijuONip(3acG6OPzrmbIEFq9iSdgo1ZWg2oOBPnJEmPok1RoJsPaQh0f6jcqPCQhHDWWPEmtCGod1rttcDaQhaCWsO5bdN6rHCG1AgK1ErTJx)hrfoyTIxlQ4LsTcDTqV2ZgR1rfVAzrmbIEV2EOde9gx73N4yulODtO41E2OxB4ZU1c8tOBvRKmXXAnJEmRf4J1ErT2rFTKIl1A)DRSBTPaaf)QDykjO1chupSeEycfQNtMOF887OoAAZOhto6c9ebQvvT0)wJljtCuBg9yY)M1QQw6FRXZVJ6OPnJEm5jskqFu7l1AXa4KIIuhL6vNsukG6bDHEIaukN6HLWdtOq9aG0)wJFXNzRJM(SrnPyb5FZAvvlas)Bn(fFMToA6Zg1KIfKNiPa9rTVuRWoy4CjzIJAs4yaN4GJkIS)H6dsI1QQ2xvllmGU4hh0UjuCQhHDWWPEmtCGod1rttcDaQJs9QtDukG6bDHEIaukN6HLWdtOq9q)BnE(DuhnTz0Jj)BwRQAP)Tgp)oQJM2m6XKNiPa9rTVuRfdGtkkwRQAzrmbIENJgcMCWW5jkaDRvvTSiMarVZV4ZS1rtF2OMuSG8ejfOpQvvTVQwwyaDXpoODtO4upc7GHt9yM4aDgQJMMe6auh1r9eMOJjLcOuVsukG6bDHEIaukN6HLWdtOq9KFhBrAHCa4GbnNqxYUAwqskoahDHEIa1QQw6FRXbGdg0CcDj7QzbjP4a6wgJJ)nPEe2bdN6PbtutpLXrDuQxDukG6bDHEIaukN6HLWdtOq9KFhBrAHCReoMD1qgKnro6c9ebQvvTKIlCt2vRrQTJqaupc7GHt90YyCApmiuhL67akfq9GUqprakLt94cjs9mI)CI3bDlD(P7s9iSdgo1Zi(ZjEh0T05NUl1rPEqiLcOEe2bdN6baLZMoshPEqxONiaLYPok1taukG6bDHEIaukN6HLWdtOq9qkUWnzxTgPwqOrPEe2bdN6jfaO4NEykjOuhL6vyukG6ryhmCQhsyMro0rtFrsI(r9GUqprakLtDuQ)1rPaQh0f6jcqPCQhwcpmHc1d9V14sYeh1MrpMCGO3RvvTSiMarVZLKjoQnJEm5jskqFq9iSdgo1ZWg2oOBPnJEmPok13HOua1d6c9ebOuo1dlHhMqH6HfXei6DUKmXrTz0JjprbOBTQQL(3ACjzIJAMTKwiFCcd0AFPw6FRXLKjoQz2sAHCsrr94egOupc7GHt9ijtCuhjn1rP(ocLcOEqxONiaLYPEyj8WekupSWa6IFCdOF2DZAvvllIjq07CsyMro0rtFrsI(XtKuG(OwJuBhces9iSdgo1JKmXrn9ugh1rPELmkLcOEe2bdN65IpZwhn9zJAsXcs9GUqprakLtDuQxjLOua1JWoy4upsYeh1MrpMupOl0teGs5uhL6vsDukG6bDHEIaukN6HLWdtOq9q)BnUKmXrTz0Jjhi6DQhHDWWPEYVJ6OPnJEmPok1RuhqPaQh0f6jcqPCQhHDWWPEmtCGod1rttcDaQhaCWsO5bdN6rHCG1(ArhT2lQD86)iQWbRv8ArfVuQTJtM4yTkFkJRwGFcDRApBSwfexhLGD8RvBp0bI(A)(ehJAZV7q3Q2oozIJ1QqZSdETGGTA74KjowRcnZoQfoQ9Kj6hcyCT9yTmXFF1(hyTVw0rRThE2qV2ZgRvbX1rjyh)A12dDGOV2VpXXO2ESwOFyMFZR2ZgRTJ7O1YSf3XPX1oIA7X3ZzTdXawl84upSeEycfQNxv7jt0pUKmXrnYSdo6c9ebQvvTai9V14x8z26OPpButkwq(3Swv1cG0)wJFXNzRJM(SrnPyb5jskqFu7lGRLOAf2bdNljtCutpLXXrfr2)q9bjXAbbQL(3ACZehOZqD00KqhGtkkQhNWaTwcPok1ReiKsbupOl0teGs5upc7GHt9yM4aDgQJMMe6aupa4GLqZdgo1diyR2xl6O1Ald)9vlnIET)bculWpHUvTNnwRcIRJwBp0bIEJRThFpN1(hyTWR2lQD86)iQWbRv8ArfVuQTJtM4yTkFkJRwOx7zJ1QqfVgb74xR2EOde9CQhwcpmHc1d9V14sYeh1MrpM8VzTQQL(3A887OoAAZOhtEIKc0h1(c4AjQwHDWW5sYeh10tzCCurK9puFqsSwqGAP)Tg3mXb6muhnnj0b4KII6XjmqRLqQJs9kraukG6bDHEIaukN6HLWdtOq9aehpfaO4NEykjO8ejfOpQ1i1sa1smX1cG0)wJNcau8tpmLeuTH)0XuOHt41LpoHbATgPwJs9iSdgo1JKmXrn9ugh1rPELuyukG6bDHEIaukN6ryhmCQhjzIJAAjtXcPEaWblHMhmCQNoE2lDh1QCjtXcRvUApBSw0bQnA12XVwT92OxB(Dh6w1E2yTDCYehRvHyjjdVBTt0cDaj7s9Ws4HjuOEO)TgxsM4O2m6XK)nRvvT0)wJljtCuBg9yYtKuG(O2xQ1IbuRQAZVJTiTqUKmXrTTKKH3LJUqpraQJs9k96Oua1d6c9ebOuo1JWoy4upsYeh10sMIfs9aGdwcnpy4upD8Sx6oQv5sMIfwRC1E2yTOduB0Q9SXAvOIxR2EOde912BJET53DOBv7zJ12XjtCSwfILKm8U1orl0bKSl1dlHhMqH6H(3A887OoAAZOht(3Swv1s)BnUKmXrTz0Jjhi69Avvl9V1453rD00MrpM8ejfOpQ9fW1AXaQvvT53XwKwixsM4O2wsYW7YrxONia1rPEL6qukG6bDHEIaukN6HzlqN6rjQhuYzxnZwGUg2OEO)TgNnrjzY4GULMzlUJtoq07QiI(3ACjzIJAZOht(3KyIj6vNmr)4HbmnJEmraver)BnE(DuhnTz0Jj)BsmXSiMarVZrdbtoy48efGUesiHupSeEycfQhaK(3A8l(mBD00NnQjfli)BwRQApzI(XLKjoQrMDWrxONiqTQQLOAP)TghaLZMosh5arVxlXexRWoObuJoscXrTGRvPAjSwv1cG0)wJFXNzRJM(SrnPyb5jskqFuRrQvyhmCUKmXrnjCmGtCWrfr2)q9bjrQhHDWWPEKKjoQjHJbCIdQJs9k1rOua1d6c9ebOuo1dlHhMqH6H(3AC2eLKjJd6w8XjmqRfCT0)wJZMOKmzCq3ItkkQhNWaTwv1YcdOl(XnG(z3nPEe2bdN6rsM4OMeogWjoOok1RoJsPaQh0f6jcqPCQhHDWWPEKKjoQjHJbCIdQhMTaDQhLOEyj8Wekup0)wJZMOKmzCq3INOWUAvvllIjq07CjzIJAZOhtEIKc0h1QQwIQL(3A887OoAAZOht(3SwIjUw6FRXLKjoQnJEm5FZAjK6OuV6uIsbupOl0teGs5upSeEycfQh6FRXLKjoQz2sAH8XjmqR9fW1AqsOqpr(fhPMuuuZSL0chupc7GHt9ijtCuhjn1rPE1Pokfq9GUqprakLt9Ws4HjuOEO)Tgp)oQJM2m6XK)nRLyIRLuCHBYUAnsTkraupc7GHt9ijtCutpLXrDuQxDDaLcOEqxONiaLYPEe2bdN6bnem5GHt9a9dZ8BEAyJ6HuCHBYoJaUdraupq)Wm)MNgssIaq5qQhLOEyj8Wekup0)wJNFh1rtBg9yYbIEVwv1s)BnUKmXrTz0Jjhi6DQJs9QdesPaQhHDWWPEKKjoQPLmflK6bDHEIaukN6OoQNg0LPM(NoLcOuVsukG6bDHEIaukN6ryhmCQhjzIJAs4yaN4G6HzlqN6rjQhwcpmHc1d9V14Sjkjtgh0T4jkSJ6OuV6Oua1JWoy4upsYeh10tzCupOl0teGs5uhL67akfq9iSdgo1JKmXrnTKPyHupOl0teGs5uh1rDupgWCadNs9QZOQtDgvDQtjQNEjDOBnOEu47yfk1dcQEfUiWARvb2yTqsZiVABrw77WeDmFxBIV(pmrGAhbjwR8VGuoeOwMT4w4GxQbIqhRvjcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRvDeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowRsDabwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePKIeYl1arOJ1QKcJaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8Uw5QvHwHaiwlrkPiH8snqe6yTk96iWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRvUAvOviaI1sKsksiVudeHowRsDicS2ohUbmpeO23Nmr)4k7DTxu77tMOFCLXrxONiW7AjsjfjKxQvQPW3XkuQheu9kCrG1wRcSXAHKMrE12IS23n4Wg6w6WeDmFxBIV(pmrGAhbjwR8VGuoeOwMT4w4GxQbIqhRvjcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsDksiVudeHowR6iWA7C4gW8qGAFFYe9JRS31ErTVpzI(XvghDHEIaVRLiLuKqEPgicDS2oGaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAbHeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowlbqG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTkmcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7ALRwfAfcGyTePKIeYl1arOJ12riWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDS2ocbwBNd3aMhcu7Bw4aF4Xv27AVO23SWb(WJRmo6c9ebExRC1QqRqaeRLiLuKqEPgicDSwLuhbwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePofjKxQbIqhRvjcGaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAvQdrG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTk1riWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSw1PebwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePKIeYl1arOJ1QoqibwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePofjKxQbIqhRvDGqcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7ALRwfAfcGyTePKIeYl1arOJ1QofgbwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTYvRcTcbqSwIusrc5LAGi0XAv3RJaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIusrc5LALAk8DScL6bbvVcxeyT1QaBSwiPzKxTTiR9DgNCWWFxBIV(pmrGAhbjwR8VGuoeOwMT4w4GxQbIqhRvjcS2ohUbmpeO23Nmr)4k7DTxu77tMOFCLXrxONiW7AjsjfjKxQbIqhRvjcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRvDeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowBhqG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTeabwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePKIeYl1arOJ1QWiWA7C4gW8qGAFFYe9JRS31ErTVpzI(XvghDHEIaVRLiLuKqEPgicDSwLmkbwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePKIeYl1arOJ1QuhHaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIusrc5LAGi0XAvQJqG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTQZOeyTDoCdyEiqTVpzI(Xv27AVO23Nmr)4kJJUqprG31sKsksiVudeHowR6mkbwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1QoLiWA7C4gW8qGAFFYe9JRS31ErTVpzI(XvghDHEIaVRLiLuKqEPgicDSw1PebwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1Qo1rG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTQRdiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPwPMcFhRqPEqq1RWfbwBTkWgRfsAg5vBlYAFdGn5pV31M4R)dteO2rqI1k)liLdbQLzlUfo4LAGi0XAvhbwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePofjKxQbIqhRfesG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTkPWiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSwL6qeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowR6mkbwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1Qo1rG125WnG5Ha1(aj7CTJU(jkwRcrw7f1cIFPwaOb4agETHjMYfzTerqcRLiLuKqEPgicDSw1PocS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRvDGqcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7ALRwfAfcGyTePKIeYl1arOJ1QocGaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAvNcJaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAv3RJaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAvxhIaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAvxhHaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LALAk8DScL6bbvVcxeyT1QaBSwiPzKxTTiR9TzISGKwU31M4R)dteO2rqI1k)liLdbQLzlUfo4LAGi0XAjacS2ohUbmpeO23J4pPHoaxzVR9IAFpI)Kg6aCLXrxONiW7AjsjfjKxQbIqhRLaiWA7C4gW8qGAFpI)Kg6aCL9U2lQ99i(tAOdWvghDHEIaVRvUAvOviaI1sKsksiVudeHowRcJaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAvyeyTDoCdyEiqTVzHd8HhxzVR9IAFZch4dpUY4Ol0te4DTePKIeYl1arOJ1(6iWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRvUAvOviaI1sKsksiVudeHowBhIaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XA7ieyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVuRutHVJvOupiO6v4IaRTwfyJ1cjnJ8QTfzTVLaFxBIV(pmrGAhbjwR8VGuoeOwMT4w4GxQbIqhRvjcS2ohUbmpeO23Nmr)4k7DTxu77tMOFCLXrxONiW7AjsDksiVudeHowRseyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowR6iWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLi1PiH8snqe6yTDabwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePofjKxQbIqhRTdiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSwqibwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1saeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowRcJaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAFDeyTDoCdyEiqTVpzI(Xv27AVO23Nmr)4kJJUqprG31sKsksiVudeHowBhIaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XA7ieyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowRsgLaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAvsjcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRvj1rG125WnG5Ha1((Kj6hxzVR9IAFFYe9JRmo6c9ebExlrQtrc5LAGi0XAvQdiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSwLaHeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowRseabwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1Q0RJaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIuNIeYl1arOJ1QoJsG125WnG5Ha1((Kj6hxzVR9IAFFYe9JRmo6c9ebExlrQtrc5LAGi0XAvNrjWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSw1zucS2ohUbmpeO23J4pPHoaxzVR9IAFpI)Kg6aCLXrxONiW7AjsjfjKxQbIqhRvDkrG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTQtDeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowR66acS2ohUbmpeO23Nmr)4k7DTxu77tMOFCLXrxONiW7AjsDksiVudeHowR66acS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRvDDabwBNd3aMhcu77r8N0qhGRS31ErTVhXFsdDaUY4Ol0te4DTePKIeYl1arOJ1QoqibwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1QoqibwBNd3aMhcu77r8N0qhGRS31ErTVhXFsdDaUY4Ol0te4DTePKIeYl1arOJ1QocGaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAvhbqG125WnG5Ha1(Ee)jn0b4k7DTxu77r8N0qhGRmo6c9ebExlrkPiH8snqe6yTQtHrG125WnG5Ha1((Kj6hxzVR9IAFFYe9JRmo6c9ebExRC1QqRqaeRLiLuKqEPgicDSw196iWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSw196iWA7C4gW8qGAFpI)Kg6aCL9U2lQ99i(tAOdWvghDHEIaVRLiLuKqEPgicDSw11HiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSw11HiWA7C4gW8qGAFpI)Kg6aCL9U2lQ99i(tAOdWvghDHEIaVRLiLuKqEPgicDSw11riWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSw11riWA7C4gW8qGAFpI)Kg6aCL9U2lQ99i(tAOdWvghDHEIaVRLiLuKqEPgicDS2oWOeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowBhyucS2ohUbmpeO23J4pPHoaxzVR9IAFpI)Kg6aCLXrxONiW7AjsjfjKxQbIqhRTduIaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XA7aLiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRvUAvOviaI1sKsksiVudeHowBhOocS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRTd6acS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRTdaHeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowBhqaeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowBhOWiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDS2o41rG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTDqhIaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XA7GocbwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1ccnkbwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1ccvIaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIusrc5LAGi0XAbHQJaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIusrc5LAGi0XAbHQJaRTZHBaZdbQ9D(DSfPfYv27AVO2353XwKwixzC0f6jc8UwIusrc5LAGi0XAbHDabwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePKIeYl1arOJ1cc7acS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRfesaeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowli81rG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTGWocbwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePKIeYl1arOJ1cc7ieyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowlbyucS2ohUbmpeO23Nmr)4k7DTxu77tMOFCLXrxONiW7AjsjfjKxQvQPW3XkuQheu9kCrG1wRcSXAHKMrE12IS232ssgE331M4R)dteO2rqI1k)liLdbQLzlUfo4LAGi0XAvIaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIusrc5LAGi0XAvyeyTDoCdyEiqTVVe6GIhxOzCwetGO3Fx7f1(MfXei6DUqZExlrQtrc5LAGi0XAFDeyTDoCdyEiqTVVe6GIhxOzCwetGO3Fx7f1(MfXei6DUqZExlrQtrc5LAGi0XA7ieyTDoCdyEiqTVzHd8HhxzVR9IAFZch4dpUY4Ol0te4DTePKIeYl1arOJ1QuhqG125WnG5Ha1(MfoWhECL9U2lQ9nlCGp84kJJUqprG31sKsksiVudeHowRsGqcS2ohUbmpeO23SWb(WJRS31ErTVzHd8HhxzC0f6jc8UwIusrc5LAGi0XAvIaiWA7C4gW8qGAFFYe9JRS31ErTVpzI(XvghDHEIaVRLiLuKqEPgicDSwLiacS2ohUbmpeO23SWb(WJRS31ErTVzHd8HhxzC0f6jc8UwIusrc5LAGi0XAvNseyTDoCdyEiqTVzHd8HhxzVR9IAFZch4dpUY4Ol0te4DTePKIeYl1k1u47yfk1dcQEfUiWARvb2yTqsZiVABrw7BwetGO3hVRnXx)hMiqTJGeRv(xqkhculZwClCWl1arOJ1QebwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePofjKxQbIqhRvjcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRvDeyTDoCdyEiqTVpzI(Xv27AVO23Nmr)4kJJUqprG31sK6uKqEPgicDSw1rG125WnG5Ha1(o)o2I0c5k7DTxu7787ylslKRmo6c9ebExlrkPiH8snqe6yTDabwBNd3aMhcu77tMOFCL9U2lQ99jt0pUY4Ol0te4DTePofjKxQbIqhRTdiWA7C4gW8qGAFNFhBrAHCL9U2lQ9D(DSfPfYvghDHEIaVRLiLuKqEPgicDSwqibwBNd3aMhcu7787ylslKRS31ErTVZVJTiTqUY4Ol0te4DTePKIeYl1arOJ1saeyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowRcJaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIuNIeYl1arOJ1(6iWA7C4gW8qGAFpI)Kg6aCL9U2lQ99i(tAOdWvghDHEIaVRLi1PiH8snqe6yTDecS2ohUbmpeO23Nmr)4k7DTxu77tMOFCLXrxONiW7AjsDksiVudeHowRsgLaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIuNIeYl1arOJ1QK6iWA7C4gW8qGAFFYe9JRS31ErTVpzI(XvghDHEIaVRLi1PiH8snqe6yTk1beyTDoCdyEiqTVZVJTiTqUYEx7f1(o)o2I0c5kJJUqprG31sKsksiVudeHowRsGqcS2ohUbmpeO2353XwKwixzVR9IAFNFhBrAHCLXrxONiW7AjsjfjKxQbIqhRvjcGaRTZHBaZdbQ99jt0pUYEx7f1((Kj6hxzC0f6jc8UwIusrc5LAGi0XAvsHrG125WnG5Ha1((Kj6hxzVR9IAFFYe9JRmo6c9ebExlrkPiH8snqe6yTQZOeyTDoCdyEiqTVpzI(Xv27AVO23Nmr)4kJJUqprG31sKsksiVuRudeK0mYdbQTJuRWoy41oHJBWl1OEmZObNi1tN6uTDuXcRTJtM4yPwN6uTkefPZVKDRvDeGX1QoJQo1vQvQ1PovBNTf3cheyPwN6uTDy1QqoWAVUMqMmR9bs25ATfhycDRAJwTmBXDCwl0pmZV5bdVwOpouaQnA1(MjodNAHDWWFZl16uNQTdR2oBlUfwRKmXrn0BqhEDR9IALKjoQTLKm8U1se8Q1rdywBp6xTtObSwzuRKmXrTTKKH3LqEPwN6uTDy1QWD4VVAvOnem5WAHETDScbf6A7W)JRwAKj)bwB34)oXAJ)vB0Qnf3cRvCGA94Q9pGUvTDCYehRvHwrZzmGHZl16uNQTdR2ogOd)pUAntyKWRBTxu7FG12XjtCS2xl6X89OwS1q2bnG1YIyce9ET0YabQn8A7Sc3ku1ITgYUbVuRtDQ2oSAvihyTJlHSRwZmy4yaDRAVO2eb(mS2o)AkK1EqsSwGpw7f1(Dhz4yiz3A74xdeRTfjOdEPwN6uTDy12rddiqTgKek0tCqqMmz)PCWWh1ErTG4xQLma(tS2lQnrGpdRTZVMczThKe5LALAc7GHp4MjYcsA5ajyckjtCud9dNtKDLAc7GHp4MjYcsA5ajyckjtCu3es4ekzPMWoy4dUzISGKwoqcMGSW7W)jQjfx0wizPwN6uTc7GHp4MjYcsA5ajycAqsOqprJDHeblbQpjTWtZIVFghMGtCGNXayt(ZdChuQ1PovRWoy4dUzISGKwoqcMGgKek0t0yxirWOHqBYoJdtWjoWZyaSj)5bwjcOuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGnt08pNA0qyCycEGNXWgyIYVJTiTq(aAAhUECrsQIiwyaDXpUb0p7UjXeZcdOl(XDKLXmsaIjMfoWhECjzIJAZmaGwDjKqJniZpcwjJniZpQX5abB0sTo1PAf2bdFWntKfK0YbsWe0GKqHEIg7cjc2wmG6WeDeW4We8apJHnWc7Ggqn6ijehgbSbjHc9e5sG6tsl80S47NXgK5hbRKXgK5h14CGGnAPwN6uTc7GHp4MjYcsA5ajycAqsOqprJDHeb3GUm10)0nombpWZydY8JGnAPwN6uTc7GHp4MjYcsA5ajycAqsOqprJDHebBljz4D1JtyGQpijACycoXbEgdGn5ppWDKsTo1PAf2bdFWntKfK0YbsWe0GKqHEIg7cjcwM9s3HE01zAwetGO3hghMGtCGNXayt(ZdSrl16uNQvyhm8b3mrwqslhibtqdscf6jASlKi4COjff1a4u6QBrQV4inombN4apJbWM8NhycOuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGZHMuuudGtPRUfPodtJdtWjoWZyaSj)5bMak16uNQvyhm8b3mrwqslhibtqdscf6jASlKi4COjff1a4u6QBrQftJdtWjoWZyaSj)5bwDgTuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGjJtBMidra9fhPMURXHj4eh4zma2K)8a3Hk16uNQvyhm8b3mrwqslhibtqdscf6jASlKiyY40KIIAaCkD1Ti1xCKghMGtCGNXayt(ZdSsgTuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGjJttkkQbWP0v3IulMghMGtCGNXayt(ZdSseqPwN6uTc7GHp4MjYcsA5ajycAqsOqprJDHeblMAsrrnaoLU6wK6losJdtWjoWZyydmlCGp84sYeh1MzaaT6ASbz(rWDGrn2Gm)OgNdeSsgTuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGftnPOOgaNsxDls9fhPXHj4eh4zma2K)8aRoJwQ1PovRWoy4dUzISGKwoqcMGgKek0t0yxirWIPMuuudGtPRUfPMmoJdtWjoWZyaSj)5bwDgTuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGZWutkkQbWP0v3IuFXrACycEGNXgK5hbRoJ2HrebacWch4dpUKmXrTzgaqRUewQ1PovRWoy4dUzISGKwoqcMGgKek0t0yxirWxCKAsrrnaoLU6wKAX04We8apJniZpcMaaP6mkiarSWa6IFChAzF6MGetmrSWb(WJljtCuBMba0QRkHDqdOgDKeIJxmijuONixcuFsAHNMfF)iKqqQebacqelmGU4hh0UjuCv53XwKwixsM4O2wsYW7Qsyh0aQrhjH4WiGnijuONixcuFsAHNMfF)iSuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGV4i1KIIAaCkD1Ti1zyACycEGNXgK5hbRoJ2HruhceGfoWhECjzIJAZmaGwDjSuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGPLmflutkUOnzNXHj4bEgdBGzHb0f)4o0Y(0nbn2Gm)iyfMr7WiIughMD1gK5hbbuYOgLWsTo1PAf2bdFWntKfK0YbsWe0GKqHEIg7cjcMwYuSqnP4I2KDghMGh4zmSbMfgqx8JdA3ekUXgK5hb3riGomIiLXHzxTbz(rqaLmQrjSuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGPLmflutkUOnzNXHj4bEgdBGnijuONiNwYuSqnP4I2KDGnQXgK5hb3HmAhgrKY4WSR2Gm)iiGsg1OewQ1PovRWoy4dUzISGKwoqcMGgKek0t0yxirWIPMe6qYpPMuCrBYoJdtWjoWZyaSj)5bwjcOuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGV4i1KIIAMTKw4W4WeCId8mgaBYFEGvxPwN6uTc7GHp4MjYcsA5ajycAqsOqprJDHeblbQV4i1KIIAMTKw4W4WeCId8mgaBYFEGvxPwN6uTc7GHp4MjYcsA5ajycAqsOqprJDHeb3GdBOBPdt0X04We8apJniZpcwjqaIWx)hAAIaCK0SBIYuhjGlodjMyIozI(XZVJ6OPnJEmvr0jt0pUKmXrnYSdIj(vSWa6IFCq7MqXjufrVIfgqx8J7ilJzKaetSWoObuJoscXbyLiM487ylslKpGM2HRhxKKeQ6vSWa6IFCdOF2DtcjSuRtDQwHDWWhCZezbjTCGembnijuONOXUqIGftD46)anombpWZydY8JGXx)hAAIaCsHj0jQh2iEAY)aYiMy81)HMMia3Akaq5ICOPfalKyIXx)hAAIaCRPaaLlYHMebK5egoXeJV(p00eb4asckzeUgazGQn)xIdg6mKyIXx)hAAIaCOpy5)e6jQF9FXVpPganaziXeJV(p00eb4J4pN4Dq3sNF6Uetm(6)qtteGp(o9mcaTqIND3XrmX4R)dnnraEVak6yo0TmCaIjgF9FOPjcWBtHe1rttl3nXsnHDWWhCZezbjTCGembjHzgPgskwyPMWoy4dUzISGKwoqcMGTjoSzP0oJHnWJ4pPHoa3qmLdor9iMgq)iM4r8N0qhGB(h3FIAm)Mhm8snHDWWhCZezbjTCGembZVJ6OPnJEmng2aZcdOl(XbTBcfxv(DSfPfYLKjoQTLKm8UQyHd8HhxsM4O2mdaOvxvgKek0tKlZEP7qp66mnlIjq07dvc7Ggqn6ijehVyqsOqprUeO(K0cpnl((vQjSdg(GBMiliPLdKGjylJXrhZZyyd8RmijuONi3mrZ)CQrdbyLuLFhBrAHCa4GbnNqxYUAwqskoqPMWoy4dUzISGKwoqcMGsYeh10tzCgdBGFLbjHc9e5MjA(NtnAiaRKQxLFhBrAHCa4GbnNqxYUAwqskoGkIEflmGU4h3a6ND3KyInijuONiVbh2q3shMOJjHLAc7GHp4MjYcsA5ajycscZmYHoA6lss0pJHnWVYGKqHEICZen)ZPgneGvs1RYVJTiTqoaCWGMtOlzxnlijfhqflmGU4h3a6ND3u1RmijuONiVbh2q3shMOJzPMWoy4dUzISGKwoqcMGOHGjhmCJHnWgKek0tKBMO5Fo1OHaSsLALAc7GHpajycYIVFyomX5Sutyhm8bibtW)a1KIlAlK0yydmrNmr)4OpHw2h6iGksXfUj7EbChYOQifx4MSZiGvyeaHetmrV6Kj6hh9j0Y(qhburkUWnz3lG7qeaHLAc7GHpajycAghmCJHnW0)wJljtCuBg9yY)MLAc7GHpajycEqsu3lPPXWg487ylslKFiPzKYu3lPPk6FRXrfTL)4GHZ)MQiIfXei6DUKmXrTz0JjprbOlXethJHQg0Y(0jskqF8cyqOrjSutyhm8bibtWj0Y(g6o8pGfj6NXWgy6FRXLKjoQnJEm5arVRI(3A887OoAAZOhtoq07Qaq6FRXV4ZS1rtF2OMuSGCGO3l1e2bdFasWeKwS0rtFjKb6Wyydm9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjhi6Dvai9V14x8z26OPpButkwqoq07LAc7GHpajycsJ5atqHULXWgy6FRXLKjoQnJEm5FZsnHDWWhGembPNraOB)SRXWgy6FRXLKjoQnJEm5FZsnHDWWhGembBWePNraymSbM(3ACjzIJAZOht(3Sutyhm8bibtqXz44szQzYCAmSbM(3ACjzIJAZOht(3Sutyhm8bibtW)a1WdjhgdBGP)TgxsM4O2m6XK)nl1e2bdFasWe8pqn8qsJXwdzN2fseS1uaGYf5qtlawOXWgy6FRXLKjoQnJEm5FtIjMfXei6DUKmXrTz0Jjprsb6dJaMaiavai9V14x8z26OPpButkwq(3Sutyhm8bibtW)a1Wdjn2fsemze(eEAZeoing2aZcdOl(XbTBcfxflIjq07CjzIJAZOhtEIKc0hVawjJQIfXei6D(fFMToA6Zg1KIfKNiPa9XlGvYOLAc7GHpajyc(hOgEiPXUqIGjJWNWtBMWbPXWg4xXcdOl(XbTBcfxflIjq07CjzIJAZOhtEIKc0hVawHPIfXei6D(fFMToA6Zg1KIfKNiPa9XlGvyLAc7GHpajyc(hOgEiPXUqIGrsZUjktDKaU4m0yydmlIjq07CjzIJAZOhtEIKc0hVawjcqflIjq078l(mBD00NnQjfliprsb6JxaRebuQjSdg(aKGj4FGA4HKg7cjcgirbObtuBahdCAmSbMfXei6DUKmXrTz0Jjprsb6dJawDgLyIFLbjHc9e5IPoC9FGGvIyIj6GKiyJQYGKqHEI8gCydDlDyIoMGvsv(DSfPfYhqt7W1Jlsscl1e2bdFasWe8pqn8qsJDHebpI)udTC4HPXWgywetGO35sYeh1MrpM8ejfOpmc4oWOet8RmijuONixm1HR)deSsLAc7GHpajyc(hOgEiPXUqIGTMDnT1rtlJbKeoLdgUXWgywetGO35sYeh1MrpM8ejfOpmcy1zuIj(vgKek0tKlM6W1)bcwjIjMOdsIGnQkdscf6jYBWHn0T0Hj6ycwjv53XwKwiFanTdxpUijjSutyhm8bibtW)a1Wdjn2fsemPWe6e1dBepn5FazgdBGzrmbIENljtCuBg9yYtKuG(4fWeGkIELbjHc9e5n4Wg6w6WeDmbReXeFqs0iDGrjSutyhm8bibtW)a1Wdjn2fsemPWe6e1dBepn5FazgdBGzrmbIENljtCuBg9yYtKuG(4fWeGkdscf6jYBWHn0T0Hj6ycwjv0)wJNFh1rtBg9yY)MQO)Tgp)oQJM2m6XKNiPa9XlGjsjJ2HraGa53XwKwiFanTdxpUijju1bjXx6aJwQjSdg(aKGj4FGA4HKg7cjcEylarpcOJKwhn9fjj6NXWg4dsIGnkXetKbjHc9e5X)gqauhnnlIjq07dverelmGU4hh0UjuCvSiMarVZtbak(PhMsckprsb6JxaRovSiMarVZLKjoQnJEm5jskqF8cycqflIjq078l(mBD00NnQjfliprsb6JxataesmXSiMarVZLKjoQnJEm5jskqF8cy1rmXnOL9PtKuG(4fwetGO35sYeh1MrpM8ejfOpiKWsTovlbWvy1ch1E2yTdtebQnA1E2yTpXFoX7GUvTkuF6U1AMrhoYo4el1e2bdFasWe8pqn8qsJDHebpI)CI3bDlD(P7AmSbMidscf6jYpijQ)(bNAXeKejSdgopfaO4NEykjOCurK9puFqseeGfgqx8JdA3ekoHGKiHDWW5aOC20r6ihvez)d1hKebbyHb0f)4oYYygjaHGuyhmC(fFMToA6Zg1KIfKJkIS)H6dsIVCsAHhhaooXzOcrsaCfgHQiYGKqHEICBXaQdt0raIjMiwyaDXpoODtO4QYVJTiTqUKmXrn0BqhEDjKqvNKw4XbGJtCgAe1raLADQt1kSdg(aKGjOJ9T47a6ehX0aA8FG6EB4e1mzCq3cSsgdBGP)TgxsM4O2m6XK)njMyaK(3A8l(mBD00NnQjfli)BsmXaXXtbak(PhMsck)GmqHUvPwN6uTc7GHpajycYK5ulSdgUEchNXUqIGzYK9NYbdFuQjSdg(aKGjitMtTWoy46jCCg7cjcwc04XLq2bwjJHnWc7Ggqn6ijehgbSbjHc9e5sG6tsl80S47xPMWoy4dqcMGmzo1c7GHRNWXzSlKiyBjjdVRXJlHSdSsgdBGzHb0f)4G2nHIRk)o2I0c5sYeh12ssgE3snHDWWhGembzYCQf2bdxpHJZyxirWn4Wg6w6WeDmnECjKDGvYyydSbjHc9e52IbuhMOJaGnQkdscf6jYBWHn0T0Hj6yQ6veXcdOl(XbTBcfxv(DSfPfYLKjoQTLKm8UewQjSdg(aKGjitMtTWoy46jCCg7cjcomrhtJhxczhyLmg2aBqsOqprUTya1Hj6iayJQ6veXcdOl(XbTBcfxv(DSfPfYLKjoQTLKm8UewQjSdg(aKGjitMtTWoy46jCCg7cjcMfXei69HXJlHSdSsgdBGFfrSWa6IFCq7MqXvLFhBrAHCjzIJABjjdVlHLAc7GHpajycYK5ulSdgUEchNXUqIGZ4KdgUXJlHSdSsgdBGnijuONiVbDzQP)Pd2OQEfrSWa6IFCq7MqXvLFhBrAHCjzIJABjjdVlHLAc7GHpajycYK5ulSdgUEchNXUqIGBqxMA6F6gpUeYoWkzmSb2GKqHEI8g0LPM(NoyLu9kIyHb0f)4G2nHIRk)o2I0c5sYeh12ssgExcl1k1e2bdFWLab3YyC0X8mg2aNFhBrAHCa4GbnNqxYUAwqskoGkwetGO350)wtdahmO5e6s2vZcssXb4jkaDvr)BnoaCWGMtOlzxnlijfhq3YyCCGO3vre9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjhi6Dvai9V14x8z26OPpButkwqoq07eQIfXei6D(fFMToA6Zg1KIfKNiPa9byJQIi6FRXLKjoQz2sAH8XjmqFbSbjHc9e5sG6losnPOOMzlPfourerNmr)453rD00MrpMQyrmbIENNFh1rtBg9yYtKuG(4fWwmavSiMarVZLKjoQnJEm5jskqFyedscf6jYV4i1KIIAaCkD1Ti1IjHetmrV6Kj6hp)oQJM2m6XuflIjq07CjzIJAZOhtEIKc0hgXGKqHEI8losnPOOgaNsxDlsTysiXeZIyce9oxsM4O2m6XKNiPa9XlGTyaesyPMWoy4dUeiibtWgmrn9ugNXWgyIYVJTiTqoaCWGMtOlzxnlijfhqflIjq07C6FRPbGdg0CcDj7QzbjP4a8efGUQO)TghaoyqZj0LSRMfKKIdOBWe5arVRYmrdAlgaxjElJXrhZJqIjMO87ylslKdahmO5e6s2vZcssXbuDqseSrjSutyhm8bxceKGjylJXP9WGymSbo)o2I0c5wjCm7QHmiBIQyrmbIENljtCuBg9yYtKuG(WiDGrvXIyce9o)IpZwhn9zJAsXcYtKuG(aSrvre9V14sYeh1mBjTq(4egOVa2GKqHEICjq9fhPMuuuZSL0chQiIOtMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jskqF8cylgGkwetGO35sYeh1MrpM8ejfOpmIbjHc9e5xCKAsrrnaoLU6wKAXKqIjMOxDYe9JNFh1rtBg9yQIfXei6DUKmXrTz0Jjprsb6dJyqsOqpr(fhPMuuudGtPRUfPwmjKyIzrmbIENljtCuBg9yYtKuG(4fWwmacjSutyhm8bxceKGjylJXP9WGymSbo)o2I0c5wjCm7QHmiBIQyrmbIENljtCuBg9yYtKuG(aSrvrereXIyce9o)IpZwhn9zJAsXcYtKuG(WigKek0tKlMAsrrnaoLU6wK6losv0)wJljtCuZSL0c5JtyGcM(3ACjzIJAMTKwiNuuupoHbkHetmrSiMarVZV4ZS1rtF2OMuSG8ejfOpaBuv0)wJljtCuZSL0c5JtyG(cydscf6jYLa1xCKAsrrnZwslCqiHQO)Tgp)oQJM2m6XKde9oHLAc7GHp4sGGembLKjoQjHJbCIdJHnWSWa6IFCq7MqXvLFhBrAHCjzIJABjjdVRk6FRXLKjoQTLKm8U8XjmqFrjcqflIjq078uaGIF6HPKGYtKuG(4fWgKek0tKBljz4D1JtyGQpijcsurK9puFqsuflIjq078l(mBD00NnQjfliprsb6JxaBqsOqprUTKKH3vpoHbQ(GKiirfr2)q9bjrqkSdgopfaO4NEykjOCurK9puFqsuflIjq07CjzIJAZOhtEIKc0hVa2GKqHEICBjjdVRECcdu9bjrqIkIS)H6dsIGuyhmCEkaqXp9Wusq5OIi7FO(GKiif2bdNFXNzRJM(SrnPyb5OIi7FO(GKOXmBb6GvQutyhm8bxceKGjOKmXrnjCmGtCymSbMfgqx8JBa9ZUBQk)o2I0c5sYeh1qVbD41vf9V14sYeh12ssgEx(4egOVOebOIfXei6D(fFMToA6Zg1KIfKNiPa9XlGnijuONi3wsYW7QhNWavFqseKOIi7FO(GKOkwetGO35sYeh1MrpM8ejfOpEbSbjHc9e52ssgEx94egO6dsIGevez)d1hKebPWoy48l(mBD00NnQjflihvez)d1hKenMzlqhSsLAc7GHp4sGGembLKjoQPNY4mg2aZcdOl(XnG(z3nvDYe9JljtCuJm7q1bjXxuYOQyrmbIENtcZmYHoA6lss0pEIKc0hQO)TgNnrjzY4GUfFCcd0x6GsnHDWWhCjqqcMG)bQHhsASlKi4r8Nt8oOBPZpDxJHnW53XwKwiFanTdxpUijvzMObTfdGRehnem5GHxQjSdg(GlbcsWe8IpZwhn9zJAsXcAmSbo)o2I0c5dOPD46XfjPkZenOTyaCL4OHGjhm8snHDWWhCjqqcMGsYeh1MrpMgdBGZVJTiTq(aAAhUECrsQIiZenOTyaCL4OHGjhmCIj2mrdAlgaxj(fFMToA6Zg1KIfKWsnHDWWhCjqqcMGKWmJCOJM(IKe9ZyydC(DSfPfYLKjoQHEd6WRRkwetGO35x8z26OPpButkwqEIKc0hVawjJQIfXei6DUKmXrTz0Jjprsb6JxaRebuQjSdg(GlbcsWeKeMzKdD00xKKOFgdBGzrmbIENljtCuBg9yYtKuG(4fWDivSiMarVZV4ZS1rtF2OMuSG8ejfOpEbChsfr0)wJljtCuZSL0c5JtyG(cydscf6jYLa1xCKAsrrnZwslCOIiIozI(XZVJ6OPnJEmvXIyce9op)oQJM2m6XKNiPa9XlGTyaQyrmbIENljtCuBg9yYtKuG(WieaHetmrV6Kj6hp)oQJM2m6XuflIjq07CjzIJAZOhtEIKc0hgHaiKyIzrmbIENljtCuBg9yYtKuG(4fWwmacjSutyhm8bxceKGjiAiyYbd3yyd8bjrJ0bgvv(DSfPfYhqt7W1JlssvSWa6IFCdOF2DtvMjAqBXa4kXjHzg5qhn9fjj6xPMWoy4dUeiibtq0qWKdgUXWg4dsIgPdmQQ87ylslKpGM2HRhxKKQO)TgxsM4OMzlPfYhNWa9fWgKek0tKlbQV4i1KIIAMTKw4qflIjq078l(mBD00NnQjfliprsb6dWgvflIjq07CjzIJAZOhtEIKc0hVa2IbuQjSdg(GlbcsWeenem5GHBmSb(GKOr6aJQk)o2I0c5dOPD46XfjPkwetGO35sYeh1MrpM8ejfOpaBuvererSiMarVZV4ZS1rtF2OMuSG8ejfOpmIbjHc9e5IPMuuudGtPRUfP(IJuf9V14sYeh1mBjTq(4egOGP)TgxsM4OMzlPfYjff1JtyGsiXetelIjq078l(mBD00NnQjfliprsb6dWgvf9V14sYeh1mBjTq(4egOVa2GKqHEICjq9fhPMuuuZSL0chesOk6FRXZVJ6OPnJEm5arVtOXq)Wm)MNg2at)Bn(aAAhUECrsYhNWafm9V14dOPD46XfjjNuuupoHbQXq)Wm)MNgssIaq5qWkvQjSdg(GlbcsWe8pqn8qsJDHebpI)CI3bDlD(P7AmSbMfXei6DEkaqXp9Wusq5jkaDvXIyce9o)IpZwhn9zJAsXcYtKuG(4fWwmaoPOOkwetGO35sYeh1MrpM8ejfOpEbSfdGtkkwQjSdg(GlbcsWemfaO4NEykjOgdBGzrmbIENFXNzRJM(SrnPyb5jskqF8cQiY(hQpijQIiIozI(XZVJ6OPnJEmvXIyce9op)oQJM2m6XKNiPa9XlGTyaQyrmbIENljtCuBg9yYtKuG(WigKek0tKFXrQjff1a4u6QBrQftcjMyIE1jt0pE(DuhnTz0JPkwetGO35sYeh1MrpM8ejfOpmIbjHc9e5xCKAsrrnaoLU6wKAXKqIjMfXei6DUKmXrTz0Jjprsb6JxaBXaiSutyhm8bxceKGjykaqXp9Wusqng2aZIyce9oxsM4O2m6XKNiPa9XlOIi7FO(GKOkIiIiwetGO35x8z26OPpButkwqEIKc0hgXGKqHEICXutkkQbWP0v3IuFXrQI(3ACjzIJAMTKwiFCcduW0)wJljtCuZSL0c5KII6XjmqjKyIjIfXei6D(fFMToA6Zg1KIfKNiPa9byJQI(3ACjzIJAMTKwiFCcd0xaBqsOqprUeO(IJutkkQz2sAHdcjuf9V1453rD00MrpMCGO3jSutyhm8bxceKGjiakNnDKoAmSbMfXei6DUKmXrTz0Jjprsb6dWgvfrerelIjq078l(mBD00NnQjfliprsb6dJyqsOqprUyQjff1a4u6QBrQV4ivr)BnUKmXrnZwslKpoHbky6FRXLKjoQz2sAHCsrr94egOesmXeXIyce9o)IpZwhn9zJAsXcYtKuG(aSrvr)BnUKmXrnZwslKpoHb6lGnijuONixcuFXrQjff1mBjTWbHeQI(3A887OoAAZOhtoq07ewQjSdg(GlbcsWe8pqn8qsJDHebpI)CI3bDlD(P7AmSbMi6FRXLKjoQz2sAH8XjmqFbSbjHc9e5sG6losnPOOMzlPfoiMyZenOTyaCL4Paaf)0dtjbLqver0jt0pE(DuhnTz0JPkwetGO3553rD00MrpM8ejfOpEbSfdqflIjq07CjzIJAZOhtEIKc0hgXGKqHEI8losnPOOgaNsxDlsTysiXet0RozI(XZVJ6OPnJEmvXIyce9oxsM4O2m6XKNiPa9HrmijuONi)IJutkkQbWP0v3IulMesmXSiMarVZLKjoQnJEm5jskqF8cylgaHQEfrJ4pPHoahBT)aAa1IdjfTWy4et5Iuv(DSfPfYTLKmCitJm7GWsnHDWWhCjqqcMGx8z26OPpButkwqJHnWSWa6IFCdOF2Dtv53XwKwixsM4Og6nOdVUQyrmbIENtcZmYHoA6lss0pEIKc0hVaMamAPMWoy4dUeiibtWl(mBD00NnQjflOXWgywyaDXpUb0p7UPQ87ylslKljtCud9g0Hxxv0)wJtcZmYHoA6lss0pEIKc0hVawDgvflIjq07CjzIJAZOhtEIKc0hVa2IbuQjSdg(GlbcsWe8IpZwhn9zJAsXcAmSbMi6FRXLKjoQz2sAH8XjmqFbSbjHc9e5sG6losnPOOMzlPfoiMyZenOTyaCL4Paaf)0dtjbLqver0jt0pE(DuhnTz0JPkwetGO3553rD00MrpM8ejfOpEbSfdqflIjq07CjzIJAZOhtEIKc0hgXGKqHEI8losnPOOgaNsxDlsTysiXet0RozI(XZVJ6OPnJEmvXIyce9oxsM4O2m6XKNiPa9HrmijuONi)IJutkkQbWP0v3IulMesmXSiMarVZLKjoQnJEm5jskqF8cylgaHQEfrJ4pPHoahBT)aAa1IdjfTWy4et5Iuv(DSfPfYTLKmCitJm7GWsnHDWWhCjqqcMGsYeh1MrpMgdBGjIiwetGO35x8z26OPpButkwqEIKc0hgXGKqHEICXutkkQbWP0v3IuFXrQI(3ACjzIJAMTKwiFCcduW0)wJljtCuZSL0c5KII6XjmqjKyIjIfXei6D(fFMToA6Zg1KIfKNiPa9byJQI(3ACjzIJAMTKwiFCcd0xaBqsOqprUeO(IJutkkQz2sAHdcjuf9V1453rD00MrpMCGO3v9kIgXFsdDao2A)b0aQfhskAHXWjMYfPQ87ylslKBljz4qMgz2bHLAc7GHp4sGGembZVJ6OPnJEmng2at)BnE(DuhnTz0Jjhi6DverelIjq078l(mBD00NnQjfliprsb6dJOoJQI(3ACjzIJAMTKwiFCcduW0)wJljtCuZSL0c5KII6XjmqjKyIjIfXei6D(fFMToA6Zg1KIfKNiPa9byJQI(3ACjzIJAMTKwiFCcd0xaBqsOqprUeO(IJutkkQz2sAHdcjufrSiMarVZLKjoQnJEm5jskqFyeLuhXedG0)wJFXNzRJM(SrnPyb5Ftcv9kIgXFsdDao2A)b0aQfhskAHXWjMYfPQ87ylslKBljz4qMgz2bHLAc7GHp4sGGembh2W2bDlTz0JPXWgywetGO35sYeh1rsZtKuG(WieaXe)QtMOFCjzIJ6iPl1e2bdFWLabjycMFh1rtBg9yAmSbEe)jn0b4yR9hqdOwCiPOfgdNykxKQYVJTiTqUTKKHdzAKzhQyrmbIENNcau8tpmLeuEIKc0hVagvez)d1hKel1e2bdFWLabjycMcau8tpmLeuJHnWJ4pPHoahBT)aAa1IdjfTWy4et5Iuv(DSfPfYTLKmCitJm7qfr0)wJljtCuZSL0c5JtyGAeWQJyIzrmbIENFXNzRJM(SrnPyb5jskqF8cyurK9puFqsKWsnHDWWhCjqqcMGx8z26OPpButkwqJHnWJ4pPHoahBT)aAa1IdjfTWy4et5Iuv(DSfPfYTLKmCitJm7qLzIg0wmaUs8uaGIF6HPKGwQjSdg(GlbcsWeusM4O2m6X0yyd8i(tAOdWXw7pGgqT4qsrlmgoXuUivLFhBrAHCBjjdhY0iZouzMObTfdGRe)IpZwhn9zJAsXcwQ1PovRWoy4dUeiibtWEbEgpqgyJYnki0yydmas)BnEkaqXp9Wusq1g(thtHgoHxx(4egOGjcaP)TgpfaO4NEykjOAd)PJPqdNWRlNuuupoHbAhMseQk)o2I0c52ssgoKPrMDOsyh0aQrhjH44fcW4j0rndaS6iGsnHDWWhCjqqcMGsYeh10tzCgdBGzHb0f)4G2nHIRk)o2I0c5sYeh1qVbD41vf9V14sYeh1MrpM8VPkaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqbdcvzMObTfdGRexsM4OosAvc7Ggqn6ijehV86u9Q87ylslKBljz4qMgz2rPMWoy4dUeiibtqjzIJAAjtXcng2aZcdOl(XbTBcfxv(DSfPfYLKjoQHEd6WRRk6FRXLKjoQnJEm5Ftvai9V14Paaf)0dtjbvB4pDmfA4eED5JtyGcgewQjSdg(GlbcsWeusM4OMEkJZyydmlmGU4hh0UjuCv53XwKwixsM4Og6nOdVUQO)TgxsM4O2m6XK)nvreqC8uaGIF6HPKGYtKuG(WikmIjgaP)TgpfaO4NEykjOAd)PJPqdNWRl)BsOkaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqFbeQsyh0aQrhjH44fcOutyhm8bxceKGjOKmXrDK0gdBGzHb0f)4G2nHIRk)o2I0c5sYeh12ssgExv0)wJljtCuBg9yY)MQaq6FRXtbak(PhMscQ2WF6yk0Wj86YhNWafChuQjSdg(GlbcsWeusM4OMwYuSqJHnWSWa6IFCq7MqXvLFhBrAHCjzIJABjjdVRk6FRXLKjoQnJEm5Ftvai9V14Paaf)0dtjbvB4pDmfA4eED5JtyGcwDLAc7GHp4sGGembLKjoQrfnNXagUXWgywyaDXpoODtO4QYVJTiTqUKmXrTTKKH3vf9V14sYeh1MrpM8VPkZenOTyaC1Xtbak(PhMscQkHDqdOgDKeIdJ0bLAc7GHp4sGGembLKjoQrfnNXagUXWgywyaDXpoODtO4QYVJTiTqUKmXrTTKKH3vf9V14sYeh1MrpM8VPkaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqbRKkHDqdOgDKeIdJ0bLAc7GHp4sGGembLKjoQrfnNXagUXWg487ylslKBljz4qMgz2HkaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqbRuPMWoy4dUeiibtqjzIJAurZzmGHBmSbo)o2I0c52ssgoKPrMDOIiZenOTyaCL4Paaf)0dtjbLyIjYmrdAlgaxD8uaGIF6HPKGQcaP)Tg)IpZwhn9zJAsXcY)MesyPMWoy4dUeiibtqjzIJ6iPng2aNFhBrAHCBjjdhY0iZoubG0)wJNcau8tpmLeuTH)0XuOHt41LpoHbk4oOutyhm8bxceKGjOKmXrnjCmGtCymSbM(3AC2eLKjJd6w8ef2P6Kj6hxsM4Ogz2HkaK(3A8l(mBD00NnQjfli)BwQjSdg(GlbcsWe0mXb6muhnnj0bmg2at)BnoakNnDKoY)MQaq6FRXV4ZS1rtF2OMuSG8VPkaK(3A8l(mBD00NnQjfliprsb6Jxat)BnUzId0zOoAAsOdWjff1JtyGcciSdgoxsM4OMEkJJJkIS)H6dsIQiIOtMOF8ehHlodvjSdAa1OJKqC8ciKqIjwyh0aQrhjH44fcGqve9Q87ylslKljtCuthK0scqI(rmXNKw4XTrzE2Ct2zKoGaiSutyhm8bxceKGjOKmXrn9ugNXWgy6FRXbq5SPJ0r(3ufreDYe9JN4iCXzOkHDqdOgDKeIJxaHesmXc7Ggqn6ijehVqaeQIOxLFhBrAHCjzIJA6GKwsas0pIj(K0cpUnkZZMBYoJ0beaHLAc7GHp4sGGembhFtm9WGuQjSdg(GlbcsWeusM4OMwYuSqJHnW0)wJljtCuZSL0c5JtyGAeWejSdAa1OJKqC0HPeHQYVJTiTqUKmXrnDqsljaj6NQtsl842OmpBUj7EPdiGsnHDWWhCjqqcMGsYeh10sMIfAmSbM(3ACjzIJAMTKwiFCcduW0)wJljtCuZSL0c5KII6Xjmql1e2bdFWLabjyckjtCuhjTXWgy6FRXLKjoQz2sAH8XjmqbBuveXIyce9oxsM4O2m6XKNiPa9HruIaiM4xrelmGU4hh0UjuCv53XwKwixsM4O2wsYW7siHLAc7GHp4sGGembD8SXuFiPjooJHnWeLylXHTqprIj(vhKbk0Tiuf9V14sYeh1mBjTq(4egOGP)TgxsM4OMzlPfYjff1JtyGwQjSdg(GlbcsWeusM4OMeogWjomg2at)BnoBIsYKXbDlEIc7uLFhBrAHCjzIJABjjdVRkIi6Kj6hxinNWgKjhmCvc7Ggqn6ijehV0HiKyIf2bnGA0rsioEHaiSutyhm8bxceKGjOKmXrnjCmGtCymSbM(3AC2eLKjJd6w8ef2P6Kj6hxinNWgKjhmCvc7Ggqn6ijehVacl1e2bdFWLabjyckjtCuJkAoJbmCJHnW0)wJljtCuZSL0c5JtyG(c9V14sYeh1mBjTqoPOOECcd0snHDWWhCjqqcMGsYeh1OIMZyad3yydm9V14sYeh1mBjTq(4egOGP)TgxsM4OMzlPfYjff1JtyGQYmrdAlgaxjUKmXrnTKPyHLADQt1kSdg(GlbcsWeenem5GHBm0pmZV5PHnWKIlCt2zeWDicWyOFyMFZtdjjraOCiyLk1k16uNQvb24aRLjt2Fkhm8rT9yI1sggqGAH(f1E2yTcaq41ErTezhMy7pNDjSwOZsugyTyRbzq0zD5LADQt1kSdg(GZKj7pLdg(aSbjHc9en2fseSTya1Hj6iGXHj4bEgBqMFeSsgdBGnijuONi3wmG6WeDeaSrvzMObTfdGRehnem5GHR6veLFhBrAH8b00oC94IKKyIZVJTiTq(HKMrktDVKMewQ1PovRWoy4dotMS)uoy4dqcMGgKek0t0yxirW2IbuhMOJaghMGh4zSbz(rWkzmSb2GKqHEICBXaQdt0raWgvf9V14sYeh1MrpMCGO3vXIyce9oxsM4O2m6XKNiPa9HkIYVJTiTq(aAAhUECrssmX53XwKwi)qsZiLPUxstcl16uNQvyhm8bNjt2Fkhm8bibtqdscf6jASlKi4g0LPM(NUXHj4bEgBqMFeSsgdBGP)TgxsM4OMzlPfYhNWafm9V14sYeh1mBjTqoPOOECcduvVI(3A88prD00NDI4G)nv1Gw2Norsb6JxaterKIlkePWoy4CjzIJA6PmoolghHGac7GHZLKjoQPNY44OIi7FO(GKiHLADQt1QqdpBmRvQT9NZU1ooHbkcuRTKKH3T2iRf61IkIS)H1MIBH12dp7AvEqsljaj6xPwN6uTc7GHp4mzY(t5GHpajycAqsOqprJDHebJKMrpMiGMwYuSqJdtWd8m2Gm)iy6FRXLKjoQTLKm8U8XjmqncyLiaIjMO87ylslKljtCuthK0scqI(P6K0cpUnkZZMBYUx6acGWsTo1PAf2bdFWzYK9NYbdFasWe0GKqHEIg7cjcEkJtlM6)angaBYFEGnQXHj4bEgdBGP)TgxsM4O2m6XK)nvrKbjHc9e5tzCAXu)hiyJsmXhKencydscf6jYNY40IP(pqqQebqOXgK5hbFqsSuRtDQ2oozIJ1(AzaaT6wRf0aoQvQ1GKqHEI1kKX3VAJwTmG04AP)xT9475S2)aRvQTnLRwCCqs5GHxRnMiVwfyJ1oGKSAnZWaeabQnrsb6dnQOjYoeOwurZehdy41ce4OwpUA7Je0A7X5S2wK1AMba0QBTaFS2lQ9SXAP)546wRl3pXAJwTNnwldi5LADQt1kSdg(GZKj7pLdg(aKGjObjHc9en2fsemooiPCiGwm1SiMarVBCycEGNXgK5hbtelIjq07CjzIJAZOhtoWpLdgoiark1HrKr5gTdabyHd8HhxsM4O2mdaOvxEkoOesiHDyeDqsSdZGKqHEI8PmoTyQ)dKWsTo1PAf2bdFWzYK9NYbdFasWe0GKqHEIg7cjc(GKO(7hCQftJdtWd8mg2aZch4dpUKmXrTzgaqRUgBqMFemlIjq07CjzIJAZOhtEIKc0hAurtKDiqPwN6uTc7GHp4mzY(t5GHpajycAqsOqprJDHebFqsu)9do1IPXHj4bEgdBGFflCGp84sYeh1MzaaT6ASbz(rWSiMarVZLKjoQnJEm5jskqFuQ1PovRcp(EoRfaNs3A74xR2VzTxuR6m6az12ISwfexhTuRtDQwHDWWhCMmz)PCWWhGembnijuONOXUqIGpijQ)(bNAX04WemPOOXgK5hbZIyce9o)IpZwhn9zJAsXcYtKuG(WyydmrSiMarVZV4ZS1rtF2OMuSG8ejfOp6WmijuONi)GKO(7hCQftcFrDgTuRtDQ2hOZWAvO(0DRfoQD8z21k1Ag9y2(ZAVe6GIxTTiRvHi2nHIBCT9475S2XbzGw7f1E2yTxFulj0)hwlRlBI1(9doRThR1cVALATHw21IE8TSRnfh0AJwTMzaaT6wQ1PovRWoy4dotMS)uoy4dqcMGgKek0t0yxirWhKe1F)GtTyACycMuu0ydY8JGVe6GIhFe)5eVd6w68t3LZIyce9oprsb6dJHnWSWb(WJljtCuBMba0QRkw4aF4XLKjoQnZaaA1LNId6leGk81)HMMiaFe)5eVd6w68t3vflmGU4hh0UjuCv53XwKwixsM4O2wsYW7wQ1PovRcp(EoRfaNs3AvqCD0A)M1ErTQZOdKvBlYA74xRuRtDQwHDWWhCMmz)PCWWhGembnijuONOXUqIGTJja0T0xCKghMGh4zSbz(rWSiMarVZV4ZS1rtF2OMuSG8efGUQmijuONi)GKO(7hCQfZxuNrl16uNQvHsaGIF1(ykjO1ce4OwpUAHKKiauoC2TwZ)v73S2ZgR1WF6yk0Wj86wlas)BTAhrTWRwM41sJ1caBni7pVAVOwa4GHPx7zlxT947eRvUApBSwfoygNDTg(thtHgoHx3AhNWaTuRtDQwHDWWhCMmz)PCWWhGembnijuONOXUqIG7W)Jt)hiGEykjOghMGh4zSbz(rWezMObTfdGRepfaO4NEykjOetSzIg0wmaU64Paaf)0dtjbLyInt0G2IbW7aEkaqXp9WusqjuLWoy48uaGIF6HPKGYpijQhqNHVyXa4KIIGaGWsTo1PAviKqlOlZAFGKDUwMnYafbQfaP)TgpfaO4NEykjOAd)PJPqdNWRlhi6DJRL(F1E2YvlqGd)9vBFKGwBVn61E2yTcaq41kMMtioQvH6rHiSwOpoXVzxEPwN6uTc7GHp4mzY(t5GHpajycAqsOqprJDHeb3H)hN(pqa9WusqnombpWZydY8JGjYmrdAlgaxjEkaqXp9WusqjMyZenOTyaC1Xtbak(PhMsckXeBMObTfdG3b8uaGIF6HPKGsOkaK(3A8uaGIF6HPKGQn8NoMcnCcVUCGO3l16uNQvyhm8bNjt2Fkhm8bibtqdscf6jASlKi44FdiaQJMMfXei69HXHj4bEgBqMFem9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjhi6Dvai9V14x8z26OPpButkwqoq07QELbjHc9e5D4)XP)deqpmLeuvai9V14Paaf)0dtjbvB4pDmfA4eED5arVxQ1PovRWoy4dotMS)uoy4dqcMGgKek0t0yxirWJtyGQTLKm8UghMGh4zSbz(rW53XwKwixsM4O2wsYW7QIiIyHb0f)4G2nHIRIfXei6DEkaqXp9Wusq5jskqF8IbjHc9e52ssgEx94egO6dsIesyPwPwNQ91syKWdQWbR9pGUvTwjCm7wlKbztS2E4zxRyYRvHCG1cVA7HNDTxCK1gNnM9WbYl1e2bdFWzrmbIEFaULX40Eyqmg2aNFhBrAHCReoMD1qgKnrvSiMarVZLKjoQnJEm5jskqFyKoWOQyrmbIENFXNzRJM(SrnPyb5jkaDvre9V14sYeh1mBjTq(4egOVa2GKqHEI8losnPOOMzlPfourerNmr)453rD00MrpMQyrmbIENNFh1rtBg9yYtKuG(4fWwmavSiMarVZLKjoQnJEm5jskqFyedscf6jYV4i1KIIAaCkD1Ti1IjHetmrV6Kj6hp)oQJM2m6XuflIjq07CjzIJAZOhtEIKc0hgXGKqHEI8losnPOOgaNsxDlsTysiXeZIyce9oxsM4O2m6XKNiPa9XlGTyaesyPMWoy4dolIjq07dqcMGTmgN2ddIXWg487ylslKBLWXSRgYGSjQIfXei6DUKmXrTz0JjprbORkIE1jt0po6tOL9HocqmXeDYe9JJ(eAzFOJaQifx4MSZiGFDgLqcvrerSiMarVZV4ZS1rtF2OMuSG8ejfOpmIsgvf9V14sYeh1mBjTq(4egOGP)TgxsM4OMzlPfYjff1JtyGsiXetelIjq078l(mBD00NnQjfliprsb6dWgvf9V14sYeh1mBjTq(4egOGnkHeQI(3A887OoAAZOhtoq07Qifx4MSZiGnijuONixm1Kqhs(j1KIlAt2vQjSdg(GZIyce9(aKGjylJXrhZZyydC(DSfPfYbGdg0CcDj7QzbjP4aQyrmbIENt)BnnaCWGMtOlzxnlijfhGNOa0vf9V14aWbdAoHUKD1SGKuCaDlJXXbIExfr0)wJljtCuBg9yYbIExf9V1453rD00MrpMCGO3vbG0)wJFXNzRJM(SrnPyb5arVtOkwetGO35x8z26OPpButkwqEIKc0hGnQkIO)TgxsM4OMzlPfYhNWa9fWgKek0tKFXrQjff1mBjTWHkIi6Kj6hp)oQJM2m6XuflIjq07887OoAAZOhtEIKc0hVa2IbOIfXei6DUKmXrTz0Jjprsb6dJyqsOqpr(fhPMuuudGtPRUfPwmjKyIj6vNmr)453rD00MrpMQyrmbIENljtCuBg9yYtKuG(WigKek0tKFXrQjff1a4u6QBrQftcjMywetGO35sYeh1MrpM8ejfOpEbSfdGqcl1e2bdFWzrmbIEFasWeSbtutpLXzmSbo)o2I0c5aWbdAoHUKD1SGKuCavSiMarVZP)TMgaoyqZj0LSRMfKKIdWtua6QI(3ACa4GbnNqxYUAwqskoGUbtKde9UkZenOTyaCL4TmghDmVsTov7RjWS2oAOGA7HNDTD8RvlSvl8EpQLfKq3Q2VzTJiCETGGTAHxT9W5SwAS2)abQThE21QG46OgxltgxTWR2XeAzFZU1sJTiXsnHDWWhCwetGO3hGembjHzg5qhn9fjj6NXWgyIEv(DSfPfYhqt7W1JlssIjM(3A8b00oC94IKK)njuflIjq078l(mBD00NnQjfliprsb6JxmijuONiNmoTzImeb0xCKA6UetmrgKek0tKFqsu)9do1IPrmijuONiNmonPOOgaNsxDlsTyQIfXei6D(fFMToA6Zg1KIfKNiPa9HrmijuONiNmonPOOgaNsxDls9fhjHLAc7GHp4SiMarVpajycscZmYHoA6lss0pJHnWSiMarVZLKjoQnJEm5jkaDvr0RozI(XrFcTSp0raIjMOtMOFC0Nql7dDeqfP4c3KDgb8RZOesOkIiIfXei6D(fFMToA6Zg1KIfKNiPa9HrmijuONixm1KIIAaCkD1Ti1xCKQO)TgxsM4OMzlPfYhNWafm9V14sYeh1mBjTqoPOOECcducjMyIyrmbIENFXNzRJM(SrnPyb5jskqFa2OQO)TgxsM4OMzlPfYhNWafSrjKqv0)wJNFh1rtBg9yYbIExfP4c3KDgbSbjHc9e5IPMe6qYpPMuCrBYUsnHDWWhCwetGO3hGembBtCyZsPDgdBGnijuONip(3acG6OPzrmbIEFOIOr8N0qhGBiMYbNOEetdOFet8i(tAOdWn)J7prnMFZdgoHLADQ2oE2lDh1(hyTaOC20r6yT9WZUwXKxliyR2loYAHJAtua6wRmQThNtJRLuafRD8tS2lQLjJRw4vln2IeR9IJKxQjSdg(GZIyce9(aKGjiakNnDKoAmSbMfXei6D(fFMToA6Zg1KIfKNOa0vf9V14sYeh1mBjTq(4egOVa2GKqHEI8losnPOOMzlPfouXIyce9oxsM4O2m6XKNiPa9XlGTyaLAc7GHp4SiMarVpajyccGYzthPJgdBGzrmbIENljtCuBg9yYtua6QIOxDYe9JJ(eAzFOJaetmrNmr)4OpHw2h6iGksXfUj7mc4xNrjKqverelIjq078l(mBD00NnQjfliprsb6dJOKrvr)BnUKmXrnZwslKpoHbky6FRXLKjoQz2sAHCsrr94egOesmXeXIyce9o)IpZwhn9zJAsXcYtua6QI(3ACjzIJAMTKwiFCcduWgLqcvr)BnE(DuhnTz0Jjhi6DvKIlCt2zeWgKek0tKlMAsOdj)KAsXfTj7k16uTkKdS2HPKGwlSv7fhzTIduRywRKyTHxldOwXbQTp83xT0yTFZABrw7mClmR9SfV2ZgRLuuSwaCkDnUwsbuOBv74NyT9yT2IbSw5QDIY4Q96JALKjowlZwslCuR4a1E2Yv7fhzT9YWFF12H)hxT)bcWl1e2bdFWzrmbIEFasWemfaO4NEykjOgdBGzrmbIENFXNzRJM(SrnPyb5jskqFyedscf6jYZHMuuudGtPRUfP(IJuflIjq07CjzIJAZOhtEIKc0hgXGKqHEI8COjff1a4u6QBrQftveDYe9JNFh1rtBg9yQIiwetGO3553rD00MrpM8ejfOpEbvez)d1hKejMywetGO3553rD00MrpM8ejfOpmIbjHc9e55qtkkQbWP0v3IuNHjHet8RozI(XZVJ6OPnJEmjuf9V14sYeh1mBjTq(4egOgrDQaq6FRXV4ZS1rtF2OMuSGCGO3vr)BnE(DuhnTz0Jjhi6Dv0)wJljtCuBg9yYbIEVuRt1QqoWAhMscAT9WZUwXS2EB0R1mgdi9e51cc2Q9IJSw4O2efGU1kJA7X504AjfqXAh)eR9IAzY4QfE1sJTiXAV4i5LAc7GHp4SiMarVpajycMcau8tpmLeuJHnWSiMarVZV4ZS1rtF2OMuSG8ejfOpEbvez)d1hKevr)BnUKmXrnZwslKpoHb6lGnijuONi)IJutkkQz2sAHdvSiMarVZLKjoQnJEm5jskqF8crOIi7FO(GKiif2bdNFXNzRJM(SrnPyb5OIi7FO(GKiHLAc7GHp4SiMarVpajycMcau8tpmLeuJHnWSiMarVZLKjoQnJEm5jskqF8cQiY(hQpijQIiIE1jt0po6tOL9HocqmXeDYe9JJ(eAzFOJaQifx4MSZiGFDgLqcvrerSiMarVZV4ZS1rtF2OMuSG8ejfOpmIbjHc9e5IPMuuudGtPRUfP(IJuf9V14sYeh1mBjTq(4egOGP)TgxsM4OMzlPfYjff1JtyGsiXetelIjq078l(mBD00NnQjfliprsb6dWgvf9V14sYeh1mBjTq(4egOGnkHeQI(3A887OoAAZOhtoq07Qifx4MSZiGnijuONixm1Kqhs(j1KIlAt2ryPMWoy4dolIjq07dqcMG)bQHhsASlKi4r8Nt8oOBPZpDxJHnWe9Q87ylslKpGM2HRhxKKetm9V14dOPD46Xfjj)BsOk6FRXLKjoQz2sAH8XjmqFbSbjHc9e5xCKAsrrnZwslCOIfXei6DUKmXrTz0Jjprsb6JxaJkIS)H6dsIQifx4MSZigKek0tKlMAsOdj)KAsXfTj7ur)BnE(DuhnTz0Jjhi69sTovRc5aR9IJS2E4zxRywlSvl8EpQThE2qV2ZgRLuuSwaCkD51cc2Q1JZ4A)dS2E4zxBgM1cB1E2yTNmr)QfoQ9eqr34AfhOw49EuBp8SHETNnwlPOyTa4u6Yl1e2bdFWzrmbIEFasWe8IpZwhn9zJAsXcAmSbMOxLFhBrAH8b00oC94IKKyIP)TgFanTdxpUij5Ftcvr)BnUKmXrnZwslKpoHb6lGnijuONi)IJutkkQz2sAHdvSiMarVZLKjoQnJEm5jskqF8cyurK9puFqsufP4c3KDgXGKqHEICXutcDi5NutkUOnzNk6FRXZVJ6OPnJEm5arVxQjSdg(GZIyce9(aKGj4fFMToA6Zg1KIf0yydm9V14sYeh1mBjTq(4egOVa2GKqHEI8losnPOOMzlPfouDYe9JNFh1rtBg9yQIfXei6DE(DuhnTz0Jjprsb6JxaJkIS)H6dsIQmijuONi)GKO(7hCQftJyqsOqpr(fhPMuuudGtPRUfPwml1e2bdFWzrmbIEFasWe8IpZwhn9zJAsXcAmSbM(3ACjzIJAMTKwiFCcd0xaBqsOqpr(fhPMuuuZSL0chQi6vNmr)453rD00MrpMetmlIjq07887OoAAZOhtEIKc0hgXGKqHEI8losnPOOgaNsxDlsDgMeQYGKqHEI8dsI6VFWPwmnIbjHc9e5xCKAsrrnaoLU6wKAXSuRt1QqoWAfZAHTAV4iRfoQn8Aza1koqT9H)(QLgR9BwBlYANHBHzTNT41E2yTKII1cGtPRX1skGcDRAh)eR9SLR2ESwBXawl6X3YUwsXLAfhO2ZwUApBmXAHJA94QvMjkaDRvQn)owB0Q1m6XSwGO35LAc7GHp4SiMarVpajyckjtCuBg9yAmSbMfXei6D(fFMToA6Zg1KIfKNiPa9HrmijuONixm1KIIAaCkD1Ti1xCKQi6vSWa6IFCdOF2DtIjMfXei6DojmZih6OPVijr)4jskqFyedscf6jYftnPOOgaNsxDlsnzCeQI(3ACjzIJAMTKwiFCcduW0)wJljtCuZSL0c5KII6Xjmqvr)BnE(DuhnTz0Jjhi6DvKIlCt2zeWgKek0tKlMAsOdj)KAsXfTj7k16uTkKdS2mmRf2Q9IJSw4O2WRLbuR4a12h(7RwAS2VzTTiRDgUfM1E2Ix7zJ1skkwlaoLUgxlPak0TQD8tS2ZgtSw4WFF1kZefGU1k1MFhRfi69AfhO2ZwUAfZA7d)9vlnYcsSwXGaNc9eRf4Nq3Q287iVutyhm8bNfXei69bibtW87OoAAZOhtJHnW0)wJljtCuBg9yYbIExfrSiMarVZV4ZS1rtF2OMuSG8ejfOpmIbjHc9e5zyQjff1a4u6QBrQV4ijMywetGO35sYeh1MrpM8ejfOpEbSbjHc9e5xCKAsrrnaoLU6wKAXKqv0)wJljtCuZSL0c5JtyGcM(3ACjzIJAMTKwiNuuupoHbQkwetGO35sYeh1MrpM8ejfOpmIsgvflIjq078l(mBD00NnQjfliprsb6dJOKrl1e2bdFWzrmbIEFasWeCydBh0T0MrpMgdBGnijuONip(3acG6OPzrmbIEFuQ1PAvihyTMbzTxu741)ruHdwR41IkEPuRqxl0R9SXADuXRwwetGO3RTh6arVX1(9jog1cA3ekETNn61g(SBTa)e6w1kjtCSwZOhZAb(yTxuRD0xlP4sT2F3k7wBkaqXVAhMscATWrPMWoy4dolIjq07dqcMGMjoqNH6OPjHoGXWg4tMOF887OoAAZOhtv0)wJljtCuBg9yY)MQO)Tgp)oQJM2m6XKNiPa9XlwmaoPOyPMWoy4dolIjq07dqcMGMjoqNH6OPjHoGXWgyaK(3A8l(mBD00NnQjfli)BQcaP)Tg)IpZwhn9zJAsXcYtKuG(4fHDWW5sYeh1KWXaoXbhvez)d1hKev9kwyaDXpoODtO4LAc7GHp4SiMarVpajycAM4aDgQJMMe6agdBGP)Tgp)oQJM2m6XK)nvr)BnE(DuhnTz0Jjprsb6JxSyaCsrrvSiMarVZrdbtoy48efGUQyrmbIENFXNzRJM(SrnPyb5jskqFO6vSWa6IFCq7MqXl1k1e2bdFWBqxMA6F6GLKjoQjHJbCIdJHnW0)wJZMOKmzCq3INOWoJz2c0bRuPMWoy4dEd6Yut)thKGjOKmXrn9ugxPMWoy4dEd6Yut)thKGjOKmXrnTKPyHLALADQwfEB0Rn)UdDRAr4zJzTNnw7ZtTrwRcu4RDIwOdijehgxBpwBV4xTxuRcTHOwASfjw7zJ1QG46OeSJFTA7Hoq0ZRvHCG1cVALrTJi8ALrTkuXRvRTmQTbD4WgbQn(zT94BdyTdt0VAJFwlZwslCuQjSdg(G3GdBOBPdt0XemAiyYbd3yydmr53XwKwi)qsZiLPUxstIjMO87ylslKpGM2HRhxKKQELbjHc9e5MjA(NtnAiaReHeQIi6FRXZVJ6OPnJEm5arVtmXMjAqBXa4kXLKjoQPLmflKqvSiMarVZZVJ6OPnJEm5jskqFuQ1PAbbB12JVnG12GoCyJa1g)SwwetGO3RTh6ar)OwXbQDyI(vB8ZAz2sAHdJR1mHrcpOchSwfAdrTHbmRfnGz3Zg6w1IZbwQjSdg(G3GdBOBPdt0XeKGjiAiyYbd3yyd8jt0pE(DuhnTz0JPkwetGO3553rD00MrpM8ejfOpuXIyce9oxsM4O2m6XKNiPa9Hk6FRXLKjoQnJEm5arVRI(3A887OoAAZOhtoq07Qmt0G2IbWvIljtCutlzkwyPMWoy4dEdoSHULomrhtqcMGnyIA6PmoJHnW53XwKwihaoyqZj0LSRMfKKIdOI(3ACa4GbnNqxYUAwqskoGULX44FZsnHDWWh8gCydDlDyIoMGembBzmoThgeJHnW53XwKwi3kHJzxnKbztufP4c3KDgPJqaLAc7GHp4n4Wg6w6WeDmbjyckjtCutchd4ehgdBGZVJTiTqUKmXrTTKKH3vf9V14sYeh12ssgEx(4egOVq)BnUKmXrTTKKH3LtkkQhNWavfrer)BnUKmXrTz0Jjhi6DvSiMarVZLKjoQnJEm5jkaDjKyIbq6FRXV4ZS1rtF2OMuSG8VjHgZSfOdwPsnHDWWh8gCydDlDyIoMGembZVJ6OPnJEmng2aNFhBrAH8b00oC94IKSutyhm8bVbh2q3shMOJjibtqjzIJ6iPng2aZIyce9op)oQJM2m6XKNOa0Tutyhm8bVbh2q3shMOJjibtqjzIJA6PmoJHnWSiMarVZZVJ6OPnJEm5jkaDvr)BnUKmXrnZwslKpoHb6l0)wJljtCuZSL0c5KII6Xjmql1e2bdFWBWHn0T0Hj6ycsWeeaLZMoshng2a)Q87ylslKFiPzKYu3lPjXeZch4dpUfSD6OPpBupHm7snHDWWh8gCydDlDyIoMGembZVJ6OPnJEml16uTGGTA7X3jwRC1skkw74egOJAJwTDUZ1koqT9yT2Ib0FF1(hiqTD0qb12fpJR9pWALAhNWaT2lQ1mrdOF1s(DMn0TQ97tCmQn)UdDRApBSwfILKm8U1orl0bKSBPMWoy4dEdoSHULomrhtqcMGsYeh1KWXaoXHXWgy6FRXztusMmoOBXtuyNk6FRXztusMmoOBXhNWafm9V14Sjkjtgh0T4KII6XjmqvXcdOl(XnG(z3nvXIyce9oNeMzKdD00xKKOF8efGUQELbjHc9e5iPz0JjcOPLmfluflIjq07CjzIJAZOhtEIcq3sTovR6JKuMZU12J1AkWSwZ4GHx7FG12dp7A74xZ4AP)xTWR2E4Cw7ugxTZWTQf94BzxBlYAPJZU2ZgRvHkETAfhO2o(1QTh6ar)O2VpXXO287o0TQ9SXAFEQnYAvGcFTt0cDajH4Outyhm8bVbh2q3shMOJjibtqZ4GHBmSb(v53XwKwi)qsZiLPUxstve9Q87ylslKpGM2HRhxKKetmrgKek0tKBMO5Fo1OHaSsQO)TgxsM4OMzlPfYhNWafm9V14sYeh1mBjTqoPOOECcducjSutyhm8bVbh2q3shMOJjibtqauoB6iD0yydm9V1453rD00MrpMCGO3jMyZenOTyaCL4sYeh10sMIfwQjSdg(G3GdBOBPdt0XeKGjykaqXp9Wusqng2at)BnE(DuhnTz0Jjhi6DIj2mrdAlgaxjUKmXrnTKPyHLAc7GHp4n4Wg6w6WeDmbjycscZmYHoA6lss0pJHnW0)wJNFh1rtBg9yYtKuG(4fIuyGuDGa53XwKwiFanTdxpUijjSuRt1QWBJET53DOBv7zJ1QqSKKH3T2jAHoGKDnU2)aRTJFTAPXwKyTkiUoATxulWN0SwP22Fo7w74egOiqT0sMIfwQjSdg(G3GdBOBPdt0XeKGjOKmXrTz0JPXWgydscf6jYrsZOhteqtlzkwOk6FRXZVJ6OPnJEm5FtverkUWnz3lePocaKePKrbbyHb0f)4G2nHItiHetm9V14Sjkjtgh0T4JtyGcM(3AC2eLKjJd6wCsrr94egOewQjSdg(G3GdBOBPdt0XeKGjOKmXrnTKPyHgdBGnijuONihjnJEmranTKPyHQO)TgxsM4OMzlPfYhNWafm9V14sYeh1mBjTqoPOOECcduv0)wJljtCuBg9yY)MLAc7GHp4n4Wg6w6WeDmbjyc(hOgEiPXUqIGhXFoX7GULo)0Dng2at)BnE(DuhnTz0Jjhi6DIj2mrdAlgaxjUKmXrnTKPyHetSzIg0wmaUs8uaGIF6HPKGsmXezMObTfdGRehaLZMoshv9Q87ylslKpGM2HRhxKKewQjSdg(G3GdBOBPdt0XeKGj4fFMToA6Zg1KIf0yydm9V1453rD00MrpMCGO3jMyZenOTyaCL4sYeh10sMIfsmXMjAqBXa4kXtbak(PhMsckXetKzIg0wmaUsCauoB6iDu1RYVJTiTq(aAAhUECrssyPMWoy4dEdoSHULomrhtqcMGsYeh1MrpMgdBGnt0G2IbWvIFXNzRJM(SrnPybl16uTkKdS2xl6O1ErTJx)hrfoyTIxlQ4LsTDCYehRv5tzC1c8tOBv7zJ1QG46OeSJFTA7Hoq0x73N4yuB(Dh6w12XjtCSwfAMDWRfeSvBhNmXXAvOz2rTWrTNmr)qaJRThRLj(7R2)aR91IoAT9WZg61E2yTkiUokb74xR2EOde91(9jog12J1c9dZ8BE1E2yTDChTwMT4oonU2ruBp(EoRDigWAHhVutyhm8bVbh2q3shMOJjibtqZehOZqD00KqhWyyd8RozI(XLKjoQrMDOcaP)Tg)IpZwhn9zJAsXcY)MQaq6FRXV4ZS1rtF2OMuSG8ejfOpEbmrc7GHZLKjoQPNY44OIi7FO(GKiia9V14MjoqNH6OPjHoaNuuupoHbkHLADQwqWwTVw0rR1wg(7RwAe9A)deOwGFcDRApBSwfexhT2EOde9gxBp(EoR9pWAHxTxu741)ruHdwR41IkEPuBhNmXXAv(ugxTqV2ZgRvHkEnc2XVwT9qhi65LAc7GHp4n4Wg6w6WeDmbjycAM4aDgQJMMe6agdBGP)TgxsM4O2m6XK)nvr)BnE(DuhnTz0Jjprsb6JxatKWoy4CjzIJA6PmooQiY(hQpijccq)BnUzId0zOoAAsOdWjff1JtyGsyPMWoy4dEdoSHULomrhtqcMGsYeh10tzCgdBGbIJNcau8tpmLeuEIKc0hgHaiMyaK(3A8uaGIF6HPKGQn8NoMcnCcVU8XjmqnIrl16uTk8yT9IF1ErTKcOyTJFI12J1AlgWArp(w21skUuBlYApBSw0pyI12XVwT9qhi6nUw0a61cB1E2yIVh1oo4Cw7bjXAtKuGo0TQn8AvOIxJxli49EuB4ZU1sJ3HzTxul9p9AVOwfoyg1koqTk0gIAHTAZV7q3Q2ZgR95P2iRvbk81orl0bKeIdEPMWoy4dEdoSHULomrhtqcMGsYeh10sMIfAmSbMfXei6DUKmXrTz0JjprbORksXfUj7EHiqOrbjrkzuqawyaDXpoODtO4esOk6FRXLKjoQz2sAH8Xjmqbt)BnUKmXrnZwslKtkkQhNWavfrVk)o2I0c5dOPD46XfjjXeBqsOqprUzIM)5uJgcWkrOQxLFhBrAH8djnJuM6Ejnv9Q87ylslKljtCuBljz4Dl16uTkxYuSWAh2XFcuRhxT0yT)bcuRC1E2yTOduB0QTJFTAHTAvOnem5GHxlCuBIcq3ALrTazyAcDRAz2sAHJA7HZzTKcOyTWR2tafRDgUfM1ErT0)0R9SZ4BzxBIKc0HUvTKIlLAc7GHp4n4Wg6w6WeDmbjyckjtCutlzkwOXWgy6FRXLKjoQnJEm5Ftv0)wJljtCuBg9yYtKuG(4fWwmavSiMarVZrdbtoy48ejfOpk16uTkxYuSWAh2XFcuRm7LUJAPXApBS2PmUAzY4Qf61E2yTkuXRvBp0bI(ALrTkiUoAT9W5S2ehxKyTNnwlZwslCu7We9Rutyhm8bVbh2q3shMOJjibtqjzIJAAjtXcng2at)BnE(DuhnTz0Jj)BQI(3ACjzIJAZOhtoq07QO)Tgp)oQJM2m6XKNiPa9XlGTyaQEv(DSfPfYLKjoQTLKm8ULAc7GHp4n4Wg6w6WeDmbjyckjtCutchd4ehgdBGbq6FRXV4ZS1rtF2OMuSG8VPQtMOFCjzIJAKzhQiI(3ACauoB6iDKde9oXelSdAa1OJKqCawjcvbG0)wJFXNzRJM(SrnPyb5jskqFyeHDWW5sYeh1KWXaoXbhvez)d1hKenMzlqhSsgJso7Qz2c01Wgy6FRXztusMmoOBPz2I74Kde9UkIO)TgxsM4O2m6XK)njMyIE1jt0pEyatZOhteqfr0)wJNFh1rtBg9yY)MetmlIjq07C0qWKdgoprbOlHesyPwNQfeSvBp(oXAnG(z3nnUwijjcaLdNDR9pWA7CNRT3g9AzIPjcu7f16XvBVmoSwZmyJABzqwBhnuqPMWoy4dEdoSHULomrhtqcMGsYeh1KWXaoXHXWgywyaDXpUb0p7UPk6FRXztusMmoOBXhNWafm9V14Sjkjtgh0T4KII6Xjmql16uTpNKxT)b0TQTZDU2oUJwBVn612XVwT2YOwAe9A)deOutyhm8bVbh2q3shMOJjibtqjzIJAs4yaN4Wyydm9V14Sjkjtgh0T4jkStflIjq07CjzIJAZOhtEIKc0hQiI(3A887OoAAZOht(3KyIP)TgxsM4O2m6XK)nj0yMTaDWkvQjSdg(G3GdBOBPdt0XeKGjOKmXrDK0gdBGP)TgxsM4OMzlPfYhNWa9fWgKek0tKFXrQjff1mBjTWrPMWoy4dEdoSHULomrhtqcMGsYeh10tzCgdBGP)Tgp)oQJM2m6XK)njMysXfUj7mIseqPMWoy4dEdoSHULomrhtqcMGOHGjhmCJHnW0)wJNFh1rtBg9yYbIExf9V14sYeh1MrpMCGO3ng6hM5380WgysXfUj7mc4oebym0pmZV5PHKKiauoeSsLAc7GHp4n4Wg6w6WeDmbjyckjtCutlzkwyPwPwN6uTkK(4BAg5Ha1YeNHtTWoy4keb1QqBiyYbdV2E4CwlnwRl3pL5SBT0zak61cB1YchaEWWh1kjwljE8sTo1PAf2bdFWTLKm8UGzIZWPwyhmCJHnWc7GHZrdbtoy4CMT4ooHULksXfUj7mc4ocbuQ1PAbbB1oJ(AdVwsXLAfhOwwetGO3h1kjwlliHUvTFtJR1kQvSrbOwXbQfneLAc7GHp42ssgExqcMGOHGjhmCJHnWKIlCt29c4oWOQmijuONip(3acG6OPzrmbIEFOIOtMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jskqF8IsgLWsTovRcpwBV4xTxu74egO1Aljz4DRT9NZU8AvGnw7FG1gTAvsHv74egOJATXeRfoQ9IAfgl((vBlYApBS2dYaT2j2UAdV2ZgRLzlUJZAfhO2ZgRLeogWjwl0RTnHw2hVutyhm8b3wsYW7csWeusM4OMeogWjomg2atKbjHc9e5JtyGQTLKm8Uet8bjXxuYOeQI(3ACjzIJABjjdVlFCcd0xusHzmZwGoyLk16uTk82Ox7FaDRAvOjn7MOmRvHqc4IZqJRLjJRwP2g2xlQ4LsTKWXaoXrT92WjwBVapOBvBlYApBSw6FRvRC1E2yTJtYR2Ov7zJ12Gw2xPMWoy4dUTKKH3fKGjOKmXrnjCmGtCymSbgF9FOPjcWrsZUjktDKaU4mu1bjXx6aJQIfXei6DosA2nrzQJeWfNH8ejfOpmIskSoKQxjSdgohjn7MOm1rc4IZqoaCi0teOutyhm8b3wsYW7csWe8pqn8qsJDHebpI)CI3bDlD(P7AmSbM(3ACjzIJAZOht(3u1jPfECa44eNHVawjJwQjSdg(GBljz4Dbjyc(hOgEiPXUqIGhXFoX7GULo)0Dng2aBqsOqprosAg9yIaAAjtXcvXIyce9o)IpZwhn9zJAsXcYtKuG(4fWOIi7FO(GKOkwetGO35sYeh1MrpM8ejfOpEbmrOIi7FO(GKiiG6iu1jPfECa44eNHgrjJwQjSdg(GBljz4DbjycMcau8tpmLeuJHnWgKek0tKJKMrpMiGMwYuSqvSiMarVZV4ZS1rtF2OMuSG8ejfOpEbmQiY(hQpijQIfXei6DUKmXrTz0Jjprsb6JxateQiY(hQpijccOocvr0RWx)hAAIa8r8Nt8oOBPZpDxIjMfoWhECjzIJAZmaGwD5P4GAeWeaXet0Lqhu84J4pN4Dq3sNF6UCwetGO35jskqFyeLuYOQojTWJdahN4m0ikzucjMyIUe6GIhFe)5eVd6w68t3LZIyce9oprsb6JxaJkIS)H6dsIQojTWJdahN4m8fWkzucjSutyhm8b3wsYW7csWe8IpZwhn9zJAsXcAmSb2GKqHEI8o8)40)bcOhMscQkwetGO35sYeh1MrpM8ejfOpEbmQiY(hQpijQIOxHV(p00eb4J4pN4Dq3sNF6UetmlCGp84sYeh1MzaaT6YtXb1iGjaIjMOlHoO4XhXFoX7GULo)0D5SiMarVZtKuG(WikPKrvDsAHhhaooXzOruYOesmXeDj0bfp(i(ZjEh0T05NUlNfXei6DEIKc0hVagvez)d1hKevDsAHhhaooXz4lGvYOesyPMWoy4dUTKKH3fKGjOKmXrTz0JPXWgyZenOTyaCL4x8z26OPpButkwWsnHDWWhCBjjdVlibtW87OoAAZOhtJHnWgKek0tKJKMrpMiGMwYuSqvSiMarVZtbak(PhMsckprsb6JxaJkIS)H6dsIQmijuONi)GKO(7hCQftJawDgvfrVIfoWhECjzIJAZmaGwDjM4xzqsOqprUm7LUd9ORZ0SiMarVpiMywetGO35x8z26OPpButkwqEIKc0hVaMiurK9puFqseeqDesyPMWoy4dUTKKH3fKGjykaqXp9Wusqng2aBqsOqprosAg9yIaAAjtXcvzMObTfdGRep)oQJM2m6XSutyhm8b3wsYW7csWe8IpZwhn9zJAsXcAmSb2GKqHEI8o8)40)bcOhMscQQxzqsOqprUDmbGUL(IJSuRt1QqoWAvNduRKmXXAPLmflSwOxBh)AGuHsHWRvB4ZU1cB1Q8zeaZ)4QvCGALR2jkJRw1vBN78OwZmymeOutyhm8b3wsYW7csWeusM4OMwYuSqJHnW0)wJljtCuZSL0c5JtyGcM(3ACjzIJAMTKwiNuuupoHbQk6FRXZVJ6OPnJEm5Ftv0)wJljtCuBg9yY)MQO)TgxsM4O2wsYW7YhNWa1iGvsHPI(3ACjzIJAZOhtEIKc0hVawyhmCUKmXrnTKPyHCurK9puFqsuf9V140ZiaM)XX)MLADQwfYbwR6CGAvOIxRwOxBh)A1g(SBTWwTkFgbW8pUAfhOw1vBN78OwZmyLAc7GHp42ssgExqcMG53rD00MrpMgdBGP)Tgp)oQJM2m6XKde9Uk6FRXPNram)JJ)nvrKbjHc9e5hKe1F)GtTyAKoWOetmlIjq078uaGIF6HPKGYtKuG(WikPocvre9V14sYeh12ssgEx(4egOgbSseaXet)BnoBIsYKXbDl(4egOgbSseQIOxXch4dpUKmXrTzgaqRUet8RmijuONixM9s3HE01zAwetGO3hewQjSdg(GBljz4DbjycMFh1rtBg9yAmSbM(3ACjzIJAZOhtoq07QiYGKqHEI8dsI6VFWPwmnshyuIjMfXei6DEkaqXp9Wusq5jskqFyeLuhHQi6vSWb(WJljtCuBMba0QlXe)kdscf6jYLzV0DOhDDMMfXei69bHLAc7GHp42ssgExqcMGPaaf)0dtjb1yydSbjHc9e5iPz0JjcOPLmflufr0)wJljtCuZSL0c5JtyGAeWQJyIzrmbIENljtCuhjnprbOlHQi6vNmr)453rD00MrpMetmlIjq07887OoAAZOhtEIKc0hgHaiuflIjq07CjzIJAZOhtEIKc0hAurtKDiGra3bgvfrVIfoWhECjzIJAZmaGwDjM4xzqsOqprUm7LUd9ORZ0SiMarVpiSuRt1QWBJET53DOBvRzgaqRUgx7FG1EXrwlD3AH3aNTAHETrcGzTxuRmHwETWR2E4zxRywQjSdg(GBljz4DbjycEXNzRJM(SrnPybng2aBqsOqpr(bjr93p4ulMVqagvLbjHc9e5hKe1F)GtTyAKoWOQi6v4R)dnnra(i(ZjEh0T05NUlXeZch4dpUKmXrTzgaqRU8uCqncycGWsnHDWWhCBjjdVlibtqjzIJ6iPng2aBqsOqprEh(FC6)ab0dtjbvf9V14sYeh1mBjTq(4egOVq)BnUKmXrnZwslKtkkQhNWaTuRtDQwfEB0R9pGUvTkeljz4qwTk0m7W4A7g)AbIA94QTx8R2lQ91)XpwBhNmXXAvUKPyH1c8tOBv7zJ12XjtCSwLpLXvltgxPwN6uTc7GHp42ssgExqcMG9c8mEGmWgLBuqOXWgyaK(3A8uaGIF6HPKGQn8NoMcnCcVU8Xjmqbteas)BnEkaqXp9Wusq1g(thtHgoHxxoPOOECcd0omLiuv(DSfPfYTLKmCitJm7W4j0rndaS6iGsnHDWWhCBjjdVlibtqjzIJAAjtXcng2adG0)wJNcau8tpmLeuTH)0XuOHt41LpoHbkyaK(3A8uaGIF6HPKGQn8NoMcnCcVUCsrr94egOLAc7GHp42ssgExqcMGsYeh10tzCgdBGnijuONiVd)po9FGa6HPKGsmXebG0)wJNcau8tpmLeuTH)0XuOHt41L)nvbG0)wJNcau8tpmLeuTH)0XuOHt41LpoHb6lai9V14Paaf)0dtjbvB4pDmfA4eED5KII6XjmqjSuRt1QqoWAjHoSwLlzkwyT041JOxBkaqXVAhMsc6OwyR2VdGzTkheRThE2X)QfaNsxOBvRcLaaf)Q9XusqRfcGYC2Tutyhm8b3wsYW7csWeusM4OMwYuSqJHnW0)wJNFh1rtBg9yY)MQO)TgxsM4O2m6XKde9Uk6FRXPNram)JJ)nvXIyce9opfaO4NEykjO8ejfOpEbSsgvf9V14sYeh12ssgEx(4egOgbSskSsTovRc5aRns6AdVwgqTFFIJrTIzTWrTSGe6w1(nRDeHxQjSdg(GBljz4DbjyckjtCuhjTXWgy6FRXLKjoQz2sAH8XjmqFPduzqsOqpr(bjr93p4ulMgrjJQIiwetGO35x8z26OPpButkwqEIKc0hgHaiM4xXch4dpUKmXrTzgaqRUewQjSdg(GBljz4DbjyckjtCutchd4ehgdBGP)TgNnrjzY4GUfprHDQO)TgxsM4O2m6XK)nnMzlqhSsLADQwqWwT9yTw4vRz0JzTqV9hWWRf4Nq3Q25FC12JVNZATfdyTOhFl7ATLXH1ErTw4vB0A1k1oUmCRAPLmflSwGFcDRApBS2mmjOywBp0bI(snHDWWhCBjjdVlibtqjzIJAAjtXcng2at)BnE(DuhnTz0Jj)BQI(3A887OoAAZOhtEIKc0hVawyhmCUKmXrnjCmGtCWrfr2)q9bjrv0)wJljtCuBg9yY)MQO)TgxsM4OMzlPfYhNWafm9V14sYeh1mBjTqoPOOECcduv0)wJljtCuBljz4D5JtyGQI(3ACZOhtn0B)bmC(3uf9V140ZiaM)XX)MLADQwqWwT9yTw4vRz0JzTqV9hWWRf4Nq3Q25FC12JVNZATfdyTOhFl7ATLXH1ErTw4vB0A1k1oUmCRAPLmflSwGFcDRApBS2mmjOywBp0bIEJRDe12JVNZAdF2T2)aRf94Bzxl9ug3OwOdpOmNDR9IATWR2lQTf)SwMTKw4Outyhm8b3wsYW7csWeusM4OMEkJZyydm9V14MjoqNH6OPjHoa)BQIi6FRXLKjoQz2sAH8XjmqFH(3ACjzIJAMTKwiNuuupoHbkXe)kIO)Tg3m6Xud92FadN)nvr)Bno9mcG5FC8VjHewQ1PAvGnwlnoUA)dS2OvRzqwlCu7f1(hyTWR2lQ91)HmqNDRL(dNa1YSL0ch1c8tOBvRywR0omR9SXU1AHxTaFsteOw6U1E2yT2ssgE3APLmflSutyhm8b3wsYW7csWe0mXb6muhnnj0bmg2at)BnUKmXrnZwslKpoHb6l0)wJljtCuZSL0c5KII6Xjmqvr)BnUKmXrTz0Jj)BwQ1PAv4XA7f)Q9IAhNWaTwBjjdVBTT)C2LxRcSXA)dS2OvRskSAhNWaDuRnMyTWrTxuRWyX3VABrw7zJ1EqgO1oX2vB41E2yTmBXDCwR4a1E2yTKWXaoXAHETTj0Y(4LAc7GHp42ssgExqcMGsYeh1KWXaoXHXWgy6FRXLKjoQTLKm8U8XjmqFrjfMXmBb6GvYyOFyMFZdSsgd9dZ8BEARzqltWkvQjSdg(GBljz4DbjyckjtCutlzkwOXWgy6FRXLKjoQz2sAH8Xjmqbt)BnUKmXrnZwslKtkkQhNWavLbjHc9e5iPz0JjcOPLmflSutyhm8b3wsYW7csWeenem5GHBmSbMuCHBYUxuIak16uTke8z3A)dSw6PmUAVOw6pCculZwslCulSvBpwRmtua6wRTyaRDeKyTTmiRns6snHDWWhCBjjdVlibtqjzIJA6PmoJHnW0)wJljtCuZSL0c5JtyGQI(3ACjzIJAMTKwiFCcd0xO)TgxsM4OMzlPfYjff1JtyGwQ1PAvikCoRThE21kK1(9jog1kM1ch1YcsOBv73SwXbQThFNyTZOV2WRLuCPutyhm8b3wsYW7csWeusM4OMeogWjomg2a)kImijuONi)GKO(7hCQfZxaRKrvrkUWnz3lDGrj0yMTaDWkzm0pmZV5bwjJH(Hz(npT1mOLjyLk16uTVwgn4eh12dp7ANrFTKY4WSRX1AdTSR1wghACTrwlDC21skDR1JRwBXawl6X3YUwsXLAVO2X30mYRw7OVwsXLAH(H(aAaRnfaO4xTdtjbTwM41sJgx7iQThFpN1(hyTnyI1spLXvR4a12YyC0X8QT3g9ANrFTHxlP4sPMWoy4dUTKKH3fKGjydMOMEkJRutyhm8b3wsYW7csWeSLX4OJ5vQvQjSdg(GhMOJj4gmrn9ugNXWg487ylslKdahmO5e6s2vZcssXbur)BnoaCWGMtOlzxnlijfhq3YyC8VzPMWoy4dEyIoMGembBzmoThgeJHnW53XwKwi3kHJzxnKbztufP4c3KDgPJqaLAc7GHp4Hj6ycsWe8pqn8qsJDHebpI)CI3bDlD(P7wQjSdg(GhMOJjibtqauoB6iDSutyhm8bpmrhtqcMGPaaf)0dtjb1yydmP4c3KDgbeA0snHDWWh8WeDmbjycscZmYHoA6lss0VsnHDWWh8WeDmbjycoSHTd6wAZOhtJHnW0)wJljtCuBg9yYbIExflIjq07CjzIJAZOhtEIKc0hLAc7GHp4Hj6ycsWeusM4OosAJHnWSiMarVZLKjoQnJEm5jkaDvr)BnUKmXrnZwslKpoHb6l0)wJljtCuZSL0c5KII6Xjmql1e2bdFWdt0XeKGjOKmXrn9ugNXWgywyaDXpUb0p7UPkwetGO35KWmJCOJM(IKe9JNiPa9Hr6qGWsnHDWWh8WeDmbjycEXNzRJM(SrnPybl1e2bdFWdt0XeKGjOKmXrTz0JzPMWoy4dEyIoMGembZVJ6OPnJEmng2at)BnUKmXrTz0Jjhi69sTovRc5aR91IoATxu741)ruHdwR41IkEPuBhNmXXAv(ugxTa)e6w1E2yTkiUokb74xR2EOde91(9jog1MF3HUvTDCYehRvHMzh8AbbB12XjtCSwfAMDulCu7jt0peW4A7XAzI)(Q9pWAFTOJwBp8SHETNnwRcIRJsWo(1QTh6arFTFFIJrT9yTq)Wm)MxTNnwBh3rRLzlUJtJRDe12JVNZAhIbSw4Xl1e2bdFWdt0XeKGjOzId0zOoAAsOdymSb(vNmr)4sYeh1iZoubG0)wJFXNzRJM(SrnPyb5Ftvai9V14x8z26OPpButkwqEIKc0hVaMiHDWW5sYeh10tzCCurK9puFqseeG(3ACZehOZqD00KqhGtkkQhNWaLWsTovliyR2xl6O1Ald)9vlnIET)bculWpHUvTNnwRcIRJwBp0bIEJRThFpN1(hyTWR2lQD86)iQWbRv8ArfVuQTJtM4yTkFkJRwOx7zJ1QqfVgb74xR2EOde98snHDWWh8WeDmbjycAM4aDgQJMMe6agdBGP)TgxsM4O2m6XK)nvr)BnE(DuhnTz0Jjprsb6JxatKWoy4CjzIJA6PmooQiY(hQpijccq)BnUzId0zOoAAsOdWjff1JtyGsyPMWoy4dEyIoMGembLKjoQPNY4mg2adehpfaO4NEykjO8ejfOpmcbqmXai9V14Paaf)0dtjbvB4pDmfA4eED5JtyGAeJwQ1PA74zV0DuRYLmflSw5Q9SXArhO2OvBh)A12BJET53DOBv7zJ12XjtCSwfILKm8U1orl0bKSBPMWoy4dEyIoMGembLKjoQPLmfl0yydm9V14sYeh1MrpM8VPk6FRXLKjoQnJEm5jskqF8Ifdqv(DSfPfYLKjoQTLKm8ULADQ2oE2lDh1QCjtXcRvUApBSw0bQnA1E2yTkuXRvBp0bI(A7TrV287o0TQ9SXA74KjowRcXssgE3ANOf6as2Tutyhm8bpmrhtqcMGsYeh10sMIfAmSbM(3A887OoAAZOht(3uf9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjprsb6JxaBXauLFhBrAHCjzIJABjjdVBPMWoy4dEyIoMGembLKjoQjHJbCIdJHnWai9V14x8z26OPpButkwq(3u1jt0pUKmXrnYSdver)BnoakNnDKoYbIENyIf2bnGA0rsioaReHQaq6FRXV4ZS1rtF2OMuSG8ejfOpmIWoy4CjzIJAs4yaN4GJkIS)H6dsIgZSfOdwjJrjND1mBb6Aydm9V14Sjkjtgh0T0mBXDCYbIExfr0)wJljtCuBg9yY)MetmrV6Kj6hpmGPz0JjcOIi6FRXZVJ6OPnJEm5FtIjMfXei6DoAiyYbdNNOa0LqcjSutyhm8bpmrhtqcMGsYeh1KWXaoXHXWgy6FRXztusMmoOBXhNWafm9V14Sjkjtgh0T4KII6XjmqvXcdOl(XnG(z3nl1e2bdFWdt0XeKGjOKmXrnjCmGtCymSbM(3AC2eLKjJd6w8ef2PIfXei6DUKmXrTz0Jjprsb6dver)BnE(DuhnTz0Jj)BsmX0)wJljtCuBg9yY)MeAmZwGoyLk1e2bdFWdt0XeKGjOKmXrDK0gdBGP)TgxsM4OMzlPfYhNWa9fWgKek0tKFXrQjff1mBjTWrPMWoy4dEyIoMGembLKjoQPNY4mg2at)BnE(DuhnTz0Jj)BsmXKIlCt2zeLiGsnHDWWh8WeDmbjycIgcMCWWng2at)BnE(DuhnTz0Jjhi6Dv0)wJljtCuBg9yYbIE3yOFyMFZtdBGjfx4MSZiG7qeGXq)Wm)MNgssIaq5qWkvQjSdg(GhMOJjibtqjzIJAAjtXcl1k16uNQvyhm8bpJtoy4GzIZWPwyhmCJHnWc7GHZrdbtoy4CMT4ooHULksXfUj7mc4ocbOIOxLFhBrAH8b00oC94IKKyIP)TgFanTdxpUij5JtyGcM(3A8b00oC94IKKtkkQhNWaLWsTovRc5aRfne1cB12JVtS2z0xB41skUuR4a1YIyce9(OwjXAf64F1ErT0yTFZsnHDWWh8mo5GHdsWeenem5GHBmSb(v53XwKwiFanTdxpUijvrkUWnz3lGnijuONihneAt2PIiwetGO35x8z26OPpButkwqEIKc0hVawyhmCoAiyYbdNJkIS)H6dsIetmlIjq07CjzIJAZOhtEIKc0hVawyhmCoAiyYbdNJkIS)H6dsIetmrNmr)453rD00MrpMQyrmbIENNFh1rtBg9yYtKuG(4fWc7GHZrdbtoy4CurK9puFqsKqcvr)BnE(DuhnTz0Jjhi6Dv0)wJljtCuBg9yYbIExfas)Bn(fFMToA6Zg1KIfKde9UQxzMObTfdGRe)IpZwhn9zJAsXcwQjSdg(GNXjhmCqcMGOHGjhmCJHnW53XwKwiFanTdxpUijv9kwyaDXpUb0p7UPkwetGO35sYeh1MrpM8ejfOpEbSWoy4C0qWKdgohvez)d1hKel1e2bdFWZ4Kdgoibtq0qWKdgUXWg487ylslKpGM2HRhxKKQyHb0f)4gq)S7MQyrmbIENtcZmYHoA6lss0pEIKc0hVawyhmCoAiyYbdNJkIS)H6dsIQyrmbIENFXNzRJM(SrnPyb5jskqF8cyImijuONiNmoTzImeb0xCKA6UGuyhmCoAiyYbdNJkIS)H6dsIGSdiuflIjq07CjzIJAZOhtEIKc0hVaMidscf6jYjJtBMidra9fhPMUlif2bdNJgcMCWW5OIi7FO(GKii7acl16uTkxYuSWAHTAH37rThKeR9IA)dS2loYAfhO2ESwBXaw7frTKI3TwMTKw4Outyhm8bpJtoy4GembLKjoQPLmfl0yydmlIjq078l(mBD00NnQjfliprbORkIO)TgxsM4OMzlPfYhNWa1igKek0tKFXrQjff1mBjTWHkwetGO35sYeh1MrpM8ejfOpEbmQiY(hQpijQIuCHBYoJyqsOqprUyQjHoK8tQjfx0MStf9V1453rD00MrpMCGO3jSutyhm8bpJtoy4GembLKjoQPLmfl0yydmlIjq078l(mBD00NnQjfliprbORkIO)TgxsM4OMzlPfYhNWa1igKek0tKFXrQjff1mBjTWHQtMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jskqF8cyurK9puFqsuLbjHc9e5hKe1F)GtTyAedscf6jYV4i1KIIAaCkD1Ti1IjHLAc7GHp4zCYbdhKGjOKmXrnTKPyHgdBGzrmbIENFXNzRJM(SrnPyb5jkaDvre9V14sYeh1mBjTq(4egOgXGKqHEI8losnPOOMzlPfour0RozI(XZVJ6OPnJEmjMywetGO3553rD00MrpM8ejfOpmIbjHc9e5xCKAsrrnaoLU6wK6mmjuLbjHc9e5hKe1F)GtTyAedscf6jYV4i1KIIAaCkD1Ti1IjHLAc7GHp4zCYbdhKGjOKmXrnTKPyHgdBGbq6FRXtbak(PhMscQ2WF6yk0Wj86YhNWafmas)BnEkaqXp9Wusq1g(thtHgoHxxoPOOECcduver)BnUKmXrTz0Jjhi6DIjM(3ACjzIJAZOhtEIKc0hVa2IbqOkIO)Tgp)oQJM2m6XKde9oXet)BnE(DuhnTz0Jjprsb6JxaBXaiSutyhm8bpJtoy4GembLKjoQPNY4mg2aBqsOqprEh(FC6)ab0dtjbLyIjcaP)TgpfaO4NEykjOAd)PJPqdNWRl)BQcaP)TgpfaO4NEykjOAd)PJPqdNWRlFCcd0xaq6FRXtbak(PhMscQ2WF6yk0Wj86Yjff1JtyGsyPMWoy4dEgNCWWbjyckjtCutpLXzmSbM(3ACZehOZqD00KqhG)nvbG0)wJFXNzRJM(SrnPyb5Ftvai9V14x8z26OPpButkwqEIKc0hVawyhmCUKmXrn9ughhvez)d1hKel1e2bdFWZ4KdgoibtqjzIJAs4yaN4Wyydmas)Bn(fFMToA6Zg1KIfK)nvDYe9JljtCuJm7qfr0)wJdGYzthPJCGO3jMyHDqdOgDKeIdWkrOkIaq6FRXV4ZS1rtF2OMuSG8ejfOpmIWoy4CjzIJAs4yaN4GJkIS)H6dsIetmlIjq07CZehOZqD00KqhGNiPa9bXeZcdOl(XbTBcfNqJz2c0bRKXOKZUAMTaDnSbM(3AC2eLKjJd6wAMT4oo5arVRIi6FRXLKjoQnJEm5FtIjMOxDYe9JhgW0m6Xebure9V1453rD00MrpM8VjXeZIyce9ohnem5GHZtua6siHewQ1PA7C4Jpjw7zJ1IkAkoacuRzCOFqzwl9V1QvgIzTxuRhxTZyG1Agh6huM1AMbBuQjSdg(GNXjhmCqcMGsYeh1KWXaoXHXWgy6FRXztusMmoOBXtuyNk6FRXrfnfhab0MXH(bLj)BwQjSdg(GNXjhmCqcMGsYeh1KWXaoXHXWgy6FRXztusMmoOBXtuyNkIO)TgxsM4O2m6XK)njMy6FRXZVJ6OPnJEm5FtIjgaP)Tg)IpZwhn9zJAsXcYtKuG(Wic7GHZLKjoQjHJbCIdoQiY(hQpijsOXmBb6GvQutyhm8bpJtoy4GembLKjoQjHJbCIdJHnW0)wJZMOKmzCq3INOWov0)wJZMOKmzCq3IpoHbky6FRXztusMmoOBXjff1JtyGAmZwGoyLk16uTD8Sx6oQ9YU1ErT0IdATDUZ12ISwwetGO3RTh6ar)Ow6)vlWN0S2ZgjRf2Q9SXUVtSwHo(xTxulQOjmXsnHDWWh8mo5GHdsWeusM4OMeogWjomg2at)BnoBIsYKXbDlEIc7ur)BnoBIsYKXbDlEIKc0hVaMiIO)TgNnrjzY4GUfFCcduqaHDWW5sYeh1KWXaoXbhvez)d1hKejeKwmaoPOiHgZSfOdwPsnHDWWh8mo5GHdsWe0XZgt9HKM44mg2atuITeh2c9ejM4xDqgOq3Iqv0)wJljtCuZSL0c5JtyGcM(3ACjzIJAMTKwiNuuupoHbQk6FRXLKjoQnJEm5arVRcaP)Tg)IpZwhn9zJAsXcYbIEVutyhm8bpJtoy4GembLKjoQJK2yydm9V14sYeh1mBjTq(4egOVa2GKqHEI8losnPOOMzlPfok1e2bdFWZ4KdgoibtWX3etpmigdBGnijuONip(3acG6OPzrmbIEFOIuCHBYUxa3riGsnHDWWh8mo5GHdsWeusM4OMEkJZyydm9V145FI6OPp7eXb)BQI(3ACjzIJAMTKwiFCcduJ0bLADQwfU)KM1YSL0ch1cB12J12K5SwACg91E2yTSWhyAaRLuCP2ZoXHDmbQvCGArdbtoy41ch1oo4CwB41YIyce9EPMWoy4dEgNCWWbjyckjtCutlzkwOXWg4xLFhBrAH8b00oC94IKuLbjHc9e5X)gqauhnnlIjq07dv0)wJljtCuZSL0c5JtyGcM(3ACjzIJAMTKwiNuuupoHbQQtMOFCjzIJ6iPvXIyce9oxsM4OosAEIKc0hVa2IbOIuCHBYUxa3rmQkwetGO35OHGjhmCEIKc0hLAc7GHp4zCYbdhKGjOKmXrnTKPyHgdBGZVJTiTq(aAAhUECrsQYGKqHEI84FdiaQJMMfXei69Hk6FRXLKjoQz2sAH8Xjmqbt)BnUKmXrnZwslKtkkQhNWav1jt0pUKmXrDK0QyrmbIENljtCuhjnprsb6JxaBXaurkUWnz3lG7igvflIjq07C0qWKdgoprsb6Jx6aJwQ1PAv4(tAwlZwslCulSvBK01ch1MOa0Tutyhm8bpJtoy4GembLKjoQPLmfl0yydSbjHc9e5X)gqauhnnlIjq07dv0)wJljtCuZSL0c5JtyGcM(3ACjzIJAMTKwiNuuupoHbQQtMOFCjzIJ6iPvXIyce9oxsM4OosAEIKc0hVa2IbOIuCHBYUxa3rmQkwetGO35OHGjhmCEIKc0hQi6v53XwKwiFanTdxpUijjMy6FRXhqt7W1JlssEIKc0hVawPoeHLADQ2oozIJ1QCjtXcRDyh)jqTwOJPmNDRLgR9SXANY4QLjJR2Ov7zJ12XVwT9qhi6l1e2bdFWZ4KdgoibtqjzIJAAjtXcng2at)BnUKmXrTz0Jj)BQI(3ACjzIJAZOhtEIKc0hVa2IbOI(3ACjzIJAMTKwiFCcduW0)wJljtCuZSL0c5KII6XjmqvrelIjq07C0qWKdgoprsb6dIjo)o2I0c5sYeh12ssgExcl16uTDCYehRv5sMIfw7Wo(tGATqhtzo7wlnw7zJ1oLXvltgxTrR2ZgRvHkETA7Hoq0xQjSdg(GNXjhmCqcMGsYeh10sMIfAmSbM(3A887OoAAZOht(3uf9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjprsb6JxaBXaur)BnUKmXrnZwslKpoHbky6FRXLKjoQz2sAHCsrr94egOQiIfXei6DoAiyYbdNNiPa9bXeNFhBrAHCjzIJABjjdVlHLADQ2oozIJ1QCjtXcRDyh)jqT0yTNnw7ugxTmzC1gTApBSwfexhT2EOde91cB1cVAHJA94Q9pqGA7HNDTkuXRvBK12XVwPMWoy4dEgNCWWbjyckjtCutlzkwOXWgy6FRXLKjoQnJEm5arVRI(3A887OoAAZOhtoq07Qaq6FRXV4ZS1rtF2OMuSG8VPkaK(3A8l(mBD00NnQjfliprsb6JxaBXaur)BnUKmXrnZwslKpoHbky6FRXLKjoQz2sAHCsrr94egOLADQwfEB0R9SXApjTWRw4OwOxlQiY(hwBkUfwR4a1E2yI1ch1sgjw7zlETHJ1Ios214A)dSwAjtXcRvg1oIWRvg12n(1AlgWArp(w21YSL0ch1ErT2WRwzoRfDKeIJAHTApBS2oozIJ1Q8GKwsas0VANOf6as2Tw4Ow81)HMMiqPMWoy4dEgNCWWbjyckjtCutlzkwOXWgydscf6jYrsZOhteqtlzkwOk6FRXLKjoQz2sAH8XjmqncyIe2bnGA0rsio6WuIqvc7Ggqn6ijehgrjv0)wJdGYzthPJCGO3l1e2bdFWZ4KdgoibtqjzIJAurZzmGHBmSb2GKqHEICK0m6Xeb00sMIfQI(3ACjzIJAMTKwiFCcd0xO)TgxsM4OMzlPfYjff1JtyGQsyh0aQrhjH4WikPI(3ACauoB6iDKde9EPMWoy4dEgNCWWbjyckjtCutpLXvQjSdg(GNXjhmCqcMGOHGjhmCJHnWgKek0tKh)BabqD00SiMarVpk1e2bdFWZ4KdgoibtqjzIJAAjtXcPEK)zhj1ZdK8pLdgENtPDuh1rrb]] )


end