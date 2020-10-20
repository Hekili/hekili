-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local IsActiveSpell = ns.IsActiveSpell


-- Conduits
-- [x] depths_of_insanity
-- [-] hack_and_slash
-- [-] vicious_contempt


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
            duration = function () return ( azerite.moment_of_glory.enabled and 12 or 10 ) * ( 1 + conduit.inspiring_presence.mod * 0.01 ) end,
            max_stack = 1,
        },
        recklessness = {
            id = 1719,
            duration = function () return ( level > 51 and 12 or 10 ) * ( 1 + conduit.depths_of_insanity.mod * 0.01 ) end,
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
                    if buff.cadence_of_fujieda.stack < 5 then stat.haste = stat.haste + 0.01 end
                    addStack( "cadence_of_fujieda", nil, 1 )
                end
            end,

            auras = {
                cadence_of_fujieda = {
                    id = 335558,
                    duration = 8,
                    max_stack = 5,
                },
            }
        },


        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or nil end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "off",

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
            cooldown = function () return 120 - conduit.stalwart_guardian.mod * 0.001 end,
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
                if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
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
            cooldown = function () return 30 + conduit.disturb_the_peace.mod * 0.001 end,
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

                if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 8 end
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
                if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
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


    spec:RegisterPack( "Fury", 20201013, [[dO01MaqiIIhHQOnHKmkrQoLIkVcPYSOK6wIeTlk(fs0WOu6yOkTmIsptKKPjsW1Ou02ePuFdPkmofvLZHQqRtKsAEkQY9qk7JsHdIuLwis4HkQQAIIuOlksiTrfvvgPiPWjfjvTskXmfPGBksi2jsQFkskAOIKslvKu5PsAQkIRksOSvrcvFvKsSxL(RedMKdlSyfEmHjtLldTzs9zImAIQtdA1Ok41OQMnvDBuz3s9BedxehhPkA5Q8CGPRQRlQTRO8DfPXlsrNNsY6rQQ5tPA)O8Y7ozRU4XLAzTvwB51wEtLXwE0M2mv0JT(wLGBnje8djCRDWHBD(LpR2AsyLNeUDYwbK8jWTk))eqALskLGV88WiiCucGCzF8qslUq)ucGCck36id9FQV3XwDXJl1YARS2YRT8MkJT8OnTPS84wJ8lNCBTc5M)mfLmf9Ec5qUhEeWwLdDoS3XwDiqSvEYuZV8zftLwI7GKJzHNmvQP4jd8ykEtL1mLS2kRTmlml8KPM)YJwcbPvMfEYuPKPOxNdDmvQnZXHEdZcpzQuYuPriigE0XuCKzih2ptrjtLAGhbkyQ0agjmLi8EMk9M8mvJOdDmLMCmfStPuWHmLG0pMM)CgMfEYuPKPsriZqhtrHpCi4jhhtfTJPsJxirAMk1rIJPIbzgYuu4je3lhEGNPEctb5soYmKP0hspZylSIPiAM6qbHJdBx8qsdyQ0bqoatDKSKCVvmfspZHFodZcpzQuYu0RZHoMII4FpYuv5K8ZupHPsouq4gXZu0BQnnyyw4jtLsMIEDo0XuP4qXtoRyQuxgiNPIbzgYuayl5Xu(XjHptLwKdp)uy7mml8KPsjtrVoh6yQumaYuP(h5aMT6HGhSt2ka2sES8XjH)ozPM3DYwdXdj9wbquchhg8XBRyhdp6wk2FPw2DYwXogE0TuSvXbF8GXwtNPgzT2COGVhbGgbatoHPSBNPgzT2WHCKZQcrx8zb0vChgCatoHPMJPSBNPsNPgzT2G9fsO5qUa2aMAEmLKWXu2TZuxiHmLnykE0wMAUTgIhs6TEbxsiH7VuNQDYwdXdj9wX0ef5h3k2XWJULI9xQtHDYwdXdj9wfK2HC9wXogE0TuS)sTn3jBf7y4r3sXwfh8XdgBn5WzfjHZWR5cUKqc3AiEiP36Whoe8KJB)L60ENSvSJHhDlfBvCWhpyS1rwRnyFHeAYjBnepK0B1DHePlhjU9xQPh7KTIDm8OBPyRId(4bJToYATb7lKqJJmTzk72zQG(4bF0iiExb8i6lYjFz4jeN5IMptzdMI3TgIhs6To8eI7LdpWV)s98Tt2AiEiP3kPb(ilj)3k2XWJULI9xQ5XDYwXogE0TuSvXbF8GXwfYJtcbmfnMs2TgIhs6TEHeSLkdpz6(l18A7ozRH4HKERdpH4E5Wd8Bf7y4r3sX(l18Y7ozRH4HKERxibBPYWtMUvSJHhDlf7VuZRS7KTgIhs6TodkEYzv5Ya5Bf7y4r3sX(l18MQDYwdXdj9wHCjy7GTuzgu8KZQTIDm8OBPy)LAEtHDYwdXdj9wNkhE(PW2TvSJHhDlf7V)wDOoY(FNSuZ7ozRH4HKERc5XjHBf7y4r3sX(l1YUt2AiEiP3AsMJd9Bf7y4r3sX(l1PANSvSJHhDlfBvCWhpyS10zQlGUcod73WrMHCy)ghe8rlqMYgmLS2KPOIPUa6k4mSFdhzgYH9BGntzdMkfSjtn3wdXdj9wLJhbkkEms2FPof2jBf7y4r3sXwfh8XdgBDK1AJuoohm6crxc6Jh5LBYjmLD7mv6mLmmfcaylqJG0oSbOR4HAutobA4cEGCmfvm1hNe(MhYHLNuCqKPMhnMkTTLPMBRH4HKERjKhs69xQT5ozRyhdp6wk2Q4GpEWyRccX7itBZHc(EeaAeamhYfWgWuZJPsftrft9Hh73COGVhbGsmI2rAd2XWJUTgIhs6TEbxsiH7VuN27KTIDm8OBPyRId(4bJTMotnYAT5qbFpcancaMCctz3otjieVJmTnhk47raOraWCixaBatnpMIxMAoMIkMkDM6cjKPSbtnF2YuuXuPZuJSwB4W4lcpgZWZKtykQyQrwRnyFHeAYjmLD7mfib9(YhNe(aZu5WZpf2oMIgtXltnhtz3ot5iVPjPjKKbLzyt4mhYfWgWuZT1q8qsV1HNqCfIU8YXc2iNv7Vutp2jBf7y4r3sXwfh8XdgBvgMAK1AZHc(EeaAeam5eMIkMsgMAK1AdaIs44WGpEMCYwdXdj9wtYhuBfSLkdFa(9xQNVDYwXogE0TuSvXbF8GXwLHPgzT2COGVhbGgbatoHPOIPKHPgzT2aGOeoom4JNjNS1q8qsV1dMK4XcSlGKqG7VuZJ7KTIDm8OBPyRId(4bJTkdtnYAT5qbFpcancaMCctrftjdtnYATbarjCCyWhptozRH4HKERtjN3ndHD5qaPJwG7VuZRT7KTIDm8OBPyRId(4bJTkdtnYAT5qbFpcancaMCctrftjdtnYATbarjCCyWhptozRH4HKERAIidqxjOpEWhldm42FPMxE3jBf7y4r3sXwfh8XdgBvgMAK1AZHc(EeaAeam5eMIkMsgMAK1AdaIs44WGpEMCYwdXdj9wpmsGTur7doeS)snVYUt2k2XWJULITko4Jhm2Qmm1iR1Mdf89ia0iayYjmfvmLmm1iR1gaeLWXHbF8m5eMIkMYrEJG0cS)lE0v0(GdlJ81Md5cydykAmLTBnepK0BvqAb2)fp6kAFWH7VuZBQ2jBf7y4r3sXwfh8XdgBDK1AZHc(EeakAYjqtozRH4HKERVCSK7bj3UIMCcC)LAEtHDYwXogE0TuSvXbF8GXwLHPgzT2COGVhbGgbatoHPOIPsNPEihwEsXbrMYgmfV8Onzk72zQpoj8nYXW)YnjINPMhtjRTm1CBnepK0BvkhNdgDHOlb9XJ8Y3FPMxBUt2k2XWJULITko4Jhm2Qmm1iR1Mdf89ia0iayYjBnepK0BLd5iNvfIU4ZcOR4om4a7VuZBAVt2k2XWJULITko4Jhm26iR1Mdf89ia0iayCKPntrft5WrwRnaikHJdd(4zCKP9wdXdj9wfKMEMXJCGYi6gV9xQ5LESt2k2XWJULITko4Jhm2QKWzoKlGnGPOXu2YuuXuPZuYWuiaGTancs7WgGUIhQrn5eOHl4bYXuuXuYWuiaGTandpH4keD5LJfSroRmCbpqoMYUDMsqiEhzABKYX5Grxi6sqF8iVCZHCbSbmLnykEzk72zQrwRns54CWOleDjOpEKxUjNWu2TZuJSwBgEcXvi6YlhlyJCwzYjm1CBnepK0B9qbFpcanca7VuZ78Tt2k2XWJULITko4Jhm2kib9(YhNe(aZu5WZpf2oMYgmfVmfvmLmm1iR1gom(IWJXm8m5KTgIhs6Tovo88tHTB)LAE5XDYwXogE0TuS1q8qsV1aiFw0iOCb9jxrqUWVvXbF8GXwFihwEsXbrMAEmLS2Yu2TZuYWuoCK1AZf0NCfb5cFXHJSwBYjmLD7mv6m1hNe(MhYHLNuseFjv2YuZJPSjtrft5WrwRncs7YIhodlWMFXHJSwBYjm1CmLD7mv6mLmmLdhzT2iiTllE4mSaB(fhoYATjNWuuXuJSwB4qoYzvHOl(Sa6kUddoGjNWu2TZujhoRijCgzns54CWOleDjOpEKxotz3otLC4SIKWzK1COGVhbGgbaMIkMkDMsgMcbaSfOHd5iNvfIU4ZcOR4om4agUGhihtrftjdtHaa2c0iiTdBa6kEOg1KtGgUGhihtnhtn3w7Gd3AaKplAeuUG(KRiix43FPwwB3jBf7y4r3sXw7Gd36fCjWwQeCjE4NDyrckfZi(VGTeSXTgIhs6TEbxcSLkbxIh(zhwKGsXmI)lylbBC)LAz5DNS1q8qsV1malWh5aBf7y4r3sX(l1Yk7ozRyhdp6wk2Q4GpEWyRJSwBouW3JaqJaGjNS1q8qsV1HNqCfD(SA)LAzt1ozRyhdp6wk2Q4GpEWyRJSwBouW3JaqJaGjNS1q8qsV1bEa84dBP9xQLnf2jBf7y4r3sXwfh8XdgBDK1AZHc(EeaAeamoY0MPOIPC4iR1gaeLWXHbF8moY0ERH4HKEREOK8hu4HStId7F)LAzT5ozRyhdp6wk2Q4GpEWyRJSwBouW3JaqJaGXrM2mfvmLdhzT2aGOeoom4JNXrM2BnepK0BfKGXvi6YiapK07VulBAVt2k2XWJULITko4Jhm26iR1Mdf89ia0iayCKPntrft5WrwRnaikHJdd(4zCKPntrftLotfIhodlyJCqeWu2GP4LPSBNPgeaGPMBRH4HKERrlGy)Lq)4bKte83FPww6XozRyhdp6wk2Q4GpEWyRJSwBouW3JaqJaGjNS1q8qsVvn8WHNqC7Vul78Tt2k2XWJULITko4Jhm26iR1Mdf89ia0iayYjBnepK0BnAbc(l8fr497VullpUt2k2XWJULITko4Jhm26iR1Mdf89ia0iayCKPntrft5WrwRnaikHJdd(4zCKPntrftnYATb7lKqtozRH4HKERJqQq0L)Gc(G9xQtLT7KTIDm8OBPyRH4HKERxUlH4HKU4HGFREi4lDWHBfaBjpw(4KWF)93khzgYH9VtwQ5DNS1q8qsVv54rGIIhJKTIDm8OBPy)93AYHcc3i(DYsnV7KTgIhs6ToI)9ybiNK)TIDm8OBPy)LAz3jBf7y4r3sXw7Gd3AqFG84cqrt6Vq0LeYu82AiEiP3AqFG84cqrt6Vq0LeYu82FPov7KTgIhs6ToLCE3me2LdbKoAbUvSJHhDlf7VuNc7KTgIhs6TYHCKZQcrx8zb0vChgCGTIDm8OBPy)LABUt2AiEiP3Quoohm6crxc6Jh5LVvSJHhDlf7VuN27KTgIhs6TEOGVhbGgbGTIDm8OBPy)93FRZWdaj9sTS2kRT2oFPY2TonUg2sGTM65si3JoMkfyQq8qsZuEi4bgMLTcsqXsn9q2TMCen0JBLNm18lFwXuPL4oi5yw4jtLAkEYapMI3uzntjRTYAlZcZcpzQ5V8OLqqALzHNmvkzk615qhtLAZCCO3WSWtMkLmvAecIHhDmfhzgYH9ZuuYuPg4rGcMknGrctjcVNPsVjpt1i6qhtPjhtb7ukfCitji9JP5pNHzHNmvkzQueYm0Xuu4dhcEYXXur7yQ04fsKMPsDK4yQyqMHmffEcX9YHh4zQNWuqUKJmdzk9H0Zm2cRykIMPouq44W2fpK0aMkDaKdWuhjlj3BftH0ZC4NZWSWtMkLmf96COJPOi(3Jmvvoj)m1tyQKdfeUr8mf9MAtdgMfEYuPKPOxNdDmvkou8KZkMk1LbYzQyqMHmfa2sEmLFCs4ZuPf5WZpf2odZcpzQuYu0RZHoMkfdGmvQ)roGHzHzHNmvkAAII8JoMAGAYHmLGWnINPgOeSbgMIEfcm5bmvt6ukpooD2ZuH4HKgWuK2BLHzjepK0atYHcc3iE6Or5i(3JfGCs(zwcXdjnWKCOGWnINoAuMbyb(iN1DWH0c6dKhxakAs)fIUKqMIhZsiEiPbMKdfeUr80rJYPKZ7MHWUCiG0rlqMLq8qsdmjhkiCJ4PJgLCih5SQq0fFwaDf3HbhGzjepK0atYHcc3iE6OrPuoohm6crxc6Jh5LZSeIhsAGj5qbHBepD0O8qbFpcancamlml8KPsrttuKF0Xu4m8SIPEihYuVCKPcXtoMccyQywa9XWJgMLq8qsdOjKhNeYSeIhsAaD0OmjZXHEMfEYutKdbmfeWuCeW7TIPEctLC4mSFMsqiEhzAdyk9r4yQbcBjMkecOd7p8ERyQmaDmLlFWwIP4iZqoSFdZcpzQq8qsdOJgLxUlH4HKU4HG36o4qACKzih2V1qnnoYmKd734GGpAbAdBYSeIhsAaD0OuoEeOO4XiXAOMw6xaDfCg2VHJmd5W(noi4JwG2qwBs1fqxbNH9B4iZqoSFdSTrkyZ5ywcXdjnGoAuMqEiPTgQPnYATrkhNdgDHOlb9XJ8Yn5e72txgeaWwGgbPDydqxXd1OMCc0Wf8a5O6JtcFZd5WYtkoiopAPTTZXSeIhsAaD0O8cUKqcTgQPjieVJmTnhk47raOraWCixaBW8sfvF4X(nhk47raOeJODK2GDm8OJzjepK0a6Or5WtiUcrxE5ybBKZkRHAAPpYAT5qbFpcancaMCID7ccX7itBZHc(EeaAeamhYfWgmpENJQ0VqcTX8zlvPpYATHdJVi8ymdptoHQrwRnyFHeAYj2TdsqVV8XjHpWmvo88tHTJgVZz3UJ8MMKMqsguMHnHZCixaBWCmlH4HKgqhnktYhuBfSLkdFaERHAAYmYAT5qbFpcancaMCcvYmYATbarjCCyWhptoHzjepK0a6Or5bts8yb2fqsiqRHAAYmYAT5qbFpcancaMCcvYmYATbarjCCyWhptoHzjepK0a6Or5uY5DZqyxoeq6OfO1qnnzgzT2COGVhbGgbatoHkzgzT2aGOeoom4JNjNWSeIhsAaD0Outeza6kb9Xd(yzGbN1qnnzgzT2COGVhbGgbatoHkzgzT2aGOeoom4JNjNWSeIhsAaD0O8Wib2sfTp4qG1qnnzgzT2COGVhbGgbatoHkzgzT2aGOeoom4JNjNWSeIhsAaD0OuqAb2)fp6kAFWHwd10KzK1AZHc(EeaAeam5eQKzK1AdaIs44WGpEMCcvoYBeKwG9FXJUI2hCyzKV2CixaBanBzwcXdjnGoAu(YXsUhKC7kAYjqRHAAJSwBouW3JaqrtobAYjmlH4HKgqhnkLYX5Grxi6sqF8iVCRHAAYmYAT5qbFpcancaMCcvP)qoS8KIdI2GxE0M2T)XjHVrog(xUjr8ZtwBNJzjepK0a6OrjhYroRkeDXNfqxXDyWbSgQPjZiR1Mdf89ia0iayYjmlH4HKgqhnkfKMEMXJCGYi6gpRHAAJSwBouW3JaqJaGXrM2u5WrwRnaikHJdd(4zCKPnZsiEiPb0rJYdf89ia0iaynutts4mhYfWgqZwQsxgeaWwGgbPDydqxXd1OMCc0Wf8a5OsgeaWwGMHNqCfIU8YXc2iNvgUGhiND7ccX7itBJuoohm6crxc6Jh5LBoKlGnWg8A3(iR1gPCCoy0fIUe0hpYl3KtSBFK1AZWtiUcrxE5ybBKZktozoMLq8qsdOJgLtLdp)uy7SgQPbsqVV8XjHpWmvo88tHTZg8sLmJSwB4W4lcpgZWZKtywcXdjnGoAuMbyb(iN1DWH0cG8zrJGYf0NCfb5cV1qnThYHLNuCqCEYARD7Y4WrwRnxqFYveKl8fhoYATjNy3E6FCs4BEihwEsjr8Luz78SjvoCK1AJG0US4HZWcS5xC4iR1MCYC2TNUmoCK1AJG0US4HZWcS5xC4iR1MCcvJSwB4qoYzvHOl(Sa6kUddoGjNy3EYHZkscNrwJuoohm6crxc6Jh5LB3EYHZkscNrwZHc(EeaAeaOkDzqaaBbA4qoYzvHOl(Sa6kUddoGHl4bYrLmiaGTancs7WgGUIhQrn5eOHl4bYn3CmlH4HKgqhnkZaSaFKZ6o4qAxWLaBPsWL4HF2HfjOumJ4)c2sWgzwcXdjnGoAuMbyb(ihGzjepK0a6Or5WtiUIoFwznutBK1AZHc(EeaAeam5eMLq8qsdOJgLd8a4Xh2swd10gzT2COGVhbGgbatoHzjepK0a6OrPhkj)bfEi7K4W(TgQPnYAT5qbFpcancaghzAtLdhzT2aGOeoom4JNXrM2mlH4HKgqhnkbjyCfIUmcWdjT1qnTrwRnhk47raOraW4itBQC4iR1gaeLWXHbF8moY0MzjepK0a6Orz0ci2Fj0pEa5ebFRHAAJSwBouW3JaqJaGXrM2u5WrwRnaikHJdd(4zCKPnvPhIhodlyJCqeydETBFqaG5ywcXdjnGoAuQHho8eIZAOM2iR1Mdf89ia0iayYjmlH4HKgqhnkJwGG)cFreEV1qnTrwRnhk47raOraWKtywcXdjnGoAuocPcrx(dk4dSgQPnYAT5qbFpcancaghzAtLdhzT2aGOeoom4JNXrM2unYATb7lKqtoHzjepK0a6Or5L7siEiPlEi4TUdoKga2sES8XjHpZcZsiEiPbgoYmKd7NMC8iqrXJrcZcZsiEiPbgaSL8y5JtcFAaikHJdd(4XSeIhsAGbaBjpw(4KWNoAuEbxsiHwd10sFK1AZHc(EeaAeam5e72hzT2WHCKZQcrx8zb0vChgCatozo72tFK1Ad2xiHMd5cydMNKWz3(fsOn4rBNJzjepK0ada2sES8XjHpD0OettuKFKzjepK0ada2sES8XjHpD0OuqAhY1mlH4HKgyaWwYJLpoj8PJgLdF4qWtooRHAAjhoRijCgEnxWLesiZsiEiPbgaSL8y5JtcF6OrP7cjsxosCwd10gzT2G9fsOjNWSeIhsAGbaBjpw(4KWNoAuo8eI7LdpWBnutBK1Ad2xiHghzAB3EqF8GpAeeVRaEe9f5KVm8eIZCrZ3g8YSeIhsAGbaBjpw(4KWNoAusAGpYsYFMLq8qsdmayl5XYhNe(0rJYlKGTuz4jtTgQPjKhNecOjlZsiEiPbgaSL8y5JtcF6Or5WtiUxo8apZsiEiPbgaSL8y5JtcF6Or5fsWwQm8KPmlH4HKgyaWwYJLpoj8PJgLZGINCwvUmqoZsiEiPbgaSL8y5JtcF6OrjKlbBhSLkZGINCwXSeIhsAGbaBjpw(4KWNoAuovo88tHTB)93f]] )


end
