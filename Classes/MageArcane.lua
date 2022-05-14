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

            x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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


    spec:RegisterPack( "Arcane", 20220502, [[deLJPhqifipsvkUejvufBIK8jGyuOeNcr1QuaLxPkvZIc1TqjH2fQ(fqYWuaogIYYqe9mebttbQUMQuABKuHVPasJtbfNJKkzDOK07iPIQuZtb5Ea1(iPQdQaLfIsQhQGQjssLsUijvKnssfvLpssLsnssQOYjrjrTskKxssfvjZerOBQaQ2jjf)KKkkdvbLwkkjYtvOPcK6QkGWwjPIQQVssLQXssP9IWFj1Gv6WelMepgPjd4YqBwsFMsnAk50GwTci61isZwr3gf7MQFlmCk64OKGLl65smDvUUQA7uW3vfJhLQZRkz9KuPy(Ou2VutqgbOjgbKdjudjhajj5aE7aijNm11GpmKaX49YejgnfkPInsm6cdsmoyjvCKy0uEndbGa0eJL4NuKy06oZcRckqzdpRVcNgmGQaz(t5GHttPEGQazOGIyu5dNhRStOqmcihsOgsoassYb82bqsozQRbFyi5aLySyIuc1OoijXOfeaaDcfIraSqjgh4In27GLuXX2ObU8QxsACVKCaKKKTrTrd3sCBSWQTrSI9oquWEVxMqQm7DeYm8ETehycD7EJAVulXDC2l0pmZV5bdVxOxoua6nQ9ccvCko1c9GHdcVnIvS3HBjUn2RKuXrn0RqhEV69IELKkoQTKKj8x9Yc861rdy27d6xVtObSxP0RKuXrTLKmH)ICEBeRyVQBfoixVQtgcQCyVqV3btDM6uVdK)Y1RcsLFb79v8bjXEJ)1Bu7nf3g7vCGE9469xGUDVdwsfh7vDIDZzuGHZBJyf7DWagi)LRxZegj8E17f9(lyVdwsfh7DyJhmbP0lwRi9GgWEPrmbIhVxfPGa9gEVdxDlwPEXAfPxH3gXk27arb7TCjKE9AMbflfOB37f9MiWNI9o8HDGO3dYG9c8XEVO3V7iflfjF17GnSKyV1ijTWBJyf7DGhgqGEnijuuMybuuzs)t5GHx69IEjXV0lta8NyVx0BIaFk27Wh2bIEpidYjgNWYvianXObjqcqtOgYianXi6IYebiynXinHhMqHy8GmyVd17aLyuOhmCIX87OoQAZ4btIJqnKKa0eJOlkteGG1eJ0eEycfIXdYG9ouVduIrHEWWjgLKkoQJuH4iudjqaAIr0fLjcqWAIrAcpmHcX4bzWEhQ3bkXOqpy4eJssfh1i7MZOadN4iuZGtaAIr0fLjcqWAIrHEWWjgzIWNWtBMWcdXinHhMqHy0mrdABkaNmodmZil6OQVizq)igDHbjgzIWNWtBMWcdXrOM3saAIr0fLjcqWAIrAcpmHcXinIjq848l(ulDu1NfQzeBiprgb6LEhcCVS0Rqpy4C0qqLdgohzhP)d1hKb799EjJe6L8Ev1lnIjq84CjPIJAZ4btEImc0l9oe4EzPxHEWW5OHGkhmCoYos)hQpid2779s2G3l5eJc9GHtmIgcQCWWjoc1OoianXi6IYebiynXinHhMqHy8GmyVQVx1rVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUx1vVQ6v5xR8c00kCD5IKH)njgf6bdNyKbMzKfDu1xKmOFehHAgOeGMyeDrzIaeSMyKMWdtOqmQ8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHsAVQ6v5xR8c00kCD5IKHNiJa9sVQVxsoGEv17G6fav(1kNbMzKfDu1xKmOF8VjXOqpy4eJssfh1i7MZOadN4iuZWqaAIr0fLjcqWAIrAcpmHcXiaQ8RvodmZil6OQVizq)4FZEv17bzWEhQxYibIrHEWWjgLKkoQvMs5ioc1OUianXi6IYebiynXinHhMqHyeav(1kNbMzKfDu1xKmOF8ezeOx6v9G7Lm1vVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9cXOqpy4eJssfh1ktPCehHAiBaeGMyeDrzIaeSMyKMWdtOqmQ8RvUKuXrTz8GjhiE8Ev1lnIjq848l(ulDu1NfQzeBiprgb6LEhcCVi7i9FO(GmyVQ6LgXeiECUKuXrTz8Gjprgb6LEvFVKnaIrHEWWjgZVJ6OQnJhmjoc1qgzeGMyeDrzIaeSMyKMWdtOqmEqgSx1dUxYiHEv1lnIjq84CjPIJAZ4btEImc0l9oe4Er2r6)q9bzqIrHEWWjgV4tT0rvFwOMrSHehHAiJKeGMyeDrzIaeSMyKMWdtOqmEqgSx13ljmGEv1RzIg02uaoz887OoQAZ4btIrHEWWjgV4tT0rvFwOMrSHehHAiJeianXi6IYebiynXinHhMqHy0mrdABkaNm(fFQLoQ6Zc1mInKyuOhmCIrjPIJAZ4btIJqnKn4eGMyeDrzIaeSMyKMWdtOqmQ8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHsAVQ6v5xR8c00kCD5IKHNiJa9sVQVxso49QQ3b1laQ8Rv(fFQLoQ6Zc1mInKdepoXOqpy4eJssfh1i7MZOadN4iudzVLa0eJOlkteGG1eJ0eEycfIrAetG4X5x8Pw6OQpluZi2qEImc0l9oe4EhMEv1lnIjq84887OoQAZ4btEImc0l9oe4Evx9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVc9Ggqn6idel9ouVQJEzf7LLEjR3bwVf80kH)l8dIjjhgnjnP9soXOqpy4eJssfh1ktPCehHAitDqaAIr0fLjcqWAIrQLaDIrYigrjNV0ulb6AyLyu5xRC6eLKkLd62AQL4oo5aXJRsOh0aQrhzGyzi1bXinHhMqHyuOh0aQrhzGyP3H6vD1lRyVS0lz9oW6TGNwj8FHFqmj5WOjPjTxY7vvVaOYVw5x8Pw6OQpluZi2q(3Sxv9cGk)ALFXNAPJQ(SqnJyd5jYiqV0R67vOhmCUKuXrndSuGtSWr2r6)q9bzqIrHEWWjgLKkoQzGLcCIfIJqnKnqjanXi6IYebiynXinHhMqHyu5xRC6eLKkLd628ef6rmk0dgoXOKuXrndSuGtSqCeQHSHHa0eJOlkteGG1eJ0eEycfIrLFTYLKkoQPwsAJ8Yjus7fCVdOxv9sJycepoxsQ4O2mEWKNiJa9sVQVxYElXOqpy4eJssfh1rQqCeQHm1fbOjgrxuMiabRjgPj8WekeJhKb7v99s2a6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0RQEzPxLFTYlqtRW1LlsgEImc0l9ouVK8T9YgB9Q8RvEbAAfUUCrYWbIhVxv9sJycepo)Ip1shv9zHAgXgYtKrGEPx1dUxYiRxYjgf6bdNyusQ4OwrYuSrIJqnKCaeGMyeDrzIaeSMyKMWdtOqmQ8RvUKuXrn1ssBKxoHsAVd1RYVw5ssfh1uljTroJWUUCcLuIrHEWWjgLKkoQr2nNrbgoXrOgssgbOjgrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEnt0G2McWjJljvCuRizk2iXOqpy4eJssfh1i7MZOadN4ioIXkSybDBDyIoMeGMqnKraAIr0fLjcqWAIrHEWWjgrdbvoy4eJayHMqZdgoXO6Uf69MF3HUDVi8SWS3Zc7DCS3i7f0Q79orB0bKeIfJ79b79r8R3l6vDYq0RcwJe79SWEbDCdCqnydBVpqhiE49oquWEHxVsP3seEVsPxwPyy71sk9wHoSyHa9g)S3heedyVft0VEJF2l1ssBSqmst4HjuigzP387ynsBKFiJzKYu)iPjhDrzIa9YgB9YsV53XAK2iVanTcxxUiz4OlkteOxv9oOEnijuuMi3mrZ)CQrdrVG7LSEjVxY7vvVS0RYVw553rDu1MXdMCG4X7Ln261mrdABkaNmUKuXrTIKPyJ9sEVQ6LgXeiECE(DuhvTz8Gjprgb6fIJqnKKa0eJOlkteGG1eJc9GHtmIgcQCWWjgbWcnHMhmCIrw5AVpiigWERqhwSqGEJF2lnIjq849(aDG4P0R4a9wmr)6n(zVuljTXIX9AMWiHhuDd2R6KHO3WaM9IgW81zbD7EXzbjgPj8WekeJNmr)453rDu1MXdMC0fLjc0RQEPrmbIhNNFh1rvBgpyYtKrGEPxv9sJycepoxsQ4O2mEWKNiJa9sVQ6v5xRCjPIJAZ4btoq849QQxLFTYZVJ6OQnJhm5aXJ3RQEnt0G2McWjJljvCuRizk2iXrOgsGa0eJOlkteGG1eJ0eEycfIX87ynsBKdaluO5e6s(stdggXb4OlkteOxv9Q8RvoaSqHMtOl5lnnyyehqxZOC8VjXOqpy4eJvyIALPuoIJqndobOjgrxuMiabRjgPj8WekeJ53XAK2i3oHL5lnKcPtKJUOmrGEv1lJ4c3KE9Q(EvxVLyuOhmCIXAgLt7HbH4iuZBjanXi6IYebiynXOqpy4eJssfh1mWsboXcXi1sGoXizeJ0eEycfIX87ynsBKljvCuBjjt4V4OlkteOxv9Q8RvUKuXrTLKmH)IxoHsAVd1RYVw5ssfh1wsYe(loJWUUCcL0Ev1ll9YsVk)ALljvCuBgpyYbIhVxv9sJycepoxsQ4O2mEWKNOa8QxY7Ln26fav(1k)Ip1shv9zHAgXgY)M9soXrOg1bbOjgrxuMiabRjgPj8WekeJ0Wb(WJBdRNoQ6Zc1ti1IyuOhmCIrauolLiDK4iuZaLa0eJOlkteGG1eJ0eEycfIX87ynsBKxGMwHRlxKmC0fLjcqmk0dgoXy(DuhvTz8GjXrOMHHa0eJOlkteGG1eJ0eEycfIrAetG4X553rDu1MXdM8efGxeJc9GHtmkjvCuhPcXrOg1fbOjgrxuMiabRjgPj8WekeJ0iMaXJZZVJ6OQnJhm5jkaV6vvVk)ALljvCutTK0g5LtOK27q9Q8RvUKuXrn1ssBKZiSRlNqjLyuOhmCIrjPIJALPuoIJqnKnacqtmIUOmracwtmst4Hjuigpid2R6b37B799EzPxY6DG1BbpTs4)c)GysYHrp4M0EjNyuOhmCIrgyMrw0rvFrYG(rCeQHmYianXi6IYebiynXOqpy4eJmr4t4PntyHHyKMWdtOqmEqgSx13R6Gy0fgKyKjcFcpTzclmehHAiJKeGMyuOhmCIX87OoQAZ4btIr0fLjcqWAIJqnKrceGMyeDrzIaeSMyuOhmCIrjPIJAgyPaNyHyeal0eAEWWjgzLR9(GGKyVY1lJWEVLtOKw6nQ9o8H3R4a9(G9AjgqhKR3Fbb6DGhGU3x4zCV)c2R0B5ekP9ErVMjAa9RxMVtTGUDVFFILsV53DOB37zH9QoNKmH)Q3jAJoGKVigPj8WekeJk)ALtNOKuPCq3MNOqVEv1RYVw50jkjvkh0T5LtOK2l4Ev(1kNorjPs5GUnNryxxoHsAVQ6Lggqx8JBa9Z6v2RQEPrmbIhNZaZmYIoQ6lsg0pEIcWREv17G61GKqrzICKXmEWeb0ksMIn2RQEPrmbIhNljvCuBgpyYtuaErCeQHSbNa0eJOlkteGG1eJ0eEycfIXb1B(DSgPnYpKXmszQFK0KJUOmrGEv1ll9oOEZVJ1iTrEbAAfUUCrYWrxuMiqVSXwVS0RbjHIYe5MjA(NtnAi6fCVK1RQEv(1kxsQ4OMAjPnYlNqjTxW9Q8RvUKuXrn1ssBKZiSRlNqjTxY7LCIraSqtO5bdNyunrYiZ5REFWEnfy2RzCWW79xWEFGNvVd2WACVk)Rx417dCo7DkLR3z429IE8TT6TgzVkXz17zH9YkfdBVId07GnS9(aDG4P073NyP0B(Dh629EwyVJJ9gzVGwDV3jAJoGKqSqmk0dgoXOzCWWjoc1q2BjanXi6IYebiynXinHhMqHyu5xR887OoQAZ4btoq849YgB9AMObTnfGtgxsQ4OwrYuSrIrHEWWjgbq5SuI0rIJqnKPoianXi6IYebiynXinHhMqHyu5xR887OoQAZ4btoq849YgB9AMObTnfGtgxsQ4OwrYuSrIrHEWWjgtbak(PlMsskXrOgYgOeGMyeDrzIaeSMyKMWdtOqmQ8RvE(DuhvTz8Gjprgb6LEhQxw6vD0779sYEhy9MFhRrAJ8c00kCD5IKHJUOmrGEjNyuOhmCIrgyMrw0rvFrYG(rCeQHSHHa0eJOlkteGG1eJc9GHtmkjvCuBgpysmcGfAcnpy4eJQ7wO3B(Dh629EwyVQZjjt4V6DI2Odi5lJ79xWEhSHTxfSgj2lOJBG37f9c8zm7v6T(NZx9woHskc0RIKPyJeJ0eEycfIrdscfLjYrgZ4bteqRizk2yVQ6v5xR887OoQAZ4bt(3Sxv9YsVmIlCt617q9YsVK8T9(EVS0lzdO3bwV0Wa6IFCsFLqX7L8EjVx2yRxLFTYPtusQuoOBZlNqjTxW9Q8RvoDIssLYbDBoJWUUCcL0EjN4iudzQlcqtmIUOmracwtmst4HjuignijuuMihzmJhmraTIKPyJ9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVk)ALljvCuBgpyY)MeJc9GHtmkjvCuRizk2iXrOgsoacqtmIUOmracwtmk0dgoXyj(ZjEh0T15x5fXinHhMqHyu5xR887OoQAZ4btoq849YgB9AMObTnfGtgxsQ4OwrYuSXEzJTEnt0G2McWjJNcau8txmLK0EzJTEzPxZenOTPaCY4aOCwkr6yVQ6Dq9MFhRrAJ8c00kCD5IKHJUOmrGEjNy0fgKySe)5eVd6268R8I4iudjjJa0eJOlkteGG1eJ0eEycfIrLFTYZVJ6OQnJhm5aXJ3lBS1RzIg02uaozCjPIJAfjtXg7Ln261mrdABkaNmEkaqXpDXuss7Ln26LLEnt0G2McWjJdGYzPePJ9QQ3b1B(DSgPnYlqtRW1Llsgo6IYeb6LCIrHEWWjgV4tT0rvFwOMrSHehHAijjjanXi6IYebiynXinHhMqHy0mrdABkaNm(fFQLoQ6Zc1mInKyuOhmCIrjPIJAZ4btIJqnKKeianXi6IYebiynXOqpy4eJMjwqNI6OQzGoaXiawOj08GHtmoquWEh2yG37f9wyf(iQUb7v8Er2Vu6DWsQ4yVSEkLRxGFcD7EplSxqh3ahud2W27d0bINE)(elLEZV7q3U3blPIJ9QorTcEVSY1EhSKko2R6e1k6fw69Kj6hcyCVpyVuXb569xWEh2yG37d8SGEVNf2lOJBGdQbBy79b6aXtVFFILsVpyVq)Wm)MxVNf27GnW7LAjUJtJ7Te9(GGmN9wedyVWJtmst4HjuighuVNmr)4ssfh1i1k4OlkteOxv9cGk)ALFXNAPJQ(SqnJyd5FZEv1laQ8Rv(fFQLoQ6Zc1mInKNiJa9sVdbUxw6vOhmCUKuXrTYukhhzhP)d1hKb7DG1RYVw5MjwqNI6OQzGoaNryxxoHsAVKtCeQHKdobOjgrxuMiabRjgf6bdNy0mXc6uuhvnd0bigbWcnHMhmCIrw5AVdBmW71skoixVki69(liqVa)e629EwyVGoUbEVpqhiEmU3heK5S3Fb7fE9ErVfwHpIQBWEfVxK9lLEhSKko2lRNs56f69EwyVSsXWcQbBy79b6aXdNyKMWdtOqmQ8RvUKuXrTz8Gj)B2RQEv(1kp)oQJQ2mEWKNiJa9sVdbUxw6vOhmCUKuXrTYukhhzhP)d1hKb7DG1RYVw5MjwqNI6OQzGoaNryxxoHsAVKtCeQHKVLa0eJOlkteGG1eJ0eEycfIrG44Paaf)0ftjjLNiJa9sVQV332lBS1laQ8RvEkaqXpDXuss1g(thtrboH3lE5ekP9Q(EhaXOqpy4eJssfh1ktPCehHAiP6Ga0eJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmQUJ9(i(17f9YiKI9w(j27d2RLya7f94BB1lJ4sV1i79SWEr)Gj27GnS9(aDG4X4ErdO3lS27zHjcsP3YbNZEpid2BImc0HUDVH3lRumS8EzLpqk9g(8vVk4Dy27f9Q8tV3l6vDdMrVId0R6KHOxyT387o0T79SWEhh7nYEbT6EVt0gDajHyHtmst4HjuigPrmbIhNljvCuBgpyYtuaE1RQEzex4M0R3H6LLEh8b0779YsVKnGEhy9sddOl(Xj9vcfVxY7L8Ev1RYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9QQxw6Dq9MFhRrAJ8c00kCD5IKHJUOmrGEzJTEnijuuMi3mrZ)CQrdrVG7LSEjVxv9oOEZVJ1iTr(HmMrkt9JKMC0fLjc0RQEhuV53XAK2ixsQ4O2ssMWFXrxuMiaXrOgsoqjanXi6IYebiynXOqpy4eJssfh1ksMInsmcGfAcnpy4eJSwYuSXElwXFc0RhxVkyV)cc0RC9EwyVOd0Bu7DWg2EH1EvNmeu5GH3lS0BIcWRELsVazyAcD7EPwsAJLEFGZzVmcPyVWR3tif7DgUnM9ErVk)079SY4BB1BImc0HUDVmIleJ0eEycfIrLFTYLKkoQnJhm5FZEv1RYVw5ssfh1MXdM8ezeOx6DiW9Atb6vvV0iMaXJZrdbvoy48ezeOxioc1qYHHa0eJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmYAjtXg7Tyf)jqVY8rEv6vb79SWENs56LkLRxO37zH9YkfdBVpqhiE6vk9c64g49(aNZEtSCrI9EwyVuljTXsVft0pIrAcpmHcXOYVw553rDu1MXdM8VzVQ6v5xRCjPIJAZ4btoq849QQxLFTYZVJ6OQnJhm5jYiqV07qG71Mc0RQEhuV53XAK2ixsQ4O2ssMWFXrxuMiaXrOgsQUianXi6IYebiynXi1sGoXizeJOKZxAQLaDnSsmQ8RvoDIssLYbDBn1sChNCG4XvXIYVw5ssfh1MXdM8VjBSXYGozI(XddyAgpyIaQyr5xR887OoQAZ4bt(3Kn2OrmbIhNJgcQCWW5jkaViNCYjgPj8WekeJaOYVw5x8Pw6OQpluZi2q(3Sxv9EYe9JljvCuJuRGJUOmrGEv1ll9Q8RvoakNLsKoYbIhVx2yRxHEqdOgDKbILEb3lz9sEVQ6fav(1k)Ip1shv9zHAgXgYtKrGEPx13Rqpy4CjPIJAgyPaNyHJSJ0)H6dYGeJc9GHtmkjvCuZalf4elehHAiHbqaAIr0fLjcqWAIrHEWWjgLKkoQzGLcCIfIraSqtO5bdNyKvU27dcsI9Aa9Z6vACVqggeakhoF17VG9o8H37Jf69sftteO3l61JR3hPCyVMzql9wZGP3bEaAIrAcpmHcXinmGU4h3a6N1RSxv9Q8RvoDIssLYbDBE5ekP9cUxLFTYPtusQuoOBZze21LtOKsCeQHeiJa0eJOlkteGG1eJayHMqZdgoX44j517VaD7Eh(W7DWg49(yHEVd2W2RLu6vbrV3FbbigPj8WekeJk)ALtNOKuPCq3MNOqVEv1lnIjq84CjPIJAZ4btEImc0l9QQxw6v5xR887OoQAZ4bt(3Sx2yRxLFTYLKkoQnJhm5FZEjNyKAjqNyKmIrHEWWjgLKkoQzGLcCIfIJqnKajjanXi6IYebiynXinHhMqHyu5xRCjPIJAQLK2iVCcL0EhcCVgKekktKFXXOze21uljTXcXOqpy4eJssfh1rQqCeQHeibcqtmIUOmracwtmst4Hjuigv(1kp)oQJQ2mEWK)n7Ln26LrCHBsVEvFVK9wIrHEWWjgLKkoQvMs5ioc1qcdobOjgrxuMiabRjgf6bdNyeneu5GHtmc9dZ8BEAyLyKrCHBsp1dEyElXi0pmZV5PHmmiauoKyKmIrAcpmHcXOYVw553rDu1MXdMCG4X7vvVk)ALljvCuBgpyYbIhN4iudj8wcqtmk0dgoXOKuXrTIKPyJeJOlkteGG1ehXrmMXjhmCcqtOgYianXi6IYebiynXOqpy4eJssfh1ksMInsmcGfAcnpy4eJdefSx0q0lS27dcsI9oJNEdVxgXLEfhOxAetG4Xl9kj2ROe)R3l6vb79Bsmst4Hjuigl4Pvc)x4hetsomAsAs7vvV0Wa6IFCdOFwVYEv1lnIjq84887OoQAZ4btEImc0l9oe4Er2r6)q9bzWEv1lnIjq848l(ulDu1NfQzeBiprgb6LEhQxsOxv9YsVk)ALljvCutTK0g5LtOK2R671GKqrzI8lognJWUMAjPnw6vvVNmr)453rDu1MXdMC0fLjc0RQEnijuuMi)GmO(7hCQfZEvFVgKekktKFXXOze21a4uEPRrQfZEjN4iudjjanXi6IYebiynXinHhMqHyKLEhuVf80kH)l8dIjjhgnjnP9YgB9oOEPHb0f)4gq)SEL9sEVQ6LgXeiEC(fFQLoQ6Zc1mInKNOa8Qxv9YsVk)ALljvCutTK0g5LtOK2R671GKqrzI8lognJWUMAjPnw6vvV0iMaXJZLKkoQnJhm5jYiqV07qG7fzhP)d1hKb7vvVmIlCt61R671GKqrzICXuZaDiZNrZiUOnPxVQ6v5xR887OoQAZ4btoq849soXOqpy4eJssfh1ksMInsCeQHeianXi6IYebiynXinHhMqHyKLEhuVf80kH)l8dIjjhgnjnP9YgB9oOEPHb0f)4gq)SEL9sEVQ6LgXeiEC(fFQLoQ6Zc1mInKNOa8Qxv9YsVk)ALljvCutTK0g5LtOK2R671GKqrzI8lognJWUMAjPnw6vvVNmr)453rDu1MXdMC0fLjc0RQEPrmbIhNNFh1rvBgpyYtKrGEP3Ha3lYos)hQpid2RQEnijuuMi)GmO(7hCQfZEvFVgKekktKFXXOze21a4uEPRrQfZEjNyuOhmCIrjPIJAfjtXgjoc1m4eGMyeDrzIaeSMyKMWdtOqmYsVdQ3cEALW)f(bXKKdJMKM0EzJTEhuV0Wa6IFCdOFwVYEjVxv9sJycepo)Ip1shv9zHAgXgYtuaE1RQEzPxLFTYLKkoQPwsAJ8Yjus7v99AqsOOmr(fhJMryxtTK0gl9QQxw6Dq9EYe9JNFh1rvBgpyYrxuMiqVSXwV0iMaXJZZVJ6OQnJhm5jYiqV0R671GKqrzI8lognJWUgaNYlDnsDgM9sEVQ61GKqrzI8dYG6VFWPwm7v99AqsOOmr(fhJMryxdGt5LUgPwm7LCIrHEWWjgLKkoQvKmfBK4iuZBjanXi6IYebiynXinHhMqHyeav(1kpfaO4NUykjPAd)PJPOaNW7fVCcL0Eb3laQ8RvEkaqXpDXuss1g(thtrboH3loJWUUCcL0Ev1ll9Q8RvUKuXrTz8GjhiE8EzJTEv(1kxsQ4O2mEWKNiJa9sVdbUxBkqVK3RQEzPxLFTYZVJ6OQnJhm5aXJ3lBS1RYVw553rDu1MXdM8ezeOx6DiW9Atb6LCIrHEWWjgLKkoQvKmfBK4iuJ6Ga0eJOlkteGG1eJ0eEycfIrdscfLjYhi)Lt)liGUykjP9YgB9YsVaOYVw5Paaf)0ftjjvB4pDmff4eEV4FZEv1laQ8RvEkaqXpDXuss1g(thtrboH3lE5ekP9ouVaOYVw5Paaf)0ftjjvB4pDmff4eEV4mc76Yjus7LCIrHEWWjgLKkoQvMs5ioc1mqjanXi6IYebiynXinHhMqHyu5xRCZelOtrDu1mqhG)n7vvVaOYVw5x8Pw6OQpluZi2q(3Sxv9cGk)ALFXNAPJQ(SqnJyd5jYiqV07qG7vOhmCUKuXrTYukhhzhP)d1hKbjgf6bdNyusQ4OwzkLJ4iuZWqaAIr0fLjcqWAIrQLaDIrYigrjNV0ulb6AyLyu5xRC6eLKkLd62AQL4oo5aXJRIfLFTYLKkoQnJhm5Ft2yJLbDYe9JhgW0mEWebuXIYVw553rDu1MXdM8VjBSrJycepohneu5GHZtuaEro5Ktmst4HjuigbqLFTYV4tT0rvFwOMrSH8VzVQ69Kj6hxsQ4OgPwbhDrzIa9QQxw6v5xRCauolLiDKdepEVSXwVc9Ggqn6idel9cUxY6L8Ev1ll9cGk)ALFXNAPJQ(SqnJyd5jYiqV0R67vOhmCUKuXrndSuGtSWr2r6)q9bzWEzJTEPrmbIhNBMybDkQJQMb6a8ezeOx6Ln26Lggqx8Jt6RekEVKtmk0dgoXOKuXrndSuGtSqCeQrDraAIr0fLjcqWAIrHEWWjgLKkoQzGLcCIfIraSqtO5bdNyC4Hx(myVNf2lYUP4aiqVMXH(bLzVk)ATxPiM9ErVEC9oJc2RzCOFqz2Rzg0cXinHhMqHyu5xRC6eLKkLd628ef61RQEv(1khz3uCaeqBgh6huM8VjXrOgYgabOjgrxuMiabRjgf6bdNyusQ4OMbwkWjwigPwc0jgjJyKMWdtOqmQ8RvoDIssLYbDBEIc96vvVS0RYVw5ssfh1MXdM8VzVSXwVk)ALNFh1rvBgpyY)M9YgB9cGk)ALFXNAPJQ(SqnJyd5jYiqV0R67vOhmCUKuXrndSuGtSWr2r6)q9bzWEjN4iudzKraAIr0fLjcqWAIrHEWWjgLKkoQzGLcCIfIrQLaDIrYigPj8WekeJk)ALtNOKuPCq3MNOqVEv1RYVw50jkjvkh0T5LtOK2l4Ev(1kNorjPs5GUnNryxxoHskXrOgYijbOjgrxuMiabRjgbWcnHMhmCIXbB(iVk9E5REVOxfXjT3Hp8ERr2lnIjq849(aDG4P0RY)6f4Zy27zHm9cR9Ew4lqsSxrj(xVx0lYUjmrIrAcpmHcXOYVw50jkjvkh0T5jk0Rxv9Q8RvoDIssLYbDBEImc0l9oe4EzPxw6v5xRC6eLKkLd628Yjus7DG1Rqpy4CjPIJAgyPaNyHJSJ0)H6dYG9sEVV3RnfGZiS3l5eJulb6eJKrmk0dgoXOKuXrndSuGtSqCeQHmsGa0eJOlkteGG1eJ0eEycfIrw6nXAIflrzI9YgB9oOEpiLuOB3l59QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVk)ALljvCuBgpyYbIhVxv9cGk)ALFXNAPJQ(SqnJyd5aXJtmk0dgoXOJNfM6dzmXYrCeQHSbNa0eJOlkteGG1eJ0eEycfIrLFTYLKkoQPwsAJ8Yjus7DiW9AqsOOmr(fhJMryxtTK0gleJc9GHtmkjvCuhPcXrOgYElbOjgrxuMiabRjgPj8WekeJgKekktKh)RabqDu10iMaXJx6vvVmIlCt617qG7vD9wIrHEWWjglFtm9WGqCeQHm1bbOjgrxuMiabRjgPj8WekeJk)ALN)jQJQ(Ssel8VzVQ6v5xRCjPIJAQLK2iVCcL0EvFVKaXOqpy4eJssfh1ktPCehHAiBGsaAIr0fLjcqWAIrHEWWjgLKkoQvKmfBKyeal0eAEWWjgv36Zy2l1ssBS0lS27d2BvMZEvWz807zH9sdVGPbSxgXLEpRelwXeOxXb6fneu5GH3lS0B5GZzVH3lnIjq84eJ0eEycfIXb1B(DSgPnYlqtRW1Llsgo6IYeb6vvVgKekktKh)RabqDu10iMaXJx6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEpzI(XLKkoQJuHJUOmrGEv1lnIjq84CjPIJ6iv4jYiqV07qG71Mc0RQEzex4M0R3Ha3R6Aa9QQxAetG4X5OHGkhmCEImc0lehHAiByianXi6IYebiynXinHhMqHym)owJ0g5fOPv46YfjdhDrzIa9QQxdscfLjYJ)vGaOoQAAetG4Xl9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVNmr)4ssfh1rQWrxuMiqVQ6LgXeiECUKuXrDKk8ezeOx6DiW9Atb6vvVmIlCt617qG7vDnGEv1lnIjq84C0qqLdgoprgb6LEhQxsyaeJc9GHtmkjvCuRizk2iXrOgYuxeGMyeDrzIaeSMyuOhmCIrjPIJAfjtXgjgbWcnHMhmCIr1T(mM9sTK0gl9cR9gPsVWsVjkaVigPj8WekeJgKekktKh)RabqDu10iMaXJx6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEpzI(XLKkoQJuHJUOmrGEv1lnIjq84CjPIJ6iv4jYiqV07qG71Mc0RQEzex4M0R3Ha3R6Aa9QQxAetG4X5OHGkhmCEImc0l9QQxw6Dq9MFhRrAJ8c00kCD5IKHJUOmrGEzJTEv(1kVanTcxxUiz4jYiqV07qG7LSHPxYjoc1qYbqaAIr0fLjcqWAIrHEWWjgLKkoQvKmfBKyeal0eAEWWjghSKko2lRLmfBS3Iv8Na9AJoMYC(QxfS3Zc7DkLRxQuUEJAVNf27GnS9(aDG4HyKMWdtOqmQ8RvUKuXrTz8Gj)B2RQEv(1kxsQ4O2mEWKNiJa9sVdbUxBkqVQ6v5xRCjPIJAQLK2iVCcL0Eb3RYVw5ssfh1uljTroJWUUCcL0Ev1ll9sJycepohneu5GHZtKrGEPx2yR387ynsBKljvCuBjjt4V4OlkteOxYjoc1qsYianXi6IYebiynXOqpy4eJssfh1ksMInsmcGfAcnpy4eJdwsfh7L1sMIn2BXk(tGETrhtzoF1Rc27zH9oLY1lvkxVrT3Zc7Lvkg2EFGoq8qmst4Hjuigv(1kp)oQJQ2mEWK)n7vvVk)ALljvCuBgpyYbIhVxv9Q8RvE(DuhvTz8Gjprgb6LEhcCV2uGEv1RYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9QQxw6LgXeiECoAiOYbdNNiJa9sVSXwV53XAK2ixsQ4O2ssMWFXrxuMiqVKtCeQHKKKa0eJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmoyjvCSxwlzk2yVfR4pb6vb79SWENs56LkLR3O27zH9c64g49(aDG4PxyTx41lS0RhxV)cc07d8S6Lvkg2EJS3bByjgPj8WekeJk)ALljvCuBgpyYbIhVxv9Q8RvE(DuhvTz8GjhiE8Ev1laQ8Rv(fFQLoQ6Zc1mInK)n7vvVaOYVw5x8Pw6OQpluZi2qEImc0l9oe4ETPa9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjusjoc1qssGa0eJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmQUBHEVNf27jPnE9cl9c9Er2r6)WEtXTXEfhO3ZctSxyPxMiXEplX7nCSx0rMxg37VG9Qizk2yVsP3seEVsP3xXVxlXa2l6X32QxQLK2yP3l61cE9kZzVOJmqS0lS27zH9oyjvCSxwhmkscWG(17eTrhqYx9cl9IScFOPjcqmst4HjuignijuuMihzmJhmraTIKPyJ9QQxLFTYLKkoQPwsAJ8Yjus7v9G7LLEf6bnGA0rgiw6LvSxY6L8Ev1RqpObuJoYaXsVQVxY6vvVk)ALdGYzPePJCG4Xjoc1qYbNa0eJOlkteGG1eJ0eEycfIrdscfLjYrgZ4bteqRizk2yVQ6v5xRCjPIJAQLK2iVCcL0EhQxLFTYLKkoQPwsAJCgHDD5ekP9QQxHEqdOgDKbILEvFVK1RQEv(1khaLZsjsh5aXJtmk0dgoXOKuXrnYU5mkWWjoc1qY3saAIrHEWWjgLKkoQvMs5igrxuMiabRjoc1qs1bbOjgrxuMiabRjgPj8WekeJgKekktKh)RabqDu10iMaXJxigf6bdNyeneu5GHtCeQHKducqtmk0dgoXOKuXrTIKPyJeJOlkteGG1ehXrmsJycepEHa0eQHmcqtmIUOmracwtmk0dgoXynJYP9WGqmcGfAcnpy4eJdBcJeEq1nyV)c0T71oHL5REHuiDI9(apREftEVdefSx417d8S69IJP34SW8bwqoXinHhMqHym)owJ0g52jSmFPHuiDIC0fLjc0RQEPrmbIhNljvCuBgpyYtKrGEPx13ljmGEv1lnIjq848l(ulDu1NfQzeBiprb4vVQ6LLEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5xCmAgHDn1ssBS0RQEzPxw69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84887OoQAZ4btEImc0l9oe4ETPa9QQxAetG4X5ssfh1MXdM8ezeOx6v99AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEzP3b17jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X5ssfh1MXdM8ezeOx6v99AqsOOmr(fhJMryxdGt5LUgPwm7L8EzJTEPrmbIhNljvCuBgpyYtKrGEP3Ha3RnfOxY7LCIJqnKKa0eJOlkteGG1eJ0eEycfIX87ynsBKBNWY8LgsH0jYrxuMiqVQ6LgXeiECUKuXrTz8Gjprb4vVQ6LLEhuVNmr)4OpH2wh6iahDrzIa9YgB9YsVNmr)4OpH2wh6iahDrzIa9QQxgXfUj96v9G7DGoGEjVxY7vvVS0ll9sJycepo)Ip1shv9zHAgXgYtKrGEPx13lzdOxv9Q8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHsAVK3lBS1ll9sJycepo)Ip1shv9zHAgXgYtKrGEPxW9oGEv1RYVw5ssfh1uljTrE5ekP9cU3b0l59sEVQ6v5xR887OoQAZ4btoq849QQxgXfUj96v9G71GKqrzICXuZaDiZNrZiUOnPhXOqpy4eJ1mkN2ddcXrOgsGa0eJOlkteGG1eJ0eEycfIX87ynsBKdaluO5e6s(stdggXb4OlkteOxv9sJycepox5xRAayHcnNqxYxAAWWioaprb4vVQ6v5xRCayHcnNqxYxAAWWioGUMr54aXJ3RQEzPxLFTYLKkoQnJhm5aXJ3RQEv(1kp)oQJQ2mEWKdepEVQ6fav(1k)Ip1shv9zHAgXgYbIhVxY7vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx6fCVdOxv9YsVk)ALljvCutTK0g5LtOK27qG71GKqrzI8lognJWUMAjPnw6vvVS0ll9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECE(DuhvTz8Gjprgb6LEhcCV2uGEv1lnIjq84CjPIJAZ4btEImc0l9Q(EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwVS07G69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9Q(EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwV0iMaXJZLKkoQnJhm5jYiqV07qG71Mc0l59soXOqpy4eJ1mkNsmpIJqndobOjgrxuMiabRjgPj8WekeJ53XAK2ihawOqZj0L8LMgmmIdWrxuMiqVQ6LgXeiECUYVw1aWcfAoHUKV00GHrCaEIcWREv1RYVw5aWcfAoHUKV00GHrCaDfMihiE8Ev1RzIg02uaoz8AgLtjMhXOqpy4eJvyIALPuoIJqnVLa0eJOlkteGG1eJc9GHtmYaZmYIoQ6lsg0pIraSqtO5bdNyCyfy27apaDVpWZQ3bBy7fw7fEGu6Lgmq3U3VzVLiCEVSY1EHxVpW5SxfS3Fbb69bEw9c64g4g3lvkxVWR3YeABDZx9QG1irIrAcpmHcX4G6n)owJ0g5fOPv46YfjdhDrzIa9QQxAetG4X5x8Pw6OQpluZi2qEImc0l9oe4Evx9Yk2ll9sc9oW6TGNwj8FHFqmj5WOhCtAVK3RQEPrmbIhNljvCuBgpyYtKrGEP3Ha3lzdOxwXEzPxsO3bwVf80kH)l8dIjjhg9GBs7LCIJqnQdcqtmIUOmracwtmst4HjuigZVJ1iTrEbAAfUUCrYWrxuMiqVQ6v5xR8c00kCD5IKH)n7vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx6DiW9QU6LvSxw6Le6DG1BbpTs4)c)GysYHrp4M0EjVxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxYgqVSI9YsVKqVdSEl4Pvc)x4hetsom6b3K2l5eJc9GHtmYaZmYIoQ6lsg0pIJqnducqtmIUOmracwtmst4HjuignijuuMip(xbcG6OQPrmbIhV0RQEzP3s8NkqhGBiMYbNOUetdOFC0fLjc0lBS1Bj(tfOdWn)L7prnMFZdgohDrzIa9soXOqpy4eJ1jwSOPupIJqnddbOjgrxuMiabRjgf6bdNyeaLZsjshjgbWcnHMhmCIXbB(iVk9(lyVaOCwkr6yVpWZQxXK3lRCT3loMEHLEtuaE1Ru69bNtJ7Lrif7T8tS3l6LkLRx41RcwJe79IJHtmst4HjuighuV53XAK2iVanTcxxUiz4OlkteOxv9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3lzVTxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxYuhehHAuxeGMyeDrzIaeSMyKMWdtOqmMFhRrAJ8c00kCD5IKHJUOmrGEv1RzIg02uaozC0qqLdgoXOqpy4eJaOCwkr6iXrOgYgabOjgrxuMiabRjgPj8WekeJ0iMaXJZLKkoQnJhm5jkaV6vvVS07G69Kj6hh9j026qhb4OlkteOx2yRxw69Kj6hh9j026qhb4OlkteOxv9YiUWnPxVQhCVd0b0l59sEVQ6LLEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9Q(EjBa9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7L8EzJTEzPxAetG4X5x8Pw6OQpluZi2qEIcWREv1RYVw5ssfh1uljTrE5ekP9cU3b0l59sEVQ6v5xR887OoQAZ4btoq849QQxgXfUj96v9G71GKqrzICXuZaDiZNrZiUOnPhXOqpy4eJaOCwkr6iXrOgYiJa0eJOlkteGG1eJc9GHtmMcau8txmLKuIraSqtO5bdNyCGOG9wmLK0EH1EV4y6vCGEfZELe7n8EPa9koqVpHdY1Rc273S3AK9od3gZEplX79SWEze27faNYlJ7Lrif629w(j27d2RLya7vUENOuUEVNOxjPIJ9sTK0gl9koqVNLC9EXX07JuCqUEhi)LR3Fbb4eJ0eEycfIrAetG4X5x8Pw6OQpluZi2qEImc0l9Q(EnijuuMiplAgHDnaoLx6AK6loMEv1lnIjq84CjPIJAZ4btEImc0l9Q(EnijuuMiplAgHDnaoLx6AKAXSxv9YsVNmr)453rDu1MXdMC0fLjc0RQEzPxAetG4X553rDu1MXdM8ezeOx6DOEr2r6)q9bzWEzJTEPrmbIhNNFh1rvBgpyYtKrGEPx13RbjHIYe5zrZiSRbWP8sxJuNHzVK3lBS17G69Kj6hp)oQJQ2mEWKJUOmrGEjVxv9Q8RvUKuXrn1ssBKxoHsAVQVxs2RQEbqLFTYV4tT0rvFwOMrSHCG4X7vvVk)ALNFh1rvBgpyYbIhVxv9Q8RvUKuXrTz8GjhiECIJqnKrscqtmIUOmracwtmk0dgoXykaqXpDXussjgbWcnHMhmCIXbIc2BXuss79bEw9kM9(yHEVMrPavMiVxw5AVxCm9cl9MOa8QxP07doNg3lJqk2B5NyVx0lvkxVWRxfSgj27fhdNyKMWdtOqmsJycepo)Ip1shv9zHAgXgYtKrGEP3H6fzhP)d1hKb7vvVk)ALljvCutTK0g5LtOK27qG71GKqrzI8lognJWUMAjPnw6vvV0iMaXJZLKkoQnJhm5jYiqV07q9YsVi7i9FO(GmyVV3Rqpy48l(ulDu1NfQzeBihzhP)d1hKb7LCIJqnKrceGMyeDrzIaeSMyKMWdtOqmsJycepoxsQ4O2mEWKNiJa9sVd1lYos)hQpid2RQEzPxw6Dq9EYe9JJ(eABDOJaC0fLjc0lBS1ll9EYe9JJ(eABDOJaC0fLjc0RQEzex4M0Rx1dU3b6a6L8EjVxv9YsVS0lnIjq848l(ulDu1NfQzeBiprgb6LEvFVgKekktKlMAgHDnaoLx6AK6loMEv1RYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9sEVSXwVS0lnIjq848l(ulDu1NfQzeBiprgb6LEb37a6vvVk)ALljvCutTK0g5LtOK2l4EhqVK3l59QQxLFTYZVJ6OQnJhm5aXJ3RQEzex4M0Rx1dUxdscfLjYftnd0HmFgnJ4I2KE9soXOqpy4eJPaaf)0ftjjL4iudzdobOjgrxuMiabRjgf6bdNySe)5eVd6268R8IyKMWdtOqmYsVdQ387ynsBKxGMwHRlxKmC0fLjc0lBS1RYVw5fOPv46Yfjd)B2l59QQxLFTYLKkoQPwsAJ8Yjus7DiW9AqsOOmr(fhJMryxtTK0gl9QQxAetG4X5ssfh1MXdM8ezeOx6DiW9ISJ0)H6dYG9QQxgXfUj96v99AqsOOmrUyQzGoK5ZOzex0M0Rxv9Q8RvE(DuhvTz8GjhiECIrxyqIXs8Nt8oOBRZVYlIJqnK9wcqtmIUOmracwtmst4HjuigZVJ1iTrEbAAfUUCrYWrxuMiqVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUxw6vOhmCoAiOYbdNJSJ0)H6dYG9(EVKrc9soXOqpy4eJOHGkhmCIJqnKPoianXi6IYebiynXinHhMqHySGNwj8FHFqmj5WOjPjTxv9sddOl(XnG(z9k7vvVk)ALljvCuBgpyYbIhVxv9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3lYos)hQpid2RQEPrmbIhNljvCuBgpyYtKrGEPx13lzdGyuOhmCIX87OoQAZ4btIJqnKnqjanXi6IYebiynXinHhMqHySGNwj8FHFqmj5WOjPjTxv9sddOl(XnG(z9k7vvVMjAqBtb4KXZVJ6OQnJhmjgf6bdNy8Ip1shv9zHAgXgsCeQHSHHa0eJOlkteGG1eJ0eEycfIXcEALW)f(bXKKdJMKM0Ev1lnmGU4h3a6N1RSxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxKDK(puFqgKyuOhmCIXl(ulDu1NfQzeBiXrOgYuxeGMyeDrzIaeSMyKMWdtOqmAMObTnfGtg)Ip1shv9zHAgXgsmk0dgoXOKuXrTz8GjXrOgsoacqtmIUOmracwtmst4HjuigzP3b1BbpTs4)c)GysYHrtstAVSXwVdQxAyaDXpUb0pRxzVK3RQEzP3b1B(DSgPnYlqtRW1Llsgo6IYeb6Ln26v5xR8c00kCD5IKH)n7L8Ev1RYVw5ssfh1uljTrE5ekP9oe4EnijuuMi)IJrZiSRPwsAJLEv1lnIjq84CjPIJAZ4btEImc0l9oe4Er2r6)q9bzWEv1lJ4c3KE9Q(EnijuuMixm1mqhY8z0mIlAt61RQEv(1kp)oQJQ2mEWKdepoXOqpy4eJx8Pw6OQpluZi2qIJqnKKmcqtmIUOmracwtmst4HjuigzP3b1BbpTs4)c)GysYHrtstAVSXwVdQxAyaDXpUb0pRxzVK3RQEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5xCmAgHDn1ssBS0RQEpzI(XZVJ6OQnJhm5OlkteOxv9sJycepop)oQJQ2mEWKNiJa9sVdbUxKDK(puFqgSxv9AqsOOmr(bzq93p4ulM9Q(EnijuuMi)IJrZiSRbWP8sxJulMeJc9GHtmEXNAPJQ(SqnJydjoc1qsssaAIr0fLjcqWAIrAcpmHcXil9oOEl4Pvc)x4hetsomAsAs7Ln26Dq9sddOl(XnG(z9k7L8Ev1RYVw5ssfh1uljTrE5ekP9oe4EnijuuMi)IJrZiSRPwsAJLEv1ll9oOEpzI(XZVJ6OQnJhm5OlkteOx2yRxAetG4X553rDu1MXdM8ezeOx6v99AqsOOmr(fhJMryxdGt5LUgPodZEjVxv9AqsOOmr(bzq93p4ulM9Q(EnijuuMi)IJrZiSRbWP8sxJulMeJc9GHtmEXNAPJQ(SqnJydjoc1qssGa0eJOlkteGG1eJ0eEycfIrw6Dq9wWtRe(VWpiMKCy0K0K2lBS17G6Lggqx8JBa9Z6v2l59QQxLFTYLKkoQnJhm5aXJ3RQEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9Q(EnijuuMipdtnJWUgaNYlDns9fhtVSXwV0iMaXJZLKkoQnJhm5jYiqV07qG71GKqrzI8lognJWUgaNYlDnsTy2l59QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvV0iMaXJZLKkoQnJhm5jYiqV0R67LSb0RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0R67LSbqmk0dgoXy(DuhvTz8GjXrOgso4eGMyeDrzIaeSMyKMWdtOqmAqsOOmrE8Vcea1rvtJycepEHyuOhmCIXIfSEq3wBgpysCeQHKVLa0eJOlkteGG1eJc9GHtmAMybDkQJQMb6aeJayHMqZdgoX4arb71my69IElScFev3G9kEVi7xk9kk9c9EplSxhz)6LgXeiE8EFGoq8yCVFFILsVK(kHI37zHEVHpF1lWpHUDVssfh71mEWSxGp27f9Afp9YiU0R13TZx9Mcau8R3IPKK2lSqmst4HjuigpzI(XZVJ6OQnJhm5OlkteOxv9Q8RvUKuXrTz8Gj)B2RQEv(1kp)oQJQ2mEWKNiJa9sVd1RnfGZiStCeQHKQdcqtmIUOmracwtmst4HjuigbqLFTYV4tT0rvFwOMrSH8VzVQ6fav(1k)Ip1shv9zHAgXgYtKrGEP3H6vOhmCUKuXrndSuGtSWr2r6)q9bzWEv17G6Lggqx8Jt6RekoXOqpy4eJMjwqNI6OQzGoaXrOgsoqjanXi6IYebiynXinHhMqHyu5xR887OoQAZ4bt(3Sxv9Q8RvE(DuhvTz8Gjprgb6LEhQxBkaNryVxv9sJycepohneu5GHZtuaE1RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0RQEhuV0Wa6IFCsFLqXjgf6bdNy0mXc6uuhvnd0bioIJyeaRYFEeGMqnKraAIrHEWWjgPX3pmlM4CsmIUOmracwtCeQHKeGMyeDrzIaeSMyKMWdtOqmYsVNmr)4OpH2wh6iahDrzIa9QQxgXfUj96DiW9omdOxv9YiUWnPxVQhCVQJ32l59YgB9YsVdQ3tMOFC0NqBRdDeGJUOmrGEv1lJ4c3KE9oe4EhM32l5eJc9GHtmYiUOTrgIJqnKabOjgrxuMiabRjgPj8WekeJk)ALljvCuBgpyY)MeJc9GHtmAghmCIJqndobOjgrxuMiabRjgPj8WekeJ53XAK2i)qgZiLP(rsto6IYeb6vvVk)ALJSBj)YbdN)n7vvVS0lnIjq84CjPIJAZ4btEIcWREzJTEvIsPxv9wH2wNorgb6LEhcCVd(a6LCIrHEWWjgpidQFK0K4iuZBjanXi6IYebiynXinHhMqHyu5xRCjPIJAZ4btoq849QQxLFTYZVJ6OQnJhm5aXJ3RQEbqLFTYV4tT0rvFwOMrSHCG4Xjgf6bdNyCcTTUIEG8dyZG(rCeQrDqaAIr0fLjcqWAIrAcpmHcXOYVw5ssfh1MXdMCG4X7vvVk)ALNFh1rvBgpyYbIhVxv9cGk)ALFXNAPJQ(SqnJyd5aXJtmk0dgoXOIyRJQ(siL0cXrOMbkbOjgrxuMiabRjgPj8WekeJk)ALljvCuBgpyY)MeJc9GHtmQGzbtsHUnXrOMHHa0eJOlkteGG1eJ0eEycfIrLFTYLKkoQnJhm5FtIrHEWWjgvMraOR)8fXrOg1fbOjgrxuMiabRjgPj8WekeJk)ALljvCuBgpyY)MeJc9GHtmwHjQmJaG4iudzdGa0eJOlkteGG1eJ0eEycfIrLFTYLKkoQnJhm5FtIrHEWWjgfNILlLPMkZjXrOgYiJa0eJOlkteGG1eJ0eEycfIrLFTYLKkoQnJhm5FtIrHEWWjg)fudpKPqCeQHmssaAIr0fLjcqWAIrxyqIXcvYIoQ6AkhMUm1LlHvKyuOhmCIXcvYIoQ6AkhMUm1LlHvK4iudzKabOjgrxuMiabRjgf6bdNy0Ekaq5ISOveaBKyKMWdtOqmQ8RvUKuXrTz8Gj)B2lBS1lnIjq84CjPIJAZ4btEImc0l9QEW9(232RQEbqLFTYV4tT0rvFwOMrSH8VjXiwRi90UWGeJ2tbakxKfTIayJehHAiBWjanXi6IYebiynXOqpy4eJmr4t4PntyHHyKMWdtOqmsddOl(Xj9vcfVxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxYgqVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUxYgaXOlmiXite(eEAZewyioc1q2BjanXi6IYebiynXOqpy4eJmr4t4PntyHHyKMWdtOqmoOEPHb0f)4K(kHI3RQEPrmbIhNljvCuBgpyYtKrGEP3Ha3R6Oxv9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3R6Oxv9EqgSx13ljmGEv1ll9oOEPHb0f)4gq)SEL9YgB9k0dAa1OJmqS07q9AqsOOmrUeO(K0gpnn((1l5eJUWGeJmr4t4PntyHH4iudzQdcqtmIUOmracwtmk0dgoXiYy(krzQJeWfNIeJ0eEycfIrAetG4X5ssfh1MXdM8ezeOx6DiW9s2B7vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx6DiW9s2BjgDHbjgrgZxjktDKaU4uK4iudzducqtmIUOmracwtmk0dgoXiqIcqfMO2awk4KyKMWdtOqmsJycepoxsQ4O2mEWKNiJa9sVQhCVKCa9YgB9oOEnijuuMixm1HR)fSxW9swVSXwVS07bzWEb37a6vvVgKekktKxHflOBRdt0XSxW9swVQ6n)owJ0g5fOPv46YfjdhDrzIa9soXOlmiXiqIcqfMO2awk4K4iudzddbOjgrxuMiabRjgf6bdNySe)PgA7WdtIrAcpmHcXinIjq84CjPIJAZ4btEImc0l9QEW9scdOx2yR3b1RbjHIYe5IPoC9VG9cUxYigDHbjglXFQH2o8WK4iudzQlcqtmIUOmracwtmk0dgoXO98LPLoQAPuGmWPCWWjgPj8WekeJ0iMaXJZLKkoQnJhm5jYiqV0R6b3ljhqVSXwVdQxdscfLjYftD46Fb7fCVK1lBS1ll9EqgSxW9oGEv1RbjHIYe5vyXc626WeDm7fCVK1RQEZVJ1iTrEbAAfUUCrYWrxuMiqVKtm6cdsmApFzAPJQwkfidCkhmCIJqnKCaeGMyeDrzIaeSMyuOhmCIrgHkkjQlwiEAMFbsjgPj8WekeJ0iMaXJZLKkoQnJhm5jYiqV07qG79T9QQxw6Dq9AqsOOmrEfwSGUTomrhZEb3lz9YgB9EqgSx13ljmGEjNy0fgKyKrOIsI6IfINM5xGuIJqnKKmcqtmIUOmracwtmk0dgoXiJqfLe1flepnZVaPeJ0eEycfIrAetG4X5ssfh1MXdM8ezeOx6DiW9(2Ev1RbjHIYe5vyXc626WeDm7fCVK1RQEv(1kp)oQJQ2mEWK)n7vvVk)ALNFh1rvBgpyYtKrGEP3Ha3ll9s2a6LvS3327aR387ynsBKxGMwHRlxKmC0fLjc0l59QQ3dYG9ouVKWaigDHbjgzeQOKOUyH4Pz(fiL4iudjjjbOjgrxuMiabRjgf6bdNySyjaXdcOJurhv9fjd6hXinHhMqHy8GmyVG7Da9YgB9YsVgKekktKh)RabqDu10iMaXJx6vvVS0ll9sddOl(Xj9vcfVxv9sJycepopfaO4NUykjP8ezeOx6DiW9sYEv1lnIjq84CjPIJAZ4btEImc0l9oe4EFBVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbU332l59YgB9sJycepoxsQ4O2mEWKNiJa9sVdbUxs2lBS1BfABD6ezeOx6DOEPrmbIhNljvCuBgpyYtKrGEPxY7LCIrxyqIXILaepiGosfDu1xKmOFehHAijjqaAIr0fLjcqWAIraSqtO5bdNy8TC1rVWsVNf2BXerGEJAVNf27y8Nt8oOB3lR0x5vVMzmqI0dorIrxyqIXs8Nt8oOBRZVYlIrAcpmHcXil9AqsOOmr(bzq93p4ulM9(EVS0Rqpy48uaGIF6IPKKYr2r6)q9bzWEhy9sddOl(Xj9vcfVxY799EzPxHEWW5aOCwkr6ihzhP)d1hKb7DG1lnmGU4h3rAgZib6L8EFVxHEWW5x8Pw6OQpluZi2qoYos)hQpid27q9EsAJhhawoXPyVGQ33Yvh9sEVQ6LLEnijuuMi3smG6WeDeOx2yRxw6Lggqx8Jt6RekEVQ6n)owJ0g5ssfh1qVcD49IJUOmrGEjVxY7vvVNK24XbGLtCk2R67LKVLyuOhmCIXs8Nt8oOBRZVYlIJqnKCWjanXi6IYebiynXinHhMqHyKggqx8JBa9Z6v2RQEZVJ1iTrEbAAfUUCrYWrxuMiqVQ69Kj6hxsQ4OgPwbhDrzIa9QQxHEqdOgDKbILEvp4EnijuuMixcuFsAJNMgF)iglxcPhHAiJyuOhmCIrQmNAHEWW1ty5igNWYPDHbjgnibsCeQHKVLa0eJOlkteGG1eJ0eEycfIrHEqdOgDKbILEvp4EnijuuMixcuFsAJNMgF)iglxcPhHAiJyuOhmCIrQmNAHEWW1ty5igNWYPDHbjgLajoc1qs1bbOjgrxuMiabRjgPj8WekeJ0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiaXy5si9iudzeJc9GHtmsL5ul0dgUEclhX4ewoTlmiXOLKmH)I4iudjhOeGMyeDrzIaeSMyKMWdtOqmAqsOOmrULya1Hj6iqVG7Da9QQxdscfLjYRWIf0T1Hj6y2RQEhuVS0lnmGU4hN0xju8Ev1B(DSgPnYLKkoQTKKj8xC0fLjc0l5eJLlH0JqnKrmk0dgoXivMtTqpy46jSCeJty50UWGeJvyXc626WeDmjoc1qYHHa0eJOlkteGG1eJ0eEycfIrdscfLjYTedOomrhb6fCVdOxv9oOEzPxAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxYjglxcPhHAiJyuOhmCIrQmNAHEWW1ty5igNWYPDHbjgdt0XK4iudjvxeGMyeDrzIaeSMyKMWdtOqmoOEzPxAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxYjglxcPhHAiJyuOhmCIrQmNAHEWW1ty5igNWYPDHbjgPrmbIhVqCeQHegabOjgrxuMiabRjgPj8WekeJgKekktKxHUm1k)07fCVdOxv9oOEzPxAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxYjglxcPhHAiJyuOhmCIrQmNAHEWW1ty5igNWYPDHbjgZ4KdgoXrOgsGmcqtmIUOmracwtmst4HjuignijuuMiVcDzQv(P3l4EjRxv9oOEzPxAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxYjglxcPhHAiJyuOhmCIrQmNAHEWW1ty5igNWYPDHbjgRqxMALF6ehXrmAMinyuKJa0eQHmcqtmk0dgoXOKuXrn0pCor6rmIUOmracwtCeQHKeGMyuOhmCIXYNHjCTKuXrDvyGtOKeJOlkteGG1ehHAibcqtmk0dgoXin8bYFIAgXfTnYqmIUOmracwtCeQzWjanXOqpy4eJmWmJudzeBKyeDrzIaeSM4iuZBjanXi6IYebiynXinHhMqHySe)Pc0b4gIPCWjQlX0a6hhDrzIa9YgB9wI)ub6aCZF5(tuJ538GHZrxuMiaXOqpy4eJ1jwSOPupIJqnQdcqtmIUOmracwtmst4HjuigPHb0f)4K(kHI3RQEZVJ1iTrUKuXrTLKmH)IJUOmrGEv1lnCGp84ssfh1MzaaTFXrxuMiqVQ61GKqrzICz(iVk6YlNQPrmbIhV0RQEf6bnGA0rgiw6DOEnijuuMixcuFsAJNMgF)igf6bdNym)oQJQ2mEWK4iuZaLa0eJOlkteGG1eJ0eEycfIXb1RbjHIYe5MjA(NtnAi6fCVK1RQEZVJ1iTroaSqHMtOl5lnnyyehGJUOmraIrHEWWjgRzuoLyEehHAggcqtmIUOmracwtmst4HjuighuVgKekktKBMO5Fo1OHOxW9swVQ6Dq9MFhRrAJCayHcnNqxYxAAWWioahDrzIa9QQxw6Dq9sddOl(XnG(z9k7Ln261GKqrzI8kSybDBDyIoM9soXOqpy4eJssfh1ktPCehHAuxeGMyeDrzIaeSMyKMWdtOqmoOEnijuuMi3mrZ)CQrdrVG7LSEv17G6n)owJ0g5aWcfAoHUKV00GHrCao6IYeb6vvV0Wa6IFCdOFwVYEv17G61GKqrzI8kSybDBDyIoMeJc9GHtmYaZmYIoQ6lsg0pIJqnKnacqtmIUOmracwtmst4HjuignijuuMi3mrZ)CQrdrVG7LmIrHEWWjgrdbvoy4ehXrmkbsaAc1qgbOjgrxuMiabRjgPj8WekeJ53XAK2ihawOqZj0L8LMgmmIdWrxuMiqVQ6LgXeiECUYVw1aWcfAoHUKV00GHrCaEIcWREv1RYVw5aWcfAoHUKV00GHrCaDnJYXbIhVxv9YsVk)ALljvCuBgpyYbIhVxv9Q8RvE(DuhvTz8GjhiE8Ev1laQ8Rv(fFQLoQ6Zc1mInKdepEVK3RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0l4EhqVQ6LLEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5sG6lognJWUMAjPnw6vvVS0ll9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECE(DuhvTz8Gjprgb6LEhcCV2uGEv1lnIjq84CjPIJAZ4btEImc0l9Q(EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwVS07G69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9Q(EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwV0iMaXJZLKkoQnJhm5jYiqV07qG71Mc0l59soXOqpy4eJ1mkNsmpIJqnKKa0eJOlkteGG1eJ0eEycfIrw6n)owJ0g5aWcfAoHUKV00GHrCao6IYeb6vvV0iMaXJZv(1QgawOqZj0L8LMgmmIdWtuaE1RQEv(1khawOqZj0L8LMgmmIdORWe5aXJ3RQEnt0G2McWjJxZOCkX86L8EzJTEzP387ynsBKdaluO5e6s(stdggXb4OlkteOxv9EqgSxW9oGEjNyuOhmCIXkmrTYukhXrOgsGa0eJOlkteGG1eJ0eEycfIX87ynsBKBNWY8LgsH0jYrxuMiqVQ6LgXeiECUKuXrTz8Gjprgb6LEvFVKWa6vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx6fCVdOxv9YsVk)ALljvCutTK0g5LtOK27qG71GKqrzICjq9fhJMryxtTK0gl9QQxw6LLEpzI(XZVJ6OQnJhm5OlkteOxv9sJycepop)oQJQ2mEWKNiJa9sVdbUxBkqVQ6LgXeiECUKuXrTz8Gjprgb6LEvFVgKekktKFXXOze21a4uEPRrQfZEjVx2yRxw6Dq9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECUKuXrTz8Gjprgb6LEvFVgKekktKFXXOze21a4uEPRrQfZEjVx2yRxAetG4X5ssfh1MXdM8ezeOx6DiW9Atb6L8EjNyuOhmCIXAgLt7HbH4iuZGtaAIr0fLjcqWAIrAcpmHcXy(DSgPnYTtyz(sdPq6e5OlkteOxv9sJycepoxsQ4O2mEWKNiJa9sVG7Da9QQxw6LLEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9Q(EnijuuMixm1mc7AaCkV01i1xCm9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7L8EzJTEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9cU3b0RQEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5sG6lognJWUMAjPnw6L8EjVxv9Q8RvE(DuhvTz8GjhiE8EjNyuOhmCIXAgLt7HbH4iuZBjanXi6IYebiynXOqpy4eJssfh1mWsboXcXi1sGoXizeJ0eEycfIrAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxv9Q8RvUKuXrTLKmH)IxoHsAVd1lzVTxv9sJycepopfaO4NUykjP8ezeOx6DiW9AqsOOmrULKmH)sxoHsQ(GmyVV3lYos)hQpid2RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG71GKqrzICljzc)LUCcLu9bzWEFVxKDK(puFqgS337vOhmCEkaqXpDXuss5i7i9FO(GmyVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVgKekktKBjjt4V0LtOKQpid2779ISJ0)H6dYG9(EVc9GHZtbak(PlMsskhzhP)d1hKb799Ef6bdNFXNAPJQ(SqnJyd5i7i9FO(GmiXrOg1bbOjgrxuMiabRjgf6bdNyusQ4OMbwkWjwigPwc0jgjJyKMWdtOqmsddOl(XnG(z9k7vvV53XAK2ixsQ4Og6vOdVxC0fLjc0RQEv(1kxsQ4O2ssMWFXlNqjT3H6LS32RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG71GKqrzICljzc)LUCcLu9bzWEFVxKDK(puFqgSxv9sJycepoxsQ4O2mEWKNiJa9sVdbUxdscfLjYTKKj8x6Yjus1hKb799Er2r6)q9bzWEFVxHEWW5x8Pw6OQpluZi2qoYos)hQpidsCeQzGsaAIr0fLjcqWAIrAcpmHcXinmGU4h3a6N1RSxv9EYe9JljvCuJuRGJUOmrGEv17bzWEhQxYgqVQ6LgXeiECodmZil6OQVizq)4jYiqV0RQEv(1kNorjPs5GUnVCcL0EhQxsGyuOhmCIrjPIJALPuoIJqnddbOjgrxuMiabRjgf6bdNySe)5eVd6268R8IyKMWdtOqmMFhRrAJ8c00kCD5IKHJUOmrGEv1RzIg02uaozC0qqLdgoXOlmiXyj(ZjEh0T15x5fXrOg1fbOjgrxuMiabRjgPj8WekeJ53XAK2iVanTcxxUiz4OlkteOxv9AMObTnfGtghneu5GHtmk0dgoX4fFQLoQ6Zc1mInK4iudzdGa0eJOlkteGG1eJ0eEycfIX87ynsBKxGMwHRlxKmC0fLjc0RQEzPxZenOTPaCY4OHGkhm8EzJTEnt0G2McWjJFXNAPJQ(SqnJyd7LCIrHEWWjgLKkoQnJhmjoc1qgzeGMyeDrzIaeSMyKMWdtOqmMFhRrAJCjPIJAOxHo8EXrxuMiqVQ6LgXeiEC(fFQLoQ6Zc1mInKNiJa9sVdbUxYgqVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVK9wIrHEWWjgzGzgzrhv9fjd6hXrOgYijbOjgrxuMiabRjgPj8WekeJ0iMaXJZLKkoQnJhm5jYiqV07qG7Dy6vvV0iMaXJZV4tT0rvFwOMrSH8ezeOx6DiW9om9QQxw6v5xRCjPIJAQLK2iVCcL0EhcCVgKekktKlbQV4y0mc7AQLK2yPxv9YsVS07jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X553rDu1MXdM8ezeOx6DiW9Atb6vvV0iMaXJZLKkoQnJhm5jYiqV0R679T9sEVSXwVS07G69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9Q(EFBVK3lBS1lnIjq84CjPIJAZ4btEImc0l9oe4ETPa9sEVKtmk0dgoXidmZil6OQVizq)ioc1qgjqaAIr0fLjcqWAIrAcpmHcX4bzWEvFVKWa6vvV53XAK2iVanTcxxUiz4OlkteOxv9sddOl(XnG(z9k7vvVMjAqBtb4KXzGzgzrhv9fjd6hXOqpy4eJOHGkhmCIJqnKn4eGMyeDrzIaeSMyKMWdtOqmEqgSx13ljmGEv1B(DSgPnYlqtRW1Llsgo6IYeb6vvVk)ALljvCutTK0g5LtOK27qG71GKqrzICjq9fhJMryxtTK0gl9QQxAetG4X5x8Pw6OQpluZi2qEImc0l9cU3b0RQEPrmbIhNljvCuBgpyYtKrGEP3Ha3RnfGyuOhmCIr0qqLdgoXrOgYElbOjgrxuMiabRjgf6bdNyeneu5GHtmc9dZ8BEAyLyu5xR8c00kCD5IKHxoHskyLFTYlqtRW1LlsgoJWUUCcLuIrOFyMFZtdzyqaOCiXizeJ0eEycfIXdYG9Q(EjHb0RQEZVJ1iTrEbAAfUUCrYWrxuMiqVQ6LgXeiECUKuXrTz8Gjprgb6LEb37a6vvVS0ll9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx6v99AqsOOmrUyQze21a4uEPRrQV4y6vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2l59YgB9YsV0iMaXJZV4tT0rvFwOMrSH8ezeOx6fCVdOxv9Q8RvUKuXrn1ssBKxoHsAVdbUxdscfLjYLa1xCmAgHDn1ssBS0l59sEVQ6v5xR887OoQAZ4btoq849soXrOgYuheGMyeDrzIaeSMyuOhmCIXs8Nt8oOBRZVYlIrAcpmHcXinIjq848uaGIF6IPKKYtuaE1RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG71McWze27vvV0iMaXJZLKkoQnJhm5jYiqV07qG71McWze2jgDHbjglXFoX7GUTo)kVioc1q2aLa0eJOlkteGG1eJ0eEycfIrAetG4X5x8Pw6OQpluZi2qEImc0l9ouVi7i9FO(GmyVQ6LLEzP3tMOF887OoQAZ4bto6IYeb6vvV0iMaXJZZVJ6OQnJhm5jYiqV07qG71Mc0RQEPrmbIhNljvCuBgpyYtKrGEPx13RbjHIYe5xCmAgHDnaoLx6AKAXSxY7Ln26LLEhuVNmr)453rDu1MXdMC0fLjc0RQEPrmbIhNljvCuBgpyYtKrGEPx13RbjHIYe5xCmAgHDnaoLx6AKAXSxY7Ln26LgXeiECUKuXrTz8Gjprgb6LEhcCV2uGEjNyuOhmCIXuaGIF6IPKKsCeQHSHHa0eJOlkteGG1eJ0eEycfIrAetG4X5ssfh1MXdM8ezeOx6DOEr2r6)q9bzWEv1ll9YsVS0lnIjq848l(ulDu1NfQzeBiprgb6LEvFVgKekktKlMAgHDnaoLx6AK6loMEv1RYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9sEVSXwVS0lnIjq848l(ulDu1NfQzeBiprgb6LEb37a6vvVk)ALljvCutTK0g5LtOK27qG71GKqrzICjq9fhJMryxtTK0gl9sEVK3RQEv(1kp)oQJQ2mEWKdepEVKtmk0dgoXykaqXpDXussjoc1qM6Ia0eJOlkteGG1eJ0eEycfIrAetG4X5ssfh1MXdM8ezeOx6fCVdOxv9YsVS0ll9sJycepo)Ip1shv9zHAgXgYtKrGEPx13RbjHIYe5IPMryxdGt5LUgP(IJPxv9Q8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHsAVK3lBS1ll9sJycepo)Ip1shv9zHAgXgYtKrGEPxW9oGEv1RYVw5ssfh1uljTrE5ekP9oe4EnijuuMixcuFXXOze21uljTXsVK3l59QQxLFTYZVJ6OQnJhm5aXJ3l5eJc9GHtmcGYzPePJehHAi5aianXi6IYebiynXOqpy4eJL4pN4Dq3wNFLxeJ0eEycfIrw6v5xRCjPIJAQLK2iVCcL0EhcCVgKekktKlbQV4y0mc7AQLK2yPx2yRxZenOTPaCY4Paaf)0ftjjTxY7vvVS0ll9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECE(DuhvTz8Gjprgb6LEhcCV2uGEv1lnIjq84CjPIJAZ4btEImc0l9Q(EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwVS07G69Kj6hp)oQJQ2mEWKJUOmrGEv1lnIjq84CjPIJAZ4btEImc0l9Q(EnijuuMi)IJrZiSRbWP8sxJulM9sEVSXwV0iMaXJZLKkoQnJhm5jYiqV07qG71Mc0l59QQ3b1ll9wI)ub6aCSw)fObuloKr0cLItmLlso6IYeb6vvV53XAK2i3ssMWHunsTco6IYeb6LCIrxyqIXs8Nt8oOBRZVYlIJqnKKmcqtmIUOmracwtmst4HjuigPHb0f)4gq)SEL9QQ387ynsBKljvCud9k0H3lo6IYeb6vvV0iMaXJZzGzgzrhv9fjd6hprgb6LEhcCVVDaeJc9GHtmEXNAPJQ(SqnJydjoc1qsssaAIr0fLjcqWAIrAcpmHcXinmGU4h3a6N1RSxv9MFhRrAJCjPIJAOxHo8EXrxuMiqVQ6v5xRCgyMrw0rvFrYG(XtKrGEP3Ha3ljhqVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCV2uaIrHEWWjgV4tT0rvFwOMrSHehHAijjqaAIr0fLjcqWAIrAcpmHcXil9Q8RvUKuXrn1ssBKxoHsAVdbUxdscfLjYLa1xCmAgHDn1ssBS0lBS1RzIg02uaoz8uaGIF6IPKK2l59QQxw6LLEpzI(XZVJ6OQnJhm5OlkteOxv9sJycepop)oQJQ2mEWKNiJa9sVdbUxBkqVQ6LgXeiECUKuXrTz8Gjprgb6LEvFVgKekktKFXXOze21a4uEPRrQfZEjVx2yRxw6Dq9EYe9JNFh1rvBgpyYrxuMiqVQ6LgXeiECUKuXrTz8Gjprgb6LEvFVgKekktKFXXOze21a4uEPRrQfZEjVx2yRxAetG4X5ssfh1MXdM8ezeOx6DiW9Atb6L8Ev17G6LLElXFQaDaowR)c0aQfhYiAHsXjMYfjhDrzIa9QQ387ynsBKBjjt4qQgPwbhDrzIa9soXOqpy4eJx8Pw6OQpluZi2qIJqnKCWjanXi6IYebiynXinHhMqHyKLEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9Q(EnijuuMixm1mc7AaCkV01i1xCm9QQxLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7L8EzJTEzPxAetG4X5x8Pw6OQpluZi2qEImc0l9cU3b0RQEv(1kxsQ4OMAjPnYlNqjT3Ha3RbjHIYe5sG6lognJWUMAjPnw6L8EjVxv9Q8RvE(DuhvTz8GjhiE8Ev17G6LLElXFQaDaowR)c0aQfhYiAHsXjMYfjhDrzIa9QQ387ynsBKBjjt4qQgPwbhDrzIa9soXOqpy4eJssfh1MXdMehHAi5BjanXi6IYebiynXinHhMqHyu5xR887OoQAZ4btoq849QQxw6LLEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0R67LKdOxv9Q8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHsAVK3lBS1ll9sJycepo)Ip1shv9zHAgXgYtKrGEPxW9oGEv1RYVw5ssfh1uljTrE5ekP9oe4EnijuuMixcuFXXOze21uljTXsVK3l59QQxw6LgXeiECUKuXrTz8Gjprgb6LEvFVKrYEzJTEbqLFTYV4tT0rvFwOMrSH8VzVK3RQEhuVS0Bj(tfOdWXA9xGgqT4qgrlukoXuUi5OlkteOxv9MFhRrAJCljzchs1i1k4OlkteOxYjgf6bdNym)oQJQ2mEWK4iudjvheGMyeDrzIaeSMyKMWdtOqmsJycepoxsQ4OosfEImc0l9Q(EFBVSXwVdQ3tMOFCjPIJ6iv4OlkteGyuOhmCIXIfSEq3wBgpysCeQHKducqtmIUOmracwtmst4HjuiglXFQaDaowR)c0aQfhYiAHsXjMYfjhDrzIa9QQ387ynsBKBjjt4qQgPwbhDrzIa9QQxAetG4X5Paaf)0ftjjLNiJa9sVdbUxKDK(puFqgKyuOhmCIX87OoQAZ4btIJqnKCyianXi6IYebiynXinHhMqHySe)Pc0b4yT(lqdOwCiJOfkfNykxKC0fLjc0RQEZVJ1iTrULKmHdPAKAfC0fLjc0RQEzPxLFTYLKkoQPwsAJ8Yjus7v9G7LK9YgB9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3lYos)hQpid2l5eJc9GHtmMcau8txmLKuIJqnKuDraAIr0fLjcqWAIrAcpmHcXyj(tfOdWXA9xGgqT4qgrlukoXuUi5OlkteOxv9MFhRrAJCljzchs1i1k4OlkteOxv9AMObTnfGtgpfaO4NUykjPeJc9GHtmEXNAPJQ(SqnJydjoc1qcdGa0eJOlkteGG1eJ0eEycfIXs8NkqhGJ16VanGAXHmIwOuCIPCrYrxuMiqVQ6n)owJ0g5wsYeoKQrQvWrxuMiqVQ61mrdABkaNm(fFQLoQ6Zc1mInKyuOhmCIrjPIJAZ4btIJqnKazeGMyeDrzIaeSMyKMWdtOqmsddOl(Xj9vcfVxv9MFhRrAJCjPIJAOxHo8EXrxuMiqVQ6v5xRCjPIJAZ4bt(3Sxv9cGk)ALNcau8txmLKuTH)0XuuGt49IxoHsAVG7DW7vvVMjAqBtb4KXLKkoQJuPxv9k0dAa1OJmqS07q9oq7vvVdQ387ynsBKBjjt4qQgPwbhDrzIaeJc9GHtmkjvCuRmLYrCeQHeijbOjgrxuMiabRjgPj8WekeJ0Wa6IFCsFLqX7vvV53XAK2ixsQ4Og6vOdVxC0fLjc0RQEv(1kxsQ4O2mEWK)n7vvVaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOK2l4EhCIrHEWWjgLKkoQvKmfBK4iudjqceGMyeDrzIaeSMyKMWdtOqmsddOl(Xj9vcfVxv9MFhRrAJCjPIJAOxHo8EXrxuMiqVQ6v5xRCjPIJAZ4bt(3Sxv9YsVaXXtbak(PlMsskprgb6LEvFVQJEzJTEbqLFTYtbak(PlMssQ2WF6ykkWj8EX)M9sEVQ6fav(1kpfaO4NUykjPAd)PJPOaNW7fVCcL0EhQ3bVxv9k0dAa1OJmqS07q9(wIrHEWWjgLKkoQvMs5ioc1qcdobOjgrxuMiabRjgPj8WekeJ0Wa6IFCsFLqX7vvV53XAK2ixsQ4O2ssMWFXrxuMiqVQ6v5xRCjPIJAZ4bt(3Sxv9cGk)ALNcau8txmLKuTH)0XuuGt49IxoHsAVG7Leigf6bdNyusQ4OosfIJqnKWBjanXi6IYebiynXinHhMqHyKggqx8Jt6RekEVQ6n)owJ0g5ssfh1wsYe(lo6IYeb6vvVk)ALljvCuBgpyY)M9QQxau5xR8uaGIF6IPKKQn8NoMIcCcVx8Yjus7fCVKKyuOhmCIrjPIJAfjtXgjoc1qcQdcqtmIUOmracwtmst4HjuigPHb0f)4K(kHI3RQEZVJ1iTrUKuXrTLKmH)IJUOmrGEv1RYVw5ssfh1MXdM8VzVQ61mrdABkaNK8uaGIF6IPKK2RQEf6bnGA0rgiw6v99sceJc9GHtmkjvCuJSBoJcmCIJqnKWaLa0eJOlkteGG1eJ0eEycfIrAyaDXpoPVsO49QQ387ynsBKljvCuBjjt4V4OlkteOxv9Q8RvUKuXrTz8Gj)B2RQEbqLFTYtbak(PlMssQ2WF6ykkWj8EXlNqjTxW9swVQ6vOh0aQrhzGyPx13ljqmk0dgoXOKuXrnYU5mkWWjoc1qcddbOjgrxuMiabRjgPj8WekeJ53XAK2i3ssMWHunsTco6IYeb6vvVaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOK2l4EjJyuOhmCIrjPIJAKDZzuGHtCeQHeuxeGMyeDrzIaeSMyKMWdtOqmMFhRrAJCljzchs1i1k4OlkteOxv9YsVMjAqBtb4KXtbak(PlMssAVSXwVS0RzIg02uaoj5Paaf)0ftjjTxv9cGk)ALFXNAPJQ(SqnJyd5FZEjVxYjgf6bdNyusQ4Ogz3Cgfy4ehHAg8bqaAIr0fLjcqWAIrAcpmHcXy(DSgPnYTKKjCivJuRGJUOmrGEv1laQ8RvEkaqXpDXuss1g(thtrboH3lE5ekP9cUxsGyuOhmCIrjPIJ6ivioc1m4KraAIr0fLjcqWAIrAcpmHcXOYVw50jkjvkh0T5jk0Rxv9EYe9JljvCuJuRGJUOmrGEv1laQ8Rv(fFQLoQ6Zc1mInK)njgf6bdNyusQ4OMbwkWjwioc1m4KKa0eJOlkteGG1eJ0eEycfIrLFTYbq5SuI0r(3Sxv9cGk)ALFXNAPJQ(SqnJyd5FZEv1laQ8Rv(fFQLoQ6Zc1mInKNiJa9sVdbUxLFTYntSGof1rvZaDaoJWUUCcL0Ehy9k0dgoxsQ4OwzkLJJSJ0)H6dYG9QQxw6LLEpzI(XtSeU4uKJUOmrGEv1RqpObuJoYaXsVd17G3l59YgB9k0dAa1OJmqS07q9(2EjVxv9YsVdQ387ynsBKljvCuRemkscWG(XrxuMiqVSXwVNK24XTqzEwCt61R67LeEBVKtmk0dgoXOzIf0POoQAgOdqCeQzWjbcqtmIUOmracwtmst4Hjuigv(1khaLZsjsh5FZEv1ll9YsVNmr)4jwcxCkYrxuMiqVQ6vOh0aQrhzGyP3H6DW7L8EzJTEf6bnGA0rgiw6DOEFBVK3RQEzP3b1B(DSgPnYLKkoQvcgfjbyq)4OlkteOx2yR3tsB84wOmplUj96v99scVTxYjgf6bdNyusQ4OwzkLJ4iuZGp4eGMyuOhmCIXY3etpmieJOlkteGG1ehHAg83saAIr0fLjcqWAIrAcpmHcXOYVw5ssfh1uljTrE5ekP9QEW9YsVc9Ggqn6idel9Yk2lz9sEVQ6n)owJ0g5ssfh1kbJIKamOFC0fLjc0RQEpjTXJBHY8S4M0R3H6LeElXOqpy4eJssfh1ksMInsCeQzWvheGMyeDrzIaeSMyKMWdtOqmQ8RvUKuXrn1ssBKxoHsAVG7v5xRCjPIJAQLK2iNryxxoHskXOqpy4eJssfh1ksMInsCeQzWhOeGMyeDrzIaeSMyKMWdtOqmQ8RvUKuXrn1ssBKxoHsAVG7Da9QQxw6LgXeiECUKuXrTz8Gjprgb6LEvFVK92EzJTEhuVS0lnmGU4hN0xju8Ev1B(DSgPnYLKkoQTKKj8xC0fLjc0l59soXOqpy4eJssfh1rQqCeQzWhgcqtmIUOmracwtmst4HjuigzP3eRjwSeLj2lBS17G69GusHUDVK3RQEv(1kxsQ4OMAjPnYlNqjTxW9Q8RvUKuXrn1ssBKZiSRlNqjLyuOhmCIrhplm1hYyILJ4iuZGRUianXi6IYebiynXinHhMqHyu5xRC6eLKkLd628ef61RQEZVJ1iTrUKuXrTLKmH)IJUOmrGEv1ll9YsVNmr)4cJ5ewHu5GHZrxuMiqVQ6vOh0aQrhzGyP3H6Dy6L8EzJTEf6bnGA0rgiw6DOEFBVKtmk0dgoXOKuXrndSuGtSqCeQ5TdGa0eJOlkteGG1eJ0eEycfIrLFTYPtusQuoOBZtuOxVQ69Kj6hxymNWkKkhmCo6IYeb6vvVc9Ggqn6idel9ouVdoXOqpy4eJssfh1mWsboXcXrOM3sgbOjgrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK27q9Q8RvUKuXrn1ssBKZiSRlNqjLyuOhmCIrjPIJAKDZzuGHtCeQ5TKKa0eJOlkteGG1eJ0eEycfIrLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVMjAqBtb4KXLKkoQvKmfBKyuOhmCIrjPIJAKDZzuGHtCehXyyIoMeGMqnKraAIr0fLjcqWAIrAcpmHcXy(DSgPnYbGfk0CcDjFPPbdJ4aC0fLjc0RQEv(1khawOqZj0L8LMgmmIdORzuo(3KyuOhmCIXkmrTYukhXrOgssaAIr0fLjcqWAIrAcpmHcXy(DSgPnYTtyz(sdPq6e5OlkteOxv9YiUWnPxVQVx11Bjgf6bdNySMr50Eyqioc1qceGMyeDrzIaeSMy0fgKySe)5eVd6268R8IyuOhmCIXs8Nt8oOBRZVYlIJqndobOjgf6bdNyeaLZsjshjgrxuMiabRjoc18wcqtmIUOmracwtmst4Hjuigzex4M0Rx137GpaIrHEWWjgtbak(PlMsskXrOg1bbOjgf6bdNyKbMzKfDu1xKmOFeJOlkteGG1ehHAgOeGMyeDrzIaeSMyKMWdtOqmQ8RvUKuXrTz8GjhiE8Ev1lnIjq84CjPIJAZ4btEImc0leJc9GHtmwSG1d62AZ4btIJqnddbOjgrxuMiabRjgPj8WekeJ0iMaXJZLKkoQnJhm5jkaV6vvVk)ALljvCutTK0g5LtOK27q9Q8RvUKuXrn1ssBKZiSRlNqjLyuOhmCIrjPIJ6ivioc1OUianXi6IYebiynXinHhMqHyKggqx8JBa9Z6v2RQEPrmbIhNZaZmYIoQ6lsg0pEImc0l9Q(EhMbNyuOhmCIrjPIJALPuoIJqnKnacqtmk0dgoX4fFQLoQ6Zc1mInKyeDrzIaeSM4iudzKraAIrHEWWjgLKkoQnJhmjgrxuMiabRjoc1qgjjanXi6IYebiynXinHhMqHyu5xRCjPIJAZ4btoq84eJc9GHtmMFh1rvBgpysCeQHmsGa0eJOlkteGG1eJc9GHtmAMybDkQJQMb6aeJayHMqZdgoX4arb7DyJbEVx0BHv4JO6gSxX7fz)sP3blPIJ9Y6PuUEb(j0T79SWEbDCdCqnydBVpqhiE697tSu6n)UdD7EhSKko2R6e1k49Ykx7DWsQ4yVQtuROxyP3tMOFiGX9(G9sfhKR3Fb7DyJbEVpWZc69EwyVGoUboOgSHT3hOdep9(9jwk9(G9c9dZ8BE9EwyVd2aVxQL4oonU3s07dcYC2BrmG9cpoXinHhMqHyCq9EYe9JljvCuJuRGJUOmrGEv1laQ8Rv(fFQLoQ6Zc1mInK)n7vvVaOYVw5x8Pw6OQpluZi2qEImc0l9oe4EzPxHEWW5ssfh1ktPCCKDK(puFqgS3bwVk)ALBMybDkQJQMb6aCgHDD5ekP9soXrOgYgCcqtmIUOmracwtmk0dgoXOzIf0POoQAgOdqmcGfAcnpy4eJSY1Eh2yG3RLuCqUEvq079xqGEb(j0T79SWEbDCd8EFGoq8yCVpiiZzV)c2l869IElScFev3G9kEVi7xk9oyjvCSxwpLY1l079SWEzLIHfud2W27d0bIhoXinHhMqHyu5xRCjPIJAZ4bt(3Sxv9Q8RvE(DuhvTz8Gjprgb6LEhcCVS0Rqpy4CjPIJALPuooYos)hQpid27aRxLFTYntSGof1rvZaDaoJWUUCcL0EjN4iudzVLa0eJOlkteGG1eJ0eEycfIrG44Paaf)0ftjjLNiJa9sVQV332lBS1laQ8RvEkaqXpDXuss1g(thtrboH3lE5ekP9Q(EhaXOqpy4eJssfh1ktPCehHAitDqaAIr0fLjcqWAIrHEWWjgLKkoQvKmfBKyeal0eAEWWjghS5J8Q0lRLmfBSx569SWErhO3O27GnS9(yHEV53DOB37zH9oyjvCSx15KKj8x9orB0bK8fXinHhMqHyu5xRCjPIJAZ4bt(3Sxv9Q8RvUKuXrTz8Gjprgb6LEhQxBkqVQ6n)owJ0g5ssfh1wsYe(lo6IYebioc1q2aLa0eJOlkteGG1eJc9GHtmkjvCuRizk2iXiawOj08GHtmoyZh5vPxwlzk2yVY17zH9IoqVrT3Zc7Lvkg2EFGoq807Jf69MF3HUDVNf27GLuXXEvNtsMWF17eTrhqYxeJ0eEycfIrLFTYZVJ6OQnJhm5FZEv1RYVw5ssfh1MXdMCG4X7vvVk)ALNFh1rvBgpyYtKrGEP3Ha3RnfOxv9MFhRrAJCjPIJAljzc)fhDrzIaehHAiByianXi6IYebiynXi1sGoXizeJOKZxAQLaDnSsmQ8RvoDIssLYbDBn1sChNCG4XvXIYVw5ssfh1MXdM8VjBSXYGozI(XddyAgpyIaQyr5xR887OoQAZ4bt(3Kn2OrmbIhNJgcQCWW5jkaViNCYjgPj8WekeJaOYVw5x8Pw6OQpluZi2q(3Sxv9EYe9JljvCuJuRGJUOmrGEv1ll9Q8RvoakNLsKoYbIhVx2yRxHEqdOgDKbILEb3lz9sEVQ6fav(1k)Ip1shv9zHAgXgYtKrGEPx13Rqpy4CjPIJAgyPaNyHJSJ0)H6dYGeJc9GHtmkjvCuZalf4elehHAitDraAIr0fLjcqWAIrAcpmHcXOYVw50jkjvkh0T5LtOK2l4Ev(1kNorjPs5GUnNryxxoHsAVQ6Lggqx8JBa9Z6vsmk0dgoXOKuXrndSuGtSqCeQHKdGa0eJOlkteGG1eJc9GHtmkjvCuZalf4eleJulb6eJKrmst4Hjuigv(1kNorjPs5GUnprHE9QQxAetG4X5ssfh1MXdM8ezeOx6vvVS0RYVw553rDu1MXdM8VzVSXwVk)ALljvCuBgpyY)M9soXrOgssgbOjgrxuMiabRjgPj8WekeJk)ALljvCutTK0g5LtOK27qG71GKqrzI8lognJWUMAjPnwigf6bdNyusQ4OosfIJqnKKKeGMyeDrzIaeSMyKMWdtOqmQ8RvE(DuhvTz8Gj)B2lBS1lJ4c3KE9Q(Ej7TeJc9GHtmkjvCuRmLYrCeQHKKabOjgrxuMiabRjgf6bdNyeneu5GHtmc9dZ8BEAyLyKrCHBsp1dEyElXi0pmZV5PHmmiauoKyKmIrAcpmHcXOYVw553rDu1MXdMCG4X7vvVk)ALljvCuBgpyYbIhN4iudjhCcqtmk0dgoXOKuXrTIKPyJeJOlkteGG1ehXrmAjjt4VianHAiJa0eJOlkteGG1eJc9GHtmIgcQCWWjgbWcnHMhmCIrw5AVZ4P3W7LrCPxXb6LgXeiE8sVsI9sdgOB37304ETJEflua6vCGErdbXinHhMqHyKrCHBsVEhcCVKWa6vvVgKekktKh)RabqDu10iMaXJx6vvVS07jt0pE(DuhvTz8GjhDrzIa9QQxAetG4X553rDu1MXdM8ezeOx6DOEjBa9soXrOgssaAIr0fLjcqWAIraSqtO5bdNyuDh79r8R3l6TCcL0ETKKj8x9w)Z5lEVG2c79xWEJAVKPo6TCcL0sVwyI9cl9ErVcLgF)6TgzVNf27bPK27eRxVH37zH9sTe3XzVId07zH9Yalf4e7f69wNqBRJtmst4HjuigzPxdscfLjYlNqjvBjjt4V6Ln269GmyVd1lzdOxY7vvVk)ALljvCuBjjt4V4LtOK27q9sM6GyKAjqNyKmIrHEWWjgLKkoQzGLcCIfIJqnKabOjgrxuMiabRjgf6bdNyusQ4OMbwkWjwigbWcnHMhmCIr1Dl079xGUDVQtmMVsuM9QolbCXPOX9sLY1R0BfF6fz)sPxgyPaNyP3hl4e79rGh0T7TgzVNf2RYVw7vUEplS3Yj51Bu79SWERqBRJyKMWdtOqmIScFOPjcWrgZxjktDKaU4uSxv9EqgS3H6LegqVQ6LgXeiECoYy(krzQJeWfNI8ezeOx6v99sM6yy6vvVdQxHEWW5iJ5ReLPosaxCkYbGfrzIaehHAgCcqtmIUOmracwtmk0dgoXyj(ZjEh0T15x5fXinHhMqHyu5xRCjPIJAZ4bt(3Sxv9EsAJhhawoXPyVdbUxYgaXOlmiXyj(ZjEh0T15x5fXrOM3saAIr0fLjcqWAIrHEWWjglXFoX7GUTo)kVigPj8WekeJgKekktKJmMXdMiGwrYuSXEv1lnIjq848l(ulDu1NfQzeBiprgb6LEhcCVi7i9FO(GmyVQ6LgXeiECUKuXrTz8Gjprgb6LEhcCVS0lYos)hQpid27aRxs2l59QQ3tsB84aWYjof7v99s2aigDHbjglXFoX7GUTo)kVioc1OoianXi6IYebiynXinHhMqHy0GKqrzICKXmEWeb0ksMIn2RQEPrmbIhNFXNAPJQ(SqnJyd5jYiqV07qG7fzhP)d1hKb7vvV0iMaXJZLKkoQnJhm5jYiqV07qG7LLEr2r6)q9bzWEhy9sYEjVxv9YsVdQxKv4dnnraEj(ZjEh0T15x5vVSXwV0Wb(WJljvCuBMba0(fpfN0Evp4EFBVSXwVS0lnIjq848s8Nt8oOBRZVYlEImc0l9Q(EjJSb0RQEpjTXJdalN4uSx13lzdOxY7Ln26LLEPrmbIhNxI)CI3bDBD(vEXtKrGEP3Ha3lYos)hQpid2RQEpjTXJdalN4uS3Ha3lzdOxY7LCIrHEWWjgtbak(PlMsskXrOMbkbOjgrxuMiabRjgPj8WekeJgKekktKpq(lN(xqaDXuss7vvV0iMaXJZLKkoQnJhm5jYiqV07qG7fzhP)d1hKb7vvVS07G6fzf(qtteGxI)CI3bDBD(vE1lBS1lnCGp84ssfh1MzaaTFXtXjTx1dU332lBS1ll9sJycepoVe)5eVd6268R8INiJa9sVQVxYiBa9QQ3tsB84aWYjof7v99s2a6L8EzJTEzPxAetG4X5L4pN4Dq3wNFLx8ezeOx6DiW9ISJ0)H6dYG9QQ3tsB84aWYjof7DiW9s2a6L8EjNyuOhmCIXl(ulDu1NfQzeBiXrOMHHa0eJOlkteGG1eJ0eEycfIrZenOTPaCY4x8Pw6OQpluZi2qIrHEWWjgLKkoQnJhmjoc1OUianXi6IYebiynXinHhMqHy0GKqrzICKXmEWeb0ksMIn2RQEPrmbIhNNcau8txmLKuEImc0l9oe4Er2r6)q9bzWEv1RbjHIYe5hKb1F)GtTy2R6b3ljhqVQ6LLEhuV0Wb(WJljvCuBMba0(fhDrzIa9YgB9oOEnijuuMixMpYRIU8YPAAetG4Xl9YgB9sJycepo)Ip1shv9zHAgXgYtKrGEP3Ha3ll9ISJ0)H6dYG9oW6LK9sEVKtmk0dgoXy(DuhvTz8GjXrOgYgabOjgrxuMiabRjgPj8WekeJgKekktKJmMXdMiGwrYuSXEv1RzIg02uaoz887OoQAZ4btIrHEWWjgtbak(PlMsskXrOgYiJa0eJOlkteGG1eJ0eEycfIrdscfLjYhi)Lt)liGUykjP9QQ3b1RbjHIYe5wXea626logIrHEWWjgV4tT0rvFwOMrSHehHAiJKeGMyeDrzIaeSMyuOhmCIrjPIJAfjtXgjgbWcnHMhmCIXbIc2ljDGELKko2RIKPyJ9c9EhSH9Dwj1zdBVHpF1lS2lRNram)LRxXb6vUENOuUEjzVdF4LEnZGsraIrAcpmHcXOYVw5ssfh1uljTrE5ekP9cUxLFTYLKkoQPwsAJCgHDD5ekP9QQxLFTYZVJ6OQnJhm5FZEv1RYVw5ssfh1MXdM8VzVQ6v5xRCjPIJAljzc)fVCcL0Evp4EjtD0RQEv(1kxsQ4O2mEWKNiJa9sVdbUxHEWW5ssfh1ksMInYr2r6)q9bzWEv1RYVw5kZiaM)YX)MehHAiJeianXi6IYebiynXOqpy4eJ53rDu1MXdMeJayHMqZdgoX4arb7LKoqVSsXW2l07DWg2EdF(QxyTxwpJay(lxVId0lj7D4dV0RzguIrAcpmHcXOYVw553rDu1MXdMCG4X7vvVk)ALRmJay(lh)B2RQEzPxdscfLjYpidQ)(bNAXSx13ljmGEzJTEPrmbIhNNcau8txmLKuEImc0l9Q(EjJK9sEVQ6LLEv(1kxsQ4O2ssMWFXlNqjTx1dUxYEBVSXwVk)ALtNOKuPCq3MxoHsAVQhCVK1l59QQxw6Dq9sdh4dpUKuXrTzgaq7xC0fLjc0lBS17G61GKqrzICz(iVk6YlNQPrmbIhV0l5ehHAiBWjanXi6IYebiynXinHhMqHyu5xRCjPIJAZ4btoq849QQxw61GKqrzI8dYG6VFWPwm7v99scdOx2yRxAetG4X5Paaf)0ftjjLNiJa9sVQVxYizVK3RQEzP3b1lnCGp84ssfh1MzaaTFXrxuMiqVSXwVdQxdscfLjYL5J8QOlVCQMgXeiE8sVKtmk0dgoXy(DuhvTz8GjXrOgYElbOjgrxuMiabRjgPj8WekeJgKekktKJmMXdMiGwrYuSXEv1ll9Q8RvUKuXrn1ssBKxoHsAVQhCVKSx2yRxAetG4X5ssfh1rQWtuaE1l59QQxw6Dq9EYe9JNFh1rvBgpyYrxuMiqVSXwV0iMaXJZZVJ6OQnJhm5jYiqV0R679T9sEVQ6LgXeiECUKuXrTz8Gjprgb6fnYUjspeOx1dUxsya9QQxw6Dq9sdh4dpUKuXrTzgaq7xC0fLjc0lBS17G61GKqrzICz(iVk6YlNQPrmbIhV0l5eJc9GHtmMcau8txmLKuIJqnKPoianXi6IYebiynXOqpy4eJx8Pw6OQpluZi2qIraSqtO5bdNyuD3c9EZV7q3UxZmaG2VmU3Fb79IJPxLx9cVcoR9c9EJeaZEVOxzcT9EHxVpWZQxXKyKMWdtOqmAqsOOmr(bzq93p4ulM9ouVVDa9QQxdscfLjYpidQ)(bNAXSx13ljmGEv1ll9oOErwHp00eb4L4pN4Dq3wNFLx9YgB9sdh4dpUKuXrTzgaq7x8uCs7v9G79T9soXrOgYgOeGMyeDrzIaeSMyKMWdtOqmAqsOOmr(a5VC6Fbb0ftjjTxv9Q8RvUKuXrn1ssBKxoHsAVd1RYVw5ssfh1uljTroJWUUCcLuIrHEWWjgLKkoQJuH4iudzddbOjgrxuMiabRjgPj8WekeJaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOK2l4EbqLFTYtbak(PlMssQ2WF6ykkWj8EXze21LtOKsmk0dgoXOKuXrTIKPyJehHAitDraAIr0fLjcqWAIrAcpmHcXObjHIYe5dK)YP)feqxmLK0EzJTEzPxau5xR8uaGIF6IPKKQn8NoMIcCcVx8VzVQ6fav(1kpfaO4NUykjPAd)PJPOaNW7fVCcL0EhQxau5xR8uaGIF6IPKKQn8NoMIcCcVxCgHDD5ekP9soXOqpy4eJssfh1ktPCehHAi5aianXi6IYebiynXOqpy4eJssfh1ksMInsmcGfAcnpy4eJdefSxgOd7L1sMIn2RcEpi69Mcau8R3IPKKw6fw797ay2lRjXEFGNv8VEbWP8c629YkjaqXVEhnLK0EHaOmNVigPj8WekeJk)ALNFh1rvBgpyY)M9QQxLFTYLKkoQnJhm5aXJ3RQEv(1kxzgbW8xo(3Sxv9sJycepopfaO4NUykjP8ezeOx6DiW9s2a6vvVk)ALljvCuBjjt4V4LtOK2R6b3lzQdIJqnKKmcqtmIUOmracwtmk0dgoXOKuXrDKkeJayHMqZdgoX4arb7nsLEdVxkqVFFILsVIzVWsV0Gb629(n7TeHtmst4Hjuigv(1kxsQ4OMAjPnYlNqjT3H6Le6vvVgKekktKFqgu)9do1IzVQVxYgqVQ6LLEPrmbIhNFXNAPJQ(SqnJyd5jYiqV0R679T9YgB9oOEPHd8HhxsQ4O2mdaO9lo6IYeb6LCIJqnKKKeGMyeDrzIaeSMyuOhmCIrjPIJAgyPaNyHyKAjqNyKmIrAcpmHcXOYVw50jkjvkh0T5jk0Rxv9Q8RvUKuXrTz8Gj)BsCeQHKKabOjgrxuMiabRjgf6bdNyusQ4OwrYuSrIraSqtO5bdNyKvU27d2RnE9Agpy2l0R)cm8Eb(j0T7D(lxVpiiZzVwIbSx0JVTvVws5WEVOxB86nQ1ELElxgUDVksMIn2lWpHUDVNf2BgMGsm79b6aXdXinHhMqHyu5xR887OoQAZ4bt(3Sxv9Q8RvE(DuhvTz8Gjprgb6LEhcCVc9GHZLKkoQzGLcCIfoYos)hQpid2RQEv(1kxsQ4O2mEWK)n7vvVk)ALljvCutTK0g5LtOK2l4Ev(1kxsQ4OMAjPnYze21LtOK2RQEv(1kxsQ4O2ssMWFXlNqjTxv9Q8RvUz8GPg61Fbgo)B2RQEv(1kxzgbW8xo(3K4iudjhCcqtmIUOmracwtmk0dgoXOKuXrTYukhXiawOj08GHtmYkx79b71gVEnJhm7f61FbgEVa)e629o)LR3heK5SxlXa2l6X32QxlPCyVx0RnE9g1AVsVLld3UxfjtXg7f4Nq3U3Zc7ndtqjM9(aDG4X4ElrVpiiZzVHpF17VG9IE8TT6vzkLR0l0HhuMZx9ErV2417f9wJF2l1ssBSqmst4Hjuigv(1k3mXc6uuhvnd0b4FZEv1ll9Q8RvUKuXrn1ssBKxoHsAVd1RYVw5ssfh1uljTroJWUUCcL0EzJTEhuVS0RYVw5MXdMAOx)fy48VzVQ6v5xRCLzeaZF54FZEjVxY7vvVdQxw6v5xRCjPIJAQLK2iVCcL0Eb37a6vvVk)ALBMybDkQJQMb6a8Yjus7fCVK1l5ehHAi5BjanXi6IYebiynXOqpy4eJMjwqNI6OQzGoaXiawOj08GHtmcAlSxfSC9(lyVrTxZGPxyP3l69xWEHxVx0lRWhsjD(QxLpCc0l1ssBS0lWpHUDVIzVs9WS3ZcF1RnE9c8zmrGEvE17zH9Ajjt4V6vrYuSrIrAcpmHcXOYVw5ssfh1uljTrE5ekP9ouVk)ALljvCutTK0g5mc76Yjus7vvVk)ALljvCuBgpyY)MehHAiP6Ga0eJOlkteGG1eJayHMqZdgoXO6o27J4xVx0B5ekP9Ajjt4V6T(NZx8EbTf27VG9g1EjtD0B5ekPLETWe7fw69IEfkn((1BnYEplS3dsjT3jwVEdV3Zc7LAjUJZEfhO3Zc7LbwkWj2l07ToH2whNyuOhmCIrjPIJAgyPaNyHye6hM538igjJyKAjqNyKmIrAcpmHcXOYVw5ssfh1wsYe(lE5ekP9ouVKPoigH(Hz(npT9muKjXizehHAi5aLa0eJOlkteGG1eJ0eEycfIrLFTYLKkoQPwsAJ8Yjus7fCVk)ALljvCutTK0g5mc76Yjus7vvVgKekktKJmMXdMiGwrYuSrIrHEWWjgLKkoQvKmfBK4iudjhgcqtmIUOmracwtmst4Hjuigzex4M0R3H6LS3smk0dgoXiAiOYbdN4iudjvxeGMyeDrzIaeSMyuOhmCIrjPIJALPuoIraSqtO5bdNyuDMpF17VG9QmLY17f9Q8HtGEPwsAJLEH1EFWELzIcWRETedyVLGb7TMbtVrQqmst4Hjuigv(1kxsQ4OMAjPnYlNqjTxv9Q8RvUKuXrn1ssBKxoHsAVd1RYVw5ssfh1uljTroJWUUCcLuIJqnKWaianXi6IYebiynXiawOj08GHtmQoFW5S3h4z1RW073NyP0Ry2lS0lnyGUDVFZEfhO3heKe7Dgp9gEVmIleJc9GHtmkjvCuZalf4eleJq)Wm)MhXizeJulb6eJKrmst4HjuighuVS0RbjHIYe5hKb1F)GtTy27qG7LSb0RQEzex4M0R3H6LegqVKtmc9dZ8BEA7zOitIrYioc1qcKraAIr0fLjcqWAIraSqtO5bdNyCyZOcNyP3h4z17mE6LrkhMVmUxlOTvVws5qJ7nYEvIZQxg5vVEC9AjgWErp(2w9YiU07f9w(MMrE9Afp9YiU0l0p0lqdyVPaaf)6TykjP9sfVxf04ElrVpiiZzV)c2BfMyVktPC9koqV1mkNsmVEFSqV3z80B49YiUqmk0dgoXyfMOwzkLJ4iudjqscqtmk0dgoXynJYPeZJyeDrzIaeSM4ioIXk0LPw5NobOjudzeGMyeDrzIaeSMyuOhmCIrjPIJAgyPaNyHyKAjqNyKmIrAcpmHcXOYVw50jkjvkh0T5jk0J4iudjjanXOqpy4eJssfh1ktPCeJOlkteGG1ehHAibcqtmk0dgoXOKuXrTIKPyJeJOlkteGG1ehXrCeJgWSadNqnKCaKKKdGei7TeJps6q3UqmQUpySsQHvwnQBZQ92lOTWEHmMrE9wJSxqct0XeKEtKv4dteO3sWG9k)lyKdb6LAjUnw4TrKi0XEjJv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxsYQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2lzKaR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo582ise6yVKPoy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKELRx1j1zKyVSqg7KZBJirOJ9s2aLv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6vUEvNuNrI9YczStoVnIeHo2lzddR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo582O2i19bJvsnSYQrDBwT3EbTf2lKXmYR3AK9csfwSGUTomrhtq6nrwHpmrGElbd2R8VGroeOxQL42yH3grIqh7LmwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwij7KZBJirOJ9sswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwiJDY5TrKi0XEjbwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEhCwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEFlR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVduwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPx56vDsDgj2llKXo582ise6yVKn4SAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqs2jN3grIqh7LSbkR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVKCaSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9ssYy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7LKKaR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo582ise6yVKuDWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YcjzNCEBejcDSxsQoy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKELRx1j1zKyVSqg7KZBJirOJ9sYHHv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6vUEvNuNrI9YczStoVnIeHo2ljvxSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZBJAJu3hmwj1WkRg1Tz1E7f0wyVqgZiVERr2lizCYbdhKEtKv4dteO3sWG9k)lyKdb6LAjUnw4TrKi0XEjJv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCEBejcDSxsGv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCEBejcDS3bNv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCEBejcDS3HHv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCEBejcDSxYgOSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZBJirOJ9s2aLv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxYggwT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwiJDY5TrKi0XEjByy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7Lm1fR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKXo582ise6yVKPUy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7LKdGv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxssgR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582O2i19bJvsnSYQrDBwT3EbTf2lKXmYR3AK9ccawL)8aP3ezf(Web6TemyVY)cg5qGEPwIBJfEBejcDSxsYQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YcjzNCEBejcDS3bNv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxYgOSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9sM6Iv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxssgR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVKKey1EhE4gW8qGEhHmdV3Yl)e27vDE69IEjXV0la0aSadV3Wet5ISxwaf59YczStoVnIeHo2ljjbwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEj5GZQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YczStoVnIeHo2ljhCwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEjP6Gv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6vUEvNuNrI9YczStoVnIeHo2ljhOSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9sYHHv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxsQUy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7LegaR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVKazSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJAJu3hmwj1WkRg1Tz1E7f0wyVqgZiVERr2liMjsdgf5aP3ezf(Web6TemyVY)cg5qGEPwIBJfEBejcDS33YQ9o8WnG5Ha9csj(tfOdWvli9ErVGuI)ub6aC1YrxuMiai9YczStoVnIeHo27Bz1EhE4gW8qGEbPe)Pc0b4QfKEVOxqkXFQaDaUA5OlkteaKELRx1j1zKyVSqg7KZBJirOJ9Qoy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7vDWQ9o8WnG5Ha9ccnCGp84QfKEVOxqOHd8HhxTC0fLjcasVSqg7KZBJirOJ9oqz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKELRx1j1zKyVSqg7KZBJirOJ9omSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9QUy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3g1gPUpySsQHvwnQBZQ92lOTWEHmMrE9wJSxqKabP3ezf(Web6TemyVY)cg5qGEPwIBJfEBejcDSxYy1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHKStoVnIeHo2lzSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9sswT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwij7KZBJirOJ9scSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqs2jN3grIqh7Ley1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7DWz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh79TSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9Qoy1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7DGYQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YczStoVnIeHo27WWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2R6Iv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxYgaR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVKrgR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVKrswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZBJirOJ9sgjWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2lzdoR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVK9wwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEjBGYQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YcjzNCEBejcDSxsoawT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZBJirOJ9sYbWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2ljhaR27Wd3aMhc0liL4pvGoaxTG07f9csj(tfOdWvlhDrzIaG0llKXo582ise6yVKKmwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEjjjz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7LKKaR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKKDY5TrKi0XEjjjWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2ljjbwT3HhUbmpeOxqkXFQaDaUAbP3l6fKs8NkqhGRwo6IYebaPxwiJDY5TrKi0XEj5GZQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2ljhCwT3HhUbmpeOxqkXFQaDaUAbP3l6fKs8NkqhGRwo6IYebaPxwiJDY5TrKi0XEj5Bz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7LKVLv7D4HBaZdb6fKs8NkqhGRwq69IEbPe)Pc0b4QLJUOmraq6LfYyNCEBejcDSxsQoy1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKELRx1j1zKyVSqg7KZBJirOJ9sYbkR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVKCGYQ9o8WnG5Ha9csj(tfOdWvli9ErVGuI)ub6aC1YrxuMiai9YczStoVnIeHo2ljhgwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEj5WWQ9o8WnG5Ha9csj(tfOdWvli9ErVGuI)ub6aC1YrxuMiai9YczStoVnIeHo2ljvxSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9ss1fR27Wd3aMhc0liL4pvGoaxTG07f9csj(tfOdWvlhDrzIaG0llKXo582ise6yVKWay1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7LegaR27Wd3aMhc0liL4pvGoaxTG07f9csj(tfOdWvlhDrzIaG0llKXo582ise6yVKazSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9scKXQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9kxVQtQZiXEzHm2jN3grIqh7LeijR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVKajWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2ljm4SAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9scVLv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxsqDWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2ljmqz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7LeggwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEjb1fR27Wd3aMhc0li53XAK2ixTG07f9cs(DSgPnYvlhDrzIaG0llKXo582ise6yVd(ay1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7DWjJv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCEBejcDS3bNKSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZBJirOJ9o4KKv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDS3bNey1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHm2jN3grIqh7DWjbwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEh83YQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo27Gpqz1EhE4gW8qGEbj)owJ0g5QfKEVOxqYVJ1iTrUA5OlkteaKEzHm2jN3grIqh7DWvxSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZBJirOJ9o4QlwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEF7ay1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHm2jN3g1gPUpySsQHvwnQBZQ92lOTWEHmMrE9wJSxqSKKj8xG0BIScFyIa9wcgSx5FbJCiqVulXTXcVnIeHo2lzSAVdpCdyEiqVGCYe9JRwq69IEb5Kj6hxTC0fLjcasVSqg7KZBJirOJ9Qoy1EhE4gW8qGEb5sOtkECrHYPrmbIhhKEVOxqOrmbIhNlkuq6LfsYo582ise6yVduwT3HhUbmpeOxqUe6KIhxuOCAetG4XbP3l6feAetG4X5IcfKEzHKStoVnIeHo2R6Iv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3grIqh7LmsGv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3grIqh7LSbNv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3grIqh7LS3YQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YczStoVnIeHo2lzVLv7D4HBaZdb6feA4aF4Xvli9ErVGqdh4dpUA5OlkteaKEzHm2jN3grIqh7LKKXQ9o8WnG5Ha9ccnCGp84QfKEVOxqOHd8HhxTC0fLjcasVSqg7KZBJAJu3hmwj1WkRg1Tz1E7f0wyVqgZiVERr2li0iMaXJxaP3ezf(Web6TemyVY)cg5qGEPwIBJfEBejcDSxYy1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHKStoVnIeHo2lzSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9sswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZBJirOJ9sswT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEjbwT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZBJirOJ9scSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9o4SAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9(wwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEvhSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9oqz1EhE4gW8qGEbPe)Pc0b4QfKEVOxqkXFQaDaUA5OlkteaKEzHKStoVnIeHo27WWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2R6Iv7D4HBaZdb6fK87ynsBKRwq69IEbj)owJ0g5QLJUOmraq6LfYyNCEBejcDSxYgaR27Wd3aMhc0liNmr)4QfKEVOxqozI(XvlhDrzIaG0llKKDY5TrKi0XEjJmwT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwij7KZBJirOJ9sgjWQ9o8WnG5Ha9cYjt0pUAbP3l6fKtMOFC1YrxuMiai9YcjzNCEBejcDSxYgCwT3HhUbmpeOxqYVJ1iTrUAbP3l6fK87ynsBKRwo6IYebaPxwiJDY5TrKi0XEj7TSAVdpCdyEiqVGKFhRrAJC1csVx0li53XAK2ixTC0fLjcasVSqg7KZBJirOJ9sYbWQ9o8WnG5Ha9cs(DSgPnYvli9ErVGKFhRrAJC1YrxuMiai9YczStoVnIeHo2ljjJv7D4HBaZdb6fKtMOFC1csVx0liNmr)4QLJUOmraq6LfYyNCEBejcDSxssswT3HhUbmpeOxqozI(Xvli9ErVGCYe9JRwo6IYebaPxwiJDY5TrKi0XEj5Bz1EhE4gW8qGEb5Kj6hxTG07f9cYjt0pUA5OlkteaKEzHm2jN3g1gXkZyg5Ha9s2a6vOhm8ENWYv4TreJMzuHtKy8nVP3bUyJ9oyjvCSn6nVP3bU8QxsACVKCaKKKTrTrV5n9oClXTXcR2g9M30lRyVdefS37LjKkZEhHmdVxlXbMq3U3O2l1sChN9c9dZ8BEWW7f6LdfGEJAVGqfNItTqpy4GWBJEZB6LvS3HBjUn2RKuXrn0RqhEV69IELKkoQTKKj8x9Yc861rdy27d6xVtObSxP0RKuXrTLKmH)ICEB0BEtVSI9QUv4GC9QoziOYH9c9Ehm1zQt9oq(lxVkiv(fS3xXhKe7n(xVrT3uCBSxXb61JR3Fb629oyjvCSx1j2nNrbgoVn6nVPxwXEhmGbYF561mHrcVx9ErV)c27GLuXXEh24btqk9I1kspObSxAetG4X7vrkiqVH37Wv3IvQxSwr6v4TrV5n9Yk27arb7TCjKE9AMbflfOB37f9MiWNI9o8HDGO3dYG9c8XEVO3V7iflfjF17GnSKyV1ijTWBJEZB6LvS3bEyab61GKqrzIfqrLj9pLdgEP3l6Le)sVmbWFI9ErVjc8PyVdFyhi69GmiVnQnsOhm8c3mrAWOi37GbLKuXrn0pCor61gj0dgEHBMinyuK7DWGssQ4OUkmWjuY2iHEWWlCZePbJICVdgu0Whi)jQzex02itB0BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGLa1NK24PPX3pJdtWjwWZyaSk)5bMeAJEZB6vOhm8c3mrAWOi37GbLbjHIYen2fgemAi0M0Z4WeCIf8mgaRYFEGj7TTrV5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdc2mrZ)CQrdHXHj4cEgdRGzj)owJ0g5fOPv46YfjJkwOHb0f)4gq)SELSXgnmGU4h3rAgZibyJnA4aF4XLKkoQnZaaA)ICYn2Gm)iyYm2Gm)OgNfe8aAJEZB6vOhm8c3mrAWOi37GbLbjHIYen2fgeSLya1Hj6iGXHj4cEgdRGf6bnGA0rgiwupydscfLjYLa1NK24PPX3pJniZpcMmJniZpQXzbbpG2O38MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbxHUm1k)0nombxWZydY8JGhqB0BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGTKKj8x6Yjus1hKbnombNybpJbWQ8Nhy1vB0BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGL5J8QOlVCQMgXeiE8IXHj4el4zmawL)8apG2O38MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbNfnJWUgaNYlDns9fhJXHj4el4zmawL)8a)22O38MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbNfnJWUgaNYlDnsDgMghMGtSGNXayv(Zd8BBJEZB6vOhm8c3mrAWOi37GbLbjHIYen2fgeCw0mc7AaCkV01i1IPXHj4el4zmawL)8atYb0g9M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyM40MjsreqFXXOvEzCycoXcEgdGv5ppWdtB0BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGzItZiSRbWP8sxJuFXXyCycoXcEgdGv5ppWKnG2O38MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbZeNMryxdGt5LUgPwmnombNybpJbWQ8NhyYEBB0BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGftnJWUgaNYlDns9fhJXHj4el4zmScMgoWhECjPIJAZmaG2Vm2Gm)iysyagBqMFuJZccMSb0g9M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyXuZiSRbWP8sxJuFXXyCycoXcEgdGv5ppWKCaTrV5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdcwm1mc7AaCkV01i1mXzCycoXcEgdGv5ppWKCaTrV5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdcodtnJWUgaNYlDns9fhJXHj4cEgBqMFemjhaRilVDGrdh4dpUKuXrTzgaq7xK3g9M30Rqpy4fUzI0GrrU3bdkdscfLjASlmi4lognJWUgaNYlDnsTyACycUGNXgK5hb)23j5agySqddOl(XDOT1PRcYgBSqdh4dpUKuXrTzgaq7xQe6bnGA0rgiwgYGKqrzICjq9jPnEAA89JCYFNS3oWyHggqx8Jt6RekUQ87ynsBKljvCuBjjt4Vuj0dAa1OJmqSOEWgKekktKlbQpjTXttJVFK3g9M30Rqpy4fUzI0GrrU3bdkdscfLjASlmi4lognJWUgaNYlDnsDgMghMGl4zSbz(rWKCaSISmmdmA4aF4XLKkoQnZaaA)I82O38MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbRizk2OMrCrBspJdtWf8mgwbtddOl(XDOT1PRcASbz(rWQJbWkYcJuomFPniZpoWiBadG82O38MEf6bdVWntKgmkY9oyqzqsOOmrJDHbbRizk2OMrCrBspJdtWf8mgwbtddOl(Xj9vcf3ydY8JGvxVLvKfgPCy(sBqMFCGr2aga5TrV5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdcwrYuSrnJ4I2KEghMGl4zmSc2GKqrzICfjtXg1mIlAt6bEagBqMFe8WmawrwyKYH5lTbz(XbgzdyaK3g9M30Rqpy4fUzI0GrrU3bdkdscfLjASlmiyXuZaDiZNrZiUOnPNXHj4el4zmawL)8at2BBJEZB6vOhm8c3mrAWOi37GbLbjHIYen2fge8fhJMryxtTK0glghMGtSGNXayv(ZdmjBJEZB6vOhm8c3mrAWOi37GbLbjHIYen2fgeSeO(IJrZiSRPwsAJfJdtWjwWZyaSk)5bMKTrV5n9k0dgEHBMinyuK7DWGYGKqrzIg7cdcUclwq3whMOJPXHj4cEgBqMFemzdmwqwHp00eb4iJ5ReLPosaxCkYgBSCYe9JNFh1rvBgpyQILtMOFCjPIJAKAfSX2GOHb0f)4K(kHItUkwgenmGU4h3rAgZibyJnHEqdOgDKbIfWKXgB53XAK2iVanTcxxUizix1GOHb0f)4gq)SELKtEB0BEtVc9GHx4Mjsdgf5EhmOmijuuMOXUWGGftD46FbnombxWZydY8JGrwHp00eb4mcvusuxSq80m)cKYgBiRWhAAIaC7PaaLlYIwraSr2ydzf(qtteGBpfaOCrw0miGmNWWzJnKv4dnnraoGKKYeHRbqkPAZ)LyHIofzJnKv4dnnrao0l08FIYe1ScFXVpJganaPiBSHScFOPjcWlXFoX7GUTo)kVyJnKv4dnnraE57kZia0cdEwVkhBSHScFOPjcWFesrhZIUMHdWgBiRWhAAIa86uyqDu1kYDtSnsOhm8c3mrAWOi37GbfdmZi1qgXgBJe6bdVWntKgmkY9oyqvNyXIMs9mgwbxI)ub6aCdXuo4e1LyAa9Jn2kXFQaDaU5VC)jQX8BEWWBJe6bdVWntKgmkY9oyqLFh1rvBgpyAmScMggqx8Jt6RekUQ87ynsBKljvCuBjjt4Vurdh4dpUKuXrTzgaq7xQmijuuMixMpYRIU8YPAAetG4XlQe6bnGA0rgiwgYGKqrzICjq9jPnEAA89RnsOhm8c3mrAWOi37GbvnJYPeZZyyf8GmijuuMi3mrZ)CQrdbyYuLFhRrAJCayHcnNqxYxAAWWioqBKqpy4fUzI0GrrU3bdkjPIJALPuoJHvWdYGKqrzICZen)ZPgneGjt1GYVJ1iTroaSqHMtOl5lnnyyehqfldIggqx8JBa9Z6vYgBgKekktKxHflOBRdt0XK82iHEWWlCZePbJICVdgumWmJSOJQ(IKb9Zyyf8GmijuuMi3mrZ)CQrdbyYunO87ynsBKdaluO5e6s(stdggXburddOl(XnG(z9kvnidscfLjYRWIf0T1Hj6y2gj0dgEHBMinyuK7DWGcneu5GHBmSc2GKqrzICZen)ZPgneGjRnQnsOhm8Y7Gbfn((HzXeNZ2iHEWWlVdgu)cQzex02iJXWkywozI(XrFcTTo0ravmIlCt6ne4HzaQyex4M0t9GvhVLC2yJLbDYe9JJ(eABDOJaQyex4M0BiWdZBjVnsOhm8Y7GbLzCWWngwbR8RvUKuXrTz8Gj)B2gj0dgE5DWG6GmO(rstJHvW53XAK2i)qgZiLP(rstvk)ALJSBj)YbdN)nvXcnIjq84CjPIJAZ4btEIcWl2ytjkfvvOT1PtKrGEziWd(aiVnsOhm8Y7Gb1eABDf9a5hWMb9ZyyfSYVw5ssfh1MXdMCG4XvP8RvE(DuhvTz8GjhiECvaOYVw5x8Pw6OQpluZi2qoq84Trc9GHxEhmOueBDu1xcPKwmgwbR8RvUKuXrTz8GjhiECvk)ALNFh1rvBgpyYbIhxfaQ8Rv(fFQLoQ6Zc1mInKdepEBKqpy4L3bdkfmlysk0TngwbR8RvUKuXrTz8Gj)B2gj0dgE5DWGszgbGU(ZxgdRGv(1kxsQ4O2mEWK)nBJe6bdV8oyqvHjQmJaWyyfSYVw5ssfh1MXdM8VzBKqpy4L3bdkXPy5szQPYCAmScw5xRCjPIJAZ4bt(3SnsOhm8Y7Gb1VGA4HmfJHvWk)ALljvCuBgpyY)MTrc9GHxEhmO(fudpKXyxyqWfQKfDu11uomDzQlxcRyBKqpy4L3bdQFb1WdzmgRvKEAxyqW2tbakxKfTIayJgdRGv(1kxsQ4O2mEWK)nzJnAetG4X5ssfh1MXdM8ezeOxup43(wvaOYVw5x8Pw6OQpluZi2q(3SnsOhm8Y7Gb1VGA4Hmg7cdcMjcFcpTzclmgdRGPHb0f)4K(kHIRIgXeiECUKuXrTz8Gjprgb6LHat2aurJycepo)Ip1shv9zHAgXgYtKrGEziWKnG2iHEWWlVdgu)cQHhYySlmiyMi8j80MjSWymScEq0Wa6IFCsFLqXvrJycepoxsQ4O2mEWKNiJa9YqGvhQOrmbIhNFXNAPJQ(SqnJyd5jYiqVmey1HQdYGQNegGkwgenmGU4h3a6N1RKn2e6bnGA0rgiwgYGKqrzICjq9jPnEAA89J82iHEWWlVdgu)cQHhYySlmiyKX8vIYuhjGlofngwbtJycepoxsQ4O2mEWKNiJa9YqGj7TQOrmbIhNFXNAPJQ(SqnJyd5jYiqVmeyYEBBKqpy4L3bdQFb1Wdzm2fgemqIcqfMO2awk40yyfmnIjq84CjPIJAZ4btEImc0lQhmjhaBSnidscfLjYftD46FbbtgBSXYbzqWdqLbjHIYe5vyXc626WeDmbtMQ87ynsBKxGMwHRlxKmK3gj0dgE5DWG6xqn8qgJDHbbxI)udTD4HPXWkyAetG4X5ssfh1MXdM8ezeOxupysyaSX2GmijuuMixm1HR)femzTrc9GHxEhmO(fudpKXyxyqW2ZxMw6OQLsbYaNYbd3yyfmnIjq84CjPIJAZ4btEImc0lQhmjhaBSnidscfLjYftD46FbbtgBSXYbzqWdqLbjHIYe5vyXc626WeDmbtMQ87ynsBKxGMwHRlxKmK3gj0dgE5DWG6xqn8qgJDHbbZiurjrDXcXtZ8lqQXWkyAetG4X5ssfh1MXdM8ezeOxgc8BvXYGmijuuMiVclwq3whMOJjyYyJTdYGQNega5Trc9GHxEhmO(fudpKXyxyqWmcvusuxSq80m)cKAmScMgXeiECUKuXrTz8Gjprgb6LHa)wvgKekktKxHflOBRdt0XemzQu(1kp)oQJQ2mEWK)nvP8RvE(DuhvTz8Gjprgb6LHaZczdGv8TdS87ynsBKxGMwHRlxKmKR6Gm4qKWaAJe6bdV8oyq9lOgEiJXUWGGlwcq8Ga6iv0rvFrYG(zmSc(Gmi4bWgBSyqsOOmrE8Vcea1rvtJycepErflSqddOl(Xj9vcfxfnIjq848uaGIF6IPKKYtKrGEziWKufnIjq84CjPIJAZ4btEImc0ldb(TQOrmbIhNFXNAPJQ(SqnJyd5jYiqVme43soBSrJycepoxsQ4O2mEWKNiJa9YqGjjBSvH2wNorgb6LHOrmbIhNljvCuBgpyYtKrGEHCYBJEtVVLRo6fw69SWElMic0Bu79SWEhJ)CI3bD7EzL(kV61mJbsKEWj2gj0dgE5DWG6xqn8qgJDHbbxI)CI3bDBD(vEzmScMfdscfLjYpidQ)(bNAX8Dwe6bdNNcau8txmLKuoYos)hQpidoWOHb0f)4K(kHIt(7Si0dgohaLZsjsh5i7i9FO(Gm4aJggqx8J7inJzKaK)Uqpy48l(ulDu1NfQzeBihzhP)d1hKbh6K0gpoaSCItr155TC1b5QyXGKqrzIClXaQdt0ra2yJfAyaDXpoPVsO4QYVJ1iTrUKuXrn0RqhEViNCvNK24XbGLtCkQEs(22O38MEf6bdV8oyq54tn(oGoXsmnGg)lO(Xcornvkh0TbtMXWkyLFTYLKkoQnJhm5Ft2ydav(1k)Ip1shv9zHAgXgY)MSXgqC8uaGIF6IPKKYpiLuOB3g9M30Rqpy4L3bdkQmNAHEWW1ty5m2fgemvM0)uoy4L2iHEWWlVdguuzo1c9GHRNWYzSlmiydsGgxUespWKzmScMggqx8JBa9Z6vQk)owJ0g5fOPv46YfjJQtMOFCjPIJAKAfQe6bnGA0rgiwupydscfLjYLa1NK24PPX3V2iHEWWlVdguuzo1c9GHRNWYzSlmiyjqJlxcPhyYmgwbl0dAa1OJmqSOEWgKekktKlbQpjTXttJVFTrc9GHxEhmOOYCQf6bdxpHLZyxyqWwsYe(lJlxcPhyYmgwbtddOl(Xj9vcfxv(DSgPnYLKkoQTKKj8xTrc9GHxEhmOOYCQf6bdxpHLZyxyqWvyXc626WeDmnUCjKEGjZyyfSbjHIYe5wIbuhMOJaGhGkdscfLjYRWIf0T1Hj6yQAqSqddOl(Xj9vcfxv(DSgPnYLKkoQTKKj8xK3gj0dgE5DWGIkZPwOhmC9ewoJDHbbhMOJPXLlH0dmzgdRGnijuuMi3smG6WeDea8auniwOHb0f)4K(kHIRk)owJ0g5ssfh1wsYe(lYBJe6bdV8oyqrL5ul0dgUEclNXUWGGPrmbIhVyC5si9atMXWk4bXcnmGU4hN0xjuCv53XAK2ixsQ4O2ssMWFrEBKqpy4L3bdkQmNAHEWW1ty5m2fgeCgNCWWnUCjKEGjZyyfSbjHIYe5vOltTYpDWdq1GyHggqx8Jt6RekUQ87ynsBKljvCuBjjt4ViVnsOhm8Y7GbfvMtTqpy46jSCg7cdcUcDzQv(PBC5si9atMXWkydscfLjYRqxMALF6Gjt1GyHggqx8Jt6RekUQ87ynsBKljvCuBjjt4ViVnQnsOhm8cxceCnJYPeZZyyfC(DSgPnYbGfk0CcDjFPPbdJ4aQOrmbIhNR8RvnaSqHMtOl5lnnyyehGNOa8sLYVw5aWcfAoHUKV00GHrCaDnJYXbIhxflk)ALljvCuBgpyYbIhxLYVw553rDu1MXdMCG4XvbGk)ALFXNAPJQ(SqnJyd5aXJtUkAetG4X5x8Pw6OQpluZi2qEImc0lGhGkwu(1kxsQ4OMAjPnYlNqjDiWgKekktKlbQV4y0mc7AQLK2yrflSCYe9JNFh1rvBgpyQIgXeiECE(DuhvTz8Gjprgb6LHaBtburJycepoxsQ4O2mEWKNiJa9I6nijuuMi)IJrZiSRbWP8sxJulMKZgBSmOtMOF887OoQAZ4btv0iMaXJZLKkoQnJhm5jYiqVOEdscfLjYV4y0mc7AaCkV01i1Ij5SXgnIjq84CjPIJAZ4btEImc0ldb2Mcqo5Trc9GHx4sGVdguvyIALPuoJHvWSKFhRrAJCayHcnNqxYxAAWWioGkAetG4X5k)AvdaluO5e6s(stdggXb4jkaVuP8RvoaSqHMtOl5lnnyyehqxHjYbIhxLzIg02uaoz8AgLtjMh5SXgl53XAK2ihawOqZj0L8LMgmmIdO6Gmi4bqEBKqpy4fUe47GbvnJYP9WGymSco)owJ0g52jSmFPHuiDIQOrmbIhNljvCuBgpyYtKrGEr9KWaurJycepo)Ip1shv9zHAgXgYtKrGEb8auXIYVw5ssfh1uljTrE5ekPdb2GKqrzICjq9fhJMryxtTK0glQyHLtMOF887OoQAZ4btv0iMaXJZZVJ6OQnJhm5jYiqVmeyBkGkAetG4X5ssfh1MXdM8ezeOxuVbjHIYe5xCmAgHDnaoLx6AKAXKC2yJLbDYe9JNFh1rvBgpyQIgXeiECUKuXrTz8Gjprgb6f1BqsOOmr(fhJMryxdGt5LUgPwmjNn2OrmbIhNljvCuBgpyYtKrGEziW2uaYjVnsOhm8cxc8DWGQMr50EyqmgwbNFhRrAJC7ewMV0qkKorv0iMaXJZLKkoQnJhm5jYiqVaEaQyHfwOrmbIhNFXNAPJQ(SqnJyd5jYiqVOEdscfLjYftnJWUgaNYlDns9fhJkLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjLC2yJfAetG4X5x8Pw6OQpluZi2qEImc0lGhGkLFTYLKkoQPwsAJ8YjushcSbjHIYe5sG6lognJWUMAjPnwiNCvk)ALNFh1rvBgpyYbIhN82iHEWWlCjW3bdkjPIJAgyPaNyXyyfmnmGU4hN0xjuCv53XAK2ixsQ4O2ssMWFPs5xRCjPIJAljzc)fVCcL0Hi7TQOrmbIhNNcau8txmLKuEImc0ldb2GKqrzICljzc)LUCcLu9bzW3r2r6)q9bzqv0iMaXJZV4tT0rvFwOMrSH8ezeOxgcSbjHIYe5wsYe(lD5ekP6dYGVJSJ0)H6dYGVl0dgopfaO4NUykjPCKDK(puFqgufnIjq84CjPIJAZ4btEImc0ldb2GKqrzICljzc)LUCcLu9bzW3r2r6)q9bzW3f6bdNNcau8txmLKuoYos)hQpid(Uqpy48l(ulDu1NfQzeBihzhP)d1hKbnMAjqhmzTrc9GHx4sGVdgussfh1mWsboXIXWkyAyaDXpUb0pRxPQ87ynsBKljvCud9k0H3lvk)ALljvCuBjjt4V4LtOKoezVvfnIjq848l(ulDu1NfQzeBiprgb6LHaBqsOOmrULKmH)sxoHsQ(Gm47i7i9FO(GmOkAetG4X5ssfh1MXdM8ezeOxgcSbjHIYe5wsYe(lD5ekP6dYGVJSJ0)H6dYGVl0dgo)Ip1shv9zHAgXgYr2r6)q9bzqJPwc0btwBKqpy4fUe47GbLKuXrTYukNXWkyAyaDXpUb0pRxPQtMOFCjPIJAKAfQoidoezdqfnIjq84CgyMrw0rvFrYG(XtKrGErLYVw50jkjvkh0T5LtOKoej0gj0dgEHlb(oyq9lOgEiJXUWGGlXFoX7GUTo)kVmgwbNFhRrAJ8c00kCD5IKrLzIg02uaozC0qqLdgEBKqpy4fUe47Gb1fFQLoQ6Zc1mIn0yyfC(DSgPnYlqtRW1LlsgvMjAqBtb4KXrdbvoy4Trc9GHx4sGVdgussfh1MXdMgdRGZVJ1iTrEbAAfUUCrYOIfZenOTPaCY4OHGkhmC2yZmrdABkaNm(fFQLoQ6Zc1mInK82iHEWWlCjW3bdkgyMrw0rvFrYG(zmSco)owJ0g5ssfh1qVcD49sfnIjq848l(ulDu1NfQzeBiprgb6LHat2aurJycepoxsQ4O2mEWKNiJa9YqGj7TTrc9GHx4sGVdgumWmJSOJQ(IKb9ZyyfmnIjq84CjPIJAZ4btEImc0ldbEyurJycepo)Ip1shv9zHAgXgYtKrGEziWdJkwu(1kxsQ4OMAjPnYlNqjDiWgKekktKlbQV4y0mc7AQLK2yrflSCYe9JNFh1rvBgpyQIgXeiECE(DuhvTz8Gjprgb6LHaBtburJycepoxsQ4O2mEWKNiJa9I6Fl5SXgld6Kj6hp)oQJQ2mEWufnIjq84CjPIJAZ4btEImc0lQ)TKZgB0iMaXJZLKkoQnJhm5jYiqVmeyBka5K3gj0dgEHlb(oyqHgcQCWWngwbFqgu9KWauLFhRrAJ8c00kCD5IKrfnmGU4h3a6N1RuLzIg02uaozCgyMrw0rvFrYG(1gj0dgEHlb(oyqHgcQCWWngwbFqgu9KWauLFhRrAJ8c00kCD5IKrLYVw5ssfh1uljTrE5ekPdb2GKqrzICjq9fhJMryxtTK0glQOrmbIhNFXNAPJQ(SqnJyd5jYiqVaEaQOrmbIhNljvCuBgpyYtKrGEziW2uG2iHEWWlCjW3bdk0qqLdgUXWk4dYGQNegGQ87ynsBKxGMwHRlxKmQOrmbIhNljvCuBgpyYtKrGEb8auXclSqJycepo)Ip1shv9zHAgXgYtKrGEr9gKekktKlMAgHDnaoLx6AK6logvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsk5SXgl0iMaXJZV4tT0rvFwOMrSH8ezeOxapavk)ALljvCutTK0g5LtOKoeydscfLjYLa1xCmAgHDn1ssBSqo5Qu(1kp)oQJQ2mEWKdepo5gd9dZ8BEAyfSYVw5fOPv46YfjdVCcLuWk)ALxGMwHRlxKmCgHDD5ekPgd9dZ8BEAiddcaLdbtwBKqpy4fUe47Gb1VGA4Hmg7cdcUe)5eVd6268R8YyyfmnIjq848uaGIF6IPKKYtuaEPIgXeiEC(fFQLoQ6Zc1mInKNiJa9YqGTPaCgHDv0iMaXJZLKkoQnJhm5jYiqVmeyBkaNryVnsOhm8cxc8DWGkfaO4NUykjPgdRGPrmbIhNFXNAPJQ(SqnJyd5jYiqVmeYos)hQpidQIfwozI(XZVJ6OQnJhmvrJycepop)oQJQ2mEWKNiJa9YqGTPaQOrmbIhNljvCuBgpyYtKrGEr9gKekktKFXXOze21a4uEPRrQftYzJnwg0jt0pE(DuhvTz8GPkAetG4X5ssfh1MXdM8ezeOxuVbjHIYe5xCmAgHDnaoLx6AKAXKC2yJgXeiECUKuXrTz8Gjprgb6LHaBtbiVnsOhm8cxc8DWGkfaO4NUykjPgdRGPrmbIhNljvCuBgpyYtKrGEziKDK(puFqguflSWcnIjq848l(ulDu1NfQzeBiprgb6f1BqsOOmrUyQze21a4uEPRrQV4yuP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPKZgBSqJycepo)Ip1shv9zHAgXgYtKrGEb8auP8RvUKuXrn1ssBKxoHs6qGnijuuMixcuFXXOze21uljTXc5KRs5xR887OoQAZ4btoq84K3gj0dgEHlb(oyqbGYzPePJgdRGPrmbIhNljvCuBgpyYtKrGEb8auXclSqJycepo)Ip1shv9zHAgXgYtKrGEr9gKekktKlMAgHDnaoLx6AK6logvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsk5SXgl0iMaXJZV4tT0rvFwOMrSH8ezeOxapavk)ALljvCutTK0g5LtOKoeydscfLjYLa1xCmAgHDn1ssBSqo5Qu(1kp)oQJQ2mEWKdepo5Trc9GHx4sGVdgu)cQHhYySlmi4s8Nt8oOBRZVYlJHvWSO8RvUKuXrn1ssBKxoHs6qGnijuuMixcuFXXOze21uljTXcBSzMObTnfGtgpfaO4NUykjPKRIfwozI(XZVJ6OQnJhmvrJycepop)oQJQ2mEWKNiJa9YqGTPaQOrmbIhNljvCuBgpyYtKrGEr9gKekktKFXXOze21a4uEPRrQftYzJnwg0jt0pE(DuhvTz8GPkAetG4X5ssfh1MXdM8ezeOxuVbjHIYe5xCmAgHDnaoLx6AKAXKC2yJgXeiECUKuXrTz8Gjprgb6LHaBtbix1GyPe)Pc0b4yT(lqdOwCiJOfkfNykxKQYVJ1iTrULKmHdPAKAfK3gj0dgEHlb(oyqDXNAPJQ(SqnJydngwbtddOl(XnG(z9kvLFhRrAJCjPIJAOxHo8EPIgXeiECodmZil6OQVizq)4jYiqVme43oG2iHEWWlCjW3bdQl(ulDu1NfQzeBOXWkyAyaDXpUb0pRxPQ87ynsBKljvCud9k0H3lvk)ALZaZmYIoQ6lsg0pEImc0ldbMKdqfnIjq84CjPIJAZ4btEImc0ldb2Mc0gj0dgEHlb(oyqDXNAPJQ(SqnJydngwbZIYVw5ssfh1uljTrE5ekPdb2GKqrzICjq9fhJMryxtTK0glSXMzIg02uaoz8uaGIF6IPKKsUkwy5Kj6hp)oQJQ2mEWufnIjq84887OoQAZ4btEImc0ldb2McOIgXeiECUKuXrTz8Gjprgb6f1BqsOOmr(fhJMryxdGt5LUgPwmjNn2yzqNmr)453rDu1MXdMQOrmbIhNljvCuBgpyYtKrGEr9gKekktKFXXOze21a4uEPRrQftYzJnAetG4X5ssfh1MXdM8ezeOxgcSnfGCvdILs8NkqhGJ16VanGAXHmIwOuCIPCrQk)owJ0g5wsYeoKQrQvqEBKqpy4fUe47GbLKuXrTz8GPXWkywyHgXeiEC(fFQLoQ6Zc1mInKNiJa9I6nijuuMixm1mc7AaCkV01i1xCmQu(1kxsQ4OMAjPnYlNqjfSYVw5ssfh1uljTroJWUUCcLuYzJnwOrmbIhNFXNAPJQ(SqnJyd5jYiqVaEaQu(1kxsQ4OMAjPnYlNqjDiWgKekktKlbQV4y0mc7AQLK2yHCYvP8RvE(DuhvTz8GjhiECvdILs8NkqhGJ16VanGAXHmIwOuCIPCrQk)owJ0g5wsYeoKQrQvqEBKqpy4fUe47Gbv(DuhvTz8GPXWkyLFTYZVJ6OQnJhm5aXJRIfwOrmbIhNFXNAPJQ(SqnJyd5jYiqVOEsoavk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsk5SXgl0iMaXJZV4tT0rvFwOMrSH8ezeOxapavk)ALljvCutTK0g5LtOKoeydscfLjYLa1xCmAgHDn1ssBSqo5QyHgXeiECUKuXrTz8Gjprgb6f1tgjzJnau5xR8l(ulDu1NfQzeBi)BsUQbXsj(tfOdWXA9xGgqT4qgrlukoXuUivLFhRrAJCljzchs1i1kiVnsOhm8cxc8DWGQybRh0T1MXdMgdRGPrmbIhNljvCuhPcprgb6f1)w2yBqNmr)4ssfh1rQ0gj0dgEHlb(oyqLFh1rvBgpyAmScUe)Pc0b4yT(lqdOwCiJOfkfNykxKQYVJ1iTrULKmHdPAKAfQOrmbIhNNcau8txmLKuEImc0ldbgzhP)d1hKbBJe6bdVWLaFhmOsbak(PlMssQXWk4s8NkqhGJ16VanGAXHmIwOuCIPCrQk)owJ0g5wsYeoKQrQvOIfLFTYLKkoQPwsAJ8YjusvpysYgB0iMaXJZV4tT0rvFwOMrSH8ezeOxgcmYos)hQpidsEBKqpy4fUe47Gb1fFQLoQ6Zc1mIn0yyfCj(tfOdWXA9xGgqT4qgrlukoXuUivLFhRrAJCljzchs1i1kuzMObTnfGtgpfaO4NUykjPTrc9GHx4sGVdgussfh1MXdMgdRGlXFQaDaowR)c0aQfhYiAHsXjMYfPQ87ynsBKBjjt4qQgPwHkZenOTPaCY4x8Pw6OQpluZi2W2O38MEf6bdVWLaFhmOEe4zCbPGhaFadUXWkyau5xR8uaGIF6IPKKQn8NoMIcCcVx8YjusbZcaQ8RvEkaqXpDXuss1g(thtrboH3loJWUUCcLuwrYixv(DSgPnYTKKjCivJuRqLqpObuJoYaXYqV14j0rnfamjFBBKqpy4fUe47GbLKuXrTYukNXWkyAyaDXpoPVsO4QYVJ1iTrUKuXrn0RqhEVuP8RvUKuXrTz8Gj)BQcav(1kpfaO4NUykjPAd)PJPOaNW7fVCcLuWdUkZenOTPaCY4ssfh1rQOsOh0aQrhzGyzObQQbLFhRrAJCljzchs1i1kAJe6bdVWLaFhmOKKkoQvKmfB0yyfmnmGU4hN0xjuCv53XAK2ixsQ4Og6vOdVxQu(1kxsQ4O2mEWK)nvbGk)ALNcau8txmLKuTH)0XuuGt49IxoHsk4bVnsOhm8cxc8DWGssQ4OwzkLZyyfmnmGU4hN0xjuCv53XAK2ixsQ4Og6vOdVxQu(1kxsQ4O2mEWK)nvXcqC8uaGIF6IPKKYtKrGEr9Qd2ydav(1kpfaO4NUykjPAd)PJPOaNW7f)BsUkau5xR8uaGIF6IPKKQn8NoMIcCcVx8YjushAWvj0dAa1OJmqSm0BBJe6bdVWLaFhmOKKkoQJuXyyfmnmGU4hN0xjuCv53XAK2ixsQ4O2ssMWFPs5xRCjPIJAZ4bt(3ufaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekPGjH2iHEWWlCjW3bdkjPIJAfjtXgngwbtddOl(Xj9vcfxv(DSgPnYLKkoQTKKj8xQu(1kxsQ4O2mEWK)nvbGk)ALNcau8txmLKuTH)0XuuGt49IxoHskys2gj0dgEHlb(oyqjjvCuJSBoJcmCJHvW0Wa6IFCsFLqXvLFhRrAJCjPIJAljzc)LkLFTYLKkoQnJhm5FtvMjAqBtb4KKNcau8txmLKuvc9Ggqn6idelQNeAJe6bdVWLaFhmOKKkoQr2nNrbgUXWkyAyaDXpoPVsO4QYVJ1iTrUKuXrTLKmH)sLYVw5ssfh1MXdM8VPkau5xR8uaGIF6IPKKQn8NoMIcCcVx8YjusbtMkHEqdOgDKbIf1tcTrc9GHx4sGVdgussfh1i7MZOad3yyfC(DSgPnYTKKjCivJuRqfaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekPGjRnsOhm8cxc8DWGssQ4Ogz3Cgfy4gdRGZVJ1iTrULKmHdPAKAfQyXmrdABkaNmEkaqXpDXusszJnwmt0G2McWjjpfaO4NUykjPQaqLFTYV4tT0rvFwOMrSH8Vj5K3gj0dgEHlb(oyqjjvCuhPIXWk487ynsBKBjjt4qQgPwHkau5xR8uaGIF6IPKKQn8NoMIcCcVx8YjusbtcTrc9GHx4sGVdgussfh1mWsboXIXWkyLFTYPtusQuoOBZtuONQtMOFCjPIJAKAfQaqLFTYV4tT0rvFwOMrSH8VzBKqpy4fUe47GbLzIf0POoQAgOdymScw5xRCauolLiDK)nvbGk)ALFXNAPJQ(SqnJyd5FtvaOYVw5x8Pw6OQpluZi2qEImc0ldbw5xRCZelOtrDu1mqhGZiSRlNqjDGj0dgoxsQ4OwzkLJJSJ0)H6dYGQyHLtMOF8elHlofvj0dAa1OJmqSm0GtoBSj0dAa1OJmqSm0Bjxfldk)owJ0g5ssfh1kbJIKamOFSX2jPnECluMNf3KEQNeEl5Trc9GHx4sGVdgussfh1ktPCgdRGv(1khaLZsjsh5FtvSWYjt0pEILWfNIQe6bnGA0rgiwgAWjNn2e6bnGA0rgiwg6TKRILbLFhRrAJCjPIJALGrrsag0p2y7K0gpUfkZZIBsp1tcVL82iHEWWlCjW3bdQY3etpmiTrc9GHx4sGVdgussfh1ksMInAmScw5xRCjPIJAQLK2iVCcLu1dMfHEqdOgDKbIfwrYixv(DSgPnYLKkoQvcgfjbyq)uDsAJh3cL5zXnP3qKWBBJe6bdVWLaFhmOKKkoQvKmfB0yyfSYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOK2gj0dgEHlb(oyqjjvCuhPIXWkyLFTYLKkoQPwsAJ8YjusbpavSqJycepoxsQ4O2mEWKNiJa9I6j7TSX2GyHggqx8Jt6RekUQ87ynsBKljvCuBjjt4ViN82iHEWWlCjW3bdkhplm1hYyILZyyfmljwtSyjktKn2g0bPKcDBYvP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPTrc9GHx4sGVdgussfh1mWsboXIXWkyLFTYPtusQuoOBZtuONQ87ynsBKljvCuBjjt4VuXclNmr)4cJ5ewHu5GHRsOh0aQrhzGyzOHHC2ytOh0aQrhzGyzO3sEBKqpy4fUe47GbLKuXrndSuGtSymScw5xRC6eLKkLd628ef6P6Kj6hxymNWkKkhmCvc9Ggqn6ideldn4Trc9GHx4sGVdgussfh1i7MZOad3yyfSYVw5ssfh1uljTrE5ekPdP8RvUKuXrn1ssBKZiSRlNqjTnsOhm8cxc8DWGssQ4Ogz3Cgfy4gdRGv(1kxsQ4OMAjPnYlNqjfSYVw5ssfh1uljTroJWUUCcLuvMjAqBtb4KXLKkoQvKmfBSn6nVPxHEWWlCjW3bdk0qqLdgUXq)Wm)MNgwbZiUWnPN6bpmV1yOFyMFZtdzyqaOCiyYAJAJEZB6f0wyb7Lkt6Fkhm8sVpyI9YegqGEH(f9EwyVcaq49ErVSyfMy9pNViVxOttukyVyTcPq0PV4TrV5n9k0dgEHtLj9pLdgEbSbjHIYen2fgeSLya1Hj6iGXHj4cEgBqMFemzgdRGnijuuMi3smG6WeDea8auzMObTnfGtghneu5GHRAqSKFhRrAJ8c00kCD5IKHn2YVJ1iTr(HmMrkt9JKMK3g9M30Rqpy4fovM0)uoy4L3bdkdscfLjASlmiylXaQdt0raJdtWf8m2Gm)iyYmgwbBqsOOmrULya1Hj6ia4bOs5xRCjPIJAZ4btoq84QOrmbIhNljvCuBgpyYtKrGErfl53XAK2iVanTcxxUizyJT87ynsBKFiJzKYu)iPj5TrV5n9k0dgEHtLj9pLdgE5DWGYGKqrzIg7cdcUcDzQv(PBCycUGNXgK5hbtMXWkyLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjv1Gu(1kp)tuhv9zLiw4FtvvOT1PtKrGEziWSWcJ4I68i0dgoxsQ4OwzkLJtJYr(atOhmCUKuXrTYukhhzhP)d1hKbjVn6nVPx1j4zHzVsV1)C(Q3YjusrGETKKj8x9gzVqVxKDK(pS3uCBS3h4z1lRdgfjbyq)AJEZB6vOhm8cNkt6Fkhm8Y7GbLbjHIYen2fgemYygpyIaAfjtXgnombxWZydY8JGv(1kxsQ4O2ssMWFXlNqjv9Gj7TSXgl53XAK2ixsQ4OwjyuKeGb9t1jPnECluMNf3KEdrcVL82O38MEf6bdVWPYK(NYbdV8oyqzqsOOmrJDHbbpLYPft9VGgdGv5ppWdW4WeCbpJHvWk)ALljvCuBgpyY)MQyXGKqrzI8PuoTyQ)fe8ayJTdYGQhSbjHIYe5tPCAXu)l47K9wYn2Gm)i4dYGTrV5n9oyjvCS3HndaO9RETHgWsVsVgKekktSxHj((1Bu7LcKg3RY)69bbzo79xWELERt56flhKroy49AHjY7f0wyVfidTxZmmabqGEtKrGErJSBI0db6fz3mXsbgEVabw61JR3NijT3hCo7TgzVMzaaTF1lWh79IEplSxLFwUx96Y9tS3O27zH9sbsEB0BEtVc9GHx4uzs)t5GHxEhmOmijuuMOXUWGGXYbzKdb0IPMgXeiECJdtWf8m2Gm)iywOrmbIhNljvCuBgpyYb(PCWWhySqgRildGpasyGrdh4dpUKuXrTzgaq7x8uCsjNCYzfz5GmiRObjHIYe5tPCAXu)li5TrV5n9k0dgEHtLj9pLdgE5DWGYGKqrzIg7cdc(GmO(7hCQftJdtWf8mgwbtdh4dpUKuXrTzgaq7xgBqMFemnIjq84CjPIJAZ4btEImc0lAKDtKEiqB0BEtVc9GHx4uzs)t5GHxEhmOmijuuMOXUWGGpidQ)(bNAX04WeCbpJHvWdIgoWhECjPIJAZmaG2Vm2Gm)iyAetG4X5ssfh1MXdM8ezeOxAJEZB6vDhbzo7faNYREhSHT3VzVx0ljhqbP9wJSxqh3aVn6nVPxHEWWlCQmP)PCWWlVdgugKekkt0yxyqWhKb1F)GtTyACycMry3ydY8JGPrmbIhNFXNAPJQ(SqnJyd5jYiqVymScMfAetG4X5x8Pw6OQpluZi2qEImc0lSIgKekktKFqgu)9do1Ij5drYb0g9M307i0PyVSsFLx9cl9w(uRELEnJhmR)zVxcDsXR3AK9QoVELqXnU3heK5S3YbPK27f9EwyV3t0ld0)h2l9fDI9(9do79b71gVELETG2w9IE8TT6nfN0EJAVMzaaTF1g9M30Rqpy4fovM0)uoy4L3bdkdscfLjASlmi4dYG6VFWPwmnombZiSBSbz(rWxcDsXJxI)CI3bDBD(vEXPrmbIhNNiJa9IXWkyA4aF4XLKkoQnZaaA)sfnCGp84ssfh1MzaaTFXtXjDO3Qczf(qtteGxI)CI3bDBD(vEPIggqx8Jt6RekUQ87ynsBKljvCuBjjt4VAJEZB6vDhbzo7faNYREbDCd8E)M9ErVKCafK2BnYEhSHTn6nVPxHEWWlCQmP)PCWWlVdgugKekkt0yxyqWwXea626logJdtWf8m2Gm)iyAetG4X5x8Pw6OQpluZi2qEIcWlvgKekktKFqgu)9do1I5qKCaTrV5n9YkjaqXVEhnLK0EbcS0RhxVqggeakhoF1R5)69B27zH9A4pDmff4eEV6fav(1AVLOx41lv8EvWEbG1kK(NxVx0laSqX079SKR3heKe7vUEplSx1nygNvVg(thtrboH3RElNqjTn6nVPxHEWWlCQmP)PCWWlVdgugKekkt0yxyqWdK)YP)feqxmLKuJdtWf8m2Gm)iywmt0G2McWjJNcau8txmLKu2yZmrdABkaNK8uaGIF6IPKKYgBMjAqBtb4KapfaO4NUykjPKRsOhmCEkaqXpDXuss5hKb1fOtXHSPaCgH9b2G3g9M30R6SeAdDz27iKz49sTqkPiqVaOYVw5Paaf)0ftjjvB4pDmff4eEV4aXJBCVk)R3ZsUEbcS4GC9(ejP9(yHEVNf2RaaeEVIP5eILEzLgvN)EHE5e)MV4TrV5n9k0dgEHtLj9pLdgE5DWGYGKqrzIg7cdcEG8xo9VGa6IPKKACycUGNXgK5hbZIzIg02uaoz8uaGIF6IPKKYgBMjAqBtb4KKNcau8txmLKu2yZmrdABkaNe4Paaf)0ftjjLCvaOYVw5Paaf)0ftjjvB4pDmff4eEV4aXJ3g9M30Rqpy4fovM0)uoy4L3bdkdscfLjASlmi44FfiaQJQMgXeiE8IXHj4cEgBqMFeSYVw5ssfh1MXdMCG4XvP8RvE(DuhvTz8GjhiECvaOYVw5x8Pw6OQpluZi2qoq84QgKbjHIYe5dK)YP)feqxmLKuvaOYVw5Paaf)0ftjjvB4pDmff4eEV4aXJ3g9M30Rqpy4fovM0)uoy4L3bdkdscfLjASlmi4Yjus1wsYe(lJdtWf8m2Gm)i487ynsBKljvCuBjjt4VuXcl0Wa6IFCsFLqXvrJycepopfaO4NUykjP8ezeOxgYGKqrzICljzc)LUCcLu9bzqYjVnQn6n9oSjms4bv3G9(lq3Ux7ewMV6fsH0j27d8S6vm59oquWEHxVpWZQ3loMEJZcZhyb5Trc9GHx40iMaXJxaxZOCApmigdRGZVJ1iTrUDclZxAifsNOkAetG4X5ssfh1MXdM8ezeOxupjmav0iMaXJZV4tT0rvFwOMrSH8efGxQyr5xRCjPIJAQLK2iVCcL0HaBqsOOmr(fhJMryxtTK0glQyHLtMOF887OoQAZ4btv0iMaXJZZVJ6OQnJhm5jYiqVmeyBkGkAetG4X5ssfh1MXdM8ezeOxuVbjHIYe5xCmAgHDnaoLx6AKAXKC2yJLbDYe9JNFh1rvBgpyQIgXeiECUKuXrTz8Gjprgb6f1BqsOOmr(fhJMryxdGt5LUgPwmjNn2OrmbIhNljvCuBgpyYtKrGEziW2uaYjVnsOhm8cNgXeiE8Y7GbvnJYP9WGymSco)owJ0g52jSmFPHuiDIQOrmbIhNljvCuBgpyYtuaEPILbDYe9JJ(eABDOJaSXglNmr)4OpH2wh6iGkgXfUj9up4b6aiNCvSWcnIjq848l(ulDu1NfQzeBiprgb6f1t2auP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPKZgBSqJycepo)Ip1shv9zHAgXgYtKrGEb8auP8RvUKuXrn1ssBKxoHsk4bqo5Qu(1kp)oQJQ2mEWKdepUkgXfUj9upydscfLjYftnd0HmFgnJ4I2KETrc9GHx40iMaXJxEhmOQzuoLyEgdRGZVJ1iTroaSqHMtOl5lnnyyehqfnIjq84CLFTQbGfk0CcDjFPPbdJ4a8efGxQu(1khawOqZj0L8LMgmmIdORzuooq84Qyr5xRCjPIJAZ4btoq84Qu(1kp)oQJQ2mEWKdepUkau5xR8l(ulDu1NfQzeBihiECYvrJycepo)Ip1shv9zHAgXgYtKrGEb8auXIYVw5ssfh1uljTrE5ekPdb2GKqrzI8lognJWUMAjPnwuXclNmr)453rDu1MXdMQOrmbIhNNFh1rvBgpyYtKrGEziW2uav0iMaXJZLKkoQnJhm5jYiqVOEdscfLjYV4y0mc7AaCkV01i1Ij5SXgld6Kj6hp)oQJQ2mEWufnIjq84CjPIJAZ4btEImc0lQ3GKqrzI8lognJWUgaNYlDnsTysoBSrJycepoxsQ4O2mEWKNiJa9YqGTPaKtEBKqpy4fonIjq84L3bdQkmrTYukNXWk487ynsBKdaluO5e6s(stdggXburJycepox5xRAayHcnNqxYxAAWWioaprb4LkLFTYbGfk0CcDjFPPbdJ4a6kmroq84Qmt0G2McWjJxZOCkX8AJEtVdRaZEh4bO79bEw9oydBVWAVWdKsV0Gb629(n7TeHZ7LvU2l869boN9QG9(liqVpWZQxqh3a34EPs56fE9wMqBRB(QxfSgj2gj0dgEHtJycepE5DWGIbMzKfDu1xKmOFgdRGhu(DSgPnYlqtRW1Llsgv0iMaXJZV4tT0rvFwOMrSH8ezeOxgcS6IvKfsyGvWtRe(VWpiMKCy0dUjLCv0iMaXJZLKkoQnJhm5jYiqVmeyYgaRilKWaRGNwj8FHFqmj5WOhCtk5Trc9GHx40iMaXJxEhmOyGzgzrhv9fjd6NXWk487ynsBKxGMwHRlxKmQu(1kVanTcxxUiz4Ftv0iMaXJZV4tT0rvFwOMrSH8ezeOxgcS6IvKfsyGvWtRe(VWpiMKCy0dUjLCv0iMaXJZLKkoQnJhm5jYiqVmeyYgaRilKWaRGNwj8FHFqmj5WOhCtk5Trc9GHx40iMaXJxEhmOQtSyrtPEgdRGnijuuMip(xbcG6OQPrmbIhVOILs8NkqhGBiMYbNOUetdOFSXwj(tfOdWn)L7prnMFZdgo5TrVP3bB(iVk9(lyVaOCwkr6yVpWZQxXK3lRCT3loMEHLEtuaE1Ru69bNtJ7Lrif7T8tS3l6LkLRx41RcwJe79IJH3gj0dgEHtJycepE5DWGcaLZsjshngwbpO87ynsBKxGMwHRlxKmQOrmbIhNFXNAPJQ(SqnJyd5jYiqVmeyYERkAetG4X5ssfh1MXdM8ezeOxgcmzQJ2iHEWWlCAetG4XlVdguaOCwkr6OXWk487ynsBKxGMwHRlxKmQmt0G2McWjJJgcQCWWBJe6bdVWPrmbIhV8oyqbGYzPePJgdRGPrmbIhNljvCuBgpyYtuaEPILbDYe9JJ(eABDOJaSXglNmr)4OpH2wh6iGkgXfUj9up4b6aiNCvSWcnIjq848l(ulDu1NfQzeBiprgb6f1t2auP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPKZgBSqJycepo)Ip1shv9zHAgXgYtuaEPs5xRCjPIJAQLK2iVCcLuWdGCYvP8RvE(DuhvTz8GjhiECvmIlCt6PEWgKekktKlMAgOdz(mAgXfTj9AJEtVdefS3IPKK2lS27fhtVId0Ry2RKyVH3lfOxXb69jCqUEvWE)M9wJS3z42y27zjEVNf2lJWEVa4uEzCVmcPq3U3YpXEFWETedyVY17eLY179e9kjvCSxQLK2yPxXb69SKR3loMEFKIdY17a5VC9(liaVnsOhm8cNgXeiE8Y7GbvkaqXpDXussngwbtJycepo)Ip1shv9zHAgXgYtKrGEr9gKekktKNfnJWUgaNYlDns9fhJkAetG4X5ssfh1MXdM8ezeOxuVbjHIYe5zrZiSRbWP8sxJulMQy5Kj6hp)oQJQ2mEWufl0iMaXJZZVJ6OQnJhm5jYiqVmeYos)hQpidYgB0iMaXJZZVJ6OQnJhm5jYiqVOEdscfLjYZIMryxdGt5LUgPodtYzJTbDYe9JNFh1rvBgpysUkLFTYLKkoQPwsAJ8YjusvpjvbGk)ALFXNAPJQ(SqnJyd5aXJRs5xR887OoQAZ4btoq84Qu(1kxsQ4O2mEWKdepEB0B6DGOG9wmLK0EFGNvVIzVpwO3RzukqLjY7LvU27fhtVWsVjkaV6vk9(GZPX9YiKI9w(j27f9sLY1l86vbRrI9EXXWBJe6bdVWPrmbIhV8oyqLcau8txmLKuJHvW0iMaXJZV4tT0rvFwOMrSH8ezeOxgczhP)d1hKbvP8RvUKuXrn1ssBKxoHs6qGnijuuMi)IJrZiSRPwsAJfv0iMaXJZLKkoQnJhm5jYiqVmeli7i9FO(Gm47c9GHZV4tT0rvFwOMrSHCKDK(puFqgK82iHEWWlCAetG4XlVdguPaaf)0ftjj1yyfmnIjq84CjPIJAZ4btEImc0ldHSJ0)H6dYGQyHLbDYe9JJ(eABDOJaSXglNmr)4OpH2wh6iGkgXfUj9up4b6aiNCvSWcnIjq848l(ulDu1NfQzeBiprgb6f1BqsOOmrUyQze21a4uEPRrQV4yuP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPKZgBSqJycepo)Ip1shv9zHAgXgYtKrGEb8auP8RvUKuXrn1ssBKxoHsk4bqo5Qu(1kp)oQJQ2mEWKdepUkgXfUj9upydscfLjYftnd0HmFgnJ4I2KEK3gj0dgEHtJycepE5DWG6xqn8qgJDHbbxI)CI3bDBD(vEzmScMLbLFhRrAJ8c00kCD5IKHn2u(1kVanTcxxUiz4FtYvP8RvUKuXrn1ssBKxoHs6qGnijuuMi)IJrZiSRPwsAJfv0iMaXJZLKkoQnJhm5jYiqVmeyKDK(puFqgufJ4c3KEQ3GKqrzICXuZaDiZNrZiUOnPNkLFTYZVJ6OQnJhm5aXJ3gj0dgEHtJycepE5DWGcneu5GHBmSco)owJ0g5fOPv46YfjJkAetG4X5x8Pw6OQpluZi2qEImc0ldbMfHEWW5OHGkhmCoYos)hQpid(ozKa5Trc9GHx40iMaXJxEhmOYVJ6OQnJhmngwbxWtRe(VWpiMKCy0K0KQIggqx8JBa9Z6vQs5xRCjPIJAZ4btoq84QOrmbIhNFXNAPJQ(SqnJyd5jYiqVmeyKDK(puFqgufnIjq84CjPIJAZ4btEImc0lQNSb0gj0dgEHtJycepE5DWG6Ip1shv9zHAgXgAmScUGNwj8FHFqmj5WOjPjvfnmGU4h3a6N1RuLzIg02uaoz887OoQAZ4bZ2iHEWWlCAetG4XlVdgux8Pw6OQpluZi2qJHvWf80kH)l8dIjjhgnjnPQOHb0f)4gq)SELQOrmbIhNljvCuBgpyYtKrGEziWi7i9FO(GmyBKqpy4fonIjq84L3bdkjPIJAZ4btJHvWMjAqBtb4KXV4tT0rvFwOMrSHTrc9GHx40iMaXJxEhmOU4tT0rvFwOMrSHgdRGzzqf80kH)l8dIjjhgnjnPSX2GOHb0f)4gq)SELKRILbLFhRrAJ8c00kCD5IKHn2u(1kVanTcxxUiz4FtYvP8RvUKuXrn1ssBKxoHs6qGnijuuMi)IJrZiSRPwsAJfv0iMaXJZLKkoQnJhm5jYiqVmeyKDK(puFqgufJ4c3KEQ3GKqrzICXuZaDiZNrZiUOnPNkLFTYZVJ6OQnJhm5aXJ3gj0dgEHtJycepE5DWG6Ip1shv9zHAgXgAmScMLbvWtRe(VWpiMKCy0K0KYgBdIggqx8JBa9Z6vsUkLFTYLKkoQPwsAJ8YjushcSbjHIYe5xCmAgHDn1ssBSO6Kj6hp)oQJQ2mEWufnIjq84887OoQAZ4btEImc0ldbgzhP)d1hKbvzqsOOmr(bzq93p4ulMQ3GKqrzI8lognJWUgaNYlDnsTy2gj0dgEHtJycepE5DWG6Ip1shv9zHAgXgAmScMLbvWtRe(VWpiMKCy0K0KYgBdIggqx8JBa9Z6vsUkLFTYLKkoQPwsAJ8YjushcSbjHIYe5xCmAgHDn1ssBSOILbDYe9JNFh1rvBgpyYgB0iMaXJZZVJ6OQnJhm5jYiqVOEdscfLjYV4y0mc7AaCkV01i1zysUkdscfLjYpidQ)(bNAXu9gKekktKFXXOze21a4uEPRrQfZ2iHEWWlCAetG4XlVdgu53rDu1MXdMgdRGzzqf80kH)l8dIjjhgnjnPSX2GOHb0f)4gq)SELKRs5xRCjPIJAZ4btoq84QyHgXeiEC(fFQLoQ6Zc1mInKNiJa9I6nijuuMipdtnJWUgaNYlDns9fhdBSrJycepoxsQ4O2mEWKNiJa9YqGnijuuMi)IJrZiSRbWP8sxJulMKRs5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusvrJycepoxsQ4O2mEWKNiJa9I6jBaQOrmbIhNFXNAPJQ(SqnJyd5jYiqVOEYgqBKqpy4fonIjq84L3bdQIfSEq3wBgpyAmSc2GKqrzI84FfiaQJQMgXeiE8sB0B6DGOG9Agm9ErVfwHpIQBWEfVxK9lLEfLEHEVNf2RJSF9sJycepEVpqhiEmU3VpXsPxsFLqX79SqV3WNV6f4Nq3UxjPIJ9Agpy2lWh79IETINEzex616725REtbak(1BXuss7fwAJe6bdVWPrmbIhV8oyqzMybDkQJQMb6agdRGpzI(XZVJ6OQnJhmvP8RvUKuXrTz8Gj)BQs5xR887OoQAZ4btEImc0ldztb4mc7Trc9GHx40iMaXJxEhmOmtSGof1rvZaDaJHvWaOYVw5x8Pw6OQpluZi2q(3ufaQ8Rv(fFQLoQ6Zc1mInKNiJa9Yqc9GHZLKkoQzGLcCIfoYos)hQpidQAq0Wa6IFCsFLqXBJe6bdVWPrmbIhV8oyqzMybDkQJQMb6agdRGv(1kp)oQJQ2mEWK)nvP8RvE(DuhvTz8Gjprgb6LHSPaCgHDv0iMaXJZrdbvoy48efGxQOrmbIhNFXNAPJQ(SqnJyd5jYiqVOAq0Wa6IFCsFLqXBJAJe6bdVWRqxMALF6GLKkoQzGLcCIfJHvWk)ALtNOKuPCq3MNOqpJPwc0btwBKqpy4fEf6YuR8t)DWGssQ4OwzkLRnsOhm8cVcDzQv(P)oyqjjvCuRizk2yBuB0B6vD3c9EZV7q3UxeEwy27zH9oo2BK9cA19ENOn6ascXIX9(G9(i(17f9Qozi6vbRrI9EwyVGoUboOgSHT3hOdep8EhikyVWRxP0BjcVxP0lRumS9AjLERqhwSqGEJF27dcIbS3Ij6xVXp7LAjPnwAJe6bdVWRWIf0T1Hj6ycgneu5GHBmScML87ynsBKFiJzKYu)iPjBSXs(DSgPnYlqtRW1LlsgvdYGKqrzICZen)ZPgneGjJCYvXIYVw553rDu1MXdMCG4XzJnZenOTPaCY4ssfh1ksMInsUkAetG4X553rDu1MXdM8ezeOxAJEtVSY1EFqqmG9wHoSyHa9g)SxAetG4X79b6aXtPxXb6TyI(1B8ZEPwsAJfJ71mHrcpO6gSx1jdrVHbm7fnG5RZc629IZc2gj0dgEHxHflOBRdt0X8DWGcneu5GHBmSc(Kj6hp)oQJQ2mEWufnIjq84887OoQAZ4btEImc0lQOrmbIhNljvCuBgpyYtKrGErLYVw5ssfh1MXdMCG4XvP8RvE(DuhvTz8GjhiECvMjAqBtb4KXLKkoQvKmfBSnsOhm8cVclwq3whMOJ57GbvfMOwzkLZyyfC(DSgPnYbGfk0CcDjFPPbdJ4aQu(1khawOqZj0L8LMgmmIdORzuo(3SnsOhm8cVclwq3whMOJ57GbvnJYP9WGymSco)owJ0g52jSmFPHuiDIQyex4M0t9QR32gj0dgEHxHflOBRdt0X8DWGssQ4OMbwkWjwmgwbNFhRrAJCjPIJAljzc)LkLFTYLKkoQTKKj8x8Yjushs5xRCjPIJAljzc)fNryxxoHsQkwyr5xRCjPIJAZ4btoq84QOrmbIhNljvCuBgpyYtuaEroBSbGk)ALFXNAPJQ(SqnJyd5FtYnMAjqhmzTrc9GHx4vyXc626WeDmFhmOaq5SuI0rJHvW0Wb(WJBdRNoQ6Zc1ti1QnsOhm8cVclwq3whMOJ57Gbv(DuhvTz8GPXWk487ynsBKxGMwHRlxKmTrc9GHx4vyXc626WeDmFhmOKKkoQJuXyyfmnIjq84887OoQAZ4btEIcWR2iHEWWl8kSybDBDyIoMVdgussfh1ktPCgdRGPrmbIhNNFh1rvBgpyYtuaEPs5xRCjPIJAQLK2iVCcL0Hu(1kxsQ4OMAjPnYze21LtOK2gj0dgEHxHflOBRdt0X8DWGIbMzKfDu1xKmOFgdRGpidQEWV9DwiBGvWtRe(VWpiMKCy0dUjL82iHEWWl8kSybDBDyIoMVdgu)cQHhYySlmiyMi8j80MjSWymSc(GmO6vhTrc9GHx4vyXc626WeDmFhmOYVJ6OQnJhmBJEtVSY1EFqqsSx56LryV3Yjusl9g1Eh(W7vCGEFWETedOdY17VGa9oWdq37l8mU3Fb7v6TCcL0EVOxZenG(1lZ3Pwq3U3VpXsP387o0T79SWEvNtsMWF17eTrhqYxTrc9GHx4vyXc626WeDmFhmOKKkoQzGLcCIfJHvWk)ALtNOKuPCq3MNOqpvk)ALtNOKuPCq3MxoHskyLFTYPtusQuoOBZze21LtOKQIggqx8JBa9Z6vQIgXeiECodmZil6OQVizq)4jkaVunidscfLjYrgZ4bteqRizk2OkAetG4X5ssfh1MXdM8efGxTrVPx1ejJmNV69b71uGzVMXbdV3Fb79bEw9oydRX9Q8VEHxVpW5S3PuUENHB3l6X32Q3AK9QeNvVNf2lRumS9koqVd2W27d0bINsVFFILsV53DOB37zH9oo2BK9cA19ENOn6ascXsBKqpy4fEfwSGUTomrhZ3bdkZ4GHBmScEq53XAK2i)qgZiLP(rstvSmO87ynsBKxGMwHRlxKmSXglgKekktKBMO5Fo1OHamzQu(1kxsQ4OMAjPnYlNqjfSYVw5ssfh1uljTroJWUUCcLuYjVnsOhm8cVclwq3whMOJ57GbfakNLsKoAmScw5xR887OoQAZ4btoq84SXMzIg02uaozCjPIJAfjtXgBJe6bdVWRWIf0T1Hj6y(oyqLcau8txmLKuJHvWk)ALNFh1rvBgpyYbIhNn2mt0G2McWjJljvCuRizk2yBKqpy4fEfwSGUTomrhZ3bdkgyMrw0rvFrYG(zmScw5xR887OoQAZ4btEImc0ldXI64DsoWYVJ1iTrEbAAfUUCrYqEB0B6vD3c9EZV7q3U3Zc7vDojzc)vVt0gDajFzCV)c27GnS9QG1iXEbDCd8EVOxGpJzVsV1)C(Q3YjusrGEvKmfBSnsOhm8cVclwq3whMOJ57GbLKuXrTz8GPXWkydscfLjYrgZ4bteqRizk2OkLFTYZVJ6OQnJhm5FtvSWiUWnP3qSqY3(olKnGbgnmGU4hN0xjuCYjNn2u(1kNorjPs5GUnVCcLuWk)ALtNOKuPCq3MZiSRlNqjL82iHEWWl8kSybDBDyIoMVdgussfh1ksMInAmSc2GKqrzICKXmEWeb0ksMInQs5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusvP8RvUKuXrTz8Gj)B2gj0dgEHxHflOBRdt0X8DWG6xqn8qgJDHbbxI)CI3bDBD(vEzmScw5xR887OoQAZ4btoq84SXMzIg02uaozCjPIJAfjtXgzJnZenOTPaCY4Paaf)0ftjjLn2yXmrdABkaNmoakNLsKoQAq53XAK2iVanTcxxUiziVnsOhm8cVclwq3whMOJ57Gb1fFQLoQ6Zc1mIn0yyfSYVw553rDu1MXdMCG4XzJnZenOTPaCY4ssfh1ksMInYgBMjAqBtb4KXtbak(PlMsskBSXIzIg02uaozCauolLiDu1GYVJ1iTrEbAAfUUCrYqEBKqpy4fEfwSGUTomrhZ3bdkjPIJAZ4btJHvWMjAqBtb4KXV4tT0rvFwOMrSHTrVP3bIc27Wgd8EVO3cRWhr1nyVI3lY(LsVdwsfh7L1tPC9c8tOB37zH9c64g4GAWg2EFGoq8073NyP0B(Dh629oyjvCSx1jQvW7LvU27GLuXXEvNOwrVWsVNmr)qaJ79b7LkoixV)c27Wgd8EFGNf079SWEbDCdCqnydBVpqhiE697tSu69b7f6hM53869SWEhSbEVulXDCACVLO3heK5S3Iya7fE82iHEWWl8kSybDBDyIoMVdguMjwqNI6OQzGoGXWk4bDYe9JljvCuJuRqfaQ8Rv(fFQLoQ6Zc1mInK)nvbGk)ALFXNAPJQ(SqnJyd5jYiqVmeywe6bdNljvCuRmLYXr2r6)q9bzWbMYVw5MjwqNI6OQzGoaNryxxoHsk5TrVPxw5AVdBmW71skoixVki69(liqVa)e629EwyVGoUbEVpqhiEmU3heK5S3Fb7fE9ErVfwHpIQBWEfVxK9lLEhSKko2lRNs56f69EwyVSsXWcQbBy79b6aXdVnsOhm8cVclwq3whMOJ57GbLzIf0POoQAgOdymScw5xRCjPIJAZ4bt(3uLYVw553rDu1MXdM8ezeOxgcmlc9GHZLKkoQvMs54i7i9FO(Gm4at5xRCZelOtrDu1mqhGZiSRlNqjL82iHEWWl8kSybDBDyIoMVdgussfh1ktPCgdRGbIJNcau8txmLKuEImc0lQ)TSXgaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekPQFaTrVPx1DS3hXVEVOxgHuS3YpXEFWETedyVOhFBREzex6TgzVNf2l6hmXEhSHT3hOdepg3lAa9EH1Eplmrqk9wo4C27bzWEtKrGo0T7n8EzLIHL3lR8bsP3WNV6vbVdZEVOxLF69ErVQBWm6vCGEvNme9cR9MF3HUDVNf274yVr2lOv37DI2Odijel82iHEWWl8kSybDBDyIoMVdgussfh1ksMInAmScMgXeiECUKuXrTz8Gjprb4LkgXfUj9gILbFaVZczdyGrddOl(Xj9vcfNCYvP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQyzq53XAK2iVanTcxxUizyJndscfLjYnt08pNA0qaMmYvnO87ynsBKFiJzKYu)iPPQbLFhRrAJCjPIJAljzc)vB0B6L1sMIn2BXk(tGE946vb79xqGELR3Zc7fDGEJAVd2W2lS2R6KHGkhm8EHLEtuaE1Ru6fidttOB3l1ssBS07dCo7Lrif7fE9EcPyVZWTXS3l6v5NEVNvgFBREtKrGo0T7LrCPnsOhm8cVclwq3whMOJ57GbLKuXrTIKPyJgdRGv(1kxsQ4O2mEWK)nvP8RvUKuXrTz8Gjprgb6LHaBtburJycepohneu5GHZtKrGEPn6n9YAjtXg7Tyf)jqVY8rEv6vb79SWENs56LkLRxO37zH9YkfdBVpqhiE6vk9c64g49(aNZEtSCrI9EwyVuljTXsVft0V2iHEWWl8kSybDBDyIoMVdgussfh1ksMInAmScw5xR887OoQAZ4bt(3uLYVw5ssfh1MXdMCG4XvP8RvE(DuhvTz8Gjprgb6LHaBtbunO87ynsBKljvCuBjjt4VAJe6bdVWRWIf0T1Hj6y(oyqjjvCuZalf4elgdRGbqLFTYV4tT0rvFwOMrSH8VPQtMOFCjPIJAKAfQyr5xRCauolLiDKdepoBSj0dAa1OJmqSaMmYvbGk)ALFXNAPJQ(SqnJyd5jYiqVOEHEWW5ssfh1mWsboXchzhP)d1hKbnMAjqhmzgJsoFPPwc01WkyLFTYPtusQuoOBRPwI74KdepUkwu(1kxsQ4O2mEWK)nzJnwg0jt0pEyatZ4bteqflk)ALNFh1rvBgpyY)MSXgnIjq84C0qqLdgoprb4f5KtEB0B6LvU27dcsI9Aa9Z6vACVqggeakhoF17VG9o8H37Jf69sftteO3l61JR3hPCyVMzql9wZGP3bEa62iHEWWl8kSybDBDyIoMVdgussfh1mWsboXIXWkyAyaDXpUb0pRxPkLFTYPtusQuoOBZlNqjfSYVw50jkjvkh0T5mc76YjusBJEtVJNKxV)c0T7D4dV3bBG37Jf69oydBVwsPxfe9E)feOnsOhm8cVclwq3whMOJ57GbLKuXrndSuGtSymScw5xRC6eLKkLd628ef6PIgXeiECUKuXrTz8Gjprgb6fvSO8RvE(DuhvTz8Gj)BYgBk)ALljvCuBgpyY)MKBm1sGoyYAJe6bdVWRWIf0T1Hj6y(oyqjjvCuhPIXWkyLFTYLKkoQPwsAJ8YjushcSbjHIYe5xCmAgHDn1ssBS0gj0dgEHxHflOBRdt0X8DWGssQ4OwzkLZyyfSYVw553rDu1MXdM8VjBSXiUWnPN6j7TTrc9GHx4vyXc626WeDmFhmOqdbvoy4gdRGv(1kp)oQJQ2mEWKdepUkLFTYLKkoQnJhm5aXJBm0pmZV5PHvWmIlCt6PEWdZBng6hM5380qggeakhcMS2iHEWWl8kSybDBDyIoMVdgussfh1ksMIn2g1g9M307aHx(MMrEiqVuXP4ul0dgU68Ux1jdbvoy49(aNZEvWED5(PmNV6vjdsrVxyTxA4aWdgEPxjXEzWJ3g9M30Rqpy4fULKmH)cmvCko1c9GHBmScwOhmCoAiOYbdNtTe3Xj0TvXiUWnPN6bRUEBB0B6LvU27mE6n8Ezex6vCGEPrmbIhV0RKyV0Gb629(nnUx7OxXcfGEfhOx0q0gj0dgEHBjjt4VEhmOqdbvoy4gdRGzex4M0BiWKWauzqsOOmrE8Vcea1rvtJycepErflNmr)453rDu1MXdMQOrmbIhNNFh1rvBgpyYtKrGEziYga5TrVPx1DS3hXVEVO3Yjus71ssMWF1B9pNV49cAlS3Fb7nQ9sM6O3Yjusl9AHj2lS07f9kuA89R3AK9EwyVhKsAVtSE9gEVNf2l1sChN9koqVNf2ldSuGtSxO3BDcTToEBKqpy4fULKmH)6DWGssQ4OMbwkWjwmgwbZIbjHIYe5LtOKQTKKj8xSX2bzWHiBaKRs5xRCjPIJAljzc)fVCcL0HitDym1sGoyYAJEtVQ7wO37VaD7EvNymFLOm7vDwc4ItrJ7LkLRxP3k(0lY(LsVmWsboXsVpwWj27JapOB3BnYEplSxLFT2RC9EwyVLtYR3O27zH9wH2wxBKqpy4fULKmH)6DWGssQ4OMbwkWjwmgwbJScFOPjcWrgZxjktDKaU4uu1bzWHiHbOIgXeiECoYy(krzQJeWfNI8ezeOxupzQJHr1Ge6bdNJmMVsuM6ibCXPihaweLjc0gj0dgEHBjjt4VEhmO(fudpKXyxyqWL4pN4Dq3wNFLxgdRGv(1kxsQ4O2mEWK)nvDsAJhhawoXP4qGjBaTrc9GHx4wsYe(R3bdQFb1Wdzm2fgeCj(ZjEh0T15x5LXWkydscfLjYrgZ4bteqRizk2OkAetG4X5x8Pw6OQpluZi2qEImc0ldbgzhP)d1hKbvrJycepoxsQ4O2mEWKNiJa9YqGzbzhP)d1hKbhyKKCvNK24XbGLtCkQEYgqBKqpy4fULKmH)6DWGkfaO4NUykjPgdRGnijuuMihzmJhmraTIKPyJQOrmbIhNFXNAPJQ(SqnJyd5jYiqVmeyKDK(puFqgufnIjq84CjPIJAZ4btEImc0ldbMfKDK(puFqgCGrsYvXYGqwHp00eb4L4pN4Dq3wNFLxSXgnCGp84ssfh1MzaaTFXtXjv9GFlBSXYLqNu84L4pN4Dq3wNFLxCAetG4X5jYiqVOEYiBaQojTXJdalN4uu9KnaYzJnwUe6KIhVe)5eVd6268R8ItJycepoprgb6LHaJSJ0)H6dYGQojTXJdalN4uCiWKnaYjVnsOhm8c3ssMWF9oyqDXNAPJQ(SqnJydngwbBqsOOmr(a5VC6Fbb0ftjjvfnIjq84CjPIJAZ4btEImc0ldbgzhP)d1hKbvXYGqwHp00eb4L4pN4Dq3wNFLxSXgnCGp84ssfh1MzaaTFXtXjv9GFlBSXYLqNu84L4pN4Dq3wNFLxCAetG4X5jYiqVOEYiBaQojTXJdalN4uu9KnaYzJnwUe6KIhVe)5eVd6268R8ItJycepoprgb6LHaJSJ0)H6dYGQojTXJdalN4uCiWKnaYjVnsOhm8c3ssMWF9oyqjjvCuBgpyAmSc2mrdABkaNm(fFQLoQ6Zc1mInSnsOhm8c3ssMWF9oyqLFh1rvBgpyAmSc2GKqrzICKXmEWeb0ksMInQIgXeiECEkaqXpDXuss5jYiqVmeyKDK(puFqguLbjHIYe5hKb1F)GtTyQEWKCaQyzq0Wb(WJljvCuBMba0(fBSnidscfLjYL5J8QOlVCQMgXeiE8cBSrJycepo)Ip1shv9zHAgXgYtKrGEziWSGSJ0)H6dYGdmsso5Trc9GHx4wsYe(R3bdQuaGIF6IPKKAmSc2GKqrzICKXmEWeb0ksMInQYmrdABkaNmE(DuhvTz8GzBKqpy4fULKmH)6DWG6Ip1shv9zHAgXgAmSc2GKqrzI8bYF50)ccOlMssQQbzqsOOmrUvmbGUT(IJPn6n9oquWEjPd0RKuXXEvKmfBSxO37GnSVZkPoBy7n85REH1Ez9mcG5VC9koqVY17eLY1lj7D4dV0Rzgukc0gj0dgEHBjjt4VEhmOKKkoQvKmfB0yyfSYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKQs5xR887OoQAZ4bt(3uLYVw5ssfh1MXdM8VPkLFTYLKkoQTKKj8x8YjusvpyYuhQu(1kxsQ4O2mEWKNiJa9YqGf6bdNljvCuRizk2ihzhP)d1hKbvP8RvUYmcG5VC8VzB0B6DGOG9sshOxwPyy7f69oydBVHpF1lS2lRNram)LRxXb6LK9o8Hx61mdABKqpy4fULKmH)6DWGk)oQJQ2mEW0yyfSYVw553rDu1MXdMCG4XvP8RvUYmcG5VC8VPkwmijuuMi)GmO(7hCQft1tcdGn2OrmbIhNNcau8txmLKuEImc0lQNmssUkwu(1kxsQ4O2ssMWFXlNqjv9Gj7TSXMYVw50jkjvkh0T5LtOKQEWKrUkwgenCGp84ssfh1MzaaTFXgBdYGKqrzICz(iVk6YlNQPrmbIhVqEBKqpy4fULKmH)6DWGk)oQJQ2mEW0yyfSYVw5ssfh1MXdMCG4XvXIbjHIYe5hKb1F)GtTyQEsyaSXgnIjq848uaGIF6IPKKYtKrGEr9KrsYvXYGOHd8HhxsQ4O2mdaO9l2yBqgKekktKlZh5vrxE5unnIjq84fYBJe6bdVWTKKj8xVdguPaaf)0ftjj1yyfSbjHIYe5iJz8GjcOvKmfBuflk)ALljvCutTK0g5LtOKQEWKKn2OrmbIhNljvCuhPcprb4f5QyzqNmr)453rDu1MXdMSXgnIjq84887OoQAZ4btEImc0lQ)TKRIgXeiECUKuXrTz8Gjprgb6fnYUjspeq9GjHbOILbrdh4dpUKuXrTzgaq7xSX2GmijuuMixMpYRIU8YPAAetG4XlK3g9MEv3TqV387o0T71mdaO9lJ79xWEV4y6v5vVWRGZAVqV3ibWS3l6vMqBVx417d8S6vmBJe6bdVWTKKj8xVdgux8Pw6OQpluZi2qJHvWgKekktKFqgu)9do1I5qVDaQmijuuMi)GmO(7hCQft1tcdqfldczf(qtteGxI)CI3bDBD(vEXgB0Wb(WJljvCuBMba0(fpfNu1d(TK3gj0dgEHBjjt4VEhmOKKkoQJuXyyfSbjHIYe5dK)YP)feqxmLKuvk)ALljvCutTK0g5LtOKoKYVw5ssfh1uljTroJWUUCcL02O38MEv3TqV3Fb629QoNKmHdP9QorTcJ79v87fi61JR3hXVEVOxwHp(XEhSKko2lRLmfBSxGFcD7EplS3blPIJ9Y6PuUEPs5AJEZB6vOhm8c3ssMWF9oyq9iWZ4csbpa(agCJHvWaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOKcMfau5xR8uaGIF6IPKKQn8NoMIcCcVxCgHDD5ekPSIKrUQ87ynsBKBjjt4qQgPwHkHEqdOgDKbIf1tMXtOJAkays(22iHEWWlCljzc)17GbLKuXrTIKPyJgdRGbqLFTYtbak(PlMssQ2WF6ykkWj8EXlNqjfmaQ8RvEkaqXpDXuss1g(thtrboH3loJWUUCcL02iHEWWlCljzc)17GbLKuXrTYukNXWkydscfLjYhi)Lt)liGUykjPSXglaOYVw5Paaf)0ftjjvB4pDmff4eEV4FtvaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOKoeaQ8RvEkaqXpDXuss1g(thtrboH3loJWUUCcLuYBJEtVdefSxgOd7L1sMIn2RcEpi69Mcau8R3IPKKw6fw797ay2lRjXEFGNv8VEbWP8c629YkjaqXVEhnLK0EHaOmNVAJe6bdVWTKKj8xVdgussfh1ksMInAmScw5xR887OoQAZ4bt(3uLYVw5ssfh1MXdMCG4XvP8RvUYmcG5VC8VPkAetG4X5Paaf)0ftjjLNiJa9YqGjBaQu(1kxsQ4O2ssMWFXlNqjv9GjtD0g9MEhikyVrQ0B49sb697tSu6vm7fw6Lgmq3U3VzVLi82iHEWWlCljzc)17GbLKuXrDKkgdRGv(1kxsQ4OMAjPnYlNqjDisqLbjHIYe5hKb1F)GtTyQEYgGkwOrmbIhNFXNAPJQ(SqnJyd5jYiqVO(3YgBdIgoWhECjPIJAZmaG2ViVnsOhm8c3ssMWF9oyqjjvCuZalf4elgdRGv(1kNorjPs5GUnprHEQu(1kxsQ4O2mEWK)nnMAjqhmzTrVPxw5AVpyV241Rz8GzVqV(lWW7f4Nq3U35VC9(GGmN9AjgWErp(2w9AjLd79IETXR3Ow7v6TCz429Qizk2yVa)e629EwyVzyckXS3hOdepTrc9GHx4wsYe(R3bdkjPIJAfjtXgngwbR8RvE(DuhvTz8Gj)BQs5xR887OoQAZ4btEImc0ldbwOhmCUKuXrndSuGtSWr2r6)q9bzqvk)ALljvCuBgpyY)MQu(1kxsQ4OMAjPnYlNqjfSYVw5ssfh1uljTroJWUUCcLuvk)ALljvCuBjjt4V4LtOKQs5xRCZ4btn0R)cmC(3uLYVw5kZiaM)YX)MTrVPxw5AVpyV241Rz8GzVqV(lWW7f4Nq3U35VC9(GGmN9AjgWErp(2w9AjLd79IETXR3Ow7v6TCz429Qizk2yVa)e629EwyVzyckXS3hOdepg3Bj69bbzo7n85RE)fSx0JVTvVktPCLEHo8GYC(Q3l61gVEVO3A8ZEPwsAJL2iHEWWlCljzc)17GbLKuXrTYukNXWkyLFTYntSGof1rvZaDa(3uflk)ALljvCutTK0g5LtOKoKYVw5ssfh1uljTroJWUUCcLu2yBqSO8RvUz8GPg61Fbgo)BQs5xRCLzeaZF54FtYjx1Gyr5xRCjPIJAQLK2iVCcLuWdqLYVw5MjwqNI6OQzGoaVCcLuWKrEB0B6f0wyVky569xWEJAVMbtVWsVx07VG9cVEVOxwHpKs68vVkF4eOxQLK2yPxGFcD7EfZEL6HzVNf(QxB86f4ZyIa9Q8Q3Zc71ssMWF1RIKPyJTrc9GHx4wsYe(R3bdkZelOtrDu1mqhWyyfSYVw5ssfh1uljTrE5ekPdP8RvUKuXrn1ssBKZiSRlNqjvLYVw5ssfh1MXdM8VzB0B6vDh79r8R3l6TCcL0ETKKj8x9w)Z5lEVG2c79xWEJAVKPo6TCcL0sVwyI9cl9ErVcLgF)6TgzVNf27bPK27eRxVH37zH9sTe3XzVId07zH9Yalf4e7f69wNqBRJ3gj0dgEHBjjt4VEhmOKKkoQzGLcCIfJHvWk)ALljvCuBjjt4V4LtOKoezQdJPwc0btMXq)Wm)MhyYmg6hM53802ZqrMGjRnsOhm8c3ssMWF9oyqjjvCuRizk2OXWkyLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjvLbjHIYe5iJz8GjcOvKmfBSnsOhm8c3ssMWF9oyqHgcQCWWngwbZiUWnP3qK922O30R6mF(Q3Fb7vzkLR3l6v5dNa9sTK0gl9cR9(G9kZefGx9AjgWElbd2BndMEJuPnsOhm8c3ssMWF9oyqjjvCuRmLYzmScw5xRCjPIJAQLK2iVCcLuvk)ALljvCutTK0g5LtOKoKYVw5ssfh1uljTroJWUUCcL02O30R68bNZEFGNvVctVFFILsVIzVWsV0Gb629(n7vCGEFqqsS3z80B49YiU0gj0dgEHBjjt4VEhmOKKkoQzGLcCIfJHvWdIfdscfLjYpidQ)(bNAXCiWKnavmIlCt6nejmaYnMAjqhmzgd9dZ8BEGjZyOFyMFZtBpdfzcMS2O307WMrfoXsVpWZQ3z80lJuomFzCVwqBRETKYHg3BK9QeNvVmYRE9461smG9IE8TT6LrCP3l6T8nnJ861kE6LrCPxOFOxGgWEtbak(1BXuss7LkEVkOX9wIEFqqMZE)fS3kmXEvMs56vCGERzuoLyE9(yHEVZ4P3W7LrCPnsOhm8c3ssMWF9oyqvHjQvMs5AJe6bdVWTKKj8xVdgu1mkNsmV2O2iHEWWl8WeDmbxHjQvMs5mgwbNFhRrAJCayHcnNqxYxAAWWioGkLFTYbGfk0CcDjFPPbdJ4a6AgLJ)nBJe6bdVWdt0X8DWGQMr50EyqmgwbNFhRrAJC7ewMV0qkKorvmIlCt6PE11BBJe6bdVWdt0X8DWG6xqn8qgJDHbbxI)CI3bDBD(vE1gj0dgEHhMOJ57GbfakNLsKo2gj0dgEHhMOJ57GbvkaqXpDXussngwbZiUWnPN6h8b0gj0dgEHhMOJ57GbfdmZil6OQVizq)AJe6bdVWdt0X8DWGQybRh0T1MXdMgdRGv(1kxsQ4O2mEWKdepUkAetG4X5ssfh1MXdM8ezeOxAJe6bdVWdt0X8DWGssQ4OosfJHvW0iMaXJZLKkoQnJhm5jkaVuP8RvUKuXrn1ssBKxoHs6qk)ALljvCutTK0g5mc76YjusBJe6bdVWdt0X8DWGssQ4OwzkLZyyfmnmGU4h3a6N1RufnIjq84CgyMrw0rvFrYG(XtKrGEr9dZG3gj0dgEHhMOJ57Gb1fFQLoQ6Zc1mInSnsOhm8cpmrhZ3bdkjPIJAZ4bZ2iHEWWl8WeDmFhmOYVJ6OQnJhmngwbR8RvUKuXrTz8GjhiE82O307arb7DyJbEVx0BHv4JO6gSxX7fz)sP3blPIJ9Y6PuUEb(j0T79SWEbDCdCqnydBVpqhiE697tSu6n)UdD7EhSKko2R6e1k49Ykx7DWsQ4yVQtuROxyP3tMOFiGX9(G9sfhKR3Fb7DyJbEVpWZc69EwyVGoUboOgSHT3hOdep9(9jwk9(G9c9dZ8BE9EwyVd2aVxQL4oonU3s07dcYC2BrmG9cpEBKqpy4fEyIoMVdguMjwqNI6OQzGoGXWk4bDYe9JljvCuJuRqfaQ8Rv(fFQLoQ6Zc1mInK)nvbGk)ALFXNAPJQ(SqnJyd5jYiqVmeywe6bdNljvCuRmLYXr2r6)q9bzWbMYVw5MjwqNI6OQzGoaNryxxoHsk5TrVPxw5AVdBmW71skoixVki69(liqVa)e629EwyVGoUbEVpqhiEmU3heK5S3Fb7fE9ErVfwHpIQBWEfVxK9lLEhSKko2lRNs56f69EwyVSsXWcQbBy79b6aXdVnsOhm8cpmrhZ3bdkZelOtrDu1mqhWyyfSYVw5ssfh1MXdM8VPkLFTYZVJ6OQnJhm5jYiqVmeywe6bdNljvCuRmLYXr2r6)q9bzWbMYVw5MjwqNI6OQzGoaNryxxoHsk5Trc9GHx4Hj6y(oyqjjvCuRmLYzmScgioEkaqXpDXuss5jYiqVO(3YgBaOYVw5Paaf)0ftjjvB4pDmff4eEV4LtOKQ(b0g9MEhS5J8Q0lRLmfBSx569SWErhO3O27GnS9(yHEV53DOB37zH9oyjvCSx15KKj8x9orB0bK8vBKqpy4fEyIoMVdgussfh1ksMInAmScw5xRCjPIJAZ4bt(3uLYVw5ssfh1MXdM8ezeOxgYMcOk)owJ0g5ssfh1wsYe(R2O307GnFKxLEzTKPyJ9kxVNf2l6a9g1EplSxwPyy79b6aXtVpwO3B(Dh629EwyVdwsfh7vDojzc)vVt0gDajF1gj0dgEHhMOJ57GbLKuXrTIKPyJgdRGv(1kp)oQJQ2mEWK)nvP8RvUKuXrTz8GjhiECvk)ALNFh1rvBgpyYtKrGEziW2uav53XAK2ixsQ4O2ssMWF1gj0dgEHhMOJ57GbLKuXrndSuGtSymScgav(1k)Ip1shv9zHAgXgY)MQozI(XLKkoQrQvOIfLFTYbq5SuI0roq84SXMqpObuJoYaXcyYixfaQ8Rv(fFQLoQ6Zc1mInKNiJa9I6f6bdNljvCuZalf4elCKDK(puFqg0yQLaDWKzmk58LMAjqxdRGv(1kNorjPs5GUTMAjUJtoq84Qyr5xRCjPIJAZ4bt(3Kn2yzqNmr)4HbmnJhmravSO8RvE(DuhvTz8Gj)BYgB0iMaXJZrdbvoy48efGxKto5Trc9GHx4Hj6y(oyqjjvCuZalf4elgdRGv(1kNorjPs5GUnVCcLuWk)ALtNOKuPCq3MZiSRlNqjvfnmGU4h3a6N1RSnsOhm8cpmrhZ3bdkjPIJAgyPaNyXyyfSYVw50jkjvkh0T5jk0tfnIjq84CjPIJAZ4btEImc0lQyr5xR887OoQAZ4bt(3Kn2u(1kxsQ4O2mEWK)nj3yQLaDWK1gj0dgEHhMOJ57GbLKuXrDKkgdRGv(1kxsQ4OMAjPnYlNqjDiWgKekktKFXXOze21uljTXsBKqpy4fEyIoMVdgussfh1ktPCgdRGv(1kp)oQJQ2mEWK)nzJngXfUj9upzVTnsOhm8cpmrhZ3bdk0qqLdgUXWkyLFTYZVJ6OQnJhm5aXJRs5xRCjPIJAZ4btoq84gd9dZ8BEAyfmJ4c3KEQh8W8wJH(Hz(npnKHbbGYHGjRnsOhm8cpmrhZ3bdkjPIJAfjtXgBJAJEZB6vOhm8cpJtoy4GPItXPwOhmCJHvWc9GHZrdbvoy4CQL4ooHUTkgXfUj9upy11BvXYGYVJ1iTrEbAAfUUCrYWgBk)ALxGMwHRlxKm8YjusbR8RvEbAAfUUCrYWze21LtOKsEB0B6DGOG9IgIEH1EFqqsS3z80B49YiU0R4a9sJycepEPxjXEfL4F9ErVkyVFZ2iHEWWl8mo5GH)oyqjjvCuRizk2OXWk4cEALW)f(bXKKdJMKMuv0Wa6IFCdOFwVsv0iMaXJZZVJ6OQnJhm5jYiqVmeyKDK(puFqgufnIjq848l(ulDu1NfQzeBiprgb6LHibvSO8RvUKuXrn1ssBKxoHsQ6nijuuMi)IJrZiSRPwsAJfvNmr)453rDu1MXdMQmijuuMi)GmO(7hCQft1BqsOOmr(fhJMryxdGt5LUgPwmjVnsOhm8cpJtoy4Vdgussfh1ksMInAmScMLbvWtRe(VWpiMKCy0K0KYgBdIggqx8JBa9Z6vsUkAetG4X5x8Pw6OQpluZi2qEIcWlvSO8RvUKuXrn1ssBKxoHsQ6nijuuMi)IJrZiSRPwsAJfv0iMaXJZLKkoQnJhm5jYiqVmeyKDK(puFqgufJ4c3KEQ3GKqrzICXuZaDiZNrZiUOnPNkLFTYZVJ6OQnJhm5aXJtEBKqpy4fEgNCWWFhmOKKkoQvKmfB0yyfmldQGNwj8FHFqmj5WOjPjLn2genmGU4h3a6N1RKCv0iMaXJZV4tT0rvFwOMrSH8efGxQyr5xRCjPIJAQLK2iVCcLu1BqsOOmr(fhJMryxtTK0glQozI(XZVJ6OQnJhmvrJycepop)oQJQ2mEWKNiJa9YqGr2r6)q9bzqvgKekktKFqgu)9do1IP6nijuuMi)IJrZiSRbWP8sxJulMK3gj0dgEHNXjhm83bdkjPIJAfjtXgngwbZYGk4Pvc)x4hetsomAsAszJTbrddOl(XnG(z9kjxfnIjq848l(ulDu1NfQzeBiprb4Lkwu(1kxsQ4OMAjPnYlNqjv9gKekktKFXXOze21uljTXIkwg0jt0pE(DuhvTz8GjBSrJycepop)oQJQ2mEWKNiJa9I6nijuuMi)IJrZiSRbWP8sxJuNHj5QmijuuMi)GmO(7hCQft1BqsOOmr(fhJMryxdGt5LUgPwmjVnsOhm8cpJtoy4Vdgussfh1ksMInAmScgav(1kpfaO4NUykjPAd)PJPOaNW7fVCcLuWaOYVw5Paaf)0ftjjvB4pDmff4eEV4mc76YjusvXIYVw5ssfh1MXdMCG4XzJnLFTYLKkoQnJhm5jYiqVmeyBka5Qyr5xR887OoQAZ4btoq84SXMYVw553rDu1MXdM8ezeOxgcSnfG82iHEWWl8mo5GH)oyqjjvCuRmLYzmSc2GKqrzI8bYF50)ccOlMsskBSXcaQ8RvEkaqXpDXuss1g(thtrboH3l(3ufaQ8RvEkaqXpDXuss1g(thtrboH3lE5ekPdbGk)ALNcau8txmLKuTH)0XuuGt49IZiSRlNqjL82iHEWWl8mo5GH)oyqjjvCuRmLYzmScw5xRCZelOtrDu1mqhG)nvbGk)ALFXNAPJQ(SqnJyd5FtvaOYVw5x8Pw6OQpluZi2qEImc0ldbwOhmCUKuXrTYukhhzhP)d1hKbBJe6bdVWZ4Kdg(7GbLKuXrndSuGtSymScgav(1k)Ip1shv9zHAgXgY)MQozI(XLKkoQrQvOIfLFTYbq5SuI0roq84SXMqpObuJoYaXcyYixflaOYVw5x8Pw6OQpluZi2qEImc0lQxOhmCUKuXrndSuGtSWr2r6)q9bzq2yJgXeiECUzIf0POoQAgOdWtKrGEHn2OHb0f)4K(kHItUXulb6GjZyuY5ln1sGUgwbR8RvoDIssLYbDBn1sChNCG4XvXIYVw5ssfh1MXdM8VjBSXYGozI(XddyAgpyIaQyr5xR887OoQAZ4bt(3Kn2OrmbIhNJgcQCWW5jkaViNCYBJEtVdp8YNb79SWEr2nfhab61mo0pOm7v5xR9kfXS3l61JR3zuWEnJd9dkZEnZGwAJe6bdVWZ4Kdg(7GbLKuXrndSuGtSymScw5xRC6eLKkLd628ef6Ps5xRCKDtXbqaTzCOFqzY)MTrc9GHx4zCYbd)DWGssQ4OMbwkWjwmgwbR8RvoDIssLYbDBEIc9uXIYVw5ssfh1MXdM8VjBSP8RvE(DuhvTz8Gj)BYgBaOYVw5x8Pw6OQpluZi2qEImc0lQxOhmCUKuXrndSuGtSWr2r6)q9bzqYnMAjqhmzTrc9GHx4zCYbd)DWGssQ4OMbwkWjwmgwbR8RvoDIssLYbDBEIc9uP8RvoDIssLYbDBE5ekPGv(1kNorjPs5GUnNryxxoHsQXulb6GjRn6n9oyZh5vP3lF17f9QioP9o8H3BnYEPrmbIhV3hOdepLEv(xVaFgZEplKPxyT3ZcFbsI9kkX)69IEr2nHj2gj0dgEHNXjhm83bdkjPIJAgyPaNyXyyfSYVw50jkjvkh0T5jk0tLYVw50jkjvkh0T5jYiqVmeywyr5xRC6eLKkLd628Yjushyc9GHZLKkoQzGLcCIfoYos)hQpids(72uaoJWo5gtTeOdMS2iHEWWl8mo5GH)oyq54zHP(qgtSCgdRGzjXAIflrzISX2GoiLuOBtUkLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjvLYVw5ssfh1MXdMCG4XvbGk)ALFXNAPJQ(SqnJyd5aXJ3gj0dgEHNXjhm83bdkjPIJ6ivmgwbR8RvUKuXrn1ssBKxoHs6qGnijuuMi)IJrZiSRPwsAJL2iHEWWl8mo5GH)oyqv(My6HbXyyfSbjHIYe5X)kqauhvnnIjq84fvmIlCt6ney11BBJe6bdVWZ4Kdg(7GbLKuXrTYukNXWkyLFTYZ)e1rvFwjIf(3uLYVw5ssfh1uljTrE5ekPQNeAJEtVQB9zm7LAjPnw6fw79b7TkZzVk4mE69SWEPHxW0a2lJ4sVNvIfRyc0R4a9IgcQCWW7fw6TCW5S3W7LgXeiE82iHEWWl8mo5GH)oyqjjvCuRizk2OXWk4bLFhRrAJ8c00kCD5IKrLbjHIYe5X)kqauhvnnIjq84fvk)ALljvCutTK0g5LtOKcw5xRCjPIJAQLK2iNryxxoHsQQtMOFCjPIJ6ivurJycepoxsQ4OosfEImc0ldb2McOIrCHBsVHaRUgGkAetG4X5OHGkhmCEImc0lTrc9GHx4zCYbd)DWGssQ4OwrYuSrJHvW53XAK2iVanTcxxUizuzqsOOmrE8Vcea1rvtJycepErLYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKQ6Kj6hxsQ4Oosfv0iMaXJZLKkoQJuHNiJa9YqGTPaQyex4M0BiWQRbOIgXeiECoAiOYbdNNiJa9YqKWaAJEtVQB9zm7LAjPnw6fw7nsLEHLEtuaE1gj0dgEHNXjhm83bdkjPIJAfjtXgngwbBqsOOmrE8Vcea1rvtJycepErLYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKQ6Kj6hxsQ4Oosfv0iMaXJZLKkoQJuHNiJa9YqGTPaQyex4M0BiWQRbOIgXeiECoAiOYbdNNiJa9Ikwgu(DSgPnYlqtRW1Llsg2yt5xR8c00kCD5IKHNiJa9YqGjByiVn6n9oyjvCSxwlzk2yVfR4pb61gDmL58vVkyVNf27ukxVuPC9g1EplS3bBy79b6aXtBKqpy4fEgNCWWFhmOKKkoQvKmfB0yyfSYVw5ssfh1MXdM8VPkLFTYLKkoQnJhm5jYiqVmeyBkGkLFTYLKkoQPwsAJ8YjusbR8RvUKuXrn1ssBKZiSRlNqjvfl0iMaXJZrdbvoy48ezeOxyJT87ynsBKljvCuBjjt4ViVn6n9oyjvCSxwlzk2yVfR4pb61gDmL58vVkyVNf27ukxVuPC9g1EplSxwPyy79b6aXtBKqpy4fEgNCWWFhmOKKkoQvKmfB0yyfSYVw553rDu1MXdM8VPkLFTYLKkoQnJhm5aXJRs5xR887OoQAZ4btEImc0ldb2McOs5xRCjPIJAQLK2iVCcLuWk)ALljvCutTK0g5mc76YjusvXcnIjq84C0qqLdgoprgb6f2yl)owJ0g5ssfh1wsYe(lYBJEtVdwsfh7L1sMIn2BXk(tGEvWEplS3PuUEPs56nQ9EwyVGoUbEVpqhiE6fw7fE9cl96X17VGa9(apREzLIHT3i7DWg22iHEWWl8mo5GH)oyqjjvCuRizk2OXWkyLFTYLKkoQnJhm5aXJRs5xR887OoQAZ4btoq84QaqLFTYV4tT0rvFwOMrSH8VPkau5xR8l(ulDu1NfQzeBiprgb6LHaBtbuP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPTrVPx1Dl079SWEpjTXRxyPxO3lYos)h2BkUn2R4a9EwyI9cl9Yej27zjEVHJ9IoY8Y4E)fSxfjtXg7vk9wIW7vk9(k(9AjgWErp(2w9sTK0gl9ErVwWRxzo7fDKbILEH1EplS3blPIJ9Y6Grrsag0VENOn6as(QxyPxKv4dnnrG2iHEWWl8mo5GH)oyqjjvCuRizk2OXWkydscfLjYrgZ4bteqRizk2OkLFTYLKkoQPwsAJ8Yjusvpywe6bnGA0rgiwyfjJCvc9Ggqn6idelQNmvk)ALdGYzPePJCG4XBJe6bdVWZ4Kdg(7GbLKuXrnYU5mkWWngwbBqsOOmroYygpyIaAfjtXgvP8RvUKuXrn1ssBKxoHs6qk)ALljvCutTK0g5mc76Yjusvj0dAa1OJmqSOEYuP8RvoakNLsKoYbIhVnsOhm8cpJtoy4Vdgussfh1ktPCTrc9GHx4zCYbd)DWGcneu5GHBmSc2GKqrzI84FfiaQJQMgXeiE8sBKqpy4fEgNCWWFhmOKKkoQvKmfBSnQnsOhm8c3Gei487OoQAZ4btJHvWhKbhAG2gj0dgEHBqc8DWGssQ4OosfJHvWhKbhAG2gj0dgEHBqc8DWGssQ4Ogz3Cgfy4gdRGpido0aTnsOhm8c3Ge47Gb1VGA4Hmg7cdcMjcFcpTzclmgdRGnt0G2McWjJZaZmYIoQ6lsg0V2iHEWWlCdsGVdguOHGkhmCJHvW0iMaXJZV4tT0rvFwOMrSH8ezeOxgcmlc9GHZrdbvoy4CKDK(puFqg8DYibYvrJycepoxsQ4O2mEWKNiJa9YqGzrOhmCoAiOYbdNJSJ0)H6dYGVt2GtEBKqpy4fUbjW3bdkgyMrw0rvFrYG(zmSc(GmO6vhQOrmbIhNFXNAPJQ(SqnJyd5jYiqVmey1LkLFTYlqtRW1Llsg(3SnsOhm8c3Ge47GbLKuXrnYU5mkWWngwbR8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQu(1kVanTcxxUiz4jYiqVOEsoavdcav(1kNbMzKfDu1xKmOF8VzBKqpy4fUbjW3bdkjPIJALPuoJHvWaOYVw5mWmJSOJQ(IKb9J)nvDqgCiYiH2iHEWWlCdsGVdgussfh1ktPCgdRGbqLFTYzGzgzrhv9fjd6hprgb6f1dMm1LkAetG4X5x8Pw6OQpluZi2qEImc0lTrc9GHx4gKaFhmOYVJ6OQnJhmngwbR8RvUKuXrTz8GjhiECv0iMaXJZV4tT0rvFwOMrSH8ezeOxgcmYos)hQpidQIgXeiECUKuXrTz8Gjprgb6f1t2aAJe6bdVWnib(oyqDXNAPJQ(SqnJydngwbFqgu9GjJeurJycepoxsQ4O2mEWKNiJa9YqGr2r6)q9bzW2iHEWWlCdsGVdgux8Pw6OQpluZi2qJHvWhKbvpjmavMjAqBtb4KXZVJ6OQnJhmBJe6bdVWnib(oyqjjvCuBgpyAmSc2mrdABkaNm(fFQLoQ6Zc1mInSnsOhm8c3Ge47GbLKuXrnYU5mkWWngwbR8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQu(1kVanTcxxUiz4jYiqVOEso4QgeaQ8Rv(fFQLoQ6Zc1mInKdepEBKqpy4fUbjW3bdkjPIJALPuoJHvW0iMaXJZV4tT0rvFwOMrSH8ezeOxgc8WOIgXeiECE(DuhvTz8Gjprgb6LHaRUuP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQe6bnGA0rgiwgsDWkYczdScEALW)f(bXKKdJMKMuYBJe6bdVWnib(oyqjjvCuZalf4elgdRGf6bnGA0rgiwgsDXkYczdScEALW)f(bXKKdJMKMuYvbGk)ALFXNAPJQ(SqnJyd5FtvaOYVw5x8Pw6OQpluZi2qEImc0lQxOhmCUKuXrndSuGtSWr2r6)q9bzqJPwc0btMXOKZxAQLaDnScw5xRC6eLKkLd62AQL4oo5aXJRsOh0aQrhzGyzi1rBKqpy4fUbjW3bdkjPIJAgyPaNyXyyfSYVw50jkjvkh0T5jk0RnsOhm8c3Ge47GbLKuXrDKkgdRGv(1kxsQ4OMAjPnYlNqjf8aurJycepoxsQ4O2mEWKNiJa9I6j7TTrc9GHx4gKaFhmOKKkoQvKmfB0yyf8bzq1t2auP8RvUKuXrn1ssBKxoHskyLFTYLKkoQPwsAJCgHDD5ekPQOrmbIhNFXNAPJQ(SqnJyd5jYiqVOIfLFTYlqtRW1LlsgEImc0ldrY3YgBk)ALxGMwHRlxKmCG4XvrJycepo)Ip1shv9zHAgXgYtKrGEr9GjJmYBJe6bdVWnib(oyqjjvCuJSBoJcmCJHvWk)ALljvCutTK0g5LtOKoKYVw5ssfh1uljTroJWUUCcL02iHEWWlCdsGVdgussfh1i7MZOad3yyfSYVw5ssfh1uljTrE5ekPGv(1kxsQ4OMAjPnYze21LtOKQYmrdABkaNmUKuXrTIKPyJeJY)SIKyCeY8NYbdF4PupIJ4iiaa]] )


end