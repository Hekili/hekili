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
                hit_by_fresh_meat = {
                    duration = 3600,
                    max_stack = 1,
                }
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


    spec:RegisterPack( "Fury", 20210703, [[d4Khlbqiiv5rOqTjI4tusnkkOtrbwLkOsEfrvZsf4weLAxe(fLWWikogLQLbP0ZOK00qb11ujSnvq4BQG04GuKZrjHwhkG5bPY9is7JOYbvbLfsj6HOanrvq0fHuuBesvHpcPQOrcPQ0jvbvTsvOzIcYnPKOQDsH6NQGk1qvbvSuivvpfLMkfYvPKOyRusWxPKiJfsH9sYFHQbd6Wswms9yrnzrUSYMHYNHy0QuNgy1usu51QKMnPUnfTBQ(nQgUk64OqwUQEoIPlCDKSDu03PugprjNxLO1tjrP5dj7xQv2vgPytvmLXOvg0AxMdvgRkSBv7OLHVqXgxEof7zLVwitX6L5uSOpO(lvSN1LAELugPyjCQppf7DeNegWclqaXnfTiZnTGamP0va4E(lSWccWmBHILMcOJdVROvSPkMYy0kdATlZHkJvf2TQD0AvgwXwuXn)vSSatgSHw0Wd7Z3aZa8CII9gKsZv0k20izfl6dQ)YgALQ)b8VpEKsFzdT6bneTYGw79X(idExoYimqFu2n8WsPLA4HdLP50I(OSB4HeqkA9sn0KZCMZJgArdrF3Zb5gYqRoByU06gAOZJg6BPLAig)BiWLnszUgM5Emzfgi6JYUHw55mxQHwQR0ib)nBy5PgEi)cH7ne9ZRVHfnN5AOLAopf3GNenm4neyE(CMRHy)ye188LnKJ1WFzUP58ufaUtAOHeGjPHpNc5wFzdhJOkTbI(OSB4HLsl1qlRi0RHS3CQOHbVHN)YCt6kA4HD4WqI(OSB4HLsl1qRaih8)YgI(Pi3nSO5mxdjahrpzh1JSOHwPBWRTb8KOpk7gEyP0sn0kdzn8WhZKi6JYUHgzB11gIX)gALUbV2gWtnKEy8FnupMt3qREOI(OSBi6FMCMl1q0mHmppIOpk7gEi5U1rdPiRHSGHm6F119neG1qqynPHL(xLUSHuNn0Wd5Q42SUU3arFu2nKDb1zdXQRRHKXiQ55rAig)BilaXx0q(589cfRgqcIYifBXNYiLX2vgPyNx06LuwQyZpi2dkflsoj(zwaN0qPnuMgkPHeoLMg4jbg4jbojEW1jMx06LAOKgstHHjWapjWjXdUoXpZc4KgkPH0uyyI5FHmXpZc4KgIUgIKtk2khaURyZLNNgNMcdtXstHHH7L5uS06knsWFtvOmgTkJuSZlA9sklvS5he7bLILMcdtm)lKjOoBOKgM5CDIBZf)Yx1Jq8riIFMfWjnuUgEHITYbG7k2YZG5bEHf7j388vvOm2QkJuSZlA9sklvS5he7bLILMcdtm)lKjOoBOKg(fYAi6AidlJITYbG7kwY5QhNJHtxKaWDvOmMHvgPyNx06LuwQyZpi2dkflnfgMy(xitqD2qjnKCoTgpQhzbry7g8ABap1q5AiAvSvoaCxXsRR0ib)nvSap2)uNboatXIKtIFMfWjsLrcHtPPbEsGbEsGtIhCDsOPWWeyGNe4K4bxN4NzbCIeAkmmX8VqM4NzbCc6qYjvOm(cLrk25fTEjLLk28dI9GsXAydPPWWeZ)czcQZgIcvdPPWWe)Yx1Jq8ricQZgkPHpLpm(Jmbb4yuACc1JmX8IwVudnOHsAiZ6bfTEIjRLPIHFExKPyRCa4UInZ90mDvOm(qOmsXw5aWDflbmKr)RUUxXoVO1lPSufkJpuLrk2khaURy)Y8SqMIDErRxszPkugJMugPyNx06LuwQyZpi2dkflnfgMy(xitqD2qjnmZ56e3Ml(LVQhH4Jqe)mlGtAOCn8cfBLda3vSKZvpohdNUibG7QqzSvuzKIDErRxszPIn)GypOuS0uyyI5FHmXpZc4KgkxdrYPgE4QHOvCHITYbG7kwADLgj4VPkugBxgLrk2khaURyzcYb)Ve)Pi3k25fTEjLLQqzSD7kJuSvoaCxXcmpNNaocotqo4)Lk25fTEjLLQqfkwcWr0dpQhzHYiLX2vgPyNx06LuwQyZpi2dkf7t5dJ)itydO14Cm84E407j7VUxmgrbopxQHsAinfgMWgqRX5y4X9WP3t2FDV4NzbCsdrxdrYjfBLda3vSFHaCeCAn3MkugJwLrk25fTEjLLk28dI9GsX(u(W4pYe2aAnohdpUho9EY(R7fJruGZZLAOKgstHHjSb0ACogECpC69K9x3l(zwaN0q01qKCsXw5aWDf7xiahbNwZTPcLXwvzKIDErRxszPIn)GypOuSKZP14r9ilicB3GxBd4PgkTH2BOKgIKtIFMfWjnuAdLPHsAOHnmk98qywesL)jMx06LAikunmZzoV8qWCECF53qdAOKgYSEqrRNyYAzQy4N3fznusdnSHFHSgkxdTIY0quOAi61WmNRtCBUiZ90mDXpZc4KgAGITYbG7k2C55PXPPWWuS0uyy4EzoflTUsJe83ufkJzyLrk25fTEjLLk28dI9GsXAydPPWWeZ)czcQZgIcvdPPWWe)Yx1Jq8ricQZgkPHpLpm(Jmbb4yuACc1JmX8IwVudnOHsAiZ6bfTEIjRLPIHFExKPyRCa4UInZ90mDvOm(cLrk25fTEjLLk28dI9GsXstHHjM)fYeuNnusdzwpOO1tmzTmvm8Z7ImfBLda3vSzUNMPRcLXhcLrk25fTEjLLk28dI9GsXMgnfgMGagYO)vx3lsCBEdL0qdBi5CAnEupYcIW2n412aEQHY1q7nefQg(fiHpMZdrLsebWBOCn0(fn0afBLda3vSeWqg9V66EvOm(qvgPyNx06LuwQyZpi2dkfRHnKMcdt8lFvpcXhHiOoBikunKMcdtyot(FjohdxtLbj80VYKiOoBObnefQgAydPPWWeZ)czIFMfWjneDnejNAikun8lK1q5AOvuMgAqdrHQH0uyycSFUv2lf)mlGtAi6AODXfk2khaURy)Y8SqMkugJMugPyRCa4UInZ90mDf78IwVKYsvOm2kQmsXoVO1lPSuXMFqShukwAkmmX8VqMG6SHsAOHnKCoTgpQhzbry7g8ABap1q5AO9gIcvd)cKWhZ5HOsjIa4nuUgEOx0qduSvoaCxXwEgmpWlSyp5MNVQcLX2LrzKIDErRxszPIn)GypOuS0uyyI5FHmb1zdL0qdBi5CAnEupYcIW2n412aEQHY1q7nefQg(fiHpMZdrLsebWBOCnKHVOHgOyRCa4UILCU6X5y40fjaCxfkJTBxzKITYbG7k2jRLPIPyNx06LuwQcLX2rRYif78IwVKYsfB(bXEqPyPPWWeZ)czcQZgkPHg2q0RH0uyyIF5R6ri(ieXpZc4KgIcvd)czneDn8czAObnusdnSHKZP14r9ilicB3GxBd4PgkTH2BOKg(fiHpMZdrLsebWBOCnKHVOHOq1qY50A8OEKfeHTBWRTb8udL2q02qduSvoaCxXsRR0ib)nvHYy7wvzKIDErRxszPIn)GypOuS0uyyI5FHmrIBZBikunmZ9efiembzaNIGN5EmZZq8LFTHY1WlAOKgg1JSqCVsh3IZC0q01qREHITYbG7kwAnNNIBWtcvOm2odRmsXoVO1lPSuXMFqShukwAkmmX8VqMiXT5nefQgM5EIcecMGmGtrWZCpM5zi(YV2q5A4fnusdJ6rwiUxPJBXzoAi6AOvVOHsAi61WO0Zdr(PMoUumVO1lPyRCa4UILwZ5P4g8KqfkJTFHYif78IwVKYsfB(bXEqPyPPWWeZ)czcQZgkPHg2qY50A8OEKfeHTBWRTb8udLRH2Bikun8lqcFmNhIkLicG3q5AO9lAObk2khaURytFHWD8NxVkugB)qOmsXw5aWDfl3j6Ic5ouSZlA9sklvHYy7hQYif78IwVKYsfB(bXEqPyPPWWeM7Za9ieCAUpKh4P9cQZgkPHKZP14r9ilicB3GxBd4PgkxdTQITYbG7kwB3GxBd4jvOm2oAszKIDErRxszPIn)GypOuS576rgPHsBiABikunKMcdt8lFvpcXhHiOoBOKgYSEqrRNyYAzQy4N3fznusdJsppeMfHu5FI5fTEjfBLda3vSFHaCeCAn3MkugB3kQmsXoVO1lPSuXMFqShuk28D9iJ0qPneTnefQgstHHj(LVQhH4JqeuNnusdzwpOO1tmzTmvm8Z7ISgkPHrPNhcZIqQ8pX8IwVKITYbG7k2VqaocoTMBtfkJrRmkJuSvoaCxXsR58uCdEsOyNx06LuwQcLXO1UYifBLda3vS0Aopf3GNek25fTEjLLQqzmArRYifBLda3vSFHaCeCAn3MIDErRxszPkugJwRQmsXw5aWDf7xiahbNwZTPyNx06LuwQcLXOLHvgPyRCa4UI12n412aEsXoVO1lPSufQqXMgwrPdLrkJTRmsXoVO1lPSuXw5aWDfB(UEKPytJKFWza4UILbVRhzneG1qBZ6FnuZDKgEwKOHCQVH8Z57pOH8VH2wdtC36OH(wQHX9Ai)C((gM5M08gIX)gYcq8fn0qN7Y2kmpUV8nqOyZpi2dkfBamxdLRHOPgIcvdJsppejofTE4bWCI5fTEPgIcvdRCayo85ZemsdLRH2BikunmZzoV8qWCECF53quOAi61WNYhg)rMGaq8f4Cm8G)MZJLWVcCeIymIcCEUudrHQHzoxN42CXV8v9ieFeI4NzbCsdLRHi5KkugJwLrk2khaURypPmnNwXoVO1lPSufkJTQYif78IwVKYsfl)uXswOyRCa4UILz9GIwpflZstnfBu65HWSiKk)tmVO1l1qjnmQhzH4ELoUfN5OHORHw9IgIcvdJ6rwiUxPJBXzoAi6AiALPHOq1WOEKfI7v64wCMJgkxdrtY0qjnmZzoV8qWCECF5RyzwpUxMtXozTmvm8Z7ImvOmMHvgPyNx06LuwQy5NkwYcfBLda3vSmRhu06PyzwAQPyFkFy8hzccaXxGZXWd(Bopwc)kWriI5fTEPgIcvdFkFy8hzccWXO04eQhzI5fTEPgIcvdFkFy8hzIPVKakh3eGChI5fTEjflZ6X9YCkwkhWiQHRhY8u9GruHY4lugPyNx06LuwQyRCa4UILwZ5P4g8KqXQb(WZjfRDzuS5he7bLInaMRHORHOPgkPHvoamh(8zcgPHsBO9gkPHpLpm(JmbbG4lW5y4b)nNhlHFf4ieXyef48CPgkPHg2q0RHzoZ5LhcMZJ7l)gIcvdZCUoXT5IF5R6ri(ieXpZc4KgIoPnejNAObk20i5hCgaURyrZMu6kgPHaheGs3ql1CEkUbpjAizmIAEEneJ)nKaCe9KDupYIgkFdzbi(cHkugFiugPyNx06LuwQyRCa4UI9x(QEeIpcrXQb(WZjfRDzuS5he7bLInaMRHORHOPgkPHvoamh(8zcgPHsBO9gkPHzoZ5LhcMZJ7l)gkPHpLpm(JmbbG4lW5y4b)nNhlHFf4ieXyef48CPgkPHN)ykO1CEkUbpjuSPrYp4maCxXIMnP0vmsdboiaLUHO)LVQhH4JqAizmIAEEneJ)nKaCe9KDupYIgkFdTcZJ7l)gkFdzbi(cHkugFOkJuSZlA9sklvSvoaCxXEVNdY46vNkwnWhEoPyTlJIn)GypOuSKfbWriI79CqgpFxpYAOKggaZ1q01WlAOKgw5aWC4ZNjyKgkTH2BOKgIEnmZzoV8qWCECF53qjn8P8HXFKjiaeFbohdp4V58yj8RahHigJOaNNl1qjn88htbTMZtXn4jrdL0WmNRtCBUiFxpYe)mlGtAi6AOmIluSPrYp4maCxXIMnP0vmsdboiaLUHOV75GCdzOvNnuUgYG31JSgsgJOMNxdX4Fdjahrpzh1JSOHY3qN7Y2kmpUV8BO8nKfG4leQqzmAszKIDErRxszPITYbG7k28D9itXQb(WZjfRDzuS5he7bLILSiaocrCVNdY4576rwdL0WayUgIUgErdL0WkhaMdF(mbJ0qPn0EdL0q0RHzoZ5LhcMZJ7l)gkPHpLpm(JmbbG4lW5y4b)nNhlHFf4ieXyef48CPgkPHN)ykU3ZbzC9QtfBAK8doda3vSOztkDfJ0qGdcqPBi67Eoi3qgA1zdLRHm4D9iRHKXiQ551qm(3qcWr0t2r9ilAO8n05USTcZJ7l)gkFdzbi(cHkugBfvgPyRCa4UI9KhaURyNx06LuwQcLX2LrzKIDErRxszPIn)GypOuSzoxN42CXV8v9ieFeI4NzbCsdrxdTAdL0WO0ZdXV8v9ie8IU8e3fZlA9sk2khaURy)Y8SqMkugB3UYif78IwVKYsfB(bXEqPyPPWWe)Yx1Jq8riIe3M3qjnmnAkmmbbmKr)RUUxK428gIcvdXai3b(pZc4KgIUgEHmk2khaURyZCNru75pbNUCFVkugBhTkJuSZlA9sklvS5he7bLI9P8HXFKjiahJsJtOEKjMx06LAOKgIKtIFMfWjnuAdLPHsAOHnKz9GIwpXK1YuXWpVlYAikun0Wgg1JSqeaZHhC8ZCGB1lAOCnKHLPHsAyu65HOCK94MLxiZCEiMx06LAikunmQhzHiaMdp44N5a3Qx0q5A4HktdL0q0RHrPNhIYr2JBwEHmZ5HyErRxQHg0qdAOKgAydjNtRXJ6rwqe2UbV2gWtnuAdT3quOAinfgMWCvGN1RyUxqD2qduSvoaCxX(lFvpcXhHOcLX2TQYif78IwVKYsfB(bXEqPyFkFy8hzIPVKakh3eGChI5fTEPgkPHi5K4NzbCsdL2qzAOKgAydZCUoXT5cY5QhNJHtxKaWDXpZc4KgIUgErdrHQHzoxN42Cb5C1JZXWPlsa4U4NzbCsdLRHOvMgAqdL0qdBOHnKMcdtqR58KMIecQZgIcvdJsppeLJSh3S8czMZdX8IwVudrHQHFbs4J58quPera8gkxdTltdnOHOq1WOEKfIayo8GJNaRHY1q7YitdrHQHmRhu06jMSwMkg(5DrwdrHQHr9ilebWC4bhpbwdrxdTFrdL0WVaj8XCEiQuIiaEdLRH2LPHg0qjn0WgsoNwJh1JSGiSDdETnGNAO0gAVHOq1qAkmmH5QapRxXCVG6SHgOyRCa4UI9x(QEeIpcrfkJTZWkJuSZlA9sklvS5he7bLIf9AiZ6bfTEckhWiQHRhY8u9GrAOKgIKtIFMfWjnuAdLPHsAOHn0WgstHHjO1CEstrcb1zdrHQHrPNhIYr2JBwEHmZ5HyErRxQHOq1WVaj8XCEiQuIiaEdLRH2LPHg0quOAyupYcramhEWXtG1q5AODzKPHOq1qM1dkA9etwltfd)8UiRHOq1WOEKfIayo8GJNaRHORH2VOHsA4xGe(yopevkreaVHY1q7Y0qdAOKgAydjNtRXJ6rwqe2UbV2gWtnuAdT3quOAinfgMWCvGN1RyUxqD2qduSvoaCxX(lFvpcXhHOcLX2VqzKIDErRxszPIn)GypOuSpLpm(JmbbG4lW5y4b)nNhlHFf4ieXyef48CPgkPHN)yIJKtc7IVmplK1qjn0WgAydPPWWe0AopPPiHG6SHOq1WO0Zdr5i7XnlVqM58qmVO1l1quOA4xGe(yopevkreaVHY1q7Y0qdAikunmQhzHiaMdp44jWAOCn0UmY0quOAiZ6bfTEIjRLPIHFExK1quOAyupYcramhEWXtG1q01q7x0qjn8lqcFmNhIkLicG3q5AODzAObnusdnSHKZP14r9ilicB3GxBd4PgkTH2BikunKMcdtyUkWZ6vm3lOoBObk2khaURy)LVQhH4JquSuKHZXWWrYjLX2vHYy7hcLrk25fTEjLLk28dI9GsXQhZPBOCn0QhIgkPHg2qY50A8OEKfeHTBWRTb8udLRH2BOKgIEnKMcdtyUkWZ6vm3lOoBikun8lqcFmNhIkLicG3q01qKCQHsAi61qAkmmH5QapRxXCVG6SHgOyRCa4UI12n412aEsfkJTFOkJuSvoaCxXsrgoiMjrXoVO1lPSufkJTJMugPyRCa4UILwZ5jCmQ)sf78IwVKYsvOm2UvuzKIDErRxszPIn)GypOuS0uyyIF5R6ri(ieb1PITYbG7kw69K9xboIkugJwzugPyNx06LuwQyZpi2dkflnfgM4x(QEeIpcrK428gkPHPrtHHjiGHm6F119Ie3MRyRCa4UIvdqUdcUvoQeI58qfkJrRDLrk2khaURyXa)O1CEsXoVO1lPSufkJrlAvgPyRCa4UIT88iXxA8CP1k25fTEjLLQqzmATQYif78IwVKYsfB(bXEqPyPPWWe)Yx1Jq8riIe3M3qjnmnAkmmbbmKr)RUUxK428gkPH0uyyI5FHmb1PITYbG7kw6cbNJHhpiFLOcLXOLHvgPyNx06LuwQyZpi2dkfl5CAnEupYcIW2n412aEQHY1q7kws8GCOm2UITYbG7k2NYXRCa4oUgqcfRgqcCVmNIT4tfkJr7fkJuSZlA9sklvSvoaCxX(uoELda3X1asOy1asG7L5uSeGJOhEupYcvOcf75Vm3KUcLrkJTRmsXw5aWDflDfHE4KBovOyNx06LuwQcLXOvzKIDErRxszPIn)GypOuSOxdFkFy8hzccaXxGZXWd(Bopwc)kWriIXikW55sk2khaURy)LVQhH4JquHkuHIL5EcG7kJrRmO1UmhQm2f2vS2Q3bocrXALom0VXhEJrFYanSHgDVgcmp5F0qm(3qRl(SUH)yef4xQHeU5AyrfCZkwQH57Yrgr0hziGVgANbAidYDM7JLAO1eoLMg4jbAyDddEdTMWP00apjqdX8IwVK1n0q7YYarFKHa(A4fmqdzqUZCFSudT(P8HXFKjqdRByWBO1pLpm(JmbAiMx06LSUHgAxwgi6J9rR0HH(n(WBm6tgOHn0O71qG5j)JgIX)gAnb4i6Hh1JSW6g(JruGFPgs4MRHfvWnRyPgMVlhzerFKHa(AOvzGgYGCN5(yPgADMZCE5HaneZlA9sw3WG3qRZCMZlpeOH1n0q7YYarFKHa(AidZanKb5oZ9Xsn06NYhg)rManSUHbVHw)u(W4pYeOHyErRxY6gAODzzGOp2hTshg634dVXOpzGg2qJUxdbMN8pAig)BO1PHvu6W6g(JruGFPgs4MRHfvWnRyPgMVlhzerFKHa(AOvzGgYGCN5(yPgADu65HanSUHbVHwhLEEiqdX8IwVK1n0q7YYarFKHa(AidZanKb5oZ9Xsn06NYhg)rManSUHbVHw)u(W4pYeOHyErRxY6gAODzzGOpYqaFnKHzGgYGCN5(yPgA9t5dJ)itGgw3WG3qRFkFy8hzc0qmVO1lzDdROHO5d3mudn0USmq0hziGVgYWmqdzqUZCFSudT(P8HXFKjqdRByWBO1pLpm(JmbAiMx06LSUHgAxwgi6JmeWxdpemqdzqUZCFSudToZzoV8qGgI5fTEjRByWBO1zoZ5Lhc0W6gAODzzGOpYqaFn8qzGgYGCN5(yPgADMZCE5HaneZlA9sw3WG3qRZCMZlpeOH1n0q7YYarFKHa(AiAIbAidYDM7JLAO1zoZ5Lhc0qmVO1lzDddEdToZzoV8qGgw3qdTllde9rgc4RH2rld0qgK7m3hl1qRJsppeOH1nm4n06O0ZdbAiMx06LSUHgIwzzGOpYqaFn0oAzGgYGCN5(yPgA9t5dJ)itGgw3WG3qRFkFy8hzc0qmVO1lzDdn0USmq0hziGVgA3QmqdzqUZCFSudT(P8HXFKjqdRByWBO1pLpm(JmbAiMx06LSUHgAxwgi6J9XdV5j)JLAid3WkhaU3qnGeerFuXsoxwz8HIwf75ZXa6PyzmJBi6dQ)YgALQ)b8VpYyg3WJu6lBOvpOHOvg0AVp2hzmJBidExoYimqFKXmUHYUHhwkTudpCOmnNw0hzmJBOSB4HeqkA9sn0KZCMZJgArdrF3Zb5gYqRoByU06gAOZJg6BPLAig)BiWLnszUgM5Emzfgi6JmMXnu2n0kpN5sn0sDLgj4Vzdlp1Wd5xiCVHOFE9nSO5mxdTuZ5P4g8KOHbVHaZZNZCne7hJOMNVSHCSg(lZnnNNQaWDsdnKamjn85ui36lB4yevPnq0hzmJBOSB4HLsl1qlRi0RHS3CQOHbVHN)YCt6kA4HD4WqI(iJzCdLDdpSuAPgAfa5G)x2q0pf5UHfnN5Aib4i6j7OEKfn0kDdETnGNe9rgZ4gk7gEyP0sn0kdzn8WhZKi6JmMXnu2n0iBRU2qm(3qR0n412aEQH0dJ)RH6XC6gA1dv0hzmJBOSBi6FMCMl1q0mHmppIOpYyg3qz3Wdj3ToAifznKfmKr)RUUVHaSgccRjnS0)Q0LnK6SHgEixf3M119gi6JmMXnu2nKDb1zdXQRRHKXiQ55rAig)BilaXx0q(589I(yFKXmUHOzzTmvSudPhg)xdZCt6kAi9qaor0WdlN3zqAOZDzFxVjgLUHvoaCN0qURVu0hRCa4orC(lZnPRqEPwqxrOho5Mtf9XkhaUteN)YCt6kKxQf)Yx1Jq8rihaWKIEpLpm(JmbbG4lW5y4b)nNhlHFf4ieXyef48CP(yFKXmUHOzzTmvSudhZ9x2WayUgg3RHvo4FdbKgwmlGUO1t0hzCdzW76rwdbyn02S(xd1ChPHNfjAiN6Bi)C((dAi)BOT1We3ToAOVLAyCVgYpNVVHzUjnVHy8VHSaeFrdn05USTcZJ7lFde9XkhaUtKMVRhzhaWKgaZjhAcfQO0ZdrItrRhEamNyErRxcfQkhaMdF(mbJiNDuOYCMZlpemNh3x(OqHEpLpm(JmbbG4lW5y4b)nNhlHFf4ieXyef48CjuOYCUoXT5IF5R6ri(ieXpZc4e5qYP(yLda3jYl1ItktZP7JvoaCNiVulywpOO17aVmN0jRLPIHFExKDaZstnPrPNhcZIqQ8pjr9ile3R0XT4mhOZQxGcvupYcX9kDCloZb6qRmOqf1JSqCVsh3IZCihAsgjzoZ5LhcMZJ7l)(yLda3jYl1cM1dkA9oWlZjLYbmIA46HmpvpyKdywAQj9P8HXFKjiaeFbohdp4V58yj8RahHGc1t5dJ)itqaogLgNq9idfQNYhg)rMy6ljGYXnbi3rFKXmUHgDdineqAOjNe6lByWB45pMZJgM5CDIBZjne75MnKEahPHvodsZJsRVSHuKLAyI6bosdn5mN58q0hzmJByLda3jYl1INYXRCa4oUgqId8YCsn5mN584aaMutoZzopejajkpp5UOpYyg3WkhaUtKxQf375GmUE15bamPg(fiHpMZdHjN5mNhIeGeLNNCO9cjFbs4J58qyYzoZ5Ha4YXWxyqFKXmUHvoaCNiVuliJruZZ7aaM0khaMdF(mbJi1UKmN58YdbZ5X9LVyErRxsYt5dJ)itqai(cCogEWFZ5Xs4xbocrmgrbopx6aVmNulnsc6F5RmaTMZtXn4jbd8lFvpcXhH0hzCdrZMu6kgPHaheGs3ql1CEkUbpjAizmIAEEneJ)nKaCe9KDupYIgkFdzbi(crFSYbG7e5LAbTMZtXn4jXbAGp8CsQDzoaGjnaMdDOjjvoamh(8zcgrQDjpLpm(JmbbG4lW5y4b)nNhlHFf4ieXyef48CjjgIEzoZ5LhcMZJ7lFuOYCUoXT5IF5R6ri(ieXpZc4e0jfjNmOpY4gIMnP0vmsdboiaLUHO)LVQhH4JqAizmIAEEneJ)nKaCe9KDupYIgkFdTcZJ7l)gkFdzbi(crFSYbG7e5LAXV8v9ieFeYbAGp8CsQDzoaGjnaMdDOjjvoamh(8zcgrQDjzoZ5LhcMZJ7lFX8IwVKKNYhg)rMGaq8f4Cm8G)MZJLWVcCeIymIcCEUKKZFmf0Aopf3GNe9rgZ4gw5aWDI8sTGmgrnpVdaysRCayo85ZemIu7sqVmN58YdbZ5X9LVyErRxsYt5dJ)itqai(cCogEWFZ5Xs4xbocrmgrbopx6aVmNulnscdExpYyaAnNNIBWtcg4EphKXZ31JS(iJBiA2KsxXine4Gau6gI(UNdYnKHwD2q5AidExpYAizmIAEEneJ)nKaCe9KDupYIgkFdDUlBRW84(YVHY3qwaIVq0hRCa4orEPwCVNdY46vNhOb(WZjP2L5aaMuYIa4ieX9EoiJNVRhzscG5q3fsQCayo85ZemIu7sqVmN58YdbZ5X9LVyErRxsYt5dJ)itqai(cCogEWFZ5Xs4xbocrmgrbopxsY5pMcAnNNIBWtcjzoxN42Cr(UEKj(zwaNGozex0hzCdrZMu6kgPHaheGs3q039CqUHm0QZgkxdzW76rwdjJruZZRHy8VHeGJONSJ6rw0q5BOZDzBfMh3x(nu(gYcq8fI(yLda3jYl1I8D9i7anWhEoj1UmhaWKsweahHiU3Zbz88D9itsamh6UqsLdaZHpFMGrKAxc6L5mNxEiyopUV8fZlA9ssEkFy8hzccaXxGZXWd(Bopwc)kWriIXikW55sso)XuCVNdY46vN9XkhaUtKxQfN8aW9(yLda3jYl1IVmplKDaatAMZ1jUnx8lFvpcXhHi(zwaNGoRkjk98q8lFvpcbVOlpXDX8IwVuFSYbG7e5LArM7mIAp)j40L77paGjLMcdt8lFvpcXhHisCBUK0OPWWeeWqg9V66ErIBZrHcdGCh4)mlGtq3fY0hRCa4orEPw8lFvpcXhHCaat6t5dJ)itqaogLgNq9itcsoj(zwaNivgjgYSEqrRNyYAzQy4N3fzOqzyupYcramhEWXpZbUvVqogwgjrPNhIYr2JBwEHmZ5bkur9ilebWC4bh)mh4w9c5ouzKGErPNhIYr2JBwEHmZ5HbgiXqY50A8OEKfeHTBWRTb8Ku7OqrtHHjmxf4z9kM7fuNg0hRCa4orEPw8lFvpcXhHCaat6t5dJ)itm9Leq54MaK7qcsoj(zwaNivgjgM5CDIBZfKZvpohdNUibG7IFMfWjO7cuOYCUoXT5cY5QhNJHtxKaWDXpZc4e5qRmgiXqdPPWWe0AopPPiHG6efQO0Zdr5i7XnlVqM58qmVO1lHc1xGe(yopevkreaxo7Yyakur9ilebWC4bhpbMC2LrguOywpOO1tmzTmvm8Z7ImuOI6rwicG5WdoEcm0z)cjFbs4J58quPeraC5SlJbsmKCoTgpQhzbry7g8ABapj1oku0uyycZvbEwVI5Eb1Pb9XkhaUtKxQf)Yx1Jq8rihaWKIEmRhu06jOCaJOgUEiZt1dgrcsoj(zwaNivgjgAinfgMGwZ5jnfjeuNOqfLEEikhzpUz5fYmNhI5fTEjuO(cKWhZ5HOsjIa4YzxgdqHkQhzHiaMdp44jWKZUmYGcfZ6bfTEIjRLPIHFExKHcvupYcramhEWXtGHo7xi5lqcFmNhIkLicGlNDzmqIHKZP14r9ilicB3GxBd4jP2rHIMcdtyUkWZ6vm3lOonOpw5aWDI8sT4x(QEeIpc5akYW5yy4i5Ku7haWK(u(W4pYeeaIVaNJHh83CESe(vGJqeJruGZZLKC(JjosojSl(Y8SqMednKMcdtqR58KMIecQtuOIsppeLJSh3S8czMZdX8IwVekuFbs4J58quPeraC5SlJbOqf1JSqeaZHhC8eyYzxgzqHIz9GIwpXK1YuXWpVlYqHkQhzHiaMdp44jWqN9lK8fiHpMZdrLsebWLZUmgiXqY50A8OEKfeHTBWRTb8Ku7OqrtHHjmxf4z9kM7fuNg0hRCa4orEPwy7g8ABapDaatQEmNwoREiKyi5CAnEupYcIW2n412aEso7sqpAkmmH5QapRxXCVG6efQVaj8XCEiQuIiao6qYjjOhnfgMWCvGN1RyUxqDAqFSYbG7e5LAbfz4GyMK(yLda3jYl1cAnNNWXO(l7JvoaCNiVulO3t2Ff4ihaWKstHHj(LVQhH4JqeuN9XkhaUtKxQfAaYDqWTYrLqmNhhaWKstHHj(LVQhH4JqejUnxsA0uyyccyiJ(xDDViXT59XkhaUtKxQfyGF0Aop1hRCa4orEPwuEEK4lnEU06(yLda3jYl1c6cbNJHhpiFLCaatknfgM4x(QEeIpcrK42CjPrtHHjiGHm6F119Ie3MlHMcdtm)lKjOo7JvoaCNiVulEkhVYbG74AajoGepihsTFGxMtAX3bamPKZP14r9ilicB3GxBd4j5S3hRCa4orEPw8uoELda3X1asCGxMtkb4i6Hh1JSOp2hRCa4oru8jnxEEACAkmSd8YCsP1vAKG)MhaWKIKtIFMfWjsLrcHtPPbEsGbEsGtIhCDsOPWWeyGNe4K4bxN4NzbCIeAkmmX8VqM4NzbCc6qYP(yLda3jIIp5LAr5zW8aVWI9KBE(6bamP0uyyI5FHmb1PKmNRtCBU4x(QEeIpcr8ZSaorUl6JvoaCNik(KxQfKZvpohdNUibG7haWKstHHjM)fYeuNs(czOJHLPpw5aWDIO4tEPwqRR0ib)npa4X(N6mWbysrYjXpZc4ePYiHWP00apjWapjWjXdUoj0uyycmWtcCs8GRt8ZSaorcnfgMy(xit8ZSaobDi50bamP0uyyI5FHmb1PeY50A8OEKfeHTBWRTb8KCOTpw5aWDIO4tEPwK5EAM(bamPgstHHjM)fYeuNOqrtHHj(LVQhH4JqeuNsEkFy8hzccWXO04eQhzgiHz9GIwpXK1YuXWpVlY6JvoaCNik(KxQfeWqg9V66((yLda3jIIp5LAXxMNfY6JvoaCNik(KxQfKZvpohdNUibG7haWKstHHjM)fYeuNsYCUoXT5IF5R6ri(ieXpZc4e5UOpw5aWDIO4tEPwqRR0ib)npaGjLMcdtm)lKj(zwaNihsoD4cTIl6JvoaCNik(KxQfmb5G)xI)uK7(yLda3jIIp5LAbW8CEc4i4mb5G)x2h7JvoaCNiiahrp8OEKfYl1IVqaocoTMB7aaM0NYhg)rMWgqRX5y4X9WP3t2FDVymIcCEUKeAkmmHnGwJZXWJ7HtVNS)6EXpZc4e0HKt9XkhaUteeGJOhEupYc5LAr(Pi3ahbNwZTDaat6t5dJ)itydO14Cm84E407j7VUxmgrbopxscnfgMWgqRX5y4X9WP3t2FDV4NzbCc6qYP(yLda3jccWr0dpQhzH8sTixEEACAkmSd8YCsP1vAKG)MhaWKsoNwJh1JSGiSDdETnGNKAxcsoj(zwaNivgjggLEEimlcPY)eZlA9sOqL5mNxEiyopUV8fZlA9sgiHz9GIwpXK1YuXWpVlYKy4xitoROmOqHEzoxN42CrM7Pz6IFMfWjg0hRCa4orqaoIE4r9ilKxQfzUNMPFaatQH0uyyI5FHmb1jku0uyyIF5R6ri(ieb1PKNYhg)rMGaCmknoH6rMbsywpOO1tmzTmvm8Z7IS(yLda3jccWr0dpQhzH8sTiZ90m9daysPPWWeZ)czcQtjmRhu06jMSwMkg(5DrwFSYbG7ebb4i6Hh1JSqEPwqadz0)QR7paGjnnAkmmbbmKr)RUUxK42CjgsoNwJh1JSGiSDdETnGNKZokuFbs4J58quPeraC5SFHb9XkhaUteeGJOhEupYc5LAXxMNfYoaGj1qAkmmXV8v9ieFeIG6efkAkmmH5m5)L4CmCnvgKWt)ktIG60auOmKMcdtm)lKj(zwaNGoKCcfQVqMCwrzmafkAkmmb2p3k7LIFMfWjOZU4I(yLda3jccWr0dpQhzH8sTiZ90m9(yLda3jccWr0dpQhzH8sTO8myEGxyXEYnpF9aaMuAkmmX8VqMG6uIHKZP14r9ilicB3GxBd4j5SJc1xGe(yopevkreaxUd9cd6JvoaCNiiahrp8OEKfYl1cY5QhNJHtxKaW9daysPPWWeZ)czcQtjgsoNwJh1JSGiSDdETnGNKZokuFbs4J58quPeraC5y4lmOpw5aWDIGaCe9WJ6rwiVulMSwMkwFSYbG7ebb4i6Hh1JSqEPwqRR0ib)npaGjLMcdtm)lKjOoLyi6rtHHj(LVQhH4Jqe)mlGtqH6lKHUlKXajgsoNwJh1JSGiSDdETnGNKAxYxGe(yopevkreaxog(cuOiNtRXJ6rwqe2UbV2gWtsrRb9XkhaUteeGJOhEupYc5LAbTMZtXn4jXbamP0uyyI5FHmrIBZrHkZ9efiembzaNIGN5EmZZq8LFvUlKe1JSqCVsh3IZCGoRErFSYbG7ebb4i6Hh1JSqEPwqR58eDf3haWKstHHjM)fYejUnhfQm3tuGqWeKbCkcEM7XmpdXx(v5UqsupYcX9kDCloZb6S6fsqVO0Zdr(PMoUumVO1l1hRCa4orqaoIE4r9ilKxQfPVq4o(ZR)aaMuAkmmX8VqMG6uIHKZP14r9ilicB3GxBd4j5SJc1xGe(yopevkreaxo7xyqFSYbG7ebb4i6Hh1JSqEPwWDIUOqUJ(yLda3jccWr0dpQhzH8sTW2n412aE6aaMuAkmmH5(mqpcbNM7d5bEAVG6uc5CAnEupYcIW2n412aEsoR2hRCa4orqaoIE4r9ilKxQfFHaCeCAn32bamP576rgrkArHIMcdt8lFvpcXhHiOoLWSEqrRNyYAzQy4N3fzsIsppeMfHu5FI5fTEP(yLda3jccWr0dpQhzH8sTi)uKBGJGtR52oaGjnFxpYisrlku0uyyIF5R6ri(ieb1PeM1dkA9etwltfd)8Uitsu65HWSiKk)tmVO1l1hRCa4orqaoIE4r9ilKxQf0Aopf3GNe9XkhaUteeGJOhEupYc5LAbTMZt0vC3hRCa4orqaoIE4r9ilKxQfFHaCeCAn3wFSYbG7ebb4i6Hh1JSqEPwKFkYnWrWP1CB9XkhaUteeGJOhEupYc5LAHTBWRTb8KkuHsba]] )


end
