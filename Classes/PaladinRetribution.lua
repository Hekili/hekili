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

        reckoning = {
            id = 343724,
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
            duration = 8,
            max_stack = 1
        },

        blessing_of_dusk = {
            id = 337757,
            duration = 8,
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
                if buff.relentless_inquisitor.stack < 6 then
                    stat.haste = stat.haste + 0.01
                end
                addStack( "relentless_inquisitor" )
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

            spend = 0.09,
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

                if buff.empyrean_power.up or buff.divine_purpose.up then
                    removeBuff( "divine_purpose" )
                    removeBuff( "empyrean_power" )
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

            toggle = "cooldowns",

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
            charges = function () return legendary.vanguards_momentum.enabled and 2 or nil end,
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

                if legendary.vanguards_momentum.enabled then
                    addStack( "vanguards_momentum" )
                end
            end,

            auras = {
                vanguards_momentum = {
                    id = 345046,
                    duration = 8,
                    max_stack = 3
                }
            }
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


    spec:RegisterPack( "Retribution", 20201118, [[dy0GJbqifv9ifIKnrP8jkPOgfLWPOeTkcGxPq1SOuzxq9lfvgMIYXiqltI0ZKkmncORPqABkeLVraQXraY5OKcRtHOQMNeX9uW(KOoOcrfTqfkpuHivUOcrQ6Jkev4KusrALsfntfIuStPsnufIkTukPiEkjMQujFvHiLgRcrv2RG)k0Gr6WuTyc9yIMmPUmQnlPpJOrRiNwLvRq41usMTuUnjTBr)wPHlvDCfIy5Q65qMoW1Py7e03LW4PKQZtPQ1tjLMpc7h0bbdDfu0oGdDx6SsNjOGckGWcAnMzneCKfua23ZbLExALtYbL0v5GI1eg8NObCBgu6D7BRRdDfuqR5LCqjOiAUgWAAgedkAhWHUlDwPZeuqbfqybTgZSgckWGcQNLHUfWZcktNwZzqmOOzKmOmsbPwtyWFIgWTjKoY1BU(syNJuqA3RqwvKFivqbSDqAPZkDwqP)3614GYifKAnHb)jAa3Mq6ixV56lHDosbPDVczvr(HubfW2bPLoR0zWoHD6sWTjc3)SCvfDW4dZ5V0toc2)5ea7esHDosbPJ0BDwAaSgszH8BpKcovgsbtmK6sW(q6HGuxOFnxSXyyNUeCBIgEw0yfd70LGBt04dZj9wl6sWTzSDiGDPRYdYDB6TirWoDj42en(WCsV1IUeCBgBhcyx6Q8ajN87G9rWoHuyNUeCBIWYDB6Tird9l420URoyHOPwXITD1ndcGF2LaccrtTIDHCsEjzS4DWe20Bt0uRyxiNKxsglEhmHFw1VevwqbebHOPwXY3GCnJn92en1kw(gKRz8ZQ(LOskDulHD6sWTjcl3TP3Ien(WCTJCcGIJWOjv5ey3vhq9CRfb(tYaeUDKtauCegnPkNGYdLsqyX8VF6ilKta21AeMT(HaicI3pDKfYja7AncFzzb8Owc70LGBtewUBtVfjA8H5Q3ZITD12D1brtTIDHCsEjzS4DWe20tqiAQvS8nixZytVnrtTILVb5AgJaU0QbbNb70LGBtewUBtVfjA8H5qth30XTgfYjj7PKHD6sWTjcl3TP3Ien(WCIngHUKmU1iYOQYpStxcUnry5Un9wKOXhMtSXi0LKXTgDdWOMWoDj42eHL720BrIgFyoXgJqxsg3AS4sa)WoDj42eHL720BrIgFyoXgJqxsg3Ae1)xsc70LGBtewUBtVfjA8H5mioEaw1U0v5H3TwTjTcffpY4Z6OOba2e2Plb3MiSC3MEls04dZzqC8aSQDPRYdoAsONmk(U1UFuUV3S7QdAw0uR43T29JY99wuZIMAfR3IKGWcrtTIDHCsEjzS4DWe(zv)su5HsNrqiAQvS8nixZyeWLwni4mBIMAflFdY1m(zv)suzbh1sBwi3TP3IetA8xFEg3A0Tw(xWe(zv)suzRXmccG)Kmadovoc2O(4s6ygbX8mcXPKXYn1CIyDSDvUUVKXQ(i23syNUeCBIWYDB6TirJpmNbXXdWQ2LUkpmcgfN2Ig)2D1brtTIDHCsEjzS4DWe20tqiAQvS8nixZytVnrtTILVb5AgJaU0QbbNb70LGBtewUBtVfjA8H5mioEaw1U0v5bHN3IBn65P6awhfB7QT7QdwiAQvSlKtYljJfVdMWMEccrtTILVb5AgB6TjAQvS8nixZ4Nv9lrLiOaYscclK720BrIDHCsEjzS4DWe(zv)su5oMrqi3TP3IelFdY1m(zv)su5oMzjStxcUnry5Un9wKOXhMZG44byv7sxLh07QIIvZBVDxDq0uRyxiNKxsglEhmHn9eeIMAflFdY1m20Bt0uRy5BqUMXpR6xIkrqbeStxcUnry5Un9wKOXhMZG44byv7sxLhi9gl9wJFuuKDRS7QdIMAf7c5K8sYyX7GjSPNGq0uRy5BqUMXMEBIMAflFdY1m(zv)sujcokStxcUnry5Un9wKOXhMZG44byv7sxLheTNCtokYC0BQE6s7U6GOPwXUqojVKmw8oycB6jien1kw(gKRzSPh2Plb3MiSC3MEls04dZzqC8aSQDPRYdQ8ZwbMCuS6jPDxDWI5F)0rwiNaSR1imB9dbqeeVF6ilKta21Ae(YYcoQLeeOEU1Ia)jzacRpHxYreyF1YdLc70LGBtewUBtVfjA8H5mioEaw1U0v5H(Mj18lY(RrXAZrwz3vhen1k2fYj5LKXI3btytpbHOPwXY3GCnJn92en1kw(gKRzmc4sRkpi4mcc5Un9wKyxiNKxsglEhmHFw1VevwGJsqmVOPwXY3GCnJn92K720BrILVb5Ag)SQFjQSahf2Plb3MiSC3MEls04dZzqC8aSQDPRYdI8J43k(rXrygHXURoiAQvSlKtYljJfVdMWMEccrtTILVb5AgB6TjAQvS8nixZyeWLwvEqWzeeYDB6TiXUqojVKmw8oyc)SQFjQSahLGyErtTILVb5AgB6Tj3TP3IelFdY1m(zv)suzbokStxcUnry5Un9wKOXhMZG44byv7sxLh4u3yekcUucmph3AS(UeCB6Ty)wWVDxDq0uRyxiNKxsglEhmHn9eeIMAflFdY1m20Bt0uRy5BqUMXiGlTQ8GGZiiK720BrIDHCsEjzS4DWe(zv)suzbokbHC3MElsS8nixZ4Nv9lrLf4OWoDj42eHL720BrIgFyodIJhGvTlDvEON9Vf1Nq(rr5Q27iKDxDq0uRyxiNKxsglEhmHn9eeIMAflFdY1m20Bt0uRy5BqUMXiGlTQ8GGZGD6sWTjcl3TP3Ien(WCgehpaRAx6Q8q9EeiQ6agfr92t2CeYURoiAQvSlKtYljJfVdMWMEccrtTILVb5AgB6TjAQvS8nixZ4Nv9lrLmi4OWoDj42eHL720BrIgFyodIJhGvTlDvEqU)B6bSos2C95G9rrvw7T2TPDxDq0uRyxiNKxsglEhmHn9eeIMAflFdY1m20Bt0uRy5BqUMXpR6xIkP0zWoDj42eHL720BrIgFyodIJhGvTlDvEqU)B6bSos2C95G9rrrxtY2D1brtTIDHCsEjzS4DWe20tqiAQvS8nixZytVnrtTILVb5Ag)SQFjQebhf2Plb3MiSC3MEls04dZzqC8aSQDPRYdf)bMUKmIysvobXTg1pJaoPdMGD6sWTjcl3TP3Ien(WCgehpaRAx6Q8aAALwjEa(rXQNK2D1brtTIDHCsEjzS4DWe20tqiAQvS8nixZytpStxcUnry5Un9wKOXhMZG44byv7sxLhANWljJ71IsppeGFyNUeCBIWYDB6TirJpmNbXXdWQ2LUkp8hW4TyLDWe)XTgnzsgDRS7QdIMAf7c5K8sYyX7GjSPNGq0uRy5BqUMXMEBIMAflFdY1mgbCPvdcoJGqUBtVfj2fYj5LKXI3bt4Nv9lrLh6ygbHC3MElsS8nixZ4Nv9lrLh6ygStxcUnry5Un9wKOXhMZG44byv7sxLhEwDbCK0CApLCuZcpjd70LGBtewUBtVfjA8H5mioEaw1U0v5bHN3IBnIa7RIGD6sWTjcl3TP3Ien(WCgehpaRAx6Q8qX09TIljrX(Mr1jz7U6GOPwXUqojVKmw8oycB6jien1kw(gKRzSP3MOPwXY3GCnJFw1VevYqPZGD6sWTjcl3TP3Ien(WCgehpaRAx6Q8G(zxhjBU(CW(OOORjz7U6GOPwXUqojVKmw8oycB6jien1kw(gKRzSP3MOPwXY3GCnJFw1VevYqPZGD6sWTjcl3TP3Ien(WCgehpaRAx6Q8G(zxhDu)9Ecqrvw7T2TPDxDq0uRyxiNKxsglEhmHn9eeIMAflFdY1m20Bt0uRy5BqUMXpR6xIkzO0zWoDj42eHL720BrIgFyodIJhGvTlDvEG83Kef7)t1BX3jz7U6W8IMAf7c5K8sYyX7GjSP328IMAflFdY1m20d70LGBtewUBtVfjA8H5mioEaw1U0v5b0LhcWFKS56Zb7JIIUMKT7QdIMAf7c5K8sYyX7GjSPNGq0uRy5BqUMXMEBIMAflFdY1m(zv)sujdcokStxcUnry5Un9wKOXhMZG44byv7sxLhqxEia)rYMRphSpkQYAV1UnT7QdIMAf7c5K8sYyX7GjSPNGq0uRy5BqUMXMEBIMAflFdY1m(zv)sujdLod2Plb3MiSC3MEls04dZzqC8aSQDPRYdU1IM83rX6MG4wJ9Bb)2D1H5bEJtaw(gKRzmNUyJ12K720BrIDHCsEjzS4DWe(zv)sujJsqa8gNaS8nixZyoDXgRTj3TP3IelFdY1m(zv)sujJAdCQCzbNrqmTn7J9Bb)Lh6Wg4u5seCMnG34eGlCR44wJoAIryoDXgRHD6sWTjcl3TP3Ien(WCgehpaRAx6Q8GWdDBg3AuZQhIT7QdIMAf7c5K8sYyX7GjSPNGq0uRy5BqUMXMEBIMAflFdY1mgbCPvdcoJGqUBtVfj2fYj5LKXI3bt4Nv9lrLh6ygbHC3MElsS8nixZ4Nv9lrLh6ygStxcUnry5Un9wKOXhMZG44byv7sxLhC0Kqpzu8DRD)OCFVz3vh0SOPwXVBT7hL77TOMfn1kwVfjbHfIMAf7c5K8sYyX7Gj8ZQ(LOYdLoJGq0uRy5BqUMXiGlTAqWz2en1kw(gKRz8ZQ(LOYcoQL2SqUBtVfjM04V(8mU1OBT8VGj8ZQ(LOYwJzeeGtLJGnQpUKoMrqmpJqCkzSCtnNiwhBxLR7lzSQpI9Te2Plb3MiSC3MEls04dZzqC8aSQDPRYdwLliU1ONYJtqSAE7T7QdIMAf7c5K8sYyX7GjSPNGq0uRy5BqUMXMEBIMAflFdY1mgbCPvLheCgbHC3MElsSlKtYljJfVdMWpR6xIk3XmcI5fn1kw(gKRzSP3MC3MElsS8nixZ4Nv9lrL7ygStxcUnry5Un9wKOXhMZG44byveStxcUnry5Un9wKOXhMZfYj5LKXI3bt2D1blM2M9X(TG)Ydc0g4u5sgLGyAB2h73c(lp0HnWPYLhLGa4nob4PTzF0fYjj)yoDXgRTj3TP3IepTn7JUqoj5h)SQFjAyML2aNkhbBCQNCygStxcUnry5Un9wKOXhMt(gKRz7U6GftBZ(y)wWF5bbAdCQCjJsqmTn7J9Bb)Lh6Wg4u5YJsqa8gNa802Sp6c5KKFmNUyJ12K720BrIN2M9rxiNK8JFw1VenmZsBGtLJGno1tomd2Plb3MiSC3MEls04dZ5OjoJtERTfWoDj42eHL720BrIgFyUPTzF0fYjj)2D1bWPYrWgN6jhMzZclen1k2fYj5LKXI3btytpbHOPwXY3GCnJn9wsqyHOPwXUqojVKmw8oycR3I0MC3MElsSlKtYljJfVdMWpR6xIklWzeeIMAflFdY1mwVfPn5Un9wKy5BqUMXpR6xIklWzwAjStxcUnry5Un9wKOXhMREP3IplTAZljT7QdtBZ(y)wWF5HoSj3TP3Ie7c5K8sYyX7Gj8ZQ(LOYKsTnWPYrWgN6jhMzZI5bEJtagXV3pDQyoDXgRjien1kgXV3pDQytVLWoDj42eHL720BrIgFyoWehnP4AsDSUVKT7QdGtLlzOuccrtTIFwAvJrOyDFjJn9WoDj42eHL720BrIgFyoX2U64wJGjoYjRAVDxDq0uRyxiNKxsglEhmHn9eeIMAflFdY1m20Bt0uRy5BqUMXiGlTAqWzWoDj42eHL720BrIgFyosJ)6ZZ4wJU1Y)cMS7QdZd8gNaS8nixZyoDXgRTzHC3MElsSlKtYljJfVdMWpR6xIkzuBtBZ(y)wWF5HoiiK720BrIDHCsEjzS4DWe(zv)su5bboQLeewa8gNaS8nixZyoDXgRTj3TP3IelFdY1m(zv)sujKsTTPTzFSFl4V8GajiK720BrILVb5Ag)SQFjQ8Gah1syNUeCBIWYDB6TirJpmxX(nTq(Y4ZOn9uY2D1b5Un9wKyxiNKxsglEhmHFw1VevcPuBBAB2h73c(lp0bbbWBCcWY3GCnJ50fBS2MC3MElsS8nixZ4Nv9lrLqk12M2M9X(TG)YdcKGqUBtVfj2fYj5LKXI3bt4Nv9lrLhe4OeeYDB6TiXY3GCnJFw1VevEqGJc70LGBtewUBtVfjA8H5QR0GyD0Tw(pahfzx1URoyX8VF6ilKta21AeMT(HaicI3pDKfYja7AncFz5oMrqG65wlc8NKbiS(eEjhrG9vlpuQL2M3crtTIDHCsEjzS4DWe20tqiAQvS8nixZytVL2SqUBtVfjwS5AoU14imiWjz8ZQ(LOYKsTa0Hn5Un9wK4ry0KQCcWpR6xIktk1cqhwc70LGBtewUBtVfjA8H5uz19TpU1yZipDu)SRIS7QdwiAQvSlKtYljJfVdMWMEccrtTILVb5AgB6TjAQvS8nixZyeWLwni4mlTnTn7J9Bb)Lm0bStxcUnry5Un9wKOXhMR38x1(ljJInhbS7Qdwm)7NoYc5eGDTgHzRFiaIG49thzHCcWUwJWxwUJzeeOEU1Ia)jzacRpHxYreyF1YdLAjStif2Plb3MiC9YdnXpA8H5e6)5In2U0v5bnkkDeWfBSDc9MHhq9CRfb(tYaewFcVKJiW(QLhkLGq0uRywT3(N9m2Vf8Jn920SOPwXJWOjv5eG1BrAt0uRy9j8so2B((fXy9wKeeOEU1Ia)jzacRpHxYreyF1YdLAt0uRy5BqUMXMEBIMAflFdY1mgbCPvLi4myNUeCBIW1lp0e)OXhMdXV3pDQ2D1blSyEG34eGLVb5AgZPl2yTnrtTIDHCsEjzS4DWe20tqi3TP3Ie7c5K8sYyX7Gj8ZQ(LOYLoQLeewiAQvS8nixZytpbHC3MElsS8nixZ4Nv9lrLlDulT0MfZd8gNaC9sVfFwA1MxsI50fBSMGqUBtVfjUEP3IplTAZljXpR6xIkrWzwAZI5bEJtaMTolnGBZiItaNsgZPl2ynbHC3MElsmBDwAa3MreNaoLm(zv)sujcoZsBGtLJGno1tomd2Plb3MiC9YdnXpA8H5e65iXCOj(rXjxvLF7U6GfZd8gNaC9sVfFwA1MxsI50fBSMGqUBtVfjUEP3IplTAZljXpR6xIktk1cGGZii0SOPwX1l9w8zPvBEjj20BPnlMh4noby26S0aUnJiobCkzmNUyJ1eeYDB6TiXS1zPbCBgrCc4uY4Nv9lrLjLAbqWzeeAw0uRy26S0aUnJiobCkzSP3sccup3ArG)KmaH1NWl5icSVA5HsHD6sWTjcxV8qt8JgFyo26S0aUnJiobCkz7U6aQNBTiWFsgGW6t4LCeb2xTKHoSzHfZd8gNaS8nixZyoDXgRjien1kw(gKRzSElsBYDB6TiXY3GCnJFw1VevwWzwsqiAQvS8nixZyeWLwvEOdcc5Un9wKyxiNKxsglEhmHFw1VevwWzeeAw0uR46LEl(S0QnVKeB6T0g4u5iyJt9KdZGD6sWTjcxV8qt8JgFyo9j8soIa7RA3vhe6)5IngRrrPJaUyJTnVOPwXc9CKyo0e)O4KRQYp20BZclMh4noby5BqUMXC6Inwtqi3TP3IelFdY1m(zv)suzsPwa6WsBwmpWBCcWS1zPbCBgrCc4uYyoDXgRjiK720BrIzRZsd42mI4eWPKXpR6xIktk1cqheeOEU1Ia)jzacRpHxYreyF1YdDyjbbQNBTiWFsgGW6t4LCeb2xT8qP2Sa4nob4PTzF0fYjj)yoDXgRTj3TP3IepTn7JUqoj5h)SQFjQesPwa6GGq0uRy5BqUMXMEBIMAflFdY1mgbCPvLi4mlTe2Plb3MiC9YdnXpA8H5aSAFZFuui)6tcS7QdwmpWBCcWY3GCnJ50fBSMGqUBtVfjw(gKRz8ZQ(LOYKsTa0HL2SyEG34eGzRZsd42mI4eWPKXC6Inwtqi3TP3IeZwNLgWTzeXjGtjJFw1VevMuQfGoSH65wlc8NKbiS(eEjhrG9vlzOdlTzX8YviNEcWjl)TTVgZPl2ynbHC3MElsSqphjMdnXpko5QQ8JFw1VevMuQTKGa4nob4PTzF0fYjj)yoDXgRTj3TP3IepTn7JUqoj5h)SQFjQesPwa6GGq0uR4PTzF0fYjj)ytpbHOPwXY3GCnJn92en1kw(gKRzmc4sRkrWzeeIMAfl0ZrI5qt8JItUQk)ytpStif2Plb3MimjN87G9rJpmN0BTOlb3MX2Ha2LUkpuV8qt8JS7QdtBZ(y)wWF5Hrjien1kEAB2hDHCsYp20tqOzrtTIRx6T4ZsR28ssSPNGqZIMAfZwNLgWTzeXjGtjJn9WoDj42eHj5KFhSpA8H50NWl5iyBn7U6W8Aw0uR4ry0KQCcWMEBwm)7NoYc5eGDTgHzRFiaIG49thzHCcWUwJWxwUJzwAZIPTzFSFl4VKHsjiM2M9X(TG)sgeOnlK720BrIfBUMJBnocdcCsg)SQFjQmPulaLsqOzrtTIzRZsd42mI4eWPKXMEccnlAQvC9sVfFwA1MxsIn9wAPnlMh4nob46LEl(S0QnVKeZPl2ynbHC3MElsC9sVfFwA1MxsIFw1VevMuQfabNzPnlMh4noby26S0aUnJiobCkzmNUyJ1eeYDB6TiXS1zPbCBgrCc4uY4Nv9lrLjLAbqWzwc70LGBteMKt(DW(OXhMRWTIJBn6Ojgz3vhSyAB2h73c(hMrqmTn7J9Bb)LmuQnlK720BrIfBUMJBnocdcCsg)SQFjQmPulaLsqOzrtTIzRZsd42mI4eWPKXMEccnlAQvC9sVfFwA1MxsIn9wAPnlM)9thzHCcWUwJWS1pearq8(PJSqobyxRr4llx6mlTzX8aVXjaZwNLgWTzeXjGtjJ50fBSMGqUBtVfjMTolnGBZiItaNsg)SQFjQSGJAPnlMh4nob46LEl(S0QnVKeZPl2ynbHC3MElsC9sVfFwA1MxsIFw1VevwWrTe2Plb3MimjN87G9rJpmNyZ1CCRXryqGtY2D1HPTzFSFl4VKHoGD6sWTjctYj)oyF04dZn5QQ8h3AS4DWKDxDyAB2h73c(lzqGWoDj42eHj5KFhSpA8H5gHrtQYjWURomVMfn1kEegnPkNaSP3MftBZ(y)wWFjdLsqmTn7J9Bb)LmiqBYDB6TiXInxZXTghHbbojJFw1VevMuQfGsTe2Plb3MimjN87G9rJpmN0BTOlb3MX2Ha2LUkpuV8qt8JS7Qdwa8NKb4j2BGjCVeuYqPZiien1k2fYj5LKXI3btytpbHOPwXY3GCnJn9eeIMAfZQ92)SNX(TGFSP3syNUeCBIWKCYVd2hn(WCY3GCn)re4pRy7U6GC3MElsS8nixZFeb(ZkglN8NKrX67sWTP3kpiiwapQnlM2M9X(TG)sgkLGyAB2h73c(lzOdBYDB6TiXInxZXTghHbbojJFw1VevMuQfGsjiM2M9X(TG)bbAtUBtVfjwS5AoU14imiWjz8ZQ(LOYKsTauQn5Un9wK4ry0KQCcWpR6xIktk1cqPwc70LGBteMKt(DW(OXhMt6Tw0LGBZy7qa7sxLhQxEOj(rWoDj42eHj5KFhSpA8H5KVb5A(JiWFwX2D1HPTzFSFl4VKbbc70LGBteMKt(DW(OXhMtUPKtW7awhRnxLHD6sWTjctYj)oyF04dZ9S3FjzS2Cvgz3vha(tYa8e7nWuSxcklGMrqa8NKb4j2BGPyVeusPZiiQh5ei(SQFjQKogf2Plb3MimjN87G9rJpmN)sp5iy)NtGDxDyAB2h73c(lzqGWoDj42eHj5KFhSpA8H5KBIy57GBt7U6a4u5iyJt9KLjL6GIq(r3MHUlDwPZeuWzc4GsH)5LKOGYiTJCAnPBRPDpYXiFifs7AIH0tTFFaKw3hsTMRxEOj(rwZq6ZJeZ9SgsrRkdPUbSQoG1qQCYtsgHHDosZLmKoYg5dPJ0TPq(bSgsTMLRqo9eGh5H50fBS2AgsblKAnlxHC6japYZAgsTqqRBjg2jStRPQ97dynKokK6sWTjK2oeaHHDguCdyA)GIYiXWnhSFqPDiak0vqrZv30aHUcDlyORGIlb3MbLNfnwXbfoDXgRdJfaHUln0vqHtxSX6WybfxcUndksV1IUeCBgBhceuAhcetxLdkYDB6TirbqO7ocDfu40fBSomwqXLGBZGI0BTOlb3MX2HabL2HaX0v5GcjN87G9rbqaeu6FwUQIoi0vOBbdDfuCj42mO4V0toc2)5eeu40fBSomwaeabfso53b7JcDf6wWqxbfoDXgRdJfuK)b4)8GY02Sp2Vf8dPLhG0rHucciv0uR4PTzF0fYjj)ytpKsqaPAw0uR46LEl(S0QnVKeB6HuccivZIMAfZwNLgWTzeXjGtjJn9bfxcUndksV1IUeCBgBhceuAhcetxLdk1lp0e)Oai0DPHUckC6InwhglOi)dW)5bL5HunlAQv8imAsvobytpKAdsTasNhsF)0rwiNaSR1imB9dbqqkbbK((PJSqobyxRr4lH0YqAhZGulHuBqQfq602Sp2Vf8dPLmaPLcPeeq602Sp2Vf8dPLmaPcesTbPwaPYDB6TiXInxZXTghHbbojJFw1VebPLHusPgsfaiTuiLGas1SOPwXS1zPbCBgrCc4uYytpKsqaPAw0uR46LEl(S0QnVKeB6HulHulHuBqQfq68qkWBCcW1l9w8zPvBEjjMtxSXAiLGasL720BrIRx6T4ZsR28ss8ZQ(LiiTmKsk1qQaaPcodsTesTbPwaPZdPaVXjaZwNLgWTzeXjGtjJ50fBSgsjiGu5Un9wKy26S0aUnJiobCkz8ZQ(LiiTmKsk1qQaaPcodsTmO4sWTzqrFcVKJGT1cGq3De6kOWPl2yDySGI8pa)NhuSasN2M9X(TGFiDasNbPeeq602Sp2Vf8dPLmaPLcP2GulGu5Un9wKyXMR54wJJWGaNKXpR6xIG0YqkPudPcaKwkKsqaPAw0uRy26S0aUnJiobCkzSPhsjiGunlAQvC9sVfFwA1MxsIn9qQLqQLqQni1ciDEi99thzHCcWUwJWS1peabPeeq67NoYc5eGDTgHVesldPLodsTesTbPwaPZdPaVXjaZwNLgWTzeXjGtjJ50fBSgsjiGu5Un9wKy26S0aUnJiobCkz8ZQ(LiiTmKk4OqQLqQni1ciDEif4nob46LEl(S0QnVKeZPl2ynKsqaPYDB6TiX1l9w8zPvBEjj(zv)seKwgsfCui1YGIlb3MbLc3koU1OJMyuae6wGHUckC6InwhglOi)dW)5bLPTzFSFl4hslzas7iO4sWTzqrS5AoU14imiWj5ai09OHUckC6InwhglOi)dW)5bLPTzFSFl4hslzasfyqXLGBZGYKRQYFCRXI3btbqO7rwORGcNUyJ1HXckY)a8FEqzEivZIMAfpcJMuLta20dP2GulG0PTzFSFl4hslzaslfsjiG0PTzFSFl4hslzasfiKAdsL720BrIfBUMJBnocdcCsg)SQFjcsldPKsnKkaqAPqQLbfxcUndkJWOjv5eeaHUfWHUckC6InwhglOi)dW)5bflGuG)KmapXEdmH7LaiTKbiT0zqkbbKkAQvSlKtYljJfVdMWMEiLGasfn1kw(gKRzSPhsjiGurtTIz1E7F2Zy)wWp20dPwguCj42mOi9wl6sWTzSDiqqPDiqmDvoOuV8qt8JcGq3cOqxbfoDXgRdJfuK)b4)8GIC3MElsS8nixZFeb(ZkglN8NKrX67sWTP3G0YdqQGyb8OqQni1ciDAB2h73c(H0sgG0sHucciDAB2h73c(H0sgG0oGuBqQC3MElsSyZ1CCRXryqGtY4Nv9lrqAziLuQHubaslfsjiG0PTzFSFl4hshGubcP2Gu5Un9wKyXMR54wJJWGaNKXpR6xIG0YqkPudPcaKwkKAdsL720BrIhHrtQYja)SQFjcsldPKsnKkaqAPqQLbfxcUndkY3GCn)re4pR4ai0T1i0vqHtxSX6WybfxcUndksV1IUeCBgBhceuAhcetxLdk1lp0e)Oai0TGZcDfu40fBSomwqr(hG)ZdktBZ(y)wWpKwYaKkWGIlb3Mbf5BqUM)ic8NvCae6wqbdDfuCj42mOi3uYj4DaRJ1MRYbfoDXgRdJfaHUfS0qxbfoDXgRdJfuK)b4)8GcWFsgGNyVbMI9saKwgsfqZGuccif4pjdWtS3atXEjaslbslDgKsqaP1JCceFw1VebPLaPDmAqXLGBZGYZE)LKXAZvzuae6wWocDfu40fBSomwqr(hG)ZdktBZ(y)wWpKwYaKkWGIlb3Mbf)LEYrW(pNGai0TGcm0vqHtxSX6Wybf5Fa(ppOaovoc24upjKwgsjL6GIlb3Mbf5Miw(o42macGGs9YdnXpk0vOBbdDfu40fBSomwqz7dkigeuCj42mOi0)ZfBCqrO3mCqb1ZTwe4pjdqy9j8soIa7RcPLhG0sHucciv0uRywT3(N9m2Vf8Jn9qQnivZIMAfpcJMuLtawVfjKAdsfn1kwFcVKJ9MVFrmwVfjKsqaPOEU1Ia)jzacRpHxYreyFviT8aKwkKAdsfn1kw(gKRzSPhsTbPIMAflFdY1mgbCPvqAjqQGZckc9pMUkhu0OO0raxSXbqO7sdDfu40fBSomwqr(hG)ZdkwaPwaPZdPaVXjalFdY1mMtxSXAi1gKkAQvSlKtYljJfVdMWMEiLGasL720BrIDHCsEjzS4DWe(zv)seKwgslDui1siLGasTasfn1kw(gKRzSPhsjiGu5Un9wKy5BqUMXpR6xIG0YqAPJcPwcPwcP2GulG05HuG34eGRx6T4ZsR28ssmNUyJ1qkbbKk3TP3IexV0BXNLwT5LK4Nv9lrqAjqQGZGulHuBqQfq68qkWBCcWS1zPbCBgrCc4uYyoDXgRHuccivUBtVfjMTolnGBZiItaNsg)SQFjcslbsfCgKAjKAdsbNkhbBCQNeshG0zbfxcUndki(9(PtnacD3rORGcNUyJ1HXckY)a8FEqXciDEif4nob46LEl(S0QnVKeZPl2ynKsqaPYDB6TiX1l9w8zPvBEjj(zv)seKwgsjLAivaGubNbPeeqQMfn1kUEP3IplTAZljXMEi1si1gKAbKopKc8gNamBDwAa3MreNaoLmMtxSXAiLGasL720BrIzRZsd42mI4eWPKXpR6xIG0YqkPudPcaKk4miLGas1SOPwXS1zPbCBgrCc4uYytpKAjKsqaPOEU1Ia)jzacRpHxYreyFviT8aKwAqXLGBZGIqphjMdnXpko5QQ8haHUfyORGcNUyJ1HXckY)a8FEqb1ZTwe4pjdqy9j8soIa7RcPLmaPDaP2GulGulG05HuG34eGLVb5AgZPl2ynKsqaPIMAflFdY1mwVfjKAdsL720BrILVb5Ag)SQFjcsldPcodsTesjiGurtTILVb5AgJaU0kiT8aK2bKsqaPYDB6TiXUqojVKmw8oyc)SQFjcsldPcodsjiGunlAQvC9sVfFwA1MxsIn9qQLqQnifCQCeSXPEsiDasNfuCj42mOWwNLgWTzeXjGtjhaHUhn0vqHtxSX6Wybf5Fa(ppOi0)ZfBmwJIshbCXgdP2G05HurtTIf65iXCOj(rXjxvLFSPhsTbPwaPwaPZdPaVXjalFdY1mMtxSXAiLGasL720BrILVb5Ag)SQFjcsldPKsnKkaqAhqQLqQni1ciDEif4noby26S0aUnJiobCkzmNUyJ1qkbbKk3TP3IeZwNLgWTzeXjGtjJFw1VebPLHusPgsfaiTdiLGasr9CRfb(tYaewFcVKJiW(QqA5biTdi1siLGasr9CRfb(tYaewFcVKJiW(QqA5biTui1gKAbKc8gNa802Sp6c5KKFmNUyJ1qQnivUBtVfjEAB2hDHCsYp(zv)seKwcKsk1qQaaPDaPeeqQOPwXY3GCnJn9qQniv0uRy5BqUMXiGlTcslbsfCgKAjKAzqXLGBZGI(eEjhrG9vdGq3JSqxbfoDXgRdJfuK)b4)8GIfq68qkWBCcWY3GCnJ50fBSgsjiGu5Un9wKy5BqUMXpR6xIG0YqkPudPcaK2bKAjKAdsTasNhsbEJtaMTolnGBZiItaNsgZPl2ynKsqaPYDB6TiXS1zPbCBgrCc4uY4Nv9lrqAziLuQHubas7asTbPOEU1Ia)jzacRpHxYreyFviTKbiTdi1si1gKAbKopKkxHC6jaNS832(AiLGasL720BrIf65iXCOj(rXjxvLF8ZQ(LiiTmKsk1qQLqkbbKc8gNa802Sp6c5KKFmNUyJ1qQnivUBtVfjEAB2hDHCsYp(zv)seKwcKsk1qQaaPDaPeeqQOPwXtBZ(OlKts(XMEiLGasfn1kw(gKRzSPhsTbPIMAflFdY1mgbCPvqAjqQGZGucciv0uRyHEosmhAIFuCYvv5hB6dkUeCBguaSAFZFuui)6tccGaiOi3TP3Ief6k0TGHUckC6InwhglOi)dW)5bflGurtTIfB7QBgea)SlbqkbbKkAQvSlKtYljJfVdMWMEi1gKkAQvSlKtYljJfVdMWpR6xIG0YqQGciiLGasfn1kw(gKRzSPhsTbPIMAflFdY1m(zv)seKwcKw6OqQLbfxcUndk9l42macDxAORGcNUyJ1HXckY)a8FEqb1ZTwe4pjdq42robqXry0KQCcG0YdqAPqkbbKAbKopK((PJSqobyxRry26hcGGucci99thzHCcWUwJWxcPLHub8OqQLbfxcUndkTJCcGIJWOjv5eeaHU7i0vqHtxSX6Wybf5Fa(ppOiAQvSlKtYljJfVdMWMEiLGasfn1kw(gKRzSPhsTbPIMAflFdY1mgbCPvq6aKk4SGIlb3MbL69SyBxDae6wGHUckUeCBguqth30XTgfYjj7PKdkC6InwhglacDpAORGIlb3MbfXgJqxsg3Aezuv5pOWPl2yDySai09il0vqXLGBZGIyJrOljJBn6gGrndkC6InwhglacDlGdDfuCj42mOi2ye6sY4wJfxc4pOWPl2yDySai0Tak0vqXLGBZGIyJrOljJBnI6)ljdkC6InwhglacDBncDfu40fBSomwqjDvoO8U1QnPvOO4rgFwhfnaWMbfxcUndkVBTAtAfkkEKXN1rrdaSzae6wWzHUckC6InwhglO4sWTzqXrtc9KrX3T29JY99wqr(hG)ZdkAw0uR43T29JY99wuZIMAfR3IesjiGulGurtTIDHCsEjzS4DWe(zv)seKwEaslDgKsqaPIMAflFdY1mgbCPvq6aKk4mi1gKkAQvS8nixZ4Nv9lrqAzivWrHulHuBqQfqQC3MElsmPXF95zCRr3A5Fbt4Nv9lrqAzi1AmdsjiGuG)Kmadovoc2O(yiTeiTJzqkbbKopKYieNsgl3uZjI1X2v56(sgR6JyFi1YGs6QCqXrtc9KrX3T29JY99wae6wqbdDfu40fBSomwqXLGBZGYiyuCAlA8huK)b4)8GIOPwXUqojVKmw8oycB6Hucciv0uRy5BqUMXMEi1gKkAQvS8nixZyeWLwbPdqQGZckPRYbLrWO40w04pacDlyPHUckC6InwhglO4sWTzqr45T4wJEEQoG1rX2U6GI8pa)NhuSasfn1k2fYj5LKXI3btytpKsqaPIMAflFdY1m20dP2GurtTILVb5Ag)SQFjcslbsfuabPwcPeeqQfqQC3MElsSlKtYljJfVdMWpR6xIG0YqAhZGuccivUBtVfjw(gKRz8ZQ(LiiTmK2Xmi1YGs6QCqr45T4wJEEQoG1rX2U6ai0TGDe6kOWPl2yDySGIlb3Mbf9UQOy182huK)b4)8GIOPwXUqojVKmw8oycB6Hucciv0uRy5BqUMXMEi1gKkAQvS8nixZ4Nv9lrqAjqQGcOGs6QCqrVRkkwnV9bqOBbfyORGcNUyJ1HXckUeCBgui9gl9wJFuuKDRckY)a8FEqr0uRyxiNKxsglEhmHn9qkbbKkAQvS8nixZytpKAdsfn1kw(gKRz8ZQ(LiiTeivWrdkPRYbfsVXsV14hffz3Qai0TGJg6kOWPl2yDySGIlb3Mbfr7j3KJImh9MQNUmOi)dW)5bfrtTIDHCsEjzS4DWe20dPeeqQOPwXY3GCnJn9bL0v5GIO9KBYrrMJEt1txgaHUfCKf6kOWPl2yDySGIlb3Mbfv(zRatokw9KmOi)dW)5bflG05H03pDKfYja7AncZw)qaeKsqaPVF6ilKta21Ae(siTmKk4OqQLqkbbKI65wlc8NKbiS(eEjhrG9vH0YdqAPbL0v5GIk)SvGjhfREsgaHUfuah6kOWPl2yDySGIlb3MbL(Mj18lY(RrXAZrwfuK)b4)8GIOPwXUqojVKmw8oycB6Hucciv0uRy5BqUMXMEi1gKkAQvS8nixZyeWLwbPLhGubNbPeeqQC3MElsSlKtYljJfVdMWpR6xIG0YqQahfsjiG05HurtTILVb5AgB6HuBqQC3MElsS8nixZ4Nv9lrqAzivGJgusxLdk9ntQ5xK9xJI1MJSkacDlOak0vqHtxSX6WybfxcUndkI8J43k(rXrygHjOi)dW)5bfrtTIDHCsEjzS4DWe20dPeeqQOPwXY3GCnJn9qQniv0uRy5BqUMXiGlTcslpaPcodsjiGu5Un9wKyxiNKxsglEhmHFw1VebPLHubokKsqaPZdPIMAflFdY1m20dP2Gu5Un9wKy5BqUMXpR6xIG0YqQahnOKUkhue5hXVv8JIJWmctae6wqRrORGcNUyJ1HXckUeCBgu4u3yekcUucmph3AS(UeCB6Ty)wWFqr(hG)ZdkIMAf7c5K8sYyX7GjSPhsjiGurtTILVb5AgB6HuBqQOPwXY3GCnJraxAfKwEasfCgKsqaPYDB6TiXUqojVKmw8oyc)SQFjcsldPcCuiLGasL720BrILVb5Ag)SQFjcsldPcC0Gs6QCqHtDJrOi4sjW8CCRX67sWTP3I9Bb)bqO7sNf6kOWPl2yDySGIlb3MbLE2)wuFc5hfLRAVJqbf5Fa(ppOiAQvSlKtYljJfVdMWMEiLGasfn1kw(gKRzSPhsTbPIMAflFdY1mgbCPvqA5bivWzbL0v5Gsp7FlQpH8JIYvT3rOai0DPcg6kOWPl2yDySGIlb3MbL69iqu1bmkI6TNS5iuqr(hG)ZdkIMAf7c5K8sYyX7GjSPhsjiGurtTILVb5AgB6HuBqQOPwXY3GCnJFw1VebPLmaPcoAqjDvoOuVhbIQoGrruV9KnhHcGq3LwAORGcNUyJ1HXckUeCBguK7)MEaRJKnxFoyFuuL1ERDBguK)b4)8GIOPwXUqojVKmw8oycB6Hucciv0uRy5BqUMXMEi1gKkAQvS8nixZ4Nv9lrqAjqAPZckPRYbf5(VPhW6izZ1Nd2hfvzT3A3MbqO7s7i0vqHtxSX6WybfxcUndkY9FtpG1rYMRphSpkk6AsoOi)dW)5bfrtTIDHCsEjzS4DWe20dPeeqQOPwXY3GCnJn9qQniv0uRy5BqUMXpR6xIG0sGubhnOKUkhuK7)MEaRJKnxFoyFuu01KCae6Uubg6kOWPl2yDySGs6QCqP4pW0LKretQYjiU1O(zeWjDWuqXLGBZGsXFGPljJiMuLtqCRr9ZiGt6GPai0DPJg6kOWPl2yDySGIlb3Mbf00kTs8a8JIvpjdkY)a8FEqr0uRyxiNKxsglEhmHn9qkbbKkAQvS8nixZytFqjDvoOGMwPvIhGFuS6jzae6U0rwORGcNUyJ1HXckPRYbL2j8sY4ETO0Zdb4pO4sWTzqPDcVKmUxlk98qa(dGq3LkGdDfu40fBSomwqXLGBZGYFaJ3Iv2bt8h3A0Kjz0TkOi)dW)5bfrtTIDHCsEjzS4DWe20dPeeqQOPwXY3GCnJn9qQniv0uRy5BqUMXiGlTcshGubNbPeeqQC3MElsSlKtYljJfVdMWpR6xIG0YdqAhZGuccivUBtVfjw(gKRz8ZQ(LiiT8aK2XSGs6QCq5pGXBXk7Gj(JBnAYKm6wfaHUlvaf6kOWPl2yDySGs6QCq5z1fWrsZP9uYrnl8KCqXLGBZGYZQlGJKMt7PKJAw4j5ai0DPwJqxbfoDXgRdJfusxLdkcpVf3Aeb2xffuCj42mOi88wCRreyFvuae6UJzHUckC6InwhglO4sWTzqPy6(wXLKOyFZO6KCqr(hG)ZdkIMAf7c5K8sYyX7GjSPhsjiGurtTILVb5AgB6HuBqQOPwXY3GCnJFw1VebPLmaPLolOKUkhukMUVvCjjk23mQojhaHU7qWqxbfoDXgRdJfuCj42mOOF21rYMRphSpkk6AsoOi)dW)5bfrtTIDHCsEjzS4DWe20dPeeqQOPwXY3GCnJn9qQniv0uRy5BqUMXpR6xIG0sgG0sNfusxLdk6NDDKS56Zb7JIIUMKdGq3DuAORGcNUyJ1HXckUeCBgu0p76OJ6V3takQYAV1UndkY)a8FEqr0uRyxiNKxsglEhmHn9qkbbKkAQvS8nixZytpKAdsfn1kw(gKRz8ZQ(LiiTKbiT0zbL0v5GI(zxhDu)9Ecqrvw7T2Tzae6UJocDfu40fBSomwqXLGBZGc5Vjjk2)NQ3IVtYbf5Fa(ppOmpKkAQvSlKtYljJfVdMWMEi1gKopKkAQvS8nixZytFqjDvoOq(BsII9)P6T47KCae6Udbg6kOWPl2yDySGIlb3Mbf0LhcWFKS56Zb7JIIUMKdkY)a8FEqr0uRyxiNKxsglEhmHn9qkbbKkAQvS8nixZytpKAdsfn1kw(gKRz8ZQ(LiiTKbivWrdkPRYbf0LhcWFKS56Zb7JIIUMKdGq3DmAORGcNUyJ1HXckUeCBguqxEia)rYMRphSpkQYAV1UndkY)a8FEqr0uRyxiNKxsglEhmHn9qkbbKkAQvS8nixZytpKAdsfn1kw(gKRz8ZQ(LiiTKbiT0zbL0v5Gc6Ydb4ps2C95G9rrvw7T2Tzae6UJrwORGcNUyJ1HXckUeCBguCRfn5VJI1nbXTg73c(dkY)a8FEqzEif4noby5BqUMXC6InwdP2Gu5Un9wKyxiNKxsglEhmHFw1VebPLaPJcPeeqkWBCcWY3GCnJ50fBSgsTbPYDB6TiXY3GCnJFw1VebPLaPJcP2GuWPYqAzivWzqkbbKoTn7J9Bb)qA5biTdi1gKcovgslbsfCgKAdsbEJtaUWTIJBn6OjgH50fBSoOKUkhuCRfn5VJI1nbXTg73c(dGq3DiGdDfu40fBSomwqXLGBZGIWdDBg3AuZQhIdkY)a8FEqr0uRyxiNKxsglEhmHn9qkbbKkAQvS8nixZytpKAdsfn1kw(gKRzmc4sRG0bivWzqkbbKk3TP3Ie7c5K8sYyX7Gj8ZQ(LiiT8aK2XmiLGasL720BrILVb5Ag)SQFjcslpaPDmlOKUkhueEOBZ4wJAw9qCae6UdbuORGcNUyJ1HXckUeCBguC0Kqpzu8DRD)OCFVfuK)b4)8GIMfn1k(DRD)OCFVf1SOPwX6TiHucci1civ0uRyxiNKxsglEhmHFw1VebPLhG0sNbPeeqQOPwXY3GCnJraxAfKoaPcodsTbPIMAflFdY1m(zv)seKwgsfCui1si1gKAbKk3TP3IetA8xFEg3A0Tw(xWe(zv)seKwgsTgZGuccifCQCeSr9XqAjqAhZGucciDEiLrioLmwUPMteRJTRY19Lmw1hX(qQLbL0v5GIJMe6jJIVBT7hL77Tai0DhwJqxbfoDXgRdJfuCj42mOyvUG4wJEkpobXQ5TpOi)dW)5bfrtTIDHCsEjzS4DWe20dPeeqQOPwXY3GCnJn9qQniv0uRy5BqUMXiGlTcslpaPcodsjiGu5Un9wKyxiNKxsglEhmHFw1VebPLH0oMbPeeq68qQOPwXY3GCnJn9qQnivUBtVfjw(gKRz8ZQ(LiiTmK2XSGs6QCqXQCbXTg9uECcIvZBFae6wGZcDfuCj42mOyqC8aSkkOWPl2yDySai0Tafm0vqHtxSX6Wybf5Fa(ppOybKoTn7J9Bb)qA5bivGqQnifCQmKwcKokKsqaPtBZ(y)wWpKwEas7asTbPGtLH0Yq6OqkbbKc8gNa802Sp6c5KKFmNUyJ1qQnivUBtVfjEAB2hDHCsYp(zv)seKoaPZGulHuBqk4u5iyJt9Kq6aKolO4sWTzqXfYj5LKXI3btbqOBbwAORGcNUyJ1HXckY)a8FEqXciDAB2h73c(H0YdqQaHuBqk4uziTeiDuiLGasN2M9X(TGFiT8aK2bKAdsbNkdPLH0rHuccif4nob4PTzF0fYjj)yoDXgRHuBqQC3MEls802Sp6c5KKF8ZQ(LiiDasNbPwcP2GuWPYrWgN6jH0biDwqXLGBZGI8nixZbqOBb2rORGIlb3MbfhnXzCYBTTiOWPl2yDySai0TafyORGcNUyJ1HXckY)a8FEqbCQCeSXPEsiDasNbP2GulGulGurtTIDHCsEjzS4DWe20dPeeqQOPwXY3GCnJn9qQLqkbbKAbKkAQvSlKtYljJfVdMW6TiHuBqQC3MElsSlKtYljJfVdMWpR6xIG0YqQaNbPeeqQOPwXY3GCnJ1BrcP2Gu5Un9wKy5BqUMXpR6xIG0YqQaNbPwcPwguCj42mOmTn7JUqoj5pacDlWrdDfu40fBSomwqr(hG)ZdktBZ(y)wWpKwEas7asTbPYDB6TiXUqojVKmw8oyc)SQFjcsldPKsnKAdsbNkhbBCQNeshG0zqQni1ciDEif4nobye)E)0PI50fBSgsjiGurtTIr879tNk20dPwguCj42mOuV0BXNLwT5LKbqOBboYcDfu40fBSomwqr(hG)ZdkGtLH0sgG0sHucciv0uR4NLw1yekw3xYytFqXLGBZGcyIJMuCnPow3xYbqOBbkGdDfu40fBSomwqr(hG)ZdkIMAf7c5K8sYyX7GjSPhsjiGurtTILVb5AgB6HuBqQOPwXY3GCnJraxAfKoaPcolO4sWTzqrSTRoU1iyIJCYQ2haHUfOak0vqHtxSX6Wybf5Fa(ppOmpKc8gNaS8nixZyoDXgRHuBqQfqQC3MElsSlKtYljJfVdMWpR6xIG0sG0rHuBq602Sp2Vf8dPLhG0oGuccivUBtVfj2fYj5LKXI3bt4Nv9lrqA5bivGJcPwcPeeqQfqkWBCcWY3GCnJ50fBSgsTbPYDB6TiXY3GCnJFw1VebPLaPKsnKAdsN2M9X(TGFiT8aKkqiLGasL720BrILVb5Ag)SQFjcslpaPcCui1YGIlb3MbfsJ)6ZZ4wJU1Y)cMcGq3c0Ae6kOWPl2yDySGI8pa)NhuK720BrIDHCsEjzS4DWe(zv)seKwcKsk1qQniDAB2h73c(H0YdqAhqkbbKc8gNaS8nixZyoDXgRHuBqQC3MElsS8nixZ4Nv9lrqAjqkPudP2G0PTzFSFl4hslpaPcesjiGu5Un9wKyxiNKxsglEhmHFw1VebPLhGubokKsqaPYDB6TiXY3GCnJFw1VebPLhGuboAqXLGBZGsX(nTq(Y4ZOn9uYbqO7rNf6kOWPl2yDySGI8pa)NhuSasNhsF)0rwiNaSR1imB9dbqqkbbK((PJSqobyxRr4lH0YqAhZGuccif1ZTwe4pjdqy9j8soIa7RcPLhG0sHulHuBq68qQfqQOPwXUqojVKmw8oycB6Hucciv0uRy5BqUMXMEi1si1gKAbKk3TP3Iel2Cnh3ACege4Km(zv)seKwgsjLAivaG0oGuBqQC3MEls8imAsvob4Nv9lrqAziLuQHubas7asTmO4sWTzqPUsdI1r3A5)aCuKD1ai09Ocg6kOWPl2yDySGI8pa)NhuSasfn1k2fYj5LKXI3btytpKsqaPIMAflFdY1m20dP2GurtTILVb5AgJaU0kiDasfCgKAjKAdsN2M9X(TGFiTKbiTJGIlb3MbfvwDF7JBn2mYth1p7QOai09OLg6kOWPl2yDySGI8pa)NhuSasNhsF)0rwiNaSR1imB9dbqqkbbK((PJSqobyxRr4lH0YqAhZGuccif1ZTwe4pjdqy9j8soIa7RcPLhG0sHuldkUeCBgu6n)vT)sYOyZrGaiacGaiacba]] )


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
