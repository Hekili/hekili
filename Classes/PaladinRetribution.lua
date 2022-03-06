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


    spec:RegisterPack( "Retribution", 20220305, [[dKKY)bqijHhPkaBIK6tiLgfbCkKQwLKeVsvuZsvKBPkqSlu9lvHgMQkDmsILrs6zifnnjjDnvvSnvb13iqLXrGY5ufK1HuW8eq3dj2NQQoibQQfkj1drk0evfiDrceYhvfqoPQa1krsMjbs3uvaLDkq9tceQHQkGQLsGGNsQMQKOVsGQmwbWEf6VsmyGdlAXc6XenzQ6YqBguFMugTQ0Pvz1cqVgj1SPYTjXUP8BPgUK64eiA5iEoktxX1bz7e03vvgVa58ivMpH2Vshvjwzu3Ndgdw1Fvv1FP5V)Wv5NFRAvvnQp0vJr96usDQHrDlvWOUGaoKleAU2I61jDUo9XkJ6SgIiXOEupe6CZd2IHrDFoymyv)vvv)LM)(dxLF(TQvnQZQrzmyb3Vr93Z7rlgg19itg1feWHCHqZ12cEGNU0F2s1dSKiFxWppTav)vvvxQwQOX300qgnSu9GSGhSnOgjhCbg(TGAY1KBOBbSA3nlaM0klq)uOr(s1dYcEGLuJlqhjz97PSGVMq9ccXzqYc(U5Db98IKfqJpOSfmTMMd9lOHH5lvpil4bTnANf8LSbxGc6piLhDjrdxan(GYwqBlWt3zAlOoLuZwaK5qgBb3qlBb5ccBgBbWN27WJ61Kg(Cyu)b8awGGaoKleAU2wWd80L(ZwQEapGf8aljY3f8Ztlq1Fvv1LQLQhWdyb04BAAiJgwQEapGf8GSGhSnOgjhCbg(TGAY1KBOBbSA3nlaM0klq)uOr(s1d4bSGhKf8alPgxGosY63tzbFnH6feIZGKf8DZ7c65fjlGgFqzlyAnnh6xqddZxQEapGf8GSGh02ODwWxYgCbkO)GuE0LenCb04dkBbTTapDNPTG6usnBbqMdzSfCdTSfKliSzSfaFAVdFPAPkLZ1gJxtqzReMdL6EU2wQs5CTX41eu2kH58mLhdDiJDMwPHlmiffKSuLY5AJXRjOSvcZ5zkpg6qg7mTsdxsObsXwQs5CTX41eu2kH58mLhdDiJDMwPHlFNnizPkLZ1gJxtqzReMZZuEm0Hm2zALgUWQjNPTuLY5AJXRjOSvcZ5zkpc7q2RKKWZthmfwd5cpZZRHydKdlibQEU2efznKl8mpxy7Y5CyH1oHOnlvPCU2y8AckBLWCEMYJjrMgwMMqqBE6GPmPdTHdFw6keusDBNPXrldDOx9Ko0godjz97PWrldDOFPkLZ1gJxtqzReMZZuEK9EOZxA4Iq00W0K4s1s1d4bSabrbHsOb9lafIe6wWCk4cMxCbPCAYco2csH55YqhYxQs5CTXOqWqiQXLQuoxBSNP8OmDUskNRTI7yZtwQGuKD789NXwQs5CTXEMYJY05kPCU2kUJnpzPcsbzfysPUB3zApDWueOcsE(ckeTHNEpJJbDSHjksYZxqHOn807zCOArrsE(ckeTHNEpJFwGpKOijpFbfI2WtVNXp7pn)LE1cmPdTHJbHsO5ARWqBqtIQLD789NXXGqj0CTvyOnOjrobvYZyb(qQz1OZvMKOHdJ7pHNHf20eLa)ruCshAdh(S0viOK62ottTSBNV)mo8zPRqqj1TDMgNGk5zSaFi6vpjrdh(Ckyz6I)W)c2svkNRn2ZuEuMoxjLZ1wXDS5jlvqkiRatkPCoH4tSHCYHIkpDWu8yiemmhdcLqZ1wHH2GMe5q1IIEmecgMdFw6keusDBNPXHQxQs5CTXEMYJY05kPCU2kUJnpzPcsrdnKKttylvlvPCU2yCz3oF)zmk19CT90btjecgMNcrt7mTYhjNxouTOyiemmxsGyPh5q1QdHGH5scel9iNnPKAkQ8ROyyZyQHpT3PqqL8mwGQ(ZsvkNRngx2TZ3Fg7zkp6oT3HvciKxtbT5PdMcRgDUYKenCyC3P9oSsaH8AkOn)POQOyfK88fuiAdp9Eghd6ydtuKKNVGcrB4P3Z4N9xW9JOijpFbfI2WtVNXHQxQs5CTX4YUD((Zypt5r4JGHUU9pDWueiecgMNcrt7mTYhjNxouTOyiemmxsGyPh5q1QdHGH5scel9iNnPKAkQ8l9QRyshAdhdcLqZ1wHH2GMexQs5CTX4YUD((Zypt5ryhYELKeEE6GPWAix4zEEneBGCybjq1Z1MOiRHCHN55cBxoNdlS2jeT5PZgKqGQNYPOG(lhKIkpD2Gecu9u0CDy6OOYtNniHavpLdMcRHCHN55cBxoNdlS2jeTzPkLZ1gJl7257pJ9mLhzVh68LgUiennmnj(0btrGkM0H2WXGqj0CTvyOnOjrrrz3oF)zCmiucnxBfgAdAsKtqL8mwG)Ok9QHpT3PqqL8m2Fv(zPkLZ1gJl7257pJ9mLhdDiJDMwPHlmiffKSuLY5AJXLD789NXEMYJHoKXotR0WLeAGuSLQuoxBmUSBNV)m2ZuEm0Hm2zALgU8D2GKLQuoxBmUSBNV)m2ZuEm0Hm2zALgUWQjNPTuLY5AJXLD789NXEMYJqmSCdQ8KLkiLZysc0KHoSiiHsBGukEu4jXNoykHqWW8uiAANPv(i58YHQffdHGH5scel9ihQwDiemmxsGyPh5SjLutrLFffdBgtn8P9ofcQKNXcKM)UuLY5AJXLD789NXEMYJqmSCdQ8KLkiLwis(ErNYzAL6(djfjHo2KUNoykHqWW8uiAANPv(i58YHQffdHGH5scel9ihQwDiemmxsGyPh5SjLutrLFffdBgtn8P9ofcQKNXcuLFwQs5CTX4YUD((Zypt5rigwUbvEYsfKIpjuR0Tv8OK6IWMKYBO7PdMsiemmpfIM2zALpsoVCOArXqiyyUKaXspYHQvhcbdZLeiw6roBsj1uu5xrXWMXudFAVtHGk5zSav93LQuoxBmUSBNV)m2ZuEeIHLBqLNSubPOKYmKGf2lItrbIDYNoykHqWW8uiAANPv(i58YHQffdHGH5scel9ihQwDiemmxsGyPh5SjLutrLFffdBgtn8P9ofcQKNXcu1FxQs5CTX4YUD((Zypt5rigwUbvEYsfKcCc5g6kYgYgKOGjdIGpDWuQyshAdxsGyPhffdHGH5scel9ihQwumSzm1WN27uiOsEglqA(7svkNRngx2TZ3Fg7zkpcXWYnOYtwQGu8em9WhblcrgdDlvPCU2yCz3oF)zSNP8iedl3GkpzPcsHrnKJAKWkFNPTuLY5AJXLD789NXEMYJqmSCdQ8KLkifnYPuKThdAPkLZ1gJl7257pJ9mLhHyy5gu5jlvqkkOstOR0WL6Knf2zSLQuoxBmUSBNV)m2ZuEeIHLBqLNSubPWQtcwuWCkVDt9svkNRngx2TZ3Fg7zkpcXWYnOYtwQGuyPtyQH(cme7ARKk1Ud(qYsvkNRngx2TZ3Fg7zkpcXWYnOYtwQGu0U0MstSubTjDLAmjULQuoxBmUSBNV)m2ZuEeIHLBqLNSubP8DMNjts57fh20gUuLY5AJXLD789NXEMYJqmSCdQ8KLkifMmjSsdxGj5GelDf2qoyCPkLZ1gJl7257pJ9mLhHyy5gu5jlvqkY38mwPHl(w5SCU2wQs5CTX4YUD((Zypt5rigwUbvEYsfKcMK5nKGj1iHvoL6uolvPCU2yCz3oF)zSNP8iedl3GkpzPcs5ftYuA4Y8If2xsuE6GPuriemmpfIM2zALpsoVCOA1HqWWCjbILEKdvVuLY5AJXLD789NXEMYJqmSCdQ8KLkifnx6VCAcReMEn8PdMsiemmpfIM2zALpsoVCOArXqiyyUKaXspYHQvhcbdZLeiw6roBsj1)POYVIIYUD((Z4Pq00otR8rY5LtqL8m2)Q(JOOSBNV)mUKaXspYjOsEg7Fv)zPkLZ1gJl7257pJ9mLhHyy5guH90btjecgMNcrt7mTYhjNxouTOyiemmxsGyPh5q1QdHGH5scel9iNnPK6)uu53LQuoxBmUSBNV)m2ZuEmfIM2zALpsoVpDWue4TD0vQ7pK8NsvvpNcg4pIIVTJUsD)HK)uOPAbMtb))JOibYq4MOH85flkP2XgsoiReqiVMcAd9IIVTJUsD)HK)uuvnbYq4MOHCHPPbLepRO0kOnqkQN0H2WHplDfckPUTZ0efN0H2WFBhDLuiAAirTSBNV)m(B7ORKcrtdjCcQKNXO8l9QfOIjDOnCgsY63truSIjDOnC4ZsxHGsQB7mnrrz3oF)zCgsY63tHtqL8m2)FPFPkLZ1gJl7257pJ9mLhLeiw6XNoykVTJUsD)HK)uQQ65uWa)ru8TD0vQ7pK8NcnvpNc()NLQuoxBmUSBNV)m2ZuEmzVOvEtNR)wQs5CTX4YUD((Zypt5X32rxjfIMgsE6GPmNcwMU8wRr5x1VTJUsD)HKaPOQAbcHGH5Pq00otR8rY5LdvlkoPdTHljqS0JQfq2TZ3FgxsGyPh5eujpJr5xrXqiyyUKaXspYHQPxumSzm1WN27uiOsEglqv)L(LQuoxBmUSBNV)m2ZuEe(S0viOK62ot7PdMIaVTJUsD)HK)uQQ65uWafmrX32rxPU)qYFk0uTaZPG)PiyIISA05kts0WHX9NWZWcBAIYFkQQw2crlTHtnDKln6PxTSBNV)mEkenTZ0kFKCE5eujpJ9xt6vpNcwMU8wRr5x1cuXKo0godjz97PikgcbdZzijRFpfoun9QfOcsE(ckeTHNEpJJbDSHjksYZxqHOn807zCOArrsE(ckeTHNEpJF2)Q(l9QfOIqiyyEkenTZ0kFKCE5q1IIVTJUsD)Hek)ikk7257pJ)MkkiP0WLpsoVCcQKNXefz1OZvMKOHdJ7pHNHf20eL)uuvTSfIwAdNA6ixA0VuTuLY5AJXrwbMus5CcrkWhbdDD7xQs5CTX4iRatkPCoH4ZuEuMoxjLZ1wXDS5jlvqkWNDSxKWE6GP82o6k19hsO8JOOhdHGH5beYRPG2WHQff9yiemmh(S0viOK62otJdvRwapgcbdZHplDfckPUTZ04eujpJfOM0ZvYGefz1OZvMKOHdJ7pHNHf20eL)uuvDft6qB4yqOeAU2km0g0Ki9IIEmecgMJbHsO5ARWqBqtICOA1EmecgMJbHsO5ARWqBqtICcQKNXcut65kzqlvPCU2yCKvGjLuoNq8zkp6pHNHLPDULQuoxBmoYkWKskNti(mLhfMMGe6yViHvEtffKSuLY5AJXrwbMus5CcXNP84xsnwA4sYEr2thmL32rxPU)qsGuuvTaEmecgMdFw6keusDBNPXHQv7Xqiyyo8zPRqqj1TDMgNGk5zSa1K(QOQ6kiqgc3enK7pHNHfcYAlnjkk6XqiyyogekHMRTcdTbnjYHQv7XqiyyogekHMRTcdTbnjYjOsEglqnPxuKvJoxzsIgomU)eEgwyttu(t5h1eidHBIgY9NWZWcbzTLMevpPdTHJbHsO5ARWqBqtI0VuLY5AJXrwbMus5CcXNP8yOl9yPHlbeInNeF6GPiBZdDdhdQgIOLZ1MAbQGaziCt0qU)eEgwiiRT0KO632rxPU)qsGuOPO4B7ORu3FijqkQs)svkNRnghzfysjLZjeFMYJbeYRPG280btPcpgcbdZdiKxtbTHdvRwG32rxPU)qYFkQOMaziCt0q(8IfLu7ydjhKvciKxtbTru8TD0vQ7pK8NIQ0VuLY5AJXrwbMus5CcXNP8OmDUskNRTI7yZtwQGuGp7yViHTuLY5AJXrwbMus5CcXNP84xsnwA4sYEr2thmL32rxPU)qsGuuDPkLZ1gJJScmPKY5eIpt5Xqx6XsdxcieBoj(0bt5TD0vQ7pKeifAUuLY5AJXrwbMus5CcXNP8yaH8AkOnpDWuQWJHqWW8ac51uqB4q1lvPCU2yCKvGjLuoNq8zkp(MkkiP0WLpsoVlvPCU2yCKvGjLuoNq8zkpkjqS0JKcBih14svkNRnghzfysjLZjeFMYJjrMgwMMqqBwQs5CTX4iRatkPCoH4ZuEu2gdLKCU2wQwQs5CTX4iRatk1D7otJcdjz97P80bt5TD0vQ7pKq5h1cuXKo0go8zPRqqj1TDMMOOSBNV)mo8zPRqqj1TDMgNGk5zSaPOj9vHMIIYUD((Z4WNLUcbLu32zACcQKNX(l7257pJE1cuXKo0gogekHMRTcdTbnjkkk7257pJJbHsO5ARWqBqtICcQKNXcKIM0xfAkkk7257pJJbHsO5ARWqBqtICcQKNX(l7257ptuCshAdh(S0viOK62otJE1cuHSfIwAdNA6ixAIIYUD((Z4(t4zyzANJtqL8mwGpKOOSBNV)mU)eEgwM254eujpJ9x2TZ3Fg9lvPCU2yCKvGjL6UDNP9mLhLPZvs5CTvChBEYsfKc8zh7fjSNoykVTJUsD)Hek)ik6Xqiyyo8zPRqqj1TDMghQwumecgMljqS0JCOA1HqWWCjbILEKZMusDGQ87svkNRnghzfysPUB3zApt5rHPjiHo2lsyL3urbjpDWucHGH5mKK1VNchQEPkLZ1gJJScmPu3T7mTNP84BQOGKsdx(i58(0btHaziCt0qUW00GsINvuAf0giLLQuoxBmoYkWKsD3UZ0EMYJFj1yPHlj7fzpDWuEBhDL6(djbsrv1mCkHTbX4ZHevfSsvRLlvPCU2yCKvGjL6UDNP9mLhdDPhlnCjGqS5K4thmL32rxPU)qsGuO5svkNRnghzfysPUB3zApt5Xac51uqBE6GPuHhdHGH5beYRPG2WHQxQs5CTX4iRatk1D7ot7zkp(MkkiP0WLpsoVlvPCU2yCKvGjL6UDNP9mLhLeiw6rsHnKJA8PdMISBNV)mUKaXspskSHCuJC5Bs0qwbMKY5AlD)POcxW9JAbEBhDL6(djbsrvrX32rxPU)qsGuOPAz3oF)z8qx6XsdxcieBojYjOsEg7VM0xfvffFBhDL6(djuQQAz3oF)z8qx6XsdxcieBojYjOsEg7VM0xfvvl7257pJhqiVMcAdNGk5zS)AsFvuL(LQuoxBmoYkWKsD3UZ0EMYJmKK1VNYthmLkM0H2WHplDfckPUTZ0ul7257pJJbHsO5ARWqBqtICcQKNXcKIM0xfAQwGkKTq0sB4uth5stuu2TZ3Fg3Fcpdlt7CCcQKNXc8HOFPkLZ1gJJScmPu3T7mTNP8OmDUskNRTI7yZtwQGuGp7yViHTuLY5AJXrwbMuQ72DM2ZuEusGyPhjf2qoQXLQuoxBmoYkWKsD3UZ0EMYJjrMgwMMqqBE6GP82o6k19hscKsvxQs5CTX4iRatk1D7ot7zkpYqsw)EkpDWueOIjDOnC4ZsxHGsQB7mnrrz3oF)zC4ZsxHGsQB7mnobvYZybsrt6RcnPxTavmPdTHJbHsO5ARWqBqtIIIYUD((Z4yqOeAU2km0g0KiNGk5zSaPOj9vHMIIt6qB4WNLUcbLu32zA0RwGkKTq0sB4uth5stuu2TZ3Fg3Fcpdlt7CCcQKNXc8HOFPkLZ1gJJScmPu3T7mTNP8OSngkj5CTTuTuLY5AJXHp7yViHrrysUm0HpzPcsXZkYKnzOdFsy6GqkSA05kts0WHX9NWZWcBAIcfvvxHaeidHBIgYHplDfHiXFYruCshAdNCAVd2qSIqK4p5qVOiRgDUYKenCyC)j8mSWMMO8xvrXqiyyoQuthbtRu3FiHdvRUcpgcbdZdiKxtbTHdvRUIqiyyU)eEgwQHi1nd5q1lvPCU2yC4Zo2lsypt5rgsY63t5PdMIaYUD((Z4Pq00otR8rY5LtqL8m2Fv(ruu2TZ3FgxsGyPh5eujpJ9xLFOxTavmPdTHdFw6keusDBNPjkk7257pJdFw6keusDBNPXjOsEg7VSBNV)m6vlqft6qB4yqOeAU2km0g0KOOOSBNV)mogekHMRTcdTbnjYjOsEg7VSBNV)mrrwn6CLjjA4W4(t4zyHnnr5pLFOxTavqYZxqHOn807zCmOJnmrrsE(ckeTHNEpJF2)Q(ROijpFbfI2WtVNXplqnPxuKKNVGcrB4P3Z4q10RwGkKTq0sB4uth5stuuaz3oF)zC)j8mSmTZXjOsEglWhsuu2TZ3Fg3Fcpdlt7CCcQKNX(l7257pJE6ffdBgtn8P9ofcQKNXcuLFudFAVtHGk5zS))ikgcbdZLeiw6rouT6qiyyUKaXspYztkPoqv(DPkLZ1gJdF2XErc7zkpIbHsO5ARWqBqtIpDWueiecgMljqS0JCF)zQLD789NXLeiw6robvYZy)v5xrXqiyyUKaXspYztkP(pfAkkk7257pJNcrt7mTYhjNxobvYZy)v5x6vlqft6qB4WNLUcbLu32zAIIYUD((Z4WNLUcbLu32zACcQKNX(RYV0REsIgo85uWY0f)H)fm1SA05kts0WHX9NWZWcBAIsG)SuLY5AJXHp7yViH9mLh9NWZWcBAIYthmfHj5YqhY9SImztg6q1vecbdZfMMGe6yViHvEtffKWHQvlGavmPdTHljqS0JIIYUD((Z4scel9iNGk5zS)AsFvOj9QfOIjDOnCmiucnxBfgAdAsuuu2TZ3FghdcLqZ1wHH2GMe5eujpJ9xt6RYdlkk7257pJJbHsO5ARWqBqtICcQKNX(Rj9vPQQFBhDL6(dj)P8JO4KenC4ZPGLPl(dduWefz1OZvMKOHdJ7pHNHf20eL)u(ruSIjDOnCgsY63trTSBNV)mogekHMRTcdTbnjYjOsEg7VM0xfvPxTavmPdTHdFw6keusDBNPjkk7257pJdFw6keusDBNPXjOsEg7VM0xLhwuu2TZ3Fgh(S0viOK62otJtqL8m2FnPVkvv9B7ORu3Fi5pLFefRyshAdNHKS(9uul7257pJdFw6keusDBNPXjOsEg7VM0xfvPxuCshAd)TD0vsHOPHe1YUD((Z4VTJUskennKWjOsEglqnPVk0uumecgM)2o6kPq00qchQwumecgMljqS0JCOA1HqWWCjbILEKZMusDGQ8l9lvPCU2yC4Zo2lsypt5XbvQDjHveIe)jNNoykcuXKo0gUKaXspkkk7257pJljqS0JCcQKNX(Rj9vHM0RwGkM0H2WXGqj0CTvyOnOjrrrz3oF)zCmiucnxBfgAdAsKtqL8m2FnPVkcMOOSBNV)mogekHMRTcdTbnjYjOsEg7VM0xLhw9B7ORu3Fi5pLQkkojrdh(Ckyz6I)WafmrXkM0H2WzijRFpf1YUD((Z4yqOeAU2km0g0KiNGk5zS)AsFvuLE1cuXKo0go8zPRqqj1TDMMOOSBNV)mo8zPRqqj1TDMgNGk5zS)AsFvemrrz3oF)zC4ZsxHGsQB7mnobvYZy)1K(Q8WQFBhDL6(dj)PuvrXkM0H2WzijRFpf1YUD((Z4WNLUcbLu32zACcQKNX(Rj9vrv6ffN0H2WFBhDLuiAAirTSBNV)m(B7ORKcrtdjCcQKNXcut6RcnffdHGH5VTJUskennKWHQffdHGH5scel9ihQwDiemmxsGyPh5SjLuhOk)UuTGLQuoxBmUgAijNMWOitNRKY5AR4o28KLkif4Zo2lsypDWuEBhDL6(dju(ruuapgcbdZdiKxtbTHdvlk(2o6k19hsOuv6vhcbdZ9NWZWcbzTLMe5q1IIHqWW832rxjfIMgs4q1lvPCU2yCn0qsonH9mLhfMMGe6yViHvEtffK80btPccKHWnrd5EOHUWgY8fTui6efRyshAdh(S0viOK62ottDft6qB4yqOeAU2km0g0KOOyyZyQHpT3PqqL8mwGc2svkNRngxdnKKttypt5X3urbjLgU8rY59PdMcbYq4MOH85flkPVuNKuRnrrzleT0gUq0Mx6iQLD789NXt2lAL3056pobvYZy)vvLFxQs5CTX4AOHKCAc7zkp(LuJLgUKSxK90bt5TD0vQ7pKeifvvZWPe2geJphsuvWkvTwQwaz3oF)z8uiAANPv(i58YjOsEgtuu2TZ3FgxsGyPh5eujpJr)svkNRngxdnKKttypt5r)j8mSmTZ90bt5TD0vQ7pKeifvuxHhdHGH5beYRPG2WHQvlqft6qB4mKK1VNIOyiemmNHKS(9u4q10RwGki55lOq0gE69mog0XgMOijpFbfI2WtVNXp7pn)vuKKNVGcrB4P3Z4q10RUIjDOnC4ZsxHGsQB7mn1cuXKo0gogekHMRTcdTbnjkkg2mMA4t7DkeujpJfOGjkYQrNRmjrdhg3FcpdlSPjk)P8d9Qfq2TZ3FgpfIM2zALpsoVCcQKNXefLD789NXLeiw6robvYZy0VuLY5AJX1qdj50e2ZuEmGqEnf0MNoykv4XqiyyEaH8AkOnCOA1c82o6k19hs(trf1eidHBIgYNxSOKAhBi5GSsaH8AkOnIIVTJUsD)HK)uuL(LQuoxBmUgAijNMWEMYJFj1yPHlj7fzpDWue4TD0vQ7pKq5xrX32rxPU)qsGuuvTSBNV)mEOl9yPHlbeInNe5eujpJ9xt6RIQ0RwGki55lOq0gE69mog0XgMOijpFbfI2WtVNXp7VQ)kksYZxqHOn807zCOA6vlqft6qB4mKK1VNIOOSBNV)modjz97PWjOsEg7)pIIYwiAPnCQPJCPrVAbQyshAdhdcLqZ1wHH2GMeffLD789NXXGqj0CTvyOnOjrobvYZy)v5hrXjjA4WNtbltx8hgOGjkYQrNRmjrdhg3FcpdlSPjk)P8d9QfOIjDOnC4ZsxHGsQB7mnrrz3oF)zC4ZsxHGsQB7mnobvYZy)v5hrXWMXudFAVtHGk5zSafm6vlGSBNV)mEkenTZ0kFKCE5eujpJjkk7257pJljqS0JCcQKNXOFPkLZ1gJRHgsYPjSNP8OmDUskNRTI7yZtwQGuGp7yViH90bt5TD0vQ7pK8NcnvhcbdZLeiw6rouT6qiyyUKaXspYztkPoqv(DPkLZ1gJRHgsYPjSNP8yOl9yPHlbeInNeF6GPiBZdDdhdQgIOLZ1M632rxPU)qsGuO5svkNRngxdnKKttypt5Xac51uqBE6GPuHhdHGH5beYRPG2WHQxQs5CTX4AOHKCAc7zkp(MkkiP0WLpsoVlvPCU2yCn0qsonH9mLhdDPhlnCjGqS5K4thmL32rxPU)qsGuO5svkNRngxdnKKttypt5rz6CLuoxBf3XMNSubPaF2XErc7PdMIats0WH)IPBE51YjqkQ(ROyiemmpfIM2zALpsoVCOArXqiyyUKaXspYHQffdHGH5OsnDemTsD)Heoun9lvPCU2yCn0qsonH9mLhLTXqjjNRTNoykviBJHssoxBCOA1SA05kts0WHX9NWZWcBAIYFkQUuLY5AJX1qdj50e2ZuEusGyPhjf2qoQXNoykYUD((Z4scel9iPWgYrnYLVjrdzfyskNRT09NIkCb3pQf4TD0vQ7pKeifvffFBhDL6(djbsHMQLD789NXdDPhlnCjGqS5KiNGk5zS)AsFvuvu8TD0vQ7pKqPQQLD789NXdDPhlnCjGqS5KiNGk5zS)AsFvuvTSBNV)mEaH8AkOnCcQKNX(Rj9vrv6xQs5CTX4AOHKCAc7zkpktNRKY5AR4o28KLkif4Zo2lsylvPCU2yCn0qsonH9mLhLTXqjjNRTNoykviBJHssoxBCO6LQuoxBmUgAijNMWEMYJscel9iPWgYrnUuLY5AJX1qdj50e2ZuEmjY0WY0ecAZsvkNRngxdnKKttypt5rzBmusY5AlQlejSRTyWQ(RQQ(RQQ(Wr9VKyNPXI6cEc(ccb)Gd(bIgwWcQ8fxWPu3KzbWnzb0QHgsYPjmAxabfKqhb9lG1k4csOPvYb9lq(MMgY4lvc6z4cuLgwan2MqKmOFb0oPdTHhaAxW0lG2jDOn8aWrldDON2fiGQbrpFPsqpdxGQ0WcOX2eIKb9lGwcKHWnrd5bG2fm9cOLaziCt0qEa4OLHo0t7ceqLGONVujONHlGM0WcOX2eIKb9lGwcKHWnrd5bG2fm9cOLaziCt0qEa4OLHo0t7ceqLGONVujONHl4hAyb0yBcrYG(fq7Ko0gEaODbtVaAN0H2WdahTm0HEAxGa0mi65lvc6z4cEyAyb0yBcrYG(fqlbYq4MOH8aq7cMEb0sGmeUjAipaC0Yqh6PDbcOsq0ZxQe0ZWfi4OHfqJTjejd6xaTt6qB4bG2fm9cODshAdpaC0Yqh6PDbcqZGONVuTuj4j4lie8do4hiAyblOYxCbNsDtMfa3KfqRhHti3q7ciOGe6iOFbSwbxqcnTsoOFbY300qgFPsqpdxanPHfqJTjejd6xaTt6qB4bG2fm9cODshAdpaC0Yqh6PDbcOAq0ZxQwQe8e8fec(bh8denSGfu5lUGtPUjZcGBYcOTMGYwjmhAxabfKqhb9lG1k4csOPvYb9lq(MMgY4lvc6z4cEyAyb0yBcrYG(fqlRHCHN55bG2fm9cOL1qUWZ88aWrldDON2fiGkbrpFPsqpdxWdtdlGgBtisg0VaAznKl8mppa0UGPxaTSgYfEMNhaoAzOd90UGCwGGibXc6ceqLGONVuTuj4j4lie8do4hiAyblOYxCbNsDtMfa3KfqRSBNV)mgTlGGcsOJG(fWAfCbj00k5G(fiFttdz8Lkb9mCb0Kgwan2MqKmOFb0oPdTHhaAxW0lG2jDOn8aWrldDON2fKZceejiwqxGaQee98Lkb9mCbvLgwan2MqKmOFb0YAix4zEEaODbtVaAznKl8mppaC0Yqh6PDbcOsq0ZxQe0ZWfuvAyb0yBcrYG(fqlRHCHN55bG2fm9cOL1qUWZ88aWrldDON2fKZceejiwqxGaQee98Lkb9mCb)qdlGgBtisg0VaAN0H2WdaTly6fq7Ko0gEa4OLHo0t7ceqLGONVujONHlqLQsdlGgBtisg0VaAN0H2WdaTly6fq7Ko0gEa4OLHo0t7ceqLGONVujONHlq1hIgwan2MqKmOFb0oPdTHhaAxW0lG2jDOn8aWrldDON2fiqvdIE(sLGEgUavFiAyb0yBcrYG(fqlbYq4MOH8aq7cMEb0sGmeUjAipaC0Yqh6PDbcOAq0ZxQe0ZWfqtvPHfqJTjejd6xaTt6qB4bG2fm9cODshAdpaC0Yqh6PDbcOsq0ZxQe0ZWfqtAsdlGgBtisg0VaAN0H2WdaTly6fq7Ko0gEa4OLHo0t7ceqLGONVuTuj4j4lie8do4hiAyblOYxCbNsDtMfa3Kfql8zh7fjmAxabfKqhb9lG1k4csOPvYb9lq(MMgY4lvc6z4cuHgwan2MqKmOFb0oPdTHhaAxW0lG2jDOn8aWrldDON2fiGkbrpFPsqpdxGk0WcOX2eIKb9lGwcKHWnrd5bG2fm9cOLaziCt0qEa4OLHo0t7ceqLGONVujONHlqvAyb0yBcrYG(fq7Ko0gEaODbtVaAN0H2WdahTm0HEAxGaQge98Lkb9mCb0Kgwan2MqKmOFb0oPdTHhaAxW0lG2jDOn8aWrldDON2fiGkbrpFPsqpdxqvPHfqJTjejd6xaTt6qB4bG2fm9cODshAdpaC0Yqh6PDbc8WbrpFPsqpdxWp0WcOX2eIKb9lG2jDOn8aq7cMEb0oPdTHhaoAzOd90UabE4GONVuTuj4j4lie8do4hiAyblOYxCbNsDtMfa3KfqlYkWKskNtis7ciOGe6iOFbSwbxqcnTsoOFbY300qgFPsqpdxGQ0WcOX2eIKb9lG2jDOn8aq7cMEb0oPdTHhaoAzOd90Uabuji65lvc6z4c(Hgwan2MqKmOFb0oPdTHhaAxW0lG2jDOn8aWrldDON2fiGkbrpFPsqpdxWp0WcOX2eIKb9lGwcKHWnrd5bG2fm9cOLaziCt0qEa4OLHo0t7ceq1GONVujONHl4HPHfqJTjejd6xaTeidHBIgYdaTly6fqlbYq4MOH8aWrldDON2fiGkbrpFPsqpdxGGJgwan2MqKmOFb0sGmeUjAipa0UGPxaTeidHBIgYdahTm0HEAxGaQee98LQLkbpbFbHGFWb)ardlybv(Il4uQBYSa4MSaArwbMuQ72DMgTlGGcsOJG(fWAfCbj00k5G(fiFttdz8Lkb9mCbQqdlGgBtisg0VaAN0H2WdaTly6fq7Ko0gEa4OLHo0t7ceGMbrpFPsqpdxqvPHfqJTjejd6xaTeidHBIgYdaTly6fqlbYq4MOH8aWrldDON2fKZceejiwqxGaQee98Lkb9mCbQ8lnSaASnHizq)cODshAdpa0UGPxaTt6qB4bGJwg6qpTlqavcIE(sLGEgUavQknSaASnHizq)cODshAdpa0UGPxaTt6qB4bGJwg6qpTlqaAge98LQLQhSsDtg0Vab3cs5CTTa3XggFPkQ7o2WIvg11qdj50ewSYyWQeRmQJwg6qFS6OUKCdsUmQ)2o6k19hswaLf8ZcefxGalWJHqWW8ac51uqB4q1lquCbVTJUsD)HKfqzbvDb0Va1liecgM7pHNHfcYAlnjYHQxGO4ccHGH5VTJUskennKWHQJ6PCU2I6Y05kPCU2kUJnrD3XMILkyuh(SJ9IewCIbRASYOoAzOd9XQJ6sYni5YOEflGaziCt0qUhAOlSHmFrlfIooAzOd9lquCbvSGjDOnC4ZsxHGsQB7mnoAzOd9lq9cQybt6qB4yqOeAU2km0g0KihTm0H(fikUGWMXwG6faFAVtHGk5zSfe4ceSOEkNRTOUW0eKqh7fjSYBQOGK4edMMXkJ6OLHo0hRoQlj3GKlJ6eidHBIgYNxSOK(sDssT24OLHo0VarXfiBHOL2WfI28shzbQxGSBNV)mEYErR8Mox)XjOsEgBb)xGQQ8BupLZ1wu)nvuqsPHlFKCEJtm4QgRmQJwg6qFS6OUKCdsUmQ)2o6k19hswqGuwGQlq9cy4ucBdIXNdjQkyLQwlxG6fiWcKD789NXtHOPDMw5JKZlNGk5zSfikUaz3oF)zCjbILEKtqL8m2cOpQNY5AlQ)LuJLgUKSxKfNyW)eRmQJwg6qFS6OUKCdsUmQ)2o6k19hswqGuwGklq9cQybEmecgMhqiVMcAdhQEbQxGalOIfmPdTHZqsw)EkC0Yqh6xGO4ccHGH5mKK1VNchQEb0Va1lqGfuXci55lOq0gE69mog0Xg2cefxajpFbfI2WtVNXpBb)xan)DbIIlGKNVGcrB4P3Z4q1lG(fOEbvSGjDOnC4ZsxHGsQB7mnoAzOd9lq9ceybvSGjDOnCmiucnxBfgAdAsKJwg6q)cefxqyZylq9cGpT3PqqL8m2ccCbc2cefxaRgDUYKenCyC)j8mSWMMOSG)uwWplG(fOEbcSaz3oF)z8uiAANPv(i58YjOsEgBbIIlq2TZ3FgxsGyPh5eujpJTa6J6PCU2I6(t4zyzANloXGF4yLrD0Yqh6Jvh1LKBqYLr9kwGhdHGH5beYRPG2WHQxG6fiWcEBhDL6(djl4pLfOYcuVacKHWnrd5ZlwusTJnKCqwjGqEnf0goAzOd9lquCbVTJUsD)HKf8NYcuDb0h1t5CTf1diKxtbTjoXGfCXkJ6OLHo0hRoQlj3GKlJ6cSG32rxPU)qYcOSGFxGO4cEBhDL6(djliqklq1fOEbYUD((Z4HU0JLgUeqi2CsKtqL8m2c(VanPFbvzbQUa6xG6fiWcQybK88fuiAdp9Eghd6ydBbIIlGKNVGcrB4P3Z4NTG)lq1FxGO4ci55lOq0gE69mou9cOFbQxGalOIfmPdTHZqsw)EkC0Yqh6xGO4cKD789NXzijRFpfobvYZyl4)c(zbIIlq2crlTHtnDKlTfq)cuVabwqflyshAdhdcLqZ1wHH2GMe5OLHo0VarXfi7257pJJbHsO5ARWqBqtICcQKNXwW)fOYplquCbts0WHpNcwMU4pCbbUabBbIIlGvJoxzsIgomU)eEgwyttuwWFkl4Nfq)cuVabwqflyshAdh(S0viOK62otJJwg6q)cefxGSBNV)mo8zPRqqj1TDMgNGk5zSf8FbQ8ZcefxqyZylq9cGpT3PqqL8m2ccCbc2cOFbQxGalq2TZ3FgpfIM2zALpsoVCcQKNXwGO4cKD789NXLeiw6robvYZylG(OEkNRTO(xsnwA4sYErwCIblyXkJ6OLHo0hRoQlj3GKlJ6VTJUsD)HKf8NYcO5cuVGqiyyUKaXspYHQxG6fecbdZLeiw6roBsj1liWfOYVr9uoxBrDz6CLuoxBf3XMOU7ytXsfmQdF2XErcloXGFOyLrD0Yqh6Jvh1LKBqYLrDzBEOB4yq1qeTCU2wG6f82o6k19hswqGuwanJ6PCU2I6HU0JLgUeqi2CsmoXGv53yLrD0Yqh6Jvh1LKBqYLr9kwGhdHGH5beYRPG2WHQJ6PCU2I6beYRPG2eNyWQOsSYOEkNRTO(BQOGKsdx(i58g1rldDOpwDCIbRIQXkJ6OLHo0hRoQlj3GKlJ6VTJUsD)HKfeiLfqZOEkNRTOEOl9yPHlbeInNeJtmyvOzSYOoAzOd9XQJ6sYni5YOUalysIgo8xmDZlVwoliqklq1FxGO4ccHGH5Pq00otR8rY5LdvVarXfecbdZLeiw6rou9cefxqiemmhvQPJGPvQ7pKWHQxa9r9uoxBrDz6CLuoxBf3XMOU7ytXsfmQdF2XErcloXGvPQXkJ6OLHo0hRoQlj3GKlJ6vSazBmusY5AJdvVa1lGvJoxzsIgomU)eEgwyttuwWFklq1OEkNRTOUSngkj5CTfNyWQ8tSYOoAzOd9XQJ6sYni5YOUSBNV)mUKaXspskSHCuJC5Bs0qwbMKY5AlDl4pLfOcxW9ZcuVabwWB7ORu3FizbbszbQUarXf82o6k19hswqGuwanxG6fi7257pJh6spwA4saHyZjrobvYZyl4)c0K(fuLfO6cefxWB7ORu3FizbuwqvxG6fi7257pJh6spwA4saHyZjrobvYZyl4)c0K(fuLfO6cuVaz3oF)z8ac51uqB4eujpJTG)lqt6xqvwGQlG(OEkNRTOUKaXspskSHCuJXjgSkpCSYOoAzOd9XQJ6PCU2I6Y05kPCU2kUJnrD3XMILkyuh(SJ9IewCIbRIGlwzuhTm0H(y1rDj5gKCzuVIfiBJHssoxBCO6OEkNRTOUSngkj5CTfNyWQiyXkJ6PCU2I6scel9iPWgYrng1rldDOpwDCIbRYdfRmQNY5AlQNezAyzAcbTjQJwg6qFS64edw1FJvg1t5CTf1LTXqjjNRTOoAzOd9XQJtCI6EeoHCtSYyWQeRmQNY5AlQtWqiQXOoAzOd9XQJtmyvJvg1rldDOpwDupLZ1wuxMoxjLZ1wXDSjQ7o2uSubJ6YUD((ZyXjgmnJvg1rldDOpwDuxsUbjxg1fybvSasE(ckeTHNEpJJbDSHTarXfqYZxqHOn807zCO6fikUasE(ckeTHNEpJF2ccCbp0cefxajpFbfI2WtVNXpBb)xan)Db0Va1lqGfmPdTHJbHsO5ARWqBqtIC0Yqh6xG6fi7257pJJbHsO5ARWqBqtICcQKNXwqGl4HwG6fWQrNRmjrdhg3FcpdlSPjkliWf8ZcefxWKo0go8zPRqqj1TDMghTm0H(fOEbYUD((Z4WNLUcbLu32zACcQKNXwqGl4Hwa9lq9cMKOHdFofSmDXF4c(VablQNY5AlQltNRKY5AR4o2e1DhBkwQGrDKvGjL6UDNPfNyWvnwzuhTm0H(y1rDj5gKCzu3JHqWWCmiucnxBfgAdAsKdvVarXf4Xqiyyo8zPRqqj1TDMghQoQZgYjNyWQe1t5CTf1LPZvs5CTvChBI6UJnflvWOoYkWKskNtigNyW)eRmQJwg6qFS6OEkNRTOUmDUskNRTI7ytu3DSPyPcg11qdj50ewCItuVMGYwjmNyLXGvjwzupLZ1wuVUNRTOoAzOd9XQJtmyvJvg1t5CTf1dDiJDMwPHlmiffKe1rldDOpwDCIbtZyLr9uoxBr9qhYyNPvA4scnqkwuhTm0H(y1XjgCvJvg1t5CTf1dDiJDMwPHlFNnijQJwg6qFS64ed(NyLr9uoxBr9qhYyNPvA4cRMCMwuhTm0H(y1Xjg8dhRmQJwg6qFS6OUKCdsUmQZAix4zEEneBGCybjq1Z1ghTm0H(fikUawd5cpZZf2UCohwyTtiAdhTm0H(OEkNRTOoSdzVsscpXjgSGlwzuhTm0H(y1rDj5gKCzuFshAdh(S0viOK62otJJwg6q)cuVGjDOnCgsY63tHJwg6qFupLZ1wupjY0WY0ecAtCIblyXkJ6PCU2I6S3dD(sdxeIMgMMeJ6OLHo0hRooXjQl7257pJfRmgSkXkJ6OLHo0hRoQlj3GKlJ6HqWW8uiAANPv(i58YHQxGO4ccHGH5scel9ihQEbQxqiemmxsGyPh5SjLuVaklqLFxGO4ccBgBbQxa8P9ofcQKNXwqGlq1FI6PCU2I619CTfNyWQgRmQJwg6qFS6OUKCdsUmQZQrNRmjrdhg3DAVdReqiVMcAZc(tzbQUarXfuXci55lOq0gE69mog0Xg2cefxajpFbfI2WtVNXpBb)xGG7NfikUasE(ckeTHNEpJdvh1t5CTf1DN27WkbeYRPG2eNyW0mwzuhTm0H(y1rDj5gKCzuxGfecbdZtHOPDMw5JKZlhQEbIIliecgMljqS0JCO6fOEbHqWWCjbILEKZMus9cOSav(Db0Va1lOIfmPdTHJbHsO5ARWqBqtIC0Yqh6J6PCU2I6WhbdDD7Jtm4QgRmQJwg6qFS6OUKCdsUmQZAix4zEEneBGCybjq1Z1ghTm0H(fikUawd5cpZZf2UCohwyTtiAdhTm0H(O(zdsiq1t5GJ6SgYfEMNlSD5CoSWANq0MO(zdsiq1t5uuq)Ldg1vjQNY5AlQd7q2RKKWtu)SbjeO6PO56W0f1vjoXG)jwzuhTm0H(y1rDj5gKCzuxGfuXcM0H2WXGqj0CTvyOnOjroAzOd9lquCbYUD((Z4yqOeAU2km0g0KiNGk5zSfe4c(r1fq)cuVa4t7DkeujpJTG)lqLFI6PCU2I6S3dD(sdxeIMgMMeJtm4howzupLZ1wup0Hm2zALgUWGuuqsuhTm0H(y1XjgSGlwzupLZ1wup0Hm2zALgUKqdKIf1rldDOpwDCIblyXkJ6PCU2I6HoKXotR0WLVZgKe1rldDOpwDCIb)qXkJ6PCU2I6HoKXotR0Wfwn5mTOoAzOd9XQJtmyv(nwzuhTm0H(y1r9uoxBr9Zysc0KHoSiiHsBGukEu4jXOUKCdsUmQhcbdZtHOPDMw5JKZlhQEbIIliecgMljqS0JCO6fOEbHqWWCjbILEKZMus9cOSav(DbIIliSzSfOEbWN27uiOsEgBbbUaA(Bu3sfmQFgtsGMm0HfbjuAdKsXJcpjgNyWQOsSYOoAzOd9XQJ6PCU2I6TqK89IoLZ0k19hskscDSjDrDj5gKCzupecgMNcrt7mTYhjNxou9cefxqiemmxsGyPh5q1lq9ccHGH5scel9iNnPK6fqzbQ87cefxqyZylq9cGpT3PqqL8m2ccCbQ8tu3sfmQ3crY3l6uotRu3FiPij0XM0fNyWQOASYOoAzOd9XQJ6PCU2I6(KqTs3wXJsQlcBskVHUOUKCdsUmQhcbdZtHOPDMw5JKZlhQEbIIliecgMljqS0JCO6fOEbHqWWCjbILEKZMus9cOSav(DbIIliSzSfOEbWN27uiOsEgBbbUav)nQBPcg19jHALUTIhLuxe2KuEdDXjgSk0mwzuhTm0H(y1r9uoxBrDLuMHeSWErCkkqStg1LKBqYLr9qiyyEkenTZ0kFKCE5q1lquCbHqWWCjbILEKdvVa1liecgMljqS0JC2KsQxaLfOYVlquCbHnJTa1la(0ENcbvYZyliWfO6VrDlvWOUskZqcwyVioffi2jJtmyvQASYOoAzOd9XQJ6PCU2I6WjKBORiBiBqIcMmicg1LKBqYLr9kwWKo0gUKaXspYrldDOFbIIliecgMljqS0JCO6fikUGWMXwG6faFAVtHGk5zSfe4cO5VrDlvWOoCc5g6kYgYgKOGjdIGXjgSk)eRmQJwg6qFS6OULkyu3tW0dFeSiezm0f1t5CTf19em9WhblcrgdDXjgSkpCSYOoAzOd9XQJ6wQGrDg1qoQrcR8DMwupLZ1wuNrnKJAKWkFNPfNyWQi4Ivg1rldDOpwDu3sfmQRroLIS9yqr9uoxBrDnYPuKThdkoXGvrWIvg1rldDOpwDu3sfmQRGknHUsdxQt2uyNXI6PCU2I6kOstOR0WL6Knf2zS4edwLhkwzuhTm0H(y1rDlvWOoRojyrbZP82n1r9uoxBrDwDsWIcMt5TBQJtmyv)nwzuhTm0H(y1rDlvWOolDctn0xGHyxBLuP2DWhsI6PCU2I6S0jm1qFbgIDTvsLA3bFijoXGvvLyLrD0Yqh6Jvh1TubJ6AxAtPjwQG2KUsnMexupLZ1wux7sBknXsf0M0vQXK4ItmyvvnwzuhTm0H(y1rDlvWO(3zEMmjLVxCytByupLZ1wu)7mptMKY3loSPnmoXGvLMXkJ6OLHo0hRoQBPcg1zYKWknCbMKdsS0vyd5GXOEkNRTOotMewPHlWKCqILUcBihmgNyWQw1yLrD0Yqh6Jvh1TubJ6Y38mwPHl(w5SCU2I6PCU2I6Y38mwPHl(w5SCU2Itmyv)jwzuhTm0H(y1rDlvWOoMK5nKGj1iHvoL6uor9uoxBrDmjZBibtQrcRCk1PCItmyvF4yLrD0Yqh6Jvh1t5CTf1FXKmLgUmVyH9LeLOUKCdsUmQxXccHGH5Pq00otR8rY5LdvVa1liecgMljqS0JCO6OULkyu)ftYuA4Y8If2xsuItmyvfCXkJ6OLHo0hRoQNY5AlQR5s)LttyLW0RHrDj5gKCzupecgMNcrt7mTYhjNxou9cefxqiemmxsGyPh5q1lq9ccHGH5scel9iNnPK6f8NYcu53fikUaz3oF)z8uiAANPv(i58YjOsEgBb)xqv)zbIIlq2TZ3FgxsGyPh5eujpJTG)lOQ)e1TubJ6AU0F50ewjm9AyCIbRQGfRmQJwg6qFS6OUKCdsUmQhcbdZtHOPDMw5JKZlhQEbIIliecgMljqS0JCO6fOEbHqWWCjbILEKZMus9c(tzbQ8BupLZ1wuhIHLBqfwCIbR6dfRmQJwg6qFS6OUKCdsUmQlWcEBhDL6(djl4pLfu1fOEbZPGliWf8ZcefxWB7ORu3Fizb)PSaAUa1lqGfmNcUG)l4NfikUacKHWnrd5ZlwusTJnKCqwjGqEnf0goAzOd9lG(fikUG32rxPU)qYc(tzbQUa1lGaziCt0qUW00GsINvuAf0gifoAzOd9lq9cM0H2WHplDfckPUTZ04OLHo0VarXfmPdTH)2o6kPq00qchTm0H(fOEbYUD((Z4VTJUskennKWjOsEgBbuwWVlG(fOEbcSGkwWKo0godjz97PWrldDOFbIIlOIfmPdTHdFw6keusDBNPXrldDOFbIIlq2TZ3FgNHKS(9u4eujpJTG)l43fqFupLZ1wupfIM2zALpsoVXjgmn)nwzuhTm0H(y1rDj5gKCzu)TD0vQ7pKSG)uwqvxG6fmNcUGaxWplquCbVTJUsD)HKf8NYcO5cuVG5uWf8Fb)e1t5CTf1Leiw6X4edMMQeRmQNY5AlQNSx0kVPZ1FrD0Yqh6JvhNyW0u1yLrD0Yqh6Jvh1LKBqYLr95uWY0L3ATfqzb)Ua1l4TD0vQ7pKSGaPSavxG6fiWccHGH5Pq00otR8rY5LdvVarXfmPdTHljqS0JC0Yqh6xG6fiWcKD789NXLeiw6robvYZylGYc(DbIIliecgMljqS0JCO6fq)cefxqyZylq9cGpT3PqqL8m2ccCbQ(7cOpQNY5AlQ)2o6kPq00qsCIbttAgRmQJwg6qFS6OUKCdsUmQlWcEBhDL6(djl4pLfu1fOEbZPGliWfiylquCbVTJUsD)HKf8NYcO5cuVabwWCk4c(tzbc2cefxaRgDUYKenCyC)j8mSWMMOSG)uwGQlq9cKTq0sB4uth5sBb0Va6xG6fi7257pJNcrt7mTYhjNxobvYZyl4)c0K(fOEbZPGLPlV1AlGYc(DbQxGalOIfmPdTHZqsw)EkC0Yqh6xGO4ccHGH5mKK1VNchQEb0Va1lqGfuXci55lOq0gE69mog0Xg2cefxajpFbfI2WtVNXHQxGO4ci55lOq0gE69m(zl4)cQ6VlG(fOEbcSGkwqiemmpfIM2zALpsoVCO6fikUG32rxPU)qYcOSGFwGO4cKD789NXFtffKuA4YhjNxobvYZylquCbSA05kts0WHX9NWZWcBAIYc(tzbQUa1lq2crlTHtnDKlTfqFupLZ1wuh(S0viOK62otloXjQdF2XErclwzmyvIvg1rldDOpwDuVRJ6mCI6PCU2I6ctYLHomQlmDqyuNvJoxzsIgomU)eEgwyttuwaLfO6cuVGkwGalGaziCt0qo8zPRiej(toC0Yqh6xGO4cM0H2WjN27GneRiej(toC0Yqh6xa9lquCbSA05kts0WHX9NWZWcBAIYc(VavxGO4ccHGH5OsnDemTsD)Heou9cuVGkwGhdHGH5beYRPG2WHQxG6fuXccHGH5(t4zyPgIu3mKdvh1fMKILkyu3ZkYKnzOdJtmyvJvg1rldDOpwDuxsUbjxg1fybYUD((Z4Pq00otR8rY5LtqL8m2c(Vav(zbIIlq2TZ3FgxsGyPh5eujpJTG)lqLFwa9lq9ceybvSGjDOnC4ZsxHGsQB7mnoAzOd9lquCbYUD((Z4WNLUcbLu32zACcQKNXwW)fKY5ARi7257pBb0Va1lqGfuXcM0H2WXGqj0CTvyOnOjroAzOd9lquCbYUD((Z4yqOeAU2km0g0KiNGk5zSf8FbPCU2kYUD((ZwGO4cy1OZvMKOHdJ7pHNHf20eLf8NYc(zb0Va1lqGfuXci55lOq0gE69mog0Xg2cefxajpFbfI2WtVNXpBb)xqv)DbIIlGKNVGcrB4P3Z4NTGaxGM0VarXfqYZxqHOn807zCO6fq)cuVabwqflq2crlTHtnDKlTfikUabwGSBNV)mU)eEgwM254eujpJTGaxWdTarXfi7257pJ7pHNHLPDoobvYZyl4)cs5CTvKD789NTa6xa9lquCbHnJTa1la(0ENcbvYZyliWfOYplq9cGpT3PqqL8m2c(VGFwGO4ccHGH5scel9ihQEbQxqiemmxsGyPh5SjLuVGaxGk)g1t5CTf1zijRFpL4edMMXkJ6OLHo0hRoQlj3GKlJ6cSGqiyyUKaXspY99NTa1lq2TZ3FgxsGyPh5eujpJTG)lqLFxGO4ccHGH5scel9iNnPK6f8NYcO5cefxGSBNV)mEkenTZ0kFKCE5eujpJTG)lqLFxa9lq9ceybvSGjDOnC4ZsxHGsQB7mnoAzOd9lquCbYUD((Z4WNLUcbLu32zACcQKNXwW)fOYVlG(fOEbts0WHpNcwMU4pCb)xGGTa1lGvJoxzsIgomU)eEgwyttuwqGl4NOEkNRTOogekHMRTcdTbnjgNyWvnwzuhTm0H(y1rDj5gKCzuxysUm0HCpRit2KHoCbQxqfliecgMlmnbj0XErcR8MkkiHdvVa1lqGfiWcQybt6qB4scel9ihTm0H(fikUaz3oF)zCjbILEKtqL8m2c(VanPFbvzb0Cb0Va1lqGfuXcM0H2WXGqj0CTvyOnOjroAzOd9lquCbYUD((Z4yqOeAU2km0g0KiNGk5zSf8FbAs)cQYcE4fikUaz3oF)zCmiucnxBfgAdAsKtqL8m2c(VanPFbvzbvDbQxWB7ORu3Fizb)PSGFwGO4cMKOHdFofSmDXF4ccCbc2cefxaRgDUYKenCyC)j8mSWMMOSG)uwWplquCbvSGjDOnCgsY63tHJwg6q)cuVaz3oF)zCmiucnxBfgAdAsKtqL8m2c(VanPFbvzbQUa6xG6fiWcQybt6qB4WNLUcbLu32zAC0Yqh6xGO4cKD789NXHplDfckPUTZ04eujpJTG)lqt6xqvwWdVarXfi7257pJdFw6keusDBNPXjOsEgBb)xGM0VGQSGQUa1l4TD0vQ7pKSG)uwWplquCbvSGjDOnCgsY63tHJwg6q)cuVaz3oF)zC4ZsxHGsQB7mnobvYZyl4)c0K(fuLfO6cOFbIIlyshAd)TD0vsHOPHeoAzOd9lq9cKD789NXFBhDLuiAAiHtqL8m2ccCbAs)cQYcO5cefxqiemm)TD0vsHOPHeou9cefxqiemmxsGyPh5q1lq9ccHGH5scel9iNnPK6fe4cu53fqFupLZ1wu3FcpdlSPjkXjg8pXkJ6OLHo0hRoQlj3GKlJ6cSGkwWKo0gUKaXspYrldDOFbIIlq2TZ3FgxsGyPh5eujpJTG)lqt6xqvwanxa9lq9ceybvSGjDOnCmiucnxBfgAdAsKJwg6q)cefxGSBNV)mogekHMRTcdTbnjYjOsEgBb)xGM0VGQSabBbIIlq2TZ3FghdcLqZ1wHH2GMe5eujpJTG)lqt6xqvwWdVa1l4TD0vQ7pKSG)uwqvxGO4cMKOHdFofSmDXF4ccCbc2cefxqflyshAdNHKS(9u4OLHo0Va1lq2TZ3FghdcLqZ1wHH2GMe5eujpJTG)lqt6xqvwGQlG(fOEbcSGkwWKo0go8zPRqqj1TDMghTm0H(fikUaz3oF)zC4ZsxHGsQB7mnobvYZyl4)c0K(fuLfiylquCbYUD((Z4WNLUcbLu32zACcQKNXwW)fOj9lOkl4HxG6f82o6k19hswWFklOQlquCbvSGjDOnCgsY63tHJwg6q)cuVaz3oF)zC4ZsxHGsQB7mnobvYZyl4)c0K(fuLfO6cOFbIIlyshAd)TD0vsHOPHeoAzOd9lq9cKD789NXFBhDLuiAAiHtqL8m2ccCbAs)cQYcO5cefxqiemm)TD0vsHOPHeou9cefxqiemmxsGyPh5q1lq9ccHGH5scel9iNnPK6fe4cu53OEkNRTO(Gk1UKWkcrI)KtCItuhzfysjLZjeJvgdwLyLr9uoxBrD4JGHUU9rD0Yqh6JvhNyWQgRmQJwg6qFS6OUKCdsUmQ)2o6k19hswaLf8ZcefxGhdHGH5beYRPG2WHQxGO4c8yiemmh(S0viOK62otJdvVa1lqGf4Xqiyyo8zPRqqj1TDMgNGk5zSfe4c0KEUsg0cefxaRgDUYKenCyC)j8mSWMMOSG)uwGQlq9cQybt6qB4yqOeAU2km0g0KihTm0H(fq)cefxGhdHGH5yqOeAU2km0g0KihQEbQxGhdHGH5yqOeAU2km0g0KiNGk5zSfe4c0KEUsguupLZ1wuxMoxjLZ1wXDSjQ7o2uSubJ6WNDSxKWItmyAgRmQNY5AlQ7pHNHLPDUOoAzOd9XQJtm4QgRmQNY5AlQlmnbj0XErcR8MkkijQJwg6qFS64ed(NyLrD0Yqh6Jvh1LKBqYLr932rxPU)qYccKYcuDbQxGalWJHqWWC4ZsxHGsQB7mnou9cuVapgcbdZHplDfckPUTZ04eujpJTGaxGM0VGQSavxG6fuXciqgc3enK7pHNHfcYAlnjYrldDOFbIIlWJHqWWCmiucnxBfgAdAsKdvVa1lWJHqWWCmiucnxBfgAdAsKtqL8m2ccCbAs)cefxaRgDUYKenCyC)j8mSWMMOSG)uwWplq9ciqgc3enK7pHNHfcYAlnjYrldDOFbQxWKo0gogekHMRTcdTbnjYrldDOFb0h1t5CTf1)sQXsdxs2lYItm4howzuhTm0H(y1rDj5gKCzux2Mh6gogunerlNRTfOEbcSGkwabYq4MOHC)j8mSqqwBPjroAzOd9lq9cEBhDL6(djliqklGMlquCbVTJUsD)HKfeiLfO6cOpQNY5AlQh6spwA4saHyZjX4edwWfRmQJwg6qFS6OUKCdsUmQxXc8yiemmpGqEnf0gou9cuVabwWB7ORu3Fizb)PSavwG6fqGmeUjAiFEXIsQDSHKdYkbeYRPG2WrldDOFbIIl4TD0vQ7pKSG)uwGQlG(OEkNRTOEaH8AkOnXjgSGfRmQJwg6qFS6OEkNRTOUmDUskNRTI7ytu3DSPyPcg1Hp7yViHfNyWpuSYOoAzOd9XQJ6sYni5YO(B7ORu3FizbbszbQg1t5CTf1)sQXsdxs2lYItmyv(nwzuhTm0H(y1rDj5gKCzu)TD0vQ7pKSGaPSaAg1t5CTf1dDPhlnCjGqS5KyCIbRIkXkJ6OLHo0hRoQlj3GKlJ6vSapgcbdZdiKxtbTHdvh1t5CTf1diKxtbTjoXGvr1yLr9uoxBr93urbjLgU8rY5nQJwg6qFS64edwfAgRmQNY5AlQljqS0JKcBih1yuhTm0H(y1XjgSkvnwzupLZ1wupjY0WY0ecAtuhTm0H(y1XjgSk)eRmQNY5AlQlBJHssoxBrD0Yqh6JvhN4e1rwbMuQ72DMwSYyWQeRmQJwg6qFS6OUKCdsUmQ)2o6k19hswaLf8ZcuVabwqflyshAdh(S0viOK62otJJwg6q)cefxGSBNV)mo8zPRqqj1TDMgNGk5zSfeiLfOj9lOklGMlquCbYUD((Z4WNLUcbLu32zACcQKNXwW)fKY5ARi7257pBb0Va1lqGfuXcM0H2WXGqj0CTvyOnOjroAzOd9lquCbYUD((Z4yqOeAU2km0g0KiNGk5zSfeiLfOj9lOklGMlquCbYUD((Z4yqOeAU2km0g0KiNGk5zSf8FbPCU2kYUD((ZwGO4cM0H2WHplDfckPUTZ04OLHo0Va6xG6fiWcQybYwiAPnCQPJCPTarXfi7257pJ7pHNHLPDoobvYZyliWf8qlquCbYUD((Z4(t4zyzANJtqL8m2c(VGuoxBfz3oF)zlG(OEkNRTOodjz97PeNyWQgRmQJwg6qFS6OUKCdsUmQ)2o6k19hswaLf8ZcefxGhdHGH5WNLUcbLu32zACO6fikUGqiyyUKaXspYHQxG6fecbdZLeiw6roBsj1liWfOYVr9uoxBrDz6CLuoxBf3XMOU7ytXsfmQdF2XErcloXGPzSYOoAzOd9XQJ6sYni5YOEiemmNHKS(9u4q1r9uoxBrDHPjiHo2lsyL3urbjXjgCvJvg1rldDOpwDuxsUbjxg1jqgc3enKlmnnOK4zfLwbTbsHJwg6qFupLZ1wu)nvuqsPHlFKCEJtm4FIvg1rldDOpwDuxsUbjxg1FBhDL6(djliqklq1fOEbmCkHTbX4ZHevfSsvRLr9uoxBr9VKAS0WLK9IS4ed(HJvg1rldDOpwDuxsUbjxg1FBhDL6(djliqklGMr9uoxBr9qx6XsdxcieBojgNyWcUyLrD0Yqh6Jvh1LKBqYLr9kwGhdHGH5beYRPG2WHQJ6PCU2I6beYRPG2eNyWcwSYOEkNRTO(BQOGKsdx(i58g1rldDOpwDCIb)qXkJ6OLHo0hRoQlj3GKlJ6YUD((Z4scel9iPWgYrnYLVjrdzfyskNRT0TG)uwGkCb3plq9ceybVTJUsD)HKfeiLfO6cefxWB7ORu3Fizbbszb0CbQxGSBNV)mEOl9yPHlbeInNe5eujpJTG)lqt6xqvwGQlquCbVTJUsD)HKfqzbvDbQxGSBNV)mEOl9yPHlbeInNe5eujpJTG)lqt6xqvwGQlq9cKD789NXdiKxtbTHtqL8m2c(VanPFbvzbQUa6J6PCU2I6scel9iPWgYrngNyWQ8BSYOoAzOd9XQJ6sYni5YOEflyshAdh(S0viOK62otJJwg6q)cuVaz3oF)zCmiucnxBfgAdAsKtqL8m2ccKYc0K(fuLfqZfOEbcSGkwGSfIwAdNA6ixAlquCbYUD((Z4(t4zyzANJtqL8m2ccCbp0cOpQNY5AlQZqsw)EkXjgSkQeRmQJwg6qFS6OEkNRTOUmDUskNRTI7ytu3DSPyPcg1Hp7yViHfNyWQOASYOEkNRTOUKaXspskSHCuJrD0Yqh6JvhNyWQqZyLrD0Yqh6Jvh1LKBqYLr932rxPU)qYccKYcQAupLZ1wupjY0WY0ecAtCIbRsvJvg1rldDOpwDuxsUbjxg1fybvSGjDOnC4ZsxHGsQB7mnoAzOd9lquCbYUD((Z4WNLUcbLu32zACcQKNXwqGuwGM0VGQSaAUa6xG6fiWcQybt6qB4yqOeAU2km0g0KihTm0H(fikUaz3oF)zCmiucnxBfgAdAsKtqL8m2ccKYc0K(fuLfqZfikUGjDOnC4ZsxHGsQB7mnoAzOd9lG(fOEbcSGkwGSfIwAdNA6ixAlquCbYUD((Z4(t4zyzANJtqL8m2ccCbp0cOpQNY5AlQZqsw)EkXjgSk)eRmQNY5AlQlBJHssoxBrD0Yqh6JvhN4eNOEcnVnjQRFk0yCItmca]] )


end
