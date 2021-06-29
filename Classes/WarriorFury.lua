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


    spec:RegisterPack( "Fury", 20210629, [[d00Vcbqivs8iivTjc6tuQAueOtriEfPOzPs0Tia7IOFrPyyeshJuzzQK6zQaMgPeDnvcBdQK8nvsQXPcKZbPswhuPAEqfUhHAFKchKusTqkLEiujMiPK0fvbQnQss0hjLqmsvssNeQKYkvHMjuPCtsjK2jLk)uLKqdLuc1sHuPEkQAQKsDvvsc2kPe8vsjXyHuXEP4VqzWQ6WsTyu5XsAYsCzLnJuFgIrdjNgy1qLu1RHuMnj3Ms2nv)gLHRIoourlh0ZrmDHRJKTdv9DsvJNa68QGwpujvMVk1(fTrNrBdFPJzS7ArVwNO4QRrxsD6U4a6m8XHNZWF2v0AKz492Ag(Rsk4Hg(Z(qfRlgTn8egfSodpQioj4Un2GacuuCYkZYgcWIs1bG5vyth2qawvBm8CuavGR5godFPJzS7ArVwNO4QRrxsD6U4aIQLg(MkqXGgEEGfUKVn5R1WkkGvaGmIHhfOuMB4m8LrQg(Rsk4H5RvAieWG5XJu(Y)A01L5FTOxRlpMhXfuTJmcUNhfq(ADPSs(AXuwwtjZJciFTkG0CQvY3IHFwZJ8Tj)R6GmqnFCB9z(1wPYxqNf57BLvYNMbZh4caPTw(vMhtGHiY8OaYxlkd)k5BRQlJemOv(TxYxRcBeMNp6M1W8Bog(LVTkgReOaqsKFWYhyDcz4x(0WHtQ51dZNrNpCvML18shaMtYxqcWIKpKrHGsDy(dNuTsezEua5R1LYk5BBhHA5ZJIrf5hS8pHRYS46iFTwlg3K5rbKVwxkRKVwaudg8W8r3ueu53Cm8lFcWrutardrwKVwbfaQ0d8ImpkG816szL8Vkqw(4AXSiY8OaYxB9RrlFAgmFTckauPh4L85gndU8vd)u5FGRwMhfq(O7zXWVs(hmHmVoImpkG81Qm3(iFkYYNhmKXbxJ2G5dOZhe2tYVvW1LdZN6mFb1QRduwnAdkImpkG85xqDMpDJ2YNmCsnVos(0my(8aeFr(SZ5dkn8kajigTn8eGJOgw0qKfgTn2PZOTHFEZPwXyRHVcbXGG2WdP8rZGitQhOuymASa1W4gKmiAdkhoPaNNRKVW85OOPL6bkfgJglqnmUbjdI2Gs4SAGtYhh5Julg(UgaMB4HncWrW4um9MWy31gTn8ZBo1kgBn8viige0gEiLpAgezs9aLcJrJfOgg3GKbrBq5Wjf48CL8fMphfnTupqPWy0ybQHXnizq0gucNvdCs(4iFKAXW31aWCdpSraocgNIP3eg7oGrBd)8MtTIXwdFfcIbbTHNCoLclAiYcIupkauPh4L8fNVU8fMpsTiHZQbojFX5lA(cZxW8JwnpKwnH0v4KZBo1k5FFNFLHFE7He)8a1HW8fjFH5JVHGMtn5e4QuXWor1KLVW8fmFyJS81iF0LO5FFN)vYVYyQctVlRmVmlxcNvdCs(Iy47AayUHV2EDkmokAAdphfnnM3wZWZP6YibdAzcJDAPrBd)8MtTIXwdFfcIbbTHxW85OOPLZHnYKuN5FFNphfnTeUkAQri(iej1z(cZhs5JMbrMKaCAkfgHcIm58MtTs(IKVW8X3qqZPMCcCvQyyNOAYm8Dnam3WxzEzwUjm2DHrBd)8MtTIXwdFfcIbbTHNJIMwoh2itsDMVW8X3qqZPMCcCvQyyNOAYm8Dnam3WxzEzwUjm2HRmAB4N3CQvm2A4RqqmiOn8LXrrtljGHmo4A0guwy698fMVG5toNsHfnezbrQhfaQ0d8s(AKVU8VVZh2Gc2WppKDPqKapFnYx3f5lIHVRbG5gEcyiJdUgTbnHXUR2OTHFEZPwXyRHVcbXGG2Wly(Cu00s4QOPgH4JqKuN5FFNphfnT0Awm4HymAmfvfuWkW1wej1z(IK)9D(cMphfnTCoSrMeoRg4K8Xr(i1s(335dBKLVg5JUenFrY)(oFokAAjnCoUUdLWz1aNKpoYxN8cdFxdaZn8W26SrMjm2DqgTn8Dnam3WxzEzwUHFEZPwXyRjm2HUmAB4N3CQvm2A4RqqmiOn8Cu00Y5WgzsQZ8fMVG5toNsHfnezbrQhfaQ0d8s(AKVU8VVZh2Gc2WppKDPqKapFnY)QViFrm8Dnam3W3EfmpWA6yqckwfntyStNOgTn8ZBo1kgBn8viige0gEokAA5CyJmj1z(cZxW8jNtPWIgISGi1Jcav6bEjFnYxx(335dBqbB4NhYUuisGNVg5RLxKVig(UgaMB4jNRHymAmUMeaMBcJD60z02W31aWCd)e4QuXm8ZBo1kgBnHXoDxB02WpV5uRyS1WxHGyqqB45OOPLZHnYKuN5lmFbZ)k5ZrrtlHRIMAeIpcrcNvdCs(335dBKLpoY)crZxK8fMVG5toNsHfnezbrQhfaQ0d8s(IZxx(cZh2Gc2WppKDPqKapFnYxlVi)778jNtPWIgISGi1Jcav6bEjFX5FD(Iy47AayUHNt1Lrcg0Yeg70DaJ2g(5nNAfJTg(keedcAdphfnTCoSrMSW075FFNFL5fkqiXdQagfbRY8ywNHe2oA5Rr(xKVW8JgISqIATkqjpRr(4i)dCHHVRbG5gEofJvcuaijmHXoDAPrBd)8MtTIXwdFfcIbbTHNJIMwoh2itwy698VVZVY8cfiK4bvaJIGvzEmRZqcBhT81i)lYxy(rdrwirTwfOKN1iFCK)bUiFH5FL8JwnpKvi1uXHY5nNAfdFxdaZn8CkgReOaqsycJD6UWOTHFEZPwXyRHVcbXGG2WZrrtlNdBKjPoZxy(cMp5Ckfw0qKfePEuaOspWl5Rr(6Y)(oFydkyd)8q2Lcrc881iFDxKVig(UgaMB4lWgH5yqwdnHXoD4kJ2g(UgaMB4zor1uiOcd)8MtTIXwtySt3vB02WpV5uRyS1WxHGyqqB45OOPLwdwbQriyCmFiqGxgusDMVW8jNtPWIgISGi1Jcav6bEjFnY)ag(UgaMB41Jcav6bEXeg70DqgTn8ZBo1kgBn8viige0g(kQgIms(IZ)68VVZNJIMwcxfn1ieFeIK6mFH5JVHGMtn5e4QuXWor1KLVW8JwnpKwnH0v4KZBo1kg(UgaMB4HncWrW4um9MWyNo0LrBd)8MtTIXwdFfcIbbTHVIQHiJKV48Vo)7785OOPLWvrtncXhHiPoZxy(4BiO5utobUkvmStunz5lm)OvZdPvtiDfo58MtTIHVRbG5gEyJaCemoftVjm2DTOgTn8Dnam3WZPySsGcajHHFEZPwXyRjm2DToJ2g(UgaMB45umwjqbGKWWpV5uRyS1eg7U(AJ2g(UgaMB4HncWrW4um9g(5nNAfJTMWy31hWOTHVRbG5gEyJaCemoftVHFEZPwXyRjm2DTwA02W31aWCdVEuaOspWlg(5nNAfJTMWy31xy02W31aWCdpEqnyWdXGueug(5nNAfJTMWy314kJ2g(UgaMB4bwNZlahbdpOgm4Hg(5nNAfJTMWeg(YOBkvy02yNoJ2g(5nNAfJTg(UgaMB4ROAiYm8LrQqWzayUHhxq1qKLpGoF9ZE4YxXCK8pBsKpJcMp7C(GxMpdMV(LFH52h57BL8dulF258bZVYS4y5tZG5Zdq8f5lOZCbOfMhOoekI0WxHGyqqB4dG1YxJ8pO8VVZpA18qwyuCQHfaRjN3CQvY)(o)Uga8dB(SaJKVg5Rl)778Rm8ZBpK4NhOoeM)9D(xjFiLpAgezscaXxGXOXcg0AEScgAahHihoPaNNRK)9D(vgtvy6DjCv0uJq8ris4SAGtYxJ8rQftyS7AJ2g(UgaMB4pPSSMYWpV5uRyS1eg7oGrBd)8MtTIXwdp70Wtwy47AayUHhFdbnNAgE8TIAg(OvZdPvtiDfo58MtTs(cZpAiYcjQ1QaL8Sg5JJ8pWf5FFNF0qKfsuRvbk5znYhh5FTO5FFNF0qKfsuRvbk5znYxJ8pirZxy(vg(5Ths8Zduhcn84BiM3wZWpbUkvmStunzMWyNwA02WpV5uRyS1WZon8Kfg(UgaMB4X3qqZPMHhFROMHhs5JMbrMKaq8fymASGbTMhRGHgWriY5nNAL8VVZhs5JMbrMKaCAkfgHcIm58MtTs(335dP8rZGito1Heq7ywaeuHCEZPwXWJVHyEBndpLdWj1WudzEPHGrmHXUlmAB4N3CQvm2A47AayUHNtXyLafascdVc4dRwm86e1WxHGyqqB4dG1Yhh5Fq5lm)Uga8dB(SaJKV481LVW8Hu(OzqKjjaeFbgJglyqR5XkyObCeIC4KcCEUs(cZxW8Vs(vg(5Ths8ZduhcZ)(o)kJPkm9UeUkAQri(iejCwnWj5JdX5Jul5lIHVmsfcodaZn8hSfLQJrYh4Ga0Q8TvXyLafasI8jdNuZRlFAgmFcWrutardrwKVM5Zdq8fstySdxz02WpV5uRyS1W31aWCdpCv0uJq8rigEfWhwTy41jQHVcbXGG2WhaRLpoY)GYxy(Dna4h28zbgjFX5RlFH5xz4N3EiXppqDimFH5dP8rZGitsai(cmgnwWGwZJvWqd4ie5Wjf48CL8fM)jC4LCkgReOaqsy4lJuHGZaWCd)bBrP6yK8boiaTkF09QOPgH4JqYNmCsnVU8PzW8jahrnbenezr(AMVwyEG6qy(AMppaXxinHXUR2OTHFEZPwXyRHVRbG5gEudYavm16tdVc4dRwm86e1WxHGyqqB4jlcGJqKOgKbQyvunez5lm)ayT8Xr(xKVW87AaWpS5Zcms(IZxx(cZ)k5xz4N3EiXppqDimFH5dP8rZGitsai(cmgnwWGwZJvWqd4ie5Wjf48CL8fM)jC4LCkgReOaqsKVW8RmMQW07YkQgImjCwnWj5JJ8fvEHHVmsfcodaZn8hSfLQJrYh4Ga0Q8VQdYa18XT1N5Rr(4cQgIS8jdNuZRlFAgmFcWrutardrwKVM57mxaAH5bQdH5Rz(8aeFH0eg7oiJ2g(5nNAfJTg(UgaMB4ROAiYm8kGpSAXWRtudFfcIbbTHNSiaocrIAqgOIvr1qKLVW8dG1Yhh5Fr(cZVRba)WMplWi5loFD5lm)RKFLHFE7He)8a1HW8fMpKYhndImjbG4lWy0ybdAnpwbdnGJqKdNuGZZvYxy(NWHxIAqgOIPwFA4lJuHGZaWCd)bBrP6yK8boiaTk)R6GmqnFCB9z(AKpUGQHilFYWj186YNMbZNaCe1eq0qKf5Rz(oZfGwyEG6qy(AMppaXxinHXo0LrBdFxdaZn8NSaWCd)8MtTIXwtyStNOgTn8ZBo1kgBn8viige0g(kJPkm9UeUkAQri(iejCwnWj5JJ8pq(cZpA18qcxfn1ieSMR9cZLZBo1kg(UgaMB4HT1zJmtyStNoJ2g(5nNAfJTg(keedcAdphfnTeUkAQri(iezHP3Zxy(LXrrtljGHmo4A0guwy698VVZNgGGkWGZQbojFCK)fIA47AayUHVYCCsnidsW4A3h0eg70DTrBd)8MtTIXwdFfcIbbTHhs5JMbrMKaCAkfgHcIm58MtTs(cZhPwKWz1aNKV48fnFH5ly(4BiO5utobUkvmStunz5FFNVG5hnezHmawdlyyN1a7axKVg5RLIMVW8JwnpKTJmiMv7nYSMhY5nNAL8VVZpAiYczaSgwWWoRb2bUiFnY)QfnFH5FL8JwnpKTJmiMv7nYSMhY5nNAL8fjFrYxy(cMp5Ckfw0qKfePEuaOspWl5loFD5FFNphfnT0ADGvvRXpOK6mFrm8Dnam3Wdxfn1ieFeIjm2P7agTn8ZBo1kgBn8viige0gEiLpAgezYPoKaAhZcGGkKZBo1k5lmFKArcNvdCs(IZx08fMVG5xzmvHP3LKZ1qmgngxtcaZLWz1aNKpoY)I8VVZVYyQctVljNRHymAmUMeaMlHZQbojFnY)ArZxK8fMVG5ly(Cu00sofJvuuKqsDM)9D(rRMhY2rgeZQ9gzwZd58MtTs(335dBqbB4NhYUuisGNVg5Rt08fj)778JgISqgaRHfmScy5Rr(6ev08VVZhFdbnNAYjWvPIHDIQjl)778JgISqgaRHfmScy5JJ81Dr(cZh2Gc2WppKDPqKapFnYxNO5ls(cZxW8jNtPWIgISGi1Jcav6bEjFX5Rl)7785OOPLwRdSQAn(bLuN5lIHVRbG5gE4QOPgH4JqmHXoDAPrBd)8MtTIXwdFfcIbbTH)k5JVHGMtnjLdWj1WudzEPHGrYxy(i1IeoRg4K8fNVO5lmFbZxW85OOPLCkgROOiHK6m)778JwnpKTJmiMv7nYSMhY5nNAL8VVZh2Gc2WppKDPqKapFnYxNO5ls(335hnezHmawdlyyfWYxJ81jQO5FFNp(gcAo1KtGRsfd7evtw(335hnezHmawdlyyfWYhh5R7I8fMpSbfSHFEi7sHibE(AKVorZxK8fMVG5toNsHfnezbrQhfaQ0d8s(IZxx(335ZrrtlTwhyv1A8dkPoZxedFxdaZn8WvrtncXhHycJD6UWOTHFEZPwXyRHVcbXGG2WdP8rZGitsai(cmgnwWGwZJvWqd4ie5Wjf48CL8fM)jC4XqQfPojSToBKLVW8fmFbZNJIMwYPySIIIesQZ8VVZpA18q2oYGywT3iZAEiN3CQvY)(oFydkyd)8q2Lcrc881iFDIMVi5FFNF0qKfYaynSGHvalFnYxNOIM)9D(4BiO5utobUkvmStunz5FFNF0qKfYaynSGHvalFCKVUlYxy(WguWg(5HSlfIe45Rr(6enFrYxy(cMp5Ckfw0qKfePEuaOspWl5loFD5FFNphfnT0ADGvvRXpOK6mFrm8Dnam3Wdxfn1ieFeIHNImmgnngsTyStNjm2Pdxz02WpV5uRyS1WxHGyqqB4vd)u5Rr(haxLVW8fmFY5ukSOHilis9OaqLEGxYxJ81LVW8Vs(Cu00sR1bwvTg)GsQZ8VVZh2Gc2WppKDPqKapFCKpsTKVW8Vs(Cu00sR1bwvTg)GsQZ8fXW31aWCdVEuaOspWlMWyNUR2OTHVRbG5gEkYWaXSig(5nNAfJTMWyNUdYOTHVRbG5gEofJvWOPGhA4N3CQvm2AcJD6qxgTn8ZBo1kgBn8viige0gEokAAjCv0uJq8risQtdFxdaZn8CdsgenGJycJDxlQrBd)8MtTIXwdFfcIbbTHNJIMwcxfn1ieFeISW075lm)Y4OOPLeWqghCnAdklm9UHVRbG5gEfabvqWW1tvqSMhMWy316mAB47AayUHNgahNIXkg(5nNAfJTMWy31xB02W31aWCdF71rcyRWQTsz4N3CQvm2AcJDxFaJ2g(5nNAfJTg(keedcAdphfnTeUkAQri(iezHP3Zxy(LXrrtljGHmo4A0guwy698fMphfnTCoSrMK60W31aWCdpxJGXOXciOIgXeg7UwlnAB4N3CQvm2A47AayUHhs5yDnamhtbiHHxbibM3wZWtaoIAyrdrwycty4pHRYS46WOTXoDgTn8Dnam3WZ1rOggbfJkm8ZBo1kgBnHXURnAB4N3CQvm2A4RqqmiOn8xjFiLpAgezscaXxGXOXcg0AEScgAahHihoPaNNRy47AayUHhUkAQri(ietycty4XpibWCJDxl616efxD9bz413qh4iedVwrRr32HRzNweCp)81g1YhyDYGr(0my(2taoIAyrdrwyF(WHtkaCL8jmRLFtfmRowj)kQ2rgrMhXnGV8paUNpUWC8dgRKV9vg(5Ths0roV5uRyF(blF7Rm8ZBpKOJ95lOobkImpIBaF5RL4E(4cZXpySs(2dP8rZGitIo2NFWY3EiLpAgezs0roV5uRyF(cQtGIiZJ5rTIwJUTdxZoTi4E(5RnQLpW6KbJ8PzW8TVm6Msf2NpC4KcaxjFcZA53ubZQJvYVIQDKrK5rCd4l)dG75Jlmh)GXk5BF0Q5HeDSp)GLV9rRMhs0roV5uRyF(cQtGIiZJ4gWx(AjUNpUWC8dgRKV9qkF0miYKOJ95hS8Ths5JMbrMeDKZBo1k2NVG6eOiY8iUb8LVwI75Jlmh)GXk5BpKYhndImj6yF(blF7Hu(OzqKjrh58MtTI953r(h8vrClFb1jqrK5rCd4lFTe3Zhxyo(bJvY3EiLpAgezs0X(8dw(2dP8rZGitIoY5nNAf7ZxqDcuezEe3a(YhxH75Jlmh)GXk5BFLHFE7HeDKZBo1k2NFWY3(kd)82dj6yF(cQtGIiZJ4gWx(xnUNpUWC8dgRKV9vg(5Ths0roV5uRyF(blF7Rm8ZBpKOJ95lOobkImpIBaF5Fq4E(4cZXpySs(2xz4N3Eirh58MtTI95hS8TVYWpV9qIo2NVG6eOiY8iUb8LVURX98XfMJFWyL8TpA18qIo2NFWY3(OvZdj6iN3CQvSpFbVwGIiZJ4gWx(6Ug3Zhxyo(bJvY3EiLpAgezs0X(8dw(2dP8rZGitIoY5nNAf7ZxqDcuezEe3a(Yx3bW98XfMJFWyL8Ths5JMbrMeDSp)GLV9qkF0miYKOJCEZPwX(8fuNafrMhZJ4AwNmySs(hi)UgaMNVcqcImpA4jNRAS7QV2WFcz0a1m8Oh95FvsbpmFTsdHagmpIE0N)rkF5Fn66Y8Vw0R1LhZJOh95JlOAhzeCppIE0NVaYxRlLvYxlMYYAkzEe9OpFbKVwfqAo1k5BXWpR5r(2K)vDqgOMpUT(m)ARu5lOZI89TYk5tZG5dCbG0wl)kZJjWqezEe9OpFbKVwug(vY3wvxgjyqR8BVKVwf2impF0nRH53Cm8lFBvmwjqbGKi)GLpW6eYWV8PHdNuZRhMpJoF4QmlR5LoamNKVGeGfjFiJcbL6W8hoPALiY8i6rF(ciFTUuwjFB7iulFEumQi)GL)jCvMfxh5R1AX4MmpIE0NVaYxRlLvYxlaQbdEy(OBkcQ8Bog(Lpb4iQjGOHilYxRGcav6bErMhrp6Zxa5R1LYk5FvGS8X1IzrK5r0J(8fq(ARFnA5tZG5RvqbGk9aVKp3OzWLVA4Nk)dC1Y8i6rF(ciF09Sy4xj)dMqMxhrMhrp6Zxa5RvzU9r(uKLppyiJdUgTbZhqNpiSNKFRGRlhMp1z(cQvxhOSA0guezEe9OpFbKp)cQZ8PB0w(KHtQ51rYNMbZNhG4lYNDoFqzEmpIE0N)blWvPIvYNB0m4YVYS46iFUHaCImFTUw3zqY3zUaq1qlAkv(DnamNKpZvhkZJDnamNipHRYS46qtX2W1rOggbfJkYJDnamNipHRYS46qtX2axfn1ieFeYLaAXxbs5JMbrMKaq8fymASGbTMhRGHgWriYHtkW55k5X8i6rF(hSaxLkwj)HFWdZpawl)a1YVRbdMpGKFJVbQMtnzEe95JlOAiYYhqNV(zpC5Ryos(NnjYNrbZNDoFWlZNbZx)YVWC7J89Ts(bQLp7C(G5xzwCS8PzW85bi(I8f0zUa0cZduhcfrMh7AayorCfvdr2LaAXbWAACq33rRMhYcJItnSayn58MtTY9Dxda(HnFwGr0q39DLHFE7He)8a1HW77RaP8rZGitsai(cmgnwWGwZJvWqd4ie5Wjf48CL77kJPkm9UeUkAQri(iejCwnWjAGul5XUgaMt0uSnNuwwtLh7AayortX2GVHGMtTl92AINaxLkg2jQMSlX3kQjoA18qA1esxHty0qKfsuRvbk5znWXbU4(oAiYcjQ1QaL8Sg44ArVVJgISqIATkqjpRHghKOcRm8ZBpK4NhOoeMh7AayortX2GVHGMtTl92AIPCaoPgMAiZlnemYL4Bf1edP8rZGitsai(cmgnwWGwZJvWqd4iK7BiLpAgezscWPPuyekiYUVHu(OzqKjN6qcODmlacQipIE0NV2OaK8bK8TyKqDy(bl)t4WppYVYyQctVtYNgYSYNBahj)UwbL5rRuhMpfzL8luqGJKVfd)SMhY8i6rF(DnamNOPyBGuowxdaZXuasCP3wtSfd)SMhxcOfBXWpR5HSair71PXf5r0J(87AayortX2GAqgOIPwFEjGwSGWguWg(5H0IHFwZdzbqI2RtJRVqiSbfSHFEiTy4N18qcCn0YlejpIE0NFxdaZjAk2gYWj186UeqlURba)WMplWiI1jSYWpV9qIFEG6qOCEZPwriKYhndImjbG4lWy0ybdAnpwbdnGJqKdNuGZZvU0BRj2wTfIUxfnCNtXyLafascChUkAQri(iK8i6Z)GTOuDms(aheGwLVTkgReOaqsKpz4KAED5tZG5taoIAciAiYI81mFEaIVqMh7AayortX2WPySsGcajXLkGpSArSorVeqloawdhhKWUga8dB(SaJiwNqiLpAgezscaXxGXOXcg0AEScgAahHihoPaNNRiuWRuz4N3EiXppqDi8(UYyQctVlHRIMAeIpcrcNvdCcoeJulIKhrF(hSfLQJrYh4Ga0Q8r3RIMAeIpcjFYWj186YNMbZNaCe1eq0qKf5Rz(AH5bQdH5Rz(8aeFHmp21aWCIMITbUkAQri(iKlvaFy1IyDIEjGwCaSgooiHDna4h28zbgrSoHvg(5Ths8ZduhcLZBo1kcHu(OzqKjjaeFbgJglyqR5XkyObCeIC4KcCEUIWt4Wl5umwjqbGKipIE0NFxdaZjAk2gYWj186UeqlURba)WMplWiI1j8kvg(5Ths8ZduhcLZBo1kcHu(OzqKjjaeFbgJglyqR5XkyObCeIC4KcCEUYLEBnX2QTqCbvdrgUZPySsGcajbUJAqgOIvr1qKLhrF(hSfLQJrYh4Ga0Q8VQdYa18XT1N5Rr(4cQgIS8jdNuZRlFAgmFcWrutardrwKVM57mxaAH5bQdH5Rz(8aeFHmp21aWCIMITb1GmqftT(8sfWhwTiwNOxcOftweahHirniduXQOAiYegaRHJle21aGFyZNfyeX6eELkd)82dj(5bQdHY5nNAfHqkF0miYKeaIVaJrJfmO18yfm0aocroCsbopxr4jC4LCkgReOaqsiSYyQctVlROAiYKWz1aNGdrLxKhrF(hSfLQJrYh4Ga0Q8VQdYa18XT1N5Rr(4cQgIS8jdNuZRlFAgmFcWrutardrwKVM57mxaAH5bQdH5Rz(8aeFHmp21aWCIMITPIQHi7sfWhwTiwNOxcOftweahHirniduXQOAiYegaRHJle21aGFyZNfyeX6eELkd)82dj(5bQdHY5nNAfHqkF0miYKeaIVaJrJfmO18yfm0aocroCsbopxr4jC4LOgKbQyQ1N5XUgaMt0uSnNSaW88yxdaZjAk2gyBD2i7saT4kJPkm9UeUkAQri(iejCwnWj44acJwnpKWvrtncbR5AVWC58MtTsESRbG5enfBtL54KAqgKGX1Up4LaAXCu00s4QOPgH4JqKfMExyzCu00scyiJdUgTbLfME)(MgGGkWGZQbobhxiAESRbG5enfBdCv0uJq8rixcOfdP8rZGitsaonLcJqbrMqKArcNvdCIyrfki(gcAo1KtGRsfd7evt29TGrdrwidG1Wcg2znWoWfAOLIkmA18q2oYGywT3iZAECFhnezHmawdlyyN1a7axOXvlQWReTAEiBhzqmR2BKznpereHcsoNsHfnezbrQhfaQ0d8IyD33Cu00sR1bwvTg)GsQtrYJDnamNOPyBGRIMAeIpc5saTyiLpAgezYPoKaAhZcGGkeIuls4SAGtelQqbRmMQW07sY5AigJgJRjbG5s4SAGtWXf33vgtvy6Dj5CneJrJX1KaWCjCwnWjACTOIiuqb5OOPLCkgROOiHK68(oA18q2oYGywT3iZAEiN3CQvUVHnOGn8ZdzxkejW1qNOICFhnezHmawdlyyfW0qNOIEFJVHGMtn5e4QuXWor1KDFhnezHmawdlyyfWWHUlecBqbB4NhYUuisGRHorfrOGKZPuyrdrwqK6rbGk9aViw39nhfnT0ADGvvRXpOK6uK8yxdaZjAk2g4QOPgH4JqUeql(k4BiO5uts5aCsnm1qMxAiyeHi1IeoRg4eXIkuqb5OOPLCkgROOiHK68(oA18q2oYGywT3iZAEiN3CQvUVHnOGn8ZdzxkejW1qNOICFhnezHmawdlyyfW0qNOIEFJVHGMtn5e4QuXWor1KDFhnezHmawdlyyfWWHUlecBqbB4NhYUuisGRHorfrOGKZPuyrdrwqK6rbGk9aViw39nhfnT0ADGvvRXpOK6uK8yxdaZjAk2g4QOPgH4JqUKImmgnngsTiw3LaAXqkF0miYKeaIVaJrJfmO18yfm0aocroCsbopxr4jC4XqQfPojSToBKjuqb5OOPLCkgROOiHK68(oA18q2oYGywT3iZAEiN3CQvUVHnOGn8ZdzxkejW1qNOICFhnezHmawdlyyfW0qNOIEFJVHGMtn5e4QuXWor1KDFhnezHmawdlyyfWWHUlecBqbB4NhYUuisGRHorfrOGKZPuyrdrwqK6rbGk9aViw39nhfnT0ADGvvRXpOK6uK8yxdaZjAk2g9OaqLEGxUeqlwn8tPXbWvcfKCoLclAiYcIupkauPh4fn0j8kCu00sR1bwvTg)GsQZ7Bydkyd)8q2LcrcCCGulcVchfnT0ADGvvRXpOK6uK8yxdaZjAk2gkYWaXSi5XUgaMt0uSnCkgRGrtbpmp21aWCIMITHBqYGObCKlb0I5OOPLWvrtncXhHiPoZJDnamNOPyBuaeubbdxpvbXAECjGwmhfnTeUkAQri(iezHP3fwghfnTKagY4GRrBqzHP3ZJDnamNOPyBObWXPySsESRbG5enfBt71rcyRWQTsLh7AayortX2W1iymASacQOrUeqlMJIMwcxfn1ieFeISW07clJJIMwsadzCW1OnOSW07c5OOPLZHnYKuN5XUgaMt0uSnqkhRRbG5ykajU0BRjMaCe1WIgISipMh7AayorsaoIAyrdrwOPyBGncWrW4um9xcOfdP8rZGitQhOuymASa1W4gKmiAdkhoPaNNRiKJIMwQhOuymASa1W4gKmiAdkHZQbobhi1sESRbG5ejb4iQHfnezHMITPcPiOaocgNIP)saTyiLpAgezs9aLcJrJfOgg3GKbrBq5Wjf48CfHCu00s9aLcJrJfOgg3GKbrBqjCwnWj4aPwYJDnamNijahrnSOHil0uSn12RtHXrrtFP3wtmNQlJemO1LaAXKZPuyrdrwqK6rbGk9aViwNqKArcNvdCIyrfky0Q5H0QjKUcNCEZPw5(UYWpV9qIFEG6qOCEZPwreH4BiO5utobUkvmStunzcfe2itd0LO33xPYyQctVlRmVmlxcNvdCIi5XUgaMtKeGJOgw0qKfAk2MkZlZYVeqlwqokAA5CyJmj159nhfnTeUkAQri(iej1PqiLpAgezscWPPuyekiYeri(gcAo1KtGRsfd7evtwESRbG5ejb4iQHfnezHMITPY8YS8lb0I5OOPLZHnYKuNcX3qqZPMCcCvQyyNOAYYJDnamNijahrnSOHil0uSneWqghCnAdEjGwCzCu00scyiJdUgTbLfMExOGKZPuyrdrwqK6rbGk9aVOHU7Bydkyd)8q2LcrcCn0DHi5XUgaMtKeGJOgw0qKfAk2gyBD2i7saTyb5OOPLWvrtncXhHiPoVV5OOPLwZIbpeJrJPOQGcwbU2IiPof5(wqokAA5CyJmjCwnWj4aPwUVHnY0aDjQi33Cu00sA4CCDhkHZQbobh6KxKh7AayorsaoIAyrdrwOPyBQmVmlpp21aWCIKaCe1WIgISqtX20EfmpWA6yqckwfTlb0I5OOPLZHnYKuNcfKCoLclAiYcIupkauPh4fn0DFdBqbB4NhYUuisGRXvFHi5XUgaMtKeGJOgw0qKfAk2gY5AigJgJRjbG5xcOfZrrtlNdBKjPofki5Ckfw0qKfePEuaOspWlAO7(g2Gc2WppKDPqKaxdT8crYJDnamNijahrnSOHil0uSntGRsflp21aWCIKaCe1WIgISqtX2WP6YibdADjGwmhfnTCoSrMK6uOGxHJIMwcxfn1ieFeIeoRg4K7ByJmCCHOIiuqY5ukSOHilis9OaqLEGxeRtiSbfSHFEi7sHibUgA5f33KZPuyrdrwqK6rbGk9aVi(ArYJDnamNijahrnSOHil0uSnCkgReOaqsCjGwmhfnTCoSrMSW0733vMxOaHepOcyueSkZJzDgsy7OPXfcJgISqIATkqjpRbooWf5XUgaMtKeGJOgw0qKfAk2gofJv46a1LaAXCu00Y5WgzYctVFFxzEHces8GkGrrWQmpM1ziHTJMgximAiYcjQ1QaL8Sg44axi8krRMhYkKAQ4q58MtTsESRbG5ejb4iQHfnezHMITPaBeMJbzn8saTyokAA5CyJmj1PqbjNtPWIgISGi1Jcav6bErdD33WguWg(5HSlfIe4AO7crYJDnamNijahrnSOHil0uSnmNOAkeurESRbG5ejb4iQHfnezHMITrpkauPh4Llb0I5OOPLwdwbQriyCmFiqGxgusDkKCoLclAiYcIupkauPh4fnoqESRbG5ejb4iQHfnezHMITb2iahbJtX0FjGwCfvdrgr8133Cu00s4QOPgH4JqKuNcX3qqZPMCcCvQyyNOAYegTAEiTAcPRWjN3CQvYJDnamNijahrnSOHil0uSnvifbfWrW4um9xcOfxr1qKreF99nhfnTeUkAQri(iej1Pq8ne0CQjNaxLkg2jQMmHrRMhsRMq6kCY5nNAL8yxdaZjscWrudlAiYcnfBdNIXkbkaKe5XUgaMtKeGJOgw0qKfAk2gofJv46avESRbG5ejb4iQHfnezHMITb2iahbJtX0Nh7AayorsaoIAyrdrwOPyBQqkckGJGXPy6ZJDnamNijahrnSOHil0uSn6rbGk9aVKh7AayorsaoIAyrdrwOPyBWdQbdEigKIGkp21aWCIKaCe1WIgISqtX2aSoNxaocgEqnyWdnHjmga]] )


end
