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


    spec:RegisterPack( "Fury", 20210701, [[d4KOlbqiiv8iukTjKQprj1OifDksPwfKIiVIuYSur5wKkzxe9lkrdJu4yKQwgKspdc00qkvxtfvBdLQ4BqanosLY5qPkToivzEiLCpc1(qkoieGfsj5HqQQjsQu1fHuuBesLWhHujAKqQKojKI0kvrMjsPCtsLk1oPe(jKIOgkKIWsHuPEkbtLuXvjvQWwrPQ8vuQQglKc7LI)cLbd6WsTyu8yrnzrUSYMHQpRsJgIonWQjvQKxdHMnj3MsTBQ(nQgUkCCukwUQEoIPlCDKSDuY3jKXJsLZdbTEsLkA(qY(LSrVrhJqQJzSaTAGw9AGa1qVudDtdDJ2rRriq4XmchDgX(oJG32ZiGUG6rOr4OrOI3jJogbcN6ZZiGmIdc6zPLxqGKIrM52wsa2uQoaCp)nEyjbyNT0iWqbubAQBymcPoMXc0QbA1Rbcud9sn0nn0neK9yeAQaj)nccaB0VGwwqeWNrcSdWZjgbKGuAUHXiKgjBeqxq9iSGS)(Fa)RtNOuiSG6pRGOvd0QVovNqFKTFhb9Qt6QGiGuAPcIMGY2EkzDsxfu3dinJAPcAZzn75rbTSGOR75GCbPT1hfm3kvb105rb9T0sfeN)fe46622RGzUhJDH2Y6KUkOUBoRLkOvQonsWF7c2EQG6(VVCVGOBE)fSz4SwbTsX5Paj4jrbdEbb2hpN1ki(p2qnpJWcYXl4Vm32EEQda3jfutcWMuWNtDrQqybhBOAL2Y6KUkiciLwQGw1rOwbfqYPIcg8cE8lZTz6OGia0e0MSoPRcIasPLki7dKd(JWcIUPiilyZWzTcsa(vnDf9Fxuq2psWReb8KSoPRcIasPLkOUdYkiAAmBISoPRcQJO1iwqC(xq2psWReb8ubzgo)xbvJ1ufebrGY6KUki6E2Cwlvq0mHmppISoPRcQ75U1rbPiRGcGDhZVgX9feGxqqynPGT6xNqybPokOM6(1bs7gX9AlRt6QGclOokiEJ4kizSHAEEKcIZ)ckaU(IcYpMVxAeuasqm6yeA(m6ySqVrhJW8MrTKXkJq(bXEqBeihtPWI(VlisribVseWtfKMcQVG0l4nNK)SBGtkO4cQrbPxqcNsXa8Keh8KaJepaXjN3mQLki9cYqHJlXbpjWiXdqCYF2nWjfKEbzOWXLZ)(o5p7g4KcsRcEZjJqNda3nc52ZtHXqHJBeyOWXX82EgbgvNgj4VTjmwGwJogH5nJAjJvgH8dI9G2iWqHJlN)9DsQJcsVGzoxL4IC5VmIQri(ie5p7g4KcstbpVG0li5ykfw0)Dbrkcj4vIaEQG0uq9gHohaUBeApdMhynESNGKNr0eglqqJogH5nJAjJvgH8dI9G2iWqHJlN)9DsQJcsVGFFxbPvbPDnki9csoMsHf9FxqKIqcELiGNkinfuVrOZbG7gbYX6hJJJX0KaWDtySG2n6yeM3mQLmwzeYpi2dAJadfoUC(33jPoki9csoMsHf9FxqKIqcELiGNkinfeTgHohaUBeyuDAKG)2MWyX5gDmcZBg1sgRmc5he7bTrGCmLcl6)UGifHe8krapvqAkO(csVGAwqgkCC58VVtsDuquOkidfoU8xgr1ieFeIK6OG0l4t5dN)3jjahNsHrO(7KZBg1sfu7csVGS6h0mQjh7wMkg2bYMmJqNda3nczUNMTBcJfShJogH5nJAjJvgH8dI9G2iqoMsHf9FxqKIqcELiGNkinfuVrOZbG7gbcy3X8RrCVjmwGan6yeM3mQLmwzeYpi2dAJa5ykfw0)Dbrkcj4vIaEQG0uq9gHohaUBe(2(OVZegl0nJogH5nJAjJvgH8dI9G2iWqHJlN)9DsQJcsVGzoxL4IC5VmIQri(ie5p7g4KcstbpVG0li5ykfw0)Dbrkcj4vIaEQG0uq9gHohaUBeihRFmoogttca3nHXc2RrhJW8MrTKXkJq(bXEqBeyOWXLZ)(o5p7g4KcstbV5ubrtQGOvEEbPxqYXukSO)7cIuesWReb8ubPPG6ncDoaC3iWO60ib)TnHjmceGFvdl6)UWOJXc9gDmcZBg1sgRmc5he7bTr4P8HZ)7KIakfghhlqomM9K9iUxo2qboowQG0lidfoUueqPW44ybYHXSNShX9YF2nWjfKwf8MtgHohaUBe((c8lgJIlYeglqRrhJW8MrTKXkJq(bXEqBeEkF48)oPiGsHXXXcKdJzpzpI7LJnuGJJLki9cYqHJlfbukmoowGCym7j7rCV8NDdCsbPvbV5KrOZbG7gHVVa)IXO4ImHXce0OJryEZOwYyLri)GypOncKJPuyr)3fePiKGxjc4PckUG6li9cEZj5p7g4KckUGAuq6fuZcgTAEiTBcPZ)KZBg1sfefQcM5SM3EiznpqIWVGAxq6fKv)GMrn5y3YuXWoq2Kvq6fuZc(9DfKMcYE1OGOqvq0PGzoxL4ICzM7Pz7YF2nWjfuBJqNda3nc52ZtHXqHJBeyOWXX82EgbgvNgj4VTjmwq7gDmcZBg1sgRmc5he7bTrqZcYqHJlN)9DsQJcIcvbzOWXL)YiQgH4JqKuhfKEbFkF48)ojb44ukmc1FNCEZOwQGAxq6fKv)GMrn5y3YuXWoq2Kze6Ca4UriZ90SDtyS4CJogH5nJAjJvgH8dI9G2iWqHJlN)9DsQJcsVGS6h0mQjh7wMkg2bYMmJqNda3nczUNMTBcJfShJogH5nJAjJvgH8dI9G2iKgdfoUKa2Dm)Ae3ltCrEbPxqnli5ykfw0)Dbrkcj4vIaEQG0uq9fefQc(niHnwZdzNsejWlinfu)5fuBJqNda3nceWUJ5xJ4EtySabA0XimVzulzSYiKFqSh0gbnlidfoU8xgr1ieFeIK6OGOqvqgkCCP9S5pcX44ykQmiHL(12ej1rb1UGOqvqnlidfoUC(33j)z3aNuqAvWBovquOk433vqAki7vJcQDbrHQGmu44s8FUUtek)z3aNuqAvq9YZncDoaC3i8T9rFNjmwOBgDmcDoaC3iK5EA2UryEZOwYyLjmwWEn6yeM3mQLmwzeYpi2dAJadfoUC(33jPoki9cQzbjhtPWI(VlisribVseWtfKMcQVGOqvWVbjSXAEi7uIibEbPPGiWZlO2gHohaUBeApdMhynESNGKNr0egl0RHrhJW8MrTKXkJq(bXEqBeyOWXLZ)(oj1rbPxqnli5ykfw0)Dbrkcj4vIaEQG0uq9fefQc(niHnwZdzNsejWlinfK2pVGABe6Ca4UrGCS(X44ymnjaC3egl0R3OJrOZbG7gHXULPIzeM3mQLmwzcJf6rRrhJW8MrTKXkJq(bXEqBeyOWXLZ)(oj1rbPxqnli6uqgkCC5VmIQri(ie5p7g4KcIcvb)(UcsRcEUgfu7csVGAwqYXukSO)7cIuesWReb8ubfxq9fKEb)gKWgR5HStjIe4fKMcs7NxquOki5ykfw0)Dbrkcj4vIaEQGIliAlO2gHohaUBeyuDAKG)2MWyHEe0OJryEZOwYyLri)GypOncmu44Y5FFNmXf5fefQcM5EIceswGmGtrWYCpM9ri)2rSG0uWZli9cg9FxirUwfiLh5OG0QGi45gHohaUBeyuCEkqcEsycJf6PDJogH5nJAjJvgH8dI9G2iWqHJlN)9DYexKxquOkyM7jkqizbYaofblZ9y2hH8BhXcstbpVG0ly0)DHe5AvGuEKJcsRcIGNxq6feDky0Q5Hm)utfiuoVzulze6Ca4UrGrX5Paj4jHjmwO)CJogH5nJAjJvgH8dI9G2iWqHJlN)9DsQJcsVGAwqYXukSO)7cIuesWReb8ubPPG6likuf8BqcBSMhYoLisGxqAkO(ZlO2gHohaUBesFF5o2Z73egl0ZEm6ye6Ca4UrG7evtDrggH5nJAjJvMWyHEeOrhJW8MrTKXkJq(bXEqBeyOWXL27Za1iemgUV7d80Ej1rbPxqYXukSO)7cIuesWReb8ubPPGiOrOZbG7gbribVseWtMWyHEDZOJryEZOwYyLri)GypOnczK9FhPGIliAlikufKHchx(lJOAeIpcrsDuq6fKv)GMrn5y3YuXWoq2Kvq6fmA18qA3esN)jN3mQLmcDoaC3i89f4xmgfxKjmwON9A0XimVzulzSYiKFqSh0gHmY(VJuqXfeTfefQcYqHJl)LruncXhHiPoki9cYQFqZOMCSBzQyyhiBYki9cgTAEiTBcPZ)KZBg1sgHohaUBe((c8lgJIlYeglqRggDmcDoaC3iWO48uGe8KWimVzulzSYeglqREJogHohaUBeyuCEkqcEsyeM3mQLmwzcJfOfTgDmcDoaC3i89f4xmgfxKryEZOwYyLjmwGwe0OJrOZbG7gHVVa)IXO4ImcZBg1sgRmHXc0s7gDmcDoaC3iicj4vIaEYimVzulzSYeglq75gDmcDoaC3iWcKd(JqSNIG0imVzulzSYeglql7XOJrOZbG7gbG9X8eWVySa5G)i0imVzulzSYeMWiKgEtPcJogl0B0XimVzulzSYi05aWDJqgz)3zesJKFWra4Ura9r2)DfeGxqrZ6FfuX9BbpAsuqo1xq(X89Nvq(xqrRGjUBDuqFlvWa5ki)y((cM52m8cIZ)ckaU(IcQPZDDX(Mhir4RT0iKFqSh0gHayVcstb1TcIcvbJwnpKjofJAybWEY5nJAPcIcvb7CaynS5ZgmsbPPG6likufmZznV9qYAEGeHFbrHQGOtbFkF48)ojbC9fyCCSG)2ZJLWqe4xICSHcCCSubrHQGzoxL4IC5VmIQri(ie5p7g4KcstbV5KjmwGwJogHohaUBeoOSTNYimVzulzSYeglqqJogH5nJAjJvgb(HrGSWi05aWDJaR(bnJAgbwTIAgHOvZdPDtiD(NCEZOwQG0ly0)DHe5AvGuEKJcsRcIGNxquOky0)DHe5AvGuEKJcsRcIwnkikufm6)UqICTkqkpYrbPPG6MgfKEbZCwZBpKSMhir4Bey1pM32Zim2TmvmSdKnzMWybTB0XimVzulzSYiWpmcKfgHohaUBey1pOzuZiWQvuZi8u(W5)Dsc46lW44yb)TNhlHHiWVe58MrTubrHQGpLpC(FNKaCCkfgH6VtoVzulvquOk4t5dN)3jNcHeq7y2GlYqoVzulzey1pM32Ziq5a2qnm1UZt9dgXeglo3OJryEZOwYyLrOZbG7gbgfNNcKGNegbfWhwoze0RHri)GypOncbWEfKwfu3ki9c25aWAyZNnyKckUG6li9c(u(W5)Dsc46lW44yb)TNhlHHiWVe5ydf44yPcsVGAwq0PGzoR5ThswZdKi8likufmZ5QexKl)LruncXhHi)z3aNuqAjUG3CQGABesJKFWra4UranBtP6yKccCqaAvbTsX5Paj4jrbjJnuZZRG48VGeGFvtxr)3ffuRckaU(cPjmwWEm6yeM3mQLmwze6Ca4Ur4xgr1ieFeIrqb8HLtgb9AyeYpi2dAJqaSxbPvb1TcsVGDoaSg28zdgPGIlO(csVGzoR5ThswZdKi8li9c(u(W5)Dsc46lW44yb)TNhlHHiWVe5ydf44yPcsVGh)yjzuCEkqcEsyesJKFWra4UranBtP6yKccCqaAvbr3lJOAeIpcPGKXgQ55vqC(xqcWVQPRO)7IcQvbzFZdKi8lOwfuaC9fstySabA0XimVzulzSYi05aWDJaY9CqgtT(WiOa(WYjJGEnmc5he7bTrGSia(LirUNdYyzK9FxbPxWayVcsRcEEbPxWohawdB(SbJuqXfuFbPxq0PGzoR5ThswZdKi8li9c(u(W5)Dsc46lW44yb)TNhlHHiWVe5ydf44yPcsVGh)yjzuCEkqcEsuq6fmZ5QexKlZi7)o5p7g4KcsRcQH8CJqAK8doca3ncOzBkvhJuqGdcqRki66EoixqAB9rbPPGOpY(VRGKXgQ55vqC(xqcWVQPRO)7IcQvbDURl238ajc)cQvbfaxFH0egl0nJogH5nJAjJvgHohaUBeYi7)oJGc4dlNmc61WiKFqSh0gbYIa4xIe5EoiJLr2)DfKEbdG9kiTk45fKEb7CaynS5Zgmsbfxq9fKEbrNcM5SM3EiznpqIWVG0l4t5dN)3jjGRVaJJJf83EESegIa)sKJnuGJJLki9cE8JLe5EoiJPwFyesJKFWra4UranBtP6yKccCqaAvbrx3Zb5csBRpkinfe9r2)DfKm2qnpVcIZ)csa(vnDf9FxuqTkOZDDX(Mhir4xqTkOa46lKMWyb71OJrOZbG7gHdEa4UryEZOwYyLjmwOxdJogH5nJAjJvgH8dI9G2iK5CvIlYL)YiQgH4JqK)SBGtkiTkicwq6fmA18q(lJOAecwZ0EI7Y5nJAjJqNda3ncFBF03zcJf61B0XimVzulzSYiKFqSh0gbgkCC5VmIQri(iezIlYli9cMgdfoUKa2Dm)Ae3ltCrEbrHQG4GlYa7NDdCsbPvbpxdJqNda3nczUZgQ98NGX0UV3egl0JwJogH5nJAjJvgH8dI9G2i8u(W5)DscWXPuyeQ)o58MrTubPxWBoj)z3aNuqXfuJcsVGAwqw9dAg1KJDltfd7aztwbrHQGAwWO)7czaShwWXoYbgcEEbPPG0UgfKEbJwnpKTF3Jz3EFN98qoVzulvquOky0)DHma2dl4yh5adbpVG0uqeOgfKEbrNcgTAEiB)UhZU9(o75HCEZOwQGAxqTli9cQzbjhtPWI(VlisribVseWtfuCb1xquOkidfoU0EDGLvRzTxsDuqTncDoaC3i8lJOAeIpcXegl0JGgDmcZBg1sgRmc5he7bTr4P8HZ)7KtHqcODmBWfziN3mQLki9cEZj5p7g4KckUGAuq6fuZcM5CvIlYLKJ1pghhJPjbG7YF2nWjfKwf88cIcvbZCUkXf5sYX6hJJJX0KaWD5p7g4KcstbrRgfu7csVGAwqnlidfoUKrX5jffjKuhfefQcgTAEiB)UhZU9(o75HCEZOwQGOqvWVbjSXAEi7uIibEbPPG61OGAxquOky0)DHma2dl4yjWkinfuVgAuquOkiR(bnJAYXULPIHDGSjRGOqvWO)7czaShwWXsGvqAvq9Nxq6f8BqcBSMhYoLisGxqAkOEnkO2fKEb1SGKJPuyr)3fePiKGxjc4PckUG6likufKHchxAVoWYQ1S2lPokO2gHohaUBe(LruncXhHycJf6PDJogH5nJAjJvgH8dI9G2iGofKv)GMrnjLdyd1Wu7op1pyKcsVG3Cs(ZUboPGIlOgfKEb1SGAwqgkCCjJIZtkksiPokikufmA18q2(DpMD79D2Zd58MrTubrHQGFdsyJ18q2Perc8cstb1Rrb1UGOqvWO)7czaShwWXsGvqAkOEn0OGOqvqw9dAg1KJDltfd7aztwbrHQGr)3fYaypSGJLaRG0QG6pVG0l43Ge2ynpKDkrKaVG0uq9AuqTli9cQzbjhtPWI(VlisribVseWtfuCb1xquOkidfoU0EDGLvRzTxsDuqTncDoaC3i8lJOAeIpcXegl0FUrhJW8MrTKXkJq(bXEqBeEkF48)ojbC9fyCCSG)2ZJLWqe4xICSHcCCSubPxWJFSWU5KuV8B7J(UcsVGAwqnlidfoUKrX5jffjKuhfefQcgTAEiB)UhZU9(o75HCEZOwQGOqvWVbjSXAEi7uIibEbPPG61OGAxquOky0)DHma2dl4yjWkinfuVgAuquOkiR(bnJAYXULPIHDGSjRGOqvWO)7czaShwWXsGvqAvq9Nxq6f8BqcBSMhYoLisGxqAkOEnkO2fKEb1SGKJPuyr)3fePiKGxjc4PckUG6likufKHchxAVoWYQ1S2lPokO2gHohaUBe(LruncXhHyeOidJJJJDZjJf6nHXc9ShJogH5nJAjJvgH8dI9G2iOgRPkinfebzpfKEb1SGKJPuyr)3fePiKGxjc4Pcstb1xq6feDkidfoU0EDGLvRzTxsDuquOk43Ge2ynpKDkrKaVG0QG3CQG0li6uqgkCCP96alRwZAVK6OGABe6Ca4UrqesWReb8KjmwOhbA0Xi05aWDJafzyGy2eJW8MrTKXktySqVUz0Xi05aWDJaJIZty4upcncZBg1sgRmHXc9SxJogH5nJAjJvgH8dI9G2iWqHJl)LruncXhHiPomcDoaC3iWSNShrGFnHXc0QHrhJW8MrTKXkJq(bXEqBeyOWXL)YiQgH4JqKjUiVG0lyAmu44scy3X8RrCVmXf5gHohaUBeuGlYGGP7IkDTNhMWybA1B0Xi05aWDJao4hJIZtgH5nJAjJvMWybArRrhJqNda3ncTNhj(wHLBLYimVzulzSYeglqlcA0XimVzulzSYiKFqSh0gbgkCC5VmIQri(iezIlYli9cMgdfoUKa2Dm)Ae3ltCrEbPxqgkCC58VVtsDye6Ca4UrGPVyCCS4bzejMWybAPDJogH5nJAjJvgHohaUBeEkhRZbG7ykajmckajW82EgbcWVQHf9Fxyctyeo(L52mDy0XyHEJogHohaUBey6iudJGKtfgH5nJAjJvMWybAn6yeM3mQLmwzeYpi2dAJa6uWNYho)VtsaxFbghhl4V98yjmeb(LihBOahhlze6Ca4Ur4xgr1ieFeIjmHjmcS2taC3ybA1aT61G9Gw2Rrqu)oWVeJa7hbGUTan1c0LOxblOoixbb2h8pkio)lO1nFwxWFSHc8lvqc3EfSPcUDhlvWmY2VJiRt0gWxb1JEfe95oR9Xsf0AcNsXa8KenSUGbVGwt4ukgGNKOHCEZOwY6cQPE2PTSorBaFf8C0RGOp3zTpwQGw)u(W5)Ds0W6cg8cA9t5dN)3jrd58MrTK1fut9StBzDQoX(raOBlqtTaDj6vWcQdYvqG9b)JcIZ)cAnb4x1WI(VlSUG)ydf4xQGeU9kytfC7owQGzKTFhrwNOnGVcIGOxbrFUZAFSubToZznV9qIgY5nJAjRlyWlO1zoR5Ths0W6cQPE2PTSorBaFfK2rVcI(CN1(yPcA9t5dN)3jrdRlyWlO1pLpC(FNenKZBg1swxqn1ZoTL1P6e7hbGUTan1c0LOxblOoixbb2h8pkio)lO1PH3uQW6c(JnuGFPcs42RGnvWT7yPcMr2(DezDI2a(kicIEfe95oR9Xsf06OvZdjAyDbdEbToA18qIgY5nJAjRlOM6zN2Y6eTb8vqAh9ki6ZDw7JLkO1pLpC(FNenSUGbVGw)u(W5)Ds0qoVzulzDb1up70wwNOnGVcs7OxbrFUZAFSubT(P8HZ)7KOH1fm4f06NYho)VtIgY5nJAjRlyhfenJMmTvqn1ZoTL1jAd4RG0o6vq0N7S2hlvqRFkF48)ojAyDbdEbT(P8HZ)7KOHCEZOwY6cQPE2PTSorBaFfK9GEfe95oR9Xsf06mN182djAiN3mQLSUGbVGwN5SM3EirdRlOM6zN2Y6eTb8vqei6vq0N7S2hlvqRZCwZBpKOHCEZOwY6cg8cADMZAE7HenSUGAQNDAlRt0gWxb1n0RGOp3zTpwQGwN5SM3Eird58MrTK1fm4f06mN182djAyDb1up70wwNOnGVcQhTOxbrFUZAFSubToA18qIgwxWGxqRJwnpKOHCEZOwY6cQjAzN2Y6eTb8vq9Of9ki6ZDw7JLkO1pLpC(FNenSUGbVGw)u(W5)Ds0qoVzulzDb1up70wwNOnGVcQhbrVcI(CN1(yPcA9t5dN)3jrdRlyWlO1pLpC(FNenKZBg1swxqn1ZoTL1P6eAQ9b)JLkiTxWohaUxqfGeezDYiqow2ybceTgHJNJduZiWw2wq0fupcli7V)hW)6eBzBbprPqyb1FwbrRgOvFDQoXw2wq0hz73rqV6eBzBb1vbraP0sfenbLT9uY6eBzBb1vb19asZOwQG2CwZEEuqlli66EoixqAB9rbZTsvqnDEuqFlTubX5FbbUUUT9kyM7XyxOTSoXw2wqDvqD3CwlvqRuDAKG)2fS9ub19FF5Ebr38(lyZWzTcALIZtbsWtIcg8ccSpEoRvq8FSHAEgHfKJxWFzUT98uhaUtkOMeGnPGpN6IuHWco2q1kTL1j2Y2cQRcIasPLkOvDeQvqbKCQOGbVGh)YCBMokicanbTjRtSLTfuxfebKslvq2hih8hHfeDtrqwWMHZAfKa8RA6k6)UOGSFKGxjc4jzDITSTG6QGiGuAPcQ7GScIMgZMiRtSLTfuxfuhrRrSG48VGSFKGxjc4PcYmC(VcQgRPkicIaL1j2Y2cQRcIUNnN1sfentiZZJiRtSLTfuxfu3ZDRJcsrwbfa7oMFnI7liaVGGWAsbB1VoHWcsDuqn19RdK2nI71wwNylBlOUkOWcQJcI3iUcsgBOMNhPG48VGcGRVOG8J57L1P6eBzBbrZSBzQyPcYmC(VcM52mDuqMDborwqeqoVJGuqN76cz)24uQc25aWDsb5UcHY6uNda3jYJFzUnthAj2sMoc1Wii5urDQZbG7e5XVm3MPdTeB5VmIQri(iKZa4IrNNYho)VtsaxFbghhl4V98yjmeb(LihBOahhlvNQtSLTfenZULPILk4yThHfma2RGbYvWoh8VGasbBwnq1mQjRtSTGOpY(VRGa8ckAw)RGkUFl4rtIcYP(cYpMV)ScY)ckAfmXDRJc6BPcgixb5hZ3xWm3MHxqC(xqbW1xuqnDURl238ajcFTL1PohaUteNr2)DNbWfha7rJUHcv0Q5HmXPyudla2toVzulHcvNdaRHnF2GrOrpkuzoR5ThswZdKi8rHcDEkF48)ojbC9fyCCSG)2ZJLWqe4xICSHcCCSekuzoxL4IC5VmIQri(ie5p7g4eAU5uDQZbG7eTeB5bLT9u1PohaUt0sSLS6h0mQDM32t8y3YuXWoq2KDgRwrnXrRMhs7Mq68p6r)3fsKRvbs5roOfcEokur)3fsKRvbs5roOfA1afQO)7cjY1QaP8ih0OBAqpZznV9qYAEGeHFDQZbG7eTeBjR(bnJAN5T9et5a2qnm1UZt9dg5mwTIAIFkF48)ojbC9fyCCSG)2ZJLWqe4xckupLpC(FNKaCCkfgH6VdfQNYho)VtofcjG2XSbxKrDITSTG6GeqkiGuqBojuiSGbVGh)ynpkyMZvjUiNuq8NBxqMb8Bb7CgKMhTsHWcsrwQGjQh43cAZzn75HSoXw2wWohaUt0sSLpLJ15aWDmfGeN5T9eBZzn75XzaCX2CwZEEitas0EE0CEDITSTGDoaCNOLylrUNdYyQ1hNbWfR53Ge2ynpK2CwZEEitas0EE0G2ZP)niHnwZdPnN1SNhsGtdTFU21j2Y2c25aWDIwITKm2qnpVZa4I7CaynS5ZgmIy90ZCwZBpKSMhir4lN3mQLO)u(W5)Dsc46lW44yb)TNhlHHiWVe5ydf44yPZ82EITsh6O7Lre9yuCEkqcEsGE)YiQgH4JqQtSTGOzBkvhJuqGdcqRkOvkopfibpjkizSHAEEfeN)fKa8RA6k6)UOGAvqbW1xiRtDoaCNOLylzuCEkqcEsCMc4dlNeRxJZa4IdG9OLUrVZbG1WMpBWiI1t)P8HZ)7KeW1xGXXXc(BppwcdrGFjYXgkWXXs01eDYCwZBpKSMhir4JcvMZvjUix(lJOAeIpcr(ZUboHwIV5K21j2wq0SnLQJrkiWbbOvfeDVmIQri(iKcsgBOMNxbX5Fbja)QMUI(VlkOwfK9npqIWVGAvqbW1xiRtDoaCNOLyl)LruncXhHCMc4dlNeRxJZa4IdG9OLUrVZbG1WMpBWiI1tpZznV9qYAEGeHVCEZOwI(t5dN)3jjGRVaJJJf83EESegIa)sKJnuGJJLOF8JLKrX5Paj4jrDITSTGDoaCNOLyljJnuZZ7maU4ohawdB(SbJiwpD0jZznV9qYAEGeHVCEZOwI(t5dN)3jjGRVaJJJf83EESegIa)sKJnuGJJLoZB7j2kDOJ(i7)o0JrX5Paj4jb6HCphKXYi7)U6eBliA2Ms1Xife4Ga0QcIUUNdYfK2wFuqAki6JS)7kizSHAEEfeN)fKa8RA6k6)UOGAvqN76I9npqIWVGAvqbW1xiRtDoaCNOLylrUNdYyQ1hNPa(WYjX614maUyYIa4xIe5EoiJLr2)D0dG9O1507CaynS5ZgmIy90rNmN182djR5bse(Y5nJAj6pLpC(FNKaU(cmoowWF75Xsyic8lro2qboowI(XpwsgfNNcKGNe0ZCUkXf5YmY(Vt(ZUboHwAipVoX2cIMTPuDmsbboiaTQGOR75GCbPT1hfKMcI(i7)UcsgBOMNxbX5Fbja)QMUI(VlkOwf05UUyFZdKi8lOwfuaC9fY6uNda3jAj2YmY(V7mfWhwojwVgNbWftwea)sKi3ZbzSmY(VJEaShToNENdaRHnF2GreRNo6K5SM3EiznpqIWxoVzulr)P8HZ)7KeW1xGXXXc(BppwcdrGFjYXgkWXXs0p(XsICphKXuRpQtDoaCNOLylp4bG71PohaUt0sSLFBF03DgaxCMZvjUix(lJOAeIpcr(ZUboHwii9OvZd5VmIQriynt7jUlN3mQLQtDoaCNOLylZCNnu75pbJPDF)zaCXmu44YFzevJq8riYexKtpngkCCjbS7y(1iUxM4ICuOWbxKb2p7g4eADUg1PohaUt0sSL)YiQgH4JqodGl(P8HZ)7KeGJtPWiu)D0V5K8NDdCIynORjR(bnJAYXULPIHDGSjdfknJ(VlKbWEybh7ihyi450q7AqpA18q2(DpMD79D2ZduOI(VlKbWEybh7ihyi450Ga1Go6eTAEiB)UhZU9(o75H2AtxtYXukSO)7cIuesWReb8Ky9OqXqHJlTxhyz1Aw7LuhAxN6Ca4orlXw(lJOAeIpc5maU4NYho)VtofcjG2XSbxKb9Boj)z3aNiwd6AM5CvIlYLKJ1pghhJPjbG7YF2nWj06CuOYCUkXf5sYX6hJJJX0KaWD5p7g4eAqRgAtxtnzOWXLmkopPOiHK6afQOvZdz739y2T33zppKZBg1sOq9niHnwZdzNsejWPrVgAJcv0)DHma2dl4yjWOrVgAGcfR(bnJAYXULPIHDGSjdfQO)7czaShwWXsGrl9Nt)BqcBSMhYoLisGtJEn0MUMKJPuyr)3fePiKGxjc4jX6rHIHchxAVoWYQ1S2lPo0Uo15aWDIwIT8xgr1ieFeYzaCXOdR(bnJAskhWgQHP2DEQFWi0V5K8NDdCIynORPMmu44sgfNNuuKqsDGcv0Q5HS97Em7277SNhY5nJAjuO(gKWgR5HStjIe40OxdTrHk6)Uqga7HfCSey0OxdnqHIv)GMrn5y3YuXWoq2KHcv0)DHma2dl4yjWOL(ZP)niHnwZdzNsejWPrVgAtxtYXukSO)7cIuesWReb8Ky9OqXqHJlTxhyz1Aw7LuhAxN6Ca4orlXw(lJOAeIpc5mkYW444y3CsS(Za4IFkF48)ojbC9fyCCSG)2ZJLWqe4xICSHcCCSe9JFSWU5KuV8B7J(o6AQjdfoUKrX5jffjKuhOqfTAEiB)UhZU9(o75HCEZOwcfQVbjSXAEi7uIibon61qBuOI(VlKbWEybhlbgn61qduOy1pOzuto2TmvmSdKnzOqf9FxidG9WcowcmAP)C6FdsyJ18q2PercCA0RH201KCmLcl6)UGifHe8krapjwpkumu44s71bwwTM1Ej1H21PohaUt0sSLIqcELiGNodGlwnwtrdcYEORj5ykfw0)Dbrkcj4vIaEIg90rhgkCCP96alRwZAVK6afQVbjSXAEi7uIiboTU5eD0HHchxAVoWYQ1S2lPo0Uo15aWDIwITKImmqmBsDQZbG7eTeBjJIZty4upcRtDoaCNOLylz2t2JiWVNbWfZqHJl)LruncXhHiPoQtDoaCNOLylvGlYGGP7IkDTNhNbWfZqHJl)LruncXhHitCro90yOWXLeWUJ5xJ4EzIlYRtDoaCNOLylXb)yuCEQo15aWDIwITS98iX3kSCRu1PohaUt0sSLm9fJJJfpiJi5maUygkCC5VmIQri(iezIlYPNgdfoUKa2Dm)Ae3ltCroDgkCC58VVtsDuN6Ca4orlXw(uowNda3XuasCM32tmb4x1WI(VlQt1PohaUtKnFIZTNNcJHch)mVTNygvNgj4V9zaCXKJPuyr)3fePiKGxjc4jA0t)MtYF2nWjI1GoHtPyaEsIdEsGrIhG4OZqHJlXbpjWiXdqCYF2nWj0zOWXLZ)(o5p7g4eADZP6uNda3jYMpTeBz7zW8aRXJ9eK8mINbWfZqHJlN)9DsQd6zoxL4IC5VmIQri(ie5p7g4eAoNo5ykfw0)Dbrkcj4vIaEIg91PohaUtKnFAj2sYX6hJJJX0KaW9Za4IzOWXLZ)(oj1b9VVJw0Ug0jhtPWI(VlisribVseWt0OVo15aWDIS5tlXwYO60ib)TpdGlMHchxo)77Kuh0jhtPWI(VlisribVseWt0G26uNda3jYMpTeBzM7Pz7NbWftoMsHf9FxqKIqcELiGNOrpDnzOWXLZ)(oj1bkumu44YFzevJq8risQd6pLpC(FNKaCCkfgH6VtB6S6h0mQjh7wMkg2bYMS6uNda3jYMpTeBjbS7y(1iU)maUyYXukSO)7cIuesWReb8en6RtDoaCNiB(0sSLFBF03Dgaxm5ykfw0)Dbrkcj4vIaEIg91PohaUtKnFAj2sYX6hJJJX0KaW9Za4IzOWXLZ)(oj1b9mNRsCrU8xgr1ieFeI8NDdCcnNtNCmLcl6)UGifHe8kraprJ(6uNda3jYMpTeBjJQtJe83(maUygkCC58VVt(ZUboHMBoHMeALNtNCmLcl6)UGifHe8kraprJ(6uDQZbG7ejb4x1WI(Vl0sSLFFb(fJrXfDgax8t5dN)3jfbukmoowGCym7j7rCVCSHcCCSeDgkCCPiGsHXXXcKdJzpzpI7L)SBGtO1nNQtDoaCNija)Qgw0)DHwITm)ueKa)IXO4IodGl(P8HZ)7KIakfghhlqomM9K9iUxo2qboowIodfoUueqPW44ybYHXSNShX9YF2nWj06Mt1PohaUtKeGFvdl6)UqlXwMBppfgdfo(zEBpXmQonsWF7Za4IjhtPWI(VlisribVseWtI1t)MtYF2nWjI1GUMrRMhs7Mq68p58MrTekuzoR5ThswZdKi8LZBg1sAtNv)GMrn5y3YuXWoq2KrxZVVJg2RgOqHozoxL4ICzM7Pz7YF2nWjAxN6Ca4orsa(vnSO)7cTeBzM7Pz7NbWfRjdfoUC(33jPoqHIHchx(lJOAeIpcrsDq)P8HZ)7KeGJtPWiu)DAtNv)GMrn5y3YuXWoq2KvN6Ca4orsa(vnSO)7cTeBzM7Pz7NbWfZqHJlN)9DsQd6S6h0mQjh7wMkg2bYMS6uNda3jscWVQHf9FxOLyljGDhZVgX9NbWfNgdfoUKa2Dm)Ae3ltCroDnjhtPWI(VlisribVseWt0OhfQVbjSXAEi7uIibon6px76uNda3jscWVQHf9FxOLyl)2(OV7maUynzOWXL)YiQgH4JqKuhOqXqHJlTNn)righhtrLbjS0V2MiPo0gfknzOWXLZ)(o5p7g4eADZjuO((oAyVAOnkumu44s8FUUtek)z3aNql9YZRtDoaCNija)Qgw0)DHwITmZ90S96uNda3jscWVQHf9FxOLylBpdMhynESNGKNr8maUygkCC58VVtsDqxtYXukSO)7cIuesWReb8en6rH6BqcBSMhYoLisGtdc8CTRtDoaCNija)Qgw0)DHwITKCS(X44ymnjaC)maUygkCC58VVtsDqxtYXukSO)7cIuesWReb8en6rH6BqcBSMhYoLisGtdTFU21PohaUtKeGFvdl6)UqlXwo2TmvS6uNda3jscWVQHf9FxOLylzuDAKG)2NbWfZqHJlN)9DsQd6AIomu44YFzevJq8riYF2nWjOq99D06Cn0MUMKJPuyr)3fePiKGxjc4jX6P)niHnwZdzNsejWPH2phfkYXukSO)7cIuesWReb8Ky0QDDQZbG7ejb4x1WI(Vl0sSLmkopfibpjodGlMHchxo)77KjUihfQm3tuGqYcKbCkcwM7XSpc53oI0Co9O)7cjY1QaP8ih0cbpVo15aWDIKa8RAyr)3fAj2sgfNNy6a5zaCXmu44Y5FFNmXf5OqL5EIceswGmGtrWYCpM9ri)2rKMZPh9FxirUwfiLh5Gwi450rNOvZdz(PMkqOCEZOwQo15aWDIKa8RAyr)3fAj2Y03xUJ98(pdGlMHchxo)77Kuh01KCmLcl6)UGifHe8kraprJEuO(gKWgR5HStjIe40O)CTRtDoaCNija)Qgw0)DHwITK7evtDrg1PohaUtKeGFvdl6)UqlXwkcj4vIaE6maUygkCCP9(mqncbJH77(apTxsDqNCmLcl6)UGifHe8kraprdcwN6Ca4orsa(vnSO)7cTeB53xGFXyuCrNbWfNr2)DeXOffkgkCC5VmIQri(iej1bDw9dAg1KJDltfd7aztg9OvZdPDtiD(NCEZOwQo15aWDIKa8RAyr)3fAj2Y8trqc8lgJIl6maU4mY(VJigTOqXqHJl)LruncXhHiPoOZQFqZOMCSBzQyyhiBYOhTAEiTBcPZ)KZBg1s1PohaUtKeGFvdl6)UqlXwYO48uGe8KOo15aWDIKa8RAyr)3fAj2sgfNNy6azDQZbG7ejb4x1WI(Vl0sSLFFb(fJrXfvN6Ca4orsa(vnSO)7cTeBz(Piib(fJrXfvN6Ca4orsa(vnSO)7cTeBPiKGxjc4P6uNda3jscWVQHf9FxOLylzbYb)ri2trqwN6Ca4orsa(vnSO)7cTeBjW(yEc4xmwGCWFeActyma]] )


end
