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
            max_stack = 3,      
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

        if legendary.will_of_the_berserker.enabled and buff.recklessness.up then
            applyBuff( "will_of_the_berserker" )
            buff.will_of_the_berserker.applied = buff.recklessness.expires
            buff.will_of_the_berserker.expires = buff.recklessness.expires + 8
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
                    applyBuff( "will_of_the_berserker" )
                    buff.will_of_the_berserker.applied = buff.recklessness.expires
                    buff.will_of_the_berserker.expires = buff.recklessness.expires + 8
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


        spell_reflect = {
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
               applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
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


    spec:RegisterPack( "Fury", 20201020, [[dOe0MaqiIOhHe1MuPmkvIoLkHxHuzwuc3IsL2fP(LkPHrj6yeHLHk8murzAIK4AIKABir03qfPghQi5COIQ1Huv08qI09qk7JsfhePQAHijpePQWerIGlksG2iseAKIeKtksKwjL0mfjQUPibStKu)uKqAOIeXsfjkpvftvLQRksi2Qib1xfju7fQ)kXGj5WclwspMWKPYLbBMIptuJMiDAeRgveVgvA2u1Trv7wQFdz4I44ivLwUspxX0v11f12rcFxKA8IK05Pu16rQY8Pu2pkJLaFhFCXdyQ5WsoSucl5WsTeCEQ5WsoWN3(eaFscb3qgWNo4b8HsmV2JpjH9Eu4W3XNbLxbGps)pzOpVEvM8sZvTaXFDi8zF8eul2W8xhcV4k(uZe)NsBCfFCXdyQ5WsoSucl5WsTeCEQ5WsjWNi)srl(Ci80hm1vMI(xHuc)tw0Gpsjoh04k(4GrGpuMPOeZR9mvko2LGwMvkZuPOIhvHLP4WslykoSKdlzwzwPmtrFinAzyOpzwPmtzxMI(DoWXuPKmpp41mRuMPSltrjqMO6bhtXJOa4H(zQRmvkeSiIGPs5qKWuIW7zQlB0ZunaoWXug0YuK2UYbpWucu)qQ(xOzwPmtzxMkfarb4ykQ8HdMhT8mv0oMIsydzuZuPmuSmvuruamfvEeY9sj78m1JykcFYIOaykZc03m0c7zkKHPwqG45H2fpb1dtD5q4hMArzzPE7zkG(Md)fAMvkZu2LPOFNdCmfvX)EGPosr5NPEetLSGaXxJNPO)uskxZSszMYUmf97CGJPsHjIhT2ZuPS8iLPIkIcGPgsl7b7(XkdptLILswFAs70mRuMPSltr)oh4yQuKbyQu6d8JgF8K5h8D8ziTShkFSYWJVJPwc8D8jepb14ZqazOUqWfw8b6O6bhMk8JPMd8D8b6O6bhMk8rSKhwsGpxYu1SXOxqW1dZ0Wm6CctzZgtvZgJMh4rR9fKP4ZcIR4wi4hDoHPUGPSzJPUKPQzJrd9gYGEb(G0dtrPmLSWXu2SXuBidmLDyko3sM6c8jepb14Zg8jHmGFm1Cg(o(eINGA8bsvqKFaFGoQEWHPc)yQtf8D8b6O6bhMk8rSKhwsGpjlqrrw40sO3GpjKb8jepb14t1hoyE0YJFm1PgFhFGoQEWHPcFel5HLe4tnBmAO3qg05e8jepb14JBdzuxwuS4htnLeFhFGoQEWHPcFel5HLe4tnBmAO3qg0ou6MPSzJPc6bl5bTa5DL5bWxKI(s1Jqo9gnxMYomLe4tiEcQXNQhHCVuYop(XuZPX3XNq8euJpOE8rww6Jpqhvp4WuHFm1Ck8D8b6O6bhMk8rSKhwsGpcPXkddtrJP4aFcXtqn(SHmPLlvpkn(XuZ5474tiEcQXNQhHCVuYop(aDu9Gdtf(XulHL474tiEcQXNnKjTCP6rPXhOJQhCyQWpMAjKaFhFcXtqn(Kwkz9PjTdFGoQEWHPc)4hF4rua8q)47yQLaFhFcXtqn(ifweru8qKGpqhvp4WuHF8JpoWez)JVJPwc8D8jepb14JqASYa(aDu9Gdtf(XuZb(o(eINGA8jjZZdE8b6O6bhMk8JPMZW3XhOJQhCyQWhXsEyjb(CjtTbXvakG(18ikaEOFTJmF0cGPSdtXrQzQBm1gexbOa6xZJOa4H(1KMPSdtLkPMPUaFcXtqn(ifweru8qKGFm1Pc(o(aDu9Gdtf(iwYdljWNA2y0Y5yDKOlitjOhSOxQoNWu2SXuxYusYuWmqlaTa1oOhWv8edyqRa08bNGwM6gt9XkdV(j8q5rfhbykkLgtrjTKPUaFcXtqn(KGEcQXpM6uJVJpqhvp4WuHpIL8Wsc8rGqEhkDRxqW1dZ0Wm6f4dspmfLYuCgtDJP(Wd9RxqW1dZuIA0ouRHoQEWHpH4jOgF2GpjKb8JPMsIVJpqhvp4WuHpIL8Wsc85sMQMng9ccUEyMgMrNtykB2ykbc5DO0TEbbxpmtdZOxGpi9WuuktjbtDbtDJPUKP2qgyk7WuCklzQBm1LmvnBmAEi(IWdbfWQZjm1nMQMngn0Bid6CctzZgtnjG3x(yLHF0PLswFAs7ykAmLem1fmLnBmLd96gLQeuEkuanIxVaFq6HPUaFcXtqn(u9iKRGmLxkuGg4Th)yQ50474d0r1domv4JyjpSKaFKKPQzJrVGGRhMPHz05eM6gtjjtvZgJEiGmuxi4cRoNGpH4jOgFsYlXypPLlvFmp(XuZPW3XhOJQhCyQWhXsEyjb(ijtvZgJEbbxpmtdZOZjm1nMssMQMng9qazOUqWfwDobFcXtqn(SKKepuiDzscbGFm1Co(o(aDu9Gdtf(iwYdljWhjzQA2y0li46HzAygDoHPUXusYu1SXOhcid1fcUWQZj4tiEcQXN0O17OaiDzHb1rla8JPwclX3XhOJQhCyQWhXsEyjb(ijtvZgJEbbxpmtdZOZjm1nMssMQMng9qazOUqWfwDobFcXtqn(yqI8aUsqpyjpuQqWJFm1sib(o(aDu9Gdtf(iwYdljWhjzQA2y0li46HzAygDoHPUXusYu1SXOhcid1fcUWQZj4tiEcQXNfIeslxm(Ghg8JPwcoW3XhOJQhCyQWhXsEyjb(ijtvZgJEbbxpmtdZOZjm1nMssMQMng9qazOUqWfwDoHPUXuo0RfOwa9VXdUIXh8qPM3wVaFq6HPOXuwIpH4jOgFeOwa9VXdUIXh8a(XulbNHVJpqhvp4WuHpIL8Wsc8PMng9ccUEyMIbTcqNtWNq8euJpVuOK7kk3UIbTca)yQLivW3XhOJQhCyQWhXsEyjb(ijtvZgJEbbxpmtdZOZjm1nM6sM6j8q5rfhbyk7WusW5PMPSzJP(yLHxlfc)lvNiEMIszkoSKPUaFcXtqn(iNJ1rIUGmLGEWIEP4htTePgFhFGoQEWHPcFel5HLe4JKmvnBm6feC9WmnmJoNGpH4jOgF4bE0AFbzk(SG4kUfc(b)yQLGsIVJpqhvp4WuHpIL8Wsc8PMng9ccUEyMgMr7qPBM6gt5GA2y0dbKH6cbxy1ou6gFcXtqn(iqn9ndlANsn6gw8JPwcon(o(aDu9Gdtf(iwYdljWhzHtVaFq6HPOXuwYu3yQlzkjzkygOfGwGAh0d4kEIbmOvaA(GtqltDJPKKPGzGwa6QhHCfKP8sHc0aV9A(GtqltzZgtjqiVdLU1Y5yDKOlitjOhSOxQEb(G0dtzhMscMYMnMQMngTCowhj6cYuc6bl6LQZjmLnBmvnBm6QhHCfKP8sHc0aV96CctDb(eINGA8zbbxpmtdZGFm1sWPW3XhOJQhCyQWhXsEyjb(mjG3x(yLHF0PLswFAs7yk7WusWu3ykjzQA2y08q8fHhckGvNtWNq8euJpPLswFAs7WpMAj4C8D8b6O6bhMk8jepb14tmsPiAykBqp0weOn84JyjpSKaFEcpuEuXraMIszkoSKPSzJPKKPCqnBm6nOhAlc0g(IdQzJrNtykB2yQlzQpwz41pHhkpQKi(cNzjtrPmvQzQBmLdQzJrlqTllEcfqH0CloOMngDoHPUGPSzJPUKPKKPCqnBmAbQDzXtOakKMBXb1SXOZjm1nMQMngnpWJw7litXNfexXTqWp6CctzZgtLSaffzHtZHwohRJeDbzkb9Gf9szkB2yQKfOOilCAo0li46HzAygM6gtDjtjjtbZaTa08apATVGmfFwqCf3cb)O5dobTm1nMssMcMbAbOfO2b9aUINyadAfGMp4e0YuxWuxGpDWd4tmsPiAykBqp0weOn84htnhwIVJpqhvp4WuHpDWd4Zg8jKwUe8jEYNDqrMihuG8FbAzsd4tiEcQXNn4tiTCj4t8Kp7GImroOa5)c0YKgWpMAoKaFhFcXtqn(KhOqEGFWhOJQhCyQWpMAo4aFhFGoQEWHPcFel5HLe4tnBm6feC9WmnmJoNGpH4jOgFQEeYvm51E8JPMdodFhFGoQEWHPcFel5HLe4tnBm6feC9WmnmJoNGpH4jOgFQWoWYL0Y4htnhPc(o(aDu9Gdtf(iwYdljWNA2y0li46HzAygTdLUzQBmLdQzJrpeqgQleCHv7qPB8jepb14JNil9NcNKDY8q)4htnhPgFhFGoQEWHPcFel5HLe4tnBm6feC9WmnmJ2Hs3m1nMYb1SXOhcid1fcUWQDO0n(eINGA8zsGylitPgZtqn(XuZbLeFhFGoQEWHPcFel5HLe4tnBm6feC9WmnmJ2Hs3m1nMYb1SXOhcid1fcUWQDO0ntDJPUKPcXtOakqd8eyyk7WusWu2SXuv0mm1f4tiEcQXNOfeO)syEyhPibx8JPMdon(o(aDu9Gdtf(iwYdljWNA2y0li46HzAygDobFcXtqn(yilu9iKd)yQ5GtHVJpqhvp4WuHpIL8Wsc8PMng9ccUEyMgMrNtWNq8euJprlG53WxeH3JFm1CW5474d0r1domv4JyjpSKaFQzJrVGGRhMPHz0ou6MPUXuoOMng9qazOUqWfwTdLUzQBmvnBmAO3qg05e8jepb14tnKlit5xIG7GFm1CML474d0r1domv4tiEcQXNn3Lq8eux8K5Xhpz(sh8a(mKw2dLpwz4Xp(XNKfei(A847yQLaFhFcXtqn(uJ)9qzKIYp(aDu9Gdtf(XuZb(o(aDu9Gdtf(0bpGpb9gPXgtXG6VGmLeuAyXNq8euJpb9gPXgtXG6VGmLeuAyXpMAodFhFcXtqn(KgTEhfaPllmOoAbGpqhvp4WuHFm1Pc(o(eINGA8Hh4rR9fKP4ZcIR4wi4h8b6O6bhMk8JPo1474tiEcQXh5CSos0fKPe0dw0lfFGoQEWHPc)yQPK474tiEcQXNfeC9Wmnmd(aDu9Gdtf(Xp(XhkGDiOgtnhwYHLsyPeCg(Ko2M0Yd(Ks5tq7doMkvyQq8euZuEY8JMzfFswKH4b8HYmfLyETNPsXXUe0YSszMkfv8OkSmfhwAbtXHLCyjZkZkLzk6dPrldd9jZkLzk7Yu0VZboMkLK55bVMzLYmLDzkkbYevp4ykEefap0ptDLPsHGfremvkhIeMseEptDzJEMQbWboMYGwMI02vo4bMsG6hs1)cnZkLzk7YuPaikahtrLpCW8OLNPI2XuucBiJAMkLHILPIkIcGPOYJqUxkzNNPEetr4twefatzwG(MHwyptHmm1ccepp0U4jOEyQlhc)Wulkll1Bptb03C4VqZSszMYUmf97CGJPOk(3dm1rkk)m1JyQKfei(A8mf9Nss5AMvkZu2LPOFNdCmvkmr8O1EMkLLhPmvuruam1qAzpy3pwz4zQuSuY6ttANMzLYmLDzk635ahtLImatLsFGF0mRmRuMPsbtvqKFWXuvWGwGPei(A8mvfKj9Ozk6xiGKFyQg12vAS8MSNPcXtq9WuO2BVMznepb1JozbbIVgpD0UwJ)9qzKIYpZAiEcQhDYcceFnE6ODnpqH8aVfDWd0c6nsJnMIb1FbzkjO0WYSgING6rNSGaXxJNoAxtJwVJcG0LfguhTaywdXtq9OtwqG4RXthTR8apATVGmfFwqCf3cb)WSgING6rNSGaXxJNoAxLZX6irxqMsqpyrVuM1q8eup6Kfei(A80r76ccUEyMgMHzLzLYmvkyQcI8doMcOaw7zQNWdm1lfyQq8OLPidtfueeFu9GMznepb1dnH0yLbM1q8eup0r7AsMNh8mRuMPUlLmmfzykE08E7zQhXujlqb0ptjqiVdLUhMYSiEMQcKwMPcHG4G(dV3EMkpGJPC5L0YmfpIcGh6xZSszMkepb1dD0UU5UeING6INmVfDWd04rua8q)wqm04rua8q)Ahz(OfGDsnZAiEcQh6ODvkSiIO4HiXcIH2LBqCfGcOFnpIcGh6x7iZhTaSdhP(2gexbOa6xZJOa4H(1K2oPsQVGznepb1dD0UMGEcQTGyOvZgJwohRJeDbzkb9Gf9s15eB2UusygOfGwGAh0d4kEIbmOvaA(Gtq7Tpwz41pHhkpQ4iaLsJsA5fmRH4jOEOJ21n4tczWcIHMaH8ou6wVGGRhMPHz0lWhKEOuo72hEOF9ccUEyMsuJ2HAn0r1doM1q8eup0r7A1JqUcYuEPqbAG3EligAxwZgJEbbxpmtdZOZj2SjqiVdLU1li46HzAyg9c8bPhkvIlUD5gYGD4uwE7YA2y08q8fHhckGvNtUvZgJg6nKbDoXMTjb8(YhRm8JoTuY6ttAhnjUWMnh61nkvjO8uOaAeVEb(G0ZfmRH4jOEOJ21K8sm2tA5s1hZBbXqtYA2y0li46HzAygDo5MK1SXOhcid1fcUWQZjmRH4jOEOJ21LKK4HcPltsialigAswZgJEbbxpmtdZOZj3KSMng9qazOUqWfwDoHznepb1dD0UMgTEhfaPllmOoAbybXqtYA2y0li46HzAygDo5MK1SXOhcid1fcUWQZjmRH4jOEOJ2vdsKhWvc6bl5HsfcEligAswZgJEbbxpmtdZOZj3KSMng9qazOUqWfwDoHznepb1dD0UUqKqA5IXh8WybXqtYA2y0li46HzAygDo5MK1SXOhcid1fcUWQZjmRH4jOEOJ2vbQfq)B8GRy8bpybXqtYA2y0li46HzAygDo5MK1SXOhcid1fcUWQZj3COxlqTa6FJhCfJp4HsnVTEb(G0dnlzwdXtq9qhTRVuOK7kk3UIbTcWcIHwnBm6feC9WmfdAfGoNWSgING6HoAxLZX6irxqMsqpyrVuligAswZgJEbbxpmtdZOZj3U8j8q5rfhbSJeCEQTz7JvgETui8VuDI4PuoS8cM1q8eup0r7kpWJw7litXNfexXTqWpwqm0KSMng9ccUEyMgMrNtywdXtq9qhTRcutFZWI2PuJUH1cIHwnBm6feC9WmnmJ2Hs33CqnBm6HaYqDHGlSAhkDZSgING6HoAxxqW1dZ0Wmwqm0Kfo9c8bPhAwE7sjHzGwaAbQDqpGR4jgWGwbO5dobT3KeMbAbOREeYvqMYlfkqd82R5dobT2SjqiVdLU1Y5yDKOlitjOhSOxQEb(G0JDKWMTA2y0Y5yDKOlitjOhSOxQoNyZwnBm6QhHCfKP8sHc0aV96CYfmRH4jOEOJ210sjRpnPDwqm0MeW7lFSYWp60sjRpnPD2rIBswZgJMhIVi8qqbS6CcZAiEcQh6ODnpqH8aVfDWd0Irkfrdtzd6H2IaTH3cIH2t4HYJkocqPCyPnBs6GA2y0Bqp0weOn8fhuZgJoNyZ2LFSYWRFcpuEujr8foZskn13CqnBmAbQDzXtOakKMBXb1SXOZjxyZ2Ls6GA2y0cu7YINqbuin3IdQzJrNtUvZgJMh4rR9fKP4ZcIR4wi4hDoXMTKfOOilCAo0Y5yDKOlitjOhSOxQnBjlqrrw40COxqW1dZ0Wm3UusygOfGMh4rR9fKP4ZcIR4wi4hnFWjO9MKWmqlaTa1oOhWv8edyqRa08bNG2lUGznepb1dD0UMhOqEG3Io4bABWNqA5sWN4jF2bfzICqbY)fOLjnWSgING6HoAxZduipWpmRH4jOEOJ21QhHCftET3cIHwnBm6feC9WmnmJoNWSgING6HoAxRWoWYL0Ywqm0QzJrVGGRhMPHz05eM1q8eup0r7QNil9NcNKDY8q)wqm0QzJrVGGRhMPHz0ou6(MdQzJrpeqgQleCHv7qPBM1q8eup0r76KaXwqMsnMNGAligA1SXOxqW1dZ0WmAhkDFZb1SXOhcid1fcUWQDO0nZAiEcQh6ODnAbb6VeMh2rksW1cIHwnBm6feC9WmnmJ2Hs33CqnBm6HaYqDHGlSAhkDF7Yq8ekGc0apbg7iHnBv0mxWSgING6HoAxnKfQEeYzbXqRMng9ccUEyMgMrNtywdXtq9qhTRrlG53WxeH3BbXqRMng9ccUEyMgMrNtywdXtq9qhTR1qUGmLFjcUJfedTA2y0li46HzAygTdLUV5GA2y0dbKH6cbxy1ou6(wnBmAO3qg05eM1q8eup0r76M7siEcQlEY8w0bpqBiTShkFSYWZSYSgING6rZJOa4H(Pjfweru8qKWSYSgING6rpKw2dLpwz4PneqgQleCHLznepb1JEiTShkFSYWthTRBWNeYGfedTlRzJrVGGRhMPHz05eB2QzJrZd8O1(cYu8zbXvCle8JoNCHnBxwZgJg6nKb9c8bPhkvw4SzBdzWoCULxWSgING6rpKw2dLpwz4PJ2vivbr(bM1q8eup6H0YEO8XkdpD0Uw9HdMhT8wqm0swGIISWPLqVbFsidmRH4jOE0dPL9q5JvgE6OD1THmQllkwligA1SXOHEdzqNtywdXtq9Ohsl7HYhRm80r7A1JqUxkzN3cIHwnBmAO3qg0ou62MTGEWsEqlqExzEa8fPOVu9iKtVrZ1osWSszMkepb1JEiTShkFSYWthTRvpc5QXl1cIHwnBmAO3qg0ou62MTGEWsEqlqExzEa8fPOVu9iKtVrZ1osWSgING6rpKw2dLpwz4PJ2vup(ill9zwdXtq9Ohsl7HYhRm80r76gYKwUu9O0wqm0esJvggACWSszMkepb1JEiTShkFSYWthTRInpsjTCP6rPTGyOjKgRmm04Gznepb1JEiTShkFSYWthTRvpc5EPKDEMvkZuH4jOE0dPL9q5JvgE6ODT6rixnEPmRH4jOE0dPL9q5JvgE6ODDdzslxQEuAMvkZuH4jOE0dPL9q5JvgE6ODvS5rkPLlvpknZAiEcQh9qAzpu(yLHNoAxtlLS(0K2HptciWuZP5a)4hJb]] )


end
