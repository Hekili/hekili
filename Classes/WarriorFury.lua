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


    spec:RegisterPack( "Fury", 20210703.3, [[d4eJkbqiiv5rOq2er8jkrJIOQtrbwfeuKxrbnlvGBruQDr4xusnmIIJrPAzqk9mvqMgkuDniW2OekFtfughLGohLqSouGMhKk3JiTpIkhufuTqkjpefWePeQUieuTrivf(iKQIgjKQsNeckTsvOzIcLBsjKQDsH6NqqrnuiOWsHuv9uuAQuixLsiXwPeWxPeOXcbzVK6Vq1GbDyPwms9yrnzrUSYMHYNvPrdrNgy1ucP8Ai0Sj52u0UP63OA4QOJJcA5Q65iMUW1rY2rrFNsz8eLCEifRNsiP5dj7xYA7AJ0SPoM2y0kdATlZHjZHe2Tq0AH2rGMnqZ50SNDgX(onR3MtZI(G6rJM9SrJI3jTrAwcN6ZtZImItcdAT1xqGKIwK5MwtaMuQoaCp)nwynbyMTwZstbubcRRP1SPoM2y0kdATlZHjZHe2Tq0AHYGwnBtfi5VMLfyYaf06cE4FgjWmapNOzrcsP5AAnBAKSMf9b1JMcAb7)b8VoEKsHMcEOdkiALbT2RJ1rgaz73ryW6OSl4HNslvqeguMMtjQJYUGwCaPPvlvqtoZzopkO1fe9DphKliJT(SG5wPkO8opkOVLwQGy8VGax232CfmZ9yYkmquhLDbTOZzUubTs1Prc(BwW2tf0I)9L7fe9Z7VGnnN5kOvkopfibpjkyWliW885mxbX(XqQ5z0uqowb)L5MMZtDa4oPGYtaMKc(CQlsfAk4yivRmquhLDbp8uAPcAvhHAfKfjNkkyWl45Vm3KUJcE4imymrDu2f8WtPLkOfaKd(JMcI(PiilytZzUcsa(vnzh9FxuqlisWRSb8KOok7cE4P0sf0IczfeHnMjruhLDbnY2Aelig)lOfej4v2aEQG0dJ)RGQXCQcEOdtuhLDbr)ZKZCPcIWjK55re1rzxqlo3TmkifzfKfS7O)1iUVGaScccljfSv)6eAki1zbL3IVoqA2iU3arDu2fKDb1zbXAexbjJHuZZJuqm(xqwW1xuq(589cnRcqcI2inBZN2iTX21gPzN30QL0wPzZpi2dAn7nNe)mBGtkO0cktbLuqcNsrd8Kad8KaNepaXjM30QLkOKcstHHjWapjWjXdqCIFMnWjfusbPPWWeZ)(oXpZg4KcIUcEZjnBNda31S52ZtHttHHPzPPWWW92CAwAvNgj4VPo0gJwTrA25nTAjTvA28dI9GwZstHHjM)9DcQZckPGzoxL42CXVmIQri(ieXpZg4KckxbrGMTZbG7A22ZG5bEJf7ji5ze1H24dPnsZoVPvlPTsZMFqSh0AwAkmmX8VVtqDwqjf877ki6kiJlJMTZbG7AwY56hNJHt3KaWDDOnMX1gPzN30QL0wPzZpi2dAnlnfgMy(33jOolOKcsoNsHh9Fxqe2qcELnGNkOCfeTA2ohaURzPvDAKG)MAwGh7FQZahGPzV5K4NzdCIuzKq4ukAGNeyGNe4K4bioj0uyycmWtcCs8aeN4NzdCIeAkmmX8VVt8ZSbobD3CshAJrG2in78MwTK2knB(bXEqRzLVG0uyyI5FFNG6SGOqvqAkmmXVmIQri(ieb1zbLuWNYhg)VtqaogLcNq93jM30QLkObfusbz2pOPvtmzTmvm8tKnzA2ohaURzZCpntxhAJTyAJ0SDoaCxZsa7o6FnI71SZBA1sAR0H24dtBKMTZbG7A2Vnp770SZBA1sAR0H2yluBKMDEtRwsBLMn)GypO1S0uyyI5FFNG6SGskyMZvjUnx8lJOAeIpcr8ZSboPGYvqeOz7Ca4UMLCU(X5y40njaCxhAJTiAJ0SZBA1sAR0S5he7bTMLMcdtm)77e)mBGtkOCf8MtfeHPcIwbc0SDoaCxZsR60ib)n1Ho0SeGFvdp6)UqBK2y7AJ0SZBA1sAR0S5he7bTM9P8HX)7e2akfohdpqoC69K9iUxmgsbopxQGskinfgMWgqPW5y4bYHtVNShX9IFMnWjfeDf8MtA2ohaURz)(c8loTIBthAJrR2in78MwTK2knB(bXEqRzFkFy8)oHnGsHZXWdKdNEpzpI7fJHuGZZLkOKcstHHjSbukCogEGC407j7rCV4NzdCsbrxbV5KMTZbG7A2VVa)ItR420H24dPnsZoVPvlPTsZMFqSh0AwY5uk8O)7cIWgsWRSb8ubLwq7fusbV5K4NzdCsbLwqzkOKckFbJwnpeMnH05FI5nTAPcIcvbZCMZBpemNhirZxqdkOKcYSFqtRMyYAzQy4NiBYkOKckFb)(UckxbTiYuquOki6vWmNRsCBUiZ90mDXpZg4KcAGMTZbG7A2C75PWPPWW0S0uyy4EBonlTQtJe83uhAJzCTrA25nTAjTvA28dI9GwZkFbPPWWeZ)(ob1zbrHQG0uyyIFzevJq8ricQZckPGpLpm(FNGaCmkfoH6VtmVPvlvqdkOKcYSFqtRMyYAzQy4NiBY0SDoaCxZM5EAMUo0gJaTrA25nTAjTvA28dI9GwZstHHjM)9DcQZckPGm7h00QjMSwMkg(jYMmnBNda31SzUNMPRdTXwmTrA25nTAjTvA28dI9GwZMgnfgMGa2D0)Ae3lsCBEbLuq5li5CkfE0)Dbrydj4v2aEQGYvq7fefQc(niHpMZdrNsebWlOCf0ockObA2ohaURzjGDh9VgX96qB8HPnsZoVPvlPTsZMFqSh0Aw5linfgM4xgr1ieFeIG6SGOqvqAkmmH5m5pAW5y4kQmiHN(1Meb1zbnOGOqvq5linfgMy(33j(z2aNuq0vWBovquOk433vq5kOfrMcAqbrHQG0uyycSFUfv0i(z2aNuq0vq7ceOz7Ca4UM9BZZ(oDOn2c1gPz7Ca4UMnZ90mDn78MwTK2kDOn2IOnsZoVPvlPTsZMFqSh0AwAkmmX8VVtqDwqjfu(csoNsHh9Fxqe2qcELnGNkOCf0EbrHQGFds4J58q0Pera8ckxbpmeuqd0SDoaCxZ2EgmpWBSypbjpJOo0gBxgTrA25nTAjTvA28dI9GwZstHHjM)9DcQZckPGYxqY5uk8O)7cIWgsWRSb8ubLRG2likuf8BqcFmNhIoLicGxq5kiJJGcAGMTZbG7AwY56hNJHt3KaWDDOn2UDTrA2ohaURzNSwMkMMDEtRwsBLo0gBhTAJ0SZBA1sAR0S5he7bTMLMcdtm)77euNfusbLVGOxbPPWWe)YiQgH4Jqe)mBGtkikuf877ki6kicKPGguqjfu(csoNsHh9Fxqe2qcELnGNkO0cAVGsk43Ge(yopeDkreaVGYvqghbfefQcsoNsHh9Fxqe2qcELnGNkO0cI2cAGMTZbG7AwAvNgj4VPo0gB)qAJ0SZBA1sAR0S5he7bTMLMcdtm)77ejUnVGOqvWm3tuGqWeKbCkcEM7XmpdX3oIfuUcIGckPGr)3fcKRvbsXzoki6k4HqGMTZbG7AwAfNNcKGNe6qBSDgxBKMDEtRwsBLMn)GypO1S0uyyI5FFNiXT5fefQcM5EIcecMGmGtrWZCpM5zi(2rSGYvqeuqjfm6)UqGCTkqkoZrbrxbpeckOKcIEfmA18qKFQPc0iM30QL0SDoaCxZsR48uGe8KqhAJTJaTrA25nTAjTvA28dI9GwZstHHjM)9DcQZckPGYxqY5uk8O)7cIWgsWRSb8ubLRG2likuf8BqcFmNhIoLicGxq5kODeuqd0SDoaCxZM((YD8N3Vo0gB3IPnsZ25aWDnl3jQM6Im0SZBA1sAR0H2y7hM2in78MwTK2knB(bXEqRzPPWWeM7Za1ieCAUV7d80Eb1zbLuqY5uk8O)7cIWgsWRSb8ubLRGhsZ25aWDnRnKGxzd4jDOn2UfQnsZoVPvlPTsZMFqSh0A2mY(VJuqPfeTfefQcstHHj(LruncXhHiOolOKcYSFqtRMyYAzQy4NiBYkOKcgTAEimBcPZ)eZBA1sA2ohaURz)(c8loTIBthAJTBr0gPzN30QL0wPzZpi2dAnBgz)3rkO0cI2cIcvbPPWWe)YiQgH4JqeuNfusbz2pOPvtmzTmvm8tKnzfusbJwnpeMnH05FI5nTAjnBNda31SFFb(fNwXTPdTXOvgTrA2ohaURzPvCEkqcEsOzN30QL0wPdTXO1U2inBNda31S0kopfibpj0SZBA1sAR0H2y0IwTrA2ohaURz)(c8loTIBtZoVPvlPTshAJr7H0gPz7Ca4UM97lWV40kUnn78MwTK2kDOngTmU2inBNda31S2qcELnGN0SZBA1sAR0Ho0SPH1uQqBK2y7AJ0SZBA1sAR0SDoaCxZMr2)DA20i5hCgaURzzaK9Fxbbyf02S8xbvC)wWZMefKt9fKFoF)bfK)f02kyI7wgf03sfmqUcYpNVVGzUjnVGy8VGSGRVOGY7Cx2wG5bs08gi0S5he7bTMnaMRGYvqlSGOqvWOvZdrItrRgEamNyEtRwQGOqvWohaMdF(mbJuq5kO9cIcvbZCMZBpemNhirZxquOki6vWNYhg)VtqaxFbohdp4V58yjCeb(LigdPaNNlvquOkyMZvjUnx8lJOAeIpcr8ZSboPGYvWBoPdTXOvBKMTZbG7A2tktZP0SZBA1sAR0H24dPnsZoVPvlPTsZYp1SKfA2ohaURzz2pOPvtZYSvutZgTAEimBcPZ)eZBA1sfusbJ(VleixRcKIZCuq0vWdHGcIcvbJ(VleixRcKIZCuq0vq0ktbrHQGr)3fcKRvbsXzokOCf0cLPGskyMZCE7HG58ajAEnlZ(X92CA2jRLPIHFISjthAJzCTrA25nTAjTvAw(PMLSqZ25aWDnlZ(bnTAAwMTIAA2NYhg)VtqaxFbohdp4V58yjCeb(LiM30QLkikuf8P8HX)7eeGJrPWju)DI5nTAPcIcvbFkFy8)oXuOHaAh3eCrgI5nTAjnlZ(X92CAwkhWqQHR2DEQFWi6qBmc0gPzN30QL0wPz7Ca4UMLwX5Paj4jHMvb8HNtAw7YOzZpi2dAnBamxbrxbTWckPGDoamh(8zcgPGslO9ckPGpLpm(FNGaU(cCogEWFZ5Xs4ic8lrmgsbopxQGskO8fe9kyMZCE7HG58ajA(cIcvbZCUkXT5IFzevJq8riIFMnWjfeDsl4nNkObA20i5hCgaURzr4MuQogPGaheGwvqRuCEkqcEsuqYyi188kig)lib4x1KD0)DrbnSGSGRVqOdTXwmTrA25nTAjTvA2ohaURz)LruncXhHOzvaF45KM1UmA28dI9GwZgaZvq0vqlSGskyNdaZHpFMGrkO0cAVGskyMZCE7HG58ajA(ckPGpLpm(FNGaU(cCogEWFZ5Xs4ic8lrmgsbopxQGsk45pMcAfNNcKGNeA20i5hCgaURzr4MuQogPGaheGwvq0)YiQgH4JqkizmKAEEfeJ)fKa8RAYo6)UOGgwqlW8ajA(cAybzbxFHqhAJpmTrA25nTAjTvA2ohaURzrUNdY4Q1NAwfWhEoPzTlJMn)GypO1SKfbWVebY9CqgpJS)7kOKcgaZvq0vqeuqjfSZbG5WNptWifuAbTxqjfe9kyMZCE7HG58ajA(ckPGpLpm(FNGaU(cCogEWFZ5Xs4ic8lrmgsbopxQGsk45pMcAfNNcKGNefusbZCUkXT5ImY(Vt8ZSboPGORGYiqGMnns(bNbG7AweUjLQJrkiWbbOvfe9DphKliJT(SGYvqgaz)3vqYyi188kig)lib4x1KD0)DrbnSGo3LTfyEGenFbnSGSGRVqOdTXwO2in78MwTK2knBNda31SzK9FNMvb8HNtAw7YOzZpi2dAnlzra8lrGCphKXZi7)UckPGbWCfeDfebfusb7Cayo85ZemsbLwq7fusbrVcM5mN3EiyopqIMVGsk4t5dJ)3jiGRVaNJHh83CESeoIa)seJHuGZZLkOKcE(JPa5EoiJRwFQztJKFWza4UMfHBsP6yKccCqaAvbrF3Zb5cYyRplOCfKbq2)DfKmgsnpVcIX)csa(vnzh9FxuqdlOZDzBbMhirZxqdlil46le6qBSfrBKMTZbG7A2tEa4UMDEtRwsBLo0gBxgTrA25nTAjTvA28dI9GwZM5CvIBZf)YiQgH4Jqe)mBGtki6k4HkOKcgTAEi(LruncbVPBpXDX8MwTKMTZbG7A2Vnp770H2y721gPzN30QL0wPzZpi2dAnlnfgM4xgr1ieFeIiXT5fusbtJMcdtqa7o6FnI7fjUnVGOqvqmWfzG)ZSboPGORGiqgnBNda31SzUZqQ98NGt3UVxhAJTJwTrA25nTAjTvA28dI9GwZ(u(W4)DccWXOu4eQ)oX8MwTubLuWBoj(z2aNuqPfuMckPGYxqM9dAA1etwltfd)eztwbrHQGYxWO)7cramhEWXpZb(HqqbLRGmUmfusbJwnpeTF3JB2EFN58qmVPvlvquOky0)DHiaMdp44N5a)qiOGYvWdtMckPGOxbJwnpeTF3JB2EFN58qmVPvlvqdkObfusbLVGKZPu4r)3feHnKGxzd4PckTG2likufKMcdtyUoWZQ1m3lOolObA2ohaURz)LruncXhHOdTX2pK2in78MwTK2knB(bXEqRzFkFy8)oXuOHaAh3eCrgI5nTAPckPG3Cs8ZSboPGslOmfusbLVGzoxL42Cb5C9JZXWPBsa4U4NzdCsbrxbrqbrHQGzoxL42Cb5C9JZXWPBsa4U4NzdCsbLRGOvMcAqbLuq5lO8fKMcdtqR48KIIecQZcIcvbJwnpeTF3JB2EFN58qmVPvlvquOk43Ge(yopeDkreaVGYvq7Yuqdkikufm6)UqeaZHhC8eyfuUcAxgzkikufKz)GMwnXK1YuXWpr2KvquOky0)DHiaMdp44jWki6kODeuqjf8BqcFmNhIoLicGxq5kODzkObfusbLVGKZPu4r)3feHnKGxzd4PckTG2likufKMcdtyUoWZQ1m3lOolObA2ohaURz)LruncXhHOdTX2zCTrA25nTAjTvA28dI9GwZIEfKz)GMwnbLdyi1Wv7op1pyKckPG3Cs8ZSboPGslOmfusbLVGYxqAkmmbTIZtkksiOolikufmA18q0(DpUz79DMZdX8MwTubrHQGFds4J58q0Pera8ckxbTltbnOGOqvWO)7cramhEWXtGvq5kODzKPGOqvqM9dAA1etwltfd)eztwbrHQGr)3fIayo8GJNaRGORG2rqbLuWVbj8XCEi6uIiaEbLRG2LPGguqjfu(csoNsHh9Fxqe2qcELnGNkO0cAVGOqvqAkmmH56apRwZCVG6SGgOz7Ca4UM9xgr1ieFeIo0gBhbAJ0SZBA1sAR0S5he7bTM9P8HX)7eeW1xGZXWd(BopwchrGFjIXqkW55sfusbp)Xe)Mtc7IVnp77kOKckFbLVG0uyycAfNNuuKqqDwquOky0Q5HO97ECZ277mNhI5nTAPcIcvb)gKWhZ5HOtjIa4fuUcAxMcAqbrHQGr)3fIayo8GJNaRGYvq7YitbrHQGm7h00QjMSwMkg(jYMScIcvbJ(VlebWC4bhpbwbrxbTJGckPGFds4J58q0Pera8ckxbTltbnOGskO8fKCoLcp6)UGiSHe8kBapvqPf0EbrHQG0uyycZ1bEwTM5Eb1zbnqZ25aWDn7VmIQri(ienlfz4Cmm8BoPn2Uo0gB3IPnsZoVPvlPTsZMFqSh0Aw1yovbLRGhYIvqjfu(csoNsHh9Fxqe2qcELnGNkOCf0EbLuq0RG0uyycZ1bEwTM5Eb1zbrHQGFds4J58q0Pera8cIUcEZPckPGOxbPPWWeMRd8SAnZ9cQZcAGMTZbG7AwBibVYgWt6qBS9dtBKMTZbG7AwkYWbXmjA25nTAjTv6qBSDluBKMTZbG7AwAfNNWXOE0OzN30QL0wPdTX2TiAJ0SZBA1sAR0S5he7bTMLMcdt8lJOAeIpcrqDQz7Ca4UMLEpzpIa)QdTXOvgTrA25nTAjTvA28dI9GwZstHHj(LruncXhHisCBEbLuW0OPWWeeWUJ(xJ4ErIBZ1SDoaCxZQaxKbb3Igv6Aop0H2y0AxBKMTZbG7AwmWpAfNN0SZBA1sAR0H2y0IwTrA2ohaURzBpps8Tcp3kLMDEtRwsBLo0gJ2dPnsZoVPvlPTsZMFqSh0AwAkmmXVmIQri(ierIBZlOKcMgnfgMGa2D0)Ae3lsCBEbLuqAkmmX8VVtqDQz7Ca4UMLUV4Cm84bzej6qBmAzCTrA25nTAjTvA28dI9GwZsoNsHh9Fxqe2qcELnGNkOCf0UMLepihAJTRz7Ca4UMn3kfENda3XvasOzvasG7T50SnF6qBmArG2in78MwTK2knBNda31SpLJ35aWDCfGeAwfGe4EBonlb4x1WJ(Vl0Ho0SN)YCt6o0gPn2U2inBNda31S0DeQHtqYPcn78MwTK2kDOngTAJ0SZBA1sAR0S5he7bTMf9k4t5dJ)3jiGRVaNJHh83CESeoIa)seJHuGZZL0SDoaCxZ(lJOAeIpcrh6qhAwM7jaURngTYGw7YCyYCibA1S263b(LOzTGho63yewJrFYGfSGgHCfeyEY)OGy8VGw28zzb)XqkWVubjCZvWMk4MDSubZiB)oIOoYyaFf0odwqgG7m3hlvqljCkfnWtceYYcg8cAjHtPObEsGqI5nTAjllO82LLbI6iJb8vqeWGfKb4oZ9Xsf0YNYhg)VtGqwwWGxqlFkFy8)obcjM30QLSSGYBxwgiQJ1rl4HJ(ngH1y0NmyblOrixbbMN8pkig)lOLeGFvdp6)UWYc(JHuGFPcs4MRGnvWn7yPcMr2(DerDKXa(k4HyWcYaCN5(yPcAzMZCE7HaHeZBA1swwWGxqlZCMZBpeiKLfuE7YYarDKXa(kiJZGfKb4oZ9Xsf0YNYhg)VtGqwwWGxqlFkFy8)obcjM30QLSSGYBxwgiQJ1rl4HJ(ngH1y0NmyblOrixbbMN8pkig)lOLPH1uQWYc(JHuGFPcs4MRGnvWn7yPcMr2(DerDKXa(k4HyWcYaCN5(yPcAz0Q5HaHSSGbVGwgTAEiqiX8MwTKLfuE7YYarDKXa(kiJZGfKb4oZ9Xsf0YNYhg)VtGqwwWGxqlFkFy8)obcjM30QLSSGYBxwgiQJmgWxbzCgSGma3zUpwQGw(u(W4)DceYYcg8cA5t5dJ)3jqiX8MwTKLfSJcIWryMXkO82LLbI6iJb8vqgNblidWDM7JLkOLpLpm(FNaHSSGbVGw(u(W4)DcesmVPvlzzbL3USmquhzmGVcAXyWcYaCN5(yPcAzMZCE7HaHeZBA1swwWGxqlZCMZBpeiKLfuE7YYarDKXa(k4HXGfKb4oZ9Xsf0YmN582dbcjM30QLSSGbVGwM5mN3EiqillO82LLbI6iJb8vqlKblidWDM7JLkOLzoZ5ThcesmVPvlzzbdEbTmZzoV9qGqwwq5Tllde1rgd4RG2rldwqgG7m3hlvqlJwnpeiKLfm4f0YOvZdbcjM30QLSSGYJwzzGOoYyaFf0oAzWcYaCN5(yPcA5t5dJ)3jqillyWlOLpLpm(FNaHeZBA1swwq5Tllde1rgd4RG2pedwqgG7m3hlvqlFkFy8)obczzbdEbT8P8HX)7eiKyEtRwYYckVDzzGOowhrynp5FSubz8c25aW9cQaKGiQJAwY5YAJpm0QzpFogqnnlJyubrFq9OPGwW(Fa)RJmIrf8iLcnf8qhuq0kdATxhRJmIrfKbq2(DegSoYigvqzxWdpLwQGimOmnNsuhzeJkOSlOfhqAA1sf0KZCMZJcADbrF3Zb5cYyRplyUvQckVZJc6BPLkig)liWL9TnxbZCpMScde1rgXOck7cArNZCPcALQtJe83SGTNkOf)7l3li6N3FbBAoZvqRuCEkqcEsuWGxqG55ZzUcI9JHuZZOPGCSc(lZnnNN6aWDsbLNamjf85uxKk0uWXqQwzGOoYigvqzxWdpLwQGw1rOwbzrYPIcg8cE(lZnP7OGhocdgtuhzeJkOSl4HNslvqlaih8hnfe9trqwWMMZCfKa8RAYo6)UOGwqKGxzd4jrDKrmQGYUGhEkTubTOqwbryJzse1rgXOck7cAKT1iwqm(xqlisWRSb8ubPhg)xbvJ5uf8qhMOoYigvqzxq0)m5mxQGiCczEEerDKrmQGYUGwCUBzuqkYkily3r)RrCFbbyfeewskyR(1j0uqQZckVfFDG0SrCVbI6iJyubLDbzxqDwqSgXvqYyi188ifeJ)fKfC9ffKFoFVOowhzeJkicxwltflvq6HX)vWm3KUJcsVlWjIcE458odsbDUlBK9BIrPkyNda3jfK7k0iQJDoaCNio)L5M0DyOuRP7iudNGKtf1XohaUteN)YCt6omuQ1)YiQgH4JqoaGjf9EkFy8)obbC9f4Cm8G)MZJLWre4xIymKcCEUuDSoYigvqeUSwMkwQGJ5E0uWayUcgixb7CW)ccifSz2avtRMOoYOcYai7)UccWkOTz5VcQ4(TGNnjkiN6li)C((dki)lOTvWe3TmkOVLkyGCfKFoFFbZCtAEbX4FbzbxFrbL35USTaZdKO5nquh7Ca4orAgz)3DaatAamNCwikurRMhIeNIwn8ayoX8MwTekuDoamh(8zcgro7OqL5mN3EiyopqIMhfk07P8HX)7eeW1xGZXWd(BopwchrGFjIXqkW55sOqL5CvIBZf)YiQgH4Jqe)mBGtK7Mt1XohaUtmuQ1NuMMtvh7Ca4oXqPwZSFqtR2bEBoPtwltfd)ezt2bmBf1KgTAEimBcPZ)Ke9FxiqUwfifN5aDhcbOqf9FxiqUwfifN5aDOvguOI(VleixRcKIZCiNfkJKmN582dbZ5bs081XohaUtmuQ1m7h00QDG3MtkLdyi1Wv7op1pyKdy2kQj9P8HX)7eeW1xGZXWd(BopwchrGFjOq9u(W4)DccWXOu4eQ)ouOEkFy8)oXuOHaAh3eCrg1rgXOcAesaPGasbn5KqHMcg8cE(J58OGzoxL42CsbXEUzbPhWVfSZzqAE0kfAkifzPcMOEGFlOjN5mNhI6iJyub7Ca4oXqPw)uoENda3XvasCG3MtQjN5mNhhaWKAYzoZ5Hibir75jhcQJmIrfSZbG7edLAnY9CqgxT(8aaMu5)gKWhZ5HWKZCMZdrcqI2Zto0IajFds4J58qyYzoZ5Ha4YX4iWG6iJyub7Ca4oXqPwtgdPMN3bamPDoamh(8zcgrQDjzoZ5ThcMZdKO5fZBA1ssEkFy8)obbC9f4Cm8G)MZJLWre4xIymKcCEU0bEBoPwzKe0)YiYG0kopfibpjyWFzevJq8ri1rgvqeUjLQJrkiWbbOvf0kfNNcKGNefKmgsnpVcIX)csa(vnzh9Fxuqdlil46le1XohaUtmuQ10kopfibpjoqb8HNtsTlZbamPbWCOZcL05aWC4ZNjyeP2L8u(W4)Dcc46lW5y4b)nNhlHJiWVeXyif48CjjYJEzoZ5ThcMZdKO5rHkZ5Qe3Ml(LruncXhHi(z2aNGoP3CYG6iJkic3Ks1Xife4Ga0QcI(xgr1ieFesbjJHuZZRGy8VGeGFvt2r)3ff0WcAbMhirZxqdlil46le1XohaUtmuQ1)YiQgH4Jqoqb8HNtsTlZbamPbWCOZcL05aWC4ZNjyeP2LK5mN3EiyopqIMxmVPvlj5P8HX)7eeW1xGZXWd(BopwchrGFjIXqkW55sso)XuqR48uGe8KOoYigvWohaUtmuQ1KXqQ55DaatANdaZHpFMGrKAxc6L5mN3EiyopqIMxmVPvlj5P8HX)7eeW1xGZXWd(BopwchrGFjIXqkW55sh4T5KALrsyaK9FhdsR48uGe8KGbrUNdY4zK9FxDKrfeHBsP6yKccCqaAvbrF3Zb5cYyRplOCfKbq2)DfKmgsnpVcIX)csa(vnzh9FxuqdlOZDzBbMhirZxqdlil46le1XohaUtmuQ1i3ZbzC16ZduaF45Ku7YCaatkzra8lrGCphKXZi7)ojbWCOdbs6Cayo85ZemIu7sqVmN582dbZ5bs08I5nTAjjpLpm(FNGaU(cCogEWFZ5Xs4ic8lrmgsbopxsY5pMcAfNNcKGNesYCUkXT5ImY(Vt8ZSbobDYiqqDKrfeHBsP6yKccCqaAvbrF3Zb5cYyRplOCfKbq2)DfKmgsnpVcIX)csa(vnzh9FxuqdlOZDzBbMhirZxqdlil46le1XohaUtmuQ1zK9F3bkGp8CsQDzoaGjLSia(LiqUNdY4zK9FNKayo0HajDoamh(8zcgrQDjOxMZCE7HG58ajAEX8MwTKKNYhg)VtqaxFbohdp4V58yjCeb(LigdPaNNlj58htbY9CqgxT(So25aWDIHsT(KhaUxh7Ca4oXqPw)T5zF3bamPzoxL42CXVmIQri(ieXpZg4e0DijrRMhIFzevJqWB62tCxmVPvlvh7Ca4oXqPwN5odP2ZFcoD7((daysPPWWe)YiQgH4JqejUnxsA0uyyccy3r)RrCViXT5OqHbUid8FMnWjOdbYuh7Ca4oXqPw)lJOAeIpc5aaM0NYhg)VtqaogLcNq93j5MtIFMnWjsLrI8m7h00QjMSwMkg(jYMmuOKp6)UqeaZHhC8ZCGFieihJlJKOvZdr7394MT33zopqHk6)UqeaZHhC8ZCGFiei3HjJe0lA18q0(DpUz79DMZddmqI8KZPu4r)3feHnKGxzd4jP2rHIMcdtyUoWZQ1m3lOonOo25aWDIHsT(xgr1ieFeYbamPpLpm(FNyk0qaTJBcUidj3Cs8ZSborQmsKpZ5Qe3MliNRFCogoDtca3f)mBGtqhcqHkZ5Qe3MliNRFCogoDtca3f)mBGtKdTYyGe5LNMcdtqR48KIIecQtuOIwnpeTF3JB2EFN58qmVPvlHc13Ge(yopeDkreaxo7Yyakur)3fIayo8GJNato7Yidkum7h00QjMSwMkg(jYMmuOI(VlebWC4bhpbg6SJajFds4J58q0PeraC5SlJbsKNCoLcp6)UGiSHe8kBapj1oku0uyycZ1bEwTM5Eb1Pb1XohaUtmuQ1)YiQgH4JqoaGjf9y2pOPvtq5agsnC1UZt9dgrYnNe)mBGtKkJe5LNMcdtqR48KIIecQtuOIwnpeTF3JB2EFN58qmVPvlHc13Ge(yopeDkreaxo7Yyakur)3fIayo8GJNato7Yidkum7h00QjMSwMkg(jYMmuOI(VlebWC4bhpbg6SJajFds4J58q0PeraC5SlJbsKNCoLcp6)UGiSHe8kBapj1oku0uyycZ1bEwTM5Eb1Pb1XohaUtmuQ1)YiQgH4JqoGImCogg(nNKA)aaM0NYhg)VtqaxFbohdp4V58yjCeb(LigdPaNNlj58ht8BojSl(28SVtI8YttHHjOvCEsrrcb1jkurRMhI2V7XnBVVZCEiM30QLqH6BqcFmNhIoLicGlNDzmafQO)7cramhEWXtGjNDzKbfkM9dAA1etwltfd)eztgkur)3fIayo8GJNadD2rGKVbj8XCEi6uIiaUC2LXajYtoNsHh9Fxqe2qcELnGNKAhfkAkmmH56apRwZCVG60G6yNda3jgk1ABibVYgWthaWKQgZPK7qwmjYtoNsHh9Fxqe2qcELnGNKZUe0JMcdtyUoWZQ1m3lOorH6BqcFmNhIoLicGJUBojb9OPWWeMRd8SAnZ9cQtdQJDoaCNyOuRPidheZKuh7Ca4oXqPwtR48eog1JM6yNda3jgk1A69K9ic87bamP0uyyIFzevJq8ricQZ6yNda3jgk1Af4Imi4w0OsxZ5XbamP0uyyIFzevJq8riIe3MljnAkmmbbS7O)1iUxK4286yNda3jgk1AmWpAfNNQJDoaCNyOuRBpps8Tcp3kvDSZbG7edLAnDFX5y4XdYisoaGjLMcdt8lJOAeIpcrK42CjPrtHHjiGDh9VgX9Ie3MlHMcdtm)77euN1XohaUtmuQ15wPW7Ca4oUcqIdiXdYHu7h4T5K28Daatk5CkfE0)Dbrydj4v2aEso71XohaUtmuQ1pLJ35aWDCfGeh4T5Ksa(vn8O)7I6yDSZbG7erZN0C75PWPPWWoWBZjLw1Prc(BEaat6nNe)mBGtKkJecNsrd8Kad8KaNepaXjHMcdtGbEsGtIhG4e)mBGtKqtHHjM)9DIFMnWjO7Mt1XohaUtenFgk162ZG5bEJf7ji5zepaGjLMcdtm)77euNsYCUkXT5IFzevJq8riIFMnWjYHG6yNda3jIMpdLAn5C9JZXWPBsa4(bamP0uyyI5FFNG6uY33HogxM6yNda3jIMpdLAnTQtJe838aGh7FQZahGj9MtIFMnWjsLrcHtPObEsGbEsGtIhG4KqtHHjWapjWjXdqCIFMnWjsOPWWeZ)(oXpZg4e0DZPdaysPPWWeZ)(ob1PeY5uk8O)7cIWgsWRSb8KCOTo25aWDIO5ZqPwN5EAM(bamPYttHHjM)9DcQtuOOPWWe)YiQgH4JqeuNsEkFy8)obb4yukCc1FNbsy2pOPvtmzTmvm8tKnz1XohaUtenFgk1Acy3r)RrCFDSZbG7erZNHsT(BZZ(U6yNda3jIMpdLAn5C9JZXWPBsa4(bamP0uyyI5FFNG6usMZvjUnx8lJOAeIpcr8ZSboroeuh7Ca4or08zOuRPvDAKG)MhaWKstHHjM)9DIFMnWjYDZjeMqRab1X6yNda3jccWVQHh9FxyOuR)(c8loTIB7aaM0NYhg)VtydOu4Cm8a5WP3t2J4EXyif48Cjj0uyycBaLcNJHhiho9EYEe3l(z2aNGUBovh7Ca4orqa(vn8O)7cdLAD(Piib(fNwXTDaat6t5dJ)3jSbukCogEGC407j7rCVymKcCEUKeAkmmHnGsHZXWdKdNEpzpI7f)mBGtq3nNQJDoaCNiia)QgE0)DHHsTo3EEkCAkmSd82CsPvDAKG)MhaWKsoNsHh9Fxqe2qcELnGNKAxYnNe)mBGtKkJe5JwnpeMnH05FI5nTAjuOYCMZBpemNhirZlM30QLmqcZ(bnTAIjRLPIHFISjtI8FFNCwezqHc9YCUkXT5Im3tZ0f)mBGtmOo25aWDIGa8RA4r)3fgk16m3tZ0paGjvEAkmmX8VVtqDIcfnfgM4xgr1ieFeIG6uYt5dJ)3jiahJsHtO(7mqcZ(bnTAIjRLPIHFISjRo25aWDIGa8RA4r)3fgk16m3tZ0paGjLMcdtm)77euNsy2pOPvtmzTmvm8tKnz1XohaUteeGFvdp6)UWqPwta7o6FnI7paGjnnAkmmbbS7O)1iUxK42CjYtoNsHh9Fxqe2qcELnGNKZokuFds4J58q0PeraC5SJadQJDoaCNiia)QgE0)DHHsT(BZZ(UdaysLNMcdt8lJOAeIpcrqDIcfnfgMWCM8hn4CmCfvgKWt)AtIG60auOKNMcdtm)77e)mBGtq3nNqH677KZIiJbOqrtHHjW(5wurJ4NzdCc6SlqqDSZbG7ebb4x1WJ(VlmuQ1zUNMPxh7Ca4orqa(vn8O)7cdLAD7zW8aVXI9eK8mIhaWKstHHjM)9DcQtjYtoNsHh9Fxqe2qcELnGNKZokuFds4J58q0PeraC5omeyqDSZbG7ebb4x1WJ(VlmuQ1KZ1pohdNUjbG7haWKstHHjM)9DcQtjYtoNsHh9Fxqe2qcELnGNKZokuFds4J58q0PeraC5yCeyqDSZbG7ebb4x1WJ(VlmuQ1twltfRo25aWDIGa8RA4r)3fgk1AAvNgj4V5bamP0uyyI5FFNG6uI8OhnfgM4xgr1ieFeI4NzdCckuFFh6qGmgirEY5uk8O)7cIWgsWRSb8Ku7s(gKWhZ5HOtjIa4YX4iafkY5uk8O)7cIWgsWRSb8Ku0AqDSZbG7ebb4x1WJ(VlmuQ10kopfibpjoaGjLMcdtm)77ejUnhfQm3tuGqWeKbCkcEM7XmpdX3oIYHajr)3fcKRvbsXzoq3HqqDSZbG7ebb4x1WJ(VlmuQ10kopr3bYdaysPPWWeZ)(orIBZrHkZ9efiembzaNIGN5EmZZq8TJOCiqs0)DHa5AvGuCMd0Dieib9Iwnpe5NAQanI5nTAP6yNda3jccWVQHh9FxyOuRtFF5o(Z7)aaMuAkmmX8VVtqDkrEY5uk8O)7cIWgsWRSb8KC2rH6BqcFmNhIoLicGlNDeyqDSZbG7ebb4x1WJ(VlmuQ1CNOAQlYOo25aWDIGa8RA4r)3fgk1ABibVYgWthaWKstHHjm3NbQri40CF3h4P9cQtjKZPu4r)3feHnKGxzd4j5ouDSZbG7ebb4x1WJ(VlmuQ1FFb(fNwXTDaatAgz)3rKIwuOOPWWe)YiQgH4JqeuNsy2pOPvtmzTmvm8tKnzsIwnpeMnH05FI5nTAP6yNda3jccWVQHh9FxyOuRZpfbjWV40kUTdaysZi7)oIu0IcfnfgM4xgr1ieFeIG6ucZ(bnTAIjRLPIHFISjts0Q5HWSjKo)tmVPvlvh7Ca4orqa(vn8O)7cdLAnTIZtbsWtI6yNda3jccWVQHh9FxyOuRPvCEIUdK1XohaUteeGFvdp6)UWqPw)9f4xCAf3wDSZbG7ebb4x1WJ(VlmuQ15NIGe4xCAf3wDSZbG7ebb4x1WJ(VlmuQ12qcELnGN0Ho0Aa]] )


end
