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


    spec:RegisterPack( "Retribution", 20200910, [[dqK7QaqibvEKGQ0Mqv(KsHyuuKoffLvPuQxjvPzPuYUi5xsvmmLQoMuvltPYZGQyAOQQRPuW2qvf(gQQ04eufoNsHY6euvzEuuDpLyFcYbfuvyHcvUOGQs9rbvLCsLcvRevLzkOQODkOmubvvTuLcPNIktLI4QcQI8vbvrTxI(Rugmkhw0If4XqMmPUmyZuYNPuJwjDAvTAOk9AHQMnHBlv2nv)wYWHkhhvv0Yr65iMUIRdLTlu(ofgVsrNhQQ5lK9RYY(stKC6Cazy72VB)(nw)9Q(8JDBap4rYn4JdKC4su8Pni58SdKCBuyOFa28Ll5WL4lQulnrYrkmkcKCsUaSxmBCxgi505aYW2TF3(9BS(7v95h72aE2j5i4aKmm(DVKB91AWLbsonqqsUW7X2OWq)aS5l)yH)Pi1VF8fEpghGBGUaGEm(XwhB3(D7LC4OL1lajx49yBuyOFa28LFSW)uK63p(cVhJdWnqxaqpg)yRJTB)U9hFhFH3Jf(EtaHnG(yqmGI)XMVdo2Schlrtrp2towglFrgia1XxIMVCYsInvlNjrXF8LO5lN07spuialE44lrZxoP3LEqPq0s08L3epz2YZoybvLqxgo54lrZxoP3LEqPq0s08L3epz2YZoyXgCGMtrjhFhFjA(YjkuvcDz4KEx6r82RdPHxmTDh4ZwV1cbhieTjP2WquI3EDin8IPT7aFcTSlkY0WrZx3GyGpQuRjkyZNmKOiA(6ged8rLAnr9Ei(DdMD8LO5lNOqvj0LHt6DPhRNcbIQ0B9wlbywwQmg42VB3mO5SQWWfffGzzPqumsQbfgoEbywwkefJKAqrMef)s)9hFjA(YjkuvcDz4KEx6HS(Gq3kRwmWTH0rWXxIMVCIcvLqxgoP3LEYyGB)UDZGMZ6wV1YAjWVHRmaAOLnWBsb4Jc2eqyZxEJa(aocuGNbcqZBsb4JY69u0Oak(YF3wbEgiaDu0AjWVHRmaAOf8WlCMoPa8rbBciS5lVraFahbkWZabO5nPa8rz9EkAuafF5VBRapdeG2SJVenF5efQkHUmCsVl9GOyKudB9wlRLa)gUYaOHw4Fu0AjWVHRmaAOf8WB(oW8(7p(s08LtuOQe6YWj9U0tswbVTMcrzC8LO5lNOqvj0LHt6DPNabqiVB3kRgbRRdOhFjA(YjkuvcDz4KEx6jqaeY72TYQLydwNF8LO5lNOqvj0LHt6DPNabqiVB3kRMX7dqp(s08LtuOQe6YWj9U0tGaiK3TBLvJGJ(U9XxIMVCIcvLqxgoP3LEILo)e7jRaL0wZUoGE8LO5lNOqvj0LHt6DPh9h7DOnLqC8LO5lNOqvj0LHt6DPN1sGFlJbUnqp(s08LtuOQe6YWj9U0dbOjU1VBR3AX0WnPa8rHOyKudkWZabO5HQsOldxLXa3(D7MbnNvff6Y3jH6VpkAsb4JcrXiPguGNbcqZlaZYsHOyKudkDz48qvj0LHRqumsQbff6Y3jH6VpkkaZYsHOyKudkYKO4dTWVMD8LO5lNOqvj0LHt6DPhR3trJcO4l)D7TERftd3KcWhfIIrsnOapdeGMhQkHUmCvgdC73TBg0CwvuOlFNeQ)(OOjfGpkefJKAqbEgianVamllfIIrsnO0LHZdvLqxgUcrXiPguuOlFNeQ)(OOamllfIIrsnOitIIp0s)9MXlCtkaFuWMacB(YBeWhWrGc8mqa6OOjfGpkytaHnF5nc4d4iqbEgianpneGzzPGnbe28L3iGpGJafgUJVJVenF5eL17pzfOKLyj9ZabSLNDWIX72KgUQeBflfyWs4Mua(OqumsQbf4zGa08qvj0LHRYyGB)UDZGMZQIcD57Kq2i924jkcvLqxgUcrXiPguuOlFNeYgP3gphFjA(YjkR3FYkqj9U0tSK(zGa2YZoyrtAOKmzGa2kwkWGfcoqiAtsTHHO0FS3HgzkAxOLDrrbywwkOdh(ui9gUYaOkmC8cWSSuzmWTF3UzqZzTLytHO)O0LHF8LO5lNOSE)jRaL07spXsNFI9KvGsARzxhq36TwIL0pdeGY4DBsdxvcEAiaZYsHxmTDh4JsxgEu0KcWhL17POrbu8L)UTc8mqaAEOQe6YWvwVNIgfqXx(72kk0LVtc1F)XxIMVCIY69NScusVl9aBciS5lVraFahbB9wleCGq0MKAddrP)yVdnYu0oZx2XZ0WnPa8rHOyKudkWZabO5HQsOldxLXa3(D7MbnNvff6Y3jH6VpkAsb4JcrXiPguGNbcqZlaZYsHOyKudkDz48qvj0LHRqumsQbff6Y3jH6VpkkaZYsHOyKudkYKO4dTWVMD8LO5lNOSE)jRaL07sp6p27qJmfTBR3Ajws)mqaknPHsYKbcGxSK(zGaugVBtA4QsWZutd3KcWhfSjGWMV8gb8bCeOapdeGokYucoqiAtsTHHO0FS3HgzkAxOLDrrOQe6YWvWMacB(YBeWhWrGIcD57Kq2i927mZSOitrvj0LHRYyGB)UDZGMZQIcD57Kq2i924HhQkHUmCvgdC73TBg0CwvuOlFNyE)9rrOQe6YWvikgj1GIcD57Kq2i924HhQkHUmCfIIrsnOOqx(oX8(7JIcWSSuikgj1GcdhVamllfIIrsnOitII38(7nZSJVenF5eL17pzfOKEx6zGoCIKsAXaQ(rZwV1sSK(zGaugVBtA4QsWZ0WnPa8rbBciS5lVraFahbkWZabOJIqvj0LHRGnbe28L3iGpGJaff6Y3jHSr6T3ffHQsOldxLXa3(D7MbnNvff6Y3jHSr6TXdpuvcDz4Qmg42VB3mO5SQOqx(oX8(7JIqvj0LHRqumsQbff6Y3jHSr6TXdpuvcDz4kefJKAqrHU8DI593hffGzzPqumsQbfgoEbywwkefJKAqrMefV593B2X3XxIMVCIYgCGMtrj9U0dkfIwIMV8M4jZwE2blwV)KvGs26Twwlb(nCLbqdTSHOOamllvh0vu8BLvtGHEDttHSJOWWfffGzzPiamRVB3OPnOWWD8LO5lNOSbhO5uusVl9yKXdTYQLKvGS1BTyA4O5RBqmWhvQ1efS5tgsuenFDdIb(OsTMOEpu)nefrWbcrBsQnmeLrgp0kRwswbsOLDMXZ01sGFdxzauZx2ffTwc8B4kdGU0NhQkHUmCvGi1qRSA4fJmpcuuOlFNeYgPnJNPOQe6YWvzmWTF3UzqZzvrHU8DsO(7JIMua(OqumsQbf4zGa08qvj0LHRqumsQbff6Y3jH6V3mEHBsb4Jc2eqyZxEJa(aocuGNbcqhfPHamllfSjGWMV8gb8bCeOWWXBTe43Wvga18LDhFjA(YjkBWbAofL07spRzxhqBLvZGMZ6wV1YAjWVHRmaQ5l8)4lrZxorzdoqZPOKEx6jqKAOvwn8IrMhbB9wlRLa)gUYaOMVSlkY01sGFdxza0f8WZuuvcDz4Q1SRdOTYQzqZzvrHU8DsiBKE7DMz2XxIMVCIYgCGMtrj9U0J(J9o0Msi26TwmDTe43Wvga18LDrrMUwc8B4kdGA(c)5zkQkHUmCvGi1qRSA4fJmpcuuOlFNeYgP3ENzMzgpneGzzPWlM2Ud8rPldpkAsb4Jc2eqyZxEJa(aocuGNbcqZdvLqxgUc2eqyZxEJa(aocuuOlFNeQ)EEMUwc8B4kdGA(c)5zkQkHUmCvGi1qRSA4fJmpcuuOlFNeYgP3ENzMD8LO5lNOSbhO5uusVl9GxmTDh4ZwV1YAjWVHRmaQ5l7IImDTe43Wvga18f(ZZuuvcDz4QarQHwz1WlgzEeOOqx(ojKnsV9oZm74lrZxorzdoqZPOKEx6bLcrlrZxEt8Kzlp7GfR3FYkqjB9wltkaFuRzxhqBLvZGMZQc8mqaAEtsTHrTcPywv4qJ5l72hffGzzPYyGB)UDZGMZQcdxuuaMLLcrXiPguy4o(s08Ltu2Gd0CkkP3LEqumsQbAJm0pEyR3AbvLqxgUcrXiPgOnYq)4bfAnP2aPzrt08LNIql9v87g4z6AjWVHRmaQ5l7IIwlb(nCLbqnFbp8qvj0LHRcePgALvdVyK5rGIcD57Kq2i927IIwlb(nCLbqx4ppuvcDz4QarQHwz1WlgzEeOOqx(ojKnsV9oEOQe6YWv4ftB3b(OOqx(ojKnsV9oEOQe6YWvOYjaIMZxUIcD57Kq2i927m74lrZxorzdoqZPOKEx6bLcrlrZxEt8Kzlp7GfR3FYkqjhFjA(YjkBWbAofL07spOYjaIMZx(wV1cbhieTjP2WquOYjaIMZxEOL(B44lrZxorzdoqZPOKEx6brXiPgOnYq)4HTERL1sGFdxzauZx4)XxIMVCIYgCGMtrj9U0tsrPdTPOuWNTERL1sGFdxzauZx4)XxIMVCIYgCGMtrj9U0dQCcGO58LV1BTmFh0MQTIZoKnsl5IbuYxUmSD73TFF4Xo(vYzKu)DBIKl8C4JnAyB8WcFf(DSJzYkCSVdxrNJzv0JTr0GvIjMnYXOa)e7PG(yKQdowInvxoG(yO10TbI64l857WX6h(DSWtobdhUIoG(yjA(Yp2gjXMQLZKO43iQJVJVnEhUIoG(y8)yjA(YpM4jdrD8j5epzistKCAWkXeJ0ezy9LMi5s08Ll5sSPA5mjkEjh4zGa0Y4KJmSDstKCjA(YLCuialEqYbEgiaTmo5iddpstKCGNbcqlJtYLO5lxYHsHOLO5lVjEYi5epzAE2bsouvcDz4e5idJ)stKCGNbcqlJtYLO5lxYHsHOLO5lVjEYi5epzAE2bsoBWbAofLih5i5Wrbu1fKJ0e5i5qvj0LHtKMidRV0ejh4zGa0Y4KCi6pa9tjhbhieTjP2WquI3EDin8IPT7aFowOLJT7yrrhZ0JfUJrZx3GyGpQuRjkyZNmKJffDmA(6ged8rLAnr9(XcDm(DdhZmjxIMVCjN4TxhsdVyA7oWh5idBN0ejh4zGa0Y4KCi6pa9tjxaMLLkJbU972ndAoRkmChlk6ybywwkefJKAqHH7y8owaMLLcrXiPguKjrXFSLJ1FVKlrZxUKZ6PqGOkTCKHHhPjsUenF5soY6dcDRSAXa3gshbsoWZabOLXjhzy8xAIKd8mqaAzCsoe9hG(PKBTe43Wvga9yHwo2gogVJnPa8rbBciS5lVraFahbkWZabOpgVJnPa8rz9EkAuafF5VBRapdeG(yrrhBTe43Wvga9yHwogEogVJfUJz6XMua(OGnbe28L3iGpGJaf4zGa0hJ3XMua(OSEpfnkGIV83TvGNbcqFmZKCjA(YLCzmWTF3UzqZzvoYW2G0ejh4zGa0Y4KCi6pa9tj3AjWVHRma6XcTCm(FSOOJTwc8B4kdGESqlhdphJ3XMVdoM5hR)EjxIMVCjhIIrsnihzy8dPjsUenF5sUKScEBnfIYqYbEgiaTmo5idJFLMi5s08Ll5ceaH8UDRSAeSUoGk5apdeGwgNCKHfEinrYLO5lxYfiac5D7wz1sSbRZLCGNbcqlJtoYW2ystKCjA(YLCbcGqE3UvwnJ3hGk5apdeGwgNCKH1FV0ejxIMVCjxGaiK3TBLvJGJ(UTKd8mqaAzCYrgw)(stKCjA(YLCXsNFI9KvGsARzxhqLCGNbcqlJtoYW6VtAIKlrZxUKt)XEhAtjesoWZabOLXjhzy9XJ0ejxIMVCj3AjWVLXa3gOsoWZabOLXjhzy95V0ejh4zGa0Y4KCi6pa9tjNPhlChBsb4JcrXiPguGNbcqFmEhdvLqxgUkJbU972ndAoRkk0LVtowOJ1F)XIIo2KcWhfIIrsnOapdeG(y8owaMLLcrXiPgu6YWpgVJHQsOldxHOyKudkk0LVtowOJ1F)XIIowaMLLcrXiPguKjrXFSqlhJFpMzsUenF5socqtCRFNCKH1FdstKCGNbcqlJtYHO)a0pLCMESWDSjfGpkefJKAqbEgia9X4DmuvcDz4Qmg42VB3mO5SQOqx(o5yHow)9hlk6ytkaFuikgj1Gc8mqa6JX7ybywwkefJKAqPld)y8ogQkHUmCfIIrsnOOqx(o5yHow)9hlk6ybywwkefJKAqrMef)XcTCS(7pMzhJ3Xc3XMua(OGnbe28L3iGpGJaf4zGa0hlk6ytkaFuWMacB(YBeWhWrGc8mqa6JX7yAiaZYsbBciS5lVraFahbkmCsUenF5soR3trJcO4l)DB5ihjN17pzfOePjYW6lnrYbEgiaTmojxHtYrGrYLO5lxYflPFgiajxSuGbsUWDSjfGpkefJKAqbEgia9X4DmuvcDz4Qmg42VB3mO5SQOqx(o5yHoMnsFSTpgEowu0Xqvj0LHRqumsQbff6Y3jhl0XSr6JT9XWJKlwsBE2bsoJ3TjnCvjKJmSDstKCGNbcqlJtYv4KCeyKCjA(YLCXs6NbcqYflfyGKJGdeI2KuByik9h7DOrMI2DSqlhB3XIIowaMLLc6WHpfsVHRmaQcd3X4DSamllvgdC73TBg0CwBj2ui6pkDz4sUyjT5zhi50Kgkjtgia5iddpstKCGNbcqlJtYHO)a0pLCXs6Nbcqz8UnPHRkXX4DmneGzzPWlM2Ud8rPld)yrrhBsb4JY69u0Oak(YF3wbEgia9X4DmuvcDz4kR3trJcO4l)DBff6Y3jhl0X6VxYLO5lxYflD(j2twbkPTMDDavoYW4V0ejh4zGa0Y4KCi6pa9tjhbhieTjP2Wqu6p27qJmfT7yMVCSDhJ3Xm9yH7ytkaFuikgj1Gc8mqa6JX7yOQe6YWvzmWTF3UzqZzvrHU8DYXcDS(7pwu0XMua(OqumsQbf4zGa0hJ3XcWSSuikgj1Gsxg(X4DmuvcDz4kefJKAqrHU8DYXcDS(7pwu0XcWSSuikgj1GImjk(JfA5y87XmtYLO5lxYbBciS5lVraFahbYrg2gKMi5apdeGwgNKdr)bOFk5IL0pdeGstAOKmzGaogVJflPFgiaLX72KgUQehJ3Xm9yMESWDSjfGpkytaHnF5nc4d4iqbEgia9XIIoMPhJGdeI2KuByik9h7DOrMI2DSqlhB3XIIogQkHUmCfSjGWMV8gb8bCeOOqx(o5yHoMnsFSTp2UJz2Xm7yrrhZ0JHQsOldxLXa3(D7MbnNvff6Y3jhl0XSr6JT9XWZX4DmuvcDz4Qmg42VB3mO5SQOqx(o5yMFS(7pwu0Xqvj0LHRqumsQbff6Y3jhl0XSr6JT9XWZX4DmuvcDz4kefJKAqrHU8DYXm)y93FSOOJfGzzPqumsQbfgUJX7ybywwkefJKAqrMef)Xm)y93FmZoMzsUenF5so9h7DOrMI2jhzy8dPjsoWZabOLXj5q0Fa6NsUyj9ZabOmE3M0WvL4y8oMPhlChBsb4Jc2eqyZxEJa(aocuGNbcqFSOOJHQsOldxbBciS5lVraFahbkk0LVtowOJzJ0hB7JT7yrrhdvLqxgUkJbU972ndAoRkk0LVtowOJzJ0hB7JHNJX7yOQe6YWvzmWTF3UzqZzvrHU8DYXm)y93FSOOJHQsOldxHOyKudkk0LVtowOJzJ0hB7JHNJX7yOQe6YWvikgj1GIcD57KJz(X6V)yrrhlaZYsHOyKudkmChJ3XcWSSuikgj1GImjk(Jz(X6V)yMj5s08Ll5gOdNiPKwmGQF0ih5i5SbhO5uuI0ezy9LMi5apdeGwgNKdr)bOFk5wlb(nCLbqpwOLJTHJffDSamllvh0vu8BLvtGHEDttHSJOWWDSOOJfGzzPiamRVB3OPnOWWj5s08Ll5qPq0s08L3epzKCINmnp7ajN17pzfOe5idBN0ejh4zGa0Y4KCi6pa9tjNPhlChJMVUbXaFuPwtuWMpzihlk6y081nig4Jk1AI69Jf6y93WXIIogbhieTjP2Wqugz8qRSAjzfihl0YX2DmZogVJz6Xwlb(nCLbqpM5lhB3XIIo2AjWVHRma6Xwow)JX7yOQe6YWvbIudTYQHxmY8iqrHU8DYXcDmBK(yMDmEhZ0JHQsOldxLXa3(D7MbnNvff6Y3jhl0X6V)yrrhBsb4JcrXiPguGNbcqFmEhdvLqxgUcrXiPguuOlFNCSqhR)(Jz2X4DSWDSjfGpkytaHnF5nc4d4iqbEgia9XIIoMgcWSSuWMacB(YBeWhWrGcd3X4DS1sGFdxza0Jz(YX2j5s08Ll5mY4Hwz1sYkqKJmm8inrYbEgiaTmojhI(dq)uYTwc8B4kdGEmZxog)LCjA(YLCRzxhqBLvZGMZQCKHXFPjsoWZabOLXj5q0Fa6NsU1sGFdxza0Jz(YX2DSOOJz6Xwlb(nCLbqp2YXWZX4DmtpgQkHUmC1A21b0wz1mO5SQOqx(o5yHoMnsFSTp2UJz2XmtYLO5lxYfisn0kRgEXiZJa5idBdstKCGNbcqlJtYHO)a0pLCMES1sGFdxza0Jz(YX2DSOOJz6Xwlb(nCLbqpM5lhJ)hJ3Xm9yOQe6YWvbIudTYQHxmY8iqrHU8DYXcDmBK(yBFSDhZSJz2Xm7y8oMgcWSSu4ftB3b(O0LHFSOOJnPa8rbBciS5lVraFahbkWZabOpgVJHQsOldxbBciS5lVraFahbkk0LVtowOJ1F)X4Dmtp2AjWVHRma6XmF5y8)y8oMPhdvLqxgUkqKAOvwn8IrMhbkk0LVtowOJzJ0hB7JT7yMDmZKCjA(YLC6p27qBkHqoYW4hstKCGNbcqlJtYHO)a0pLCRLa)gUYaOhZ8LJT7yrrhZ0JTwc8B4kdGEmZxog)pgVJz6Xqvj0LHRcePgALvdVyK5rGIcD57KJf6y2i9X2(y7oMzhZmjxIMVCjhEX02DGpYrgg)knrYbEgiaTmojhI(dq)uYnPa8rTMDDaTvwndAoRkWZabOpgVJnj1gg1kKIzvHdnhZ8LJTB)XIIowaMLLkJbU972ndAoRkmChlk6ybywwkefJKAqHHtYLO5lxYHsHOLO5lVjEYi5epzAE2bsoR3FYkqjYrgw4H0ejh4zGa0Y4KCi6pa9tjhQkHUmCfIIrsnqBKH(Xdk0AsTbsZIMO5lpfhl0YX6R43nCmEhZ0JTwc8B4kdGEmZxo2UJffDS1sGFdxza0Jz(YXWZX4DmuvcDz4QarQHwz1WlgzEeOOqx(o5yHoMnsFSTp2UJffDS1sGFdxza0JTCm(FmEhdvLqxgUkqKAOvwn8IrMhbkk0LVtowOJzJ0hB7JT7y8ogQkHUmCfEX02DGpkk0LVtowOJzJ0hB7JT7y8ogQkHUmCfQCcGO58LROqx(o5yHoMnsFSTp2UJzMKlrZxUKdrXiPgOnYq)4b5idBJjnrYbEgiaTmojxIMVCjhkfIwIMV8M4jJKt8KP5zhi5SE)jRaLihzy93lnrYbEgiaTmojhI(dq)uYrWbcrBsQnmefQCcGO58LFSqlhR)gKCjA(YLCOYjaIMZxUCKH1VV0ejh4zGa0Y4KCi6pa9tj3AjWVHRma6XmF5y8xYLO5lxYHOyKud0gzOF8GCKH1FN0ejh4zGa0Y4KCi6pa9tj3AjWVHRma6XmF5y8xYLO5lxYLuu6qBkkf8roYW6JhPjsoWZabOLXj5q0Fa6NsU57G2uTvC2hl0XSrAjxIMVCjhQCcGO58Llh5ihjxInRfvYXXpXarofvoYrkb]] )

    
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
