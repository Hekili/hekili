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


    spec:RegisterPack( "Retribution", 20210709, [[dS0RHbqiLGhHssDjLivTjc5tekmkQIofvHvHs0RavzwOeULiLYUq6xkrnmQsDmcvlJQQEgHstdLuxduyBOKOVHscJJqrNtKIADIuW8afDpuQ9jsoOsKIfcQQhQejteLK4IOKKSrLiv(OifHtksrALuLmtrk0nvIuQDQeAOkrkzPIuINkIPks1wfPi6ROKKASIuQ2RK(ROgmWHfwmf9yIMmLUm0Mb5ZemAj60QA1kr8AqLztLBtHDt63snCL0XfPKwoINJQPRY1vQTtv57sy8uv58GsZhf7xXvXRPxtSXH1f93B)f3BwH3PzQ)ElwXHH41Kd2vSMSgs4cbSMOHbwtsl4rEZ99TwtwdyDDyRPxt49MiXAsnXC)UlnvRM1eBCyDr)92FX9Mv4DAM6V3IvCXfVMWxrzDrwH31KY3ArTAwtSixwtsl4rEZ99ToGLwHlSVoE512b7asZSya(7T)IpEnETuLHkG80W4vABaPXGFPnokB1oGnpeWb0qd4iVchE8Lxkwf(a0UyaqnzaMnNpaOxO84dOvhSdWtBRIXnGIGF4awkwf(aADahj4LEqhVsBdyPDahoGeKeRLVXaG2Q8(whqrjQdyP71WnG0ckHR1xfwMvLFOCFFRdib1dvjoGGGdO1bSuSkdaQjdigqr57Wb4j0MCLizae0f(H2b06ayfllMEqhVsBdyPXAhau4CPTRK0BHYbWQKSC6PjhqrjQdibjXA5BS8sxAzabbhGf5WQYs0sRjRKg6DynHvZQhqAbpYBUVV1bS0kCH91XlwnREaETDWoG0mlgG)E7V4JxJxSAw9awQYqfqEAy8IvZQhqABaPXGFPnokB1oGnpeWb0qd4iVchE8Lxkwf(a0UyaqnzaMnNpaOxO84dOvhSdWtBRIXnGIGF4awkwf(aADahj4LEqhVy1S6bK2gWs7aoCajijwlFJbaTv59ToGIsuhWs3RHBaPfucxRVkSmRk)q5((whqcQhQsCabbhqRdyPyvgautgqmGIY3HdWtOn5krYaiOl8dTdO1bWkwwm9GoEXQz1diTnGLgRDaqHZL2UssVfkhaRsYYPNMCafLOoGeKeRLVXYlDPLbeeCawKdRklrlD8A8kK33kNUsqzBygh71((whVc59TYPReu2gMXbp2lB6qo)vHCdL5BddKmEfY7BLtxjOSnmJdESx20HC(Rc5gkh7BBOJxH8(w50vckBdZ4Gh7LnDiN)QqUHYfVEiz8kK33kNUsqzBygh8yVSPd58xfYnuMVsEvy8kK33kNUsqzBygh8yVCqKHI5Rjeupw8qSVWH6rHEnCzckHR1xfOOgMo0k6chQhLJKyT8nOOgMo0oEnEnGXlwnREaSQ8dL7dTda9HeyhW9g4aUsCaH8AYaE(acFX7cthshVc59TYztqZnC44viVVvo8yVSmCUCiVV1S75hl0Wazl72z7cLpEfY7BLdp2lldNlhY7Bn7E(Xcnmq2cOIK4AcF8AaJxH8(w5uz3oBxOC2R99TYIhIT5gcIg(qv4vHCbjUs6ELHXCdbrLKnpSiDVkYCdbrLKnpSiLFHeo2I7ndJzZ5IGEHYltqJ4vom9hgJxH8(w5uz3oBxOC4XEz3luE88s2wbdupw8qS5ROZLVGiGhN6EHYJNxY2kyG6LIT)mmlqI3MrFOE0WA5u0VNFCggs82m6d1JgwlN(AkwbmyyiXBZOpupAyTC6ED8kK33kNk72z7cLdp2ld9e001TLfpeBZneen8HQWRc5csCL09kdJ5gcIkjBEyr6EvK5gcIkjBEyrk)cjCSf37XRqEFRCQSBNTluo8yVmV8rNn3qzFOkGHkrw8qS9CHlCOEu0puUVV1mh1dvjsrnmDOLHr2TZ2fkf9dL77BnZr9qvIucAeVYHjm83drqVq5LjOr8kpL4Wy8kK33kNk72z7cLdp2lB6qo)vHCdL5BddKmEfY7BLtLD7SDHYHh7LnDiN)QqUHYX(2g64viVVvov2TZ2fkhESx20HC(Rc5gkx86HKXRqEFRCQSBNTluo8yVSPd58xfYnuMVsEvy8kK33kNk72z7cLdp2lV5y(p0GfAyGSFLlj7lmDyoTUd92gzl67LilEi2MBiiA4dvHxfYfK4kP7vggZneevs28WI09QiZneevs28WIu(fs4ylU3mmMnNlc6fkVmbnIx5WuSEpEfY7BLtLD7SDHYHh7L3Cm)hAWcnmq2TpKuuIoJxfYRDbsYscS8lCS4HyBUHGOHpufEvixqIRKUxzym3qqujzZdls3RIm3qqujzZdls5xiHJT4EZWy2CUiOxO8Ye0iELdtXHX4viVVvov2TZ2fkhESxEZX8FObl0WazBdcCgDRzlkHl7RjH8pyzXdX2CdbrdFOk8QqUGexjDVYWyUHGOsYMhwKUxfzUHGOsYMhwKYVqchBX9MHXS5CrqVq5LjOr8khM(794viVVvov2TZ2fkhESxEZX8FObl0WazBeYWKGzEjIx2yZFjlEi2MBiiA4dvHxfYfK4kP7vggZneevs28WI09QiZneevs28WIu(fs4ylU3mmMnNlc6fkVmbnIx5W0FVhVc59TYPYUD2Uq5WJ9YBoM)dnyHggiBlbdl0tWSpKZr34viVVvov2TZ2fkhESxEZX8FObl0WazZHB7Gdj8CXRcJxH8(w5uz3oBxOC4XE5nhZ)HgSqddKTa5nYY2I(nEfY7BLtLD7SDHYHh7L3Cm)hAWcnmq2gOrtGn3q51GFz(R8XRqEFRCQSBNTluo8yV8MJ5)qdwOHbYMVgemBGXLl7gUXRqEFRCQSBNTluo8yV8MJ5)qdwOHbYMhoFHaAZqB(3AomwDp0JKXRqEFRCQSBNTluo8yV8MJ5)qdwOHbYERYY4v0MfCH9JRj8SzyfWCdLHqsl)dww8qSn3qq0WhQcVkKliXvs3RmmMBiiQKS5HfP7vrMBiiQKS5HfP8lKWLIT4EZWi72z7cLg(qv4vHCbjUskbnIx5PynmyyKD7SDHsLKnpSiLGgXR8uSggJxH8(w5uz3oBxOC4XE5nhZ)HgSqddK9wLLXROnh81Ne6XZMHvaZnugcjT8pyzXdX2CdbrdFOk8QqUGexjDVYWyUHGOsYMhwKUxfzUHGOsYMhwKYVqcxk2I7ndJSBNTluA4dvHxfYfK4kPe0iELNI1WGHr2TZ2fkvs28WIucAeVYtXAymEfY7BLtLD7SDHYHh7L3Cm)hAWcnmq28xH2USGlSFCnHNndRaMBOmesA5FWYIhIT5gcIg(qv4vHCbjUs6ELHXCdbrLKnpSiDVkYCdbrLKnpSiLFHeUuSf3Bggz3oBxO0WhQcVkKliXvsjOr8kpfRHbdJSBNTluQKS5HfPe0iELNI1Wy8kK33kNk72z7cLdp2lV5y(p0GfAyGS5VcTD5GV(KqpE2mScyUHYqiPL)bllEi2MBiiA4dvHxfYfK4kP7vggZneevs28WI09QiZneevs28WIu(fs4sXwCVzyKD7SDHsdFOk8QqUGexjLGgXR8uSggmmYUD2UqPsYMhwKsqJ4vEkwdJXRqEFRCQSBNTluo8yV8MJ5)qdolEi2MBiiA4dvHxfYfK4kP7vggZneevs28WI09QiZneevs28WIu(fs4sXwCVhVc59TYPYUD2Uq5WJ9YHpufEvixqIRKfpeBplBhS51UajPyZAr3BGWegmmLTd28AxGKuSfRipV3atbdggYwrOMiG0ReZgHWZpsCipVKTvWa1ZdgMlCOE0Y2bBo8HQasOOgMo0ks2TZ2fkTSDWMdFOkGekbnIx5S92drEUWfoupkhjXA5BqrnmDOLHr2TZ2fkLJKyT8nOe0iELNYBgMlCOEuEOY7HE0MliXvsrnmDO1JXRqEFRCQSBNTluo8yVSKS5HfzXdXUSDWMx7cKKInRfDVbctyWWu2oyZRDbssXwSIU3atbdgMlCOE0Y2bBo8HQasOOgMo0ks2TZ2fkTSDWMdFOkGekbnIx5S9E8kK33kNk72z7cLdp2lh8suZLHZ1fJxH8(w5uz3oBxOC4XE5Y2bBo8HQasyXdX(EdmFDUCvGT3I80CdbrdFOk8QqUGexjDVYWyUHGOsYMhwKUxzym3qq0WhQcVkKliXvsTDHks2TZ2fkn8HQWRc5csCLucAeVYtXAVzym3qqujzZdlsTDHks2TZ2fkvs28WIucAeVYtXAV9y8kK33kNk72z7cLdp2ld9A4YeucxRVkWIhITNLTd28AxGKuSzTO7nqykMmmLTd28AxGKuSfRO7nWuSftpej72z7cLg(qv4vHCbjUskbnIx5PeKwr3BG5RZLRcS9wKNlCHd1JYrsSw(guudthAzym3qquosI1Y3GUx9qKNlqI3MrFOE0WA5u0VNFCggs82m6d1JgwlNUxzyiXBZOpupAyTC6RPyT3EmEnGXRqEFRCk0RpVejC2(cYhMoKfAyGST8Sm4xy6qw4lCBKnFfDU8feb84u777vmZVMyW2Frl4jzRiuteqk0RHl7dj2xEIUWH6rjVq5H9MN9He7lpkQHPdTIKTA3)rp0y1feE23R2xg33kf1W0Hwpyy4ROZLVGiGhNAFFVIz(1eJu(ZWyUHGOOXkSem08AxGe6EvKfn3qq0LSTcgOEuBxOIm3qqu777vmVUjRnhP2UqhVc59TYPqV(8sKWHh7L5ijwlFdw8qS9u2TZ2fkn8HQWRc5csCLucAeVYtjomyyKD7SDHsLKnpSiLGgXR8uIddgMlCOEuOxdxMGs4A9vbkQHPdTEiYZfUWH6rHEnCzckHR1xfOOgMo0YWi72z7cLc9A4YeucxRVkqjOr8kpL)EdpbPLLILHr2TZ2fkf61WLjOeUwFvGsqJ4vomzliTSuSI8Cbs82m6d1JgwlNI(98JZWqI3MrFOE0WA50xtXAVzyiXBZOpupAyTC6RWuqAzyiXBZOpupAyTC6E1dpe55cx4q9OOFOCFFRzoQhQsKIAy6qldJSBNTluk6hk333AMJ6HQePe0iELNsSWGHr2TZ2fkf9dL77BnZr9qvIucAeVYHjBbPLLILH5chQhf61WLjOeUwFvGIAy6qRhI8Cbz7d1qpkCWs(qzyKD7SDHsTVVxX81ohLGgXR8uSggmmYUD2UqP233Ry(ANJsqJ4vomtZEWWy2CUiOxO8Ye0iELdtXHHiOxO8Ye0iELNcgJxH8(w5uOxFEjs4WJ9YOFOCFFRzoQhQsKfpeBpn3qqujzZdlsTDHks2TZ2fkvs28WIucAeVYtjU3mmMBiiQKS5HfP8lKWLITyzyKD7SDHsdFOk8QqUGexjLGgXR8uI7ThI8CHlCOEuOxdxMGs4A9vbkQHPdTmmYUD2UqPqVgUmbLW16RcucAeVYtjU3Ei6cIaE07nW81z7JPeZXRqEFRCk0RpVejC4XEz777vmZVMyWIhITVG8HPdPwEwg8lmDOOfm3qquFHMw3pVej8CzyyGe6EvKNEUWfoupQKS5HfPOgMo0YWi72z7cLkjBEyrkbnIx5PeKwwkwpe55cx4q9OOFOCFFRzoQhQsKIAy6qldJSBNTluk6hk333AMJ6HQePe0iELNsqAzjRKHr2TZ2fkf9dL77BnZr9qvIucAeVYtjiTSegIkBhS51UajPyZAgMlic4rV3aZxNTpctXKHzHlCOEuosI1Y3GIAy6qRiz3oBxOu0puUVV1mh1dvjsjOr8kpLG0Ys)9qKNlCHd1Jc9A4YeucxRVkqrnmDOLHr2TZ2fkf61WLjOeUwFvGsqJ4vEkbPLLSsggz3oBxOuOxdxMGs4A9vbkbnIx5PeKwwcdrLTd28AxGKuSzndZcx4q9OCKeRLVbf1W0HwrYUD2UqPqVgUmbLW16RcucAeVYtjiTS0Fpe55cx4q9OCKeRLVbf1W0Hwggz3oBxOuosI1Y3GsqJ4v(sVG0cVY2bBETlqskXYWCHd1Jc9A4YeucxRVkqrnmDOLH5chQhf9dL77BnZr9qvIuudthAzyKTpud9OWbl5d1dggpVWH6rlBhS5WhQciHIAy6qRiz3oBxO0Y2bBo8HQasOe0iELdtbPLLILHXCdbrlBhS5WhQciHUxzym3qqujzZdls3RIm3qqujzZdls5xiHdMI7ThEmEfY7BLtHE95LiHdp2lFOXQli8SpKyF5XIhITNlCHd1JkjBEyrkQHPdTmmYUD2UqPsYMhwKsqJ4vEkbPLLI1drEUWfoupk6hk333AMJ6HQePOgMo0YWi72z7cLI(HY99TM5OEOkrkbnIx5PeKwwYkzyKD7SDHsr)q5((wZCupuLiLGgXR8ucsllHHOY2bBETlqsk2SMH5cIaE07nW81z7JWumzyw4chQhLJKyT8nOOgMo0ks2TZ2fkf9dL77BnZr9qvIucAeVYtjiTS0Fpe55cx4q9OqVgUmbLW16RcuudthAzyKD7SDHsHEnCzckHR1xfOe0iELNsqAzjRKHr2TZ2fkf61WLjOeUwFvGsqJ4vEkbPLLWquz7GnV2fijfBwZWSWfoupkhjXA5BqrnmDOvKSBNTluk0RHltqjCT(QaLGgXR8ucsll93drEUWfoupkhjXA5BqrnmDOLHr2TZ2fkLJKyT8nOe0iELV0liTWRSDWMx7cKKsSmmx4q9OqVgUmbLW16RcuudthAzyUWH6rr)q5((wZCupuLif1W0Hwggz7d1qpkCWs(q9GH5chQhTSDWMdFOkGekQHPdTIKD7SDHslBhS5WhQciHsqJ4vomfKwwkwggZneeTSDWMdFOkGe6ELHXCdbrLKnpSiDVkYCdbrLKnpSiLFHeoykU3JxH8(w5uOxFEjs4WJ9Y233RyMFnXGfpeBFb5dthsT8Sm4xy6qrx4q9OCKeRLVbf1W0HwrYUD2UqPCKeRLVbLGHfwrLTd28AxGe2LTd28AxGeQr4NOlCOEuOxdxMGs4A9vbkQHPdTIKD7SDHsHEnCzckHR1xfOe0iELNI1SuqAhVc59TYPqV(8sKWHh7Lp0y1feE2hsSV8yXdX(chQhLJKyT8nOOgMo0ks2TZ2fkLJKyT8nOemSWkQSDWMx7cKWUSDWMx7cKqnc)eDHd1Jc9A4YeucxRVkqrnmDOvKSBNTluk0RHltqjCT(QaLGgXR8uSMLcs741agVc59TYPcOIK4AcNTmCUCiVV1S75hl0Wazd96ZlrcNfpe7Y2bBETlqcByWWyUHGOLTd2C4dvbKq3Rmmw0CdbrHEnCzckHR1xfO7vgglAUHGOOFOCFFRzoQhQsKUxhVc59TYPcOIK4AchESx2xOP19Zlrcpxgggiz8kK33kNkGksIRjC4XEz777vmFTZXIhI9cw0CdbrxY2kyG6r3RI8CHlCOEuosI1Y3GIAy6qldJ5gcIYrsSw(g09QhI8Cbs82m6d1JgwlNI(98JZWqI3MrFOE0WA50xtjwVzyiXBZOpupAyTC6E1drEw2oyZRDbsGjB)zykBhS51UajWKnRf5PSBNTluQPlSyUHYlzZVxIucAeVYtjiTS0FgglAUHGOOFOCFFRzoQhQsKUxzySO5gcIc9A4YeucxRVkq3RE4Hipx4chQhf61WLjOeUwFvGIAy6qldJSBNTluk0RHltqjCT(QaLGgXR8ucsllf3Bpe55cx4q9OOFOCFFRzoQhQsKIAy6qldJSBNTluk6hk333AMJ6HQePe0iELNsqAzP4EZWCbrap69gy(6S9rykMEiYtz3oBxO0WhQcVkKliXvsjOr8kNHr2TZ2fkvs28WIucAeVY9y8kK33kNkGksIRjC4XE5YWWaj5gkxqIRKfpeBYwrOMiG0ReZgHnVgKqOvggYwrOMiGuFHkSdILNnAduVTHOlCOEu0puUVV1mh1dvjsrnmDOLHr2(qn0J6d1RewIiz3oBxO0GxIAUmCUUGsqJ4vEk)f37XRqEFRCQaQijUMWHh7LxY2kyG6XIhI9cw0CdbrxY2kyG6r3RIm3qq0Y2bBo8HQasO71XRqEFRCQaQijUMWHh7Llc4WCdLdEjYzXdX2ZY2bBETlqcmz7VOlCOEu0puUVV1mh1dvjsrnmDOvKfn3qqu0puUVV1mh1dvjsjOr8kpL3ISO5gcII(HY99TM5OEOkrkbnIx5WuqAzP)EmEfY7BLtfqfjX1eo8yVSPlSyUHYlzZVxIS4Hyx2oyZRDbsGjBXk6chQh10fwm3q5csCLuudthAf55foupk0RHltqjCT(Qaf1W0Hwrw0CdbrHEnCzckHR1xfOe0iELNsqAzP)mmx4q9OOFOCFFRzoQhQsKIAy6qROfUWH6rHEnCzckHR1xfOOgMo0kYtlAUHGOOFOCFFRzoQhQsKUxzyKD7SDHsr)q5((wZCupuLiLGgXRC2E7HhJxH8(w5ubursCnHdp2lVKTvWa1Jfpe7fSO5gcIUKTvWa1JUxfDHd1JYrsSw(guudthAf5zz7GnV2fijfBXfr2kc1ebKELy2ieE(rId55LSTcgOEmmLTd28AxGKuS93JXRqEFRCQaQijUMWHh7Llc4WCdLdEjYzXdX2ZY2bBETlqcBVzykBhS51UajWKT)I8u2TZ2fk10fwm3q5LS53lrkbnIx5PeKww6pdJfn3qqu0puUVV1mh1dvjs3RmmxqeWJEVbMVoBFeMIjdJfn3qquOxdxMGs4A9vb6E1dpe55cK4Tz0hQhnSwof975hNHHeVnJ(q9OH1YPVMYFVzyiXBZOpupAyTC6E1drEUWfoupk6hk333AMJ6HQePOgMo0YWi72z7cLI(HY99TM5OEOkrkbnIx5PehgmmxqeWJEVbMVoBFeMIPhI8CHlCOEuOxdxMGs4A9vbkQHPdTmmYUD2UqPqVgUmbLW16RcucAeVYtjomyyUGiGh9EdmFD2(imftpe5PSBNTluA4dvHxfYfK4kPe0iELZWi72z7cLkjBEyrkbnIx5EmEfY7BLtfqfjX1eo8yVSmCUCiVV1S75hl0Wazd96ZlrcNfpe7Y2bBETlqsk2IvK5gcIkjBEyr6EvK5gcIkjBEyrk)cjCWuCVhVc59TYPcOIK4AchESx20fwm3q5LS53lrw8qSlBhS51UajWKTyfjB1U)JI(TUjcX9TsrnmDOv0cY2hQHEuFOELWsgVc59TYPcOIK4AchESxEjBRGbQhlEi2lyrZneeDjBRGbQhDVoEfY7BLtfqfjX1eo8yVCzyyGKCdLliXvoEfY7BLtfqfjX1eo8yVSPlSyUHYlzZVxIS4Hyx2oyZRDbsGjBXoEfY7BLtfqfjX1eo8yVSmCUCiVV1S75hl0Wazd96ZlrcNfpeBpVGiGhTed3vsxLhmz7V3mmMBiiA4dvHxfYfK4kP7vggZneevs28WI09kdJ5gcIIgRWsWqZRDbsO7vpgVc59TYPcOIK4AchESxws28WIKm)ipCilEi2YUD2UqPsYMhwKK5h5HdPYYGiG8mejK33A4sXwCkRagI8SSDWMx7cKat2(ZWu2oyZRDbsGjBXks2TZ2fk10fwm3q5LS53lrkbnIx5PeKww6pdtz7GnV2fiHnRfj72z7cLA6clMBO8s287LiLGgXR8ucsll9xKSBNTlu6s2wbdupkbnIx5PeKww6VhJxH8(w5ubursCnHdp2llBLJssCFRS4HyVGSvokjX9Ts3RI4ROZLVGiGhNAFFVIz(1eJuS9F8kK33kNkGksIRjC4XEzz4C5qEFRz3ZpwOHbYg61NxIe(4viVVvovavKext4WJ9YYw5OKe33klEi2liBLJssCFR0964viVVvovavKext4WJ9YsYMhwKK5h5HdhVc59TYPcOIK4AchESxoiYqX81ecQ34viVVvovavKext4WJ9YYw5OKe33AnXhs4FR1f93B)f3BwH3IznPii6Rc8AcR6LM0YIPPlMMinmGbKEjoG3yTj3aGAYaedz3oBxOCXyaemTUFcAhaVnWbe7RnIdTdqwgQaYPJxPXxXb4pRtddyPA1hso0oaXGSveQjcinTlgd46bigKTIqnraPPDkQHPdTIXa8uC)8GoEnEXQEPjTSyA6IPjsddyaPxId4nwBYnaOMmaXa61NxIeUymacMw3pbTdG3g4aI91gXH2bildva50XR04R4aepnmGLQvFi5q7aedYwrOMiG00UymGRhGyq2kc1ebKM2POgMo0kgdWtX9Zd64vA8vCaSonmGLQvFi5q7asEJLAaCy1l8Bal9d46bKg3XaSVVN)ToGEfjX1Kb45YEmapf3ppOJxPXxXbaJ0WawQw9HKdTdi5nwQbWHvVWVbS0pGRhqAChdW((E(36a6vKextgGNl7Xa8uC)8GoEnEXQEPjTSyA6IPjsddyaPxId4nwBYnaOMmaXqavKext4IXaiyAD)e0oaEBGdi2xBehAhGSmubKthVsJVIdG1PHbSuT6djhAhGyq2kc1ebKM2fJbC9aedYwrOMiG00of1W0HwXyaEkUFEqhVsJVIdG1PHbSuT6djhAhGyq2kc1ebKM2fJbC9aedYwrOMiG00of1W0HwXyaEkUFEqhVsJVIdqmtddyPA1hso0oaXGSveQjcinTlgd46bigKTIqnraPPDkQHPdTIXa8uC)8GoEnELMAS2KdTdagdiK336aCp)40XRAI75hVMEnXIqX2D10RlkEn9AsiVV1Acbn3WH1eudthARWVE1f9VMEnb1W0H2k8RjH8(wRjYW5YH8(wZUNF1e3ZVSggynr2TZ2fkVE1ffBn9AcQHPdTv4xtc59TwtKHZLd59TMDp)QjUNFznmWAIaQijUMWRx9QjReu2gMXvtVUO410RjH8(wRjR99TwtqnmDOTc)6vx0)A61KqEFR1ethY5VkKBOmFByGKAcQHPdTv4xV6IITMEnjK33AnX0HC(Rc5gkh7BBO1eudthARWVE1fzDn9AsiVV1AIPd58xfYnuU41dj1eudthARWVE1fHrn9AsiVV1AIPd58xfYnuMVsEvOMGAy6qBf(1RUiRSMEnb1W0H2k8RjsYFi5JAYfoupk0RHltqjCT(Qaf1W0H2biAax4q9OCKeRLVbf1W0H2AsiVV1AsqKHI5RjeuV6vVAIaQijUMWRPxxu8A61eudthARWVMij)HKpQjLTd28AxGKbWEaWyammdWCdbrlBhS5WhQciHUxhadZaSO5gcIc9A4YeucxRVkq3RdGHzaw0Cdbrr)q5((wZCupuLiDVwtc59TwtKHZLd59TMDp)QjUNFznmWAc0RpVej86vx0)A61KqEFR1eFHMw3pVej8CzyyGKAcQHPdTv4xV6IITMEnb1W0H2k8RjsYFi5JAYcdWIMBii6s2wbdup6EDaIgGNdyHbCHd1JYrsSw(guudthAhadZam3qquosI1Y3GUxhGhdq0a8Calmas82m6d1JgwlNI(98JpagMbqI3MrFOE0WA50xhqQbiwVhadZaiXBZOpupAyTC6EDaEmardWZbu2oyZRDbsgamzpa)hadZakBhS51UajdaMShaRhGOb45aKD7SDHsnDHfZnuEjB(9sKsqJ4v(asnabPDaSCa(pagMbyrZneef9dL77BnZr9qvI096ayygGfn3qquOxdxMGs4A9vb6EDaEmapgGOb45awyax4q9OqVgUmbLW16RcuudthAhadZaKD7SDHsHEnCzckHR1xfOe0iELpGudqqAhalhG4EpapgGOb45awyax4q9OOFOCFFRzoQhQsKIAy6q7ayygGSBNTluk6hk333AMJ6HQePe0iELpGudqqAhalhG4EpagMbCbrap69gy(6S9XbaZbiMdWJbiAaEoaz3oBxO0WhQcVkKliXvsjOr8kFammdq2TZ2fkvs28WIucAeVYhGh1KqEFR1e777vmFTZvV6ISUMEnb1W0H2k8RjsYFi5JAczRiuteq6vIzJWMxdsi0kf1W0H2bWWmaYwrOMiGuFHkSdILNnAduVTbf1W0H2biAax4q9OOFOCFFRzoQhQsKIAy6q7ayygGS9HAOh1hQxjSKbiAaYUD2UqPbVe1Cz4CDbLGgXR8bKAa(lU31KqEFR1KYWWaj5gkxqIRSE1fHrn9AcQHPdTv4xtKK)qYh1KfgGfn3qq0LSTcgOE096aenaZneeTSDWMdFOkGe6ETMeY7BTMSKTvWa1RE1fzL10RjOgMo0wHFnrs(djFut8CaLTd28AxGKbat2dW)biAax4q9OOFOCFFRzoQhQsKIAy6q7aenalAUHGOOFOCFFRzoQhQsKsqJ4v(asnaVhGObyrZneef9dL77BnZr9qvIucAeVYhamhGG0oawoa)hGh1KqEFR1KIaom3q5GxI86vxKvutVMGAy6qBf(1ej5pK8rnPSDWMx7cKmayYEaIDaIgWfoupQPlSyUHYfK4kPOgMo0oardWZbCHd1Jc9A4YeucxRVkqrnmDODaIgGfn3qquOxdxMGs4A9vbkbnIx5di1aeK2bWYb4)ayygWfoupk6hk333AMJ6HQePOgMo0oardyHbCHd1Jc9A4YeucxRVkqrnmDODaIgGNdWIMBiik6hk333AMJ6HQeP71bWWmaz3oBxOu0puUVV1mh1dvjsjOr8kFaShG3dWJb4rnjK33AnX0fwm3q5LS53lX6vxumRPxtqnmDOTc)AIK8hs(OMSWaSO5gcIUKTvWa1JUxhGObCHd1JYrsSw(guudthAhGOb45akBhS51Uajdif7bi(aenaYwrOMiG0ReZgHWZpsCipVKTvWa1JIAy6q7ayygqz7GnV2fizaPypa)hGh1KqEFR1KLSTcgOE1RUyAUMEnb1W0H2k8RjsYFi5JAINdOSDWMx7cKma2dW7bWWmGY2bBETlqYaGj7b4)aenaphGSBNTluQPlSyUHYlzZVxIucAeVYhqQbiiTdGLdW)bWWmalAUHGOOFOCFFRzoQhQsKUxhadZaUGiGh9EdmFD2(4aG5aeZbWWmalAUHGOqVgUmbLW16Rc096a8yaEmardWZbSWaiXBZOpupAyTCk63Zp(ayygajEBg9H6rdRLtFDaPgG)EpagMbqI3MrFOE0WA5096a8yaIgGNdyHbCHd1JI(HY99TM5OEOkrkQHPdTdGHzaYUD2UqPOFOCFFRzoQhQsKsqJ4v(asnaXHXayygWfeb8O3BG5RZ2hhamhGyoapgGOb45awyax4q9OqVgUmbLW16RcuudthAhadZaKD7SDHsHEnCzckHR1xfOe0iELpGudqCymagMbCbrap69gy(6S9XbaZbiMdWJbiAaEoaz3oBxO0WhQcVkKliXvsjOr8kFammdq2TZ2fkvs28WIucAeVYhGh1KqEFR1KIaom3q5GxI86vxuCVRPxtqnmDOTc)AIK8hs(OMu2oyZRDbsgqk2dqSdq0am3qqujzZdls3Rdq0am3qqujzZdls5xiHBaWCaI7DnjK33AnrgoxoK33A298RM4E(L1WaRjqV(8sKWRxDrXfVMEnb1W0H2k8RjsYFi5JAsz7GnV2fizaWK9ae7aenazR29Fu0V1nriUVvkQHPdTdq0awyaY2hQHEuFOELWsQjH8(wRjMUWI5gkVKn)EjwV6II7Fn9AcQHPdTv4xtKK)qYh1KfgGfn3qq0LSTcgOE09AnjK33AnzjBRGbQx9QlkUyRPxtc59TwtkdddKKBOCbjUYAcQHPdTv4xV6IIZ6A61eudthARWVMij)HKpQjLTd28AxGKbat2dqS1KqEFR1etxyXCdLxYMFVeRxDrXHrn9AcQHPdTv4xtKK)qYh1ephWfeb8OLy4Us6Q8gamzpa)9EammdWCdbrdFOk8QqUGexjDVoagMbyUHGOsYMhwKUxhadZam3qqu0yfwcgAETlqcDVoapQjH8(wRjYW5YH8(wZUNF1e3ZVSggynb61NxIeE9QlkoRSMEnb1W0H2k8RjsYFi5JAISBNTluQKS5Hfjz(rE4qQSmicipdrc59TgUbKI9aeNYkGXaenaphqz7GnV2fizaWK9a8FammdOSDWMx7cKmayYEaIDaIgGSBNTluQPlSyUHYlzZVxIucAeVYhqQbiiTdGLdW)bWWmGY2bBETlqYaypawpardq2TZ2fk10fwm3q5LS53lrkbnIx5di1aeK2bWYb4)aenaz3oBxO0LSTcgOEucAeVYhqQbiiTdGLdW)b4rnjK33Anrs28WIKm)ipCy9QlkoROMEnb1W0H2k8RjsYFi5JAYcdq2khLK4(wP71biAa8v05YxqeWJtTVVxXm)AIXasXEa(xtc59TwtKTYrjjUV16vxuCXSMEnb1W0H2k8RjH8(wRjYW5YH8(wZUNF1e3ZVSggynb61NxIeE9QlkEAUMEnb1W0H2k8RjsYFi5JAYcdq2khLK4(wP71AsiVV1AISvokjX9TwV6I(7Dn9AsiVV1AIKS5Hfjz(rE4WAcQHPdTv4xV6I(lEn9AsiVV1AsqKHI5RjeuVAcQHPdTv4xV6I(7Fn9AsiVV1AISvokjX9TwtqnmDOTc)6vVAc0RpVej8A61ffVMEnb1W0H2k8Rj9AnHJxnjK33AnXxq(W0H1eFHBJ1e(k6C5lic4XP233RyMFnXyaShG)dq0awyaEoaYwrOMiGuOxdx2hsSV8OOgMo0oard4chQhL8cLh2BE2hsSV8OOgMo0oardq2QD)h9qJvxq4zFVAFzCFRuudthAhGhdGHza8v05YxqeWJtTVVxXm)AIXasna)hadZam3qqu0yfwcgAETlqcDVoardWIMBii6s2wbdupQTl0biAaMBiiQ999kMx3K1MJuBxO1eFbjRHbwtS8Sm4xy6W6vx0)A61eudthARWVMij)HKpQjEoaz3oBxO0WhQcVkKliXvsjOr8kFaPgG4Wyammdq2TZ2fkvs28WIucAeVYhqQbiomgadZaUWH6rHEnCzckHR1xfOOgMo0oapgGOb45awyax4q9OqVgUmbLW16RcuudthAhadZaKD7SDHsHEnCzckHR1xfOe0iELpGudWFVha8gGG0oawoaXoagMbi72z7cLc9A4YeucxRVkqjOr8kFaWK9aeK2bWYbi2biAaEoGfgajEBg9H6rdRLtr)E(XhadZaiXBZOpupAyTC6Rdi1ayT3dGHzaK4Tz0hQhnSwo91baZbiiTdGHzaK4Tz0hQhnSwoDVoapgGhdq0a8CalmGlCOEu0puUVV1mh1dvjsrnmDODammdq2TZ2fkf9dL77BnZr9qvIucAeVYhqQbiwymagMbi72z7cLI(HY99TM5OEOkrkbnIx5daMShGG0oawoaXoagMbCHd1Jc9A4YeucxRVkqrnmDODaEmardWZbSWaKTpud9OWbl5dDammdq2TZ2fk1((EfZx7CucAeVYhqQbWAymagMbi72z7cLAFFVI5RDokbnIx5daMdinpapgadZamBoFaIga0luEzcAeVYhamhG4WyaIga0luEzcAeVYhqQbaJAsiVV1AchjXA5BuV6IITMEnb1W0H2k8RjsYFi5JAINdWCdbrLKnpSi12f6aenaz3oBxOujzZdlsjOr8kFaPgG4EpagMbyUHGOsYMhwKYVqc3asXEaIDammdq2TZ2fkn8HQWRc5csCLucAeVYhqQbiU3dWJbiAaEoGfgWfoupk0RHltqjCT(Qaf1W0H2bWWmaz3oBxOuOxdxMGs4A9vbkbnIx5di1ae37b4XaenGlic4rV3aZxNTpoGudqmRjH8(wRjOFOCFFRzoQhQsSE1fzDn9AcQHPdTv4xtKK)qYh1eFb5dthsT8Sm4xy6WbiAalmaZnee1xOP19ZlrcpxgggiHUxhGOb45a8CalmGlCOEujzZdlsrnmDODammdq2TZ2fkvs28WIucAeVYhqQbiiTdGLdqSdWJbiAaEoGfgWfoupk6hk333AMJ6HQePOgMo0oagMbi72z7cLI(HY99TM5OEOkrkbnIx5di1aeK2bWYbWkhadZaKD7SDHsr)q5((wZCupuLiLGgXR8bKAacs7ay5aGXaenGY2bBETlqYasXEaSEammd4cIaE07nW81z7JdaMdqmhadZawyax4q9OCKeRLVbf1W0H2biAaYUD2UqPOFOCFFRzoQhQsKsqJ4v(asnabPDaSCa(papgGOb45awyax4q9OqVgUmbLW16RcuudthAhadZaKD7SDHsHEnCzckHR1xfOe0iELpGudqqAhalhaRCammdq2TZ2fkf61WLjOeUwFvGsqJ4v(asnabPDaSCaWyaIgqz7GnV2fizaPypawpagMbSWaUWH6r5ijwlFdkQHPdTdq0aKD7SDHsHEnCzckHR1xfOe0iELpGudqqAhalhG)dWJbiAaEoGfgWfoupkhjXA5BqrnmDODammdq2TZ2fkLJKyT8nOe0iELpGLhGG0oa4nGY2bBETlqYasnaXoagMbCHd1Jc9A4YeucxRVkqrnmDODammd4chQhf9dL77BnZr9qvIuudthAhadZaKTpud9OWbl5dDaEmagMb45aUWH6rlBhS5WhQciHIAy6q7aenaz3oBxO0Y2bBo8HQasOe0iELpayoabPDaSCaIDammdWCdbrlBhS5WhQciHUxhadZam3qqujzZdls3Rdq0am3qqujzZdls5xiHBaWCaI79a8yaEutc59TwtSVVxXm)AIr9QlcJA61eudthARWVMij)HKpQjEoGfgWfoupQKS5HfPOgMo0oagMbi72z7cLkjBEyrkbnIx5di1aeK2bWYbi2b4XaenaphWcd4chQhf9dL77BnZr9qvIuudthAhadZaKD7SDHsr)q5((wZCupuLiLGgXR8bKAacs7ay5ayLdGHzaYUD2UqPOFOCFFRzoQhQsKsqJ4v(asnabPDaSCaWyaIgqz7GnV2fizaPypawpagMbCbrap69gy(6S9XbaZbiMdGHzalmGlCOEuosI1Y3GIAy6q7aenaz3oBxOu0puUVV1mh1dvjsjOr8kFaPgGG0oawoa)hGhdq0a8CalmGlCOEuOxdxMGs4A9vbkQHPdTdGHzaYUD2UqPqVgUmbLW16RcucAeVYhqQbiiTdGLdGvoagMbi72z7cLc9A4YeucxRVkqjOr8kFaPgGG0oawoaymardOSDWMx7cKmGuShaRhadZawyax4q9OCKeRLVbf1W0H2biAaYUD2UqPqVgUmbLW16RcucAeVYhqQbiiTdGLdW)b4XaenaphWcd4chQhLJKyT8nOOgMo0oagMbi72z7cLYrsSw(gucAeVYhWYdqqAha8gqz7GnV2fizaPgGyhadZaUWH6rHEnCzckHR1xfOOgMo0oagMbCHd1JI(HY99TM5OEOkrkQHPdTdGHzaY2hQHEu4GL8HoapgadZaUWH6rlBhS5WhQciHIAy6q7aenaz3oBxO0Y2bBo8HQasOe0iELpayoabPDaSCaIDammdWCdbrlBhS5WhQciHUxhadZam3qqujzZdls3Rdq0am3qqujzZdls5xiHBaWCaI7DnjK33An5qJvxq4zFiX(YRE1fzL10RjOgMo0wHFnrs(djFut8fKpmDi1YZYGFHPdhGObCHd1JYrsSw(guudthAhGObi72z7cLYrsSw(gucgwyhGObu2oyZRDbsga7bu2oyZRDbsOgHFdq0aUWH6rHEnCzckHR1xfOOgMo0oardq2TZ2fkf61WLjOeUwFvGsqJ4v(asnawpawoabPTMeY7BTMyFFVIz(1eJ6vxKvutVMGAy6qBf(1ej5pK8rn5chQhLJKyT8nOOgMo0oardq2TZ2fkLJKyT8nOemSWoardOSDWMx7cKma2dOSDWMx7cKqnc)gGObCHd1Jc9A4YeucxRVkqrnmDODaIgGSBNTluk0RHltqjCT(QaLGgXR8bKAaSEaSCacsBnjK33An5qJvxq4zFiX(YRE1RMi72z7cLxtVUO410RjOgMo0wHFnrs(djFutm3qq0WhQcVkKliXvs3RdGHzaMBiiQKS5HfP71biAaMBiiQKS5HfP8lKWna2dqCVhadZamBoFaIga0luEzcAeVYhamhG)WOMeY7BTMS233A9Ql6Fn9AcQHPdTv4xtKK)qYh1e(k6C5lic4XPUxO845LSTcgOEdif7b4)ayygWcdGeVnJ(q9OH1YPOFp)4dGHzaK4Tz0hQhnSwo91bKAaScymagMbqI3MrFOE0WA509AnjK33AnX9cLhpVKTvWa1RE1ffBn9AcQHPdTv4xtKK)qYh1eZneen8HQWRc5csCL096ayygG5gcIkjBEyr6EDaIgG5gcIkjBEyrk)cjCdG9ae37AsiVV1Ac0tqtx326vxK110RjOgMo0wHFnrs(djFut8CalmGlCOEu0puUVV1mh1dvjsrnmDODammdq2TZ2fkf9dL77BnZr9qvIucAeVYhamham8FaEmarda6fkVmbnIx5di1aehg1KqEFR1eE5JoBUHY(qvadvI1RUimQPxtc59TwtmDiN)QqUHY8THbsQjOgMo0wHF9QlYkRPxtc59TwtmDiN)QqUHYX(2gAnb1W0H2k8RxDrwrn9AsiVV1AIPd58xfYnuU41dj1eudthARWVE1ffZA61KqEFR1ethY5VkKBOmFL8Qqnb1W0H2k8RxDX0Cn9AcQHPdTv4xtc59TwtELlj7lmDyoTUd92gzl67Lynrs(djFutm3qq0WhQcVkKliXvs3RdGHzaMBiiQKS5HfP71biAaMBiiQKS5HfP8lKWna2dqCVhadZamBoFaIga0luEzcAeVYhamhGy9UMOHbwtELlj7lmDyoTUd92gzl67Ly9QlkU310RjOgMo0wHFnjK33AnP9HKIs0z8QqETlqswsGLFHRMij)HKpQjMBiiA4dvHxfYfK4kP71bWWmaZneevs28WI096aenaZneevs28WIu(fs4ga7biU3dGHzaMnNparda6fkVmbnIx5daMdqCyut0WaRjTpKuuIoJxfYRDbsYscS8lC1RUO4IxtVMGAy6qBf(1KqEFR1eBqGZOBnBrjCzFnjK)bBnrs(djFutm3qq0WhQcVkKliXvs3RdGHzaMBiiQKS5HfP71biAaMBiiQKS5HfP8lKWna2dqCVhadZamBoFaIga0luEzcAeVYhamhG)Ext0WaRj2GaNr3A2Is4Y(Asi)d26vxuC)RPxtqnmDOTc)AsiVV1AIridtcM5LiEzJn)L1ej5pK8rnXCdbrdFOk8QqUGexjDVoagMbyUHGOsYMhwKUxhGObyUHGOsYMhwKYVqc3aypaX9EammdWS58biAaqVq5LjOr8kFaWCa(7DnrddSMyeYWKGzEjIx2yZFz9QlkUyRPxtqnmDOTc)AIggynXsWWc9em7d5C0vtc59TwtSemSqpbZ(qohD1RUO4SUMEnb1W0H2k8RjAyG1eoCBhCiHNlEvOMeY7BTMWHB7Gdj8CXRc1RUO4WOMEnb1W0H2k8RjAyG1ebYBKLTf9RMeY7BTMiqEJSSTOF1RUO4SYA61eudthARWVMOHbwtmqJMaBUHYRb)Y8x51KqEFR1ed0OjWMBO8AWVm)vE9QlkoROMEnb1W0H2k8RjAyG1e(AqWSbgxUSB4QjH8(wRj81GGzdmUCz3WvV6IIlM10RjOgMo0wHFnrddSMWdNVqaTzOn)BnhgRUh6rsnjK33AnHhoFHaAZqB(3AomwDp0JK6vxu80Cn9AcQHPdTv4xtc59Twt2QSmEfTzbxy)4AcpBgwbm3qziK0Y)GTMij)HKpQjMBiiA4dvHxfYfK4kP71bWWmaZneevs28WI096aenaZneevs28WIu(fs4gqk2dqCVhadZaKD7SDHsdFOk8QqUGexjLGgXR8bKAaSggdGHzaYUD2UqPsYMhwKsqJ4v(asnawdJAIggynzRYY4v0MfCH9JRj8SzyfWCdLHqsl)d26vx0FVRPxtqnmDOTc)AsiVV1AYwLLXROnh81Ne6XZMHvaZnugcjT8pyRjsYFi5JAI5gcIg(qv4vHCbjUs6EDammdWCdbrLKnpSiDVoardWCdbrLKnpSiLFHeUbKI9ae37bWWmaz3oBxO0WhQcVkKliXvsjOr8kFaPgaRHXayygGSBNTluQKS5HfPe0iELpGudG1WOMOHbwt2QSmEfT5GV(KqpE2mScyUHYqiPL)bB9Ql6V410RjOgMo0wHFnjK33AnH)k02LfCH9JRj8SzyfWCdLHqsl)d2AIK8hs(OMyUHGOHpufEvixqIRKUxhadZam3qqujzZdls3Rdq0am3qqujzZdls5xiHBaPypaX9Eammdq2TZ2fkn8HQWRc5csCLucAeVYhqQbWAymagMbi72z7cLkjBEyrkbnIx5di1aynmQjAyG1e(RqBxwWf2pUMWZMHvaZnugcjT8pyRxDr)9VMEnb1W0H2k8RjH8(wRj8xH2UCWxFsOhpBgwbm3qziK0Y)GTMij)HKpQjMBiiA4dvHxfYfK4kP71bWWmaZneevs28WI096aenaZneevs28WIu(fs4gqk2dqCVhadZaKD7SDHsdFOk8QqUGexjLGgXR8bKAaSggdGHzaYUD2UqPsYMhwKsqJ4v(asnawdJAIggynH)k02Ld(6tc94zZWkG5gkdHKw(hS1RUO)ITMEnb1W0H2k8RjsYFi5JAI5gcIg(qv4vHCbjUs6EDammdWCdbrLKnpSiDVoardWCdbrLKnpSiLFHeUbKI9ae37AsiVV1AYMJ5)qdE9Ql6pRRPxtqnmDOTc)AIK8hs(OM45akBhS51Uajdif7bW6biAa3BGdaMdagdGHzaLTd28AxGKbKI9ae7aenaphW9g4asnaymagMbq2kc1ebKELy2ieE(rId55LSTcgOEuudthAhGhdGHzax4q9OLTd2C4dvbKqrnmDODaIgGSBNTluAz7Gnh(qvajucAeVYha7b49a8yaIgGNdyHbCHd1JYrsSw(guudthAhadZaKD7SDHs5ijwlFdkbnIx5di1a8Eammd4chQhLhQ8EOhT5csCLuudthAhGh1KqEFR1KWhQcVkKliXvwV6I(dJA61eudthARWVMij)HKpQjLTd28AxGKbKI9ay9aenG7nWbaZbaJbWWmGY2bBETlqYasXEaIDaIgW9g4asnaymagMbCHd1Jw2oyZHpufqcf1W0H2biAaYUD2UqPLTd2C4dvbKqjOr8kFaShG31KqEFR1ejzZdlwV6I(ZkRPxtc59TwtcEjQ5YW56IAcQHPdTv4xV6I(ZkQPxtqnmDOTc)AIK8hs(OMCVbMVoxUkma2dW7biAaEoaZneen8HQWRc5csCL096ayygG5gcIkjBEyr6EDammdWCdbrdFOk8QqUGexj12f6aenaz3oBxO0WhQcVkKliXvsjOr8kFaPgaR9EammdWCdbrLKnpSi12f6aenaz3oBxOujzZdlsjOr8kFaPgaR9EaEutc59TwtkBhS5WhQciPE1f9xmRPxtqnmDOTc)AIK8hs(OM45akBhS51Uajdif7bW6biAa3BGdaMdqmhadZakBhS51Uajdif7bi2biAa3BGdif7biMdWJbiAaYUD2UqPHpufEvixqIRKsqJ4v(asnabPDaIgW9gy(6C5QWaypaVhGOb45awyax4q9OCKeRLVbf1W0H2bWWmaZneeLJKyT8nO71b4XaenaphWcdGeVnJ(q9OH1YPOFp)4dGHzaK4Tz0hQhnSwoDVoagMbqI3MrFOE0WA50xhqQbWAVhGh1KqEFR1eOxdxMGs4A9vH6vV6vtI9v2KAsYBSu1RE1ka]] )


end
