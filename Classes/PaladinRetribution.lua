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
                    duration = 8,
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


    spec:RegisterPack( "Retribution", 20210307, [[dKu(hbqiHQEecP6scfPnjeFcHKgLQKtPkAvQc1ReQmlvPClsfv1Ui8ljvggr4yejlJuPNHqmnHcxtvQ2gPc13ivKXrQGZHqkzDcfL5jPQ7HG9jPCqesPwOQGhsQOCrHIQ2iPIk(iPIQCsHIkRKi1mrif3uOi0ofknuHIGLsQqEkPmvsv9vsfvAScfr7vWFLyWGoSOftspgvtMQUm0MvvFMOgTI60aRwviVgHA2u52Ky3u(TudxroocjwosphLPRY1vy7cPVljJNuLZtenFeTFLoivq)GMppmeRUsORusqej0jHU6QlrIHooODsoHbTPKtCkJbnlvWGMocpkqDCG2cAtPKUo9b9dASEq5yqlOPoaUlMZcQbnFEyiwDLqxPKGisOtcD1vxIedIe0ytipeRojrqBg49OfudAEKXdA6i8Oa1XbABHXesx6b2kDmXKYNxOuVTqDLqxPwPxP1zZPjJSy2kTo)fQJqxQ3c1qAonduwifjkdafvq7w4VPl0bmGjVWX0cRa38cJ51t7TfQZrhjcAt0(dCyqJOt0xOocpkqDCG2wymH0LEGTst0j6lmMys5ZluQ3wOUsORuR0R0eDI(c1zZPjJSy2knrNOVqD(luhHUuVfQH0CAgOSqksugakQG2TWFtxOdyatEHJPfwbU5fgZRN2BluNJosSsVsN8d0gtmrrEROMhHP(aTTsN8d0gtmrrEROMxCeQt1HmgWKl9VWgkkiDLo5hOnMyII8wrnV4iuNQdzmGjx6Fjh3qXwPt(bAJjMOiVvuZloc1P6qgdyYL(xQa2H0v6KFG2yIjkYBf18IJqDQoKXaMCP)f2efyYR0j)aTXetuK3kQ5fhH6skpnSCnLI2TsVWvAIorFHX86H8XH(fIrrQKl8ak4cVzCHj)A6cbSfMrtGlvDOyLo5hOngbkQoigxPt(bAJfhH64PZvs(bAR4aS7nlvqc8UD(UYyR0j)aTXIJqD805kj)aTvCa29MLkibz0qAEnLTsVWv6KFG2ycE3oFxzmct9bA7nWNG64)fzu0KbMCPIM3SymrsQo(FbNoyPhfJPiQJ)xWPdw6rb7soXeKscsYpqE(kuujbgREDFFLo5hOnMG3TZ3vgloc15aYZhR8OHxwbT7nWNaBcDUYLuz8ychqE(yLhn8YkOD1iOlj5R4PjWxWOODI07zcupa7yKK0e4lyu0or69mbWQPtV)CLo5hOnMG3TZ3vgloc19buu11T)nWNG64)fzu0KbMCPIM3SymrsQo(FbNoyPhfJPiQJ)xWPdw6rb7soXeKsIv6KFG2ycE3oFxzS4iuhBgGoFP)LOOjJPXX3aFcVI)shANa1d5Jd0wHH2HghfOLQo0tsY7257ktG6H8XbARWq7qJJckQKaJv)76(mYhipFfkQKaJvtQ3xPt(bAJj4D78DLXIJqDQoKXaMCP)f2qrbPR0j)aTXe8UD(UYyXrOovhYyatU0)soUHITsN8d0gtW7257kJfhH6uDiJbm5s)lva7q6kDYpqBmbVBNVRmwCeQt1HmgWKl9VWMOatELo5hOnMG3TZ3vgloc1nyybCOYBwQGeagJthxQ6WcrzK2nukEmkGJVb(euh)ViJIMmWKlv08MfJjss1X)l40bl9OymfrD8)coDWspkyxYjMGusqs(bYZxHIkjWy1tejwPt(bAJj4D78DLXIJqDdgwahQ8MLkiHoksRMrNcWKltDfslCQKSlDVb(euh)ViJIMmWKlv08MfJjss1X)l40bl9OymfrD8)coDWspkyxYjMGusqs(bYZxHIkjWy1l17R0j)aTXe8UD(UYyXrOUbdlGdvEZsfKGpPeR0Tv8iN4s0MMCWj5BGpb1X)lYOOjdm5sfnVzXyIKuD8)coDWspkgtruh)VGthS0Jc2LCIjiLeKKFG88vOOscmw96kXkDYpqBmbVBNVRmwCeQBWWc4qL3SubjOK8uLIf2mIxrzWa83aFcQJ)xKrrtgyYLkAEZIXejP64)fC6GLEumMIOo(FbNoyPhfSl5etqkjij)a55RqrLeyS61vIv6KFG2ycE3oFxzS4iu3GHfWHkVzPcsWtX0)buSefzm0TsN8d0gtW7257kJfhH6gmSaou5nlvqcmIhoIrkRubm5v6KFG2ycE3oFxzS4iu3GHfWHkVzPcsqMcuk82J6TsN8d0gtW7257kJfhH6gmSaou5nlvqckOstLS0)YuYUcdySv6KFG2ycE3oFxzS4iu3GHfWHkVzPcsGnLuSOG5vM7M4v6KFG2ycE3oFxzS4iu3GHfWHkVzPcsGbS)WvKDPhKxtzf10lJL(x(iT5GtY3aFcQJ)xKrrtgyYLkAEZIXejP64)fC6GLEumMIOo(FbNoyPhfSl5exJGusqsY7257ktKrrtgyYLkAEZckQKaJvlgVtsY7257ktWPdw6rbfvsGXQfJ3xPt(bAJj4D78DLXIJqDdgwahQ8MLkibgW(dxjztaAAhROMEzS0)YhPnhCs(g4tqD8)ImkAYatUurZBwmMijvh)VGthS0JIXue1X)l40bl9OGDjN4AeKscssE3oFxzImkAYatUurZBwqrLeySAX4DssE3oFxzcoDWspkOOscmwTy8(kDYpqBmbVBNVRmwCeQBWWc4qf2BGpb1X)lYOOjdm5sfnVzXyIKuD8)coDWspkgtruh)VGthS0Jc2LCIRrqkjwPt(bAJj4D78DLXIJqDzu0KbMCPIM38BGpHxZTtYYuxH0AeIrKdOG1)oj5C7KSm1viTgbIe51buWAVtsshg(BQmkUzSOKYa2rZdzLhn8YkODpjjV0H2jMBNKLmkAYivGwQ6qFeE3oFxzI52jzjJIMmsfuujbgJGepJ8k(lDODcgsZPzGIaTu1HEssE3oFxzcgsZPzGIGIkjWy1K45kDYpqBmbVBNVRmwCeQJthS0JVb(eMBNKLPUcP1ieJihqbR)DsY52jzzQRqAncejYbuWAVtsEPdTtm3ojlzu0KrQaTu1H(i8UD(UYeZTtYsgfnzKkOOscmgbjwPt(bAJj4D78DLXIJqDjBgTYC6CD1kDYpqBmbVBNVRmwCeQBUDswYOOjJ03aFchqblxxMNKjirKxVuh)ViJIMmWKlv08MfJjss1X)l40bl9Oym9KK8L64)fzu0KbMCPIM3SW3vweE3oFxzImkAYatUurZBwqrLeySAXqcss1X)l40bl9OW3vweE3oFxzcoDWspkOOscmwTyiXZNR0j)aTXe8UD(UYyXrOUpWsxHICIBdyYVb(eMBNKLPUcP1iqKi8UD(UYezu0KbMCPIM3SGIkjWy1K5(ihqblxxMNKjirKxXFPdTtWqAondueOLQo0tsQo(FbdP50mqrmMEUsVWv6KFG2yIpWaSzKYienPGu1HVzPcsWZk8KDPQdFlA6gib2e6CLlPY4XeEquGHf21uLAe0LKuD8)cuzsskMwzQRqQymfXJQJ)x8OHxwbTt47klI64)fEquGHLPbDQzOW3v2kDYpqBmXhya2mszXrOogsZPzGYBGpHxVI)shANGthS0Jc0svh6J8I3TZ3vMiJIMmWKlv08MfuujbgRMUVtsY7257ktKrrtgyYLkAEZckQKaJrqINpjjFDPdTtG6H8XbARWq7qJJc0svh6JCPdTt8bw6kuKtCBatwGwQ6q)tsYxQJ)xWPdw6rXyIKK3TZ3vMGthS0JckQKaJvtQ3F(mYR4V0H2j(alDfkYjUnGjlqlvDONKK3TZ3vM4dS0vOiN42aMSGIkjWy1RdKK8UD(UYeFGLUcf5e3gWKfuujbgRwmE)zKxXFPdTtG6H8XbARWq7qJJc0svh6jj5D78DLjq9q(4aTvyODOXrbfvsGXQxhij5D78DLjq9q(4aTvyODOXrbfvsGXQfJ3FUsN8d0gt8bgGnJuwCeQlAAeLbGnJuwzovuq6BGpHxXFPdTt8bw6kuKtCBatwGwQ6qpjjVBNVRmXhyPRqroXTbmzbfvsGXQjZ9pwkjij9O64)fFGLUcf5e3gWKfJPNrEf)Lo0obQhYhhOTcdTdnokqlvDONKK3TZ3vMa1d5Jd0wHH2HghfuujbgRMm3)yPKGK0JQJ)xG6H8XbARWq7qJJIX0tss2e6CLlPY4XeEquGHf21uLAe0DLo5hOnM4dmaBgPS4iuhQhYhhOTcdTdno(g4t41R4V0H2j40bl9OaTu1HEss1X)l40bl9OW3vweE3oFxzcoDWspkOOscmwnPK4jjP64)fC6GLEuWUKtCnceHKK3TZ3vMiJIMmWKlv08MfuujbgRMusqs6r1X)l(alDfkYjUnGjlgtpJCafSCDzEsMGerUKkJN4aky56IhG10Hv6KFG2yIpWaSzKYIJqDEquGHf21uL3aFcrtkivDOWZk8KDPQdJeV64)frtJOmaSzKYkZPIcsfJPiVEf)Lo0obNoyPhfOLQo0tsY7257ktWPdw6rbfvsGXQjZ9pMipJ8k(lDODcupKpoqBfgAhACuGwQ6qpj5lE3oFxzcupKpoqBfgAhACuqrLeySyQm3h3C7KSm1viTMorsEjvgpXbuWY1fpaRxhE(mYR4V0H2j(alDfkYjUnGjlqlvDONKK3TZ3vM4dS0vOiN42aMSGIkjWyXuzUpU52jzzQRqAnD6zKxXFPdTtWqAondueOLQo0tsY7257ktWqAondueuujbglMkZ9Xn3ojltDfsRrKNKKSj05kxsLXJj8GOadlSRPk1iOBKxx6q7eZTtYsgfnzKkqlvDOpcVBNVRmXC7KSKrrtgPckQKaJvVm3)yIqsQo(FbNoyPhfJPiQJ)xWPdw6rb7soX1lLepFUsN8d0gt8bgGnJuwCeQ7qLjxszLOi1d43BGpHxXFPdTtWPdw6rbAPQd9KK8UD(UYeC6GLEuqrLeySAYC)JjYZiVI)shANa1d5Jd0wHH2HghfOLQo0ts(I3TZ3vMa1d5Jd0wHH2HghfuujbglMkZ9Xn3ojltDfsRPtKKxsLXtCafSCDXdW61HNpJ8k(lDODIpWsxHICIBdyYc0svh6jj5D78DLj(alDfkYjUnGjlOOscmwmvM7JBUDswM6kKwtNEg5v88okAPDcd5021uVaTu1HEssE3oFxzIOPruga2mszL5urbPckQKaJvtM7Fg5v8x6q7emKMtZafbAPQd9KK8UD(UYemKMtZafbfvsGXIPYCFCZTtYYuxH0Ae5jj5Lo0oXC7KSKrrtgPc0svh6JW7257ktm3ojlzu0KrQGIkjWy1lZ9pMiKKQJ)xm3ojlzu0KrQymrsQo(FbNoyPhfJPiQJ)xWPdw6rb7soX1lLeR0lCLo5hOnMqgnKMxtze4PZvs(bAR4aS7nlvqcFGbyZiL9g4tyUDswM6kKs4Dss1X)lMBNKLmkAYivmMij9O64)fFGLUcf5e3gWKfJjsspQo(FbQhYhhOTcdTdnokgtR0j)aTXeYOH08Akloc15brbgwU25Ed8jeVhvh)V4rdVScANymf5v80e4lyu0or69mbQhGDmssAc8fmkANi9EMay1iIepJ8AUDswM6kKwpbDjjNBNKLPUcP1tigrEX7257ktO6spw6F5rd2b4OGIkjWy1K5(hRlj5lpQo(FbQhYhhOTcdTdnokgtKKxsLXtCafSCDXdW61HNKKEuD8)IpWsxHICIBdyYIX0ZNrEf)Lo0oXhyPRqroXTbmzbAPQd9KK8UD(UYeFGLUcf5e3gWKfuujbgRMm3)yPK4zKxXFPdTtG6H8XbARWq7qJJc0svh6jjFX7257ktG6H8XbARWq7qJJckQKaJvtM7FSusqsEjvgpXbuWY1fpaRxhE(mYlE3oFxzImkAYatUurZBwqrLeySAsqsY7257ktWPdw6rbfvsGXQjXZv6KFG2ycz0qAEnLfhH6QsIXs)ljBgzVb(eEn3ojltDfsjibj5C7KSm1viTEc6g5fVBNVRmHQl9yP)LhnyhGJckQKaJvtM7FSUKKV8O64)fOEiFCG2km0o04OymrsEjvgpXbuWY1fpaRxhEss6r1X)l(alDfkYjUnGjlgtpFg5v80e4lyu0or69mbQhGDmssAc8fmkANi9EMay10vINrEf)Lo0obQhYhhOTcdTdnokqlvDONKK3TZ3vMa1d5Jd0wHH2HghfuujbgRMuV)mYR4V0H2j(alDfkYjUnGjlqlvDONKK3TZ3vM4dS0vOiN42aMSGIkjWy1K69NrEX7257ktKrrtgyYLkAEZckQKaJvtcssE3oFxzcoDWspkOOscmwnjEUsN8d0gtiJgsZRPS4iuNQl9yP)LhnyhGJVb(eMBNKLPUcP1tGirU0H2jq9q(4aTvyODOXrbAPQd9rE5r1X)lq9q(4aTvyODOXrXyIKK3TZ3vMa1d5Jd0wHH2HghfuujbgJGepxPt(bAJjKrdP51uwCeQBovuqAP)LkAEZR0j)aTXeYOH08Akloc1XtNRK8d0wXby3BwQGe(adWMrk7nWNWC7KSm1viTgbIerD8)coDWspkgtruh)VGthS0Jc2LCIRxkjwPt(bAJjKrdP51uwCeQt1LES0)YJgSdWX3aFcZTtYYuxH06jqKv6KFG2ycz0qAEnLfhH6E0WlRG29g4tiEpQo(FXJgEzf0oXyALo5hOnMqgnKMxtzXrOoE6CLKFG2koa7EZsfKWhya2mszVb(eEDjvgpXmMUBwmXV6jOReKKQJ)xKrrtgyYLkAEZIXejP64)fC6GLEumMijvh)VavMKKIPvM6kKkgtpxPt(bAJjKrdP51uwCeQJthS0J0c7OaIX3aFc8UD(UYeC6GLEKwyhfqmk4ZjvgzLpn5hOT0vJGucD69iVMBNKLPUcP1tqxsY52jzzQRqA9eiseE3oFxzcvx6Xs)lpAWoahfuujbgRMm3)yDjjNBNKLPUcPeIreE3oFxzcvx6Xs)lpAWoahfuujbgRMm3)yDJW7257kt8OHxwbTtqrLeySAYC)J195kDYpqBmHmAinVMYIJqD82yiNMhOT3aFcXZBJHCAEG2eJPiSj05kxsLXJj8GOadlSRPk1iO7kDYpqBmHmAinVMYIJqD805kj)aTvCa29MLkiHpWaSzKYwPt(bAJjKrdP51uwCeQJ3gd508aT9g4tiEEBmKtZd0MymTsN8d0gtiJgsZRPS4iuhNoyPhPf2rbeJR0j)aTXeYOH08Akloc1LuEAy5AkfTBLo5hOnMqgnKMxtzXrOoEBmKtZd0wqlkszG2cXQRe6kLesPBmcAvj1aMmlOPZLOTok2yUy15fZw4c1FgxiqzQP3c)nDHevE3oFxzmI6cPirzaOOFHSwbxyoUwjp0Vq(CAYitSst0amCH6kvmBH6S2II0d9lKOshg(BQmkIjjQl86fsuPdd)nvgfXKc0svh6jQl8Lu69uSsVsRZLOTok2yUy15fZw4c1FgxiqzQP3c)nDHe1pWaSzKYiQlKIeLbGI(fYAfCH54AL8q)c5ZPjJmXknrdWWf(EmBH6S2II0d9ludOOZwits7s9wymDHxVqIMrUqpikGbABH9esZRPl8vDpx4lIO3tXknrdWWfQJJzluN1wuKEOFHAafD2czsAxQ3cJPl86fs0mYf6brbmqBlSNqAEnDHVQ75cFre9EkwPjAagUqDCmBH6S2II0d9lKOY7OOL2jIjfOLQo0tux41lKOY7OOL2jIjjQl8Lu69uSsVshZPm10d9l89fM8d02cDa2XeR0bnhGDSG(bnp(ZH7c6hIvQG(bTKFG2cAuuDqmg0qlvDOp8q4cXQBq)GgAPQd9HhcAj)aTf04PZvs(bAR4aSlO5aSRyPcg04D78DLXcxiwIe0pOHwQ6qF4HGwYpqBbnE6CLKFG2koa7cAoa7kwQGbnz0qAEnLfUWf0MOiVvuZlOFiwPc6h0s(bAlOn1hOTGgAPQd9HhcxiwDd6h0s(bAlOP6qgdyYL(xydffKg0qlvDOp8q4cXsKG(bTKFG2cAQoKXaMCP)LCCdflOHwQ6qF4HWfIngb9dAj)aTf0uDiJbm5s)lva7qAqdTu1H(WdHle77b9dAj)aTf0uDiJbm5s)lSjkWKdAOLQo0hEiCHy1Xb9dAj)aTf0skpnSCnLI2f0qlvDOp8q4cxqtgnKMxtzb9dXkvq)GgAPQd9HhcACk4qkidAZTtYYuxH0fsyHVVqsYfQo(FXC7KSKrrtgPIX0cjjxOhvh)V4dS0vOiN42aMSymTqsYf6r1X)lq9q(4aTvyODOXrXykOL8d0wqJNoxj5hOTIdWUGMdWUILkyq7dmaBgPSWfIv3G(bn0svh6dpe04uWHuqg0IFHEuD8)Ihn8YkODIX0cJSWxlm(fstGVGrr7eP3ZeOEa2Xwij5cPjWxWOODI07zcGTWAlKisSWNlmYcFTW52jzzQRq6cRNWc1DHKKlCUDswM6kKUW6jSWySWil81c5D78DLjuDPhl9V8Ob7aCuqrLeySfwBHYC)cF8c1DHKKl81c9O64)fOEiFCG2km0o04OymTqsYfEjvgpXbuWY1fpaxy9luhw4ZfssUqpQo(FXhyPRqroXTbmzXyAHpx4ZfgzHVwy8l8shAN4dS0vOiN42aMSaTu1H(fssUqE3oFxzIpWsxHICIBdyYckQKaJTWAluM7x4JxOusSWNlmYcFTW4x4Lo0obQhYhhOTcdTdnokqlvDOFHKKl81c5D78DLjq9q(4aTvyODOXrbfvsGXwyTfkZ9l8Xlukjwij5cVKkJN4aky56IhGlS(fQdl85cFUWil81c5D78DLjYOOjdm5sfnVzbfvsGXwyTfkXcjjxiVBNVRmbNoyPhfuujbgBH1wOel8zql5hOTGMhefyy5ANlCHyjsq)GgAPQd9HhcACk4qkidAVw4C7KSm1viDHewOelKKCHZTtYYuxH0fwpHfQ7cJSWxlK3TZ3vMq1LES0)YJgSdWrbfvsGXwyTfkZ9l8Xlu3fssUWxl0JQJ)xG6H8XbARWq7qJJIX0cjjx4Luz8ehqblxx8aCH1VqDyHpxij5c9O64)fFGLUcf5e3gWKfJPf(CHpxyKf(AHXVqAc8fmkANi9EMa1dWo2cjjxinb(cgfTtKEptaSfwBH6kXcFUWil81cJFHx6q7eOEiFCG2km0o04OaTu1H(fssUqE3oFxzcupKpoqBfgAhACuqrLeySfwBHs9(cFUWil81cJFHx6q7eFGLUcf5e3gWKfOLQo0VqsYfY7257kt8bw6kuKtCBatwqrLeySfwBHs9(cFUWil81c5D78DLjYOOjdm5sfnVzbfvsGXwyTfkXcjjxiVBNVRmbNoyPhfuujbgBH1wOel8zql5hOTGwvsmw6FjzZilCHyJrq)GgAPQd9HhcACk4qkidAZTtYYuxH0fwpHfsKfgzHx6q7eOEiFCG2km0o04OaTu1H(fgzHVwOhvh)Va1d5Jd0wHH2HghfJPfssUqE3oFxzcupKpoqBfgAhACuqrLeySfsyHsSWNbTKFG2cAQU0JL(xE0GDaogUqSVh0pOL8d0wqBovuqAP)LkAEZbn0svh6dpeUqS64G(bn0svh6dpe04uWHuqg0MBNKLPUcPlSgHfsKfgzHQJ)xWPdw6rXyAHrwO64)fC6GLEuWUKt8cRFHsjrql5hOTGgpDUsYpqBfhGDbnhGDflvWG2hya2mszHleRof0pOHwQ6qF4HGgNcoKcYG2C7KSm1viDH1tyHejOL8d0wqt1LES0)YJgSdWXWfIvhc6h0qlvDOp8qqJtbhsbzql(f6r1X)lE0WlRG2jgtbTKFG2cApA4Lvq7cxiwIwb9dAOLQo0hEiOXPGdPGmO9AHxsLXtmJP7Mft8BH1tyH6kXcjjxO64)fzu0KbMCPIM3SymTqsYfQo(FbNoyPhfJPfssUq1X)lqLjjPyALPUcPIX0cFg0s(bAlOXtNRK8d0wXbyxqZbyxXsfmO9bgGnJuw4cXkLeb9dAOLQo0hEiOXPGdPGmOX7257ktWPdw6rAHDuaXOGpNuzKv(0KFG2s3cRryHsj0P3xyKf(AHZTtYYuxH0fwpHfQ7cjjx4C7KSm1viDH1tyHezHrwiVBNVRmHQl9yP)LhnyhGJckQKaJTWAluM7x4JxOUlKKCHZTtYYuxH0fsyHXyHrwiVBNVRmHQl9yP)LhnyhGJckQKaJTWAluM7x4JxOUlmYc5D78DLjE0WlRG2jOOscm2cRTqzUFHpEH6UWNbTKFG2cAC6GLEKwyhfqmgUqSsjvq)GgAPQd9HhcACk4qkidAXVqEBmKtZd0MymTWilKnHox5sQmEmHhefyyHDnvzH1iSqDdAj)aTf04TXqonpqBHleRu6g0pOHwQ6qF4HGwYpqBbnE6CLKFG2koa7cAoa7kwQGbTpWaSzKYcxiwPisq)GgAPQd9HhcACk4qkidAXVqEBmKtZd0Mymf0s(bAlOXBJHCAEG2cxiwPIrq)GwYpqBbnoDWspslSJcigdAOLQo0hEiCHyL69G(bTKFG2cAjLNgwUMsr7cAOLQo0hEiCHyLshh0pOL8d0wqJ3gd508aTf0qlvDOp8q4cxq7dmaBgPSG(HyLkOFqdTu1H(WdbTEkOXWlOL8d0wqlAsbPQddArt3adASj05kxsLXJj8GOadlSRPklSgHfQ7cjjxO64)fOYKKumTYuxHuXyAHrwOhvh)V4rdVScANW3v2cJSq1X)l8GOadltd6uZqHVRSGw0KwSubdAEwHNSlvDy4cXQBq)GgAPQd9HhcACk4qkidAVw4Rfg)cV0H2j40bl9OaTu1H(fgzHVwiVBNVRmrgfnzGjxQO5nlOOscm2cRTqDFFHKKlK3TZ3vMiJIMmWKlv08MfuujbgBHewOel85cFUqsYf(AHx6q7eOEiFCG2km0o04OaTu1H(fgzHx6q7eFGLUcf5e3gWKfOLQo0VWNlKKCHVwO64)fC6GLEumMwij5c5D78DLj40bl9OGIkjWylS2cL69f(CHpxyKf(AHXVWlDODIpWsxHICIBdyYc0svh6xij5c5D78DLj(alDfkYjUnGjlOOscm2cRFH6WcjjxiVBNVRmXhyPRqroXTbmzbfvsGXwyTfgJ3x4ZfgzHVwy8l8shANa1d5Jd0wHH2HghfOLQo0VqsYfY7257ktG6H8XbARWq7qJJckQKaJTW6xOoSqsYfY7257ktG6H8XbARWq7qJJckQKaJTWAlmgVVWNbTKFG2cAmKMtZaLWfILib9dAOLQo0hEiOXPGdPGmO9AHXVWlDODIpWsxHICIBdyYc0svh6xij5c5D78DLj(alDfkYjUnGjlOOscm2cRTqzUFHpEHsjXcjjxOhvh)V4dS0vOiN42aMSymTWNlmYcFTW4x4Lo0obQhYhhOTcdTdnokqlvDOFHKKlK3TZ3vMa1d5Jd0wHH2HghfuujbgBH1wOm3VWhVqPKyHKKl0JQJ)xG6H8XbARWq7qJJIX0cFUqsYfYMqNRCjvgpMWdIcmSWUMQSWAewOUbTKFG2cArtJOmaSzKYkZPIcsdxi2ye0pOHwQ6qF4HGgNcoKcYG2Rf(AHXVWlDODcoDWspkqlvDOFHKKluD8)coDWspk8DLTWilK3TZ3vMGthS0JckQKaJTWAlukjw4ZfssUq1X)l40bl9OGDjN4fwJWcjYcjjxiVBNVRmrgfnzGjxQO5nlOOscm2cRTqPKyHKKl0JQJ)x8bw6kuKtCBatwmMw4ZfgzHhqblxxMNKxiHfkXcJSWlPY4joGcwUU4b4cRTqDiOL8d0wqd1d5Jd0wHH2Hghdxi23d6h0qlvDOp8qqJtbhsbzqlAsbPQdfEwHNSlvD4cJSW4xO64)frtJOmaSzKYkZPIcsfJPfgzHVw4Rfg)cV0H2j40bl9OaTu1H(fssUqE3oFxzcoDWspkOOscm2cRTqzUFHpEHezHpxyKf(AHXVWlDODcupKpoqBfgAhACuGwQ6q)cjjx4RfY7257ktG6H8XbARWq7qJJckQKaJTW6wOm3VW4w4C7KSm1viDH1wOoTqsYfEjvgpXbuWY1fpaxy9luhw4Zf(CHrw4Rfg)cV0H2j(alDfkYjUnGjlqlvDOFHKKlK3TZ3vM4dS0vOiN42aMSGIkjWylSUfkZ9lmUfo3ojltDfsxyTfQtl85cJSWxlm(fEPdTtWqAondueOLQo0VqsYfY7257ktWqAondueuujbgBH1TqzUFHXTW52jzzQRq6cRTqISWNlKKCHSj05kxsLXJj8GOadlSRPklSgHfQ7cJSWxl8shANyUDswYOOjJubAPQd9lmYc5D78DLjMBNKLmkAYivqrLeySfw)cL5(f(4fsKfssUq1X)l40bl9OymTWiluD8)coDWspkyxYjEH1VqPKyHpx4ZGwYpqBbnpikWWc7AQs4cXQJd6h0qlvDOp8qqJtbhsbzq71cJFHx6q7eC6GLEuGwQ6q)cjjxiVBNVRmbNoyPhfuujbgBH1wOm3VWhVqISWNlmYcFTW4x4Lo0obQhYhhOTcdTdnokqlvDOFHKKl81c5D78DLjq9q(4aTvyODOXrbfvsGXwyDluM7xyClCUDswM6kKUWAluNwij5cVKkJN4aky56IhGlS(fQdl85cFUWil81cJFHx6q7eFGLUcf5e3gWKfOLQo0VqsYfY7257kt8bw6kuKtCBatwqrLeySfw3cL5(fg3cNBNKLPUcPlS2c1Pf(CHrw4Rfg)c5Du0s7egYPTRP(fssUqE3oFxzIOPruga2mszL5urbPckQKaJTWAluM7x4ZfgzHVwy8l8shANGH0CAgOiqlvDOFHKKlK3TZ3vMGH0CAgOiOOscm2cRBHYC)cJBHZTtYYuxH0fwBHezHpxij5cV0H2jMBNKLmkAYivGwQ6q)cJSqE3oFxzI52jzjJIMmsfuujbgBH1VqzUFHpEHezHKKluD8)I52jzjJIMmsfJPfssUq1X)l40bl9OymTWiluD8)coDWspkyxYjEH1VqPKiOL8d0wq7qLjxszLOi1d4x4cxqJ3TZ3vglOFiwPc6h0qlvDOp8qqJtbhsbzqtD8)ImkAYatUurZBwmMwij5cvh)VGthS0JIX0cJSq1X)l40bl9OGDjN4fsyHsjXcjjx4hipFfkQKaJTW6xOUVh0s(bAlOn1hOTWfIv3G(bn0svh6dpe04uWHuqg0ytOZvUKkJht4aYZhR8OHxwbTBH1iSqDxij5cFTW4xinb(cgfTtKEptG6byhBHKKlKMaFbJI2jsVNja2cRTqD69f(mOL8d0wqZbKNpw5rdVScAx4cXsKG(bn0svh6dpe04uWHuqg0uh)ViJIMmWKlv08MfJPfssUq1X)l40bl9OymTWiluD8)coDWspkyxYjEHewOuse0s(bAlO9buu11TpCHyJrq)GgAPQd9HhcACk4qkidAVwy8l8shANa1d5Jd0wHH2HghfOLQo0VqsYfY7257ktG6H8XbARWq7qJJckQKaJTW6x476UWNlmYc)a55RqrLeySfwBHs9Eql5hOTGgBgGoFP)LOOjJPXXWfI99G(bTKFG2cAQoKXaMCP)f2qrbPbn0svh6dpeUqS64G(bTKFG2cAQoKXaMCP)LCCdflOHwQ6qF4HWfIvNc6h0s(bAlOP6qgdyYL(xQa2H0GgAPQd9HhcxiwDiOFql5hOTGMQdzmGjx6FHnrbMCqdTu1H(WdHlelrRG(bn0svh6dpe0s(bAlObmgNoUu1HfIYiTBOu8yuahdACk4qkidAQJ)xKrrtgyYLkAEZIX0cjjxO64)fC6GLEumMwyKfQo(FbNoyPhfSl5eVqclukjwij5c)a55RqrLeySfw)cjIebnlvWGgWyC64svhwikJ0UHsXJrbCmCHyLsIG(bn0svh6dpe0s(bAlO1rrA1m6uaMCzQRqAHtLKDPlOXPGdPGmOPo(FrgfnzGjxQO5nlgtlKKCHQJ)xWPdw6rXyAHrwO64)fC6GLEuWUKt8cjSqPKyHKKl8dKNVcfvsGXwy9luQ3dAwQGbToksRMrNcWKltDfslCQKSlDHleRusf0pOHwQ6qF4HGwYpqBbnFsjwPBR4roXLOnn5GtYGgNcoKcYGM64)fzu0KbMCPIM3SymTqsYfQo(FbNoyPhfJPfgzHQJ)xWPdw6rb7soXlKWcLsIfssUWpqE(kuujbgBH1VqDLiOzPcg08jLyLUTIh5exI20KdojdxiwP0nOFqdTu1H(WdbTKFG2cAkjpvPyHnJ4vugmapOXPGdPGmOPo(FrgfnzGjxQO5nlgtlKKCHQJ)xWPdw6rXyAHrwO64)fC6GLEuWUKt8cjSqPKyHKKl8dKNVcfvsGXwy9luxjcAwQGbnLKNQuSWMr8kkdgGhUqSsrKG(bn0svh6dpe0SubdAEkM(pGILOiJHUGwYpqBbnpft)hqXsuKXqx4cXkvmc6h0qlvDOp8qqZsfmOXiE4igPSsfWKdAj)aTf0yepCeJuwPcyYHleRuVh0pOHwQ6qF4HGMLkyqtMcuk82J6f0s(bAlOjtbkfE7r9cxiwP0Xb9dAOLQo0hEiOzPcg0uqLMkzP)LPKDfgWybTKFG2cAkOstLS0)YuYUcdySWfIvkDkOFqdTu1H(WdbnlvWGgBkPyrbZRm3nXbTKFG2cASPKIffmVYC3ehUqSsPdb9dAOLQo0hEiOL8d0wqJbS)WvKDPhKxtzf10lJL(x(iT5GtYGgNcoKcYGM64)fzu0KbMCPIM3SymTqsYfQo(FbNoyPhfJPfgzHQJ)xWPdw6rb7soXlSgHfkLelKKCH8UD(UYezu0KbMCPIM3SGIkjWylS2cJX7lKKCH8UD(UYeC6GLEuqrLeySfwBHX49GMLkyqJbS)WvKDPhKxtzf10lJL(x(iT5GtYWfIvkIwb9dAOLQo0hEiOL8d0wqJbS)Wvs2eGM2XkQPxgl9V8rAZbNKbnofCifKbn1X)lYOOjdm5sfnVzXyAHKKluD8)coDWspkgtlmYcvh)VGthS0Jc2LCIxynclukjwij5c5D78DLjYOOjdm5sfnVzbfvsGXwyTfgJ3xij5c5D78DLj40bl9OGIkjWylS2cJX7bnlvWGgdy)HRKSjanTJvutVmw6F5J0MdojdxiwDLiOFqdTu1H(WdbnofCifKbn1X)lYOOjdm5sfnVzXyAHKKluD8)coDWspkgtlmYcvh)VGthS0Jc2LCIxynclukjcAj)aTf0gmSaouHfUqS6kvq)GgAPQd9HhcACk4qkidAVw4C7KSm1viDH1iSWySWil8ak4cRFHVVqsYfo3ojltDfsxynclKilmYcFTWdOGlS2cFFHKKlKom83uzuCZyrjLbSJMhYkpA4Lvq7eOLQo0VWNlKKCHx6q7eZTtYsgfnzKkqlvDOFHrwiVBNVRmXC7KSKrrtgPckQKaJTqcluIf(CHrw4Rfg)cV0H2jyinNMbkc0svh6xij5c5D78DLjyinNMbkckQKaJTWAluIf(mOL8d0wqlJIMmWKlv08MdxiwD1nOFqdTu1H(WdbnofCifKbT52jzzQRq6cRryHXyHrw4buWfw)cFFHKKlCUDswM6kKUWAewirwyKfEafCH1w47lKKCHx6q7eZTtYsgfnzKkqlvDOFHrwiVBNVRmXC7KSKrrtgPckQKaJTqcluIGwYpqBbnoDWspgUqS6sKG(bTKFG2cAjBgTYC6CDvqdTu1H(WdHleRUXiOFqdTu1H(WdbnofCifKbTdOGLRlZtYlKWcLyHrw4Rf(AHQJ)xKrrtgyYLkAEZIX0cjjxO64)fC6GLEumMw4ZfssUWxluD8)ImkAYatUurZBw47kBHrwiVBNVRmrgfnzGjxQO5nlOOscm2cRTWyiXcjjxO64)fC6GLEu47kBHrwiVBNVRmbNoyPhfuujbgBH1wymKyHpx4ZGwYpqBbT52jzjJIMmsdxiwDFpOFqdTu1H(WdbnofCifKbT52jzzQRq6cRryHezHrwiVBNVRmrgfnzGjxQO5nlOOscm2cRTqzUFHrw4buWY1L5j5fsyHsSWil81cJFHx6q7emKMtZafbAPQd9lKKCHQJ)xWqAondueJPf(mOL8d0wq7dS0vOiN42aMC4cx4cA54MBAqtdOOZcx4cba]] )


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
