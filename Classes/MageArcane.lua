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


    spec:RegisterPack( "Arcane", 20220809, [[Hekili:S3tAZTnYX(BXF4PJSo0suhRDklvLxh)EjBThUS2u59jrcsoueXGam4qYk1w83(B6EoWmyobiLxVV1FizTiaMPNU7PVNEU90B)LBVzrsn52FA8jJhFYlp98rJp90xn(YBVP(XnKBVztY8pMCh9FKNSM())MY5j54p)ywrYc4ZRkAkNt)Pv11BQ(lV4f3LwVQz2O5fRFrv66MSK60I85LjlRH)E(lU9MznPz1)98BNzDUp9v0XCdz(T)0LJPJA6Ife2RsQMF7n)ify2oLbgB)(30Cxtv92PV65BNcdY2VF73)2vj53rQ(lB)()82P)Jk6BtxjPZtY2o9M01VD7u6ZxKLMF32Pfl3oDo9pZj0hMMxtklB2aGl8xv1KKfS35q6SnNKnjzo8WdhHdnBE2onbHLjP5ltZtRFKoDfYFCvs56IC6VDukfkZj3tk3o9bso9pYsVh(4QUV7XSr)VsNh6B9U7lMtrra8qx1)872o9FHl4zK5jnWA7XIMdlP)3IMAgSwYHQCkSNxq)XMkCTYrztF3N2KvurxgS55nlyd4MY0Isj4JdT4lEFXdKYdPakz5scfdaW98IISffpqbQzjveanr)NV9V(bXlvnQf9xvxMohNII5Kkg0atsjzrZC6ZF77)h0FiDn9FUOHWbaknbE5Kske9M3)dBNUSO8J8r9hlUhMY7tkttMLrQEbL4oNZOvX((FOjz701flAYioMSr3EtwAvDfWcxSHKtkP)RFc3qqYHHDXTF3T3mNIti0P52BkBYjuy4oYOfPvZt3q5GOa3ekB(AkUEe)B2o9akkPz5sRV1KLLfv1JA2C7nmwPBVzzAjzYSSKQ6BRPBeIy6VRmTk7XjPZtNNr0Mx6uKmAdGQVMUL4cLjbM2j5f3NatYzDMe2oB624SmsDnL8mPSz2JTFTXtOJX5WyiEHfKK6vZkkbbdTJl9TUW5Yrdup)K2XQmzrAsE9KQnjLFegJlDogZPSb503De9)uV6XsLbHISMuSCYgGZfgKVvfCxNwwwuwbVqDr5A6h3bSFPZPePS89R4GpITj4G2De6pUKSoHkkrbzUkDjIjLW2R8SaTpKjlESLpJ)mQymG5OQMkVE70xB9HRt(0e8fAbh(luuodaLtpjAKT(A2eLkw5ib(LNBmJsw(tpvL2ux0mFfomRitwNCxAhsZPJvFBv8s3xSlxEiIOhUNtpVZyjEZnLKkcvZa82RtZxWusvMUH9yu637l(rMeOQ)DdH8FqrZuPKFQUmPve73bydq8xjt64k6V9lf1)4lEZ7P6lOJCXdGmrQSokcLcF56I0NVQy02P)9L6)evPbinmjJsoilEoO4HsYsq9knsq7bQ6Aq5I)58bIIcs(l)MFuQ9Ko4vfWBDygvtAvcOIiTEKkw)zcqrG6jauRk(AbbPmgSau5L(FUKv71xr10srWi5zKkN2iYNiZBQjty6z(t89hDjGTBr2o9yK03vewKKEGwGO3vjvicFgHKJO9fwiZc89ZLOqK(a2mejNJKc(HI3Rqah5NVNJyXhOX1)KIsDlrFrbvUHQcanPixSD6V(Rs2aT3BY9nzun4jZsZO2WiKcs)Mt8i45BDqAfVyszjA5RgH9nzpK8ifE(o2tPygX2bso3Are9Vci3YDQS9lCs2Ftyuyg5o6hrTpiEQKnLlO4(7MZ2e1ANGUzLIDA4kVRcU91kxWb2k)yhXd6mLoresLWH4K7fwYqX8k6aD7nNs)XKsQfy4FpjDjhwPwJbdwfQDNlxeHSdoYgn9x)1JEgxGiv1Aj(ZKf83T76(x)vPQwc6raSzene44JpwBhuazObebFKW4vPfDCClSXlbT9Fc1u51PekcLIppLUNoszZx3viY6uQVauTlAYrm4ffVfADSBZtmOaczaxXxrAptrKeAfJl7iTbdD9qW17QWU4dmPerWk4qgqQrDm3vaKh7coqrUJD7xHhBiVQ1flkHTE9eaTXENkxwqooGzx2bDnVbo9c3YSh7Ysm5UIBVrAMcU1um0xF1lVq7zRxtOkqQj2Oq6qPU0ftdhb46clMLkfJQAyAn4Yh1jaQmc3EDAzvPjk(FQlvLqnHdcSakD9MBOYIP)XV8pBfSs3UYn)7HKCUrfV7(cWQeQuqIDJ)gXDFhScbctrvb4Jp8Vqj8RG)feYJQvO))nyKnoeS8RAdgHd8NK8lTO4JuL)wtwVPOmjBYdjLBALfbCfAVxv6Mvf50DTu3l0ez9mfUuQThBO(QoHaRnP4PJ9S5Pv6g9BVFcv)WOthPt)edGC)Pv9l28EpezemsKJY6GiBdVcJwuXdOJfm7ZLXUjfmrejRfyCMGOn9iyCpWIKvruPbC9a6lfv0Q)vBKcS6NMA5ZCskSf9IpZrOPRaONKi04YPJO0XeY2gdkJ452JDG4P66mpQDdLD6R3yxCSML82nw54qb)jFrd1fZ7sxwl(2S05RU1wuPerakaDZMmgpHfWDyICU5HU6DP5mIWazz02ZXbQ15i3MAXC376RqhY(gKp4u09Vks9Kzf5nvJQtjLJF5KZ3mhOJ(c8Mmaqw42xtv4qDNBcv8w1AlqW2Pxk4fPkbi)7M0nBilgbCc09S0TtvP3LMXy1K4WopTvC1XIaHQpTgXCsNniqqNCUX1MEGsUpvuYde0Ck9PI5w1BFlx8pObFvc1mvEiCwaXc)x2o9rs9Z5XmiH)PmL8GKuuJX6M85mnbgrrc19hHVyomBDFA5TUKdRbvuWZRQ2hmHa9EQvLTFjqwdQNwOQcAGIKVlKjkClz8zJI3TWx5FlmZcNomu)efcsYYEKXXSjjLIz3uapJZLab9dcuXZHbVMzJ3dPqGNyHtkRanAiVO5UvyQxOVxb8jTE4JmKTwlw5IZYH9OT7nyaM1GTfHz5EnDZLYapHGAxNiJ8xyeMjVZLAiDocfWrLWogfVgIrlSG2aH9HlrZNNgoKvie(aSdcxkyX1eecTOz9guW0YgKNe5BbiwI8Arjb2t7Whs2MXwJRyiVXT6NobXGsXnF8r6SKlCoq688qKIDS9qf1Rf0W23B1(AvdxnTD2iakIx1m5F76ocJhRTXqkwu5fA3IkeWhbhVJCxAlqn)ozfjijMzcZFGCuMxljrZ6wDBXRrkv(RP26)NNAlNXs7RP2AWOu3gW8zn1wJ7AFJRitQRRNOgFW1jFK(3vnGUCHFhTMec6A5ggYtbuDk8MT0NNJbGIs7szjgQKaLqev)jWdWWRmmaRsSYr6lSvVgEpQlypcCw11yGnHqv2uMZ(x)hszb3(tmAxWeeLnNJS6vTTauCGP1eNFsCwtSZk1J3TIaX9SRkh3EY8S4Yi24bLXuz(cRwrvtVGxvAZicrg2tGkquFNiUPmX9CAde35fLfB2G0BEuqfUVW4ArPl4)cCKPdh0QsglSc3hqRJxCshgglPx0AY6Adt8Gs)QbAmHNpwatI4pM4Y5gcnBv5bOoHqzaBrLNv3g)FjQeJYCadM2F5InwMVVMo2VWsh7zU8MO776mAx8W(qvvithhi2hTqac6fR6bMNaX1JThgLD8aLQsy1tkKdQYI1yCW0LUBjYsd0jpCT21BcTL0n1jL1YkTfGCWasg0)grUYAntk2qRfobldlJWkBD8rE)SL04ZEAtA8zFHM04Z6tsJllQzGQN0f7v)b6XgryVeFdygOva0VYSNdTPsW1b5Cedj9mS2YrnOGs7nQRCJy(pgI5FWq76rTGUP3QFKpVJ2o9mTnewzoV2dVPQ4yDOtvGC7NtHUjnuJEZMKSXXiVGKL84eQEn8vyoi4KrNz1ND0jWT)mBO0JdJGeMZUBiMasISs302Fkh(KnGRtPRBGjjpzYg10iyBl0X(cOLBbhFzJpdYOnODk7e3PhSS7mL8LnwMbD(X1Ajh0bYoa(J6lIyr9urb8exHOdzWvrfFbdFrDzHVDdmmTWpUQVjkNf8IICNshjMhoPttadW6eY2iql6XPlcS9RJ6L1cGKtdycKbjJWsfkOIHEUgMpu4XCd2g1hXxDyZPdBhfd5ioF26itZG7qoCSxRBqS86tqxFWJZJV3wKx1SweMbYN2qTZeqyBkQH4gcNmtyPdXNaKek9ZlRaSzv5Tqp(I17j8zIjBICuGuKvBPaxCUuSvJv(MxRYm1CjZU)m7p6plNKpzfQS5ZI2n6t7AaS1tyqDj)yOolj)Jm)PXinBPQiXQxGLGzk(ATmAZpEyhxxOmcPLKHVe7M1GJ8Gh(tXsNWikd5Sdl5NyDm3ZrB7iiMElP74xbpuAdwD68pIHMyFeFAxge4tJc6YRCnLtG8bmbIhnHxUzUnX0nWoOyn4PgtKJfLPPkDbUfvXzynxAG5wT(nRA2qkfLVz4YljJWqpLektHLqPAyO7zUvZoSZX0Ff3ZiTwMfta6(SeiUWZiyGbyrfMk8Muc5(HfJaaORwvGrGgcxarpi98e8a)Pa3DREQsdLzdvZODsj2nwyDT4uod7(EP8CRrUUd7Wj6FT1y)BudoTOM)WIxyHVXs6mBnU3OaBgkpofMvsMu)29)7tC7b9jJI4Qq7XAaXPVuehRawp54eeIpu5eeksL1DWbHHvWIwZML8Sf2MEzxQigs662nc7r(X)aAnu(Tey1bfy3DhRQKJWiI9UFtaS8rFzJZDDODggo3pIwTGyyYJGmvdIJ4DQfaSy1MlstaJEFZ79ZQ7dZh2WSEfkGDM2Hi8a1iVJAtbZLgIeRHXKJ2sZLHbDRwNVbl4e27SMNHBW72cGOboGllzvzX9PFe3ESOPBjVi1JaUtScpvCGLos35tLcPemhfRPJ(I1yb4lRvwgqjoTcw1a13sf96RKfYKA8f(ZkXxO7ZUwRWZ7eUcKm52I8bdNbonkdaq7Y8qen3iCjyn)AOzZAzxZSCPI0QGBTKjXArzY4ITwDMPassbXwk9SzwyWt1MuKiGRMy917COH8Ce4KYo8ed4Hk1H9grKhaUWhk)9j2Gfp(dsXRtCLuGJcLuGdcNtaRL7JDtnIj4)YyrhmHf7Z5lI06jIHVsCbr(Jzfzb6yvhPQd(ZgVBAjX6bjvc0Qi7EaFSi2WyevXfAho0yoBQUpCOHjRNDYx3Y873TmYJ37UDgIdabQe(J0Tu2FOL1srV2YhWi7MHFQKRyah5IyNyD1li3afxWE8eyBT2xm8hr0Wi1iUQR3vgNl7tVi69)AOh(iXOf8Gp)n(k1g3m39Bm)gzKWnbvTKi6nbUwXNbYehB(FnRATvxA(AvDccGTG6)AVbH1vmy9DWQcfqgDfykfRM7d90ofDr7tMyLy98i5(CVfX8DK9P04CwzmZ2YsjYQAnXE2GjFBbJD3vxgl37zuloXipd8Qm)bh)x2l4(L)U2SGl2)A(VyhvU7GK62Yyz)lGBpxe7vSkcuzpITEAQvNt9K8Wbaw7klum8SsBbIJ64AD37IagxBARCCPDL5V3gFRiQv4bGL)QfFXYsfJfF2scCmQRBLJ15y8j8knMLjNjLLW)WKwLx3NAFpjCokGYIPG)MiCpsFW2Bs(JC(IJiPPtOpTbIqdVtQtKBT(d7oDpuJi6DtFvy7(Ke0PbS4kF((eaVRMS2XTIoTVHJ)QyVHk2dN2NHaiq)Mbvzkz5YMkitoj5PRtMKmFojJuMqTTrdyBT(HfpH05DCL3Fp(ON9R(E6aOVqfaR(lojG7XE6bj7a8HBccbBJhMnZ2xgEdY)x3t2dyBxNV4ONp97j9ZV4TavJuh1Fqvz(zHQPY8eiz)(a0Ermhhc99Lnb7OG79GkvyCGs5VzZNVTMAeT26HikJE1k)WRL9NgJgDKszmQydNXvCJNcSyVJb00eyVH7a0D7hHjtCMB32EkGCVQtHY8zCh1abc1q3ZfIBpImAkjpTlux68dPzXDchEIHstWXP0uJ(IHTmq4EsJ4yd2kX08KIOvcugTTI(bkh1N(D34UVWbHfeAQtsh8J5(qBpHjntUxKDNchhHOH3r4maeTUYrav1kvixOA7m0Z1KKGVJVgGMXHEYwNu7GUwZtQkYH7wrnCdmoQ1a4R3o9CP6Flp8cfL026MqZAleZ25bglwPKoAfjjRELSxfC2fAmMgTdVArR7OpuHF3TSvPI4sg1Hl1XlpVtkyb4TcCwLDQy7i)1VAClUdSU2Gm3BP9WO0fjI7c)RxMR6D(CRfZ78DspSeT1In897CkFTHrxzuF824h4cfp3ToUJEApdITqK5Xi88a98vhIQdJk6Uboz9MS0LP8ZDqGnXVm0MyVc8ppqBykG6N(aOM3sJAasC3OIDCXkwIPn1)NpKtfAq3ipiQ(4Tf4PgII9YKMS6BfvST4TNx0aj(TAdjlRJerVXoJtLi5zP3TQMsl0l6u9d71lpPZpcYnV0rbre5qQZ(HDKN7i4TEqCuBMKhvBwABN7XuMJU7jL4Sq(0QKMkK3TvpQlPFyEybeXScOV(EaCR6qrbt0SJ5C963f7tlWCdaCaL6AtNmii(cqsKNhAKsvn5F1S4or1Je4ee)KbkZsUdFAjvAnURpo95MSbZO7giLGeFyuItbRLrjROyXKLnLy4(JtTP5OafPnosWG4P(W8pkG9Av1aV68e6U8AVvTL)HQPImH(MRzhj4Usi457yEcl8(lP(UsT1IoVWfP9sfzuUFLAlf6J4RUld8hQgsEWSKf3z2te6a2rf4z86G5Iq(BqHh82bFcBjAaj1EQthN3gm2mUjIWK3T89IRA)yYyFcVRzCvzkox(pZU5DrGbUSxia2B3T6LoYrp(YH1o6rBfnvFcQ7u3vMNq8RRoJnvp0JuvizudCxGUMDRNWJAJDQFLMnusOmq0CIR90thwaQ5WdDY9KQkswpGsm8HNiThxn5kf5tWdd5vOhxCBjupXlhO8(6xFHIp6GWvYMKQySiQTurgsHCfnztsVlhwL9C1Ew4vRA2LLZsTNcu4USh3G01eQLXRtZ4LoyVGRVmOc2xj1EoC)RtMNmJs1QwrO7Bx3uLoVhRCmJ5kBYdSuWavOkTPDtTfWO2ZPNFFb2HX9wmal(7HaqdZFgNRyUSFuKgZ7Eg(roUoM7uV0PlEYcWXEuCLO6HBrqQSGCUsjQWzZY4iNbEiMSZmowDy9tQBVQ0BEQw66drWV9yfwvxy3Aljjx78UFXOl53XjWjkN6xjq0L9rGBARfMTt)qZShXwJ2)IAzf1zDNfmJURNTfCGERQ8BKXIROljY4wXW2vGG23Rehu3FCozEzrgv9N475FSjXuFmETmAFlsP(2tvDUD6lOeza1jTMq58krTfb3XUqjpYrexmZAWrMuyJPhYZ9f66UmQzjxg4MtAaNlQEmpztfy20kyml7q2SBHEK7bUM7)RzI09RSYVv9k87Uwd1bY(S3AHYzDXhiflDT)ewnonaLsSaNEbv)kH1H6O3e2Fmjlf6BaW)p37L7HJUFT3KB3liaH5EeVwl8L9Friwd(Qo5iGLobmT)WbFaqyXDWcSVzoSXr9dXAgi8(VE6ChFx7n11bwwFMb9wq2tIS)mdtsBlqWYDyxu4aGOHWUXx(TcrkBz)1EZKTly(0FlG5wy4wmG3BkjZHmTzgYBPuOAcvh3CJEQI67w1SMczt4FYYeQ3gPjDV8Cpt9lMxK)VAkbvm8isR)UNR(USsHDs6AJ(RINi6klxK7lapFYOwmxKDVrQsLV2MMQAOTnsGd3vABUuuIYygPA18YKLbcG7WOLOgE2vETqxDzXI070FLwLlyRufuepVJH5D1j5lQmTloJcJYTcdvx7SCXuPTA912nuWSQnCe3AhcpXpl25wy9OZyB5uvJNmO7wbW(gYTAqLBxU7UvY4OS6wpGBWwj0AkNdZAvz5EUktu6gd6og9(Y0c6SNc3zG87BhwRYG6Ue2RmenqTKnJ2o9FiURbz)gRSHlG0g)qAfr7(GRf9o4wVrKDOLOUCd0Qn1VCo(1rwM6h9LBzXh4EyzxyduiSbseRi4EXMRwWXHV9KTALJ8rr7Z3PHke6RcLZ89EPxZELOkhEDSG2zcOZfjJvXh1X1wMIqMkFHdW6o0GQ()dnxTVkpAFkpYUDoXu9eF2yAd2v1uweADenNPZ0s)QqxpFsAjER(j0DlUuqtX7hwkKH6(HOpbDTt(DentvpRfMR3pvHwV6Z3kUDmP)VkuMlR54sXMKo2Jfr4NIzZfqPFfgx)JWROS)KLBlPZHBlPJJHbuKi6igo)(GeXQd5g0EApc04VDl7aMY62TLOsPX(YRr9T9Aoo6kpOkhGA73AgyUdvVY5vSdg2BWm(TZfP7duN3FU(L9m0EBB3MW2CW(6Ux65rWfflZs30N7Hr4s)(sfbq5Vrx15KQ77ig)vZa96GZVzM)1He6YjZoN8iZRlt(bzjvU7b7T0GEE8MXeVKlwW)1hk4xg(mLslHE3T82NgB(0yQ7wdn(f0Mb22oulw3Bz9eSHrJ7bRFaURZrC422wqnVhxJxD2iG9a)U4hUIZyk(SFzNh5bULk30XbUThMizmijYs4mOLyhfHHIDpEBAgE54J8cFIlYprfR7fipoal(1ISyhWq9aS)29oazRDLs)yzRf6he3uXBkQQsbeZtI(IyybT1QB2fxscPob5ZgwhRKBILN2Pw4j3XzJ6lkLgAcC)Y)m4)KOyzR3toRZkwnqbyeHbuyXSB1o8qsF299gx9uDL(6TrM5oHnHWv9WyZJK7XBV7qmKcC6zAKD9MjONZZEVUqS9e7Nyxm9Tj(Igc6jXoEAuz9BTPEYH1Me5CBSYW53ZbrVxZFpzWdbwU94yyNsCp9UiMWHbDRk)hA5kEjGE6ft7a(ExWubncoKXSwXLTZzA)UcQdH)EsU763f8xmb1TV(eybZSpUEVdHBFsUh79OCjsdU08wQWUbGrgU7icCEid78Bkzyrpx3Rd9ti9KXCbj5)sdYsFYXv4Yn6bbw8QBtXAMZyv)7gcbYpoe0bYNQltO)ZzSlllmge50FSfjiUqYGBeR8mcC0jfvMsn6xyroeL8fnLySkeXIabA4N5UaUcUsZwJxrORAYVdUOR4Mk3ghfT7U5GI)m5FJPy6BByU1ERnZ9qBXOBhVWX187b67szixp02AV1JPLfFVql6Ba6CBOh9UJ(VMQ5vmR3l7kzHD)T(251RpNtBenZLH8T6hkDxz0Y1b0ZBxAxrr2t3HElI((1EZJPyeeh)iEUBFWCVZwEQH63bC8vTBI6yw8WtQ0UPpZewu1onwwuRCrvwAjOwAMqAmZU91Y3yYSEvSF5upxlkUDAY943UgHS98QiPHUHHEDGV)T397qchrSYzXmv91d3qYvBlVTH6AVBPVdZh6bDTXVh25DENDE2JTV)TEEc1vS8EVmAVeF1EW6AyX0PWHVuKt(tTNt(XDYjVXwtdH4YBtlssz2JtW)U924qTx3aplpNKHO6d0bUxFPk60cG)QOaC)2bgTDIxhLDIgyj1EVJNGYzGygHnbi)dxC9JdBHwpSyNR3QDHhPB)LNWOjfYS75Pos53h0wZBoUZZHJZNRWL1lvfOu7tTUzOTVG5jKGUrg7uhwYtqX2n0)G7WsR4hemp1gUsnBO5fmK0YmWluiV8mprX8KlD9MN2(2AhJ6Y7Dq61xr99H)Y0bxflO3UKoRZ5mZxPcf092GYTz7eSwVY63n2ei))51CV)z0aoEC70LnzzpoA70Fb88hRri4yeF6L83KorTxv2W3NmNFAeXkyaJxa062Gcsyznd3I)ix8RSweO)exedlsdlX8soQtSSKOoCYNiHY2t7VyzBidyL51H4LcKTfr8THrUGWB9N6N2sTJXHDk5XQAK8ipnWvAE7TfPL70C(Hy4D82aY2P)mVpGiRwrkF8sYdYq5igniT9i2(HKu2jbVLIb4nwzKG)jfLvwRC(XXZ0UkLr67Pr3ir3w)UhVbJxxxnWLVuyOKWxpJ3FrAfdT5X1AFjs10eEH)jiXw5SzZQIqFzFCi3kusoi7xg6XOByiUrWDH24q1pwSZX2rt3)QpIlb9VWwJDIBs3fLiWjwp1CLj5FKPw(cZAqO7iPZvZTpXog2Ann4E8SIxCW6UTt5IBujcruCRq9HbDzMfknP5iid2QuL)iJ6T6ERBJQhM3TrCGXdSHmY(FVUrnDZT1vYqnDepOV(pgQ8Ss1Q)1(rrvpOMbd)OdPaQBhmcLsehBr7iWWX3WSkGI4qPBBZNkMAffBa8PqkYcWR5S4)6ATTzEIgJ1Wk(AudfeRAWKT38(V5d)87fj8bQ61Vd6AIzynLYk912ctLI)F7BRWgpZ85uyyV56a(cUtWHnD9EmteD86shFUgtMUp6CeJzQCWrzMaVary1wKTSZu6IA8HI3lOa(W(QOCd8TV6hvfCf7K9KlBrFtlKCeqQRQY4qKbvxPTDfBJVKUY99KWMJ7r0c7GaFAqv7ZLMhjGUJXyajGh5l(l2Uis4Vi7IJbZKO6ADVuKgxev6LGakqMxdJ71xz0Nk37OCd9aUAWKwu8BXBq6Qph9LJdBpN7ZoRwladRsRRizlzIlOErHhVaWTDQ725QN1DOOtSqU7WcdDG8t8R)VdoCpyZ3XbcPPxfM7ViHjcjzWKGf5ficcEDJeHrlFYmuerhR0O0XZ4JwuGCrO3(VP4DYsWOIs(iSGl8yrJ4WsISyYyXiIlKmupveGQ2ogSLmW1rxdy8jeVHueI8Bxw0uwVAWi1XdgPAlEQDrGyEi8euM)g)QLz703nFvbfN9gUztFxgAdu1k6Eayzteh2uQaOAmyIqSweV97eH4unenyo87ItFikI3GXMDB)kRCE15mumUBRGhaGoeGWF4UDNItVxJr7FaXDMq7fEkIx2T8p1mperXSzimM7QDeWGEQYIyP96OEz1dsIJn31EkQUWUkbLFmDZUqO2ms9deulTwHTvXSwVjhvg)D)atdCrtn)G(HBM)G4tUHxlClijzzMHYmshFcyFFiZrfr1igFNqCOlRAu0yzb)r)52tjPO4cbJkGKn09i8hNhKVwOO1J9kT9Q9ycWW1QxVHHSqKLngxDNB(x1gV)2ShmpucBD6HloJUov4E5HHeIbhQuulnoCGck42XdOjIc6K5G5dKdblbyN)usErZDRG)IQntrtFbMvbqBvzb8Ps19IXcvzvwS5f4PkelR0EWH7Pag0Do3DHwgvicgymjSVjr8uC2MiqVAtB3Ofy0kiJWUKViOLph2PkhFwGkqBhftcc5G8W806uq(MYec)dWAWTIJXSbNHX1lxB0kgSv)YD2h1p6022dr4ZcabxPDSenweAw1GYpm6RMc6FGY8gtH7mc)eEZSXeR6BrUBBeT7m4pO(Pn)Jy)nPjfmsLJ1vQKB6Imzzn7aQtEKtMw0SEdiPdCOdzbK(fifYePC6ETRsBZAx7T82JcRT0rq136KlmJoTUblCGQNdrsJ(R)id3Tr2u5al3VhWiytIdSsN6JBPq(JjlRd54bnyu3uX4sY8Gc5R9fVCZEsDNnLWP9(UKYfmD1ahwh)cJJ8hJq1(HKQTCtC60eBl2IyXzm4aTZ9fJrLtnrwDCPd3lH7EmCxMf2LFSv3FeOPy2L0F0uxJ5)9u1I40ukOrZwcTrhM5uUmSYUsASyrugJj3LvmljdgG6W3MNdMd3Dqw95m2zUZeVs5iPxLDALgVXLWze2x8ZTkZNXcUbqE7Q6iLBfssgpiVmBmQkaZVwwc6IqxbIbbUtXYR2YT2P265)gdSfpuOR979bR)TqoeyS1kGSDID8zEZDGIhyAev(nDIlo1Uwo2P3OwSKxzq46oJDKSOIVkHajVkvAh4Zb6effxaV26ekHmVOURfJSsOdLs0SztbubrkhYlacZH7zBZZ51C4SJnJOBTiYAbnhojdgI2LDqorWVCqa0BRCSRFu5ZA7cDTOgSAcvAN1EkOqdIBpCBdTNxfy03JPcp6D46UAT1HC40srkrDz)04tgp(KlHJzXdjLq2bOq4)8nF4N(7)0)ZFz7uUS601mkekh(qwF99qqzo1mWsWSg2E0KM6I1jy2rarY0n1J2(9)qkOy8u6G92IC60Ip(W2We()EiJnq9NeUetF0rN(PJLJY49YOC65DggEcKKJH4VDoaF7qHdWIO39Z)q3X7L75X7vdEbU97dq81BUZFUycg7Hji(fh77pBWqH6O0LhAyJYf7LrzFZo2LovtDP7JK6rjZMpse0lXa3MU0zZdUrlAatJGp8TB6cpoz)mmdNlwBy6Yg2x24Xxoy4y8EzySZ8mEpllB8tOSmXDOXH7KuS4bi7YF673VRAV6sG673BSDCNhGOzr8R1S3WXGzv3xABDmaddo(sr(wWTDWj1VFB5my57TcPGaf)YxVFW1qmfz8E3ict7z7n6HpqDnhzWd0EAh(EAJXUYrBxJ9nPRFlLh5X8AOVx8FXgOFOH696I07tzbbKALCjChuthQxCCilagiyzq0IGj07amq4yWgsOpmdM1zFBpIFZqg2WC2(rg9z7ho6Z2v)PdkvvEdFDyVKR2LJu2YZLGv7V4AXnWXWox0(H3U7OiQha5yi)bxJWEEZX(zVXUU1iixuVTxyiMOR5X5oUISBDq8JIkSme3f899XdfNUtwQ8)XEhDn322i)T4jtvj9xvsokNZnIAMCP9H276CDI7D3BvHMcYInuI8eLSp3rJ)TF7caccqaqcrsNKjnpLyrYflwSy)cy31L9KTdkv3g5cfPx2e9z4Eho)A)OwrpWpoqzv230EwEf8OF4z7q4NuatB43uOkTXbXAbqlNivbJJQevfQ1pSA9Ln5D1dmna0t4rRiT9dBVgyAfU0p7D0atRWLw4HJfNb6h740atRMv9JAinW0kCPFuMPbMwHl9JWonW0gC5lm314GPnwuQaGUgbAna0YjslKlupaAjE0p7KVQFy8FzBmIRwa0s8OnQMzaOrhc5xaRV9z3Pq5jKMzGhrWrLn5q74tAjCQYUC8rtqZo7waIQBLBbi662ynaC84qFzvBxIWtJC9IKe(5NV)5pyihlw0t6(6iw0pwO3pQ)6hLx9JfXT1iuzAB)ydA)OevlGkhlJs3dLsxzv7ROF0pSz9La22qwvaqBKdPaG2RT6PF6hPYZXpdVDUSlR5tVpjoFhkU(3UbKIVkD7VDZnXR3NqVAkVL25wVjJD5B)TBEXlE69)mn5k4PCWpH)YB2Fhn3SE95iLE8yCSWF)Tmvb)v2FDXtVNMSc7EmloclgGStWeENfj0RRmEB8f3LEXLeMIJk5PW3gHLVQK5SjW3EPa8SX7jEbacZdkmxT45PL6LNhOkyUeTHCpMBepqWB4Bc9c)IjoH676xocFpRry(d0BKoHNuf)ZFOO3uEljkKExGFmDp9gxttuweN3YXm8AbtVoY8SWxlZnkhR3SGbuEc8WNg7LZ3JFbV49ylJMSCjHMkfLPfkMim002hPFV97FxXlLFP6Yroyay0owH3HKZWkCGaT77XIe2B)L)1t8IKOOFyShwJWxoe7egV5x(hute(GeK)507XHU4cIN)DWcEeNNINDf0JQED6I9jeldiLNLNCsxkokVZc(oX67osscmLQ9TwgUoojoCR5xcmi633VftB2nHZVJSMndm9MfZLZXQmyq1Ct580Samb32Do)MCeCLRGICFk2(N0HWOjUcc4jz7tsMdGcbdcK4LbELs0KlUVd8Q2uDoCq8lW6620K0TlWFZu6c77F(9Hj7jbJy)7CssojyORykEl8zxE3fsyQAAanlWAka1PXU8cZxm0mO5ma4YdyPPbnVC1x0ETRaZy93rhEoJCgBRT6WZzEktDq2(eCHgG2yNNTRtXEacieISGorNF7J6G76JbAUq8gDu4xZZx33HBSdLwcqypK5TRCw8RgkVJX9Prdd7XVUPbqGq1f4zUZDPU)E8Wl8MCQfXzUoqgBTxQJZKZgp80sHRBWS(du)qoCWZ8GxTY(BvSNV)zJMibAwljAqP8Dvdwg4S80Um95YduPZx3v6mpNHMx0veL0sOtz5d8RGbMNkyZP)YPJgoSxhrgbNpCVEYZ0WjwMQ(ob8TVbx3PzQHMozxKjvTXfAyFSRGIYx2FGtnlHu5shDQN9kcoSvL7afU3suVogu8RfjJD0Q0dhoPc7H)aVtmziL6UXGrhoy2Wm)bNu1Ym)JzTfGd4DG6SvmvxhgfElyOB(kcS5Fn4(r0HdINExcMMJ7WUv0THlUJy(rRjlctsaer6Xlc3(bSPCbcgaBIY2VdwYIiusP4DaV3I2UFhISZ)V7HPhWaUGCFSYlvTK7j)O9BOLVI5WefOk57KE2dHFaxJZNVCli4r6bltG3gxbbQ1oWhdJM)ZArtZJxJ(0A8nwcEVSkcDdg3HkcJ09POZmW8jpnbxRoCq8OmWRnWPM5KcVxncxf(ldYASlC3IUKsz8MmS0zvnwOcfzHkIPNi(yj)ocgjHXlIZJIZaV6bhebWUEn63BDoPrZO06G9j1dC5DEcNAeGsvCGFDScYDRRUGpvXMbNybBmJmIuExrTGcki5C8zOFS7XaMKNbEel)7GabHVTuFc5cYKAT(dkYr7PG6fXFml4vt8bXHNu)hmXxE0YslWzJL)eP3KMX4peUndF5sA5oSycSfeiJpAafiK)3QqyhvmTE2G(UAU(OgUaKyCBAE(aAdGyoVclnn4Ldvqr6SiF(VVFXDfRX64koadmu2MO)ET9fl5H62W7OpFBC0hYFwhiyHNS9datLlKEMO0L73(OlVnMB60VWLxgvHMVdx)IaffU8fi)zmSQBH(y(LzA8YJczBxxUney9rF7XyzTKy8tyb)Ao9lRQTZ2yJXaPMQX7SGjtSVivhQR0flnj8V2XDk4a3GMR(B0xZ7eBTEZdhko53kp4YYcShdq(hXePQnrnntELttKxnaLxm7QHgLZ7QQn)NBQHM5KSL26xkN4efaTk32WUaL(rRHe3tYZjjnoQZax1aZxljuf2oI2M6HK6GHdSOVsrpVI1R1StfmnAE8DBWYnHdi3v2qo7JWDjpMrPCH55XRJte6o)SIoyWg8gXXPbta2wRibW3Y2z8mmS2N5g0yTpZ0VkGM3OHxm5uB(9GZHPxnSgoOvHaQswGfJZkwOXwMG1lb6AQFxnWtl6jLBSnvhrNgmUjzxUTZfTIQban(WbvJwQ99P(e(07NC5R4LQkAzSoJqwi1fSUP0BQNE)7OvWCWrHFhpKOeZkif7uLDcJAYOGWQuMFoZJbKkKp5Qw5PvDqw8nliH7wDB62nelFGW9z)Z4FIojw(lNwP528na5bK3lqDPZDGgoUg81Q4Od9bEtvapBCnsI3q2Jg)aUEfMLJAKwHFcvMNNjdmCGbAgy)kfJBqowDgIOgebaR3qEyjOrCbWWr9F9CCAq74AZ5faOGr2nkQMrcEy6UkCeyntdzdRGdOfI8JWDoEe0mkOY5e(tn92yQCFo7amziSMBxwocm9W54EmtBgTQIvod6bNCeSMnJh8igyMc1qygAg6vcYM8GyABNDvPUmRlok(Mrl3rNEDylpcp5rUxhII6fI55w5PB23tnPZnTPrE0XnYIXg3jeOeKPgJVcxEikkAUPxHftaMrjME(C6WX802GW527zUVds1HLipBfiWPvKpujS4GLmgdrDP5mMTa7UOf1BqZSs98MoRl5GbzzKBhuBW4iaV99vyu4rLOmOHEFeywGbKT2Nv2)0emSiTPbCGzMQ(ebbX8nP3hQY0Fh4qDYJZJJIJsinqHVYLOb8voUoYX19fkCjWZR5LQzYoKQF42dSTmgy4bIQkQIrK1XL0sMeWszlsl1iLCGxuskBWUTkM9OGFkvc3PogkfjRbQEDEot2LIMC)Zv44MdmNtRlNsX4qLyjK1PrPmykl1Hi5yeQF2gftdg5uVH1n9QQisZokAXwBjbMIJ1OkW1OnDeEYRy1akptW6WHSAAPPACZMp3i78VUWIkV2zM5tkEG1IhnaMRDcDU(ZqvhtAR2bhIhJrfakhjxr4OTWxPTjvIJsFDQlJuBxxAEzpOrEqy(0fu)R6knOR88YIJDr8xKjAYiVYVlWDzaSEnbpNlIUwLMfMxUdTs0rr7KBM4q5oqSYbMi81QIGkJQc(yFivuE)Sj4PrRlBLuPgHAZKrnjw2PHgHrfYNd7a(sBZxvcyzuQBK69Nv5vhVGL2AkHIzzkS2()zCZ(Gt8e34mYsSHpDpzE4M41HZdJIijSc)OKU3vY9dtT1nJgGFeEL5GRgtdMmSVhwkVuDd542yfJrS6R8Tnd1Mj19nFR8arxLCqq4xyYG7zkQYaioeqddRtK6X2NWFQjNnCMQJgx7jD23mY5RIxs1tkO7vrpw7NNHCtoC4e1a)GTJ0Mwj7a(oWQ)a892kDRYMmeTliIv5WZW7rrZ8mQOQBkc7c(At6FtsY6PXuB(yzCf9xo1OxPcxh6BXST22cJPtJINnsgitiZsRSU2R)GnTgWEMEz2QfRuo8LJWnfu6TyjtHV1LRukFGYQ0unfJK0fSzFwDq0(Ze7xOpV6ivkQ(uE8T5tbAKQV0IV4K8u6fJSA6i8sFTRX5e86AQz53T4nKF7c0iVdh4xnNvKWKDROxA9RMyBTweaDdKNpP4x((mYw8CLSH4SCbtG6gL85PICxmYx3OzjuBGgMn9kTak7(4xRM8637zfKdBu)mQd09lBGgDFdb40bl(iRZifhJmzjWbScnAa1VYU3s(TZaMoisW2COKpnCDws8YywOwRYRETjE1oGoUmMV0f59wnvRf0rNaCTlqYkjvz1vt5UWQb2woaTLzlZ1tSf5vg4(1veSABOwhmEG2VrxNslwgWNNYV9MHlwq7UOWF7TknJq7CP(4RebRj0Ms9syPigei)4LQOR8aimbU46GPv7fkkNcXwVKuMoHmW03sEu5WqlNzJkPYJVDK8mhkrenJMYR0s(OuRiKbpNZcBfBcT7vP7mSNW9elHW0tVLqYr1xvs4jppKR8BmPvoknFNFJ6R5tZFiEhTnrhY7CU82KlYQUQOi6KYBSW8pxuNBy9OZ)wPgNJGYP1pzvjGYKOvYN))SauLG3rR37ywvrA18WmAE2kQqhszWToBiAEHGNv6ZXRSo9aYcm90ZgnPOoRWCOcXqrv)HLXNp9(7arW50fOcya)XAwplMwmLwSf7h2ynisUrLIlOjyfkg07bEuGZuwRpUO3iNhVoIEFXVpEbUCZzTqHUKiA9Jc(FBXIfeT)8NIibTOg9qk2IuFaZbrwrdmRavfLoiQ8nyBrowqJ2eUBpTmjvCT1bmUg5z6SkSjaWQaKTI96QSlwSIyX(TuyEQ3Ol8gE5WRSu3caR)38bFF)lOPdYfMwRog(hLBqVsHgOMI3rTcXkxu6owCs7rd2O)FyCz04PHfgkwligx2hpmNeXzk(10D)CxWwqIyvuYQ3lu76A(1kxyvgn)PfvIKBavVKImPaZ6ICas0TsuYaiGeMNSmiJpl)7SsgHyRxoR3Hl2dS7HuSpHVHk2m6XiCZlDCzDH67qafw0yJlABXi3iB7sXoREHowK7BvpVgTKFZoV6GA2)mDYaRP5)axTG3ehgLtYipgW75oLzvkTV3BO0XulNdEs4M5BeSnVRO7rFdR7rljRuyJiQzndLrtNhiRHsmgWjlQwH1WPXIwxeRfuJn6l0kW9y)LgN)49ofCLebs4ort)g)VuO(hKT0wIDfOZTY2zIfwu6qXEl4HZtvAR9q3ylYnsp5QQNpc3sLQ5tcqPZX9Jt5xEGtFjd))NBJVdn7QO0cgTIWSxXHi5q1CWvwYOF4AfTA)X1Qr7G3YMNhMbEeHRNV7M)nRefcapPodY)KsmDKiCeyVPeTZUXAsMLZnKDt1JuO27vVujuOcz7zyQr3vui6rDovJ75hzkgk5lt1BqQpn7iEbAShT6pg)hernJKDLJboo6DoUWy7WSl5v0rugb73qbAG6c0o(hIZXcQOyYxSEf0dxS5gVb6OKsxo)0pExFWgpkZpzhqQVHfPZ669pNUayOuEuwVJmvFpMf8xgIhuMdgqnB0NQd6lyynhnA5mr5mFRueSQHI)10r6RBpDA7Pscj9rGBP28rIP5imElwjE)1cTbO)yXlr9dyjdgGevBcA1zEkw4HF)pUSq5bAJ9TunoO5tSphn2(C06tSOeJVwovIbQj6wC2smtzSuxLmh6nh4vNg86l8U6uqF88Bt3SphShKSD81ZFzwKFt31NrdT(PhdYBb3PRwk3kxNYW7pQti1YzMydH5sMqBQ2z(uEV3qRbz84nvEyBk2QGCBmduq)PPm8prR(2y8JagT1HFaJffnarO7nLmEC2n6xBYMMZQE1n7c3MCwfzzr4vUGdwqH6ZMf7G7lqn9cjEpxA5FrrjpN5mESGbKww2dbbHH0OrUbdej)xFGvX3PcdZ4bxijDZDyKXb)elCjCn2eUPAtyCUurRmExmAo4HvWCfpHqzJPr)HnpPf9EuDkFezEFYqShczUGYQe8O0yl87T4(YxQo0yPJ2vDPgkSZdSuenBWUa5ZGqsxSXxUMXFBkQk3O9b2pl3zJBW5tB8EMnvtJxRqUxrCeYsZZJr0)zwoyl4luteG2ywy9Yl9o(KJ0IYSULGdpRcjvee95YvmTheIAzLWHR9VfDWhoyYSj7BuBpFNY9(RC6w3S1gXYmrqj536Gfhffjjb8u2lC2ORSTDqgprCqZUWXzrd0UD9wC20fm190LE2OHMrAZ33sNqC5WJkp179b6i4Rmp2YFhoSUD)mBe79oXe(lxyQ5Za1RQ2xOB)6kjQnt5wf(dfcH5dqQHqv85dbWCCyC36ndtp0(TUtw()T31EVTXXr8plcfqHSM1HuVQnQOaSDDrBrDJrCbY)ff(4K4HqXtLpSIac0N9UZm77D2h3jAhfxd)p0uh3B3zNDE(BMnHyXossSKnwGAylduzVIkYgSPmbRQBMqKviDbI9JkkpSegsgFbJnY32CdzA7M)7UQkithtqmfTD9eXhNsqmcDZAL4lTVIRUREL4ddGmNVSAJWMzkXl4tVc8KBjI9K1O7yk3TiLegiPSO5oWk7vq223T6A4oTATkVTkxf3WVK5WFnRmHqgP0nmZGYIo3B9rbXBPbhY5NcuOUG42VZ(w(uJzzw0I3WlASeQ06pNz6AMWwnSmVLSE6gId2Wg0IzyEMlmZZ8ikuMIha(bKrvqhwH8Ovsq3HC7F4dec7(p)ae3GRRwnxCEsmjPykChYGcmWV9Jnwodc)siwTFleVx6aIDMbbplH49sF67BEpeDcXNGkQCZcSjIUdVs8(MpIUVwHOjd(kvykSwDo9fwh7FTWHNdgkDqONJPXrA1(GhxrSdWP0kDPU9ZOfgP9GN3Y1P3Q3xcJk2mmKJb6BOpmhT4ErdERcc3TG3VDbTVUCtvmcNVRdDWOI0Y1JPglMRGjqgD0vqRsac(ItKfm7cDj8nvuMq1gy(Yttmwmh)ndO8pQsVVnrCHtJNI7Vyu52lw68ITNjKW1pDThYjlYBL5hTycCwxl0qRgSL1ZwKyacmBI)yBEIRSspIYadX7k7Gy1)RIpmXTGnLnrjE58P)HGT7PpR3OCzEjyaZ098Xr(S9CBQpZwRTKqfEXWOzJeNneAdFZBuHdxgmBmQ0u2bXmmEF12bg4ft0vu3eilbLzEZUvZizHkB10k9qvw)DfMYvA6kGROa12hg(9wMj7892wjhlcaS9AaG1ZO9ka)6PoOJu))TyKMGiShiV3I5TLUkvKKuv(BvauZKKw0CdmHegqII5OykI1pKYI64XDpJfbBITneXMJe7fMl9LdIOZpr0h6XR0VBE30pftVRaX2BrrQZt(XHEVo68cHsy(CVZE2rXA1(C2Cg54N68mW0OmUKaClc20D3C7dC1gs(fK9PahVedp5W76qpLY9Z7DeigEyqJMVVmUwT7CFk2h3TRsM2TL7L1hXI1LWfZ92ZggVzLyx71JSQF2dJC0ofTKnqvpvNS(CRPJDRkKgVV5DXdPHQqEEnj9wfFcop3yetRVYWNTOrM(q7VsEPqG(qunx6RO4plvylNAGgfDuvI(oHFQUQgLp8REN(wAFaHjDvboG54wyKzkDfmHh4G2vc85JMHobk22o6EptGJq8sAVV2OiKyTqMf(PvvRuw9eSPzfmk7ITQEBX8b69dHcBhN3Bh9KtmsQOTSxix5o(OTFp8(HqfwXt1(8KTJlCXqspwLDuqSZtUbZfkJIO47HMgH0ybhx96kBtIgGESVsIleOE4ayYjura7LyUDKfchUVd2Mj2NGdGiC6OqnovibgdFtdwKBYA4fQ8cPfyy4bGxqrwDLARpuHucZmnxzF9oziVgZoQ0kUPDrcNZHrTsmSBkSqx6pIdjs7k(PnleQ6MlRIgdif115s1k5fHJcVJVvJRkFewmFDZT3I7cAi4qMvt8s4zx8tAe)y2xxSwwswgEcKhRn7yXpQ6TfkpP6aCw7GIAIPvazAIekEaLcPpKWMzbICmI)bsJsKgqneh83AITOMurbdR1R3aZ5IeEKuISacrc2LCtjB)gtPQHrZefmhR(hczKc8gTVJF7Nvn1fUsDzd6UkopdewRU8(lX)3LC(6EPuJCu8Jdxnp6C1bHNuAYkBSvDU5d9I9E)(99JyG0j5bE10gQ(dcCaH4PztGaAqhHOIfwm1RWczCge(51qsGGyj0QDpE0m0oZ(X1Zh2oz9wDj2atBWqhAQ)kvmYTmaOvZYWxofBI0rTn2wd3UBjHeu(tY05vsKT38JTBx2jCQRJk7OurL1jA4r8liIuJ23EoYUKSsxdyD)Qn7UvO0cld(zqVcsDJ58xC00yWqpwK7u4DMUU5NvwyaHKTgF1syNEt1wVshukpBSZRbOjsrhMJMYJ)I5VfoUGiFlpPUeeRdtlYmi0uetIyP3VPGaeNKVgmyzH4aV8HfVkdPsoV83P02ym(yR76jEOL3HCCC(OH9zm7tgRrLSFkEeQozakdcSfy0zMaAUa76kOxsWQCgDREzzBivP2lRUAlr0uQ9asSgKUWogDeNuJEfcyWNZrLyKiyI7foRuQUOEcbSstKUHrNDOx)EY9opLmB2(EfZYymUTdlHh6Odjfe(w5vAkuCTY70uLTdG50v3PDMrT6aHMir5Uj101pOHWcRjll12qYC1D)bSrMuibm(D4V62K0Ysj)hXaLHZEXHhOonf8uZR3a0S5CtPcJ(IVXDE3MGqfC0TrVKWnVxqUNW)qhFbpk8krKFneev0FlNYwPuXNAc26eT1fCXyONYuC)r4IrJgYqE63MXWBLYWXyhNBd9MnQAAAUFjtNHa6Iv6V8jE2uH8r5JHz3pBPLWSxqRungq4GgBDVi9RfNR0y07p4gjDMrEFzTjv)ZqS0T2CippED7kZSz9A3kpmrJ9iS(EqIKjbfOw7x9(N99F37vHVbSl71WLD)sSEBOYcARUODocCmyd5YYmE1cr85LXo7cYfqbEk79Ll8AiwNLkAcUoGkNYppS6pMQOiy(iCOPyydQLUifNgAt4k60tsJ(TNphg52j(c4sep9bTlgDuFxxL9PENgnlsxaE435ZF8NKyPbbo48OxW73jDlo(xyJB24LQmGdDfJXNMP6z1Dol4gN)rrxctPQQZzj9aHkVlS1rTDt1YROZmc7mvXuCIW5Hvpy15oSbZCPsfD4ho)0HX0DGR2oRrpL6tzOfIkNoAmhsjlm)7R00gm(403YZHoozT3oVPwhU(x18wn0G3iOKvKFr33St54pUTR9jv55P2zYnvar2mgg8YO67xQNqRTs)BVQz36Tlkt5tXuMJ6aLX3xrccb1ZO8qQOhZnX7t5YUGGbyVwN(l1s0jNAEjhtgVAvQzi)3VrgvAiNAnWdtZq2OOiOpGhPdee2XdF(WtAf5zehMiHjwBjBdwwdS4ZhF0PHoBhqa9ObQq6Bs6Hqm2wminn2zbw1BCTD9gXkMpd3DfXzNIvtNwVYPKMW2VqUEl4cyNJbm6SYP5a3Iz2NOzqSM1v7FF))0rUEf8KADeUn88K8vJCocUxfIwWdwIwn9HQy6rfoexWRYavISZ8Zl4b9ahb6dauWEwmttR2EhMHe3YNzdXeTBfAUZR)xKnonaqgXsAcza97uI1ZRWyMx0ouPElfXhICoK71XlcCYYqqGBHfD)JqHIgOQ)HJo(DCN8g2e1EPJJzB3OHfvCANIv7gNzEPmVRKuAX5IQt4LPehkn0H8)xOgdUItWMjSuEe58OeinUi5ybL3qTXsnymLbDARryWoLv226MB)wS9lq54(XYwfjV0UUuZxivCuOoc(IOCL0Fbh9lvex9RjWF(NeBjUGjJILaAfT6LGIfbzjRQ3wt5tt)cHpCfFrkfx8krJ8r1eetHo5NcCDuukzVpC9rfDpxkUjyQjTtHeaJ53AALSVWqwaIfsPkXwoWpt4T3SFgtb5UAWesnio0fhjGM3R2kR9S7L0vaLViOEVxUNPDPjaMVg6CoqPvmfL)OIR(C3uFf472)yLYM26T7OE95at69R3yx8wZvfUf2WmbtMfogVwBvZJuWysJ9CCrWrAj78xFEccoPlF)pTU66jRNtAEaEcFNqlxYxRfhv8s0OWKXNfaOfsxwi6FDinWZZhKPgzJ9xTYWP8ovYjl0K9UXU2U1)xcPXoQcOZhDMg8sAGxy)5lVEzZ0jlTrGX(NHmE0i5ER8Gzye5O(3zuir14RelGUstRLAsNSuIYqsp5Mga9OeeNCUO(YOCIzb31yOjwc)nmYuY4lEtA7tLf7fIVlxWJugJXbrctnAmTM2E8W(fZL8hWl(IRKqmaxelPc3xiiaRwfQv5J2ImGGtlveu3aTkE0FyoibJh(ii940kaG5Wk4E3lSBamJAa7UwSGSgxHykwYGG0qtp5ugTLSuttL0Y(xn94tZFMWS04pz1GRgtupIAVTW6wH5hy1)id)JbzGq)Ypzi3J7NLfFaeY8BclalMhAtqZVi04f09ZK5KGzGLpMFv069R3dv)AuS81YQHK8W8fNWmYjsLoB92uYgipz(HVwjoovIZxRaNs2)ZxbopDR8MplvCJQV((ABhq2gu1f3XuGPksDQ68oxPdWsB5KJcTqMu3KmfTsuCcMtJFQwxTk0LjkjI8veXxReI9BLqucDnyoA76sHDGGU(M(muNbFkQVG9sDf8BB9eKPocup26MT4uR7G8Vv92rlopNVNl7ovQAvK1pq(IiyYumVoOVXvORK)t)vkRyWw2ioJidKhIWXTt54eGskkxkFtFms(ychfNU4xHuNw0XctUQtEp8Kyf3gWc)O6SN)EHG0LYxPiC9(Lb)shrSxQfF37kOLs0k1u4sEqR6JMxVcN2vBt5s107Yyfy617tESfuWChhpUe394CAnNZyPMBFoSJUxULqjgsBDimGckhg4rCBoapvT(wyPYBe7h7GORt(U9l3kmlbIoWTnBHw8au5AWidPvAI8Ecfdf8YgQZZQFkQoKlCloyHBJ(b1K4s9O)802bvYihHwgHQTp4uym1VBt9WVpR)po5av5Q(21Yu(pfVfCHK4Ij7sXI8GP3MHDjnQfvjw63OrX29FJNrQI9Q61fFYU8vOjep9IS8)JLSf8mzRWn9EXQkiH1xcDtJksczV1vxjoDVaKWd3fk1ZGBKMU2Jp4vHL(ctjfjDF4HO1OUz3TvRv5Kq)tzR7ytjkBNAICQAcVY9Jn1V4yKJ9VICEZ8Zk4vtOAchDKIYgR41xTgIwRmzulGDTMLwLDTDRlr2mAqaMPy6lZ4My3awPjxDJDXvhNyZoW)bQ4oScCL1(YWKD4KIwSFrSwp)4HX4LqugAALnLru(91QVvb1WauZxqgfeaZzfY5VgIjJSxmOSzWgSZ6W(ALdMYiVCQNteFAKw0nIEV4uTF9xJfb49fDXoC4TGWSVcW9thkwAYKD6OEqEPBshzrJp3zDTAIuu1vwF5u0IODPvtxKtrDMQBvElijrwNairOgZahANdGUIvy(xK4rkAHgaEcPROodc428Gv7Shl)bxuEOLCcM7Ta7a(GouPFvAldT2QBUrm6ZX88BLmhCsPQAUc3PIJ)O4wqm2R3EaL2G73CHS9465YyQ5Kd426WSQv4ER9tpp0Uy9aoHUpPkSc2sSHmZhN0qxL76tlWBaBDi)z3NkWU10pKdPoYJUlDBa3QwZcryX(U7GlNsoe6ccDEb3sz5cBCUr4KWzzIgY(zLeW)XV8WqZhSDopXEzNKcY86uUGF0Wdpqk)LbhnXNu(1Ch7pMAcoJo(rmiQ554rVSasBWlk4Sve1w5h6206xC6fnYzcBvtJ8mJhDCoMu(aaMDKpEybT7c3TenHQSEpYNto1t0CQ5C2pcxwjBYViBcuEz3SeXVIbo7pXDZnCKZn3G76WogqEd2lJoypkdVkjaDDmQS(uJsw0bdjf4RmkkJUBnm3H4tJYrzmUcpN11lJ6ce7id5kRNMhDkNFOfkpti2zuuwTIoixiIo7WiNMOfTvS)JBf)7h)F)]] )


end