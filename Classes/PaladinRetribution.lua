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
        return max( gcd.remains, min( cooldown.judgment.remains, cooldown.crusader_strike.remains, cooldown.blade_of_justice.remains, ( action.hammer_of_wrath.usable and cooldown.hammer_of_wrath.remains or 999 ), cooldown.wake_of_ashes.remains, ( race.blood_elf and cooldown.arcane_torrent.remains or 999 ), ( IsSpellKnown( 304971 ) and cooldown.divine_toll.remains or 999 ) ) )
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


    spec:RegisterPack( "Retribution", 20201201, [[dCuo9aqiPs9iLQK2Kq8jLQiJcf1PicRIc0RKkmlHQ2fHFjv0WqbhdfzzuqptPstJc4Akv12uQI6BcPOXjKsoNqkL1jKcAEsLCpPQ9juoOsvk1cfQ8qLQuYefsbUOsvI8rLQe1jvQsyLuiZuPkfTtHKHQuLklvif6PKyQuO(QsvkmwLQu1Ej1FfzWiDyjlMOEmQMSGldTzL8zsA0kLtRQvlKQxtenBkDBkA3u9BfdxkoUsvy5GEoIPRY1f12jsFxknELkopk06fsPA(O0(bwZK2yTsOouhLHmyidmzidmjyAxdeT2FxTYXydQvAkUKLkQv8Ye1krJ4bF589JRvAkgTtf0gRvitgYrTIwro)2BVW1YALqDOokdzWqgyYqgysW0UgiAT)UAfsdY1rfnzqRS9Ha6AzTsajCTYEfqJgXd(Y57hhq37kBfEhy0EfqJgGC0ugHaktXdOgYGHmOvAGZ6TOwzVcOrJ4bF589JdO7DLTcVdmAVcOrdqoAkJqaLP4budzWqgagbmQ43por0ar(ykxxFZC)4aJk(9JtenqKpMY11rFNYwKqExnnRejBAIqGrf)(XjIgiYht566OVtzlsiVRMMvQYx20bgv87hNiAGiFmLRRJ(oLTiH8UAAwP23pecmQ43por0ar(ykxxh9DkBrc5D10SsKg47QaJk(9JtenqKpMY11rFNfKxoMUbcr)agbOaJ2Ra6EPDqE(WaGIsriJa69MiGEBiGw8BGa6ta0sA92s2IcGrf)(Xj9quoljcmQ43poPJ(o5L1Mk(9JNSp5I3ltSNpJnmTobyuXVFCsh9DYlRnv87hpzFYfVxMyVk6iSUbsagbOaJk(9Jte8zSHP1j9nZ9Jh)V6zwoVwcz7mbBMCciw8JLvoVwIsk6QVRMAH1TjYnrKZRLOKIU67QPwyDBciAwVtIXu0ILvoVwcomtQakYnrKZRLGdZKkGciAwVt6YW9LayuXVFCIGpJnmToPJ(oTV62rsrphunr)I)x9Kg0AtxbvXJiSV62rsrphunr)I1BillZDdRpKqPOFIkeicCNNCewwy9Hekf9tuHar8ESO5(samQ43porWNXgMwN0rFNRhIY2zcX)RE58AjkPOR(UAQfw3Mi3WYkNxlbhMjvaf5MiY51sWHzsfqb5kUK9mXaWOIF)4ebFgByADsh9Ds2E0gsZkjfDvSCocmQ43porWNXgMwN0rFNYwKqExnnRejBAIqGrf)(Xjc(m2W06Ko67u2IeY7QPzLQ8LnDGrf)(Xjc(m2W06Ko67u2IeY7QPzLAF)qiWOIF)4ebFgByADsh9DkBrc5D10SsKg47QaJk(9Jte8zSHP1jD03zMGP)qZ49Ye7jsMTsIqsQ9DvGrf)(Xjc(m2W06Ko67mtW0FOz8EzI9MfVKHyISH4LmZKNh)V6LZRLOKIU67QPwyDBICdlRCETeCyMubuKBIiNxlbhMjvafKR4sgRNjgagv87hNi4ZydtRt6OVZmbt)HMX7Lj2BIMdKX0Ssnf5sK3jaJk(9Jte8zSHP1jD03zMGP)qZ49Ye7dqScRhIjPiHGwGrf)(Xjc(m2W06Ko67mtW0FOz8EzI9HckP5mEkGCjtshyX)JX4)vVCETeLu0vFxn1cRBtKByzLZRLGdZKkGICte58Aj4WmPcOGCfxYy9mXaWOIF)4ebFgByADsh9DMjy6p0mEVmX(rkcB3qR57QPMPfHjoKrYv24)vVCETeLu0vFxn1cRBtKByzLZRLGdZKkGICte58Aj4WmPcOGCfxYy9mXaWOIF)4ebFgByADsh9DMjy6p0mEVmXEstbXKjwxABgjbgv87hNi4ZydtRt6OVZmbt)HMX7Lj2RcFZeFc4oaJk(9Jte8zSHP1jD03zMGP)qZ49Ye7FNWH5RKTyApYLFzZuaL(Cm(F1lNxlrjfD13vtTW62e5gww58Aj4WmPcOi3eroVwcomtQakixXLmwptmWYYNXgMwxusrx9D1ulSUnbenR3jXmW(SS8zSHP1fCyMubuarZ6DsmdSpWOIF)4ebFgByADsh9DMjy6p0mEVmXEY7RSnPARWx3ajj5kOIPzLwiC4)Xy8)QxoVwIsk6QVRMAH1TjYnSSY51sWHzsfqrUjICETeCyMubuqUIlzSEMyGLLpJnmTUOKIU67QPwyDBciAwVtIzG9zz5ZydtRl4WmPcOaIM17KygyFGrf)(Xjc(m2W06Ko67mtW0FOz8EzI9fztA5ijbRO9bM4dSSX)REMLZRLOKIU67QPwyDBICdlRCETeCyMubuKBKayuXVFCIGpJnmToPJ(oZem9hAsI)x9Y51susrx9D1ulSUnrUHLvoVwcomtQakYnrKZRLGdZKkGcYvCjJ1ZedaJk(9Jte8zSHP1jD03zjfD13vtTW62I)x9mVnwgtntlcJ1BGi3BIDTpl72yzm1mTimw)UrU3eJTpl7vw0pX2yzmvsrxfHc0lzlgIWNXgMwxSnwgtLu0vrOaIM17KEgKiY9My6M0wJApdaJk(9Jte8zSHP1jD03jhMjvaJ)x9mVnwgtntlcJ1BGi3BIDTpl72yzm1mTimw)UrU3eJTpl7vw0pX2yzmvsrxfHc0lzlgIWNXgMwxSnwgtLu0vrOaIM17KEgKiY9My6M0wJApdaJk(9Jte8zSHP1jD03zr2qpTvw70cmQ43porWNXgMwN0rFNBJLXujfDveg)V6V3et3K2Au7zicZmlNxlrjfD13vtTW62e5gww58Aj4WmPcOi3ibllZY51susrx9D1ulSUnryA9i8zSHP1fLu0vFxn1cRBtarZ6DsmdWalRCETeCyMubueMwpcFgByADbhMjvafq0SENeZamiHeaJk(9Jte8zSHP1jD03569YMGixYXFxn(F1VnwgtntlcJ1VBe(m2W06Isk6QVRMAH1TjGOz9ojMkpe5EtmDtARrTNHim39vw0pbbHvZ2BkqVKTyGLvoVwcccRMT3uKBKayeGcmQ43porSE)jBiK0rFNsl4xYwmEVmX(ajXlYvYwmEPLnJ9Kg0AtxbvXJicV03Xe5gOzSEdzzLZRLanByeILNAMwekYnrcOCETerphunr)eHP1JiNxlr4L(oMAYWMHGIW06SSKg0AtxbvXJicV03Xe5gOzSEdJiNxlbhMjvaf5MiY51sWHzsfqb5kUKDXedaJk(9JteR3FYgcjD03jbHvZ2Bg)V6zM5UVYI(j4WmPcOa9s2IHiY51susrx9D1ulSUnrUHLLpJnmTUOKIU67QPwyDBciAwVtIz4(sWYYSCETeCyMubuKByz5ZydtRl4WmPcOaIM17KygUVeseH5UVYI(jwVx2ee5so(7Qc0lzlgyz5ZydtRlwVx2ee5so(7QciAwVt6IjgKicZDFLf9tG7G889JNiOFOZrb6LSfdSS8zSHP1f4oipF)4jc6h6CuarZ6DsxmXGerU3et3K2Au7zayuXVFCIy9(t2qiPJ(oLw(EKFYgcjPTY0eHX)REM7(kl6Ny9EztqKl54VRkqVKTyGLLpJnmTUy9EztqKl54VRkGOz9ojMkpyqMyGLnGY51sSEVSjiYLC83vf5gjIWC3xzr)e4oipF)4jc6h6CuGEjBXallFgByADbUdYZ3pEIG(Hohfq0SENetLhmitmWYgq58AjWDqE((Xte0p05Oi3ibllPbT20vqv8iIWl9DmrUbAgR3qGrf)(XjI17pzdHKo67e3b557hprq)qNJX)REsdATPRGQ4reHx67yICd0SR(DJWmZDFLf9tWHzsfqb6LSfdSSY51sWHzsfqryA9i8zSHP1fCyMubuarZ6DsmMyqcww58Aj4WmPcOGCfxYy97YYYNXgMwxusrx9D1ulSUnbenR3jXyIbw2akNxlX69YMGixYXFxvKBKiY9My6M0wJApdaJk(9JteR3FYgcjD03z4L(oMi3anJ)x9sl4xYwueijErUs2Ir6woVwcPLVh5NSHqsARmnrOi3eHzM7(kl6NGdZKkGc0lzlgyz5ZydtRl4WmPcOaIM17KyQ8Gb3vIim39vw0pbUdYZ3pEIG(HohfOxYwmWYYNXgMwxG7G889JNiOFOZrbenR3jXu5bdUlllPbT20vqv8iIWl9DmrUbAgRFxjyzjnO1MUcQIhreEPVJjYnqZy9ggH5RSOFITXYyQKIUkcfOxYwmeHpJnmTUyBSmMkPORIqbenR3jDPYdgCxww58Aj4WmPcOi3eroVwcomtQakixXLSlMyqcjagv87hNiwV)Knes6OVZdnBSfKKKIWWZV4)vpZDFLf9tWHzsfqb6LSfdSS8zSHP1fCyMubuarZ6DsmvEWG7kreM7(kl6Na3b557hprq)qNJc0lzlgyz5ZydtRlWDqE((Xte0p05OaIM17KyQ8Gb3ncPbT20vqv8iIWl9DmrUbA2v)UseH5U5Ju0l)eoYHJDGbb6LSfdSS8zSHP1fslFpYpzdHK0wzAIqbenR3jXu5bjyzVYI(j2glJPsk6QiuGEjBXqe(m2W06ITXYyQKIUkcfq0SEN0LkpyWDzzLZRLyBSmMkPORIqrUHLvoVwcomtQakYnrKZRLGdZKkGcYvCj7IjgyzLZRLqA57r(jBiKK2kttekYnaJauGrf)(Xjcv0ryDdK0rFN8YAtf)(Xt2NCX7Lj2VE)jBiKe)V63glJPMPfHX63NLvoVwITXYyQKIUkcf5gw2akNxlX69YMGixYXFxvKByzdOCETe4oipF)4jc6h6CuKBagv87hNiurhH1nqsh9DgEPVJPBS24)vF3buoVwIONdQMOFICteM7gwFiHsr)eviqe4op5iSSW6djuk6NOcbI49y7YGeryEBSmMAMwe2vVHSSBJLXuZ0IWU6nqeM5ZydtRlKTvatZkf9m5EokGOz9ojMkpyqdzzdOCETe4oipF)4jc6h6CuKByzdOCETeR3lBcICjh)DvrUrcjIWC3xzr)eR3lBcICjh)Dvb6LSfdSS8zSHP1fR3lBcICjh)DvbenR3jXu5bdYedseH5UVYI(jWDqE((Xte0p05Oa9s2Ibww(m2W06cChKNVF8eb9dDokGOz9ojMkpyqMyqcGrf)(Xjcv0ryDdK0rFNTLKyAwPISHK4)vpZBJLXuZ0IWEgyz3glJPMPfHD1ByeM5ZydtRlKTvatZkf9m5EokGOz9ojMkpyqdzzdOCETe4oipF)4jc6h6CuKByzdOCETeR3lBcICjh)DvrUrcjIWC3W6djuk6NOcbIa35jhHLfwFiHsr)eviqeVhZqgKicZDFLf9tG7G889JNiOFOZrb6LSfdSS8zSHP1f4oipF)4jc6h6CuarZ6DsmM2xIim39vw0pX69YMGixYXFxvGEjBXallFgByADX69YMGixYXFxvarZ6DsmM2xcGrf)(Xjcv0ryDdK0rFNY2kGPzLIEMCphJ)x9BJLXuZ0IWU63fyuXVFCIqfDew3ajD035wzAIW0SsTW62I)x9BJLXuZ0IWU6naWOIF)4eHk6iSUbs6OVZONdQMOFX)R(UdOCETerphunr)e5MimVnwgtntlc7Q3qw2TXYyQzAryx9gicFgByADHSTcyAwPONj3ZrbenR3jXu5bdAOeaJk(9JteQOJW6giPJ(o5L1Mk(9JNSp5I3ltSF9(t2qij(F1Z8vqv8eByzVnrd)6Q3qgyzLZRLOKIU67QPwyDBICdlRCETeCyMubuKByzLZRLanByeILNAMwekYnsamQ43porOIocRBGKo67KdZKkGWe5GVKy8)QNpJnmTUGdZKkGWe5GVKOGVvqvKKwWIF)4LnwptIO5(ryEBSmMAMwe2vVHSSBJLXuZ0IWU63ncFgByADHSTcyAwPONj3ZrbenR3jXu5bdAil72yzm1mTiS3ar4ZydtRlKTvatZkf9m5EokGOz9ojMkpyqdJWNXgMwxe9Cq1e9tarZ6DsmvEWGgkbWOIF)4eHk6iSUbs6OVtEzTPIF)4j7tU49Ye7xV)Knesagv87hNiurhH1nqsh9DYhNGCyD)4X)R(U5JtqoSUFCrUbyuXVFCIqfDew3ajD03jhMjvaHjYbFjX4)v)2yzm1mTiSREdamQ43porOIocRBGKo67SG8YX0nqi6x8)QFBSmMAMwe2vVbagv87hNiurhH1nqsh9DYhNGCyD)4X)R(7nX0nPTg1yQ8Gwrkcj)46OmKbdzGjMm0aAL2c6VRs0k7n2Bhng1Eru7LJgcOaQXBiG(Mnd8a01ab09069NSHqYEcqH4EKFigauYyIaALVXSomaO8TYvrIay0EZ3raDphneq3BnUueEyaq3t8rk6LFI9Eb6LSfd7ja9gaDpXhPOx(j273takZmTJecGraJ2lmBg4HbaDFaT43poGAFYreaJ0k2NCeTXALaUQS90gRJIjTXALIF)4AfikNLe1kOxYwmOJtF6OmuBSwb9s2IbDCALIF)4AfEzTPIF)4j7toTI9jxYltuRWNXgMwNOpDu7QnwRGEjBXGooTsXVFCTcVS2uXVF8K9jNwX(Kl5LjQvurhH1nqI(0NwPbI8XuUoTX6OysBSwP43pUwPzUFCTc6LSfd640Nokd1gRvk(9JRvKTiH8UAAwjs20eHAf0lzlg0XPpDu7QnwRu87hxRiBrc5D10Ssv(YMUwb9s2IbDC6thLb0gRvk(9JRvKTiH8UAAwP23peQvqVKTyqhN(0rTV2yTsXVFCTISfjK3vtZkrAGVRQvqVKTyqhN(0rTN1gRvk(9JRvkiVCmDdeI(PvqVKTyqhN(0NwrfDew3ajAJ1rXK2yTc6LSfd640kC4Fi8lTY2yzm1mTieqJ1dO7dOSSaQCETeBJLXujfDvekYnakllGgq58AjwVx2ee5so(7QICdGYYcObuoVwcChKNVF8eb9dDokYnALIF)4AfEzTPIF)4j7toTI9jxYltuRSE)jBiKOpDugQnwRGEjBXGooTch(hc)sR0nGgq58AjIEoOAI(jYnaAeaLzaTBafwFiHsr)eviqe4op5iakllGcRpKqPOFIkeiI3b0ya6UmaOsaOrauMb0TXYyQzAriG2vpGAiGYYcOBJLXuZ0IqaTREa1aaAeaLzaLpJnmTUq2wbmnRu0ZK75OaIM17eangGQYdaQbbudbuwwanGY51sG7G889JNiOFOZrrUbqzzb0akNxlX69YMGixYXFxvKBaujauja0iakZaA3a6vw0pX69YMGixYXFxvGEjBXaGYYcO8zSHP1fR3lBcICjh)DvbenR3jaAmavLhaudcOmXaGkbGgbqzgq7gqVYI(jWDqE((Xte0p05Oa9s2IbaLLfq5ZydtRlWDqE((Xte0p05OaIM17eangGQYdaQbbuMyaqLqRu87hxReEPVJPBSw9PJAxTXAf0lzlg0XPv4W)q4xAfMb0TXYyQzAriG2dOmaOSSa62yzm1mTieq7QhqneqJaOmdO8zSHP1fY2kGPzLIEMCphfq0SENaOXauvEaqniGAiGYYcObuoVwcChKNVF8eb9dDokYnakllGgq58AjwVx2ee5so(7QICdGkbGkbGgbqzgq7gqH1hsOu0prfcebUZtocGYYcOW6djuk6NOcbI4DangGAidaQeaAeaLzaTBa9kl6Na3b557hprq)qNJc0lzlgauwwaLpJnmTUa3b557hprq)qNJciAwVta0yakt7dOsaOrauMb0Ub0RSOFI17LnbrUKJ)UQa9s2IbaLLfq5ZydtRlwVx2ee5so(7QciAwVta0yakt7dOsOvk(9JRvAljX0Ssfzdj6thLb0gRvqVKTyqhNwHd)dHFPv2glJPMPfHaAx9a6UALIF)4AfzBfW0SsrptUNJ6th1(AJ1kOxYwmOJtRWH)HWV0kBJLXuZ0IqaTREa1aALIF)4ALTY0eHPzLAH1TPpDu7zTXAf0lzlg0XPv4W)q4xALUb0akNxlr0Zbvt0prUbqJaOmdOBJLXuZ0IqaTREa1qaLLfq3glJPMPfHaAx9aQba0iakFgByADHSTcyAwPONj3ZrbenR3jaAmavLhaudcOgcOsOvk(9JRvIEoOAI(PpDurtTXAf0lzlg0XPv4W)q4xAfMb0RGQ4j2WYEBIg(bOD1dOgYaGYYcOY51susrx9D1ulSUnrUbqzzbu58Aj4WmPcOi3aOSSaQCETeOzdJqS8uZ0IqrUbqLqRu87hxRWlRnv87hpzFYPvSp5sEzIAL17pzdHe9PJkAPnwRGEjBXGooTch(hc)sRWNXgMwxWHzsfqyICWxsuW3kOksslyXVF8YcOX6buMerZ9b0iakZa62yzm1mTieq7Qhqneqzzb0TXYyQzAriG2vpGUlGgbq5ZydtRlKTvatZkf9m5EokGOz9obqJbOQ8aGAqa1qaLLfq3glJPMPfHaApGAaancGYNXgMwxiBRaMMvk6zY9CuarZ6DcGgdqv5ba1GaQHaAeaLpJnmTUi65GQj6NaIM17eangGQYdaQbbudbuj0kf)(X1kCyMubeMih8Le1NoQOnTXAf0lzlg0XPvk(9JRv4L1Mk(9JNSp50k2NCjVmrTY69NSHqI(0rXedAJ1kOxYwmOJtRWH)HWV0kDdO8Xjihw3pUi3Ovk(9JRv4JtqoSUFC9PJIjM0gRvqVKTyqhNwHd)dHFPv2glJPMPfHaAx9aQb0kf)(X1kCyMubeMih8Le1NokMmuBSwb9s2IbDCAfo8pe(LwzBSmMAMwecOD1dOgqRu87hxRuqE5y6gie9tF6OyAxTXAf0lzlg0XPv4W)q4xAL7nX0nPTgvangGQYdALIF)4Af(4eKdR7hxF6tRSE)jBiKOnwhftAJ1kOxYwmOJtRmnAfcEALIF)4AfPf8lzlQvKw2mQvinO1MUcQIhreEPVJjYnqtanwpGAiGYYcOY51sGMnmcXYtntlcf5gancGgq58AjIEoOAI(jctRdOrau58AjcV03Xutg2meueMwhqzzbusdATPRGQ4reHx67yICd0eqJ1dOgcOrau58Aj4WmPcOi3aOrau58Aj4WmPcOGCfxsaTlaLjg0kslyYltuReijErUs2I6thLHAJ1kOxYwmOJtRWH)HWV0kmdOmdODdOxzr)eCyMubuGEjBXaGgbqLZRLOKIU67QPwyDBICdGYYcO8zSHP1fLu0vFxn1cRBtarZ6DcGgdqnCFavcaLLfqzgqLZRLGdZKkGICdGYYcO8zSHP1fCyMubuarZ6DcGgdqnCFavcavcancGYmG2nGELf9tSEVSjiYLC83vfOxYwmaOSSakFgByADX69YMGixYXFxvarZ6DcG2fGYedaQeaAeaLzaTBa9kl6Na3b557hprq)qNJc0lzlgauwwaLpJnmTUa3b557hprq)qNJciAwVta0UauMyaqLaqJaO3BIPBsBnQaApGYGwP43pUwHGWQz7n1NoQD1gRvqVKTyqhNwHd)dHFPvygq7gqVYI(jwVx2ee5so(7Qc0lzlgauwwaLpJnmTUy9EztqKl54VRkGOz9obqJbOQ8aGAqaLjgauwwanGY51sSEVSjiYLC83vf5gavcancGYmG2nGELf9tG7G889JNiOFOZrb6LSfdakllGYNXgMwxG7G889JNiOFOZrbenR3jaAmavLhaudcOmXaGYYcObuoVwcChKNVF8eb9dDokYnaQeakllGsAqRnDfufpIi8sFhtKBGMaASEa1qTsXVFCTI0Y3J8t2qijTvMMiuF6OmG2yTc6LSfd640kC4Fi8lTcPbT20vqv8iIWl9DmrUbAcOD1dO7cOrauMbuMb0Ub0RSOFcomtQakqVKTyaqzzbu58Aj4WmPcOimToGgbq5ZydtRl4WmPcOaIM17eangGYedaQeakllGkNxlbhMjvafKR4scOX6b0DbuwwaLpJnmTUOKIU67QPwyDBciAwVta0yaktmaOSSaAaLZRLy9EztqKl54VRkYnaQeaAea9EtmDtARrfq7bug0kf)(X1k4oipF)4jc6h6CuF6O2xBSwb9s2IbDCAfo8pe(LwrAb)s2IIajXlYvYweqJaODdOY51siT89i)KnessBLPjcf5gancGYmGYmG2nGELf9tWHzsfqb6LSfdakllGYNXgMwxWHzsfqbenR3jaAmavLhaudcO7cOsaOrauMb0Ub0RSOFcChKNVF8eb9dDokqVKTyaqzzbu(m2W06cChKNVF8eb9dDokGOz9obqJbOQ8aGAqaDxaLLfqjnO1MUcQIhreEPVJjYnqtanwpGUlGkbGYYcOKg0AtxbvXJicV03Xe5gOjGgRhqneqJaOmdOxzr)eBJLXujfDvekqVKTyaqJaO8zSHP1fBJLXujfDvekGOz9obq7cqv5ba1Ga6UakllGkNxlbhMjvaf5gancGkNxlbhMjvafKR4scODbOmXaGkbGkHwP43pUwj8sFhtKBGM6th1EwBSwb9s2IbDCAfo8pe(LwHzaTBa9kl6NGdZKkGc0lzlgauwwaLpJnmTUGdZKkGciAwVta0yaQkpaOgeq3fqLaqJaOmdODdOxzr)e4oipF)4jc6h6CuGEjBXaGYYcO8zSHP1f4oipF)4jc6h6CuarZ6DcGgdqv5ba1Ga6UaAeaL0GwB6kOkEer4L(oMi3anb0U6b0Dbuja0iakZaA3akFKIE5NWroCSdmaOSSakFgByADH0Y3J8t2qijTvMMiuarZ6DcGgdqv5bavcaLLfqVYI(j2glJPsk6QiuGEjBXaGgbq5ZydtRl2glJPsk6QiuarZ6DcG2fGQYdaQbb0DbuwwavoVwITXYyQKIUkcf5gaLLfqLZRLGdZKkGICdGgbqLZRLGdZKkGcYvCjb0UauMyaqzzbu58AjKw(EKFYgcjPTY0eHICJwP43pUw5qZgBbjjPim88tF6tRWNXgMwNOnwhftAJ1kOxYwmOJtRWH)HWV0kmdOY51siBNjyZKtaXIFakllGkNxlrjfD13vtTW62e5gancGkNxlrjfD13vtTW62eq0SENaOXauMIwakllGkNxlbhMjvaf5gancGkNxlbhMjvafq0SENaODbOgUpGkHwP43pUwPzUFC9PJYqTXAf0lzlg0XPv4W)q4xAfsdATPRGQ4re2xD7iPONdQMOFaASEa1qaLLfqzgq7gqH1hsOu0prfcebUZtocGYYcOW6djuk6NOcbI4DangGgn3hqLqRu87hxRyF1TJKIEoOAI(PpDu7QnwRGEjBXGooTch(hc)sRiNxlrjfD13vtTW62e5gaLLfqLZRLGdZKkGICdGgbqLZRLGdZKkGcYvCjb0EaLjg0kf)(X1kRhIY2zc6thLb0gRvk(9JRviBpAdPzLKIUkwoh1kOxYwmOJtF6O2xBSwP43pUwr2IeY7QPzLiztteQvqVKTyqhN(0rTN1gRvk(9JRvKTiH8UAAwPkFztxRGEjBXGoo9PJkAQnwRu87hxRiBrc5D10SsTVFiuRGEjBXGoo9PJkAPnwRu87hxRiBrc5D10SsKg47QAf0lzlg0XPpDurBAJ1kOxYwmOJtR4LjQvisMTsIqsQ9DvTsXVFCTcrYSvsessTVRQpDumXG2yTc6LSfd640kf)(X1kMfVKHyISH4LmZKNRv4W)q4xAf58AjkPOR(UAQfw3Mi3aOSSaQCETeCyMubuKBa0iaQCETeCyMubuqUIljGgRhqzIbTIxMOwXS4LmetKneVKzM8C9PJIjM0gRvqVKTyqhNwXltuRyIMdKX0Ssnf5sK3jALIF)4Aft0CGmMMvQPixI8orF6OyYqTXAf0lzlg0XPv8Ye1kbiwH1dXKuKqqRwP43pUwjaXkSEiMKIecA1NokM2vBSwb9s2IbDCALIF)4ALqbL0CgpfqUKjPdS4)XOwHd)dHFPvKZRLOKIU67QPwyDBICdGYYcOY51sWHzsfqrUbqJaOY51sWHzsfqb5kUKaASEaLjg0kEzIALqbL0CgpfqUKjPdS4)XO(0rXKb0gRvqVKTyqhNwP43pUwzKIW2n0A(UAQzAryIdzKCLvRWH)HWV0kY51susrx9D1ulSUnrUbqzzbu58Aj4WmPcOi3aOrau58Aj4WmPcOGCfxsanwpGYedAfVmrTYifHTBO18D1uZ0IWehYi5kR(0rX0(AJ1kOxYwmOJtR4LjQvinfetMyDPTzKuRu87hxRqAkiMmX6sBZiP(0rX0EwBSwb9s2IbDCAfVmrTIk8nt8jG7Ovk(9JRvuHVzIpbCh9PJIPOP2yTc6LSfd640kf)(X1kVt4W8vYwmTh5YVSzkGsFoQv4W)q4xAf58AjkPOR(UAQfw3Mi3aOSSaQCETeCyMubuKBa0iaQCETeCyMubuqUIljGgRhqzIbaLLfq5ZydtRlkPOR(UAQfw3MaIM17eangGAG9buwwaLpJnmTUGdZKkGciAwVta0yaQb2xR4LjQvENWH5RKTyApYLFzZuaL(CuF6OykAPnwRGEjBXGooTsXVFCTc59v2MuTv4RBGKKCfuX0Ssleo8)yuRWH)HWV0kY51susrx9D1ulSUnrUbqzzbu58Aj4WmPcOi3aOrau58Aj4WmPcOGCfxsanwpGYedakllGYNXgMwxusrx9D1ulSUnbenR3jaAma1a7dOSSakFgByADbhMjvafq0SENaOXaudSVwXltuRqEFLTjvBf(6gijjxbvmnR0cHd)pg1NokMI20gRvqVKTyqhNwP43pUwPiBslhjjyfTpWeFGLvRWH)HWV0kmdOY51susrx9D1ulSUnrUbqzzbu58Aj4WmPcOi3aOsOv8Ye1kfztA5ijbRO9bM4dSS6thLHmOnwRGEjBXGooTch(hc)sRiNxlrjfD13vtTW62e5gaLLfqLZRLGdZKkGICdGgbqLZRLGdZKkGcYvCjb0y9aktmOvk(9JRvYem9hAs0NokdzsBSwb9s2IbDCAfo8pe(LwHzaDBSmMAMwecOX6budaOra07nraTlaDFaLLfq3glJPMPfHaASEaDxancGEVjcOXa09buwwa9kl6NyBSmMkPORIqb6LSfdaAeaLpJnmTUyBSmMkPORIqbenR3jaApGYaGkbGgbqV3et3K2Aub0EaLbTsXVFCTsjfD13vtTW620NokdnuBSwb9s2IbDCAfo8pe(LwHzaDBSmMAMwecOX6budaOra07nraTlaDFaLLfq3glJPMPfHaASEaDxancGEVjcOXa09buwwa9kl6NyBSmMkPORIqb6LSfdaAeaLpJnmTUyBSmMkPORIqbenR3jaApGYaGkbGgbqV3et3K2Aub0EaLbTsXVFCTchMjva1Nokd3vBSwP43pUwPiBON2kRDA1kOxYwmOJtF6Om0aAJ1kOxYwmOJtRWH)HWV0k3BIPBsBnQaApGYaGgbqzgqzgqLZRLOKIU67QPwyDBICdGYYcOY51sWHzsfqrUbqLaqzzbuMbu58AjkPOR(UAQfw3MimToGgbq5ZydtRlkPOR(UAQfw3MaIM17eangGAagauwwavoVwcomtQakctRdOrau(m2W06comtQakGOz9obqJbOgGbavcavcTsXVFCTY2yzmvsrxfH6thLH7RnwRGEjBXGooTch(hc)sRSnwgtntlcb0y9a6UaAeaLpJnmTUOKIU67QPwyDBciAwVta0yaQkpaOra07nX0nPTgvaThqzaqJaOmdODdOxzr)eeewnBVPa9s2IbaLLfqLZRLGGWQz7nf5gavcTsXVFCTY69YMGixYXFxvF6tFALkFBduROShz0w3a1N(0A]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_focused_resolve",

        package = "Retribution",
    } )


    spec:RegisterSetting( "check_wake_range", false, {
        name = "Check |T1112939:0|t Wake of Ashes Range",
        desc = "If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } )


end
