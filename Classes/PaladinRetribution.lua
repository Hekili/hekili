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


    spec:RegisterPack( "Retribution", 20201205, [[dCuo9aqiPs9iuGytcXNqbKrHICkuuRIivVsQWSeQAxe(LurdtPQJreTmIKNHcAAePCnLkTnHuY3esrJdfiDoHukRtif08Kk5Esv7tOCquGsTqHkpefOKjkKcCruav(ikGQojkGYkPqMjkqr7uizOOavwQqk0tjXuPq9vuGcJffOQ9sQ)kYGr6Wswmr9yunzbxgAZk5ZK0OvkNwvRwivVMimBkDBkA3u9Bfdxkookalh0ZrmDvUUO2of8DP04vQ48OqRxiLQ5Js7hyTKAJ1kH6qDusTxQ9sk1(DfskLu7LskTYXydQvAkUeLkQv8Ye1krJ4bF589JRvAkgTtf0gRvitgYrTIwro)2JbMRL1kH6qDusTxQ9sk1(DfskLu73hT0kKgKRJkAUxRS9Ha6AzTsajCTcdcGgnIh8LZ3poGYGRSv4DGrmiaA0aKJMYieq3nEavQ9sTxR0aN1BrTcdcGgnIh8LZ3poGYGRSv4DGrmiaA0aKJMYieq3nEavQ9sThyeWOIF)4erde5JPCD9nZ9JdmQ43por0ar(ykxxh9DkBrc5D10SsKSPjcbgv87hNiAGiFmLRRJ(oLTiH8UAAwPkFzthyuXVFCIObI8XuUUo67u2IeY7QPzLAF)qiWOIF)4erde5JPCDD03PSfjK3vtZkrAGVRcmQ43por0ar(ykxxh9DwqE5y6gie9dyeGcmIbbqzGBhKNpmaOObeYiGEVjcO3gcOf)giG(eaTmuVTKTOayuXVFCspeLZsGaJk(9Jt6OVtEzTPIF)4j7tU49Ye75ZydtRtagv87hN0rFN8YAtf)(Xt2NCX7Lj2RIocRBGeGrakWOIF)4ebFgByADsFZC)4X)REMKZRLq2otWMjNaIf)yzLZRLOmGU67QPwyDBICte58AjkdOR(UAQfw3MaIM17KysYGYYkNxlbhMjvaf5MiY51sWHzsfqbenR3jDj1UmdmQ43porWNXgMwN0rFN2xD7iPONdQMOFX)REsdATPRGQ4re2xD7iPONdQMOFX6LILLPUH1hsOb0prfcebUZtocllS(qcnG(jQqGiEpw0CxMbgv87hNi4ZydtRt6OVZ1drz7mH4)vVCETeLb0vFxn1cRBtKByzLZRLGdZKkGICte58Aj4WmPcOGCfxIEj3dmQ43porWNXgMwN0rFNKThTH0SsgqxflNJaJk(9Jte8zSHP1jD03PSfjK3vtZkrYMMieyuXVFCIGpJnmToPJ(oLTiH8UAAwPkFzthyuXVFCIGpJnmToPJ(oLTiH8UAAwP23pecmQ43porWNXgMwN0rFNYwKqExnnRePb(UkWOIF)4ebFgByADsh9DMjy6p0mEVmXEIezReiKKAFxfyuXVFCIGpJnmToPJ(oZem9hAgVxMyVzXlziMiBiEjZm55X)RE58AjkdOR(UAQfw3Mi3WYkNxlbhMjvaf5MiY51sWHzsfqb5kUeX6LCpWOIF)4ebFgByADsh9DMjy6p0mEVmXEt0CGmMMvQPixI8obyuXVFCIGpJnmToPJ(oZem9hAgVxMyFaIvy9qmzaje0cmQ43porWNXgMwN0rFNzcM(dnJ3ltSpuqjmNXtbKlrYWal(Fmg)V6LZRLOmGU67QPwyDBICdlRCETeCyMubuKBIiNxlbhMjvafKR4seRxY9aJk(9Jte8zSHP1jD03zMGP)qZ49Ye7hdiSDdTMVRMAMweM4qgjxzJ)x9Y51sugqx9D1ulSUnrUHLvoVwcomtQakYnrKZRLGdZKkGcYvCjI1l5EGrf)(Xjc(m2W06Ko67mtW0FOz8EzI9KMcIjtSU02msamQ43porWNXgMwN0rFNzcM(dnJ3ltSxf(Mj(eWDagv87hNi4ZydtRt6OVZmbt)HMX7Lj2)oHdZxjBXedix(Lntb0WZX4)vVCETeLb0vFxn1cRBtKByzLZRLGdZKkGICte58Aj4WmPcOGCfxIy9sUNLLpJnmTUOmGU67QPwyDBciAwVtIjTDzz5ZydtRl4WmPcOaIM17KysBxGrf)(Xjc(m2W06Ko67mtW0FOz8EzI9K3xzBs1wHVUbssYvqftZkTq4W)JX4)vVCETeLb0vFxn1cRBtKByzLZRLGdZKkGICte58Aj4WmPcOGCfxIy9sUNLLpJnmTUOmGU67QPwyDBciAwVtIjTDzz5ZydtRl4WmPcOaIM17KysBxGrf)(Xjc(m2W06Ko67mtW0FOz8EzI9fzZq5ijbRO9bM4dSSX)REMKZRLOmGU67QPwyDBICdlRCETeCyMubuKBygyuXVFCIGpJnmToPJ(oZem9hAsI)x9Y51sugqx9D1ulSUnrUHLvoVwcomtQakYnrKZRLGdZKkGcYvCjI1l5EGrf)(Xjc(m2W06Ko67SmGU67QPwyDBX)REM2glJPMPfHX6LwK7nXU2LLDBSmMAMwegRNHrU3eJTll7vw0pX2yzmvgqxfHc0lzlgIWNXgMwxSnwgtLb0vrOaIM17K(9mh5EtmDtARrTFpWOIF)4ebFgByADsh9DYHzsfW4)vptBJLXuZ0IWy9slY9Myx7YYUnwgtntlcJ1ZWi3BIX2LL9kl6NyBSmMkdORIqb6LSfdr4ZydtRl2glJPYa6QiuarZ6Ds)EMJCVjMUjT1O2VhyuXVFCIGpJnmToPJ(olYg6PTYANwGrf)(Xjc(m2W06Ko67CBSmMkdORIW4)v)9My6M0wJA)(imXKCETeLb0vFxn1cRBtKByzLZRLGdZKkGICdZSSmjNxlrzaD13vtTW62eHP1JWNXgMwxugqx9D1ulSUnbenR3jXK2Eww58Aj4WmPcOimTEe(m2W06comtQakGOz9ojM02ZmZaJk(9Jte8zSHP1jD03569YMGixIXFxn(F1VnwgtntlcJ1ZWi8zSHP1fLb0vFxn1cRBtarZ6DsmvEiY9My6M0wJA)(im19vw0pbbHvZ2BkqVKTyGLvoVwcccRMT3uKBygyeGcmQ43porSE)jBiK0rFNgk4xYwmEVmX(ajXlYvYwmEdLnJ9Kg0AtxbvXJicVH3Xe5gOzSEPyzLZRLanByeILNAMwekYnrcOCETerphunr)eHP1JiNxlr4n8oMAYWMHGIW06SSKg0AtxbvXJicVH3Xe5gOzSEPIiNxlbhMjvaf5MiY51sWHzsfqb5kUeDj5EGrf)(XjI17pzdHKo67KGWQz7nJ)x9mXu3xzr)eCyMubuGEjBXqe58AjkdOR(UAQfw3Mi3WYYNXgMwxugqx9D1ulSUnbenR3jXKAxMzzzsoVwcomtQakYnSS8zSHP1fCyMubuarZ6DsmP2LzMJWu3xzr)eR3lBcICjg)Dvb6LSfdSS8zSHP1fR3lBcICjg)DvbenR3jDj5EMJWu3xzr)e4oipF)4jc6h6CuGEjBXallFgByADbUdYZ3pEIG(Hohfq0SEN0LK7zoY9My6M0wJA)EGrf)(XjI17pzdHKo670q5mG8t2qijTvMMim(F1Zu3xzr)eR3lBcICjg)Dvb6LSfdSS8zSHP1fR3lBcICjg)DvbenR3jXu5bPl5Ew2akNxlX69YMGixIXFxvKByoctDFLf9tG7G889JNiOFOZrb6LSfdSS8zSHP1f4oipF)4jc6h6CuarZ6DsmvEq6sUNLnGY51sG7G889JNiOFOZrrUHzwwsdATPRGQ4reH3W7yICd0mwVuaJk(9JteR3FYgcjD03jUdYZ3pEIG(HohJ)x9Kg0AtxbvXJicVH3Xe5gOzx9mmctm19vw0pbhMjvafOxYwmWYkNxlbhMjvafHP1JWNXgMwxWHzsfqbenR3jXKCpZSSY51sWHzsfqb5kUeX6zillFgByADrzaD13vtTW62eq0SENetY9SSbuoVwI17LnbrUeJ)UQi3WCK7nX0nPTg1(9aJk(9JteR3FYgcjD03z4n8oMi3anJ)x9gk4xYwueijErUs2Ir6woVwcdLZaYpzdHK0wzAIqrUjctm19vw0pbhMjvafOxYwmWYYNXgMwxWHzsfqbenR3jXu5bPZqMJWu3xzr)e4oipF)4jc6h6CuGEjBXallFgByADbUdYZ3pEIG(Hohfq0SENetLhKodzzjnO1MUcQIhreEdVJjYnqZy9mKzwwsdATPRGQ4reH3W7yICd0mwVury6kl6NyBSmMkdORIqb6LSfdr4ZydtRl2glJPYa6QiuarZ6DsxQ8G0zilRCETeCyMubuKBIiNxlbhMjvafKR4s0LK7zMzGrf)(XjI17pzdHKo678qZgBbjjdim88l(F1Zu3xzr)eCyMubuGEjBXallFgByADbhMjvafq0SENetLhKodzoctDFLf9tG7G889JNiOFOZrb6LSfdSS8zSHP1f4oipF)4jc6h6CuarZ6DsmvEq6mmcPbT20vqv8iIWB4DmrUbA2vpdzoctDZhdOx(jCKdh7adc0lzlgyz5ZydtRlmuodi)KnessBLPjcfq0SENetLhyML9kl6NyBSmMkdORIqb6LSfdr4ZydtRl2glJPYa6QiuarZ6DsxQ8G0zilRCETeBJLXuzaDvekYnSSY51sWHzsfqrUjICETeCyMubuqUIlrxsUNLvoVwcdLZaYpzdHK0wzAIqrUbyeGcmQ43porOIocRBGKo67KxwBQ43pEY(KlEVmX(17pzdHK4)v)2yzm1mTimw)USSY51sSnwgtLb0vrOi3WYgq58AjwVx2ee5sm(7QICdlBaLZRLa3b557hprq)qNJICdWOIF)4eHk6iSUbs6OVZWB4DmDJ1g)V67oGY51se9Cq1e9tKBIWu3W6dj0a6NOcbIa35jhHLfwFiHgq)eviqeVhJH7zoctBJLXuZ0IWU6LILDBSmMAMwe2vV0IWeFgByADHSTcyAwPONj3ZrbenR3jXu5bPlflBaLZRLa3b557hprq)qNJICdlBaLZRLy9EztqKlX4VRkYnmZCeM6(kl6Ny9EztqKlX4VRkqVKTyGLLpJnmTUy9EztqKlX4VRkGOz9ojMkpiDj3ZCeM6(kl6Na3b557hprq)qNJc0lzlgyz5ZydtRlWDqE((Xte0p05OaIM17KyQ8G0LCpZaJk(9JteQOJW6giPJ(oBljW0SsfzdjX)REM2glJPMPfH97zz3glJPMPfHD1lveM4ZydtRlKTvatZkf9m5EokGOz9ojMkpiDPyzdOCETe4oipF)4jc6h6CuKByzdOCETeR3lBcICjg)DvrUHzMJWu3W6dj0a6NOcbIa35jhHLfwFiHgq)eviqeVhtQ9mhHPUVYI(jWDqE((Xte0p05Oa9s2Ibww(m2W06cChKNVF8eb9dDokGOz9ojMK7YCeM6(kl6Ny9EztqKlX4VRkqVKTyGLLpJnmTUy9EztqKlX4VRkGOz9ojMK7YmWOIF)4eHk6iSUbs6OVZTY0eHPzLAH1Tf)V63glJPMPfHD1lnGrf)(Xjcv0ryDdK0rFNY2kGPzLIEMCphJ)x9BJLXuZ0IWU6ziWOIF)4eHk6iSUbs6OVZONdQMOFX)R(UdOCETerphunr)e5MimTnwgtntlc7Qxkw2TXYyQzAryx9slcFgByADHSTcyAwPONj3ZrbenR3jXu5bPlfZaJk(9JteQOJW6giPJ(o5L1Mk(9JNSp5I3ltSF9(t2qij(F1Z0vqv8eByzVnrd)6QxQ9SSY51sugqx9D1ulSUnrUHLvoVwcomtQakYnSSY51sGMnmcXYtntlcf5gMbgv87hNiurhH1nqsh9DYHzsfqyICWxcm(F1ZNXgMwxWHzsfqyICWxcuW3kOksslyXVF8YgRxsr0C3imTnwgtntlc7Qxkw2TXYyQzAryx9mmcFgByADHSTcyAwPONj3ZrbenR3jXu5bPlfl72yzm1mTiSxAr4ZydtRlKTvatZkf9m5EokGOz9ojMkpiDPIWNXgMwxe9Cq1e9tarZ6DsmvEq6sXmWOIF)4eHk6iSUbs6OVtEzTPIF)4j7tU49Ye7xV)Knesagv87hNiurhH1nqsh9DYhNGCyD)4X)R(U5JtqoSUFCrUbyuXVFCIqfDew3ajD03jhMjvaHjYbFjW4)v)2yzm1mTiSREPbmQ43porOIocRBGKo67SG8YX0nqi6x8)QFBSmMAMwe2vV0agv87hNiurhH1nqsh9DYhNGCyD)4X)R(7nX0nPTg1yQ8GwXacj)46OKAVu7LuQ9sQvAlO)UkrRWGbd2rJrXalkg4JgcOaQXBiG(Mnd8a01abugO17pzdHegiafImG8dXaGsgteqR8nM1HbaLVvUkseaJyW8DeqJwrdbugSg3acpmaOmq8Xa6LFcg8c0lzlgyGa0Baugi(ya9YpbdEgiaLjj3HzbWiGrmWmBg4HbaDxaT43poGAFYreaJ0kv(2gOwrHbKrBDduRyFYr0gRvc4QY2tBSokj1gRvk(9JRvGOCwcuRGEjBXGoo9PJskTXAf0lzlg0XPvk(9JRv4L1Mk(9JNSp50k2NCjVmrTcFgByADI(0rXqTXAf0lzlg0XPvk(9JRv4L1Mk(9JNSp50k2NCjVmrTIk6iSUbs0N(0knqKpMY1PnwhLKAJ1kf)(X1knZ9JRvqVKTyqhN(0rjL2yTsXVFCTISfjK3vtZkrYMMiuRGEjBXGoo9PJIHAJ1kf)(X1kYwKqExnnRuLVSPRvqVKTyqhN(0rjnTXALIF)4AfzlsiVRMMvQ99dHAf0lzlg0XPpDu7QnwRu87hxRiBrc5D10SsKg47QAf0lzlg0XPpDurlTXALIF)4ALcYlht3aHOFAf0lzlg0XPp9PvurhH1nqI2yDusQnwRGEjBXGooTch(hc)sRSnwgtntlcb0y9a6UakllGkNxlX2yzmvgqxfHICdGYYcObuoVwI17LnbrUeJ)UQi3aOSSaAaLZRLa3b557hprq)qNJICJwP43pUwHxwBQ43pEY(KtRyFYL8Ye1kR3FYgcj6thLuAJ1kOxYwmOJtRWH)HWV0kDdObuoVwIONdQMOFICdGgbqzcq7gqH1hsOb0prfcebUZtocGYYcOW6dj0a6NOcbI4DangGYW9akZaAeaLjaDBSmMAMwecOD1dOsbOSSa62yzm1mTieq7QhqLgGgbqzcq5ZydtRlKTvatZkf9m5EokGOz9obqJbOQ8aGkDavkaLLfqdOCETe4oipF)4jc6h6CuKBauwwanGY51sSEVSjiYLy83vf5gaLzaLzancGYeG2nGELf9tSEVSjiYLy83vfOxYwmaOSSakFgByADX69YMGixIXFxvarZ6DcGgdqv5bav6aQK7buMb0iaktaA3a6vw0pbUdYZ3pEIG(HohfOxYwmaOSSakFgByADbUdYZ3pEIG(Hohfq0SENaOXauvEaqLoGk5EaLzTsXVFCTs4n8oMUXA1NokgQnwRGEjBXGooTch(hc)sRWeGUnwgtntlcb0EaDpGYYcOBJLXuZ0IqaTREavkancGYeGYNXgMwxiBRaMMvk6zY9CuarZ6DcGgdqv5bav6aQuakllGgq58AjWDqE((Xte0p05Oi3aOSSaAaLZRLy9EztqKlX4VRkYnakZakZaAeaLjaTBafwFiHgq)eviqe4op5iakllGcRpKqdOFIkeiI3b0yaQu7buMb0iaktaA3a6vw0pbUdYZ3pEIG(HohfOxYwmaOSSakFgByADbUdYZ3pEIG(Hohfq0SENaOXauj3fqzgqJaOmbODdOxzr)eR3lBcICjg)Dvb6LSfdakllGYNXgMwxSEVSjiYLy83vfq0SENaOXauj3fqzwRu87hxR0wsGPzLkYgs0NokPPnwRGEjBXGooTch(hc)sRSnwgtntlcb0U6buPPvk(9JRv2ktteMMvQfw3M(0rTR2yTc6LSfd640kC4Fi8lTY2yzm1mTieq7QhqzOwP43pUwr2wbmnRu0ZK75O(0rfT0gRvqVKTyqhNwHd)dHFPv6gqdOCETerphunr)e5gancGYeGUnwgtntlcb0U6buPauwwaDBSmMAMwecOD1dOsdqJaO8zSHP1fY2kGPzLIEMCphfq0SENaOXauvEaqLoGkfGYSwP43pUwj65GQj6N(0rfn1gRvqVKTyqhNwHd)dHFPvycqVcQINydl7TjA4hG2vpGk1EaLLfqLZRLOmGU67QPwyDBICdGYYcOY51sWHzsfqrUbqzzbu58AjqZggHy5PMPfHICdGYSwP43pUwHxwBQ43pEY(KtRyFYL8Ye1kR3FYgcj6thfdQ2yTc6LSfd640kC4Fi8lTcFgByADbhMjvaHjYbFjqbFRGQijTGf)(XllGgRhqLuen3fqJaOmbOBJLXuZ0IqaTREavkaLLfq3glJPMPfHaAx9akdb0iakFgByADHSTcyAwPONj3ZrbenR3jaAmavLhauPdOsbOSSa62yzm1mTieq7buPbOrau(m2W06czBfW0SsrptUNJciAwVta0yaQkpaOshqLcqJaO8zSHP1frphunr)eq0SENaOXauvEaqLoGkfGYSwP43pUwHdZKkGWe5GVeO(0rfTPnwRGEjBXGooTsXVFCTcVS2uXVF8K9jNwX(Kl5LjQvwV)Knes0Nokj3RnwRGEjBXGooTch(hc)sR0nGYhNGCyD)4ICJwP43pUwHpob5W6(X1NokjLuBSwb9s2IbDCAfo8pe(LwzBSmMAMwecOD1dOstRu87hxRWHzsfqyICWxcuF6OKukTXAf0lzlg0XPv4W)q4xALTXYyQzAriG2vpGknTsXVFCTsb5LJPBGq0p9PJssgQnwRGEjBXGooTch(hc)sRCVjMUjT1OcOXauvEqRu87hxRWhNGCyD)46tFAL17pzdHeTX6OKuBSwb9s2IbDCALPrRqWtRu87hxRyOGFjBrTIHYMrTcPbT20vqv8iIWB4DmrUbAcOX6buPauwwavoVwc0SHriwEQzArOi3aOra0akNxlr0Zbvt0pryADancGkNxlr4n8oMAYWMHGIW06akllGsAqRnDfufpIi8gEhtKBGMaASEavkancGkNxlbhMjvaf5gancGkNxlbhMjvafKR4saODbOsUxRyOGjVmrTsGK4f5kzlQpDusPnwRGEjBXGooTch(hc)sRWeGYeG2nGELf9tWHzsfqb6LSfdaAeavoVwIYa6QVRMAH1TjYnakllGYNXgMwxugqx9D1ulSUnbenR3jaAmavQDbuMbuwwaLjavoVwcomtQakYnakllGYNXgMwxWHzsfqbenR3jaAmavQDbuMbuMb0iaktaA3a6vw0pX69YMGixIXFxvGEjBXaGYYcO8zSHP1fR3lBcICjg)DvbenR3jaAxaQK7buMb0iaktaA3a6vw0pbUdYZ3pEIG(HohfOxYwmaOSSakFgByADbUdYZ3pEIG(Hohfq0SENaODbOsUhqzgqJaO3BIPBsBnQaApGUxRu87hxRqqy1S9M6thfd1gRvqVKTyqhNwHd)dHFPvycq7gqVYI(jwVx2ee5sm(7Qc0lzlgauwwaLpJnmTUy9EztqKlX4VRkGOz9obqJbOQ8aGkDavY9akllGgq58AjwVx2ee5sm(7QICdGYmGgbqzcq7gqVYI(jWDqE((Xte0p05Oa9s2IbaLLfq5ZydtRlWDqE((Xte0p05OaIM17eangGQYdaQ0buj3dOSSaAaLZRLa3b557hprq)qNJICdGYmGYYcOKg0AtxbvXJicVH3Xe5gOjGgRhqLsRu87hxRyOCgq(jBiKK2ktteQpDustBSwb9s2IbDCAfo8pe(LwH0GwB6kOkEer4n8oMi3anb0U6bugcOrauMauMa0Ub0RSOFcomtQakqVKTyaqzzbu58Aj4WmPcOimToGgbq5ZydtRl4WmPcOaIM17eangGk5EaLzaLLfqLZRLGdZKkGcYvCja0y9akdbuwwaLpJnmTUOmGU67QPwyDBciAwVta0yaQK7buwwanGY51sSEVSjiYLy83vf5gaLzancGEVjMUjT1OcO9a6ETsXVFCTcUdYZ3pEIG(Hoh1NoQD1gRvqVKTyqhNwHd)dHFPvmuWVKTOiqs8ICLSfb0iaA3aQCETegkNbKFYgcjPTY0eHICdGgbqzcqzcq7gqVYI(j4WmPcOa9s2IbaLLfq5ZydtRl4WmPcOaIM17eangGQYdaQ0bugcOmdOrauMa0Ub0RSOFcChKNVF8eb9dDokqVKTyaqzzbu(m2W06cChKNVF8eb9dDokGOz9obqJbOQ8aGkDaLHakllGsAqRnDfufpIi8gEhtKBGMaASEaLHakZakllGsAqRnDfufpIi8gEhtKBGMaASEavkancGYeGELf9tSnwgtLb0vrOa9s2IbancGYNXgMwxSnwgtLb0vrOaIM17eaTlavLhauPdOmeqzzbu58Aj4WmPcOi3aOrau58Aj4WmPcOGCfxcaTlavY9akZakZALIF)4ALWB4DmrUbAQpDurlTXAf0lzlg0XPv4W)q4xAfMa0Ub0RSOFcomtQakqVKTyaqzzbu(m2W06comtQakGOz9obqJbOQ8aGkDaLHakZaAeaLjaTBa9kl6Na3b557hprq)qNJc0lzlgauwwaLpJnmTUa3b557hprq)qNJciAwVta0yaQkpaOshqziGgbqjnO1MUcQIhreEdVJjYnqtaTREaLHakZaAeaLjaTBaLpgqV8t4iho2bgauwwaLpJnmTUWq5mG8t2qijTvMMiuarZ6DcGgdqv5baLzaLLfqVYI(j2glJPYa6QiuGEjBXaGgbq5ZydtRl2glJPYa6QiuarZ6DcG2fGQYdaQ0bugcOSSaQCETeBJLXuzaDvekYnakllGkNxlbhMjvaf5gancGkNxlbhMjvafKR4saODbOsUhqzzbu58Ajmuodi)KnessBLPjcf5gTsXVFCTYHMn2cssgqy45N(0NwHpJnmTorBSokj1gRvqVKTyqhNwHd)dHFPvycqLZRLq2otWMjNaIf)auwwavoVwIYa6QVRMAH1TjYnaAeavoVwIYa6QVRMAH1TjGOz9obqJbOsYGcOSSaQCETeCyMubuKBa0iaQCETeCyMubuarZ6DcG2fGk1UakZALIF)4ALM5(X1NokP0gRvqVKTyqhNwHd)dHFPvinO1MUcQIhryF1TJKIEoOAI(bOX6buPauwwaLjaTBafwFiHgq)eviqe4op5iakllGcRpKqdOFIkeiI3b0yaA0CxaLzTsXVFCTI9v3osk65GQj6N(0rXqTXAf0lzlg0XPv4W)q4xAf58AjkdOR(UAQfw3Mi3aOSSaQCETeCyMubuKBa0iaQCETeCyMubuqUIlbG2dOsUxRu87hxRSEikBNjOpDustBSwP43pUwHS9OnKMvYa6Qy5CuRGEjBXGoo9PJAxTXALIF)4AfzlsiVRMMvIKnnrOwb9s2IbDC6thv0sBSwP43pUwr2IeY7QPzLQ8LnDTc6LSfd640NoQOP2yTsXVFCTISfjK3vtZk1((HqTc6LSfd640NokguTXALIF)4AfzlsiVRMMvI0aFxvRGEjBXGoo9PJkAtBSwb9s2IbDCAfVmrTcrISvcessTVRQvk(9JRvisKTsGqsQ9Dv9PJsY9AJ1kOxYwmOJtRu87hxRyw8sgIjYgIxYmtEUwHd)dHFPvKZRLOmGU67QPwyDBICdGYYcOY51sWHzsfqrUbqJaOY51sWHzsfqb5kUeaASEavY9AfVmrTIzXlziMiBiEjZm556thLKsQnwRGEjBXGooTIxMOwXenhiJPzLAkYLiVt0kf)(X1kMO5azmnRutrUe5DI(0rjPuAJ1kOxYwmOJtR4LjQvcqScRhIjdiHGwTsXVFCTsaIvy9qmzaje0QpDusYqTXAf0lzlg0XPvk(9JRvcfucZz8ua5sKmmWI)hJAfo8pe(LwroVwIYa6QVRMAH1TjYnakllGkNxlbhMjvaf5gancGkNxlbhMjvafKR4saOX6buj3Rv8Ye1kHckH5mEkGCjsggyX)Jr9PJssPPnwRGEjBXGooTsXVFCTYyaHTBO18D1uZ0IWehYi5kRwHd)dHFPvKZRLOmGU67QPwyDBICdGYYcOY51sWHzsfqrUbqJaOY51sWHzsfqb5kUeaASEavY9AfVmrTYyaHTBO18D1uZ0IWehYi5kR(0rj5UAJ1kOxYwmOJtR4LjQvinfetMyDPTzKqRu87hxRqAkiMmX6sBZiH(0rjz0sBSwb9s2IbDCAfVmrTIk8nt8jG7Ovk(9JRvuHVzIpbCh9PJsYOP2yTc6LSfd640kf)(X1kVt4W8vYwmXaYLFzZuan8CuRWH)HWV0kY51sugqx9D1ulSUnrUbqzzbu58Aj4WmPcOi3aOrau58Aj4WmPcOGCfxcanwpGk5EaLLfq5ZydtRlkdOR(UAQfw3MaIM17eangGkTDbuwwaLpJnmTUGdZKkGciAwVta0yaQ02vR4LjQvENWH5RKTyIbKl)YMPaA45O(0rjjdQ2yTc6LSfd640kf)(X1kK3xzBs1wHVUbssYvqftZkTq4W)JrTch(hc)sRiNxlrzaD13vtTW62e5gaLLfqLZRLGdZKkGICdGgbqLZRLGdZKkGcYvCja0y9aQK7buwwaLpJnmTUOmGU67QPwyDBciAwVta0yaQ02fqzzbu(m2W06comtQakGOz9obqJbOsBxTIxMOwH8(kBtQ2k81nqssUcQyAwPfch(FmQpDusgTPnwRGEjBXGooTsXVFCTsr2muossWkAFGj(alRwHd)dHFPvycqLZRLOmGU67QPwyDBICdGYYcOY51sWHzsfqrUbqzwR4LjQvkYMHYrscwr7dmXhyz1NokP2RnwRGEjBXGooTch(hc)sRiNxlrzaD13vtTW62e5gaLLfqLZRLGdZKkGICdGgbqLZRLGdZKkGcYvCja0y9aQK71kf)(X1kzcM(dnj6thLusQnwRGEjBXGooTch(hc)sRWeGUnwgtntlcb0y9aQ0a0ia69MiG2fGUlGYYcOBJLXuZ0IqanwpGYqancGEVjcOXa0Dbuwwa9kl6NyBSmMkdORIqb6LSfdaAeaLpJnmTUyBSmMkdORIqbenR3jaApGUhqzgqJaO3BIPBsBnQaApGUxRu87hxRugqx9D1ulSUn9PJskP0gRvqVKTyqhNwHd)dHFPvycq3glJPMPfHaASEavAaAea9Eteq7cq3fqzzb0TXYyQzAriGgRhqziGgbqV3eb0ya6UakllGELf9tSnwgtLb0vrOa9s2IbancGYNXgMwxSnwgtLb0vrOaIM17eaThq3dOmdOra07nX0nPTgvaThq3Rvk(9JRv4WmPcO(0rjfd1gRvk(9JRvkYg6PTYANwTc6LSfd640NokPKM2yTc6LSfd640kC4Fi8lTY9My6M0wJkG2dO7b0iaktaktaQCETeLb0vFxn1cRBtKBauwwavoVwcomtQakYnakZakllGYeGkNxlrzaD13vtTW62eHP1b0iakFgByADrzaD13vtTW62eq0SENaOXauPThqzzbu58Aj4WmPcOimToGgbq5ZydtRl4WmPcOaIM17eangGkT9akZakZALIF)4ALTXYyQmGUkc1NokP2vBSwb9s2IbDCAfo8pe(LwzBSmMAMwecOX6bugcOrau(m2W06IYa6QVRMAH1TjGOz9obqJbOQ8aGgbqV3et3K2Aub0EaDpGgbqzcq7gqVYI(jiiSA2Etb6LSfdakllGkNxlbbHvZ2BkYnakZALIF)4AL17LnbrUeJ)UQ(0N(0N(0Aa]] )


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
