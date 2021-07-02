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


    spec:RegisterPack( "Fury", 20210701.1, [[d4uLkbqiiv5rifTjI0Nubgff0POaRsLqjVIOQzrPQBruPDr4xucdJO4yukldsPNPsW0qk4AQG2gLkX3OuPghKcohLk06qkX8Gu5EeX(ikDqvczHuIEisHMiLkPlcPqBesvHpcPQOrcPQ0jvjuTsvOzIus3KsfvTtku)uLqPgQkHILcPQ6PO0uPqUkLkk2kLk4RuQiJfsr7LK)cvdg0HLSyu8yrMSOUSYMHYNHy0QuNgy1uQOYRvjnBsDBkA3u9BunCv0Xrk1Yv1ZrmDHRJKTJu9DkPXtuX5vjA9uQO08HK9l1kBkJuS5kMYy0kdATjJDlJnbAVWfo02Hk24YZPypR01czkwVmNIf9b1FPI9SUuZRSYiflHt9PPyVJ4KqlwybciUPyejUPfeGjLUca3tFHfwqaMjluSmuaDCXDfJInxXugJwzqRnzSBzSjq7fUanCinOylQ4M)kwwGjn2qlA4f9PBGzaEorXEdY55kgfBEKKIf9b1FzdTt1)a(3hpsPVSH2SVHOvg0ARp2hPX7YrgHw6JYTHxuoVCdVyOmnNw0hLBdTRasXOxUHMC6ZCE0qlAi67Eoi1qAD1zdtLw3qdDE0qFlVCdX4FdbUCrkZ1We3JjNWarFuUn0opN(Yn0sDLhj4Vzdlp3q76xiCVHOFE9nSy40xdTuZ554g8KOHbVHaZZNtFne7hTPMNUSHCSg(lXnnNNRaWDsdnKamjn85ui36lB4OnvPnq0hLBdVOCE5gAzfHEnK9Mtfnm4n88xIBYurdVOlgAv0hLBdVOCE5gAhaPG)x2q0pf5UHfdN(Aib4i6j3OEKfn0oDdETvGNf9r52WlkNxUH2ziRHx8yMerFuUn0iRRU2qm(3q70n41wbEUHmdJ)RH6rF6gEb7w0hLBdr)ZKtF5gIgjK5Pre9r52q7k3piAifznKfmKX8RUUVHaSgcIdinS0)Q8LnK6SHgAxxf3M119gi6JYTHSlOoBiwDDnKmAtnpnsdX4Fdzbi(IgYpNVxOy1asqugPyl(ugPm2MYif78IrVSYsfBLca3vSLNaZd8cl2tU5PRk28iPhCgaURyRua4oru8jjvEAACgkmm79YCsy0vEKG)M2dWKGKYIFMfWjsKrkHtPzaEwGbEsGtIhCDszOWWeyGNe4K4bxN4NzbCIugkmmX8VqM4NzbCc6qszfB6bXEqPyzOWWeZ)czcQZgkTHjoxN5wDXV0v9ieFeI4NzbCsdLTHhQcLXOvzKIDEXOxwzPIn9GypOuSmuyyI5FHmb1zdL2WVqwdrxdPbzuSvkaCxXsox94CmCMIeaURcLXxqzKIDEXOxwzPIn9GypOuSmuyyI5FHmb1zdL2qY50A8OEKfeH1BWRTc8CdLTHOvXwPaWDflJUYJe83uXc8y)tDg4amflskl(zwaNirgPeoLMb4zbg4jbojEW1jLHcdtGbEsGtIhCDIFMfWjszOWWeZ)czIFMfWjOdjLvHYyAqzKIDEXOxwzPIn9GypOuSg2qgkmmX8VqMG6SHOq1qgkmmXV0v9ieFeIG6SHsB4t5dJ)itqaogLgNq9itmVy0l3qdAO0gsVEqXONyYzjQy4N3fzk2kfaURytCpptxfkJpuzKITsbG7kwcyiJ5xDDVIDEXOxwzPkugBxugPyRua4UI9lZZczk25fJEzLLQqzSDRmsXoVy0lRSuXMEqShukwgkmmX8VqMG6SHsByIZ1zUvx8lDvpcXhHi(zwaN0qzB4Hk2kfaURyjNRECogotrca3vHYy0GYif78IrVSYsfB6bXEqPyzOWWeZ)czIFMfWjnu2gIKYn8IvdrR4qfBLca3vSm6kpsWFtvOm2oQmsXwPaWDflDqk4)L4pf5wXoVy0lRSufkJTjJYifBLca3vSaZZ5zGJGthKc(FPIDEXOxwzPkuHILaCe9WJ6rwOmszSnLrk25fJEzLLk20dI9GsX(u(W4pYewbAnohdpUhoZEY(R7fJ2uGZZLBO0gYqHHjSc0ACogECpCM9K9x3l(zwaN0q01qKuwXwPaWDf7xiahbNrZTQcLXOvzKIDEXOxwzPIn9GypOuSpLpm(JmHvGwJZXWJ7HZSNS)6EXOnf48C5gkTHmuyycRaTgNJHh3dNzpz)19IFMfWjneDnejLvSvkaCxX(fcWrWz0CRQqz8fugPyNxm6LvwQytpi2dkfl5CAnEupYcIW6n41wbEUHsAOTgkTHiPS4NzbCsdL0qzAO0gAydJsppeMfHuPFI5fJE5gIcvdtC6Zlpe0Nh3x(n0GgkTH0Rhum6jMCwIkg(5DrwdL2qdB4xiRHY2q7OmnefQgIEnmX56m3QlsCpptx8ZSaoPHgOyRua4UInvEAACgkmmfldfggUxMtXYOR8ib)nvHYyAqzKIDEXOxwzPIn9GypOuSg2qgkmmX8VqMG6SHOq1qgkmmXV0v9ieFeIG6SHsB4t5dJ)itqaogLgNq9itmVy0l3qdAO0gsVEqXONyYzjQy4N3fzk2kfaURytCpptxfkJpuzKIDEXOxwzPIn9GypOuSmuyyI5FHmb1zdL2q61dkg9etolrfd)8UitXwPaWDfBI75z6QqzSDrzKIDEXOxwzPIn9GypOuS5XqHHjiGHmMF119Im3Q3qPn0WgsoNwJh1JSGiSEdETvGNBOSn0wdrHQHFbY4J(8qu5mra8gkBdTDydnqXwPaWDflbmKX8RUUxfkJTBLrk25fJEzLLk20dI9GsXAydzOWWe)sx1Jq8ricQZgIcvdzOWWeMZK)xIZXW1ujqgp)RmjcQZgAqdrHQHg2qgkmmX8VqM4NzbCsdrxdrs5gIcvd)cznu2gAhLPHg0quOAidfgMa7NBN9sXpZc4KgIUgAtCOITsbG7k2VmplKPcLXObLrk2kfaURytCpptxXoVy0lRSufkJTJkJuSZlg9YklvSPhe7bLILHcdtm)lKjOoBO0gAydjNtRXJ6rwqewVbV2kWZnu2gARHOq1WVaz8rFEiQCMiaEdLTH29Hn0afBLca3vSLNaZd8cl2tU5PRQqzSnzugPyNxm6LvwQytpi2dkfldfgMy(xitqD2qPn0WgsoNwJh1JSGiSEdETvGNBOSn0wdrHQHFbY4J(8qu5mra8gkBdPHdBObk2kfaURyjNRECogotrca3vHYyB2ugPyRua4UIDYzjQyk25fJEzLLQqzSn0QmsXoVy0lRSuXMEqShukwgkmmX8VqMG6SHsBOHne9AidfgM4x6QEeIpcr8ZSaoPHOq1WVqwdrxdpuMgAqdL2qdBi5CAnEupYcIW6n41wbEUHsAOTgkTHFbY4J(8qu5mra8gkBdPHdBikunKCoTgpQhzbry9g8ARap3qjneTn0afBLca3vSm6kpsWFtvOm22fugPyNxm6LvwQytpi2dkfldfgMy(xitK5w9gIcvdtCptbcbDqcWPi4jUhZ8meF5xBOSn8WgkTHr9ile3R0XT4mfneDn8chQyRua4UILrZ554g8KqfkJTrdkJuSZlg9YklvSPhe7bLILHcdtm)lKjYCREdrHQHjUNPaHGoib4ue8e3JzEgIV8Rnu2gEydL2WOEKfI7v64wCMIgIUgEHdBO0gIEnmk98qKEQPJlfZlg9Yk2kfaURyz0CEoUbpjuHYyBhQmsXoVy0lRSuXMEqShukwgkmmX8VqMG6SHsBOHnKCoTgpQhzbry9g8ARap3qzBOTgIcvd)cKXh95HOYzIa4nu2gA7WgAGITsbG7k28xiCh)51RcLX2SlkJuSvkaCxXYDIUOqUdf78IrVSYsvOm2MDRmsXoVy0lRSuXMEqShukwgkmmH5(eqpcbNH7d5bEEVG6SHsBi5CAnEupYcIW6n41wbEUHY2WlOyRua4UI16n41wbEwfkJTHgugPyNxm6LvwQytpi2dkfB6UEKrAOKgI2gIcvdzOWWe)sx1Jq8ricQZgkTH0Rhum6jMCwIkg(5DrwdL2WO0ZdHzriv6NyEXOxwXwPaWDf7xiahbNrZTQcLX2SJkJuSZlg9YklvSPhe7bLInDxpYinusdrBdrHQHmuyyIFPR6ri(ieb1zdL2q61dkg9etolrfd)8UiRHsByu65HWSiKk9tmVy0lRyRua4UI9leGJGZO5wvHYy0kJYifBLca3vSmAoph3GNek25fJEzLLQqzmATPmsXwPaWDflJMZZXn4jHIDEXOxwzPkugJw0QmsXwPaWDf7xiahbNrZTQyNxm6LvwQcLXO9ckJuSvkaCxX(fcWrWz0CRk25fJEzLLQqzmAPbLrk2kfaURyTEdETvGNvSZlg9YklvHkuS5Hvu6qzKYyBkJuSZlg9YklvSvkaCxXMURhzk28iPhCgaURyPX76rwdbyn06o4xd1ChPHNfjAiN6Bi)C(E7Bi)BO11Wm3piAOVLByCVgYpNVVHjUjdVHy8VHSaeFrdn05UCTdZJ7lFdek20dI9GsXgaZ1qzBiAOHOq1WO0ZdrMtXOhEamNyEXOxUHOq1Wkfa6dF(mbJ0qzBOTgIcvdtC6Zlpe0Nh3x(nefQgIEn8P8HXFKjiaeFbohdp4V58yz8RahHigTPaNNl3quOAyIZ1zUvx8lDvpcXhHi(zwaN0qzBiskRcLXOvzKITsbG7k2tktZPvSZlg9YklvHY4lOmsXoVy0lRSuXYpvSKfk2kfaURyPxpOy0tXsV0utXgLEEimlcPs)eZlg9YnuAdJ6rwiUxPJBXzkAi6A4foSHOq1WOEKfI7v64wCMIgIUgIwzAikunmQhzH4ELoUfNPOHY2q0GmnuAdtC6Zlpe0Nh3x(kw61J7L5uStolrfd)8UitfkJPbLrk25fJEzLLkw(PILSqXwPaWDfl96bfJEkw6LMAk2NYhg)rMGaq8f4Cm8G)MZJLXVcCeIyEXOxUHOq1WNYhg)rMGaCmknoH6rMyEXOxUHOq1WNYhg)rMy6ljGYXnbi3HyEXOxwXsVECVmNILYb0MA46HmpxpyevOm(qLrk25fJEzLLk2kfaURyz0CEoUbpjuSAGp8uwXAtgfB6bXEqPydG5Ai6AiAOHsByLca9HpFMGrAOKgARHsB4t5dJ)itqai(cCogEWFZ5XY4xbocrmAtbopxUHsBOHne9AyItFE5HG(84(YVHOq1WeNRZCRU4x6QEeIpcr8ZSaoPHOtsdrs5gAGInps6bNbG7kw0OjLUIrAiWbbO0n0snNNJBWtIgsgTPMNwdX4Fdjahrp5g1JSOHY3qwaIVqOcLX2fLrk25fJEzLLk2kfaURy)LUQhH4JquSAGp8uwXAtgfB6bXEqPydG5Ai6AiAOHsByLca9HpFMGrAOKgARHsByItFE5HG(84(YVHsB4t5dJ)itqai(cCogEWFZ5XY4xbocrmAtbopxUHsB45p6cgnNNJBWtcfBEK0doda3vSOrtkDfJ0qGdcqPBi6FPR6ri(iKgsgTPMNwdX4Fdjahrp5g1JSOHY3q7W84(YVHY3qwaIVqOcLX2TYif78IrVSYsfBLca3vS375GeUE1PIvd8HNYkwBYOytpi2dkflzraCeI4EphKWt31JSgkTHbWCneDn8WgkTHvka0h(8zcgPHsAOTgkTHOxdtC6Zlpe0Nh3x(nuAdFkFy8hzccaXxGZXWd(Bopwg)kWriIrBkW55YnuAdp)rxWO58CCdEs0qPnmX56m3Qls31JmXpZc4KgIUgkJ4qfBEK0doda3vSOrtkDfJ0qGdcqPBi67Eoi1qAD1zdLTH04D9iRHKrBQ5P1qm(3qcWr0tUr9ilAO8n05UCTdZJ7l)gkFdzbi(cHkugJgugPyNxm6LvwQyRua4UInDxpYuSAGp8uwXAtgfB6bXEqPyjlcGJqe375GeE6UEK1qPnmaMRHORHh2qPnSsbG(WNptWinusdT1qPne9AyItFE5HG(84(YVHsB4t5dJ)itqai(cCogEWFZ5XY4xbocrmAtbopxUHsB45p6I79CqcxV6uXMhj9GZaWDflA0KsxXine4Gau6gI(UNdsnKwxD2qzBinExpYAiz0MAEAneJ)nKaCe9KBupYIgkFdDUlx7W84(YVHY3qwaIVqOcLX2rLrk2kfaURyp5bG7k25fJEzLLQqzSnzugPyNxm6LvwQytpi2dkfBIZ1zUvx8lDvpcXhHi(zwaN0q01Wl0qPnmk98q8lDvpcbVykpZDX8IrVSITsbG7k2VmplKPcLX2SPmsXoVy0lRSuXMEqShukwgkmmXV0v9ieFeIiZT6nuAdZJHcdtqadzm)QR7fzUvVHOq1qmaYDG)ZSaoPHORHhkJITsbG7k2e3Pn1E(tWzk33RcLX2qRYif78IrVSYsfB6bXEqPyFkFy8hzccWXO04eQhzI5fJE5gkTHiPS4NzbCsdL0qzAO0gAydPxpOy0tm5Sevm8Z7ISgIcvdnSHr9ilebWC4bh)mf4x4WgkBdPbzAO0ggLEEikhzpUz5fYmNhI5fJE5gIcvdJ6rwicG5Wdo(zkWVWHnu2gA3Y0qPne9Ayu65HOCK94MLxiZCEiMxm6LBObn0GgkTHg2qY50A8OEKfeH1BWRTc8CdL0qBnefQgYqHHjmxf4j9k67fuNn0afBLca3vS)sx1Jq8riQqzSTlOmsXoVy0lRSuXMEqShuk2NYhg)rMy6ljGYXnbi3HyEXOxUHsBiskl(zwaN0qjnuMgkTHg2WeNRZCRUGCU6X5y4mfjaCx8ZSaoPHORHh2quOAyIZ1zUvxqox94CmCMIeaUl(zwaN0qzBiALPHg0qPn0WgAydzOWWemAopRPiHG6SHOq1WO0Zdr5i7XnlVqM58qmVy0l3quOA4xGm(OppevoteaVHY2qBY0qdAikunmQhzHiaMdp44zWAOSn0MmY0quOAi96bfJEIjNLOIHFExK1quOAyupYcramhEWXZG1q01qBh2qPn8lqgF0NhIkNjcG3qzBOnzAObnuAdnSHKZP14r9ilicR3GxBf45gkPH2AikunKHcdtyUkWt6v03lOoBObk2kfaURy)LUQhH4JquHYyB0GYif78IrVSYsfB6bXEqPyrVgsVEqXONGYb0MA46HmpxpyKgkTHiPS4NzbCsdL0qzAO0gAydnSHmuyycgnNN1uKqqD2quOAyu65HOCK94MLxiZCEiMxm6LBikun8lqgF0NhIkNjcG3qzBOnzAObnefQgg1JSqeaZHhC8mynu2gAtgzAikunKE9GIrpXKZsuXWpVlYAikunmQhzHiaMdp44zWAi6AOTdBO0g(fiJp6ZdrLZebWBOSn0Mmn0GgkTHg2qY50A8OEKfeH1BWRTc8CdL0qBnefQgYqHHjmxf4j9k67fuNn0afBLca3vS)sx1Jq8riQqzSTdvgPyNxm6LvwQytpi2dkf7t5dJ)itqai(cCogEWFZ5XY4xbocrmAtbopxUHsB45p64iPSWM4lZZcznuAdnSHg2qgkmmbJMZZAksiOoBikunmk98quoYECZYlKzopeZlg9YnefQg(fiJp6ZdrLZebWBOSn0Mmn0GgIcvdJ6rwicG5WdoEgSgkBdTjJmnefQgsVEqXONyYzjQy4N3fznefQgg1JSqeaZHhC8myneDn02HnuAd)cKXh95HOYzIa4nu2gAtMgAqdL2qdBi5CAnEupYcIW6n41wbEUHsAOTgIcvdzOWWeMRc8KEf99cQZgAGITsbG7k2FPR6ri(ieflfz4CmmCKuwzSnvOm2MDrzKIDEXOxwzPIn9GypOuS6rF6gkBdVGDPHsBOHnKCoTgpQhzbry9g8ARap3qzBOTgkTHOxdzOWWeMRc8KEf99cQZgIcvd)cKXh95HOYzIa4neDnejLBO0gIEnKHcdtyUkWt6v03lOoBObk2kfaURyTEdETvGNvHYyB2TYifBLca3vSuKHdIzsuSZlg9YklvHYyBObLrk2kfaURyz0CEghJ6VuXoVy0lRSufkJTzhvgPyNxm6LvwQytpi2dkfldfgM4x6QEeIpcrqDQyRua4UILzpz)vGJOcLXOvgLrk25fJEzLLk20dI9GsXYqHHj(LUQhH4JqezUvVHsByEmuyyccyiJ5xDDViZT6k2kfaURy1aK7GGBNJkJyopuHYy0AtzKITsbG7kwmWpgnNNvSZlg9YklvHYy0IwLrk2kfaURylpns8LgpvATIDEXOxwzPkugJ2lOmsXoVy0lRSuXMEqShukwgkmmXV0v9ieFeIiZT6nuAdZJHcdtqadzm)QR7fzUvVHsBidfgMy(xitqDQyRua4UILPqW5y4XdsxjQqzmAPbLrk25fJEzLLkws8GuOm2MITsbG7k2NYXRua4oUgqcfB6bXEqPyjNtRXJ6rwqewVbV2kWZnu2gAtfkJr7HkJuSZlg9YklvSvkaCxX(uoELca3X1asOy1asG7L5uSeGJOhEupYcvOcf75Ve3KPcLrkJTPmsXwPaWDfltfHE4KBovOyNxm6LvwQcLXOvzKIDEXOxwzPIn9GypOuSOxdFkFy8hzccaXxGZXWd(Bopwg)kWriIrBkW55Yk2kfaURy)LUQhH4JquHkuHIL(EcG7kJrRmO1Mm2Tm2uSwR3bocrXANUi0VXxCJrFslnSHgDVgcmp5F0qm(3Wdk(oOH)Onf4xUHeU5AyrfCZkwUHP7Yrgr0hPvGVgsd0sdPrUtFFSCdp4P8HXFKjqZdAyWB4bpLpm(JmbAkMxm6LpOHgAtogi6J9r70fH(n(IBm6tAPHn0O71qG5j)JgIX)gEab4i6Hh1JS4Gg(J2uGF5gs4MRHfvWnRy5gMUlhzerFKwb(A4fOLgsJCN((y5gEqItFE5HanfZlg9Yh0WG3WdsC6ZlpeO5bn0qBYXarFKwb(AinqlnKg5o99XYn8GNYhg)rManpOHbVHh8u(W4pYeOPyEXOx(GgAOn5yGOp2hTtxe634lUXOpPLg2qJUxdbMN8pAig)B4b5Hvu64Gg(J2uGF5gs4MRHfvWnRy5gMUlhzerFKwb(A4fOLgsJCN((y5gEqu65HanpOHbVHheLEEiqtX8IrV8bn0qBYXarFKwb(AinqlnKg5o99XYn8GNYhg)rManpOHbVHh8u(W4pYeOPyEXOx(GgAOn5yGOpsRaFnKgOLgsJCN((y5gEWt5dJ)itGMh0WG3WdEkFy8hzc0umVy0lFqdROHOXl20Adn0MCmq0hPvGVgsd0sdPrUtFFSCdp4P8HXFKjqZdAyWB4bpLpm(JmbAkMxm6LpOHgAtogi6J0kWxdTl0sdPrUtFFSCdpiXPpV8qGMI5fJE5dAyWB4bjo95Lhc08GgAOn5yGOpsRaFn0UPLgsJCN((y5gEqItFE5HanfZlg9Yh0WG3WdsC6ZlpeO5bn0qBYXarFKwb(AiAGwAinYD67JLB4bjo95Lhc0umVy0lFqddEdpiXPpV8qGMh0qdTjhde9rAf4RH2qlT0qAK703hl3WdIsppeO5bnm4n8GO0ZdbAkMxm6LpOHgIw5yGOpsRaFn0gAPLgsJCN((y5gEWt5dJ)itGMh0WG3WdEkFy8hzc0umVy0lFqdn0MCmq0hPvGVgA7c0sdPrUtFFSCdp4P8HXFKjqZdAyWB4bpLpm(JmbAkMxm6LpOHgAtogi6J9XlU5j)JLBin0WkfaU3qnGeerFuXsoxszSDJwf75ZXa6PyPjnBi6dQ)YgANQ)b8VpstA2WJu6lBOn7BiALbT26J9rAsZgsJ3LJmcT0hPjnBOCB4fLZl3WlgktZPf9rAsZgk3gAxbKIrVCdn50N58OHw0q039CqQH06QZgMkTUHg68OH(wE5gIX)gcC5IuMRHjUhtoHbI(inPzdLBdTZZPVCdTux5rc(B2WYZn0U(fc3Bi6NxFdlgo91ql1CEoUbpjAyWBiW8850xdX(rBQ5PlBihRH)sCtZ55kaCN0qdjatsdFofYT(YgoAtvAde9rAsZgk3gEr58Yn0Ykc9Ai7nNkAyWB45Ve3KPIgErxm0QOpstA2q52WlkNxUH2bqk4)Lne9trUByXWPVgsaoIEYnQhzrdTt3GxBf4zrFKM0SHYTHxuoVCdTZqwdV4XmjI(inPzdLBdnY6QRneJ)n0oDdETvGNBiZW4)AOE0NUHxWUf9rAsZgk3gI(NjN(YnensiZtJi6J0KMnuUn0UY9dIgsrwdzbdzm)QR7BiaRHG4asdl9VkFzdPoBOH21vXTzDDVbI(inPzdLBdzxqD2qS66Aiz0MAEAKgIX)gYcq8fnKFoFVOp2hPjnBiAuolrfl3qMHX)1We3KPIgYmeGten8IsPDgKg6CxU31BIrPByLca3jnK76lf9XkfaUteN)sCtMkKxIfmve6HtU5urFSsbG7eX5Ve3KPc5LyXV0v9ieFeI9amjO3t5dJ)itqai(cCogEWFZ5XY4xbocrmAtbopxUp2hPjnBiAuolrfl3WrF)LnmaMRHX9AyLc(3qaPHf9cOlg9e9rA2qA8UEK1qawdTUd(1qn3rA4zrIgYP(gYpNV3(gY)gADnmZ9dIg6B5gg3RH8Z57ByIBYWBig)BilaXx0qdDUlx7W84(Y3arFSsbG7ejP76rM9amjbWCYIgqHkk98qK5um6HhaZjMxm6LrHQsbG(WNptWiYAdfQeN(8Ydb95X9LpkuO3t5dJ)itqai(cCogEWFZ5XY4xbocrmAtbopxgfQeNRZCRU4x6QEeIpcr8ZSaorwKuUpwPaWDI8sS4KY0C6(yLca3jYlXc61dkg9S3lZjzYzjQy4N3fz2tV0utsu65HWSiKk9tAupYcX9kDClotb6UWHOqf1JSqCVsh3IZuGo0kdkur9ile3R0XT4mfYIgKrAItFE5HG(84(YVpwPaWDI8sSGE9GIrp79YCsOCaTPgUEiZZ1dgXE6LMAsEkFy8hzccaXxGZXWd(Bopwg)kWriOq9u(W4pYeeGJrPXjupYqH6P8HXFKjM(scOCCtaYD0hPjnBOr3asdbKgAYjH(Ygg8gE(J(8OHjoxN5wDsdXEUzdzgWrAyLsG88O06lBifz5gMPEGJ0qto9zope9rAsZgwPaWDI8sS4PC8kfaUJRbKWEVmNeto9zopShGjXKtFMZdrgqIYtt2d7J0KMnSsbG7e5LyX9EoiHRxDApatIHFbY4J(8qyYPpZ5Hidir5PjlApu6xGm(OppeMC6ZCEiaUS0WHg0hPjnByLca3jYlXcYOn180ShGjPsbG(WNptWisSjnXPpV8qqFECF5lMxm6LL(u(W4pYeeaIVaNJHh83CESm(vGJqeJ2uGZZLT3lZjXsJKI(x6kTWO58CCdEsql)sx1Jq8ri9rA2q0OjLUIrAiWbbO0n0snNNJBWtIgsgTPMNwdX4Fdjahrp5g1JSOHY3qwaIVq0hRua4orEjwWO58CCdEsyVg4dpLLytg7byscG5qhAqALca9HpFMGrKyt6t5dJ)itqai(cCogEWFZ5XY4xbocrmAtbopxwQHOxItFE5HG(84(YhfQeNRZCRU4x6QEeIpcr8ZSaobDsqszd6J0SHOrtkDfJ0qGdcqPBi6FPR6ri(iKgsgTPMNwdX4Fdjahrp5g1JSOHY3q7W84(YVHY3qwaIVq0hRua4orEjw8lDvpcXhHyVg4dpLLytg7byscG5qhAqALca9HpFMGrKytAItFE5HG(84(YxmVy0ll9P8HXFKjiaeFbohdp4V58yz8RahHigTPaNNll98hDbJMZZXn4jrFKM0SHvkaCNiVeliJ2uZtZEaMKkfa6dF(mbJiXMu0lXPpV8qqFECF5lMxm6LL(u(W4pYeeaIVaNJHh83CESm(vGJqeJ2uGZZLT3lZjXsJKsJ31JmAHrZ554g8KGwU3Zbj80D9iRpsZgIgnP0vmsdboiaLUHOV75GudP1vNnu2gsJ31JSgsgTPMNwdX4Fdjahrp5g1JSOHY3qN7Y1ompUV8BO8nKfG4le9XkfaUtKxIf375GeUE1P9AGp8uwInzShGjHSiaocrCVNds4P76rM0ayo0DO0kfa6dF(mbJiXMu0lXPpV8qqFECF5lMxm6LL(u(W4pYeeaIVaNJHh83CESm(vGJqeJ2uGZZLLE(JUGrZ554g8KqAIZ1zUvxKURhzIFMfWjOtgXH9rA2q0OjLUIrAiWbbO0ne9DphKAiTU6SHY2qA8UEK1qYOn180Aig)Bib4i6j3OEKfnu(g6CxU2H5X9LFdLVHSaeFHOpwPaWDI8sSiDxpYSxd8HNYsSjJ9amjKfbWriI79CqcpDxpYKgaZHUdLwPaqF4ZNjyej2KIEjo95Lhc6ZJ7lFX8IrVS0NYhg)rMGaq8f4Cm8G)MZJLXVcCeIy0McCEUS0ZF0f375GeUE1zFSsbG7e5LyXjpaCVpwPaWDI8sS4lZZcz2dWKK4CDMB1f)sx1Jq8riIFMfWjO7csJsppe)sx1JqWlMYZCxmVy0l3hRua4orEjwK4oTP2ZFcot5(E7bysyOWWe)sx1Jq8riIm3QlnpgkmmbbmKX8RUUxK5wDuOWai3b(pZc4e0DOm9XkfaUtKxIf)sx1Jq8ri2dWK8u(W4pYeeGJrPXjupYKIKYIFMfWjsKrQH0Rhum6jMCwIkg(5Drgkugg1JSqeaZHhC8ZuGFHdLLgKrAu65HOCK94MLxiZCEGcvupYcramhEWXptb(fouw7wgPOxu65HOCK94MLxiZCEyGbsnKCoTgpQhzbry9g8ARaplXgkumuyycZvbEsVI(Eb1Pb9XkfaUtKxIf)sx1Jq8ri2dWK8u(W4pYetFjbuoUja5oKIKYIFMfWjsKrQHjoxN5wDb5C1JZXWzksa4U4NzbCc6oefQeNRZCRUGCU6X5y4mfjaCx8ZSaorw0kJbsn0qgkmmbJMZZAksiOorHkk98quoYECZYlKzopeZlg9YOq9fiJp6ZdrLZebWL1MmgGcvupYcramhEWXZGjRnzKbfk61dkg9etolrfd)8UidfQOEKfIayo8GJNbdD2ou6xGm(OppevoteaxwBYyGudjNtRXJ6rwqewVbV2kWZsSHcfdfgMWCvGN0ROVxqDAqFSsbG7e5LyXV0v9ieFeI9amjOh96bfJEckhqBQHRhY8C9GrKIKYIFMfWjsKrQHgYqHHjy0CEwtrcb1jkurPNhIYr2JBwEHmZ5HyEXOxgfQVaz8rFEiQCMiaUS2KXauOI6rwicG5WdoEgmzTjJmOqrVEqXONyYzjQy4N3fzOqf1JSqeaZHhC8myOZ2Hs)cKXh95HOYzIa4YAtgdKAi5CAnEupYcIW6n41wbEwInuOyOWWeMRc8KEf99cQtd6JvkaCNiVel(LUQhH4JqSNImCoggosklXM9amjpLpm(JmbbG4lW5y4b)nNhlJFf4ieXOnf48CzPN)OJJKYcBIVmplKj1qdzOWWemAopRPiHG6efQO0Zdr5i7XnlVqM58qmVy0lJc1xGm(OppevoteaxwBYyakur9ilebWC4bhpdMS2KrguOOxpOy0tm5Sevm8Z7ImuOI6rwicG5WdoEgm0z7qPFbY4J(8qu5mraCzTjJbsnKCoTgpQhzbry9g8ARaplXgkumuyycZvbEsVI(Eb1Pb9XkfaUtKxIfwVbV2kWZ2dWKOh9PL9c2fPgsoNwJh1JSGiSEdETvGNL1Mu0JHcdtyUkWt6v03lOorH6lqgF0NhIkNjcGJoKuwk6XqHHjmxf4j9k67fuNg0hRua4orEjwqrgoiMjPpwPaWDI8sSGrZ5zCmQ)Y(yLca3jYlXcM9K9xboI9amjmuyyIFPR6ri(ieb1zFSsbG7e5LyHgGCheC7CuzeZ5H9amjmuyyIFPR6ri(ierMB1LMhdfgMGagYy(vx3lYCREFSsbG7e5Lybg4hJMZZ9XkfaUtKxIfLNgj(sJNkTUpwPaWDI8sSGPqW5y4Xdsxj2dWKWqHHj(LUQhH4JqezUvxAEmuyyccyiJ5xDDViZT6szOWWeZ)czcQZ(yLca3jYlXINYXRua4oUgqc7jXdsHeB2dWKqoNwJh1JSGiSEdETvGNL1wFSsbG7e5LyXt54vkaChxdiH9EzojeGJOhEupYI(yFKMnSsbG7erXNKu5PPXzOWWS3lZjHrx5rc(BApatcskl(zwaNirgPeoLMb4zbg4jbojEW1jLHcdtGbEsGtIhCDIFMfWjszOWWeZ)czIFMfWjOdjL7JvkaCNik(KxIfLNaZd8cl2tU5PR2dWKWqHHjM)fYeuNstCUoZT6IFPR6ri(ieXpZc4ezpSpwPaWDIO4tEjwqox94CmCMIeaUBpatcdfgMy(xitqDk9lKHoAqM(yLca3jIIp5LybJUYJe830EGh7FQZahGjbjLf)mlGtKiJucNsZa8Sad8KaNep46KYqHHjWapjWjXdUoXpZc4ePmuyyI5FHmXpZc4e0HKY2dWKWqHHjM)fYeuNsjNtRXJ6rwqewVbV2kWZYI2(yLca3jIIp5LyrI75z62dWKyidfgMy(xitqDIcfdfgM4x6QEeIpcrqDk9P8HXFKjiahJsJtOEKzGu61dkg9etolrfd)8UiRpwPaWDIO4tEjwqadzm)QR77JvkaCNik(KxIfFzEwiRpwPaWDIO4tEjwqox94CmCMIeaUBpatcdfgMy(xitqDknX56m3Ql(LUQhH4Jqe)mlGtK9W(yLca3jIIp5LybJUYJe830EaMegkmmX8VqM4NzbCISiP8fl0koSpwPaWDIO4tEjwqhKc(Fj(trU7JvkaCNik(KxIfaZZ5zGJGthKc(FzFSpwPaWDIGaCe9WJ6rwiVel(cb4i4mAUv7bysEkFy8hzcRaTgNJHh3dNzpz)19IrBkW55YszOWWewbAnohdpUhoZEY(R7f)mlGtqhsk3hRua4orqaoIE4r9ilKxIfPNICdCeCgn3Q9amjpLpm(JmHvGwJZXWJ7HZSNS)6EXOnf48CzPmuyycRaTgNJHh3dNzpz)19IFMfWjOdjL7JvkaCNiiahrp8OEKfYlXIu5PPXzOWWS3lZjHrx5rc(BApatc5CAnEupYcIW6n41wbEwInPiPS4NzbCIezKAyu65HWSiKk9tmVy0lJcvItFE5HG(84(YxmVy0lBGu61dkg9etolrfd)8UitQHFHmzTJYGcf6L4CDMB1fjUNNPl(zwaNyqFSsbG7ebb4i6Hh1JSqEjwK4EEMU9amjgYqHHjM)fYeuNOqXqHHj(LUQhH4JqeuNsFkFy8hzccWXO04eQhzgiLE9GIrpXKZsuXWpVlY6JvkaCNiiahrp8OEKfYlXIe3ZZ0ThGjHHcdtm)lKjOoLsVEqXONyYzjQy4N3fz9XkfaUteeGJOhEupYc5LybbmKX8RUU3EaMK8yOWWeeWqgZV66ErMB1LAi5CAnEupYcIW6n41wbEwwBOq9fiJp6ZdrLZebWL12Hg0hRua4orqaoIE4r9ilKxIfFzEwiZEaMedzOWWe)sx1Jq8ricQtuOyOWWeMZK)xIZXW1ujqgp)RmjcQtdqHYqgkmmX8VqM4NzbCc6qszuO(czYAhLXauOyOWWey)C7Sxk(zwaNGoBId7JvkaCNiiahrp8OEKfYlXIe3ZZ07JvkaCNiiahrp8OEKfYlXIYtG5bEHf7j380v7bysyOWWeZ)czcQtPgsoNwJh1JSGiSEdETvGNL1gkuFbY4J(8qu5mraCzT7dnOpwPaWDIGaCe9WJ6rwiVeliNRECogotrca3ThGjHHcdtm)lKjOoLAi5CAnEupYcIW6n41wbEwwBOq9fiJp6ZdrLZebWLLgo0G(yLca3jccWr0dpQhzH8sSyYzjQy9XkfaUteeGJOhEupYc5LybJUYJe830EaMegkmmX8VqMG6uQHOhdfgM4x6QEeIpcr8ZSaobfQVqg6ougdKAi5CAnEupYcIW6n41wbEwInPFbY4J(8qu5mraCzPHdrHICoTgpQhzbry9g8ARaplbTg0hRua4orqaoIE4r9ilKxIfmAoph3GNe2dWKWqHHjM)fYezUvhfQe3ZuGqqhKaCkcEI7XmpdXx(vzpuAupYcX9kDClotb6UWH9XkfaUteeGJOhEupYc5LybJMZZmvCBpatcdfgMy(xitK5wDuOsCptbcbDqcWPi4jUhZ8meF5xL9qPr9ile3R0XT4mfO7chkf9IsppePNA64sX8IrVCFSsbG7ebb4i6Hh1JSqEjwK)cH74pVE7bysyOWWeZ)czcQtPgsoNwJh1JSGiSEdETvGNL1gkuFbY4J(8qu5mraCzTDOb9XkfaUteeGJOhEupYc5Lyb3j6Ic5o6JvkaCNiiahrp8OEKfYlXcR3GxBf4z7bysyOWWeM7ta9ieCgUpKh459cQtPKZP14r9ilicR3GxBf4zzVqFSsbG7ebb4i6Hh1JSqEjw8fcWrWz0CR2dWKKURhzejOffkgkmmXV0v9ieFeIG6uk96bfJEIjNLOIHFExKjnk98qywesL(jMxm6L7JvkaCNiiahrp8OEKfYlXI0trUbocoJMB1EaMK0D9iJibTOqXqHHj(LUQhH4JqeuNsPxpOy0tm5Sevm8Z7ImPrPNhcZIqQ0pX8IrVCFSsbG7ebb4i6Hh1JSqEjwWO58CCdEs0hRua4orqaoIE4r9ilKxIfmAopZuXDFSsbG7ebb4i6Hh1JSqEjw8fcWrWz0CR9XkfaUteeGJOhEupYc5Lyr6Pi3ahbNrZT2hRua4orqaoIE4r9ilKxIfwVbV2kWZQqfkfa]] )


end
