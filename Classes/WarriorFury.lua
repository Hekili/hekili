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
        },

        conquerors_banner = {
            aura = "conquerors_banner",

            last = function ()
                local app = state.buff.conquerors_banner.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / ( 1 * state.haste ) ) * ( 1 * state.haste ) )
            end,

            interval = 1,

            value = 4,
        },
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




    spec:RegisterHook( "TimeToReady", function( wait, action )
        local id = class.abilities[ action ].id
        if buff.bladestorm.up and ( id < -99 or id > 0 ) then
            wait = max( wait, buff.bladestorm.remains )
        end
        return wait
    end )
    
    
    spec:RegisterHook( "reset_precast", function ()
        rage_spent = nil
        rage_since_banner = nil
        
        if buff.bladestorm.up and buff.gathering_storm.up then
            applyBuff( "gathering_storm", buff.bladestorm.remains + 6, 5 )
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
                    duration = 12,
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

                if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end
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
                    duration = 12,
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


    spec:RegisterPack( "Fury", 20210310, [[dWu0VaqiPk5rsrTjk0NqQWOOiDkQeRsksvVIIywsHUffKDrYVGsggf4yuultQINrOY0qQuxtkyBivuFtksghuiDoQK06OskZJqv3dLAFivDqKkzHqPEisfzIqHQlcfI2OuKIpkvPOrkvPYjPsIwjvQzsLeUPuLs7KqzOsvQAPujvpfjtfk6QsrQSvPkf(kuOmwOqyVO6VGAWqoSOfdvpMQMmLUSQnJIpdYOLkNwPvlfP0RLQA2K62uXUL8BIgUu64uqTCGNJy6cxNGTtiFhLmEPiopuW8rk7xXCZCm5u2moxSEmOhZgioZgOm7QIdJ2qdCQadTNt1M((j05uv6CovtJaadCQ2edAzA5yYPisbG)CQUiAjUgwybTrNaUYlDWISoc6mwz5bjtGfzD8yXPWfwD4klooNYMX5I1Jb9y2aXz2aLzxvCy0gehNkfIojGtrTo0PbH1GOlGVBDIfijCQU1AFXX5u2t8CQMgbaggeglbGvcg392e47gKzdACq9yqpMh3JB6uxwqN4AJBdni6YAVDq9EbhNRvJBdnim(ssC9TdYrk6oVIbH1G6Dhix)GCfpBhKp16bzAjJbv)2BheJemOTmeu68b5Lv8MeUOg3gAq9wPOBhe260Esibodkl7GW4GeswdY1LjyqjUu0he2AP0gDlGedkKdADAbsrFqmGByHxEmmijZGa3lDCEzZyLfzqMswhYGasbOongg0nSqQDrnUn0GOlR92bHDgH(dIQtkedkKdQfCV0bpJbrx9ExHACBObrxw7TdQ3y9HeGHb56cKUbL4srFqKTG03qrcGEmimw3c0S2YQg3gAq0L1E7GA6iFqUY4oe142qdctwp7pigjyqySUfOzTLDq4Nrc(G0x01dsCnLACBOb563rk62bHrsiV8NOg3gAqyCzrhXGeiFqu7Hoo4z)dg0YmOnOdYGsn4PfddsODqMIXFgDoz)dCrnUn0GOUHfE5pzq1VDqHCq4FqGlApRBheJemOT8AbYkRbzAihKvoiSXelx)((6ti1jKbjIOge2yIvV7a56heDQlbq3ffNsVKGWXKtr2csF4ibqp4yYfZmhto1RexFlhBoLhSXbBYPac1zKaORyTAnSKbo6om(bKd6FG6gwyBBVDqgheUadJI1Q1Wsg4O7W4hqoO)bkWDYTids8dcYB5uPpwzXPaj0wqW4AjlEWfRhoMCQxjU(wo2CkpyJd2KtbeQZibqxXA1AyjdC0Dy8dih0)a1nSW22E7GmoiCbggfRvRHLmWr3HXpGCq)duG7KBrgK4heK3YPsFSYItbsOTGGX1sw8GlM44yYPEL46B5yZP8GnoytofP9AnCKaOhefRUfOzTLDqShK5bzCqqERcCNClYGypidgKXbz6GIu)kuojHKEWvVsC9TdIgTb5LIELvOe9k6WayqUmiJdsuc2exF1BY9cXHB7sYhKXbz6Gaj0he9dYvnyq0OnOEniVuQTswLYll7Dkf4o5wKb5cNk9XkloLpl)1W4cmmCkCbgg4kDoNcxN2tcjWHhCXOBoMCQxjU(wo2CkpyJd2KtHlWWOEbsORa3j3Imi6heK3oOM(b1JQHbzCqK2R1WrcGEquS6wGM1w2br)GmZPsFSYItHRt7jHe4WdUynWXKt9kX13YXMt5bBCWMCkCbgg1lqcDLq7GmoirjytC9vVj3lehUTljNtL(yLfNYll7DkEWfJoZXKt9kX13YXMt5bBCWMCk7XfyyuK9qhh8S)bkRKvniJdY0brAVwdhja6brXQBbAwBzhe9dY8GOrBqGCTWx0RqLwlrT1GOFqMByqUWPsFSYItr2dDCWZ(hWdUynfhto1RexFlhBoLhSXbBYPmDq4cmmkW991NqQtikH2brJ2GWfyyuo3rcWaSKbwl4xlSf80HOeAhKldIgTbz6GWfyyuVaj0vG7KBrgK4heK3oiA0geiH(GOFqUQbdYfov6JvwCkq60MqNhCXWOCm5uPpwzXP8YYENIt9kX13YXMhCXCvoMCQxjU(wo2CkpyJd2KtHlWWOEbsOReAhKXbz6GiTxRHJea9GOy1TanRTSdI(bzEq0OniqUw4l6vOsRLO2Aq0pOMQHb5cNk9Xklovw(9vaNmXbKoPVpp4Iz2aoMCQxjU(wo2CkpyJd2KtHlWWOEbsOReAhKXbz6GiTxRHJea9GOy1TanRTSdI(bzEq0OniqUw4l6vOsRLO2Aq0pi6UHb5cNk9XklofP9jawYaJNKyLfp4Iz2mhtov6JvwCQ3K7fIZPEL46B5yZdUyM7HJjN6vIRVLJnNYd24Gn5u4cmmQxGe6kH2bzCqMoOEniCbggf4((6ti1jef4o5wKbrJ2Gaj0hK4hudgmixgKXbrAVwdhja6brXQBbAwBzhe7bzEqgheixl8f9kuP1suBni6heD3aNk9XklofUoTNesGdp4IzwCCm5uVsC9TCS5uEWghSjNcxGHr9cKqxj0oiJdI0ETgosa0dIIv3c0S2Yoi2dY8GmoiqUw4l6vOsRLO2Aq0pi6Ubo1wXbaH2aEz4uK2R1WrcGEquS6wGM1ww2Mnc5TkWDYTiSnWOPGe607QgqJMOeSjU(Q3K7fId32LKBSxEPuBLSkLxw27ukWDYTiUWPsFSYItHRt7jHe4WP2koai0gWqAjEQ5uM5bxmZ0nhto1RexFlhBoLhSXbBYPWfyyuVaj0vcTdY4GmDqK2R1WrcGEquS6wGM1w2br)GmpiA0geixl8f9kuP1suBni6hK5ggKlCQ0hRS4uwqcjlyGmb8GlM5g4yYPEL46B5yZP8GnoytofUadJ6fiHUYkzvdIgTb5LLvydLO1VsbcSxwXDAdfiR(dI(b1WGmoOibqpuDp1rNQ1hds8dsCnmiJdQxdks9Rq5bcxhyq9kX13YPsFSYItHRLsB0TasWdUyMPZCm5uVsC9TCS5uEWghSjNcxGHr9cKqxzLSQbrJ2G8YYkSHs06xPab2lR4oTHcKv)br)GAyqghuKaOhQUN6Ot16Jbj(bjUggKXb1RbfP(vO8aHRdmOEL46B5uPpwzXPW1sPn6waj4bxmZnfhto1RexFlhBoLhSXbBYPWfyyuoh4x9jeyCzDiWw2ducTdY4GiTxRHJea9GOy1TanRTSdI(bjoov6JvwCkwDlqZAllp4IzgJYXKtL(yLfNsweDka1fCQxjU(wo28GlMzxLJjN6vIRVLJnNYd24Gn5u(UeaDYGypOEgenAdcxGHrbUVV(esDcrj0oiJdsuc2exF1BY9cXHB7sYhKXbfP(vOCscj9GREL46B5uPpwzXPaj0wqW4AjlEWfRhd4yYPEL46B5yZP8GnoytoLVlbqNmi2dQhov6JvwCkqcTfemUwYIhCX6Xmhtov6JvwCkCTuAJUfqco1RexFlhBEWfRNE4yYPsFSYItHRLsB0TasWPEL46B5yZdUy9iooMCQ0hRS4uGeAliyCTKfN6vIRVLJnp4I1dDZXKtL(yLfNcKqBbbJRLS4uVsC9TCS5bxSEAGJjNk9XklofRUfOzTLLt9kX13YXMhCX6HoZXKtL(yLfNs06djadWabshN6vIRVLJnp4I1ttXXKtL(yLfNADAFz3ccw06djadCQxjU(wo28GhCkhPO78k4yYfZmhtov6JvwCQUdKRhw)SLt9kX13YXMh8GtzptkOdoMCXmZXKtL(yLfNY3LaOZPEL46B5yZdUy9WXKtL(yLfNQvWX5Ao1RexFlhBEWftCCm5uVsC9TCS5uYwof5bNk9XkloLOeSjU(CkrPw4CQi1VcLtsiPhC1RexF7GmoOibqpuDp1rNQ1hds8dsCnmiA0guKaOhQUN6Ot16Jbj(b1JbdIgTbfja6HQ7Po6uT(yq0pimQbdY4G8srVYkuIEfDyaWPeLa4kDoN6n5EH4WTDj58GlgDZXKt9kX13YXMt5bBCWMCktheixl8f9kuosr35vOSljYY)br)G6PHbzCqGCTWx0Rq5ifDNxHARbr)GO7ggKlCQ0hRS4uDhixpS(zlp4I1ahtov6JvwCQwzSYIt9kX13YXMhCXOZCm5uVsC9TCS5uEWghSjNYlLARKvPa33xFcPoHOa3j3ImiXpiXniJdks9RqbUVV(ecCINLvwQxjU(wov6JvwCkq60MqNhCXAkoMCQxjU(wo2CkpyJd2KtHlWWOa33xFcPoHOSsw1Gmoi7XfyyuK9qhh8S)bkRKvniA0geZc1fWG7KBrgK4hudgWPsFSYIt5LLHfoqciW4zvhWdUyyuoMCQxjU(wo2CkpyJd2Kt1RbbeQZibqxrwO6bSKboKaNxXTW93cIOUHf222BhKXbb5TkWDYTidI9GmyqghKPdY0bHlWWOW1sPvlqcLq7GOrBqrQFfQSGoa2jRe6oVc1RexF7GOrBqGCTWx0RqLwlrT1GOFqMnyqUmiA0guKaOhQyDoCiHT7he9dYSbgmiA0gKOeSjU(Q3K7fId32LKpiA0guKaOhQyDoCiHT7hK4hK5ggKXbbY1cFrVcvATe1wdI(bz2Gb5YGmoitheP9AnCKaOhefRUfOzTLDqShK5brJ2GWfyyuopdyV(POducTdYfov6JvwCkW991NqQti8GlMRYXKt9kX13YXMt5bBCWMCkGqDgja6kYcvpGLmWHe48kUfU)wqe1nSW22E7GmoiiVvbUtUfzqghul4IGH8wLzfiDAtOpiJdY0bz6GWfyyu4AP0QfiHsODq0OnOi1Vcvwqha7KvcDNxH6vIRVDq0OniqUw4l6vOsRLO2Aq0piZgmixgenAdksa0dvSohoKW29dI(bz2adgenAdsuc2exF1BY9cXHB7sYhenAdksa0dvSohoKW29ds8dYCddY4Ga5AHVOxHkTwIARbr)GmBWGCzqghKPdI0ETgosa0dIIv3c0S2Yoi2dY8GOrBq4cmmkNNbSx)u0bkH2b5cNk9Xklof4((6ti1jeoLa5WsggyiVLlMzEWfZSbCm5uVsC9TCS5uEWghSjNsFrxpi6hK4OZdY4GmDqK2R1WrcGEquS6wGM1w2br)GmpiJdQxdcxGHr58mG96NIoqj0oiA0geixl8f9kuP1suBniXpiiVDqghuVgeUadJY5za71pfDGsODqUWPsFSYItXQBbAwBz5bxmZM5yYPsFSYItjqo8g3HWPEL46B5yZdUyM7HJjNk9XklofUwkTWmcamWPEL46B5yZdUyMfhhto1RexFlhBoLhSXbBYPWfyyuG77RpHuNqucTCQ0hRS4u4hqoO)wq8GlMz6MJjN6vIRVLJnNYd24Gn5u4cmmkW991NqQtikRKvniJdYECbggfzp0Xbp7FGYkzvCQ0hRS4u6fQliWnTcwiNxbp4IzUboMCQ0hRS4uml44AP0YPEL46B5yZdUyMPZCm5uPpwzXPYYFsasnSp1Ao1RexFlhBEWfZCtXXKt9kX13YXMt5bBCWMCkCbggf4((6ti1jeLvYQgKXbzpUadJISh64GN9pqzLSQbzCq4cmmQxGe6kHwov6JvwCk8ecwYahG13NWdUyMXOCm5uVsC9TCS5uPpwzXPacfC6JvwW6LeCk9sc4kDoNISfK(WrcGEWdEWPAb3lDWZGJjxmZCm5uPpwzXPWZi0hM0jfco1RexFlhBEWfRhoMCQxjU(wo2CkpyJd2Kt1RbbeQZibqxrwO6bSKboKaNxXTW93cIOUHf222B5uPpwzXPa33xFcPoHWdEWdoLOdiRS4I1Jb9y2GEmloofReuBbr4uym6Y1fZvkwVPRnObHz3h060kbXGyKGbrhKTG0hosa0d6yqGByHfC7GisNpOuiKozC7G8DzbDIAC7k26dsCU2GOtYs0bXTdIo8srVYkuyeQxjU(w6yqHCq0Hxk6vwHcJGogKPMBIlQX94gJrxUUyUsX6nDTbnim7(GwNwjigeJemi6WEMuqh0XGa3Wcl42brKoFqPqiDY42b57Yc6e142vS1hK4CTbrNKLOdIBheDeP(vOWiOJbfYbrhrQFfkmc1RexFlDmitn3exuJ7XTR0PvcIBheDpO0hRSgKEjbrnU5uTajZQpNQ5MhutJaaddcJLaWkbJ7MBEq92e47gKzdACq9yqpMh3J7MBEq0PUSGoX1g3n38Gm0GOlR92b17fCCUwnUBU5bzObHXxsIRVDqosr35vmiSguV7a56hKR4z7G8PwpitlzmO63E7GyKGbTLHGsNpiVSI3KWf14U5MhKHguVvk62bHToTNesGZGYYoimoiHK1GCDzcguIlf9bHTwkTr3ciXGc5GwNwGu0hed4gw4LhddsYmiW9shNx2mwzrgKPK1HmiGuaQtJHbDdlKAxuJ7MBEqgAq0L1E7GWoJq)br1jfIbfYb1cUx6GNXGOREVRqnUBU5bzObrxw7TdQ3y9HeGHb56cKUbL4srFqKTG03qrcGEmimw3c0S2YQg3n38Gm0GOlR92b10r(GCLXDiQXDZnpidnimz9S)GyKGbHX6wGM1w2bHFgj4dsFrxpiX1uQXDZnpidnix)osr3oimsc5L)e14U5MhKHgegxw0rmibYhe1EOJdE2)GbTmdAd6GmOudEAXWGeAhKPy8NrNt2)axuJ7MBEqgAqu3WcV8NmO63oOqoi8piWfTN1TdIrcg0wETazL1GmnKdYkhe2yILRFFF9jK6eYGerudcBmXQ3DGC9dIo1LaO7IACpUBU5bHr2K7fIBhe(zKGpiV0bpJbHFOTiQbrxE)BdYGkzzOUe4WiOhu6JvwKbjlnguJ70hRSiQwW9sh8mmHnw4ze6dt6KcX4o9XklIQfCV0bpdtyJf4((6ti1jKgxg29ciuNrcGUISq1dyjdCiboVIBH7VferDdlSTT3oUh3n38GWiBY9cXTd6IoaddkwNpOO7dk9HemOLmOuuU6exF14o9XklcBFxcG(4o9XklIjSXQvWX56XD6JvwetyJLOeSjU(nwPZz)MCVqC42UK8gfLAHZos9Rq5Kes6b3yKaOhQUN6Ot16dXlUgOrlsa0dv3tD0PA9H47XaA0Iea9q19uhDQwFqpg1aJEPOxzfkrVIomag3n38GWSBjdAjdYrscngguihul4IEfdYlLARKvrgedq6mi8Vf0GsVFTVIuRXWGei3oiRaylOb5ifDNxHAC3CZdk9XklIjSXciuWPpwzbRxs0yLoNTJu0DEfnUmSDKIUZRqzxsKL)03W4o9XklIjSXQ7a56H1pBBCzyBkixl8f9kuosr35vOSljYYF67PbJGCTWx0Rq5ifDNxHAl6P7gCzC3CZdk9XklIjSXICdl8Y)gxg2Ppwrh(1D2tyB2Oxk6vwHs0ROdda1RexFRrGqDgja6kYcvpGLmWHe48kUfU)wqe1nSW22EBJv6C2yJPrx)((UgUwkTr3ciHRbUVV(esDczC3CZdk9XklIjSXICdl8Y)gxg2Ppwrh(1D2tyB2yV8srVYkuIEfDyaOEL46BnceQZibqxrwO6bSKboKaNxXTW93cIOUHf222BBSsNZgBmnsN6sa0DnCTuAJUfqcxR7a56H9Dja6J70hRSiMWgRwzSYACN(yLfXe2ybsN2e6nUmS9sP2kzvkW991NqQtikWDYTiIxCgJu)kuG77RpHaN4zzLL6vIRVDCN(yLfXe2y5LLHfoqciW4zvh04YWgxGHrbUVV(esDcrzLSkJ2JlWWOi7Hoo4z)duwjRIgnMfQlGb3j3Ii(gmyCN(yLfXe2ybUVV(esDcPXLHDVac1zKaORilu9awYahsGZR4w4(Bbru3WcBB7TgH8wf4o5we2gy0utXfyyu4AP0QfiHsOLgTi1Vcvwqha7KvcDNxH6vIRVLgnqUw4l6vOsRLO2IEZg4cnArcGEOI15WHe2UNEZgyanAIsWM46REtUxioCBxsonArcGEOI15WHe2Ux8MBWiixl8f9kuP1suBrVzdCXOPK2R1WrcGEquS6wGM1ww2MPrdxGHr58mG96NIoqj06Y4o9XklIjSXcCFF9jK6esJcKdlzyGH8w2MBCzydeQZibqxrwO6bSKboKaNxXTW93cIOUHf222Bnc5TkWDYTigBbxemK3QmRaPtBcDJMAkUadJcxlLwTajucT0OfP(vOYc6ayNSsO78kuVsC9T0ObY1cFrVcvATe1w0B2axOrlsa0dvSohoKW290B2adOrtuc2exF1BY9cXHB7sYPrlsa0dvSohoKW29I3Cdgb5AHVOxHkTwIAl6nBGlgnL0ETgosa0dIIv3c0S2YY2mnA4cmmkNNbSx)u0bkHwxg3PpwzrmHnwS6wGM1w2gxg26l6A6fhD2OPK2R1WrcGEquS6wGM1ww6nBSx4cmmkNNbSx)u0bkHwA0a5AHVOxHkTwIAlXd5Tg7fUadJY5za71pfDGsO1LXD6JvwetyJLa5WBChY4o9XklIjSXcxlLwygbagg3PpwzrmHnw4hqoO)wqnUmSXfyyuG77RpHuNqucTJ70hRSiMWgl9c1fe4MwblKZROXLHnUadJcCFF9jK6eIYkzvgThxGHrr2dDCWZ(hOSsw14o9XklIjSXIzbhxlL2XD6JvwetyJvw(tcqQH9PwpUtFSYIycBSWtiyjdCawFFsJldBCbggf4((6ti1jeLvYQmApUadJISh64GN9pqzLSkJ4cmmQxGe6kH2XD6JvwetyJfqOGtFSYcwVKOXkDoBYwq6dhja6X4ECN(yLfr5ifDNxb7UdKRhw)SDCpUtFSYIOiBbPpCKaOhMWglqcTfemUwYQXLHnqOoJeaDfRvRHLmWr3HXpGCq)du3WcBB7TgXfyyuSwTgwYahDhg)aYb9pqbUtUfr8qE74o9XklIISfK(WrcGEycBS8abs3wqW4AjRgxg2aH6msa0vSwTgwYahDhg)aYb9pqDdlSTT3AexGHrXA1AyjdC0Dy8dih0)af4o5weXd5TJ70hRSikYwq6dhja6HjSXYNL)AyCbgMgR05SX1P9KqcCACzytAVwdhja6brXQBbAwBzzB2iK3Qa3j3IW2aJMgP(vOCscj9GREL46BPrZlf9kRqj6v0HbG6vIRV1fJIsWM46REtUxioCBxsUrtbj0P3vnGgTE5LsTvYQuEzzVtPa3j3I4Y4o9XklIISfK(WrcGEycBSW1P9KqcCACzyJlWWOEbsORa3j3IqpK3203JQbJK2R1WrcGEquS6wGM1ww6npUtFSYIOiBbPpCKaOhMWglVSS3PACzyJlWWOEbsOReAnkkbBIRV6n5EH4WTDj5J70hRSikYwq6dhja6HjSXISh64GN9pOXLHT94cmmkYEOJdE2)aLvYQmAkP9AnCKaOhefRUfOzTLLEZ0ObY1cFrVcvATe1w0BUbxg3PpwzruKTG0hosa0dtyJfiDAtO34YW2uCbggf4((6ti1jeLqlnA4cmmkN7ibyawYaRf8Rf2cE6qucTUqJMP4cmmQxGe6kWDYTiIhYBPrdKqNEx1axg3PpwzruKTG0hosa0dtyJLxw27uJ70hRSikYwq6dhja6HjSXkl)(kGtM4asN03VXLHnUadJ6fiHUsO1OPK2R1WrcGEquS6wGM1ww6ntJgixl8f9kuP1suBrFt1GlJ70hRSikYwq6dhja6HjSXI0(ealzGXtsSYQXLHnUadJ6fiHUsO1OPK2R1WrcGEquS6wGM1ww6ntJgixl8f9kuP1suBrpD3GlJ70hRSikYwq6dhja6HjSX6n5EH4J70hRSikYwq6dhja6HjSXcxN2tcjWPXLHnUadJ6fiHUsO1OP9cxGHrbUVV(esDcrbUtUfHgnqcDX3GbUyK0ETgosa0dIIv3c0S2YY2SrqUw4l6vOsRLO2IE6UHXD6Jvwefzli9HJea9We2yHRt7jHe404YWgxGHr9cKqxj0AK0ETgosa0dIIv3c0S2YY2SrqUw4l6vOsRLO2IE6UHg3koai0gWqAjEQzBUXTIdacTb8YWM0ETgosa0dIIv3c0S2YY2SriVvbUtUfHTbgnfKqNEx1aA0eLGnX1x9MCVqC42UKCJ9YlLARKvP8YYENsbUtUfXLXD6Jvwefzli9HJea9We2yzbjKSGbYe04YWgxGHr9cKqxj0A0us71A4ibqpikwDlqZAll9MPrdKRf(IEfQ0AjQTO3CdUmUtFSYIOiBbPpCKaOhMWglCTuAJUfqIgxg24cmmQxGe6kRKvrJMxwwHnuIw)kfiWEzf3PnuGS6tFdgJea9q19uhDQwFiEX1GXEfP(vO8aHRdmOEL46Bh3PpwzruKTG0hosa0dtyJfUwkT4z014YWgxGHr9cKqxzLSkA08YYkSHs06xPab2lR4oTHcKvF6BWyKaOhQUN6Ot16dXlUgm2Ri1VcLhiCDGb1RexF74o9XklIISfK(WrcGEycBSy1TanRTSnUmSXfyyuoh4x9jeyCzDiWw2ducTgjTxRHJea9GOy1TanRTS0lUXD6Jvwefzli9HJea9We2yjlIofG6IXD6Jvwefzli9HJea9We2ybsOTGGX1swnUmS9Dja6e29qJgUadJcCFF9jK6eIsO1OOeSjU(Q3K7fId32LKBms9Rq5Kes6bx9kX13oUtFSYIOiBbPpCKaOhMWglpqG0TfemUwYQXLHTVlbqNWUNXD6Jvwefzli9HJea9We2yHRLsB0TasmUtFSYIOiBbPpCKaOhMWglCTuAXZOBCN(yLfrr2csF4ibqpmHnwGeAliyCTK14o9XklIISfK(WrcGEycBS8abs3wqW4AjRXD6Jvwefzli9HJea9We2yXQBbAwBzh3PpwzruKTG0hosa0dtyJLO1hsagGbcKUXD6Jvwefzli9HJea9We2yToTVSBbblA9HeGbofP9EUynvp8GhCoa]] )


end
