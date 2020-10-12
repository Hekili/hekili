-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


-- Conduits
-- [x] expurgation
-- [-] templars_vindication
-- [x] truths_wake
-- [x] virtuous_command


if UnitClassBase( "player" ) == "PALADIN" then
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
            duration = function () return 3 * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) end,
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


        -- Conduits
        expurgation = {
            id = 344067,
            duration = 6,
            max_stack = 1
        }
    } )

    spec:RegisterGear( "tier19", 138350, 138353, 138356, 138359, 138362, 138369 )
    spec:RegisterGear( "tier20", 147160, 147162, 147158, 147157, 147159, 147161 )
        spec:RegisterAura( "sacred_judgment", {
            id = 246973,
            duration = 8
        } )

    spec:RegisterGear( "tier21", 152151, 152153, 152149, 152148, 152150, 152152 )
        spec:RegisterAura( "hidden_retribution_t21_4p", {
            id = 253806,
            duration = 15
        } )

    spec:RegisterGear( "class", 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
    spec:RegisterGear( "truthguard", 128866 )
    spec:RegisterGear( "whisper_of_the_nathrezim", 137020 )
        spec:RegisterAura( "whisper_of_the_nathrezim", {
            id = 207633,
            duration = 3600
        } )

    spec:RegisterGear( "justice_gaze", 137065 )
    spec:RegisterGear( "ashes_to_dust", 51745 )
        spec:RegisterAura( "ashes_to_dust", {
            id = 236106,
            duration = 6
        } )

    spec:RegisterGear( "aegisjalmur_the_armguards_of_awe", 140846 )
    spec:RegisterGear( "chain_of_thrayn", 137086 )
        spec:RegisterAura( "chain_of_thrayn", {
            id = 236328,
            duration = 3600
        } )

    spec:RegisterGear( "liadrins_fury_unleashed", 137048 )
        spec:RegisterAura( "liadrins_fury_unleashed", {
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


    spec:RegisterHook( "spend", function( amt, resource )
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

            toggle = "cooldowns",
            notalent = "crusade",

            startsCombat = true,
            texture = 135875,

            nobuff = "avenging_wrath",

            handler = function ()
                applyBuff( "avenging_wrath" )
                applyBuff( "avenging_wrath_crit" )
            end,
        },


        blade_of_justice = {
            id = 184575,
            cast = 0,
            cooldown = function () return 12 * haste end,
            gcd = "spell",

            spend = -2,
            spendType = "holy_power",

            startsCombat = true,
            texture = 1360757,

            handler = function ()
                removeBuff( "blade_of_wrath" )
                removeBuff( "sacred_judgment" )
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
                applyBuff( "blessing_of_freedom" )
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
                applyBuff( "blessing_of_protection" )
                applyDebuff( "player", "forbearance" )

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

            talent = "blinding_light",

            startsCombat = true,
            texture = 571553,

            handler = function ()
                applyDebuff( "target", "blinding_light", 6 )
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

            talent = "crusade",
            toggle = "cooldowns",

            startsCombat = false,
            texture = 236262,

            nobuff = "crusade",

            handler = function ()
                applyBuff( "crusade" )
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
                applyBuff( "divine_shield" )
                applyDebuff( "player", "forbearance" )

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
                applyBuff( "divine_steed" )
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

                if buff.empyrean_power.up then removeBuff( "empyrean_power" )
                elseif buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else
                    removeBuff( "fires_of_justice" )
                    removeBuff( "hidden_retribution_t21_4p" )
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

            talent = "execution_sentence",

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

            talent = "eye_for_an_eye",

            startsCombat = false,
            texture = 135986,

            handler = function ()
                applyBuff( "eye_for_an_eye" )
            end,
        },


        final_reckoning = {
            id = 343721,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = "final_reckoning",

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
                removeBuff( "selfless_healer" )
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
                applyDebuff( "target", "hammer_of_justice" )
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
            spendType = "holy_power",

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
                applyDebuff( "target", "hand_of_hindrance" )
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
                applyDebuff( "target", "hand_of_reckoning" )
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
                applyDebuff( "target", "judgment" )
                if talent.zeal.enabled then applyBuff( "zeal", 20, 3 ) end
                if set_bonus.tier20_2pc > 0 then applyBuff( "sacred_judgment" ) end
                if set_bonus.tier21_4pc > 0 then applyBuff( "hidden_retribution_t21_4p", 15 ) end
                if talent.sacred_judgment.enabled then applyBuff( "sacred_judgment" ) end
                if conduit.virtuous_command.enabled then applyBuff( "virtuous_command" ) end
            end,

            auras = {
                virtuous_command = {
                    id = 339664,
                    duration = 6,
                    max_stack = 1
                }
            }
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
                if buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else
                    removeBuff( "fires_of_justice" )
                    removeBuff( "hidden_retribution_t21_4p" )
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
                applyDebuff( "player", "forbearance", 30 )

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

            toggle = "interrupts",

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
                applyDebuff( "target", "repentance", 60 )
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

            talent = "seraphim",
            toggle = "cooldowns",

            startsCombat = false,
            texture = 1030103,

            handler = function ()
                applyBuff( "seraphim" )
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
                applyBuff( "shield_of_vengeance" )
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

                if buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else
                    removeBuff( "fires_of_justice" )
                    removeBuff( "hidden_retribution_t21_4p" )
                end
                if buff.vanquishers_hammer.up then removeBuff( "vanquishers_hammer" ) end
                if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
                if talent.righteous_verdict.enabled then applyBuff( "righteous_verdict" ) end
                if talent.divine_judgment.enabled then addStack( "divine_judgment", 15, 1 ) end
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
            spendType = "holy_power",

            startsCombat = true,
            texture = 1112939,

            usable = function ()
                if settings.check_wake_range and not ( target.exists and target.within12 ) then return false, "target is outside of 12 yards" end
                return true
            end,

            handler = function ()
                if target.is_undead or target.is_demon then applyDebuff( "target", "wake_of_ashes" ) end
                if talent.divine_judgment.enabled then addStack( "divine_judgment", 15, 1 ) end
                if conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
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
                if buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else
                    removeBuff( "fires_of_justice" )
                    removeBuff( "hidden_retribution_t21_4p" )
                end
                gain( 1.33 * stat.spell_power * 8, "health" )

                if conduit.shielding_words.enabled then applyBuff( "shielding_words" ) end
            end,
        },
    } )


    spec:RegisterPack( "Retribution", 20201011, [[dCKGKbqifkpsQuP2eL0NiesJIsXPOeTkcbVsrXSOuAxq(LIsdtr1XiKwgLkptQW0ieDnfsBtsb9njfyCec15KkvSocHG5jP09uW(KuDqPsvPwOcvpuQuj1fLkvs(OuPQWjLkvIvkv0mLkvfTtfIFkvQQmucHqlLqi6PKyQsL8vPsvjJvQuv1Ef8xHgmshMQftWJjAYK6YO2SeFgrJwroTQwTuP8AkHzlLBts7w0VvA4svhxQuLLRYZHA6axNITtO(UKmEjfDEkvTEjfA(iSFqhen0vqr7aomIDZTBUOZfvuKDZfTgoA3jOaSVNdk9U0cNKdkPRYbfrKm4Ebd43mO0723wxh6kOGxZj5GsqrW8nq3Lmieu0oGdJy3C7Ml6Crffz3CrRH2jYGcUNLHrQbZdktVwZzqiOOzSmO0DdPIizW9cgWVjKkIO3C9NWo7UH0UFsWkWhKkQO2cP2n3U5bL(BlFJdkD3qQisgCVGb8BcPIi6nx)jSZUBiT7NeSc8bPIkQTqQDZTBoStyNUe8BIr9hlxvbhmZWS9l43e2Plb)Myu)XYvvWbZmmRFsp5iyVJtaStif2z3nK2DvnzPbWAiLfZN9qk4vzifmXqQlb7bPpgsDX(3CHgJGD6sWVjE4ybJfmStxc(nXZmmR0BTOlb)MX2Jb2MUkpi3TP3Qed70LGFt8mdZk9wl6sWVzS9yGTPRYdKCYNd2dd7esHD6sWVjgj3TP3Qep0VGFtB)YGncMsbj02v3mya6yxciiemLcYfZj5NKXQZbtitVvbtPGCXCs(jzS6CWe6yv)tCDrfXeecMsbjpd21mY0BvWuki5zWUMrhR6FIR1UrTe2Plb)MyKC3MERs8mdZ2EYjao2nJMuLtGTFza3ZTwe4hjdWO2tobWXUz0KQCcQpyhbHnJD(RJSyobixRXiUMpgGjio)1rwmNaKR1y0N1RbJAjStxc(nXi5Un9wL4zgMT8hl02vB7xgemLcYfZj5NKXQZbtitpbHGPuqYZGDnJm9wfmLcsEgSRzeg4slgeDoStxc(nXi5Un9wL4zgMfp9Cth3sumNKSNsg2Plb)MyKC3MERs8mdZAWC8bSQTPRYdNxJAtAbok8KXJ1rbdaSjStxc(nXi5Un9wL4zgM1G54dyvBtxLhC8KypzC88ACVOCpVz7xg0SGPuqNxJ7fL75TOMfmLcsVvjbHncMsb5I5K8tYy15Gj0XQ(N46d2nNGqWuki5zWUMryGlTyq05wfmLcsEgSRz0XQ(N46IoQLwTrUBtVvjI04N(9mULOxJ8TGj0XQ(N46DN5eeGxLJGnQFU2oMtqmgJXCkzKCtnNywhBFHl7jzKQ3T9Se2Plb)MyKC3MERs8mdZAWC8bSQTPRYdDJXXPTQXNTFzqWukixmNKFsgRohmHm9eecMsbjpd21mY0BvWuki5zWUMryGlTyq05WoDj43eJK720BvINzywdMJpGvTnDvEq87T4wIE(QoG1rH2UAB)YGncMsb5I5K8tYy15GjKPNGqWuki5zWUMrMERcMsbjpd21m6yv)tCTIkITKGWg5Un9wLixmNKFsgRohmHow1)exVJ5eeYDB6TkrYZGDnJow1)exVJ5wc70LGFtmsUBtVvjEMHznyo(aw120v5b9UQ4yXC2B7xgemLcYfZj5NKXQZbtitpbHGPuqYZGDnJm9wfmLcsEgSRz0XQ(N4Afved70LGFtmsUBtVvjEMHznyo(aw120v5bsVXsV14dhfy3cB)YGGPuqUyoj)KmwDoycz6jiemLcsEgSRzKP3QGPuqYZGDnJow1)exROJc70LGFtmsUBtVvjEMHznyo(aw120v5bb7j3KJcmh9MQNU02VmiykfKlMtYpjJvNdMqMEccbtPGKNb7Agz6HD6sWVjgj3TP3QepZWSgmhFaRAB6Q8GkFSfGjhhlEsA7xgSzSZFDKfZja5AngX18XambX5VoYI5eGCTgJ(SUOJAjbbUNBTiWpsgGr6x8NCed2tT(GDWoDj43eJK720BvINzywdMJpGvTnDvEOVzsnFcSFACS0CSf2(LbbtPGCXCs(jzS6CWeY0tqiykfK8myxZitVvbtPGKNb7AgHbU0I6dIoNGqUBtVvjYfZj5NKXQZbtOJv9pX1f5OeeJjykfK8myxZitVv5Un9wLi5zWUMrhR6FIRlYrHD6sWVjgj3TP3QepZWSgmhFaRAB6Q8GaFy(SGpCSBMUzS9ldcMsb5I5K8tYy15GjKPNGqWuki5zWUMrMERcMsbjpd21mcdCPf1heDobHC3MERsKlMtYpjJvNdMqhR6FIRlYrjigtWuki5zWUMrMERYDB6TkrYZGDnJow1)exxKJc70LGFtmsUBtVvjEMHznyo(aw120v5bo1ngJJGpLaZXXTelNlb)MEl2Vv8z7xgemLcYfZj5NKXQZbtitpbHGPuqYZGDnJm9wfmLcsEgSRzeg4slQpi6Ccc5Un9wLixmNKFsgRohmHow1)exxKJsqi3TP3Qejpd21m6yv)tCDrokStxc(nXi5Un9wL4zgM1G54dyvBtxLh6z)Ar9lMpCuUQ9ogB7xgemLcYfZj5NKXQZbtitpbHGPuqYZGDnJm9wfmLcsEgSRzeg4slQpi6CyNUe8BIrYDB6TkXZmmRbZXhWQ2MUkpu(ddIQoGXrCV9KnhJT9ldcMsb5I5K8tYy15GjKPNGqWuki5zWUMrMERcMsbjpd21m6yv)tCTdIokStxc(nXi5Un9wL4zgM1G54dyvBtxLhK7DMEaRJKnx)oypCuL1ER9BA7xgemLcYfZj5NKXQZbtitpbHGPuqYZGDnJm9wfmLcsEgSRz0XQ(N4ATBoStxc(nXi5Un9wL4zgM1G54dyvBtxLhK7DMEaRJKnx)oypCuW1KSTFzqWukixmNKFsgRohmHm9eecMsbjpd21mY0BvWuki5zWUMrhR6FIRv0rHD6sWVjgj3TP3QepZWSgmhFaRAB6Q8q19GPpjJyMuLtqClr9XyGt6GjyNUe8BIrYDB6TkXZmmRbZXhWQ2MUkpGNwPfcpGpCS4jPTFzqWukixmNKFsgRohmHm9eecMsbjpd21mY0d70LGFtmsUBtVvjEMHznyo(aw120v5H2l(tY4(TO0Zhd4d2Plb)MyKC3MERs8mdZAWC8bSQTPRYd3dmElwyhmXxClrtMKr3cB)YGGPuqUyoj)KmwDoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAXGOZjiK720BvICXCs(jzS6CWe6yv)tC9HoMtqi3TP3Qejpd21m6yv)tC9HoMd70LGFtmsUBtVvjEMHznyo(aw120v5HJvxahjnV2tjh1S4xYWoDj43eJK720BvINzywdMJpGvTnDvEq87T4wIyWEQyyNUe8BIrYDB6TkXZmmRbZXhWQ2MUkpun9xR6tsCSVzuDs22VmiykfKlMtYpjJvNdMqMEccbtPGKNb7Agz6TkykfK8myxZOJv9pX1oy3CyNUe8BIrYDB6TkXZmmRbZXhWQ2MUkpOp21rYMRFhShok4As22VmiykfKlMtYpjJvNdMqMEccbtPGKNb7Agz6TkykfK8myxZOJv9pX1oy3CyNUe8BIrYDB6TkXZmmRbZXhWQ2MUkpOp21rh3)NNaCuL1ER9BA7xgemLcYfZj5NKXQZbtitpbHGPuqYZGDnJm9wfmLcsEgSRz0XQ(N4AhSBoStxc(nXi5Un9wL4zgM1G54dyvBtxLhiVnjXX(7v9w8Cs22VmmMGPuqUyoj)KmwDoycz6ToMGPuqYZGDnJm9WoDj43eJK720BvINzywdMJpGvTnDvEa)5Jb8fjBU(DWE4OGRjzB)YGGPuqUyoj)KmwDoycz6jiemLcsEgSRzKP3QGPuqYZGDnJow1)ex7GOJc70LGFtmsUBtVvjEMHznyo(aw120v5b8NpgWxKS563b7HJQS2BTFtB)YGGPuqUyoj)KmwDoycz6jiemLcsEgSRzKP3QGPuqYZGDnJow1)ex7GDZHD6sWVjgj3TP3QepZWSgmhFaRAB6Q8GxJ4j)CCSSjiULy)wXNTFzymG34eGKNb7AgXPl0yTv5Un9wLixmNKFsgRohmHow1)ex7OeeaVXjajpd21mItxOXARYDB6TkrYZGDnJow1)ex7OwbVkxx05eetBZ(y)wXx9HoScEvUwrNBf4nobOk3coULOJNymItxOXAyNUe8BIrYDB6TkXZmmRbZXhWQ2MUkpi(X)MXTe1S6JzB)YGGPuqUyoj)KmwDoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAXGOZjiK720BvICXCs(jzS6CWe6yv)tC9HoMtqi3TP3Qejpd21m6yv)tC9HoMd70LGFtmsUBtVvjEMHznyo(aw120v5bhpj2tghpVg3lk3ZB2(Lbnlykf0514Er5EElQzbtPG0BvsqyJGPuqUyoj)KmwDoycDSQ)jU(GDZjiemLcsEgSRzeg4slgeDUvbtPGKNb7AgDSQ)jUUOJAPvBK720BvIin(PFpJBj61iFlycDSQ)jUE3zobb4v5iyJ6NRTJ5eeJXymNsgj3uZjM1X2x4YEsgP6DBplHD6sWVjgj3TP3QepZWSgmhFaRAB6Q8Gf5cIBj6P85eelMZEB)YGGPuqUyoj)KmwDoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAr9brNtqi3TP3Qe5I5K8tYy15Gj0XQ(N46DmNGymbtPGKNb7Agz6Tk3TP3Qejpd21m6yv)tC9oMd70LGFtmsUBtVvjEMHzD8eNXjV12kB)YWycMsb5I5K8tYy15GjKP36ycMsbjpd21mY0d70LGFtmsUBtVvjEMHzDXCs(jzS6CWKTFzWMPTzFSFR4R(GiTcEvU2rjiM2M9X(TIV6dDyf8QC9rjiaEJtaAAB2hDXCsYhItxOXARYDB6TkrtBZ(OlMts(qhR6FIhMBPvWRYrWgN6jhMd70LGFtmsUBtVvjEMHzLNb7A22VmyZ02Sp2Vv8vFqKwbVkx7OeetBZ(y)wXx9HoScEvU(OeeaVXjanTn7JUyoj5dXPl0yTv5Un9wLOPTzF0fZjjFOJv9pXdZT0k4v5iyJt9KdZHD6sWVjgj3TP3QepZWStBZ(OlMts(S9ldGxLJGno1tom3Qn2iykfKlMtYpjJvNdMqMEccbtPGKNb7Agz6TKGWgbtPGCXCs(jzS6CWesVvPv5Un9wLixmNKFsgRohmHow1)exxKZjiemLcsEgSRzKERsRYDB6TkrYZGDnJow1)exxKZT0syNUe8BIrYDB6TkXZmmB5tVfpwAXMFsA7xgM2M9X(TIV6dDyvUBtVvjYfZj5NKXQZbtOJv9pX1jLARGxLJGno1tom3QnJb8gNaeMpVF6vrC6cnwtqiykfeMpVF6vrMElHD6sWVjgj3TP3QepZWSGjoAsH1K6yzpjB7xgaVkx7GDeecMsbDS0IgJXXYEsgz6HD6sWVjgj3TP3QepZWScTD1XTebtCKtw1EB)YGGPuqUyoj)KmwDoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAXGOZHD6sWVjgj3TP3QepZWSKg)0VNXTe9AKVfmz7xggd4nobi5zWUMrC6cnwB1g5Un9wLixmNKFsgRohmHow1)ex7OwN2M9X(TIV6dDqqi3TP3Qe5I5K8tYy15Gj0XQ(N46dICuljiSb4nobi5zWUMrC6cnwBvUBtVvjsEgSRz0XQ(N4AjLARtBZ(y)wXx9brsqi3TP3Qejpd21m6yv)tC9broQLWoDj43eJK720BvINzy2Q9AAX8NXJXB6PKT9ldYDB6TkrUyoj)KmwDoycDSQ)jUwsP2602Sp2Vv8vFOdccG34eGKNb7AgXPl0yTv5Un9wLi5zWUMrhR6FIRLuQToTn7J9BfF1hejbHC3MERsKlMtYpjJvNdMqhR6FIRpiYrjiK720BvIKNb7AgDSQ)jU(Gihf2Plb)MyKC3MERs8mdZwwPbZ6OxJ89aokWUQTFzWMXo)1rwmNaKR1yexZhdWeeN)6ilMtaY1Am6Z6DmNGa3ZTwe4hjdWi9l(toIb7PwFWolToMncMsb5I5K8tYy15GjKPNGqWuki5zWUMrMElTAJC3MERsKqZ1CClXUzWGxYOJv9pX1jLArOdRYDB6TkrDZOjv5eGow1)exNuQfHoSe2Plb)MyKC3MERs8mdZQYQ7zFClXMr(6O(yxfB7xgSrWukixmNKFsgRohmHm9eecMsbjpd21mY0BvWuki5zWUMryGlTyq05wADAB2h73k(QDOdyNUe8BIrYDB6TkXZmmBV5(I9FsgfAogy7xgSzSZFDKfZja5AngX18XambX5VoYI5eGCTgJ(SEhZjiW9CRfb(rYams)I)KJyWEQ1hSZsyNqkStxc(nXOYNpEIp8mdZk2V3fASTPRYdACu6yGl0yBf7ndpG75wlc8JKbyK(f)jhXG9uRpyhbHGPuqSAV9h7zSFR4dz6TQzbtPG6MrtQYjaP3Q0QGPuq6x8NCS3C9lMr6TkjiW9CRfb(rYams)I)KJyWEQ1hSZQGPuqYZGDnJm9wfmLcsEgSRzeg4slQv05WoDj43eJkF(4j(WZmmlMpVF6vT9ld2yZyaVXjajpd21mItxOXARcMsb5I5K8tYy15GjKPNGqUBtVvjYfZj5NKXQZbtOJv9pX1TBuljiSrWuki5zWUMrMEcc5Un9wLi5zWUMrhR6FIRB3OwAPvBgd4nobOYNElES0In)KeXPl0ynbHC3MERsu5tVfpwAXMFsIow1)exROZT0QnJb8gNaextwAa)MrmNaoLmItxOXAcc5Un9wLiUMS0a(nJyobCkz0XQ(N4AfDULwbVkhbBCQNCyoStxc(nXOYNpEIp8mdZk2ZUN5Xt8HJtUQkF2(LbBgd4nobOYNElES0In)KeXPl0ynbHC3MERsu5tVfpwAXMFsIow1)exNuQfbrNtqOzbtPGkF6T4Xsl28tsKP3sR2mgWBCcqCnzPb8BgXCc4uYioDHgRjiK720BvI4AYsd43mI5eWPKrhR6FIRtk1IGOZji0SGPuqCnzPb8BgXCc4uYitVLee4EU1Ia)izagPFXFYrmyp16d2b70LGFtmQ85JN4dpZWSCnzPb8BgXCc4uY2(LbCp3ArGFKmaJ0V4p5igSNATdDy1gBgd4nobi5zWUMrC6cnwtqiykfK8myxZi9wLwL720BvIKNb7AgDSQ)jUUOZTKGqWuki5zWUMryGlTO(qheeYDB6TkrUyoj)KmwDoycDSQ)jUUOZji0SGPuqLp9w8yPfB(jjY0BPvWRYrWgN6jhMd70LGFtmQ85JN4dpZWS6x8NCed2t12Vmi2V3fAmsJJshdCHgBDmbtPGe7z3Z84j(WXjxvLpKP3Qn2mgWBCcqYZGDnJ40fASMGqUBtVvjsEgSRz0XQ(N46KsTi0HLwTzmG34eG4AYsd43mI5eWPKrC6cnwtqi3TP3QeX1KLgWVzeZjGtjJow1)exNuQfHoiiW9CRfb(rYams)I)KJyWEQ1h6WsccCp3ArGFKmaJ0V4p5igSNA9b7SAdWBCcqtBZ(OlMts(qC6cnwBvUBtVvjAAB2hDXCsYh6yv)tCTKsTi0bbHGPuqYZGDnJm9wfmLcsEgSRzeg4slQv05wAjStxc(nXOYNpEIp8mdZcy1(MF4Oy(0Vey7xgSzmG34eGKNb7AgXPl0ynbHC3MERsK8myxZOJv9pX1jLArOdlTAZyaVXjaX1KLgWVzeZjGtjJ40fASMGqUBtVvjIRjlnGFZiMtaNsgDSQ)jUoPulcDyf3ZTwe4hjdWi9l(toIb7Pw7qhwA1MXaEJtaQ8P3IhlTyZpjrC6cnwtqi3TP3Qev(0BXJLwS5NKOJv9pX1jLArOdlTAZyYvmNEcqjlVTTNgXPl0ynbHC3MERsKyp7EMhpXhoo5QQ8How1)exNuQTKGa4nobOPTzF0fZjjFioDHgRTk3TP3QenTn7JUyoj5dDSQ)jUwsPwe6GGqWukOPTzF0fZjjFitpbHGPuqYZGDnJm9wfmLcsEgSRzeg4slQv05eecMsbj2ZUN5Xt8HJtUQkFitpStif2Plb)MyejN85G9WZmmR0BTOlb)MX2Jb2MUkpu(8Xt8HT9ldtBZ(y)wXx9HrjiemLcAAB2hDXCsYhY0tqOzbtPGkF6T4Xsl28tsKPNGqZcMsbX1KLgWVzeZjGtjJm9WoDj43eJi5KphShEMHzfAmg)jzClrSrvLpyNUe8BIrKCYNd2dpZWScngJ)KmULOBag1e2Plb)MyejN85G9WZmmRqJX4pjJBjw9jGpyNUe8BIrKCYNd2dpZWScngJ)KmULiU)(Ke2Plb)MyejN85G9WZmmR(f)jhbBRz7xggtZcMsb1nJMuLtaY0B1MXo)1rwmNaKR1yexZhdWeeN)6ilMtaY1Am6Z6Dm3sR2mTn7J9BfF1oyhbX02Sp2Vv8v7GiTAJC3MERsKqZ1CClXUzWGxYOJv9pX1jLArWoccnlykfextwAa)MrmNaoLmY0tqOzbtPGkF6T4Xsl28tsKP3slTAZyaVXjav(0BXJLwS5NKioDHgRjiK720BvIkF6T4Xsl28ts0XQ(N46KsTii6ClTAZyaVXjaX1KLgWVzeZjGtjJ40fASMGqUBtVvjIRjlnGFZiMtaNsgDSQ)jUoPulcIo3syNUe8BIrKCYNd2dpZWSvUfCClrhpXyB)YGntBZ(y)wX3WCcIPTzFSFR4R2b7SAJC3MERsKqZ1CClXUzWGxYOJv9pX1jLArWoccnlykfextwAa)MrmNaoLmY0tqOzbtPGkF6T4Xsl28tsKP3slTAZyN)6ilMtaY1AmIR5JbycIZFDKfZja5Ang9zD7MBPvBgd4nobiUMS0a(nJyobCkzeNUqJ1eeYDB6TkrCnzPb8BgXCc4uYOJv9pX1fDulTAZyaVXjav(0BXJLwS5NKioDHgRjiK720BvIkF6T4Xsl28ts0XQ(N46IoQLWoDj43eJi5KphShEMHzfAUMJBj2ndg8s22VmmTn7J9BfF1o0bStxc(nXiso5Zb7HNzy2jxvLV4wIvNdMS9ldtBZ(y)wXxTdIe2Plb)MyejN85G9WZmmB3mAsvob2(LHX0SGPuqDZOjv5eGm9wTzAB2h73k(QDWocIPTzFSFR4R2brAvUBtVvjsO5AoULy3myWlz0XQ(N46KsTiyNLWoDj43eJi5KphShEMHzLERfDj43m2EmW20v5HYNpEIpSTFzWgGFKmanXEdmH6LGAhSBobHGPuqUyoj)KmwDoycz6jiemLcsEgSRzKPNGqWukiwT3(J9m2Vv8Hm9wc70LGFtmIKt(CWE4zgMvEgSR5lIb3BbB7xgK720BvIKNb7A(IyW9wWi5KFKmowoxc(n9w9brr1GrTAZ02Sp2Vv8v7GDeetBZ(y)wXxTdDyvUBtVvjsO5AoULy3myWlz0XQ(N46KsTiyhbX02Sp2Vv8nisRYDB6TkrcnxZXTe7MbdEjJow1)exNuQfb7Sk3TP3Qe1nJMuLta6yv)tCDsPweSZsyNUe8BIrKCYNd2dpZWSsV1IUe8BgBpgyB6Q8q5ZhpXhg2Plb)MyejN85G9WZmmR8myxZxedU3c22VmmTn7J9BfF1oisyNUe8BIrKCYNd2dpZWSYnLCcohW6yP5QmStxc(nXiso5Zb7HNzy2J9(pjJLMRYyB)YaWpsgGMyVbMI9sqDr8CccGFKmanXEdmf7LGATBobr5jNaXJv9pX12XOWoDj43eJi5KphShEMHz9t6jhb7DCcS9ldtBZ(y)wXxTdIe2Plb)MyejN85G9WZmmRCtmlph8BA7xgaVkhbBCQNSoPuhueZh(3mmIDZTB(8UJD1WGsLF5NK4Gs3xDFlICKUlJ09HicqkK21edPVA)EaiTShKkIw(8Xt8HfrH0J7EM)ynKIxvgsDdyvDaRHu5KNKmgb7S7ZpziTgkIaK2D9MI5dWAivevUI50taQ7pItxOXAruifSqQiQCfZPNau3Frui1grRPLiyNWo7UO2VhG1q6OqQlb)MqA7Xamc2zqP9yao0vqrZf30aHUcJiAORGIlb)MbLJfmwWbfoDHgRdJhaHrSl0vqHtxOX6W4bfxc(ndksV1IUe8BgBpgeuApgetxLdkYDB6TkXbqyKocDfu40fASomEqXLGFZGI0BTOlb)MX2JbbL2JbX0v5GcjN85G9Wbqaeu6pwUQcoi0vyerdDfuCj43mO0VGFZGcNUqJ1HXdGWi2f6kO4sWVzqXpPNCeS3XjiOWPl0yDy8aiackKCYNd2dh6kmIOHUckC6cnwhgpOiVhW37bLPTzFSFR4dsRpaPJcPeeqQGPuqtBZ(OlMts(qMEiLGas1SGPuqLp9w8yPfB(jjY0dPeeqQMfmLcIRjlnGFZiMtaNsgz6dkUe8BguKERfDj43m2EmiO0EmiMUkhukF(4j(Wbqye7cDfuCj43mOi0ym(tY4wIyJQkFbfoDHgRdJhaHr6i0vqXLGFZGIqJX4pjJBj6gGrndkC6cnwhgpacJiYqxbfxc(ndkcngJ)KmULy1Na(ckC6cnwhgpacJmAORGIlb)MbfHgJXFsg3se3FFsgu40fASomEaegPgg6kOWPl0yDy8GI8EaFVhugds1SGPuqDZOjv5eGm9qQvi1giDmi98xhzXCcqUwJrCnFmadPeeq65VoYI5eGCTgJ(esRdPDmhsTesTcP2aPtBZ(y)wXhKw7aKAhKsqaPtBZ(y)wXhKw7aKksi1kKAdKk3TP3Qej0Cnh3sSBgm4Lm6yv)tmKwhsjLAiveGu7GuccivZcMsbX1KLgWVzeZjGtjJm9qkbbKQzbtPGkF6T4Xsl28tsKPhsTesTesTcP2aPJbPaVXjav(0BXJLwS5NKioDHgRHuccivUBtVvjQ8P3IhlTyZpjrhR6FIH06qkPudPIaKk6Ci1si1kKAdKogKc8gNaextwAa)MrmNaoLmItxOXAiLGasL720BvI4AYsd43mI5eWPKrhR6FIH06qkPudPIaKk6Ci1YGIlb)Mbf9l(toc2wlacJudcDfu40fASomEqrEpGV3dk2aPtBZ(y)wXhKoaPZHucciDAB2h73k(G0AhGu7GuRqQnqQC3MERsKqZ1CClXUzWGxYOJv9pXqADiLuQHurasTdsjiGunlykfextwAa)MrmNaoLmY0dPeeqQMfmLcQ8P3IhlTyZpjrMEi1si1si1kKAdKogKE(RJSyobixRXiUMpgGHucci98xhzXCcqUwJrFcP1Hu7MdPwcPwHuBG0XGuG34eG4AYsd43mI5eWPKrC6cnwdPeeqQC3MERsextwAa)MrmNaoLm6yv)tmKwhsfDui1si1kKAdKogKc8gNau5tVfpwAXMFsI40fASgsjiGu5Un9wLOYNElES0In)KeDSQ)jgsRdPIokKAzqXLGFZGsLBbh3s0XtmoacJiIdDfu40fASomEqrEpGV3dktBZ(y)wXhKw7aK2rqXLGFZGIqZ1CClXUzWGxYbqyKUtORGcNUqJ1HXdkY7b89EqzAB2h73k(G0AhGurguCj43mOm5QQ8f3sS6CWuaegr05HUckC6cnwhgpOiVhW37bLXGunlykfu3mAsvobitpKAfsTbsN2M9X(TIpiT2bi1oiLGasN2M9X(TIpiT2bivKqQvivUBtVvjsO5AoULy3myWlz0XQ(NyiToKsk1qQiaP2bPwguCj43mO0nJMuLtqaegrurdDfu40fASomEqrEpGV3dk2aPa)izaAI9gyc1lbqATdqQDZHuccivWukixmNKFsgRohmHm9qkbbKkykfK8myxZitpKsqaPcMsbXQ92FSNX(TIpKPhsTmO4sWVzqr6Tw0LGFZy7XGGs7XGy6QCqP85JN4dhaHre1UqxbfoDHgRdJhuK3d479GIC3MERsK8myxZxedU3cgjN8JKXXY5sWVP3G06dqQOOAWOqQvi1giDAB2h73k(G0AhGu7GucciDAB2h73k(G0AhG0oGuRqQC3MERsKqZ1CClXUzWGxYOJv9pXqADiLuQHurasTdsjiG0PTzFSFR4dshGurcPwHu5Un9wLiHMR54wIDZGbVKrhR6FIH06qkPudPIaKAhKAfsL720BvI6MrtQYjaDSQ)jgsRdPKsnKkcqQDqQLbfxc(ndkYZGDnFrm4El4aimIODe6kOWPl0yDy8GIlb)MbfP3Arxc(nJThdckThdIPRYbLYNpEIpCaegrurg6kOWPl0yDy8GI8EaFVhuM2M9X(TIpiT2bivKbfxc(ndkYZGDnFrm4El4aimIOJg6kO4sWVzqrUPKtW5awhlnxLdkC6cnwhgpacJiAnm0vqHtxOX6W4bf59a(EpOa8JKbOj2BGPyVeaP1Hur8CiLGasb(rYa0e7nWuSxcG0AHu7MdPeeqA5jNaXJv9pXqATqAhJguCj43mOCS3)jzS0CvghaHreTge6kOWPl0yDy8GI8EaFVhuM2M9X(TIpiT2bivKbfxc(ndk(j9KJG9oobbqyerfXHUckC6cnwhgpOiVhW37bfWRYrWgN6jH06qkPuhuCj43mOi3eZYZb)MbqaeukF(4j(WHUcJiAORGcNUqJ1HXdkBFqbZGGIlb)MbfX(9UqJdkI9MHdk4EU1Ia)izagPFXFYrmypviT(aKAhKsqaPcMsbXQ92FSNX(TIpKPhsTcPAwWukOUz0KQCcq6TkHuRqQGPuq6x8NCS3C9lMr6TkHuccif3ZTwe4hjdWi9l(toIb7PcP1hGu7GuRqQGPuqYZGDnJm9qQvivWuki5zWUMryGlTasRfsfDEqrSFX0v5GIghLog4cnoacJyxORGcNUqJ1HXdkY7b89EqXgi1giDmif4nobi5zWUMrC6cnwdPwHubtPGCXCs(jzS6CWeY0dPeeqQC3MERsKlMtYpjJvNdMqhR6FIH06qQDJcPwcPeeqQnqQGPuqYZGDnJm9qkbbKk3TP3Qejpd21m6yv)tmKwhsTBui1si1si1kKAdKogKc8gNau5tVfpwAXMFsI40fASgsjiGu5Un9wLOYNElES0In)KeDSQ)jgsRfsfDoKAjKAfsTbshdsbEJtaIRjlnGFZiMtaNsgXPl0ynKsqaPYDB6TkrCnzPb8BgXCc4uYOJv9pXqATqQOZHulHuRqk4v5iyJt9Kq6aKopO4sWVzqbZN3p9QbqyKocDfu40fASomEqrEpGV3dk2aPJbPaVXjav(0BXJLwS5NKioDHgRHuccivUBtVvjQ8P3IhlTyZpjrhR6FIH06qkPudPIaKk6CiLGas1SGPuqLp9w8yPfB(jjY0dPwcPwHuBG0XGuG34eG4AYsd43mI5eWPKrC6cnwdPeeqQC3MERsextwAa)MrmNaoLm6yv)tmKwhsjLAiveGurNdPeeqQMfmLcIRjlnGFZiMtaNsgz6HulHuccif3ZTwe4hjdWi9l(toIb7PcP1hGu7ckUe8Bgue7z3Z84j(WXjxvLVaimIidDfu40fASomEqrEpGV3dk4EU1Ia)izagPFXFYrmypviT2biTdi1kKAdKAdKogKc8gNaK8myxZioDHgRHuccivWuki5zWUMr6TkHuRqQC3MERsK8myxZOJv9pXqADiv05qQLqkbbKkykfK8myxZimWLwaP1hG0oGuccivUBtVvjYfZj5NKXQZbtOJv9pXqADiv05qkbbKQzbtPGkF6T4Xsl28tsKPhsTesTcPGxLJGno1tcPdq68GIlb)MbfUMS0a(nJyobCk5aimYOHUckC6cnwhgpOiVhW37bfX(9UqJrACu6yGl0yi1kKogKkykfKyp7EMhpXhoo5QQ8Hm9qQvi1gi1giDmif4nobi5zWUMrC6cnwdPeeqQC3MERsK8myxZOJv9pXqADiLuQHuras7asTesTcP2aPJbPaVXjaX1KLgWVzeZjGtjJ40fASgsjiGu5Un9wLiUMS0a(nJyobCkz0XQ(NyiToKsk1qQiaPDaPeeqkUNBTiWpsgGr6x8NCed2tfsRpaPDaPwcPeeqkUNBTiWpsgGr6x8NCed2tfsRpaP2bPwHuBGuG34eGM2M9rxmNK8H40fASgsTcPYDB6TkrtBZ(OlMts(qhR6FIH0AHusPgsfbiTdiLGasfmLcsEgSRzKPhsTcPcMsbjpd21mcdCPfqATqQOZHulHuldkUe8Bgu0V4p5igSNAaegPgg6kOWPl0yDy8GI8EaFVhuSbshdsbEJtasEgSRzeNUqJ1qkbbKk3TP3Qejpd21m6yv)tmKwhsjLAiveG0oGulHuRqQnq6yqkWBCcqCnzPb8BgXCc4uYioDHgRHuccivUBtVvjIRjlnGFZiMtaNsgDSQ)jgsRdPKsnKkcqAhqQvif3ZTwe4hjdWi9l(toIb7PcP1oaPDaPwcPwHuBG0XGuG34eGkF6T4Xsl28tseNUqJ1qkbbKk3TP3Qev(0BXJLwS5NKOJv9pXqADiLuQHuras7asTesTcP2aPJbPYvmNEcqjlVTTNgsjiGu5Un9wLiXE29mpEIpCCYvv5dDSQ)jgsRdPKsnKAjKsqaPaVXjanTn7JUyoj5dXPl0ynKAfsL720BvIM2M9rxmNK8How1)edP1cPKsnKkcqAhqkbbKkykf002Sp6I5KKpKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJWaxAbKwlKk6CiLGasfmLcsSNDpZJN4dhNCvv(qM(GIlb)MbfaR238dhfZN(LGaiackYDB6TkXHUcJiAORGcNUqJ1HXdkY7b89EqXgivWukiH2U6Mbdqh7saKsqaPcMsb5I5K8tYy15GjKPhsTcPcMsb5I5K8tYy15Gj0XQ(NyiToKkQigsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJow1)edP1cP2nkKAzqXLGFZGs)c(ndGWi2f6kOWPl0yDy8GI8EaFVhuW9CRfb(rYamQ9KtaCSBgnPkNaiT(aKAhKsqaP2aPJbPN)6ilMtaY1AmIR5JbyiLGasp)1rwmNaKR1y0NqADiTgmkKAzqXLGFZGs7jNa4y3mAsvobbqyKocDfu40fASomEqrEpGV3dkcMsb5I5K8tYy15GjKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJWaxAbKoaPIopO4sWVzqP8hl02vhaHrezORGIlb)Mbf80ZnDClrXCsYEk5GcNUqJ1HXdGWiJg6kOWPl0yDy8Gs6QCq58AuBslWrHNmESokyaGndkUe8BguoVg1M0cCu4jJhRJcgayZaimsnm0vqHtxOX6W4bfxc(ndkoEsSNmoEEnUxuUN3ckY7b89EqrZcMsbDEnUxuUN3IAwWuki9wLqkbbKAdKkykfKlMtYpjJvNdMqhR6FIH06dqQDZHuccivWuki5zWUMryGlTashGurNdPwHubtPGKNb7AgDSQ)jgsRdPIokKAjKAfsTbsL720BvIin(PFpJBj61iFlycDSQ)jgsRdPDN5qkbbKcEvoc2O(ziTwiTJ5qkbbKogKYymNsgj3uZjM1X2x4YEsgP6DBpi1YGs6QCqXXtI9KXXZRX9IY98waegPge6kOWPl0yDy8GIlb)MbLUX440w14lOiVhW37bfbtPGCXCs(jzS6CWeY0dPeeqQGPuqYZGDnJm9qQvivWuki5zWUMryGlTashGurNhusxLdkDJXXPTQXxaegreh6kOWPl0yDy8GIlb)MbfXV3IBj65R6awhfA7QdkY7b89EqXgivWukixmNKFsgRohmHm9qkbbKkykfK8myxZitpKAfsfmLcsEgSRz0XQ(NyiTwivurmKAjKsqaP2aPYDB6TkrUyoj)KmwDoycDSQ)jgsRdPDmhsjiGu5Un9wLi5zWUMrhR6FIH06qAhZHuldkPRYbfXV3IBj65R6awhfA7QdGWiDNqxbfoDHgRdJhuCj43mOO3vfhlMZ(GI8EaFVhuemLcYfZj5NKXQZbtitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgDSQ)jgsRfsfvehusxLdk6DvXXI5SpacJi68qxbfoDHgRdJhuCj43mOq6nw6TgF4Oa7weuK3d479GIGPuqUyoj)KmwDoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZOJv9pXqATqQOJgusxLdkKEJLERXhokWUfbqyerfn0vqHtxOX6W4bfxc(ndkc2tUjhfyo6nvpDzqrEpGV3dkcMsb5I5K8tYy15GjKPhsjiGubtPGKNb7Agz6dkPRYbfb7j3KJcmh9MQNUmacJiQDHUckC6cnwhgpO4sWVzqrLp2cWKJJfpjdkY7b89EqXgiDmi98xhzXCcqUwJrCnFmadPeeq65VoYI5eGCTgJ(esRdPIokKAjKsqaP4EU1Ia)izagPFXFYrmypviT(aKAxqjDvoOOYhBbyYXXINKbqyer7i0vqHtxOX6W4bfxc(ndk9ntQ5tG9tJJLMJTiOiVhW37bfbtPGCXCs(jzS6CWeY0dPeeqQGPuqYZGDnJm9qQvivWuki5zWUMryGlTasRpaPIohsjiGu5Un9wLixmNKFsgRohmHow1)edP1HurokKsqaPJbPcMsbjpd21mY0dPwHu5Un9wLi5zWUMrhR6FIH06qQihnOKUkhu6BMuZNa7NghlnhBraegrurg6kOWPl0yDy8GIlb)Mbfb(W8zbF4y3mDZeuK3d479GIGPuqUyoj)KmwDoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZimWLwaP1hGurNdPeeqQC3MERsKlMtYpjJvNdMqhR6FIH06qQihfsjiG0XGubtPGKNb7Agz6HuRqQC3MERsK8myxZOJv9pXqADivKJgusxLdkc8H5Zc(WXUz6MjacJi6OHUckC6cnwhgpO4sWVzqHtDJX4i4tjWCCClXY5sWVP3I9BfFbf59a(EpOiykfKlMtYpjJvNdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21mcdCPfqA9biv05qkbbKk3TP3Qe5I5K8tYy15Gj0XQ(NyiToKkYrHuccivUBtVvjsEgSRz0XQ(NyiToKkYrdkPRYbfo1ngJJGpLaZXXTelNlb)MEl2Vv8faHreTgg6kOWPl0yDy8GIlb)MbLE2Vwu)I5dhLRAVJXbf59a(EpOiykfKlMtYpjJvNdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21mcdCPfqA9biv05bL0v5Gsp7xlQFX8HJYvT3X4aimIO1GqxbfoDHgRdJhuCj43mOu(ddIQoGXrCV9KnhJdkY7b89EqrWukixmNKFsgRohmHm9qkbbKkykfK8myxZitpKAfsfmLcsEgSRz0XQ(NyiT2biv0rdkPRYbLYFyqu1bmoI7TNS5yCaegrurCORGcNUqJ1HXdkUe8BguK7DMEaRJKnx)oypCuL1ER9BguK3d479GIGPuqUyoj)KmwDoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZOJv9pXqATqQDZdkPRYbf5ENPhW6izZ1Vd2dhvzT3A)Mbqyer7oHUckC6cnwhgpO4sWVzqrU3z6bSos2C97G9WrbxtYbf59a(EpOiykfKlMtYpjJvNdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21m6yv)tmKwlKk6ObL0v5GICVZ0dyDKS563b7HJcUMKdGWi2np0vqHtxOX6W4bL0v5Gs19GPpjJyMuLtqClr9XyGt6GPGIlb)MbLQ7btFsgXmPkNG4wI6JXaN0btbqye7en0vqHtxOX6W4bfxc(ndk4PvAHWd4dhlEsguK3d479GIGPuqUyoj)KmwDoycz6HuccivWuki5zWUMrM(Gs6QCqbpTsleEaF4yXtYaimID2f6kOWPl0yDy8Gs6QCqP9I)KmUFlk98Xa(ckUe8BguAV4pjJ73IspFmGVaimIDDe6kOWPl0yDy8GIlb)MbL7bgVflSdM4lULOjtYOBrqrEpGV3dkcMsb5I5K8tYy15GjKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJWaxAbKoaPIohsjiGu5Un9wLixmNKFsgRohmHow1)edP1hG0oMdPeeqQC3MERsK8myxZOJv9pXqA9biTJ5bL0v5GY9aJ3If2bt8f3s0Kjz0TiacJyNidDfu40fASomEqjDvoOCS6c4iP51Ek5OMf)soO4sWVzq5y1fWrsZR9uYrnl(LCaegXUrdDfu40fASomEqjDvoOi(9wClrmypvCqXLGFZGI43BXTeXG9uXbqye7QHHUckC6cnwhgpO4sWVzqPA6Vw1NK4yFZO6KCqrEpGV3dkcMsb5I5K8tYy15GjKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJow1)edP1oaP2npOKUkhuQM(Rv9jjo23mQojhaHrSRge6kOWPl0yDy8GIlb)Mbf9XUos2C97G9WrbxtYbf59a(EpOiykfKlMtYpjJvNdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21m6yv)tmKw7aKA38Gs6QCqrFSRJKnx)oypCuW1KCaegXorCORGcNUqJ1HXdkUe8Bgu0h76OJ7)ZtaoQYAV1(ndkY7b89EqrWukixmNKFsgRohmHm9qkbbKkykfK8myxZitpKAfsfmLcsEgSRz0XQ(NyiT2bi1U5bL0v5GI(yxhDC)FEcWrvw7T2VzaegXUUtORGcNUqJ1HXdkUe8BguiVnjXX(7v9w8CsoOiVhW37bLXGubtPGCXCs(jzS6CWeY0dPwH0XGubtPGKNb7Agz6dkPRYbfYBtsCS)EvVfpNKdGWiDmp0vqHtxOX6W4bfxc(ndk4pFmGVizZ1Vd2dhfCnjhuK3d479GIGPuqUyoj)KmwDoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZOJv9pXqATdqQOJgusxLdk4pFmGVizZ1Vd2dhfCnjhaHr6q0qxbfoDHgRdJhuCj43mOG)8Xa(IKnx)oypCuL1ER9BguK3d479GIGPuqUyoj)KmwDoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZOJv9pXqATdqQDZdkPRYbf8NpgWxKS563b7HJQS2BTFZaimsh2f6kOWPl0yDy8GIlb)MbfVgXt(54yztqClX(TIVGI8EaFVhugdsbEJtasEgSRzeNUqJ1qQvivUBtVvjYfZj5NKXQZbtOJv9pXqATq6OqkbbKc8gNaK8myxZioDHgRHuRqQC3MERsK8myxZOJv9pXqATq6OqQvif8QmKwhsfDoKsqaPtBZ(y)wXhKwFas7asTcPGxLH0AHurNdPwHuG34eGQCl44wIoEIXioDHgRdkPRYbfVgXt(54yztqClX(TIVaimshDe6kOWPl0yDy8GIlb)MbfXp(3mULOMvFmhuK3d479GIGPuqUyoj)KmwDoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZimWLwaPdqQOZHuccivUBtVvjYfZj5NKXQZbtOJv9pXqA9biTJ5qkbbKk3TP3Qejpd21m6yv)tmKwFas7yEqjDvoOi(X)MXTe1S6J5aimshIm0vqHtxOX6W4bfxc(ndkoEsSNmoEEnUxuUN3ckY7b89EqrZcMsbDEnUxuUN3IAwWuki9wLqkbbKAdKkykfKlMtYpjJvNdMqhR6FIH06dqQDZHuccivWuki5zWUMryGlTashGurNdPwHubtPGKNb7AgDSQ)jgsRdPIokKAjKAfsTbsL720BvIin(PFpJBj61iFlycDSQ)jgsRdPDN5qkbbKcEvoc2O(ziTwiTJ5qkbbKogKYymNsgj3uZjM1X2x4YEsgP6DBpi1YGs6QCqXXtI9KXXZRX9IY98waegPJrdDfu40fASomEqXLGFZGIf5cIBj6P85eelMZ(GI8EaFVhuemLcYfZj5NKXQZbtitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgHbU0ciT(aKk6CiLGasL720BvICXCs(jzS6CWe6yv)tmKwhs7yoKsqaPJbPcMsbjpd21mY0dPwHu5Un9wLi5zWUMrhR6FIH06qAhZdkPRYbflYfe3s0t5ZjiwmN9bqyKoQHHUckC6cnwhgpOiVhW37bLXGubtPGCXCs(jzS6CWeY0dPwH0XGubtPGKNb7Agz6dkUe8BguC8eNXjV12Qaimsh1GqxbfoDHgRdJhuK3d479GInq602Sp2Vv8bP1hGurcPwHuWRYqATq6OqkbbKoTn7J9BfFqA9biTdi1kKcEvgsRdPJcPeeqkWBCcqtBZ(OlMts(qC6cnwdPwHu5Un9wLOPTzF0fZjjFOJv9pXq6aKohsTesTcPGxLJGno1tcPdq68GIlb)MbfxmNKFsgRohmfaHr6qeh6kOWPl0yDy8GI8EaFVhuSbsN2M9X(TIpiT(aKksi1kKcEvgsRfshfsjiG0PTzFSFR4dsRpaPDaPwHuWRYqADiDuiLGasbEJtaAAB2hDXCsYhItxOXAi1kKk3TP3QenTn7JUyoj5dDSQ)jgshG05qQLqQvif8QCeSXPEsiDasNhuCj43mOipd21CaegPJUtORGcNUqJ1HXdkY7b89Eqb8QCeSXPEsiDasNdPwHuBGuBGubtPGCXCs(jzS6CWeY0dPeeqQGPuqYZGDnJm9qQLqkbbKAdKkykfKlMtYpjJvNdMq6TkHuRqQC3MERsKlMtYpjJvNdMqhR6FIH06qQiNdPeeqQGPuqYZGDnJ0BvcPwHu5Un9wLi5zWUMrhR6FIH06qQiNdPwcPwguCj43mOmTn7JUyoj5lacJiY5HUckC6cnwhgpOiVhW37bLPTzFSFR4dsRpaPDaPwHu5Un9wLixmNKFsgRohmHow1)edP1HusPgsTcPGxLJGno1tcPdq6Ci1kKAdKogKc8gNaeMpVF6vrC6cnwdPeeqQGPuqy(8(Pxfz6HuldkUe8BgukF6T4Xsl28tYaimIifn0vqHtxOX6W4bf59a(EpOaEvgsRDasTdsjiGubtPGowArJX4yzpjJm9bfxc(ndkGjoAsH1K6yzpjhaHrePDHUckC6cnwhgpOiVhW37bfbtPGCXCs(jzS6CWeY0dPeeqQGPuqYZGDnJm9qQvivWuki5zWUMryGlTashGurNhuCj43mOi02vh3semXrozv7dGWiISJqxbfoDHgRdJhuK3d479GYyqkWBCcqYZGDnJ40fASgsTcP2aPYDB6TkrUyoj)KmwDoycDSQ)jgsRfshfsTcPtBZ(y)wXhKwFas7asjiGu5Un9wLixmNKFsgRohmHow1)edP1hGurokKAjKsqaP2aPaVXjajpd21mItxOXAi1kKk3TP3Qejpd21m6yv)tmKwlKsk1qQviDAB2h73k(G06dqQiHuccivUBtVvjsEgSRz0XQ(NyiT(aKkYrHuldkUe8Bguin(PFpJBj61iFlykacJisrg6kOWPl0yDy8GI8EaFVhuK720BvICXCs(jzS6CWe6yv)tmKwlKsk1qQviDAB2h73k(G06dqAhqkbbKc8gNaK8myxZioDHgRHuRqQC3MERsK8myxZOJv9pXqATqkPudPwH0PTzFSFR4dsRpaPIesjiGu5Un9wLixmNKFsgRohmHow1)edP1hGurokKsqaPYDB6TkrYZGDnJow1)edP1hGuroAqXLGFZGs1EnTy(Z4X4n9uYbqyeroAORGcNUqJ1HXdkY7b89EqXgiDmi98xhzXCcqUwJrCnFmadPeeq65VoYI5eGCTgJ(esRdPDmhsjiGuCp3ArGFKmaJ0V4p5igSNkKwFasTdsTesTcPJbP2aPcMsb5I5K8tYy15GjKPhsjiGubtPGKNb7Agz6HulHuRqQnqQC3MERsKqZ1CClXUzWGxYOJv9pXqADiLuQHuras7asTcPYDB6TkrDZOjv5eGow1)edP1HusPgsfbiTdi1YGIlb)MbLYknywh9AKVhWrb2vdGWiISgg6kOWPl0yDy8GI8EaFVhuSbsfmLcYfZj5NKXQZbtitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgHbU0ciDasfDoKAjKAfsN2M9X(TIpiT2biTJGIlb)MbfvwDp7JBj2mYxh1h7Q4aimIiRbHUckC6cnwhgpOiVhW37bfBG0XG0ZFDKfZja5AngX18XamKsqaPN)6ilMtaY1Am6tiToK2XCiLGasX9CRfb(rYams)I)KJyWEQqA9bi1oi1YGIlb)MbLEZ9f7)Kmk0CmiacGaiO4gW0EbfLUNHBoyVaiacba]] )


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
