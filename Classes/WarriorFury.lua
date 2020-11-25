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

        potion = "potion_of_unbridled_fury",

        package = "Fury",
    } )


    spec:RegisterSetting( "check_ww_range", false, {
        name = "Check |T132369:0|t Whirlwind Range",
        desc = "If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } ) 


    spec:RegisterPack( "Fury", 20201124, [[dKKPRaqiIOhHkQnPenkLKoLsIxHkmlrKBPeyxK6xqjddkQJbvAzeHNPe00OuY1ucTnOi13OuQghQi6CIqzDIqfZJsH7HkTprWbPuKfcL6HOIKMiue1ffHkTrurIrkcv5KqrIvsPAMqrKBcfbTtOIHcfHwkuK0tvPPcfUkueyRIqv9vurQ9c5VIAWeoSWIvXJjzYu5YGntvFgvnAOQtRQvtPuEnr1SP42uYUL8BugUiDCkf1Yv8CKMUuxxP2UsQVtKgpQiCEruRxeY8jk7hXiCryGUUObeosGzjWmU4kHT0sibUjMT4KOBNCkGUPHsEWdOBfwa6YPSNKr30izdlCimqxkBpkaDX3DknXblS4)g)(OvmlSOV12e9Zk1e(gl6BPWcDp730ykf6GUUObeosGzjWmU4kHT0sibUjMTweDJDJNnO79T4ujcSicBAu4FR(hgfDX)ohuOd66aQcD5mrWPSNKjcoDmZZgIDote4WwdwhyicjSvseHeywcmtStSZzIGtfFu8anXHyNZeXcicBY5ahrGjUTSaJMyNZeXcicm5Nghd4icl2AWcQMiWIis8GH9kIatcIuIqfgdrSAXAIOaWboIWZgI4RfWhwarOyvdCIEfnXoNjIfqeyczRbhrGTjCaTzJfreLJiWKNGNvebMklgIioS1arGTHXCn(FOnr0mI4Tsh2AGi8dyZBOujtemprmGIzzbLl6NvuIyv6BrjIHT5XBsMiaBEhMv0e7CMiwarytoh4icSJUnarCXZ2nr0mIiDafZ6enrytyIysAIDotelGiSjNdCerI)RA2KmrGPUP4jI4Wwdeb9lEdSGogEOjcon(Fms)YPj25mrSaIWMCoWreycOarGP0GfvtSZzIybebgsHqor4zdrWPX)Jr6xoI4aE2aeHbwdgIyH2UgDnpTPimqx6x8gi3XWdncdeo4IWaDHkogWHWgDvZ3W8b6o7c8SHh0sFJjZ85gpKpWqHromAWM3FAk4iILeXz79APVXKz(CJhYhyOWihg9awXxuIWgebVYHUHQFwHUtW)fF(yysrnchjqyGUqfhd4qyJUQ5By(aDNDbE2WdAPVXKz(CJhYhyOWihgnyZ7pnfCeXsI4S9ET03yYmFUXd5dmuyKdJEaR4lkrydIGx5q3q1pRq3j4)IpFmmPOgHZcryGUqfhd4qyJUQ5By(aDPPGXK7y4HMQLI)hJ0VCercebUeHmzeXeVldRHQ1HZr1Frejqe4Ui6gQ(zf6sFGhodeYHb1iCSfcd0fQ4yahcB0vnFdZhO7QeXz796buYnaLwaLQ3PeHmzeXz79AlWInjNz(SzREx2nqyr17uIyfIqMmIyvI4S9EnutWd6bSIVOeHnicELJiKjJiMGhiIeiIedZeXkOBO6NvO7ewPbpGAeolIWaDdv)ScDvSYbwf6cvCmGdHnQr4GPryGUqfhd4qyJUQ5By(aDpBVxd1e8GENseljIvjcAkym5ogEOPAP4)Xi9lhrKarGlritgrmX7YWAOAD4Cu9xerceHTVirSc6gQ(zf6gL6HQZHVHHINPKJAeo2ocd0fQ4yahcB0vnFdZhO7z79AOMGh07uIyjrSkrqtbJj3XWdnvlf)pgPF5iIeicCjczYiIjExgwdvRdNJQ)IisGiS1IeXkOBO6NvOlnfIjZ85tq7NvOgHdNeHb6gQ(zf6cCcqTBaDHkogWHWg1iCsmegOluXXaoe2ORA(gMpq3Z271qnbpO3PeXsIyvIGMcgtUJHhAQwk(Fms)Yrejqe4seYKret8UmSgQwhohv)frKaryRfjIvq3q1pRq3JjCaTzJfQr4GlMryGUqfhd4qyJUQ5By(aDpBVxd1e8GENseljIvjcAkym5ogEOPAP4)Xi9lhrKarGlritgrmX7YWAOAD4Cu9xercebUlseRGUHQFwHUUj4zvEyXGAeo4Ilcd0fQ4yahcB0vnFdZhO7z79AOMGh0oM0IiKjJiuSYT)wV(vpBtZkw1GvARNOKtejqelseljIogEO14HW041PQMiSbrSWfjILeHKerhgOATA2GPtwdvCmGdDdv)ScDpggZ14)H2OgHdUsGWaDHkogWHWgDvZ3W8b6E2EVgQj4bTJjTiczYicfRC7V1RF1Z20SIvnyL26jk5erceXIeXsIOJHhAnEimnEDQQjcBqelCrIyjrijr0HbQwRMny6K1qfhd4q3q1pRq3JHXCn(FOnQr4G7cryGUHQFwHUSIAInp(gDHkogWHWg1iCW1wimqxOIJbCiSrx18nmFGUk8XWduIGlrib6gQ(zf6ob)x85JHjf1iCWDregOluXXaoe2ORA(gMpqxf(y4bkrWLiKaDdv)ScDNG)l(8XWKIAeo4IPryGUHQFwHUhdJ5A8)qB0fQ4yahcBuJWbxBhHb6gQ(zf6EmmMRX)dTrxOIJbCiSrnchC5Kimq3q1pRq3j4)IpFmmPOluXXaoe2OgHdUjgcd0nu9Zk0Dc(V4Zhdtk6cvCmGdHnQr4ibMryGUHQFwHUsX)Jr6xo0fQ4yahcBuJA01ITgSGQryGWbxegOBO6NvOlEyyVkBGifDHkogWHWg1OgDDGp2MgHbchCryGUHQFwHUk8XWdOluXXaoe2OgHJeimq3q1pRq30TLfyqxOIJbCiSrncNfIWaDHkogWHWgDvZ3W8b6UkrmX7YWAOATfBnybvRDpTJsberceHelseljIjExgwdvRTyRblOA9xerceHTwKiwbDdv)ScDXdd7vzdePOgHJTqyGUHQFwHUPS(zf6cvCmGdHnQr4Sicd0fQ4yahcB0vnFdZhORIXmoM0spGsUbO0cOu9awXxuIWgeXcjILerhgOA9ak5gGsZXjkhR0qfhd4q3q1pRq3jSsdEa1iCW0imqxOIJbCiSrx18nmFGUNT3Rhqj3auAbuQ2XKweXsIWbNT3RPpWdNbc5WODmPfritgr4FE8DEaR4lkrydIyrmJUHQFwHUkwzZByydnFIQGb1iCSDegOluXXaoe2ORA(gMpq3vjIZ271dOKBakTakvVtjczYicfJzCmPLEaLCdqPfqP6bSIVOeHnicCjIviILeXQeXe8arKarWjXmrSKiwLioBVxBbrNvgiwdJENseljIZ271qnbpO3PeHmzebnfmMChdp0uTu8)yK(LJi4se4seRqeYKreowRlgN4zBAEnuml9awXxuIyf0nu9Zk09yymxM5ZnEidfyLmQr4WjryGUqfhd4qyJUQ5By(aDLKioBVxpGsUbO0cOu9oLiwsesseNT3RPpWdNbc5WO3POBO6NvOB6EEFYFXNpMG2OgHtIHWaDHkogWHWgDvZ3W8b6kjrC2EVEaLCdqPfqP6DkrSKiKKioBVxtFGhodeYHrVtr3q1pRq35ttnq(RmnnuaQr4GlMryGUqfhd4qyJUQ5By(aDLKioBVxpGsUbO0cOu9oLiwsesseNT3RPpWdNbc5WO3POBO6NvORu2yCRHVYdqzvuka1iCWfxegOluXXaoe2ORA(gMpqxjjIZ271dOKBakTakvVtjILeHKeXz79A6d8WzGqom6Dk6gQ(zf66zQnfC5irW8nKpqyHAeo4kbcd0fQ4yahcB0vnFdZhORKeXz796buYnaLwaLQ3PeXsIqsI4S9En9bE4mqihg9ofDdv)ScDhis)Ip7nHfqrnchCxicd0fQ4yahcB0vnFdZhORKeXz796buYnaLwaLQ3PeXsIqsI4S9En9bE4mqihg9oLiwseowRvSsbvprdUS3ewq(SNspGv8fLi4seygDdv)ScDvSsbvprdUS3ewaQr4GRTqyGUqfhd4qyJUQ5By(aDpBVxpGsUbO0SNnkqVtr3q1pRq3gpK31HTlx2ZgfGAeo4Uicd0fQ4yahcB0vnFdZhORKeXz796buYnaLwaLQ3PeXsIyvIOFli3SS7bIibIa3eBrIqMmIOJHhAnEimnEDQQjcBqesGzIyf0nu9Zk0LFhJ7JkZ85irWWA8OgHdUyAegOluXXaoe2ORA(gMpqxjjIZ271dOKBakTakvVtr3q1pRqxlWInjNz(SzREx2nqyrrnchCTDegOluXXaoe2ORA(gMpqxELtpGv8fLi4seyMiwseRsesseaLcLc0kw5GIcUS59GNnkqBf2gBiILeHKebqPqPa9XWyUmZNB8qgkWkzTvyBSHiKjJiumMXXKwA(DmUpQmZNJebdRXRhWk(Isejqe4seYKreNT3R53X4(OYmFosemSgVENseYKreNT3RpggZLz(CJhYqbwjR3PeXkOBO6NvO7ak5gGslGsrnchC5KimqxOIJbCiSrx18nmFGU0uWyYDm8qt1sX)Jr6xoIibIaxIyjryG1GHisGiwiMMiwsesseNT3RTGOZkdeRHrVtr3q1pRqxP4)Xi9lhQr4GBIHWaDHkogWHWgDdv)ScDdk(1rb08ejInzfBcd6QMVH5d0TFli3SS7bIWgeHeyMiKjJiKKiCWz796jseBYk2eMSdoBVxVtjczYiIvjIogEO19Bb5MLtvDEHyMiSbrSirSKiCWz79AfRCBv)RH8xYZo4S9E9oLiwHiKjJiwLiKKiCWz79AfRCBv)RH8xYZo4S9E9oLiwseNT3RTal2KCM5ZMT6Dz3aHfvVtjczYiI0bwN5voTeA(DmUpQmZNJebdRXteYKrePdSoZRCAj0dOKBakTakLiwseRsesseaLcLc0wGfBsoZ8zZw9USBGWIQTcBJneXsIqsIaOuOuGwXkhuuWLnVh8SrbARW2ydrScrSc6wHfGUbf)6OaAEIeXMSInHb1iCKaZimq3q1pRq3nfYFdwu0fQ4yahcBuJWrcCryGUqfhd4qyJUQ5By(aDNGhicBqe2cZeXsIqsI4S9E9ak5gGslGs17u0nu9Zk0ngvuqUzZavJAeosibcd0fQ4yahcB0vnFdZhO7z796buYnaLwaLQDmPfrSKiCWz79A6d8WzGqomAhtAHUHQFwHUMNhFtZ222XBbvJAeosSqegOluXXaoe2ORA(gMpq3Z271dOKBakTakv7yslIyjr4GZ2710h4HZaHCy0oM0IiwseNT3RHAcEqVtr3q1pRq3tWNz(CpVsof1iCKWwimqxOIJbCiSrx18nmFGUNT3Rhqj3auAbuQENIUHQFwHUhyOWi)lEuJWrIfryGUHQFwHUhdJ5Y(9Km6cvCmGdHnQr4ibMgHb6gQ(zf66)boggZHUqfhd4qyJAeosy7imq3q1pRq3OuaTNWKvHXGUqfhd4qyJAeosWjryGUqfhd4qyJUHQFwHUZUYHQFwLnpTrxZt7Cfwa6s)I3a5ogEOrnQr30bumRt0imq4Glcd0nu9Zk09eDBGmfpB3OluXXaoe2OgHJeimqxOIJbCiSr3kSa0nsefFmbn7zvNz(CktkmOBO6NvOBKik(ycA2ZQoZ85uMuyqncNfIWaDdv)ScDLYgJBn8vEakRIsbOluXXaoe2OgHJTqyGUHQFwHUwGfBsoZ8zZw9USBGWIIUqfhd4qyJAeolIWaDdv)ScD53X4(OYmFosemSgp6cvCmGdHnQr4GPryGUHQFwHUdOKBakTakfDHkogWHWg1Og1O7AyOpRq4ibMLaZ4IRe2cDLgt9fpfDXuSsztdoIWwerO6NveH5PnvtSJUPdZ)gaD5mrWPSNKjcoDmZZgIDote4WwdwhyicjSvseHeywcmtStSZzIGtfFu8anXHyNZeXcicBY5ahrGjUTSaJMyNZeXcicm5Nghd4icl2AWcQMiWIis8GH9kIatcIuIqfgdrSAXAIOaWboIWZgI4RfWhwarOyvdCIEfnXoNjIfqeyczRbhrGTjCaTzJfreLJiWKNGNvebMklgIioS1arGTHXCn(FOnr0mI4Tsh2AGi8dyZBOujtemprmGIzzbLl6NvuIyv6BrjIHT5XBsMiaBEhMv0e7CMiwarytoh4icSJUnarCXZ2nr0mIiDafZ6enrytyIysAIDotelGiSjNdCerI)RA2KmrGPUP4jI4Wwdeb9lEdSGogEOjcon(Fms)YPj25mrSaIWMCoWreycOarGP0GfvtSZzIybebgsHqor4zdrWPX)Jr6xoI4aE2aeHbwdgIyH2UMyNyNZerIlNau7gCeXb8SbicfZ6enrCa(VOAIWMukiTPerXQfGpgl)2qeHQFwrjcwzswtShQ(zfvNoGIzDIMdUyDIUnqMINTBI9q1pRO60bumRt0CWfRnfYFdwjvHfWnsefFmbn7zvNz(Cktkme7HQFwr1PdOywNO5GlwszJXTg(kpaLvrPaI9q1pRO60bumRt0CWfllWInjNz(SzREx2nqyrj2dv)SIQthqXSorZbxS43X4(OYmFosemSgpXEO6NvuD6akM1jAo4I1ak5gGslGsj2j25mrK4Yja1UbhraRHjzIOFlGiA8areQMneXtjIyD8M4yanXEO6NvuUk8XWde7HQFwr5GlwPBllWqSZzIad8pLiEkryXOTjzIOzer6aRHQjcfJzCmPfLi8dZIioWx8erOuVdQomMKjInfCeHBpFXtewS1GfuTMyNZerO6Nvuo4I1SRCO6NvzZt7KQWc4AXwdwq1j9EUwS1GfuT290okfKWIe7HQFwr5Glw4HH9QSbI0KEp3vN4DzynuT2ITgSGQ1UN2rPGeKyXLt8UmSgQwBXwdwq16VsWwlUcXEO6Nvuo4IvkRFwrShQ(zfLdUynHvAWdj9EUkgZ4ysl9ak5gGslGs1dyfFrTXcx2HbQwpGsUbO0CCIYXknuXXaoI9q1pROCWflfRS5nmSHMprvWK075E2EVEaLCdqPfqPAhtAT0bNT3RPpWdNbc5WODmPLmz(NhFNhWk(IAJfXmXEO6Nvuo4I1XWyUmZNB8qgkWk5KEp3vpBVxpGsUbO0cOu9ovMmfJzCmPLEaLCdqPfqP6bSIVO2a3vwU6e8qcCsmVC1Z271wq0zLbI1WO3PlpBVxd1e8GENktgnfmMChdp0uTu8)yK(LJlURitMJ16IXjE2MMxdfZspGv8fDfI9q1pROCWfR098(K)IpFmbTt69CL8S9E9ak5gGslGs170LsE2EVM(apCgiKdJENsShQ(zfLdUynFAQbYFLPPHcs69CL8S9E9ak5gGslGs170LsE2EVM(apCgiKdJENsShQ(zfLdUyjLng3A4R8auwfLcs69CL8S9E9ak5gGslGs170LsE2EVM(apCgiKdJENsShQ(zfLdUy5zQnfC5irW8nKpqyL075k5z796buYnaLwaLQ3PlL8S9En9bE4mqihg9oLypu9ZkkhCXAGi9l(S3ewanP3ZvYZ271dOKBakTakvVtxk5z79A6d8WzGqom6DkXEO6Nvuo4ILIvkO6jAWL9MWcs69CL8S9E9ak5gGslGs170LsE2EVM(apCgiKdJENU0XATIvkO6jAWL9MWcYN9u6bSIVOCXmXEO6Nvuo4IvJhY76W2Ll7zJcs69CpBVxpGsUbO0SNnkqVtj2dv)SIYbxS43X4(OYmFosemSgFsVNRKNT3Rhqj3auAbuQENUC1(TGCZYUhsa3eBrzY6y4HwJhctJxNQABibMxHypu9ZkkhCXYcSytYzMpB2Q3LDdew0KEpxjpBVxpGsUbO0cOu9oLypu9ZkkhCXAaLCdqPfqPj9EU8kNEaR4lkxmVCvjbkfkfOvSYbffCzZ7bpBuG2kSn2SusGsHsb6JHXCzMp34HmuGvYARW2yJmzkgZ4ysln)og3hvM5ZrIGH141dyfFrtaxzYoBVxZVJX9rLz(CKiyynE9ovMSZ271hdJ5YmFUXdzOaRK170vi2dv)SIYbxSKI)hJ0VCj9EU0uWyYDm8qt1sX)Jr6xUeWDPbwdMewiMEPKNT3RTGOZkdeRHrVtj2dv)SIYbxS2ui)nyLufwa3GIFDuanprIytwXMWK0752VfKBw29GnKaZYKjPdoBVxprIytwXMWKDWz796DQmzR2XWdTUFli3SCQQZleZ2yXLo4S9ETIvUTQ)1q(l5zhC2EVENUImzRkPdoBVxRyLBR6FnK)sE2bNT3R3PlpBVxBbwSj5mZNnB17YUbclQENktw6aRZ8kNwcn)og3hvM5ZrIGH14LjlDG1zELtlHEaLCdqPfqPlxvsGsHsbAlWInjNz(SzREx2nqyr1wHTXMLscukukqRyLdkk4YM3dE2OaTvyBSzLvi2dv)SIYbxS2ui)nyrj2dv)SIYbxSIrffKB2mq1j9EUtWd2WwyEPKNT3Rhqj3auAbuQENsShQ(zfLdUyzEE8nnBBBhVfuDsVN7z796buYnaLwaLQDmP1shC2EVM(apCgiKdJ2XKwe7HQFwr5GlwNGpZ85EELCAsVN7z796buYnaLwaLQDmP1shC2EVM(apCgiKdJ2XKwlpBVxd1e8GENsShQ(zfLdUyDGHcJ8V4t69CpBVxpGsUbO0cOu9oLypu9ZkkhCX6yymx2VNKj2dv)SIYbxS8)ahdJ5i2dv)SIYbxSIsb0EctwfgdXEO6Nvuo4I1SRCO6NvzZt7KQWc4s)I3a5ogEOj2j2dv)SIQTyRblOAU4HH9QSbIuIDI9q1pROA6x8gi3XWdnhCXAc(V4ZhdtAsVN7SlWZgEql9nMmZNB8q(adfg5WObBE)PPGB5z79APVXKz(CJhYhyOWihg9awXxuBWRCe7HQFwr10V4nqUJHhAo4ILA2u8FXNpgM0KEp3zxGNn8Gw6BmzMp34H8bgkmYHrd28(ttb3YZ271sFJjZ85gpKpWqHrom6bSIVO2Gx5i2dv)SIQPFXBGChdp0CWfl6d8WzGqomj9EU0uWyYDm8qt1sX)Jr6xUeWvMSjExgwdvRdNJQ)kbCxKypu9ZkQM(fVbYDm8qZbxSMWkn4HKEp3vpBVxpGsUbO0cOu9ovMSZ271wGfBsoZ8zZw9USBGWIQ3PRit2QNT3RHAcEqpGv8f1g8kNmztWdjKyyEfI9q1pROA6x8gi3XWdnhCXsXkhyve7HQFwr10V4nqUJHhAo4IvuQhQoh(ggkEMsEsVN7z79AOMGh070LRstbJj3XWdnvlf)pgPF5saxzYM4DzynuToCoQ(ReS9fxHypu9ZkQM(fVbYDm8qZbxSOPqmzMpFcA)SkP3Z9S9EnutWd6D6YvPPGXK7y4HMQLI)hJ0VCjGRmzt8UmSgQwhohv)vc2AXvi2dv)SIQPFXBGChdp0CWflGtaQDde7HQFwr10V4nqUJHhAo4I1XeoG2SXkP3Z9S9EnutWd6D6YvPPGXK7y4HMQLI)hJ0VCjGRmzt8UmSgQwhohv)vc2AXvi2dv)SIQPFXBGChdp0CWfl3e8SkpSys69CpBVxd1e8GENUCvAkym5ogEOPAP4)Xi9lxc4kt2eVldRHQ1HZr1FLaUlUcXEO6Nvun9lEdK7y4HMdUyDmmMRX)dTt69CpBVxd1e8G2XKwYKPyLB)TE9RE2MMvSQbR0wprjpHfx2XWdTgpeMgVov12yHlUuYomq1A1SbtNSgQ4yahXEO6Nvun9lEdK7y4HMdUyDmmM7en(KEp3Z271qnbpODmPLmzkw52FRx)QNTPzfRAWkT1tuYtyXLDm8qRXdHPXRtvTnw4IlLSdduTwnBW0jRHkogWrShQ(zfvt)I3a5ogEO5GlwSIAInp(Mypu9ZkQM(fVbYDm8qZbxSMG)l(8XWKM075QWhdpq5kbXEO6Nvun9lEdK7y4HMdUyPMnf)x85JHjnP3ZvHpgEGYvcI9q1pROA6x8gi3XWdnhCX6yymxJ)hAtShQ(zfvt)I3a5ogEO5GlwhdJ5orJNypu9ZkQM(fVbYDm8qZbxSMG)l(8XWKsShQ(zfvt)I3a5ogEO5GlwQztX)fF(yysj2dv)SIQPFXBGChdp0CWflP4)Xi9lh6stbfchBxcuJAeca]] )


end
