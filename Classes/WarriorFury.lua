-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local IsActiveSpell = ns.IsActiveSpell


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 72 )

    local base_rage_gen, fury_rage_mult = 1.75, 1.00
    local offhand_mod = 0.50

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand_fury = {
            swing = "mainhand",

            last = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = "mainhand_speed",

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * ( base_rage_gen * fury_rage_mult * state.swings.mainhand_speed / state.haste )
            end
        },

        offhand_fury = {
            swing = "offhand",

            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            interval = "offhand_speed",

            stop = function () return state.time == 0 or state.swings.offhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.offhand_speed * offhand_mod / state.haste
            end,
        },

        bladestorm = {
            aura = "bladestorm",

            last = function ()
                local app = state.buff.bladestorm.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / ( 1 * state.haste ) ) * ( 1 * state.haste ) )
            end,

            interval = function () return 1 * state.haste end,

            value = 5,
        },

        battle_trance = {
            aura = "battle_trance",

            last = function ()
                local app = state.buff.battle_trance.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / state.haste ) * state.haste )
            end,

            interval = 3,

            value = 5,
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        war_machine = 22632, -- 262231
        sudden_death = 22633, -- 280721
        fresh_meat = 22491, -- 215568

        double_time = 19676, -- 103827
        impending_victory = 22625, -- 202168
        storm_bolt = 23093, -- 107570

        massacre = 22379, -- 206315
        frenzy = 22381, -- 335077
        onslaught = 23372, -- 315720

        furious_charge = 23097, -- 202224
        bounding_stride = 22627, -- 202163
        warpaint = 22382, -- 208154

        seethe = 22383, -- 335091
        frothing_berserker = 22393, -- 215571
        cruelty = 19140, -- 335070

        meat_cleaver = 22396, -- 280392
        dragon_roar = 22398, -- 118000
        bladestorm = 22400, -- 46924

        anger_management = 22405, -- 152278
        reckless_abandon = 22402, -- 202751
        siegebreaker = 16037, -- 280772
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {         
        barbarian = 166, -- 280745
        battle_trance = 170, -- 213857
        bloodrage = 172, -- 329038
        death_sentence = 25, -- 198500
        death_wish = 179, -- 199261
        demolition = 5373, -- 329033
        disarm = 3533, -- 236077       
        enduring_rage = 177, -- 198877
        master_and_commander = 3528, -- 235941
        overwatch = 5375, -- 329035
        slaughterhouse = 3735, -- 280747        
    } )


    -- Auras
    spec:RegisterAuras( {
        battle_shout = {
            id = 6673,
            duration = 3600,
            max_stack = 1,
            shared = "player", -- check for anyone's buff on the player.
        },
        berserker_rage = {
            id = 18499,
            duration = 6,
            type = "",
            max_stack = 1,
        },
        bladestorm = {
            id = 46924,
            duration = function () return 4 * haste end,
            max_stack = 1,
        },
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        charge = {
            id = 105771,
            duration = 1,
            max_stack = 1,
        },
        enrage = {
            id = 184362,
            duration = 4,
            max_stack = 1,
        },
        enraged_regeneration = {
            id = 184364,
            duration = 8,
            max_stack = 1,
        },
        frenzy = {
            id = 335082,
            duration = 12,
            max_stack = 3,      
        },
        furious_charge = {
            id = 202225,
            duration = 5,
            max_stack = 1,
        },
        hamstring= { 
            id = 1715,
            duration = 15,
            max_stack = 1,
        },
        ignore_pain = {
            id = 190456,
            duration = 12,
            max_stack = 1,
        },
        intimidating_shout = {
            id = 5246,
            duration = 8,
            max_stack = 1,
        },
        piercing_howl = {
            id = 12323,
            duration = 8,
            max_stack = 1,
        },
        rallying_cry = {
            id = 97463,
            duration = function () return azerite.moment_of_glory.enabled and 12 or 10 end,
            max_stack = 1,
        },
        recklessness = {
            id = 1719,
            duration = 12,
            max_stack = 1,
        },
        siegebreaker = {
            id = 280773,
            duration = 10,
            max_stack = 1,
        },
        storm_bolt = {
            id = 132169,
            duration = 4,
            max_stack = 1,
        },
        sudden_death = {
            id = 280776,
            duration = 10,
            max_stack = 1,
        },
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
        victorious = {
            id = 32216,
            duration = 20,
            max_stack = 1,
        },
        whirlwind = {
            id = 85739,
            duration = 20,
            max_stack = function () return talent.meat_cleaver.enabled and 4 or 2 end,
            copy = "meat_cleaver"
        },


        -- Azerite Powers
        gathering_storm = {
            id = 273415,
            duration = 6,
            max_stack = 5,
        },

        -- Cold Steel, Hot Blood
        gushing_wound = {
            id = 288091,
            duration = 6,
            max_stack = 1,
        },

        intimidating_presence = {
            id = 288644,
            duration = 12,
            max_stack = 1,
        },

        moment_of_glory = {
            id = 280210,
            duration = 12,
            max_stack = 1,
        },


        -- PvP Talents
        battle_trance = {
            id = 213858,
            duration = 18,
            max_stack = 1
        }
    } )


    spec:RegisterGear( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
        spec:RegisterAura( "raging_thirst", {
            id = 242300, 
            duration = 8
         } ) -- fury 2pc.
        spec:RegisterAura( "bloody_rage", {
            id = 242952,
            duration = 10,
            max_stack = 10
         } ) -- fury 4pc.

    spec:RegisterGear( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )
        spec:RegisterAura( "slaughter", {
            id = 253384,
            duration = 4
        } ) -- fury 2pc dot.
        spec:RegisterAura( "outrage", {
            id = 253385,
            duration = 8
         } ) -- fury 4pc.

    spec:RegisterGear( "ceannar_charger", 137088 )
    spec:RegisterGear( "timeless_stratagem", 143728 )
    spec:RegisterGear( "kazzalax_fujiedas_fury", 137053 )
        spec:RegisterAura( "fujiedas_fury", {
            id = 207776,
            duration = 10,
            max_stack = 4 
        } )
    spec:RegisterGear( "mannoroths_bloodletting_manacles", 137107 ) -- NYI.
    spec:RegisterGear( "najentuss_vertebrae", 137087 )
    spec:RegisterGear( "valarjar_berserkers", 151824 )
    spec:RegisterGear( "ayalas_stone_heart", 137052 )
        spec:RegisterAura( "stone_heart", { id = 225947,
            duration = 10
        } )
    spec:RegisterGear( "the_great_storms_eye", 151823 )
        spec:RegisterAura( "tornados_eye", {
            id = 248142, 
            duration = 6, 
            max_stack = 6
        } )
    spec:RegisterGear( "archavons_heavy_hand", 137060 )
    spec:RegisterGear( "weight_of_the_earth", 137077 ) -- NYI.

    spec:RegisterGear( "soul_of_the_battlelord", 151650 )

    state.IsActiveSpell = IsActiveSpell

    local whirlwind_consumers = {
        bloodthirst = 1,
        execute = 1,
        impending_victory = 1,
        raging_blow = 1,
        rampage = 1,
        siegebreaker = 1,
        victory_rush = 1
    }

    local whirlwind_gained = 0
    local whirlwind_stacks = 0

    local rageSpent = 0
    local rageSinceBanner = 0 


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event )
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" then
            local ability = class.abilities[ spellID ]

            if not ability then return end

            if ability.key == "whirlwind" then
                whirlwind_gained = GetTime()
                whirlwind_stacks = state.talent.meat_cleaver.enabled and 4 or 2
            
            elseif whirlwind_consumers[ ability.key ] and whirlwind_stacks > 0 then
                whirlwind_stacks = whirlwind_stacks - 1

            end

            if ability.key == "conquerors_banner" then
                rageSinceBanner = 0
            end
        end
    end )


    local RAGE = Enum.PowerType.Rage
    local lastRage = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( unit, powerType )
        if powerType == RAGE then
            local current = UnitPower( "player", RAGE )

            if current < lastRage then
                rageSpent = ( rageSpent + lastRage - current ) % 20 -- Recklessness.             
                rageSinceBanner = ( rageSinceBanner + lastRage - current ) % 30 -- Glory.
            end

            lastRage = current
        end
    end )

    spec:RegisterStateExpr( "rage_spent", function ()
        return rageSpent
    end )

    spec:RegisterStateExpr( "rage_since_banner", function ()
        return rageSinceBanner
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" then
            if talent.recklessness.enabled then
                rage_spent = rage_spent + amt
                cooldown.recklessness.expires = cooldown.recklessness.expires - floor( rage_spent / 20 )
                rage_spent = rage_spent % 20
            end

            if buff.conquerors_frenzy.up then
                rage_since_banner = rage_since_banner + amt
                local stacks = floor( rage_since_banner / 30 )
                rage_since_banner = rage_since_banner % 30

                if stacks > 0 then addStack( "glory", nil, stacks ) end
            end
        end
    end )


    spec:RegisterHook( "reset_precast", function ()
        rage_spent = nil
        rage_since_banner = nil
        
        if buff.bladestorm.up then
            setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.bladestorm.remains ) )
            if buff.gathering_storm.up then
                applyBuff( "gathering_storm", buff.bladestorm.remains + 6, 5 )
            end
        end

        if buff.whirlwind.up then
            if whirlwind_stacks == 0 then removeBuff( "whirlwind" )
            elseif whirlwind_stacks < buff.whirlwind.stack then
                applyBuff( "whirlwind", buff.whirlwind.remains, whirlwind_stacks )
            end
        end

        if legendary.will_of_the_berserker.enabled and buff.recklessness.up then
            applyBuff( "will_of_the_berserker" )
            buff.will_of_the_berserker.applied = buff.recklessness.expires
            buff.will_of_the_berserker.expires = buff.recklessness.expires + 8
        end
    end )    


    -- Abilities
    spec:RegisterAbilities( {
        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 132333,

            essential = true,
            nobuff = "battle_shout",

            handler = function ()
                applyBuff( "battle_shout" )
            end,
        },


        berserker_rage = {
            id = 18499,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136009,

            handler = function ()
                applyBuff( "berserker_rage" )
            end,
        },


        bladestorm = {
            id = 46924,
            cast = function () return 4 * haste end,
            channeled = true,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 236303,

            talent = "bladestorm",
            range = 8,

            start = function ()
                applyBuff( "bladestorm" )
                gain( 5, "rage" )

                if azerite.gathering_storm.enabled then
                    applyBuff( "gathering_storm", 6 + ( 4 * haste ), 5 )
                end
            end,
        },


        bloodthirst = {
            id = 23881,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = function () return ( talent.seethe.enabled and ( stat.crit >= 100 and -4 or -2 ) or 0 ) - 8 end,
            spendType = "rage",

            startsCombat = true,
            texture = 136012,

            handler = function ()
                gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ), "health" )

                removeBuff( "bloody_rage" )
                removeStack( "whirlwind" )

                if azerite.cold_steel_hot_blood.enabled and stat.crit >= 100 then
                    applyDebuff( "target", "gushing_wound" )
                    gain( 4, "rage" )
                end

                if legendary.cadence_of_fujieda.enabled then
                    addStack( "cadence_of_fujieda", nil, 1 )
                end
            end,

            auras = {
                cadence_of_fujieda = {
                    id = 335558,
                    duration = 8,
                    max_stack = 4,
                },
            }
        },


        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or nil end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 132337,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute ) end,
            handler = function ()
                applyDebuff( "target", "charge" )
                if talent.furious_charge.enabled then applyBuff( "furious_charge" ) end
                setDistance( 5 )
            end,
        },


        dragon_roar = {
            id = 118000,
            cast = 0,
            cooldown = 35,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 642418,

            talent = "dragon_roar",
            range = 12,
        },


        enraged_regeneration = {
            id = 184364,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 132345,

            handler = function ()
                applyBuff( "enraged_regeneration" )
            end,
        },


        execute = {
            id = function () return IsActiveSpell( 280735 ) and 280735 or 5308 end,
            known = 5308,
            noOverride = 317485,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",

            spend = -20,
            spendType = "rage",

            startsCombat = true,
            texture = 135358,

            usable = function () return buff.sudden_death.up or buff.stone_heart.up or target.health.pct < ( IsActiveSpell( 280735 ) and 35 or 20 ) end,
            handler = function ()
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                elseif buff.sudden_death.up then removeBuff( "sudden_death" ) end
                removeStack( "whirlwind" )
            end,

            copy = { 280735, 5308 }
        },


        heroic_leap = {
            id = 6544,
            cast = 0,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 236171,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
        },

        ignore_pain = {
            id = 190456,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            toggle = "defensives",

            spend = 80,
            spendType = "rage",

            startsCombat = false,
            texture = 1377132,

            handler = function ()
                applyBuff( "ignore_pain" )
            end,
        },


        impending_victory = {
            id = 202168,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = true,
            texture = 589768,

            talent = "impending_victory",

            handler = function ()
                gain( health.max * 0.3, "health" )
                removeStack( "whirlwind" )
            end,
        },


        intimidating_shout = {
            id = 5246,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132154,

            handler = function ()
                applyDebuff( "target", "intimidating_shout" )
                --if azerite.intimidating_presence.enabled then applyDebuff( "target", "intimidating_presence" ) end
            end,
        },


        onslaught = {
            id = 315720,
            cast = 0,
            cooldown = 12,
            hasteCD = true,
            gcd = "spell",

            spend = -15,
            spendType = "rage",

            startsCombat = true,
            texture = 132364,

            buff = "enrage",

            handler = function ()
                removeStack( "whirlwind" )
            end,
        },

        piercing_howl = {
            id = 12323,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 136147,

            handler = function ()
                applyDebuff( "target", "piercing_howl" )
            end,
        },


        pummel = {
            id = 6552,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 132938,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        raging_blow = {
            id = 85288,
            cast = 0,
            charges = 2,
            cooldown = 8,
            recharge = 8,
            hasteCD = true,
            gcd = "spell",

            spend = -12,
            spendType = "rage",

            startsCombat = true,
            texture = 589119,

            handler = function ()
                removeStack( "whirlwind" )

                if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = buff.will_of_the_berserker.expires + 8 end
            end,
        },


        rallying_cry = {
            id = 97462,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 132351,

            handler = function ()
                applyBuff( "rallying_cry" )

                if azerite.moment_of_glory.enabled then applyBuff( "moment_of_glory" ) end
            end,
        },


        rampage = {
            id = 184367,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 80,
            spendType = "rage",

            startsCombat = true,
            texture = 132352,

            handler = function ()
                if talent.frenzy.enabled then addStack( "frenzy", nil, 1 ) end
                applyBuff( "enrage" )
                removeStack( "whirlwind" )  
            end,
        },


        recklessness = {
            id = 1719,
            cast = 0,
            cooldown = 90,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 458972,

            handler = function ()
                applyBuff( "recklessness" )
                if talent.reckless_abandon.enabled then gain( 20, "rage" ) end
                if legendary.will_of_the_berserker.enabled then
                    applyBuff( "will_of_the_berserker" )
                    buff.will_of_the_berserker.applied = buff.recklessness.expires
                    buff.will_of_the_berserker.expires = buff.recklessness.expires + 8
                end
            end,

            auras = {
                will_of_the_berserker = {
                    id = 335597,
                    duration = 8,
                    max_stack = 1
                }
            }
        },

        shattering_throw = {
            id = 64382,
            cast = 1.5,
            cooldown = 180,
            gcd = "spell",

            startsCombat = true,
            texture = 311430,

            range = 30,
        },


        siegebreaker = {
            id = 280772,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 294382,

            talent = "siegebreaker",

            handler = function ()
                applyDebuff( "target", "siegebreaker" )
                removeStack( "whirlwind" )
            end,
        },


        slam = {
            id = 1464,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 20,
            spendType = "rage",

            startsCombat = true,
            texture = 132340,

            handler = function ()
                removeStack( "whirlwind" )
            end,
        },


        spell_reflect = {
            id = 23920,
            cast = 0,
            cooldown = 25,
            gcd = "off",

            toggle = "interrupts",

            startsCombat = false,
            texture = 132361,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                applyDebuff( "target", "storm_bolt" )
            end,
        },

        storm_bolt = {
            id = 107570,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 613535,

            talent = "storm_bolt",

            handler = function ()
                applyDebuff( "target", "storm_bolt" )
            end,
        },


        taunt = {
            id = 355,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            startsCombat = true,
            texture = 136080,

            handler = function ()
                applyDebuff( "target", "taunt" )
            end,
        },


        victory_rush = {
            id = 34428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132342,

            notalent = "impending_victory",
            buff = "victorious",

            handler = function ()
                removeBuff( "victorious" )
                removeStack( "whirlwind" )
            end,
        },


        whirlwind = {
            id = 190411,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132369,

            usable = function ()
                if settings.check_ww_range and target.outside7 then return false, "target is outside of whirlwind range" end
                return true
            end,

            handler = function ()
               applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_unbridled_fury",

        package = "Fury",
    } )


    spec:RegisterSetting( "check_ww_range", false, {
        name = "Check |T132369:0|t Whirlwind Range",
        desc = "If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } ) 


    spec:RegisterPack( "Fury", 20200830, [[dKukOaqiIOhreAtiPgLivNsvfVcPywKkDlrI2ff)svvdJO0Xiv1YikEMijttvL4AIuABKkY3uvjnosf15qkX6qkjnpsfUhs1(ejCqvvQfQQ0djcktuKI6IIKs2isjXifjfDsrkYkjfZuKcUjrq1orcdvKu1sfjvEQctvvXvfjLARIKcFvKcTxv(RQmysoSWIf1JjmzQCzWMP0NrvJMO60qTAIaVMinBQ62OYUL8BedxehhPKA5k9CitxQRROTJK8DKOXteKZtQY6rk18jL2pkF6FFUHlA4OqgzLrwz15ujRrFDkvYK2F9gTEjWnscH0GhUrfCWnOvMRE3ij0Ztc395giYCfWnK3DcIw9)FEClFMncc3FeMB6JgtkXg2(pcZj(FJ8e770uD5B4IgokKrwzKvwDovYA0xNsLmPvNUrmB5K9gdmNegt9NP(9kKJ5A8sq3qo25G6Y3WbiXnKitrRmx9yQ0ySlMSmnsKP(9KFIAMkvYQltjJSYiltdtJezkjm5rXdiAvMgjYuPKP(TZboMk1p54aVHPrImvkzQ0mgfzp4ykocvahunt9NPsnHLGfmvAaIeMseEptLErAMQaWboMYswMcxPKp4aMsqQgKq9pgMgjYuPKPKWjuboM6RpCaQjlhtfLJPsZBWtkMk1rILPImHkGP(6jexlhVOMPActH5swcvatzxGwpHsOhtrSm1ccchhuUOXKcXuPJWCiMAjtE5E9ykGwpd)pgMgjYuPKP(TZboM6B0ThyQHCYSzQMWujliiC5OzQFN6tdgMgjYuPKP(TZboMk1alAYQhtL6Mi5mvKjubmfcx8EiLDS8qZuPr541tjUCgMgjYuPKP(TZboMk1gbmvAQboK5gEmQr3NBGWfVhEDS8qFFok0)(CJq0ysDdeg4H8cHuyVbur2dU771hfYCFUbur2dU77nelUHfh3iDMkpTwZccPEaHkaHmZeMsRwMkpTwdhWrw9Ee7Zpfy3ZTqWHmZeM6hMsRwMkDMQdpuTXUKwoU4FzyrWkfwdur2doMsRwMQdpuTreBf8GbQi7bhtrntLotLNwRbQn4bZcCbUqmLoykEHJP0QLP2GhyQuWu0ISm1pmLwTmvhEOAdxGqHybdur2doMIAMkDMkpTwduBWdMf4cCHykDWu8chtPvltTbpWuPGPOfzzQFyQFUriAmPUXgCjbpC9rrQUp3ienMu3aKqGy2WnGkYEWDFV(O4xUp3ienMu3qqkhWv3aQi7b3996JI0EFUbur2dU77nelUHfh3izbQE8cNrFZgCjbpCJq0ysDJSpCaQjl31hf6095gqfzp4UV3qS4gwCCJ80AnqTbpyMj3ienMu3WTbpPElj2Rpk(17ZnGkYEWDFVHyXnS44g5P1AGAdEW4iuwmLwTmvqByXnyeeV7HAa8p5K(L9eIZSrjLPsbtP)ncrJj1nYEcX1YXlQV(OqNVp3aQi7b399gIf3WIJBiKhlpGyk6mLm3ienMu3ydECX)YEcLxFuql3NBeIgtQBK9eIRLJxuFdOIShC33Rpk0x27ZnGkYEWDFVHyXnS44gD4HQnIyRGhmqfzp4ykTAzQ0zQo8q1gUaHcXcgOIShCmf1m1g8atPdMsNLLP(HP0QLPsNP6WdvBSlPLJl(xgweSsH1avK9GJPOMP2GhykDWu0ISm1p3ienMu3ydECX)YEcLxFuOV(3NBeIgtQBqfw0KvV3orYVbur2dU771hf6lZ95gHOXK6gyUeOC4I)rfw0KvVBavK9G7(E9rH(P6(CJq0ysDdkLJxpL4YDdOIShC33RV(goWgtFFFok0)(CJq0ysDdH8y5HBavK9G7(E9rHm3NBeIgtQBKm54a)nGkYEWDFV(Oiv3NBavK9G7(EdXIByXXnsNP2a7Eavq1gocvahuTXHrDucGPsbtjtAzkQzQnWUhqfuTHJqfWbvBWftLcM6xslt9ZncrJj1nKdlblEEisU(O4xUp3aQi7b399gIf3WIJBKNwRHFgRdh1JyFbTHL0YnZeMsRwMkDMssMcqiOeGrqkhuiW98ylyjRamCHeqwMIAMQJLhAtJ5GxtEomWu6GotPtYYu)CJq0ysDJesJj11hfP9(CdOIShC33BiwCdloUHGq8ocLLzbHupGqfGqMf4cCHykDWuP6gHOXK6gBWLe8W1hf6095gqfzp4UV3qS4gwCCJ80AnliK6beQaeYmtUriAmPUr2tiUhX(A5WdkGtVRpk(17ZnGkYEWDFVHyXnS44gsYu5P1Awqi1diubiKzMWuuZusYu5P1AqyGhYlesH1mtUriAmPUrYCXw9Wf)l7duF9rHoFFUbur2dU77nelUHfh3qsMkpTwZccPEaHkaHmZeMIAMssMkpTwdcd8qEHqkSMzYncrJj1nwCsIhE46HscbC9rbTCFUbur2dU77nelUHfh3qsMkpTwZccPEaHkaHmZeMIAMssMkpTwdcd8qEHqkSMzYncrJj1nOKSEhvaUElGivuc46Jc9L9(CdOIShC33BiwCdloUHKmvEATMfes9acvaczMjmf1mLKmvEATgeg4H8cHuynZKBeIgtQByjIjcCVG2WIB4LHG76Jc91)(CdOIShC33BiwCdloUHKmvEATMfes9acvaczMjmf1mLKmvEATgeg4H8cHuynZKBeIgtQBSqKGl(N1hCa66Jc9L5(CdOIShC33BiwCdloUHKmvEATMfes9acvaczMjmf1mLKmvEATgeg4H8cHuynZeMIAMYrAJGucO6nAW9S(GdE55wMf4cCHyk6mLS3ienMu3qqkbu9gn4EwFWbxFuOFQUp3aQi7b399gIf3WIJBKNwRzbHupGqplzfGzMCJq0ysDJwo8MvMml3ZswbC9rH()Y95gqfzp4UV3qS4gwCCdjzQ80AnliK6beQaeYmtykQzQ0zQgZbVM8CyGPsbtPpTKwMsRwMQJLhAJCi8TCtIOzkDWuYilt9ZncrJj1n4NX6Wr9i2xqByjT8Rpk0pT3NBavK9G7(EdXIByXXnKKPYtR1SGqQhqOcqiZm5gHOXK6gCahz17rSp)uGDp3cbh66Jc91P7ZnGkYEWDFVHyXnS44g5P1Awqi1diubiKXrOSykQzkhKNwRbHbEiVqifwJJqzDJq0ysDdbPO1tyjl6LJQG96Jc9)17ZnGkYEWDFVHyXnS44gsYuacbLamcs5GcbUNhBblzfGHlKaYYuuZusYuacbLamzpH4Ee7RLdpOao9mCHeqwMsRwMsqiEhHYYWpJ1HJ6rSVG2WsA5Mf4cCHyQuWu6ZuA1Yu5P1A4NX6Wr9i2xqByjTCZmHP0QLPeeI3rOSmzpH4Ee7RLdpOao9mlWf4cXu6GP4fUBeIgtQBSGqQhqOcqORpk0xNVp3aQi7b399gIf3WIJBGsaV)1XYdnYqPC86PexoMkfmL(mf1mLKmvEATgoi6NWdbvWAMj3ienMu3Gs541tjUCxFuOpTCFUbur2dU77ncrJj1ncKCQIcqVnOnzFcYg(BiwCdloUrJ5GxtEomWu6GPKrwMsRwMssMYb5P1A2G2K9jiB4FoipTwZmHP0QLPsNP6y5H20yo41KxIOFPswMshmvAzkQzkhKNwRrqk3u0yQGhUK(CqEATMzct9dtPvltLotjjt5G80Ancs5MIgtf8WL0NdYtR1mtykQzQ80AnCahz17rSp)uGDp3cbhYmtykTAzQKfO6XlCgzm8ZyD4OEe7lOnSKwotPvltLSavpEHZiJzbHupGqfGqmf1mv6mLKmfGqqjadhWrw9Ee7Zpfy3ZTqWHmCHeqwMIAMssMcqiOeGrqkhuiW98ylyjRamCHeqwM6hM6NBubhCJajNQOa0BdAt2NGSH)6JczK9(CdOIShC33BubhCJn4sWf)l4s84E6GhpMpOI47hu84cUriAmPUXgCj4I)fCjECpDWJhZhur89dkECbxFuiJ(3NBeIgtQBmrWd3ah6gqfzp4UVxFuiJm3NBavK9G7(EdXIByXXnYtR1SGqQhqOcqiZm5gHOXK6gzpH4E25Q31hfYKQ7ZnGkYEWDFVHyXnS44g5P1Awqi1diubiKzMCJq0ysDJmSiyLIl(RpkK5xUp3aQi7b399gIf3WIJBKNwRzbHupGqfGqghHYIPOMPCqEATgeg4H8cHuynocL1ncrJj1n8yE5n6jbthphu91hfYK27ZnGkYEWDFVHyXnS44g5P1Awqi1diubiKXrOSykQzkhKNwRbHbEiVqifwJJqzDJq0ysDduce7JyF5a1ysD9rHm6095gqfzp4UV3qS4gwCCJ80AnliK6beQaeY4iuwmf1mLdYtR1GWapKxiKcRXrOSykQzQ0zQq0yQGhuahgqmvkyk9zkTAzQmbHyQFUriAmPUrucmu9lSnSi5eH0RpkK5xVp3aQi7b399gIf3WIJBKNwRzbHupGqfGqMzYncrJj1nS4fYEcXD9rHm6895gqfzp4UV3qS4gwCCJ80AnliK6beQaeYmtUriAmPUruca1B4FIW7V(OqgA5(CdOIShC33BiwCdloUrEATMfes9acvaczCeklMIAMYb5P1AqyGhYlesH14iuwmf1mvEATgO2GhmZKBeIgtQBKd(hX(6flKIU(OivYEFUbur2dU77ncrJj1n2z9crJj1ZJr9n8yu)QGdUbcx8E41XYd91xFdocvahu995Oq)7ZncrJj1nKdlblEEisUbur2dU771xFJKfeeUC03NJc9Vp3aQi7b3996JczUp3aQi7b3996JIuDFUbur2dU771hf)Y95gHOXK6g5OBp8qYjZ(gqfzp4UVxFuK27ZnGkYEWDFVrfCWncAJKhBGEws1pI9LqOe2BeIgtQBe0gjp2a9SKQFe7lHqjSxFuOt3NBeIgtQBqjz9oQaC9warQOeWnGkYEWDFV(O4xVp3ienMu3Gd4iREpI95NcS75wi4q3aQi7b3996JcD((CJq0ysDd(zSoCupI9f0gwsl)gqfzp4UVxFuql3NBeIgtQBSGqQhqOcqOBavK9G7(E9rH(YEFUriAmPUrcPXK6gqfzp4UVxF913GkyrysDuiJSYiRSYOVS3GYylCXJUrAIlHSn4yQFHPcrJjft5XOgzyAUbkbehf)Qm3izjwShUHezkAL5QhtLgJDXKLPrIm1VN8tuZuPswDzkzKvgzzAyAKitjHjpkEarRY0irMkLm1VDoWXuP(jhh4nmnsKPsjtLMXOi7bhtXrOc4GQzQ)mvQjSeSGPsdqKWuIW7zQ0lsZufaoWXuwYYu4kL8bhWucs1GeQ)XW0irMkLmLeoHkWXuF9Hdqnz5yQOCmvAEdEsXuPosSmvKjubm1xpH4A54f1mvtykmxYsOcyk7c06juc9ykILPwqq44GYfnMuiMkDeMdXulzYl3Rhtb06z4)XW0irMkLm1VDoWXuFJU9atnKtMnt1eMkzbbHlhnt97uFAWW0irMkLm1VDoWXuPgyrtw9yQu3ejNPImHkGPq4I3dPSJLhAMknkhVEkXLZW0irMkLm1VDoWXuP2iGPstnWHmmnmnsKPsTKqGy2GJPYGLSatjiC5OzQmWJlKHP(TqajnIPksLs5XYzNEMkenMuiMIuE9mmnHOXKczswqq4Yrt36dKuMMq0ysHmjliiC5OPH(FlH4yAcrJjfYKSGGWLJMg6)JjphuD0ysX0irMAurcsoPzQnWoMkpTwWXuOoAetLblzbMsq4YrZuzGhxiMkkhtLSqktiDJlEMcJykhPadttiAmPqMKfeeUC00q)Fo62dpKCYSzAcrJjfYKSGGWLJMg6)Ni4HBGt3k4a6bTrYJnqplP6hX(siuclttiAmPqMKfeeUC00q)pLK17OcW1BbePIsamnHOXKczswqq4Yrtd9)Cahz17rSp)uGDp3cbhIPjenMuitYcccxoAAO)NFgRdh1JyFbTHL0YzAcrJjfYKSGGWLJMg6)xqi1diubiettiAmPqMKfeeUC00q)FcPXKIPHPrImvQLeceZgCmfqfS6XunMdyQwoWuHOjltHrmvqvG9r2dgMMq0ysHOlKhlpW0eIgtken0)Nm54aptJezQpYXiMcJykocQ96XunHPswGkOAMsqiEhHYcXu2LWXuzax8mvieyhuD496Xute4yk3CXfptXrOc4GQnmnsKPcrJjfIg6)3z9crJj1ZJrTUvWb05iubCq16IT05iubCq1ghg1rjGuKwMMq0ysHOH(F5WsWINhIeDXw6PVb29aQGQnCeQaoOAJdJ6OeqkKjTuVb29aQGQnCeQaoOAdUsXVK2FyAcrJjfIg6)tinMu6IT0ZtR1WpJ1HJ6rSVG2WsA5MzIwTPljGqqjaJGuoOqG75XwWswby4cjGSu3XYdTPXCWRjphg0bDDs2FyAcrJjfIg6)3Glj4bDXw6ccX7iuwMfes9acvaczwGlWfshPIPjenMuiAO)p7je3JyFTC4bfWPNUyl980AnliK6beQaeYmtyAcrJjfIg6)tMl2QhU4FzFGADXw6sMNwRzbHupGqfGqMzc1sMNwRbHbEiVqifwZmHPjenMuiAO)FXjjE4HRhkjeGUylDjZtR1SGqQhqOcqiZmHAjZtR1GWapKxiKcRzMW0eIgtken0)tjz9oQaC9warQOeGUylDjZtR1SGqQhqOcqiZmHAjZtR1GWapKxiKcRzMW0eIgtken0)BjIjcCVG2WIB4LHGtxSLUK5P1Awqi1diubiKzMqTK5P1AqyGhYlesH1mtyAcrJjfIg6)xisWf)Z6doaPl2sxY80AnliK6beQaeYmtOwY80AnimWd5fcPWAMjmnHOXKcrd9)csjGQ3Ob3Z6doqxSLUK5P1Awqi1diubiKzMqTK5P1AqyGhYlesH1mtO2rAJGucO6nAW9S(GdE55wMf4cCHOllttiAmPq0q)FlhEZktML7zjRa0fBPNNwRzbHupGqplzfGzMW0eIgtken0)ZpJ1HJ6rSVG2WsA56IT0LmpTwZccPEaHkaHmZeQtVXCWRjphgsH(0sA1QTJLhAJCi8TCtIO1HmY(dttiAmPq0q)phWrw9Ee7Zpfy3ZTqWH0fBPlzEATMfes9acvaczMjmnHOXKcrd9)csrRNWsw0lhvbRUyl980AnliK6beQaeY4iuwu7G80AnimWd5fcPWACeklMMq0ysHOH()fes9acvacPl2sxsaHGsagbPCqHa3ZJTGLScWWfsazPwsaHGsaMSNqCpI91YHhuaNEgUqciRwTccX7iuwg(zSoCupI9f0gwsl3SaxGluk0xR280An8ZyD4OEe7lOnSKwUzMOvRGq8ocLLj7je3JyFTC4bfWPNzbUaxiDWlCmnHOXKcrd9)ukhVEkXLtxSLokb8(xhlp0idLYXRNsC5sH(ulzEATgoi6NWdbvWAMjmnHOXKcrd9)te8WnWPBfCa9ajNQOa0BdAt2NGSHxxSLEJ5GxtEomOdzKvRwjDqEATMnOnzFcYg(NdYtR1mt0Qn9owEOnnMdEn5Li6xQKvhPLAhKNwRrqk3u0yQGhUK(CqEATMzYpA1MUKoipTwJGuUPOXubpCj95G80AnZeQZtR1WbCKvVhX(8tb29CleCiZmrR2KfO6XlCgzm8ZyD4OEe7lOnSKwUwTjlq1Jx4mYywqi1diubie1PljGqqjadhWrw9Ee7Zpfy3ZTqWHmCHeqwQLeqiOeGrqkhuiW98ylyjRamCHeq2F(HPjenMuiAO)FIGhUboDRGdOVbxcU4FbxIh3th84X8bveF)GIhxattiAmPq0q))ebpCdCiMMq0ysHOH()SNqCp7C1txSLEEATMfes9acvaczMjmnHOXKcrd9)zyrWkfx86IT0ZtR1SGqQhqOcqiZmHPjenMuiAO)3J5L3ONemD8Cq16IT0ZtR1SGqQhqOcqiJJqzrTdYtR1GWapKxiKcRXrOSyAcrJjfIg6)rjqSpI9LduJjLUyl980AnliK6beQaeY4iuwu7G80AnimWd5fcPWACeklMMq0ysHOH()OeyO6xyByrYjcP6IT0ZtR1SGqQhqOcqiJJqzrTdYtR1GWapKxiKcRXrOSOo9q0yQGhuahgqPqFTAZee6hMMq0ysHOH(FlEHSNqC6IT0ZtR1SGqQhqOcqiZmHPjenMuiAO)pkbG6n8pr496IT0ZtR1SGqQhqOcqiZmHPjenMuiAO)ph8pI91lwifPl2sppTwZccPEaHkaHmocLf1oipTwdcd8qEHqkSghHYI680AnqTbpyMjmnHOXKcrd9)7SEHOXK65XOw3k4a6iCX7Hxhlp0mnmnHOXKcz4iubCq10LdlblEEisyAyAcrJjfYGWfVhEDS8qthHbEiVqifwMMq0ysHmiCX7Hxhlp00q))gCjbpOl2sp980AnliK6beQaeYmt0QnpTwdhWrw9Ee7Zpfy3ZTqWHmZKF0Qn9o8q1g7sA54I)LHfbRuynqfzp40QTdpuTreBf8GbQi7bh1PNNwRbQn4bZcCbUq6Gx40QDdEif0IS)OvBhEOAdxGqHybdur2doQtppTwduBWdMf4cCH0bVWPv7g8qkOfz)5hMMq0ysHmiCX7Hxhlp00q)piHaXSbMMq0ysHmiCX7Hxhlp00q)VGuoGRyAcrJjfYGWfVhEDS8qtd9)zF4autwoDXw6jlq1Jx4m6B2Glj4bMMq0ysHmiCX7Hxhlp00q)VBdEs9wsS6IT0ZtR1a1g8GzMW0eIgtkKbHlEp86y5HMg6)ZEcX1YXlQ1fBPNNwRbQn4bJJqzPvBqByXnyeeV7HAa8p5K(L9eIZSrjnf6Z0eIgtkKbHlEp86y5HMg6)3Ghx8VSNqPUylDH8y5beDzyAcrJjfYGWfVhEDS8qtd9)zpH4A54f1mnHOXKczq4I3dVowEOPH()n4Xf)l7juQl2sVdpuTreBf8GbQi7bNwTP3HhQ2WfiuiwWavK9GJ6n4bDOZY(JwTP3HhQ2yxslhx8VmSiyLcRbQi7bh1BWd6GwK9hMMq0ysHmiCX7Hxhlp00q)pvyrtw9E7ejNPjenMuidcx8E41XYdnn0)J5sGYHl(hvyrtw9yAcrJjfYGWfVhEDS8qtd9)ukhVEkXL76RVda]] )


end
