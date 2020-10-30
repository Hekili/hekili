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


    spec:RegisterPack( "Retribution", 20201030, [[dCK6Jbqifv9ijKQ2eLYNieQgfLWPOKSkPs1RuuzwusTlO(LIsdtH6yesltc6zsGPri6AkK2gHG8njKY4ieY5ieO1riu08Ou19uW(KkoiHGsTqffpKqqrxucPs(OesL6KsivSsjuZKqqj7uH4NecQAOecQSucHspLetvQKVsiOWyjekSxb)vObJ0HPAXe8yIMmPUmQnlPpJOrRiNwvRwQuEnLOzlLBts7w0VvA4svhNqalxLNdz6axNITtO(UenEjeNNsL1lHK5JW(bDq0qxbfTd4WifoUWXIoUGXyrhx4yrhnOaSRNdk9U0sNKdkPRYbfrSm4Ebd43mO0721wxh6kOGwZj5GsqrW8nqrNmieu0oGdJu44chl64cgJfDCHJhlIckOEwggPOnoOm9AnNbHGIMrYGsrpKkILb3lya)MqQiCEZ1FclUOhsfHxcwb(G0cgBnKw44chhu6VT(noOu0dPIyzW9cgWVjKkcN3C9NWIl6Hur4LGvGpiTGXwdPfoUWXWIHf7sWVjc3FSCvfCWCdZ6N0toc274ealgsHfx0dPfDvewAaSgszX8zhKcEvgsbtmK6sWEq6JGuxS)nxOXyyXUe8BIgowWyjdl2LGFt0CdZk9wl6sWVzS9iG1PRYdYDB6TmrWIDj43en3WSsV1IUe8BgBpcyD6Q8ajN85G9qWIHuyXUe8BIWYDB6Tmrd9l4306VoyHGPwXcTD1ndcGp2LaccbtTIDXCs(jzS8CWe20BtWuRyxmNKFsglphmHpw1)e1rurebHGPwXYZGCnJn92em1kwEgKRz8XQ(Ni7lCuRGf7sWVjcl3TP3Yen3WSTNCcGIDZOjv5ey9xhq9CRfb(rYaeU9KtauSBgnPkNGodfsqyX8N)6ilMta21AeMlYJaicIZFDKfZja7Anc)zNI2Owbl2LGFtewUBtVLjAUHzR)XcTD1w)1bbtTIDXCs(jzS8CWe20tqiyQvS8mixZytVnbtTILNb5AgJaU0Ybrhdl2LGFtewUBtVLjAUHzrtp30XTgfZjj7PKHf7sWVjcl3TP3Yen3WSgehFaRAD6Q8W5fL2KwIIcpz8yDuWaaBcl2LGFtewUBtVLjAUHznio(aw160v5bhnj2tgfpVO2lk3ZBw)1bnlyQv85f1Er5EElQzbtTI1BzsqyHGPwXUyoj)KmwEoycFSQ)jQZqHJjiem1kwEgKRzmc4slheDSnbtTILNb5AgFSQ)jQJOJALnlK720BzIjn(PFpJBn6ffFlycFSQ)jQJi4yccGFKmadEvoc2O(z7lymbX8mcXPKXYn1CIyDS9vUUNKXQE32ZkyXUe8BIWYDB6TmrZnmRbXXhWQwNUkp0ngfN2YgFw)1bbtTIDXCs(jzS8CWe20tqiyQvS8mixZytVnbtTILNb5AgJaU0Ybrhdl2LGFtewUBtVLjAUHznio(aw160v5bXV3IBn65R6awhfA7QT(RdwiyQvSlMtYpjJLNdMWMEccbtTILNb5AgB6TjyQvS8mixZ4Jv9pr2lQiYkcclK720BzIDXCs(jzS8CWe(yv)tuNcgtqi3TP3YelpdY1m(yv)tuNcgBfSyxc(nry5Un9wMO5gM1G44dyvRtxLh07QIIvZzN1FDqWuRyxmNKFsglphmHn9eecMAflpdY1m20BtWuRy5zqUMXhR6FISxureSyxc(nry5Un9wMO5gM1G44dyvRtxLhi9gl9wJpuuGDlT(RdcMAf7I5K8tYy55GjSPNGqWuRy5zqUMXMEBcMAflpdY1m(yv)tK9IokSyxc(nry5Un9wMO5gM1G44dyvRtxLheSJCtokWC0BQE6sR)6GGPwXUyoj)KmwEoycB6jiem1kwEgKRzSPhwSlb)MiSC3MElt0CdZAqC8bSQ1PRYdQ8XwcMCuS6jP1FDWI5p)1rwmNaSR1imxKhbqeeN)6ilMta21Ae(ZoIoQveeOEU1Ia)izacRFXFYreyp1odfcl2LGFtewUBtVLjAUHznio(aw160v5H(Mj18jW(PrXAZrwA9xhem1k2fZj5NKXYZbtytpbHGPwXYZGCnJn92em1kwEgKRzmc4sl7mi6ycc5Un9wMyxmNKFsglphmHpw1)e1rKJsqmVGPwXYZGCnJn92K720BzILNb5AgFSQ)jQJihfwSlb)MiSC3MElt0CdZAqC8bSQ1PRYdc8H4Zs(qXUz6MX6VoiyQvSlMtYpjJLNdMWMEccbtTILNb5AgB6TjyQvS8mixZyeWLw2zq0XeeYDB6TmXUyoj)KmwEoycFSQ)jQJihLGyEbtTILNb5AgB6Tj3TP3YelpdY1m(yv)tuhrokSyxc(nry5Un9wMO5gM1G44dyvRtxLh4u3yekc(ucmhh3ASEUe8B6Ty)wYN1FDqWuRyxmNKFsglphmHn9eecMAflpdY1m20BtWuRy5zqUMXiGlTSZGOJjiK720BzIDXCs(jzS8CWe(yv)tuhrokbHC3MEltS8mixZ4Jv9prDe5OWIDj43eHL720BzIMBywdIJpGvToDvEON9Rf1Vy(qr5Q27iK1FDqWuRyxmNKFsglphmHn9eecMAflpdY1m20BtWuRy5zqUMXiGlTSZGOJHf7sWVjcl3TP3Yen3WSgehFaRAD6Q8q9peiQ6agfr92r2CeY6VoiyQvSlMtYpjJLNdMWMEccbtTILNb5AgB6TjyQvS8mixZ4Jv9pr2pi6OWIDj43eHL720BzIMBywdIJpGvToDvEqU3z6bSos2C97G9qrvw7T2VP1FDqWuRyxmNKFsglphmHn9eecMAflpdY1m20BtWuRy5zqUMXhR6FISVWXWIDj43eHL720BzIMBywdIJpGvToDvEqU3z6bSos2C97G9qrbxtYw)1bbtTIDXCs(jzS8CWe20tqiyQvS8mixZytVnbtTILNb5AgFSQ)jYErhfwSlb)MiSC3MElt0CdZAqC8bSQ1PRYdL3dM(KmIysvobXTg1hJaoPdMGf7sWVjcl3TP3Yen3WSgehFaRAD6Q8aAALwk8a(qXQNKw)1bbtTIDXCs(jzS8CWe20tqiyQvS8mixZytpSyxc(nry5Un9wMO5gM1G44dyvRtxLhAV4pjJ73IspFeGpyXUe8BIWYDB6TmrZnmRbXXhWQwNUkpCpW4TyLDWeFXTgnzsgDlT(RdcMAf7I5K8tYy55GjSPNGqWuRy5zqUMXMEBcMAflpdY1mgbCPLdIoMGqUBtVLj2fZj5NKXYZbt4Jv9prDgkymbHC3MEltS8mixZ4Jv9prDgkymSyxc(nry5Un9wMO5gM1G44dyvRtxLhowDbCK08ApLCuZIFjdl2LGFtewUBtVLjAUHznio(aw160v5bXV3IBnIa7PIGf7sWVjcl3TP3Yen3WSgehFaRAD6Q8q50FTYpjrX(Mr1jzR)6GGPwXUyoj)KmwEoycB6jiem1kwEgKRzSP3MGPwXYZGCnJpw1)ez)qHJHf7sWVjcl3TP3Yen3WSgehFaRAD6Q8G(yxhjBU(DWEOOGRjzR)6GGPwXUyoj)KmwEoycB6jiem1kwEgKRzSP3MGPwXYZGCnJpw1)ez)qHJHf7sWVjcl3TP3Yen3WSgehFaRAD6Q8G(yxhDu)FEcqrvw7T2VP1FDqWuRyxmNKFsglphmHn9eecMAflpdY1m20BtWuRy5zqUMXhR6FISFOWXWIDj43eHL720BzIMBywdIJpGvToDvEG82Kef7Vx1BXZjzR)6W8cMAf7I5K8tYy55GjSP328cMAflpdY1m20dl2LGFtewUBtVLjAUHznio(aw160v5b0NpcWxKS563b7HIcUMKT(RdcMAf7I5K8tYy55GjSPNGqWuRy5zqUMXMEBcMAflpdY1m(yv)tK9dIokSyxc(nry5Un9wMO5gM1G44dyvRtxLhqF(iaFrYMRFhShkQYAV1(nT(RdcMAf7I5K8tYy55GjSPNGqWuRy5zqUMXMEBcMAflpdY1m(yv)tK9dfogwSlb)MiSC3MElt0CdZAqC8bSQ1PRYdErHM8ZrX6MG4wJ9BjFw)1H5bEJtawEgKRzmNUqJ12K720BzIDXCs(jzS8CWe(yv)tK9Jsqa8gNaS8mixZyoDHgRTj3TP3YelpdY1m(yv)tK9JAd8QChrhtqmTn7I9BjFDgkWg4vz7fDSnG34eGlDl54wJoAIryoDHgRHf7sWVjcl3TP3Yen3WSgehFaRAD6Q8G4h9Bg3AuZQpIT(RdcMAf7I5K8tYy55GjSPNGqWuRy5zqUMXMEBcMAflpdY1mgbCPLdIoMGqUBtVLj2fZj5NKXYZbt4Jv9prDgkymbHC3MEltS8mixZ4Jv9prDgkymSyxc(nry5Un9wMO5gM1G44dyvRtxLhC0Kypzu88IAVOCpVz9xh0SGPwXNxu7fL75TOMfm1kwVLjbHfcMAf7I5K8tYy55Gj8XQ(NOodfoMGqWuRy5zqUMXiGlTCq0X2em1kwEgKRz8XQ(NOoIoQv2SqUBtVLjM04N(9mU1Oxu8TGj8XQ(NOoIGJjiaVkhbBu)S9fmMGyEgH4uYy5MAorSo2(kx3tYyvVB7zfSyxc(nry5Un9wMO5gM1G44dyvRtxLhSmxqCRrpLpNGy1C2z9xhem1k2fZj5NKXYZbtytpbHGPwXYZGCnJn92em1kwEgKRzmc4sl7mi6ycc5Un9wMyxmNKFsglphmHpw1)e1PGXeeZlyQvS8mixZytVn5Un9wMy5zqUMXhR6FI6uWyyXUe8BIWYDB6TmrZnmRlMtYpjJLNdMS(RdwmTn7I9BjFDgePnWRY2pkbX02Sl2VL81zOaBGxL7mkbbWBCcWtBZUOlMts(WC6cnwBtUBtVLjEAB2fDXCsYh(yv)t0WyRSbEvoc24up5WyyXUe8BIWYDB6TmrZnmR8mixZw)1blM2MDX(TKVodI0g4vz7hLGyAB2f73s(6muGnWRYDgLGa4nob4PTzx0fZjjFyoDHgRTj3TP3YepTn7IUyoj5dFSQ)jAySv2aVkhbBCQNCymSyxc(nry5Un9wMO5gM1rtCgN8wBlHf7sWVjcl3TP3Yen3WStBZUOlMts(S(RdGxLJGno1tom2MfwiyQvSlMtYpjJLNdMWMEccbtTILNb5AgB6TIGWcbtTIDXCs(jzS8CWewVLPn5Un9wMyxmNKFsglphmHpw1)e1rKJjiem1kwEgKRzSEltBYDB6TmXYZGCnJpw1)e1rKJTYkyXUe8BIWYDB6TmrZnmB9tVfpwA5MFsA9xhM2MDX(TKVodfytUBtVLj2fZj5NKXYZbt4Jv9prDiLABGxLJGno1tom2MfZd8gNamIpVF6vXC6cnwtqiyQvmIpVF6vXMERGf7sWVjcl3TP3Yen3WSGjoAsH1K6yDpjB9xhaVkB)qHeecMAfFS0YgJqX6EsgB6Hf7sWVjcl3TP3Yen3WScTD1XTgbtCKtw1oR)6GGPwXUyoj)KmwEoycB6jiem1kwEgKRzSP3MGPwXYZGCnJraxA5GOJHf7sWVjcl3TP3Yen3WSKg)0VNXTg9IIVfmz9xhMh4noby5zqUMXC6cnwBZc5Un9wMyxmNKFsglphmHpw1)ez)O2M2MDX(TKVodfqqi3TP3Ye7I5K8tYy55Gj8XQ(NOodICuRiiSa4noby5zqUMXC6cnwBtUBtVLjwEgKRz8XQ(Ni7jLABtBZUy)wYxNbrsqi3TP3YelpdY1m(yv)tuNbroQvWIDj43eHL720BzIMBy2Y9AAX8NXJrB6PKT(RdYDB6TmXUyoj)KmwEoycFSQ)jYEsP2202Sl2VL81zOaccG34eGLNb5AgZPl0yTn5Un9wMy5zqUMXhR6FISNuQTnTn7I9BjFDgejbHC3MEltSlMtYpjJLNdMWhR6FI6miYrjiK720BzILNb5AgFSQ)jQZGihfwSlb)MiSC3MElt0CdZwxPbX6Oxu89aokWUQ1FDWI5p)1rwmNaSR1imxKhbqeeN)6ilMta21Ae(ZofmMGa1ZTwe4hjdqy9l(toIa7P2zOqRSnVfcMAf7I5K8tYy55GjSPNGqWuRy5zqUMXMERSzHC3MEltSqZ1CCRXUzqGxY4Jv9prDiL6UxGn5Un9wM4Uz0KQCcWhR6FI6qk1DVaRGf7sWVjcl3TP3Yen3WSQS6E2f3ASzKVoQp2vrw)1blem1k2fZj5NKXYZbtytpbHGPwXYZGCnJn92em1kwEgKRzmc4slheDSv2M2MDX(TKp7hkawSlb)MiSC3MElt0CdZ2BUVA3NKrHMJaw)1blM)8xhzXCcWUwJWCrEearqC(RJSyobyxRr4p7uWyccup3ArGFKmaH1V4p5icSNANHcTcwmKcl2LGFteU(5JM4dn3WSI97DHgBD6Q8GgfLoc4cn2AXEZWdOEU1Ia)izacRFXFYreyp1odfsqiyQvmR2B3XEg73s(WMEBAwWuR4Uz0KQCcW6TmTjyQvS(f)jh7nx)IySEltccup3ArGFKmaH1V4p5icSNANHcTjyQvS8mixZytVnbtTILNb5AgJaU0s7fDmSyxc(nr46NpAIp0CdZI4Z7NEvR)6GfwmpWBCcWYZGCnJ50fAS2MGPwXUyoj)KmwEoycB6jiK720BzIDXCs(jzS8CWe(yv)tuNch1kcclem1kwEgKRzSPNGqUBtVLjwEgKRz8XQ(NOofoQvwzZI5bEJtaU(P3IhlTCZpjXC6cnwtqi3TP3Yex)0BXJLwU5NK4Jv9pr2l6yRSzX8aVXjaZfHLgWVzeXjGtjJ50fASMGqUBtVLjMlclnGFZiItaNsgFSQ)jYErhBLnWRYrWgN6jhgdl2LGFteU(5JM4dn3WSI9ueW8Oj(qXjxvLpR)6GfZd8gNaC9tVfpwA5MFsI50fASMGqUBtVLjU(P3IhlTCZpjXhR6FI6qk1Dx0XeeAwWuR46NElES0Yn)KeB6TYMfZd8gNamxewAa)MreNaoLmMtxOXAcc5Un9wMyUiS0a(nJiobCkz8XQ(NOoKsD3fDmbHMfm1kMlclnGFZiItaNsgB6TIGa1ZTwe4hjdqy9l(toIa7P2zOqyXUe8BIW1pF0eFO5gMLlclnGFZiItaNs26VoG65wlc8JKbiS(f)jhrG9uTFOaBwyX8aVXjalpdY1mMtxOXAccbtTILNb5AgR3Y0MC3MEltS8mixZ4Jv9prDeDSveecMAflpdY1mgbCPLDgkGGqUBtVLj2fZj5NKXYZbt4Jv9prDeDmbHMfm1kU(P3IhlTCZpjXMERSbEvoc24up5WyyXUe8BIW1pF0eFO5gMv)I)KJiWEQw)1bX(9UqJXAuu6iGl0yBZlyQvSypfbmpAIpuCYvv5dB6TzHfZd8gNaS8mixZyoDHgRjiK720BzILNb5AgFSQ)jQdPu39cSYMfZd8gNamxewAa)MreNaoLmMtxOXAcc5Un9wMyUiS0a(nJiobCkz8XQ(NOoKsD3lGGa1ZTwe4hjdqy9l(toIa7P2zOaRiiq9CRfb(rYaew)I)KJiWEQDgk0MfaVXjapTn7IUyoj5dZPl0yTn5Un9wM4PTzx0fZjjF4Jv9pr2tk1DVaccbtTILNb5AgB6TjyQvS8mixZyeWLwAVOJTYkyXUe8BIW1pF0eFO5gMfWQ9n)qrX8PFjW6VoyX8aVXjalpdY1mMtxOXAcc5Un9wMy5zqUMXhR6FI6qk1DVaRSzX8aVXjaZfHLgWVzeXjGtjJ50fASMGqUBtVLjMlclnGFZiItaNsgFSQ)jQdPu39cSH65wlc8JKbiS(f)jhrG9uTFOaRSzX8aVXjax)0BXJLwU5NKyoDHgRjiK720BzIRF6T4Xsl38ts8XQ(NOoKsD3lWkBwmVCfZPNaCYYBB7PXC6cnwtqi3TP3Yel2traZJM4dfNCvv(WhR6FI6qk1wrqa8gNa802Sl6I5KKpmNUqJ12K720BzIN2MDrxmNK8Hpw1)ezpPu39ciiem1kEAB2fDXCsYh20tqiyQvS8mixZytVnbtTILNb5AgJaU0s7fDmbHGPwXI9ueW8Oj(qXjxvLpSPhwmKcl2LGFteMKt(CWEO5gMv6Tw0LGFZy7raRtxLhQF(Oj(qw)1HPTzxSFl5RZWOeecMAfpTn7IUyoj5dB6ji0SGPwX1p9w8yPLB(jj20tqOzbtTI5IWsd43mI4eWPKXMEyXUe8BIWKCYNd2dn3WScngH(KmU1iYOQYhSyxc(nryso5Zb7HMBywHgJqFsg3A0naJAcl2LGFteMKt(CWEO5gMvOXi0NKXTgl)eWhSyxc(nryso5Zb7HMBywHgJqFsg3Ae1FFscl2LGFteMKt(CWEO5gMv)I)KJGT1S(RdZRzbtTI7MrtQYjaB6TzX8N)6ilMta21AeMlYJaicIZFDKfZja7Anc)zNcgBLnlM2MDX(TKp7hkKGyAB2f73s(SFqK2SqUBtVLjwO5AoU1y3miWlz8XQ(NOoKsD3lKGqZcMAfZfHLgWVzeXjGtjJn9eeAwWuR46NElES0Yn)KeB6TYkBwmpWBCcW1p9w8yPLB(jjMtxOXAcc5Un9wM46NElES0Yn)KeFSQ)jQdPu3DrhBLnlMh4nobyUiS0a(nJiobCkzmNUqJ1eeYDB6TmXCryPb8BgrCc4uY4Jv9prDiL6Ul6yRGf7sWVjctYjFoyp0CdZw6wYXTgD0eJS(RdwmTn7I9BjFdJjiM2MDX(TKp7hk0MfYDB6TmXcnxZXTg7MbbEjJpw1)e1HuQ7EHeeAwWuRyUiS0a(nJiobCkzSPNGqZcMAfx)0BXJLwU5NKytVvwzZI5p)1rwmNaSR1imxKhbqeeN)6ilMta21Ae(Zofo2kBwmpWBCcWCryPb8BgrCc4uYyoDHgRjiK720BzI5IWsd43mI4eWPKXhR6FI6i6OwzZI5bEJtaU(P3IhlTCZpjXC6cnwtqi3TP3Yex)0BXJLwU5NK4Jv9prDeDuRGf7sWVjctYjFoyp0CdZk0Cnh3ASBge4LS1FDyAB2f73s(SFOayXUe8BIWKCYNd2dn3WStUQkFXTglphmz9xhM2MDX(TKp7hejSyxc(nryso5Zb7HMBy2Uz0KQCcS(RdZRzbtTI7MrtQYjaB6TzX02Sl2VL8z)qHeetBZUy)wYN9dI0MC3MEltSqZ1CCRXUzqGxY4Jv9prDiL6UxOvWIDj43eHj5KphShAUHzLERfDj43m2EeW60v5H6NpAIpK1FDWcGFKmapXEdmH7La7hkCmbHGPwXUyoj)KmwEoycB6jiem1kwEgKRzSPNGqWuRywT3UJ9m2VL8Hn9wbl2LGFteMKt(CWEO5gMvEgKR5lIa3BjB9xhK720BzILNb5A(IiW9wYy5KFKmkwpxc(n9wNbrXfTrTzX02Sl2VL8z)qHeetBZUy)wYN9dfytUBtVLjwO5AoU1y3miWlz8XQ(NOoKsD3lKGyAB2f73s(gePn5Un9wMyHMR54wJDZGaVKXhR6FI6qk1DVqBYDB6TmXDZOjv5eGpw1)e1HuQ7EHwbl2LGFteMKt(CWEO5gMv6Tw0LGFZy7raRtxLhQF(Oj(qWIDj43eHj5KphShAUHzLNb5A(IiW9wYw)1HPTzxSFl5Z(brcl2LGFteMKt(CWEO5gMvUPKtW5awhRnxLHf7sWVjctYjFoyp0CdZES3)jzS2Cvgz9xha(rYa8e7nWuSxc6iIgtqa8JKb4j2BGPyVeyFHJjiQp5eiESQ)jY(cgfwSlb)MimjN85G9qZnmRFsp5iyVJtG1FDyAB2f73s(SFqKWIDj43eHj5KphShAUHzLBIy55GFtR)6a4v5iyJt9KDiL6GIy(q)MHrkCCHJfDSOfeuk9l)KefueHHiSfXosrNrk6wetifs7AIH0xTFpaKw3dsfXRF(Oj(qI4q6XIaM)ynKIwvgsDdyvDaRHu5KNKmcdlwewFYqQiKiMqQim3umFawdPI4YvmNEcWIyG50fASwehsblKkIlxXC6jalIHioKAHOfXkmSyyXfDu73dWAiDui1LGFtiT9iacdloO0Eeaf6kOO5QBAGqxHren0vqXLGFZGYXcgl5GcNUqJ1HzcGWifg6kOWPl0yDyMGIlb)MbfP3Arxc(nJThbckThbIPRYbf5Un9wMOaimsbHUckC6cnwhMjO4sWVzqr6Tw0LGFZy7rGGs7rGy6QCqHKt(CWEOaiack9hlxvbhe6kmIOHUckUe8Bgu8t6jhb7DCcckC6cnwhMjacGGcjN85G9qHUcJiAORGcNUqJ1HzckY7b89EqzAB2f73s(G0odq6OqkbbKkyQv802Sl6I5KKpSPhsjiGunlyQvC9tVfpwA5MFsIn9qkbbKQzbtTI5IWsd43mI4eWPKXM(GIlb)MbfP3Arxc(nJThbckThbIPRYbL6NpAIpuaegPWqxbfxc(ndkcngH(KmU1iYOQYxqHtxOX6WmbqyKccDfuCj43mOi0ye6tY4wJUbyuZGcNUqJ1HzcGWiIm0vqXLGFZGIqJrOpjJBnw(jGVGcNUqJ1HzcGWiJg6kO4sWVzqrOXi0NKXTgr93NKbfoDHgRdZeaHreHcDfu40fASomtqrEpGV3dkZdPAwWuR4Uz0KQCcWMEi1gKAbKopKE(RJSyobyxRryUipcGGucci98xhzXCcWUwJWFcPDG0cgdPwbP2GulG0PTzxSFl5dsTFaslesjiG0PTzxSFl5dsTFasfjKAdsTasL720BzIfAUMJBn2ndc8sgFSQ)jcs7aPKsnK2DiTqiLGas1SGPwXCryPb8BgrCc4uYytpKsqaPAwWuR46NElES0Yn)KeB6HuRGuRGuBqQfq68qkWBCcW1p9w8yPLB(jjMtxOXAiLGasL720BzIRF6T4Xsl38ts8XQ(NiiTdKsk1qA3HurhdPwbP2GulG05HuG34eG5IWsd43mI4eWPKXC6cnwdPeeqQC3MEltmxewAa)MreNaoLm(yv)teK2bsjLAiT7qQOJHuRckUe8Bgu0V4p5iyBTaimsrl0vqHtxOX6Wmbf59a(EpOybKoTn7I9BjFq6aKogsjiG0PTzxSFl5dsTFaslesTbPwaPYDB6TmXcnxZXTg7MbbEjJpw1)ebPDGusPgs7oKwiKsqaPAwWuRyUiS0a(nJiobCkzSPhsjiGunlyQvC9tVfpwA5MFsIn9qQvqQvqQni1ciDEi98xhzXCcWUwJWCrEeabPeeq65VoYI5eGDTgH)es7aPfogsTcsTbPwaPZdPaVXjaZfHLgWVzeXjGtjJ50fASgsjiGu5Un9wMyUiS0a(nJiobCkz8XQ(NiiTdKk6OqQvqQni1ciDEif4nob46NElES0Yn)KeZPl0ynKsqaPYDB6TmX1p9w8yPLB(jj(yv)teK2bsfDui1QGIlb)MbLs3soU1OJMyuaegref6kOWPl0yDyMGI8EaFVhuM2MDX(TKpi1(biTGGIlb)MbfHMR54wJDZGaVKdGWiIGHUckC6cnwhMjOiVhW37bLPTzxSFl5dsTFasfzqXLGFZGYKRQYxCRXYZbtbqyerhh6kOWPl0yDyMGI8EaFVhuMhs1SGPwXDZOjv5eGn9qQni1ciDAB2f73s(Gu7hG0cHucciDAB2f73s(Gu7hGurcP2Gu5Un9wMyHMR54wJDZGaVKXhR6FIG0oqkPudPDhslesTkO4sWVzqPBgnPkNGaimIOIg6kOWPl0yDyMGI8EaFVhuSasb(rYa8e7nWeUxcGu7hG0chdPeeqQGPwXUyoj)KmwEoycB6HuccivWuRy5zqUMXMEiLGasfm1kMv7T7ypJ9BjFytpKAvqXLGFZGI0BTOlb)MX2JabL2JaX0v5Gs9ZhnXhkacJiAHHUckC6cnwhMjOiVhW37bf5Un9wMy5zqUMVicCVLmwo5hjJI1ZLGFtVbPDgGurXfTrHuBqQfq602Sl2VL8bP2paPfcPeeq602Sl2VL8bP2paPfaP2Gu5Un9wMyHMR54wJDZGaVKXhR6FIG0oqkPudPDhslesjiG0PTzxSFl5dshGurcP2Gu5Un9wMyHMR54wJDZGaVKXhR6FIG0oqkPudPDhslesTbPYDB6TmXDZOjv5eGpw1)ebPDGusPgs7oKwiKAvqXLGFZGI8mixZxebU3soacJiAbHUckC6cnwhMjO4sWVzqr6Tw0LGFZy7rGGs7rGy6QCqP(5JM4dfaHrevKHUckC6cnwhMjOiVhW37bLPTzxSFl5dsTFasfzqXLGFZGI8mixZxebU3soacJi6OHUckUe8BguKBk5eCoG1XAZv5GcNUqJ1HzcGWiIkcf6kOWPl0yDyMGI8EaFVhua(rYa8e7nWuSxcG0oqQiAmKsqaPa)izaEI9gyk2lbqQ9qAHJHucciT(KtG4XQ(Nii1EiTGrdkUe8Bguo27)KmwBUkJcGWiIw0cDfu40fASomtqrEpGV3dktBZUy)wYhKA)aKkYGIlb)Mbf)KEYrWEhNGaimIOIOqxbfoDHgRdZeuK3d479Gc4v5iyJt9KqAhiLuQdkUe8BguKBIy55GFZaiack1pF0eFOqxHren0vqHtxOX6WmbLTpOGyqqXLGFZGIy)ExOXbfXEZWbfup3ArGFKmaH1V4p5icSNkK2zaslesjiGubtTIz1E7o2Zy)wYh20dP2GunlyQvC3mAsvoby9wMqQnivWuRy9l(to2BU(fXy9wMqkbbKI65wlc8JKbiS(f)jhrG9uH0odqAHqQnivWuRy5zqUMXMEi1gKkyQvS8mixZyeWLwcP2dPIooOi2Vy6QCqrJIshbCHghaHrkm0vqHtxOX6Wmbf59a(EpOybKAbKopKc8gNaS8mixZyoDHgRHuBqQGPwXUyoj)KmwEoycB6HuccivUBtVLj2fZj5NKXYZbt4Jv9prqAhiTWrHuRGucci1civWuRy5zqUMXMEiLGasL720BzILNb5AgFSQ)jcs7aPfokKAfKAfKAdsTasNhsbEJtaU(P3IhlTCZpjXC6cnwdPeeqQC3MEltC9tVfpwA5MFsIpw1)ebP2dPIogsTcsTbPwaPZdPaVXjaZfHLgWVzeXjGtjJ50fASgsjiGu5Un9wMyUiS0a(nJiobCkz8XQ(Nii1Eiv0XqQvqQnif8QCeSXPEsiDashhuCj43mOG4Z7NE1aimsbHUckC6cnwhMjOiVhW37bflG05HuG34eGRF6T4Xsl38tsmNUqJ1qkbbKk3TP3Yex)0BXJLwU5NK4Jv9prqAhiLuQH0UdPIogsjiGunlyQvC9tVfpwA5MFsIn9qQvqQni1ciDEif4nobyUiS0a(nJiobCkzmNUqJ1qkbbKk3TP3YeZfHLgWVzeXjGtjJpw1)ebPDGusPgs7oKk6yiLGas1SGPwXCryPb8BgrCc4uYytpKAfKsqaPOEU1Ia)izacRFXFYreypviTZaKwyqXLGFZGIypfbmpAIpuCYvv5lacJiYqxbfoDHgRdZeuK3d479GcQNBTiWpsgGW6x8NCeb2tfsTFaslasTbPwaPwaPZdPaVXjalpdY1mMtxOXAiLGasfm1kwEgKRzSElti1gKk3TP3YelpdY1m(yv)teK2bsfDmKAfKsqaPcMAflpdY1mgbCPLqANbiTaiLGasL720BzIDXCs(jzS8CWe(yv)teK2bsfDmKsqaPAwWuR46NElES0Yn)KeB6HuRGuBqk4v5iyJt9Kq6aKooO4sWVzqHlclnGFZiItaNsoacJmAORGcNUqJ1HzckY7b89EqrSFVl0ySgfLoc4cngsTbPZdPcMAfl2traZJM4dfNCvv(WMEi1gKAbKAbKopKc8gNaS8mixZyoDHgRHuccivUBtVLjwEgKRz8XQ(NiiTdKsk1qA3H0cGuRGuBqQfq68qkWBCcWCryPb8BgrCc4uYyoDHgRHuccivUBtVLjMlclnGFZiItaNsgFSQ)jcs7aPKsnK2DiTaiLGasr9CRfb(rYaew)I)KJiWEQqANbiTai1kiLGasr9CRfb(rYaew)I)KJiWEQqANbiTqi1gKAbKc8gNa802Sl6I5KKpmNUqJ1qQnivUBtVLjEAB2fDXCsYh(yv)teKApKsk1qA3H0cGuccivWuRy5zqUMXMEi1gKkyQvS8mixZyeWLwcP2dPIogsTcsTkO4sWVzqr)I)KJiWEQbqyerOqxbfoDHgRdZeuK3d479GIfq68qkWBCcWYZGCnJ50fASgsjiGu5Un9wMy5zqUMXhR6FIG0oqkPudPDhslasTcsTbPwaPZdPaVXjaZfHLgWVzeXjGtjJ50fASgsjiGu5Un9wMyUiS0a(nJiobCkz8XQ(NiiTdKsk1qA3H0cGuBqkQNBTiWpsgGW6x8NCeb2tfsTFaslasTcsTbPwaPZdPaVXjax)0BXJLwU5NKyoDHgRHuccivUBtVLjU(P3IhlTCZpjXhR6FIG0oqkPudPDhslasTcsTbPwaPZdPYvmNEcWjlVTTNgsjiGu5Un9wMyXEkcyE0eFO4KRQYh(yv)teK2bsjLAi1kiLGasbEJtaEAB2fDXCsYhMtxOXAi1gKk3TP3YepTn7IUyoj5dFSQ)jcsThsjLAiT7qAbqkbbKkyQv802Sl6I5KKpSPhsjiGubtTILNb5AgB6HuBqQGPwXYZGCnJraxAjKApKk6yiLGasfm1kwSNIaMhnXhko5QQ8Hn9bfxc(ndkawTV5hkkMp9lbbqaeuK720BzIcDfgr0qxbfoDHgRdZeuK3d479GIfqQGPwXcTD1ndcGp2LaiLGasfm1k2fZj5NKXYZbtytpKAdsfm1k2fZj5NKXYZbt4Jv9prqAhivureKsqaPcMAflpdY1m20dP2GubtTILNb5AgFSQ)jcsThslCui1QGIlb)MbL(f8BgaHrkm0vqHtxOX6Wmbf59a(EpOG65wlc8JKbiC7jNaOy3mAsvobqANbiTqiLGasTasNhsp)1rwmNaSR1imxKhbqqkbbKE(RJSyobyxRr4pH0oqArBui1QGIlb)MbL2tobqXUz0KQCccGWife6kOWPl0yDyMGI8EaFVhuem1k2fZj5NKXYZbtytpKsqaPcMAflpdY1m20dP2GubtTILNb5AgJaU0siDasfDCqXLGFZGs9pwOTRoacJiYqxbfxc(ndkOPNB64wJI5KK9uYbfoDHgRdZeaHrgn0vqHtxOX6WmbL0v5GY5fL2KwIIcpz8yDuWaaBguCj43mOCErPnPLOOWtgpwhfmaWMbqyerOqxbfoDHgRdZeuCj43mO4OjXEYO45f1Er5EElOiVhW37bfnlyQv85f1Er5EElQzbtTI1BzcPeeqQfqQGPwXUyoj)KmwEoycFSQ)jcs7maPfogsjiGubtTILNb5AgJaU0siDasfDmKAdsfm1kwEgKRz8XQ(NiiTdKk6OqQvqQni1civUBtVLjM04N(9mU1Oxu8TGj8XQ(NiiTdKkcogsjiGuGFKmadEvoc2O(zi1EiTGXqkbbKopKYieNsgl3uZjI1X2x56EsgR6DBpi1QGs6QCqXrtI9KrXZlQ9IY98waegPOf6kOWPl0yDyMGIlb)MbLUXO40w24lOiVhW37bfbtTIDXCs(jzS8CWe20dPeeqQGPwXYZGCnJn9qQnivWuRy5zqUMXiGlTeshGurhhusxLdkDJrXPTSXxaegref6kOWPl0yDyMGIlb)MbfXV3IBn65R6awhfA7QdkY7b89EqXcivWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAdsfm1kwEgKRz8XQ(Nii1EivureKAfKsqaPwaPYDB6TmXUyoj)KmwEoycFSQ)jcs7aPfmgsjiGu5Un9wMy5zqUMXhR6FIG0oqAbJHuRckPRYbfXV3IBn65R6awhfA7QdGWiIGHUckC6cnwhMjO4sWVzqrVRkkwnNDbf59a(EpOiyQvSlMtYpjJLNdMWMEiLGasfm1kwEgKRzSPhsTbPcMAflpdY1m(yv)teKApKkQikOKUkhu07QIIvZzxaegr0XHUckC6cnwhMjO4sWVzqH0BS0Bn(qrb2TmOiVhW37bfbtTIDXCs(jzS8CWe20dPeeqQGPwXYZGCnJn9qQnivWuRy5zqUMXhR6FIGu7HurhnOKUkhui9gl9wJpuuGDldGWiIkAORGcNUqJ1HzckUe8BgueSJCtokWC0BQE6YGI8EaFVhuem1k2fZj5NKXYZbtytpKsqaPcMAflpdY1m20husxLdkc2rUjhfyo6nvpDzaegr0cdDfu40fASomtqXLGFZGIkFSLGjhfREsguK3d479GIfq68q65VoYI5eGDTgH5I8iacsjiG0ZFDKfZja7Anc)jK2bsfDui1kiLGasr9CRfb(rYaew)I)KJiWEQqANbiTWGs6QCqrLp2sWKJIvpjdGWiIwqORGcNUqJ1HzckUe8Bgu6BMuZNa7NgfRnhzzqrEpGV3dkcMAf7I5K8tYy55GjSPhsjiGubtTILNb5AgB6HuBqQGPwXYZGCnJraxAjK2zasfDmKsqaPYDB6TmXUyoj)KmwEoycFSQ)jcs7aPICuiLGasNhsfm1kwEgKRzSPhsTbPYDB6TmXYZGCnJpw1)ebPDGuroAqjDvoO03mPMpb2pnkwBoYYaimIOIm0vqHtxOX6Wmbfxc(ndkc8H4Zs(qXUz6MjOiVhW37bfbtTIDXCs(jzS8CWe20dPeeqQGPwXYZGCnJn9qQnivWuRy5zqUMXiGlTes7maPIogsjiGu5Un9wMyxmNKFsglphmHpw1)ebPDGurokKsqaPZdPcMAflpdY1m20dP2Gu5Un9wMy5zqUMXhR6FIG0oqQihnOKUkhue4dXNL8HIDZ0ntaegr0rdDfu40fASomtqXLGFZGcN6gJqrWNsG544wJ1ZLGFtVf73s(ckY7b89EqrWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAdsfm1kwEgKRzmc4slH0odqQOJHuccivUBtVLj2fZj5NKXYZbt4Jv9prqAhivKJcPeeqQC3MEltS8mixZ4Jv9prqAhivKJgusxLdkCQBmcfbFkbMJJBnwpxc(n9wSFl5lacJiQiuORGcNUqJ1HzckUe8Bgu6z)Ar9lMpuuUQ9ocfuK3d479GIGPwXUyoj)KmwEoycB6HuccivWuRy5zqUMXMEi1gKkyQvS8mixZyeWLwcPDgGurhhusxLdk9SFTO(fZhkkx1EhHcGWiIw0cDfu40fASomtqXLGFZGs9peiQ6agfr92r2CekOiVhW37bfbtTIDXCs(jzS8CWe20dPeeqQGPwXYZGCnJn9qQnivWuRy5zqUMXhR6FIGu7hGurhnOKUkhuQ)HarvhWOiQ3oYMJqbqyerfrHUckC6cnwhMjO4sWVzqrU3z6bSos2C97G9qrvw7T2VzqrEpGV3dkcMAf7I5K8tYy55GjSPhsjiGubtTILNb5AgB6HuBqQGPwXYZGCnJpw1)ebP2dPfooOKUkhuK7DMEaRJKnx)oypuuL1ER9BgaHrevem0vqHtxOX6Wmbfxc(ndkY9otpG1rYMRFhShkk4AsoOiVhW37bfbtTIDXCs(jzS8CWe20dPeeqQGPwXYZGCnJn9qQnivWuRy5zqUMXhR6FIGu7HurhnOKUkhuK7DMEaRJKnx)oypuuW1KCaegPWXHUckC6cnwhMjOKUkhukVhm9jzeXKQCcIBnQpgbCshmfuCj43mOuEpy6tYiIjv5ee3AuFmc4KoykacJuOOHUckC6cnwhMjO4sWVzqbnTslfEaFOy1tYGI8EaFVhuem1k2fZj5NKXYZbtytpKsqaPcMAflpdY1m20husxLdkOPvAPWd4dfREsgaHrkSWqxbfoDHgRdZeusxLdkTx8NKX9BrPNpcWxqXLGFZGs7f)jzC)wu65Ja8faHrkSGqxbfoDHgRdZeuCj43mOCpW4TyLDWeFXTgnzsgDldkY7b89EqrWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAdsfm1kwEgKRzmc4slH0biv0XqkbbKk3TP3Ye7I5K8tYy55Gj8XQ(NiiTZaKwWyiLGasL720BzILNb5AgFSQ)jcs7maPfmoOKUkhuUhy8wSYoyIV4wJMmjJULbqyKcfzORGcNUqJ1HzckPRYbLJvxahjnV2tjh1S4xYbfxc(ndkhRUaosAETNsoQzXVKdGWifoAORGcNUqJ1HzckPRYbfXV3IBnIa7PIckUe8Bgue)ElU1icSNkkacJuOiuORGcNUqJ1HzckUe8BgukN(Rv(jjk23mQojhuK3d479GIGPwXUyoj)KmwEoycB6HuccivWuRy5zqUMXMEi1gKkyQvS8mixZ4Jv9prqQ9dqAHJdkPRYbLYP)ALFsII9nJQtYbqyKclAHUckC6cnwhMjO4sWVzqrFSRJKnx)oypuuW1KCqrEpGV3dkcMAf7I5K8tYy55GjSPhsjiGubtTILNb5AgB6HuBqQGPwXYZGCnJpw1)ebP2paPfooOKUkhu0h76izZ1Vd2dffCnjhaHrkuef6kOWPl0yDyMGIlb)Mbf9XUo6O()8eGIQS2BTFZGI8EaFVhuem1k2fZj5NKXYZbtytpKsqaPcMAflpdY1m20dP2GubtTILNb5AgFSQ)jcsTFaslCCqjDvoOOp21rh1)NNauuL1ER9BgaHrkuem0vqHtxOX6Wmbfxc(ndkK3MKOy)9QElEojhuK3d479GY8qQGPwXUyoj)KmwEoycB6HuBq68qQGPwXYZGCnJn9bL0v5Gc5Tjjk2FVQ3INtYbqyKcgh6kOWPl0yDyMGIlb)Mbf0NpcWxKS563b7HIcUMKdkY7b89EqrWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAdsfm1kwEgKRz8XQ(Nii1(biv0rdkPRYbf0NpcWxKS563b7HIcUMKdGWifiAORGcNUqJ1HzckUe8BguqF(iaFrYMRFhShkQYAV1(ndkY7b89EqrWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAdsfm1kwEgKRz8XQ(Nii1(biTWXbL0v5Gc6Zhb4ls2C97G9qrvw7T2VzaegPGcdDfu40fASomtqXLGFZGIxuOj)CuSUjiU1y)wYxqrEpGV3dkZdPaVXjalpdY1mMtxOXAi1gKk3TP3Ye7I5K8tYy55Gj8XQ(Nii1EiDuiLGasbEJtawEgKRzmNUqJ1qQnivUBtVLjwEgKRz8XQ(Nii1EiDui1gKcEvgs7aPIogsjiG0PTzxSFl5ds7maPfaP2GuWRYqQ9qQOJHuBqkWBCcWLULCCRrhnXimNUqJ1bL0v5GIxuOj)CuSUjiU1y)wYxaegPGccDfu40fASomtqXLGFZGI4h9Bg3AuZQpIdkY7b89EqrWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAdsfm1kwEgKRzmc4slH0biv0XqkbbKk3TP3Ye7I5K8tYy55Gj8XQ(NiiTZaKwWyiLGasL720BzILNb5AgFSQ)jcs7maPfmoOKUkhue)OFZ4wJAw9rCaegParg6kOWPl0yDyMGIlb)Mbfhnj2tgfpVO2lk3ZBbf59a(EpOOzbtTIpVO2lk3ZBrnlyQvSEltiLGasTasfm1k2fZj5NKXYZbt4Jv9prqANbiTWXqkbbKkyQvS8mixZyeWLwcPdqQOJHuBqQGPwXYZGCnJpw1)ebPDGurhfsTcsTbPwaPYDB6TmXKg)0VNXTg9IIVfmHpw1)ebPDGurWXqkbbKcEvoc2O(zi1EiTGXqkbbKopKYieNsgl3uZjI1X2x56EsgR6DBpi1QGs6QCqXrtI9KrXZlQ9IY98waegPGrdDfu40fASomtqXLGFZGIL5cIBn6P85eeRMZUGI8EaFVhuem1k2fZj5NKXYZbtytpKsqaPcMAflpdY1m20dP2GubtTILNb5AgJaU0siTZaKk6yiLGasL720BzIDXCs(jzS8CWe(yv)teK2bslymKsqaPZdPcMAflpdY1m20dP2Gu5Un9wMy5zqUMXhR6FIG0oqAbJdkPRYbflZfe3A0t5ZjiwnNDbqyKceHcDfu40fASomtqrEpGV3dkwaPtBZUy)wYhK2zasfjKAdsbVkdP2dPJcPeeq602Sl2VL8bPDgG0cGuBqk4vziTdKokKsqaPaVXjapTn7IUyoj5dZPl0ynKAdsL720BzIN2MDrxmNK8Hpw1)ebPdq6yi1ki1gKcEvoc24upjKoaPJdkUe8BguCXCs(jzS8CWuaegPGIwORGcNUqJ1HzckY7b89EqXciDAB2f73s(G0odqQiHuBqk4vzi1EiDuiLGasN2MDX(TKpiTZaKwaKAdsbVkdPDG0rHuccif4nob4PTzx0fZjjFyoDHgRHuBqQC3MElt802Sl6I5KKp8XQ(NiiDashdPwbP2GuWRYrWgN6jH0biDCqXLGFZGI8mixZbqyKcerHUckUe8BguC0eNXjV12YGcNUqJ1HzcGWificg6kOWPl0yDyMGI8EaFVhuaVkhbBCQNeshG0XqQni1ci1civWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAfKsqaPwaPcMAf7I5K8tYy55GjSElti1gKk3TP3Ye7I5K8tYy55Gj8XQ(NiiTdKkYXqkbbKkyQvS8mixZy9wMqQnivUBtVLjwEgKRz8XQ(NiiTdKkYXqQvqQvbfxc(ndktBZUOlMts(cGWiICCORGcNUqJ1HzckY7b89EqzAB2f73s(G0odqAbqQnivUBtVLj2fZj5NKXYZbt4Jv9prqAhiLuQHuBqk4v5iyJt9Kq6aKogsTbPwaPZdPaVXjaJ4Z7NEvmNUqJ1qkbbKkyQvmIpVF6vXMEi1QGIlb)MbL6NElES0Yn)KmacJisrdDfu40fASomtqrEpGV3dkGxLHu7hG0cHuccivWuR4JLw2yekw3tYytFqXLGFZGcyIJMuynPow3tYbqyerwyORGcNUqJ1HzckY7b89EqrWuRyxmNKFsglphmHn9qkbbKkyQvS8mixZytpKAdsfm1kwEgKRzmc4slH0biv0Xbfxc(ndkcTD1XTgbtCKtw1UaimIili0vqHtxOX6Wmbf59a(EpOmpKc8gNaS8mixZyoDHgRHuBqQfqQC3MEltSlMtYpjJLNdMWhR6FIGu7H0rHuBq602Sl2VL8bPDgG0cGuccivUBtVLj2fZj5NKXYZbt4Jv9prqANbivKJcPwbPeeqQfqkWBCcWYZGCnJ50fASgsTbPYDB6TmXYZGCnJpw1)ebP2dPKsnKAdsN2MDX(TKpiTZaKksiLGasL720BzILNb5AgFSQ)jcs7maPICui1QGIlb)MbfsJF63Z4wJErX3cMcGWiIuKHUckC6cnwhMjOiVhW37bf5Un9wMyxmNKFsglphmHpw1)ebP2dPKsnKAdsN2MDX(TKpiTZaKwaKsqaPaVXjalpdY1mMtxOXAi1gKk3TP3YelpdY1m(yv)teKApKsk1qQniDAB2f73s(G0odqQiHuccivUBtVLj2fZj5NKXYZbt4Jv9prqANbivKJcPeeqQC3MEltS8mixZ4Jv9prqANbivKJguCj43mOuUxtlM)mEmAtpLCaegrKJg6kOWPl0yDyMGI8EaFVhuSasNhsp)1rwmNaSR1imxKhbqqkbbKE(RJSyobyxRr4pH0oqAbJHuccif1ZTwe4hjdqy9l(toIa7PcPDgG0cHuRGuBq68qQfqQGPwXUyoj)KmwEoycB6HuccivWuRy5zqUMXMEi1ki1gKAbKk3TP3Yel0Cnh3ASBge4Lm(yv)teK2bsjLAiT7qAbqQnivUBtVLjUBgnPkNa8XQ(NiiTdKsk1qA3H0cGuRckUe8BguQR0GyD0lk(EahfyxnacJisrOqxbfoDHgRdZeuK3d479GIfqQGPwXUyoj)KmwEoycB6HuccivWuRy5zqUMXMEi1gKkyQvS8mixZyeWLwcPdqQOJHuRGuBq602Sl2VL8bP2paPfeuCj43mOOYQ7zxCRXMr(6O(yxffaHrezrl0vqHtxOX6Wmbf59a(EpOybKopKE(RJSyobyxRryUipcGGucci98xhzXCcWUwJWFcPDG0cgdPeeqkQNBTiWpsgGW6x8NCeb2tfs7maPfcPwfuCj43mO0BUVA3NKrHMJabqaeabf3aM2lOOicy4Md2lacGqaa]] )


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
