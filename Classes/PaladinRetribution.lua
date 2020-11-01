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


    spec:RegisterPack( "Retribution", 20201101, [[dyeWKbqifv9icaztukFIaeJIsYPOeTkfIELcvZIsQDb1VuuzykkhJaTmPcpJsvtJa6AkK2MePQVjrQmocqDocGSocGQMNeX9uW(KOoibqrluHYdjau5IeaQ6Jeafojbi1kLkAMeak2PuPgkbqPLsasEkjnvPs(kbGsJLaOYEf8xHgmshMQftOht0Kj1LrTzj9zenAf50QSAfcVMsy2s52Ky3I(TsdxQ64eaSCv9Cith01Py7e03LW4Li58uQSEjsz(iSFGdcg6kOQDih6UJzDmtqbNjiwqbNv6fO9bvOD9CqT3Lw4KCqnDfoOkGIH)jAG3Mb1E3U266qxbv0AEjhudQIMRbfqNbXGQ2HCO7oM1XmbfCMGybfCwPxG2hur9Sm0DPBwqD60AodIbvnJKbvbqaQakg(NObEBcOcW6nxFjOtbqaA3RqwrKFavqRb0oM1XSGA)V1RXbvbqaQakg(NObEBcOcW6nxFjOtbqaA3RqwrKFavqRb0oM1XmqNGoDj82eH7FwUkIoC8H58x6jhH7)CcbDcOGofabOcGVuS0aznGYc53oafEkmGcNya1LW9b0dbOUq)AUyJXGoDj82en8SOXcg0PlH3MOXhMt6Tw0LWBZy7qqRtxHhK720BrIaD6s4TjA8H5KERfDj82m2oe060v4bso53H7JaDcOGoDj82eHL720BrIg6x4TP1xDWkrtTIfB7QBgee)SlHeeIMAf7c5K8sYyX7WjSP3MOPwXUqojVKmw8oCc)SIFjQSGcyccrtTILVb5AgB6TjAQvS8nixZ4Nv8lrL0XOwc60LWBtewUBtVfjA8H5Ah5eefhHrtQWj06RoG65wlc9NKHiC7iNGO4imAsfoHLh6GGWQ5F)0rwiNqSR1imxQdbreeVF6ilKti21Ae(YYLUrTe0PlH3MiSC3MEls04dZvVNfB7QT(QdIMAf7c5K8sYyX7WjSPNGq0uRy5BqUMXMEBIMAflFdY1mgbDPfdcod0PlH3MiSC3MEls04dZHMoUPJBnkKts2tjd60LWBtewUBtVfjA8H5mioEqwX60v4H3lnTjTaffpY4Z6OObc3e0PlH3MiSC3MEls04dZzqC8GSI1PRWdoAsONmk(EPTFuUV3S(QdAw0uR43lT9JY99wuZIMAfR3IKGWkrtTIDHCsEjzS4D4e(zf)su5HoMrqiAQvS8nixZye0Lwmi4mBIMAflFdY1m(zf)suzbh1sBwj3TP3IetA8xFEg3A0ln(x4e(zf)suzbOzeeq)jzigEkCeUr9XLy)mcI5zeItjJLBQ5eX6y7QCDFjJv8rSVLGoDj82eHL720BrIgFyodIJhKvSoDfEyemkoTfn(T(QdIMAf7c5K8sYyX7WjSPNGq0uRy5BqUMXMEBIMAflFdY1mgbDPfdcod0PlH3MiSC3MEls04dZzqC8GSI1PRWdcpVf3A0ZtXHSok22vB9vhSs0uRyxiNKxsglEhoHn9eeIMAflFdY1m20Bt0uRy5BqUMXpR4xIkrqbSLeewj3TP3Ie7c5K8sYyX7Wj8Zk(LOY2pJGqUBtVfjw(gKRz8Zk(LOY2pZsqNUeEBIWYDB6TirJpmNbXXdYkwNUcpO3vbfRM3oRV6GOPwXUqojVKmw8oCcB6jien1kw(gKRzSP3MOPwXY3GCnJFwXVevIGcyqNUeEBIWYDB6TirJpmNbXXdYkwNUcpq6nw6Tg)OOi7wy9vhen1k2fYj5LKXI3HtytpbHOPwXY3GCnJn92en1kw(gKRz8Zk(LOseCuqNUeEBIWYDB6TirJpmNbXXdYkwNUcpiAh5MCuK5O3u80LwF1brtTIDHCsEjzS4D4e20tqiAQvS8nixZytpOtxcVnry5Un9wKOXhMZG44bzfRtxHhu4NTao5Oy1tsRV6GvZ)(PJSqoHyxRryUuhcIiiE)0rwiNqSR1i8LLfCuljiq9CRfH(tYqewFcVKJi4(kLh6a0PlH3MiSC3MEls04dZzqC8GSI1PRWd9ntQ5xK9xJI1MJSW6RoiAQvSlKtYljJfVdNWMEccrtTILVb5AgB6TjAQvS8nixZye0LwuEqWzeeYDB6TiXUqojVKmw8oCc)SIFjQSahLGyErtTILVb5AgB6Tj3TP3IelFdY1m(zf)suzbokOtxcVnry5Un9wKOXhMZG44bzfRtxHhe5hXVf8JIJWmcJ1xDq0uRyxiNKxsglEhoHn9eeIMAflFdY1m20Bt0uRy5BqUMXiOlTO8GGZiiK720BrIDHCsEjzS4D4e(zf)suzbokbX8IMAflFdY1m20BtUBtVfjw(gKRz8Zk(LOYcCuqNUeEBIWYDB6TirJpmNbXXdYkwNUcpWPUXiueEPeAEoU1y9Dj820BX(TGFRV6GOPwXUqojVKmw8oCcB6jien1kw(gKRzSP3MOPwXY3GCnJrqxAr5bbNrqi3TP3Ie7c5K8sYyX7Wj8Zk(LOYcCucc5Un9wKy5BqUMXpR4xIklWrbD6s4Tjcl3TP3Ien(WCgehpiRyD6k8qp7FlQpH8JIYvP3riRV6GOPwXUqojVKmw8oCcB6jien1kw(gKRzSP3MOPwXY3GCnJrqxAr5bbNb60LWBtewUBtVfjA8H5mioEqwX60v4H69iyuXHmkI6TJS5iK1xDq0uRyxiNKxsglEhoHn9eeIMAflFdY1m20Bt0uRy5BqUMXpR4xIkzqWrbD6s4Tjcl3TP3Ien(WCgehpiRyD6k8GC)30dzDKS56ZH7JIkS2BTBtRV6GOPwXUqojVKmw8oCcB6jien1kw(gKRzSP3MOPwXY3GCnJFwXVevshZaD6s4Tjcl3TP3Ien(WCgehpiRyD6k8GC)30dzDKS56ZH7JIIUMKT(QdIMAf7c5K8sYyX7WjSPNGq0uRy5BqUMXMEBIMAflFdY1m(zf)sujcokOtxcVnry5Un9wKOXhMZG44bzfRtxHhk(doDjzeXKkCcJBnQFgbDshob60LWBtewUBtVfjA8H5mioEqwX60v4b00kTq8G8JIvpjT(QdIMAf7c5K8sYyX7WjSPNGq0uRy5BqUMXMEqNUeEBIWYDB6TirJpmNbXXdYkwNUcp0oHxsg3RfLEEii)GoDj82eHL720BrIgFyodIJhKvSoDfE4pOXBXk7Wj(JBnAYKm6wy9vhen1k2fYj5LKXI3HtytpbHOPwXY3GCnJn92en1kw(gKRzmc6slgeCgbHC3MElsSlKtYljJfVdNWpR4xIkpy)mcc5Un9wKy5BqUMXpR4xIkpy)mqNUeEBIWYDB6TirJpmNbXXdYkwNUcp8SYc5iP50Ek5OMfEsg0PlH3MiSC3MEls04dZzqC8GSI1PRWdcpVf3Aeb3xbb60LWBtewUBtVfjA8H5mioEqwX60v4HIP7BfxsII9nJItYwF1brtTIDHCsEjzS4D4e20tqiAQvS8nixZytVnrtTILVb5Ag)SIFjQKHoMb60LWBtewUBtVfjA8H5mioEqwX60v4b9ZUos2C95W9rrrxtYwF1brtTIDHCsEjzS4D4e20tqiAQvS8nixZytVnrtTILVb5Ag)SIFjQKHoMb60LWBtewUBtVfjA8H5mioEqwX60v4b9ZUo6O(79eIIkS2BTBtRV6GOPwXUqojVKmw8oCcB6jien1kw(gKRzSP3MOPwXY3GCnJFwXVevYqhZaD6s4Tjcl3TP3Ien(WCgehpiRyD6k8a5Vjjk2)NI3IVtYwF1H5fn1k2fYj5LKXI3HtytVT5fn1kw(gKRzSPh0PlH3MiSC3MEls04dZzqC8GSI1PRWdOlpeK)izZ1Nd3hffDnjB9vhen1k2fYj5LKXI3HtytpbHOPwXY3GCnJn92en1kw(gKRz8Zk(LOsgeCuqNUeEBIWYDB6TirJpmNbXXdYkwNUcpGU8qq(JKnxFoCFuuH1ERDBA9vhen1k2fYj5LKXI3HtytpbHOPwXY3GCnJn92en1kw(gKRz8Zk(LOsg6ygOtxcVnry5Un9wKOXhMZG44bzfRtxHh8sdn5VJI1nHXTg73c(T(QdZd9gNqS8nixZyoDXgRTj3TP3Ie7c5K8sYyX7Wj8Zk(LOsgLGa6noHy5BqUMXC6InwBtUBtVfjw(gKRz8Zk(LOsg1g8u4YcoJGyAB2f73c(lpyVn4PWLi4mBqVXjex4wWXTgD0eJWC6Inwd60LWBtewUBtVfjA8H5mioEqwX60v4bHh62mU1OMvoeB9vhen1k2fYj5LKXI3HtytpbHOPwXY3GCnJn92en1kw(gKRzmc6slgeCgbHC3MElsSlKtYljJfVdNWpR4xIkpy)mcc5Un9wKy5BqUMXpR4xIkpy)mqNUeEBIWYDB6TirJpmNbXXdYkwNUcp4OjHEYO47L2(r5(EZ6RoOzrtTIFV02pk33BrnlAQvSElsccRen1k2fYj5LKXI3Ht4Nv8lrLh6ygbHOPwXY3GCnJrqxAXGGZSjAQvS8nixZ4Nv8lrLfCulTzLC3MElsmPXF95zCRrV04FHt4Nv8lrLfGMrqapfoc3O(4sSFgbX8mcXPKXYn1CIyDSDvUUVKXk(i23sqNUeEBIWYDB6TirJpmNbXXdYkwNUcpyrUW4wJEkpoHXQ5TZ6RoiAQvSlKtYljJfVdNWMEccrtTILVb5AgB6TjAQvS8nixZye0LwuEqWzeeYDB6TiXUqojVKmw8oCc)SIFjQS9ZiiMx0uRy5BqUMXMEBYDB6TiXY3GCnJFwXVev2(zGoDj82eHL720BrIgFyoxiNKxsglEhoz9vhSAAB2f73c(lpiqBWtHlzucIPTzxSFl4V8G92GNcxEuccO34eIN2MDrxiNK8J50fBS2MC3MEls802Sl6c5KKF8Zk(LOHzwAdEkCeUXPEYHzGoDj82eHL720BrIgFyo5BqUMT(QdwnTn7I9Bb)LheOn4PWLmkbX02Sl2Vf8xEWEBWtHlpkbb0BCcXtBZUOlKts(XC6InwBtUBtVfjEAB2fDHCsYp(zf)s0WmlTbpfoc34up5WmqNUeEBIWYDB6TirJpmNJM4mo5T2wa60LWBtewUBtVfjA8H5M2MDrxiNK8B9vhGNchHBCQNCyMnRSs0uRyxiNKxsglEhoHn9eeIMAflFdY1m20BjbHvIMAf7c5K8sYyX7WjSElsBYDB6TiXUqojVKmw8oCc)SIFjQSaNrqiAQvS8nixZy9wK2K720BrILVb5Ag)SIFjQSaNzPLGoDj82eHL720BrIgFyU6LEl(S0InVK06RomTn7I9Bb)LhS3MC3MElsSlKtYljJfVdNWpR4xIktk12GNchHBCQNCyMnRMh6noHye)E)0PG50fBSMGq0uRye)E)0PGn9eeYDB6TiXi(9(Ptb)SIFjQSGJAjOtxcVnry5Un9wKOXhMdoXrtkUMuhR7lzRV6a8u4sg6GGq0uR4NLw0yekw3xYytpOtxcVnry5Un9wKOXhMtSTRoU1iCIJCYk2z9vhen1k2fYj5LKXI3HtytpbHOPwXY3GCnJn92en1kw(gKRzmc6slgeCgOtxcVnry5Un9wKOXhMJ04V(8mU1OxA8VWjRV6W8qVXjelFdY1mMtxSXABwj3TP3Ie7c5K8sYyX7Wj8Zk(LOsg1202Sl2Vf8xEWEcc5Un9wKyxiNKxsglEhoHFwXVevEqGJAjbHvqVXjelFdY1mMtxSXABYDB6TiXY3GCnJFwXVevcPuBBAB2f73c(lpiqcc5Un9wKy5BqUMXpR4xIkpiWrTe0PlH3MiSC3MEls04dZvSFtlKVm(mAtpLS1xDqUBtVfj2fYj5LKXI3Ht4Nv8lrLqk12M2MDX(TG)Yd2tqa9gNqS8nixZyoDXgRTj3TP3IelFdY1m(zf)sujKsTTPTzxSFl4V8GajiK720BrIDHCsEjzS4D4e(zf)su5bbokbHC3MElsS8nixZ4Nv8lrLhe4OGoDj82eHL720BrIgFyU6kniwh9sJ)dYrr2vS(Qdwn)7NoYc5eIDTgH5sDiiIG49thzHCcXUwJWxw2(zeeOEU1Iq)jzicRpHxYreCFLYdDyPT5Ts0uRyxiNKxsglEhoHn9eeIMAflFdY1m20BPnRK720BrIfBUMJBnocdcEsg)SIFjQmPups7Tj3TP3IepcJMuHti(zf)suzsPEK2BjOtxcVnry5Un9wKOXhMtHv23U4wJnJ80r9ZUcY6RoyLOPwXUqojVKmw8oCcB6jien1kw(gKRzSP3MOPwXY3GCnJrqxAXGGZS0202Sl2Vf8xYG9GoDj82eHL720BrIgFyUEZFv7UKmk2Ce06Roy18VF6ilKti21AeMl1HGicI3pDKfYje7AncFzz7NrqG65wlc9NKHiS(eEjhrW9vkp0HLGobuqNUeEBIW1lp0e)OXhMtO)Nl2yRtxHh0OO0rqxSXwl0BgEa1ZTwe6pjdry9j8soIG7RuEOdccrtTIzLE7E2Zy)wWp20BtZIMAfpcJMuHtiwVfPnrtTI1NWl5yV57xeJ1BrsqG65wlc9NKHiS(eEjhrW9vkp0HnrtTILVb5AgB6TjAQvS8nixZye0LwuIGZaD6s4TjcxV8qt8JgFyoe)E)0Py9vhSYQ5HEJtiw(gKRzmNUyJ12en1k2fYj5LKXI3HtytpbHC3MElsSlKtYljJfVdNWpR4xIk3XOwsqyLOPwXY3GCnJn9eeYDB6TiXY3GCnJFwXVevUJrT0sBwnp0BCcX1l9w8zPfBEjjMtxSXAcc5Un9wK46LEl(S0InVKe)SIFjQebNrqi3TP3IexV0BXNLwS5LK4Nv8lrLTFulTz18qVXjeZLILg4TzeXjKtjJ50fBSMGqUBtVfjMlflnWBZiItiNsg)SIFjQebNzPn4PWr4gN6jhMb60LWBteUE5HM4hn(WCc9uaWCOj(rXjxrHFRV6GvZd9gNqC9sVfFwAXMxsI50fBSMGqUBtVfjUEP3IplTyZljXpR4xIktk1JuWzeeAw0uR46LEl(S0InVKeB6T0MvZd9gNqmxkwAG3MreNqoLmMtxSXAcc5Un9wKyUuS0aVnJioHCkz8Zk(LOYKs9ifCgbHMfn1kMlflnWBZiItiNsgB6TKGa1ZTwe6pjdry9j8soIG7RuEOdqNUeEBIW1lp0e)OXhMJlflnWBZiItiNs26RoG65wlc9NKHiS(eEjhrW9vkzWEBwz18qVXjelFdY1mMtxSXAccrtTILVb5AgR3I0MC3MElsS8nixZ4Nv8lrLfCMLeeIMAflFdY1mgbDPfLhSNGqUBtVfj2fYj5LKXI3Ht4Nv8lrLfCgbHMfn1kUEP3IplTyZljXMElTbpfoc34up5WmqNUeEBIW1lp0e)OXhMtFcVKJi4(kwF1bH(FUyJXAuu6iOl2yBZlAQvSqpfamhAIFuCYvu4hB6TzLvZd9gNqS8nixZyoDXgRjiK720BrILVb5Ag)SIFjQmPups7T0MvZd9gNqmxkwAG3MreNqoLmMtxSXAcc5Un9wKyUuS0aVnJioHCkz8Zk(LOYKs9iTNGa1ZTwe6pjdry9j8soIG7RuEWEljiq9CRfH(tYqewFcVKJi4(kLh6WMvqVXjepTn7IUqoj5hZPl2yTn5Un9wK4PTzx0fYjj)4Nv8lrLqk1J0EccrtTILVb5AgB6TjAQvS8nixZye0LwuIGZS0sqNUeEBIW1lp0e)OXhMdYk9n)rrH8Rpj06Roy18qVXjelFdY1mMtxSXAcc5Un9wKy5BqUMXpR4xIktk1J0ElTz18qVXjeZLILg4TzeXjKtjJ50fBSMGqUBtVfjMlflnWBZiItiNsg)SIFjQmPups7TH65wlc9NKHiS(eEjhrW9vkzWElTz18qVXjexV0BXNLwS5LKyoDXgRjiK720BrIRx6T4Zsl28ss8Zk(LOYKs9iT3sBwnVCfYPNqCYYFB7RXC6Inwtqi3TP3Iel0tbaZHM4hfNCff(XpR4xIktk1wsqa9gNq802Sl6c5KKFmNUyJ12K720BrIN2MDrxiNK8JFwXVevcPups7jien1kEAB2fDHCsYp20tqiAQvS8nixZytVnrtTILVb5AgJGU0IseCgbHOPwXc9uaWCOj(rXjxrHFSPh0jGc60LWBteMKt(D4(OXhMt6Tw0LWBZy7qqRtxHhQxEOj(rwF1HPTzxSFl4V8WOeeIMAfpTn7IUqoj5hB6ji0SOPwX1l9w8zPfBEjj20tqOzrtTI5sXsd82mI4eYPKXMEqNUeEBIWKCYVd3hn(WCIngHUKmU1iYOOWpOtxcVnryso53H7JgFyoXgJqxsg3A0nqJsc60LWBteMKt(D4(OXhMtSXi0LKXTglUeYpOtxcVnryso53H7JgFyoXgJqxsg3Ae1)xsc60LWBteMKt(D4(OXhMtFcVKJWT1S(QdZRzrtTIhHrtQWjeB6Tz18VF6ilKti21AeMl1HGicI3pDKfYje7AncFzz7NzPnRM2MDX(TG)sg6GGyAB2f73c(lzqG2SsUBtVfjwS5AoU14imi4jz8Zk(LOYKs9i7GGqZIMAfZLILg4TzeXjKtjJn9eeAw0uR46LEl(S0InVKeB6T0sBwnp0BCcX1l9w8zPfBEjjMtxSXAcc5Un9wK46LEl(S0InVKe)SIFjQmPupsbNzPnRMh6noHyUuS0aVnJioHCkzmNUyJ1eeYDB6TiXCPyPbEBgrCc5uY4Nv8lrLjL6rk4mlbD6s4TjctYj)oCF04dZv4wWXTgD0eJS(QdwnTn7I9Bb)dZiiM2MDX(TG)sg6WMvYDB6TiXInxZXTghHbbpjJFwXVevMuQhzheeAw0uRyUuS0aVnJioHCkzSPNGqZIMAfxV0BXNLwS5LKytVLwAZQ5F)0rwiNqSR1imxQdbreeVF6ilKti21Ae(YYDmZsBwnp0BCcXCPyPbEBgrCc5uYyoDXgRjiK720BrI5sXsd82mI4eYPKXpR4xIkl4OwAZQ5HEJtiUEP3IplTyZljXC6Inwtqi3TP3IexV0BXNLwS5LK4Nv8lrLfCulbD6s4TjctYj)oCF04dZj2Cnh3ACege8KS1xDyAB2f73c(lzWEqNUeEBIWKCYVd3hn(WCtUIc)XTglEhoz9vhM2MDX(TG)sgeiOtxcVnryso53H7JgFyUry0KkCcT(QdZRzrtTIhHrtQWjeB6Tz102Sl2Vf8xYqheetBZUy)wWFjdc0MC3MElsSyZ1CCRXryqWtY4Nv8lrLjL6r2HLGoDj82eHj5KFhUpA8H5KERfDj82m2oe060v4H6LhAIFK1xDWkO)KmepXEdoH7LWsg6ygbHOPwXUqojVKmw8oCcB6jien1kw(gKRzSPNGq0uRywP3UN9m2Vf8Jn9wc60LWBteMKt(D4(OXhMt(gKR5pIG)zbB9vhK720BrILVb5A(Ji4FwWy5K)KmkwFxcVn9w5bbXLUrTz102Sl2Vf8xYqheetBZUy)wWFjd2BtUBtVfjwS5AoU14imi4jz8Zk(LOYKs9i7GGyAB2f73c(heOn5Un9wKyXMR54wJJWGGNKXpR4xIktk1JSdBYDB6TiXJWOjv4eIFwXVevMuQhzhwc60LWBteMKt(D4(OXhMt6Tw0LWBZy7qqRtxHhQxEOj(rGoDj82eHj5KFhUpA8H5KVb5A(Ji4FwWwF1HPTzxSFl4VKbbc60LWBteMKt(D4(OXhMtUPKt47qwhRnxHbD6s4TjctYj)oCF04dZ9S3FjzS2Cfgz9vhG(tYq8e7n4uSxcllGNrqa9NKH4j2BWPyVewshZiiQh5em(SIFjQe7hf0PlH3MimjN87W9rJpmN)sp5iC)NtO1xDyAB2f73c(lzqGGoDj82eHj5KFhUpA8H5KBIy57WBtRV6a8u4iCJt9KLjL6GQq(r3MHU7ywhZeCM9ZWcgul8pVKefufaRamfq1Ta6UfGHa8akG21edONs)(qaTUpGkGuV8qt8Jeqa0Nfam3ZAafTkmG6g4Q4qwdOYjpjzeg0PayUKb0sVa8aQa42ui)qwdOciYviNEcXcWH50fBSwabqHlGkGixHC6jelaNacGALGLYsmOtqNDnXaQaIbXXdYkibea1LWBtaTWraAUqaTUMudOxcOWPdbONs)(qmOtb0k97dznGokG6s4TjG2oeeHbDguDdCA)GQQaGHBoC)GA7qquORGQMRUPbdDf6wWqxbvxcVndQplASGdQC6InwhgladD3rORGkNUyJ1HXcQUeEBguLERfDj82m2oemO2oemMUchuL720BrIcWq32h6kOYPl2yDySGQlH3MbvP3ArxcVnJTdbdQTdbJPRWbvso53H7JcWamO2)SCveDyORq3cg6kO6s4Tzq1FPNCeU)ZjmOYPl2yDySamadQKCYVd3hf6k0TGHUcQC6InwhglOk)dY)5b1PTzxSFl4hqlpaOJcOeeaQOPwXtBZUOlKts(XMEaLGaq1SOPwX1l9w8zPfBEjj20dOeeaQMfn1kMlflnWBZiItiNsgB6dQUeEBguLERfDj82m2oemO2oemMUchuRxEOj(rbyO7ocDfuDj82mOk2ye6sY4wJiJIc)bvoDXgRdJfGHUTp0vq1LWBZGQyJrOljJBn6gOrjdQC6InwhgladDlWqxbvxcVndQIngHUKmU1yXLq(dQC6InwhgladDpAORGQlH3MbvXgJqxsg3Ae1)xsgu50fBSomwag6U0h6kOYPl2yDySGQ8pi)NhuNhq1SOPwXJWOjv4eIn9aQna1kaDEa99thzHCcXUwJWCPoeebOeea67NoYc5eIDTgHVeqldO2pdqTeqTbOwbOtBZUy)wWpGwYaG2bGsqaOtBZUy)wWpGwYaGkqa1gGAfGk3TP3Iel2Cnh3ACege8Km(zf)seGwgqjLAaDKaAhakbbGQzrtTI5sXsd82mI4eYPKXMEaLGaq1SOPwX1l9w8zPfBEjj20dOwcOwcO2auRa05buO34eIRx6T4Zsl28ssmNUyJ1akbbGk3TP3IexV0BXNLwS5LK4Nv8lraAzaLuQb0rcOcodqTeqTbOwbOZdOqVXjeZLILg4TzeXjKtjJ50fBSgqjiau5Un9wKyUuS0aVnJioHCkz8Zk(LiaTmGsk1a6ibubNbOwguDj82mOQpHxYr42AbyO7sxORGkNUyJ1HXcQY)G8FEq1kaDAB2f73c(b0baDgGsqaOtBZUy)wWpGwYaG2bGAdqTcqL720BrIfBUMJBnocdcEsg)SIFjcqldOKsnGosaTdaLGaq1SOPwXCPyPbEBgrCc5uYytpGsqaOAw0uR46LEl(S0InVKeB6bulbulbuBaQva68a67NoYc5eIDTgH5sDiicqjia03pDKfYje7AncFjGwgq7ygGAjGAdqTcqNhqHEJtiMlflnWBZiItiNsgZPl2ynGsqaOYDB6TiXCPyPbEBgrCc5uY4Nv8lraAzavWrbulbuBaQva68ak0BCcX1l9w8zPfBEjjMtxSXAaLGaqL720BrIRx6T4Zsl28ss8Zk(LiaTmGk4OaQLbvxcVndQfUfCCRrhnXOam0Tao0vqLtxSX6Wybv5Fq(ppOoTn7I9Bb)aAjdaQ9bvxcVndQInxZXTghHbbpjhGHUfGcDfu50fBSomwqv(hK)ZdQtBZUy)wWpGwYaGkWGQlH3Mb1jxrH)4wJfVdNcWq3col0vqLtxSX6Wybv5Fq(ppOopGQzrtTIhHrtQWjeB6buBaQva602Sl2Vf8dOLmaODaOeea602Sl2Vf8dOLmaOceqTbOYDB6TiXInxZXTghHbbpjJFwXVebOLbusPgqhjG2bGAzq1LWBZG6imAsfoHbyOBbfm0vqLtxSX6Wybv5Fq(ppOAfGc9NKH4j2BWjCVecOLmaODmdqjiaurtTIDHCsEjzS4D4e20dOeeaQOPwXY3GCnJn9akbbGkAQvmR0B3ZEg73c(XMEa1YGQlH3MbvP3ArxcVnJTdbdQTdbJPRWb16LhAIFuag6wWocDfu50fBSomwqv(hK)ZdQYDB6TiXY3GCn)re8plySCYFsgfRVlH3MEdqlpaOcIlDJcO2auRa0PTzxSFl4hqlzaq7aqjia0PTzxSFl4hqlzaqThqTbOYDB6TiXInxZXTghHbbpjJFwXVebOLbusPgqhjG2bGsqaOtBZUy)wWpGoaOceqTbOYDB6TiXInxZXTghHbbpjJFwXVebOLbusPgqhjG2bGAdqL720BrIhHrtQWje)SIFjcqldOKsnGosaTda1YGQlH3Mbv5BqUM)ic(NfCag6wq7dDfu50fBSomwq1LWBZGQ0BTOlH3MX2HGb12HGX0v4GA9YdnXpkadDlOadDfu50fBSomwqv(hK)ZdQtBZUy)wWpGwYaGkWGQlH3Mbv5BqUM)ic(NfCag6wWrdDfuDj82mOk3uYj8DiRJ1MRWbvoDXgRdJfGHUfS0h6kOYPl2yDySGQ8pi)NhuH(tYq8e7n4uSxcb0YaQaEgGsqaOq)jziEI9gCk2lHaAjaAhZauccaTEKtW4Zk(LiaTea1(rdQUeEBguF27VKmwBUcJcWq3cw6cDfu50fBSomwqv(hK)ZdQtBZUy)wWpGwYaGkWGQlH3Mbv)LEYr4(pNWam0TGc4qxbvoDXgRdJfuL)b5)8Gk8u4iCJt9KaAzaLuQdQUeEBguLBIy57WBZamadQ1lp0e)OqxHUfm0vqLtxSX6Wyb1TpOIyyq1LWBZGQq)pxSXbvHEZWbvup3ArO)KmeH1NWl5icUVcGwEaq7aqjiaurtTIzLE7E2Zy)wWp20dO2aunlAQv8imAsfoHy9wKaQnav0uRy9j8so2B((fXy9wKakbbGI65wlc9NKHiS(eEjhrW9va0YdaAhaQnav0uRy5BqUMXMEa1gGkAQvS8nixZye0LwaOLaOcolOk0)y6kCqvJIshbDXghGHU7i0vqLtxSX6Wybv5Fq(ppOAfGAfGopGc9gNqS8nixZyoDXgRbuBaQOPwXUqojVKmw8oCcB6buccavUBtVfj2fYj5LKXI3Ht4Nv8lraAzaTJrbulbucca1kav0uRy5BqUMXMEaLGaqL720BrILVb5Ag)SIFjcqldODmkGAjGAjGAdqTcqNhqHEJtiUEP3IplTyZljXC6InwdOeeaQC3MElsC9sVfFwAXMxsIFwXVebOLaOcodqjiau5Un9wK46LEl(S0InVKe)SIFjcqldO2pkGAjGAdqTcqNhqHEJtiMlflnWBZiItiNsgZPl2ynGsqaOYDB6TiXCPyPbEBgrCc5uY4Nv8lraAjaQGZaulbuBak8u4iCJt9Ka6aGolO6s4TzqfXV3pDkbyOB7dDfu50fBSomwqv(hK)ZdQwbOZdOqVXjexV0BXNLwS5LKyoDXgRbuccavUBtVfjUEP3IplTyZljXpR4xIa0YakPudOJeqfCgGsqaOAw0uR46LEl(S0InVKeB6bulbuBaQva68ak0BCcXCPyPbEBgrCc5uYyoDXgRbuccavUBtVfjMlflnWBZiItiNsg)SIFjcqldOKsnGosavWzakbbGQzrtTI5sXsd82mI4eYPKXMEa1saLGaqr9CRfH(tYqewFcVKJi4(kaA5baTJGQlH3MbvHEkayo0e)O4KROWFag6wGHUcQC6InwhglOk)dY)5bvup3ArO)KmeH1NWl5icUVcGwYaGApGAdqTcqTcqNhqHEJtiw(gKRzmNUyJ1akbbGkAQvS8nixZy9wKaQnavUBtVfjw(gKRz8Zk(LiaTmGk4ma1saLGaqfn1kw(gKRzmc6sla0YdaQ9akbbGk3TP3Ie7c5K8sYyX7Wj8Zk(LiaTmGk4maLGaq1SOPwX1l9w8zPfBEjj20dOwcO2au4PWr4gN6jb0baDwq1LWBZGkxkwAG3MreNqoLCag6E0qxbvoDXgRdJfuL)b5)8GQq)pxSXynkkDe0fBmGAdqNhqfn1kwONcaMdnXpko5kk8Jn9aQna1ka1kaDEaf6noHy5BqUMXC6InwdOeeaQC3MElsS8nixZ4Nv8lraAzaLuQb0rcO2dOwcO2auRa05buO34eI5sXsd82mI4eYPKXC6InwdOeeaQC3MElsmxkwAG3MreNqoLm(zf)seGwgqjLAaDKaQ9akbbGI65wlc9NKHiS(eEjhrW9va0YdaQ9aQLakbbGI65wlc9NKHiS(eEjhrW9va0YdaAhaQna1kaf6noH4PTzx0fYjj)yoDXgRbuBaQC3MEls802Sl6c5KKF8Zk(LiaTeaLuQb0rcO2dOeeaQOPwXY3GCnJn9aQnav0uRy5BqUMXiOlTaqlbqfCgGAjGAzq1LWBZGQ(eEjhrW9vcWq3L(qxbvoDXgRdJfuL)b5)8GQva68ak0BCcXY3GCnJ50fBSgqjiau5Un9wKy5BqUMXpR4xIa0YakPudOJeqThqTeqTbOwbOZdOqVXjeZLILg4TzeXjKtjJ50fBSgqjiau5Un9wKyUuS0aVnJioHCkz8Zk(LiaTmGsk1a6ibu7buBakQNBTi0FsgIW6t4LCeb3xbqlzaqThqTeqTbOwbOZdOqVXjexV0BXNLwS5LKyoDXgRbuccavUBtVfjUEP3IplTyZljXpR4xIa0YakPudOJeqThqTeqTbOwbOZdOYviNEcXjl)TTVgqjiau5Un9wKyHEkayo0e)O4KROWp(zf)seGwgqjLAa1saLGaqHEJtiEAB2fDHCsYpMtxSXAa1gGk3TP3IepTn7IUqoj5h)SIFjcqlbqjLAaDKaQ9akbbGkAQv802Sl6c5KKFSPhqjiaurtTILVb5AgB6buBaQOPwXY3GCnJrqxAbGwcGk4maLGaqfn1kwONcaMdnXpko5kk8Jn9bvxcVndQqwPV5pkkKF9jHbyaguL720BrIcDf6wWqxbvoDXgRdJfuL)b5)8GQvaQOPwXITD1ndcIF2LqaLGaqfn1k2fYj5LKXI3HtytpGAdqfn1k2fYj5LKXI3Ht4Nv8lraAzavqbmGsqaOIMAflFdY1m20dO2aurtTILVb5Ag)SIFjcqlbq7yua1YGQlH3Mb1(fEBgGHU7i0vqLtxSX6Wybv5Fq(ppOI65wlc9NKHiC7iNGO4imAsfoHaA5baTdaLGaqTcqNhqF)0rwiNqSR1imxQdbrakbbG((PJSqoHyxRr4lb0YaAPBua1YGQlH3Mb12robrXry0KkCcdWq32h6kOYPl2yDySGQ8pi)Nhufn1k2fYj5LKXI3HtytpGsqaOIMAflFdY1m20dO2aurtTILVb5AgJGU0caDaqfCwq1LWBZGA9EwSTRoadDlWqxbvxcVndQOPJB64wJc5KK9uYbvoDXgRdJfGHUhn0vqLtxSX6Wyb10v4G67LM2KwGIIhz8zDu0aHBguDj82mO(EPPnPfOO4rgFwhfnq4MbyO7sFORGkNUyJ1HXcQUeEBguD0Kqpzu89sB)OCFVfuL)b5)8GQMfn1k(9sB)OCFVf1SOPwX6Tibucca1kav0uRyxiNKxsglEhoHFwXVebOLha0oMbOeeaQOPwXY3GCnJrqxAbGoaOcodqTbOIMAflFdY1m(zf)seGwgqfCua1sa1gGAfGk3TP3IetA8xFEg3A0ln(x4e(zf)seGwgqfGMbOeeak0FsgIHNchHBuFmGwcGA)maLGaqNhqzeItjJLBQ5eX6y7QCDFjJv8rSpGAzqnDfoO6OjHEYO47L2(r5(EladDx6cDfu50fBSomwq1LWBZG6iyuCAlA8huL)b5)8GQOPwXUqojVKmw8oCcB6buccav0uRy5BqUMXMEa1gGkAQvS8nixZye0LwaOdaQGZcQPRWb1rWO40w04padDlGdDfu50fBSomwq1LWBZGQWZBXTg98uCiRJITD1bv5Fq(ppOAfGkAQvSlKtYljJfVdNWMEaLGaqfn1kw(gKRzSPhqTbOIMAflFdY1m(zf)seGwcGkOagqTeqjiauRau5Un9wKyxiNKxsglEhoHFwXVebOLbu7NbOeeaQC3MElsS8nixZ4Nv8lraAza1(zaQLb10v4GQWZBXTg98uCiRJITD1byOBbOqxbvoDXgRdJfuDj82mOQ3vbfRM3UGQ8pi)Nhufn1k2fYj5LKXI3HtytpGsqaOIMAflFdY1m20dO2aurtTILVb5Ag)SIFjcqlbqfuahutxHdQ6DvqXQ5TladDl4SqxbvoDXgRdJfuDj82mOs6nw6Tg)OOi7weuL)b5)8GQOPwXUqojVKmw8oCcB6buccav0uRy5BqUMXMEa1gGkAQvS8nixZ4Nv8lraAjaQGJgutxHdQKEJLERXpkkYUfbyOBbfm0vqLtxSX6WybvxcVndQI2rUjhfzo6nfpDzqv(hK)ZdQIMAf7c5K8sYyX7WjSPhqjiaurtTILVb5AgB6dQPRWbvr7i3KJImh9MINUmadDlyhHUcQC6InwhglO6s4TzqvHF2c4KJIvpjdQY)G8FEq1kaDEa99thzHCcXUwJWCPoeebOeea67NoYc5eIDTgHVeqldOcokGAjGsqaOOEU1Iq)jzicRpHxYreCFfaT8aG2rqnDfoOQWpBbCYrXQNKbyOBbTp0vqLtxSX6WybvxcVndQ9ntQ5xK9xJI1MJSiOk)dY)5bvrtTIDHCsEjzS4D4e20dOeeaQOPwXY3GCnJn9aQnav0uRy5BqUMXiOlTaqlpaOcodqjiau5Un9wKyxiNKxsglEhoHFwXVebOLbubokGsqaOZdOIMAflFdY1m20dO2au5Un9wKy5BqUMXpR4xIa0YaQahnOMUchu7BMuZVi7VgfRnhzrag6wqbg6kOYPl2yDySGQlH3Mbvr(r8Bb)O4imJWeuL)b5)8GQOPwXUqojVKmw8oCcB6buccav0uRy5BqUMXMEa1gGkAQvS8nixZye0LwaOLhaubNbOeeaQC3MElsSlKtYljJfVdNWpR4xIa0YaQahfqjia05burtTILVb5AgB6buBaQC3MElsS8nixZ4Nv8lraAzavGJgutxHdQI8J43c(rXrygHjadDl4OHUcQC6InwhglO6s4TzqLtDJrOi8sj08CCRX67s4TP3I9Bb)bv5Fq(ppOkAQvSlKtYljJfVdNWMEaLGaqfn1kw(gKRzSPhqTbOIMAflFdY1mgbDPfaA5bavWzakbbGk3TP3Ie7c5K8sYyX7Wj8Zk(LiaTmGkWrbuccavUBtVfjw(gKRz8Zk(LiaTmGkWrdQPRWbvo1ngHIWlLqZZXTgRVlH3MEl2Vf8hGHUfS0h6kOYPl2yDySGQlH3Mb1E2)wuFc5hfLRsVJqbv5Fq(ppOkAQvSlKtYljJfVdNWMEaLGaqfn1kw(gKRzSPhqTbOIMAflFdY1mgbDPfaA5bavWzb10v4GAp7FlQpH8JIYvP3rOam0TGLUqxbvoDXgRdJfuDj82mOwVhbJkoKrruVDKnhHcQY)G8FEqv0uRyxiNKxsglEhoHn9akbbGkAQvS8nixZytpGAdqfn1kw(gKRz8Zk(LiaTKbavWrdQPRWb169iyuXHmkI6TJS5iuag6wqbCORGkNUyJ1HXcQUeEBguL7)MEiRJKnxFoCFuuH1ERDBguL)b5)8GQOPwXUqojVKmw8oCcB6buccav0uRy5BqUMXMEa1gGkAQvS8nixZ4Nv8lraAjaAhZcQPRWbv5(VPhY6izZ1Nd3hfvyT3A3MbyOBbfGcDfu50fBSomwq1LWBZGQC)30dzDKS56ZH7JIIUMKdQY)G8FEqv0uRyxiNKxsglEhoHn9akbbGkAQvS8nixZytpGAdqfn1kw(gKRz8Zk(LiaTeavWrdQPRWbv5(VPhY6izZ1Nd3hffDnjhGHU7ywORGkNUyJ1HXcQPRWb1I)GtxsgrmPcNW4wJ6NrqN0HtbvxcVndQf)bNUKmIysfoHXTg1pJGoPdNcWq3DiyORGkNUyJ1HXcQUeEBgurtR0cXdYpkw9KmOk)dY)5bvrtTIDHCsEjzS4D4e20dOeeaQOPwXY3GCnJn9b10v4GkAALwiEq(rXQNKbyO7o6i0vqLtxSX6Wyb10v4GA7eEjzCVwu65HG8huDj82mO2oHxsg3RfLEEii)byO7oSp0vqLtxSX6WybvxcVndQ)bnElwzhoXFCRrtMKr3IGQ8pi)Nhufn1k2fYj5LKXI3HtytpGsqaOIMAflFdY1m20dO2aurtTILVb5AgJGU0caDaqfCgGsqaOYDB6TiXUqojVKmw8oCc)SIFjcqlpaO2pdqjiau5Un9wKy5BqUMXpR4xIa0YdaQ9ZcQPRWb1)GgVfRSdN4pU1OjtYOBrag6Udbg6kOYPl2yDySGA6kCq9zLfYrsZP9uYrnl8KCq1LWBZG6ZklKJKMt7PKJAw4j5am0DhJg6kOYPl2yDySGA6kCqv45T4wJi4(kOGQlH3MbvHN3IBnIG7RGcWq3Du6dDfu50fBSomwq1LWBZGAX09TIljrX(MrXj5GQ8pi)Nhufn1k2fYj5LKXI3HtytpGsqaOIMAflFdY1m20dO2aurtTILVb5Ag)SIFjcqlzaq7ywqnDfoOwmDFR4ssuSVzuCsoadD3rPl0vqLtxSX6WybvxcVndQ6NDDKS56ZH7JIIUMKdQY)G8FEqv0uRyxiNKxsglEhoHn9akbbGkAQvS8nixZytpGAdqfn1kw(gKRz8Zk(LiaTKbaTJzb10v4GQ(zxhjBU(C4(OOORj5am0Dhc4qxbvoDXgRdJfuDj82mOQF21rh1FVNquuH1ERDBguL)b5)8GQOPwXUqojVKmw8oCcB6buccav0uRy5BqUMXMEa1gGkAQvS8nixZ4Nv8lraAjdaAhZcQPRWbv9ZUo6O(79eIIkS2BTBZam0DhcqHUcQC6InwhglO6s4TzqL83Kef7)tXBX3j5GQ8pi)NhuNhqfn1k2fYj5LKXI3HtytpGAdqNhqfn1kw(gKRzSPpOMUchuj)njrX()u8w8DsoadDB)SqxbvoDXgRdJfuDj82mOIU8qq(JKnxFoCFuu01KCqv(hK)ZdQIMAf7c5K8sYyX7WjSPhqjiaurtTILVb5AgB6buBaQOPwXY3GCnJFwXVebOLmaOcoAqnDfoOIU8qq(JKnxFoCFuu01KCag62EbdDfu50fBSomwq1LWBZGk6Ydb5ps2C95W9rrfw7T2Tzqv(hK)ZdQIMAf7c5K8sYyX7WjSPhqjiaurtTILVb5AgB6buBaQOPwXY3GCnJFwXVebOLmaODmlOMUchurxEii)rYMRphUpkQWAV1UndWq323rORGkNUyJ1HXcQUeEBgu9sdn5VJI1nHXTg73c(dQY)G8FEqDEaf6noHy5BqUMXC6InwdO2au5Un9wKyxiNKxsglEhoHFwXVebOLaOJcOeeak0BCcXY3GCnJ50fBSgqTbOYDB6TiXY3GCnJFwXVebOLaOJcO2au4PWaAzavWzakbbGoTn7I9Bb)aA5ba1Ea1gGcpfgqlbqfCgGAdqHEJtiUWTGJBn6OjgH50fBSoOMUchu9sdn5VJI1nHXTg73c(dWq32BFORGkNUyJ1HXcQUeEBgufEOBZ4wJAw5qCqv(hK)ZdQIMAf7c5K8sYyX7WjSPhqjiaurtTILVb5AgB6buBaQOPwXY3GCnJrqxAbGoaOcodqjiau5Un9wKyxiNKxsglEhoHFwXVebOLhau7NbOeeaQC3MElsS8nixZ4Nv8lraA5ba1(zb10v4GQWdDBg3AuZkhIdWq32lWqxbvoDXgRdJfuDj82mO6OjHEYO47L2(r5(ElOk)dY)5bvnlAQv87L2(r5(ElQzrtTI1BrcOeeaQvaQOPwXUqojVKmw8oCc)SIFjcqlpaODmdqjiaurtTILVb5AgJGU0caDaqfCgGAdqfn1kw(gKRz8Zk(LiaTmGk4OaQLaQna1kavUBtVfjM04V(8mU1OxA8VWj8Zk(LiaTmGkandqjiau4PWr4g1hdOLaO2pdqjia05bugH4uYy5MAorSo2Ukx3xYyfFe7dOwgutxHdQoAsONmk(EPTFuUV3cWq32pAORGkNUyJ1HXcQUeEBguTixyCRrpLhNWy182fuL)b5)8GQOPwXUqojVKmw8oCcB6buccav0uRy5BqUMXMEa1gGkAQvS8nixZye0LwaOLhaubNbOeeaQC3MElsSlKtYljJfVdNWpR4xIa0YaQ9ZauccaDEav0uRy5BqUMXMEa1gGk3TP3IelFdY1m(zf)seGwgqTFwqnDfoOArUW4wJEkpoHXQ5TladDBFPp0vqLtxSX6Wybv5Fq(ppOAfGoTn7I9Bb)aA5bavGaQnafEkmGwcGokGsqaOtBZUy)wWpGwEaqThqTbOWtHb0Ya6OakbbGc9gNq802Sl6c5KKFmNUyJ1aQnavUBtVfjEAB2fDHCsYp(zf)seGoaOZaulbuBak8u4iCJt9Ka6aGolO6s4Tzq1fYj5LKXI3HtbyOB7lDHUcQC6InwhglOk)dY)5bvRa0PTzxSFl4hqlpaOceqTbOWtHb0sa0rbuccaDAB2f73c(b0YdaQ9aQnafEkmGwgqhfqjiauO34eIN2MDrxiNK8J50fBSgqTbOYDB6TiXtBZUOlKts(XpR4xIa0baDgGAjGAdqHNchHBCQNeqha0zbvxcVndQY3GCnhGHUTxah6kO6s4Tzq1rtCgN8wBlcQC6InwhgladDBVauORGkNUyJ1HXcQY)G8FEqfEkCeUXPEsaDaqNbO2auRauRaurtTIDHCsEjzS4D4e20dOeeaQOPwXY3GCnJn9aQLakbbGAfGkAQvSlKtYljJfVdNW6TibuBaQC3MElsSlKtYljJfVdNWpR4xIa0YaQaNbOeeaQOPwXY3GCnJ1BrcO2au5Un9wKy5BqUMXpR4xIa0YaQaNbOwcOwguDj82mOoTn7IUqoj5padDlWzHUcQC6InwhglOk)dY)5b1PTzxSFl4hqlpaO2dO2au5Un9wKyxiNKxsglEhoHFwXVebOLbusPgqTbOWtHJWno1tcOda6ma1gGAfGopGc9gNqmIFVF6uWC6InwdOeeaQOPwXi(9(PtbB6buccavUBtVfjgXV3pDk4Nv8lraAzavWrbuldQUeEBguRx6T4Zsl28sYam0Tafm0vqLtxSX6Wybv5Fq(ppOcpfgqlzaq7aqjiaurtTIFwArJrOyDFjJn9bvxcVndQWjoAsX1K6yDFjhGHUfyhHUcQC6InwhglOk)dY)5bvrtTIDHCsEjzS4D4e20dOeeaQOPwXY3GCnJn9aQnav0uRy5BqUMXiOlTaqhaubNfuDj82mOk22vh3AeoXrozf7cWq3c0(qxbvoDXgRdJfuL)b5)8G68ak0BCcXY3GCnJ50fBSgqTbOwbOYDB6TiXUqojVKmw8oCc)SIFjcqlbqhfqTbOtBZUy)wWpGwEaqThqjiau5Un9wKyxiNKxsglEhoHFwXVebOLhaubokGAjGsqaOwbOqVXjelFdY1mMtxSXAa1gGk3TP3IelFdY1m(zf)seGwcGsk1aQnaDAB2f73c(b0YdaQabuccavUBtVfjw(gKRz8Zk(LiaT8aGkWrbuldQUeEBgujn(RppJBn6Lg)lCkadDlqbg6kOYPl2yDySGQ8pi)NhuL720BrIDHCsEjzS4D4e(zf)seGwcGsk1aQnaDAB2f73c(b0YdaQ9akbbGc9gNqS8nixZyoDXgRbuBaQC3MElsS8nixZ4Nv8lraAjakPudO2a0PTzxSFl4hqlpaOceqjiau5Un9wKyxiNKxsglEhoHFwXVebOLhaubokGsqaOYDB6TiXY3GCnJFwXVebOLhauboAq1LWBZGAX(nTq(Y4ZOn9uYbyOBboAORGkNUyJ1HXcQY)G8FEq1kaDEa99thzHCcXUwJWCPoeebOeea67NoYc5eIDTgHVeqldO2pdqjiauup3ArO)KmeH1NWl5icUVcGwEaq7aqTeqTbOZdOwbOIMAf7c5K8sYyX7WjSPhqjiaurtTILVb5AgB6bulbuBaQvaQC3MElsSyZ1CCRXryqWtY4Nv8lraAzaLuQb0rcO2dO2au5Un9wK4ry0KkCcXpR4xIa0YakPudOJeqThqTmO6s4TzqTUsdI1rV04)GCuKDLam0Tal9HUcQC6InwhglOk)dY)5bvRaurtTIDHCsEjzS4D4e20dOeeaQOPwXY3GCnJn9aQnav0uRy5BqUMXiOlTaqhaubNbOwcO2a0PTzxSFl4hqlzaqTpO6s4TzqvHv23U4wJnJ80r9ZUckadDlWsxORGkNUyJ1HXcQY)G8FEq1kaDEa99thzHCcXUwJWCPoeebOeea67NoYc5eIDTgHVeqldO2pdqjiauup3ArO)KmeH1NWl5icUVcGwEaq7aqTmO6s4TzqT38x1UljJInhbdWamadWamea]] )


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
