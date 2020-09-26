-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'PALADIN' then
    local spec = Hekili:NewSpecialization( 70 )

    spec:RegisterResource( Enum.PowerType.HolyPower )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        zeal = 22590, -- 269569
        righteous_verdict = 22557, -- 267610
        execution_sentence = 23467, -- 343527

        fires_of_justice = 22319, -- 203316
        blade_of_wrath = 22592, -- 231832
        empyrean_power = 23466, -- 326732

        fist_of_justice = 22179, -- 234299
        repentance = 22180, -- 20066
        blinding_light = 21811, -- 115750

        unbreakable_spirit = 22433, -- 114154
        cavalier = 22434, -- 230332
        eye_for_an_eye = 22183, -- 205191

        divine_purpose = 17597, -- 223817
        holy_avenger = 17599, -- 105809
        seraphim = 17601, -- 152262

        selfless_healer = 23167, -- 85804
        justicars_vengeance = 22483, -- 215661
        healing_hands = 23086, -- 326734

        sanctified_wrath = 23456, -- 317866
        crusade = 22215, -- 231895
        final_reckoning = 22634, -- 343721
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        blessing_of_sanctuary = 752, -- 210256
        cleansing_light = 3055, -- 236186
        divine_punisher = 755, -- 204914
        hammer_of_reckoning = 756, -- 247675
        jurisdiction = 757, -- 204979
        law_and_order = 858, -- 204934
        lawbringer = 754, -- 246806
        luminescence = 81, -- 199428
        ultimate_retribution = 753, -- 287947
        unbound_freedom = 641, -- 305394
        vengeance_aura = 751, -- 210323
    } )

    -- Auras
    spec:RegisterAuras( {
        avenging_wrath = {
            id = 31884,
            duration = function () return ( azerite.lights_decree.enabled and 25 or 20 ) * ( talent.sanctified_wrath.enabled and 1.25 or 1 ) end,
            max_stack = 1,
        },

        avenging_wrath_autocrit = {
            id = 294027,
            duration = 20,
            max_stack = 1,
            copy = "avenging_wrath_crit"
        },

        blade_of_wrath = {
            id = 281178,
            duration = 10,
            max_stack = 1,
        },

        blessing_of_freedom = {
            id = 1044,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },

        blessing_of_protection = {
            id = 1022,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        blinding_light = {
            id = 115750,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        concentration_aura = {
            id = 317920,
            duration = 3600,
            max_stack = 1,
        },

        consecration = {
            id = 26573,
            duration = 12,
            max_stack = 1,
            generate = function( c, type )
                local dropped, expires

                c.count = 0
                c.expires = 0
                c.applied = 0
                c.caster = "unknown"                
                    
                for i = 1, 5 do
                    local up, name, start, duration = GetTotemInfo( i )

                    if up and name == class.abilities.consecration.name then
                        dropped = start
                        expires = dropped + duration
                        break
                    end
                end

                if dropped and expires > query_time then
                    c.expires = expires
                    c.applied = dropped
                    c.count = 1
                    c.caster = "player"
                end
            end
        },

        crusade = {
            id = 231895,
            duration = 25,
            type = "Magic",
            max_stack = 10,
        },

        crusader_aura = {
            id = 32223,
            duration = 3600,
            max_stack = 1,
        },

        devotion_aura = {
            id = 465,
            duration = 3600,
            max_stack = 1,
        },

        divine_purpose = {
            id = 223819,
            duration = 12,
            max_stack = 1,
        },

        divine_shield = {
            id = 642,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },

        -- Check racial for aura ID.
        divine_steed = {
            id = 221885,
            duration = 3,
            max_stack = 1,
            copy = { 221886 },
        },

        empyrean_power = {
            id = 326733,
            duration = 15,
            max_stack = 1,
        },

        execution_sentence = {
            id = 343527,
            duration = 8,
            max_stack = 1,
        },

        eye_for_an_eye = {
            id = 205191,
            duration = 10,
            max_stack = 1,
        },

        final_reckoning = {
            id = 343721,
            duration = 8,
            max_stack = 1,
        },

        fires_of_justice = {
            id = 209785,
            duration = 15,
            max_stack = 1,
            copy = "the_fires_of_justice" -- backward compatibility
        },

        forbearance = {
            id = 25771,
            duration = 30,
            max_stack = 1,
        },

        hammer_of_justice = {
            id = 853,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        hand_of_hindrance = {
            id = 183218,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        hand_of_reckoning = {
            id = 62124,
            duration = 3,
            max_stack = 1,
        },

        holy_avenger = {
            id = 105809,
            duration = 20,
            max_stack = 1,
        },

        inquisition = {
            id = 84963,
            duration = 45,
            max_stack = 1,
        },

        judgment = {
            id = 197277,
            duration = 15,
            max_stack = 1,
        },

        relentless_inquisitor = {
            id = 337315,
            duration = 12,
            max_stack = 5,
        },

        retribution_aura = {
            id = 183435,
            duration = 3600,
            max_stack = 1,
        },

        righteous_verdict = {
            id = 267611,
            duration = 6,
            max_stack = 1,
        },

        selfless_healer = {
            id = 114250,
            duration = 15,
            max_stack = 4,
        },

        seraphim = {
            id = 152262,
            duration = 15,
            max_stack = 1,
        },

        shield_of_the_righteous = {
            id = 132403,
            duration = 4.5,
            max_stack = 1,
        },        

        shield_of_vengeance = {
            id = 184662,
            duration = 15,
            max_stack = 1,
        },

        the_magistrates_judgment = {
            id = 337682,
            duration = 15,
            max_stack = 1,
        },

        -- what is the undead/demon stun?
        wake_of_ashes = { -- snare.
            id = 255937,
            duration = 5,
            max_stack = 1,
        },

        zeal = {
            id = 269571,
            duration = 20,
            max_stack = 3,
        },


        -- Azerite Powers
        empyreal_ward = {
            id = 287731,
            duration = 60,
            max_stack = 1,
        },


        -- PvP
        reckoning = {
            id = 247677,
            max_stack = 30,
            duration = 30
        },


        -- Legendaries
        blessing_of_dawn = {
            id = 337767,
            duration = 10,
            max_stack = 1
        },

        blessing_of_dusk = {
            id = 337757,
            duration = 10,
            max_stack = 1
        },
        
        final_verdict = {
            id = 337228,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        relentless_inquisitor = {
            id = 337315,
            duration = 12,
            max_stack = 20
        },

        the_arbiters_judgment = {
            id = 337682,
            duration = 15,
            max_stack = 1,
            copy = "arbiters_judgment"
        },
    } )

    spec:RegisterGear( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
    spec:RegisterGear( 'tier20', 147160, 147162, 147158, 147157, 147159, 147161 )
        spec:RegisterAura( 'sacred_judgment', {
            id = 246973,
            duration = 8
        } )

    spec:RegisterGear( 'tier21', 152151, 152153, 152149, 152148, 152150, 152152 )
        spec:RegisterAura( 'hidden_retribution_t21_4p', {
            id = 253806, 
            duration = 15 
        } )

    spec:RegisterGear( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
    spec:RegisterGear( 'truthguard', 128866 )
    spec:RegisterGear( 'whisper_of_the_nathrezim', 137020 )
        spec:RegisterAura( 'whisper_of_the_nathrezim', {
            id = 207633,
            duration = 3600
        } )

    spec:RegisterGear( 'justice_gaze', 137065 )
    spec:RegisterGear( 'ashes_to_dust', 51745 )
        spec:RegisterAura( 'ashes_to_dust', {
            id = 236106, 
            duration = 6
        } )

    spec:RegisterGear( 'aegisjalmur_the_armguards_of_awe', 140846 )
    spec:RegisterGear( 'chain_of_thrayn', 137086 )
        spec:RegisterAura( 'chain_of_thrayn', {
            id = 236328,
            duration = 3600
        } )

    spec:RegisterGear( 'liadrins_fury_unleashed', 137048 )
        spec:RegisterAura( 'liadrins_fury_unleashed', {
            id = 208410,
            duration = 3600,
        } )

    spec:RegisterGear( "soul_of_the_highlord", 151644 )
    spec:RegisterGear( "pillars_of_inmost_light", 151812 )
    spec:RegisterGear( "scarlet_inquisitors_expurgation", 151813 )
        spec:RegisterAura( "scarlet_inquisitors_expurgation", {
            id = 248289, 
            duration = 3600,
            max_stack = 3
        } )

    spec:RegisterHook( "prespend", function( amt, resource, overcap )
        if resource == "holy_power" and amt < 0 and buff.holy_avenger.up then
            return amt * 3, resource, overcap
        end
    end )

    
    spec:RegisterHook( 'spend', function( amt, resource )
        if amt > 0 and resource == "holy_power" then
            if talent.crusade.enabled and buff.crusade.up then
                addStack( "crusade", buff.crusade.remains, amt )
            end
            if talent.fist_of_justice.enabled then
                setCooldown( "hammer_of_justice", max( 0, cooldown.hammer_of_justice.remains - 2 * amt ) )
            end
            if legendary.uthers_devotion.enabled then
                setCooldown( "blessing_of_freedom", max( 0, cooldown.blessing_of_freedom.remains - 1 ) )
                setCooldown( "blessing_of_protection", max( 0, cooldown.blessing_of_protection.remains - 1 ) )
                setCooldown( "blessing_of_sacrifice", max( 0, cooldown.blessing_of_sacrifice.remains - 1 ) )
                setCooldown( "blessing_of_spellwarding", max( 0, cooldown.blessing_of_spellwarding.remains - 1 ) )
            end
            if legendary.relentless_inquisitor.enabled then
                addStack( "relentless_inquisitor", nil, amt )
            end                
            if legendary.of_dusk_and_dawn.enabled and holy_power.current == 0 then applyBuff( "blessing_of_dusk" ) end
        end        
    end )

    spec:RegisterHook( "gain", function( amt, resource, overcap )
        if legendary.of_dusk_and_dawn.enabled and amt > 0 and resource == "holy_power" and holy_power.current == 5 then
            applyBuff( "blessing_of_dawn" )
        end
    end )

    spec:RegisterStateExpr( "time_to_hpg", function ()
        return max( gcd.remains, min( cooldown.judgment.remains, cooldown.crusader_strike.remains, cooldown.blade_of_justice.remains, ( action.hammer_of_wrath.usable and cooldown.hammer_of_wrath.remains or 999 ), cooldown.wake_of_ashes.remains, ( race.blood_elf and cooldown.arcane_torrent.remains or 999 ), ( IsSpellKnown( 304971 ) and cooldown.divine_toll.remains or 999 ) ) )
    end )

    spec:RegisterHook( "reset_precast", function ()
        --[[ Moved to hammer_of_wrath_hallow generator.
        if IsUsableSpell( 24275 ) and not ( target.health_pct < 20 or buff.avenging_wrath.up or buff.crusade.up or buff.final_verdict.up ) then
            applyBuff( "hammer_of_wrath_hallow", action.ashen_hallow.lastCast + 30 - now )
        end ]]
    end )


    spec:RegisterStateFunction( "apply_aura", function( name )
        removeBuff( "concentration_aura" )
        removeBuff( "crusader_aura" )
        removeBuff( "devotion_aura" )
        removeBuff( "retribution_aura" )

        if name then applyBuff( name ) end
    end )

    spec:RegisterStateFunction( "foj_cost", function( amt )
        if buff.fires_of_justice.up then return max( 0, amt - 1 ) end
        return amt
    end )

    spec:RegisterStateFunction( "arbiters_cost", function( amt )
        if buff.arbiters_judgment.up then return max( 0, amt - 1 ) end
        return amt
    end )



    -- Abilities
    spec:RegisterAbilities( {
        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 42 and 120 or 180 ) end,
            gcd = "off",

            toggle = 'cooldowns',
            notalent = 'crusade',

            startsCombat = true,
            texture = 135875,

            nobuff = 'avenging_wrath',

            handler = function ()
                applyBuff( 'avenging_wrath' )
                applyBuff( "avenging_wrath_crit" )
            end,
        },


        blade_of_justice = {
            id = 184575,
            cast = 0,
            cooldown = function () return 12 * haste end,
            gcd = "spell",

            spend = -2,
            spendType = 'holy_power',

            startsCombat = true,
            texture = 1360757,

            handler = function ()
                removeBuff( "blade_of_wrath" )
                removeBuff( 'sacred_judgment' )
            end,
        },


        blessing_of_freedom = {
            id = 1044,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 0.07,
            spendType = "mana",

            startsCombat = false,
            texture = 135968,

            handler = function ()
                applyBuff( 'blessing_of_freedom' )
            end,
        },


        blessing_of_protection = {
            id = 1022,
            cast = 0,
            charges = 1,
            cooldown = 300,
            recharge = 300,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = false,
            texture = 135964,

            readyTime = function () return debuff.forbearance.remains end,

            handler = function ()
                applyBuff( 'blessing_of_protection' )
                applyDebuff( 'player', 'forbearance' )

                if talent.liadrins_fury_reborn.enabled then
                    gain( 5, "holy_power" )
                end
            end,
        },


        blinding_light = {
            id = 115750,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            talent = 'blinding_light',

            startsCombat = true,
            texture = 571553,

            handler = function ()
                applyDebuff( 'target', 'blinding_light', 6 )
                active_dot.blinding_light = active_enemies
            end,
        },


        cleanse_toxins = {
            id = 213644,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135953,

            usable = function ()
                return buff.dispellable_poison.up or buff.dispellable_disease.up, "requires poison or disease"
            end,

            handler = function ()
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_disease" )
            end,
        },


        concentration_aura = {
            id = 317920,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135933,

            nobuff = "concentration_aura",
            
            handler = function ()
                apply_aura( "concentration_aura" )
            end,
        },


        consecration = {
            id = 26573,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 135926,

            handler = function ()
                applyBuff( "consecration" )
            end,
        },


        crusade = {
            id = 231895,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            talent = 'crusade',
            toggle = 'cooldowns',

            startsCombat = false,
            texture = 236262,

            nobuff = 'crusade',

            handler = function ()
                applyBuff( 'crusade' )
            end,
        },


        crusader_aura = {
            id = 32223,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135890,
            
            handler = function ()
                apply_aura( "crusader_aura" )
            end,
        },
        
        
        crusader_strike = {
            id = 35395,
            cast = 0,
            charges = 2,
            cooldown = function () return 6 * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
            recharge = function () return 6 * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
            gcd = "spell",

            spend = 0.12,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135891,

            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },


        devotion_aura = {
            id = 465,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135893,
            
            handler = function ()
            end,
        },


        divine_shield = {
            id = 642,
            cast = 0,
            cooldown = function () return 300 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 524354,

            readyTime = function () return debuff.forbearance.remains end,

            handler = function ()
                applyBuff( 'divine_shield' )
                applyDebuff( 'player', 'forbearance' )

                if talent.liadrins_fury_reborn.enabled then
                    gain( 5, "holy_power" )
                end
            end,
        },


        divine_steed = {
            id = 190784,
            cast = 0,
            charges = function () return talent.cavalier.enabled and 2 or nil end,
            cooldown = function () return level > 48 and 30 or 45 end,
            recharge = function () return level > 48 and 30 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 1360759,

            handler = function ()
                applyBuff( 'divine_steed' )
            end,
        },


        divine_storm = {
            id = 53385,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                if buff.empyrean_power.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_arbiters_judgment.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            startsCombat = true,
            texture = 236250,

            handler = function ()
                removeDebuff( "target", "judgment" )

                if buff.empyrean_power.up then removeBuff( 'empyrean_power' )
                elseif buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end

                if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
            end,
        },


        execution_sentence = {
            id = 343527,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_arbiters_judgment.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            talent = 'execution_sentence', 

            startsCombat = true,
            texture = 613954,

            handler = function ()
                if buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else
                    removeBuff( "fires_of_justice" )
                    removeBuff( "hidden_retribution_t21_4p" )
                end
                applyDebuff( "target", "execution_sentence" )
            end,
        },


        eye_for_an_eye = {
            id = 205191,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = 'eye_for_an_eye',

            startsCombat = false,
            texture = 135986,

            handler = function ()
                applyBuff( 'eye_for_an_eye' )
            end,
        },


        final_reckoning = {
            id = 343721,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = 'final_reckoning',

            startsCombat = true,
            texture = 135878,

            handler = function ()
                applyDebuff( "target", "final_reckoning" )
            end,
        },


        flash_of_light = {
            id = 19750,
            cast = function () return ( 1.5 - ( buff.selfless_healer.stack * 0.5 ) ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            startsCombat = false,
            texture = 135907,

            handler = function ()
                removeBuff( 'selfless_healer' )
            end,
        },


        hammer_of_justice = {
            id = 853,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 135963,

            handler = function ()
                applyDebuff( 'target', 'hammer_of_justice' )
            end,
        },


        hammer_of_reckoning = {
            id = 247675,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            -- texture = ???,

            pvptalent = "hammer_of_reckoning",

            usable = function () return buff.reckoning.stack >= 50 end,
            handler = function ()
                removeStack( "reckoning", 50 )
                if talent.crusade.enabled then
                    applyBuff( "crusade", 12 )
                else
                    applyBuff( "avenging_wrath", 6 )
                end
            end,
        },


        hammer_of_wrath = {
            id = 24275,
            cast = 0,
            charges = function () return legendary.vanguards_momentum.enabled and 3 or nil end,
            cooldown = function () return 7.5 * haste end,
            recharge = function () return legendary.vanguards_momentum.enabled and ( 7.5 * haste ) or nil end,
            gcd = "spell",

            spend = -1,
            spendType = 'holy_power',

            startsCombat = true,
            texture = 613533,

            usable = function () return target.health_pct < 20 or ( level > 57 and ( buff.avenging_wrath.up or buff.crusade.up ) ) or buff.final_verdict.up or buff.hammer_of_wrath_hallow.up end,
            handler = function ()
                removeBuff( "final_verdict" )

                if legendary.the_mad_paragon.enabled then
                    if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 1 end
                    if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 1 end
                end
            end,
        },


        hand_of_hindrance = {
            id = 183218,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 1360760,

            handler = function ()
                applyDebuff( 'target', 'hand_of_hindrance' )
            end,
        },


        hand_of_reckoning = {
            id = 62124,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135984,

            handler = function ()
                applyDebuff( 'target', 'hand_of_reckoning' )
            end,
        },


        holy_avenger = {
            id = 105809,
            cast = 0,
            cooldown = 180,
            gcd = "off",
            
            toggle = "cooldowns",
            talent = "holy_avenger",

            startsCombat = true,
            texture = 571555,
            
            handler = function ()
                applyBuff( "holy_avenger" )
            end,
        },


        judgment = {
            id = 20271,
            cast = 0,
            charges = 1,
            cooldown = function () return 12 * haste end,
            gcd = "spell",

            spend = -1,
            spendType = "holy_power",

            startsCombat = true,
            texture = 135959,

            handler = function ()
                applyDebuff( 'target', 'judgment' )
                if talent.zeal.enabled then applyBuff( 'zeal', 20, 3 ) end
                if set_bonus.tier20_2pc > 0 then applyBuff( 'sacred_judgment' ) end
                if set_bonus.tier21_4pc > 0 then applyBuff( 'hidden_retribution_t21_4p', 15 ) end
                if talent.sacred_judgment.enabled then applyBuff( 'sacred_judgment' ) end
            end,
        },


        justicars_vengeance = {
            id = 215661,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 5 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            startsCombat = true,
            texture = 135957,

            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
            end,
        },


        lay_on_hands = {
            id = 633,
            cast = 0,
            cooldown = function () return 600 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
            gcd = "off",

            startsCombat = false,
            texture = 135928,

            readyTime = function () return debuff.forbearance.remains end,

            handler = function ()
                gain( health.max, "health" )
                applyDebuff( 'player', 'forbearance', 30 )

                if talent.liadrins_fury_reborn.enabled then
                    gain( 5, "holy_power" )
                end

                if azerite.empyreal_ward.enabled then applyBuff( "empyreal_ward" ) end
            end,
        },


        rebuke = {
            id = 96231,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            toggle = 'interrupts',

            startsCombat = true,
            texture = 523893,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        redemption = {
            id = 7328,
            cast = function () return 10 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 135955,

            handler = function ()
            end,
        },


        repentance = {
            id = 20066,
            cast = function () return 1.7 * haste end,
            cooldown = 15,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135942,

            handler = function ()
                interrupt()
                applyDebuff( 'target', 'repentance', 60 )
            end,
        },


        retribution_aura = {
            id = 183435,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135889,
            
            handler = function ()
                apply_aura( "retribution_aura" )
            end,
        },


        seraphim = {
            id = 152262,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = function () return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 ) end,
            spendType = "holy_power",

            talent = 'seraphim',
            toggle = 'cooldowns',

            startsCombat = false,
            texture = 1030103,

            handler = function ()
                applyBuff( 'seraphim' )
            end,
        },


        shield_of_the_righteous = {
            id = 53600,
            cast = 0,
            cooldown = 1,
            gcd = "spell",
            
            spend = function () return 3  - ( buff.the_magistrates_judgment.up and 1 or 0 ) end,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 236265,
            
            usable = function() return false end,
            handler = function ()
                applyBuff( "shield_of_the_righteous" )
                -- TODO: Detect that we're wearing a shield.
                -- Can probably use the same thing for Stormstrike requiring non-daggers, etc.
            end,
        },


        shield_of_vengeance = {
            id = 184662,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = true,
            texture = 236264,

            usable = function () return incoming_damage_3s > 0.2 * health.max, "incoming damage over 3s is less than 20% of max health" end,
            handler = function ()
                applyBuff( 'shield_of_vengeance' )
            end,
        },


        templars_verdict = {
            id = 85256,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            startsCombat = true,
            texture = 461860,

            handler = function ()
                removeDebuff( "target", "judgment" )
                
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )                
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                if buff.vanquishers_hammer.up then removeBuff( "vanquishers_hammer" ) end
                if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
                if talent.righteous_verdict.enabled then applyBuff( 'righteous_verdict' ) end
                if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
            end,

            copy = { "final_verdict", 336872 }
        },


        vanquishers_hammer = {
            id = 328204,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 1 - ( buff.the_magistrates_judgment.up and 1 or 0 ) end,
            spendType = "holy_power",

            startsCombat = true,
            texture = 3578228,

			handler = function ()
				if debuff.judgment.up then removeDebuff( "target", "judgment" ) end
            end
        },        


        wake_of_ashes = {
            id = 255937,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = -3,
            spendType = 'holy_power',

            startsCombat = true,
            texture = 1112939,

            usable = function ()
                if settings.check_wake_range and not ( target.exists and target.within12 ) then return false, "target is outside of 12 yards" end
                return true
            end,

            handler = function ()
                if target.is_undead or target.is_demon then applyDebuff( 'target', 'wake_of_ashes' ) end
                if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        word_of_glory = {
            id = 85673,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            startsCombat = false,
            texture = 133192,

            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                gain( 1.33 * stat.spell_power * 8, 'health' )
            end,
        },
    } )


    spec:RegisterPack( "Retribution", 20200926, [[dy0QKbqifLEKcrXMOu(eHq1OOKCkkrRIqWRuumlkvTlO(Lcvdtr1XiKwgLuptsvtJq01uOSncH8nkvW4OuHoNcrSofIQAEsQCpfSpPIdQqurluH0dvikLlQquQ(OcrfojHqPvkP0mvikXoLk1qviQ0sjekEkjMQujFvHOKgRcrv2RG)kXGr1HPAXe8yIMmPUmYMf6ZO0OvKtRYQvi8AkHzlLBts7w0VvA4svhxHiTCv9Cith46uSDc13LKXtPsNxsX6PurZhf7h0brdDfu0oGcDB9CRNpFKyTiclQOJnM12XGcOMEkO07slCwkOKUkfueXqG)emGBZGsVxtBDDORGcAnVKckbfbZ1aIyZGqqr7ak0T1ZTE(8rI1IiSOIo2ywBhckOEsg62ompOmDAnLbHGIMqYGYidKlIHa)jya3Mq(ixV56lH1oYa5kupGufOhYTwezpKB9CRNhu6)nEnkOmYa5IyiWFcgWTjKpY1BU(syTJmqUc1divb6HCRfr2d5wp365WAH16sWTjc3)KCvfCWqS5ilG16sWTjc3)KCvfCWmdJh3vdR1LGBteU)j5Qk4Gzgg3nSQucCWTjSwxcUnr4(NKRQGdMzyCu69OPfuqahGG16sWTjc3)KCvfCWmdJ3VGBtyTUeCBIW9pjxvbhmZW4(l9KkG9FkbWAHCyTJmq(i72LKgaPHCsm91a5GtLGCWeb5UeSpKFii3f7xZfAegwRlb3MOHNemwqWADj42enZW4sV1kUeCBwAhcyF6Q0GC3MERseSwxcUnrZmmU0BTIlb3ML2Ha2NUknWsj9oyFeSwihwRlb3MiSC3MERs0q)cUnT)IdwjyIrSqBxDZGa4NCjGHrWeJyxmLSxYwQEhmHn92emXi2ftj7LSLQ3bt4Nu9lrDe1oYWiyIrS8nixtytVnbtmILVb5Ac)KQFjQoRhZsyTUeCBIWYDB6TkrZmmE7yNaOYimAwvkb2FXbup1AfG)SeaHBh7eavgHrZQsjOZG1mmwn77NUqIPeGDTgHj7EiaIH59txiXucWUwJWx2XomMLWADj42eHL720BvIMzy849KqBxT9xCqWeJyxmLSxYwQEhmHn9mmcMyelFdY1e20BtWeJy5BqUMWiGlTyq05WADj42eHL720BvIMzyC00rnDzJfXuYsEkjyTUeCBIWYDB6TkrZmmUbrLdqQ2NUkn8UDQnPfOIWXwEsxemaWMWADj42eHL720BvIMzyCdIkhGuTpDvAWrtI9KqL3TZ9lY99M9xCqtcMye)UDUFrUV3kAsWeJy9wLmmwjyIrSlMs2lzlvVdMWpP6xI6my9CggbtmILVb5AcJaU0IbrNBtWeJy5BqUMWpP6xI6i6ywAZk5Un9wLywJ)6ZZYglUDs)cMWpP6xI6msMZWaovQa2I(O6QFodZSecrPKWYn1uIiDPDrkUVKWQ(i23syTUeCBIWYDB6TkrZmmUbrLdqQ2NUknmccvM2Qg92FXbbtmIDXuYEjBP6DWe20ZWiyIrS8nixtytVnbtmILVb5AcJaU0IbrNdR1LGBtewUBtVvjAMHXniQCas1(0vPbXN3kBS45P6asxeA7QT)IdwjyIrSlMs2lzlvVdMWMEggbtmILVb5AcB6TjyIrS8nixt4Nu9lr1jQD0sggRK720BvIDXuYEjBP6DWe(jv)suN6NZWi3TP3QelFdY1e(jv)suN6NBjSwxcUnry5Un9wLOzgg3GOYbiv7txLg07QIkrZxJ9xCqWeJyxmLSxYwQEhmHn9mmcMyelFdY1e20BtWeJy5BqUMWpP6xIQtu7iSwxcUnry5Un9wLOzgg3GOYbiv7txLgy9gj9wJEurGClS)IdcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEBcMyelFdY1e(jv)suDIogSwxcUnry5Un9wLOzgg3GOYbiv7txLgeQHDtQiquXBQE6s7V4GGjgXUykzVKTu9oycB6zyemXiw(gKRjSPhwRlb3MiSC3MERs0mdJBqu5aKQ9PRsdQ0twaMCuj6jR9xCWQzF)0fsmLaSR1imz3dbqmmVF6cjMsa21Ae(YoIoMLmmOEQ1ka)zjacRpXxsfeyF1odwdR1LGBtewUBtVvjAMHXniQCas1(0vPH(Mj10lq(RrLyZrwy)fhemXi2ftj7LSLQ3btytpdJGjgXY3GCnHn92emXiw(gKRjmc4sl6mi6Cgg5Un9wLyxmLSxYwQEhmHFs1Ve1rKJXWmRGjgXY3GCnHn92K720BvILVb5Ac)KQFjQJihdwRlb3MiSC3MERs0mdJBqu5aKQ9PRsdc0JO3c6rLrygHX(loiyIrSlMs2lzlvVdMWMEggbtmILVb5AcB6TjyIrS8nixtyeWLw0zq05mmYDB6TkXUykzVKTu9oyc)KQFjQJihJHzwbtmILVb5AcB6Tj3TP3QelFdY1e(jv)suhrogSwxcUnry5Un9wLOzgg3GOYbiv7txLgOu3ieQaUucmpv2yj(UeCB6Ts)wrV9xCqWeJyxmLSxYwQEhmHn9mmcMyelFdY1e20BtWeJy5BqUMWiGlTOZGOZzyK720BvIDXuYEjBP6DWe(jv)suhrogdJC3MERsS8nixt4Nu9lrDe5yWADj42eHL720BvIMzyCdIkhGuTpDvAON8Vv0Ny6rf5Q27iK9xCqWeJyxmLSxYwQEhmHn9mmcMyelFdY1e20BtWeJy5BqUMWiGlTOZGOZH16sWTjcl3TP3QenZW4gevoaPAF6Q0q8EeOO6acvq91W2CeY(loiyIrSlMs2lzlvVdMWMEggbtmILVb5AcB6TjyIrS8nixt4Nu9lr1ni6yWADj42eHL720BvIMzyCdIkhGuTpDvAqU)B6bKUW2C95G9rfvs7T2TP9xCqWeJyxmLSxYwQEhmHn9mmcMyelFdY1e20BtWeJy5BqUMWpP6xIQZ65WADj42eHL720BvIMzyCdIkhGuTpDvAqU)B6bKUW2C95G9rfbxZs2FXbbtmIDXuYEjBP6DWe20ZWiyIrS8nixtytVnbtmILVb5Ac)KQFjQorhdwRlb3MiSC3MERs0mdJBqu5aKQ9PRsdv)bMUKTGiwvkbLnw0pHaoRdMG16sWTjcl3TP3QenZW4gevoaPAF6Q0aAALwiCa6rLONS2FXbbtmIDXuYEjBP6DWe20ZWiyIrS8nixtytpSwxcUnry5Un9wLOzgg3GOYbiv7txLgAN4lzl71ksppeGEyTUeCBIWYDB6TkrZmmUbrLdqQ2NUkn8hW4TsKCWe9LnwmzYwClS)IdcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEBcMyelFdY1egbCPfdIoNHrUBtVvj2ftj7LSLQ3bt4Nu9lrDgQFodJC3MERsS8nixt4Nu9lrDgQFoSwxcUnry5Un9wLOzgg3GOYbiv7txLgEsDbuH1CApLurtIpjbR1LGBtewUBtVvjAMHXniQCas1(0vPbXN3kBSGa7RIG16sWTjcl3TP3QenZW4gevoaPAF6Q0q109TQlzrL(Mr1zj7V4GGjgXUykzVKTu9oycB6zyemXiw(gKRjSP3MGjgXY3GCnHFs1Vev3G1ZH16sWTjcl3TP3QenZW4gevoaPAF6Q0G(jxxyBU(CW(OIGRzj7V4GGjgXUykzVKTu9oycB6zyemXiw(gKRjSP3MGjgXY3GCnHFs1Vev3G1ZH16sWTjcl3TP3QenZW4gevoaPAF6Q0G(jxxCu)9Ecqfvs7T2TP9xCqWeJyxmLSxYwQEhmHn9mmcMyelFdY1e20BtWeJy5BqUMWpP6xIQBW65WADj42eHL720BvIMzyCdIkhGuTpDvAG93Kfv6)t1BL3zj7V4WScMye7IPK9s2s17GjSP32ScMyelFdY1e20dR1LGBtewUBtVvjAMHXniQCas1(0vPb0LhcqFHT56Zb7JkcUMLS)IdcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEBcMyelFdY1e(jv)suDdIogSwxcUnry5Un9wLOzgg3GOYbiv7txLgqxEia9f2MRphSpQOsAV1UnT)IdcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEBcMyelFdY1e(jv)suDdwphwRlb3MiSC3MERs0mdJBqu5aKQ9PRsdUDIM83rL4MGYgl9Bf92FXHzbEJsaw(gKRjmLUqJ02K720BvIDXuYEjBP6DWe(jv)suDJXWa8gLaS8nixtykDHgPTj3TP3QelFdY1e(jv)suDJzdCQuhrNZWmTTAk9Bf9DgQ3g4uP6eDUnG3OeGRClOYgloAIqykDHgPH16sWTjcl3TP3QenZW4gevoaPAF6Q0G4dDBw2yrtQhIS)IdcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEBcMyelFdY1egbCPfdIoNHrUBtVvj2ftj7LSLQ3bt4Nu9lrDgQFodJC3MERsS8nixt4Nu9lrDgQFoSwxcUnry5Un9wLOzgg3GOYbiv7txLgC0Kypju5D7C)ICFVz)fh0KGjgXVBN7xK77TIMemXiwVvjdJvcMye7IPK9s2s17Gj8tQ(LOodwpNHrWeJy5BqUMWiGlTyq052emXiw(gKRj8tQ(LOoIoML2SsUBtVvjM14V(8SSXIBN0VGj8tQ(LOoJK5mmGtLkGTOpQU6NZWmlHqukjSCtnLisxAxKI7ljSQpI9TewRlb3MiSC3MERs0mdJBqu5aKQ9PRsdwKlOSXINYJsqjA(AS)IdcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEBcMyelFdY1egbCPfDgeDodJC3MERsSlMs2lzlvVdMWpP6xI6u)CgMzfmXiw(gKRjSP3MC3MERsS8nixt4Nu9lrDQFoSwxcUnry5Un9wLOzgg3rtuwM8wBRS)IdZkyIrSlMs2lzlvVdMWMEBZkyIrS8nixtytpSwxcUnry5Un9wLOzgg3ftj7LSLQ3bt2FXbRM2wnL(TI(odI0g4uP6gJHzAB1u63k67muVnWPsDgJHb4nkb4PTvtXftjl9ykDHgPTj3TP3QepTTAkUykzPh)KQFjAyUL2aNkvaBzQNDyoSwxcUnry5Un9wLOzggx(gKRj7V4GvtBRMs)wrFNbrAdCQuDJXWmTTAk9Bf9DgQ3g4uPoJXWa8gLa802QP4IPKLEmLUqJ02K720BvIN2wnfxmLS0JFs1Venm3sBGtLkGTm1ZomhwRlb3MiSC3MERs0mdJpTTAkUykzP3(loaovQa2Yup7WCBwzLGjgXUykzVKTu9oycB6zyemXiw(gKRjSP3sggRemXi2ftj7LSLQ3bty9wL2K720BvIDXuYEjBP6DWe(jv)suhroNHrWeJy5BqUMW6TkTj3TP3QelFdY1e(jv)suhro3slH16sWTjcl3TP3QenZW4Xl9w5jPfBEjR9xCyAB1u63k67muVn5Un9wLyxmLSxYwQEhmHFs1Ve1HvQTbovQa2Yup7WCBwnlWBucWi69(PtftPl0indJGjgXi69(PtfB6TewRlb3MiSC3MERs0mdJdMOIjfwtQlX9LK9xCaCQuDdwZWiyIr8tslAecvI7ljSPhwRlb3MiSC3MERs0mdJl02vx2ybmrfkj1AS)IdcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEBcMyelFdY1egbCPfdIohwRlb3MiSC3MERs0mdJZA8xFEw2yXTt6xWK9xCywG3OeGLVb5ActPl0iTnRK720BvIDXuYEjBP6DWe(jv)suDJzBAB1u63k67mupdJC3MERsSlMs2lzlvVdMWpP6xI6miYXSKHXkG3OeGLVb5ActPl0iTn5Un9wLy5BqUMWpP6xIQJvQTnTTAk9Bf9DgejdJC3MERsS8nixt4Nu9lrDge5ywcR1LGBtewUBtVvjAMHXR2VPftxwEcTPNsY(loi3TP3Qe7IPK9s2s17Gj8tQ(LO6yLABtBRMs)wrFNH6zyaEJsaw(gKRjmLUqJ02K720BvILVb5Ac)KQFjQowP2202QP0Vv03zqKmmYDB6TkXUykzVKTu9oyc)KQFjQZGihJHrUBtVvjw(gKRj8tQ(LOodICmyTUeCBIWYDB6TkrZmmECLgePlUDs)bOIa5Q2FXbRM99txiXucWUwJWKDpeaXW8(PlKykbyxRr4l7u)Cggup1AfG)SeaH1N4lPccSVANbRT02SwjyIrSlMs2lzlvVdMWMEggbtmILVb5AcB6T0MvYDB6TkXcnxtLnwgHbbojHFs1Ve1HvQfH6Tj3TP3QepcJMvLsa(jv)suhwPweQ3syTUeCBIWYDB6TkrZmmUkPUFnLnwAg5Pl6NCvK9xCWkbtmIDXuYEjBP6DWe20ZWiyIrS8nixtytVnbtmILVb5AcJaU0IbrNBPTPTvtPFROVUH6H16sWTjcl3TP3QenZW49M)I1CjBrO5iG9xCWQzF)0fsmLaSR1imz3dbqmmVF6cjMsa21Ae(Yo1pNHb1tTwb4plbqy9j(sQGa7R2zWAlH1c5WADj42eHJxEOj6rZmmUy)pxOr2NUknOrfPJaUqJSxS3m0aQNATcWFwcGW6t8Lubb2xTZG1mmcMyetQ918KNL(TIESP3MMemXiEegnRkLaSERsBcMyeRpXxsLEZ3VicR3QKHb1tTwb4plbqy9j(sQGa7R2zWABcMyelFdY1e20BtWeJy5BqUMWiGlTOorNdR1LGBteoE5HMOhnZW4i69(Pt1(loyLvZc8gLaS8nixtykDHgPTjyIrSlMs2lzlvVdMWMEgg5Un9wLyxmLSxYwQEhmHFs1Ve1X6XSKHXkbtmILVb5AcB6zyK720BvILVb5Ac)KQFjQJ1JzPL2SAwG3OeGJx6TYtsl28swmLUqJ0mmYDB6TkXXl9w5jPfBEjl(jv)suDIo3sBwnlWBucWKDjPbCBwqucOusykDHgPzyK720BvIj7ssd42SGOeqPKWpP6xIQt05wAdCQubSLPE2H5WADj42eHJxEOj6rZmmUyphPMdnrpQm5QQ0B)fhSAwG3OeGJx6TYtsl28swmLUqJ0mmYDB6TkXXl9w5jPfBEjl(jv)suhwPweeDodJMemXioEP3kpjTyZlzXMElTz1SaVrjat2LKgWTzbrjGsjHP0fAKMHrUBtVvjMSljnGBZcIsaLsc)KQFjQdRulcIoNHrtcMyet2LKgWTzbrjGsjHn9wYWG6PwRa8NLaiS(eFjvqG9v7mynSwxcUnr44LhAIE0mdJt2LKgWTzbrjGsjz)fhq9uRva(ZsaewFIVKkiW(Q1nuVnRSAwG3OeGLVb5ActPl0indJGjgXY3GCnH1BvAtUBtVvjw(gKRj8tQ(LOoIo3sggbtmILVb5AcJaU0Iod1ZWi3TP3Qe7IPK9s2s17Gj8tQ(LOoIoNHrtcMyehV0BLNKwS5LSytVL2aNkvaBzQNDyoSwxcUnr44LhAIE0mdJRpXxsfeyFv7V4Gy)pxOrynQiDeWfAKTzfmXiwSNJuZHMOhvMCvv6XMEBwz1SaVrjalFdY1eMsxOrAgg5Un9wLy5BqUMWpP6xI6Wk1Iq9wAZQzbEJsaMSljnGBZcIsaLsctPl0indJC3MERsmzxsAa3MfeLakLe(jv)suhwPweQNHb1tTwb4plbqy9j(sQGa7R2zOElzyq9uRva(ZsaewFIVKkiW(QDgS2MvaVrjapTTAkUykzPhtPl0iTn5Un9wL4PTvtXftjl94Nu9lr1Xk1Iq9mmcMyelFdY1e20BtWeJy5BqUMWiGlTOorNBPLWADj42eHJxEOj6rZmmoGu7B(JkIPxFsG9xCWQzbEJsaw(gKRjmLUqJ0mmYDB6TkXY3GCnHFs1Ve1HvQfH6T0MvZc8gLamzxsAa3MfeLakLeMsxOrAgg5Un9wLyYUK0aUnlikbukj8tQ(LOoSsTiuVnup1AfG)SeaH1N4lPccSVADd1BPnRMf4nkb44LER8K0InVKftPl0indJC3MERsC8sVvEsAXMxYIFs1Ve1HvQfH6T0MvZkxXu6jaNK832(AmLUqJ0mmYDB6TkXI9CKAo0e9OYKRQsp(jv)suhwP2sggG3OeGN2wnfxmLS0JP0fAK2MC3MERs802QP4IPKLE8tQ(LO6yLArOEggbtmIN2wnfxmLS0Jn9mmcMyelFdY1e20BtWeJy5BqUMWiGlTOorNZWiyIrSyphPMdnrpQm5QQ0Jn9WAHCyTUeCBIWSusVd2hnZW4sV1kUeCBwAhcyF6Q0q8YdnrpY(lomTTAk9Bf9DggJHrWeJ4PTvtXftjl9ytpdJMemXioEP3kpjTyZlzXMEggnjyIrmzxsAa3MfeLakLe20dR1LGBteMLs6DW(OzggxOri0LSLnwqgvv6H16sWTjcZsj9oyF0mdJl0ie6s2YglUbyutyTUeCBIWSusVd2hnZW4cncHUKTSXs1La6H16sWTjcZsj9oyF0mdJl0ie6s2YglO()swyTUeCBIWSusVd2hnZW46t8LubSTM9xCywnjyIr8imAwvkbytVnRM99txiXucWUwJWKDpeaXW8(PlKykbyxRr4l7u)ClTz102QP0Vv0x3G1mmtBRMs)wrFDdI0MvYDB6TkXcnxtLnwgHbbojHFs1Ve1HvQfbRzy0KGjgXKDjPbCBwqucOusytpdJMemXioEP3kpjTyZlzXMElT0MvZc8gLaC8sVvEsAXMxYIP0fAKMHrUBtVvjoEP3kpjTyZlzXpP6xI6Wk1IGOZT0MvZc8gLamzxsAa3MfeLakLeMsxOrAgg5Un9wLyYUK0aUnlikbukj8tQ(LOoSsTii6ClH16sWTjcZsj9oyF0mdJx5wqLnwC0eHS)IdwnTTAk9Bf9dZzyM2wnL(TI(6gS2MvYDB6TkXcnxtLnwgHbbojHFs1Ve1HvQfbRzy0KGjgXKDjPbCBwqucOusytpdJMemXioEP3kpjTyZlzXMElT0MvZ((PlKykbyxRryYUhcGyyE)0fsmLaSR1i8LDSEUL2SAwG3OeGj7ssd42SGOeqPKWu6cnsZWi3TP3Qet2LKgWTzbrjGsjHFs1Ve1r0XS0MvZc8gLaC8sVvEsAXMxYIP0fAKMHrUBtVvjoEP3kpjTyZlzXpP6xI6i6ywcR1LGBteMLs6DW(OzggxO5AQSXYimiWjj7V4W02QP0Vv0x3q9WADj42eHzPKEhSpAMHXNCvv6lBSu9oyY(lomTTAk9Bf91nisyTUeCBIWSusVd2hnZW4JWOzvPey)fhMvtcMyepcJMvLsa20BZQPTvtPFROVUbRzyM2wnL(TI(6gePn5Un9wLyHMRPYglJWGaNKWpP6xI6Wk1IG1wcR1LGBteMLs6DW(Ozggx6TwXLGBZs7qa7txLgIxEOj6r2FXbRa(Zsa8e5nWeUxcQBW65mmcMye7IPK9s2s17GjSPNHrWeJy5BqUMWMEggbtmIj1(AEYZs)wrp20BjSwxcUnrywkP3b7JMzyC5BqUM(cc8NfK9xCqUBtVvjw(gKRPVGa)zbHLt(ZsOs8Dj420BDgefBhgZMvtBRMs)wrFDdwZWmTTAk9Bf91nuVn5Un9wLyHMRPYglJWGaNKWpP6xI6Wk1IG1mmtBRMs)wr)GiTj3TP3Qel0Cnv2yzege4Ke(jv)suhwPweS2MC3MERs8imAwvkb4Nu9lrDyLArWAlH16sWTjcZsj9oyF0mdJl9wR4sWTzPDiG9PRsdXlp0e9iyTUeCBIWSusVd2hnZW4Y3GCn9fe4pli7V4W02QP0Vv0x3GiH16sWTjcZsj9oyF0mdJl3usj4DaPlXMRsWADj42eHzPKEhSpAMHXFY7VKTeBUkHG16sWTjcZsj9oyF0mdJ7V0tQa2)Pey)fhM2wnL(TI(6gejSwxcUnrywkP3b7JMzyC5Mis(o420(loaovQa2YupBhwPoOiME0TzOBRNB985JeRfrbLk)ZlzrbLrwh5uet3Iy7EKJr(qoK31eb5NA)(aipUpKlIhV8qt0JeXH8NgPM7jnKJwvcYDdyvDaPHC5KNSecdRDKLljixenYhYhzBtX0dinKlIlxXu6japYdtPl0iTioKdwixexUIP0taEKNioKBLO21smSwyTIyv73hqAiFmi3LGBtiVDiacdRnO0oeaf6kOOPOBAGqxHUfn0vqXLGBZGYtcglOGcLUqJ0HrdGq3wh6kOqPl0iDy0GIlb3MbfP3AfxcUnlTdbckTdbkPRsbf5Un9wLOai0D9HUcku6cnshgnO4sWTzqr6TwXLGBZs7qGGs7qGs6QuqHLs6DW(Oaiack9pjxvbhe6k0TOHUcku6cnshgnacDBDORGcLUqJ0HrdGq31h6kOqPl0iDy0ai0TidDfuO0fAKomAae6ESqxbfxcUndk9l42mOqPl0iDy0ai0Tik0vqXLGBZGI)spPcy)NsqqHsxOr6WObqaeuyPKEhSpk0vOBrdDfuO0fAKomAqr(hG(ZdktBRMs)wrpK3zaYhdYzyGCbtmIN2wnfxmLS0Jn9qoddKRjbtmIJx6TYtsl28swSPhYzyGCnjyIrmzxsAa3MfeLakLe20huCj42mOi9wR4sWTzPDiqqPDiqjDvkOeV8qt0JcGq3wh6kO4sWTzqrOri0LSLnwqgvv6dku6cnshgnacDxFORGIlb3MbfHgHqxYw2yXnaJAguO0fAKomAae6wKHUckUeCBgueAecDjBzJLQlb0huO0fAKomAae6ESqxbfxcUndkcncHUKTSXcQ)VKnOqPl0iDy0ai0Tik0vqHsxOr6WObf5Fa6ppOmlKRjbtmIhHrZQsjaB6HCBqUvq(Sq(7NUqIPeGDTgHj7EiacYzyG83pDHetja7AncFjK3bYRFoKBjKBdYTcYN2wnL(TIEiVUbi3AiNHbYN2wnL(TIEiVUbixKqUni3kixUBtVvjwO5AQSXYimiWjj8tQ(LiiVdKZk1qUia5wd5mmqUMemXiMSljnGBZcIsaLscB6HCggixtcMyehV0BLNKwS5LSytpKBjKBjKBdYTcYNfYbEJsaoEP3kpjTyZlzXu6cnsd5mmqUC3MERsC8sVvEsAXMxYIFs1Veb5DGCwPgYfbix05qULqUni3kiFwih4nkbyYUK0aUnlikbukjmLUqJ0qoddKl3TP3Qet2LKgWTzbrjGsjHFs1Veb5DGCwPgYfbix05qULbfxcUndk6t8LubSTwae62oe6kOqPl0iDy0GI8pa9NhuScYN2wnL(TIEiFaYNd5mmq(02QP0Vv0d51na5wd52GCRGC5Un9wLyHMRPYglJWGaNKWpP6xIG8oqoRud5IaKBnKZWa5AsWeJyYUK0aUnlikbukjSPhYzyGCnjyIrC8sVvEsAXMxYIn9qULqULqUni3kiFwi)9txiXucWUwJWKDpeab5mmq(7NUqIPeGDTgHVeY7a5wphYTeYTb5wb5Zc5aVrjat2LKgWTzbrjGsjHP0fAKgYzyGC5Un9wLyYUK0aUnlikbukj8tQ(LiiVdKl6yqULqUni3kiFwih4nkb44LER8K0InVKftPl0inKZWa5YDB6TkXXl9w5jPfBEjl(jv)seK3bYfDmi3YGIlb3MbLk3cQSXIJMiuae62og6kOqPl0iDy0GI8pa9NhuM2wnL(TIEiVUbiV(GIlb3MbfHMRPYglJWGaNKcGq3JKqxbfkDHgPdJguK)bO)8GY02QP0Vv0d51na5ImO4sWTzqzYvvPVSXs17GPai0TOZdDfuO0fAKomAqr(hG(ZdkZc5AsWeJ4ry0SQucWMEi3gKBfKpTTAk9Bf9qEDdqU1qoddKpTTAk9Bf9qEDdqUiHCBqUC3MERsSqZ1uzJLryqGts4Nu9lrqEhiNvQHCraYTgYTmO4sWTzqzegnRkLGai0TOIg6kOqPl0iDy0GI8pa9NhuScYb(Zsa8e5nWeUxcG86gGCRNd5mmqUGjgXUykzVKTu9oycB6HCggixWeJy5BqUMWMEiNHbYfmXiMu7R5jpl9Bf9ytpKBzqXLGBZGI0BTIlb3ML2HabL2HaL0vPGs8YdnrpkacDlQ1HUcku6cnshgnOi)dq)5bf5Un9wLy5BqUM(cc8Nfewo5plHkX3LGBtVb5DgGCrX2HXGCBqUvq(02QP0Vv0d51na5wd5mmq(02QP0Vv0d51na51d52GC5Un9wLyHMRPYglJWGaNKWpP6xIG8oqoRud5IaKBnKZWa5tBRMs)wrpKpa5IeYTb5YDB6TkXcnxtLnwgHbbojHFs1Veb5DGCwPgYfbi3Ai3gKl3TP3QepcJMvLsa(jv)seK3bYzLAixeGCRHCldkUeCBguKVb5A6liWFwqbqOBrRp0vqHsxOr6WObfxcUndksV1kUeCBwAhceuAhcusxLckXlp0e9Oai0TOIm0vqHsxOr6WObf5Fa6ppOmTTAk9Bf9qEDdqUidkUeCBguKVb5A6liWFwqbqOBrhl0vqXLGBZGICtjLG3bKUeBUkfuO0fAKomAae6wuruORGIlb3MbLN8(lzlXMRsOGcLUqJ0HrdGq3IAhcDfuO0fAKomAqr(hG(ZdktBRMs)wrpKx3aKlYGIlb3Mbf)LEsfW(pLGai0TO2XqxbfkDHgPdJguK)bO)8Gc4uPcylt9SqEhiNvQdkUeCBguKBIi57GBZaiackXlp0e9OqxHUfn0vqHsxOr6WObLTpOGiqqXLGBZGIy)pxOrbfXEZqbfup1AfG)SeaH1N4lPccSVkK3zaYTgYzyGCbtmIj1(AEYZs)wrp20d52GCnjyIr8imAwvkby9wLqUnixWeJy9j(sQ0B((fry9wLqoddKJ6PwRa8NLaiS(eFjvqG9vH8odqU1qUnixWeJy5BqUMWMEi3gKlyIrS8nixtyeWLwa51b5IopOi2)s6QuqrJkshbCHgfaHUTo0vqHsxOr6WObf5Fa6ppOyfKBfKplKd8gLaS8nixtykDHgPHCBqUGjgXUykzVKTu9oycB6HCggixUBtVvj2ftj7LSLQ3bt4Nu9lrqEhi36XGClHCggi3kixWeJy5BqUMWMEiNHbYL720BvILVb5Ac)KQFjcY7a5wpgKBjKBjKBdYTcYNfYbEJsaoEP3kpjTyZlzXu6cnsd5mmqUC3MERsC8sVvEsAXMxYIFs1Veb51b5IohYTeYTb5wb5Zc5aVrjat2LKgWTzbrjGsjHP0fAKgYzyGC5Un9wLyYUK0aUnlikbukj8tQ(LiiVoix05qULqUnihCQubSLPEwiFaYNhuCj42mOGO37No1ai0D9HUcku6cnshgnOi)dq)5bfRG8zHCG3OeGJx6TYtsl28swmLUqJ0qoddKl3TP3QehV0BLNKwS5LS4Nu9lrqEhiNvQHCraYfDoKZWa5AsWeJ44LER8K0InVKfB6HClHCBqUvq(SqoWBucWKDjPbCBwqucOusykDHgPHCggixUBtVvjMSljnGBZcIsaLsc)KQFjcY7a5SsnKlcqUOZHCggixtcMyet2LKgWTzbrjGsjHn9qULqoddKJ6PwRa8NLaiS(eFjvqG9vH8odqU1bfxcUndkI9CKAo0e9OYKRQsFae6wKHUcku6cnshgnOi)dq)5bfup1AfG)SeaH1N4lPccSVkKx3aKxpKBdYTcYTcYNfYbEJsaw(gKRjmLUqJ0qoddKlyIrS8nixty9wLqUnixUBtVvjw(gKRj8tQ(LiiVdKl6Ci3siNHbYfmXiw(gKRjmc4slG8odqE9qoddKl3TP3Qe7IPK9s2s17Gj8tQ(LiiVdKl6CiNHbY1KGjgXXl9w5jPfBEjl20d5wc52GCWPsfWwM6zH8biFEqXLGBZGczxsAa3MfeLakLuae6ESqxbfkDHgPdJguK)bO)8GIy)pxOrynQiDeWfAeKBdYNfYfmXiwSNJuZHMOhvMCvv6XMEi3gKBfKBfKplKd8gLaS8nixtykDHgPHCggixUBtVvjw(gKRj8tQ(LiiVdKZk1qUia51d5wc52GCRG8zHCG3OeGj7ssd42SGOeqPKWu6cnsd5mmqUC3MERsmzxsAa3MfeLakLe(jv)seK3bYzLAixeG86HCggih1tTwb4plbqy9j(sQGa7Rc5DgG86HClHCggih1tTwb4plbqy9j(sQGa7Rc5DgGCRHCBqUvqoWBucWtBRMIlMsw6Xu6cnsd52GC5Un9wL4PTvtXftjl94Nu9lrqEDqoRud5IaKxpKZWa5cMyelFdY1e20d52GCbtmILVb5AcJaU0ciVoix05qULqULbfxcUndk6t8Lubb2xnacDlIcDfuO0fAKomAqr(hG(Zdkwb5Zc5aVrjalFdY1eMsxOrAiNHbYL720BvILVb5Ac)KQFjcY7a5SsnKlcqE9qULqUni3kiFwih4nkbyYUK0aUnlikbukjmLUqJ0qoddKl3TP3Qet2LKgWTzbrjGsjHFs1Veb5DGCwPgYfbiVEi3gKJ6PwRa8NLaiS(eFjvqG9vH86gG86HClHCBqUvq(SqoWBucWXl9w5jPfBEjlMsxOrAiNHbYL720BvIJx6TYtsl28sw8tQ(LiiVdKZk1qUia51d5wc52GCRG8zHC5kMspb4KK)22xd5mmqUC3MERsSyphPMdnrpQm5QQ0JFs1Veb5DGCwPgYTeYzyGCG3OeGN2wnfxmLS0JP0fAKgYTb5YDB6TkXtBRMIlMsw6XpP6xIG86GCwPgYfbiVEiNHbYfmXiEAB1uCXuYsp20d5mmqUGjgXY3GCnHn9qUnixWeJy5BqUMWiGlTaYRdYfDoKZWa5cMyel2ZrQ5qt0JktUQk9ytFqXLGBZGcGu7B(JkIPxFsqaeabf5Un9wLOqxHUfn0vqHsxOr6WObf5Fa6ppOyfKlyIrSqBxDZGa4NCjaYzyGCbtmIDXuYEjBP6DWe20d52GCbtmIDXuYEjBP6DWe(jv)seK3bYf1oc5mmqUGjgXY3GCnHn9qUnixWeJy5BqUMWpP6xIG86GCRhdYTmO4sWTzqPFb3MbqOBRdDfuO0fAKomAqr(hG(ZdkOEQ1ka)zjac3o2jaQmcJMvLsaK3zaYTgYzyGCRG8zH83pDHetja7Anct29qaeKZWa5VF6cjMsa21Ae(siVdKBhgdYTmO4sWTzqPDStauzegnRkLGai0D9HUcku6cnshgnOi)dq)5bfbtmIDXuYEjBP6DWe20d5mmqUGjgXY3GCnHn9qUnixWeJy5BqUMWiGlTaYhGCrNhuCj42mOeVNeA7QdGq3Im0vqXLGBZGcA6OMUSXIykzjpLuqHsxOr6WObqO7XcDfuO0fAKomAqjDvkO8UDQnPfOIWXwEsxemaWMbfxcUndkVBNAtAbQiCSLN0fbdaSzae6wef6kOqPl0iDy0GIlb3Mbfhnj2tcvE3o3Vi33Bbf5Fa6ppOOjbtmIF3o3Vi33BfnjyIrSERsiNHbYTcYfmXi2ftj7LSLQ3bt4Nu9lrqENbi365qoddKlyIrS8nixtyeWLwa5dqUOZHCBqUGjgXY3GCnHFs1Veb5DGCrhdYTeYTb5wb5YDB6TkXSg)1NNLnwC7K(fmHFs1Veb5DG8rYCiNHbYbNkvaBrFeKxhKx)CiNHbYNfYjeIsjHLBQPer6s7IuCFjHv9rSpKBzqjDvkO4OjXEsOY725(f5(ElacDBhcDfuO0fAKomAqXLGBZGYiiuzARA0huK)bO)8GIGjgXUykzVKTu9oycB6HCggixWeJy5BqUMWMEi3gKlyIrS8nixtyeWLwa5dqUOZdkPRsbLrqOY0w1OpacDBhdDfuO0fAKomAqXLGBZGI4ZBLnw88uDaPlcTD1bf5Fa6ppOyfKlyIrSlMs2lzlvVdMWMEiNHbYfmXiw(gKRjSPhYTb5cMyelFdY1e(jv)seKxhKlQDeYTeYzyGCRGC5Un9wLyxmLSxYwQEhmHFs1Veb5DG86Nd5mmqUC3MERsS8nixt4Nu9lrqEhiV(5qULbL0vPGI4ZBLnw88uDaPlcTD1bqO7rsORGcLUqJ0HrdkUeCBgu07QIkrZxtqr(hG(ZdkcMye7IPK9s2s17GjSPhYzyGCbtmILVb5AcB6HCBqUGjgXY3GCnHFs1Veb51b5IAhdkPRsbf9UQOs081eaHUfDEORGcLUqJ0HrdkUeCBguy9gj9wJEurGClckY)a0FEqrWeJyxmLSxYwQEhmHn9qoddKlyIrS8nixtytpKBdYfmXiw(gKRj8tQ(LiiVoix0XckPRsbfwVrsV1Ohvei3Iai0TOIg6kOqPl0iDy0GIlb3MbfHAy3Kkcev8MQNUmOi)dq)5bfbtmIDXuYEjBP6DWe20d5mmqUGjgXY3GCnHn9bL0vPGIqnSBsfbIkEt1txgaHUf16qxbfkDHgPdJguCj42mOOspzbyYrLONSbf5Fa6ppOyfKplK)(PlKykbyxRryYUhcGGCggi)9txiXucWUwJWxc5DGCrhdYTeYzyGCup1AfG)SeaH1N4lPccSVkK3zaYToOKUkfuuPNSam5Os0t2ai0TO1h6kOqPl0iDy0GIlb3MbL(Mj10lq(RrLyZrweuK)bO)8GIGjgXUykzVKTu9oycB6HCggixWeJy5BqUMWMEi3gKlyIrS8nixtyeWLwa5DgGCrNd5mmqUC3MERsSlMs2lzlvVdMWpP6xIG8oqUihdYzyG8zHCbtmILVb5AcB6HCBqUC3MERsS8nixt4Nu9lrqEhixKJfusxLck9ntQPxG8xJkXMJSiacDlQidDfuO0fAKomAqXLGBZGIa9i6TGEuzeMryckY)a0FEqrWeJyxmLSxYwQEhmHn9qoddKlyIrS8nixtytpKBdYfmXiw(gKRjmc4slG8odqUOZHCggixUBtVvj2ftj7LSLQ3bt4Nu9lrqEhixKJb5mmq(SqUGjgXY3GCnHn9qUnixUBtVvjw(gKRj8tQ(LiiVdKlYXckPRsbfb6r0Bb9OYimJWeaHUfDSqxbfkDHgPdJguCj42mOqPUriubCPeyEQSXs8Dj420BL(TI(GI8pa9NhuemXi2ftj7LSLQ3btytpKZWa5cMyelFdY1e20d52GCbtmILVb5AcJaU0ciVZaKl6CiNHbYL720BvIDXuYEjBP6DWe(jv)seK3bYf5yqoddKl3TP3QelFdY1e(jv)seK3bYf5ybL0vPGcL6gHqfWLsG5PYglX3LGBtVv63k6dGq3IkIcDfuO0fAKomAqXLGBZGsp5FROpX0JkYvT3rOGI8pa9NhuemXi2ftj7LSLQ3btytpKZWa5cMyelFdY1e20d52GCbtmILVb5AcJaU0ciVZaKl68Gs6QuqPN8Vv0Ny6rf5Q27iuae6wu7qORGcLUqJ0HrdkUeCBguI3JafvhqOcQVg2MJqbf5Fa6ppOiyIrSlMs2lzlvVdMWMEiNHbYfmXiw(gKRjSPhYTb5cMyelFdY1e(jv)seKx3aKl6ybL0vPGs8EeOO6acvq91W2CekacDlQDm0vqHsxOr6WObfxcUndkY9FtpG0f2MRphSpQOsAV1UndkY)a0FEqrWeJyxmLSxYwQEhmHn9qoddKlyIrS8nixtytpKBdYfmXiw(gKRj8tQ(LiiVoi365bL0vPGIC)30diDHT56Zb7JkQK2BTBZai0TOJKqxbfkDHgPdJguCj42mOi3)n9asxyBU(CW(OIGRzPGI8pa9NhuemXi2ftj7LSLQ3btytpKZWa5cMyelFdY1e20d52GCbtmILVb5Ac)KQFjcYRdYfDSGs6QuqrU)B6bKUW2C95G9rfbxZsbqOBRNh6kOqPl0iDy0Gs6QuqP6pW0LSfeXQsjOSXI(jeWzDWuqXLGBZGs1FGPlzliIvLsqzJf9tiGZ6GPai0T1Ig6kOqPl0iDy0GIlb3Mbf00kTq4a0JkrpzdkY)a0FEqrWeJyxmLSxYwQEhmHn9qoddKlyIrS8nixtytFqjDvkOGMwPfchGEuj6jBae62ARdDfuO0fAKomAqjDvkO0oXxYw2RvKEEia9bfxcUndkTt8LSL9AfPNhcqFae6266dDfuO0fAKomAqXLGBZGYFaJ3krYbt0x2yXKjBXTiOi)dq)5bfbtmIDXuYEjBP6DWe20d5mmqUGjgXY3GCnHn9qUnixWeJy5BqUMWiGlTaYhGCrNd5mmqUC3MERsSlMs2lzlvVdMWpP6xIG8odqE9ZHCggixUBtVvjw(gKRj8tQ(LiiVZaKx)8Gs6Quq5pGXBLi5Gj6lBSyYKT4weaHUTwKHUcku6cnshgnOKUkfuEsDbuH1CApLurtIpjfuCj42mO8K6cOcR50EkPIMeFskacDB9yHUcku6cnshgnOKUkfueFERSXccSVkkO4sWTzqr85TYgliW(QOai0T1IOqxbfkDHgPdJguCj42mOunDFR6swuPVzuDwkOi)dq)5bfbtmIDXuYEjBP6DWe20d5mmqUGjgXY3GCnHn9qUnixWeJy5BqUMWpP6xIG86gGCRNhusxLckvt33QUKfv6BgvNLcGq3wBhcDfuO0fAKomAqXLGBZGI(jxxyBU(CW(OIGRzPGI8pa9NhuemXi2ftj7LSLQ3btytpKZWa5cMyelFdY1e20d52GCbtmILVb5Ac)KQFjcYRBaYTEEqjDvkOOFY1f2MRphSpQi4AwkacDBTDm0vqHsxOr6WObfxcUndk6NCDXr937javujT3A3Mbf5Fa6ppOiyIrSlMs2lzlvVdMWMEiNHbYfmXiw(gKRjSPhYTb5cMyelFdY1e(jv)seKx3aKB98Gs6Quqr)KRloQ)EpbOIkP9w72macDB9ij0vqHsxOr6WObfxcUndkS)MSOs)FQER8olfuK)bO)8GYSqUGjgXUykzVKTu9oycB6HCBq(SqUGjgXY3GCnHn9bL0vPGc7VjlQ0)NQ3kVZsbqO76Nh6kOqPl0iDy0GIlb3Mbf0LhcqFHT56Zb7JkcUMLckY)a0FEqrWeJyxmLSxYwQEhmHn9qoddKlyIrS8nixtytpKBdYfmXiw(gKRj8tQ(LiiVUbix0XckPRsbf0LhcqFHT56Zb7JkcUMLcGq31lAORGcLUqJ0HrdkUeCBguqxEia9f2MRphSpQOsAV1UndkY)a0FEqrWeJyxmLSxYwQEhmHn9qoddKlyIrS8nixtytpKBdYfmXiw(gKRj8tQ(LiiVUbi365bL0vPGc6YdbOVW2C95G9rfvs7T2Tzae6UERdDfuO0fAKomAqXLGBZGIBNOj)DujUjOSXs)wrFqr(hG(ZdkZc5aVrjalFdY1eMsxOrAi3gKl3TP3Qe7IPK9s2s17Gj8tQ(LiiVoiFmiNHbYbEJsaw(gKRjmLUqJ0qUnixUBtVvjw(gKRj8tQ(LiiVoiFmi3gKdovcY7a5IohYzyG8PTvtPFROhY7ma51d52GCWPsqEDqUOZHCBqoWBucWvUfuzJfhnrimLUqJ0bL0vPGIBNOj)DujUjOSXs)wrFae6U(6dDfuO0fAKomAqXLGBZGI4dDBw2yrtQhIckY)a0FEqrWeJyxmLSxYwQEhmHn9qoddKlyIrS8nixtytpKBdYfmXiw(gKRjmc4slG8bix05qoddKl3TP3Qe7IPK9s2s17Gj8tQ(LiiVZaKx)CiNHbYL720BvILVb5Ac)KQFjcY7ma51ppOKUkfueFOBZYglAs9quae6UErg6kOqPl0iDy0GIlb3Mbfhnj2tcvE3o3Vi33Bbf5Fa6ppOOjbtmIF3o3Vi33BfnjyIrSERsiNHbYTcYfmXi2ftj7LSLQ3bt4Nu9lrqENbi365qoddKlyIrS8nixtyeWLwa5dqUOZHCBqUGjgXY3GCnHFs1Veb5DGCrhdYTeYTb5wb5YDB6TkXSg)1NNLnwC7K(fmHFs1Veb5DG8rYCiNHbYbNkvaBrFeKxhKx)CiNHbYNfYjeIsjHLBQPer6s7IuCFjHv9rSpKBzqjDvkO4OjXEsOY725(f5(ElacDx)yHUcku6cnshgnO4sWTzqXICbLnw8uEuckrZxtqr(hG(ZdkcMye7IPK9s2s17GjSPhYzyGCbtmILVb5AcB6HCBqUGjgXY3GCnHraxAbK3zaYfDoKZWa5YDB6TkXUykzVKTu9oyc)KQFjcY7a51phYzyG8zHCbtmILVb5AcB6HCBqUC3MERsS8nixt4Nu9lrqEhiV(5bL0vPGIf5ckBS4P8OeuIMVMai0D9IOqxbfkDHgPdJguK)bO)8GYSqUGjgXUykzVKTu9oycB6HCBq(SqUGjgXY3GCnHn9bfxcUndkoAIYYK3ABvae6UE7qORGcLUqJ0HrdkY)a0FEqXkiFAB1u63k6H8odqUiHCBqo4ujiVoiFmiNHbYN2wnL(TIEiVZaKxpKBdYbNkb5DG8XGCggih4nkb4PTvtXftjl9ykDHgPHCBqUC3MERs802QP4IPKLE8tQ(LiiFaYNd5wc52GCWPsfWwM6zH8biFEqXLGBZGIlMs2lzlvVdMcGq31BhdDfuO0fAKomAqr(hG(Zdkwb5tBRMs)wrpK3zaYfjKBdYbNkb51b5Jb5mmq(02QP0Vv0d5DgG86HCBqo4ujiVdKpgKZWa5aVrjapTTAkUykzPhtPl0inKBdYL720BvIN2wnfxmLS0JFs1Veb5dq(Ci3si3gKdovQa2YuplKpa5ZdkUeCBguKVb5AkacDx)ij0vqHsxOr6WObf5Fa6ppOaovQa2YuplKpa5ZHCBqUvqUvqUGjgXUykzVKTu9oycB6HCggixWeJy5BqUMWMEi3siNHbYTcYfmXi2ftj7LSLQ3bty9wLqUnixUBtVvj2ftj7LSLQ3bt4Nu9lrqEhixKZHCggixWeJy5BqUMW6TkHCBqUC3MERsS8nixt4Nu9lrqEhixKZHClHCldkUeCBguM2wnfxmLS0haHUf58qxbfkDHgPdJguK)bO)8GY02QP0Vv0d5DgG86HCBqUC3MERsSlMs2lzlvVdMWpP6xIG8oqoRud52GCWPsfWwM6zH8biFoKBdYTcYNfYbEJsagrV3pDQykDHgPHCggixWeJye9E)0PIn9qULbfxcUndkXl9w5jPfBEjBae6wKIg6kOqPl0iDy0GI8pa9NhuaNkb51na5wd5mmqUGjgXpjTOriujUVKWM(GIlb3MbfWevmPWAsDjUVKcGq3I06qxbfkDHgPdJguK)bO)8GIGjgXUykzVKTu9oycB6HCggixWeJy5BqUMWMEi3gKlyIrS8nixtyeWLwa5dqUOZdkUeCBgueA7QlBSaMOcLKAnbqOBrwFORGcLUqJ0HrdkY)a0FEqzwih4nkby5BqUMWu6cnsd52GCRGC5Un9wLyxmLSxYwQEhmHFs1Veb51b5Jb52G8PTvtPFROhY7ma51d5mmqUC3MERsSlMs2lzlvVdMWpP6xIG8odqUihdYTeYzyGCRGCG3OeGLVb5ActPl0inKBdYL720BvILVb5Ac)KQFjcYRdYzLAi3gKpTTAk9Bf9qENbixKqoddKl3TP3QelFdY1e(jv)seK3zaYf5yqULbfxcUndkSg)1NNLnwC7K(fmfaHUfPidDfuO0fAKomAqr(hG(ZdkYDB6TkXUykzVKTu9oyc)KQFjcYRdYzLAi3gKpTTAk9Bf9qENbiVEiNHbYbEJsaw(gKRjmLUqJ0qUnixUBtVvjw(gKRj8tQ(LiiVoiNvQHCBq(02QP0Vv0d5DgGCrc5mmqUC3MERsSlMs2lzlvVdMWpP6xIG8odqUihdYzyGC5Un9wLy5BqUMWpP6xIG8odqUihlO4sWTzqPA)MwmDz5j0MEkPai0Tihl0vqHsxOr6WObf5Fa6ppOyfKplK)(PlKykbyxRryYUhcGGCggi)9txiXucWUwJWxc5DG86Nd5mmqoQNATcWFwcGW6t8Lubb2xfY7ma5wd5wc52G8zHCRGCbtmIDXuYEjBP6DWe20d5mmqUGjgXY3GCnHn9qULqUni3kixUBtVvjwO5AQSXYimiWjj8tQ(LiiVdKZk1qUia51d52GC5Un9wL4ry0SQucWpP6xIG8oqoRud5IaKxpKBzqXLGBZGsCLgePlUDs)bOIa5QbqOBrkIcDfuO0fAKomAqr(hG(Zdkwb5cMye7IPK9s2s17GjSPhYzyGCbtmILVb5AcB6HCBqUGjgXY3GCnHraxAbKpa5IohYTeYTb5tBRMs)wrpKx3aKxFqXLGBZGIkPUFnLnwAg5Pl6NCvuae6wK2HqxbfkDHgPdJguK)bO)8GIvq(Sq(7NUqIPeGDTgHj7EiacYzyG83pDHetja7AncFjK3bYRFoKZWa5OEQ1ka)zjacRpXxsfeyFviVZaKBnKBzqXLGBZGsV5VynxYweAoceabqaeuCdyA)GIYi1qnhSFaeaHa]] )

    
    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_focused_resolve",

        package = "Retribution",
    } )


    spec:RegisterSetting( "check_wake_range", false, {
        name = "Check |T1112939:0|t Wake of Ashes Range",
        desc = "If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } ) 


end
