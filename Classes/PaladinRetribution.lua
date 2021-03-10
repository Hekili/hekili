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


    spec:RegisterPack( "Retribution", 20210310, [[dKKyxbqirspsKiDjqPu2eH6tGs1OieNIqAvif9kqjZcPWTejQSlu(LKQggfPJHuAzuP6zueMgfvUgOW2OiIVjseJJIQCoqPK1rruMNKs3dPAFIuhKIiXcbf9qqPyIIevDrqPu1hPOQWjPOQ0kPOmtkIQBckLk7usLHsrvrlLIi1tfXuLu8vkIKglfvv7vI)kQbdCyHftHht0KP0LH2miFMGrRcNwvRwKWRbvMnvDBQy3K(TudxfDCrIYYr8CunDLUUkTDQKVljJNkLZdQA(iz)kUqBPMsInwSuN7M6oTMAcAnLzkSfmm1CMKsYc)jwsodjCHaws0WbljM04sEJ7(Twsod49Dyl1us49LiXssjX4((18vlgLeBSyPo3n1DAn1e0AkZuylyyQ5mrjHFIYsDPetljhV1IAXOKyrUSKysJl5nU736amFg(W(6ygSDbrEmaAnLgdWDtDN2XSXmyZrOci3KnMLYnatEW3uookB1oGlpeWb0qdyjVchU86HnP88bOD1aGAYamAoFaqVWXYhqRE4hGi2wH9DavbFXbaBs55dO1bSKGFikRKCsAO3JLKuAkDaM04sEJ7(ToaZNHpSVoMLstPda2UGipgaTMsJb4UPUt7y2ywknLoayZrOci3KnMLstPdiLBaM8GVPCCu2QDaxEiGdOHgWsEfoC51dBs55dq7Qba1Kby0C(aGEHJLpGw9WparSTc77aQc(Ida2KYZhqRdyjb)qu2y2ywi3Vvo7KGY2Xiw6N9(ToMfY9BLZojOSDmIfw0R3WJC(Rc5gkZVooizmlK73kNDsqz7yelSOxVHh58xfYnuoU71rhZc5(TYzNeu2ogXcl61B4ro)vHCdLREDrYywi3Vvo7KGY2XiwyrVEdpY5VkKBOm)K8QWywi3Vvo7KGY2XiwyrV(GidfZBtiOU04HOVHh1Lb9A4ZeucxRVkWqnm8Ov8gEuxghjX5X7Wqnm8ODmBmBaJzP0u6aGT3nuEx0oa0fsGFa77GdypWbeYTjd45diCfVpm8iBmlK73kNobnUWHJzHC)w5WIE9YW7ZHC)wZ(NV0qdhKUSBVTRu(ywi3VvoSOxVm8(Ci3V1S)5ln0WbPlGksITj8XSbmMfY9BLZKD7TDLYPF273knEi6gxiiw4cvHxfYvKypy3tkkJleetsU8WIS7PyJleetsU8WIm(gs4OtRPuugnNlg6fo2mbDIx516omgZc5(TYzYU92Us5WIE9(x4y55uCTcoOU04HOZprVpVbraxoZ)chlpNIRvWb1nnD3POsLeVnJUqDzH1YzOBpF5uuK4Tz0fQllSwo710PeyqrrI3MrxOUSWA5S75ywi3Vvot2T32vkhw0Rh6jOHVBlnEi6gxiiw4cvHxfYvKypy3tkkJleetsU8WIS7PyJleetsU8WIm(gs4OtRPJzHC)w5mz3EBxPCyrVE(XJEBUHYUqvadvI04HOlsQB4rDzOBO8UFRzoQlQsKHAy4rlfLSBVTRug6gkV73AMJ6IQeze0jELxlmCxuXqVWXMjOt8kpnTWymlK73kNj72B7kLdl61B4ro)vHCdL5xhhKmMfY9BLZKD7TDLYHf96n8iN)QqUHYXDVo6ywi3Vvot2T32vkhw0R3WJC(Rc5gkx96IKXSqUFRCMSBVTRuoSOxVHh58xfYnuMFsEvymlK73kNj72B7kLdl61F5y(x0HgA4G0FLlj3nm8yoLDdDVozl66LinEi6gxiiw4cvHxfYvKypy3tkkJleetsU8WIS7PyJleetsU8WIm(gs4OtRPuugnNlg6fo2mbDIx51ActhZc5(TYzYU92Us5WIE9xoM)fDOHgoi92fsQoqVZRc5ZUcjzjbE(gEA8q0nUqqSWfQcVkKRiXEWUNuugxiiMKC5Hfz3tXgxiiMKC5Hfz8nKWrNwtPOmAoxm0lCSzc6eVYRLwymMfY9BLZKD7TDLYHf96VCm)l6qdnCq62GaNt3A2Is4YUAsi)fEA8q0nUqqSWfQcVkKRiXEWUNuugxiiMKC5Hfz3tXgxiiMKC5Hfz8nKWrNwtPOmAoxm0lCSzc6eVYR1DthZc5(TYzYU92Us5WIE9xoM)fDOHgoiDNqggemZpqCZox(lPXdr34cbXcxOk8QqUIe7b7EsrzCHGysYLhwKDpfBCHGysYLhwKX3qchDAnLIYO5CXqVWXMjOt8kVw3nDmlK73kNj72B7kLdl61F5y(x0HgA4G0TemSqpbZUqoh9JzHC)w5mz3EBxPCyrV(lhZ)Io0qdhKohURhoKWZvVkmMfY9BLZKD7TDLYHf96VCm)l6qdnCq6cK3jlBl62ywi3Vvot2T32vkhw0R)YX8VOdn0WbP7Gonb(CdLpd(M5VYhZc5(TYzYU92Us5WIE9xoM)fDOHgoiD(zqWSdgB(OB4gZc5(TYzYU92Us5WIE9xoM)fDOHgoiD(RqxFwWh2p2MWZgHvaZnugcjT8x4PXdr34cbXcxOk8QqUIe7b7EsrzCHGysYLhwKDpfBCHGysYLhwKX3qcxA60AkfLSBVTRuw4cvHxfYvKypye0jELN2CWGIs2T32vktsU8WImc6eVYtBoymMfY9BLZKD7TDLYHf96VCm)l6qdnCq68xHU(CWpFsOlpBewbm3qziK0YFHNgpeDJleelCHQWRc5ksShS7jfLXfcIjjxEyr29uSXfcIjjxEyrgFdjCPPtRPuuYU92UszHlufEvixrI9GrqN4vEAZbdkkz3EBxPmj5YdlYiOt8kpT5GXywi3Vvot2T32vkhw0R)YX8VOdNgpeDJleelCHQWRc5ksShS7jfLXfcIjjxEyr29uSXfcIjjxEyrgFdjCPPtRPJzHC)w5mz3EBxPCyrV(WfQcVkKRiXEqJhIUihTh(8zxHK00nN49DWAHbf1r7HpF2vijnDtiwK9DW0WGIICveQjciBpWSti88LelYZP4AfCqDfLIAdpQl7O9WNdxOkGegQHHhTILD7TDLYoAp85WfQciHrqN4voDtfvSiPUHh1LXrsCE8omuddpAPOKD7TDLY4ijopEhgbDIx5PnLIAdpQlJhQCFOhT5ksShmuddpAfDmlK73kNj72B7kLdl61ljxEyrA8q0pAp85ZUcjPPBoX77G1cdkQJ2dF(SRqsA6Mq8(oyAyqrTHh1LD0E4ZHlufqcd1WWJwXYU92UszhTh(C4cvbKWiOt8kNUPJzHC)w5mz3EBxPCyrV(GFGA(i8(UAmlK73kNj72B7kLdl61F0E4ZHlufqcnEi677G5TZhNc0nvSigxiiw4cvHxfYvKypy3tkkJleetsU8WIS7jfLXfcIfUqv4vHCfj2dMTRuXYU92UszHlufEvixrI9GrqN4vEAZzkfLXfcIjjxEyrMTRuXYU92UszsYLhwKrqN4vEAZzQOJzHC)w5mz3EBxPCyrVEOxdFMGs4A9vbA8q0f5O9WNp7kKKMU5eVVdwR5rrD0E4ZNDfsst3eI33btt38evSSBVTRuw4cvHxfYvKypye0jELNwqAfVVdM3oFCkq3uXIK6gEuxghjX5X7Wqnm8OLIY4cbX4ijopEh29uuXIKkjEBgDH6YcRLZq3E(YPOiXBZOluxwyTC29KIIeVnJUqDzH1YzVM2CMk6y2agZc5(TYzqV(8dKWP7kiFy4rAOHds3YZYGVHHhPHRWFr68t07ZBqeWLZSVRxXmFBIdD3fNQiKRIqnrazqVg(SlKyF5kEdpQlJ8chl2xE2fsSVCzOggE0kw2Q9(lBrNtFq4zxVAFzSFRmuddpAfLIIFIEFEdIaUCM9D9kM5BtCs7ofLXfcIHoNWtWqZNDfsy3tXw04cbXsX1k4G6YSDLk24cbXSVRxX85LC2CKz7kDmlK73kNb96Zpqchw0RNJK484DOXdrxez3EBxPSWfQcVkKRiXEWiOt8kpnTWGIs2T32vktsU8WImc6eVYttlmOO2WJ6YGEn8zckHR1xfyOggE0kQyrsDdpQld61WNjOeUwFvGHAy4rlfLSBVTRug0RHptqjCT(QaJGoXR8APliT00eIfjvs82m6c1LfwlNHU98LtrrI3MrxOUSWA5SxtBotPOiXBZOluxwyTC2R1kiTuuK4Tz0fQllSwo7EkQOIfj1n8OUm0nuE3V1mh1fvjYqnm8OLIs2T32vkdDdL39BnZrDrvImc6eVYRLUG0sttqrTHh1Lb9A4ZeucxRVkWqnm8OvuXIKQSDHAOldo4jFOuuYU92Usz231RyEBVNrqN4vETWwIsrz0CUyOx4yZe0jELxlTWqm0lCSzc6eVYtdJXSqUFRCg0Rp)ajCyrVE0nuE3V1mh1fvjsJhIUigxiiMKC5Hfz2Usfl72B7kLjjxEyrgbDIx5PP1ukkJleetsU8WIm(gs4st3euuYU92UszHlufEvixrI9GrqN4vEAAnvuXIK6gEuxg0RHptqjCT(Qad1WWJwkkz3EBxPmOxdFMGs4A9vbgbDIx5PP1urfVbrax2(oyE7S9X0M3ywi3Vvod61NFGeoSOxV9D9kM5BtCOXdr3vq(WWJmlpld(ggEuCQgxiiMRqtz3NFGeE(iCCqc7EkwersDdpQltsU8WImuddpAPOKD7TDLYKKlpSiJGoXR80cslnnHOIfj1n8OUm0nuE3V1mh1fvjYqnm8OLIs2T32vkdDdL39BnZrDrvImc6eVYtliT00Kqrj72B7kLHUHY7(TM5OUOkrgbDIx5PfKwAcdXhTh(8zxHK00nhf1gebCz77G5TZ2hR18OOsDdpQlJJK484DyOggE0kw2T32vkdDdL39BnZrDrvImc6eVYtliT00DrflsQB4rDzqVg(mbLW16RcmuddpAPOKD7TDLYGEn8zckHR1xfye0jELNwqAPPjHIs2T32vkd61WNjOeUwFvGrqN4vEAbPLMWq8r7HpF2vijnDZrrL6gEuxghjX5X7Wqnm8OvSSBVTRug0RHptqjCT(QaJGoXR80cslnDxuXIK6gEuxghjX5X7Wqnm8OLIs2T32vkJJK484Dye0jELdBtqAH1r7HpF2vijTjOO2WJ6YGEn8zckHR1xfyOggE0srTHh1LHUHY7(TM5OUOkrgQHHhTuuY2fQHUm4GN8HkkfLiB4rDzhTh(C4cvbKWqnm8OvSSBVTRu2r7HphUqvajmc6eVYRvqAPPjOOmUqqSJ2dFoCHQasy3tkkJleetsU8WIS7PyJleetsU8WIm(gs4QLwtfv0XSqUFRCg0Rp)ajCyrV(fDo9bHNDHe7lxA8q0fj1n8OUmj5YdlYqnm8OLIs2T32vktsU8WImc6eVYtliT00eIkwKu3WJ6Yq3q5D)wZCuxuLid1WWJwkkz3EBxPm0nuE3V1mh1fvjYiOt8kpTG0sttcfLSBVTRug6gkV73AMJ6IQeze0jELNwqAPjmeF0E4ZNDfsst3CuuBqeWLTVdM3oBFSwZJIk1n8OUmosIZJ3HHAy4rRyz3EBxPm0nuE3V1mh1fvjYiOt8kpTG0st3fvSiPUHh1Lb9A4ZeucxRVkWqnm8OLIs2T32vkd61WNjOeUwFvGrqN4vEAbPLMMekkz3EBxPmOxdFMGs4A9vbgbDIx5PfKwAcdXhTh(8zxHK00nhfvQB4rDzCKeNhVdd1WWJwXYU92UszqVg(mbLW16Rcmc6eVYtliT00DrflsQB4rDzCKeNhVdd1WWJwkkz3EBxPmosIZJ3HrqN4voSnbPfwhTh(8zxHK0MGIAdpQld61WNjOeUwFvGHAy4rlf1gEuxg6gkV73AMJ6IQezOggE0srjBxOg6YGdEYhQOuuB4rDzhTh(C4cvbKWqnm8OvSSBVTRu2r7HphUqvajmc6eVYRvqAPPjOOmUqqSJ2dFoCHQasy3tkkJleetsU8WIS7PyJleetsU8WIm(gs4QLwthZgWywi3VvotavKeBt40LH3Nd5(TM9pFPHgoiDOxF(bs404HOF0E4ZNDfsOddkkJlee7O9WNdxOkGe29KIYIgxiig0RHptqjCT(Qa7EsrzrJleedDdL39BnZrDrvIS75ywi3VvotavKeBt4WIE9UcnLDF(bs45JWXbjJzHC)w5mbursSnHdl61BFxVI5T9EA8q0t1IgxiiwkUwbhux29uSiPUHh1LXrsCE8omuddpAPOmUqqmosIZJ3HDpfvSiPsI3MrxOUSWA5m0TNVCkks82m6c1LfwlN9AAtykffjEBgDH6YcRLZUNIkwKJ2dF(SRqsT0DNI6O9WNp7kKulDZjwez3EBxPmdFyXCdLtXLVVeze0jELNwqAPP7uuw04cbXq3q5D)wZCuxuLi7EsrzrJleed61WNjOeUwFvGDpfvuXIK6gEuxg0RHptqjCT(Qad1WWJwkkz3EBxPmOxdFMGs4A9vbgbDIx5PfKwAsRPIkwKu3WJ6Yq3q5D)wZCuxuLid1WWJwkkz3EBxPm0nuE3V1mh1fvjYiOt8kpTG0stAnLIAdIaUS9DW82z7J1AEIkwez3EBxPSWfQcVkKRiXEWiOt8kNIs2T32vktsU8WImc6eVYfDmlK73kNjGksITjCyrV(JWXbj5gkxrI9GgpeDYvrOMiGS9aZoHnFgKqOvkkYvrOMiGmxHkCdILNDAhu3RJ4n8OUm0nuE3V1mh1fvjYqnm8OLIs2Uqn0L5c19aEIyz3EBxPSGFGA(i8(UIrqN4vEA3P10XSqUFRCMaQij2MWHf96tX1k4G6sJhIEQw04cbXsX1k4G6YUNInUqqSJ2dFoCHQasy3ZXSqUFRCMaQij2MWHf96Rc4WCdLd(bYPXdrxKJ2dF(SRqsT0Dx8gEuxg6gkV73AMJ6IQezOggE0k2Igxiig6gkV73AMJ6IQeze0jELN2uXw04cbXq3q5D)wZCuxuLiJGoXR8AfKwA6UOJzHC)w5mbursSnHdl61B4dlMBOCkU89LinEi6hTh(8zxHKAPBcXB4rDzg(WI5gkxrI9GHAy4rRyr2WJ6YGEn8zckHR1xfyOggE0k2Igxiig0RHptqjCT(QaJGoXR80cslnDNIAdpQldDdL39BnZrDrvImuddpAfN6gEuxg0RHptqjCT(Qad1WWJwXIyrJleedDdL39BnZrDrvIS7jfLSBVTRug6gkV73AMJ6IQeze0jELt3urfDmlK73kNjGksITjCyrV(uCTcoOU04HONQfnUqqSuCTcoOUS7P4n8OUmosIZJ3HHAy4rRyroAp85ZUcjPPtRyYvrOMiGS9aZoHWZxsSipNIRvWb1LI6O9WNp7kKKMU7IoMfY9BLZeqfjX2eoSOxFvahMBOCWpqonEi6IC0E4ZNDfsOBkf1r7HpF2viPw6Ulwez3EBxPmdFyXCdLtXLVVeze0jELNwqAPP7uuw04cbXq3q5D)wZCuxuLi7EsrTbrax2(oyE7S9XAnpkklACHGyqVg(mbLW16RcS7POIkwKujXBZOluxwyTCg62ZxoffjEBgDH6YcRLZEnT7MsrrI3MrxOUSWA5S7POIfj1n8OUm0nuE3V1mh1fvjYqnm8OLIs2T32vkdDdL39BnZrDrvImc6eVYttlmOO2GiGlBFhmVD2(yTMNOIfj1n8OUmOxdFMGs4A9vbgQHHhTuuYU92UszqVg(mbLW16Rcmc6eVYttlmOO2GiGlBFhmVD2(yTMNOIfr2T32vklCHQWRc5ksShmc6eVYPOKD7TDLYKKlpSiJGoXRCrhZc5(TYzcOIKyBchw0RxgEFoK73A2)8LgA4G0HE95hiHtJhI(r7HpF2vijnDti24cbXKKlpSi7Ek24cbXKKlpSiJVHeUAP10XSqUFRCMaQij2MWHf96n8HfZnuofx((sKgpe9J2dF(SRqsT0nHyzR27Vm0TZlri2VvgQHHhTItv2Uqn0L5c19aEYywi3VvotavKeBt4WIE9P4AfCqDPXdrpvlACHGyP4AfCqDz3ZXSqUFRCMaQij2MWHf96pchhKKBOCfj2JXSqUFRCMaQij2MWHf96n8HfZnuofx((sKgpe9J2dF(SRqsT0nXywi3VvotavKeBt4WIE9YW7ZHC)wZ(NV0qdhKo0Rp)ajCA8q0fzdIaUSdm87b7uU1s3DtPOmUqqSWfQcVkKRiXEWUNuugxiiMKC5Hfz3tkkJleedDoHNGHMp7kKWUNIoMfY9BLZeqfjX2eoSOxVKC5Hfjz(sE4qA8q0LD7TDLYKKlpSijZxYdhYKhbra5zisi3V1WNMoTSucmelYr7HpF2viPw6UtrD0E4ZNDfsQLUjel72B7kLz4dlMBOCkU89LiJGoXR80cslnDNI6O9WNp7kKq3CILD7TDLYm8HfZnuofx((sKrqN4vEAbPLMUlw2T32vklfxRGdQlJGoXR80cslnDx0XSqUFRCMaQij2MWHf96LTYrjj2VvA8q0tv2khLKy)wz3tX8t07ZBqeWLZSVRxXmFBItA6UpMfY9BLZeqfjX2eoSOxVm8(Ci3V1S)5ln0WbPd96ZpqcFmlK73kNjGksITjCyrVEzRCusI9BLgpe9uLTYrjj2Vv29CmlK73kNjGksITjCyrVEj5YdlsY8L8WHJzHC)w5mbursSnHdl61hezOyEBcb1DmlK73kNjGksITjCyrVEzRCusI9BTK4cj8V1sDUBQ70AQjmnLusQcI(QaVKys1KIjDDMV1z(WKnGbuZboG35Sj7aGAYaGDz3EBxPCyFaemLDFcAhaVDWbe3TDIfTdqEeQaYzJzM8xXb4oTMSbaBA1fsw0oayNCveQjciZ8d7dy7ba7KRIqnrazMFgQHHhTW(aeHw3eLnMnMzs1KIjDDMV1z(WKnGbuZboG35Sj7aGAYaGDOxF(bs4W(aiyk7(e0oaE7GdiUB7elAhG8iubKZgZm5VIdGwt2aGnT6cjlAhaStUkc1ebKz(H9bS9aGDYvrOMiGmZpd1WWJwyFaIqRBIYgZm5VIdWCMSbaBA1fsw0oGK3b2mao86gUnayBdy7byYVXaSVRN)ToG(ejX2Kbis9IoarO1nrzJzM8xXbadt2aGnT6cjlAhqY7aBgahEDd3gaSTbS9am53ya231Z)whqFIKyBYaePErhGi06MOSXSXmtQMumPRZ8ToZhMSbmGAoWb8oNnzhautgaSlGksITjCyFaemLDFcAhaVDWbe3TDIfTdqEeQaYzJzM8xXbyot2aGnT6cjlAhaStUkc1ebKz(H9bS9aGDYvrOMiGmZpd1WWJwyFaIqRBIYgZm5VIdWCMSbaBA1fsw0oayNCveQjciZ8d7dy7ba7KRIqnrazMFgQHHhTW(aeHw3eLnMzYFfhG5zYgaSPvxizr7aGDYvrOMiGmZpSpGThaStUkc1ebKz(zOggE0c7dqeADtu2y2yM5RZztw0oaymGqUFRdW)8LZgZkj(NV8snLelcfx)wQPuhTLAkjHC)wlje04chwsqnm8OTaZYwQZ9snLeuddpAlWSKeY9BTKidVphY9Bn7F(ws8pFZA4GLez3EBxP8YwQZeLAkjOggE0wGzjjK73AjrgEFoK73A2)8TK4F(M1WbljcOIKyBcVSLTKCsqz7yeBPMsD0wQPKeY9BTKC273Ajb1WWJ2cmlBPo3l1usc5(Twsm8iN)QqUHY8RJdskjOggE0wGzzl1zIsnLKqUFRLedpY5VkKBOCC3RJwsqnm8OTaZYwQZCLAkjHC)wljgEKZFvi3q5QxxKusqnm8OTaZYwQdgLAkjHC)wljgEKZFvi3qz(j5vHscQHHhTfyw2sDMKsnLeuddpAlWSKij)IKpkjB4rDzqVg(mbLW16RcmuddpAhG4bSHh1LXrsCE8omuddpAljHC)wljbrgkM3MqqDlBzljcOIKyBcVutPoAl1usqnm8OTaZsIK8ls(OKC0E4ZNDfsga9baJbqrnaJlee7O9WNdxOkGe29CauudWIgxiig0RHptqjCT(Qa7EoakQbyrJleedDdL39BnZrDrvIS7zjjK73AjrgEFoK73A2)8TK4F(M1WbljqV(8dKWlBPo3l1usc5(TwsCfAk7(8dKWZhHJdskjOggE0wGzzl1zIsnLeuddpAlWSKij)IKpkjPoalACHGyP4AfCqDz3ZbiEaImGuhWgEuxghjX5X7Wqnm8ODauudW4cbX4ijopEh29CaIoaXdqKbK6aiXBZOluxwyTCg62Zx(aOOgajEBgDH6YcRLZEDaPhGjmDauudGeVnJUqDzH1Yz3Zbi6aepargWr7HpF2viza1sFaUpakQbC0E4ZNDfsgqT0hG5gG4biYaKD7TDLYm8HfZnuofx((sKrqN4v(aspabPDa0CaUpakQbyrJleedDdL39BnZrDrvIS75aOOgGfnUqqmOxdFMGs4A9vb29CaIoarhG4biYasDaB4rDzqVg(mbLW16RcmuddpAhaf1aKD7TDLYGEn8zckHR1xfye0jELpG0dqqAhanhaTMoarhG4biYasDaB4rDzOBO8UFRzoQlQsKHAy4r7aOOgGSBVTRug6gkV73AMJ6IQeze0jELpG0dqqAhanhaTMoakQbSbrax2(oyE7S9Xbu7amVbi6aepargGSBVTRuw4cvHxfYvKypye0jELpakQbi72B7kLjjxEyrgbDIx5dq0ssi3V1sI9D9kM327lBPoZvQPKGAy4rBbMLej5xK8rjHCveQjciBpWStyZNbjeALHAy4r7aOOga5QiuteqMRqfUbXYZoTdQ71HHAy4r7aepGn8OUm0nuE3V1mh1fvjYqnm8ODauudq2Uqn0L5c19aEYaepaz3EBxPSGFGA(i8(UIrqN4v(aspa3P10ssi3V1sYr44GKCdLRiXEu2sDWOutjb1WWJ2cmljsYVi5JssQdWIgxiiwkUwbhux29CaIhGXfcID0E4ZHlufqc7Ewsc5(TwssX1k4G6w2sDMKsnLeuddpAlWSKij)IKpkjImGJ2dF(SRqYaQL(aCFaIhWgEuxg6gkV73AMJ6IQezOggE0oaXdWIgxiig6gkV73AMJ6IQeze0jELpG0dW0biEaw04cbXq3q5D)wZCuxuLiJGoXR8bu7aeK2bqZb4(aeTKeY9BTKufWH5gkh8dKx2sDPKsnLeuddpAlWSKij)IKpkjhTh(8zxHKbul9byIbiEaB4rDzg(WI5gkxrI9GHAy4r7aepargWgEuxg0RHptqjCT(Qad1WWJ2biEaw04cbXGEn8zckHR1xfye0jELpG0dqqAhanhG7dGIAaB4rDzOBO8UFRzoQlQsKHAy4r7aepGuhWgEuxg0RHptqjCT(Qad1WWJ2biEaImalACHGyOBO8UFRzoQlQsKDphaf1aKD7TDLYq3q5D)wZCuxuLiJGoXR8bqFaMoarhGOLKqUFRLedFyXCdLtXLVVelBPoZRutjb1WWJ2cmljsYVi5JssQdWIgxiiwkUwbhux29CaIhWgEuxghjX5X7Wqnm8ODaIhGid4O9WNp7kKmG00haTdq8aixfHAIaY2dm7ecpFjXI8CkUwbhuxgQHHhTdGIAahTh(8zxHKbKM(aCFaIwsc5(TwssX1k4G6w2sDWwLAkjOggE0wGzjrs(fjFusezahTh(8zxHKbqFaMoakQbC0E4ZNDfsgqT0hG7dq8aezaYU92Uszg(WI5gkNIlFFjYiOt8kFaPhGG0oaAoa3haf1aSOXfcIHUHY7(TM5OUOkr29CauudydIaUS9DW82z7JdO2byEdGIAaw04cbXGEn8zckHR1xfy3Zbi6aeDaIhGidi1bqI3MrxOUSWA5m0TNV8bqrnas82m6c1LfwlN96aspa3nDauudGeVnJUqDzH1Yz3Zbi6aepargqQdydpQldDdL39BnZrDrvImuddpAhaf1aKD7TDLYq3q5D)wZCuxuLiJGoXR8bKEa0cJbqrnGnic4Y23bZBNTpoGAhG5narhG4biYasDaB4rDzqVg(mbLW16RcmuddpAhaf1aKD7TDLYGEn8zckHR1xfye0jELpG0dGwymakQbSbrax2(oyE7S9Xbu7amVbi6aepargGSBVTRuw4cvHxfYvKypye0jELpakQbi72B7kLjjxEyrgbDIx5dq0ssi3V1ssvahMBOCWpqEzl1rRPLAkjOggE0wGzjrs(fjFusoAp85ZUcjdin9byIbiEagxiiMKC5Hfz3ZbiEagxiiMKC5Hfz8nKWnGAhaTMwsc5(TwsKH3Nd5(TM9pFlj(NVznCWsc0Rp)aj8YwQJwAl1usqnm8OTaZsIK8ls(OKC0E4ZNDfsgqT0hGjgG4biB1E)LHUDEjcX(TYqnm8ODaIhqQdq2Uqn0L5c19aEsjjK73AjXWhwm3q5uC57lXYwQJw3l1usqnm8OTaZsIK8ls(OKK6aSOXfcILIRvWb1LDpljHC)wljP4AfCqDlBPoAnrPMssi3V1sYr44GKCdLRiXEusqnm8OTaZYwQJwZvQPKGAy4rBbMLej5xK8rj5O9WNp7kKmGAPpatusc5(Twsm8HfZnuofx((sSSL6OfgLAkjOggE0wGzjrs(fjFusezaBqeWLDGHFpyNYDa1sFaUB6aOOgGXfcIfUqv4vHCfj2d29CauudW4cbXKKlpSi7EoakQbyCHGyOZj8em08zxHe29CaIwsc5(TwsKH3Nd5(TM9pFlj(NVznCWsc0Rp)aj8YwQJwtsPMscQHHhTfywsKKFrYhLez3EBxPmj5YdlsY8L8WHm5rqeqEgIeY9Bn8din9bqllLaJbiEaImGJ2dF(SRqYaQL(aCFauud4O9WNp7kKmGAPpatmaXdq2T32vkZWhwm3q5uC57lrgbDIx5di9aeK2bqZb4(aOOgWr7HpF2viza0hG5gG4bi72B7kLz4dlMBOCkU89LiJGoXR8bKEacs7aO5aCFaIhGSBVTRuwkUwbhuxgbDIx5di9aeK2bqZb4(aeTKeY9BTKijxEyrsMVKhoSSL6OnLuQPKGAy4rBbMLej5xK8rjj1biBLJssSFRS75aepa(j695nic4Yz231RyMVnXzaPPpa3ljHC)wljYw5OKe73Azl1rR5vQPKGAy4rBbMLKqUFRLez495qUFRz)Z3sI)5BwdhSKa96ZpqcVSL6Of2Qutjb1WWJ2cmljsYVi5JssQdq2khLKy)wz3Zssi3V1sISvokjX(Tw2sDUBAPMssi3V1sIKC5Hfjz(sE4WscQHHhTfyw2sDUtBPMssi3V1ssqKHI5Tjeu3scQHHhTfyw2sDU7EPMssi3V1sISvokjX(Twsqnm8OTaZYw2sc0Rp)aj8snL6OTutjb1WWJ2cmlj9zjHJBjjK73AjXvq(WWJLexH)ILe(j695nic4Yz231RyMVnXza0hG7dq8asDaImaYvrOMiGmOxdF2fsSVCzOggE0oaXdydpQlJ8chl2xE2fsSVCzOggE0oaXdq2Q9(lBrNtFq4zxVAFzSFRmuddpAhGOdGIAa8t07ZBqeWLZSVRxXmFBIZaspa3haf1amUqqm05eEcgA(SRqc7EoaXdWIgxiiwkUwbhuxMTR0biEagxiiM9D9kMpVKZMJmBxPLexbjRHdwsS8Sm4By4XYwQZ9snLeuddpAlWSKij)IKpkjImaz3EBxPSWfQcVkKRiXEWiOt8kFaPhaTWyauudq2T32vktsU8WImc6eVYhq6bqlmgaf1a2WJ6YGEn8zckHR1xfyOggE0oarhG4biYasDaB4rDzqVg(mbLW16RcmuddpAhaf1aKD7TDLYGEn8zckHR1xfye0jELpGAPpabPDa0CaMyaIhGidi1bqI3MrxOUSWA5m0TNV8bqrnas82m6c1LfwlN96aspaZz6aOOgajEBgDH6YcRLZEDa1oabPDauudGeVnJUqDzH1Yz3Zbi6aeDaIhGidi1bSHh1LHUHY7(TM5OUOkrgQHHhTdGIAaYU92UszOBO8UFRzoQlQsKrqN4v(aQL(aeK2bqZbyIbqrnGn8OUmOxdFMGs4A9vbgQHHhTdq0biEaImGuhGSDHAOldo4jFOdGIAaYU92Usz231RyEBVNrqN4v(aQDaWwdq0bqrnaJMZhG4ba9chBMGoXR8bu7aOfgdq8aGEHJntqN4v(aspayusc5(Tws4ijopENYwQZeLAkjOggE0wGzjrs(fjFusezagxiiMKC5Hfz2UshG4bi72B7kLjjxEyrgbDIx5di9aO10bqrnaJleetsU8WIm(gs4gqA6dWedGIAaYU92UszHlufEvixrI9GrqN4v(aspaAnDaIoaXdqKbK6a2WJ6YGEn8zckHR1xfyOggE0oakQbi72B7kLb9A4ZeucxRVkWiOt8kFaPhaTMoarhG4bSbrax2(oyE7S9XbKEaMxjjK73AjbDdL39BnZrDrvILTuN5k1usqnm8OTaZsIK8ls(OK4kiFy4rMLNLbFddpoaXdi1byCHGyUcnLDF(bs45JWXbjS75aepargGidi1bSHh1LjjxEyrgQHHhTdGIAaYU92UszsYLhwKrqN4v(aspabPDa0CaMyaIoaXdqKbK6a2WJ6Yq3q5D)wZCuxuLid1WWJ2bqrnaz3EBxPm0nuE3V1mh1fvjYiOt8kFaPhGG0oaAoatYaOOgGSBVTRug6gkV73AMJ6IQeze0jELpG0dqqAhanhamgG4bC0E4ZNDfsgqA6dWCdGIAaBqeWLTVdM3oBFCa1oaZBauudi1bSHh1LXrsCE8omuddpAhG4bi72B7kLHUHY7(TM5OUOkrgbDIx5di9aeK2bqZb4(aeDaIhGidi1bSHh1Lb9A4ZeucxRVkWqnm8ODauudq2T32vkd61WNjOeUwFvGrqN4v(aspabPDa0CaMKbqrnaz3EBxPmOxdFMGs4A9vbgbDIx5di9aeK2bqZbaJbiEahTh(8zxHKbKM(am3aOOgqQdydpQlJJK484DyOggE0oaXdq2T32vkd61WNjOeUwFvGrqN4v(aspabPDa0CaUparhG4biYasDaB4rDzCKeNhVdd1WWJ2bqrnaz3EBxPmosIZJ3HrqN4v(aQFacs7aG1aoAp85ZUcjdi9amXaOOgWgEuxg0RHptqjCT(Qad1WWJ2bqrnGn8OUm0nuE3V1mh1fvjYqnm8ODauudq2Uqn0Lbh8Kp0bi6aOOgGidydpQl7O9WNdxOkGegQHHhTdq8aKD7TDLYoAp85WfQciHrqN4v(aQDacs7aO5amXaOOgGXfcID0E4ZHlufqc7EoakQbyCHGysYLhwKDphG4byCHGysYLhwKX3qc3aQDa0A6aeDaIwsc5(TwsSVRxXmFBItzl1bJsnLeuddpAlWSKij)IKpkjImGuhWgEuxMKC5HfzOggE0oakQbi72B7kLjjxEyrgbDIx5di9aeK2bqZbyIbi6aepargqQdydpQldDdL39BnZrDrvImuddpAhaf1aKD7TDLYq3q5D)wZCuxuLiJGoXR8bKEacs7aO5amjdGIAaYU92UszOBO8UFRzoQlQsKrqN4v(aspabPDa0CaWyaIhWr7HpF2vizaPPpaZnakQbSbrax2(oyE7S9Xbu7amVbqrnGuhWgEuxghjX5X7Wqnm8ODaIhGSBVTRug6gkV73AMJ6IQeze0jELpG0dqqAhanhG7dq0biEaImGuhWgEuxg0RHptqjCT(Qad1WWJ2bqrnaz3EBxPmOxdFMGs4A9vbgbDIx5di9aeK2bqZbysgaf1aKD7TDLYGEn8zckHR1xfye0jELpG0dqqAhanhamgG4bC0E4ZNDfsgqA6dWCdGIAaPoGn8OUmosIZJ3HHAy4r7aepaz3EBxPmOxdFMGs4A9vbgbDIx5di9aeK2bqZb4(aeDaIhGidi1bSHh1LXrsCE8omuddpAhaf1aKD7TDLY4ijopEhgbDIx5dO(biiTdawd4O9WNp7kKmG0dWedGIAaB4rDzqVg(mbLW16RcmuddpAhaf1a2WJ6Yq3q5D)wZCuxuLid1WWJ2bqrnaz7c1qxgCWt(qhGOdGIAaB4rDzhTh(C4cvbKWqnm8ODaIhGSBVTRu2r7HphUqvajmc6eVYhqTdqqAhanhGjgaf1amUqqSJ2dFoCHQasy3ZbqrnaJleetsU8WIS75aepaJleetsU8WIm(gs4gqTdGwtljHC)wljl6C6dcp7cj2xULTSLez3EBxP8snL6OTutjb1WWJ2cmljsYVi5JsIXfcIfUqv4vHCfj2d29CauudW4cbXKKlpSi7EoaXdW4cbXKKlpSiJVHeUbqFa0A6aOOgGrZ5dq8aGEHJntqN4v(aQDaUdJssi3V1sYzVFRLTuN7LAkjOggE0wGzjrs(fjFus4NO3N3GiGlN5FHJLNtX1k4G6oG00hG7dGIAaPoas82m6c1LfwlNHU98LpakQbqI3MrxOUSWA5Sxhq6bKsGXaOOgajEBgDH6YcRLZUNLKqUFRLe)lCS8CkUwbhu3YwQZeLAkjOggE0wGzjrs(fjFusmUqqSWfQcVkKRiXEWUNdGIAagxiiMKC5Hfz3ZbiEagxiiMKC5Hfz8nKWna6dGwtljHC)wljqpbn8DBlBPoZvQPKGAy4rBbMLej5xK8rjrKbK6a2WJ6Yq3q5D)wZCuxuLid1WWJ2bqrnaz3EBxPm0nuE3V1mh1fvjYiOt8kFa1oay4(aeDaIha0lCSzc6eVYhq6bqlmkjHC)wlj8Jh92CdLDHQagQelBPoyuQPKeY9BTKy4ro)vHCdL5xhhKusqnm8OTaZYwQZKuQPKeY9BTKy4ro)vHCdLJ7ED0scQHHhTfyw2sDPKsnLKqUFRLedpY5VkKBOC1RlskjOggE0wGzzl1zELAkjHC)wljgEKZFvi3qz(j5vHscQHHhTfyw2sDWwLAkjOggE0wGzjjK73Aj5vUKC3WWJ5u2n096KTORxILej5xK8rjX4cbXcxOk8QqUIe7b7EoakQbyCHGysYLhwKDphG4byCHGysYLhwKX3qc3aOpaAnDauudWO58biEaqVWXMjOt8kFa1oatyAjrdhSK8kxsUBy4XCk7g6EDYw01lXYwQJwtl1usqnm8OTaZssi3V1ss7cjvhO35vH8zxHKSKapFdFjrs(fjFusmUqqSWfQcVkKRiXEWUNdGIAagxiiMKC5Hfz3ZbiEagxiiMKC5Hfz8nKWna6dGwthaf1amAoFaIha0lCSzc6eVYhqTdGwyus0WbljTlKuDGENxfYNDfsYsc88n8LTuhT0wQPKGAy4rBbMLKqUFRLeBqGZPBnBrjCzxnjK)cFjrs(fjFusmUqqSWfQcVkKRiXEWUNdGIAagxiiMKC5Hfz3ZbiEagxiiMKC5Hfz8nKWna6dGwthaf1amAoFaIha0lCSzc6eVYhqTdWDtljA4GLeBqGZPBnBrjCzxnjK)cFzl1rR7LAkjOggE0wGzjjK73AjXjKHbbZ8de3SZL)YsIK8ls(OKyCHGyHlufEvixrI9GDphaf1amUqqmj5YdlYUNdq8amUqqmj5YdlY4BiHBa0haTMoakQby0C(aepaOx4yZe0jELpGAhG7Mws0WbljoHmmiyMFG4MDU8xw2sD0AIsnLeuddpAlWSKOHdwsSemSqpbZUqoh9LKqUFRLelbdl0tWSlKZrFzl1rR5k1usqnm8OTaZsIgoyjHd31dhs45QxfkjHC)wljC4UE4qcpx9Qqzl1rlmk1usqnm8OTaZsIgoyjrG8ozzBr3kjHC)wljcK3jlBl6wzl1rRjPutjb1WWJ2cmljA4GLeh0PjWNBO8zW3m)vEjjK73AjXbDAc85gkFg8nZFLx2sD0Msk1usqnm8OTaZsIgoyjHFgem7GXMp6gUssi3V1sc)miy2bJnF0nCLTuhTMxPMscQHHhTfywsc5(Tws4VcD9zbFy)yBcpBewbm3qziK0YFHVKij)IKpkjgxiiw4cvHxfYvKypy3ZbqrnaJleetsU8WIS75aepaJleetsU8WIm(gs4gqA6dGwthaf1aKD7TDLYcxOk8QqUIe7bJGoXR8bKEaMdgdGIAaYU92UszsYLhwKrqN4v(aspaZbJsIgoyjH)k01Nf8H9JTj8SryfWCdLHqsl)f(YwQJwyRsnLeuddpAlWSKeY9BTKWFf66Zb)8jHU8SryfWCdLHqsl)f(sIK8ls(OKyCHGyHlufEvixrI9GDphaf1amUqqmj5YdlYUNdq8amUqqmj5YdlY4BiHBaPPpaAnDauudq2T32vklCHQWRc5ksShmc6eVYhq6byoymakQbi72B7kLjjxEyrgbDIx5di9amhmkjA4GLe(RqxFo4Npj0LNncRaMBOmesA5VWx2sDUBAPMscQHHhTfywsKKFrYhLeJleelCHQWRc5ksShS75aOOgGXfcIjjxEyr29CaIhGXfcIjjxEyrgFdjCdin9bqRPLKqUFRLKlhZ)Io8YwQZDAl1usqnm8OTaZsIK8ls(OKiYaoAp85ZUcjdin9byUbiEa77GdO2baJbqrnGJ2dF(SRqYastFaMyaIhGidyFhCaPhamgaf1aixfHAIaY2dm7ecpFjXI8CkUwbhuxgQHHhTdq0bqrnGn8OUSJ2dFoCHQasyOggE0oaXdq2T32vk7O9WNdxOkGegbDIx5dG(amDaIoaXdqKbK6a2WJ6Y4ijopEhgQHHhTdGIAaYU92UszCKeNhVdJGoXR8bKEaMoakQbSHh1LXdvUp0J2Cfj2dgQHHhTdq0ssi3V1ss4cvHxfYvKypkBPo3DVutjb1WWJ2cmljsYVi5JsYr7HpF2vizaPPpaZnaXdyFhCa1oaymakQbC0E4ZNDfsgqA6dWedq8a23bhq6baJbqrnGn8OUSJ2dFoCHQasyOggE0oaXdq2T32vk7O9WNdxOkGegbDIx5dG(amTKeY9BTKijxEyXYwQZDtuQPKeY9BTKe8duZhH33vLeuddpAlWSSL6C3CLAkjOggE0wGzjrs(fjFus23bZBNpofga9by6aepargGXfcIfUqv4vHCfj2d29CauudW4cbXKKlpSi7EoakQbyCHGyHlufEvixrI9Gz7kDaIhGSBVTRuw4cvHxfYvKypye0jELpG0dWCMoakQbyCHGysYLhwKz7kDaIhGSBVTRuMKC5Hfze0jELpG0dWCMoarljHC)wljhTh(C4cvbKu2sDUdJsnLeuddpAlWSKij)IKpkjImGJ2dF(SRqYastFaMBaIhW(o4aQDaM3aOOgWr7HpF2vizaPPpatmaXdyFhCaPPpaZBaIoaXdq2T32vklCHQWRc5ksShmc6eVYhq6biiTdq8a23bZBNpofga9by6aepargqQdydpQlJJK484DyOggE0oakQbyCHGyCKeNhVd7EoarhG4biYasDaK4Tz0fQllSwodD75lFauudGeVnJUqDzH1Yz3Zbqrnas82m6c1LfwlN96aspaZz6aeTKeY9BTKa9A4ZeucxRVku2Yw2ssC3JMussEhytzlBPa]] )


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
