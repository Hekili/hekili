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
            gcd = "spell",

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
            gcd = "spell",

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
            gcd = "spell",
            
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


    spec:RegisterPack( "Retribution", 20200827, [[dKKPPaqisj9iPuQnHk(KukQrrkCkuPwLuQELsvMLsr3sujyxe9lruddu5ykvwMsPNPuvtJuIRjQuBduL03avX4evIoNOsO1jLsmpsPUNsAFIWbbvPSqLcpukL0efvsPlkQKkBukf4JGQensrLuCsPuKvskAMIkPQDkLyOsPGwQuk0trvtve5QGQe(kOkv7Ls)vQgSQoSWIfPhd1Kj5YiBMcFMIgTsCAGvdQQxlQy2eUTuSBQ(TKHdkhxujz5qEoktxX1bz7IQ(oPA8sjDEujZxu2VkB3ztYYRIHSTSfUTWbxUCl8iHB7(5ENwS8dxWilpSaNtyswEpAilFBKgeifAaLB5HfCjQqztYYZkieMS8w(uiGyAtUn1YRIHSTSfUTWbxUCl8iHB7(Aj3WJLNbJW2wGh4S8laLICBQLxrmSLVTVVnsdcKcnGYVVnmeHc4NMT99lZaJ1wsoztWSaLkXvtYmqdKigq5yuymjZan4KpnB77H3GHaI7Zf38(TWTfUtZtZ2((26s4MeRTCA223NlCp8cyQyi19gf6(CPCF5PzBFFUW9TbGwVhhSjz8s4ojUVTMRLDpEHW5WU3Oq3dVbVNCBfbXcfjpnB77ZfUVna0kXU3Oq3NRPAdR7HvLa4M3RNCDFBYZvqagyaLFF4Q7H3lKqLNa(9TrIvE4y6E9KR7BRiiwOiPLhgQmacYY323NRRvcdnK6EkpH46(b0q3pl09bEk09a29r(aiIubjpnd8akNTgqt1JzcCoNMbEaLZ2BnzeLcLdDAg4buoBV1KXHq0d8akVlaSztpAOvCvcvP7StZapGYz7TMmoeIEGhq5DbGnB6rdTAsoHIPqStZtZapGYzsCvcvP7S9wtwamxgwh(qkZgYNnbgRmyKq0NazsdtkaMldRdFiLzd5tI1TzzAOvuauDkp5JmukMKAfWgwwgkaQoLN8rgkftc8eWtU5(0mWdOCMexLqv6oBV1KnaikvuLAtGXAkKHHmYtUjWn76OywKqWYYsHmmKyeeluKecgNuiddjgbXcfjztGZzDhCNMbEaLZK4QeQs3z7TMmBbqcvVm65j3KchtNMbEaLZK4QeQs3z7TMCKNCtGB21rXSSjWyDPeC1Hv6ekXAU5mHG8rsTsyObuENr(qoMKKhPcsXzcb5J0a4HOJiCoLdCtj5rQGuzzlLGRoSsNqjw3NJw1ycb5JKALWqdO8oJ8HCmjjpsfKIZecYhPbWdrhr4Ckh4MsYJubP4(0mWdOCMexLqv6oBV1KXiiwOOnbgRlLGRoSsNqjw1sw2sj4QdR0juI195mGgs7DWDAg4buotIRsOkDNT3AYbBH8(sieL(PzGhq5mjUkHQ0D2ERjVucU6rEYnj0PzGhq5mjUkHQ0D2ERjZiuaBb0SjWyvdToHG8rIrqSqrsYJubP4GRsOkDxg5j3e4MDDumlse1eaNLyhCzztiiFKyeeluKK8ivqkoPqggsmcIfksQkDNdUkHQ0DjgbXcfjrutaCwIDWLLLczyiXiiwOijBcCojwHhUpnd8akNjXvjuLUZ2BnzdGhIoIW5uoWn3eySQHwNqq(iXiiwOij5rQGuCWvjuLUlJ8KBcCZUokMfjIAcGZsSdUSSjeKpsmcIfkssEKkifNuiddjgbXcfjvLUZbxLqv6UeJGyHIKiQjaolXo4YYsHmmKyeeluKKnboNeR7GJBoADcb5JKALWqdO8oJ8HCmjjpsfKklBcb5JKALWqdO8oJ8HCmjjpsfKIJIsHmmKuRegAaL3zKpKJjjeStZtZapGYzsdGdyleITMpqGivqB6rdTQdCtwhwvInZhciAvRtiiFKyeeluKK8ivqko4QeQs3LrEYnbUzxhfZIernbWzjmXQ23pldxLqv6UeJGyHIKiQjaolHjw1((NMbEaLZKgahWwieBV1KZhiqKkOn9OHwvSooytKkOnZhciALbJeI(eitAysfipWPoBkutI1TzzPqggsQbgxik8oSsNqsiyCsHmmKrEYnbUzxhfZspGMcJaJuv6(PzGhq5mPbWbSfcX2Bn58HNRGaSfcX6lrtdH2eySMpqGivqsDGBY6WQsWrrPqggs4dPmBiFKQs3ZYMqq(inaEi6icNt5a3usEKkifhCvcvP7sdGhIoIW5uoWnLiQjaolXo4ond8akNjnaoGTqi2ERjtTsyObuENr(qoM2eySYGrcrFcKjnmPcKh4uNnfQr71TC0qRtiiFKyeeluKK8ivqko4QeQs3LrEYnbUzxhfZIernbWzj2bxw2ecYhjgbXcfjjpsfKItkKHHeJGyHIKQs35GRsOkDxIrqSqrse1eaNLyhCzzPqggsmcIfksYMaNtIv4H7tZapGYzsdGdyleIT3AYkqEGtD2uOMnbgR5deisfKuX64GnrQG4KpqGivqsDGBY6WQsWrdn06ecYhj1kHHgq5Dg5d5yssEKkivwMgmyKq0NazsdtQa5bo1ztHAsSUnldxLqv6UKALWqdO8oJ8HCmjrutaCwctSQ9TCZDwMg4QeQs3LrEYnbUzxhfZIernbWzjmXQ23NdUkHQ0DzKNCtGB21rXSirutaCM27GlldxLqv6UeJGyHIKiQjaolHjw1((CWvjuLUlXiiwOijIAcGZ0EhCzzPqggsmcIfkscbJtkKHHeJGyHIKSjW5O9o44M7tZapGYzsdGdyleIT3AYd1ateiwppHua8SjWynFGarQGK6a3K1HvLGJgADcb5JKALWqdO8oJ8HCmjjpsfKkldxLqv6UKALWqdO8oJ8HCmjrutaCwctSQ9Tzz4QeQs3LrEYnbUzxhfZIernbWzjmXQ23NdUkHQ0DzKNCtGB21rXSirutaCM27GlldxLqv6UeJGyHIKiQjaolHjw1((CWvjuLUlXiiwOijIAcGZ0EhCzzPqggsmcIfkscbJtkKHHeJGyHIKSjW5O9o44(080mWdOCM0KCcftHy7TMmoeIEGhq5DbGnB6rdTAaCaBHqSnbgRlLGRoSsNqjwZDwwkKHHSHAkex9YOlGWavxHOOHjHGLLLczyizenla3SJctscb70mWdOCM0KCcftHy7TMSEKd1lJEWwi2MaJvn0kkaQoLN8rgkftsTcydlldfavNYt(idLIjbEID5olJbJeI(eitAys9ihQxg9GTqSeRB5MJglLGRoSsNqAVUnlBPeC1Hv6eADhhCvcvP7YurOOEz0HpeBaysIOMa4SeMyf3C0axLqv6UmYtUjWn76OywKiQjaolXo4YYMqq(iXiiwOij5rQGuCWvjuLUlXiiwOijIAcGZsSdoU5O1jeKpsQvcdnGY7mYhYXKK8ivqQSmfLczyiPwjm0akVZiFihtsiyCwkbxDyLoH0ED7PzGhq5mPj5ekMcX2Bn5LOPHq9YORJIzztGX6sj4QdR0jK2RA50mWdOCM0KCcftHy7TMCQiuuVm6WhInamTjWyDPeC1Hv6es71TzzASucU6WkDcTUphnWvjuLUlxIMgc1lJUokMfjIAcGZsyIvTVLBUpnd8akNjnjNqXui2ERjRa5bo1Nsi2eySQXsj4QdR0jK2RBZY0yPeC1Hv6es7vTWrdCvcvP7YurOOEz0HpeBaysIOMa4SeMyv7B5MBU5OOuiddj8HuMnKpsvP7zztiiFKuRegAaL3zKpKJjj5rQGuCWvjuLUlPwjm0akVZiFihtse1eaNLyhCC0yPeC1Hv6es7vTWrdCvcvP7YurOOEz0HpeBaysIOMa4SeMyv7B5M7tZapGYzstYjumfIT3AYWhsz2q(SjWyDPeC1Hv6es71TzzASucU6WkDcP9Qw4ObUkHQ0DzQiuuVm6WhInamjrutaCwctSQ9TCZ9PzGhq5mPj5ekMcX2BnzCie9apGY7caB20JgA1a4a2cHyBcmwNqq(ixIMgc1lJUokMfj5rQGuCMazsJCHcXSiHHhTx3cxwwkKHHmYtUjWn76OywKqWYYsHmmKyeeluKec2PzGhq5mPj5ekMcX2BnzmcIfkc1zdcKdTjWyfxLqv6UeJGyHIqD2Ga5qs8sGmjw3af4buEisSUtcp5MJglLGRoSsNqAVUnlBPeC1Hv6es7195GRsOkDxMkcf1lJo8Hydatse1eaNLWeRAFBw2sj4QdR0j0Qw4GRsOkDxMkcf1lJo8Hydatse1eaNLWeRAFlhCvcvP7s4dPmBiFKiQjaolHjw1(wo4QeQs3L4YzegfdOCjIAcGZsyIvTVL7tZapGYzstYjumfIT3AY4qi6bEaL3fa2SPhn0QbWbSfcXond8akNjnjNqXui2ERjJlNryumGY3eySYGrcrFcKjnmjUCgHrXakpX6UCFAg4buotAsoHIPqS9wtgJGyHIqD2Ga5qBcmwxkbxDyLoH0EvlNMbEaLZKMKtOykeBV1KdeoCQpfcr(SjWyDPeC1Hv6es7vTCAg4buotAsoHIPqS9wtgxoJWOyaLVjWyDanuFQ(cmZeMyLLppHyGYTTSfUTWbh8SlxA51dKdCtMLhEhERn2sBQf4LTL7VpPf6EqdScn3BuO7BZkYiGetB(EeLRGaisDpRAO7dOPAIHu3Jxc3KyYtZC9aNUFxB5E4fodcgScnK6(apGYVVnhqt1JzcCoTz5P5PzBQbwHgsDVwUpWdO87fa2WKNMwEbGnmBswEfzeqIXMKTLD2KS8bEaLB5dOP6Xmbohlp5rQGu2nSJTLT2KS8bEaLB5rukuoKLN8ivqk7g2X2Y(2KS8KhPcsz3WYh4buULhhcrpWdO8UaWglVaWMUhnKLhxLqv6oZo2w0Injlp5rQGu2nS8bEaLB5XHq0d8akVlaSXYlaSP7rdz5njNqXuiMDSJLhgIWvtAm2KSJLhxLqv6oZMKTLD2KS8KhPcsz3WYJrGHqGWYZGrcrFcKjnmPayUmSo8HuMnKp3Ny9(T3NLDVg3R17rbq1P8KpYqPysQvaBy3NLDpkaQoLN8rgkftc87tCp8K7752Yh4buULxamxgwh(qkZgYh7yBzRnjlp5rQGu2nS8yeyieiS8PqggYip5Ma3SRJIzrcb7(SS7tHmmKyeeluKec29CUpfYWqIrqSqrs2e4CUF9(DWz5d8ak3YBaquQOkLDSTSVnjlFGhq5wE2cGeQEz0ZtUjfoMS8KhPcsz3Wo2w0Injlp5rQGu2nS8yeyieiS8lLGRoSsNq3Ny9(CFpN7Nqq(iPwjm0akVZiFihtsYJubPUNZ9tiiFKgapeDeHZPCGBkjpsfK6(SS7xkbxDyLoHUpX697FpN7169AC)ecYhj1kHHgq5Dg5d5yssEKki19CUFcb5J0a4HOJiCoLdCtj5rQGu3ZTLpWdOClFKNCtGB21rXSyhBl52MKLN8ivqk7gwEmcmecew(LsWvhwPtO7tSEVwUpl7(LsWvhwPtO7tSE)(3Z5(b0q3R997GZYh4buULhJGyHISJTf4vBsw(apGYT8bBH8(sieLULN8ivqk7g2X2c8ytYYh4buULFPeC1J8KBsilp5rQGu2nSJTLCPnjlp5rQGu2nS8yeyieiS8ACVwVFcb5JeJGyHIKKhPcsDpN7XvjuLUlJ8KBcCZUokMfjIAcGZUpX97G7(SS7Nqq(iXiiwOij5rQGu3Z5(uiddjgbXcfjvLUFpN7XvjuLUlXiiwOijIAcGZUpX97G7(SS7tHmmKyeeluKKnboN7tSEp8Cp3w(apGYT8mcfWwan2X2sUOnjlp5rQGu2nS8yeyieiS8ACVwVFcb5JeJGyHIKKhPcsDpN7XvjuLUlJ8KBcCZUokMfjIAcGZUpX97G7(SS7Nqq(iXiiwOij5rQGu3Z5(uiddjgbXcfjvLUFpN7XvjuLUlXiiwOijIAcGZUpX97G7(SS7tHmmKyeeluKKnboN7tSE)o4UN775CVwVFcb5JKALWqdO8oJ8HCmjjpsfK6(SS7Nqq(iPwjm0akVZiFihtsYJubPUNZ9kkfYWqsTsyObuENr(qoMKqWS8bEaLB5naEi6icNt5a30o2XYBaCaBHqmBs2w2ztYYtEKkiLDdlFbZYZOXYh4buULpFGarQGS85dbez5169tiiFKyeeluKK8ivqQ75CpUkHQ0DzKNCtGB21rXSirutaC29jU3eRUV973)(SS7XvjuLUlXiiwOijIAcGZUpX9My19TF)(w(8bQ7rdz51bUjRdRkHDSTS1MKLN8ivqk7gw(cMLNrJLpWdOClF(abIubz5ZhciYYZGrcrFcKjnmPcKh4uNnfQ5(eR3V9(SS7tHmmKudmUqu4DyLoHKqWUNZ9PqggYip5Ma3SRJIzPhqtHrGrQkD3YNpqDpAilVI1XbBIubzhBl7BtYYtEKkiLDdlpgbgcbclF(abIubj1bUjRdRkX9CUxrPqggs4dPmBiFKQs3Vpl7(jeKpsdGhIoIW5uoWnLKhPcsDpN7XvjuLUlnaEi6icNt5a3uIOMa4S7tC)o4S8bEaLB5ZhEUccWwieRVenneYo2w0Injlp5rQGu2nS8yeyieiS8myKq0NazsdtQa5bo1ztHAUx7173EpN714ETE)ecYhjgbXcfjjpsfK6Eo3JRsOkDxg5j3e4MDDumlse1eaNDFI73b39zz3pHG8rIrqSqrsYJubPUNZ9PqggsmcIfksQkD)Eo3JRsOkDxIrqSqrse1eaNDFI73b39zz3NczyiXiiwOijBcCo3Ny9E45EUT8bEaLB5Pwjm0akVZiFiht2X2sUTjz5jpsfKYUHLhJadHaHLpFGarQGKkwhhSjsf09CUpFGarQGK6a3K1HvL4Eo3RX9ACVwVFcb5JKALWqdO8oJ8HCmjjpsfK6(SS714Egmsi6tGmPHjvG8aN6SPqn3Ny9(T3NLDpUkHQ0Dj1kHHgq5Dg5d5ysIOMa4S7tCVjwDF73V9EUVN77ZYUxJ7XvjuLUlJ8KBcCZUokMfjIAcGZUpX9My19TF)(3Z5ECvcvP7Yip5Ma3SRJIzrIOMa4S71((DWDFw294QeQs3LyeeluKernbWz3N4EtS6(2VF)75CpUkHQ0DjgbXcfjrutaC29AF)o4Upl7(uiddjgbXcfjHGDpN7tHmmKyeeluKKnboN71((DWDp33ZTLpWdOClVcKh4uNnfQXo2wGxTjz5jpsfKYUHLhJadHaHLpFGarQGK6a3K1HvL4Eo3RX9A9(jeKpsQvcdnGY7mYhYXKK8ivqQ7ZYUhxLqv6UKALWqdO8oJ8HCmjrutaC29jU3eRUV973EFw294QeQs3LrEYnbUzxhfZIernbWz3N4EtS6(2VF)75CpUkHQ0DzKNCtGB21rXSirutaC29AF)o4Upl7ECvcvP7smcIfksIOMa4S7tCVjwDF73V)9CUhxLqv6UeJGyHIKiQjao7ETVFhC3NLDFkKHHeJGyHIKqWUNZ9PqggsmcIfksYMaNZ9AF)o4UNBlFGhq5w(HAGjceRNNqkaESJDS8MKtOykeZMKTLD2KS8KhPcsz3WYJrGHqGWYVucU6WkDcDFI17Z99zz3NczyiBOMcXvVm6cimq1vikAysiy3NLDFkKHHKr0SaCZokmjjemlFGhq5wECie9apGY7caBS8caB6E0qwEdGdyleIzhBlBTjz5jpsfKYUHLhJadHaHLxJ7169OaO6uEYhzOumj1kGnS7ZYUhfavNYt(idLIjb(9jUFxUVpl7Egmsi6tGmPHj1JCOEz0d2cXUpX69BVN775CVg3VucU6WkDcDV2R3V9(SS7xkbxDyLoHUF9(D3Z5ECvcvP7YurOOEz0HpeBaysIOMa4S7tCVjwDp33Z5EnUhxLqv6UmYtUjWn76OywKiQjao7(e3VdU7ZYUFcb5JeJGyHIKKhPcsDpN7XvjuLUlXiiwOijIAcGZUpX97G7EUVNZ9A9(jeKpsQvcdnGY7mYhYXKK8ivqQ7ZYUxrPqggsQvcdnGY7mYhYXKec29CUFPeC1Hv6e6ETxVFRLpWdOClVEKd1lJEWwiMDSTSVnjlp5rQGu2nS8yeyieiS8lLGRoSsNq3R969AXYh4buULFjAAiuVm66OywSJTfTytYYtEKkiLDdlpgbgcbcl)sj4QdR0j09AVE)27ZYUxJ7xkbxDyLoHUF9(9VNZ9ACpUkHQ0D5s00qOEz01rXSirutaC29jU3eRUV973Ep33ZTLpWdOClFQiuuVm6WhInamzhBl52MKLN8ivqk7gwEmcmecewEnUFPeC1Hv6e6ETxVF79zz3RX9lLGRoSsNq3R969A5Eo3RX94QeQs3LPIqr9YOdFi2aWKernbWz3N4EtS6(2VF79CFp33Z99CUxrPqggs4dPmBiFKQs3Vpl7(jeKpsQvcdnGY7mYhYXKK8ivqQ75CpUkHQ0Dj1kHHgq5Dg5d5ysIOMa4S7tC)o4UNZ9AC)sj4QdR0j09AVEVwUNZ9ACpUkHQ0DzQiuuVm6WhInamjrutaC29jU3eRUV973Ep33ZTLpWdOClVcKh4uFkHWo2wGxTjz5jpsfKYUHLhJadHaHLFPeC1Hv6e6ETxVF79zz3RX9lLGRoSsNq3R969A5Eo3RX94QeQs3LPIqr9YOdFi2aWKernbWz3N4EtS6(2VF79CFp3w(apGYT8Whsz2q(yhBlWJnjlp5rQGu2nS8yeyieiS8tiiFKlrtdH6LrxhfZIK8ivqQ75C)eitAKluiMfjm8CV2R3VfU7ZYUpfYWqg5j3e4MDDumlsiy3NLDFkKHHeJGyHIKqWS8bEaLB5XHq0d8akVlaSXYlaSP7rdz5naoGTqiMDSTKlTjz5jpsfKYUHLhJadHaHLhxLqv6UeJGyHIqD2Ga5qs8sGmjw3af4buEiUpX697KWtUVNZ9AC)sj4QdR0j09AVE)27ZYUFPeC1Hv6e6ETxVF)75CpUkHQ0DzQiuuVm6WhInamjrutaC29jU3eRUV973EFw29lLGRoSsNq3VEVwUNZ94QeQs3LPIqr9YOdFi2aWKernbWz3N4EtS6(2VF79CUhxLqv6Ue(qkZgYhjIAcGZUpX9My19TF)275CpUkHQ0DjUCgHrXakxIOMa4S7tCVjwDF73V9EUT8bEaLB5XiiwOiuNniqoKDSTKlAtYYtEKkiLDdlFGhq5wECie9apGY7caBS8caB6E0qwEdGdyleIzhBl7GZMKLN8ivqk7gwEmcmecewEgmsi6tGmPHjXLZimkgq53Ny9(D52Yh4buULhxoJWOyaLBhBl72ztYYtEKkiLDdlpgbgcbcl)sj4QdR0j09AVEVwS8bEaLB5XiiwOiuNniqoKDSTSBRnjlp5rQGu2nS8yeyieiS8lLGRoSsNq3R969AXYh4buULpq4WP(uie5JDSTSBFBswEYJubPSBy5XiWqiqy5hqd1NQVaZ8(e3BIvw(apGYT84YzegfdOC7yh7y5dOzPqwE(CfejIPq2Xowl]] )

    
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
