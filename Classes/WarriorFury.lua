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


    spec:RegisterPack( "Fury", 20210320, [[dWe36aqibHhbjSjc5teQAusP6usPSkcvGxHk1SeKUfsWUi5xuOggs0XeOLbj5zcIMMGkUMuL2gHk6BcQ04euvNdsQSobuMhsO7Hk2hQKdkG0cPqEOaIjsOsDrPkYgfqL(iKuKrcjfoPaQALsjZuqvUPaQyNcWqjuHwQuf1tHQPsOCviPO2kKu6ReQKXcjvTxI(lugmOdRyXe8yHMmLUSQnJuFgIrlvoTsRMqf0RLQA2K62u0Uf9BugUuCCirlh45iMovxhvTDi13PGXlvHZlOmFK0(LSmOumjUD8ldavuIQGugsurPIskdz42BiL4EynxI3mX(dYL45yEjEGlpimjEZeMMnwPysCcJheVeVZ9gsGzSXiR3XlOImtJjRjVE8LLrWq7gtwZOXsCb(v7b(ukiXTJFzaOIsufKYqIkkvusjQc3qg(s8H37yajo(Agif04cgOGy3A6lGrK4DR1(ukiXTNeL4bU8GWkO4AaGLbQwbodi2vqurzOfevuIQGvRQvG0njYjbw1IcfmqT2BlO4iVP51QQffkO4EjJG(2cAYqFZNEbnUGOghW2ybdVpnfmoADbBpzEbZF7TfKMbk4MuazmFbJS0Fp82uvlkuWahg6BlOr6XEIZaMfCsBbf3GbHLfSNzdOGJad9lOrAgZ6DlG4f0zfCnBam0VG0GJs(NXWkiJUGGhzMMpTJVSKuW2jRjPGagpsNoScEuYp62uvlkuWa1AVTGgnURFbX7y8EbDwbBapYmfgVGbQ4y4PQwuOGbQ1EBbrTB0zGWkypZt6k4iWq)cs2erFk4da5EbfxDlqBytRQArHcgOw7Tfe1m5fmW73KOQwuOGIz4t)csZafuC1TaTHnTfu40mWlO(OVUGHmCvvlkuWE(Mm03wWEIqEgprvTOqbf3Su8Eb5jVG47rUa4t)dk4sxW1fpPGJg8Xgwb5Bky7I7pEN50)G2uvlkuq878nfKE6)csok5FgpPG0mqbXxK8EbznppqjX1lXjsXK4Knr0hZhaYDPyYackftI)Ce03knsIhbRFWosCaFEAga5kdRwJXOX8UJjCa5G(hOok53MMBlOOckWttRmSAngJgZ7oMWbKd6FGcCZztsbPybrIwj(e9LLsCWGSjcMGMzq6YaqLumj(ZrqFR0ijEeS(b7iXb85PzaKRmSAngJgZ7oMWbKd6FG6OKFBAUTGIkOapnTYWQ1ymAmV7ychqoO)bkWnNnjfKIfejAL4t0xwkXbdYMiycAMbPldiKsXK4phb9TsJK4rW6hSJeN0CTgZhaYDIYq3c0g20wqofmybfvqKOvbU5SjPGCkiLfuubBVG(OF6kZHqMi4QNJG(2csLAbJm0pN0vOF6DHbkyBfuubrpGDe0x9E8iVFSMUH8ckQGTxqWG8cYvbrDuwqQulyikyKX0wMHufzP9MPcCZztsbBtIprFzPepoz8AmbEAAjUapnnwoMxIlOh7jodykDzaHJumj(ZrqFR0ijEeS(b7iXf4PPvpbdYvGBoBskixfejAlO4GcIkvVfuubjnxRX8bGCNOm0TaTHnTfKRcguIprFzPexqp2tCgWu6Ya6vkMe)5iOVvAKepcw)GDK4c800QNGb5k(MckQGOhWoc6REpEK3pwt3qUeFI(YsjEKL2BMsxgG4ukMe)5iOVvAKepcw)GDK42lWttRi7rUa4t)duwMHSGIky7fK0CTgZhaYDIYq3c0g20wqUkyWcsLAbbZAXo6NUASwIAZcYvbd2BbBtIprFzPeNSh5cGp9pq6YacxPys8NJG(wPrs8iy9d2rI3Ebf4PPvGh7RpHKNqu8nfKk1ckWttRmVjdeggJgtZhxlMf8XKO4BkyBfKk1c2Ebf4PPvpbdYvGBoBskiflis0wqQuliyqEb5QGOoklyBs8j6llL4GXSzqU0Lbe(sXK4t0xwkXJS0EZuI)Ce03kns6YaqDsXK4phb9TsJK4rW6hSJexGNMw9emixX3uqrfS9csAUwJ5da5orzOBbAdBAlixfmybPsTGGzTyh9txnwlrTzb5QGHBVfSnj(e9LLs8jJ7thBO9diDSyFPldiiLsXK4phb9TsJK4rW6hSJexGNMw9emixX3uqrfS9csAUwJ5da5orzOBbAdBAlixfmybPsTGGzTyh9txnwlrTzb5QGHtVfSnj(e9LLsCsZhagJgtyi(YsPldiyqPys8j6llL4VhpY7xI)Ce03kns6YacIkPys8NJG(wPrs8iy9d2rIlWttREcgKR4BkOOc2Ebdrbf4PPvGh7RpHKNquGBoBskivQfemiVGuSG9szbBRGIkiP5AnMpaK7eLHUfOnSPTGCkyWckQGGzTyh9txnwlrTzb5QGHtVs8j6llL4c6XEIZaMsxgqWqkftI)Ce03knsIhbRFWosCbEAA1tWGCfFtbfvqsZ1AmFai3jkdDlqBytBb5uWGfuubbZAXo6NUASwIAZcYvbdNEL4B6ha4BCSLwItAUwJ5da5orzOBbAdBA5eues0Qa3C2KWHsrTdgKZfQJsQurpGDe0x9E8iVFSMUHCrHiYyAlZqQIS0EZubU5SjPnj(e9LLsCb9ypXzatj(M(ba(ghdrZegTepO0LbemCKIjXFoc6BLgjXJG1pyhjUapnT6jyqUIVPGIky7fK0CTgZhaYDIYq3c0g20wqUkyWcsLAbbZAXo6NUASwIAZcYvbd2BbBtIprFzPe3cgewIbydq6Yac2Rumj(ZrqFR0ijEeS(b7iXf4PPvpbdYvwMHSGuPwWilT8RRqVXLXtWIS0VzJRat2VGCvWElOOc6da5UQ7J27unrVGuSGHS3ckQGHOG(OF6QiG)Apm1ZrqFReFI(YsjUGMXSE3ciU0LbeuCkftI)Ce03knsIhbRFWosCbEAA1tWGCLLzilivQfmYsl)6k0BCz8eSil9B24kWK9lixfS3ckQG(aqUR6(O9ovt0liflyi7TGIkyikOp6NUkc4V2dt9Ce03kXNOVSuIlOzmR3TaIlDzabdxPys8NJG(wPrs8iy9d2rIlWttRmpiU6tiycS8iGnThO4BkOOcsAUwJ5da5orzOBbAdBAlixfmKs8j6llL4g6wG2WMwPldiy4lftIprFzPeNLe9WJ05s8NJG(wPrsxgqquNumj(ZrqFR0ijEeS(b7iXJDda5KcYPGOQGuPwqbEAAf4X(6ti5jefFtbfvq0dyhb9vVhpY7hRPBiVGIkOp6NUYCiKjcU65iOVvIprFzPehmiBIGjOzgKUmaurPumj(ZrqFR0ijEeS(b7iXJDda5KcYPGOsIprFzPehmiBIGjOzgKUmaufukMeFI(YsjUGMXSE3ciUe)5iOVvAK0LbGkujftIprFzPexqZywVBbexI)Ce03kns6YaqviLIjXNOVSuIdgKnrWe0mds8NJG(wPrsxgaQchPys8j6llL4GbztembnZGe)5iOVvAK0LbGQELIjXNOVSuIBOBbAdBAL4phb9TsJKUmaujoLIjXNOVSuIJEJodeggGN0jXFoc6BLgjDzaOkCLIjXNOVSuIVMnpTBIGHEJodeMe)5iOVvAK0LUe3KH(MpDPyYackftIprFzPeV7a2gX0FAK4phb9TsJKU0L42tp8AxkMmGGsXK4phb9TsJK4rW6hSJe3xZxqUky4xqQulOp6NUYY4f0hZxZREoc6BlivQfCI(I(ypV5Esb5QGblivQfmYq)CsxH(P3fgOGuPwWquqaFEAga5kYIK3Xy0yody(0VfR)Mie1rj)20CBbPsTGrgtBzgsf4X(6ti5jef4MZMKcYvbrIwj(e9LLs8y3aqUe3EseSn(YsjEG0naKxWLUGgU4bVGAwIuWMH4fKXdkiR55bHwqgOGgEbTSu8EbZFBb9UxqwZZdkyKzkWkinduq8fjVxW2twsbu7tVlmqBkPldavsXK4t0xwkXB4nnVwI)Ce03kns6YacPumj(ZrqFR0ijoRrItUlXNOVSuIJEa7iOVeh9O5Ve3h9txzoeYebx9Ce03wqrf0haYDv3hT3PAIEbPybdzVfKk1c6da5UQ7J27unrVGuSGOIYcsLAb9bGCx19r7DQMOxqUky4tzbfvWid9ZjDf6NExyajo6bGLJ5L4VhpY7hRPBix6YachPys8NJG(wPrs8j6llL4cAgZ6DlG4sC9MhlAL4bPuIhbRFWosCFnFbPybd)ckQGt0x0h75n3tkiNcgSGIkiGppndGCfzrY7ymAmNbmF63I1FteI6OKFBAUTGIky7fmefmYq)CsxH(P3fgOGuPwWiJPTmdPc8yF9jK8eIcCZztsbPiNcIeTfSnjU9KiyB8LLs8EYKxp(jfCZ13rxqJ0mM17waXli5OK)z8fKMbkizte9PGpaK7fK7cIVi5DL0Lb0Rumj(ZrqFR0ij(e9LLsCWJ91NqYtisC9MhlAL4bPuIhbRFWosCFnFbPybd)ckQGt0x0h75n3tkiNcgSGIkyKH(5KUc9tVlmqbfvqaFEAga5kYIK3Xy0yody(0VfR)Mie1rj)20CBbfvWgWrRe0mM17waXL42tIGTXxwkX7jtE94NuWnxFhDb75h7RpHKNqki5OK)z8fKMbkizte9PGpaK7fK7cIAF6DHbki3feFrY7kPldqCkftI)Ce03knsIprFzPeV7a2gX0FAK46npw0kXdsPepcw)GDK4(A(csXc2BbfvWj6l6J98M7jfKtbdwqrfmefmYq)CsxH(P3fgOGIkiGppndGCfzrY7ymAmNbmF63I1FteI6OKFBAUTGIkyd4OvcAgZ6DlG4fuubJmM2YmKQy3aqUcCZztsbPybPu1Re3EseSn(YsjEpzYRh)KcU567OliQXbSnwWW7ttb5QGbs3aqEbjhL8pJVG0mqbjBIOpf8bGCVGCxWKLua1(07cduqUli(IK3vsxgq4kftI)Ce03knsIprFzPep2naKlX1BESOvIhKsjEeS(b7iX918fKIfS3ckQGt0x0h75n3tkiNcgSGIkyikyKH(5KUc9tVlmqbfvqaFEAga5kYIK3Xy0yody(0VfR)Mie1rj)20CBbfvWgWrR6oGTrm9NgjU9KiyB8LLs8EYKxp(jfCZ13rxquJdyBSGH3NMcYvbdKUbG8csok5FgFbPzGcs2erFk4da5Eb5UGjlPaQ9P3fgOGCxq8fjVRKUmGWxkMeFI(YsjEdZxwkXFoc6BLgjDzaOoPys8NJG(wPrs8iy9d2rIhzmTLzivGh7RpHKNquGBoBskiflyilOOc6J(PRap2xFcbBeM0Ys1ZrqFReFI(YsjoymBgKlDzabPukMe)5iOVvAKepcw)GDK4c800kWJ91NqYtiklZqwqrf0EbEAAfzpYfaF6FGYYmKfKk1csViDog4MZMKcsXc2lLs8j6llL4rwIs(dyacMWK5bsxgqWGsXK4phb9TsJK4rW6hSJepefeWNNMbqUISi5DmgnMZaMp9BX6VjcrDuYVnn3wqrfejAvGBoBskiNcszbfvW2ly7fuGNMwjOzmRMN4k(McsLAb9r)0vtICaM5KdYnF6QNJG(2csLAbbZAXo6NUASwIAZcYvbdszbBRGuPwqFai3v(AEmNHz3xqUkyqkPSGuPwq0dyhb9vVhpY7hRPBiVGuPwqFai3v(AEmNHz3xqkwWG9wqrfemRf7OF6QXAjQnlixfmiLfSTckQGTxqsZ1AmFai3jkdDlqBytBb5uWGfKk1ckWttRm)4yr9h0hO4BkyBs8j6llL4Gh7RpHKNqKUmGGOskMe)5iOVvAKepcw)GDK4a(80maYvKfjVJXOXCgW8PFlw)nriQJs(TP52ckQGirRcCZztsbfvWgWrJHeTQGkWy2miVGIky7fS9ckWttRe0mMvZtCfFtbPsTG(OF6QjroaZCYb5MpD1ZrqFBbPsTGGzTyh9txnwlrTzb5QGbPSGTvqQulOpaK7kFnpMZWS7lixfmiLuwqQuli6bSJG(Q3Jh59J10nKxqQulOpaK7kFnpMZWS7liflyWElOOccM1ID0pD1yTe1MfKRcgKYc2wbfvW2liP5AnMpaK7eLHUfOnSPTGCkyWcsLAbf4PPvMFCSO(d6du8nfSnj(e9LLsCWJ91NqYtisCEYXy00yirRmGGsxgqWqkftI)Ce03knsIhbRFWosC9rFDb5QGHuCwqrfS9csAUwJ5da5orzOBbAdBAlixfmybfvWquqbEAAL5hhlQ)G(afFtbPsTGGzTyh9txnwlrTzbPybrI2ckQGHOGc800kZpowu)b9bk(Mc2MeFI(YsjUHUfOnSPv6YacgosXK4t0xwkX5jhB9BsK4phb9TsJKUmGG9kftIprFzPexqZywmAEqys8NJG(wPrsxgqqXPumj(ZrqFR0ijEeS(b7iXf4PPvGh7RpHKNqu8ns8j6llL4chqoO)MisxgqWWvkMe)5iOVvAKepcw)GDK4c800kWJ91NqYtiklZqwqrf0EbEAAfzpYfaF6FGYYmKs8j6llL46fPZjyId5TiMpDPldiy4lftIprFzPeNEbxqZywj(ZrqFR0iPldiiQtkMeFI(Ysj(KXtCWOXIJwlXFoc6BLgjDzaOIsPys8NJG(wPrs8iy9d2rIlWttRap2xFcjpHOSmdzbfvq7f4PPvK9ixa8P)bklZqwqrfuGNMw9emixX3iXNOVSuIlmiymAmhSX(ePldavbLIjXFoc6BLgjXNOVSuId4tSj6llX0lXL46L4y5yEjozte9X8bGCx6sxI3aEKzkmUumzabLIjXNOVSuIlmURpgPJX7s8NJG(wPrsxgaQKIjXFoc6BLgjXJG1pyhjEikiGppndGCfzrY7ymAmNbmF63I1FteI6OKFBAUvIprFzPeh8yF9jK8eI0LU0L4OpGSSugaQOevbPmKbPuIBya5MiejU4kq75ac8bGAkWkybfR7fCnByaVG0mqbfpzte9X8bGCx8feCuYVGBliHz(co8oZC8BlySBsKtuvRWBZxWqgyfmqyj6d8BlO4Jm0pN0vOE1ZrqFR4lOZkO4Jm0pN0vOEXxW2d2J2uvRQL4kq75ac8bGAkWkybfR7fCnByaVG0mqbfV90dV2fFbbhL8l42csyMVGdVZmh)2cg7Me5ev1k828fmKbwbdewI(a)2ckEF0pDfQx8f0zfu8(OF6kuV65iOVv8fS9G9Onv1k828fS3aRGbclrFGFBbfFKH(5KUc1REoc6BfFbDwbfFKH(5KUc1l(c2EWE0MQAfEB(ckodScgiSe9b(Tfu8rg6Nt6kuV65iOVv8f0zfu8rg6Nt6kuV4ly7b7rBQQv4T5ly4gyfmqyj6d8BlO4Jm0pN0vOE1ZrqFR4lOZkO4Jm0pN0vOEXxW2d2J2uvRQvG3SHb8Bly4uWj6lllOEjorvTK4nag9QVehfOOGbU8GWkO4AaGLbQwOaffmWzaXUcIkkdTGOIsufSAvTqbkkyG0njYjbw1cfOOGuOGbQ1EBbfh5nnVwvTqbkkifkO4EjJG(2cAYqFZNEbnUGOghW2ybdVpnfmoADbBpzEbZF7TfKMbk4MuazmFbJS0Fp82uvluGIcsHcg4WqFBbnsp2tCgWSGtAlO4gmiSSG9mBafCeyOFbnsZywVBbeVGoRGRzdGH(fKgCuY)mgwbz0fe8iZ08PD8LLKc2oznjfeW4r60HvWJs(r3MQAHcuuqkuWa1AVTGgnURFbX7y8EbDwbBapYmfgVGbQ4y4PQwOaffKcfmqT2BliQDJodewb7zEsxbhbg6xqYMi6tbFai3lO4QBbAdBAvvluGIcsHcgOw7Tfe1m5fmW73KOQwOaffKcfumdF6xqAgOGIRUfOnSPTGcNMbEb1h91fmKHRQAHcuuqkuWE(Mm03wWEIqEgprvTqbkkifkO4MLI3lip5feFpYfaF6Fqbx6cUU4jfC0Gp2WkiFtbBxC)X7mN(h0MQAHcuuqkuq878nfKE6)csok5FgpPG0mqbXxK8EbznppqvTQwOaffSN6XJ8(Tfu40mWlyKzkmEbfoYMevbd0y8noPGjlPq3amP51fCI(YssbzPomv1AI(YsIQb8iZuyCU5ySW4U(yKogVxTMOVSKOAapYmfgNBogdESV(esEcj0LMtia85PzaKRilsEhJrJ5mG5t)wS(BIquhL8BtZTvRQfkqrb7PE8iVFBbp6dcRG(A(c6DVGt0zGcUKcoONvpc6RQwOOGbs3aqEbx6cA4Ih8cQzjsbBgIxqgpOGSMNheAbzGcA4f0YsX7fm)Tf07EbznppOGrMPaRG0mqbXxK8EbBpzjfqTp9UWaTPQwt0xws4e7gaYdDP54R55k8Ps1h9txzz8c6J5R5vphb9TuPorFrFSN3CpHRGuPgzOFoPRq)07cdqLAia85PzaKRilsEhJrJ5mG5t)wS(BIquhL8BtZTuPgzmTLzivGh7RpHKNquGBoBs4cjARwt0xws4MJXn8MMxxTMOVSKWnhJrpGDe0p0CmpN3Jh59J10nKhk6rZFo(OF6kZHqMi4I8bGCx19r7DQMOtXq2lvQ(aqUR6(O9ovt0PiQOKkvFai3vDF0ENQj6Cf(ukkYq)CsxH(P3fgOAHcuuqX6wsbxsbnzexhwbDwbBah9tVGrgtBzgssbPbmZck8nrk4eJR9PpADyfKNCBbT8GnrkOjd9nF6QQfkqrbNOVSKWnhJb8j2e9LLy6L4HMJ55yYqFZNEOlnhtg6B(0v2L4tgpx9wTqbkk4e9LLeU5yC3bSnIP)0e6sZPDWSwSJ(PRmzOV5txzxIpz8CHQEfbM1ID0pDLjd9nF6Qn5kC6TTQfkqrbNOVSKWnhJjhL8pJp0LMZe9f9XEEZ9eobffzOFoPRq)07cdOEoc6Bfb4ZtZaixrwK8ogJgZzaZN(Ty93eHOok53MMBdnhZZXiXe1Zp2pWe0mM17waXdmWJ91NqYtivluuWEYKxp(jfCZ13rxqJ0mM17waXli5OK)z8fKMbkizte9PGpaK7fK7cIVi5Dv1AI(Ysc3CmwqZywVBbepu9MhlA5eKYqxAo(AEkg(IMOVOp2ZBUNWjOiaFEAga5kYIK3Xy0yody(0VfR)Mie1rj)20CRO2drKH(5KUc9tVlmavQrgtBzgsf4X(6ti5jef4MZMekYbjABRAHIc2tM86XpPGBU(o6c2Zp2xFcjpHuqYrj)Z4linduqYMi6tbFai3li3fe1(07cduqUli(IK3vvRj6lljCZXyWJ91NqYtiHQ38yrlNGug6sZXxZtXWx0e9f9XEEZ9eobffzOFoPRq)07cdOEoc6Bfb4ZtZaixrwK8ogJgZzaZN(Ty93eHOok53MMBf1aoALGMXSE3ciE1cfOOGt0xws4MJXKJs(NXh6sZzI(I(ypV5EcNGIcrKH(5KUc9tVlmG65iOVveGppndGCfzrY7ymAmNbmF63I1FteI6OKFBAUn0CmphJetuG0naKhycAgZ6DlG4bw3bSnIf7gaYRwOOG9KjVE8tk4MRVJUGOghW2ybdVpnfKRcgiDda5fKCuY)m(csZafKSjI(uWhaY9cYDbtwsbu7tVlmqb5UG4lsExvTMOVSKWnhJ7oGTrm9NMq1BESOLtqkdDP54R5PyVIMOVOp2ZBUNWjOOqezOFoPRq)07cdOEoc6Bfb4ZtZaixrwK8ogJgZzaZN(Ty93eHOok53MMBf1aoALGMXSE3ciUOiJPTmdPk2naKRa3C2Kqrkv9wTqrb7jtE94NuWnxFhDbrnoGTXcgEFAkixfmq6gaYli5OK)z8fKMbkizte9PGpaK7fK7cMSKcO2NExyGcYDbXxK8UQAnrFzjHBogh7gaYdvV5XIwobPm0LMJVMNI9kAI(I(ypV5EcNGIcrKH(5KUc9tVlmG65iOVveGppndGCfzrY7ymAmNbmF63I1FteI6OKFBAUvud4OvDhW2iM(tt1AI(Ysc3CmUH5llRwt0xws4MJXGXSzqEOlnNiJPTmdPc8yF9jK8eIcCZztcfdPiF0pDf4X(6tiyJWKwwQEoc6BRwt0xws4MJXrwIs(dyacMWK5bHU0Ce4PPvGh7RpHKNquwMHuK9c800kYEKla(0)aLLziPsLEr6CmWnNnjuSxkRwt0xws4MJXGh7RpHKNqcDP5ecaFEAga5kYIK3Xy0yody(0VfR)Mie1rj)20CRiKOvbU5SjHdLIAVDbEAALGMXSAEIR4BOs1h9txnjYbyMtoi38PREoc6BPsfmRf7OF6QXAjQn5kiLTrLQpaK7kFnpMZWS75kiLusLk6bSJG(Q3Jh59J10nKtLQpaK7kFnpMZWS7PyWEfbM1ID0pD1yTe1MCfKY2e1oP5AnMpaK7eLHUfOnSPLtqQuf4PPvMFCSO(d6du8nTvTMOVSKWnhJbp2xFcjpHekp5ymAAmKOLtWqxAoa(80maYvKfjVJXOXCgW8PFlw)nriQJs(TP5wrirRcCZztIOgWrJHeTQGkWy2mixu7TlWttRe0mMvZtCfFdvQ(OF6QjroaZCYb5MpD1ZrqFlvQGzTyh9txnwlrTjxbPSnQu9bGCx5R5XCgMDpxbPKsQurpGDe0x9E8iVFSMUHCQu9bGCx5R5XCgMDpfd2RiWSwSJ(PRgRLO2KRGu2MO2jnxRX8bGCNOm0TaTHnTCcsLQapnTY8JJf1FqFGIVPTQ1e9LLeU5ySHUfOnSPn0LMJ(OVMRqkof1oP5AnMpaK7eLHUfOnSPLRGIcHapnTY8JJf1FqFGIVHkvWSwSJ(PRgRLO2KIirROqiWttRm)4yr9h0hO4BARAnrFzjHBogZto263KuTMOVSKWnhJf0mMfJMhew1AI(Ysc3Cmw4aYb93ej0LMJapnTc8yF9jK8eIIVPAnrFzjHBogRxKoNGjoK3Iy(0dDP5iWttRap2xFcjpHOSmdPi7f4PPvK9ixa8P)bklZqwTMOVSKWnhJPxWf0mMTAnrFzjHBogpz8ehmAS4O1vRj6lljCZXyHbbJrJ5Gn2Ne6sZrGNMwbESV(esEcrzzgsr2lWttRi7rUa4t)duwMHuKapnT6jyqUIVPAnrFzjHBogd4tSj6llX0lXdnhZZHSjI(y(aqUxTQwt0xwsuMm038PZP7a2gX0FAQwvRj6lljkYMi6J5da5o3CmgmiBIGjOzgcDP5a4ZtZaixzy1AmgnM3DmHdih0)a1rj)20CRibEAALHvRXy0yE3XeoGCq)duGBoBsOis0wTMOVSKOiBIOpMpaK7CZX4iGN0TjcMGMzi0LMdGppndGCLHvRXy0yE3XeoGCq)duhL8BtZTIe4PPvgwTgJrJ5Dht4aYb9pqbU5SjHIirB1AI(YsIISjI(y(aqUZnhJJtgVgtGNMo0Cmphb9ypXzaZqxAoKMR1y(aqUtug6wG2WMwobfHeTkWnNnjCOuu7(OF6kZHqMi4QNJG(wQuJm0pN0vOF6DHbuphb9TTjc9a2rqF17XJ8(XA6gYf1oyqoxOokPsnergtBzgsvKL2BMkWnNnjTvTMOVSKOiBIOpMpaK7CZXyb9ypXzaZqxAoc800QNGb5kWnNnjCHeTIdqLQxrKMR1y(aqUtug6wG2WMwUcwTMOVSKOiBIOpMpaK7CZX4ilT3mdDP5iWttREcgKR4BeHEa7iOV694rE)ynDd5vRj6lljkYMi6J5da5o3CmMSh5cGp9pi0LMJ9c800kYEKla(0)aLLzif1oP5AnMpaK7eLHUfOnSPLRGuPcM1ID0pD1yTe1MCfS32Qwt0xwsuKnr0hZhaYDU5ymymBgKh6sZPDbEAAf4X(6ti5jefFdvQc800kZBYaHHXOX08X1IzbFmjk(M2OsTDbEAA1tWGCf4MZMekIeTuPcgKZfQJY2Qwt0xwsuKnr0hZhaYDU5yCKL2BMvRj6lljkYMi6J5da5o3CmEY4(0XgA)ashl2p0LMJapnT6jyqUIVru7KMR1y(aqUtug6wG2WMwUcsLkywl2r)0vJ1suBYv42BBvRj6lljkYMi6J5da5o3CmM08bGXOXegIVSm0LMJapnT6jyqUIVru7KMR1y(aqUtug6wG2WMwUcsLkywl2r)0vJ1suBYv40BBvRj6lljkYMi6J5da5o3Cm(94rE)vRj6lljkYMi6J5da5o3Cmwqp2tCgWm0LMJapnT6jyqUIVru7HqGNMwbESV(esEcrbU5SjHkvWGCk2lLTjI0CTgZhaYDIYq3c0g20YjOiWSwSJ(PRgRLO2KRWP3Q1e9LLefzte9X8bGCNBoglOh7jodyg6sZrGNMw9emixX3iI0CTgZhaYDIYq3c0g20YjOiWSwSJ(PRgRLO2KRWP3q30paW34yiAMWO5em0n9da8no2sZH0CTgZhaYDIYq3c0g20YjOiKOvbU5SjHdLIAhmiNluhLuPIEa7iOV694rE)ynDd5IcrKX0wMHufzP9MPcCZztsBvRj6lljkYMi6J5da5o3Cm2cgewIbydi0LMJapnT6jyqUIVru7KMR1y(aqUtug6wG2WMwUcsLkywl2r)0vJ1suBYvWEBRAnrFzjrr2erFmFai35MJXcAgZ6DlG4HU0Ce4PPvpbdYvwMHKk1ilT8RRqVXLXtWIS0VzJRat2NREf5da5UQ7J27unrNIHSxrHWh9txfb8x7HPEoc6BRwt0xwsuKnr0hZhaYDU5ySGMXScJ3f6sZrGNMw9emixzzgsQuJS0YVUc9gxgpblYs)MnUcmzFU6vKpaK7QUpAVt1eDkgYEffcF0pDveWFThM65iOVTAnrFzjrr2erFmFai35MJXg6wG2WM2qxAoc800kZdIR(ecMalpcyt7bk(grKMR1y(aqUtug6wG2WMwUcz1AI(YsIISjI(y(aqUZnhJzjrp8iDE1AI(YsIISjI(y(aqUZnhJbdYMiycAMHqxAoXUbGCchurLQapnTc8yF9jK8eIIVre6bSJG(Q3Jh59J10nKlYh9txzoeYebx9Ce03wTMOVSKOiBIOpMpaK7CZX4iGN0TjcMGMzi0LMtSBaiNWbvvRj6lljkYMi6J5da5o3CmwqZywVBbeVAnrFzjrr2erFmFai35MJXcAgZkmEx1AI(YsIISjI(y(aqUZnhJbdYMiycAMHQ1e9LLefzte9X8bGCNBoghb8KUnrWe0mdvRj6lljkYMi6J5da5o3Cm2q3c0g20wTMOVSKOiBIOpMpaK7CZXy0B0zGWWa8KUQ1e9LLefzte9X8bGCNBogVMnpTBIGHEJodeMeN08OmGWfvsx6sja]] )


end
