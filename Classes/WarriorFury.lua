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


    spec:RegisterPack( "Fury", 20210213, [[dWKRPaqiuu8iiLnjO(efjnkPeNskPvPkPkVIq1SKs5wekTls9lKIHrrCmk0YeKEgKutdfvUMGyBOOkFJIughKKCoij16OirZJqX9iK9bP6GOO0crrEOQKktuvs5IQssTrksLpQkPQgPQKqNKIewjf1mrrvDtvjb7eP0qvLKSuij6PqmviXvPiv1wPiv5RqsySQsISxe)vvnyOoSOfJKhl0KP0LbBgL(SunAvXPvSAvjr9AvPMnj3wGDl53enCP44sPQLRYZr10P66eSDk47ivJxkvoVQeZhf2VstmsqHGythi0gQjHA0KqnIATruZCMecQIG4V0aeKMm(o7abPYaGGy6eUxiin5lkzAjOqq4sHlceKh3B4MsAOPp(JaLokdOHpbcQ0hzfVK1PHpbrAiiucJYnffHIGythi0gQjHA0KqnIATruJAtd1Hsqsb)rEeeKj41TyAwmZEXNjWNtYjipJ1cfHIGybEKGGgAl20jCVSyurE3iV1mAOTythqDc59YInI62wCOMeQX18Agn0w8R7jRoWnLRz0qBXIDXmR1c2f)QeccaLEnJgAlwSl(1gEsPa7IdKgGaO8ftZIFfHtoXfZ8HSzXXuPwClL0xCbGfSlMvElEkX2ZayXrz5q78w1Rz0qBXIDXVcsdGDXmPslWD5fS4SSl(1USlRfJkL5T4KsAawmtkP06pZX9f7YfpbnN0aSy2dAVauXxwSKDXheLbbqztFKfFXTWNa(IpPq)r9YIH2lKQw1Rz0qBXIDXmR1c2fZu6UcwmYJuWxSlxCZbrzav6lMzFvmF9Agn0wSyxmZATGDXMEt0L3llgvkWFwCsjnalMpvxbI1ZRd(IrfpZPOpLvVMrdTfl2fZSwlyxSPphwSPWHaUEnJgAlwSlgf6q(EXSYBXOIN5u0NYUykGvEWIvGbqTyuBA61mAOTyXUyujeina2f)Q5COIaxVMrdTfl2f)AYYu9flWHfJmqhOoiFd3Ih2fpUPYxCQoiTVSyHMf3YRbP)eKVHRvnbrnCNtqHGWNQRGVNxhCckeAnsqHGavsPalHjcs8ghUjjiNqbSYRdA6Js9LSF)b(uWXH7nCAO9cttdyxC4ftjWYQPpk1xY(9h4tbhhU3WPpiiNIVyXS4E0sqYOpYIGCzFQ(NsjPtCcTHsqHGavsPalHjcs8ghUjjiNqbSYRdA6Js9LSF)b(uWXH7nCAO9cttdyxC4ftjWYQPpk1xY(9h4tbhhU3WPpiiNIVyXS4E0sqYOpYIGCzFQ(NsjPtCcTOMGcbbQKsbwcteK4noCtsqOeyz1qDzh0heKtXxm6lUhTl(1BXHQdzXHxmVbuQVNxhCUM(ZCk6tzxm6l2ibjJ(ilccLkTa3LxaXj0YCeuiiqLukWsyIGeVXHBsccLalRgQl7GwOzXHxSH8MKsbAODquWHFZtYbcsg9rweKOSSqqrCcTHqqHGavsPalHjcs8ghUjjiwGsGLvZhOduhKVHtBL0RfhEXTSyEdOuFpVo4Cn9N5u0NYUy0xSXfZGXIVCSFWauUoTwUEQfJ(IngYIBLGKrFKfbHpqhOoiFdhXj0Y8iOqqGkPuGLWebjEJd3KeKwwmLalR(G4BfW5fW5AHMfZGXIPeyz1bqG8E5lz)kH4y)2dYaUwOzXTUygmwCllMsGLvd1LDqFqqofFXIzX9ODXmyS4l7WIrFXOAtwCReKm6JSiixg0KDG4eAnnckeKm6JSiirzzHGIGavsPalHjItOfvrqHGavsPalHjcs8ghUjjiucSSAOUSdAHMfhEXTSyEdOuFpVo4Cn9N5u0NYUy0xSXfZGXIVCSFWauUoTwUEQfJ(InTqwCReKm6JSiizfhO8FY6WXFKX3eNqlQMGcbbQKsbwcteK4noCtsqOeyz1qDzh0cnlo8IBzX8gqP(EEDW5A6pZPOpLDXOVyJlMbJfF5y)GbOCDATC9ulg9fZCHS4wjiz0hzrq4nqEFj7Nk5(ilItO1Ojeuiiz0hzrqG2brbhiiqLukWsyI4eAnAKGcbbQKsbwcteK4noCtsqOeyz1qDzh0cnlo8I5nGs9986GZ10FMtrFk7IfTyJlo8IVCSFWauUoTwUEQfJ(IzUqiit5WDcn(Fyji8gqP(EEDW5A6pZPOpLvKXW9OvFqqofxKjHB5YoGoQ2egmmK3KukqdTdIco8BEsoeMzIsPYkPx6OSSqqPpiiNI3kbjJ(ilccLkTa3LxabzkhUtOX)DLKkveeJeNqRXqjOqqGkPuGLWebjEJd3Keekbwwnux2bTqZIdV4wwmVbuQVNxhCUM(ZCk6tzxm6l24IzWyXxo2pyakxNwlxp1IrFXgdzXTsqYOpYIGyVSlR)jZJ4eAnIAckeeOskfyjmrqI34WnjbHsGLvd1LDqBL0RfZGXIJYYkmU2WehPa)hLLdbnU(Y69IrFXHS4Wl2ZRdU(bsL)OBI(IfZIrDilo8IzMf7Pckxhpbq5VOHkPuGLGKrFKfbHsjLw)zoUtCcTgzockeeOskfyjmrqI34WnjbHsGLvd1LDqBL0RfZGXIJYYkmU2WehPa)hLLdbnU(Y69IrFXHS4Wl2ZRdU(bsL)OBI(IfZIrDilo8IzMf7Pckxhpbq5VOHkPuGLGKrFKfbHsjLw)zoUtCcTgdHGcbbQKsbwcteK4noCtsqOeyz1bWfhfW5Fkzb9BklCAHMfhEX8gqP(EEDW5A6pZPOpLDXOVyutqYOpYIGq)zof9PSeNqRrMhbfcsg9rweezXvPq)XjiqLukWsyI4eAnAAeuiiqLukWsyIGeVXHBscs8jVoWxSOfhkbjJ(ilcYL9P6FkLKoXj0AevrqHGavsPalHjcs8ghUjjiXN86aFXIwCOeKm6JSiix2NQ)Pus6eNqRrunbfcsg9rweekLuA9N54obbQKsbwcteNqBOMqqHGKrFKfbHsjLw)zoUtqGkPuGLWeXj0gQrckeKm6JSiix2NQ)Pus6eeOskfyjmrCcTHgkbfcsg9rweKl7t1)ukjDccujLcSeMioH2qrnbfcsg9rwee6pZPOpLLGavsPalHjItOnuMJGcbjJ(ilcIHj6Y7L)jWFiiqLukWsyI4eAdneckeKm6JSiitqdu2P6Fdt0L3leeOskfyjmrCItqcKgGaOCckeAnsqHGKrFKfb5bo5e)kiBiiqLukWsyI4eNGyb2uq5eui0AKGcbjJ(ilcs8jVoqqGkPuGLWeXj0gkbfcsg9rweKgHGaqrqGkPuGLWeXj0IAckeeOskfyjmrqKneeo4eKm6JSiigYBskfqqmKkbGG4PckxhKCEgpqdvsPa7IdVypVo46hiv(JUj6lwmlg1HSygmwSNxhC9dKk)r3e9flMfhQjlMbJf751bx)aPYF0nrFXOVyuLjlo8IJsdqLLRnaL)8YrqmK3VYaGGaTdIco8BEsoqCcTmhbfccujLcSeMiiXBC4MKG0YIVCSFWauUoqAacGY12H7zfHfJ(IdnKfhEXxo2pyakxhinabq56Pwm6lM5czXTsqYOpYIG8aNCIFfKneNqBieuiiz0hzrqAK(ilccujLcSeMioHwMhbfccujLcSeMiiXBC4MKGeLsLvsV0heFRaoVaoxFqqofFXIzXOEXHxSNkOC9bX3kGZ)jvwwzPHkPuGLGKrFKfb5YGMSdeNqRPrqHGavsPalHjcs8ghUjjiucSS6dIVvaNxaNRTs61IdVylqjWYQ5d0bQdY3WPTs61IzWyXSt)X)heKtXxSywCiMqqYOpYIGeLv7fGtE8pvwfCeNqlQIGcbbQKsbwcteK4noCtsqyMfFcfWkVoO5tVa)lz)U8cGYb7)9uDUgAVW00a2fhEX9OvFqqofFXIwSjlo8IBzXTSykbwwnLskTkbURfAwmdgl2tfuUoRoC)GSYoeaLRHkPuGDXmyS4lh7hmaLRtRLRNAXOVyJMS4wxmdgl2ZRdU2Na47YVDGfJ(InAIjlMbJfBiVjPuGgAhefC438KCyXmySypVo4AFcGVl)2bwSywSXqwC4fF5y)GbOCDATC9ulg9fB0Kf36IdV4wwmVbuQVNxhCUM(ZCk6tzxSOfBCXmySykbwwDaK(pQG0aCAHMf3kbjJ(ilcYbX3kGZlGZjoHwunbfccujLcSeMiiXBC4MKGCcfWkVoO5tVa)lz)U8cGYb7)9uDUgAVW00a2fhEX9OvFqqofFXHxCZbg(9OvBuFzqt2HfhEXTS4wwmLalRMsjLwLa31cnlMbJf7PckxNvhUFqwzhcGY1qLukWUygmw8LJ9dgGY1P1Y1tTy0xSrtwCRlMbJf751bx7ta8D53oWIrFXgnXKfZGXInK3KukqdTdIco8BEsoSygmwSNxhCTpbW3LF7alwml2yilo8IVCSFWauUoTwUEQfJ(InAYIBDXHxCllM3ak13ZRdoxt)zof9PSlw0InUygmwmLalRoas)hvqAaoTqZIBLGKrFKfb5G4BfW5fW5eebo8LSS)E0sO1iXj0A0eckeeOskfyjmrqI34Wnjbrbga1IrFXOM5T4WlULfZBaL6751bNRP)mNI(u2fJ(InU4WlMzwmLalRoas)hvqAaoTqZIzWyXxo2pyakxNwlxp1IfZI7r7IdVyMzXucSS6ai9FubPb40cnlUvcsg9rwee6pZPOpLL4eAnAKGcbjJ(ilcIah(JdbCccujLcSeMioHwJHsqHGKrFKfbHsjL2pRW9cbbQKsbwcteNqRrutqHGavsPalHjcs8ghUjjiucSS6dIVvaNxaNRfAiiz0hzrqOGJd37P6eNqRrMJGcbbQKsbwcteK4noCtsqOeyz1heFRaoVaoxBL0RfhEXwGsGLvZhOduhKVHtBL0lcsg9rwee10FC()vwW2dGYjoHwJHqqHGKrFKfbHDoGsjLwccujLcSeMioHwJmpckeKm6JSiizfbUFP6htLIGavsPalHjItO1OPrqHGavsPalHjcs8ghUjjiucSS6dIVvaNxaNRTs61IdVylqjWYQ5d0bQdY3WPTs61IdVykbwwnux2bTqdbjJ(ilccv2)s2VFt8nN4eAnIQiOqqGkPuGLWebjJ(ilcYju)m6JS(QH7ee1W9FLbabHpvxbFpVo4eN4eKMdIYaQ0jOqO1ibfcsg9rweeQ0Df85psbNGavsPalHjItOnuckeeOskfyjmrqI34WnjbHzw8juaR86GMp9c8VK97YlakhS)3t15AO9cttdyjiz0hzrqoi(wbCEbCoXjoXjigGJpYIqBOMeQrtc1Kqji0ZRMQZjiOcMfvsRPG2xFt5IxmkpWINGg55lMvEl2uTaBkOCtDXh0EH5a7I5YayXPGldshSlo(Kvh461mZFkyXO2uU4xNSmaNd2fBQEQGY1VsM6ID5Invpvq56xjnujLcSM6IBXy7AvVMxZMIGg55GDXm3IZOpYAXQH7C9AMG0Cs2rbee0qBXMoH7LfJkY7g5TMrdTfB6aQtiVxwSru32Id1KqnUMxZOH2IFDpz1bUPCnJgAlwSlMzTwWU4xLqqaO0Rz0qBXIDXV2WtkfyxCG0aeaLVyAw8RiCYjUyMpKnloMk1IBPK(IlaSGDXSYBXtj2EgaloklhAN3QEnJgAlwSl(vqAaSlMjvAbUlVGfNLDXV2LDzTyuPmVfNusdWIzsjLw)zoUVyxU4jO5KgGfZEq7fGk(YILSl(GOmiakB6JS4lUf(eWx8jf6pQxwm0EHu1QEnJgAlwSlMzTwWUyMs3vWIrEKc(ID5IBoikdOsFXm7RI5RxZOH2If7IzwRfSl20BIU8EzXOsb(ZItkPbyX8P6kqSEEDWxmQ4zof9PS61mAOTyXUyM1Ab7In95WInfoeW1Rz0qBXIDXOqhY3lMvElgv8mNI(u2ftbSYdwScmaQfJAttVMrdTfl2fJkHaPbWU4xnNdve461mAOTyXU4xtwMQVyboSyKb6a1b5B4w8WU4Xnv(It1bP9Lfl0S4wEni9NG8nCTQxZRz0qBXV62brbhSlMcyLhS4OmGk9ftb9P46fZSXi048fxYsSp5fWkOwCg9rw8fll1l61Cg9rwCDZbrzav6IlIgQ0Df85psbFnNrFKfx3CqugqLU4IO5G4BfW5fW5TnSIyMtOaw51bnF6f4Fj73Lxauoy)VNQZ1q7fMMgWUMxZOH2IF1TdIcoyxmyaUxwSpbWI9hyXz0L3Ih(Itd5OskfOxZz0hzXffFYRdR5m6JS4IlIMgHGaqTMZOpYIlUiAmK3KukOTkdarq7GOGd)MNKdTzivcGipvq56GKZZ4bH986GRFGu5p6MOlguhcdgEEDW1pqQ8hDt0ftOMWGHNxhC9dKk)r3eD0rvMeoknavwU2au(Zl3Agn0wmkpdFXdFXbsUREzXUCXnhyakFXrPuzL0l(IzpzWIPGP6loJXXcLNk1llwGd2fBfUP6loqAacGY1Rz0qBXz0hzXfxenNq9ZOpY6RgU3wLbGOaPbiakVTHvuG0aeaLRTd3ZkcOhYAoJ(ilU4IO5bo5e)kiBAByf1YLJ9dgGY1bsdqauU2oCpRiGEOHe(YX(bdq56aPbiakxpf6mxiTUMZOpYIlUiAAK(iR1Cg9rwCXfrZLbnzhAByffLsLvsV0heFRaoVaoxFqqofxmOoSNkOC9bX3kGZ)jvwwzPHkPuGDnNrFKfxCr0eLv7fGtE8pvwfCTnSIOeyz1heFRaoVaoxBL0RWwGsGLvZhOduhKVHtBL0lgmyN(J)piiNIlMqmznNrFKfxCr0Cq8Tc48c482gwrmZjuaR86GMp9c8VK97YlakhS)3t15AO9cttdyd3Jw9bb5uCrMeULwOeyz1ukP0Qe4UwOHbdpvq56S6W9dYk7qauUgQKsbwgmUCSFWauUoTwUEk0nAsRmy451bx7ta8D53oa6gnXegmmK3KukqdTdIco8BEsoWGHNxhCTpbW3LF7aIXyiHVCSFWauUoTwUEk0nAsRHBH3ak13ZRdoxt)zof9PSImYGbLalRoas)hvqAaoTqtRR5m6JS4IlIMdIVvaNxaN3Mah(sw2FpAfzSTHv0juaR86GMp9c8VK97YlakhS)3t15AO9cttdyd3Jw9bb5u8Wnhy43JwTr9Lbnzhc3slucSSAkLuAvcCxl0WGHNkOCDwD4(bzLDiakxdvsPaldgxo2pyakxNwlxpf6gnPvgm886GR9ja(U8BhaDJMycdggYBskfOH2brbh(npjhyWWZRdU2Na47YVDaXymKWxo2pyakxNwlxpf6gnP1WTWBaL6751bNRP)mNI(uwrgzWGsGLvhaP)JkinaNwOP11Cg9rwCXfrd9N5u0NY22Wksbgaf6OM5fUfEdOuFpVo4Cn9N5u0NYIUXWmdLalRoas)hvqAaoTqddgxo2pyakxNwlxpLy6rByMHsGLvhaP)JkinaNwOP11Cg9rwCXfrJah(Jdb81Cg9rwCXfrdLskTFwH7L1Cg9rwCXfrdfCC4EpvVTHveLalR(G4BfW5fW5AHM1Cg9rwCXfrJA6po))kly7bq5TnSIOeyz1heFRaoVaoxBL0RWwGsGLvZhOduhKVHtBL0R1Cg9rwCXfrd7CaLskTR5m6JS4IlIMSIa3Vu9JPsTMZOpYIlUiAOY(xY(9BIV5TnSIOeyz1heFRaoVaoxBL0RWwGsGLvZhOduhKVHtBL0RWucSSAOUSdAHM1Cg9rwCXfrZju)m6JS(QH7TvzaiIpvxbFpVo4R51Cg9rwCDG0aeaLl6bo5e)kiBwZR5m6JS4A(uDf8986GlUiAUSpv)tPK0BByfDcfWkVoOPpk1xY(9h4tbhhU3WPH2lmnnGnmLalRM(OuFj73FGpfCC4EdN(GGCkUy6r7AoJ(ilUMpvxbFpVo4IlIM4jWFMQ)Pus6TnSIoHcyLxh00hL6lz)(d8PGJd3B40q7fMMgWgMsGLvtFuQVK97pWNcooCVHtFqqofxm9ODnNrFKfxZNQRGVNxhCXfrdLkTa3LxqBdRikbwwnux2b9bb5uC07r7RxO6qcZBaL6751bNRP)mNI(uw0nUMZOpYIR5t1vW3ZRdU4IOjklleuTnSIOeyz1qDzh0cnHnK3KukqdTdIco8BEsoSMZOpYIR5t1vW3ZRdU4IOHpqhOoiFdxBdRilqjWYQ5d0bQdY3WPTs6v4w4nGs9986GZ10FMtrFkl6gzW4YX(bdq560A56Pq3yiTUMZOpYIR5t1vW3ZRdU4IO5YGMSdTnSIAHsGLvFq8Tc48c4CTqddgucSS6aiqEV8LSFLqCSF7bzaxl00kdgTqjWYQH6YoOpiiNIlME0YGXLDaDuTjTUMZOpYIR5t1vW3ZRdU4IOjklleuR5m6JS4A(uDf8986GlUiAYkoq5)K1HJ)iJVBByfrjWYQH6YoOfAc3cVbuQVNxhCUM(ZCk6tzr3idgxo2pyakxNwlxpf6MwiTUMZOpYIR5t1vW3ZRdU4IOH3a59LSFQK7JSAByfrjWYQH6YoOfAc3cVbuQVNxhCUM(ZCk6tzr3idgxo2pyakxNwlxpf6mxiTUMZOpYIR5t1vW3ZRdU4IObAhefCynNrFKfxZNQRGVNxhCXfrdLkTa3LxqBdRikbwwnux2bTqtyEdOuFpVo4Cn9N5u0NYkYy4lh7hmaLRtRLRNcDMlK2MYH7eA8FxjPsLiJTnLd3j04)HveVbuQVNxhCUM(ZCk6tzfzmCpA1heKtXfzs4wUSdOJQnHbdd5njLc0q7GOGd)MNKdHzMOuQSs6Loklleu6dcYP4TUMZOpYIR5t1vW3ZRdU4IOXEzxw)tMxBdRikbwwnux2bTqt4w4nGs9986GZ10FMtrFkl6gzW4YX(bdq560A56Pq3yiTUMZOpYIR5t1vW3ZRdU4IOHsjLw)zoU32WkIsGLvd1LDqBL0lgmIYYkmU2WehPa)hLLdbnU(Y6n6He2ZRdU(bsL)OBIUyqDiHzgpvq564jak)fnujLcSR5m6JS4A(uDf8986GlUiAOusPLk9N2gwrucSSAOUSdARKEXGruwwHX1gM4if4)OSCiOX1xwVrpKWEEDW1pqQ8hDt0fdQdjmZ4Pckxhpbq5VOHkPuGDnNrFKfxZNQRGVNxhCXfrd9N5u0NY22WkIsGLvhaxCuaN)PKf0VPSWPfAcZBaL6751bNRP)mNI(uw0r9AoJ(ilUMpvxbFpVo4IlIgzXvPq)XxZz0hzX18P6k4751bxCr0CzFQ(NsjP32Wkk(Kxh4IcDnNrFKfxZNQRGVNxhCXfrt8e4pt1)ukj92gwrXN86axuOR5m6JS4A(uDf8986GlUiAOusP1FMJ7R5m6JS4A(uDf8986GlUiAOusPLk9N1Cg9rwCnFQUc(EEDWfxenx2NQ)Pus6R5m6JS4A(uDf8986GlUiAINa)zQ(NsjPVMZOpYIR5t1vW3ZRdU4IOH(ZCk6tzxZz0hzX18P6k4751bxCr0yyIU8E5Fc8N1Cg9rwCnFQUc(EEDWfxentqdu2P6Fdt0L3leeEdej0AAHsCIti]] )


end
