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
            max_stack = PTR and 3 or 4,      
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


    spec:RegisterPack( "Fury", 20201105, [[dKetNaqicYJuQ0MqcJsPItPuQxHuAwuIUfLk2ff)sPQHrPQJHk1YOeEMsjnnLs4AeuTnkvQVHuiJtPeDouj16qkuMhsb3dPAFeuoiQKSqKupKsLWefjLUiLkjBePq1ifjbNuKKALusZuKuCtrsODIKmursYsfjrpvjtfj6QuQKARuQe9vuj0Er8xjgmjhwyXs6XenzQ6YGntQptOrtGtd1QrLOxJkMnvUnQA3s9BidxehhvcwUINRY0v11f12vk(Ui14fjvNxKy9ifnFkL9JYeUjusw(4bcvwyVf2Zn32lCJ9BPW5AUTGS(usaYkjKCcrGS6GhilA88KczLeP4qHNqjzDO8ibYsW)jhn2(9I4xqUAKi(9hMp7IhJA5e6F)H5L7jRAg7(uDtQKLpEGqLf2BH9CZT9c3y)wkCUMBUjRi)cqdzTW82fm1EMIRgPam)Jh0rwcWEp0Kkz5Htsw7Yu045jfMIlgZGrdZ6UmfvOnaFfgMs4wYuwyVf2ZSYSUltzxiiAr4OXyw3LPSdtXvEp4zQuvMNhCgM1Dzk7WuPw8fvh4zkE0gGh6NP2ZuPcWGWsMk1arctjdNJP2Prpt1a4bptPrdtHB7ig8atjr9dP(VTHzDxMYomvQiAd4zkQDHhUhn8mv0EMk1oHiQzQujkgMkQOnatrTdH8Va8Cpt9iMcZNmOnatPhGlKHwMctH0m1asepp0(4XO(yQDom)XudklkWLctbCHC422WSUltzhMIR8EWZuuh)7aMAjaLFM6rmvYaseFnEMIRsvPgdZ6UmLDykUY7bptzxILpAsHPsL5tatfv0gGPoCl6a78XicptXffGhxAC7nmR7Yu2HP4kVh8mLD9bmvQ(b(ZWSUltzhMIY0qWHP0OHP4IcWJlnU9mvf0ObykhSbCm1wPrgYYHV)iuswhUfDq5JreEcLeQ4MqjzfYhJAY6WGiuhi4adzbDuDGNqn5juzbHsYc6O6apHAYso4hgCqw7Wu1SwBgqYXb31WDMCctzZgtvZATHh4rtkfKU4YsSV4hi4ptoHP2MPSzJP2HPQzT2a9eIGza(a3htrdmLO0Zu2SXuticmLWykU2EMABYkKpg1K1e8jHiqEcvBLqjzfYhJAYcsDqMFGSGoQoWtOM8eQ2ccLKf0r1bEc1KLCWpm4GSsgytru6nCBMGpjebYkKpg1Kv1fE4E0WtEcvcNqjzbDuDGNqnzjh8ddoiRAwRnqpHiyYjKviFmQjl)eIOUmOyipHk7MqjzbDuDGNqnzjh8ddoiRAwRnqpHiy8O0ntzZgtf0eg8dgjY5l3dGRia9LQdH8MjAomLWykUjRq(yutwvhc5Fb45EYtOIgrOKSc5JrnzH6ZfzrbpzbDuDGNqn5juTLekjlOJQd8eQjl5GFyWbzjfeJiCmfDMYcYkKpg1K1eI4wSuDO0KNqfxtOKSc5JrnzvDiK)fGN7jlOJQd8eQjpHkUTNqjzfYhJAYAcrClwQouAYc6O6apHAYtOIBUjuswH8XOMSslapU042twqhvh4jutEYtw8Onap0pHscvCtOKSc5JrnzjagewwCqKqwqhvh4jutEYtwEqhz3tOKqf3ekjRq(yutwsbXicKf0r1bEc1KNqLfekjRq(yutwjzEEWrwqhvh4jutEcvBLqjzbDuDGNqnzjh8ddoiRDyQjW(cSb63WJ2a8q)gp((OLatjmMYcHZuuWutG9fyd0VHhTb4H(n4MPegtTfcNP2MSc5JrnzjagewwCqKqEcvBbHsYc6O6apHAYso4hgCqw1SwBeZX4Xrxq6sqtyqVatoHPSzJP2HPeIPG7GwcgjQ9qFGV4WAqJgjy4dUenmffm1hJi8MhZdLhv8yGPOb6mLDBptTnzfYhJAYkb9yutEcvcNqjzbDuDGNqnzjh8ddoiljc58O0TzajhhCxd3zgGpW9Xu0atTvMIcM6dh0VzajhhCxjQr7rTb6O6apzfYhJAYAc(KqeipHk7MqjzbDuDGNqnzjh8ddoiRDyQAwRndi54G7A4otoHPSzJPKiKZJs3MbKCCWDnCNza(a3htrdmf3m12mffm1om1eIatjmMAlTNPOGP2HPQzT2WdXxKoi2aJjNWuuWu1SwBGEcrWKtykB2yQlbCUYhJi8NjTa84sJBptrNP4MP2MPSzJP8O30OuhJYxzd0iEZa8bUpMABYkKpg1Kv1Hq(csxEbqbAGpfYtOIgrOKSGoQoWtOMSKd(HbhKLqmvnR1MbKCCWDnCNjNWuuWucXu1SwBomic1bcoWyYjKviFmQjRK8G1PGBXs1f3tEcvBjHsYc6O6apHAYso4hgCqwcXu1SwBgqYXb31WDMCctrbtjetvZAT5WGiuhi4aJjNqwH8XOMSgCsIdk4UCjHeipHkUMqjzbDuDGNqnzjh8ddoilHyQAwRndi54G7A4otoHPOGPeIPQzT2CyqeQdeCGXKtiRq(yutwPrJZVbWDzGd1rlbYtOIB7juswqhvh4jutwYb)WGdYsiMQM1AZasoo4UgUZKtykkykHyQAwRnhgeH6abhym5eYkKpg1KLgjZh4lbnHb)qPcbp5juXn3ekjlOJQd8eQjl5GFyWbzjetvZATzajhhCxd3zYjmffmLqmvnR1MddIqDGGdmMCczfYhJAYAGib3IfTl4HJ8eQ42ccLKf0r1bEc1KLCWpm4GSeIPQzT2mGKJdURH7m5eMIcMsiMQM1AZHbrOoqWbgtoHPOGP8O3irTe6FIh8fTl4HsnpTza(a3htrNPSNSc5JrnzjrTe6FIh8fTl4bYtOI7TsOKSGoQoWtOMSKd(HbhKvnR1MbKCCWDfnAKGjNqwH8XOMSEbqj3vuU9fnAKa5juX9wqOKSGoQoWtOMSKd(HbhKLqmvnR1MbKCCWDnCNjNWuuWu7WupMhkpQ4XatjmMIBUw4mLnBm1hJi8gbq4EbMe5Zu0atzH9m12KviFmQjlXCmEC0fKUe0eg0lG8eQ4w4ekjlOJQd8eQjl5GFyWbzjetvZATzajhhCxd3zYjKviFmQjlEGhnPuq6IllX(IFGG)ipHkUTBcLKf0r1bEc1KLCWpm4GSQzT2mGKJdURH7mEu6MPOGP8qnR1MddIqDGGdmgpkDtwH8XOMSKOMlKHbnxPgDdd5juXnnIqjzbDuDGNqnzjh8ddoilrP3maFG7JPOZu2ZuuWu7WucXuWDqlbJe1EOpWxCynOrJem8bxIgMIcMsiMcUdAjyQoeYxq6Ylakqd8Py4dUenmLnBmLeHCEu62iMJXJJUG0LGMWGEbMb4dCFmLWykUzkB2yQAwRnI5y84OliDjOjmOxGjNWu2SXu1SwBQoeYxq6Ylakqd8PyYjm12KviFmQjRbKCCWDnCh5juX9wsOKSGoQoWtOMSKd(HbhK1Laox5Jre(ZKwaECPXTNPegtXntrbt5GnGJPegtTv7MPOGPeIPQzT2WdXxKoi2aJjNqwH8XOMSslapU042tEcvCZ1ekjlOJQd8eQjRq(yutwXjyt0WvMGMOPirt4il5GFyWbz9yEO8OIhdmfnWuwyptzZgtjet5HAwRntqt0uKOjCfpuZATjNWu2SXu7WuFmIWBEmpuEujr(LTAptrdmLWzkkykpuZATrIAFw(4nqb3CkEOM1AtoHP2MPSzJP2HPeIP8qnR1gjQ9z5J3afCZP4HAwRn5eMIcMQM1AdpWJMukiDXLLyFXpqWFMCctzZgtLmWMIO0BSWiMJXJJUG0LGMWGEbmLnBmvYaBkIsVXcZasoo4UgUJPOGP2HPeIPG7GwcgEGhnPuq6IllX(IFGG)m8bxIgMIcMsiMcUdAjyKO2d9b(IdRbnAKGHp4s0WuBZuBtwDWdKvCc2enCLjOjAks0eoYtOYc7juswqhvh4jutwDWdK1e8j4wSe8jo8N9qrelgBqUVaTiUbYkKpg1K1e8j4wSe8jo8N9qrelgBqUVaTiUbYtOYcUjuswH8XOMSYhuWpWFKf0r1bEc1KNqLfwqOKSGoQoWtOMSKd(HbhKvnR1MbKCCWDnCNjNqwH8XOMSQoeYx05jfYtOYITsOKSGoQoWtOMSKd(HbhKvnR1MbKCCWDnCNjNqwH8XOMSQWCWWb3IKNqLfBbHsYc6O6apHAYso4hgCqw1SwBgqYXb31WDgpkDZuuWuEOM1AZHbrOoqWbgJhLUjRq(yutwoSOG)kCz2lYd9tEcvwiCcLKf0r1bEc1KLCWpm4GSQzT2mGKJdURH7mEu6MPOGP8qnR1MddIqDGGdmgpkDtwH8XOMSUeiMcsxQX9yutEcvwy3ekjlOJQd8eQjl5GFyWbzvZATzajhhCxd3z8O0ntrbt5HAwRnhgeH6abhymEu6MPOGP2HPc5J3afObEmCmLWykUzkB2yQk6oMABYkKpg1Kv0sm0Fj0pmNaKKd5juzbnIqjzbDuDGNqnzjh8ddoiRAwRndi54G7A4otoHSc5JrnzPXduDiKN8eQSyljuswqhvh4jutwYb)WGdYQM1AZasoo4UgUZKtiRq(yutwrlH7NWvKHZrEcvwW1ekjlOJQd8eQjl5GFyWbzvZATzajhhCxd3z8O0ntrbt5HAwRnhgeH6abhymEu6MPOGPQzT2a9eIGjNqwH8XOMSQHybPl)GLCoYtOAR2tOKSGoQoWtOMSc5Jrnzn5UeYhJ6IdFpz5W3x6GhiRd3IoO8Xicp5jpzLmGeXxJNqjHkUjuswH8XOMSQX)oOCcq5NSGoQoWtOM8eQSGqjzbDuDGNqnz1bpqwbnpbXexrJ6VG0LeuAyiRq(yutwbnpbXexrJ6VG0LeuAyipHQTsOKSc5JrnzLgno)ga3LbouhTeilOJQd8eQjpHQTGqjzfYhJAYIh4rtkfKU4YsSV4hi4pYc6O6apHAYtOs4ekjRq(yutwI5y84OliDjOjmOxazbDuDGNqn5juz3ekjRq(yutwdi54G7A4oYc6O6apHAYtEYtwBG5WOMqLf2BH9CBVf2twPJPXT4rwPA(e08GNP2cMkKpg1mLdF)zywjRKbPXoGS2LPOXZtkmfxmMbJgM1DzkQqBa(kmmLWTKPSWElSNzLzDxMYUqq0IWrJXSUltzhMIR8EWZuPQmpp4mmR7Yu2HPsT4lQoWZu8Onap0ptTNPsfGbHLmvQbIeMsgohtTtJEMQbWdEMsJgMc32rm4bMsI6hs9FBdZ6UmLDyQur0gWZuu7cpCpA4zQO9mvQDcruZuPsummvurBaMIAhc5Fb45EM6rmfMpzqBaMspaxidTmfMcPzQbKiEEO9XJr9Xu7Cy(JPguwuGlfMc4c5WTTHzDxMYomfx59GNPOo(3bm1sak)m1JyQKbKi(A8mfxLQsngM1Dzk7WuCL3dEMYUelF0KctLkZNaMkQOnatD4w0b25JreEMIlkapU042Byw3LPSdtXvEp4zk76dyQu9d8NHzDxMYomfLPHGdtPrdtXffGhxAC7zQkOrdWuoyd4yQTsJmmRmR7Yu2vPoiZp4zQkOrdWuseFnEMQcI4(mmfxjLqYFmvJA7iigED2XuH8XO(yku7sXWSgYhJ6ZKmGeXxJNw67RX)oOCcq5NznKpg1NjzajIVgpT03NpOGFG3Yo4b6bnpbXexrJ6VG0LeuAyywd5Jr9zsgqI4RXtl99PrJZVbWDzGd1rlbM1q(yuFMKbKi(A80sFppWJMukiDXLLyFXpqWFmRH8XO(mjdir814PL(EXCmEC0fKUe0eg0lGznKpg1NjzajIVgpT03pGKJdURH7ywzw3LPSRsDqMFWZuWgysHPEmpWuVaGPc5JgMcFmvSjWUO6adZAiFmQp6sbXicmRH8XO(OL((Kmpp4yw3LPOua(yk8Xu8O7DPWupIPsgyd0ptjriNhLUpMspiEMQc4wKPcPe7H(dNlfMkFGNP85b3ImfpAdWd9Byw3LPc5Jr9rl99tUlH8XOU4W3Bzh8aDE0gGh63sSMopAdWd9B847Jwcct4mRH8XO(OL(EbWGWYIdIelXA67mb2xGnq)gE0gGh634X3hTeeMfcNIjW(cSb63WJ2a8q)gClSTq4BZSgYhJ6Jw67tqpg1wI10RzT2iMJXJJUG0LGMWGEbMCInB7ieCh0sWirTh6d8fhwdA0ibdFWLOHIpgr4npMhkpQ4Xanq3UTFBM1q(yuF0sF)e8jHiyjwtxIqopkDBgqYXb31WDMb4dCF0WwP4dh0VzajhhCxjQr7rTb6O6apZAiFmQpAPVV6qiFbPlVaOanWNILyn9DQzT2mGKJdURH7m5eB2KiKZJs3MbKCCWDnCNza(a3hnW92uSZeIGW2s7PyNAwRn8q8fPdInWyYjuuZATb6jebtoXMTlbCUYhJi8NjTa84sJBpDU32Mnp6nnk1XO8v2anI3maFG7BBM1q(yuF0sFFsEW6uWTyP6I7TeRPlunR1MbKCCWDnCNjNqHq1SwBomic1bcoWyYjmRH8XO(OL((bNK4GcUlxsiblXA6cvZATzajhhCxd3zYjuiunR1MddIqDGGdmMCcZAiFmQpAPVpnAC(naUldCOoAjyjwtxOAwRndi54G7A4otoHcHQzT2CyqeQdeCGXKtywd5Jr9rl99AKmFGVe0eg8dLke8wI10fQM1AZasoo4UgUZKtOqOAwRnhgeH6abhym5eM1q(yuF0sF)arcUflAxWdNLynDHQzT2mGKJdURH7m5ekeQM1AZHbrOoqWbgtoHznKpg1hT03lrTe6FIh8fTl4blXA6cvZATzajhhCxd3zYjuiunR1MddIqDGGdmMCcfE0BKOwc9pXd(I2f8qPMN2maFG7JU9mRH8XO(OL((xauYDfLBFrJgjyjwtVM1AZasoo4UIgnsWKtywd5Jr9rl99I5y84OliDjOjmOxGLynDHQzT2mGKJdURH7m5ek25X8q5rfpgeg3CTWTz7JreEJaiCVatI8PblSFBM1q(yuF0sFppWJMukiDXLLyFXpqWFwI10fQM1AZasoo4UgUZKtywd5Jr9rl99suZfYWGMRuJUHXsSMEnR1MbKCCWDnCNXJs3u4HAwRnhgeH6abhymEu6MznKpg1hT03pGKJdURH7SeRPlk9Mb4dCF0TNIDecUdAjyKO2d9b(IdRbnAKGHp4s0qHqWDqlbt1Hq(csxEbqbAGpfdFWLOXMnjc58O0TrmhJhhDbPlbnHb9cmdWh4(eg32SvZATrmhJhhDbPlbnHb9cm5eB2QzT2uDiKVG0LxauGg4tXKt2MznKpg1hT03NwaECPXT3sSM(Laox5Jre(ZKwaECPXTxyCtHd2aoHTv7McHQzT2WdXxKoi2aJjNWSgYhJ6Jw67ZhuWpWBzh8a94eSjA4ktqt0uKOjCwI10FmpuEuXJbAWc7TztipuZATzcAIMIenHR4HAwRn5eB225JreEZJ5HYJkjYVSv7PbHtHhQzT2irTplF8gOGBofpuZATjNSTnB7iKhQzT2irTplF8gOGBofpuZATjNqrnR1gEGhnPuq6IllX(IFGG)m5eB2sgytru6nwyeZX4Xrxq6sqtyqVaB2sgytru6nwygqYXb31WDuSJqWDqlbdpWJMukiDXLLyFXpqWFg(Glrdfcb3bTemsu7H(aFXH1GgnsWWhCjA2EBM1q(yuF0sFF(Gc(bEl7GhOpbFcUflbFId)zpueXIXgK7lqlIBGznKpg1hT03NpOGFG)ywd5Jr9rl99vhc5l68KILyn9AwRndi54G7A4otoHznKpg1hT03xH5GHdUfTeRPxZATzajhhCxd3zYjmRH8XO(OL(EhwuWFfUm7f5H(TeRPxZATzajhhCxd3z8O0nfEOM1AZHbrOoqWbgJhLUzwd5Jr9rl99xcetbPl14EmQTeRPxZATzajhhCxd3z8O0nfEOM1AZHbrOoqWbgJhLUzwd5Jr9rl99rlXq)Lq)WCcqsowI10RzT2mGKJdURH7mEu6McpuZAT5WGiuhi4aJXJs3uStiF8gOanWJHtyCBZwfD32mRH8XO(OL(EnEGQdH8wI10RzT2mGKJdURH7m5eM1q(yuF0sFF0s4(jCfz4CwI10RzT2mGKJdURH7m5eM1q(yuF0sFFneliD5hSKZzjwtVM1AZasoo4UgUZ4rPBk8qnR1MddIqDGGdmgpkDtrnR1gONqem5eM1q(yuF0sF)K7siFmQlo89w2bpq)WTOdkFmIWZSYSgYhJ6ZWJ2a8q)0fadclloisywzwd5Jr9zoCl6GYhJi80pmic1bcoWWSgYhJ6ZC4w0bLpgr4PL((j4tcrWsSM(o1SwBgqYXb31WDMCInB1SwB4bE0KsbPlUSe7l(bc(ZKt22MTDQzT2a9eIGza(a3hnik92SnHiimU2(Tzwd5Jr9zoCl6GYhJi80sFpK6Gm)aZAiFmQpZHBrhu(yeHNw67RUWd3JgElXA6jdSPik9gUntWNeIaZAiFmQpZHBrhu(yeHNw679tiI6YGIXsSMEnR1gONqem5eM1q(yuFMd3IoO8XicpT03xDiK)fGN7TeRPxZATb6jebJhLUTzlOjm4hmsKZxUhaxra6lvhc5nt0Ceg3mR7YuH8XO(mhUfDq5JreEAPVV6qiFnEbwI10RzT2a9eIGXJs32Sf0eg8dgjY5l3dGRia9LQdH8MjAocJBM1q(yuFMd3IoO8XicpT03J6ZfzrbpZAiFmQpZHBrhu(yeHNw67Nqe3ILQdL2sSMUuqmIWr3cM1DzQq(yuFMd3IoO8XicpT03lN8ja3ILQdL2sSMUuqmIWr3cM1q(yuFMd3IoO8XicpT03xDiK)fGN7zw3LPc5Jr9zoCl6GYhJi80sFF1Hq(A8cywd5Jr9zoCl6GYhJi80sF)eI4wSuDO0mR7YuH8XO(mhUfDq5JreEAPVxo5taUflvhknZAiFmQpZHBrhu(yeHNw67tlapU042twxcijurJSG8KNqaa]] )


end
