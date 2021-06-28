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
        slaughterhouse = 3735, -- 352998
        warbringer = 5431, -- 356353
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
        },
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
    local gloryRage = 0

    local fresh_meat_actual = {}
    local fresh_meat_virtual = {}


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event )
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == "SPELL_CAST_SUCCESS" then
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
            
            elseif state.talent.fresh_meat.enabled and spellID == 23881 and subtype == "SPELL_DAMAGE" and not fresh_meat_actual[ destGUID ] then
                fresh_meat_actual[ destGUID ] = true
            end
        end
    end )


    local wipe = table.wipe

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function()
        wipe( fresh_meat_actual )
    end )

    spec:RegisterHook( "UNIT_ELIMINATED", function( id )
        fresh_meat_actual[ id ] = nil
    end )


    local RAGE = Enum.PowerType.Rage
    local lastRage = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "RAGE" then
            local current = UnitPower( "player", RAGE )

            if current < lastRage then
                rageSpent = ( rageSpent + lastRage - current ) % 20 -- Recklessness.             
                
                if state.legendary.glory.enabled and FindUnitBuffByID( "player", 324143 ) then
                    gloryRage = ( gloryRage + lastRage - current ) % 20 -- Glory.
                end
            end

            lastRage = current
        end
    end )

    spec:RegisterStateExpr( "rage_spent", function ()
        return rageSpent
    end )

    spec:RegisterStateExpr( "glory_rage", function ()
        return gloryRage
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" then
            if talent.recklessness.enabled then
                rage_spent = rage_spent + amt
                cooldown.recklessness.expires = cooldown.recklessness.expires - floor( rage_spent / 20 )
                rage_spent = rage_spent % 20
            end

            if legendary.glory.enabled and buff.conquerors_banner.up then
                glory_rage = glory_rage + amt
                local reduction = floor( glory_rage / 20 ) * 0.5
                glory_rage = glory_rage % 20

                buff.conquerors_banner.expires = buff.conquerors_banner.expires + reduction
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

        wipe( fresh_meat_virtual )
        active_dot.hit_by_fresh_meat = 0

        for k, v in pairs( fresh_meat_actual ) do
            fresh_meat_virtual[ k ] = v
            if k == target.unit then
                applyDebuff( "target", "hit_by_fresh_meat" )
            else
                active_dot.hit_by_fresh_meat = active_dot.hit_by_fresh_meat + 1
            end
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

            cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

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

                if talent.fresh_meat.enabled and debuff.hit_by_fresh_meat.down then
                    applyBuff( "enrage" )
                    applyDebuff( "target", "hit_by_fresh_meat" )
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
        width = "full"
    } )

    spec:RegisterSetting( "heroic_charge", false, {
        name = "Use Heroic Charge Combo",
        desc = "If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use Heroic Leap + Charge together.\n\n" ..
            "This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay.",
        type = "toggle",
        width = "full",
    } )


    spec:RegisterPack( "Fury", 20210627, [[dWuZ6aqibrpcsytOQ(eHuJskvNsQIvrib9kKOzjiDlKGDrYVOGggfYXOOwgKKNjvPMMukCnbvBdsk9nkuACuO4CqsvRtqW8qcDpuL9rioifQAHuepKcvMiHK6IsvInsib(iHeYiLsroPukQvkLmtbHUjHePDsrAOesulvQs6Pq1uPaxLqc1wHKkFLqsglKuSxI(lugmOdRyXe8yHMmLUSQnJkFgIrlvoTsRMqI41svnBsDBb2TOFJYWLIJdjA5aphX0P66i12HuFNqnEPu68ckZhjTFjlnlnqIBh)strLrOYSrOwuzmkJmMWnwZHlX9WAUeVzI9hKlXZj4sCrb0GWK4ntyA2yLgiXjmAq8s8o3BiHGHgISEhTGkYcmKSb06XxwgbdNBizdIgkXfOxT3MtPGe3o(LMIkJqLzJqTOYyugzmHBSMBdj(q7DmGehFdmUcAybnEqSBd8fWis8U1AFkfK42tIsCrb0GWkOOAaGLbQwTOZxquzSHwquzeQmxTQwgx3KiNecvlkuqJ3AVTGIY0bbxRQwuOGI6Lmc6Blyad9dE6f0Wc2MoGTXcgIFAkyC06c2EY8cM)2BlihduWnPaYe8cgzP)269OQwuOGIszOVTGMOh7jodeuWjTfuudgewwWELnGcocm0VGMOzmR3TaIxqNvWnObWq)cYbokPFgdRGmUccEKfe80o(YssbBNSbKccy0iD6Wk4rj9O7rvTOqbnER92cAY4U(feVJr7f0zfSb8ilqy8cA8IYHOQArHcA8w7Tfe1TrNbcRG9knPRGJad9lizte9PGpaK7fuu1TaT4nTQQffkOXBT3wqrXKxW2S)aIQArHcAG4p9lihduqrv3c0I30wqHZXaVG6J(6c2BJvvTOqb71hWqFBb7fc5z8ev1IcfuuZsr7fKM8cIVh5cGp9pOGlxbxx0KcoAWhByfKUPGTlQ)4Dbt)d6rvTOqbXVt3uqUP)li5OK(z8KcYXafeFrY7fK188aLexVeNinqIt2erFmFai3Lgin1S0aj(ZrqFR0ejEeS(b7iXb055yaKReVAngJdZ7oMWbKd6FG6OKEBAUTG8lOanhNs8Q1ymomV7ychqoO)bkWdMnjfKIfejAL4t0xwkXbdYMiycAMyPlnfvsdK4phb9TstK4rW6hSJehqNNJbqUs8Q1ymomV7ychqoO)bQJs6TP52cYVGc0CCkXRwJX4W8UJjCa5G(hOapy2KuqkwqKOvIprFzPehmiBIGjOzILU00ElnqI)Ce03knrIhbRFWosCsZ1AmFai3jkXDlqlEtBb5vqZfKFbrIwf4bZMKcYRGgvq(fS9c6J(PRcgczIGREoc6BlivQfmYq)CsxH(P3fgOG9uq(fe9a2rqF1B7J0(XA6gYli)c2EbbdYlOife1BubPsTGHSGrgtBzItvKL2hKkWdMnjfShj(e9LLs84KXRXeO54K4c0CCy5eCjUGESN4mqG0LM2gsdK4phb9TstK4rW6hSJexGMJt9emixbEWSjPGIuqKOTGIcliQuHxq(fK0CTgZhaYDIsC3c0I30wqrkOzj(e9LLsCb9ypXzGaPlnnCPbs8NJG(wPjs8iy9d2rIlqZXPEcgKROBki)cIEa7iOV6T9rA)ynDd5s8j6llL4rwAFqkDPPOwPbs8NJG(wPjs8iy9d2rIBVanhNISh5cGp9pqzzIZcYVGTxqsZ1AmFai3jkXDlqlEtBbfPGMlivQfemRf7OF6QXAjQnlOif0C4fShj(e9LLsCYEKla(0)aPln1yLgiXFoc6BLMiXJG1pyhjE7fuGMJtbESV(esEcrr3uqQulOanhNk4bmqyymomnDCTywWNaIIUPG9uqQuly7fuGMJt9emixbEWSjPGuSGirBbPsTGGb5fuKcI6nQG9iXNOVSuIdMGMb5sxAQXinqIprFzPepYs7dsj(ZrqFR0ePlnf1lnqI)Ce03knrIhbRFWosCbAoo1tWGCfDtb5xW2liP5AnMpaK7eL4UfOfVPTGIuqZfKk1ccM1ID0pD1yTe1MfuKcASHxWEK4t0xwkXNmUpDSHZpG0XI9LU0uZgjnqI)Ce03knrIhbRFWosCbAoo1tWGCfDtb5xW2liP5AnMpaK7eL4UfOfVPTGIuqZfKk1ccM1ID0pD1yTe1MfuKc2gHxWEK4t0xwkXjnFaymomHH4llLU0uZMLgiXNOVSuI)2(iTFj(ZrqFR0ePln1mQKgiXFoc6BLMiXJG1pyhjUanhN6jyqUIUPG8ly7fmKfuGMJtbESV(esEcrbEWSjPGuPwqWG8csXcgUrfSNcYVGKMR1y(aqUtuI7wGw8M2cYRGMli)ccM1ID0pD1yTe1MfuKc2gHlXNOVSuIlOh7jodeiDPPM7T0aj(ZrqFR0ejEeS(b7iXfO54upbdYv0nfKFbjnxRX8bGCNOe3TaT4nTfKxbnxq(femRf7OF6QXAjQnlOifSncxIVPFaGUXXwojoP5AnMpaK7eL4UfOfVPLNz(irRc8GztcpJ43oyqUiOEJOsf9a2rqF1B7J0(XA6gY5hYiJPTmXPkYs7dsf4bZMKEK4t0xwkXf0J9eNbcK4B6haOBCmenty0sCZsxAQ52qAGe)5iOVvAIepcw)GDK4c0CCQNGb5k6McYVGTxqsZ1AmFai3jkXDlqlEtBbfPGMlivQfemRf7OF6QXAjQnlOif0C4fShj(e9LLsClyqyjgGnaPln1C4sdK4phb9TstK4rW6hSJexGMJt9emixzzIZcsLAbJS0sVUc9gxgnblYs)bnUcmz)cksbdVG8lOpaK7QUpAVt1e9csXc27Wli)cgYc6J(PRIa6R9Wuphb9Ts8j6llL4cAgZ6DlG4sxAQzuR0aj(ZrqFR0ejEeS(b7iXfO54upbdYvwM4SGuPwWilT0RRqVXLrtWIS0FqJRat2VGIuWWli)c6da5UQ7J27unrVGuSG9o8cYVGHSG(OF6QiG(Apm1ZrqFReFI(YsjUGMXSE3ciU0LMA2yLgiXFoc6BLMiXJG1pyhjUanhNk4G4QpHGjWYJa20EGIUPG8liP5AnMpaK7eL4UfOfVPTGIuWElXNOVSuIlUBbAXBALU0uZgJ0aj(e9LLsCws0dnsNlXFoc6BLMiDPPMr9sdK4phb9TstK4rW6hSJep2naKtkiVcIQcsLAbfO54uGh7RpHKNqu0nfKFbrpGDe0x92(iTFSMUH8cYVG(OF6QGHqMi4QNJG(wj(e9LLsCWGSjcMGMjw6strLrsdK4phb9TstK4rW6hSJep2naKtkiVcIkj(e9LLsCWGSjcMGMjw6strLzPbs8j6llL4cAgZ6DlG4s8NJG(wPjsxAkQqL0aj(e9LLsCbnJz9UfqCj(ZrqFR0ePlnfv9wAGeFI(Ysjoyq2ebtqZelXFoc6BLMiDPPOQnKgiXNOVSuIdgKnrWe0mXs8NJG(wPjsxAkQcxAGeFI(YsjU4UfOfVPvI)Ce03knr6strfQvAGeFI(Ysjo6n6mqyyaAsNe)5iOVvAI0LMIkJvAGeFI(Ysj(g080Ujcg6n6mqys8NJG(wPjsx6sC75gATlnqAQzPbs8NJG(wPjs8j6llL4XUbGCjU9KiyB8LLsCJRBaiVGlxbfFrdEb1SePGndXliJguqwZZdcTGmqbf)cAzPO9cM)2c6DVGSMNhuWilqGvqogOG4lsEVGTNSKcOUNExyGEus8iy9d2rI7BWlOif0ykivQf0h9txzz0c6J5BWvphb9TfKk1corFrFSNpypPGIuqZfKk1cgzOFoPRq)07cduqQulyiliGophdGCfzrY7ymomNbcE63I1FteI6OKEBAUTGuPwWiJPTmXPc8yF9jK8eIc8GztsbfPGirR0LMIkPbs8j6llL4n0bbxlXFoc6BLMiDPP9wAGe)5iOVvAIeN1iXj3L4t0xwkXrpGDe0xIJE00xI7J(PRcgczIGREoc6Bli)c6da5UQ7J27unrVGuSG9o8csLAb9bGCx19r7DQMOxqkwquzubPsTG(aqUR6(O9ovt0lOif0ymQG8lyKH(5KUc9tVlmGeh9aWYj4s832hP9J10nKlDPPTH0aj(ZrqFR0ej(e9LLsCbnJz9UfqCjUEZJfTsCZgjXJG1pyhjUVbVGuSGgtb5xWj6l6J98b7jfKxbnxq(feqNNJbqUISi5DmghMZabp9BX6VjcrDusVnn3wq(fS9cgYcgzOFoPRq)07cduqQulyKX0wM4ubESV(esEcrbEWSjPGuKxbrI2c2Je3EseSn(YsjEVeqRh)KcU567OlOjAgZ6DlG4fKCus)m(cYXafKSjI(uWhaY9cszbXxK8Us6stdxAGe)5iOVvAIeFI(Ysjo4X(6ti5jejUEZJfTsCZgjXJG1pyhjUVbVGuSGgtb5xWj6l6J98b7jfKxbnxq(fmYq)CsxH(P3fgOG8liGophdGCfzrY7ymomNbcE63I1FteI6OKEBAUTG8lyd4OvcAgZ6DlG4sC7jrW24llL49saTE8tk4MRVJUG96J91NqYtifKCus)m(cYXafKSjI(uWhaY9cszbrDp9UWafKYcIVi5DL0LMIALgiXFoc6BLMiXNOVSuI3DaBJy6pnsC9MhlAL4MnsIhbRFWosCYDFteIQ7a2gXIDda5fKFb9n4fKIfm8cYVGt0x0h75d2tkiVcAUG8lyilyKH(5KUc9tVlmqb5xqaDEoga5kYIK3XyCyode80VfR)Mie1rj920CBb5xWgWrRe0mM17waXli)cgzmTLjovXUbGCf4bZMKcsXcAKkCjU9KiyB8LLs8EjGwp(jfCZ13rxW20bSnwWq8ttbfPGgx3aqEbjhL0pJVGCmqbjBIOpf8bGCVGuwWKLua1907cduqkli(IK3vsxAQXknqI)Ce03knrIprFzPep2naKlX1BESOvIB2ijEeS(b7iXj39nriQUdyBel2naKxq(f03GxqkwWWli)corFrFSNpypPG8kO5cYVGHSGrg6Nt6k0p9UWafKFbb055yaKRilsEhJXH5mqWt)wS(BIquhL0BtZTfKFbBahTQ7a2gX0FAK42tIGTXxwkX7LaA94NuWnxFhDbBthW2ybdXpnfuKcACDda5fKCus)m(cYXafKSjI(uWhaY9cszbtwsbu3tVlmqbPSG4lsExjDPPgJ0aj(e9LLs8gMVSuI)Ce03knr6str9sdK4phb9TstK4rW6hSJepYyAltCQap2xFcjpHOapy2KuqkwWExq(f0h9txbESV(ec2imPLLQNJG(wj(e9LLsCWe0mix6stnBK0aj(ZrqFR0ejEeS(b7iXfO54uGh7RpHKNquwM4SG8lO9c0CCkYEKla(0)aLLjolivQfKBr6CmWdMnjfKIfmCJK4t0xwkXJSeL0hWaemHjZdKU0uZMLgiXFoc6BLMiXJG1pyhjEiliGophdGCfzrY7ymomNbcE63I1FteI6OKEBAUTG8lis0Qapy2KuqEf0OcYVGTxW2lOanhNsqZywnnXv0nfKk1c6J(PRMe5aSGjhKh80vphb9TfKk1ccM1ID0pD1yTe1MfuKcA2Oc2tbPsTG(aqUR8n4yodZUVGIuqZgzubPsTGOhWoc6REBFK2pwt3qEbPsTG(aqUR8n4yodZUVGuSGMdVG8liywl2r)0vJ1suBwqrkOzJkypfKFbBVGKMR1y(aqUtuI7wGw8M2cYRGMlivQfuGMJtf8XXI6pOpqr3uWEK4t0xwkXbp2xFcjpHiDPPMrL0aj(ZrqFR0ejEeS(b7iXb055yaKRilsEhJXH5mqWt)wS(BIquhL0BtZTfKFbBahngs0QmRatqZG8cYVGTxW2lOanhNsqZywnnXv0nfKk1c6J(PRMe5aSGjhKh80vphb9TfKk1ccM1ID0pD1yTe1MfuKcA2Oc2tbPsTG(aqUR8n4yodZUVGIuqZgzubPsTGOhWoc6REBFK2pwt3qEbPsTG(aqUR8n4yodZUVGuSGMdVG8liywl2r)0vJ1suBwqrkOzJkypfKFbBVGKMR1y(aqUtuI7wGw8M2cYRGMlivQfuGMJtf8XXI6pOpqr3uWEK4t0xwkXbp2xFcjpHiXPjhJXXHHeTstnlDPPM7T0aj(ZrqFR0ejEeS(b7iX1h91fuKc2BuBb5xW2liP5AnMpaK7eL4UfOfVPTGIuqZfKFbdzbfO54ubFCSO(d6du0nfKk1ccM1ID0pD1yTe1MfKIfejAli)cgYckqZXPc(4yr9h0hOOBkyps8j6llL4I7wGw8MwPln1CBinqIprFzPeNMCS1FarI)Ce03knr6stnhU0aj(e9LLsCbnJzX4ObHjXFoc6BLMiDPPMrTsdK4phb9TstK4rW6hSJexGMJtbESV(esEcrr3iXNOVSuIlCa5G(BIiDPPMnwPbs8NJG(wPjs8iy9d2rIlqZXPap2xFcjpHOSmXzb5xq7fO54uK9ixa8P)bkltCkXNOVSuIRxKoNGjkH2Ie80LU0uZgJ0aj(e9LLsCUfCbnJzL4phb9TstKU0uZOEPbs8j6llL4tgpXbJgloATe)5iOVvAI0LMIkJKgiXFoc6BLMiXJG1pyhjUanhNc8yF9jK8eIYYeNfKFbTxGMJtr2JCbWN(hOSmXzb5xqbAoo1tWGCfDJeFI(YsjUWGGX4WCWg7tKU0uuzwAGe)5iOVvAIeFI(YsjoGoXMOVSetVexIRxIJLtWL4Knr0hZhaYDPlDjEd4rwGW4sdKMAwAGeFI(YsjUW4U(yKogTlXFoc6BLMiDPPOsAGe)5iOVvAIepcw)GDK4HSGa68CmaYvKfjVJX4WCgi4PFlw)nriQJs6TP5wj(e9LLsCWJ91NqYtisx6sxIJ(aYYsPPOYiuz2OWncvsCXdi3eHiXfvgFVAAB2urrHqblObDVGBqdd4fKJbkOOjBIOpMpaK7IUGGJs6fCBbjSGxWH2zbJFBbJDtICIQAfIB(c27qOGghlrFGFBbfDKH(5KUc1OEoc6BfDbDwbfDKH(5KUc1i6c2U522JQAvTevgFVAAB2urrHqblObDVGBqdd4fKJbkOOTNBO1UOli4OKEb3wqcl4fCODwW43wWy3KiNOQwH4MVG9oekOXXs0h43wqr7J(PRqnIUGoRGI2h9txHAuphb9TIUGTBUT9OQwH4MVGHhcf04yj6d8BlOOJm0pN0vOg1ZrqFROlOZkOOJm0pN0vOgrxW2n32EuvRqCZxquBiuqJJLOpWVTGIoYq)CsxHAuphb9TIUGoRGIoYq)CsxHAeDbB3CB7rvTcXnFbn2qOGghlrFGFBbfDKH(5KUc1OEoc6BfDbDwbfDKH(5KUc1i6c2U522JQAvTAZbnmGFBb7DbNOVSSG6L4ev1sI3ayCR(sCuGIckkGgewbfvdaSmq1cfOOGTOZxquzSHwquzeQmxTQwOaff046Me5KqOAHcuuqkuqJ3AVTGIY0bbxRQwOaffKcfuuVKrqFBbdyOFWtVGgwW20bSnwWq8ttbJJwxW2tMxW83EBb5yGcUjfqMGxWil93wVhv1cfOOGuOGIszOVTGMOh7jodeuWjTfuudgewwWELnGcocm0VGMOzmR3TaIxqNvWnObWq)cYbokPFgdRGmUccEKfe80o(YssbBNSbKccy0iD6Wk4rj9O7rvTqbkkifkOXBT3wqtg31VG4DmAVGoRGnGhzbcJxqJxuoevvluGIcsHcA8w7Tfe1TrNbcRG9knPRGJad9lizte9PGpaK7fuu1TaT4nTQQfkqrbPqbnER92ckkM8c2M9hquvluGIcsHcAG4p9lihduqrv3c0I30wqHZXaVG6J(6c2BJvvTqbkkifkyV(ag6BlyVqipJNOQwOaffKcfuuZsr7fKM8cIVh5cGp9pOGlxbxx0KcoAWhByfKUPGTlQ)4Dbt)d6rvTqbkkifki(D6McYn9FbjhL0pJNuqogOG4lsEVGSMNhOQwvluGIc2lT9rA)2ckCog4fmYcegVGchztIQGgFm(gNuWKLuOBabC06corFzjPGSuhMQAnrFzjr1aEKfimoL8muyCxFmshJ2Rwt0xwsunGhzbcJtjpdbp2xFcjpHe6YXlKa68CmaYvKfjVJX4WCgi4PFlw)nriQJs6TP52Qv1cfOOG9sBFK2VTGh9bHvqFdEb9UxWj6mqbxsbh0ZQhb9vvluuqJRBaiVGlxbfFrdEb1SePGndXliJguqwZZdcTGmqbf)cAzPO9cM)2c6DVGSMNhuWilqGvqogOG4lsEVGTNSKcOUNExyGEuvRj6llj8IDda5HUC88n4IymuP6J(PRSmAb9X8n4QNJG(wQuNOVOp2ZhSNiIzQuJm0pN0vOF6DHbOsnKa68CmaYvKfjVJX4WCgi4PFlw)nriQJs6TP5wQuJmM2YeNkWJ91NqYtikWdMnjIGeTvRj6lljuYZWg6GGRRwt0xwsOKNHOhWoc6hAobN3B7J0(XA6gYdf9OPppF0pDvWqiteC((aqUR6(O9ovt0PyVdNkvFai3vDF0ENQj6uevgrLQpaK7QUpAVt1eDrmgJ4hzOFoPRq)07cduTqbkkObDlPGlPGbmIRdRGoRGnGJ(PxWiJPTmXjPGCawqbf(MifCIX1(0hToScstUTGwAWMifmGH(bpDv1cfOOGt0xwsOKNHa6eBI(Ysm9s8qZj48cyOFWtp0LJxad9dE6k7s8jJxKWRwOaffCI(YscL8mS7a2gX0FAcD541oywl2r)0vbm0p4PRSlXNmErqv48bZAXo6NUkGH(bpD1MI0gH3t1cfOOGt0xwsOKNHKJs6NXh6YXBI(I(ypFWEcpZ8Jm0pN0vOF6DHbuphb9T8b055yaKRilsEhJXH5mqWt)wS(BIquhL0BtZTHMtW5zIb871h7hccAgZ6DlG4Ha4X(6ti5jKQfkkyVeqRh)KcU567OlOjAgZ6DlG4fKCus)m(cYXafKSjI(uWhaY9cszbXxK8UQAnrFzjHsEgkOzmR3TaIhQEZJfT8mBuOlhpFdofng(t0x0h75d2t4zMpGophdGCfzrY7ymomNbcE63I1FteI6OKEBAULF7HmYq)CsxH(P3fgGk1iJPTmXPc8yF9jK8eIc8Gztcf5HeT9uTqrb7LaA94NuWnxFhDb71h7RpHKNqki5OK(z8fKJbkizte9PGpaK7fKYcI6E6DHbkiLfeFrY7QQ1e9LLek5zi4X(6ti5jKq1BESOLNzJcD545BWPOXWFI(I(ypFWEcpZ8Jm0pN0vOF6DHbuphb9T8b055yaKRilsEhJXH5mqWt)wS(BIquhL0BtZT8BahTsqZywVBbeVAHcuuWj6lljuYZqYrj9Z4dD54nrFrFSNpypHNz(HmYq)CsxH(P3fgq9Ce03YhqNNJbqUISi5DmghMZabp9BX6VjcrDusVnn3gAobNNjgW346gaYdbbnJz9Ufq8qO7a2gXIDda5vluuWEjGwp(jfCZ13rxW20bSnwWq8ttbfPGgx3aqEbjhL0pJVGCmqbjBIOpf8bGCVGuwWKLua1907cduqkli(IK3vvRj6lljuYZWUdyBet)Pju9MhlA5z2OqxoEK7(Miev3bSnIf7gaY57BWPy48NOVOp2ZhSNWZm)qgzOFoPRq)07cdOEoc6B5dOZZXaixrwK8ogJdZzGGN(Ty93eHOokP3MMB53aoALGMXSE3cio)iJPTmXPk2naKRapy2KqrJuHxTqrb7LaA94NuWnxFhDbBthW2ybdXpnfuKcACDda5fKCus)m(cYXafKSjI(uWhaY9cszbtwsbu3tVlmqbPSG4lsExvTMOVSKqjpdJDda5HQ38yrlpZgf6YXJC33eHO6oGTrSy3aqoFFdofdN)e9f9XE(G9eEM5hYid9ZjDf6NExya1ZrqFlFaDEoga5kYIK3XyCyode80VfR)Mie1rj920Cl)gWrR6oGTrm9NMQ1e9LLek5zydZxwwTMOVSKqjpdbtqZG8qxoErgtBzItf4X(6ti5jef4bZMek2B((OF6kWJ91NqWgHjTSu9Ce03wTMOVSKqjpdJSeL0hWaemHjZdcD54jqZXPap2xFcjpHOSmXjF7fO54uK9ixa8P)bkltCsLk3I05yGhmBsOy4gvTMOVSKqjpdbp2xFcjpHe6YXlKa68CmaYvKfjVJX4WCgi4PFlw)nriQJs6TP5w(irRc8GztcpJ43E7c0CCkbnJz10exr3qLQp6NUAsKdWcMCqEWtx9Ce03sLkywl2r)0vJ1suBkIzJ6HkvFai3v(gCmNHz3lIzJmIkv0dyhb9vVTps7hRPBiNkvFai3v(gCmNHz3trZHZhmRf7OF6QXAjQnfXSr9WVDsZ1AmFai3jkXDlqlEtlpZuPkqZXPc(4yr9h0hOOB6PAnrFzjHsEgcESV(esEcjuAYXyCCyirlpZHUC8a055yaKRilsEhJXH5mqWt)wS(BIquhL0BtZT8Bahngs0QmRatqZGC(T3UanhNsqZywnnXv0nuP6J(PRMe5aSGjhKh80vphb9TuPcM1ID0pD1yTe1MIy2OEOs1haYDLVbhZzy29Iy2iJOsf9a2rqF1B7J0(XA6gYPs1haYDLVbhZzy29u0C48bZAXo6NUASwIAtrmBup8BN0CTgZhaYDIsC3c0I30YZmvQc0CCQGpowu)b9bk6MEQwt0xwsOKNHI7wGw8M2qxoE6J(Ar6nQLF7KMR1y(aqUtuI7wGw8MwrmZpKc0CCQGpowu)b9bk6gQubZAXo6NUASwIAtkIeT8dPanhNk4JJf1FqFGIUPNQ1e9LLek5zin5yR)as1AI(YscL8muqZywmoAqyvRj6lljuYZqHdih0FtKqxoEc0CCkWJ91NqYtik6MQ1e9LLek5zOEr6CcMOeAlsWtp0LJNanhNc8yF9jK8eIYYeN8TxGMJtr2JCbWN(hOSmXz1AI(YscL8mKBbxqZy2Q1e9LLek5z4KXtCWOXIJwxTMOVSKqjpdfgemghMd2yFsOlhpbAoof4X(6ti5jeLLjo5BVanhNISh5cGp9pqzzIt(c0CCQNGb5k6MQ1e9LLek5ziGoXMOVSetVep0CcopYMi6J5da5E1QAnrFzjrr2erFmFai3PKNHGbztembntCOlhpaDEoga5kXRwJX4W8UJjCa5G(hOokP3MMB5lqZXPeVAngJdZ7oMWbKd6FGc8GztcfrI2Q1e9LLefzte9X8bGCNsEggb0KUnrWe0mXHUC8a055yaKReVAngJdZ7oMWbKd6FG6OKEBAULVanhNs8Q1ymomV7ychqoO)bkWdMnjuejARwt0xwsuKnr0hZhaYDk5zyCY41yc0CCHMtW5jOh7jodee6YXJ0CTgZhaYDIsC3c0I30YZmFKOvbEWSjHNr8B3h9txfmeYebx9Ce03sLAKH(5KUc9tVlmG65iOVTh(OhWoc6REBFK2pwt3qo)2bdYfb1BevQHmYyAltCQIS0(GubEWSjPNQ1e9LLefzte9X8bGCNsEgkOh7jodee6YXtGMJt9emixbEWSjreKOvuiQuHZN0CTgZhaYDIsC3c0I30kI5Q1e9LLefzte9X8bGCNsEggzP9bzOlhpbAoo1tWGCfDdF0dyhb9vVTps7hRPBiVAnrFzjrr2erFmFai3PKNHK9ixa8P)bHUC8SxGMJtr2JCbWN(hOSmXj)2jnxRX8bGCNOe3TaT4nTIyMkvWSwSJ(PRgRLO2ueZH3t1AI(YsIISjI(y(aqUtjpdbtqZG8qxoETlqZXPap2xFcjpHOOBOsvGMJtf8agimmghMMoUwml4tarr30dvQTlqZXPEcgKRapy2KqrKOLkvWGCrq9g1t1AI(YsIISjI(y(aqUtjpdJS0(GSAnrFzjrr2erFmFai3PKNHtg3No2W5hq6yX(HUC8eO54upbdYv0n8BN0CTgZhaYDIsC3c0I30kIzQubZAXo6NUASwIAtrm2W7PAnrFzjrr2erFmFai3PKNHKMpamghMWq8LLHUC8eO54upbdYv0n8BN0CTgZhaYDIsC3c0I30kIzQubZAXo6NUASwIAtrAJW7PAnrFzjrr2erFmFai3PKNHVTps7VAnrFzjrr2erFmFai3PKNHc6XEIZabHUC8eO54upbdYv0n8BpKc0CCkWJ91NqYtikWdMnjuPcgKtXWnQh(KMR1y(aqUtuI7wGw8MwEM5dM1ID0pD1yTe1MI0gHxTMOVSKOiBIOpMpaK7uYZqb9ypXzGGqxoEc0CCQNGb5k6g(KMR1y(aqUtuI7wGw8MwEM5dM1ID0pD1yTe1MI0gHh6M(ba6ghdrZegnpZHUPFaGUXXwoEKMR1y(aqUtuI7wGw8MwEM5JeTkWdMnj8mIF7Gb5IG6nIkv0dyhb9vVTps7hRPBiNFiJmM2YeNQilTpivGhmBs6PAnrFzjrr2erFmFai3PKNHwWGWsmaBaHUC8eO54upbdYv0n8BN0CTgZhaYDIsC3c0I30kIzQubZAXo6NUASwIAtrmhEpvRj6lljkYMi6J5da5oL8muqZywVBbep0LJNanhN6jyqUYYeNuPgzPLEDf6nUmAcwKL(dACfyY(IeoFFai3vDF0ENQj6uS3HZpK(OF6QiG(Apm1ZrqFB1AI(YsIISjI(y(aqUtjpdf0mMvy8UqxoEc0CCQNGb5kltCsLAKLw61vO34YOjyrw6pOXvGj7ls489bGCx19r7DQMOtXEho)q6J(PRIa6R9Wuphb9TvRj6lljkYMi6J5da5oL8muC3c0I30g6YXtGMJtfCqC1NqWey5raBApqr3WN0CTgZhaYDIsC3c0I30ksVRwt0xwsuKnr0hZhaYDk5zilj6HgPZRwt0xwsuKnr0hZhaYDk5ziyq2ebtqZeh6YXl2naKt4HkQufO54uGh7RpHKNqu0n8rpGDe0x92(iTFSMUHC((OF6QGHqMi4QNJG(2Q1e9LLefzte9X8bGCNsEggb0KUnrWe0mXHUC8IDda5eEOQAnrFzjrr2erFmFai3PKNHcAgZ6DlG4vRj6lljkYMi6J5da5oL8muqZywHX7Qwt0xwsuKnr0hZhaYDk5ziyq2ebtqZexTMOVSKOiBIOpMpaK7uYZWiGM0TjcMGMjUAnrFzjrr2erFmFai3PKNHI7wGw8M2Q1e9LLefzte9X8bGCNsEgIEJodeggGM0vTMOVSKOiBIOpMpaK7uYZWnO5PDtem0B0zGWK4KMhLMASOs6sxkb]] )


end
