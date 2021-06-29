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


    spec:RegisterPack( "Fury", 20210628, [[d0K17aqibvEKuv2eH8juvAusjDkPeRcvfQEfQQMLGYTGkAxe9lkOHrr6yuultQQEMuLmnPkY1eeBtQs13KQOghQk6CqsvRJIOMhuH7HQSpOshKIilKc5HueAIue0fLQu2OGQOpIQcPrkOkDsiPKvkLAMcQQBcjLQDsHAOcQclfskEksMkf4QOQqSvuvWxPiWyHKk7LK)cLbd6WkwmbpwOjtPlRAZi1NHy0sLtR0QrvHYRHeZMu3wGDl63OmCP44qswoWZrmDQUoQSDOQVtOgVufoVG06HKsz(qQ9lzLzLbkk74xzC)M2Vzt79(5tz)9ketdHpvuEOnxr1mrugKROYj4kQWtoqOkQMjunBSkduueghiEfvN7net2qdrwVJtqgzbgs2ao94llJGH2nKSbrdvucCR2rTsLGIYo(vg3VP9B20EVF(u2FVcX0qcrrnCEhdOOO2atSGgwqtce72aFbmIIQBT2NkbfL9KOIk8KdeAbnbdaSmq1Unx(c2pFgwb730(nxTR2My3KiNyYvBCwqtYAVTGHhCbbxlR24SGMWLmc6Blyad)dE6f0WcgEpGTXcg(FAkyC06c2AY8cM)2BlinduWnXjYe8cgzP)E4TiR24SGO2z4VTGgPh7jodeuWjTf0ecgewwqudBafCey4FbnsZywVBbeVGoRGBqdGH)fKgCuX9mgAbz0fe8ili4PD8LLKc2kzdifeW4q60HwWJkUr3ISAJZcAsw7Tf0OXD9livhJZlOZkyd4rwGW4f0KcpcFz1gNf0KS2BliFyJodeAbrnCKUcocm8VGKnr0hN(aqUxqtq3c0I30kR24SGMK1EBb5JqEbrT8hqKvBCwqde)bLcsZaf0e0TaT4nTfu40mWlO(4VUG9QNLvBCwquZdy4VTG9gH8mEISAJZcAczjF9cYrEbP2JCbWhuoOGlDbxNVKcoAWhBOfKRPGTAc)4Dbdkh0ISAJZcsDNRPG0dkVGKJkUNXtkinduqQfjVxqwZZdKkk9sCIYaffzte9X8bGCxzGYyZkduuphb9TkJuurW6hSJIcWLNMbqUu8Q1ymAmV7ychqoaLdKhvCBtZTfuubf4OPLIxTgJrJ5Dht4aYbOCGe8GztsbXrbrIwf1e9LLkkWGSjcMGMjw5kJ7xzGI65iOVvzKIkcw)GDuuaU80maYLIxTgJrJ5Dht4aYbOCG8OIBBAUTGIkOahnTu8Q1ymAmV7ychqoaLdKGhmBskiokis0QOMOVSurbgKnrWe0mXkxzCVugOOEoc6BvgPOIG1pyhffP5AnMpaK7eP4UfOfVPTG8kO5ckQGirRe8Gztsb5vqtlOOc2Ab9r)0LbdHmrWLphb9Tfen6cgz4FoPlX)07cfuWwkOOcIFa7iOV894ro)ynDd5fuubBTGGb5fe3cI6nTGOrxWWvWiJPTmXPmYs7dsj4bZMKc2IIAI(YsfvCY41ycC00kkboAASCcUIsqp2tCgiq5kJ7jLbkQNJG(wLrkQiy9d2rrjWrtlFcgKlbpy2KuqClis0wq(4fSFzifuubjnxRX8bGCNif3TaT4nTfe3cAwrnrFzPIsqp2tCgiq5kJdrzGI65iOVvzKIkcw)GDuucC00YNGb5sUMckQG4hWoc6lFpEKZpwt3qUIAI(YsfvKL2hKkxzCVRmqr9Ce03QmsrfbRFWokk7f4OPLK9ixa8bLdKwM4SGIkyRfK0CTgZhaYDIuC3c0I30wqClO5cIgDbbZAXo(NUCSwICZcIBbnhsbBrrnrFzPIISh5cGpOCGYvg3Zkduuphb9TkJuurW6hSJIQ1ckWrtlbpII(esEcrY1uq0OlOahnTm4bmqOymAmnxCTywWNaIKRPGTuq0OlyRfuGJMw(emixcEWSjPG4OGirBbrJUGGb5fe3cI6nTGTuq0OlOahnTKg8e1wOsWdMnjfehf0Smef1e9LLkkWe0mix5kJ5tLbkQj6llvurwAFqQOEoc6BvgPCLXOELbkQNJG(wLrkQiy9d2rrjWrtlFcgKl5AkOOc2AbjnxRX8bGCNif3TaT4nTfe3cAUGOrxqWSwSJ)PlhRLi3SG4wWEoKc2IIAI(Ysf1KX9PJn0(bKowefLRm2SPkduuphb9TkJuurW6hSJIsGJMw(emixY1uqrfS1csAUwJ5da5orkUBbAXBAliUf0CbrJUGGzTyh)txowlrUzbXTG9uifSff1e9LLkksZhagJgtyi(YsLRm2SzLbkQj6llvuVhpY5xr9Ce03Qms5kJn3VYaf1ZrqFRYifveS(b7OOe4OPLpbdYLCnfuubBTGHRGcC00sWJOOpHKNqKGhmBskiA0femiVG4OGHyAbBPGIkiP5AnMpaK7eP4UfOfVPTG8kO5ckQGGzTyh)txowlrUzbXTG9uikQj6llvuc6XEIZabkxzS5EPmqr9Ce03QmsrfbRFWokkboAA5tWGCjxtbfvqsZ1AmFai3jsXDlqlEtBb5vqZfuubbZAXo(NUCSwICZcIBb7PquuB6ha4ACSLwrrAUwJ5da5orkUBbAXBA5zwes0kbpy2KWZurTcgKJlQ3u0OXpGDe0x(E8iNFSMUHCrHlYyAltCkJS0(GucEWSjPff1e9LLkkb9ypXzGaf1M(baUghdrZegTIYSYvgBUNugOOEoc6BvgPOIG1pyhfLahnT8jyqUKRPGIkyRfK0CTgZhaYDIuC3c0I30wqClO5cIgDbbZAXo(NUCSwICZcIBbnhsbBrrnrFzPIYcgewIbydq5kJnhIYaf1ZrqFRYifveS(b7OOe4OPLpbdYLwM4SGOrxWilTCRlXVXLXrWIS0FqJlbtIsbXTGHuqrf0haYDz3hT3jBIEbXrb7vifuubdxb9r)0Lra31EOYNJG(wf1e9LLkkbnJz9UfqCLRm2CVRmqr9Ce03QmsrfbRFWokkboAA5tWGCPLjoliA0fmYsl36s8BCzCeSil9h04sWKOuqClyifuub9bGCx29r7DYMOxqCuWEfsbfvWWvqF0pDzeWDThQ85iOVvrnrFzPIsqZywVBbex5kJn3Zkduuphb9TkJuurW6hSJIsGJMw(emixY1uqrfS1csAUwJ5da5orkUBbAXBAliUf0CbrJUGGzTyh)txowlrUzbXTGMdPGTOOMOVSurzbdclXaSbOCLXM5tLbkQNJG(wLrkQiy9d2rrjWrtldoiU6tiycS8iGnThi5AkOOcsAUwJ5da5orkUBbAXBAliUfSxkQj6llvuI7wGw8MwLRm2mQxzGIAI(Ysfflj6HdPZvuphb9TkJuUY4(nvzGI65iOVvzKIkcw)GDuuXUbGCsb5vW(liA0fuGJMwcEef9jK8eIKRPGIki(bSJG(Y3Jh58J10nKxqrf0h9txgmeYebx(Ce03QOMOVSurbgKnrWe0mXkxzC)MvgOOEoc6BvgPOIG1pyhfvSBaiNuqEfSFf1e9LLkkWGSjcMGMjw5kJ7VFLbkQj6llvucAgZ6DlG4kQNJG(wLrkxzC)9szGIAI(YsfLGMXSE3ciUI65iOVvzKYvg3FpPmqrnrFzPIcmiBIGjOzIvuphb9TkJuUY4(drzGIAI(Ysffyq2ebtqZeROEoc6BvgPCLX937kduut0xwQOe3TaT4nTkQNJG(wLrkxzC)9SYaf1e9LLkk8B0zGqXaCKof1ZrqFRYiLRmUF(uzGIAI(Ysf1g080Ujcg(n6mqOkQNJG(wLrkx5kk7PhoTRmqzSzLbkQNJG(wLrkQj6llvuXUbGCfL9KiyB8LLkktSBaiVGlDbfF(cEb1SePGndXliJduqwZZdcRGmqbf)cAzjF9cM)2c6DVGSMNhuWilqGvqAgOGulsEVGTMSeN8HNExOGwKkQiy9d2rr5BWliUfKpliA0f0h9txAzCc6J5BWLphb9Tfen6corFXFSNpypPG4wqZfen6cgz4FoPlX)07cfuq0Oly4kiGlpndGCjzrY7ymAmNbcE63IHYMie5rf320CBbrJUGrgtBzItj4ru0NqYtisWdMnjfe3cIeTkxzC)kduut0xwQOA4ccUwr9Ce03Qms5kJ7LYaf1ZrqFRYiffRrrrUROMOVSurHFa7iOVIc)O5UIYh9txgmeYebx(Ce03wqrf0haYDz3hT3jBIEbXrb7vifen6c6da5US7J27KnrVG4OG9BAbrJUG(aqUl7(O9ozt0liUfKpnTGIkyKH)5KUe)tVluGIc)aWYj4kQ3Jh58J10nKRCLX9KYaf1ZrqFRYif1e9LLkkbnJz9UfqCfLEZJfTkkZMQOIG1pyhfLVbVG4OG8zbfvWj6l(J98b7jfKxbnxqrfeWLNMbqUKSi5DmgnMZabp9BXqzteI8OIBBAUTGIkyRfmCfmYW)CsxI)P3fkOGOrxWiJPTmXPe8ik6ti5jej4bZMKcIdEfejAlylkk7jrW24llvu9waNE8tk4MRVJUGgPzmR3TaIxqYrf3Z4linduqYMi6JtFai3li)fKArY7sLRmoeLbkQNJG(wLrkQj6llvuGhrrFcjpHOO0BESOvrz2ufveS(b7OO8n4fehfKplOOcorFXFSNpypPG8kO5ckQGrg(Nt6s8p9UqbfuubbC5PzaKljlsEhJrJ5mqWt)wmu2eHipQ42MMBlOOc2aoEPGMXSE3ciUIYEseSn(YsfvVfWPh)KcU567OliQ5ru0NqYtifKCuX9m(csZafKSjI(40haY9cYFb5dp9UqbfK)csTi5DPYvg37kduuphb9TkJuut0xwQO6oGTrm9NgfLEZJfTkkZMQOIG1pyhff5UVjcr2DaBJyXUbG8ckQG(g8cIJcgsbfvWj6l(J98b7jfKxbnxqrfmCfmYW)CsxI)P3fkOGIkiGlpndGCjzrY7ymAmNbcE63IHYMie5rf320CBbfvWgWXlf0mM17waXlOOcgzmTLjoLXUbGCj4bZMKcIJcAQmefL9KiyB8LLkQElGtp(jfCZ13rxWW7bSnwWW)ttbXTGMy3aqEbjhvCpJVG0mqbjBIOpo9bGCVG8xWKL4Kp807cfuq(li1IK3LkxzCpRmqr9Ce03QmsrnrFzPIk2naKRO0BESOvrz2ufveS(b7OOi39nriYUdyBel2naKxqrf03GxqCuWqkOOcorFXFSNpypPG8kO5ckQGHRGrg(Nt6s8p9UqbfuubbC5PzaKljlsEhJrJ5mqWt)wmu2eHipQ42MMBlOOc2aoEz3bSnIP)0OOSNebBJVSur1BbC6XpPGBU(o6cgEpGTXcg(FAkiUf0e7gaYli5OI7z8fKMbkizte9XPpaK7fK)cMSeN8HNExOGcYFbPwK8Uu5kJ5tLbkQj6llvunmFzPI65iOVvzKYvgJ6vgOOEoc6BvgPOIG1pyhfvKX0wM4ucEef9jK8eIe8GztsbXrb7vbfvqF0pDj4ru0NqWgHjTSu(Ce03QOMOVSurbMGMb5kxzSztvgOOEoc6BvgPOIG1pyhfLahnTe8ik6ti5jePLjolOOcAVahnTKSh5cGpOCG0YeNfen6csViDog4bZMKcIJcgIPkQj6llvurwIkUdyacMWK5bkxzSzZkduuphb9TkJuurW6hSJIkCfeWLNMbqUKSi5DmgnMZabp9BXqzteI8OIBBAUTGIkyRfS1ckWrtlf0mMvZrCjxtbrJUG(OF6YjroalyYb5bpD5ZrqFBbrJUGGzTyh)txowlrUzbXTGMnTGTuq0OlOpaK7sFdoMZWS7liUf0SPMwq0Oli(bSJG(Y3Jh58J10nKxq0OlOpaK7sFdoMZWS7liokO5qkOOccM1ID8pD5yTe5Mfe3cA20c2sbfvWwliP5AnMpaK7eP4UfOfVPTG8kO5cIgDbf4OPLbFCSO(d(dKCnfSff1e9LLkkWJOOpHKNquUYyZ9Rmqr9Ce03QmsrfbRFWokkaxEAga5sYIK3Xy0yode80VfdLnriYJkUTP52ckQGnGJhdjALMLGjOzqEbfvWwlyRfuGJMwkOzmRMJ4sUMcIgDb9r)0LtICawWKdYdE6YNJG(2cIgDbbZAXo(NUCSwICZcIBbnBAbBPGOrxqFai3L(gCmNHz3xqClOztnTGOrxq8dyhb9LVhpY5hRPBiVGOrxqFai3L(gCmNHz3xqCuqZHuqrfemRf74F6YXAjYnliUf0SPfSLckQGTwqsZ1AmFai3jsXDlqlEtBb5vqZfen6ckWrtld(4yr9h8hi5AkylkQj6llvuGhrrFcjpHOO4ihJrtJHeTkJnRCLXM7LYaf1ZrqFRYifveS(b7OO0h)1fe3c2REVGIkyRfK0CTgZhaYDIuC3c0I30wqClO5ckQGHRGcC00YGpowu)b)bsUMcIgDbbZAXo(NUCSwICZcIJcIeTfuubdxbf4OPLbFCSO(d(dKCnfSff1e9LLkkXDlqlEtRYvgBUNugOOMOVSurXro26pGOOEoc6BvgPCLXMdrzGIAI(YsfLGMXSy0CGqvuphb9TkJuUYyZ9UYaf1ZrqFRYifveS(b7OOe4OPLGhrrFcjpHi5Auut0xwQOeoGCakBIOCLXM7zLbkQNJG(wLrkQiy9d2rrjWrtlbpII(esEcrAzIZckQG2lWrtlj7rUa4dkhiTmXPIAI(YsfLEr6CcgFmolsWtx5kJnZNkduut0xwQOOxWf0mMvr9Ce03Qms5kJnJ6vgOOMOVSurnz8ehmAS4O1kQNJG(wLrkxzC)MQmqr9Ce03QmsrfbRFWokkboAAj4ru0NqYtisltCwqrf0EboAAjzpYfaFq5aPLjolOOckWrtlFcgKl5Auut0xwQOegemgnMd2ikeLRmUFZkduuphb9TkJuut0xwQOaCj2e9LLy6L4kk9sCSCcUIISjI(y(aqURCLROAapYcegxzGYyZkduut0xwQOeg31hJ0X4Cf1ZrqFRYiLRmUFLbkQNJG(wLrkQiy9d2rrfUcc4YtZaixswK8ogJgZzGGN(TyOSjcrEuXTnn3QOMOVSurbEef9jK8eIYvUYvu4pGSSuzC)M2Vzt79(7zfL4bKBIquuMatc1ymQLX8rn5cwqd6Eb3GggWlinduq(s2erFmFai35BbbhvCl42csybVGdNZcg)2cg7Me5ez1o838fSxMCbnrwI)a)2cY3id)ZjDjQt(Ce03Y3c6ScY3id)ZjDjQJVfSvZ9Ofz1UABcmjuJXOwgZh1KlybnO7fCdAyaVG0mqb5R90dN25BbbhvCl42csybVGdNZcg)2cg7Me5ez1o838fSxMCbnrwI)a)2cYxF0pDjQJVf0zfKV(OF6suN85iOVLVfSvZ9Ofz1o838fmetUGMilXFGFBb5BKH)5KUe1jFoc6B5BbDwb5BKH)5KUe1X3c2Q5E0ISAh(B(c27MCbnrwI)a)2cY3id)ZjDjQt(Ce03Y3c6ScY3id)ZjDjQJVfSvZ9Ofz1o838fSNn5cAISe)b(TfKVrg(Nt6suN85iOVLVf0zfKVrg(Nt6suhFlyRM7rlYQD1g1kOHb8BlyVk4e9LLfuVeNiR2kksZJkJ75(vunag9QVIQV(ky4jhi0cAcgayzGQDF9vW2C5ly)8zyfSFt73C1UA3xFf0e7Me5etUA3xFfeNf0KS2Bly4bxqW1YQDF9vqCwqt4sgb9TfmGH)bp9cAybdVhW2ybd)pnfmoADbBnzEbZF7TfKMbk4M4ezcEbJS0Fp8wKv7(6RG4SGO2z4VTGgPh7jodeuWjTf0ecgewwqudBafCey4FbnsZywVBbeVGoRGBqdGH)fKgCuX9mgAbz0fe8ili4PD8LLKc2kzdifeW4q60HwWJkUr3ISA3xFfeNf0KS2BlOrJ76xqQogNxqNvWgWJSaHXlOjfEe(YQDF9vqCwqtYAVTG8Hn6mqOfe1Wr6k4iWW)cs2erFC6da5EbnbDlqlEtRSA3xFfeNf0KS2BliFeYliQL)aISA3xFfeNf0aXFqPG0mqbnbDlqlEtBbfond8cQp(RlyV6zz1UV(kioliQ5bm83wWEJqEgprwT7RVcIZcAczjF9cYrEbP2JCbWhuoOGlDbxNVKcoAWhBOfKRPGTAc)4Dbdkh0ISA3xFfeNfK6oxtbPhuEbjhvCpJNuqAgOGulsEVGSMNhiR2v7(6RG9wpEKZVTGcNMbEbJSaHXlOWr2KilOjfJVXjfmzjo7gqanNUGt0xwskil1HkR2t0xwsKnGhzbcJZppdfg31hJ0X48Q9e9LLezd4rwGW48ZZqWJOOpHKNqcBP5foaxEAga5sYIK3Xy0yode80VfdLnriYJkUTP52QD1UV(kyV1Jh58Bl4XFqOf03GxqV7fCIoduWLuWb)S6rqFz1UVcAIDda5fCPlO4ZxWlOMLifSziEbzCGcYAEEqyfKbkO4xqll5RxW83wqV7fK188GcgzbcScsZafKArY7fS1KL4Kp807cf0ISAprFzjHxSBaipSLMNVbhx(enAF0pDPLXjOpMVbx(Ce03Ig9e9f)XE(G9eCnJgDKH)5KUe)tVluaA0HdWLNMbqUKSi5DmgnMZabp9BXqzteI8OIBBAUfn6iJPTmXPe8ik6ti5jej4bZMeCrI2Q9e9LLe(5zydxqW1v7j6llj8ZZq8dyhb9dlNGZ794ro)ynDd5HHF0CNNp6NUmyiKjcUiFai3LDF0ENSj64OxHGgTpaK7YUpAVt2eDC0VPOr7da5US7J27Knrhx(0urrg(Nt6s8p9Uqbv7(6RGg0TKcUKcgWiUo0c6Sc2ao(NEbJmM2YeNKcsdybfu4BIuWjgx7tF06qlih52cA5aBIuWag(h80Lv7(6RGt0xws4NNHaUeBI(Ysm9s8WYj48cy4FWtpSLMxad)dE6s7s8jJh3qQ291xbNOVSKWppd7oGTrm9NMWwAETcM1ID8pDzad)dE6s7s8jJh3(dreywl2X)0Lbm8p4Pl3e3EkKwQ291xbNOVSKWppdjhvCpJpSLM3e9f)XE(G9eEMffz4FoPlX)07cfiFoc6Bfb4YtZaixswK8ogJgZzGGN(TyOSjcrEuXTnn3gwobNNrgic18ikMSGMXSE3ciUjdEef9jK8es1UVc2BbC6XpPGBU(o6cAKMXSE3ciEbjhvCpJVG0mqbjBIOpo9bGCVG8xqQfjVlR2t0xws4NNHcAgZ6DlG4HP38yrlpZMg2sZZ3GJd(u0e9f)XE(G9eEMfb4YtZaixswK8ogJgZzGGN(TyOSjcrEuXTnn3kQ1Wfz4FoPlX)07cfGgDKX0wM4ucEef9jK8eIe8Gztco4HeTTuT7RG9waNE8tk4MRVJUGOMhrrFcjpHuqYrf3Z4linduqYMi6JtFai3li)fKp807cfuq(li1IK3Lv7j6llj8ZZqWJOOpHKNqctV5XIwEMnnSLMNVbhh8POj6l(J98b7j8mlkYW)CsxI)P3fkq(Ce03kcWLNMbqUKSi5DmgnMZabp9BXqzteI8OIBBAUvud44LcAgZ6DlG4v7(6RGt0xws4NNHKJkUNXh2sZBI(I)ypFWEcpZIcxKH)5KUe)tVluG85iOVveGlpndGCjzrY7ymAmNbcE63IHYMie5rf320CBy5eCEgzGitSBai3Kf0mM17waXn5UdyBel2naKxT7RG9waNE8tk4MRVJUGH3dyBSGH)NMcIBbnXUbG8csoQ4EgFbPzGcs2erFC6da5Eb5VGjlXjF4P3fkOG8xqQfjVlR2t0xws4NNHDhW2iM(tty6npw0YZSPHT08i39nriYUdyBel2naKlY3GJJqenrFXFSNpypHNzrHlYW)CsxI)P3fkq(Ce03kcWLNMbqUKSi5DmgnMZabp9BXqzteI8OIBBAUvud44LcAgZ6DlG4IImM2YeNYy3aqUe8Gztcomvgs1UVc2BbC6XpPGBU(o6cgEpGTXcg(FAkiUf0e7gaYli5OI7z8fKMbkizte9XPpaK7fK)cMSeN8HNExOGcYFbPwK8USAprFzjHFEgg7gaYdtV5XIwEMnnSLMh5UVjcr2DaBJyXUbGCr(gCCeIOj6l(J98b7j8mlkCrg(Nt6s8p9UqbYNJG(wraU80maYLKfjVJXOXCgi4PFlgkBIqKhvCBtZTIAahVS7a2gX0FAQ2t0xws4NNHnmFzz1EI(Ysc)8membndYdBP5fzmTLjoLGhrrFcjpHibpy2KGJEjYh9txcEef9jeSrysllLphb9Tv7j6llj8ZZWilrf3bmabtyY8GWwAEcC00sWJOOpHKNqKwM4uK9cC00sYEKla(GYbsltCIgn9I05yGhmBsWriMwTNOVSKWppdbpII(esEcjSLMx4aC5PzaKljlsEhJrJ5mqWt)wmu2eHipQ42MMBf1ARcC00sbnJz1CexY1GgTp6NUCsKdWcMCqEWtx(Ce03Ignywl2X)0LJ1sKBIRztBbnAFai3L(gCmNHz3JRztnfnA8dyhb9LVhpY5hRPBihnAFai3L(gCmNHz3JdZHicmRf74F6YXAjYnX1SPTiQvsZ1AmFai3jsXDlqlEtlpZOrlWrtld(4yr9h8hi5AAPAprFzjHFEgcEef9jK8esyCKJXOPXqIwEMdBP5b4YtZaixswK8ogJgZzGGN(TyOSjcrEuXTnn3kQbC8yirR0SembndYf1ARcC00sbnJz1CexY1GgTp6NUCsKdWcMCqEWtx(Ce03Ignywl2X)0LJ1sKBIRztBbnAFai3L(gCmNHz3JRztnfnA8dyhb9LVhpY5hRPBihnAFai3L(gCmNHz3JdZHicmRf74F6YXAjYnX1SPTiQvsZ1AmFai3jsXDlqlEtlpZOrlWrtld(4yr9h8hi5AAPAprFzjHFEgkUBbAXBAdBP5Pp(RXTx9UOwjnxRX8bGCNif3TaT4nT4Awu4e4OPLbFCSO(d(dKCnOrdM1ID8pD5yTe5M4ajAffoboAAzWhhlQ)G)ajxtlv7j6llj8ZZqoYXw)bKQ9e9LLe(5zOGMXSy0CGqR2t0xws4NNHchqoaLnrcBP5jWrtlbpII(esEcrY1uTNOVSKWppd1lsNtW4JXzrcE6HT08e4OPLGhrrFcjpHiTmXPi7f4OPLK9ixa8bLdKwM4SAprFzjHFEgsVGlOzmB1EI(Ysc)8mCY4joy0yXrRR2t0xws4NNHcdcgJgZbBefsylnpboAAj4ru0NqYtisltCkYEboAAjzpYfaFq5aPLjofjWrtlFcgKl5AQ2t0xws4NNHaUeBI(Ysm9s8WYj48iBIOpMpaK7v7Q9e9LLejzte9X8bGCNFEgcgKnrWe0mXHT08aC5PzaKlfVAngJgZ7oMWbKdq5a5rf320CRiboAAP4vRXy0yE3XeoGCakhibpy2KGdKOTAprFzjrs2erFmFai35NNHrahPBtembntCylnpaxEAga5sXRwJXOX8UJjCa5auoqEuXTnn3ksGJMwkE1AmgnM3DmHdihGYbsWdMnj4ajAR2t0xwsKKnr0hZhaYD(5zyCY41ycC00HLtW5jOh7jodee2sZJ0CTgZhaYDIuC3c0I30YZSiKOvcEWSjHNPIA1h9txgmeYebx(Ce03IgDKH)5KUe)tVluG85iOVTfr4hWoc6lFpEKZpwt3qUOwbdYXf1BkA0HlYyAltCkJS0(GucEWSjPLQ9e9LLejzte9X8bGCNFEgkOh7jodee2sZtGJMw(emixcEWSjbxKOLpE)YqerAUwJ5da5orkUBbAXBAX1C1EI(YsIKSjI(y(aqUZppdJS0(GmSLMNahnT8jyqUKRre(bSJG(Y3Jh58J10nKxTNOVSKijBIOpMpaK78ZZqYEKla(GYbHT08SxGJMws2JCbWhuoqAzItrTsAUwJ5da5orkUBbAXBAX1mA0GzTyh)txowlrUjUMdPLQ9e9LLejzte9X8bGCNFEgcMGMb5HT08AvGJMwcEef9jK8eIKRbnAboAAzWdyGqXy0yAU4AXSGpbejxtlOr3QahnT8jyqUe8GztcoqIw0ObdYXf1BAlOrlWrtlPbprTfQe8GztcomldPAprFzjrs2erFmFai35NNHrwAFqwTNOVSKijBIOpMpaK78ZZWjJ7thBO9diDSikHT08e4OPLpbdYLCnIAL0CTgZhaYDIuC3c0I30IRz0ObZAXo(NUCSwICtC75qAPAprFzjrs2erFmFai35NNHKMpamgnMWq8LLHT08e4OPLpbdYLCnIAL0CTgZhaYDIuC3c0I30IRz0ObZAXo(NUCSwICtC7PqAPAprFzjrs2erFmFai35NNHVhpY5VAprFzjrs2erFmFai35NNHc6XEIZabHT08e4OPLpbdYLCnIAnCcC00sWJOOpHKNqKGhmBsqJgmihhHyAlIinxRX8bGCNif3TaT4nT8mlcmRf74F6YXAjYnXTNcPAprFzjrs2erFmFai35NNHc6XEIZabHT08e4OPLpbdYLCnIinxRX8bGCNif3TaT4nT8mlcmRf74F6YXAjYnXTNcjSn9daCnogIMjmAEMdBt)aaxJJT08inxRX8bGCNif3TaT4nT8mlcjALGhmBs4zQOwbdYXf1BkA04hWoc6lFpEKZpwt3qUOWfzmTLjoLrwAFqkbpy2K0s1EI(YsIKSjI(y(aqUZppdTGbHLya2acBP5jWrtlFcgKl5Ae1kP5AnMpaK7eP4UfOfVPfxZOrdM1ID8pD5yTe5M4AoKwQ2t0xwsKKnr0hZhaYD(5zOGMXSE3ciEylnpboAA5tWGCPLjorJoYsl36s8BCzCeSil9h04sWKOGBiI8bGCx29r7DYMOJJEfIOW5J(PlJaUR9qLphb9Tv7j6lljsYMi6J5da5o)8muqZywHX7cBP5jWrtlFcgKlTmXjA0rwA5wxIFJlJJGfzP)GgxcMefCdrKpaK7YUpAVt2eDC0RqefoF0pDzeWDThQ85iOVTAprFzjrs2erFmFai35NNHwWGWsmaBaHT08e4OPLpbdYLCnIAL0CTgZhaYDIuC3c0I30IRz0ObZAXo(NUCSwICtCnhslv7j6lljsYMi6J5da5o)8muC3c0I30g2sZtGJMwgCqC1NqWey5raBApqY1iI0CTgZhaYDIuC3c0I30IBVQ2t0xwsKKnr0hZhaYD(5zilj6HdPZR2t0xwsKKnr0hZhaYD(5ziyq2ebtqZeh2sZl2naKt41pA0cC00sWJOOpHKNqKCnIWpGDe0x(E8iNFSMUHCr(OF6YGHqMi4YNJG(2Q9e9LLejzte9X8bGCNFEggbCKUnrWe0mXHT08IDda5eE9xTNOVSKijBIOpMpaK78ZZqbnJz9Ufq8Q9e9LLejzte9X8bGCNFEgkOzmRW4Dv7j6lljsYMi6J5da5o)8memiBIGjOzIR2t0xwsKKnr0hZhaYD(5zyeWr62ebtqZexTNOVSKijBIOpMpaK78ZZqXDlqlEtB1EI(YsIKSjI(y(aqUZppdXVrNbcfdWr6Q2t0xwsKKnr0hZhaYD(5z4g080Ujcg(n6mqOkx5kfa]] )


end
