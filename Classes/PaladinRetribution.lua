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


    spec:RegisterPack( "Retribution", 20220319.1, [[dKepmcqib4rarytKKpHQYOqQCkKsRsssVcjXSasUfQQQSlc)ci1WKK6yKuwgjvpdPOPjjX1qsABar13qvLACOQIZbeP1HuO5jqDpKyFaLdcerTqGWdrkyIOQQQlceL6JarHtIQkXkrQAMOQk3eikzNsc)eikYqbIIAPOQs6PuPPkj6RarKXkGSxj(Rqdwvhw0If0JjAYu1LH2miFMkgnaNwLvlG61avZMu3Me7MYVvmCj1Xrvvz5iEoktxPRdQTJQ8DanEbY5rsnFuz)sDrTsLfxFUyPc1RwD1RMMQbsfQxD10uD1kUl11yXToLGNoyX1sfS4YVIl5cH3BSIBDsTEsFPYIlBGjsS4wCdHp9YVyLWIRpxSuH6vRU6vtt1aPc1RUA1PknlUSAuwQGFxDXfW59OvclUEKjlU8R4sUq49gRFqMtD6pRPhKvsKa6xnqkO6x9Qvx9M(MEAaqAoiJgB65)6NFXw0HKl2VHa7VMCd5wQ7NvRVTFiYO0V7PqdIME(V(bzLGJ97IKSgWP0pWHaE)H4UiPFG3cO)zbGK(Pb(Fw)744OrF)deKOPN)RF()X4B7hyYwSFf0FWkGwNehSFAG)N1)y97P(mN(Rtj4S(HnnYy9FlFS(Z(dhgRFOZbWkA65)6hK1qW(tFGHzRcAlR)D6h4qaVFG3cOFAG)N1pdWa06NH1jjxutTO4wtgOtJfxqcqI(5xXLCHW7nw)GmN60Fwtpibir)GSsIeq)Qbsbv)QxT6Q3030dsas0pnainhKrJn9GeGe9Z)1p)ITOdjxSFdb2Fn5gYTu3pRwFB)qKrPF3tHgen9GeGe9Z)1piReCSFxKK1aoL(boeW7pe3fj9d8wa9plaK0pnW)Z6Fhhhn67FGGen9GeGe9Z)1p))y8T9dmzl2Vc6pyfqRtId2pnW)Z6FS(9uFMt)1PeCw)WMgzS(VLpw)z)HdJ1p05ayfn9GeGe9Z)1piRHG9N(adZwf0ww)70pWHaE)aVfq)0a)pRFgGbO1pdRtsUOMArtFtFk3BmMOMGYrjmxk1ZEJ10NY9gJjQjOCucZLkuaDOgzSZCIduKbROGKM(uU3ymrnbLJsyUuHcOd1iJDMtCGIj8cRyn9PCVXyIAckhLWCPcfqhQrg7mN4afbE2IKM(uU3ymrnbLJsyUuHcOd1iJDMtCGISAYzon9PCVXyIAckhLWCPcfqdPrgajjHwqDquydSo8mVOgMTWAmIe469gJJJnW6WZ8cEJo3tJr2O5H220NY9gJjQjOCucZLkuaDsKPHXDie0wqDqu2uJ2kGol1rckbFSZCeOLHA0RAtnARGHKSgWPiqld1OVPpL7ngtutq5OeMlvOaAgGd1(4af5HMdMMeB6B6bjaj6hKDqOeErF)ipKqD)7PG9VaW(t5oK(pw)jV80zOgfn9PCVXyuiyim4ytFk3BmgvOaAEj5YqncklvqkqKibtp1GIxQHrk0by0uhRhGibmkvr1EkyW8dhhGrtDSEaIeWOqtv0TNccgf(HJJvJADCtIdUmH)4Dggz7quaJI6QKdp0sBfGtn5sJwAvjNr7hGMi5HMZzorGKCbiiOsEgdmhPx1EkyCNiGAhkvRIUa2uJ2kyijRbCkCCHWqqcgsYAaNIaUMwv0fajpFe5H2ksVNjWGo2Y44i55Jip0wr69mbCnhhjpFe5H2ksVNjodSQunTQOlGqyiirYdnNZCIaj5cqaxZXby0uhRhGiHcv54KZO9dqtaivuqsCGIaj5cqqqL8mghhRg164MehCzc)X7mmY2HOagf1vjhEOL2kaNAYLgTn9PCVXyuHcO5LKld1iOSubPGSibtp1GIxQHrk0fcdbjKeyw6rHFaAQKZO9dqtijWS0JccQKNXatTQ54cHHGescml9OGTPeCWOqtoo5mA)a0ejp0CoZjcKKlabbvYZyGPw10QIUa2uJ2kGol1rckbFSZC44KZO9dqtaDwQJeuc(yN5iiOsEgdm1QMJdWOPowparIWJqN8wkvRkL7nMa6SuhjOe8XoZr4pwgQrpTQGohaBKGk5zmW4hvSAuRJBsCWLj8hVZWiBhIsWuTPpL7ngJkuaTm16yk3BSO(ylOSubPiNr7hGgRPpL7ngJkuaTm16yk3BSO(ylOSubPGSiejwpJ(mhqDquOlasE(iYdTvKEptGbDSLXXrYZhrEOTI07zc4AoosE(iYdTvKEptCwWGuoosE(iYdTvKEptCgy0SAAvr3MA0wbgekH3BSidTfnjQsoJ2panbgekH3BSidTfnjkiOsEglyqQkwnQ1Xnjo4Ye(J3zyKTdrjyQYXTPgTvaDwQJeuc(yN5OsoJ2panb0zPosqj4JDMJGGk5zSGbP0Qc6CaSrcQKNXaJFA6t5EJXOcfqltToMY9glQp2cklvqkilcrIPCpEiOyl5Klf1a1brXJHWqqcmiucV3yrgAlAsuaxZX5Xqyiib0zPosqj4JDMJaUUPpL7ngJkuaTm16yk3BSO(ylOSubP4GgsYDiSM(M(uU3ymHCgTFaAmk1ZEJbQdIsimeKi5HMZzorGKCbiGR54cHHGescml9OaUwvimeKqsGzPhfSnLGtrTQ54chgtf05ayJeujpJfS6uTPpL7ngtiNr7hGgJkuaT(CaSSyGH9okOTG6GOWQrToUjXbxMqFoawwmWWEhf0wWOOohxaK88rKhARi9EMad6ylJJJKNpI8qBfP3ZeNbg)MQCCK88rKhARi9EMaUUPpL7ngtiNr7hGgJkuan0rWq9mEqDquOlegcsK8qZ5mNiqsUaeW1CCHWqqcjbMLEuaxRkegcsijWS0Jc2MsWPOw10QkGn1OTcmiucV3yrgAlAsSPpL7ngtiNr7hGgJkuanKgzaKKeAb1brHnW6WZ8IAy2cRXisGR3Bmoo2aRdpZl4n6CpngzJMhAlOoBrcbUEJNIc6VCrkQbQZwKqGR3OJEctnf1a1zlsiW1B8GOWgyD4zEbVrN7PXiB08qBB6t5EJXeYz0(bOXOcfqZaCO2hhOip0CW0KiOoik0fWMA0wbgekH3BSidTfnjYXjNr7hGMadcLW7nwKH2IMefeujpJfmvvNwvqNdGnsqL8mgyQr1M(uU3ymHCgTFaAmQqb0HAKXoZjoqrgSIcsA6t5EJXeYz0(bOXOcfqhQrg7mN4aft4fwXA6t5EJXeYz0(bOXOcfqhQrg7mN4afbE2IKM(uU3ymHCgTFaAmQqb0HAKXoZjoqrwn5mNM(uU3ymHCgTFaAmQqb0WmmElQaklvqkNXKe4nd1yK)bN2cRe9iVtIG6GOecdbjsEO5CMteijxac4AoUqyiiHKaZspkGRvfcdbjKeyw6rbBtj4uuRAoUWHXubDoa2ibvYZybtZQB6t5EJXeYz0(bOXOcfqdZW4TOcOSubPm8qcqaOw5mNy9aejrjHA2MAqDqucHHGejp0CoZjcKKlabCnhximeKqsGzPhfW1QcHHGescml9OGTPeCkQvnhx4WyQGohaBKGk5zSGvJQn9PCVXyc5mA)a0yuHcOHzy8wubuwQGu8jbCLzSOhLGh5nKuEl1G6GOecdbjsEO5CMteijxac4AoUqyiiHKaZspkGRvfcdbjKeyw6rbBtj4uuRAoUWHXubDoa2ibvYZybRE1n9PCVXyc5mA)a0yuHcOHzy8wubuwQGuuszgsWidaIBubMDsqDqucHHGejp0CoZjcKKlabCnhximeKqsGzPhfW1QcHHGescml9OGTPeCkQvnhx4WyQGohaBKGk5zSGvV6M(uU3ymHCgTFaAmQqb0WmmElQaklvqkqjSEPokhyBrIcMmyccQdIsaBQrBfscml9ihximeKqsGzPhfW1CCHdJPc6CaSrcQKNXcMMv30NY9gJjKZO9dqJrfkGgMHXBrfqzPcsXtW0dDemYdzmu30NY9gJjKZO9dqJrfkGgMHXBrfqzPcsHboSgCKWIapZPPpL7ngtiNr7hGgJkuanmdJ3IkGYsfKId5uIYXJb10NY9gJjKZO9dqJrfkGgMHXBrfqzPcsrbvgc1XbkwNSnYoJ10NY9gJjKZO9dqJrfkGgMHXBrfqzPcsHvNemQG5gbmd4n9PCVXyc5mA)a0yuHcOHzy8wubuwQGuyPMx6G(iem7glMk16d6qstFk3BmMqoJ2pangvOaAyggVfvaLLkifNlTnoelvqBtDSgtIUPpL7ngtiNr7hGgJkuanmdJ3IkGYsfKcWZ8mzsIabGlBhdB6t5EJXeYz0(bOXOcfqdZW4TOcOSubPWKjHfhOiejxKyPoYwYbHn9PCVXyc5mA)a0yuHcOHzy8wubuwQGuKaYZyXbk6hLZY9gRPpL7ngtiNr7hGgJkuanmdJ3IkGYsfKcMKfqibtWrclEk1PCB6t5EJXeYz0(bOXOcfqdZW4TOcOSubPaatYghO4caJmGjrbuheLacHHGejp0CoZjcKKlabCTQqyiiHKaZspkGRB6t5EJXeYz0(bOXOcfqdZW4TOcOSubP4Ot)L7qyXW07GG6GOecdbjsEO5CMteijxac4AoUqyiiHKaZspkGRvfcdbjKeyw6rbBtj4GrrTQ54KZO9dqtK8qZ5mNiqsUaeeujpJbwvOkhNCgTFaAcjbMLEuqqL8mgyvHQn9PCVXyc5mA)a0yuHcOHzy8wuHbQdIsimeKi5HMZzorGKCbiGR54cHHGescml9OaUwvimeKqsGzPhfSnLGdgf1QUPpL7ngtiNr7hGgJkuanmdJ3IkGYsfKItYd1XbkUaWi0ryBmjH3IeqDquOlegcsK8qZ5mNiqsUaeW1CCHWqqcjbMLEuaxtBtFk3BmMqoJ2pangvOa6KhAoN5ebsYfaOoik0by0uhRhGibmkvr1EkyWuLJdWOPowparcyuOPk62tbbJQCCeydHgIdkwayujDo2sYfzXad7DuqBPLJdWOPowparcyuuxfb2qOH4GcEP5aNeplQmkOTWkQ2uJ2kGol1rckbFSZC442uJ2kamAQJjp0CqIk5mA)a0eagn1XKhAoirqqL8mgLQPvfDbSPgTvWqswd4u44cytnARa6SuhjOe8XoZHJtoJ2panbdjznGtrqqL8mgyvtBtFk3BmMqoJ2pangvOaAjbMLEeuhefaJM6y9aejGrPkQ2tbdMQCCagn1X6bisaJcnvTNccgvB6t5EJXeYz0(bOXOcfqNmaOfbKA9aSPpL7ngtiNr7hGgJkuanGrtDm5HMdsa1brzpfmUteqTdLQvby0uhRhGijykQRIUqyiirYdnNZCIaj5cqaxZXTPgTvijWS0JQOtoJ2panHKaZspkiOsEgJs1CCHWqqcjbMLEuaxtlhx4WyQGohaBKGk5zSGvVAAB6t5EJXeYz0(bOXOcfqdDwQJeuc(yN5aQdIcDagn1X6bisaJsvuTNcgm)WXby0uhRhGibmk0ufD7PGGrHF44y1Owh3K4Glt4pENHr2oefWOOUk5WdT0wb4utU0OLwvYz0(bOjsEO5CMteijxaccQKNXaZr6vTNcg3jcO2Hs1QOlGn1OTcgsYAaNchximeKGHKSgWPiGRPvfDbqYZhrEOTI07zcmOJTmoosE(iYdTvKEptaxZXrYZhrEOTI07zIZaRkvtRk6ciegcsK8qZ5mNiqsUaeW1CCagn1X6bisOqvoo5mA)a0easffKehOiqsUaeeujpJXXXQrToUjXbxMWF8odJSDikGrrDvYHhAPTcWPMCPrBtFtFk3BmMazrismL7XdPaDemupJVPpL7ngtGSiejMY94HuHcOLPwht5EJf1hBbLLkifOZogaKWa1brbWOPowparcfQYX5XqyiirGH9okOTc4AoopgcdbjGol1rckbFSZCeW1QOZJHWqqcOZsDKGsWh7mhbbvYZyb7i9cLmioownQ1Xnjo4Ye(J3zyKTdrbmkQRkGn1OTcmiucV3yrgAlAsKwoopgcdbjWGqj8EJfzOTOjrbCTkpgcdbjWGqj8EJfzOTOjrbbvYZyb7i9cLmOM(uU3ymbYIqKyk3JhsfkG2F8odJ7O1n9PCVXycKfHiXuUhpKkuanV04FWhdasyraPIcsA6t5EJXeilcrIPCpEivOaAGj4yCGIjdaYa1brbWOPowparsWuuxfDEmegcsaDwQJeuc(yN5iGRv5Xqyiib0zPosqj4JDMJGGk5zSGDK(QQUQaiWgcnehu4pENHrcYglnjYX5XqyiibgekH3BSidTfnjkGRv5XqyiibgekH3BSidTfnjkiOsEglyhPNJJvJADCtIdUmH)4Dggz7quaJcvvrGneAioOWF8odJeKnwAsu1MA0wbgekH3BSidTfnjsBtFk3BmMazrismL7XdPcfqhQtpghOyGHz7jrqDquKJ5HVvGbvdtCY9gtfDbqGneAioOWF8odJeKnwAsufGrtDSEaIKGPqtooaJM6y9aejbtrDAB6t5EJXeilcrIPCpEivOa6ad7DuqBb1brjapgcdbjcmS3rbTvaxRIoaJM6y9aejGrrnveydHgIdkwayujDo2sYfzXad7DuqB54amAQJ1dqKagf1PTPpL7ngtGSiejMY94HuHcOLPwht5EJf1hBbLLkifOZogaKWA6t5EJXeilcrIPCpEivOaAGj4yCGIjdaYa1brbWOPowparsWuuVPpL7ngtGSiejMY94HuHcOd1PhJdumWWS9KiOoikagn1X6biscMcnB6t5EJXeilcrIPCpEivOa6ad7DuqBb1brjapgcdbjcmS3rbTvax30NY9gJjqweIet5E8qQqb0asffKehOiqsUaA6t5EJXeilcrIPCpEivOaAjbMLEKezl5ahB6t5EJXeilcrIPCpEivOa6KitdJ7qiOTn9PCVXycKfHiXuUhpKkuaTCmgkj5EJ1030NY9gJjqweIeRNrFMdfgsYAaNcOoikagn1X6bisOqvv0fWMA0wb0zPosqj4JDMdhNCgTFaAcOZsDKGsWh7mhbbvYZybtXr6Rkn54KZO9dqtaDwQJeuc(yN5iiOsEgdm5mA)a0OvfDbSPgTvGbHs49glYqBrtICCYz0(bOjWGqj8EJfzOTOjrbbvYZybtXr6Rkn54KZO9dqtGbHs49glYqBrtIccQKNXatoJ2panoUn1OTcOZsDKGsWh7mhAvrxaYHhAPTcWPMCPXXjNr7hGMWF8odJ7O1ccQKNXcgKYXjNr7hGMWF8odJ7O1ccQKNXatoJ2panAB6t5EJXeilcrI1ZOpZHkuaTm16yk3BSO(ylOSubPaD2XaGegOoikagn1X6bisOqvoopgcdbjGol1rckbFSZCeW1CCHWqqcjbMLEuaxRkegcsijWS0Jc2MsWdwTQB6t5EJXeilcrI1ZOpZHkuanV04FWhdasyraPIcsa1brjegcsWqswd4ueW1n9PCVXycKfHiX6z0N5qfkGgqQOGK4afbsYfaOoikeydHgIdk4LMdCs8SOYOG2cR00NY9gJjqweIeRNrFMdvOaAGj4yCGIjdaYa1brbWOPowparsWuuxfd3y4yWmXEirD(jwLAztFk3BmMazrisSEg9zouHcOd1PhJdumWWS9KiOoikagn1X6biscMcnB6t5EJXeilcrI1ZOpZHkuaDGH9okOTG6GOeGhdHHGebg27OG2kGRB6t5EJXeilcrI1ZOpZHkuanGurbjXbkcKKlGM(uU3ymbYIqKy9m6ZCOcfqljWS0JKiBjh4iOoikYz0(bOjKeyw6rsKTKdCuibKehKfHiPCVXsnyuutWVPQk6amAQJ1dqKemf154amAQJ1dqKemfAQsoJ2panrOo9yCGIbgMTNefeujpJbMJ0xv154amAQJ1dqKqPkQKZO9dqteQtpghOyGHz7jrbbvYZyG5i9vvDvYz0(bOjcmS3rbTvqqL8mgyosFvvN2M(uU3ymbYIqKy9m6ZCOcfqZqswd4ua1brjGn1OTcOZsDKGsWh7mhvYz0(bOjWGqj8EJfzOTOjrbbvYZybtXr6RknvrxaYHhAPTcWPMCPXXjNr7hGMWF8odJ7O1ccQKNXcgKsBtFk3BmMazrisSEg9zouHcOLPwht5EJf1hBbLLkifOZogaKWA6t5EJXeilcrI1ZOpZHkuaTKaZspsISLCGJn9PCVXycKfHiX6z0N5qfkGojY0W4oecAlOoikagn1X6biscMsvA6t5EJXeilcrI1ZOpZHkuandjznGtbuhef6cytnARa6SuhjOe8XoZHJtoJ2panb0zPosqj4JDMJGGk5zSGP4i9vLM0QIUa2uJ2kWGqj8EJfzOTOjroo5mA)a0eyqOeEVXIm0w0KOGGk5zSGP4i9vLMCCBQrBfqNL6ibLGp2zo0QIUaKdp0sBfGtn5sJJtoJ2panH)4Dgg3rRfeujpJfmiL2M(uU3ymbYIqKy9m6ZCOcfqlhJHssU3yn9n9PCVXycOZogaKWOWljxgQrqzPcsXZIYKTzOgbfVudJuy1Owh3K4Glt4pENHr2oefkQRka6iWgcnehuaDwQJ8qI)Klh3MA0wb5CaS4aZI8qI)KlTCCSAuRJBsCWLj8hVZWiBhIcyQZXfcdbjqLAQjyAX6biseW1QcWJHWqqIad7DuqBfW1Qciegcs4pENHXAys9WqbCDtFk3BmMa6SJbajmQqb0mKK1aofqDquOtoJ2panrYdnNZCIaj5cqqqL8mgyQrvoo5mA)a0escml9OGGk5zmWuJQ0QIUa2uJ2kGol1rckbFSZC44KZO9dqtaDwQJeuc(yN5iiOsEgdm5mA)a0OvfDbSPgTvGbHs49glYqBrtICCYz0(bOjWGqj8EJfzOTOjrbbvYZyGjNr7hGghhRg164MehCzc)X7mmY2HOagfQsRk6cGKNpI8qBfP3ZeyqhBzCCK88rKhARi9EM4mWQs1CCK88rKhARi9EM4SGDKEoosE(iYdTvKEptaxtRk6cqo8qlTvao1Klnoo6KZO9dqt4pENHXD0AbbvYZybds54KZO9dqt4pENHXD0AbbvYZyGjNr7hGgT0YXbDoa2ibvYZybRgvvbDoa2ibvYZyGrvoUqyiiHKaZspkGRvfcdbjKeyw6rbBtj4bRw1n9PCVXycOZogaKWOcfqJbHs49glYqBrtIG6GOqximeKqsGzPhf(bOPsoJ2panHKaZspkiOsEgdm1QMJlegcsijWS0Jc2MsWbJcn54KZO9dqtK8qZ5mNiqsUaeeujpJbMAvtRk6cytnARa6SuhjOe8XoZHJtoJ2panb0zPosqj4JDMJGGk5zmWuRAooaJM6y9aejcpcDYBPuTk6cGxsUmuJcisKGPNAoUuU3ycOZsDKGsWh7mhH)yzOg90sRkOZbWgjOsEgdm(rfRg164MehCzc)X7mmY2HOemvB6t5EJXeqNDmaiHrfkG2F8odJSDikG6GOWljxgQrHNfLjBZqnQkGqyiibV04FWhdasyraPIcseW1QOJUa2uJ2kKeyw6roo5mA)a0escml9OGGk5zmWCK(QstAvrxaBQrBfyqOeEVXIm0w0KihNCgTFaAcmiucV3yrgAlAsuqqL8mgyosFvb5CCYz0(bOjWGqj8EJfzOTOjrbbvYZyG5i9vTkQamAQJ1dqKagfQYXXQrToUjXbxMWF8odJSDikGrHQCCbSPgTvWqswd4uujNr7hGMadcLW7nwKH2IMefeujpJbMJ0xv154amAQJ1dqKi8i0jVLs1QOlaEj5YqnkqwKGPNAoUuU3ycmiucV3yrgAlAsu4pwgQrpT0QIUa2uJ2kGol1rckbFSZC44KZO9dqtaDwQJeuc(yN5iiOsEgdmhPVQGCoo5mA)a0eqNL6ibLGp2zoccQKNXaZr6RAvuby0uhRhGibmkuLJlGn1OTcgsYAaNIk5mA)a0eqNL6ibLGp2zoccQKNXaZr6RQ6CCagn1X6biseEe6K3sPAv0faVKCzOgfqKibtp1CCPCVXeqNL6ibLGp2zoc)XYqn6PLwoUn1OTcaJM6yYdnhKOsoJ2panbGrtDm5HMdseeujpJfSJ0xvAYXfcdbjamAQJjp0CqIaUMJlegcsijWS0Jc4AvHWqqcjbMLEuW2ucEWQvnhh05ayJeujpJfm)qBtFk3BmMa6SJbajmQqb0lQuRtclYdj(tUG6GOqxaBQrBfscml9ihNCgTFaAcjbMLEuqqL8mgyosFvPjTQOlGn1OTcmiucV3yrgAlAsKJtoJ2panbgekH3BSidTfnjkiOsEgdmhPVQ8dhNCgTFaAcmiucV3yrgAlAsuqqL8mgyosFvb5QamAQJ1dqKagLQWXfWMA0wbdjznGtrLCgTFaAcmiucV3yrgAlAsuqqL8mgyosFvvNJdWOPowparIWJqN8wkvRIUa4LKld1OazrcMEQ54s5EJjWGqj8EJfzOTOjrH)yzOg90sRk6cytnARa6SuhjOe8XoZHJtoJ2panb0zPosqj4JDMJGGk5zmWCK(QYpCCYz0(bOjGol1rckbFSZCeeujpJbMJ0xvqUkaJM6y9aejGrPkCCbSPgTvWqswd4uujNr7hGMa6SuhjOe8XoZrqqL8mgyosFvvNJdWOPowparIWJqN8wkvRIUa4LKld1OaIejy6PMJlL7nMa6SuhjOe8XoZr4pwgQrpT0YXTPgTvay0uhtEO5GevYz0(bOjamAQJjp0CqIGGk5zSGDK(QstoUqyiibGrtDm5HMdseW1CCHWqqcjbMLEuaxRkegcsijWS0Jc2MsWdwTQ54GohaBKGk5zSG5NM(M(uU3ymHdAij3HWOitToMY9glQp2cklvqkqNDmaiHbQdIcGrtDSEaIekuLJJopgcdbjcmS3rbTvaxZXby0uhRhGiHsvOvvimeKWF8odJeKnwAsuaxZXfcdbjamAQJjp0CqIaUUPpL7ngt4GgsYDimQqb08sJ)bFmaiHfbKkkibuheLaiWgcnehu4HxQdhyZhDsEOMJlGn1OTcOZsDKGsWh7mhvbSPgTvGbHs49glYqBrtICCHdJPc6CaSrcQKNXcMFA6t5EJXeoOHKChcJkuanGurbjXbkcKKlaqDquiWgcnehuSaWOs6J1jjDgJJto8qlTvWdTfa1evYz0(bOjsga0IasTEakiOsEgdm1vR6M(uU3ymHdAij3HWOcfqdmbhJdumzaqgOoikagn1X6biscMI6Qy4gdhdMj2djQZpXQulvrNCgTFaAIKhAoN5ebsYfGGGk5zmoo5mA)a0escml9OGGk5zmAB6t5EJXeoOHKChcJkuaT)4Dgg3rRb1brbWOPowparsWuutvaEmegcseyyVJcARaUwfDbSPgTvWqswd4u44cHHGemKK1aofbCnTQOlasE(iYdTvKEptGbDSLXXrYZhrEOTI07zIZaJMvZXrYZhrEOTI07zc4AAvrxaBQrBfqNL6ibLGp2zoCCEmegcsaDwQJeuc(yN5iGR54KZO9dqtaDwQJeuc(yN5iiOsEgdm1RMwv0fWMA0wbgekH3BSidTfnjYXbDoa2ibvYZybZpCCSAuRJBsCWLj8hVZWiBhIcyuOkTQOtoJ2panrYdnNZCIaj5cqqqL8mghNCgTFaAcjbMLEuqqL8mgTn9PCVXych0qsUdHrfkGoWWEhf0wqDqucWJHWqqIad7DuqBfW1QOdWOPowparcyuutfb2qOH4GIfagvsNJTKCrwmWWEhf0wooaJM6y9aejGrrDAB6t5EJXeoOHKChcJkuanWeCmoqXKbazG6GOqhGrtDSEaIekvZXby0uhRhGijykQRsoJ2panrOo9yCGIbgMTNefeujpJbMJ0xv1PvfDbqYZhrEOTI07zcmOJTmoosE(iYdTvKEptCgyQxnhhjpFe5H2ksVNjGRPvfDbSPgTvWqswd4u44KZO9dqtWqswd4ueeujpJbgv54Kdp0sBfGtn5sJwv0fWMA0wbgekH3BSidTfnjYXjNr7hGMadcLW7nwKH2IMefeujpJbMAuLJd6CaSrcQKNXcMF44y1Owh3K4Glt4pENHr2oefWOqvAvrxaBQrBfqNL6ibLGp2zoCCYz0(bOjGol1rckbFSZCeeujpJbMAuLJd6CaSrcQKNXcMFOvfDYz0(bOjsEO5CMteijxaccQKNX44KZO9dqtijWS0JccQKNXOTPpL7ngt4GgsYDimQqb0YuRJPCVXI6JTGYsfKc0zhdasyG6GOay0uhRhGibmk0uvimeKqsGzPhfW1QcHHGescml9OGTPe8GvR6M(uU3ymHdAij3HWOcfqhQtpghOyGHz7jrqDquKJ5HVvGbvdtCY9gtfGrtDSEaIKGPqZM(uU3ymHdAij3HWOcfqhyyVJcAlOoikb4XqyiirGH9okOTc46M(uU3ymHdAij3HWOcfqdivuqsCGIaj5cOPpL7ngt4GgsYDimQqb0H60JXbkgyy2EseuhefaJM6y9aejbtHMn9PCVXych0qsUdHrfkGwMADmL7nwuFSfuwQGuGo7yaqcduhef62K4GRaaM6fGOwUbtr9Q54cHHGejp0CoZjcKKlabCnhximeKqsGzPhfW1CCHWqqcuPMAcMwSEaIebCnTn9PCVXych0qsUdHrfkGwogdLKCVXa1brja5ymusY9gtaxRIvJADCtIdUmH)4Dggz7quaJI6n9PCVXych0qsUdHrfkGwsGzPhjr2soWrqDquKZO9dqtijWS0JKiBjh4Oqcijoilcrs5EJLAWOOMGFtvv0by0uhRhGijykQZXby0uhRhGijyk0uLCgTFaAIqD6X4afdmmBpjkiOsEgdmhPVQQZXby0uhRhGiHsvujNr7hGMiuNEmoqXadZ2tIccQKNXaZr6RQ6QKZO9dqteyyVJcARGGk5zmWCK(QQoTn9PCVXych0qsUdHrfkGwMADmL7nwuFSfuwQGuGo7yaqcRPpL7ngt4GgsYDimQqb0YXyOKK7ngOoikbihJHssU3yc46M(uU3ymHdAij3HWOcfqljWS0JKiBjh4ytFk3BmMWbnKK7qyuHcOtImnmUdHG220NY9gJjCqdj5oegvOaA5ymusY9gR4YdjSBSsfQxT6QxnnvdKwCbMe7mhwXfKeiz(1k4xQaKbn2F)vca7)uQhY2p0q6Nph0qsUdHXx)eK)bFe03pBuW(t4DuYf99lbKMdYen983zy)QtJ9tdJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9tN6brROPN)od7xDASFAymEizrF)8rGneAioOiq81)o9Zhb2qOH4GIajqld1ONV(PtTGOv00ZFNH9ttASFAymEizrF)8rGneAioOiq81)o9Zhb2qOH4GIajqld1ONV(PtTGOv00ZFNH9tvASFAymEizrF)8TPgTvei(6FN(5BtnARiqc0Yqn65RF6Ozq0kA65VZW(b50y)0Wy8qYI((5JaBi0qCqrG4R)D6NpcSHqdXbfbsGwgQrpF9tNAbrROPN)od7NFtJ9tdJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9thndIwrtFtpijqY8RvWVubidAS)(Rea2)PupKTFOH0pFEekH1lF9tq(h8rqF)Srb7pH3rjx03VeqAoit00ZFNH9Ron2pnmgpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pDQfeTIME(7mSFAsJ9tdJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9tNAbrROPN)od7NQ0y)0Wy8qYI((5BtnARiq81)o9Z3MA0wrGeOLHA0Zx)0PEq0kA6B6bjbsMFTc(LkazqJ93FLaW(pL6HS9dnK(5RMGYrjmx(6NG8p4JG((zJc2FcVJsUOVFjG0CqMOPN)od7hKtJ9tdJXdjl67Np2aRdpZlceF9Vt)8XgyD4zErGeOLHA0Zx)0Pwq0kA65VZW(b50y)0Wy8qYI((5JnW6WZ8IaXx)70pFSbwhEMxeibAzOg981FU9dYgKj(RF6uliAfn9n9GKajZVwb)sfGmOX(7Vsay)Ns9q2(Hgs)8jNr7hGgJV(ji)d(iOVF2OG9NW7OKl67xcinhKjA65VZW(Pjn2pnmgpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981FU9dYgKj(RF6uliAfn983zy)vHg7NggJhsw03pFSbwhEMxei(6FN(5JnW6WZ8Iajqld1ONV(PtTGOv00ZFNH9xfASFAymEizrF)8XgyD4zErG4R)D6Np2aRdpZlcKaTmuJE(6p3(bzdYe)1pDQfeTIME(7mSFQsJ9tdJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9tNAbrROPN)od7xTQqJ9tdJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9tNAbrROPN)od7NMvtJ9tdJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9txvcIwrtp)Dg2pnRMg7NggJhsw03pFeydHgIdkceF9Vt)8rGneAioOiqc0Yqn65RF6upiAfn983zy)0KM0y)0Wy8qYI((5BtnARiq81)o9Z3MA0wrGeOLHA0Zx)0Pwq0kA65VZW(PzvOX(PHX4HKf99Z3MA0wrG4R)D6NVn1OTIajqld1ONV(PtTGOv0030dscKm)Af8lvaYGg7V)kbG9Fk1dz7hAi9Zh0zhdasy81pb5FWhb99ZgfS)eEhLCrF)saP5Gmrtp)Dg2VA0y)0Wy8qYI((5BtnARiq81)o9Z3MA0wrGeOLHA0Zx)0Pwq0kA65VZW(vJg7NggJhsw03pFeydHgIdkceF9Vt)8rGneAioOiqc0Yqn65RF6uliAfn983zy)QtJ9tdJXdjl67NVn1OTIaXx)70pFBQrBfbsGwgQrpF9tN6brROPN)od7NM0y)0Wy8qYI((5BtnARiq81)o9Z3MA0wrGeOLHA0Zx)0Pwq0kA65VZW(Rcn2pnmgpKSOVF(2uJ2kceF9Vt)8TPgTveibAzOg981pDG8GOv00ZFNH9tvASFAymEizrF)8TPgTvei(6FN(5BtnARiqc0Yqn65RF6a5brROPVPhKeiz(1k4xQaKbn2F)vca7)uQhY2p0q6NpKfHiXuUhpKV(ji)d(iOVF2OG9NW7OKl67xcinhKjA65VZW(vNg7NggJhsw03pFBQrBfbIV(3PF(2uJ2kcKaTmuJE(6No1cIwrtp)Dg2pvPX(PHX4HKf99Z3MA0wrG4R)D6NVn1OTIajqld1ONV(PtTGOv00ZFNH9tvASFAymEizrF)8rGneAioOiq81)o9Zhb2qOH4GIajqld1ONV(Pt9GOv00ZFNH9dYPX(PHX4HKf99Zhb2qOH4GIaXx)70pFeydHgIdkcKaTmuJE(6No1cIwrtp)Dg2p)Mg7NggJhsw03pFeydHgIdkceF9Vt)8rGneAioOiqc0Yqn65RF6uliAfn9n9GKajZVwb)sfGmOX(7Vsay)Ns9q2(Hgs)8HSiejwpJ(mh(6NG8p4JG((zJc2FcVJsUOVFjG0CqMOPN)od7xnASFAymEizrF)8TPgTvei(6FN(5BtnARiqc0Yqn65RF6Ozq0kA65VZW(Rcn2pnmgpKSOVF(iWgcnehuei(6FN(5JaBi0qCqrGeOLHA0Zx)52piBqM4V(PtTGOv00ZFNH9Rw10y)0Wy8qYI((5BtnARiq81)o9Z3MA0wrGeOLHA0Zx)0Pwq0kA65VZW(vRk0y)0Wy8qYI((5BtnARiq81)o9Z3MA0wrGeOLHA0Zx)0rZGOv0030ZVOupKf99ZV7pL7nw)6JTmrtFXnHxadP46Ek0qXvFSLvQS4kNr7hGgRuzPc1kvwCrld1OVaIIRKClsUS4gcdbjsEO5CMteijxac46(546pegcsijWS0Jc46(v1FimeKqsGzPhfSnLG3pL(vR6(546pCyS(v1p05ayJeujpJ1FW9RovlUPCVXkU1ZEJv2sfQxQS4IwgQrFbefxj5wKCzXLvJADCtIdUmH(CaSSyGH9okOT9dgL(vVFoU(dOFsE(iYdTvKEptGbDSL1phx)K88rKhARi9EM4S(bRF(nv7NJRFsE(iYdTvKEptaxxCt5EJvC1NdGLfdmS3rbTTSLkOzPYIlAzOg9fquCLKBrYLfx66pegcsK8qZ5mNiqsUaeW19ZX1FimeKqsGzPhfW19RQ)qyiiHKaZspkyBkbVFk9Rw19tB)Q6pG(3uJ2kWGqj8EJfzOTOjrbAzOg9f3uU3yfxOJGH6z8LTurvkvwCrld1OVaIIRKClsUS4YgyD4zErnmBH1yejW17nMaTmuJ((546NnW6WZ8cEJo3tJr2O5H2kqld1OV4E2IecC9gpOIlBG1HN5f8gDUNgJSrZdTT4E2IecC9gpff0F5Ifx1kUPCVXkUqAKbqssOT4E2IecC9gD0tyQlUQv2sfuTuzXfTmuJ(cikUsYTi5YIlD9hq)BQrBfyqOeEVXIm0w0KOaTmuJ((546xoJ2panbgekH3BSidTfnjkiOsEgR)G7NQQ3pT9RQFOZbWgjOsEgRFW6xnQwCt5EJvCzaou7JduKhAoyAsSSLka5LklUPCVXkUHAKXoZjoqrgSIcskUOLHA0xarzlvWVlvwCt5EJvCd1iJDMtCGIj8cRyfx0Yqn6lGOSLk4NsLf3uU3yf3qnYyN5ehOiWZwKuCrld1OVaIYwQaKwQS4MY9gR4gQrg7mN4afz1KZCkUOLHA0xarzlvOw1LklUOLHA0xarXnL7nwX9mMKaVzOgJ8p40wyLOh5DsS4kj3IKllUHWqqIKhAoN5ebsYfGaUUFoU(dHHGescml9OaUUFv9hcdbjKeyw6rbBtj49tPF1QUFoU(dhgRFv9dDoa2ibvYZy9hC)0S6IRLkyX9mMKaVzOgJ8p40wyLOh5DsSSLkutTsLfx0Yqn6lGO4MY9gR4o8qcqaOw5mNy9aejrjHA2M6IRKClsUS4gcdbjsEO5CMteijxac46(546pegcsijWS0Jc46(v1FimeKqsGzPhfSnLG3pL(vR6(546pCyS(v1p05ayJeujpJ1FW9RgvlUwQGf3Hhsaca1kN5eRhGijkjuZ2ux2sfQPEPYIlAzOg9fquCt5EJvC9jbCLzSOhLGh5nKuEl1fxj5wKCzXnegcsK8qZ5mNiqsUaeW19ZX1FimeKqsGzPhfW19RQ)qyiiHKaZspkyBkbVFk9Rw19ZX1F4Wy9RQFOZbWgjOsEgR)G7x9QlUwQGfxFsaxzgl6rj4rEdjL3sDzlvOgnlvwCrld1OVaIIBk3BSIRskZqcgzaqCJkWStwCLKBrYLf3qyiirYdnNZCIaj5cqax3phx)HWqqcjbMLEuax3VQ(dHHGescml9OGTPe8(P0VAv3phx)HdJ1VQ(HohaBKGk5zS(dUF1RU4APcwCvszgsWidaIBubMDYYwQqTQuQS4IwgQrFbef3uU3yfxOewVuhLdSTirbtgmblUsYTi5YIBa9VPgTvijWS0Jc0Yqn67NJR)qyiiHKaZspkGR7NJR)WHX6xv)qNdGnsqL8mw)b3pnRU4APcwCHsy9sDuoW2IefmzWeSSLkuJQLklUOLHA0xarX1sfS46jy6Hocg5HmgQlUPCVXkUEcMEOJGrEiJH6YwQqnqEPYIlAzOg9fquCTublUmWH1GJewe4zof3uU3yfxg4WAWrclc8mNYwQqn(DPYIlAzOg9fquCTublUoKtjkhpguXnL7nwX1HCkr54XGkBPc14NsLfx0Yqn6lGO4APcwCvqLHqDCGI1jBJSZyf3uU3yfxfuziuhhOyDY2i7mwzlvOgiTuzXfTmuJ(cikUwQGfxwDsWOcMBeWmGxCt5EJvCz1jbJkyUraZaEzlvOE1LklUOLHA0xarX1sfS4YsnV0b9riy2nwmvQ1h0HKIBk3BSIll18sh0hHGz3yXuPwFqhskBPc1vRuzXfTmuJ(cikUwQGfxNlTnoelvqBtDSgtIU4MY9gR46CPTXHyPcABQJ1ys0LTuH6QxQS4IwgQrFbefxlvWIlWZ8mzsIabGlBhdlUPCVXkUapZZKjjceaUSDmSSLkuNMLklUOLHA0xarX1sfS4YKjHfhOiejxKyPoYwYbHf3uU3yfxMmjS4afHi5Iel1r2soiSSLkuVkLklUOLHA0xarX1sfS4kbKNXIdu0pkNL7nwXnL7nwXvcipJfhOOFuol3BSYwQqDQwQS4IwgQrFbefxlvWIlMKfqibtWrclEk1PClUPCVXkUyswaHembhjS4PuNYTSLkuhKxQS4IwgQrFbef3uU3yfxays24afxayKbmjkfxj5wKCzXnG(dHHGejp0CoZjcKKlabCD)Q6pegcsijWS0Jc46IRLkyXfaMKnoqXfagzatIszlvOo)UuzXfTmuJ(cikUPCVXkUo60F5oewmm9oyXvsUfjxwCdHHGejp0CoZjcKKlabCD)CC9hcdbjKeyw6rbCD)Q6pegcsijWS0Jc2MsW7hmk9Rw19ZX1VCgTFaAIKhAoN5ebsYfGGGk5zS(bR)Qq1(546xoJ2panHKaZspkiOsEgRFW6VkuT4APcwCD0P)YDiSyy6DWYwQqD(PuzXfTmuJ(cikUsYTi5YIBimeKi5HMZzorGKCbiGR7NJR)qyiiHKaZspkGR7xv)HWqqcjbMLEuW2ucE)GrPF1QU4MY9gR4cZW4TOcRSLkuhKwQS4IwgQrFbef3uU3yfxNKhQJduCbGrOJW2yscVfjfxj5wKCzXLU(dHHGejp0CoZjcKKlabCD)CC9hcdbjKeyw6rbCD)0wCTublUojpuhhO4caJqhHTXKeElskBPcAwDPYIlAzOg9fquCLKBrYLfx66hWOPowpars)GrP)Q0VQ(3tb7p4(PA)CC9dy0uhRhGiPFWO0pn7xv)01)Eky)G1pv7NJRFcSHqdXbflamQKohBj5ISyGH9okOTc0Yqn67N2(546hWOPowpars)GrPF17xv)eydHgIdk4LMdCs8SOYOG2cRiqld1OVFv9VPgTvaDwQJeuc(yN5iqld1OVFoU(3uJ2kamAQJjp0CqIaTmuJ((v1VCgTFaAcaJM6yYdnhKiiOsEgRFk9xD)02VQ(PR)a6FtnARGHKSgWPiqld1OVFoU(dO)n1OTcOZsDKGsWh7mhbAzOg99ZX1VCgTFaAcgsYAaNIGGk5zS(bR)Q7N2IBk3BSIBYdnNZCIaj5cOSLkOPALklUOLHA0xarXvsUfjxwCbmAQJ1dqK0pyu6Vk9RQ)9uW(dUFQ2phx)agn1X6bis6hmk9tZ(v1)Eky)G1pvlUPCVXkUscml9yzlvqt1lvwCt5EJvCtga0IasTEawCrld1OVaIYwQGM0SuzXfTmuJ(cikUsYTi5YI7EkyCNiGAN(P0F19RQFaJM6y9aej9hmL(vVFv9tx)HWqqIKhAoN5ebsYfGaUUFoU(3uJ2kKeyw6rbAzOg99RQF66xoJ2panHKaZspkiOsEgRFk9xD)CC9hcdbjKeyw6rbCD)02phx)HdJ1VQ(HohaBKGk5zS(dUF1RUFAlUPCVXkUagn1XKhAoiPSLkOzvkvwCrld1OVaIIRKClsUS4sx)agn1X6bis6hmk9xL(v1)Eky)b3p)0phx)agn1X6bis6hmk9tZ(v1pD9VNc2pyu6NF6NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0V69RQF5WdT0wb4utU06N2(PTFv9lNr7hGMi5HMZzorGKCbiiOsEgRFW63r67xv)7PGXDIaQD6Ns)v3VQ(PR)a6FtnARGHKSgWPiqld1OVFoU(dHHGemKK1aofbCD)02VQ(PR)a6NKNpI8qBfP3ZeyqhBz9ZX1pjpFe5H2ksVNjGR7NJRFsE(iYdTvKEptCw)G1FvQUFA7xv)01Fa9hcdbjsEO5CMteijxac46(546hWOPowpars)u6NQ9ZX1VCgTFaAcaPIcsIdueijxaccQKNX6NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0V69RQF5WdT0wb4utU06N2IBk3BSIl0zPosqj4JDMtzlBX1JqjSElvwQqTsLf3uU3yfxcgcdowCrld1OVaIYwQq9sLfx0Yqn6lGO4o1fxgUf3uU3yfxEj5YqnwC5LAyS4sx)agn1X6bis6hmk9xL(v1)Eky)b3p)0phx)agn1X6bis6hmk9tZ(v1pD9VNc2pyu6NF6NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0V69RQF5WdT0wb4utU06N2(PTFv9lNr7hGMi5HMZzorGKCbiiOsEgRFW63r67xv)7PGXDIaQD6Ns)v3VQ(PR)a6FtnARGHKSgWPiqld1OVFoU(dHHGemKK1aofbCD)02VQ(PR)a6NKNpI8qBfP3ZeyqhBz9ZX1pjpFe5H2ksVNjGR7NJRFsE(iYdTvKEptCw)G1FvQUFA7xv)01Fa9hcdbjsEO5CMteijxac46(546hWOPowpars)u6NQ9ZX1VCgTFaAcaPIcsIdueijxaccQKNX6NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0V69RQF5WdT0wb4utU06N2IlVKeTublUqKibtp1LTubnlvwCrld1OVaII7uxCz4wCt5EJvC5LKld1yXLxQHXIlD9hcdbjKeyw6rHFaA9RQF5mA)a0escml9OGGk5zS(bRF1QUFoU(dHHGescml9OGTPe8(bJs)0SFoU(LZO9dqtK8qZ5mNiqsUaeeujpJ1py9Rw19tB)Q6NU(dO)n1OTcOZsDKGsWh7mhbAzOg99ZX1VCgTFaAcOZsDKGsWh7mhbbvYZy9dw)QvD)CC9dy0uhRhGir4rOtEB)u6V6(v1Fk3Bmb0zPosqj4JDMJWFSmuJ((PTFv9dDoa2ibvYZy9dw)8t)Q6NvJADCtIdUmH)4Dggz7qu6p4(PAXLxsIwQGfxKfjy6PUSLkQsPYIlAzOg9fquCt5EJvCLPwht5EJf1hBlU6JTrlvWIRCgTFaASYwQGQLklUOLHA0xarXvsUfjxwCPR)a6NKNpI8qBfP3ZeyqhBz9ZX1pjpFe5H2ksVNjGR7NJRFsE(iYdTvKEptCw)b3piTFoU(j55Jip0wr69mXz9dw)0S6(PTFv9tx)BQrBfyqOeEVXIm0w0KOaTmuJ((v1VCgTFaAcmiucV3yrgAlAsuqqL8mw)b3piTFv9ZQrToUjXbxMWF8odJSDik9hC)uTFoU(3uJ2kGol1rckbFSZCeOLHA03VQ(LZO9dqtaDwQJeuc(yN5iiOsEgR)G7hK2pT9RQFOZbWgjOsEgRFW6NFkUPCVXkUYuRJPCVXI6JTfx9X2OLkyXfzrisSEg9zoLTubiVuzXfTmuJ(cikUsYTi5YIRhdHHGeyqOeEVXIm0w0KOaUUFoU(9yimeKa6SuhjOe8XoZraxxCzl5KBPc1kUPCVXkUYuRJPCVXI6JTfx9X2OLkyXfzrismL7XdlBPc(DPYIlAzOg9fquCt5EJvCLPwht5EJf1hBlU6JTrlvWIRdAij3HWkBzlU1euokH5wQSuHALklUPCVXkU1ZEJvCrld1OVaIYwQq9sLf3uU3yf3qnYyN5ehOidwrbjfx0Yqn6lGOSLkOzPYIBk3BSIBOgzSZCIdumHxyfR4IwgQrFbeLTurvkvwCt5EJvCd1iJDMtCGIapBrsXfTmuJ(cikBPcQwQS4MY9gR4gQrg7mN4afz1KZCkUOLHA0xarzlvaYlvwCrld1OVaIIRKClsUS4YgyD4zErnmBH1yejW17nMaTmuJ((546NnW6WZ8cEJo3tJr2O5H2kqld1OV4MY9gR4cPrgajjH2YwQGFxQS4IwgQrFbefxj5wKCzXDtnARa6SuhjOe8XoZrGwgQrF)Q6FtnARGHKSgWPiqld1OV4MY9gR4MezAyChcbTTSLk4NsLf3uU3yfxgGd1(4af5HMdMMelUOLHA0xarzlBX1bnKK7qyLklvOwPYIlAzOg9fquCLKBrYLfxaJM6y9aej9tPFQ2phx)01VhdHHGebg27OG2kGR7NJRFaJM6y9aej9tP)Q0pT9RQ)qyiiH)4DggjiBS0KOaUUFoU(dHHGeagn1XKhAoiraxxCt5EJvCLPwht5EJf1hBlU6JTrlvWIl0zhdasyLTuH6LklUOLHA0xarXvsUfjxwCdOFcSHqdXbfE4L6Wb28rNKhQfOLHA03phx)b0)MA0wb0zPosqj4JDMJaTmuJ((v1Fa9VPgTvGbHs49glYqBrtIc0Yqn67NJR)WHX6xv)qNdGnsqL8mw)b3p)uCt5EJvC5Lg)d(yaqclcivuqszlvqZsLfx0Yqn6lGO4kj3IKllUeydHgIdkwayuj9X6KKoJjqld1OVFoU(Ldp0sBf8qBbqnPFv9lNr7hGMizaqlci16bOGGk5zS(bRF1vR6IBk3BSIlGurbjXbkcKKlGYwQOkLklUOLHA0xarXvsUfjxwCbmAQJ1dqK0FWu6x9(v1pd3y4yWmXEirD(jwLAz)Q6NU(LZO9dqtK8qZ5mNiqsUaeeujpJ1phx)Yz0(bOjKeyw6rbbvYZy9tBXnL7nwXfycoghOyYaGSYwQGQLklUOLHA0xarXvsUfjxwCbmAQJ1dqK0FWu6xT(v1Fa97XqyiirGH9okOTc46(v1pD9hq)BQrBfmKK1aofbAzOg99ZX1FimeKGHKSgWPiGR7N2(v1pD9hq)K88rKhARi9EMad6ylRFoU(j55Jip0wr69mXz9dw)0S6(546NKNpI8qBfP3ZeW19tB)Q6NU(dO)n1OTcOZsDKGsWh7mhbAzOg99ZX1VhdHHGeqNL6ibLGp2zoc46(546xoJ2panb0zPosqj4JDMJGGk5zS(bRF1RUFA7xv)01Fa9VPgTvGbHs49glYqBrtIc0Yqn67NJRFOZbWgjOsEgR)G7NF6NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0pv7N2(v1pD9lNr7hGMi5HMZzorGKCbiiOsEgRFoU(LZO9dqtijWS0JccQKNX6N2IBk3BSIR)4Dgg3rRlBPcqEPYIlAzOg9fquCLKBrYLf3a63JHWqqIad7DuqBfW19RQF66hWOPowpars)GrPF16xv)eydHgIdkwayujDo2sYfzXad7DuqBfOLHA03phx)agn1X6bis6hmk9RE)0wCt5EJvCdmS3rbTTSLk43LklUOLHA0xarXvsUfjxwCPRFaJM6y9aej9tP)Q7NJRFaJM6y9aej9hmL(vVFv9lNr7hGMiuNEmoqXadZ2tIccQKNX6hS(DK((RA)Q3pT9RQF66pG(j55Jip0wr69mbg0Xww)CC9tYZhrEOTI07zIZ6hS(vV6(546NKNpI8qBfP3ZeW19tB)Q6NU(dO)n1OTcgsYAaNIaTmuJ((546xoJ2panbdjznGtrqqL8mw)G1pv7NJRF5WdT0wb4utU06N2(v1pD9hq)BQrBfyqOeEVXIm0w0KOaTmuJ((546xoJ2panbgekH3BSidTfnjkiOsEgRFW6xnQ2phx)qNdGnsqL8mw)b3p)0phx)SAuRJBsCWLj8hVZWiBhIs)GrPFQ2pT9RQF66pG(3uJ2kGol1rckbFSZCeOLHA03phx)Yz0(bOjGol1rckbFSZCeeujpJ1py9Rgv7NJRFOZbWgjOsEgR)G7NF6N2(v1pD9lNr7hGMi5HMZzorGKCbiiOsEgRFoU(LZO9dqtijWS0JccQKNX6N2IBk3BSIlWeCmoqXKbazLTub)uQS4IwgQrFbefxj5wKCzXfWOPowpars)GrPFA2VQ(dHHGescml9OaUUFv9hcdbjKeyw6rbBtj49hC)QvDXnL7nwXvMADmL7nwuFST4Qp2gTublUqNDmaiHv2sfG0sLfx0Yqn6lGO4kj3IKllUYX8W3kWGQHjo5EJ1VQ(bmAQJ1dqK0FWu6NMf3uU3yf3qD6X4afdmmBpjw2sfQvDPYIlAzOg9fquCLKBrYLf3a63JHWqqIad7DuqBfW1f3uU3yf3ad7DuqBlBPc1uRuzXnL7nwXfqQOGK4afbsYfqXfTmuJ(cikBPc1uVuzXfTmuJ(cikUsYTi5YIlGrtDSEaIK(dMs)0S4MY9gR4gQtpghOyGHz7jXYwQqnAwQS4IwgQrFbefxj5wKCzXLU(3K4GRaaM6fGOwU9hmL(vV6(546pegcsK8qZ5mNiqsUaeW19ZX1FimeKqsGzPhfW19ZX1FimeKavQPMGPfRhGirax3pTf3uU3yfxzQ1XuU3yr9X2IR(yB0sfS4cD2XaGewzlvOwvkvwCrld1OVaIIRKClsUS4gq)YXyOKK7nMaUUFv9ZQrToUjXbxMWF8odJSDik9dgL(vV4MY9gR4khJHssU3yLTuHAuTuzXfTmuJ(cikUsYTi5YIRCgTFaAcjbMLEKezl5ahfsajXbzrisk3BSu3pyu6xnb)MQ9RQF66hWOPowpars)btPF17NJRFaJM6y9aej9hmL(Pz)Q6xoJ2panrOo9yCGIbgMTNefeujpJ1py97i99x1(vVFoU(bmAQJ1dqK0pL(Rs)Q6xoJ2panrOo9yCGIbgMTNefeujpJ1py97i99x1(vVFv9lNr7hGMiWWEhf0wbbvYZy9dw)osF)vTF17N2IBk3BSIRKaZspsISLCGJLTuHAG8sLfx0Yqn6lGO4MY9gR4ktToMY9glQp2wC1hBJwQGfxOZogaKWkBPc143LklUOLHA0xarXvsUfjxwCdOF5ymusY9gtaxxCt5EJvCLJXqjj3BSYwQqn(PuzXnL7nwXvsGzPhjr2soWXIlAzOg9fqu2sfQbslvwCt5EJvCtImnmUdHG2wCrld1OVaIYwQq9QlvwCt5EJvCLJXqjj3BSIlAzOg9fqu2YwCHo7yaqcRuzPc1kvwCrld1OVaII7uxCz4wCt5EJvC5LKld1yXLxQHXIlRg164MehCzc)X7mmY2HO0pL(vVFv9hq)01pb2qOH4GcOZsDKhs8NCfOLHA03phx)BQrBfKZbWIdmlYdj(tUc0Yqn67N2(546NvJADCtIdUmH)4Dggz7qu6hS(vVFoU(dHHGeOsn1emTy9aejc46(v1Fa97XqyiirGH9okOTc46(v1Fa9hcdbj8hVZWynmPEyOaUU4YljrlvWIRNfLjBZqnw2sfQxQS4IwgQrFbefxj5wKCzXLU(LZO9dqtK8qZ5mNiqsUaeeujpJ1py9Rgv7NJRF5mA)a0escml9OGGk5zS(bRF1OA)02VQ(PR)a6FtnARa6SuhjOe8XoZrGwgQrF)CC9lNr7hGMa6SuhjOe8XoZrqqL8mw)G1Fk3BSOCgTFaA9tB)Q6NU(dO)n1OTcmiucV3yrgAlAsuGwgQrF)CC9lNr7hGMadcLW7nwKH2IMefeujpJ1py9NY9glkNr7hGw)CC9ZQrToUjXbxMWF8odJSDik9dgL(PA)02VQ(PR)a6NKNpI8qBfP3ZeyqhBz9ZX1pjpFe5H2ksVNjoRFW6Vkv3phx)K88rKhARi9EM4S(dUFhPVFoU(j55Jip0wr69mbCD)02VQ(PR)a6xo8qlTvao1KlT(546NU(LZO9dqt4pENHXD0AbbvYZy9hC)G0(546xoJ2panH)4Dgg3rRfeujpJ1py9NY9glkNr7hGw)02pT9ZX1p05ayJeujpJ1FW9Rgv7xv)qNdGnsqL8mw)G1pv7NJR)qyiiHKaZspkGR7xv)HWqqcjbMLEuW2ucE)b3VAvxCt5EJvCzijRbCkLTubnlvwCrld1OVaIIRKClsUS4sx)HWqqcjbMLEu4hGw)Q6xoJ2panHKaZspkiOsEgRFW6xTQ7NJR)qyiiHKaZspkyBkbVFWO0pn7NJRF5mA)a0ejp0CoZjcKKlabbvYZy9dw)QvD)02VQ(PR)a6FtnARa6SuhjOe8XoZrGwgQrF)CC9lNr7hGMa6SuhjOe8XoZrqqL8mw)G1VAv3phx)agn1X6biseEe6K32pL(RUFv9tx)b0pVKCzOgfqKibtp19ZX1Fk3Bmb0zPosqj4JDMJWFSmuJ((PTFA7xv)qNdGnsqL8mw)G1p)0VQ(z1Owh3K4Glt4pENHr2oeL(dUFQwCt5EJvCXGqj8EJfzOTOjXYwQOkLklUOLHA0xarXvsUfjxwC5LKld1OWZIYKTzOg7xv)b0FimeKGxA8p4JbajSiGurbjc46(v1pD9tx)b0)MA0wHKaZspkqld1OVFoU(LZO9dqtijWS0JccQKNX6hS(DK((RA)0SFA7xv)01Fa9VPgTvGbHs49glYqBrtIc0Yqn67NJRF5mA)a0eyqOeEVXIm0w0KOGGk5zS(bRFhPV)Q2piVFoU(LZO9dqtGbHs49glYqBrtIccQKNX6hS(DK((RA)vPFv9dy0uhRhGiPFWO0pv7NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0pv7NJR)a6FtnARGHKSgWPiqld1OVFv9lNr7hGMadcLW7nwKH2IMefeujpJ1py97i99x1(vVFoU(bmAQJ1dqKi8i0jVTFk9xD)Q6NU(dOFEj5YqnkqwKGPN6(546pL7nMadcLW7nwKH2IMef(JLHA03pT9tB)Q6NU(dO)n1OTcOZsDKGsWh7mhbAzOg99ZX1VCgTFaAcOZsDKGsWh7mhbbvYZy9dw)osF)vTFqE)CC9lNr7hGMa6SuhjOe8XoZrqqL8mw)G1VJ03Fv7Vk9RQFaJM6y9aej9dgL(PA)CC9hq)BQrBfmKK1aofbAzOg99RQF5mA)a0eqNL6ibLGp2zoccQKNX6hS(DK((RA)Q3phx)agn1X6biseEe6K32pL(RUFv9tx)b0pVKCzOgfqKibtp19ZX1Fk3Bmb0zPosqj4JDMJWFSmuJ((PTFA7NJR)n1OTcaJM6yYdnhKiqld1OVFv9lNr7hGMaWOPoM8qZbjccQKNX6p4(DK((RA)0SFoU(dHHGeagn1XKhAoirax3phx)HWqqcjbMLEuax3VQ(dHHGescml9OGTPe8(dUF1QUFoU(HohaBKGk5zS(dUF(PFAlUPCVXkU(J3zyKTdrPSLkOAPYIlAzOg9fquCLKBrYLfx66pG(3uJ2kKeyw6rbAzOg99ZX1VCgTFaAcjbMLEuqqL8mw)G1VJ03Fv7NM9tB)Q6NU(dO)n1OTcmiucV3yrgAlAsuGwgQrF)CC9lNr7hGMadcLW7nwKH2IMefeujpJ1py97i99x1(5N(546xoJ2panbgekH3BSidTfnjkiOsEgRFW63r67VQ9dY7xv)agn1X6bis6hmk9xL(546pG(3uJ2kyijRbCkc0Yqn67xv)Yz0(bOjWGqj8EJfzOTOjrbbvYZy9dw)osF)vTF17NJRFaJM6y9aejcpcDYB7Ns)v3VQ(PR)a6NxsUmuJcKfjy6PUFoU(t5EJjWGqj8EJfzOTOjrH)yzOg99tB)02VQ(PR)a6FtnARa6SuhjOe8XoZrGwgQrF)CC9lNr7hGMa6SuhjOe8XoZrqqL8mw)G1VJ03Fv7NF6NJRF5mA)a0eqNL6ibLGp2zoccQKNX6hS(DK((RA)G8(v1pGrtDSEaIK(bJs)vPFoU(dO)n1OTcgsYAaNIaTmuJ((v1VCgTFaAcOZsDKGsWh7mhbbvYZy9dw)osF)vTF17NJRFaJM6y9aejcpcDYB7Ns)v3VQ(PR)a6NxsUmuJcisKGPN6(546pL7nMa6SuhjOe8XoZr4pwgQrF)02pT9ZX1)MA0wbGrtDm5HMdseOLHA03VQ(LZO9dqtay0uhtEO5GebbvYZy9hC)osF)vTFA2phx)HWqqcaJM6yYdnhKiGR7NJR)qyiiHKaZspkGR7xv)HWqqcjbMLEuW2ucE)b3VAv3phx)qNdGnsqL8mw)b3p)uCt5EJvCxuPwNewKhs8NClBzlUilcrIPCpEyPYsfQvQS4MY9gR4cDemupJV4IwgQrFbeLTuH6LklUOLHA0xarXvsUfjxwCbmAQJ1dqK0pL(PA)CC97XqyiirGH9okOTc46(5463JHWqqcOZsDKGsWh7mhbCD)Q6NU(9yimeKa6SuhjOe8XoZrqqL8mw)b3VJ0luYG6NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0V69RQ)a6FtnARadcLW7nwKH2IMefOLHA03pT9ZX1VhdHHGeyqOeEVXIm0w0KOaUUFv97XqyiibgekH3BSidTfnjkiOsEgR)G73r6fkzqf3uU3yfxzQ1XuU3yr9X2IR(yB0sfS4cD2XaGewzlvqZsLf3uU3yfx)X7mmUJwxCrld1OVaIYwQOkLklUPCVXkU8sJ)bFmaiHfbKkkiP4IwgQrFbeLTubvlvwCrld1OVaIIRKClsUS4cy0uhRhGiP)GP0V69RQF663JHWqqcOZsDKGsWh7mhbCD)Q63JHWqqcOZsDKGsWh7mhbbvYZy9hC)osF)vTF17xv)b0pb2qOH4Gc)X7mmsq2yPjrbAzOg99ZX1VhdHHGeyqOeEVXIm0w0KOaUUFv97XqyiibgekH3BSidTfnjkiOsEgR)G73r67NJRFwnQ1Xnjo4Ye(J3zyKTdrPFWO0pv7xv)eydHgIdk8hVZWibzJLMefOLHA03VQ(3uJ2kWGqj8EJfzOTOjrbAzOg99tBXnL7nwXfycoghOyYaGSYwQaKxQS4IwgQrFbefxj5wKCzXvoMh(wbgunmXj3BS(v1pD9hq)eydHgIdk8hVZWibzJLMefOLHA03VQ(bmAQJ1dqK0FWu6NM9ZX1pGrtDSEaIK(dMs)Q3pTf3uU3yf3qD6X4afdmmBpjw2sf87sLfx0Yqn6lGO4kj3IKllUb0VhdHHGebg27OG2kGR7xv)01pGrtDSEaIK(bJs)Q1VQ(jWgcnehuSaWOs6CSLKlYIbg27OG2kqld1OVFoU(bmAQJ1dqK0pyu6x9(PT4MY9gR4gyyVJcABzlvWpLklUOLHA0xarXnL7nwXvMADmL7nwuFST4Qp2gTublUqNDmaiHv2sfG0sLfx0Yqn6lGO4kj3IKllUagn1X6bis6pyk9REXnL7nwXfycoghOyYaGSYwQqTQlvwCrld1OVaIIRKClsUS4cy0uhRhGiP)GP0pnlUPCVXkUH60JXbkgyy2EsSSLkutTsLfx0Yqn6lGO4kj3IKllUb0VhdHHGebg27OG2kGRlUPCVXkUbg27OG2w2sfQPEPYIBk3BSIlGurbjXbkcKKlGIlAzOg9fqu2sfQrZsLf3uU3yfxjbMLEKezl5ahlUOLHA0xarzlvOwvkvwCt5EJvCtImnmUdHG2wCrld1OVaIYwQqnQwQS4MY9gR4khJHssU3yfx0Yqn6lGOSLT4ISiejwpJ(mNsLLkuRuzXfTmuJ(cikUsYTi5YIlGrtDSEaIK(P0pv7xv)01Fa9VPgTvaDwQJeuc(yN5iqld1OVFoU(LZO9dqtaDwQJeuc(yN5iiOsEgR)GP0VJ03Fv7NM9ZX1VCgTFaAcOZsDKGsWh7mhbbvYZy9dw)PCVXIYz0(bO1pT9RQF66pG(3uJ2kWGqj8EJfzOTOjrbAzOg99ZX1VCgTFaAcmiucV3yrgAlAsuqqL8mw)btPFhPV)Q2pn7NJRF5mA)a0eyqOeEVXIm0w0KOGGk5zS(bR)uU3yr5mA)a06NJR)n1OTcOZsDKGsWh7mhbAzOg99tB)Q6NU(dOF5WdT0wb4utU06NJRF5mA)a0e(J3zyChTwqqL8mw)b3piTFoU(LZO9dqt4pENHXD0AbbvYZy9dw)PCVXIYz0(bO1pTf3uU3yfxgsYAaNszlvOEPYIlAzOg9fquCLKBrYLfxaJM6y9aej9tPFQ2phx)EmegcsaDwQJeuc(yN5iGR7NJR)qyiiHKaZspkGR7xv)HWqqcjbMLEuW2ucE)b3VAvxCt5EJvCLPwht5EJf1hBlU6JTrlvWIl0zhdasyLTubnlvwCrld1OVaIIRKClsUS4gcdbjyijRbCkc46IBk3BSIlV04FWhdasyraPIcskBPIQuQS4IwgQrFbefxj5wKCzXLaBi0qCqbV0CGtINfvgf0wyfbAzOg9f3uU3yfxaPIcsIdueijxaLTubvlvwCrld1OVaIIRKClsUS4cy0uhRhGiP)GP0V69RQFgUXWXGzI9qI68tSk1YIBk3BSIlWeCmoqXKbazLTubiVuzXfTmuJ(cikUsYTi5YIlGrtDSEaIK(dMs)0S4MY9gR4gQtpghOyGHz7jXYwQGFxQS4IwgQrFbefxj5wKCzXnG(9yimeKiWWEhf0wbCDXnL7nwXnWWEhf02YwQGFkvwCt5EJvCbKkkijoqrGKCbuCrld1OVaIYwQaKwQS4IwgQrFbefxj5wKCzXvoJ2panHKaZspsISLCGJcjGK4GSiejL7nwQ7hmk9RMGFt1(v1pD9dy0uhRhGiP)GP0V69ZX1pGrtDSEaIK(dMs)0SFv9lNr7hGMiuNEmoqXadZ2tIccQKNX6hS(DK((RA)Q3phx)agn1X6bis6Ns)vPFv9lNr7hGMiuNEmoqXadZ2tIccQKNX6hS(DK((RA)Q3VQ(LZO9dqteyyVJcARGGk5zS(bRFhPV)Q2V69tBXnL7nwXvsGzPhjr2soWXYwQqTQlvwCrld1OVaIIRKClsUS4gq)BQrBfqNL6ibLGp2zoc0Yqn67xv)Yz0(bOjWGqj8EJfzOTOjrbbvYZy9hmL(DK((RA)0SFv9tx)b0VC4HwARaCQjxA9ZX1VCgTFaAc)X7mmUJwliOsEgR)G7hK2pTf3uU3yfxgsYAaNszlvOMALklUOLHA0xarXnL7nwXvMADmL7nwuFST4Qp2gTublUqNDmaiHv2sfQPEPYIBk3BSIRKaZspsISLCGJfx0Yqn6lGOSLkuJMLklUOLHA0xarXvsUfjxwCbmAQJ1dqK0FWu6Vkf3uU3yf3KitdJ7qiOTLTuHAvPuzXfTmuJ(cikUsYTi5YIlD9hq)BQrBfqNL6ibLGp2zoc0Yqn67NJRF5mA)a0eqNL6ibLGp2zoccQKNX6pyk97i99x1(Pz)02VQ(PR)a6FtnARadcLW7nwKH2IMefOLHA03phx)Yz0(bOjWGqj8EJfzOTOjrbbvYZy9hmL(DK((RA)0SFoU(3uJ2kGol1rckbFSZCeOLHA03pT9RQF66pG(Ldp0sBfGtn5sRFoU(LZO9dqt4pENHXD0AbbvYZy9hC)G0(PT4MY9gR4Yqswd4ukBPc1OAPYIBk3BSIRCmgkj5EJvCrld1OVaIYw2Yw2Ywk]] )


end
