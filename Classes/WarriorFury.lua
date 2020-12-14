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
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed / state.haste
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
            max_stack = 4,      
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
        spell_reflection = {
            id = 23920,
            duration = function () return legendary.misshapen_mirror.enabled and 8 or 5 end,
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

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "RAGE" then
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


    local WillOfTheBerserker = setfenv( function()
        applyBuff( "will_of_the_berserker" )
    end, state )


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
            state:QueueAuraExpiration( "recklessness", WillOfTheBerserker, buff.recklessness.expires )
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
            id = function () return talent.reckless_abandon.enabled and buff.recklessness.up and 335096 or 23881 end,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = function () return ( talent.seethe.enabled and ( stat.crit >= 100 and -4 or -2 ) or 0 ) - 8 end,
            spendType = "rage",

            startsCombat = true,
            texture = function () return talent.reckless_abandon.enabled and buff.recklessness.up and 236304 or 136012 end,

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
            },

            copy = { "bloodbath", 335096, 23881 }
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
            charges = function () return legendary.leaper.enabled and 3 or nil end,
            recharge = function () return legendary.leaper.enabled and ( talent.bounding_stride.enabled and 30 or 45 ) or nil end,
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
            id = function () return talent.reckless_abandon.enabled and buff.recklessness.up and 335097 or 85288 end,
            cast = 0,
            charges = 2,
            cooldown = 8,
            recharge = 8,
            hasteCD = true,
            gcd = "spell",

            spend = -12,
            spendType = "rage",

            startsCombat = true,
            texture = function () return talent.reckless_abandon.enabled and buff.recklessness.up and 132215 or 589119 end,

            handler = function ()
                removeStack( "whirlwind" )

                if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 8 end
            end,

            copy = { "crushing_blow", 335097, 85288 }
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
                if talent.reckless_abandon.enabled then
                    gain( 50, "rage" )
                end
                if legendary.will_of_the_berserker.enabled then
                    state:QueueAuraExpiration( "recklessness", WillOfTheBerserker, buff.recklessness.expires )
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


        spell_reflection = {
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
                applyBuff( "spell_reflection" )
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
                if level > 36 then
                    applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
                end
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

        potion = "potion_of_phantom_fire",

        package = "Fury",
    } )


    spec:RegisterSetting( "check_ww_range", false, {
        name = "Check |T132369:0|t Whirlwind Range",
        desc = "If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } ) 


    spec:RegisterPack( "Fury", 20201214, [[dKKoGaqikPYJOQ0MuQ8jkPOrrP4uuk9kuLMLsu3cuXUO4xkvnmkrhJQQLrvXZOemnkHUgLKTPueFJsQACkrKZHQGwNse18av6Eev7dj6Gkf1cbv9qufWervOlsjLSrLi0irvu5KusHvsuMjLuQBIQaTtKWqvIGLQejpvvMQsPRIQO0wrvu1xvIu7fXFrLbdCyrlwv9yQmzsDzOnJuFgKrRKoTIvJQO41kHztYTPk7wQFty4GYXrvKLRYZrz6cxNiBNs13rsJxPiDELcZhv1(LmXpzl5PZaju4JL(yPFF8BrJLw6JfT0cKxSbmK8GLUfjesED6HK3su62G8GLBOePMSL8ycPZHK3AeWyl597HMyv6BCcV9SXtsLXiA3L0XE2452tEFPrfwJM8jpDgiHcFS0hl97JFlAS0sFSGf9tEPuSkoY7nE8afyFb285whVyobJ8whTgBYN80iZrE(wGLO0Trbw68UrCLmFlapIo07Jxb8BXLlGpw6JLLSsMVfGhynBiKTKlz(wa4uGnR1OUalbjppuzkz(wa4uaECy5xH6c4jSJEyhfyFb45WtmUcyTXewbCPsvaBAruGgrnQlaT4kW0Wbk9Wc4eDGBAyRPK5BbGtb4bf2rDbGxLAKfIZRazRlapEjKOlWsjYRa5xyhla8kHqhRZXIceIcmEWoHDSa0hYtsy72Oac6cCOt45HToJr0ScydB8yf4esqRQnkaYtsPYwtjZ3caNcSzTg1fa(mcfwG3QqkkqikaSdDcVFgfyZlbRTPK5BbGtb2SwJ6cWZpUqCBuGLsITwG8lSJfGnnKcHtKhegfyPxNtrDATPK5BbGtb2SwJ6cWZYWcync0Jzkz(wa4uGTuXCrbOfxbw615uuNwxGpsloSak0oQkGfSEtjZ3caNcSuONWoQlG1IXW2HmtjZ3caNcWJI2AgfqIHf4nie(pmxGxbg6cmH1KvGuDyQ3OasWkGn8iMXQxUapBnKNAybJSL8ytdPqUipimiBju4NSL8Wo)kutGN8C3e4nj5Dsnsloi0qDukobnxSICF8y4TapdYtsdmyOUa7kWxIM2qDukobnxSICF8y4TapZHE50Sca3ca50Kx6Ir0K3LqtdX9vcQKGqHpKTKh25xHAc8KN7MaVjjVtQrAXbHgQJsXjO5IvK7JhdVf4zqEsAGbd1fyxb(s00gQJsXjO5IvK7JhdVf4zo0lNMva4waiNM8sxmIM8UeAAiUVsqLeekSazl5HD(vOMap55UjWBsYtJFjAAdBqi8FyUapJwqTlWUcytbyWqLIlYdcdMH66CkQtRlaLfWFb4ZVaxoAo0o2Hj1AMz6cqzb8BvbSL8sxmIM8ydcH)dZf4rccfwKSL8Wo)kutGN8C3e4nj5ztb(s00MdDluiJ1iJzKGva(8lWxIM24HEIBdobnNsYnAo9HPhZibRa2wa(8lGnf4lrtBW(si0COxonRaWTaqoDb4ZVaxcHfGYcWdTSa2sEPlgrtEx6blHqsqOWkYwYlDXiAYZjAn61Kh25xHAc8KGqXMq2sEyNFfQjWtEUBc8MK8(s00gSVecnsWkWUcytbyWqLIlYdcdMH66CkQtRlaLfWFb4ZVaxoAo0o2Hj1AMz6cqzbSERkGTKx6Ir0Kx2Ub7GlPd8yRc3csqOW6jBjpSZVc1e4jp3nbEtsEFjAAd2xcHgjyfyxbSPamyOsXf5bHbZqDDof1P1fGYc4Va85xGlhnhAh7WKAnZmDbOSaw0Qcyl5LUyen5XGH5XjO5(jlgrtccfljYwYlDXiAYd3u0jfi5HD(vOMapjiuWdjBjpSZVc1e4jp3nbEtsEFjAAd2xcHgjyfyxbSPamyOsXf5bHbZqDDof1P1fGYc4Va85xGlhnhAh7WKAnZmDbOSaw0Qcyl5LUyen59vPgzH48ibHc)ws2sEyNFfQjWtEUBc8MK8(s00gSVecnsWkWUcytbyWqLIlYdcdMH66CkQtRlaLfWFb4ZVaxoAo0o2Hj1AMz6cqzb8BvbSL8sxmIM80xcjAUtKhjiu43pzl5HD(vOMap55UjWBsY7lrtBW(si0Ofu7cWNFbCIwlnHX(4gHeJZj6a9GfMl7ffGYcyvb2vGipimmRyQIvdmxua4walyvb2vaRRarQWomUtcvXggSZVc1Kx6Ir0K3xje6yDowqccf(9HSL8Wo)kutGN8C3e4nj59LOPnyFjeA0cQDb4ZVaorRLMWyFCJqIX5eDGEWcZL9IcqzbSQa7kqKhegMvmvXQbMlkaClGfSQa7kG1vGivyhg3jHQydd25xHAYlDXiAY7RecDSohlibHc)wGSL8sxmIM8entLsqRb5HD(vOMapjiu43IKTKh25xHAc8KN7MaVjjp3AEqiRaYlGpKx6Ir0K3LqtdX9vcQKGqHFRiBjpSZVc1e4jp3nbEtsEU18GqwbKxaFiV0fJOjVlHMgI7ReujbHc)Bczl5LUyen59vcHowNJfKh25xHAc8KGqHFRNSL8sxmIM8(kHqhRZXcYd78RqnbEsqOW)sISL8sxmIM8UeAAiUVsqL8Wo)kutGNeek8ZdjBjV0fJOjVlHMgI7ReujpSZVc1e4jbHcFSKSL8sxmIM8OUoNI60AYd78RqnbEsqcYtJ0PKkiBju4NSL8sxmIM8CR5bHKh25xHAc8KGqHpKTKx6Ir0KhmjppurEyNFfQjWtccfwGSL8Wo)kutGN8C3e4nj5ztbUC0CODSdJNWo6HDy0dlY2HfGYc4JvfyxbUC0CODSdJNWo6HDyMUauwalAvbSL8sxmIM8wXtmoofMWibHcls2sEPlgrtEWeXiAYd78RqnbEsqOWkYwYd78RqnbEYZDtG3KKNtiuAb12COBHczSgzmZHE50Sca3cyHcSRarQWomh6wOqgJl)zRfTb78Rqn5LUyen5DPhSecjbHInHSL8Wo)kutGN8C3e4nj59LOPnh6wOqgRrgZOfu7cSRaA8lrtBydcH)dZf4z0cQDb4ZVa0d0AWDOxonRaWTawzj5LUyen55enpjHN4yC)SB8ibHcRNSL8Wo)kutGN8C3e4nj5b50Md9YPzfqEbSSa7kGnfWMc8LOPnFLqOvsSWibRa85xGivyhMSHWJZl7ec9WomyNFfQlaF(f4YrZH2XomPwZmtxaklGFllGTfGp)cqpqRb3HE50Scqzb8BPLfGp)cytbIuHDy8sglDhAWo)kuxGDfiYdcdZkMQy1aZffaUfWcwvaBlaF(fiYdcdZkMQy1aZffaUfWhllaF(fiYdcdtmEixi40dwa4wa)wvGDf4YrZH2XomPwZmtxaklGFllGTfyxbSPamyOsXf5bHbZqDDof1P1fqEb8xa(8lWxIM24HzW5uyAhpJeScyl5LUyen5DOBHczSgzmsqOyjr2sEyNFfQjWtEUBc8MK8uODuvaklGf2KcSRa2uagmuP4I8GWGzOUoNI606cqzb8xGDfW6kWxIM24HzW5uyAhpJeScWNFbUC0CODSdtQ1mZ0faUfaYPlWUcyDf4lrtB8Wm4CkmTJNrcwbSL8sxmIM8OUoNI60AsqOGhs2sEPlgrtEsmKBc0JrEyNFfQjWtccf(TKSL8sxmIM8(kHqZrlDBqEyNFfQjWtccf(9t2sEyNFfQjWtEUBc8MK8(s00MdDluiJ1iJzKGrEPlgrtEF8y4TyAisqOWVpKTKh25xHAc8KN7MaVjjVVenT5q3cfYynYygTGAxGDfqJFjAAdBqi8FyUapJwqTjV0fJOjp1aTgmoEgjnKh2bjiu43cKTKx6Ir0Kh9C4xjeAYd78RqnbEsqOWVfjBjV0fJOjVSDilUuX5sLI8Wo)kutGNeek8Bfzl5HD(vOMap55UjWBsY7lrtBo0TqHmwJmMrlO2fyxb04xIM2Wgec)hMlWZOfu7cSRaFjAAd2xcHgjyKx6Ir0K3pH4e0CXnUfmsqOW)Mq2sEyNFfQjWtEPlgrtENuZLUyenNAyb5PgwW1PhsESPHuixKhegKGeKNNWo6HDq2sOWpzl5LUyen5TINyCCkmHrEyNFfQjWtcsqEWo0j8(zq2sOWpzl5LUyen59ZiuihBvifKh25xHAc8KGqHpKTKx6Ir0K3HUfkKXAKXipSZVc1e4jbjib5zhp2iAcf(yPpw63hlTI8OMxpneJ8SgEWexG6cyXcKUyeDbudlyMsg5XGHocfwVpKhStqpkK88TalrPBJcS05DJ4kz(waEeDO3hVc43IlxaFS0hllzLmFlapWA2qiBjxY8TaWPaBwRrDbwcsEEOYuY8TaWPa84WYVc1fWtyh9WokW(cWZHNyCfWAJjSc4sLQa20IOanIAuxaAXvGPHdu6HfWj6a30WwtjZ3caNcWdkSJ6caVk1ileNxbYwxaE8sirxGLsKxbYVWowa4vcHowNJffiefy8GDc7ybOpKNKW2Trbe0f4qNWZdBDgJOzfWg24XkWjKGwvBuaKNKsLTMsMVfaofyZAnQla8zekSaVvHuuGquayh6eE)mkWMxcwBtjZ3caNcSzTg1fGNFCH42OalLeBTa5xyhlaBAifcNipimkWsVoNI60AtjZ3caNcSzTg1fGNLHfWAeOhZuY8TaWPaBPI5IcqlUcS0RZPOoTUaFKwCybuODuvaly9MsMVfaofyPqpHDuxaRfJHTdzMsMVfaofGhfT1mkGedlWBqi8FyUaVcm0fycRjRaP6WuVrbKGvaB4rmJvVCbE2AkzLmFlG1AtrNuG6c8rAXHfWj8(zuGpcnnZuGn7CiSGvGw0WznppAjvbsxmIMvarR2WuYsxmIMzGDOt49ZGx57)zekKJTkKIsw6Ir0mdSdDcVFg8kF)HUfkKXAKXkzLmFlG1AtrNuG6cG2XBJceJhwGyflq6cXvGHvG0EoQ8RqtjlDXiAMC3AEqyjlDXiAgVY3dtYZdvLmFlW21HvGHvapbluBuGquayhAh7OaoHqPfuBwbOpHxb(40qfiDUrJDKk1gfqIH6cOLUPHkGNWo6HDykz(wG0fJOz8kF)j1CPlgrZPgwSCNEOCpHD0d7y5HwUNWo6HDy0dlY2HuAvjlDXiAgVY3VINyCCkmHT8ql3MlhnhAh7W4jSJEyhg9WISDiL(y1UlhnhAh7W4jSJEyhMPP0IwzBjlDXiAgVY3dteJOlzPlgrZ4v((l9GLq4YdTCNqO0cQT5q3cfYynYyMd9YPzW1c7IuHDyo0TqHmgx(ZwlAd25xH6sw6Ir0mELV3jAEscpXX4(z34T8ql)lrtBo0TqHmwJmMrlO2704xIM2Wgec)hMlWZOfuB(8PhO1G7qVCAgCTYYsw6Ir0mELV)q3cfYynYylp0YHCAZHE50m5wUZgB(s00MVsi0kjwyKGXNFKkSdt2q4X5LDcHEyhgSZVc185F5O5q7yhMuRzMPP0VL2YNp9aTgCh6LtZO0VLwYNVnrQWomEjJLUdnyNFfQ3f5bHHzftvSAG5c4AbRSLp)ipimmRyQIvdmxaxFSKp)ipimmX4HCHGtpiC9B1UlhnhAh7WKAnZmnL(T02D2WGHkfxKhegmd115uuNwl3pF(FjAAJhMbNtHPD8msWSTKLUyenJx57PUoNI606LhA5k0oQO0cBYoByWqLIlYdcdMH66CkQtRP0)oR7lrtB8Wm4CkmTJNrcgF(xoAo0o2Hj1AMzA4c507SUVenTXdZGZPW0oEgjy2wYsxmIMXR89smKBc0JvYsxmIMXR89FLqO5OLUnkzPlgrZ4v((pEm8wmn0YdT8VenT5q3cfYynYygjyLS0fJOz8kFVAGwdghpJKgYd7y5Hw(xIM2COBHczSgzmJwqT3PXVenTHnie(pmxGNrlO2LS0fJOz8kFp9C4xje6sw6Ir0mELVpBhYIlvCUuPkzPlgrZ4v((FcXjO5IBClylp0Y)s00MdDluiJ1iJz0cQ9on(LOPnSbHW)H5c8mAb1E3xIM2G9LqOrcwjlDXiAgVY3Fsnx6Ir0CQHfl3PhkNnnKc5I8GWOKvYsxmIMz8e2rpSd5R4jghNctyLSsw6Ir0mdBAifYf5bHbVY3Fj00qCFLG6YdT8tQrAXbHgQJsXjO5IvK7JhdVf4zqEsAGbd17(s00gQJsXjO5IvK7JhdVf4zo0lNMbxiNUKLUyenZWMgsHCrEqyWR89UtITone3xjOU8ql)KAKwCqOH6OuCcAUyf5(4XWBbEgKNKgyWq9UVenTH6OuCcAUyf5(4XWBbEMd9YPzWfYPlzPlgrZmSPHuixKheg8kFpBqi8FyUaVLhA5A8lrtBydcH)dZf4z0cQ9oByWqLIlYdcdMH66CkQtRP0pF(xoAo0o2Hj1AMzAk9BLTLS0fJOzg20qkKlYdcdELV)spyjeU8ql3MVenT5q3cfYynYygjy85)LOPnEON42GtqZPKCJMtFy6XmsWSLpFB(s00gSVecnh6LtZGlKtZN)LqiL8qlTTKLUyenZWMgsHCrEqyWR89orRrVUKLUyenZWMgsHCrEqyWR89z7gSdUKoWJTkClwEOL)LOPnyFjeAKGTZggmuP4I8GWGzOUoNI60Ak9ZN)LJMdTJDysTMzMMsR3kBlzPlgrZmSPHuixKheg8kFpdgMhNGM7NSye9YdT8VenTb7lHqJeSD2WGHkfxKhegmd115uuNwtPF(8VC0CODSdtQ1mZ0uArRSTKLUyenZWMgsHCrEqyWR894MIoPalzPlgrZmSPHuixKheg8kF)xLAKfIZB5Hw(xIM2G9LqOrc2oByWqLIlYdcdMH66CkQtRP0pF(xoAo0o2Hj1AMzAkTOv2wYsxmIMzytdPqUipim4v(E9LqIM7e5T8ql)lrtBW(si0ibBNnmyOsXf5bHbZqDDof1P1u6Np)lhnhAh7WKAnZmnL(TY2sw6Ir0mdBAifYf5bHbVY3)vcHowNJflp0Y)s00gSVecnAb1MpFNO1stySpUriX4CIoqpyH5YEbLwTlYdcdZkMQy1aZfW1cwTZ6IuHDyCNeQInmyNFfQlzPlgrZmSPHuixKheg8kF)xje6FgRlp0Y)s00gSVecnAb1MpFNO1stySpUriX4CIoqpyH5YEbLwTlYdcdZkMQy1aZfW1cwTZ6IuHDyCNeQInmyNFfQlzPlgrZmSPHuixKheg8kFVOzQucAnkzPlgrZmSPHuixKheg8kF)LqtdX9vcQlp0YDR5bHm5(uYsxmIMzytdPqUipim4v(E3jXwNgI7ReuxEOL7wZdczY9PKLUyenZWMgsHCrEqyWR89FLqOJ15yrjlDXiAMHnnKc5I8GWGx57)kHq)ZyTKLUyenZWMgsHCrEqyWR89xcnne3xjOwYsxmIMzytdPqUipim4v(E3jXwNgI7ReulzPlgrZmSPHuixKheg8kFp115uuNwtcsqi]] )


end
