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


    spec:RegisterPack( "Retribution", 20201107, [[dGKbKbqicWJKkfSjkLpPOQyuusofLOvPOkVsrLzrPQDb1VuOAykkhJaTmjONjHAAeqxtH02Kkf9nfvvJJsk6CsLswNIQszEsG7PG9jvCqfvLOfQq5HkQkHlkvku2iLui9rPsHQtsjfQvkHmtPsHyNkedvrvPAPusbpLetvQKTsjfIVkvkKgRIQsAVc(RqdgXHPAXe6XenzsDzuBwsFgPgTICAvTAPs1RPeMTuUnjTBr)wPHlvDCPsPwUkphY0bDDk2ob9DjA8us15Puz9usP5JK9dCqWqxbfTd5WifoRWzck4S5hpRBn68pRBguG21ZbLExAHtZbL0v5GI1adVx0a)ndk9UDT11HUckO1CsoOeuenFdAnodIbfTd5WifoRWzck4S5hpRBnQGcSBguq9SmmY8plOm9AnNbXGIMrYGs3aGynWW7fnWFtaz(U3C9NGI6gaKrwHSQiFaY8BpGu4ScNbkcuu3aGynWQRqgqSg9tVbiwdS0In)KgqAl9lbe4KdbeX2kTabiDXQ9n)MpiaXAe(0VeIdk93w)ghu6gaeRbgEVOb(BciZ39MR)euu3aGmYkKvf5dqMF7bKcNv4mqrGI6gaeRbwDfYaI1OF6naXAGLwS5N0acYUuciTL(LacCYHaIyBLwGaKUSgbdkcuKlH)MiC)XYvv0HZnmUFsp5iCVJtiOiabuu3aG0nM1zPbYAaHfYNDac8vzaboXaIlH7bipcqCH(3CXgJbf5s4VjA4yrJfmOixc)nrZnmU0BTOlH)MX2JG2NUkpi3TP3YebkYLWFt0CdJl9wl6s4VzS9iO9PRYd0CYNd3dbkcqaf5s4Vjcl3TP3Yen0VWFt7)6GvIMAfl22v3mii(yxcPOen1k2fYj9N0XYZHtytVnrtTIDHCs)jDS8C4e(yv)tuhbTMuuIMAflpdY1m20Bt0uRy5zqUMXhR6FIkOWrTeuKlH)MiSC3MElt0CdJ3E6jik2DJMwLtO9FDa1ZTwe6hndr42tpbrXUB00QCc7muifLvc48xhzHCcXUwJWS1FeerrD(RJSqoHyxRr4p7m)JAjOixc)nry5Un9wMO5ggV(hl22vB)xhen1k2fYj9N0XYZHtytpfLOPwXYZGCnJn92en1kwEgKRzmc6slgeCgOixc)nry5Un9wMO5gghn9Cth3AuiN0SNsguKlH)MiSC3MElt0CdJBqC8HSQ9PRYdNBTAtAbkk(0XJ1rrdeUjOixc)nry5Un9wMO5gg3G44dzv7txLhC0Kqpzu8CRDVOCpVz)xh0SOPwXNBT7fL75TOMfn1kwVLjfLvIMAf7c5K(t6y55Wj8XQ(NOodfoJIs0uRy5zqUMXiOlTyqWz2en1kwEgKRz8XQ(NOocoQL2SsUBtVLjM24N(9mU1OBT8TWj8XQ(NOoDRzuuq)Ozig(QCeUr9Zfu8mkkbWieNsgl3uZjI1X2x56EsgR6DFplbf5s4Vjcl3TP3Yen3W4gehFiRAF6Q8q3zuCAlB8z)xhen1k2fYj9N0XYZHtytpfLOPwXYZGCnJn92en1kwEgKRzmc6slgeCgOixc)nry5Un9wMO5gg3G44dzv7txLhe(ElU1ONVQdzDuSTR2(VoyLOPwXUqoP)KowEoCcB6POen1kwEgKRzSP3MOPwXYZGCnJpw1)evGGwtlPOSsUBtVLj2fYj9N0XYZHt4Jv9prDkEgfLC3MEltS8mixZ4Jv9prDkEMLGICj83eHL720BzIMByCdIJpKvTpDvEqVRkkwnND2)1brtTIDHCs)jDS8C4e20trjAQvS8mixZytVnrtTILNb5AgFSQ)jQabTMGICj83eHL720BzIMByCdIJpKvTpDvEG2BS0Bn(qrr2TW(VoiAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZ4Jv9prfi4OGICj83eHL720BzIMByCdIJpKvTpDvEq0o6n5OiZrVP6PlT)RdIMAf7c5K(t6y55WjSPNIs0uRy5zqUMXMEqrUe(BIWYDB6TmrZnmUbXXhYQ2NUkpOYhBbCYrXQN02)1bReW5VoYc5eIDTgHzR)iiII68xhzHCcXUwJWF2rWrTKIc1ZTwe6hndry9l8toIG7P2zOqqrUe(BIWYDB6TmrZnmUbXXhYQ2NUkp03mPMpr2pnkwBoYc7)6GOPwXUqoP)KowEoCcB6POen1kwEgKRzSP3MOPwXYZGCnJrqxArNbbNrrj3TP3Ye7c5K(t6y55Wj8XQ(NOocCukkbiAQvS8mixZytVn5Un9wMy5zqUMXhR6FI6iWrbf5s4Vjcl3TP3Yen3W4gehFiRAF6Q8GiFi(SGpuS7MUBS)RdIMAf7c5K(t6y55WjSPNIs0uRy5zqUMXMEBIMAflpdY1mgbDPfDgeCgfLC3MEltSlKt6pPJLNdNWhR6FI6iWrPOeGOPwXYZGCnJn92K720BzILNb5AgFSQ)jQJahfuKlH)MiSC3MElt0CdJBqC8HSQ9PRYdCQBmcfHFkHMJJBnwpxc)n9wSFl5Z(VoiAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZye0Lw0zqWzuuYDB6TmXUqoP)KowEoCcFSQ)jQJahLIsUBtVLjwEgKRz8XQ(NOocCuqrUe(BIWYDB6TmrZnmUbXXhYQ2NUkp0Z(1I6xiFOOCv7DeY(VoiAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZye0Lw0zqWzGICj83eHL720BzIMByCdIJpKvTpDvEO(hcgvDiJIOE7OBocz)xhen1k2fYj9N0XYZHtytpfLOPwXYZGCnJn92en1kwEgKRz8XQ(NOcgeCuqrUe(BIWYDB6TmrZnmUbXXhYQ2NUkpi37m9qwhPBU(D4EOOkR9w730(VoiAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZ4Jv9prfu4mqrUe(BIWYDB6TmrZnmUbXXhYQ2NUkpi37m9qwhPBU(D4EOOORPz7)6GOPwXUqoP)KowEoCcB6POen1kwEgKRzSP3MOPwXYZGCnJpw1)evGGJckYLWFtewUBtVLjAUHXnio(qw1(0v5HY7HtFshrmTkNW4wJ6JrqN2HtGICj83eHL720BzIMByCdIJpKvTpDvEanTsleFiFOy1tA7)6GOPwXUqoP)KowEoCcB6POen1kwEgKRzSPhuKlH)MiSC3MElt0CdJBqC8HSQ9PRYdTx4N0X9BrPNpcYhOixc)nry5Un9wMO5gg3G44dzv7txLhUhA8wSYoCIV4wJMmPJUf2)1brtTIDHCs)jDS8C4e20trjAQvS8mixZytVnrtTILNb5AgJGU0IbbNrrj3TP3Ye7c5K(t6y55Wj8XQ(NOodfpJIsUBtVLjwEgKRz8XQ(NOodfpduKlH)MiSC3MElt0CdJBqC8HSQ9PRYdhRUqosBETNsoQzHVKbf5s4Vjcl3TP3Yen3W4gehFiRAF6Q8GW3BXTgrW9urGICj83eHL720BzIMByCdIJpKvTpDvEOC6Vw5N0OyFZO60S9FDq0uRyxiN0FshlphoHn9uuIMAflpdY1m20Bt0uRy5zqUMXhR6FIkyOWzGICj83eHL720BzIMByCdIJpKvTpDvEqFSRJ0nx)oCpuu010S9FDq0uRyxiN0FshlphoHn9uuIMAflpdY1m20Bt0uRy5zqUMXhR6FIkyOWzGICj83eHL720BzIMByCdIJpKvTpDvEqFSRJoQ)ppHOOkR9w730(VoiAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZ4Jv9prfmu4mqrUe(BIWYDB6TmrZnmUbXXhYQ2NUkpqFBsJI93R6T450S9FDqaIMAf7c5K(t6y55WjSP3Maen1kwEgKRzSPhuKlH)MiSC3MElt0CdJBqC8HSQ9PRYdOpFeKViDZ1Vd3dffDnnB)xhen1k2fYj9N0XYZHtytpfLOPwXYZGCnJn92en1kwEgKRz8XQ(NOcgeCuqrUe(BIWYDB6TmrZnmUbXXhYQ2NUkpG(8rq(I0nx)oCpuuL1ER9BA)xhen1k2fYj9N0XYZHtytpfLOPwXYZGCnJn92en1kwEgKRz8XQ(NOcgkCgOixc)nry5Un9wMO5gg3G44dzv7txLhCRfn5NJI1nHXTg73s(S)Rdca6noHy5zqUMXC6InwBtUBtVLj2fYj9N0XYZHt4Jv9prfmkff0BCcXYZGCnJ50fBS2MC3MEltS8mixZ4Jv9prfmQn4RYDeCgf102Sl2VL81zOyBWxLlqWz2GEJtiU0TGJBn6OjgH50fBSguKlH)MiSC3MElt0CdJBqC8HSQ9PRYdcF0VzCRrnR(i2(VoiAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZye0Lwmi4mkk5Un9wMyxiN0FshlphoHpw1)e1zO4zuuYDB6TmXYZGCnJpw1)e1zO4zGICj83eHL720BzIMByCdIJpKvTpDvEWrtc9KrXZT29IY98M9FDqZIMAfFU1UxuUN3IAw0uRy9wMuuwjAQvSlKt6pPJLNdNWhR6FI6mu4mkkrtTILNb5AgJGU0IbbNzt0uRy5zqUMXhR6FI6i4OwAZk5Un9wMyAJF63Z4wJU1Y3cNWhR6FI60TMrrbFvoc3O(5ckEgfLayeItjJLBQ5eX6y7RCDpjJv9UVNLGICj83eHL720BzIMByCdIJpKvTpDvEWICHXTg9u(CcJvZzN9FDq0uRyxiN0FshlphoHn9uuIMAflpdY1m20Bt0uRy5zqUMXiOlTOZGGZOOK720BzIDHCs)jDS8C4e(yv)tuNINrrjartTILNb5AgB6Tj3TP3YelpdY1m(yv)tuNINbkYLWFtewUBtVLjAUHXDHCs)jDS8C4K9FDWQPTzxSFl5RZGaTbFvUGrPOM2MDX(TKVodfBd(QCNrPOGEJtiEAB2fDHCsZhMtxSXABYDB6TmXtBZUOlKtA(WhR6FIgMzPn4RYr4gN6PhMbkYLWFtewUBtVLjAUHXLNb5A2(Voy102Sl2VL81zqG2GVkxWOuutBZUy)wYxNHITbFvUZOuuqVXjepTn7IUqoP5dZPl2yTn5Un9wM4PTzx0fYjnF4Jv9prdZS0g8v5iCJt90dZaf5s4Vjcl3TP3Yen3W4oAIZ4K3ABjOixc)nry5Un9wMO5ggFAB2fDHCsZN9FDa(QCeUXPE6Hz2SYkrtTIDHCs)jDS8C4e20trjAQvS8mixZytVLuuwjAQvSlKt6pPJLNdNW6TmTj3TP3Ye7c5K(t6y55Wj8XQ(NOocCgfLOPwXYZGCnJ1BzAtUBtVLjwEgKRz8XQ(NOocCMLwckYLWFtewUBtVLjAUHXRF6T4Xsl28tA7)6W02Sl2VL81zOyBYDB6TmXUqoP)KowEoCcFSQ)jQdTuBd(QCeUXPE6Hz2SsaqVXjeJ4Z7NEvmNUyJ1uuIMAfJ4Z7NEvSP3sqrUe(BIWYDB6TmrZnmoCIJMuCnPow3tY2)1b4RYfmuifLOPwXhlTOXiuSUNKXMEqrUe(BIWYDB6TmrZnmUyBxDCRr4eh5KvTZ(VoiAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZye0Lwmi4mqrUe(BIWYDB6TmrZnmoTXp97zCRr3A5BHt2)1bba9gNqS8mixZyoDXgRTzLC3MEltSlKt6pPJLNdNWhR6FIkyuBtBZUy)wYxNHIPOK720BzIDHCs)jDS8C4e(yv)tuNbboQLuuwb9gNqS8mixZyoDXgRTj3TP3YelpdY1m(yv)tub0sTTPTzxSFl5RZGaPOK720BzILNb5AgFSQ)jQZGah1sqrUe(BIWYDB6TmrZnmE5EnTq(Z4XOn9uY2)1b5Un9wMyxiN0FshlphoHpw1)evaTuBBAB2f73s(6mumff0BCcXYZGCnJ50fBS2MC3MEltS8mixZ4Jv9prfql12M2MDX(TKVodcKIsUBtVLj2fYj9N0XYZHt4Jv9prDge4OuuYDB6TmXYZGCnJpw1)e1zqGJckYLWFtewUBtVLjAUHXRR0GyD0Tw(Eihfzx1(VoyLao)1rwiNqSR1imB9hbruuN)6ilKti21Ae(ZofpJIc1ZTwe6hndry9l8toIG7P2zOqlTjaRen1k2fYj9N0XYZHtytpfLOPwXYZGCnJn9wAZk5Un9wMyXMR54wJD3GGVKXhR6FI6ql1ZRyBYDB6TmXD3OPv5eIpw1)e1HwQNxXwckYLWFtewUBtVLjAUHXvz19SlU1yZiFDuFSRIS)RdwjAQvSlKt6pPJLNdNWMEkkrtTILNb5AgB6TjAQvS8mixZye0Lwmi4mlTnTn7I9BjFfmumOixc)nry5Un9wMO5ggV3CF1UpPJInhbT)RdwjGZFDKfYje7AncZw)rqef15VoYc5eIDTgH)StXZOOq9CRfH(rZqew)c)KJi4EQDgk0sqracOixc)nr46NpAIp0CdJl0V3fBS9PRYdAuu6iOl2y7f6ndpG65wlc9JMHiS(f(jhrW9u7muifLOPwXSAVDh7zSFl5dB6TPzrtTI7UrtRYjeR3Y0MOPwX6x4NCS3C9lIX6TmPOq9CRfH(rZqew)c)KJi4EQDgk0MOPwXYZGCnJn92en1kwEgKRzmc6slkqWzGICj83eHRF(Oj(qZnmoIpVF6vT)RdwzLaGEJtiwEgKRzmNUyJ12en1k2fYj9N0XYZHtytpfLC3MEltSlKt6pPJLNdNWhR6FI6u4OwsrzLOPwXYZGCnJn9uuYDB6TmXYZGCnJpw1)e1PWrT0sBwjaO34eIRF6T4Xsl28tAmNUyJ1uuYDB6TmX1p9w8yPfB(jn(yv)tubcoZsBwjaO34eIzRZsd83mI4eYPKXC6Inwtrj3TP3YeZwNLg4VzeXjKtjJpw1)evGGZS0g8v5iCJt90dZaf5s4Vjcx)8rt8HMByCHE2TnpAIpuCYvv5Z(VoyLaGEJtiU(P3IhlTyZpPXC6Inwtrj3TP3Yex)0BXJLwS5N04Jv9prDOL65j4mkknlAQvC9tVfpwAXMFsJn9wAZkba9gNqmBDwAG)MreNqoLmMtxSXAkk5Un9wMy26S0a)nJioHCkz8XQ(NOo0s98eCgfLMfn1kMTolnWFZiItiNsgB6TKIc1ZTwe6hndry9l8toIG7P2zOqqrUe(BIW1pF0eFO5ggNTolnWFZiItiNs2(VoG65wlc9JMHiS(f(jhrW9ulyOyBwzLaGEJtiwEgKRzmNUyJ1uuIMAflpdY1mwVLPn5Un9wMy5zqUMXhR6FI6i4mlPOen1kwEgKRzmc6sl6mumfLC3MEltSlKt6pPJLNdNWhR6FI6i4mkknlAQvC9tVfpwAXMFsJn9wAd(QCeUXPE6HzGICj83eHRF(Oj(qZnmU(f(jhrW9uT)Rdc97DXgJ1OO0rqxSX2eGOPwXc9SBBE0eFO4KRQYh20BZkRea0BCcXYZGCnJ50fBSMIsUBtVLjwEgKRz8XQ(NOo0s98k2sBwjaO34eIzRZsd83mI4eYPKXC6Inwtrj3TP3YeZwNLg4VzeXjKtjJpw1)e1HwQNxXuuOEU1Iq)OzicRFHFYreCp1odfBjffQNBTi0pAgIW6x4NCeb3tTZqH2Sc6noH4PTzx0fYjnFyoDXgRTj3TP3YepTn7IUqoP5dFSQ)jQaAPEEftrjAQvS8mixZytVnrtTILNb5AgJGU0IceCMLwckYLWFteU(5JM4dn3W4qwTV5hkkKp9lH2)1bRea0BCcXYZGCnJ50fBSMIsUBtVLjwEgKRz8XQ(NOo0s98k2sBwjaO34eIzRZsd83mI4eYPKXC6Inwtrj3TP3YeZwNLg4VzeXjKtjJpw1)e1HwQNxX2q9CRfH(rZqew)c)KJi4EQfmuSL2SsaYviNEcXjlVTTNgZPl2ynfLC3MEltSqp72MhnXhko5QQ8Hpw1)e1HwQTKIc6noH4PTzx0fYjnFyoDXgRTj3TP3YepTn7IUqoP5dFSQ)jQaAPEEftrjAQv802Sl6c5KMpSPNIs0uRy5zqUMXMEBIMAflpdY1mgbDPffi4mkkrtTIf6z328Oj(qXjxvLpSPhueGakYLWFteMMt(C4EO5ggx6Tw0LWFZy7rq7txLhQF(Oj(q2)1HPTzxSFl5RZWOuuIMAfpTn7IUqoP5dB6PO0SOPwX1p9w8yPfB(jn20trPzrtTIzRZsd83mI4eYPKXMEqrUe(BIW0CYNd3dn3W4IngH(KoU1iYOQYhOixc)nryAo5ZH7HMByCXgJqFsh3A0nqJAckYLWFteMMt(C4EO5ggxSXi0N0XTgl)eYhOixc)nryAo5ZH7HMByCXgJqFsh3Ae1FFsdkYLWFteMMt(C4EO5ggx)c)KJWT1S)RdcqZIMAf3DJMwLti20BZkbC(RJSqoHyxRry26pcIOOo)1rwiNqSR1i8NDkEML2SAAB2f73s(kyOqkQPTzxSFl5RGbbAZk5Un9wMyXMR54wJD3GGVKXhR6FI6ql1ZRqkknlAQvmBDwAG)MreNqoLm20trPzrtTIRF6T4Xsl28tASP3slTzLaGEJtiU(P3IhlTyZpPXC6Inwtrj3TP3Yex)0BXJLwS5N04Jv9prDOL65j4mlTzLaGEJtiMTolnWFZiItiNsgZPl2ynfLC3MEltmBDwAG)MreNqoLm(yv)tuhAPEEcoZsqrUe(BIW0CYNd3dn3W4LUfCCRrhnXi7)6GvtBZUy)wY3WmkQPTzxSFl5RGHcTzLC3MEltSyZ1CCRXUBqWxY4Jv9prDOL65vifLMfn1kMTolnWFZiItiNsgB6PO0SOPwX1p9w8yPfB(jn20BPL2SsaN)6ilKti21AeMT(JGikQZFDKfYje7Anc)zNcNzPnRea0BCcXS1zPb(BgrCc5uYyoDXgRPOK720BzIzRZsd83mI4eYPKXhR6FI6i4OwAZkba9gNqC9tVfpwAXMFsJ50fBSMIsUBtVLjU(P3IhlTyZpPXhR6FI6i4OwckYLWFteMMt(C4EO5ggxS5AoU1y3ni4lz7)6W02Sl2VL8vWqXGICj83eHP5KphUhAUHXNCvv(IBnwEoCY(VomTn7I9BjFfmiqqrUe(BIW0CYNd3dn3W4D3OPv5eA)xheGMfn1kU7gnTkNqSP3MvtBZUy)wYxbdfsrnTn7I9BjFfmiqBYDB6TmXInxZXTg7UbbFjJpw1)e1HwQNxHwckYLWFteMMt(C4EO5ggx6Tw0LWFZy7rq7txLhQF(Oj(q2)1bRG(rZq8e7n4eUxclyOWzuuIMAf7c5K(t6y55WjSPNIs0uRy5zqUMXMEkkrtTIz1E7o2Zy)wYh20BjOixc)nryAo5ZH7HMByC5zqUMVicEVfS9FDqUBtVLjwEgKR5lIG3BbJLt(rZOy9Cj830BDgeep)JAZQPTzxSFl5RGHcPOM2MDX(TKVcgk2MC3MEltSyZ1CCRXUBqWxY4Jv9prDOL65vif102Sl2VL8niqBYDB6TmXInxZXTg7UbbFjJpw1)e1HwQNxH2K720BzI7UrtRYjeFSQ)jQdTupVcTeuKlH)MimnN85W9qZnmU0BTOlH)MX2JG2NUkpu)8rt8Haf5s4VjctZjFoCp0CdJlpdY18frW7TGT)RdtBZUy)wYxbdceuKlH)MimnN85W9qZnmUCtjNWZHSowBUkdkYLWFteMMt(C4EO5gg)yV)t6yT5QmY(Voa9JMH4j2BWPyVe2XAoJIc6hndXtS3GtXEjSGcNrrvF6jy8yv)tubfpkOixc)nryAo5ZH7HMByC)KEYr4EhNq7)6W02Sl2VL8vWGabf5s4VjctZjFoCp0CdJl3eXYZH)M2)1b4RYr4gN6P7ql1bfH8H(ndJu4ScNjOGZkoOu6x(jnkO0n68LwdJynEKUXNVbiasxtmG8Q97bbK6EaY8P(5JM4dnFaKJ72M)ynGGwvgqCdCvDiRbe5KN0mcdkQBKpzaPBoFdqMVytH8bznGmFKRqo9eINVI50fBSE(aiWfqMpYviNEcXZxNpaIvcADlXGIaf11ediZhdIJpKvrZhaXLWFtaP0rasUqaPUMudiFciWPhbiVA)EqmOiRXQ97bznGmkG4s4VjG0EeeHbffuCdCAVGIs32WnhUxqP9iik0vqrZv30GHUcJiyORGIlH)MbLJfnwWbfoDXgRdJfGHrkm0vqHtxSX6Wybfxc)ndksV1IUe(BgBpcguApcgtxLdkYDB6TmrbyyKIdDfu40fBSomwqXLWFZGI0BTOlH)MX2JGbL2JGX0v5GcnN85W9qbyagu6pwUQIom0vyebdDfuCj83mO4N0toc374egu40fBSomwagGbfAo5ZH7HcDfgrWqxbfoDXgRdJfuK3d579GY02Sl2VL8biDgaKrbekkar0uR4PTzx0fYjnFytpGqrbiAw0uR46NElES0In)KgB6bekkarZIMAfZwNLg4VzeXjKtjJn9bfxc)ndksV1IUe(BgBpcguApcgtxLdk1pF0eFOammsHHUckUe(BgueBmc9jDCRrKrvLVGcNUyJ1HXcWWifh6kO4s4VzqrSXi0N0XTgDd0OMbfoDXgRdJfGHreyORGIlH)MbfXgJqFsh3AS8tiFbfoDXgRdJfGHrgn0vqXLWFZGIyJrOpPJBnI6VpPdkC6InwhgladJ0ndDfu40fBSomwqrEpKV3dkcaq0SOPwXD3OPv5eIn9aInaXkaraaY5VoYc5eIDTgHzR)iicqOOaKZFDKfYje7Anc)jG0bqkEgGyjGydqScqM2MDX(TKpaPGbaPqaHIcqM2MDX(TKpaPGbarGaInaXkarUBtVLjwS5AoU1y3ni4lz8XQ(NiaPdGql1aY8aKcbekkarZIMAfZwNLg4VzeXjKtjJn9acffGOzrtTIRF6T4Xsl28tASPhqSeqSeqSbiwbicaqGEJtiU(P3IhlTyZpPXC6InwdiuuaIC3MEltC9tVfpwAXMFsJpw1)ebiDaeAPgqMhGi4maXsaXgGyfGiaab6noHy26S0a)nJioHCkzmNUyJ1acffGi3TP3YeZwNLg4VzeXjKtjJpw1)ebiDaeAPgqMhGi4maXYGIlH)Mbf9l8toc3wladJm)HUckC6InwhglOiVhY37bfRaKPTzxSFl5dqgaKzacffGmTn7I9BjFasbdasHaInaXkarUBtVLjwS5AoU1y3ni4lz8XQ(NiaPdGql1aY8aKcbekkarZIMAfZwNLg4VzeXjKtjJn9acffGOzrtTIRF6T4Xsl28tASPhqSeqSeqSbiwbicaqo)1rwiNqSR1imB9hbracffGC(RJSqoHyxRr4pbKoasHZaelbeBaIvaIaaeO34eIzRZsd83mI4eYPKXC6InwdiuuaIC3MEltmBDwAG)MreNqoLm(yv)teG0bqeCuaXsaXgGyfGiaab6noH46NElES0In)KgZPl2ynGqrbiYDB6TmX1p9w8yPfB(jn(yv)teG0bqeCuaXYGIlH)MbLs3coU1OJMyuaggXAg6kOWPl2yDySGI8EiFVhuM2MDX(TKpaPGbaP4GIlH)MbfXMR54wJD3GGVKdWWiDRqxbfoDXgRdJfuK3d579GY02Sl2VL8bifmaicmO4s4VzqzYvv5lU1y55WPammIGZcDfu40fBSomwqrEpKV3dkcaq0SOPwXD3OPv5eIn9aInaXkazAB2f73s(aKcgaKcbekkazAB2f73s(aKcgaebci2ae5Un9wMyXMR54wJD3GGVKXhR6FIaKoacTudiZdqkeqSmO4s4VzqP7gnTkNWammIGcg6kOWPl2yDySGI8EiFVhuScqG(rZq8e7n4eUxcbKcgaKcNbiuuaIOPwXUqoP)KowEoCcB6bekkar0uRy5zqUMXMEaHIcqen1kMv7T7ypJ9BjFytpGyzqXLWFZGI0BTOlH)MX2JGbL2JGX0v5Gs9ZhnXhkadJiyHHUckC6InwhglOiVhY37bf5Un9wMy5zqUMVicEVfmwo5hnJI1ZLWFtVbiDgaebXZ)OaInaXkazAB2f73s(aKcgaKcbekkazAB2f73s(aKcgaKIbeBaIC3MEltSyZ1CCRXUBqWxY4Jv9prashaHwQbK5bifciuuaY02Sl2VL8bidaIabeBaIC3MEltSyZ1CCRXUBqWxY4Jv9prashaHwQbK5bifci2ae5Un9wM4UB00QCcXhR6FIaKoacTudiZdqkeqSmO4s4VzqrEgKR5lIG3BbhGHreS4qxbfoDXgRdJfuCj83mOi9wl6s4VzS9iyqP9iymDvoOu)8rt8HcWWickWqxbfoDXgRdJfuK3d579GY02Sl2VL8bifmaicmO4s4VzqrEgKR5lIG3BbhGHreC0qxbfxc)ndkYnLCcphY6yT5QCqHtxSX6Wybyyeb7MHUckC6InwhglOiVhY37bfOF0mepXEdof7LqaPdGynNbiuuac0pAgINyVbNI9siGuaGu4maHIcqQp9emESQ)jcqkaqkE0GIlH)MbLJ9(pPJ1MRYOammIGZFORGcNUyJ1HXckY7H89EqzAB2f73s(aKcgaebguCj83mO4N0toc374egGHre0Ag6kOWPl2yDySGI8EiFVhuGVkhHBCQNgq6ai0sDqXLWFZGICtelph(BgGbyqP(5JM4df6kmIGHUckC6InwhglOS9bfeddkUe(Bgue637InoOi0BgoOG65wlc9JMHiS(f(jhrW9ubKodasHacffGiAQvmR2B3XEg73s(WMEaXgGOzrtTI7UrtRYjeR3YeqSbiIMAfRFHFYXEZ1VigR3YeqOOaeup3ArOF0meH1VWp5icUNkG0zaqkeqSbiIMAflpdY1m20di2aertTILNb5AgJGU0caPaarWzbfH(ftxLdkAuu6iOl24ammsHHUckC6InwhglOiVhY37bfRaeRaebaiqVXjelpdY1mMtxSXAaXgGiAQvSlKt6pPJLNdNWMEaHIcqK720BzIDHCs)jDS8C4e(yv)teG0bqkCuaXsaHIcqScqen1kwEgKRzSPhqOOae5Un9wMy5zqUMXhR6FIaKoasHJciwciwci2aeRaebaiqVXjex)0BXJLwS5N0yoDXgRbekkarUBtVLjU(P3IhlTyZpPXhR6FIaKcaebNbiwci2aeRaebaiqVXjeZwNLg4VzeXjKtjJ50fBSgqOOae5Un9wMy26S0a)nJioHCkz8XQ(NiaPaarWzaILaInab(QCeUXPEAazaqMfuCj83mOG4Z7NE1ammsXHUckC6InwhglOiVhY37bfRaebaiqVXjex)0BXJLwS5N0yoDXgRbekkarUBtVLjU(P3IhlTyZpPXhR6FIaKoacTudiZdqeCgGqrbiAw0uR46NElES0In)KgB6belbeBaIvaIaaeO34eIzRZsd83mI4eYPKXC6InwdiuuaIC3MEltmBDwAG)MreNqoLm(yv)teG0bqOLAazEaIGZaekkarZIMAfZwNLg4VzeXjKtjJn9aILacffGG65wlc9JMHiS(f(jhrW9ubKodasHbfxc)ndkc9SBBE0eFO4KRQYxaggrGHUckC6InwhglOiVhY37bfup3ArOF0meH1VWp5icUNkGuWaGumGydqScqScqeaGa9gNqS8mixZyoDXgRbekkar0uRy5zqUMX6TmbeBaIC3MEltS8mixZ4Jv9prasharWzaILacffGiAQvS8mixZye0LwaiDgaKIbekkarUBtVLj2fYj9N0XYZHt4Jv9prasharWzacffGOzrtTIRF6T4Xsl28tASPhqSeqSbiWxLJWno1tdidaYSGIlH)Mbf26S0a)nJioHCk5ammYOHUckC6InwhglOiVhY37bfH(9UyJXAuu6iOl2yaXgGiaar0uRyHE2TnpAIpuCYvv5dB6beBaIvaIvaIaaeO34eILNb5AgZPl2ynGqrbiYDB6TmXYZGCnJpw1)ebiDaeAPgqMhGumGyjGydqScqeaGa9gNqmBDwAG)MreNqoLmMtxSXAaHIcqK720BzIzRZsd83mI4eYPKXhR6FIaKoacTudiZdqkgqOOaeup3ArOF0meH1VWp5icUNkG0zaqkgqSeqOOaeup3ArOF0meH1VWp5icUNkG0zaqkeqSbiwbiqVXjepTn7IUqoP5dZPl2ynGydqK720BzIN2MDrxiN08Hpw1)ebifai0snGmpaPyaHIcqen1kwEgKRzSPhqSbiIMAflpdY1mgbDPfasbaIGZaelbeldkUe(Bgu0VWp5icUNAaggPBg6kOWPl2yDySGI8EiFVhuScqeaGa9gNqS8mixZyoDXgRbekkarUBtVLjwEgKRz8XQ(NiaPdGql1aY8aKIbelbeBaIvaIaaeO34eIzRZsd83mI4eYPKXC6InwdiuuaIC3MEltmBDwAG)MreNqoLm(yv)teG0bqOLAazEasXaInab1ZTwe6hndry9l8toIG7Pcifmaifdiwci2aeRaebaiYviNEcXjlVTTNgqOOae5Un9wMyHE2TnpAIpuCYvv5dFSQ)jcq6ai0snGyjGqrbiqVXjepTn7IUqoP5dZPl2ynGydqK720BzIN2MDrxiN08Hpw1)ebifai0snGmpaPyaHIcqen1kEAB2fDHCsZh20diuuaIOPwXYZGCnJn9aInar0uRy5zqUMXiOlTaqkaqeCgGqrbiIMAfl0ZUT5rt8HItUQkFytFqXLWFZGcKv7B(HIc5t)syagGbf5Un9wMOqxHrem0vqHtxSX6Wybf59q(EpOyfGiAQvSyBxDZGG4JDjeqOOaertTIDHCs)jDS8C4e20di2aertTIDHCs)jDS8C4e(yv)teG0bqe0AciuuaIOPwXYZGCnJn9aInar0uRy5zqUMXhR6FIaKcaKchfqSmO4s4VzqPFH)MbyyKcdDfu40fBSomwqrEpKV3dkOEU1Iq)Ozic3E6jik2DJMwLtiG0zaqkeqOOaeRaebaiN)6ilKti21AeMT(JGiaHIcqo)1rwiNqSR1i8Nashaz(hfqSmO4s4VzqP90tquS7gnTkNWammsXHUckC6InwhglOiVhY37bfrtTIDHCs)jDS8C4e20diuuaIOPwXYZGCnJn9aInar0uRy5zqUMXiOlTaqgaebNfuCj83mOu)JfB7QdWWicm0vqXLWFZGcA65MoU1OqoPzpLCqHtxSX6WybyyKrdDfu40fBSomwqjDvoOCU1QnPfOO4thpwhfnq4Mbfxc)ndkNBTAtAbkk(0XJ1rrdeUzaggPBg6kOWPl2yDySGIlH)Mbfhnj0tgfp3A3lk3ZBbf59q(EpOOzrtTIp3A3lk3ZBrnlAQvSEltaHIcqScqen1k2fYj9N0XYZHt4Jv9prasNbaPWzacffGiAQvS8mixZye0LwaidaIGZaeBaIOPwXYZGCnJpw1)ebiDaebhfqSeqSbiwbiYDB6TmX0g)0VNXTgDRLVfoHpw1)ebiDaKU1maHIcqG(rZqm8v5iCJ6NbKcaKINbiuuaIaaegH4uYy5MAorSo2(kx3tYyvV77biwgusxLdkoAsONmkEU1UxuUN3cWWiZFORGcNUyJ1HXckUe(Bgu6oJItBzJVGI8EiFVhuen1k2fYj9N0XYZHtytpGqrbiIMAflpdY1m20di2aertTILNb5AgJGU0cazaqeCwqjDvoO0DgfN2YgFbyyeRzORGcNUyJ1HXckUe(Bgue(ElU1ONVQdzDuSTRoOiVhY37bfRaertTIDHCs)jDS8C4e20diuuaIOPwXYZGCnJn9aInar0uRy5zqUMXhR6FIaKcaebTMaILacffGyfGi3TP3Ye7c5K(t6y55Wj8XQ(NiaPdGu8maHIcqK720BzILNb5AgFSQ)jcq6aifpdqSmOKUkhue(ElU1ONVQdzDuSTRoadJ0TcDfu40fBSomwqXLWFZGIExvuSAo7ckY7H89Eqr0uRyxiN0FshlphoHn9acffGiAQvS8mixZytpGydqen1kwEgKRz8XQ(NiaPaarqRzqjDvoOO3vffRMZUammIGZcDfu40fBSomwqXLWFZGcT3yP3A8HIISBrqrEpKV3dkIMAf7c5K(t6y55WjSPhqOOaertTILNb5AgB6beBaIOPwXYZGCnJpw1)ebifaicoAqjDvoOq7nw6TgFOOi7weGHreuWqxbfoDXgRdJfuCj83mOiAh9MCuK5O3u90Lbf59q(EpOiAQvSlKt6pPJLNdNWMEaHIcqen1kwEgKRzSPpOKUkhueTJEtokYC0BQE6YammIGfg6kOWPl2yDySGIlH)Mbfv(ylGtokw9KoOiVhY37bfRaebaiN)6ilKti21AeMT(JGiaHIcqo)1rwiNqSR1i8NasharWrbelbekkab1ZTwe6hndry9l8toIG7PciDgaKcdkPRYbfv(ylGtokw9KoadJiyXHUckC6InwhglO4s4VzqPVzsnFISFAuS2CKfbf59q(EpOiAQvSlKt6pPJLNdNWMEaHIcqen1kwEgKRzSPhqSbiIMAflpdY1mgbDPfasNbarWzacffGi3TP3Ye7c5K(t6y55Wj8XQ(NiaPdGiWrbekkaraaIOPwXYZGCnJn9aInarUBtVLjwEgKRz8XQ(NiaPdGiWrdkPRYbL(Mj18jY(PrXAZrweGHreuGHUckC6InwhglO4s4VzqrKpeFwWhk2Dt3nbf59q(EpOiAQvSlKt6pPJLNdNWMEaHIcqen1kwEgKRzSPhqSbiIMAflpdY1mgbDPfasNbarWzacffGi3TP3Ye7c5K(t6y55Wj8XQ(NiaPdGiWrbekkaraaIOPwXYZGCnJn9aInarUBtVLjwEgKRz8XQ(NiaPdGiWrdkPRYbfr(q8zbFOy3nD3eGHreC0qxbfoDXgRdJfuCj83mOWPUXiue(PeAooU1y9Cj830BX(TKVGI8EiFVhuen1k2fYj9N0XYZHtytpGqrbiIMAflpdY1m20di2aertTILNb5AgJGU0caPZaGi4maHIcqK720BzIDHCs)jDS8C4e(yv)teG0bqe4OacffGi3TP3YelpdY1m(yv)teG0bqe4ObL0v5GcN6gJqr4NsO544wJ1ZLWFtVf73s(cWWic2ndDfu40fBSomwqXLWFZGsp7xlQFH8HIYvT3rOGI8EiFVhuen1k2fYj9N0XYZHtytpGqrbiIMAflpdY1m20di2aertTILNb5AgJGU0caPZaGi4SGs6QCqPN9Rf1Vq(qr5Q27iuaggrW5p0vqHtxSX6Wybfxc)ndk1)qWOQdzue1BhDZrOGI8EiFVhuen1k2fYj9N0XYZHtytpGqrbiIMAflpdY1m20di2aertTILNb5AgFSQ)jcqkyaqeC0Gs6QCqP(hcgvDiJIOE7OBocfGHre0Ag6kOWPl2yDySGIlH)Mbf5ENPhY6iDZ1Vd3dfvzT3A)Mbf59q(EpOiAQvSlKt6pPJLNdNWMEaHIcqen1kwEgKRzSPhqSbiIMAflpdY1m(yv)teGuaGu4SGs6QCqrU3z6HSos3C97W9qrvw7T2VzaggrWUvORGcNUyJ1HXckUe(BguK7DMEiRJ0nx)oCpuu010CqrEpKV3dkIMAf7c5K(t6y55WjSPhqOOaertTILNb5AgB6beBaIOPwXYZGCnJpw1)ebifaicoAqjDvoOi37m9qwhPBU(D4EOOORP5ammsHZcDfu40fBSomwqjDvoOuEpC6t6iIPv5eg3AuFmc60oCkO4s4VzqP8E40N0retRYjmU1O(ye0PD4uaggPqbdDfu40fBSomwqXLWFZGcAALwi(q(qXQN0bf59q(EpOiAQvSlKt6pPJLNdNWMEaHIcqen1kwEgKRzSPpOKUkhuqtR0cXhYhkw9KoadJuyHHUckC6InwhglOKUkhuAVWpPJ73IspFeKVGIlH)MbL2l8t64(TO0Zhb5ladJuyXHUckC6InwhglO4s4Vzq5EOXBXk7Wj(IBnAYKo6weuK3d579GIOPwXUqoP)KowEoCcB6bekkar0uRy5zqUMXMEaXgGiAQvS8mixZye0LwaidaIGZaekkarUBtVLj2fYj9N0XYZHt4Jv9prasNbaP4zacffGi3TP3YelpdY1m(yv)teG0zaqkEwqjDvoOCp04TyLD4eFXTgnzshDlcWWifkWqxbfoDXgRdJfusxLdkhRUqosBETNsoQzHVKdkUe(BguowDHCK28ApLCuZcFjhGHrkC0qxbfoDXgRdJfusxLdkcFVf3Aeb3tffuCj83mOi89wCRreCpvuaggPWUzORGcNUyJ1HXckUe(BgukN(Rv(jnk23mQonhuK3d579GIOPwXUqoP)KowEoCcB6bekkar0uRy5zqUMXMEaXgGiAQvS8mixZ4Jv9prasbdasHZckPRYbLYP)ALFsJI9nJQtZbyyKcN)qxbfoDXgRdJfuCj83mOOp21r6MRFhUhkk6AAoOiVhY37bfrtTIDHCs)jDS8C4e20diuuaIOPwXYZGCnJn9aInar0uRy5zqUMXhR6FIaKcgaKcNfusxLdk6JDDKU563H7HIIUMMdWWifAndDfu40fBSomwqXLWFZGI(yxhDu)FEcrrvw7T2VzqrEpKV3dkIMAf7c5K(t6y55WjSPhqOOaertTILNb5AgB6beBaIOPwXYZGCnJpw1)ebifmaifolOKUkhu0h76OJ6)ZtikQYAV1(ndWWif2TcDfu40fBSomwqXLWFZGc9Tjnk2FVQ3INtZbf59q(EpOiaar0uRyxiN0FshlphoHn9aInaraaIOPwXYZGCnJn9bL0v5Gc9Tjnk2FVQ3INtZbyyKINf6kOWPl2yDySGIlH)Mbf0NpcYxKU563H7HIIUMMdkY7H89Eqr0uRyxiN0FshlphoHn9acffGiAQvS8mixZytpGydqen1kwEgKRz8XQ(NiaPGbarWrdkPRYbf0NpcYxKU563H7HIIUMMdWWiflyORGcNUyJ1HXckUe(BguqF(iiFr6MRFhUhkQYAV1(ndkY7H89Eqr0uRyxiN0FshlphoHn9acffGiAQvS8mixZytpGydqen1kwEgKRz8XQ(NiaPGbaPWzbL0v5Gc6Zhb5ls3C97W9qrvw7T2VzaggP4cdDfu40fBSomwqXLWFZGIBTOj)CuSUjmU1y)wYxqrEpKV3dkcaqGEJtiwEgKRzmNUyJ1aInarUBtVLj2fYj9N0XYZHt4Jv9prasbaYOacffGa9gNqS8mixZyoDXgRbeBaIC3MEltS8mixZ4Jv9prasbaYOaInab(QmG0bqeCgGqrbitBZUy)wYhG0zaqkgqSbiWxLbKcaebNbi2aeO34eIlDl44wJoAIryoDXgRdkPRYbf3Art(5OyDtyCRX(TKVammsXfh6kOWPl2yDySGIlH)MbfHp63mU1OMvFehuK3d579GIOPwXUqoP)KowEoCcB6bekkar0uRy5zqUMXMEaXgGiAQvS8mixZye0LwaidaIGZaekkarUBtVLj2fYj9N0XYZHt4Jv9prasNbaP4zacffGi3TP3YelpdY1m(yv)teG0zaqkEwqjDvoOi8r)MXTg1S6J4ammsXcm0vqHtxSX6Wybfxc)ndkoAsONmkEU1UxuUN3ckY7H89EqrZIMAfFU1UxuUN3IAw0uRy9wMacffGyfGiAQvSlKt6pPJLNdNWhR6FIaKodasHZaekkar0uRy5zqUMXiOlTaqgaebNbi2aertTILNb5AgFSQ)jcq6aicokGyjGydqScqK720BzIPn(PFpJBn6wlFlCcFSQ)jcq6aiDRzacffGaFvoc3O(zaPaaP4zacffGiaaHrioLmwUPMteRJTVY19Kmw17(EaILbL0v5GIJMe6jJINBT7fL75TammsXJg6kOWPl2yDySGIlH)MbflYfg3A0t5ZjmwnNDbf59q(EpOiAQvSlKt6pPJLNdNWMEaHIcqen1kwEgKRzSPhqSbiIMAflpdY1mgbDPfasNbarWzacffGi3TP3Ye7c5K(t6y55Wj8XQ(NiaPdGu8maHIcqeaGiAQvS8mixZytpGydqK720BzILNb5AgFSQ)jcq6aifplOKUkhuSixyCRrpLpNWy1C2fGHrkUBg6kOWPl2yDySGI8EiFVhuScqM2MDX(TKpaPZaGiqaXgGaFvgqkaqgfqOOaKPTzxSFl5dq6maifdi2ae4RYashazuaHIcqGEJtiEAB2fDHCsZhMtxSXAaXgGi3TP3YepTn7IUqoP5dFSQ)jcqgaKzaILaInab(QCeUXPEAazaqMfuCj83mO4c5K(t6y55WPammsXZFORGcNUyJ1HXckY7H89EqXkazAB2f73s(aKodaIabeBac8vzaPaazuaHIcqM2MDX(TKpaPZaGumGydqGVkdiDaKrbekkab6noH4PTzx0fYjnFyoDXgRbeBaIC3MElt802Sl6c5KMp8XQ(NiazaqMbiwci2ae4RYr4gN6PbKbazwqXLWFZGI8mixZbyyKITMHUckUe(BguC0eNXjV12YGcNUyJ1HXcWWif3TcDfu40fBSomwqrEpKV3dkWxLJWno1tdidaYmaXgGyfGyfGiAQvSlKt6pPJLNdNWMEaHIcqen1kwEgKRzSPhqSeqOOaeRaertTIDHCs)jDS8C4ewVLjGydqK720BzIDHCs)jDS8C4e(yv)teG0bqe4maHIcqen1kwEgKRzSEltaXgGi3TP3YelpdY1m(yv)teG0bqe4maXsaXYGIlH)MbLPTzx0fYjnFbyyebol0vqHtxSX6Wybf59q(EpOmTn7I9BjFasNbaPyaXgGi3TP3Ye7c5K(t6y55Wj8XQ(NiaPdGql1aInab(QCeUXPEAazaqMbi2aeRaebaiqVXjeJ4Z7NEvmNUyJ1acffGiAQvmIpVF6vXMEaXYGIlH)MbL6NElES0In)KoadJiqbdDfu40fBSomwqrEpKV3dkWxLbKcgaKcbekkar0uR4JLw0yekw3tYytFqXLWFZGcCIJMuCnPow3tYbyyebwyORGcNUyJ1HXckY7H89Eqr0uRyxiN0FshlphoHn9acffGiAQvS8mixZytpGydqen1kwEgKRzmc6slaKbarWzbfxc)ndkITD1XTgHtCKtw1UammIalo0vqHtxSX6Wybf59q(EpOiaab6noHy5zqUMXC6Inwdi2aeRae5Un9wMyxiN0FshlphoHpw1)ebifaiJci2aKPTzxSFl5dq6maifdiuuaIC3MEltSlKt6pPJLNdNWhR6FIaKodaIahfqSeqOOaeRaeO34eILNb5AgZPl2ynGydqK720BzILNb5AgFSQ)jcqkaqOLAaXgGmTn7I9BjFasNbarGacffGi3TP3YelpdY1m(yv)teG0zaqe4OaILbfxc)ndk0g)0VNXTgDRLVfofGHreOadDfu40fBSomwqrEpKV3dkYDB6TmXUqoP)KowEoCcFSQ)jcqkaqOLAaXgGmTn7I9BjFasNbaPyaHIcqGEJtiwEgKRzmNUyJ1aInarUBtVLjwEgKRz8XQ(NiaPaaHwQbeBaY02Sl2VL8biDgaebciuuaIC3MEltSlKt6pPJLNdNWhR6FIaKodaIahfqOOae5Un9wMy5zqUMXhR6FIaKodaIahnO4s4VzqPCVMwi)z8y0MEk5ammIahn0vqHtxSX6Wybf59q(EpOyfGiaa58xhzHCcXUwJWS1FeebiuuaY5VoYc5eIDTgH)eq6aifpdqOOaeup3ArOF0meH1VWp5icUNkG0zaqkeqSeqSbicaqScqen1k2fYj9N0XYZHtytpGqrbiIMAflpdY1m20diwci2aeRae5Un9wMyXMR54wJD3GGVKXhR6FIaKoacTudiZdqkgqSbiYDB6TmXD3OPv5eIpw1)ebiDaeAPgqMhGumGyzqXLWFZGsDLgeRJU1Y3d5Oi7Qbyyeb2ndDfu40fBSomwqrEpKV3dkwbiIMAf7c5K(t6y55WjSPhqOOaertTILNb5AgB6beBaIOPwXYZGCnJrqxAbGmaicodqSeqSbitBZUy)wYhGuWaGuCqXLWFZGIkRUNDXTgBg5RJ6JDvuaggrGZFORGcNUyJ1HXckY7H89EqXkaraaY5VoYc5eIDTgHzR)iicqOOaKZFDKfYje7Anc)jG0bqkEgGqrbiOEU1Iq)OzicRFHFYreCpvaPZaGuiGyzqXLWFZGsV5(QDFshfBocgGbyagGbyia]] )


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
