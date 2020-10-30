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


    spec:RegisterPack( "Retribution", 20201030.1, [[dCKEKbqifv9iPsLAtukFIqinkkjNIs0Qie8kfvMLeyxq9lfLgMc1XiKwMuHNrj10ieDnfsBtQuX3OubJJqOohLk06iecnpjO7PG9jHoOuPQulurXdLkvfDrPsLKpkvQK6KsLkXkLkAMsLQs2PcXpLkvvnuPsvLLsie9usmvPs(QuPQWyjec2RG)k0Gr6WuTycEmrtMuxg1ML0Nr0OvKtRYQLkLxtjmBPCBsA3I(TsdxQ64sLQSCv9Cith46uSDc13LOXtPsNNsvRNsfnFe2pOdIg6kOODahgPJXDmw0XwpglQDCSDCC3jOaSVNdk9U0cNKdkPRYbfrKm4pbd42mO0723wxh6kOGwZl5GsqrWCnq3Lmieu0oGdJ0X4ogl6yRhJf1oo2oyD3jOG6zzye7W4GY0P1CgeckAgjdkD3qQisg8NGbCBcPD)8MRVe2z3nK29xcwb(HuRhxaK2X4oghu6)TEnoO0DdPIizWFcgWTjK29ZBU(syND3qA3Fjyf4hsTECbqAhJ7ymStyNUeCBIW9plxvbhm3WS(l9KJG9FobWoHuyND3qA3v2LLgaRHuwm)2dPGtLHuWedPUeSpKEii1f7xZfAmg2Plb3MOHNfmwWWoDj42en3WSsV1IUeCBgBhcuq6Q8GC3MElteStxcUnrZnmR0BTOlb3MX2HafKUkpqYj)oyFeStif2Plb3MiSC3MElt0q)cUnl4QdwjyQvSqBxDZGa4NDjGGqWuRyxmNKxsglFhmHn92em1k2fZj5LKXY3bt4Nv9lrffvetqiyQvS8nixZytVnbtTILVb5Ag)SQFjQWog1syNUeCBIWYDB6TmrZnmB7iNaOy3mAsvobfC1bup3ArG)KmaHBh5eaf7MrtQYjO4qheewn)7NoYI5eGDTgHz7EiaIG49thzXCcWUwJWxw0omQLWoDj42eHL720BzIMBy269SqBxDbxDqWuRyxmNKxsglFhmHn9eecMAflFdY1m20BtWuRy5BqUMXiGlTyq0XWoDj42eHL720BzIMByw00XnDCRrXCsYEkzyNUeCBIWYDB6TmrZnmRbXXdWQfKUkp8UDQnPfOOWrgFwhfmaWMWoDj42eHL720BzIMBywdIJhGvliDvEWrtI9KrX3TZ9JY99wbxDqZcMAf)UDUFuUV3IAwWuRy9wMeewjyQvSlMtYljJLVdMWpR6xIko0XyccbtTILVb5AgJaU0IbrhBtWuRy5BqUMXpR6xIkk6OwAZk5Un9wMysJ)6ZZ4wJUDY)cMWpR6xIkAhhtqa8NKbyWPYrWg1hxO1JjiMNrioLmwUPMteRJTRY19Lmw172(wc70LGBtewUBtVLjAUHznioEawTG0v5HUXO40w24VGRoiyQvSlMtYljJLVdMWMEccbtTILVb5AgB6TjyQvS8nixZyeWLwmi6yyNUeCBIWYDB6TmrZnmRbXXdWQfKUkpi(8wCRrppvhW6OqBxDbxDWkbtTIDXCsEjzS8DWe20tqiyQvS8nixZytVnbtTILVb5Ag)SQFjQqrfXwsqyLC3MEltSlMtYljJLVdMWpR6xIkA9ycc5Un9wMy5BqUMXpR6xIkA9ylHD6sWTjcl3TP3Yen3WSgehpaRwq6Q8GExvuSAE7l4QdcMAf7I5K8sYy57GjSPNGqWuRy5BqUMXMEBcMAflFdY1m(zv)suHIkIHD6sWTjcl3TP3Yen3WSgehpaRwq6Q8aP3yP3A8JIcSBrbxDqWuRyxmNKxsglFhmHn9eecMAflFdY1m20BtWuRy5BqUMXpR6xIku0rHD6sWTjcl3TP3Yen3WSgehpaRwq6Q8GG9KBYrbMJEt1txwWvhem1k2fZj5LKXY3btytpbHGPwXY3GCnJn9WoDj42eHL720BzIMBywdIJhGvliDvEqLF2cWKJIvpjl4Qdwn)7NoYI5eGDTgHz7EiaIG49thzXCcWUwJWxwu0rTKGa1ZTwe4pjdqy9j(soIa7RwCOdyNUeCBIWYDB6TmrZnmRbXXdWQfKUkp03mPMFb2FnkwBoYIcU6GGPwXUyojVKmw(oycB6jiem1kw(gKRzSP3MGPwXY3GCnJraxArXbrhtqi3TP3Ye7I5K8sYy57Gj8ZQ(LOIICucI5fm1kw(gKRzSP3MC3MEltS8nixZ4Nv9lrff5OWoDj42eHL720BzIMBywdIJhGvliDvEqGFe)wWpk2nt3mfC1bbtTIDXCsEjzS8DWe20tqiyQvS8nixZytVnbtTILVb5AgJaU0IIdIoMGqUBtVLj2fZj5LKXY3bt4Nv9lrff5OeeZlyQvS8nixZytVn5Un9wMy5BqUMXpR6xIkkYrHD6sWTjcl3TP3Yen3WSgehpaRwq6Q8aN6gJqrWLsG554wJ13LGBtVf73s(l4QdcMAf7I5K8sYy57GjSPNGqWuRy5BqUMXMEBcMAflFdY1mgbCPffheDmbHC3MEltSlMtYljJLVdMWpR6xIkkYrjiK720BzILVb5Ag)SQFjQOihf2Plb3MiSC3MElt0CdZAqC8aSAbPRYd9S)TO(eZpkkx1EhHk4QdcMAf7I5K8sYy57GjSPNGqWuRy5BqUMXMEBcMAflFdY1mgbCPffheDmStxcUnry5Un9wMO5gM1G44by1csxLhQ3JarvhWOiQ3EYMJqfC1bbtTIDXCsEjzS8DWe20tqiyQvS8nixZytVnbtTILVb5Ag)SQFjQWbrhf2Plb3MiSC3MElt0CdZAqC8aSAbPRYdY9FtpG1rYMRphSpkQYAV1Unl4QdcMAf7I5K8sYy57GjSPNGqWuRy5BqUMXMEBcMAflFdY1m(zv)suHDmg2Plb3MiSC3MElt0CdZAqC8aSAbPRYdY9FtpG1rYMRphSpkk4AsUGRoiyQvSlMtYljJLVdMWMEccbtTILVb5AgB6TjyQvS8nixZ4Nv9lrfk6OWoDj42eHL720BzIMBywdIJhGvliDvEO8pW0LKretQYjiU1O(zeWjDWeStxcUnry5Un9wMO5gM1G44by1csxLhqtR0cHdWpkw9KSGRoiyQvSlMtYljJLVdMWMEccbtTILVb5AgB6HD6sWTjcl3TP3Yen3WSgehpaRwq6Q8q7eFjzCVwu65Ha8d70LGBtewUBtVLjAUHznioEawTG0v5H)agVfRSdM4pU1OjtYOBrbxDqWuRyxmNKxsglFhmHn9eecMAflFdY1m20BtWuRy5BqUMXiGlTyq0XeeYDB6TmXUyojVKmw(oyc)SQFjQ4G1JjiK720BzILVb5Ag)SQFjQ4G1JHD6sWTjcl3TP3Yen3WSgehpaRwq6Q8WZQlGJKMt7PKJAw8jzyNUeCBIWYDB6TmrZnmRbXXdWQfKUkpi(8wCRreyFveStxcUnry5Un9wMO5gM1G44by1csxLhkNUVvEjjk23mQojxWvhem1k2fZj5LKXY3btytpbHGPwXY3GCnJn92em1kw(gKRz8ZQ(LOch6ymStxcUnry5Un9wMO5gM1G44by1csxLh0p76izZ1Nd2hffCnjxWvhem1k2fZj5LKXY3btytpbHGPwXY3GCnJn92em1kw(gKRz8ZQ(LOch6ymStxcUnry5Un9wMO5gM1G44by1csxLh0p76OJ6V3takQYAV1Unl4QdcMAf7I5K8sYy57GjSPNGqWuRy5BqUMXMEBcMAflFdY1m(zv)suHdDmg2Plb3MiSC3MElt0CdZAqC8aSAbPRYdK)MKOy)FQEl(ojxWvhMxWuRyxmNKxsglFhmHn92MxWuRy5BqUMXMEyNUeCBIWYDB6TmrZnmRbXXdWQfKUkpGU8qa(JKnxFoyFuuW1KCbxDqWuRyxmNKxsglFhmHn9eecMAflFdY1m20BtWuRy5BqUMXpR6xIkCq0rHD6sWTjcl3TP3Yen3WSgehpaRwq6Q8a6Ydb4ps2C95G9rrvw7T2TzbxDqWuRyxmNKxsglFhmHn9eecMAflFdY1m20BtWuRy5BqUMXpR6xIkCOJXWoDj42eHL720BzIMBywdIJhGvliDvEWTt0K)okw3ee3ASFl5VGRompWBCcWY3GCnJ50fAS2MC3MEltSlMtYljJLVdMWpR6xIkCuccG34eGLVb5AgZPl0yTn5Un9wMy5BqUMXpR6xIkCuBGtLlk6ycIPTzFSFl5V4G12aNkxOOJTb8gNaCPBbh3A0rtmcZPl0ynStxcUnry5Un9wMO5gM1G44by1csxLheFOBZ4wJAw9qCbxDqWuRyxmNKxsglFhmHn9eecMAflFdY1m20BtWuRy5BqUMXiGlTyq0XeeYDB6TmXUyojVKmw(oyc)SQFjQ4G1JjiK720BzILVb5Ag)SQFjQ4G1JHD6sWTjcl3TP3Yen3WSgehpaRwq6Q8GJMe7jJIVBN7hL77TcU6GMfm1k(D7C)OCFVf1SGPwX6TmjiSsWuRyxmNKxsglFhmHFw1VevCOJXeecMAflFdY1mgbCPfdIo2MGPwXY3GCnJFw1Vevu0rT0MvYDB6TmXKg)1NNXTgD7K)fmHFw1Vev0ooMGaCQCeSr9XfA9ycI5zeItjJLBQ5eX6y7QCDFjJv9UTVLWoDj42eHL720BzIMBywdIJhGvliDvEWICbXTg9uECcIvZBFbxDqWuRyxmNKxsglFhmHn9eecMAflFdY1m20BtWuRy5BqUMXiGlTO4GOJjiK720BzIDXCsEjzS8DWe(zv)surRhtqmVGPwXY3GCnJn92K720BzILVb5Ag)SQFjQO1JHD6sWTjcl3TP3Yen3WSUyojVKmw(oyQGRoy102Sp2VL8xCqK2aNkx4OeetBZ(y)wYFXbRTbovU4OeeaVXjapTn7JUyoj5hZPl0yTn5Un9wM4PTzF0fZjj)4Nv9lrdJT0g4u5iyJt9KdJHD6sWTjcl3TP3Yen3WSY3GCnxWvhSAAB2h73s(loisBGtLlCucIPTzFSFl5V4G12aNkxCuccG34eGN2M9rxmNK8J50fAS2MC3MElt802Sp6I5KKF8ZQ(LOHXwAdCQCeSXPEYHXWoDj42eHL720BzIMBywhnXzCYBTTe2Plb3MiSC3MElt0CdZoTn7JUyoj5VGRoaovoc24up5WyBwzLGPwXUyojVKmw(oycB6jiem1kw(gKRzSP3sccRem1k2fZj5LKXY3bty9wM2K720BzIDXCsEjzS8DWe(zv)surroMGqWuRy5BqUMX6TmTj3TP3YelFdY1m(zv)surro2slHD6sWTjcl3TP3Yen3WS1l9w8zPfBEjzbxDyAB2h73s(loyTn5Un9wMyxmNKxsglFhmHFw1VevKuQTbovoc24up5WyBwnpWBCcWi(9(PtfZPl0ynbHGPwXi(9(PtfB6Te2Plb3MiSC3MElt0CdZcM4OjfwtQJ19LCbxDaCQCHdDqqiyQv8ZslAmcfR7lzSPh2Plb3MiSC3MElt0CdZk02vh3AemXrozv7l4QdcMAf7I5K8sYy57GjSPNGqWuRy5BqUMXMEBcMAflFdY1mgbCPfdIog2Plb3MiSC3MElt0CdZsA8xFEg3A0Tt(xWubxDyEG34eGLVb5AgZPl0yTnRK720BzIDXCsEjzS8DWe(zv)suHJABAB2h73s(loynbHC3MEltSlMtYljJLVdMWpR6xIkoiYrTKGWkG34eGLVb5AgZPl0yTn5Un9wMy5BqUMXpR6xIkKuQTnTn7J9Bj)fhejbHC3MEltS8nixZ4Nv9lrfhe5Owc70LGBtewUBtVLjAUHzl3VPfZxgFgTPNsUGRoi3TP3Ye7I5K8sYy57Gj8ZQ(LOcjLABtBZ(y)wYFXbRjiaEJtaw(gKRzmNUqJ12K720BzILVb5Ag)SQFjQqsP2202Sp2VL8xCqKeeYDB6TmXUyojVKmw(oyc)SQFjQ4GihLGqUBtVLjw(gKRz8ZQ(LOIdICuyNUeCBIWYDB6TmrZnmBDLgeRJUDY)b4Oa7QfC1bRM)9thzXCcWUwJWSDpearq8(PJSyobyxRr4llA9yccup3ArG)KmaH1N4l5icSVAXHoS028wjyQvSlMtYljJLVdMWMEccbtTILVb5AgB6T0MvYDB6TmXcnxZXTg7MbbojJFw1VevKuQfbRTj3TP3Ye3nJMuLta(zv)sursPweS2syNUeCBIWYDB6TmrZnmRkRUV9XTgBg5PJ6NDvubxDWkbtTIDXCsEjzS8DWe20tqiyQvS8nixZytVnbtTILVb5AgJaU0IbrhBPTPTzFSFl5VWbRHD6sWTjcl3TP3Yen3WS9M)Q2FjzuO5iqbxDWQ5F)0rwmNaSR1imB3dbqeeVF6ilMta21Ae(YIwpMGa1ZTwe4pjdqy9j(soIa7RwCOdlHDcPWoDj42eHRxEOj(rZnmRy)pxOXfKUkpOrrPJaUqJlqS3m8aQNBTiWFsgGW6t8LCeb2xT4qheecMAfZQ92)SNX(TKFSP3MMfm1kUBgnPkNaSEltBcMAfRpXxYXEZ3VigR3YKGa1ZTwe4pjdqy9j(soIa7RwCOdBcMAflFdY1m20BtWuRy5BqUMXiGlTOqrhd70LGBteUE5HM4hn3WSi(9(PtTGRoyLvZd8gNaS8nixZyoDHgRTjyQvSlMtYljJLVdMWMEcc5Un9wMyxmNKxsglFhmHFw1VevSJrTKGWkbtTILVb5AgB6jiK720BzILVb5Ag)SQFjQyhJAPL2SAEG34eGRx6T4Zsl28ssmNUqJ1eeYDB6TmX1l9w8zPfBEjj(zv)suHIoMGqUBtVLjUEP3IplTyZljXpR6xIkA9OwAZQ5bEJtaMTllnGBZiItaNsgZPl0ynbHC3MEltmBxwAa3MreNaoLm(zv)suHIo2sBGtLJGno1tomg2Plb3MiC9YdnXpAUHzf7z3ZCOj(rXjxvL)cU6GvZd8gNaC9sVfFwAXMxsI50fASMGqUBtVLjUEP3IplTyZljXpR6xIksk1IGOJji0SGPwX1l9w8zPfBEjj20BPnRMh4noby2US0aUnJiobCkzmNUqJ1eeYDB6TmXSDzPbCBgrCc4uY4Nv9lrfjLArq0XeeAwWuRy2US0aUnJiobCkzSP3sccup3ArG)KmaH1N4l5icSVAXHoGD6sWTjcxV8qt8JMByw2US0aUnJiobCk5cU6aQNBTiWFsgGW6t8LCeb2xTWbRTzLvZd8gNaS8nixZyoDHgRjiem1kw(gKRzSEltBYDB6TmXY3GCnJFw1Vevu0XwsqiyQvS8nixZyeWLwuCWAcc5Un9wMyxmNKxsglFhmHFw1Vevu0XeeAwWuR46LEl(S0InVKeB6T0g4u5iyJt9KdJHD6sWTjcxV8qt8JMByw9j(soIa7RwWvhe7)5cngRrrPJaUqJTnVGPwXI9S7zo0e)O4KRQYp20BZkRMh4noby5BqUMXC6cnwtqi3TP3YelFdY1m(zv)sursPweS2sBwnpWBCcWSDzPbCBgrCc4uYyoDHgRjiK720BzIz7Ysd42mI4eWPKXpR6xIksk1IG1eeOEU1Ia)jzacRpXxYreyF1IdwBjbbQNBTiWFsgGW6t8LCeb2xT4qh2Sc4nob4PTzF0fZjj)yoDHgRTj3TP3YepTn7JUyoj5h)SQFjQqsPweSMGqWuRy5BqUMXMEBcMAflFdY1mgbCPffk6ylTe2Plb3MiC9YdnXpAUHzbSAFZFuum)6tck4QdwnpWBCcWY3GCnJ50fASMGqUBtVLjw(gKRz8ZQ(LOIKsTiyTL2SAEG34eGz7Ysd42mI4eWPKXC6cnwtqi3TP3YeZ2LLgWTzeXjGtjJFw1VevKuQfbRTH65wlc8NKbiS(eFjhrG9vlCWAlTz18aVXjaxV0BXNLwS5LKyoDHgRjiK720BzIRx6T4Zsl28ss8ZQ(LOIKsTiyTL2SAE5kMtpb4KL)22xJ50fASMGqUBtVLjwSNDpZHM4hfNCvv(XpR6xIksk1wsqa8gNa802Sp6I5KKFmNUqJ12K720BzIN2M9rxmNK8JFw1VeviPulcwtqiyQv802Sp6I5KKFSPNGqWuRy5BqUMXMEBcMAflFdY1mgbCPffk6yccbtTIf7z3ZCOj(rXjxvLFSPh2jKc70LGBteMKt(DW(O5gMv6Tw0LGBZy7qGcsxLhQxEOj(rfC1HPTzFSFl5V4WOeecMAfpTn7JUyoj5hB6ji0SGPwX1l9w8zPfBEjj20tqOzbtTIz7Ysd42mI4eWPKXMEyNUeCBIWKCYVd2hn3WScngHUKmU1iYOQYpStxcUnryso53b7JMBywHgJqxsg3A0naJAc70LGBteMKt(DW(O5gMvOXi0LKXTglVeWpStxcUnryso53b7JMBywHgJqxsg3Ae1)xsc70LGBteMKt(DW(O5gMvFIVKJGT1k4QdZRzbtTI7MrtQYjaB6Tz18VF6ilMta21AeMT7HaicI3pDKfZja7AncFzrRhBPnRM2M9X(TK)ch6GGyAB2h73s(lCqK2SsUBtVLjwO5AoU1y3miWjz8ZQ(LOIKsTi0bbHMfm1kMTllnGBZiItaNsgB6ji0SGPwX1l9w8zPfBEjj20BPL2SAEG34eGRx6T4Zsl28ssmNUqJ1eeYDB6TmX1l9w8zPfBEjj(zv)sursPweeDSL2SAEG34eGz7Ysd42mI4eWPKXC6cnwtqi3TP3YeZ2LLgWTzeXjGtjJFw1VevKuQfbrhBjStxcUnryso53b7JMBy2s3coU1OJMyubxDWQPTzFSFl5FymbX02Sp2VL8x4qh2SsUBtVLjwO5AoU1y3miWjz8ZQ(LOIKsTi0bbHMfm1kMTllnGBZiItaNsgB6ji0SGPwX1l9w8zPfBEjj20BPL2SA(3pDKfZja7AncZ29qaebX7NoYI5eGDTgHVSyhJT0MvZd8gNamBxwAa3MreNaoLmMtxOXAcc5Un9wMy2US0aUnJiobCkz8ZQ(LOIIoQL2SAEG34eGRx6T4Zsl28ssmNUqJ1eeYDB6TmX1l9w8zPfBEjj(zv)surrh1syNUeCBIWKCYVd2hn3WScnxZXTg7MbbojxWvhM2M9X(TK)chSg2Plb3MimjN87G9rZnm7KRQYFCRXY3btfC1HPTzFSFl5VWbrc70LGBteMKt(DW(O5gMTBgnPkNGcU6W8AwWuR4Uz0KQCcWMEBwnTn7J9Bj)fo0bbX02Sp2VL8x4GiTj3TP3Yel0Cnh3ASBge4Km(zv)sursPwe6WsyNUeCBIWKCYVd2hn3WSsV1IUeCBgBhcuq6Q8q9YdnXpQGRoyfWFsgGNyVbMW9sqHdDmMGqWuRyxmNKxsglFhmHn9eecMAflFdY1m20tqiyQvmR2B)ZEg73s(XMElHD6sWTjctYj)oyF0CdZkFdY18hrG)SGl4QdYDB6TmXY3GCn)re4plySCYFsgfRVlb3MER4GOy7WO2SAAB2h73s(lCOdcIPTzFSFl5VWbRTj3TP3Yel0Cnh3ASBge4Km(zv)sursPwe6GGyAB2h73s(hePn5Un9wMyHMR54wJDZGaNKXpR6xIksk1Iqh2K720BzI7MrtQYja)SQFjQiPulcDyjStxcUnryso53b7JMBywP3ArxcUnJTdbkiDvEOE5HM4hb70LGBteMKt(DW(O5gMv(gKR5pIa)zbxWvhM2M9X(TK)chejStxcUnryso53b7JMByw5MsobVdyDS2Cvg2Plb3MimjN87G9rZnm7ZE)LKXAZvzubxDa4pjdWtS3atXEjOOiEmbbWFsgGNyVbMI9sqHDmMGOEKtG4ZQ(LOcTEuyNUeCBIWKCYVd2hn3WS(l9KJG9FobfC1HPTzFSFl5VWbrc70LGBteMKt(DW(O5gMvUjILVdUnl4QdGtLJGno1twKuQdkI5hDBggPJXDmw0XwpoOu6FEjjkO09r33IihP7YiDxlIiKcPDnXq6P2VpasR7dPIO1lp0e)irui95UN5EwdPOvLHu3awvhWAivo5jjJWWo7(6sgs7oIicPDFUPy(bSgsfrLRyo9eGfraZPl0yTikKcwivevUI50tawebrui1krTRLyyNWo7AIHurudIJhGvrIOqQlb3MqAPJG0CbqADnPgsVesbthcsp1(9byyNDxu73hWAiDui1LGBtiTDiacd7mO4gW0(bfLUNHBoy)Gs7qauORGIMRUPbcDfgr0qxbfxcUndkplySGdkC6cnwhMjacJ0rORGcNUqJ1HzckUeCBguKERfDj42m2oeiO0oeiMUkhuK720BzIcGWiwh6kOWPl0yDyMGIlb3MbfP3ArxcUnJTdbckTdbIPRYbfso53b7JcGaiO0)SCvfCqORWiIg6kO4sWTzqXFPNCeS)ZjiOWPl0yDyMaiackKCYVd2hf6kmIOHUckC6cnwhMjOi)dW)5bLPTzFSFl5hsloaPJcPeeqQGPwXtBZ(OlMts(XMEiLGas1SGPwX1l9w8zPfBEjj20dPeeqQMfm1kMTllnGBZiItaNsgB6dkUeCBguKERfDj42m2oeiO0oeiMUkhuQxEOj(rbqyKocDfuCj42mOi0ye6sY4wJiJQk)bfoDHgRdZeaHrSo0vqXLGBZGIqJrOljJBn6gGrndkC6cnwhMjacJiYqxbfxcUndkcngHUKmU1y5La(dkC6cnwhMjacJmAORGIlb3MbfHgJqxsg3Ae1)xsgu40fASomtaegP7e6kOWPl0yDyMGI8pa)NhuMhs1SGPwXDZOjv5eGn9qQni1kiDEi99thzXCcWUwJWSDpeabPeeq67NoYI5eGDTgHVeslcPwpgsTesTbPwbPtBZ(y)wYpKw4aK2bKsqaPtBZ(y)wYpKw4aKksi1gKAfKk3TP3Yel0Cnh3ASBge4Km(zv)seKwesjLAiveG0oGuccivZcMAfZ2LLgWTzeXjGtjJn9qkbbKQzbtTIRx6T4Zsl28ssSPhsTesTesTbPwbPZdPaVXjaxV0BXNLwS5LKyoDHgRHuccivUBtVLjUEP3IplTyZljXpR6xIG0IqkPudPIaKk6yi1si1gKAfKopKc8gNamBxwAa3MreNaoLmMtxOXAiLGasL720BzIz7Ysd42mI4eWPKXpR6xIG0IqkPudPIaKk6yi1YGIlb3Mbf9j(soc2wlacJyhcDfu40fASomtqr(hG)ZdkwbPtBZ(y)wYpKoaPJHucciDAB2h73s(H0chG0oGuBqQvqQC3MEltSqZ1CCRXUzqGtY4Nv9lrqAriLuQHuras7asjiGunlyQvmBxwAa3MreNaoLm20dPeeqQMfm1kUEP3IplTyZljXMEi1si1si1gKAfKopK((PJSyobyxRry2UhcGGucci99thzXCcWUwJWxcPfH0ogdPwcP2GuRG05HuG34eGz7Ysd42mI4eWPKXC6cnwdPeeqQC3MEltmBxwAa3MreNaoLm(zv)seKwesfDui1si1gKAfKopKc8gNaC9sVfFwAXMxsI50fASgsjiGu5Un9wM46LEl(S0InVKe)SQFjcslcPIokKAzqXLGBZGsPBbh3A0rtmkacJiIdDfu40fASomtqr(hG)ZdktBZ(y)wYpKw4aKADqXLGBZGIqZ1CCRXUzqGtYbqye7yORGcNUqJ1HzckY)a8FEqzAB2h73s(H0chGurguCj42mOm5QQ8h3AS8DWuaegr0XHUckC6cnwhMjOi)dW)5bL5HunlyQvC3mAsvobytpKAdsTcsN2M9X(TKFiTWbiTdiLGasN2M9X(TKFiTWbivKqQnivUBtVLjwO5AoU1y3miWjz8ZQ(LiiTiKsk1qQiaPDaPwguCj42mO0nJMuLtqaegrurdDfu40fASomtqr(hG)ZdkwbPa)jzaEI9gyc3lbqAHdqAhJHuccivWuRyxmNKxsglFhmHn9qkbbKkyQvS8nixZytpKsqaPcMAfZQ92)SNX(TKFSPhsTmO4sWTzqr6Tw0LGBZy7qGGs7qGy6QCqPE5HM4hfaHreTJqxbfoDHgRdZeuK)b4)8GIC3MEltS8nixZFeb(ZcglN8NKrX67sWTP3G0IdqQOy7WOqQni1kiDAB2h73s(H0chG0oGucciDAB2h73s(H0chGuRHuBqQC3MEltSqZ1CCRXUzqGtY4Nv9lrqAriLuQHuras7asjiG0PTzFSFl5hshGurcP2Gu5Un9wMyHMR54wJDZGaNKXpR6xIG0IqkPudPIaK2bKAdsL720BzI7MrtQYja)SQFjcslcPKsnKkcqAhqQLbfxcUndkY3GCn)re4pl4aimIOwh6kOWPl0yDyMGIlb3MbfP3ArxcUnJTdbckTdbIPRYbL6LhAIFuaegrurg6kOWPl0yDyMGI8pa)NhuM2M9X(TKFiTWbivKbfxcUndkY3GCn)re4pl4aimIOJg6kO4sWTzqrUPKtW7awhRnxLdkC6cnwhMjacJiA3j0vqHtxOX6Wmbf5Fa(ppOa8NKb4j2BGPyVeaPfHur8yiLGasb(tYa8e7nWuSxcG0cH0ogdPeeqA9iNaXNv9lrqAHqQ1JguCj42mO8S3FjzS2CvgfaHre1oe6kOWPl0yDyMGI8pa)NhuM2M9X(TKFiTWbivKbfxcUndk(l9KJG9FobbqyerfXHUckC6cnwhMjOi)dW)5bfWPYrWgN6jH0IqkPuhuCj42mOi3eXY3b3MbqaeuQxEOj(rHUcJiAORGcNUqJ1HzckBFqbXGGIlb3MbfX(FUqJdkI9MHdkOEU1Ia)jzacRpXxYreyFviT4aK2bKsqaPcMAfZQ92)SNX(TKFSPhsTbPAwWuR4Uz0KQCcW6TmHuBqQGPwX6t8LCS389lIX6TmHuccif1ZTwe4pjdqy9j(soIa7RcPfhG0oGuBqQGPwXY3GCnJn9qQnivWuRy5BqUMXiGlTaslesfDCqrS)X0v5GIgfLoc4cnoacJ0rORGcNUqJ1HzckY)a8FEqXki1kiDEif4noby5BqUMXC6cnwdP2GubtTIDXCsEjzS8DWe20dPeeqQC3MEltSlMtYljJLVdMWpR6xIG0IqAhJcPwcPeeqQvqQGPwXY3GCnJn9qkbbKk3TP3YelFdY1m(zv)seKwes7yui1si1si1gKAfKopKc8gNaC9sVfFwAXMxsI50fASgsjiGu5Un9wM46LEl(S0InVKe)SQFjcslesfDmKsqaPYDB6TmX1l9w8zPfBEjj(zv)seKwesTEui1si1gKAfKopKc8gNamBxwAa3MreNaoLmMtxOXAiLGasL720BzIz7Ysd42mI4eWPKXpR6xIG0cHurhdPwcP2GuWPYrWgN6jH0biDCqXLGBZGcIFVF6udGWiwh6kOWPl0yDyMGI8pa)NhuScsNhsbEJtaUEP3IplTyZljXC6cnwdPeeqQC3MEltC9sVfFwAXMxsIFw1VebPfHusPgsfbiv0XqkbbKQzbtTIRx6T4Zsl28ssSPhsTesTbPwbPZdPaVXjaZ2LLgWTzeXjGtjJ50fASgsjiGu5Un9wMy2US0aUnJiobCkz8ZQ(LiiTiKsk1qQiaPIogsjiGunlyQvmBxwAa3MreNaoLm20dPwcPeeqkQNBTiWFsgGW6t8LCeb2xfsloaPDeuCj42mOi2ZUN5qt8JItUQk)bqyerg6kOWPl0yDyMGI8pa)Nhuq9CRfb(tYaewFIVKJiW(QqAHdqQ1qQni1ki1kiDEif4noby5BqUMXC6cnwdPeeqQGPwXY3GCnJ1BzcP2Gu5Un9wMy5BqUMXpR6xIG0IqQOJHulHuccivWuRy5BqUMXiGlTasloaPwdPeeqQC3MEltSlMtYljJLVdMWpR6xIG0IqQOJHuccivZcMAfxV0BXNLwS5LKytpKAjKAdsbNkhbBCQNeshG0XbfxcUndkSDzPbCBgrCc4uYbqyKrdDfu40fASomtqr(hG)ZdkI9)CHgJ1OO0raxOXqQniDEivWuRyXE29mhAIFuCYvv5hB6HuBqQvqQvq68qkWBCcWY3GCnJ50fASgsjiGu5Un9wMy5BqUMXpR6xIG0IqkPudPIaKAnKAjKAdsTcsNhsbEJtaMTllnGBZiItaNsgZPl0ynKsqaPYDB6TmXSDzPbCBgrCc4uY4Nv9lrqAriLuQHurasTgsjiGuup3ArG)KmaH1N4l5icSVkKwCasTgsTesjiGuup3ArG)KmaH1N4l5icSVkKwCas7asTbPwbPaVXjapTn7JUyoj5hZPl0ynKAdsL720BzIN2M9rxmNK8JFw1VebPfcPKsnKkcqQ1qkbbKkyQvS8nixZytpKAdsfm1kw(gKRzmc4slG0cHurhdPwcPwguCj42mOOpXxYreyF1aims3j0vqHtxOX6Wmbf5Fa(ppOyfKopKc8gNaS8nixZyoDHgRHuccivUBtVLjw(gKRz8ZQ(LiiTiKsk1qQiaPwdPwcP2GuRG05HuG34eGz7Ysd42mI4eWPKXC6cnwdPeeqQC3MEltmBxwAa3MreNaoLm(zv)seKwesjLAiveGuRHuBqkQNBTiWFsgGW6t8LCeb2xfslCasTgsTesTbPwbPZdPaVXjaxV0BXNLwS5LKyoDHgRHuccivUBtVLjUEP3IplTyZljXpR6xIG0IqkPudPIaKAnKAjKAdsTcsNhsLRyo9eGtw(BBFnKsqaPYDB6TmXI9S7zo0e)O4KRQYp(zv)seKwesjLAi1siLGasbEJtaEAB2hDXCsYpMtxOXAi1gKk3TP3YepTn7JUyoj5h)SQFjcslesjLAiveGuRHuccivWuR4PTzF0fZjj)ytpKsqaPcMAflFdY1m20dP2GubtTILVb5AgJaU0ciTqiv0XqkbbKkyQvSyp7EMdnXpko5QQ8Jn9bfxcUndkawTV5pkkMF9jbbqaeuK720BzIcDfgr0qxbfoDHgRdZeuK)b4)8GIvqQGPwXcTD1ndcGF2LaiLGasfm1k2fZj5LKXY3btytpKAdsfm1k2fZj5LKXY3bt4Nv9lrqArivurmKsqaPcMAflFdY1m20dP2GubtTILVb5Ag)SQFjcsles7yui1YGIlb3MbL(fCBgaHr6i0vqHtxOX6Wmbf5Fa(ppOG65wlc8NKbiC7iNaOy3mAsvobqAXbiTdiLGasTcsNhsF)0rwmNaSR1imB3dbqqkbbK((PJSyobyxRr4lH0IqQDyui1YGIlb3MbL2robqXUz0KQCccGWiwh6kOWPl0yDyMGI8pa)Nhuem1k2fZj5LKXY3btytpKsqaPcMAflFdY1m20dP2GubtTILVb5AgJaU0ciDasfDCqXLGBZGs9EwOTRoacJiYqxbfxcUndkOPJB64wJI5KK9uYbfoDHgRdZeaHrgn0vqHtxOX6WmbL0v5GY72P2KwGIchz8zDuWaaBguCj42mO8UDQnPfOOWrgFwhfmaWMbqyKUtORGcNUqJ1HzckUeCBguC0Kypzu8D7C)OCFVfuK)b4)8GIMfm1k(D7C)OCFVf1SGPwX6TmHucci1kivWuRyxmNKxsglFhmHFw1VebPfhG0ogdPeeqQGPwXY3GCnJraxAbKoaPIogsTbPcMAflFdY1m(zv)seKwesfDui1si1gKAfKk3TP3YetA8xFEg3A0Tt(xWe(zv)seKwesTJJHuccif4pjdWGtLJGnQpgslesTEmKsqaPZdPmcXPKXYn1CIyDSDvUUVKXQE32hsTmOKUkhuC0Kypzu8D7C)OCFVfaHrSdHUckC6cnwhMjO4sWTzqPBmkoTLn(dkY)a8FEqrWuRyxmNKxsglFhmHn9qkbbKkyQvS8nixZytpKAdsfm1kw(gKRzmc4slG0biv0XbL0v5Gs3yuCAlB8haHreXHUckC6cnwhMjO4sWTzqr85T4wJEEQoG1rH2U6GI8pa)NhuScsfm1k2fZj5LKXY3btytpKsqaPcMAflFdY1m20dP2GubtTILVb5Ag)SQFjcslesfvedPwcPeeqQvqQC3MEltSlMtYljJLVdMWpR6xIG0IqQ1JHuccivUBtVLjw(gKRz8ZQ(LiiTiKA9yi1YGs6QCqr85T4wJEEQoG1rH2U6aimIDm0vqHtxOX6WmbfxcUndk6DvrXQ5TpOi)dW)5bfbtTIDXCsEjzS8DWe20dPeeqQGPwXY3GCnJn9qQnivWuRy5BqUMXpR6xIG0cHurfXbL0v5GIExvuSAE7dGWiIoo0vqHtxOX6WmbfxcUndkKEJLERXpkkWUfbf5Fa(ppOiyQvSlMtYljJLVdMWMEiLGasfm1kw(gKRzSPhsTbPcMAflFdY1m(zv)seKwiKk6ObL0v5GcP3yP3A8JIcSBraegrurdDfu40fASomtqXLGBZGIG9KBYrbMJEt1txguK)b4)8GIGPwXUyojVKmw(oycB6HuccivWuRy5BqUMXM(Gs6QCqrWEYn5OaZrVP6PldGWiI2rORGcNUqJ1HzckUeCBguu5NTam5Oy1tYGI8pa)NhuScsNhsF)0rwmNaSR1imB3dbqqkbbK((PJSyobyxRr4lH0IqQOJcPwcPeeqkQNBTiWFsgGW6t8LCeb2xfsloaPDeusxLdkQ8ZwaMCuS6jzaegruRdDfu40fASomtqXLGBZGsFZKA(fy)1OyT5ilckY)a8FEqrWuRyxmNKxsglFhmHn9qkbbKkyQvS8nixZytpKAdsfm1kw(gKRzmc4slG0IdqQOJHuccivUBtVLj2fZj5LKXY3bt4Nv9lrqArivKJcPeeq68qQGPwXY3GCnJn9qQnivUBtVLjw(gKRz8ZQ(LiiTiKkYrdkPRYbL(Mj18lW(RrXAZrweaHrevKHUckC6cnwhMjO4sWTzqrGFe)wWpk2nt3mbf5Fa(ppOiyQvSlMtYljJLVdMWMEiLGasfm1kw(gKRzSPhsTbPcMAflFdY1mgbCPfqAXbiv0XqkbbKk3TP3Ye7I5K8sYy57Gj8ZQ(LiiTiKkYrHucciDEivWuRy5BqUMXMEi1gKk3TP3YelFdY1m(zv)seKwesf5ObL0v5GIa)i(TGFuSBMUzcGWiIoAORGcNUqJ1HzckUeCBgu4u3yekcUucmph3AS(UeCB6Ty)wYFqr(hG)ZdkcMAf7I5K8sYy57GjSPhsjiGubtTILVb5AgB6HuBqQGPwXY3GCnJraxAbKwCasfDmKsqaPYDB6TmXUyojVKmw(oyc)SQFjcslcPICuiLGasL720BzILVb5Ag)SQFjcslcPIC0Gs6QCqHtDJrOi4sjW8CCRX67sWTP3I9Bj)bqyer7oHUckC6cnwhMjO4sWTzqPN9Vf1Ny(rr5Q27iuqr(hG)ZdkcMAf7I5K8sYy57GjSPhsjiGubtTILVb5AgB6HuBqQGPwXY3GCnJraxAbKwCasfDCqjDvoO0Z(3I6tm)OOCv7DekacJiQDi0vqHtxOX6WmbfxcUndk17rGOQdyue1BpzZrOGI8pa)Nhuem1k2fZj5LKXY3btytpKsqaPcMAflFdY1m20dP2GubtTILVb5Ag)SQFjcslCasfD0Gs6QCqPEpcevDaJIOE7jBocfaHreveh6kOWPl0yDyMGIlb3Mbf5(VPhW6izZ1Nd2hfvzT3A3Mbf5Fa(ppOiyQvSlMtYljJLVdMWMEiLGasfm1kw(gKRzSPhsTbPcMAflFdY1m(zv)seKwiK2X4Gs6QCqrU)B6bSos2C95G9rrvw7T2Tzaegru7yORGcNUqJ1HzckUeCBguK7)MEaRJKnxFoyFuuW1KCqr(hG)ZdkcMAf7I5K8sYy57GjSPhsjiGubtTILVb5AgB6HuBqQGPwXY3GCnJFw1VebPfcPIoAqjDvoOi3)n9awhjBU(CW(OOGRj5aimshJdDfu40fASomtqjDvoOu(hy6sYiIjv5ee3Au)mc4KoykO4sWTzqP8pW0LKretQYjiU1O(zeWjDWuaegPdrdDfu40fASomtqXLGBZGcAALwiCa(rXQNKbf5Fa(ppOiyQvSlMtYljJLVdMWMEiLGasfm1kw(gKRzSPpOKUkhuqtR0cHdWpkw9KmacJ0rhHUckC6cnwhMjOKUkhuAN4ljJ71IsppeG)GIlb3MbL2j(sY4ETO0Zdb4pacJ0H1HUckC6cnwhMjO4sWTzq5pGXBXk7Gj(JBnAYKm6weuK)b4)8GIGPwXUyojVKmw(oycB6HuccivWuRy5BqUMXMEi1gKkyQvS8nixZyeWLwaPdqQOJHuccivUBtVLj2fZj5LKXY3bt4Nv9lrqAXbi16XqkbbKk3TP3YelFdY1m(zv)seKwCasTECqjDvoO8hW4TyLDWe)XTgnzsgDlcGWiDiYqxbfoDHgRdZeusxLdkpRUaosAoTNsoQzXNKdkUeCBguEwDbCK0CApLCuZIpjhaHr6y0qxbfoDHgRdZeusxLdkIpVf3Aeb2xffuCj42mOi(8wCRreyFvuaegPJUtORGcNUqJ1HzckUeCBgukNUVvEjjk23mQojhuK)b4)8GIGPwXUyojVKmw(oycB6HuccivWuRy5BqUMXMEi1gKkyQvS8nixZ4Nv9lrqAHdqAhJdkPRYbLYP7BLxsII9nJQtYbqyKoSdHUckC6cnwhMjO4sWTzqr)SRJKnxFoyFuuW1KCqr(hG)ZdkcMAf7I5K8sYy57GjSPhsjiGubtTILVb5AgB6HuBqQGPwXY3GCnJFw1VebPfoaPDmoOKUkhu0p76izZ1Nd2hffCnjhaHr6qeh6kOWPl0yDyMGIlb3Mbf9ZUo6O(79eGIQS2BTBZGI8pa)Nhuem1k2fZj5LKXY3btytpKsqaPcMAflFdY1m20dP2GubtTILVb5Ag)SQFjcslCas7yCqjDvoOOF21rh1FVNauuL1ERDBgaHr6Wog6kOWPl0yDyMGIlb3MbfYFtsuS)pvVfFNKdkY)a8FEqzEivWuRyxmNKxsglFhmHn9qQniDEivWuRy5BqUMXM(Gs6QCqH83Kef7)t1BX3j5aimI1JdDfu40fASomtqXLGBZGc6Ydb4ps2C95G9rrbxtYbf5Fa(ppOiyQvSlMtYljJLVdMWMEiLGasfm1kw(gKRzSPhsTbPcMAflFdY1m(zv)seKw4aKk6ObL0v5Gc6Ydb4ps2C95G9rrbxtYbqyeRfn0vqHtxOX6WmbfxcUndkOlpeG)izZ1Nd2hfvzT3A3Mbf5Fa(ppOiyQvSlMtYljJLVdMWMEiLGasfm1kw(gKRzSPhsTbPcMAflFdY1m(zv)seKw4aK2X4Gs6QCqbD5Ha8hjBU(CW(OOkR9w72macJyDhHUckC6cnwhMjO4sWTzqXTt0K)okw3ee3ASFl5pOi)dW)5bL5HuG34eGLVb5AgZPl0ynKAdsL720BzIDXCsEjzS8DWe(zv)seKwiKokKsqaPaVXjalFdY1mMtxOXAi1gKk3TP3YelFdY1m(zv)seKwiKokKAdsbNkdPfHurhdPeeq602Sp2VL8dPfhGuRHuBqk4uziTqiv0XqQnif4nob4s3coU1OJMyeMtxOX6Gs6QCqXTt0K)okw3ee3ASFl5pacJyT1HUckC6cnwhMjO4sWTzqr8HUnJBnQz1dXbf5Fa(ppOiyQvSlMtYljJLVdMWMEiLGasfm1kw(gKRzSPhsTbPcMAflFdY1mgbCPfq6aKk6yiLGasL720BzIDXCsEjzS8DWe(zv)seKwCasTEmKsqaPYDB6TmXY3GCnJFw1VebPfhGuRhhusxLdkIp0TzCRrnREioacJyTidDfu40fASomtqXLGBZGIJMe7jJIVBN7hL77TGI8pa)Nhu0SGPwXVBN7hL77TOMfm1kwVLjKsqaPwbPcMAf7I5K8sYy57Gj8ZQ(LiiT4aK2XyiLGasfm1kw(gKRzmc4slG0biv0XqQnivWuRy5BqUMXpR6xIG0IqQOJcPwcP2GuRGu5Un9wMysJ)6ZZ4wJUDY)cMWpR6xIG0IqQDCmKsqaPGtLJGnQpgslesTEmKsqaPZdPmcXPKXYn1CIyDSDvUUVKXQE32hsTmOKUkhuC0Kypzu8D7C)OCFVfaHrSE0qxbfoDHgRdZeuCj42mOyrUG4wJEkpobXQ5TpOi)dW)5bfbtTIDXCsEjzS8DWe20dPeeqQGPwXY3GCnJn9qQnivWuRy5BqUMXiGlTasloaPIogsjiGu5Un9wMyxmNKxsglFhmHFw1VebPfHuRhdPeeq68qQGPwXY3GCnJn9qQnivUBtVLjw(gKRz8ZQ(LiiTiKA94Gs6QCqXICbXTg9uECcIvZBFaegX6UtORGcNUqJ1HzckY)a8FEqXkiDAB2h73s(H0IdqQiHuBqk4uziTqiDuiLGasN2M9X(TKFiT4aKAnKAdsbNkdPfH0rHuccif4nob4PTzF0fZjj)yoDHgRHuBqQC3MElt802Sp6I5KKF8ZQ(LiiDashdPwcP2GuWPYrWgN6jH0biDCqXLGBZGIlMtYljJLVdMcGWiwBhcDfu40fASomtqr(hG)ZdkwbPtBZ(y)wYpKwCasfjKAdsbNkdPfcPJcPeeq602Sp2VL8dPfhGuRHuBqk4uziTiKokKsqaPaVXjapTn7JUyoj5hZPl0ynKAdsL720BzIN2M9rxmNK8JFw1VebPdq6yi1si1gKcovoc24upjKoaPJdkUeCBguKVb5AoacJyTio0vqXLGBZGIJM4mo5T2wgu40fASomtaegXA7yORGcNUqJ1HzckY)a8FEqbCQCeSXPEsiDashdP2GuRGuRGubtTIDXCsEjzS8DWe20dPeeqQGPwXY3GCnJn9qQLqkbbKAfKkyQvSlMtYljJLVdMW6TmHuBqQC3MEltSlMtYljJLVdMWpR6xIG0IqQihdPeeqQGPwXY3GCnJ1BzcP2Gu5Un9wMy5BqUMXpR6xIG0IqQihdPwcPwguCj42mOmTn7JUyoj5pacJiYXHUckC6cnwhMjOi)dW)5bLPTzFSFl5hsloaPwdP2Gu5Un9wMyxmNKxsglFhmHFw1VebPfHusPgsTbPGtLJGno1tcPdq6yi1gKAfKopKc8gNamIFVF6uXC6cnwdPeeqQGPwXi(9(PtfB6HuldkUeCBguQx6T4Zsl28sYaimIifn0vqHtxOX6Wmbf5Fa(ppOaovgslCas7asjiGubtTIFwArJrOyDFjJn9bfxcUndkGjoAsH1K6yDFjhaHrezhHUckC6cnwhMjOi)dW)5bfbtTIDXCsEjzS8DWe20dPeeqQGPwXY3GCnJn9qQnivWuRy5BqUMXiGlTashGurhhuCj42mOi02vh3AemXrozv7dGWiI06qxbfoDHgRdZeuK)b4)8GY8qkWBCcWY3GCnJ50fASgsTbPwbPYDB6TmXUyojVKmw(oyc)SQFjcsleshfsTbPtBZ(y)wYpKwCasTgsjiGu5Un9wMyxmNKxsglFhmHFw1VebPfhGurokKAjKsqaPwbPaVXjalFdY1mMtxOXAi1gKk3TP3YelFdY1m(zv)seKwiKsk1qQniDAB2h73s(H0IdqQiHuccivUBtVLjw(gKRz8ZQ(LiiT4aKkYrHuldkUeCBguin(RppJBn62j)lykacJisrg6kOWPl0yDyMGI8pa)NhuK720BzIDXCsEjzS8DWe(zv)seKwiKsk1qQniDAB2h73s(H0IdqQ1qkbbKc8gNaS8nixZyoDHgRHuBqQC3MEltS8nixZ4Nv9lrqAHqkPudP2G0PTzFSFl5hsloaPIesjiGu5Un9wMyxmNKxsglFhmHFw1VebPfhGurokKsqaPYDB6TmXY3GCnJFw1VebPfhGuroAqXLGBZGs5(nTy(Y4ZOn9uYbqyeroAORGcNUqJ1HzckY)a8FEqXkiDEi99thzXCcWUwJWSDpeabPeeq67NoYI5eGDTgHVeslcPwpgsjiGuup3ArG)KmaH1N4l5icSVkKwCas7asTesTbPZdPwbPcMAf7I5K8sYy57GjSPhsjiGubtTILVb5AgB6HulHuBqQvqQC3MEltSqZ1CCRXUzqGtY4Nv9lrqAriLuQHurasTgsTbPYDB6TmXDZOjv5eGFw1VebPfHusPgsfbi1Ai1YGIlb3MbL6kniwhD7K)dWrb2vdGWiIS7e6kOWPl0yDyMGI8pa)NhuScsfm1k2fZj5LKXY3btytpKsqaPcMAflFdY1m20dP2GubtTILVb5AgJaU0ciDasfDmKAjKAdsN2M9X(TKFiTWbi16GIlb3MbfvwDF7JBn2mYth1p7QOaimIiTdHUckC6cnwhMjOi)dW)5bfRG05H03pDKfZja7AncZ29qaeKsqaPVF6ilMta21Ae(siTiKA9yiLGasr9CRfb(tYaewFIVKJiW(QqAXbiTdi1YGIlb3MbLEZFv7VKmk0CeiacGaiacGqa]] )


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
