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


    spec:RegisterPack( "Fury", 20210703.2, [[d4Khlbqiiv5rOq2er8jkPgff0POaRcsrKxru1SubUfrP2fHFrjmmIIJrPAzqk9mkjnnuO6AQe2Mki8nvqzCQG05OKG1Hc08Gu5EeP9ru5GQGQfsj6HOaMOki6IqkQncPQWhHuv0iHuv6KqksRufAMOq5Musu1oPq9tifrnuifHLcPQ6PO0uPqUkLefBLsc9vkjYyHuyVK8xOAWGoSKfJupwWKf6YkBgkFgIrRsDAGvtjrLxRsA2K62u0UP63OA4QOJJcA5Q65iMUORJKTJI(oLY4jk58QeTEkjknFiz)sTYUYifBSYPmgTYGw7YCyYyvH9dfTYy)cfBE55uSNv4AHmfRxMtXI(G6VuXEwxQ5vuzKILWP(WuS3zEsyqlSabK3u0Ia30ccWKsxjG7HVWsliaZGfkwAkGortDfTInw5ugJwzqRDzomzSQW(HA3kyv0QylQ8M)kwwGjd0qlA4H)HBGzcEorXEdIX5kAfBCKGIf9b1FzdTs1)a(3hpsPVSHw9GgIwzqR9(yFKbUlhzegSpk7gE4X4InenbLP50I(OSB4HeqkA9In0KZCMZZgArdrF3ZbHgYyRoByO06gAOZZg6BXfBig)BiWLnszUgg4EozLgi6JYUHw55mxSHwQR4ij)nBy5XgEi)cH7ne9ZRVHfnN5AOLAopM3GNKnm5neyE(CMRHy)yi18WLnKJ1WFbUP58yLaUtAOHeGjPHpNc5wFzdhdPkTbI(OSB4HhJl2qlRm1RHS3CQSHjVHN)cCt6kB4HJMGXe9rz3WdpgxSHwrqi5)Lne9trUByrZzUgsaoIEYoRhzzdTs3GxBd4rrFu2n8WJXfBOvgYAiAAotIOpk7gAKTvxBig)BOv6g8ABap2q6HX)1q9yoDdT6Hj6JYUHO)zYzUydrZeY8WiI(OSB4HK7wNnKISgYcgYO)vx33qawdbP1Kgw6Fv8YgsD2qdpKRYBZ66Ede9rz3q2LuNneRUUgsgdPMhgPHy8VHSaeFzd5NZ3luSAajjkJuSfFkJugBxzKIDErRxuzPIn8GCpOuSiHO4NzbCsdL2qzAOKgs4uAAGhfyGNK4K8bxNyErRxSHsAinfgMad8KeNKp46e)mlGtAOKgstHHjM)fYe)mlGtAi6AisiQyRqc4UInuEyACAkmmflnfggUxMtXsRR4ij)nvPYy0QmsXoVO1lQSuXgEqUhukwAkmmX8VqMG6SHsAyGZ1rUnx8lCvpcXhHi(zwaN0q5A4fk2kKaURylpaMN4fwUNCZdxvPYyRQmsXoVO1lQSuXgEqUhukwAkmmX8VqMG6SHsA4xiRHORHmUmk2kKaURyjNRECogoDrsa3vPYygxzKIDErRxuzPIn8GCpOuS0uyyI5FHmb1zdL0qY50A8SEKLeHTBWRTb8ydLRHOvXwHeWDflTUIJK83uXc8C)tDM4amflsik(zwaNivgjeoLMg4rbg4jjojFW1jHMcdtGbEsItYhCDIFMfWjsOPWWeZ)czIFMfWjOdjevPY4lugPyNx06fvwQydpi3dkfRHnKMcdtm)lKjOoBikunKMcdt8lCvpcXhHiOoBOKg(u(W4pYeeGJrPXjupYeZlA9In0GgkPHmRhu06jMSwGkh(5DrMITcjG7k2a3JZ0vPY4dHYifBfsa3vSeWqg9V66Ef78IwVOYsvQm(WugPyRqc4UI9lZZczk25fTErLLQuz8HQmsXoVO1lQSuXgEqUhukwAkmmX8VqMG6SHsAyGZ1rUnx8lCvpcXhHi(zwaN0q5A4fk2kKaURyjNRECogoDrsa3vPYyRGYif78IwVOYsfB4b5EqPyPPWWeZ)czIFMfWjnuUgIeInenPgIwXfk2kKaURyP1vCKK)MQuzSDzugPyRqc4UILjiK8)s8NICRyNx06fvwQsLX2TRmsXwHeWDflW8CEe4i4mbHK)xQyNx06fvwQsvQyjahrp8SEKLkJugBxzKIDErRxuzPIn8GCpOuSpLpm(JmHnGwJZXWZ7HtVNS)6EXyif48CXgkPH0uyycBaTgNJHN3dNEpz)19IFMfWjneDnejevSvibCxX(fcWrWP1CBQuzmAvgPyNx06fvwQydpi3dkf7t5dJ)itydO14Cm88E407j7VUxmgsbopxSHsAinfgMWgqRX5y459WP3t2FDV4NzbCsdrxdrcrfBfsa3vSFHaCeCAn3MkvgBvLrk25fTErLLk2WdY9GsXsoNwJN1JSKiSDdETnGhBO0gAVHsAisik(zwaN0qPnuMgkPHg2WS0ZtHzriv4NyErRxSHOq1WaN58YtbZ559LFdnOHsAiZ6bfTEIjRfOYHFExK1qjn0Wg(fYAOCn0kitdrHQHOxddCUoYT5Ia3JZ0f)mlGtAObk2kKaURydLhMgNMcdtXstHHH7L5uS06kosYFtvQmMXvgPyNx06fvwQydpi3dkfRHnKMcdtm)lKjOoBikunKMcdt8lCvpcXhHiOoBOKg(u(W4pYeeGJrPXjupYeZlA9In0GgkPHmRhu06jMSwGkh(5DrMITcjG7k2a3JZ0vPY4lugPyNx06fvwQydpi3dkflnfgMy(xitqD2qjnKz9GIwpXK1cu5WpVlYuSvibCxXg4ECMUkvgFiugPyNx06fvwQydpi3dkfBC0uyyccyiJ(xDDViYT5nusdnSHKZP14z9iljcB3GxBd4XgkxdT3quOA4xGi(yopfvmseaVHY1q7x0qduSvibCxXsadz0)QR7vPY4dtzKIDErRxuzPIn8GCpOuSg2qAkmmXVWv9ieFeIG6SHOq1qAkmmH5m5)L4CmCnvaeXJ)ktIG6SHg0quOAOHnKMcdtm)lKj(zwaN0q01qKqSHOq1WVqwdLRHwbzAObnefQgstHHjW(5wzVu8ZSaoPHORH2fxOyRqc4UI9lZZczQuz8HQmsXwHeWDfBG7Xz6k25fTErLLQuzSvqzKIDErRxuzPIn8GCpOuS0uyyI5FHmb1zdL0qdBi5CAnEwpYsIW2n412aESHY1q7nefQg(fiIpMZtrfJebWBOCn8WUOHgOyRqc4UIT8ayEIxy5EYnpCvLkJTlJYif78IwVOYsfB4b5EqPyPPWWeZ)czcQZgkPHg2qY50A8SEKLeHTBWRTb8ydLRH2Bikun8lqeFmNNIkgjcG3q5AiJFrdnqXwHeWDfl5C1JZXWPlsc4UkvgB3UYifBfsa3vStwlqLtXoVO1lQSuLkJTJwLrk25fTErLLk2WdY9GsXstHHjM)fYeuNnusdnSHOxdPPWWe)cx1Jq8riIFMfWjnefQg(fYAi6A4fY0qdAOKgAydjNtRXZ6rwse2UbV2gWJnuAdT3qjn8lqeFmNNIkgjcG3q5AiJFrdrHQHKZP14z9iljcB3GxBd4XgkTHOTHgOyRqc4UILwxXrs(BQsLX2TQYif78IwVOYsfB4b5EqPyPPWWeZ)czIi3M3quOAyG7rkqkyccaofbpW9CMNP4l)AdLRHx0qjnmRhzP4ELoVfNHSHORHw9cfBfsa3vS0AopM3GNKQuzSDgxzKIDErRxuzPIn8GCpOuS0uyyI5FHmrKBZBikunmW9ififmbbaNIGh4EoZZu8LFTHY1WlAOKgM1JSuCVsN3IZq2q01qRErdL0q0RHzPNNIWtnDEPyErRxuXwHeWDflTMZJ5n4jPkvgB)cLrk25fTErLLk2WdY9GsXstHHjM)fYeuNnusdnSHKZP14z9iljcB3GxBd4XgkxdT3quOA4xGi(yopfvmseaVHY1q7x0qduSvibCxXg)cH74pVEvQm2(HqzKITcjG7kwUt0ffYDQyNx06fvwQsLX2pmLrk25fTErLLk2WdY9GsXstHHjm3ha6ri40CFipWJ7fuNnusdjNtRXZ6rwse2UbV2gWJnuUgAvfBfsa3vS2UbV2gWJQuzS9dvzKIDErRxuzPIn8GCpOuSH76rgPHsBiABikunKMcdt8lCvpcXhHiOoBOKgYSEqrRNyYAbQC4N3fznusdZsppfMfHuHFI5fTErfBfsa3vSFHaCeCAn3MkvgB3kOmsXoVO1lQSuXgEqUhuk2WD9iJ0qPneTnefQgstHHj(fUQhH4JqeuNnusdzwpOO1tmzTavo8Z7ISgkPHzPNNcZIqQWpX8IwVOITcjG7k2VqaocoTMBtLkJrRmkJuSvibCxXsR58yEdEsQyNx06fvwQsLXO1UYifBfsa3vS0AopM3GNKk25fTErLLQuzmArRYifBfsa3vSFHaCeCAn3MIDErRxuzPkvgJwRQmsXwHeWDf7xiahbNwZTPyNx06fvwQsLXOLXvgPyRqc4UI12n412aEuXoVO1lQSuLQuXghwrPtLrkJTRmsXoVO1lQSuXwHeWDfB4UEKPyJJeEWzc4UILbURhzneG1qBZ6FnuZDKgEwKSHCQVH8Z57pOH8VH2wdJC36SH(wSH59Ai)C((gg4M08gIX)gYcq8Ln0qN7Y2kopVV8nqOydpi3dkfBcmxdLRHhAdrHQHzPNNIiNIwp8eyoX8IwVydrHQHvibmh(8zcgPHY1q7nefQgg4mNxEkyopVV8Bikune9A4t5dJ)itqai(sCogEYFZ55I4xbocrmgsbopxSHOq1WaNRJCBU4x4QEeIpcr8ZSaoPHY1qKquLkJrRYifBfsa3vSNuMMtRyNx06fvwQsLXwvzKIDErRxuzPILFQyjlvSvibCxXYSEqrRNILzPPMInl98uywesf(jMx06fBOKgM1JSuCVsN3IZq2q01qRErdrHQHz9ilf3R05T4mKneDneTY0quOAywpYsX9kDElodzdLRHhQmnusddCMZlpfmNN3x(kwM1J7L5uStwlqLd)8UitLkJzCLrk25fTErLLkw(PILSuXwHeWDflZ6bfTEkwMLMAk2NYhg)rMGaq8L4Cm8K)MZZfXVcCeIyErRxSHOq1WNYhg)rMGaCmknoH6rMyErRxSHOq1WNYhg)rMy6ljGYXnbi3PyErRxuXYSECVmNILYbmKA46HmpwpyevQm(cLrk25fTErLLk2kKaURyP1CEmVbpjvSAGp8quXAxgfB4b5EqPytG5Ai6A4H2qjnScjG5WNptWinuAdT3qjn8P8HXFKjiaeFjohdp5V58Cr8RahHigdPaNNl2qjn0WgIEnmWzoV8uWCEEF53quOAyGZ1rUnx8lCvpcXhHi(zwaN0q0jTHiHydnqXghj8GZeWDflA2Ksx5ine4Geu6gAPMZJ5n4jzdjJHuZdRHy8VHeGJONSZ6rw2q5BilaXxkuPY4dHYif78IwVOYsfBfsa3vS)cx1Jq8rikwnWhEiQyTlJIn8GCpOuSjWCneDn8qBOKgwHeWC4ZNjyKgkTH2BOKgg4mNxEkyopVV8BOKg(u(W4pYeeaIVeNJHN83CEUi(vGJqeJHuGZZfBOKgE(JPGwZ5X8g8KuXghj8GZeWDflA2Ksx5ine4Geu6gI(x4QEeIpcPHKXqQ5H1qm(3qcWr0t2z9ilBO8n0kopVV8BO8nKfG4lfQuz8HPmsXoVO1lQSuXwHeWDf79EoiGRxDQy1aF4HOI1Umk2WdY9GsXswMahHiU3Zbb8WD9iRHsAycmxdrxdVOHsAyfsaZHpFMGrAO0gAVHsAi61WaN58YtbZ559LFdL0WNYhg)rMGaq8L4Cm8K)MZZfXVcCeIymKcCEUydL0WZFmf0AopM3GNKnusddCUoYT5IWD9it8ZSaoPHORHYiUqXghj8GZeWDflA2Ksx5ine4Geu6gI(UNdcnKXwD2q5AidCxpYAizmKAEyneJ)nKaCe9KDwpYYgkFdDUlBR488(YVHY3qwaIVuOsLXhQYif78IwVOYsfBfsa3vSH76rMIvd8HhIkw7YOydpi3dkflzzcCeI4EpheWd31JSgkPHjWCneDn8IgkPHvibmh(8zcgPHsBO9gkPHOxddCMZlpfmNN3x(nusdFkFy8hzccaXxIZXWt(Bopxe)kWriIXqkW55Inusdp)XuCVNdc46vNk24iHhCMaURyrZMu6khPHahKGs3q039CqOHm2QZgkxdzG76rwdjJHuZdRHy8VHeGJONSZ6rw2q5BOZDzBfNN3x(nu(gYcq8LcvQm2kOmsXwHeWDf7jpbCxXoVO1lQSuLkJTlJYif78IwVOYsfB4b5EqPydCUoYT5IFHR6ri(ieXpZc4KgIUgA1gkPHzPNNIFHR6ri4fD5rUlMx06fvSvibCxX(L5zHmvQm2UDLrk25fTErLLk2WdY9GsXstHHj(fUQhH4JqerUnVHsAyC0uyyccyiJ(xDDViYT5nefQgIbqUt8FMfWjneDn8czuSvibCxXg4odP2ZFcoD5(EvQm2oAvgPyNx06fvwQydpi3dkf7t5dJ)itqaogLgNq9itmVO1l2qjnejef)mlGtAO0gktdL0qdBiZ6bfTEIjRfOYHFExK1quOAOHnmRhzPibMdp54NHe3Qx0q5AiJltdL0WS0Ztr5i7XnlVqM58umVO1l2quOAywpYsrcmhEYXpdjUvVOHY1WdtMgkPHOxdZsppfLJSh3S8czMZtX8IwVydnOHg0qjn0WgsoNwJN1JSKiSDdETnGhBO0gAVHOq1qAkmmH5QepOxXCVG6SHgOyRqc4UI9x4QEeIpcrLkJTBvLrk25fTErLLk2WdY9GsX(u(W4pYetFjbuoUja5ofZlA9InusdrcrXpZc4KgkTHY0qjn0Wgg4CDKBZfKZvpohdNUijG7IFMfWjneDn8IgIcvddCUoYT5cY5QhNJHtxKeWDXpZc4KgkxdrRmn0GgkPHg2qdBinfgMGwZ5rnfjfuNnefQgMLEEkkhzpUz5fYmNNI5fTEXgIcvd)ceXhZ5POIrIa4nuUgAxMgAqdrHQHz9ilfjWC4jhpcwdLRH2LrMgIcvdzwpOO1tmzTavo8Z7ISgIcvdZ6rwksG5WtoEeSgIUgA)IgkPHFbI4J58uuXira8gkxdTltdnOHsAOHnKCoTgpRhzjry7g8ABap2qPn0EdrHQH0uyycZvjEqVI5Eb1zdnqXwHeWDf7VWv9ieFeIkvgBNXvgPyNx06fvwQydpi3dkfl61qM1dkA9euoGHudxpK5X6bJ0qjnejef)mlGtAO0gktdL0qdBOHnKMcdtqR58OMIKcQZgIcvdZsppfLJSh3S8czMZtX8IwVydrHQHFbI4J58uuXira8gkxdTltdnOHOq1WSEKLIeyo8KJhbRHY1q7YitdrHQHmRhu06jMSwGkh(5DrwdrHQHz9ilfjWC4jhpcwdrxdTFrdL0WVar8XCEkQyKiaEdLRH2LPHg0qjn0WgsoNwJN1JSKiSDdETnGhBO0gAVHOq1qAkmmH5QepOxXCVG6SHgOyRqc4UI9x4QEeIpcrLkJTFHYif78IwVOYsfB4b5EqPyFkFy8hzccaXxIZXWt(Bopxe)kWriIXqkW55Inusdp)Xehjef2fFzEwiRHsAOHn0WgstHHjO1CEutrsb1zdrHQHzPNNIYr2JBwEHmZ5PyErRxSHOq1WVar8XCEkQyKiaEdLRH2LPHg0quOAywpYsrcmhEYXJG1q5AODzKPHOq1qM1dkA9etwlqLd)8UiRHOq1WSEKLIeyo8KJhbRHORH2VOHsA4xGi(yopfvmseaVHY1q7Y0qdAOKgAydjNtRXZ6rwse2UbV2gWJnuAdT3quOAinfgMWCvIh0RyUxqD2qduSvibCxX(lCvpcXhHOyPidNJHHJeIkJTRsLX2pekJuSZlA9IklvSHhK7bLIvpMt3q5AOvpenusdnSHKZP14z9iljcB3GxBd4XgkxdT3qjne9AinfgMWCvIh0RyUxqD2quOA4xGi(yopfvmseaVHORHiHydL0q0RH0uyycZvjEqVI5Eb1zdnqXwHeWDfRTBWRTb8OkvgB)WugPyRqc4UILImCqotIIDErRxuzPkvgB)qvgPyRqc4UILwZ5rCmQ)sf78IwVOYsvQm2UvqzKIDErRxuzPIn8GCpOuS0uyyIFHR6ri(ieb1PITcjG7kw69K9xboIkvgJwzugPyNx06fvwQydpi3dkflnfgM4x4QEeIpcre528gkPHXrtHHjiGHm6F119Ii3MRyRqc4UIvdqUtcUvoQiI58uLkJrRDLrk2kKaURyXa)O1CEuXoVO1lQSuLkJrlAvgPyRqc4UIT8Wi5xA8qP1k25fTErLLQuzmATQYif78IwVOYsfB4b5EqPyPPWWe)cx1Jq8riIi3M3qjnmoAkmmbbmKr)RUUxe528gkPH0uyyI5FHmb1PITcjG7kw6cbNJHNpiCLOsLXOLXvgPyNx06fvwQydpi3dkfl5CAnEwpYsIW2n412aESHY1q7kws(GqQm2UITcjG7k2qP14vibChxdiPIvdijUxMtXw8PsLXO9cLrk25fTErLLk2kKaURyFkhVcjG74AajvSAajX9YCkwcWr0dpRhzPkvPI98xGBsxPYiLX2vgPyRqc4UILUYupCYnNkvSZlA9IklvPYy0QmsXoVO1lQSuXgEqUhukw0RHpLpm(JmbbG4lX5y4j)nNNlIFf4ieXyif48CrfBfsa3vS)cx1Jq8riQuLQuXYCpbWDLXOvg0AxMdtgRQyTvVdCeII1kD4OFJrtng9jd2WgA09AiW8K)zdX4FdTU4Z6g(JHuGFXgs4MRHfvYnRCXggUlhzerFKXa(AODgSHma3zUpxSHwt4uAAGhfOH1nm5n0AcNstd8OaneZlA9Iw3qdTllde9rgd4RHxWGnKb4oZ95In06NYhg)rManSUHjVHw)u(W4pYeOHyErRx06gAODzzGOp2hTsho63y0uJrFYGnSHgDVgcmp5F2qm(3qRjahrp8SEKLw3WFmKc8l2qc3CnSOsUzLl2WWD5iJi6JmgWxdTkd2qgG7m3Nl2qRdCMZlpfOHyErRx06gM8gADGZCE5PanSUHgAxwgi6JmgWxdzCgSHma3zUpxSHw)u(W4pYeOH1nm5n06NYhg)rManeZlA9Iw3qdTllde9X(Ov6Wr)gJMAm6tgSHn0O71qG5j)ZgIX)gADCyfLoTUH)yif4xSHeU5AyrLCZkxSHH7Yrgr0hzmGVgAvgSHma3zUpxSHwNLEEkqdRByYBO1zPNNc0qmVO1lADdn0USmq0hzmGVgY4mydzaUZCFUydT(P8HXFKjqdRByYBO1pLpm(JmbAiMx06fTUHgAxwgi6JmgWxdzCgSHma3zUpxSHw)u(W4pYeOH1nm5n06NYhg)rManeZlA9Iw3WkBiAgnzgRHgAxwgi6JmgWxdzCgSHma3zUpxSHw)u(W4pYeOH1nm5n06NYhg)rManeZlA9Iw3qdTllde9rgd4RHhcgSHma3zUpxSHwh4mNxEkqdX8IwVO1nm5n06aN58YtbAyDdn0USmq0hzmGVgEymydzaUZCFUydToWzoV8uGgI5fTErRByYBO1boZ5LNc0W6gAODzzGOpYyaFn8qzWgYaCN5(CXgADGZCE5PaneZlA9Iw3WK3qRdCMZlpfOH1n0q7YYarFKXa(AOD0YGnKb4oZ95In06S0ZtbAyDdtEdTol98uGgI5fTErRBOHOvwgi6JmgWxdTJwgSHma3zUpxSHw)u(W4pYeOH1nm5n06NYhg)rManeZlA9Iw3qdTllde9rgd4RH2Tkd2qgG7m3Nl2qRFkFy8hzc0W6gM8gA9t5dJ)itGgI5fTErRBOH2LLbI(yFen18K)5InKXByfsa3BOgqsIOpQyjNlOm(WqRI985ya9uSmIrne9b1FzdTs1)a(3hzeJA4rk9Ln0Qh0q0kdAT3h7JmIrnKbUlhzegSpYig1qz3WdpgxSHOjOmnNw0hzeJAOSB4HeqkA9In0KZCMZZgArdrF3ZbHgYyRoByO06gAOZZg6BXfBig)BiWLnszUgg4EozLgi6JmIrnu2n0kpN5In0sDfhj5Vzdlp2Wd5xiCVHOFE9nSO5mxdTuZ5X8g8KSHjVHaZZNZCne7hdPMhUSHCSg(lWnnNhReWDsdnKamjn85ui36lB4yivPnq0hzeJAOSB4HhJl2qlRm1RHS3CQSHjVHN)cCt6kB4HJMGXe9rgXOgk7gE4X4In0kccj)VSHOFkYDdlAoZ1qcWr0t2z9ilBOv6g8ABapk6JmIrnu2n8WJXfBOvgYAiAAotIOpYig1qz3qJST6AdX4FdTs3GxBd4Xgspm(VgQhZPBOvpmrFKrmQHYUHO)zYzUydrZeY8WiI(iJyudLDdpKC36SHuK1qwWqg9V66(gcWAiiTM0Ws)RIx2qQZgA4HCvEBwx3BGOpYig1qz3q2LuNneRUUgsgdPMhgPHy8VHSaeFzd5NZ3l6J9rgXOgIML1cu5InKEy8FnmWnPRSH0db4erdp8qyNjPHo3L9D9Myu6gwHeWDsd5U(srFScjG7eX5Va3KUs5LAbDLPE4KBov2hRqc4orC(lWnPRuEPw8lCvpcXhHCaatk69u(W4pYeeaIVeNJHN83CEUi(vGJqeJHuGZZf7J9rgXOgIML1cu5InCm3FzdtG5AyEVgwHK)neqAyXSa6IwprFKrnKbURhzneG1qBZ6FnuZDKgEwKSHCQVH8Z57pOH8VH2wdJC36SH(wSH59Ai)C((gg4M08gIX)gYcq8Ln0qN7Y2kopVV8nq0hRqc4orA4UEKDaatAcmNChkkuzPNNIiNIwp8eyoX8IwVikuvibmh(8zcgro7Oqf4mNxEkyopVV8rHc9EkFy8hzccaXxIZXWt(Bopxe)kWriIXqkW55IOqf4CDKBZf)cx1Jq8riIFMfWjYHeI9XkKaUtKxQfNuMMt3hRqc4orEPwWSEqrR3bEzoPtwlqLd)8Ui7aMLMAsZsppfMfHuHFsY6rwkUxPZBXzirNvVafQSEKLI7v68wCgs0HwzqHkRhzP4ELoVfNHuUdvgjboZ5LNcMZZ7l)(yfsa3jYl1cM1dkA9oWlZjLYbmKA46HmpwpyKdywAQj9P8HXFKjiaeFjohdp5V58Cr8RahHGc1t5dJ)itqaogLgNq9idfQNYhg)rMy6ljGYXnbi3zFKrmQHgDdineqAOjNK6lByYB45pMZZgg4CDKBZjne75MnKEahPHviaIZZsRVSHuKfByK6bosdn5mN58u0hzeJAyfsa3jYl1INYXRqc4oUgqYd8YCsn5mN588aaMutoZzopfrajlpm5UOpYig1WkKaUtKxQf375GaUE15bamPg(fiIpMZtHjN5mNNIiGKLhMCO9cjFbI4J58uyYzoZ5Pa4YX4xyqFKrmQHvibCNiVuliJHuZd7aaM0kKaMdF(mbJi1UKaN58YtbZ559LVyErRxuYt5dJ)itqai(sCogEYFZ55I4xbocrmgsbopx8aVmNulnsc6FHRmiTMZJ5n4jjd(lCvpcXhH0hzudrZMu6khPHahKGs3ql1CEmVbpjBizmKAEyneJ)nKaCe9KDwpYYgkFdzbi(srFScjG7e5LAbTMZJ5n4j5bAGp8quQDzoaGjnbMdDhQKkKaMdF(mbJi1UKNYhg)rMGaq8L4Cm8K)MZZfXVcCeIymKcCEUOedrVaN58YtbZ559Lpkuboxh52CXVWv9ieFeI4NzbCc6KIeIg0hzudrZMu6khPHahKGs3q0)cx1Jq8rinKmgsnpSgIX)gsaoIEYoRhzzdLVHwX559LFdLVHSaeFPOpwHeWDI8sT4x4QEeIpc5anWhEik1UmhaWKMaZHUdvsfsaZHpFMGrKAxsGZCE5PG588(YxmVO1lk5P8HXFKjiaeFjohdp5V58Cr8RahHigdPaNNlk58htbTMZJ5n4jzFKrmQHvibCNiVuliJHuZd7aaM0kKaMdF(mbJi1Ue0lWzoV8uWCEEF5lMx06fL8u(W4pYeeaIVeNJHN83CEUi(vGJqeJHuGZZfpWlZj1sJKWa31JmgKwZ5X8g8KKbV3Zbb8WD9iRpYOgIMnP0vosdboibLUHOV75GqdzSvNnuUgYa31JSgsgdPMhwdX4FdjahrpzN1JSSHY3qN7Y2kopVV8BO8nKfG4lf9XkKaUtKxQf375GaUE15bAGp8quQDzoaGjLSmbocrCVNdc4H76rMKeyo0DHKkKaMdF(mbJi1Ue0lWzoV8uWCEEF5lMx06fL8u(W4pYeeaIVeNJHN83CEUi(vGJqeJHuGZZfLC(JPGwZ5X8g8KusGZ1rUnxeURhzIFMfWjOtgXf9rg1q0SjLUYrAiWbjO0ne9DpheAiJT6SHY1qg4UEK1qYyi18WAig)Bib4i6j7SEKLnu(g6Cx2wX559LFdLVHSaeFPOpwHeWDI8sTiCxpYoqd8HhIsTlZbamPKLjWriI79CqapCxpYKKaZHUlKuHeWC4ZNjyeP2LGEboZ5LNcMZZ7lFX8IwVOKNYhg)rMGaq8L4Cm8K)MZZfXVcCeIymKcCEUOKZFmf375GaUE1zFScjG7e5LAXjpbCVpwHeWDI8sT4lZZczhaWKg4CDKBZf)cx1Jq8riIFMfWjOZQsYsppf)cx1JqWl6YJCxmVO1l2hRqc4orEPwe4odP2ZFcoD5((daysPPWWe)cx1Jq8riIi3MljoAkmmbbmKr)RUUxe52CuOWai3j(pZc4e0DHm9XkKaUtKxQf)cx1Jq8rihaWK(u(W4pYeeGJrPXjupYKGeIIFMfWjsLrIHmRhu06jMSwGkh(5DrgkugM1JSuKaZHNC8ZqIB1lKJXLrsw65POCK94MLxiZCEIcvwpYsrcmhEYXpdjUvVqUdtgjOxw65POCK94MLxiZCEAGbsmKCoTgpRhzjry7g8ABapk1oku0uyycZvjEqVI5Eb1Pb9XkKaUtKxQf)cx1Jq8rihaWK(u(W4pYetFjbuoUja5oLGeIIFMfWjsLrIHboxh52Cb5C1JZXWPlsc4U4NzbCc6UafQaNRJCBUGCU6X5y40fjbCx8ZSaoro0kJbsm0qAkmmbTMZJAkskOorHkl98uuoYECZYlKzopfZlA9IOq9fiIpMZtrfJebWLZUmgGcvwpYsrcmhEYXJGjNDzKbfkM1dkA9etwlqLd)8UidfQSEKLIeyo8KJhbdD2VqYxGi(yopfvmseaxo7YyGedjNtRXZ6rwse2UbV2gWJsTJcfnfgMWCvIh0RyUxqDAqFScjG7e5LAXVWv9ieFeYbamPOhZ6bfTEckhWqQHRhY8y9GrKGeIIFMfWjsLrIHgstHHjO1CEutrsb1jkuzPNNIYr2JBwEHmZ5PyErRxefQVar8XCEkQyKiaUC2LXauOY6rwksG5WtoEem5SlJmOqXSEqrRNyYAbQC4N3fzOqL1JSuKaZHNC8iyOZ(fs(ceXhZ5POIrIa4YzxgdKyi5CAnEwpYsIW2n412aEuQDuOOPWWeMRs8GEfZ9cQtd6JvibCNiVul(fUQhH4JqoGImCoggosik1(bamPpLpm(JmbbG4lX5y4j)nNNlIFf4ieXyif48CrjN)yIJeIc7IVmplKjXqdPPWWe0AopQPiPG6efQS0Ztr5i7XnlVqM58umVO1lIc1xGi(yopfvmseaxo7Yyakuz9ilfjWC4jhpcMC2LrguOywpOO1tmzTavo8Z7ImuOY6rwksG5WtoEem0z)cjFbI4J58uuXiraC5SlJbsmKCoTgpRhzjry7g8ABapk1oku0uyycZvjEqVI5Eb1Pb9XkKaUtKxQf2UbV2gWJhaWKQhZPLZQhcjgsoNwJN1JSKiSDdETnGhLZUe0JMcdtyUkXd6vm3lOorH6lqeFmNNIkgjcGJoKquc6rtHHjmxL4b9kM7fuNg0hRqc4orEPwqrgoiNjPpwHeWDI8sTGwZ5rCmQ)Y(yfsa3jYl1c69K9xboYbamP0uyyIFHR6ri(ieb1zFScjG7e5LAHgGCNeCRCureZ55bamP0uyyIFHR6ri(ierKBZLehnfgMGagYO)vx3lICBEFScjG7e5LAbg4hTMZJ9XkKaUtKxQfLhgj)sJhkTUpwHeWDI8sTGUqW5y45dcxjhaWKstHHj(fUQhH4JqerUnxsC0uyyccyiJ(xDDViYT5sOPWWeZ)czcQZ(yfsa3jYl1IqP14vibChxdi5bK8bHuQ9d8YCsl(oaGjLCoTgpRhzjry7g8ABapkN9(yfsa3jYl1INYXRqc4oUgqYd8YCsjahrp8SEKL9X(yfsa3jIIpPHYdtJttHHDGxMtkTUIJK838aaMuKqu8ZSaorQmsiCknnWJcmWtsCs(GRtcnfgMad8KeNKp46e)mlGtKqtHHjM)fYe)mlGtqhsi2hRqc4oru8jVulkpaMN4fwUNCZdxpaGjLMcdtm)lKjOoLe4CDKBZf)cx1Jq8riIFMfWjYDrFScjG7erXN8sTGCU6X5y40fjbC)aaMuAkmmX8VqMG6uYxidDmUm9XkKaUtefFYl1cADfhj5V5bap3)uNjoatksik(zwaNivgjeoLMg4rbg4jjojFW1jHMcdtGbEsItYhCDIFMfWjsOPWWeZ)czIFMfWjOdjepaGjLMcdtm)lKjOoLqoNwJN1JSKiSDdETnGhLdT9XkKaUtefFYl1Ia3JZ0paGj1qAkmmX8VqMG6efkAkmmXVWv9ieFeIG6uYt5dJ)itqaogLgNq9iZajmRhu06jMSwGkh(5DrwFScjG7erXN8sTGagYO)vx33hRqc4oru8jVul(Y8SqwFScjG7erXN8sTGCU6X5y40fjbC)aaMuAkmmX8VqMG6usGZ1rUnx8lCvpcXhHi(zwaNi3f9XkKaUtefFYl1cADfhj5V5bamP0uyyI5FHmXpZc4e5qcr0KqR4I(yfsa3jIIp5LAbtqi5)L4pf5UpwHeWDIO4tEPwampNhbocotqi5)L9X(yfsa3jccWr0dpRhzP8sT4leGJGtR52oaGj9P8HXFKjSb0ACogEEpC69K9x3lgdPaNNlkHMcdtydO14Cm88E407j7VUx8ZSaobDiHyFScjG7ebb4i6HN1JSuEPweEkYnWrWP1CBhaWK(u(W4pYe2aAnohdpVho9EY(R7fJHuGZZfLqtHHjSb0ACogEEpC69K9x3l(zwaNGoKqSpwHeWDIGaCe9WZ6rwkVulcLhMgNMcd7aVmNuADfhj5V5bamPKZP14z9iljcB3GxBd4rP2LGeIIFMfWjsLrIHzPNNcZIqQWpX8IwVikuboZ5LNcMZZ7lFX8IwVObsywpOO1tmzTavo8Z7Imjg(fYKZkidkuOxGZ1rUnxe4ECMU4NzbCIb9XkKaUteeGJOhEwpYs5LArG7Xz6haWKAinfgMy(xitqDIcfnfgM4x4QEeIpcrqDk5P8HXFKjiahJsJtOEKzGeM1dkA9etwlqLd)8UiRpwHeWDIGaCe9WZ6rwkVulcCpot)aaMuAkmmX8VqMG6ucZ6bfTEIjRfOYHFExK1hRqc4orqaoIE4z9ilLxQfeWqg9V66(daysJJMcdtqadz0)QR7frUnxIHKZP14z9iljcB3GxBd4r5SJc1xGi(yopfvmseaxo7xyqFScjG7ebb4i6HN1JSuEPw8L5zHSdaysnKMcdt8lCvpcXhHiOorHIMcdtyot(Fjohdxtfar84VYKiOonafkdPPWWeZ)czIFMfWjOdjerH6lKjNvqgdqHIMcdtG9ZTYEP4NzbCc6SlUOpwHeWDIGaCe9WZ6rwkVulcCpotVpwHeWDIGaCe9WZ6rwkVulkpaMN4fwUNCZdxpaGjLMcdtm)lKjOoLyi5CAnEwpYsIW2n412aEuo7Oq9fiIpMZtrfJebWL7WUWG(yfsa3jccWr0dpRhzP8sTGCU6X5y40fjbC)aaMuAkmmX8VqMG6uIHKZP14z9iljcB3GxBd4r5SJc1xGi(yopfvmseaxog)cd6JvibCNiiahrp8SEKLYl1IjRfOY1hRqc4orqaoIE4z9ilLxQf06kosYFZdaysPPWWeZ)czcQtjgIE0uyyIFHR6ri(ieXpZc4euO(czO7czmqIHKZP14z9iljcB3GxBd4rP2L8fiIpMZtrfJebWLJXVafkY50A8SEKLeHTBWRTb8Ou0AqFScjG7ebb4i6HN1JSuEPwqR58yEdEsEaatknfgMy(xite52CuOcCpsbsbtqaWPi4bUNZ8mfF5xL7cjz9ilf3R05T4mKOZQx0hRqc4orqaoIE4z9ilLxQf0Aopsx59bamP0uyyI5FHmrKBZrHkW9ififmbbaNIGh4EoZZu8LFvUlKK1JSuCVsN3IZqIoREHe0ll98ueEQPZlfZlA9I9XkKaUteeGJOhEwpYs5LAr8leUJ)86paGjLMcdtm)lKjOoLyi5CAnEwpYsIW2n412aEuo7Oq9fiIpMZtrfJebWLZ(fg0hRqc4orqaoIE4z9ilLxQfCNOlkK7SpwHeWDIGaCe9WZ6rwkVulSDdETnGhpaGjLMcdtyUpa0JqWP5(qEGh3lOoLqoNwJN1JSKiSDdETnGhLZQ9XkKaUteeGJOhEwpYs5LAXxiahbNwZTDaatA4UEKrKIwuOOPWWe)cx1Jq8ricQtjmRhu06jMSwGkh(5DrMKS0ZtHzriv4NyErRxSpwHeWDIGaCe9WZ6rwkVulcpf5g4i40AUTdaysd31JmIu0IcfnfgM4x4QEeIpcrqDkHz9GIwpXK1cu5WpVlYKKLEEkmlcPc)eZlA9I9XkKaUteeGJOhEwpYs5LAbTMZJ5n4jzFScjG7ebb4i6HN1JSuEPwqR58iDL39XkKaUteeGJOhEwpYs5LAXxiahbNwZT1hRqc4orqaoIE4z9ilLxQfHNICdCeCAn3wFScjG7ebb4i6HN1JSuEPwy7g8ABapQsvQu]] )


end
