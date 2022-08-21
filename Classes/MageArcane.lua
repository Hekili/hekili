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


    spec:RegisterPack( "Arcane", 20220821, [[Hekili:S3tAZTTrw(BXFyTPMXJSeLKpM1Yv54X7otQC4kktnBvBTIeeSPiIbb4GdPOPsXF7B)E9b6g9jaPCCM4VKyra0hV7ZUV(0R)XRVAzsd56VB6jtNEYlNE6XN(QPV6SxC9vn3VLC9vBts)yYn0)rrYg6)9TvPjf4pFFEzYs4ZRlBRsP)06MMT1)5N9SBYAw3U440YnpRoBtBEstwzrAvYQg4VtF21xTOnlV5VvC9cRZ90xrhZTK0R)UNpLoQzlxsyVkPo96R(w6Iz3C2Yy3x)22BARB2nF6PpL(FOJYUVE3x)U1jf3qQ)Z7(6)0U5)9A6Rt3kzPj57MFv2M3TBo95lZZkUz38Yv7MNs)Zcc9HzfnKQQ2TW6f(R6gsYs278e60LsYNLKcp8jhJdnBE2npbxmZYkwLvK1CpD6kL)46KQnLf0FBsgDzwqULuTB(DKc6FKNDl8X19F3JyJ(FHop03693wMsHrW6HUT)(3VB(pH74fK0KwyVDFz7tQO))Y2g2ATIVQkOR9Is6p2wJ7vomB(7)5T5L10TbBEE7s2aUTkRSsU8XHw8fFO8os1tOluYQvekeaw3PLL5llVJUOwKutaWe9F(U)YpiEP6J7a)1nvzP4uuMsQzRgysQilBtPp)DF4Vt)HSn0)5YwcFbqXjWlNurxrV9dFZU5RkR(iFu)2YBHP82KQSKf5K6NrrUPCkTA23)nTj7MVPCzBoXXKD81xLNv3ud0WLBjfKk6)67qocsbmSlV(RU(QukmHqNMRVQQTGqxd3qoEzwDA2wkfeDXnJsNVHcRpM)n7M)ykiPD1kRV1SvvL1nh3U96RyKsxF1QSkYSf5j1nx3q5eIy6VPkRo)(zzPzP5eT5LofjhVfa1Vz38xDHYKat7SIYBtGj5SEtcJ1MYhNNtAAOONzvTlUV7RnEcDmohgdXlSKK0SErzfizOBCPV1fo3oAl1ZpPBSQswMLu0mREBs1hHX45ohJukzqb9DpM()AwFFLYGqbwZkxnBlq5cdYluxUBYQQkRQHxOPSAd9J7TSFPZPeXSC(vCWpMXe84ooc9hxr2KqfLOamxNTcHKY12R8SbTpKjlVVJoJ)mQymG4OUHkWE38xB9HBs(5z4l0TC4Vqz1cyPC6jrdS13ZMGuXohrWV8CJzusYF6PQ4MMY2014WSMmBtYnz9qnNov9TvHl9FX(u5HqIEOEo98EJL4n3wrQjundWBVjRyjtlvv2w2JrPFFO8BzsGQ)NTeY)cfntLs(ZnvjDIy)kaAaI)Qyshxt)TFSS5BF2B)avFbDKlVdKjsL1rbO01xHUi901LhVB(FBL(prvAasdtYPOdYYNckEOOSeuVsRCPDhvFnOCX)CEhrrbj)LF73k1Esh86s4TEsovtADcOIiR5yvO(JelfbONaRAvXxljiMXGeGkV0)ZLKAV(sQMwkagrphRsPDm5NjPTnKzm9m)bo)rFeyhlYU5hHO((IWIe1d4ce8UoPgb4liKceSV0cAwaVFQeeI4hWMHiPCKyWFO8dkiWJ9t3ZbS4d0O6FqbPULOVSKk3qvbGMuKl2n)x(fjzG27n722CQg8Kfz5uByesbPFZjEe88chOwXlMuvHM(QHyFB(Dj3txpFf7PuiJGDGuWTweb)Rb0TKtLXVWrz)vHrH5KBOFe1(G4Xs2uUGI7VjLXe1zNGUzLconCN3xb3HANlOa7KFSNWbDIsNacPs4quYdckzOyEnDGU(QtP)ysf1cm8VNLTIVwPwJbdwnQDNlxexzpEInC6V8ltEexGiv1Af(ZKL83T)((x(fPQwc6raWmIgcC0rhPXbfqgAarWtegVkTOJdBbgVe02)zutL3KrOauk88ukpDKYMFtFHiBYO(cq1UOjhXGwu8wO1XUnpXadiKbCjFhP9mfrsOvmUSJ02AOVhcUExfYfFltkseScoKbKAyhtUca9yxWbkYDQB)k8yd5LDUyrrSnBMbGn27u7YcYPbm7Y(sxZBGtVWTm7PUSetYvC9vsZuqwtXq)MlF5fApBZgcvbsdXggsFvQlDX0WryDDHfZsLIrvnmTbC5J6eavgHBVoTSR0ef)p0LQsOMWbbwaLUE1vuzX0)4h)hDcwPSRCZ)UlPGBuX7VTeSkHkfKy34VJ5UVdwHaHPOUe8Xh(xOe(1W)cc5r9A0))wmYgpbS8RElgHd8NK0lDG4jQYFBiB2wwLKp7UKQTDYIaQcT3RoB76Yckxl19cnrwpsHkLA7XwQVQZiWEtkE6ipmpDs3OF7TZO6ho(0J1XFIbqYFAv)InV3dHgbJe5GSEaYUWRWWf18a6ybY(uzSBYater0AjgNjiAt3dg3dKi51evCaxpG(wrfS6F3gPaRHPPw(mNOcBrV4tCeA6la6bjcnUC6ikDmHSTXaZiEU9yhiEQUoZjDmu2XVEJDXrAwYB3yLJcf8NILTuxmVjBvJ4BZZsxFTTOsjIaua8MnzmEclG7We5K5HU7DP5mIWazz0oWXbQZ5i3MAXC37nxIoK9hr6Gtr3)QjnZwuw0wFCtgPA6lND(2uap6lWBYaazHAFdvHd1DUzuXB1BSSc2n)5cArQsaY)SnB7wYYJbkbkplLDQo7MSCgPMeg27PDIRoseiu9P1iMt6Kbbc6KtgxB6bQ4(urrpqqZP4NAMBvV7DCX)Gg81juZu5HWzjel8FC387jnpLhZGe(NYuYdssrngBAlszAcmIIeQ7pcFXCy26H0YBDjhwdQOGMxvTpycb69uNkB)sGSgupTqvf0afjDxitu4wY4ZgfVSWx6NfMzHtpcQVJUcsYZVNrXSnjJcz3wcpJtLab9dcuXtHbVHzJ3DzqGNyHtkVenAOOS9M1yQxOVxj8jDE4JeKDwlw7IYYH9OD8gSfM1GTfHz5EnDZLYapHGAFNiJ8xyeMjVZLAiDMGc4OsyNIIxdrOfwqBGW(WLO5ZtdhYkecFaYbHlfS4AccHw2UzlkyAvlstI0TWkwc86ajb4PD4djJzSZ4kgWBAN(PtqiOuCZhVNolfcNdKoppgPyhzpurdAdno(ER2xRA4QPTZgbqr8QMj)BF5imESgJHuSOYl0XIkeWhbfVJCxAlqn)gzhjqjMzcZFGCuMxljrZkRUT41iLk)LuB9V5P2YzS0(sQTgni1TbmFstT10(234kYK666jQXhCtYhP)DDlOlx43rNjHGUwUHH8ua1KbVzh(5PyaOO4UmwIHQiqjer1Fc0am4kdcWQeRce)cS6nW7rDb7EGYQPbdSjeQY2Qc2)6FrQk52FIr7cMGOS58yREvBlafp20AIZpjoRj2BL6X7wrG4E2xLJBpzEuCzeB6OYyQmFH1RPQPxYRkTfeHid7jqfqQVxe3uM4EoUbI78YQYTBr8npkOc3xyuTO0f8FboY0JcADfJewH6dW1XloPhbJL0lAnzDDHjEuPF1amMWZhlajr4htCzQHqZovEaOtiugGwu5znDX)xckXOmhWGPdxUyJL47lPJ9ZS0XEMlVj6)UoJ2fpSpuvfY0XbI9rleGGEXQEG0eiUEmEyu2XDuSkHvpPqoOQk3GXbtx6ULilnsN8W9AFVj02sx1Ku1iR0wyLdgqYw9VvKRSoZKIn0AHtWY4YiScRJp07NSKgF2dBsJp7Z0KgF2qsACvzdBP6jDXE1FGESre2lXzaZbTcG(vM9COnvcQoiNJyiPxG1woQbfuAVvDNBeZ)Pqm)dgAxpQf0n9w9J85D0U5NPXqyL48nEOnvfhRV6ufi3950v3SwQrV5Zs26yKxsYtUFgvVg(kmheCsOZS6Zo4eO2FKnq6rHbqcZz3patajrwXBA8NYHpzl46u2MwysksMTvnnc2yHoYxaTCl44ZB4zqcTrXPSxuNEGYUZuYN3qz2QZpSwl5Goa2bGFuFreBQhkmGN4keDidUmQ4ly4lQll8TBGHPf(Xv9nr5SGxqK7u6iH8qNondmaRxiBJaSOhNUiG2VoQxwlasonGjqgKmclvOGkg65Aq(qHhZ9Y2O(i(IdBoDyBsmOJ48zRNmndQd5WXET(bXYRpb99bpop(ExzrD7grygi)8wQDMaaBBzde3qOZmHToeFcqsO0pV8sWMvL3c94lwVNWNjMSzYrbsrwJLcCX5wXwnw5BETkZuZLm7(ZC4W)SCs(GvOYMplA3OpTVbWw7WGMkEBOUiP4Jm)PXinBPQiXQxGLGzk8AJmAZ3)KEUUqjeYQiJFl2pRbt8ah(dXINWikd5Sdl5NyDm3tRTnbIP3kkh)A4HsBWAYs)igAIdr8PDzqGpnkOlVY9ubbYhWmiE0eE5M52et3l2rfRbp1yICSOen1zlrwufNH1CPbMB163SUDlPsu(MHlVKCcd8urOefwcLQHHUN5wn746JP)cYZiTwMftakFwcex4femWaSOctfEtQGC)WIraSORxxIrGgcxarpi98e8a)Pa2DTEQsdLzdvZODIj2psyDT4ukd7(EP8CRrUUh5Wj6FT1y)BudoDGMF3cxyHVXs6m7mU3OaBglnoDnRKmPHX9)Bty7JhsgfXDH2J1weN(srCScy9KJoieFOsheksL1nqJWWkyrRzZs2BHDPx2LkIXKUU9dXoXp8haRHYVLaQoQa7U)qvLCegrS39BcGLp6ZByURM2zCWC)aA1cIHjpcYunioIFsTallwT5I4eWO33(b)K6(G8HnmBqHcyVXDiapqnY7O2uWCPHaXgym5GTSczyq3PDY3GfCc7D2WZWn4DBjG0ahWLLSQS4(0BXT7lB7xYls9iG7eRXUIdS0r6oFMuiLG4OCdD0xUblaFzTYYwuIUvWQgOHwQOV5szHmPgFH)Ks8f6)S3Ov459cxbIMCBr(OxNb6gLrSq7t8qehUr4wWA(1qZM1YUMz5sfPvbxBjtInIYKXfzT6mdfzHCW8KypLUdtNT4dkD(hp7ZSMpJsLHDFMqCsYw125K9BGltuwcGv5USAYX2ng1DZSfiPqGxl9mpz0H63RREIpFsOy9)4WH63Av84C)fmM(YqmhmpehY5lIS1jcnFGSsUpKbki2UDpPip7M1nu27LgTiJVxrZYxqE3lozNwV9ojazwhq80t2pLyQO1yMs6WfXmQUD8Pjxhk4lTQwfF4nNPDy7GnqRCJdR1zwF9E9NONUTvU58KUPXAGd7nIiLJ9XwFrE0bB(gK8iDQ2fL5r321FYiAZQiwBw9UvC3MqR5XD1x32or601ZJTWh2RNIw3t4)auT00vgQ7hSMhSHL3XeDD1xx12Y(CWrKNkCpbETAuMlZvrO)TgEm7IH5cdzbAy6eSGDC30WXqaIrK4KOgo)jioIDhsnO9uUNtFEVT9rH5nXYHJg2eGuRnFbKsXBlHdFZCYS6Y8Bz6WvuTlFTTT1nqOVj8tzvvxX74yYj1RXZlwB5qw8wQh5KwZHe6CNAdyPyhmWBWm(TxzLFhjh63h1wFaC2RJnrEEPq)6(TaueurXsSC6frti8CBPLDqK2kcWukislaABznTBM(IzGbCW5xnZ)6HcD5KPENlBP4r5fntMK7bJ0cONhRtumLpl5)6DL8wdJPuctFRSxmWqXGHkbZ7jAZaJTd1I1VNJsWWNG8Gn3bD(dp(ksZT4r8bBKeCHDhVZ0yhTXGIp7T(JFkej0Lk3u32g2SeMd17GKSvq0g0sSjryOy)6bCOf2MX6tuwBICi7DrgkXYVb7I9WgQhG83U3bwRSGHswl0piQB)TL11zaG5brFrmKGgOuVq4WUKesDcsNPpJ)rzLmyUoTvZjU9Tm8KBSxN85NsdnbU2fj8WRq5x54kOzTM5XDHRMTW3rmWK9ibLTBdl9z)5nU8HQa39Deg4PwvcbRgGXMtK84DzsZqkWPNPH21I3TNYDzyThINy)e7MXD3J4ud9PQN(8Q4hRfxZy3BQNBeAtICUn2zbQxKHn)dKap0YYThhJ8COWTJftgFpg87A5kErGEoDu2d49(aPcAeCiJzTclhDdzec(9G0jx7d8lMG6ouFcEGA2LqW2hKU6YJYLin4sZBPs7gagz4UJiW5HmSZVPKHf90fcKi37E1tgt5c4pf6MxmkgNMkIxnMZMOTqtH76eMjzHYjKqb9h7ackhFjIdiirRr0G(fYozseNZnIyrGl6DD3FrRHc8HvWSRBlUbk7dUPYDXrrRtgck(ZK(nMJ4gz5LhOohoafiuKf9(J15szaxp42glN7iPXwJAbbl6ma96nOO5og(EctWZQK28gzDFiE70YwOHZR3sYZ7xOk(emgTlWGaOxEsFtnO)4ZVWEkcJCiVqpJdGrk3q24pLZ2OQvaCYJgYyY)N7Z3gCwi)86K2Ae72DMb6nQ1OHHL1me8kaemttkoCKaPEITbQbH52wQ(8TLJk0xr2BfiMQE2p1U8grwEc0ncpylLfj3GpTkl9J1(t3KFYGfuUbsfeCyBPek6rjVSC5SvTv37pLj(hfiHU4ifiDi(hf46eSUbOvttOC52clFSdvBnzg9n3uBnkO8GlKMWY93QQe6GwqNx4s5BLIBEUFfBX1t8v3Kdk1AGmlUiz5nM9xLHcRimqcpAPVWpLgaby30GZyBrJvIVyr58KL2ODidBhLiDSrQQq51zYyFap3QDwUbU2(MkXIfc88bbayVT8y8(mv4HP97aCaw6QLf6Rv9mUKABbwuWZqDN6E))acFDDk7r1dDpvfs(SYQLfaR(qce(LMP)ne50fILO5eBlewsM3QSnZiP5zBRh6k8fdAb(cX6tBgTfDlXsBjObgRDMBPMGtYhWYdKEm9eP7GQXpPSygwwaxI1uSiZbivOmy6Y3x)wAr5O6ou4KKemgBc)boBF3xs60QkkCoPE2QKBlThCToX33VfXBjut13KLZZ9)HBn9jdwBFNylqxD2NMMSGIBQxtOco20wNLoGDoqwFHIuMaBfy)RjURtQILLHT4lDOx2HH9J01QlrqcVaLUiUtUCf1b8wb0pWXL5i1RtOBEYsO95qXrIIPtXpBfsqovzu160KaQgDC2UcGJPXQeDyI97CwlIHEk7n77etWV9ifsvxqxBH)rlGmxC8ZzPohJ3c1XwaPlBkQR6Y81U5)q7I7XZ5HFcUPPZjUVDI1891vOi)JQP3shfzCe)A78Cv77vA(e3FCbjTQmNQ)v898pou(ZF9oEJnb1CAdO7E38NrrYaOtAoJCBcfgdJJDPsoJnjp7484OxXTuUgZhN)R)0d1SHAlUB7qw3LjMfKwW7M67lsO66P2TTggZQEOnNX0kgEG3WDa3mP5(vw53Tcf6Dx7bBrstfinl7Mcytoa5YWA7SWksv5gKZI)aKznzGHei)4DHoOB6BpUErd0ZGC6cgVc4HaD1fMlQJV8lu)zWfXo76yN7n3T0Ha3yUD2FqRaCn)O9Inz4BcXEWNjFrSww37SWDWRd(aGbIZDalSlBjSTAddWU2SjCh8(P39NyJLtN1O3wFIx6klz3XY9t8AQlxmnEpkwvOaGOdXonT)1cqkpouBSC(UgEnF6VgR5U1W1yca2wrsHwe2mfasPqneQk3uJ(vv9DRB3qxzZ4FYQeQZpzj9VyYot9lsll(P2kYmze61F3ZvFxwFdmlBJrVR6jc3hQ(cOBzO3ua(UvahdUen4GDDckupxvUm7g9xPt5c2IbGDbP98tOVojFrPQBZzKmv3AZvTnW(fjw3U1x7qPazv7Yk3ABdpXpk25wymRZy95uvJNJir36yp0RCRgu5oca9zLmUuUIqJSXYwjuJkfIxdZKdl9rE3yoOnk3KvWw59OB5(3Hw8ezE)sBE(G3MNEtW9Vc0Ub70tvG9awFQrHsfwO1TOX0O2dVT87qRXC6m8fwMpxzzK9ZFmLgXOjtur8t0JYsKvk3Vn6uIiiDd3gforr7195DGi44mIf92VRnULVhyAgv8KghjgUORfbgAP3p8Xm2OPgPpcQWZaH7sgJ2(z636DumFdkqa2oIyFT3J0txzS1xuWJiME270x39FYEDwv6VTITw4V7vBmpX(uYeu4RPeS5xH0vmpMNhhlySCx9jSCZZOEv3e5nQE0XHgRJVbTUF5VPnlWrbpgX0hXqgbS2IYDhOu3wg3VmAIGxjuhkz78iXMhN(A4ZrSS2xsOyOzL2ceh2X1(EWxPu4EtBNJBTln)DPzoXCZtncO8xS4lwsQyS4RXtD25tDDNCSEfoWqQ7CorQzHS7LMgBhaFTDQpBNIyr5SvUJx66br4EK(GDWK8h58fhsAN)US2xcF9p8oXorYA97woDpyd3gk)fHTpiOGEhPnUoD4du1q716TNBfAef76kzNVi2BOI9WPLLAwzgcjRw1wdPwlPiBtYSK0usoPck3FTfBN1pS4jKL2Zv(J8P3ZtpOVhXGjQqfG1Z3jbCp2tpBVhRpKji0AB64Sz2(2WBq()cp5awB778fh(8HNN0p9I32bpsDu)ovL5NeSMkXdIWcCzo5yHoiK50qGVpVrytcY7bnCpVOT9xTQFIqYAinel7U(F6V10UmByHiJxORoVuCuSHZ8CbWZ5n0HgcOPjWDj(B)OZXeM550e6byL7vDkwo09udeiud9pX3C7rKN629HyJ6sNFinlUt4Wd8Q0C54uAQNs2nMjnIlH2ojMM37GAxOgEkZ2ywkt8zCgxwS8fM2)fECybHM6K0x(XCphCGGKMj3JF)d6PaBXH3XfszG8t6TpPDLT5gVLoloGkT8sOdcKqpxtsc(og3mTkANnUcnnV4HvmAqyXmPUeB7vnydmo9kkZZLQ)T8Wluus)ilErTO7A9PBEGXI3anRjj5nRLhGxNPFSyy78n5SahweMyHFZTTvXI4wg1Hl1XlV9mvGcWBf3jgHPITjMBr1BdP42Cp26EdYC)fMBSU7QWZI7aQyqMR6D(I7OSWy(ozawI2zXg((JPiRTkFMlu8CVN(FpK3OTDRiZlL2ZdCKC4quDyqrFg4KnBZZwLjo7n9Ze)YqmXEf4FUBDGXO(zil0Z9VqI7mbQNlwXImTP()8XChdh0nsD766XD6B9001ywEU5VuYNSwl1chj14D0luHlSZzm8uqxWlxZpu27UzqE6U53ahE6uzzl3jV6EvHc6hNtN1RVV81C0XhXkxrtJvamwVnQ0VhajWP7EbEsVdx2WioGdh3nFvBE(9hVB(pc9vm21KqxgF6Z5VjDI6UwaHVNAnpR7axvwX7gzqWcCCZVQHbBXFKI2lki5YtAE6pXPLzNJCRWtDPJ7j3sc6WjFMCvIknvlOmtzyRnlwVNla2wy10c7aZWu9UFeMYaysQCJ0yU9XdC9n2vlJwU)g5xrDVNFmLSB(3ZpNsK3fnu64vK7KhuFIrdou2rO9DjzSgfVdJbWTD4Lea(NuqwvJs7LJT8UkMrEGWyCAPWe11DmeOt6A866QiFoRsOEu3PPSX7VmRMb2AmRAxPPqEszLkfcJbIBoOrRBZQOmFj7ym1SGKcY(f)44cJWJdAaYRzg0z0Z9tfCo26CD)7(iUWh)mBpor)WmQ)MseihRDXwvsb3U4lmd6z)rsNQMxwI2HWwdIQ7XZkCXbPBF7fnIWuexDrWT)b078lvcHqeObB(y(7zqV1qN52hNXfLl3(WeldzKrNv3OMEhxikhret4nOO)2cL7nsN(x7Tg6qcYQBPa(IgFmTrODay4dMEZ6DjI2T3gZNkKAnfAa0PqsscqR58QDPV12MNcWtXBOi8121DvpdMS92p8h)HV)dIJZx4on6RGt1XC8gdIDXg1iV2HOW)39UA8CPjnLS8W56alIIA2e78kw3Yd6zMiq(YTt08Z1iY4MOOdanJUgokleWfiyInEomi7r(4aBGxS5mmGpOVki3aE7idIglxbNSt(9UtDLqYr45JtQmoeAGlU30PA1xsx5(bsydRMuJZzxZuW(aaQoKBnpsaDhe1asaNm00KXFrwAnX61vDVEqoc(LrJ1RblqafiPnW4(Mlnohnp4GCd9aUofKSO43I3G0DFb6lhFTjUs(zLJbyyvwtnjFftCb1lk8YJdCBN6UDH6nzoCLcybD3JegIp2j(1)3dgEaS5JXnosRvpCrcJhOvpvQ6WsVfU86hjcJJGjZqr4CH5Qeo9QJNrhTSePIqV9FB57LhW(1u0hHfCH7lBfxfUijMmwmI4cjd1tnbWQDJbBlduD09agFcXBifHi)2vLTvnRhnqD6ObQnEoJpfaqmZlEckZFLN4ZDZFF66skm7TCZM(QC0gO61uEayBtexLWubqnyWeHyTiE73lcXPAiAWdw3(W07Ic5nAOz)Jdf3j2DSqC3wbpIf6yweEd3TNYS0Bs2p8le3r6FqWPiE5OYxwmxvjgcJ5UAhXAqpp4rS1EDuVSALR5G5UXZ5XyyxLGlxkkZUqO2csZDeulnBrXzmRzwR3wGkJ)QVHPbUSTHFnUImZ)G4tUIb8YwssYZndLzKo(eW((qMJkIQrm(oHWqxw1OOXYc8J(ZD3bUIRogWOcizd9VG2JZdYxlu06XELtntJR)kNSlvUHSqKLngx9Io)R8F2fy6(txofT5HloJUouW9sddjedUYGrT04WbkOGA3cWjIRRhMdM3rEcyja72fMuu2EZA4VOAZu00xIzva0wvvcFQuDVySqvwvLBFgENXIxAqdGc3vIWmCo391OtuHiyKXKWotI4P4SntaE1M2(rlWOg7IWUKplWLpf4uLJplqfOTJIjbx5G8WISMmq(MYec)dWAWDIlPAdkdJIFQlAfJ2QF1I0yi4PDDfM8JcScUuRoOn2eAw1GYpmkFrb(pWL4fMc3fe(93nZgt8o9sK7w8xZ4WAQFAPFeWalAZaJuLvCT8E6IUjtw1WU(Xj3ZrtlB3SfK0bo0HKas)cKczIuo9G4Q0yw7BVL3ZmWglfHPoRtHWm6SMwSWbQFkejn6V(Tmy32QSs6Ek7FbB8YBbisju5lGv6uFCReYFmjzDihpObJ6MkgxsMhviFTV5Lm7jn9ykHsl6MKQLmD1afwp)cJd9hJq1HbKASuNOonX2ITiwCgdUUY5(IXWYzMaREU0H8si3JH7YSWU8TD6(JamfdxYWbtEp45)mVArCAkL8CFGzoLldRSRKglwe1ZoIBYlxKKddqt4AnD0u4UdYQpNXoZDM4vkhj9d9gTtIdJsenc7l((oL5lyb3aqV9vDKXTcjjNhKxMng1LG5xRQaDrORaXaa3Ry51yPMs12p)xyGT4HcDJFVpqAsQrnaHTwbKTxKJpYBUdu8atdPYViuCrP23YrT98hQkxXRmiCFNZUWnPIVQGajVotAh4tb8efexcV2MekISOSPVfJSsOdLs0UDBjubrkxHNWkSa6cK(UdtHTqbWUGOBTisAbhMJscmeSRCQrYc(LdeG(XajR4yLptECzQaAWQj82Gh(RYsB6fx7opkHoOH0)CoTIO5ggZ3QxKMo4MDELL59ulsyr9JEiVgWIOp4cNYFUpFHUb(1d4HM5KJyepxlwsAIvDlwwEIdnSR8Tx1jeS31SUcs26rF1y6bGyuyzUwudtcVmqEKm4CwArElnxJgXCWKTyDmX5TR(q9Cmb6UOzCp(D7rqO8RIeh6EnmORatzK8cpJJRm64f(NtHBEQCfoD9LmoTWtL72(mUIyXchfp3JHRih7ZGBPVJRMSISgco4CEN3JZZKgbql(z98unaXs717Cq0ta7E1biQBwcdWZXMwAcglL)Woh369EsgG554L0YnQJ853pd)7UtNov)7NXDIbb1pwFX96NRcoTSWFvulCCBV)Tt4BIkGPUTUTXB65De4d)d3iBaSOoJvEJUVq62F552LukKXsQqgo1Am8qpUluI251FnC)IPuMuAV1GuvGsTp1kZGsE)Itt1W8nZRqipziE)a)JUJJuUcA800r9PPhsQDKUqyvQKMpl63kn93i6E3a(3qQWncfroD6jV8KxD9v3LubvqeDf(pE7p8D)TV7)(pVBopEozByEXHXQ5jS7IJNab8J6hqfe6tMF8jTnLBsWkOcK4rD8)4DF93Kbbp7u6G9UYc60Ip(jDLsW)ZtyUkQ(tI0MrF0Kt)5JKJY0dYOC659ggErMjhdXF7CaEXyxhqutF)3)n9hVxEGhVxn6n4UVoaYx)cz5tfrWupebXV5yF)zJEvOok9PHg3OCXbzuo0KJ9XtnvzfFK0CCYI0JfAqedCNg2fPbz0IEHPHWhp7MUWJtomdZ4PI1gM(KHdLmE6Zh96y6bzySt8m9allB6dOSmX9E3t2lPyXVGSl)zOF)(Q9QpcAOFVb74EpartI4xR5GxhJMu9qPT1XamU1XNlY3cY2bXwFySCgK8dwHuWf1sYQK28MHTUgJPitp4gryAp7Gbp8bQV5iJEGoGCw)9cEsKGbQTMmJ6Z0gryk2n))D38nvv3q9IQE2QKBlR()(pHer1uD)U5Iwe)GZICy8dzAp82vzBEhLO7(Ig4eO))GnqFtBcSrUnJv5buZUXZln6q9SJcmEJDzTVY3ngGrUoomerggqe9Wy3GKZom0qNTVIz5dZHHu8SdJtrNTVuGbftlVMFFYGeu3xWM8ejuUS6(fxBUrog2PIgTv3Ehfrrilhd5p4AegnRQ9T1HHLD0CSXsfnydqcBZ))p7D01CBBJ83INmvH0Fvj5Ou3Be1m5A7dxVRt7K07U3ozAsilMqjYJuY(Chn(3(TlaiiajajejDsNK8uIfj3DXIf7xa7IMn0pml27(ADzAPlXF003BpvmzWD9zyYFs1Lr2WrgKfr)jCTdxEDymYvptswWzvw30DrEf6yyKz7r(SuatxK3u4kDjIZgbqhhivbJLMevvQnmIA9oSvoy6BiDdvSbvbtNyTdJyFnW0jAzyw7udmDIwQfNB7tYgYo5W4hxnW0Pr1WygQgy6eTmmgZQbMorldJYUAGPl0YxgbpAXYjva03uA374o5GPd6fAgaDKogMvYxnmc(VQloX1ia6iD0ftZma0AaH8Q(4Lp7bfkpGQ5g4rKTvzxoQLVUocNQIlhF2eQ5NDhar1LYDae9DzCnaC80Wq5vBFYWtRs9Iot0ZVC)ZFYqowQyGS91tQyy8qFym)nmgVggpI7QtOY82HXh0HXiATeQCSck9pvk9vuDOY(XWiMnuky7cBvbaDrpKca6U1QN(5)2MIDgfpjYf7jACu(ouDnwRc0c77)8Ux8INU5xOfUnVCM)z8xEZ(7O99HPtoh5OtNIWeFWpWu5)xy)1fpDdTsO39yAua2PXz7uj8oHX0AHel13GIc1vubIuArPiOFza2BCJxYi0xEPa8m89eV7IkUBnzCa(pkk1yhSrfSLCpw41pqWctlMwnHyvzR(UULy4hb8HHWtRllcVIT)1F6PBEpLdCljWNwOHpMSNwoN0UWdsZzCkdR5qAToYBXx1kl8sC9Mqgq5Dha(WyVCXK)B4br)LabtwTIqp0)LhoBSk7P9emK)9d)4BlEP8lvNoYbh9c2X6QNKCgvHicSIVh7aX)WV9pFIx7tH7jCIaMJWx2h3F838B)dQRaFqcY)sY9iQlQ(08VfMWd2hxut7imOBj9MKW9XediKkBYMKZVuSLDN59TI53DK4yyi14BTYFtuCKFM(xcC8597ZWdV(w)L3r2Wgb6EZIXY5ynh6vTW3ppj1d7Eg7oNFeq8UYwqrUpzzAGgimzMTGaEs6(44LaOqWGajALNtPMl5ZX)iNQxnThoi(fyEnljojle)nD9Iix3ZV3pEpXBc7FxsIZjEJTLsXs8LDQFdLOu1cwzHNX(lqVWD5jTVa1mOzna46dyN6FAnSuFs77TfyABUN1HN1exw(Y6xHQ1HN1Yu1Gxws6qcoFnqBQ1J2njy5(ckHiHSl1ZBFSo4U(yGMnmVjhf91(41(v4AVGClbiSgs)YvUi(vJLxXy)WOf0E8ZB1aiWO6d8aHsduy567PJVWz2PguNzlI0ERnRINzNnD8PLkx3ITueW8d5Wbh9iVAr8zuTNR7ztMjbA2T81Os97QoSmYA9P9z4Z1hOYNVUV8zEXgXmiZnlkKWRYz5i(1aI59zIL0F50jJhpOyKXW5O77N9mHoX0u13XJV8176EnsXfFGhXB2Vrb7DvNu1ltznRJTfu6UBM7b4ulVivP0jN6y(6gcwQYducxBjQT4rf)Arj8fSo5WHtQiE4oY5eDosPUA0BYHd6DmZD0jv9mZ9yMBb4arhOoAfd1n(b(3co6MVMal(3aHFeC4G4P3fJ9qLDyJj4w)W7i6F0gsOFCmqispo0p7dy)3auma(eLUFhmLfqOSsX7arVfKTFhsSl)V7HHhiagsUps5LQ2pVLF0(T0EJ3syGcCL8Dsp7b)pGZX5lxLbkEKEWQy4TXzqGBTdIXqR7)SUXWYOnyqTAFJvq0lRdY8xrxHksx09jyWmW4jpjgNRoCq8OuiQniOMLKIOx1cxf5ln6AmRC3GTKsD86CS0Atng4cfT4gKspr8XsXD4nrIIdJYdIsHO6HaebWUzdg3BtbPrlf1MG9jndC5vEIGAeGsvDGBtIcYnMJ(qpvPMrNyGA0tmIg)IIzbfsqk44ZW4y3JjmjpfIiw(3XJ6ErST0yc5kYiBPD8mmoSrfnaQ5G5fXFSW71ZCb1HN08hmZvgBPjf0C9gnY(u53K2oQEWplfF5sEjEvFMKbkKXhnIceY)BTpSIkI2SmXyx1xl((HGgJBtYZhrVD5wYle95EVAScjshf5lF)(W7kMJ13uuyyxzzk73BSfyiJQB9VJ(8SOGpK)SIiyINKHx(Q2W6zQsxTp7rBEBSXxr)cBEz0eA(oC(lamuyZxuukgg4p6FzMfV8aF2Y1vz(GOpgBpMlRveTFcl5xlPFzvRDMWnMdKg68dl8MnZ8KutKUsdRsNY)gX7CiaUrT3dgOVMZjM6YwhouSdVvBWwL9xfgGCpIbsvFIABK8ARgiVEeQVyXvJ1QN3wtBUp3CJAUtYMABEQCMvCa0RCtO9USOnGlPXrP52GXVZke(DMXxiQTL2q8UNKNtIBfNlGqdb3LlNyk8vf9f2bNA9gpYG9rf)ku8wUbPsLs5Q7KxdS84htPmo)88OnrXcB1Ddrpx8H6(83kno3BgSmXiraRtyReFgqR5rUglK7t19RcO5mz8fZo1uCw4yy(vJBW2YAFGujHyx8PIhHSPjy(sqU6U8Eh5ulBnLks0DPim3BAB6kTttb61wlaA6HdQoj147tJb9PBMD5R59Dx6DYtkHekDL((UYO3E6M3sVoMGatEpUPuXnSoQAqFuxufmwLEw6zomGuH9j3rPoTAa5IVjK4VB9TjzBjg(ar46UNX)K6Sy5VCELBQZVbypG9fbPlTph00)1sSDfBvPliBQc4ftBqZ)wYE0zliupFq3pybCn(junEo6COXcbOfG)YukUf9yn54td6gWj8Lr3TfBzrTQuyH3vM0xQKwealBjpScSXhcI00iYphrl9cQEjVxi5nXSBEnmwGhMSRImh2IPrb9k0a6ZlFtPxIBEoBeRSZN)CBVnwv7NZ2swgbxlqsdBQx9euzFwGBNSQsvwd6rNCec)Tth8CGONd1sItAh6vsBOms0TW2SXABg1fhUG2jl7jNbfTLBkPmMhuuu06u0p2k3V2HEOjTtWTH5jhhMf4gxj4PK2SwZyextiQkAPUxHLLdMBp6E(sk6y5oqJ6)UNRbxlSBatroM6GEZROFOsI(bFL0M09shM07J3DbHn7Y0Ispj0T7DYP3YaM7guBX9lGUDDveu45zPmnOoFeewaeYM7tlBDHcbwK30cnWCeU(abbXYTj37Rk0drKLh)4YOGOGyslC4RSj)gFvIRNsC9FIcNcCCAFQAHSlC13U(rMMg908arB3uXn1MKs6Oqc4lUbTL1yLCGx0DoBXVTkU9OqFRLV4qMBzYHK8gO6bu6m5GwAlatBHJDHiDoTfLIUQRLzj01vJtPXvwAixYz90CBuNXoRF)Ep)QQes7HIAWxBjfMInQPkWRXB6j8KNXAauo6G1HdPn0TXRjnRFNWml)AJiQ8CNEHpPmC2iD0cyU2kY56)eA6ywxToyrgF0AaqztglsWUb5QAlstB8s(OhyQRZlTpT71QmimE6dP)vBLASvEE5Djur(xu6Q4seVYVlODzaSzdb35osDRkTRmVCfAL8VI(j3oZHkDGuLfcr4RvLavWQc9ygLkgVF2u80Q3LDsRuRqTD2ynnwM5HAHrf2NfRa(CBXxvgyzEWBL79LQ(QJxXsxDLqXTmfrB3VexSp6ehXzOJScVFCVNS0FB0g)L(bbKywlRuY2llkLOaAic1M306a(revMfHAm3B24HgTuzPMq50U4fJwQ6RYTTd12z1dTCRmIOZswOi8ZmDWdmhvbbInbudATIvp18a(tn7SLDTDY0g3PZHwqoFD0kQDsbFVk5LKDRG4MD4WjQj(bEARZK9GEhzmEa(ABLl6U2CeTpeIr9WlWtQr7YmQKQDgc7d9As7FBAYgiCwB8yaVI7zj1SxPcx(6bLXXY73hVfONBJIblY8L2MsJPvyXXeld0jiE0u1h14bSWKvdynZGmARLRuo8LZWnfu1VTP0L(wBoKSCeLIL8Z2a6Y8nGWIatshHN9PnbrZptSEH(8QyQuv9P88BZhc0mvFPHyXj5j0J6z1cS4vU1oyQZWdGAnp)UfpZ)zHOtEhoWp8pRj(X7wtpg(xnZ0CTib6AypFsPV89PKmCFLmr4SQBtq6A185OsCxmXTUtZsK2OAu28RQLqz7XFJwYBETNrqoUv7ZOnq7pSb147BjGKo4XhztkPyBKjRajG1OtdO9v25wYTBoW0dvcMgdLYP(BsJJwfXs1Avz1R1jR2dYXgC(kB03B0vToWhTcWnobjBKuvuxTic9RMyB5e0ww)pxpZuMxzG73xtW(hIAN9aKNjyB9G2(pGppHF(q9ddX(qc(3oRtsjR2hh)Ol(kbWCcchWPGOGiqH8JxQsUYiq4cCXXbRw3KOObrez8qsPBhYaxFlLrLtdTCTAQuCsUMjYZSOPx0ozkptlfJsJQqg9Cokm1(mQDUkTxG9eEKyXeMD6mcjhnFvPeUCCqPYVrNv5GK8DUTAVMpm)PiubjmCF6gQ8h28BaYafvxx0wGWwAh2vF4FUOZ98a8TpDZFT0IZrW5qooUWiuy6rHbkZIwlV))l8qtcohTDVJzwf5vl9tPvoSONJivt61fdr3leYSsFoEO4PBqMNUNE2KzfDogwavifk6JrSAy9PBUdubNtNGkGb8hBONrvw7Hkm7C8YyDhQP5LXX8(HeoHgJ9wzWUherbosHPuGJFjVJfMhTjGEI0VpkeNU5IwOsxsaTZxb)VmS9hHFzycse0200djqCnaUquTcLnslivrZqIQFdwwKJTOPT(72tB8tfhmEGIBqFwDrf2aaeva2wXADvXfdEreUpJcZtDMCHZ4lhFLHoXa49)2p466EbTGtUq3C1Xi)OCg9vADcn0osAujw5Ks)PIt6ozWW()MjLrZNg2QRabUu20(0X5KaUqXVNS7x6d1cAeRssgJEH6xx7Vw5eRc2CNx0BvEhy6LuuRgyDDKdqIUuIYgafKW4KvtC8r5FN1emel9Yr)jLwdS7b4)brsrvBg8yaU4LIx8lG12iGaWVguUJxUwj7X)fLgzlxkwzni8XIQ5R6(1uRC(mlRoQH1pZNnYyJlyKTEWRtcJkjPvgdK9SNZSggKi9uVz40OKdUt46LBeInVLL7aq(HMYhzDLcFerlRPOoA64afnuYXqXvip2KyHVAh6dj2U6Womxe6fiydIn(XZDkekjceFMkFu3k(FPq9pizjOv5kqN7LT1mlSn7HQ9c5PZtvBR5u3ykZnsp5QQ7pc3tLQ1tcWPZX1JZ5hEGtFfJ()1SO7q3UkAwIbRjm)vSitoulhCJLm(hoxr7FHCRARjBvDp3pfIicNpF77(xSMUia84MCi)tkZ0sMWrq96kLpZoRj5wo3r2Tv3sHgpx9snfIkSTNHHgDvrHQh1XudHNFKfXOuSmvpbPU0QJ4fOZE0(zz0FqeDbt2rogK4ON54cNT9tVK3JkrDeSFdvObMlq)4FikhBrKIbFX8L3aCWMB9eOJAkTz)t)4D8bBDRm)KTbPUAMKoRVN)C6eGMMtszhCsxhlzH33ng3OmlCGAXKpvB0N34g2A0YrIYE(wPTE1ah)RLJ0xxEA1YtLcs6JG0sJ1JeZYHFug2BH)9cRby8yrRq7dytqgGe1Ac61zEc2kLV5VTQW4b6J9TuloO7tSphD2(C07tSnlJVwovJbAj6wC0s0Zzm0PO0N6nlKvN799x4C1PG94L3MSDFo4pijB61lFvAGBBN1NjJn(PhdXBG2PZwkNkxRQH8pQdi1g0MybH(MYqx6FBUuzV3q7QA88nvUzBk(QGsBmhuW4PPc8pr7N4y(JabTn(FaZffnbry4nLcECXn6xRZNMZQE0n7J0MCvfzys412qdgiHMRMfZG7Zql9cnEpxw5FrrtCNfmEKqaK2O59bfH(0SrUftej)xFG1d7Pkdt5jxioz7DyMXH4elcjCdE9HtTMWKCPQwzYUy2CWnRGfkEmHkgtZ(dBCsBJ)O5uogzrFYiSh8zHGY6T9O2ydY7D48YxAouBZW2wBPAAv1Jm0wqBXVa59GqYwS2xUb8NLGMY16FG59YDX0wc(0KSNEx1QjRvO3RipcPj55ri5)mRhSdYfQfcqxClSz9LohFXrAWyw)kWHNvLKkkI(ZYrmDauIAyMWIJ9VbBWhoOZTjZlu7UCNY5(RC420O1eZsptqP436HhhfTHjb8uwlC2KRmTCqMorAOMFHttdgv701BiytBOu7lx6ftgRNO1FElTIWLtpQ8qFWr0rixPh3YFhIw7oFMTs9oNOJ(LB128rG6rv7ZMLF))27kD32i5i8ZIrauiJv8ssDeBerby74GKG4SgRcW(pRLhJehSuCu4HveWc9SNUQQV7QpMr0E16y4)qtnSNURU764RU2VKOUSK7e8hoecEhiLbQINoeaECykx7nMLhO)2(KSeWwSJKelEJfig2sbv2MUrwWMYawv3uHilt6cy7hLvEykmKeFbJoY32CdPA7M)ZUQkWthtWykA76jIpoLcXi0mRvIV0UPDDx9kXhoe8C(YQncDMjhVGp9kWsULySNSgnhtzUfjKWesklAUd0YEf4T9DRUg6sxRv(TvzQ4g(Lmx8xZYti8Gu6sYzqArN7T(OcXBPchY5NkOqDdIB)AvC5tnMLzrlEZzrJMqLM)5mtxZe2QGL5TK1t3W4GnSaTygMN7gM5zEevuMIxa(r8GQGoScpJwjd6o80(fxqry3)(hbCdUUA1CX9jXKKWu4o8akCa(DFQXYyq4xcy1(DaEV0feBpdcwwc49sF6hA(aGoH4tqgvUzbwMs3Hn5VF)NqZxRWOjd(kfmfwRoNkpRJ(VwXHNtmu6eHEoQghP5bawCfrpaNuR0L62pJuyK2dwElxNEREFomkSzyihhQ75GOpAX9IgSpjcDlX73UG2xxAvGK9iC(Mo0bLksZxpMySyMcMiYOJUcALdqWxCcVGzNOlHVPI8eQwbZxDsIXI56VzaL)rL79TjIlCk8uC)fJi3EXCNxS9mbhU(PZ9qoErERmF0IPGZ6AHeA1GTSE2IedqGAt8xBZtCLz6r0dWaExzheR6Fv8HjUgSP0jkXlN39puy7EYZ7nmNNxcgWm9daCKpDpx49ZS1AZjufVyiA2iXzdfTHV9Tk4WLGzJOstEhe9W49vBp0eEXeDfLnb8sqEM3SB1mIxOsxnTqpuK1Ftft5kjDfCQOaX2he(9wQj7892Ajhdba2AnaC0Zi9ki(1tDrhP()lXinbJWEG8El63wQ5WijPk)3QcqnJtAr1nqhsycsu0hftXy9dPSOmEC3ZOrWMyBdr05iXEHPn28SiY8tG(qpEH(DZ6M(Po07YqS9AuK6(Kpo071rNNjuc1N7D6ZhfRy(ZPZzKRFQ7ZWHgLYLua3IbB6UBU9bUCdj)cY(wGJvIH3C4nDONs4(z9gbSHheuk77lX1QD37tD8XD7QKPDBp9YAJyXYs4WCV9hdJxSsSZ96Hw5p7brUANIwYcu1t1jR)P10y3QG04dnVpoKgQe55ne3Bf(eCwUXWMw3e0NTOr6(q7Vs22jqBiQMlTvu8NLcSLtnqIIgvLOVt4NQZQr5d)63R778hsXKUkbhqFCluYmLScg4bEw7sb(8OzODGITUJUDYcCeINs791kfHeRfsVWpTQALsRNGnnlWOSt2Q6TfFoqVFiey7y8E7ONCSrsH2YEHCL76Jw)9W(dHcwXt028KTIlC(asowLnki2(j3eZfkLIi89qvJqAS4ex96kBvIoeTyFLmUqG8HdctoHicyVe9TJmr4W9Dq3mX(eCbedNocQXPcoWi8nnysUjZHxiZlKAGHWdaVGI06k1wFOaPeQzAAcH9oEaVeZok0kUQDrGZ5GOAjgwnfwOt9hXLePEf)0MfcrDZLzrJjif155s1kzR2rfVJVthxv(ryX81n3ElUlOdbhsTA6SeE3f)KoIFm7RlwltjlZzc8mwB2XIFv1BluEt1jWzTbf1GPvazAImu8akfsFiMnZcy5yy)dKgflnGAiU4V1GTOMurGH161BG6CrGhjfllGqK44sUPKTDJPe1WizIaZXQ(HqkPaVr7UwC)SIPo3LRllO7kCEouOT6Y7Ve)FxYzR7LsjYrJFCO18O9vhapPuLvwSvD6LJEyV3VFFFedKgjFOxoTHI)aGdOiEA2eaqd6keLSWIPEfMiJZa4NxdobcWsOv7E8rZq7u7hxpxSDY6T6uSbM2GIo0u)1kmYTuaOvZYWxoHnrAuBJT1WT7wcKGYFsMkVscV9MFSDRYoHtDnQSdtHkRdA4rSlicxJ2xEoYUKSCxdOD)Qn7Uvi0ctd(zqTcs1XC(ZosAmXqpMK7e8otx38ZknmaizRXxTmStVPARxQdk5Nn251a0ejRdZvt51FX83koUaKVL3uxcS1HPfPgeQkIXrS073KqaIBYxdkSSqCHx(WIxLHujNx(7uADmgFKvVEIp0Y7GpooB4G(mQ9jXAuX7NWJqvjdqEqGUadp1aO5cSQRGwjbRYzux9Ys3qktTxwD1wIOPe7bKyDq6c7y0vCsm6vyad(coQedhbdUx4Ssj6IQjeWknH7ggE6bE17j3U4kP2SDFfZszmUTdlMhA0HKmcFNSjTcjxRSlTQ0DauNU6oTXmQvhW0ejk3nPMAWHgclSMS0uBdXZvx9hWczsHeqnc5bTrwv)Q0stj)hXekdN(YdEM62uWtnVEdqZMZnLke9fFL786xHqgC0TrVe4M3lrUNW(qhBbhf20f5xdbOI(R5u2YLk(utqxNOLUGZhd1uMIRpcNpC4agYt)2mgERuMtm24CBO3SOQPP5(PmDgcOBSs)1pXZMkKhLpMd7(ElTKd7fukvJfiCqHTUxK61IttafT(d65PZm87lRmP6FhILU1Ml55Jx3UEy2SETlLhg0yhH53dsKmoOaLA)6p88F47)Gc(gqVS3aTV)Ly(2qPf0wDs7mcmmydzYYmEXcrS5Lrp7c8fqbwk79Ll8kiwNMcnbxdqLt5xeM9htvue0Feo0ue2GAPjsXPH2eUIU9KuPF75Zbr6)XNd9c30x0oF4O(UMk7t9ojQxKohSWVZ3)4VjXsdcmW5rVG3Vt6wC9VWc3SXkvjGdDngJpjt2ZQRCwqJt(rrxcDPQQYzjTaHsVlS0rTDt1YRO7mc9mvykory8WQhSQCh2bZCPCfDopC2jdIj7axTDwIEkXNsOfIYNokMdP4fM)9vQBdgFu6U8COHtw7TZBQ1W1)6M3Pdn4nckzfzx09n7ug(JB7ABsvwEQnMCtfqKnJHjEzu19l1tOLwP)Tx1SB92fLj8PykZOoqz8TvKcHG6zKFiv0J5g8(uMSliyqSxRD)LAj64tnpNJjXRw5AgY(9BKOsd(uRbEyAgYIIIG(awKEOGWoEWlgCCRipd5IjsyI1wY2HlRHJ4Zhp6KqJTdiGE0afK(gNEiyJTfbPPX2lWQAJRTP3ySI5FG7UIozN6OM2TELtjnW2VqUElObSZDam6SYP4a3Iz2NPzqSI1v7FF))0vUEf8KAzeUf88KNRg6CfCVYeTGhSePA6lvXKJkmiUGxLjujYoZpRGh0l4iqBaGe2Z6W00QT3HEiXn9z2qhI2Tcv35n)tshNgiqgXuAcpa6xPeRNxHyMx0ouPwlfXgICgK7vXlcmYYqqGUWIU(rOIIgiR)HRo(vCN8k2evFPJIPB3WbfLCANGz7gNAEPuVRexAXzIQd8YKJdLk6q2)leJbT4eSycl5hrgpkdKg3i5yb53qTYsniMYGmT1yyWoLL326MB)oS8lq(4(XESkIFPDnPMprQ4OqDm4lIEQK(l4OFPI4QFnb2Z)KylXnyYiSeqTOvVeKTiWlzv92AYFA6xi8HR4tsP4SxjAKFunbyk0j7uG2rrPK9(q7Jk6EUKDtWutQNcXag9V10kzDHH0aetKsLJTCc)mH1EZ(z0fK7Qbvi1bXHo5iHO59QTYCp7EjDfIYxmOEVxUNPnPjimFn05CbLwXuu(RkUYZDD9vGTB)9vkDAR3UJQ1NhACVF9g7K3AUkXTWcMjOYSWW41ATAEKmgtQSNJjcoClzN)67ta4KUN7)P1vxpz9CsYdCMW3i0Y581A2rfVencmzSzbc0cPjle9VoKg4z5dEOgpg7VALWP8ELZjluL9UDCTDR)VgCJDubqNn8uDWlPd8c7pF51lBMozPDeyS)pqghnsU3kFWmmKmu)7ncKOC8vglGUCtRLssNSugLHKCYnnq0JsH4KtJ6lJWjMfCxXqtSe(RiYus8fVjT(PYK9cJVl3GhPSdgplcm1OY0AA7rd6x8PKFh24lUsgIb4IyjL4(cgby2QqLkFuxKdPWPLscQBGsfpApmxibJx(Oq6XPuaaZHvqF3lSAamJka7UASGhnUcJPy5beKgAQjNs0wYsnnzsl7F1uJpn)zkMLg)zlhC1Xe1Ji3BlmVvy(bw1pYW)yGhi0V8JhW94(EzXpacz(nHjGfZdTjO4xeQ8cA(zsFsWmWYhZplA9(17HSFnAS81YSHKSW8LhZmYjCLoB(2uYgipz(HVLjoozIZ3YaNs2)ZNbopDZ8MVizCJQU((gBdq2gK1f3XKGPksDQ88oxQdWsB54JcLqMuDsMIwjQtcMBJFUwxTc6YePer(mI4BzcX(ntikHUgmhTnDPWkqqxFtFbYZGph5xWEjVc(1nFcYKhbQhBDZwCQ19G8Vv12rRtEoFpN3DQu5QiRDG8jrWKPOFDqBJRqtj)h(Ruw2GTSqCgHhiFichxpLJseusrpLYx0hJ4pMWrXPk(vi1PfvSWKR6K9HNeR42eSWpQk75VviiDj9vkkUE)648shJyVul(UxvqlLOvQQWL8Gw5hnVCfoPR2QYLQO3LrlW0R3N8XwqbZDC84CC3JZO1CgJLAU9Lqp6E5wcLOiT1LWakOCyGhXT4a8uv7BHMkVvSFSdqxNSD7)ERqTeaDGBB2cL4biZ1GrgCR0ezFcfHcEzdv5z1pfLhYfUfhSWTJ(b1K4s9O)I06bvYihHwgHQTpoPWOQF3M6HFFw7FC8bQYu9TRLU8Fk2fCbN4Io7sDe5btTndRsAujQsS0VrhfB3)79usvSxvVU4B2LVcnq80lYY)puYwWZLLc307fRQahwFjunnQioK9wxDL429cGdp0luQNbDKMUwJp4fHLUHPKIKUpSq0Au3S72Q1kFsO)PS5DSjfLTDnrornHTC)yt9ZpcpX(xWtEZ89k4vtOCchnKI8gR41xTgqRv6mQfWUwZsR0U2U0LilgnyaMPo0xMYnX6awPjxD74IRmoXMDG9duYDybCL1(YGKv4KIwSFvSwp7ObXolHrzOPu2ugr53wR(wbQHjqnFjPuqqyoRIC(RbmzK1IbLod2b7Sg2xlFWug5Lt8Cc8PrAr3i69It1(LFjgcW7l6InC4TGWSVa4(PdflnzY2DupiB6M0vwu5ZDwTvtKIQAz9LtrlI2LwmDrgf1zQUv6TGKezEcGeHA0dCOEoq0vSc9)ImEKIMObGLq6mQZebCBEWQC2JP)GBuEO5CcQ7TaRa(GmuPDvAndT2QBUrm6Zr)8B5mhCsPYAUc3PIh)rX1GySxT9asTb3V5Cz5X1ZKXuZjNGBRdZQwf3BTF65fTlwpGd09jfHvWwIDiZ8PjnuRCxFBbEdyPd5p5(ub6TM(HCi1rE0DPld4w5AwyewSVRo4YPKdHUaOZlOlLLd24CJWXHZYefK9tlbW)XV6Gq1hSnopXEzN4cY86uMGpAWbptY)LjoAIpP8Z5o2FmveCgE0JyquZZXdFvbK2GxuWDRiITYp0TP0V4ulAKZe2SMgpZmE4r5oKYday2r(ObfuUlC3s0eQYQ9iFjpPES(KAoJ9JCkRKn5xM1bkVQBAI4NXaN(h56CdJC6CdURdBmG8gSxfDWEukEvcaDDevwFQrjl6GHKa(kJGYO7wdYDj(KONOmkxH3Z6AZOUa2osixzT0C0jC2Hwi)mbBNHrpQv0f5cJOZomYPjArlf7F8Ij72UOz9hV4I6B2TeLM)wOlZ)r4FF8)n]] )


end