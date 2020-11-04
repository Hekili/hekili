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


    spec:RegisterPack( "Retribution", 20201103, [[dye)LbqifLEeHaztuKpriugffYPOGwLuP6vkuMLOs7cYVuummfvhJqAzIkEgfQPri6AkeBJqq(gfLyCec5CuusRJqqvZJIQ7PG9jQ6GeckAHku9qcbQCrcbQ6JeckCscHQwPurZKqGIDQqAOeckTucHkpLKMQujFLqGsJLqqL9kYFLyWiDyQwmbpMOjtQlJAZs6ZiA0kYPvz1sLYRPaZwk3Me7w43knCPQJtiGLRQNd10bDDkTDc13fLXtrX5LkSEkk18ry)aNen1vsv7qonAoZZzUOIo3yuoglsZYCZAsf2rpNu7DPbojNudxHtQI4y4Fcw4TrsT37OTUo1vsfV2xYj1KQG9Aqr8rsiPQDiNgnN55mxurNBmkhJfPzzUOjvCpltJAwMNuNoTMJKqsvZyzsveeGkIJH)jyH3gaQiSEZ1xa6ueeGo6kMve4hqnoxanN55mpP2)B9ACsveeGkIJH)jyH3gaQiSEZ1xa6ueeGo6kMve4hqnoxanN55mh0jOtxcVnWO(NLRIGdhByg)LEWf4(phqqNakOtrqaQi4ndlTqwdOSy(7aqHNcdOWjgqDjCFa9WaQl2VMl0yeOtxcVnWdplynGbD6s4TbESHzKERvCj82O0omm3Wv4b5Un9MfyqNUeEBGhBygP3AfxcVnkTddZnCfEGKd(D4(yqNakOtxcVnWi5Un9Mf4H(fEBK7vhmsWwRiH2U6Mfdrp7sibHGTwrUyoiVGSK9oCcz7njyRvKlMdYlilzVdNqpR4xGZlQiIGqWwRi5BXUMr2Etc2AfjFl21m6zf)cS55mIHGoDj82aJK720BwGhByM2robXLUz1KkCaZ9Qd4EU1kq)jzig1oYjiU0nRMuHdy(HCiimA23pDHfZbe5AngXM5WqmbX7NUWI5aICTgJUiVzzedbD6s4Tbgj3TP3Sap2Wm17zH2U6CV6GGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJWqxAWGOZbD6s4Tbgj3TP3Sap2Wm4PJB6YwlI5GK9qYGoDj82aJK720BwGhByglMlhKvYnCfE4DZwBddWfHJS8SUiyHWnaD6s4Tbgj3TP3Sap2WmwmxoiRKB4k8GJNe7bJlVB27xK77TCV6GMfS1k6DZE)ICFVv0SGTwr6nliimsWwRixmhKxqwYEhoHEwXVaNFiN5eec2AfjFl21mcdDPbdIo3KGTwrY3IDnJEwXVaNx0rm0KrYDB6nlqKw)1NhLTwCZM)foHEwXVaN3SoNGa6pjdrWtHlWTOp2CJNtqmlJXCizKCdnhywxAxLR7lzKI3T9ne0PlH3gyKC3MEZc8ydZyXC5GSsUHRWdDJXLPnRXFUxDqWwRixmhKxqwYEhoHS9eec2AfjFl21mY2BsWwRi5BXUMryOlnyq05GoDj82aJK720BwGhByglMlhKvYnCfEq85TYwlECkoK1fH2U6CV6Grc2Af5I5G8cYs27WjKTNGqWwRi5BXUMr2Etc2AfjFl21m6zf)cS5IkImKGWi5Un9MfixmhKxqwYEhoHEwXVaN345eeYDB6nlqY3IDnJEwXVaN345gc60LWBdmsUBtVzbESHzSyUCqwj3Wv4b9Uk4s1(DK7vheS1kYfZb5fKLS3HtiBpbHGTwrY3IDnJS9MeS1ks(wSRz0Zk(fyZfveb60LWBdmsUBtVzbESHzSyUCqwj3Wv4bsVXsV14hxey3GCV6GGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJEwXVaBUOJa60LWBdmsUBtVzbESHzSyUCqwj3Wv4bHoi3Glcmx8MIhUm3RoiyRvKlMdYlilzVdNq2EccbBTIKVf7Agz7bD6s4Tbgj3TP3Sap2WmwmxoiRKB4k8Gc)SbWjhxQEqM7vhmA23pDHfZbe5AngXM5WqmbX7NUWI5aICTgJUiVOJyibbUNBTc0FsgIr6t8fCbd3xj)qoGoDj82aJK720BwGhByglMlhKvYnCfEOVzdn)cS)ACP2CSb5E1bbBTICXCqEbzj7D4eY2tqiyRvK8TyxZiBVjbBTIKVf7AgHHU0G8dIoNGqUBtVzbYfZb5fKLS3HtONv8lW5f5ieeZkyRvK8TyxZiBVj5Un9Mfi5BXUMrpR4xGZlYraD6s4Tbgj3TP3Sap2WmwmxoiRKB4k8Ga)y(nGFCPB2UzZ9Qdc2Af5I5G8cYs27WjKTNGqWwRi5BXUMr2Etc2AfjFl21mcdDPb5heDobHC3MEZcKlMdYlilzVdNqpR4xGZlYriiMvWwRi5BXUMr2EtYDB6nlqY3IDnJEwXVaNxKJa60LWBdmsUBtVzbESHzSyUCqwj3Wv4bo0ngJlWlKq7ZLTwQVlH3gER0Vz8N7vheS1kYfZb5fKLS3HtiBpbHGTwrY3IDnJS9MeS1ks(wSRzeg6sdYpi6Ccc5Un9MfixmhKxqwYEhoHEwXVaNxKJqqi3TP3SajFl21m6zf)cCErocOtxcVnWi5Un9Mf4XgMXI5YbzLCdxHh6z)Bf9jMFCrUk9ogN7vheS1kYfZb5fKLS3HtiBpbHGTwrY3IDnJS9MeS1ks(wSRzeg6sdYpi6CqNUeEBGrYDB6nlWJnmJfZLdYk5gUcpuVhdlkoKXfCFhKnhJZ9Qdc2Af5I5G8cYs27WjKTNGqWwRi5BXUMr2Etc2AfjFl21m6zf)cS5dIocOtxcVnWi5Un9Mf4XgMXI5YbzLCdxHhK7)2EiRlKnxFoCFCrH1ERDBK7vheS1kYfZb5fKLS3HtiBpbHGTwrY3IDnJS9MeS1ks(wSRz0Zk(fyZZzoOtxcVnWi5Un9Mf4XgMXI5YbzLCdxHhK7)2EiRlKnxFoCFCrW1KCUxDqWwRixmhKxqwYEhoHS9eec2AfjFl21mY2BsWwRi5BXUMrpR4xGnx0raD6s4Tbgj3TP3Sap2WmwmxoiRKB4k8q2FWPlilyMuHdyzRf9ZyOt6WjqNUeEBGrYDB6nlWJnmJfZLdYk5gUcpGNwPbchKFCP6bzUxDqWwRixmhKxqwYEhoHS9eec2AfjFl21mY2d60LWBdmsUBtVzbESHzSyUCqwj3Wv4H2j(cYYETI0Jdd5h0PlH3gyKC3MEZc8ydZyXC5GSsUHRWd)bTERuzhoXFzRfBeKf3GCV6GGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJWqxAWGOZjiK720BwGCXCqEbzj7D4e6zf)cC(bJNtqi3TP3SajFl21m6zf)cC(bJNd60LWBdmsUBtVzbESHzSyUCqwj3Wv4HNvwixiTN2djx0S4tYGoDj82aJK720BwGhByglMlhKvYnCfEq85TYwly4(kyqNUeEBGrYDB6nlWJnmJfZLdYk5gUcpKnDFl7csCPVzvCso3RoiyRvKlMdYlilzVdNq2EccbBTIKVf7Agz7njyRvK8TyxZONv8lWMpKZCqNUeEBGrYDB6nlWJnmJfZLdYk5gUcpOF21fYMRphUpUi4Aso3RoiyRvKlMdYlilzVdNq2EccbBTIKVf7Agz7njyRvK8TyxZONv8lWMpKZCqNUeEBGrYDB6nlWJnmJfZLdYk5gUcpOF21fh3FVhqCrH1ERDBK7vheS1kYfZb5fKLS3HtiBpbHGTwrY3IDnJS9MeS1ks(wSRz0Zk(fyZhYzoOtxcVnWi5Un9Mf4XgMXI5YbzLCdxHhi)niXL()u8w5Dso3RomRGTwrUyoiVGSK9oCcz7nnRGTwrY3IDnJS9GoDj82aJK720BwGhByglMlhKvYnCfEaFXHH8xiBU(C4(4IGRj5CV6GGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJEwXVaB(GOJa60LWBdmsUBtVzbESHzSyUCqwj3Wv4b8fhgYFHS56ZH7JlkS2BTBJCV6GGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJEwXVaB(qoZbD6s4Tbgj3TP3Sap2WmwmxoiRKB4k8GB24j)DCPUbSS1s)MXFUxDywO34aIKVf7AgXHl0yTj5Un9MfixmhKxqwYEhoHEwXVaB(ieeqVXbejFl21mIdxOXAtYDB6nlqY3IDnJEwXVaB(iMGNcNx05eetBRJs)MXF(bJnbpf2CrNBc6noGOm3aUS1IJNymIdxOXAqNUeEBGrYDB6nlWJnmJfZLdYk5gUcpi(W3gLTw0SYH5CV6GGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJWqxAWGOZjiK720BwGCXCqEbzj7D4e6zf)cC(bJNtqi3TP3SajFl21m6zf)cC(bJNd60LWBdmsUBtVzbESHzSyUCqwj3Wv4bhpj2dgxE3S3Vi33B5E1bnlyRv07M9(f5(EROzbBTI0BwqqyKGTwrUyoiVGSK9oCc9SIFbo)qoZjieS1ks(wSRzeg6sdgeDUjbBTIKVf7Ag9SIFboVOJyOjJK720BwGiT(RppkBT4Mn)lCc9SIFboVzDobb8u4cCl6Jn345eeZYymhsgj3qZbM1L2v56(sgP4DBFdbD6s4Tbgj3TP3Sap2WmwmxoiRKB4k8GbXclBT4H84awQ2VJCV6GGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJWqxAq(brNtqi3TP3Sa5I5G8cYs27Wj0Zk(f48gpNGywbBTIKVf7Agz7nj3TP3SajFl21m6zf)cCEJNd60LWBdmsUBtVzbESHzCXCqEbzj7D4uUxDWOPT1rPFZ4p)Ginbpf28riiM2whL(nJ)8dgBcEkC(riiGEJdiAABDuCXCqYpIdxOXAtYDB6nlqtBRJIlMds(rpR4xGhMBOj4PWf4wM6jhMd60LWBdmsUBtVzbESHzKVf7Ao3Roy0026O0Vz8NFqKMGNcB(ieetBRJs)MXF(bJnbpfo)ieeqVXbenTTokUyoi5hXHl0yTj5Un9MfOPT1rXfZbj)ONv8lWdZn0e8u4cClt9KdZbD6s4Tbgj3TP3Sap2WmoEIJYK3ABgOtxcVnWi5Un9Mf4XgMzABDuCXCqYFUxDaEkCbULPEYH5MmYibBTICXCqEbzj7D4eY2tqiyRvK8TyxZiBVHeegjyRvKlMdYlilzVdNq6nlmj3TP3Sa5I5G8cYs27Wj0Zk(f48ICobHGTwrY3IDnJ0BwysUBtVzbs(wSRz0Zk(f48ICUHgc60LWBdmsUBtVzbESHzQx4TYZsd24cYCV6W026O0Vz8NFWytgjyRvKlMdYlilzVdNqpR4xGZlIgJuQjiK720BwGCXCqEbzj7D4e6zf)cS5KsnbHC3MEZcKlMdYlilzVdNqpR4xGZpsogAcEkCbULPEYH5MmAwO34aIW879tNcIdxOXAccbBTIW879tNcY2BiOtxcVnWi5Un9Mf4XgMboXfBiS2qxQ7l5CV6a8uyZhYHGqWwRONLg0ymUu3xYiBpOtxcVnWi5Un9Mf4XgMrOTRUS1cCIlCWkDK7vheS1kYfZb5fKLS3HtiBpbHGTwrY3IDnJS9MeS1ks(wSRzeg6sdgeDoOtxcVnWi5Un9Mf4XgMH06V(8OS1IB28VWPCV6WSqVXbejFl21mIdxOXAtgj3TP3Sa5I5G8cYs27Wj0Zk(fyZhX0026O0Vz8NFWycc5Un9MfixmhKxqwYEhoHEwXVaNFqKJyibHrqVXbejFl21mIdxOXAtYDB6nlqY3IDnJEwXVaBoPuBAABDu63m(Zpiscc5Un9Mfi5BXUMrpR4xGZpiYrme0PlH3gyKC3MEZc8ydZKTFtlMVO8mEdpKCUxDqUBtVzbYfZb5fKLS3HtONv8lWMtk1MM2whL(nJ)8dgtqa9ghqK8TyxZioCHgRnj3TP3SajFl21m6zf)cS5KsTPPT1rPFZ4p)GijiK720BwGCXCqEbzj7D4e6zf)cC(brocbHC3MEZcK8TyxZONv8lW5he5iGoDj82aJK720BwGhByM6kTywxCZM)dYfb2vY9Qdgn77NUWI5aICTgJyZCyiMG49txyXCarUwJrxK345ee4EU1kq)jzigPpXxWfmCFL8d5yOPznsWwRixmhKxqwYEhoHS9eec2AfjFl21mY2BOjJK720BwGeAUMlBT0nlgEsg9SIFbopPu3DJnj3TP3Sa1nRMuHdi6zf)cCEsPU7gBiOtxcVnWi5Un9Mf4XgMrHv2VJYwlnR80f9ZUco3RoyKGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKT3KGTwrY3IDnJWqxAWGOZn00026O0Vz8B(GXGoDj82aJK720BwGhByME7F1oUGSi0Cmm3Roy0SVF6clMdiY1AmInZHHycI3pDHfZbe5AngDrEJNtqG75wRa9NKHyK(eFbxWW9vYpKJHGobuqNUeEBGr1lo8e)4XgMrS)Nl04CdxHh04I0XqxOX5k2BwEa3ZTwb6pjdXi9j(cUGH7RKFihccbBTIyL(oE2Js)MXpY2BsZc2Af1nRMuHdisVzHjbBTI0N4l4sV97xmJ0BwqqG75wRa9NKHyK(eFbxWW9vYpKJjbBTIKVf7Agz7njyRvK8TyxZim0LgyUOZbD6s4TbgvV4Wt8JhBygm)E)0PK7vhmYOzHEJdis(wSRzehUqJ1MeS1kYfZb5fKLS3HtiBpbHC3MEZcKlMdYlilzVdNqpR4xGZNZigsqyKGTwrY3IDnJS9eeYDB6nlqY3IDnJEwXVaNpNrm0qtgnl0BCar1l8w5zPbBCbjIdxOXAcc5Un9MfO6fER8S0GnUGe9SIFb2CrNtqi3TP3SavVWBLNLgSXfKONv8lW5nEednz0SqVXbeXMHLw4TrbZbKdjJ4WfASMGqUBtVzbIndlTWBJcMdihsg9SIFb28riiK720BwGyZWsl82OG5aYHKrpR4xGZl6igAcEkCbULPEYH5GoDj82aJQxC4j(XJnmJypebShEIFCzYvu4p3Roy0SqVXbevVWBLNLgSXfKioCHgRjiK720BwGQx4TYZsd24cs0Zk(f48KsD3fDobHMfS1kQEH3kplnyJlir2Ednz0SqVXbeXMHLw4TrbZbKdjJ4WfASMGqUBtVzbIndlTWBJcMdihsg9SIFbopPu3DrNtqOzbBTIyZWsl82OG5aYHKr2EdjiW9CRvG(tYqmsFIVGly4(k5hYb0PlH3gyu9IdpXpESHzyZWsl82OG5aYHKZ9Qd4EU1kq)jzigPpXxWfmCFfZhm2Krgnl0BCarY3IDnJ4WfASMGqWwRi5BXUMr6nlmj3TP3SajFl21m6zf)cCErNBibHGTwrY3IDnJWqxAq(bJjiK720BwGCXCqEbzj7D4e6zf)cCErNtqOzbBTIQx4TYZsd24csKT3qtWtHlWTm1tomh0PlH3gyu9IdpXpESHz0N4l4cgUVsUxDqS)Nl0yKgxKog6cn20Sc2Afj2dra7HN4hxMCff(r2Etgz0SqVXbejFl21mIdxOXAcc5Un9Mfi5BXUMrpR4xGZtk1D3ydnz0SqVXbeXMHLw4TrbZbKdjJ4WfASMGqUBtVzbIndlTWBJcMdihsg9SIFbopPu3DJjiW9CRvG(tYqmsFIVGly4(k5hm2qccCp3AfO)KmeJ0N4l4cgUVs(HCmze0BCartBRJIlMds(rC4cnwBsUBtVzbAABDuCXCqYp6zf)cS5KsD3nMGqWwRi5BXUMr2Etc2AfjFl21mcdDPbMl6Cdne0PlH3gyu9IdpXpESHzGSsFZFCrm)6tcZ9Qdgnl0BCarY3IDnJ4WfASMGqUBtVzbs(wSRz0Zk(f48KsD3n2qtgnl0BCarSzyPfEBuWCa5qYioCHgRjiK720BwGyZWsl82OG5aYHKrpR4xGZtk1D3yt4EU1kq)jzigPpXxWfmCFfZhm2qtgnl0BCar1l8w5zPbBCbjIdxOXAccO34aIW879tNcIdxOXAtYDB6nlqy(9(Ptb9SIFbopPu3DJjiK720BwGQx4TYZsd24cs0Zk(f48KsD3n2qtgnRCfZHhquWYFB7RrC4cnwtqi3TP3Saj2dra7HN4hxMCff(rpR4xGZtk1gsqa9ghq0026O4I5GKFehUqJ1MK720BwGM2whfxmhK8JEwXVaBoPu3DJjieS1kAABDuCXCqYpY2tqiyRvK8TyxZiBVjbBTIKVf7AgHHU0aZfDobHGTwrI9qeWE4j(XLjxrHFKTh0jGc60LWBdmIKd(D4(4XgMr6TwXLWBJs7WWCdxHhQxC4j(X5E1HPT1rPFZ4p)Wieec2AfnTTokUyoi5hz7ji0SGTwr1l8w5zPbBCbjY2tqOzbBTIyZWsl82OG5aYHKr2EqNUeEBGrKCWVd3hp2WmcngJVGSS1c2QOWpOtxcVnWiso43H7JhBygHgJXxqw2AXTqRsa60LWBdmIKd(D4(4XgMrOXy8fKLTwYUaYpOtxcVnWiso43H7JhBygHgJXxqw2Ab3)xqc60LWBdmIKd(D4(4XgMrFIVGlWT1Y9QdZQzbBTI6MvtQWbez7nz0SVF6clMdiY1AmInZHHycI3pDHfZbe5AngDrEJNBOjJM2whL(nJFZhYHGyABDu63m(nFqKMmsUBtVzbsO5AUS1s3Sy4jz0Zk(f48KsD3ZHGqZc2AfXMHLw4TrbZbKdjJS9eeAwWwRO6fER8S0GnUGez7n0qtgnl0BCar1l8w5zPbBCbjIdxOXAcc5Un9MfO6fER8S0GnUGe9SIFbopPu3DrNBOjJMf6noGi2mS0cVnkyoGCizehUqJ1eeYDB6nlqSzyPfEBuWCa5qYONv8lW5jL6Ul6CdbD6s4TbgrYb)oCF8ydZK5gWLTwC8eJZ9QdgnTTok9Bg)dZjiM2whL(nJFZhYXKrYDB6nlqcnxZLTw6MfdpjJEwXVaNNuQ7EoeeAwWwRi2mS0cVnkyoGCizKTNGqZc2AfvVWBLNLgSXfKiBVHgAYOzF)0fwmhqKR1yeBMddXeeVF6clMdiY1Am6I85m3qtgnl0BCarSzyPfEBuWCa5qYioCHgRjiK720BwGyZWsl82OG5aYHKrpR4xGZl6igAYOzHEJdiQEH3kplnyJlirC4cnwtqi3TP3SavVWBLNLgSXfKONv8lW5fDedbD6s4TbgrYb)oCF8ydZi0Cnx2APBwm8KCUxDyABDu63m(nFWyqNUeEBGrKCWVd3hp2WmtUIc)LTwYEhoL7vhM2whL(nJFZhejOtxcVnWiso43H7JhByMUz1KkCaZ9QdZQzbBTI6MvtQWbez7nz0026O0Vz8B(qoeetBRJs)MXV5dI0KC3MEZcKqZ1CzRLUzXWtYONv8lW5jL6UNJHGoDj82aJi5GFhUpESHzKERvCj82O0omm3Wv4H6fhEIFCUxDWiO)KmenXEdoH6LqZhYzobHGTwrUyoiVGSK9oCcz7jieS1ks(wSRzKTNGqWwRiwPVJN9O0Vz8JS9gc60LWBdmIKd(D4(4XgMr(wSR5VGH)zaN7vhK720BwGKVf7A(ly4FgWi5K)KmUuFxcVn8w(brrMLrmz0026O0Vz8B(qoeetBRJs)MXV5dgBsUBtVzbsO5AUS1s3Sy4jz0Zk(f48KsD3ZHGyABDu63m(hePj5Un9MfiHMR5YwlDZIHNKrpR4xGZtk1DphtYDB6nlqDZQjv4aIEwXVaNNuQ7Eogc60LWBdmIKd(D4(4XgMr6TwXLWBJs7WWCdxHhQxC4j(XGoDj82aJi5GFhUpESHzKVf7A(ly4FgW5E1HPT1rPFZ438brc60LWBdmIKd(D4(4XgMrUHKd47qwxQnxHbD6s4TbgrYb)oCF8ydZ8S3FbzP2CfgN7vhG(tYq0e7n4uPxcZlIMtqa9NKHOj2BWPsVeAEoZjiQh5eS8SIFb2CJhb0PlH3gyejh87W9XJnmJ)sp4cC)NdyUxDyABDu63m(nFqKGoDj82aJi5GFhUpESHzKBGz57WBJCV6a8u4cClt9K5jL6KQy(X3gPrZzEoZfv05IMuZ8pUGeNufbRimfXnQi(rfHHi8akG21edONs)(qaTUpGkIvV4Wt8JfXa0NfbS3ZAafVkmG6w4Q4qwdOYjpizmc0PiyUGburir4burWTHy(HSgqfXKRyo8aIeHdXHl0yTigGcxavetUI5Wdiseorma1irnJHiqNGo7AIburmlMlhKvWIyaQlH3gaAMJb0yHaADTHgqVaqHthgqpL(9HiqNI4v63hYAaDea1LWBdaTDyigb6mP6w40(jvvral3C4(j12HH4uxjvnxDBdM6knQOPUsQUeEBKuFwWAaNu5WfASonEcMgnNuxjvoCHgRtJNuDj82iPk9wR4s4TrPDyysTDyyjCfoPk3TP3SaNGPrno1vsLdxOX604jvxcVnsQsV1kUeEBuAhgMuBhgwcxHtQKCWVd3hNGjysT)z5Qi4WuxPrfn1vs1LWBJKQ)sp4cC)NdysLdxOX604jycMuj5GFhUpo1vAurtDLu5WfASonEsv(hK)ZtQtBRJs)MXpGMFaqhbqjiaubBTIM2whfxmhK8JS9akbbGQzbBTIQx4TYZsd24csKThqjiaunlyRveBgwAH3gfmhqoKmY2NuDj82iPk9wR4s4TrPDyysTDyyjCfoPwV4Wt8JtW0O5K6kP6s4TrsvOXy8fKLTwWwff(tQC4cnwNgpbtJACQRKQlH3gjvHgJXxqw2AXTqRsKu5WfASonEcMgvKPUsQUeEBKufAmgFbzzRLSlG8Nu5WfASonEcMgDKuxjvxcVnsQcngJVGSS1cU)VGmPYHl0yDA8emnQiuQRKkhUqJ1PXtQY)G8FEsDwavZc2Af1nRMuHdiY2dOMauJa0zb03pDHfZbe5AngXM5WqmGsqaOVF6clMdiY1Am6canpGA8Ca1qa1eGAeGoTTok9Bg)aQ5daAoakbbGoTTok9Bg)aQ5daQibutaQraQC3MEZcKqZ1CzRLUzXWtYONv8lWaAEaLuQb0UdO5aOeeaQMfS1kIndlTWBJcMdihsgz7buccavZc2AfvVWBLNLgSXfKiBpGAiGAiGAcqncqNfqHEJdiQEH3kplnyJlirC4cnwdOeeaQC3MEZcu9cVvEwAWgxqIEwXVadO5busPgq7oGk6Ca1qa1eGAeGolGc9ghqeBgwAH3gfmhqoKmIdxOXAaLGaqL720BwGyZWsl82OG5aYHKrpR4xGb08akPudODhqfDoGAys1LWBJKQ(eFbxGBRLGPrnlPUsQC4cnwNgpPk)dY)5jvJa0PT1rPFZ4hqha05akbbGoTTok9Bg)aQ5daAoaQja1iavUBtVzbsO5AUS1s3Sy4jz0Zk(fyanpGsk1aA3b0CauccavZc2AfXMHLw4TrbZbKdjJS9akbbGQzbBTIQx4TYZsd24csKThqneqneqnbOgbOZcOVF6clMdiY1AmInZHHyaLGaqF)0fwmhqKR1y0faAEanN5aQHaQja1iaDwaf6noGi2mS0cVnkyoGCizehUqJ1akbbGk3TP3SaXMHLw4TrbZbKdjJEwXVadO5burhbqneqnbOgbOZcOqVXbevVWBLNLgSXfKioCHgRbuccavUBtVzbQEH3kplnyJlirpR4xGb08aQOJaOgMuDj82iPM5gWLTwC8eJtW0OIOuxjvoCHgRtJNuL)b5)8K6026O0Vz8dOMpaOgNuDj82iPk0Cnx2APBwm8KCcMg1SM6kPYHl0yDA8KQ8pi)NNuN2whL(nJFa18bavKjvxcVnsQtUIc)LTwYEhoLGPrfDEQRKkhUqJ1PXtQY)G8FEsDwavZc2Af1nRMuHdiY2dOMauJa0PT1rPFZ4hqnFaqZbqjia0PT1rPFZ4hqnFaqfjGAcqL720BwGeAUMlBT0nlgEsg9SIFbgqZdOKsnG2Danha1WKQlH3gj1Uz1KkCatW0OIkAQRKkhUqJ1PXtQY)G8FEs1iaf6pjdrtS3GtOEjeqnFaqZzoGsqaOc2Af5I5G8cYs27WjKThqjiaubBTIKVf7Agz7buccavWwRiwPVJN9O0Vz8JS9aQHjvxcVnsQsV1kUeEBuAhgMuBhgwcxHtQ1lo8e)4emnQO5K6kPYHl0yDA8KQ8pi)NNuL720BwGKVf7A(ly4FgWi5K)KmUuFxcVn8gGMFaqffzwgbqnbOgbOtBRJs)MXpGA(aGMdGsqaOtBRJs)MXpGA(aGAmGAcqL720BwGeAUMlBT0nlgEsg9SIFbgqZdOKsnG2DanhaLGaqN2whL(nJFaDaqfjGAcqL720BwGeAUMlBT0nlgEsg9SIFbgqZdOKsnG2Danha1eGk3TP3Sa1nRMuHdi6zf)cmGMhqjLAaT7aAoaQHjvxcVnsQY3IDn)fm8pd4emnQOgN6kPYHl0yDA8KQlH3gjvP3AfxcVnkTddtQTddlHRWj16fhEIFCcMgvurM6kPYHl0yDA8KQ8pi)NNuN2whL(nJFa18bavKjvxcVnsQY3IDn)fm8pd4emnQOJK6kP6s4TrsvUHKd47qwxQnxHtQC4cnwNgpbtJkQiuQRKkhUqJ1PXtQY)G8FEsf6pjdrtS3GtLEjeqZdOIO5akbbGc9NKHOj2BWPsVecOMdO5mhqjia06roblpR4xGbuZbuJhjP6s4Trs9zV)cYsT5kmobtJkQzj1vsLdxOX604jv5Fq(ppPoTTok9Bg)aQ5daQitQUeEBKu9x6bxG7)CatW0OIkIsDLu5WfASonEsv(hK)ZtQWtHlWTm1tcO5busPoP6s4TrsvUbMLVdVnsWemPwV4Wt8JtDLgv0uxjvoCHgRtJNu3(KkMHjvxcVnsQI9)CHgNuf7nlNuX9CRvG(tYqmsFIVGly4(kaA(banhaLGaqfS1kIv674zpk9Bg)iBpGAcq1SGTwrDZQjv4aI0BwaOMaubBTI0N4l4sV97xmJ0BwaOeeakUNBTc0FsgIr6t8fCbd3xbqZpaO5aOMaubBTIKVf7Agz7butaQGTwrY3IDnJWqxAaGAoGk68KQy)lHRWjvnUiDm0fACcMgnNuxjvoCHgRtJNuL)b5)8KQraQra6Sak0BCarY3IDnJ4WfASgqnbOc2Af5I5G8cYs27WjKThqjiau5Un9MfixmhKxqwYEhoHEwXVadO5b0CgbqneqjiauJaubBTIKVf7Agz7buccavUBtVzbs(wSRz0Zk(fyanpGMZiaQHaQHaQja1iaDwaf6noGO6fER8S0GnUGeXHl0ynGsqaOYDB6nlq1l8w5zPbBCbj6zf)cmGAoGk6CaLGaqL720BwGQx4TYZsd24cs0Zk(fyanpGA8iaQHaQja1iaDwaf6noGi2mS0cVnkyoGCizehUqJ1akbbGk3TP3SaXMHLw4TrbZbKdjJEwXVadOMdOJaOeeaQC3MEZceBgwAH3gfmhqoKm6zf)cmGMhqfDea1qa1eGcpfUa3YupjGoaOZtQUeEBKuX879tNscMg14uxjvoCHgRtJNuL)b5)8KQra6Sak0BCar1l8w5zPbBCbjIdxOXAaLGaqL720BwGQx4TYZsd24cs0Zk(fyanpGsk1aA3burNdOeeaQMfS1kQEH3kplnyJlir2Ea1qa1eGAeGolGc9ghqeBgwAH3gfmhqoKmIdxOXAaLGaqL720BwGyZWsl82OG5aYHKrpR4xGb08akPudODhqfDoGsqaOAwWwRi2mS0cVnkyoGCizKThqneqjiauCp3AfO)KmeJ0N4l4cgUVcGMFaqZjP6s4TrsvShIa2dpXpUm5kk8NGPrfzQRKkhUqJ1PXtQY)G8FEsf3ZTwb6pjdXi9j(cUGH7RaOMpaOgdOMauJauJa0zbuO34aIKVf7AgXHl0ynGsqaOc2AfjFl21msVzbGAcqL720BwGKVf7Ag9SIFbgqZdOIohqneqjiaubBTIKVf7AgHHU0aan)aGAmGsqaOYDB6nlqUyoiVGSK9oCc9SIFbgqZdOIohqjiaunlyRvu9cVvEwAWgxqIS9aQHaQjafEkCbULPEsaDaqNNuDj82iPYMHLw4TrbZbKdjNGPrhj1vsLdxOX604jv5Fq(ppPk2)ZfAmsJlshdDHgdOMa0zbubBTIe7HiG9Wt8JltUIc)iBpGAcqncqncqNfqHEJdis(wSRzehUqJ1akbbGk3TP3SajFl21m6zf)cmGMhqjLAaT7aQXaQHaQja1iaDwaf6noGi2mS0cVnkyoGCizehUqJ1akbbGk3TP3SaXMHLw4TrbZbKdjJEwXVadO5busPgq7oGAmGsqaO4EU1kq)jzigPpXxWfmCFfan)aGAmGAiGsqaO4EU1kq)jzigPpXxWfmCFfan)aGMdGAcqncqHEJdiAABDuCXCqYpIdxOXAa1eGk3TP3SanTTokUyoi5h9SIFbgqnhqjLAaT7aQXakbbGkyRvK8TyxZiBpGAcqfS1ks(wSRzeg6sdauZburNdOgcOgMuDj82iPQpXxWfmCFLemnQiuQRKkhUqJ1PXtQY)G8FEs1iaDwaf6noGi5BXUMrC4cnwdOeeaQC3MEZcK8TyxZONv8lWaAEaLuQb0UdOgdOgcOMauJa0zbuO34aIyZWsl82OG5aYHKrC4cnwdOeeaQC3MEZceBgwAH3gfmhqoKm6zf)cmGMhqjLAaT7aQXaQjaf3ZTwb6pjdXi9j(cUGH7RaOMpaOgdOgcOMauJa0zbuO34aIQx4TYZsd24csehUqJ1akbbGc9ghqeMFVF6uqC4cnwdOMau5Un9Mfim)E)0PGEwXVadO5busPgq7oGAmGsqaOYDB6nlq1l8w5zPbBCbj6zf)cmGMhqjLAaT7aQXaQHaQja1iaDwavUI5Wdiky5VT91akbbGk3TP3Saj2dra7HN4hxMCff(rpR4xGb08akPudOgcOeeak0BCartBRJIlMds(rC4cnwdOMau5Un9MfOPT1rXfZbj)ONv8lWaQ5akPudODhqngqjiaubBTIM2whfxmhK8JS9akbbGkyRvK8TyxZiBpGAcqfS1ks(wSRzeg6sdauZburNdOeeaQGTwrI9qeWE4j(XLjxrHFKTpP6s4TrsfYk9n)XfX8RpjmbtWKQC3MEZcCQR0OIM6kPYHl0yDA8KQ8pi)NNuncqfS1ksOTRUzXq0ZUecOeeaQGTwrUyoiVGSK9oCcz7butaQGTwrUyoiVGSK9oCc9SIFbgqZdOIkIauccavWwRi5BXUMr2Ea1eGkyRvK8TyxZONv8lWaQ5aAoJaOgMuDj82iP2VWBJemnAoPUsQC4cnwNgpPk)dY)5jvCp3AfO)KmeJAh5eex6MvtQWbeqZpaO5aOeeaQra6Sa67NUWI5aICTgJyZCyigqjia03pDHfZbe5AngDbGMhqnlJaOgMuDj82iP2oYjiU0nRMuHdycMg14uxjvoCHgRtJNuL)b5)8KQGTwrUyoiVGSK9oCcz7buccavWwRi5BXUMr2Ea1eGkyRvK8TyxZim0LgaOdaQOZtQUeEBKuR3ZcTD1jyAurM6kP6s4TrsfpDCtx2ArmhKShsoPYHl0yDA8emn6iPUsQC4cnwNgpPgUcNuF3S12WaCr4ilpRlcwiCJKQlH3gj13nBTnmaxeoYYZ6IGfc3ibtJkcL6kPYHl0yDA8KQlH3gjvhpj2dgxE3S3Vi33Bjv5Fq(ppPQzbBTIE3S3Vi33BfnlyRvKEZcaLGaqncqfS1kYfZb5fKLS3HtONv8lWaA(banN5akbbGkyRvK8TyxZim0LgaOdaQOZbutaQGTwrY3IDnJEwXVadO5burhbqneqnbOgbOYDB6nlqKw)1NhLTwCZM)foHEwXVadO5buZ6CaLGaqH(tYqe8u4cCl6JbuZbuJNdOeea6SakJXCizKCdnhywxAxLR7lzKI3T9budtQHRWjvhpj2dgxE3S3Vi33BjyAuZsQRKkhUqJ1PXtQUeEBKu7gJltBwJ)KQ8pi)NNufS1kYfZb5fKLS3HtiBpGsqaOc2AfjFl21mY2dOMaubBTIKVf7AgHHU0aaDaqfDEsnCfoP2ngxM2Sg)jyAuruQRKkhUqJ1PXtQUeEBKufFERS1IhNIdzDrOTRoPk)dY)5jvJaubBTICXCqEbzj7D4eY2dOeeaQGTwrY3IDnJS9aQjavWwRi5BXUMrpR4xGbuZburfraQHakbbGAeGk3TP3Sa5I5G8cYs27Wj0Zk(fyanpGA8CaLGaqL720BwGKVf7Ag9SIFbgqZdOgphqnmPgUcNufFERS1IhNIdzDrOTRobtJAwtDLu5WfASonEs1LWBJKQExfCPA)osQY)G8FEsvWwRixmhKxqwYEhoHS9akbbGkyRvK8TyxZiBpGAcqfS1ks(wSRz0Zk(fya1CavurusnCfoPQ3vbxQ2VJemnQOZtDLu5WfASonEs1LWBJKkP3yP3A8JlcSBqsv(hK)ZtQc2Af5I5G8cYs27WjKThqjiaubBTIKVf7Agz7butaQGTwrY3IDnJEwXVadOMdOIossnCfoPs6nw6Tg)4Ia7gKGPrfv0uxjvoCHgRtJNuDj82iPk0b5gCrG5I3u8WLjv5Fq(ppPkyRvKlMdYlilzVdNq2EaLGaqfS1ks(wSRzKTpPgUcNuf6GCdUiWCXBkE4YemnQO5K6kPYHl0yDA8KQlH3gjvf(zdGtoUu9GmPk)dY)5jvJa0zb03pDHfZbe5AngXM5WqmGsqaOVF6clMdiY1Am6canpGk6iaQHakbbGI75wRa9NKHyK(eFbxWW9va08daAoj1Wv4KQc)SbWjhxQEqMGPrf14uxjvoCHgRtJNuDj82iP23SHMFb2FnUuBo2GKQ8pi)NNufS1kYfZb5fKLS3HtiBpGsqaOc2AfjFl21mY2dOMaubBTIKVf7AgHHU0aan)aGk6CaLGaqL720BwGCXCqEbzj7D4e6zf)cmGMhqf5iakbbGolGkyRvK8TyxZiBpGAcqL720BwGKVf7Ag9SIFbgqZdOICKKA4kCsTVzdn)cS)ACP2CSbjyAurfzQRKkhUqJ1PXtQUeEBKuf4hZVb8JlDZ2nBsv(hK)ZtQc2Af5I5G8cYs27WjKThqjiaubBTIKVf7Agz7butaQGTwrY3IDnJWqxAaGMFaqfDoGsqaOYDB6nlqUyoiVGSK9oCc9SIFbgqZdOICeaLGaqNfqfS1ks(wSRzKThqnbOYDB6nlqY3IDnJEwXVadO5burossnCfoPkWpMFd4hx6MTB2emnQOJK6kPYHl0yDA8KQlH3gjvo0ngJlWlKq7ZLTwQVlH3gER0Vz8NuL)b5)8KQGTwrUyoiVGSK9oCcz7buccavWwRi5BXUMr2Ea1eGkyRvK8TyxZim0LgaO5haurNdOeeaQC3MEZcKlMdYlilzVdNqpR4xGb08aQihbqjiau5Un9Mfi5BXUMrpR4xGb08aQihjPgUcNu5q3ymUaVqcTpx2AP(UeEB4Ts)MXFcMgvurOuxjvoCHgRtJNuDj82iP2Z(3k6tm)4ICv6DmoPk)dY)5jvbBTICXCqEbzj7D4eY2dOeeaQGTwrY3IDnJS9aQjavWwRi5BXUMryOlnaqZpaOIopPgUcNu7z)Bf9jMFCrUk9ogNGPrf1SK6kPYHl0yDA8KQlH3gj169yyrXHmUG77GS5yCsv(hK)ZtQc2Af5I5G8cYs27WjKThqjiaubBTIKVf7Agz7butaQGTwrY3IDnJEwXVadOMpaOIossnCfoPwVhdlkoKXfCFhKnhJtW0OIkIsDLu5WfASonEs1LWBJKQC)32dzDHS56ZH7JlkS2BTBJKQ8pi)NNufS1kYfZb5fKLS3HtiBpGsqaOc2AfjFl21mY2dOMaubBTIKVf7Ag9SIFbgqnhqZzEsnCfoPk3)T9qwxiBU(C4(4IcR9w72ibtJkQzn1vsLdxOX604jvxcVnsQY9FBpK1fYMRphUpUi4AsoPk)dY)5jvbBTICXCqEbzj7D4eY2dOeeaQGTwrY3IDnJS9aQjavWwRi5BXUMrpR4xGbuZburhjPgUcNuL7)2EiRlKnxFoCFCrW1KCcMgnN5PUsQC4cnwNgpPgUcNuZ(doDbzbZKkCalBTOFgdDshoLuDj82iPM9hC6cYcMjv4aw2Ar)mg6KoCkbtJMJOPUsQC4cnwNgpP6s4TrsfpTsdeoi)4s1dYKQ8pi)NNufS1kYfZb5fKLS3HtiBpGsqaOc2AfjFl21mY2NudxHtQ4PvAGWb5hxQEqMGPrZjNuxjvoCHgRtJNudxHtQTt8fKL9AfPhhgYFs1LWBJKA7eFbzzVwr6XHH8NGPrZX4uxjvoCHgRtJNuDj82iP(h06TsLD4e)LTwSrqwCdsQY)G8FEsvWwRixmhKxqwYEhoHS9akbbGkyRvK8TyxZiBpGAcqfS1ks(wSRzeg6sda0bav05akbbGk3TP3Sa5I5G8cYs27Wj0Zk(fyan)aGA8CaLGaqL720BwGKVf7Ag9SIFbgqZpaOgppPgUcNu)dA9wPYoCI)Ywl2iilUbjyA0CezQRKkhUqJ1PXtQHRWj1NvwixiTN2djx0S4tYjvxcVnsQpRSqUqApThsUOzXNKtW0O5msQRKkhUqJ1PXtQHRWjvXN3kBTGH7RGtQUeEBKufFERS1cgUVcobtJMJiuQRKkhUqJ1PXtQUeEBKuZMUVLDbjU03SkojNuL)b5)8KQGTwrUyoiVGSK9oCcz7buccavWwRi5BXUMr2Ea1eGkyRvK8TyxZONv8lWaQ5daAoZtQHRWj1SP7BzxqIl9nRItYjyA0CmlPUsQC4cnwNgpP6s4Trsv)SRlKnxFoCFCrW1KCsv(hK)ZtQc2Af5I5G8cYs27WjKThqjiaubBTIKVf7Agz7butaQGTwrY3IDnJEwXVadOMpaO5mpPgUcNu1p76czZ1Nd3hxeCnjNGPrZreL6kPYHl0yDA8KQlH3gjv9ZUU44(79aIlkS2BTBJKQ8pi)NNufS1kYfZb5fKLS3HtiBpGsqaOc2AfjFl21mY2dOMaubBTIKVf7Ag9SIFbgqnFaqZzEsnCfoPQF21fh3FVhqCrH1ERDBKGPrZXSM6kPYHl0yDA8KQlH3gjvYFdsCP)pfVvENKtQY)G8FEsDwavWwRixmhKxqwYEhoHS9aQjaDwavWwRi5BXUMr2(KA4kCsL83Gex6)tXBL3j5emnQXZtDLu5WfASonEs1LWBJKk(Idd5Vq2C95W9XfbxtYjv5Fq(ppPkyRvKlMdYlilzVdNq2EaLGaqfS1ks(wSRzKThqnbOc2AfjFl21m6zf)cmGA(aGk6ij1Wv4Kk(Idd5Vq2C95W9XfbxtYjyAuJfn1vsLdxOX604jvxcVnsQ4lomK)czZ1Nd3hxuyT3A3gjv5Fq(ppPkyRvKlMdYlilzVdNq2EaLGaqfS1ks(wSRzKThqnbOc2AfjFl21m6zf)cmGA(aGMZ8KA4kCsfFXHH8xiBU(C4(4IcR9w72ibtJACoPUsQC4cnwNgpP6s4Trs1nB8K)oUu3aw2APFZ4pPk)dY)5j1zbuO34aIKVf7AgXHl0ynGAcqL720BwGCXCqEbzj7D4e6zf)cmGAoGocGsqaOqVXbejFl21mIdxOXAa1eGk3TP3SajFl21m6zf)cmGAoGocGAcqHNcdO5burNdOeea6026O0Vz8dO5hauJbutak8uya1Cav05aQjaf6noGOm3aUS1IJNymIdxOX6KA4kCs1nB8K)oUu3aw2APFZ4pbtJASXPUsQC4cnwNgpP6s4Trsv8HVnkBTOzLdZjv5Fq(ppPkyRvKlMdYlilzVdNq2EaLGaqfS1ks(wSRzKThqnbOc2AfjFl21mcdDPba6aGk6CaLGaqL720BwGCXCqEbzj7D4e6zf)cmGMFaqnEoGsqaOYDB6nlqY3IDnJEwXVadO5hauJNNudxHtQIp8TrzRfnRCyobtJASitDLu5WfASonEs1LWBJKQJNe7bJlVB27xK77TKQ8pi)NNu1SGTwrVB27xK77TIMfS1ksVzbGsqaOgbOc2Af5I5G8cYs27Wj0Zk(fyan)aGMZCaLGaqfS1ks(wSRzeg6sda0bav05aQjavWwRi5BXUMrpR4xGb08aQOJaOgcOMauJau5Un9MfisR)6ZJYwlUzZ)cNqpR4xGb08aQzDoGsqaOWtHlWTOpgqnhqnEoGsqaOZcOmgZHKrYn0CGzDPDvUUVKrkE32hqnmPgUcNuD8KypyC5DZE)ICFVLGPrnEKuxjvoCHgRtJNuDj82iPAqSWYwlEipoGLQ97iPk)dY)5jvbBTICXCqEbzj7D4eY2dOeeaQGTwrY3IDnJS9aQjavWwRi5BXUMryOlnaqZpaOIohqjiau5Un9MfixmhKxqwYEhoHEwXVadO5buJNdOeea6SaQGTwrY3IDnJS9aQjavUBtVzbs(wSRz0Zk(fyanpGA88KA4kCs1GyHLTw8qECalv73rcMg1yrOuxjvoCHgRtJNuL)b5)8KQra6026O0Vz8dO5haurcOMau4PWaQ5a6iakbbGoTTok9Bg)aA(ba1ya1eGcpfgqZdOJaOeeak0BCartBRJIlMds(rC4cnwdOMau5Un9MfOPT1rXfZbj)ONv8lWa6aGohqneqnbOWtHlWTm1tcOda68KQlH3gjvxmhKxqwYEhoLGPrn2SK6kPYHl0yDA8KQ8pi)NNuncqN2whL(nJFan)aGksa1eGcpfgqnhqhbqjia0PT1rPFZ4hqZpaOgdOMau4PWaAEaDeaLGaqHEJdiAABDuCXCqYpIdxOXAa1eGk3TP3SanTTokUyoi5h9SIFbgqha05aQHaQjafEkCbULPEsaDaqNNuDj82iPkFl21CcMg1yruQRKQlH3gjvhpXrzYBTnlPYHl0yDA8emnQXM1uxjvoCHgRtJNuL)b5)8Kk8u4cClt9Ka6aGohqnbOgbOgbOc2Af5I5G8cYs27WjKThqjiaubBTIKVf7Agz7budbucca1iavWwRixmhKxqwYEhoH0BwaOMau5Un9MfixmhKxqwYEhoHEwXVadO5burohqjiaubBTIKVf7AgP3SaqnbOYDB6nlqY3IDnJEwXVadO5burohqneqnmP6s4TrsDABDuCXCqYFcMgvKZtDLu5WfASonEsv(hK)ZtQtBRJs)MXpGMFaqngqnbOgbOc2Af5I5G8cYs27Wj0Zk(fyanpGkIa0XausPgqjiau5Un9MfixmhKxqwYEhoHEwXVadOMdOKsnGsqaOYDB6nlqUyoiVGSK9oCc9SIFbgqZdOJKdGAiGAcqHNcxGBzQNeqha05aQja1iaDwaf6noGim)E)0PG4WfASgqjiaubBTIW879tNcY2dOgMuDj82iPwVWBLNLgSXfKjyAurkAQRKkhUqJ1PXtQY)G8FEsfEkmGA(aGMdGsqaOc2Af9S0GgJXL6(sgz7tQUeEBKuHtCXgcRn0L6(sobtJkYCsDLu5WfASonEsv(hK)ZtQc2Af5I5G8cYs27WjKThqjiaubBTIKVf7Agz7butaQGTwrY3IDnJWqxAaGoaOIopP6s4TrsvOTRUS1cCIlCWkDKGPrfPXPUsQC4cnwNgpPk)dY)5j1zbuO34aIKVf7AgXHl0ynGAcqncqL720BwGCXCqEbzj7D4e6zf)cmGAoGocGAcqN2whL(nJFan)aGAmGsqaOYDB6nlqUyoiVGSK9oCc9SIFbgqZpaOICea1qaLGaqncqHEJdis(wSRzehUqJ1aQjavUBtVzbs(wSRz0Zk(fya1CaLuQbuta6026O0Vz8dO5haurcOeeaQC3MEZcK8TyxZONv8lWaA(bavKJaOgMuDj82iPsA9xFEu2AXnB(x4ucMgvKIm1vsLdxOX604jv5Fq(ppPk3TP3Sa5I5G8cYs27Wj0Zk(fya1CaLuQbuta6026O0Vz8dO5hauJbuccaf6noGi5BXUMrC4cnwdOMau5Un9Mfi5BXUMrpR4xGbuZbusPgqnbOtBRJs)MXpGMFaqfjGsqaOYDB6nlqUyoiVGSK9oCc9SIFbgqZpaOICeaLGaqL720BwGKVf7Ag9SIFbgqZpaOICKKQlH3gj1S9BAX8fLNXB4HKtW0OICKuxjvoCHgRtJNuL)b5)8KQra6Sa67NUWI5aICTgJyZCyigqjia03pDHfZbe5AngDbGMhqnEoGsqaO4EU1kq)jzigPpXxWfmCFfan)aGMdGAiGAcqNfqncqfS1kYfZb5fKLS3HtiBpGsqaOc2AfjFl21mY2dOgcOMauJau5Un9MfiHMR5YwlDZIHNKrpR4xGb08akPudODhqngqnbOYDB6nlqDZQjv4aIEwXVadO5busPgq7oGAmGAys1LWBJKADLwmRlUzZ)b5Ia7kjyAurkcL6kPYHl0yDA8KQ8pi)NNuncqfS1kYfZb5fKLS3HtiBpGsqaOc2AfjFl21mY2dOMaubBTIKVf7AgHHU0aaDaqfDoGAiGAcqN2whL(nJFa18ba14KQlH3gjvfwz)okBT0SYtx0p7k4emnQinlPUsQC4cnwNgpPk)dY)5jvJa0zb03pDHfZbe5AngXM5WqmGsqaOVF6clMdiY1Am6canpGA8CaLGaqX9CRvG(tYqmsFIVGly4(kaA(banha1WKQlH3gj1E7F1oUGSi0CmmbtWembtWuca]] )


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
