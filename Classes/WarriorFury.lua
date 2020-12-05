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


    spec:RegisterPack( "Fury", 20201205, [[dOeLIaqiIOEKsWMus(evb1OOQ0POQ4vejZsj0TiKSlQ8le0WuI6ykPwgjYZicnnLiUgjQTHqW3OkW4OkuDoecToLiP5re5Eev7Ji1brizHiupujszIes1fvIeBujs1ijKsojvHyLKWmPkuUjvbPDsigkvH0sjKINQQMkcCvQcITsiL6Rie1EH6VQYGr5WclgspMstMIld2Ss9zcgneDAvwnrGxtvA2K62K0UL8BKgoeoorqlxXZr10fDDeTDQQ(oHA8ie58ufTEesnFIY(LA8Amb4VjsalIslR0YRvAzLDRvsIsujIi(NEIaWFeH1Bia4FfQa(V0jhpXFeHNAAyWeG)Ck5yb8hzMi4lvcju4sKKOolvLq(PsQJ8OLDIDsi)uTeI)OKNo9ifgf)nrcyruAzLwETslRSBTssujjUg)dYejDW))PU0AgHnJOglYtnVHYXFKNXafgf)na3I)l0SLo54zZiYXmhDAfl0mrhSGkkmnt5fBMslR0YTIwXcnBPHmkbGVuBfl0mr1mIYyatZ8OKQQG21kwOzIQzI(XdunyAMk1pOcv2mcBMOfm0Z2mpgeiAMn06M5BrZMvayatZ20PzxjkHqfAMLwjqKsFCTIfAMOAMhk1pyAgX6Wa8KoQnlktZe9jeOvZen0yAwGs9dnJynLAsK3WZML0MDQigQFOz7bKqsOSE2m6UzdyPQQqzI8OfVz(YpvEZgkPasTNndKqYq7JRvSqZevZikJbmnJ4itn0Spskz2SK2medyPQOr2mIYJ6XCTIfAMOAgrzmGPzI2NnPJNnt0qYr2SaL6hAg)kbniQmgbiBgrg5nAXxzCTIfAMOAgrzmGPzEiCOzEKeu5UwXcntunJaXq4TzB60mImYB0IVY0muythOzAWpOBMe9axRyHMjQMjAavQFW0SLcNdLf4UwXcntunt0PLhoBgjhA2)abaDGWlmn72n7spmVzHEGW4zZir0mFfDisKQHxy8XH)6JNCmb4p)kbn8YyeGetawK1ycWFOcunyWeJ)25syUa)hYc20raCIpT(r3Vej8qHHdJxyCGesEiqaMMTQzOK7Tt8P1p6(LiHhkmCy8cJBa14kEZKuZeSg8pS5rl8FcHReEOAQyCIfrjmb4pubQgmyIXF7CjmxG)dzbB6iaoXNw)O7xIeEOWWHXlmoqcjpeiatZw1muY92j(06hD)sKWdfgomEHXnGACfVzsQzcwd(h28Of(pHWvcpunvmoXIirmb4pubQgmyIXF7CjmxG)gaLCVD8dea0bcVW4muXvZw1mFBghbO1Vmgbi5oXiVrl(ktZKUzRBMmznBIZ8a)qLUWy4URAM0nBTYnZh8pS5rl8NFGaGoq4fgCIfzjycWFOcunyWeJ)25syUa)9TzOK7TBaRxnW5fW5osentMSMHsU3ovqLoE(O7NM0EMNzGqL7ir0mFAMmznZ3MHsU3oOMqaCdOgxXBMKAMG10mzYA2ecqZKUzeXLBMp4FyZJw4)eQicbaNyrugta(h28Of(BPLbul8hQavdgmX4elcrata(dvGQbdMy83oxcZf4pk5E7GAcbWrIOzRAMVnJJa06xgJaKCNyK3OfFLPzs3S1ntMSMnXzEGFOsxymC3vnt6M5bk3mFW)WMhTW)OShu5l2jmCKuRxCIfXdWeG)qfOAWGjg)TZLWCb(JsU3oOMqaCKiA2QM5BZ4iaT(LXiaj3jg5nAXxzAM0nBDZKjRztCMh4hQ0fgd3DvZKUzlr5M5d(h28Of(ZraX8O7hAWZJw4elIhhta(h28Of(dejWsMa(dvGQbdMyCIfHiIja)Hkq1Gbtm(BNlH5c8hLCVDqnHa4ir0SvnZ3MXraA9lJrasUtmYB0IVY0mPB26MjtwZM4mpWpuPlmgU7QMjDZwIYnZh8pS5rl8hvhgGN0rfNyrwVmMa8hQavdgmX4VDUeMlWFuY92b1ecGJerZw1mFBghbO1Vmgbi5oXiVrl(ktZKUzRBMmznBIZ8a)qLUWy4URAM0nBTYnZh8pS5rl83mHaTEdngCIfz9Amb4pubQgmyIXF7CjmxG)OK7TdQjeaNHkUAMmznZsld5Lo)N9OK8NLwjOIiDtuEBM0nt5MTQzzmcq6qcHor6qyZMjPMjrLB2QMj5MLHgQ0zhsqNE6Gkq1Gb)dBE0c)r1uQjrEdpXjwK1kHja)Hkq1Gbtm(BNlH5c8hLCVDqnHa4muXvZKjRzwAziV05)ShLK)S0kbvePBIYBZKUzk3SvnlJrashsi0jshcB2mj1mjQCZw1mj3Sm0qLo7qc60thubQgm4FyZJw4pQMsnjYB4joXISwIycW)WMhTWFAX1bPaYe)Hkq1GbtmoXISEjycWFOcunyWeJ)25syUa)TiJra4ntEZuc)dBE0c)Nq4kHhQMkgNyrwRmMa8hQavdgmX4VDUeMlWFlYyeaEZK3mLW)WMhTW)jeUs4HQPIXjwK1ebmb4FyZJw4pQMsnjYB4j(dvGQbdMyCIfzThGja)dBE0c)r1uQjrEdpXFOcunyWeJtSiR94ycW)WMhTW)jeUs4HQPIXFOcunyWeJtSiRjIycW)WMhTW)jeUs4HQPIXFOcunyWeJtSikTmMa8pS5rl8xmYB0IVYG)qfOAWGjgN4e)vP(bvOsmbyrwJja)dBE0c)rcd9SpneiWFOcunyWeJtCI)gyhK6etawK1ycW)WMhTWFlYyea8hQavdgmX4elIsycW)WMhTWFeKQQGg)Hkq1GbtmoXIirmb4pubQgmyIXF7CjmxG)(2SjoZd8dv6uP(bvOsN54zuwOzs3mLuUzRA2eN5b(HkDQu)GkuP7QMjDZwIYnZh8pS5rl8hjm0Z(0qGaNyrwcMa8pS5rl8hbnpAH)qfOAWGjgNyrugta(dvGQbdMy83oxcZf4VLs1gQ4YnG1Rg48c4C3aQXv8MjPMjXMTQzzOHkDdy9Qbo)fOrzOLdQavdg8pS5rl8FcveHaGtSiebmb4pubQgmyIXF7CjmxG)OK7TBaRxnW5fW5odvC1SvnZaOK7TJFGaGoq4fgNHkUAMmznBFciZ3aQXv8MjPMP8Y4FyZJw4VLwsijm0H)qJQGbNyr8amb4pubQgmyIXF7CjmxG)cwJBa14kEZK3SLB2QM5BZKCZaohkl4S0Yafhmp9THnDSGtnKa60SvntYnd4COSGdvtPMhD)sKWdkq1tNAib0PzYK1mlLQnuXLtGmgZf1JUFbrddnr6gqnUI3mPB26MjtwZqj3BNazmMlQhD)cIggAI0rIOzYK1muY92HQPuZJUFjs4bfO6PJerZ8b)dBE0c)hW6vdCEbCooXI4XXeG)qfOAWGjg)TZLWCb(ZraA9lJrasUtmYB0IVY0mPB26MTQzAWpOBM0ntIeHMTQzsUzOK7TtfI8z1q4hghjc8pS5rl8xmYB0IVYGtSiermb4pubQgmyIX)WMhTW)GJ0Fua)nbrtNNLoHg)TZLWCb(NNk8s6ZCqZKuZuA5MjtwZKCZmak5E7MGOPZZsNq)mak5E7ir0mzYAMVnlJrasxEQWlPpe28jXLBMKAMYnBvZmak5E7S0YqAZZp8UY7ZaOK7TJerZ8PzYK1mFBMKBMbqj3BNLwgsBE(H3vEFgaLCVDKiA2QMHsU3ovqLoE(O7NM0EMNzGqL7ir0mzYAgIb8)eSgNsobYymxup6(fenm0ezZKjRzigW)tWACk5gW6vdCEbCEZw1mFBMKBgW5qzbNkOshpF09ttApZZmqOYDQHeqNMTQzsUzaNdLfCwAzGIdMN(2WMowWPgsaDAMpnZh8Vcva)dos)rb83eenDEw6eACIfz9YycW)WMhTWFso8Ueu54pubQgmyIXjwK1RXeG)qfOAWGjg)TZLWCb(pHa0mj1SLSCZw1mj3muY92nG1Rg48c4Chjc8pS5rl8pgBuWlPZavItSiRvcta(dvGQbdMy83oxcZf4pk5E7gW6vdCEbCUZqfxnBvZmak5E74hiaOdeEHXzOIl8pS5rl8xFcit(tcincQqL4elYAjIja)Hkq1Gbtm(BNlH5c8hLCVDdy9QboVao3zOIRMTQzgaLCVD8dea0bcVW4muXvZw1muY92b1ecGJeb(h28Of(Jgcp6(LZz9YXjwK1lbta(dvGQbdMy83oxcZf4pk5E7gW6vdCEbCUJeb(h28Of(JcdhgVxjGtSiRvgta(h28Of(JQPuZBtoEI)qfOAWGjgNyrwteWeG)HnpAH)7BaunLAWFOcunyWeJtSiR9amb4FyZJw4FuwGNtOF2qRXFOcunyWeJtSiR94ycWFOcunyWeJ)HnpAH)dz9cBE06PpEI)6JNVkub8NFLGgEzmcqItCI)igWsvrJetawK1ycW)WMhTWF0itn84iPKj(dvGQbdMyCIfrjmb4FyZJw4)awVAGZlGZXFOcunyWeJtCIt83pm8JwyruAzLwE9ALwc(loM6kbo(7rurqNemnBjnlS5rRMPpEYDTc8hXq3NgW)fA2sNC8Sze5yMJoTIfAMOdwqffMMP8IntPLvA5wrRyHMT0qgLaWxQTIfAMOAgrzmGPzEusvvq7Afl0mr1mr)4bQgmntL6huHkBgHnt0cg6zBMhdcenZgADZ8TOzZkamGPzB60SReLqOcnZsReisPpUwXcntunZdL6hmnJyDyaEsh1MfLPzI(ec0QzIgAmnlqP(HMrSMsnjYB4zZsAZoved1p0S9asijuwpBgD3SbSuvvOmrE0I3mF5NkVzdLuaP2ZMbsizO9X1kwOzIQzeLXaMMrCKPgA2hjLmBwsBgIbSuv0iBgr5r9yUwXcntunJOmgW0mr7ZM0XZMjAi5iBwGs9dnJFLGgevgJaKnJiJ8gT4RmUwXcntunJOmgW0mpeo0mpscQCxRyHMjQMrGyi82SnDAgrg5nAXxzAgkSPd0mn4h0ntIEGRvSqZevZenGk1pyA2sHZHYcCxRyHMjQMj60YdNnJKdn7FGaGoq4fMMD7MDPhM3Sqpqy8SzKiAMVIoejs1Wlm(4AfTIfA2sHibwYemndf20bAMLQIgzZqbHR4UMruwlGi5nROLOqgJ6Mu3SWMhT4nJwApDTIWMhT4oedyPQOrkLCcrJm1WJJKsMTIWMhT4oedyPQOrkLCchW6vdCEbCEROvSqZwkejWsMGPzGFy8Sz5PcnlrcnlSjDA2XBw4poDGQbxRiS5rlUClYyeGwryZJwCPKticsvvq3kwOzeG84n74ntLYtTNnlPndXa(HkBMLs1gQ4I3S9qvBgkCLqZcR9mqLHw7zZi5GPzgY5kHMPs9dQqLUwXcnlS5rlUuYjCiRxyZJwp9XZfRqfKRs9dQqLlEB5Qu)GkuPZC8mkliTYTIWMhT4sjNqKWqp7tdbIfVTCFN4mpWpuPtL6huHkDMJNrzbPvs5vtCMh4hQ0Ps9dQqLURKEjk7tRiS5rlUuYjebnpA1kcBE0IlLCcNqfrialEB5wkvBOIl3awVAGZlGZDdOgxXLKexLHgQ0nG1Rg48xGgLHwoOcunyAfHnpAXLsoHwAjHKWqh(dnQcMfVTCuY92nG1Rg48c4CNHkUwzauY92Xpqaqhi8cJZqfxYKTpbK5Ba14kUKuE5wryZJwCPKt4awVAGZlGZx82YfSg3aQXvC5lVYxjdCouwWzPLbkoyE6BdB6ybNAib0zLKbohkl4q1uQ5r3Vej8Gcu90PgsaDKjZsPAdvC5eiJXCr9O7xq0WqtKUbuJR4sVwMmuY92jqgJ5I6r3VGOHHMiDKiKjdLCVDOAk18O7xIeEqbQE6ir4tRiS5rlUuYjumYB0IVYS4TLZraA9lJrasUtmYB0IVYi96vAWpOLwIeHvsgLCVDQqKpRgc)W4ir0kcBE0IlLCcj5W7sqDXkub5bhP)Oa(BcIMoplDc9I3wEEQWlPpZbssPLLjtYgaLCVDtq005zPtOFgaLCVDKiKjZ3mgbiD5PcVK(qyZNexwskVYaOK7TZsldPnp)W7kVpdGsU3ose(itMVs2aOK7TZsldPnp)W7kVpdGsU3oseRqj3BNkOshpF09ttApZZmqOYDKiKjdXa(FcwJtjNazmMlQhD)cIggAIuMmed4)jynoLCdy9QboVaoFLVsg4COSGtfuPJNp6(PjTN5zgiu5o1qcOZkjdCouwWzPLbkoyE6BdB6ybNAib0XhFAfHnpAXLsoHKC4DjOYBfHnpAXLsoHXyJcEjDgOYfVT8jeajTKLxjzuY92nG1Rg48c4ChjIwryZJwCPKtO(eqM8NeqAeuHkx82Yrj3B3awVAGZlGZDgQ4ALbqj3Bh)abaDGWlmodvC1kcBE0IlLCcrdHhD)Y5SE5lEB5OK7TBaRxnW5fW5odvCTYaOK7TJFGaGoq4fgNHkUwHsU3oOMqaCKiAfHnpAXLsoHOWWHX7vclEB5OK7TBaRxnW5fW5oseTIWMhT4sjNqunLAEBYXZwryZJwCPKt4(gavtPMwryZJwCPKtyuwGNtOF2qRBfHnpAXLsoHdz9cBE06PpEUyfQGC(vcA4LXiazROve28Of3Ps9dQqLYrcd9SpneiAfTIWMhT4o(vcA4LXiaPuYjCcHReEOAQ4fVT8HSGnDeaN4tRF09lrcpuy4W4fghiHKhceGzfk5E7eFA9JUFjs4HcdhgVW4gqnUIljbRPve28Of3XVsqdVmgbiLsoH2HKJ8kHhQMkEXBlFilythbWj(06hD)sKWdfgomEHXbsi5HabywHsU3oXNw)O7xIeEOWWHXlmUbuJR4ssWAAfHnpAXD8Re0WlJrasPKti)abaDGWlmlEB5gaLCVD8dea0bcVW4muX1kF5iaT(LXiaj3jg5nAXxzKETmztCMh4hQ0fgd3DL0Rv2NwryZJwCh)kbn8YyeGuk5eoHkIqaw82Y9fLCVDdy9QboVao3rIqMmuY92PcQ0XZhD)0K2Z8mdeQChjcFKjZxuY92b1ecGBa14kUKeSgzYMqaKMiUSpTIWMhT4o(vcA4LXiaPuYj0sldOwTIWMhT4o(vcA4LXiaPuYjmk7bv(IDcdhj16DXBlhLCVDqnHa4irSYxocqRFzmcqYDIrEJw8vgPxlt2eN5b(HkDHXWDxjThOSpTIWMhT4o(vcA4LXiaPuYjKJaI5r3p0GNhTw82Yrj3BhutiaoseR8LJa06xgJaKCNyK3OfFLr61YKnXzEGFOsxymC3vsVeL9Pve28Of3XVsqdVmgbiLsoHarcSKj0kcBE0I74xjOHxgJaKsjNquDyaEsh1fVTCuY92b1ecGJeXkF5iaT(LXiaj3jg5nAXxzKETmztCMh4hQ0fgd3DL0lrzFAfHnpAXD8Re0WlJrasPKtOzcbA9gAmlEB5OK7TdQjeahjIv(YraA9lJrasUtmYB0IVYi9AzYM4mpWpuPlmgU7kPxRSpTIWMhT4o(vcA4LXiaPuYjevtPMe5n8CXBlhLCVDqnHa4muXLmzwAziV05)ShLK)S0kbvePBIYR0kVkJrashsi0jshcBkjjQ8kjNHgQ0zhsqNE6Gkq1GPve28Of3XVsqdVmgbiLsoHOAk1GgjYfVTCuY92b1ecGZqfxYKzPLH8sN)ZEus(ZsReurKUjkVsR8QmgbiDiHqNiDiSPKKOYRKCgAOsNDibD6PdQavdMwryZJwCh)kbn8YyeGuk5eslUoifqMTIWMhT4o(vcA4LXiaPuYjCcHReEOAQ4fVTClYyeaUCLAfHnpAXD8Re0WlJrasPKtODi5iVs4HQPIx82YTiJra4YvQve28Of3XVsqdVmgbiLsoHOAk1KiVHNTIWMhT4o(vcA4LXiaPuYjevtPg0ir2kcBE0I74xjOHxgJaKsjNWjeUs4HQPIBfHnpAXD8Re0WlJrasPKtODi5iVs4HQPIBfHnpAXD8Re0WlJrasPKtOyK3OfFLb)5ialwepqjCItmg]] )


end
