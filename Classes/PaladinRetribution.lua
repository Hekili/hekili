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


    spec:RegisterPack( "Retribution", 20220212, [[dG0b(bqibQhHKkztKsFcPYOiuDkcLvjj0RuvLzPQOBHKkvTlu9lvLAyQk5yivTmsrpdjLPjj4AQkSnvvfFJuqgNaW5qsfRtvv18ei3dj2NQkhuauwOKupejvDrKuPSrKuPYhfaPtQQQKvIKmtsb2PKOFkaQmubqvlvvvPEkPAQss(QaiglPq7vI)k0GbDyrlwqpMOjtvxgAZa(mjgnqoTkRwa61ifZMk3MK2nLFRy4sQJtkOwoINJY0L66QY2jKVduJxaDEKsZNG9R0f6lvv09zJLk18ln18lnPxtUM0)1xFfaf9M2ASOxNsAsfSOBPkw0)3ytUWxFJv0RtADt6lvv0zZJiXIErp8DU(FzLWIUpBSuPMFPPMFPj9AY18lQ91hAOIoRgLLk1qFv0bDEpALWIUhzYI()gBYf(6BSfgGpDP)SLkQ7WqYlj0Uq618ZfQ5xAQ5s1sf1dknfK9)LkQ7x4)YAuHKnUqdbVWAYnKRPDHSA31leGmQlu)uPEErVMmaNdl6uxuxl8FJn5cF9n2cdWNU0F2sf1f11cPUddjVKq7cPxZpxOMFPPMlvlvuxuxlK6bLMcY()sf1f11cPUFH)lRrfs24cne8cRj3qUM2fYQDxVqaYOUq9tL65lvlvPSVXy8Ackh1WSPup9n2svk7BmgVMGYrnm7)O8DOdzSZuIdqK9uvrYsvk7BmgVMGYrnm7)O8DOdzSZuIdqmF9t1wQszFJX41euoQHz)hLVdDiJDMsCaIGpRrYsvk7BmgVMGYrnm7)O8DOdzSZuIdqKvtotzPkL9ngJxtq5OgM9Fu(gWHmqssc0FEauyZZfEMNx)y9ZHrK8Q7Bmbb28CHN55Igx2NdJSXjcTEPkL9ngJxtq5OgM9Fu(ojY0WypecA9NhaLoDO1CGZsxKGsAg7mfoAzOd9A70HwZzijRbDQC0Yqh6xQwQw4sf1f11cPUfikFn6xikcj0UW(uXf2GWfMYEil8ylmfLNldDiFPkL9ngJcbdF0GlvPSVXy)r5Bz6CXu23yr3X6pTufPiNX5hWgBPkL9ng7pkFltNlMY(gl6ow)PLQifKfbiX6zCNP85bqr8Gj55JOi0AE69mog4XAMGajpFefHwZtVNXF1ccK88rueAnp9Eg)SGOoccK88rueAnp9Eg)SFu7lX0kENo0AogikF9nwKHwJMe1kNX5hWghdeLV(glYqRrtICcQMNXcI6OLvJoxStIc2mU)eDggz9qud6dbHoDO1CGZsxKGsAg7mfTYzC(bSXbolDrckPzSZu4eunpJfe1rmTDsuWM3Nkg7j6p8xaSuLY(gJ9hLVLPZftzFJfDhR)0svKcYIaKyk7te(jRjNSPq)Nhafpg(aa4yGO813yrgAnAsK)Qfe8y4daGdCw6IeusZyNPWF1lvPSVXy)r5Bz6CXu23yr3X6pTufPOGgsYEiSLQfUuLY(gJXLZ48dyJrPE6BSppakHpaaEkcnLZuIGjzdI)QfecFaaCj5XspYF1AdFaaCj5XspYzDkPHc9FjieomMwGtbuhjOAEglin)yPkL9ngJlNX5hWg7pkF7ofqnlgWNxrfT(ZdGcRgDUyNefSzC3PaQzXa(8kQO1)OOPGqWK88rueAnp9Eghd8yntqGKNpIIqR5P3Z4N9td9HGajpFefHwZtVNXF1lvPSVXyC5mo)a2y)r5BGJGHUz8FEauep8baWtrOPCMsemjBq8xTGq4daGljpw6r(RwB4daGljpw6roRtjnuO)lX0gCNo0AogikF9nwKHwJMexQszFJX4YzC(bSX(JY3aoKbsssG(ZdGcBEUWZ886hRFomIKxDFJjiWMNl8mpx04Y(CyKnorO1FEwJeYRUJNQk6VSrk0)5znsiV6oQ4MW0rH(ppRrc5v3XdGcBEUWZ8CrJl7ZHr24eHwVuLY(gJXLZ48dyJ9hLVzGo05JdqueAkyAs8ZdGI4b3PdTMJbIYxFJfzO1Ojrbb5mo)a24yGO813yrgAnAsKtq18mwqFOPyAbofqDKGQ5zSF0)Xsvk7BmgxoJZpGn2Fu(o0Hm2zkXbiYEQQizPkL9ngJlNX5hWg7pkFh6qg7mL4aeZx)uTLQu23ymUCgNFaBS)O8DOdzSZuIdqe8znswQszFJX4YzC(bSX(JY3HoKXotjoarwn5mLLQu23ymUCgNFaBS)O89JHXRr1pTufPCgtsEDg6WOg(Lw)uJEu0jXppakHpaaEkcnLZuIGjzdI)QfecFaaCj5XspYF1AdFaaCj5XspYzDkPHc9FjieomMwGtbuhjOAEgliQ91svk7BmgxoJZpGn2Fu((XW41O6NwQIugribmi0PEMsSEaJKOKqlRt3NhaLWhaapfHMYzkrWKSbXF1ccHpaaUK8yPh5VATHpaaUK8yPh5SoL0qH(VeechgtlWPaQJeunpJfe9FSuLY(gJXLZ48dyJ9hLVFmmEnQ(PLQifFsOrDgl6rjnrrdjLxt7NhaLWhaapfHMYzkrWKSbXF1ccHpaaUK8yPh5VATHpaaUK8yPh5SoL0qH(VeechgtlWPaQJeunpJfKMFTuLY(gJXLZ48dyJ9hLVFmmEnQ(PLQif1uMHemYaHyhvFSt(5bqj8baWtrOPCMsemjBq8xTGq4daGljpw6r(RwB4daGljpw6roRtjnuO)lbHWHX0cCkG6ibvZZybP5xlvPSVXyC5mo)a2y)r57hdJxJQFAPksbiFUM2OCEwJevmzpc(5bqj4oDO1Cj5Xspkie(aa4sYJLEK)QfechgtlWPaQJeunpJfe1(APkL9ngJlNX5hWg7pkF)yy8Au9tlvrkEcMEGJGrriJHULQu23ymUCgNFaBS)O89JHXRr1pTufPWO55ObjSi4ZuwQszFJX4YzC(bSX(JY3pggVgv)0svKIc5uJYXJbUuLY(gJXLZ48dyJ9hLVFmmEnQ(PLQifvuDi0ghGyDY6i7m2svk7BmgxoJZpGn2Fu((XW41O6NwQIuy1jbJQy2rqZqZsvk7BmgxoJZpGn2Fu((XW41O6NwQIuyPtuQG(iWJDJft1A3bCizPkL9ngJlNX5hWg7pkF)yy8Au9tlvrkkxADCiwQIwNUynMe3svk7BmgxoJZpGn2Fu((XW41O6NwQIuaFMNjtsemiSz9y4svk7BmgxoJZpGn2Fu((XW41O6NwQIuEMeuEg6JkU0Fzpewmm9kyCaIaizKxt7NhaLWhaapfHMYzkrWKSbXF1ccHpaaUK8yPh5VATHpaaUK8yPh5SoL08Jc9FjiiNX5hWgpfHMYzkrWKSbXjOAEg7xf(qqqoJZpGnUK8yPh5eunpJ9RcFSuLY(gJXLZ48dyJ9hLVFmmEnQ(PLQiLNjbLNH(yYQpsAnlgMEfmoaraKmYRP9ZdGs4daGNIqt5mLiys2G4VAbHWhaaxsES0J8xT2WhaaxsES0JCwNsA(rH(VeeKZ48dyJNIqt5mLiys2G4eunpJ9RcFiiiNX5hWgxsES0JCcQMNX(vHpwQszFJX4YzC(bSX(JY3pggVgv)0svKc7mGNlQ4s)L9qyXW0RGXbicGKrEnTFEaucFaa8ueAkNPebtYge)vlie(aa4sYJLEK)Q1g(aa4sYJLEKZ6usZpk0)LGGCgNFaB8ueAkNPebtYgeNGQ5zSFv4dbb5mo)a24sYJLEKtq18m2Vk8Xsvk7BmgxoJZpGn2Fu((XW41O6NwQIuyNb8CXKvFK0Awmm9kyCaIaizKxt7NhaLWhaapfHMYzkrWKSbXF1ccHpaaUK8yPh5VATHpaaUK8yPh5SoL08Jc9FjiiNX5hWgpfHMYzkrWKSbXjOAEg7xf(qqqoJZpGnUK8yPh5eunpJ9RcFSuLY(gJXLZ48dyJ9hLVFmmEnQY(8aOe(aa4Pi0uotjcMKni(Rwqi8baWLKhl9i)vRn8baWLKhl9iN1PKMFuO)RLQu23ymUCgNFaBS)O8DkcnLZuIGjzd6ZdGI4GghTX6bms(rPcA7tfd6dbbqJJ2y9agj)OqnTI3Nk(7dbbYZqGHOG8gegvtLJ1KSrwmGpVIkATyccGghTX6bms(rrtTKNHadrb5Ist5LeplQoQO1pvTD6qR5aNLUibL0m2zkccD6qR5GghTXueAkirRCgNFaBCqJJ2ykcnfKWjOAEgJYxIPv8G70HwZzijRbDQccb3PdTMdCw6IeusZyNPiiiNX5hWgNHKSg0PYjOAEg73xITuLY(gJXLZ48dyJ9hLVLKhl94NhafqJJ2y9agj)OubT9PIb9HGaOXrBSEaJKFuOM2(uXFFSuLY(gJXLZ48dyJ9hLVtgi0IGsNBaVuLY(gJXLZ48dyJ9hLVbnoAJPi0uqYNhaL(uXyprq1ku(slOXrBSEaJKGOOPwXdFaa8ueAkNPebtYge)vli0PdTMljpw6rTIlNX5hWgxsES0JCcQMNXO8LGq4daGljpw6r(RwmbHWHX0cCkG6ibvZZybP5xITuLY(gJXLZ48dyJ9hLVbolDrckPzSZu(8aOioOXrBSEaJKFuQG2(uXGcabbqJJ2y9agj)OqnTI3Nk(JsaiiWQrNl2jrbBg3FIodJSEiQ)OOPw5icT0Aon0sU0etmTYzC(bSXtrOPCMsemjBqCcQMNX(Pi9A7tfJ9ebvRq5lTIhCNo0AodjznOtvqi8baWzijRbDQ8xTyAfpysE(ikcTMNEpJJbESMjiqYZhrrO1807z8xTGajpFefHwZtVNXp7xf(smTIhC4daGNIqt5mLiys2G4VAbbqJJ2y9agju(qqqoJZpGnoOuvfjXbicMKniobvZZyccSA05IDsuWMX9NOZWiRhI6pkAQvoIqlTMtdTKlnXwQszFJX4YzC(bSXOWqswd6u)8aOaAC0gRhWiHYhAfp4oDO1CGZsxKGsAg7mfbb5mo)a24aNLUibL0m2zkCcQMNXcIII0xrQjiiNX5hWgh4S0fjOKMXotHtq18m2p5mo)a2etR4b3PdTMJbIYxFJfzO1Ojrbb5mo)a24yGO813yrgAnAsKtq18mwquuK(ksnbb5mo)a24yGO813yrgAnAsKtq18m2p5mo)a2ee60HwZbolDrckPzSZuetR4blhrOLwZPHwYLMGGCgNFaBC)j6mm2JZXjOAEgliQJGGCgNFaBC)j6mm2JZXjOAEg7NCgNFaBITuTuLY(gJXrweGetzFIqkahbdDZ4xQszFJX4ilcqIPSpr4Fu(wMoxmL9nw0DS(tlvrkaNDmqiH95bqXJHpaaEaFEfv0A(RwqWJHpaaoWzPlsqjnJDMc)vRvCpg(aa4aNLUibL0m2zkCcQMNXcsr65QzGccSA05IDsuWMX9NOZWiRhI6pkAQn4oDO1Cmqu(6BSidTgnjkMGGhdFaaCmqu(6BSidTgnjYF1A9y4daGJbIYxFJfzO1OjrobvZZybPi9C1mWLQu23ymoYIaKyk7te(hLV9NOZWypo3svk7BmghzrasmL9jc)JY3Istd)ogiKWIGsvvKSuLY(gJXrweGetzFIW)O8n4KgmoaXKbczFEauanoAJ1dyKeefn1kUhdFaaCGZsxKGsAg7mf(RwRhdFaaCGZsxKGsAg7mfobvZZybPi9vutTbtEgcmefK7prNHrcYglnjki4XWhaahdeLV(glYqRrtI8xTwpg(aa4yGO813yrgAnAsKtq18mwqksVGaRgDUyNefSzC)j6mmY6HO(JYhAjpdbgIcY9NOZWibzJLMe12PdTMJbIYxFJfzO1OjrXwQszFJX4ilcqIPSpr4Fu(o0LEmoaXa(y9jXppakYX8VR5yG1pIs23yAfpyYZqGHOGC)j6mmsq2yPjrTGghTX6bmscIc1eeanoAJ1dyKeefnfBPkL9ngJJSiajMY(eH)r57a(8kQO1FEauc2JHpaaEaFEfv0A(RwR4GghTX6bms(rHETKNHadrb5nimQMkhRjzJSyaFEfv0AbbqJJ2y9agj)OOPylvPSVXyCKfbiXu2Ni8pkFltNlMY(gl6ow)PLQifGZogiKWwQszFJX4ilcqIPSpr4Fu(gCsdghGyYaHSppakGghTX6bmscIIMlvPSVXyCKfbiXu2Ni8pkFh6spghGyaFS(K4NhafqJJ2y9agjbrHAlvPSVXyCKfbiXu2Ni8pkFhWNxrfT(ZdGsWEm8baWd4ZROIwZF1lvPSVXyCKfbiXu2Ni8pkFdkvvrsCaIGjzdAPkL9ngJJSiajMY(eH)r5Bj5XspsISMC0GlvPSVXyCKfbiXu2Ni8pkFNezAyShcbTEPkL9ngJJSiajMY(eH)r5B5ymusY(gBPAPkL9ngJJSiajwpJ7mL)O8TmDUyk7BSO7y9NwQIuao7yGqc7ZdGcOXrBSEaJekFii4XWhaah4S0fjOKMXotH)QfecFaaCj5XspYF1AdFaaCj5XspYzDkPji6)APkL9ngJJSiajwpJ7mL)O8TO00WVJbcjSiOuvfjFEaucFaaCgsYAqNk)vVuLY(gJXrweGeRNXDMYFu(guQQIK4aebtYg0NhafYZqGHOGCrPP8sINfvhv06N6svk7BmghzrasSEg3zk)r57qx6X4aed4J1Ne)8aOaAC0gRhWijikuBPkL9ngJJSiajwpJ7mL)O8DaFEfv06ppakb7XWhaapGpVIkAn)vVuLY(gJXrweGeRNXDMYFu(guQQIK4aebtYg0svk7BmghzrasSEg3zk)r5Bj5XspsISMC0GFEauKZ48dyJljpw6rsK1KJgKlbLefKfbiPSVXs3pk0Z1qFOvCqJJ2y9agjbrrtbbqJJ2y9agjbrHAALZ48dyJh6spghGyaFS(KiNGQ5zSFksFf1uqa04OnwpGrcLkOvoJZpGnEOl9yCaIb8X6tICcQMNX(Pi9vutTYzC(bSXd4ZROIwZjOAEg7NI0xrnfBPkL9ngJJSiajwpJ7mL)O8ndjznOt9ZdGsWD6qR5aNLUibL0m2zkALZ48dyJJbIYxFJfzO1OjrobvZZybrrr6Ri10kEWYreAP1CAOLCPjiiNX5hWg3FIodJ94CCcQMNXcI6i2svk7BmghzrasSEg3zk)r5Bz6CXu23yr3X6pTufPaC2XaHe2svk7BmghzrasSEg3zk)r5Bj5XspsISMC0GlvPSVXyCKfbiX6zCNP8hLVtImnm2dHGw)5bqb04OnwpGrsquQWsvk7BmghzrasSEg3zk)r5BgsYAqN6NhafXdUthAnh4S0fjOKMXotrqqoJZpGnoWzPlsqjnJDMcNGQ5zSGOOi9vKAIPv8G70HwZXar5RVXIm0A0KOGGCgNFaBCmqu(6BSidTgnjYjOAEglikksFfPMGqNo0AoWzPlsqjnJDMIyAfpy5icT0Aon0sU0eeKZ48dyJ7prNHXECoobvZZybrDeBPkL9ngJJSiajwpJ7mL)O8TCmgkjzFJTuTuLY(gJXbo7yGqcJIOKCzOd)0svKINfLjRZqh(PO09qkSA05IDsuWMX9NOZWiRhIkfn1gS4KNHadrb5aNLUOiK4pzli0PdTMtofqnopwues8NSftqGvJoxStIc2mU)eDggz9qu)PPGq4daGJQ10sW0I1dyKWF1Ad2JHpaaEaFEfv0A(RwBWHpaaU)eDggRFK6HH8x9svk7Bmgh4SJbcjS)O8ndjznOt9ZdGI4YzC(bSXtrOPCMsemjBqCcQMNX(r)hccYzC(bSXLKhl9iNGQ5zSF0)HyAdUthAnh4S0fjOKMXotrR4b3PdTMJbIYxFJfzO1Ojrbbwn6CXojkyZ4(t0zyK1dr9hLpetR4btYZhrrO1807zCmWJ1mbbsE(ikcTMNEpJF2Vk8LGajpFefHwZtVNXplifPxqGKNpIIqR5P3Z4VAX0kEWYreAP1CAOLCPjiiNX5hWg3FIodJ94CCcQMNXcI6iMGaWPaQJeunpJfe9FOf4ua1rcQMNX(9HGq4daGljpw6r(RwB4daGljpw6roRtjnbr)xlvPSVXyCGZogiKW(JY3yGO813yrgAnAs8ZdGI4HpaaUK8yPh5(bSPvoJZpGnUK8yPh5eunpJ9J(VeecFaaCj5XspYzDkP5hfQjiiNX5hWgpfHMYzkrWKSbXjOAEg7h9FjMwXdUthAnh4S0fjOKMXotrqqoJZpGnoWzPlsqjnJDMcNGQ5zSF0)LyA7KOGnVpvm2t0F4VaqlRgDUyNefSzC)j6mmY6HOg0hlvPSVXyCGZogiKW(JY3(t0zyK1dr9ZdGIOKCzOd5EwuMSodDO2GdFaaCrPPHFhdesyrqPQks4VATIlEWD6qR5sYJLEuqqoJZpGnUK8yPh5eunpJ9tr6Ri1etR4b3PdTMJbIYxFJfzO1Ojrbb5mo)a24yGO813yrgAnAsKtq18m2pfPVI)JGGCgNFaBCmqu(6BSidTgnjYjOAEg7NI0xXkOf04OnwpGrYpkFii0jrbBEFQySNO)WGcabbwn6CXojkyZ4(t0zyK1dr9hLpeecUthAnNHKSg0PQvoJZpGnogikF9nwKHwJMe5eunpJ9tr6ROMIPv8G70HwZbolDrckPzSZueeKZ48dyJdCw6IeusZyNPWjOAEg7NI0xX)rqqoJZpGnoWzPlsqjnJDMcNGQ5zSFksFfRGwqJJ2y9agj)O8HGqWD6qR5mKK1GovTYzC(bSXbolDrckPzSZu4eunpJ9tr6ROMIji0PdTMdAC0gtrOPGeTYzC(bSXbnoAJPi0uqcNGQ5zSGuK(ksnbHWhaah04OnMIqtbj8xTGq4daGljpw6r(RwB4daGljpw6roRtjnbr)xITuLY(gJXbo7yGqc7pkF3OATljSOiK4pz)5bqr8G70HwZLKhl9OGGCgNFaBCj5XspYjOAEg7NI0xrQjMwXdUthAnhdeLV(glYqRrtIccYzC(bSXXar5RVXIm0A0KiNGQ5zSFksFfdabb5mo)a24yGO813yrgAnAsKtq18m2pfPVI)JwqJJ2y9agj)OubbHojkyZ7tfJ9e9hguaiieCNo0AodjznOtvRCgNFaBCmqu(6BSidTgnjYjOAEg7NI0xrnftR4b3PdTMdCw6IeusZyNPiiiNX5hWgh4S0fjOKMXotHtq18m2pfPVIbGGGCgNFaBCGZsxKGsAg7mfobvZZy)uK(k(pAbnoAJ1dyK8JsfeecUthAnNHKSg0PQvoJZpGnoWzPlsqjnJDMcNGQ5zSFksFf1umbHoDO1CqJJ2ykcnfKOvoJZpGnoOXrBmfHMcs4eunpJfKI0xrQjie(aa4GghTXueAkiH)QfecFaaCj5XspYF1AdFaaCj5XspYzDkPji6)APAHlvPSVXyCf0qs2dHrrMoxmL9nw0DS(tlvrkaNDmqiH95bqb04OnwpGrcLpeee3JHpaaEaFEfv0A(Rwqa04OnwpGrcLkiM2Whaa3FIodJeKnwAsK)QfecFaaCqJJ2ykcnfKWF1lvPSVXyCf0qs2dH9hLVfLMg(DmqiHfbLQQi5ZdGsWKNHadrb5(xtB48mFujfHobHG70HwZbolDrckPzSZu0gCNo0AogikF9nwKHwJMefeaofqDKGQ5zSGcGLQu23ymUcAij7HW(JY3GsvvKehGiys2G(8aOqEgcmefK3GWOA6J1jjvgtqqoIqlTMlcTgeTeTYzC(bSXtgi0IGsNBaZjOAEg7NM0)1svk7BmgxbnKK9qy)r5B)j6mm2JZ95bqjypg(aa4b85vurR5VATIhCNo0AodjznOtvqi8baWzijRbDQ8xTyAfpysE(ikcTMNEpJJbESMjiqYZhrrO1807z8Z(rTVeei55JOi0AE69m(RwmTb3PdTMdCw6IeusZyNPOv8G70HwZXar5RVXIm0A0KOGaWPaQJeunpJfuaiiWQrNl2jrbBg3FIodJSEiQ)O8HyAfxoJZpGnEkcnLZuIGjzdItq18mMGGCgNFaBCj5XspYjOAEgtSLQu23ymUcAij7HW(JY3b85vurR)8aOeShdFaa8a(8kQO18xTwXbnoAJ1dyK8Jc9AjpdbgIcYBqyunvowtYgzXa(8kQO1ccGghTX6bms(rrtXwQszFJX4kOHKShc7pkFdoPbJdqmzGq2NhafXbnoAJ1dyKq5lbbqJJ2y9agjbrrtTYzC(bSXdDPhJdqmGpwFsKtq18m2pfPVIAkMwXdMKNpIIqR5P3Z4yGhRzccK88rueAnp9Eg)SFA(LGajpFefHwZtVNXF1IPv8G70HwZzijRbDQccYzC(bSXzijRbDQCcQMNX(9HGGCeHwAnNgAjxAIPv8G70HwZXar5RVXIm0A0KOGGCgNFaBCmqu(6BSidTgnjYjOAEg7h9Fii0jrbBEFQySNO)WGcabbwn6CXojkyZ4(t0zyK1dr9hLpetR4b3PdTMdCw6IeusZyNPiiiNX5hWgh4S0fjOKMXotHtq18m2p6)qqa4ua1rcQMNXckaetR4YzC(bSXtrOPCMsemjBqCcQMNXeeKZ48dyJljpw6robvZZyITuLY(gJXvqdjzpe2Fu(wMoxmL9nw0DS(tlvrkaNDmqiH95bqb04OnwpGrYpkutB4daGljpw6r(RwB4daGljpw6roRtjnbr)xlvPSVXyCf0qs2dH9hLVdDPhJdqmGpwFs8ZdGICm)7Aogy9JOK9nMwqJJ2y9agjbrHAlvPSVXyCf0qs2dH9hLVd4ZROIw)5bqjypg(aa4b85vurR5V6LQu23ymUcAij7HW(JY3GsvvKehGiys2GwQszFJX4kOHKShc7pkFh6spghGyaFS(K4NhafqJJ2y9agjbrHAlvPSVXyCf0qs2dH9hLVLPZftzFJfDhR)0svKcWzhdesyFEaueVtIc2Cqy6Aq8Azhefn)sqi8baWtrOPCMsemjBq8xTGq4daGljpw6r(Rwqi8baWr1AAjyAX6bms4VAXwQszFJX4kOHKShc7pkFlhJHss23yFEaucwogdLKSVX4VATSA05IDsuWMX9NOZWiRhI6pkAUuLY(gJXvqdjzpe2Fu(wsES0JKiRjhn4Nhaf5mo)a24sYJLEKezn5Ob5sqjrbzrask7BS09Jc9Cn0hAfh04OnwpGrsqu0uqa04OnwpGrsquOMw5mo)a24HU0JXbigWhRpjYjOAEg7NI0xrnfeanoAJ1dyKqPcALZ48dyJh6spghGyaFS(KiNGQ5zSFksFf1uRCgNFaB8a(8kQO1CcQMNX(Pi9vutXwQszFJX4kOHKShc7pkFltNlMY(gl6ow)PLQifGZogiKWwQszFJX4kOHKShc7pkFlhJHss23yFEaucwogdLKSVX4V6LQu23ymUcAij7HW(JY3sYJLEKezn5ObxQszFJX4kOHKShc7pkFNezAyShcbTEPkL9ngJRGgsYEiS)O8TCmgkjzFJv0fHe2nwPsn)st6PNEnPwrhCsSZuyf9aKaS)DL)Rkdq))cxyvGWfEQ1dPxiWqwiDkOHKShcJUfsqn87iOFHSrfxy(6rnB0VqjO0uqgFPsdodxOM)FHu)yIqsJ(fsxNo0AUgPBH9Sq660HwZ1ihTm0HE6wO4AgOy8Lkn4mCHA()fs9Jjcjn6xiDKNHadrb5AKUf2ZcPJ8meyikixJC0Yqh6PBHItFGIXxQ0GZWfsT)VqQFmriPr)cPJ8meyikixJ0TWEwiDKNHadrb5AKJwg6qpDluC6dum(sLgCgUWk8)fs9Jjcjn6xiDD6qR5AKUf2ZcPRthAnxJC0Yqh6PBHItTafJVuPbNHl8J)VqQFmriPr)cPJ8meyikixJ0TWEwiDKNHadrb5AKJwg6qpDluC6dum(sLgCgUW)5)lK6htesA0Vq660HwZ1iDlSNfsxNo0AUg5OLHo0t3cfNAbkgFPAPkaja7Fx5)QYa0)VWfwfiCHNA9q6fcmKfsNhbYNRPBHeud)oc6xiBuXfMVEuZg9lucknfKXxQ0GZWfsT)VqQFmriPr)cPRthAnxJ0TWEwiDD6qR5AKJwg6qpDluCndum(s1svasa2)UY)vLbO)FHlSkq4cp16H0leyilKUAckh1WSPBHeud)oc6xiBuXfMVEuZg9lucknfKXxQ0GZWf(p)FHu)yIqsJ(fshBEUWZ8Cns3c7zH0XMNl8mpxJC0Yqh6PBHItFGIXxQ0GZWf(p)FHu)yIqsJ(fshBEUWZ8Cns3c7zH0XMNl8mpxJC0Yqh6PBHzVqQBb40Gfko9bkgFPAPkaja7Fx5)QYa0)VWfwfiCHNA9q6fcmKfsNCgNFaBm6wib1WVJG(fYgvCH5Rh1Sr)cLGstbz8Lkn4mCHu7)lK6htesA0Vq660HwZ1iDlSNfsxNo0AUg5OLHo0t3cZEHu3cWPbluC6dum(sLgCgUWk8)fs9Jjcjn6xiDS55cpZZ1iDlSNfshBEUWZ8CnYrldDONUfko9bkgFPsdodxyf()cP(XeHKg9lKo28CHN55AKUf2ZcPJnpx4zEUg5OLHo0t3cZEHu3cWPbluC6dum(sLgCgUWp()cP(XeHKg9lKUoDO1Cns3c7zH01PdTMRroAzOd90TqXPpqX4lvAWz4cPVc)FHu)yIqsJ(fsxNo0AUgPBH9Sq660HwZ1ihTm0HE6wO40hOy8Lkn4mCHAga)FHu)yIqsJ(fsxNo0AUgPBH9Sq660HwZ1ihTm0HE6wO4viqX4lvAWz4c1ma()cP(XeHKg9lKoYZqGHOGCns3c7zH0rEgcmefKRroAzOd90TqX1mqX4lvAWz4cPg9)FHu)yIqsJ(fsxNo0AUgPBH9Sq660HwZ1ihTm0HE6wO40hOy8Lkn4mCHutZ)VqQFmriPr)cPRthAnxJ0TWEwiDD6qR5AKJwg6qpDluC6dum(sLgCgUqQrT)VqQFmriPr)cPRthAnxJ0TWEwiDD6qR5AKJwg6qpDluCQfOy8LQLQaKaS)DL)Rkdq))cxyvGWfEQ1dPxiWqwiDaNDmqiHr3cjOg(De0Vq2OIlmF9OMn6xOeuAkiJVuPbNHlK()VqQFmriPr)cPRthAnxJ0TWEwiDD6qR5AKJwg6qpDluC6dum(sLgCgUq6))cP(XeHKg9lKoYZqGHOGCns3c7zH0rEgcmefKRroAzOd90TqXPpqX4lvAWz4c18)lK6htesA0Vq660HwZ1iDlSNfsxNo0AUg5OLHo0t3cfxZafJVuPbNHlKA)FHu)yIqsJ(fsxNo0AUgPBH9Sq660HwZ1ihTm0HE6wO40hOy8Lkn4mCHv4)lK6htesA0Vq660HwZ1iDlSNfsxNo0AUg5OLHo0t3cf)Fcum(sLgCgUWp()cP(XeHKg9lKUoDO1Cns3c7zH01PdTMRroAzOd90TqX)NafJVuTufGeG9VR8Fvza6)x4cRceUWtTEi9cbgYcPdzrasmL9jcPBHeud)oc6xiBuXfMVEuZg9lucknfKXxQ0GZWfQ5)xi1pMiK0OFH01PdTMRr6wyplKUoDO1CnYrldDONUfko9bkgFPsdodx4h)FHu)yIqsJ(fsxNo0AUgPBH9Sq660HwZ1ihTm0HE6wO40hOy8Lkn4mCHF8)fs9Jjcjn6xiDKNHadrb5AKUf2ZcPJ8meyikixJC0Yqh6PBHIRzGIXxQ0GZWf(p)FHu)yIqsJ(fsh5ziWquqUgPBH9Sq6ipdbgIcY1ihTm0HE6wO40hOy8Lkn4mCHAO)VqQFmriPr)cPJ8meyikixJ0TWEwiDKNHadrb5AKJwg6qpDluC6dum(s1svasa2)UY)vLbO)FHlSkq4cp16H0leyilKoKfbiX6zCNPq3cjOg(De0Vq2OIlmF9OMn6xOeuAkiJVuPbNHlKA)FHu)yIqsJ(fsh5ziWquqUgPBH9Sq6ipdbgIcY1ihTm0HE6wy2lK6waonyHItFGIXxQ0GZWfga)FHu)yIqsJ(fsxNo0AUgPBH9Sq660HwZ1ihTm0HE6wO40hOy8Lkn4mCH0R5)xi1pMiK0OFH01PdTMRr6wyplKUoDO1CnYrldDONUfko1cum(s1s1)sTEin6xOgAHPSVXwO7ynJVuv0DhRzLQk6kOHKShcRuvPs6lvv0rldDOVuDrpL9nwrxMoxmL9nw0DSUOljxJKll6GghTX6bmswiLf(XcfewO4l0JHpaaEaFEfv0A(REHccle04OnwpGrYcPSWkSqXwO2fg(aa4(t0zyKGSXstI8x9cfewy4daGdAC0gtrOPGe(RUO7owhTufl6aNDmqiHv6sLAwQQOJwg6qFP6IUKCnsUSOh8cjpdbgIcY9VM2W5z(OskcDC0Yqh6xOGWcdEHD6qR5aNLUibL0m2zkC0Yqh6xO2fg8c70HwZXar5RVXIm0A0KihTm0H(fkiSqGtbuhjOAEgBHbTWaOONY(gROlknn87yGqclckvvrsPlvsTsvfD0Yqh6lvx0LKRrYLfDYZqGHOG8gegvtFSojPYyC0Yqh6xOGWcLJi0sR5IqRbrlzHAxOCgNFaB8KbcTiO05gWCcQMNXw4VfQj9Fv0tzFJv0bLQQijoarWKSbv6sLvOuvrhTm0H(s1fDj5AKCzrp4f6XWhaapGpVIkAn)vVqTlu8fg8c70HwZzijRbDQC0Yqh6xOGWcdFaaCgsYAqNk)vVqXwO2fk(cdEHK88rueAnp9Eghd8ynBHcclKKNpIIqR5P3Z4NTWFlKAFTqbHfsYZhrrO1807z8x9cfBHAxyWlSthAnh4S0fjOKMXotHJwg6q)c1UqXxyWlSthAnhdeLV(glYqRrtIC0Yqh6xOGWcbofqDKGQ5zSfg0cdGfkiSqwn6CXojkyZ4(t0zyK1drDH)OSWpwOylu7cfFHYzC(bSXtrOPCMsemjBqCcQMNXwOGWcLZ48dyJljpw6robvZZyluSIEk7BSIU)eDgg7X5kDPYpkvv0rldDOVuDrxsUgjxw0dEHEm8baWd4ZROIwZF1lu7cfFHGghTX6bmsw4pklK(fQDHKNHadrb5nimQMkhRjzJSyaFEfv0AoAzOd9luqyHGghTX6bmsw4pkluZfkwrpL9nwrpGpVIkADPlv(pLQk6OLHo0xQUOljxJKll6IVqqJJ2y9agjlKYc)AHccle04OnwpGrYcdIYc1CHAxOCgNFaB8qx6X4aed4J1Ne5eunpJTWFlur6xyfxOMluSfQDHIVWGxijpFefHwZtVNXXapwZwOGWcj55JOi0AE69m(zl83c18RfkiSqsE(ikcTMNEpJ)QxOylu7cfFHbVWoDO1CgsYAqNkhTm0H(fkiSq5mo)a24mKK1GovobvZZyl83c)yHccluoIqlTMtdTKlTfk2c1UqXxyWlSthAnhdeLV(glYqRrtIC0Yqh6xOGWcLZ48dyJJbIYxFJfzO1OjrobvZZyl83cP)JfkiSWojkyZ7tfJ9e9hUWGwyaSqbHfYQrNl2jrbBg3FIodJSEiQl8hLf(XcfBHAxO4lm4f2PdTMdCw6IeusZyNPWrldDOFHccluoJZpGnoWzPlsqjnJDMcNGQ5zSf(BH0)XcfewiWPaQJeunpJTWGwyaSqXwO2fk(cLZ48dyJNIqt5mLiys2G4eunpJTqbHfkNX5hWgxsES0JCcQMNXwOyf9u23yfDWjnyCaIjdeYkDPsnuPQIoAzOd9LQl6PSVXk6Y05IPSVXIUJ1fDj5AKCzrh04OnwpGrYc)rzHuBHAxy4daGljpw6r(REHAxy4daGljpw6roRtjnlmOfs)xfD3X6OLQyrh4SJbcjSsxQmakvv0rldDOVuDrxsUgjxw0LJ5FxZXaRFeLSVXwO2fcAC0gRhWizHbrzHuRONY(gROh6spghGyaFS(KyPlvsDkvv0rldDOVuDrxsUgjxw0dEHEm8baWd4ZROIwZF1f9u23yf9a(8kQO1LUuj9FvQQONY(gROdkvvrsCaIGjzdQOJwg6qFP6sxQKE6lvv0rldDOVuDrxsUgjxw0bnoAJ1dyKSWGOSqQv0tzFJv0dDPhJdqmGpwFsS0LkPxZsvfD0Yqh6lvx0tzFJv0LPZftzFJfDhRl6sY1i5YIU4lStIc2Cqy6Aq8AzVWGOSqn)AHcclm8baWtrOPCMsemjBq8x9cfewy4daGljpw6r(REHcclm8baWr1AAjyAX6bms4V6fkwr3DSoAPkw0bo7yGqcR0LkPNALQk6OLHo0xQUOljxJKll6bVq5ymusY(gJ)QxO2fYQrNl2jrbBg3FIodJSEiQl8hLfQzrpL9nwrxogdLKSVXkDPs6RqPQIoAzOd9LQl6sY1i5YIUCgNFaBCj5XspsISMC0GCjOKOGSiajL9nw6w4pklKEUg6JfQDHIVqqJJ2y9agjlmikluZfkiSqqJJ2y9agjlmiklKAlu7cLZ48dyJh6spghGyaFS(KiNGQ5zSf(BHks)cR4c1CHccle04OnwpGrYcPSWkSqTluoJZpGnEOl9yCaIb8X6tICcQMNXw4VfQi9lSIluZfQDHYzC(bSXd4ZROIwZjOAEgBH)wOI0VWkUqnxOyf9u23yfDj5XspsISMC0GLUuj9FuQQOJwg6qFP6IEk7BSIUmDUyk7BSO7yDr3DSoAPkw0bo7yGqcR0LkP)Fkvv0rldDOVuDrxsUgjxw0dEHYXyOKK9ng)vx0tzFJv0LJXqjj7BSsxQKEnuPQIEk7BSIUK8yPhjrwtoAWIoAzOd9LQlDPs6dGsvf9u23yf9KitdJ9qiO1fD0Yqh6lvx6sL0tDkvv0tzFJv0LJXqjj7BSIoAzOd9LQlDPl6EeiFUUuvPs6lvv0tzFJv0jy4JgSOJwg6qFP6sxQuZsvfD0Yqh6lvx0tzFJv0LPZftzFJfDhRl6UJ1rlvXIUCgNFaBSsxQKALQk6OLHo0xQUONY(gROltNlMY(gl6owx0LKRrYLfDXxyWlKKNpIIqR5P3Z4yGhRzluqyHK88rueAnp9Eg)vVqbHfsYZhrrO1807z8ZwyqlK6SqbHfsYZhrrO1807z8Zw4VfsTVwOylu7cfFHD6qR5yGO813yrgAnAsKJwg6q)c1Uq5mo)a24yGO813yrgAnAsKtq18m2cdAHuNfQDHSA05IDsuWMX9NOZWiRhI6cdAHFSqbHf2PdTMdCw6IeusZyNPWrldDOFHAxOCgNFaBCGZsxKGsAg7mfobvZZylmOfsDwOylu7c7KOGnVpvm2t0F4c)TWaOO7owhTufl6ilcqI1Z4otP0LkRqPQIoAzOd9LQl6sY1i5YIUhdFaaCmqu(6BSidTgnjYF1luqyHEm8baWbolDrckPzSZu4V6IoRjNSlvsFrpL9nwrxMoxmL9nw0DSUO7owhTufl6ilcqIPSpryPlv(rPQIoAzOd9LQl6PSVXk6Y05IPSVXIUJ1fD3X6OLQyrxbnKK9qyLU0f9Ackh1WSlvvQK(svf9u23yf96PVXk6OLHo0xQU0Lk1SuvrpL9nwrp0Hm2zkXbiYEQQiPOJwg6qFP6sxQKALQk6PSVXk6HoKXotjoaX81pvROJwg6qFP6sxQScLQk6PSVXk6HoKXotjoarWN1iPOJwg6qFP6sxQ8Jsvf9u23yf9qhYyNPehGiRMCMsrhTm0H(s1LUu5)uQQOJwg6qFP6IUKCnsUSOZMNl8mpV(X6NdJi5v33yC0Yqh6xOGWczZZfEMNlACzFomYgNi0AoAzOd9f9u23yfDahYajjjqx6sLAOsvfD0Yqh6lvx0LKRrYLf9oDO1CGZsxKGsAg7mfoAzOd9lu7c70HwZzijRbDQC0Yqh6l6PSVXk6jrMgg7HqqRlDPl6YzC(bSXkvvQK(svfD0Yqh6lvx0LKRrYLf9WhaapfHMYzkrWKSbXF1luqyHHpaaUK8yPh5V6fQDHHpaaUK8yPh5SoL0SqklK(VwOGWcdhgBHAxiWPaQJeunpJTWGwOMFu0tzFJv0RN(gR0Lk1SuvrhTm0H(s1fDj5AKCzrNvJoxStIc2mU7ua1SyaFEfv06f(JYc1CHcclm4fsYZhrrO1807zCmWJ1SfkiSqsE(ikcTMNEpJF2c)Tqn0hluqyHK88rueAnp9Eg)vx0tzFJv0DNcOMfd4ZROIwx6sLuRuvrhTm0H(s1fDj5AKCzrx8fg(aa4Pi0uotjcMKni(REHcclm8baWLKhl9i)vVqTlm8baWLKhl9iN1PKMfszH0)1cfBHAxyWlSthAnhdeLV(glYqRrtIC0Yqh6l6PSVXk6ahbdDZ4lDPYkuQQOJwg6qFP6IUKCnsUSOZMNl8mpV(X6NdJi5v33yC0Yqh6xOGWczZZfEMNlACzFomYgNi0AoAzOd9f9ZAKqE1D8ak6S55cpZZfnUSphgzJteADr)SgjKxDhpvv0FzJfD6l6PSVXk6aoKbsssGUOFwJeYRUJkUjmDfD6lDPYpkvv0rldDOVuDrxsUgjxw0fFHbVWoDO1Cmqu(6BSidTgnjYrldDOFHccluoJZpGnogikF9nwKHwJMe5eunpJTWGw4hAUqXwO2fcCkG6ibvZZyl83cP)JIEk7BSIod0HoFCaIIqtbttILUu5)uQQONY(gROh6qg7mL4aezpvvKu0rldDOVuDPlvQHkvv0tzFJv0dDiJDMsCaI5RFQwrhTm0H(s1LUuzauQQONY(gROh6qg7mL4aebFwJKIoAzOd9LQlDPsQtPQIEk7BSIEOdzSZuIdqKvtotPOJwg6qFP6sxQK(Vkvv0rldDOVuDr3svSOFgtsEDg6WOg(Lw)uJEu0jXIEk7BSI(zmj51zOdJA4xA9tn6rrNel6sY1i5YIE4daGNIqt5mLiys2G4V6fkiSWWhaaxsES0J8x9c1UWWhaaxsES0JCwNsAwiLfs)xluqyHHdJTqTle4ua1rcQMNXwyqlKAFv6sL0tFPQIoAzOd9LQl6wQIf9resadcDQNPeRhWijkj0Y60v0tzFJv0hribmi0PEMsSEaJKOKqlRtxrxsUgjxw0dFaa8ueAkNPebtYge)vVqbHfg(aa4sYJLEK)QxO2fg(aa4sYJLEKZ6usZcPSq6)AHcclmCySfQDHaNcOosq18m2cdAH0)rPlvsVMLQk6OLHo0xQUOBPkw09jHg1zSOhL0efnKuEnTf9u23yfDFsOrDgl6rjnrrdjLxtBrxsUgjxw0dFaa8ueAkNPebtYge)vVqbHfg(aa4sYJLEK)QxO2fg(aa4sYJLEKZ6usZcPSq6)AHcclmCySfQDHaNcOosq18m2cdAHA(vPlvsp1kvv0rldDOVuDr3svSORMYmKGrgie7O6JDYIEk7BSIUAkZqcgzGqSJQp2jl6sY1i5YIE4daGNIqt5mLiys2G4V6fkiSWWhaaxsES0J8x9c1UWWhaaxsES0JCwNsAwiLfs)xluqyHHdJTqTle4ua1rcQMNXwyqluZVkDPs6RqPQIoAzOd9LQl6wQIfDG85AAJY5znsuXK9iyrpL9nwrhiFUM2OCEwJevmzpcw0LKRrYLf9GxyNo0AUK8yPh5OLHo0VqbHfg(aa4sYJLEK)QxOGWcdhgBHAxiWPaQJeunpJTWGwi1(Q0LkP)JsvfD0Yqh6lvx0Tufl6EcMEGJGrriJHUIEk7BSIUNGPh4iyueYyOR0LkP)Fkvv0rldDOVuDr3svSOZO55ObjSi4Zuk6PSVXk6mAEoAqclc(mLsxQKEnuPQIoAzOd9LQl6wQIfDfYPgLJhdSONY(gRORqo1OC8yGLUuj9bqPQIoAzOd9LQl6wQIfDvuDi0ghGyDY6i7mwrpL9nwrxfvhcTXbiwNSoYoJv6sL0tDkvv0rldDOVuDr3svSOZQtcgvXSJGMHMIEk7BSIoRojyufZocAgAkDPsn)QuvrhTm0H(s1fDlvXIolDIsf0hbESBSyQw7oGdjf9u23yfDw6eLkOpc8y3yXuT2DahskDPsnPVuvrhTm0H(s1fDlvXIUYLwhhILQO1PlwJjXv0tzFJv0vU064qSufToDXAmjUsxQutnlvv0rldDOVuDr3svSOd(mptMKiyqyZ6XWIEk7BSIo4Z8mzsIGbHnRhdlDPsnPwPQIoAzOd9LQl6wQIf9NjbLNH(OIl9x2dHfdtVcghGiasg510w0tzFJv0FMeuEg6JkU0Fzpewmm9kyCaIaizKxtBrxsUgjxw0dFaa8ueAkNPebtYge)vVqbHfg(aa4sYJLEK)QxO2fg(aa4sYJLEKZ6usZc)rzH0)1cfewOCgNFaB8ueAkNPebtYgeNGQ5zSf(BHv4JfkiSq5mo)a24sYJLEKtq18m2c)TWk8rPlvQzfkvv0rldDOVuDr3svSO)mjO8m0htw9rsRzXW0RGXbicGKrEnTf9u23yf9NjbLNH(yYQpsAnlgMEfmoaraKmYRPTOljxJKll6HpaaEkcnLZuIGjzdI)QxOGWcdFaaCj5XspYF1lu7cdFaaCj5XspYzDkPzH)OSq6)AHccluoJZpGnEkcnLZuIGjzdItq18m2c)TWk8XcfewOCgNFaBCj5XspYjOAEgBH)wyf(O0Lk18JsvfD0Yqh6lvx0Tufl6SZaEUOIl9x2dHfdtVcghGiasg510w0tzFJv0zNb8Crfx6VShclgMEfmoaraKmYRPTOljxJKll6HpaaEkcnLZuIGjzdI)QxOGWcdFaaCj5XspYF1lu7cdFaaCj5XspYzDkPzH)OSq6)AHccluoJZpGnEkcnLZuIGjzdItq18m2c)TWk8XcfewOCgNFaBCj5XspYjOAEgBH)wyf(O0Lk18Fkvv0rldDOVuDr3svSOZod45IjR(iP1Syy6vW4aebqYiVM2IEk7BSIo7mGNlMS6JKwZIHPxbJdqeajJ8AAl6sY1i5YIE4daGNIqt5mLiys2G4V6fkiSWWhaaxsES0J8x9c1UWWhaaxsES0JCwNsAw4pklK(VwOGWcLZ48dyJNIqt5mLiys2G4eunpJTWFlScFSqbHfkNX5hWgxsES0JCcQMNXw4VfwHpkDPsn1qLQk6OLHo0xQUOljxJKll6HpaaEkcnLZuIGjzdI)QxOGWcdFaaCj5XspYF1lu7cdFaaCj5XspYzDkPzH)OSq6)QONY(gRO)yy8AuLv6sLAgaLQk6OLHo0xQUOljxJKll6IVqqJJ2y9agjl8hLfwHfQDH9PIlmOf(XcfewiOXrBSEaJKf(JYcP2c1UqXxyFQ4c)TWpwOGWcjpdbgIcYBqyunvowtYgzXa(8kQO1C0Yqh6xOyluqyHGghTX6bmsw4pkluZfQDHKNHadrb5Ist5LeplQoQO1pvoAzOd9lu7c70HwZbolDrckPzSZu4OLHo0VqbHf2PdTMdAC0gtrOPGeoAzOd9lu7cLZ48dyJdAC0gtrOPGeobvZZylKYc)AHITqTlu8fg8c70HwZzijRbDQC0Yqh6xOGWcdEHD6qR5aNLUibL0m2zkC0Yqh6xOGWcLZ48dyJZqswd6u5eunpJTWFl8RfkwrpL9nwrpfHMYzkrWKSbv6sLAsDkvv0rldDOVuDrxsUgjxw0bnoAJ1dyKSWFuwyfwO2f2NkUWGw4hluqyHGghTX6bmsw4pklKAlu7c7tfx4Vf(rrpL9nwrxsES0JLUuj1(QuvrpL9nwrpzGqlckDUbCrhTm0H(s1LUuj1OVuvrhTm0H(s1fDj5AKCzrVpvm2teuTYcPSWVwO2fcAC0gRhWizHbrzHAUqTlu8fg(aa4Pi0uotjcMKni(REHcclSthAnxsES0JC0Yqh6xO2fk(cLZ48dyJljpw6robvZZylKYc)AHcclm8baWLKhl9i)vVqXwOGWcdhgBHAxiWPaQJeunpJTWGwOMFTqXk6PSVXk6GghTXueAkiP0LkPMMLQk6OLHo0xQUOljxJKll6IVqqJJ2y9agjl8hLfwHfQDH9PIlmOfgaluqyHGghTX6bmsw4pklKAlu7cfFH9PIl8hLfgaluqyHSA05IDsuWMX9NOZWiRhI6c)rzHAUqTluoIqlTMtdTKlTfk2cfBHAxOCgNFaB8ueAkNPebtYgeNGQ5zSf(BHks)c1UW(uXyprq1klKYc)AHAxO4lm4f2PdTMZqswd6u5OLHo0VqbHfg(aa4mKK1Gov(REHITqTlu8fg8cj55JOi0AE69mog4XA2cfewijpFefHwZtVNXF1luqyHK88rueAnp9Eg)Sf(BHv4Rfk2c1UqXxyWlm8baWtrOPCMsemjBq8x9cfewiOXrBSEaJKfszHFSqbHfkNX5hWghuQQIK4aebtYgeNGQ5zSfkiSqwn6CXojkyZ4(t0zyK1drDH)OSqnxO2fkhrOLwZPHwYL2cfRONY(gROdCw6IeusZyNPu6sLuJALQk6OLHo0xQUOljxJKll6GghTX6bmswiLf(Xc1UqXxyWlSthAnh4S0fjOKMXotHJwg6q)cfewOCgNFaBCGZsxKGsAg7mfobvZZylmiklur6xyfxi1wOGWcLZ48dyJdCw6IeusZyNPWjOAEgBH)wyk7BSOCgNFaBluSfQDHIVWGxyNo0AogikF9nwKHwJMe5OLHo0VqbHfkNX5hWghdeLV(glYqRrtICcQMNXwyquwOI0VWkUqQTqbHfkNX5hWghdeLV(glYqRrtICcQMNXw4VfMY(glkNX5hW2cfewyNo0AoWzPlsqjnJDMchTm0H(fk2c1UqXxyWluoIqlTMtdTKlTfkiSq5mo)a24(t0zyShNJtq18m2cdAHuNfkiSq5mo)a24(t0zyShNJtq18m2c)TWu23yr5mo)a2wOyf9u23yfDgsYAqNAPlDrh4SJbcjSsvLkPVuvrhTm0H(s1f9PUOZWUONY(gROlkjxg6WIUO09WIoRgDUyNefSzC)j6mmY6HOUqkluZfQDHbVqXxi5ziWquqoWzPlkcj(t2C0Yqh6xOGWc70HwZjNcOgNhlkcj(t2C0Yqh6xOyluqyHSA05IDsuWMX9NOZWiRhI6c)TqnxOGWcdFaaCuTMwcMwSEaJe(REHAxyWl0JHpaaEaFEfv0A(REHAxyWlm8baW9NOZWy9JupmK)Ql6Iss0svSO7zrzY6m0HLUuPMLQk6OLHo0xQUOljxJKll6IVq5mo)a24Pi0uotjcMKniobvZZyl83cP)JfkiSq5mo)a24sYJLEKtq18m2c)Tq6)yHITqTlm4f2PdTMdCw6IeusZyNPWrldDOFHAxO4lm4f2PdTMJbIYxFJfzO1OjroAzOd9luqyHSA05IDsuWMX9NOZWiRhI6c)rzHFSqXwO2fk(cdEHK88rueAnp9Eghd8ynBHcclKKNpIIqR5P3Z4NTWFlScFTqbHfsYZhrrO1807z8Zwyqlur6xOGWcj55JOi0AE69m(REHITqTlu8fg8cLJi0sR50ql5sBHccluoJZpGnU)eDgg7X54eunpJTWGwi1zHITqbHfcCkG6ibvZZylmOfs)hlu7cbofqDKGQ5zSf(BHFSqbHfg(aa4sYJLEK)QxO2fg(aa4sYJLEKZ6usZcdAH0)vrpL9nwrNHKSg0Pw6sLuRuvrhTm0H(s1fDj5AKCzrx8fg(aa4sYJLEK7hW2c1Uq5mo)a24sYJLEKtq18m2c)Tq6)AHcclm8baWLKhl9iN1PKMf(JYcP2cfewOCgNFaB8ueAkNPebtYgeNGQ5zSf(BH0)1cfBHAxO4lm4f2PdTMdCw6IeusZyNPWrldDOFHccluoJZpGnoWzPlsqjnJDMcNGQ5zSf(BH0)1cfBHAxyNefS59PIXEI(dx4Vfgalu7cz1OZf7KOGnJ7prNHrwpe1fg0c)OONY(gROJbIYxFJfzO1OjXsxQScLQk6OLHo0xQUOljxJKll6IsYLHoK7zrzY6m0Hlu7cdEHHpaaUO00WVJbcjSiOuvfj8x9c1UqXxO4lm4f2PdTMljpw6roAzOd9luqyHYzC(bSXLKhl9iNGQ5zSf(BHks)cR4cP2cfBHAxO4lm4f2PdTMJbIYxFJfzO1OjroAzOd9luqyHYzC(bSXXar5RVXIm0A0KiNGQ5zSf(BHks)cR4c)NfkiSq5mo)a24yGO813yrgAnAsKtq18m2c)TqfPFHvCHvyHAxiOXrBSEaJKf(JYc)yHcclStIc28(uXypr)HlmOfgaluqyHSA05IDsuWMX9NOZWiRhI6c)rzHFSqbHfg8c70HwZzijRbDQC0Yqh6xO2fkNX5hWghdeLV(glYqRrtICcQMNXw4VfQi9lSIluZfk2c1UqXxyWlSthAnh4S0fjOKMXotHJwg6q)cfewOCgNFaBCGZsxKGsAg7mfobvZZyl83cvK(fwXf(pluqyHYzC(bSXbolDrckPzSZu4eunpJTWFlur6xyfxyfwO2fcAC0gRhWizH)OSWpwOGWcdEHD6qR5mKK1GovoAzOd9lu7cLZ48dyJdCw6IeusZyNPWjOAEgBH)wOI0VWkUqnxOyluqyHD6qR5GghTXueAkiHJwg6q)c1Uq5mo)a24GghTXueAkiHtq18m2cdAHks)cR4cP2cfewy4daGdAC0gtrOPGe(REHcclm8baWLKhl9i)vVqTlm8baWLKhl9iN1PKMfg0cP)RfkwrpL9nwr3FIodJSEiQLUu5hLQk6OLHo0xQUOljxJKll6IVWGxyNo0AUK8yPh5OLHo0VqbHfkNX5hWgxsES0JCcQMNXw4VfQi9lSIlKAluSfQDHIVWGxyNo0AogikF9nwKHwJMe5OLHo0VqbHfkNX5hWghdeLV(glYqRrtICcQMNXw4VfQi9lSIlmawOGWcLZ48dyJJbIYxFJfzO1OjrobvZZyl83cvK(fwXf(plu7cbnoAJ1dyKSWFuwyfwOGWc7KOGnVpvm2t0F4cdAHbWcfewyWlSthAnNHKSg0PYrldDOFHAxOCgNFaBCmqu(6BSidTgnjYjOAEgBH)wOI0VWkUqnxOylu7cfFHbVWoDO1CGZsxKGsAg7mfoAzOd9luqyHYzC(bSXbolDrckPzSZu4eunpJTWFlur6xyfxyaSqbHfkNX5hWgh4S0fjOKMXotHtq18m2c)TqfPFHvCH)Zc1UqqJJ2y9agjl8hLfwHfkiSWGxyNo0AodjznOtLJwg6q)c1Uq5mo)a24aNLUibL0m2zkCcQMNXw4VfQi9lSIluZfk2cfewyNo0AoOXrBmfHMcs4OLHo0VqTluoJZpGnoOXrBmfHMcs4eunpJTWGwOI0VWkUqQTqbHfg(aa4GghTXueAkiH)QxOGWcdFaaCj5XspYF1lu7cdFaaCj5XspYzDkPzHbTq6)QONY(gRO3OATljSOiK4pzx6sx0rweGetzFIWsvLkPVuvrpL9nwrh4iyOBgFrhTm0H(s1LUuPMLQk6OLHo0xQUONY(gROltNlMY(gl6owx0LKRrYLfDpg(aa4b85vurR5V6fkiSqpg(aa4aNLUibL0m2zk8x9c1UqXxOhdFaaCGZsxKGsAg7mfobvZZylmOfQi9C1mWfkiSqwn6CXojkyZ4(t0zyK1drDH)OSqnxO2fg8c70HwZXar5RVXIm0A0KihTm0H(fk2cfewOhdFaaCmqu(6BSidTgnjYF1lu7c9y4daGJbIYxFJfzO1OjrobvZZylmOfQi9C1mWIU7yD0svSOdC2XaHewPlvsTsvf9u23yfD)j6mm2JZv0rldDOVuDPlvwHsvf9u23yfDrPPHFhdesyrqPQksk6OLHo0xQU0Lk)OuvrhTm0H(s1fDj5AKCzrh04OnwpGrYcdIYc1CHAxO4l0JHpaaoWzPlsqjnJDMc)vVqTl0JHpaaoWzPlsqjnJDMcNGQ5zSfg0cvK(fwXfQ5c1UWGxi5ziWquqU)eDggjiBS0KihTm0H(fkiSqpg(aa4yGO813yrgAnAsK)QxO2f6XWhaahdeLV(glYqRrtICcQMNXwyqlur6xOGWcz1OZf7KOGnJ7prNHrwpe1f(JYc)yHAxi5ziWquqU)eDggjiBS0KihTm0H(fQDHD6qR5yGO813yrgAnAsKJwg6q)cfRONY(gROdoPbJdqmzGqwPlv(pLQk6OLHo0xQUOljxJKll6YX8VR5yG1pIs23ylu7cfFHbVqYZqGHOGC)j6mmsq2yPjroAzOd9lu7cbnoAJ1dyKSWGOSqQTqbHfcAC0gRhWizHbrzHAUqXk6PSVXk6HU0JXbigWhRpjw6sLAOsvfD0Yqh6lvx0LKRrYLf9GxOhdFaa8a(8kQO18x9c1UqXxiOXrBSEaJKf(JYcPFHAxi5ziWquqEdcJQPYXAs2ilgWNxrfTMJwg6q)cfewiOXrBSEaJKf(JYc1CHIv0tzFJv0d4ZROIwx6sLbqPQIoAzOd9LQl6PSVXk6Y05IPSVXIUJ1fD3X6OLQyrh4SJbcjSsxQK6uQQOJwg6qFP6IUKCnsUSOdAC0gRhWizHbrzHAw0tzFJv0bN0GXbiMmqiR0LkP)RsvfD0Yqh6lvx0LKRrYLfDqJJ2y9agjlmiklKAf9u23yf9qx6X4aed4J1NelDPs6PVuvrhTm0H(s1fDj5AKCzrp4f6XWhaapGpVIkAn)vx0tzFJv0d4ZROIwx6sL0RzPQIEk7BSIoOuvfjXbicMKnOIoAzOd9LQlDPs6PwPQIEk7BSIUK8yPhjrwtoAWIoAzOd9LQlDPs6RqPQIEk7BSIEsKPHXEie06IoAzOd9LQlDPs6)OuvrpL9nwrxogdLKSVXk6OLHo0xQU0LUOJSiajwpJ7mLsvLkPVuvrhTm0H(s1f9u23yfDz6CXu23yr3X6IUKCnsUSOdAC0gRhWizHuw4hluqyHEm8baWbolDrckPzSZu4V6fkiSWWhaaxsES0J8x9c1UWWhaaxsES0JCwNsAwyqlK(Vk6UJ1rlvXIoWzhdesyLUuPMLQk6OLHo0xQUOljxJKll6HpaaodjznOtL)Ql6PSVXk6Istd)ogiKWIGsvvKu6sLuRuvrhTm0H(s1fDj5AKCzrN8meyikixuAkVK4zr1rfT(PYrldDOVONY(gROdkvvrsCaIGjzdQ0LkRqPQIoAzOd9LQl6sY1i5YIoOXrBSEaJKfgeLfsTIEk7BSIEOl9yCaIb8X6tILUu5hLQk6OLHo0xQUOljxJKll6bVqpg(aa4b85vurR5V6IEk7BSIEaFEfv06sxQ8Fkvv0tzFJv0bLQQijoarWKSbv0rldDOVuDPlvQHkvv0rldDOVuDrxsUgjxw0LZ48dyJljpw6rsK1KJgKlbLefKfbiPSVXs3c)rzH0Z1qFSqTlu8fcAC0gRhWizHbrzHAUqbHfcAC0gRhWizHbrzHuBHAxOCgNFaB8qx6X4aed4J1Ne5eunpJTWFlur6xyfxOMluqyHGghTX6bmswiLfwHfQDHYzC(bSXdDPhJdqmGpwFsKtq18m2c)TqfPFHvCHAUqTluoJZpGnEaFEfv0AobvZZyl83cvK(fwXfQ5cfRONY(gROljpw6rsK1KJgS0LkdGsvfD0Yqh6lvx0LKRrYLf9GxyNo0AoWzPlsqjnJDMchTm0H(fQDHYzC(bSXXar5RVXIm0A0KiNGQ5zSfgeLfQi9lSIlKAlu7cfFHbVq5icT0Aon0sU0wOGWcLZ48dyJ7prNHXECoobvZZylmOfsDwOyf9u23yfDgsYAqNAPlvsDkvv0rldDOVuDrpL9nwrxMoxmL9nw0DSUO7owhTufl6aNDmqiHv6sL0)vPQIEk7BSIUK8yPhjrwtoAWIoAzOd9LQlDPs6PVuvrhTm0H(s1fDj5AKCzrh04OnwpGrYcdIYcRqrpL9nwrpjY0WypecADPlvsVMLQk6OLHo0xQUOljxJKll6IVWGxyNo0AoWzPlsqjnJDMchTm0H(fkiSq5mo)a24aNLUibL0m2zkCcQMNXwyquwOI0VWkUqQTqXwO2fk(cdEHD6qR5yGO813yrgAnAsKJwg6q)cfewOCgNFaBCmqu(6BSidTgnjYjOAEgBHbrzHks)cR4cP2cfewyNo0AoWzPlsqjnJDMchTm0H(fk2c1UqXxyWluoIqlTMtdTKlTfkiSq5mo)a24(t0zyShNJtq18m2cdAHuNfkwrpL9nwrNHKSg0Pw6sL0tTsvf9u23yfD5ymusY(gROJwg6qFP6sx6sx0ZxdAifD9tL6lDPlfa]] )


end
