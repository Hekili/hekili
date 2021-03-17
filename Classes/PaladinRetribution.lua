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


        -- Generic Aura to cover any Aura.
        paladin_aura = {
            alias = { "concentration_aura", "crusader_aura", "devotion_aura", "retribution_aura" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600,
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
            duration = 12,
            max_stack = 1
        },

        blessing_of_dusk = {
            id = 337757,
            duration = 12,
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
        return max( gcd.remains, min( cooldown.judgment.true_remains, cooldown.crusader_strike.true_remains, cooldown.blade_of_justice.true_remains, ( action.hammer_of_wrath.usable and cooldown.hammer_of_wrath.true_remains or 999 ), cooldown.wake_of_ashes.true_remains, ( race.blood_elf and cooldown.arcane_torrent.true_remains or 999 ), ( IsSpellKnown( 304971 ) and cooldown.divine_toll.true_remains or 999 ) ) )
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

            startsCombat = false,
            texture = 135933,

            nobuff = "paladin_aura",

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

            startsCombat = false,
            texture = 135890,

            nobuff = "paladin_aura",

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

            startsCombat = false,
            texture = 135893,

            nobuff = "paladin_aura",
            
            handler = function ()
                apply_aura( "devotion_aura" )
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
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
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
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
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

            usable = function () return target.health_pct < 20 or ( level > 57 and ( buff.avenging_wrath.up or buff.crusade.up ) ) or buff.final_verdict.up or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up end,
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
                    duration = 10,
                    max_stack = 3
                },

                -- Power: 335069
                negative_energy_token_proc = {
                    id = 345693,
                    duration = 5,
                    max_stack = 1,
                },
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

            nobuff = "paladin_aura",

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


    spec:RegisterPack( "Retribution", 20210317, [[dOKjzbqirspIkK6ssQs1MiuFcrKrriDkQGvHi5vGknleHBrfIAxO8lqHHrf1XielJkvpdrQPrfQRbkABuHW3KuvghIOohviP1jsG5jP4EiQ9jsDqjvv1cbv8qjvXePcjUOKQQSrjvj5JuHioPKQeRKkYmfjOBkPkLDkPYqLuLulvsvLNkIPkP0xPcrASIeYEL4VIAWahwyXu4XenzkDzOndYNjy0QWPv1Qfj61GsZMQUnfTBs)wQHRIoUiHA5i9CunDLUUkTDQKVljJNkLZdQA(iSFfxePuBjXglwQZDNDxeNjTi1hZzswK6J0KCjzH)eljNHe2qaljAyILK6hU034UFRLKZaEFh2sTLeEFPsSKusmUVFRx0IrjXglwQZDNDxeNjTi1hZzswK6ZDhxs4NOSux95Cj54TwulgLelYLLK6hU034UFRdOED4d7RJt1BbvEmarQpsma3D2DrgNgNQNJqfqEkyCYrEaPWGVoYCu2QDaxEiGdOHgWsFfwC5WOECu4dq7Qba10by0C(aGEHJLpGw9WparTTss7aQc(IdOECu4dO1bS0GF4aBCYrEa1BbS4asqACE8Mda6QY9BDavhOoG6vVg(bu)qjST(QamQ)CdL39BDajOUOkXbeuCaToG6XrzaqnDaXaQoEpYkjN0g69yjXr7Ohq9dx6BC3V1buVo8H91XjhTJEa1BbvEmarQpsma3D2DrgNgNC0o6buphHkG8uW4KJ2rpah5bKcd(6iZrzR2bC5HaoGgAal9vyXLdJ6XrHpaTRgauthGrZ5da6fow(aA1d)ae12kjTdOk4loG6XrHpGwhWsd(HdSXjhTJEaoYdOElGfhqcsJZJ3CaqxvUFRdO6a1buV61WpG6hkHT1xfGr9NBO8UFRdib1fvjoGGIdO1bupokdaQPdigq1X7r2404ui3Vvo7KIY20iwYN9(ToofY9BLZoPOSnnIfUKHHHh58xfYnuMFnnr64ui3Vvo7KIY20iw4sgggEKZFvi3q54UxtDCkK73kNDsrzBAelCjdddpY5VkKBOC1RlshNc5(TYzNuu2MgXcxYWWWJC(Rc5gkZpPVkmofY9BLZoPOSnnIfUKHrqLHI5TPuuxs8qK3WJ6YGEn8zkkHT1xfyOggE0kEdpQlJJ0484nzOggE0oononGXjhTJEa1FUHY7I2bGUqk8dyFtCa7boGqUnDapFaHR49HHhzJtHC)w5KPOXfwCCkK73khUKHHm8(Ci3V1S)5lj0Wejl72B7kLpofY9BLdxYWqgEFoK73A2)8LeAyIKfqfPX2u(40agNc5(TYzYU92Us5Kp79BLepezJleelCHQWRc5kAShS7jbHXfcIjPxEyr29uSXfcIjPxEyrgFdjSKfXzccJMZfd9chBMIMXR8AChMJtHC)w5mz3EBxPC4sgg(x4y55uETcMOUK4HiZprVpVbvaxoZ)chlpNYRvWe1nnz3jisLgVnJUqDzH1YzOBpF5ee04Tz0fQllSwo7101hmjiOXBZOluxwyTC29CCkK73kNj72B7kLdxYWa6POHVBljEiYgxiiw4cvHxfYv0ypy3tccJleetsV8WIS7PyJleetsV8WIm(gsyjlIZJtHC)w5mz3EBxPC4sgg8Jh92CdLDHQagQejXdrw0u3WJ6Yq3q5D)wZCuxuLid1WWJwccz3EBxPm0nuE3V1mh1fvjYOOz8kVgy6UdIHEHJntrZ4vEArG54ui3Vvot2T32vkhUKHHHh58xfYnuMFnnr64ui3Vvot2T32vkhUKHHHh58xfYnuoU71uhNc5(TYzYU92Us5WLmmm8iN)QqUHYvVUiDCkK73kNj72B7kLdxYWWWJC(Rc5gkZpPVkmofY9BLZKD7TDLYHlzyC5y(x0KeAyIKFLlP3nm8yofFdDVMzl66LijEiYgxiiw4cvHxfYv0ypy3tccJleetsV8WIS7PyJleetsV8WIm(gsyjlIZeegnNlg6fo2mfnJx51qANhNc5(TYzYU92Us5WLmmUCm)lAscnmrYTlKwDGEZxfYNDfsZsk88n8K4HiBCHGyHlufEvixrJ9GDpjimUqqmj9YdlYUNInUqqmj9YdlY4BiHLSiotqy0CUyOx4yZu0mELxJiWCCkK73kNj72B7kLdxYW4YX8VOjj0WejBdkSMDRzlkHn7QPH8x4jXdr24cbXcxOk8QqUIg7b7EsqyCHGys6LhwKDpfBCHGys6LhwKX3qclzrCMGWO5CXqVWXMPOz8kVg3DECkK73kNj72B7kLdxYW4YX8VOjj0WejBgYWGIz(bIB28YFjjEiYgxiiw4cvHxfYv0ypy3tccJleetsV8WIS7PyJleetsV8WIm(gsyjlIZeegnNlg6fo2mfnJx514UZJtHC)w5mz3EBxPC4sggxoM)fnjHgMizlfdl0tXSlKZr)4ui3Vvot2T32vkhUKHXLJ5FrtsOHjsMd71dls55QxfgNc5(TYzYU92Us5WLmmUCm)lAscnmrYc03mlBl624ui3Vvot2T32vkhUKHXLJ5FrtsOHjs2enBk85gkFg8nZFLpofY9BLZKD7TDLYHlzyC5y(x0KeAyIK5NbfZMyS5JUHDCkK73kNj72B7kLdxYW4YX8VOjj0WejZFf66Zc(W(X2uE2iScyUHYqiTL)cpjEiYgxiiw4cvHxfYv0ypy3tccJleetsV8WIS7PyJleetsV8WIm(gsyttweNjiKD7TDLYcxOk8QqUIg7bJIMXR80ogMeeYU92Uszs6LhwKrrZ4vEAhdZXPqUFRCMSBVTRuoCjdJlhZ)IMKqdtKm)vORph8ZNg6YZgHvaZnugcPT8x4jXdr24cbXcxOk8QqUIg7b7EsqyCHGys6LhwKDpfBCHGys6LhwKX3qcBAYI4mbHSBVTRuw4cvHxfYv0ypyu0mELN2XWKGq2T32vktsV8WImkAgVYt7yyoofY9BLZKD7TDLYHlzyC5y(x0KtIhISXfcIfUqv4vHCfn2d29KGW4cbXK0lpSi7Ek24cbXK0lpSiJVHe20KfX5XPqUFRCMSBVTRuoCjdJWfQcVkKROXEqIhISOhTh(8zxH00KDS49nXAGjbXr7HpF2vinnzslw09nX0WKGGEveQPciBpWSzi88LglYZP8AfmrDDGGydpQl7O9WNdxOkGugQHHhTILD7TDLYoAp85WfQciLrrZ4vozNDqSOPUHh1LXrACE8MmuddpAjiKD7TDLY4inopEtgfnJx5PDMGydpQlJhQCFOhT5kAShmuddpADyCkK73kNj72B7kLdxYWqsV8WIK4HiF0E4ZNDfstt2XI33eRbMeehTh(8zxH00KjT49nX0WKGydpQl7O9WNdxOkGugQHHhTILD7TDLYoAp85WfQciLrrZ4vozNhNc5(TYzYU92Us5WLmmc(bQ5JW77QXPqUFRCMSBVTRuoCjdJJ2dFoCHQasjXdrEFtmVD(4uGSZIf14cbXcxOk8QqUIg7b7EsqyCHGys6LhwKDpjimUqqSWfQcVkKROXEWSDLkw2T32vklCHQWRc5kAShmkAgVYt7yNjimUqqmj9YdlYSDLkw2T32vktsV8WImkAgVYt7yNDyCkK73kNj72B7kLdxYWa61WNPOe2wFvGepezrpAp85ZUcPPj7yX7BI1qYeehTh(8zxH00KjT49nX0Kjzhel72B7kLfUqv4vHCfn2dgfnJx5PfKwX7BI5TZhNcKDwSOPUHh1LXrACE8MmuddpAjimUqqmosJZJ3KDpDqSOPsJ3MrxOUSWA5m0TNVCccA82m6c1LfwlNDpjiOXBZOluxwyTC2RPDSZomonGXPqUFRCg0Rp)aPCYUc6hgEKeAyIKT8Sm4By4rs4k8xKm)e9(8gubC5m776vmZ3MAs2DXPkk9Qiutfqg0RHp7cP2xUI3WJ6YOVWXI9LNDHu7lxgQHHhTILTAV)Yw080huE21R2xg73kd1WWJwhii4NO3N3GkGlNzFxVIz(2uZ0UtqyCHGyO5j8um08zxHu29uSfnUqqSuETcMOUmBxPInUqqm776vmFEPNnhz2UshNc5(TYzqV(8dKYHlzyWrACE8MK4HilQSBVTRuw4cvHxfYv0ypyu0mELNweysqi72B7kLjPxEyrgfnJx5PfbMeeB4rDzqVg(mfLW26RcmuddpADqSOPUHh1Lb9A4ZuucBRVkWqnm8OLGq2T32vkd61WNPOe2wFvGrrZ4vEAstYeeYU92UszqVg(mfLW26RcmkAgVYRHSG0skslw0uPXBZOluxwyTCg62ZxobbnEBgDH6YcRLZEnTJDMGGgVnJUqDzH1YzVwJG0sqqJ3MrxOUSWA5S7Pdoiw0u3WJ6Yq3q5D)wZCuxuLid1WWJwccz3EBxPm0nuE3V1mh1fvjYOOz8kpnPHjbHSBVTRug6gkV73AMJ6IQezu0mELxdzbPLuKMGydpQld61WNPOe2wFvGHAy4rRdIfnvz7c1qxgSWt)qjiKD7TDLYSVRxX82EpJIMXR80ogMeeYU92Usz231RyEBVNrrZ4vEnoQoqqy0CUyOx4yZu0mELxJiWum0lCSzkAgVYtdZXPqUFRCg0Rp)aPC4sggOBO8UFRzoQlQsKepezrnUqqmj9YdlYSDLkw2T32vktsV8WImkAgVYtlIZeegxiiMKE5Hfz8nKWMMmPjiKD7TDLYcxOk8QqUIg7bJIMXR80I4SdIfn1n8OUmOxdFMIsyB9vbgQHHhTeeYU92UszqVg(mfLW26RcmkAgVYtlIZoiEdQaUS9nX82z7JPj5XPqUFRCg0Rp)aPC4sgg231RyMVn1Kepezxb9ddpYS8Sm4By4rXPACHGyUcnfFF(bs55JW0ePS7Pyrfn1n8OUmj9YdlYqnm8OLGq2T32vktsV8WImkAgVYtliTKI0oiw0u3WJ6Yq3q5D)wZCuxuLid1WWJwccz3EBxPm0nuE3V1mh1fvjYOOz8kpTG0skhbbHSBVTRug6gkV73AMJ6IQezu0mELNwqAjfmfF0E4ZNDfstt2XeeBqfWLTVjM3oBFSgsMGi1n8OUmosJZJ3KHAy4rRyz3EBxPm0nuE3V1mh1fvjYOOz8kpTG0sk3DqSOPUHh1Lb9A4ZuucBRVkWqnm8OLGq2T32vkd61WNPOe2wFvGrrZ4vEAbPLuocccz3EBxPmOxdFMIsyB9vbgfnJx5PfKwsbtXhTh(8zxH00KDmbrQB4rDzCKgNhVjd1WWJwXYU92UszqVg(mfLW26RcmkAgVYtliTKYDhelAQB4rDzCKgNhVjd1WWJwccz3EBxPmosJZJ3KrrZ4vE9UG0c3J2dF(SRqAAstqSHh1Lb9A4ZuucBRVkWqnm8OLGydpQldDdL39BnZrDrvImuddpAjiKTludDzWcp9d1bccr3WJ6YoAp85WfQciLHAy4rRyz3EBxPSJ2dFoCHQaszu0mELxJG0skstqyCHGyhTh(C4cvbKYUNeegxiiMKE5Hfz3tXgxiiMKE5Hfz8nKWwJio7GdJtHC)w5mOxF(bs5WLmmw080huE2fsTVCjXdrw0u3WJ6YK0lpSid1WWJwccz3EBxPmj9YdlYOOz8kpTG0sks7GyrtDdpQldDdL39BnZrDrvImuddpAjiKD7TDLYq3q5D)wZCuxuLiJIMXR80cslPCeeeYU92UszOBO8UFRzoQlQsKrrZ4vEAbPLuWu8r7HpF2vinnzhtqSbvax2(MyE7S9XAizcIu3WJ6Y4inopEtgQHHhTILD7TDLYq3q5D)wZCuxuLiJIMXR80cslPC3bXIM6gEuxg0RHptrjST(Qad1WWJwccz3EBxPmOxdFMIsyB9vbgfnJx5PfKws5iiiKD7TDLYGEn8zkkHT1xfyu0mELNwqAjfmfF0E4ZNDfstt2XeePUHh1LXrACE8MmuddpAfl72B7kLb9A4ZuucBRVkWOOz8kpTG0sk3DqSOPUHh1LXrACE8MmuddpAjiKD7TDLY4inopEtgfnJx517cslCpAp85ZUcPPjnbXgEuxg0RHptrjST(Qad1WWJwcIn8OUm0nuE3V1mh1fvjYqnm8OLGq2Uqn0Lbl80puhii2WJ6YoAp85WfQciLHAy4rRyz3EBxPSJ2dFoCHQaszu0mELxJG0skstqyCHGyhTh(C4cvbKYUNeegxiiMKE5Hfz3tXgxiiMKE5Hfz8nKWwJioponGXPqUFRCMaQin2MYjldVphY9Bn7F(scnmrYqV(8dKYjXdr(O9WNp7kKsgMeegxii2r7HphUqvaPS7jbHfnUqqmOxdFMIsyB9vb29KGWIgxiig6gkV73AMJ6IQez3ZXPqUFRCMaQin2MYHlzy4k0u895hiLNpcttKoofY9BLZeqfPX2uoCjdd776vmVT3tIhICQw04cbXs51kyI6YUNIfn1n8OUmosJZJ3KHAy4rlbHXfcIXrACE8MS7PdIfnvA82m6c1LfwlNHU98LtqqJ3MrxOUSWA5SxttANjiOXBZOluxwyTC290bXIE0E4ZNDfsRHS7eehTh(8zxH0Ai7yXIk72B7kLz4dlMBOCkV89LiJIMXR80cslPCNGWIgxiig6gkV73AMJ6IQez3tcclACHGyqVg(mfLW26RcS7Pdoiw0u3WJ6YGEn8zkkHT1xfyOggE0sqi72B7kLb9A4ZuucBRVkWOOz8kpTG0skrC2bXIM6gEuxg6gkV73AMJ6IQezOggE0sqi72B7kLHUHY7(TM5OUOkrgfnJx5PfKwsjIZeeBqfWLTVjM3oBFSgs2bXIk72B7kLfUqv4vHCfn2dgfnJx5eeYU92Uszs6LhwKrrZ4vUdJtHC)w5mburASnLdxYW4imnrAUHYv0ypiXdrMEveQPciBpWSzyZNbneALGGEveQPciZvOc3GA5zZ2e19AkEdpQldDdL39BnZrDrvImuddpAjiKTludDzUqDpGNkw2T32vkl4hOMpcVVRyu0mELN2DrCECkK73kNjGksJTPC4sggP8AfmrDjXdrovlACHGyP8AfmrDz3tXgxii2r7HphUqvaPS754ui3VvotavKgBt5WLmmQcyXCdLd(bYjXdrw0J2dF(SRqAnKDx8gEuxg6gkV73AMJ6IQezOggE0k2Igxiig6gkV73AMJ6IQezu0mELN2zXw04cbXq3q5D)wZCuxuLiJIMXR8AeKws5UdJtHC)w5mburASnLdxYWWWhwm3q5uE57lrs8qKpAp85ZUcP1qM0I3WJ6Ym8HfZnuUIg7bd1WWJwXIUHh1Lb9A4ZuucBRVkWqnm8OvSfnUqqmOxdFMIsyB9vbgfnJx5PfKws5obXgEuxg6gkV73AMJ6IQezOggE0ko1n8OUmOxdFMIsyB9vbgQHHhTIf1Igxiig6gkV73AMJ6IQez3tccz3EBxPm0nuE3V1mh1fvjYOOz8kNSZo4W4ui3VvotavKgBt5WLmms51kyI6sIhICQw04cbXs51kyI6YUNI3WJ6Y4inopEtgQHHhTIf9O9WNp7kKMMSiIPxfHAQaY2dmBgcpFPXI8CkVwbtuxcIJ2dF(SRqAAYU7W4ui3VvotavKgBt5WLmmQcyXCdLd(bYjXdrw0J2dF(SRqkzNjioAp85ZUcP1q2DXIk72B7kLz4dlMBOCkV89LiJIMXR80cslPCNGWIgxiig6gkV73AMJ6IQez3tcInOc4Y23eZBNTpwdjtqyrJleed61WNPOe2wFvGDpDWbXIMknEBgDH6YcRLZq3E(YjiOXBZOluxwyTC2RPD3zccA82m6c1LfwlNDpDqSOPUHh1LHUHY7(TM5OUOkrgQHHhTeeYU92UszOBO8UFRzoQlQsKrrZ4vEArGjbXgubCz7BI5TZ2hRHKDqSOPUHh1Lb9A4ZuucBRVkWqnm8OLGq2T32vkd61WNPOe2wFvGrrZ4vEArGjbXgubCz7BI5TZ2hRHKDqSOYU92UszHlufEvixrJ9GrrZ4vobHSBVTRuMKE5Hfzu0mEL7W4ui3VvotavKgBt5WLmmKH3Nd5(TM9pFjHgMizOxF(bs5K4HiF0E4ZNDfsttM0InUqqmj9YdlYUNInUqqmj9YdlY4BiHTgrCECkK73kNjGksJTPC4sggg(WI5gkNYlFFjsIhI8r7HpF2viTgYKwSSv79xg625Lke73kd1WWJwXPkBxOg6YCH6EapDCkK73kNjGksJTPC4sggP8AfmrDjXdrovlACHGyP8AfmrDz3ZXPqUFRCMaQin2MYHlzyCeMMin3q5kAShJtHC)w5mburASnLdxYWWWhwm3q5uE57lrs8qKpAp85ZUcP1qM0JtHC)w5mburASnLdxYWqgEFoK73A2)8LeAyIKHE95hiLtIhISOBqfWLDGHFpyNYTgYU7mbHXfcIfUqv4vHCfn2d29KGW4cbXK0lpSi7EsqyCHGyO5j8um08zxHu290HXPqUFRCMaQin2MYHlzyiPxEyrAMV0hwKepezz3EBxPmj9YdlsZ8L(WIm5rqfqEgIgY9Bn8PjlcR(GPyrpAp85ZUcP1q2DcIJ2dF(SRqAnKjTyz3EBxPmdFyXCdLt5LVVezu0mELNwqAjL7eehTh(8zxHuYowSSBVTRuMHpSyUHYP8Y3xImkAgVYtliTKYDXYU92UszP8AfmrDzu0mELNwqAjL7omofY9BLZeqfPX2uoCjddzRCusJ9BLepe5uLTYrjn2Vv29um)e9(8gubC5m776vmZ3MAMMS7JtHC)w5mburASnLdxYWqgEFoK73A2)8LeAyIKHE95hiLpofY9BLZeqfPX2uoCjddzRCusJ9BLepe5uLTYrjn2Vv29CCkK73kNjGksJTPC4sggs6LhwKM5l9HfhNc5(TYzcOI0yBkhUKHrqLHI5TPuu3XPqUFRCMaQin2MYHlzyiBLJsASFRLexiL)TwQZDNDxeNjTioxsQcQ(QaVK4iT(V(vx9sDossbdya1EGd4npB6oaOMoass2T32vkNKgaftX3NI2bWBtCaXDBZyr7aKhHkGC24uk8vCaUlskya1tRUq6I2bqs0RIqnvazPisAaBpasIEveQPcilfXqnm8OLKgGOI4MdSXPXjhP1)1V6QxQZrskyadO2dCaV5zt3ba10bqsqV(8dKYjPbqXu89PODa82ehqC32mw0oa5rOciNnoLcFfhGiPGbupT6cPlAhajrVkc1ubKLIiPbS9aij6vrOMkGSued1WWJwsAaIkIBoWgNsHVIdWXPGbupT6cPlAhqYBwpdGdVUHBdOEFaBpGu4ngG9D98V1b0Nin2MoarHHddqurCZb24uk8vCaWmfmG6PvxiDr7asEZ6zaC41nCBa17dy7bKcVXaSVRN)ToG(ePX20bikmCyaIkIBoWgNgNCKw)x)QREPohjPGbmGApWb8MNnDhauthajjGksJTPCsAaumfFFkAhaVnXbe3TnJfTdqEeQaYzJtPWxXb44uWaQNwDH0fTdGKOxfHAQaYsrK0a2EaKe9QiutfqwkIHAy4rljnarfXnhyJtPWxXb44uWaQNwDH0fTdGKOxfHAQaYsrK0a2EaKe9QiutfqwkIHAy4rljnarfXnhyJtPWxXbqYPGbupT6cPlAhajrVkc1ubKLIiPbS9aij6vrOMkGSued1WWJwsAaIkIBoWgNgNQxmpB6I2baZbeY9BDa(NVC24ujX)8LxQTKyrO463sTL6ePuBjjK73AjHIgxyXscQHHhTf4u2sDUxQTKGAy4rBboLKqUFRLez495qUFRz)Z3sI)5BwdtSKi72B7kLx2sDKUuBjb1WWJ2cCkjHC)wljYW7ZHC)wZ(NVLe)Z3SgMyjravKgBt5LTSLKtkkBtJyl1wQtKsTLKqUFRLKZE)wljOggE0wGtzl15EP2ssi3V1sIHh58xfYnuMFnnrAjb1WWJ2cCkBPosxQTKeY9BTKy4ro)vHCdLJ7En1scQHHhTf4u2sDoUuBjjK73AjXWJC(Rc5gkx96I0scQHHhTf4u2sDWSuBjjK73AjXWJC(Rc5gkZpPVkusqnm8OTaNYwQZruQTKGAy4rBboLej9xK(rjzdpQld61WNPOe2wFvGHAy4r7aepGn8OUmosJZJ3KHAy4rBjjK73AjjOYqX82ukQBzlBjravKgBt5LAl1jsP2scQHHhTf4usK0Fr6hLKJ2dF(SRq6aipayoacIbyCHGyhTh(C4cvbKYUNdGGyaw04cbXGEn8zkkHT1xfy3ZbqqmalACHGyOBO8UFRzoQlQsKDpljHC)wljYW7ZHC)wZ(NVLe)Z3SgMyjb61NFGuEzl15EP2ssi3V1sIRqtX3NFGuE(imnrAjb1WWJ2cCkBPosxQTKGAy4rBboLej9xK(rjj1byrJleelLxRGjQl7EoaXdq0bK6a2WJ6Y4inopEtgQHHhTdGGyagxiighPX5XBYUNdWHbiEaIoGuhanEBgDH6YcRLZq3E(YhabXaOXBZOluxwyTC2Rdi9aiTZdGGya04Tz0fQllSwo7EoahgG4bi6aoAp85ZUcPdOgYdW9bqqmGJ2dF(SRq6aQH8aC8aeparhGSBVTRuMHpSyUHYP8Y3xImkAgVYhq6biiTdGudW9bqqmalACHGyOBO8UFRzoQlQsKDphabXaSOXfcIb9A4ZuucBRVkWUNdWHb4WaeparhqQdydpQld61WNPOe2wFvGHAy4r7aiigGSBVTRug0RHptrjST(QaJIMXR8bKEacs7ai1aeX5b4WaeparhqQdydpQldDdL39BnZrDrvImuddpAhabXaKD7TDLYq3q5D)wZCuxuLiJIMXR8bKEacs7ai1aeX5bqqmGnOc4Y23eZBNTpoGAgajpahgG4bi6aKD7TDLYcxOk8QqUIg7bJIMXR8bqqmaz3EBxPmj9YdlYOOz8kFaousc5(TwsSVRxX82EFzl154sTLeuddpAlWPKiP)I0pkj0RIqnvaz7bMndB(mOHqRmuddpAhabXaOxfHAQaYCfQWnOwE2SnrDVMmuddpAhG4bSHh1LHUHY7(TM5OUOkrgQHHhTdGGyaY2fQHUmxOUhWthG4bi72B7kLf8duZhH33vmkAgVYhq6b4Uioxsc5(TwsocttKMBOCfn2JYwQdMLAljOggE0wGtjrs)fPFussDaw04cbXs51kyI6YUNdq8amUqqSJ2dFoCHQasz3Zssi3V1sskVwbtu3YwQZruQTKGAy4rBboLej9xK(rjr0bC0E4ZNDfshqnKhG7dq8a2WJ6Yq3q5D)wZCuxuLid1WWJ2biEaw04cbXq3q5D)wZCuxuLiJIMXR8bKEaopaXdWIgxiig6gkV73AMJ6IQezu0mELpGAgGG0oasna3hGdLKqUFRLKQawm3q5GFG8YwQR(k1wsqnm8OTaNsIK(ls)OKC0E4ZNDfshqnKhaPhG4bSHh1Lz4dlMBOCfn2dgQHHhTdq8aeDaB4rDzqVg(mfLW26RcmuddpAhG4byrJleed61WNPOe2wFvGrrZ4v(aspabPDaKAaUpacIbSHh1LHUHY7(TM5OUOkrgQHHhTdq8asDaB4rDzqVg(mfLW26RcmuddpAhG4bi6aSOXfcIHUHY7(TM5OUOkr29Caeedq2T32vkdDdL39BnZrDrvImkAgVYha5b48aCyaousc5(Twsm8HfZnuoLx((sSSL6i5sTLeuddpAlWPKiP)I0pkjPoalACHGyP8AfmrDz3ZbiEaB4rDzCKgNhVjd1WWJ2biEaIoGJ2dF(SRq6astEaImaXdGEveQPciBpWSzi88LglYZP8AfmrDzOggE0oacIbC0E4ZNDfshqAYdW9b4qjjK73AjjLxRGjQBzl15OwQTKGAy4rBboLej9xK(rjr0bC0E4ZNDfsha5b48aiigWr7HpF2viDa1qEaUpaXdq0bi72B7kLz4dlMBOCkV89LiJIMXR8bKEacs7ai1aCFaeedWIgxiig6gkV73AMJ6IQez3ZbqqmGnOc4Y23eZBNTpoGAgajpacIbyrJleed61WNPOe2wFvGDphGddWHbiEaIoGuhanEBgDH6YcRLZq3E(YhabXaOXBZOluxwyTC2Rdi9aC35bqqmaA82m6c1LfwlNDphGddq8aeDaPoGn8OUm0nuE3V1mh1fvjYqnm8ODaeedq2T32vkdDdL39BnZrDrvImkAgVYhq6bicmhabXa2GkGlBFtmVD2(4aQzaK8aCyaIhGOdi1bSHh1Lb9A4ZuucBRVkWqnm8ODaeedq2T32vkd61WNPOe2wFvGrrZ4v(asparG5aiigWgubCz7BI5TZ2hhqndGKhGddq8aeDaYU92UszHlufEvixrJ9GrrZ4v(aiigGSBVTRuMKE5Hfzu0mELpahkjHC)wljvbSyUHYb)a5LTuNioxQTKGAy4rBboLej9xK(rj5O9WNp7kKoG0KhaPhG4byCHGys6LhwKDphG4byCHGys6LhwKX3qc7aQzaI4CjjK73AjrgEFoK73A2)8TK4F(M1WeljqV(8dKYlBPorePuBjb1WWJ2cCkjs6Vi9JsYr7HpF2viDa1qEaKEaIhGSv79xg625Lke73kd1WWJ2biEaPoaz7c1qxMlu3d4PLKqUFRLedFyXCdLt5LVVelBPorCVuBjb1WWJ2cCkjs6Vi9JssQdWIgxiiwkVwbtux29SKeY9BTKKYRvWe1TSL6eH0LAljHC)wljhHPjsZnuUIg7rjb1WWJ2cCkBPorCCP2scQHHhTf4usK0Fr6hLKJ2dF(SRq6aQH8aiDjjK73AjXWhwm3q5uE57lXYwQteywQTKGAy4rBboLej9xK(rjr0bSbvax2bg(9GDk3bud5b4UZdGGyagxiiw4cvHxfYv0ypy3ZbqqmaJleetsV8WIS75aiigGXfcIHMNWtXqZNDfsz3Zb4qjjK73AjrgEFoK73A2)8TK4F(M1WeljqV(8dKYlBPorCeLAljOggE0wGtjrs)fPFusKD7TDLYK0lpSinZx6dlYKhbva5ziAi3V1WpG0KhGiS6dMdq8aeDahTh(8zxH0bud5b4(aiigWr7HpF2viDa1qEaKEaIhGSBVTRuMHpSyUHYP8Y3xImkAgVYhq6biiTdGudW9bqqmGJ2dF(SRq6aipahpaXdq2T32vkZWhwm3q5uE57lrgfnJx5di9aeK2bqQb4(aepaz3EBxPSuETcMOUmkAgVYhq6biiTdGudW9b4qjjK73AjrsV8WI0mFPpSyzl1js9vQTKGAy4rBboLej9xK(rjj1biBLJsASFRS75aepa(j695nOc4Yz231RyMVn1CaPjpa3ljHC)wljYw5OKg73Azl1jcjxQTKGAy4rBboLKqUFRLez495qUFRz)Z3sI)5BwdtSKa96ZpqkVSL6eXrTuBjb1WWJ2cCkjs6Vi9JssQdq2khL0y)wz3Zssi3V1sISvokPX(Tw2sDU7CP2ssi3V1sIKE5HfPz(sFyXscQHHhTf4u2sDUlsP2ssi3V1ssqLHI5TPuu3scQHHhTf4u2sDU7EP2ssi3V1sISvokPX(Twsqnm8OTaNYw2sc0Rp)aP8sTL6ePuBjb1WWJ2cCkj9zjHJBjjK73AjXvq)WWJLexH)ILe(j695nOc4Yz231RyMVn1CaKhG7dq8asDaIoa6vrOMkGmOxdF2fsTVCzOggE0oaXdydpQlJ(chl2xE2fsTVCzOggE0oaXdq2Q9(lBrZtFq5zxVAFzSFRmuddpAhGddGGya8t07ZBqfWLZSVRxXmFBQ5aspa3habXamUqqm08eEkgA(SRqk7EoaXdWIgxiiwkVwbtuxMTR0biEagxiiM9D9kMpV0ZMJmBxPLexbnRHjwsS8Sm4By4XYwQZ9sTLeuddpAlWPKiP)I0pkjIoaz3EBxPSWfQcVkKROXEWOOz8kFaPhGiWCaeedq2T32vktsV8WImkAgVYhq6bicmhabXa2WJ6YGEn8zkkHT1xfyOggE0oahgG4bi6asDaB4rDzqVg(mfLW26RcmuddpAhabXaKD7TDLYGEn8zkkHT1xfyu0mELpG0dG0K8aiigGSBVTRug0RHptrjST(QaJIMXR8bud5biiTdGudG0dq8aeDaPoaA82m6c1LfwlNHU98LpacIbqJ3MrxOUSWA5Sxhq6b4yNhabXaOXBZOluxwyTC2RdOMbiiTdGGya04Tz0fQllSwo7EoahgGddq8aeDaPoGn8OUm0nuE3V1mh1fvjYqnm8ODaeedq2T32vkdDdL39BnZrDrvImkAgVYhq6bqAyoacIbi72B7kLHUHY7(TM5OUOkrgfnJx5dOgYdqqAhaPgaPhabXa2WJ6YGEn8zkkHT1xfyOggE0oahgG4bi6asDaY2fQHUmyHN(HoacIbi72B7kLzFxVI5T9EgfnJx5di9aCmmhabXaKD7TDLYSVRxX82EpJIMXR8buZaCuhGddGGyagnNpaXda6fo2mfnJx5dOMbicmhG4ba9chBMIMXR8bKEaWSKeY9BTKWrACE8MLTuhPl1wsqnm8OTaNsIK(ls)OKi6amUqqmj9YdlYSDLoaXdq2T32vktsV8WImkAgVYhq6biIZdGGyagxiiMKE5Hfz8nKWoG0KhaPhabXaKD7TDLYcxOk8QqUIg7bJIMXR8bKEaI48aCyaIhGOdi1bSHh1Lb9A4ZuucBRVkWqnm8ODaeedq2T32vkd61WNPOe2wFvGrrZ4v(asparCEaomaXdydQaUS9nX82z7Jdi9ai5ssi3V1sc6gkV73AMJ6IQelBPohxQTKGAy4rBboLej9xK(rjXvq)WWJmlpld(ggECaIhqQdW4cbXCfAk((8dKYZhHPjsz3ZbiEaIoarhqQdydpQltsV8WImuddpAhabXaKD7TDLYK0lpSiJIMXR8bKEacs7ai1ai9aCyaIhGOdi1bSHh1LHUHY7(TM5OUOkrgQHHhTdGGyaYU92UszOBO8UFRzoQlQsKrrZ4v(aspabPDaKAaoIbqqmaz3EBxPm0nuE3V1mh1fvjYOOz8kFaPhGG0oasnayoaXd4O9WNp7kKoG0KhGJhabXa2GkGlBFtmVD2(4aQzaK8aiigqQdydpQlJJ0484nzOggE0oaXdq2T32vkdDdL39BnZrDrvImkAgVYhq6biiTdGudW9b4WaeparhqQdydpQld61WNPOe2wFvGHAy4r7aiigGSBVTRug0RHptrjST(QaJIMXR8bKEacs7ai1aCedGGyaYU92UszqVg(mfLW26RcmkAgVYhq6biiTdGudaMdq8aoAp85ZUcPdin5b44bqqmGuhWgEuxghPX5XBYqnm8ODaIhGSBVTRug0RHptrjST(QaJIMXR8bKEacs7ai1aCFaomaXdq0bK6a2WJ6Y4inopEtgQHHhTdGGyaYU92UszCKgNhVjJIMXR8baJbiiTdaUd4O9WNp7kKoG0dG0dGGyaB4rDzqVg(mfLW26RcmuddpAhabXa2WJ6Yq3q5D)wZCuxuLid1WWJ2bqqmaz7c1qxgSWt)qhGddGGyaIoGn8OUSJ2dFoCHQaszOggE0oaXdq2T32vk7O9WNdxOkGugfnJx5dOMbiiTdGudG0dGGyagxii2r7HphUqvaPS75aiigGXfcIjPxEyr29CaIhGXfcIjPxEyrgFdjSdOMbiIZdWHb4qjjK73AjX(UEfZ8TPMLTuhml1wsqnm8OTaNsIK(ls)OKi6asDaB4rDzs6LhwKHAy4r7aiigGSBVTRuMKE5Hfzu0mELpG0dqqAhaPgaPhGddq8aeDaPoGn8OUm0nuE3V1mh1fvjYqnm8ODaeedq2T32vkdDdL39BnZrDrvImkAgVYhq6biiTdGudWrmacIbi72B7kLHUHY7(TM5OUOkrgfnJx5di9aeK2bqQbaZbiEahTh(8zxH0bKM8aC8aiigWgubCz7BI5TZ2hhqndGKhabXasDaB4rDzCKgNhVjd1WWJ2biEaYU92UszOBO8UFRzoQlQsKrrZ4v(aspabPDaKAaUpahgG4bi6asDaB4rDzqVg(mfLW26RcmuddpAhabXaKD7TDLYGEn8zkkHT1xfyu0mELpG0dqqAhaPgGJyaeedq2T32vkd61WNPOe2wFvGrrZ4v(aspabPDaKAaWCaIhWr7HpF2viDaPjpahpacIbK6a2WJ6Y4inopEtgQHHhTdq8aKD7TDLYGEn8zkkHT1xfyu0mELpG0dqqAhaPgG7dWHbiEaIoGuhWgEuxghPX5XBYqnm8ODaeedq2T32vkJJ0484nzu0mELpaymabPDaWDahTh(8zxH0bKEaKEaeedydpQld61WNPOe2wFvGHAy4r7aiigWgEuxg6gkV73AMJ6IQezOggE0oacIbiBxOg6YGfE6h6aCyaeedydpQl7O9WNdxOkGugQHHhTdq8aKD7TDLYoAp85WfQciLrrZ4v(aQzacs7ai1ai9aiigGXfcID0E4ZHlufqk7EoacIbyCHGys6LhwKDphG4byCHGys6LhwKX3qc7aQzaI4CjjK73AjzrZtFq5zxi1(YTSLTKi72B7kLxQTuNiLAljOggE0wGtjrs)fPFusmUqqSWfQcVkKROXEWUNdGGyagxiiMKE5Hfz3ZbiEagxiiMKE5Hfz8nKWoaYdqeNhabXamAoFaIha0lCSzkAgVYhqndWDywsc5(Twso79BTSL6CVuBjb1WWJ2cCkjs6Vi9Jsc)e9(8gubC5m)lCS8CkVwbtu3bKM8aCFaeedi1bqJ3MrxOUSWA5m0TNV8bqqmaA82m6c1LfwlN96aspG6dMdGGya04Tz0fQllSwo7Ewsc5(Tws8VWXYZP8AfmrDlBPosxQTKGAy4rBboLej9xK(rjX4cbXcxOk8QqUIg7b7EoacIbyCHGys6LhwKDphG4byCHGys6LhwKX3qc7aiparCUKeY9BTKa9u0W3TTSL6CCP2scQHHhTf4usK0Fr6hLerhqQdydpQldDdL39BnZrDrvImuddpAhabXaKD7TDLYq3q5D)wZCuxuLiJIMXR8buZaGP7dWHbiEaqVWXMPOz8kFaPhGiWSKeY9BTKWpE0BZnu2fQcyOsSSL6GzP2ssi3V1sIHh58xfYnuMFnnrAjb1WWJ2cCkBPohrP2ssi3V1sIHh58xfYnuoU71uljOggE0wGtzl1vFLAljHC)wljgEKZFvi3q5QxxKwsqnm8OTaNYwQJKl1wsc5(Twsm8iN)QqUHY8t6RcLeuddpAlWPSL6Cul1wsqnm8OTaNssi3V1sYRCj9UHHhZP4BO71mBrxVeljs6Vi9JsIXfcIfUqv4vHCfn2d29CaeedW4cbXK0lpSi7EoaXdW4cbXK0lpSiJVHe2bqEaI48aiigGrZ5dq8aGEHJntrZ4v(aQzaK25sIgMyj5vUKE3WWJ5u8n09AMTORxILTuNioxQTKGAy4rBboLKqUFRLK2fsRoqV5Rc5ZUcPzjfE(g(sIK(ls)OKyCHGyHlufEvixrJ9GDphabXamUqqmj9YdlYUNdq8amUqqmj9YdlY4BiHDaKhGiopacIby0C(aepaOx4yZu0mELpGAgGiWSKOHjwsAxiT6a9MVkKp7kKMLu45B4lBPorePuBjb1WWJ2cCkjHC)wlj2GcRz3A2IsyZUAAi)f(sIK(ls)OKyCHGyHlufEvixrJ9GDphabXamUqqmj9YdlYUNdq8amUqqmj9YdlY4BiHDaKhGiopacIby0C(aepaOx4yZu0mELpGAgG7oxs0Welj2GcRz3A2IsyZUAAi)f(YwQte3l1wsqnm8OTaNssi3V1sIziddkM5hiUzZl)LLej9xK(rjX4cbXcxOk8QqUIg7b7EoacIbyCHGys6LhwKDphG4byCHGys6LhwKX3qc7aiparCEaeedWO58biEaqVWXMPOz8kFa1ma3DUKOHjwsmdzyqXm)aXnBE5VSSL6eH0LAljOggE0wGtjrdtSKyPyyHEkMDHCo6ljHC)wljwkgwONIzxiNJ(YwQtehxQTKGAy4rBboLenmXsch2RhwKYZvVkusc5(Tws4WE9WIuEU6vHYwQteywQTKGAy4rBboLenmXsIa9nZY2IUvsc5(TwseOVzw2w0TYwQtehrP2scQHHhTf4us0WeljMOztHp3q5ZGVz(R8ssi3V1sIjA2u4Znu(m4BM)kVSL6eP(k1wsqnm8OTaNsIgMyjHFgumBIXMp6g2ssi3V1sc)mOy2eJnF0nSLTuNiKCP2scQHHhTf4usc5(Tws4VcD9zbFy)yBkpBewbm3qziK2YFHVKiP)I0pkjgxiiw4cvHxfYv0ypy3ZbqqmaJleetsV8WIS75aepaJleetsV8WIm(gsyhqAYdqeNhabXaKD7TDLYcxOk8QqUIg7bJIMXR8bKEaogMdGGyaYU92Uszs6LhwKrrZ4v(aspahdZsIgMyjH)k01Nf8H9JTP8SryfWCdLHqAl)f(YwQteh1sTLeuddpAlWPKeY9BTKWFf66Zb)8PHU8SryfWCdLHqAl)f(sIK(ls)OKyCHGyHlufEvixrJ9GDphabXamUqqmj9YdlYUNdq8amUqqmj9YdlY4BiHDaPjparCEaeedq2T32vklCHQWRc5kAShmkAgVYhq6b4yyoacIbi72B7kLjPxEyrgfnJx5di9aCmmljAyILe(RqxFo4Npn0LNncRaMBOmesB5VWx2sDU7CP2scQHHhTf4usK0Fr6hLeJleelCHQWRc5kAShS75aiigGXfcIjPxEyr29CaIhGXfcIjPxEyrgFdjSdin5biIZLKqUFRLKlhZ)IM8YwQZDrk1wsqnm8OTaNsIK(ls)OKi6aoAp85ZUcPdin5b44biEa7BIdOMbaZbqqmGJ2dF(SRq6astEaKEaIhGOdyFtCaPhamhabXaOxfHAQaY2dmBgcpFPXI8CkVwbtuxgQHHhTdWHbqqmGn8OUSJ2dFoCHQaszOggE0oaXdq2T32vk7O9WNdxOkGugfnJx5dG8aCEaomaXdq0bK6a2WJ6Y4inopEtgQHHhTdGGyaYU92UszCKgNhVjJIMXR8bKEaopacIbSHh1LXdvUp0J2Cfn2dgQHHhTdWHssi3V1ss4cvHxfYv0ypkBPo3DVuBjb1WWJ2cCkjs6Vi9JsYr7HpF2viDaPjpahpaXdyFtCa1mayoacIbC0E4ZNDfshqAYdG0dq8a23ehq6baZbqqmGn8OUSJ2dFoCHQaszOggE0oaXdq2T32vk7O9WNdxOkGugfnJx5dG8aCUKeY9BTKiPxEyXYwQZDsxQTKeY9BTKe8duZhH33vLeuddpAlWPSL6C3XLAljOggE0wGtjrs)fPFus23eZBNpofga5b48aeparhGXfcIfUqv4vHCfn2d29CaeedW4cbXK0lpSi7EoacIbyCHGyHlufEvixrJ9Gz7kDaIhGSBVTRuw4cvHxfYv0ypyu0mELpG0dWXopacIbyCHGys6LhwKz7kDaIhGSBVTRuMKE5Hfzu0mELpG0dWXopahkjHC)wljhTh(C4cvbKw2sDUdZsTLeuddpAlWPKiP)I0pkjIoGJ2dF(SRq6astEaoEaIhW(M4aQzaK8aiigWr7HpF2viDaPjpaspaXdyFtCaPjpasEaomaXdq2T32vklCHQWRc5kAShmkAgVYhq6biiTdq8a23eZBNpofga5b48aeparhqQdydpQlJJ0484nzOggE0oacIbyCHGyCKgNhVj7EoahgG4bi6asDa04Tz0fQllSwodD75lFaeedGgVnJUqDzH1Yz3ZbqqmaA82m6c1LfwlN96aspah78aCOKeY9BTKa9A4ZuucBRVku2Yw2ssC3JMwssEZ6PSLTua]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "spectral_strength",

        package = "Retribution",
    } )


    spec:RegisterSetting( "check_wake_range", false, {
        name = "Check |T1112939:0|t Wake of Ashes Range",
        desc = "If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } )


end
