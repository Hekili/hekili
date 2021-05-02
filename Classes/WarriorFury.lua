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

            usable = function () return target.distance > 10 and ( query_time - action.charge.lastCast > gcd.execute ) end,
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
            gcd = "off",

            startsCombat = false,
            texture = 236171,

            usable = function () return ( query_time - action.heroic_leap.lastCast > gcd.execute ) end,
            handler = function ()
                setDistance( 15 ) -- probably heroic_leap + charge combo.
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end                
            end,

            copy = 52174
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


    spec:RegisterPack( "Fury", 20210502, [[dWeW6aqiPapcsyteYNqvvJskLtjf1Qqvf0RqIMLuOBHeSls9lkudJq1XOOwgKKNjvjttkixtQITbjL(MuLY4OiLZbjvToks18qcDpuL9HQYbPiXcPqEifjnruvPUOuQQnIQkWhrvfYiLsvCsPuLwPuYmLcQBIQks7KIyOOQIAPsvQEkunvcLRIQkuBfsQ8vuvjJfsk2lr)fkdg0HvSycESqtMsxw1MrQpdXOLkNwPvJQkIxlv1Sj52cSBr)gLHlOJdjA5aphX0P66OY2HuFNcgVuQCEPiZhjTFjlnlftIBh)stqL4OYS49ioQ0MrT9Y0mJkjU3u4L4HtS)GCjEobxIZpGd0KepCAsXgRumjoHXbIxI35EiX0n2yK174e0rwGXKnGtn(YYiyODJjBq0yjUa3Q82BkfK42XV0eujoQmlEpIJkTzuBVmnZML4dN3XasC8nWulOXf0uaXUnWxaJiX7wR9PuqIBpjkX5hWbAQG8RbawgOAzkHGvvqujEJfevIJkZvRQLP2njYjME1Icf0uS2Bli)mxqWv6Qffki)EjJG62cgWq)GNEbnUGTNdyBSGn8NWcghLQGTLmVG5V92csZafCtkGmbVGrw6VDEZ6Qffki)ug6BlOrQXEIZabfCsBb53GbHLfS3zdOGJad9lOrkgZ6DlG4f0zfCdcbm0VG0GJsUNXMkiJUGGhzbbpTJVSKuW2iBaPGaghsNQPcEuYnQM1vlkuqtXAVTGgnUREbX7yCEbDwbdbpYcegVGMc)CdRRwuOGMI1EBbrDB0zGMkyVZr6k4iWq)cs2erDk4da5Eb5xDlqzytRUArHcAkw7TfKFm5fS96pGORwuOGIz4t)csZafKF1TaLHnTfu40mWlO6OVQG9Q30vlkuWE)bm03wW2NqEgprxTOqb53SK)Eb5iVG47rUa4t)dk4sxW15pPGJc8X2ub5clyB87pExW0)GM1vlkuq87CHfKE6)csok5EgpPG0mqbXxK8EbzHppqlXvlXjsXK4KnruhZhaYDPystmlftI)Ceu3knsIhbRFWosCaxEAga5AdRsHXOX8UJjCa5G(hOpk52WWBlOOckWrtRnSkfgJgZ7oMWbKd6FGg8GztsbPybrIwj(e9LLsCWGSjcMGIzq6stqLumj(ZrqDR0ijEeS(b7iXbC5PzaKRnSkfgJgZ7oMWbKd6FG(OKBddVTGIkOahnT2WQuymAmV7ychqoO)bAWdMnjfKIfejAL4t0xwkXbdYMiyckMbPlnPxsXK4phb1TsJK4rW6hSJeNeELcZhaYDI2q3cug20wqEf0CbfvqKOvdEWSjPG8kO4fuubBRG(OE66GHqMi46NJG62csLAbJm0pN01OF6DnbkyZfuubrpGDeux)29iNFSWUH8ckQGTvqWG8cYxbr9IxqQulydkyKXuwMHuhzP9bPg8GztsbBwIprFzPepoz8kmboAAjUahnnwobxIlOg7jodeiDPjnKumj(ZrqDR0ijEeS(b7iXf4OP1pbdY1GhmBskiFfejAli)WcIkDpfuubjHxPW8bGCNOn0TaLHnTfKVcAwIprFzPexqn2tCgiq6st6rkMe)5iOUvAKepcw)GDK4cC006NGb5AUWckQGOhWocQRF7EKZpwy3qUeFI(YsjEKL2hKsxAcQvkMe)5iOUvAKepcw)GDK42lWrtRj7rUa4t)d0wMHSGIkyBfKeELcZhaYDI2q3cug20wq(kO5csLAbbZAXo6NUESwIEZcYxbn3tbBwIprFzPeNSh5cGp9pq6st6nPys8NJG6wPrs8iy9d2rI3wbf4OP1Gh7RoHKNq0CHfKk1ckWrtRdEad0egJgtXfxlMf8jGO5clyZfKk1c2wbf4OP1pbdY1GhmBskiflis0wqQuliyqEb5RGOEXlyZs8j6llL4GjiCqU0LMyAsXK4t0xwkXJS0(GuI)Ceu3kns6stq9sXK4phb1TsJK4rW6hSJexGJMw)emixZfwqrfSTcscVsH5da5orBOBbkdBAliFf0CbPsTGGzTyh9txpwlrVzb5RG9wpfSzj(e9LLs8jJ7thBO9diDSyFPlnXS4sXK4phb1TsJK4rW6hSJexGJMw)emixZfwqrfSTcscVsH5da5orBOBbkdBAliFf0CbPsTGGzTyh9txpwlrVzb5RGnupfSzj(e9LLsCs4hagJgtyi(YsPlnXSzPys8j6llL4VDpY5xI)Ceu3kns6stmJkPys8NJG6wPrs8iy9d2rIlWrtRFcgKR5clOOc2wbBqbf4OP1Gh7RoHKNq0GhmBskivQfemiVGuSG9iEbBUGIkij8kfMpaK7eTHUfOmSPTG8kO5ckQGGzTyh9txpwlrVzb5RGnups8j6llL4cQXEIZabsxAI5EjftI)Ceu3knsIhbRFWosCboAA9tWGCnxybfvqs4vkmFai3jAdDlqzytBb5vqZfuubbZAXo6NUESwIEZcYxbBOEK4B6ha4cDSLwItcVsH5da5orBOBbkdBA5zwes0Qbpy2KWtCrTbgKZhQxCQurpGDeux)29iNFSWUHCrniYyklZqQJS0(GudEWSjPzj(e9LLsCb1ypXzGaj(M(baUqhdrXegLe3S0LMyUHKIjXFocQBLgjXJG1pyhjUahnT(jyqUMlSGIkyBfKeELcZhaYDI2q3cug20wq(kO5csLAbbZAXo6NUESwIEZcYxbn3tbBwIprFzPe3cgewIbydq6stm3Jumj(ZrqDR0ijEeS(b7iXf4OP1pbdY1wMHSGuPwWilTCRRrVXLXrWIS0FqORbt2VG8vWEkOOc6da5UU7JY70HrVGuSG9QNckQGnOG(OE66iG7kVj9ZrqDReFI(YsjUGIXSE3ciU0LMyg1kftI)Ceu3knsIhbRFWosCboAA9tWGCTLzilivQfmYsl36A0BCzCeSil9he6AWK9liFfSNckQG(aqUR7(O8oDy0liflyV6PGIkydkOpQNUoc4UYBs)Ceu3kXNOVSuIlOymR3TaIlDPjM7nPys8NJG6wPrs8iy9d2rIlWrtRdoiUQtiycS8iGnThO5clOOcscVsH5da5orBOBbkdBAliFfSxs8j6llL4g6wGYWMwPlnXSPjftIprFzPeNLe1WH05s8NJG6wPrsxAIzuVumj(ZrqDR0ijEeS(b7iXJDda5KcYRGOQGuPwqboAAn4X(Qti5jenxybfvq0dyhb11VDpY5hlSBiVGIkOpQNUoyiKjcU(5iOUvIprFzPehmiBIGjOygKU0eujUumj(ZrqDR0ijEeS(b7iXJDda5KcYRGOsIprFzPehmiBIGjOygKU0euzwkMeFI(YsjUGIXSE3ciUe)5iOUvAK0LMGkujftIprFzPexqXywVBbexI)Ceu3kns6stqvVKIjXNOVSuIdgKnrWeumds8NJG6wPrsxAcQAiPys8j6llL4GbztembfZGe)5iOUvAK0LMGQEKIjXNOVSuIBOBbkdBAL4phb1TsJKU0euHALIjXNOVSuIJEJod0egGJ0jXFocQBLgjDPjOQ3KIjXNOVSuIVbHpTBIGHEJod0Ke)5iOUvAK0LUepGH(bpDPystmlftIprFzPeV7a2gXuFcL4phb1TsJKU0L42tpCkxkM0eZsXK4phb1TsJK4t0xwkXJDda5sC7jrWg6llL4MA3aqEbx6cA48h8cQyjsbdhIxqghOGSWNh0ybzGcA4f0Ys(7fm)Tf07EbzHppOGrwGaRG0mqbXxK8EbBlzjfqDp9UManRL4rW6hSJe33Gxq(kOPvqQulOpQNU2Y4euhZ3GRFocQBlivQfCI(I(ypFWEsb5RGMlivQfmYq)CsxJ(P31eOGuPwWguqaxEAga5AYIK3Xy0yode80VfR)Mie9rj3ggEBbPsTGrgtzzgsn4X(Qti5jen4bZMKcYxbrIwPlnbvsXK4t0xwkXd5ccUsI)Ceu3kns6st6Lumj(ZrqDR0ijoluItUlXNOVSuIJEa7iOUeh9O4Ue3h1txhmeYebx)Ceu3wqrf0haYDD3hL3PdJEbPyb7vpfKk1c6da5UU7JY70HrVGuSGOs8csLAb9bGCx39r5D6WOxq(kOPjEbfvWid9ZjDn6NExtajo6bGLtWL4VDpY5hlSBix6stAiPys8NJG6wPrs8j6llL4ckgZ6DlG4sC1MhlAL4MfxIhbRFWosCFdEbPybnTckQGt0x0h75d2tkiVcAUGIkiGlpndGCnzrY7ymAmNbcE63I1FteI(OKBddVTGIkyBfSbfmYq)CsxJ(P31eOGuPwWiJPSmdPg8yF1jK8eIg8GztsbPiVcIeTfSzjU9Kiyd9LLs82pGtn(jfCZ13rvqJumM17waXli5OK7z8fKMbkizte1PGpaK7fKYcIVi5DT0LM0Jumj(ZrqDR0ij(e9LLsCWJ9vNqYtisC1MhlAL4MfxIhbRFWosCFdEbPybnTckQGt0x0h75d2tkiVcAUGIkyKH(5KUg9tVRjqbfvqaxEAga5AYIK3Xy0yode80VfR)Mie9rj3ggEBbfvWqWrRfumM17waXL42tIGn0xwkXB)ao14NuWnxFhvb79h7RoHKNqki5OK7z8fKMbkizte1PGpaK7fKYcI6E6DnbkiLfeFrY7APlnb1kftI)Ceu3knsIprFzPeV7a2gXuFcL4Qnpw0kXnlUepcw)GDK4(g8csXc2tbfvWj6l6J98b7jfKxbnxqrfSbfmYq)CsxJ(P31eOGIkiGlpndGCnzrY7ymAmNbcE63I1FteI(OKBddVTGIkyi4O1ckgZ6DlG4fuubJmMYYmK6y3aqUg8GztsbPybfx3Je3EseSH(YsjE7hWPg)KcU567Oky75a2glyd)jSG8vqtTBaiVGKJsUNXxqAgOGKnruNc(aqUxqklyYskG6E6DnbkiLfeFrY7APlnP3KIjXFocQBLgjXNOVSuIh7gaYL4Qnpw0kXnlUepcw)GDK4(g8csXc2tbfvWj6l6J98b7jfKxbnxqrfSbfmYq)CsxJ(P31eOGIkiGlpndGCnzrY7ymAmNbcE63I1FteI(OKBddVTGIkyi4O1DhW2iM6tOe3EseSH(YsjE7hWPg)KcU567Oky75a2glyd)jSG8vqtTBaiVGKJsUNXxqAgOGKnruNc(aqUxqklyYskG6E6DnbkiLfeFrY7APlnX0KIjXNOVSuIhY8LLs8NJG6wPrsxAcQxkMe)5iOUvAKepcw)GDK4rgtzzgsn4X(Qti5jen4bZMKcsXc2RckQG(OE6AWJ9vNqWgHjTSu)Ceu3kXNOVSuIdMGWb5sxAIzXLIjXFocQBLgjXJG1pyhjUahnTg8yF1jK8eI2YmKfuubTxGJMwt2JCbWN(hOTmdzbPsTG0lsNJbEWSjPGuSG9iUeFI(YsjEKLOK7agGGjmzEG0LMy2Sumj(ZrqDR0ijEeS(b7iXBqbbC5PzaKRjlsEhJrJ5mqWt)wS(BIq0hLCBy4TfuubrIwn4bZMKcYRGIxqrfSTc2wbf4OP1ckgZQ4iUMlSGuPwqFupD9KihGfm5G8GNU(5iOUTGuPwqWSwSJ(PRhRLO3SG8vqZIxWMlivQf0haYDTVbhZzy29fKVcAwCXlivQfe9a2rqD9B3JC(Xc7gYlivQf0haYDTVbhZzy29fKIf0CpfuubbZAXo6NUESwIEZcYxbnlEbBUGIkyBfKeELcZhaYDI2q3cug20wqEf0CbPsTGcC006Gpowu9b9bAUWc2SeFI(Ysjo4X(Qti5jePlnXmQKIjXFocQBLgjXJG1pyhjoGlpndGCnzrY7ymAmNbcE63I1FteI(OKBddVTGIkyi4OXqIwTznycchKxqrfSTc2wbf4OP1ckgZQ4iUMlSGuPwqFupD9KihGfm5G8GNU(5iOUTGuPwqWSwSJ(PRhRLO3SG8vqZIxWMlivQf0haYDTVbhZzy29fKVcAwCXlivQfe9a2rqD9B3JC(Xc7gYlivQf0haYDTVbhZzy29fKIf0CpfuubbZAXo6NUESwIEZcYxbnlEbBUGIkyBfKeELcZhaYDI2q3cug20wqEf0CbPsTGcC006Gpowu9b9bAUWc2SeFI(Ysjo4X(Qti5jejoh5ymAAmKOvAIzPlnXCVKIjXFocQBLgjXJG1pyhjU6OVQG8vWEHAlOOc2wbjHxPW8bGCNOn0TaLHnTfKVcAUGIkydkOahnTo4JJfvFqFGMlSGuPwqWSwSJ(PRhRLO3SGuSGirBbfvWguqboAADWhhlQ(G(anxybBwIprFzPe3q3cug20kDPjMBiPys8j6llL4CKJT(dis8NJG6wPrsxAI5EKIjXNOVSuIlOymlgnhOjj(ZrqDR0iPlnXmQvkMe)5iOUvAKepcw)GDK4cC00AWJ9vNqYtiAUqj(e9LLsCHdih0FtePlnXCVjftI)Ceu3knsIhbRFWosCboAAn4X(Qti5jeTLzilOOcAVahnTMSh5cGp9pqBzgsj(e9LLsC1I05em(jCwKGNU0LMy20KIjXNOVSuItVGlOymRe)5iOUvAK0LMyg1lftIprFzPeFY4joyuyXrPK4phb1TsJKU0eujUumj(ZrqDR0ijEeS(b7iXf4OP1Gh7RoHKNq0wMHSGIkO9cC00AYEKla(0)aTLzilOOckWrtRFcgKR5cL4t0xwkXfgemgnMd2yFI0LMGkZsXK4phb1TsJK4t0xwkXbCj2e9LLyQL4sC1sCSCcUeNSjI6y(aqUlDPlXdbpYcegxkM0eZsXK4t0xwkXfg3vhJ0X4Cj(ZrqDR0iPlnbvsXK4phb1TsJK4rW6hSJeVbfeWLNMbqUMSi5DmgnMZabp9BX6VjcrFuYTHH3kXNOVSuIdESV6esEcr6sx6sC0hqwwknbvIJkZI3lujUe3WaYnrisC(LP07M0EnHFKPxWckw3l4geYaEbPzGcYFYMiQJ5da5o)li4OKBb3wqcl4fC4CwW43wWy3KiNORwn8MVG9Y0lOPYs0h43wq(hzOFoPRrn6NJG6w(xqNvq(hzOFoPRrn8VGTzUDnRRwvl(LP07M0EnHFKPxWckw3l4geYaEbPzGcYF7PhoLZ)ccok5wWTfKWcEbhoNfm(Tfm2njYj6QvdV5lyVm9cAQSe9b(TfK)(OE6Aud)lOZki)9r901Og9ZrqDl)lyBMBxZ6QvdV5lypMEbnvwI(a)2cY)id9ZjDnQr)Ceu3Y)c6ScY)id9ZjDnQH)fSnZTRzD1QH38fe1A6f0uzj6d8Bli)Jm0pN01Og9ZrqDl)lOZki)Jm0pN01Og(xW2m3UM1vRgEZxWEZ0lOPYs0h43wq(hzOFoPRrn6NJG6w(xqNvq(hzOFoPRrn8VGTzUDnRRwvR2Bqid43wWgQGt0xwwq1sCIUAjXdbm6vDjokqrb5hWbAQG8RbawgOAHcuuqtjeSQcIkXBSGOsCuzUAvTqbkkOP2njYjME1cfOOGuOGMI1EBb5N5ccUsxTqbkkifki)EjJG62cgWq)GNEbnUGTNdyBSGn8NWcghLQGTLmVG5V92csZafCtkGmbVGrw6VDEZ6QfkqrbPqb5NYqFBbnsn2tCgiOGtAli)gmiSSG9oBafCeyOFbnsXywVBbeVGoRGBqiGH(fKgCuY9m2ubz0fe8ili4PD8LLKc2gzdifeW4q6unvWJsUr1SUAHcuuqkuqtXAVTGgnUREbX7yCEbDwbdbpYcegVGMc)CdRRwOaffKcf0uS2BliQBJod0ub7Dosxbhbg6xqYMiQtbFai3li)QBbkdBA1vluGIcsHcAkw7TfKFm5fS96pGORwOaffKcfumdF6xqAgOG8RUfOmSPTGcNMbEbvh9vfSx9MUAHcuuqkuWE)bm03wW2NqEgprxTqbkkifki)ML83lih5feFpYfaF6Fqbx6cUo)jfCuGp2MkixybBJF)X7cM(h0SUAHcuuqkuq87CHfKE6)csok5EgpPG0mqbXxK8EbzHppqxTQwOaffS9B3JC(Tfu40mWlyKfimEbfoYMeDbnLy8HoPGjlPq3acO5ufCI(YssbzPQjD1AI(YsIoe8ilqyCk5zSW4U6yKogNxTMOVSKOdbpYcegNsEgdESV6esEcPXLMxdaC5PzaKRjlsEhJrJ5mqWt)wS(BIq0hLCBy4TvRQfkqrbB)29iNFBbp6dAQG(g8c6DVGt0zGcUKcoONvncQRRwOOGMA3aqEbx6cA48h8cQyjsbdhIxqghOGSWNh0ybzGcA4f0Ys(7fm)Tf07EbzHppOGrwGaRG0mqbXxK8EbBlzjfqDp9UManRRwt0xws4f7gaYBCP55BW5Z0Os1h1txBzCcQJ5BW1phb1TuPorFrFSNpypHpZuPgzOFoPRr)07AcqLAdaC5PzaKRjlsEhJrJ5mqWt)wS(BIq0hLCBy4TuPgzmLLzi1Gh7RoHKNq0GhmBs4djARwt0xwsOKNXHCbbxvTMOVSKqjpJrpGDeuVXCcoV3Uh58Jf2nK3i6rXDE(OE66GHqMi4I8bGCx39r5D6WOtXE1dvQ(aqUR7(O8oDy0PiQeNkvFai31DFuENom68zAIlkYq)CsxJ(P31eOAHcuuqX6wsbxsbdyex1ubDwbdbh9tVGrgtzzgssbPbSGck8nrk4eJR9PpkvtfKJCBbTCGnrkyad9dE66QfkqrbNOVSKqjpJbCj2e9LLyQL4nMtW5fWq)GNEJlnVag6h8012L4tgpF9uTqbkk4e9LLek5zC3bSnIP(e24sZRnWSwSJ(PRdyOFWtxBxIpz88HQEebM1ID0pDDad9dE66n5RH6P5QfkqrbNOVSKqjpJjhLCpJVXLM3e9f9XE(G9eEMffzOFoPRr)07AcOFocQBfb4YtZaixtwK8ogJgZzGGN(Ty93eHOpk52WWBBmNGZZiXe17p230fumM17waXnDWJ9vNqYtivluuW2pGtn(jfCZ13rvqJumM17waXli5OK7z8fKMbkizte1PGpaK7fKYcIVi5DD1AI(YscL8mwqXywVBbeVr1MhlA5zw8gxAE(gCkAAIMOVOp2ZhSNWZSiaxEAga5AYIK3Xy0yode80VfR)Mie9rj3ggERO2AqKH(5KUg9tVRjavQrgtzzgsn4X(Qti5jen4bZMekYdjABUAHIc2(bCQXpPGBU(oQc27p2xDcjpHuqYrj3Z4linduqYMiQtbFai3liLfe1907Acuqkli(IK31vRj6lljuYZyWJ9vNqYtinQ28yrlpZI34sZZ3Gtrtt0e9f9XE(G9eEMffzOFoPRr)07AcOFocQBfb4YtZaixtwK8ogJgZzGGN(Ty93eHOpk52WWBffcoATGIXSE3ciE1cfOOGt0xwsOKNXKJsUNX34sZBI(I(ypFWEcpZIAqKH(5KUg9tVRjG(5iOUveGlpndGCnzrY7ymAmNbcE63I1FteI(OKBddVTXCcopJetKP2naKB6ckgZ6DlG4ME3bSnIf7gaYRwOOGTFaNA8tk4MRVJQGTNdyBSGn8NWcYxbn1UbG8csok5EgFbPzGcs2erDk4da5EbPSGjlPaQ7P31eOGuwq8fjVRRwt0xwsOKNXDhW2iM6tyJQnpw0YZS4nU088n4uShrt0x0h75d2t4zwudIm0pN01OF6Dnb0phb1TIaC5PzaKRjlsEhJrJ5mqWt)wS(BIq0hLCBy4TIcbhTwqXywVBbexuKXuwMHuh7gaY1GhmBsOO46EQwOOGTFaNA8tk4MRVJQGTNdyBSGn8NWcYxbn1UbG8csok5EgFbPzGcs2erDk4da5EbPSGjlPaQ7P31eOGuwq8fjVRRwt0xwsOKNXXUbG8gvBESOLNzXBCP55BWPypIMOVOp2ZhSNWZSOgezOFoPRr)07AcOFocQBfb4YtZaixtwK8ogJgZzGGN(Ty93eHOpk52WWBffcoAD3bSnIP(ewTMOVSKqjpJdz(YYQ1e9LLek5zmycchK34sZlYyklZqQbp2xDcjpHObpy2KqXEjYh1txdESV6ec2imPLL6NJG62Q1e9LLek5zCKLOK7agGGjmzEqJlnpboAAn4X(Qti5jeTLzifzVahnTMSh5cGp9pqBzgsQuPxKohd8Gztcf7r8Q1e9LLek5zm4X(Qti5jKgxAEnaWLNMbqUMSi5DmgnMZabp9BX6VjcrFuYTHH3kcjA1GhmBs4jUO2AtGJMwlOymRIJ4AUqQu9r901tICawWKdYdE66NJG6wQubZAXo6NUESwIEt(mlEZuP6da5U23GJ5mm7E(mlU4uPIEa7iOU(T7ro)yHDd5uP6da5U23GJ5mm7EkAUhrGzTyh9txpwlrVjFMfVzrTrcVsH5da5orBOBbkdBA5zMkvboAADWhhlQ(G(anxyZvRj6lljuYZyWJ9vNqYtinYrogJMgdjA5zUXLMhGlpndGCnzrY7ymAmNbcE63I1FteI(OKBddVvui4OXqIwTznycchKlQT2e4OP1ckgZQ4iUMlKkvFupD9KihGfm5G8GNU(5iOULkvWSwSJ(PRhRLO3KpZI3mvQ(aqUR9n4yodZUNpZIlovQOhWocQRF7EKZpwy3qovQ(aqUR9n4yodZUNIM7reywl2r)01J1s0BYNzXBwuBKWRuy(aqUt0g6wGYWMwEMPsvGJMwh8XXIQpOpqZf2C1AI(YscL8m2q3cug2024sZtD0xXxVqTIAJeELcZhaYDI2q3cug20YNzrnqGJMwh8XXIQpOpqZfsLkywl2r)01J1s0BsrKOvude4OP1bFCSO6d6d0CHnxTMOVSKqjpJ5ihB9hqQwt0xwsOKNXckgZIrZbAQAnrFzjHsEglCa5G(BI04sZtGJMwdESV6esEcrZfwTMOVSKqjpJvlsNtW4NWzrcE6nU08e4OP1Gh7RoHKNq0wMHuK9cC00AYEKla(0)aTLziRwt0xwsOKNX0l4ckgZwTMOVSKqjpJNmEIdgfwCuQQ1e9LLek5zSWGGXOXCWg7tACP5jWrtRbp2xDcjpHOTmdPi7f4OP1K9ixa8P)bAlZqksGJMw)emixZfwTMOVSKqjpJbCj2e9LLyQL4nMtW5r2erDmFai3RwvRj6llj6ag6h8051DaBJyQpHvRQ1e9LLenzte1X8bGCNsEgdgKnrWeumdnU08aC5PzaKRnSkfgJgZ7oMWbKd6FG(OKBddVvKahnT2WQuymAmV7ychqoO)bAWdMnjuejARwt0xws0KnruhZhaYDk5zCeWr62ebtqXm04sZdWLNMbqU2WQuymAmV7ychqoO)b6JsUnm8wrcC00AdRsHXOX8UJjCa5G(hObpy2KqrKOTAnrFzjrt2erDmFai3PKNXXjJxHjWrt3yobNNGASN4mqqJlnps4vkmFai3jAdDlqzytlpZIqIwn4bZMeEIlQnFupDDWqiteC9ZrqDlvQrg6Nt6A0p9UMa6NJG62MfHEa7iOU(T7ro)yHDd5IAdmiNpuV4uP2GiJPSmdPoYs7dsn4bZMKMRwt0xws0KnruhZhaYDk5zSGASN4mqqJlnpboAA9tWGCn4bZMe(qIw(HOs3Jis4vkmFai3jAdDlqzytlFMRwt0xws0KnruhZhaYDk5zCKL2hKnU08e4OP1pbdY1CHIqpGDeux)29iNFSWUH8Q1e9LLenzte1X8bGCNsEgt2JCbWN(h04sZZEboAAnzpYfaF6FG2YmKIAJeELcZhaYDI2q3cug20YNzQubZAXo6NUESwIEt(m3tZvRj6lljAYMiQJ5da5oL8mgmbHdYBCP51MahnTg8yF1jK8eIMlKkvboAADWdyGMWy0ykU4AXSGpbenxyZuP2MahnT(jyqUg8GztcfrIwQubdY5d1lEZvRj6lljAYMiQJ5da5oL8moYs7dYQ1e9LLenzte1X8bGCNsEgpzCF6ydTFaPJf734sZtGJMw)emixZfkQns4vkmFai3jAdDlqzytlFMPsfmRf7OF66XAj6n5R36P5Q1e9LLenzte1X8bGCNsEgtc)aWy0ycdXxw24sZtGJMw)emixZfkQns4vkmFai3jAdDlqzytlFMPsfmRf7OF66XAj6n5RH6P5Q1e9LLenzte1X8bGCNsEg)29iN)Q1e9LLenzte1X8bGCNsEglOg7jode04sZtGJMw)emixZfkQTgiWrtRbp2xDcjpHObpy2KqLkyqof7r8MfrcVsH5da5orBOBbkdBA5zweywl2r)01J1s0BYxd1t1AI(YsIMSjI6y(aqUtjpJfuJ9eNbcACP5jWrtRFcgKR5cfrcVsH5da5orBOBbkdBA5zweywl2r)01J1s0BYxd1tJB6ha4cDmeftyu8m34M(baUqhBP5rcVsH5da5orBOBbkdBA5zwes0Qbpy2KWtCrTbgKZhQxCQurpGDeux)29iNFSWUHCrniYyklZqQJS0(GudEWSjP5Q1e9LLenzte1X8bGCNsEgBbdclXaSb04sZtGJMw)emixZfkQns4vkmFai3jAdDlqzytlFMPsfmRf7OF66XAj6n5ZCpnxTMOVSKOjBIOoMpaK7uYZybfJz9Ufq8gxAEcC006NGb5AlZqsLAKLwU11O34Y4iyrw6pi01Gj7ZxpI8bGCx39r5D6WOtXE1JOg4J6PRJaUR8M0phb1TvRj6lljAYMiQJ5da5oL8mwqXywHX7ACP5jWrtRFcgKRTmdjvQrwA5wxJEJlJJGfzP)GqxdMSpF9iYhaYDD3hL3PdJof7vpIAGpQNUoc4UYBs)Ceu3wTMOVSKOjBIOoMpaK7uYZydDlqzytBJlnpboAADWbXvDcbtGLhbSP9anxOis4vkmFai3jAdDlqzytlF9QAnrFzjrt2erDmFai3PKNXSKOgoKoVAnrFzjrt2erDmFai3PKNXGbztembfZqJlnVy3aqoHhQOsvGJMwdESV6esEcrZfkc9a2rqD9B3JC(Xc7gYf5J6PRdgczIGRFocQBRwt0xws0KnruhZhaYDk5zCeWr62ebtqXm04sZl2naKt4HQQ1e9LLenzte1X8bGCNsEglOymR3TaIxTMOVSKOjBIOoMpaK7uYZybfJzfgVRAnrFzjrt2erDmFai3PKNXGbztembfZq1AI(YsIMSjI6y(aqUtjpJJaos3MiyckMHQ1e9LLenzte1X8bGCNsEgBOBbkdBARwt0xws0KnruhZhaYDk5zm6n6mqtyaosx1AI(YsIMSjI6y(aqUtjpJ3GWN2nrWqVrNbAsItcFuAsVHkPlDPea]] )


end
