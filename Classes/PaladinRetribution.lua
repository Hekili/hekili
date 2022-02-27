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


    spec:RegisterPack( "Retribution", 20220226, [[dG0j9bqibQhHKkztKuFcPYOqQ6ueOvjkXRufAwQcUfsQu1Uq1VufzyiHogjPLrapdjLPjkPRHeSnvrX3ijKXjG4CQIsRtvunpb4EG0(qsoOaszHIs9qKu1frsLYgrsLkFuajDsKuHvIentsc2POWpfqQmubKQwksQONsktvu0xfqIXss0Ef6VImyGdlzXc6XenzQ6YqBguFMunAvPtRYQfq9AKIztLBtIDt53kgUO64KeQLJ45OmDPUUQA7e03bX4fiNhP08j0(v6OQXmJA(QXygcqrbeGIciWZWfGAu7zunQ10MJrT8sstPJrnRuWOg1j2Kl833yrT8Iw3u(yMrn28jsmQf1c)NRPoSyyuZxngZqakkGauuabEgUauJAuJAptuJLJYygQikg1EpVhTyyuZJmzuJ6eBYf(7BSfeOVCL)SLsQ7WqYVi0UabOWdlqakkGalLlLu)Bz6i75lLu3VaQdRrDs14cmeYcYj3qUM2fWYDxVayYOSaTtH65rTCYaFomQrDrDTaQtSjx4VVXwqG(Yv(ZwkPUOUwa1Dyi5xeAxGau4HfiaffqGLYLsQlQRfq9VLPJSNVusDrDTaQ7xa1H1OoPACbgczb5KBixt7cy5URxamzuwG2Pq98LYLYs23ymEobLJsy1qZN(gBPSK9ngJNtq5Oew9JqFk0Hm2z6PboX(kkizPSK9ngJNtq5Oew9JqFk0Hm2z6Pbov)(RylLLSVXy8CckhLWQFe6tHoKXotpnWjiN1izPSK9ngJNtq5Oew9JqFk0Hm2z6PboXYjNPVuwY(gJXZjOCucR(rOpb7q2RKuW9dhmu28DHN555Fw)Dycj)8(gtuKnFx4zEUWXv95WeBCcrRxklzFJX45euokHv)i0NkISmm1dHGw)WbdTlhAnh(SYLiOKMXotNJwf6qV6UCO1CgsQ83tHJwf6q)szj7BmgpNGYrjS6hH(e79qNpnWjHOPJLjXLYLsQlQRfqDliu(B0VauisODb9PGlOFXfuYEil4ylOewNRcDiFPSK9ngdkbd)0GlLLSVXypc9jz5CPs23yj3X6hSsbHkNX5higBPSK9ng7rOpjlNlvY(gl5ow)GvkiuKLGjP8zCNP)WbdL(Gj15tOq0AE59mog0XAMOiPoFcfIwZlVNX)5IIK68juiAnV8Eg)SaEwrrsD(ekeTMxEpJFgvuJIcQM(UCO1Cmiu(7BSedTgnjQwoJZpqmogek)9nwIHwJMe5euPoJfWZQMLJoxQlIo2mU)eEgMy9qucGcIID5qR5WNvUebL0m2z6QLZ48deJdFw5seusZyNPZjOsDglGNvq1Dr0XM3NcM6j5pKQazPSK9ng7rOpjlNlvY(gl5ow)GvkiuKLGjPs2Nq8bwtozdv1hoyOEm8ddZXGq5VVXsm0A0Ki)Nlk6XWpmmh(SYLiOKMXotN)ZxklzFJXEe6tYY5sLSVXsUJ1pyLccvhnKu9qylLlLLSVXyC5mo)aXyqZN(g7HdgA4hgMxcrt)m9ees1V8FUOy4hgMljFw5r(pxD4hgMljFw5roRljnqvLIIIHdJPg(0F7ebvQZybiafwklzFJX4YzC(bIXEe6tUt)TzPa)96kO1pCWqz5OZL6IOJnJ7o93MLc83RRGwtfubefdMuNpHcrR5L3Z4yqhRzIIK68juiAnV8Eg)mQuruquKuNpHcrR5L3Z4)8LYs23ymUCgNFGyShH(e8rWq3m(hoyO0h(HH5Lq00ptpbHu9l)Nlkg(HH5sYNvEK)Zvh(HH5sYNvEKZ6ssduvPOGQdUlhAnhdcL)(glXqRrtIlLLSVXyC5mo)aXypc9jyhYELKcUF4GHYMVl8mpp)Z6Vdti5N33yIIS57cpZZfoUQphMyJtiA9dN1iH8Z70POG(RAeQQpCwJeYpVt6UjSCqv9HZAKq(5D6GHYMVl8mpx44Q(CyInoHO1lLLSVXyC5mo)aXypc9j27HoFAGtcrthltIpCWqPp4UCO1Cmiu(7BSedTgnjkkkNX5highdcL)(glXqRrtICcQuNXcGcciOA4t)TteuPoJrLQuyPSK9ngJlNX5hig7rOpf6qg7m90aNyFffKSuwY(gJXLZ48deJ9i0NcDiJDMEAGt1V)k2szj7BmgxoJZpqm2JqFk0Hm2z6Pbob5SgjlLLSVXyC5mo)aXypc9PqhYyNPNg4elNCM(szj7BmgxoJZpqm2JqF6ZW01OYdwPGqpJjj)UcDysf)lR)kjpk8K4dhm0WpmmVeIM(z6jiKQF5)CrXWpmmxs(SYJ8FU6Wpmmxs(SYJCwxsAGQkfffdhgtn8P)2jcQuNXcGAuCPSK9ngJlNX5hig7rOp9zy6Au5bRuqOJqKa5fDkNPNYhiijjj0Y6Y9Wbdn8ddZlHOPFMEccP6x(pxum8ddZLKpR8i)NRo8ddZLKpR8iN1LKgOQsrrXWHXudF6VDIGk1zSauLclLLSVXyC5mo)aXypc9PpdtxJkpyLcc1xeAuMXsEusts4qk510(Wbdn8ddZlHOPFMEccP6x(pxum8ddZLKpR8i)NRo8ddZLKpR8iN1LKgOQsrrXWHXudF6VDIGk1zSaeGIlLLSVXyC5mo)aXypc9PpdtxJkpyLccvPKvibtSxe7KYNDYhoyOHFyyEjen9Z0tqiv)Y)5IIHFyyUK8zLh5)C1HFyyUK8zLh5SUK0avvkkkgomMA4t)TteuPoJfGauCPSK9ngJlNX5hig7rOp9zy6Au5bRuqOW1310MKZ3AKOGf7tWhoyOb3LdTMljFw5rrXWpmmxs(SYJ8FUOy4WyQHp93orqL6mwauJIlLLSVXyC5mo)aXypc9PpdtxJkpyLcc1tWYdFemjezm0TuwY(gJXLZ48deJ9i0N(mmDnQ8GvkiugnFhniHLGCM(szj7BmgxoJZpqm2JqF6ZW01OYdwPGq1jNssoEmOLYs23ymUCgNFGyShH(0NHPRrLhSsbHQGkdH20aNYlwNyNXwklzFJX4YzC(bIXEe6tFgMUgvEWkfeklViysbRo9odnlLLSVXyC5mo)aXypc9PpdtxJkpyLccLvoHLo6tWF2nwQuYDh8HKLYs23ymUCgNFGyShH(0NHPRrLhSsbHQFL1PHyLcAD5s5yrClLLSVXyC5mo)aXypc9PpdtxJkpyLccfYzEMSijiVyZ6XWLYs23ymUCgNFGyShH(0NHPRrLhSsbHYKfHLg4emPAKyLlXAYbJlLLSVXyC5mo)aXypc9PpdtxJkpyLccv(wNXsdCYpkNv9n2szj7BmgxoJZpqm2JqF6ZW01OYdwPGqXI0VHeSObjS0PKxYEPSK9ngJlNX5hig7rOp9zy6Au5bRuqOVyr60aN6xmXGueLhoyObh(HH5Lq00ptpbHu9l)NRo8ddZLKpR8i)NVuwY(gJXLZ48deJ9i0N(mmDnQ8GvkiuDx5VQhclfwED8HdgA4hgMxcrt)m9ees1V8FUOy4hgMljFw5r(pxD4hgMljFw5roRljnubvvkkkkNX5higVeIM(z6jiKQF5euPoJrvwPGOOCgNFGyCj5ZkpYjOsDgJQSsHLYs23ymUCgNFGyShH(0NHPRrf2dhm0WpmmVeIM(z6jiKQF5)CrXWpmmxs(SYJ8FU6Wpmmxs(SYJCwxsAOcQQuCPSK9ngJlNX5hig7rOpvcrt)m9ees1VpCWqP)DC0MYhiiHkOzvDFkyauqu8DC0MYhiiHkOutn99PGurbrrY3q4HOJ8(ftkL(XAs1ilf4VxxbTwqrX3XrBkFGGeQGkGAY3q4HOJCHLP)lINLugf06VI6UCO1C4ZkxIGsAg7mDrXUCO183XrBQeIMosulNX5hig)DC0MkHOPJeobvQZyqPOGQPp4UCO1CgsQ83trum4UCO1C4ZkxIGsAg7mDrr5mo)aX4mKu5VNcNGk1zmQOOGlLLSVXyC5mo)aXypc9jj5Zkp(Wbd9DC0MYhiiHkOzvDFkyauqu8DC0MYhiiHkOutDFkivuyPSK9ngJlNX5hig7rOpvSx0sVLZnqwklzFJX4YzC(bIXEe6tVJJ2ujenDK8WbdTpfm1t6nxhkfv)ooAt5deKeaubutF4hgMxcrt)m9ees1V8FUOyxo0AUK8zLhvtVCgNFGyCj5ZkpYjOsDgdkfffd)WWCj5ZkpY)5ckkgomMA4t)TteuPoJfGauuWLYs23ymUCgNFGyShH(e8zLlrqjnJDM(dhmu6FhhTP8bcsOcAwv3NcgqGik(ooAt5deKqfuQPM((uqQGgiIISC05sDr0XMX9NWZWeRhIcvqfqTCeIwznNgAjxzckOA5mo)aX4Lq00ptpbHu9lNGk1zmQ0LE19PGPEsV56qPOA6dUlhAnNHKk)9uefd)WWCgsQ83tH)Zfun9btQZNqHO18Y7zCmOJ1mrrsD(ekeTMxEpJ)Zffj15tOq0AE59m(zuLvkkOA6do8ddZlHOPFMEccP6x(pxu8DC0MYhiibkfefLZ48deJ)wkkijnWjiKQF5euPoJjkYYrNl1frhBg3FcpdtSEikubva1YriAL1CAOLCLj4s5szj7BmghzjysQK9jeHcFem0nJFPSK9ngJJSemjvY(eIpc9jz5CPs23yj3X6hSsbHcF2XErc7Hdg674OnLpqqcukik6XWpmmpWFVUcAn)Nlk6XWpmmh(SYLiOKMXotN)ZvtVhd)WWC4ZkxIGsAg7mDobvQZybOl9CLkirrwo6CPUi6yZ4(t4zyI1drHkOcOo4UCO1Cmiu(7BSedTgnjkOOOhd)WWCmiu(7BSedTgnjY)5Q9y4hgMJbHYFFJLyO1OjrobvQZybOl9CLkOLYs23ymoYsWKuj7ti(i0N8NWZWupo3szj7BmghzjysQK9jeFe6tcltf)p2lsyP3srbjlLLSVXyCKLGjPs2Nq8rOpbPObtdCQyVi7Hdg674OnLpqqsaqfqn9Em8ddZHpRCjckPzSZ05)C1Em8ddZHpRCjckPzSZ05euPoJfGU0Nfbuhm5Bi8q0rU)eEgMiiBSYKOOOhd)WWCmiu(7BSedTgnjY)5Q9y4hgMJbHYFFJLyO1OjrobvQZybOl9IISC05sDr0XMX9NWZWeRhIcvqPGAY3q4HOJC)j8mmrq2yLjr1D5qR5yqO833yjgAnAsuWLYs23ymoYsWKuj7ti(i0NcDLhtdCkWFwFs8HdgQCm))Aogu(NOx9nMA6dM8neEi6i3FcpdteKnwzsu974OnLpqqsaqPMO474OnLpqqsaqfqWLYs23ymoYsWKuj7ti(i0Nc83RRGw)Wbdnypg(HH5b(71vqR5)C10)ooAt5deKqfuvvt(gcpeDK3VysP0pwtQgzPa)96kO1IIVJJ2u(abjubvabxklzFJX4ilbtsLSpH4JqFswoxQK9nwYDS(bRuqOWNDSxKWwklzFJX4ilbtsLSpH4JqFcsrdMg4uXEr2dhm03XrBkFGGKaGkWszj7BmghzjysQK9jeFe6tHUYJPbof4pRpj(Wbd9DC0MYhiijaOuBPSK9ngJJSemjvY(eIpc9Pa)96kO1pCWqd2JHFyyEG)EDf0A(pFPSK9ngJJSemjvY(eIpc9P3srbjPbobHu97szj7BmghzjysQK9jeFe6tsYNvEKKyn5ObxklzFJX4ilbtsLSpH4JqFQiYYWupecA9szj7BmghzjysQK9jeFe6tYXyOKu9n2s5szj7BmghzjyskFg3z6qziPYFpLhoyOVJJ2u(abjqPGA6dUlhAnh(SYLiOKMXotxuuoJZpqmo8zLlrqjnJDMoNGk1zSaGQl9zHAIIYzC(bIXHpRCjckPzSZ05euPoJrLCgNFGycQM(G7YHwZXGq5VVXsm0A0KOOOCgNFGyCmiu(7BSedTgnjYjOsDglaO6sFwOMOOCgNFGyCmiu(7BSedTgnjYjOsDgJk5mo)aXef7YHwZHpRCjckPzSZ0fun9blhHOvwZPHwYvMOOCgNFGyC)j8mm1JZXjOsDglGNvuuoJZpqmU)eEgM6X54euPoJrLCgNFGycUuwY(gJXrwcMKYNXDM(JqFswoxQK9nwYDS(bRuqOWNDSxKWE4GH(ooAt5deKaLcIIEm8ddZHpRCjckPzSZ05)CrXWpmmxs(SYJ8FU6Wpmmxs(SYJCwxsAcqvkUuwY(gJXrwcMKYNXDM(JqFsyzQ4)XErcl9wkki5HdgA4hgMZqsL)Ek8F(szj7BmghzjyskFg3z6pc9P3srbjPbobHu97dhmuY3q4HOJCHLP)lINLugf06VYszj7BmghzjyskFg3z6pc9jifnyAGtf7fzpCWqFhhTP8bcscaQaQzyNch7Z49HebcKuwZLlLLSVXyCKLGjP8zCNP)i0NcDLhtdCkWFwFs8Hdg674OnLpqqsaqP2szj7BmghzjyskFg3z6pc9Pa)96kO1pCWqd2JHFyyEG)EDf0A(pFPSK9ngJJSemjLpJ7m9hH(0BPOGK0aNGqQ(DPSK9ngJJSemjLpJ7m9hH(KK8zLhjjwtoAWhoyOYzC(bIXLKpR8ijXAYrdYLVfrhzjysj7BSYrfuv5QikOM(3XrBkFGGKaGkGO474OnLpqqsaqPMA5mo)aX4HUYJPbof4pRpjYjOsDgJkDPplcik(ooAt5deKanRQLZ48deJh6kpMg4uG)S(KiNGk1zmQ0L(SiGA5mo)aX4b(71vqR5euPoJrLU0NfbeCPSK9ngJJSemjLpJ7m9hH(edjv(7P8Wbdn4UCO1C4ZkxIGsAg7mD1YzC(bIXXGq5VVXsm0A0KiNGk1zSaGQl9zHAQPpy5ieTYAon0sUYefLZ48deJ7pHNHPECoobvQZyb8ScUuwY(gJXrwcMKYNXDM(JqFswoxQK9nwYDS(bRuqOWNDSxKWwklzFJX4ilbts5Z4ot)rOpjjFw5rsI1KJgCPSK9ngJJSemjLpJ7m9hH(urKLHPEie06hoyOVJJ2u(abjbanRlLLSVXyCKLGjP8zCNP)i0NyiPYFpLhoyO0hCxo0Ao8zLlrqjnJDMUOOCgNFGyC4ZkxIGsAg7mDobvQZybavx6Zc1eun9b3LdTMJbHYFFJLyO1Ojrrr5mo)aX4yqO833yjgAnAsKtqL6mwaq1L(SqnrXUCO1C4ZkxIGsAg7mDbvtFWYriAL1CAOLCLjkkNX5hig3Fcpdt94CCcQuNXc4zfCPSK9ngJJSemjLpJ7m9hH(KCmgkjvFJTuUuwY(gJXHp7yViHbvyrUk0HpyLcc1ZsYI1vOdFqy5(iuwo6CPUi6yZ4(t4zyI1drbQaQdMEY3q4HOJC4Zkxsis8NSff7YHwZjN(BJZNLeIe)jBbffz5OZL6IOJnJ7pHNHjwpefQequm8ddZrLCAjyzP8bcs4)C1b7XWpmmpWFVUcAn)NRo4Wpmm3Fcpdt5Fs(Wq(pFPSK9ngJdF2XErc7rOpXqsL)EkpCWqPxoJZpqmEjen9Z0tqiv)YjOsDgJkvPGOOCgNFGyCj5ZkpYjOsDgJkvPGGQdUlhAnh(SYLiOKMXotxn9b3LdTMJbHYFFJLyO1Ojrrrwo6CPUi6yZ4(t4zyI1drHkOuqq10hmPoFcfIwZlVNXXGowZefj15tOq0AE59m(zuLvkkksQZNqHO18Y7z8Zcqx6ffj15tOq0AE59m(pxq10hSCeIwznNgAjxzIIYzC(bIX9NWZWupohNGk1zSaEwbffHp93orqL6mwaQsb1WN(BNiOsDgJkkikg(HH5sYNvEK)Zvh(HH5sYNvEKZ6sstaQsXLYs23ymo8zh7fjShH(egek)9nwIHwJMeF4GHsF4hgMljFw5rUFGyQLZ48deJljFw5robvQZyuPkfffd)WWCj5ZkpYzDjPHkOutuuoJZpqmEjen9Z0tqiv)YjOsDgJkvPOGQPp4UCO1C4ZkxIGsAg7mDrr5mo)aX4WNvUebL0m2z6CcQuNXOsvkkO6Ui6yZ7tbt9K8hsvGOMLJoxQlIo2mU)eEgMy9qucGclLLSVXyC4Zo2lsypc9j)j8mmX6HO8WbdvyrUk0HCpljlwxHouDWHFyyUWYuX)J9Iew6Tuuqc)NRME6dUlhAnxs(SYJIIYzC(bIXLKpR8iNGk1zmQ0L(SqnbvtFWD5qR5yqO833yjgAnAsuuuoJZpqmogek)9nwIHwJMe5euPoJrLU0NLNruuoJZpqmogek)9nwIHwJMe5euPoJrLU0NLSQ(DC0MYhiiHkOuquSlIo28(uWupj)HbeiIISC05sDr0XMX9NWZWeRhIcvqPGOyWD5qR5mKu5VNIA5mo)aX4yqO833yjgAnAsKtqL6mgv6sFweqq10hCxo0Ao8zLlrqjnJDMUOOCgNFGyC4ZkxIGsAg7mDobvQZyuPl9z5zefLZ48deJdFw5seusZyNPZjOsDgJkDPplzv974OnLpqqcvqPGOyWD5qR5mKu5VNIA5mo)aX4WNvUebL0m2z6CcQuNXOsx6ZIackk2LdTM)ooAtLq00rIA5mo)aX4VJJ2ujenDKWjOsDglaDPplutum8ddZFhhTPsiA6iH)Zffd)WWCj5ZkpY)5Qd)WWCj5ZkpYzDjPjavPOGlLLSVXyC4Zo2lsypc9PgvYDfHLeIe)j7hoyO0hCxo0AUK8zLhffLZ48deJljFw5robvQZyuPl9zHAcQM(G7YHwZXGq5VVXsm0A0KOOOCgNFGyCmiu(7BSedTgnjYjOsDgJkDPplbIOOCgNFGyCmiu(7BSedTgnjYjOsDgJkDPplpJ63XrBkFGGeQGMvrXUi6yZ7tbt9K8hgqGikgCxo0Aodjv(7POwoJZpqmogek)9nwIHwJMe5euPoJrLU0Nfbeun9b3LdTMdFw5seusZyNPlkkNX5high(SYLiOKMXotNtqL6mgv6sFwcerr5mo)aX4WNvUebL0m2z6CcQuNXOsx6ZYZO(DC0MYhiiHkOzvum4UCO1CgsQ83trTCgNFGyC4ZkxIGsAg7mDobvQZyuPl9zrabff7YHwZFhhTPsiA6irTCgNFGy83XrBQeIMos4euPoJfGU0NfQjkg(HH5VJJ2ujenDKW)5IIHFyyUK8zLh5)C1HFyyUK8zLh5SUK0eGQuCPCblLLSVXyCD0qs1dHbvwoxQK9nwYDS(bRuqOWNDSxKWE4GH(ooAt5deKaLcII07XWpmmpWFVUcAn)Nlk(ooAt5deKanRcQo8ddZ9NWZWebzJvMe5)CrXWpmm)DC0MkHOPJe(pFPSK9ngJRJgsQEiShH(KWYuX)J9Iew6TuuqYdhm0GjFdHhIoY9)M2W5B(KEjeDIIb3LdTMdFw5seusZyNPRo4UCO1Cmiu(7BSedTgnjkkcF6VDIGk1zSacKLYs23ymUoAiP6HWEe6tVLIcssdCccP63hoyOKVHWdrh59lMukFkViL(yIIYriAL1CHO1V0sulNX5higVyVOLElNBGWjOsDgJkbuLIlLLSVXyCD0qs1dH9i0NGu0GPbovSxK9Wbd9DC0MYhiijaOcOMHDkCSpJ3hseiqsznxQME5mo)aX4Lq00ptpbHu9lNGk1zmrr5mo)aX4sYNvEKtqL6mMGlLLSVXyCD0qs1dH9i0N8NWZWupo3dhm03XrBkFGGKaGQQ6G9y4hgMh4VxxbTM)ZvtFWD5qR5mKu5VNIOy4hgMZqsL)Ek8FUGQPpysD(ekeTMxEpJJbDSMjksQZNqHO18Y7z8ZOIAuuuKuNpHcrR5L3Z4)CbvhCxo0Ao8zLlrqjnJDMUA6dUlhAnhdcL)(glXqRrtIIIWN(BNiOsDglGaruKLJoxQlIo2mU)eEgMy9quOckfeun9YzC(bIXlHOPFMEccP6xobvQZyIIYzC(bIXLKpR8iNGk1zmbxklzFJX46OHKQhc7rOpf4VxxbT(HdgAWEm8ddZd83RRGwZ)5QP)DC0MYhiiHkOQQM8neEi6iVFXKsPFSMunYsb(71vqRffFhhTP8bcsOcQacUuwY(gJX1rdjvpe2JqFcsrdMg4uXEr2dhmu6FhhTP8bcsGsrrX3XrBkFGGKaGkGA5mo)aX4HUYJPbof4pRpjYjOsDgJkDPplciOA6dMuNpHcrR5L3Z4yqhRzIIK68juiAnV8Eg)mQeGIIIK68juiAnV8Eg)NlOA6dUlhAnNHKk)9uefLZ48deJZqsL)EkCcQuNXOIcIIYriAL1CAOLCLjOA6dUlhAnhdcL)(glXqRrtIIIYzC(bIXXGq5VVXsm0A0KiNGk1zmQuLcIIDr0XM3NcM6j5pmGaruKLJoxQlIo2mU)eEgMy9quOckfeun9b3LdTMdFw5seusZyNPlkkNX5high(SYLiOKMXotNtqL6mgvQsbrr4t)TteuPoJfqGiOA6LZ48deJxcrt)m9ees1VCcQuNXefLZ48deJljFw5robvQZycUuwY(gJX1rdjvpe2JqFswoxQK9nwYDS(bRuqOWNDSxKWE4GH(ooAt5deKqfuQPo8ddZLKpR8i)NRo8ddZLKpR8iN1LKMauLIlLLSVXyCD0qs1dH9i0NcDLhtdCkWFwFs8HdgQCm))Aogu(NOx9nM63XrBkFGGKaGsTLYs23ymUoAiP6HWEe6tb(71vqRF4GHgShd)WW8a)96kO18F(szj7BmgxhnKu9qypc9P3srbjPbobHu97szj7BmgxhnKu9qypc9Pqx5X0aNc8N1NeF4GH(ooAt5deKeauQTuwY(gJX1rdjvpe2JqFswoxQK9nwYDS(bRuqOWNDSxKWE4GHsFxeDS5Vy56xEUSdaQauuum8ddZlHOPFMEccP6x(pxum8ddZLKpR8i)Nlkg(HH5OsoTeSSu(abj8FUGlLLSVXyCD0qs1dH9i0NKJXqjP6BShoyOblhJHss13y8FUAwo6CPUi6yZ4(t4zyI1drHkOcSuwY(gJX1rdjvpe2JqFss(SYJKeRjhn4dhmu5mo)aX4sYNvEKKyn5Ob5Y3IOJSemPK9nw5OcQQCvefut)74OnLpqqsaqfqu8DC0MYhiijaOutTCgNFGy8qx5X0aNc8N1Ne5euPoJrLU0NfbefFhhTP8bcsGMv1YzC(bIXdDLhtdCkWFwFsKtqL6mgv6sFweqTCgNFGy8a)96kO1CcQuNXOsx6ZIacUuwY(gJX1rdjvpe2JqFswoxQK9nwYDS(bRuqOWNDSxKWwklzFJX46OHKQhc7rOpjhJHss13ypCWqdwogdLKQVX4)8LYs23ymUoAiP6HWEe6tsYNvEKKyn5ObxklzFJX46OHKQhc7rOpvezzyQhcbTEPSK9ngJRJgsQEiShH(KCmgkjvFJf1eIe2nwmdbOOacqrbuvGOgKIyNPZIAbkbAuNzqDKrG6ZxWcY8fxWPKpKEbWdzb0PJgsQEim6wabvX)JG(fWgfCb1VhLQr)cKVLPJm(sPkCgUabE(cO(XeIKg9lGUUCO1Cvs3c6zb01LdTMRsoAvOd90Ta6fiib5lLQWz4ce45lG6htisA0Va6iFdHhIoYvjDlONfqh5Bi8q0rUk5OvHo0t3cOx1GeKVuQcNHlGApFbu)ycrsJ(fqh5Bi8q0rUkPBb9Sa6iFdHhIoYvjhTk0HE6wa9QgKG8Lsv4mCbu45lG6htisA0Va66YHwZvjDlONfqxxo0AUk5OvHo0t3cONAbjiFPufodxWZ88fq9Jjejn6xaDKVHWdrh5QKUf0ZcOJ8neEi6ixLC0Qqh6PBb0RAqcYxkvHZWfOIE(cO(XeIKg9lGUUCO1Cvs3c6zb01LdTMRsoAvOd90Ta6PwqcYxkxkduc0OoZG6iJa1NVGfK5lUGtjFi9cGhYcOZJW1310TacQI)hb9lGnk4cQFpkvJ(fiFlthz8Lsv4mCbu75lG6htisA0Va66YHwZvjDlONfqxxo0AUk5OvHo0t3cOxGGeKVuUugOeOrDMb1rgbQpFbliZxCbNs(q6fapKfqxobLJsy10TacQI)hb9lGnk4cQFpkvJ(fiFlthz8Lsv4mCbpZZxa1pMqK0OFb0XMVl8mpxL0TGEwaDS57cpZZvjhTk0HE6wa9QgKG8Lsv4mCbpZZxa1pMqK0OFb0XMVl8mpxL0TGEwaDS57cpZZvjhTk0HE6wq1lG6wGovyb0RAqcYxkxkduc0OoZG6iJa1NVGfK5lUGtjFi9cGhYcOtoJZpqmgDlGGQ4)rq)cyJcUG63Js1OFbY3Y0rgFPufodxa1E(cO(XeIKg9lGUUCO1Cvs3c6zb01LdTMRsoAvOd90TGQxa1TaDQWcOx1GeKVuQcNHliRpFbu)ycrsJ(fqhB(UWZ8Cvs3c6zb0XMVl8mpxLC0Qqh6PBb0RAqcYxkvHZWfK1NVaQFmHiPr)cOJnFx4zEUkPBb9Sa6yZ3fEMNRsoAvOd90TGQxa1TaDQWcOx1GeKVuQcNHlGcpFbu)ycrsJ(fqxxo0AUkPBb9Sa66YHwZvjhTk0HE6wa9QgKG8Lsv4mCbQM1NVaQFmHiPr)cORlhAnxL0TGEwaDD5qR5QKJwf6qpDlGEvdsq(sPkCgUabE2NVaQFmHiPr)cORlhAnxL0TGEwaDD5qR5QKJwf6qpDlG(SgKG8Lsv4mCbc8SpFbu)ycrsJ(fqh5Bi8q0rUkPBb9Sa6iFdHhIoYvjhTk0HE6wa9ceKG8Lsv4mCbutGNVaQFmHiPr)cORlhAnxL0TGEwaDD5qR5QKJwf6qpDlGEvdsq(sPkCgUaQrTNVaQFmHiPr)cORlhAnxL0TGEwaDD5qR5QKJwf6qpDlGEvdsq(s5szGsGg1zguhzeO(8fSGmFXfCk5dPxa8qwaDWNDSxKWOBbeuf)pc6xaBuWfu)EuQg9lq(wMoY4lLQWz4cu95lG6htisA0Va66YHwZvjDlONfqxxo0AUk5OvHo0t3cOx1GeKVuQcNHlq1NVaQFmHiPr)cOJ8neEi6ixL0TGEwaDKVHWdrh5QKJwf6qpDlGEvdsq(sPkCgUabE(cO(XeIKg9lGUUCO1Cvs3c6zb01LdTMRsoAvOd90Ta6fiib5lLQWz4cO2Zxa1pMqK0OFb01LdTMRs6wqplGUUCO1CvYrRcDONUfqVQbjiFPufodxqwF(cO(XeIKg9lGUUCO1Cvs3c6zb01LdTMRsoAvOd90Ta6FMGeKVuQcNHlGcpFbu)ycrsJ(fqxxo0AUkPBb9Sa66YHwZvjhTk0HE6wa9ptqcYxkxkduc0OoZG6iJa1NVGfK5lUGtjFi9cGhYcOdzjysQK9jePBbeuf)pc6xaBuWfu)EuQg9lq(wMoY4lLQWz4ce45lG6htisA0Va66YHwZvjDlONfqxxo0AUk5OvHo0t3cOx1GeKVuQcNHlGcpFbu)ycrsJ(fqxxo0AUkPBb9Sa66YHwZvjhTk0HE6wa9QgKG8Lsv4mCbu45lG6htisA0Va6iFdHhIoYvjDlONfqh5Bi8q0rUk5OvHo0t3cOxGGeKVuQcNHl4zE(cO(XeIKg9lGoY3q4HOJCvs3c6zb0r(gcpeDKRsoAvOd90Ta6vnib5lLQWz4curpFbu)ycrsJ(fqh5Bi8q0rUkPBb9Sa6iFdHhIoYvjhTk0HE6wa9QgKG8LYLYaLanQZmOoYiq95lybz(Il4uYhsVa4HSa6qwcMKYNXDMoDlGGQ4)rq)cyJcUG63Js1OFbY3Y0rgFPufodxGQpFbu)ycrsJ(fqxxo0AUkPBb9Sa66YHwZvjhTk0HE6wa9ulib5lLQWz4cY6Zxa1pMqK0OFb0r(gcpeDKRs6wqplGoY3q4HOJCvYrRcDONUfu9cOUfOtfwa9QgKG8Lsv4mCbQsXNVaQFmHiPr)cORlhAnxL0TGEwaDD5qR5QKJwf6qpDlGEvdsq(sPkCgUavZ6Zxa1pMqK0OFb01LdTMRs6wqplGUUCO1CvYrRcDONUfqp1csq(s5sj1Hs(qA0Vav0ckzFJTa3XAgFPmQ5owZIzg10rdjvpewmZygQgZmQHwf6qFm7OMKCnsUkQ9ooAt5deKSaOlGclquCb0Vapg(HH5b(71vqR5)8fikUG3XrBkFGGKfaDbzDbcUa1li8ddZ9NWZWebzJvMe5)8fikUGWpmm)DC0MkHOPJe(ppQvY(glQjlNlvY(gl5owh1ChRtwPGrn4Zo2lsyXoMHaXmJAOvHo0hZoQjjxJKRIAbVaY3q4HOJC)VPnC(MpPxcrhhTk0H(fikUGGxqxo0Ao8zLlrqjnJDMohTk0H(fOEbbVGUCO1Cmiu(7BSedTgnjYrRcDOFbIIla(0F7ebvQZyliGfeirTs23yrnHLPI)h7fjS0BPOGKyhZGAXmJAOvHo0hZoQjjxJKRIAKVHWdrh59lMukFkViL(yC0Qqh6xGO4cKJq0kR5crRFPLSa1lqoJZpqmEXErl9wo3aHtqL6m2cOAbcOkfJALSVXIAVLIcssdCccP63yhZiRXmJAOvHo0hZoQjjxJKRIAVJJ2u(abjliaOlqGfOEbmStHJ9z8(qIabskR5YfOEb0Va5mo)aX4Lq00ptpbHu9lNGk1zSfikUa5mo)aX4sYNvEKtqL6m2cemQvY(glQbPObtdCQyVil2XmOqmZOgAvOd9XSJAsY1i5QO274OnLpqqYcca6cuDbQxqWlWJHFyyEG)EDf0A(pFbQxa9li4f0LdTMZqsL)EkC0Qqh6xGO4cc)WWCgsQ83tH)ZxGGlq9cOFbbVasD(ekeTMxEpJJbDSMTarXfqQZNqHO18Y7z8ZwavlGAuCbIIlGuNpHcrR5L3Z4)8fi4cuVGGxqxo0Ao8zLlrqjnJDMohTk0H(fOEb0VGGxqxo0Aogek)9nwIHwJMe5OvHo0VarXfaF6VDIGk1zSfeWccKfikUawo6CPUi6yZ4(t4zyI1drzbubDbuybcUa1lG(fiNX5higVeIM(z6jiKQF5euPoJTarXfiNX5higxs(SYJCcQuNXwGGrTs23yrn)j8mm1JZf7ygptmZOgAvOd9XSJAsY1i5QOwWlWJHFyyEG)EDf0A(pFbQxa9l4DC0MYhiizbubDbQUa1lG8neEi6iVFXKsPFSMunYsb(71vqR5OvHo0VarXf8ooAt5deKSaQGUabwGGrTs23yrTa)96kO1XoMHkkMzudTk0H(y2rnj5AKCvuJ(f8ooAt5deKSaOlGIlquCbVJJ2u(abjliaOlqGfOEbYzC(bIXdDLhtdCkWFwFsKtqL6m2cOAb6s)cYYceybcUa1lG(fe8ci15tOq0AE59mog0XA2cefxaPoFcfIwZlVNXpBbuTabO4cefxaPoFcfIwZlVNX)5lqWfOEb0VGGxqxo0Aodjv(7PWrRcDOFbIIlqoJZpqmodjv(7PWjOsDgBbuTakSarXfihHOvwZPHwYv2ceCbQxa9li4f0LdTMJbHYFFJLyO1OjroAvOd9lquCbYzC(bIXXGq5VVXsm0A0KiNGk1zSfq1cuLclquCbDr0XM3NcM6j5pCbbSGazbIIlGLJoxQlIo2mU)eEgMy9quwavqxafwGGlq9cOFbbVGUCO1C4ZkxIGsAg7mDoAvOd9lquCbYzC(bIXHpRCjckPzSZ05euPoJTaQwGQuybIIla(0F7ebvQZyliGfeilqWfOEb0Va5mo)aX4Lq00ptpbHu9lNGk1zSfikUa5mo)aX4sYNvEKtqL6m2cemQvY(glQbPObtdCQyVil2XmcKyMrn0Qqh6Jzh1KKRrYvrT3XrBkFGGKfqf0fqTfOEbHFyyUK8zLh5)8fOEbHFyyUK8zLh5SUK0SGawGQumQvY(glQjlNlvY(gl5owh1ChRtwPGrn4Zo2lsyXoMXZgZmQHwf6qFm7OMKCnsUkQjhZ)VMJbL)j6vFJTa1l4DC0MYhiizbbaDbulQvY(glQf6kpMg4uG)S(KySJzOkfJzg1qRcDOpMDutsUgjxf1cEbEm8ddZd83RRGwZ)5rTs23yrTa)96kO1XoMHQQgZmQvY(glQ9wkkijnWjiKQFJAOvHo0hZo2XmuvGyMrn0Qqh6Jzh1KKRrYvrT3XrBkFGGKfea0fqTOwj7BSOwOR8yAGtb(Z6tIXoMHQulMzudTk0H(y2rnj5AKCvuJ(f0frhB(lwU(LNl7fea0fiafxGO4cc)WW8siA6NPNGqQ(L)ZxGO4cc)WWCj5ZkpY)5lquCbHFyyoQKtlbllLpqqc)NVabJALSVXIAYY5sLSVXsUJ1rn3X6Kvkyud(SJ9IewSJzOAwJzg1qRcDOpMDutsUgjxf1cEbYXyOKu9ng)NVa1lGLJoxQlIo2mU)eEgMy9quwavqxGarTs23yrn5ymusQ(gl2XmuLcXmJAOvHo0hZoQjjxJKRIAYzC(bIXLKpR8ijXAYrdYLVfrhzjysj7BSYTaQGUav5QikSa1lG(f8ooAt5deKSGaGUabwGO4cEhhTP8bcswqaqxa1wG6fiNX5higp0vEmnWPa)z9jrobvQZylGQfOl9lillqGfikUG3XrBkFGGKfaDbzDbQxGCgNFGy8qx5X0aNc8N1Ne5euPoJTaQwGU0VGSSabwG6fiNX5higpWFVUcAnNGk1zSfq1c0L(fKLfiWcemQvY(glQjjFw5rsI1KJgm2Xmu9zIzg1qRcDOpMDuRK9nwutwoxQK9nwYDSoQ5owNSsbJAWNDSxKWIDmdvvrXmJAOvHo0hZoQjjxJKRIAbVa5ymusQ(gJ)ZJALSVXIAYXyOKu9nwSJzOAGeZmQvY(glQjjFw5rsI1KJgmQHwf6qFm7yhZq1NnMzuRK9nwuRiYYWupecADudTk0H(y2XoMHaumMzuRK9nwutogdLKQVXIAOvHo0hZo2XoQ5r4676yMXmunMzuRK9nwuJGHFAWOgAvOd9XSJDmdbIzg1qRcDOpMDuRK9nwutwoxQK9nwYDSoQ5owNSsbJAYzC(bIXIDmdQfZmQHwf6qFm7OMKCnsUkQr)ccEbK68juiAnV8Eghd6ynBbIIlGuNpHcrR5L3Z4)8fikUasD(ekeTMxEpJF2ccybp7cefxaPoFcfIwZlVNXpBbuTaQrXfi4cuVa6xqxo0Aogek)9nwIHwJMe5OvHo0Va1lqoJZpqmogek)9nwIHwJMe5euPoJTGawWZUa1lGLJoxQlIo2mU)eEgMy9quwqalGclquCbD5qR5WNvUebL0m2z6C0Qqh6xG6fiNX5high(SYLiOKMXotNtqL6m2ccybp7ceCbQxqxeDS59PGPEs(dxavliqIALSVXIAYY5sLSVXsUJ1rn3X6KvkyudzjyskFg3z6XoMrwJzg1qRcDOpMDutsUgjxf18y4hgMJbHYFFJLyO1Ojr(pFbIIlWJHFyyo8zLlrqjnJDMo)Nh1yn5KDmdvJALSVXIAYY5sLSVXsUJ1rn3X6KvkyudzjysQK9jeJDmdkeZmQHwf6qFm7Owj7BSOMSCUuj7BSK7yDuZDSozLcg10rdjvpewSJDulNGYrjS6yMXmunMzuRK9nwulF6BSOgAvOd9XSJDmdbIzg1kzFJf1cDiJDMEAGtSVIcsIAOvHo0hZo2XmOwmZOwj7BSOwOdzSZ0tdCQ(9xXIAOvHo0hZo2XmYAmZOwj7BSOwOdzSZ0tdCcYznsIAOvHo0hZo2XmOqmZOwj7BSOwOdzSZ0tdCILtotpQHwf6qFm7yhZ4zIzg1qRcDOpMDutsUgjxf1yZ3fEMNN)z93HjK8Z7BmoAvOd9lquCbS57cpZZfoUQphMyJtiAnhTk0H(Owj7BSOgSdzVssb3XoMHkkMzudTk0H(y2rnj5AKCvuRlhAnh(SYLiOKMXotNJwf6q)cuVGUCO1CgsQ83tHJwf6qFuRK9nwuRiYYWupecADSJzeiXmJALSVXIAS3dD(0aNeIMowMeJAOvHo0hZo2XoQjNX5higlMzmdvJzg1qRcDOpMDutsUgjxf1c)WW8siA6NPNGqQ(L)ZxGO4cc)WWCj5ZkpY)5lq9cc)WWCj5ZkpYzDjPzbqxGQuCbIIliCySfOEbWN(BNiOsDgBbbSabOquRK9nwulF6BSyhZqGyMrn0Qqh6Jzh1KKRrYvrnwo6CPUi6yZ4Ut)TzPa)96kO1lGkOlqGfikUGGxaPoFcfIwZlVNXXGowZwGO4ci15tOq0AE59m(zlGQfOIOWcefxaPoFcfIwZlVNX)5rTs23yrn3P)2SuG)EDf06yhZGAXmJAOvHo0hZoQjjxJKRIA0VGWpmmVeIM(z6jiKQF5)8fikUGWpmmxs(SYJ8F(cuVGWpmmxs(SYJCwxsAwa0fOkfxGGlq9ccEbD5qR5yqO833yjgAnAsKJwf6qFuRK9nwud(iyOBgFSJzK1yMrn0Qqh6Jzh1KKRrYvrn28DHN555Fw)Dycj)8(gJJwf6q)cefxaB(UWZ8CHJR6ZHj24eIwZrRcDOpQDwJeYpVthCuJnFx4zEUWXv95WeBCcrRJAN1iH8Z70POG(RAmQPAuRK9nwud2HSxjPG7O2znsi)8oP7MWYf1un2XmOqmZOgAvOd9XSJAsY1i5QOg9li4f0LdTMJbHYFFJLyO1OjroAvOd9lquCbYzC(bIXXGq5VVXsm0A0KiNGk1zSfeWcOGalqWfOEbWN(BNiOsDgBbuTavPquRK9nwuJ9EOZNg4Kq00XYKySJz8mXmJALSVXIAHoKXotpnWj2xrbjrn0Qqh6Jzh7ygQOyMrTs23yrTqhYyNPNg4u97VIf1qRcDOpMDSJzeiXmJALSVXIAHoKXotpnWjiN1ijQHwf6qFm7yhZ4zJzg1kzFJf1cDiJDMEAGtSCYz6rn0Qqh6Jzh7ygQsXyMrn0Qqh6Jzh1kzFJf1oJjj)UcDysf)lR)kjpk8KyutsUgjxf1c)WW8siA6NPNGqQ(L)ZxGO4cc)WWCj5ZkpY)5lq9cc)WWCj5ZkpYzDjPzbqxGQuCbIIliCySfOEbWN(BNiOsDgBbbSaQrXOMvkyu7mMK87k0Hjv8VS(RK8OWtIXoMHQQgZmQHwf6qFm7Owj7BSO2iejqErNYz6P8bcssscTSUCrnj5AKCvul8ddZlHOPFMEccP6x(pFbIIli8ddZLKpR8i)NVa1li8ddZLKpR8iN1LKMfaDbQsXfikUGWHXwG6faF6VDIGk1zSfeWcuLcrnRuWO2iejqErNYz6P8bcssscTSUCXoMHQceZmQHwf6qFm7Owj7BSOMVi0OmJL8OKMKWHuYRPnQjjxJKRIAHFyyEjen9Z0tqiv)Y)5lquCbHFyyUK8zLh5)8fOEbHFyyUK8zLh5SUK0SaOlqvkUarXfeom2cuVa4t)TteuPoJTGawGaumQzLcg18fHgLzSKhL0KeoKsEnTXoMHQulMzudTk0H(y2rTs23yrnLswHemXErStkF2jJAsY1i5QOw4hgMxcrt)m9ees1V8F(cefxq4hgMljFw5r(pFbQxq4hgMljFw5roRljnla6cuLIlquCbHdJTa1la(0F7ebvQZyliGfiafJAwPGrnLswHemXErStkF2jJDmdvZAmZOgAvOd9XSJALSVXIAW1310MKZ3AKOGf7tWOMKCnsUkQf8c6YHwZLKpR8ihTk0H(fikUGWpmmxs(SYJ8F(cefxq4Wylq9cGp93orqL6m2ccybuJIrnRuWOgC9DnTj58TgjkyX(em2XmuLcXmJAOvHo0hZoQzLcg18eS8WhbtcrgdDrTs23yrnpblp8rWKqKXqxSJzO6ZeZmQHwf6qFm7OMvkyuJrZ3rdsyjiNPh1kzFJf1y08D0GewcYz6XoMHQQOyMrn0Qqh6Jzh1SsbJA6KtjjhpguuRK9nwutNCkj54XGIDmdvdKyMrn0Qqh6Jzh1SsbJAkOYqOnnWP8I1j2zSOwj7BSOMcQmeAtdCkVyDIDgl2Xmu9zJzg1qRcDOpMDuZkfmQXYlcMuWQtVZqtuRK9nwuJLxemPGvNENHMyhZqakgZmQHwf6qFm7OMvkyuJvoHLo6tWF2nwQuYDh8HKOwj7BSOgRCclD0NG)SBSuPK7o4djXoMHaQgZmQHwf6qFm7OMvkyut)kRtdXkf06YLYXI4IALSVXIA6xzDAiwPGwxUuowexSJziGaXmJAOvHo0hZoQzLcg1GCMNjlscYl2SEmmQvY(glQb5mptwKeKxSz9yySJzia1Izg1qRcDOpMDuZkfmQXKfHLg4emPAKyLlXAYbJrTs23yrnMSiS0aNGjvJeRCjwtoym2XmeiRXmJAOvHo0hZoQzLcg1KV1zS0aN8JYzvFJf1kzFJf1KV1zS0aN8JYzvFJf7ygcqHyMrn0Qqh6Jzh1SsbJAyr63qcw0Gew6uYlzh1kzFJf1WI0VHeSObjS0PKxYo2Xme4zIzg1qRcDOpMDuRK9nwu7flsNg4u)IjgKIOe1KKRrYvrTGxq4hgMxcrt)m9ees1V8F(cuVGWpmmxs(SYJ8FEuZkfmQ9IfPtdCQFXedsruIDmdburXmJAOvHo0hZoQvY(glQP7k)v9qyPWYRJrnj5AKCvul8ddZlHOPFMEccP6x(pFbIIli8ddZLKpR8i)NVa1li8ddZLKpR8iN1LKMfqf0fOkfxGO4cKZ48deJxcrt)m9ees1VCcQuNXwavliRuybIIlqoJZpqmUK8zLh5euPoJTaQwqwPquZkfmQP7k)v9qyPWYRJXoMHabsmZOgAvOd9XSJAsY1i5QOw4hgMxcrt)m9ees1V8F(cefxq4hgMljFw5r(pFbQxq4hgMljFw5roRljnlGkOlqvkg1kzFJf1(mmDnQWIDmdbE2yMrn0Qqh6Jzh1KKRrYvrn6xW74OnLpqqYcOc6cY6cuVG(uWfeWcOWcefxW74OnLpqqYcOc6cO2cuVa6xqFk4cOAbuybIIlG8neEi6iVFXKsPFSMunYsb(71vqR5OvHo0VabxGO4cEhhTP8bcswavqxGalq9ciFdHhIoYfwM(ViEwszuqR)kC0Qqh6xG6f0LdTMdFw5seusZyNPZrRcDOFbIIlOlhAn)DC0MkHOPJeoAvOd9lq9cKZ48deJ)ooAtLq00rcNGk1zSfaDbuCbcUa1lG(fe8c6YHwZziPYFpfoAvOd9lquCbbVGUCO1C4ZkxIGsAg7mDoAvOd9lquCbYzC(bIXziPYFpfobvQZylGQfqXfiyuRK9nwuReIM(z6jiKQFJDmdQrXyMrn0Qqh6Jzh1KKRrYvrT3XrBkFGGKfqf0fK1fOEb9PGliGfqHfikUG3XrBkFGGKfqf0fqTfOEb9PGlGQfqHOwj7BSOMK8zLhJDmdQPAmZOwj7BSOwXErl9wo3ajQHwf6qFm7yhZGAceZmQHwf6qFm7OMKCnsUkQ1NcM6j9MRVaOlGIlq9cEhhTP8bcswqaqxGalq9cOFbHFyyEjen9Z0tqiv)Y)5lquCbD5qR5sYNvEKJwf6q)cuVa6xGCgNFGyCj5ZkpYjOsDgBbqxafxGO4cc)WWCj5ZkpY)5lqWfikUGWHXwG6faF6VDIGk1zSfeWceGIlqWOwj7BSO274OnvcrthjXoMb1OwmZOgAvOd9XSJAsY1i5QOg9l4DC0MYhiizbubDbzDbQxqFk4ccybbYcefxW74OnLpqqYcOc6cO2cuVa6xqFk4cOc6ccKfikUawo6CPUi6yZ4(t4zyI1drzbubDbcSa1lqocrRSMtdTKRSfi4ceCbQxGCgNFGy8siA6NPNGqQ(LtqL6m2cOAb6s)cuVG(uWupP3C9faDbuCbQxa9li4f0LdTMZqsL)EkC0Qqh6xGO4cc)WWCgsQ83tH)ZxGGlq9cOFbbVasD(ekeTMxEpJJbDSMTarXfqQZNqHO18Y7z8F(cefxaPoFcfIwZlVNXpBbuTGSsXfi4cuVa6xqWli8ddZlHOPFMEccP6x(pFbIIl4DC0MYhiizbqxafwGO4cKZ48deJ)wkkijnWjiKQF5euPoJTarXfWYrNl1frhBg3FcpdtSEiklGkOlqGfOEbYriAL1CAOLCLTabJALSVXIAWNvUebL0m2z6Xo2rn4Zo2lsyXmJzOAmZOgAvOd9XSJAtEuJHDuRK9nwutyrUk0HrnHL7Jrnwo6CPUi6yZ4(t4zyI1drzbqxGalq9ccEb0VaY3q4HOJC4Zkxsis8NS5OvHo0VarXf0LdTMto93gNpljej(t2C0Qqh6xGGlquCbSC05sDr0XMX9NWZWeRhIYcOAbcSarXfe(HH5OsoTeSSu(abj8F(cuVGGxGhd)WW8a)96kO18F(cuVGGxq4hgM7pHNHP8pjFyi)Nh1ewKKvkyuZZsYI1vOdJDmdbIzg1qRcDOpMDutsUgjxf1OFbYzC(bIXlHOPFMEccP6xobvQZylGQfOkfwGO4cKZ48deJljFw5robvQZylGQfOkfwGGlq9ccEbD5qR5WNvUebL0m2z6C0Qqh6xG6fq)ccEbD5qR5yqO833yjgAnAsKJwf6q)cefxalhDUuxeDSzC)j8mmX6HOSaQGUakSabxG6fq)ccEbK68juiAnV8Eghd6ynBbIIlGuNpHcrR5L3Z4NTaQwqwP4cefxaPoFcfIwZlVNXpBbbSaDPFbIIlGuNpHcrR5L3Z4)8fi4cuVa6xqWlqocrRSMtdTKRSfikUa5mo)aX4(t4zyQhNJtqL6m2ccybp7ceCbIIla(0F7ebvQZyliGfOkfwG6faF6VDIGk1zSfq1cOWcefxq4hgMljFw5r(pFbQxq4hgMljFw5roRljnliGfOkfJALSVXIAmKu5VNsSJzqTyMrn0Qqh6Jzh1KKRrYvrn6xq4hgMljFw5rUFGylq9cKZ48deJljFw5robvQZylGQfOkfxGO4cc)WWCj5ZkpYzDjPzbubDbuBbIIlqoJZpqmEjen9Z0tqiv)YjOsDgBbuTavP4ceCbQxa9li4f0LdTMdFw5seusZyNPZrRcDOFbIIlqoJZpqmo8zLlrqjnJDMoNGk1zSfq1cuLIlqWfOEbDr0XM3NcM6j5pCbuTGazbQxalhDUuxeDSzC)j8mmX6HOSGawafIALSVXIAyqO833yjgAnAsm2XmYAmZOgAvOd9XSJAsY1i5QOMWICvOd5EwswSUcD4cuVGGxq4hgMlSmv8)yViHLElffKW)5lq9cOFb0VGGxqxo0AUK8zLh5OvHo0VarXfiNX5higxs(SYJCcQuNXwavlqx6xqwwa1wGGlq9cOFbbVGUCO1Cmiu(7BSedTgnjYrRcDOFbIIlqoJZpqmogek)9nwIHwJMe5euPoJTaQwGU0VGSSGNzbIIlqoJZpqmogek)9nwIHwJMe5euPoJTaQwGU0VGSSGSUa1l4DC0MYhiizbubDbuybIIlOlIo28(uWupj)HliGfeilquCbSC05sDr0XMX9NWZWeRhIYcOc6cOWcefxqWlOlhAnNHKk)9u4OvHo0Va1lqoJZpqmogek)9nwIHwJMe5euPoJTaQwGU0VGSSabwGGlq9cOFbbVGUCO1C4ZkxIGsAg7mDoAvOd9lquCbYzC(bIXHpRCjckPzSZ05euPoJTaQwGU0VGSSGNzbIIlqoJZpqmo8zLlrqjnJDMoNGk1zSfq1c0L(fKLfK1fOEbVJJ2u(abjlGkOlGclquCbbVGUCO1CgsQ83tHJwf6q)cuVa5mo)aX4WNvUebL0m2z6CcQuNXwavlqx6xqwwGalqWfikUGUCO183XrBQeIMos4OvHo0Va1lqoJZpqm(74OnvcrthjCcQuNXwqalqx6xqwwa1wGO4cc)WW83XrBQeIMos4)8fikUGWpmmxs(SYJ8F(cuVGWpmmxs(SYJCwxsAwqalqvkUabJALSVXIA(t4zyI1drj2XmOqmZOgAvOd9XSJAsY1i5QOg9li4f0LdTMljFw5roAvOd9lquCbYzC(bIXLKpR8iNGk1zSfq1c0L(fKLfqTfi4cuVa6xqWlOlhAnhdcL)(glXqRrtIC0Qqh6xGO4cKZ48deJJbHYFFJLyO1OjrobvQZylGQfOl9lilliqwGO4cKZ48deJJbHYFFJLyO1OjrobvQZylGQfOl9lill4zwG6f8ooAt5deKSaQGUGSUarXf0frhBEFkyQNK)WfeWccKfikUGGxqxo0Aodjv(7PWrRcDOFbQxGCgNFGyCmiu(7BSedTgnjYjOsDgBbuTaDPFbzzbcSabxG6fq)ccEbD5qR5WNvUebL0m2z6C0Qqh6xGO4cKZ48deJdFw5seusZyNPZjOsDgBbuTaDPFbzzbbYcefxGCgNFGyC4ZkxIGsAg7mDobvQZylGQfOl9lill4zwG6f8ooAt5deKSaQGUGSUarXfe8c6YHwZziPYFpfoAvOd9lq9cKZ48deJdFw5seusZyNPZjOsDgBbuTaDPFbzzbcSabxGO4c6YHwZFhhTPsiA6iHJwf6q)cuVa5mo)aX4VJJ2ujenDKWjOsDgBbbSaDPFbzzbuBbIIli8ddZFhhTPsiA6iH)ZxGO4cc)WWCj5ZkpY)5lq9cc)WWCj5ZkpYzDjPzbbSavPyuRK9nwuRrLCxryjHiXFYo2XoQHSemjvY(eIXmJzOAmZOwj7BSOg8rWq3m(OgAvOd9XSJDmdbIzg1qRcDOpMDutsUgjxf1EhhTP8bcswa0fqHfikUapg(HH5b(71vqR5)8fikUapg(HH5WNvUebL0m2z68F(cuVa6xGhd)WWC4ZkxIGsAg7mDobvQZyliGfOl9CLkOfikUawo6CPUi6yZ4(t4zyI1drzbubDbcSa1li4f0LdTMJbHYFFJLyO1OjroAvOd9lqWfikUapg(HH5yqO833yjgAnAsK)ZxG6f4XWpmmhdcL)(glXqRrtICcQuNXwqalqx65kvqrTs23yrnz5CPs23yj3X6OM7yDYkfmQbF2XErcl2XmOwmZOwj7BSOM)eEgM6X5IAOvHo0hZo2XmYAmZOwj7BSOMWYuX)J9Iew6TuuqsudTk0H(y2XoMbfIzg1qRcDOpMDutsUgjxf1EhhTP8bcswqaqxGalq9cOFbEm8ddZHpRCjckPzSZ05)8fOEbEm8ddZHpRCjckPzSZ05euPoJTGawGU0VGSSabwG6fe8ciFdHhIoY9NWZWebzJvMe5OvHo0VarXf4XWpmmhdcL)(glXqRrtI8F(cuVapg(HH5yqO833yjgAnAsKtqL6m2ccyb6s)cefxalhDUuxeDSzC)j8mmX6HOSaQGUakSa1lG8neEi6i3FcpdteKnwzsKJwf6q)cuVGUCO1Cmiu(7BSedTgnjYrRcDOFbcg1kzFJf1Gu0GPbovSxKf7ygptmZOgAvOd9XSJAsY1i5QOMCm))Aogu(NOx9n2cuVa6xqWlG8neEi6i3FcpdteKnwzsKJwf6q)cuVG3XrBkFGGKfea0fqTfikUG3XrBkFGGKfea0fiWcemQvY(glQf6kpMg4uG)S(KySJzOIIzg1qRcDOpMDutsUgjxf1cEbEm8ddZd83RRGwZ)5lq9cOFbVJJ2u(abjlGkOlq1fOEbKVHWdrh59lMuk9J1KQrwkWFVUcAnhTk0H(fikUG3XrBkFGGKfqf0fiWcemQvY(glQf4VxxbTo2XmcKyMrn0Qqh6Jzh1kzFJf1KLZLkzFJLChRJAUJ1jRuWOg8zh7fjSyhZ4zJzg1qRcDOpMDutsUgjxf1EhhTP8bcswqaqxGarTs23yrnifnyAGtf7fzXoMHQumMzudTk0H(y2rnj5AKCvu7DC0MYhiizbbaDbulQvY(glQf6kpMg4uG)S(KySJzOQQXmJAOvHo0hZoQjjxJKRIAbVapg(HH5b(71vqR5)8Owj7BSOwG)EDf06yhZqvbIzg1kzFJf1ElffKKg4ees1Vrn0Qqh6Jzh7ygQsTyMrTs23yrnj5ZkpssSMC0Grn0Qqh6Jzh7ygQM1yMrTs23yrTIildt9qiO1rn0Qqh6Jzh7ygQsHyMrTs23yrn5ymusQ(glQHwf6qFm7yh7OgYsWKu(mUZ0JzgZq1yMrn0Qqh6Jzh1KKRrYvrT3XrBkFGGKfaDbuybQxa9li4f0LdTMdFw5seusZyNPZrRcDOFbIIlqoJZpqmo8zLlrqjnJDMoNGk1zSfea0fOl9lillGAlquCbYzC(bIXHpRCjckPzSZ05euPoJTaQwqj7BSKCgNFGylqWfOEb0VGGxqxo0Aogek)9nwIHwJMe5OvHo0VarXfiNX5highdcL)(glXqRrtICcQuNXwqaqxGU0VGSSaQTarXfiNX5highdcL)(glXqRrtICcQuNXwavlOK9nwsoJZpqSfikUGUCO1C4ZkxIGsAg7mDoAvOd9lqWfOEb0VGGxGCeIwznNgAjxzlquCbYzC(bIX9NWZWupohNGk1zSfeWcE2fikUa5mo)aX4(t4zyQhNJtqL6m2cOAbLSVXsYzC(bITabJALSVXIAmKu5VNsSJziqmZOgAvOd9XSJAsY1i5QO274OnLpqqYcGUakSarXf4XWpmmh(SYLiOKMXotN)ZxGO4cc)WWCj5ZkpY)5lq9cc)WWCj5ZkpYzDjPzbbSavPyuRK9nwutwoxQK9nwYDSoQ5owNSsbJAWNDSxKWIDmdQfZmQHwf6qFm7OMKCnsUkQf(HH5mKu5VNc)Nh1kzFJf1ewMk(FSxKWsVLIcsIDmJSgZmQHwf6qFm7OMKCnsUkQr(gcpeDKlSm9Fr8SKYOGw)v4OvHo0h1kzFJf1ElffKKg4ees1VXoMbfIzg1qRcDOpMDutsUgjxf1EhhTP8bcswqaqxGalq9cyyNch7Z49HebcKuwZLrTs23yrnifnyAGtf7fzXoMXZeZmQHwf6qFm7OMKCnsUkQ9ooAt5deKSGaGUaQf1kzFJf1cDLhtdCkWFwFsm2XmurXmJAOvHo0hZoQjjxJKRIAbVapg(HH5b(71vqR5)8Owj7BSOwG)EDf06yhZiqIzg1kzFJf1ElffKKg4ees1Vrn0Qqh6Jzh7ygpBmZOgAvOd9XSJAsY1i5QOMCgNFGyCj5ZkpssSMC0GC5Br0rwcMuY(gRClGkOlqvUkIclq9cOFbVJJ2u(abjliaOlqGfikUG3XrBkFGGKfea0fqTfOEbYzC(bIXdDLhtdCkWFwFsKtqL6m2cOAb6s)cYYceybIIl4DC0MYhiizbqxqwxG6fiNX5higp0vEmnWPa)z9jrobvQZylGQfOl9lillqGfOEbYzC(bIXd83RRGwZjOsDgBbuTaDPFbzzbcSabJALSVXIAsYNvEKKyn5ObJDmdvPymZOgAvOd9XSJAsY1i5QOwWlOlhAnh(SYLiOKMXotNJwf6q)cuVa5mo)aX4yqO833yjgAnAsKtqL6m2cca6c0L(fKLfqTfOEb0VGGxGCeIwznNgAjxzlquCbYzC(bIX9NWZWupohNGk1zSfeWcE2fiyuRK9nwuJHKk)9uIDmdvvnMzudTk0H(y2rTs23yrnz5CPs23yj3X6OM7yDYkfmQbF2XErcl2XmuvGyMrTs23yrnj5ZkpssSMC0Grn0Qqh6Jzh7ygQsTyMrn0Qqh6Jzh1KKRrYvrT3XrBkFGGKfea0fK1Owj7BSOwrKLHPEie06yhZq1SgZmQHwf6qFm7OMKCnsUkQr)ccEbD5qR5WNvUebL0m2z6C0Qqh6xGO4cKZ48deJdFw5seusZyNPZjOsDgBbbaDb6s)cYYcO2ceCbQxa9li4f0LdTMJbHYFFJLyO1OjroAvOd9lquCbYzC(bIXXGq5VVXsm0A0KiNGk1zSfea0fOl9lillGAlquCbD5qR5WNvUebL0m2z6C0Qqh6xGGlq9cOFbbVa5ieTYAon0sUYwGO4cKZ48deJ7pHNHPECoobvQZyliGf8SlqWOwj7BSOgdjv(7Pe7ygQsHyMrTs23yrn5ymusQ(glQHwf6qFm7yh7yh1QF)oKOM2Pq9Xo2Xia]] )


end
