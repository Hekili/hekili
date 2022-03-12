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


    spec:RegisterPack( "Retribution", 20220312, [[dK0HacqijHhjjj2ej1Nqknkc4uivTkjjELQunlvPClcuLDHQFPkPHPQIJrsSmsspdPOPjjLRHuyBssQVrGOXrGY5KKQwNQk18eq3dj2NQQoOKKKfQkXdvvjtKav1fLKk1hLKkCsceSsKKzsG0nLKkzNcu)usQidvsQOwkbc9uQ0uLe9vjjPgRayVc9xjgmWHfTyb9yIMmvDzOndQptfJwvCAvwTa0RrsnBsDBsSBk)wQHlPoobQSCephLPR46GSDc67QkJxGCEKkZNq7xPJQeRm66ZbJbR6pQQ6p0ufv5Qu1)unvfKr3HUAm6wNsQthm6APcgDfeXHCHqZ1w0ToPt3Ppwz0L1qejgDJUHqNEeeSyy01Ndgdw1Fuv1FOPkQYvPQ)PAQw1rxwnkJbli)j6(CEpAXWORhzYORGioKleAU2wq15uN(ZwQQUsI8zbQO6Blq1Fuv1LQLQF9KMdY(9sLG3ceeSbDi5GlWWVfutUMCdDlGvRVzbWKwzbUNYV4lvcElO6kPgxGlsY6NtzbFnH6feIZGKf8DZZc65bjl4xc(SfmTJJg9lOHH5lvcElqWVnANf8LSbxGc6piLx1jXbxWVe8zlOTf4P7mNfuNsQzlaY0iJTGBOLTGCbHnJTa4Z5z4lvcElO6Qj4csFaHyJcAdBbtVGVMq9c(U5zb)sWNTa2t)zlGH1jjhuthp6wtA4tJr3QsvzbcI4qUqO5ABbvNtD6pBPQQuvwq1vsKplqfvFBbQ(JQQUuTuvvQkl4xpP5GSFVuvvQklqWBbcc2GoKCWfy43cQjxtUHUfWQ13SaysRSa3t5x8LQQsvzbcElO6kPgxGlsY6NtzbFnH6feIZGKf8DZZc65bjl4xc(SfmTJJg9lOHH5lvvLQYce8wGGFB0ol4lzdUaf0FqkVQtIdUGFj4ZwqBlWt3zolOoLuZwaKPrgBb3qlBb5ccBgBbWNZZWxQQkvLfi4TGQRMGli9beInkOnSfm9c(Ac1l47MNf8lbF2cyp9NTagwNKCqnD8LQLQuoxBmEnbLTsyouQ75ABPkLZ1gJxtqzReMZ7uEnuJm2zoLgUWGuuqYsvkNRngVMGYwjmN3P8AOgzSZCknCjHgifBPkLZ1gJxtqzReMZ7uEnuJm2zoLgU8D2GKLQuoxBmEnbLTsyoVt51qnYyN5uA4cRMCMZsvkNRngVMGYwjmN3P8kSgzpsscpVDWuynKo8mpVgInqASGeO65AtuK1q6WZ8CHToNtJfwRfI2SuLY5AJXRjOSvcZ5DkVMezAyzAcbT5TdMYKA0go8zPUqqj1TDMdhTmuJE1tQrB4mKK1pNchTmuJ(LQuoxBmEnbLTsyoVt5v2ZHAFPHlcrZbttIlvlvvLQYcQUdcLqd6xakej0TG5uWfmp4cs50KfCSfKcZtNHAKVuLY5AJrHGHquJlvPCU2yVt5vzQ1LuoxBf9XM3SubPi7w77pJTuLY5AJ9oLxLPwxs5CTv0hBEZsfKcYkWKsD36ZCE7GPiqfK88fuiAdp9Eghd6ydtuKKNVGcrB4P3Z4q1IIK88fuiAdp9Eg)SaRErrsE(ckeTHNEpJF2FA(d9QfysnAdhdcLqZ1wHH2GMevl7w77pJJbHsO5ARWqBqtICcQKNXcS6vZQrTUmjXbhg3FcpdlSPjkbsdrXj1OnC4ZsDHGsQB7mh1YU1((Z4WNL6cbLu32zoCcQKNXcS6Pxn858mfcQKNX(lylvPCU2yVt5vzQ1LuoxBf9XM3SubPGScmPKY5eIVXgYjhkQ82btXJHqWWCmiucnxBfgAdAsKdvlk6Xqiyyo8zPUqqj1TDMdhQEPkLZ1g7DkVktTUKY5AROp28MLkifh0qsonHTuTuLY5AJXLDR99NXOu3Z12BhmLqiyyEkenNZCkFKCE4q1IIHqWWCjbILEKdvRoecgMljqS0JC2KsQPOYpIIHnJPg(CEMcbvYZybQknwQs5CTX4YU1((ZyVt5v958mSsaH8okOnVDWuy1OwxMK4GdJRpNNHvciK3rbT5pfvffRGKNVGcrB4P3Z4yqhByIIK88fuiAdp9Eg)S)csAiksYZxqHOn807zCO6LQuoxBmUSBTV)m27uEf(iyOUB)BhmfbcHGH5Pq0CoZP8rY5HdvlkgcbdZLeiw6rouT6qiyyUKaXspYztkPMIk)qV6kMuJ2WXGqj0CTvyOnOjXLQuoxBmUSBTV)m27uEfwJShjjHN3oykSgshEMNxdXginwqcu9CTjkYAiD4zEUWwNZPXcR1crBE7SbjeO6PCkkO)YbPOYBNniHavpfhDhMAkQ82zdsiq1t5GPWAiD4zEUWwNZPXcR1crBwQs5CTX4YU1((ZyVt5v2ZHAFPHlcrZbttIVDWueOIj1OnCmiucnxBfgAdAsuuu2T23FghdcLqZ1wHH2GMe5eujpJfinuLE1WNZZuiOsEg7Vk0yPkLZ1gJl7w77pJ9oLxd1iJDMtPHlmiffKSuLY5AJXLDR99NXENYRHAKXoZP0WLeAGuSLQuoxBmUSBTV)m27uEnuJm2zoLgU8D2GKLQuoxBmUSBTV)m27uEnuJm2zoLgUWQjN5SuLY5AJXLDR99NXENYRqmSCdQ8MLkiLZysc0KHASi4GsBGukEu4jX3oykHqWW8uiAoN5u(i58WHQffdHGH5scel9ihQwDiemmxsGyPh5SjLutrLFefdBgtn858mfcQKNXcKM)SuLY5AJXLDR99NXENYRqmSCdQ8MLkiLwis(EqTYzoL6(djfjHo2K63oykHqWW8uiAoN5u(i58WHQffdHGH5scel9ihQwDiemmxsGyPh5SjLutrLFefdBgtn858mfcQKNXcufASuLY5AJXLDR99NXENYRqmSCdQ8MLkifFsOwPBR4rj1fHnjL3q3BhmLqiyyEkenNZCkFKCE4q1IIHqWWCjbILEKdvRoecgMljqS0JC2KsQPOYpIIHnJPg(CEMcbvYZybQ6plvPCU2yCz3AF)zS3P8kedl3GkVzPcsrjLziblSheNIce7KVDWucHGH5Pq0CoZP8rY5HdvlkgcbdZLeiw6rouT6qiyyUKaXspYztkPMIk)ikg2mMA4Z5zkeujpJfOQ)SuLY5AJXLDR99NXENYRqmSCdQ8MLkif4esp0vKnKnirbtgebF7GPuXKA0gUKaXspkkgcbdZLeiw6rouTOyyZyQHpNNPqqL8mwG08NLQuoxBmUSBTV)m27uEfIHLBqL3SubP4jy6HpcweImgQxQs5CTX4YU1((ZyVt5vigwUbvEZsfKcJAin1iHv(oZzPkLZ1gJl7w77pJ9oLxHyy5gu5nlvqkoKtPiBpg0svkNRngx2T23Fg7DkVcXWYnOYBwQGuuqLMqxPHl1jBkSZylvPCU2yCz3AF)zS3P8kedl3GkVzPcsHvNeSOG5uE6M6LQuoxBmUSBTV)m27uEfIHLBqL3SubPWsTW0b9fyi21wjvQ1h8HKLQuoxBmUSBTV)m27uEfIHLBqL3SubP4CPnLMyPcAtQl1ys0lvPCU2yCz3AF)zS3P8kedl3GkVzPcs57mptMKY3doSPnCPkLZ1gJl7w77pJ9oLxHyy5gu5nlvqkmzsyLgUatYbjwQlSHCW4svkNRngx2T23Fg7DkVcXWYnOYBwQGuKp5zSsdx8TYz5CTTuLY5AJXLDR99NXENYRqmSCdQ8MLkifmjZtibtQrcRCk1PCwQs5CTX4YU1((ZyVt5vigwUbvEZsfKYdMKP0WL5blSVKO82btPIqiyyEkenNZCkFKCE4q1QdHGH5scel9ihQEPkLZ1gJl7w77pJ9oLxHyy5gu5nlvqko60F50ewjm9o4BhmLqiyyEkenNZCkFKCE4q1IIHqWWCjbILEKdvRoecgMljqS0JC2KsQ)trLFefLDR99NXtHO5CMt5JKZdNGk5zS)vJgIIYU1((Z4scel9iNGk5zS)vJglvPCU2yCz3AF)zS3P8kedl3GkS3oykHqWW8uiAoN5u(i58WHQffdHGH5scel9ihQwDiemmxsGyPh5SjLu)NIk)SuLY5AJXLDR99NXENYRPq0CoZP8rY55TdMIapTMUsD)HK)uQM65uWaPHO4tRPRu3Fi5pfAQwG5uW)0quKaziCtCq(8GfL05ydjhKvciK3rbTHErXNwtxPU)qYFkQQMaziCtCqUW0CGsINvuAf0gif1tQrB4WNL6cbLu32zoIItQrB4pTMUskenhKOw2T23Fg)P10vsHO5GeobvYZyu(HE1cuXKA0godjz9ZPikwXKA0go8zPUqqj1TDMJOOSBTV)modjz9ZPWjOsEg7)p0VuLY5AJXLDR99NXENYRscel94BhmLNwtxPU)qYFkvt9CkyG0qu8P10vQ7pK8NcnvpNc(NglvPCU2yCz3AF)zS3P8AYEqR8KAD)TuLY5AJXLDR99NXENYRpTMUskenhK82btzofSmD5P2HYpQFAnDL6(djbsrv1cecbdZtHO5CMt5JKZdhQwuCsnAdxsGyPhvlGSBTV)mUKaXspYjOsEgJYpIIHqWWCjbILEKdvtVOyyZyQHpNNPqqL8mwGQ(d9lvPCU2yCz3AF)zS3P8k8zPUqqj1TDMZBhmfbEAnDL6(dj)Pun1ZPGbkyIIpTMUsD)HK)uOPAbMtb)trWefz1OwxMK4GdJ7pHNHf20eL)uuvTSfIwAdNA6ixA0tVAz3AF)z8uiAoN5u(i58WjOsEg7VJ0REofSmD5P2HYpQfOIj1OnCgsY6NtrumecgMZqsw)CkCOA6vlqfK88fuiAdp9Eghd6ydtuKKNVGcrB4P3Z4q1IIK88fuiAdp9Eg)S)v7h6vlqfHqWW8uiAoN5u(i58WHQffFAnDL6(djuOHOOSBTV)m(tQOGKsdx(i58WjOsEgtuKvJADzsIdomU)eEgwyttu(trv1YwiAPnCQPJCPr)s1svkNRnghzfysjLZjePaFemu3TFPkLZ1gJJScmPKY5eIVt5vzQ1LuoxBf9XM3SubPaF2XEqc7TdMYtRPRu3FiHcnef9yiemmpGqEhf0gouTOOhdHGH5WNL6cbLu32zoCOA1c4Xqiyyo8zPUqqj1TDMdNGk5zSaDKEUsgKOiRg16YKehCyC)j8mSWMMO8NIQQRysnAdhdcLqZ1wHH2GMePxu0JHqWWCmiucnxBfgAdAsKdvR2JHqWWCmiucnxBfgAdAsKtqL8mwGospxjdAPkLZ1gJJScmPKY5eIVt5v)j8mSmTwVuLY5AJXrwbMus5CcX3P8QW0eCqh7bjSYtQOGKLQuoxBmoYkWKskNti(oLx)sQXsdxs2dYE7GP80A6k19hscKIQQfWJHqWWC4ZsDHGsQB7mhouTApgcbdZHpl1fckPUTZC4eujpJfOJ0xfvvxbbYq4M4GC)j8mSqqwBPjrrrpgcbdZXGqj0CTvyOnOjrouTApgcbdZXGqj0CTvyOnOjrobvYZyb6i9IISAuRltsCWHX9NWZWcBAIYFk0qnbYq4M4GC)j8mSqqwBPjr1tQrB4yqOeAU2km0g0Ki9lvPCU2yCKvGjLuoNq8DkVgQtpwA4saHyZjX3oykY28q3WXGQHio5CTPwGkiqgc3ehK7pHNHfcYAlnjQ(P10vQ7pKeifAkk(0A6k19hscKIQ0VuLY5AJXrwbMus5CcX3P8AaH8okOnVDWuQWJHqWW8ac5DuqB4q1Qf4P10vQ7pK8NIkQjqgc3ehKppyrjDo2qYbzLac5DuqBefFAnDL6(dj)POk9lvPCU2yCKvGjLuoNq8DkVktTUKY5AROp28MLkif4Zo2dsylvPCU2yCKvGjLuoNq8DkV(LuJLgUKShK92bt5P10vQ7pKeifvxQs5CTX4iRatkPCoH47uEnuNES0WLacXMtIVDWuEAnDL6(djbsHMlvPCU2yCKvGjLuoNq8DkVgqiVJcAZBhmLk8yiemmpGqEhf0gou9svkNRnghzfysjLZjeFNYRpPIcsknC5JKZZsvkNRnghzfysjLZjeFNYRscel9iPWgYrnUuLY5AJXrwbMus5CcX3P8AsKPHLPje0MLQuoxBmoYkWKskNti(oLxLTXqjjNRTLQLQuoxBmoYkWKsD36ZCOWqsw)CkVDWuEAnDL6(djuOHAbQysnAdh(SuxiOK62oZruu2T23Fgh(SuxiOK62oZHtqL8mwGuCK(Qqtrrz3AF)zC4ZsDHGsQB7mhobvYZy)LDR99NrVAbQysnAdhdcLqZ1wHH2GMeffLDR99NXXGqj0CTvyOnOjrobvYZybsXr6RcnffLDR99NXXGqj0CTvyOnOjrobvYZy)LDR99NjkoPgTHdFwQleusDBN5qVAbQq2crlTHtnDKlnrrz3AF)zC)j8mSmTwZjOsEglWQxuu2T23Fg3FcpdltR1CcQKNX(l7w77pJ(LQuoxBmoYkWKsD36ZCENYRYuRlPCU2k6JnVzPcsb(SJ9Ge2BhmLNwtxPU)qcfAik6Xqiyyo8zPUqqj1TDMdhQwumecgMljqS0JCOA1HqWWCjbILEKZMusDGQ8ZsvkNRnghzfysPUB9zoVt5vHPj4Go2dsyLNurbjVDWucHGH5mKK1pNchQEPkLZ1gJJScmPu3T(mN3P86tQOGKsdx(i5882btHaziCtCqUW0CGsINvuAf0giLLQuoxBmoYkWKsD36ZCENYRFj1yPHlj7bzVDWuEAnDL6(djbsrv1mCkHTbX4ZHevfSs1QLlvPCU2yCKvGjL6U1N58oLxd1PhlnCjGqS5K4BhmLNwtxPU)qsGuO5svkNRnghzfysPUB9zoVt51ac5DuqBE7GPuHhdHGH5beY7OG2WHQxQs5CTX4iRatk1DRpZ5DkV(KkkiP0WLpsoplvPCU2yCKvGjL6U1N58oLxLeiw6rsHnKJA8TdMISBTV)mUKaXspskSHCuJC5tsCqwbMKY5Al1)POcxqsd1c80A6k19hscKIQIIpTMUsD)HKaPqt1YU1((Z4H60JLgUeqi2CsKtqL8m2FhPVkQkk(0A6k19hsOun1YU1((Z4H60JLgUeqi2CsKtqL8m2FhPVkQQw2T23FgpGqEhf0gobvYZy)DK(QOk9lvPCU2yCKvGjL6U1N58oLxzijRFoL3oykvmPgTHdFwQleusDBN5Ow2T23FghdcLqZ1wHH2GMe5eujpJfifhPVk0uTaviBHOL2WPMoYLMOOSBTV)mU)eEgwMwR5eujpJfy1t)svkNRnghzfysPUB9zoVt5vzQ1LuoxBf9XM3SubPaF2XEqcBPkLZ1gJJScmPu3T(mN3P8QKaXspskSHCuJlvPCU2yCKvGjL6U1N58oLxtImnSmnHG282bt5P10vQ7pKeiLQTuLY5AJXrwbMuQ7wFMZ7uELHKS(5uE7GPiqftQrB4WNL6cbLu32zoIIYU1((Z4WNL6cbLu32zoCcQKNXcKIJ0xfAsVAbQysnAdhdcLqZ1wHH2GMeffLDR99NXXGqj0CTvyOnOjrobvYZybsXr6RcnffNuJ2WHpl1fckPUTZCOxTaviBHOL2WPMoYLMOOSBTV)mU)eEgwMwR5eujpJfy1t)svkNRnghzfysPUB9zoVt5vzBmusY5ABPAPkLZ1gJdF2XEqcJIWKCzOgFZsfKINvKjBYqn(MWudHuy1OwxMK4GdJ7pHNHf20efkQQUcbiqgc3ehKdFwQlcrI)KJO4KA0go5CEgSHyfHiXFYHErrwnQ1Ljjo4W4(t4zyHnnr5VQIIHqWWCuPMocMwPU)qchQwDfEmecgMhqiVJcAdhQwDfHqWWC)j8mSudrQBgYHQxQs5CTX4WNDShKWENYRmKK1pNYBhmfbKDR99NXtHO5CMt5JKZdNGk5zS)Qqdrrz3AF)zCjbILEKtqL8m2FvOb9QfOIj1OnC4ZsDHGsQB7mhrrz3AF)zC4ZsDHGsQB7mhobvYZy)LDR99NrVAbQysnAdhdcLqZ1wHH2GMeffLDR99NXXGqj0CTvyOnOjrobvYZy)LDR99NjkYQrTUmjXbhg3FcpdlSPjk)Pqd6vlqfK88fuiAdp9Eghd6ydtuKKNVGcrB4P3Z4N9VA)iksYZxqHOn807z8Zc0r6ffj55lOq0gE69moun9QfOczleT0go10rU0effq2T23Fg3FcpdltR1CcQKNXcS6ffLDR99NX9NWZWY0AnNGk5zS)YU1((ZONErr4Z5zkeujpJfOk0qn858mfcQKNX(tdrXqiyyUKaXspYHQvhcbdZLeiw6roBsj1bQYplvPCU2yC4Zo2dsyVt5vmiucnxBfgAdAs8TdMIaHqWWCjbILEK77ptTSBTV)mUKaXspYjOsEg7Vk)ikgcbdZLeiw6roBsj1)Pqtrrz3AF)z8uiAoN5u(i58WjOsEg7Vk)qVAbQysnAdh(SuxiOK62oZruu2T23Fgh(SuxiOK62oZHtqL8m2Fv(HE1WNZZuiOsEg7VGPMvJADzsIdomU)eEgwyttucKglvPCU2yC4Zo2dsyVt5v)j8mSWMMO82btrysUmuJCpRit2KHAuDfHqWWCHPj4Go2dsyLNurbjCOA1ciqftQrB4scel9OOOSBTV)mUKaXspYjOsEg7VJ0xfAsVAbQysnAdhdcLqZ1wHH2GMeffLDR99NXXGqj0CTvyOnOjrobvYZy)DK(Qu1IIYU1((Z4yqOeAU2km0g0KiNGk5zS)osFvQM6NwtxPU)qYFk0quKvJADzsIdomU)eEgwyttu(tHgIIvmPgTHZqsw)CkQLDR99NXXGqj0CTvyOnOjrobvYZy)DK(QOk9QfOIj1OnC4ZsDHGsQB7mhrrz3AF)zC4ZsDHGsQB7mhobvYZy)DK(Qu1IIYU1((Z4WNL6cbLu32zoCcQKNX(7i9vPAQFAnDL6(dj)PqdrXkMuJ2WzijRFof1YU1((Z4WNL6cbLu32zoCcQKNX(7i9vrv6ffNuJ2WFAnDLuiAoirTSBTV)m(tRPRKcrZbjCcQKNXc0r6RcnffdHGH5pTMUskenhKWHQffdHGH5scel9ihQwDiemmxsGyPh5SjLuhOk)ikcFoptHGk5zSafm6xQs5CTX4WNDShKWENYRdQuRtcRiej(toVDWueOIj1OnCjbILEuuu2T23FgxsGyPh5eujpJ93r6RcnPxTavmPgTHJbHsO5ARWqBqtIIIYU1((Z4yqOeAU2km0g0KiNGk5zS)osFvemrrz3AF)zCmiucnxBfgAdAsKtqL8m2FhPVkvT6NwtxPU)qYFkvtuSIj1OnCgsY6NtrTSBTV)mogekHMRTcdTbnjYjOsEg7VJ0xfvPxTavmPgTHdFwQleusDBN5ikk7w77pJdFwQleusDBN5WjOsEg7VJ0xfbtuu2T23Fgh(SuxiOK62oZHtqL8m2FhPVkvT6NwtxPU)qYFkvtuSIj1OnCgsY6NtrTSBTV)mo8zPUqqj1TDMdNGk5zS)osFvuLErXj1On8NwtxjfIMdsul7w77pJ)0A6kPq0CqcNGk5zSaDK(QqtrXqiyy(tRPRKcrZbjCOArXqiyyUKaXspYHQvhcbdZLeiw6roBsj1bQYpIIWNZZuiOsEglqbBPAblvPCU2yCh0qsonHrrMADjLZ1wrFS5nlvqkWNDShKWE7GP80A6k19hsOqdrrb8yiemmpGqEhf0gouTO4tRPRu3FiHs1OxDiemm3FcpdleK1wAsKdvlkgcbdZFAnDLuiAoiHdvVuLY5AJXDqdj50e27uEvyAcoOJ9Gew5jvuqYBhmLkiqgc3ehK7Hg6cBiZxCsHOwuSIj1OnC4ZsDHGsQB7mh1vmPgTHJbHsO5ARWqBqtIIIHnJPg(CEMcbvYZybkylvPCU2yCh0qsonH9oLxFsffKuA4YhjNN3oykeidHBIdYNhSOK(sDssN2efLTq0sB4crBEOJOw2T23FgpzpOvEsTU)4eujpJ9xvv(zPkLZ1gJ7GgsYPjS3P86xsnwA4sYEq2BhmLNwtxPU)qsGuuvndNsyBqm(CirvbRuTAPAbKDR99NXtHO5CMt5JKZdNGk5zmrrz3AF)zCjbILEKtqL8mg9lvPCU2yCh0qsonH9oLx9NWZWY0A9BhmLNwtxPU)qsGuurDfEmecgMhqiVJcAdhQwTavmPgTHZqsw)CkIIHqWWCgsY6NtHdvtVAbQGKNVGcrB4P3Z4yqhByIIK88fuiAdp9Eg)S)08hrrsE(ckeTHNEpJdvtVAbQysnAdh(SuxiOK62oZru0JHqWWC4ZsDHGsQB7mhouTOOSBTV)mo8zPUqqj1TDMdNGk5zS)Q(d9QfOIj1OnCmiucnxBfgAdAsuue(CEMcbvYZybkyIISAuRltsCWHX9NWZWcBAIYFk0GE1ci7w77pJNcrZ5mNYhjNhobvYZyIIYU1((Z4scel9iNGk5zm6xQs5CTX4oOHKCAc7DkVgqiVJcAZBhmLk8yiemmpGqEhf0gouTAbEAnDL6(dj)POIAcKHWnXb5ZdwusNJnKCqwjGqEhf0grXNwtxPU)qYFkQs)svkNRng3bnKKttyVt51VKAS0WLK9GS3oykc80A6k19hsO8JO4tRPRu3FijqkQQw2T23FgpuNES0WLacXMtICcQKNX(7i9vrv6vlqfK88fuiAdp9Eghd6ydtuKKNVGcrB4P3Z4N9x1Fefj55lOq0gE69moun9QfOIj1OnCgsY6Ntruu2T23FgNHKS(5u4eujpJ9NgIIYwiAPnCQPJCPrVAbQysnAdhdcLqZ1wHH2GMeffLDR99NXXGqj0CTvyOnOjrobvYZy)vHgIIWNZZuiOsEglqbtuKvJADzsIdomU)eEgwyttu(tHg0RwGkMuJ2WHpl1fckPUTZCefLDR99NXHpl1fckPUTZC4eujpJ9xfAikcFoptHGk5zSafm6vlGSBTV)mEkenNZCkFKCE4eujpJjkk7w77pJljqS0JCcQKNXOFPkLZ1gJ7GgsYPjS3P8Qm16skNRTI(yZBwQGuGp7ypiH92bt5P10vQ7pK8NcnvhcbdZLeiw6rouT6qiyyUKaXspYztkPoqv(zPkLZ1gJ7GgsYPjS3P8AOo9yPHlbeInNeF7GPiBZdDdhdQgI4KZ1M6NwtxPU)qsGuO5svkNRng3bnKKttyVt51ac5DuqBE7GPuHhdHGH5beY7OG2WHQxQs5CTX4oOHKCAc7DkV(KkkiP0WLpsoplvPCU2yCh0qsonH9oLxd1PhlnCjGqS5K4BhmLNwtxPU)qsGuO5svkNRng3bnKKttyVt5vzQ1LuoxBf9XM3SubPaF2XEqc7TdMIatsCWH)GPEE41YjqkQ(JOyiemmpfIMZzoLpsopCOArXqiyyUKaXspYHQffdHGH5OsnDemTsD)Heoun9lvPCU2yCh0qsonH9oLxLTXqjjNRT3oykviBJHssoxBCOA1SAuRltsCWHX9NWZWcBAIYFkQUuLY5AJXDqdj50e27uEvsGyPhjf2qoQX3oykYU1((Z4scel9iPWgYrnYLpjXbzfyskNRTu)NIkCbjnulWtRPRu3FijqkQkk(0A6k19hscKcnvl7w77pJhQtpwA4saHyZjrobvYZy)DK(QOQO4tRPRu3FiHs1ul7w77pJhQtpwA4saHyZjrobvYZy)DK(QOQAz3AF)z8ac5DuqB4eujpJ93r6RIQ0VuLY5AJXDqdj50e27uEvMADjLZ1wrFS5nlvqkWNDShKWwQs5CTX4oOHKCAc7DkVkBJHssoxBVDWuQq2gdLKCU24q1lvPCU2yCh0qsonH9oLxLeiw6rsHnKJACPkLZ1gJ7GgsYPjS3P8AsKPHLPje0MLQuoxBmUdAijNMWENYRY2yOKKZ1w0visyxBXGv9hvv9hA(dnIUFjXoZHfDRQRQeedwqi4QJFVGfu5dUGtPUjZcGBYcO1bnKKtty0Uack4Goc6xaRvWfKqtRKd6xG8jnhKXxQe0ZWfO6VxWVAtisg0VaANuJ2WdaTly6fq7KA0gEa4OLHA0t7ceq1GONVujONHlq1FVGF1MqKmOFb0sGmeUjoipa0UGPxaTeidHBIdYdahTmuJEAxGaQee98Lkb9mCb083l4xTjejd6xaTeidHBIdYdaTly6fqlbYq4M4G8aWrld1ON2fiGkbrpFPsqpdxan(9c(vBcrYG(fq7KA0gEaODbtVaANuJ2WdahTmuJEAxGa0mi65lvc6z4cQ6FVGF1MqKmOFb0sGmeUjoipa0UGPxaTeidHBIdYdahTmuJEAxGaQee98Lkb9mCbcYFVGF1MqKmOFb0oPgTHhaAxW0lG2j1On8aWrld1ON2fiandIE(s1svvDvLGyWccbxD87fSGkFWfCk1nzwaCtwaTEeoH0dTlGGcoOJG(fWAfCbj00k5G(fiFsZbz8Lkb9mCb083l4xTjejd6xaTtQrB4bG2fm9cODsnAdpaC0Yqn6PDbcOAq0ZxQwQQQRQeedwqi4QJFVGfu5dUGtPUjZcGBYcOTMGYwjmhAxabfCqhb9lG1k4csOPvYb9lq(KMdY4lvc6z4cQ6FVGF1MqKmOFb0YAiD4zEEaODbtVaAznKo8mppaC0Yqn6PDbcOsq0ZxQe0ZWfu1)Eb)QnHizq)cOL1q6WZ88aq7cMEb0YAiD4zEEa4OLHA0t7cYzbv3vNe0fiGkbrpFPAPQQUQsqmybHGRo(9cwqLp4coL6MmlaUjlGwz3AF)zmAxabfCqhb9lG1k4csOPvYb9lq(KMdY4lvc6z4cO5VxWVAtisg0VaANuJ2WdaTly6fq7KA0gEa4OLHA0t7cYzbv3vNe0fiGkbrpFPsqpdxq1(9c(vBcrYG(fqlRH0HN55bG2fm9cOL1q6WZ88aWrld1ON2fiGkbrpFPsqpdxq1(9c(vBcrYG(fqlRH0HN55bG2fm9cOL1q6WZ88aWrld1ON2fKZcQURojOlqavcIE(sLGEgUaA87f8R2eIKb9lG2j1On8aq7cMEb0oPgTHhaoAzOg90Uabuji65lvc6z4cuPA)Eb)QnHizq)cODsnAdpa0UGPxaTtQrB4bGJwgQrpTlqavcIE(sLGEgUavR(FVGF1MqKmOFb0oPgTHhaAxW0lG2j1On8aWrld1ON2fiq1cIE(sLGEgUavR(FVGF1MqKmOFb0sGmeUjoipa0UGPxaTeidHBIdYdahTmuJEAxGaQge98Lkb9mCb0u1FVGF1MqKmOFb0oPgTHhaAxW0lG2j1On8aWrld1ON2fiGkbrpFPsqpdxanP5VxWVAtisg0VaANuJ2WdaTly6fq7KA0gEa4OLHA0t7ceqLGONVuTuvvxvjigSGqWvh)EblOYhCbNsDtMfa3Kfql8zh7bjmAxabfCqhb9lG1k4csOPvYb9lq(KMdY4lvc6z4cu53l4xTjejd6xaTtQrB4bG2fm9cODsnAdpaC0Yqn6PDbcOsq0ZxQe0ZWfOYVxWVAtisg0VaAjqgc3ehKhaAxW0lGwcKHWnXb5bGJwgQrpTlqavcIE(sLGEgUav)9c(vBcrYG(fq7KA0gEaODbtVaANuJ2WdahTmuJEAxGaQge98Lkb9mCb083l4xTjejd6xaTtQrB4bG2fm9cODsnAdpaC0Yqn6PDbcOsq0ZxQe0ZWfuTFVGF1MqKmOFb0oPgTHhaAxW0lG2j1On8aWrld1ON2fiqvhe98Lkb9mCb043l4xTjejd6xaTtQrB4bG2fm9cODsnAdpaC0Yqn6PDbcu1brpFPAPQQUQsqmybHGRo(9cwqLp4coL6MmlaUjlGwKvGjLuoNqK2fqqbh0rq)cyTcUGeAALCq)cKpP5Gm(sLGEgUav)9c(vBcrYG(fq7KA0gEaODbtVaANuJ2WdahTmuJEAxGaQee98Lkb9mCb043l4xTjejd6xaTtQrB4bG2fm9cODsnAdpaC0Yqn6PDbcOsq0ZxQe0ZWfqJFVGF1MqKmOFb0sGmeUjoipa0UGPxaTeidHBIdYdahTmuJEAxGaQge98Lkb9mCbv9VxWVAtisg0VaAjqgc3ehKhaAxW0lGwcKHWnXb5bGJwgQrpTlqavcIE(sLGEgUab5VxWVAtisg0VaAjqgc3ehKhaAxW0lGwcKHWnXb5bGJwgQrpTlqavcIE(s1svvDvLGyWccbxD87fSGkFWfCk1nzwaCtwaTiRatk1DRpZH2fqqbh0rq)cyTcUGeAALCq)cKpP5Gm(sLGEgUav(9c(vBcrYG(fq7KA0gEaODbtVaANuJ2WdahTmuJEAxGa0mi65lvc6z4cQ2VxWVAtisg0VaAjqgc3ehKhaAxW0lGwcKHWnXb5bGJwgQrpTliNfuDxDsqxGaQee98Lkb9mCbQ8ZVxWVAtisg0VaANuJ2WdaTly6fq7KA0gEa4OLHA0t7ceqLGONVujONHlqLQ97f8R2eIKb9lG2j1On8aq7cMEb0oPgTHhaoAzOg90UabOzq0ZxQwQeeuQBYG(fiixqkNRTfOp2W4lvrx9XgwSYORdAijNMWIvgdwLyLrx0Yqn6JVeDLKBqYLr3NwtxPU)qYcOSaASarXfiWc8yiemmpGqEhf0gou9cefxWtRPRu3Fizbuwq1wa9lq9ccHGH5(t4zyHGS2stICO6fikUGqiyy(tRPRKcrZbjCO6OBkNRTORm16skNRTI(yt0vFSPyPcgDHp7ypiHfNyWQgRm6IwgQrF8LORKCdsUm6wXciqgc3ehK7Hg6cBiZxCsHOMJwgQr)cefxqflysnAdh(SuxiOK62oZHJwgQr)cuVGkwWKA0gogekHMRTcdTbnjYrld1OFbIIliSzSfOEbWNZZuiOsEgBbbUabl6MY5Al6kmnbh0XEqcR8KkkijoXGPzSYOlAzOg9XxIUsYni5YOlbYq4M4G85blkPVuNK0PnoAzOg9lquCbYwiAPnCHOnp0rwG6fi7w77pJNSh0kpPw3FCcQKNXwW)fOQk)eDt5CTfDFsffKuA4YhjNN4edUAXkJUOLHA0hFj6kj3GKlJUpTMUsD)HKfeiLfO6cuVagoLW2Gy85qIQcwPA1YfOEbcSaz3AF)z8uiAoN5u(i58WjOsEgBbIIlq2T23FgxsGyPh5eujpJTa6JUPCU2IUFj1yPHlj7bzXjgmnIvgDrld1Op(s0vsUbjxgDFAnDL6(djliqklqLfOEbvSapgcbdZdiK3rbTHdvVa1lqGfuXcMuJ2WzijRFofoAzOg9lquCbHqWWCgsY6NtHdvVa6xG6fiWcQybK88fuiAdp9Eghd6ydBbIIlGKNVGcrB4P3Z4NTG)lGM)SarXfqYZxqHOn807zCO6fq)cuVabwqflysnAdh(SuxiOK62oZHJwgQr)cefxGhdHGH5WNL6cbLu32zoCO6fikUaz3AF)zC4ZsDHGsQB7mhobvYZyl4)cu9Nfq)cuVabwqflysnAdhdcLqZ1wHH2GMe5OLHA0VarXfaFoptHGk5zSfe4ceSfikUawnQ1Ljjo4W4(t4zyHnnrzb)PSaASa6xG6fiWcKDR99NXtHO5CMt5JKZdNGk5zSfikUaz3AF)zCjbILEKtqL8m2cOp6MY5Al66pHNHLP164edUQJvgDrld1Op(s0vsUbjxgDRybEmecgMhqiVJcAdhQEbQxGal4P10vQ7pKSG)uwGklq9ciqgc3ehKppyrjDo2qYbzLac5DuqB4OLHA0VarXf80A6k19hswWFklq1fqF0nLZ1w0nGqEhf0M4edwqgRm6IwgQrF8LORKCdsUm6kWcEAnDL6(djlGYc(zbIIl4P10vQ7pKSGaPSavxG6fi7w77pJhQtpwA4saHyZjrobvYZyl4)cCK(fuLfO6cOFbQxGalOIfqYZxqHOn807zCmOJnSfikUasE(ckeTHNEpJF2c(Vav)zbIIlGKNVGcrB4P3Z4q1lG(fOEbcSGkwWKA0godjz9ZPWrld1OFbIIlq2T23FgNHKS(5u4eujpJTG)lGglquCbYwiAPnCQPJCPTa6xG6fiWcQybtQrB4yqOeAU2km0g0KihTmuJ(fikUaz3AF)zCmiucnxBfgAdAsKtqL8m2c(VavOXcefxa858mfcQKNXwqGlqWwGO4cy1OwxMK4GdJ7pHNHf20eLf8NYcOXcOFbQxGalOIfmPgTHdFwQleusDBN5Wrld1OFbIIlq2T23Fgh(SuxiOK62oZHtqL8m2c(VavOXcefxa858mfcQKNXwqGlqWwa9lq9ceybYU1((Z4Pq0CoZP8rY5HtqL8m2cefxGSBTV)mUKaXspYjOsEgBb0hDt5CTfD)sQXsdxs2dYItmyblwz0fTmuJ(4lrxj5gKCz09P10vQ7pKSG)uwanxG6fecbdZLeiw6rou9cuVGqiyyUKaXspYztkPEbbUav(j6MY5Al6ktTUKY5AROp2eD1hBkwQGrx4Zo2dsyXjgC1hRm6IwgQrF8LORKCdsUm6kBZdDdhdQgI4KZ12cuVGNwtxPU)qYccKYcOz0nLZ1w0nuNES0WLacXMtIXjgSk)eRm6IwgQrF8LORKCdsUm6wXc8yiemmpGqEhf0gouD0nLZ1w0nGqEhf0M4edwfvIvgDt5CTfDFsffKuA4YhjNNOlAzOg9XxItmyvunwz0fTmuJ(4lrxj5gKCz09P10vQ7pKSGaPSaAgDt5CTfDd1PhlnCjGqS5KyCIbRcnJvgDrld1Op(s0vsUbjxgDfybtsCWH)GPEE41YzbbszbQ(ZcefxqiemmpfIMZzoLpsopCO6fikUGqiyyUKaXspYHQxGO4ccHGH5OsnDemTsD)Heou9cOp6MY5Al6ktTUKY5AROp2eD1hBkwQGrx4Zo2dsyXjgSkvlwz0fTmuJ(4lrxj5gKCz0TIfiBJHssoxBCO6fOEbSAuRltsCWHX9NWZWcBAIYc(tzbQgDt5CTfDLTXqjjNRT4edwfAeRm6IwgQrF8LORKCdsUm6k7w77pJljqS0JKcBih1ix(KehKvGjPCU2s9c(tzbQWfK0ybQxGal4P10vQ7pKSGaPSavxGO4cEAnDL6(djliqklGMlq9cKDR99NXd1PhlnCjGqS5KiNGk5zSf8Fbos)cQYcuDbIIl4P10vQ7pKSaklOAlq9cKDR99NXd1PhlnCjGqS5KiNGk5zSf8Fbos)cQYcuDbQxGSBTV)mEaH8okOnCcQKNXwW)f4i9lOklq1fqF0nLZ1w0vsGyPhjf2qoQX4edwLQowz0fTmuJ(4lr3uoxBrxzQ1LuoxBf9XMOR(ytXsfm6cF2XEqcloXGvrqgRm6IwgQrF8LORKCdsUm6wXcKTXqjjNRnouD0nLZ1w0v2gdLKCU2ItmyveSyLr3uoxBrxjbILEKuyd5OgJUOLHA0hFjoXGvP6JvgDt5CTfDtImnSmnHG2eDrld1Op(sCIbR6pXkJUPCU2IUY2yOKKZ1w0fTmuJ(4lXjorxpcNq6jwzmyvIvgDt5CTfDjyie1y0fTmuJ(4lXjgSQXkJUOLHA0hFj6MY5Al6ktTUKY5AROp2eD1hBkwQGrxz3AF)zS4edMMXkJUOLHA0hFj6kj3GKlJUcSGkwajpFbfI2WtVNXXGo2WwGO4ci55lOq0gE69mou9cefxajpFbfI2WtVNXpBbbUGQFbIIlGKNVGcrB4P3Z4NTG)lGM)Sa6xG6fiWcMuJ2WXGqj0CTvyOnOjroAzOg9lq9cKDR99NXXGqj0CTvyOnOjrobvYZyliWfu9lq9cy1OwxMK4GdJ7pHNHf20eLfe4cOXcefxWKA0go8zPUqqj1TDMdhTmuJ(fOEbYU1((Z4WNL6cbLu32zoCcQKNXwqGlO6xa9lq9cGpNNPqqL8m2c(Vabl6MY5Al6ktTUKY5AROp2eD1hBkwQGrxKvGjL6U1N5eNyWvlwz0fTmuJ(4lrxj5gKCz01JHqWWCmiucnxBfgAdAsKdvVarXf4Xqiyyo8zPUqqj1TDMdhQo6YgYjNyWQeDt5CTfDLPwxs5CTv0hBIU6JnflvWOlYkWKskNtigNyW0iwz0fTmuJ(4lr3uoxBrxzQ1LuoxBf9XMOR(ytXsfm66GgsYPjS4eNOBnbLTsyoXkJbRsSYOBkNRTOBDpxBrx0Yqn6JVeNyWQgRm6MY5Al6gQrg7mNsdxyqkkij6IwgQrF8L4edMMXkJUPCU2IUHAKXoZP0WLeAGuSOlAzOg9XxItm4QfRm6MY5Al6gQrg7mNsdx(oBqs0fTmuJ(4lXjgmnIvgDt5CTfDd1iJDMtPHlSAYzorx0Yqn6JVeNyWvDSYOlAzOg9XxIUsYni5YOlRH0HN551qSbsJfKavpxBC0Yqn6xGO4cynKo8mpxyRZ50yH1AHOnC0Yqn6JUPCU2IUWAK9ijj8eNyWcYyLrx0Yqn6JVeDLKBqYLr3j1OnC4ZsDHGsQB7mhoAzOg9lq9cMuJ2WzijRFofoAzOg9r3uoxBr3KitdlttiOnXjgSGfRm6MY5Al6YEou7lnCriAoyAsm6IwgQrF8L4eNORSBTV)mwSYyWQeRm6IwgQrF8LORKCdsUm6gcbdZtHO5CMt5JKZdhQEbIIliecgMljqS0JCO6fOEbHqWWCjbILEKZMus9cOSav(zbIIliSzSfOEbWNZZuiOsEgBbbUavPr0nLZ1w0TUNRT4edw1yLrx0Yqn6JVeDLKBqYLrxwnQ1Ljjo4W46Z5zyLac5DuqBwWFklq1fikUGkwajpFbfI2WtVNXXGo2WwGO4ci55lOq0gE69m(zl4)ceK0ybIIlGKNVGcrB4P3Z4q1r3uoxBrx958mSsaH8okOnXjgmnJvgDrld1Op(s0vsUbjxgDfybHqWW8uiAoN5u(i58WHQxGO4ccHGH5scel9ihQEbQxqiemmxsGyPh5SjLuVaklqLFwa9lq9cQybtQrB4yqOeAU2km0g0KihTmuJ(OBkNRTOl8rWqD3(4edUAXkJUOLHA0hFj6kj3GKlJUSgshEMNxdXginwqcu9CTXrld1OFbIIlG1q6WZ8CHToNtJfwRfI2Wrld1Op6E2Gecu9uo4OlRH0HN55cBDoNglSwleTj6E2Gecu9uoff0F5GrxvIUPCU2IUWAK9ijj8eDpBqcbQEko6om1rxvItmyAeRm6IwgQrF8LORKCdsUm6kWcQybtQrB4yqOeAU2km0g0KihTmuJ(fikUaz3AF)zCmiucnxBfgAdAsKtqL8m2ccCb0q1fq)cuVa4Z5zkeujpJTG)lqfAeDt5CTfDzphQ9LgUienhmnjgNyWvDSYOBkNRTOBOgzSZCknCHbPOGKOlAzOg9XxItmybzSYOBkNRTOBOgzSZCknCjHgifl6IwgQrF8L4edwWIvgDt5CTfDd1iJDMtPHlFNnij6IwgQrF8L4edU6JvgDt5CTfDd1iJDMtPHlSAYzorx0Yqn6JVeNyWQ8tSYOlAzOg9XxIUPCU2IUNXKeOjd1yrWbL2aPu8OWtIrxj5gKCz0necgMNcrZ5mNYhjNhou9cefxqiemmxsGyPh5q1lq9ccHGH5scel9iNnPK6fqzbQ8ZcefxqyZylq9cGpNNPqqL8m2ccCb08NORLky09mMKanzOglcoO0giLIhfEsmoXGvrLyLrx0Yqn6JVeDt5CTfDBHi57b1kN5uQ7pKuKe6ytQJUsYni5YOBiemmpfIMZzoLpsopCO6fikUGqiyyUKaXspYHQxG6fecbdZLeiw6roBsj1lGYcu5NfikUGWMXwG6faFoptHGk5zSfe4cuHgrxlvWOBlejFpOw5mNsD)HKIKqhBsDCIbRIQXkJUOLHA0hFj6MY5Al66tc1kDBfpkPUiSjP8g6IUsYni5YOBiemmpfIMZzoLpsopCO6fikUGqiyyUKaXspYHQxG6fecbdZLeiw6roBsj1lGYcu5NfikUGWMXwG6faFoptHGk5zSfe4cu9NORLky01NeQv62kEusDryts5n0fNyWQqZyLrx0Yqn6JVeDt5CTfDvszgsWc7bXPOaXoz0vsUbjxgDdHGH5Pq0CoZP8rY5HdvVarXfecbdZLeiw6rou9cuVGqiyyUKaXspYztkPEbuwGk)SarXfe2m2cuVa4Z5zkeujpJTGaxGQ)eDTubJUkPmdjyH9G4uuGyNmoXGvPAXkJUOLHA0hFj6MY5Al6cNq6HUISHSbjkyYGiy0vsUbjxgDRybtQrB4scel9ihTmuJ(fikUGqiyyUKaXspYHQxGO4ccBgBbQxa858mfcQKNXwqGlGM)eDTubJUWjKEORiBiBqIcMmicgNyWQqJyLrx0Yqn6JVeDTubJUEcME4JGfHiJH6OBkNRTORNGPh(iyriYyOooXGvPQJvgDrld1Op(s01sfm6YOgstnsyLVZCIUPCU2IUmQH0uJew57mN4edwfbzSYOlAzOg9XxIUwQGrxhYPuKThdk6MY5Al66qoLIS9yqXjgSkcwSYOlAzOg9XxIUwQGrxfuPj0vA4sDYMc7mw0nLZ1w0vbvAcDLgUuNSPWoJfNyWQu9XkJUOLHA0hFj6APcgDz1jblkyoLNUPo6MY5Al6YQtcwuWCkpDtDCIbR6pXkJUOLHA0hFj6APcgDzPwy6G(cme7ARKk16d(qs0nLZ1w0LLAHPd6lWqSRTsQuRp4djXjgSQQeRm6IwgQrF8LORLky015sBknXsf0MuxQXKOJUPCU2IUoxAtPjwQG2K6snMeDCIbRQQXkJUOLHA0hFj6APcgD)oZZKjP89GdBAdJUPCU2IUFN5zYKu(EWHnTHXjgSQ0mwz0fTmuJ(4lrxlvWOltMewPHlWKCqIL6cBihmgDt5CTfDzYKWknCbMKdsSuxyd5GX4edw1QfRm6IwgQrF8LORLky0v(KNXknCX3kNLZ1w0nLZ1w0v(KNXknCX3kNLZ1wCIbRknIvgDrld1Op(s01sfm6IjzEcjysnsyLtPoLt0nLZ1w0ftY8esWKAKWkNsDkN4edw1Qowz0fTmuJ(4lr3uoxBr3hmjtPHlZdwyFjrj6kj3GKlJUvSGqiyyEkenNZCkFKCE4q1lq9ccHGH5scel9ihQo6APcgDFWKmLgUmpyH9LeL4edwvbzSYOlAzOg9XxIUPCU2IUo60F50ewjm9oy0vsUbjxgDdHGH5Pq0CoZP8rY5HdvVarXfecbdZLeiw6rou9cuVGqiyyUKaXspYztkPEb)PSav(zbIIlq2T23FgpfIMZzoLpsopCcQKNXwW)funASarXfi7w77pJljqS0JCcQKNXwW)funAeDTubJUo60F50ewjm9oyCIbRQGfRm6IwgQrF8LORKCdsUm6gcbdZtHO5CMt5JKZdhQEbIIliecgMljqS0JCO6fOEbHqWWCjbILEKZMus9c(tzbQ8t0nLZ1w0fIHLBqfwCIbRA1hRm6IwgQrF8LORKCdsUm6kWcEAnDL6(djl4pLfuTfOEbZPGliWfqJfikUGNwtxPU)qYc(tzb0CbQxGalyofCb)xanwGO4ciqgc3ehKppyrjDo2qYbzLac5DuqB4OLHA0Va6xGO4cEAnDL6(djl4pLfO6cuVacKHWnXb5ctZbkjEwrPvqBGu4OLHA0Va1lysnAdh(SuxiOK62oZHJwgQr)cefxWKA0g(tRPRKcrZbjC0Yqn6xG6fi7w77pJ)0A6kPq0CqcNGk5zSfqzb)Sa6xG6fiWcQybtQrB4mKK1pNchTmuJ(fikUGkwWKA0go8zPUqqj1TDMdhTmuJ(fikUaz3AF)zCgsY6NtHtqL8m2c(VGFwa9r3uoxBr3uiAoN5u(i58eNyW08NyLrx0Yqn6JVeDLKBqYLr3NwtxPU)qYc(tzbvBbQxWCk4ccCb0ybIIl4P10vQ7pKSG)uwanxG6fmNcUG)lGgr3uoxBrxjbILEmoXGPPkXkJUPCU2IUj7bTYtQ19x0fTmuJ(4lXjgmnvnwz0fTmuJ(4lrxj5gKCz0DofSmD5P2zbuwWplq9cEAnDL6(djliqklq1fOEbcSGqiyyEkenNZCkFKCE4q1lquCbtQrB4scel9ihTmuJ(fOEbcSaz3AF)zCjbILEKtqL8m2cOSGFwGO4ccHGH5scel9ihQEb0VarXfe2m2cuVa4Z5zkeujpJTGaxGQ)Sa6JUPCU2IUpTMUskenhKeNyW0KMXkJUOLHA0hFj6kj3GKlJUcSGNwtxPU)qYc(tzbvBbQxWCk4ccCbc2cefxWtRPRu3Fizb)PSaAUa1lqGfmNcUG)uwGGTarXfWQrTUmjXbhg3FcpdlSPjkl4pLfO6cuVazleT0go10rU0wa9lG(fOEbYU1((Z4Pq0CoZP8rY5HtqL8m2c(VahPFbQxWCkyz6YtTZcOSGFwG6fiWcQybtQrB4mKK1pNchTmuJ(fikUGqiyyodjz9ZPWHQxa9lq9ceybvSasE(ckeTHNEpJJbDSHTarXfqYZxqHOn807zCO6fikUasE(ckeTHNEpJF2c(VGQ9ZcOFbQxGalOIfecbdZtHO5CMt5JKZdhQEbIIl4P10vQ7pKSaklGglquCbYU1((Z4pPIcsknC5JKZdNGk5zSfikUawnQ1Ljjo4W4(t4zyHnnrzb)PSavxG6fiBHOL2WPMoYL2cOp6MY5Al6cFwQleusDBN5eN4eDHp7ypiHfRmgSkXkJUOLHA0hFj621rxgor3uoxBrxHj5YqngDfMAim6YQrTUmjXbhg3FcpdlSPjklGYcuDbQxqflqGfqGmeUjoih(SuxeIe)jhoAzOg9lquCbtQrB4KZ5zWgIveIe)jhoAzOg9lG(fikUawnQ1Ljjo4W4(t4zyHnnrzb)xGQlquCbHqWWCuPMocMwPU)qchQEbQxqflWJHqWW8ac5DuqB4q1lq9cQybHqWWC)j8mSudrQBgYHQJUctsXsfm66zfzYMmuJXjgSQXkJUOLHA0hFj6kj3GKlJUcSaz3AF)z8uiAoN5u(i58WjOsEgBb)xGk0ybIIlq2T23FgxsGyPh5eujpJTG)lqfASa6xG6fiWcQybtQrB4WNL6cbLu32zoC0Yqn6xGO4cKDR99NXHpl1fckPUTZC4eujpJTG)liLZ1wr2T23F2cOFbQxGalOIfmPgTHJbHsO5ARWqBqtIC0Yqn6xGO4cKDR99NXXGqj0CTvyOnOjrobvYZyl4)cs5CTvKDR99NTarXfWQrTUmjXbhg3FcpdlSPjkl4pLfqJfq)cuVabwqflGKNVGcrB4P3Z4yqhBylquCbK88fuiAdp9Eg)Sf8Fbv7NfikUasE(ckeTHNEpJF2ccCbos)cefxajpFbfI2WtVNXHQxa9lq9ceybvSazleT0go10rU0wGO4ceybYU1((Z4(t4zyzATMtqL8m2ccCbv)cefxGSBTV)mU)eEgwMwR5eujpJTG)liLZ1wr2T23F2cOFb0VarXfaFoptHGk5zSfe4cuHglq9cGpNNPqqL8m2c(VaASarXfecbdZLeiw6rou9cuVGqiyyUKaXspYztkPEbbUav(j6MY5Al6Yqsw)CkXjgmnJvgDrld1Op(s0vsUbjxgDfybHqWWCjbILEK77pBbQxGSBTV)mUKaXspYjOsEgBb)xGk)SarXfecbdZLeiw6roBsj1l4pLfqZfikUaz3AF)z8uiAoN5u(i58WjOsEgBb)xGk)Sa6xG6fiWcQybtQrB4WNL6cbLu32zoC0Yqn6xGO4cKDR99NXHpl1fckPUTZC4eujpJTG)lqLFwa9lq9cGpNNPqqL8m2c(VabBbQxaRg16YKehCyC)j8mSWMMOSGaxanIUPCU2IUyqOeAU2km0g0KyCIbxTyLrx0Yqn6JVeDLKBqYLrxHj5YqnY9SImztgQXfOEbvSGqiyyUW0eCqh7bjSYtQOGeou9cuVabwGalOIfmPgTHljqS0JC0Yqn6xGO4cKDR99NXLeiw6robvYZyl4)cCK(fuLfqZfq)cuVabwqflysnAdhdcLqZ1wHH2GMe5OLHA0VarXfi7w77pJJbHsO5ARWqBqtICcQKNXwW)f4i9lOklOQxGO4cKDR99NXXGqj0CTvyOnOjrobvYZyl4)cCK(fuLfuTfOEbpTMUsD)HKf8NYcOXcefxaRg16YKehCyC)j8mSWMMOSG)uwanwGO4cQybtQrB4mKK1pNchTmuJ(fOEbYU1((Z4yqOeAU2km0g0KiNGk5zSf8Fbos)cQYcuDb0Va1lqGfuXcMuJ2WHpl1fckPUTZC4OLHA0VarXfi7w77pJdFwQleusDBN5WjOsEgBb)xGJ0VGQSGQEbIIlq2T23Fgh(SuxiOK62oZHtqL8m2c(VahPFbvzbvBbQxWtRPRu3Fizb)PSaASarXfuXcMuJ2WzijRFofoAzOg9lq9cKDR99NXHpl1fckPUTZC4eujpJTG)lWr6xqvwGQlG(fikUGj1On8NwtxjfIMds4OLHA0Va1lq2T23Fg)P10vsHO5GeobvYZyliWf4i9lOklGMlquCbHqWW8NwtxjfIMds4q1lquCbHqWWCjbILEKdvVa1liecgMljqS0JC2KsQxqGlqLFwGO4cGpNNPqqL8m2ccCbc2cOp6MY5Al66pHNHf20eL4edMgXkJUOLHA0hFj6kj3GKlJUcSGkwWKA0gUKaXspYrld1OFbIIlq2T23FgxsGyPh5eujpJTG)lWr6xqvwanxa9lq9ceybvSGj1OnCmiucnxBfgAdAsKJwgQr)cefxGSBTV)mogekHMRTcdTbnjYjOsEgBb)xGJ0VGQSabBbIIlq2T23FghdcLqZ1wHH2GMe5eujpJTG)lWr6xqvwqvVa1l4P10vQ7pKSG)uwq1wGO4cQybtQrB4mKK1pNchTmuJ(fOEbYU1((Z4yqOeAU2km0g0KiNGk5zSf8Fbos)cQYcuDb0Va1lqGfuXcMuJ2WHpl1fckPUTZC4OLHA0VarXfi7w77pJdFwQleusDBN5WjOsEgBb)xGJ0VGQSabBbIIlq2T23Fgh(SuxiOK62oZHtqL8m2c(VahPFbvzbv9cuVGNwtxPU)qYc(tzbvBbIIlOIfmPgTHZqsw)CkC0Yqn6xG6fi7w77pJdFwQleusDBN5WjOsEgBb)xGJ0VGQSavxa9lquCbtQrB4pTMUskenhKWrld1OFbQxGSBTV)m(tRPRKcrZbjCcQKNXwqGlWr6xqvwanxGO4ccHGH5pTMUskenhKWHQxGO4ccHGH5scel9ihQEbQxqiemmxsGyPh5SjLuVGaxGk)SarXfaFoptHGk5zSfe4ceSOBkNRTO7Gk16KWkcrI)KtCIt0fzfysjLZjeJvgdwLyLr3uoxBrx4JGH6U9rx0Yqn6JVeNyWQgRm6IwgQrF8LORKCdsUm6(0A6k19hswaLfqJfikUapgcbdZdiK3rbTHdvVarXf4Xqiyyo8zPUqqj1TDMdhQEbQxGalWJHqWWC4ZsDHGsQB7mhobvYZyliWf4i9CLmOfikUawnQ1Ljjo4W4(t4zyHnnrzb)PSavxG6fuXcMuJ2WXGqj0CTvyOnOjroAzOg9lG(fikUapgcbdZXGqj0CTvyOnOjrou9cuVapgcbdZXGqj0CTvyOnOjrobvYZyliWf4i9CLmOOBkNRTORm16skNRTI(yt0vFSPyPcgDHp7ypiHfNyW0mwz0nLZ1w01FcpdltR1rx0Yqn6JVeNyWvlwz0nLZ1w0vyAcoOJ9Gew5jvuqs0fTmuJ(4lXjgmnIvgDrld1Op(s0vsUbjxgDFAnDL6(djliqklq1fOEbcSapgcbdZHpl1fckPUTZC4q1lq9c8yiemmh(SuxiOK62oZHtqL8m2ccCbos)cQYcuDbQxqflGaziCtCqU)eEgwiiRT0KihTmuJ(fikUapgcbdZXGqj0CTvyOnOjrou9cuVapgcbdZXGqj0CTvyOnOjrobvYZyliWf4i9lquCbSAuRltsCWHX9NWZWcBAIYc(tzb0ybQxabYq4M4GC)j8mSqqwBPjroAzOg9lq9cMuJ2WXGqj0CTvyOnOjroAzOg9lG(OBkNRTO7xsnwA4sYEqwCIbx1XkJUOLHA0hFj6kj3GKlJUY28q3WXGQHio5CTTa1lqGfuXciqgc3ehK7pHNHfcYAlnjYrld1OFbQxWtRPRu3Fizbbszb0CbIIl4P10vQ7pKSGaPSavxa9r3uoxBr3qD6XsdxcieBojgNyWcYyLrx0Yqn6JVeDLKBqYLr3kwGhdHGH5beY7OG2WHQxG6fiWcEAnDL6(djl4pLfOYcuVacKHWnXb5ZdwusNJnKCqwjGqEhf0goAzOg9lquCbpTMUsD)HKf8NYcuDb0hDt5CTfDdiK3rbTjoXGfSyLrx0Yqn6JVeDt5CTfDLPwxs5CTv0hBIU6JnflvWOl8zh7bjS4edU6JvgDrld1Op(s0vsUbjxgDFAnDL6(djliqklq1OBkNRTO7xsnwA4sYEqwCIbRYpXkJUOLHA0hFj6kj3GKlJUpTMUsD)HKfeiLfqZOBkNRTOBOo9yPHlbeInNeJtmyvujwz0fTmuJ(4lrxj5gKCz0TIf4XqiyyEaH8okOnCO6OBkNRTOBaH8okOnXjgSkQgRm6MY5Al6(KkkiP0WLpsoprx0Yqn6JVeNyWQqZyLr3uoxBrxjbILEKuyd5OgJUOLHA0hFjoXGvPAXkJUPCU2IUjrMgwMMqqBIUOLHA0hFjoXGvHgXkJUPCU2IUY2yOKKZ1w0fTmuJ(4lXjorxKvGjL6U1N5eRmgSkXkJUOLHA0hFj6kj3GKlJUpTMUsD)HKfqzb0ybQxGalOIfmPgTHdFwQleusDBN5Wrld1OFbIIlq2T23Fgh(SuxiOK62oZHtqL8m2ccKYcCK(fuLfqZfikUaz3AF)zC4ZsDHGsQB7mhobvYZyl4)cs5CTvKDR99NTa6xG6fiWcQybtQrB4yqOeAU2km0g0KihTmuJ(fikUaz3AF)zCmiucnxBfgAdAsKtqL8m2ccKYcCK(fuLfqZfikUaz3AF)zCmiucnxBfgAdAsKtqL8m2c(VGuoxBfz3AF)zlquCbtQrB4WNL6cbLu32zoC0Yqn6xa9lq9ceybvSazleT0go10rU0wGO4cKDR99NX9NWZWY0AnNGk5zSfe4cQ(fikUaz3AF)zC)j8mSmTwZjOsEgBb)xqkNRTISBTV)SfqF0nLZ1w0LHKS(5uItmyvJvgDrld1Op(s0vsUbjxgDFAnDL6(djlGYcOXcefxGhdHGH5WNL6cbLu32zoCO6fikUGqiyyUKaXspYHQxG6fecbdZLeiw6roBsj1liWfOYpr3uoxBrxzQ1LuoxBf9XMOR(ytXsfm6cF2XEqcloXGPzSYOlAzOg9XxIUsYni5YOBiemmNHKS(5u4q1r3uoxBrxHPj4Go2dsyLNurbjXjgC1IvgDrld1Op(s0vsUbjxgDjqgc3ehKlmnhOK4zfLwbTbsHJwgQrF0nLZ1w09jvuqsPHlFKCEItmyAeRm6IwgQrF8LORKCdsUm6(0A6k19hswqGuwGQlq9cy4ucBdIXNdjQkyLQvlJUPCU2IUFj1yPHlj7bzXjgCvhRm6IwgQrF8LORKCdsUm6(0A6k19hswqGuwanJUPCU2IUH60JLgUeqi2CsmoXGfKXkJUOLHA0hFj6kj3GKlJUvSapgcbdZdiK3rbTHdvhDt5CTfDdiK3rbTjoXGfSyLr3uoxBr3NurbjLgU8rY5j6IwgQrF8L4edU6JvgDrld1Op(s0vsUbjxgDLDR99NXLeiw6rsHnKJAKlFsIdYkWKuoxBPEb)PSav4csASa1lqGf80A6k19hswqGuwGQlquCbpTMUsD)HKfeiLfqZfOEbYU1((Z4H60JLgUeqi2CsKtqL8m2c(VahPFbvzbQUarXf80A6k19hswaLfuTfOEbYU1((Z4H60JLgUeqi2CsKtqL8m2c(VahPFbvzbQUa1lq2T23FgpGqEhf0gobvYZyl4)cCK(fuLfO6cOp6MY5Al6kjqS0JKcBih1yCIbRYpXkJUOLHA0hFj6kj3GKlJUvSGj1OnC4ZsDHGsQB7mhoAzOg9lq9cKDR99NXXGqj0CTvyOnOjrobvYZyliqklWr6xqvwanxG6fiWcQybYwiAPnCQPJCPTarXfi7w77pJ7pHNHLP1AobvYZyliWfu9lG(OBkNRTOldjz9ZPeNyWQOsSYOlAzOg9XxIUPCU2IUYuRlPCU2k6Jnrx9XMILky0f(SJ9GewCIbRIQXkJUPCU2IUscel9iPWgYrngDrld1Op(sCIbRcnJvgDrld1Op(s0vsUbjxgDFAnDL6(djliqklOAr3uoxBr3KitdlttiOnXjgSkvlwz0fTmuJ(4lrxj5gKCz0vGfuXcMuJ2WHpl1fckPUTZC4OLHA0VarXfi7w77pJdFwQleusDBN5WjOsEgBbbszbos)cQYcO5cOFbQxGalOIfmPgTHJbHsO5ARWqBqtIC0Yqn6xGO4cKDR99NXXGqj0CTvyOnOjrobvYZyliqklWr6xqvwanxGO4cMuJ2WHpl1fckPUTZC4OLHA0Va6xG6fiWcQybYwiAPnCQPJCPTarXfi7w77pJ7pHNHLP1AobvYZyliWfu9lG(OBkNRTOldjz9ZPeNyWQqJyLr3uoxBrxzBmusY5Al6IwgQrF8L4eN4eDtO5Pjrx3t5xXjoXia]] )


end
