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


    spec:RegisterPack( "Arcane", 20220315, [[defHPhqifipsvkUefcvXMijFcigfkXPquTkfq5vQs1SOqDlGuPDHQFbKmmfGJHOSmerpdiLPPGIRPkL2gqQ6BkG04uGQZrHOwhkj9okeQsnpfK7bu7JcPdQaLfIsQhQGQjsHiYfPqiBKcHQYhPqe1iPqOYjPqqRKKQxsHqvYmrjXnvav7KKIFsHqzOkO0sPqGNQqtfr4QkGWwPqOQ6RuisJLKs7fH)sQbR0HjwmjEmstgWLH2SK(mLA0uYPbTAfq0RrKMTIUnk2nv)wy4u0Xbsflx0ZLy6QCDv12PGVRkgpkvNxvY6PqeMpkL9l1eKrqcIra5qc1qYbqssoaqJS3YjBWj5af0a9eJ3ltKy0uOKk2iXOlmiX4GLuXrIrt51meacsqmwIFsrIrR7mlSkOaLn8S(kCAWaQcK5pLdgonL6bQcKHckIrLpCEgHoHcXiGCiHAi5aijjhaOr2B5Kn4KCGcAKKySyIuc1a6jjXOfeaaDcfIraSqjgh4In27GLuXXw9bUKuREj7Tg3ljhajjzRER(WTe3glSARoOBVdefS37LjKkZEhHmdVxlXbMq3U3O2l1sChN9c9dZ8BEWW7f6LdfGEJAVGqfNItTqpy4GWB1bD7D4wIBJ9kjvCud9k0H3REVOxjPIJAljzc)vVSaVED0aM9(G(17eAa7vk9kjvCuBjjt4ViN3Qd62RrsHdY1RrKHGkh2l07DWmIze17a5VC9QGu5xWEFfFqsS34F9g1EtXTXEfhOxpUE)fOB37GLuXXEnIy3Cgfy48wDq3EhmGbYF561mHrcVx9ErV)c27GLuXXEh24btqk9I1kspObSxAetG4X7vrkiqVH37WnsYiOxSwr6v4T6GU9oquWElxcPxVMzqXsb629ErVjc8PyVdFyhi69GmyVaFS3l697osXsrYx9oydlR0Bnssl8wDq3Eh4HbeOxdscfLjwafvM0)uoy4LEVOxw5l9Yea)j27f9MiWNI9o8HDGO3dYGCIXjSCfcsqmgMOJjbjiudzeKGyeDrzIaeSMyKMWdtOqmMFhRrAJCayHcnNqxYxAAWWioahDrzIa9QQxLFTYbGfk0CcDjFPPbdJ4a6AgLJ)njgf6bdNySctuRmLYrCeQHKeKGyeDrzIaeSMyKMWdtOqmMFhRrAJC7ewMV0qkKoro6IYeb6vvVmIlCt61Rr71i)wIrHEWWjgRzuoThgeIJqnGgbjigrxuMiabRjgDHbjglXFoX7GUTo)kVigf6bdNySe)5eVd6268R8I4iuZWqqcIrHEWWjgbq5SuI0rIr0fLjcqWAIJqnVLGeeJOlkteGG1eJ0eEycfIrgXfUj961O9omdGyuOhmCIXuaGIF6IPKKsCeQb0tqcIrHEWWjgzGzgzrhv9fjd6hXi6IYebiynXrOMbkbjigrxuMiabRjgPj8WekeJk)ALljvCuBgpyYbIhVxv9sJycepoxsQ4O2mEWKNiJa9cXOqpy4eJfly9GUT2mEWK4iuZGtqcIr0fLjcqWAIrAcpmHcXinIjq84CjPIJAZ4btEIcWREv1RYVw5ssfh1uljTrE5ekP9ouVk)ALljvCutTK0g5mc76Yjusjgf6bdNyusQ4OosfIJqngzcsqmIUOmracwtmst4HjuigPHb0f)4gq)SEL9QQxAetG4X5mWmJSOJQ(IKb9JNiJa9sVgT3bFyigf6bdNyusQ4OwzkLJ4iudzdGGeeJc9GHtmEXNAPJQ(SqnJydjgrxuMiabRjoc1qgzeKGyuOhmCIrjPIJAZ4btIr0fLjcqWAIJqnKrscsqmIUOmracwtmst4Hjuigv(1kxsQ4O2mEWKdepoXOqpy4eJ53rDu1MXdMehHAid0iibXi6IYebiynXOqpy4eJMjwqNI6OQzGoaXiawOj08GHtmoquWEh2yG37f9waD(iAKa7v8Er2Vu6DWsQ4yVSEkLRxGFcD7EplSxse3ahud2W27d0bINE)(elLEZV7q3U3blPIJ9AerTcEVgH1EhSKko2Rre1k6fw69Kj6hcyCVpyVuXb569xWEh2yG37d8SGEVNf2ljIBGdQbBy79b6aXtVFFILsVpyVq)Wm)MxVNf27GnW7LAjUJtJ7Te9(GGmN9wedyVWJtmst4HjuighuVNmr)4ssfh1i1k4OlkteOxv9cGk)ALFXNAPJQ(SqnJyd5FZEv1laQ8Rv(fFQLoQ6Zc1mInKNiJa9sVdbUxw6vOhmCUKuXrTYukhhzhP)d1hKb7DG1RYVw5MjwqNI6OQzGoaNryxxoHsAVKtCeQHSHHGeeJOlkteGG1eJc9GHtmAMybDkQJQMb6aeJayHMqZdgoXOryT3Hng49AjfhKRxfe9E)feOxGFcD7EplSxse3aV3hOdepg37dcYC27VG9cVEVO3cOZhrJeyVI3lY(LsVdwsfh7L1tPC9c9EplSxJGyyb1GnS9(aDG4Htmst4Hjuigv(1kxsQ4O2mEWK)n7vvVk)ALNFh1rvBgpyYtKrGEP3Ha3ll9k0dgoxsQ4OwzkLJJSJ0)H6dYG9oW6v5xRCZelOtrDu1mqhGZiSRlNqjTxYjoc1q2BjibXi6IYebiynXinHhMqHyeioEkaqXpDXuss5jYiqV0Rr79T9YgB9cGk)ALNcau8txmLKuTH)0XuuGt49IxoHsAVgT3bqmk0dgoXOKuXrTYukhXrOgYa9eKGyeDrzIaeSMyuOhmCIrjPIJAfjtXgjgbWcnHMhmCIXbB(iVk9YAjtXg7vUEplSx0b6nQ9oydBVpwO3B(Dh629EwyVdwsfh71iojzc)vVt0gDajFrmst4Hjuigv(1kxsQ4O2mEWK)n7vvVk)ALljvCuBgpyYtKrGEP3H61Mc0RQEZVJ1iTrUKuXrTLKmH)IJUOmraIJqnKnqjibXi6IYebiynXOqpy4eJssfh1ksMInsmcGfAcnpy4eJd28rEv6L1sMIn2RC9EwyVOd0Bu79SWEncIHT3hOdep9(yHEV53DOB37zH9oyjvCSxJ4KKj8x9orB0bK8fXinHhMqHyu5xR887OoQAZ4bt(3Sxv9Q8RvUKuXrTz8GjhiE8Ev1RYVw553rDu1MXdM8ezeOx6DiW9Atb6vvV53XAK2ixsQ4O2ssMWFXrxuMiaXrOgYgCcsqmIUOmracwtmsTeOtmsgXik58LMAjqxdReJk)ALtNOKuPCq3wtTe3XjhiECvSO8RvUKuXrTz8Gj)BYgBSmOtMOF8WaMMXdMiGkwu(1kp)oQJQ2mEWK)nzJnAetG4X5OHGkhmCEIcWlYjNCIrAcpmHcXiaQ8Rv(fFQLoQ6Zc1mInK)n7vvVNmr)4ssfh1i1k4OlkteOxv9YsVk)ALdGYzPePJCG4X7Ln26vOh0aQrhzGyPxW9swVK3RQEbqLFTYV4tT0rvFwOMrSH8ezeOx61O9k0dgoxsQ4OMbwkWjw4i7i9FO(GmiXOqpy4eJssfh1mWsboXcXrOgYmYeKGyeDrzIaeSMyKMWdtOqmQ8RvoDIssLYbDBE5ekP9cUxLFTYPtusQuoOBZze21LtOK2RQEPHb0f)4gq)SELeJc9GHtmkjvCuZalf4elehHAi5aiibXi6IYebiynXOqpy4eJssfh1mWsboXcXi1sGoXizeJ0eEycfIrLFTYPtusQuoOBZtuOxVQ6LgXeiECUKuXrTz8Gjprgb6LEv1ll9Q8RvE(DuhvTz8Gj)B2lBS1RYVw5ssfh1MXdM8VzVKtCeQHKKrqcIr0fLjcqWAIrAcpmHcXOYVw5ssfh1uljTrE5ekP9oe4EnijuuMi)IJrZiSRPwsAJfIrHEWWjgLKkoQJuH4iudjjjbjigrxuMiabRjgPj8WekeJk)ALNFh1rvBgpyY)M9YgB9YiUWnPxVgTxYElXOqpy4eJssfh1ktPCehHAijOrqcIr0fLjcqWAIrHEWWjgrdbvoy4eJq)Wm)MNgwjgzex4M0ZOGh83smc9dZ8BEAiddcaLdjgjJyKMWdtOqmQ8RvE(DuhvTz8GjhiE8Ev1RYVw5ssfh1MXdMCG4Xjoc1qYHHGeeJc9GHtmkjvCuRizk2iXi6IYebiynXrCeJvyXc626WeDmjibHAiJGeeJOlkteGG1eJc9GHtmIgcQCWWjgbWcnHMhmCIrJul07n)UdD7Er4zHzVNf274yVr2ljms7DI2Odijelg37d27J4xVx0RrKHOxfSgj27zH9sI4g4GAWg2EFGoq8W7DGOG9cVELsVLi8ELsVgbXW2RLu6TcDyXcb6n(zVpiigWElMOF9g)SxQLK2yHyKMWdtOqmYsV53XAK2i)qgZiLP(rsto6IYeb6Ln26LLEZVJ1iTrEbAAfUUCrYWrxuMiqVQ6Dq9AqsOOmrUzIM)5uJgIEb3lz9sEVK3RQEzPxLFTYZVJ6OQnJhm5aXJ3lBS1RzIg02uaozCjPIJAfjtXg7L8Ev1lnIjq84887OoQAZ4btEImc0lehHAijbjigrxuMiabRjgf6bdNyeneu5GHtmcGfAcnpy4eJgH1EFqqmG9wHoSyHa9g)SxAetG4X79b6aXtPxXb6TyI(1B8ZEPwsAJfJ71mHrcpOrcSxJidrVHbm7fnG5RZc629IZcsmst4HjuigpzI(XZVJ6OQnJhm5OlkteOxv9sJycepop)oQJQ2mEWKNiJa9sVQ6LgXeiECUKuXrTz8Gjprgb6LEv1RYVw5ssfh1MXdMCG4X7vvVk)ALNFh1rvBgpyYbIhVxv9AMObTnfGtgxsQ4OwrYuSrIJqnGgbjigrxuMiabRjgPj8WekeJ53XAK2ihawOqZj0L8LMgmmIdWrxuMiqVQ6v5xRCayHcnNqxYxAAWWioGUMr54FtIrHEWWjgRWe1ktPCehHAggcsqmIUOmracwtmst4HjuigZVJ1iTrUDclZxAifsNihDrzIa9QQxgXfUj961O9AKFlXOqpy4eJ1mkN2ddcXrOM3sqcIr0fLjcqWAIrHEWWjgLKkoQzGLcCIfIrQLaDIrYigPj8WekeJ53XAK2ixsQ4O2ssMWFXrxuMiqVQ6v5xRCjPIJAljzc)fVCcL0EhQxLFTYLKkoQTKKj8xCgHDD5ekP9QQxw6LLEv(1kxsQ4O2mEWKdepEVQ6LgXeiECUKuXrTz8Gjprb4vVK3lBS1laQ8Rv(fFQLoQ6Zc1mInK)n7LCIJqnGEcsqmIUOmracwtmst4HjuigPHd8Hh3gwpDu1NfQNqQfXOqpy4eJaOCwkr6iXrOMbkbjigrxuMiabRjgPj8WekeJ53XAK2iVanTcxxUiz4OlkteGyuOhmCIX87OoQAZ4btIJqndobjigrxuMiabRjgPj8WekeJ0iMaXJZZVJ6OQnJhm5jkaVigf6bdNyusQ4OosfIJqngzcsqmIUOmracwtmst4HjuigPrmbIhNNFh1rvBgpyYtuaE1RQEv(1kxsQ4OMAjPnYlNqjT3H6v5xRCjPIJAQLK2iNryxxoHskXOqpy4eJssfh1ktPCehHAiBaeKGyeDrzIaeSMyKMWdtOqmEqgSxJcU332779YsVK17aR3cEALW)f(bXKKdUEymP9soXOqpy4eJmWmJSOJQ(IKb9J4iudzKrqcIr0fLjcqWAIrHEWWjgzIWNWtBMWcdXinHhMqHy8GmyVgTxqpXOlmiXite(eEAZewyioc1qgjjibXOqpy4eJ53rDu1MXdMeJOlkteGG1ehHAid0iibXi6IYebiynXOqpy4eJssfh1mWsboXcXiawOj08GHtmAew79bbjXELRxgH9ElNqjT0Bu7D4dVxXb69b71smGoixV)cc07apirVVWZ4E)fSxP3Yjus79IEnt0a6xVmFNAbD7E)(elLEZV7q3U3Zc71iojzc)vVt0gDajFrmst4Hjuigv(1kNorjPs5GUnprHE9QQxLFTYPtusQuoOBZlNqjTxW9Q8RvoDIssLYbDBoJWUUCcL0Ev1lnmGU4h3a6N1RSxv9sJycepoNbMzKfDu1xKmOF8efGx9QQ3b1RbjHIYe5iJz8GjcOvKmfBSxv9sJycepoxsQ4O2mEWKNOa8I4iudzddbjigrxuMiabRjgPj8WekeJdQ387ynsBKFiJzKYu)iPjhDrzIa9QQxw6Dq9MFhRrAJ8c00kCD5IKHJUOmrGEzJTEzPxdscfLjYnt08pNA0q0l4EjRxv9Q8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHsAVK3l5eJayHMqZdgoXOAIKrMZx9(G9AkWSxZ4GH37VG9(apREhSH14Ev(xVWR3h4C27ukxVZWT7f94BB1BnYEvIZQ3Zc71iig2EfhO3bBy79b6aXtP3VpXsP387o0T79SWEhh7nYEjHrAVt0gDajHyHyuOhmCIrZ4GHtCeQHS3sqcIr0fLjcqWAIrAcpmHcXOYVw553rDu1MXdMCG4X7Ln261mrdABkaNmUKuXrTIKPyJeJc9GHtmcGYzPePJehHAid0tqcIr0fLjcqWAIrAcpmHcXOYVw553rDu1MXdMCG4X7Ln261mrdABkaNmUKuXrTIKPyJeJc9GHtmMcau8txmLKuIJqnKnqjibXi6IYebiynXinHhMqHyu5xR887OoQAZ4btEImc0l9ouVS0lOV337LK9oW6n)owJ0g5fOPv46YfjdhDrzIa9soXOqpy4eJmWmJSOJQ(IKb9J4iudzdobjigrxuMiabRjgf6bdNyusQ4O2mEWKyeal0eAEWWjgnsTqV387o0T79SWEnItsMWF17eTrhqYxg37VG9oydBVkynsSxse3aV3l6f4Zy2R0B9pNV6TCcLueOxfjtXgjgPj8WekeJgKekktKJmMXdMiGwrYuSXEv1RYVw553rDu1MXdM8VzVQ6LLEzex4M0R3H6LLEj5B799EzPxYgqVdSEPHb0f)4K(kHI3l59sEVSXwVk)ALtNOKuPCq3MxoHsAVG7v5xRC6eLKkLd62CgHDD5ekP9soXrOgYmYeKGyeDrzIaeSMyKMWdtOqmAqsOOmroYygpyIaAfjtXg7vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEv(1kxsQ4O2mEWK)njgf6bdNyusQ4OwrYuSrIJqnKCaeKGyeDrzIaeSMyuOhmCIXs8Nt8oOBRZVYlIrAcpmHcXOYVw553rDu1MXdMCG4X7Ln261mrdABkaNmUKuXrTIKPyJ9YgB9AMObTnfGtgpfaO4NUykjP9YgB9YsVMjAqBtb4KXbq5SuI0XEv17G6n)owJ0g5fOPv46YfjdhDrzIa9soXOlmiXyj(ZjEh0T15x5fXrOgssgbjigrxuMiabRjgPj8WekeJk)ALNFh1rvBgpyYbIhVx2yRxZenOTPaCY4ssfh1ksMIn2lBS1RzIg02uaoz8uaGIF6IPKK2lBS1ll9AMObTnfGtghaLZsjsh7vvVdQ387ynsBKxGMwHRlxKmC0fLjc0l5eJc9GHtmEXNAPJQ(SqnJydjoc1qsssqcIr0fLjcqWAIrAcpmHcXOzIg02uaoz8l(ulDu1NfQzeBiXOqpy4eJssfh1MXdMehHAijOrqcIr0fLjcqWAIrHEWWjgntSGof1rvZaDaIraSqtO5bdNyCGOG9oSXaV3l6Ta68r0ib2R49ISFP07GLuXXEz9ukxVa)e629EwyVKiUboOgSHT3hOdep9(9jwk9MF3HUDVdwsfh71iIAf8EncR9oyjvCSxJiQv0lS07jt0peW4EFWEPIdY17VG9oSXaV3h4zb9EplSxse3ahud2W27d0bINE)(elLEFWEH(Hz(nVEplS3bBG3l1sChNg3Bj69bbzo7TigWEHhNyKMWdtOqmoOEpzI(XLKkoQrQvWrxuMiqVQ6fav(1k)Ip1shv9zHAgXgY)M9QQxau5xR8l(ulDu1NfQzeBiprgb6LEhcCVS0Rqpy4CjPIJALPuooYos)hQpid27aRxLFTYntSGof1rvZaDaoJWUUCcL0EjN4iudjhgcsqmIUOmracwtmk0dgoXOzIf0POoQAgOdqmcGfAcnpy4eJgH1Eh2yG3RLuCqUEvq079xqGEb(j0T79SWEjrCd8EFGoq8yCVpiiZzV)c2l869IElGoFensG9kEVi7xk9oyjvCSxwpLY1l079SWEncIHfud2W27d0bIhoXinHhMqHyu5xRCjPIJAZ4bt(3Sxv9Q8RvE(DuhvTz8Gjprgb6LEhcCVS0Rqpy4CjPIJALPuooYos)hQpid27aRxLFTYntSGof1rvZaDaoJWUUCcL0EjN4iudjFlbjigrxuMiabRjgPj8WekeJaXXtbak(PlMsskprgb6LEnAVVTx2yRxau5xR8uaGIF6IPKKQn8NoMIcCcVx8Yjus71O9oaIrHEWWjgLKkoQvMs5ioc1qsqpbjigrxuMiabRjgf6bdNyusQ4OwrYuSrIraSqtO5bdNy0if79r8R3l6Lrif7T8tS3hSxlXa2l6X32QxgXLERr27zH9I(btS3bBy79b6aXJX9IgqVxyT3ZcteKsVLdoN9EqgS3ezeOdD7EdVxJGyy59AeEGu6n85REvW7WS3l6v5NEVx0RrcmJEfhOxJidrVWAV53DOB37zH9oo2BK9scJ0ENOn6ascXcNyKMWdtOqmsJycepoxsQ4O2mEWKNOa8Qxv9YiUWnPxVd1ll9omdO337LLEjBa9oW6Lggqx8Jt6RekEVK3l59QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVS07G6n)owJ0g5fOPv46YfjdhDrzIa9YgB9AqsOOmrUzIM)5uJgIEb3lz9sEVQ6Dq9MFhRrAJ8dzmJuM6hjn5OlkteOxv9oOEZVJ1iTrUKuXrTLKmH)IJUOmraIJqnKCGsqcIr0fLjcqWAIrHEWWjgLKkoQvKmfBKyeal0eAEWWjgzTKPyJ9wSI)eOxpUEvWE)feOx569SWErhO3O27GnS9cR9AeziOYbdVxyP3efGx9kLEbYW0e629sTK0gl9(aNZEzesXEHxVNqk27mCBm79IEv(P37zLX32Q3ezeOdD7EzexigPj8WekeJk)ALljvCuBgpyY)M9QQxLFTYLKkoQnJhm5jYiqV07qG71Mc0RQEPrmbIhNJgcQCWW5jYiqVqCeQHKdobjigrxuMiabRjgf6bdNyusQ4OwrYuSrIraSqtO5bdNyK1sMIn2BXk(tGEL5J8Q0Rc27zH9oLY1lvkxVqV3Zc71iig2EFGoq80Ru6LeXnW79boN9My5Ie79SWEPwsAJLElMOFeJ0eEycfIrLFTYZVJ6OQnJhm5FZEv1RYVw5ssfh1MXdMCG4X7vvVk)ALNFh1rvBgpyYtKrGEP3Ha3RnfOxv9oOEZVJ1iTrUKuXrTLKmH)IJUOmraIJqnK0itqcIr0fLjcqWAIrQLaDIrYigrjNV0ulb6AyLyu5xRC6eLKkLd62AQL4oo5aXJRIfLFTYLKkoQnJhm5Ft2yJLbDYe9JhgW0mEWebuXIYVw553rDu1MXdM8VjBSrJycepohneu5GHZtuaEro5Ktmst4HjuigbqLFTYV4tT0rvFwOMrSH8VzVQ69Kj6hxsQ4OgPwbhDrzIa9QQxw6v5xRCauolLiDKdepEVSXwVc9Ggqn6idel9cUxY6L8Ev1laQ8Rv(fFQLoQ6Zc1mInKNiJa9sVgTxHEWW5ssfh1mWsboXchzhP)d1hKbjgf6bdNyusQ4OMbwkWjwioc1aAdGGeeJOlkteGG1eJc9GHtmkjvCuZalf4eleJayHMqZdgoXOryT3heKe71a6N1R04EHmmiauoC(Q3Fb7D4dV3hl07LkMMiqVx0RhxVps5WEnZGw6TMbtVd8GeeJ0eEycfIrAyaDXpUb0pRxzVQ6v5xRC6eLKkLd628Yjus7fCVk)ALtNOKuPCq3MZiSRlNqjL4iudOrgbjigrxuMiabRjgbWcnHMhmCIXXtYR3Fb629o8H37GnW79Xc9EhSHTxlP0RcIEV)ccqmst4Hjuigv(1kNorjPs5GUnprHE9QQxAetG4X5ssfh1MXdM8ezeOx6vvVS0RYVw553rDu1MXdM8VzVSXwVk)ALljvCuBgpyY)M9soXi1sGoXizeJc9GHtmkjvCuZalf4elehHAanssqcIr0fLjcqWAIrAcpmHcXOYVw5ssfh1uljTrE5ekP9oe4EnijuuMi)IJrZiSRPwsAJfIrHEWWjgLKkoQJuH4iudObAeKGyeDrzIaeSMyKMWdtOqmQ8RvE(DuhvTz8Gj)B2lBS1lJ4c3KE9A0Ej7TeJc9GHtmkjvCuRmLYrCeQb0ggcsqmIUOmracwtmk0dgoXiAiOYbdNye6hM5380WkXiJ4c3KEgf8G)wIrOFyMFZtdzyqaOCiXizeJ0eEycfIrLFTYZVJ6OQnJhm5aXJ3RQEv(1kxsQ4O2mEWKdepoXrOgq7TeKGyuOhmCIrjPIJAfjtXgjgrxuMiabRjoIJymJtoy4eKGqnKrqcIr0fLjcqWAIrHEWWjgLKkoQvKmfBKyeal0eAEWWjghikyVOHOxyT3heKe7Dgp9gEVmIl9koqV0iMaXJx6vsSxrj(xVx0Rc273KyKMWdtOqmwWtRe(VWpiMKCW1K0K2RQEPHb0f)4gq)SEL9QQxAetG4X553rDu1MXdM8ezeOx6DiW9ISJ0)H6dYG9QQxAetG4X5x8Pw6OQpluZi2qEImc0l9ouVGwVQ6LLEv(1kxsQ4OMAjPnYlNqjTxJ2RbjHIYe5xCmAgHDn1ssBS0RQEpzI(XZVJ6OQnJhm5OlkteOxv9AqsOOmr(bzq93p4ulM9A0EnijuuMi)IJrZiSRbWP8sxJulM9soXrOgssqcIr0fLjcqWAIrAcpmHcXil9oOEl4Pvc)x4hetso4AsAs7Ln26Dq9sddOl(XnG(z9k7L8Ev1lnIjq848l(ulDu1NfQzeBiprb4vVQ6LLEv(1kxsQ4OMAjPnYlNqjTxJ2RbjHIYe5xCmAgHDn1ssBS0RQEPrmbIhNljvCuBgpyYtKrGEP3Ha3lYos)hQpid2RQEzex4M0RxJ2RbjHIYe5IPMb6qMpJMrCrBsVEv1RYVw553rDu1MXdMCG4X7LCIrHEWWjgLKkoQvKmfBK4iudOrqcIr0fLjcqWAIrAcpmHcXil9oOEl4Pvc)x4hetso4AsAs7Ln26Dq9sddOl(XnG(z9k7L8Ev1lnIjq848l(ulDu1NfQzeBiprb4vVQ6LLEv(1kxsQ4OMAjPnYlNqjTxJ2RbjHIYe5xCmAgHDn1ssBS0RQEpzI(XZVJ6OQnJhm5OlkteOxv9sJycepop)oQJQ2mEWKNiJa9sVdbUxKDK(puFqgSxv9AqsOOmr(bzq93p4ulM9A0EnijuuMi)IJrZiSRbWP8sxJulM9soXOqpy4eJssfh1ksMInsCeQzyiibXi6IYebiynXinHhMqHyKLEhuVf80kH)l8dIjjhCnjnP9YgB9oOEPHb0f)4gq)SEL9sEVQ6LgXeiEC(fFQLoQ6Zc1mInKNOa8Qxv9YsVk)ALljvCutTK0g5LtOK2Rr71GKqrzI8lognJWUMAjPnw6vvVS07G69Kj6hp)oQJQ2mEWKJUOmrGEzJTEPrmbIhNNFh1rvBgpyYtKrGEPxJ2RbjHIYe5xCmAgHDnaoLx6AK6mm7L8Ev1RbjHIYe5hKb1F)GtTy2Rr71GKqrzI8lognJWUgaNYlDnsTy2l5eJc9GHtmkjvCuRizk2iXrOM3sqcIr0fLjcqWAIrAcpmHcXiaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekP9cUxau5xR8uaGIF6IPKKQn8NoMIcCcVxCgHDD5ekP9QQxw6v5xRCjPIJAZ4btoq849YgB9Q8RvUKuXrTz8Gjprgb6LEhcCV2uGEjVxv9YsVk)ALNFh1rvBgpyYbIhVx2yRxLFTYZVJ6OQnJhm5jYiqV07qG71Mc0l5eJc9GHtmkjvCuRizk2iXrOgqpbjigrxuMiabRjgPj8WekeJgKekktKpq(lN(xqaDXuss7Ln26LLEbqLFTYtbak(PlMssQ2WF6ykkWj8EX)M9QQxau5xR8uaGIF6IPKKQn8NoMIcCcVx8Yjus7DOEbqLFTYtbak(PlMssQ2WF6ykkWj8EXze21LtOK2l5eJc9GHtmkjvCuRmLYrCeQzGsqcIr0fLjcqWAIrAcpmHcXOYVw5MjwqNI6OQzGoa)B2RQEbqLFTYV4tT0rvFwOMrSH8VzVQ6fav(1k)Ip1shv9zHAgXgYtKrGEP3Ha3Rqpy4CjPIJALPuooYos)hQpidsmk0dgoXOKuXrTYukhXrOMbNGeeJOlkteGG1eJulb6eJKrmIsoFPPwc01WkXOYVw50jkjvkh0T1ulXDCYbIhxflk)ALljvCuBgpyY)MSXgld6Kj6hpmGPz8GjcOIfLFTYZVJ6OQnJhm5Ft2yJgXeiECoAiOYbdNNOa8ICYjNyKMWdtOqmcGk)ALFXNAPJQ(SqnJyd5FZEv17jt0pUKuXrnsTco6IYeb6vvVS0RYVw5aOCwkr6ihiE8EzJTEf6bnGA0rgiw6fCVK1l59QQxw6fav(1k)Ip1shv9zHAgXgYtKrGEPxJ2Rqpy4CjPIJAgyPaNyHJSJ0)H6dYG9YgB9sJycepo3mXc6uuhvnd0b4jYiqV0lBS1lnmGU4hN0xju8EjNyuOhmCIrjPIJAgyPaNyH4iuJrMGeeJOlkteGG1eJc9GHtmkjvCuZalf4eleJayHMqZdgoX4WdV8zWEplSxKDtXbqGEnJd9dkZEv(1AVsrm79IE946DgfSxZ4q)GYSxZmOfIrAcpmHcXOYVw50jkjvkh0T5jk0Rxv9Q8RvoYUP4aiG2mo0pOm5FtIJqnKnacsqmIUOmracwtmk0dgoXOKuXrndSuGtSqmsTeOtmsgXinHhMqHyu5xRC6eLKkLd628ef61RQEzPxLFTYLKkoQnJhm5FZEzJTEv(1kp)oQJQ2mEWK)n7Ln26fav(1k)Ip1shv9zHAgXgYtKrGEPxJ2Rqpy4CjPIJAgyPaNyHJSJ0)H6dYG9soXrOgYiJGeeJOlkteGG1eJc9GHtmkjvCuZalf4eleJulb6eJKrmst4Hjuigv(1kNorjPs5GUnprHE9QQxLFTYPtusQuoOBZlNqjTxW9Q8RvoDIssLYbDBoJWUUCcLuIJqnKrscsqmIUOmracwtmcGfAcnpy4eJd28rEv69Yx9ErVkItAVdF49wJSxAetG4X79b6aXtPxL)1lWNXS3Zcz6fw79SWxGKyVIs8VEVOxKDtyIeJ0eEycfIrLFTYPtusQuoOBZtuOxVQ6v5xRC6eLKkLd628ezeOx6DiW9YsVS0RYVw50jkjvkh0T5LtOK27aRxHEWW5ssfh1mWsboXchzhP)d1hKb7L8EFVxBkaNryVxYjgPwc0jgjJyuOhmCIrjPIJAgyPaNyH4iudzGgbjigrxuMiabRjgPj8WekeJS0BI1elwIYe7Ln26Dq9EqkPq3UxY7vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEv(1kxsQ4O2mEWKdepEVQ6fav(1k)Ip1shv9zHAgXgYbIhNyuOhmCIrhplm1hYyILJ4iudzddbjigrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK27qG71GKqrzI8lognJWUMAjPnwigf6bdNyusQ4OosfIJqnK9wcsqmIUOmracwtmst4HjuignijuuMip(xbcG6OQPrmbIhV0RQEzex4M0R3Ha3Rr(TeJc9GHtmw(My6HbH4iudzGEcsqmIUOmracwtmst4Hjuigv(1kp)tuhv9zLiw4FZEv1RYVw5ssfh1uljTrE5ekP9A0EbnIrHEWWjgLKkoQvMs5ioc1q2aLGeeJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmAK0NXSxQLK2yPxyT3hS3QmN9QGZ4P3Zc7LgEbtdyVmIl9EwjwSIjqVId0lAiOYbdVxyP3YbNZEdVxAetG4XjgPj8WekeJdQ387ynsBKxGMwHRlxKmC0fLjc0RQEnijuuMip(xbcG6OQPrmbIhV0RQEv(1kxsQ4OMAjPnYlNqjTxW9Q8RvUKuXrn1ssBKZiSRlNqjTxv9EYe9JljvCuhPchDrzIa9QQxAetG4X5ssfh1rQWtKrGEP3Ha3RnfOxv9YiUWnPxVdbUxJ8a6vvV0iMaXJZrdbvoy48ezeOxioc1q2GtqcIr0fLjcqWAIrAcpmHcXy(DSgPnYlqtRW1Llsgo6IYeb6vvVgKekktKh)RabqDu10iMaXJx6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEpzI(XLKkoQJuHJUOmrGEv1lnIjq84CjPIJ6iv4jYiqV07qG71Mc0RQEzex4M0R3Ha3RrEa9QQxAetG4X5OHGkhmCEImc0l9ouVG2aigf6bdNyusQ4OwrYuSrIJqnKzKjibXi6IYebiynXOqpy4eJssfh1ksMInsmcGfAcnpy4eJgj9zm7LAjPnw6fw7nsLEHLEtuaErmst4HjuignijuuMip(xbcG6OQPrmbIhV0RQEv(1kxsQ4OMAjPnYlNqjTxW9Q8RvUKuXrn1ssBKZiSRlNqjTxv9EYe9JljvCuhPchDrzIa9QQxAetG4X5ssfh1rQWtKrGEP3Ha3RnfOxv9YiUWnPxVdbUxJ8a6vvV0iMaXJZrdbvoy48ezeOx6vvVS07G6n)owJ0g5fOPv46YfjdhDrzIa9YgB9Q8RvEbAAfUUCrYWtKrGEP3Ha3lzdEVKtCeQHKdGGeeJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmoyjvCSxwlzk2yVfR4pb61gDmL58vVkyVNf27ukxVuPC9g1EplS3bBy79b6aXdXinHhMqHyu5xRCjPIJAZ4bt(3Sxv9Q8RvUKuXrTz8Gjprgb6LEhcCV2uGEv1RYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9QQxw6LgXeiECoAiOYbdNNiJa9sVSXwV53XAK2ixsQ4O2ssMWFXrxuMiqVKtCeQHKKrqcIr0fLjcqWAIrHEWWjgLKkoQvKmfBKyeal0eAEWWjghSKko2lRLmfBS3Iv8Na9AJoMYC(QxfS3Zc7DkLRxQuUEJAVNf2RrqmS9(aDG4HyKMWdtOqmQ8RvE(DuhvTz8Gj)B2RQEv(1kxsQ4O2mEWKdepEVQ6v5xR887OoQAZ4btEImc0l9oe4ETPa9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVS0lnIjq84C0qqLdgoprgb6LEzJTEZVJ1iTrUKuXrTLKmH)IJUOmrGEjN4iudjjjbjigrxuMiabRjgf6bdNyusQ4OwrYuSrIraSqtO5bdNyCWsQ4yVSwYuSXElwXFc0Rc27zH9oLY1lvkxVrT3Zc7LeXnW79b6aXtVWAVWRxyPxpUE)feO3h4z1RrqmS9gzVd2Wsmst4Hjuigv(1kxsQ4O2mEWKdepEVQ6v5xR887OoQAZ4btoq849QQxau5xR8l(ulDu1NfQzeBi)B2RQEbqLFTYV4tT0rvFwOMrSH8ezeOx6DiW9Atb6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOKsCeQHKGgbjigrxuMiabRjgf6bdNyusQ4OwrYuSrIraSqtO5bdNy0i1c9EplS3tsB86fw6f69ISJ0)H9MIBJ9koqVNfMyVWsVmrI9EwI3B4yVOJmVmU3Fb7vrYuSXELsVLi8ELsVVIFVwIbSx0JVTvVuljTXsVx0Rf86vMZErhzGyPxyT3Zc7DWsQ4yVSoyuKeGb9R3jAJoGKV6fw6fbD(qtteGyKMWdtOqmAqsOOmroYygpyIaAfjtXg7vvVk)ALljvCutTK0g5LtOK2Rrb3ll9k0dAa1OJmqS0lOBVK1l59QQxHEqdOgDKbILEnAVK1RQEv(1khaLZsjsh5aXJtCeQHKddbjigrxuMiabRjgPj8WekeJgKekktKJmMXdMiGwrYuSXEv1RYVw5ssfh1uljTrE5ekP9ouVk)ALljvCutTK0g5mc76Yjus7vvVc9Ggqn6idel9A0EjRxv9Q8RvoakNLsKoYbIhNyuOhmCIrjPIJAKDZzuGHtCeQHKVLGeeJc9GHtmkjvCuRmLYrmIUOmracwtCeQHKGEcsqmIUOmracwtmst4HjuignijuuMip(xbcG6OQPrmbIhVqmk0dgoXiAiOYbdN4iudjhOeKGyuOhmCIrjPIJAfjtXgjgrxuMiabRjoIJyKgXeiE8cbjiudzeKGyeDrzIaeSMyuOhmCIXAgLt7HbHyeal0eAEWWjgh2egj8GgjWE)fOB3RDclZx9cPq6e79bEw9kM8EhikyVWR3h4z17fhtVXzH5dSGCIrAcpmHcXy(DSgPnYTtyz(sdPq6e5OlkteOxv9sJycepoxsQ4O2mEWKNiJa9sVgTxqBa9QQxAetG4X5x8Pw6OQpluZi2qEIcWREv1ll9Q8RvUKuXrn1ssBKxoHsAVdbUxdscfLjYV4y0mc7AQLK2yPxv9YsVS07jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X553rDu1MXdM8ezeOx6DiW9Atb6vvV0iMaXJZLKkoQnJhm5jYiqV0Rr71GKqrzI8lognJWUgaNYlDnsTy2l59YgB9YsVdQ3tMOF887OoQAZ4bto6IYeb6vvV0iMaXJZLKkoQnJhm5jYiqV0Rr71GKqrzI8lognJWUgaNYlDnsTy2l59YgB9sJycepoxsQ4O2mEWKNiJa9sVdbUxBkqVK3l5ehHAijbjigrxuMiabRjgPj8WekeJ53XAK2i3oHL5lnKcPtKJUOmrGEv1lnIjq84CjPIJAZ4btEIcWREv1ll9oOEpzI(XrFcTTo0rao6IYeb6Ln26LLEpzI(XrFcTTo0rao6IYeb6vvVmIlCt61Rrb37aDa9sEVK3RQEzPxw6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVgTxYgqVQ6v5xRCjPIJAQLK2iVCcL0Eb3RYVw5ssfh1uljTroJWUUCcL0EjVx2yRxw6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVG7Da9QQxLFTYLKkoQPwsAJ8Yjus7fCVdOxY7L8Ev1RYVw553rDu1MXdMCG4X7vvVmIlCt61Rrb3RbjHIYe5IPMb6qMpJMrCrBspIrHEWWjgRzuoThgeIJqnGgbjigrxuMiabRjgPj8WekeJ53XAK2ihawOqZj0L8LMgmmIdWrxuMiqVQ6LgXeiECUYVw1aWcfAoHUKV00GHrCaEIcWREv1RYVw5aWcfAoHUKV00GHrCaDnJYXbIhVxv9YsVk)ALljvCuBgpyYbIhVxv9Q8RvE(DuhvTz8GjhiE8Ev1laQ8Rv(fFQLoQ6Zc1mInKdepEVK3RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0l4EhqVQ6LLEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5xCmAgHDn1ssBS0RQEzPxw69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84887OoQAZ4btEImc0l9oe4ETPa9QQxAetG4X5ssfh1MXdM8ezeOx61O9AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEzP3b17jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X5ssfh1MXdM8ezeOx61O9AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEPrmbIhNljvCuBgpyYtKrGEP3Ha3RnfOxY7LCIrHEWWjgRzuoLyEehHAggcsqmIUOmracwtmst4HjuigZVJ1iTroaSqHMtOl5lnnyyehGJUOmrGEv1lnIjq84CLFTQbGfk0CcDjFPPbdJ4a8efGx9QQxLFTYbGfk0CcDjFPPbdJ4a6kmroq849QQxZenOTPaCY41mkNsmpIrHEWWjgRWe1ktPCehHAElbjigrxuMiabRjgf6bdNyKbMzKfDu1xKmOFeJayHMqZdgoX4WkWS3bEqIEFGNvVd2W2lS2l8aP0lnyGUDVFZElr48EncR9cVEFGZzVkyV)cc07d8S6LeXnWnUxQuUEHxVLj026MV6vbRrIeJ0eEycfIXb1B(DSgPnYlqtRW1Llsgo6IYeb6vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx6DiW9AK7f0Txw6f06DG1BbpTs4)c)GysYbxpmM0EjVxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxYgqVGU9YsVGwVdSEl4Pvc)x4hetso46HXK2l5ehHAa9eKGyeDrzIaeSMyKMWdtOqmMFhRrAJ8c00kCD5IKHJUOmrGEv1RYVw5fOPv46Yfjd)B2RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG71i3lOBVS0lO17aR3cEALW)f(bXKKdUEymP9sEVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVKnGEbD7LLEbTEhy9wWtRe(VWpiMKCW1dJjTxYjgf6bdNyKbMzKfDu1xKmOFehHAgOeKGyeDrzIaeSMyKMWdtOqmAqsOOmrE8Vcea1rvtJycepEPxv9YsVL4pvGoa3qmLdorDjMgq)4OlkteOx2yR3s8NkqhGB(l3FIAm)MhmCo6IYeb6LCIrHEWWjgRtSyrtPEehHAgCcsqmIUOmracwtmk0dgoXiakNLsKosmcGfAcnpy4eJd28rEv69xWEbq5SuI0XEFGNvVIjVxJWAVxCm9cl9MOa8QxP07doNg3lJqk2B5NyVx0lvkxVWRxfSgj27fhdNyKMWdtOqmoOEZVJ1iTrEbAAfUUCrYWrxuMiqVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUxYEBVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVKb6joc1yKjibXi6IYebiynXinHhMqHym)owJ0g5fOPv46YfjdhDrzIa9QQxZenOTPaCY4OHGkhmCIrHEWWjgbq5SuI0rIJqnKnacsqmIUOmracwtmst4HjuigPrmbIhNljvCuBgpyYtuaE1RQEzP3b17jt0po6tOT1HocWrxuMiqVSXwVS07jt0po6tOT1HocWrxuMiqVQ6LrCHBsVEnk4EhOdOxY7L8Ev1ll9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx61O9s2a6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2l59YgB9YsV0iMaXJZV4tT0rvFwOMrSH8efGx9QQxLFTYLKkoQPwsAJ8Yjus7fCVdOxY7L8Ev1RYVw553rDu1MXdMCG4X7vvVmIlCt61Rrb3RbjHIYe5IPMb6qMpJMrCrBspIrHEWWjgbq5SuI0rIJqnKrgbjigrxuMiabRjgf6bdNymfaO4NUykjPeJayHMqZdgoX4arb7TykjP9cR9EXX0R4a9kM9kj2B49sb6vCGEFchKRxfS3VzV1i7DgUnM9EwI37zH9YiS3laoLxg3lJqk0T7T8tS3hSxlXa2RC9orPC9EprVssfh7LAjPnw6vCGEpl569IJP3hP4GC9oq(lxV)ccWjgPj8WekeJ0iMaXJZV4tT0rvFwOMrSH8ezeOx61O9AqsOOmrEw0mc7AaCkV01i1xCm9QQxAetG4X5ssfh1MXdM8ezeOx61O9AqsOOmrEw0mc7AaCkV01i1IzVQ6LLEpzI(XZVJ6OQnJhm5OlkteOxv9YsV0iMaXJZZVJ6OQnJhm5jYiqV07q9ISJ0)H6dYG9YgB9sJycepop)oQJQ2mEWKNiJa9sVgTxdscfLjYZIMryxdGt5LUgPodZEjVx2yR3b17jt0pE(DuhvTz8GjhDrzIa9sEVQ6v5xRCjPIJAQLK2iVCcL0EnAVKSxv9cGk)ALFXNAPJQ(SqnJyd5aXJ3RQEv(1kp)oQJQ2mEWKdepEVQ6v5xRCjPIJAZ4btoq84ehHAiJKeKGyeDrzIaeSMyuOhmCIXuaGIF6IPKKsmcGfAcnpy4eJdefS3IPKK27d8S6vm79Xc9EnJsbQmrEVgH1EV4y6fw6nrb4vVsP3hConUxgHuS3YpXEVOxQuUEHxVkynsS3logoXinHhMqHyKgXeiEC(fFQLoQ6Zc1mInKNiJa9sVd1lYos)hQpid2RQEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5xCmAgHDn1ssBS0RQEPrmbIhNljvCuBgpyYtKrGEP3H6LLEr2r6)q9bzWEFVxHEWW5x8Pw6OQpluZi2qoYos)hQpid2l5ehHAid0iibXi6IYebiynXinHhMqHyKgXeiECUKuXrTz8Gjprgb6LEhQxKDK(puFqgSxv9YsVS07G69Kj6hh9j026qhb4OlkteOx2yRxw69Kj6hh9j026qhb4OlkteOxv9YiUWnPxVgfCVd0b0l59sEVQ6LLEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9A0EnijuuMixm1mc7AaCkV01i1xCm9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7L8EzJTEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9cU3b0RQEv(1kxsQ4OMAjPnYlNqjTxW9oGEjVxY7vvVk)ALNFh1rvBgpyYbIhVxv9YiUWnPxVgfCVgKekktKlMAgOdz(mAgXfTj96LCIrHEWWjgtbak(PlMsskXrOgYggcsqmIUOmracwtmk0dgoXyj(ZjEh0T15x5fXinHhMqHyKLEhuV53XAK2iVanTcxxUiz4OlkteOx2yRxLFTYlqtRW1Llsg(3SxY7vvVk)ALljvCutTK0g5LtOK27qG71GKqrzI8lognJWUMAjPnw6vvV0iMaXJZLKkoQnJhm5jYiqV07qG7fzhP)d1hKb7vvVmIlCt61Rr71GKqrzICXuZaDiZNrZiUOnPxVQ6v5xR887OoQAZ4btoq84eJUWGeJL4pN4Dq3wNFLxehHAi7TeKGyeDrzIaeSMyKMWdtOqmMFhRrAJ8c00kCD5IKHJUOmrGEv1lnIjq848l(ulDu1NfQzeBiprgb6LEhcCVS0Rqpy4C0qqLdgohzhP)d1hKb799Ejd06LCIrHEWWjgrdbvoy4ehHAid0tqcIr0fLjcqWAIrAcpmHcXybpTs4)c)GysYbxtstAVQ6Lggqx8JBa9Z6v2RQEv(1kxsQ4O2mEWKdepEVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUxKDK(puFqgSxv9sJycepoxsQ4O2mEWKNiJa9sVgTxYgaXOqpy4eJ53rDu1MXdMehHAiBGsqcIr0fLjcqWAIrAcpmHcXybpTs4)c)GysYbxtstAVQ6Lggqx8JBa9Z6v2RQEnt0G2McWjJNFh1rvBgpysmk0dgoX4fFQLoQ6Zc1mInK4iudzdobjigrxuMiabRjgPj8WekeJf80kH)l8dIjjhCnjnP9QQxAyaDXpUb0pRxzVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVi7i9FO(GmiXOqpy4eJx8Pw6OQpluZi2qIJqnKzKjibXi6IYebiynXinHhMqHy0mrdABkaNm(fFQLoQ6Zc1mInKyuOhmCIrjPIJAZ4btIJqnKCaeKGyeDrzIaeSMyKMWdtOqmYsVdQ3cEALW)f(bXKKdUMKM0EzJTEhuV0Wa6IFCdOFwVYEjVxv9YsVdQ387ynsBKxGMwHRlxKmC0fLjc0lBS1RYVw5fOPv46Yfjd)B2l59QQxLFTYLKkoQPwsAJ8Yjus7DiW9AqsOOmr(fhJMryxtTK0gl9QQxAetG4X5ssfh1MXdM8ezeOx6DiW9ISJ0)H6dYG9QQxgXfUj961O9AqsOOmrUyQzGoK5ZOzex0M0Rxv9Q8RvE(DuhvTz8GjhiECIrHEWWjgV4tT0rvFwOMrSHehHAijzeKGyeDrzIaeSMyKMWdtOqmYsVdQ3cEALW)f(bXKKdUMKM0EzJTEhuV0Wa6IFCdOFwVYEjVxv9Q8RvUKuXrn1ssBKxoHsAVdbUxdscfLjYV4y0mc7AQLK2yPxv9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECE(DuhvTz8Gjprgb6LEhcCVi7i9FO(GmyVQ61GKqrzI8dYG6VFWPwm71O9AqsOOmr(fhJMryxdGt5LUgPwmjgf6bdNy8Ip1shv9zHAgXgsCeQHKKKGeeJOlkteGG1eJ0eEycfIrw6Dq9wWtRe(VWpiMKCW1K0K2lBS17G6Lggqx8JBa9Z6v2l59QQxLFTYLKkoQPwsAJ8Yjus7DiW9AqsOOmr(fhJMryxtTK0gl9QQxw6Dq9EYe9JNFh1rvBgpyYrxuMiqVSXwV0iMaXJZZVJ6OQnJhm5jYiqV0Rr71GKqrzI8lognJWUgaNYlDnsDgM9sEVQ61GKqrzI8dYG6VFWPwm71O9AqsOOmr(fhJMryxdGt5LUgPwmjgf6bdNy8Ip1shv9zHAgXgsCeQHKGgbjigrxuMiabRjgPj8WekeJS07G6TGNwj8FHFqmj5GRjPjTx2yR3b1lnmGU4h3a6N1RSxY7vvVk)ALljvCuBgpyYbIhVxv9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx61O9AqsOOmrEgMAgHDnaoLx6AK6loMEzJTEPrmbIhNljvCuBgpyYtKrGEP3Ha3RbjHIYe5xCmAgHDnaoLx6AKAXSxY7vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEPrmbIhNljvCuBgpyYtKrGEPxJ2lzdOxv9sJycepo)Ip1shv9zHAgXgYtKrGEPxJ2lzdGyuOhmCIX87OoQAZ4btIJqnKCyiibXi6IYebiynXinHhMqHy0GKqrzI84FfiaQJQMgXeiE8cXOqpy4eJfly9GUT2mEWK4iudjFlbjigrxuMiabRjgf6bdNy0mXc6uuhvnd0bigbWcnHMhmCIXbIc2RzW07f9waD(iAKa7v8Er2Vu6vu6f69EwyVoY(1lnIjq849(aDG4X4E)(elLEj9vcfV3Zc9EdF(QxGFcD7ELKko2Rz8GzVaFS3l61kE6LrCPxRVBNV6nfaO4xVftjjTxyHyKMWdtOqmEYe9JNFh1rvBgpyYrxuMiqVQ6v5xRCjPIJAZ4bt(3Sxv9Q8RvE(DuhvTz8Gjprgb6LEhQxBkaNryN4iudjb9eKGyeDrzIaeSMyKMWdtOqmcGk)ALFXNAPJQ(SqnJyd5FZEv1laQ8Rv(fFQLoQ6Zc1mInKNiJa9sVd1Rqpy4CjPIJAgyPaNyHJSJ0)H6dYG9QQ3b1lnmGU4hN0xjuCIrHEWWjgntSGof1rvZaDaIJqnKCGsqcIr0fLjcqWAIrAcpmHcXOYVw553rDu1MXdM8VzVQ6v5xR887OoQAZ4btEImc0l9ouV2uaoJWEVQ6LgXeiECoAiOYbdNNOa8Qxv9sJycepo)Ip1shv9zHAgXgYtKrGEPxv9oOEPHb0f)4K(kHItmk0dgoXOzIf0POoQAgOdqCehXiawL)8iibHAiJGeeJc9GHtmsJVFywmX5KyeDrzIaeSM4iudjjibXi6IYebiynXinHhMqHyKLEpzI(XrFcTTo0rao6IYeb6vvVmIlCt617qG7DWhqVQ6LrCHBsVEnk4Eb9VTxY7Ln26LLEhuVNmr)4OpH2wh6iahDrzIa9QQxgXfUj96DiW9o4VTxYjgf6bdNyKrCrBJmehHAancsqmIUOmracwtmst4Hjuigv(1kxsQ4O2mEWK)njgf6bdNy0moy4ehHAggcsqmIUOmracwtmst4HjuigZVJ1iTr(HmMrkt9JKMC0fLjc0RQEv(1khz3s(Ldgo)B2RQEzPxAetG4X5ssfh1MXdM8efGx9YgB9QeLsVQ6TcTToDImc0l9oe4EhMb0l5eJc9GHtmEqgu)iPjXrOM3sqcIr0fLjcqWAIrAcpmHcXOYVw5ssfh1MXdMCG4X7vvVk)ALNFh1rvBgpyYbIhVxv9cGk)ALFXNAPJQ(SqnJyd5aXJtmk0dgoX4eABDf9a5hWMb9J4iudONGeeJOlkteGG1eJ0eEycfIrLFTYLKkoQnJhm5aXJ3RQEv(1kp)oQJQ2mEWKdepEVQ6fav(1k)Ip1shv9zHAgXgYbIhNyuOhmCIrfXwhv9LqkPfIJqnducsqmIUOmracwtmst4Hjuigv(1kxsQ4O2mEWK)njgf6bdNyubZcMKcDBIJqndobjigrxuMiabRjgPj8WekeJk)ALljvCuBgpyY)MeJc9GHtmQmJaqx)5lIJqngzcsqmIUOmracwtmst4Hjuigv(1kxsQ4O2mEWK)njgf6bdNySctuzgbaXrOgYgabjigrxuMiabRjgPj8WekeJk)ALljvCuBgpyY)MeJc9GHtmkoflxktnvMtIJqnKrgbjigrxuMiabRjgPj8WekeJk)ALljvCuBgpyY)MeJc9GHtm(lOgEitH4iudzKKGeeJOlkteGG1eJUWGeJfQKfDu11uomDzQlxcRiXOqpy4eJfQKfDu11uomDzQlxcRiXrOgYancsqmIUOmracwtmk0dgoXO9uaGYfzrRia2iXinHhMqHyu5xRCjPIJAZ4bt(3Sx2yRxAetG4X5ssfh1MXdM8ezeOx61OG79TVTxv9cGk)ALFXNAPJQ(SqnJyd5FtIrSwr6PDHbjgTNcauUilAfbWgjoc1q2WqqcIr0fLjcqWAIrHEWWjgzIWNWtBMWcdXinHhMqHyKggqx8Jt6RekEVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVKnGEv1lnIjq848l(ulDu1NfQzeBiprgb6LEhcCVKnaIrxyqIrMi8j80MjSWqCeQHS3sqcIr0fLjcqWAIrHEWWjgzIWNWtBMWcdXinHhMqHyCq9sddOl(Xj9vcfVxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxqFVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUxqFVQ69GmyVgTxqBa9QQxw6Dq9sddOl(XnG(z9k7Ln26vOh0aQrhzGyP3H61GKqrzICjq9jPnEAA89RxYjgDHbjgzIWNWtBMWcdXrOgYa9eKGyeDrzIaeSMyuOhmCIrKX8vIYuhjGlofjgPj8WekeJ0iMaXJZLKkoQnJhm5jYiqV07qG7LS32RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG7LS3sm6cdsmImMVsuM6ibCXPiXrOgYgOeKGyeDrzIaeSMyuOhmCIrGefGkmrTbSuWjXinHhMqHyKgXeiECUKuXrTz8Gjprgb6LEnk4Ej5a6Ln26Dq9AqsOOmrUyQdx)lyVG7LSEzJTEzP3dYG9cU3b0RQEnijuuMiVclwq3whMOJzVG7LSEv1B(DSgPnYlqtRW1Llsgo6IYeb6LCIrxyqIrGefGkmrTbSuWjXrOgYgCcsqmIUOmracwtmk0dgoXyj(tn02HhMeJ0eEycfIrAetG4X5ssfh1MXdM8ezeOx61OG7f0gqVSXwVdQxdscfLjYftD46Fb7fCVKrm6cdsmwI)udTD4HjXrOgYmYeKGyeDrzIaeSMyuOhmCIr75ltlDu1sPazGt5GHtmst4HjuigPrmbIhNljvCuBgpyYtKrGEPxJcUxsoGEzJTEhuVgKekktKlM6W1)c2l4EjRx2yRxw69GmyVG7Da9QQxdscfLjYRWIf0T1Hj6y2l4EjRxv9MFhRrAJ8c00kCD5IKHJUOmrGEjNy0fgKy0E(Y0shvTukqg4uoy4ehHAi5aiibXi6IYebiynXOqpy4eJmcvusuxSq80m)cKsmst4HjuigPrmbIhNljvCuBgpyYtKrGEP3Ha37B7vvVS07G61GKqrzI8kSybDBDyIoM9cUxY6Ln269GmyVgTxqBa9soXOlmiXiJqfLe1flepnZVaPehHAijzeKGyeDrzIaeSMyuOhmCIrgHkkjQlwiEAMFbsjgPj8WekeJ0iMaXJZLKkoQnJhm5jYiqV07qG79T9QQxdscfLjYRWIf0T1Hj6y2l4EjRxv9Q8RvE(DuhvTz8Gj)B2RQEv(1kp)oQJQ2mEWKNiJa9sVdbUxw6LSb0lOBVVT3bwV53XAK2iVanTcxxUiz4OlkteOxY7vvVhKb7DOEbTbqm6cdsmYiurjrDXcXtZ8lqkXrOgssscsqmIUOmracwtmk0dgoXyXsaIheqhPIoQ6lsg0pIrAcpmHcX4bzWEb37a6Ln26LLEnijuuMip(xbcG6OQPrmbIhV0RQEzPxw6Lggqx8Jt6RekEVQ6LgXeiECEkaqXpDXuss5jYiqV07qG7LK9QQxAetG4X5ssfh1MXdM8ezeOx6DiW9(2Ev1lnIjq848l(ulDu1NfQzeBiprgb6LEhcCVVTxY7Ln26LgXeiECUKuXrTz8Gjprgb6LEhcCVKSx2yR3k0260jYiqV07q9sJycepoxsQ4O2mEWKNiJa9sVK3l5eJUWGeJflbiEqaDKk6OQVizq)ioc1qsqJGeeJOlkteGG1eJayHMqZdgoX4B5G(EHLEplS3IjIa9g1EplS3X4pN4Dq3UxJGVYREnZyGePhCIeJUWGeJL4pN4Dq3wNFLxeJ0eEycfIrw61GKqrzI8dYG6VFWPwm799EzPxHEWW5Paaf)0ftjjLJSJ0)H6dYG9oW6Lggqx8Jt6RekEVK3779YsVc9GHZbq5SuI0roYos)hQpid27aRxAyaDXpUJ0mMrc0l59(EVc9GHZV4tT0rvFwOMrSHCKDK(puFqgS3H69K0gpoaSCItXEbvVVLd67L8Ev1ll9AqsOOmrULya1Hj6iqVSXwVS0lnmGU4hN0xju8Ev1B(DSgPnYLKkoQHEf6W7fhDrzIa9sEVK3RQEpjTXJdalN4uSxJ2ljFlXOqpy4eJL4pN4Dq3wNFLxehHAi5WqqcIr0fLjcqWAIrAcpmHcXinmGU4h3a6N1RSxv9MFhRrAJ8c00kCD5IKHJUOmrGEv17jt0pUKuXrnsTco6IYeb6vvVc9Ggqn6idel9AuW9AqsOOmrUeO(K0gpnn((rmwUespc1qgXOqpy4eJuzo1c9GHRNWYrmoHLt7cdsmAqcK4iudjFlbjigrxuMiabRjgPj8WekeJc9Ggqn6idel9AuW9AqsOOmrUeO(K0gpnn((rmwUespc1qgXOqpy4eJuzo1c9GHRNWYrmoHLt7cdsmkbsCeQHKGEcsqmIUOmracwtmst4HjuigPHb0f)4K(kHI3RQEZVJ1iTrUKuXrTLKmH)IJUOmraIXYLq6rOgYigf6bdNyKkZPwOhmC9ewoIXjSCAxyqIrljzc)fXrOgsoqjibXi6IYebiynXinHhMqHy0GKqrzIClXaQdt0rGEb37a6vvVgKekktKxHflOBRdt0XSxv9oOEzPxAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxYjglxcPhHAiJyuOhmCIrQmNAHEWW1ty5igNWYPDHbjgRWIf0T1Hj6ysCeQHKdobjigrxuMiabRjgPj8WekeJgKekktKBjgqDyIoc0l4EhqVQ6Dq9YsV0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiqVKtmwUespc1qgXOqpy4eJuzo1c9GHRNWYrmoHLt7cdsmgMOJjXrOgsAKjibXi6IYebiynXinHhMqHyCq9YsV0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiqVKtmwUespc1qgXOqpy4eJuzo1c9GHRNWYrmoHLt7cdsmsJycepEH4iudOnacsqmIUOmracwtmst4HjuignijuuMiVcDzQv(P3l4EhqVQ6Dq9YsV0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiqVKtmwUespc1qgXOqpy4eJuzo1c9GHRNWYrmoHLt7cdsmMXjhmCIJqnGgzeKGyeDrzIaeSMyKMWdtOqmAqsOOmrEf6YuR8tVxW9swVQ6Dq9YsV0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiqVKtmwUespc1qgXOqpy4eJuzo1c9GHRNWYrmoHLt7cdsmwHUm1k)0joIJy0mrAWOihbjiudzeKGyuOhmCIrjPIJAOF4CI0JyeDrzIaeSM4iudjjibXOqpy4eJLpdt4AjPIJ6QWaNqjjgrxuMiabRjoc1aAeKGyuOhmCIrA4dK)e1mIlABKHyeDrzIaeSM4iuZWqqcIrHEWWjgzGzgPgYi2iXi6IYebiynXrOM3sqcIr0fLjcqWAIrAcpmHcXyj(tfOdWnet5GtuxIPb0po6IYeb6Ln26Te)Pc0b4M)Y9NOgZV5bdNJUOmraIrHEWWjgRtSyrtPEehHAa9eKGyeDrzIaeSMyKMWdtOqmsddOl(Xj9vcfVxv9MFhRrAJCjPIJAljzc)fhDrzIa9QQxA4aF4XLKkoQnZaaA)IJUOmrGEv1RbjHIYe5Y8rEv0LxovtJycepEPxv9k0dAa1OJmqS07q9AqsOOmrUeO(K0gpnn((rmk0dgoXy(DuhvTz8GjXrOMbkbjigrxuMiabRjgPj8WekeJdQxdscfLjYnt08pNA0q0l4EjRxv9MFhRrAJCayHcnNqxYxAAWWioahDrzIaeJc9GHtmwZOCkX8ioc1m4eKGyeDrzIaeSMyKMWdtOqmoOEnijuuMi3mrZ)CQrdrVG7LSEv17G6n)owJ0g5aWcfAoHUKV00GHrCao6IYeb6vvVS07G6Lggqx8JBa9Z6v2lBS1RbjHIYe5vyXc626WeDm7LCIrHEWWjgLKkoQvMs5ioc1yKjibXi6IYebiynXinHhMqHyCq9AqsOOmrUzIM)5uJgIEb3lz9QQ3b1B(DSgPnYbGfk0CcDjFPPbdJ4aC0fLjc0RQEPHb0f)4gq)SEL9QQ3b1RbjHIYe5vyXc626WeDmjgf6bdNyKbMzKfDu1xKmOFehHAiBaeKGyeDrzIaeSMyKMWdtOqmAqsOOmrUzIM)5uJgIEb3lzeJc9GHtmIgcQCWWjoIJyucKGeeQHmcsqmIUOmracwtmst4HjuigZVJ1iTroaSqHMtOl5lnnyyehGJUOmrGEv1lnIjq84CLFTQbGfk0CcDjFPPbdJ4a8efGx9QQxLFTYbGfk0CcDjFPPbdJ4a6AgLJdepEVQ6LLEv(1kxsQ4O2mEWKdepEVQ6v5xR887OoQAZ4btoq849QQxau5xR8l(ulDu1NfQzeBihiE8EjVxv9sJycepo)Ip1shv9zHAgXgYtKrGEPxW9oGEv1ll9Q8RvUKuXrn1ssBKxoHsAVdbUxdscfLjYLa1xCmAgHDn1ssBS0RQEzPxw69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84887OoQAZ4btEImc0l9oe4ETPa9QQxAetG4X5ssfh1MXdM8ezeOx61O9AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEzP3b17jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X5ssfh1MXdM8ezeOx61O9AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEPrmbIhNljvCuBgpyYtKrGEP3Ha3RnfOxY7LCIrHEWWjgRzuoLyEehHAijbjigrxuMiabRjgPj8WekeJS0B(DSgPnYbGfk0CcDjFPPbdJ4aC0fLjc0RQEPrmbIhNR8RvnaSqHMtOl5lnnyyehGNOa8Qxv9Q8RvoaSqHMtOl5lnnyyehqxHjYbIhVxv9AMObTnfGtgVMr5uI51l59YgB9YsV53XAK2ihawOqZj0L8LMgmmIdWrxuMiqVQ69GmyVG7Da9soXOqpy4eJvyIALPuoIJqnGgbjigrxuMiabRjgPj8WekeJ53XAK2i3oHL5lnKcPtKJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9A0EbTb0RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0l4EhqVQ6LLEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5sG6lognJWUMAjPnw6vvVS0ll9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECE(DuhvTz8Gjprgb6LEhcCV2uGEv1lnIjq84CjPIJAZ4btEImc0l9A0EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwVS07G69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9A0EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwV0iMaXJZLKkoQnJhm5jYiqV07qG71Mc0l59soXOqpy4eJ1mkN2ddcXrOMHHGeeJOlkteGG1eJ0eEycfIX87ynsBKBNWY8LgsH0jYrxuMiqVQ6LgXeiECUKuXrTz8Gjprgb6LEb37a6vvVS0ll9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx61O9AqsOOmrUyQze21a4uEPRrQV4y6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2l59YgB9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx6fCVdOxv9Q8RvUKuXrn1ssBKxoHsAVdbUxdscfLjYLa1xCmAgHDn1ssBS0l59sEVQ6v5xR887OoQAZ4btoq849soXOqpy4eJ1mkN2ddcXrOM3sqcIr0fLjcqWAIrHEWWjgLKkoQzGLcCIfIrQLaDIrYigPj8WekeJ0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiqVQ6v5xRCjPIJAljzc)fVCcL0EhQxYEBVQ6LgXeiECEkaqXpDXuss5jYiqV07qG71GKqrzICljzc)LUCcLu9bzWEFVxKDK(puFqgSxv9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3RbjHIYe5wsYe(lD5ekP6dYG9(EVi7i9FO(GmyVV3Rqpy48uaGIF6IPKKYr2r6)q9bzWEv1lnIjq84CjPIJAZ4btEImc0l9oe4EnijuuMi3ssMWFPlNqjvFqgS337fzhP)d1hKb799Ef6bdNNcau8txmLKuoYos)hQpid2779k0dgo)Ip1shv9zHAgXgYr2r6)q9bzqIJqnGEcsqmIUOmracwtmk0dgoXOKuXrndSuGtSqmsTeOtmsgXinHhMqHyKggqx8JBa9Z6v2RQEZVJ1iTrUKuXrn0RqhEV4OlkteOxv9Q8RvUKuXrTLKmH)IxoHsAVd1lzVTxv9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3RbjHIYe5wsYe(lD5ekP6dYG9(EVi7i9FO(GmyVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVgKekktKBjjt4V0LtOKQpid2779ISJ0)H6dYG9(EVc9GHZV4tT0rvFwOMrSHCKDK(puFqgK4iuZaLGeeJOlkteGG1eJ0eEycfIrAyaDXpUb0pRxzVQ69Kj6hxsQ4OgPwbhDrzIa9QQ3dYG9ouVKnGEv1lnIjq84CgyMrw0rvFrYG(XtKrGEPxv9Q8RvoDIssLYbDBE5ekP9ouVGgXOqpy4eJssfh1ktPCehHAgCcsqmIUOmracwtmk0dgoXyj(ZjEh0T15x5fXinHhMqHym)owJ0g5fOPv46YfjdhDrzIa9QQxZenOTPaCY4OHGkhmCIrxyqIXs8Nt8oOBRZVYlIJqngzcsqmIUOmracwtmst4HjuigZVJ1iTrEbAAfUUCrYWrxuMiqVQ61mrdABkaNmoAiOYbdNyuOhmCIXl(ulDu1NfQzeBiXrOgYgabjigrxuMiabRjgPj8WekeJ53XAK2iVanTcxxUiz4OlkteOxv9YsVMjAqBtb4KXrdbvoy49YgB9AMObTnfGtg)Ip1shv9zHAgXg2l5eJc9GHtmkjvCuBgpysCeQHmYiibXi6IYebiynXinHhMqHym)owJ0g5ssfh1qVcD49IJUOmrGEv1lnIjq848l(ulDu1NfQzeBiprgb6LEhcCVKnGEv1lnIjq84CjPIJAZ4btEImc0l9oe4Ej7TeJc9GHtmYaZmYIoQ6lsg0pIJqnKrscsqmIUOmracwtmst4HjuigPrmbIhNljvCuBgpyYtKrGEP3Ha37G3RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG7DW7vvVS0RYVw5ssfh1uljTrE5ekP9oe4EnijuuMixcuFXXOze21uljTXsVQ6LLEzP3tMOF887OoQAZ4bto6IYeb6vvV0iMaXJZZVJ6OQnJhm5jYiqV07qG71Mc0RQEPrmbIhNljvCuBgpyYtKrGEPxJ27B7L8EzJTEzP3b17jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X5ssfh1MXdM8ezeOx61O9(2EjVx2yRxAetG4X5ssfh1MXdM8ezeOx6DiW9Atb6L8EjNyuOhmCIrgyMrw0rvFrYG(rCeQHmqJGeeJOlkteGG1eJ0eEycfIXdYG9A0EbTb0RQEZVJ1iTrEbAAfUUCrYWrxuMiqVQ6Lggqx8JBa9Z6v2RQEnt0G2McWjJZaZmYIoQ6lsg0pIrHEWWjgrdbvoy4ehHAiByiibXi6IYebiynXinHhMqHy8GmyVgTxqBa9QQ387ynsBKxGMwHRlxKmC0fLjc0RQEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5sG6lognJWUMAjPnw6vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx6fCVdOxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxBkaXOqpy4eJOHGkhmCIJqnK9wcsqmIUOmracwtmk0dgoXiAiOYbdNye6hM5380WkXOYVw5fOPv46YfjdVCcLuWk)ALxGMwHRlxKmCgHDD5ekPeJq)Wm)MNgYWGaq5qIrYigPj8WekeJhKb71O9cAdOxv9MFhRrAJ8c00kCD5IKHJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9cU3b0RQEzPxw6LLEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0Rr71GKqrzICXuZiSRbWP8sxJuFXX0RQEv(1kxsQ4OMAjPnYlNqjTxW9Q8RvUKuXrn1ssBKZiSRlNqjTxY7Ln26LLEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0l4EhqVQ6v5xRCjPIJAQLK2iVCcL0EhcCVgKekktKlbQV4y0mc7AQLK2yPxY7L8Ev1RYVw553rDu1MXdMCG4X7LCIJqnKb6jibXi6IYebiynXOqpy4eJL4pN4Dq3wNFLxeJ0eEycfIrAetG4X5Paaf)0ftjjLNOa8Qxv9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3RnfGZiS3RQEPrmbIhNljvCuBgpyYtKrGEP3Ha3RnfGZiStm6cdsmwI)CI3bDBD(vErCeQHSbkbjigrxuMiabRjgPj8WekeJ0iMaXJZV4tT0rvFwOMrSH8ezeOx6DOEr2r6)q9bzWEv1ll9YsVNmr)453rDu1MXdMC0fLjc0RQEPrmbIhNNFh1rvBgpyYtKrGEP3Ha3RnfOxv9sJycepoxsQ4O2mEWKNiJa9sVgTxdscfLjYV4y0mc7AaCkV01i1IzVK3lBS1ll9oOEpzI(XZVJ6OQnJhm5OlkteOxv9sJycepoxsQ4O2mEWKNiJa9sVgTxdscfLjYV4y0mc7AaCkV01i1IzVK3lBS1lnIjq84CjPIJAZ4btEImc0l9oe4ETPa9soXOqpy4eJPaaf)0ftjjL4iudzdobjigrxuMiabRjgPj8WekeJ0iMaXJZLKkoQnJhm5jYiqV07q9ISJ0)H6dYG9QQxw6LLEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9A0EnijuuMixm1mc7AaCkV01i1xCm9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7L8EzJTEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9cU3b0RQEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5sG6lognJWUMAjPnw6L8EjVxv9Q8RvE(DuhvTz8GjhiE8EjNyuOhmCIXuaGIF6IPKKsCeQHmJmbjigrxuMiabRjgPj8WekeJ0iMaXJZLKkoQnJhm5jYiqV0l4EhqVQ6LLEzPxw6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVgTxdscfLjYftnJWUgaNYlDns9fhtVQ6v5xRCjPIJAQLK2iVCcL0Eb3RYVw5ssfh1uljTroJWUUCcL0EjVx2yRxw6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVG7Da9QQxLFTYLKkoQPwsAJ8Yjus7DiW9AqsOOmrUeO(IJrZiSRPwsAJLEjVxY7vvVk)ALNFh1rvBgpyYbIhVxYjgf6bdNyeaLZsjshjoc1qYbqqcIr0fLjcqWAIrHEWWjglXFoX7GUTo)kVigPj8WekeJS0RYVw5ssfh1uljTrE5ekP9oe4EnijuuMixcuFXXOze21uljTXsVSXwVMjAqBtb4KXtbak(PlMssAVK3RQEzPxw69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84887OoQAZ4btEImc0l9oe4ETPa9QQxAetG4X5ssfh1MXdM8ezeOx61O9AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEzP3b17jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X5ssfh1MXdM8ezeOx61O9AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEPrmbIhNljvCuBgpyYtKrGEP3Ha3RnfOxY7vvVdQxw6Te)Pc0b4yT(lqdOwCiJOfkfNykxKC0fLjc0RQEZVJ1iTrULKmHdPAKAfC0fLjc0l5eJUWGeJL4pN4Dq3wNFLxehHAijzeKGyeDrzIaeSMyKMWdtOqmsddOl(XnG(z9k7vvV53XAK2ixsQ4Og6vOdVxC0fLjc0RQEPrmbIhNZaZmYIoQ6lsg0pEImc0l9oe4EF7aigf6bdNy8Ip1shv9zHAgXgsCeQHKKKGeeJOlkteGG1eJ0eEycfIrAyaDXpUb0pRxzVQ6n)owJ0g5ssfh1qVcD49IJUOmrGEv1RYVw5mWmJSOJQ(IKb9JNiJa9sVdbUxsoGEv1lnIjq84CjPIJAZ4btEImc0l9oe4ETPaeJc9GHtmEXNAPJQ(SqnJydjoc1qsqJGeeJOlkteGG1eJ0eEycfIrw6v5xRCjPIJAQLK2iVCcL0EhcCVgKekktKlbQV4y0mc7AQLK2yPx2yRxZenOTPaCY4Paaf)0ftjjTxY7vvVS0ll9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECE(DuhvTz8Gjprgb6LEhcCV2uGEv1lnIjq84CjPIJAZ4btEImc0l9A0EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwVS07G69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9A0EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwV0iMaXJZLKkoQnJhm5jYiqV07qG71Mc0l59QQ3b1ll9wI)ub6aCSw)fObuloKr0cLItmLlso6IYeb6vvV53XAK2i3ssMWHunsTco6IYeb6LCIrHEWWjgV4tT0rvFwOMrSHehHAi5WqqcIr0fLjcqWAIrAcpmHcXil9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx61O9AqsOOmrUyQze21a4uEPRrQV4y6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2l59YgB9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx6fCVdOxv9Q8RvUKuXrn1ssBKxoHsAVdbUxdscfLjYLa1xCmAgHDn1ssBS0l59sEVQ6v5xR887OoQAZ4btoq849QQ3b1ll9wI)ub6aCSw)fObuloKr0cLItmLlso6IYeb6vvV53XAK2i3ssMWHunsTco6IYeb6LCIrHEWWjgLKkoQnJhmjoc1qY3sqcIr0fLjcqWAIrAcpmHcXOYVw553rDu1MXdMCG4X7vvVS0ll9sJycepo)Ip1shv9zHAgXgYtKrGEPxJ2ljhqVQ6v5xRCjPIJAQLK2iVCcL0Eb3RYVw5ssfh1uljTroJWUUCcL0EjVx2yRxw6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVG7Da9QQxLFTYLKkoQPwsAJ8Yjus7DiW9AqsOOmrUeO(IJrZiSRPwsAJLEjVxY7vvVS0lnIjq84CjPIJAZ4btEImc0l9A0EjJK9YgB9cGk)ALFXNAPJQ(SqnJyd5FZEjVxv9oOEzP3s8NkqhGJ16VanGAXHmIwOuCIPCrYrxuMiqVQ6n)owJ0g5wsYeoKQrQvWrxuMiqVKtmk0dgoXy(DuhvTz8GjXrOgsc6jibXi6IYebiynXinHhMqHyKgXeiECUKuXrDKk8ezeOx61O9(2EzJTEhuVNmr)4ssfh1rQWrxuMiaXOqpy4eJfly9GUT2mEWK4iudjhOeKGyeDrzIaeSMyKMWdtOqmwI)ub6aCSw)fObuloKr0cLItmLlso6IYeb6vvV53XAK2i3ssMWHunsTco6IYeb6vvV0iMaXJZtbak(PlMsskprgb6LEhcCVi7i9FO(GmiXOqpy4eJ53rDu1MXdMehHAi5GtqcIr0fLjcqWAIrAcpmHcXyj(tfOdWXA9xGgqT4qgrlukoXuUi5OlkteOxv9MFhRrAJCljzchs1i1k4OlkteOxv9YsVk)ALljvCutTK0g5LtOK2Rrb3lj7Ln26LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUxKDK(puFqgSxYjgf6bdNymfaO4NUykjPehHAiPrMGeeJOlkteGG1eJ0eEycfIXs8NkqhGJ16VanGAXHmIwOuCIPCrYrxuMiqVQ6n)owJ0g5wsYeoKQrQvWrxuMiqVQ61mrdABkaNmEkaqXpDXussjgf6bdNy8Ip1shv9zHAgXgsCeQb0gabjigrxuMiabRjgPj8WekeJL4pvGoahR1FbAa1IdzeTqP4et5IKJUOmrGEv1B(DSgPnYTKKjCivJuRGJUOmrGEv1RzIg02uaoz8l(ulDu1NfQzeBiXOqpy4eJssfh1MXdMehHAanYiibXi6IYebiynXinHhMqHyKggqx8Jt6RekEVQ6n)owJ0g5ssfh1qVcD49IJUOmrGEv1RYVw5ssfh1MXdM8VzVQ6fav(1kpfaO4NUykjPAd)PJPOaNW7fVCcL0Eb37W0RQEnt0G2McWjJljvCuhPsVQ6vOh0aQrhzGyP3H6DG2RQEhuV53XAK2i3ssMWHunsTco6IYebigf6bdNyusQ4OwzkLJ4iudOrscsqmIUOmracwtmst4HjuigPHb0f)4K(kHI3RQEZVJ1iTrUKuXrn0RqhEV4OlkteOxv9Q8RvUKuXrTz8Gj)B2RQEbqLFTYtbak(PlMssQ2WF6ykkWj8EXlNqjTxW9omeJc9GHtmkjvCuRizk2iXrOgqd0iibXi6IYebiynXinHhMqHyKggqx8Jt6RekEVQ6n)owJ0g5ssfh1qVcD49IJUOmrGEv1RYVw5ssfh1MXdM8VzVQ6LLEbIJNcau8txmLKuEImc0l9A0Eb99YgB9cGk)ALNcau8txmLKuTH)0XuuGt49I)n7L8Ev1laQ8RvEkaqXpDXuss1g(thtrboH3lE5ekP9ouVdtVQ6vOh0aQrhzGyP3H69TeJc9GHtmkjvCuRmLYrCeQb0ggcsqmIUOmracwtmst4HjuigPHb0f)4K(kHI3RQEZVJ1iTrUKuXrTLKmH)IJUOmrGEv1RYVw5ssfh1MXdM8VzVQ6fav(1kpfaO4NUykjPAd)PJPOaNW7fVCcL0Eb3lOrmk0dgoXOKuXrDKkehHAaT3sqcIr0fLjcqWAIrAcpmHcXinmGU4hN0xju8Ev1B(DSgPnYLKkoQTKKj8xC0fLjc0RQEv(1kxsQ4O2mEWK)n7vvVaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOK2l4EjjXOqpy4eJssfh1ksMInsCeQb0a9eKGyeDrzIaeSMyKMWdtOqmsddOl(Xj9vcfVxv9MFhRrAJCjPIJAljzc)fhDrzIa9QQxLFTYLKkoQnJhm5FZEv1RzIg02uaoj5Paaf)0ftjjTxv9k0dAa1OJmqS0Rr7f0igf6bdNyusQ4Ogz3Cgfy4ehHAaTbkbjigrxuMiabRjgPj8WekeJ0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiqVQ6v5xRCjPIJAZ4bt(3Sxv9cGk)ALNcau8txmLKuTH)0XuuGt49IxoHsAVG7LSEv1RqpObuJoYaXsVgTxqJyuOhmCIrjPIJAKDZzuGHtCeQb0gCcsqmIUOmracwtmst4HjuigZVJ1iTrULKmHdPAKAfC0fLjc0RQEbqLFTYtbak(PlMssQ2WF6ykkWj8EXlNqjTxW9sgXOqpy4eJssfh1i7MZOadN4iudOzKjibXi6IYebiynXinHhMqHym)owJ0g5wsYeoKQrQvWrxuMiqVQ6LLEnt0G2McWjJNcau8txmLK0EzJTEzPxZenOTPaCsYtbak(PlMssAVQ6fav(1k)Ip1shv9zHAgXgY)M9sEVKtmk0dgoXOKuXrnYU5mkWWjoc1mmdGGeeJOlkteGG1eJ0eEycfIX87ynsBKBjjt4qQgPwbhDrzIa9QQxau5xR8uaGIF6IPKKQn8NoMIcCcVx8Yjus7fCVGgXOqpy4eJssfh1rQqCeQzyiJGeeJOlkteGG1eJ0eEycfIrLFTYPtusQuoOBZtuOxVQ69Kj6hxsQ4OgPwbhDrzIa9QQxau5xR8l(ulDu1NfQzeBi)Bsmk0dgoXOKuXrndSuGtSqCeQzyijbjigrxuMiabRjgPj8WekeJk)ALdGYzPePJ8VzVQ6fav(1k)Ip1shv9zHAgXgY)M9QQxau5xR8l(ulDu1NfQzeBiprgb6LEhcCVk)ALBMybDkQJQMb6aCgHDD5ekP9oW6vOhmCUKuXrTYukhhzhP)d1hKb7vvVS0ll9EYe9JNyjCXPihDrzIa9QQxHEqdOgDKbILEhQ3HPxY7Ln26vOh0aQrhzGyP3H69T9sEVQ6LLEhuV53XAK2ixsQ4OwjyuKeGb9JJUOmrGEzJTEpjTXJBHY8S4M0RxJ2lO92EjNyuOhmCIrZelOtrDu1mqhG4iuZWaAeKGyeDrzIaeSMyKMWdtOqmQ8RvoakNLsKoY)M9QQxw6LLEpzI(XtSeU4uKJUOmrGEv1RqpObuJoYaXsVd17W0l59YgB9k0dAa1OJmqS07q9(2EjVxv9YsVdQ387ynsBKljvCuRemkscWG(XrxuMiqVSXwVNK24XTqzEwCt61Rr7f0EBVKtmk0dgoXOKuXrTYukhXrOMHzyiibXOqpy4eJLVjMEyqigrxuMiabRjoc1mmVLGeeJOlkteGG1eJ0eEycfIrLFTYLKkoQPwsAJ8Yjus71OG7LLEf6bnGA0rgiw6f0TxY6L8Ev1B(DSgPnYLKkoQvcgfjbyq)4OlkteOxv9EsAJh3cL5zXnPxVd1lO9wIrHEWWjgLKkoQvKmfBK4iuZWa6jibXi6IYebiynXinHhMqHyu5xRCjPIJAQLK2iVCcL0Eb3RYVw5ssfh1uljTroJWUUCcLuIrHEWWjgLKkoQvKmfBK4iuZWmqjibXi6IYebiynXinHhMqHyu5xRCjPIJAQLK2iVCcL0Eb37a6vvVS0lnIjq84CjPIJAZ4btEImc0l9A0Ej7T9YgB9oOEzPxAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxY7LCIrHEWWjgLKkoQJuH4iuZWm4eKGyeDrzIaeSMyKMWdtOqmYsVjwtSyjktSx2yR3b17bPKcD7EjVxv9Q8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHskXOqpy4eJoEwyQpKXelhXrOMHXitqcIr0fLjcqWAIrAcpmHcXOYVw50jkjvkh0T5jk0Rxv9MFhRrAJCjPIJAljzc)fhDrzIa9QQxw6LLEpzI(XfgZjScPYbdNJUOmrGEv1RqpObuJoYaXsVd17G3l59YgB9k0dAa1OJmqS07q9(2EjNyuOhmCIrjPIJAgyPaNyH4iuZBhabjigrxuMiabRjgPj8WekeJk)ALtNOKuPCq3MNOqVEv17jt0pUWyoHvivoy4C0fLjc0RQEf6bnGA0rgiw6DOEhgIrHEWWjgLKkoQzGLcCIfIJqnVLmcsqmIUOmracwtmst4Hjuigv(1kxsQ4OMAjPnYlNqjT3H6v5xRCjPIJAQLK2iNryxxoHskXOqpy4eJssfh1i7MZOadN4iuZBjjbjigrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEnt0G2McWjJljvCuRizk2iXOqpy4eJssfh1i7MZOadN4ioIrljzc)fbjiudzeKGyeDrzIaeSMyuOhmCIr0qqLdgoXiawOj08GHtmAew7Dgp9gEVmIl9koqV0iMaXJx6vsSxAWaD7E)Mg3RD0RyHcqVId0lAiigPj8WekeJmIlCt617qG7f0gqVQ61GKqrzI84FfiaQJQMgXeiE8sVQ6LLEpzI(XZVJ6OQnJhm5OlkteOxv9sJycepop)oQJQ2mEWKNiJa9sVd1lzdOxYjoc1qscsqmIUOmracwtmcGfAcnpy4eJgPyVpIF9ErVLtOK2RLKmH)Q36FoFX7LewyV)c2Bu7LmqFVLtOKw61ctSxyP3l6vO047xV1i79SWEpiL0ENy96n8EplSxQL4oo7vCGEplSxgyPaNyVqV36eABDCIrAcpmHcXil9AqsOOmrE5ekPAljzc)vVSXwVhKb7DOEjBa9sEVQ6v5xRCjPIJAljzc)fVCcL0EhQxYa9eJulb6eJKrmk0dgoXOKuXrndSuGtSqCeQb0iibXi6IYebiynXOqpy4eJssfh1mWsboXcXiawOj08GHtmAKAHEV)c0T71iIX8vIYSxJyjGlofnUxQuUELER4tVi7xk9Yalf4el9(ybNyVpc8GUDV1i79SWEv(1AVY17zH9wojVEJAVNf2BfABDeJ0eEycfIre05dnnraoYy(krzQJeWfNI9QQ3dYG9ouVG2a6vvV0iMaXJZrgZxjktDKaU4uKNiJa9sVgTxYa9dEVQ6Dq9k0dgohzmFLOm1rc4ItroaSikteG4iuZWqqcIr0fLjcqWAIrHEWWjglXFoX7GUTo)kVigPj8WekeJk)ALljvCuBgpyY)M9QQ3tsB84aWYjof7DiW9s2aigDHbjglXFoX7GUTo)kVioc18wcsqmIUOmracwtmk0dgoXyj(ZjEh0T15x5fXinHhMqHy0GKqrzICKXmEWeb0ksMIn2RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG7fzhP)d1hKb7vvV0iMaXJZLKkoQnJhm5jYiqV07qG7LLEr2r6)q9bzWEhy9sYEjVxv9EsAJhhawoXPyVgTxYgaXOlmiXyj(ZjEh0T15x5fXrOgqpbjigrxuMiabRjgPj8WekeJgKekktKJmMXdMiGwrYuSXEv1lnIjq848l(ulDu1NfQzeBiprgb6LEhcCVi7i9FO(GmyVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVS0lYos)hQpid27aRxs2l59QQxw6Dq9IGoFOPjcWlXFoX7GUTo)kV6Ln26LgoWhECjPIJAZmaG2V4P4K2Rrb37B7Ln26LLEPrmbIhNxI)CI3bDBD(vEXtKrGEPxJ2lzKnGEv17jPnECay5eNI9A0EjBa9sEVSXwVS0lnIjq848s8Nt8oOBRZVYlEImc0l9oe4Er2r6)q9bzWEv17jPnECay5eNI9oe4EjBa9sEVKtmk0dgoXykaqXpDXussjoc1mqjibXi6IYebiynXinHhMqHy0GKqrzI8bYF50)ccOlMssAVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVi7i9FO(GmyVQ6LLEhuViOZhAAIa8s8Nt8oOBRZVYREzJTEPHd8HhxsQ4O2mdaO9lEkoP9AuW9(2EzJTEzPxAetG4X5L4pN4Dq3wNFLx8ezeOx61O9sgzdOxv9EsAJhhawoXPyVgTxYgqVK3lBS1ll9sJycepoVe)5eVd6268R8INiJa9sVdbUxKDK(puFqgSxv9EsAJhhawoXPyVdbUxYgqVK3l5eJc9GHtmEXNAPJQ(SqnJydjoc1m4eKGyeDrzIaeSMyKMWdtOqmAMObTnfGtg)Ip1shv9zHAgXgsmk0dgoXOKuXrTz8GjXrOgJmbjigrxuMiabRjgPj8WekeJgKekktKJmMXdMiGwrYuSXEv1lnIjq848uaGIF6IPKKYtKrGEP3Ha3lYos)hQpid2RQEnijuuMi)GmO(7hCQfZEnk4Ej5a6vvVS07G6LgoWhECjPIJAZmaG2V4OlkteOx2yR3b1RbjHIYe5Y8rEv0LxovtJycepEPx2yRxAetG4X5x8Pw6OQpluZi2qEImc0l9oe4EzPxKDK(puFqgS3bwVKSxY7LCIrHEWWjgZVJ6OQnJhmjoc1q2aiibXi6IYebiynXinHhMqHy0GKqrzICKXmEWeb0ksMIn2RQEnt0G2McWjJNFh1rvBgpysmk0dgoXykaqXpDXussjoc1qgzeKGyeDrzIaeSMyKMWdtOqmAqsOOmr(a5VC6Fbb0ftjjTxv9oOEnijuuMi3kMaq3wFXXqmk0dgoX4fFQLoQ6Zc1mInK4iudzKKGeeJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmoquWEjPd0RKuXXEvKmfBSxO37GnSVBeyeBy7n85REH1Ez9mcG5VC9koqVY17eLY1lj7D4dV0Rzgukcqmst4Hjuigv(1kxsQ4OMAjPnYlNqjTxW9Q8RvUKuXrn1ssBKZiSRlNqjTxv9Q8RvE(DuhvTz8Gj)B2RQEv(1kxsQ4O2mEWK)n7vvVk)ALljvCuBjjt4V4LtOK2Rrb3lzG(Ev1RYVw5ssfh1MXdM8ezeOx6DiW9k0dgoxsQ4OwrYuSroYos)hQpid2RQEv(1kxzgbW8xo(3K4iudzGgbjigrxuMiabRjgf6bdNym)oQJQ2mEWKyeal0eAEWWjghikyVK0b61iig2EHEVd2W2B4Zx9cR9Y6zeaZF56vCGEjzVdF4LEnZGsmst4Hjuigv(1kp)oQJQ2mEWKdepEVQ6v5xRCLzeaZF54FZEv1ll9AqsOOmr(bzq93p4ulM9A0EbTb0lBS1lnIjq848uaGIF6IPKKYtKrGEPxJ2lzKSxY7vvVS0RYVw5ssfh1wsYe(lE5ekP9AuW9s2B7Ln26v5xRC6eLKkLd628Yjus71OG7LSEjVxv9YsVdQxA4aF4XLKkoQnZaaA)IJUOmrGEzJTEhuVgKekktKlZh5vrxE5unnIjq84LEjN4iudzddbjigrxuMiabRjgPj8WekeJk)ALljvCuBgpyYbIhVxv9YsVgKekktKFqgu)9do1IzVgTxqBa9YgB9sJycepopfaO4NUykjP8ezeOx61O9sgj7L8Ev1ll9oOEPHd8HhxsQ4O2mdaO9lo6IYeb6Ln26Dq9AqsOOmrUmFKxfD5Lt10iMaXJx6LCIrHEWWjgZVJ6OQnJhmjoc1q2BjibXi6IYebiynXinHhMqHy0GKqrzICKXmEWeb0ksMIn2RQEzPxLFTYLKkoQPwsAJ8Yjus71OG7LK9YgB9sJycepoxsQ4OosfEIcWREjVxv9YsVdQ3tMOF887OoQAZ4bto6IYeb6Ln26LgXeiECE(DuhvTz8Gjprgb6LEnAVVTxY7vvV0iMaXJZLKkoQnJhm5jYiqVOr2nr6Ha9AuW9cAdOxv9YsVdQxA4aF4XLKkoQnZaaA)IJUOmrGEzJTEhuVgKekktKlZh5vrxE5unnIjq84LEjNyuOhmCIXuaGIF6IPKKsCeQHmqpbjigrxuMiabRjgf6bdNy8Ip1shv9zHAgXgsmcGfAcnpy4eJgPwO3B(Dh629AMba0(LX9(lyVxCm9Q8Qx4vWzTxO3BKay27f9ktOT3l869bEw9kMeJ0eEycfIrdscfLjYpidQ)(bNAXS3H69TdOxv9AqsOOmr(bzq93p4ulM9A0EbTb0RQEzP3b1lc68HMMiaVe)5eVd6268R8Qx2yRxA4aF4XLKkoQnZaaA)INItAVgfCVVTxYjoc1q2aLGeeJOlkteGG1eJ0eEycfIrdscfLjYhi)Lt)liGUykjP9QQxLFTYLKkoQPwsAJ8Yjus7DOEv(1kxsQ4OMAjPnYze21LtOKsmk0dgoXOKuXrDKkehHAiBWjibXi6IYebiynXinHhMqHyeav(1kpfaO4NUykjPAd)PJPOaNW7fVCcL0Eb3laQ8RvEkaqXpDXuss1g(thtrboH3loJWUUCcLuIrHEWWjgLKkoQvKmfBK4iudzgzcsqmIUOmracwtmst4HjuignijuuMiFG8xo9VGa6IPKK2lBS1ll9cGk)ALNcau8txmLKuTH)0XuuGt49I)n7vvVaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOK27q9cGk)ALNcau8txmLKuTH)0XuuGt49IZiSRlNqjTxYjgf6bdNyusQ4OwzkLJ4iudjhabjigrxuMiabRjgf6bdNyusQ4OwrYuSrIraSqtO5bdNyCGOG9YaDyVSwYuSXEvW7brV3uaGIF9wmLK0sVWAVFhaZEznR07d8SI)1laoLxq3UxJabak(17OPKK2leaL58fXinHhMqHyu5xR887OoQAZ4bt(3Sxv9Q8RvUKuXrTz8GjhiE8Ev1RYVw5kZiaM)YX)M9QQxAetG4X5Paaf)0ftjjLNiJa9sVdbUxYgqVQ6v5xRCjPIJAljzc)fVCcL0Enk4Ejd0tCeQHKKrqcIr0fLjcqWAIrHEWWjgLKkoQJuHyeal0eAEWWjghikyVrQ0B49sb697tSu6vm7fw6Lgmq3U3VzVLiCIrAcpmHcXOYVw5ssfh1uljTrE5ekP9ouVGwVQ61GKqrzI8dYG6VFWPwm71O9s2a6vvVS0lnIjq848l(ulDu1NfQzeBiprgb6LEnAVVTx2yR3b1lnCGp84ssfh1MzaaTFXrxuMiqVKtCeQHKKKGeeJOlkteGG1eJc9GHtmkjvCuZalf4eleJulb6eJKrmst4Hjuigv(1kNorjPs5GUnprHE9QQxLFTYLKkoQnJhm5FtIJqnKe0iibXi6IYebiynXOqpy4eJssfh1ksMInsmcGfAcnpy4eJgH1EFWETXRxZ4bZEHE9xGH3lWpHUDVZF569bbzo71smG9IE8TT61skh27f9AJxVrT2R0B5YWT7vrYuSXEb(j0T79SWEZWeuIzVpqhiEigPj8WekeJk)ALNFh1rvBgpyY)M9QQxLFTYZVJ6OQnJhm5jYiqV07qG7vOhmCUKuXrndSuGtSWr2r6)q9bzWEv1RYVw5ssfh1MXdM8VzVQ6v5xRCjPIJAQLK2iVCcL0Eb3RYVw5ssfh1uljTroJWUUCcL0Ev1RYVw5ssfh1wsYe(lE5ekP9QQxLFTYnJhm1qV(lWW5FZEv1RYVw5kZiaM)YX)MehHAi5WqqcIr0fLjcqWAIrHEWWjgLKkoQvMs5igbWcnHMhmCIrJWAVpyV241Rz8GzVqV(lWW7f4Nq3U35VC9(GGmN9AjgWErp(2w9AjLd79IETXR3Ow7v6TCz429Qizk2yVa)e629EwyVzyckXS3hOdepg3Bj69bbzo7n85RE)fSx0JVTvVktPCLEHo8GYC(Q3l61gVEVO3A8ZEPwsAJfIrAcpmHcXOYVw5MjwqNI6OQzGoa)B2RQEzPxLFTYLKkoQPwsAJ8Yjus7DOEv(1kxsQ4OMAjPnYze21LtOK2lBS17G6LLEv(1k3mEWud96VadN)n7vvVk)ALRmJay(lh)B2l59sEVQ6Dq9YsVk)ALljvCutTK0g5LtOK2l4EhqVQ6v5xRCZelOtrDu1mqhGxoHsAVG7LSEjN4iudjFlbjigrxuMiabRjgf6bdNy0mXc6uuhvnd0bigbWcnHMhmCIrsyH9QGLR3Fb7nQ9Agm9cl9ErV)c2l869IEbD(qkPZx9Q8HtGEPwsAJLEb(j0T7vm7vQhM9Ew4RETXRxGpJjc0RYREplSxljzc)vVksMInsmst4Hjuigv(1kxsQ4OMAjPnYlNqjT3H6v5xRCjPIJAQLK2iNryxxoHsAVQ6v5xRCjPIJAZ4bt(3K4iudjb9eKGyeDrzIaeSMyeal0eAEWWjgnsXEFe)69IElNqjTxljzc)vV1)C(I3ljSWE)fS3O2lzG(ElNqjT0RfMyVWsVx0RqPX3VERr27zH9EqkP9oX61B49EwyVulXDC2R4a9EwyVmWsboXEHEV1j0264eJc9GHtmkjvCuZalf4eleJq)Wm)MhXizeJulb6eJKrmst4Hjuigv(1kxsQ4O2ssMWFXlNqjT3H6LmqpXi0pmZV5PTNHImjgjJ4iudjhOeKGyeDrzIaeSMyKMWdtOqmQ8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHsAVQ61GKqrzICKXmEWeb0ksMInsmk0dgoXOKuXrTIKPyJehHAi5GtqcIr0fLjcqWAIrAcpmHcXiJ4c3KE9ouVK9wIrHEWWjgrdbvoy4ehHAiPrMGeeJOlkteGG1eJc9GHtmkjvCuRmLYrmcGfAcnpy4eJgX85RE)fSxLPuUEVOxLpCc0l1ssBS0lS27d2RmtuaE1RLya7TemyV1my6nsfIrAcpmHcXOYVw5ssfh1uljTrE5ekP9QQxLFTYLKkoQPwsAJ8Yjus7DOEv(1kxsQ4OMAjPnYze21LtOKsCeQb0gabjigrxuMiabRjgbWcnHMhmCIrJ4doN9(apREfME)(elLEfZEHLEPbd0T79B2R4a9(GGKyVZ4P3W7LrCHyuOhmCIrjPIJAgyPaNyHye6hM538igjJyKAjqNyKmIrAcpmHcX4G6LLEnijuuMi)GmO(7hCQfZEhcCVKnGEv1lJ4c3KE9ouVG2a6LCIrOFyMFZtBpdfzsmsgXrOgqJmcsqmIUOmracwtmcGfAcnpy4eJdBgv4el9(apRENXtVms5W8LX9AbTT61skhACVr2RsCw9YiV61JRxlXa2l6X32QxgXLEVO3Y30mYRxR4PxgXLEH(HEbAa7nfaO4xVftjjTxQ49QGg3Bj69bbzo79xWERWe7vzkLRxXb6TMr5uI517Jf69oJNEdVxgXfIrHEWWjgRWe1ktPCehHAanssqcIrHEWWjgRzuoLyEeJOlkteGG1ehXrmAqcKGeeQHmcsqmIUOmracwtmst4Hjuigpid27q9oqjgf6bdNym)oQJQ2mEWK4iudjjibXi6IYebiynXinHhMqHy8GmyVd17aLyuOhmCIrjPIJ6ivioc1aAeKGyeDrzIaeSMyKMWdtOqmEqgS3H6DGsmk0dgoXOKuXrnYU5mkWWjoc1mmeKGyeDrzIaeSMyuOhmCIrMi8j80MjSWqmst4Hjuignt0G2McWjJZaZmYIoQ6lsg0pIrxyqIrMi8j80MjSWqCeQ5TeKGyeDrzIaeSMyKMWdtOqmsJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3ll9k0dgohneu5GHZr2r6)q9bzWEFVxYaTEjVxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxw6vOhmCoAiOYbdNJSJ0)H6dYG9(EVKnm9soXOqpy4eJOHGkhmCIJqnGEcsqmIUOmracwtmst4Hjuigpid2Rr7f03RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG71i3RQEv(1kVanTcxxUiz4FtIrHEWWjgzGzgzrhv9fjd6hXrOMbkbjigrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEv(1kVanTcxxUiz4jYiqV0Rr7LKdOxv9oOEbqLFTYzGzgzrhv9fjd6h)Bsmk0dgoXOKuXrnYU5mkWWjoc1m4eKGyeDrzIaeSMyKMWdtOqmcGk)ALZaZmYIoQ6lsg0p(3Sxv9EqgS3H6LmqJyuOhmCIrjPIJALPuoIJqngzcsqmIUOmracwtmst4HjuigbqLFTYzGzgzrhv9fjd6hprgb6LEnk4EjZi3RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqVqmk0dgoXOKuXrTYukhXrOgYgabjigrxuMiabRjgPj8WekeJk)ALljvCuBgpyYbIhVxv9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3lYos)hQpid2RQEPrmbIhNljvCuBgpyYtKrGEPxJ2lzdGyuOhmCIX87OoQAZ4btIJqnKrgbjigrxuMiabRjgPj8WekeJhKb71OG7LmqRxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxKDK(puFqgKyuOhmCIXl(ulDu1NfQzeBiXrOgYijbjigrxuMiabRjgPj8WekeJhKb71O9cAdOxv9AMObTnfGtgp)oQJQ2mEWKyuOhmCIXl(ulDu1NfQzeBiXrOgYancsqmIUOmracwtmst4Hjuignt0G2McWjJFXNAPJQ(SqnJydjgf6bdNyusQ4O2mEWK4iudzddbjigrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEv(1kVanTcxxUiz4jYiqV0Rr7LKdtVQ6Dq9cGk)ALFXNAPJQ(SqnJyd5aXJtmk0dgoXOKuXrnYU5mkWWjoc1q2BjibXi6IYebiynXinHhMqHyKgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbU3bVxv9sJycepop)oQJQ2mEWKNiJa9sVdbUxJCVQ6v5xRCjPIJAQLK2iVCcL0Eb3RYVw5ssfh1uljTroJWUUCcL0Ev1RqpObuJoYaXsVd1lOVxq3EzPxY6DG1BbpTs4)c)GysYbxtstAVKtmk0dgoXOKuXrTYukhXrOgYa9eKGyeDrzIaeSMyKAjqNyKmIruY5ln1sGUgwjgv(1kNorjPs5GUTMAjUJtoq84Qe6bnGA0rgiwgc0tmst4Hjuigf6bnGA0rgiw6DOEnY9c62ll9swVdSEl4Pvc)x4hetso4AsAs7L8Ev1laQ8Rv(fFQLoQ6Zc1mInK)n7vvVaOYVw5x8Pw6OQpluZi2qEImc0l9A0Ef6bdNljvCuZalf4elCKDK(puFqgKyuOhmCIrjPIJAgyPaNyH4iudzducsqmIUOmracwtmst4Hjuigv(1kNorjPs5GUnprHEeJc9GHtmkjvCuZalf4elehHAiBWjibXi6IYebiynXinHhMqHyu5xRCjPIJAQLK2iVCcL0Eb37a6vvV0iMaXJZLKkoQnJhm5jYiqV0Rr7LS3smk0dgoXOKuXrDKkehHAiZitqcIr0fLjcqWAIrAcpmHcX4bzWEnAVKnGEv1RYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9QQxAetG4X5x8Pw6OQpluZi2qEImc0l9QQxw6v5xR8c00kCD5IKHNiJa9sVd1ljFBVSXwVk)ALxGMwHRlxKmCG4X7vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx61OG7LmY6LCIrHEWWjgLKkoQvKmfBK4iudjhabjigrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK27q9Q8RvUKuXrn1ssBKZiSRlNqjLyuOhmCIrjPIJAKDZzuGHtCeQHKKrqcIr0fLjcqWAIrAcpmHcXOYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9QQxZenOTPaCY4ssfh1ksMInsmk0dgoXOKuXrnYU5mkWWjoIJyScDzQv(Ptqcc1qgbjigrxuMiabRjgf6bdNyusQ4OMbwkWjwigPwc0jgjJyKMWdtOqmQ8RvoDIssLYbDBEIc9ioc1qscsqmk0dgoXOKuXrTYukhXi6IYebiynXrOgqJGeeJc9GHtmkjvCuRizk2iXi6IYebiynXrCehXObmlWWjudjhajj5aijjb9eJps6q3UqmAKoygbQXiungjZQ92ljSWEHmMrE9wJSxqct0XeKEte05dteO3sWG9k)lyKdb6LAjUnw4T6Sc0XEjJv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxsYQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2lzGgR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo58wDwb6yVKb6z1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKELRxJiJySsVSqg7KZB1zfOJ9s2aLv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6vUEnImIXk9YczStoVvNvGo2lzdoR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo58w9wDJ0bZiqngHQXizwT3EjHf2lKXmYR3AK9csfwSGUTomrhtq6nrqNpmrGElbd2R8VGroeOxQL42yH3QZkqh7LmwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwij7KZB1zfOJ9sswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwiJDY5T6Sc0XEbnwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEhgwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEFlR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVduwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPx561iYigR0llKXo58wDwb6yVKnmSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqs2jN3QZkqh7LSbkR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVKCaSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9ssYy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7LKGgR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo58wDwb6yVKe0ZQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YcjzNCERoRaDSxsc6z1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKELRxJiJySsVSqg7KZB1zfOJ9sYbNv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6vUEnImIXk9YczStoVvNvGo2ljnYSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZB1B1nshmJa1yeQgJKz1E7LewyVqgZiVERr2lizCYbdhKEte05dteO3sWG9k)lyKdb6LAjUnw4T6Sc0XEjJv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCERoRaDSxqJv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCERoRaDS3HHv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCERoRaDS3bNv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCERoRaDSxYgOSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZB1zfOJ9s2aLv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxYgCwT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwiJDY5T6Sc0XEjBWz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7LmJmR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo58wDwb6yVKzKz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7LKdGv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxssgR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58w9wDJ0bZiqngHQXizwT3EjHf2lKXmYR3AK9ccawL)8aP3ebD(Web6TemyVY)cg5qGEPwIBJfERoRaDSxsYQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YcjzNCERoRaDS3HHv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxYgOSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9sMrMv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxssgR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVKe0y1EhE4gW8qGEhHmdV3Yl)e271iE69IEzLV0la0aSadV3Wet5ISxwaf59YczStoVvNvGo2ljbnwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEj5WWQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YczStoVvNvGo2ljhgwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEjjONv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6vUEnImIXk9YczStoVvNvGo2ljhOSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9sYbNv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxsAKz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7f0gaR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVGgzSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1B1nshmJa1yeQgJKz1E7LewyVqgZiVERr2liMjsdgf5aP3ebD(Web6TemyVY)cg5qGEPwIBJfERoRaDS33YQ9o8WnG5Ha9csj(tfOdWvli9ErVGuI)ub6aC1YrxuMiai9YczStoVvNvGo27Bz1EhE4gW8qGEbPe)Pc0b4QfKEVOxqkXFQaDaUA5OlkteaKELRxJiJySsVSqg7KZB1zfOJ9c6z1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7f0ZQ9o8WnG5Ha9ccnCGp84QfKEVOxqOHd8HhxTC0fLjcasVSqg7KZB1zfOJ9oqz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKELRxJiJySsVSqg7KZB1zfOJ9o4SAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9AKz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3Q3QBKoygbQXiungjZQ92ljSWEHmMrE9wJSxqKabP3ebD(Web6TemyVY)cg5qGEPwIBJfERoRaDSxYy1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHKStoVvNvGo2lzSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9sswT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwij7KZB1zfOJ9cASAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqs2jN3QZkqh7f0y1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7Dyy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh79TSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9c6z1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7DGYQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YczStoVvNvGo27GZQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2RrMv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxYgaR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVKrgR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVKrswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZB1zfOJ9sgOXQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2lzddR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVK9wwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEjBGYQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YcjzNCERoRaDSxsoawT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZB1zfOJ9sYbWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2ljhaR27Wd3aMhc0liL4pvGoaxTG07f9csj(tfOdWvlhDrzIaG0llKXo58wDwb6yVKKmwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEjjjz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7LKGgR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKKDY5T6Sc0XEjjOXQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2ljbnwT3HhUbmpeOxqkXFQaDaUAbP3l6fKs8NkqhGRwo6IYebaPxwiJDY5T6Sc0XEj5WWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2ljhgwT3HhUbmpeOxqkXFQaDaUAbP3l6fKs8NkqhGRwo6IYebaPxwiJDY5T6Sc0XEj5Bz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7LKVLv7D4HBaZdb6fKs8NkqhGRwq69IEbPe)Pc0b4QLJUOmraq6LfYyNCERoRaDSxsc6z1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKELRxJiJySsVSqg7KZB1zfOJ9sYbkR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVKCGYQ9o8WnG5Ha9csj(tfOdWvli9ErVGuI)ub6aC1YrxuMiai9YczStoVvNvGo2ljhCwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEj5GZQ9o8WnG5Ha9csj(tfOdWvli9ErVGuI)ub6aC1YrxuMiai9YczStoVvNvGo2ljnYSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9ssJmR27Wd3aMhc0liL4pvGoaxTG07f9csj(tfOdWvlhDrzIaG0llKXo58wDwb6yVG2ay1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7f0gaR27Wd3aMhc0liL4pvGoaxTG07f9csj(tfOdWvlhDrzIaG0llKXo58wDwb6yVGgzSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9cAKXQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9kxVgrgXyLEzHm2jN3QZkqh7f0ijR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVGgOXQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2lOnmSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9cAVLv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxqd0ZQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2lOnqz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7f0gCwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEbnJmR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo58wDwb6yVdZay1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7DyiJv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCERoRaDS3HHKSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZB1zfOJ9omKKv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDS3Hb0y1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHm2jN3QZkqh7DyanwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEhM3YQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo27Wmqz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3QZkqh7DymYSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZB1zfOJ9omgzwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEF7ay1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHm2jN3Q3QBKoygbQXiungjZQ92ljSWEHmMrE9wJSxqSKKj8xG0BIGoFyIa9wcgSx5FbJCiqVulXTXcVvNvGo2lzSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZB1zfOJ9c6z1EhE4gW8qGEb5sOtkECrHYPrmbIhhKEVOxqOrmbIhNlkuq6LfsYo58wDwb6yVduwT3HhUbmpeOxqUe6KIhxuOCAetG4XbP3l6feAetG4X5IcfKEzHKStoVvNvGo2RrMv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3QZkqh7LmqJv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3QZkqh7LSHHv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3QZkqh7LS3YQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YczStoVvNvGo2lzVLv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3QZkqh7LKKXQ9o8WnG5Ha9ccnCGp84QfKEVOxqOHd8HhxTC0fLjcasVSqg7KZB1B1nshmJa1yeQgJKz1E7LewyVqgZiVERr2li0iMaXJxaP3ebD(Web6TemyVY)cg5qGEPwIBJfERoRaDSxYy1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHKStoVvNvGo2lzSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9sswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZB1zfOJ9sswT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEbnwT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZB1zfOJ9cASAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9omSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9(wwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEb9SAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9oqz1EhE4gW8qGEbPe)Pc0b4QfKEVOxqkXFQaDaUA5OlkteaKEzHKStoVvNvGo27GZQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2RrMv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCERoRaDSxYgaR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKKDY5T6Sc0XEjJmwT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZB1zfOJ9sgOXQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YcjzNCERoRaDSxYggwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5T6Sc0XEj7TSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZB1zfOJ9sYbWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVvNvGo2ljjJv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCERoRaDSxssswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwiJDY5T6Sc0XEj5Bz1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHm2jN3Q3QBeYyg5Ha9s2a6vOhm8ENWYv4T6eJMzuHtKy8nVP3bUyJ9oyjvCSv)nVP3bUKuREj7Tg3ljhajjzRER(BEtVd3sCBSWQT6V5n9c627arb79EzcPYS3riZW71sCGj0T7nQ9sTe3XzVq)Wm)Mhm8EHE5qbO3O2liuXP4ul0dgoi8w938MEbD7D4wIBJ9kjvCud9k0H3REVOxjPIJAljzc)vVSaVED0aM9(G(17eAa7vk9kjvCuBjjt4ViN3Q)M30lOBVgjfoixVgrgcQCyVqV3bZiMruVdK)Y1RcsLFb79v8bjXEJ)1Bu7nf3g7vCGE9469xGUDVdwsfh71iIDZzuGHZB1FZB6f0T3bdyG8xUEntyKW7vVx07VG9oyjvCS3HnEWeKsVyTI0dAa7LgXeiE8EvKcc0B49oCJKmc6fRvKEfER(BEtVGU9oquWElxcPxVMzqXsb629ErVjc8PyVdFyhi69GmyVaFS3l697osXsrYx9oydlR0Bnssl8w938MEbD7DGhgqGEnijuuMybuuzs)t5GHx69IEzLV0lta8NyVx0BIaFk27Wh2bIEpidYB1B1f6bdVWntKgmkY9oyqjjvCud9dNtKET6c9GHx4Mjsdgf5EhmOKKkoQRcdCcLSvxOhm8c3mrAWOi37Gbfn8bYFIAgXfTnY0Q)M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyjq9jPnEAA89Z4WeCIf8mgaRYFEGbTw938MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbJgcTj9mombNybpJbWQ8NhyYEBR(BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGnt08pNA0qyCycUGNXWkywYVJ1iTrEbAAfUUCrYOIfAyaDXpUb0pRxjBSrddOl(XDKMXmsa2yJgoWhECjPIJAZmaG2ViNCJniZpcMmJniZpQXzbbpGw938MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbBjgqDyIocyCycUGNXWkyHEqdOgDKbIfJc2GKqrzICjq9jPnEAA89ZydY8JGjZydY8JACwqWdOv)nVPxHEWWlCZePbJICVdgugKekkt0yxyqWvOltTYpDJdtWf8m2Gm)i4b0Q)M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyljzc)LUCcLu9bzqJdtWjwWZyaSk)5b2i3Q)M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyz(iVk6YlNQPrmbIhVyCycoXcEgdGv5ppWdOv)nVPxHEWWlCZePbJICVdgugKekkt0yxyqWzrZiSRbWP8sxJuFXXyCycoXcEgdGv5ppWVTv)nVPxHEWWlCZePbJICVdgugKekkt0yxyqWzrZiSRbWP8sxJuNHPXHj4el4zmawL)8a)2w938MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbNfnJWUgaNYlDnsTyACycoXcEgdGv5ppWKCaT6V5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdcMjoTzIueb0xCmALxghMGtSGNXayv(Zd8G3Q)M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyM40mc7AaCkV01i1xCmghMGtSGNXayv(ZdmzdOv)nVPxHEWWlCZePbJICVdgugKekkt0yxyqWmXPze21a4uEPRrQftJdtWjwWZyaSk)5bMS32Q)M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyXuZiSRbWP8sxJuFXXyCycoXcEgdRGPHd8HhxsQ4O2mdaO9lJniZpcg0gGXgK5h14SGGjBaT6V5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdcwm1mc7AaCkV01i1xCmghMGtSGNXayv(ZdmjhqR(BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGftnJWUgaNYlDnsntCghMGtSGNXayv(ZdmjhqR(BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGZWuZiSRbWP8sxJuFXXyCycUGNXgK5hbtYba6YYBhy0Wb(WJljvCuBMba0(f5T6V5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdc(IJrZiSRbWP8sxJulMghMGl4zSbz(rWV9DsoGbgl0Wa6IFChABD6QGSXgl0Wb(WJljvCuBMba0(LkHEqdOgDKbILHmijuuMixcuFsAJNMgF)iN83j7TdmwOHb0f)4K(kHIRk)owJ0g5ssfh1wsYe(lvc9Ggqn6idelgfSbjHIYe5sG6tsB80047h5T6V5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdc(IJrZiSRbWP8sxJuNHPXHj4cEgBqMFemjhaOlld(aJgoWhECjPIJAZmaG2ViVv)nVPxHEWWlCZePbJICVdgugKekkt0yxyqWksMInQzex0M0Z4WeCbpJHvW0Wa6IFChABD6QGgBqMFemOFaGUSWiLdZxAdY8JdmYgWaiVv)nVPxHEWWlCZePbJICVdgugKekkt0yxyqWksMInQzex0M0Z4WeCbpJHvW0Wa6IFCsFLqXn2Gm)iyJ8BbDzHrkhMV0gK5hhyKnGbqER(BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGvKmfBuZiUOnPNXHj4cEgdRGnijuuMixrYuSrnJ4I2KEGhGXgK5hbp4da0LfgPCy(sBqMFCGr2aga5T6V5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdcwm1mqhY8z0mIlAt6zCycoXcEgdGv5ppWK92w938MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbFXXOze21uljTXIXHj4el4zmawL)8atYw938MEf6bdVWntKgmkY9oyqzqsOOmrJDHbblbQV4y0mc7AQLK2yX4WeCIf8mgaRYFEGjzR(BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGRWIf0T1Hj6yACycUGNXgK5hbt2aJfe05dnnraoYy(krzQJeWfNISXglNmr)453rDu1MXdMQy5Kj6hxsQ4OgPwbBSniAyaDXpoPVsO4KRILbrddOl(XDKMXmsa2ytOh0aQrhzGybmzSXw(DSgPnYlqtRW1LlsgYvniAyaDXpUb0pRxj5K3Q)M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyXuhU(xqJdtWf8m2Gm)iye05dnnraoJqfLe1flepnZVaPSXgc68HMMia3Ekaq5ISOveaBKn2qqNp00eb42tbakxKfndciZjmC2ydbD(qtteGdijPmr4AaKsQ28FjwOOtr2ydbD(qtteGd9cn)NOmrnOZx87ZObqdqkYgBiOZhAAIa8s8Nt8oOBRZVYl2ydbD(qtteGx(UYmcaTWGN1RYXgBiOZhAAIa8hHu0XSORz4aSXgc68HMMiaVofguhvTIC3eB1f6bdVWntKgmkY9oyqXaZmsnKrSXwDHEWWlCZePbJICVdgu1jwSOPupJHvWL4pvGoa3qmLdorDjMgq)yJTs8NkqhGB(l3FIAm)Mhm8wDHEWWlCZePbJICVdgu53rDu1MXdMgdRGPHb0f)4K(kHIRk)owJ0g5ssfh1wsYe(lv0Wb(WJljvCuBMba0(LkdscfLjYL5J8QOlVCQMgXeiE8IkHEqdOgDKbILHmijuuMixcuFsAJNMgF)A1f6bdVWntKgmkY9oyqvZOCkX8mgwbpidscfLjYnt08pNA0qaMmv53XAK2ihawOqZj0L8LMgmmId0Ql0dgEHBMinyuK7DWGssQ4OwzkLZyyf8GmijuuMi3mrZ)CQrdbyYunO87ynsBKdaluO5e6s(stdggXbuXYGOHb0f)4gq)SELSXMbjHIYe5vyXc626WeDmjVvxOhm8c3mrAWOi37GbfdmZil6OQVizq)mgwbpidscfLjYnt08pNA0qaMmvdk)owJ0g5aWcfAoHUKV00GHrCav0Wa6IFCdOFwVsvdYGKqrzI8kSybDBDyIoMT6c9GHx4Mjsdgf5EhmOqdbvoy4gdRGnijuuMi3mrZ)CQrdbyYA1B1f6bdV8oyqrJVFywmX5SvxOhm8Y7Gb1VGAgXfTnYymScMLtMOFC0NqBRdDeqfJ4c3KEdbEWhGkgXfUj9mkyq)BjNn2yzqNmr)4OpH2wh6iGkgXfUj9gc8G)wYB1f6bdV8oyqzghmCJHvWk)ALljvCuBgpyY)MT6c9GHxEhmOoidQFK00yyfC(DSgPnYpKXmszQFK0uLYVw5i7wYVCWW5FtvSqJycepoxsQ4O2mEWKNOa8In2uIsrvfABD6ezeOxgc8WmaYB1f6bdV8oyqnH2wxrpq(bSzq)mgwbR8RvUKuXrTz8GjhiECvk)ALNFh1rvBgpyYbIhxfaQ8Rv(fFQLoQ6Zc1mInKdepERUqpy4L3bdkfXwhv9LqkPfJHvWk)ALljvCuBgpyYbIhxLYVw553rDu1MXdMCG4XvbGk)ALFXNAPJQ(SqnJyd5aXJ3Ql0dgE5DWGsbZcMKcDBJHvWk)ALljvCuBgpyY)MT6c9GHxEhmOuMraOR)8LXWkyLFTYLKkoQnJhm5FZwDHEWWlVdguvyIkZiamgwbR8RvUKuXrTz8Gj)B2Ql0dgE5DWGsCkwUuMAQmNgdRGv(1kxsQ4O2mEWK)nB1f6bdV8oyq9lOgEitXyyfSYVw5ssfh1MXdM8VzRUqpy4L3bdQFb1Wdzm2fgeCHkzrhvDnLdtxM6YLWk2Ql0dgE5DWG6xqn8qgJXAfPN2fgeS9uaGYfzrRia2OXWkyLFTYLKkoQnJhm5Ft2yJgXeiECUKuXrTz8Gjprgb6fJc(TVvfaQ8Rv(fFQLoQ6Zc1mInK)nB1f6bdV8oyq9lOgEiJXUWGGzIWNWtBMWcJXWkyAyaDXpoPVsO4QOrmbIhNljvCuBgpyYtKrGEziWKnav0iMaXJZV4tT0rvFwOMrSH8ezeOxgcmzdOvxOhm8Y7Gb1VGA4Hmg7cdcMjcFcpTzclmgdRGhenmGU4hN0xjuCv0iMaXJZLKkoQnJhm5jYiqVmeyqVkAetG4X5x8Pw6OQpluZi2qEImc0ldbg0R6GmOrbTbOILbrddOl(XnG(z9kzJnHEqdOgDKbILHmijuuMixcuFsAJNMgF)iVvxOhm8Y7Gb1VGA4Hmg7cdcgzmFLOm1rc4ItrJHvW0iMaXJZLKkoQnJhm5jYiqVmeyYERkAetG4X5x8Pw6OQpluZi2qEImc0ldbMS32Ql0dgE5DWG6xqn8qgJDHbbdKOauHjQnGLcongwbtJycepoxsQ4O2mEWKNiJa9IrbtYbWgBdYGKqrzICXuhU(xqWKXgBSCqge8auzqsOOmrEfwSGUTomrhtWKPk)owJ0g5fOPv46Yfjd5T6c9GHxEhmO(fudpKXyxyqWL4p1qBhEyAmScMgXeiECUKuXrTz8Gjprgb6fJcg0gaBSnidscfLjYftD46FbbtwRUqpy4L3bdQFb1Wdzm2fgeS98LPLoQAPuGmWPCWWngwbtJycepoxsQ4O2mEWKNiJa9IrbtYbWgBdYGKqrzICXuhU(xqWKXgBSCqge8auzqsOOmrEfwSGUTomrhtWKPk)owJ0g5fOPv46Yfjd5T6c9GHxEhmO(fudpKXyxyqWmcvusuxSq80m)cKAmScMgXeiECUKuXrTz8Gjprgb6LHa)wvSmidscfLjYRWIf0T1Hj6ycMm2y7GmOrbTbqERUqpy4L3bdQFb1Wdzm2fgemJqfLe1flepnZVaPgdRGPrmbIhNljvCuBgpyYtKrGEziWVvLbjHIYe5vyXc626WeDmbtMkLFTYZVJ6OQnJhm5Ftvk)ALNFh1rvBgpyYtKrGEziWSq2aaDF7al)owJ0g5fOPv46Yfjd5QoidoeOnGwDHEWWlVdgu)cQHhYySlmi4ILaepiGosfDu1xKmOFgdRGpidcEaSXglgKekktKh)RabqDu10iMaXJxuXcl0Wa6IFCsFLqXvrJycepopfaO4NUykjP8ezeOxgcmjvrJycepoxsQ4O2mEWKNiJa9YqGFRkAetG4X5x8Pw6OQpluZi2qEImc0ldb(TKZgB0iMaXJZLKkoQnJhm5jYiqVmeysYgBvOT1PtKrGEziAetG4X5ssfh1MXdM8ezeOxiN8w9307B5G(EHLEplS3IjIa9g1EplS3X4pN4Dq3UxJGVYREnZyGePhCIT6c9GHxEhmO(fudpKXyxyqWL4pN4Dq3wNFLxgdRGzXGKqrzI8dYG6VFWPwmFNfHEWW5Paaf)0ftjjLJSJ0)H6dYGdmAyaDXpoPVsO4K)olc9GHZbq5SuI0roYos)hQpidoWOHb0f)4osZygja5Vl0dgo)Ip1shv9zHAgXgYr2r6)q9bzWHojTXJdalN4u0iEElh0tUkwmijuuMi3smG6WeDeGn2yHggqx8Jt6RekUQ87ynsBKljvCud9k0H3lYjx1jPnECay5eNIgLKVTv)nVPxHEWWlVdguo(uJVdOtSetdOX)cQFSGtutLYbDBWKzmScw5xRCjPIJAZ4bt(3Kn2aqLFTYV4tT0rvFwOMrSH8VjBSbehpfaO4NUykjP8dsjf62T6V5n9k0dgE5DWGIkZPwOhmC9ewoJDHbbtLj9pLdgEPvxOhm8Y7GbfvMtTqpy46jSCg7cdc2GeOXLlH0dmzgdRGPHb0f)4gq)SELQYVJ1iTrEbAAfUUCrYO6Kj6hxsQ4OgPwHkHEqdOgDKbIfJc2GKqrzICjq9jPnEAA89RvxOhm8Y7GbfvMtTqpy46jSCg7cdcwc04YLq6bMmJHvWc9Ggqn6idelgfSbjHIYe5sG6tsB80047xRUqpy4L3bdkQmNAHEWW1ty5m2fgeSLKmH)Y4YLq6bMmJHvW0Wa6IFCsFLqXvLFhRrAJCjPIJAljzc)vRUqpy4L3bdkQmNAHEWW1ty5m2fgeCfwSGUTomrhtJlxcPhyYmgwbBqsOOmrULya1Hj6ia4bOYGKqrzI8kSybDBDyIoMQgel0Wa6IFCsFLqXvLFhRrAJCjPIJAljzc)f5T6c9GHxEhmOOYCQf6bdxpHLZyxyqWHj6yAC5si9atMXWkydscfLjYTedOomrhbapavdIfAyaDXpoPVsO4QYVJ1iTrUKuXrTLKmH)I8wDHEWWlVdguuzo1c9GHRNWYzSlmiyAetG4XlgxUespWKzmScEqSqddOl(Xj9vcfxv(DSgPnYLKkoQTKKj8xK3Ql0dgE5DWGIkZPwOhmC9ewoJDHbbNXjhmCJlxcPhyYmgwbBqsOOmrEf6YuR8th8auniwOHb0f)4K(kHIRk)owJ0g5ssfh1wsYe(lYB1f6bdV8oyqrL5ul0dgUEclNXUWGGRqxMALF6gxUespWKzmSc2GKqrzI8k0LPw5NoyYuniwOHb0f)4K(kHIRk)owJ0g5ssfh1wsYe(lYB1B1f6bdVWLabxZOCkX8mgwbNFhRrAJCayHcnNqxYxAAWWioGkAetG4X5k)AvdaluO5e6s(stdggXb4jkaVuP8RvoaSqHMtOl5lnnyyehqxZOCCG4XvXIYVw5ssfh1MXdMCG4XvP8RvE(DuhvTz8GjhiECvaOYVw5x8Pw6OQpluZi2qoq84KRIgXeiEC(fFQLoQ6Zc1mInKNiJa9c4bOIfLFTYLKkoQPwsAJ8YjushcSbjHIYe5sG6lognJWUMAjPnwuXclNmr)453rDu1MXdMQOrmbIhNNFh1rvBgpyYtKrGEziW2uav0iMaXJZLKkoQnJhm5jYiqVyudscfLjYV4y0mc7AaCkV01i1Ij5SXgld6Kj6hp)oQJQ2mEWufnIjq84CjPIJAZ4btEImc0lg1GKqrzI8lognJWUgaNYlDnsTysoBSrJycepoxsQ4O2mEWKNiJa9YqGTPaKtERUqpy4fUe47GbvfMOwzkLZyyfml53XAK2ihawOqZj0L8LMgmmIdOIgXeiECUYVw1aWcfAoHUKV00GHrCaEIcWlvk)ALdaluO5e6s(stdggXb0vyICG4XvzMObTnfGtgVMr5uI5roBSXs(DSgPnYbGfk0CcDjFPPbdJ4aQoidcEaK3Ql0dgEHlb(oyqvZOCApmigdRGZVJ1iTrUDclZxAifsNOkAetG4X5ssfh1MXdM8ezeOxmkOnav0iMaXJZV4tT0rvFwOMrSH8ezeOxapavSO8RvUKuXrn1ssBKxoHs6qGnijuuMixcuFXXOze21uljTXIkwy5Kj6hp)oQJQ2mEWufnIjq84887OoQAZ4btEImc0ldb2McOIgXeiECUKuXrTz8Gjprgb6fJAqsOOmr(fhJMryxdGt5LUgPwmjNn2yzqNmr)453rDu1MXdMQOrmbIhNljvCuBgpyYtKrGEXOgKekktKFXXOze21a4uEPRrQftYzJnAetG4X5ssfh1MXdM8ezeOxgcSnfGCYB1f6bdVWLaFhmOQzuoThgeJHvW53XAK2i3oHL5lnKcPtufnIjq84CjPIJAZ4btEImc0lGhGkwyHfAetG4X5x8Pw6OQpluZi2qEImc0lg1GKqrzICXuZiSRbWP8sxJuFXXOs5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusjNn2yHgXeiEC(fFQLoQ6Zc1mInKNiJa9c4bOs5xRCjPIJAQLK2iVCcL0HaBqsOOmrUeO(IJrZiSRPwsAJfYjxLYVw553rDu1MXdMCG4XjVvxOhm8cxc8DWGssQ4OMbwkWjwmgwbtddOl(Xj9vcfxv(DSgPnYLKkoQTKKj8xQu(1kxsQ4O2ssMWFXlNqjDiYERkAetG4X5Paaf)0ftjjLNiJa9YqGnijuuMi3ssMWFPlNqjvFqg8DKDK(puFqgufnIjq848l(ulDu1NfQzeBiprgb6LHaBqsOOmrULKmH)sxoHsQ(Gm47i7i9FO(Gm47c9GHZtbak(PlMsskhzhP)d1hKbvrJycepoxsQ4O2mEWKNiJa9YqGnijuuMi3ssMWFPlNqjvFqg8DKDK(puFqg8DHEWW5Paaf)0ftjjLJSJ0)H6dYGVl0dgo)Ip1shv9zHAgXgYr2r6)q9bzqJPwc0btwRUqpy4fUe47GbLKuXrndSuGtSymScMggqx8JBa9Z6vQk)owJ0g5ssfh1qVcD49sLYVw5ssfh1wsYe(lE5ekPdr2BvrJycepo)Ip1shv9zHAgXgYtKrGEziWgKekktKBjjt4V0LtOKQpid(oYos)hQpidQIgXeiECUKuXrTz8Gjprgb6LHaBqsOOmrULKmH)sxoHsQ(Gm47i7i9FO(Gm47c9GHZV4tT0rvFwOMrSHCKDK(puFqg0yQLaDWK1Ql0dgEHlb(oyqjjvCuRmLYzmScMggqx8JBa9Z6vQ6Kj6hxsQ4OgPwHQdYGdr2aurJycepoNbMzKfDu1xKmOF8ezeOxuP8RvoDIssLYbDBE5ekPdbAT6c9GHx4sGVdgu)cQHhYySlmi4s8Nt8oOBRZVYlJHvW53XAK2iVanTcxxUizuzMObTnfGtghneu5GH3Ql0dgEHlb(oyqDXNAPJQ(SqnJydngwbNFhRrAJ8c00kCD5IKrLzIg02uaozC0qqLdgERUqpy4fUe47GbLKuXrTz8GPXWk487ynsBKxGMwHRlxKmQyXmrdABkaNmoAiOYbdNn2mt0G2McWjJFXNAPJQ(SqnJydjVvxOhm8cxc8DWGIbMzKfDu1xKmOFgdRGZVJ1iTrUKuXrn0RqhEVurJycepo)Ip1shv9zHAgXgYtKrGEziWKnav0iMaXJZLKkoQnJhm5jYiqVmeyYEBRUqpy4fUe47GbfdmZil6OQVizq)mgwbtJycepoxsQ4O2mEWKNiJa9YqGhCv0iMaXJZV4tT0rvFwOMrSH8ezeOxgc8GRIfLFTYLKkoQPwsAJ8YjushcSbjHIYe5sG6lognJWUMAjPnwuXclNmr)453rDu1MXdMQOrmbIhNNFh1rvBgpyYtKrGEziW2uav0iMaXJZLKkoQnJhm5jYiqVy03soBSXYGozI(XZVJ6OQnJhmvrJycepoxsQ4O2mEWKNiJa9IrFl5SXgnIjq84CjPIJAZ4btEImc0ldb2Mcqo5T6c9GHx4sGVdguOHGkhmCJHvWhKbnkOnav53XAK2iVanTcxxUizurddOl(XnG(z9kvzMObTnfGtgNbMzKfDu1xKmOFT6c9GHx4sGVdguOHGkhmCJHvWhKbnkOnav53XAK2iVanTcxxUizuP8RvUKuXrn1ssBKxoHs6qGnijuuMixcuFXXOze21uljTXIkAetG4X5x8Pw6OQpluZi2qEImc0lGhGkAetG4X5ssfh1MXdM8ezeOxgcSnfOvxOhm8cxc8DWGcneu5GHBmSc(GmOrbTbOk)owJ0g5fOPv46YfjJkAetG4X5ssfh1MXdM8ezeOxapavSWcl0iMaXJZV4tT0rvFwOMrSH8ezeOxmQbjHIYe5IPMryxdGt5LUgP(IJrLYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKsoBSXcnIjq848l(ulDu1NfQzeBiprgb6fWdqLYVw5ssfh1uljTrE5ekPdb2GKqrzICjq9fhJMryxtTK0glKtUkLFTYZVJ6OQnJhm5aXJtUXq)Wm)MNgwbR8RvEbAAfUUCrYWlNqjfSYVw5fOPv46YfjdNryxxoHsQXq)Wm)MNgYWGaq5qWK1Ql0dgEHlb(oyq9lOgEiJXUWGGlXFoX7GUTo)kVmgwbtJycepopfaO4NUykjP8efGxQOrmbIhNFXNAPJQ(SqnJyd5jYiqVmeyBkaNryxfnIjq84CjPIJAZ4btEImc0ldb2McWze2B1f6bdVWLaFhmOsbak(PlMssQXWkyAetG4X5x8Pw6OQpluZi2qEImc0ldHSJ0)H6dYGQyHLtMOF887OoQAZ4btv0iMaXJZZVJ6OQnJhm5jYiqVmeyBkGkAetG4X5ssfh1MXdM8ezeOxmQbjHIYe5xCmAgHDnaoLx6AKAXKC2yJLbDYe9JNFh1rvBgpyQIgXeiECUKuXrTz8Gjprgb6fJAqsOOmr(fhJMryxdGt5LUgPwmjNn2OrmbIhNljvCuBgpyYtKrGEziW2uaYB1f6bdVWLaFhmOsbak(PlMssQXWkyAetG4X5ssfh1MXdM8ezeOxgczhP)d1hKbvXclSqJycepo)Ip1shv9zHAgXgYtKrGEXOgKekktKlMAgHDnaoLx6AK6logvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsk5SXgl0iMaXJZV4tT0rvFwOMrSH8ezeOxapavk)ALljvCutTK0g5LtOKoeydscfLjYLa1xCmAgHDn1ssBSqo5Qu(1kp)oQJQ2mEWKdepo5T6c9GHx4sGVdguaOCwkr6OXWkyAetG4X5ssfh1MXdM8ezeOxapavSWcl0iMaXJZV4tT0rvFwOMrSH8ezeOxmQbjHIYe5IPMryxdGt5LUgP(IJrLYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKsoBSXcnIjq848l(ulDu1NfQzeBiprgb6fWdqLYVw5ssfh1uljTrE5ekPdb2GKqrzICjq9fhJMryxtTK0glKtUkLFTYZVJ6OQnJhm5aXJtERUqpy4fUe47Gb1VGA4Hmg7cdcUe)5eVd6268R8Yyyfmlk)ALljvCutTK0g5LtOKoeydscfLjYLa1xCmAgHDn1ssBSWgBMjAqBtb4KXtbak(PlMssk5QyHLtMOF887OoQAZ4btv0iMaXJZZVJ6OQnJhm5jYiqVmeyBkGkAetG4X5ssfh1MXdM8ezeOxmQbjHIYe5xCmAgHDnaoLx6AKAXKC2yJLbDYe9JNFh1rvBgpyQIgXeiECUKuXrTz8Gjprgb6fJAqsOOmr(fhJMryxdGt5LUgPwmjNn2OrmbIhNljvCuBgpyYtKrGEziW2uaYvniwkXFQaDaowR)c0aQfhYiAHsXjMYfPQ87ynsBKBjjt4qQgPwb5T6c9GHx4sGVdgux8Pw6OQpluZi2qJHvW0Wa6IFCdOFwVsv53XAK2ixsQ4Og6vOdVxQOrmbIhNZaZmYIoQ6lsg0pEImc0ldb(TdOvxOhm8cxc8DWG6Ip1shv9zHAgXgAmScMggqx8JBa9Z6vQk)owJ0g5ssfh1qVcD49sLYVw5mWmJSOJQ(IKb9JNiJa9YqGj5aurJycepoxsQ4O2mEWKNiJa9YqGTPaT6c9GHx4sGVdgux8Pw6OQpluZi2qJHvWSO8RvUKuXrn1ssBKxoHs6qGnijuuMixcuFXXOze21uljTXcBSzMObTnfGtgpfaO4NUykjPKRIfwozI(XZVJ6OQnJhmvrJycepop)oQJQ2mEWKNiJa9YqGTPaQOrmbIhNljvCuBgpyYtKrGEXOgKekktKFXXOze21a4uEPRrQftYzJnwg0jt0pE(DuhvTz8GPkAetG4X5ssfh1MXdM8ezeOxmQbjHIYe5xCmAgHDnaoLx6AKAXKC2yJgXeiECUKuXrTz8Gjprgb6LHaBtbix1GyPe)Pc0b4yT(lqdOwCiJOfkfNykxKQYVJ1iTrULKmHdPAKAfK3Ql0dgEHlb(oyqjjvCuBgpyAmScMfwOrmbIhNFXNAPJQ(SqnJyd5jYiqVyudscfLjYftnJWUgaNYlDns9fhJkLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjLC2yJfAetG4X5x8Pw6OQpluZi2qEImc0lGhGkLFTYLKkoQPwsAJ8YjushcSbjHIYe5sG6lognJWUMAjPnwiNCvk)ALNFh1rvBgpyYbIhx1GyPe)Pc0b4yT(lqdOwCiJOfkfNykxKQYVJ1iTrULKmHdPAKAfK3Ql0dgEHlb(oyqLFh1rvBgpyAmScw5xR887OoQAZ4btoq84QyHfAetG4X5x8Pw6OQpluZi2qEImc0lgLKdqLYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKsoBSXcnIjq848l(ulDu1NfQzeBiprgb6fWdqLYVw5ssfh1uljTrE5ekPdb2GKqrzICjq9fhJMryxtTK0glKtUkwOrmbIhNljvCuBgpyYtKrGEXOKrs2ydav(1k)Ip1shv9zHAgXgY)MKRAqSuI)ub6aCSw)fObuloKr0cLItmLlsv53XAK2i3ssMWHunsTcYB1f6bdVWLaFhmOkwW6bDBTz8GPXWkyAetG4X5ssfh1rQWtKrGEXOVLn2g0jt0pUKuXrDKkT6c9GHx4sGVdgu53rDu1MXdMgdRGlXFQaDaowR)c0aQfhYiAHsXjMYfPQ87ynsBKBjjt4qQgPwHkAetG4X5Paaf)0ftjjLNiJa9YqGr2r6)q9bzWwDHEWWlCjW3bdQuaGIF6IPKKAmScUe)Pc0b4yT(lqdOwCiJOfkfNykxKQYVJ1iTrULKmHdPAKAfQyr5xRCjPIJAQLK2iVCcLuJcMKSXgnIjq848l(ulDu1NfQzeBiprgb6LHaJSJ0)H6dYGK3Ql0dgEHlb(oyqDXNAPJQ(SqnJydngwbxI)ub6aCSw)fObuloKr0cLItmLlsv53XAK2i3ssMWHunsTcvMjAqBtb4KXtbak(PlMssARUqpy4fUe47GbLKuXrTz8GPXWk4s8NkqhGJ16VanGAXHmIwOuCIPCrQk)owJ0g5wsYeoKQrQvOYmrdABkaNm(fFQLoQ6Zc1mInSv)nVPxHEWWlCjW3bdQhbEgxqk4bWhWWymScgav(1kpfaO4NUykjPAd)PJPOaNW7fVCcLuWSaGk)ALNcau8txmLKuTH)0XuuGt49IZiSRlNqjf0LmYvLFhRrAJCljzchs1i1kuj0dAa1OJmqSm0BnEcDutbatY32Ql0dgEHlb(oyqjjvCuRmLYzmScMggqx8Jt6RekUQ87ynsBKljvCud9k0H3lvk)ALljvCuBgpyY)MQaqLFTYtbak(PlMssQ2WF6ykkWj8EXlNqjf8WOYmrdABkaNmUKuXrDKkQe6bnGA0rgiwgAGQAq53XAK2i3ssMWHunsTIwDHEWWlCjW3bdkjPIJAfjtXgngwbtddOl(Xj9vcfxv(DSgPnYLKkoQHEf6W7LkLFTYLKkoQnJhm5FtvaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOKcEyA1f6bdVWLaFhmOKKkoQvMs5mgwbtddOl(Xj9vcfxv(DSgPnYLKkoQHEf6W7LkLFTYLKkoQnJhm5FtvSaehpfaO4NUykjP8ezeOxmkONn2aqLFTYtbak(PlMssQ2WF6ykkWj8EX)MKRcav(1kpfaO4NUykjPAd)PJPOaNW7fVCcL0Hggvc9Ggqn6ideld92wDHEWWlCjW3bdkjPIJ6ivmgwbtddOl(Xj9vcfxv(DSgPnYLKkoQTKKj8xQu(1kxsQ4O2mEWK)nvbGk)ALNcau8txmLKuTH)0XuuGt49IxoHskyqRvxOhm8cxc8DWGssQ4OwrYuSrJHvW0Wa6IFCsFLqXvLFhRrAJCjPIJAljzc)LkLFTYLKkoQnJhm5FtvaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOKcMKT6c9GHx4sGVdgussfh1i7MZOad3yyfmnmGU4hN0xjuCv53XAK2ixsQ4O2ssMWFPs5xRCjPIJAZ4bt(3uLzIg02uaoj5Paaf)0ftjjvLqpObuJoYaXIrbTwDHEWWlCjW3bdkjPIJAKDZzuGHBmScMggqx8Jt6RekUQ87ynsBKljvCuBjjt4VuP8RvUKuXrTz8Gj)BQcav(1kpfaO4NUykjPAd)PJPOaNW7fVCcLuWKPsOh0aQrhzGyXOGwRUqpy4fUe47GbLKuXrnYU5mkWWngwbNFhRrAJCljzchs1i1kubGk)ALNcau8txmLKuTH)0XuuGt49IxoHskyYA1f6bdVWLaFhmOKKkoQr2nNrbgUXWk487ynsBKBjjt4qQgPwHkwmt0G2McWjJNcau8txmLKu2yJfZenOTPaCsYtbak(PlMssQkau5xR8l(ulDu1NfQzeBi)Bso5T6c9GHx4sGVdgussfh1rQymSco)owJ0g5wsYeoKQrQvOcav(1kpfaO4NUykjPAd)PJPOaNW7fVCcLuWGwRUqpy4fUe47GbLKuXrndSuGtSymScw5xRC6eLKkLd628ef6P6Kj6hxsQ4OgPwHkau5xR8l(ulDu1NfQzeBi)B2Ql0dgEHlb(oyqzMybDkQJQMb6agdRGv(1khaLZsjsh5FtvaOYVw5x8Pw6OQpluZi2q(3ufaQ8Rv(fFQLoQ6Zc1mInKNiJa9YqGv(1k3mXc6uuhvnd0b4mc76Yjushyc9GHZLKkoQvMs54i7i9FO(GmOkwy5Kj6hpXs4Itrvc9Ggqn6ideldnmKZgBc9Ggqn6ideld9wYvXYGYVJ1iTrUKuXrTsWOijad6hBSDsAJh3cL5zXnPNrbT3sERUqpy4fUe47GbLKuXrTYukNXWkyLFTYbq5SuI0r(3uflSCYe9JNyjCXPOkHEqdOgDKbILHggYzJnHEqdOgDKbILHEl5Qyzq53XAK2ixsQ4OwjyuKeGb9Jn2ojTXJBHY8S4M0ZOG2BjVvxOhm8cxc8DWGQ8nX0ddsRUqpy4fUe47GbLKuXrTIKPyJgdRGv(1kxsQ4OMAjPnYlNqj1OGzrOh0aQrhzGyb0LmYvLFhRrAJCjPIJALGrrsag0pvNK24XTqzEwCt6neO92wDHEWWlCjW3bdkjPIJAfjtXgngwbR8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPT6c9GHx4sGVdgussfh1rQymScw5xRCjPIJAQLK2iVCcLuWdqfl0iMaXJZLKkoQnJhm5jYiqVyuYElBSniwOHb0f)4K(kHIRk)owJ0g5ssfh1wsYe(lYjVvxOhm8cxc8DWGYXZct9HmMy5mgwbZsI1elwIYezJTbDqkPq3MCvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsARUqpy4fUe47GbLKuXrndSuGtSymScw5xRC6eLKkLd628ef6Pk)owJ0g5ssfh1wsYe(lvSWYjt0pUWyoHvivoy4Qe6bnGA0rgiwgAWjNn2e6bnGA0rgiwg6TK3Ql0dgEHlb(oyqjjvCuZalf4elgdRGv(1kNorjPs5GUnprHEQozI(XfgZjScPYbdxLqpObuJoYaXYqdtRUqpy4fUe47GbLKuXrnYU5mkWWngwbR8RvUKuXrn1ssBKxoHs6qk)ALljvCutTK0g5mc76YjusB1f6bdVWLaFhmOKKkoQr2nNrbgUXWkyLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjvLzIg02uaozCjPIJAfjtXgB1FZB6vOhm8cxc8DWGcneu5GHBm0pmZV5PHvWmIlCt6zuWd(Bng6hM5380qggeakhcMSw9w938MEjHfwWEPYK(NYbdV07dMyVmHbeOxOFrVNf2RaaeEVx0llwHjw)Z5lY7f60eLc2lwRqkeD6lER(BEtVc9GHx4uzs)t5GHxaBqsOOmrJDHbbBjgqDyIocyCycUGNXgK5hbtMXWkydscfLjYTedOomrhbapavMjAqBtb4KXrdbvoy4Qgel53XAK2iVanTcxxUizyJT87ynsBKFiJzKYu)iPj5T6V5n9k0dgEHtLj9pLdgE5DWGYGKqrzIg7cdc2smG6WeDeW4WeCbpJniZpcMmJHvWgKekktKBjgqDyIocaEaQu(1kxsQ4O2mEWKdepUkAetG4X5ssfh1MXdM8ezeOxuXs(DSgPnYlqtRW1Llsg2yl)owJ0g5hYygPm1psAsER(BEtVc9GHx4uzs)t5GHxEhmOmijuuMOXUWGGRqxMALF6ghMGl4zSbz(rWKzmScw5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusvniLFTYZ)e1rvFwjIf(3uvfABD6ezeOxgcmlSWiUyepc9GHZLKkoQvMs540OCKpWe6bdNljvCuRmLYXr2r6)q9bzqYB1FZB61icEwy2R0B9pNV6TCcLueOxljzc)vVr2l07fzhP)d7nf3g79bEw9Y6Grrsag0Vw938MEf6bdVWPYK(NYbdV8oyqzqsOOmrJDHbbJmMXdMiGwrYuSrJdtWf8m2Gm)iyLFTYLKkoQTKKj8x8YjusnkyYElBSXs(DSgPnYLKkoQvcgfjbyq)uDsAJh3cL5zXnP3qG2BjVv)nVPxHEWWlCQmP)PCWWlVdgugKekkt0yxyqWtPCAXu)lOXayv(Zd8amombxWZyyfSYVw5ssfh1MXdM8VPkwmijuuMiFkLtlM6Fbbpa2y7GmOrbBqsOOmr(ukNwm1)c(ozVLCJniZpc(GmyR(BEtVdwsfh7DyZaaA)QxBObS0R0RbjHIYe7vyIVF9g1EPaPX9Q8VEFqqMZE)fSxP36uUEXYbzKdgEVwyI8EjHf2BbYq71mddqaeO3ezeOx0i7Mi9qGEr2ntSuGH3lqGLE9469jss79bNZERr2Rzgaq7x9c8XEVO3Zc7v5NL7vVUC)e7nQ9EwyVuGK3Q)M30Rqpy4fovM0)uoy4L3bdkdscfLjASlmiySCqg5qaTyQPrmbIh34WeCbpJniZpcMfAetG4X5ssfh1MXdMCGFkhm8bglKb6YYa4da0gy0Wb(WJljvCuBMba0(fpfNuYjNCqxwoidc6AqsOOmr(ukNwm1)csER(BEtVc9GHx4uzs)t5GHxEhmOmijuuMOXUWGGpidQ)(bNAX04WeCbpJHvW0Wb(WJljvCuBMba0(LXgK5hbtJycepoxsQ4O2mEWKNiJa9Igz3ePhc0Q)M30Rqpy4fovM0)uoy4L3bdkdscfLjASlmi4dYG6VFWPwmnombxWZyyf8GOHd8HhxsQ4O2mdaO9lJniZpcMgXeiECUKuXrTz8Gjprgb6Lw938MEnsrqMZEbWP8Q3bBy79B27f9sYbuqAV1i7LeXnWB1FZB6vOhm8cNkt6Fkhm8Y7GbLbjHIYen2fge8bzq93p4ulMghMGze2n2Gm)iyAetG4X5x8Pw6OQpluZi2qEImc0lgdRGzHgXeiEC(fFQLoQ6Zc1mInKNiJa9cORbjHIYe5hKb1F)GtTys(qKCaT6V5n9ocDk2RrWx5vVWsVLp1QxPxZ4bZ6F27LqNu86TgzVgXRxjuCJ79bbzo7TCqkP9ErVNf279e9Ya9)H9sFrNyVF)GZEFWETXRxPxlOTvVOhFBREtXjT3O2Rzgaq7xT6V5n9k0dgEHtLj9pLdgE5DWGYGKqrzIg7cdc(GmO(7hCQftJdtWmc7gBqMFe8LqNu84L4pN4Dq3wNFLxCAetG4X5jYiqVymScMgoWhECjPIJAZmaG2Vurdh4dpUKuXrTzgaq7x8uCsh6TQqqNp00eb4L4pN4Dq3wNFLxQOHb0f)4K(kHIRk)owJ0g5ssfh1wsYe(Rw938MEnsrqMZEbWP8Qxse3aV3VzVx0ljhqbP9wJS3bByB1FZB6vOhm8cNkt6Fkhm8Y7GbLbjHIYen2fgeSvmbGUT(IJX4WeCbpJniZpcMgXeiEC(fFQLoQ6Zc1mInKNOa8sLbjHIYe5hKb1F)GtTyoejhqR(BEtVgbcau8R3rtjjTxGal96X1lKHbbGYHZx9A(VE)M9EwyVg(thtrboH3REbqLFT2Bj6fE9sfVxfSxayTcP)517f9calum9Epl569bbjXELR3Zc71ibMXz1RH)0XuuGt49Q3YjusB1FZB6vOhm8cNkt6Fkhm8Y7GbLbjHIYen2fge8a5VC6Fbb0ftjj14WeCbpJniZpcMfZenOTPaCY4Paaf)0ftjjLn2mt0G2McWjjpfaO4NUykjPSXMzIg02uaoOXtbak(PlMssk5Qe6bdNNcau8txmLKu(bzqDb6uCiBkaNryFGnmT6V5n9AelH2qxM9oczgEVulKskc0laQ8RvEkaqXpDXuss1g(thtrboH3loq84g3RY)69SKRxGaloixVprsAVpwO37zH9kaaH3RyAoHyPxJGrJ4VxOxoXV5lER(BEtVc9GHx4uzs)t5GHxEhmOmijuuMOXUWGGhi)Lt)liGUykjPghMGl4zSbz(rWSyMObTnfGtgpfaO4NUykjPSXMzIg02uaoj5Paaf)0ftjjLn2mt0G2McWbnEkaqXpDXussjxfaQ8RvEkaqXpDXuss1g(thtrboH3loq84T6V5n9k0dgEHtLj9pLdgE5DWGYGKqrzIg7cdco(xbcG6OQPrmbIhVyCycUGNXgK5hbR8RvUKuXrTz8GjhiECvk)ALNFh1rvBgpyYbIhxfaQ8Rv(fFQLoQ6Zc1mInKdepUQbzqsOOmr(a5VC6Fbb0ftjjvfaQ8RvEkaqXpDXuss1g(thtrboH3loq84T6V5n9k0dgEHtLj9pLdgE5DWGYGKqrzIg7cdcUCcLuTLKmH)Y4WeCbpJniZpco)owJ0g5ssfh1wsYe(lvSWcnmGU4hN0xjuCv0iMaXJZtbak(PlMsskprgb6LHmijuuMi3ssMWFPlNqjvFqgKCYB1B1FtVdBcJeEqJeyV)c0T71oHL5REHuiDI9(apREftEVdefSx417d8S69IJP34SW8bwqERUqpy4fonIjq84fW1mkN2ddIXWk487ynsBKBNWY8LgsH0jQIgXeiECUKuXrTz8Gjprgb6fJcAdqfnIjq848l(ulDu1NfQzeBiprb4Lkwu(1kxsQ4OMAjPnYlNqjDiWgKekktKFXXOze21uljTXIkwy5Kj6hp)oQJQ2mEWufnIjq84887OoQAZ4btEImc0ldb2McOIgXeiECUKuXrTz8Gjprgb6fJAqsOOmr(fhJMryxdGt5LUgPwmjNn2yzqNmr)453rDu1MXdMQOrmbIhNljvCuBgpyYtKrGEXOgKekktKFXXOze21a4uEPRrQftYzJnAetG4X5ssfh1MXdM8ezeOxgcSnfGCYB1f6bdVWPrmbIhV8oyqvZOCApmigdRGZVJ1iTrUDclZxAifsNOkAetG4X5ssfh1MXdM8efGxQyzqNmr)4OpH2wh6iaBSXYjt0po6tOT1HocOIrCHBspJcEGoaYjxflSqJycepo)Ip1shv9zHAgXgYtKrGEXOKnavk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsk5SXgl0iMaXJZV4tT0rvFwOMrSH8ezeOxapavk)ALljvCutTK0g5LtOKcEaKtUkLFTYZVJ6OQnJhm5aXJRIrCHBspJc2GKqrzICXuZaDiZNrZiUOnPxRUqpy4fonIjq84L3bdQAgLtjMNXWk487ynsBKdaluO5e6s(stdggXburJycepox5xRAayHcnNqxYxAAWWioaprb4LkLFTYbGfk0CcDjFPPbdJ4a6AgLJdepUkwu(1kxsQ4O2mEWKdepUkLFTYZVJ6OQnJhm5aXJRcav(1k)Ip1shv9zHAgXgYbIhNCv0iMaXJZV4tT0rvFwOMrSH8ezeOxapavSO8RvUKuXrn1ssBKxoHs6qGnijuuMi)IJrZiSRPwsAJfvSWYjt0pE(DuhvTz8GPkAetG4X553rDu1MXdM8ezeOxgcSnfqfnIjq84CjPIJAZ4btEImc0lg1GKqrzI8lognJWUgaNYlDnsTysoBSXYGozI(XZVJ6OQnJhmvrJycepoxsQ4O2mEWKNiJa9IrnijuuMi)IJrZiSRbWP8sxJulMKZgB0iMaXJZLKkoQnJhm5jYiqVmeyBka5K3Ql0dgEHtJycepE5DWGQctuRmLYzmSco)owJ0g5aWcfAoHUKV00GHrCav0iMaXJZv(1QgawOqZj0L8LMgmmIdWtuaEPs5xRCayHcnNqxYxAAWWioGUctKdepUkZenOTPaCY41mkNsmVw9307WkWS3bEqIEFGNvVd2W2lS2l8aP0lnyGUDVFZElr48EncR9cVEFGZzVkyV)cc07d8S6LeXnWnUxQuUEHxVLj026MV6vbRrIT6c9GHx40iMaXJxEhmOyGzgzrhv9fjd6NXWk4bLFhRrAJ8c00kCD5IKrfnIjq848l(ulDu1NfQzeBiprgb6LHaBKbDzb0gyf80kH)l8dIjjhC9WysjxfnIjq84CjPIJAZ4btEImc0ldbMSba6YcOnWk4Pvc)x4hetso46HXKsERUqpy4fonIjq84L3bdkgyMrw0rvFrYG(zmSco)owJ0g5fOPv46YfjJkLFTYlqtRW1Llsg(3ufnIjq848l(ulDu1NfQzeBiprgb6LHaBKbDzb0gyf80kH)l8dIjjhC9WysjxfnIjq84CjPIJAZ4btEImc0ldbMSba6YcOnWk4Pvc)x4hetso46HXKsERUqpy4fonIjq84L3bdQ6elw0uQNXWkydscfLjYJ)vGaOoQAAetG4XlQyPe)Pc0b4gIPCWjQlX0a6hBSvI)ub6aCZF5(tuJ538GHtER(B6DWMpYRsV)c2lakNLsKo27d8S6vm59Aew79IJPxyP3efGx9kLEFW504EzesXEl)e79IEPs56fE9QG1iXEV4y4T6c9GHx40iMaXJxEhmOaq5SuI0rJHvWdk)owJ0g5fOPv46YfjJkAetG4X5x8Pw6OQpluZi2qEImc0ldbMS3QIgXeiECUKuXrTz8Gjprgb6LHatgOVvxOhm8cNgXeiE8Y7GbfakNLsKoAmSco)owJ0g5fOPv46YfjJkZenOTPaCY4OHGkhm8wDHEWWlCAetG4XlVdguaOCwkr6OXWkyAetG4X5ssfh1MXdM8efGxQyzqNmr)4OpH2wh6iaBSXYjt0po6tOT1HocOIrCHBspJcEGoaYjxflSqJycepo)Ip1shv9zHAgXgYtKrGEXOKnavk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsk5SXgl0iMaXJZV4tT0rvFwOMrSH8efGxQu(1kxsQ4OMAjPnYlNqjf8aiNCvk)ALNFh1rvBgpyYbIhxfJ4c3KEgfSbjHIYe5IPMb6qMpJMrCrBsVw9307arb7TykjP9cR9EXX0R4a9kM9kj2B49sb6vCGEFchKRxfS3VzV1i7DgUnM9EwI37zH9YiS3laoLxg3lJqk0T7T8tS3hSxlXa2RC9orPC9EprVssfh7LAjPnw6vCGEpl569IJP3hP4GC9oq(lxV)ccWB1f6bdVWPrmbIhV8oyqLcau8txmLKuJHvW0iMaXJZV4tT0rvFwOMrSH8ezeOxmQbjHIYe5zrZiSRbWP8sxJuFXXOIgXeiECUKuXrTz8Gjprgb6fJAqsOOmrEw0mc7AaCkV01i1IPkwozI(XZVJ6OQnJhmvXcnIjq84887OoQAZ4btEImc0ldHSJ0)H6dYGSXgnIjq84887OoQAZ4btEImc0lg1GKqrzI8SOze21a4uEPRrQZWKC2yBqNmr)453rDu1MXdMKRs5xRCjPIJAQLK2iVCcLuJssvaOYVw5x8Pw6OQpluZi2qoq84Qu(1kp)oQJQ2mEWKdepUkLFTYLKkoQnJhm5aXJ3Q)MEhikyVftjjT3h4z1Ry27Jf69AgLcuzI8EncR9EXX0lS0BIcWRELsVp4CACVmcPyVLFI9ErVuPC9cVEvWAKyVxCm8wDHEWWlCAetG4XlVdguPaaf)0ftjj1yyfmnIjq848l(ulDu1NfQzeBiprgb6LHq2r6)q9bzqvk)ALljvCutTK0g5LtOKoeydscfLjYV4y0mc7AQLK2yrfnIjq84CjPIJAZ4btEImc0ldXcYos)hQpid(Uqpy48l(ulDu1NfQzeBihzhP)d1hKbjVvxOhm8cNgXeiE8Y7GbvkaqXpDXussngwbtJycepoxsQ4O2mEWKNiJa9Yqi7i9FO(GmOkwyzqNmr)4OpH2wh6iaBSXYjt0po6tOT1HocOIrCHBspJcEGoaYjxflSqJycepo)Ip1shv9zHAgXgYtKrGEXOgKekktKlMAgHDnaoLx6AK6logvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsk5SXgl0iMaXJZV4tT0rvFwOMrSH8ezeOxapavk)ALljvCutTK0g5LtOKcEaKtUkLFTYZVJ6OQnJhm5aXJRIrCHBspJc2GKqrzICXuZaDiZNrZiUOnPh5T6c9GHx40iMaXJxEhmO(fudpKXyxyqWL4pN4Dq3wNFLxgdRGzzq53XAK2iVanTcxxUizyJnLFTYlqtRW1Llsg(3KCvk)ALljvCutTK0g5LtOKoeydscfLjYV4y0mc7AQLK2yrfnIjq84CjPIJAZ4btEImc0ldbgzhP)d1hKbvXiUWnPNrnijuuMixm1mqhY8z0mIlAt6Ps5xR887OoQAZ4btoq84T6c9GHx40iMaXJxEhmOqdbvoy4gdRGZVJ1iTrEbAAfUUCrYOIgXeiEC(fFQLoQ6Zc1mInKNiJa9YqGzrOhmCoAiOYbdNJSJ0)H6dYGVtgOrERUqpy4fonIjq84L3bdQ87OoQAZ4btJHvWf80kH)l8dIjjhCnjnPQOHb0f)4gq)SELQu(1kxsQ4O2mEWKdepUkAetG4X5x8Pw6OQpluZi2qEImc0ldbgzhP)d1hKbvrJycepoxsQ4O2mEWKNiJa9IrjBaT6c9GHx40iMaXJxEhmOU4tT0rvFwOMrSHgdRGl4Pvc)x4hetso4AsAsvrddOl(XnG(z9kvzMObTnfGtgp)oQJQ2mEWSvxOhm8cNgXeiE8Y7Gb1fFQLoQ6Zc1mIn0yyfCbpTs4)c)GysYbxtstQkAyaDXpUb0pRxPkAetG4X5ssfh1MXdM8ezeOxgcmYos)hQpid2Ql0dgEHtJycepE5DWGssQ4O2mEW0yyfSzIg02uaoz8l(ulDu1NfQzeByRUqpy4fonIjq84L3bdQl(ulDu1NfQzeBOXWkywgubpTs4)c)GysYbxtstkBSniAyaDXpUb0pRxj5Qyzq53XAK2iVanTcxxUizyJnLFTYlqtRW1Llsg(3KCvk)ALljvCutTK0g5LtOKoeydscfLjYV4y0mc7AQLK2yrfnIjq84CjPIJAZ4btEImc0ldbgzhP)d1hKbvXiUWnPNrnijuuMixm1mqhY8z0mIlAt6Ps5xR887OoQAZ4btoq84T6c9GHx40iMaXJxEhmOU4tT0rvFwOMrSHgdRGzzqf80kH)l8dIjjhCnjnPSX2GOHb0f)4gq)SELKRs5xRCjPIJAQLK2iVCcL0HaBqsOOmr(fhJMryxtTK0glQozI(XZVJ6OQnJhmvrJycepop)oQJQ2mEWKNiJa9YqGr2r6)q9bzqvgKekktKFqgu)9do1IPrnijuuMi)IJrZiSRbWP8sxJulMT6c9GHx40iMaXJxEhmOU4tT0rvFwOMrSHgdRGzzqf80kH)l8dIjjhCnjnPSX2GOHb0f)4gq)SELKRs5xRCjPIJAQLK2iVCcL0HaBqsOOmr(fhJMryxtTK0glQyzqNmr)453rDu1MXdMSXgnIjq84887OoQAZ4btEImc0lg1GKqrzI8lognJWUgaNYlDnsDgMKRYGKqrzI8dYG6VFWPwmnQbjHIYe5xCmAgHDnaoLx6AKAXSvxOhm8cNgXeiE8Y7Gbv(DuhvTz8GPXWkywgubpTs4)c)GysYbxtstkBSniAyaDXpUb0pRxj5Qu(1kxsQ4O2mEWKdepUkwOrmbIhNFXNAPJQ(SqnJyd5jYiqVyudscfLjYZWuZiSRbWP8sxJuFXXWgB0iMaXJZLKkoQnJhm5jYiqVmeydscfLjYV4y0mc7AaCkV01i1Ij5Qu(1kxsQ4OMAjPnYlNqjfSYVw5ssfh1uljTroJWUUCcLuv0iMaXJZLKkoQnJhm5jYiqVyuYgGkAetG4X5x8Pw6OQpluZi2qEImc0lgLSb0Ql0dgEHtJycepE5DWGQybRh0T1MXdMgdRGnijuuMip(xbcG6OQPrmbIhV0Q)MEhikyVMbtVx0Bb05JOrcSxX7fz)sPxrPxO37zH96i7xV0iMaXJ37d0bIhJ797tSu6L0xju8Epl07n85REb(j0T7vsQ4yVMXdM9c8XEVOxR4PxgXLET(UD(Q3uaGIF9wmLK0EHLwDHEWWlCAetG4XlVdguMjwqNI6OQzGoGXWk4tMOF887OoQAZ4btvk)ALljvCuBgpyY)MQu(1kp)oQJQ2mEWKNiJa9Yq2uaoJWERUqpy4fonIjq84L3bdkZelOtrDu1mqhWyyfmaQ8Rv(fFQLoQ6Zc1mInK)nvbGk)ALFXNAPJQ(SqnJyd5jYiqVmKqpy4CjPIJAgyPaNyHJSJ0)H6dYGQgenmGU4hN0xju8wDHEWWlCAetG4XlVdguMjwqNI6OQzGoGXWkyLFTYZVJ6OQnJhm5Ftvk)ALNFh1rvBgpyYtKrGEziBkaNryxfnIjq84C0qqLdgoprb4LkAetG4X5x8Pw6OQpluZi2qEImc0lQgenmGU4hN0xju8w9wDHEWWl8k0LPw5NoyjPIJAgyPaNyXyyfSYVw50jkjvkh0T5jk0ZyQLaDWK1Ql0dgEHxHUm1k)0FhmOKKkoQvMs5A1f6bdVWRqxMALF6Vdgussfh1ksMIn2Q3Q)MEnsTqV387o0T7fHNfM9EwyVJJ9gzVKWiT3jAJoGKqSyCVpyVpIF9ErVgrgIEvWAKyVNf2ljIBGdQbBy79b6aXdV3bIc2l86vk9wIW7vk9AeedBVwsP3k0HfleO34N9(GGya7TyI(1B8ZEPwsAJLwDHEWWl8kSybDBDyIoMGrdbvoy4gdRGzj)owJ0g5hYygPm1psAYgBSKFhRrAJ8c00kCD5IKr1GmijuuMi3mrZ)CQrdbyYiNCvSO8RvE(DuhvTz8GjhiEC2yZmrdABkaNmUKuXrTIKPyJKRIgXeiECE(DuhvTz8Gjprgb6Lw930RryT3heedyVvOdlwiqVXp7LgXeiE8EFGoq8u6vCGElMOF9g)SxQLK2yX4EntyKWdAKa71iYq0ByaZErdy(6SGUDV4SGT6c9GHx4vyXc626WeDmFhmOqdbvoy4gdRGpzI(XZVJ6OQnJhmvrJycepop)oQJQ2mEWKNiJa9IkAetG4X5ssfh1MXdM8ezeOxuP8RvUKuXrTz8GjhiECvk)ALNFh1rvBgpyYbIhxLzIg02uaozCjPIJAfjtXgB1f6bdVWRWIf0T1Hj6y(oyqvHjQvMs5mgwbNFhRrAJCayHcnNqxYxAAWWioGkLFTYbGfk0CcDjFPPbdJ4a6AgLJ)nB1f6bdVWRWIf0T1Hj6y(oyqvZOCApmigdRGZVJ1iTrUDclZxAifsNOkgXfUj9mQr(TT6c9GHx4vyXc626WeDmFhmOKKkoQzGLcCIfJHvW53XAK2ixsQ4O2ssMWFPs5xRCjPIJAljzc)fVCcL0Hu(1kxsQ4O2ssMWFXze21LtOKQIfwu(1kxsQ4O2mEWKdepUkAetG4X5ssfh1MXdM8efGxKZgBaOYVw5x8Pw6OQpluZi2q(3KCJPwc0btwRUqpy4fEfwSGUTomrhZ3bdkauolLiD0yyfmnCGp842W6PJQ(Sq9esTA1f6bdVWRWIf0T1Hj6y(oyqLFh1rvBgpyAmSco)owJ0g5fOPv46YfjtRUqpy4fEfwSGUTomrhZ3bdkjPIJ6ivmgwbtJycepop)oQJQ2mEWKNOa8QvxOhm8cVclwq3whMOJ57GbLKuXrTYukNXWkyAetG4X553rDu1MXdM8efGxQu(1kxsQ4OMAjPnYlNqjDiLFTYLKkoQPwsAJCgHDD5ekPT6c9GHx4vyXc626WeDmFhmOyGzgzrhv9fjd6NXWk4dYGgf8BFNfYgyf80kH)l8dIjjhC9WysjVvxOhm8cVclwq3whMOJ57Gb1VGA4Hmg7cdcMjcFcpTzclmgdRGpidAuqFRUqpy4fEfwSGUTomrhZ3bdQ87OoQAZ4bZw930RryT3heKe7vUEze27TCcL0sVrT3Hp8EfhO3hSxlXa6GC9(liqVd8Ge9(cpJ79xWELElNqjT3l61mrdOF9Y8DQf0T797tSu6n)UdD7EplSxJ4KKj8x9orB0bK8vRUqpy4fEfwSGUTomrhZ3bdkjPIJAgyPaNyXyyfSYVw50jkjvkh0T5jk0tLYVw50jkjvkh0T5LtOKcw5xRC6eLKkLd62CgHDD5ekPQOHb0f)4gq)SELQOrmbIhNZaZmYIoQ6lsg0pEIcWlvdYGKqrzICKXmEWeb0ksMInQIgXeiECUKuXrTz8Gjprb4vR(B6vnrYiZ5REFWEnfy2RzCWW79xWEFGNvVd2WACVk)Rx417dCo7DkLR3z429IE8TT6TgzVkXz17zH9AeedBVId07GnS9(aDG4P073NyP0B(Dh629EwyVJJ9gzVKWiT3jAJoGKqS0Ql0dgEHxHflOBRdt0X8DWGYmoy4gdRGhu(DSgPnYpKXmszQFK0ufldk)owJ0g5fOPv46YfjdBSXIbjHIYe5MjA(NtnAiatMkLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjLCYB1f6bdVWRWIf0T1Hj6y(oyqbGYzPePJgdRGv(1kp)oQJQ2mEWKdepoBSzMObTnfGtgxsQ4OwrYuSXwDHEWWl8kSybDBDyIoMVdguPaaf)0ftjj1yyfSYVw553rDu1MXdMCG4XzJnZenOTPaCY4ssfh1ksMIn2Ql0dgEHxHflOBRdt0X8DWGIbMzKfDu1xKmOFgdRGv(1kp)oQJQ2mEWKNiJa9YqSa6FNKdS87ynsBKxGMwHRlxKmK3Q)MEnsTqV387o0T79SWEnItsMWF17eTrhqYxg37VG9oydBVkynsSxse3aV3l6f4Zy2R0B9pNV6TCcLueOxfjtXgB1f6bdVWRWIf0T1Hj6y(oyqjjvCuBgpyAmSc2GKqrzICKXmEWeb0ksMInQs5xR887OoQAZ4bt(3uflmIlCt6nelK8TVZczdyGrddOl(Xj9vcfNCYzJnLFTYPtusQuoOBZlNqjfSYVw50jkjvkh0T5mc76YjusjVvxOhm8cVclwq3whMOJ57GbLKuXrTIKPyJgdRGnijuuMihzmJhmraTIKPyJQu(1kxsQ4OMAjPnYlNqjfSYVw5ssfh1uljTroJWUUCcLuvk)ALljvCuBgpyY)MT6c9GHx4vyXc626WeDmFhmO(fudpKXyxyqWL4pN4Dq3wNFLxgdRGv(1kp)oQJQ2mEWKdepoBSzMObTnfGtgxsQ4OwrYuSr2yZmrdABkaNmEkaqXpDXusszJnwmt0G2McWjJdGYzPePJQgu(DSgPnYlqtRW1LlsgYB1f6bdVWRWIf0T1Hj6y(oyqDXNAPJQ(SqnJydngwbR8RvE(DuhvTz8GjhiEC2yZmrdABkaNmUKuXrTIKPyJSXMzIg02uaoz8uaGIF6IPKKYgBSyMObTnfGtghaLZsjshvnO87ynsBKxGMwHRlxKmK3Ql0dgEHxHflOBRdt0X8DWGssQ4O2mEW0yyfSzIg02uaoz8l(ulDu1NfQzeByR(B6DGOG9oSXaV3l6Ta68r0ib2R49ISFP07GLuXXEz9ukxVa)e629EwyVKiUboOgSHT3hOdep9(9jwk9MF3HUDVdwsfh71iIAf8EncR9oyjvCSxJiQv0lS07jt0peW4EFWEPIdY17VG9oSXaV3h4zb9EplSxse3ahud2W27d0bINE)(elLEFWEH(Hz(nVEplS3bBG3l1sChNg3Bj69bbzo7TigWEHhVvxOhm8cVclwq3whMOJ57GbLzIf0POoQAgOdymScEqNmr)4ssfh1i1kubGk)ALFXNAPJQ(SqnJyd5FtvaOYVw5x8Pw6OQpluZi2qEImc0ldbMfHEWW5ssfh1ktPCCKDK(puFqgCGP8RvUzIf0POoQAgOdWze21LtOKsER(B61iS27Wgd8ETKIdY1RcIEV)cc0lWpHUDVNf2ljIBG37d0bIhJ79bbzo79xWEHxVx0Bb05JOrcSxX7fz)sP3blPIJ9Y6PuUEHEVNf2RrqmSGAWg2EFGoq8WB1f6bdVWRWIf0T1Hj6y(oyqzMybDkQJQMb6agdRGv(1kxsQ4O2mEWK)nvP8RvE(DuhvTz8Gjprgb6LHaZIqpy4CjPIJALPuooYos)hQpidoWu(1k3mXc6uuhvnd0b4mc76YjusjVvxOhm8cVclwq3whMOJ57GbLKuXrTYukNXWkyG44Paaf)0ftjjLNiJa9IrFlBSbGk)ALNcau8txmLKuTH)0XuuGt49IxoHsQrhqR(B61if79r8R3l6Lrif7T8tS3hSxlXa2l6X32QxgXLERr27zH9I(btS3bBy79b6aXJX9IgqVxyT3ZcteKsVLdoN9EqgS3ezeOdD7EdVxJGyy59AeEGu6n85REvW7WS3l6v5NEVx0RrcmJEfhOxJidrVWAV53DOB37zH9oo2BK9scJ0ENOn6ascXcVvxOhm8cVclwq3whMOJ57GbLKuXrTIKPyJgdRGPrmbIhNljvCuBgpyYtuaEPIrCHBsVHyzygW7Sq2agy0Wa6IFCsFLqXjNCvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsQkwgu(DSgPnYlqtRW1Llsg2yZGKqrzICZen)ZPgneGjJCvdk)owJ0g5hYygPm1psAQAq53XAK2ixsQ4O2ssMWF1Q)MEzTKPyJ9wSI)eOxpUEvWE)feOx569SWErhO3O27GnS9cR9AeziOYbdVxyP3efGx9kLEbYW0e629sTK0gl9(aNZEzesXEHxVNqk27mCBm79IEv(P37zLX32Q3ezeOdD7EzexA1f6bdVWRWIf0T1Hj6y(oyqjjvCuRizk2OXWkyLFTYLKkoQnJhm5Ftvk)ALljvCuBgpyYtKrGEziW2uav0iMaXJZrdbvoy48ezeOxA1FtVSwYuSXElwXFc0RmFKxLEvWEplS3PuUEPs56f69EwyVgbXW27d0bINELsVKiUbEVpW5S3elxKyVNf2l1ssBS0BXe9RvxOhm8cVclwq3whMOJ57GbLKuXrTIKPyJgdRGv(1kp)oQJQ2mEWK)nvP8RvUKuXrTz8GjhiECvk)ALNFh1rvBgpyYtKrGEziW2uavdk)owJ0g5ssfh1wsYe(RwDHEWWl8kSybDBDyIoMVdgussfh1mWsboXIXWkyau5xR8l(ulDu1NfQzeBi)BQ6Kj6hxsQ4OgPwHkwu(1khaLZsjsh5aXJZgBc9Ggqn6idelGjJCvaOYVw5x8Pw6OQpluZi2qEImc0lgvOhmCUKuXrndSuGtSWr2r6)q9bzqJPwc0btMXOKZxAQLaDnScw5xRC6eLKkLd62AQL4oo5aXJRIfLFTYLKkoQnJhm5Ft2yJLbDYe9JhgW0mEWebuXIYVw553rDu1MXdM8VjBSrJycepohneu5GHZtuaEro5K3Q)MEncR9(GGKyVgq)SELg3lKHbbGYHZx9(lyVdF49(yHEVuX0eb69IE9469rkh2Rzg0sV1my6DGhKOvxOhm8cVclwq3whMOJ57GbLKuXrndSuGtSymScMggqx8JBa9Z6vQs5xRC6eLKkLd628YjusbR8RvoDIssLYbDBoJWUUCcL0w93074j517VaD7Eh(W7DWg49(yHEVd2W2RLu6vbrV3FbbA1f6bdVWRWIf0T1Hj6y(oyqjjvCuZalf4elgdRGv(1kNorjPs5GUnprHEQOrmbIhNljvCuBgpyYtKrGErflk)ALNFh1rvBgpyY)MSXMYVw5ssfh1MXdM8Vj5gtTeOdMSwDHEWWl8kSybDBDyIoMVdgussfh1rQymScw5xRCjPIJAQLK2iVCcL0HaBqsOOmr(fhJMryxtTK0glT6c9GHx4vyXc626WeDmFhmOKKkoQvMs5mgwbR8RvE(DuhvTz8Gj)BYgBmIlCt6zuYEBRUqpy4fEfwSGUTomrhZ3bdk0qqLdgUXWkyLFTYZVJ6OQnJhm5aXJRs5xRCjPIJAZ4btoq84gd9dZ8BEAyfmJ4c3KEgf8G)wJH(Hz(npnKHbbGYHGjRvxOhm8cVclwq3whMOJ57GbLKuXrTIKPyJT6T6V5n9oq4LVPzKhc0lvCko1c9GHBeV71iYqqLdgEVpW5SxfSxxUFkZ5REvYGu07fw7Lgoa8GHx6vsSxg84T6V5n9k0dgEHBjjt4VatfNItTqpy4gdRGf6bdNJgcQCWW5ulXDCcDBvmIlCt6zuWg532Q)MEncR9oJNEdVxgXLEfhOxAetG4Xl9kj2lnyGUDVFtJ71o6vSqbOxXb6fneT6c9GHx4wsYe(R3bdk0qqLdgUXWkygXfUj9gcmOnavgKekktKh)RabqDu10iMaXJxuXYjt0pE(DuhvTz8GPkAetG4X553rDu1MXdM8ezeOxgISbqER(B61if79r8R3l6TCcL0ETKKj8x9w)Z5lEVKWc79xWEJAVKb67TCcL0sVwyI9cl9ErVcLgF)6TgzVNf27bPK27eRxVH37zH9sTe3XzVId07zH9Yalf4e7f69wNqBRJ3Ql0dgEHBjjt4VEhmOKKkoQzGLcCIfJHvWSyqsOOmrE5ekPAljzc)fBSDqgCiYga5Qu(1kxsQ4O2ssMWFXlNqjDiYa9gtTeOdMSw930RrQf69(lq3UxJigZxjkZEnILaU4u04EPs56v6TIp9ISFP0ldSuGtS07JfCI9(iWd629wJS3Zc7v5xR9kxVNf2B5K86nQ9EwyVvOT11Ql0dgEHBjjt4VEhmOKKkoQzGLcCIfJHvWiOZhAAIaCKX8vIYuhjGlofvDqgCiqBaQOrmbIhNJmMVsuM6ibCXPiprgb6fJsgOFWvniHEWW5iJ5ReLPosaxCkYbGfrzIaT6c9GHx4wsYe(R3bdQFb1Wdzm2fgeCj(ZjEh0T15x5LXWkyLFTYLKkoQnJhm5FtvNK24XbGLtCkoeyYgqRUqpy4fULKmH)6DWG6xqn8qgJDHbbxI)CI3bDBD(vEzmSc2GKqrzICKXmEWeb0ksMInQIgXeiEC(fFQLoQ6Zc1mInKNiJa9YqGr2r6)q9bzqv0iMaXJZLKkoQnJhm5jYiqVmeywq2r6)q9bzWbgjjx1jPnECay5eNIgLSb0Ql0dgEHBjjt4VEhmOsbak(PlMssQXWkydscfLjYrgZ4bteqRizk2OkAetG4X5x8Pw6OQpluZi2qEImc0ldbgzhP)d1hKbvrJycepoxsQ4O2mEWKNiJa9YqGzbzhP)d1hKbhyKKCvSmie05dnnraEj(ZjEh0T15x5fBSrdh4dpUKuXrTzgaq7x8uCsnk43YgBSCj0jfpEj(ZjEh0T15x5fNgXeiECEImc0lgLmYgGQtsB84aWYjofnkzdGC2yJLlHoP4XlXFoX7GUTo)kV40iMaXJZtKrGEziWi7i9FO(GmOQtsB84aWYjofhcmzdGCYB1f6bdVWTKKj8xVdgux8Pw6OQpluZi2qJHvWgKekktKpq(lN(xqaDXussvrJycepoxsQ4O2mEWKNiJa9YqGr2r6)q9bzqvSmie05dnnraEj(ZjEh0T15x5fBSrdh4dpUKuXrTzgaq7x8uCsnk43YgBSCj0jfpEj(ZjEh0T15x5fNgXeiECEImc0lgLmYgGQtsB84aWYjofnkzdGC2yJLlHoP4XlXFoX7GUTo)kV40iMaXJZtKrGEziWi7i9FO(GmOQtsB84aWYjofhcmzdGCYB1f6bdVWTKKj8xVdgussfh1MXdMgdRGnt0G2McWjJFXNAPJQ(SqnJydB1f6bdVWTKKj8xVdgu53rDu1MXdMgdRGnijuuMihzmJhmraTIKPyJQOrmbIhNNcau8txmLKuEImc0ldbgzhP)d1hKbvzqsOOmr(bzq93p4ulMgfmjhGkwgenCGp84ssfh1MzaaTFXgBdYGKqrzICz(iVk6YlNQPrmbIhVWgB0iMaXJZV4tT0rvFwOMrSH8ezeOxgcmli7i9FO(Gm4aJKKtERUqpy4fULKmH)6DWGkfaO4NUykjPgdRGnijuuMihzmJhmraTIKPyJQmt0G2McWjJNFh1rvBgpy2Ql0dgEHBjjt4VEhmOU4tT0rvFwOMrSHgdRGnijuuMiFG8xo9VGa6IPKKQAqgKekktKBftaOBRV4yA1FtVdefSxs6a9kjvCSxfjtXg7f69oyd77gbgXg2EdF(QxyTxwpJay(lxVId0RC9orPC9sYEh(Wl9AMbLIaT6c9GHx4wsYe(R3bdkjPIJAfjtXgngwbR8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQu(1kp)oQJQ2mEWK)nvP8RvUKuXrTz8Gj)BQs5xRCjPIJAljzc)fVCcLuJcMmqVkLFTYLKkoQnJhm5jYiqVmeyHEWW5ssfh1ksMInYr2r6)q9bzqvk)ALRmJay(lh)B2Q)MEhikyVK0b61iig2EHEVd2W2B4Zx9cR9Y6zeaZF56vCGEjzVdF4LEnZG2Ql0dgEHBjjt4VEhmOYVJ6OQnJhmngwbR8RvE(DuhvTz8GjhiECvk)ALRmJay(lh)BQIfdscfLjYpidQ)(bNAX0OG2ayJnAetG4X5Paaf)0ftjjLNiJa9IrjJKKRIfLFTYLKkoQTKKj8x8YjusnkyYElBSP8RvoDIssLYbDBE5ekPgfmzKRILbrdh4dpUKuXrTzgaq7xSX2GmijuuMixMpYRIU8YPAAetG4XlK3Ql0dgEHBjjt4VEhmOYVJ6OQnJhmngwbR8RvUKuXrTz8GjhiECvSyqsOOmr(bzq93p4ulMgf0gaBSrJycepopfaO4NUykjP8ezeOxmkzKKCvSmiA4aF4XLKkoQnZaaA)In2gKbjHIYe5Y8rEv0LxovtJycepEH8wDHEWWlCljzc)17GbvkaqXpDXussngwbBqsOOmroYygpyIaAfjtXgvXIYVw5ssfh1uljTrE5ekPgfmjzJnAetG4X5ssfh1rQWtuaErUkwg0jt0pE(DuhvTz8GjBSrJycepop)oQJQ2mEWKNiJa9IrFl5QOrmbIhNljvCuBgpyYtKrGErJSBI0dbmkyqBaQyzq0Wb(WJljvCuBMba0(fBSnidscfLjYL5J8QOlVCQMgXeiE8c5T6VPxJul07n)UdD7EnZaaA)Y4E)fS3loMEvE1l8k4S2l07nsam79IELj027fE9(apREfZwDHEWWlCljzc)17Gb1fFQLoQ6Zc1mIn0yyfSbjHIYe5hKb1F)GtTyo0BhGkdscfLjYpidQ)(bNAX0OG2auXYGqqNp00eb4L4pN4Dq3wNFLxSXgnCGp84ssfh1MzaaTFXtXj1OGFl5T6c9GHx4wsYe(R3bdkjPIJ6ivmgwbBqsOOmr(a5VC6Fbb0ftjjvLYVw5ssfh1uljTrE5ekPdP8RvUKuXrn1ssBKZiSRlNqjTv)nVPxJul079xGUDVgXjjt4qAVgruRW4EFf)EbIE9469r8R3l6f05JFS3blPIJ9YAjtXg7f4Nq3U3Zc7DWsQ4yVSEkLRxQuUw938MEf6bdVWTKKj8xVdgupc8mUGuWdGpGHXyyfmaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekPGzbav(1kpfaO4NUykjPAd)PJPOaNW7fNryxxoHskOlzKRk)owJ0g5wsYeoKQrQvy8e6OMcaMKVTvxOhm8c3ssMWF9oyqjjvCuRizk2OXWkyau5xR8uaGIF6IPKKQn8NoMIcCcVx8YjusbdGk)ALNcau8txmLKuTH)0XuuGt49IZiSRlNqjTvxOhm8c3ssMWF9oyqjjvCuRmLYzmSc2GKqrzI8bYF50)ccOlMsskBSXcaQ8RvEkaqXpDXuss1g(thtrboH3l(3ufaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekPdbGk)ALNcau8txmLKuTH)0XuuGt49IZiSRlNqjL8w9307arb7Lb6WEzTKPyJ9QG3dIEVPaaf)6TykjPLEH1E)oaM9YAwP3h4zf)RxaCkVGUDVgbcau8R3rtjjTxiakZ5RwDHEWWlCljzc)17GbLKuXrTIKPyJgdRGv(1kp)oQJQ2mEWK)nvP8RvUKuXrTz8GjhiECvk)ALRmJay(lh)BQIgXeiECEkaqXpDXuss5jYiqVmeyYgGkLFTYLKkoQTKKj8x8YjusnkyYa9T6VP3bIc2BKk9gEVuGE)(elLEfZEHLEPbd0T79B2BjcVvxOhm8c3ssMWF9oyqjjvCuhPIXWkyLFTYLKkoQPwsAJ8Yjushc0uzqsOOmr(bzq93p4ulMgLSbOIfAetG4X5x8Pw6OQpluZi2qEImc0lg9TSX2GOHd8HhxsQ4O2mdaO9lYB1f6bdVWTKKj8xVdgussfh1mWsboXIXWkyLFTYPtusQuoOBZtuONkLFTYLKkoQnJhm5FtJPwc0btwR(B61iS27d2RnE9Agpy2l0R)cm8Eb(j0T7D(lxVpiiZzVwIbSx0JVTvVws5WEVOxB86nQ1ELElxgUDVksMIn2lWpHUDVNf2BgMGsm79b6aXtRUqpy4fULKmH)6DWGssQ4OwrYuSrJHvWk)ALNFh1rvBgpyY)MQu(1kp)oQJQ2mEWKNiJa9YqGf6bdNljvCuZalf4elCKDK(puFqguLYVw5ssfh1MXdM8VPkLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjvLYVw5ssfh1wsYe(lE5ekPQu(1k3mEWud96VadN)nvP8RvUYmcG5VC8VzR(B61iS27d2RnE9Agpy2l0R)cm8Eb(j0T7D(lxVpiiZzVwIbSx0JVTvVws5WEVOxB86nQ1ELElxgUDVksMIn2lWpHUDVNf2BgMGsm79b6aXJX9wIEFqqMZEdF(Q3Fb7f94BB1RYukxPxOdpOmNV69IETXR3l6Tg)SxQLK2yPvxOhm8c3ssMWF9oyqjjvCuRmLYzmScw5xRCZelOtrDu1mqhG)nvXIYVw5ssfh1uljTrE5ekPdP8RvUKuXrn1ssBKZiSRlNqjLn2gelk)ALBgpyQHE9xGHZ)MQu(1kxzgbW8xo(3KCYvniwu(1kxsQ4OMAjPnYlNqjf8auP8RvUzIf0POoQAgOdWlNqjfmzK3Q)MEjHf2RcwUE)fS3O2RzW0lS07f9(lyVWR3l6f05dPKoF1RYhob6LAjPnw6f4Nq3UxXSxPEy27zHV61gVEb(mMiqVkV69SWETKKj8x9Qizk2yRUqpy4fULKmH)6DWGYmXc6uuhvnd0bmgwbR8RvUKuXrn1ssBKxoHs6qk)ALljvCutTK0g5mc76YjusvP8RvUKuXrTz8Gj)B2Q)MEnsXEFe)69IElNqjTxljzc)vV1)C(I3ljSWE)fS3O2lzG(ElNqjT0RfMyVWsVx0RqPX3VERr27zH9EqkP9oX61B49EwyVulXDC2R4a9EwyVmWsboXEHEV1j0264T6c9GHx4wsYe(R3bdkjPIJAgyPaNyXyyfSYVw5ssfh1wsYe(lE5ekPdrgO3yQLaDWKzm0pmZV5bMmJH(Hz(npT9muKjyYA1f6bdVWTKKj8xVdgussfh1ksMInAmScw5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusvzqsOOmroYygpyIaAfjtXgB1f6bdVWTKKj8xVdguOHGkhmCJHvWmIlCt6nezVTv)n9AeZNV69xWEvMs569IEv(WjqVuljTXsVWAVpyVYmrb4vVwIbS3sWG9wZGP3ivA1f6bdVWTKKj8xVdgussfh1ktPCgdRGv(1kxsQ4OMAjPnYlNqjvLYVw5ssfh1uljTrE5ekPdP8RvUKuXrn1ssBKZiSRlNqjTv)n9AeFW5S3h4z1RW073NyP0Ry2lS0lnyGUDVFZEfhO3heKe7Dgp9gEVmIlT6c9GHx4wsYe(R3bdkjPIJAgyPaNyXyyf8GyXGKqrzI8dYG6VFWPwmhcmzdqfJ4c3KEdbAdGCJPwc0btMXq)Wm)MhyYmg6hM53802ZqrMGjRv)n9oSzuHtS07d8S6Dgp9YiLdZxg3Rf02QxlPCOX9gzVkXz1lJ8QxpUETedyVOhFBREzex69IElFtZiVETINEzex6f6h6fObS3uaGIF9wmLK0EPI3RcACVLO3heK5S3Fb7TctSxLPuUEfhO3AgLtjMxVpwO37mE6n8EzexA1f6bdVWTKKj8xVdguvyIALPuUwDHEWWlCljzc)17GbvnJYPeZRvVvxOhm8cpmrhtWvyIALPuoJHvW53XAK2ihawOqZj0L8LMgmmIdOs5xRCayHcnNqxYxAAWWioGUMr54FZwDHEWWl8WeDmFhmOQzuoThgeJHvW53XAK2i3oHL5lnKcPtufJ4c3KEg1i)2wDHEWWl8WeDmFhmO(fudpKXyxyqWL4pN4Dq3wNFLxT6c9GHx4Hj6y(oyqbGYzPePJT6c9GHx4Hj6y(oyqLcau8txmLKuJHvWmIlCt6z0HzaT6c9GHx4Hj6y(oyqXaZmYIoQ6lsg0VwDHEWWl8WeDmFhmOkwW6bDBTz8GPXWkyLFTYLKkoQnJhm5aXJRIgXeiECUKuXrTz8Gjprgb6LwDHEWWl8WeDmFhmOKKkoQJuXyyfmnIjq84CjPIJAZ4btEIcWlvk)ALljvCutTK0g5LtOKoKYVw5ssfh1uljTroJWUUCcL0wDHEWWl8WeDmFhmOKKkoQvMs5mgwbtddOl(XnG(z9kvrJycepoNbMzKfDu1xKmOF8ezeOxm6GpmT6c9GHx4Hj6y(oyqDXNAPJQ(SqnJydB1f6bdVWdt0X8DWGssQ4O2mEWSvxOhm8cpmrhZ3bdQ87OoQAZ4btJHvWk)ALljvCuBgpyYbIhVv)n9oquWEh2yG37f9waD(iAKa7v8Er2Vu6DWsQ4yVSEkLRxGFcD7EplSxse3ahud2W27d0bINE)(elLEZV7q3U3blPIJ9AerTcEVgH1EhSKko2Rre1k6fw69Kj6hcyCVpyVuXb569xWEh2yG37d8SGEVNf2ljIBGdQbBy79b6aXtVFFILsVpyVq)Wm)MxVNf27GnW7LAjUJtJ7Te9(GGmN9wedyVWJ3Ql0dgEHhMOJ57GbLzIf0POoQAgOdymScEqNmr)4ssfh1i1kubGk)ALFXNAPJQ(SqnJyd5FtvaOYVw5x8Pw6OQpluZi2qEImc0ldbMfHEWW5ssfh1ktPCCKDK(puFqgCGP8RvUzIf0POoQAgOdWze21LtOKsER(B61iS27Wgd8ETKIdY1RcIEV)cc0lWpHUDVNf2ljIBG37d0bIhJ79bbzo79xWEHxVx0Bb05JOrcSxX7fz)sP3blPIJ9Y6PuUEHEVNf2RrqmSGAWg2EFGoq8WB1f6bdVWdt0X8DWGYmXc6uuhvnd0bmgwbR8RvUKuXrTz8Gj)BQs5xR887OoQAZ4btEImc0ldbMfHEWW5ssfh1ktPCCKDK(puFqgCGP8RvUzIf0POoQAgOdWze21LtOKsERUqpy4fEyIoMVdgussfh1ktPCgdRGbIJNcau8txmLKuEImc0lg9TSXgaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekPgDaT6VP3bB(iVk9YAjtXg7vUEplSx0b6nQ9oydBVpwO3B(Dh629EwyVdwsfh71iojzc)vVt0gDajF1Ql0dgEHhMOJ57GbLKuXrTIKPyJgdRGv(1kxsQ4O2mEWK)nvP8RvUKuXrTz8Gjprgb6LHSPaQYVJ1iTrUKuXrTLKmH)Qv)n9oyZh5vPxwlzk2yVY17zH9IoqVrT3Zc71iig2EFGoq807Jf69MF3HUDVNf27GLuXXEnItsMWF17eTrhqYxT6c9GHx4Hj6y(oyqjjvCuRizk2OXWkyLFTYZVJ6OQnJhm5Ftvk)ALljvCuBgpyYbIhxLYVw553rDu1MXdM8ezeOxgcSnfqv(DSgPnYLKkoQTKKj8xT6c9GHx4Hj6y(oyqjjvCuZalf4elgdRGbqLFTYV4tT0rvFwOMrSH8VPQtMOFCjPIJAKAfQyr5xRCauolLiDKdepoBSj0dAa1OJmqSaMmYvbGk)ALFXNAPJQ(SqnJyd5jYiqVyuHEWW5ssfh1mWsboXchzhP)d1hKbnMAjqhmzgJsoFPPwc01WkyLFTYPtusQuoOBRPwI74KdepUkwu(1kxsQ4O2mEWK)nzJnwg0jt0pEyatZ4bteqflk)ALNFh1rvBgpyY)MSXgnIjq84C0qqLdgoprb4f5KtERUqpy4fEyIoMVdgussfh1mWsboXIXWkyLFTYPtusQuoOBZlNqjfSYVw50jkjvkh0T5mc76YjusvrddOl(XnG(z9kB1f6bdVWdt0X8DWGssQ4OMbwkWjwmgwbR8RvoDIssLYbDBEIc9urJycepoxsQ4O2mEWKNiJa9Ikwu(1kp)oQJQ2mEWK)nzJnLFTYLKkoQnJhm5FtYnMAjqhmzT6c9GHx4Hj6y(oyqjjvCuhPIXWkyLFTYLKkoQPwsAJ8YjushcSbjHIYe5xCmAgHDn1ssBS0Ql0dgEHhMOJ57GbLKuXrTYukNXWkyLFTYZVJ6OQnJhm5Ft2yJrCHBspJs2BB1f6bdVWdt0X8DWGcneu5GHBmScw5xR887OoQAZ4btoq84Qu(1kxsQ4O2mEWKdepUXq)Wm)MNgwbZiUWnPNrbp4V1yOFyMFZtdzyqaOCiyYA1f6bdVWdt0X8DWGssQ4OwrYuSXw9w938MEf6bdVWZ4KdgoyQ4uCQf6bd3yyfSqpy4C0qqLdgoNAjUJtOBRIrCHBspJc2i)wvSmO87ynsBKxGMwHRlxKmSXMYVw5fOPv46YfjdVCcLuWk)ALxGMwHRlxKmCgHDD5ekPK3Q)MEhikyVOHOxyT3heKe7Dgp9gEVmIl9koqV0iMaXJx6vsSxrj(xVx0Rc273SvxOhm8cpJtoy4Vdgussfh1ksMInAmScUGNwj8FHFqmj5GRjPjvfnmGU4h3a6N1RufnIjq84887OoQAZ4btEImc0ldbgzhP)d1hKbvrJycepo)Ip1shv9zHAgXgYtKrGEziqtflk)ALljvCutTK0g5LtOKAudscfLjYV4y0mc7AQLK2yr1jt0pE(DuhvTz8GPkdscfLjYpidQ)(bNAX0OgKekktKFXXOze21a4uEPRrQftYB1f6bdVWZ4Kdg(7GbLKuXrTIKPyJgdRGzzqf80kH)l8dIjjhCnjnPSX2GOHb0f)4gq)SELKRIgXeiEC(fFQLoQ6Zc1mInKNOa8sflk)ALljvCutTK0g5LtOKAudscfLjYV4y0mc7AQLK2yrfnIjq84CjPIJAZ4btEImc0ldbgzhP)d1hKbvXiUWnPNrnijuuMixm1mqhY8z0mIlAt6Ps5xR887OoQAZ4btoq84K3Ql0dgEHNXjhm83bdkjPIJAfjtXgngwbZYGk4Pvc)x4hetso4AsAszJTbrddOl(XnG(z9kjxfnIjq848l(ulDu1NfQzeBiprb4Lkwu(1kxsQ4OMAjPnYlNqj1OgKekktKFXXOze21uljTXIQtMOF887OoQAZ4btv0iMaXJZZVJ6OQnJhm5jYiqVmeyKDK(puFqguLbjHIYe5hKb1F)GtTyAudscfLjYV4y0mc7AaCkV01i1Ij5T6c9GHx4zCYbd)DWGssQ4OwrYuSrJHvWSmOcEALW)f(bXKKdUMKMu2yBq0Wa6IFCdOFwVsYvrJycepo)Ip1shv9zHAgXgYtuaEPIfLFTYLKkoQPwsAJ8YjusnQbjHIYe5xCmAgHDn1ssBSOILbDYe9JNFh1rvBgpyYgB0iMaXJZZVJ6OQnJhm5jYiqVyudscfLjYV4y0mc7AaCkV01i1zysUkdscfLjYpidQ)(bNAX0OgKekktKFXXOze21a4uEPRrQftYB1f6bdVWZ4Kdg(7GbLKuXrTIKPyJgdRGbqLFTYtbak(PlMssQ2WF6ykkWj8EXlNqjfmaQ8RvEkaqXpDXuss1g(thtrboH3loJWUUCcLuvSO8RvUKuXrTz8GjhiEC2yt5xRCjPIJAZ4btEImc0ldb2McqUkwu(1kp)oQJQ2mEWKdepoBSP8RvE(DuhvTz8Gjprgb6LHaBtbiVvxOhm8cpJtoy4Vdgussfh1ktPCgdRGnijuuMiFG8xo9VGa6IPKKYgBSaGk)ALNcau8txmLKuTH)0XuuGt49I)nvbGk)ALNcau8txmLKuTH)0XuuGt49IxoHs6qaOYVw5Paaf)0ftjjvB4pDmff4eEV4mc76YjusjVvxOhm8cpJtoy4Vdgussfh1ktPCgdRGv(1k3mXc6uuhvnd0b4FtvaOYVw5x8Pw6OQpluZi2q(3ufaQ8Rv(fFQLoQ6Zc1mInKNiJa9YqGf6bdNljvCuRmLYXr2r6)q9bzWwDHEWWl8mo5GH)oyqjjvCuZalf4elgdRGbqLFTYV4tT0rvFwOMrSH8VPQtMOFCjPIJAKAfQyr5xRCauolLiDKdepoBSj0dAa1OJmqSaMmYvXcaQ8Rv(fFQLoQ6Zc1mInKNiJa9Irf6bdNljvCuZalf4elCKDK(puFqgKn2OrmbIhNBMybDkQJQMb6a8ezeOxyJnAyaDXpoPVsO4KBm1sGoyYmgLC(stTeORHvWk)ALtNOKuPCq3wtTe3XjhiECvSO8RvUKuXrTz8Gj)BYgBSmOtMOF8WaMMXdMiGkwu(1kp)oQJQ2mEWK)nzJnAetG4X5OHGkhmCEIcWlYjN8w9307WdV8zWEplSxKDtXbqGEnJd9dkZEv(1AVsrm79IE946DgfSxZ4q)GYSxZmOLwDHEWWl8mo5GH)oyqjjvCuZalf4elgdRGv(1kNorjPs5GUnprHEQu(1khz3uCaeqBgh6huM8VzRUqpy4fEgNCWWFhmOKKkoQzGLcCIfJHvWk)ALtNOKuPCq3MNOqpvSO8RvUKuXrTz8Gj)BYgBk)ALNFh1rvBgpyY)MSXgaQ8Rv(fFQLoQ6Zc1mInKNiJa9Irf6bdNljvCuZalf4elCKDK(puFqgKCJPwc0btwRUqpy4fEgNCWWFhmOKKkoQzGLcCIfJHvWk)ALtNOKuPCq3MNOqpvk)ALtNOKuPCq3MxoHskyLFTYPtusQuoOBZze21LtOKAm1sGoyYA1FtVd28rEv69Yx9ErVkItAVdF49wJSxAetG4X79b6aXtPxL)1lWNXS3Zcz6fw79SWxGKyVIs8VEVOxKDtyIT6c9GHx4zCYbd)DWGssQ4OMbwkWjwmgwbR8RvoDIssLYbDBEIc9uP8RvoDIssLYbDBEImc0ldbMfwu(1kNorjPs5GUnVCcL0bMqpy4CjPIJAgyPaNyHJSJ0)H6dYGK)UnfGZiStUXulb6GjRvxOhm8cpJtoy4VdguoEwyQpKXelNXWkywsSMyXsuMiBSnOdsjf62KRs5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusvP8RvUKuXrTz8GjhiECvaOYVw5x8Pw6OQpluZi2qoq84T6c9GHx4zCYbd)DWGssQ4OosfJHvWk)ALljvCutTK0g5LtOKoeydscfLjYV4y0mc7AQLK2yPvxOhm8cpJtoy4VdguLVjMEyqmgwbBqsOOmrE8Vcea1rvtJycepErfJ4c3KEdb2i)2wDHEWWl8mo5GH)oyqjjvCuRmLYzmScw5xR88prDu1NvIyH)nvP8RvUKuXrn1ssBKxoHsQrbTw930RrsFgZEPwsAJLEH1EFWERYC2RcoJNEplSxA4fmnG9YiU07zLyXkMa9koqVOHGkhm8EHLElhCo7n8EPrmbIhVvxOhm8cpJtoy4Vdgussfh1ksMInAmScEq53XAK2iVanTcxxUizuzqsOOmrE8Vcea1rvtJycepErLYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKQ6Kj6hxsQ4Oosfv0iMaXJZLKkoQJuHNiJa9YqGTPaQyex4M0BiWg5bOIgXeiECoAiOYbdNNiJa9sRUqpy4fEgNCWWFhmOKKkoQvKmfB0yyfC(DSgPnYlqtRW1LlsgvgKekktKh)RabqDu10iMaXJxuP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQozI(XLKkoQJurfnIjq84CjPIJ6iv4jYiqVmeyBkGkgXfUj9gcSrEaQOrmbIhNJgcQCWW5jYiqVmeOnGw930RrsFgZEPwsAJLEH1EJuPxyP3efGxT6c9GHx4zCYbd)DWGssQ4OwrYuSrJHvWgKekktKh)RabqDu10iMaXJxuP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQozI(XLKkoQJurfnIjq84CjPIJ6iv4jYiqVmeyBkGkgXfUj9gcSrEaQOrmbIhNJgcQCWW5jYiqVOILbLFhRrAJ8c00kCD5IKHn2u(1kVanTcxxUiz4jYiqVmeyYgCYB1FtVdwsfh7L1sMIn2BXk(tGETrhtzoF1Rc27zH9oLY1lvkxVrT3Zc7DWg2EFGoq80Ql0dgEHNXjhm83bdkjPIJAfjtXgngwbR8RvUKuXrTz8Gj)BQs5xRCjPIJAZ4btEImc0ldb2McOs5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusvXcnIjq84C0qqLdgoprgb6f2yl)owJ0g5ssfh1wsYe(lYB1FtVdwsfh7L1sMIn2BXk(tGETrhtzoF1Rc27zH9oLY1lvkxVrT3Zc71iig2EFGoq80Ql0dgEHNXjhm83bdkjPIJAfjtXgngwbR8RvE(DuhvTz8Gj)BQs5xRCjPIJAZ4btoq84Qu(1kp)oQJQ2mEWKNiJa9YqGTPaQu(1kxsQ4OMAjPnYlNqjfSYVw5ssfh1uljTroJWUUCcLuvSqJycepohneu5GHZtKrGEHn2YVJ1iTrUKuXrTLKmH)I8w9307GLuXXEzTKPyJ9wSI)eOxfS3Zc7DkLRxQuUEJAVNf2ljIBG37d0bINEH1EHxVWsVEC9(liqVpWZQxJGyy7nYEhSHTvxOhm8cpJtoy4Vdgussfh1ksMInAmScw5xRCjPIJAZ4btoq84Qu(1kp)oQJQ2mEWKdepUkau5xR8l(ulDu1NfQzeBi)BQcav(1k)Ip1shv9zHAgXgYtKrGEziW2uavk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsAR(B61i1c9EplS3tsB86fw6f69ISJ0)H9MIBJ9koqVNfMyVWsVmrI9EwI3B4yVOJmVmU3Fb7vrYuSXELsVLi8ELsVVIFVwIbSx0JVTvVuljTXsVx0Rf86vMZErhzGyPxyT3Zc7DWsQ4yVSoyuKeGb9R3jAJoGKV6fw6fbD(qtteOvxOhm8cpJtoy4Vdgussfh1ksMInAmSc2GKqrzICKXmEWeb0ksMInQs5xRCjPIJAQLK2iVCcLuJcMfHEqdOgDKbIfqxYixLqpObuJoYaXIrjtLYVw5aOCwkr6ihiE8wDHEWWl8mo5GH)oyqjjvCuJSBoJcmCJHvWgKekktKJmMXdMiGwrYuSrvk)ALljvCutTK0g5LtOKoKYVw5ssfh1uljTroJWUUCcLuvc9Ggqn6idelgLmvk)ALdGYzPePJCG4XB1f6bdVWZ4Kdg(7GbLKuXrTYukxRUqpy4fEgNCWWFhmOqdbvoy4gdRGnijuuMip(xbcG6OQPrmbIhV0Ql0dgEHNXjhm83bdkjPIJAfjtXgB1B1f6bdVWnibco)oQJQ2mEW0yyf8bzWHgOT6c9GHx4gKaFhmOKKkoQJuXyyf8bzWHgOT6c9GHx4gKaFhmOKKkoQr2nNrbgUXWk4dYGdnqB1f6bdVWnib(oyq9lOgEiJXUWGGzIWNWtBMWcJXWkyZenOTPaCY4mWmJSOJQ(IKb9RvxOhm8c3Ge47GbfAiOYbd3yyfmnIjq848l(ulDu1NfQzeBiprgb6LHaZIqpy4C0qqLdgohzhP)d1hKbFNmqJCv0iMaXJZLKkoQnJhm5jYiqVmeywe6bdNJgcQCWW5i7i9FO(Gm47KnmK3Ql0dgEHBqc8DWGIbMzKfDu1xKmOFgdRGpidAuqVkAetG4X5x8Pw6OQpluZi2qEImc0ldb2iRs5xR8c00kCD5IKH)nB1f6bdVWnib(oyqjjvCuJSBoJcmCJHvWk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsQkLFTYlqtRW1LlsgEImc0lgLKdq1GaqLFTYzGzgzrhv9fjd6h)B2Ql0dgEHBqc8DWGssQ4OwzkLZyyfmaQ8RvodmZil6OQVizq)4FtvhKbhImqRvxOhm8c3Ge47GbLKuXrTYukNXWkyau5xRCgyMrw0rvFrYG(XtKrGEXOGjZiRIgXeiEC(fFQLoQ6Zc1mInKNiJa9sRUqpy4fUbjW3bdQ87OoQAZ4btJHvWk)ALljvCuBgpyYbIhxfnIjq848l(ulDu1NfQzeBiprgb6LHaJSJ0)H6dYGQOrmbIhNljvCuBgpyYtKrGEXOKnGwDHEWWlCdsGVdgux8Pw6OQpluZi2qJHvWhKbnkyYanv0iMaXJZLKkoQnJhm5jYiqVmeyKDK(puFqgSvxOhm8c3Ge47Gb1fFQLoQ6Zc1mIn0yyf8bzqJcAdqLzIg02uaoz887OoQAZ4bZwDHEWWlCdsGVdgussfh1MXdMgdRGnt0G2McWjJFXNAPJQ(SqnJydB1f6bdVWnib(oyqjjvCuJSBoJcmCJHvWk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsQkLFTYlqtRW1LlsgEImc0lgLKdJQbbGk)ALFXNAPJQ(SqnJyd5aXJ3Ql0dgEHBqc8DWGssQ4OwzkLZyyfmnIjq848l(ulDu1NfQzeBiprgb6LHap4QOrmbIhNNFh1rvBgpyYtKrGEziWgzvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsQkHEqdOgDKbILHa9GUSq2aRGNwj8FHFqmj5GRjPjL8wDHEWWlCdsGVdgussfh1mWsboXIXWkyHEqdOgDKbILHmYGUSq2aRGNwj8FHFqmj5GRjPjLCvaOYVw5x8Pw6OQpluZi2q(3ufaQ8Rv(fFQLoQ6Zc1mInKNiJa9Irf6bdNljvCuZalf4elCKDK(puFqg0yQLaDWKzmk58LMAjqxdRGv(1kNorjPs5GUTMAjUJtoq84Qe6bnGA0rgiwgc03Ql0dgEHBqc8DWGssQ4OMbwkWjwmgwbR8RvoDIssLYbDBEIc9A1f6bdVWnib(oyqjjvCuhPIXWkyLFTYLKkoQPwsAJ8Yjusbpav0iMaXJZLKkoQnJhm5jYiqVyuYEBRUqpy4fUbjW3bdkjPIJAfjtXgngwbFqg0OKnavk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsQkAetG4X5x8Pw6OQpluZi2qEImc0lQyr5xR8c00kCD5IKHNiJa9YqK8TSXMYVw5fOPv46YfjdhiECv0iMaXJZV4tT0rvFwOMrSH8ezeOxmkyYiJ8wDHEWWlCdsGVdgussfh1i7MZOad3yyfSYVw5ssfh1uljTrE5ekPdP8RvUKuXrn1ssBKZiSRlNqjTvxOhm8c3Ge47GbLKuXrnYU5mkWWngwbR8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQmt0G2McWjJljvCuRizk2iXO8pRijghHm)PCWWhEk1J4iocca]] )


end