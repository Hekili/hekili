-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 72 )

    local base_rage_gen, fury_rage_mult = 1.75, 1.00
    local offhand_mod = 0.50

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand_fury = {
            -- setting = "forecast_fury",

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
            -- setting = 'forecast_fury',

            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            interval = 'offhand_speed',

            stop = function () return state.time == 0 or state.swings.offhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed * offhand_mod / state.haste
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
        
        death_sentence = 25, -- 198500
        barbarian = 166, -- 280745
        battle_trance = 170, -- 213857
        blood_rage = 172, -- 329038
        enduring_rage = 177, -- 198877
        death_wish = 179, -- 199261
        master_and_commander = 3528, -- 235941
        disarm = 3533, -- 236077       
        slaughterhouse = 3735, -- 280747        
        demolition = 5373, -- 329033
        overwatch = 5375 -- 329035
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
        --dragon_roar = {  No Debuff anymore
        --    id = 118000,
        --    duration = 6,
        --    max_stack = 1,
        --},
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
        --frothing_berserker = { Its a Passive now for refund Rage
        --    id = 215572,
        --    duration = 6,
        --    max_stack = 1,
        --},
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
        moment_of_glory = { --Additional Buff from Rallying_Cryw
            id = 280210,
            duration = 12,
            max_stack = 1,
        },
        piercing_howl = {
            id = 12323,
            duration = 8,
            max_stack = 1,
        },
        rallying_cry = {
            id = 97463,
            duration = 12,
            max_stack = 1,
        },
        recklessness = {
            id = 1719,
            duration = 10,
            max_stack = 1,
        },
        siegebreaker = {
            id = 280773,
            duration = 10,
            max_stack = 1,
        },
        --sign_of_the_skirmisher = { Just for Arena Right?
        --    id = 186401,
        --   duration = 3600,
        --    max_stack = 1,
        --},
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
        victorious = {  --Need Check
            id = 32216,
            duration = 20,
        },
        whirlwind = {
            id = 85739,
            duration = 20,
            max_stack = 2
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


    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell

    local whirlwind_consumers = {
        bloodthirst = 1,
        execute = 1,
    --   furious_slash = 1,
        impending_victory = 1,
        raging_blow = 1,
        rampage = 1,
        siegebreaker = 1,
    --    storm_bolt = 1,
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
                whirlwind_stacks = 2
            
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
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 236303,

            range = 8,

            handler = function ()
                applyBuff( "bladestorm" )
                gain( 25, "rage" )
                setCooldown( "global_cooldown", 4 * haste )

                --if level < 116 and equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end

                --if azerite.gathering_storm.enabled then
                --    applyBuff( "gathering_storm", 6 + ( 4 * haste ), 5 )
                --end
            end,
        },


        bloodthirst = {
            id = 23881,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = -8,
            spendType = "rage",

            startsCombat = true,
            texture = 136012,

            handler = function ()
                gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ), "health" )
                if level < 116 and equipped.kazzalax_fujiedas_fury then addStack( "fujiedas_fury", 10, 1 ) end
                removeBuff( "bloody_rage" )
                removeStack( "whirlwind" )
                if azerite.cold_steel_hot_blood.enabled and stat.crit >= 100 then
                    applyDebuff( "target", "gushing_wound" )
                    gain( 4, "rage" )
                end
            end,
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
            charges = function () return ( level < 116 and equipped.timeless_stratagem ) and 3 or nil end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
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


        piercing_howl = {
            id = 12323,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -0,
            spendType = "rage",

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
            cooldown = function () return haste * 8 end,
            recharge = function () return haste * 8 end,
            gcd = "spell",

            spend = -12,
            spendType = "rage",

            startsCombat = true,
            texture = 589119,

            handler = function ()
                if level < 116 and set_bonus.tier_21_4pc == 1 then addStack( "bloody_rage", 10, 1 ) end
                removeStack( "whirlwind" )
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
                applyBuff( "moment_of_gloryw" )
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
                applyBuff ( "frenzy" ) --Can Stack 3 Times if target not swoped
                applyBuff( "enrage" )
                if level < 116 and set_bonus.tier21_2pc == 1 then applyDebuff( "target", "slaughter" ) end
                removeStack( "whirlwind" )  
            end,
        },


        recklessness = {
            id = 1719,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 458972,

            handler = function ()
                applyBuff( "recklessness" )
                --if talent.reckless_abandon.enabled then gain( 100, "rage" ) end generates 20 more Rage 
            end,
        },

        shattering_throw = {
            id = 64382,
            cast = 1.5,
            cooldown = 180,
            gcd = "spell",

            startsCombat = true,
            texture = 311430,
            range = 30,

        --    handler = function () end, Removing any magical immunities
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

            toggle = "defensives",

            startsCombat = false,
            texture = 132361,

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

            range = 7,
            
            usable = function ()
                if settings.check_ww_range and target.outside7 then return false, "target is outside of whirlwind range" end
                return true
            end,

            handler = function ()
                applyBuff( "whirlwind", 20, 2 )
                if talent.meat_cleaver.enabled then gain( 2 + "whirlwind") end -- then gain 2 addtitional stacks
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


    spec:RegisterPack( "Fury", 20200210, [[dKe0EaqifupsIQnrImkqOtbcELcmlur3IqQDrXViHHriogjPLjr5zOc10irLRHkW2qfuFJefgNccNJqI1HkKMhHk3tH2hjrhubPfcsEiQGyIKOOlIkiTruHyKesQojjkzLivZKqv1njKu2jsXqjuvwkjk1tb1ubrxLqsSvcjPVsOk2lI)IKbtPdt1IL0JjAYcUm0Mf6ZemAuPtRYQjrvVMKA2K62OQDl1VbgUeooHQ0Yv65QA6IUUI2oi13rknEfeDEcL1tsy(sK9JYevjqsGdEIeAktKYerKHGJfXiIQCSiIOCe4uScKax4s1UasGBNhjWCK5kgbUWftd8absc8dMRejWCZS45OkuiCj3z1ib8k(JFQ98aTC9yQ4pEPccCDE6uz1Kkbo4jsOPmrkterktvriW(m5cwcm8XZHWSky2HUsUhFEl4jWCVqaBsLahWxsGlNz5iZvmMv847EGLrVCMLBMfphvHcHl5oRgjGxXF8tTNhOLRhtf)Xlz0lNz5iyDN(kgZQQiCYSLjszIWOZOxoZYHW1Bb85Om6LZSIMzhAiGbMv8n55rTHrVCMv0mRY8EVQXaZYdGg5XozwfmROoUGtYSIF0lywPR1mleBqYSnIbmWSrWYSxlAbNhzwjOtCitiyy0lNzfnZkQbGgdmluApGFcwEM17aZQmxxa0mRYg4lZ6va0iZcLgacj3B)KztaZE8flaAKzJlkENylfJzbrMDrjGNh7GNhOFMfI)X)m7cMcC1IXSO4D6Aiyy0lNzfnZo0qadmluEMAKzH5cMjZMaMTyrjGV6jZouXN43WOxoZkAMDOHagywr1tMGvmMvzpFUmRxbqJm7FTGgfD6RaMmR4H7TAAVoyy0lNzfnZo0qadmROYJmRYkr(3qG13Npbsc8FTGgPsFfWKajHgvjqsGDzEGMa)hkG1fD14sGX2RAmqGIKeAkJajbgBVQXabkcSCVe3ZjWqKzRZy0SOuTg)VX)nZcMTujMToJrdpYdwXOark9uEbQWIo)BMfmley2sLywiYSPRXonXfKCVwGQI7JRACny7vngy2sLy201yNgPVTlGgS9QgdmRsmlez26mgnyVUaAwK3V(zwXXScYaZwQeZUUaYSQKzffrywiWSLkXSPRXon8()UCrd2EvJbMvjMfImBDgJgSxxanlY7x)mR4ywbzGzlvIzxxazwvYSIIimleywiqGDzEGMaVoFHlGKKqdhtGKa7Y8anbghsuotKaJTx1yGafjj0OCeijWy7vngiqrGL7L4EobUyrOPeKbJQM15lCbKa7Y8anbUQ9a(jy5jjHgoGajbgBVQXabkcSCVe3ZjW1zmAWEDb0mliWUmpqtGdRlaAQf4ljj0WHjqsGX2RAmqGIal3lX9CcCDgJgSxxanbaTnZwQeZ6Qa3lrJeOduFIOMIliPQAaiywVvZSQKzvLa7Y8anbUQbGqY92pjjHgLbbscm2EvJbcuey5EjUNtGLC9vaFMDKzlJa7Y8anbEDHRfOQAaTKKqZqqGKa7Y8anbUQbGqY92pjWy7vngiqrscnIcbscm2EvJbcuey5EjUNtGtxJDAK(2UaAW2RAmWSLkXSqKztxJDA49)D5IgS9QgdmRsm76ciZkoMDieHzHaZwQeZcrMnDn2PjUGK71cuvCFCvJRbBVQXaZQeZUUaYSIJzffrywiqGDzEGMaVUW1cuvnGwssOrvriqsGDzEGMad9jtWkg1oFUeyS9QgdeOijHgvvLajb2L5bAc8XxGD4AbkOpzcwXiWy7vngiqrscnQwgbscSlZd0eyA5ERM2RdeyS9QgdeOijjjW8aOrEStcKeAuLajb2L5bAcmxCbNKsJEbbgBVQXabkssscCaJ(uNeij0OkbscSlZd0eyjxFfqcm2EvJbcuKKqtzeijWUmpqtGlM88OMaJTx1yGafjj0WXeijWy7vngiqrGL7L4EobgIm76xGcHg70WdGg5XonH7tVLiZQsMTmoGzvIzx)cui0yNgEa0ip2P5AMvLmRYXbmleiWUmpqtG5Il4KuA0lijHgLJajbgBVQXabkcSCVe3ZjWPVcyAYJhPsav4qMvCJmlhwecSlZd0e4cqEGMKeA4acKeyS9QgdeOiWY9sCpNa)fOwtL(kG5BOL7TAAVoWSQKzvLzvIzhUoJrdTCVvt71bZSGa7Y8anbMwU3QP96ajj0WHjqsGX2RAmqGIal3lX9CcSea0baTTzrPAn(FJ)BwK3V(zwXXSCmb2L5bAc868fUasscnkdcKeyS9QgdeOiWY9sCpNatGDzEGMaVOuTg)VX)jjHMHGajb2L5bAc88rQlr(NaJTx1yGafjj0ikeijWy7vngiqrGL7L4EobUoJrZIs1A8)g)3mliWUmpqtGRAaiqfNRyKKqJQIqGKaJTx1yGafbwUxI75e46mgnlkvRX)B8FZSGa7Y8anbUI7JR6RfijHgvvLajbgBVQXabkcSCVe3ZjW1zmAwuQwJ)34)MaG2MzvIzdyDgJM)qbSUORgxtaqBtGDzEGMaRpbU5tP8ZGap2jjj0OAzeijWy7vngiqrGL7L4EobUoJrZIs1A8)g)3mliWUmpqtGJ3IvnaeijHgv5ycKeyS9QgdeOiWY9sCpNaxNXOzrPAn(FJ)BMfeyxMhOjWElXpxxtjDTMKeAuv5iqsGX2RAmqGIal3lX9CcCDgJMfLQ14)n(VjaOTzwLy2awNXO5puaRl6QX1ea02mRsmBDgJgSxxanZccSlZd0e4QlqbIu5Es1pjj0OkhqGKaJTx1yGafb2L5bAc8oBkxMhOP03Ney99jv78ib(VwqJuPVcyssssGlwuc4REsGKqJQeijWy7vngiqrscnLrGKaJTx1yGafjj0WXeijWy7vngiqrscnkhbscSlZd0e4QNPgPEUGzsGX2RAmqGIKeA4acKeyS9QgdeOiWTZJeyxfpxF9Nkc6KcePka0Ilb2L5bAcSRINRV(tfbDsbIufaAXLKeA4WeijWUmpqtGPfS6a041ul(G2BjsGX2RAmqGIKeAugeijWUmpqtG5rEWkgfisPNYlqfw05Fcm2EvJbcuKKqZqqGKa7Y8anbwy6B48McePCvGli5sGX2RAmqGIKeAefcKeyxMhOjWlkvRX)B8Fcm2EvJbcuKKqJQIqGKa7Y8anbUaKhOjWy7vngiqrsssscm04(hOj0uMiLjIiLPQieyA9TVw4jWkl(cWMyGzvoM1L5bAMvFF(ggDcCXcINgjWLZSCK5kgZkE8DpWYOxoZYnZINJQqHWLCNvJeWR4p(P2Zd0Y1JPI)4Lm6LZSCeSUtFfJzvveoz2YePmry0z0lNz5q46Ta(Cug9YzwrZSdneWaZk(M88O2WOxoZkAMvzEVx1yGz5bqJ8yNmRcMvuhxWjzwXp6fmR01AMfIniz2gXagy2iyz2RfTGZJmRe0joKjemm6LZSIMzf1aqJbMfkThWpblpZ6DGzvMRlaAMvzd8Lz9kaAKzHsdaHK7TFYSjGzp(IfanYSXffVtSLIXSGiZUOeWZJDWZd0pZcX)4FMDbtbUAXywu8oDnemm6LZSIMzhAiGbMfkptnYSWCbZKztaZwSOeWx9KzhQ4t8By0lNzfnZo0qadmRO6jtWkgZQSNpxM1RaOrM9VwqJIo9vatMv8W9wnTxhmm6LZSIMzhAiGbMvu5rMvzLi)By0z0lNz5qhsuotmWSvmcwKzLa(QNmBffU(nm7qLsSiFMTbTO56lFCQzwxMhOFMf0AXmm6Umpq)MIfLa(QNJrT)Qz0DzEG(nflkb8vphmQicabgDxMhOFtXIsaF1ZbJk8Pap2PNhOz0lNzHBV45csMD9lWS1zmIbM9tpFMTIrWImReWx9KzROW1pZ6DGzlwu0fGmVwGzVNzdGgnm6Umpq)MIfLa(QNdgvu9m1i1ZfmtgDxMhOFtXIsaF1ZbJkMpsDjYZz784ORINRV(tfbDsbIufaAXLr3L5b63uSOeWx9CWOcAbRoanEn1IpO9wIm6Umpq)MIfLa(QNdgvWJ8GvmkqKspLxGkSOZ)m6Umpq)MIfLa(QNdgvim9nCEtbIuUkWfKCz0DzEG(nflkb8vphmQyrPAn(FJ)ZO7Y8a9Bkwuc4REoyurbipqZOZOxoZYHoKOCMyGzrOXvmMnpEKztUiZ6YeSm79mRdTFAVQrdJUlZd0)OKRVciJUlZd0)GrfftEEuZOxoZcj37z27zwEWNAXy2eWSflcn2jZkbaDaqB)mBCb8mBfVwGzDP8cyNUwlgZoFmWSH5ETaZYdGg5Xonm6LZSUmpq)dgvSZMYL5bAk99jNTZJJ8aOrEStoV4ipaAKh70eUp9wIQKdy0DzEG(hmQGlUGtsPrVGZlocX1Vafcn2PHhanYJDAc3NElrvwghO06xGcHg70WdGg5XonxRsLJdGaJUlZd0)GrffG8anNxCSoJrJW03W5nfis5QaxqY1mlkvcIdJ)JTensqhW(XaL(IyeSs0W7kpyvk9vattE8ivcOchkUroSiqGr3L5b6FWOI15lCbKZlokbaDaqBBwuQwJ)34)Mf59RFXXXm6Umpq)dgvu1aqGcePsUif2iVyCEXX6mgnlkvRX)B8FZSGr3L5b6FWOII5ErXUwGQQ9p58IJdxNXOzrPAn(FJ)BMfknCDgJM)qbSUORgxZSGr3L5b6FWOI9kk0i11uFHlroV44W1zmAwuQwJ)34)MzHsdxNXO5puaRl6QX1mly0DzEG(hmQGwWQdqJxtT4dAVLiNxCC46mgnlkvRX)B8FZSqPHRZy08hkG1fD14AMfm6Umpq)dgvebY5Jbkxf4EjsvrNNZlooCDgJMfLQ14)n(VzwO0W1zmA(dfW6IUACnZcgDxMhO)bJkw0lUwGkQDE858IJdxNXOzrPAn(FJ)BMfknCDgJM)qbSUORgxZSGr3L5b6FWOcjOLyNRNyGkQDEKZlooCDgJMfLQ14)n(VzwO0W1zmA(dfW6IUACnZcLcG0ibTe7C9edurTZJu152Mf59R)rry0DzEG(hmQi5IuZUcMDGkcwjY5fhRZy0SOuTg)NkcwjAMfm6Umpq)dgvim9nCEtbIuUkWfKC58IJdxNXOzrPAn(FJ)BMfkbX84rQeqfouLQkkCqPsPVcyA4IUo5AkKP4kteiWO7Y8a9pyubpYdwXOark9uEbQWIo)Z5fhhUoJrZIs1A8)g)3mly0DzEG(hmQyrPAn(FJ)Z5fhhg)hBjAKGoG9Jbk9fXiyLOH3vEWQ0W4)ylrtvdabkqKk5IuyJ8Iz4DLhSLkjbaDaqBBeM(goVParkxf4csUMf59RFvQAPs1zmAeM(goVParkxf4csUMzrPssaqha02MQgacuGivYfPWg5fZSiVF9lobzGr3L5b6FWOcA5ERM2RdCEXXVa1AQ0xbmFdTCVvt71bvQQsdxNXOHh9KsQrhACnZcgDxMhO)bJkMpsDjYZz784O)CH2B8PwxfGLscwxZ5fhZJhPsav4qXvMiLknCaRZy0SUkalLeSUMkG1zmAMfLkbX0xbmn5XJujGQqMuCSiIJdukG1zmAKGomL5bnsDTAQawNXOzwaHsLG4WbSoJrJe0HPmpOrQRvtfW6mgnZcLQZy0WJ8GvmkqKspLxGkSOZ)MzrPsflcnLGmykZim9nCEtbIuUkWfKClvQyrOPeKbtzMfLQ14)n(VsqCy8FSLOHh5bRyuGiLEkVavyrN)n8UYdwLgg)hBjAKGoG9Jbk9fXiyLOH3vEWcbiWO7Y8a9pyuX8rQlrEoBNhhxNV4AbkNVqF5mGucNGdnqNuylCnYO7Y8a9pyuX8rQlr(Nr3L5b6FWOIQgacuX5kgNxCSoJrZIs1A8)g)3mly0DzEG(hmQOI7JR6Rf48IJ1zmAwuQwJ)34)MzbJUlZd0)Grf6tGB(uk)miWJDY5fhRZy0SOuTg)VX)nbaTTsbSoJrZFOawx0vJRjaOTz0DzEG(hmQiElw1aqGZlowNXOzrPAn(FJ)BMfm6Umpq)dgv4Te)CDnL01AoV4yDgJMfLQ14)n(VzwWO7Y8a9pyur1fOarQCpP6NZlowNXOzrPAn(FJ)BcaABLcyDgJM)qbSUORgxtaqBRuDgJgSxxanZcgDxMhO)bJk2zt5Y8anL((KZ25XX)AbnsL(kGjJoJUlZd0VHhanYJDoYfxWjP0OxWOZO7Y8a9B(Rf0iv6RaMJ)HcyDrxnUm6Umpq)M)AbnsL(kG5GrfRZx4ciNxCeI1zmAwuQwJ)34)MzrPs1zmA4rEWkgfisPNYlqfw05FZSacLkbX01yNM4csUxlqvX9XvnUgS9QgdLkLUg70i9TDb0GTx1yqjiwNXOb71fqZI8(1V4eKHsLwxavPOicekvkDn2PH3)3LlAW2RAmOeeRZy0G96cOzrE)6xCcYqPsRlGQuuebcqGr3L5b638xlOrQ0xbmhmQahsuotKr3L5b638xlOrQ0xbmhmQio3dmFQx7pxoV44W1zmAQAaiONFAMfkvNXOjo3dmFQx7pxZI8(1V44ygDxMhOFZFTGgPsFfWCWOIQ2d4NGLNZlowSi0ucYGrvZ68fUaYO7Y8a9B(Rf0iv6RaMdgvewxa0ulWxoV4yDgJgSxxanZcgDxMhOFZFTGgPsFfWCWOIQgacj3B)KZlowNXOb71fqtaqBxQKRcCVensGoq9jIAkUGKQQbGGz9wTkvLr3L5b638xlOrQ0xbmhmQyDHRfOQAaTCEXrjxFfWFSmgDxMhOFZFTGgPsFfWCWOIQgacj3B)Kr3L5b638xlOrQ0xbmhmQyDHRfOQAaTCEXX01yNgPVTlGgS9QgdLkbX01yNgE)FxUObBVQXGsRlGIBiebcLkbX01yNM4csUxlqvX9XvnUgS9QgdkTUakorreiWO7Y8a9B(Rf0iv6RaMdgveN7bMp1R9NlNxCmDn2Pjo3dmFQx7pxd2EvJbgDxMhOFZFTGgPsFfWCWOcOpzcwXO25ZLr3L5b638xlOrQ0xbmhmQ44lWoCTaf0NmbRym6Umpq)M)AbnsL(kG5Grf0Y9wnTxhiWFbkj0OmkJKKKqa]] )
end
