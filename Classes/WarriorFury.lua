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


    spec:RegisterPack( "Fury", 20210202, [[dWK9PaqiiP6rqkBsq9jbjnkPeNskPvbjj5vekZskLBrHyxK6xifdJq1XOOwgfQNrH00GK4AcITHsL8nbPmoPIY5GKuRdLk18qPQ7ri7ds1brPIfIs5HqsIjkvuDrPIKnkiHpcjj1iLkICsbjALuKzkivUPGuLDIuAOsfPwkKu6PQQPcjUQurWwfKQ6RqsXyLkcTxO(ledgXHfTyK8yHMmLUmyZO4ZQYOLQoTIvlve1RLknBsUTa7wYVjA4sXXLsvlxLNJQPt11jy7uW3rQgVuQCEPcZhLSFLgBgJc(BthW0AS4gBwCJf3yT5odvcr8qd)9oAa8VjJDZhG)vga4FOq46a)BYouY0Irb)5sHlc4FV7nC2nn08gVxGshLb0WNabv6JSIxY40WNGin4pLWO8qzHPWFB6aMwJf3yZIBS4gRn3zOsiIBg)tbVxE4)FcqvwcnlHDUy)e4Zj54F)yTqHPWFlWJ4pAOTKqHW1Xsqn5DJ8wtOH2scfa1jKxhlX42wIXIBS510Acn0wcQsFwpGZUxtOH2smYsyhRfSlPtleeak9Acn0wIrwsNp8Ksb2Leinabq5lHML0jbNCIlj0bzZsIPsTKwkPVKcalyxcJ8wYug5LbWsIYYH25TQxtOH2smYsc9Kga7sytLwG7YlyjzzxsNF5twlb1kZBjjL0aSe2usP17NJ7lXLlzcAoPbyjmh0EbOIDSejZsoikdcGYM(il(sAHpb8LCsHxVQJLaTxivTQxtOH2smYsyhRfSlHT0DfSKFVuWxIlxsZbrzav6lHD60Ho9Acn0wIrwc7yTGDjH(t0Lxhlb1kW7xssjnalHp1tbgXZ7b(sqn9ZPOpLvVMqdTLyKLWowlyxsNahwsO0HaUEnHgAlXilbf6q2DjmYBjOM(5u0NYUekGrEWsuGbqTeJgA61eAOTeJSeuleina2L0P4COIaxVMqdTLyKL05Yku9LiWHL8h4buhKDHBjdZsgpu5ljvhK2owIqZsAPZH07dYUW1Qg)vd35yuWF(upfG459ahJcMwZyuWFOskfyXSH)XBC4Me)pHcyK3d00hLcrYG49acfCC46cNgAVW00a2LeEjucmmA6JsHizq8EaHcooCDHtFqqofFjSFjVOf)ZOpYc)V8n1dHsjPJDmTgJrb)HkPuGfZg(hVXHBs8)ekGrEpqtFukejdI3diuWXHRlCAO9cttdyxs4LqjWWOPpkfIKbX7bek44W1fo9bb5u8LW(L8Iw8pJ(il8)Y3upekLKo2X0Aumk4pujLcSy2W)4noCtI)ucmmAOU8b6dcYP4lb9L8I2LGQAjgRdzjHxcVbukepVh4Cn9(5u0NYUe0xIz8pJ(il8NsLwG7Yla7yArfmk4pujLcSy2W)4noCtI)ucmmAOU8bAHMLeEjgYBskfOH2brbhqA6toG)z0hzH)rzzHGc7yAdbJc(dvsPalMn8pEJd3K4VfOeyy08bEa1bzx40wj9AjHxsllH3akfIN3dCUME)Ck6tzxc6lX8syXAjxoweWauUoTwUEQLG(smhYsAf)ZOpYc)5d8aQdYUWHDmTSlmk4pujLcSy2W)4noCtI)TSekbgg9bXUkGZlGZ1cnlHfRLqjWWOdGa51bIKbrjehlI9GmGRfAwsRlHfRL0YsOeyy0qD5d0heKtXxc7xYlAxclwl5YhSe0xcQw8L0k(NrFKf(Fzqt(aSJPn0WOG)z0hzH)rzzHGc)HkPuGfZg2X02zyuWFOskfyXSH)XBC4Me)Peyy0qD5d0cnlj8sAzj8gqPq88EGZ107NtrFk7sqFjMxclwl5YXIagGY1P1Y1tTe0xsOfYsAf)ZOpYc)Zkoq5ijJdhVxg7IDmTOAmk4pujLcSy2W)4noCtI)ucmmAOU8bAHMLeEjTSeEdOuiEEpW5A69ZPOpLDjOVeZlHfRLC5yradq560A56Pwc6lbvczjTI)z0hzH)8gipejdcvY9rwyhtRzXXOG)z0hzH)q7GOGd4pujLcSy2WoMwZMXOG)qLukWIzd)J34Wnj(tjWWOH6YhOfAws4LWBaLcXZ7boxtVFof9PSlr0smVKWl5YXIagGY1P1Y1tTe0xcQec(pLd3j04idd(ZBaLcXZ7boxtVFof9PSImh(fT6dcYP4IepClx(a0r1IZILH8MKsbAODquWbKM(KdHr9OuQSs6Loklleu6dcYP4TI)z0hzH)uQ0cCxEb4)uoCNqJJ8usQuH)MXoMwZgJrb)HkPuGfZg(hVXHBs8NsGHrd1Lpql0SKWlPLLWBaLcXZ7boxtVFof9PSlb9LyEjSyTKlhlcyakxNwlxp1sqFjMdzjTI)z0hzH)2lFYc5K5HDmTMnkgf8hQKsbwmB4F8ghUjXFkbggnux(aTvsVwclwljklRW4AdtCKcCKOSCiOX1xwDxc6ljKLeEjEEpW19qQ8EDt0xc7xIrdzjHxcQVepvq564jakVdnujLcS4Fg9rw4pLskTE)CCh7yAnJkyuWFOskfyXSH)XBC4Me)Peyy0qD5d0wj9AjSyTKOSScJRnmXrkWrIYYHGgxFz1DjOVKqws4L459ax3dPY71nrFjSFjgnKLeEjO(s8ubLRJNaO8o0qLukWI)z0hzH)ukP069ZXDSJP1CiyuWFOskfyXSH)XBC4Me)Peyy0bWfhfW5iuYcE3uw40cnlj8s4nGsH459aNRP3pNI(u2LG(smk(NrFKf(tVFof9PSyhtRz2fgf8pJ(il8xwCvk86D8hQKsbwmByhtR5qdJc(dvsPalMn8pEJd3K4FSpVhWxIOLym(NrFKf(F5BQhcLssh7yAn3zyuWFOskfyXSH)XBC4Me)J959a(seTeJX)m6JSW)lFt9qOus6yhtRzungf8pJ(il8NsjLwVFoUJ)qLukWIzd7yAnwCmk4Fg9rw4pLskTE)CCh)HkPuGfZg2X0ASzmk4Fg9rw4)LVPEiukjD8hQKsbwmByhtRXgJrb)ZOpYc)V8n1dHsjPJ)qLukWIzd7yAn2OyuW)m6JSWF69ZPOpLf)HkPuGfZg2X0AmQGrb)ZOpYc)nmrxEDGCc8E8hQKsbwmByhtRXHGrb)ZOpYc)NGgOSt9qmmrxEDG)qLukWIzd7yh)TatkOCmkyAnJrb)ZOpYc)J959a8hQKsbwmByhtRXyuW)m6JSW)gHGaqH)qLukWIzd7yAnkgf8hQKsbwmB4VSb)5GJ)z0hzH)gYBskfG)gsLaG)EQGY1bjNNXd0qLukWUKWlXZ7bUUhsL3RBI(sy)smAilHfRL459ax3dPY71nrFjSFjgl(syXAjEEpW19qQ8EDt0xc6lPZeFjHxsuAaQSCTbO8(oo83qEivga4p0oik4astFYbSJPfvWOG)qLukWIzd)J34Wnj(3YsUCSiGbOCDG0aeaLRTd3Zkclb9LyCilj8sUCSiGbOCDG0aeaLRNAjOVeujKL0k(NrFKf(3dNCIikiBWoM2qWOG)z0hzH)nsFKf(dvsPalMnSJPLDHrb)HkPuGfZg(hVXHBs8pkLkRKEPpi2vbCEbCU(GGCk(sy)sm6scVepvq56dIDvaNJKuzzLLgQKsbw8pJ(il8)YGM8byhtBOHrb)HkPuGfZg(hVXHBs8NsGHrFqSRc48c4CTvsVws4LybkbggnFGhqDq2foTvsVwclwlHzE9oYbb5u8LW(LeI44Fg9rw4FuwTxao5XrOYQGd7yA7mmk4pujLcSy2W)4noCtI)O(soHcyK3d085vGJizqC5faLdwKUt94AO9cttdyxs4L8Iw9bb5u8LiAjIVKWlPLL0YsOeyy0ukP0Qe4UwOzjSyTepvq56SEWHeKv(GaOCnujLcSlHfRLC5yradq560A56Pwc6lXS4lP1LWI1s88EGR9jaqCjIDGLG(smlU4lHfRLyiVjPuGgAhefCaPPp5WsyXAjEEpW1(eaiUeXoWsy)smhYscVKlhlcyakxNwlxp1sqFjMfFjTUKWlPLLWBaLcXZ7boxtVFof9PSlr0smVewSwcLadJoashjQG0aCAHML0k(NrFKf(FqSRc48c4CSJPfvJrb)HkPuGfZg(hVXHBs8)ekGrEpqZNxboIKbXLxauoyr6o1JRH2lmnnGDjHxYlA1heKtXxs4L0CGbKx0QnRVmOjFWscVKwwsllHsGHrtPKsRsG7AHMLWI1s8ubLRZ6bhsqw5dcGY1qLukWUewSwYLJfbmaLRtRLRNAjOVeZIVKwxclwlXZ7bU2NaaXLi2bwc6lXS4IVewSwIH8MKsbAODquWbKM(KdlHfRL459ax7taG4se7alH9lXCilj8sUCSiGbOCDATC9ulb9Lyw8L06scVKwwcVbukepVh4Cn9(5u0NYUerlX8syXAjucmm6aiDKOcsdWPfAwsR4Fg9rw4)bXUkGZlGZXFboGizyqErlMwZyhtRzXXOG)qLukWIzd)J34Wnj(RadGAjOVeJYUws4L0Ys4nGsH459aNRP3pNI(u2LG(smVKWlb1xcLadJoashjQG0aCAHMLWI1sUCSiGbOCDATC9ulH9l5fTlj8sq9LqjWWOdG0rIkinaNwOzjTI)z0hzH)07NtrFkl2X0A2mgf8pJ(il8xGdiJdbC8hQKsbwmByhtRzJXOG)z0hzH)ukP0IWiCDG)qLukWIzd7yAnBumk4pujLcSy2W)4noCtI)ucmm6dIDvaNxaNRfAW)m6JSWFk44W1DQh2X0AgvWOG)qLukWIzd)J34Wnj(tjWWOpi2vbCEbCU2kPxlj8sSaLadJMpWdOoi7cN2kPx4Fg9rw4VAE9ohPtwW(cGYXoMwZHGrb)ZOpYc)zMdOusPf)HkPuGfZg2X0AMDHrb)ZOpYc)ZkcC)sfsmvk8hQKsbwmByhtR5qdJc(dvsPalMn8pEJd3K4pLadJ(GyxfW5fW5ARKETKWlXcucmmA(apG6GSlCARKETKWlHsGHrd1Lpql0G)z0hzH)u5drYG43e7YXoMwZDggf8hQKsbwmB4Fg9rw4)juiz0hzHOgUJ)QH7ivga4pFQNcq88EGJDSJ)bsdqauogfmTMXOG)z0hzH)9WjNiIcYg8hQKsbwmByh74FZbrzav6yuW0AgJc(NrFKf(tLURaeEVuWXFOskfyXSHDmTgJrb)ZOpYc)pi2vbCEbCo(dvsPalMnSJP1OyuWFOskfyXSH)XBC4Me)r9LCcfWiVhO5ZRahrYG4YlakhSiDN6X1q7fMMgWI)z0hzH)he7QaoVaoh7yh74Vb44JSW0AS4glUzJnJk4p98QPEC8h1WoOwAdL0IQMDVKLGspSKjOrE(syK3scvlWKckpuxYbTxyoWUeUmawsk4YG0b7sI9z9aUEnf6McwIrz3lbvrwgGZb7scvpvq56oXqDjUCjHQNkOCDNOgQKsb2qDjTyUDTQxtRPqzqJ8CWUeuzjz0hzTe1WDUEnH)8giIPn0mg)BojZOa8hn0wsOq46yjOM8UrERj0qBjHcG6eYRJLyCBlXyXn28AAnHgAlbvPpRhWz3Rj0qBjgzjSJ1c2L0PfccaLEnHgAlXilPZhEsPa7scKgGaO8LqZs6KGtoXLe6GSzjXuPwslL0xsbGfSlHrElzkJ8Yayjrz5q78w1Rj0qBjgzjHEsdGDjSPslWD5fSKSSlPZV8jRLGAL5TKKsAawcBkP069ZX9L4YLmbnN0aSeMdAVauXowIKzjheLbbqztFKfFjTWNa(soPWRx1XsG2lKQw1Rj0qBjgzjSJ1c2LWw6UcwYVxk4lXLlP5GOmGk9LWoD6qNEnHgAlXilHDSwWUKq)j6YRJLGAf49ljPKgGLWN6PaJ459aFjOM(5u0NYQxtOH2smYsyhRfSlPtGdlju6qaxVMqdTLyKLGcDi7Ueg5Teut)Ck6tzxcfWipyjkWaOwIrdn9Acn0wIrwcQfcKga7s6uCourGRxtOH2smYs6CzfQ(se4Ws(d8aQdYUWTKHzjJhQ8LKQdsBhlrOzjT05q69bzx4AvVMwtOH2s6uTdIcoyxcfWipyjrzav6lHcEtX1lHDIrOX5lPKLr6ZlGrqTKm6JS4lrwQo0RPm6JS46MdIYaQ0ftenuP7kaH3lf81ug9rwCDZbrzav6IjIMdIDvaNxaNVMYOpYIRBoikdOsxmr0CqSRc48c482ggrO(juaJ8EGMpVcCejdIlVaOCWI0DQhxdTxyAAa7AAnHgAlPt1oik4GDjGb46yj(ealX7HLKrxElz4ljnKJkPuGEnLrFKfxuSpVhSMYOpYIlMiAAecca1AkJ(ilUyIOXqEtsPG2QmaebTdIcoG00NCOndPsae5PckxhKCEgpiSN3dCDpKkVx3eD2B0qyXYZ7bUUhsL3RBIo7nwCwS88EGR7Hu596MOJENjE4O0auz5Adq59DCRj0qBjO0p8Lm8Lei5UQJL4YL0CGbO8LeLsLvsV4lH5KblHcM6TKmghluEQuDSeboyxIv4M6TKaPbiakxVMqdTLKrFKfxmr0Ccfsg9rwiQH7TvzaikqAacGYBByefinabq5A7W9SIa6HSMYOpYIlMiA6HtorefKnTnmIA5YXIagGY1bsdqauU2oCpRiGUXHe(YXIagGY1bsdqauUEk0rLqADnLrFKfxmr00i9rwRPm6JS4IjIMldAYh02WikkLkRKEPpi2vbCEbCU(GGCko7nAypvq56dIDvaNJKuzzLLgQKsb21ug9rwCXertuwTxao5XrOYQGRTHreLadJ(GyxfW5fW5ARKEf2cucmmA(apG6GSlCARKEXIfZ86DKdcYP4SpeXxtz0hzXftenhe7QaoVaoVTHreQFcfWiVhO5ZRahrYG4YlakhSiDN6X1q7fMMgWg(fT6dcYP4IepClTqjWWOPusPvjWDTqdlwEQGY1z9GdjiR8bbq5AOskfyzX6YXIagGY1P1Y1tHUzXBLflpVh4AFcaexIyhaDZIlolwgYBskfOH2brbhqA6toWILN3dCTpbaIlrSdWEZHe(YXIagGY1P1Y1tHUzXBnCl8gqPq88EGZ107NtrFkRiZSyrjWWOdG0rIkinaNwOP11ug9rwCXerZbXUkGZlGZBtGdisggKx0kYCBdJOtOag59anFEf4isgexEbq5GfP7upUgAVW00a2WVOvFqqofpCZbgqErR2S(YGM8bHBPfkbggnLskTkbURfAyXYtfuUoRhCibzLpiakxdvsPallwxoweWauUoTwUEk0nlERSy559ax7taG4se7aOBwCXzXYqEtsPan0oik4astFYbwS88EGR9jaqCjIDa2BoKWxoweWauUoTwUEk0nlERHBH3akfIN3dCUME)Ck6tzfzMflkbggDaKosubPb40cnTUMYOpYIlMiAO3pNI(u22ggrkWaOq3OSRWTWBaLcXZ7boxtVFof9PSOBomQtjWWOdG0rIkinaNwOHfRlhlcyakxNwlxpf7FrByuNsGHrhaPJevqAaoTqtRRPm6JS4IjIgboGmoeWxtz0hzXftenukP0IWiCDSMYOpYIlMiAOGJdx3PETnmIOeyy0he7QaoVaoxl0SMYOpYIlMiAuZR35iDYc2xauEBdJikbgg9bXUkGZlGZ1wj9kSfOeyy08bEa1bzx40wj9AnLrFKfxmr0WmhqPKs7AkJ(ilUyIOjRiW9lviXuPwtz0hzXftenu5drYG43e7YBByerjWWOpi2vbCEbCU2kPxHTaLadJMpWdOoi7cN2kPxHPeyy0qD5d0cnRPm6JS4IjIMtOqYOpYcrnCVTkdar8PEkaXZ7b(AAnLrFKfxhinabq5I6HtorefKnRP1ug9rwCnFQNcq88EGlMiAU8n1dHsjP32Wi6ekGrEpqtFukejdI3diuWXHRlCAO9cttdydtjWWOPpkfIKbX7bek44W1fo9bb5uC2)I21ug9rwCnFQNcq88EGlMiAINaVFQhcLssVTHr0juaJ8EGM(OuisgeVhqOGJdxx40q7fMMgWgMsGHrtFukejdI3diuWXHRlC6dcYP4S)fTRPm6JS4A(upfG459axmr0qPslWD5f02WiIsGHrd1LpqFqqofh9x0IQYyDiH5nGsH459aNRP3pNI(uw0nVMYOpYIR5t9uaIN3dCXertuwwiOAByerjWWOH6YhOfAcBiVjPuGgAhefCaPPp5WAkJ(ilUMp1tbiEEpWften8bEa1bzx4AByezbkbggnFGhqDq2foTvsVc3cVbukepVh4Cn9(5u0NYIUzwSUCSiGbOCDATC9uOBoKwxtz0hzX18PEkaXZ7bUyIO5YGM8bTnmIAHsGHrFqSRc48c4CTqdlwucmm6aiqEDGizqucXXIypid4AHMwzXQfkbggnux(a9bb5uC2)IwwSU8bOJQfV11ug9rwCnFQNcq88EGlMiAIYYcb1AkJ(ilUMp1tbiEEpWftenzfhOCKKXHJ3lJDBByerjWWOH6YhOfAc3cVbukepVh4Cn9(5u0NYIUzwSUCSiGbOCDATC9uOhAH06AkJ(ilUMp1tbiEEpWften8gipejdcvY9rwTnmIOeyy0qD5d0cnHBH3akfIN3dCUME)Ck6tzr3mlwxoweWauUoTwUEk0rLqADnLrFKfxZN6PaepVh4IjIgODquWH1ug9rwCnFQNcq88EGlMiAOuPf4U8cAByerjWWOH6YhOfAcZBaLcXZ7boxtVFof9PSImh(YXIagGY1P1Y1tHoQesBt5WDcnoYtjPsLiZTnLd3j04idJiEdOuiEEpW5A69ZPOpLvK5WVOvFqqofxK4HB5YhGoQwCwSmK3KukqdTdIcoG00NCimQhLsLvsV0rzzHGsFqqofV11ug9rwCnFQNcq88EGlMiASx(KfYjZRTHreLadJgQlFGwOjCl8gqPq88EGZ107NtrFkl6MzX6YXIagGY1P1Y1tHU5qADnLrFKfxZN6PaepVh4IjIgkLuA9(54EBdJikbggnux(aTvsVyXkklRW4AdtCKcCKOSCiOX1xwDrpKWEEpW19qQ8EDt0zVrdjmQ7Pckxhpbq5DOHkPuGDnLrFKfxZN6PaepVh4IjIgkLuAPsVVTHreLadJgQlFG2kPxSyfLLvyCTHjosbosuwoe046lRUOhsypVh46EivEVUj6S3OHeg19ubLRJNaO8o0qLukWUMYOpYIR5t9uaIN3dCXerd9(5u0NY22WiIsGHrhaxCuaNJqjl4DtzHtl0eM3akfIN3dCUME)Ck6tzr3ORPm6JS4A(upfG459axmr0ilUkfE9(AkJ(ilUMp1tbiEEpWftenx(M6HqPK0BByef7Z7bCrgVMYOpYIR5t9uaIN3dCXert8e49t9qOus6TnmII959aUiJxtz0hzX18PEkaXZ7bUyIOHsjLwVFoUVMYOpYIR5t9uaIN3dCXerdLskTuP3VMYOpYIR5t9uaIN3dCXerZLVPEiukj91ug9rwCnFQNcq88EGlMiAINaVFQhcLssFnLrFKfxZN6PaepVh4IjIg69ZPOpLDnLrFKfxZN6PaepVh4IjIgdt0LxhiNaVFnLrFKfxZN6PaepVh4IjIMjObk7upedt0Lxhyh7yma]] )


end
