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
            max_stack = 6,
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


    spec:RegisterPack( "Retribution", 20201013, [[dCKuKbqifspsQuP2eL0NiesJIs0POewfHGxPOYSOuAxq(LIQgMIYXiKwMKONjjzAeIUMcvBJsv03OufghHqDoPsfRJqi08KeUNc2NuXbLkvsTqfkpuQuvQlkvQK8rPsvHtkvQeRusQzkvQkzNke)uQuv1qLkvvwkHq0tjXuLk5RsLQIglHqWEf8xHgmshMQftWJjAYK6YO2SeFgrJwroTQwTuP8AkfZwk3MK2TOFR0WLQoUuPklxLNd10bUofBNq9Dj14PuvNNsL1tPknFe2pOdIg6kOODahgPYzvot0zIwfAw3Ps7POIgua21ZbLExAJtYbL0v5GIisgCVGb8Bgu6D7ARRdDfuWR5KCqjOiy(gO7sgeckAhWHrQCwLZeDMOvHM1DQ0EoZEeuW9SmmI9ywqz61AodcbfnJLbLUBivejdUxWa(nH0UFEZ1FcRU7gs7(lbRaFqQOvzlKw5SkNfu6VT8noO0DdPIizW9cgWVjK29ZBU(ty1D3qA3Fjyf4dsfTkBH0kNv5my1WQDj43eJ6pwUQcoyUH59t6jhb7DCcGvdPWQ7UH0URSplnawdPSy(SdsbVkdPGjgsDjypi9XqQl2)Ml0yeSAxc(nXdhlySHHv7sWVjEUH5LERfDj43m2EmW20v5b5Un9wNyy1Ue8BINByEP3Arxc(nJThdSnDvEGKt(CWEyy1qkSAxc(nXi5Un9wN4H(f8BA7xgSuWukiH2U6Mbdqh7sabHGPuqUyoj)KmwFoycz6TkykfKlMtYpjJ1NdMqhR6FI7iQiMGqWuki5zWUMrMERcMsbjpd21m6yv)tCfvoUfWQDj43eJK720BDINBy(2tobWXUz0KQCcS9ld4EU1Ia)izag1EYjao2nJMuLtqNHkjiSC0ZFDKfZja5AngX2)XambX5VoYI5eGCTgJ(SJ9yClGv7sWVjgj3TP36ep3W8L)yH2UAB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAZGOZGv7sWVjgj3TP36ep3W84PNB64wII5KK9uYWQDj43eJK720BDINByEdMJpGvTnDvE4C7vBsBWrHNmESokyaGnHv7sWVjgj3TP36ep3W8gmhFaRAB6Q8GJNe7jJJNBV7fL75nB)YGMfmLc6C7DVOCpVf1SGPuq6TojiSuWukixmNKFsgRphmHow1)e3zOYzeecMsbjpd21mcdCPndIoZQGPuqYZGDnJow1)e3r0XTWQLYDB6TorKg)0VNXTeD7LVfmHow1)e3P7mJGa4hjdqGxLJGnQFUIQMrqmkJXCkzKCtnNywhBFHl7jzKQ3T9SawTlb)MyKC3MERt8CdZBWC8bSQTPRYdDJXXPTUXNTFzqWukixmNKFsgRphmHm9eecMsbjpd21mY0BvWuki5zWUMryGlTzq0zWQDj43eJK720BDINByEdMJpGvTnDvEq87T4wIE(QoG1rH2UAB)YGLcMsb5I5K8tYy95GjKPNGqWuki5zWUMrMERcMsbjpd21m6yv)tCfIkITGGWs5Un9wNixmNKFsgRphmHow1)e3PQzeeYDB6TorYZGDnJow1)e3PQzwaR2LGFtmsUBtV1jEUH5nyo(aw120v5b9UQ4yXC2z7xgemLcYfZj5NKX6ZbtitpbHGPuqYZGDnJm9wfmLcsEgSRz0XQ(N4kevedR2LGFtmsUBtV1jEUH5nyo(aw120v5bsVXsV14dhfy3gB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJow1)exHOJdR2LGFtmsUBtV1jEUH5nyo(aw120v5bb7i3KJcmh9MQNU02VmiykfKlMtYpjJ1NdMqMEccbtPGKNb7Agz6Hv7sWVjgj3TP36ep3W8gmhFaRAB6Q8GkFSnGjhhlEsA7xgSC0ZFDKfZja5AngX2)XambX5VoYI5eGCTgJ(SJOJBbbbUNBTiWpsgGr6x8NCed2tTZqLWQDj43eJK720BDINByEdMJpGvTnDvEOVzsnFcSFACS0CSn2(LbbtPGCXCs(jzS(CWeY0tqiykfK8myxZitVvbtPGKNb7AgHbU0ModIoJGqUBtV1jYfZj5NKX6ZbtOJv9pXDe54eeJkykfK8myxZitVv5Un9wNi5zWUMrhR6FI7iYXHv7sWVjgj3TP36ep3W8gmhFaRAB6Q8GaFy(SHpCSBMUzS9ldcMsb5I5K8tYy95GjKPNGqWuki5zWUMrMERcMsbjpd21mcdCPnDgeDgbHC3MERtKlMtYpjJ1NdMqhR6FI7iYXjigvWuki5zWUMrMERYDB6TorYZGDnJow1)e3rKJdR2LGFtmsUBtV1jEUH5nyo(aw120v5bo1ngJJGpLaZXXTelNlb)MEl2V18z7xgemLcYfZj5NKX6ZbtitpbHGPuqYZGDnJm9wfmLcsEgSRzeg4sB6mi6mcc5Un9wNixmNKFsgRphmHow1)e3rKJtqi3TP36ejpd21m6yv)tChrooSAxc(nXi5Un9wN45gM3G54dyvBtxLh6z)Ar9lMpCuUQ9ogB7xgemLcYfZj5NKX6ZbtitpbHGPuqYZGDnJm9wfmLcsEgSRzeg4sB6mi6my1Ue8BIrYDB6ToXZnmVbZXhWQ2MUkpu(ddIQoGXrCVDKnhJT9ldcMsb5I5K8tYy95GjKPNGqWuki5zWUMrMERcMsbjpd21m6yv)tCfdIooSAxc(nXi5Un9wN45gM3G54dyvBtxLhK7DMEaRJKnx)oypCuL1ER9BA7xgemLcYfZj5NKX6ZbtitpbHGPuqYZGDnJm9wfmLcsEgSRz0XQ(N4kQCgSAxc(nXi5Un9wN45gM3G54dyvBtxLhK7DMEaRJKnx)oypCuW1KSTFzqWukixmNKFsgRphmHm9eecMsbjpd21mY0BvWuki5zWUMrhR6FIRq0XHv7sWVjgj3TP36ep3W8gmhFaRAB6Q8q99GPpjJyMuLtqClr9XyGt6Gjy1Ue8BIrYDB6ToXZnmVbZXhWQ2MUkpGNwPncpGpCS4jPTFzqWukixmNKFsgRphmHm9eecMsbjpd21mY0dR2LGFtmsUBtV1jEUH5nyo(aw120v5H2l(tY4(TO0Zhd4dwTlb)MyKC3MERt8CdZBWC8bSQTPRYd3dmElwyhmXxClrtMKr3gB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAZGOZiiK720BDICXCs(jzS(CWe6yv)tCNHQMrqi3TP36ejpd21m6yv)tCNHQMbR2LGFtmsUBtV1jEUH5nyo(aw120v5HJvxahjnV2tjh1S4xYWQDj43eJK720BDINByEdMJpGvTnDvEq87T4wIyWEQyy1Ue8BIrYDB6ToXZnmVbZXhWQ2MUkpup9xR(tsCSVzuDs22VmiykfKlMtYpjJ1NdMqMEccbtPGKNb7Agz6TkykfK8myxZOJv9pXvmu5my1Ue8BIrYDB6ToXZnmVbZXhWQ2MUkpOp21rYMRFhShok4As22VmiykfKlMtYpjJ1NdMqMEccbtPGKNb7Agz6TkykfK8myxZOJv9pXvmu5my1Ue8BIrYDB6ToXZnmVbZXhWQ2MUkpOp21rh3)NNaCuL1ER9BA7xgemLcYfZj5NKX6ZbtitpbHGPuqYZGDnJm9wfmLcsEgSRz0XQ(N4kgQCgSAxc(nXi5Un9wN45gM3G54dyvBtxLhiVnjXX(7v9w8Cs22VmmQGPuqUyoj)KmwFoycz6ToQGPuqYZGDnJm9WQDj43eJK720BDINByEdMJpGvTnDvEa)5Jb8fjBU(DWE4OGRjzB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJow1)exXGOJdR2LGFtmsUBtV1jEUH5nyo(aw120v5b8NpgWxKS563b7HJQS2BTFtB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJow1)exXqLZGv7sWVjgj3TP36ep3W8gmhFaRAB6Q8GBV4j)CCSSjiULy)wZNTFzyuG34eGKNb7AgXPl0yTv5Un9wNixmNKFsgRphmHow1)exX4eeaVXjajpd21mItxOXARYDB6TorYZGDnJow1)exX4wbVk3r0zeetBZUy)wZxNHQScEvUcrNzf4nobOA3goULOJNymItxOXAy1Ue8BIrYDB6ToXZnmVbZXhWQ2MUkpi(X)MXTe1S6JzB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAZGOZiiK720BDICXCs(jzS(CWe6yv)tCNHQMrqi3TP36ejpd21m6yv)tCNHQMbR2LGFtmsUBtV1jEUH5nyo(aw120v5bhpj2tghp3E3lk3ZB2(Lbnlykf0527Er5EElQzbtPG0BDsqyPGPuqUyoj)KmwFoycDSQ)jUZqLZiiemLcsEgSRzeg4sBgeDMvbtPGKNb7AgDSQ)jUJOJBHvlL720BDIin(PFpJBj62lFlycDSQ)jUt3zgbb4v5iyJ6NROQzeeJYymNsgj3uZjM1X2x4YEsgP6DBplGv7sWVjgj3TP36ep3W8gmhFaRAB6Q8Gn5cIBj6P85eelMZoB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAtNbrNrqi3TP36e5I5K8tYy95Gj0XQ(N4ovnJGyubtPGKNb7Agz6Tk3TP36ejpd21m6yv)tCNQMbR2LGFtmsUBtV1jEUH5D8eNXjV12AB)YWOcMsb5I5K8tYy95GjKP36OcMsbjpd21mY0dR2LGFtmsUBtV1jEUH5DXCs(jzS(CWKTFzWYPTzxSFR5RZGiTcEvUIXjiM2MDX(TMVodvzf8QCNXjiaEJtaAAB2fDXCsYhItxOXARYDB6TortBZUOlMts(qhR6FIhMzHvWRYrWgN6jhMbR2LGFtmsUBtV1jEUH5LNb7A22Vmy502Sl2V181zqKwbVkxX4eetBZUy)wZxNHQScEvUZ4eeaVXjanTn7IUyoj5dXPl0yTv5Un9wNOPTzx0fZjjFOJv9pXdZSWk4v5iyJt9KdZGv7sWVjgj3TP36ep3W8tBZUOlMts(S9ldGxLJGno1tomZQLwkykfKlMtYpjJ1NdMqMEccbtPGKNb7Agz6TGGWsbtPGCXCs(jzS(CWesV1Pv5Un9wNixmNKFsgRphmHow1)e3rKZiiemLcsEgSRzKERtRYDB6TorYZGDnJow1)e3rKZSWcy1Ue8BIrYDB6ToXZnmF5tVfpwAZMFsA7xgM2MDX(TMVodvzvUBtV1jYfZj5NKX6ZbtOJv9pXDiLARGxLJGno1tomZQLJc8gNaeMpVF6vrC6cnwtqiykfeMpVF6vrMElGv7sWVjgj3TP36ep3W8GjoAsH1K6yzpjB7xgaVkxXqLeecMsbDS0MgJXXYEsgz6Hv7sWVjgj3TP36ep3W8cTD1XTebtCKtw1oB)YGGPuqUyoj)KmwFoycz6jiemLcsEgSRzKP3QGPuqYZGDnJWaxAZGOZGv7sWVjgj3TP36ep3W8Kg)0VNXTeD7LVfmz7xggf4nobi5zWUMrC6cnwB1s5Un9wNixmNKFsgRphmHow1)exX4wN2MDX(TMVodvrqi3TP36e5I5K8tYy95Gj0XQ(N4odICCliiSe4nobi5zWUMrC6cnwBvUBtV1jsEgSRz0XQ(N4kiLARtBZUy)wZxNbrsqi3TP36ejpd21m6yv)tCNbroUfWQDj43eJK720BDINBy(69AAX8NXJXB6PKT9ldYDB6TorUyoj)KmwFoycDSQ)jUcsP2602Sl2V181zOkccG34eGKNb7AgXPl0yTv5Un9wNi5zWUMrhR6FIRGuQToTn7I9BnFDgejbHC3MERtKlMtYpjJ1NdMqhR6FI7miYXjiK720BDIKNb7AgDSQ)jUZGihhwTlb)MyKC3MERt8CdZxwPbZ6OBV89aokWUQTFzWYrp)1rwmNaKR1yeB)hdWeeN)6ilMtaY1Am6ZovnJGa3ZTwe4hjdWi9l(toIb7P2zOslSoQLcMsb5I5K8tYy95GjKPNGqWuki5zWUMrMElSAPC3MERtKqZ1CClXUzWGxYOJv9pXDiLArOkRYDB6TorDZOjv5eGow1)e3HuQfHQSawTlb)MyKC3MERt8CdZRYQ7zxClXMr(6O(yxfB7xgSuWukixmNKFsgRphmHm9eecMsbjpd21mY0BvWuki5zWUMryGlTzq0zwyDAB2f73A(QyOky1Ue8BIrYDB6ToXZnmFV5(IDFsgfAogy7xgSC0ZFDKfZja5AngX2)XambX5VoYI5eGCTgJ(StvZiiW9CRfb(rYams)I)KJyWEQDgQ0cy1qkSAxc(nXOYNpEIp8CdZl2V3fASTPRYdACu6yGl0yBf7ndpG75wlc8JKbyK(f)jhXG9u7mujbHGPuqSAVDh7zSFR5dz6TQzbtPG6MrtQYjaP360QGPuq6x8NCS3C9lMr6TojiW9CRfb(rYams)I)KJyWEQDgQ0QGPuqYZGDnJm9wfmLcsEgSRzeg4sBQq0zWQDj43eJkF(4j(WZnmpMpVF6vT9ldwA5OaVXjajpd21mItxOXARcMsb5I5K8tYy95GjKPNGqUBtV1jYfZj5NKX6ZbtOJv9pXDQCCliiSuWuki5zWUMrMEcc5Un9wNi5zWUMrhR6FI7u54wyHvlhf4nobOYNElES0Mn)KeXPl0ynbHC3MERtu5tVfpwAZMFsIow1)exHOZSWQLJc8gNaeBFwAa)MrmNaoLmItxOXAcc5Un9wNi2(S0a(nJyobCkz0XQ(N4keDMfwbVkhbBCQNCygSAxc(nXOYNpEIp8CdZl2ZUN5Xt8HJtUQkF2(Lblhf4nobOYNElES0Mn)KeXPl0ynbHC3MERtu5tVfpwAZMFsIow1)e3HuQfbrNrqOzbtPGkF6T4XsB28tsKP3cRwokWBCcqS9zPb8BgXCc4uYioDHgRjiK720BDIy7Zsd43mI5eWPKrhR6FI7qk1IGOZii0SGPuqS9zPb8BgXCc4uYitVfee4EU1Ia)izagPFXFYrmyp1odvcR2LGFtmQ85JN4dp3W8S9zPb8BgXCc4uY2(LbCp3ArGFKmaJ0V4p5igSNAfdvz1slhf4nobi5zWUMrC6cnwtqiykfK8myxZi9wNwL720BDIKNb7AgDSQ)jUJOZSGGqWuki5zWUMryGlTPZqveeYDB6TorUyoj)KmwFoycDSQ)jUJOZii0SGPuqLp9w8yPnB(jjY0BHvWRYrWgN6jhMbR2LGFtmQ85JN4dp3W86x8NCed2t12Vmi2V3fAmsJJshdCHgBDubtPGe7z3Z84j(WXjxvLpKP3QLwokWBCcqYZGDnJ40fASMGqUBtV1jsEgSRz0XQ(N4oKsTiuLfwTCuG34eGy7Zsd43mI5eWPKrC6cnwtqi3TP36eX2NLgWVzeZjGtjJow1)e3HuQfHQiiW9CRfb(rYams)I)KJyWEQDgQYcccCp3ArGFKmaJ0V4p5igSNANHkTAjWBCcqtBZUOlMts(qC6cnwBvUBtV1jAAB2fDXCsYh6yv)tCfKsTiufbHGPuqYZGDnJm9wfmLcsEgSRzeg4sBQq0zwybSAxc(nXOYNpEIp8CdZdy1(MF4Oy(0Vey7xgSCuG34eGKNb7AgXPl0ynbHC3MERtK8myxZOJv9pXDiLArOklSA5OaVXjaX2NLgWVzeZjGtjJ40fASMGqUBtV1jITplnGFZiMtaNsgDSQ)jUdPulcvzf3ZTwe4hjdWi9l(toIb7PwXqvwy1YrbEJtaQ8P3IhlTzZpjrC6cnwtqi3TP36ev(0BXJL2S5NKOJv9pXDiLArOklSA5OYvmNEcqjlVTTNgXPl0ynbHC3MERtKyp7EMhpXhoo5QQ8How1)e3HuQTGGa4nobOPTzx0fZjjFioDHgRTk3TP36enTn7IUyoj5dDSQ)jUcsPweQIGqWukOPTzx0fZjjFitpbHGPuqYZGDnJm9wfmLcsEgSRzeg4sBQq0zeecMsbj2ZUN5Xt8HJtUQkFitpSAifwTlb)MyejN85G9WZnmV0BTOlb)MX2Jb2MUkpu(8Xt8HT9ldtBZUy)wZxNHXjiemLcAAB2fDXCsYhY0tqOzbtPGkF6T4XsB28tsKPNGqZcMsbX2NLgWVzeZjGtjJm9WQDj43eJi5KphShEUH5fAmg)jzClrSrvLpy1Ue8BIrKCYNd2dp3W8cngJ)KmULOBag1ewTlb)MyejN85G9WZnmVqJX4pjJBjw)jGpy1Ue8BIrKCYNd2dp3W8cngJ)KmULiU)(KewTlb)MyejN85G9WZnmV(f)jhbBRz7xggvZcMsb1nJMuLtaY0B1Yrp)1rwmNaKR1yeB)hdWeeN)6ilMtaY1Am6ZovnZcRwoTn7I9BnFvmujbX02Sl2V18vXGiTAPC3MERtKqZ1CClXUzWGxYOJv9pXDiLArOsccnlykfeBFwAa)MrmNaoLmY0tqOzbtPGkF6T4XsB28tsKP3clSA5OaVXjav(0BXJL2S5NKioDHgRjiK720BDIkF6T4XsB28ts0XQ(N4oKsTii6mlSA5OaVXjaX2NLgWVzeZjGtjJ40fASMGqUBtV1jITplnGFZiMtaNsgDSQ)jUdPulcIoZcy1Ue8BIrKCYNd2dp3W81UnCClrhpXyB)YGLtBZUy)wZ3WmcIPTzxSFR5RIHkTAPC3MERtKqZ1CClXUzWGxYOJv9pXDiLArOsccnlykfeBFwAa)MrmNaoLmY0tqOzbtPGkF6T4XsB28tsKP3clSA5ON)6ilMtaY1AmIT)JbycIZFDKfZja5Ang9zNkNzHvlhf4nobi2(S0a(nJyobCkzeNUqJ1eeYDB6TorS9zPb8BgXCc4uYOJv9pXDeDClSA5OaVXjav(0BXJL2S5NKioDHgRjiK720BDIkF6T4XsB28ts0XQ(N4oIoUfWQDj43eJi5KphShEUH5fAUMJBj2ndg8s22VmmTn7I9BnFvmufSAxc(nXiso5Zb7HNBy(jxvLV4wI1NdMS9ldtBZUy)wZxfdIewTlb)MyejN85G9WZnmF3mAsvob2(LHr1SGPuqDZOjv5eGm9wTCAB2f73A(QyOscIPTzxSFR5RIbrAvUBtV1jsO5AoULy3myWlz0XQ(N4oKsTiuPfWQDj43eJi5KphShEUH5LERfDj43m2EmW20v5HYNpEIpSTFzWsGFKmanXEdmH6LGkgQCgbHGPuqUyoj)KmwFoycz6jiemLcsEgSRzKPNGqWukiwT3UJ9m2V18Hm9waR2LGFtmIKt(CWE45gMxEgSR5lIb3BdB7xgK720BDIKNb7A(IyW92Wi5KFKmowoxc(n9wNbrr2JXTA502Sl2V18vXqLeetBZUy)wZxfdvzvUBtV1jsO5AoULy3myWlz0XQ(N4oKsTiujbX02Sl2V18nisRYDB6TorcnxZXTe7MbdEjJow1)e3HuQfHkTk3TP36e1nJMuLta6yv)tChsPweQ0cy1Ue8BIrKCYNd2dp3W8sV1IUe8BgBpgyB6Q8q5ZhpXhgwTlb)MyejN85G9WZnmV8myxZxedU3g22VmmTn7I9BnFvmisy1Ue8BIrKCYNd2dp3W8YnLCcohW6yP5QmSAxc(nXiso5Zb7HNBy(J9(pjJLMRYyB)YaWpsgGMyVbMI9sqhr8mccGFKmanXEdmf7LGkQCgbr5jNaXJv9pXvu14WQDj43eJi5KphShEUH59t6jhb7DCcS9ldtBZUy)wZxfdIewTlb)MyejN85G9WZnmVCtmlph8BA7xgaVkhbBCQNSdPuhueZh(3mmsLZQCMOZev0GsTF5NK4Gs3NDxlICKUlJ09HiIqkK21edPVA)EaiTShKkIw(8Xt8HfrH0J7EM)ynKIxvgsDdyvDaRHu5KNKmgbRU7Rpzi1EkIiK299MI5dWAivevUI50tasebeNUqJ1IOqkyHuru5kMtpbireerHulf1(wGGvdRU7IA)EawdPJdPUe8BcPThdWiy1bL2Jb4qxbfnxCtde6kmIOHUckUe8BguowWydhu40fASomwaegPYqxbfoDHgRdJfuCj43mOi9wl6sWVzS9yqqP9yqmDvoOi3TP36ehaHrQk0vqHtxOX6Wybfxc(ndksV1IUe8BgBpgeuApgetxLdkKCYNd2dhabqqP)y5Qk4GqxHren0vqXLGFZGIFsp5iyVJtqqHtxOX6Wybqaeui5KphSho0vyerdDfu40fASomwqrEpGV3dktBZUy)wZhK2zashhsjiGubtPGM2MDrxmNK8Hm9qkbbKQzbtPGkF6T4XsB28tsKPhsjiGunlykfeBFwAa)MrmNaoLmY0huCj43mOi9wl6sWVzS9yqqP9yqmDvoOu(8Xt8HdGWivg6kO4sWVzqrOXy8NKXTeXgvv(ckC6cnwhglacJuvORGIlb)MbfHgJXFsg3s0naJAgu40fASomwaegrKHUckUe8BgueAmg)jzClX6pb8fu40fASomwaegz8qxbfxc(ndkcngJ)KmULiU)(KmOWPl0yDySaimI9m0vqHtxOX6Wybf59a(EpOmkKQzbtPG6MrtQYjaz6HuRqQLq6Oq65VoYI5eGCTgJy7)yagsjiG0ZFDKfZja5Ang9jK2bsRAgKAbKAfsTesN2MDX(TMpiTIbiTsiLGasN2MDX(TMpiTIbivKqQvi1sivUBtV1jsO5AoULy3myWlz0XQ(NyiTdKsk1qQiaPvcPeeqQMfmLcITplnGFZiMtaNsgz6HuccivZcMsbv(0BXJL2S5NKitpKAbKAbKAfsTeshfsbEJtaQ8P3IhlTzZpjrC6cnwdPeeqQC3MERtu5tVfpwAZMFsIow1)edPDGusPgsfbiv0zqQfqQvi1siDuif4nobi2(S0a(nJyobCkzeNUqJ1qkbbKk3TP36eX2NLgWVzeZjGtjJow1)edPDGusPgsfbiv0zqQfbfxc(ndk6x8NCeSTwaegXEe6kOWPl0yDySGI8EaFVhuSesN2MDX(TMpiDasNbPeeq602Sl2V18bPvmaPvcPwHulHu5Un9wNiHMR54wIDZGbVKrhR6FIH0oqkPudPIaKwjKsqaPAwWuki2(S0a(nJyobCkzKPhsjiGunlykfu5tVfpwAZMFsIm9qQfqQfqQvi1siDui98xhzXCcqUwJrS9FmadPeeq65VoYI5eGCTgJ(es7aPvodsTasTcPwcPJcPaVXjaX2NLgWVzeZjGtjJ40fASgsjiGu5Un9wNi2(S0a(nJyobCkz0XQ(NyiTdKk64qQfqQvi1siDuif4nobOYNElES0Mn)KeXPl0ynKsqaPYDB6TorLp9w8yPnB(jj6yv)tmK2bsfDCi1IGIlb)MbLA3goULOJNyCaegreh6kOWPl0yDySGI8EaFVhuM2MDX(TMpiTIbiTQGIlb)MbfHMR54wIDZGbVKdGWiDNqxbfoDHgRdJfuK3d479GY02Sl2V18bPvmaPImO4sWVzqzYvv5lULy95GPaimIOZcDfu40fASomwqrEpGV3dkJcPAwWukOUz0KQCcqMEi1kKAjKoTn7I9BnFqAfdqALqkbbKoTn7I9BnFqAfdqQiHuRqQC3MERtKqZ1CClXUzWGxYOJv9pXqAhiLuQHurasResTiO4sWVzqPBgnPkNGaimIOIg6kOWPl0yDySGI8EaFVhuSesb(rYa0e7nWeQxcG0kgG0kNbPeeqQGPuqUyoj)KmwFoycz6HuccivWuki5zWUMrMEiLGasfmLcIv7T7ypJ9BnFitpKArqXLGFZGI0BTOlb)MX2JbbL2JbX0v5Gs5ZhpXhoacJiALHUckC6cnwhglOiVhW37bf5Un9wNi5zWUMVigCVnmso5hjJJLZLGFtVbPDgGurr2JXHuRqQLq602Sl2V18bPvmaPvcPeeq602Sl2V18bPvmaPvbPwHu5Un9wNiHMR54wIDZGbVKrhR6FIH0oqkPudPIaKwjKsqaPtBZUy)wZhKoaPIesTcPYDB6TorcnxZXTe7MbdEjJow1)edPDGusPgsfbiTsi1kKk3TP36e1nJMuLta6yv)tmK2bsjLAiveG0kHulckUe8BguKNb7A(IyW92WbqyerRk0vqHtxOX6Wybfxc(ndksV1IUe8BgBpgeuApgetxLdkLpF8eF4aimIOIm0vqHtxOX6Wybf59a(EpOmTn7I9BnFqAfdqQidkUe8BguKNb7A(IyW92Wbqyerhp0vqXLGFZGICtjNGZbSowAUkhu40fASomwaegru7zORGcNUqJ1HXckY7b89Eqb4hjdqtS3atXEjas7aPI4zqkbbKc8JKbOj2BGPyVeaPvaPvodsjiG0YtobIhR6FIH0kG0QgpO4sWVzq5yV)tYyP5QmoacJiQ9i0vqHtxOX6Wybf59a(EpOmTn7I9BnFqAfdqQidkUe8Bgu8t6jhb7DCccGWiIkIdDfu40fASomwqrEpGV3dkGxLJGno1tcPDGusPoO4sWVzqrUjMLNd(ndGaiOu(8Xt8HdDfgr0qxbfoDHgRdJfu2(GcMbbfxc(ndkI97DHghue7ndhuW9CRfb(rYams)I)KJyWEQqANbiTsiLGasfmLcIv7T7ypJ9BnFitpKAfs1SGPuqDZOjv5eG0BDcPwHubtPG0V4p5yV56xmJ0BDcPeeqkUNBTiWpsgGr6x8NCed2tfs7maPvcPwHubtPGKNb7Agz6HuRqQGPuqYZGDnJWaxAdKwbKk6SGIy)IPRYbfnokDmWfACaegPYqxbfoDHgRdJfuK3d479GILqQLq6OqkWBCcqYZGDnJ40fASgsTcPcMsb5I5K8tYy95GjKPhsjiGu5Un9wNixmNKFsgRphmHow1)edPDG0khhsTasjiGulHubtPGKNb7Agz6HuccivUBtV1jsEgSRz0XQ(NyiTdKw54qQfqQfqQvi1siDuif4nobOYNElES0Mn)KeXPl0ynKsqaPYDB6TorLp9w8yPnB(jj6yv)tmKwbKk6mi1ci1kKAjKokKc8gNaeBFwAa)MrmNaoLmItxOXAiLGasL720BDIy7Zsd43mI5eWPKrhR6FIH0kGurNbPwaPwHuWRYrWgN6jH0biDwqXLGFZGcMpVF6vdGWivf6kOWPl0yDySGI8EaFVhuSeshfsbEJtaQ8P3IhlTzZpjrC6cnwdPeeqQC3MERtu5tVfpwAZMFsIow1)edPDGusPgsfbiv0zqkbbKQzbtPGkF6T4XsB28tsKPhsTasTcPwcPJcPaVXjaX2NLgWVzeZjGtjJ40fASgsjiGu5Un9wNi2(S0a(nJyobCkz0XQ(NyiTdKsk1qQiaPIodsjiGunlykfeBFwAa)MrmNaoLmY0dPwaPeeqkUNBTiWpsgGr6x8NCed2tfs7maPvguCj43mOi2ZUN5Xt8HJtUQkFbqyerg6kOWPl0yDySGI8EaFVhuW9CRfb(rYams)I)KJyWEQqAfdqAvqQvi1si1siDuif4nobi5zWUMrC6cnwdPeeqQGPuqYZGDnJ0BDcPwHu5Un9wNi5zWUMrhR6FIH0oqQOZGulGuccivWuki5zWUMryGlTbs7maPvbPeeqQC3MERtKlMtYpjJ1NdMqhR6FIH0oqQOZGuccivZcMsbv(0BXJL2S5NKitpKAbKAfsbVkhbBCQNeshG0zbfxc(ndkS9zPb8BgXCc4uYbqyKXdDfu40fASomwqrEpGV3dkI97DHgJ04O0XaxOXqQviDuivWukiXE29mpEIpCCYvv5dz6HuRqQLqQLq6OqkWBCcqYZGDnJ40fASgsjiGu5Un9wNi5zWUMrhR6FIH0oqkPudPIaKwfKAbKAfsTeshfsbEJtaITplnGFZiMtaNsgXPl0ynKsqaPYDB6TorS9zPb8BgXCc4uYOJv9pXqAhiLuQHurasRcsjiGuCp3ArGFKmaJ0V4p5igSNkK2zasRcsTasjiGuCp3ArGFKmaJ0V4p5igSNkK2zasResTcPwcPaVXjanTn7IUyoj5dXPl0ynKAfsL720BDIM2MDrxmNK8How1)edPvaPKsnKkcqAvqkbbKkykfK8myxZitpKAfsfmLcsEgSRzeg4sBG0kGurNbPwaPweuCj43mOOFXFYrmyp1aimI9m0vqHtxOX6Wybf59a(EpOyjKokKc8gNaK8myxZioDHgRHuccivUBtV1jsEgSRz0XQ(NyiTdKsk1qQiaPvbPwaPwHulH0rHuG34eGy7Zsd43mI5eWPKrC6cnwdPeeqQC3MERteBFwAa)MrmNaoLm6yv)tmK2bsjLAiveG0QGuRqkUNBTiWpsgGr6x8NCed2tfsRyasRcsTasTcPwcPJcPaVXjav(0BXJL2S5NKioDHgRHuccivUBtV1jQ8P3IhlTzZpjrhR6FIH0oqkPudPIaKwfKAbKAfsTeshfsLRyo9eGswEBBpnKsqaPYDB6TorI9S7zE8eF44KRQYh6yv)tmK2bsjLAi1ciLGasbEJtaAAB2fDXCsYhItxOXAi1kKk3TP36enTn7IUyoj5dDSQ)jgsRasjLAiveG0QGuccivWukOPTzx0fZjjFitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgHbU0giTciv0zqkbbKkykfKyp7EMhpXhoo5QQ8Hm9bfxc(ndkawTV5hokMp9lbbqaeuK720BDIdDfgr0qxbfoDHgRdJfuK3d479GILqQGPuqcTD1ndgGo2LaiLGasfmLcYfZj5NKX6ZbtitpKAfsfmLcYfZj5NKX6ZbtOJv9pXqAhivurmKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgDSQ)jgsRasRCCi1IGIlb)MbL(f8BgaHrQm0vqHtxOX6Wybf59a(EpOG75wlc8JKbyu7jNa4y3mAsvobqANbiTsiLGasTeshfsp)1rwmNaKR1yeB)hdWqkbbKE(RJSyobixRXOpH0oqQ9yCi1IGIlb)MbL2tobWXUz0KQCccGWivf6kOWPl0yDySGI8EaFVhuemLcYfZj5NKX6ZbtitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgHbU0giDasfDwqXLGFZGs5pwOTRoacJiYqxbfxc(ndk4PNB64wII5KK9uYbfoDHgRdJfaHrgp0vqHtxOX6WybL0v5GY52R2K2GJcpz8yDuWaaBguCj43mOCU9QnPn4OWtgpwhfmaWMbqye7zORGcNUqJ1HXckUe8BguC8KypzC8C7DVOCpVfuK3d479GIMfmLc6C7DVOCpVf1SGPuq6ToHucci1sivWukixmNKFsgRphmHow1)edPDgG0kNbPeeqQGPuqYZGDnJWaxAdKoaPIodsTcPcMsbjpd21m6yv)tmK2bsfDCi1ci1kKAjKk3TP36erA8t)Eg3s0Tx(wWe6yv)tmK2bs7oZGuccif4hjdqGxLJGnQFgsRasRAgKsqaPJcPmgZPKrYn1CIzDS9fUSNKrQE32dsTiOKUkhuC8KypzC8C7DVOCpVfaHrShHUckC6cnwhglO4sWVzqPBmooT1n(ckY7b89EqrWukixmNKFsgRphmHm9qkbbKkykfK8myxZitpKAfsfmLcsEgSRzeg4sBG0biv0zbL0v5Gs3yCCARB8faHreXHUckC6cnwhglO4sWVzqr87T4wIE(QoG1rH2U6GI8EaFVhuSesfmLcYfZj5NKX6ZbtitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgDSQ)jgsRasfvedPwaPeeqQLqQC3MERtKlMtYpjJ1NdMqhR6FIH0oqAvZGuccivUBtV1jsEgSRz0XQ(NyiTdKw1mi1IGs6QCqr87T4wIE(QoG1rH2U6aims3j0vqHtxOX6Wybfxc(ndk6DvXXI5SlOiVhW37bfbtPGCXCs(jzS(CWeY0dPeeqQGPuqYZGDnJm9qQvivWuki5zWUMrhR6FIH0kGurfXbL0v5GIExvCSyo7cGWiIol0vqHtxOX6Wybfxc(ndkKEJLERXhokWUnbf59a(EpOiykfKlMtYpjJ1NdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21m6yv)tmKwbKk64bL0v5GcP3yP3A8HJcSBtaegrurdDfu40fASomwqXLGFZGIGDKBYrbMJEt1txguK3d479GIGPuqUyoj)KmwFoycz6HuccivWuki5zWUMrM(Gs6QCqrWoYn5OaZrVP6PldGWiIwzORGcNUqJ1HXckUe8Bguu5JTbm54yXtYGI8EaFVhuSeshfsp)1rwmNaKR1yeB)hdWqkbbKE(RJSyobixRXOpH0oqQOJdPwaPeeqkUNBTiWpsgGr6x8NCed2tfs7maPvgusxLdkQ8X2aMCCS4jzaegr0QcDfu40fASomwqXLGFZGsFZKA(ey)04yP5yBckY7b89EqrWukixmNKFsgRphmHm9qkbbKkykfK8myxZitpKAfsfmLcsEgSRzeg4sBG0odqQOZGuccivUBtV1jYfZj5NKX6ZbtOJv9pXqAhivKJdPeeq6OqQGPuqYZGDnJm9qQvivUBtV1jsEgSRz0XQ(NyiTdKkYXdkPRYbL(Mj18jW(PXXsZX2eaHrevKHUckC6cnwhglO4sWVzqrGpmF2Who2nt3mbf59a(EpOiykfKlMtYpjJ1NdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21mcdCPnqANbiv0zqkbbKk3TP36e5I5K8tYy95Gj0XQ(NyiTdKkYXHucciDuivWuki5zWUMrMEi1kKk3TP36ejpd21m6yv)tmK2bsf54bL0v5GIaFy(SHpCSBMUzcGWiIoEORGcNUqJ1HXckUe8Bgu4u3ymoc(ucmhh3sSCUe8B6Ty)wZxqrEpGV3dkcMsb5I5K8tYy95GjKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJWaxAdK2zasfDgKsqaPYDB6TorUyoj)KmwFoycDSQ)jgs7aPICCiLGasL720BDIKNb7AgDSQ)jgs7aPIC8Gs6QCqHtDJX4i4tjWCCClXY5sWVP3I9BnFbqyerTNHUckC6cnwhglO4sWVzqPN9Rf1Vy(Wr5Q27yCqrEpGV3dkcMsb5I5K8tYy95GjKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJWaxAdK2zasfDwqjDvoO0Z(1I6xmF4OCv7DmoacJiQ9i0vqHtxOX6Wybfxc(ndkL)WGOQdyCe3BhzZX4GI8EaFVhuemLcYfZj5NKX6ZbtitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgDSQ)jgsRyasfD8Gs6QCqP8hgevDaJJ4E7iBoghaHreveh6kOWPl0yDySGIlb)Mbf5ENPhW6izZ1Vd2dhvzT3A)Mbf59a(EpOiykfKlMtYpjJ1NdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21m6yv)tmKwbKw5SGs6QCqrU3z6bSos2C97G9Wrvw7T2Vzaegr0UtORGcNUqJ1HXckUe8BguK7DMEaRJKnx)oypCuW1KCqrEpGV3dkcMsb5I5K8tYy95GjKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJow1)edPvaPIoEqjDvoOi37m9awhjBU(DWE4OGRj5aimsLZcDfu40fASomwqjDvoOuFpy6tYiMjv5ee3suFmg4KoykO4sWVzqP(EW0NKrmtQYjiULO(ymWjDWuaegPsrdDfu40fASomwqXLGFZGcEAL2i8a(WXINKbf59a(EpOiykfKlMtYpjJ1NdMqMEiLGasfmLcsEgSRzKPpOKUkhuWtR0gHhWhow8KmacJuzLHUckC6cnwhglOKUkhuAV4pjJ73IspFmGVGIlb)MbL2l(tY4(TO0Zhd4lacJuzvHUckC6cnwhglO4sWVzq5EGXBXc7Gj(IBjAYKm62euK3d479GIGPuqUyoj)KmwFoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZimWL2aPdqQOZGuccivUBtV1jYfZj5NKX6ZbtOJv9pXqANbiTQzqkbbKk3TP36ejpd21m6yv)tmK2zasRAwqjDvoOCpW4TyHDWeFXTenzsgDBcGWivkYqxbfoDHgRdJfusxLdkhRUaosAETNsoQzXVKdkUe8BguowDbCK08ApLCuZIFjhaHrQC8qxbfoDHgRdJfusxLdkIFVf3sed2tfhuCj43mOi(9wClrmypvCaegPs7zORGcNUqJ1HXckUe8BguQN(Rv)jjo23mQojhuK3d479GIGPuqUyoj)KmwFoycz6HuccivWuki5zWUMrMEi1kKkykfK8myxZOJv9pXqAfdqALZckPRYbL6P)A1FsIJ9nJQtYbqyKkThHUckC6cnwhglO4sWVzqrFSRJKnx)oypCuW1KCqrEpGV3dkcMsb5I5K8tYy95GjKPhsjiGubtPGKNb7Agz6HuRqQGPuqYZGDnJow1)edPvmaPvolOKUkhu0h76izZ1Vd2dhfCnjhaHrQueh6kOWPl0yDySGIlb)Mbf9XUo64()8eGJQS2BTFZGI8EaFVhuemLcYfZj5NKX6ZbtitpKsqaPcMsbjpd21mY0dPwHubtPGKNb7AgDSQ)jgsRyasRCwqjDvoOOp21rh3)NNaCuL1ER9BgaHrQS7e6kOWPl0yDySGIlb)MbfYBtsCS)EvVfpNKdkY7b89EqzuivWukixmNKFsgRphmHm9qQviDuivWuki5zWUMrM(Gs6QCqH82Keh7Vx1BXZj5aimsvZcDfu40fASomwqXLGFZGc(Zhd4ls2C97G9WrbxtYbf59a(EpOiykfKlMtYpjJ1NdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21m6yv)tmKwXaKk64bL0v5Gc(Zhd4ls2C97G9WrbxtYbqyKQen0vqHtxOX6Wybfxc(ndk4pFmGVizZ1Vd2dhvzT3A)Mbf59a(EpOiykfKlMtYpjJ1NdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21m6yv)tmKwXaKw5SGs6QCqb)5Jb8fjBU(DWE4OkR9w73macJuvLHUckC6cnwhglO4sWVzqXTx8KFoow2ee3sSFR5lOiVhW37bLrHuG34eGKNb7AgXPl0ynKAfsL720BDICXCs(jzS(CWe6yv)tmKwbKooKsqaPaVXjajpd21mItxOXAi1kKk3TP36ejpd21m6yv)tmKwbKooKAfsbVkdPDGurNbPeeq602Sl2V18bPDgG0QGuRqk4vziTciv0zqQvif4nobOA3goULOJNymItxOX6Gs6QCqXTx8KFoow2ee3sSFR5lacJuvvHUckC6cnwhglO4sWVzqr8J)nJBjQz1hZbf59a(EpOiykfKlMtYpjJ1NdMqMEiLGasfmLcsEgSRzKPhsTcPcMsbjpd21mcdCPnq6aKk6miLGasL720BDICXCs(jzS(CWe6yv)tmK2zasRAgKsqaPYDB6TorYZGDnJow1)edPDgG0QMfusxLdkIF8VzClrnR(yoacJuLidDfu40fASomwqXLGFZGIJNe7jJJNBV7fL75TGI8EaFVhu0SGPuqNBV7fL75TOMfmLcsV1jKsqaPwcPcMsb5I5K8tYy95Gj0XQ(NyiTZaKw5miLGasfmLcsEgSRzeg4sBG0biv0zqQvivWuki5zWUMrhR6FIH0oqQOJdPwaPwHulHu5Un9wNisJF63Z4wIU9Y3cMqhR6FIH0oqA3zgKsqaPGxLJGnQFgsRasRAgKsqaPJcPmgZPKrYn1CIzDS9fUSNKrQE32dsTiOKUkhuC8KypzC8C7DVOCpVfaHrQA8qxbfoDHgRdJfuCj43mOytUG4wIEkFobXI5SlOiVhW37bfbtPGCXCs(jzS(CWeY0dPeeqQGPuqYZGDnJm9qQvivWuki5zWUMryGlTbs7maPIodsjiGu5Un9wNixmNKFsgRphmHow1)edPDG0QMbPeeq6OqQGPuqYZGDnJm9qQvivUBtV1jsEgSRz0XQ(NyiTdKw1SGs6QCqXMCbXTe9u(CcIfZzxaegPk7zORGcNUqJ1HXckY7b89EqzuivWukixmNKFsgRphmHm9qQviDuivWuki5zWUMrM(GIlb)MbfhpXzCYBTToacJuL9i0vqHtxOX6Wybf59a(EpOyjKoTn7I9BnFqANbivKqQvif8QmKwbKooKsqaPtBZUy)wZhK2zasRcsTcPGxLH0oq64qkbbKc8gNa002Sl6I5KKpeNUqJ1qQvivUBtV1jAAB2fDXCsYh6yv)tmKoaPZGulGuRqk4v5iyJt9Kq6aKolO4sWVzqXfZj5NKX6ZbtbqyKQeXHUckC6cnwhglOiVhW37bflH0PTzxSFR5ds7maPIesTcPGxLH0kG0XHucciDAB2f73A(G0odqAvqQvif8QmK2bshhsjiGuG34eGM2MDrxmNK8H40fASgsTcPYDB6TortBZUOlMts(qhR6FIH0biDgKAbKAfsbVkhbBCQNeshG0zbfxc(ndkYZGDnhaHrQQ7e6kOWPl0yDySGI8EaFVhuaVkhbBCQNeshG0zqQvi1si1sivWukixmNKFsgRphmHm9qkbbKkykfK8myxZitpKAbKsqaPwcPcMsb5I5K8tYy95GjKERti1kKk3TP36e5I5K8tYy95Gj0XQ(NyiTdKkYzqkbbKkykfK8myxZi9wNqQvivUBtV1jsEgSRz0XQ(NyiTdKkYzqQfqQfbfxc(ndktBZUOlMts(cGWiICwORGcNUqJ1HXckY7b89EqzAB2f73A(G0odqAvqQvivUBtV1jYfZj5NKX6ZbtOJv9pXqAhiLuQHuRqk4v5iyJt9Kq6aKodsTcPwcPJcPaVXjaH5Z7NEveNUqJ1qkbbKkykfeMpVF6vrMEi1IGIlb)MbLYNElES0Mn)KmacJisrdDfu40fASomwqrEpGV3dkGxLH0kgG0kHuccivWukOJL20ymow2tYitFqXLGFZGcyIJMuynPow2tYbqyerwzORGcNUqJ1HXckY7b89EqrWukixmNKFsgRphmHm9qkbbKkykfK8myxZitpKAfsfmLcsEgSRzeg4sBG0biv0zbfxc(ndkcTD1XTebtCKtw1UaimIiRk0vqHtxOX6Wybf59a(EpOmkKc8gNaK8myxZioDHgRHuRqQLqQC3MERtKlMtYpjJ1NdMqhR6FIH0kG0XHuRq602Sl2V18bPDgG0QGuccivUBtV1jYfZj5NKX6ZbtOJv9pXqANbivKJdPwaPeeqQLqkWBCcqYZGDnJ40fASgsTcPYDB6TorYZGDnJow1)edPvaPKsnKAfsN2MDX(TMpiTZaKksiLGasL720BDIKNb7AgDSQ)jgs7maPICCi1IGIlb)MbfsJF63Z4wIU9Y3cMcGWiIuKHUckC6cnwhglOiVhW37bf5Un9wNixmNKFsgRphmHow1)edPvaPKsnKAfsN2MDX(TMpiTZaKwfKsqaPaVXjajpd21mItxOXAi1kKk3TP36ejpd21m6yv)tmKwbKsk1qQviDAB2f73A(G0odqQiHuccivUBtV1jYfZj5NKX6ZbtOJv9pXqANbivKJdPeeqQC3MERtK8myxZOJv9pXqANbivKJhuCj43mOuVxtlM)mEmEtpLCaegrKJh6kOWPl0yDySGI8EaFVhuSeshfsp)1rwmNaKR1yeB)hdWqkbbKE(RJSyobixRXOpH0oqAvZGuccif3ZTwe4hjdWi9l(toIb7PcPDgG0kHulGuRq6OqQLqQGPuqUyoj)KmwFoycz6HuccivWuki5zWUMrMEi1ci1kKAjKk3TP36ej0Cnh3sSBgm4Lm6yv)tmK2bsjLAiveG0QGuRqQC3MERtu3mAsvobOJv9pXqAhiLuQHurasRcsTiO4sWVzqPSsdM1r3E57bCuGD1aimIiTNHUckC6cnwhglOiVhW37bflHubtPGCXCs(jzS(CWeY0dPeeqQGPuqYZGDnJm9qQvivWuki5zWUMryGlTbshGurNbPwaPwH0PTzxSFR5dsRyasRkO4sWVzqrLv3ZU4wInJ81r9XUkoacJis7rORGcNUqJ1HXckY7b89EqXsiDui98xhzXCcqUwJrS9FmadPeeq65VoYI5eGCTgJ(es7aPvndsjiGuCp3ArGFKmaJ0V4p5igSNkK2zasResTiO4sWVzqP3CFXUpjJcnhdcGaiackUbmTxqrP7z4Md2lacGqaa]] )


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
