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
        if buff.arcane_charge.stack == buff.arcane_charge.max_stack and not buff.rule_of_threes.up and fight_remains <= ( ( mana.percent * action.arcane_blast.execute_time ) ) then
            return 1
        end

        return 0
    end )


    -- actions.precombat+=/variable,name=harmony_stack_time,op=reset,default=9
    spec:RegisterVariable( "harmony_stack_time", function ()
        return 9
    end )

    -- + actions.precombat+=/variable,name=always_sync_cooldowns,default=-1,op=set,if=variable.always_sync_cooldowns=-1,value=1*set_bonus.tier28_2pc
    spec:RegisterVariable( "always_sync_cooldowns", function ()
        return set_bonus.tier28_4pc > 0 and 1 or 0
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


    spec:RegisterPack( "Arcane", 20220221, [[dev)ehqivj6rQs4sKar0MijFcinkevNcrzvQssELQuMffQBjvqzxO6xisggjLogjYYOq6zsfyAKGY1uLQ2gjq9nvPIgNuH4CsfK1rcY7ibIqZtQO7bu7JevhuQqTqsuEOQKAIKGk5IKaPnscePpscQuJKeiQtQkvyLKu9ssGiWmjbCtPcPDssXpjbcdvvsSuvPsEQQyQisDvvPsTvsGiOVscQASui2ls(lPgSshMyXi1JrzYaUm0MLYNPKrtPonOvlvq1RbIzROBJWUP63cdNIoUQKulx0Zvy6QCDv12PGVlvnEsOZlvA9KGkMpIy)sMsjkst9aihsPgJQwJAu1AuJQe3OQvTDO3RGPEUUMi1JPWarSqQhxiqQNoozIJupMs3ziauKM6ze)KHup23zouisrkl4z)P5SGGudiXFkhmCwkTJudibJuup0F48Ehofn1dGCiLAmQAnQrvRrnQsCJQw12HE)7PEgMiJsnkyJs9ydbaqNIM6bahmQNoQyH12XjtCSuxbPiD(LSBTgvjJR1OQ1OgTuVu)12IBHdfQuVdR239aR96AczYS2hiXRR1wCGj0TQnA1YSf3XzTq)Wm)Mhm8AH(4qbO2OvlOmXz4ulSdgoO8s9oSAFTT4wyTsYeh1qVbD41T2lQvsM4O2wsIW7wl5WRwhnGzT9OF1oHgWALrTsYeh12sseExY4L6Dy1QWv4GE1QGAiyYH1c9A7yfekO12H)hxT0it(dS2UXh0eRn(xTrR2uClSwXbQ1JR2)a6w12XjtCSwfufnNXagoVuVdR2ogOd)pUAntyKWRBTxu7FG12XjtCS2xj6Xe0rTyRHSdAaRLfXei69APLbcuB41(AfUEx1ITgYUbVuVdR239aRDCjKD1AMbdhdOBv7f1MiWNH1(6x5Dx7bjWAb(yTxu73DKHJHKDRTJFffO2wKGm4L6Dy12rddiqTgKek0tCqkMmz)PCWWh1ErTkWxQLia(tS2lQnrGpdR91VY7U2dsGCQNjCCdkst9yljr4DPinLAuII0upOl0teGszupc7GHt9GgcMCWWPEaWblHMhmCQN3rR2z0xB41siUuR4a1YIyce9(OwjXAzbb0TQ9BACTwrTInka1koqTOHG6HLWdtOq9qiUWnzxTDcU2oqT1QQwdscf6jYJ)nGaOoAAwetGO3h1QQwYR9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIec0h12zTkP2AjJ6OuJrPin1d6c9ebOug1daoyj08GHt9OWJ12l(v7f1ooHbsT2sseE3AB)5SlVwsBJ1(hyTrRwLuW1ooHbYOwBmXAHJAVOwHXIVF12IS2ZgR9GmqQDITR2WR9SXAz2I74SwXbQ9SXAjGJbCI1c9ABtOL9XPEyj8WekupKxRbjHc9e5JtyGOTLKi8U1scj1EqcS2oRvj1wlz1QQw6FRXLKjoQTLKi8U8XjmqQTZAvsbt9WSfOt9Oe1JWoy4upsYeh1eWXaoXb1rPMoGI0upOl0teGszupc7GHt9ijtCutahd4ehupa4GLqZdgo1JcVn61(hq3QwfucZUjkZAvqKaU4m04AzY4QvQTH91IkEPulbCmGtCuBVnCI12lWd6w12IS2ZgRL(3A1kxTNnw74K8QnA1E2yTnOL9r9Ws4HjuOEWx9hAAIaCKWSBIYuhjGlodRvvThKaRTZA7a1wRQAVWYAICwetGO3h1QQwwetGO35iHz3eLPosaxCgYtKqG(OwLxRsk4osTQQ9L1kSdgohjm7MOm1rc4IZqoaCi0teG6OuJcJI0upOl0teGszupc7GHt9mI)CI3bDlD(P7s9Ws4HjuOEO)TgxsM4O2m6XK)nRvvTNKw4XbGJtCgwBNGRvj1s94cbs9mI)CI3bDlD(P7sDuQ59uKM6bDHEIaukJ6ryhmCQNr8Nt8oOBPZpDxQhwcpmHc1JbjHc9e5iHz0JjcOPLmflSwv1YIyce9o)IpZwhn9zJAcXcYtKqG(O2obxlQiY(hQpibwRQAzrmbIENljtCuBg9yYtKqG(O2obxl51IkIS)H6dsG1(QQ1O1swTQQ9K0cpoaCCIZWAvETkPwQhxiqQNr8Nt8oOBPZpDxQJsnkykst9GUqprakLr9Ws4HjuOEmijuONihjmJEmranTKPyH1QQwwetGO35x8z26OPpButiwqEIec0h12j4Arfr2)q9bjWAvvllIjq07CjzIJAZOhtEIec0h12j4AjVwurK9puFqcS2xvTgTwYQvvTKx7lRfF1FOPjcWhXFoX7GULo)0DRLesQLfoWhECjzIJAZmaGwD5P4GuRYbx77RLesQL8AzrmbIENpI)CI3bDlD(P7YtKqG(OwLxRskP2Avv7jPfECa44eNH1Q8AvsT1swTKqsTKxllIjq078r8Nt8oOBPZpDxEIec0h12j4Arfr2)q9bjWAvv7jPfECa44eNH12j4AvsT1swTKr9iSdgo1tkaqXp9WusqOok18oPin1d6c9ebOug1dlHhMqH6XGKqHEI8o8)40)bcOhMscsTQQLfXei6DUKmXrTz0Jjprcb6JA7eCTOIi7FO(GeyTQQL8AFzT4R(dnnra(i(ZjEh0T05NUBTKqsTSWb(WJljtCuBMba0QlpfhKAvo4AFFTKqsTKxllIjq078r8Nt8oOBPZpDxEIec0h1Q8Avsj1wRQApjTWJdahN4mSwLxRsQTwYQLesQL8AzrmbIENpI)CI3bDlD(P7YtKqG(O2obxlQiY(hQpibwRQApjTWJdahN4mS2obxRsQTwYQLmQhHDWWPEU4ZS1rtF2OMqSGuhLA6iuKM6bDHEIaukJ6HLWdtOq9yMObTfdGRe)IpZwhn9zJAcXcs9iSdgo1JKmXrTz0Jj1rPMoefPPEqxONiaLYOEyj8WekupgKek0tKJeMrpMiGMwYuSWAvvllIjq078uaGIF6HPKGWtKqG(O2obxlQiY(hQpibwRQAnijuONi)GeO(7hCQfZAvo4AnQARvvTKx7lRLfoWhECjzIJAZmaGwD5Ol0teOwsiP2xwRbjHc9e5YSx6o0JUotZIyce9(OwsiPwwetGO35x8z26OPpButiwqEIec0h12j4AjVwurK9puFqcS2xvTgTwYQLmQhHDWWPEYVJ6OPnJEmPok1OKAPin1d6c9ebOug1dlHhMqH6XGKqHEICKWm6Xeb00sMIfwRQAnt0G2IbWvINFh1rtBg9ys9iSdgo1tkaqXp9WusqOok1OKsuKM6bDHEIaukJ6HLWdtOq9yqsOqprEh(FC6)ab0dtjbPwv1(YAnijuONi3oMaq3sFXrq9iSdgo1ZfFMToA6Zg1eIfK6OuJsgLI0upOl0teGszupc7GHt9ijtCutlzkwi1daoyj08GHt98UhyTg1bQvsM4yT0sMIfwl0RTJFL3ExkiELAdF2TwyRwLnJay(hxTIduRC1orzC1A0AF9Rh1AMbJHaupSeEycfQh6FRXLKjoQz2sAH8XjmqQfCT0)wJljtCuZSL0c5eII6XjmqQvvT0)wJNFh1rtBg9yY)M1QQw6FRXLKjoQnJEm5FZAvvl9V14sYeh12sseEx(4egi1QCW1QKcUwv1s)BnUKmXrTz0Jjprcb6JA7eCTc7GHZLKjoQPLmflKJkIS)H6dsG1QQw6FRXPNram)JJ)nPok1OuhqrAQh0f6jcqPmQhHDWWPEYVJ6OPnJEmPEaWblHMhmCQN39aR1OoqTVR4vQf612XVsTHp7wlSvRYMram)JRwXbQ1O1(6xpQ1mdg1dlHhMqH6H(3A887OoAAZOhtoq071QQw6FRXPNram)JJ)nRvvTKxRbjHc9e5hKa1F)GtTywRYRTduBTKqsTSiMarVZtbak(PhMsccprcb6JAvETkz0AjRwv1sET0)wJljtCuBljr4D5JtyGuRYbxRsVVwsiPw6FRXztusMmoOBXhNWaPwLdUwLQLSAvvl51(YAzHd8HhxsM4O2mdaOvxo6c9ebQLesQ9L1AqsOqprUm7LUd9ORZ0SiMarVpQLmQJsnkPWOin1d6c9ebOug1dlHhMqH6H(3ACjzIJAZOhtoq071QQwYR1GKqHEI8dsG6VFWPwmRv512bQTwsiPwwetGO35Paaf)0dtjbHNiHa9rTkVwLmATKvRQAjV2xwllCGp84sYeh1MzaaT6YrxONiqTKqsTVSwdscf6jYLzV0DOhDDMMfXei69rTKr9iSdgo1t(DuhnTz0Jj1rPgLEpfPPEqxONiaLYOEyj8WekupgKek0tKJeMrpMiGMwYuSWAvvl51s)BnUKmXrnZwslKpoHbsTkhCTgTwsiPwwetGO35sYeh1rsZtua6wlz1QQwYR9L1EYe9JNFh1rtBg9yYrxONiqTKqsTSiMarVZZVJ6OPnJEm5jsiqFuRYR991swTQQLfXei6DUKmXrTz0Jjprcb6dnQOjYoeOwLdU2oqT1QQwYR9L1Ych4dpUKmXrTzgaqRUC0f6jculjKu7lR1GKqHEICz2lDh6rxNPzrmbIEFulzupc7GHt9Kcau8tpmLeeQJsnkPGPin1d6c9ebOug1JWoy4upx8z26OPpButiwqQhaCWsO5bdN6rH3g9AZV7q3QwZmaGwDnU2)aR9IJOw6U1cVboB1c9AJeaZAVOwzcT8AHxT9WZUwXK6HLWdtOq9yqsOqpr(bjq93p4ulM12zTVxT1QQwdscf6jYpibQ)(bNAXSwLxBhO2Avvl51(YAXx9hAAIa8r8Nt8oOBPZpD3AjHKAzHd8HhxsM4O2mdaOvxEkoi1QCW1((AjJ6OuJsVtkst9GUqprakLr9Ws4HjuOEmijuONiVd)po9FGa6HPKGuRQAP)TgxsM4OMzlPfYhNWaP2oRL(3ACjzIJAMTKwiNquupoHbc1JWoy4upsYeh1rstDuQrPocfPPEqxONiaLYOEyj8Wekupai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGul4Abq6FRXtbak(PhMscI2WF6yk0Wj86Yjef1JtyGq9iSdgo1JKmXrnTKPyHuhLAuQdrrAQh0f6jcqPmQhwcpmHc1JbjHc9e5D4)XP)deqpmLeKAjHKAjVwaK(3A8uaGIF6HPKGOn8NoMcnCcVU8VzTQQfaP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdKA7SwaK(3A8uaGIF6HPKGOn8NoMcnCcVUCcrr94egi1sg1JWoy4upsYeh10tzCuhLAmQAPin1d6c9ebOug1JWoy4upsYeh10sMIfs9aGdwcnpy4upV7bwlb0H1QmjtXcRLgVEe9Atbak(v7Wusqg1cB1(DamRvzkqT9WZo(xTa4u6cDRAFxcau8R2htjbPwiakZzxQhwcpmHc1d9V1453rD00MrpM8VzTQQL(3ACjzIJAZOhtoq071QQw6FRXPNram)JJ)nRvvTSiMarVZtbak(PhMsccprcb6JA7eCTkP2Avvl9V14sYeh12sseEx(4egi1QCW1QKcM6OuJrvII0upOl0teGszupc7GHt9ijtCuhjn1daoyj08GHt98UhyTrsxB41YaQ97tCmQvmRfoQLfeq3Q2VzTJiCQhwcpmHc1d9V14sYeh1mBjTq(4egi12zTDqTQQ1GKqHEI8dsG6VFWPwmRv51QKARvvTKxllIjq078l(mBD00NnQjeliprcb6JAvETVVwsiP2xwllCGp84sYeh1MzaaT6YrxONiqTKrDuQXOgLI0upOl0teGszupc7GHt9ijtCutahd4ehupmBb6upkr9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQw6FRXLKjoQnJEm5FtQJsngTdOin1d6c9ebOug1JWoy4upsYeh10sMIfs9aGdwcnpy4upVJwT9yTw4vRz0JzTqV9hWWRf4Nq3Q25FC12JGoN1AlgWArp(w21AlJdR9IATWR2O1QvQDCz4w1slzkwyTa)e6w1E2yTzyskXS2EOde9upSeEycfQh6FRXZVJ6OPnJEm5FZAvvl9V1453rD00MrpM8ejeOpQTtW1kSdgoxsM4OMaogWjo4OIi7FO(GeyTQQL(3ACjzIJAZOht(3Swv1s)BnUKmXrnZwslKpoHbsTGRL(3ACjzIJAMTKwiNquupoHbsTQQL(3ACjzIJABjjcVlFCcdKAvvl9V14MrpMAO3(dy48VzTQQL(3AC6zeaZ)44FtQJsngvHrrAQh0f6jcqPmQhHDWWPEKKjoQPNY4OEaWblHMhmCQN3rR2ESwl8Q1m6XSwO3(dy41c8tOBv78pUA7rqNZATfdyTOhFl7ATLXH1ErTw4vB0A1k1oUmCRAPLmflSwGFcDRApBS2mmjLywBp0bIEJRDe12JGoN1g(SBT)bwl6X3YUw6PmUrTqhEqzo7w7f1AHxTxuBl(zTmBjTWb1dlHhMqH6H(3ACZehOZqD00eqhG)nRvvTKxl9V14sYeh1mBjTq(4egi12zT0)wJljtCuZSL0c5eII6XjmqQLesQ9L1sET0)wJBg9yQHE7pGHZ)M1QQw6FRXPNram)JJ)nRLSAjJ6OuJrFpfPPEqxONiaLYOEe2bdN6XmXb6muhnnb0bOEaWblHMhmCQhsBJ1sJJR2)aRnA1Age1ch1ErT)bwl8Q9IAF1FidKz3AP)WjqTmBjTWrTa)e6w1kM1kTdZApBSBTw4vlWNWebQLUBTNnwRTKeH3TwAjtXcPEyj8Wekup0)wJljtCuZSL0c5JtyGuBN1s)BnUKmXrnZwslKtikQhNWaPwv1s)BnUKmXrTz0Jj)BsDuQXOkykst9GUqprakLr9aGdwcnpy4upk8yT9IF1ErTJtyGuRTKeH3T22Fo7YRL02yT)bwB0QvjfCTJtyGmQ1gtSw4O2lQvyS47xTTiR9SXApidKANy7Qn8ApBSwMT4ooRvCGApBSwc4yaNyTqV22eAzFCQhHDWWPEKKjoQjGJbCIdQhOFyMFZJ6rjQhMTaDQhLOEyj8Wekup0)wJljtCuBljr4D5JtyGuBN1QKcM6b6hM5380wZGwMupkrDuQXOVtkst9GUqprakLr9Ws4HjuOEO)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtikQhNWaPwv1AqsOqprosyg9yIaAAjtXcPEe2bdN6rsM4OMwYuSqQJsngTJqrAQh0f6jcqPmQhwcpmHc1dH4c3KD12zTk9EQhHDWWPEqdbtoy4uhLAmAhII0upOl0teGszupc7GHt9ijtCutpLXr9aGdwcnpy4upki8z3A)dSw6PmUAVOw6pCculZwslCulSvBpwRmtua6wRTyaRDeeyTTmiQnsAQhwcpmHc1d9V14sYeh1mBjTq(4egi1QQw6FRXLKjoQz2sAH8XjmqQTZAP)TgxsM4OMzlPfYjef1JtyGqDuQPdulfPPEqxONiaLYOEaWblHMhmCQhfKcNZA7HNDTcrTFFIJrTIzTWrTSGa6w1(nRvCGA7rqtS2z0xB41siUq9iSdgo1JKmXrnbCmGtCq9a9dZ8BEupkr9WSfOt9Oe1dlHhMqH65L1sETgKek0tKFqcu)9do1IzTDcUwLuBTQQLqCHBYUA7S2oqT1sg1d0pmZV5PTMbTmPEuI6OuthOefPPEqxONiaLYOEaWblHMhmCQNxjJgCIJA7HNDTZOVwczCy214ATHw21AlJdnU2iRLoo7AjKU16XvRTyaRf94BzxlH4sTxu74BAg5vRD0xlH4sTq)qFanG1Mcau8R2HPKGult8APrJRDe12JGoN1(hyTnyI1spLXvR4a12YyC0X8QT3g9ANrFTHxlH4c1JWoy4upnyIA6PmoQJsnDGrPin1JWoy4upTmghDmpQh0f6jcqPmQJ6OEAWHn0T0Hj6ysrAk1OefPPEqxONiaLYOEe2bdN6bnem5GHt9aGdwcnpy4upk82OxB(Dh6w1IWZgZApBS2NNAJSwsRWx7eTqhqsiomU2ES2EXVAVOwfudrT0ylsS2ZgRL0X1rjvh)k12dDGONx77EG1cVALrTJi8ALrTVR4vQ1wg12GoCyJa1g)S2EeudyTdt0VAJFwlZwslCq9Ws4HjuOEiV287ylslKFiHzKYu3lPjhDHEIa1scj1sET53XwKwiFanTdxpUij4Ol0teOwv1(YAnijuONi3mrZ)CQrdrTGRvPAjRwYQvvTKxl9V1453rD00MrpMCGO3RLesQ1mrdAlgaxjUKmXrnTKPyH1swTQQLfXei6DE(DuhnTz0Jjprcb6dQJsngLI0upOl0teGszupc7GHt9GgcMCWWPEaWblHMhmCQN3rR2EeudyTnOdh2iqTXpRLfXei69A7Hoq0pQvCGAhMOF1g)SwMTKw4W4AntyKWdQWbRvb1quByaZArdy29SHUvT4CGupSeEycfQNtMOF887OoAAZOhto6c9ebQvvTSiMarVZZVJ6OPnJEm5jsiqFuRQAzrmbIENljtCuBg9yYtKqG(Owv1s)BnUKmXrTz0Jjhi69Avvl9V1453rD00MrpMCGO3RvvTMjAqBXa4kXLKjoQPLmflK6OuthqrAQh0f6jcqPmQhwcpmHc1t(DSfPfYbGdg0CcDj7QzbbH4aC0f6jcuRQAP)TghaoyqZj0LSRMfeeIdOBzmo(3K6ryhmCQNgmrn9ugh1rPgfgfPPEqxONiaLYOEyj8Wekup53XwKwi3kHJzxnKbztKJUqprGAvvlH4c3KD1Q8A7qVN6ryhmCQNwgJt7HbH6OuZ7Pin1d6c9ebOug1JWoy4upsYeh1eWXaoXb1dZwGo1JsupSeEycfQN87ylslKljtCuBljr4D5Ol0teOwv1s)BnUKmXrTTKeH3LpoHbsTDwl9V14sYeh12sseExoHOOECcdKAvvl51sET0)wJljtCuBg9yYbIEVwv1YIyce9oxsM4O2m6XKNOa0TwYQLesQfaP)Tg)IpZwhn9zJAcXcY)M1sg1rPgfmfPPEqxONiaLYOEyj8Wekup53XwKwiFanTdxpUij4Ol0teG6ryhmCQN87OoAAZOhtQJsnVtkst9GUqprakLr9Ws4HjuOEyrmbIENNFh1rtBg9yYtua6s9iSdgo1JKmXrDK0uhLA6iuKM6bDHEIaukJ6HLWdtOq9WIyce9op)oQJM2m6XKNOa0Twv1s)BnUKmXrnZwslKpoHbsTDwl9V14sYeh1mBjTqoHOOECcdeQhHDWWPEKKjoQPNY4Ook10HOin1d6c9ebOug1dlHhMqH65L1MFhBrAH8djmJuM6Ejn5Ol0teOwsiPww4aF4XTGTthn9zJ6jKzZrxONia1JWoy4upaOC20r6i1rPgLulfPPEe2bdN6j)oQJM2m6XK6bDHEIaukJ6OuJskrrAQh0f6jcqPmQhHDWWPEKKjoQjGJbCIdQhaCWsO5bdN65D0QThbnXALRwcrXAhNWazuB0Q91VUwXbQThR1wmGoOxT)bcuBhniDTDXZ4A)dSwP2XjmqQ9IAnt0a6xTeFNzdDRA)(ehJAZV7q3Q2ZgRvbzjjcVBTt0cDaj7s9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQw6FRXztusMmoOBXhNWaPwW1s)BnoBIsYKXbDloHOOECcdKAvvllmGU4h3a6ND3Swv1YIyce9oNaMzKdD00xKeOF8efGU1QQ2xwRbjHc9e5iHz0JjcOPLmflSwv1YIyce9oxsM4O2m6XKNOa0L6OuJsgLI0upOl0teGszupSeEycfQNxwB(DSfPfYpKWmszQ7L0KJUqprGAvvl51(YAZVJTiTq(aAAhUECrsWrxONiqTKqsTKxRbjHc9e5MjA(NtnAiQfCTkvRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtikQhNWaPwYQLmQhaCWsO5bdN6rnrsiZz3A7XAnfywRzCWWR9pWA7HNDTD8RyCT0)Rw4vBpCoRDkJR2z4w1IE8TSRTfzT0Xzx7zJ1(UIxPwXbQTJFLA7Hoq0pQ97tCmQn)UdDRApBS2NNAJSwsRWx7eTqhqsioOEe2bdN6Xmoy4uhLAuQdOin1d6c9ebOug1dlHhMqH6H(3A887OoAAZOhtoq071scj1AMObTfdGRexsM4OMwYuSqQhHDWWPEaq5SPJ0rQJsnkPWOin1d6c9ebOug1dlHhMqH6H(3A887OoAAZOhtoq071scj1AMObTfdGRexsM4OMwYuSqQhHDWWPEsbak(PhMscc1rPgLEpfPPEqxONiaLYOEyj8Wekup0)wJNFh1rtBg9yYtKqG(O2oRL8AvW1(wTgT2xvT53XwKwiFanTdxpUij4Ol0teOwYOEe2bdN6HaMzKdD00xKeOFuhLAusbtrAQh0f6jcqPmQhHDWWPEKKjoQnJEmPEaWblHMhmCQhfEB0Rn)UdDRApBSwfKLKi8U1orl0bKSRX1(hyTD8Ruln2IeRL0X1rR9IAb(eM1k12(Zz3AhNWabbQLwYuSqQhwcpmHc1JbjHc9e5iHz0JjcOPLmflSwv1s)BnE(DuhnTz0Jj)BwRQAjVwcXfUj7QTZAjVwJ((AFRwYRvj1w7RQwwyaDXpoiDtO41swTKvljKul9V14Sjkjtgh0T4JtyGul4AP)TgNnrjzY4GUfNquupoHbsTKrDuQrP3jfPPEqxONiaLYOEyj8WekupgKek0tKJeMrpMiGMwYuSWAvvl9V14sYeh1mBjTq(4egi1cUw6FRXLKjoQz2sAHCcrr94egi1QQw6FRXLKjoQnJEm5FtQhHDWWPEKKjoQPLmflK6OuJsDekst9GUqprakLr9iSdgo1Zi(ZjEh0T05NUl1dlHhMqH6H(3A887OoAAZOhtoq071scj1AMObTfdGRexsM4OMwYuSWAjHKAnt0G2IbWvINcau8tpmLeKAjHKAjVwZenOTyaCL4aOC20r6yTQQ9L1MFhBrAH8b00oC94IKGJUqprGAjJ6XfcK6ze)5eVd6w68t3L6OuJsDikst9GUqprakLr9Ws4HjuOEO)Tgp)oQJM2m6XKde9ETKqsTMjAqBXa4kXLKjoQPLmflSwsiPwZenOTyaCL4Paaf)0dtjbPwsiPwYR1mrdAlgaxjoakNnDKowRQAFzT53XwKwiFanTdxpUij4Ol0teOwYOEe2bdN65IpZwhn9zJAcXcsDuQXOQLI0upOl0teGszupSeEycfQhZenOTyaCL4x8z26OPpButiwqQhHDWWPEKKjoQnJEmPok1yuLOin1d6c9ebOug1JWoy4upMjoqNH6OPjGoa1daoyj08GHt98UhyTVs0rR9IAhV6pIkCWAfVwuXlLA74KjowRYMY4Qf4Nq3Q2ZgRL0X1rjvh)k12dDGOV2VpXXO287o0TQTJtM4yTkOm7Gx77OvBhNmXXAvqz2rTWrTNmr)qaJRThRLjoOxT)bw7ReD0A7HNn0R9SXAjDCDus1XVsT9qhi6R97tCmQThRf6hM538Q9SXA74oATmBXDCACTJO2Ee05S2HyaRfECQhwcpmHc1ZlR9Kj6hxsM4Ogz2bhDHEIa1QQwaK(3A8l(mBD00NnQjeli)BwRQAbq6FRXV4ZS1rtF2OMqSG8ejeOpQTtW1sETc7GHZLKjoQPNY44OIi7FO(GeyTVQAP)Tg3mXb6muhnnb0b4eII6XjmqQLmQJsng1OuKM6bDHEIaukJ6ryhmCQhZehOZqD00eqhG6bahSeAEWWPEEhTAFLOJwRTmCqVAPr0R9pqGAb(j0TQ9SXAjDCD0A7Hoq0BCT9iOZzT)bwl8Q9IAhV6pIkCWAfVwuXlLA74KjowRYMY4Qf61E2yTVR4vivh)k12dDGONt9Ws4HjuOEO)TgxsM4O2m6XK)nRvvT0)wJNFh1rtBg9yYtKqG(O2obxl51kSdgoxsM4OMEkJJJkIS)H6dsG1(QQL(3ACZehOZqD00eqhGtikQhNWaPwYOok1y0oGI0upOl0teGszupSeEycfQhG44Paaf)0dtjbHNiHa9rTkV23xljKulas)BnEkaqXp9Wusq0g(thtHgoHxx(4egi1Q8Avl1JWoy4upsYeh10tzCuhLAmQcJI0upOl0teGszupc7GHt9ijtCutlzkwi1daoyj08GHt9OWJ12l(v7f1siGG1o(jwBpwRTyaRf94BzxlH4sTTiR9SXAr)GjwBh)k12dDGO34ArdOxlSv7zJjc6O2XbNZApibwBIec0HUvTHx77kEfETVJd0rTHp7wlnEhM1ErT0)0R9IAv4GzuR4a1QGAiQf2Qn)UdDRApBS2NNAJSwsRWx7eTqhqsio4upSeEycfQhwetGO35sYeh1MrpM8efGU1QQwcXfUj7QTZAjVwfMAR9TAjVwLuBTVQAzHb0f)4G0nHIxlz1swTQQL(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoHOOECcdKAvvl51(YAZVJTiTq(aAAhUECrsWrxONiqTKqsTgKek0tKBMO5Fo1OHOwW1QuTKvRQAFzT53XwKwi)qcZiLPUxsto6c9ebQvvTVS287ylslKljtCuBljr4D5Ol0teG6OuJrFpfPPEqxONiaLYOEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6rzsMIfw7Wo(tGA94QLgR9pqGALR2ZgRfDGAJwTD8RulSvRcQHGjhm8AHJAtua6wRmQfidttOBvlZwslCuBpCoRLqabRfE1EciyTZWTWS2lQL(NETNDgFl7AtKqGo0TQLqCH6HLWdtOq9q)BnUKmXrTz0Jj)BwRQAP)TgxsM4O2m6XKNiHa9rTDcUwlgqTQQLfXei6DoAiyYbdNNiHa9b1rPgJQGPin1d6c9ebOug1JWoy4upsYeh10sMIfs9aGdwcnpy4upktYuSWAh2XFcuRm7LUJAPXApBS2PmUAzY4Qf61E2yTVR4vQTh6arFTYOwshxhT2E4CwBIJlsS2ZgRLzlPfoQDyI(r9Ws4HjuOEO)Tgp)oQJM2m6XK)nRvvT0)wJljtCuBg9yYbIEVwv1s)BnE(DuhnTz0Jjprcb6JA7eCTwmGAvv7lRn)o2I0c5sYeh12sseExo6c9ebOok1y03jfPPEqxONiaLYOEy2c0PEuI6bLC2vZSfORHnQh6FRXztusMmoOBPz2I74Kde9UkYP)TgxsM4O2m6XK)njHeYF5jt0pEyatZOhteqf50)wJNFh1rtBg9yY)MKqclIjq07C0qWKdgoprbOlzKrg1dlHhMqH6baP)Tg)IpZwhn9zJAcXcY)M1QQ2tMOFCjzIJAKzhC0f6jcuRQAjVw6FRXbq5SPJ0roq071scj1kSdAa1OJeqCul4AvQwYQvvTai9V14x8z26OPpButiwqEIec0h1Q8Af2bdNljtCutahd4ehCurK9puFqcK6ryhmCQhjzIJAc4yaN4G6OuJr7iuKM6bDHEIaukJ6ryhmCQhjzIJAc4yaN4G6bahSeAEWWPEEhTA7rqtSwdOF2DtJRfsqGaq5Wz3A)dS2x)6A7TrVwMyAIa1ErTEC12lJdR1md2O2wge12rdst9Ws4HjuOEyHb0f)4gq)S7M1QQw6FRXztusMmoOBXhNWaPwW1s)BnoBIsYKXbDloHOOECcdeQJsngTdrrAQh0f6jcqPmQhaCWsO5bdN655K8Q9pGUvTV(112XD0A7TrV2o(vQ1wg1sJOx7FGaupSeEycfQh6FRXztusMmoOBXtuyxTQQLfXei6DUKmXrTz0Jjprcb6JAvvl51s)BnE(DuhnTz0Jj)BwljKul9V14sYeh1MrpM8VzTKr9WSfOt9Oe1JWoy4upsYeh1eWXaoXb1rPMoqTuKM6bDHEIaukJ6HLWdtOq9q)BnUKmXrnZwslKpoHbsTDcUwdscf6jYV4i0eIIAMTKw4G6ryhmCQhjzIJ6iPPok10bkrrAQh0f6jcqPmQhwcpmHc1d9V1453rD00MrpM8VzTKqsTeIlCt2vRYRvP3t9iSdgo1JKmXrn9ugh1rPMoWOuKM6bDHEIaukJ6ryhmCQh0qWKdgo1d0pmZV5PHnQhcXfUj7uo4oY7PEG(Hz(npnKGabGYHupkr9Ws4HjuOEO)Tgp)oQJM2m6XKde9ETQQL(3ACjzIJAZOhtoq07uhLA6GoGI0upc7GHt9ijtCutlzkwi1d6c9ebOug1rDupzCYbdNI0uQrjkst9GUqprakLr9iSdgo1dAiyYbdN6bahSeAEWWPEE3dSw0qulSvBpcAI1oJ(AdVwcXLAfhOwwetGO3h1kjwRqh)R2lQLgR9Bs9Ws4HjuOEEzT53XwKwiFanTdxpUij4Ol0teOwv1siUWnzxTDcUwdscf6jYrdH2KD1QQwYRLfXei6D(fFMToA6Zg1eIfKNiHa9rTDcUwHDWW5OHGjhmCoQiY(hQpibwljKullIjq07CjzIJAZOhtEIec0h12j4Af2bdNJgcMCWW5OIi7FO(GeyTKqsTKx7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejeOpQTtW1kSdgohnem5GHZrfr2)q9bjWAjRwYQvvT0)wJNFh1rtBg9yYbIEVwv1s)BnUKmXrTz0Jjhi69Avvlas)Bn(fFMToA6Zg1eIfKde9ETQQ9L1AMObTfdGRe)IpZwhn9zJAcXcsDuQXOuKM6bDHEIaukJ6HLWdtOq9KFhBrAH8b00oC94IKGJUqprGAvv7lRLfgqx8JBa9ZUBwRQAzrmbIENljtCuBg9yYtKqG(O2obxRWoy4C0qWKdgohvez)d1hKaPEe2bdN6bnem5GHtDuQPdOin1d6c9ebOug1dlHhMqH6j)o2I0c5dOPD46XfjbhDHEIa1QQwwyaDXpUb0p7UzTQQLfXei6DobmZih6OPVijq)4jsiqFuBNGRvyhmCoAiyYbdNJkIS)H6dsG1QQwwetGO35x8z26OPpButiwqEIec0h12j4AjVwdscf6jYjItBMidra9fhHMUBTVvRWoy4C0qWKdgohvez)d1hKaR9TA7GAjRwv1YIyce9oxsM4O2m6XKNiHa9rTDcUwYR1GKqHEICI40MjYqeqFXrOP7w7B1kSdgohnem5GHZrfr2)q9bjWAFR2oOwYOEe2bdN6bnem5GHtDuQrHrrAQh0f6jcqPmQhHDWWPEKKjoQPLmflK6bahSeAEWWPEuMKPyH1cB1cpqh1EqcS2lQ9pWAV4iQvCGA7XATfdyTxe1siE3Az2sAHdQhwcpmHc1dlIjq078l(mBD00NnQjeliprbOBTQQL8AP)TgxsM4OMzlPfYhNWaPwLxRbjHc9e5xCeAcrrnZwslCuRQAzrmbIENljtCuBg9yYtKqG(O2obxlQiY(hQpibwRQAjex4MSRwLxRbjHc9e5IPMa6qIpHMqCrBYUAvvl9V1453rD00MrpMCGO3RLmQJsnVNI0upOl0teGszupSeEycfQhwetGO35x8z26OPpButiwqEIcq3Avvl51s)BnUKmXrnZwslKpoHbsTkVwdscf6jYV4i0eIIAMTKw4Owv1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprcb6JA7eCTOIi7FO(GeyTQQ1GKqHEI8dsG6VFWPwmRv51AqsOqpr(fhHMquudGtPRUfPwmRLmQhHDWWPEKKjoQPLmflK6OuJcMI0upOl0teGszupSeEycfQhwetGO35x8z26OPpButiwqEIcq3Avvl51s)BnUKmXrnZwslKpoHbsTkVwdscf6jYV4i0eIIAMTKw4Owv1sETVS2tMOF887OoAAZOhto6c9ebQLesQLfXei6DE(DuhnTz0Jjprcb6JAvETgKek0tKFXrOjef1a4u6QBrQZWSwYQvvTgKek0tKFqcu)9do1IzTkVwdscf6jYV4i0eIIAaCkD1Ti1IzTKr9iSdgo1JKmXrnTKPyHuhLAENuKM6bDHEIaukJ6HLWdtOq9aG0)wJNcau8tpmLeeTH)0XuOHt41LpoHbsTGRfaP)TgpfaO4NEykjiAd)PJPqdNWRlNquupoHbsTQQL8AP)TgxsM4O2m6XKde9ETKqsT0)wJljtCuBg9yYtKqG(O2obxRfdOwYQvvTKxl9V1453rD00MrpMCGO3RLesQL(3A887OoAAZOhtEIec0h12j4ATya1sg1JWoy4upsYeh10sMIfsDuQPJqrAQh0f6jcqPmQhwcpmHc1JbjHc9e5D4)XP)deqpmLeKAjHKAjVwaK(3A8uaGIF6HPKGOn8NoMcnCcVU8VzTQQfaP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdKA7SwaK(3A8uaGIF6HPKGOn8NoMcnCcVUCcrr94egi1sg1JWoy4upsYeh10tzCuhLA6quKM6bDHEIaukJ6HLWdtOq9q)BnUzId0zOoAAcOdW)M1QQwaK(3A8l(mBD00NnQjeli)BwRQAbq6FRXV4ZS1rtF2OMqSG8ejeOpQTtW1kSdgoxsM4OMEkJJJkIS)H6dsGupc7GHt9ijtCutpLXrDuQrj1srAQh0f6jcqPmQhMTaDQhLOEqjND1mBb6AyJ6H(3AC2eLKjJd6wAMT4oo5arVRIC6FRXLKjoQnJEm5FtsiH8xEYe9JhgW0m6Xeburo9V1453rD00MrpM8VjjKWIyce9ohnem5GHZtua6sgzKr9Ws4HjuOEaq6FRXV4ZS1rtF2OMqSG8VzTQQ9Kj6hxsM4Ogz2bhDHEIa1QQwYRL(3ACauoB6iDKde9ETKqsTc7Ggqn6ibeh1cUwLQLSAvvl51cG0)wJFXNzRJM(SrnHyb5jsiqFuRYRvyhmCUKmXrnbCmGtCWrfr2)q9bjWAjHKAzrmbIENBM4aDgQJMMa6a8ejeOpQLesQLfgqx8Jds3ekETKr9iSdgo1JKmXrnbCmGtCqDuQrjLOin1d6c9ebOug1JWoy4upsYeh1eWXaoXb1daoyj08GHt986WhFcS2ZgRfv0uCaeOwZ4q)GYSw6FRvRmeZAVOwpUANXaR1mo0pOmR1md2G6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvT0)wJJkAkoacOnJd9dkt(3K6OuJsgLI0upOl0teGszupc7GHt9ijtCutahd4ehupmBb6upkr9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQwYRL(3ACjzIJAZOht(3SwsiPw6FRXZVJ6OPnJEm5FZAjHKAbq6FRXV4ZS1rtF2OMqSG8ejeOpQv51kSdgoxsM4OMaogWjo4OIi7FO(GeyTKrDuQrPoGI0upOl0teGszupc7GHt9ijtCutahd4ehupmBb6upkr9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQw6FRXztusMmoOBXhNWaPwW1s)BnoBIsYKXbDloHOOECcdeQJsnkPWOin1d6c9ebOug1daoyj08GHt90XZEP7O2l7w7f1sloi1(6xxBlYAzrmbIEV2EOde9JAP)xTaFcZApBKOwyR2Zg7cAI1k0X)Q9IArfnHjs9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQw6FRXztusMmoOBXtKqG(O2obxl51sET0)wJZMOKmzCq3IpoHbsTVQAf2bdNljtCutahd4ehCurK9puFqcSwYQ9TATyaCcrXAjJ6HzlqN6rjQhHDWWPEKKjoQjGJbCIdQJsnk9Ekst9GUqprakLr9Ws4HjuOEiV2eBjoSf6jwljKu7lR9GmqGUvTKvRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtikQhNWaPwv1s)BnUKmXrTz0Jjhi69Avvlas)Bn(fFMToA6Zg1eIfKde9o1JWoy4upoE2yQpKWehh1rPgLuWuKM6bDHEIaukJ6HLWdtOq9q)BnUKmXrnZwslKpoHbsTDcUwdscf6jYV4i0eIIAMTKw4G6ryhmCQhjzIJ6iPPok1O07KI0upOl0teGszupSeEycfQhdscf6jYJ)nGaOoAAwetGO3h1QQwcXfUj7QTtW12HEp1JWoy4upJVjMEyqOok1OuhHI0upOl0teGszupSeEycfQh6FRXZ)e1rtF2jId(3Swv1s)BnUKmXrnZwslKpoHbsTkV2oG6ryhmCQhjzIJA6PmoQJsnk1HOin1d6c9ebOug1JWoy4upsYeh10sMIfs9aGdwcnpy4upkC9jmRLzlPfoQf2QThRTjZzT04m6R9SXAzHpW0awlH4sTNDId7ycuR4a1IgcMCWWRfoQDCW5S2WRLfXei6DQhwcpmHc1ZlRn)o2I0c5dOPD46XfjbhDHEIa1QQwdscf6jYJ)nGaOoAAwetGO3h1QQw6FRXLKjoQz2sAH8XjmqQfCT0)wJljtCuZSL0c5eII6XjmqQvvTNmr)4sYeh1rsZrxONiqTQQLfXei6DUKmXrDK08ejeOpQTtW1AXaQvvTeIlCt2vBNGRTdP2AvvllIjq07C0qWKdgoprcb6dQJsngvTuKM6bDHEIaukJ6HLWdtOq9KFhBrAH8b00oC94IKGJUqprGAvvRbjHc9e5X)gqauhnnlIjq07JAvvl9V14sYeh1mBjTq(4egi1cUw6FRXLKjoQz2sAHCcrr94egi1QQ2tMOFCjzIJ6iP5Ol0teOwv1YIyce9oxsM4OosAEIec0h12j4ATya1QQwcXfUj7QTtW12HuBTQQLfXei6DoAiyYbdNNiHa9rTDwBhOwQhHDWWPEKKjoQPLmflK6OuJrvII0upOl0teGszupc7GHt9ijtCutlzkwi1daoyj08GHt9OW1NWSwMTKw4OwyR2iPRfoQnrbOl1dlHhMqH6XGKqHEI84FdiaQJMMfXei69rTQQL(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoHOOECcdKAvv7jt0pUKmXrDK0C0f6jcuRQAzrmbIENljtCuhjnprcb6JA7eCTwmGAvvlH4c3KD12j4A7qQTwv1YIyce9ohnem5GHZtKqG(Owv1sETVS287ylslKpGM2HRhxKeC0f6jculjKul9V14dOPD46Xfjbprcb6JA7eCTk1rQLmQJsng1OuKM6bDHEIaukJ6ryhmCQhjzIJAAjtXcPEaWblHMhmCQNoozIJ1QmjtXcRDyh)jqTwOJPmNDRLgR9SXANY4QLjJR2Ov7zJ12XVsT9qhi6PEyj8Wekup0)wJljtCuBg9yY)M1QQw6FRXLKjoQnJEm5jsiqFuBNGR1IbuRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtikQhNWaPwv1sETSiMarVZrdbtoy48ejeOpQLesQn)o2I0c5sYeh12sseExo6c9ebQLmQJsngTdOin1d6c9ebOug1JWoy4upsYeh10sMIfs9aGdwcnpy4upDCYehRvzsMIfw7Wo(tGATqhtzo7wlnw7zJ1oLXvltgxTrR2ZgR9DfVsT9qhi6PEyj8Wekup0)wJNFh1rtBg9yY)M1QQw6FRXLKjoQnJEm5arVxRQAP)Tgp)oQJM2m6XKNiHa9rTDcUwlgqTQQL(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoHOOECcdKAvvl51YIyce9ohnem5GHZtKqG(OwsiP287ylslKljtCuBljr4D5Ol0teOwYOok1yufgfPPEqxONiaLYOEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6PJtM4yTktYuSWAh2XFculnw7zJ1oLXvltgxTrR2ZgRL0X1rRTh6arFTWwTWRw4OwpUA)deO2E4zx77kELAJS2o(vOEyj8Wekup0)wJljtCuBg9yYbIEVwv1s)BnE(DuhnTz0Jjhi69Avvlas)Bn(fFMToA6Zg1eIfK)nRvvTai9V14x8z26OPpButiwqEIec0h12j4ATya1QQw6FRXLKjoQz2sAH8XjmqQfCT0)wJljtCuZSL0c5eII6XjmqOok1y03trAQh0f6jcqPmQhHDWWPEKKjoQPLmflK6bahSeAEWWPEu4TrV2ZgR9K0cVAHJAHETOIi7FyTP4wyTIdu7zJjwlCulrKyTNT41gowl6irxJR9pWAPLmflSwzu7icVwzuB34xRTyaRf94BzxlZwslCu7f1AdVAL5Sw0rcioQf2Q9SXA74KjowRYccAjbiq)QDIwOdiz3AHJAXx9hAAIaupSeEycfQhdscf6jYrcZOhteqtlzkwyTQQL(3ACjzIJAMTKwiFCcdKAvo4AjVwHDqdOgDKaIJA7WQvPAjRwv1kSdAa1OJeqCuRYRvPAvvl9V14aOC20r6ihi6DQJsngvbtrAQh0f6jcqPmQhwcpmHc1JbjHc9e5iHz0JjcOPLmflSwv1s)BnUKmXrnZwslKpoHbsTDwl9V14sYeh1mBjTqoHOOECcdKAvvRWoObuJosaXrTkVwLQvvT0)wJdGYzthPJCGO3PEe2bdN6rsM4Ogv0Cgdy4uhLAm67KI0upc7GHt9ijtCutpLXr9GUqprakLrDuQXODekst9GUqprakLr9Ws4HjuOEmijuONip(3acG6OPzrmbIEFq9iSdgo1dAiyYbdN6OuJr7quKM6ryhmCQhjzIJAAjtXcPEqxONiaLYOoQJ6baBYFEuKMsnkrrAQhHDWWPEyX3pmhM4Cs9GUqprakLrDuQXOuKM6bDHEIaukJ6HLWdtOq9qETNmr)4OpHw2h6iahDHEIa1QQwcXfUj7QTtW12ruBTQQLqCHBYUAvo4AvWVVwYQLesQL8AFzTNmr)4OpHw2h6iahDHEIa1QQwcXfUj7QTtW12rEFTKr9iSdgo1dH4I2cjOok10buKM6bDHEIaukJ6HLWdtOq9q)BnUKmXrTz0Jj)Bs9iSdgo1JzCWWPok1OWOin1d6c9ebOug1dlHhMqH6j)o2I0c5hsygPm19sAYrxONiqTQQL(3ACurB5poy48VzTQQL8AzrmbIENljtCuBg9yYtua6wljKulDmg1QQ2g0Y(0jsiqFuBNGRvHP2AjJ6ryhmCQNdsG6EjnPok18Ekst9GUqprakLr9Ws4HjuOEO)TgxsM4O2m6XKde9ETQQL(3A887OoAAZOhtoq071QQwaK(3A8l(mBD00NnQjelihi6DQhHDWWPEMql7BO7W)aweOFuhLAuWuKM6bDHEIaukJ6HLWdtOq9q)BnUKmXrTz0Jjhi69Avvl9V1453rD00MrpMCGO3RvvTai9V14x8z26OPpButiwqoq07upc7GHt9qlw6OPVeYazqDuQ5DsrAQh0f6jcqPmQhwcpmHc1d9V14sYeh1MrpM8Vj1JWoy4up0yoWeeOBrDuQPJqrAQh0f6jcqPmQhwcpmHc1d9V14sYeh1MrpM8Vj1JWoy4up0Zia0TF2L6OuthII0upOl0teGszupSeEycfQh6FRXLKjoQnJEm5FtQhHDWWPEAWePNraqDuQrj1srAQh0f6jcqPmQhwcpmHc1d9V14sYeh1MrpM8Vj1JWoy4upIZWXLYuZK5K6OuJskrrAQh0f6jcqPmQhwcpmHc1d9V14sYeh1MrpM8Vj1JWoy4up)bQHhsmOok1OKrPin1d6c9ebOug1JWoy4uper4t4Pnt4GG6HLWdtOq9WcdOl(XbPBcfVwv1YIyce9oxsM4O2m6XKNiHa9rTDcUwLuBTQQLfXei6D(fFMToA6Zg1eIfKNiHa9rTDcUwLul1Jlei1dre(eEAZeoiOok1OuhqrAQh0f6jcqPmQhHDWWPEiIWNWtBMWbb1dlHhMqH65L1YcdOl(XbPBcfVwv1YIyce9oxsM4O2m6XKNiHa9rTDcUwfCTQQLfXei6D(fFMToA6Zg1eIfKNiHa9rTDcUwfm1Jlei1dre(eEAZeoiOok1OKcJI0upOl0teGszupc7GHt9ynfaOCro00cGfs9Ws4HjuOEO)TgxsM4O2m6XK)nRLesQLfXei6DUKmXrTz0Jjprcb6JAvo4AF)7RvvTai9V14x8z26OPpButiwq(3K6bBnKDAxiqQhRPaaLlYHMwaSqQJsnk9Ekst9GUqprakLr9iSdgo1dsy2nrzQJeWfNHupSeEycfQhwetGO35sYeh1MrpM8ejeOpQTtW1Q07RvvTSiMarVZV4ZS1rtF2OMqSG8ejeOpQTtW1Q07PECHaPEqcZUjktDKaU4mK6OuJskykst9GUqprakLr9iSdgo1dqIcqdMO2aog4K6HLWdtOq9WIyce9oxsM4O2m6XKNiHa9rTkhCTgvT1scj1(YAnijuONixm1HR)dSwW1QuTKqsTKx7bjWAbxRARvvTgKek0tK3GdBOBPdt0XSwW1QuTQQn)o2I0c5dOPD46XfjbhDHEIa1sg1Jlei1dqIcqdMO2aog4K6OuJsVtkst9GUqprakLr9iSdgo1Zi(tn0YHhMupSeEycfQhwetGO35sYeh1MrpM8ejeOpQv5GRTduBTKqsTVSwdscf6jYftD46)aRfCTkr94cbs9mI)udTC4Hj1rPgL6iuKM6bDHEIaukJ6ryhmCQhRzxtBD00YyajGt5GHt9Ws4HjuOEyrmbIENljtCuBg9yYtKqG(OwLdUwJQ2AjHKAFzTgKek0tKlM6W1)bwl4AvQwsiPwYR9GeyTGRvT1QQwdscf6jYBWHn0T0Hj6ywl4AvQwv1MFhBrAH8b00oC94IKGJUqprGAjJ6XfcK6XA210whnTmgqc4uoy4uhLAuQdrrAQh0f6jcqPmQhHDWWPEieMqNOEyJ4Pj(diJ6HLWdtOq9WIyce9oxsM4O2m6XKNiHa9rTDcU23xRQAjV2xwRbjHc9e5n4Wg6w6WeDmRfCTkvljKu7bjWAvETDGARLmQhxiqQhcHj0jQh2iEAI)aYOok1yu1srAQh0f6jcqPmQhHDWWPEieMqNOEyJ4Pj(diJ6HLWdtOq9WIyce9oxsM4O2m6XKNiHa9rTDcU23xRQAnijuONiVbh2q3shMOJzTGRvPAvvl9V1453rD00MrpM8VzTQQL(3A887OoAAZOhtEIec0h12j4AjVwLuBTDy1((AFv1MFhBrAH8b00oC94IKGJUqprGAjRwv1EqcS2oRTdul1Jlei1dHWe6e1dBepnXFazuhLAmQsuKM6bDHEIaukJ6ryhmCQNHTae9iGosAD00xKeOFupSeEycfQNdsG1cUw1wljKul51AqsOqprE8Vbea1rtZIyce9(Owv1sETKxllmGU4hhKUju8AvvllIjq078uaGIF6HPKGWtKqG(O2obxRrRvvTSiMarVZLKjoQnJEm5jsiqFuBNGR991QQwwetGO35x8z26OPpButiwqEIec0h12j4AFFTKvljKullIjq07CjzIJAZOhtEIec0h12j4AnATKqsTnOL9PtKqG(O2oRLfXei6DUKmXrTz0Jjprcb6JAjRwYOECHaPEg2cq0Ja6iP1rtFrsG(rDuQXOgLI0upOl0teGszupa4GLqZdgo1Z75k4AHJApBS2HjIa1gTApBS2N4pN4Dq3Q231NUBTMz0HJSdorQhxiqQNr8Nt8oOBPZpDxQhwcpmHc1d51AqsOqpr(bjq93p4ulM1(wTKxRWoy48uaGIF6HPKGWrfr2)q9bjWAFv1YcdOl(XbPBcfVwYQ9TAjVwHDWW5aOC20r6ihvez)d1hKaR9vvllmGU4h3rwgZibQLSAFRwHDWW5x8z26OPpButiwqoQiY(hQpibwBN1EsAHhhaooXzyTKQ23ZvW1swTQQL8AnijuONi3wmG6WeDeOwsiPwYRLfgqx8Jds3ekETQQn)o2I0c5sYeh1qVbD41LJUqprGAjRwYQvvTNKw4XbGJtCgwRYR1OVN6ryhmCQNr8Nt8oOBPZpDxQJsngTdOin1d6c9ebOug1dlHhMqH6ryh0aQrhjG4OwLdUwdscf6jYLa1NKw4PzX3pQNXLq2rPgLOEe2bdN6HjZPwyhmC9eooQNjCCAxiqQhjqQJsngvHrrAQh0f6jcqPmQhwcpmHc1dlmGU4hhKUju8AvvB(DSfPfYLKjoQTLKi8UC0f6jcq9mUeYok1Oe1JWoy4upmzo1c7GHRNWXr9mHJt7cbs9yljr4DPok1y03trAQh0f6jcqPmQhwcpmHc1JbjHc9e52IbuhMOJa1cUw1wRQAnijuONiVbh2q3shMOJzTQQ9L1sETSWa6IFCq6MqXRvvT53XwKwixsM4O2wsIW7YrxONiqTKr9mUeYok1Oe1JWoy4upmzo1c7GHRNWXr9mHJt7cbs90GdBOBPdt0XK6OuJrvWuKM6bDHEIaukJ6HLWdtOq9yqsOqprUTya1Hj6iqTGRvT1QQ2xwl51YcdOl(XbPBcfVwv1MFhBrAHCjzIJABjjcVlhDHEIa1sg1Z4si7OuJsupc7GHt9WK5ulSdgUEchh1ZeooTlei1tyIoMuhLAm67KI0upOl0teGszupSeEycfQNxwl51YcdOl(XbPBcfVwv1MFhBrAHCjzIJABjjcVlhDHEIa1sg1Z4si7OuJsupc7GHt9WK5ulSdgUEchh1ZeooTlei1dlIjq07dQJsngTJqrAQh0f6jcqPmQhwcpmHc1JbjHc9e5nOltn9p9AbxRARvvTVSwYRLfgqx8Jds3ekETQQn)o2I0c5sYeh12sseExo6c9ebQLmQNXLq2rPgLOEe2bdN6HjZPwyhmC9eooQNjCCAxiqQNmo5GHtDuQXODikst9GUqprakLr9Ws4HjuOEmijuONiVbDzQP)Pxl4AvQwv1(YAjVwwyaDXpoiDtO41QQ287ylslKljtCuBljr4D5Ol0teOwYOEgxczhLAuI6ryhmCQhMmNAHDWW1t44OEMWXPDHaPEAqxMA6F6uh1r9yMiliOLJI0uQrjkst9iSdgo1JKmXrn0pCor2r9GUqprakLrDuQXOuKM6ryhmCQNXNGiCTKmXrDtiGtOKupOl0teGszuhLA6akst9iSdgo1dl8o8FIAcXfTfsq9GUqprakLrDuQrHrrAQhHDWWPEiGzgPgsiwi1d6c9ebOug1rPM3trAQh0f6jcqPmQhwcpmHc1Zi(tAOdWnet5GtupIPb0po6c9ebQLesQDe)jn0b4M)X9NOgZV5bdNJUqpraQhHDWWPEAtCyZsPDuhLAuWuKM6bDHEIaukJ6HLWdtOq9WcdOl(XbPBcfVwv1MFhBrAHCjzIJABjjcVlhDHEIa1QQww4aF4XLKjoQnZaaA1LJUqprGAvvRbjHc9e5YSx6o0JUotZIyce9(Owv1kSdAa1OJeqCuBN1AqsOqprUeO(K0cpnl((r9iSdgo1t(DuhnTz0Jj1rPM3jfPPEqxONiaLYOEyj8WekupVSwdscf6jYnt08pNA0qul4AvQwv1MFhBrAHCa4GbnNqxYUAwqqioahDHEIaupc7GHt90YyC0X8Ook10rOin1d6c9ebOug1dlHhMqH65L1AqsOqprUzIM)5uJgIAbxRs1QQ2xwB(DSfPfYbGdg0CcDj7QzbbH4aC0f6jcuRQAjV2xwllmGU4h3a6ND3SwsiPwdscf6jYBWHn0T0Hj6ywlzupc7GHt9ijtCutpLXrDuQPdrrAQh0f6jcqPmQhwcpmHc1ZlR1GKqHEICZen)ZPgne1cUwLQvvTVS287ylslKdahmO5e6s2vZcccXb4Ol0teOwv1YcdOl(XnG(z3nRvvTVSwdscf6jYBWHn0T0Hj6ys9iSdgo1dbmZih6OPVijq)Ook1OKAPin1d6c9ebOug1dlHhMqH6XGKqHEICZen)ZPgne1cUwLOEe2bdN6bnem5GHtDuh1JeifPPuJsuKM6bDHEIaukJ6HLWdtOq9KFhBrAHCa4GbnNqxYUAwqqioahDHEIa1QQwwetGO350)wtdahmO5e6s2vZcccXb4jkaDRvvT0)wJdahmO5e6s2vZcccXb0Tmghhi69Avvl51s)BnUKmXrTz0Jjhi69Avvl9V1453rD00MrpMCGO3RvvTai9V14x8z26OPpButiwqoq071swTQQLfXei6D(fFMToA6Zg1eIfKNiHa9rTGRvT1QQwYRL(3ACjzIJAMTKwiFCcdKA7eCTgKek0tKlbQV4i0eIIAMTKw4Owv1sETKx7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejeOpQTtW1AXaQvvTSiMarVZLKjoQnJEm5jsiqFuRYR1GKqHEI8locnHOOgaNsxDlsTywlz1scj1sETVS2tMOF887OoAAZOhto6c9ebQvvTSiMarVZLKjoQnJEm5jsiqFuRYR1GKqHEI8locnHOOgaNsxDlsTywlz1scj1YIyce9oxsM4O2m6XKNiHa9rTDcUwlgqTKvlzupc7GHt90YyC0X8Ook1yukst9GUqprakLr9Ws4HjuOEiV287ylslKdahmO5e6s2vZcccXb4Ol0teOwv1YIyce9oN(3AAa4GbnNqxYUAwqqioaprbOBTQQL(3ACa4GbnNqxYUAwqqioGUbtKde9ETQQ1mrdAlgaxjElJXrhZRwYQLesQL8AZVJTiTqoaCWGMtOlzxnliiehGJUqprGAvv7bjWAbxRARLmQhHDWWPEAWe10tzCuhLA6akst9GUqprakLr9Ws4HjuOEYVJTiTqUvchZUAidYMihDHEIa1QQwwetGO35sYeh1MrpM8ejeOpQv512bQTwv1YIyce9o)IpZwhn9zJAcXcYtKqG(OwW1Q2Avvl51s)BnUKmXrnZwslKpoHbsTDcUwdscf6jYLa1xCeAcrrnZwslCuRQAjVwYR9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIec0h12j4ATya1QQwwetGO35sYeh1MrpM8ejeOpQv51AqsOqpr(fhHMquudGtPRUfPwmRLSAjHKAjV2xw7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO35sYeh1MrpM8ejeOpQv51AqsOqpr(fhHMquudGtPRUfPwmRLSAjHKAzrmbIENljtCuBg9yYtKqG(O2obxRfdOwYQLmQhHDWWPEAzmoThgeQJsnkmkst9GUqprakLr9Ws4HjuOEYVJTiTqUvchZUAidYMihDHEIa1QQwwetGO35sYeh1MrpM8ejeOpQfCTQTwv1sETKxl51YIyce9o)IpZwhn9zJAcXcYtKqG(OwLxRbjHc9e5IPMquudGtPRUfP(IJOwv1s)BnUKmXrnZwslKpoHbsTGRL(3ACjzIJAMTKwiNquupoHbsTKvljKul51YIyce9o)IpZwhn9zJAcXcYtKqG(OwW1Q2Avvl9V14sYeh1mBjTq(4egi12j4AnijuONixcuFXrOjef1mBjTWrTKvlz1QQw6FRXZVJ6OPnJEm5arVxlzupc7GHt90YyCApmiuhLAEpfPPEqxONiaLYOEe2bdN6rsM4OMaogWjoOEy2c0PEuI6HLWdtOq9WcdOl(XbPBcfVwv1MFhBrAHCjzIJABjjcVlhDHEIa1QQw6FRXLKjoQTLKi8U8XjmqQTZAv691QQwwetGO35Paaf)0dtjbHNiHa9rTDcUwdscf6jYTLKi8U6Xjmq0hKaR9TArfr2)q9bjWAvvllIjq078l(mBD00NnQjeliprcb6JA7eCTgKek0tKBljr4D1JtyGOpibw7B1IkIS)H6dsG1(wTc7GHZtbak(PhMscchvez)d1hKaRvvTSiMarVZLKjoQnJEm5jsiqFuBNGR1GKqHEICBjjcVRECcde9bjWAFRwurK9puFqcS23QvyhmCEkaqXp9Wusq4OIi7FO(GeyTVvRWoy48l(mBD00NnQjelihvez)d1hKaPok1OGPin1d6c9ebOug1JWoy4upsYeh1eWXaoXb1dZwGo1JsupSeEycfQhwyaDXpUb0p7UzTQQn)o2I0c5sYeh1qVbD41LJUqprGAvvl9V14sYeh12sseEx(4egi12zTk9(AvvllIjq078l(mBD00NnQjeliprcb6JA7eCTgKek0tKBljr4D1JtyGOpibw7B1IkIS)H6dsG1QQwwetGO35sYeh1MrpM8ejeOpQTtW1AqsOqprUTKeH3vpoHbI(GeyTVvlQiY(hQpibw7B1kSdgo)IpZwhn9zJAcXcYrfr2)q9bjqQJsnVtkst9GUqprakLr9Ws4HjuOEyHb0f)4gq)S7M1QQ2tMOFCjzIJAKzhC0f6jcuRQApibwBN1QKARvvTSiMarVZjGzg5qhn9fjb6hprcb6JAvvl9V14Sjkjtgh0T4JtyGuBN12bupc7GHt9ijtCutpLXrDuQPJqrAQh0f6jcqPmQhHDWWPEgXFoX7GULo)0DPEyj8Wekup53XwKwiFanTdxpUij4Ol0teOwv1AMObTfdGRehnem5GHt94cbs9mI)CI3bDlD(P7sDuQPdrrAQh0f6jcqPmQhwcpmHc1t(DSfPfYhqt7W1Jlsco6c9ebQvvTMjAqBXa4kXrdbtoy4upc7GHt9CXNzRJM(SrnHybPok1OKAPin1d6c9ebOug1dlHhMqH6j)o2I0c5dOPD46XfjbhDHEIa1QQwYR1mrdAlgaxjoAiyYbdVwsiPwZenOTyaCL4x8z26OPpButiwWAjJ6ryhmCQhjzIJAZOhtQJsnkPefPPEqxONiaLYOEyj8Wekup53XwKwixsM4Og6nOdVUC0f6jcuRQAzrmbIENFXNzRJM(SrnHyb5jsiqFuBNGRvj1wRQAzrmbIENljtCuBg9yYtKqG(O2obxRsVN6ryhmCQhcyMro0rtFrsG(rDuQrjJsrAQh0f6jcqPmQhwcpmHc1dlIjq07CjzIJAZOhtEIec0h12j4A7i1QQwwetGO35x8z26OPpButiwqEIec0h12j4A7i1QQwYRL(3ACjzIJAMTKwiFCcdKA7eCTgKek0tKlbQV4i0eIIAMTKw4Owv1sETKx7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejeOpQTtW1AXaQvvTSiMarVZLKjoQnJEm5jsiqFuRYR991swTKqsTKx7lR9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07CjzIJAZOhtEIec0h1Q8AFFTKvljKullIjq07CjzIJAZOhtEIec0h12j4ATya1swTKr9iSdgo1dbmZih6OPVijq)Ook1OuhqrAQh0f6jcqPmQhwcpmHc1ZbjWAvETDGARvvT53XwKwiFanTdxpUij4Ol0teOwv1YcdOl(XnG(z3nRvvTMjAqBXa4kXjGzg5qhn9fjb6h1JWoy4upOHGjhmCQJsnkPWOin1d6c9ebOug1dlHhMqH65GeyTkV2oqT1QQ287ylslKpGM2HRhxKeC0f6jcuRQAP)TgxsM4OMzlPfYhNWaP2obxRbjHc9e5sG6locnHOOMzlPfoQvvTSiMarVZV4ZS1rtF2OMqSG8ejeOpQfCTQTwv1YIyce9oxsM4O2m6XKNiHa9rTDcUwlga1JWoy4upOHGjhmCQJsnk9Ekst9GUqprakLr9iSdgo1dAiyYbdN6b6hM5380Wg1d9V14dOPD46XfjbFCcdeW0)wJpGM2HRhxKeCcrr94egiupq)Wm)MNgsqGaq5qQhLOEyj8WekuphKaRv512bQTwv1MFhBrAH8b00oC94IKGJUqprGAvvllIjq07CjzIJAZOhtEIec0h1cUw1wRQAjVwYRL8AzrmbIENFXNzRJM(SrnHyb5jsiqFuRYR1GKqHEICXutikQbWP0v3IuFXruRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtikQhNWaPwYQLesQL8AzrmbIENFXNzRJM(SrnHyb5jsiqFul4AvBTQQL(3ACjzIJAMTKwiFCcdKA7eCTgKek0tKlbQV4i0eIIAMTKw4OwYQLSAvvl9V1453rD00MrpMCGO3RLmQJsnkPGPin1d6c9ebOug1dlHhMqH6HfXei6D(fFMToA6Zg1eIfKNiHa9rTDwlQiY(hQpibwRQAjVwYR9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07887OoAAZOhtEIec0h12j4ATya1QQwwetGO35sYeh1MrpM8ejeOpQv51AqsOqpr(fhHMquudGtPRUfPwmRLSAjHKAjV2xw7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO35sYeh1MrpM8ejeOpQv51AqsOqpr(fhHMquudGtPRUfPwmRLSAjHKAzrmbIENljtCuBg9yYtKqG(O2obxRfdOwYOEe2bdN6jfaO4NEykjiuhLAu6DsrAQh0f6jcqPmQhwcpmHc1dlIjq07CjzIJAZOhtEIec0h12zTOIi7FO(GeyTQQL8AjVwYRLfXei6D(fFMToA6Zg1eIfKNiHa9rTkVwdscf6jYftnHOOgaNsxDls9fhrTQQL(3ACjzIJAMTKwiFCcdKAbxl9V14sYeh1mBjTqoHOOECcdKAjRwsiPwYRLfXei6D(fFMToA6Zg1eIfKNiHa9rTGRvT1QQw6FRXLKjoQz2sAH8XjmqQTtW1AqsOqprUeO(IJqtikQz2sAHJAjRwYQvvT0)wJNFh1rtBg9yYbIEVwYOEe2bdN6jfaO4NEykjiuhLAuQJqrAQh0f6jcqPmQhwcpmHc1dlIjq07CjzIJAZOhtEIec0h1cUw1wRQAjVwYRL8AzrmbIENFXNzRJM(SrnHyb5jsiqFuRYR1GKqHEICXutikQbWP0v3IuFXruRQAP)TgxsM4OMzlPfYhNWaPwW1s)BnUKmXrnZwslKtikQhNWaPwYQLesQL8AzrmbIENFXNzRJM(SrnHyb5jsiqFul4AvBTQQL(3ACjzIJAMTKwiFCcdKA7eCTgKek0tKlbQV4i0eIIAMTKw4OwYQLSAvvl9V1453rD00MrpMCGO3RLmQhHDWWPEaq5SPJ0rQJsnk1HOin1d6c9ebOug1JWoy4upJ4pN4Dq3sNF6UupSeEycfQhYRL(3ACjzIJAMTKwiFCcdKA7eCTgKek0tKlbQV4i0eIIAMTKw4OwsiPwZenOTyaCL4Paaf)0dtjbPwYQvvTKxl51EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DE(DuhnTz0Jjprcb6JA7eCTwmGAvvllIjq07CjzIJAZOhtEIec0h1Q8AnijuONi)IJqtikQbWP0v3IulM1swTKqsTKx7lR9Kj6hp)oQJM2m6XKJUqprGAvvllIjq07CjzIJAZOhtEIec0h1Q8AnijuONi)IJqtikQbWP0v3IulM1swTKqsTSiMarVZLKjoQnJEm5jsiqFuBNGR1IbulzupUqGupJ4pN4Dq3sNF6UuhLAmQAPin1d6c9ebOug1dlHhMqH6Hfgqx8JBa9ZUBwRQAZVJTiTqUKmXrn0BqhED5Ol0teOwv1YIyce9oNaMzKdD00xKeOF8ejeOpQTtW1(E1s9iSdgo1ZfFMToA6Zg1eIfK6OuJrvII0upOl0teGszupSeEycfQhwyaDXpUb0p7UzTQQn)o2I0c5sYeh1qVbD41LJUqprGAvvl9V14eWmJCOJM(IKa9JNiHa9rTDcUwJQ2AvvllIjq07CjzIJAZOhtEIec0h12j4ATyaupc7GHt9CXNzRJM(SrnHybPok1yuJsrAQh0f6jcqPmQhwcpmHc1d51s)BnUKmXrnZwslKpoHbsTDcUwdscf6jYLa1xCeAcrrnZwslCuljKuRzIg0wmaUs8uaGIF6HPKGulz1QQwYRL8ApzI(XZVJ6OPnJEm5Ol0teOwv1YIyce9op)oQJM2m6XKNiHa9rTDcUwlgqTQQLfXei6DUKmXrTz0Jjprcb6JAvETgKek0tKFXrOjef1a4u6QBrQfZAjRwsiPwYR9L1EYe9JNFh1rtBg9yYrxONiqTQQLfXei6DUKmXrTz0Jjprcb6JAvETgKek0tKFXrOjef1a4u6QBrQfZAjRwsiPwwetGO35sYeh1MrpM8ejeOpQTtW1AXaQLmQhHDWWPEU4ZS1rtF2OMqSGuhLAmAhqrAQh0f6jcqPmQhwcpmHc1d51sETSiMarVZV4ZS1rtF2OMqSG8ejeOpQv51AqsOqprUyQjef1a4u6QBrQV4iQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjef1JtyGulz1scj1sETSiMarVZV4ZS1rtF2OMqSG8ejeOpQfCTQTwv1s)BnUKmXrnZwslKpoHbsTDcUwdscf6jYLa1xCeAcrrnZwslCulz1swTQQL(3A887OoAAZOhtoq07upc7GHt9ijtCuBg9ysDuQXOkmkst9GUqprakLr9Ws4HjuOEO)Tgp)oQJM2m6XKde9ETQQL8AjVwwetGO35x8z26OPpButiwqEIec0h1Q8AnQARvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjef1JtyGulz1scj1sETSiMarVZpG4ZS1rtF2OMqSG8ejeOpQfCTQTwv1s)BnUKmXrnZwslKpoHbsTDcUwdscf6jYLa1xCeAcrrnZwslCulz1swTQQL8AzrmbIENljtCuBg9yYtKqG(OwLxRsgTwsiPwaK(3A8l(mBD00NnQjeli)Bwlzupc7GHt9KFh1rtBg9ysDuQXOVNI0upOl0teGszupSeEycfQhwetGO35sYeh1rsZtKqG(OwLx77RLesQ9L1EYe9JljtCuhjnhDHEIaupc7GHt9mSHTd6wAZOhtQJsngvbtrAQh0f6jcqPmQhwcpmHc1dlmGU4hhKUju8AvvB(DSfPfYLKjoQHEd6WRlhDHEIa1QQw6FRXLKjoQnJEm5FZAvvlas)BnEkaqXp9Wusq0g(thtHgoHxx(4egi1cUwfwTQQ1mrdAlgaxjUKmXrDK01QQwHDqdOgDKaIJA7S23zTQQ9L1MFhBrAHCBjjchY0iZo4Ol0teG6ryhmCQhjzIJA6PmoQJsng9DsrAQh0f6jcqPmQhwcpmHc1dlmGU4hhKUju8AvvB(DSfPfYLKjoQHEd6WRlhDHEIa1QQw6FRXLKjoQnJEm5FZAvvlas)BnEkaqXp9Wusq0g(thtHgoHxx(4egi1cUwfg1JWoy4upsYeh10sMIfsDuQXODekst9GUqprakLr9Ws4HjuOEyHb0f)4G0nHIxRQAZVJTiTqUKmXrn0BqhED5Ol0teOwv1s)BnUKmXrTz0Jj)BwRQAjVwG44Paaf)0dtjbHNiHa9rTkVwfCTKqsTai9V14Paaf)0dtjbrB4pDmfA4eED5FZAjRwv1cG0)wJNcau8tpmLeeTH)0XuOHt41LpoHbsTDwRcRwv1kSdAa1OJeqCuBN1(EQhHDWWPEKKjoQPNY4Ook1y0oefPPEqxONiaLYOEyj8WekupSWa6IFCq6MqXRvvT53XwKwixsM4O2wsIW7YrxONiqTQQL(3ACjzIJAZOht(3Swv1cG0)wJNcau8tpmLeeTH)0XuOHt41LpoHbsTGRTdOEe2bdN6rsM4OosAQJsnDGAPin1d6c9ebOug1dlHhMqH6Hfgqx8Jds3ekETQQn)o2I0c5sYeh12sseExo6c9ebQvvT0)wJljtCuBg9yY)M1QQwaK(3A8uaGIF6HPKGOn8NoMcnCcVU8XjmqQfCTgL6ryhmCQhjzIJAAjtXcPok10bkrrAQh0f6jcqPmQhwcpmHc1dlmGU4hhKUju8AvvB(DSfPfYLKjoQTLKi8UC0f6jcuRQAP)TgxsM4O2m6XK)nRvvTMjAqBXa4gLNcau8tpmLeKAvvRWoObuJosaXrTkV2oG6ryhmCQhjzIJAurZzmGHtDuQPdmkfPPEqxONiaLYOEyj8WekupSWa6IFCq6MqXRvvT53XwKwixsM4O2wsIW7YrxONiqTQQL(3ACjzIJAZOht(3Swv1cG0)wJNcau8tpmLeeTH)0XuOHt41LpoHbsTGRvPAvvRWoObuJosaXrTkV2oG6ryhmCQhjzIJAurZzmGHtDuQPd6akst9GUqprakLr9Ws4HjuOEO)TghaLZMosh5FZAvvlas)Bn(fFMToA6Zg1eIfK)nRvvTai9V14x8z26OPpButiwqEIec0h12j4AP)Tg3mXb6muhnnb0b4eII6XjmqQ9vvRWoy4CjzIJA6PmooQiY(hQpibwRQAjVwYR9Kj6hpXr4IZqo6c9ebQvvTc7Ggqn6ibeh12zTkSAjRwsiPwHDqdOgDKaIJA7S23xlz1QQwYR9L1MFhBrAHCjzIJA6GGwsac0po6c9ebQLesQ9K0cpUnkZZMBYUAvETDW7RLmQhHDWWPEmtCGod1rttaDaQJsnDGcJI0upOl0teGszupSeEycfQh6FRXbq5SPJ0r(3Swv1sETKx7jt0pEIJWfNHC0f6jcuRQAf2bnGA0rcioQTZAvy1swTKqsTc7Ggqn6ibeh12zTVVwYQvvTKx7lRn)o2I0c5sYeh10bbTKaeOFC0f6jculjKu7jPfECBuMNn3KD1Q8A7G3xlzupc7GHt9ijtCutpLXrDuQPdEpfPPEe2bdN6z8nX0ddc1d6c9ebOug1rPMoqbtrAQh0f6jcqPmQhwcpmHc1d9V14sYeh1mBjTq(4egi1QCW1sETc7Ggqn6ibeh12HvRs1swTQQn)o2I0c5sYeh10bbTKaeOFC0f6jcuRQApjTWJBJY8S5MSR2oRTdEp1JWoy4upsYeh10sMIfsDuQPdENuKM6bDHEIaukJ6HLWdtOq9q)BnUKmXrnZwslKpoHbsTGRL(3ACjzIJAMTKwiNquupoHbc1JWoy4upsYeh10sMIfsDuQPd6iuKM6bDHEIaukJ6HLWdtOq9q)BnUKmXrnZwslKpoHbsTGRvT1QQwYRLfXei6DUKmXrTz0Jjprcb6JAvETk9(AjHKAFzTKxllmGU4hhKUju8AvvB(DSfPfYLKjoQTLKi8UC0f6jculz1sg1JWoy4upsYeh1rstDuQPd6quKM6bDHEIaukJ6HLWdtOq9qETj2sCyl0tSwsiP2xw7bzGaDRAjRwv1s)BnUKmXrnZwslKpoHbsTGRL(3ACjzIJAMTKwiNquupoHbc1JWoy4upoE2yQpKWehh1rPgfMAPin1d6c9ebOug1dlHhMqH6H(3AC2eLKjJd6w8ef2vRQAZVJTiTqUKmXrTTKeH3LJUqprGAvvl51sETNmr)4cH5e2Gm5GHZrxONiqTQQvyh0aQrhjG4O2oRTJulz1scj1kSdAa1OJeqCuBN1((AjJ6ryhmCQhjzIJAc4yaN4G6OuJctjkst9GUqprakLr9Ws4HjuOEO)TgNnrjzY4GUfprHD1QQ2tMOFCjzIJAKzhC0f6jcuRQAbq6FRXV4ZS1rtF2OMqSG8VzTQQL8ApzI(XfcZjSbzYbdNJUqprGAjHKAf2bnGA0rcioQTZA7q1sg1JWoy4upsYeh1eWXaoXb1rPgfMrPin1d6c9ebOug1dlHhMqH6H(3AC2eLKjJd6w8ef2vRQApzI(XfcZjSbzYbdNJUqprGAvvRWoObuJosaXrTDwRcJ6ryhmCQhjzIJAc4yaN4G6OuJcRdOin1d6c9ebOug1dlHhMqH6H(3ACjzIJAMTKwiFCcdKA7Sw6FRXLKjoQz2sAHCcrr94egiupc7GHt9ijtCuJkAoJbmCQJsnkmfgfPPEqxONiaLYOEyj8Wekup0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjef1JtyGuRQAnt0G2IbWvIljtCutlzkwi1JWoy4upsYeh1OIMZyadN6OoQhwetGO3huKMsnkrrAQh0f6jcqPmQhHDWWPEAzmoThgeQhaCWsO5bdN65vsyKWdQWbR9pGUvTwjCm7wlKbztS2E4zxRyYR9DpWAHxT9WZU2loIAJZgZE4a5upSeEycfQN87ylslKBLWXSRgYGSjYrxONiqTQQLfXei6DUKmXrTz0Jjprcb6JAvETDGARvvTSiMarVZV4ZS1rtF2OMqSG8efGU1QQwYRL(3ACjzIJAMTKwiFCcdKA7eCTgKek0tKFXrOjef1mBjTWrTQQL8AjV2tMOF887OoAAZOhto6c9ebQvvTSiMarVZZVJ6OPnJEm5jsiqFuBNGR1IbuRQAzrmbIENljtCuBg9yYtKqG(OwLxRbjHc9e5xCeAcrrnaoLU6wKAXSwYQLesQL8AFzTNmr)453rD00MrpMC0f6jcuRQAzrmbIENljtCuBg9yYtKqG(OwLxRbjHc9e5xCeAcrrnaoLU6wKAXSwYQLesQLfXei6DUKmXrTz0Jjprcb6JA7eCTwmGAjRwYOok1yukst9GUqprakLr9Ws4HjuOEYVJTiTqUvchZUAidYMihDHEIa1QQwwetGO35sYeh1MrpM8efGU1QQwYR9L1EYe9JJ(eAzFOJaC0f6jculjKul51EYe9JJ(eAzFOJaC0f6jcuRQAjex4MSRwLdU23PARLSAjRwv1sETKxllIjq078l(mBD00NnQjeliprcb6JAvETkP2Avvl9V14sYeh1mBjTq(4egi1cUw6FRXLKjoQz2sAHCcrr94egi1swTKqsTKxllIjq078l(mBD00NnQjeliprcb6JAbxRARvvT0)wJljtCuZSL0c5JtyGul4AvBTKvlz1QQw6FRXZVJ6OPnJEm5arVxRQAjex4MSRwLdUwdscf6jYftnb0HeFcnH4I2KDupc7GHt90YyCApmiuhLA6akst9GUqprakLr9Ws4HjuOEYVJTiTqoaCWGMtOlzxnliiehGJUqprGAvvllIjq07C6FRPbGdg0CcDj7QzbbH4a8efGU1QQw6FRXbGdg0CcDj7QzbbH4a6wgJJde9ETQQL8AP)TgxsM4O2m6XKde9ETQQL(3A887OoAAZOhtoq071QQwaK(3A8l(mBD00NnQjelihi69AjRwv1YIyce9o)IpZwhn9zJAcXcYtKqG(OwW1Q2Avvl51s)BnUKmXrnZwslKpoHbsTDcUwdscf6jYV4i0eIIAMTKw4Owv1sETKx7jt0pE(DuhnTz0JjhDHEIa1QQwwetGO3553rD00MrpM8ejeOpQTtW1AXaQvvTSiMarVZLKjoQnJEm5jsiqFuRYR1GKqHEI8locnHOOgaNsxDlsTywlz1scj1sETVS2tMOF887OoAAZOhto6c9ebQvvTSiMarVZLKjoQnJEm5jsiqFuRYR1GKqHEI8locnHOOgaNsxDlsTywlz1scj1YIyce9oxsM4O2m6XKNiHa9rTDcUwlgqTKvlzupc7GHt90YyC0X8Ook1OWOin1d6c9ebOug1dlHhMqH6j)o2I0c5aWbdAoHUKD1SGGqCao6c9ebQvvTSiMarVZP)TMgaoyqZj0LSRMfeeIdWtua6wRQAP)TghaoyqZj0LSRMfeeIdOBWe5arVxRQAnt0G2IbWvI3YyC0X8OEe2bdN6PbtutpLXrDuQ59uKM6bDHEIaukJ6ryhmCQhcyMro0rtFrsG(r9aGdwcnpy4upVIaZA7ObPRThE212XVsTWwTWd0rTSGa6w1(nRDeHZR9D0QfE12dNZAPXA)deO2E4zxlPJRJACTmzC1cVAhtOL9n7wln2IePEyj8WekupKx7lRn)o2I0c5dOPD46XfjbhDHEIa1scj1s)Bn(aAAhUECrsW)M1swTQQLfXei6D(fFMToA6Zg1eIfKNiHa9rTDwRbjHc9e5eXPntKHiG(IJqt3TwsiPwYR1GKqHEI8dsG6VFWPwmRv51AqsOqprorCAcrrnaoLU6wKAXSwv1YIyce9o)IpZwhn9zJAcXcYtKqG(OwLxRbjHc9e5eXPjef1a4u6QBrQV4iQLmQJsnkykst9GUqprakLr9Ws4HjuOEyrmbIENljtCuBg9yYtua6wRQAjV2xw7jt0po6tOL9HocWrxONiqTKqsTKx7jt0po6tOL9HocWrxONiqTQQLqCHBYUAvo4AFNQTwYQLSAvvl51sETSiMarVZV4ZS1rtF2OMqSG8ejeOpQv51AqsOqprUyQjef1a4u6QBrQV4iQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjef1JtyGulz1scj1sETSiMarVZV4ZS1rtF2OMqSG8ejeOpQfCTQTwv1s)BnUKmXrnZwslKpoHbsTGRvT1swTKvRQAP)Tgp)oQJM2m6XKde9ETQQLqCHBYUAvo4AnijuONixm1eqhs8j0eIlAt2r9iSdgo1dbmZih6OPVijq)Ook18oPin1d6c9ebOug1dlHhMqH6XGKqHEI84FdiaQJMMfXei69rTQQL8AhXFsdDaUHykhCI6rmnG(XrxONiqTKqsTJ4pPHoa38pU)e1y(npy4C0f6jculzupc7GHt90M4WMLs7Ook10rOin1d6c9ebOug1JWoy4upaOC20r6i1daoyj08GHt90XZEP7O2)aRfaLZMoshRThE21kM8AFhTAV4iQfoQnrbOBTYO2EConUwcbeS2XpXAVOwMmUAHxT0ylsS2loco1dlHhMqH6HfXei6D(fFMToA6Zg1eIfKNOa0Twv1s)BnUKmXrnZwslKpoHbsTDcUwdscf6jYV4i0eIIAMTKw4Owv1YIyce9oxsM4O2m6XKNiHa9rTDcUwlga1rPMoefPPEqxONiaLYOEyj8WekupSiMarVZLKjoQnJEm5jkaDRvvTKx7lR9Kj6hh9j0Y(qhb4Ol0teOwsiPwYR9Kj6hh9j0Y(qhb4Ol0teOwv1siUWnzxTkhCTVt1wlz1swTQQL8AjVwwetGO35x8z26OPpButiwqEIec0h1Q8AvsT1QQw6FRXLKjoQz2sAH8XjmqQfCT0)wJljtCuZSL0c5eII6XjmqQLSAjHKAjVwwetGO35x8z26OPpButiwqEIcq3Avvl9V14sYeh1mBjTq(4egi1cUw1wlz1swTQQL(3A887OoAAZOhtoq071QQwcXfUj7Qv5GR1GKqHEICXutaDiXNqtiUOnzh1JWoy4upaOC20r6i1rPgLulfPPEqxONiaLYOEe2bdN6jfaO4NEykjiupa4GLqZdgo1Z7EG1omLeKAHTAV4iQvCGAfZALeRn8Aza1koqT9Hd6vlnw73S2wK1od3cZApBXR9SXAjefRfaNsxJRLqab6w1o(jwBpwRTyaRvUANOmUAV(OwjzIJ1YSL0ch1koqTNTC1EXruBVmCqVA7W)JR2)ab4upSeEycfQhwetGO35x8z26OPpButiwqEIec0h1Q8AnijuONiphAcrrnaoLU6wK6loIAvvllIjq07CjzIJAZOhtEIec0h1Q8AnijuONiphAcrrnaoLU6wKAXSwv1sETNmr)453rD00MrpMC0f6jcuRQAjVwwetGO3553rD00MrpM8ejeOpQTZArfr2)q9bjWAjHKAzrmbIENNFh1rtBg9yYtKqG(OwLxRbjHc9e55qtikQbWP0v3IuNHzTKvljKu7lR9Kj6hp)oQJM2m6XKJUqprGAjRwv1s)BnUKmXrnZwslKpoHbsTkVwJwRQAbq6FRXV4ZS1rtF2OMqSGCGO3RvvT0)wJNFh1rtBg9yYbIEVwv1s)BnUKmXrTz0Jjhi6DQJsnkPefPPEqxONiaLYOEe2bdN6jfaO4NEykjiupa4GLqZdgo1Z7EG1omLeKA7HNDTIzT92OxRzmgq6jYR9D0Q9IJOw4O2efGU1kJA7X504AjeqWAh)eR9IAzY4QfE1sJTiXAV4i4upSeEycfQhwetGO35x8z26OPpButiwqEIec0h12zTOIi7FO(GeyTQQL(3ACjzIJAMTKwiFCcdKA7eCTgKek0tKFXrOjef1mBjTWrTQQLfXei6DUKmXrTz0Jjprcb6JA7SwYRfvez)d1hKaR9TAf2bdNFXNzRJM(SrnHyb5OIi7FO(GeyTKrDuQrjJsrAQh0f6jcqPmQhwcpmHc1dlIjq07CjzIJAZOhtEIec0h12zTOIi7FO(GeyTQQL8AjV2xw7jt0po6tOL9HocWrxONiqTKqsTKx7jt0po6tOL9HocWrxONiqTQQLqCHBYUAvo4AFNQTwYQLSAvvl51sETSiMarVZV4ZS1rtF2OMqSG8ejeOpQv51AqsOqprUyQjef1a4u6QBrQV4iQvvT0)wJljtCuZSL0c5JtyGul4AP)TgxsM4OMzlPfYjef1JtyGulz1scj1sETSiMarVZV4ZS1rtF2OMqSG8ejeOpQfCTQTwv1s)BnUKmXrnZwslKpoHbsTGRvT1swTKvRQAP)Tgp)oQJM2m6XKde9ETQQLqCHBYUAvo4AnijuONixm1eqhs8j0eIlAt2vlzupc7GHt9Kcau8tpmLeeQJsnk1buKM6bDHEIaukJ6ryhmCQNr8Nt8oOBPZpDxQhwcpmHc1d51(YAZVJTiTq(aAAhUECrsWrxONiqTKqsT0)wJpGM2HRhxKe8VzTKvRQAP)TgxsM4OMzlPfYhNWaP2obxRbjHc9e5xCeAcrrnZwslCuRQAzrmbIENljtCuBg9yYtKqG(O2obxlQiY(hQpibwRQAjex4MSRwLxRbjHc9e5IPMa6qIpHMqCrBYUAvvl9V1453rD00MrpMCGO3PECHaPEgXFoX7GULo)0DPok1OKcJI0upOl0teGszupc7GHt9CXNzRJM(SrnHybPEaWblHMhmCQN39aR9IJO2E4zxRywlSvl8aDuBp8SHETNnwlHOyTa4u6YR9D0Q1JZ4A)dS2E4zxBgM1cB1E2yTNmr)QfoQ9eqq34AfhOw4b6O2E4zd9ApBSwcrXAbWP0Lt9Ws4HjuOEiV2xwB(DSfPfYhqt7W1Jlsco6c9ebQLesQL(3A8b00oC94IKG)nRLSAvvl9V14sYeh1mBjTq(4egi12j4AnijuONi)IJqtikQz2sAHJAvvllIjq07CjzIJAZOhtEIec0h12j4Arfr2)q9bjWAvvlH4c3KD1Q8AnijuONixm1eqhs8j0eIlAt2vRQAP)Tgp)oQJM2m6XKde9o1rPgLEpfPPEqxONiaLYOEyj8Wekup0)wJljtCuZSL0c5JtyGuBNGR1GKqHEI8locnHOOMzlPfoQvvTNmr)453rD00MrpMC0f6jcuRQAzrmbIENNFh1rtBg9yYtKqG(O2obxlQiY(hQpibwRQAnijuONi)GeO(7hCQfZAvETgKek0tKFXrOjef1a4u6QBrQftQhHDWWPEU4ZS1rtF2OMqSGuhLAusbtrAQh0f6jcqPmQhwcpmHc1d9V14sYeh1mBjTq(4egi12j4AnijuONi)IJqtikQz2sAHJAvvl51(YApzI(XZVJ6OPnJEm5Ol0teOwsiPwwetGO3553rD00MrpM8ejeOpQv51AqsOqpr(fhHMquudGtPRUfPodZAjRwv1AqsOqpr(bjq93p4ulM1Q8AnijuONi)IJqtikQbWP0v3IulMupc7GHt9CXNzRJM(SrnHybPok1O07KI0upOl0teGszupc7GHt9ijtCuBg9ys9aGdwcnpy4upV7bwRywlSv7fhrTWrTHxldOwXbQTpCqVAPXA)M12IS2z4wyw7zlETNnwlHOyTa4u6ACTeciq3Q2XpXApB5QThR1wmG1IE8TSRLqCPwXbQ9SLR2ZgtSw4OwpUALzIcq3ALAZVJ1gTAnJEmRfi6Do1dlHhMqH6HfXei6D(fFMToA6Zg1eIfKNiHa9rTkVwdscf6jYftnHOOgaNsxDls9fhrTQQL8AFzTSWa6IFCdOF2DZAjHKAzrmbIENtaZmYHoA6lsc0pEIec0h1Q8AnijuONixm1eIIAaCkD1Ti1eXvlz1QQw6FRXLKjoQz2sAH8XjmqQfCT0)wJljtCuZSL0c5eII6XjmqQvvT0)wJNFh1rtBg9yYbIEVwv1siUWnzxTkhCTgKek0tKlMAcOdj(eAcXfTj7Ook1OuhHI0upOl0teGszupc7GHt9KFh1rtBg9ys9aGdwcnpy4upV7bwBgM1cB1EXrulCuB41YaQvCGA7dh0RwAS2VzTTiRDgUfM1E2Ix7zJ1sikwlaoLUgxlHac0TQD8tS2ZgtSw4Wb9QvMjkaDRvQn)owlq071koqTNTC1kM12hoOxT0iliWAfdcCk0tSwGFcDRAZVJCQhwcpmHc1d9V14sYeh1MrpMCGO3RvvTKxllIjq078l(mBD00NnQjeliprcb6JAvETgKek0tKNHPMquudGtPRUfP(IJOwsiPwwetGO35sYeh1MrpM8ejeOpQTtW1AqsOqpr(fhHMquudGtPRUfPwmRLSAvvl9V14sYeh1mBjTq(4egi1cUw6FRXLKjoQz2sAHCcrr94egi1QQwwetGO35sYeh1MrpM8ejeOpQv51QKARvvTSiMarVZV4ZS1rtF2OMqSG8ejeOpQv51QKAPok1OuhII0upOl0teGszupSeEycfQhdscf6jYJ)nGaOoAAwetGO3hupc7GHt9mSHTd6wAZOhtQJsngvTuKM6bDHEIaukJ6ryhmCQhZehOZqD00eqhG6bahSeAEWWPEE3dSwZGO2lQD8Q)iQWbRv8ArfVuQvORf61E2yToQ4vllIjq0712dDGO34A)(ehJAbPBcfV2Zg9AdF2TwGFcDRALKjowRz0JzTaFS2lQ1o6RLqCPw7VBLDRnfaO4xTdtjbPw4G6HLWdtOq9CYe9JNFh1rtBg9yYrxONiqTQQL(3ACjzIJAZOht(3Swv1s)BnE(DuhnTz0Jjprcb6JA7SwlgaNquK6OuJrvII0upOl0teGszupSeEycfQhaK(3A8l(mBD00NnQjeli)BwRQAbq6FRXV4ZS1rtF2OMqSG8ejeOpQTZAf2bdNljtCutahd4ehCurK9puFqcSwv1(YAzHb0f)4G0nHIt9iSdgo1JzId0zOoAAcOdqDuQXOgLI0upOl0teGszupSeEycfQh6FRXZVJ6OPnJEm5FZAvvl9V1453rD00MrpM8ejeOpQTZATyaCcrXAvvllIjq07C0qWKdgoprbOBTQQLfXei6D(fFMToA6Zg1eIfKNiHa9rTQQ9L1YcdOl(XbPBcfN6ryhmCQhZehOZqD00eqhG6OoQNWeDmPinLAuII0upOl0teGszupSeEycfQN87ylslKdahmO5e6s2vZcccXb4Ol0teOwv1s)BnoaCWGMtOlzxnliiehq3YyC8Vj1JWoy4upnyIA6PmoQJsngLI0upOl0teGszupSeEycfQN87ylslKBLWXSRgYGSjYrxONiqTQQLqCHBYUAvETDO3t9iSdgo1tlJXP9WGqDuQPdOin1d6c9ebOug1Jlei1Zi(ZjEh0T05NUl1JWoy4upJ4pN4Dq3sNF6UuhLAuyuKM6ryhmCQhauoB6iDK6bDHEIaukJ6OuZ7Pin1d6c9ebOug1dlHhMqH6HqCHBYUAvETkm1s9iSdgo1tkaqXp9WusqOok1OGPin1JWoy4upeWmJCOJM(IKa9J6bDHEIaukJ6OuZ7KI0upOl0teGszupSeEycfQh6FRXLKjoQnJEm5arVxRQAzrmbIENljtCuBg9yYtKqG(G6ryhmCQNHnSDq3sBg9ysDuQPJqrAQh0f6jcqPmQhwcpmHc1dlIjq07CjzIJAZOhtEIcq3Avvl9V14sYeh1mBjTq(4egi12zT0)wJljtCuZSL0c5eII6XjmqOEe2bdN6rsM4OosAQJsnDikst9GUqprakLr9Ws4HjuOEyHb0f)4gq)S7M1QQwwetGO35eWmJCOJM(IKa9JNiHa9rTkV2oIcJ6ryhmCQhjzIJA6PmoQJsnkPwkst9iSdgo1ZfFMToA6Zg1eIfK6bDHEIaukJ6OuJskrrAQhHDWWPEKKjoQnJEmPEqxONiaLYOok1OKrPin1d6c9ebOug1dlHhMqH6H(3ACjzIJAZOhtoq07upc7GHt9KFh1rtBg9ysDuQrPoGI0upOl0teGszupc7GHt9yM4aDgQJMMa6aupa4GLqZdgo1Z7EG1(krhT2lQD8Q)iQWbRv8ArfVuQTJtM4yTkBkJRwGFcDRApBSwshxhLuD8RuBp0bI(A)(ehJAZV7q3Q2oozIJ1QGYSdETVJwTDCYehRvbLzh1ch1EYe9dbmU2ESwM4GE1(hyTVs0rRThE2qV2ZgRL0X1rjvh)k12dDGOV2VpXXO2ESwOFyMFZR2ZgRTJ7O1YSf3XPX1oIA7rqNZAhIbSw4XPEyj8WekupVS2tMOFCjzIJAKzhC0f6jcuRQAbq6FRXV4ZS1rtF2OMqSG8VzTQQfaP)Tg)IpZwhn9zJAcXcYtKqG(O2obxl51kSdgoxsM4OMEkJJJkIS)H6dsG1(QQL(3ACZehOZqD00eqhGtikQhNWaPwYOok1OKcJI0upOl0teGszupc7GHt9yM4aDgQJMMa6aupa4GLqZdgo1Z7Ov7ReD0ATLHd6vlnIET)bculWpHUvTNnwlPJRJwBp0bIEJRThbDoR9pWAHxTxu74v)ruHdwR41IkEPuBhNmXXAv2ugxTqV2ZgR9DfVcP64xP2EOde9CQhwcpmHc1d9V14sYeh1MrpM8VzTQQL(3A887OoAAZOhtEIec0h12j4AjVwHDWW5sYeh10tzCCurK9puFqcS2xvT0)wJBM4aDgQJMMa6aCcrr94egi1sg1rPgLEpfPPEqxONiaLYOEyj8WekupaXXtbak(PhMsccprcb6JAvETVVwsiPwaK(3A8uaGIF6HPKGOn8NoMcnCcVU8XjmqQv51QwQhHDWWPEKKjoQPNY4Ook1OKcMI0upOl0teGszupc7GHt9ijtCutlzkwi1daoyj08GHt90XZEP7OwLjzkwyTYv7zJ1IoqTrR2o(vQT3g9AZV7q3Q2ZgRTJtM4yTkiljr4DRDIwOdizxQhwcpmHc1d9V14sYeh1MrpM8VzTQQL(3ACjzIJAZOhtEIec0h12zTwmGAvvB(DSfPfYLKjoQTLKi8UC0f6jcqDuQrP3jfPPEqxONiaLYOEe2bdN6rsM4OMwYuSqQhaCWsO5bdN6PJN9s3rTktYuSWALR2ZgRfDGAJwTNnw77kELA7Hoq0xBVn61MF3HUvTNnwBhNmXXAvqwsIW7w7eTqhqYUupSeEycfQh6FRXZVJ6OPnJEm5FZAvvl9V14sYeh1MrpMCGO3RvvT0)wJNFh1rtBg9yYtKqG(O2obxRfdOwv1MFhBrAHCjzIJABjjcVlhDHEIauhLAuQJqrAQh0f6jcqPmQhMTaDQhLOEqjND1mBb6AyJ6H(3AC2eLKjJd6wAMT4oo5arVRIC6FRXLKjoQnJEm5FtsiH8xEYe9JhgW0m6Xeburo9V1453rD00MrpM8VjjKWIyce9ohnem5GHZtua6sgzKr9Ws4HjuOEaq6FRXV4ZS1rtF2OMqSG8VzTQQ9Kj6hxsM4Ogz2bhDHEIa1QQwYRL(3ACauoB6iDKde9ETKqsTc7Ggqn6ibeh1cUwLQLSAvvlas)Bn(fFMToA6Zg1eIfKNiHa9rTkVwHDWW5sYeh1eWXaoXbhvez)d1hKaPEe2bdN6rsM4OMaogWjoOok1OuhII0upOl0teGszupSeEycfQh6FRXztusMmoOBXhNWaPwW1s)BnoBIsYKXbDloHOOECcdKAvvllmGU4h3a6ND3K6ryhmCQhjzIJAc4yaN4G6OuJrvlfPPEqxONiaLYOEe2bdN6rsM4OMaogWjoOEy2c0PEuI6HLWdtOq9q)BnoBIsYKXbDlEIc7QvvTSiMarVZLKjoQnJEm5jsiqFuRQAjVw6FRXZVJ6OPnJEm5FZAjHKAP)TgxsM4O2m6XK)nRLmQJsngvjkst9GUqprakLr9Ws4HjuOEO)TgxsM4OMzlPfYhNWaP2obxRbjHc9e5xCeAcrrnZwslCq9iSdgo1JKmXrDK0uhLAmQrPin1d6c9ebOug1dlHhMqH6H(3A887OoAAZOht(3SwsiPwcXfUj7Qv51Q07PEe2bdN6rsM4OMEkJJ6OuJr7akst9GUqprakLr9iSdgo1dAiyYbdN6b6hM5380Wg1dH4c3KDkhCh59upq)Wm)MNgsqGaq5qQhLOEyj8Wekup0)wJNFh1rtBg9yYbIEVwv1s)BnUKmXrTz0Jjhi6DQJsngvHrrAQhHDWWPEKKjoQPLmflK6bDHEIaukJ6OoQNg0LPM(NofPPuJsuKM6bDHEIaukJ6ryhmCQhjzIJAc4yaN4G6HzlqN6rjQhwcpmHc1d9V14Sjkjtgh0T4jkSJ6OuJrPin1JWoy4upsYeh10tzCupOl0teGszuhLA6akst9iSdgo1JKmXrnTKPyHupOl0teGszuh1rDupgWCadNsngvTgvjLusPoG6Pxsh6wdQhf(o(DPM3HAu4wHQTwsBJ1cjmJ8QTfzTGgMOJjO1M4R(dteO2rqG1k)liKdbQLzlUfo4L6ka0XAvsHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwJQq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowRsDGcv7Rd3aMhculONmr)4gb0AVOwqpzI(XnchDHEIaGwl5kPiz8sDfa6yTkPGvOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0ALRwfufekqTKRKIKXl1vaOJ1Q07uHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRvUAvqvqOa1sUsksgVuxbGowRsDefQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYvsrY4L6L6k8D87snVd1OWTcvBTK2gRfsyg5vBlYAbTbh2q3shMOJjO1M4R(dteO2rqG1k)liKdbQLzlUfo4L6ka0XAvsHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCJQiz8sDfa6yTgvHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCLuKmEPUcaDS2oqHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwfMcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTVxHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwfScv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwRC1QGQGqbQLCLuKmEPUcaDS2oKcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTDifQ2xhUbmpeOwqzHd8Hh3iGw7f1cklCGp84gHJUqpraqRvUAvqvqOa1sUsksgVuxbGowRsgvHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCJQiz8sDfa6yTk9EfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XAvQJOq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowRsDifQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XAnQskuTVoCdyEiqTGEYe9JBeqR9IAb9Kj6h3iC0f6jcaATKRKIKXl1vaOJ1AufMcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5gvrY4L6ka0XAnQctHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRvUAvqvqOa1sUsksgVuxbGowRrvWkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATYvRcQccfOwYvsrY4L6ka0XAn67uHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCLuKmEPEPUcFh)UuZ7qnkCRq1wlPTXAHeMrE12ISwqZ4KdgoO1M4R(dteO2rqG1k)liKdbQLzlUfo4L6ka0XAvsHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCLuKmEPUcaDSwLuOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQRaqhR1OkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ12bkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1(EfQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYvsrY4L6ka0XAvWkuTVoCdyEiqTGEYe9JBeqR9IAb9Kj6h3iC0f6jcaATKRKIKXl1vaOJ1QKAvOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0AjxjfjJxQRaqhRvPoKcv7Rd3aMhculONmr)4gb0AVOwqpzI(XnchDHEIaGwl5kPiz8sDfa6yTk1HuOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQRaqhR1OQvHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCLuKmEPUcaDSwJQwfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XAnQskuTVoCdyEiqTGEYe9JBeqR9IAb9Kj6h3iC0f6jcaATKRKIKXl1vaOJ1AuLuOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQRaqhR1OgvHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwJ2bkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1l1v4743LAEhQrHBfQ2AjTnwlKWmYR2wK1cka2K)8aT2eF1FyIa1occSw5FbHCiqTmBXTWbVuxbGowRrvOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0Aj3OksgVuxbGowRctHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwLuWkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1QuhrHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwJQwfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XAnQrvOAFD4gW8qGAFGeVU2rx)efRvbjR9IAvGVula0aCadV2Wet5ISwYjfz1sUsksgVuxbGowRrnQcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTgvHPq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1kxTkOkiuGAjxjfjJxQRaqhR1OVxHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwJQGvOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQRaqhR1OVtfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XAnAhrHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwJ2HuOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQxQRW3XVl18ouJc3kuT1sABSwiHzKxTTiRfuZezbbTCGwBIV6pmrGAhbbwR8VGqoeOwMT4w4GxQRaqhR99kuTVoCdyEiqTGoI)Kg6aCJaATxulOJ4pPHoa3iC0f6jcaATKRKIKXl1vaOJ1(EfQ2xhUbmpeOwqhXFsdDaUraT2lQf0r8N0qhGBeo6c9ebaTw5QvbvbHcul5kPiz8sDfa6yTkyfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XAvWkuTVoCdyEiqTGYch4dpUraT2lQfuw4aF4XnchDHEIaGwl5kPiz8sDfa6yTVtfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTw5QvbvbHcul5kPiz8sDfa6yTDefQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XA7qkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1l1v4743LAEhQrHBfQ2AjTnwlKWmYR2wK1cQeiO1M4R(dteO2rqG1k)liKdbQLzlUfo4L6ka0XAvsHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCJQiz8sDfa6yTkPq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowRrvOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0Aj3OksgVuxbGowBhOq1(6WnG5Ha1c6jt0pUraT2lQf0tMOFCJWrxONiaO1sUrvKmEPUcaDS2oqHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwfMcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTVxHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwfScv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTVtfQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYvsrY4L6ka0XA7ikuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ12HuOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQRaqhRvj1Qq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowRskPq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowRsgvHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCJQiz8sDfa6yTk1bkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1QKctHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwLEVcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTkPGvOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0Aj3OksgVuxbGowRsDifQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYnQIKXl1vaOJ1Au1Qq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowRrvsHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwJAufQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYnQIKXl1vaOJ1A03Rq1(6WnG5Ha1c6jt0pUraT2lQf0tMOFCJWrxONiaO1kxTkOkiuGAjxjfjJxQRaqhR1OkyfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XAnQcwHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRvUAvqvqOa1sUsksgVuxbGowRrFNkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1A0oIcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTgTdPq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowBhOwfQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XA7aLuOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQRaqhRTdmQcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTDqhOq1(6WnG5Ha1c6jt0pUraT2lQf0tMOFCJWrxONiaO1sUsksgVuxbGowBh0bkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ12bkmfQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYvsrY4L6ka0XA7afMcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTDGcwHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDS2oOJOq1(6WnG5Ha1cA(DSfPfYncO1ErTGMFhBrAHCJWrxONiaO1sUsksgVuxbGowRctTkuTVoCdyEiqTGEYe9JBeqR9IAb9Kj6h3iC0f6jcaATKRKIKXl1vaOJ1QWuRcv7Rd3aMhculO53XwKwi3iGw7f1cA(DSfPfYnchDHEIaGwl5kPiz8sDfa6yTkmLuOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0Aj3OksgVuxbGowRcZOkuTVoCdyEiqTGEYe9JBeqR9IAb9Kj6h3iC0f6jcaATKRKIKXl1l1v4743LAEhQrHBfQ2AjTnwlKWmYR2wK1cQTKeH3f0At8v)Hjcu7iiWAL)feYHa1YSf3ch8sDfa6yTkPq1(6WnG5Ha1c6jt0pUraT2lQf0tMOFCJWrxONiaO1sUsksgVuxbGowRcwHQ91HBaZdbQf0lHoi4XfAgNfXei6DqR9IAbLfXei6DUqZaTwYnQIKXl1vaOJ1(ovOAFD4gW8qGAb9sOdcECHMXzrmbIEh0AVOwqzrmbIENl0mqRLCJQiz8sDfa6yTDifQ2xhUbmpeOwqzHd8Hh3iGw7f1cklCGp84gHJUqpraqRLCLuKmEPUcaDSwL6afQ2xhUbmpeOwqzHd8Hh3iGw7f1cklCGp84gHJUqpraqRLCLuKmEPUcaDSwLuykuTVoCdyEiqTGYch4dpUraT2lQfuw4aF4XnchDHEIaGwl5kPiz8sDfa6yTk9EfQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYvsrY4L6ka0XAv69kuTVoCdyEiqTGYch4dpUraT2lQfuw4aF4XnchDHEIaGwl5kPiz8sDfa6yTgvjfQ2xhUbmpeOwqzHd8Hh3iGw7f1cklCGp84gHJUqpraqRLCLuKmEPEPUcFh)UuZ7qnkCRq1wlPTXAHeMrE12ISwqzrmbIEFaATj(Q)WebQDeeyTY)cc5qGAz2IBHdEPUcaDSwLuOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0Aj3OksgVuxbGowRskuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1AufQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYnQIKXl1vaOJ1AufQ2xhUbmpeOwqZVJTiTqUraT2lQf087ylslKBeo6c9ebaTwYvsrY4L6ka0XA7afQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYnQIKXl1vaOJ12bkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1QWuOAFD4gW8qGAbn)o2I0c5gb0AVOwqZVJTiTqUr4Ol0tea0AjxjfjJxQRaqhR99kuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1QGvOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0Aj3OksgVuxbGow77uHQ91HBaZdbQf0r8N0qhGBeqR9IAbDe)jn0b4gHJUqpraqRLCJQiz8sDfa6yTDifQ2xhUbmpeOwqpzI(XncO1ErTGEYe9JBeo6c9ebaTwYnQIKXl1vaOJ1QKAvOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0Aj3OksgVuxbGowRsgvHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCJQiz8sDfa6yTk1bkuTVoCdyEiqTGMFhBrAHCJaATxulO53XwKwi3iC0f6jcaATKRKIKXl1vaOJ1QKctHQ91HBaZdbQf087ylslKBeqR9IAbn)o2I0c5gHJUqpraqRLCLuKmEPUcaDSwLEVcv7Rd3aMhculONmr)4gb0AVOwqpzI(XnchDHEIaGwl5kPiz8sDfa6yTkPGvOAFD4gW8qGAb9Kj6h3iGw7f1c6jt0pUr4Ol0tea0AjxjfjJxQRaqhR1OQvHQ91HBaZdbQf0tMOFCJaATxulONmr)4gHJUqpraqRLCLuKmEPEP(7GWmYdbQTdvRWoy41oHJBWl1PEmZObNi1ZlErTDuXcRTJtM4yP(lErTkifPZVKDR1OkzCTgvTg1OL6L6V4f1(ABXTWHcvQ)IxuBhwTV7bw711eYKzTpqIxxRT4atOBvB0QLzlUJZAH(Hz(npy41c9XHcqTrRwqzIZWPwyhmCq5L6V4f12Hv7RTf3cRvsM4Og6nOdVU1ErTsYeh12sseE3AjhE16ObmRTh9R2j0awRmQvsM4O2wsIW7sgVu)fVO2oSAv4kCqVAvqnem5WAHETDSccf0A7W)JRwAKj)bwB34dAI1g)R2OvBkUfwR4a16Xv7FaDRA74KjowRcQIMZyadNxQ)IxuBhwTDmqh(FC1AMWiHx3AVO2)aRTJtM4yTVs0JjOJAXwdzh0awllIjq071sldeO2WR91kC9UQfBnKDdEP(lErTDy1(UhyTJlHSRwZmy4yaDRAVO2eb(mS2x)kV7ApibwlWhR9IA)UJmCmKSBTD8ROa12IeKbVu)fVO2oSA7OHbeOwdscf6joiftMS)uoy4JAVOwf4l1sea)jw7f1MiWNH1(6x5Dx7bjqEPEPUWoy4dUzISGGwU3atkjzIJAOF4CISRuxyhm8b3mrwqql3BGjLKmXrDtiGtOKL6c7GHp4MjYccA5EdmPyH3H)tutiUOTqIs9x8IAf2bdFWntKfe0Y9gyszqsOqprJDHablbQpjTWtZIVFghMGtCGNXayt(ZdChuQ)IxuRWoy4dUzISGGwU3atkdscf6jASleiy0qOnzNXHj4eh4zma2K)8aR07l1FXlQvyhm8b3mrwqql3BGjLbjHc9en2fceSzIM)5uJgcJdtWd8mg2atE(DSfPfYhqt7W1JlscvKZcdOl(XnG(z3njHewyaDXpUJSmMrcqcjSWb(WJljtCuBMba0QlzKzSbz(rWkzSbz(rnohiy1wQ)IxuRWoy4dUzISGGwU3atkdscf6jASleiyBXaQdt0raJdtWd8mg2alSdAa1OJeqCOCWgKek0tKlbQpjTWtZIVFgBqMFeSsgBqMFuJZbcwTL6V4f1kSdg(GBMiliOL7nWKYGKqHEIg7cbcUbDzQP)PBCycEGNXgK5hbR2s9x8IAf2bdFWntKfe0Y9gyszqsOqprJDHabBljr4D1JtyGOpibACycoXbEgdGn5ppWDOs9x8IAf2bdFWntKfe0Y9gyszqsOqprJDHablZEP7qp66mnlIjq07dJdtWjoWZyaSj)5bwTL6V4f1kSdg(GBMiliOL7nWKYGKqHEIg7cbcohAcrrnaoLU6wK6locJdtWjoWZyaSj)5b(9L6V4f1kSdg(GBMiliOL7nWKYGKqHEIg7cbcohAcrrnaoLU6wK6mmnombN4apJbWM8Nh43xQ)IxuRWoy4dUzISGGwU3atkdscf6jASlei4COjef1a4u6QBrQftJdtWjoWZyaSj)5b2OQTu)fVOwHDWWhCZezbbTCVbMugKek0t0yxiqWeXPntKHiG(IJqt314WeCId8mgaBYFEG7iL6V4f1kSdg(GBMiliOL7nWKYGKqHEIg7cbcMionHOOgaNsxDls9fhHXHj4eh4zma2K)8aRKAl1FXlQvyhm8b3mrwqql3BGjLbjHc9en2fcemrCAcrrnaoLU6wKAX04WeCId8mgaBYFEGv69L6V4f1kSdg(GBMiliOL7nWKYGKqHEIg7cbcwm1eIIAaCkD1Ti1xCeghMGtCGNXWgyw4aF4XLKjoQnZaaA11ydY8JG7a1ASbz(rnohiyLuBP(lErTc7GHp4MjYccA5EdmPmijuONOXUqGGftnHOOgaNsxDls9fhHXHj4eh4zma2K)8aBu1wQ)IxuRWoy4dUzISGGwU3atkdscf6jASleiyXutikQbWP0v3IuteNXHj4eh4zma2K)8aBu1wQ)IxuRWoy4dUzISGGwU3atkdscf6jASlei4mm1eIIAaCkD1Ti1xCeghMGh4zSbz(rWgvTDyK)(xflCGp84sYeh1MzaaT6swP(lErTc7GHp4MjYccA5EdmPmijuONOXUqGGV4i0eIIAaCkD1Ti1IPXHj4bEgBqMFe87FZOQ9vrolmGU4h3Hw2NUjijKqolCGp84sYeh1MzaaT6Qsyh0aQrhjG4Otdscf6jYLa1NKw4PzX3pYi7nLE)RICwyaDXpoiDtO4QYVJTiTqUKmXrTTKeH3vLWoObuJosaXHYbBqsOqprUeO(K0cpnl((rwP(lErTc7GHp4MjYccA5EdmPmijuONOXUqGGV4i0eIIAaCkD1Ti1zyACycEGNXgK5hbBu12HrEh5vXch4dpUKmXrTzgaqRUKvQ)IxuRWoy4dUzISGGwU3atkdscf6jASleiyAjtXc1eIlAt2zCycEGNXWgywyaDXpUdTSpDtqJniZpcwbR2omYjKXHzxTbz(XxLsQvTKvQ)IxuRWoy4dUzISGGwU3atkdscf6jASleiyAjtXc1eIlAt2zCycEGNXWgywyaDXpoiDtO4gBqMFeCh69DyKtiJdZUAdY8JVkLuRAjRu)fVOwHDWWhCZezbbTCVbMugKek0t0yxiqW0sMIfQjex0MSZ4We8apJHnWgKek0tKtlzkwOMqCrBYoWQ1ydY8JG7iQTdJCczCy2vBqMF8vPKAvlzL6V4f1kSdg(GBMiliOL7nWKYGKqHEIg7cbcwm1eqhs8j0eIlAt2zCycoXbEgdGn5ppWk9(s9x8IAf2bdFWntKfe0Y9gyszqsOqprJDHabFXrOjef1mBjTWHXHj4eh4zma2K)8aB0s9x8IAf2bdFWntKfe0Y9gyszqsOqprJDHablbQV4i0eIIAMTKw4W4WeCId8mgaBYFEGnAP(lErTc7GHp4MjYccA5EdmPmijuONOXUqGGBWHn0T0Hj6yACycEGNXgK5hbR0RIC8v)HMMiahjm7MOm1rc4IZqsiH8tMOF887OoAAZOhtvKFYe9JljtCuJm7GesEjlmGU4hhKUjuCYur(lzHb0f)4oYYygjajKiSdAa1OJeqCawjsij)o2I0c5dOPD46XfjbzQEjlmGU4h3a6ND3KmYk1FXlQvyhm8b3mrwqql3BGjLbjHc9en2fceSyQdx)hOXHj4bEgBqMFem(Q)qtteGtimHor9WgXtt8hqgjKGV6p00eb4wtbakxKdnTayHKqc(Q)qtteGBnfaOCro0eiGmNWWjHe8v)HMMiahqsqiIW1aideT5)sCWqNHKqc(Q)qtteGd9bl)Nqpr9R(l(9j0aObidjHe8v)HMMiaFe)5eVd6w68t3LesWx9hAAIa8X3PNraOfc8S7oosibF1FOPjcW7fqqhZHULHdqcj4R(dnnraEBkeOoAAA5UjwQlSdg(GBMiliOL7nWKIaMzKAiHyHL6c7GHp4MjYccA5EdmPAtCyZsPDgdBGhXFsdDaUHykhCI6rmnG(rcjJ4pPHoa38pU)e1y(npy4L6c7GHp4MjYccA5EdmPYVJ6OPnJEmng2aZcdOl(XbPBcfxv(DSfPfYLKjoQTLKi8UQyHd8HhxsM4O2mdaOvxvgKek0tKlZEP7qp66mnlIjq07dvc7Ggqn6ibehDAqsOqprUeO(K0cpnl((vQlSdg(GBMiliOL7nWKQLX4OJ5zmSb(LgKek0tKBMO5Fo1OHaSsQYVJTiTqoaCWGMtOlzxnliiehOuxyhm8b3mrwqql3BGjLKmXrn9ugNXWg4xAqsOqprUzIM)5uJgcWkP6L53XwKwihaoyqZj0LSRMfeeIdOI8xYcdOl(XnG(z3njHedscf6jYBWHn0T0Hj6yswPUWoy4dUzISGGwU3atkcyMro0rtFrsG(zmSb(LgKek0tKBMO5Fo1OHaSsQEz(DSfPfYbGdg0CcDj7QzbbH4aQyHb0f)4gq)S7MQEPbjHc9e5n4Wg6w6WeDml1f2bdFWntKfe0Y9gysHgcMCWWng2aBqsOqprUzIM)5uJgcWkvQxQlSdg(4nWKIfF)WCyIZzPUWoy4J3atQ)a1eIlAlKWyydm5Nmr)4OpHw2h6iGkcXfUj76eChrTQiex4MSt5GvWVNmsiH8xEYe9JJ(eAzFOJaQiex4MSRtWDK3twPUWoy4J3atkZ4GHBmSbM(3ACjzIJAZOht(3Suxyhm8XBGj1bjqDVKMgdBGZVJTiTq(HeMrktDVKMQO)Tghv0w(Jdgo)BQICwetGO35sYeh1MrpM8efGUKqcDmgQAql7tNiHa9rNGvyQLSsDHDWWhVbMutOL9n0D4Falc0pJHnW0)wJljtCuBg9yYbIExf9V1453rD00MrpMCGO3vbG0)wJFXNzRJM(SrnHyb5arVxQlSdg(4nWKIwS0rtFjKbYWyydm9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjhi6Dvai9V14x8z26OPpButiwqoq07L6c7GHpEdmPOXCGjiq3Yyydm9V14sYeh1MrpM8VzPUWoy4J3atk6zea62p7AmSbM(3ACjzIJAZOht(3Suxyhm8XBGjvdMi9mcaJHnW0)wJljtCuBg9yY)ML6c7GHpEdmPeNHJlLPMjZPXWgy6FRXLKjoQnJEm5FZsDHDWWhVbMu)bQHhsmmg2at)BnUKmXrTz0Jj)BwQlSdg(4nWK6pqn8qcJDHabteHpHN2mHdcJHnWSWa6IFCq6MqXvXIyce9oxsM4O2m6XKNiHa9rNGvsTQyrmbIENFXNzRJM(SrnHyb5jsiqF0jyLuBPUWoy4J3atQ)a1Wdjm2fcemre(eEAZeoimg2a)swyaDXpoiDtO4QyrmbIENljtCuBg9yYtKqG(OtWkyvSiMarVZV4ZS1rtF2OMqSG8ejeOp6eScUuxyhm8XBGj1FGA4HegJTgYoTleiyRPaaLlYHMwaSqJHnW0)wJljtCuBg9yY)MKqclIjq07CjzIJAZOhtEIec0hkh87FVkaK(3A8l(mBD00NnQjeli)BwQlSdg(4nWK6pqn8qcJDHabJeMDtuM6ibCXzOXWgywetGO35sYeh1MrpM8ejeOp6eSsVxflIjq078l(mBD00NnQjeliprcb6JobR07l1f2bdF8gys9hOgEiHXUqGGbsuaAWe1gWXaNgdBGzrmbIENljtCuBg9yYtKqG(q5GnQAjHKxAqsOqprUyQdx)hiyLiHeYpibcwTQmijuONiVbh2q3shMOJjyLuLFhBrAH8b00oC94IKGSsDHDWWhVbMu)bQHhsySlei4r8NAOLdpmng2aZIyce9oxsM4O2m6XKNiHa9HYb3bQLesEPbjHc9e5IPoC9FGGvQuxyhm8XBGj1FGA4Heg7cbc2A210whnTmgqc4uoy4gdBGzrmbIENljtCuBg9yYtKqG(q5GnQAjHKxAqsOqprUyQdx)hiyLiHeYpibcwTQmijuONiVbh2q3shMOJjyLuLFhBrAH8b00oC94IKGSsDHDWWhVbMu)bQHhsySleiycHj0jQh2iEAI)aYmg2aZIyce9oxsM4O2m6XKNiHa9rNGFVkYFPbjHc9e5n4Wg6w6WeDmbRejKCqcu5DGAjRuxyhm8XBGj1FGA4Heg7cbcMqycDI6HnINM4pGmJHnWSiMarVZLKjoQnJEm5jsiqF0j43RYGKqHEI8gCydDlDyIoMGvsf9V1453rD00MrpM8VPk6FRXZVJ6OPnJEm5jsiqF0jyYvsTDyV)vLFhBrAH8b00oC94IKGmvhKa7SduBPUWoy4J3atQ)a1Wdjm2fce8WwaIEeqhjToA6lsc0pJHnWhKabRwsiHCdscf6jYJ)nGaOoAAwetGO3hQiNCwyaDXpoiDtO4QyrmbIENNcau8tpmLeeEIec0hDc2OQyrmbIENljtCuBg9yYtKqG(OtWVxflIjq078l(mBD00NnQjeliprcb6Job)EYiHewetGO35sYeh1MrpM8ejeOp6eSrjHKg0Y(0jsiqF0jlIjq07CjzIJAZOhtEIec0hKrwP(lQ99CfCTWrTNnw7WerGAJwTNnw7t8Nt8oOBv776t3TwZm6Wr2bNyPUWoy4J3atQ)a1Wdjm2fce8i(ZjEh0T05NURXWgyYnijuONi)GeO(7hCQfZ3ixyhmCEkaqXp9Wusq4OIi7FO(Ge4RIfgqx8Jds3ekozVrUWoy4CauoB6iDKJkIS)H6dsGVkwyaDXpUJSmMrcq2Bc7GHZV4ZS1rtF2OMqSGCurK9puFqcSZtsl84aWXjodvqY3ZvWKPICdscf6jYTfdOomrhbiHeYzHb0f)4G0nHIRk)o2I0c5sYeh1qVbD41LmYuDsAHhhaooXzOYn67l1FXlQvyhm8XBGjLJ9T47a6ehX0aA8FG6EB4e1mzCq3cSsgdBGP)TgxsM4O2m6XK)njHeaK(3A8l(mBD00NnQjeli)BscjaXXtbak(PhMscc)GmqGUvP(lErTc7GHpEdmPyYCQf2bdxpHJZyxiqWmzY(t5GHpk1f2bdF8gysXK5ulSdgUEchNXUqGGLanECjKDGvYyydSWoObuJosaXHYbBqsOqprUeO(K0cpnl((vQlSdg(4nWKIjZPwyhmC9eooJDHabBljr4DnECjKDGvYyydmlmGU4hhKUjuCv53XwKwixsM4O2wsIW7wQlSdg(4nWKIjZPwyhmC9eooJDHab3GdBOBPdt0X04XLq2bwjJHnWgKek0tKBlgqDyIocawTQmijuONiVbh2q3shMOJPQxsolmGU4hhKUjuCv53XwKwixsM4O2wsIW7swPUWoy4J3atkMmNAHDWW1t44m2fceCyIoMgpUeYoWkzmSb2GKqHEICBXaQdt0raWQv1ljNfgqx8Jds3ekUQ87ylslKljtCuBljr4DjRuxyhm8XBGjftMtTWoy46jCCg7cbcMfXei69HXJlHSdSsgdBGFj5SWa6IFCq6MqXvLFhBrAHCjzIJABjjcVlzL6c7GHpEdmPyYCQf2bdxpHJZyxiqWzCYbd34XLq2bwjJHnWgKek0tK3GUm10)0bRwvVKCwyaDXpoiDtO4QYVJTiTqUKmXrTTKeH3LSsDHDWWhVbMumzo1c7GHRNWXzSlei4g0LPM(NUXJlHSdSsgdBGnijuONiVbDzQP)PdwjvVKCwyaDXpoiDtO4QYVJTiTqUKmXrTTKeH3LSs9sDHDWWhCjqWTmghDmpJHnW53XwKwihaoyqZj0LSRMfeeIdOIfXei6Do9V10aWbdAoHUKD1SGGqCaEIcqxv0)wJdahmO5e6s2vZcccXb0Tmghhi6DvKt)BnUKmXrTz0Jjhi6Dv0)wJNFh1rtBg9yYbIExfas)Bn(fFMToA6Zg1eIfKde9ozQyrmbIENFXNzRJM(SrnHyb5jsiqFawTQiN(3ACjzIJAMTKwiFCcdKobBqsOqprUeO(IJqtikQz2sAHdvKt(jt0pE(DuhnTz0JPkwetGO3553rD00MrpM8ejeOp6eSfdqflIjq07CjzIJAZOhtEIec0hk3GKqHEI8locnHOOgaNsxDlsTysgjKq(lpzI(XZVJ6OPnJEmvXIyce9oxsM4O2m6XKNiHa9HYnijuONi)IJqtikQbWP0v3IulMKrcjSiMarVZLKjoQnJEm5jsiqF0jylgazKvQlSdg(Glb(gys1GjQPNY4mg2atE(DSfPfYbGdg0CcDj7QzbbH4aQyrmbIENt)BnnaCWGMtOlzxnliiehGNOa0vf9V14aWbdAoHUKD1SGGqCaDdMihi6DvMjAqBXa4kXBzmo6yEKrcjKNFhBrAHCa4GbnNqxYUAwqqioGQdsGGvlzL6c7GHp4sGVbMuTmgN2ddIXWg487ylslKBLWXSRgYGSjQIfXei6DUKmXrTz0Jjprcb6dL3bQvflIjq078l(mBD00NnQjeliprcb6dWQvf50)wJljtCuZSL0c5JtyG0jydscf6jYLa1xCeAcrrnZwslCOICYpzI(XZVJ6OPnJEmvXIyce9op)oQJM2m6XKNiHa9rNGTyaQyrmbIENljtCuBg9yYtKqG(q5gKek0tKFXrOjef1a4u6QBrQftYiHeYF5jt0pE(DuhnTz0JPkwetGO35sYeh1MrpM8ejeOpuUbjHc9e5xCeAcrrnaoLU6wKAXKmsiHfXei6DUKmXrTz0Jjprcb6JobBXaiJSsDHDWWhCjW3atQwgJt7HbXyydC(DSfPfYTs4y2vdzq2evXIyce9oxsM4O2m6XKNiHa9by1QICYjNfXei6D(fFMToA6Zg1eIfKNiHa9HYnijuONixm1eIIAaCkD1Ti1xCeQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoHOOECcdeYiHeYzrmbIENFXNzRJM(SrnHyb5jsiqFawTQO)TgxsM4OMzlPfYhNWaPtWgKek0tKlbQV4i0eIIAMTKw4GmYur)BnE(DuhnTz0Jjhi6DYk1f2bdFWLaFdmPKKjoQjGJbCIdJHnWSWa6IFCq6MqXvLFhBrAHCjzIJABjjcVRk6FRXLKjoQTLKi8U8Xjmq6uP3RIfXei6DEkaqXp9Wusq4jsiqF0jydscf6jYTLKi8U6Xjmq0hKaFdvez)d1hKavXIyce9o)IpZwhn9zJAcXcYtKqG(OtWgKek0tKBljr4D1JtyGOpib(gQiY(hQpib(MWoy48uaGIF6HPKGWrfr2)q9bjqvSiMarVZLKjoQnJEm5jsiqF0jydscf6jYTLKi8U6Xjmq0hKaFdvez)d1hKaFtyhmCEkaqXp9Wusq4OIi7FO(Ge4Bc7GHZV4ZS1rtF2OMqSGCurK9puFqc0yMTaDWkvQlSdg(Glb(gysjjtCutahd4ehgdBGzHb0f)4gq)S7MQYVJTiTqUKmXrn0BqhEDvr)BnUKmXrTTKeH3LpoHbsNk9EvSiMarVZV4ZS1rtF2OMqSG8ejeOp6eSbjHc9e52sseEx94egi6dsGVHkIS)H6dsGQyrmbIENljtCuBg9yYtKqG(OtWgKek0tKBljr4D1JtyGOpib(gQiY(hQpib(MWoy48l(mBD00NnQjelihvez)d1hKanMzlqhSsL6c7GHp4sGVbMusYeh10tzCgdBGzHb0f)4gq)S7MQozI(XLKjoQrMDO6GeyNkPwvSiMarVZjGzg5qhn9fjb6hprcb6dv0)wJZMOKmzCq3IpoHbsNDqPUWoy4dUe4BGj1FGA4Heg7cbcEe)5eVd6w68t31yydC(DSfPfYhqt7W1JlscvMjAqBXa4kXrdbtoy4L6c7GHp4sGVbMux8z26OPpButiwqJHnW53XwKwiFanTdxpUijuzMObTfdGRehnem5GHxQlSdg(Glb(gysjjtCuBg9yAmSbo)o2I0c5dOPD46XfjHkYnt0G2IbWvIJgcMCWWjHeZenOTyaCL4x8z26OPpButiwqYk1f2bdFWLaFdmPiGzg5qhn9fjb6NXWg487ylslKljtCud9g0HxxvSiMarVZV4ZS1rtF2OMqSG8ejeOp6eSsQvflIjq07CjzIJAZOhtEIec0hDcwP3xQlSdg(Glb(gysraZmYHoA6lsc0pJHnWSiMarVZLKjoQnJEm5jsiqF0j4oIkwetGO35x8z26OPpButiwqEIec0hDcUJOIC6FRXLKjoQz2sAH8Xjmq6eSbjHc9e5sG6locnHOOMzlPfouro5Nmr)453rD00MrpMQyrmbIENNFh1rtBg9yYtKqG(OtWwmavSiMarVZLKjoQnJEm5jsiqFO83tgjKq(lpzI(XZVJ6OPnJEmvXIyce9oxsM4O2m6XKNiHa9HYFpzKqclIjq07CjzIJAZOhtEIec0hDc2IbqgzL6c7GHp4sGVbMuOHGjhmCJHnWhKavEhOwv53XwKwiFanTdxpUijuXcdOl(XnG(z3nvzMObTfdGReNaMzKdD00xKeOFL6c7GHp4sGVbMuOHGjhmCJHnWhKavEhOwv53XwKwiFanTdxpUijur)BnUKmXrnZwslKpoHbsNGnijuONixcuFXrOjef1mBjTWHkwetGO35x8z26OPpButiwqEIec0hGvRkwetGO35sYeh1MrpM8ejeOp6eSfdOuxyhm8bxc8nWKcnem5GHBmSb(GeOY7a1Qk)o2I0c5dOPD46XfjHkwetGO35sYeh1MrpM8ejeOpaRwvKto5SiMarVZV4ZS1rtF2OMqSG8ejeOpuUbjHc9e5IPMquudGtPRUfP(IJqf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjef1JtyGqgjKqolIjq078l(mBD00NnQjeliprcb6dWQvf9V14sYeh1mBjTq(4egiDc2GKqHEICjq9fhHMquuZSL0chKrMk6FRXZVJ6OPnJEm5arVtMXq)Wm)MNg2at)Bn(aAAhUECrsWhNWabm9V14dOPD46XfjbNquupoHbIXq)Wm)MNgsqGaq5qWkvQlSdg(Glb(gysLcau8tpmLeeJHnWSiMarVZV4ZS1rtF2OMqSG8ejeOp6evez)d1hKavro5Nmr)453rD00MrpMQyrmbIENNFh1rtBg9yYtKqG(OtWwmavSiMarVZLKjoQnJEm5jsiqFOCdscf6jYV4i0eIIAaCkD1Ti1IjzKqc5V8Kj6hp)oQJM2m6XuflIjq07CjzIJAZOhtEIec0hk3GKqHEI8locnHOOgaNsxDlsTysgjKWIyce9oxsM4O2m6XKNiHa9rNGTyaKvQlSdg(Glb(gysLcau8tpmLeeJHnWSiMarVZLKjoQnJEm5jsiqF0jQiY(hQpibQICYjNfXei6D(fFMToA6Zg1eIfKNiHa9HYnijuONixm1eIIAaCkD1Ti1xCeQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoHOOECcdeYiHeYzrmbIENFXNzRJM(SrnHyb5jsiqFawTQO)TgxsM4OMzlPfYhNWaPtWgKek0tKlbQV4i0eIIAMTKw4GmYur)BnE(DuhnTz0Jjhi6DYk1f2bdFWLaFdmPaq5SPJ0rJHnWSiMarVZLKjoQnJEm5jsiqFawTQiNCYzrmbIENFXNzRJM(SrnHyb5jsiqFOCdscf6jYftnHOOgaNsxDls9fhHk6FRXLKjoQz2sAH8Xjmqat)BnUKmXrnZwslKtikQhNWaHmsiHCwetGO35x8z26OPpButiwqEIec0hGvRk6FRXLKjoQz2sAH8Xjmq6eSbjHc9e5sG6locnHOOMzlPfoiJmv0)wJNFh1rtBg9yYbIENSsDHDWWhCjW3atQ)a1Wdjm2fce8i(ZjEh0T05NURXWgyYP)TgxsM4OMzlPfYhNWaPtWgKek0tKlbQV4i0eIIAMTKw4Gesmt0G2IbWvINcau8tpmLeeYuro5Nmr)453rD00MrpMQyrmbIENNFh1rtBg9yYtKqG(OtWwmavSiMarVZLKjoQnJEm5jsiqFOCdscf6jYV4i0eIIAaCkD1Ti1IjzKqc5V8Kj6hp)oQJM2m6XuflIjq07CjzIJAZOhtEIec0hk3GKqHEI8locnHOOgaNsxDlsTysgjKWIyce9oxsM4O2m6XKNiHa9rNGTyaKvQlSdg(Glb(gysDXNzRJM(SrnHybng2aZcdOl(XnG(z3nvLFhBrAHCjzIJAO3Go86QIfXei6DobmZih6OPVijq)4jsiqF0j43R2sDHDWWhCjW3atQl(mBD00NnQjelOXWgywyaDXpUb0p7UPQ87ylslKljtCud9g0Hxxv0)wJtaZmYHoA6lsc0pEIec0hDc2OQvflIjq07CjzIJAZOhtEIec0hDc2IbuQlSdg(Glb(gysDXNzRJM(SrnHybng2ato9V14sYeh1mBjTq(4egiDc2GKqHEICjq9fhHMquuZSL0chKqIzIg0wmaUs8uaGIF6HPKGqMkYj)Kj6hp)oQJM2m6XuflIjq07887OoAAZOhtEIec0hDc2IbOIfXei6DUKmXrTz0Jjprcb6dLBqsOqpr(fhHMquudGtPRUfPwmjJesi)LNmr)453rD00MrpMQyrmbIENljtCuBg9yYtKqG(q5gKek0tKFXrOjef1a4u6QBrQftYiHewetGO35sYeh1MrpM8ejeOp6eSfdGSsDHDWWhCjW3atkjzIJAZOhtJHnWKtolIjq078l(mBD00NnQjeliprcb6dLBqsOqprUyQjef1a4u6QBrQV4iur)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCcrr94egiKrcjKZIyce9o)IpZwhn9zJAcXcYtKqG(aSAvr)BnUKmXrnZwslKpoHbsNGnijuONixcuFXrOjef1mBjTWbzKPI(3A887OoAAZOhtoq07L6c7GHp4sGVbMu53rD00MrpMgdBGP)Tgp)oQJM2m6XKde9UkYjNfXei6D(fFMToA6Zg1eIfKNiHa9HYnQAvr)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCcrr94egiKrcjKZIyce9o)aIpZwhn9zJAcXcYtKqG(aSAvr)BnUKmXrnZwslKpoHbsNGnijuONixcuFXrOjef1mBjTWbzKPICwetGO35sYeh1MrpM8ejeOpuUsgLesaq6FRXV4ZS1rtF2OMqSG8VjzL6c7GHp4sGVbMudBy7GUL2m6X0yydmlIjq07CjzIJ6iP5jsiqFO83tcjV8Kj6hxsM4Oos6s9x8IAf2bdFWLaFdmP6f4z8azGvlxTkmJHnWai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGaMCaK(3A8uaGIF6HPKGOn8NoMcnCcVUCcrr94egiDykrMQ87ylslKBljr4qMgz2HkHDqdOgDKaIJoFVXtOJAgayJ((sDHDWWhCjW3atkjzIJA6PmoJHnWSWa6IFCq6MqXvLFhBrAHCjzIJAO3Go86QI(3ACjzIJAZOht(3ufas)BnEkaqXp9Wusq0g(thtHgoHxx(4egiGvyQmt0G2IbWvIljtCuhjTkHDqdOgDKaIJoFNQEz(DSfPfYTLKiCitJm7Ouxyhm8bxc8nWKssM4OMwYuSqJHnWSWa6IFCq6MqXvLFhBrAHCjzIJAO3Go86QI(3ACjzIJAZOht(3ufas)BnEkaqXp9Wusq0g(thtHgoHxx(4egiGvyL6c7GHp4sGVbMusYeh10tzCgdBGzHb0f)4G0nHIRk)o2I0c5sYeh1qVbD41vf9V14sYeh1MrpM8VPkYbIJNcau8tpmLeeEIec0hkxbtcjai9V14Paaf)0dtjbrB4pDmfA4eED5FtYubG0)wJNcau8tpmLeeTH)0XuOHt41LpoHbsNkmvc7Ggqn6ibehD((sDHDWWhCjW3atkjzIJ6iPng2aZcdOl(XbPBcfxv(DSfPfYLKjoQTLKi8UQO)TgxsM4O2m6XK)nvbG0)wJNcau8tpmLeeTH)0XuOHt41LpoHbc4oOuxyhm8bxc8nWKssM4OMwYuSqJHnWSWa6IFCq6MqXvLFhBrAHCjzIJABjjcVRk6FRXLKjoQnJEm5Ftvai9V14Paaf)0dtjbrB4pDmfA4eED5JtyGa2OL6c7GHp4sGVbMusYeh1OIMZyad3yydmlmGU4hhKUjuCv53XwKwixsM4O2wsIW7QI(3ACjzIJAZOht(3uLzIg0wmaUr5Paaf)0dtjbrLWoObuJosaXHY7GsDHDWWhCjW3atkjzIJAurZzmGHBmSbMfgqx8Jds3ekUQ87ylslKljtCuBljr4Dvr)BnUKmXrTz0Jj)BQcaP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdeWkPsyh0aQrhjG4q5DqPUWoy4dUe4BGjLzId0zOoAAcOdymSbM(3ACauoB6iDK)nvbG0)wJFXNzRJM(SrnHyb5Ftvai9V14x8z26OPpButiwqEIec0hDcM(3ACZehOZqD00eqhGtikQhNWa5vjSdgoxsM4OMEkJJJkIS)H6dsGQiN8tMOF8ehHlodvjSdAa1OJeqC0PcJmsiryh0aQrhjG4OZ3tMkYFz(DSfPfYLKjoQPdcAjbiq)iHKtsl842OmpBUj7uEh8EYk1f2bdFWLaFdmPKKjoQPNY4mg2at)BnoakNnDKoY)MQiN8tMOF8ehHlodvjSdAa1OJeqC0PcJmsiryh0aQrhjG4OZ3tMkYFz(DSfPfYLKjoQPdcAjbiq)iHKtsl842OmpBUj7uEh8EYk1f2bdFWLaFdmPgFtm9WGuQlSdg(Glb(gysjjtCutlzkwOXWgy6FRXLKjoQz2sAH8XjmquoyYf2bnGA0rcio6WuImv53XwKwixsM4OMoiOLeGa9t1jPfECBuMNn3KDD2bVVuxyhm8bxc8nWKssM4OMwYuSqJHnW0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNquupoHbsPUWoy4dUe4BGjLKmXrDK0gdBGP)TgxsM4OMzlPfYhNWabSAvrolIjq07CjzIJAZOhtEIec0hkxP3tcjVKCwyaDXpoiDtO4QYVJTiTqUKmXrTTKeH3LmYk1f2bdFWLaFdmPC8SXuFiHjooJHnWKNylXHTqprsi5LhKbc0Titf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjef1JtyGuQlSdg(Glb(gysjjtCutahd4ehgdBGP)TgNnrjzY4GUfprHDQYVJTiTqUKmXrTTKeH3vf5KFYe9JleMtydYKdgUkHDqdOgDKaIJo7iKrcjc7Ggqn6ibehD(EYk1f2bdFWLaFdmPKKjoQjGJbCIdJHnW0)wJZMOKmzCq3INOWovNmr)4sYeh1iZoubG0)wJFXNzRJM(SrnHyb5FtvKFYe9JleMtydYKdgojKiSdAa1OJeqC0zhISsDHDWWhCjW3atkjzIJAc4yaN4Wyydm9V14Sjkjtgh0T4jkSt1jt0pUqyoHnitoy4Qe2bnGA0rcio6uHvQlSdg(Glb(gysjjtCuJkAoJbmCJHnW0)wJljtCuZSL0c5JtyG0j9V14sYeh1mBjTqoHOOECcdKsDHDWWhCjW3atkjzIJAurZzmGHBmSbM(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5eII6XjmquzMObTfdGRexsM4OMwYuSWs9x8IAf2bdFWLaFdmPqdbtoy4gd9dZ8BEAydmH4c3KDkhCh59gd9dZ8BEAibbcaLdbRuPEP(lErTK2ghyTmzY(t5GHpQThtSwIWacul0VO2ZgRvaacV2lQLC7WeB)5Slz1cDwIYaRfBnidIoRlVu)fVOwHDWWhCMmz)PCWWhGnijuONOXUqGGTfdOomrhbmombpWZydY8JGvYyydSbjHc9e52IbuhMOJaGvRkZenOTyaCL4OHGjhmCvVK887ylslKpGM2HRhxKeKqs(DSfPfYpKWmszQ7L0KSs9x8IAf2bdFWzYK9NYbdF8gyszqsOqprJDHabBlgqDyIocyCycEGNXgK5hbRKXWgydscf6jYTfdOomrhbaRwv0)wJljtCuBg9yYbIExflIjq07CjzIJAZOhtEIec0hQip)o2I0c5dOPD46XfjbjKKFhBrAH8djmJuM6EjnjRu)fVOwHDWWhCMmz)PCWWhVbMugKek0t0yxiqWnOltn9pDJdtWd8m2Gm)iyLmg2at)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCcrr94egiQEj9V145FI6OPp7eXb)BQQbTSpDIec0hDcMCYjexuqsHDWW5sYeh10tzCCwmoYEvc7GHZLKjoQPNY44OIi7FO(GeizL6V4f1QGcpBmRvQT9NZU1ooHbccuRTKeH3T2iRf61IkIS)H1MIBH12dp7Avwqqljab6xP(lErTc7GHp4mzY(t5GHpEdmPmijuONOXUqGGrcZOhteqtlzkwOXHj4bEgBqMFem9V14sYeh12sseEx(4egikhSsVNesip)o2I0c5sYeh10bbTKaeOFQojTWJBJY8S5MSRZo49KvQ)IxuRWoy4dotMS)uoy4J3atkdscf6jASlei4PmoTyQ)d0yaSj)5bwTghMGh4zmSbM(3ACjzIJAZOht(3uf5gKek0tKpLXPft9FGGvljKCqcu5GnijuONiFkJtlM6)aFtP3tMXgK5hbFqcSu)fVO2oozIJ1(kzaaT6wRf0aoQvQ1GKqHEI1keX3VAJwTmG04AP)xT9iOZzT)bwRuBBkxT44GeYbdVwBmrETK2gRDajy1AMHbiacuBIec0hAurtKDiqTOIMjogWWRfiWrTEC12hji12JZzTTiR1mdaOv3Ab(yTxu7zJ1s)ZX1TwxUFI1gTApBSwgqYl1FXlQvyhm8bNjt2Fkhm8XBGjLbjHc9en2fcemooiHCiGwm1SiMarVBCycEGNXgK5hbtolIjq07CjzIJAZOhtoWpLdg(RICL6WixTC12bVkw4aF4XLKjoQnZaaA1LNIdczKrwhg5hKa7WmijuONiFkJtlM6)ajRu)fVOwHDWWhCMmz)PCWWhVbMugKek0t0yxiqWhKa1F)GtTyACycEGNXWgyw4aF4XLKjoQnZaaA11ydY8JGzrmbIENljtCuBg9yYtKqG(qJkAISdbk1FXlQvyhm8bNjt2Fkhm8XBGjLbjHc9en2fce8bjq93p4ulMghMGh4zmSb(LSWb(WJljtCuBMba0QRXgK5hbZIyce9oxsM4O2m6XKNiHa9rP(lErTk8iOZzTa4u6wBh)k1(nR9IAnQAhiR2wK1s646OL6V4f1kSdg(GZKj7pLdg(4nWKYGKqHEIg7cbc(GeO(7hCQftJdtWeIIgBqMFemlIjq078l(mBD00NnQjeliprcb6dJHnWKZIyce9o)IpZwhn9zJAcXcYtKqG(OdZGKqHEI8dsG6VFWPwmjRtJQ2s9x8IAFGodR9D9P7wlCu74ZSRvQ1m6XS9N1Ej0bbVABrwRcsq3ekUX12JGoN1ooidKAVO2ZgR96JAjG()WAzDztS2VFWzT9yTw4vRuRn0YUw0JVLDTP4GuB0Q1mdaOv3s9x8IAf2bdFWzYK9NYbdF8gyszqsOqprJDHabFqcu)9do1IPXHjycrrJniZpc(sOdcE8r8Nt8oOBPZpDxolIjq078ejeOpmg2aZch4dpUKmXrTzgaqRUQyHd8HhxsM4O2mdaOvxEkoiD(Ev4R(dnnra(i(ZjEh0T05NURkwyaDXpoiDtO4QYVJTiTqUKmXrTTKeH3Tu)fVOwfEe05SwaCkDRL0X1rR9Bw7f1Au1oqwTTiRTJFLs9x8IAf2bdFWzYK9NYbdF8gyszqsOqprJDHabBhtaOBPV4imombpWZydY8JGzrmbIENFXNzRJM(SrnHyb5jkaDvzqsOqpr(bjq93p4ulMDAu1wQ)Ixu77saGIF1(ykji1ce4OwpUAHeeiauoC2TwZ)v73S2ZgR1WF6yk0Wj86wlas)BTAhrTWRwM41sJ1caBni7pVAVOwa4GHPx7zlxT9iOjwRC1E2yTkCWmo7An8NoMcnCcVU1ooHbsP(lErTc7GHp4mzY(t5GHpEdmPmijuONOXUqGG7W)Jt)hiGEykjighMGh4zSbz(rWKBMObTfdGRepfaO4NEykjiKqIzIg0wmaUr5Paaf)0dtjbHesmt0G2IbW7aEkaqXp9WusqitLWoy48uaGIF6HPKGWpibQhqNHDAXa4eIIVkfwP(lErTkisOf0LzTpqIxxlZgzGGa1cG0)wJNcau8tpmLeeTH)0XuOHt41Lde9UX1s)VApB5QfiWHd6vBFKGuBVn61E2yTcaq41kMMtioQ9D9OGewl0hN43SlVu)fVOwHDWWhCMmz)PCWWhVbMugKek0t0yxiqWD4)XP)deqpmLeeJdtWd8m2Gm)iyYnt0G2IbWvINcau8tpmLeesiXmrdAlga3O8uaGIF6HPKGqcjMjAqBXa4DapfaO4NEykjiKPcaP)TgpfaO4NEykjiAd)PJPqdNWRlhi69s9x8IAf2bdFWzYK9NYbdF8gyszqsOqprJDHabh)BabqD00SiMarVpmombpWZydY8JGP)TgxsM4O2m6XKde9Uk6FRXZVJ6OPnJEm5arVRcaP)Tg)IpZwhn9zJAcXcYbIEx1lnijuONiVd)po9FGa6HPKGOcaP)TgpfaO4NEykjiAd)PJPqdNWRlhi69s9x8IAf2bdFWzYK9NYbdF8gyszqsOqprJDHabpoHbI2wsIW7ACycEGNXgK5hbNFhBrAHCjzIJABjjcVRkYjNfgqx8Jds3ekUkwetGO35Paaf)0dtjbHNiHa9rNgKek0tKBljr4D1JtyGOpibsgzL6L6VO2xjHrcpOchS2)a6w1ALWXSBTqgKnXA7HNDTIjV239aRfE12dp7AV4iQnoBm7HdKxQlSdg(GZIyce9(aClJXP9WGymSbo)o2I0c5wjCm7QHmiBIQyrmbIENljtCuBg9yYtKqG(q5DGAvXIyce9o)IpZwhn9zJAcXcYtua6QIC6FRXLKjoQz2sAH8Xjmq6eSbjHc9e5xCeAcrrnZwslCOICYpzI(XZVJ6OPnJEmvXIyce9op)oQJM2m6XKNiHa9rNGTyaQyrmbIENljtCuBg9yYtKqG(q5gKek0tKFXrOjef1a4u6QBrQftYiHeYF5jt0pE(DuhnTz0JPkwetGO35sYeh1MrpM8ejeOpuUbjHc9e5xCeAcrrnaoLU6wKAXKmsiHfXei6DUKmXrTz0Jjprcb6JobBXaiJSsDHDWWhCwetGO3hVbMuTmgN2ddIXWg487ylslKBLWXSRgYGSjQIfXei6DUKmXrTz0JjprbORkYF5jt0po6tOL9HocqcjKFYe9JJ(eAzFOJaQiex4MSt5GFNQLmYuro5SiMarVZV4ZS1rtF2OMqSG8ejeOpuUsQvf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjef1JtyGqgjKqolIjq078l(mBD00NnQjeliprcb6dWQvf9V14sYeh1mBjTq(4egiGvlzKPI(3A887OoAAZOhtoq07Qiex4MSt5GnijuONixm1eqhs8j0eIlAt2vQlSdg(GZIyce9(4nWKQLX4OJ5zmSbo)o2I0c5aWbdAoHUKD1SGGqCavSiMarVZP)TMgaoyqZj0LSRMfeeIdWtua6QI(3ACa4GbnNqxYUAwqqioGULX44arVRIC6FRXLKjoQnJEm5arVRI(3A887OoAAZOhtoq07Qaq6FRXV4ZS1rtF2OMqSGCGO3jtflIjq078l(mBD00NnQjeliprcb6dWQvf50)wJljtCuZSL0c5JtyG0jydscf6jYV4i0eIIAMTKw4qf5KFYe9JNFh1rtBg9yQIfXei6DE(DuhnTz0Jjprcb6JobBXauXIyce9oxsM4O2m6XKNiHa9HYnijuONi)IJqtikQbWP0v3IulMKrcjK)YtMOF887OoAAZOhtvSiMarVZLKjoQnJEm5jsiqFOCdscf6jYV4i0eIIAaCkD1Ti1IjzKqclIjq07CjzIJAZOhtEIec0hDc2IbqgzL6c7GHp4SiMarVpEdmPAWe10tzCgdBGZVJTiTqoaCWGMtOlzxnliiehqflIjq07C6FRPbGdg0CcDj7QzbbH4a8efGUQO)TghaoyqZj0LSRMfeeIdOBWe5arVRYmrdAlgaxjElJXrhZRu)f1(kcmRTJgKU2E4zxBh)k1cB1cpqh1YccOBv73S2reoV23rRw4vBpCoRLgR9pqGA7HNDTKoUoQX1YKXvl8QDmHw23SBT0ylsSuxyhm8bNfXei69XBGjfbmZih6OPVijq)mg2at(lZVJTiTq(aAAhUECrsqcj0)wJpGM2HRhxKe8VjzQyrmbIENFXNzRJM(SrnHyb5jsiqF0PbjHc9e5eXPntKHiG(IJqt3Lesi3GKqHEI8dsG6VFWPwmvUbjHc9e5eXPjef1a4u6QBrQftvSiMarVZV4ZS1rtF2OMqSG8ejeOpuUbjHc9e5eXPjef1a4u6QBrQV4iiRuxyhm8bNfXei69XBGjfbmZih6OPVijq)mg2aZIyce9oxsM4O2m6XKNOa0vf5V8Kj6hh9j0Y(qhbiHeYpzI(XrFcTSp0raveIlCt2PCWVt1sgzQiNCwetGO35x8z26OPpButiwqEIec0hk3GKqHEICXutikQbWP0v3IuFXrOI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5eII6XjmqiJesiNfXei6D(fFMToA6Zg1eIfKNiHa9by1QI(3ACjzIJAMTKwiFCcdeWQLmYur)BnE(DuhnTz0Jjhi6DveIlCt2PCWgKek0tKlMAcOdj(eAcXfTj7k1f2bdFWzrmbIEF8gys1M4WMLs7mg2aBqsOqprE8Vbea1rtZIyce9(qf5J4pPHoa3qmLdor9iMgq)iHKr8N0qhGB(h3FIAm)MhmCYk1FrTD8Sx6oQ9pWAbq5SPJ0XA7HNDTIjV23rR2loIAHJAtua6wRmQThNtJRLqabRD8tS2lQLjJRw4vln2IeR9IJGxQlSdg(GZIyce9(4nWKcaLZMoshng2aZIyce9o)IpZwhn9zJAcXcYtua6QI(3ACjzIJAMTKwiFCcdKobBqsOqpr(fhHMquuZSL0chQyrmbIENljtCuBg9yYtKqG(OtWwmGsDHDWWhCwetGO3hVbMuaOC20r6OXWgywetGO35sYeh1MrpM8efGUQi)LNmr)4OpHw2h6iajKq(jt0po6tOL9HocOIqCHBYoLd(DQwYitf5KZIyce9o)IpZwhn9zJAcXcYtKqG(q5kPwv0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNquupoHbczKqc5SiMarVZV4ZS1rtF2OMqSG8efGUQO)TgxsM4OMzlPfYhNWabSAjJmv0)wJNFh1rtBg9yYbIExfH4c3KDkhSbjHc9e5IPMa6qIpHMqCrBYUs9xu77EG1omLeKAHTAV4iQvCGAfZALeRn8Aza1koqT9Hd6vlnw73S2wK1od3cZApBXR9SXAjefRfaNsxJRLqab6w1o(jwBpwRTyaRvUANOmUAV(OwjzIJ1YSL0ch1koqTNTC1EXruBVmCqVA7W)JR2)ab4L6c7GHp4SiMarVpEdmPsbak(PhMscIXWgywetGO35x8z26OPpButiwqEIec0hk3GKqHEI8COjef1a4u6QBrQV4iuXIyce9oxsM4O2m6XKNiHa9HYnijuONiphAcrrnaoLU6wKAXuf5Nmr)453rD00MrpMQiNfXei6DE(DuhnTz0Jjprcb6Jorfr2)q9bjqsiHfXei6DE(DuhnTz0Jjprcb6dLBqsOqprEo0eIIAaCkD1Ti1zysgjK8YtMOF887OoAAZOhtYur)BnUKmXrnZwslKpoHbIYnQkaK(3A8l(mBD00NnQjelihi6Dv0)wJNFh1rtBg9yYbIExf9V14sYeh1MrpMCGO3l1FrTV7bw7WusqQThE21kM12BJETMXyaPNiV23rR2loIAHJAtua6wRmQThNtJRLqabRD8tS2lQLjJRw4vln2IeR9IJGxQlSdg(GZIyce9(4nWKkfaO4NEykjigdBGzrmbIENFXNzRJM(SrnHyb5jsiqF0jQiY(hQpibQI(3ACjzIJAMTKwiFCcdKobBqsOqpr(fhHMquuZSL0chQyrmbIENljtCuBg9yYtKqG(OtYrfr2)q9bjW3e2bdNFXNzRJM(SrnHyb5OIi7FO(GeizL6c7GHp4SiMarVpEdmPsbak(PhMscIXWgywetGO35sYeh1MrpM8ejeOp6evez)d1hKavro5V8Kj6hh9j0Y(qhbiHeYpzI(XrFcTSp0raveIlCt2PCWVt1sgzQiNCwetGO35x8z26OPpButiwqEIec0hk3GKqHEICXutikQbWP0v3IuFXrOI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5eII6XjmqiJesiNfXei6D(fFMToA6Zg1eIfKNiHa9by1QI(3ACjzIJAMTKwiFCcdeWQLmYur)BnE(DuhnTz0Jjhi6DveIlCt2PCWgKek0tKlMAcOdj(eAcXfTj7iRuxyhm8bNfXei69XBGj1FGA4Heg7cbcEe)5eVd6w68t31yydm5Vm)o2I0c5dOPD46XfjbjKq)Bn(aAAhUECrsW)MKPI(3ACjzIJAMTKwiFCcdKobBqsOqpr(fhHMquuZSL0chQyrmbIENljtCuBg9yYtKqG(OtWOIi7FO(GeOkcXfUj7uUbjHc9e5IPMa6qIpHMqCrBYov0)wJNFh1rtBg9yYbIEVu)f1(UhyTxCe12dp7AfZAHTAHhOJA7HNn0R9SXAjefRfaNsxETVJwTECgx7FG12dp7AZWSwyR2ZgR9Kj6xTWrTNac6gxR4a1cpqh12dpBOx7zJ1sikwlaoLU8sDHDWWhCwetGO3hVbMux8z26OPpButiwqJHnWK)Y87ylslKpGM2HRhxKeKqc9V14dOPD46Xfjb)BsMk6FRXLKjoQz2sAH8Xjmq6eSbjHc9e5xCeAcrrnZwslCOIfXei6DUKmXrTz0Jjprcb6JobJkIS)H6dsGQiex4MSt5gKek0tKlMAcOdj(eAcXfTj7ur)BnE(DuhnTz0Jjhi69sDHDWWhCwetGO3hVbMux8z26OPpButiwqJHnW0)wJljtCuZSL0c5JtyG0jydscf6jYV4i0eIIAMTKw4q1jt0pE(DuhnTz0JPkwetGO3553rD00MrpM8ejeOp6emQiY(hQpibQYGKqHEI8dsG6VFWPwmvUbjHc9e5xCeAcrrnaoLU6wKAXSuxyhm8bNfXei69XBGj1fFMToA6Zg1eIf0yydm9V14sYeh1mBjTq(4egiDc2GKqHEI8locnHOOMzlPfour(lpzI(XZVJ6OPnJEmjHewetGO3553rD00MrpM8ejeOpuUbjHc9e5xCeAcrrnaoLU6wK6mmjtLbjHc9e5hKa1F)GtTyQCdscf6jYV4i0eIIAaCkD1Ti1IzP(lQ9DpWAfZAHTAV4iQfoQn8Aza1koqT9Hd6vlnw73S2wK1od3cZApBXR9SXAjefRfaNsxJRLqab6w1o(jw7zlxT9yT2IbSw0JVLDTeIl1koqTNTC1E2yI1ch16XvRmtua6wRuB(DS2OvRz0JzTarVZl1f2bdFWzrmbIEF8gysjjtCuBg9yAmSbMfXei6D(fFMToA6Zg1eIfKNiHa9HYnijuONixm1eIIAaCkD1Ti1xCeQi)LSWa6IFCdOF2DtsiHfXei6DobmZih6OPVijq)4jsiqFOCdscf6jYftnHOOgaNsxDlsnrCKPI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5eII6Xjmqur)BnE(DuhnTz0Jjhi6DveIlCt2PCWgKek0tKlMAcOdj(eAcXfTj7k1FrTV7bwBgM1cB1EXrulCuB41YaQvCGA7dh0RwAS2VzTTiRDgUfM1E2Ix7zJ1sikwlaoLUgxlHac0TQD8tS2ZgtSw4Wb9QvMjkaDRvQn)owlq071koqTNTC1kM12hoOxT0iliWAfdcCk0tSwGFcDRAZVJ8sDHDWWhCwetGO3hVbMu53rD00MrpMgdBGP)TgxsM4O2m6XKde9UkYzrmbIENFXNzRJM(SrnHyb5jsiqFOCdscf6jYZWutikQbWP0v3IuFXrqcjSiMarVZLKjoQnJEm5jsiqF0jydscf6jYV4i0eIIAaCkD1Ti1IjzQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoHOOECcdevSiMarVZLKjoQnJEm5jsiqFOCLuRkwetGO35x8z26OPpButiwqEIec0hkxj1wQlSdg(GZIyce9(4nWKAydBh0T0MrpMgdBGnijuONip(3acG6OPzrmbIEFuQ)IAF3dSwZGO2lQD8Q)iQWbRv8ArfVuQvORf61E2yToQ4vllIjq0712dDGO34A)(ehJAbPBcfV2Zg9AdF2TwGFcDRALKjowRz0JzTaFS2lQ1o6RLqCPw7VBLDRnfaO4xTdtjbPw4Ouxyhm8bNfXei69XBGjLzId0zOoAAcOdymSb(Kj6hp)oQJM2m6Xuf9V14sYeh1MrpM8VPk6FRXZVJ6OPnJEm5jsiqF0PfdGtikwQlSdg(GZIyce9(4nWKYmXb6muhnnb0bmg2adG0)wJFXNzRJM(SrnHyb5Ftvai9V14x8z26OPpButiwqEIec0hDkSdgoxsM4OMaogWjo4OIi7FO(GeOQxYcdOl(XbPBcfVuxyhm8bNfXei69XBGjLzId0zOoAAcOdymSbM(3A887OoAAZOht(3uf9V1453rD00MrpM8ejeOp60IbWjefvXIyce9ohnem5GHZtua6QIfXei6D(fFMToA6Zg1eIfKNiHa9HQxYcdOl(XbPBcfVuVuxyhm8bVbDzQP)PdwsM4OMaogWjomg2at)BnoBIsYKXbDlEIc7mMzlqhSsL6c7GHp4nOltn9p93atkjzIJA6PmUsDHDWWh8g0LPM(N(BGjLKmXrnTKPyHL6L6VOwfEB0Rn)UdDRAr4zJzTNnw7ZtTrwlPv4RDIwOdijehgxBpwBV4xTxuRcQHOwASfjw7zJ1s646OKQJFLA7Hoq0ZR9DpWAHxTYO2reETYO23v8k1AlJABqhoSrGAJFwBpcQbS2Hj6xTXpRLzlPfok1f2bdFWBWHn0T0Hj6ycgnem5GHBmSbM887ylslKFiHzKYu3lPjjKqE(DSfPfYhqt7W1JlscvV0GKqHEICZen)ZPgneGvImYuro9V1453rD00MrpMCGO3jHeZenOTyaCL4sYeh10sMIfsMkwetGO3553rD00MrpM8ejeOpk1FrTVJwT9iOgWABqhoSrGAJFwllIjq0712dDGOFuR4a1omr)Qn(zTmBjTWHX1AMWiHhuHdwRcQHO2WaM1IgWS7zdDRAX5al1f2bdFWBWHn0T0Hj6y(gysHgcMCWWng2aFYe9JNFh1rtBg9yQIfXei6DE(DuhnTz0Jjprcb6dvSiMarVZLKjoQnJEm5jsiqFOI(3ACjzIJAZOhtoq07QO)Tgp)oQJM2m6XKde9UkZenOTyaCL4sYeh10sMIfwQlSdg(G3GdBOBPdt0X8nWKQbtutpLXzmSbo)o2I0c5aWbdAoHUKD1SGGqCav0)wJdahmO5e6s2vZcccXb0Tmgh)BwQlSdg(G3GdBOBPdt0X8nWKQLX40Eyqmg2aNFhBrAHCReoMD1qgKnrveIlCt2P8o07l1f2bdFWBWHn0T0Hj6y(gysjjtCutahd4ehgdBGZVJTiTqUKmXrTTKeH3vf9V14sYeh12sseEx(4egiDs)BnUKmXrTTKeH3LtikQhNWarf5Kt)BnUKmXrTz0Jjhi6DvSiMarVZLKjoQnJEm5jkaDjJesaq6FRXV4ZS1rtF2OMqSG8VjzgZSfOdwPsDHDWWh8gCydDlDyIoMVbMu53rD00MrpMgdBGZVJTiTq(aAAhUECrsuQlSdg(G3GdBOBPdt0X8nWKssM4OosAJHnWSiMarVZZVJ6OPnJEm5jkaDl1f2bdFWBWHn0T0Hj6y(gysjjtCutpLXzmSbMfXei6DE(DuhnTz0JjprbORk6FRXLKjoQz2sAH8Xjmq6K(3ACjzIJAMTKwiNquupoHbsPUWoy4dEdoSHULomrhZ3atkauoB6iD0yyd8lZVJTiTq(HeMrktDVKMKqclCGp84wW2PJM(Sr9eYSl1f2bdFWBWHn0T0Hj6y(gysLFh1rtBg9ywQ)IAFhTA7rqtSw5QLquS2Xjmqg1gTAF9RRvCGA7XATfdOd6v7FGa12rdsxBx8mU2)aRvQDCcdKAVOwZenG(vlX3z2q3Q2VpXXO287o0TQ9SXAvqwsIW7w7eTqhqYUL6c7GHp4n4Wg6w6WeDmFdmPKKjoQjGJbCIdJHnW0)wJZMOKmzCq3INOWov0)wJZMOKmzCq3IpoHbcy6FRXztusMmoOBXjef1JtyGOIfgqx8JBa9ZUBQIfXei6DobmZih6OPVijq)4jkaDv9sdscf6jYrcZOhteqtlzkwOkwetGO35sYeh1MrpM8efGUL6VOw1ejHmNDRThR1uGzTMXbdV2)aRThE212XVIX1s)VAHxT9W5S2PmUANHBvl6X3YU2wK1shNDTNnw77kELAfhO2o(vQTh6ar)O2VpXXO287o0TQ9SXAFEQnYAjTcFTt0cDajH4Ouxyhm8bVbh2q3shMOJ5BGjLzCWWng2a)Y87ylslKFiHzKYu3lPPkYFz(DSfPfYhqt7W1JlscsiHCdscf6jYnt08pNA0qawjv0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNquupoHbczKvQlSdg(G3GdBOBPdt0X8nWKcaLZMoshng2at)BnE(DuhnTz0Jjhi6DsiXmrdAlgaxjUKmXrnTKPyHL6c7GHp4n4Wg6w6WeDmFdmPsbak(PhMscIXWgy6FRXZVJ6OPnJEm5arVtcjMjAqBXa4kXLKjoQPLmflSuxyhm8bVbh2q3shMOJ5BGjfbmZih6OPVijq)mg2at)BnE(DuhnTz0Jjprcb6Jojxb)MrFv53XwKwiFanTdxpUijiRu)f1QWBJET53DOBv7zJ1QGSKeH3T2jAHoGKDnU2)aRTJFLAPXwKyTKoUoATxulWNWSwP22Fo7w74egiiqT0sMIfwQlSdg(G3GdBOBPdt0X8nWKssM4O2m6X0yydSbjHc9e5iHz0JjcOPLmfluf9V1453rD00MrpM8VPkYjex4MSRtYn67FJCLu7RIfgqx8Jds3ekozKrcj0)wJZMOKmzCq3IpoHbcy6FRXztusMmoOBXjef1JtyGqwPUWoy4dEdoSHULomrhZ3atkjzIJAAjtXcng2aBqsOqprosyg9yIaAAjtXcvr)BnUKmXrnZwslKpoHbcy6FRXLKjoQz2sAHCcrr94egiQO)TgxsM4O2m6XK)nl1f2bdFWBWHn0T0Hj6y(gys9hOgEiHXUqGGhXFoX7GULo)0Dng2at)BnE(DuhnTz0Jjhi6DsiXmrdAlgaxjUKmXrnTKPyHKqIzIg0wmaUs8uaGIF6HPKGqcjKBMObTfdGRehaLZMoshv9Y87ylslKpGM2HRhxKeKvQlSdg(G3GdBOBPdt0X8nWK6IpZwhn9zJAcXcAmSbM(3A887OoAAZOhtoq07KqIzIg0wmaUsCjzIJAAjtXcjHeZenOTyaCL4Paaf)0dtjbHesi3mrdAlgaxjoakNnDKoQ6L53XwKwiFanTdxpUijiRuxyhm8bVbh2q3shMOJ5BGjLKmXrTz0JPXWgyZenOTyaCL4x8z26OPpButiwWs9xu77EG1(krhT2lQD8Q)iQWbRv8ArfVuQTJtM4yTkBkJRwGFcDRApBSwshxhLuD8RuBp0bI(A)(ehJAZV7q3Q2oozIJ1QGYSdETVJwTDCYehRvbLzh1ch1EYe9dbmU2ESwM4GE1(hyTVs0rRThE2qV2ZgRL0X1rjvh)k12dDGOV2VpXXO2ESwOFyMFZR2ZgRTJ7O1YSf3XPX1oIA7rqNZAhIbSw4Xl1f2bdFWBWHn0T0Hj6y(gyszM4aDgQJMMa6agdBGF5jt0pUKmXrnYSdvai9V14x8z26OPpButiwq(3ufas)Bn(fFMToA6Zg1eIfKNiHa9rNGjxyhmCUKmXrn9ughhvez)d1hKaFv0)wJBM4aDgQJMMa6aCcrr94egiKvQ)IAFhTAFLOJwRTmCqVAPr0R9pqGAb(j0TQ9SXAjDCD0A7Hoq0BCT9iOZzT)bwl8Q9IAhV6pIkCWAfVwuXlLA74KjowRYMY4Qf61E2yTVR4vivh)k12dDGONxQlSdg(G3GdBOBPdt0X8nWKYmXb6muhnnb0bmg2at)BnUKmXrTz0Jj)BQI(3A887OoAAZOhtEIec0hDcMCHDWW5sYeh10tzCCurK9puFqc8vr)BnUzId0zOoAAcOdWjef1JtyGqwPUWoy4dEdoSHULomrhZ3atkjzIJA6PmoJHnWaXXtbak(PhMsccprcb6dL)EsibaP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdeLR2s9xuRcpwBV4xTxulHacw74NyT9yT2IbSw0JVLDTeIl12IS2ZgRf9dMyTD8RuBp0bIEJRfnGETWwTNnMiOJAhhCoR9GeyTjsiqh6w1gETVR4v41(ooqh1g(SBT04Dyw7f1s)tV2lQvHdMrTIduRcQHOwyR287o0TQ9SXAFEQnYAjTcFTt0cDajH4GxQlSdg(G3GdBOBPdt0X8nWKssM4OMwYuSqJHnWSiMarVZLKjoQnJEm5jkaDvriUWnzxNKRWu7BKRKAFvSWa6IFCq6MqXjJmv0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNquupoHbIkYFz(DSfPfYhqt7W1JlscsiXGKqHEICZen)ZPgneGvImvVm)o2I0c5hsygPm19sAQ6L53XwKwixsM4O2wsIW7wQ)IAvMKPyH1oSJ)eOwpUAPXA)deOw5Q9SXArhO2OvBh)k1cB1QGAiyYbdVw4O2efGU1kJAbYW0e6w1YSL0ch12dNZAjeqWAHxTNacw7mClmR9IAP)Px7zNX3YU2ejeOdDRAjexk1f2bdFWBWHn0T0Hj6y(gysjjtCutlzkwOXWgy6FRXLKjoQnJEm5Ftv0)wJljtCuBg9yYtKqG(OtWwmavSiMarVZrdbtoy48ejeOpk1FrTktYuSWAh2XFcuRm7LUJAPXApBS2PmUAzY4Qf61E2yTVR4vQTh6arFTYOwshxhT2E4CwBIJlsS2ZgRLzlPfoQDyI(vQlSdg(G3GdBOBPdt0X8nWKssM4OMwYuSqJHnW0)wJNFh1rtBg9yY)MQO)TgxsM4O2m6XKde9Uk6FRXZVJ6OPnJEm5jsiqF0jylgGQxMFhBrAHCjzIJABjjcVBPUWoy4dEdoSHULomrhZ3atkjzIJAc4yaN4Wyydmas)Bn(fFMToA6Zg1eIfK)nvDYe9JljtCuJm7qf50)wJdGYzthPJCGO3jHeHDqdOgDKaIdWkrMkaK(3A8l(mBD00NnQjeliprcb6dLlSdgoxsM4OMaogWjo4OIi7FO(GeOXmBb6GvYyuYzxnZwGUg2at)BnoBIsYKXbDlnZwChNCGO3vro9V14sYeh1MrpM8VjjKq(lpzI(XddyAg9yIaQiN(3A887OoAAZOht(3KesyrmbIENJgcMCWW5jkaDjJmYk1FrTVJwT9iOjwRb0p7UPX1cjiqaOC4SBT)bw7RFDT92OxltmnrGAVOwpUA7LXH1AMbBuBldIA7ObPl1f2bdFWBWHn0T0Hj6y(gysjjtCutahd4ehgdBGzHb0f)4gq)S7MQO)TgNnrjzY4GUfFCcdeW0)wJZMOKmzCq3ItikQhNWaPu)f1(CsE1(hq3Q2x)6A74oAT92OxBh)k1AlJAPr0R9pqGsDHDWWh8gCydDlDyIoMVbMusYeh1eWXaoXHXWgy6FRXztusMmoOBXtuyNkwetGO35sYeh1MrpM8ejeOpuro9V1453rD00MrpM8VjjKq)BnUKmXrTz0Jj)BsMXmBb6GvQuxyhm8bVbh2q3shMOJ5BGjLKmXrDK0gdBGP)TgxsM4OMzlPfYhNWaPtWgKek0tKFXrOjef1mBjTWrPUWoy4dEdoSHULomrhZ3atkjzIJA6PmoJHnW0)wJNFh1rtBg9yY)MKqcH4c3KDkxP3xQlSdg(G3GdBOBPdt0X8nWKcnem5GHBmSbM(3A887OoAAZOhtoq07QO)TgxsM4O2m6XKde9UXq)Wm)MNg2atiUWnzNYb3rEVXq)Wm)MNgsqGaq5qWkvQlSdg(G3GdBOBPdt0X8nWKssM4OMwYuSWs9s9x8IAF3(4BAg5Ha1YeNHtTWoy4kiXAvqnem5GHxBpCoRLgR1L7NYC2Tw6mab9AHTAzHdapy4JALeRLapEP(lErTc7GHp42sseExWmXz4ulSdgUXWgyHDWW5OHGjhmCoZwChNq3sfH4c3KDkhCh69L6VO23rR2z0xB41siUuR4a1YIyce9(OwjXAzbb0TQ9BACTwrTInka1koqTOHOuxyhm8b3wsIW7(gysHgcMCWWng2atiUWnzxNG7a1QYGKqHEI84FdiaQJMMfXei69HkYpzI(XZVJ6OPnJEmvXIyce9op)oQJM2m6XKNiHa9rNkPwYk1FrTk8yT9IF1ErTJtyGuRTKeH3T22Fo7YRL02yT)bwB0QvjfCTJtyGmQ1gtSw4O2lQvyS47xTTiR9SXApidKANy7Qn8ApBSwMT4ooRvCGApBSwc4yaNyTqV22eAzF8sDHDWWhCBjjcV7BGjLKmXrnbCmGtCymSbMCdscf6jYhNWarBljr4DjHKdsGDQKAjtf9V14sYeh12sseEx(4egiDQKc2yMTaDWkvQ)IAv4TrV2)a6w1QGsy2nrzwRcIeWfNHgxltgxTsTnSVwuXlLAjGJbCIJA7THtS2EbEq3Q2wK1E2yT0)wRw5Q9SXAhNKxTrR2ZgRTbTSVsDHDWWhCBjjcV7BGjLKmXrnbCmGtCymSbgF1FOPjcWrcZUjktDKaU4mu1bjWo7a1Q6clRjYzrmbIEFOIfXei6Dosy2nrzQJeWfNH8ejeOpuUsk4oIQxkSdgohjm7MOm1rc4IZqoaCi0teOuxyhm8b3wsIW7(gys9hOgEiHXUqGGhXFoX7GULo)0Dng2at)BnUKmXrTz0Jj)BQ6K0cpoaCCIZWobRKAl1f2bdFWTLKi8UVbMu)bQHhsySlei4r8Nt8oOBPZpDxJHnWgKek0tKJeMrpMiGMwYuSqvSiMarVZV4ZS1rtF2OMqSG8ejeOp6emQiY(hQpibQIfXei6DUKmXrTz0Jjprcb6JobtoQiY(hQpib(QmkzQojTWJdahN4mu5kP2sDHDWWhCBjjcV7BGjvkaqXp9Wusqmg2aBqsOqprosyg9yIaAAjtXcvXIyce9o)IpZwhn9zJAcXcYtKqG(OtWOIi7FO(GeOkwetGO35sYeh1MrpM8ejeOp6em5OIi7FO(Ge4RYOKPI8xIV6p00eb4J4pN4Dq3sNF6UKqclCGp84sYeh1MzaaT6YtXbr5GFpjKq(Lqhe84J4pN4Dq3sNF6UCwetGO35jsiqFOCLusTQojTWJdahN4mu5kPwYiHeYVe6GGhFe)5eVd6w68t3LZIyce9oprcb6JobJkIS)H6dsGQojTWJdahN4mStWkPwYiRuxyhm8b3wsIW7(gysDXNzRJM(SrnHybng2aBqsOqprEh(FC6)ab0dtjbrflIjq07CjzIJAZOhtEIec0hDcgvez)d1hKavr(lXx9hAAIa8r8Nt8oOBPZpDxsiHfoWhECjzIJAZmaGwD5P4GOCWVNesi)sOdcE8r8Nt8oOBPZpDxolIjq078ejeOpuUskPwvNKw4XbGJtCgQCLulzKqc5xcDqWJpI)CI3bDlD(P7YzrmbIENNiHa9rNGrfr2)q9bjqvNKw4XbGJtCg2jyLulzKvQlSdg(GBljr4DFdmPKKjoQnJEmng2aBMObTfdGRe)IpZwhn9zJAcXcwQlSdg(GBljr4DFdmPYVJ6OPnJEmng2aBqsOqprosyg9yIaAAjtXcvXIyce9opfaO4NEykji8ejeOp6emQiY(hQpibQYGKqHEI8dsG6VFWPwmvoyJQwvK)sw4aF4XLKjoQnZaaA1LesEPbjHc9e5YSx6o0JUotZIyce9(GesyrmbIENFXNzRJM(SrnHyb5jsiqF0jyYrfr2)q9bjWxLrjJSsDHDWWhCBjjcV7BGjvkaqXp9Wusqmg2aBqsOqprosyg9yIaAAjtXcvzMObTfdGRep)oQJM2m6XSuxyhm8b3wsIW7(gysDXNzRJM(SrnHybng2aBqsOqprEh(FC6)ab0dtjbr1lnijuONi3oMaq3sFXruQ)IAF3dSwJ6a1kjtCSwAjtXcRf612XVYBVlfeVsTHp7wlSvRYMram)JRwXbQvUANOmUAnATV(1JAnZGXqGsDHDWWhCBjjcV7BGjLKmXrnTKPyHgdBGP)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoHOOECcdev0)wJNFh1rtBg9yY)MQO)TgxsM4O2m6XK)nvr)BnUKmXrTTKeH3LpoHbIYbRKcwf9V14sYeh1MrpM8ejeOp6eSWoy4CjzIJAAjtXc5OIi7FO(GeOk6FRXPNram)JJ)nl1FrTV7bwRrDGAFxXRul0RTJFLAdF2TwyRwLnJay(hxTIduRrR91VEuRzgSsDHDWWhCBjjcV7BGjv(DuhnTz0JPXWgy6FRXZVJ6OPnJEm5arVRI(3AC6zeaZ)44FtvKBqsOqpr(bjq93p4ulMkVduljKWIyce9opfaO4NEykji8ejeOpuUsgLmvKt)BnUKmXrTTKeH3LpoHbIYbR07jHe6FRXztusMmoOBXhNWar5GvImvK)sw4aF4XLKjoQnZaaA1LesEPbjHc9e5YSx6o0JUotZIyce9(GSsDHDWWhCBjjcV7BGjv(DuhnTz0JPXWgy6FRXLKjoQnJEm5arVRICdscf6jYpibQ)(bNAXu5DGAjHewetGO35Paaf)0dtjbHNiHa9HYvYOKPI8xYch4dpUKmXrTzgaqRUKqYlnijuONixM9s3HE01zAwetGO3hKvQlSdg(GBljr4DFdmPsbak(PhMscIXWgydscf6jYrcZOhteqtlzkwOkYP)TgxsM4OMzlPfYhNWar5GnkjKWIyce9oxsM4OosAEIcqxYur(lpzI(XZVJ6OPnJEmjHewetGO3553rD00MrpM8ejeOpu(7jtflIjq07CjzIJAZOhtEIec0hAurtKDiGYb3bQvf5VKfoWhECjzIJAZmaGwDjHKxAqsOqprUm7LUd9ORZ0SiMarVpiRu)f1QWBJET53DOBvRzgaqRUgx7FG1EXrulD3AH3aNTAHETrcGzTxuRmHwETWR2E4zxRywQlSdg(GBljr4DFdmPU4ZS1rtF2OMqSGgdBGnijuONi)GeO(7hCQfZoFVAvzqsOqpr(bjq93p4ulMkVduRkYFj(Q)qtteGpI)CI3bDlD(P7scjSWb(WJljtCuBMba0QlpfheLd(9KvQlSdg(GBljr4DFdmPKKjoQJK2yydSbjHc9e5D4)XP)deqpmLeev0)wJljtCuZSL0c5JtyG0j9V14sYeh1mBjTqoHOOECcdKsDHDWWhCBjjcV7BGjLKmXrnTKPyHgdBGbq6FRXtbak(PhMscI2WF6yk0Wj86YhNWabmas)BnEkaqXp9Wusq0g(thtHgoHxxoHOOECcdKsDHDWWhCBjjcV7BGjLKmXrn9ugNXWgydscf6jY7W)Jt)hiGEykjiKqc5ai9V14Paaf)0dtjbrB4pDmfA4eED5Ftvai9V14Paaf)0dtjbrB4pDmfA4eED5JtyG0jas)BnEkaqXp9Wusq0g(thtHgoHxxoHOOECcdeYk1FrTV7bwlb0H1QmjtXcRLgVEe9Atbak(v7Wusqg1cB1(DamRvzkqT9WZo(xTa4u6cDRAFxcau8R2htjbPwiakZz3sDHDWWhCBjjcV7BGjLKmXrnTKPyHgdBGP)Tgp)oQJM2m6XK)nvr)BnUKmXrTz0Jjhi6Dv0)wJtpJay(hh)BQIfXei6DEkaqXp9Wusq4jsiqF0jyLuRk6FRXLKjoQTLKi8U8XjmquoyLuWL6VO239aRns6AdVwgqTFFIJrTIzTWrTSGa6w1(nRDeHxQlSdg(GBljr4DFdmPKKjoQJK2yydm9V14sYeh1mBjTq(4egiD2bQmijuONi)GeO(7hCQftLRKAvrolIjq078l(mBD00NnQjeliprcb6dL)Esi5LSWb(WJljtCuBMba0QlzL6c7GHp42sseE33atkjzIJAc4yaN4Wyydm9V14Sjkjtgh0T4jkStf9V14sYeh1MrpM8VPXmBb6GvQu)f1(oA12J1AHxTMrpM1c92FadVwGFcDRAN)XvBpc6CwRTyaRf94BzxRTmoS2lQ1cVAJwRwP2XLHBvlTKPyH1c8tOBv7zJ1MHjPeZA7Hoq0xQlSdg(GBljr4DFdmPKKjoQPLmfl0yydm9V1453rD00MrpM8VPk6FRXZVJ6OPnJEm5jsiqF0jyHDWW5sYeh1eWXaoXbhvez)d1hKavr)BnUKmXrTz0Jj)BQI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5eII6Xjmqur)BnUKmXrTTKeH3LpoHbIk6FRXnJEm1qV9hWW5Ftv0)wJtpJay(hh)BwQ)IAFhTA7XATWRwZOhZAHE7pGHxlWpHUvTZ)4QThbDoR1wmG1IE8TSR1wghw7f1AHxTrRvRu74YWTQLwYuSWAb(j0TQ9SXAZWKuIzT9qhi6nU2ruBpc6CwB4ZU1(hyTOhFl7APNY4g1cD4bL5SBTxuRfE1ErTT4N1YSL0chL6c7GHp42sseE33atkjzIJA6PmoJHnW0)wJBM4aDgQJMMa6a8VPkYP)TgxsM4OMzlPfYhNWaPt6FRXLKjoQz2sAHCcrr94egiKqYljN(3ACZOhtn0B)bmC(3uf9V140ZiaM)XX)MKrwP(lQL02yT044Q9pWAJwTMbrTWrTxu7FG1cVAVO2x9hYaz2Tw6pCculZwslCulWpHUvTIzTs7WS2Zg7wRfE1c8jmrGAP7w7zJ1Aljr4DRLwYuSWsDHDWWhCBjjcV7BGjLzId0zOoAAcOdymSbM(3ACjzIJAMTKwiFCcdKoP)TgxsM4OMzlPfYjef1JtyGOI(3ACjzIJAZOht(3Su)f1QWJ12l(v7f1ooHbsT2sseE3AB)5SlVwsBJ1(hyTrRwLuW1ooHbYOwBmXAHJAVOwHXIVF12IS2ZgR9GmqQDITR2WR9SXAz2I74SwXbQ9SXAjGJbCI1c9ABtOL9Xl1f2bdFWTLKi8UVbMusYeh1eWXaoXHXWgy6FRXLKjoQTLKi8U8Xjmq6ujfSXmBb6GvYyOFyMFZdSsgd9dZ8BEARzqltWkvQlSdg(GBljr4DFdmPKKjoQPLmfl0yydm9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjef1JtyGOYGKqHEICKWm6Xeb00sMIfwQlSdg(GBljr4DFdmPqdbtoy4gdBGjex4MSRtLEFP(lQvbHp7w7FG1spLXv7f1s)HtGAz2sAHJAHTA7XALzIcq3ATfdyTJGaRTLbrTrsxQlSdg(GBljr4DFdmPKKjoQPNY4mg2at)BnUKmXrnZwslKpoHbIk6FRXLKjoQz2sAH8Xjmq6K(3ACjzIJAMTKwiNquupoHbsP(lQvbPW5S2E4zxRqu73N4yuRywlCulliGUvTFZAfhO2Ee0eRDg91gETeIlL6c7GHp42sseE33atkjzIJAc4yaN4Wyyd8lj3GKqHEI8dsG6VFWPwm7eSsQvfH4c3KDD2bQLmJz2c0bRKXq)Wm)MhyLmg6hM5380wZGwMGvQu)f1(kz0GtCuBp8SRDg91siJdZUgxRn0YUwBzCOX1gzT0XzxlH0TwpUATfdyTOhFl7AjexQ9IAhFtZiVATJ(AjexQf6h6dObS2uaGIF1omLeKAzIxlnACTJO2Ee05S2)aRTbtSw6PmUAfhO2wgJJoMxT92Ox7m6Rn8Ajexk1f2bdFWTLKi8UVbMunyIA6PmUsDHDWWhCBjjcV7BGjvlJXrhZRuVuxyhm8bpmrhtWnyIA6PmoJHnW53XwKwihaoyqZj0LSRMfeeIdOI(3ACa4GbnNqxYUAwqqioGULX44FZsDHDWWh8WeDmFdmPAzmoThgeJHnW53XwKwi3kHJzxnKbztufH4c3KDkVd9(sDHDWWh8WeDmFdmP(dudpKWyxiqWJ4pN4Dq3sNF6UL6c7GHp4Hj6y(gysbGYzthPJL6c7GHp4Hj6y(gysLcau8tpmLeeJHnWeIlCt2PCfMAl1f2bdFWdt0X8nWKIaMzKdD00xKeOFL6c7GHp4Hj6y(gysnSHTd6wAZOhtJHnW0)wJljtCuBg9yYbIExflIjq07CjzIJAZOhtEIec0hL6c7GHp4Hj6y(gysjjtCuhjTXWgywetGO35sYeh1MrpM8efGUQO)TgxsM4OMzlPfYhNWaPt6FRXLKjoQz2sAHCcrr94egiL6c7GHp4Hj6y(gysjjtCutpLXzmSbMfgqx8JBa9ZUBQIfXei6DobmZih6OPVijq)4jsiqFO8oIcRuxyhm8bpmrhZ3atQl(mBD00NnQjelyPUWoy4dEyIoMVbMusYeh1MrpML6c7GHp4Hj6y(gysLFh1rtBg9yAmSbM(3ACjzIJAZOhtoq07L6VO239aR9vIoATxu74v)ruHdwR41IkEPuBhNmXXAv2ugxTa)e6w1E2yTKoUokP64xP2EOde91(9jog1MF3HUvTDCYehRvbLzh8AFhTA74KjowRckZoQfoQ9Kj6hcyCT9yTmXb9Q9pWAFLOJwBp8SHETNnwlPJRJsQo(vQTh6arFTFFIJrT9yTq)Wm)MxTNnwBh3rRLzlUJtJRDe12JGoN1oedyTWJxQlSdg(GhMOJ5BGjLzId0zOoAAcOdymSb(LNmr)4sYeh1iZoubG0)wJFXNzRJM(SrnHyb5Ftvai9V14x8z26OPpButiwqEIec0hDcMCHDWW5sYeh10tzCCurK9puFqc8vr)BnUzId0zOoAAcOdWjef1JtyGqwP(lQ9D0Q9vIoAT2YWb9QLgrV2)abQf4Nq3Q2ZgRL0X1rRTh6arVX12JGoN1(hyTWR2lQD8Q)iQWbRv8ArfVuQTJtM4yTkBkJRwOx7zJ1(UIxHuD8RuBp0bIEEPUWoy4dEyIoMVbMuMjoqNH6OPjGoGXWgy6FRXLKjoQnJEm5Ftv0)wJNFh1rtBg9yYtKqG(OtWKlSdgoxsM4OMEkJJJkIS)H6dsGVk6FRXntCGod1rttaDaoHOOECcdeYk1f2bdFWdt0X8nWKssM4OMEkJZyydmqC8uaGIF6HPKGWtKqG(q5VNesaq6FRXtbak(PhMscI2WF6yk0Wj86YhNWar5QTu)f12XZEP7OwLjzkwyTYv7zJ1IoqTrR2o(vQT3g9AZV7q3Q2ZgRTJtM4yTkiljr4DRDIwOdiz3sDHDWWh8WeDmFdmPKKjoQPLmfl0yydm9V14sYeh1MrpM8VPk6FRXLKjoQnJEm5jsiqF0Pfdqv(DSfPfYLKjoQTLKi8UL6VO2oE2lDh1QmjtXcRvUApBSw0bQnA1E2yTVR4vQTh6arFT92OxB(Dh6w1E2yTDCYehRvbzjjcVBTt0cDaj7wQlSdg(GhMOJ5BGjLKmXrnTKPyHgdBGP)Tgp)oQJM2m6XK)nvr)BnUKmXrTz0Jjhi6Dv0)wJNFh1rtBg9yYtKqG(OtWwmav53XwKwixsM4O2wsIW7wQlSdg(GhMOJ5BGjLKmXrnbCmGtCymSbgaP)Tg)IpZwhn9zJAcXcY)MQozI(XLKjoQrMDOIC6FRXbq5SPJ0roq07KqIWoObuJosaXbyLitfas)Bn(fFMToA6Zg1eIfKNiHa9HYf2bdNljtCutahd4ehCurK9puFqc0yMTaDWkzmk5SRMzlqxdBGP)TgNnrjzY4GULMzlUJtoq07QiN(3ACjzIJAZOht(3Kesi)LNmr)4HbmnJEmravKt)BnE(DuhnTz0Jj)BscjSiMarVZrdbtoy48efGUKrgzL6c7GHp4Hj6y(gysjjtCutahd4ehgdBGP)TgNnrjzY4GUfFCcdeW0)wJZMOKmzCq3ItikQhNWarflmGU4h3a6ND3Suxyhm8bpmrhZ3atkjzIJAc4yaN4Wyydm9V14Sjkjtgh0T4jkStflIjq07CjzIJAZOhtEIec0hQiN(3A887OoAAZOht(3KesO)TgxsM4O2m6XK)njZyMTaDWkvQlSdg(GhMOJ5BGjLKmXrDK0gdBGP)TgxsM4OMzlPfYhNWaPtWgKek0tKFXrOjef1mBjTWrPUWoy4dEyIoMVbMusYeh10tzCgdBGP)Tgp)oQJM2m6XK)njHecXfUj7uUsVVuxyhm8bpmrhZ3atk0qWKdgUXWgy6FRXZVJ6OPnJEm5arVRI(3ACjzIJAZOhtoq07gd9dZ8BEAydmH4c3KDkhCh59gd9dZ8BEAibbcaLdbRuPUWoy4dEyIoMVbMusYeh10sMIfwQxQ)IxuRWoy4dEgNCWWbZeNHtTWoy4gdBGf2bdNJgcMCWW5mBXDCcDlveIlCt2PCWDO3RI8xMFhBrAH8b00oC94IKGesO)TgFanTdxpUij4JtyGaM(3A8b00oC94IKGtikQhNWaHSs9xu77EG1IgIAHTA7rqtS2z0xB41siUuR4a1YIyce9(OwjXAf64F1ErT0yTFZsDHDWWh8mo5GH)gysHgcMCWWng2a)Y87ylslKpGM2HRhxKeQiex4MSRtWgKek0tKJgcTj7urolIjq078l(mBD00NnQjeliprcb6JoblSdgohnem5GHZrfr2)q9bjqsiHfXei6DUKmXrTz0Jjprcb6JoblSdgohnem5GHZrfr2)q9bjqsiH8tMOF887OoAAZOhtvSiMarVZZVJ6OPnJEm5jsiqF0jyHDWW5OHGjhmCoQiY(hQpibsgzQO)Tgp)oQJM2m6XKde9Uk6FRXLKjoQnJEm5arVRcaP)Tg)IpZwhn9zJAcXcYbIEx1lnt0G2IbWvIFXNzRJM(SrnHybl1f2bdFWZ4Kdg(BGjfAiyYbd3yydC(DSfPfYhqt7W1JlscvVKfgqx8JBa9ZUBQIfXei6DUKmXrTz0Jjprcb6JoblSdgohnem5GHZrfr2)q9bjWsDHDWWh8mo5GH)gysHgcMCWWng2aNFhBrAH8b00oC94IKqflmGU4h3a6ND3uflIjq07CcyMro0rtFrsG(XtKqG(OtWc7GHZrdbtoy4CurK9puFqcuflIjq078l(mBD00NnQjeliprcb6JobtUbjHc9e5eXPntKHiG(IJqt39nHDWW5OHGjhmCoQiY(hQpib(whqMkwetGO35sYeh1MrpM8ejeOp6em5gKek0tKteN2mrgIa6locnD33e2bdNJgcMCWW5OIi7FO(Ge4BDazL6VOwLjzkwyTWwTWd0rThKaR9IA)dS2loIAfhO2ESwBXaw7frTeI3TwMTKw4Ouxyhm8bpJtoy4VbMusYeh10sMIfAmSbMfXei6D(fFMToA6Zg1eIfKNOa0vf50)wJljtCuZSL0c5JtyGOCdscf6jYV4i0eIIAMTKw4qflIjq07CjzIJAZOhtEIec0hDcgvez)d1hKavriUWnzNYnijuONixm1eqhs8j0eIlAt2PI(3A887OoAAZOhtoq07KvQlSdg(GNXjhm83atkjzIJAAjtXcng2aZIyce9o)IpZwhn9zJAcXcYtua6QIC6FRXLKjoQz2sAH8XjmquUbjHc9e5xCeAcrrnZwslCO6Kj6hp)oQJM2m6XuflIjq07887OoAAZOhtEIec0hDcgvez)d1hKavzqsOqpr(bjq93p4ulMk3GKqHEI8locnHOOgaNsxDlsTyswPUWoy4dEgNCWWFdmPKKjoQPLmfl0yydmlIjq078l(mBD00NnQjeliprbORkYP)TgxsM4OMzlPfYhNWar5gKek0tKFXrOjef1mBjTWHkYF5jt0pE(DuhnTz0JjjKWIyce9op)oQJM2m6XKNiHa9HYnijuONi)IJqtikQbWP0v3IuNHjzQmijuONi)GeO(7hCQftLBqsOqpr(fhHMquudGtPRUfPwmjRuxyhm8bpJtoy4VbMusYeh10sMIfAmSbgaP)TgpfaO4NEykjiAd)PJPqdNWRlFCcdeWai9V14Paaf)0dtjbrB4pDmfA4eED5eII6Xjmquro9V14sYeh1MrpMCGO3jHe6FRXLKjoQnJEm5jsiqF0jylgazQiN(3A887OoAAZOhtoq07Kqc9V1453rD00MrpM8ejeOp6eSfdGSsDHDWWh8mo5GH)gysjjtCutpLXzmSb2GKqHEI8o8)40)bcOhMsccjKqoas)BnEkaqXp9Wusq0g(thtHgoHxx(3ufas)BnEkaqXp9Wusq0g(thtHgoHxx(4egiDcG0)wJNcau8tpmLeeTH)0XuOHt41LtikQhNWaHSsDHDWWh8mo5GH)gysjjtCutpLXzmSbM(3ACZehOZqD00eqhG)nvbG0)wJFXNzRJM(SrnHyb5Ftvai9V14x8z26OPpButiwqEIec0hDcwyhmCUKmXrn9ughhvez)d1hKal1f2bdFWZ4Kdg(BGjLKmXrnbCmGtCymSbgaP)Tg)IpZwhn9zJAcXcY)MQozI(XLKjoQrMDOIC6FRXbq5SPJ0roq07KqIWoObuJosaXbyLitf5ai9V14x8z26OPpButiwqEIec0hkxyhmCUKmXrnbCmGtCWrfr2)q9bjqsiHfXei6DUzId0zOoAAcOdWtKqG(GesyHb0f)4G0nHItMXmBb6GvYyuYzxnZwGUg2at)BnoBIsYKXbDlnZwChNCGO3vro9V14sYeh1MrpM8VjjKq(lpzI(XddyAg9yIaQiN(3A887OoAAZOht(3KesyrmbIENJgcMCWW5jkaDjJmYk1FrTVo8XNaR9SXArfnfhabQ1mo0pOmRL(3A1kdXS2lQ1JR2zmWAnJd9dkZAnZGnk1f2bdFWZ4Kdg(BGjLKmXrnbCmGtCymSbM(3AC2eLKjJd6w8ef2PI(3ACurtXbqaTzCOFqzY)ML6c7GHp4zCYbd)nWKssM4OMaogWjomg2at)BnoBIsYKXbDlEIc7uro9V14sYeh1MrpM8VjjKq)BnE(DuhnTz0Jj)Bscjai9V14x8z26OPpButiwqEIec0hkxyhmCUKmXrnbCmGtCWrfr2)q9bjqYmMzlqhSsL6c7GHp4zCYbd)nWKssM4OMaogWjomg2at)BnoBIsYKXbDlEIc7ur)BnoBIsYKXbDl(4egiGP)TgNnrjzY4GUfNquupoHbIXmBb6GvQu)f12XZEP7O2l7w7f1sloi1(6xxBlYAzrmbIEV2EOde9JAP)xTaFcZApBKOwyR2Zg7cAI1k0X)Q9IArfnHjwQlSdg(GNXjhm83atkjzIJAc4yaN4Wyydm9V14Sjkjtgh0T4jkStf9V14Sjkjtgh0T4jsiqF0jyYjN(3AC2eLKjJd6w8XjmqEvc7GHZLKjoQjGJbCIdoQiY(hQpibs2BwmaoHOizgZSfOdwPsDHDWWh8mo5GH)gys54zJP(qctCCgdBGjpXwIdBHEIKqYlpideOBrMk6FRXLKjoQz2sAH8Xjmqat)BnUKmXrnZwslKtikQhNWarf9V14sYeh1MrpMCGO3vbG0)wJFXNzRJM(SrnHyb5arVxQlSdg(GNXjhm83atkjzIJ6iPng2at)BnUKmXrnZwslKpoHbsNGnijuONi)IJqtikQz2sAHJsDHDWWh8mo5GH)gysn(My6HbXyydSbjHc9e5X)gqauhnnlIjq07dveIlCt21j4o07l1f2bdFWZ4Kdg(BGjLKmXrn9ugNXWgy6FRXZ)e1rtF2jId(3uf9V14sYeh1mBjTq(4egikVdk1FrTkC9jmRLzlPfoQf2QThRTjZzT04m6R9SXAzHpW0awlH4sTNDId7ycuR4a1IgcMCWWRfoQDCW5S2WRLfXei69sDHDWWh8mo5GH)gysjjtCutlzkwOXWg4xMFhBrAH8b00oC94IKqLbjHc9e5X)gqauhnnlIjq07dv0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNquupoHbIQtMOFCjzIJ6iPvXIyce9oxsM4OosAEIec0hDc2IbOIqCHBYUob3HuRkwetGO35OHGjhmCEIec0hL6c7GHp4zCYbd)nWKssM4OMwYuSqJHnW53XwKwiFanTdxpUijuzqsOqprE8Vbea1rtZIyce9(qf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjef1JtyGO6Kj6hxsM4OosAvSiMarVZLKjoQJKMNiHa9rNGTyaQiex4MSRtWDi1QIfXei6DoAiyYbdNNiHa9rNDGAl1FrTkC9jmRLzlPfoQf2Qns6AHJAtua6wQlSdg(GNXjhm83atkjzIJAAjtXcng2aBqsOqprE8Vbea1rtZIyce9(qf9V14sYeh1mBjTq(4egiGP)TgxsM4OMzlPfYjef1JtyGO6Kj6hxsM4OosAvSiMarVZLKjoQJKMNiHa9rNGTyaQiex4MSRtWDi1QIfXei6DoAiyYbdNNiHa9HkYFz(DSfPfYhqt7W1JlscsiH(3A8b00oC94IKGNiHa9rNGvQJqwP(lQTJtM4yTktYuSWAh2XFcuRf6ykZz3APXApBS2PmUAzY4QnA1E2yTD8RuBp0bI(sDHDWWh8mo5GH)gysjjtCutlzkwOXWgy6FRXLKjoQnJEm5Ftv0)wJljtCuBg9yYtKqG(OtWwmav0)wJljtCuZSL0c5JtyGaM(3ACjzIJAMTKwiNquupoHbIkYzrmbIENJgcMCWW5jsiqFqcj53XwKwixsM4O2wsIW7swP(lQTJtM4yTktYuSWAh2XFcuRf6ykZz3APXApBS2PmUAzY4QnA1E2yTVR4vQTh6arFPUWoy4dEgNCWWFdmPKKjoQPLmfl0yydm9V1453rD00MrpM8VPk6FRXLKjoQnJEm5arVRI(3A887OoAAZOhtEIec0hDc2IbOI(3ACjzIJAMTKwiFCcdeW0)wJljtCuZSL0c5eII6XjmqurolIjq07C0qWKdgoprcb6dsij)o2I0c5sYeh12sseExYk1FrTDCYehRvzsMIfw7Wo(tGAPXApBS2PmUAzY4QnA1E2yTKoUoAT9qhi6Rf2QfE1ch16Xv7FGa12dp7AFxXRuBK12XVsPUWoy4dEgNCWWFdmPKKjoQPLmfl0yydm9V14sYeh1MrpMCGO3vr)BnE(DuhnTz0Jjhi6Dvai9V14x8z26OPpButiwq(3ufas)Bn(fFMToA6Zg1eIfKNiHa9rNGTyaQO)TgxsM4OMzlPfYhNWabm9V14sYeh1mBjTqoHOOECcdKs9xuRcVn61E2yTNKw4vlCul0Rfvez)dRnf3cRvCGApBmXAHJAjIeR9SfV2WXArhj6ACT)bwlTKPyH1kJAhr41kJA7g)ATfdyTOhFl7Az2sAHJAVOwB4vRmN1IosaXrTWwTNnwBhNmXXAvwqqljab6xTt0cDaj7wlCul(Q)qtteOuxyhm8bpJtoy4VbMusYeh10sMIfAmSb2GKqHEICKWm6Xeb00sMIfQI(3ACjzIJAMTKwiFCcdeLdMCHDqdOgDKaIJomLitLWoObuJosaXHYvsf9V14aOC20r6ihi69sDHDWWh8mo5GH)gysjjtCuJkAoJbmCJHnWgKek0tKJeMrpMiGMwYuSqv0)wJljtCuZSL0c5JtyG0j9V14sYeh1mBjTqoHOOECcdevc7Ggqn6ibehkxjv0)wJdGYzthPJCGO3l1f2bdFWZ4Kdg(BGjLKmXrn9ugxPUWoy4dEgNCWWFdmPqdbtoy4gdBGnijuONip(3acG6OPzrmbIEFuQlSdg(GNXjhm83atkjzIJAAjtXcPEK)zhj1ZdK4pLdg(RtPDuh1rrb]] )


end