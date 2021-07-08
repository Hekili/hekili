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

                return app + floor( t - app )
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


    spec:RegisterPack( "Retribution", 20210708, [[dSeBDbqirspcLu5sQGkTjuQpHskJIG6uuGvHs0RajMfkj3sfeTlK(LkudJQkhJczzuv1ZiiMgbPRbcTnuc6BOeyCOe6COKQADIeyEGG7rG9jsDqvqkleK0dvbLjQcQ6IIecBufuXhrjvXjfjKwjfQzksq3ufKQ2PkKHQcsLLksOEQiMQkWwfje9vusvASQGK9kP)kQbRQdlSyQYJjAYu6YqBguFMqJwIonWQfj61GuZMk3MI2nPFl1WvrhxfewoINJQPR01vPTtv57sy8uqNhenFuSFfxnQEqnXglwpYF)83i)yb(XIuJyriYcfclOMSqEI1KZqcDiI1enmXAskgxcW7UGwRjNbKUoS1dQj8(sKynPM4DbUnfvRE1eBSy9i)9ZFJ8Jf4hlsnIfHiefIqQj8tuwpIf4xnPeyTOw9QjwKlRjPyCjaV7cAD(dDHlSaDm24RdY5zrwnV)(5VrJXJXhwzOIipfmgFiNpfg89qYrzR25V8qeNVHNFjafAC5hFyhE(8AxmpCtM3R585HbILlF(wDqoVW2wzTD(IGV48h2HNpFRZVKGxAaDm(qo)H(aAC(eKeNLaZ5HVQCbToFrjQZF4a0WnFkgLq3kqfpofHHO8UGwNpb1fvjoFqW5BD(d7WppCtMpMVOe4W5fg(s2sKmpbDHHOD(wNNfCmlAaDm(qo)HM1opC4ChYTK0xXY5p8jhFqkY5lkrD(eKeNLaZJpCsXZheCElYHuLLOLwtojnmWH1ewhRB(umUeG3DbTo)HUWfwGogZ6yDZB81b58SiRM3F)83OX4XywhRB(dRmurKNcgJzDSU5pKZNcd(Ei5OSv78xEiIZ3WZVeGcnU8JpSdpFETlMhUjZ71C(8WaXYLpFRoiNxyBRS2oFrWxC(d7WZNV15xsWlnGogZ6yDZFiN)qFanoFcsIZsG58WxvUGwNVOe15pCaA4MpfJsOBfOIhNIWquExqRZNG6IQeNpi48To)HD4NhUjZhZxucC48cdFjBjsMNGUWq0oFRZZcoMfnGogZ6yDZFiN)qZANhoCUd5ws6Ry58h(KJpif58fLOoFcsIZsG5XhoP45dcoVf5qQYs0shJhJd5cALtpjOSn9IvWzVGwhJd5cALtpjOSn9Ifkco2ZHCoqfZnCMFnnrYyCixqRC6jbLTPxSqrWXEoKZbQyUHZXDVM6yCixqRC6jbLTPxSqrWXEoKZbQyUHZfaDrYyCixqRC6jbLTPxSqrWXEoKZbQyUHZ8tcqfhJd5cALtpjOSn9IfkcooiYqX82ecQlRaWc2WH6sHbA4YeucDRavKIA45ql7nCOUuosIZsGjf1WZH2X4X45hJzDSU5tryikVlANh9HeiNFbM48BjoFi3MmpGpF4laUWZH0X4qUGw5ciO3fACmoKlOvoueCSmCUCixqRzhGVSsdtuGSBNTlu(yCixqRCOi4yz4C5qUGwZoaFzLgMOarursSnHpgp)yCixqRCQSBNTluUGZEbTYkaSaVlmmn8HQiqfZfKylP3tggVlmmvsU8WI07jBVlmmvsU8WIu(gsOfyKFmmEnNZggiwUzcAgaLdb)H4yCixqRCQSBNTluoueCSdiwU8CkVwrtuxwbGfWprNlVbrexo1belxEoLxROjQBAb(ZWKkja2m6d1LgwlNIgc4lNHHeaBg9H6sdRLtbAAwaezyibWMrFOU0WA5075yCixqRCQSBNTluoueCmmGGEUUTScalW7cdtdFOkcuXCbj2s69KHX7cdtLKlpSi9EY27cdtLKlpSiLVHeAbg53yCixqRCQSBNTluoueCmVeGoBUHZ(qvedvIScalq4u3WH6srdr5DbTM5OUOkrkQHNdTmmYUD2UqPOHO8UGwZCuxuLiLGMbq5qaI(BaByGy5MjOzauEAJG4yCixqRCQSBNTluoueCSNd5CGkMB4m)AAIKX4qUGw5uz3oBxOCOi4yphY5avm3W54UxtDmoKlOvov2TZ2fkhkco2ZHCoqfZnCUaOlsgJd5cALtLD7SDHYHIGJ9CiNduXCdN5NeGkoghYf0kNk72z7cLdfbhF5ygSOjR0WefauUKC3WZH5dXn09AMTOpGezfawG3fgMg(qveOI5csSL07jdJ3fgMkjxEyr69KT3fgMkjxEyrkFdj0cmYpggVMZzddel3mbndGYHGq8BmoKlOvov2TZ2fkhkco(YXmyrtwPHjkO9HKIs0zcuX8zxGKSKajFdhRaWc8UWW0WhQIavmxqITKEpzy8UWWuj5YdlsVNS9UWWuj5Ydls5BiHwGr(XW41CoByGy5MjOzauoemcIJXHCbTYPYUD2Uq5qrWXxoMblAYknmrb2GaTz3A2IsOZ(AsiblKScalW7cdtdFOkcuXCbj2s69KHX7cdtLKlpSi9EY27cdtLKlpSiLVHeAbg5hdJxZ5SHbILBMGMbq5qWF)gJd5cALtLD7SDHYHIGJVCmdw0KvAyIcmdz4rWmVeXnBE5ajRaWc8UWW0WhQIavmxqITKEpzy8UWWuj5YdlsVNS9UWWuj5Ydls5BiHwGr(XW41CoByGy5MjOzauoe83VX4qUGw5uz3oBxOCOi44lhZGfnzLgMOalbdlmGGzFiNJUX4qUGw5uz3oBxOCOi44lhZGfnzLgMOao0xh0iHNlaQ4yCixqRCQSBNTluoueC8LJzWIMSsdtuGibyMLTfnCmoKlOvov2TZ2fkhkco(YXmyrtwPHjkWenBcK5goFg8nZbkFmoKlOvov2TZ2fkhkco(YXmyrtwPHjkGFgemBIXMl7g6X4qUGw5uz3oBxOCOi44lhZGfnzLgMOaoqHVUSOlSGyBcp7fwrm3WzyK0sWcjRaWc8UWW0WhQIavmxqITKEpzy8UWWuj5YdlsVNS9UWWuj5Ydls5BiHoTaJ8JHr2TZ2fkn8HQiqfZfKylPe0makpTqHidJSBNTluQKC5HfPe0makpTqH4yCixqRCQSBNTluoueC8LJzWIMSsdtuahOWxxo4NasOlp7fwrm3WzyK0sWcjRaWc8UWW0WhQIavmxqITKEpzy8UWWuj5YdlsVNS9UWWuj5Ydls5BiHoTaJ8JHr2TZ2fkn8HQiqfZfKylPe0makpTqHidJSBNTluQKC5HfPe0makpTqH4yCixqRCQSBNTluoueC8LJzWIMCwbGf4DHHPHpufbQyUGeBj9EYW4DHHPsYLhwKEpz7DHHPsYLhwKY3qcDAbg53yCixqRCQSBNTluoueCC4dvrGkMliXwYkaSaHlBhK5ZUajPfiu2lWeHaezykBhK5ZUajPfie2cVatmnezyixfHBIis3smBgIa(sIf55uETIMOUgWWSHd1Lw2oiZHpufrcf1WZHw2YUD2UqPLTdYC4dvrKqjOzauUa)mGTWPUHd1LYrsCwcmPOgEo0YWi72z7cLYrsCwcmPe0makpTFmmB4qDP8qLlagG2Cbj2skQHNdTgmghYf0kNk72z7cLdfbhljxEyrwbGfu2oiZNDbsslqOSxGjcbiYWu2oiZNDbsslqiSxGjMgImmB4qDPLTdYC4dvrKqrn8COLTSBNTluAz7Gmh(qvejucAgaLlWVX4qUGw5uz3oBxOCOi44GxIAUmCUUymoKlOvov2TZ2fkhkcoUSDqMdFOkIewbGfSatmVDU8uuGFSf27cdtdFOkcuXCbj2s69KHX7cdtLKlpSi9EYW4DHHPHpufbQyUGeBj12fkBz3oBxO0WhQIavmxqITKsqZaO80c1pggVlmmvsU8WIuBxOSLD7SDHsLKlpSiLGMbq5PfQFgmghYf0kNk72z7cLdfbhdd0WLjOe6wbQiRaWceUSDqMp7cKKwGqzVatecSidtz7GmF2fijTaHWEbMyAbSObSLD7SDHsdFOkcuXCbj2skbndGYtlkTSxGjM3oxEkkWp2cN6gouxkhjXzjWKIA45qldJ3fgMYrsCwcmP3tdylCQKayZOpuxAyTCkAiGVCggsaSz0hQlnSwo9EYWqcGnJ(qDPH1YPanTq9ZGX45hJd5cALtHbkGxIeUaFbbeEoKvAyIcS8Sm4B45qw5lCxua)eDU8gerC5ulWhqXmFBIPa)zNQWKRIWnrePWanCzFiXcKl7nCOUucqSCX(YZ(qIfixkQHNdTSLTAVGLUO5Pli8SpGAbYybTsrn8CO1agg(j6C5niI4YPwGpGIz(2eZ0(ZW4DHHPO5jKem08zxGe69KTf9UWW0uETIMOUuBxOS9UWWulWhqX85LC2CKA7cDmoKlOvofgOaEjs4qrWXCKeNLatwbGfiSSBNTluA4dvrGkMliXwsjOzauEAJGidJSBNTluQKC5HfPe0makpTrqKHzdhQlfgOHltqj0TcurkQHNdTgWw4u3WH6sHbA4YeucDRavKIA45qldJSBNTlukmqdxMGsOBfOIucAgaLN2F)GIO0YsHWWi72z7cLcd0WLjOe6wbQiLGMbq5qqGO0YsHWw4ujbWMrFOU0WA5u0qaF5mmKayZOpuxAyTCkqtlu)yyibWMrFOU0WA5uGcbrPLHHeaBg9H6sdRLtVNgyaBHtDdhQlfneL3f0AMJ6IQePOgEo0YWi72z7cLIgIY7cAnZrDrvIucAgaLNwiqKHr2TZ2fkfneL3f0AMJ6IQePe0makhcceLwwkegMnCOUuyGgUmbLq3kqfPOgEo0AaBHtv2(qn0LcnKeqOmmYUD2UqPwGpGI5TDokbndGYtluiYWi72z7cLAb(akM325Oe0makhcS(gWW41CoByGy5MjOzauoemcISHbILBMGMbq5PH4yCixqRCkmqb8sKWHIGJrdr5DbTM5OUOkrwbGfiS3fgMkjxEyrQTlu2YUD2UqPsYLhwKsqZaO80g5hdJ3fgMkjxEyrkFdj0Pfieggz3oBxO0WhQIavmxqITKsqZaO80g5NbSfo1nCOUuyGgUmbLq3kqfPOgEo0YWi72z7cLcd0WLjOe6wbQiLGMbq5PnYpdyVbrex6cmX82zlatZIJXHCbTYPWafWlrchkco2c8bumZ3MyYkaSaFbbeEoKA5zzW3WZHSt17cdt9f6H4c4LiHNldttKqVNSfw4u3WH6sLKlpSif1WZHwggz3oBxOuj5YdlsjOzauEArPLLcXa2cN6gouxkAikVlO1mh1fvjsrn8COLHr2TZ2fkfneL3f0AMJ6IQePe0makpTO0YswidJSBNTlukAikVlO1mh1fvjsjOzauEArPLLqKDz7GmF2fijTaHYWSbrex6cmX82zlaHalYWK6gouxkhjXzjWKIA45qlBz3oBxOu0quExqRzoQlQsKsqZaO80Isll93a2cN6gouxkmqdxMGsOBfOIuudphAzyKD7SDHsHbA4YeucDRavKsqZaO80IsllzHmmYUD2UqPWanCzckHUvGksjOzauEArPLLqKDz7GmF2fijTaHYWK6gouxkhjXzjWKIA45qlBz3oBxOuyGgUmbLq3kqfPe0makpTO0Ys)nGTWPUHd1LYrsCwcmPOgEo0YWi72z7cLYrsCwcmPe0mak)WvuAHsz7GmF2fijTqyy2WH6sHbA4YeucDRavKIA45qldZgouxkAikVlO1mh1fvjsrn8COLHr2(qn0LcnKeqOgWWi8gouxAz7Gmh(qvejuudphAzl72z7cLw2oiZHpufrcLGMbq5qquAzPqyy8UWW0Y2bzo8HQisO3tggVlmmvsU8WI07jBVlmmvsU8WIu(gsOHGr(zGbJXHCbTYPWafWlrchkcoErZtxq4zFiXcKlRaWceo1nCOUuj5Ydlsrn8COLHr2TZ2fkvsU8WIucAgaLNwuAzPqmGTWPUHd1LIgIY7cAnZrDrvIuudphAzyKD7SDHsrdr5DbTM5OUOkrkbndGYtlkTSKfYWi72z7cLIgIY7cAnZrDrvIucAgaLNwuAzjezx2oiZNDbsslqOmmBqeXLUatmVD2cqiWImmPUHd1LYrsCwcmPOgEo0Yw2TZ2fkfneL3f0AMJ6IQePe0makpTO0Ys)nGTWPUHd1Lcd0WLjOe6wbQif1WZHwggz3oBxOuyGgUmbLq3kqfPe0makpTO0YswidJSBNTlukmqdxMGsOBfOIucAgaLNwuAzjezx2oiZNDbsslqOmmPUHd1LYrsCwcmPOgEo0Yw2TZ2fkfgOHltqj0TcurkbndGYtlkTS0FdylCQB4qDPCKeNLatkQHNdTmmYUD2UqPCKeNLatkbndGYpCfLwOu2oiZNDbsslegMnCOUuyGgUmbLq3kqfPOgEo0YWSHd1LIgIY7cAnZrDrvIuudphAzyKTpudDPqdjbeQbmmB4qDPLTdYC4dvrKqrn8COLTSBNTluAz7Gmh(qvejucAgaLdbrPLLcHHX7cdtlBhK5WhQIiHEpzy8UWWuj5YdlsVNS9UWWuj5Ydls5BiHgcg53yCixqRCkmqb8sKWHIGJTaFafZ8TjMScalWxqaHNdPwEwg8n8Ci7nCOUuosIZsGjf1WZHw2YUD2UqPCKeNLatkbdlKSlBhK5ZUajckBhK5ZUajuZWq2B4qDPOHO8UGwZCuxuLif1WZHw2YUD2UqPOHO8UGwZCuxuLiLGMbq5PfklfL2X4qUGw5uyGc4LiHdfbhVO5Pli8SpKybYLvaybB4qDPCKeNLatkQHNdTSLD7SDHs5ijolbMucgwizx2oiZNDbseu2oiZNDbsOMHHS3WH6srdr5DbTM5OUOkrkQHNdTSLD7SDHsrdr5DbTM5OUOkrkbndGYtluwkkTJXZpghYf0kNkIksITjCbYW5YHCbTMDa(YknmrbWafWlrcNvaybLTdY8zxGebqKHX7cdtlBhK5WhQIiHEpzySO3fgMcd0WLjOe6wbQi9EYWyrVlmmfneL3f0AMJ6IQeP3ZX4qUGw5urursSnHdfbh7l0dXfWlrcpxgMMizmoKlOvovevKeBt4qrWXwGpGI5TDowbGfKQf9UWW0uETIMOU07jBHtDdhQlLJK4Seysrn8COLHX7cdt5ijolbM07PbSfovsaSz0hQlnSwofneWxoddja2m6d1LgwlNc00cXpggsaSz0hQlnSwo9EAaBHlBhK5ZUajqqG)mmLTdY8zxGeiiqOSfw2TZ2fk1Zfwm3W5uE5lqIucAgaLNwuAzP)mmw07cdtrdr5DbTM5OUOkr69KHXIExyykmqdxMGsOBfOI07PbgWw4u3WH6sHbA4YeucDRavKIA45qldJSBNTlukmqdxMGsOBfOIucAgaLNwuAzPr(zaBHtDdhQlfneL3f0AMJ6IQePOgEo0YWi72z7cLIgIY7cAnZrDrvIucAgaLNwuAzPr(XWSbrex6cmX82zlaHalAaBHLD7SDHsdFOkcuXCbj2skbndGYzyKD7SDHsLKlpSiLGMbq5gmghYf0kNkIksITjCOi44YW0ej5goxqITKvaybKRIWnrePBjMndB(miHyRmmKRIWnreP(cv8gelpB2MOUxt2B4qDPOHO8UGwZCuxuLif1WZHwggz7d1qxQpu3sijSLD7SDHsdEjQ5YW56ckbndGYt7Vr(nghYf0kNkIksITjCOi44uETIMOUScalivl6DHHPP8AfnrDP3t2ExyyAz7Gmh(qvej075yCixqRCQiQij2MWHIGJlcOXCdNdEjYzfawGWLTdY8zxGeiiWF2B4qDPOHO8UGwZCuxuLif1WZHw2w07cdtrdr5DbTM5OUOkrkbndGYt7hBl6DHHPOHO8UGwZCuxuLiLGMbq5qquAzP)gmghYf0kNkIksITjCOi4ypxyXCdNt5LVajYkaSGY2bz(Slqceeie2B4qDPEUWI5goxqITKIA45qlBH3WH6sHbA4YeucDRavKIA45qlBl6DHHPWanCzckHUvGksjOzauEArPLL(ZWSHd1LIgIY7cAnZrDrvIuudphAzN6gouxkmqdxMGsOBfOIuudphAzlSf9UWWu0quExqRzoQlQsKEpzyKD7SDHsrdr5DbTM5OUOkrkbndGYf4NbgmghYf0kNkIksITjCOi44uETIMOUScalivl6DHHPP8AfnrDP3t2B4qDPCKeNLatkQHNdTSfUSDqMp7cKKwGrSjxfHBIis3smBgIa(sIf55uETIMOUmmLTdY8zxGK0c83GX4qUGw5urursSnHdfbhxeqJ5goh8sKZkaSaHlBhK5ZUajc8JHPSDqMp7cKabb(Zwyz3oBxOupxyXCdNt5LVajsjOzauEArPLL(ZWyrVlmmfneL3f0AMJ6IQeP3tgMniI4sxGjM3oBbieyrggl6DHHPWanCzckHUvGksVNgyaBHtLeaBg9H6sdRLtrdb8LZWqcGnJ(qDPH1YPanT)(XWqcGnJ(qDPH1YP3tdylCQB4qDPOHO8UGwZCuxuLif1WZHwggz3oBxOu0quExqRzoQlQsKsqZaO80gbrgMniI4sxGjM3oBbieyrdylCQB4qDPWanCzckHUvGksrn8COLHr2TZ2fkfgOHltqj0TcurkbndGYtBeezy2GiIlDbMyE7SfGqGfnGTWYUD2UqPHpufbQyUGeBjLGMbq5mmYUD2UqPsYLhwKsqZaOCdgJd5cALtfrfjX2eoueCSmCUCixqRzhGVSsdtuamqb8sKWzfawqz7GmF2fijTaHW27cdtLKlpSi9EY27cdtLKlpSiLVHeAiyKFJXHCbTYPIOIKyBchkco2Zfwm3W5uE5lqIScalOSDqMp7cKabbcHTSv7fSu0WZlrmwqRuudphAzNQS9HAOl1hQBjKKX4qUGw5urursSnHdfbhNYRv0e1LvaybPArVlmmnLxROjQl9EoghYf0kNkIksITjCOi44YW0ej5goxqITCmoKlOvovevKeBt4qrWXEUWI5goNYlFbsKvaybLTdY8zxGeiiqiJXHCbTYPIOIKyBchkcowgoxoKlO1SdWxwPHjkagOaEjs4Scalq4niI4slXWTL0t5cbb(7hdJ3fgMg(qveOI5csSL07jdJ3fgMkjxEyr69KHX7cdtrZtijyO5ZUaj07PbJXHCbTYPIOIKyBchkcowsU8WIKmFjaOrwbGfi72z7cLkjxEyrsMVea0ivwgerKNHjHCbTgU0cmIYcGiBHlBhK5ZUajqqG)mmLTdY8zxGeiiqiSLD7SDHs9CHfZnCoLx(cKiLGMbq5PfLww6pdtz7GmF2firGqzl72z7cL65clMB4CkV8firkbndGYtlkTS0F2YUD2UqPP8AfnrDPe0makpTO0Ys)nymoKlOvovevKeBt4qrWXYw5OKelOvwbGfKQSvokjXcALEpzZprNlVbrexo1c8bumZ3MyMwG)JXHCbTYPIOIKyBchkcowgoxoKlO1SdWxwPHjkagOaEjs4JXHCbTYPIOIKyBchkcow2khLKybTYkaSGuLTYrjjwqR075yCixqRCQiQij2MWHIGJLKlpSijZxcaACmoKlOvovevKeBt4qrWXbrgkM3MqqDhJd5cALtfrfjX2eoueCSSvokjXcATM4djCqR1J83p)nYpHyelOMueefOI8AcR3dTu8rPOhX6jfm)8huIZdmpBYopCtMN1KD7SDHYzT5j4H4ciODEEBIZh3TnJfTZlldve50X4uiqX593OuW8hwR(qYI25znYvr4MiI0dfRn)2ZZAKRIWnrePhkkQHNdTS28cBKHgqhJhJz9EOLIpkf9iwpPG5N)GsCEG5zt25HBY8Sgmqb8sKWzT5j4H4ciODEEBIZh3TnJfTZlldve50X4uiqX5nkfm)H1QpKSODEwJCveUjIi9qXAZV98Sg5QiCter6HIIA45qlRnVWgzOb0X4uiqX5fAky(dRvFizr78jaZdBEoK6ggo)H78BpFk8gZBb(aCqRZ3Nij2MmVWhBW8cBKHgqhJtHafNhIPG5pSw9HKfTZNampS55qQBy48hUZV98PWBmVf4dWbToFFIKyBY8cFSbZlSrgAaDmEmM17Hwk(Ou0Jy9KcMF(dkX5bMNnzNhUjZZAIOIKyBcN1MNGhIlGG255TjoFC32mw0oVSmurKthJtHafNxOPG5pSw9HKfTZZAKRIWnrePhkwB(TNN1ixfHBIispuuudphAzT5f2idnGogNcbkoVqtbZFyT6djlANN1ixfHBIispuS28BppRrUkc3erKEOOOgEo0YAZlSrgAaDmofcuCEwmfm)H1QpKSODEwJCveUjIi9qXAZV98Sg5QiCter6HIIA45qlRnVWgzOb0X4X4uuZZMSODEioFixqRZ7a8LthJRjoaF51dQjweoUUTEq9iJQhutc5cATMqqVl0ynb1WZH2kuRB9i)Rhutqn8COTc1AsixqR1ez4C5qUGwZoaFRjoaFZAyI1ez3oBxO86wpsi1dQjOgEo0wHAnjKlO1AImCUCixqRzhGV1ehGVznmXAIiQij2MWRBDRjNeu2MEXwpOEKr1dQjHCbTwto7f0Anb1WZH2kuRB9i)Rhutc5cATM45qohOI5goZVMMiPMGA45qBfQ1TEKqQhutc5cATM45qohOI5goh39AQ1eudphARqTU1JeA9GAsixqR1ephY5avm3W5cGUiPMGA45qBfQ1TEeeRhutc5cATM45qohOI5goZpjavSMGA45qBfQ1TEelSEqnb1WZH2kuRjscyrciQjB4qDPWanCzckHUvGksrn8CODE2ZVHd1LYrsCwcmPOgEo0wtc5cATMeezOyEBcb1TU1TMiIksITj86b1JmQEqnb1WZH2kuRjscyrciQjLTdY8zxGK5fmpeNNHzEVlmmTSDqMdFOkIe69CEgM5TO3fgMcd0WLjOe6wbQi9EopdZ8w07cdtrdr5DbTM5OUOkr69SMeYf0AnrgoxoKlO1SdW3AIdW3SgMynbgOaEjs41TEK)1dQjHCbTwt8f6H4c4LiHNldttKutqn8COTc16wpsi1dQjOgEo0wHAnrsalsarnj15TO3fgMMYRv0e1LEpNN98cpFQZVHd1LYrsCwcmPOgEo0opdZ8ExyykhjXzjWKEpN3G5zpVWZN68KayZOpuxAyTCkAiGV85zyMNeaBg9H6sdRLtb68PNxi(npdZ8KayZOpuxAyTC69CEdMN98cpFz7GmF2fizEiiyE)NNHz(Y2bz(SlqY8qqW8cDE2Zl88YUD2UqPEUWI5goNYlFbsKsqZaO85tpVO0oplN3)5zyM3IExyykAikVlO1mh1fvjsVNZZWmVf9UWWuyGgUmbLq3kqfP3Z5nyEdMN98cpFQZVHd1Lcd0WLjOe6wbQif1WZH25zyMx2TZ2fkfgOHltqj0TcurkbndGYNp98Is78SCEJ8BEdMN98cpFQZVHd1LIgIY7cAnZrDrvIuudphANNHzEz3oBxOu0quExqRzoQlQsKsqZaO85tpVO0oplN3i)MNHz(niI4sxGjM3oBb48qyEwCEdMN98cpVSBNTluA4dvrGkMliXwsjOzau(8mmZl72z7cLkjxEyrkbndGYN3GAsixqR1elWhqX82oxDRhj06b1eudphARqTMijGfjGOMqUkc3erKULy2mS5ZGeITsrn8CODEgM5jxfHBIis9fQ4niwE2SnrDVMuudphANN98B4qDPOHO8UGwZCuxuLif1WZH25zyMx2(qn0L6d1TesY8SNx2TZ2fkn4LOMldNRlOe0makF(0Z7Vr(vtc5cATMugMMij3W5csSL1TEeeRhutqn8COTc1AIKawKaIAsQZBrVlmmnLxROjQl9Eop759UWW0Y2bzo8HQisO3ZAsixqR1KuETIMOU1TEelSEqnb1WZH2kuRjscyrciQjcpFz7GmF2fizEiiyE)NN98B4qDPOHO8UGwZCuxuLif1WZH25zpVf9UWWu0quExqRzoQlQsKsqZaO85tpVFZZEEl6DHHPOHO8UGwZCuxuLiLGMbq5ZdH5fL25z58(pVb1KqUGwRjfb0yUHZbVe51TEelOEqnb1WZH2kuRjscyrciQjLTdY8zxGK5HGG5fY8SNFdhQl1Zfwm3W5csSLuudphANN98cp)gouxkmqdxMGsOBfOIuudphANN98w07cdtHbA4YeucDRavKsqZaO85tpVO0oplN3)5zyMFdhQlfneL3f0AMJ6IQePOgEo0op75tD(nCOUuyGgUmbLq3kqfPOgEo0op75fEEl6DHHPOHO8UGwZCuxuLi9EopdZ8YUD2UqPOHO8UGwZCuxuLiLGMbq5ZlyE)M3G5nOMeYf0AnXZfwm3W5uE5lqI1TEelwpOMGA45qBfQ1ejbSibe1KuN3IExyyAkVwrtux69CE2ZVHd1LYrsCwcmPOgEo0op75fE(Y2bz(SlqY8PfmVrZZEEYvr4MiI0TeZMHiGVKyrEoLxROjQlf1WZH25zyMVSDqMp7cKmFAbZ7)8gutc5cATMKYRv0e1TU1Jy9Rhutqn8COTc1AIKawKaIAIWZx2oiZNDbsMxW8(npdZ8LTdY8zxGK5HGG59FE2Zl88YUD2UqPEUWI5goNYlFbsKsqZaO85tpVO0oplN3)5zyM3IExyykAikVlO1mh1fvjsVNZZWm)gerCPlWeZBNTaCEimplopdZ8w07cdtHbA4YeucDRavKEpN3G5nyE2Zl88Popja2m6d1LgwlNIgc4lFEgM5jbWMrFOU0WA5uGoF6593V5zyMNeaBg9H6sdRLtVNZBW8SNx45tD(nCOUu0quExqRzoQlQsKIA45q78mmZl72z7cLIgIY7cAnZrDrvIucAgaLpF65ncIZZWm)gerCPlWeZBNTaCEimploVbZZEEHNp153WH6sHbA4YeucDRavKIA45q78mmZl72z7cLcd0WLjOe6wbQiLGMbq5ZNEEJG48mmZVbrex6cmX82zlaNhcZZIZBW8SNx45LD7SDHsdFOkcuXCbj2skbndGYNNHzEz3oBxOuj5YdlsjOzau(8gutc5cATMueqJ5goh8sKx36rg5x9GAcQHNdTvOwtKeWIequtkBhK5ZUajZNwW8czE2Z7DHHPsYLhwKEpNN98ExyyQKC5HfP8nKqppeM3i)QjHCbTwtKHZLd5cAn7a8TM4a8nRHjwtGbkGxIeEDRhzKr1dQjOgEo0wHAnrsalsarnPSDqMp7cKmpeemVqMN98YwTxWsrdpVeXybTsrn8CODE2ZN68Y2hQHUuFOULqsQjHCbTwt8CHfZnCoLx(cKyDRhzK)1dQjOgEo0wHAnrsalsarnj15TO3fgMMYRv0e1LEpRjHCbTwts51kAI6w36rgjK6b1KqUGwRjLHPjsYnCUGeBznb1WZH2kuRB9iJeA9GAcQHNdTvOwtKeWIequtkBhK5ZUajZdbbZlKAsixqR1epxyXCdNt5LVajw36rgbX6b1eudphARqTMijGfjGOMi88BqeXLwIHBlPNYDEiiyE)9BEgM59UWW0WhQIavmxqITKEpNNHzEVlmmvsU8WI0758mmZ7DHHPO5jKem08zxGe69CEdQjHCbTwtKHZLd5cAn7a8TM4a8nRHjwtGbkGxIeEDRhzelSEqnb1WZH2kuRjscyrciQjYUD2UqPsYLhwKK5lbansLLbre5zysixqRHB(0cM3iklaIZZEEHNVSDqMp7cKmpeemV)ZZWmFz7GmF2fizEiiyEHmp75LD7SDHs9CHfZnCoLx(cKiLGMbq5ZNEErPDEwoV)ZZWmFz7GmF2fizEbZl05zpVSBNTluQNlSyUHZP8YxGePe0makF(0ZlkTZZY59FE2Zl72z7cLMYRv0e1LsqZaO85tpVO0oplN3)5nOMeYf0AnrsU8WIKmFjaOX6wpYiwq9GAcQHNdTvOwtKeWIequtsDEzRCusIf0k9Eop755NOZL3GiIlNAb(akM5BtmNpTG59VMeYf0Anr2khLKybTw36rgXI1dQjOgEo0wHAnjKlO1AImCUCixqRzhGV1ehGVznmXAcmqb8sKWRB9iJy9Rhutqn8COTc1AIKawKaIAsQZlBLJssSGwP3ZAsixqR1ezRCusIf0ADRh5VF1dQjHCbTwtKKlpSijZxcaASMGA45qBfQ1TEK)gvpOMeYf0AnjiYqX82ecQBnb1WZH2kuRB9i)9VEqnjKlO1AISvokjXcATMGA45qBfQ1TU1eyGc4LiHxpOEKr1dQjOgEo0wHAnPpRjCCRjHCbTwt8feq45WAIVWDXAc)eDU8gerC5ulWhqXmFBI58cM3)5zpFQZl88KRIWnrePWanCzFiXcKlf1WZH25zp)gouxkbiwUyF5zFiXcKlf1WZH25zpVSv7fS0fnpDbHN9bulqglOvkQHNdTZBW8mmZZprNlVbrexo1c8bumZ3MyoF659FEgM59UWWu08escgA(Slqc9Eop75TO3fgMMYRv0e1LA7cDE2Z7DHHPwGpGI5Zl5S5i12fAnXxqYAyI1elpld(gEoSU1J8VEqnb1WZH2kuRjscyrciQjcpVSBNTluA4dvrGkMliXwsjOzau(8PN3iiopdZ8YUD2UqPsYLhwKsqZaO85tpVrqCEgM53WH6sHbA4YeucDRavKIA45q78gmp75fE(uNFdhQlfgOHltqj0TcurkQHNdTZZWmVSBNTlukmqdxMGsOBfOIucAgaLpF6593V5HY8Is78SCEHmpdZ8YUD2UqPWanCzckHUvGksjOzau(8qqW8Is78SCEHmp75fE(uNNeaBg9H6sdRLtrdb8LppdZ8KayZOpuxAyTCkqNp98c1V5zyMNeaBg9H6sdRLtb68qyErPDEgM5jbWMrFOU0WA50758gmVbZZEEHNp153WH6srdr5DbTM5OUOkrkQHNdTZZWmVSBNTlukAikVlO1mh1fvjsjOzau(8PNxiqCEgM5LD7SDHsrdr5DbTM5OUOkrkbndGYNhccMxuANNLZlK5zyMFdhQlfgOHltqj0TcurkQHNdTZBW8SNx45tDEz7d1qxk0qsaHopdZ8YUD2UqPwGpGI5TDokbndGYNp98cfIZZWmVSBNTluQf4dOyEBNJsqZaO85HW8S(ZBW8mmZ71C(8SNhgiwUzcAgaLppeM3iiop75HbILBMGMbq5ZNEEiwtc5cATMWrsCwcmRB9iHupOMGA45qBfQ1ejbSibe1eHN37cdtLKlpSi12f68SNx2TZ2fkvsU8WIucAgaLpF65nYV5zyM37cdtLKlpSiLVHe65tlyEHmpdZ8YUD2UqPHpufbQyUGeBjLGMbq5ZNEEJ8BEdMN98cpFQZVHd1Lcd0WLjOe6wbQif1WZH25zyMx2TZ2fkfgOHltqj0TcurkbndGYNp98g538gmp753GiIlDbMyE7SfGZNEEwSMeYf0AnbneL3f0AMJ6IQeRB9iHwpOMGA45qBfQ1ejbSibe1eFbbeEoKA5zzW3WZHZZE(uN37cdt9f6H4c4LiHNldttKqVNZZEEHNx45tD(nCOUuj5Ydlsrn8CODEgM5LD7SDHsLKlpSiLGMbq5ZNEErPDEwoVqM3G5zpVWZN68B4qDPOHO8UGwZCuxuLif1WZH25zyMx2TZ2fkfneL3f0AMJ6IQePe0makF(0ZlkTZZY5zHZZWmVSBNTlukAikVlO1mh1fvjsjOzau(8PNxuANNLZdX5zpFz7GmF2fiz(0cMxOZZWm)gerCPlWeZBNTaCEimplopdZ8Po)gouxkhjXzjWKIA45q78SNx2TZ2fkfneL3f0AMJ6IQePe0makF(0ZlkTZZY59FEdMN98cpFQZVHd1Lcd0WLjOe6wbQif1WZH25zyMx2TZ2fkfgOHltqj0TcurkbndGYNp98Is78SCEw48mmZl72z7cLcd0WLjOe6wbQiLGMbq5ZNEErPDEwopeNN98LTdY8zxGK5tlyEHopdZ8Po)gouxkhjXzjWKIA45q78SNx2TZ2fkfgOHltqj0TcurkbndGYNp98Is78SCE)N3G5zpVWZN68B4qDPCKeNLatkQHNdTZZWmVSBNTlukhjXzjWKsqZaO85pEErPDEOmFz7GmF2fiz(0ZlK5zyMFdhQlfgOHltqj0TcurkQHNdTZZWm)gouxkAikVlO1mh1fvjsrn8CODEgM5LTpudDPqdjbe68gmpdZ8cp)gouxAz7Gmh(qvejuudphANN98YUD2UqPLTdYC4dvrKqjOzau(8qyErPDEwoVqMNHzEVlmmTSDqMdFOkIe69CEgM59UWWuj5YdlsVNZZEEVlmmvsU8WIu(gsONhcZBKFZBW8gutc5cATMyb(akM5BtmRB9iiwpOMGA45qBfQ1ejbSibe1eHNp153WH6sLKlpSif1WZH25zyMx2TZ2fkvsU8WIucAgaLpF65fL25z58czEdMN98cpFQZVHd1LIgIY7cAnZrDrvIuudphANNHzEz3oBxOu0quExqRzoQlQsKsqZaO85tpVO0oplNNfopdZ8YUD2UqPOHO8UGwZCuxuLiLGMbq5ZNEErPDEwopeNN98LTdY8zxGK5tlyEHopdZ8BqeXLUatmVD2cW5HW8S48mmZN68B4qDPCKeNLatkQHNdTZZEEz3oBxOu0quExqRzoQlQsKsqZaO85tpVO0oplN3)5nyE2Zl88Po)gouxkmqdxMGsOBfOIuudphANNHzEz3oBxOuyGgUmbLq3kqfPe0makF(0ZlkTZZY5zHZZWmVSBNTlukmqdxMGsOBfOIucAgaLpF65fL25z58qCE2Zx2oiZNDbsMpTG5f68mmZN68B4qDPCKeNLatkQHNdTZZEEz3oBxOuyGgUmbLq3kqfPe0makF(0ZlkTZZY59FEdMN98cpFQZVHd1LYrsCwcmPOgEo0opdZ8YUD2UqPCKeNLatkbndGYN)45fL25HY8LTdY8zxGK5tpVqMNHz(nCOUuyGgUmbLq3kqfPOgEo0opdZ8B4qDPOHO8UGwZCuxuLif1WZH25zyMx2(qn0LcnKeqOZBW8mmZVHd1Lw2oiZHpufrcf1WZH25zpVSBNTluAz7Gmh(qvejucAgaLppeMxuANNLZlK5zyM37cdtlBhK5WhQIiHEpNNHzEVlmmvsU8WI0758SN37cdtLKlpSiLVHe65HW8g5xnjKlO1AYIMNUGWZ(qIfi36wpIfwpOMGA45qBfQ1ejbSibe1eFbbeEoKA5zzW3WZHZZE(nCOUuosIZsGjf1WZH25zpVSBNTlukhjXzjWKsWWc58SNVSDqMp7cKmVG5lBhK5ZUajuZWW5zp)gouxkAikVlO1mh1fvjsrn8CODE2Zl72z7cLIgIY7cAnZrDrvIucAgaLpF65f68SCErPTMeYf0AnXc8bumZ3Myw36rSG6b1eudphARqTMijGfjGOMSHd1LYrsCwcmPOgEo0op75LD7SDHs5ijolbMucgwiNN98LTdY8zxGK5fmFz7GmF2fiHAggop753WH6srdr5DbTM5OUOkrkQHNdTZZEEz3oBxOu0quExqRzoQlQsKsqZaO85tpVqNNLZlkT1KqUGwRjlAE6ccp7djwGCRBDRjYUD2Uq51dQhzu9GAcQHNdTvOwtKeWIequt8UWW0WhQIavmxqITKEpNNHzEVlmmvsU8WI0758SN37cdtLKlpSiLVHe65fmVr(npdZ8EnNpp75HbILBMGMbq5ZdH59hI1KqUGwRjN9cATU1J8VEqnb1WZH2kuRjscyrciQj8t05YBqeXLtDaXYLNt51kAI6oFAbZ7)8mmZN68KayZOpuxAyTCkAiGV85zyMNeaBg9H6sdRLtb68PNNfaX5zyMNeaBg9H6sdRLtVN1KqUGwRjoGy5YZP8AfnrDRB9iHupOMGA45qBfQ1ejbSibe1eVlmmn8HQiqfZfKylP3Z5zyM37cdtLKlpSi9Eop759UWWuj5Ydls5BiHEEbZBKF1KqUGwRjWac6562w36rcTEqnb1WZH2kuRjscyrciQjcpFQZVHd1LIgIY7cAnZrDrvIuudphANNHzEz3oBxOu0quExqRzoQlQsKsqZaO85HW8q0)5nyE2Zddel3mbndGYNp98gbXAsixqR1eEjaD2CdN9HQigQeRB9iiwpOMeYf0AnXZHCoqfZnCMFnnrsnb1WZH2kuRB9iwy9GAsixqR1ephY5avm3W54UxtTMGA45qBfQ1TEelOEqnjKlO1AINd5CGkMB4CbqxKutqn8COTc16wpIfRhutc5cATM45qohOI5goZpjavSMGA45qBfQ1TEeRF9GAcQHNdTvOwtc5cATMauUKC3WZH5dXn09AMTOpGeRjscyrciQjExyyA4dvrGkMliXwsVNZZWmV3fgMkjxEyr69CE2Z7DHHPsYLhwKY3qc98cM3i)MNHzEVMZNN98WaXYntqZaO85HW8cXVAIgMynbOCj5UHNdZhIBO71mBrFajw36rg5x9GAcQHNdTvOwtc5cATM0(qsrj6mbQy(SlqswsGKVHRMijGfjGOM4DHHPHpufbQyUGeBj9EopdZ8ExyyQKC5HfP3Z5zpV3fgMkjxEyrkFdj0ZlyEJ8BEgM59AoFE2Zddel3mbndGYNhcZBeeRjAyI1K2hskkrNjqfZNDbsYscK8nC1TEKrgvpOMGA45qBfQ1KqUGwRj2GaTz3A2IsOZ(AsiblK1ejbSibe1eVlmmn8HQiqfZfKylP3Z5zyM37cdtLKlpSi9Eop759UWWuj5Ydls5BiHEEbZBKFZZWmVxZ5ZZEEyGy5MjOzau(8qyE)9RMOHjwtSbbAZU1SfLqN91KqcwiRB9iJ8VEqnb1WZH2kuRjHCbTwtmdz4rWmVeXnBE5aznrsalsarnX7cdtdFOkcuXCbj2s69CEgM59UWWuj5YdlsVNZZEEVlmmvsU8WIu(gsONxW8g538mmZ71C(8SNhgiwUzcAgaLppeM3F)QjAyI1eZqgEemZlrCZMxoqw36rgjK6b1eudphARqTMOHjwtSemSWacM9HCo6QjHCbTwtSemSWacM9HCo6QB9iJeA9GAcQHNdTvOwt0WeRjCOVoOrcpxauXAsixqR1eo0xh0iHNlaQyDRhzeeRhutqn8COTc1AIgMynrKamZY2Igwtc5cATMisaMzzBrdRB9iJyH1dQjOgEo0wHAnrdtSMyIMnbYCdNpd(M5aLxtc5cATMyIMnbYCdNpd(M5aLx36rgXcQhutqn8COTc1AIgMynHFgemBIXMl7g6AsixqR1e(zqWSjgBUSBORB9iJyX6b1eudphARqTMeYf0AnHdu4Rll6cli2MWZEHveZnCggjTeSqwtKeWIequt8UWW0WhQIavmxqITKEpNNHzEVlmmvsU8WI0758SN37cdtLKlpSiLVHe65tlyEJ8BEgM5LD7SDHsdFOkcuXCbj2skbndGYNp98cfIZZWmVSBNTluQKC5HfPe0makF(0Zluiwt0WeRjCGcFDzrxybX2eE2lSIyUHZWiPLGfY6wpYiw)6b1eudphARqTMeYf0AnHdu4Rlh8taj0LN9cRiMB4mmsAjyHSMijGfjGOM4DHHPHpufbQyUGeBj9EopdZ8ExyyQKC5HfP3Z5zpV3fgMkjxEyrkFdj0ZNwW8g538mmZl72z7cLg(qveOI5csSLucAgaLpF65fkeNNHzEz3oBxOuj5YdlsjOzau(8PNxOqSMOHjwt4af(6Yb)eqcD5zVWkI5godJKwcwiRB9i)9REqnb1WZH2kuRjscyrciQjExyyA4dvrGkMliXwsVNZZWmV3fgMkjxEyr69CE2Z7DHHPsYLhwKY3qc98PfmVr(vtc5cATMC5ygSOjVU1J83O6b1eudphARqTMijGfjGOMi88LTdY8zxGK5tlyEHop75xGjopeMhIZZWmFz7GmF2fiz(0cMxiZZEEHNFbM48PNhIZZWmp5QiCter6wIzZqeWxsSipNYRv0e1LIA45q78gmpdZ8B4qDPLTdYC4dvrKqrn8CODE2Zl72z7cLw2oiZHpufrcLGMbq5ZlyE)M3G5zpVWZN68B4qDPCKeNLatkQHNdTZZWmVSBNTlukhjXzjWKsqZaO85tpVFZZWm)gouxkpu5cGbOnxqITKIA45q78gutc5cATMe(qveOI5csSL1TEK)(xpOMGA45qBfQ1ejbSibe1KY2bz(SlqY8PfmVqNN98lWeNhcZdX5zyMVSDqMp7cKmFAbZlK5zp)cmX5tppeNNHz(nCOU0Y2bzo8HQisOOgEo0op75LD7SDHslBhK5WhQIiHsqZaO85fmVF1KqUGwRjsYLhwSU1J8xi1dQjHCbTwtcEjQ5YW56IAcQHNdTvOw36r(l06b1eudphARqTMijGfjGOMSatmVDU8uCEbZ738SNx459UWW0WhQIavmxqITKEpNNHzEVlmmvsU8WI0758mmZ7DHHPHpufbQyUGeBj12f68SNx2TZ2fkn8HQiqfZfKylPe0makF(0Zlu)MNHzEVlmmvsU8WIuBxOZZEEz3oBxOuj5YdlsjOzau(8PNxO(nVb1KqUGwRjLTdYC4dvrKu36r(dX6b1eudphARqTMijGfjGOMi88LTdY8zxGK5tlyEHop75xGjopeMNfNNHz(Y2bz(SlqY8PfmVqMN98lWeNpTG5zX5nyE2Zl72z7cLg(qveOI5csSLucAgaLpF65fL25zp)cmX825YtX5fmVFZZEEHNp153WH6s5ijolbMuudphANNHzEVlmmLJK4SeysVNZBW8SNx45tDEsaSz0hQlnSwofneWx(8mmZtcGnJ(qDPH1YP3Z5zyMNeaBg9H6sdRLtb68PNxO(nVb1KqUGwRjWanCzckHUvGkw36w3AsC3YMutsaMhwDRBTca]] )


end
