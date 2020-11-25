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


    spec:RegisterPack( "Retribution", 20201124, [[dyeAUbqicWJuuPytIIpravnkrjNsGAveqELcvZsaTlO(LcLHPOCmbyzIkEMcX0uu11KkzBIkL(MOsLXraLZjQu16uuPQMNuPUNc2NuXbvuPKwOcPhQOsPCrfvQOpQOsP6KeqLwPOuZurLsStrvnufvQ0sjGkEkQAQIQ8vfvQWyvuPk7Ls)vObtYHPAXO4XenzsDzKnlYNrPrRiNwLvROIxtGMTuUnH2TKFR0WLQoUOsXYv1ZbnDGRtX2jOVlOXlQKZlqwVIkz(OY(HSnaBEwETdiB(5mlNzbeqoDHNnBwobK7S8GG6jlFVlf0zjlF5IKLxGdb(JXaUTS89EqT1128S8W18sYYB5zmxdiWTSmwETdiB(5mlNzbeqoDHNnBwoZcWYd7jPn)C3ml)0P1uzzS8AckT8ZniLahc8hJbCBHuZD9MRVcL9CdsL)kKezOhPYz(arQCMLZmlF)VPRrw(5gKsGdb(JXaUTqQ5UEZ1xHYEUbPYFfsIm0Ju5mFGivoZYzgkBu2UeCBbX9pjxrghm0VGBlu2UeCBbX9pjxrghm(Wy(l9IIG9FQaOSDj42cI7FsUImoy8HXyAeeEfBCtrOruKEu2UeCBbX9pjxrghm(WymnccVInUPOBagXcLTlb3wqC)tYvKXbJpmgtJGWRyJBkgEfGEu2UeCBbX9pjxrghm(WymnccVInUPiS)VIfLnsHYEUbPM7mxK0ainsrcPpiKcCIesbMiKYLG9rQdIuUq)AotJWOSDj42co8eJrqcLTlb3wWXhgt6Tw0LGBRy7GGalxKgK720Bybrz7sWTfC8HXKERfDj42k2oiiWYfPbwQO3b7drzJuOSDj42cIL720Bybh6xWTvGxAilgtkHzA7QBgia)KlbCCmMuc7cPI9k2y47GjSPpdJjLWUqQyVIng(oyc)KOFfStacmoogtkHLVb6AcB6ZWysjS8nqxt4Ne9RGDNtxbJY2LGBliwUBtVHfC8HXmqkEasmWYfPbOGMMG0dJHxXIY2LGBliwUBtVHfC8HXmqkEasmWYfPbrx6mpfHtebIIg4jd8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01egcCPGDgcygkBxcUTGy5Un9gwWXhgZaP4biXalxKgejX9dkUPyVdbr4vqu2UeCBbXYDB6nSGJpmMbsXdqIbwUinOFY1P7POqccPgkBxcUTGy5Un9gwWXhgZaP4biXalxKg0(lO4UvutsbJc33LhiOaV0aJjLWUqQyVIng(oycB654ymPew(gORjSPpdJjLWY3aDnHHaxkyNHaMHY2LGBliwUBtVHfC8HXmqkEasmWYfPHvi9Htut8k2y)gsFu(bbbElWlnWysjSlKk2RyJHVdMWMEoogtkHLVb6AcB6ZWysjS8nqxtyiWLc2ziGzOSDj42cIL720BybhFymdKIhGedSCrAa27pffjheN2vqu2UeCBbXYDB6nSGJpmMbsXdqIbwUinW(NyuUAkxOSDj42cIL720BybhFymdKIhGedSCrA4kO8naNPrXCJXlGrmQjHNKc8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01egcCPGDgcyghNC3MEdlSlKk2RyJHVdMWpj6xb7mFxCCYDB6nSWY3aDnHFs0Vc2z(Uqz7sWTfel3TP3Wco(Wygifpajgy5I0a8QKPfzBU(CW(WiJRzP4MIj6x5bckWlnWysjSlKk2RyJHVdMWMEoogtkHLVb6AcB6ZWysjS8nqxtyiWLc2ziGzCCYDB6nSWUqQyVIng(oyc)KOFfSZ8DXXj3TP3WclFd01e(jr)kyN57cLTlb3wqSC3MEdl44dJzGu8aKieLTlb3wqSC3MEdl44dJ1o2jamohJMvKkqGxAa2tTwe4plbG42XobGX5y0SIub6mKdhxwc49thjHubWUwdXuUoiaYX9(PJKqQayxRH4R6K76kyu2UeCBbXYDB6nSGJpmw6EIPTRoWlnWysjSlKk2RyJHVdMWMEoogtkHLVb6AcB6ZWysjS8nqxtyiWLcoeWmu2UeCBbXYDB6nSGJpmgC6OMoUPOqQyjVKekBxcUTGy5Un9gwWXhgJPrq4vSXnfHgrr6rz7sWTfel3TP3Wco(WymnccVInUPOBagXcLTlb3wqSC3MEdl44dJX0ii8k24MIHxbOhLTlb3wqSC3MEdl44dJX0ii8k24MIW()kwu2UeCBbXYDB6nSGJpmMbsXdqIbwUin8(CPnLGWiZXgFshzmaWwOSDj42cIL720BybhFymdKIhGedSCrAWHtc9IGX3NR9JY99wGxAqtmMuc)(CTFuUV3IAIXKsy9gwCCzXysjSlKk2RyJHVdMWpj6xb7mKZmoogtkHLVb6AcdbUuWHaMLHXKsy5BGUMWpj6xb7eqxbNjl5Un9gwywJ)6ZR4MI(Cr)cMWpj6xb7K7NXXb8NLayWjsrWg1h19iZ44eabHujjSClnvqshBxIs7ljSOpN9dgLTlb3wqSC3MEdl44dJzGu8aKyGLlsdZHGXPnSrFGxAGXKsyxivSxXgdFhmHn9CCmMuclFd01e20NHXKsy5BGUMWqGlfCiGzOSDj42cIL720BybhFymdKIhGedSCrAq45T4MIEDIoG0rM2U6aV0qwmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01e(jr)ky3biWcMJll5Un9gwyxivSxXgdFhmHFs0Vc2zKzCCYDB6nSWY3aDnHFs0Vc2zKzbJY2LGBliwUBtVHfC8HXmqkEasmWYfPb9UIWyY8bf4LgymPe2fsf7vSXW3btytphhJjLWY3aDnHn9zymPew(gORj8tI(vWUdqGHY2LGBliwUBtVHfC8HXmqkEasmWYfPbwVrsV1OhgzixWaV0aJjLWUqQyVIng(oycB654ymPew(gORjSPpdJjLWY3aDnHFs0Vc2DaDHY2LGBliwUBtVHfC8HXmqkEasmWYfPbMGy3IImef9MOxUmWlnWysjSlKk2RyJHVdMWMEoogtkHLVb6AcB6rz7sWTfel3TP3Wco(Wygifpajgy5I0Gi9KGGjhgtEXg4LgYsaVF6ijKka21AiMY1bbqoU3pDKesfa7AneFvNa6kyooyp1ArG)SeaI1NWROieSVyNHCqz7sWTfel3TP3Wco(Wygifpajgy5I0qFZuA6zi)1WyQ5qbd8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01egcCPGDgcyghNC3MEdlSlKk2RyJHVdMWpj6xb7mFxCCcGXKsy5BGUMWM(mYDB6nSWY3aDnHFs0Vc2z(Uqz7sWTfel3TP3Wco(Wygifpajgy5I0ad9q6fKEyCoM5yc8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01egcCPGDgcyghNC3MEdlSlKk2RyJHVdMWpj6xb7mFxCCcGXKsy5BGUMWM(mYDB6nSWY3aDnHFs0Vc2z(Uqz7sWTfel3TP3Wco(Wygifpajgy5I0av6gbHrWvsG5P4MIP3LGBlVf73q6d8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01egcCPGDgcyghNC3MEdlSlKk2RyJHVdMWpj6xb7mFxCCYDB6nSWY3aDnHFs0Vc2z(Uqz7sWTfel3TP3Wco(Wygifpajgy5I0qp5FlQpH0dJYvS3HWaV0aJjLWUqQyVIng(oycB654ymPew(gORjSPpdJjLWY3aDnHHaxkyNHaMHY2LGBliwUBtVHfC8HXmqkEasmWYfPH09qqu0bemc7dIT5qyGxAGXKsyxivSxXgdFhmHn9CCmMuclFd01e20NHXKsy5BGUMWpj6xb7EiGUqz7sWTfel3TP3Wco(Wygifpajgy5I0GC)30diDKT56Zb7dJIK2BTBRaV0aJjLWUqQyVIng(oycB654ymPew(gORjSPpdJjLWY3aDnHFs0Vc2DoZqz7sWTfel3TP3Wco(Wygifpajgy5I0GC)30diDKT56Zb7dJmUMLc8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01e(jr)ky3b0fkBxcUTGy5Un9gwWXhgZaP4biXalxKgc)dmDfBesSIubIBkQFccCwhmHY2LGBliwUBtVHfC8HXmqkEasmWYfPb40kfK5a0dJjVyd8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWMEu2UeCBbXYDB6nSGJpmMbsXdqIbwUin0oHxXg3RfLEDqa9OSDj42cIL720BybhFymdKIhGedSCrA4pGXBXe5Gj6JBkAQIn6cg4LgymPe2fsf7vSXW3btytphhJjLWY3aDnHn9zymPew(gORjme4sbhcyghNC3MEdlSlKk2RyJHVdMWpj6xb7mmYmoo5Un9gwy5BGUMWpj6xb7mmYmu2UeCBbXYDB6nSGJpmMbsXdqIbwUin8K4cOiR50EjPOMeEscLTlb3wqSC3MEdl44dJzGu8aKyGLlsdcpVf3uec2xeIY2LGBliwUBtVHfC8HXmqkEasmWYfPHWP7BHxXcJ9nJOZsbEPbgtkHDHuXEfBm8DWe20ZXXysjS8nqxtytFggtkHLVb6Ac)KOFfS7HCMHY2LGBliwUBtVHfC8HXmqkEasmWYfPb9tUoY2C95G9HrgxZsbEPbgtkHDHuXEfBm8DWe20ZXXysjS8nqxtytFggtkHLVb6Ac)KOFfS7HCMHY2LGBliwUBtVHfC8HXmqkEasmWYfPb9tUo6W(79caJIK2BTBRaV0aJjLWUqQyVIng(oycB654ymPew(gORjSPpdJjLWY3aDnHFs0Vc29qoZqz7sWTfel3TP3Wco(Wygifpajgy5I0a7Vflm2)NO3IVZsbEPbbWysjSlKk2RyJHVdMWM(mcGXKsy5BGUMWMEu2UeCBbXYDB6nSGJpmMbsXdqIbwUinaV6Ga6JSnxFoyFyKX1SuGxAGXKsyxivSxXgdFhmHn9CCmMuclFd01e20NHXKsy5BGUMWpj6xb7EiGUqz7sWTfel3TP3Wco(Wygifpajgy5I0a8QdcOpY2C95G9Hrrs7T2TvGxAGXKsyxivSxXgdFhmHn9CCmMuclFd01e20NHXKsy5BGUMWpj6xb7EiNzOSDj42cIL720BybhFymdKIhGedSCrAWNl4K)omM2ce3uSFdPpWlniaG3OcGLVb6ActLZ0iDg5Un9gwyxivSxXgdFhmHFs0Vc2DxCCaVrfalFd01eMkNPr6mYDB6nSWY3aDnHFs0Vc2DxzaNi1jGzCCtBlOy)gsFNHrYaorQ7aMLb4nQa4qxqkUPOdNiiMkNPrAu2UeCBbXYDB6nSGJpmMbsXdqIbwUini8G3wXnf1K4bPaV0aJjLWUqQyVIng(oycB654ymPew(gORjSPpdJjLWY3aDnHHaxk4qaZ44K720ByHDHuXEfBm8DWe(jr)kyNHrMXXj3TP3WclFd01e(jr)kyNHrMHY2LGBliwUBtVHfC8HXmqkEasmWYfPbhoj0lcgFFU2pk33BbEPbnXysj87Z1(r5(ElQjgtkH1ByXXLfJjLWUqQyVIng(oyc)KOFfSZqoZ44ymPew(gORjme4sbhcywggtkHLVb6Ac)KOFfStaDfCMSK720ByHzn(RpVIBk6Zf9lyc)KOFfStUFghh4ePiyJ6J6EKzCCcGGqQKewULMkiPJTlrP9Lew0NZ(bJY2LGBliwUBtVHfC8HXmqkEasmWYfPbbRfe3u0l5rfiMmFqbEPbgtkHDHuXEfBm8DWe20ZXXysjS8nqxtytFggtkHLVb6AcdbUuWodbmJJtUBtVHf2fsf7vSXW3bt4Ne9RGDgzghNaymPew(gORjSPpJC3MEdlS8nqxt4Ne9RGDgzgkBxcUTGy5Un9gwWXhgZfsf7vSXW3btbEPHSM2wqX(nK(odZNbCIu3DXXnTTGI9Bi9Dggjd4ePoDXXb8gva802ck6cPILEmvotJ0zK720ByHN2wqrxivS0JFs0Vcoml4mGtKIGno1ZomdLTlb3wqSC3MEdl44dJjFd01uGxAiRPTfuSFdPVZW8zaNi1DxCCtBlOy)gsFNHrYaorQtxCCaVrfapTTGIUqQyPhtLZ0iDg5Un9gw4PTfu0fsfl94Ne9RGdZcod4ePiyJt9SdZqz7sWTfel3TP3Wco(WyoCIQ4K3ABikBxcUTGy5Un9gwWXhgBABbfDHuXsFGxAaCIueSXPE2HzzYklgtkHDHuXEfBm8DWe20ZXXysjS8nqxtytFWCCzXysjSlKk2RyJHVdMW6nSYi3TP3Wc7cPI9k2y47Gj8tI(vWoZpJJJXKsy5BGUMW6nSYi3TP3WclFd01e(jr)kyN5NfCWOSDj42cIL720BybhFyS0vEl(KuWTUInWlnmTTGI9Bi9DggjJC3MEdlSlKk2RyJHVdMWpj6xb7Wk1zaNifbBCQNDywMSeaWBubWq69(PtetLZ0inhhJjLWq69(PteB6dgLTlb3wqSC3MEdl44dJbMOOPywtPJP9LuGxAaCIu3d5WXXysj8tsbBeegt7ljSPhLTlb3wqSC3MEdl44dJX02vh3uemrrQiXGc8sdmMuc7cPI9k2y47GjSPNJJXKsy5BGUMWM(mmMuclFd01egcCPGdbmdLTlb3wqSC3MEdl44dJXA8xFEf3u0Nl6xWuGxAqaaVrfalFd01eMkNPr6mzj3TP3Wc7cPI9k2y47Gj8tI(vWU7kZ02ck2VH03zyeoo5Un9gwyxivSxXgdFhmHFs0Vc2zy(UcMJllG3OcGLVb6ActLZ0iDg5Un9gwy5BGUMWpj6xb7MvQZmTTGI9Bi9DgMNJtUBtVHfw(gORj8tI(vWodZ3vWOSDj42cIL720BybhFySW9BAH0vXNGB5LKc8sdYDB6nSWUqQyVIng(oyc)KOFfSBwPoZ02ck2VH03zyeooG3OcGLVb6ActLZ0iDg5Un9gwy5BGUMWpj6xb7MvQZmTTGI9Bi9DgMNJtUBtVHf2fsf7vSXW3bt4Ne9RGDgMVloo5Un9gwy5BGUMWpj6xb7mmFxOSDj42cIL720BybhFyS0knqsh95I(dqrgYfd8sdzjG3pDKesfa7Anet56Gaih37NoscPcGDTgIVQZiZ44G9uRfb(ZsaiwFcVIIqW(IDgYj4mcilgtkHDHuXEfBm8DWe20ZXXysjS8nqxtytFWzYsUBtVHfMP5AkUP4CmqWjj8tI(vWoSsTansg5Un9gw45y0SIubWpj6xb7Wk1c0ibJY2LGBliwUBtVHfC8HXejX9dkUPyZipDu)Klcd8sdzXysjSlKk2RyJHVdMWMEoogtkHLVb6AcB6ZWysjS8nqxtyiWLcoeWSGZmTTGI9Bi9DpmckBxcUTGy5Un9gwWXhgR38xkORyJmnhcc8sdzjG3pDKesfa7Anet56Gaih37NoscPcGDTgIVQZiZ44G9uRfb(ZsaiwFcVIIqW(IDgYjyu2ifkBxcUTG40vhCIE44dJj0)ZzAuGLlsdAyu6qGZ0Oaf6ndna7Pwlc8NLaqS(eEffHG9f7mKdhhJjLWKyFqp5vSFdPhB6ZOjgtkHNJrZksfaR3WkdJjLW6t4vuS389lKW6nS44G9uRfb(ZsaiwFcVIIqW(IDgYjdJjLWY3aDnHn9zymPew(gORjme4sb7oGzOSDj42cItxDWj6HJpmgKEVF6ed8sdzLLaaEJkaw(gORjmvotJ0zymPe2fsf7vSXW3btytphNC3MEdlSlKk2RyJHVdMWpj6xb7KtxbZXLfJjLWY3aDnHn9CCYDB6nSWY3aDnHFs0Vc2jNUco4mzjaG3OcGtx5T4tsb36kwmvotJ0CCYDB6nSWPR8w8jPGBDfl(jr)ky3bml4mzjaG3OcGPCrsd42kcPcqLKWu5mnsZXj3TP3Wct5IKgWTvesfGkjHFs0Vc2DaZcod4ePiyJt9SdZqz7sWTfeNU6Gt0dhFymHELBmhCIEyCYffPpWlnKLaaEJkaoDL3IpjfCRRyXu5mnsZXj3TP3WcNUYBXNKcU1vS4Ne9RGDyLAbkGzCCAIXKs40vEl(KuWTUIfB6dotwca4nQaykxK0aUTIqQaujjmvotJ0CCYDB6nSWuUiPbCBfHubOss4Ne9RGDyLAbkGzCCAIXKsykxK0aUTIqQaujjSPpyooyp1ArG)SeaI1NWROieSVyNHCqz7sWTfeNU6Gt0dhFymkxK0aUTIqQaujPaV0aSNATiWFwcaX6t4vuec2xS7HrYKvwca4nQay5BGUMWu5mnsZXXysjS8nqxty9gwzK720ByHLVb6Ac)KOFfStaZcMJJXKsy5BGUMWqGlfSZWiCCYDB6nSWUqQyVIng(oyc)KOFfStaZ440eJjLWPR8w8jPGBDfl20hCgWjsrWgN6zhMHY2LGBlioD1bNOho(Wy6t4vuec2xmWlni0)ZzAewdJshcCMgLramMucl0RCJ5Gt0dJtUOi9ytFMSYsaaVrfalFd01eMkNPrAoo5Un9gwy5BGUMWpj6xb7Wk1c0ibNjlba8gvamLlsAa3wrivaQKeMkNPrAoo5Un9gwykxK0aUTIqQaujj8tI(vWoSsTanchhSNATiWFwcaX6t4vuec2xSZWibZXb7Pwlc8NLaqS(eEffHG9f7mKtMSaEJkaEABbfDHuXspMkNPr6mYDB6nSWtBlOOlKkw6Xpj6xb7MvQfOr44ymPew(gORjSPpdJjLWY3aDnHHaxky3bml4Grz7sWTfeNU6Gt0dhFymaj238hgfsV(KGaV0qwca4nQay5BGUMWu5mnsZXj3TP3WclFd01e(jr)kyhwPwGgj4mzjaG3OcGPCrsd42kcPcqLKWu5mnsZXj3TP3Wct5IKgWTvesfGkjHFs0Vc2HvQfOrYa7Pwlc8NLaqS(eEffHG9f7EyKGZKLaKRqQ8cGls(BBFnMkNPrAoo5Un9gwyHELBmhCIEyCYffPh)KOFfSdRuhmhhWBubWtBlOOlKkw6Xu5mnsNrUBtVHfEABbfDHuXsp(jr)ky3SsTanchhJjLWtBlOOlKkw6XMEoogtkHLVb6AcB6ZWysjS8nqxtyiWLc2DaZ44ymPewOx5gZbNOhgNCrr6XMEu2ifkBxcUTGywQO3b7dhFymP3ArxcUTITdccSCrAiD1bNOhg4LgM2wqX(nK(odDXXXysj802ck6cPILESPNJttmMucNUYBXNKcU1vSytphNMymPeMYfjnGBRiKkavscB6rz7sWTfeZsf9oyF44dJPpHxrrW2AbEPbbOjgtkHNJrZksfaB6ZKLaE)0rsivaSR1qmLRdcGCCVF6ijKka21Ai(QoJml4mznTTGI9Bi9DpKdh302ck2VH039W8zYsUBtVHfMP5AkUP4CmqWjj8tI(vWoSsTaLdhNMymPeMYfjnGBRiKkavscB6540eJjLWPR8w8jPGBDfl20hCWzYsaaVrfaNUYBXNKcU1vSyQCMgP54K720ByHtx5T4tsb36kw8tI(vWoSsTafWSGZKLaaEJkaMYfjnGBRiKkavsctLZ0inhNC3MEdlmLlsAa3wrivaQKe(jr)kyhwPwGcywWOSDj42cIzPIEhSpC8HXcDbP4MIoCIGbEPHSM2wqX(nK(HzCCtBlOy)gsF3d5Kjl5Un9gwyMMRP4MIZXabNKWpj6xb7Wk1cuoCCAIXKsykxK0aUTIqQaujjSPNJttmMucNUYBXNKcU1vSytFWbNjlb8(PJKqQayxRHykxhea54E)0rsivaSR1q8vDYzwWzYsaaVrfat5IKgWTvesfGkjHPYzAKMJtUBtVHfMYfjnGBRiKkavsc)KOFfStaDfCMSeaWBubWPR8w8jPGBDflMkNPrAoo5Un9gw40vEl(KuWTUIf)KOFfStaDfmkBxcUTGywQO3b7dhFymMMRP4MIZXabNKc8sdtBlOy)gsF3dJGY2LGBliMLk6DW(WXhgBYffPpUPy47GPaV0W02ck2VH039W8OSDj42cIzPIEhSpC8HXMJrZksfiWlnianXysj8CmAwrQaytFMSM2wqX(nK(UhYHJBABbf73q67Ey(mYDB6nSWmnxtXnfNJbcojHFs0Vc2HvQfOCcgLTlb3wqmlv07G9HJpmM0BTOlb3wX2bbbwUinKU6Gt0dd8sdzb8NLa4jYBGjCVe09qoZ44ymPe2fsf7vSXW3btytphhJjLWY3aDnHn9CCmMuctI9b9KxX(nKESPpyu2UeCBbXSurVd2ho(WyY3aDn9ri4pbPaV0GC3MEdlS8nqxtFec(tqclN8NLGX07sWTL36meao31vMSM2wqX(nK(UhYHJBABbf73q67EyKmYDB6nSWmnxtXnfNJbcojHFs0Vc2HvQfOC44M2wqX(nK(H5Zi3TP3WcZ0Cnf3uCogi4Ke(jr)kyhwPwGYjJC3MEdl8CmAwrQa4Ne9RGDyLAbkNGrz7sWTfeZsf9oyF44dJj9wl6sWTvSDqqGLlsdPRo4e9qu2UeCBbXSurVd2ho(WyY3aDn9ri4pbPaV0W02ck2VH039W8OSDj42cIzPIEhSpC8HXKBjPc8oG0XuZfju2UeCBbXSurVd2ho(Wyp59xXgtnxKGbEPbG)SeaprEdmf7LGocSzCCa)zjaEI8gyk2lbDNZmoU0XobIpj6xb7EKUqz7sWTfeZsf9oyF44dJ5V0lkc2)Pce4LgM2wqX(nK(UhMhLTlb3wqmlv07G9HJpmMClijFhCBf4LgaNifbBCQNTdRuB5fsp82YMFoZYzwabeGaZYh6FDfl0Yp3XCRcCYxGB(ZTp3hPqQ8MiK6e73hGuP9rkb(0vhCIEOaps9uUXCpPrk4ksiLBaROdinsjN8ILGyu2ZTCfHu525(i1CBBjKEaPrkbE5kKkVa45EyQCMgPf4rkWIuc8YvivEbWZ9e4rQScixbJrzJYwGRy)(asJuDHuUeCBHuTdcGyu2wE3aM23YZNBmuZb7B5BheaT5z51uYnnGnpB(byZZY7sWTLL)jgJGKLNkNPrA7OwGn)CS5z5PYzAK2oQL3LGBllV0BTOlb3wX2bbw(2bbXYfjlVC3MEdlOfyZFeBEwEQCMgPTJA5Dj42YYl9wl6sWTvSDqGLVDqqSCrYYZsf9oyFOfybw((NKRiJdS5zZpaBEwExcUTS89l42YYtLZ0iTDulWMFo28S8UeCBz59x6ffb7)ubS8u5mnsBh1cS5pInplVlb3wwEMgbHxXg3ueAefP3YtLZ0iTDulWM)828S8UeCBz5zAeeEfBCtr3amILLNkNPrA7OwGn)US5z5Dj42YYZ0ii8k24MIHxbO3YtLZ0iTDulWMFU1MNL3LGBllptJGWRyJBkc7)RyT8u5mnsBh1cSalplv07G9H28S5hGnplpvotJ02rT8Y)a0FULFABbf73q6rQodivxifhhsXysj802ck6cPILESPhP44qknXysjC6kVfFsk4wxXIn9ifhhsPjgtkHPCrsd42kcPcqLKWMElVlb3wwEP3ArxcUTITdcS8TdcILlsw(0vhCIEOfyZphBEwEQCMgPTJA5L)bO)ClVaqknXysj8CmAwrQaytpsLbPYcPeas9(PJKqQayxRHykxhearkooK69thjHubWUwdXxHuDqQrMHubJuzqQSqQPTfuSFdPhP6EaPYbP44qQPTfuSFdPhP6EaPMhPYGuzHuYDB6nSWmnxtXnfNJbcojHFs0VcIuDqkwPgPeiKkhKIJdP0eJjLWuUiPbCBfHubOssytpsXXHuAIXKs40vEl(KuWTUIfB6rQGrQGrQmivwiLaqkG3OcGtx5T4tsb36kwmvotJ0ifhhsj3TP3WcNUYBXNKcU1vS4Ne9RGivhKIvQrkbcPcygsfmsLbPYcPeasb8gvamLlsAa3wrivaQKeMkNPrAKIJdPK720ByHPCrsd42kcPcqLKWpj6xbrQoifRuJucesfWmKkylVlb3wwE9j8kkc2wZcS5pInplpvotJ02rT8Y)a0FULplKAABbf73q6rQbKAgsXXHutBlOy)gsps19asLdsLbPYcPK720ByHzAUMIBkohdeCsc)KOFfeP6GuSsnsjqivoifhhsPjgtkHPCrsd42kcPcqLKWMEKIJdP0eJjLWPR8w8jPGBDfl20JubJubJuzqQSqkbGuVF6ijKka21AiMY1bbqKIJdPE)0rsivaSR1q8vivhKkNzivWivgKklKsaifWBubWuUiPbCBfHubOssyQCMgPrkooKsUBtVHfMYfjnGBRiKkavsc)KOFfeP6Gub0fsfmsLbPYcPeasb8gvaC6kVfFsk4wxXIPYzAKgP44qk5Un9gw40vEl(KuWTUIf)KOFfeP6Gub0fsfSL3LGBllFOlif3u0Hte0cS5pVnplpvotJ02rT8Y)a0FULFABbf73q6rQUhqQrS8UeCBz5zAUMIBkohdeCsYcS53LnplpvotJ02rT8Y)a0FULFABbf73q6rQUhqQ5T8UeCBz5NCrr6JBkg(oyYcS5NBT5z5PYzAK2oQLx(hG(ZT8caP0eJjLWZXOzfPcGn9ivgKklKAABbf73q6rQUhqQCqkooKAABbf73q6rQUhqQ5rQmiLC3MEdlmtZ1uCtX5yGGts4Ne9RGivhKIvQrkbcPYbPc2Y7sWTLLFognRivalWMFUZMNLNkNPrA7OwE5Fa6p3YNfsb8NLa4jYBGjCVeGuDpGu5mdP44qkgtkHDHuXEfBm8DWe20JuCCifJjLWY3aDnHn9ifhhsXysjmj2h0tEf73q6XMEKkylVlb3wwEP3ArxcUTITdcS8TdcILlsw(0vhCIEOfyZxGzZZYtLZ0iTDulV8pa9NB5L720ByHLVb6A6JqWFcsy5K)SemMExcUT8gs1zaPcaN76cPYGuzHutBlOy)gsps19asLdsXXHutBlOy)gsps19asncsLbPK720ByHzAUMIBkohdeCsc)KOFfeP6GuSsnsjqivoifhhsnTTGI9Bi9i1asnpsLbPK720ByHzAUMIBkohdeCsc)KOFfeP6GuSsnsjqivoivgKsUBtVHfEognRiva8tI(vqKQdsXk1iLaHu5GubB5Dj42YYlFd010hHG)eKSaB(5EBEwEQCMgPTJA5Dj42YYl9wl6sWTvSDqGLVDqqSCrYYNU6Gt0dTaB(bmZMNLNkNPrA7OwE5Fa6p3YpTTGI9Bi9iv3di18wExcUTS8Y3aDn9ri4pbjlWMFabyZZY7sWTLLxULKkW7ashtnxKS8u5mnsBh1cS5hqo28S8u5mnsBh1Yl)dq)5wEG)SeaprEdmf7LaKQdsjWMHuCCifWFwcGNiVbMI9sas1nsLZmKIJdPsh7ei(KOFfeP6gPgPllVlb3ww(N8(RyJPMlsqlWMFaJyZZYtLZ0iTDulV8pa9NB5N2wqX(nKEKQ7bKAElVlb3wwE)LErrW(pvalWMFaZBZZYtLZ0iTDulV8pa9NB5bNifbBCQNfP6GuSsTL3LGBllVClijFhCBzbwGLpD1bNOhAZZMFa28S8u5mnsBh1YV9wEibS8UeCBz5f6)5mnYYl0BgYYd7Pwlc8NLaqS(eEffHG9frQodivoifhhsXysjmj2h0tEf73q6XMEKkdsPjgtkHNJrZksfaR3WcPYGumMucRpHxrXEZ3VqcR3WcP44qkyp1ArG)SeaI1NWROieSVis1zaPYbPYGumMuclFd01e20JuzqkgtkHLVb6AcdbUuqKQBKkGzwEH(hlxKS8Ayu6qGZ0ilWMFo28S8u5mnsBh1Yl)dq)5w(SqQSqkbGuaVrfalFd01eMkNPrAKkdsXysjSlKk2RyJHVdMWMEKIJdPK720ByHDHuXEfBm8DWe(jr)kis1bPYPlKkyKIJdPYcPymPew(gORjSPhP44qk5Un9gwy5BGUMWpj6xbrQoivoDHubJubJuzqQSqkbGuaVrfaNUYBXNKcU1vSyQCMgPrkooKsUBtVHfoDL3IpjfCRRyXpj6xbrQUrQaMHubJuzqQSqkbGuaVrfat5IKgWTvesfGkjHPYzAKgP44qk5Un9gwykxK0aUTIqQaujj8tI(vqKQBKkGzivWivgKcCIueSXPEwKAaPMz5Dj42YYdP37NorlWM)i28S8u5mnsBh1Yl)dq)5w(SqkbGuaVrfaNUYBXNKcU1vSyQCMgPrkooKsUBtVHfoDL3IpjfCRRyXpj6xbrQoifRuJucesfWmKIJdP0eJjLWPR8w8jPGBDfl20JubJuzqQSqkbGuaVrfat5IKgWTvesfGkjHPYzAKgP44qk5Un9gwykxK0aUTIqQaujj8tI(vqKQdsXk1iLaHubmdP44qknXysjmLlsAa3wrivaQKe20JubJuCCifSNATiWFwcaX6t4vuec2xeP6mGu5y5Dj42YYl0RCJ5Gt0dJtUOi9wGn)5T5z5PYzAK2oQLx(hG(ZT8WEQ1Ia)zjaeRpHxrriyFrKQ7bKAeKkdsLfsLfsjaKc4nQay5BGUMWu5mnsJuCCifJjLWY3aDnH1ByHuzqk5Un9gwy5BGUMWpj6xbrQoivaZqQGrkooKIXKsy5BGUMWqGlfeP6mGuJGuCCiLC3MEdlSlKk2RyJHVdMWpj6xbrQoivaZqkooKstmMucNUYBXNKcU1vSytpsfmsLbPaNifbBCQNfPgqQzwExcUTS8uUiPbCBfHubOsswGn)US5z5PYzAK2oQLx(hG(ZT8c9)CMgH1WO0HaNPrivgKsaifJjLWc9k3yo4e9W4Klksp20JuzqQSqQSqkbGuaVrfalFd01eMkNPrAKIJdPK720ByHLVb6Ac)KOFfeP6GuSsnsjqi1iivWivgKklKsaifWBubWuUiPbCBfHubOssyQCMgPrkooKsUBtVHfMYfjnGBRiKkavsc)KOFfeP6GuSsnsjqi1iifhhsb7Pwlc8NLaqS(eEffHG9frQodi1iivWifhhsb7Pwlc8NLaqS(eEffHG9frQodivoivgKklKc4nQa4PTfu0fsfl9yQCMgPrQmiLC3MEdl802ck6cPILE8tI(vqKQBKIvQrkbcPgbP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHHaxkis1nsfWmKkyKkylVlb3wwE9j8kkcb7lAb28ZT28S8u5mnsBh1Yl)dq)5w(SqkbGuaVrfalFd01eMkNPrAKIJdPK720ByHLVb6Ac)KOFfeP6GuSsnsjqi1iivWivgKklKsaifWBubWuUiPbCBfHubOssyQCMgPrkooKsUBtVHfMYfjnGBRiKkavsc)KOFfeP6GuSsnsjqi1iivgKc2tTwe4plbGy9j8kkcb7lIuDpGuJGubJuzqQSqkbGuYvivEbWfj)TTVgP44qk5Un9gwyHELBmhCIEyCYffPh)KOFfeP6GuSsnsfmsXXHuaVrfapTTGIUqQyPhtLZ0insLbPK720ByHN2wqrxivS0JFs0VcIuDJuSsnsjqi1iifhhsXysj802ck6cPILESPhP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHHaxkis1nsfWmKIJdPymPewOx5gZbNOhgNCrr6XMElVlb3wwEaj238hgfsV(KalWcS8YDB6nSG28S5hGnplpvotJ02rT8Y)a0FULplKIXKsyM2U6MbcWp5sasXXHumMuc7cPI9k2y47GjSPhPYGumMuc7cPI9k2y47Gj8tI(vqKQdsfGadP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHFs0VcIuDJu50fsfSL3LGBllF)cUTSaB(5yZZYtLZ0iTDulF5IKLhkOPji9Wy4vSwExcUTS8qbnnbPhgdVI1cS5pInplpvotJ02rT8UeCBz5fDPZ8ueoreikAGN0Yl)dq)5wEgtkHDHuXEfBm8DWe20JuCCifJjLWY3aDnHn9ivgKIXKsy5BGUMWqGlfeP6mGubmZYxUiz5fDPZ8ueoreikAGN0cS5pVnplpvotJ02rT8LlswErsC)GIBk27qqeEf0Y7sWTLLxKe3pO4MI9oeeHxbTaB(DzZZYtLZ0iTDulF5IKLx)KRt3trHeesnlVlb3wwE9tUoDpffsqi1SaB(5wBEwEQCMgPTJA5Dj42YYR9xqXDROMKcgfUVlpqqwE5Fa6p3YZysjSlKk2RyJHVdMWMEKIJdPymPew(gORjSPhPYGumMuclFd01egcCPGivNbKkGzw(YfjlV2Fbf3TIAskyu4(U8abzb28ZD28S8u5mnsBh1Y7sWTLLFfsF4e1eVIn2VH0hLFqqG3S8Y)a0FULNXKsyxivSxXgdFhmHn9ifhhsXysjS8nqxtytpsLbPymPew(gORjme4sbrQodivaZS8Llsw(vi9Htut8k2y)gsFu(bbbEZcS5lWS5z5PYzAK2oQLVCrYYd79NIIKdIt7kOL3LGBllpS3FkksoioTRGwGn)CVnplpvotJ02rT8LlswE2)eJYvt5YY7sWTLLN9pXOC1uUSaB(bmZMNLNkNPrA7OwExcUTS8xbLVb4mnkMBmEbmIrnj8KKLx(hG(ZT8mMuc7cPI9k2y47GjSPhP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHHaxkis1zaPcygsXXHuYDB6nSWUqQyVIng(oyc)KOFfeP6GuZ3fsXXHuYDB6nSWY3aDnHFs0VcIuDqQ57YYxUiz5VckFdWzAum3y8cyeJAs4jjlWMFabyZZYtLZ0iTDulVlb3wwE4vjtlY2C95G9HrgxZsXnft0VYdeKLx(hG(ZT8mMuc7cPI9k2y47GjSPhP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHHaxkis1zaPcygsXXHuYDB6nSWUqQyVIng(oyc)KOFfeP6GuZ3fsXXHuYDB6nSWY3aDnHFs0VcIuDqQ57YYxUiz5HxLmTiBZ1Nd2hgzCnlf3umr)kpqqwGn)aYXMNL3LGBllVbsXdqIqlpvotJ02rTaB(bmInplpvotJ02rT8Y)a0FULh2tTwe4plbG42XobGX5y0SIubqQodivoifhhsLfsjaK69thjHubWUwdXuUoiaIuCCi17NoscPcGDTgIVcP6Gu5UUqQGT8UeCBz5Bh7eagNJrZksfWcS5hW828S8u5mnsBh1Yl)dq)5wEgtkHDHuXEfBm8DWe20JuCCifJjLWY3aDnHn9ivgKIXKsy5BGUMWqGlfePgqQaMz5Dj42YYNUNyA7QTaB(b0LnplVlb3wwE40rnDCtrHuXsEjjlpvotJ02rTaB(bKBT5z5Dj42YYZ0ii8k24MIqJOi9wEQCMgPTJAb28di3zZZY7sWTLLNPrq4vSXnfDdWiwwEQCMgPTJAb28dqGzZZY7sWTLLNPrq4vSXnfdVcqVLNkNPrA7OwGn)aY928S8UeCBz5zAeeEfBCtry)FfRLNkNPrA7OwGn)CMzZZYtLZ0iTDulF5IKL)95sBkbHrMJn(KoYyaGTS8UeCBz5FFU0MsqyK5yJpPJmgayllWMFobyZZYtLZ0iTDulVlb3wwEhoj0lcgFFU2pk33BwE5Fa6p3YRjgtkHFFU2pk33BrnXysjSEdlKIJdPYcPymPe2fsf7vSXW3bt4Ne9RGivNbKkNzifhhsXysjS8nqxtyiWLcIudivaZqQmifJjLWY3aDnHFs0VcIuDqQa6cPcgPYGuzHuYDB6nSWSg)1NxXnf95I(fmHFs0VcIuDqQC)mKIJdPa(Zsam4ePiyJ6JqQUrQrMHuCCiLaqkccPssy5wAQGKo2UeL2xsyrFo7JubB5lxKS8oCsOxem((CTFuUV3SaB(5KJnplpvotJ02rT8UeCBz5NdbJtByJElV8pa9NB5zmPe2fsf7vSXW3btytpsXXHumMuclFd01e20JuzqkgtkHLVb6AcdbUuqKAaPcyMLVCrYYphcgN2Wg9wGn)CgXMNLNkNPrA7OwExcUTS8cpVf3u0Rt0bKoY02vB5L)bO)ClFwifJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMEKkdsXysjS8nqxt4Ne9RGiv3ivacmKkyKIJdPYcPK720ByHDHuXEfBm8DWe(jr)kis1bPgzgsXXHuYDB6nSWY3aDnHFs0VcIuDqQrMHubB5lxKS8cpVf3u0Rt0bKoY02vBb28ZzEBEwEQCMgPTJA5Dj42YYR3vegtMpilV8pa9NB5zmPe2fsf7vSXW3btytpsXXHumMuclFd01e20JuzqkgtkHLVb6Ac)KOFfeP6gPcqGz5lxKS86DfHXK5dYcS5Ntx28S8u5mnsBh1Y7sWTLLN1BK0Bn6HrgYf0Yl)dq)5wEgtkHDHuXEfBm8DWe20JuCCifJjLWY3aDnHn9ivgKIXKsy5BGUMWpj6xbrQUrQa6YYxUiz5z9gj9wJEyKHCbTaB(5KBT5z5PYzAK2oQL3LGBllptqSBrrgIIEt0lxA5L)bO)ClpJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMElF5IKLNji2TOidrrVj6LlTaB(5K7S5z5PYzAK2oQL3LGBllVi9KGGjhgtEXA5L)bO)ClFwiLaqQ3pDKesfa7Anet56GaisXXHuVF6ijKka21Ai(kKQdsfqxivWifhhsb7Pwlc8NLaqS(eEffHG9frQodivow(YfjlVi9KGGjhgtEXAb28ZrGzZZYtLZ0iTDulVlb3ww((MP00Zq(RHXuZHcA5L)bO)ClpJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMEKkdsXysjS8nqxtyiWLcIuDgqQaMHuCCiLC3MEdlSlKk2RyJHVdMWpj6xbrQoi18DHuCCiLaqkgtkHLVb6AcB6rQmiLC3MEdlS8nqxt4Ne9RGivhKA(US8Llsw((MP00Zq(RHXuZHcAb28Zj3BZZYtLZ0iTDulVlb3wwEg6H0li9W4CmZXy5L)bO)ClpJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMEKkdsXysjS8nqxtyiWLcIuDgqQaMHuCCiLC3MEdlSlKk2RyJHVdMWpj6xbrQoi18DHuCCiLaqkgtkHLVb6AcB6rQmiLC3MEdlS8nqxt4Ne9RGivhKA(US8LlswEg6H0li9W4CmZXyb28hzMnplpvotJ02rT8UeCBz5Ps3iimcUscmpf3um9UeCB5Ty)gsVLx(hG(ZT8mMuc7cPI9k2y47GjSPhP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHHaxkis1zaPcygsXXHuYDB6nSWUqQyVIng(oyc)KOFfeP6GuZ3fsXXHuYDB6nSWY3aDnHFs0VcIuDqQ57YYxUiz5Ps3iimcUscmpf3um9UeCB5Ty)gsVfyZFKaS5z5PYzAK2oQL3LGBllFp5FlQpH0dJYvS3HqlV8pa9NB5zmPe2fsf7vSXW3btytpsXXHumMuclFd01e20JuzqkgtkHLVb6AcdbUuqKQZasfWmlF5IKLVN8Vf1Nq6Hr5k27qOfyZFKCS5z5PYzAK2oQL3LGBllF6Eiik6acgH9bX2Ci0Yl)dq)5wEgtkHDHuXEfBm8DWe20JuCCifJjLWY3aDnHn9ivgKIXKsy5BGUMWpj6xbrQUhqQa6YYxUiz5t3dbrrhqWiSpi2MdHwGn)rgXMNLNkNPrA7OwExcUTS8Y9FtpG0r2MRphSpmksAV1UTS8Y)a0FULNXKsyxivSxXgdFhmHn9ifhhsXysjS8nqxtytpsLbPymPew(gORj8tI(vqKQBKkNzw(YfjlVC)30diDKT56Zb7dJIK2BTBllWM)iZBZZYtLZ0iTDulVlb3wwE5(VPhq6iBZ1Nd2hgzCnlz5L)bO)ClpJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMEKkdsXysjS8nqxt4Ne9RGiv3ivaDz5lxKS8Y9FtpG0r2MRphSpmY4AwYcS5psx28S8u5mnsBh1YxUiz5d)dmDfBesSIubIBkQFccCwhmz5Dj42YYh(hy6k2iKyfPce3uu)ee4SoyYcS5psU1MNLNkNPrA7OwExcUTS8WPvkiZbOhgtEXA5L)bO)ClpJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMElF5IKLhoTsbzoa9WyYlwlWM)i5oBEwEQCMgPTJA5lxKS8Tt4vSX9ArPxheqVL3LGBllF7eEfBCVwu61bb0Bb28hrGzZZYtLZ0iTDulVlb3ww()agVftKdMOpUPOPk2OlOLx(hG(ZT8mMuc7cPI9k2y47GjSPhP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHHaxkisnGubmdP44qk5Un9gwyxivSxXgdFhmHFs0VcIuDgqQrMHuCCiLC3MEdlS8nqxt4Ne9RGivNbKAKzw(Yfjl)FaJ3IjYbt0h3u0ufB0f0cS5psU3MNLNkNPrA7Ow(Yfjl)tIlGISMt7LKIAs4jjlVlb3ww(NexafznN2ljf1KWtswGn)5NzZZYtLZ0iTDulF5IKLx45T4MIqW(IqlVlb3wwEHN3IBkcb7lcTaB(ZhGnplpvotJ02rT8UeCBz5dNUVfEflm23mIolz5L)bO)ClpJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMEKkdsXysjS8nqxt4Ne9RGiv3divoZS8Llsw(WP7BHxXcJ9nJOZswGn)5ZXMNLNkNPrA7OwExcUTS86NCDKT56Zb7dJmUMLS8Y)a0FULNXKsyxivSxXgdFhmHn9ifhhsXysjS8nqxtytpsLbPymPew(gORj8tI(vqKQ7bKkNzw(YfjlV(jxhzBU(CW(WiJRzjlWM)8JyZZYtLZ0iTDulVlb3wwE9tUo6W(79caJIK2BTBllV8pa9NB5zmPe2fsf7vSXW3btytpsXXHumMuclFd01e20JuzqkgtkHLVb6Ac)KOFfeP6EaPYzMLVCrYYRFY1rh2FVxayuK0ERDBzb28NFEBEwEQCMgPTJA5Dj42YYZ(BXcJ9)j6T47SKLx(hG(ZT8caPymPe2fsf7vSXW3btytpsLbPeasXysjS8nqxtytVLVCrYYZ(BXcJ9)j6T47SKfyZF(US5z5PYzAK2oQL3LGBllp8QdcOpY2C95G9HrgxZswE5Fa6p3YZysjSlKk2RyJHVdMWMEKIJdPymPew(gORjSPhPYGumMuclFd01e(jr)kis19asfqxw(Yfjlp8QdcOpY2C95G9HrgxZswGn)5ZT28S8u5mnsBh1Y7sWTLLhE1bb0hzBU(CW(WOiP9w72YYl)dq)5wEgtkHDHuXEfBm8DWe20JuCCifJjLWY3aDnHn9ivgKIXKsy5BGUMWpj6xbrQUhqQCMz5lxKS8WRoiG(iBZ1Nd2hgfjT3A3wwGn)5ZD28S8u5mnsBh1Y7sWTLL3Nl4K)omM2ce3uSFdP3Yl)dq)5wEbGuaVrfalFd01eMkNPrAKkdsj3TP3Wc7cPI9k2y47Gj8tI(vqKQBKQlKIJdPaEJkaw(gORjmvotJ0ivgKsUBtVHfw(gORj8tI(vqKQBKQlKkdsborcP6GubmdP44qQPTfuSFdPhP6mGuJGuzqkWjsiv3ivaZqQmifWBubWHUGuCtrhorqmvotJ0w(YfjlVpxWj)DymTfiUPy)gsVfyZFEbMnplpvotJ02rT8UeCBz5fEWBR4MIAs8GKLx(hG(ZT8mMuc7cPI9k2y47GjSPhP44qkgtkHLVb6AcB6rQmifJjLWY3aDnHHaxkisnGubmdP44qk5Un9gwyxivSxXgdFhmHFs0VcIuDgqQrMHuCCiLC3MEdlS8nqxt4Ne9RGivNbKAKzw(YfjlVWdEBf3uutIhKSaB(ZN7T5z5PYzAK2oQL3LGBllVdNe6fbJVpx7hL77nlV8pa9NB51eJjLWVpx7hL77TOMymPewVHfsXXHuzHumMuc7cPI9k2y47Gj8tI(vqKQZasLZmKIJdPymPew(gORjme4sbrQbKkGzivgKIXKsy5BGUMWpj6xbrQoivaDHubJuzqQSqk5Un9gwywJ)6ZR4MI(Cr)cMWpj6xbrQoivUFgsXXHuGtKIGnQpcP6gPgzgsXXHucaPiiKkjHLBPPcs6y7suAFjHf95SpsfSLVCrYY7WjHErW47Z1(r5(EZcS531mBEwEQCMgPTJA5Dj42YYlyTG4MIEjpQaXK5dYYl)dq)5wEgtkHDHuXEfBm8DWe20JuCCifJjLWY3aDnHn9ivgKIXKsy5BGUMWqGlfeP6mGubmdP44qk5Un9gwyxivSxXgdFhmHFs0VcIuDqQrMHuCCiLaqkgtkHLVb6AcB6rQmiLC3MEdlS8nqxt4Ne9RGivhKAKzw(YfjlVG1cIBk6L8OcetMpilWMFxbyZZYtLZ0iTDulV8pa9NB5ZcPM2wqX(nKEKQZasnpsLbPaNiHuDJuDHuCCi102ck2VH0JuDgqQrqQmif4ejKQds1fsXXHuaVrfapTTGIUqQyPhtLZ0insLbPK720ByHN2wqrxivS0JFs0VcIudi1mKkyKkdsborkc24uplsnGuZS8UeCBz5DHuXEfBm8DWKfyZVRCS5z5PYzAK2oQLx(hG(ZT8zHutBlOy)gsps1zaPMhPYGuGtKqQUrQUqkooKAABbf73q6rQodi1iivgKcCIes1bP6cP44qkG3OcGN2wqrxivS0JPYzAKgPYGuYDB6nSWtBlOOlKkw6Xpj6xbrQbKAgsfmsLbPaNifbBCQNfPgqQzwExcUTS8Y3aDnzb287AeBEwExcUTS8oCIQ4K3ABOLNkNPrA7OwGn)UM3MNLNkNPrA7OwE5Fa6p3Ydorkc24uplsnGuZqQmivwivwifJjLWUqQyVIng(oycB6rkooKIXKsy5BGUMWMEKkyKIJdPYcPymPe2fsf7vSXW3bty9gwivgKsUBtVHf2fsf7vSXW3bt4Ne9RGivhKA(zifhhsXysjS8nqxty9gwivgKsUBtVHfw(gORj8tI(vqKQdsn)mKkyKkylVlb3ww(PTfu0fsfl9wGn)U6YMNLNkNPrA7OwE5Fa6p3YpTTGI9Bi9ivNbKAeKkdsj3TP3Wc7cPI9k2y47Gj8tI(vqKQdsXk1ivgKcCIueSXPEwKAaPMHuzqQSqkbGuaVrfadP37NormvotJ0ifhhsXysjmKEVF6eXMEKkylVlb3ww(0vEl(KuWTUI1cS53vU1MNLNkNPrA7OwE5Fa6p3YdorcP6EaPYbP44qkgtkHFskyJGWyAFjHn9wExcUTS8GjkAkM1u6yAFjzb287k3zZZYtLZ0iTDulV8pa9NB5zmPe2fsf7vSXW3btytpsXXHumMuclFd01e20JuzqkgtkHLVb6AcdbUuqKAaPcyML3LGBllptBxDCtrWefPIedYcS53LaZMNLNkNPrA7OwE5Fa6p3YlaKc4nQay5BGUMWu5mnsJuzqQSqk5Un9gwyxivSxXgdFhmHFs0VcIuDJuDHuzqQPTfuSFdPhP6mGuJGuCCiLC3MEdlSlKk2RyJHVdMWpj6xbrQodi18DHubJuCCivwifWBubWY3aDnHPYzAKgPYGuYDB6nSWY3aDnHFs0VcIuDJuSsnsLbPM2wqX(nKEKQZasnpsXXHuYDB6nSWY3aDnHFs0VcIuDgqQ57cPc2Y7sWTLLN14V(8kUPOpx0VGjlWMFx5EBEwEQCMgPTJA5L)bO)ClVC3MEdlSlKk2RyJHVdMWpj6xbrQUrkwPgPYGutBlOy)gsps1zaPgbP44qkG3OcGLVb6ActLZ0insLbPK720ByHLVb6Ac)KOFfeP6gPyLAKkdsnTTGI9Bi9ivNbKAEKIJdPK720ByHDHuXEfBm8DWe(jr)kis1zaPMVlKIJdPK720ByHLVb6Ac)KOFfeP6mGuZ3LL3LGBllF4(nTq6Q4tWT8sswGn)C7mBEwEQCMgPTJA5L)bO)ClFwiLaqQ3pDKesfa7Anet56GaisXXHuVF6ijKka21Ai(kKQdsnYmKIJdPG9uRfb(ZsaiwFcVIIqW(IivNbKkhKkyKkdsjaKklKIXKsyxivSxXgdFhmHn9ifhhsXysjS8nqxtytpsfmsLbPYcPK720ByHzAUMIBkohdeCsc)KOFfeP6GuSsnsjqi1iivgKsUBtVHfEognRiva8tI(vqKQdsXk1iLaHuJGubB5Dj42YYNwPbs6Opx0FakYqUOfyZp3gGnplpvotJ02rT8Y)a0FULplKIXKsyxivSxXgdFhmHn9ifhhsXysjS8nqxtytpsLbPymPew(gORjme4sbrQbKkGzivWivgKAABbf73q6rQUhqQrS8UeCBz5fjX9dkUPyZipDu)KlcTaB(52CS5z5PYzAK2oQLx(hG(ZT8zHucaPE)0rsivaSR1qmLRdcGifhhs9(PJKqQayxRH4RqQoi1iZqkooKc2tTwe4plbGy9j8kkcb7lIuDgqQCqQGT8UeCBz57n)Lc6k2itZHalWcSalWcSwa]] )


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
