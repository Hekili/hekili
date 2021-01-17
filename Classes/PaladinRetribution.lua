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


    spec:RegisterPack( "Retribution", 20210117, [[dy0XcbqijLEerfPlbucBsi(KKqAukQoLIYQKuvVssYSak2fQ(LKIHruCmIslJuvpJOsttsW1aQSnjHY3ak14iQW5KeQSojHW8aQ6EiyFcPdsurPwOKkpeOeDrIkk5Jevu4KscvTsIQMjrfXoLenuIkQAPscrpLKMkPkFLOIIglrfv2RG)kXGbDyrlMepgLjtLldTzaFMiJgiNwvRwsvEnc1SPQBtk7MYVLA4kYXbkPLJ0ZjmDLUUcBNu57c14LK68iK5JO9RYbzd6fuD5IHk1xg9LvgzLfS5YkJCbBzLJG6s0eguNsgXPeguTuddQvK4sFLX(TfuNsI8D6c6fuf9GYWGAqvz8(TI3ckbvxUyOs9LrFzLrwzbBUSYixWwwWoOkMqwOsWwMGkO35qlOeuDOGfuLtpyfjU0xzSFBhuoF6t3BN8YPhu(0gjLOdc2G5G6lJ(YguNOnW7XGQC6bRiXL(kJ9B7GY5tF6E7Kxo9GYN2iPeDqWgmhuFz0x2t(t(KTFBc(efzTMsUeM69B7Kpz73MGprrwRPKBveQrXJcXBsLgOigAAi9Kpz73MGprrwRPKBveQrXJcXBsLgOKJDOzN8jB)2e8jkYAnLCRIqnkEuiEtQ0aL43wKEYNS9BtWNOiR1uYTkc1O4rH4nPsduet03Ko5t2(Tj4tuK1Ak5wfHAsklnSSnLI2EYFWtE50dkNv1iBSO7GOoKs0b3xdp4ccpyY2MEWxCWux((uXJ8t(KTFBccuuzqmEYNS9BtufHAyP3xs2(Tv8VybJLAibw3ExhBIt(KTFBIQiudl9(sY2VTI)flySudjiHgsZTPIt(dEYNS9BtWzD7DDSjim173gyEacZvgaaCfF3o)qSCkMSLKuzaaWtDOj9MujMMli(ykIYaaGN6qt6nPsmnxqCkQLVjIkRCqsQmaa4m6qKoKpMIOmaa4m6qKoKtrT8nb41hCZo5t2(Tj4SU9Uo2evrOg)lbAfL6nCsAOTG5biiMqVVSjvcxb3)sGwrPEdNKgABuc6tsoVwA(UcQdTLNoNGJv)IvqssZ3vqDOT805e83Ic2GB2jFY2VnbN1T31XMOkc1a8uuX3TdmpabLbaap1HM0BsLyAUG4JjssLbaaNrhI0H8XueLbaaNrhI0HCXMmIjiRmN8jB)2eCw3ExhBIQiuJa0JExPbk6qtctJHN8jB)2eCw3ExhBIQiuJIhfI3Kknqrm00q6jFY2VnbN1T31XMOkc1O4rH4nPsduYXo0St(KTFBcoRBVRJnrveQrXJcXBsLgOe)2I0t(KTFBcoRBVRJnrveQrXJcXBsLgOiMOVjDYNS9BtWzD7DDSjQIqndbw(f1aJLAiH3em6ytfpwaRJ02HwXH6EgcMhGGYaaGN6qt6nPsmnxq8XejPYaaGZOdr6q(ykIYaaGZOdr6qUytgXrjiRmKKSU9Uo24Po0KEtQetZfeNIA5BIOvaCKKSU9Uo24m6qKoKtrT8nr0kaUt(KTFBcoRBVRJnrveQziWYVOgySudj06qAmi0R9MuzQJrAHrjsSPhmpabLbaap1HM0BsLyAUG4JjssLbaaNrhI0H8XueLbaaNrhI0HCXMmIJsqwzo5t2(Tj4SU9Uo2evrOMHal)IAGXsnKGlPeR1TvCiJ4IUMMSFjcmpabLbaap1HM0BsLyAUG4JjssLbaaNrhI0H8XueLbaaNrhI0HCXMmIJsqwzo5t2(Tj4SU9Uo2evrOMHal)IAGXsnKGwYsfkweGqClAdXZaZdqqzaaWtDOj9MujMMli(yIKuzaaWz0HiDiFmfrzaaWz0HiDixSjJ4OeKvMt(KTFBcoRBVRJnrveQziWYVOgySudj4Oy6aEkw0Hcb6p5t2(Tj4SU9Uo2evrOMHal)IAGXsnKGG4HNyKkkXVjDYNS9BtWzD7DDSjQIqndbw(f1aJLAibj6RvyTdR(Kpz73MGZ6276ytufHAgcS8lQbgl1qcAOwtjQ0aLPuSfXBIt(KTFBcoRBVRJnrveQziWYVOgySudjiMskw0WClG6M4t(KTFBcoRBVRJnrveQziWYVOgySudjiEdy4ls(0952urrjDsyPbkaiTz)seyEackdaaEQdnP3KkX0CbXhtKKkdaaoJoePd5JPikdaaoJoePd5InzehLGSYqsY6276yJN6qt6nPsmnxqCkQLVjIwbWrsY6276yJZOdr6qof1Y3erRa4o5t2(Tj4SU9Uo2evrOMHal)IAGXsnKG4nGHVKIPNM2kkkPtclnqbaPn7xIaZdqqzaaWtDOj9MujMMli(yIKuzaaWz0HiDiFmfrzaaWz0HiDixSjJ4OeKvgssw3ExhB8uhAsVjvIP5cItrT8nr0kaossw3ExhBCgDishYPOw(MiAfa3jFY2VnbN1T31XMOkc1K6qt6nPsmnxqG5bimhu7jQm1XinkHkezFne8GJKeu7jQm1Xinkb5gzFnmk4ij30J2Yb1EIkPo0KqkhTuXJUiSU9Uo24GAprLuhAsiLtrT8nbbzMfzETB6rB5cKMtGEnoAPIhDKKSU9Uo24cKMtGEnof1Y3erLz2jFY2VnbN1T31XMOkc1WOdr6qW8aeMdQ9evM6yKgLqfISVgcEWrscQ9evM6yKgLGCJSVggfCKKB6rB5GAprLuhAsiLJwQ4rxew3ExhBCqTNOsQdnjKYPOw(MGGmZo5t2(Tj4SU9Uo2evrOMuacTcO0774t(KTFBcoRBVRJnrveQbu7jQK6qtcPG5biSVgw2UaAsIGmrMpxzaaWtDOj9MujMMli(yIKuzaaWz0HiDiFmnJKCUYaaGN6qt6nPsmnxqCxhBryD7DDSXtDOj9MujMMliof1Y3erRGmKKkdaaoJoePd5Uo2IW6276yJZOdr6qof1Y3erRGmZMDYNS9BtWzD7DDSjQIqnaVL(cfze32BsG5biaQ9evM6yKgLGCJW6276yJN6qt6nPsmnxqCkQLVjIkXCr2xdlBxanjrqMiZRDtpAlxG0Cc0RXrlv8OJKuzaaWfinNa9A8X0St(dEYNS9BtWbE7fGqQGGUK(PIhbJLAibNOWsXMkEem6s)ajiMqVVSjvcxb396EdlITPArjOpjPYaaGJAterX0ktDms5JPiouzaaWR3WjPH2YDDSfrzaaWDVU3WY0Go1cK76y7Kpz73MGd82laHurveQrG0Cc0RbMhGW851UPhTLZOdr6qoAPIhDrMZ6276yJN6qt6nPsmnxqCkQLVjIQp4ijzD7DDSXtDOj9MujMMliof1Y3eeKz2msY5B6rB5y1iBSFBfbAlAmKJwQ4rxKn9OTCG3sFHImIB7njoAPIhDZijNRmaa4m6qKoKpMijzD7DDSXz0HiDiNIA5BIO6dUzZImV2n9OTCG3sFHImIB7njoAPIhDKKSU9Uo24aVL(cfze32BsCkQLVjaVCmlY8A30J2YXQr2y)2kc0w0yihTuXJossw3ExhBCSAKn2VTIaTfngYPOw(Ma8YXSi7RHLTlGMKiiZjFY2Vnbh4TxacPIQiuJU0aRJxacPIcOutdPG5bimV2n9OTCG3sFHImIB7njoAPIhDKKSU9Uo24aVL(cfze32BsCkQLVjIkXC1xwzijDOYaaGd8w6luKrCBVjXhtZImV2n9OTCSAKn2VTIaTfngYrlv8OJKK1T31XghRgzJ9BRiqBrJHCkQLVjIkXC1xwzijDOYaaGJvJSX(TveOTOXq(yAgjPyc9(YMujCfC3R7nSi2MQfLG(N8jB)2eCG3EbiKkQIqny1iBSFBfbAlAmempaH5ZRDtpAlNrhI0HC0sfp6ijvgaaCgDishYDDSfH1T31XgNrhI0HCkQLVjIkRmZijvgaaCgDishYfBYiokb5ssY6276yJN6qt6nPsmnxqCkQLVjIkRmKKouzaaWbEl9fkYiUT3K4JPzr2xdlBxanjrqMiBsLWLVVgw2U4EmQCCYNS9BtWbE7fGqQOkc14EDVHfX2unW8ae0L0pv8i3jkSuSPIhJuRYaaGRlnW64fGqQOak10qkFmfz(8A30J2Yz0HiDihTuXJossw3ExhBCgDishYPOw(MiQeZvF5olY8A30J2YXQr2y)2kc0w0yihTuXJosY5SU9Uo24y1iBSFBfbAlAmKtrT8nbyHeZvfO2tuzQJrAuWMKCtQeU891WY2f3JGxoMnlY8A30J2YbEl9fkYiUT3K4OLkE0rsY6276yJd8w6luKrCBVjXPOw(MaSqI5Qcu7jQm1XinkypJKumHEFztQeUcU719gweBt1Isq)iZ30J2Yb1EIkPo0KqkhTuXJUiSU9Uo24GAprLuhAsiLtrT8nb4LyU6lxssLbaaNrhI0H8XueLbaaNrhI0HCXMmIbVSYmB2jFY2Vnbh4TxacPIQiuZIAt(Kkk6qQ7zlyEacZRDtpAlNrhI0HC0sfp6ijzD7DDSXz0HiDiNIA5BIOsmx9L7SiZRDtpAlhRgzJ9BRiqBrJHC0sfp6ijNZ6276yJJvJSX(TveOTOXqof1Y3eGfsmxvGAprLPogPrbBsYnPs4Y3xdlBxCpcE5y2SiZRDtpAlh4T0xOiJ42EtIJwQ4rhjjRBVRJnoWBPVqrgXT9MeNIA5BcWcjMRkqTNOYuhJ0OG9SiZRL16qlTLBiJ2(M64OLkE0rsY6276yJRlnW64fGqQOak10qkNIA5BIOsm3msYn9OTCqTNOsQdnjKYrlv8OlcRBVRJnoO2tuj1HMes5uulFtaEjMR(YLKuzaaWb1EIkPo0KqkFmrsQmaa4m6qKoKpMIOmaa4m6qKoKl2Krm4LvgssLbaaxxAG1XlaHurbuQPHu(y6K)GN8jB)2eCj0qAUnvqGLEFjz73wX)IfmwQHeaE7fGqQampabqTNOYuhJucGJKuzaaWb1EIkPo0KqkFmrs6qLbaah4T0xOiJ42EtIpMijDOYaaGJvJSX(TveOTOXq(y6Kpz73MGlHgsZTPIQiuJ719gw227bZdqOwhQmaa41B4K0qB5JPiZRLMVRG6qB5PZj4y1VyfKK08DfuhAlpDob)TOYvMzrMdQ9evM6yKcEc6tscQ9evM6yKcEcviYCw3ExhBCfF6WsduQ3qSpd5uulFtevI5QV(KKZDOYaaGJvJSX(TveOTOXq(yIKCtQeU891WY2f3JGxoMrs6qLbaah4T0xOiJ42EtIpMMnlY8A30J2YbEl9fkYiUT3K4OLkE0rsY6276yJd8w6luKrCBVjXPOw(MiQeZvFzLzwK51UPhTLJvJSX(TveOTOXqoAPIhDKKZzD7DDSXXQr2y)2kc0w0yiNIA5BIOsmx9LvgsYnPs4Y3xdlBxCpcE5y2SiZzD7DDSXtDOj9MujMMliof1Y3erLHKK1T31XgNrhI0HCkQLVjIkZSt(KTFBcUeAin3MkQIqnXjXyPbkPaekaZdqyoO2tuzQJrkbzijb1EIktDmsbpb9JmN1T31XgxXNoS0aL6ne7Zqof1Y3erLyU6Rpj5ChQmaa4y1iBSFBfbAlAmKpMij3KkHlFFnSSDX9i4LJzKKouzaaWbEl9fkYiUT3K4JPzZImVwA(UcQdTLNoNGJv)IvqssZ3vqDOT805e83IQVmZImV2n9OTCSAKn2VTIaTfngYrlv8OJKK1T31XghRgzJ9BRiqBrJHCkQLVjIkl4MfzETB6rB5aVL(cfze32BsC0sfp6ijzD7DDSXbEl9fkYiUT3K4uulFtevwWnlYCw3ExhB8uhAsVjvIP5cItrT8nruzijzD7DDSXz0HiDiNIA5BIOYm7Kpz73MGlHgsZTPIQiuJIpDyPbk1Bi2NHG5biaQ9evM6yKcEcYnYME0wownYg73wrG2Igd5OLkE0fzUdvgaaCSAKn2VTIaTfngYhtKKSU9Uo24y1iBSFBfbAlAmKtrT8nbbzMDYNS9BtWLqdP52urveQbuQPH0sduIP5c6Kpz73MGlHgsZTPIQiuJIpDyPbk1Bi2NHG5biaQ9evM6yKcEcY9Kpz73MGlHgsZTPIQiut9gojn0wW8aeQ1HkdaaE9gojn0w(y6Kpz73MGlHgsZTPIQiudl9(sY2VTI)flySudja82laHubyEacZ3KkHlheM(feFITGNG(YqsQmaa4Po0KEtQetZfeFmrsQmaa4m6qKoKpMijvgaaCuBIikMwzQJrkFmn7Kpz73MGlHgsZTPIQiudJoePdPfXsFIrW8aeyD7DDSXz0HiDiTiw6tmYzGsQekka0KTFBPpkbz5Gn4Imhu7jQm1Xif8e0NKeu7jQm1Xif8eKBew3ExhBCfF6WsduQ3qSpd5uulFtevI5QV(KKGAprLPogPeQqew3ExhBCfF6WsduQ3qSpd5uulFtevI5QV(ryD7DDSXR3WjPH2YPOw(MiQeZvF9NDYNS9BtWLqdP52urveQH1Maz0C)2aZdqOwwBcKrZ9BJpMIiMqVVSjvcxb396EdlITPArjO)jFY2VnbxcnKMBtfvrOgw69LKTFBf)lwWyPgsa4TxacPIt(KTFBcUeAin3MkQIqnS2eiJM73gyEac1YAtGmAUFB8X0jFY2VnbxcnKMBtfvrOggDishslIL(eJN8jB)2eCj0qAUnvufHAsklnSSnLI2EYNS9BtWLqdP52urveQH1Maz0C)2aZdqyFnSSDb0KuujMlOQdPIVTqL6lJ(YiR(YaUGACsT3Kebv5mLZUISYk(kLZOI4Ghupq4bFTPMUheOPhSIc82laHurf9GueSoEk6oOO1WdMJT1YfDhKbknjuWp5LtEdpi4QioiyzB6q6IUdQ(AGLhuqKTz1heS4GBFq5KrEq3R7fFBhSNqAUn9GZRz2bNRF1Z4N8YjVHhSIvrCqWY20H0fDhu91alpOGiBZQpiyXb3(GYjJ8GUx3l(2oypH0CB6bNxZSdox)QNXp5LtEdpyfRI4GGLTPdPl6oyfL16qlTLlNJJwQ4rxf9GBFWkkR1HwAlxoxf9GZLT6z8t(tE9aHhSIoey5xuturpyY2VTdgNIdA9EqGEyUd(2bxqV4GV2utx(jFfV2utx0DqWDWKTFBh0)IvWp5dQ(xSIGEbvhcKd)g0luPSb9cQjB)2cQuuzqmgurlv8OluxydvQFqVGkAPIhDH6cQjB)2cQS07ljB)2k(xSbv)l2ILAyqL1T31XMiSHkLBqVGkAPIhDH6cQjB)2cQS07ljB)2k(xSbv)l2ILAyqvcnKMBtfHnSb1jkYAnLCd6fQu2GEb1KTFBb1PE)2cQOLkE0fQlSHk1pOxqnz73wqvXJcXBsLgOigAAinOIwQ4rxOUWgQuUb9cQjB)2cQkEuiEtQ0aLCSdnlOIwQ4rxOUWgQScb9cQjB)2cQkEuiEtQ0aL43wKgurlv8OluxydvcUGEb1KTFBbvfpkeVjvAGIyI(MuqfTuXJUqDHnuzflOxqnz73wqnPS0WY2ukABqfTuXJUqDHnSbvj0qAUnve0luPSb9cQOLkE0fQlOYO)I0pdQGAprLPogPhKWbb3bjjpOYaaGdQ9evsDOjHu(y6GKKh0HkdaaoWBPVqrgXT9MeFmDqsYd6qLbaahRgzJ9BRiqBrJH8Xuqnz73wqLLEFjz73wX)InO6FXwSuddQaV9cqive2qL6h0lOIwQ4rxOUGkJ(ls)mOw7bDOYaaGxVHtsdTLpMoyKdo)G1EqA(UcQdTLNoNGJv)IvCqsYdsZ3vqDOT805e83oy0dkxzo4Sdg5GZpiO2tuzQJr6bbpHdQ)bjjpiO2tuzQJr6bbpHdwHdg5GZpiRBVRJnUIpDyPbk1Bi2NHCkQLVjoy0dkXChS(hu)dssEW5h0HkdaaownYg73wrG2Igd5JPdssEWnPs4Y3xdlBxCpEqWFq54GZoij5bDOYaaGd8w6luKrCBVjXhthC2bNDWihC(bR9GB6rB5aVL(cfze32BsC0sfp6oij5bzD7DDSXbEl9fkYiUT3K4uulFtCWOhuI5oy9pOSYCWzhmYbNFWAp4ME0wownYg73wrG2Igd5OLkE0DqsYdo)GSU9Uo24y1iBSFBfbAlAmKtrT8nXbJEqjM7G1)GYkZbjjp4MujC57RHLTlUhpi4pOCCWzhC2bJCW5hK1T31Xgp1HM0BsLyAUG4uulFtCWOhuMdssEqw3ExhBCgDishYPOw(M4GrpOmhCwqnz73wq196EdlB79HnuPCd6furlv8OluxqLr)fPFguNFqqTNOYuhJ0ds4GYCqsYdcQ9evM6yKEqWt4G6FWihC(bzD7DDSXv8PdlnqPEdX(mKtrT8nXbJEqjM7G1)G6FqsYdo)GouzaaWXQr2y)2kc0w0yiFmDqsYdUjvcx((Ayz7I7Xdc(dkhhC2bjjpOdvgaaCG3sFHImIB7nj(y6GZo4Sdg5GZpyThKMVRG6qB5PZj4y1VyfhKK8G08DfuhAlpDob)Tdg9G6lZbNDWihC(bR9GB6rB5y1iBSFBfbAlAmKJwQ4r3bjjpiRBVRJnownYg73wrG2Igd5uulFtCWOhuwWDWzhmYbNFWAp4ME0woWBPVqrgXT9MehTuXJUdssEqw3ExhBCG3sFHImIB7njof1Y3ehm6bLfChC2bJCW5hK1T31Xgp1HM0BsLyAUG4uulFtCWOhuMdssEqw3ExhBCgDishYPOw(M4GrpOmhCwqnz73wqnojglnqjfGqrydvwHGEbv0sfp6c1fuz0Fr6NbvqTNOYuhJ0dcEchuUhmYb30J2YXQr2y)2kc0w0yihTuXJUdg5GZpOdvgaaCSAKn2VTIaTfngYhthKK8GSU9Uo24y1iBSFBfbAlAmKtrT8nXbjCqzo4SGAY2VTGQIpDyPbk1Bi2NHHnuj4c6fut2(TfubLAAiT0aLyAUGcQOLkE0fQlSHkRyb9cQOLkE0fQlOYO)I0pdQGAprLPogPhe8eoOCdQjB)2cQk(0HLgOuVHyFgg2qLGDqVGkAPIhDH6cQm6Vi9ZGATh0HkdaaE9gojn0w(ykOMS9BlOwVHtsdTnSHkLJGEbv0sfp6c1fuz0Fr6Nb15hCtQeUCqy6xq8j2EqWt4G6lZbjjpOYaaGN6qt6nPsmnxq8X0bjjpOYaaGZOdr6q(y6GKKhuzaaWrTjIOyALPogP8X0bNfut2(TfuzP3xs2(Tv8VydQ(xSfl1WGkWBVaesfHnuzfxqVGkAPIhDH6cQm6Vi9ZGkRBVRJnoJoePdPfXsFIrodusLqrbGMS9Bl9hmkHdklhSb3bJCW5heu7jQm1Xi9GGNWb1)GKKheu7jQm1Xi9GGNWbL7bJCqw3ExhBCfF6WsduQ3qSpd5uulFtCWOhuI5oy9pO(hKK8GGAprLPogPhKWbRWbJCqw3ExhBCfF6WsduQ3qSpd5uulFtCWOhuI5oy9pO(hmYbzD7DDSXR3WjPH2YPOw(M4GrpOeZDW6Fq9p4SGAY2VTGkJoePdPfXsFIXWgQuwzc6furlv8OluxqLr)fPFguR9GS2eiJM73gFmDWihumHEFztQeUcU719gweBt1oyuchu)GAY2VTGkRnbYO5(Tf2qLYkBqVGkAPIhDH6cQjB)2cQS07ljB)2k(xSbv)l2ILAyqf4TxacPIWgQuw9d6furlv8OluxqLr)fPFguR9GS2eiJM73gFmfut2(TfuzTjqgn3VTWgQuw5g0lOMS9BlOYOdr6qArS0NymOIwQ4rxOUWgQu2ke0lOMS9BlOMuwAyzBkfTnOIwQ4rxOUWgQuwWf0lOIwQ4rxOUGkJ(ls)mOUVgw2UaAs6GrpOeZfut2(TfuzTjqgn3VTWg2GkWBVaesfb9cvkBqVGkAPIhDH6cQ9uqvGBqnz73wqvxs)uXJbvDPFGbvXe69LnPs4k4Ux3ByrSnv7GrjCq9pij5bvgaaCuBIikMwzQJrkFmDWih0HkdaaE9gojn0wURJTdg5GkdaaU719gwMg0PwGCxhBbvDjTyPgguDIclfBQ4XWgQu)GEbv0sfp6c1fuz0Fr6Nb15hC(bR9GB6rB5m6qKoKJwQ4r3bJCW5hK1T31Xgp1HM0BsLyAUG4uulFtCWOhuFWDqsYdY6276yJN6qt6nPsmnxqCkQLVjoiHdkZbNDWzhKK8GZp4ME0wownYg73wrG2Igd5OLkE0DWihCtpAlh4T0xOiJ42EtIJwQ4r3bNDqsYdo)GkdaaoJoePd5JPdssEqw3ExhBCgDishYPOw(M4GrpO(G7GZo4Sdg5GZpyThCtpAlh4T0xOiJ42EtIJwQ4r3bjjpiRBVRJnoWBPVqrgXT9MeNIA5BIdc(dkhhC2bJCW5hS2dUPhTLJvJSX(TveOTOXqoAPIhDhKK8GSU9Uo24y1iBSFBfbAlAmKtrT8nXbb)bLJdo7Gro4(Ayz7cOjPds4GYeut2(TfufinNa9AHnuPCd6furlv8OluxqLr)fPFguNFWAp4ME0woWBPVqrgXT9MehTuXJUdssEqw3ExhBCG3sFHImIB7njof1Y3ehm6bLyUdw)dkRmhKK8GouzaaWbEl9fkYiUT3K4JPdo7Gro48dw7b30J2YXQr2y)2kc0w0yihTuXJUdssEqw3ExhBCSAKn2VTIaTfngYPOw(M4GrpOeZDW6FqzL5GKKh0HkdaaownYg73wrG2Igd5JPdo7GKKhumHEFztQeUcU719gweBt1oyuchu)GAY2VTGQU0aRJxacPIcOutdPHnuzfc6furlv8OluxqLr)fPFguNFW5hS2dUPhTLZOdr6qoAPIhDhKK8GkdaaoJoePd5Uo2oyKdY6276yJZOdr6qof1Y3ehm6bLvMdo7GKKhuzaaWz0HiDixSjJ4dgLWbL7bjjpiRBVRJnEQdnP3KkX0CbXPOw(M4GrpOSYCqsYd6qLbaah4T0xOiJ42EtIpMo4Sdg5G7RHLTlGMKoiHdkZbJCWnPs4Y3xdlBxCpEWOhuocQjB)2cQy1iBSFBfbAlAmmSHkbxqVGkAPIhDH6cQm6Vi9ZGQUK(PIh5orHLInv84bJCWApOYaaGRlnW64fGqQOak10qkFmDWihC(bNFWAp4ME0woJoePd5OLkE0DqsYdY6276yJZOdr6qof1Y3ehm6bLyUdw)dk3do7Gro48dw7b30J2YXQr2y)2kc0w0yihTuXJUdssEW5hK1T31XghRgzJ9BRiqBrJHCkQLVjoynhuI5oyvheu7jQm1Xi9GrpiyFqsYdUjvcx((Ayz7I7Xdc(dkhhC2bNDWihC(bR9GB6rB5aVL(cfze32BsC0sfp6oij5bzD7DDSXbEl9fkYiUT3K4uulFtCWAoOeZDWQoiO2tuzQJr6bJEqW(GZoij5bftO3x2KkHRG7EDVHfX2uTdgLWb1)Gro48dUPhTLdQ9evsDOjHuoAPIhDhmYbzD7DDSXb1EIkPo0KqkNIA5BIdc(dkXChS(huUhKK8GkdaaoJoePd5JPdg5GkdaaoJoePd5InzeFqWFqzL5GZo4SGAY2VTGQ719gweBt1cBOYkwqVGkAPIhDH6cQm6Vi9ZG68dw7b30J2Yz0HiDihTuXJUdssEqw3ExhBCgDishYPOw(M4GrpOeZDW6Fq5EWzhmYbNFWAp4ME0wownYg73wrG2Igd5OLkE0DqsYdo)GSU9Uo24y1iBSFBfbAlAmKtrT8nXbR5Gsm3bR6GGAprLPogPhm6bb7dssEWnPs4Y3xdlBxCpEqWFq54GZo4Sdg5GZpyThCtpAlh4T0xOiJ42EtIJwQ4r3bjjpiRBVRJnoWBPVqrgXT9MeNIA5BIdwZbLyUdw1bb1EIktDmspy0dc2hC2bJCW5hS2dYADOL2YnKrBFtDhKK8GSU9Uo246sdSoEbiKkkGsnnKYPOw(M4GrpOeZDWzhKK8GB6rB5GAprLuhAsiLJwQ4r3bJCqw3ExhBCqTNOsQdnjKYPOw(M4GG)Gsm3bR)bL7bjjpOYaaGdQ9evsDOjHu(y6GKKhuzaaWz0HiDiFmDWihuzaaWz0HiDixSjJ4dc(dkRmhKK8GkdaaUU0aRJxacPIcOutdP8Xuqnz73wqDrTjFsffDi19SnSHnOY6276yte0luPSb9cQOLkE0fQlOYO)I0pdQZpOYaaGR4725hILtXKThKK8GkdaaEQdnP3KkX0CbXhthmYbvgaa8uhAsVjvIP5cItrT8nXbJEqzLJdssEqLbaaNrhI0H8X0bJCqLbaaNrhI0HCkQLVjoi4pO(G7GZcQjB)2cQt9(Tf2qL6h0lOIwQ4rxOUGkJ(ls)mOkMqVVSjvcxb3)sGwrPEdNKgA7bJs4G6FqsYdo)G1EqA(UcQdTLNoNGJv)IvCqsYdsZ3vqDOT805e83oy0dc2G7GZcQjB)2cQ(xc0kk1B4K0qBdBOs5g0lOIwQ4rxOUGkJ(ls)mOQmaa4Po0KEtQetZfeFmDqsYdQmaa4m6qKoKpMoyKdQmaa4m6qKoKl2Kr8bjCqzLjOMS9BlOc8uuX3TlSHkRqqVGAY2VTGQa0JExPbk6qtctJHbv0sfp6c1f2qLGlOxqnz73wqvXJcXBsLgOigAAinOIwQ4rxOUWgQSIf0lOMS9BlOQ4rH4nPsduYXo0SGkAPIhDH6cBOsWoOxqnz73wqvXJcXBsLgOe)2I0GkAPIhDH6cBOs5iOxqnz73wqvXJcXBsLgOiMOVjfurlv8OluxydvwXf0lOIwQ4rxOUGAY2VTG6BcgDSPIhlG1rA7qR4qDpddQm6Vi9ZGQYaaGN6qt6nPsmnxq8X0bjjpOYaaGZOdr6q(y6GroOYaaGZOdr6qUytgXhmkHdkRmhKK8GSU9Uo24Po0KEtQetZfeNIA5BIdg9GvaChKK8GSU9Uo24m6qKoKtrT8nXbJEWkaUGQLAyq9nbJo2uXJfW6iTDOvCOUNHHnuPSYe0lOIwQ4rxOUGAY2VTGARdPXGqV2BsLPogPfgLiXM(GkJ(ls)mOQmaa4Po0KEtQetZfeFmDqsYdQmaa4m6qKoKpMoyKdQmaa4m6qKoKl2Kr8bJs4GYktq1snmO26qAmi0R9MuzQJrAHrjsSPpSHkLv2GEbv0sfp6c1fut2(TfuDjLyTUTIdzex010K9lrbvg9xK(zqvzaaWtDOj9MujMMli(y6GKKhuzaaWz0HiDiFmDWihuzaaWz0HiDixSjJ4dgLWbLvMGQLAyq1LuI162koKrCrxtt2Vef2qLYQFqVGkAPIhDH6cQjB)2cQAjlvOyracXTOneplOYO)I0pdQkdaaEQdnP3KkX0CbXhthKK8GkdaaoJoePd5JPdg5GkdaaoJoePd5InzeFWOeoOSYeuTuddQAjlvOyracXTOneplSHkLvUb9cQOLkE0fQlOAPgguDumDapfl6qHa9b1KTFBbvhfthWtXIouiqFydvkBfc6furlv8Oluxq1snmOkiE4jgPIs8Bsb1KTFBbvbXdpXivuIFtkSHkLfCb9cQOLkE0fQlOAPgguLOVwH1oS6GAY2VTGQe91kS2Hvh2qLYwXc6furlv8Oluxq1snmOQHAnLOsduMsXweVjcQjB)2cQAOwtjQ0aLPuSfXBIWgQuwWoOxqfTuXJUqDbvl1WGQykPyrdZTaQBIdQjB)2cQIPKIfnm3cOUjoSHkLvoc6furlv8Oluxqnz73wqv8gWWxK8P7ZTPIIs6KWsduaqAZ(LOGkJ(ls)mOQmaa4Po0KEtQetZfeFmDqsYdQmaa4m6qKoKpMoyKdQmaa4m6qKoKl2Kr8bJs4GYkZbjjpiRBVRJnEQdnP3KkX0CbXPOw(M4Grpyfa3bjjpiRBVRJnoJoePd5uulFtCWOhScGlOAPggufVbm8fjF6(CBQOOKojS0afaK2SFjkSHkLTIlOxqfTuXJUqDb1KTFBbvXBadFjftpnTvuusNewAGcasB2Vefuz0Fr6NbvLbaap1HM0BsLyAUG4JPdssEqLbaaNrhI0H8X0bJCqLbaaNrhI0HCXMmIpyuchuwzoij5bzD7DDSXtDOj9MujMMliof1Y3ehm6bRa4oij5bzD7DDSXz0HiDiNIA5BIdg9GvaCbvl1WGQ4nGHVKIPNM2kkkPtclnqbaPn7xIcBOs9LjOxqfTuXJUqDbvg9xK(zqD(bb1EIktDmspyuchSchmYb3xdpi4pi4oij5bb1EIktDmspyuchuUhmYb3xdpy0dcUdssEWn9OTCqTNOsQdnjKYrlv8O7GroiRBVRJnoO2tuj1HMes5uulFtCqchuMdo7Gro48dw7b30J2YfinNa9AC0sfp6oij5bzD7DDSXfinNa9ACkQLVjoy0dkZbNfut2(TfutDOj9MujMMlOWgQuFzd6furlv8OluxqLr)fPFguNFqqTNOYuhJ0dgLWbRWbJCW91Wdc(dcUdssEqqTNOYuhJ0dgLWbL7bJCW91Wdg9GG7GKKhCtpAlhu7jQK6qtcPC0sfp6oyKdY6276yJdQ9evsDOjHuof1Y3ehKWbL5GZcQjB)2cQm6qKomSHk1x)GEb1KTFBb1uacTcO0774GkAPIhDH6cBOs9LBqVGkAPIhDH6cQm6Vi9ZG6(Ayz7cOjPds4GYCWihC(bNFqLbaap1HM0BsLyAUG4JPdssEqLbaaNrhI0H8X0bNDqsYdo)GkdaaEQdnP3KkX0CbXDDSDWihK1T31Xgp1HM0BsLyAUG4uulFtCWOhScYCqsYdQmaa4m6qKoK76y7GroiRBVRJnoJoePd5uulFtCWOhScYCWzhCwqnz73wqfu7jQK6qtcPHnuP(viOxqfTuXJUqDbvg9xK(zqfu7jQm1Xi9GrjCq5EWihK1T31Xgp1HM0BsLyAUG4uulFtCWOhuI5oyKdUVgw2UaAs6GeoOmhmYbNFWAp4ME0wUaP5eOxJJwQ4r3bjjpOYaaGlqAob614JPdolOMS9BlOc8w6luKrCBVjf2Wg2GAowqnnOQ(AGLHnSHaa]] )


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
