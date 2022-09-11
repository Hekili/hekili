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


    spec:RegisterPack( "Arcane", 20220911, [[Hekili:S3ZAZTTrs(BXF4SP21lTeLKJZEwUkhV(UDtLhUIYw5Q6QtuGGdfrmiap8qYAlx83(nDppWmdMxaKkX(I)WM1IeCqpD3t)U75QtU6NV6YLjnKR(HzhpB2XF9jNm9KtoE2XND1Ln3VLC1LBtsFFYn0)rrYg6)91vPjf4hFFEzYs4Nxx2wLs)O1nnBR)Rp7z3K1SUDX00YnpRoBtBEstwzrAvYQg4VtF2vxUOnlV5FuC1c7V7tOR5ws6v)WZNrx1SLljShLuNE1LFpfy2Dndm29Txs22q2SGuT76to5P7UgwODF7UV9nRtkUHu)x39T)LDx)pRP)c6UjlnjF31xMT5n7UM(9lZZkUz31LR2DDk9pli0VmROHuv1Ufaz4VQBijlzpZtOVXus(8Ku4lFYuCPzVNDxNGWZ8SIvzfzn3tFDLYpCDs1MYc6NnjRz31fKBbO9osb9pYZUf(X1Mp7rSv)VrFp0N6T3wMsrta8q35)4B3D9V2wt)8fK0KwyVDFz7tQO))LTnmyTIdvfuyVOK(HT14ELJ2U(TFyBEznDBWEpVEjBb3wLvwjbFCPf)I3vEhP6juaLSAfHIba4oTSmFz5DuGArsnbqt0)5B(B)K4HQN2H(RBQYsXxrzkPMbnWlPISSnL(9V5D)t6hKTH(px2s4aaLMapCsffIE97(UDxVQS698v97lVfEL3MuLLSiNu)mkXnLZSvZ(9FxBYUR3uUSnN44Ln9QlZZQBQb24Btkj0))FapsqkGfD5vFZvxMsXie6lHEGabVxU76V6QlzCbxDzvlLQvUA(wa)CvdLvEq)CozVSAb8BpDm)wIGwcRWzgRG4z3uwwKN1mNsHR3OUWBRi3o)M0Ltpz6MSQQYQAy30uwTbzqFmLRD31pIsr)FBZ2ULSCAZAY8vzv1nZRZUjJEK5JFSJtW8BNwr2KKb0JJecq0HekiFUZnD3Qw2MUgHl6YVj5MSU19LxGqiBFoLGNuW)1hiPTnK5me3FMkE4ukqGBi5YYrGiPBmR4z42sGILpjSPEEak5R2D9Z1bMa7XVgF6fTRwnToB76YI51arAA7wfICpciakFLtqbxnosGkbS6gY06gQ4(DxFb)vP)LBs(WC(dyfwKa8RabX4dr5CwsWNSpWPb72yMFHti33AIVx55LtoT37yrEsnIz(6rS(D7rko6KVosAOBy4KJJI8W4rzcBJ6nY4A05zdZ7tjCuaYTWTtcjCeXkNgZRYe86ER92t4BoKCvkOFkJNtrKM(giWBWT0xLvS)p1K02HSmfg)B0jVZmo51Nhbil(p6DY(lv(f6CbAKcNY2gnojbTjzoPGSjJuJh9Pcy)lOO8t2D9FIAbcPz(IYI26PnzKQzVy(STPAcW7D0SNq81uy(QlPMNssQYVFo(3ZZwXPNP5eyjQBOg3mNBrjIQFSoW9YNRIoTa4FDuaoUTDsI5YbD(9QCmCvD89)MmQ5zudQMA)0PXtHiQaQyurm0xmDL8VCUL77Lh54ye7as4o3L9xN4wJGuiZjhFa4wJ5meZ0lpN1PCkZoNz)v)NAqQkqP2Ny9Wqsvf49hyyBCAQ0rgV0pYWVqOzU12SFOFf55g7tFWdLRDvw9A40D5w651kBEl03Aq0V1QSTS)4xwtO0fQWWc0fic1xzWDq6)L6z6LuxOO)Xp)lupdj3qkwsDUHu)uWBr6)lbmihCJH6pi48h1zic)x(ZLnF)ZE97OpuwbLypL70f4Vj4CzDj4zg8V(PY3b((s)xGJQ1RrV2Ar)rFc4sh1VB4TGFed1vRI2NGGo8MP4uQJ3BlRsYNFxs12PCCaJFu7504lLpgtfLW9TPusY22885eyVDbk67iHqoXXaDvimoC4T5KC2ZIFRkHS51wiY4)yLeLzGi7CkMrlQ5UHBbZ(uPh3z)lcNSwIrhaIrW9nRzSi51enjrj5OHOABfv0AivUHfsAiFZW4tN0cVNS86EBhZYYS60ST5zfuN(NNwUzdf5PT7W3UTNA(QQYADNkOEIQOp3T5yDV(BOELs1SNLMrvAP9EPVIKPBHqyqvc81kQqWx78IYBtS5nRl9Ckgtydo4popCq9ragFVDPTIVvx43KUdu2PVUyoswEpEGcoY51UJJ87bCAzXY2SMP3KTQr8BZZsx3HSwssAwVOSQG43bw)Yy84hJBlmCE4HU7Dz2GBRg8TAbmJyOAoJXJYoF0ohJGHBtmpZW2y7HwON7GYh3v4MmI(XdDSLyEnANnqbUT59NZdU20dakItAaHeFac1jL(uZce7BEdx8pObFDYTemGUTy0s)(YFE313tAEkpuRj8Fktjpijf1ySPTiLPjOTGca1kwpG6()7IWllmz4(imaVJ5t77mSHs77mTGLcDulsMca567R0LCynWjcEEv1(GjeuIbzzNkB)sGc4y9JIWafjFxitu4wY4ZgL9ZtGJqExngQFGcbj553Z4y2MKrXSBlHVJZLCh1IriA4pfw8gMnE3LLtpSacaO)3s0OHIY2BwJbmN(CLWpbzwq7)qgYoRfRDXz5WE0UZgmalq8cgNPBUug03P8d2lQkzzgLJEE92KQ3hJFTUcPbY18Cuc7mu8AigTWcAnvyznMtE90WHScHWhGDq4sb4nbti0Y2nBrbtRArEsKVfGyjYRdLe4mTfmgpgftunUIH8M1PF6yedkf38(7PVLcHZbsFFhJuSJc4YFmBOXDU3Q91wIgUpVVfpADjL0qAWGov1UOVW)bFIO3xRDWqkwu5b6oIkeWhbhptLDpWpc)()uDhjijwdV8m3bWECHxEMllwOlxnPifrrBOs4nKlGrg4DL8t41)VTec49jCOI8HMQKUC((nmnklBR6KGyePblQoK5yoDD50DxdwiP(runw0NM5elzjp2g0VMBxeh0aTCq2U9)oHFQmJ98h(1FVmD(pfI8bAFgOESob8wN63HH9cC)P5Oxca1QMkS)ryvpHIQMRBKtX)exSGjbSNqRzUsZBaspqlq076KAeHVGqkeMJ2JmlW3pvIcBfbvksohjfKA2HA4PCfjpn1cEvXE4rPUnGzzzJUadTOjFUMdXAp38BBZlivjlYOoLiDsN(Bo2T3BZmTVXHkbdD9e14dUj590)UUf0Ll87OZKqqxl3WqK2qz(ZGNSJ(8umauq9VScFMkcu4hu9NapadVYWaS6NPaPVWr9g45OUGDpWz10Gb2ecvzBvb7F9VivLC7pXODbVGOS5CQvVQTfGIh33AIZoooRj2BL6X7wrG4EAQYXTNmApgh2mIAeYwzAkBuSvFJq9z9AQAArTeTGiezK0i5H4fjfWebe13kIBktCpN2aXDEzv52Ti9MhfuH7lmUwu6c(Vahzm4GwxXyHv4(aAD8ItmyyuKMqv)Q76zxHFOgM4a2HhjAmj)UK7Rzyse)XexM2tOzNkpa1jekdylQ8SMU4)lrLyuMdyWKteIVi8AfzflZxpBShBIuNyJ8(Xpo5rCL4q0Z52QZFwZT(h)OvkmL98OJostQFa9(bmBqeI1odjvmuf4AuZ5R65(W2tCaYy7PU8MW8zDgTlEyFOQkY2SHqv61qaX(OfcqqVUd9(mnbIRh7mmk74okvLWQcqihuvLBW4GPlD3sKLgPtE4E10BcTT0LnjvD1hja5GbKmO)1ICL1zMuSHwlCcwSNulG5s6uBpXyhPE0Xh51TVgUvWbhSLQLAkB2mhqJYKaAp03N6oNoE2DA5sXs64LwdDQldDvYlN0bauaIyPF1fV4CTVtWLAKYfNou6ucjcxNRgxztH)DWlM04QYggO6jDXE1FGESre2lXpaMdAfa9Rm75qBQeCDqohXqsVaRiyudkO0ER6o3EzLem0UEul4UAZ85D0URpv7aHvMZx5H3uvCSo0PkqU7NtHU5TuJEZNNS1XkVKKNC)CQEn8ryoi4KrNz1ND0jWT)iBO0JcJGeMZUFiMbwgEggqRU8jBbxNY20cVKIK5BvtJGTJqElNe3co(0gFgKrBuNu2lUtpyz3zk5tBSmd68JR1soOdKDa8h1xeXM6HIc4jUcrhYGlIk(c98f1Lf(2nWOVf(Xv9nr5SGxuK7u6iX8q)PmhmaZiKTrGw0Jtxey7xg1dRfajNgWeids9clvOGkg671W8HcpMBWUx9r8fh2C6W2KyihX5ZMHmTEChYLJ9yMbXYRpbM(GhNhFVPSOUDJimdKpSLANjGW2w2aXne6NoyRdXNaKek9ZlVeSzv5Pqp(I17j87eVS5YvbsrwJLcCX5wXwnw579AvMPMlz29N5Wr)z5KmGxcJFd2)7I2n6EnGHgFYR5r0QPI38GlskEpZFAmsZwQksS6fyjyMIV2iJ289pXW1fkJqwfz8BrZSgmXdE4pflDcJOmKZoSKFI1XCp9yYeiMERON4xdFP0gSMS03JHM4qeFAxge4tJc6YRCpvqG8bmhIhnHxUzJPlxgvSg8uJjY1IY0uNTepIQ4mSMlnyhNOeZH62TKkr5BgU8sYjm0tfHYuyjuQ9m01tdO1RatIkCa)n8mJ0AzwmbONZsG4cVGGbgGfvyQWBsfK7hwmcaGUEDjgbAiCbe9G0ZtWd8NcC3v6PknuMnunJ2jLy)yH11It5mS77LY3BnY1gSdgToI1y)7PTu(dlEHf(glPZSZ4(EfyZy5XPWSsYKg2P)ppXTpEizue3foAuiWC1xiIJvaRNStpKj23mvw3ancdRGfTMnRYv8pSl9YUurmM01TFe2j(X)aAnu(Tey1rfy39hRQKJWiI9UFtaS8J(0gN7QPDgho3pIwTGyyYJGmvdIJ4ZxdaSy1MlstaJEF978ZQ7dZh2WSbfkG9M2Hi8a1iVJAtbZLgIeBG1KJ2YkKHbvFELGfCc7z2WZWn4DBjq0ahWLLSQS4(0BXT7lBnl5fPEeWDI1yxXbw6iDNptkKsWCuUHU6lzZadzTYYakr3kyvd0qlv0xDHSqMuJVWFrj(cMF3R0k8CJWvGKj3wKpA4mq3Omca1K5rVZpTMFn0SzTSR1VCPI0QGRSKjXgrzY4ITw9ndfzHCX8KypLUdt)yX7u68pE2NznFgLld7(mH4KKTQTZj7ZaxMOhjGJk3LvtMA3yu3nZwGKc1nlf2)q971vpXpFsOy9)4WH63Av84C)fmM(YqmhmpehY3xezRteA(azLCFyduiSD7EsrE2nRBOhVx2Rfz89iAw(cY7(QJ3P1BVtcWM1He3)EVVJSgZR8cXqfW7BuD74ttUowWxAvTk(WBot7O2bBGw5ghG15wFCJ(t0t32k3CEs30ynWH9erKYrtQ1xKhDWEFdsEKox7IY8OB76FZyAZQiwBw9oiUBtO184U6RBl9RLHEESf(WE9u06Ec)hGQLMczOUFWAEWgwEht01vFDvBl7NdoI8uH7jWJvJYCzUkc9V1WJzxmhU4ZPh2CP5uFnnCmmGyejooQLZFcIJy3HCdgZmTpd22(4W8My5WrdBcWQ1MVasP4TLWitmNmVUm)wMoCfv7YhBBBDde6BcF2yQ6kE3jMCs9ACqFAlhYINsPFoTNdj05o1gWsXoy4SbZ4xJYk)oso0VpQT(a4Sx3Xe58sH(RnBbOi4IILz5KZJMr452sl7GyTveGPuqKwq02YAA3B6lMbgWbNF3m)ZGe6Yjt9ox2sXJYlAMm5PhmslGEESorXu(SK)P3vYBnmMsjm9TYEXadfdgQemVNOndSJDOwmZEokbdFcEgS5o5eXvjGm8i(Gnsccy3X7mn2aPfu8zV1F8ZHiXUu5M622WElHpH6Drs2kyAdAj2Kimu0SEahAHT1d(eL1MihYEbYqjw(vyxSh2q9aS)29oWALfmu2AH(brD7VTSUodqmpi6lIHfShj1lgoSljHuNG8z9gqT8kzOpCARMtC7Bz4xEV96Kp9uAOjW1UiHhEfk)ohxbnR16pUlC1Sf(gXat2Jeu2UnS0N9)SXfpuf4UVryGNAvjeUAagBozxmJP6t1i7AX72t5UmS2dXtSFIDZCWNvXUDrAy7TXopHDxVid79pqg8qGLBpog5COWTJftgFpg8hA5kEjGEMok7b(EFWubncoKXSwXLJUHmcH)Eq6KR9b)ftqDhQpbpqn7siC7dsxD5r5sKgCP5TuPDdaJmC3re48qg253uYWIE6cbsK7DV6jJPCb8Nc961zRqRF6wtxHlpMzt0wOPWDnHzswOmHekOFyhsqz8LigqqIwJOb9lKnzseZ5grSiqGw5wNznuGpScMDDBXnqzFWnvUlokADYqqXF95FJze3ilV8a15WbOaHISO3FS(PugY1dTTXYChjn2AuliAr)aGrVbf9PJHVNWe8SkPnVrw3hINoTSfA486TK8CZcvXNGXODbgea9IJnn1G(Hp)C7PimYL8C9moagPCdzJ)uoBJRwbXjhnKXK)p3Z3g8Tq(W6K2AK62nZa9g1A0WWYAgbEfGcMRjfhgjqQtSnqni8UTLQpFB5Oc9vK9wbsPQN)RTlVrKLNaDJWdgOSi5g8BRYsFFT)0n5Nnyb90aPccoSTucf9QKxwUC(Q2Q79NYe)RcKqxCLcKoe)RcCjWv3a8QPj0t52clFSlvBnzo9j3uBnkO8GlKMWY93QQe6IwqFVWvP2kf38C)i2IRN4xDtoOuRbYS4IKL30V)Q6PWkcdKWrl95(50ama7(HBoBl2ds8flkNtw6ETdzy7OePJnsvfkpotg7d4CR2z5g4A73xjwSyGHDpKXEA5y8(uv8rF73b8aa6gxWnDEgxsTTalk45OUtDV)FaXVUMYEu9q3tvHKpVSAzbCuFibc)I(P)ne705cqS)l2wiSKhERY2mNKMNTTEOq4xnia8ReWN2B0F0TIqgbC7WXD6tnkjLfqp(lPAvv03As98vj3wwzn2vDwSKMSOImVEnHYkTPTolDaqeSrpxHVtcs6x3lI2(gaCTdaD8zwadBri7qd2bay72eeJX2SymZlzLZJBwwRiGG3Cy(roUsQD96e6MNSeAOkKbvuEvkEEHVLlWuLWn9nQQFzsaHLoM2Na6ywSIvhMGGoZ3JyPNXEstZAd(BpsHv1f21waY0Cr)8PpNLmv0dCQRoarx2Mmx2LlKDx)tTlUh78)FfUXyZjotyIU3qUco1FwnHh6KOEd9vBt4tTFVs7i4(hxqsRkZPsKf)E(pougvF5oERUavHydinF31pJsKbuNubNCBcLkb7e7sLSi2N9S7KhN8kUTH1o8Xp)z(6HS4R20Z2g72UmvSG0c27wFFrcv6pvt(AynRmiBoJYrmNbEf3LS(Pr1Vse)gAQWV7ApylayI99sWzsSmqVLuxtYhGS5Gk5uvMmriV8crEHdlqpOyyXgV3MWx45Uj)(TismPUoBtwoVIY(mCBBFNylsAst)wuwahlMFB2GmQ6tN9S(oWw03e71ksDjiEzoeERQBlZQ(SCdBzB04Fi9UMUhtBQPIoVHu0sLDsnoO6ZtQT7DtJLrURQG)5z3uaB3bUTpn82wvdV8T0yzEZAXVD1uEhcj84DHgNtMEDQxAmgUDsby86PhcNBxWCtYfx2)ZHljE2vfppMf4LfFJLHlB3gBqqacZpAVu9p8nHyp4o20rblRnM4Zdgo4laclUJ3SD7LcFYAyi219B18bVFmULqBSmhBJEB9BmORaYUdd(VXWK09neSIOHFPhnOM6XMz8)EHiLd9xaMJOznmG5t(9aM7GHRW0CTTIKcncF)eDjLc1qOUrK2RRSvF262nuiBo)NSkHAmwwI51V3PQ)I0YIFTTImxMhk9N9m1NL1DmZZ20RdT9KhNdv3V0bg6T(IV7(YXqlrNOyxAMc1ZvLlZUr)r6uUGnsd4RtQrSpm1j5lwSkwlAwYaU5NvTnW(1Lx3U1xt)PGzv7Lq3bDm8l(rX(UXN2xeTDQQXZGa1DsRo0qUvdQChvtZJs9U65CB6MBWwXRkLYnTHzYHLPLq3AoOnk3KvW))9ONq))dnYmE49lnZ8dEZm7Tmo(DG3ny)mRISha8P62QkUqRNOJzCem8HprhznMzqYxoY8P6rg5uRiMcaA0SjQe(j6rooY6b9ZJ(bkcw3WnlKts0EDR1hicooJyHX(DDV7Y(bMmDfpPXvIrl6AeMH2GjdFnJndrr6JGk(mq4UK5DYSEwSEtCZ3GccGTbH8l9o4ADfxzFz2lIy6zVF2D3Lv71ez1FZZBT823RM1FI9xjtqHVwVXMFfsxX8yEEChbJ90LjJL7ZmQxOto8PWT9)rS(VyqW9l(S2SahL1BeV(iwYiW1wuU7GK62YyZIflIZkH6dpBtDhBEC6RTMhbyTVSqXWZkTfioQJR99GV40W9M2oh3Ax0)ZLM5eZ9R2iWYFXIVyzPIXIVgpvtQp11DYXmkgQH0DfCM0(TRHxEASPx81C1(SDkcGY5aliEPRheH7r6d2btYFKVV4is78plbChI4qlVtQtKhT(d7jDpuJrxSUFry74ibgdUjFvJHNkHCVGxd3k0yk21vgIFrS3qf7HVwwQzLziKSAvBnKATKISnjZtstj5KkOPw0a2oRFyXtil1Wv(J8P3ZZKwypIbtuHkaRr5Jd4ESNjtWEaF4HGqW2SXzZS9TH3G8)LZKda2233xC0Zh(ZK(5x8o0dIuh1Fqvz(BcvtL5bjybUYYCaOdIyole67tBc2KGN9GXkbVru8xb()grK1iAiv2D9)yU10UYMyHiJxORoV6NuSHR)0VWZu16qJb00e4UTLSpGO6JZ8mZSEaGCVQtXkT2qnqGqnyoxdD7ruVAe)HDJ6sNFinlUt4Wdmu2hCCkn1tTDhZlnIRA5ojM9VDn1U2y8un2Xakt8zCgxwS8bMz(apoSGW(6K0b)yUnpoqyY(j3JFlB6PcSXL3X1UAG8t6DAa4kBZnElCACbvAJVqJ7MqFVMKe8z6D)lRODU3ffB)RxBfJgewmZ6xLu9kCawhJIY8mP6FlF55kkPFKfVOw0D5v19EG1I3uGRjj5nRLJPUt1h(l2MIpEQfChuHp722QurClJ6WL64L3rSkyHgVv2TFfBt6VfvVZVIBZ9yR7niZ9N3FJ1DJCEACJHLbzUQ33xCdSLEVVJhGLODwSHp)ykYARYN5cfpZ7mU8H8EBUdI6F1lFwGbpJdr1HrfMhGt2SnpBvMycZ6)q8lcDi2Ra)ZCRdmg1pdbqpZpGe3KVYWfRyjM2u)F2yUjTd6gPUDDgNo9bpnYUb6qvW2mDfURbBZH1uN04ymmYDjeQnvwvV6V9F7A5AyfivkyjeTA9MI6nDIMAd3Qt1a1ZuhBJMEWeF9JDLB)90UUdTvufAGDC6nmIAIxH3x5XlA3AnCTKHVUog65tXnp)ad8EuHuNsGFrFrqD3n8AnCLf)X0inNO1YvQ4fZhmoXADerpCpolYKyMYNVR8735CkFkVhwz3fVIr2zJ4M49zD3M0Dd7tk8vGpM4x)wWle2DaH6hXhFjOgdYYNYUVsOF9tA439qiObxQeYbnQZ3j8tLfbd)HFn9xt5SkkiWnmrDj8upbUkVQX7eLSgZRFOX770a8OzsmoS8NIWZh)Lusaspqlq07A(98YccmzwzxWz9iZkt0vokSvCpOgjNJKc(tLVtHao1pFF8JgPdjk1ZiETSXvW96Iwz8U)t)nwUY(LcECvCVM2oy9Y7sETANiooqGR4hyabHOFCq8kpP2OEPl)3zMHQCHlhpvYMYLD8HfBug9I7CpdoI9AN3yCvTV34bDMYd3v7EuyPEkML9ea10CQfy4F3vtHQwSpNlxeHShpXgn9JFCYJ4cePQwRWpMSK)SM77p(rPQwJba8rhDK2jOaYqdicweOAJlXA7U5CHIJ8HLn)QOg(YEDvXtDb03Njd)g0(oD3gCBhPnyW1yCZ8zT2cj(CTlG3)kuN(NkaYJDbhSBp5aoBA3gYlSL(AEk0CzbPNCe7b018g4elb1r6F0Gl3xXs)QlEX5XuhVwGsDPl9nCS5kh3J7oUp15YAS5UPLTtpZkYb5Qq)uWMD74nlNG3PEh7IUR72wLAsXnWfs3AQWc(dtxC7UIbu8tnMYi(gVGXxFeUejZA3cR3W3A77FHa3yEfc7HymORf6pwr9p9EQbW)mODbTCcugDYZ5pj9fTMayf0CyazKYNfnRkR46KGWybkIw1WWT4hYfIVtC79r)i(XBMbxRWjz9uJOKjrD4lFUekXq0Q2(s9Jy26(Tg2ZfiBtPVMJ0aMDq6ZAh4vgGsEKQGkpY9CnZ86j2tNUTMz1lYm(w(OFD31)iF2VkVFFP8XRi3jnUvSAG9di2(UKm2OwSJIb4nfBqOOSQgfRqWHgPkLroKD7nbAzkg7gKN6SU9EC9aY(CwF38iP2T(p)YSAPrfJ5QhZPfH9g(HWb4to2xP1nMkKxYbbdVE0kfHOnDm1GsADyfECpp65LXmXjhBZ(r)7(iMPoFIThz5asY7AUPeLnG1zMsvsbplmN3VeBmxjDUAEtWzhdBTKDCVEwXloyDnZorVObgXegcUrvHj12sLewhbzWwgn)JmQ3AHA4oYOJRMkCh7ZypqgzTaPBud8jQ3guxiRJTj8XHJ)Hqep3xD6FTpiIgsj94wkGVA)kMHwJDey4l7V(DxH7KJ49WNkMAnfBa8PG)eb41CED56nkfymxNH36Z8Wmi31GjBV(D)5F6hFN4kscUNO)g4MYihVfMzxw0nYRYzk()nVPgNSZPPuyik3MIjrvdj2gw(cdZeb2xUDI(Ir0f9IIhdX0VwoWvzHaVaPRYwa1TZu6IAGrfIrb8H9vr5dYTmvWvCs2559Uz8zi5i8Q)uQmoez4CfFXTfoIxPg0KdQWMJSMPcFwrkrGpmOQd5wZJeq35ymGeWj(sGMTIYSlshICWPUxpixRHYA)XRblq6RjPnW6(Ql6D3KCWr590d4AYsBrXVfVbLbdMdBpL7ZoR4)bdRYAQj5RyIlOErHxi)GB7u3TlyzfrCtOBLCBWcdvJXX(1)BGdpa28DK1mmePctpXKBK511TDBXNnfGtdbpZir0BG)2pueobmxnmOxD8m(OLLkPuO8TYlTWAk5JWcUW9LTaVImHAYyXiIlKmup1eGQ2TgSTmW1r3dy8jepHueI83UQSTQz9OrQZgns1wiXTg5upbL5VZlZwwkJFAVelwVMEga22er2lPcGAWGjwQMVzrb1OgIg8YkYeNExueVrJnnh(MUlJ4XIXDBf8ia0XaeM0yTIRYtO(9ws3hEaXDMageEkIhoQQZmMR)1EcJ5UAhbmOxJcrS1EzupSwYZDNwKaZ1mpUkbxy3k50DbP5oSsf4af)GznZA92cuz838DmnWLTqnRaDVhEy(Ne)KlziVSLKK88dusD7zFFiZrfr1igFNqCOlRAu0yzb)r)yMQaiZYIQLbmQas2qxAyG6Jb(nX4b5lfkA9yVYj9lAy)5ETRWHdzHilBmbkoIXNMtBE4IVXrvucqcXGAtc1sJlhOGc6uiGMik0gMdM8sRznwDsKIY2BwJ1NtdrrtFjMvbqBvvj8tLQ71kANQYTpdOeSYCyaC4EQnbDNZDF1ehvicgzmjSFir8T4BBUa9Q9AnJwGZ7Ldp2L8jbTuVs2ybQaTDu8sqihKhwK1KbY3uEHW)aSgetDiln5gCg9QoQUOvmAR(vBjGHqN211gSpkaeCHwx32BtOzvdk)OxZYjO)bQBomfUliajwMix8EsxK7wTcJJ6Nw67bkWI2mWivowx5UpNUjtw1qywKEpNmTSDZwqsh4qhYci9lqkKjs50d6uL2Hvt7T8oH6BS0YF6hDkeMrN10Ifoq9tHiPXksZmmGAzL09u2)c24qbhr)V09EfyLo1h3kH8N(SSoKJh0GrDtfJljZJkKV238lultnTdLqJSCts1sMUAGdZWVW4i)XiuDyiPglDLOttSTylIfNXsQL(IXOYz9rwgU0HNLWtp9CxMf2LVVt3FeOPyoLmC0KPX8FovTionLswDsmZPCzyLDL0yXIOwHt3KxUijhwGMWD24O5WDhKvFoJ552TrPCK0RfmT5(yVgsmc7l(XoL5lyb3aiVMQoY4wHKKZdYlZgJ6sW8RvvGUi0vGyqG7vS8AS0bJA7N)dmWw8qHUXV3hipj1OgGXwRaY2l2Xh5n3bkEGPru5xLWU4unTCuBp)UQYv8kdc334Ezdy3xfei51zs7aFkqNOO4s4X2KqjKfLnMwmYkHoukr72TLqfeTMTIWNdqybmZbmDhEh0gfGDk6wlISwqdDjzWq0UYDual4xoia6TcgRvmLFN8Yzqb1GvtOYLzKNckShXDaUTH2ZRcm6NXuHh973itT26qo9Nsndb1L9dZoE2SJFXmk0CxsfKDake(lV(N(H)Xp8F(x3DnxwD2ggfcLd)ewp79eqzo1mWkWSg2z0K2MYnjy2rarY0d1t39TFxgOy8e6I9MYc6Rf)6N0fMW)RNWydu)iHlX0VAYjF4i5Qm7GSkNCMXYWtGKCne)TZf4RglCawe92F87mxVxCGxVVE0BWDFBaIV(v7ZVvmbZ8Wee)MJ97pD0qH6QyYdnUv58dYQCOzhnPtnux6EpPzAYI0PIGEjw4U0LUin4bTObmnc(4pUPl844dZYmEUyTLXKnCOSXZE(OHJzhKLXoZZSdSSSzpGYYe3GIpzVKIfpazx(Zq)97R2ltc0q)99ooU3lq0Si(1Aoy4y0SQhkTTowGXbhFQiFl4Xo4MnEyh56XYpyfsbbQLKvjT5nddUgJPiZo4gr03E2bJE4lKP5iJEHGtw)ZcUNDWsrDqBo1zNnIGDU76)BQtyvv3qD)PE(QKBlR(F(3bVdBQO(lk6BJdoVTbb7YSnVHsMVVObU9a(3yl031MaqWTzS44rn0fN1D0L6zhfy9glyDy4dMDySMC8weOVmhgP8J3EcDLUMmqXCu17cms4yFLUYxMrZ4z3kRtpmofDApg5)p27PT522gP)T4jtve9BvYok19zK8m9Px)q7DDUoj9U7BNcnfKetOe5rkzFUJg)B)2DbiiajajejDsM08PelsUyXIf7Ba7UTdm9dJ819dJ81DLrUrDpYUG9lpkTpLPsYc2PeTk(fBtUwcdZCr9d9UmuYV1esyi)bBqO1lyMNw9JeOUAKxJCrhTvvTXrgn)Y74mYSnuUdfvCPnovv337owmU3TNRFK(vEBKluKEzt0NH7De8R9Jk8QHhZbkR2(M2ZYRHh9dpBhcsNgyAd)MgvPnUrxlaA5ePmyCuLOUqT(HvRZ(Ilatx9tTV8ZPmyAfPTFy7RaMwHl9ZENkGPv4sfN3BEr2six7h74QaMwnR6h1qvatRWL(rzwfW0kCPFe2vbmTbx(sX1yDW0glk1aqxJt)ZLZ0hnE0p2J2z3OfGPFy8FvBmIRwa0s8OnQM5aOrhcfxtTx(S7uO6eQIzGhriKvn5OYHm1s4uMD54JMqf7SBbikVvUfGORBJRaGJhh6lRA7seEAKRxMk1p)89p)bd5yXIEs3xhXI(Xc9(r9x)O8QFSiUTgHQsB7hBq7hLOvcOYXYO09qP0vw1(k6h9dBwFjGTnKvna0g5qAaO9ARE6x(5n5NAmEhMZpV4OWSDO4AmrMOBI8)(TV4fp9UFLY0er(x8l4V8wwYo2M7WuUy84ZrI6vxHGfF2pYL6))X)RlE6Du2BS7XKWaS6iYppy4Dwer3FBm9eKjxG8wttOJwIB8YaSEEfnNJRV8sj45J3tIkIKS7ZYjc6ztaqaWKRAl7EeZFGHx55i6gqJzsI(76vmc)LyQiN)t0v0NjYYK)(p907EpLTE3Xc8Plh9JX7PRGoL5WioNkWm8Est3pBrzjOsQSumw)Wcoqfz0KyASxnby(nmteEjGWSLlzuULuKNSyMbr1XaK(9J)L3K)szxQVCKb26fSJxjIyzCSchiqr(ESQP9J)2)4jrvJCXEMajG1i8L9XRpWp8B)nYAGpOa5Fn(ECOZVX8zFlSGhSpkppCqyqh8)M4f7JywgqI9uKTwxkp1UZM9TY13DSOiykv7BT0FtyuOFQ5xcS9597tX8iER)8vSn8zGP3mFUCow2fNvozDopozgMXF7oxC1wMDTRGIDF88Kadqy8exbb8KK9rrZbqHGbbs4YzdleELfMSoE78mSPvmyy5cbnw1Tf)cSUMghfNUa)nt5pTN3537hTNnBm)FNZIYyZg5kMIPLa)2mVqbt1ZlQBNznNO60yxKbb5dnhAodaH8aEERqjQC1fTV3vGzSGevfEoJCPzgAYWvHNZ8uvGxACsFcoFdq7kNNTBI3nhFkJTG32BV7XQG7MJbAUq8gFu4xZZx33HBSfsxaqypK5TRcw8RhPUJX9Prdd7XVUvbGaHQlWdykTGHf7VVA0fdNCQfXzUoqg7R56JZKZUA0Pfcx3IPbjO(HD4WqZd(aD5EtTk2ZZ7SXtuanVp4nOq(UUbldCwEAxM(c5b605B6kDwKevCfYc1Iso8YuwXa)AyGf5g3C6xoD8Or96iYj4IH77N8mnCYLPYVZmX23z30PzkU5dSiEZ(nAJEBLjvUxjyyFSRGYu3lVdGtpTP05shF6q7LiDyRQWxjCVLSaMmi)xZZo9G1XhoCsj2dVbdpXKHu67gNn(WbZgM5n4KYwM5DmRTaCaVd0NTYP6g)a)7adDZwZGn)Ba3pcoCq(0vryEFUdBTz35VyfZ8J2Ww4hfbiIYJx4N(HnXWqVGb2eLSFhSKfWisP8DaV3cs3Vdr25)N9W0dyaxWUpu7LkxdcvF0(Tu98yomrbQs2oLN9G)hW14mSLdUDHYdwgbVnUccuRDGpggn)N3p3MhUb9R14BSe8EzDqQ)sAhQmIr3hJoZaZNS4iCT6Wb5JsaV2aNAMZY9E1iC14VmiRXUWDl6skKXBYWsNv1yHkKNwUiMEI8Jv87y2yfm2upHSwN0OuSToyFs9axDNN0PgjO0fh4vhRGAR9Rl4tzSzWjwWgZiJSgaOPwqdfuCo(m0p29yatYsapIv)DmtaY9TL8juiiJTLQsdOFydYtA9PG6Lbf9rMxpXtP3nz5dM4PoAjX54SX6bJYBsPq)d(Pj4lxqlXMHBCkiqgF0aciS)7AFyhvivGFqFxnxWy9xasmUlolBa1rmMlk5utN9QrAOinlYM)(9lwLVgxfxXbyGH6yf97wBbuuuxugQ78xrppnm4dzpRdeSWZsX2tSlKEUO0L7tF0L3gtwF6lC5LrvOz7W1VaqrHlFrEMQyH(y(L5A8Yc85BxxM6dS(OV9ySSwYm(j8GFnN(YYA7Sn2kDJSsCBeV1TZMmX(IuDOoQWmke9GnmBJjH)1oUtbh4g0C5WJETHNiviIpNQuPZZcxfgD4q(H8w6bxwuXb5aY7iMiLTjQPzYRDAI86bO8IBVEKr58UQAZ75MAuXCs(sB9lLtCIcGwLBByxLgUbmjnkmjZLr87CAa)UAw01sKSghXBbhdbJLlwwYTuTMrOQXQnomtNnbwFTOLfn6wWcvh3ClhwRdQjr77tm9RsOnC8OlMCQnheW5W0RhvJqX1(aQYwGLXZsMYGF7myLyOeDn1PSgmSsygk2byQcKoD2vnTj3nwC0CJga0vhoORDV23NCE6P3n5YxlkYvubWoHXwO0)SEBHBhp9U3q1(CWI63JNMsunCOL9wHSTssy1kqqNnKdKsKp16D5PL9Ku(nknOsZFG0ptVZeFsvsS6xoTuBX5BaYdiyuI6kbONIBvdoLKFgBEaVPoGV9QAezTLThTsa8rXheAbIUxJFcjlXyte1bgOBbd9imUbrr1PXUgzdlqtmPkx09SSmwuJcgSk2dLfnKVzSgjhwKauJwGOhtO5JFww4MWiP7dFwHLS7GFf27m)(qhuw9Xg7szzXi7(CmUtP3hh2bTBptOiGdRH)ka8HbaeB7EyZhi9o9ZpIjTmhUAlw1TCa5U2gYPfbmyu2YEyjyo3cCrcd(Y54Ws9pX5IY51SX2TOVMD)WdR0xUXkGiQAOeoGU3iU)bZXRkbFgRDi3)stVnwygoNF67CeUsmdSC(TvJfP7b8Vz0Qmw5mOhCYrOUOz8qeUlZuOgIrwZqVueIvhetQcTVZWLzD(9iPz0YD0Pxh2IZFwDK71HiV6)yEUvC0899ut5q)BAKhFCJSCSXDcZ0IqAJbhuijeffn30RWdOf3rbtpFonCw7660V3QWk55GLwWs0qBL7ZPLKpu6mDaVlmE(kfUyy2ROvblQ3jJBlS920b1QgjtlJC7GAdoSa4TNNgJIiKAfr8E4hbMfya5R9jfDdrjdlsBAah4ghuDIGGy(24791z6xLgMf948WGWGiwdu4RDjuwFLJRJCCDFHcxcgoS5LQBvnHR6nZyGTLXzgEGSgbR5yxDCjTKjb8E1I0YkKsbWZlWSny3wjZE0WpT6A9uhJdOI1aLVlANP6MFtHKXv44wqfoNQYUOP6gjwszDvOugmLLcsHAaUREWC5tdo5SA7NC61LrKMdEJfBTveykptUYaVcTPJWtDfRgqn0eSoCiPMguCfUzZh6PD(xxyrvx7mZ8Pem7AXJgaZnoHo38zOQJjTv7GdXi1OcaTZto)SuSWxvztQchv11PUmsTDDP5L9znYdcZNUG6FvxPbDLNxuQ7ZJ)Ikrtf51(DjURcGnBy4H0YQQvPzH5f7qlDIfODYntCiUdeRCGjcFTYiO2OQHp2hsnL3pBcEA06YwjvQrO2mzSIel70qJWOe5ZHDaFPT5RmbS4KJAK69Nv5vhVGL2AkHMzzAS2E)zCZ(GtgkVUKSLy7B7E2C)THB8N7heWI41awfDVRv7UTvw3mAa(r4vMdUAmD2Kr99Ws8s1nKx1gRymIvFLVTzO2mPUV5BvhiAvYbbHFHjdUNPOAdG8qanmSorQVY(e(tn5SH75W4RQ9Ko7Bg5S1Hlj9Ks6Ez0lo9ojYn5WHt0d8d2CHBALSd47aR(di2BR17zBYq0UGiwLdFlE3MAMNrhvDtryxWxBs)BsswpnMvMpwgxz3Iup6v6W1HUqoFRTTWy60Om0gjdKjKyPX0x7vsYMwdyptVmBReRub8vJWnbQQnmntHV1L7dTyGsk1ICLJKYLEBFsDq0(ZK7xONxEKkevFQi(2IPafP6lT4lo)YbfWkNlnVYRYDqEcExJRy53Dy6DKUanY7WbX1LBnZpA3AkJlUEIT1Aza0nqE(KIFz7tyP45kzdX5jYOe1nk5BOoYDXyVQgnRGAdQGztVUsaLDF8RvtE979ScYrnQFg1b6(LnOcDFld40bl(yBsy5hJmBjWbSgnAa1VYV3sETZaMoisW2COGp1Ftsu4YqEOwlZREJjE1oGoUmMVYf59wnvRf0rNaCTlqQkj1z11Zxu)Yb2wnaTfP61ntSf5vo4(91mSuXOxexEG6EWBIPk9c85XIBuT)IfuVcg(7HRJtyuFi2dFLaynHAX8lHLIqqG8JxQJUQdG0e48RdwLchsETaj06LKY0jKbM(wWJQggA10Yvlp08SJKN5q9nPz0uDLwXhLAfHm45CwyRsPu5Ev6od7jcpXIyC90PmwgQ(Qu26nCiYv(nM0kheNTZRr91IP5pfUJA67(I(GTOPxJSQRZRauXI2eU4ZLfPjEh39)VqJZrq5Q0DO1jGQKO1QN))TZqvcdpA9EhZQksRM7NqjjUS8YOu(bQYgIMxi5zv(CmnsOdiBMPNE24j5fjiUdvigklzv80v(P3TcebNrlq5Wa(Jn8oqovjWwKID3ESaAP22HXf0iSsAd69apkWzkVrMN3PZZc3eq5WX9HlWLBbRfk0Lfq15m4)LIv6k8lxeJibvrUEigB4XpGjqlV4wMKJQY6EfjFd2wKHvJRT(72t14R8ujbW4AKNvLvHpbawfGSLVxxNDXIvel2NsW80HJVy4OlhDTLIUby9)2p455DbD7UVW0A1XW)OLvlAvjJAQ8m1keRyrP7yXjThn4J()IZLrXtdRQz8gkoUSF1OmwGGP43J39RDbBbjILrjREVq2118RvSWQnAEtZlJoVfu9YYZUjmtOYairBLiYaiGeMN80Fuml)R86DICRxgApPYEGDpeJD9)TKyZGhdWnV04Y7P8Rqa5N3MYZBc5i3iF7s(oREHoMN4MLpVMkzUPDE1b1S)z6KbwRrfdC1cEtCyeNKrEmG3ZDkZAysI4t16EuTCo4jHBMVrY28M8Eb)B59cEfzLsBernRjOmAAEGSgAXyaNSOAfE7JhR4Ib8gkp2Z)qRa3JDlEC(J37uWvsei(7KTWF8)sq9pyPudUVe0fwz7mXcROIOyVfIW5PlT1EOBSf5gLNCD5ZhryPs58jbO0z4(XPIlpWPVIJ))90WvOzx51fZG1mU9koejhsZHqzjN(HRvuPQuOvJ6h)QMN7NaEeHRNV5T)tE91eaEuDgK)jLy6ir4iWEtj)QDJ1umlxyi72YhPqT3REL6)rjY2ZWuJ2vKl6rFovJ75hzA)Q4lt5BqQhLDeVan2JkDPH)btwWt5x5yGJJUZX5gB7NCPOCKIYi4)gkqduxG2X)qygwnqLt(81Rz9WfBUXBGokP0LZp9J31hSXJY8t2bK6zyr6SUE)ZPfad1HMII1LPItZTZ(Ur4bL5Gbu3o(t1b9nBunhnAXmr7mFlvb3QHI)10r6RBpDA7Pwcj9rGBP28rIR5WpmflJ0)EU2a0FSWLO(bSExdqI0MGwDMfJvn739ZlZvEG2yFhPXbnFI)5OX2NJwFIvuB81YijgOMO7WzlZmLXsrbZCO3CGxD6SV)IHxFkOpE(DXB3Nb2dYsV6M5VkjWRP76Z4rw)0Jb5TG70QL2TY1PQUWh1jKET4tUHWCzmPnLQppI37hOcONiEtfh2MMTki3g3af0FAIH)jQ0XJXpcy024)bmwuuaIq3Bky8eSB0xBYMMZkF1n7c3MAwfzzr41UGdwqH6ZMf7G7lqn9sjEpxA5FrE96N7mEOKbK6Pa(GGqFkAKBXark(1h4TRasyyIi4crXBxHrgh8tm3LWny)4N0MW5CjrRCExmAo4HvWDfpIrSXu0F4ZtQJnGQtfJi37toI9Gp3fuEBmaLgBHFVf3x(c1HgR75UQl1qvjFGLkaBd2fOEgek6In(Y1m(PXOQCJ2hy)SCV9QgC(0gVNzt1QWRLl3lpocjXzzHi6)mlhSf8f6jcqBmlSE5Ldp(KJ0IYSULGdMfs()AVR9EBJJJ4FwekGczLQdPEvBujby76I2I6gJOcK)Zk8XjXdHINkFefbyOp7DNz237SpUJ0okUb(FOPoU3UZo7883m7osiPJGONlqmDhienYorbW(pIo4p9joZMIFqT78Do4(ZSCtTAJrS4jcof)2wyXHQXLPhpNZchm84yhhSNNWCiWUWJUFY(bORpIZMLmtlVCPVC4a(jnpEllAIBhEu7L(o)f1c(k(3T9VdETLHpZSZ(E7Xn)T7Q6YvGlu1(k9432sI6YsUtH)WHqWNaPmHQ45dbGpomLB9gZYdSFBxswcel2rsILSXcudBzGk79Rs2GnLjyvDZeIScPlqSFur5HLWqY4lySr((M7itBx9F3uvbz6yeIPO1lhj(4ycIrOBwleFP99Z2d1leF4qiZ5ZRwjSzMs8c(0lap5MJypzj6oMYDlsjHbskZAEaSYEbKT9nlUfUq2wQYBRYvXv8lzo8xZktiKrkDtSnOSOZ9w3kiEln4qo)uGc1fe3(TL6YNAmlZIw8gErJLqLw)5mtxZe2QHL5TK1t3qCWg2GwmdZbUWmpZJOqzkEa4hqgvbDybYJwjbDhYTF1vec7(p)ae3GBRwmvCEsmjPyk8aYGcmWV7NBSCge(LqSA)wiEV0be7mdcEwcX7L(0338bi6eIpbvu5QzyJ9DdEFo(n)m6(AfIMm4RuHPWA150GlDS)1chEoyO0bHEoMgh5EIa84kIDaoLwPl1TFgTWiTh88wUo9w9(syuXMHHCCO(6LeZrlUx0GxjMWfJ5JRNr7RZTAw3EeoFxh6GrfPLRhtnwmxbtGm6ORGwLae8fNily2f6s4BQOmHQnW8vNMySyo(Bgq5FuLEFBI4mNgpf3FXOYTxS05fBptiHRF6ApKtwK3kZpAXe4SUvOHwnyZRNmlXaey2e)X28exzLEeLbgI3v2bXQ)xfFyIBbBkBIs8Y5t)dbB3tpO3WCzEjya3K(QFah5Z2X3Xcz2ATLeQWlggnBK4SIqB4BFRkC4YGzJrLMYoiMHXhRwFObEXeDf1nbYsqzM3TzXeswOYwnTspuL1FxHPCLMUc4kkqT9(HFVLzYoFVTvYXIaaBVgay9mAVcWVEQd6i1)FlgPric7bY79yEBP7bijjvL)wfa1mjPfn3atiHbKOyokgJy9dPSOoEC3ZyrWQyBdrS5iXEH5glAVi68te9HE8k97M3n9tX07kqS9wuK68KFCO3PJoVqOeMp37Sdok21FbNnNro(PopdmnkJlja3IGnDZD3)exTHKFbzFkWXlXWto8Uo0tPC)8EhbIHheC5p0xgxR2DUpf7J72vjt72Y9Y6JyX6s4I5E7zdJ3SsSR96Hw1p7(roANIwYgOQNRtwFU10XUvfsJp08(4H0qvipVHKERIpbNNBmIP1339tM1itFO9xjVOwqFiQMk9vu8NLkSLtnqJIoQkrFNWpvxvJYh(1VhD9zXIki5KaM0vf4aMJBHrMP0vWeEG9AxjWNpAg6eOyB7O7D)cocXlP9(AJIqI1mzw4hxvTqz1tWMMvWOSl2Q61fZhO3pekSDCEVD0toXiPI2YoHCL74J2(9W7hcvyfpv7Zt2oUWLdi9yv2rbXop5gmxOmkIIVhAAesJfCC1lRSnj6q0J9fsCHa1dhatoHkcyVeZTJSq4W9DW2mX(eCaeHthfQXXcjWy4BAWICtwdVqLxiTaddpa8ckYQRuB9HkKsyMP5(MS3jd41y2rLwXnTls4C2pQvIHDtHz6s)rCirAxXpUAMqv3uzv0yaPOUoxQwiVCQu4D8DACv5JWIPlBU)ECxqdbhYSAIxcp7IFsJ4hZ(6SLYsYYWtG8yTzhl(rvVTq5jvhGZAhuutmTcitJKqXdOui9He2mjqKJr8pqAuI0aQH4G)AtSf1KkkyyTE9gyoxKWJKsKfqisWUKBkz73ykvnmAMOG5y1)qiJuG3O9fuD)SQPU0vQlBq3vX55qH1QZF8A8)DnNVUxl1ihf)4WvZJoxDq4jLMSYgBvNRTtVyV3VFF)igiDs(qVAAdv)bboGq80KrqanOJquXclM6vyHmobc)8sijqqSeA1UhpAgANz)465Q1JwUwxInW0gm0HM6VwfJCldaA1Sm8LtXMiDuBJT1WT7wsibL)KmDELez7n)y72LDcN66OYomvuzDIgEe)cIi1O9TNJSljR01aw3Vy1M7fkTWYGFc0RGu3yo)fhnngm0Jf5ofENXlB(jLfgqizRXxTe2P3vT2R0bLYZUW51a0ePOdZrt5XFX83chxqKVLNuNdI1HPfzgeAkIjrS073uqaItY3cgSmtCGx(WIxLHujNx(7uABmU4yR76jEOL3HCCC(Wb9zm7tgRrLSFkEeQozakdcSfy4zMaAod76kOxsWQCcDREzzBivP2ZRUznr0uQ9asSgKUWogDeNuJEdcyWxWrLyKiyI7foRuQUOEcbSstKUHHNTVx)EY9c7LmB2(EfZYymUTdlHh6Odjfe(o59XluCTYlKxLTdG50vpODMrT6aHMir5Hr10vcQHWcRjll1wrYC1D)bSrMuibuhH8GBmy1n8QLLs(pIbkdN9Y93tDAk4PMwVcOzt5Msfg9fFJ78UHpHk4OBJEjHBENGCpH)Ho(cEu41uk)AiiQO)AoLTsPIp1eS1jARl4YlGEktX9hHlhoCad5PFBgdVvkdhJDCUn0B2OQPP5(LmDgcOlwP)6N4ztfYhLpgMD)SLwcZEbTs1yaHdAS19I0VwCUeqrV)GBj4jg59L1Mu9pdXs3AZH8841TRmZM1RDR8Wen2JW67bjsMeuGATF9ho47)UpOcFdyx2BM30mDowVnuzbTwx0ohbogSICzzcVAHi(8YyNDb5cOapL9(YzEneRZsfnbxhqLt5xew9hJvuemFeo0umSb1sxKItdTjCfD6jPr)2ZN9JCJHFjCx4M(G2LdpQVRRY(uVtJMfPlbp8785p(tsS0GahC26f8UDs3IJ)f24MnEPkd4qxXy8PzQEwDNZcU4K3k6sykvvDolPhiu5DHToQ1RQMFdDMryNPkMIJeopS4jRo3HnyMlvQOd)W5NoiMUdC12zn6PuFkdTqu50rJ5qkzH5FFLM2Gloo9T8COJtw7TtBQ1HR)1nVtdn4vckzf5x0JnBuo(JB7AFsvEEQDMCvfqKnJHbVmQ((L6j0AR0)2BA2SC9SYu(umL5Ooqz89vKGqq9ekpKk6Xut8(uUSliya2R1P)sTeDYPMxYXKXRwLAgY)97KrLgYPwd8W0mKnkkc6d4r6Hcc7fdEXGtAf5zihMiHjwBjBhoVgyXNEXrNg6SDab0JgOcPVjPhcXyRXG00yNfyvVX121BeRy(mCpueNDkwnDA9kNsAcB)m56TGlGDogWOZkNMdClMzFMMbXAwxT)99)th56vWtQ1r42WZtYxn05i4oviAbpyjA10hQIPhv4qCbVkdujYoZpVGh0dCeOpaqb7zXmnUA9dygsClFMvet0MfO5oV5Fr240aazelPjKb0VtjwpTcJzEr7qL6TueFiY5qUxhViWjldbbUfw09pcfkAGQ(ho643XDYBytu7LooMTDdhuuXPDkwTBCM5LY8UssPfNlQoHxMsCO0qhY)FHAm4kobBMWs5rKZJsG04IKJzuEd1gl1GXug0PTeHb7ywzBlBU)BX2VaLJ7TLTksEPDDPMVqQ4OqDe8fr5kP)co6xRiU6xtG)8pl2sCbtgflb0kA1lbflcYswuVUMYNM(fcF4g(IukU4vIg5JQjiMcDYpf46OOuYEF46Jk6EUuCtWutANcjagZV14kzFHHSaelKsvITCGFMWBVj)eMcYn1GjKAqCOlosanV3Sww7zpkPRakFrq9(OCpt7stamFn05CGsRykk)rfx95UP(kW3T)XcLnT1R3q96ZdnP3VELDXBnvv4wydZemzw4y8sTvnBPGXKg754IGJ0s25V(8eeCsx((FCz1TJwoL08a8e(oHwUKVwloQ4LOrHjJplaqlKUSq0)6qAGNNpitnYg7VALHt59QKtwOj7DJDTDR)VgsJDufqNp8mn4L0aVW(ZxF78MXJMBJaJDpdz8OrY9w5bZWqYr9VZOqIQXxjwaDLMwl1KoAUeLHKEYvna6rjio5Cr9Lr5eZcURXqtSe(ByKPKXx8U02Nkl2leFxUGhPmgJ9IeMA0yAnT94b9lMl5pGx8f3iHyaUiMtfUVqqawTkuRYhTf5qcoTurqDh0Q4r)H5GemE4JG0JtRaaMdlG7DVWUbWeQbS7AXcYACdIPyjdcsdn9Ktz0wYsnnvsl7F10Jpn)zcZsx8zRgC1yIAlQ92cRBfMFGv)Jm8pgKbc9l)KbCpUFww8bqiZVjSaSyEOvbn)IqJxq3ptMtcMbw(y(vrR3VEhu9RrXYxlRgsYdZxEcZiNiv6S1BtjBG8K5N(9kXXPsC(9kWPK9)8vGZZ3kV5lsf3O6RVVX2bK1bvDXdmfyQIuNQoVZv6aS0wo5OqlKj1njtrRefNG504NR1vRcDzIsIiFfr87vcXUTsikHUgmhTDDPWoqqxFtFbQZGph1xWoPUc(1TEcYuhbQhBzZACQ1Dq(3QE7OfNNZ3ZLDNkvTkY6hiFremAmMxh034k0vY)P)kLvmylBeNrKbYdr442PCCcqjfLlLVPpgjFmHJItx8RqQtl6yHjx1jVhEsSIBdyH3Qo75VviiDP8vkcxVFDWV0re7LAX39UcAPeTsnfUKh0Q(O51RWPD12uUun9UmwbME9(ShBbfm3XXJlXDBNtR5Cgl1C7lHD09YTekXqARdHbuq5WapIBZb45Q13clvERy)ydeDDY3TF5EHzjq0bUVzn0IhGkxdgziTsJK3tOyOGN3qDEw9tr1HCHBXblCB0pOMexRh9xK2oOsg5i0YiuTDbNcJP(DBQh(9z9)XjhOkx1xVuMY)X4TGlKexmzxkwKNm92mSlPrTOkXs)onk2E8B8msvSxvVS4t2LVcnH4PxKL)FSKTGdKTc307flQGewFn0nnQijK9wwDJ409mqcpCxOupbUrA6Ap(Gxfw6lmLuK0DHhIwJ6Qn3xTuLtc9pLTUJnLOSDQjYPQj8k3p2u)YJro2)kY5nXpRG3mIQjC0rkkBSIxF1siATYKrnd21AMBv212TUezZObbyMIPVmJBIDdyLMC1n2fxDCIn7a)hOI7WkWvw7lds2HtkAX(vXA98JheJxcrzOPv2ugr53wR(wfuddqnFjzuqamNviN)wiMmYEXGYMbBWoRd7RvoykJ8YPEor8PrAr3i69It1(0NIfb4DfDXoC4TGWSRcW9ZhkwAYKD6OEsEPBshzrJp3yDTAIuu1vwF5u0IODPvtxKtrDMQBvElijrwNairOgZahANdGUIfy(xK4rkAHgaEcPROodc4w9Kv7Shl)bxuEOLCcM7nd7a(GouPFvAldT2QBUtm6tX88BLmhCsPQAUc3PIJ)O4wqCHxV9akTb3V5sz7X1ZLXuZjhWT1HzvRW9w7NEEODX6bCcDFsvyfSLydzMFEudDvURpTaVbS1H8NDFQa7wt)qoK6ip6M0TbCRAnleHf76UdUCk5qOli05fClLLlSX5gHtcNLjAi7Nvsa)V4v7hA(GTZ5j2l7KuqMxNYf8JgS)Es5Vm4Oj(KYVM7y)XutWz4XBXGOMNxm8vfqAdErbNTIO2k)q3Mw)ItVOrotyRAAKN5IHhNJjLpaGzh5Jhuq7UWDlrtOkR3J8LKt9enNAoN9JWLvYM8lZMaLx1nlr8RyGZ(tC3Cdh5CZn4UoSJbK3G9QOd2wz4vjbORJrL1NAuYIoyiPaFLrrz0DRb5oeFAuokJXv45SUEzuxGyhzixz908Ot58dTq5zcXodJYQv0b5cr0zhg50eTOTI9pE1OnRN1S8JxDv9DBMJAZFlClZ)r4FF8)b]] )


end