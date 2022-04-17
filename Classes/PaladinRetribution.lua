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
        aura_of_reckoning = 756, -- 247675
        blessing_of_sanctuary = 752, -- 210256
        divine_punisher = 755, -- 204914
        judgments_of_the_pure = 5422, -- 355858
        jurisdiction = 757, -- 204979
        law_and_order = 858, -- 204934
        lawbringer = 754, -- 246806
        luminescence = 81, -- 199428
        ultimate_retribution = 753, -- 355614
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

    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 363677, "tier28_4pc", 364370 )
    -- 2-Set - Ashes to Ashes - When you benefit from Art of War, you gain Seraphim for 3 sec.
    -- 4-Set - Ashes to Ashes - Art of War has a 50% chance to reset the cooldown of Wake of Ashes instead of Blade of Justice.
    -- 2/13/22:  No mechanics that can be proactively modeled.

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
        return max( gcd.remains, min( cooldown.judgment.true_remains, cooldown.crusader_strike.true_remains, cooldown.blade_of_justice.true_remains, ( state:IsUsable( "hammer_of_wrath" ) and cooldown.hammer_of_wrath.true_remains or 999 ), cooldown.wake_of_ashes.true_remains, ( race.blood_elf and cooldown.arcane_torrent.true_remains or 999 ), ( covenant.kyrian and cooldown.divine_toll.true_remains or 999 ) ) )
    end )

    spec:RegisterHook( "reset_precast", function ()
        if buff.divine_resonance.up then
            state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
            if buff.divine_resonance.remains > 5 then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" ) end
            if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
        end
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

            startsCombat = true,
            texture = 135959,

            handler = function ()
                applyDebuff( "target", "judgment" )
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
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
            flash = { 85256, 336872 },
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

                removeStack( "vanquishers_hammer" )
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
				applyBuff( "vanquishers_hammer" )
            end,

            auras = {
                vanquishers_hammer = {
                    id = 328204,
                    duration = 20,
                    max_stack = 1,
                }
            }
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


    spec:RegisterPack( "Retribution", 20220405, [[dKKFmcqib4rajyteLpHQYOqQCkKsRssuVcOQzbeDlGeYUi8lGudtsQJruzzev9mKIMMaQRbuzBifY3qvvACifCoKc16qvfZtGCpKyFaLdIQQklei8qGKMiQQQ6IOQkYhbsOojqIALivntuvPBcKizNsc)evvrnuGePwkQQcpLknvjjFfirmwbK9kXFfAWQ6WIwSGEmjtMQUm0Mb5ZuXOb40QSAjrEnsYSj1TjYUP8BfdxsDCuvvwoINJY0v66GA7OkFhqJxG68iPMpQSFPUixPQIRpxSuH8vlV8vh4QbNqoAiWYhy5lUl11yXTovuLoyX1sjS4YFGl5cH3BSIBDsTEsFPQIlBGjkS4wCdHp9ckBLWIRpxSuH8vlV8vh4QbNqoAiWYhy5kUSAuvQG)wDXfW59OvclUEKPkU8h4sUq49gRFqPtD6pRPN)RMC6(bhi7x(QLx(M(MEqfqAoiJFA6bf1pOSTOdjxSFdb2Fn5gYTu3pRwFB)qKrQF3tcufn9GI6huQKkSFxKK1aoP(boeQ6pe3fj9d8wa9plaK0pOY)Z6Fhhhn67FGGen9GI6N)Fm(2(bMSf7xc9hSeO1jXb7hu5)z9pw)EQpZP)6urfRFytJmw)3YhR)S)WHX6h6CaSIMEqr9dk1qW(tFLGzReAlR)D6h4qOQFG3cOFqL)N1pdWa06NH1jjxutTO4wtgOtJfxqbqH(5pWLCHW7nw)GsN60FwtpOaOq)8F1Kt3p4az)YxT8Y3030dkak0pOcinhKXpn9GcGc9dkQFqzBrhsUy)gcS)AYnKBPUFwT(2(HiJu)UNeOkA6bfaf6huu)GsLuH97IKSgWj1pWHqv)H4UiPFG3cO)zbGK(bv(Fw)744OrF)deKOPhuauOFqr9Z)pgFB)at2I9lH(dwc06K4G9dQ8)S(hRFp1N50FDQOI1pSPrgR)B5J1F2F4Wy9dDoawrtpOaOq)GI6huQHG9N(kbZwj0ww)70pWHqv)aVfq)Gk)pRFgGbO1pdRtsUOMArtFtFQ2BmMOMGQrkmxk1ZEJ10NQ9gJjQjOAKcZf8uaDOgzSZCIduKbljHKM(uT3ymrnbvJuyUGNcOd1iJDMtCGIj8clzn9PAVXyIAcQgPWCbpfqhQrg7mN4afbE2IKM(uT3ymrnbvJuyUGNcOd1iJDMtCGISAYzon9PAVXyIAcQgPWCbpfqdPrgafjHwqEquydSo8mVOgMTWAmIe469gJJJnW6WZ8cEJo3tJr2O5H220NQ9gJjQjOAKcZf8uaDsuPHXDie0wqEqu2uJ2kGol1rcQOASZCeOLHA0lBtnARGHKSgWjjqld1OVPpv7ngtutq1ifMl4PaAgGd1(4af5HMdMMcB6B6bfaf6N)uWOcErF)ipKqD)7jH9VaW(t1oK(pw)jV80zOgfn9PAVXyuiyimvytFQ2Bmg4PaAEj5YqncslLqkqKibtp1GKxQHrk0by0uhRhGibmkbw2Esyq0ahhGrtDSEaIeWOqtz0TNecgfAGJJvJADCtIdUmH)4Dggz7qKaJI8Yudp0sBfurn5sJwALPMr7hGMi5HMZzorGKCbiiOuEgdmhLx2EsyCNiGAhkvlJUa2uJ2kyijRbCsCCHWqqcgsYAaNKaUMwz0fajpFe5H2ksVNjWGp2Y44i55Jip0wr69mbCnhhjpFe5H2ksVNjodSaxnTYOlGqyiirYdnNZCIaj5cqaxZXby0uhRhGiHc444uZO9dqtaiLKqsCGIaj5cqqqP8mghhRg164MehCzc)X7mmY2Hibgf5LPgEOL2kOIAYLgTn9PAVXyGNcO5LKld1iiTucPGSibtp1GKxQHrk0fcdbjueyw6rHFaAYuZO9dqtOiWS0JcckLNXatUQ54cHHGekcml9OGTPIkWOqtoo1mA)a0ejp0CoZjcKKlabbLYZyGjx10kJUa2uJ2kGol1rcQOASZC44uZO9dqtaDwQJeur1yN5iiOuEgdm5QMJdWOPowparIWJqN6wkvllv7nMa6SuhjOIQXoZr4pwgQrpTYGohaBKGs5zmWObzSAuRJBsCWLj8hVZWiBhIuqGRPpv7ngd8uaTk16yQ2BSO(yliTucPOMr7hGgRPpv7ngd8uaTk16yQ2BSO(yliTucPGSiejwpJ(mhqEquOlasE(iYdTvKEptGbFSLXXrYZhrEOTI07zc4AoosE(iYdTvKEptCwq0yoosE(iYdTvKEptCgy0SAALr3MA0wbgmQG3BSidTfnfktnJ2panbgmQG3BSidTfnfkiOuEgliASmwnQ1Xnjo4Ye(J3zyKTdrkiWXXTPgTvaDwQJeur1yN5itnJ2panb0zPosqfvJDMJGGs5zSGOX0kd6CaSrckLNXaJgA6t1EJXapfqRsToMQ9glQp2cslLqkilcrIPApEiizl5ulf5a5brXJHWqqcmyubV3yrgAlAkuaxZX5Xqyiib0zPosqfvJDMJaUUPpv7ngd8uaTk16yQ2BSO(yliTucP4GgsYDiSM(M(uT3ymHAgTFaAmk1ZEJbYdIsimeKi5HMZzorGKCbiGR54cHHGekcml9OaUwwimeKqrGzPhfSnvurrUQ54chgtg05ayJeukpJfK8GRPpv7ngtOMr7hGgd8uaT(CaSSyLG9osOTG8GOWQrToUjXbxMqFoawwSsWEhj0wWOiphxaK88rKhARi9EMad(ylJJJKNpI8qBfP3ZeNbg)fCCCK88rKhARi9EMaUUPpv7ngtOMr7hGgd8uan0rWq9mEqEquOlegcsK8qZ5mNiqsUaeW1CCHWqqcfbMLEuaxllegcsOiWS0Jc2MkQOix10klGn1OTcmyubV3yrgAlAkSPpv7ngtOMr7hGgd8uanKgzauKeAb5brHnW6WZ8IAy2cRXisGR3Bmoo2aRdpZl4n6CpngzJMhAlipBrcbUEJNKe6VCrkYbYZwKqGR3OJEctnf5a5zlsiW1B8GOWgyD4zEbVrN7PXiB08qBB6t1EJXeQz0(bOXapfqZaCO2hhOip0CW0uiipik0fWMA0wbgmQG3BSidTfnfYXPMr7hGMadgvW7nwKH2IMcfeukpJfe4KNwzqNdGnsqP8mgyYbUM(uT3ymHAgTFaAmWtb0HAKXoZjoqrgSKesA6t1EJXeQz0(bOXapfqhQrg7mN4aft4fwYA6t1EJXeQz0(bOXapfqhQrg7mN4afbE2IKM(uT3ymHAgTFaAmWtb0HAKXoZjoqrwn5mNM(uT3ymHAgTFaAmWtb0WmmElkbslLqkNXue4nd1yK)bN2clf9iVtHG8GOecdbjsEO5CMteijxac4AoUqyiiHIaZspkGRLfcdbjueyw6rbBtfvuKRAoUWHXKbDoa2ibLYZybrZQB6t1EJXeQz0(bOXapfqdZW4TOeiTucPm8qcqaOw6mNy9aejrfHA2MAqEqucHHGejp0CoZjcKKlabCnhximeKqrGzPhfW1YcHHGekcml9OGTPIkkYvnhx4WyYGohaBKGs5zSGKdCn9PAVXyc1mA)a0yGNcOHzy8wucKwkHu8jHkPzSOhvuf5nKuDl1G8GOecdbjsEO5CMteijxac4AoUqyiiHIaZspkGRLfcdbjueyw6rbBtfvuKRAoUWHXKbDoa2ibLYZybjF1n9PAVXyc1mA)a0yGNcOHzy8wucKwkHuKsvgsWidaIBucMDkqEqucHHGejp0CoZjcKKlabCnhximeKqrGzPhfW1YcHHGekcml9OGTPIkkYvnhx4WyYGohaBKGs5zSGKV6M(uT3ymHAgTFaAmWtb0WmmElkbslLqkqjSEPoQgyBrIeMmyccYdIsaBQrBfkcml9ihximeKqrGzPhfW1CCHdJjd6CaSrckLNXcIMv30NQ9gJjuZO9dqJbEkGgMHXBrjqAPesXtW0dDemYdzmu30NQ9gJjuZO9dqJbEkGgMHXBrjqAPesHrfSMkKWIapZPPpv7ngtOMr7hGgd8uanmdJ3IsG0sjKId5KIQXJb30NQ9gJjuZO9dqJbEkGgMHXBrjqAPesrcLgc1XbkwNSnYoJ10NQ9gJjuZO9dqJbEkGgMHXBrjqAPesHvNemkH5gbmdvn9PAVXyc1mA)a0yGNcOHzy8wucKwkHuyPMx6G(iem7glMs16d6qstFQ2BmMqnJ2pang4PaAyggVfLaPLsifNlTnoelLqBtDSgtIUPpv7ngtOMr7hGgd8uanmdJ3IsG0sjKcWZ8mvsIabGlBhdB6t1EJXeQz0(bOXapfqdZW4TOeiTucPWujHfhOiejxKyPoYwYbHn9PAVXyc1mA)a0yGNcOHzy8wucKwkHuuaYZyXbk6hPZY9gRPpv7ngtOMr7hGgd8uanmdJ3IsG0sjKcMKfqibtQqclEs1PAB6t1EJXeQz0(bOXapfqdZW4TOeiTucPaatYghO4caJmGjrcKheLacHHGejp0CoZjcKKlabCTSacHHGekcml9OaUUPpv7ngtOMr7hGgd8uanmdJ3IsG0sjKIJo9xUdHfdtVdcYdIsimeKi5HMZzorGKCbiGR54cHHGekcml9OaUwwimeKqrGzPhfSnvubgf5QMJtnJ2panrYdnNZCIaj5cqqqP8mgybgCCCQz0(bOjueyw6rbbLYZyGfyW10NQ9gJjuZO9dqJbEkGgMHXBrjgipikHWqqIKhAoN5ebsYfGaUMJlegcsOiWS0Jc4AzHWqqcfbMLEuW2urfyuKR6M(uT3ymHAgTFaAmWtb0WmmElkbslLqkojpuhhO4caJqhHTXKeElsa5brHUqyiirYdnNZCIaj5cqaxZXfcdbjueyw6rbCnTn9PAVXyc1mA)a0yGNcOtEO5CMteijxaG8GOqhGrtDSEaIeWOeyz7jHbboooaJM6y9aejGrHMYOBpjemWXXrGneAioOybGrP05yljxKfReS3rcTLwooaJM6y9aejGrrEzeydHgIdk4LMdCs8SO0iH2cljBtnARa6SuhjOIQXoZHJBtnARaWOPoM8qZbjYuZO9dqtay0uhtEO5GebbLYZyuQMwz0fWMA0wbdjznGtIJlGn1OTcOZsDKGkQg7mhoo1mA)a0emKK1aojbbLYZyGvnTn9PAVXyc1mA)a0yGNcOveyw6rqEquamAQJ1dqKagLalBpjmiWXXby0uhRhGibmk0u2EsiyGRPpv7ngtOMr7hGgd8uaDYaGweqQ1dWM(uT3ymHAgTFaAmWtb0agn1XKhAoibKheL9KW4ora1ouQwgGrtDSEaIKGOiVm6cHHGejp0CoZjcKKlabCnh3MA0wHIaZspkJo1mA)a0ekcml9OGGs5zmkvZXfcdbjueyw6rbCnTCCHdJjd6CaSrckLNXcs(QPTPpv7ngtOMr7hGgd8uan0zPosqfvJDMdipik0by0uhRhGibmkbw2Esyq0ahhGrtDSEaIeWOqtz0TNecgfAGJJvJADCtIdUmH)4Dggz7qKaJI8Yudp0sBfurn5sJwALPMr7hGMi5HMZzorGKCbiiOuEgdmhLx2EsyCNiGAhkvlJUa2uJ2kyijRbCsCCHWqqcgsYAaNKaUMwz0fajpFe5H2ksVNjWGp2Y44i55Jip0wr69mbCnhhjpFe5H2ksVNjodSaxnTYOlGqyiirYdnNZCIaj5cqaxZXby0uhRhGiHc444uZO9dqtaiLKqsCGIaj5cqqqP8mghhRg164MehCzc)X7mmY2Hibgf5LPgEOL2kOIAYLgTn9n9PAVXycKfHiXuThpKc0rWq9m(M(uT3ymbYIqKyQ2JhcEkGwLADmv7nwuFSfKwkHuGo7yaqcdKhefaJM6y9aejuahhNhdHHGevc27iH2kGR548yimeKa6SuhjOIQXoZraxlJopgcdbjGol1rcQOASZCeeukpJfKJYlKYG54y1Owh3K4Glt4pENHr2oejWOiVSa2uJ2kWGrf8EJfzOTOPqA548yimeKadgvW7nwKH2IMcfW1Y8yimeKadgvW7nwKH2IMcfeukpJfKJYlKYGB6t1EJXeilcrIPApEi4PaA)X7mmUJw30NQ9gJjqweIet1E8qWtb08sJ)bFmaiHfbKssiPPpv7ngtGSiejMQ94HGNcObMuHXbkMmaidKhefaJM6y9aejbrrEz05Xqyiib0zPosqfvJDMJaUwMhdHHGeqNL6ibvun2zocckLNXcYr5RS8YcGaBi0qCqH)4DggjiBS0uihNhdHHGeyWOcEVXIm0w0uOaUwMhdHHGeyWOcEVXIm0w0uOGGs5zSGCuEoownQ1Xnjo4Ye(J3zyKTdrcmkGtgb2qOH4Gc)X7mmsq2yPPqzBQrBfyWOcEVXIm0w0uiTn9PAVXycKfHiXuThpe8uaDOo9yCGIvcMTNcb5brrnMh(wbgCnmXj3Bmz0fab2qOH4Gc)X7mmsq2yPPqzagn1X6biscIcn54amAQJ1dqKeef5PTPpv7ngtGSiejMQ94HGNcOReS3rcTfKheLa8yimeKOsWEhj0wbCTm6amAQJ1dqKagf5KrGneAioOybGrP05yljxKfReS3rcTLJdWOPowparcyuKN2M(uT3ymbYIqKyQ2JhcEkGwLADmv7nwuFSfKwkHuGo7yaqcRPpv7ngtGSiejMQ94HGNcObMuHXbkMmaidKhefaJM6y9aejbrr(M(uT3ymbYIqKyQ2JhcEkGouNEmoqXkbZ2tHG8GOay0uhRhGijik0SPpv7ngtGSiejMQ94HGNcOReS3rcTfKheLa8yimeKOsWEhj0wbCDtFQ2BmMazrismv7XdbpfqdiLKqsCGIaj5cOPpv7ngtGSiejMQ94HGNcOveyw6rsKTKJkSPpv7ngtGSiejMQ94HGNcOtIknmUdHG220NQ9gJjqweIet1E8qWtb0QXyOIK7nwtFtFQ2BmMazrisSEg9zouyijRbCsG8GOay0uhRhGiHc4KrxaBQrBfqNL6ibvun2zoCCQz0(bOjGol1rcQOASZCeeukpJfefhLVY0KJtnJ2panb0zPosqfvJDMJGGs5zmWuZO9dqJwz0fWMA0wbgmQG3BSidTfnfYXPMr7hGMadgvW7nwKH2IMcfeukpJfefhLVY0KJtnJ2panbgmQG3BSidTfnfkiOuEgdm1mA)a0442uJ2kGol1rcQOASZCOvgDbOgEOL2kOIAYLghNAgTFaAc)X7mmUJwliOuEgliAmhNAgTFaAc)X7mmUJwliOuEgdm1mA)a0OTPpv7ngtGSiejwpJ(mhWtb0QuRJPAVXI6JTG0sjKc0zhdasyG8GOay0uhRhGiHc4448yimeKa6SuhjOIQXoZraxZXfcdbjueyw6rbCTSqyiiHIaZspkyBQOki5QUPpv7ngtGSiejwpJ(mhWtb08sJ)bFmaiHfbKssibKheLqyiibdjznGtsax30NQ9gJjqweIeRNrFMd4PaAaPKesIdueijxaG8GOqGneAioOGxAoWjXZIsJeAlSutFQ2BmMazrisSEg9zoGNcObMuHXbkMmaidKhefaJM6y9aejbrrEzmCJHJbZe7He5PHyGRvn9PAVXycKfHiX6z0N5aEkGouNEmoqXkbZ2tHG8GOay0uhRhGijik0SPpv7ngtGSiejwpJ(mhWtb0vc27iH2cYdIsaEmegcsujyVJeARaUUPpv7ngtGSiejwpJ(mhWtb0asjjKehOiqsUaA6t1EJXeilcrI1ZOpZb8uaTIaZspsISLCuHG8GOOMr7hGMqrGzPhjr2soQqHcqsCqweIKQ9gl1Grrob)fCYOdWOPowparsquKNJdWOPowparsquOPm1mA)a0eH60JXbkwjy2EkuqqP8mgyokFLLNJdWOPowparcLaltnJ2panrOo9yCGIvcMTNcfeukpJbMJYxz5LPMr7hGMOsWEhj0wbbLYZyG5O8vwEAB6t1EJXeilcrI1ZOpZb8uandjznGtcKheLa2uJ2kGol1rcQOASZCKPMr7hGMadgvW7nwKH2IMcfeukpJfefhLVY0ugDbOgEOL2kOIAYLghNAgTFaAc)X7mmUJwliOuEgliAmTn9PAVXycKfHiX6z0N5aEkGwLADmv7nwuFSfKwkHuGo7yaqcRPpv7ngtGSiejwpJ(mhWtb0kcml9ijYwYrf20NQ9gJjqweIeRNrFMd4Pa6KOsdJ7qiOTG8GOay0uhRhGijikbUPpv7ngtGSiejwpJ(mhWtb0mKK1aojqEquOlGn1OTcOZsDKGkQg7mhoo1mA)a0eqNL6ibvun2zocckLNXcIIJYxzAsRm6cytnARadgvW7nwKH2IMc54uZO9dqtGbJk49glYqBrtHcckLNXcIIJYxzAYXTPgTvaDwQJeur1yN5qRm6cqn8qlTvqf1Klnoo1mA)a0e(J3zyChTwqqP8mwq0yAB6t1EJXeilcrI1ZOpZb8uaTAmgQi5EJ1030NQ9gJjGo7yaqcJcVKCzOgbPLsifplQs2MHAeK8snmsHvJADCtIdUmH)4Dggz7qKOiVSaOJaBi0qCqb0zPoYdj(tTCCBQrBfKZbWIdmlYdj(tT0YXXQrToUjXbxMWF8odJSDisGjphximeKaLQPMGPfRhGiraxllapgcdbjQeS3rcTvaxllGqyiiH)4DggRHj1ddfW1n9PAVXycOZogaKWapfqZqswd4Ka5brHo1mA)a0ejp0CoZjcKKlabbLYZyGjh444uZO9dqtOiWS0JcckLNXatoWrRm6cytnARa6SuhjOIQXoZHJtnJ2panb0zPosqfvJDMJGGs5zmWuZO9dqJwz0fWMA0wbgmQG3BSidTfnfYXPMr7hGMadgvW7nwKH2IMcfeukpJbMAgTFaACCSAuRJBsCWLj8hVZWiBhIeyuahTYOlasE(iYdTvKEptGbFSLXXrYZhrEOTI07zIZalWvZXrYZhrEOTI07zIZcYr554i55Jip0wr69mbCnTYOla1WdT0wbvutU044OtnJ2panH)4Dgg3rRfeukpJfenMJtnJ2panH)4Dgg3rRfeukpJbMAgTFaA0slhh05ayJeukpJfKCGtg05ayJeukpJbg444cHHGekcml9OaUwwimeKqrGzPhfSnvufKCv30NQ9gJjGo7yaqcd8uangmQG3BSidTfnfcYdIcDHWqqcfbMLEu4hGMm1mA)a0ekcml9OGGs5zmWKRAoUqyiiHIaZspkyBQOcmk0KJtnJ2panrYdnNZCIaj5cqqqP8mgyYvnTYOlGn1OTcOZsDKGkQg7mhoo1mA)a0eqNL6ibvun2zocckLNXatUQ54amAQJ1dqKi8i0PULs1YOlaEj5YqnkGircMEQ54s1EJjGol1rcQOASZCe(JLHA0tlTYGohaBKGs5zmWObzSAuRJBsCWLj8hVZWiBhIuqGRPpv7ngtaD2XaGeg4PaA)X7mmY2HibYdIcVKCzOgfEwuLSnd1OSacHHGe8sJ)bFmaiHfbKssiraxlJo6cytnARqrGzPh54uZO9dqtOiWS0JcckLNXaZr5RmnPvgDbSPgTvGbJk49glYqBrtHCCQz0(bOjWGrf8EJfzOTOPqbbLYZyG5O8vMgXXPMr7hGMadgvW7nwKH2IMcfeukpJbMJYx5aldWOPowparcyuahhhRg164MehCzc)X7mmY2HibgfWXXfWMA0wbdjznGtsMAgTFaAcmyubV3yrgAlAkuqqP8mgyokFLLNJdWOPowparIWJqN6wkvlJUa4LKld1OazrcMEQ54s1EJjWGrf8EJfzOTOPqH)yzOg90sRm6cytnARa6SuhjOIQXoZHJtnJ2panb0zPosqfvJDMJGGs5zmWCu(ktJ44uZO9dqtaDwQJeur1yN5iiOuEgdmhLVYbwgGrtDSEaIeWOaooUa2uJ2kyijRbCsYuZO9dqtaDwQJeur1yN5iiOuEgdmhLVYYZXby0uhRhGir4rOtDlLQLrxa8sYLHAuarIem9uZXLQ9gtaDwQJeur1yN5i8hld1ONwA542uJ2kamAQJjp0CqIm1mA)a0eagn1XKhAoirqqP8mwqokFLPjhximeKaWOPoM8qZbjc4AoUqyiiHIaZspkGRLfcdbjueyw6rbBtfvbjx1CCqNdGnsqP8mwq0aTn9PAVXycOZogaKWapfqVOuTojSipK4p1cYdIcDbSPgTvOiWS0JCCQz0(bOjueyw6rbbLYZyG5O8vMM0kJUa2uJ2kWGrf8EJfzOTOPqoo1mA)a0eyWOcEVXIm0w0uOGGs5zmWCu(ktdCCQz0(bOjWGrf8EJfzOTOPqbbLYZyG5O8vMgjdWOPowparcyucmhxaBQrBfmKK1aojzQz0(bOjWGrf8EJfzOTOPqbbLYZyG5O8vwEooaJM6y9aejcpcDQBPuTm6cGxsUmuJcKfjy6PMJlv7nMadgvW7nwKH2IMcf(JLHA0tlTYOlGn1OTcOZsDKGkQg7mhoo1mA)a0eqNL6ibvun2zocckLNXaZr5RmnWXPMr7hGMa6SuhjOIQXoZrqqP8mgyokFLPrYamAQJ1dqKagLaZXfWMA0wbdjznGtsMAgTFaAcOZsDKGkQg7mhbbLYZyG5O8vwEooaJM6y9aejcpcDQBPuTm6cGxsUmuJcisKGPNAoUuT3ycOZsDKGkQg7mhH)yzOg90slh3MA0wbGrtDm5HMdsKPMr7hGMaWOPoM8qZbjcckLNXcYr5Rmn54cHHGeagn1XKhAoiraxZXfcdbjueyw6rbCTSqyiiHIaZspkyBQOki5QMJd6CaSrckLNXcIgA6B6t1EJXeoOHKChcJIk16yQ2BSO(yliTucPaD2XaGegipikagn1X6bisOaooo68yimeKOsWEhj0wbCnhhGrtDSEaIekbMwzHWqqc)X7mmsq2yPPqbCnhximeKaWOPoM8qZbjc46M(uT3ymHdAij3HWapfqZln(h8XaGeweqkjHeqEqucGaBi0qCqHhEPoCGnF0j5HAoUa2uJ2kGol1rcQOASZCKfWMA0wbgmQG3BSidTfnfYXfomMmOZbWgjOuEgliAOPpv7ngt4GgsYDimWtb0asjjKehOiqsUaa5brHaBi0qCqXcaJsPpwNK0zmoo1WdT0wbp0wautKPMr7hGMizaqlci16bOGGs5zmWKxUQB6t1EJXeoOHKChcd8uanWKkmoqXKbazG8GOay0uhRhGijikYlJHBmCmyMypKipnedCTsgDQz0(bOjsEO5CMteijxacckLNX44uZO9dqtOiWS0JcckLNXOTPpv7ngt4GgsYDimWtb0(J3zyChTgKhefaJM6y9aejbrrEzb4XqyiirLG9osOTc4Az0fWMA0wbdjznGtIJlegcsWqswd4KeW10kJUai55Jip0wr69mbg8XwghhjpFe5H2ksVNjodmAwnhhjpFe5H2ksVNjGRPvgDbSPgTvaDwQJeur1yN5WX5Xqyiib0zPosqfvJDMJaUMJtnJ2panb0zPosqfvJDMJGGs5zmWKVAALrxaBQrBfyWOcEVXIm0w0uihh05ayJeukpJfenWXXQrToUjXbxMWF8odJSDisGrbC0kJo1mA)a0ejp0CoZjcKKlabbLYZyGjh444uZO9dqtOiWS0JcckLNXatoWXXbDoa2ibLYZybrd020NQ9gJjCqdj5oeg4Pa6kb7DKqBb5brjapgcdbjQeS3rcTvaxlJoaJM6y9aejGrrozeydHgIdkwayukDo2sYfzXkb7DKqB54amAQJ1dqKagf5PTPpv7ngt4GgsYDimWtb0atQW4aftgaKbYdIcDagn1X6bisOunhhGrtDSEaIKGOiVm1mA)a0eH60JXbkwjy2EkuqqP8mgyokFLLNwz0fajpFe5H2ksVNjWGp2Y44i55Jip0wr69mXzGjF1CCK88rKhARi9EMaUMwz0fWMA0wbdjznGtIJtnJ2panbdjznGtsqqP8mgyGJJtn8qlTvqf1KlnALrxaBQrBfyWOcEVXIm0w0uihNAgTFaAcmyubV3yrgAlAkuqqP8mgyYboooOZbWgjOuEgliAGJJvJADCtIdUmH)4Dggz7qKaJc4OvgDbSPgTvaDwQJeur1yN5WXPMr7hGMa6SuhjOIQXoZrqqP8mgyYboooOZbWgjOuEgliAGwz0PMr7hGMi5HMZzorGKCbiiOuEgJJtnJ2panHIaZspkiOuEgJ2M(uT3ymHdAij3HWapfqRsToMQ9glQp2cslLqkqNDmaiHbYdIcGrtDSEaIeWOqtzHWqqcfbMLEuaxllegcsOiWS0Jc2MkQcsUQB6t1EJXeoOHKChcd8uaDOo9yCGIvcMTNcb5brrnMh(wbgCnmXj3Bmzagn1X6biscIcnB6t1EJXeoOHKChcd8uaDLG9osOTG8GOeGhdHHGevc27iH2kGRB6t1EJXeoOHKChcd8uanGuscjXbkcKKlGM(uT3ymHdAij3HWapfqhQtpghOyLGz7PqqEquamAQJ1dqKeefA20NQ9gJjCqdj5oeg4PaAvQ1XuT3yr9XwqAPesb6SJbajmqEquOBtIdUcayQxaIA1gef5RMJlegcsK8qZ5mNiqsUaeW1CCHWqqcfbMLEuaxZXfcdbjqPAQjyAX6biseW1020NQ9gJjCqdj5oeg4PaA1ymurY9gdKheLauJXqfj3BmbCTmwnQ1Xnjo4Ye(J3zyKTdrcmkY30NQ9gJjCqdj5oeg4PaAfbMLEKezl5Ocb5brrnJ2panHIaZspsISLCuHcfGK4GSiejv7nwQbJICc(l4KrhGrtDSEaIKGOiphhGrtDSEaIKGOqtzQz0(bOjc1PhJduSsWS9uOGGs5zmWCu(klphhGrtDSEaIekbwMAgTFaAIqD6X4afRemBpfkiOuEgdmhLVYYltnJ2panrLG9osOTcckLNXaZr5RS8020NQ9gJjCqdj5oeg4PaAvQ1XuT3yr9XwqAPesb6SJbajSM(uT3ymHdAij3HWapfqRgJHksU3yG8GOeGAmgQi5EJjGRB6t1EJXeoOHKChcd8uaTIaZspsISLCuHn9PAVXych0qsUdHbEkGojQ0W4oecABtFQ2BmMWbnKK7qyGNcOvJXqfj3BSIlpKWUXkviF1YlF10uoASqUIlWKyN5WkUGs4)4pQauUcqX8t)9xfaS)tQEiB)qdPF(Cqdj5oegF9tq(h8rqF)Src7pH3rkx03VcqAoit00ZVNH9lp)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pDYhmTIME(9mSF55N(b1X4HKf99Zhb2qOH4GIaXx)70pFeydHgIdkcKaTmuJE(6No5cMwrtp)Eg2pn5N(b1X4HKf99Zhb2qOH4GIaXx)70pFeydHgIdkcKaTmuJE(6No5cMwrtp)Eg2p44N(b1X4HKf99Z3MA0wrG4R)D6NVn1OTIajqld1ONV(PJMbtROPNFpd7NgXp9dQJXdjl67NpcSHqdXbfbIV(3PF(iWgcnehueibAzOg981pDYfmTIME(9mSF(l)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pD0myAfn9n9Gs4)4pQauUcqX8t)9xfaS)tQEiB)qdPF(8iucRx(6NG8p4JG((zJe2FcVJuUOVFfG0CqMOPNFpd7xE(PFqDmEizrF)8TPgTvei(6FN(5BtnARiqc0Yqn65RF6KlyAfn987zy)0KF6huhJhsw03pFBQrBfbIV(3PF(2uJ2kcKaTmuJE(6No5cMwrtp)Eg2p44N(b1X4HKf99Z3MA0wrG4R)D6NVn1OTIajqld1ONV(Pt(GPv0030dkH)J)Ocq5kafZp93FvaW(pP6HS9dnK(5RMGQrkmx(6NG8p4JG((zJe2FcVJuUOVFfG0CqMOPNFpd7NgXp9dQJXdjl67Np2aRdpZlceF9Vt)8XgyD4zErGeOLHA0Zx)0jxW0kA653ZW(Pr8t)G6y8qYI((5JnW6WZ8IaXx)70pFSbwhEMxeibAzOg981FU9ZFI)m)2pDYfmTIM(MEqj8F8hvakxbOy(P)(Rca2)jvpKTFOH0pFQz0(bOX4RFcY)Gpc67Nnsy)j8os5I((vasZbzIME(9mSFAYp9dQJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9NB)8N4pZV9tNCbtROPNFpd7pW8t)G6y8qYI((5JnW6WZ8IaXx)70pFSbwhEMxeibAzOg981pDYfmTIME(9mS)aZp9dQJXdjl67Np2aRdpZlceF9Vt)8XgyD4zErGeOLHA0Zx)52p)j(Z8B)0jxW0kA653ZW(bh)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pDYfmTIME(9mSF5cm)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pDYfmTIME(9mSFAwn)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pDboyAfn987zy)0SA(PFqDmEizrF)8rGneAioOiq81)o9Zhb2qOH4GIajqld1ONV(Pt(GPv00ZVNH9ttAYp9dQJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9tNCbtROPNFpd7NMbMF6huhJhsw03pFBQrBfbIV(3PF(2uJ2kcKaTmuJE(6No5cMwrtFtpOe(p(JkaLRaum)0F)vba7)KQhY2p0q6NpOZogaKW4RFcY)Gpc67Nnsy)j8os5I((vasZbzIME(9mSF54N(b1X4HKf99Z3MA0wrG4R)D6NVn1OTIajqld1ONV(PtUGPv00ZVNH9lh)0pOogpKSOVF(iWgcnehuei(6FN(5JaBi0qCqrGeOLHA0Zx)0jxW0kA653ZW(LNF6huhJhsw03pFBQrBfbIV(3PF(2uJ2kcKaTmuJE(6No5dMwrtp)Eg2pn5N(b1X4HKf99Z3MA0wrG4R)D6NVn1OTIajqld1ONV(PtUGPv00ZVNH9hy(PFqDmEizrF)8TPgTvei(6FN(5BtnARiqc0Yqn65RF6OrbtROPNFpd7hC8t)G6y8qYI((5BtnARiq81)o9Z3MA0wrGeOLHA0Zx)0rJcMwrtFtpOe(p(JkaLRaum)0F)vba7)KQhY2p0q6NpKfHiXuThpKV(ji)d(iOVF2iH9NW7iLl67xbinhKjA653ZW(LNF6huhJhsw03pFBQrBfbIV(3PF(2uJ2kcKaTmuJE(6No5cMwrtp)Eg2p44N(b1X4HKf99Z3MA0wrG4R)D6NVn1OTIajqld1ONV(PtUGPv00ZVNH9do(PFqDmEizrF)8rGneAioOiq81)o9Zhb2qOH4GIajqld1ONV(Pt(GPv00ZVNH9tJ4N(b1X4HKf99Zhb2qOH4GIaXx)70pFeydHgIdkcKaTmuJE(6No5cMwrtp)Eg2p)LF6huhJhsw03pFeydHgIdkceF9Vt)8rGneAioOiqc0Yqn65RF6KlyAfn9n9Gs4)4pQauUcqX8t)9xfaS)tQEiB)qdPF(qweIeRNrFMdF9tq(h8rqF)Src7pH3rkx03VcqAoit00ZVNH9lh)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pD0myAfn987zy)bMF6huhJhsw03pFeydHgIdkceF9Vt)8rGneAioOiqc0Yqn65R)C7N)e)z(TF6KlyAfn987zy)Yvn)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pDYfmTIME(9mSF5cm)0pOogpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pD0myAfn9n9GYs1dzrF)83(t1EJ1V(ylt00xCt4fWqkUUNeOwC1hBzLQkUQz0(bOXkvvQqUsvfx0Yqn6lGO4Qi3IKllUHWqqIKhAoN5ebsYfGaUUFoU(dHHGekcml9OaUUFz9hcdbjueyw6rbBtfv9tPF5QUFoU(dhgRFz9dDoa2ibLYZy9hu)YdUIBQ2BSIB9S3yLTuH8LQkUOLHA0xarXvrUfjxwCz1Owh3K4GltOphallwjyVJeAB)GrPF57NJR)a6NKNpI8qBfP3ZeyWhBz9ZX1pjpFe5H2ksVNjoRFW6N)cU(546NKNpI8qBfP3ZeW1f3uT3yfx95ayzXkb7DKqBlBPcAwQQ4IwgQrFbefxf5wKCzXLU(dHHGejp0CoZjcKKlabCD)CC9hcdbjueyw6rbCD)Y6pegcsOiWS0Jc2MkQ6Ns)YvD)02VS(dO)n1OTcmyubV3yrgAlAkuGwgQrFXnv7nwXf6iyOEgFzlve4svfx0Yqn6lGO4Qi3IKllUSbwhEMxudZwyngrcC9EJjqld1OVFoU(zdSo8mVG3OZ90yKnAEOTc0Yqn6lUNTiHaxVXdQ4YgyD4zEbVrN7PXiB08qBlUNTiHaxVXtsc9xUyXvUIBQ2BSIlKgzauKeAlUNTiHaxVrh9eM6IRCLTub4kvvCrld1OVaIIRIClsUS4sx)b0)MA0wbgmQG3BSidTfnfkqld1OVFoU(vZO9dqtGbJk49glYqBrtHcckLNX6pO(bN89tB)Y6h6CaSrckLNX6hS(LdCf3uT3yfxgGd1(4af5HMdMMclBPcAuPQIBQ2BSIBOgzSZCIduKbljHKIlAzOg9fqu2sf83svf3uT3yf3qnYyN5ehOycVWswXfTmuJ(cikBPcAOuvXnv7nwXnuJm2zoXbkc8Sfjfx0Yqn6lGOSLkOXLQkUPAVXkUHAKXoZjoqrwn5mNIlAzOg9fqu2sfYvDPQIlAzOg9fquCt1EJvCpJPiWBgQXi)doTfwk6rENclUkYTi5YIBimeKi5HMZzorGKCbiGR7NJR)qyiiHIaZspkGR7xw)HWqqcfbMLEuW2urv)u6xUQ7NJR)WHX6xw)qNdGnsqP8mw)b1pnRU4APewCpJPiWBgQXi)doTfwk6rENclBPc5KRuvXfTmuJ(cikUPAVXkUdpKaeaQLoZjwparsurOMTPU4Qi3IKllUHWqqIKhAoN5ebsYfGaUUFoU(dHHGekcml9OaUUFz9hcdbjueyw6rbBtfv9tPF5QUFoU(dhgRFz9dDoa2ibLYZy9hu)YbUIRLsyXD4HeGaqT0zoX6bisIkc1Sn1LTuHCYxQQ4IwgQrFbef3uT3yfxFsOsAgl6rfvrEdjv3sDXvrUfjxwCdHHGejp0CoZjcKKlabCD)CC9hcdbjueyw6rbCD)Y6pegcsOiWS0Jc2MkQ6Ns)YvD)CC9homw)Y6h6CaSrckLNX6pO(LV6IRLsyX1NeQKMXIEurvK3qs1Tux2sfYrZsvfx0Yqn6lGO4MQ9gR4kLQmKGrgae3Oem7ufxf5wKCzXnegcsK8qZ5mNiqsUaeW19ZX1FimeKqrGzPhfW19lR)qyiiHIaZspkyBQOQFk9lx19ZX1F4Wy9lRFOZbWgjOuEgR)G6x(QlUwkHfxPuLHemYaG4gLGzNQSLkKlWLQkUOLHA0xarXnv7nwXfkH1l1r1aBlsKWKbtWIRIClsUS4gq)BQrBfkcml9OaTmuJ((546pegcsOiWS0Jc46(546pCyS(L1p05ayJeukpJ1Fq9tZQlUwkHfxOewVuhvdSTirctgmblBPc5axPQIlAzOg9fquCTuclUEcMEOJGrEiJH6IBQ2BSIRNGPh6iyKhYyOUSLkKJgvQQ4IwgQrFbefxlLWIlJkynviHfbEMtXnv7nwXLrfSMkKWIapZPSLkKJ)wQQ4IwgQrFbefxlLWIRd5KIQXJbxCt1EJvCDiNuunEm4YwQqoAOuvXfTmuJ(cikUwkHfxjuAiuhhOyDY2i7mwXnv7nwXvcLgc1XbkwNSnYoJv2sfYrJlvvCrld1OVaIIRLsyXLvNemkH5gbmdvf3uT3yfxwDsWOeMBeWmuv2sfYxDPQIlAzOg9fquCTuclUSuZlDqFecMDJftPA9bDiP4MQ9gR4YsnV0b9riy2nwmLQ1h0HKYwQqE5kvvCrld1OVaIIRLsyX15sBJdXsj02uhRXKOlUPAVXkUoxABCiwkH2M6ynMeDzlviV8LQkUOLHA0xarX1sjS4c8mptLKiqa4Y2XWIBQ2BSIlWZ8mvsIabGlBhdlBPc5PzPQIlAzOg9fquCTuclUmvsyXbkcrYfjwQJSLCqyXnv7nwXLPscloqrisUiXsDKTKdclBPc5dCPQIlAzOg9fquCTuclUka5zS4af9J0z5EJvCt1EJvCvaYZyXbk6hPZY9gRSLkKhCLQkUOLHA0xarX1sjS4IjzbesWKkKWINuDQ2IBQ2BSIlMKfqibtQqclEs1PAlBPc5PrLQkUOLHA0xarXnv7nwXfaMKnoqXfagzatIuXvrUfjxwCdO)qyiirYdnNZCIaj5cqax3VS(dO)qyiiHIaZspkGRlUwkHfxays24afxayKbmjsLTuH883svfx0Yqn6lGO4MQ9gR46Ot)L7qyXW07Gfxf5wKCzXnegcsK8qZ5mNiqsUaeW19ZX1FimeKqrGzPhfW19lR)qyiiHIaZspkyBQOQFWO0VCv3phx)Qz0(bOjsEO5CMteijxacckLNX6hS(dm46NJRF1mA)a0ekcml9OGGs5zS(bR)adUIRLsyX1rN(l3HWIHP3blBPc5PHsvfx0Yqn6lGO4Qi3IKllUHWqqIKhAoN5ebsYfGaUUFoU(dHHGekcml9OaUUFz9hcdbjueyw6rbBtfv9dgL(LR6IBQ2BSIlmdJ3IsSYwQqEACPQIlAzOg9fquCt1EJvCDsEOooqXfagHocBJjj8wKuCvKBrYLfx66pegcsK8qZ5mNiqsUaeW19ZX1FimeKqrGzPhfW19tBX1sjS46K8qDCGIlamcDe2gts4TiPSLkOz1LQkUOLHA0xarXvrUfjxwCPRFaJM6y9aej9dgL(dC)Y6FpjS)G6hC9ZX1pGrtDSEaIK(bJs)0SFz9tx)7jH9dw)GRFoU(jWgcnehuSaWOu6CSLKlYIvc27iH2kqld1OVFA7NJRFaJM6y9aej9dgL(LVFz9tGneAioOGxAoWjXZIsJeAlSKaTmuJ((L1)MA0wb0zPosqfvJDMJaTmuJ((546FtnARaWOPoM8qZbjc0Yqn67xw)Qz0(bOjamAQJjp0CqIGGs5zS(P0F19tB)Y6NU(dO)n1OTcgsYAaNKaTmuJ((546pG(3uJ2kGol1rcQOASZCeOLHA03phx)Qz0(bOjyijRbCscckLNX6hS(RUFAlUPAVXkUjp0CoZjcKKlGYwQGMYvQQ4IwgQrFbefxf5wKCzXfWOPowpars)GrP)a3VS(3tc7pO(bx)CC9dy0uhRhGiPFWO0pn7xw)7jH9dw)GR4MQ9gR4QiWS0JLTubnLVuvXnv7nwXnzaqlci16byXfTmuJ(cikBPcAsZsvfx0Yqn6lGO4Qi3IKllU7jHXDIaQD6Ns)v3VS(bmAQJ1dqK0Fqu6x((L1pD9hcdbjsEO5CMteijxac46(546FtnARqrGzPhfOLHA03VS(PRF1mA)a0ekcml9OGGs5zS(P0F19ZX1FimeKqrGzPhfW19tB)CC9homw)Y6h6CaSrckLNX6pO(LV6(PT4MQ9gR4cy0uhtEO5GKYwQGMbUuvXfTmuJ(cikUkYTi5YIlD9dy0uhRhGiPFWO0FG7xw)7jH9hu)0q)CC9dy0uhRhGiPFWO0pn7xw)01)Esy)GrPFAOFoU(z1Owh3K4Glt4pENHr2oeP(bJs)Y3VS(vdp0sBfurn5sRFA7N2(L1VAgTFaAIKhAoN5ebsYfGGGs5zS(bRFhLVFz9VNeg3jcO2PFk9xD)Y6NU(dO)n1OTcgsYAaNKaTmuJ((546pegcsWqswd4KeW19tB)Y6NU(dOFsE(iYdTvKEptGbFSL1phx)K88rKhARi9EMaUUFoU(j55Jip0wr69mXz9dw)bU6(PTFz9tx)b0FimeKi5HMZzorGKCbiGR7NJRFaJM6y9aej9tPFW1phx)Qz0(bOjaKssijoqrGKCbiiOuEgRFoU(z1Owh3K4Glt4pENHr2oeP(bJs)Y3VS(vdp0sBfurn5sRFAlUPAVXkUqNL6ibvun2zoLTSfxpcLW6TuvPc5kvvCt1EJvCjyimvyXfTmuJ(cikBPc5lvvCrld1OVaII7uxCz4wCt1EJvC5LKld1yXLxQHXIlD9dy0uhRhGiPFWO0FG7xw)7jH9hu)0q)CC9dy0uhRhGiPFWO0pn7xw)01)Esy)GrPFAOFoU(z1Owh3K4Glt4pENHr2oeP(bJs)Y3VS(vdp0sBfurn5sRFA7N2(L1VAgTFaAIKhAoN5ebsYfGGGs5zS(bRFhLVFz9VNeg3jcO2PFk9xD)Y6NU(dO)n1OTcgsYAaNKaTmuJ((546pegcsWqswd4KeW19tB)Y6NU(dOFsE(iYdTvKEptGbFSL1phx)K88rKhARi9EMaUUFoU(j55Jip0wr69mXz9dw)bU6(PTFz9tx)b0FimeKi5HMZzorGKCbiGR7NJRFaJM6y9aej9tPFW1phx)Qz0(bOjaKssijoqrGKCbiiOuEgRFoU(z1Owh3K4Glt4pENHr2oeP(bJs)Y3VS(vdp0sBfurn5sRFAlU8ss0sjS4crIem9ux2sf0SuvXfTmuJ(cikUtDXLHBXnv7nwXLxsUmuJfxEPgglU01FimeKqrGzPhf(bO1VS(vZO9dqtOiWS0JcckLNX6hS(LR6(546pegcsOiWS0Jc2MkQ6hmk9tZ(546xnJ2panrYdnNZCIaj5cqqqP8mw)G1VCv3pT9lRF66pG(3uJ2kGol1rcQOASZCeOLHA03phx)Qz0(bOjGol1rcQOASZCeeukpJ1py9lx19ZX1pGrtDSEaIeHhHo1T9tP)Q7xw)PAVXeqNL6ibvun2zoc)XYqn67N2(L1p05ayJeukpJ1py9td9lRFwnQ1Xnjo4Ye(J3zyKTdrQ)G6hCfxEjjAPewCrwKGPN6YwQiWLQkUOLHA0xarXnv7nwXvLADmv7nwuFST4Qp2gTuclUQz0(bOXkBPcWvQQ4IwgQrFbefxf5wKCzXLU(dOFsE(iYdTvKEptGbFSL1phx)K88rKhARi9EMaUUFoU(j55Jip0wr69mXz9hu)04(546NKNpI8qBfP3ZeN1py9tZQ7N2(L1pD9VPgTvGbJk49glYqBrtHc0Yqn67xw)Qz0(bOjWGrf8EJfzOTOPqbbLYZy9hu)04(L1pRg164MehCzc)X7mmY2Hi1Fq9dU(546FtnARa6SuhjOIQXoZrGwgQrF)Y6xnJ2panb0zPosqfvJDMJGGs5zS(dQFAC)02VS(HohaBKGs5zS(bRFAO4MQ9gR4QsToMQ9glQp2wC1hBJwkHfxKfHiX6z0N5u2sf0Osvfx0Yqn6lGO4Qi3IKllUEmegcsGbJk49glYqBrtHc46(5463JHWqqcOZsDKGkQg7mhbCDXLTKtTLkKR4MQ9gR4QsToMQ9glQp2wC1hBJwkHfxKfHiXuThpSSLk4VLQkUOLHA0xarXnv7nwXvLADmv7nwuFST4Qp2gTuclUoOHKChcRSLT4wtq1ifMBPQsfYvQQ4MQ9gR4wp7nwXfTmuJ(cikBPc5lvvCt1EJvCd1iJDMtCGImyjjKuCrld1OVaIYwQGMLQkUPAVXkUHAKXoZjoqXeEHLSIlAzOg9fqu2sfbUuvXnv7nwXnuJm2zoXbkc8Sfjfx0Yqn6lGOSLkaxPQIBQ2BSIBOgzSZCIduKvtoZP4IwgQrFbeLTubnQuvXfTmuJ(cikUkYTi5YIlBG1HN5f1WSfwJrKaxV3yc0Yqn67NJRF2aRdpZl4n6CpngzJMhARaTmuJ(IBQ2BSIlKgzauKeAlBPc(BPQIlAzOg9fquCvKBrYLf3n1OTcOZsDKGkQg7mhbAzOg99lR)n1OTcgsYAaNKaTmuJ(IBQ2BSIBsuPHXDie02YwQGgkvvCt1EJvCzaou7JduKhAoyAkS4IwgQrFbeLTSfxh0qsUdHvQQuHCLQkUOLHA0xarXvrUfjxwCbmAQJ1dqK0pL(bx)CC9tx)EmegcsujyVJeARaUUFoU(bmAQJ1dqK0pL(dC)02VS(dHHGe(J3zyKGSXstHc46(546pegcsay0uhtEO5GebCDXnv7nwXvLADmv7nwuFST4Qp2gTuclUqNDmaiHv2sfYxQQ4IwgQrFbefxf5wKCzXnG(jWgcnehu4HxQdhyZhDsEOwGwgQrF)CC9hq)BQrBfqNL6ibvun2zoc0Yqn67xw)b0)MA0wbgmQG3BSidTfnfkqld1OVFoU(dhgRFz9dDoa2ibLYZy9hu)0qXnv7nwXLxA8p4JbajSiGuscjLTubnlvvCrld1OVaIIRIClsUS4sGneAioOybGrP0hRts6mMaTmuJ((546xn8qlTvWdTfa1K(L1VAgTFaAIKbaTiGuRhGcckLNX6hS(LxUQlUPAVXkUasjjKehOiqsUakBPIaxQQ4IwgQrFbefxf5wKCzXfWOPowpars)brPF57xw)mCJHJbZe7He5PHyGRv9lRF66xnJ2panrYdnNZCIaj5cqqqP8mw)CC9RMr7hGMqrGzPhfeukpJ1pTf3uT3yfxGjvyCGIjdaYkBPcWvQQ4IwgQrFbefxf5wKCzXfWOPowpars)brPF57xw)b0VhdHHGevc27iH2kGR7xw)01Fa9VPgTvWqswd4KeOLHA03phx)HWqqcgsYAaNKaUUFA7xw)01Fa9tYZhrEOTI07zcm4JTS(546NKNpI8qBfP3ZeN1py9tZQ7NJRFsE(iYdTvKEptax3pT9lRF66pG(3uJ2kGol1rcQOASZCeOLHA03phx)EmegcsaDwQJeur1yN5iGR7NJRF1mA)a0eqNL6ibvun2zocckLNX6hS(LV6(PTFz9tx)b0)MA0wbgmQG3BSidTfnfkqld1OVFoU(HohaBKGs5zS(dQFAOFoU(z1Owh3K4Glt4pENHr2oeP(bJs)GRFA7xw)01VAgTFaAIKhAoN5ebsYfGGGs5zS(bRF5ax)CC9RMr7hGMqrGzPhfeukpJ1py9lh46NJRFOZbWgjOuEgR)G6Ng6N2IBQ2BSIR)4Dgg3rRlBPcAuPQIlAzOg9fquCvKBrYLf3a63JHWqqIkb7DKqBfW19lRF66hWOPowpars)GrPF56xw)eydHgIdkwayukDo2sYfzXkb7DKqBfOLHA03phx)agn1X6bis6hmk9lF)0wCt1EJvCReS3rcTTSLk4VLQkUOLHA0xarXvrUfjxwCPRFaJM6y9aej9tP)Q7NJRFaJM6y9aej9heL(LVFz9RMr7hGMiuNEmoqXkbZ2tHcckLNX6hS(Du((RC)Y3pT9lRF66pG(j55Jip0wr69mbg8Xww)CC9tYZhrEOTI07zIZ6hS(LV6(546NKNpI8qBfP3ZeW19tB)Y6NU(dO)n1OTcgsYAaNKaTmuJ((546xnJ2panbdjznGtsqqP8mw)G1p46NJRF1WdT0wbvutU06N2(L1pD9hq)BQrBfyWOcEVXIm0w0uOaTmuJ((546xnJ2panbgmQG3BSidTfnfkiOuEgRFW6xoW1phx)qNdGnsqP8mw)b1pn0phx)SAuRJBsCWLj8hVZWiBhIu)GrPFW1pT9lRF66pG(3uJ2kGol1rcQOASZCeOLHA03phx)Qz0(bOjGol1rcQOASZCeeukpJ1py9lh46NJRFOZbWgjOuEgR)G6Ng6N2(L1pD9RMr7hGMi5HMZzorGKCbiiOuEgRFoU(vZO9dqtOiWS0JcckLNX6N2IBQ2BSIlWKkmoqXKbazLTubnuQQ4IwgQrFbefxf5wKCzXfWOPowpars)GrPFA2VS(dHHGekcml9OaUUFz9hcdbjueyw6rbBtfv9hu)YvDXnv7nwXvLADmv7nwuFST4Qp2gTuclUqNDmaiHv2sf04svfx0Yqn6lGO4Qi3IKllUQX8W3kWGRHjo5EJ1VS(bmAQJ1dqK0Fqu6NMf3uT3yf3qD6X4afRemBpfw2sfYvDPQIlAzOg9fquCvKBrYLf3a63JHWqqIkb7DKqBfW1f3uT3yf3kb7DKqBlBPc5KRuvXnv7nwXfqkjHK4afbsYfqXfTmuJ(cikBPc5KVuvXfTmuJ(cikUkYTi5YIlGrtDSEaIK(dIs)0S4MQ9gR4gQtpghOyLGz7PWYwQqoAwQQ4IwgQrFbefxf5wKCzXLU(3K4GRaaM6fGOwT9heL(LV6(546pegcsK8qZ5mNiqsUaeW19ZX1FimeKqrGzPhfW19ZX1FimeKaLQPMGPfRhGirax3pTf3uT3yfxvQ1XuT3yr9X2IR(yB0sjS4cD2XaGewzlvixGlvvCrld1OVaIIRIClsUS4gq)QXyOIK7nMaUUFz9ZQrToUjXbxMWF8odJSDis9dgL(LV4MQ9gR4QgJHksU3yLTuHCGRuvXfTmuJ(cikUkYTi5YIRAgTFaAcfbMLEKezl5OcfkajXbzrisQ2BSu3pyu6xob)fC9lRF66hWOPowpars)brPF57NJRFaJM6y9aej9heL(Pz)Y6xnJ2panrOo9yCGIvcMTNcfeukpJ1py97O89x5(LVFoU(bmAQJ1dqK0pL(dC)Y6xnJ2panrOo9yCGIvcMTNcfeukpJ1py97O89x5(LVFz9RMr7hGMOsWEhj0wbbLYZy9dw)okF)vUF57N2IBQ2BSIRIaZspsISLCuHLTuHC0Osvfx0Yqn6lGO4MQ9gR4QsToMQ9glQp2wC1hBJwkHfxOZogaKWkBPc54VLQkUOLHA0xarXvrUfjxwCdOF1ymurY9gtaxxCt1EJvCvJXqfj3BSYwQqoAOuvXnv7nwXvrGzPhjr2soQWIlAzOg9fqu2sfYrJlvvCt1EJvCtIknmUdHG2wCrld1OVaIYwQq(QlvvCt1EJvCvJXqfj3BSIlAzOg9fqu2YwCHo7yaqcRuvPc5kvvCrld1OVaII7uxCz4wCt1EJvC5LKld1yXLxQHXIlRg164MehCzc)X7mmY2Hi1pL(LVFz9hq)01pb2qOH4GcOZsDKhs8NAfOLHA03phx)BQrBfKZbWIdmlYdj(tTc0Yqn67N2(546NvJADCtIdUmH)4Dggz7qK6hS(LVFoU(dHHGeOun1emTy9aejc46(L1Fa97XqyiirLG9osOTc46(L1Fa9hcdbj8hVZWynmPEyOaUU4YljrlLWIRNfvjBZqnw2sfYxQQ4IwgQrFbefxf5wKCzXLU(vZO9dqtK8qZ5mNiqsUaeeukpJ1py9lh46NJRF1mA)a0ekcml9OGGs5zS(bRF5ax)02VS(PR)a6FtnARa6SuhjOIQXoZrGwgQrF)CC9RMr7hGMa6SuhjOIQXoZrqqP8mw)G1FQ2BSOAgTFaA9tB)Y6NU(dO)n1OTcmyubV3yrgAlAkuGwgQrF)CC9RMr7hGMadgvW7nwKH2IMcfeukpJ1py9NQ9glQMr7hGw)CC9ZQrToUjXbxMWF8odJSDis9dgL(bx)02VS(PR)a6NKNpI8qBfP3ZeyWhBz9ZX1pjpFe5H2ksVNjoRFW6pWv3phx)K88rKhARi9EM4S(dQFhLVFoU(j55Jip0wr69mbCD)02VS(PR)a6xn8qlTvqf1KlT(546NU(vZO9dqt4pENHXD0AbbLYZy9hu)04(546xnJ2panH)4Dgg3rRfeukpJ1py9NQ9glQMr7hGw)02pT9ZX1p05ayJeukpJ1Fq9lh46xw)qNdGnsqP8mw)G1p46NJR)qyiiHIaZspkGR7xw)HWqqcfbMLEuW2urv)b1VCvxCt1EJvCzijRbCsLTubnlvvCrld1OVaIIRIClsUS4sx)HWqqcfbMLEu4hGw)Y6xnJ2panHIaZspkiOuEgRFW6xUQ7NJR)qyiiHIaZspkyBQOQFWO0pn7NJRF1mA)a0ejp0CoZjcKKlabbLYZy9dw)YvD)02VS(PR)a6FtnARa6SuhjOIQXoZrGwgQrF)CC9RMr7hGMa6SuhjOIQXoZrqqP8mw)G1VCv3phx)agn1X6biseEe6u32pL(RUFz9tx)b0pVKCzOgfqKibtp19ZX1FQ2Bmb0zPosqfvJDMJWFSmuJ((PTFA7xw)qNdGnsqP8mw)G1pn0VS(z1Owh3K4Glt4pENHr2oeP(dQFWvCt1EJvCXGrf8EJfzOTOPWYwQiWLQkUOLHA0xarXvrUfjxwC5LKld1OWZIQKTzOg7xw)b0FimeKGxA8p4JbajSiGuscjc46(L1pD9tx)b0)MA0wHIaZspkqld1OVFoU(vZO9dqtOiWS0JcckLNX6hS(Du((RC)0SFA7xw)01Fa9VPgTvGbJk49glYqBrtHc0Yqn67NJRF1mA)a0eyWOcEVXIm0w0uOGGs5zS(bRFhLV)k3pnQFoU(vZO9dqtGbJk49glYqBrtHcckLNX6hS(Du((RC)bUFz9dy0uhRhGiPFWO0p46NJRFwnQ1Xnjo4Ye(J3zyKTdrQFWO0p46NJR)a6FtnARGHKSgWjjqld1OVFz9RMr7hGMadgvW7nwKH2IMcfeukpJ1py97O89x5(LVFoU(bmAQJ1dqKi8i0PUTFk9xD)Y6NU(dOFEj5YqnkqwKGPN6(546pv7nMadgvW7nwKH2IMcf(JLHA03pT9tB)Y6NU(dO)n1OTcOZsDKGkQg7mhbAzOg99ZX1VAgTFaAcOZsDKGkQg7mhbbLYZy9dw)okF)vUFAu)CC9RMr7hGMa6SuhjOIQXoZrqqP8mw)G1VJY3FL7pW9lRFaJM6y9aej9dgL(bx)CC9hq)BQrBfmKK1aojbAzOg99lRF1mA)a0eqNL6ibvun2zocckLNX6hS(Du((RC)Y3phx)agn1X6biseEe6u32pL(RUFz9tx)b0pVKCzOgfqKibtp19ZX1FQ2Bmb0zPosqfvJDMJWFSmuJ((PTFA7NJR)n1OTcaJM6yYdnhKiqld1OVFz9RMr7hGMaWOPoM8qZbjcckLNX6pO(Du((RC)0SFoU(dHHGeagn1XKhAoirax3phx)HWqqcfbMLEuax3VS(dHHGekcml9OGTPIQ(dQF5QUFoU(HohaBKGs5zS(dQFAOFAlUPAVXkU(J3zyKTdrQSLkaxPQIlAzOg9fquCvKBrYLfx66pG(3uJ2kueyw6rbAzOg99ZX1VAgTFaAcfbMLEuqqP8mw)G1VJY3FL7NM9tB)Y6NU(dO)n1OTcmyubV3yrgAlAkuGwgQrF)CC9RMr7hGMadgvW7nwKH2IMcfeukpJ1py97O89x5(PH(546xnJ2panbgmQG3BSidTfnfkiOuEgRFW63r57VY9tJ6xw)agn1X6bis6hmk9h4(546pG(3uJ2kyijRbCsc0Yqn67xw)Qz0(bOjWGrf8EJfzOTOPqbbLYZy9dw)okF)vUF57NJRFaJM6y9aejcpcDQB7Ns)v3VS(PR)a6NxsUmuJcKfjy6PUFoU(t1EJjWGrf8EJfzOTOPqH)yzOg99tB)02VS(PR)a6FtnARa6SuhjOIQXoZrGwgQrF)CC9RMr7hGMa6SuhjOIQXoZrqqP8mw)G1VJY3FL7Ng6NJRF1mA)a0eqNL6ibvun2zocckLNX6hS(Du((RC)0O(L1pGrtDSEaIK(bJs)bUFoU(dO)n1OTcgsYAaNKaTmuJ((L1VAgTFaAcOZsDKGkQg7mhbbLYZy9dw)okF)vUF57NJRFaJM6y9aejcpcDQB7Ns)v3VS(PR)a6NxsUmuJcisKGPN6(546pv7nMa6SuhjOIQXoZr4pwgQrF)02pT9ZX1)MA0wbGrtDm5HMdseOLHA03VS(vZO9dqtay0uhtEO5GebbLYZy9hu)okF)vUFA2phx)HWqqcaJM6yYdnhKiGR7NJR)qyiiHIaZspkGR7xw)HWqqcfbMLEuW2urv)b1VCv3phx)qNdGnsqP8mw)b1pnuCt1EJvCxuQwNewKhs8NAlBzlUilcrIPApEyPQsfYvQQ4MQ9gR4cDemupJV4IwgQrFbeLTuH8LQkUOLHA0xarXvrUfjxwCbmAQJ1dqK0pL(bx)CC97XqyiirLG9osOTc46(5463JHWqqcOZsDKGkQg7mhbCD)Y6NU(9yimeKa6SuhjOIQXoZrqqP8mw)b1VJYlKYG7NJRFwnQ1Xnjo4Ye(J3zyKTdrQFWO0V89lR)a6FtnARadgvW7nwKH2IMcfOLHA03pT9ZX1VhdHHGeyWOcEVXIm0w0uOaUUFz97XqyiibgmQG3BSidTfnfkiOuEgR)G63r5fszWf3uT3yfxvQ1XuT3yr9X2IR(yB0sjS4cD2XaGewzlvqZsvf3uT3yfx)X7mmUJwxCrld1OVaIYwQiWLQkUPAVXkU8sJ)bFmaiHfbKssiP4IwgQrFbeLTub4kvvCrld1OVaIIRIClsUS4cy0uhRhGiP)GO0V89lRF663JHWqqcOZsDKGkQg7mhbCD)Y63JHWqqcOZsDKGkQg7mhbbLYZy9hu)okF)vUF57xw)b0pb2qOH4Gc)X7mmsq2yPPqbAzOg99ZX1VhdHHGeyWOcEVXIm0w0uOaUUFz97XqyiibgmQG3BSidTfnfkiOuEgR)G63r57NJRFwnQ1Xnjo4Ye(J3zyKTdrQFWO0p46xw)eydHgIdk8hVZWibzJLMcfOLHA03VS(3uJ2kWGrf8EJfzOTOPqbAzOg99tBXnv7nwXfysfghOyYaGSYwQGgvQQ4IwgQrFbefxf5wKCzXvnMh(wbgCnmXj3BS(L1pD9hq)eydHgIdk8hVZWibzJLMcfOLHA03VS(bmAQJ1dqK0Fqu6NM9ZX1pGrtDSEaIK(dIs)Y3pTf3uT3yf3qD6X4afRemBpfw2sf83svfx0Yqn6lGO4Qi3IKllUb0VhdHHGevc27iH2kGR7xw)01pGrtDSEaIK(bJs)Y1VS(jWgcnehuSaWOu6CSLKlYIvc27iH2kqld1OVFoU(bmAQJ1dqK0pyu6x((PT4MQ9gR4wjyVJeABzlvqdLQkUOLHA0xarXnv7nwXvLADmv7nwuFST4Qp2gTuclUqNDmaiHv2sf04svfx0Yqn6lGO4Qi3IKllUagn1X6bis6pik9lFXnv7nwXfysfghOyYaGSYwQqUQlvvCrld1OVaIIRIClsUS4cy0uhRhGiP)GO0pnlUPAVXkUH60JXbkwjy2EkSSLkKtUsvfx0Yqn6lGO4Qi3IKllUb0VhdHHGevc27iH2kGRlUPAVXkUvc27iH2w2sfYjFPQIBQ2BSIlGuscjXbkcKKlGIlAzOg9fqu2sfYrZsvf3uT3yfxfbMLEKezl5OclUOLHA0xarzlvixGlvvCt1EJvCtIknmUdHG2wCrld1OVaIYwQqoWvQQ4MQ9gR4QgJHksU3yfx0Yqn6lGOSLT4ISiejwpJ(mNsvLkKRuvXfTmuJ(cikUkYTi5YIlGrtDSEaIK(P0p46xw)01Fa9VPgTvaDwQJeur1yN5iqld1OVFoU(vZO9dqtaDwQJeur1yN5iiOuEgR)GO0VJY3FL7NM9ZX1VAgTFaAcOZsDKGkQg7mhbbLYZy9dw)PAVXIQz0(bO1pT9lRF66pG(3uJ2kWGrf8EJfzOTOPqbAzOg99ZX1VAgTFaAcmyubV3yrgAlAkuqqP8mw)brPFhLV)k3pn7NJRF1mA)a0eyWOcEVXIm0w0uOGGs5zS(bR)uT3yr1mA)a06NJR)n1OTcOZsDKGkQg7mhbAzOg99tB)Y6NU(dOF1WdT0wbvutU06NJRF1mA)a0e(J3zyChTwqqP8mw)b1pnUFoU(vZO9dqt4pENHXD0AbbLYZy9dw)PAVXIQz0(bO1pTf3uT3yfxgsYAaNuzlviFPQIlAzOg9fquCvKBrYLfxaJM6y9aej9tPFW1phx)EmegcsaDwQJeur1yN5iGR7NJR)qyiiHIaZspkGR7xw)HWqqcfbMLEuW2urv)b1VCvxCt1EJvCvPwht1EJf1hBlU6JTrlLWIl0zhdasyLTubnlvvCrld1OVaIIRIClsUS4gcdbjyijRbCsc46IBQ2BSIlV04FWhdasyraPKeskBPIaxQQ4IwgQrFbefxf5wKCzXLaBi0qCqbV0CGtINfLgj0wyjbAzOg9f3uT3yfxaPKesIdueijxaLTub4kvvCrld1OVaIIRIClsUS4cy0uhRhGiP)GO0V89lRFgUXWXGzI9qI80qmW1QIBQ2BSIlWKkmoqXKbazLTubnQuvXfTmuJ(cikUkYTi5YIlGrtDSEaIK(dIs)0S4MQ9gR4gQtpghOyLGz7PWYwQG)wQQ4IwgQrFbefxf5wKCzXnG(9yimeKOsWEhj0wbCDXnv7nwXTsWEhj02YwQGgkvvCt1EJvCbKssijoqrGKCbuCrld1OVaIYwQGgxQQ4IwgQrFbefxf5wKCzXvnJ2panHIaZspsISLCuHcfGK4GSiejv7nwQ7hmk9lNG)cU(L1pD9dy0uhRhGiP)GO0V89ZX1pGrtDSEaIK(dIs)0SFz9RMr7hGMiuNEmoqXkbZ2tHcckLNX6hS(Du((RC)Y3phx)agn1X6bis6Ns)bUFz9RMr7hGMiuNEmoqXkbZ2tHcckLNX6hS(Du((RC)Y3VS(vZO9dqtujyVJeARGGs5zS(bRFhLV)k3V89tBXnv7nwXvrGzPhjr2soQWYwQqUQlvvCrld1OVaIIRIClsUS4gq)BQrBfqNL6ibvun2zoc0Yqn67xw)Qz0(bOjWGrf8EJfzOTOPqbbLYZy9heL(Du((RC)0SFz9tx)b0VA4HwARGkQjxA9ZX1VAgTFaAc)X7mmUJwliOuEgR)G6Ng3pTf3uT3yfxgsYAaNuzlviNCLQkUOLHA0xarXnv7nwXvLADmv7nwuFST4Qp2gTuclUqNDmaiHv2sfYjFPQIBQ2BSIRIaZspsISLCuHfx0Yqn6lGOSLkKJMLQkUOLHA0xarXvrUfjxwCbmAQJ1dqK0Fqu6pWf3uT3yf3KOsdJ7qiOTLTuHCbUuvXfTmuJ(cikUkYTi5YIlD9hq)BQrBfqNL6ibvun2zoc0Yqn67NJRF1mA)a0eqNL6ibvun2zocckLNX6pik97O89x5(Pz)02VS(PR)a6FtnARadgvW7nwKH2IMcfOLHA03phx)Qz0(bOjWGrf8EJfzOTOPqbbLYZy9heL(Du((RC)0SFoU(3uJ2kGol1rcQOASZCeOLHA03pT9lRF66pG(vdp0sBfurn5sRFoU(vZO9dqt4pENHXD0AbbLYZy9hu)04(PT4MQ9gR4Yqswd4KkBPc5axPQIBQ2BSIRAmgQi5EJvCrld1OVaIYw2Yw2Ywka]] )


end
