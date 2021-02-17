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


    spec:RegisterPack( "Retribution", 20210124, [[dGuXebqijv9isv4savjBsi9jGQOrPO6uaLvPOOxjPywkkDlHQqTlu9ljLggr0XisTmsv9msvAAiuDnGkBtOQY3ivrJdOQoNqvW6aQcZdHY9qW(eIdkuLQwOKkpuOk6IcvvzJcvP0hfQcPtkuvvRKizMavP2PqLHkuLklvOk5PK0ufk(QqvigRqvk2RG)kXGbDyrlMepgLjtLldTzaFMOgnqoTQwTIcVgHmBQ62KYUP8BPgUICCHQYYr65eMUkxxHTtQ8Djz8cLopry(iA)kDq6qmbvxEyio9LuFPLuA9joxY4bIRxIRFq9KycdQtjJOugdQwQHb14fE0xzCFBb1PucFNUqmbvrpOmmOguvgV)I)TGsq1LhgItFj1xAjLwFIZLmEG46vV6zqvmHSqC6PKbvqVZHwqjO6qblOQh6XcJx4rFLX9TTW4DPpDVTsPh6XcLkTrsLyH6t8zxO(sQV0RuRu6HESW4jO0Krb4XkLEOhlmE8cJxOpJDHQinNa9AlKIX34POgA3cbA6c9V9M8chtlS6pqlm(lw1zxy824fpOorBG3Jbv9qpwy8cp6RmUVTfgVl9P7Tvk9qpwOuPnsQeluFIp7c1xs9LELALsp0JfgpbLMmkapwP0d9yHXJxy8c9zSlufP5eOxBHum(gpf1q7wiqtxO)T3Kx4yAHv)bAHXFXQo7cJ3gV4RuRuj7(2e8jkYAnL8im1332kvYUVnbFIISwtjVAiuRIhfI3Klnqrm00q6kvYUVnbFIISwtjVAiuRIhfI3Klnqjh3qZwPs29Tj4tuK1Ak5vdHAv8Oq8MCPbkvVDiDLkz33MGprrwRPKxneQvXJcXBYLgOiMOVjVsLS7BtWNOiR1uYRgc1MuwAy5AkfTBLAHRu6HESW4Vyr24q3crDivIfEVgUWdeUWKDnDHVyHPU89PIh5Ruj7(2eeOOYGiCLkz33MOgc1YsVVKS7BR4FXnRLAibw3ExxzIvQKDFBIAiull9(sYUVTI)f3SwQHeKrdP51uXk1cxPs29Tj4SU9UUYeeM67BB2hGWCLbaaxX3TZpehNIj7ijvgaa8uhAYVjxQO5bIpMIQmaa4Po0KFtUurZdeNIA5BIisd(KKkdaaoJoePd5JPOkdaaoJoePd5uulFtqm9bhyRuj7(2eCw3ExxzIAiuR)LbDIYmgozn0UzFacIj07lxsLXtW9VmOtuMXWjRH2fHG(KKZRNMVRG6q74PZj4ySV4eKK08DfuhAhpDob)Ti6j4aBLkz33MGZ6276ktudHAbEkQ472n7dqqzaaWtDOj)MCPIMhi(yIKuzaaWz0HiDiFmfvzaaWz0HiDixCjJicsl5kvYUVnbN1T31vMOgc1ka9O3vAGIo0KX0y4kvYUVnbN1T31vMOgc1Q4rH4n5sduednnKUsLS7BtWzD7DDLjQHqTkEuiEtU0aLCCdnBLkz33MGZ6276ktudHAv8Oq8MCPbkvVDiDLkz33MGZ6276ktudHAv8Oq8MCPbkIj6BYRuj7(2eCw3ExxzIAiu7qGL)qTzTudj8MGrhxQ4Xs8ns7gAfhQ7z4SpabLbaap1HM8BYLkAEG4JjssLbaaNrhI0H8XuuLbaaNrhI0HCXLmIIqqAjjjzD7DDLXtDOj)MCPIMhiof1Y3erio4ijzD7DDLXz0HiDiNIA5BIiehCRuj7(2eCw3ExxzIAiu7qGL)qTzTudj06qAfi0R9MCzQRqAHrLqCPF2hGGYaaGN6qt(n5sfnpq8XejPYaaGZOdr6q(ykQYaaGZOdr6qU4sgrriiTKRuj7(2eCw3ExxzIAiu7qGL)qTzTudj4skrADBfhYiQORPj7pjM9biOmaa4Po0KFtUurZdeFmrsQmaa4m6qKoKpMIQmaa4m6qKoKlUKruecsl5kvYUVnbN1T31vMOgc1oey5puBwl1qcAjlvOyracXROnepB2hGGYaaGN6qt(n5sfnpq8XejPYaaGZOdr6q(ykQYaaGZOdr6qU4sgrriiTKRuj7(2eCw3ExxzIAiu7qGL)qTzTudj4Oy6aEkw0Hcb6xPs29Tj4SU9UUYe1qO2Hal)HAZAPgsqq0WtesfLQ3KxPs29Tj4SU9UUYe1qO2Hal)HAZAPgsqM(Afw7WyxPs29Tj4SU9UUYe1qO2Hal)HAZAPgsqd1AQeLgOmLIRiEtSsLS7BtWzD7DDLjQHqTdbw(d1M1snKGykPyrdZRaQBIwPs29Tj4SU9UUYe1qO2Hal)HAZAPgsq8gWWxK9P7ZRPIIs6KXsduaqAZ(tIzFackdaaEQdn53Klv08aXhtKKkdaaoJoePd5JPOkdaaoJoePd5IlzefHG0sssY6276kJN6qt(n5sfnpqCkQLVjIqCWrsY6276kJZOdr6qof1Y3erio4wPs29Tj4SU9UUYe1qO2Hal)HAZAPgsq8gWWxsX0tt7efL0jJLgOaG0M9NeZ(aeugaa8uhAYVjxQO5bIpMijvgaaCgDishYhtrvgaaCgDishYfxYikcbPLKKK1T31vgp1HM8BYLkAEG4uulFteH4GJKK1T31vgNrhI0HCkQLVjIqCWTsLS7BtWzD7DDLjQHqTdbw(d1eZ(aeugaa8uhAYVjxQO5bIpMijvgaaCgDishYhtrvgaaCgDishYfxYikcbPLCLkz33MGZ6276ktudHAtDOj)MCPIMhOzFacZb1EjktDfsJqG4rVxdjg4ijb1EjktDfsJqqVrVxdJaosYl9ODCqTxIsQdnzKYrlv8OlkRBVRRmoO2lrj1HMms5uulFtqqsWIoV(l9ODCbsZjqVghTuXJossw3ExxzCbsZjqVgNIA5BIisc2kvYUVnbN1T31vMOgc1YOdr6WzFacZb1EjktDfsJqG4rVxdjg4ijb1EjktDfsJqqVrVxdJaosYl9ODCqTxIsQdnzKYrlv8OlkRBVRRmoO2lrj1HMms5uulFtqqsWwPs29Tj4SU9UUYe1qO2uacTcO077QvQKDFBcoRBVRRmrneQfu7LOK6qtgPZ(aeUxdlxxanjtqYOZNRmaa4Po0KFtUurZdeFmrsQmaa4m6qKoKpMaJKCUYaaGN6qt(n5sfnpqCxxzrzD7DDLXtDOj)MCPIMhiof1Y3eriUKKKkdaaoJoePd5UUYIY6276kJZOdr6qof1Y3eriUKGb2kvYUVnbN1T31vMOgc1c8w6luKruBVjp7dqau7LOm1vincb9gL1T31vgp1HM8BYLkAEG4uulFterM5IEVgwUUaAsMGKrNx)LE0oUaP5eOxJJwQ4rhjPYaaGlqAob614JjWwPw4kvYUVnbh4TxacPcc6s6NkECwl1qcorHLIlv84S6s)ajiMqVVCjvgpb396EdlIRPAriOpjPYaaGJAtsqX0ktDfs5JPOouzaaWNXWjRH2XDDLfvzaaWDVU3WY0Go1cK76kBLkz33MGd82laHurneQvG0Cc0Rn7dqy(86V0J2Xz0HiDihTuXJUOZzD7DDLXtDOj)MCPIMhiof1Y3er0hCKKSU9UUY4Po0KFtUurZdeNIA5BccscgyKKZV0J2XXyr24(2kc0o0yihTuXJUOx6r74aVL(cfze12BYC0sfp6aJKCUYaaGZOdr6q(yIKK1T31vgNrhI0HCkQLVjIOp4adSOZR)spAhh4T0xOiJO2EtMJwQ4rhjjRBVRRmoWBPVqrgrT9MmNIA5BcIb(KKSU9UUY4aVL(cfze12BYCkQLVjIqCWbw051FPhTJJXISX9TveODOXqoAPIhDKKSU9UUY4ySiBCFBfbAhAmKtrT8nbXaFssw3ExxzCmwKnUVTIaTdngYPOw(MicXbhyrVxdlxxanjtqYvQKDFBcoWBVaesf1qOwDPfFJxacPIcOutdPZ(aeMx)LE0ooWBPVqrgrT9MmhTuXJossw3ExxzCG3sFHImIA7nzof1Y3erKzUzkTKKKouzaaWbEl9fkYiQT3K5JjWIoV(l9ODCmwKnUVTIaTdngYrlv8OJKK1T31vghJfzJ7BRiq7qJHCkQLVjIiZCZuAjjjDOYaaGJXISX9TveODOXq(ycmssXe69LlPY4j4Ux3ByrCnvlcb9xPs29Tj4aV9cqivudHAXyr24(2kc0o0y4SpaH5ZR)spAhNrhI0HC0sfp6ijvgaaCgDishYDDLfL1T31vgNrhI0HCkQLVjIiTKGrsQmaa4m6qKoKlUKruec6LKK1T31vgp1HM8BYLkAEG4uulFterAjjjDOYaaGd8w6luKruBVjZhtGf9EnSCDb0KmbjJEjvgp(9Ay56I7XiG)kvYUVnbh4TxacPIAiuR719gwext1M9biOlPFQ4rUtuyP4sfpgTELbaaxxAX34fGqQOak10qkFmfD(86V0J2Xz0HiDihTuXJossw3ExxzCgDishYPOw(MiImZnt9cw051FPhTJJXISX9TveODOXqoAPIhDKKZzD7DDLXXyr24(2kc0o0yiNIA5BcWlzMRgqTxIYuxH0i6jj5Luz843RHLRlUhjg4dgyrNx)LE0ooWBPVqrgrT9MmhTuXJossw3ExxzCG3sFHImIA7nzof1Y3eGxYmxnGAVeLPUcPr0tWijftO3xUKkJNG7EDVHfX1uTie0p68l9ODCqTxIsQdnzKYrlv8OlkRBVRRmoO2lrj1HMms5uulFtqmzMBM6LKuzaaWz0HiDiFmfvzaaWz0HiDixCjJiIjTKGb2kvYUVnbh4TxacPIAiu7HAt(Kkk6qQ7z3SpaH51FPhTJZOdr6qoAPIhDKKSU9UUY4m6qKoKtrT8nrezMBM6fSOZR)spAhhJfzJ7BRiq7qJHC0sfp6ijNZ6276kJJXISX9TveODOXqof1Y3eGxYmxnGAVeLPUcPr0tsYlPY4XVxdlxxCpsmWhmWIoV(l9ODCG3sFHImIA7nzoAPIhDKKSU9UUY4aVL(cfze12BYCkQLVjaVKzUAa1EjktDfsJONGfDE9SwhAPDCdz023uhhTuXJossw3ExxzCDPfFJxacPIcOutdPCkQLVjIiZCGrsEPhTJdQ9susDOjJuoAPIhDrzD7DDLXb1EjkPo0KrkNIA5BcIjZCZuVKKkdaaoO2lrj1HMms5JjssLbaaNrhI0H8XuuLbaaNrhI0HCXLmIiM0sssQmaa46sl(gVaesffqPMgs5JPvQfUsLS7BtWLrdP51ubbw69LKDFBf)lUzTudja82laHuXSpabqTxIYuxHucGJKuzaaWb1EjkPo0KrkFmrs6qLbaah4T0xOiJO2EtMpMijDOYaaGJXISX9TveODOXq(yALkz33MGlJgsZRPIAiuR719gwU27N9biuVdvgaa8zmCYAOD8Xu051tZ3vqDOD805eCm2xCcssA(UcQdTJNoNG)we9kjyrNdQ9suM6kKsmc6tscQ9suM6kKsmcep6Cw3ExxzCfF6WsduMXqCpd5uulFterM5MP(KKZDOYaaGJXISX9TveODOXq(yIK8sQmE871WY1f3Jed8bJK0HkdaaoWBPVqrgrT9MmFmbgyrNx)LE0ooWBPVqrgrT9MmhTuXJossw3ExxzCG3sFHImIA7nzof1Y3erKzUzkTKGfDE9x6r74ySiBCFBfbAhAmKJwQ4rhj5Cw3ExxzCmwKnUVTIaTdngYPOw(MiImZntPLKK8sQmE871WY1f3Jed8bdSOZzD7DDLXtDOj)MCPIMhiof1Y3erKKKK1T31vgNrhI0HCkQLVjIijyRuj7(2eCz0qAEnvudHARsIWsdusbium7dqyoO2lrzQRqkbjjjb1EjktDfsjgb9JoN1T31vgxXNoS0aLzme3Zqof1Y3erKzUzQpj5ChQmaa4ySiBCFBfbAhAmKpMijVKkJh)EnSCDX9iXaFWijDOYaaGd8w6luKruBVjZhtGbw051tZ3vqDOD805eCm2xCcssA(UcQdTJNoNG)we9LeSOZR)spAhhJfzJ7BRiq7qJHC0sfp6ijzD7DDLXXyr24(2kc0o0yiNIA5BIisdoWIoV(l9ODCG3sFHImIA7nzoAPIhDKKSU9UUY4aVL(cfze12BYCkQLVjIin4al6Cw3Exxz8uhAYVjxQO5bItrT8nrejjjzD7DDLXz0HiDiNIA5BIisc2kvYUVnbxgnKMxtf1qOwfF6WsduMXqCpdN9biaQ9suM6kKsmc6n6LE0ooglYg33wrG2Hgd5OLkE0fDUdvgaaCmwKnUVTIaTdngYhtKKSU9UUY4ySiBCFBfbAhAmKtrT8nbbjbBLkz33MGlJgsZRPIAiulOutdPLgOurZd0kvYUVnbxgnKMxtf1qOwfF6WsduMXqCpdN9biaQ9suM6kKsmc6DLkz33MGlJgsZRPIAiu7mgozn0UzFac17qLbaaFgdNSgAhFmTsLS7BtWLrdP51urneQLLEFjz33wX)IBwl1qcaV9cqivm7dqy(Luz84GW0FG4tSJye0xsssLbaap1HM8BYLkAEG4JjssLbaaNrhI0H8XejPYaaGJAtsqX0ktDfs5JjWwPs29Tj4YOH08AQOgc1YOdr6qArC0NiC2hGaRBVRRmoJoePdPfXrFIqodusLrrbGMS7Bl9riinxpbx05GAVeLPUcPeJG(KKGAVeLPUcPeJGEJY6276kJR4thwAGYmgI7ziNIA5BIiYm3m1NKeu7LOm1viLaXJY6276kJR4thwAGYmgI7ziNIA5BIiYm3m1pkRBVRRm(mgozn0oof1Y3erKzUzQpyRuj7(2eCz0qAEnvudHAzTjqgnVVTzFac1ZAtGmAEFB8XuuXe69LlPY4j4Ux3ByrCnvlcb9xPs29Tj4YOH08AQOgc1YsVVKS7BR4FXnRLAibG3EbiKkwPs29Tj4YOH08AQOgc1YAtGmAEFBZ(aeQN1Maz08(24JPvQKDFBcUmAinVMkQHqTm6qKoKweh9jcxPs29Tj4YOH08AQOgc1MuwAy5AkfTBLkz33MGlJgsZRPIAiulRnbYO59Tn7dq4EnSCDb0KCezMlOQdPIVTqC6lP(slP0sRNb1QKAVjlcQXJeVpEfx8FCXJcESWfgdiCHV2utVfc00fcEc82laHub45cPy8nEk6wOO1WfMJR1YdDlKbknzuWxPaVFdxi4apwy8SnDi9q3cvFT45cfsyxg7cbVw41le8EKl096EX32c7jKMxtx48AbBHZ1pwW4RuG3VHlm(bESW4zB6q6HUfQ(AXZfkKWUm2fcETWRxi49ixO719IVTf2tinVMUW51c2cNRFSGXxPaVFdxy8d8yHXZ20H0dDle8K16qlTJhVHJwQ4rh45cVEHGNSwhAPD84nGNlCU0XcgFLALk(xBQPh6wi4wyYUVTf6FXj4Rubv)loriMGQdbYH)cXeIt6qmb1KDFBbvkQmicdQOLkE0fQlCH40petqfTuXJUqDb1KDFBbvw69LKDFBf)lUGQ)fxXsnmOY6276kteUqC6netqfTuXJUqDb1KDFBbvw69LKDFBf)lUGQ)fxXsnmOkJgsZRPIWfUG6efzTMsEHycXjDiMGAYUVTG6uFFBbv0sfp6c1fUqC6hIjOMS7BlOQ4rH4n5sduednnKgurlv8Olux4cXP3qmb1KDFBbvfpkeVjxAGsoUHMfurlv8Olux4cXr8qmb1KDFBbvfpkeVjxAGs1BhsdQOLkE0fQlCH4axiMGAYUVTGQIhfI3KlnqrmrFtoOIwQ4rxOUWfIl(fIjOMS7BlOMuwAy5AkfTlOIwQ4rxOUWfUGQmAinVMkcXeIt6qmbv0sfp6c1fuz0)q6NbvqTxIYuxH0fsyHGBHKKluzaaWb1EjkPo0KrkFmTqsYf6qLbaah4T0xOiJO2EtMpMwij5cDOYaaGJXISX9TveODOXq(ykOMS7BlOYsVVKS7BR4FXfu9V4kwQHbvG3EbiKkcxio9dXeurlv8OluxqLr)dPFguRFHouzaaWNXWjRH2Xhtlm6cNVW6xinFxb1H2XtNtWXyFXjwij5cP57kOo0oE6Cc(BlmYc1RKleSfgDHZxiO2lrzQRq6cjgHfQ)cjjxiO2lrzQRq6cjgHfs8fgDHZxiRBVRRmUIpDyPbkZyiUNHCkQLVjwyKfkZClCMlu)fssUW5l0HkdaaoglYg33wrG2Hgd5JPfssUWlPY4XVxdlxxCpUqITqWFHGTqsYf6qLbaah4T0xOiJO2EtMpMwiyleSfgDHZxy9l8spAhh4T0xOiJO2EtMJwQ4r3cjjxiRBVRRmoWBPVqrgrT9MmNIA5BIfgzHYm3cN5cLwYfc2cJUW5lS(fEPhTJJXISX9TveODOXqoAPIhDlKKCHZxiRBVRRmoglYg33wrG2Hgd5uulFtSWiluM5w4mxO0sUqsYfEjvgp(9Ay56I7XfsSfc(leSfc2cJUW5lK1T31vgp1HM8BYLkAEG4uulFtSWiluYfssUqw3ExxzCgDishYPOw(MyHrwOKleSGAYUVTGQ719gwU27dxio9gIjOIwQ4rxOUGkJ(hs)mOoFHGAVeLPUcPlKWcLCHKKleu7LOm1viDHeJWc1FHrx48fY6276kJR4thwAGYmgI7ziNIA5BIfgzHYm3cN5c1FHKKlC(cDOYaaGJXISX9TveODOXq(yAHKKl8sQmE871WY1f3JlKyle8xiylKKCHouzaaWbEl9fkYiQT3K5JPfc2cbBHrx48fw)cP57kOo0oE6Ccog7loXcjjxinFxb1H2XtNtWFBHrwO(sUqWwy0foFH1VWl9ODCmwKnUVTIaTdngYrlv8OBHKKlK1T31vghJfzJ7BRiq7qJHCkQLVjwyKfkn4wiylm6cNVW6x4LE0ooWBPVqrgrT9MmhTuXJUfssUqw3ExxzCG3sFHImIA7nzof1Y3elmYcLgCleSfgDHZxiRBVRRmEQdn53Klv08aXPOw(MyHrwOKlKKCHSU9UUY4m6qKoKtrT8nXcJSqjxiyb1KDFBb1QKiS0aLuacfHlehXdXeurlv8OluxqLr)dPFgub1EjktDfsxiXiSq9UWOl8spAhhJfzJ7BRiq7qJHC0sfp6wy0foFHouzaaWXyr24(2kc0o0yiFmTqsYfY6276kJJXISX9TveODOXqof1Y3elKWcLCHGfut29Tfuv8PdlnqzgdX9mmCH4axiMGAYUVTGkOutdPLgOurZduqfTuXJUqDHlex8letqfTuXJUqDbvg9pK(zqfu7LOm1viDHeJWc1Bqnz33wqvXNoS0aLzme3ZWWfItpdXeurlv8OluxqLr)dPFguRFHouzaaWNXWjRH2Xhtb1KDFBb1zmCYAODHleh4hIjOIwQ4rxOUGkJ(hs)mOoFHxsLXJdct)bIpXUfsmcluFjxij5cvgaa8uhAYVjxQO5bIpMwij5cvgaaCgDishYhtlKKCHkdaaoQnjbftRm1viLpMwiyb1KDFBbvw69LKDFBf)lUGQ)fxXsnmOc82laHur4cXfpeIjOIwQ4rxOUGkJ(hs)mOY6276kJZOdr6qArC0NiKZaLuzuuaOj7(2s)cJqyHsZ1tWTWOlC(cb1EjktDfsxiXiSq9xij5cb1EjktDfsxiXiSq9UWOlK1T31vgxXNoS0aLzme3Zqof1Y3elmYcLzUfoZfQ)cjjxiO2lrzQRq6cjSqIVWOlK1T31vgxXNoS0aLzme3Zqof1Y3elmYcLzUfoZfQ)cJUqw3Exxz8zmCYAODCkQLVjwyKfkZClCMlu)fcwqnz33wqLrhI0H0I4Opry4cXjTKHycQOLkE0fQlOYO)H0pdQ1VqwBcKrZ7BJpMwy0fkMqVVCjvgpb396EdlIRPAlmcHfQFqnz33wqL1Maz08(2cxioPLoetqfTuXJUqDb1KDFBbvw69LKDFBf)lUGQ)fxXsnmOc82laHur4cXjT(HycQOLkE0fQlOYO)H0pdQ1VqwBcKrZ7BJpMcQj7(2cQS2eiJM33w4cXjTEdXeut29Tfuz0HiDiTio6tegurlv8Olux4cXjnXdXeut29TfutklnSCnLI2furlv8Olux4cXjn4cXeurlv8OluxqLr)dPFguVxdlxxanjVWiluM5cQj7(2cQS2eiJM33w4cxqf4TxacPIqmH4KoetqfTuXJUqDb1EkOkWlOMS7BlOQlPFQ4XGQU0pWGQyc9(YLuz8eC3R7nSiUMQTWiewO(lKKCHkdaaoQnjbftRm1viLpMwy0f6qLbaaFgdNSgAh31v2cJUqLbaa396Edltd6ulqURRSGQUKwSuddQorHLIlv8y4cXPFiMGkAPIhDH6cQm6Fi9ZG68foFH1VWl9ODCgDishYrlv8OBHrx48fY6276kJN6qt(n5sfnpqCkQLVjwyKfQp4wij5czD7DDLXtDOj)MCPIMhiof1Y3elKWcLCHGTqWwij5cNVWl9ODCmwKnUVTIaTdngYrlv8OBHrx4LE0ooWBPVqrgrT9MmhTuXJUfc2cjjx48fQmaa4m6qKoKpMwij5czD7DDLXz0HiDiNIA5BIfgzH6dUfc2cbBHrx48fw)cV0J2XbEl9fkYiQT3K5OLkE0TqsYfY6276kJd8w6luKruBVjZPOw(MyHeBHG)cjjxiRBVRRmoWBPVqrgrT9MmNIA5BIfgzHehCleSfgDHZxy9l8spAhhJfzJ7BRiq7qJHC0sfp6wij5czD7DDLXXyr24(2kc0o0yiNIA5BIfsSfc(lKKCHSU9UUY4ySiBCFBfbAhAmKtrT8nXcJSqIdUfc2cJUW71WY1fqtYlKWcLmOMS7BlOkqAob61cxio9gIjOIwQ4rxOUGkJ(hs)mOoFH1VWl9ODCG3sFHImIA7nzoAPIhDlKKCHSU9UUY4aVL(cfze12BYCkQLVjwyKfkZClCMluAjxij5cDOYaaGd8w6luKruBVjZhtleSfgDHZxy9l8spAhhJfzJ7BRiq7qJHC0sfp6wij5czD7DDLXXyr24(2kc0o0yiNIA5BIfgzHYm3cN5cLwYfssUqhQmaa4ySiBCFBfbAhAmKpMwiylKKCHIj07lxsLXtWDVU3WI4AQ2cJqyH6hut29Tfu1Lw8nEbiKkkGsnnKgUqCepetqfTuXJUqDbvg9pK(zqD(cNVW6x4LE0ooJoePd5OLkE0TqsYfQmaa4m6qKoK76kBHrxiRBVRRmoJoePd5uulFtSWiluAjxiylKKCHkdaaoJoePd5IlzeTWiewOExij5czD7DDLXtDOj)MCPIMhiof1Y3elmYcLwYfssUqhQmaa4aVL(cfze12BY8X0cbBHrx49Ay56cOj5fsyHsUWOl8sQmE871WY1f3JlmYcb)GAYUVTGkglYg33wrG2HgddxioWfIjOIwQ4rxOUGkJ(hs)mOQlPFQ4rUtuyP4sfpUWOlS(fQmaa46sl(gVaesffqPMgs5JPfgDHZx48fw)cV0J2Xz0HiDihTuXJUfssUqw3ExxzCgDishYPOw(MyHrwOmZTWzUq9UqWwy0foFH1VWl9ODCmwKnUVTIaTdngYrlv8OBHKKlC(czD7DDLXXyr24(2kc0o0yiNIA5BIfw7cLzUfwZcb1EjktDfsxyKfQNlKKCHxsLXJFVgwUU4ECHeBHG)cbBHGTWOlC(cRFHx6r74aVL(cfze12BYC0sfp6wij5czD7DDLXbEl9fkYiQT3K5uulFtSWAxOmZTWAwiO2lrzQRq6cJSq9CHGTqsYfkMqVVCjvgpb396EdlIRPAlmcHfQ)cJUW5l8spAhhu7LOK6qtgPC0sfp6wy0fY6276kJdQ9susDOjJuof1Y3elKyluM5w4mxOExij5cvgaaCgDishYhtlm6cvgaaCgDishYfxYiAHeBHsl5cbBHGfut29TfuDVU3WI4AQw4cXf)cXeurlv8OluxqLr)dPFguNVW6x4LE0ooJoePd5OLkE0TqsYfY6276kJZOdr6qof1Y3elmYcLzUfoZfQ3fc2cJUW5lS(fEPhTJJXISX9TveODOXqoAPIhDlKKCHZxiRBVRRmoglYg33wrG2Hgd5uulFtSWAxOmZTWAwiO2lrzQRq6cJSq9CHKKl8sQmE871WY1f3JlKyle8xiyleSfgDHZxy9l8spAhh4T0xOiJO2EtMJwQ4r3cjjxiRBVRRmoWBPVqrgrT9MmNIA5BIfw7cLzUfwZcb1EjktDfsxyKfQNleSfgDHZxy9lK16qlTJBiJ2(M6wij5czD7DDLX1Lw8nEbiKkkGsnnKYPOw(MyHrwOmZTqWwij5cV0J2Xb1EjkPo0KrkhTuXJUfgDHSU9UUY4GAVeLuhAYiLtrT8nXcj2cLzUfoZfQ3fssUqLbaahu7LOK6qtgP8X0cjjxOYaaGZOdr6q(yAHrxOYaaGZOdr6qU4sgrlKyluAjxij5cvgaaCDPfFJxacPIcOutdP8Xuqnz33wq9qTjFsffDi19SlCHlOY6276kteIjeN0HycQOLkE0fQlOYO)H0pdQZxOYaaGR4725hIJtXKDlKKCHkdaaEQdn53Klv08aXhtlm6cvgaa8uhAYVjxQO5bItrT8nXcJSqPb)fssUqLbaaNrhI0H8X0cJUqLbaaNrhI0HCkQLVjwiXwO(GBHGfut29TfuN67BlCH40petqfTuXJUqDbvg9pK(zqvmHEF5sQmEcU)LbDIYmgozn0UfgHWc1FHKKlC(cRFH08DfuhAhpDobhJ9fNyHKKlKMVRG6q74PZj4VTWilupb3cblOMS7BlO6FzqNOmJHtwdTlCH40BiMGkAPIhDH6cQm6Fi9ZGQYaaGN6qt(n5sfnpq8X0cjjxOYaaGZOdr6q(yAHrxOYaaGZOdr6qU4sgrlKWcLwYGAYUVTGkWtrfF3UWfIJ4HycQj7(2cQcqp6DLgOOdnzmnggurlv8Olux4cXbUqmb1KDFBbvfpkeVjxAGIyOPH0GkAPIhDH6cxiU4xiMGAYUVTGQIhfI3Klnqjh3qZcQOLkE0fQlCH40Zqmb1KDFBbvfpkeVjxAGs1BhsdQOLkE0fQlCH4a)qmb1KDFBbvfpkeVjxAGIyI(MCqfTuXJUqDHlex8qiMGkAPIhDH6cQj7(2cQVjy0XLkESeFJ0UHwXH6Egguz0)q6NbvLbaap1HM8BYLkAEG4JPfssUqLbaaNrhI0H8X0cJUqLbaaNrhI0HCXLmIwyecluAjxij5czD7DDLXtDOj)MCPIMhiof1Y3elmYcjo4wij5czD7DDLXz0HiDiNIA5BIfgzHehCbvl1WG6BcgDCPIhlX3iTBOvCOUNHHleN0sgIjOIwQ4rxOUGAYUVTGARdPvGqV2BYLPUcPfgvcXL(GkJ(hs)mOQmaa4Po0KFtUurZdeFmTqsYfQmaa4m6qKoKpMwy0fQmaa4m6qKoKlUKr0cJqyHslzq1snmO26qAfi0R9MCzQRqAHrLqCPpCH4Kw6qmbv0sfp6c1fut29TfuDjLiTUTIdzev010K9Nebvg9pK(zqvzaaWtDOj)MCPIMhi(yAHKKluzaaWz0HiDiFmTWOluzaaWz0HiDixCjJOfgHWcLwYGQLAyq1LuI062koKrurxtt2FseUqCsRFiMGkAPIhDH6cQj7(2cQAjlvOyracXROneplOYO)H0pdQkdaaEQdn53Klv08aXhtlKKCHkdaaoJoePd5JPfgDHkdaaoJoePd5IlzeTWiewO0sguTuddQAjlvOyracXROneplCH4KwVHycQOLkE0fQlOAPgguDumDapfl6qHa9b1KDFBbvhfthWtXIouiqF4cXjnXdXeurlv8Oluxq1snmOkiA4jcPIs1BYb1KDFBbvbrdprivuQEtoCH4KgCHycQOLkE0fQlOAPgguLPVwH1om2GAYUVTGQm91kS2HXgUqCsh)cXeurlv8Oluxq1snmOQHAnvIsduMsXveVjcQj7(2cQAOwtLO0aLPuCfXBIWfItA9metqfTuXJUqDbvl1WGQykPyrdZRaQBIcQj7(2cQIPKIfnmVcOUjkCH4Kg8dXeurlv8Oluxqnz33wqv8gWWxK9P7ZRPIIs6KXsduaqAZ(tIGkJ(hs)mOQmaa4Po0KFtUurZdeFmTqsYfQmaa4m6qKoKpMwy0fQmaa4m6qKoKlUKr0cJqyHsl5cjjxiRBVRRmEQdn53Klv08aXPOw(MyHrwiXb3cjjxiRBVRRmoJoePd5uulFtSWilK4GlOAPggufVbm8fzF6(8AQOOKozS0afaK2S)KiCH4KoEietqfTuXJUqDb1KDFBbvXBadFjftpnTtuusNmwAGcasB2Fseuz0)q6NbvLbaap1HM8BYLkAEG4JPfssUqLbaaNrhI0H8X0cJUqLbaaNrhI0HCXLmIwyecluAjxij5czD7DDLXtDOj)MCPIMhiof1Y3elmYcjo4wij5czD7DDLXz0HiDiNIA5BIfgzHehCbvl1WGQ4nGHVKIPNM2jkkPtglnqbaPn7pjcxio9LmetqfTuXJUqDbvg9pK(zqvzaaWtDOj)MCPIMhi(yAHKKluzaaWz0HiDiFmTWOluzaaWz0HiDixCjJOfgHWcLwYGAYUVTG6qGL)qnr4cXPV0HycQOLkE0fQlOYO)H0pdQZxiO2lrzQRq6cJqyHeFHrx49A4cj2cb3cjjxiO2lrzQRq6cJqyH6DHrx49A4cJSqWTqsYfEPhTJdQ9susDOjJuoAPIhDlm6czD7DDLXb1EjkPo0KrkNIA5BIfsyHsUqWwy0foFH1VWl9ODCbsZjqVghTuXJUfssUqw3ExxzCbsZjqVgNIA5BIfgzHsUqWcQj7(2cQPo0KFtUurZdu4cXPV(HycQOLkE0fQlOYO)H0pdQZxiO2lrzQRq6cJqyHeFHrx49A4cj2cb3cjjxiO2lrzQRq6cJqyH6DHrx49A4cJSqWTqsYfEPhTJdQ9susDOjJuoAPIhDlm6czD7DDLXb1EjkPo0KrkNIA5BIfsyHsUqWcQj7(2cQm6qKomCH40xVHycQj7(2cQPaeAfqP33vbv0sfp6c1fUqC6t8qmbv0sfp6c1fuz0)q6Nb171WY1fqtYlKWcLCHrx48foFHkdaaEQdn53Klv08aXhtlKKCHkdaaoJoePd5JPfc2cjjx48fQmaa4Po0KFtUurZde31v2cJUqw3Exxz8uhAYVjxQO5bItrT8nXcJSqIl5cjjxOYaaGZOdr6qURRSfgDHSU9UUY4m6qKoKtrT8nXcJSqIl5cbBHGfut29Tfub1EjkPo0KrA4cXPp4cXeurlv8OluxqLr)dPFgub1EjktDfsxyecluVlm6czD7DDLXtDOj)MCPIMhiof1Y3elmYcLzUfgDH3RHLRlGMKxiHfk5cJUW5lS(fEPhTJlqAob614OLkE0TqsYfQmaa4cKMtGEn(yAHGfut29TfubEl9fkYiQT3Kdx4cxqnhhOMguvFT4z4cxia]] )


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
