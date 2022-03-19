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

    spec:RegisterResource( Enum.PowerType.HolyPower, {
        divine_resonance = {
            aura = "divine_resonance",

            last = function ()
                local app = state.buff.divine_resonance.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 5 ) * 5
            end,

            interval = 5,
            value = 1,
        },
    } )
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


    spec:RegisterPack( "Retribution", 20220319, [[dKKolcqib4rssWMiIpHQQrHu5uiLwLKKEfOIzbKCluvQSlc)ci1WKK6yejlJi1ZqvX0acUgOsBdiuFdPOACif5Css06qk08eOUhOSpGYbLKqTqGOhIuWervPQlces9rGq4KiffRePQzIQsUjqizNsc)eiezOaHOwksrPNsLMQKOVkjHmwbK9kXFfAWQ6WIwSGEmjtMQUm0Mb5ZuXOb40QSAbuVgOA2K62e1UP8BfdxsDCuvklhXZrz6kDDKSDuLVdOXlqopOQ5Jk7xQlsvQS46ZflviD1slD18rQQuifnhU0K0sxCx4RXIBDQapDWIRLYyXLMfxYfsT3yf36eE9K(sLfx2qruyXT4gsD6LMXkHfxFUyPcPRwAPRMpsvLcPO5WLMKU4YQrvPcAE1fxaN3JwjS46rMQ4sZIl5cP2BS(bro1P)SMEqujrbOFPQsq1V0vlT0n9n90aG0Cqgn20Z31pnJTOdjxSFdb2Fn5gYTW3pRwFB)qKrUF3tMgen98D9dIkbh73fjznGtUFGdb8(dXDrs)aVfq)Zcaj9td89S(3XXrJ((hiirtpFx)89JX)2pWKTy)YO)OKbTojoy)0aFpR)X63d)zo9xNkWz9tzAKX6)w(z9N9homw)qNdGv00Z31piQHG9N(atXwz0ww)70pWHaE)aVfq)0aFpRFgGbO1pdRtsUOgErXTMmqNglUvHQq)0S4sUqQ9gRFqKtD6pRPVkuf6hevsua6xQQeu9lD1slDtFtFvOk0pnainhKrJn9vHQq)8D9tZyl6qYf73qG9xtUHCl89ZQ132pezK739KPbrtFvOk0pFx)GOsWX(Drswd4K7h4qaV)qCxK0pWBb0)Saqs)0aFpR)DCC0OV)bcs00xfQc9Z31pF)y8V9dmzl2Vm6pkzqRtId2pnW3Z6FS(9WFMt)1PcCw)uMgzS(VLFw)z)HdJ1p05ayfn9vHQq)8D9dIAiy)PpWuSvgTL1)o9dCiG3pWBb0pnW3Z6NbyaA9ZW6KKlQHx0030NQ9gJjQjOAKdZfw9S3yn9PAVXyIAcQg5WCHdmqhQrg7mN4afzuYYiPPpv7ngtutq1ihMlCGb6qnYyN5ehOysTuYwtFQ2BmMOMGQromx4ad0HAKXoZjoqrGNTiPPpv7ngtutq1ihMlCGb6qnYyN5ehOiRMCMttFQ2BmMOMGQromx4ad0qAKbqrsOfuhem2qPdpZlQPylLgJiHQEVX44ydLo8mVG3OZ90yKnAEOTn9PAVXyIAcQg5WCHdmqNevAyChcbTfuheSn1OTcOZsDKGkWh7mhbAzOg9s2uJ2kyijRbCYc0Yqn6B6t1EJXe1eunYH5chyGMb4qTpoqrEO5GPPWM(M(QqvOFq0bHkQf99J8qc89VNm2)ca7pv7q6)y9N8YtNHAu00NQ9gJbJGHuGJn9PAVXyWbgO5LKld1iOSugHbrIem9WdkEPMcHrhGrdFSEaIeWGbcs2tgdMM44amA4J1dqKagm(iHU9KrWGrtCCSAuRJBsCWLj8hVZWiBhImyWKwIA4HwARaC4jxA0sRe1mA)a0ejp0CoZjcKKlabbLZZyG5O8s2tgJ7ebu7aRAj0fWMA0wbdjznGtMJlKccsWqswd4Kfu10kHUai55Jip0wr69mbg0XwghhjpFe5H2ksVNjOQ54i55Jip0wr69mXzGbcvtRe6ciKccsK8qZ5mNiqsUaeu1CCagn8X6bisGbxoo1mA)a0easzzKehOiqsUaeeuopJXXXQrToUjXbxMWF8odJSDiYGbtAjQHhAPTcWHNCPrBtFQ2BmgCGbAEj5YqncklLryilsW0dpO4LAkegDHuqqcfHILEu4hGMe1mA)a0ekcfl9OGGY5zmWKQAoUqkiiHIqXspkyBQahmy8HJtnJ2panrYdnNZCIaj5cqqq58mgysvnTsOlGn1OTcOZsDKGkWh7mhoo1mA)a0eqNL6ibvGp2zocckNNXatQQ54amA4J1dqKi8i0PUfw1ss1EJjGol1rcQaFSZCe(JLHA0tReOZbWgjOCEgdmAscRg164MehCzc)X7mmY2HihmCB6t1EJXGdmqRsToMQ9glQp2cklLryQz0(bOXA6t1EJXGdmqRsToMQ9glQp2cklLryilcrI1ZOpZbuhem6cGKNpI8qBfP3ZeyqhBzCCK88rKhARi9EMGQMJJKNpI8qBfP3ZeNfCvYXrYZhrEOTI07zIZaJpvtRe62uJ2kWGqf1EJfzOTOPqjQz0(bOjWGqf1EJfzOTOPqbbLZZybxLsy1Owh3K4Glt4pENHr2oe5GHlh3MA0wb0zPosqf4JDMJe1mA)a0eqNL6ibvGp2zocckNNXcUkPvc05ayJeuopJbgn10NQ9gJbhyGwLADmv7nwuFSfuwkJWqweIet1E8qqXwYPwysbQdcMhdPGGeyqOIAVXIm0w0uOGQMJZJHuqqcOZsDKGkWh7mhbvDtFQ2BmgCGbAvQ1XuT3yr9XwqzPmcZbnKK7qyn9n9PAVXyc1mA)a0yWQN9gduheSqkiirYdnNZCIaj5cqqvZXfsbbjuekw6rbvTKqkiiHIqXspkyBQahMuvZXfomMeOZbWgjOCEglyPHBtFQ2BmMqnJ2pangCGbA95ayzXat5DKrBb1bbJvJADCtIdUmH(CaSSyGP8oYOTGbtAoUai55Jip0wr69mbg0XwghhjpFe5H2ksVNjodmAoC54i55Jip0wr69mbvDtFQ2BmMqnJ2pangCGbAOJGH6z8G6GGrxifeKi5HMZzorGKCbiOQ54cPGGekcfl9OGQwsifeKqrOyPhfSnvGdtQQPvsaBQrBfyqOIAVXIm0w0uytFQ2BmMqnJ2pangCGbAinYaOij0cQdcgBO0HN5f1uSLsJrKqvV3yCCSHshEMxWB05EAmYgnp0wqD2Iecv9gpzz0F5IWKcuNTiHqvVrh9eMAysbQZwKqOQ34bbJnu6WZ8cEJo3tJr2O5H220NQ9gJjuZO9dqJbhyGMb4qTpoqrEO5GPPqqDqWOlGn1OTcmiurT3yrgAlAkKJtnJ2panbgeQO2BSidTfnfkiOCEgly4knTsGohaBKGY5zmWKcUn9PAVXyc1mA)a0yWbgOd1iJDMtCGImkzzK00NQ9gJjuZO9dqJbhyGouJm2zoXbkMulLS10NQ9gJjuZO9dqJbhyGouJm2zoXbkc8Sfjn9PAVXyc1mA)a0yWbgOd1iJDMtCGISAYzon9PAVXyc1mA)a0yWbgOPyy8wuguwkJWoJPiuBgQXiFJkTLso6rENcb1bblKccsK8qZ5mNiqsUaeu1CCHuqqcfHILEuqvljKccsOiuS0Jc2MkWHjv1CCHdJjb6CaSrckNNXcMpv30NQ9gJjuZO9dqJbhyGMIHXBrzqzPmcB4HeGaqT8zoX6bisIkc8Sn1G6GGfsbbjsEO5CMteijxacQAoUqkiiHIqXspkOQLesbbjuekw6rbBtf4WKQAoUWHXKaDoa2ibLZZyblfCB6t1EJXeQz0(bOXGdmqtXW4TOmOSugH5tc4YZyrpQapYBiP6w4b1bblKccsK8qZ5mNiqsUaeu1CCHuqqcfHILEuqvljKccsOiuS0Jc2MkWHjv1CCHdJjb6CaSrckNNXcw6QB6t1EJXeQz0(bOXGdmqtXW4TOmOSugHjNQmKGrgae3Omf7uG6GGfsbbjsEO5CMteijxacQAoUqkiiHIqXspkOQLesbbjuekw6rbBtf4WKQAoUWHXKaDoa2ibLZZyblD1n9PAVXyc1mA)a0yWbgOPyy8wuguwkJWGsk9cFunu2IezmzueeuheSa2uJ2kuekw6roUqkiiHIqXspkOQ54chgtc05ayJeuopJfmFQUPpv7ngtOMr7hGgdoWanfdJ3IYGYszeMNGPh6iyKhYyOUPpv7ngtOMr7hGgdoWanfdJ3IYGYszegdCkn4iHfbEMttFQ2BmMqnJ2pangCGbAkggVfLbLLYimhYjhvJhdQPpv7ngtOMr7hGgdoWanfdJ3IYGYszeMmkpe4JduSozBKDgRPpv7ngtOMr7hGgdoWanfdJ3IYGYszegRojyugZncygWB6t1EJXeQz0(bOXGdmqtXW4TOmOSugHXsnV0b9rik2nwmLR1h0HKM(uT3ymHAgTFaAm4ad0ummElkdklLryoxABCiwkJ2M6ynMeDtFQ2BmMqnJ2pangCGbAkggVfLbLLYimGN5zQKebcax2og20NQ9gJjuZO9dqJbhyGMIHXBrzqzPmcJPscloqrisUiXsDKTKdcB6t1EJXeQz0(bOXGdmqtXW4TOmOSugHPaKNXIdu0pYNL7nwtFQ2BmMqnJ2pangCGbAkggVfLbLLYimmjlGqcMGJew8KRt120NQ9gJjuZO9dqJbhyGMIHXBrzqzPmcdaMKnoqXfagzatImOoiybesbbjsEO5CMteijxacQAjHuqqcfHILEuqv30NQ9gJjuZO9dqJbhyGMIHXBrzqzPmcZrN(l3HWIHP3bb1bblKccsK8qZ5mNiqsUaeu1CCHuqqcfHILEuqvljKccsOiuS0Jc2MkWbdMuvZXPMr7hGMi5HMZzorGKCbiiOCEgdmqaUCCQz0(bOjuekw6rbbLZZyGbcWTPpv7ngtOMr7hGgdoWanfdJ3IYmqDqWcPGGejp0CoZjcKKlabvnhxifeKqrOyPhfu1scPGGekcfl9OGTPcCWGjv1n9PAVXyc1mA)a0yWbgOtEO5CMteijxaG6GGrhGrdFSEaIeWGbcs2tgdgUCCagn8X6bisadgFKq3EYiyWLJJqzi0qCqXcaJYPZXwsUilgykVJmAlTCCagn8X6bisadM0siugcnehuWlnhQK4zr5rgTLswYMA0wb0zPosqf4JDMdh3MA0wbGrdFm5HMdsKOMr7hGMaWOHpM8qZbjcckNNXGvnTsOlGn1OTcgsYAaNmhxaBQrBfqNL6ibvGp2zoCCQz0(bOjyijRbCYcckNNXaRAAB6t1EJXeQz0(bOXGdmqRiuS0JG6GGby0WhRhGibmyGGK9KXGHlhhGrdFSEaIeWGXhj7jJGb3M(uT3ymHAgTFaAm4ad0jdaAraPwpaB6t1EJXeQz0(bOXGdmqdy0WhtEO5GeqDqW2tgJ7ebu7aRAjagn8X6biscgM0sOlKccsK8qZ5mNiqsUaeu1CCBQrBfkcfl9Oe6uZO9dqtOiuS0JcckNNXGvnhxifeKqrOyPhfu10YXfomMeOZbWgjOCEglyPRM2M(uT3ymHAgTFaAm4ad0qNL6ibvGp2zoG6GGrhGrdFSEaIeWGbcs2tgdMM44amA4J1dqKagm(iHU9KrWGrtCCSAuRJBsCWLj8hVZWiBhImyWKwIA4HwARaC4jxA0sRe1mA)a0ejp0CoZjcKKlabbLZZyG5O8s2tgJ7ebu7aRAj0fWMA0wbdjznGtMJlKccsWqswd4Kfu10kHUai55Jip0wr69mbg0XwghhjpFe5H2ksVNjOQ54i55Jip0wr69mXzGbcvtRe6ciKccsK8qZ5mNiqsUaeu1CCagn8X6bisGbxoo1mA)a0easzzKehOiqsUaeeuopJXXXQrToUjXbxMWF8odJSDiYGbtAjQHhAPTcWHNCPrBtFtFQ2BmMazrismv7XdHbDemupJVPpv7ngtGSiejMQ94HWbgOvPwht1EJf1hBbLLYimOZogaKWa1bbdWOHpwparcm4YX5XqkiirGP8oYOTcQAoopgsbbjGol1rcQaFSZCeu1sOZJHuqqcOZsDKGkWh7mhbbLZZyb7O8c5mioownQ1Xnjo4Ye(J3zyKTdrgmysljGn1OTcmiurT3yrgAlAkKwoopgsbbjWGqf1EJfzOTOPqbvTepgsbbjWGqf1EJfzOTOPqbbLZZyb7O8c5mOM(uT3ymbYIqKyQ2JhchyG2F8odJ7O1n9PAVXycKfHiXuThpeoWanV04BuhdasyraPSmsA6t1EJXeilcrIPApEiCGbAGj4yCGIjdaYa1bbdWOHpwparsWWKwcDEmKccsaDwQJeub(yN5iOQL4Xqkiib0zPosqf4JDMJGGY5zSGDu(QkTKaiugcnehu4pENHrcYglnfYX5XqkiibgeQO2BSidTfnfkOQL4XqkiibgeQO2BSidTfnfkiOCEglyhLNJJvJADCtIdUmH)4Dggz7qKbdgCLqOmeAioOWF8odJeKnwAkuYMA0wbgeQO2BSidTfnfsBtFQ2BmMazrismv7XdHdmqhQtpghOyGPy7PqqDqWuJ5PUvGbvtrCY9gtcDbqOmeAioOWF8odJeKnwAkucGrdFSEaIKGHXhooaJg(y9aejbdtAAB6t1EJXeilcrIPApEiCGb6at5DKrBb1bblapgsbbjcmL3rgTvqvlHoaJg(y9aejGbtkjekdHgIdkwayuoDo2sYfzXat5DKrB54amA4J1dqKagmPPTPpv7ngtGSiejMQ94HWbgOvPwht1EJf1hBbLLYimOZogaKWA6t1EJXeilcrIPApEiCGbAGj4yCGIjdaYa1bbdWOHpwparsWWKUPpv7ngtGSiejMQ94HWbgOd1PhJdumWuS9uiOoiyagn8X6biscggFA6t1EJXeilcrIPApEiCGb6at5DKrBb1bblapgsbbjcmL3rgTvqv30NQ9gJjqweIet1E8q4ad0aszzKehOiqsUaA6t1EJXeilcrIPApEiCGbAfHILEKezl5ahB6t1EJXeilcrIPApEiCGb6KOsdJ7qiOTn9PAVXycKfHiXuThpeoWaTAmgQi5EJ1030NQ9gJjqweIeRNrFMdmgsYAaNmOoiyagn8X6bisGbxj0fWMA0wb0zPosqf4JDMdhNAgTFaAcOZsDKGkWh7mhbbLZZybdZr5RkF44uZO9dqtaDwQJeub(yN5iiOCEgdm1mA)a0OvcDbSPgTvGbHkQ9glYqBrtHCCQz0(bOjWGqf1EJfzOTOPqbbLZZybdZr5RkF44uZO9dqtGbHkQ9glYqBrtHcckNNXatnJ2panoUn1OTcOZsDKGkWh7mhALqxaQHhAPTcWHNCPXXPMr7hGMWF8odJ7O1cckNNXcUk54uZO9dqt4pENHXD0AbbLZZyGPMr7hGgTn9PAVXycKfHiX6z0N5ahyGwLADmv7nwuFSfuwkJWGo7yaqcduhemaJg(y9aejWGlhNhdPGGeqNL6ibvGp2zocQAoUqkiiHIqXspkOQLesbbjuekw6rbBtf4blv1n9PAVXycKfHiX6z0N5ahyGMxA8nQJbajSiGuwgjG6GGfsbbjyijRbCYcQ6M(uT3ymbYIqKy9m6ZCGdmqdiLLrsCGIaj5cauhemcLHqdXbf8sZHkjEwuEKrBPKB6t1EJXeilcrI1ZOpZboWanWeCmoqXKbazG6GGby0WhRhGijyyslHHBmCmkMypKinnfbHAvtFQ2BmMazrisSEg9zoWbgOd1PhJdumWuS9uiOoiyagn8X6biscggFA6t1EJXeilcrI1ZOpZboWaDGP8oYOTG6GGfGhdPGGebMY7iJ2kOQB6t1EJXeilcrI1ZOpZboWanGuwgjXbkcKKlGM(uT3ymbYIqKy9m6ZCGdmqRiuS0JKiBjh4iOoiyQz0(bOjuekw6rsKTKdCuOaKehKfHiPAVXsnyWKsqZHRe6amA4J1dqKemmP54amA4J1dqKemm(irnJ2panrOo9yCGIbMITNcfeuopJbMJYxvP54amA4J1dqKadeKOMr7hGMiuNEmoqXatX2tHcckNNXaZr5RQ0suZO9dqteykVJmARGGY5zmWCu(QknTn9PAVXycKfHiX6z0N5ahyGMHKSgWjdQdcwaBQrBfqNL6ibvGp2zosuZO9dqtGbHkQ9glYqBrtHcckNNXcgMJYxv(iHUaudp0sBfGdp5sJJtnJ2panH)4Dgg3rRfeuopJfCvsBtFQ2BmMazrisSEg9zoWbgOvPwht1EJf1hBbLLYimOZogaKWA6t1EJXeilcrI1ZOpZboWaTIqXspsISLCGJn9PAVXycKfHiX6z0N5ahyGojQ0W4oecAlOoiyagn8X6biscggi00NQ9gJjqweIeRNrFMdCGbAgsYAaNmOoiy0fWMA0wb0zPosqf4JDMdhNAgTFaAcOZsDKGkWh7mhbbLZZybdZr5RkFOvcDbSPgTvGbHkQ9glYqBrtHCCQz0(bOjWGqf1EJfzOTOPqbbLZZybdZr5RkF442uJ2kGol1rcQaFSZCOvcDbOgEOL2kahEYLghNAgTFaAc)X7mmUJwliOCEgl4QK2M(uT3ymbYIqKy9m6ZCGdmqRgJHksU3yn9n9PAVXycOZogaKWGXljxgQrqzPmcZZIQKTzOgbfVutHWy1Owh3K4Glt4pENHr2oezyslja6iugcnehuaDwQJ8qI)ulh3MA0wb5CaS4qXI8qI)ulTCCSAuRJBsCWLj8hVZWiBhImysZXfsbbjq5A4jyAX6biseu1scWJHuqqIat5DKrBfu1sciKccs4pENHXAks9WqbvDtFQ2BmMa6SJbajm4ad0mKK1aozqDqWOtnJ2panrYdnNZCIaj5cqqq58mgysbxoo1mA)a0ekcfl9OGGY5zmWKcU0kHUa2uJ2kGol1rcQaFSZC44uZO9dqtaDwQJeub(yN5iiOCEgdm1mA)a0OvcDbSPgTvGbHkQ9glYqBrtHCCQz0(bOjWGqf1EJfzOTOPqbbLZZyGPMr7hGghhRg164MehCzc)X7mmY2Hidgm4sRe6cGKNpI8qBfP3ZeyqhBzCCK88rKhARi9EM4mWaHQ54i55Jip0wr69mXzb7O8CCK88rKhARi9EMGQMwj0fGA4HwARaC4jxACC0PMr7hGMWF8odJ7O1cckNNXcUk54uZO9dqt4pENHXD0AbbLZZyGPMr7hGgT0YXbDoa2ibLZZyblfCLaDoa2ibLZZyGbxoUqkiiHIqXspkOQLesbbjuekw6rbBtf4blv1n9PAVXycOZogaKWGdmqJbHkQ9glYqBrtHG6GGrxifeKqrOyPhf(bOjrnJ2panHIqXspkiOCEgdmPQMJlKccsOiuS0Jc2MkWbdgF44uZO9dqtK8qZ5mNiqsUaeeuopJbMuvtRe6cytnARa6SuhjOc8XoZHJtnJ2panb0zPosqf4JDMJGGY5zmWKQAooaJg(y9aejcpcDQBHvTe6cGxsUmuJcisKGPhEoUuT3ycOZsDKGkWh7mhH)yzOg90sReOZbWgjOCEgdmAscRg164MehCzc)X7mmY2HihmCB6t1EJXeqNDmaiHbhyG2F8odJSDiYG6GGXljxgQrHNfvjBZqnkjGqkiibV04BuhdasyraPSmseu1sOJUa2uJ2kuekw6roo1mA)a0ekcfl9OGGY5zmWCu(QYhALqxaBQrBfyqOIAVXIm0w0uihNAgTFaAcmiurT3yrgAlAkuqq58mgyokFvbXCCQz0(bOjWGqf1EJfzOTOPqbbLZZyG5O8vfeKay0WhRhGibmyWLJJvJADCtIdUmH)4Dggz7qKbdgC54cytnARGHKSgWjlrnJ2panbgeQO2BSidTfnfkiOCEgdmhLVQsZXby0WhRhGir4rOtDlSQLqxa8sYLHAuGSibtp8CCPAVXeyqOIAVXIm0w0uOWFSmuJEAPvcDbSPgTvaDwQJeub(yN5WXPMr7hGMa6SuhjOc8XoZrqq58mgyokFvbXCCQz0(bOjGol1rcQaFSZCeeuopJbMJYxvqqcGrdFSEaIeWGbxoUa2uJ2kyijRbCYsuZO9dqtaDwQJeub(yN5iiOCEgdmhLVQsZXby0WhRhGir4rOtDlSQLqxa8sYLHAuarIem9WZXLQ9gtaDwQJeub(yN5i8hld1ONwA542uJ2kamA4Jjp0CqIe1mA)a0eagn8XKhAoirqq58mwWokFv5dhxifeKaWOHpM8qZbjcQAoUqkiiHIqXspkOQLesbbjuekw6rbBtf4blv1CCqNdGnsq58mwW0eTn9PAVXycOZogaKWGdmqVOCTojSipK4p1cQdcgDbSPgTvOiuS0JCCQz0(bOjuekw6rbbLZZyG5O8vLp0kHUa2uJ2kWGqf1EJfzOTOPqoo1mA)a0eyqOIAVXIm0w0uOGGY5zmWCu(QstCCQz0(bOjWGqf1EJfzOTOPqbbLZZyG5O8vfelbWOHpwparcyWaboUa2uJ2kyijRbCYsuZO9dqtGbHkQ9glYqBrtHcckNNXaZr5RQ0CCagn8X6biseEe6u3cRAj0faVKCzOgfilsW0dphxQ2BmbgeQO2BSidTfnfk8hld1ONwALqxaBQrBfqNL6ibvGp2zoCCQz0(bOjGol1rcQaFSZCeeuopJbMJYxvAIJtnJ2panb0zPosqf4JDMJGGY5zmWCu(QcILay0WhRhGibmyGahxaBQrBfmKK1aozjQz0(bOjGol1rcQaFSZCeeuopJbMJYxvP54amA4J1dqKi8i0PUfw1sOlaEj5YqnkGircME454s1EJjGol1rcQaFSZCe(JLHA0tlTCCBQrBfagn8XKhAoirIAgTFaAcaJg(yYdnhKiiOCEglyhLVQ8HJlKccsay0WhtEO5GebvnhxifeKqrOyPhfu1scPGGekcfl9OGTPc8GLQAooOZbWgjOCEglyAQPVPpv7ngt4GgsYDimyQuRJPAVXI6JTGYszeg0zhdasyG6GGby0WhRhGibgC54OZJHuqqIat5DKrBfu1CCagn8X6bisGbc0kjKccs4pENHrcYglnfkOQ54cPGGeagn8XKhAoirqv30NQ9gJjCqdj5oegCGbAEPX3OogaKWIaszzKaQdcwaekdHgIdk8ul8HdL5JojpuZXfWMA0wb0zPosqf4JDMJKa2uJ2kWGqf1EJfzOTOPqoUWHXKaDoa2ibLZZybttn9PAVXych0qsUdHbhyGgqklJK4afbsYfaOoiyekdHgIdkwayuo9X6KKoJXXPgEOL2k4H2caEIe1mA)a0ejdaAraPwpafeuopJbM0svDtFQ2BmMWbnKK7qyWbgObMGJXbkMmaiduhemaJg(y9aejbdtAjmCJHJrXe7HePPPiiuRKqNAgTFaAIKhAoN5ebsYfGGGY5zmoo1mA)a0ekcfl9OGGY5zmAB6t1EJXeoOHKChcdoWaT)4Dgg3rRb1bbdWOHpwparsWWKssaEmKccseykVJmARGQwcDbSPgTvWqswd4K54cPGGemKK1aozbvnTsOlasE(iYdTvKEptGbDSLXXrYZhrEOTI07zIZaJpvZXrYZhrEOTI07zcQAALqxaBQrBfqNL6ibvGp2zoCCEmKccsaDwQJeub(yN5iOQ54uZO9dqtaDwQJeub(yN5iiOCEgdmPRMwj0fWMA0wbgeQO2BSidTfnfYXbDoa2ibLZZybttCCSAuRJBsCWLj8hVZWiBhImyWGlTsOtnJ2panrYdnNZCIaj5cqqq58mghNAgTFaAcfHILEuqq58mgTn9PAVXych0qsUdHbhyGoWuEhz0wqDqWcWJHuqqIat5DKrBfu1sOdWOHpwparcyWKscHYqOH4GIfagLtNJTKCrwmWuEhz0wooaJg(y9aejGbtAAB6t1EJXeoOHKChcdoWanWeCmoqXKbazG6GGrhGrdFSEaIeyvZXby0WhRhGijyyslrnJ2panrOo9yCGIbMITNcfeuopJbMJYxvPPvcDbqYZhrEOTI07zcmOJTmoosE(iYdTvKEptCgysxnhhjpFe5H2ksVNjOQPvcDbSPgTvWqswd4K54uZO9dqtWqswd4KfeuopJbgC54udp0sBfGdp5sJwj0fWMA0wbgeQO2BSidTfnfYXPMr7hGMadcvu7nwKH2IMcfeuopJbMuWLJd6CaSrckNNXcMM44y1Owh3K4Glt4pENHr2oezWGbxALqxaBQrBfqNL6ibvGp2zoCCQz0(bOjGol1rcQaFSZCeeuopJbMuWLJd6CaSrckNNXcMMOvcDQz0(bOjsEO5CMteijxacckNNX44uZO9dqtOiuS0JcckNNXOTPpv7ngt4GgsYDim4ad0QuRJPAVXI6JTGYszeg0zhdasyG6GGby0WhRhGibmy8rsifeKqrOyPhfu1scPGGekcfl9OGTPc8GLQ6M(uT3ymHdAij3HWGdmqhQtpghOyGPy7PqqDqWuJ5PUvGbvtrCY9gtcGrdFSEaIKGHXNM(uT3ymHdAij3HWGdmqhykVJmAlOoiyb4XqkiirGP8oYOTcQ6M(uT3ymHdAij3HWGdmqdiLLrsCGIaj5cOPpv7ngt4GgsYDim4ad0H60JXbkgyk2EkeuhemaJg(y9aejbdJpn9PAVXych0qsUdHbhyGwLADmv7nwuFSfuwkJWGo7yaqcduhem62K4GRaaM6fGOwTbdt6Q54cPGGejp0CoZjcKKlabvnhxifeKqrOyPhfu1CCHuqqcuUgEcMwSEaIebvnTn9PAVXych0qsUdHbhyGwngdvKCVXa1bbla1ymurY9gtqvlHvJADCtIdUmH)4Dggz7qKbdM0n9PAVXych0qsUdHbhyGwrOyPhjr2soWrqDqWuZO9dqtOiuS0JKiBjh4Oqbijoilcrs1EJLAWGjLGMdxj0by0WhRhGijyysZXby0WhRhGijyy8rIAgTFaAIqD6X4afdmfBpfkiOCEgdmhLVQsZXby0WhRhGibgiirnJ2panrOo9yCGIbMITNcfeuopJbMJYxvPLOMr7hGMiWuEhz0wbbLZZyG5O8vvAAB6t1EJXeoOHKChcdoWaTk16yQ2BSO(ylOSugHbD2XaGewtFQ2BmMWbnKK7qyWbgOvJXqfj3BmqDqWcqngdvKCVXeu1n9PAVXych0qsUdHbhyGwrOyPhjr2soWXM(uT3ymHdAij3HWGdmqNevAyChcbTTPpv7ngt4GgsYDim4ad0QXyOIK7nwXLhsy3yLkKUAPLUA(ivvwCbMe7mhwXTkQkMMTcAMkarqJ93FLaW(p56HS9dnK(53bnKK7qy83pb5Buhb99ZgzS)KAh5CrF)kaP5GmrtpFDg2V00y)0Wy8qYI((5FtnARiq83)o9Z)MA0wrGeOLHA0ZF)0jDq0kA65RZW(LMg7NggJhsw03p)ekdHgIdkce)9Vt)8tOmeAioOiqc0Yqn65VF6KkiAfn981zy)8Hg7NggJhsw03p)ekdHgIdkce)9Vt)8tOmeAioOiqc0Yqn65VF6KkiAfn981zy)WLg7NggJhsw03p)BQrBfbI)(3PF(3uJ2kcKaTmuJE(7No(eeTIME(6mSFqmn2pnmgpKSOVF(jugcnehuei(7FN(5Nqzi0qCqrGeOLHA0ZF)0jvq0kA65RZW(P50y)0Wy8qYI((5FtnARiq83)o9Z)MA0wrGeOLHA0ZF)0XNGOv0030xfvftZwbntfGiOX(7Vsay)NC9q2(Hgs)87rOKsV83pb5Buhb99ZgzS)KAh5CrF)kaP5GmrtpFDg2V00y)0Wy8qYI((5FtnARiq83)o9Z)MA0wrGeOLHA0ZF)0jvq0kA65RZW(5dn2pnmgpKSOVF(3uJ2kce)9Vt)8VPgTveibAzOg983pDsfeTIME(6mSF4sJ9tdJXdjl67N)n1OTIaXF)70p)BQrBfbsGwgQrp)9tN0brROPVPVkQkMMTcAMkarqJ93FLaW(p56HS9dnK(5VMGQromx(7NG8nQJG((zJm2FsTJCUOVFfG0CqMOPNVod7hetJ9tdJXdjl67NF2qPdpZlce)9Vt)8ZgkD4zErGeOLHA0ZF)0jvq0kA65RZW(bX0y)0Wy8qYI((5Nnu6WZ8IaXF)70p)SHshEMxeibAzOg983FU9dIgej(QF6KkiAfn9n9vrvX0SvqZubicAS)(Rea2)jxpKTFOH0p)Qz0(bOX4VFcY3Ooc67NnYy)j1oY5I((vasZbzIME(6mSF(qJ9tdJXdjl67N)n1OTIaXF)70p)BQrBfbsGwgQrp)9NB)GObrIV6NoPcIwrtpFDg2piqJ9tdJXdjl67NF2qPdpZlce)9Vt)8ZgkD4zErGeOLHA0ZF)0jvq0kA65RZW(bbASFAymEizrF)8ZgkD4zErG4V)D6NF2qPdpZlcKaTmuJE(7p3(brdIeF1pDsfeTIME(6mSF4sJ9tdJXdjl67N)n1OTIaXF)70p)BQrBfbsGwgQrp)9tNubrROPNVod7xkqGg7NggJhsw03p)BQrBfbI)(3PF(3uJ2kcKaTmuJE(7NoPcIwrtpFDg2V0vjn2pnmgpKSOVF(3uJ2kce)9Vt)8VPgTveibAzOg983pDGqq0kA65RZW(LUkPX(PHX4HKf99ZpHYqOH4GIaXF)70p)ekdHgIdkcKaTmuJE(7NoPdIwrtpFDg2pFKMg7NggJhsw03p)BQrBfbI)(3PF(3uJ2kcKaTmuJE(7NoPcIwrtpFDg2pF4dn2pnmgpKSOVF(3uJ2kce)9Vt)8VPgTveibAzOg983pDsfeTIM(M(QOQyA2kOzQaebn2F)vca7)KRhY2p0q6NFOZogaKW4VFcY3Ooc67NnYy)j1oY5I((vasZbzIME(6mSFPOX(PHX4HKf99Z)MA0wrG4V)D6N)n1OTIajqld1ON)(PtQGOv00ZxNH9lfn2pnmgpKSOVF(jugcnehuei(7FN(5Nqzi0qCqrGeOLHA0ZF)0jvq0kA65RZW(LMg7NggJhsw03p)BQrBfbI)(3PF(3uJ2kcKaTmuJE(7NoPdIwrtpFDg2pFOX(PHX4HKf99Z)MA0wrG4V)D6N)n1OTIajqld1ON)(PtQGOv00ZxNH9dc0y)0Wy8qYI((5FtnARiq83)o9Z)MA0wrGeOLHA0ZF)0bIdIwrtpFDg2pCPX(PHX4HKf99Z)MA0wrG4V)D6N)n1OTIajqld1ON)(PdeheTIM(M(QOQyA2kOzQaebn2F)vca7)KRhY2p0q6NFKfHiXuThpK)(jiFJ6iOVF2iJ9Nu7iNl67xbinhKjA65RZW(LMg7NggJhsw03p)BQrBfbI)(3PF(3uJ2kcKaTmuJE(7NoPcIwrtpFDg2pCPX(PHX4HKf99Z)MA0wrG4V)D6N)n1OTIajqld1ON)(PtQGOv00ZxNH9dxASFAymEizrF)8tOmeAioOiq83)o9ZpHYqOH4GIajqld1ON)(Pt6GOv00ZxNH9dIPX(PHX4HKf99ZpHYqOH4GIaXF)70p)ekdHgIdkcKaTmuJE(7NoPcIwrtpFDg2pnNg7NggJhsw03p)ekdHgIdkce)9Vt)8tOmeAioOiqc0Yqn65VF6KkiAfn9n9vrvX0SvqZubicAS)(Rea2)jxpKTFOH0p)ilcrI1ZOpZH)(jiFJ6iOVF2iJ9Nu7iNl67xbinhKjA65RZW(LIg7NggJhsw03p)BQrBfbI)(3PF(3uJ2kcKaTmuJE(7No(eeTIME(6mSFqGg7NggJhsw03p)ekdHgIdkce)9Vt)8tOmeAioOiqc0Yqn65V)C7henis8v)0jvq0kA65RZW(LQAASFAymEizrF)8VPgTvei(7FN(5FtnARiqc0Yqn65VF6KkiAfn981zy)sbc0y)0Wy8qYI((5FtnARiq83)o9Z)MA0wrGeOLHA0ZF)0XNGOv0030tZixpKf99tZ7pv7nw)6JTmrtFXvFSLvQS46GgsYDiSsLLkKQuzXfTmuJ(cilUkYTi5YIlGrdFSEaIK(H1pC7NJRF663JHuqqIat5DKrBfu19ZX1pGrdFSEaIK(H1pi0pT9lP)qkiiH)4DggjiBS0uOGQUFoU(dPGGeagn8XKhAoirqvxCt1EJvCvPwht1EJf1hBlU6JTrlLXIl0zhdasyLTuH0LklUOLHA0xazXvrUfjxwCdOFcLHqdXbfEQf(WHY8rNKhQfOLHA03phx)b0)MA0wb0zPosqf4JDMJaTmuJ((L0Fa9VPgTvGbHkQ9glYqBrtHc0Yqn67NJR)WHX6xs)qNdGnsq58mw)b3pnvCt1EJvC5LgFJ6yaqclciLLrszlvWNsLfx0Yqn6lGS4Qi3IKllUekdHgIdkwayuo9X6KKoJjqld1OVFoU(vdp0sBf8qBbapPFj9RMr7hGMizaqlci16bOGGY5zS(bRFPLQ6IBQ2BSIlGuwgjXbkcKKlGYwQaekvwCrld1OVaYIRIClsUS4cy0WhRhGiP)GH1V09lPFgUXWXOyI9qI00ueeQv9lPF66xnJ2panrYdnNZCIaj5cqqq58mw)CC9RMr7hGMqrOyPhfeuopJ1pTf3uT3yfxGj4yCGIjdaYkBPc4wQS4IwgQrFbKfxf5wKCzXfWOHpwpars)bdRFP6xs)b0VhdPGGebMY7iJ2kOQ7xs)01Fa9VPgTvWqswd4KfOLHA03phx)HuqqcgsYAaNSGQUFA7xs)01Fa9tYZhrEOTI07zcmOJTS(546NKNpI8qBfP3ZeN1py9ZNQ7NJRFsE(iYdTvKEptqv3pT9lPF66pG(3uJ2kGol1rcQaFSZCeOLHA03phx)EmKccsaDwQJeub(yN5iOQ7NJRF1mA)a0eqNL6ibvGp2zocckNNX6hS(LU6(PTFj9tx)b0)MA0wbgeQO2BSidTfnfkqld1OVFoU(HohaBKGY5zS(dUFAQFoU(z1Owh3K4Glt4pENHr2oe5(bdw)WTFA7xs)01VAgTFaAIKhAoN5ebsYfGGGY5zS(546xnJ2panHIqXspkiOCEgRFAlUPAVXkU(J3zyChTUSLkaXLklUOLHA0xazXvrUfjxwCdOFpgsbbjcmL3rgTvqv3VK(PRFaJg(y9aej9dgS(LQFj9tOmeAioOybGr505yljxKfdmL3rgTvGwgQrF)CC9dy0WhRhGiPFWG1V09tBXnv7nwXnWuEhz02YwQGMxQS4IwgQrFbKfxf5wKCzXLU(bmA4J1dqK0pS(RUFoU(bmA4J1dqK0FWW6x6(L0VAgTFaAIqD6X4afdmfBpfkiOCEgRFW63r57VQ9lD)02VK(PR)a6NKNpI8qBfP3ZeyqhBz9ZX1pjpFe5H2ksVNjoRFW6x6Q7NJRFsE(iYdTvKEptqv3pT9lPF66pG(3uJ2kyijRbCYc0Yqn67NJRF1mA)a0emKK1aozbbLZZy9dw)WTFoU(vdp0sBfGdp5sRFA7xs)01Fa9VPgTvGbHkQ9glYqBrtHc0Yqn67NJRF1mA)a0eyqOIAVXIm0w0uOGGY5zS(bRFPGB)CC9dDoa2ibLZZy9hC)0u)CC9ZQrToUjXbxMWF8odJSDiY9dgS(HB)02VK(PR)a6FtnARa6SuhjOc8XoZrGwgQrF)CC9RMr7hGMa6SuhjOc8XoZrqq58mw)G1VuWTFoU(HohaBKGY5zS(dUFAQFA7xs)01VAgTFaAIKhAoN5ebsYfGGGY5zS(546xnJ2panHIqXspkiOCEgRFAlUPAVXkUatWX4aftgaKv2sf0uPYIlAzOg9fqwCvKBrYLfxaJg(y9aej9dgS(5t)s6pKccsOiuS0JcQ6(L0FifeKqrOyPhfSnvG3FW9lv1f3uT3yfxvQ1XuT3yr9X2IR(yB0szS4cD2XaGewzlvuLLklUOLHA0xazXvrUfjxwCvJ5PUvGbvtrCY9gRFj9dy0WhRhGiP)GH1pFkUPAVXkUH60JXbkgyk2EkSSLkKQ6sLfx0Yqn6lGS4Qi3IKllUb0VhdPGGebMY7iJ2kOQlUPAVXkUbMY7iJ2w2sfsjvPYIBQ2BSIlGuwgjXbkcKKlGIlAzOg9fqw2sfsjDPYIlAzOg9fqwCvKBrYLfxaJg(y9aej9hmS(5tXnv7nwXnuNEmoqXatX2tHLTuHu8PuzXfTmuJ(cilUkYTi5YIlD9VjXbxbam1larTA7pyy9lD19ZX1FifeKi5HMZzorGKCbiOQ7NJR)qkiiHIqXspkOQ7NJR)qkiibkxdpbtlwparIGQUFAlUPAVXkUQuRJPAVXI6JTfx9X2OLYyXf6SJbajSYwQqkqOuzXfTmuJ(cilUkYTi5YIBa9RgJHksU3ycQ6(L0pRg164MehCzc)X7mmY2Hi3pyW6x6IBQ2BSIRAmgQi5EJv2sfsb3sLfx0Yqn6lGS4Qi3IKllUQz0(bOjuekw6rsKTKdCuOaKehKfHiPAVXsD)GbRFPe0C42VK(PRFaJg(y9aej9hmS(LUFoU(bmA4J1dqK0FWW6Np9lPF1mA)a0eH60JXbkgyk2Ekuqq58mw)G1VJY3Fv7x6(546hWOHpwpars)W6he6xs)Qz0(bOjc1PhJdumWuS9uOGGY5zS(bRFhLV)Q2V09lPF1mA)a0ebMY7iJ2kiOCEgRFW63r57VQ9lD)0wCt1EJvCvekw6rsKTKdCSSLkKcexQS4IwgQrFbKf3uT3yfxvQ1XuT3yr9X2IR(yB0szS4cD2XaGewzlvifnVuzXfTmuJ(cilUkYTi5YIBa9RgJHksU3ycQ6IBQ2BSIRAmgQi5EJv2sfsrtLklUPAVXkUkcfl9ijYwYbowCrld1OVaYYwQqQQSuzXnv7nwXnjQ0W4oecABXfTmuJ(cilBPcPRUuzXnv7nwXvngdvKCVXkUOLHA0xazzlBX1JqjLElvwQqQsLf3uT3yfxcgsbowCrld1OVaYYwQq6sLfx0Yqn6lGS4o1fxgUf3uT3yfxEj5YqnwC5LAkS4sx)agn8X6bis6hmy9dc9lP)9KX(dUFAQFoU(bmA4J1dqK0pyW6Np9lPF66FpzSFWG1pn1phx)SAuRJBsCWLj8hVZWiBhIC)GbRFP7xs)QHhAPTcWHNCP1pT9tB)s6xnJ2panrYdnNZCIaj5cqqq58mw)G1VJY3VK(3tgJ7ebu70pS(RUFj9tx)b0)MA0wbdjznGtwGwgQrF)CC9hsbbjyijRbCYcQ6(PTFj9tx)b0pjpFe5H2ksVNjWGo2Y6NJRFsE(iYdTvKEptqv3phx)K88rKhARi9EM4S(bRFqO6(PTFj9tx)b0FifeKi5HMZzorGKCbiOQ7NJRFaJg(y9aej9dRF42phx)Qz0(bOjaKYYijoqrGKCbiiOCEgRFoU(z1Owh3K4Glt4pENHr2oe5(bdw)s3VK(vdp0sBfGdp5sRFAlU8ss0szS4crIem9Wx2sf8PuzXfTmuJ(cilUtDXLHBXnv7nwXLxsUmuJfxEPMclU01FifeKqrOyPhf(bO1VK(vZO9dqtOiuS0JcckNNX6hS(LQ6(546pKccsOiuS0Jc2MkW7hmy9ZN(546xnJ2panrYdnNZCIaj5cqqq58mw)G1Vuv3pT9lPF66pG(3uJ2kGol1rcQaFSZCeOLHA03phx)Qz0(bOjGol1rcQaFSZCeeuopJ1py9lv19ZX1pGrdFSEaIeHhHo1T9dR)Q7xs)PAVXeqNL6ibvGp2zoc)XYqn67N2(L0p05ayJeuopJ1py9tt9lPFwnQ1Xnjo4Ye(J3zyKTdrU)G7hUfxEjjAPmwCrwKGPh(YwQaekvwCrld1OVaYIBQ2BSIRk16yQ2BSO(yBXvFSnAPmwCvZO9dqJv2sfWTuzXfTmuJ(cilUkYTi5YIlD9hq)K88rKhARi9EMad6ylRFoU(j55Jip0wr69mbvD)CC9tYZhrEOTI07zIZ6p4(RY(546NKNpI8qBfP3ZeN1py9ZNQ7N2(L0pD9VPgTvGbHkQ9glYqBrtHc0Yqn67xs)Qz0(bOjWGqf1EJfzOTOPqbbLZZy9hC)vz)s6NvJADCtIdUmH)4Dggz7qK7p4(HB)CC9VPgTvaDwQJeub(yN5iqld1OVFj9RMr7hGMa6SuhjOc8XoZrqq58mw)b3Fv2pT9lPFOZbWgjOCEgRFW6NMkUPAVXkUQuRJPAVXI6JTfx9X2OLYyXfzrisSEg9zoLTubiUuzXfTmuJ(cilUkYTi5YIRhdPGGeyqOIAVXIm0w0uOGQUFoU(9yifeKa6SuhjOc8XoZrqvxCzl5uBPcPkUPAVXkUQuRJPAVXI6JTfx9X2OLYyXfzrismv7XdlBPcAEPYIlAzOg9fqwCt1EJvCvPwht1EJf1hBlU6JTrlLXIRdAij3HWkBzlU1eunYH5wQSuHuLklUPAVXkU1ZEJvCrld1OVaYYwQq6sLf3uT3yf3qnYyN5ehOiJswgjfx0Yqn6lGSSLk4tPYIBQ2BSIBOgzSZCIdumPwkzR4IwgQrFbKLTubiuQS4MQ9gR4gQrg7mN4afbE2IKIlAzOg9fqw2sfWTuzXnv7nwXnuJm2zoXbkYQjN5uCrld1OVaYYwQaexQS4IwgQrFbKfxf5wKCzXLnu6WZ8IAk2sPXisOQ3BmbAzOg99ZX1pBO0HN5f8gDUNgJSrZdTvGwgQrFXnv7nwXfsJmakscTLTubnVuzXfTmuJ(cilUkYTi5YI7MA0wb0zPosqf4JDMJaTmuJ((L0)MA0wbdjznGtwGwgQrFXnv7nwXnjQ0W4oecABzlvqtLklUPAVXkUmahQ9XbkYdnhmnfwCrld1OVaYYw2IRAgTFaASsLLkKQuzXfTmuJ(cilUkYTi5YIBifeKi5HMZzorGKCbiOQ7NJR)qkiiHIqXspkOQ7xs)HuqqcfHILEuW2ubE)W6xQQ7NJR)WHX6xs)qNdGnsq58mw)b3V0WT4MQ9gR4wp7nwzlviDPYIlAzOg9fqwCvKBrYLfxwnQ1Xnjo4Ye6ZbWYIbMY7iJ22pyW6x6(546pG(j55Jip0wr69mbg0Xww)CC9tYZhrEOTI07zIZ6hS(P5WTFoU(j55Jip0wr69mbvDXnv7nwXvFoawwmWuEhz02YwQGpLklUOLHA0xazXvrUfjxwCPR)qkiirYdnNZCIaj5cqqv3phx)HuqqcfHILEuqv3VK(dPGGekcfl9OGTPc8(H1Vuv3pT9lP)a6FtnARadcvu7nwKH2IMcfOLHA0xCt1EJvCHocgQNXx2sfGqPYIlAzOg9fqwCvKBrYLfx2qPdpZlQPylLgJiHQEVXeOLHA03phx)SHshEMxWB05EAmYgnp0wbAzOg9f3ZwKqOQ34bvCzdLo8mVG3OZ90yKnAEOTf3ZwKqOQ34jlJ(lxS4kvXnv7nwXfsJmakscTf3ZwKqOQ3OJEctDXvQYwQaULklUOLHA0xazXvrUfjxwCPR)a6FtnARadcvu7nwKH2IMcfOLHA03phx)Qz0(bOjWGqf1EJfzOTOPqbbLZZy9hC)Wv6(PTFj9dDoa2ibLZZy9dw)sb3IBQ2BSIldWHAFCGI8qZbttHLTubiUuzXnv7nwXnuJm2zoXbkYOKLrsXfTmuJ(cilBPcAEPYIBQ2BSIBOgzSZCIdumPwkzR4IwgQrFbKLTubnvQS4MQ9gR4gQrg7mN4afbE2IKIlAzOg9fqw2sfvzPYIBQ2BSIBOgzSZCIduKvtoZP4IwgQrFbKLTuHuvxQS4IwgQrFbKf3uT3yf3Zykc1MHAmY3OsBPKJEK3PWIRIClsUS4gsbbjsEO5CMteijxacQ6(546pKccsOiuS0JcQ6(L0FifeKqrOyPhfSnvG3pS(LQ6(546pCyS(L0p05ayJeuopJ1FW9ZNQlUwkJf3Zykc1MHAmY3OsBPKJEK3PWYwQqkPkvwCrld1OVaYIBQ2BSI7WdjabGA5ZCI1dqKeve4zBQlUkYTi5YIBifeKi5HMZzorGKCbiOQ7NJR)qkiiHIqXspkOQ7xs)HuqqcfHILEuW2ubE)W6xQQ7NJR)WHX6xs)qNdGnsq58mw)b3VuWT4APmwChEibiaulFMtSEaIKOIapBtDzlviL0LklUOLHA0xazXnv7nwX1NeWLNXIEubEK3qs1TWxCvKBrYLf3qkiirYdnNZCIaj5cqqv3phx)HuqqcfHILEuqv3VK(dPGGekcfl9OGTPc8(H1Vuv3phx)HdJ1VK(HohaBKGY5zS(dUFPRU4APmwC9jbC5zSOhvGh5nKuDl8LTuHu8PuzXfTmuJ(cilUPAVXkUYPkdjyKbaXnktXovXvrUfjxwCdPGGejp0CoZjcKKlabvD)CC9hsbbjuekw6rbvD)s6pKccsOiuS0Jc2MkW7hw)svD)CC9homw)s6h6CaSrckNNX6p4(LU6IRLYyXvovzibJmaiUrzk2PkBPcPaHsLfx0Yqn6lGS4MQ9gR4cLu6f(OAOSfjYyYOiyXvrUfjxwCdO)n1OTcfHILEuGwgQrF)CC9hsbbjuekw6rbvD)CC9homw)s6h6CaSrckNNX6p4(5t1fxlLXIlusPx4JQHYwKiJjJIGLTuHuWTuzXfTmuJ(cilUwkJfxpbtp0rWipKXqDXnv7nwX1tW0dDemYdzmux2sfsbIlvwCrld1OVaYIRLYyXLboLgCKWIapZP4MQ9gR4YaNsdosyrGN5u2sfsrZlvwCrld1OVaYIRLYyX1HCYr14XGkUPAVXkUoKtoQgpguzlvifnvQS4IwgQrFbKfxlLXIRmkpe4JduSozBKDgR4MQ9gR4kJYdb(4afRt2gzNXkBPcPQYsLfx0Yqn6lGS4APmwCz1jbJYyUraZaEXnv7nwXLvNemkJ5gbmd4LTuH0vxQS4IwgQrFbKfxlLXIll18sh0hHOy3yXuUwFqhskUPAVXkUSuZlDqFeIIDJft5A9bDiPSLkKwQsLfx0Yqn6lGS4APmwCDU024qSugTn1XAmj6IBQ2BSIRZL2ghILYOTPowJjrx2sfslDPYIlAzOg9fqwCTuglUapZZujjceaUSDmS4MQ9gR4c8mptLKiqa4Y2XWYwQqA(uQS4IwgQrFbKfxlLXIltLewCGIqKCrIL6iBjhewCt1EJvCzQKWIdueIKlsSuhzl5GWYwQqAqOuzXfTmuJ(cilUwkJfxfG8mwCGI(r(SCVXkUPAVXkUka5zS4af9J8z5EJv2sfsd3sLfx0Yqn6lGS4APmwCXKSacjycosyXtUovBXnv7nwXftYciKGj4iHfp56uTLTuH0G4sLfx0Yqn6lGS4MQ9gR4catYghO4caJmGjrU4Qi3IKllUb0FifeKi5HMZzorGKCbiOQ7xs)HuqqcfHILEuqvxCTuglUaWKSXbkUaWidysKlBPcPP5LklUOLHA0xazXnv7nwX1rN(l3HWIHP3blUkYTi5YIBifeKi5HMZzorGKCbiOQ7NJR)qkiiHIqXspkOQ7xs)HuqqcfHILEuW2ubE)GbRFPQUFoU(vZO9dqtK8qZ5mNiqsUaeeuopJ1py9dcWTFoU(vZO9dqtOiuS0JcckNNX6hS(bb4wCTuglUo60F5oewmm9oyzlvinnvQS4IwgQrFbKfxf5wKCzXnKccsK8qZ5mNiqsUaeu19ZX1FifeKqrOyPhfu19lP)qkiiHIqXspkyBQaVFWG1VuvxCt1EJvCPyy8wuMv2sfsxLLklUOLHA0xazXvrUfjxwCPRFaJg(y9aej9dgS(bH(L0)EYy)b3pC7NJRFaJg(y9aej9dgS(5t)s6NU(3tg7hS(HB)CC9tOmeAioOybGr505yljxKfdmL3rgTvGwgQrF)02phx)agn8X6bis6hmy9lD)s6Nqzi0qCqbV0COsINfLhz0wkzbAzOg99lP)n1OTcOZsDKGkWh7mhbAzOg99ZX1)MA0wbGrdFm5HMdseOLHA03VK(vZO9dqtay0WhtEO5GebbLZZy9dR)Q7N2(L0pD9hq)BQrBfmKK1aozbAzOg99ZX1Fa9VPgTvaDwQJeub(yN5iqld1OVFoU(vZO9dqtWqswd4KfeuopJ1py9xD)0wCt1EJvCtEO5CMteijxaLTubFQUuzXfTmuJ(cilUkYTi5YIlGrdFSEaIK(bdw)Gq)s6FpzS)G7hU9ZX1pGrdFSEaIK(bdw)8PFj9VNm2py9d3IBQ2BSIRIqXspw2sf8rQsLf3uT3yf3KbaTiGuRhGfx0Yqn6lGSSLk4J0LklUOLHA0xazXvrUfjxwC3tgJ7ebu70pS(RUFj9dy0WhRhGiP)GH1V09lPF66pKccsK8qZ5mNiqsUaeu19ZX1)MA0wHIqXspkqld1OVFj9tx)Qz0(bOjuekw6rbbLZZy9dR)Q7NJR)qkiiHIqXspkOQ7N2(546pCyS(L0p05ayJeuopJ1FW9lD19tBXnv7nwXfWOHpM8qZbjLTubF4tPYIlAzOg9fqwCvKBrYLfx66hWOHpwpars)GbRFqOFj9VNm2FW9tt9ZX1pGrdFSEaIK(bdw)8PFj9tx)7jJ9dgS(PP(546NvJADCtIdUmH)4Dggz7qK7hmy9lD)s6xn8qlTvao8KlT(PTFA7xs)Qz0(bOjsEO5CMteijxacckNNX6hS(Du((L0)EYyCNiGAN(H1F19lPF66pG(3uJ2kyijRbCYc0Yqn67NJR)qkiibdjznGtwqv3pT9lPF66pG(j55Jip0wr69mbg0Xww)CC9tYZhrEOTI07zcQ6(546NKNpI8qBfP3ZeN1py9dcv3pT9lPF66pG(dPGGejp0CoZjcKKlabvD)CC9dy0WhRhGiPFy9d3(546xnJ2panbGuwgjXbkcKKlabbLZZy9ZX1pRg164MehCzc)X7mmY2Hi3pyW6x6(L0VA4HwARaC4jxA9tBXnv7nwXf6SuhjOc8XoZPSLT4cD2XaGewPYsfsvQS4IwgQrFbKf3PU4YWT4MQ9gR4YljxgQXIlVutHfxwnQ1Xnjo4Ye(J3zyKTdrUFy9lD)s6pG(PRFcLHqdXbfqNL6ipK4p1kqld1OVFoU(3uJ2kiNdGfhkwKhs8NAfOLHA03pT9ZX1pRg164MehCzc)X7mmY2Hi3py9lD)CC9hsbbjq5A4jyAX6biseu19lP)a63JHuqqIat5DKrBfu19lP)a6pKccs4pENHXAks9WqbvDXLxsIwkJfxplQs2MHASSLkKUuzXfTmuJ(cilUkYTi5YIlD9RMr7hGMi5HMZzorGKCbiiOCEgRFW6xk42phx)Qz0(bOjuekw6rbbLZZy9dw)sb3(PTFj9tx)b0)MA0wb0zPosqf4JDMJaTmuJ((546xnJ2panb0zPosqf4JDMJGGY5zS(bR)uT3yr1mA)a06N2(L0pD9hq)BQrBfyqOIAVXIm0w0uOaTmuJ((546xnJ2panbgeQO2BSidTfnfkiOCEgRFW6pv7nwunJ2paT(546NvJADCtIdUmH)4Dggz7qK7hmy9d3(PTFj9tx)b0pjpFe5H2ksVNjWGo2Y6NJRFsE(iYdTvKEptCw)G1piuD)CC9tYZhrEOTI07zIZ6p4(Du((546NKNpI8qBfP3Zeu19tB)s6NU(dOF1WdT0wb4WtU06NJRF66xnJ2panH)4Dgg3rRfeuopJ1FW9xL9ZX1VAgTFaAc)X7mmUJwliOCEgRFW6pv7nwunJ2paT(PTFA7NJRFOZbWgjOCEgR)G7xk42VK(HohaBKGY5zS(bRF42phx)HuqqcfHILEuqv3VK(dPGGekcfl9OGTPc8(dUFPQU4MQ9gR4Yqswd4KlBPc(uQS4IwgQrFbKfxf5wKCzXLU(dPGGekcfl9OWpaT(L0VAgTFaAcfHILEuqq58mw)G1Vuv3phx)HuqqcfHILEuW2ubE)GbRF(0phx)Qz0(bOjsEO5CMteijxacckNNX6hS(LQ6(PTFj9tx)b0)MA0wb0zPosqf4JDMJaTmuJ((546xnJ2panb0zPosqf4JDMJGGY5zS(bRFPQUFoU(bmA4J1dqKi8i0PUTFy9xD)s6NU(dOFEj5YqnkGircME47NJR)uT3ycOZsDKGkWh7mhH)yzOg99tB)02VK(HohaBKGY5zS(bRFAQFj9ZQrToUjXbxMWF8odJSDiY9hC)WT4MQ9gR4IbHkQ9glYqBrtHLTubiuQS4IwgQrFbKfxf5wKCzXLxsUmuJcplQs2MHASFj9hq)HuqqcEPX3OogaKWIaszzKiOQ7xs)01pD9hq)BQrBfkcfl9OaTmuJ((546xnJ2panHIqXspkiOCEgRFW63r57VQ9ZN(PTFj9tx)b0)MA0wbgeQO2BSidTfnfkqld1OVFoU(vZO9dqtGbHkQ9glYqBrtHcckNNX6hS(Du((RA)G4(546xnJ2panbgeQO2BSidTfnfkiOCEgRFW63r57VQ9dc9lPFaJg(y9aej9dgS(HB)CC9ZQrToUjXbxMWF8odJSDiY9dgS(HB)CC9hq)BQrBfmKK1aozbAzOg99lPF1mA)a0eyqOIAVXIm0w0uOGGY5zS(bRFhLV)Q2V09ZX1pGrdFSEaIeHhHo1T9dR)Q7xs)01Fa9ZljxgQrbYIem9W3phx)PAVXeyqOIAVXIm0w0uOWFSmuJ((PTFA7xs)01Fa9VPgTvaDwQJeub(yN5iqld1OVFoU(vZO9dqtaDwQJeub(yN5iiOCEgRFW63r57VQ9dI7NJRF1mA)a0eqNL6ibvGp2zocckNNX6hS(Du((RA)Gq)s6hWOHpwpars)GbRF42phx)b0)MA0wbdjznGtwGwgQrF)s6xnJ2panb0zPosqf4JDMJGGY5zS(bRFhLV)Q2V09ZX1pGrdFSEaIeHhHo1T9dR)Q7xs)01Fa9ZljxgQrbejsW0dF)CC9NQ9gtaDwQJeub(yN5i8hld1OVFA7N2(546FtnARaWOHpM8qZbjc0Yqn67xs)Qz0(bOjamA4Jjp0CqIGGY5zS(dUFhLV)Q2pF6NJR)qkiibGrdFm5HMdseu19ZX1FifeKqrOyPhfu19lP)qkiiHIqXspkyBQaV)G7xQQ7NJRFOZbWgjOCEgR)G7NM6N2IBQ2BSIR)4Dggz7qKlBPc4wQS4IwgQrFbKfxf5wKCzXLU(dO)n1OTcfHILEuGwgQrF)CC9RMr7hGMqrOyPhfeuopJ1py97O89x1(5t)02VK(PR)a6FtnARadcvu7nwKH2IMcfOLHA03phx)Qz0(bOjWGqf1EJfzOTOPqbbLZZy9dw)okF)vTFAQFoU(vZO9dqtGbHkQ9glYqBrtHcckNNX6hS(Du((RA)G4(L0pGrdFSEaIK(bdw)Gq)CC9hq)BQrBfmKK1aozbAzOg99lPF1mA)a0eyqOIAVXIm0w0uOGGY5zS(bRFhLV)Q2V09ZX1pGrdFSEaIeHhHo1T9dR)Q7xs)01Fa9ZljxgQrbYIem9W3phx)PAVXeyqOIAVXIm0w0uOWFSmuJ((PTFA7xs)01Fa9VPgTvaDwQJeub(yN5iqld1OVFoU(vZO9dqtaDwQJeub(yN5iiOCEgRFW63r57VQ9tt9ZX1VAgTFaAcOZsDKGkWh7mhbbLZZy9dw)okF)vTFqC)s6hWOHpwpars)GbRFqOFoU(dO)n1OTcgsYAaNSaTmuJ((L0VAgTFaAcOZsDKGkWh7mhbbLZZy9dw)okF)vTFP7NJRFaJg(y9aejcpcDQB7hw)v3VK(PR)a6NxsUmuJcisKGPh((546pv7nMa6SuhjOc8XoZr4pwgQrF)02pT9ZX1)MA0wbGrdFm5HMdseOLHA03VK(vZO9dqtay0WhtEO5GebbLZZy9hC)okF)vTF(0phx)HuqqcaJg(yYdnhKiOQ7NJR)qkiiHIqXspkOQ7xs)HuqqcfHILEuW2ubE)b3Vuv3phx)qNdGnsq58mw)b3pnvCt1EJvCxuUwNewKhs8NAlBzlUilcrIPApEyPYsfsvQS4MQ9gR4cDemupJV4IwgQrFbKLTuH0LklUOLHA0xazXvrUfjxwCbmA4J1dqK0pS(HB)CC97XqkiirGP8oYOTcQ6(5463JHuqqcOZsDKGkWh7mhbvD)s6NU(9yifeKa6SuhjOc8XoZrqq58mw)b3VJYlKZG6NJRFwnQ1Xnjo4Ye(J3zyKTdrUFWG1V09lP)a6FtnARadcvu7nwKH2IMcfOLHA03pT9ZX1VhdPGGeyqOIAVXIm0w0uOGQUFj97XqkiibgeQO2BSidTfnfkiOCEgR)G73r5fYzqf3uT3yfxvQ1XuT3yr9X2IR(yB0szS4cD2XaGewzlvWNsLf3uT3yfx)X7mmUJwxCrld1OVaYYwQaekvwCt1EJvC5LgFJ6yaqclciLLrsXfTmuJ(cilBPc4wQS4IwgQrFbKfxf5wKCzXfWOHpwpars)bdRFP7xs)01VhdPGGeqNL6ibvGp2zocQ6(L0VhdPGGeqNL6ibvGp2zocckNNX6p4(Du((RA)s3VK(dOFcLHqdXbf(J3zyKGSXstHc0Yqn67NJRFpgsbbjWGqf1EJfzOTOPqbvD)s63JHuqqcmiurT3yrgAlAkuqq58mw)b3VJY3phx)SAuRJBsCWLj8hVZWiBhIC)GbRF42VK(jugcnehu4pENHrcYglnfkqld1OVFj9VPgTvGbHkQ9glYqBrtHc0Yqn67N2IBQ2BSIlWeCmoqXKbazLTubiUuzXfTmuJ(cilUkYTi5YIRAmp1TcmOAkItU3y9lPF66pG(jugcnehu4pENHrcYglnfkqld1OVFj9dy0WhRhGiP)GH1pF6NJRFaJg(y9aej9hmS(LUFAlUPAVXkUH60JXbkgyk2EkSSLkO5LklUOLHA0xazXvrUfjxwCdOFpgsbbjcmL3rgTvqv3VK(PRFaJg(y9aej9dgS(LQFj9tOmeAioOybGr505yljxKfdmL3rgTvGwgQrF)CC9dy0WhRhGiPFWG1V09tBXnv7nwXnWuEhz02YwQGMkvwCrld1OVaYIBQ2BSIRk16yQ2BSO(yBXvFSnAPmwCHo7yaqcRSLkQYsLfx0Yqn6lGS4Qi3IKllUagn8X6bis6pyy9lDXnv7nwXfycoghOyYaGSYwQqQQlvwCrld1OVaYIRIClsUS4cy0WhRhGiP)GH1pFkUPAVXkUH60JXbkgyk2EkSSLkKsQsLfx0Yqn6lGS4Qi3IKllUb0VhdPGGebMY7iJ2kOQlUPAVXkUbMY7iJ2w2sfsjDPYIBQ2BSIlGuwgjXbkcKKlGIlAzOg9fqw2sfsXNsLf3uT3yfxfHILEKezl5ahlUOLHA0xazzlvifiuQS4MQ9gR4MevAyChcbTT4IwgQrFbKLTuHuWTuzXnv7nwXvngdvKCVXkUOLHA0xazzlBXfzrisSEg9zoLklvivPYIlAzOg9fqwCvKBrYLfxaJg(y9aej9dRF42VK(PR)a6FtnARa6SuhjOc8XoZrGwgQrF)CC9RMr7hGMa6SuhjOc8XoZrqq58mw)bdRFhLV)Q2pF6NJRF1mA)a0eqNL6ibvGp2zocckNNX6hS(t1EJfvZO9dqRFA7xs)01Fa9VPgTvGbHkQ9glYqBrtHc0Yqn67NJRF1mA)a0eyqOIAVXIm0w0uOGGY5zS(dgw)okF)vTF(0phx)Qz0(bOjWGqf1EJfzOTOPqbbLZZy9dw)PAVXIQz0(bO1phx)BQrBfqNL6ibvGp2zoc0Yqn67N2(L0pD9hq)QHhAPTcWHNCP1phx)Qz0(bOj8hVZW4oATGGY5zS(dU)QSFoU(vZO9dqt4pENHXD0AbbLZZy9dw)PAVXIQz0(bO1pTf3uT3yfxgsYAaNCzlviDPYIlAzOg9fqwCvKBrYLfxaJg(y9aej9dRF42phx)EmKccsaDwQJeub(yN5iOQ7NJR)qkiiHIqXspkOQ7xs)HuqqcfHILEuW2ubE)b3VuvxCt1EJvCvPwht1EJf1hBlU6JTrlLXIl0zhdasyLTubFkvwCrld1OVaYIRIClsUS4gsbbjyijRbCYcQ6IBQ2BSIlV04BuhdasyraPSmskBPcqOuzXfTmuJ(cilUkYTi5YIlHYqOH4GcEP5qLeplkpYOTuYc0Yqn6lUPAVXkUaszzKehOiqsUakBPc4wQS4IwgQrFbKfxf5wKCzXfWOHpwpars)bdRFP7xs)mCJHJrXe7HePPPiiuRkUPAVXkUatWX4aftgaKv2sfG4sLfx0Yqn6lGS4Qi3IKllUagn8X6bis6pyy9ZNIBQ2BSIBOo9yCGIbMITNclBPcAEPYIlAzOg9fqwCvKBrYLf3a63JHuqqIat5DKrBfu1f3uT3yf3at5DKrBlBPcAQuzXnv7nwXfqklJK4afbsYfqXfTmuJ(cilBPIQSuzXfTmuJ(cilUkYTi5YIRAgTFaAcfHILEKezl5ahfkajXbzrisQ2BSu3pyW6xkbnhU9lPF66hWOHpwpars)bdRFP7NJRFaJg(y9aej9hmS(5t)s6xnJ2panrOo9yCGIbMITNcfeuopJ1py97O89x1(LUFoU(bmA4J1dqK0pS(bH(L0VAgTFaAIqD6X4afdmfBpfkiOCEgRFW63r57VQ9lD)s6xnJ2panrGP8oYOTcckNNX6hS(Du((RA)s3pTf3uT3yfxfHILEKezl5ahlBPcPQUuzXfTmuJ(cilUkYTi5YIBa9VPgTvaDwQJeub(yN5iqld1OVFj9RMr7hGMadcvu7nwKH2IMcfeuopJ1FWW63r57VQ9ZN(L0pD9hq)QHhAPTcWHNCP1phx)Qz0(bOj8hVZW4oATGGY5zS(dU)QSFAlUPAVXkUmKK1ao5YwQqkPkvwCrld1OVaYIBQ2BSIRk16yQ2BSO(yBXvFSnAPmwCHo7yaqcRSLkKs6sLf3uT3yfxfHILEKezl5ahlUOLHA0xazzlvifFkvwCrld1OVaYIRIClsUS4cy0WhRhGiP)GH1piuCt1EJvCtIknmUdHG2w2sfsbcLklUOLHA0xazXvrUfjxwCPR)a6FtnARa6SuhjOc8XoZrGwgQrF)CC9RMr7hGMa6SuhjOc8XoZrqq58mw)bdRFhLV)Q2pF6N2(L0pD9hq)BQrBfyqOIAVXIm0w0uOaTmuJ((546xnJ2panbgeQO2BSidTfnfkiOCEgR)GH1VJY3Fv7Np9ZX1)MA0wb0zPosqf4JDMJaTmuJ((PTFj9tx)b0VA4HwARaC4jxA9ZX1VAgTFaAc)X7mmUJwliOCEgR)G7Vk7N2IBQ2BSIldjznGtUSLkKcULklUPAVXkUQXyOIK7nwXfTmuJ(cilBzlBXnPwadP46EY0qzlBPaa]] )


end
