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


    spec:RegisterPack( "Retribution", 20210719, [[dSueJbqiLGhHuQ6skrv1MiKprOKrrv0POkSkqvEfOQMfsr3sKszxO8lqHHrvLJrOAzuv1ZiumnKsUgOOTHuk9nKsX4iuQZjsHwNifmpLi3dPAFIKdQevXcrk8qLOYerkvCrKsLSrLOQ8rrkkoPifvRKQKzksrUPsuLANkHgQsuLSurkvpvetvKQTksrPVIuQuJvKsAVs6VIAWahwyXuQht0KP4YqBgKptWOLOtRYQvIYRbLMnvUnLSBs)wQHRKoUiLy5iEoQMUQUUsTDQkFxcJNQuNhuz(iz)kUkEn9AIjESUO)(5V4(rBepnY8xmIlgysBQjpCRynznKWgcynrdlSMK2XNC27)ATMSgW56WutVMW7nrI1KAI9(CFAUwTRjM4X6I(7N)I7hTr80iZFXiUy8t8AcFfL1fPn(vtkpJb1QDnXGCznjTJp5S3)16awEfUWC64LxBhCdq80inhG)(5V4JxJxlxzOcipnmEL2gqAk4FAJJYwndyZdbCan0aEYPWIphglhTdFaAxmaOMma7MZha0ju(8b0QdUb4PPvX6hqrWFCalhTdFaToGNe8spyJxPTbS8oGfhqcsI1YZAaqBv(xRdOOe1bS8DA4gqAhLW26PcWG2L3OC)xRdib1hvjoGGGdO1bSC0odaQjdigqr55Wb4j0M8Lizae0fEJMb06aOnWqS9GnEL2gWYJXmaOW5sBFjP3cLdG2jbgPNMDafLOoGeKeRLNfmw(s7dii4amihovwIgwnzL0qNdRj0EA)as74to79FToGLxHlmNoEr7P9dWRTdUbiEAKMdWF)8x8XRXlApTFalxzOcipnmEr7P9diTnG0uW)0ghLTAgWMhc4aAOb8KtHfFomwoAh(a0Uyaqnza2nNpaOtO85dOvhCdWttRI1pGIG)4awoAh(aADapj4LEWgVO90(bK2gWY7awCajijwlpRbaTv5FToGIsuhWY3PHBaPDucBRNkadAxEJY9FToGeuFuL4accoGwhWYr7maOMmGyafLNdhGNqBYxIKbqqx4nAgqRdG2adX2d24fTN2pG02awEmMbafoxA7lj9wOCa0ojWi90SdOOe1bKGKyT8SGXYxAFabbhGb5WPYs0WgVgVc5FTYzReu2w2XtFT)R1XRq(xRC2kbLTLD8WNomSDiNFQqUHY8TLfsgVc5FTYzReu2w2XdF6WW2HC(Pc5gkh7FBPJxH8Vw5SvckBl74HpDyy7qo)uHCdLlo9rY4vi)RvoBLGY2YoE4thg2oKZpvi3qz(k5uHXRq(xRC2kbLTLD8WNomcImum)nHG6tZdI(houFg0PHltqjSTEQad1W2HgrF4q9zCKeRLNfd1W2HMXRXRbmEr7P9dG2L3OC)OzaOpKa3a(ZchWxIdiKFtgWXhq4loxy7q24vi)RvoDcAVHfhVc5FTYHpDyidNlhY)An7o(ttnSq6YUDMUq5JxH8Vw5WNomKHZLd5FTMDh)PPgwiDburs8nHpEnGXRq(xRCMSBNPluo91(VwP5br3EdbXcFOkCQqUGeFjBVsrzVHGysYMhgKTxfzVHGysYMhgKX)qclDX9JIYU5CrqNq5NjOvCkFj)H54vi)Rvot2TZ0fkh(0HH7ekFEEzBJGfQpnpi68v05YFqeWNZCNq5ZZlBBeSq9tr3FkQfiXzYOpuFwymCg69XFoffjotg9H6ZcJHZonfTbMuuK4mz0hQplmgoBVoEfY)ALZKD7mDHYHpDyaDe021THMheD7neel8HQWPc5cs8LS9kfL9gcIjjBEyq2EvK9gcIjjBEyqg)djS0f3VXRq(xRCMSBNPluo8PddE5HotUHY(qvadvI08GO75cF4q9zO3OC)xRzoQpQsKHAy7qdfLSBNPlug6nk3)1AMJ6JQeze0koLVem93drqNq5NjOvCkpL4WC8kK)1kNj72z6cLdF6WW2HC(Pc5gkZ3wwiz8kK)1kNj72z6cLdF6WW2HC(Pc5gkh7FBPJxH8Vw5mz3otxOC4thg2oKZpvi3q5ItFKmEfY)ALZKD7mDHYHpDyy7qo)uHCdL5RKtfgVc5FTYzYUDMUq5WNom2CmFpArtnSq6NYLK9h2omNw2H(BRSb9DsKMheD7neel8HQWPc5cs8LS9kfL9gcIjjBEyq2EvK9gcIjjBEyqg)djS0f3pkk7MZfbDcLFMGwXP8LeJFJxH8Vw5mz3otxOC4thgBoMVhTOPgwi92hskkrN1Pc51Uajzjbo(hoAEq0T3qqSWhQcNkKliXxY2Ruu2BiiMKS5Hbz7vr2BiiMKS5Hbz8pKWsxC)OOSBoxe0ju(zcAfNYxsCyoEfY)ALZKD7mDHYHpDyS5y(E0IMAyH0nbbwRU1SbLWM91KqEpC08GOBVHGyHpufovixqIVKTxPOS3qqmjzZddY2RIS3qqmjzZddY4FiHLU4(rrz3CUiOtO8Ze0koLVK)(nEfY)ALZKD7mDHYHpDyS5y(E0IMAyH0TczytWmVeXpBT5NKMheD7neel8HQWPc5cs8LS9kfL9gcIjjBEyq2EvK9gcIjjBEyqg)djS0f3pkk7MZfbDcLFMGwXP8L83VXRq(xRCMSBNPluo8PdJnhZ3Jw0udlKUHGHb6iy2hY5OB8kK)1kNj72z6cLdF6WyZX89Ofn1WcPZHD7Gfj8CXPcJxH8Vw5mz3otxOC4thgBoMVhTOPgwiDbYzLLTb9E8kK)1kNj72z6cLdF6WyZX89Ofn1WcPBHwnbUCdLxd(N5NYhVc5FTYzYUDMUq5WNom2CmFpArtnSq681GGzlm(Cz3WoEfY)ALZKD7mDHYHpDyS5y(E0IMAyH05HZxiGMm0MFTMdRv3bDiz8kK)1kNj72z6cLdF6WyZX89Ofn1WcPVvzzCkAYcUWCX3eE2omcyUHYqiPL3dhnpi62Biiw4dvHtfYfK4lz7vkk7neets28WGS9Qi7neets28WGm(hsytrxC)OOKD7mDHYcFOkCQqUGeFjJGwXP8u0cMuuYUDMUqzsYMhgKrqR4uEkAbZXRq(xRCMSBNPluo8PdJnhZ3Jw0udlK(wLLXPOjh81Je6ZZ2HraZnugcjT8E4O5br3EdbXcFOkCQqUGeFjBVsrzVHGysYMhgKTxfzVHGysYMhgKX)qcBk6I7hfLSBNPluw4dvHtfYfK4lze0koLNIwWKIs2TZ0fkts28WGmcAfNYtrlyoEfY)ALZKD7mDHYHpDyS5y(E0IMAyH05NcTDzbxyU4BcpBhgbm3qziK0Y7HJMheD7neel8HQWPc5cs8LS9kfL9gcIjjBEyq2EvK9gcIjjBEyqg)djSPOlUFuuYUDMUqzHpufovixqIVKrqR4uEkAbtkkz3otxOmjzZddYiOvCkpfTG54vi)Rvot2TZ0fkh(0HXMJ57rlAQHfsNFk02Ld(6rc95z7WiG5gkdHKwEpC08GOBVHGyHpufovixqIVKTxPOS3qqmjzZddY2RIS3qqmjzZddY4FiHnfDX9JIs2TZ0fkl8HQWPc5cs8LmcAfNYtrlysrj72z6cLjjBEyqgbTIt5POfmhVc5FTYzYUDMUq5WNom2CmFpAXP5br3EdbXcFOkCQqUGeFjBVsrzVHGysYMhgKTxfzVHGysYMhgKX)qcBk6I734vi)Rvot2TZ0fkh(0Hr4dvHtfYfK4lP5br3ZY2bxETlqsk60s0Fw4sWKIQSDWLx7cKKIUye55Fwykysrr2kc1ebK9Ly2keo(tIh55LTncwO(Eqr9Hd1Nv2o4YHpufqcd1W2HgrYUDMUqzLTdUC4dvbKWiOvCkNUFEiYZf(WH6Z4ijwlplgQHTdnuuYUDMUqzCKeRLNfJGwXP8u(rr9Hd1NXdv(h0HMCbj(sgQHTdnEmEfY)ALZKD7mDHYHpDyijBEyqAEq0lBhC51UajPOtlr)zHlbtkQY2bxETlqsk6Ir0Fwykysr9Hd1Nv2o4YHpufqcd1W2HgrYUDMUqzLTdUC4dvbKWiOvCkNUFJxH8Vw5mz3otxOC4thgbVe1Cz4CDX4vi)Rvot2TZ0fkh(0Hrz7Glh(qvaj08GO)NfM)oxUkq3prEAVHGyHpufovixqIVKTxPOS3qqmjzZddY2Ruu2Biiw4dvHtfYfK4lzMUqfj72z6cLf(qv4uHCbj(sgbTIt5POLFuu2BiiMKS5HbzMUqfj72z6cLjjBEyqgbTIt5POLFEmEfY)ALZKD7mDHYHpDyaDA4YeucBRNkqZdIUNLTdU8AxGKu0PLO)SWLeBkQY2bxETlqsk6Ir0Fwyk6IThIKD7mDHYcFOkCQqUGeFjJGwXP8ucsJO)SW835Yvb6(jYZf(WH6Z4ijwlplgQHTdnuu2BiighjXA5zX2REiYZfiXzYOpuFwymCg69XFoffjotg9H6ZcJHZ2RuuK4mz0hQplmgo70u0YppgVgW4vi)Rvod60JxIeoDFb5cBhstnSq6gEwg8pSDin9fUnsNVIox(dIa(CM58DkM5FtSO7VOf8KSveQjcid60WL9HeZjFrF4q9zKtO8XEZZ(qI5Kpd1W2HgrYwn77zpAT6ccp77uZjJ)ALHAy7qJhuu8v05YFqeWNZmNVtXm)BIvk)POS3qqm0AfocgAETlqcBVkYG2Bii2Y2gbluFMPlur2BiiM58DkMx3K1MJmtxOJxH8Vw5mOtpEjs4WNom4ijwlplAEq09u2TZ0fkl8HQWPc5cs8LmcAfNYtjomPOKD7mDHYKKnpmiJGwXP8uIdtkQpCO(mOtdxMGsyB9ubgQHTdnEiYZf(WH6ZGonCzckHT1tfyOg2o0qrj72z6cLbDA4YeucBRNkWiOvCkpL)(bFbPbEIHIs2TZ0fkd60WLjOe2wpvGrqR4u(s0fKg4jgrEUajotg9H6ZcJHZqVp(ZPOiXzYOpuFwymC2PPOLFuuK4mz0hQplmgo70LeKgkksCMm6d1NfgdNTx9WdrEUWhouFg6nk3)1AMJ6JQezOg2o0qrj72z6cLHEJY9FTM5O(OkrgbTIt5PedmPOKD7mDHYqVr5(VwZCuFuLiJGwXP8LOlinWtmuuF4q9zqNgUmbLW26PcmudBhA8qKNliBFOg6ZGfoYfkfLSBNPluM58DkM)25ye0koLNIwWKIs2TZ0fkZC(ofZF7CmcAfNYxkn6bfLDZ5IGoHYptqR4u(sIdtrqNq5NjOvCkpfmhVc5FTYzqNE8sKWHpDyGEJY9FTM5O(OkrAEq090EdbXKKnpmiZ0fQiz3otxOmjzZddYiOvCkpL4(rrzVHGysYMhgKX)qcBk6IHIs2TZ0fkl8HQWPc5cs8LmcAfNYtjUFEiYZf(WH6ZGonCzckHT1tfyOg2o0qrj72z6cLbDA4YeucBRNkWiOvCkpL4(5HOpic4Z(ZcZFNnhMsShVc5FTYzqNE8sKWHpDyyoFNIz(3elAEq09fKlSDiZWZYG)HTdfTG9gcI5l00Y(4LiHNldllKW2RI80Zf(WH6ZKKnpmid1W2Hgkkz3otxOmjzZddYiOvCkpLG0apX4Hipx4dhQpd9gL7)AnZr9rvImudBhAOOKD7mDHYqVr5(VwZCuFuLiJGwXP8ucsd8OTuuYUDMUqzO3OC)xRzoQpQsKrqR4uEkbPbEWuuz7GlV2fijfDArr9braF2Fwy(7S5WLeBkQf(WH6Z4ijwlplgQHTdnIKD7mDHYqVr5(VwZCuFuLiJGwXP8ucsd883drEUWhouFg0PHltqjSTEQad1W2Hgkkz3otxOmOtdxMGsyB9ubgbTIt5PeKg4rBPOKD7mDHYGonCzckHT1tfye0koLNsqAGhmfv2o4YRDbssrNwuul8Hd1NXrsSwEwmudBhAej72z6cLbDA4YeucBRNkWiOvCkpLG0ap)9qKNl8Hd1NXrsSwEwmudBhAOOKD7mDHY4ijwlplgbTIt5l)csd8lBhC51UajPedf1houFg0PHltqjSTEQad1W2HgkQpCO(m0BuU)R1mh1hvjYqnSDOHIs2(qn0NblCKlupOO88dhQpRSDWLdFOkGegQHTdnIKD7mDHYkBhC5WhQciHrqR4u(scsd8edfL9gcIv2o4YHpufqcBVsrzVHGysYMhgKTxfzVHGysYMhgKX)qc7sI7NhEmEfY)ALZGo94LiHdF6W4rRvxq4zFiXCYNMheDpx4dhQpts28WGmudBhAOOKD7mDHYKKnpmiJGwXP8ucsd8eJhI8CHpCO(m0BuU)R1mh1hvjYqnSDOHIs2TZ0fkd9gL7)AnZr9rvImcAfNYtjinWJ2srj72z6cLHEJY9FTM5O(OkrgbTIt5PeKg4btrLTdU8AxGKu0Pff1heb8z)zH5VZMdxsSPOw4dhQpJJKyT8SyOg2o0is2TZ0fkd9gL7)AnZr9rvImcAfNYtjinWZFpe55cF4q9zqNgUmbLW26PcmudBhAOOKD7mDHYGonCzckHT1tfye0koLNsqAGhTLIs2TZ0fkd60WLjOe2wpvGrqR4uEkbPbEWuuz7GlV2fijfDArrTWhouFghjXA5zXqnSDOrKSBNPlug0PHltqjSTEQaJGwXP8ucsd883drEUWhouFghjXA5zXqnSDOHIs2TZ0fkJJKyT8Sye0koLV8linWVSDWLx7cKKsmuuF4q9zqNgUmbLW26PcmudBhAOO(WH6ZqVr5(VwZCuFuLid1W2Hgkkz7d1qFgSWrUq9GI6dhQpRSDWLdFOkGegQHTdnIKD7mDHYkBhC5WhQciHrqR4u(scsd8edfL9gcIv2o4YHpufqcBVsrzVHGysYMhgKTxfzVHGysYMhgKX)qc7sI734vi)Rvod60JxIeo8PddZ57umZ)MyrZdIUVGCHTdzgEwg8pSDOOpCO(mosI1YZIHAy7qJOpCO(mOtdxMGsyB9ubgQHTdnI8u2TZ0fkJJKyT8SyemmWjs2TZ0fkd60WLjOe2wpvGrqR4uEkAbpbPHIs2TZ0fkJJKyT8Sye0koLNsmWtqAej72z6cLbDA4YeucBRNkWiOvCkFjAbpbPXdrLTdU8AxGe6LTdU8AxGeMv494vi)Rvod60JxIeo8PdJhTwDbHN9HeZjFAEq0)WH6Z4ijwlplgQHTdnI(WH6ZGonCzckHT1tfyOg2o0iYtz3otxOmosI1YZIrWWaNiz3otxOmOtdxMGsyB9ubgbTIt5POf8eKgkkz3otxOmosI1YZIrqR4uEkXapbPrKSBNPlug0PHltqjSTEQaJGwXP8LOf8eKgpev2o4YRDbsOx2o4YRDbsywH3Jxdy8kK)1kNjGksIVjC6YW5YH8VwZUJ)0udlKo0PhVejCAEq0lBhC51Uaj0HjfL9gcIv2o4YHpufqcBVsrzq7need60WLjOe2wpvGTxPOmO9gcIHEJY9FTM5O(Okr2ED8kK)1kNjGksIVjC4thg(cnTSpEjs45YWYcjJxH8Vw5mburs8nHdF6WWC(ofZF7C08GOVGbT3qqSLTncwO(S9Qipx4dhQpJJKyT8SyOg2o0qrzVHGyCKeRLNfBV6HipxGeNjJ(q9zHXWzO3h)5uuK4mz0hQplmgo70uIXpkksCMm6d1NfgdNTx9qKNLTdU8AxGKLO7pfvz7GlV2fizj60sKNYUDMUqz2UWG5gkVSn)pjYiOvCkpLG0ap)POmO9gcIHEJY9FTM5O(Okr2ELIYG2Biig0PHltqjSTEQaBV6HhI8CHpCO(mOtdxMGsyB9ubgQHTdnuuYUDMUqzqNgUmbLW26PcmcAfNYtjinWtC)8qKNl8Hd1NHEJY9FTM5O(OkrgQHTdnuuYUDMUqzO3OC)xRzoQpQsKrqR4uEkbPbEI7hf1heb8z)zH5VZMdxsS9qKNYUDMUqzHpufovixqIVKrqR4uofLSBNPluMKS5Hbze0koL7X4vi)RvotavKeFt4WNomkdllKKBOCbj(sAEq0jBfHAIaY(smBfM8AqcHwPOiBfHAIaY8fQWoigE2QTq93wI(WH6ZqVr5(VwZCuFuLid1W2Hgkkz7d1qFMpu)s4iIKD7mDHYcEjQ5YW56cgbTIt5P8xC)gVc5FTYzcOIK4Bch(0HXY2gbluFAEq0xWG2Bii2Y2gbluF2EvK9gcIv2o4YHpufqcBVoEfY)ALZeqfjX3eo8PdJIawm3q5GxICAEq09SSDWLx7cKSeD)f9Hd1NHEJY9FTM5O(OkrgQHTdnImO9gcIHEJY9FTM5O(OkrgbTIt5P8tKbT3qqm0BuU)R1mh1hvjYiOvCkFjbPbE(7X4vi)RvotavKeFt4WNomSDHbZnuEzB(FsKMhe9Y2bxETlqYs0fJOpCO(mBxyWCdLliXxYqnSDOrKNF4q9zqNgUmbLW26PcmudBhAezq7need60WLjOe2wpvGrqR4uEkbPbE(tr9Hd1NHEJY9FTM5O(OkrgQHTdnIw4dhQpd60WLjOe2wpvGHAy7qJipnO9gcIHEJY9FTM5O(Okr2ELIs2TZ0fkd9gL7)AnZr9rvImcAfNYP7NhEmEfY)ALZeqfjX3eo8PdJLTncwO(08GOVGbT3qqSLTncwO(S9QOpCO(mosI1YZIHAy7qJiplBhC51UajPOlUiYwrOMiGSVeZwHWXFs8ipVSTrWc1NIQSDWLx7cKKIU)EmEfY)ALZeqfjX3eo8PdJIawm3q5GxICAEq09SSDWLx7cKq3pkQY2bxETlqYs09xKNYUDMUqz2UWG5gkVSn)pjYiOvCkpLG0ap)POmO9gcIHEJY9FTM5O(Okr2ELI6dIa(S)SW83zZHlj2uug0EdbXGonCzckHT1tfy7vp8qKNlqIZKrFO(SWy4m07J)CkksCMm6d1NfgdNDAk)9JIIeNjJ(q9zHXWz7vpe55cF4q9zO3OC)xRzoQpQsKHAy7qdfLSBNPlug6nk3)1AMJ6JQeze0koLNsCysr9braF2Fwy(7S5WLeBpe55cF4q9zqNgUmbLW26PcmudBhAOOKD7mDHYGonCzckHT1tfye0koLNsCysr9braF2Fwy(7S5WLeBpe5PSBNPluw4dvHtfYfK4lze0koLtrj72z6cLjjBEyqgbTIt5EmEfY)ALZeqfjX3eo8Pddz4C5q(xRz3XFAQHfsh60JxIeonpi6LTdU8AxGKu0fJi7neets28WGS9Qi7neets28WGm(hsyxsC)gVc5FTYzcOIK4Bch(0HHTlmyUHYlBZ)tI08GOx2o4YRDbswIUyejB1SVNHEVUjcXFTYqnSDOr0cY2hQH(mFO(LWrgVc5FTYzcOIK4Bch(0HXY2gbluFAEq0xWG2Bii2Y2gbluF2ED8kK)1kNjGksIVjC4thgLHLfsYnuUGeF54vi)RvotavKeFt4WNomSDHbZnuEzB(FsKMhe9Y2bxETlqYs0fZ4vi)RvotavKeFt4WNomKHZLd5FTMDh)PPgwiDOtpEjs408GO75heb8zLy4(s2Q8xIU)(rrzVHGyHpufovixqIVKTxPOS3qqmjzZddY2Ruu2BiigATchbdnV2fiHTx9y8kK)1kNjGksIVjC4thgsYMhgKK5p5GfP5brx2TZ0fkts28WGKm)jhSitwgebKNHiH8Vwdxk6IZOnWuKNLTdU8AxGKLO7pfvz7GlV2fizj6IrKSBNPluMTlmyUHYlBZ)tImcAfNYtjinWZFkQY2bxETlqcDAjs2TZ0fkZ2fgm3q5LT5)jrgbTIt5PeKg45Viz3otxOSLTncwO(mcAfNYtjinWZFpgVc5FTYzcOIK4Bch(0HHSvokjXFTsZdI(cYw5OKe)1kBVkIVIox(dIa(CM58DkM5FtSsr3)XRq(xRCMaQij(MWHpDyidNlhY)An7o(ttnSq6qNE8sKWhVc5FTYzcOIK4Bch(0HHSvokjXFTsZdI(cYw5OKe)1kBVoEfY)ALZeqfjX3eo8PddjzZddsY8NCWIJxH8Vw5mburs8nHdF6WiiYqX83ecQ)4vi)RvotavKeFt4WNomKTYrjj(R1AIpKWVwRl6VF(lUF0g)sJ1KIGONkWRj0UxEs7lMMVyAM0Wagq6L4aoR1M8daQjdqSKD7mDHYfRbqW0Y(iOza82chqS)2kE0mazzOciNnELMofhG)0knmGLRvFi5rZaelYwrOMiGS0QynGVhGyr2kc1ebKLwzOg2o0iwdWtX92d2414fT7LN0(IP5lMMjnmGbKEjoGZATj)aGAYaelOtpEjs4I1aiyAzFe0maEBHdi2FBfpAgGSmubKZgVstNIdq80WawUw9HKhndqSiBfHAIaYsRI1a(EaIfzRiuteqwALHAy7qJynapf3BpyJxPPtXbqR0WawUw9HKhndi5SwUbWHt)W7bS8pGVhqAAhdWC(o(16a6vKeFtgGNWWJb4P4E7bB8knDkoayMggWY1QpK8OzajN1YnaoC6hEpGL)b89ast7yaMZ3XVwhqVIK4BYa8egEmapf3BpyJxJx0UxEs7lMMVyAM0Wagq6L4aoR1M8daQjdqSeqfjX3eUynacMw2hbndG3w4aI93wXJMbildva5SXR00P4aOvAyalxR(qYJMbiwKTIqnrazPvXAaFpaXISveQjcilTYqnSDOrSgGNI7ThSXR00P4aOvAyalxR(qYJMbiwKTIqnrazPvXAaFpaXISveQjcilTYqnSDOrSgGNI7ThSXR00P4ae70WawUw9HKhndqSiBfHAIaYsRI1a(EaIfzRiuteqwALHAy7qJynapf3BpyJxJxP5wRn5rZaG5ac5FToa3XFoB8QMe7VSj1KKZA5QjUJ)8A61edcfB3xtVUO410RjH8VwRje0EdlwtqnSDOPsJ6xx0)A61eudBhAQ0OMeY)ATMidNlhY)An7o(xtCh)ZAyH1ez3otxO86xxum10RjOg2o0uPrnjK)1AnrgoxoK)1A2D8VM4o(N1WcRjcOIK4BcV(1VMSsqzBzhFn96IIxtVMeY)ATMS2)1Anb1W2HMknQFDr)RPxtc5FTwtSDiNFQqUHY8TLfsQjOg2o0uPr9RlkMA61Kq(xR1eBhY5NkKBOCS)TLwtqnSDOPsJ6xxKw10RjH8VwRj2oKZpvi3q5ItFKutqnSDOPsJ6xxeM10RjH8VwRj2oKZpvi3qz(k5uHAcQHTdnvAu)6I02A61eudBhAQ0OMij3JKlQjF4q9zqNgUmbLW26PcmudBhAgGOb8Hd1NXrsSwEwmudBhAQjH8VwRjbrgkM)Mqq9RF9RjcOIK4BcVMEDrXRPxtqnSDOPsJAIKCpsUOMu2o4YRDbsga9baZbqrna7neeRSDWLdFOkGe2EDauudWG2Biig0PHltqjSTEQaBVoakQbyq7need9gL7)AnZr9rvIS9AnjK)1AnrgoxoK)1A2D8VM4o(N1WcRjqNE8sKWRFDr)RPxtc5FTwt8fAAzF8sKWZLHLfsQjOg2o0uPr9RlkMA61eudBhAQ0OMij3JKlQjlmadAVHGylBBeSq9z71biAaEoGfgWhouFghjXA5zXqnSDOzauudWEdbX4ijwlpl2EDaEmardWZbSWaiXzYOpuFwymCg69XF(aOOgajotg9H6ZcJHZoDaPgGy8BauudGeNjJ(q9zHXWz71b4Xaenaphqz7GlV2fizalrFa(pakQbu2o4YRDbsgWs0haTgGOb45aKD7mDHYSDHbZnuEzB(FsKrqR4u(asnabPzaWBa(pakQbyq7need9gL7)AnZr9rvIS96aOOgGbT3qqmOtdxMGsyB9ub2EDaEmapgGOb45awyaF4q9zqNgUmbLW26PcmudBhAgaf1aKD7mDHYGonCzckHT1tfye0koLpGudqqAga8gG4(napgGOb45awyaF4q9zO3OC)xRzoQpQsKHAy7qZaOOgGSBNPlug6nk3)1AMJ6JQeze0koLpGudqqAga8gG4(nakQb8braF2Fwy(7S5WbS0ae7b4XaenaphGSBNPluw4dvHtfYfK4lze0koLpakQbi72z6cLjjBEyqgbTIt5dWJAsi)R1AI58DkM)25QFDrAvtVMGAy7qtLg1ej5EKCrnHSveQjci7lXSvyYRbjeALHAy7qZaOOgazRiuteqMVqf2bXWZwTfQ)2IHAy7qZaenGpCO(m0BuU)R1mh1hvjYqnSDOzauudq2(qn0N5d1VeoYaenaz3otxOSGxIAUmCUUGrqR4u(asna)f3VAsi)R1AszyzHKCdLliXxw)6IWSMEnb1W2HMknQjsY9i5IAYcdWG2Bii2Y2gbluF2EDaIgG9gcIv2o4YHpufqcBVwtc5FTwtw22iyH6x)6I02A61eudBhAQ0OMij3JKlQjEoGY2bxETlqYawI(a8FaIgWhouFg6nk3)1AMJ6JQezOg2o0mardWG2Biig6nk3)1AMJ6JQeze0koLpGudWVbiAag0EdbXqVr5(VwZCuFuLiJGwXP8bS0aeKMbaVb4)a8OMeY)ATMueWI5gkh8sKx)6I0MA61eudBhAQ0OMij3JKlQjLTdU8AxGKbSe9biMbiAaF4q9z2UWG5gkxqIVKHAy7qZaenaphWhouFg0PHltqjSTEQad1W2HMbiAag0EdbXGonCzckHT1tfye0koLpGudqqAga8gG)dGIAaF4q9zO3OC)xRzoQpQsKHAy7qZaenGfgWhouFg0PHltqjSTEQad1W2HMbiAaEoadAVHGyO3OC)xRzoQpQsKTxhaf1aKD7mDHYqVr5(VwZCuFuLiJGwXP8bqFa(napgGh1Kq(xR1eBxyWCdLx2M)NeRFDrXUMEnb1W2HMknQjsY9i5IAYcdWG2Bii2Y2gbluF2EDaIgWhouFghjXA5zXqnSDOzaIgGNdOSDWLx7cKmGu0hG4dq0aiBfHAIaY(smBfch)jXJ88Y2gbluFgQHTdndGIAaLTdU8AxGKbKI(a8FaEutc5FTwtw22iyH6x)6IPXA61eudBhAQ0OMij3JKlQjEoGY2bxETlqYaOpa)gaf1akBhC51Uajdyj6dW)biAaEoaz3otxOmBxyWCdLx2M)Neze0koLpGudqqAga8gG)dGIAag0EdbXqVr5(VwZCuFuLiBVoakQb8braF2Fwy(7S5WbS0ae7bqrnadAVHGyqNgUmbLW26PcS96a8yaEmardWZbSWaiXzYOpuFwymCg69XF(aOOgajotg9H6ZcJHZoDaPgG)(nakQbqIZKrFO(SWy4S96a8yaIgGNdyHb8Hd1NHEJY9FTM5O(OkrgQHTdndGIAaYUDMUqzO3OC)xRzoQpQsKrqR4u(asnaXH5aOOgWheb8z)zH5VZMdhWsdqShGhdq0a8CalmGpCO(mOtdxMGsyB9ubgQHTdndGIAaYUDMUqzqNgUmbLW26PcmcAfNYhqQbiomhaf1a(GiGp7plm)D2C4awAaI9a8yaIgGNdq2TZ0fkl8HQWPc5cs8LmcAfNYhaf1aKD7mDHYKKnpmiJGwXP8b4rnjK)1AnPiGfZnuo4LiV(1ff3VA61eudBhAQ0OMij3JKlQjLTdU8AxGKbKI(aeZaena7neets28WGS96aena7neets28WGm(hsyhWsdqC)QjH8VwRjYW5YH8VwZUJ)1e3X)Sgwynb60JxIeE9RlkU410RjOg2o0uPrnrsUhjxutkBhC51Uajdyj6dqmdq0aKTA23ZqVx3eH4VwzOg2o0mardyHbiBFOg6Z8H6xchPMeY)ATMy7cdMBO8Y28)Ky9RlkU)10RjOg2o0uPrnrsUhjxutwyag0EdbXw22iyH6Z2R1Kq(xR1KLTncwO(1VUO4IPMEnjK)1AnPmSSqsUHYfK4lRjOg2o0uPr9RlkoTQPxtqnSDOPsJAIKCpsUOMu2o4YRDbsgWs0hGyQjH8VwRj2UWG5gkVSn)pjw)6IIdZA61eudBhAQ0OMij3JKlQjEoGpic4ZkXW9LSv5pGLOpa)9BauudWEdbXcFOkCQqUGeFjBVoakQbyVHGysYMhgKTxhaf1aS3qqm0AfocgAETlqcBVoapQjH8VwRjYW5YH8VwZUJ)1e3X)Sgwynb60JxIeE9RlkoTTMEnb1W2HMknQjsY9i5IAISBNPluMKS5Hbjz(toyrMSmicipdrc5FTgUbKI(aeNrBG5aenaphqz7GlV2fizalrFa(pakQbu2o4YRDbsgWs0hGygGObi72z6cLz7cdMBO8Y28)KiJGwXP8bKAacsZaG3a8FauudOSDWLx7cKma6dGwdq0aKD7mDHYSDHbZnuEzB(FsKrqR4u(asnabPzaWBa(pardq2TZ0fkBzBJGfQpJGwXP8bKAacsZaG3a8FaEutc5FTwtKKnpmijZFYblw)6IItBQPxtqnSDOPsJAIKCpsUOMSWaKTYrjj(Rv2EDaIgaFfDU8heb85mZ57umZ)MynGu0hG)1Kq(xR1ezRCusI)AT(1ffxSRPxtqnSDOPsJAsi)R1AImCUCi)R1S74FnXD8pRHfwtGo94LiHx)6IINgRPxtqnSDOPsJAIKCpsUOMSWaKTYrjj(Rv2ETMeY)ATMiBLJss8xR1VUO)(vtVMeY)ATMijBEyqsM)KdwSMGAy7qtLg1VUO)IxtVMeY)ATMeezOy(Bcb1VMGAy7qtLg1VUO)(xtVMeY)ATMiBLJss8xR1eudBhAQ0O(1VMaD6XlrcVMEDrXRPxtqnSDOPsJAsVwt44xtc5FTwt8fKlSDynXx42ynHVIox(dIa(CM58DkM5FtSga9b4)aenGfgGNdGSveQjcid60WL9HeZjFgQHTdndq0a(WH6ZiNq5J9MN9HeZjFgQHTdndq0aKTA23ZE0A1feE23PMtg)1kd1W2HMb4XaOOgaFfDU8heb85mZ57umZ)MynGudW)bqrna7needTwHJGHMx7cKW2Rdq0amO9gcITSTrWc1Nz6cDaIgG9gcIzoFNI51nzT5iZ0fAnXxqYAyH1edpld(h2oS(1f9VMEnb1W2HMknQjsY9i5IAINdq2TZ0fkl8HQWPc5cs8LmcAfNYhqQbiomhaf1aKD7mDHYKKnpmiJGwXP8bKAaIdZbqrnGpCO(mOtdxMGsyB9ubgQHTdndWJbiAaEoGfgWhouFg0PHltqjSTEQad1W2HMbqrnaz3otxOmOtdxMGsyB9ubgbTIt5di1a83Vba)biindaEdqmdGIAaYUDMUqzqNgUmbLW26PcmcAfNYhWs0hGG0ma4naXmardWZbSWaiXzYOpuFwymCg69XF(aOOgajotg9H6ZcJHZoDaPgaT8BauudGeNjJ(q9zHXWzNoGLgGG0makQbqIZKrFO(SWy4S96a8yaEmardWZbSWa(WH6ZqVr5(VwZCuFuLid1W2HMbqrnaz3otxOm0BuU)R1mh1hvjYiOvCkFaPgGyG5aOOgGSBNPlug6nk3)1AMJ6JQeze0koLpGLOpabPzaWBaIzauud4dhQpd60WLjOe2wpvGHAy7qZa8yaIgGNdyHbiBFOg6ZGfoYf6aOOgGSBNPluM58DkM)25ye0koLpGudGwWCauudq2TZ0fkZC(ofZF7CmcAfNYhWsdinoapgaf1aSBoFaIga0ju(zcAfNYhWsdqCyoarda6ek)mbTIt5di1aGznjK)1AnHJKyT8SQFDrXutVMGAy7qtLg1ej5EKCrnXZbyVHGysYMhgKz6cDaIgGSBNPluMKS5Hbze0koLpGudqC)gaf1aS3qqmjzZddY4FiHDaPOpaXmakQbi72z6cLf(qv4uHCbj(sgbTIt5di1ae3Vb4XaenaphWcd4dhQpd60WLjOe2wpvGHAy7qZaOOgGSBNPlug0PHltqjSTEQaJGwXP8bKAaI73a8yaIgWheb8z)zH5VZMdhqQbi21Kq(xR1e0BuU)R1mh1hvjw)6I0QMEnb1W2HMknQjsY9i5IAIVGCHTdzgEwg8pSD4aenGfgG9gcI5l00Y(4LiHNldllKW2Rdq0a8CaEoGfgWhouFMKS5HbzOg2o0makQbi72z6cLjjBEyqgbTIt5di1aeKMbaVbiMb4XaenaphWcd4dhQpd9gL7)AnZr9rvImudBhAgaf1aKD7mDHYqVr5(VwZCuFuLiJGwXP8bKAacsZaG3aOTdGIAaYUDMUqzO3OC)xRzoQpQsKrqR4u(asnabPzaWBaWCaIgqz7GlV2fizaPOpaAnakQb8braF2Fwy(7S5WbS0ae7bqrnGfgWhouFghjXA5zXqnSDOzaIgGSBNPlug6nk3)1AMJ6JQeze0koLpGudqqAga8gG)dWJbiAaEoGfgWhouFg0PHltqjSTEQad1W2HMbqrnaz3otxOmOtdxMGsyB9ubgbTIt5di1aeKMbaVbqBhaf1aKD7mDHYGonCzckHT1tfye0koLpGudqqAga8gamhGObu2o4YRDbsgqk6dGwdGIAalmGpCO(mosI1YZIHAy7qZaenaz3otxOmOtdxMGsyB9ubgbTIt5di1aeKMbaVb4)a8yaIgGNdyHb8Hd1NXrsSwEwmudBhAgaf1aKD7mDHY4ijwlplgbTIt5dagdqqAga8hqz7GlV2fizaPgGygaf1a(WH6ZGonCzckHT1tfyOg2o0makQb8Hd1NHEJY9FTM5O(OkrgQHTdndGIAaY2hQH(myHJCHoapgaf1a8CaF4q9zLTdUC4dvbKWqnSDOzaIgGSBNPluwz7Glh(qvajmcAfNYhWsdqqAga8gGygaf1aS3qqSY2bxo8HQasy71bqrna7neets28WGS96aena7neets28WGm(hsyhWsdqC)gGhdWJAsi)R1AI58DkM5FtSQFDrywtVMGAy7qtLg1ej5EKCrnXZbSWa(WH6ZKKnpmid1W2HMbqrnaz3otxOmjzZddYiOvCkFaPgGG0ma4naXmapgGOb45awyaF4q9zO3OC)xRzoQpQsKHAy7qZaOOgGSBNPlug6nk3)1AMJ6JQeze0koLpGudqqAga8gaTDauudq2TZ0fkd9gL7)AnZr9rvImcAfNYhqQbiindaEdaMdq0akBhC51Uajdif9bqRbqrnGpic4Z(ZcZFNnhoGLgGypakQbSWa(WH6Z4ijwlplgQHTdndq0aKD7mDHYqVr5(VwZCuFuLiJGwXP8bKAacsZaG3a8FaEmardWZbSWa(WH6ZGonCzckHT1tfyOg2o0makQbi72z6cLbDA4YeucBRNkWiOvCkFaPgGG0ma4naA7aOOgGSBNPlug0PHltqjSTEQaJGwXP8bKAacsZaG3aG5aenGY2bxETlqYasrFa0AauudyHb8Hd1NXrsSwEwmudBhAgGObi72z6cLbDA4YeucBRNkWiOvCkFaPgGG0ma4na)hGhdq0a8CalmGpCO(mosI1YZIHAy7qZaOOgGSBNPlughjXA5zXiOvCkFaWyacsZaG)akBhC51Uajdi1aeZaOOgWhouFg0PHltqjSTEQad1W2HMbqrnGpCO(m0BuU)R1mh1hvjYqnSDOzauudq2(qn0NblCKl0b4XaOOgWhouFwz7Glh(qvajmudBhAgGObi72z6cLv2o4YHpufqcJGwXP8bS0aeKMbaVbiMbqrna7neeRSDWLdFOkGe2EDauudWEdbXKKnpmiBVoardWEdbXKKnpmiJ)He2bS0ae3VAsi)R1AYJwRUGWZ(qI5KF9RlsBRPxtqnSDOPsJAIKCpsUOM4lixy7qMHNLb)dBhoard4dhQpJJKyT8SyOg2o0mard4dhQpd60WLjOe2wpvGHAy7qZaenaphGSBNPlughjXA5zXiyyGBaIgGSBNPlug0PHltqjSTEQaJGwXP8bKAa0AaWBacsZaOOgGSBNPlughjXA5zXiOvCkFaPgGyga8gGG0mardq2TZ0fkd60WLjOe2wpvGrqR4u(awAa0AaWBacsZa8yaIgqz7GlV2fiza0hqz7GlV2fiHzfExtc5FTwtmNVtXm)BIv9RlsBQPxtqnSDOPsJAIKCpsUOM8Hd1NXrsSwEwmudBhAgGOb8Hd1NbDA4YeucBRNkWqnSDOzaIgGNdq2TZ0fkJJKyT8SyemmWnardq2TZ0fkd60WLjOe2wpvGrqR4u(asnaAna4nabPzauudq2TZ0fkJJKyT8Sye0koLpGudqmdaEdqqAgGObi72z6cLbDA4YeucBRNkWiOvCkFalnaAna4nabPzaEmardOSDWLx7cKma6dOSDWLx7cKWScVRjH8VwRjpAT6ccp7djMt(1V(1ez3otxO8A61ffVMEnb1W2HMknQjsY9i5IAI9gcIf(qv4uHCbj(s2EDauudWEdbXKKnpmiBVoardWEdbXKKnpmiJ)He2bqFaI73aOOgGDZ5dq0aGoHYptqR4u(awAa(dZAsi)R1AYA)xR1VUO)10RjOg2o0uPrnrsUhjxut4ROZL)GiGpN5oHYNNx22iyH6pGu0hG)dGIAalmasCMm6d1NfgdNHEF8NpakQbqIZKrFO(SWy4SthqQbqBG5aOOgajotg9H6ZcJHZ2R1Kq(xR1e3ju(88Y2gblu)6xxum10RjOg2o0uPrnrsUhjxutS3qqSWhQcNkKliXxY2RdGIAa2BiiMKS5Hbz71biAa2BiiMKS5Hbz8pKWoa6dqC)QjH8VwRjqhbTDDBQFDrAvtVMGAy7qtLg1ej5EKCrnXZbSWa(WH6ZqVr5(VwZCuFuLid1W2HMbqrnaz3otxOm0BuU)R1mh1hvjYiOvCkFalnay6)a8yaIga0ju(zcAfNYhqQbiomRjH8VwRj8YdDMCdL9HQagQeRFDrywtVMeY)ATMy7qo)uHCdL5BllKutqnSDOPsJ6xxK2wtVMeY)ATMy7qo)uHCdLJ9VT0AcQHTdnvAu)6I0MA61Kq(xR1eBhY5NkKBOCXPpsQjOg2o0uPr9Rlk210RjH8VwRj2oKZpvi3qz(k5uHAcQHTdnvAu)6IPXA61eudBhAQ0OMeY)ATMCkxs2Fy7WCAzh6VTYg03jXAIKCpsUOMyVHGyHpufovixqIVKTxhaf1aS3qqmjzZddY2Rdq0aS3qqmjzZddY4FiHDa0hG4(nakQby3C(aenaOtO8Ze0koLpGLgGy8RMOHfwtoLlj7pSDyoTSd93wzd67Ky9RlkUF10RjOg2o0uPrnjK)1AnP9HKIs0zDQqETlqswsGJ)HRMij3JKlQj2Biiw4dvHtfYfK4lz71bqrna7neets28WGS96aena7neets28WGm(hsyha9biUFdGIAa2nNparda6ek)mbTIt5dyPbiomRjAyH1K2hskkrN1Pc51Uajzjbo(hU6xxuCXRPxtqnSDOPsJAsi)R1AIjiWA1TMnOe2SVMeY7HRMij3JKlQj2Biiw4dvHtfYfK4lz71bqrna7neets28WGS96aena7neets28WGm(hsyha9biUFdGIAa2nNparda6ek)mbTIt5dyPb4VF1enSWAIjiWA1TMnOe2SVMeY7HR(1ff3)A61eudBhAQ0OMeY)ATMyfYWMGzEjIF2AZpznrsUhjxutS3qqSWhQcNkKliXxY2RdGIAa2BiiMKS5Hbz71biAa2BiiMKS5Hbz8pKWoa6dqC)gaf1aSBoFaIga0ju(zcAfNYhWsdWF)QjAyH1eRqg2emZlr8ZwB(jRFDrXftn9AcQHTdnvAut0WcRjgcggOJGzFiNJUAsi)R1AIHGHb6iy2hY5OR(1ffNw10RjOg2o0uPrnrdlSMWHD7Gfj8CXPc1Kq(xR1eoSBhSiHNlovO(1ffhM10RjOg2o0uPrnrdlSMiqoRSSnO31Kq(xR1ebYzLLTb9U(1ffN2wtVMGAy7qtLg1enSWAIfA1e4YnuEn4FMFkVMeY)ATMyHwnbUCdLxd(N5NYRFDrXPn10RjOg2o0uPrnrdlSMWxdcMTW4ZLDdBnjK)1AnHVgemBHXNl7g26xxuCXUMEnb1W2HMknQjAyH1eE48fcOjdT5xR5WA1DqhsQjH8VwRj8W5leqtgAZVwZH1Q7GoKu)6IINgRPxtqnSDOPsJAsi)R1AYwLLXPOjl4cZfFt4z7WiG5gkdHKwEpC1ej5EKCrnXEdbXcFOkCQqUGeFjBVoakQbyVHGysYMhgKTxhGObyVHGysYMhgKX)qc7asrFaI73aOOgGSBNPluw4dvHtfYfK4lze0koLpGudGwWCauudq2TZ0fkts28WGmcAfNYhqQbqlywt0WcRjBvwgNIMSGlmx8nHNTdJaMBOmesA59Wv)6I(7xn9AcQHTdnvAutc5FTwt2QSmofn5GVEKqFE2omcyUHYqiPL3dxnrsUhjxutS3qqSWhQcNkKliXxY2RdGIAa2BiiMKS5Hbz71biAa2BiiMKS5Hbz8pKWoGu0hG4(nakQbi72z6cLf(qv4uHCbj(sgbTIt5di1aOfmhaf1aKD7mDHYKKnpmiJGwXP8bKAa0cM1enSWAYwLLXPOjh81Je6ZZ2HraZnugcjT8E4QFDr)fVMEnb1W2HMknQjH8VwRj8tH2USGlmx8nHNTdJaMBOmesA59WvtKK7rYf1e7neel8HQWPc5cs8LS96aOOgG9gcIjjBEyq2EDaIgG9gcIjjBEyqg)djSdif9biUFdGIAaYUDMUqzHpufovixqIVKrqR4u(asnaAbZbqrnaz3otxOmjzZddYiOvCkFaPgaTGznrdlSMWpfA7YcUWCX3eE2omcyUHYqiPL3dx9Rl6V)10RjOg2o0uPrnjK)1AnHFk02Ld(6rc95z7WiG5gkdHKwEpC1ej5EKCrnXEdbXcFOkCQqUGeFjBVoakQbyVHGysYMhgKTxhGObyVHGysYMhgKX)qc7asrFaI73aOOgGSBNPluw4dvHtfYfK4lze0koLpGudGwWCauudq2TZ0fkts28WGmcAfNYhqQbqlywt0WcRj8tH2UCWxpsOppBhgbm3qziK0Y7HR(1f9xm10RjOg2o0uPrnrsUhjxutS3qqSWhQcNkKliXxY2RdGIAa2BiiMKS5Hbz71biAa2BiiMKS5Hbz8pKWoGu0hG4(vtc5FTwt2CmFpAXRFDr)Pvn9AcQHTdnvAutKK7rYf1ephqz7GlV2fizaPOpaAnard4plCalnayoakQbu2o4YRDbsgqk6dqmdq0a8Ca)zHdi1aG5aOOgazRiuteq2xIzRq44pjEKNx22iyH6ZqnSDOzaEmakQb8Hd1Nv2o4YHpufqcd1W2HMbiAaYUDMUqzLTdUC4dvbKWiOvCkFa0hGFdWJbiAaEoGfgWhouFghjXA5zXqnSDOzauudq2TZ0fkJJKyT8Sye0koLpGudWVbqrnGpCO(mEOY)Go0KliXxYqnSDOzaEutc5FTwtcFOkCQqUGeFz9Rl6pmRPxtqnSDOPsJAIKCpsUOMu2o4YRDbsgqk6dGwdq0a(ZchWsdaMdGIAaLTdU8AxGKbKI(aeZaenG)SWbKAaWCauud4dhQpRSDWLdFOkGegQHTdndq0aKD7mDHYkBhC5WhQciHrqR4u(aOpa)QjH8VwRjsYMhgS(1f9N2wtVMeY)ATMe8suZLHZ1f1eudBhAQ0O(1f9N2utVMGAy7qtLg1ej5EKCrn5plm)DUCvya0hGFdq0a8Ca2Biiw4dvHtfYfK4lz71bqrna7neets28WGS96aOOgG9gcIf(qv4uHCbj(sMPl0biAaYUDMUqzHpufovixqIVKrqR4u(asnaA53aOOgG9gcIjjBEyqMPl0biAaYUDMUqzsYMhgKrqR4u(asnaA53a8OMeY)ATMu2o4YHpufqs9Rl6VyxtVMGAy7qtLg1ej5EKCrnXZbu2o4YRDbsgqk6dGwdq0a(ZchWsdqShaf1akBhC51Uajdif9biMbiAa)zHdif9bi2dWJbiAaYUDMUqzHpufovixqIVKrqR4u(asnabPzaIgWFwy(7C5QWaOpa)gGOb45awyaF4q9zCKeRLNfd1W2HMbqrna7neeJJKyT8Sy71b4XaenaphWcdGeNjJ(q9zHXWzO3h)5dGIAaK4mz0hQplmgoBVoakQbqIZKrFO(SWy4SthqQbql)gGh1Kq(xR1eOtdxMGsyB9uH6x)6x)6xR]] )


end
