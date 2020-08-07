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
        execution_sentence = 23467, -- 267798

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
        inquisition = 22634, -- 84963
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
            id = 267799,
            duration = 12,
            max_stack = 1,
        },

        eye_for_an_eye = {
            id = 205191,
            duration = 10,
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

        hammer_of_wrath_hallow = {
            duration = 30,
            max_stack = 1
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

        --[[ empyrean_power = {
            id = 286393,
            duration = 15,
            max_stack = 1
        }, ]]

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
            if legendary.uthers_guard.enabled then
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
        if IsUsableSpell( 24275 ) and not ( target.health_pct < 20 or buff.avenging_wrath.up or buff.crusade.up or buff.final_verdict.up ) then
            applyBuff( "hammer_of_wrath_hallow", action.ashen_hallow.lastCast + 30 - now )
        end
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
        ashen_hallow = {
            id = 316958,
            cast = function () return 1.5 * haste end,
            cooldown = 120,
            gcd = "spell",
            toggle = 'cooldowns',

            startsCombat = false,
            texture = 3565722,
        },


        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "spell",

            toggle = 'cooldowns',
            notalent = 'crusade',

            startsCombat = true,
            texture = 135875,

            nobuff = 'avenging_wrath',

            handler = function ()
                applyBuff( 'avenging_wrath' )
                applyBuff( "avenging_wrath_crit" )

                if talent.liadrins_fury_reborn.enabled then
                    gain( 5, "holy_power" )
                end
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
            cooldown = 45,
            recharge = 45,
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
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_arbiters_judgment.up and 1 or 0 )
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


        divine_toll = {
            id = 304971,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -1,
            spendType = "holy_power",

            startsCombat = true,
            texture = 3578228,

            handler = function()
                applyDebuff( "target", "judgment" )

                local t = min( 5, active_enemies ) - 1
                if t > 0 then
                    gain( t * ( buff.holy_avenger.up and 3 or 1 ), "holy_power" )
                    active_dot.judgment = min( active_enemies, active_dot.judgment + t )
                end
            end,
        },


        execution_sentence = {
            id = 267798,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_arbiters_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            talent = 'execution_sentence', 

            startsCombat = true,
            texture = 613954,

            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                applyDebuff( 'target', 'execution_sentence', 12 )
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
            cooldown = function () return 7.5 * haste end,
            gcd = "spell",

            spend = -1,
            spendType = 'holy_power',

            startsCombat = true,
            texture = 613533,

            usable = function () return target.health_pct < 20 or ( level > 57 and ( buff.avenging_wrath.up or buff.crusade.up ) ) or buff.final_verdict.up or buff.hammer_of_wrath_hallow.up end,
            handler = function ()
                removeBuff( "final_verdict" )

                if legendary.badge_of_the_mad_paragon.enabled then
                    if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 3 end
                    if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 3 end
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
        
        
        inquisition = {
            id = 84963,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "holy_power",

            talent = 'inquisition',

            startsCombat = false,
            texture = 461858,

            usable = function () return holy_power.current > 0 or buff.fires_of_justice.up or buff.the_arbiters_judgment.up, "requires holy_power or fires_of_justice or the_arbiters_judgment" end,
            handler = function ()
                local hopo = min( 3, holy_power.current )
                applyBuff( "inquisition", 15 * hopo )                

                spend( hopo - ( buff.fires_of_justice.up and 1 or 0 ) + ( buff.the_arbiters_judgment.up and 1 or 0 ), "holy_power" )

                removeBuff( "fires_of_justice" )
                removeBuff( "the_arbiters_judgment" )
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

                -- TODO: Legendary
            end,
        },


        justicars_vengeance = {
            id = 215661,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 5 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
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

            spend = 3,
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
            
            spend = 3,
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
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
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

            spend = 1,
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
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
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


    spec:RegisterPack( "Retribution", 20200718, [[dKuFNaqiQapsQuztePpjvkAuurofvOvbqEfaAwsLClPIGDr4xuPmmGYXaILbKEgvQMMurDnsr2MuPkFdOIXbujNtQi06KkLmpIO7jvTpsPdcuPSqa4HsLsnrPIiDrPIOSrPIeFuQuvnsPIioPuPWkjfMPuruTtPcdvQiPLkvK6PizQurDvPsv5RavQ2lj)vvgmOdlSyQYJrmzkUmQnJuFMunAP0PvSAQGEna1SP0TLIDl63sgoGooqvlhYZHA6QCDv12Ps(ornEsrDEIW8PQ2VsRar5SIYehR6auWafmWahqaxcq0KM6EG6UI6KaiROageah6SIkJgwr1P5dnE)BQurbmKWwHr5SIcxFeHvukkV)yVUrQ8uuM4yvhGcgOGbg4ac4saIMC3DnbQIcdKjQoahWuuTJXWPYtrzymrr1DlStZhA8(3u5c7udByMC1O7wy7DaXDl3CtFU2VNGunUHNMVnUPsckOp3WtdXTvJUBHGBarJDHDIDTqqbduWwnwn6Uf2TBJuNXDRvJUBHDclS7dOjo2Sq6cTqWLWDXQr3TWoHf2PmAEHKaFUrAJmz7c72DsXlK0YeaJxiDHwi4g4UBDB0hhgwSA0DlStyHDkJMz8cPl0c7KuDQ1cbwLDs9fk7wTWUrc()GNBQCHrAwi4EHSgx8KlStZ4kJKWlu2TAHDB0hhgwOOaIk6XYkQUBHDY0mt(hBwi7IrsSWBA4fET8cdYvOfo4fgUIXgEwwSAeKBQe3h)REXDbbWRgb5MkXaS3ne79bmVAeKBQedWE3iH1(cYnv(Sd(6kJgUNuL1uYjE1ii3ujgG9UrcR9fKBQ8zh81vgnCVoNmkUcHxnwncYnvIfKQSMsoXaS3n7O3E4Nd)g9goVUg6Emq2AFxG05dlSJE7HFo8B0B4802dQVVtoafJ5XU48eHXGfSMh8H99rXyESloprymyXKAbhn54QrqUPsSGuL1uYjgG9Urpi2ZwLPRHU37ttlcxCQpP(tgfxR4d0337ttliOpomS4duQ3NMwqqFCyyb(ccG7bbSvJGCtLybPkRPKtma7Dd3oS18k6Nlo15ij8QrqUPsSGuL1uYjgG9UfU4uFs9NmkU2Ug6ENCWfwopXKG)p45MkfCgEw24779PPftc()GNBQu8b6O02YkXdyjZiT9UVAeKBQelivznLCIbyVBe0hhgURHUVTSs8awYmsBFN99BlRepGLmJ027U0BAyjbbSvJGCtLybPkRPKtma7DlWTC(AdRTK7AO7DGtxy58ee0hhgwWz4zzJusvwtjNIWfN6tQ)KrX1kqCtmjwBV7G57FHLZtqqFCyybNHNLns9(00cc6JddlmLCkLuL1uYPGG(4WWce3etI127oyoUAeKBQelivznLCIbyVBTLvIx4ItDg11q37aN8(00IWfN6tQ)KrX1k(a999(00cc6Jddl(aDC1ii3ujwqQYAk5edWE3Wmka2onDn09o5GlSCEcc6Jddl4m8SSrkPkRPKtr4It9j1FYO4AfiUjMeRfeW89VWY5jiOpomSGZWZYgPEFAAbb9XHHfMsoLsQYAk5uqqFCyybIBIjXAbbmFFVpnTGG(4WWc8feaRThCCC1y1ii3ujwqp5GBzeU3vGMWZYDLrd3lpPo(bSkBxUc7N7DWfwopbb9XHHfCgEw2iLuL1uYPiCXP(K6pzuCTce3etI1QtmaYDFFsvwtjNcc6JddlqCtmjwRoXai3xncYnvIf0to4wgHbyVBUc0eEwURmA4Ed(rc8fEwUlxH9Z9yGS1(UaPZhwygxtYp8vOgT9G6779PPfCdqjqCKpGLmJeFGs9(00IWfN6tQ)KrX1(I)ve0CctjNRgb5MkXc6jhClJWaS3Tjb)FWZnv21q379PPfHlo1Nu)jJIRvyk5uQtEFAAXKG)p45MkfMso999(00Ijb)FWZnvkqCtmjwsWL02YkXdyjZiT9U77FHLZtWAMj)BQ8H584KWcodplBKsQYAk5uWAMj)BQ8H584KWce3etILeeWK69PPftc()GNBQuG4MysSKGOjFFsvwtjNIWfN6tQ)KrX1kqCtmjwsq0KuVpnTysW)h8CtLce3etILeuWK2wwjEalzgPT3DhxncYnvIf0to4wgHbyVBSMzY)MkFyopojCxdDpgiBTVlq68HfMX1K8dFfQrYEqL6KdUWY5jiOpomSGZWZYgPKQSMsofHlo1Nu)jJIRvG4MysSwqaZ3)clNNGG(4WWcodplBK69PPfe0hhgwyk5ukPkRPKtbb9XHHfiUjMeRfeW899(00cc6JddlWxqaS2EWXXvJGCtLyb9KdULrya27MzCnj)WxHA6AO7DfOj8SSWGFKaFHNLL6kqt4zzH8K64hWQSsDYjhCHLZtWAMj)BQ8H584KWcodplB89DcdKT23fiD(WcZ4As(HVc1OThuFFsvwtjNcwZm5FtLpmNhNewG4MysSwDIbqG6OJ((orQYAk5ueU4uFs9NmkUwbIBIjXA1jga5UusvwtjNIWfN6tQ)KrX1kqCtmjwsqaZ3NuL1uYPGG(4WWce3etI1QtmaYDPKQSMsofe0hhgwG4MysSKGaMVV3NMwqqFCyyXhOuVpnTGG(4WWc8fealjiG5OJRgb5MkXc6jhClJWaS3TJBaAde(5IrMHCDn09Uc0eEwwipPo(bSkRuNCWfwopbRzM8VPYhMZJtcl4m8SSX3NuL1uYPG1mt(3u5dZ5XjHfiUjMeRvNyaeO((KQSMsofHlo1Nu)jJIRvG4MysSwDIbqUlLuL1uYPiCXP(K6pzuCTce3etILeeW89jvznLCkiOpomSaXnXKyT6edGCxkPkRPKtbb9XHHfiUjMeljiG5779PPfe0hhgw8bk17ttliOpomSaFbbWsccyoUAeKBQelONCWTmcdWE3Cfj4)dULr4xB00WOUg6ExbAcpllKNuh)awLvQH9(00ch(n6nCEctjNRgRgb5MkXcDozuCfcdWE3iH1(cYnv(Sd(6kJgUNEYb3YiCxdDFBzL4bSKzK2En5779PPfnCtHK4v0p7NmMNbXrdw8b6779PPfyMV2j1FOqNfFG((xy58etc()GNBQuWz4zzJuVpnTysW)h8CtLctjNsBlRepGLmJ027(QrqUPsSqNtgfxHWaS3n5aW8ROFbULXDn09o5aumMh7IZtegdwWAEWh23hfJ5XU48eHXGftQfen57JbYw77cKoFyHCay(v0Va3YyT9G6OuNAlRepGLmJKShuF)2YkXdyjZOEqKsQYAk5u4zdd)k6Nd)4BiSaXnXKyT6eJJsDIuL1uYPiCXP(K6pzuCTce3etI1ccy((xy58ee0hhgwWz4zzJusvwtjNcc6JddlqCtmjwliG54QrqUPsSqNtgfxHWaS3T2OPHrVI(jJIRTRHUVTSs8awYmsY(oVAeKBQel05KrXvima7DZZgg(v0ph(X3q4Ug6(2YkXdyjZij7b133P2YkXdyjZOE3L6ePkRPKtrB00WOxr)KrX1kqCtmjwRoXaiqD0XvJGCtLyHoNmkUcHbyVBo8B0B486AO7BlRepGLmJKShuFFNAlRepGLmJKSVZsDIuL1uYPWZgg(v0ph(X3qybIBIjXA1jgabQJoUAeKBQel05KrXvima7DJew7li3u5Zo4RRmA4E6jhClJWDn09xy58eTrtdJEf9tgfxRGZWZYgPxG05t0YH9AfajNK9GcMVV3NMweU4uFs9NmkUwXhOVV3NMwqqFCyyXh4QrqUPsSqNtgfxHWaS3nc6JddJE4dnaM7AO7jvznLCkiOpomm6Hp0aywqAdKoJF0OGCtLHvBpicWrtsDQTSs8awYmsYEq99BlRepGLmJKS3DPKQSMsofE2WWVI(5Wp(gclqCtmjwRoXaiq99BlRepGLmJ67SusvwtjNcpBy4xr)C4hFdHfiUjMeRvNyaeOsjvznLCkC43O3W5jqCtmjwRoXaiqLsQYAk5uqQeZeuCtLce3etI1QtmacuhxncYnvIf6CYO4kegG9UrcR9fKBQ8zh81vgnCp9KdULr4vJGCtLyHoNmkUcHbyVBKkXmbf3uzxdDpgiBTVlq68HfKkXmbf3uP2Eq00QrqUPsSqNtgfxHWaS3nc6JddJE4dnaM7AO7BlRepGLmJKSVZRgb5MkXcDozuCfcdWE3ivIzckUPYUg6(BA43vVwG6A1jMvJGCtLyHoNmkUcHbyVBbIej)UcH486AO7BlRepGLmJKSVZkkxmcpvQ6auWafmW6myDIkk5aLtQJvuG7GBD6o6gD093Tw4cDULx40aSq3cPl0c7MgMo(2RBUqed()GyZcXvdVW4FvtCSzHK2i1zSy1Ot(K8cbPBTWUVe)bcSqhBwyqUPYf2nJ)vV4UGa4UPy1y1OB0aSqhBwyNxyqUPYfAh8HfRgkk7GpSYzfLHPJV9uoR6aeLZkQGCtLkQ4F1lUliawrXz4zzJcaQt1bOkNvub5Mkvui27dywrXz4zzJcaQt1H7kNvuCgEw2OaGIki3uPIIew7li3u5Zo4trzh89YOHvuKQSMsoXQt1rNvoRO4m8SSrbafvqUPsffjS2xqUPYNDWNIYo47LrdRO05KrXviS6uNIciIjvJxCkNvNIsNtgfxHWkNvDaIYzffNHNLnkaOOiO5y0ekQ2YkXdyjZOfQTFHAAH((l07ttlA4McjXROF2pzmpdIJgS4dCH((l07ttlWmFTtQ)qHol(axOV)cVWY5jMe8)bp3uPGZWZYMfkDHEFAAXKG)p45MkfMsoxO0f2wwjEalzgTqT9l0DfvqUPsffjS2xqUPYNDWNIYo47LrdROONCWTmcRovhGQCwrXz4zzJcakkcAognHIYPf6GfIIX8yxCEIWyWcwZd(Wl03FHOymp2fNNimgSyYfQDHGOPf67Vqmq2AFxG05dlKdaZVI(f4wgVqT9le0f64cLUqNwyBzL4bSKz0cLSFHGUqF)f2wwjEalzgTW(fcYcLUqsvwtjNcpBy4xr)C4hFdHfiUjMeVqTluNywOJlu6cDAHKQSMsofHlo1Nu)jJIRvG4Mys8c1UqqaBH((l8clNNGG(4WWcodplBwO0fsQYAk5uqqFCyybIBIjXlu7cbbSf6OIki3uPIsoam)k6xGBzS6uD4UYzffNHNLnkaOOiO5y0ekQ2YkXdyjZOfkz)c7SIki3uPIQnAAy0ROFYO4AvNQJoRCwrXz4zzJcakkcAognHIQTSs8awYmAHs2VqqxOV)cDAHTLvIhWsMrlSFHUVqPl0PfsQYAk5u0gnnm6v0pzuCTce3etIxO2fQtmleqle0f64cDurfKBQur5zdd)k6Nd)4BiS6uDOjLZkkodplBuaqrrqZXOjuuTLvIhWsMrluY(fc6c99xOtlSTSs8awYmAHs2VWoVqPl0PfsQYAk5u4zdd)k6Nd)4BiSaXnXK4fQDH6eZcb0cbDHoUqhvub5Mkvuo8B0B48uNQJUNYzffNHNLnkaOOiO5y0ekQlSCEI2OPHrVI(jJIRvWz4zzZcLUWlq68jA5WETcGKBHs2VqqbBH((l07ttlcxCQpP(tgfxR4dCH((l07ttliOpomS4durfKBQurrcR9fKBQ8zh8POSd(Ez0Wkk6jhClJWQt1b4OCwrXz4zzJcakkcAognHIIuL1uYPGG(4WWOh(qdGzbPnq6m(rJcYnvg2fQTFHGiahnTqPl0Pf2wwjEalzgTqj7xiOl03FHTLvIhWsMrluY(f6(cLUqsvwtjNcpBy4xr)C4hFdHfiUjMeVqTluNywiGwiOl03FHTLvIhWsMrlSFHDEHsxiPkRPKtHNnm8ROFo8JVHWce3etIxO2fQtmleqle0fkDHKQSMsofo8B0B48eiUjMeVqTluNywiGwiOlu6cjvznLCkivIzckUPsbIBIjXlu7c1jMfcOfc6cDurfKBQurrqFCyy0dFObWS6uDaUuoRO4m8SSrbafvqUPsffjS2xqUPYNDWNIYo47LrdROONCWTmcRovhDIkNvuCgEw2OaGIIGMJrtOOWazR9DbsNpSGujMjO4MkxO2(fcIMuub5MkvuKkXmbf3uP6uDacykNvuCgEw2OaGIIGMJrtOOAlRepGLmJwOK9lSZkQGCtLkkc6JddJE4dnaMvNQdqar5SIIZWZYgfauue0CmAcf1nn87Qxlq9fQDH6eJIki3uPIIujMjO4MkvNQdqav5SIIZWZYgfauue0CmAcfvBzL4bSKz0cLSFHDwrfKBQurfisK87keIZtDQtrrp5GBzew5SQdquoRO4m8SSrbafvburH5trfKBQur5kqt4zzfLRW(zfLdw4fwopbb9XHHfCgEw2SqPlKuL1uYPiCXP(K6pzuCTce3etIxO2fQtmleql09f67VqsvwtjNcc6JddlqCtmjEHAxOoXSqaTq3vuUc0lJgwrjpPo(bSkR6uDaQYzffNHNLnkaOOkGkkmFkQGCtLkkxbAcplROCf2pROWazR9DbsNpSWmUMKF4RqnluB)cbDH((l07ttl4gGsG4iFalzgj(axO0f69PPfHlo1Nu)jJIR9f)RiO5eMsovuUc0lJgwrzWpsGVWZYQt1H7kNvuCgEw2OaGIIGMJrtOO8(00IWfN6tQ)KrX1kmLCUqPl0Pf69PPftc()GNBQuyk5CH((l07ttlMe8)bp3uPaXnXK4fk5cbxlu6cBlRepGLmJwO2(f6(c99x4fwopbRzM8VPYhMZJtcl4m8SSzHsxiPkRPKtbRzM8VPYhMZJtclqCtmjEHsUqqaBHsxO3NMwmj4)dEUPsbIBIjXluYfcIMwOV)cjvznLCkcxCQpP(tgfxRaXnXK4fk5cbrtlu6c9(00Ijb)FWZnvkqCtmjEHsUqqbBHsxyBzL4bSKz0c12Vq3xOJkQGCtLkQjb)FWZnvQovhDw5SIIZWZYgfauue0CmAcffgiBTVlq68HfMX1K8dFfQzHs2VqqxO0f60cDWcVWY5jiOpomSGZWZYMfkDHKQSMsofHlo1Nu)jJIRvG4Mys8c1UqqaBH((l8clNNGG(4WWcodplBwO0f69PPfe0hhgwyk5CHsxiPkRPKtbb9XHHfiUjMeVqTleeWwOV)c9(00cc6JddlWxqa8c12VqWzHoQOcYnvQOynZK)nv(WCECsy1P6qtkNvuCgEw2OaGIIGMJrtOOCfOj8SSWGFKaFHNLxO0f6kqt4zzH8K64hWQSlu6cDAHoTqhSWlSCEcwZm5FtLpmNhNewWz4zzZc99xOtledKT23fiD(WcZ4As(HVc1SqT9le0f67VqsvwtjNcwZm5FtLpmNhNewG4Mys8c1UqDIzHaAHGUqhxOJl03FHoTqsvwtjNIWfN6tQ)KrX1kqCtmjEHAxOoXSqaTq3xO0fsQYAk5ueU4uFs9NmkUwbIBIjXluYfccyl03FHKQSMsofe0hhgwG4Mys8c1UqDIzHaAHUVqPlKuL1uYPGG(4WWce3etIxOKleeWwOV)c9(00cc6Jddl(axO0f69PPfe0hhgwGVGa4fk5cbbSf64cDurfKBQurzgxtYp8vOg1P6O7PCwrXz4zzJcakkcAognHIYvGMWZYc5j1XpGvzxO0f60cDWcVWY5jynZK)nv(WCECsybNHNLnl03FHKQSMsofSMzY)MkFyopojSaXnXK4fQDH6eZcb0cbDH((lKuL1uYPiCXP(K6pzuCTce3etIxO2fQtmleql09fkDHKQSMsofHlo1Nu)jJIRvG4Mys8cLCHGa2c99xiPkRPKtbb9XHHfiUjMeVqTluNywiGwO7lu6cjvznLCkiOpomSaXnXK4fk5cbbSf67VqVpnTGG(4WWIpWfkDHEFAAbb9XHHf4liaEHsUqqaBHoQOcYnvQOoUbOnq4NlgzgYPovhGJYzffNHNLnkaOOiO5y0ekkxbAcpllKNuh)awLDHsxOH9(00ch(n6nCEctjNkQGCtLkkxrc()GBze(1gnnmsDQtrrQYAk5eRCw1bikNvuCgEw2OaGIIGMJrtOOWazR9DbsNpSWo6Th(5WVrVHZBHA7xiOl03FHoTqhSqumMh7IZtegdwWAEWhEH((lefJ5XU48eHXGftUqTleC00cDurfKBQurzh92d)C43O3W5PovhGQCwrXz4zzJcakkcAognHIY7ttlcxCQpP(tgfxR4dCH((l07ttliOpomS4dCHsxO3NMwqqFCyyb(ccGxy)cbbmfvqUPsff9GypBvg1P6WDLZkQGCtLkkC7WwZROFU4uNJKWkkodplBuaqDQo6SYzffNHNLnkaOOiO5y0ekkNwOdw4fwopXKG)p45MkfCgEw2SqF)f69PPftc()GNBQu8bUqhxO0f2wwjEalzgTqT9l0DfvqUPsfv4It9j1FYO4AvNQdnPCwrXz4zzJcakkcAognHIQTSs8awYmAHA7xyNxOV)cBlRepGLmJwO2(f6(cLUWBA4fk5cbbmfvqUPsffb9XHHvNQJUNYzffNHNLnkaOOiO5y0ekkhSqNw4fwopbb9XHHfCgEw2SqPlKuL1uYPiCXP(K6pzuCTce3etIxO2(f6oyl03FHxy58ee0hhgwWz4zzZcLUqVpnTGG(4WWctjNlu6cjvznLCkiOpomSaXnXK4fQTFHUd2cDurfKBQurf4woFTH1wYQt1b4OCwrXz4zzJcakkcAognHIYbl0Pf69PPfHlo1Nu)jJIRv8bUqF)f69PPfe0hhgw8bUqhvub5MkvuTLvIx4ItDgPovhGlLZkkodplBuaqrrqZXOjuuoTqhSWlSCEcc6Jddl4m8SSzHsxiPkRPKtr4It9j1FYO4AfiUjMeVqTleeWwOV)cVWY5jiOpomSGZWZYMfkDHEFAAbb9XHHfMsoxO0fsQYAk5uqqFCyybIBIjXlu7cbbSf67VqVpnTGG(4WWc8feaVqT9leCwOJkQGCtLkkmJcGTtJ6uN6uuX)AlKIIcWSLVcPo1Pua]] )


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
