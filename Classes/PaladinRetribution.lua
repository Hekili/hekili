-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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


    spec:RegisterPack( "Retribution", 20220821, [[Hekili:T3ZApUnos(BjybCSNnN32V60zr7gyUzxCyc2l3HTxG7(KLLTOT12YwE1JUtdy4F7xvuViPyrrj7oz3BcgGmXsflwSExfjvwmAXFBXJEUjSfFz8nJhFZDJhnC0NUz8O7w8yYRhzlE8O76NC3c)LdU7H)8VYsI8xLM4hEaF3RbHUEioIdtJwdVFXJRs9ds(1dlwPhXJaypYwV4lF8MfpUZ3ZJLbklETe2pV8)2nW1Z)W5p)ZPBtJtoVC8nFa)JXJp)5ZF(x25Eyll(pE(Z)BNx(RhsyBJGz78YdSxoV8yKFyKFYRNxgFmWhg6MOW9Nx(O)(FziFa)NUpbW(ilY94oF4nVeg905LRyjjSi4x(j7oVmmzh(JF5pfFEzs42Tbmp4HB2KHH)u4H3di(f3yCw3Z88t3)hcCJ2YYhcUe8E1)WwGCaEi8K0dbSy4)7N8E4pDH5le)5g)T7sYjRWiy4UE)Dy9UNDiHpZfuxgvXXD8UWxa0hZo6IR6GxhccJOWn(bGi4397oVupJeFJwMj(Ikgk(RwZuZh0fYyZXY1N5wqEDMbJSj31idnE4Xi26W9RCtMFmKZIR)MF)8)WkKGas0jCJtC6(9WAUr4Ctts3Bb(EX)qIn4lgeAatslCBa42ToYDtYh83mhmGdw5FWB4rG1KgWCyrPhXbD6u5REomWnb0XCIddEg4E6XRB0A3dmNKWOiage3jUbWFB4g)dUboaKpfEaOQHSdUaT61l)1X5knfpxp2J35Zc8W1gqbBzUhwZk0G)ZFLTonbvMypZIa90e)9G0g02ar(AGEaTdu34zx)aCggwodZJyRsbf3IFdZZZUr(iqFa97nFteq3UEV(HNDdszZ7Vlm4vNJHVWIEy(0E48C)DNoj(0j96Jp(H5WZbhEbbojO(Bs8qp)N9b(tmqq7Fy(4ERdHvIlWaE6vykpmya8KWapqbCOlUgrr5lGw4UHrS9U(hIFy7Ap(Cc8yNDh3o)ME9FNct80PvPGfvjpn94aaOixFphgk6g665fpK9v)4K4tNuFE6X6pZ)WdtVbrchXkugoGQv)8zNovUg25IQ(CLwXfrB5k0YgwSSSHtFRJsJD9ydrsOIFw80cg5OBY5tfViob8Macpb6NqgmIZl0RzlmAvDEXzUIHn0JTXFTFcijZwL1gNNFm3OyqpUhnNc8CxpA249ZezARDbWY(Ptai2ZyEfeACZGc8zWm4imaGGqZ6lvF6(pPvlBcYzZzSmUjnshXWpzGXELWS(7k4U3)jJCLtN0l261Ku7(pvJ9BlBdF8ZSpedHLxNmFeY(8yCvpnldKDL)wvkj9yZZ4w2bWShwRXIbTkL05bTqsGYuwYMi9yV62iZ5MoqiwzgY9JNPzgbknaHk25VN6TDFEubzrKcaGlGtNSw)c0A(4mDQD6jMn(G)(GWqpUw8fXeg07DKQQet(fh29d8G)iCo(7XKJGmuqvQYNUniCLBG0JeNk6W4I0PMaTzg9KRxb3EgSnNnw1iAeHoJPeOOGtnbkk4utGICEvsGseU0yMJFcBFMvhSsaLJe0lTZ)ifICLU3XJ9SFgB7IuY0APn5gBOkikA0l7yb7XPLhRXzD0RaIdEBOkkzPmv55g90(qq7WdCS58CyKle8713gkASv8P9URDxfbMe7ySeN9PX(R)EsoBCtdsE1zDykQMUN5gNgX1JkS(YNRAuYfOQ4HzrHUgbd(4ywGnJj(P0GNyrXO9KvwjBJ83dllp2xTb69S9HrVI2HhHsbDaJYyBgwmu1gZb4Ajo7cdFYQH4g8S7wMNZgq0dkMU7HAC34t5IqzrbjOM4egH)4aiGCoYCJSI)bSnV41UroGnAcKEYbIGgkelmIyKRSbloncZqatSyJvdE9ouNahTxi4vWfH3MXblPKDGjIlxE7VhQ7MiYH842HdeNoOomN4xCJ2Z1J1Bz17Dk6Z2mdBX2BWZ3XzLR32l0F7dCl3YizeP)pvSeh1YkMALtWTaQdkymGDhOG7gTcEFuBslzG5Pk(Yzg6Naz0XPynffptFrXyUAPhyBcHC)gIl)9UBHm7qT5Quahip2X9QgYZUh2M6g5f7SpebnDFpQkXYFohtCAMfvLNV4tlKEZflSRQC6Ml1RSw7c1GBiKn5CyKNzdllJJrifG4vhC2bLbe(IEiexI8EXi13GQz6EGbtQZjh0PxFkn)5Q1td6Nerbj4nkSxk9QF0SL34MTujDeRFDEzLt6F)VNQKuqS6dQQrXYk9iTNxOBHvV5IF71N4vfkwG0A4E3V20cMUiMbLZU2cZ7r)sfsGKdLtljHbbKWao4(hPzCmNmzkjOVabK5v(aqRWE52008YMzL)eWPQ86Mt4rS4WdU869UCoLzb1SE0ZEpArijVAfKPaNzH9)pVYS1Hh8s9r8CmnAlpDi04LEEf5VteTeb2n9ul25J3vxNVNKxUr9Ao8Os0r6zUblYoQy1kESelRRSiYXP40JMrKfukINSSq3(vHtEdmOrh8m26O8eOvblVpPZlckO647cAE89ZrtZjnd4dfaiKrtxBBtT5Kg2YPLQrRi5OeYraXc(hRA8Q53xTqjednBgqgyQUJtBsC(EX8MvjL6E3lZsxihc6XROWJd2uUX0iQHyhXSeNvHhsJhMavcp(oNPhxtJSwB4xn0wA5tYjmi9LT9ZC8lNeBX7gcvidmsebzyZna8ip8JZe9rFp2FAPvxvIKQmcXuj)jPHbPZA5OQGRKVi9Edk(IEGi85y1MQK5bO9MUD3M0AXjnG13mArH2u74AxSR6RO)3RMhvtIfIiBLcM5Y7al4RzTBmV135BclDsDyY39R8wLToEMf55VoPC1fHflYctJlEZaJ5joo3JmB)XxJyUhYeV82jPjtRSAQYraKZ3XWy5onvUmvvdAQuXrMAk0Ozx0ggF9cLleE2yU3TPgwE9QA3JxEo(1l5vRcB)RtoaGYI6MsOSJtZADiCrDI6S2Qg2vGbKq(xQZDq)3vytpCt(HD50PSvp9HrOJNgbjUPimiFSKme8QKBZwpVjELt9RTPiKm(RK3yoEU1EqN2tSwTzny4v1SXcVp2eFUE2f6LUSyfPRgukiGVaDnvMKj4QXHOzbMqJfR)wOD3HUhFFEyAU(Qeawx3GQ3R7gO3Wjbc3fGBeuEmsPmv(2AkCN9GERKGE6)Fsx)olHRfSGFZPRlMUz15yAERlEVVU2klw41GEIPbw2DVksxzbPJSilLxS9HPjVUkm9GNdF)(i3ijdTKw7oOChbbzS3az9s0ZbpvZBd5LiKNcgMB2Uxfe4I7SuPA3yXuIKM2o0jHEnLpnTZRbeuHqAH1PbTDD96Uvo8tViv6Uu(wm0NPg9dm(Mg8GRO00Ck)nM)P5ACmf8ssu9nSF4MvufMO53O0oFB7otl1rg3KosL2yjbuB3LNjy9MVTDxEWCncWMvz6EutD6lnQc2E3cTk6bUBYwf7IyYSDpMiAnABmsSleqlOtBOjlyM9Z0vgUJ5gaYTJRtaBPIsEB(COq1nhsXRq7Q4CkXhGIpJ7fmfs)TtdJBJ4TJIa7yYeqrTFCKuWIhHsIWJXx(LpC6nZw84lUrOVN4fp()8Z)1V8RF5)4pEE55L)n8Yb5V)yyeEH2WRi07Rq77pVmIbP3fH3PO4q8Ye5MMeU3LFjJwNDH5gE(Z)fqF68YXac)LWdWuZF97Z9k()((S7yw5VlUFtWZ7p(RdihFviVsui8irSmsaltUkyzwhwlteg)TxfQ4JDMko)5geYq5s4rS9TxcBs202X3fPYy74hLxXU2XruLZL3XGsAQ6juRQoIdxG2)Z)x)LsK14sSWHylnR7GqtL0Yq00UToVg4qpb1f1jXXpsLAAlcMCthqWutiWE)mIEEN0bzS8cP7CIgvBld92o12rDMI0pE75SJmetZgQy8v0JzxKl3EHMi3ANCv80e1orBxyQxt7E1XBVQX438ueAlwSumLV34Tto1ftWjguETETP3D)OU4T9I93xKp2VY5Q4W(i)247JFchWcmq(1Ihb24UWOfpIFnjw8i)54NvKYy2Wp(c)JvsoQx8VdVmcVSe(U43CeDfwEE5PtNxQuC55L9uEgVE(ZlNJCO8HW)0r0l)RhrrVjoV8EW2dQKiJ6x8y29ODrcuLbjLz8sUEE5dWSooBsFhOBPTfszVUEBKGrdmZz6FD6Xk6uzwrcEcjb3pN7CD4Md4aalTCvdnTEQGkkj3YZyosOtP5Su3C2cmMrWK361Qjw8wYkGx1bibyX9UDXJJeO8YR2RiSz3gxeqy9mZeJ3g(u2QYIE5XvxNnUqgOOkdQoJeuL1CzFrQ9wKAlGzvTRJR4kbG(JuqNDPCvG(okOZUAUkq)jskHFbDvGE0nkS5Ir6tEjD)(4ozYnfFyLmqz4cs13xXcI((9(9zbHkvzlidugUGuDzwSG0F1G)(SygxkDiOkCHO6kTyHO5gf)9EvOJKWLGQt2s)z6UfYIlIkhwfuMKxQARdRTg0pZiTQ6anx(OC3Lf0NuFdIKB1IePlZSGVrPhJd)JAhE1vBUAScpdh4DAhOMB5SGAKMxIO6t6xcY38zHfHYlWKwuDsMJcQBcTaYibbrRQRQCUJ27iTaNs)7reQ6QidH1V60vitZ7qePAQMVGPUn1clysqq0QA(KHwD3Z6kmQ9TiY0RFR7YxxHmTVfrMQEEXaQFNSvSQP8oLLmNIDDbrQbRirOATukXvU22xBVJpi4ESHTuKNp00zkWQS7I5avQqRs(4Av1aVCT6sDxVVKCVhusl0OhPkvFfVf85Q1A5vpNxOHQtgPvB1gBLHMP8jj7Z2gM9AgHOc1eou9la8HsaB(qcufFAGECpMJBt3MMku0Rm6N6(BlffmhgPZtKiomEgR4b5llKsQgHAFV8kkJ0gII8CfW5N3W1TkeOY6hCPkDP4xIiTsEk4OmtzJpRJflcq8akPK()e6YBfUj3fS2EYKZ9LAbnyosL5t2iP9IKnR6nOBmfPXYIgrvg(kNUE5Mn3UZoZT5LqsVV6IgtkNsf(QCGSMVbVYBx7vsL1fCwyqWzYIxRojBP20YLcbprRyMQyMAs3rKhpV0QOYtG(RX)LX1fYRx2ZWcmzHhZ3r0ffnARa4SpnMkwyQPKfcjbeZesjP4iOI)TGu2pu)(H6hQt4KxEx(5sM7YQlQssEorAwwGQlZTr6C6kKcZe7ZuCK(aY2fWL4SWjrJvYNIZ1TGsxgFH8OCt3WV74p3K87EEO3k5uX5NhLtunjq9adL19(Ceu1)(KM7951YyawfFYOPYer5NfDCTN9nC9twXJLsGGuTPNnAnzZjPi3s5K0UCHYk1khRKvM(MFKTUipqZGHn)7FkgHPn0f(2N5PasvlPrKuDGUYI0vEwxQfRlFhD0eRRaIvn1e8juqRTj4tPGwBtWNrsj6AcoTi86T1jLzuuTZhAKscPF3Skpr0uHe)LooG48jTvc62kdjgtIKgHX9vuFCY(LQ4INfxDbwNwyzYHwZDnriKKY9nXsD7YthIUSYKAPd5vsP11p2Rn7uLHAzUtmgV61OrxQbvRhYR0IAq38SqqT2DVgPK2NMR4c3R5yX2zOKmKUqH6vyQkKu73rJ8WpnMVHuYd1sSriREPB2G54T6jZ3PxV(BDEUcbPPI832KVO)yABFUzJ1N0xt6)Au7Tlp6zctxJkj8TZTjDfbG0svc6scxKkZHsmQZOwk3i(lAtx6u9PMxGHaLkEQgOJ70VMR5AzAlAj04zSVQ2WFkJGUmD9XTtxxVfO5w6ntXJOq1WTvL2QCHBszRTMawAPBLPSzRaRn66UNz1TjGU9PtQsFWIwXFVCN4TpZb6DiqZvxIp9QgoteZmv2ObNGANiJgCHO3aFKu26QrMLt)T2jmGo8xt0UXtlvT76uUJeX2ny7oSu(WA39jj9j7LR12AFj2U6L0PPsx5EFfidXRCtIM9Mxuls2mXWvNkpuXq8KTvpmsUpADUUN0nx36tBVlysCmQx6QAbmeyJYSeoNKAJBBHKNoyyDjVbzQuTvQKQIfN0H0sPmnLAQVrcTs3DlMCTAvRknLQ1CZcnPplM5BFXetYcE8C23vdT7MxTVqv12zrJgsLAEuw7gth)DYfuw9nSsS3DcF(CmxBOnH6At(LVjHSZ15lG9nnVLAZvJIZ65Q0HKaNsKeyEln5opSjjXAP4HdsuiR5JNLyttndhHSyavgvJYCJxV1KZiIbAxQnf54AUnb)gFNcYMZAFnyYgzgN082iCP7KqH0QUbN52OO7BaMKNpTFjWkwZsSAThmrJI)IO0tEtDYuml32THnTws4pu1Gsl8vHGzQGYETNKQLlvZAKf7VKKgPHVrtckLxz7jkXHnJXOSWwMSntuh4WDYMxiphPUsRLWLGq0ZVGDuP3uLMC3HqauXz02)kUoV5wH(VuolURBd7wTkOtBNcQLZvh0r)NpVaQ8zBgZvHjBZe1bo8VD8cu5cq9ZJyw1KsBOS62)wDZZuQw1Qojv5ZNA3bnSne9e3wrtB2)28)1fXQa9Lv3AH)Obs0iX273ZeaAiZU05cPDqxCJiKfksBDUM9pug62Uxy0cdz2qdIkHwd9oPTGvDRGL8vD9Kb2PMKvIMnuxp7uLm06B6TsIQtZ9TM31tBtbLDwwkKhyUPVgBF2)8SLxux4a7n3OB9FnMMbXQH(732UTtFCmAZofmUf7uWKw0JZPw3JZrZSUhNYh)QwEKuUYPbHIiLG2npOVLDOZeb2Lo71eBRXER9g2yn9n8QJ5JOlswRZ8QlUyOBqhFAeo1igJOBSLr2CLDODi0Hme0DOE6uCVw6FSLbMme2WoVJM2Ay5cJ)XM6rhfXCislCEBBP4kEhVCpxe(Gi)IeyVBb5y0ne3L2hIQkZuY4Zjg3q83WGOFddf2e9FvIMrPtyDgpz)3I)V]] )


end
