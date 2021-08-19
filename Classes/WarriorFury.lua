-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local IsActiveSpell = ns.IsActiveSpell

local FindUnitBuffByID = ns.FindUnitBuffByID


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
            
            elseif state.talent.fresh_meat.enabled and spellID == 23881 and subtype == "SPELL_DAMAGE" and not fresh_meat_actual[ destGUID ] and UnitGUID( "target" ) == destGUID then
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


    spec:RegisterPack( "Fury", 20210705, [[d400kbqiOu5rOKAtePprPyuevDkkOvbbu5vuGzrPYTiQ0Ui8lkHHruCmvWYGs6zukzAOK01Ou12OuQ6BqagheOohkHADOempOuUhk1(ikDqOe1cPe9qOu1eHaYfHsKnIsi8rucrJeLq6KqG0kvHMjkjUjLsPANuO(jeqvdfcOSukLINIIPsHCvkLsSvkLkFfceJfkH9sYFHQbd6Wswms9yrMSOUSYMH0NvPrdrNgy1ukLYRHqZMu3MI2nv)gvdxfDCuIwUQEoIPlCDKSDI47usJNOIZdbTEkLsA(qX(LA1bLrkMCftzmwLbRhKbbiJ9czyX2cR2YEftGWZPyoReI1DkgVmNIHfb1JqfZzHqnVYkJumeo1NMIbzeNewWclUGajfTiXnTGamP0va4E6l0WccWmzHIHMcOdeuxrRyYvmLXyvgSEqgeGm2lKHfBlSAlBPykQaj)vmmatSVHw0qS8NqcmdWZjkgKGCEUIwXKhjPyyrq9iSHii1)a(3hpsPrydT3UgIvzW6H(yFe7rw(DewOpk3gILZ5LBicmktZPf9r52qeiaPO1l3qtUKzopAOfnKfDphKAiRS6SHPsRBO8opAOVLxUHO8VHaxU3YCnmX9yYjmu0hLBdTTZLSCdTux5rc(B2WYZneb6Rl3BOTHxFdlAUK1ql1CEoqcEs0WG3qG55ZLSgI(JLuZtiSHC0g(lXnnNNRaWDsdLNamjn85uxKAe2WXsQsBOOpk3gILZ5LBOLve61qgKCQOHbVHN)sCt6kAiwgbgRi6JYTHy5CE5gABHSgIGgZKi6JYTHgzDfIneL)nebbj41wbEUH0dL)RH6jz6gAleGOpk3gABMjxYYnelriZtJi6JYTHiqC3MOHuK1qgWUJ(xH4(gcqBiiSH0Ws)RYiSHuNnuEeOvbsZcX9gk6JYTHmlOoBiAH4AizSKAEAKgIY)gYaU(IgYpNVxOy0asqugPyk(ugPm(GYifZ8IwVSYsft6bXEqPyUPS4NzbCsdz3qzAO0gs4uAAGNfOGNe4K4bioX8IwVCdL2qAkuubk4jbojEaIt8ZSaoPHsBinfkQy(x3j(zwaN0qS1WBkRyQua4UIjvEAACAkuufdnfkkUxMtXqRR8ib)nvHYySQmsXmVO1lRSuXKEqShukgAkuuX8VUtqD2qPnmX56m3Ql(LqupcXhHi(zwaN0qzBO9kMkfaURykpbMh4fASNGKNqufkJTLYifZ8IwVSYsft6bXEqPyOPqrfZ)6ob1zdL2WVURHyRHSQmkMkfaURyiNRECokoDrca3vHYywvzKIzErRxwzPIj9GypOum0uOOI5FDNG6SHsBi5CAnEu)Dbryfj41wbEUHY2qSQyQua4UIHwx5rc(BQyaES)PodCaQI5MYIFMfWjSLrkHtPPbEwGcEsGtIhG4KstHIkqbpjWjXdqCIFMfWjsPPqrfZ)6oXpZc4eSDtzvOm2ELrkM5fTEzLLkM0dI9GsXiFdPPqrfZ)6ob1zdXGPH0uOOIFje1Jq8ricQZgkTHpLpu(FNGaCuknoH6VtmVO1l3qdBO0gkPEqrRNyYzjQy4NilYumvkaCxXK4EEMUkugB7vgPyQua4UIHa2D0)ke3RyMx06LvwQcLXiaLrkMkfaURy(Y8SUtXmVO1lRSufkJrWkJumZlA9YklvmPhe7bLIHMcfvm)R7euNnuAdtCUoZT6IFje1Jq8riIFMfWjnu2gAVIPsbG7kgY5QhNJItxKaWDvOmMfRmsXmVO1lRSuXKEqShukgAkuuX8VUt8ZSaoPHY2WBk3qe4Aiwf2RyQua4UIHwx5rc(BQcvOyia)QhEu)DHYiLXhugPyMx06LvwQyspi2dkfZt5dL)3jSc0ACokEGC407j7rCVySKcCEUCdL2qAkuuHvGwJZrXdKdNEpzpI7f)mlGtAi2A4nLvmvkaCxX81f4xCAn3QkugJvLrkM5fTEzLLkM0dI9GsX8u(q5)DcRaTgNJIhiho9EYEe3lglPaNNl3qPnKMcfvyfO14Cu8a5WP3t2J4EXpZc4KgITgEtzftLca3vmFDb(fNwZTQcLX2szKIzErRxwzPIj9GypOumKZP14r93feHvKGxBf45gYUHhAO0gEtzXpZc4KgYUHY0qPnu(ggLEEimlcPs)eZlA9YnedMgM4sMxEiKmpqIWVHg2qPnus9GIwpXKZsuXWprwK1qPnu(g(1Dnu2gYILPHyW0qSRHjoxN5wDrI75z6IFMfWjn0qftLca3vmPYttJttHIQyOPqrX9YCkgADLhj4VPkugZQkJumZlA9YklvmPhe7bLIr(gstHIkM)1DcQZgIbtdPPqrf)siQhH4JqeuNnuAdFkFO8)obb4OuACc1FNyErRxUHg2qPnus9GIwpXKZsuXWprwKPyQua4UIjX98mDvOm2ELrkM5fTEzLLkM0dI9GsXqtHIkM)1DcQZgkTHsQhu06jMCwIkg(jYImftLca3vmjUNNPRcLX2ELrkM5fTEzLLkM0dI9GsXKhnfkQGa2D0)ke3lYCREdL2q5Bi5CAnEu)Dbryfj41wbEUHY2WdnedMg(fiJpjZdrLZebWBOSn8G9n0qftLca3vmeWUJ(xH4EvOmgbOmsXmVO1lRSuXKEqShukg5BinfkQ4xcr9ieFeIG6SHyW0qAkuuH5m5pcX5O4AQeiJN)vMeb1zdnSHyW0q5BinfkQy(x3j(zwaN0qS1WBk3qmyA4x31qzBilwMgAydXGPH0uOOc0FUTvek(zwaN0qS1Wdc7vmvkaCxX8L5zDNkugJGvgPyQua4UIjX98mDfZ8IwVSYsvOmMfRmsXmVO1lRSuXKEqShukgAkuuX8VUtqD2qPnu(gsoNwJh1FxqewrcETvGNBOSn8qdXGPHFbY4tY8qu5mra8gkBdra23qdvmvkaCxXuEcmpWl0ypbjpHOkugFqgLrkM5fTEzLLkM0dI9GsXqtHIkM)1DcQZgkTHY3qY50A8O(7cIWksWRTc8CdLTHhAigmn8lqgFsMhIkNjcG3qzBiRAFdnuXuPaWDfd5C1JZrXPlsa4UkugF4GYiftLca3vmtolrftXmVO1lRSufkJpGvLrkM5fTEzLLkM0dI9GsXqtHIkM)1DcQZgkTHY3qSRH0uOOIFje1Jq8riIFMfWjnedMg(1DneBn0EzAOHnuAdLVHKZP14r93feHvKGxBf45gYUHhAO0g(fiJpjZdrLZebWBOSnKvTVHyW0qY50A8O(7cIWksWRTc8Cdz3qS2qdvmvkaCxXqRR8ib)nvHY4d2szKIzErRxwzPIPsbG7kgAnNNdKGNekM0dI9GsXqtHIkM)1DIm3Q3qmyAyI7zkqiKasaofbpX9yMNH4lhXgkBdTVHsByu)DHa5kDGuCMIgITgAl7vmjeM0dpQ)UGOm(GkugFGvvgPyMx06LvwQyspi2dkfdnfkQy(x3jYCREdXGPHjUNPaHqcib4ue8e3JzEgIVCeBOSn0(gkTHr93fcKR0bsXzkAi2AOTSVHsBi21WO0Zdr6PMoqOyErRxwXuPaWDfdTMZZbsWtcvOm(G9kJumZlA9YklvmPhe7bLIHMcfvm)R7euNnuAdLVHKZP14r93feHvKGxBf45gkBdp0qmyA4xGm(KmpevoteaVHY2Wd23qdvmvkaCxXK)6YD8NxVkugFW2RmsXuPaWDfd3j6I6ImumZlA9YklvHY4diaLrkM5fTEzLLkM0dI9GsXqtHIkm3Na6ri40CF3h459cQZgkTHKZP14r93feHvKGxBf45gkBdTLIPsbG7kgRibV2kWZQqz8beSYifZ8IwVSYsft6bXEqPysiR)osdz3qS2qmyAinfkQ4xcr9ieFeIG6SHsBOK6bfTEIjNLOIHFISiRHsByu65HWSiKk9tmVO1lRyQua4UI5RlWV40AUvvOm(alwzKIzErRxwzPIj9GypOumjK1FhPHSBiwBigmnKMcfv8lHOEeIpcrqD2qPnus9GIwpXKZsuXWprwK1qPnmk98qywesL(jMx06LvmvkaCxX81f4xCAn3QkugJvzugPyMx06LvwQyQua4UIHwZ55aj4jHIj9GypOum0uOOI5FDNiZT6kMect6Hh1FxqugFqfkJX6bLrkMkfaURyO1CEoqcEsOyMx06LvwQcLXyfRkJumvkaCxXqR58CGe8KqXmVO1lRSufkJXQTugPyQua4UI5RlWV40AUvfZ8IwVSYsvOmgRSQYiftLca3vmFDb(fNwZTQyMx06LvwQcLXy1ELrkMkfaURySIe8ARapRyMx06LvwQcvOyYdTO0HYiLXhugPyMx06LvwQyQua4UIjHS(7um5rsp4maCxXG9iR)UgcqBO1zZVgQ5(THNfjAiN6Bi)C(E7Ai)BO11Wm3TjAOVLByGCnKFoFFdtCtAEdr5FdzaxFrdL35UCTDZdKi8nuOyspi2dkftamxdLTHi4gIbtdJsppezofTE4bWCI5fTE5gIbtdRuaKm85ZemsdLTHhAigmnmXLmV8qizEGeHFdXGPHyxdFkFO8)obbC9f4Cu8G)MZJLXre4xIySKcCEUCdXGPHjoxN5wDXVeI6ri(ieXpZc4KgkBdVPSkugJvLrkMkfaURyoPmnNwXmVO1lRSufkJTLYifZ8IwVSYsfd)uXqwOyQua4UIrs9GIwpfJKstnftu65HWSiKk9tmVO1l3qPnmQ)UqGCLoqkotrdXwdTL9nedMgg1FxiqUshifNPOHyRHyvMgIbtdJ6VleixPdKIZu0qzBicwMgkTHjUK5LhcjZdKi8vmsQh3lZPyMCwIkg(jYImvOmMvvgPyMx06LvwQy4NkgYcftLca3vmsQhu06PyKuAQPyEkFO8)obbC9f4Cu8G)MZJLXre4xIyErRxUHyW0WNYhk)VtqaokLgNq93jMx06LBigmn8P8HY)7etJqcOCCtWfziMx06LvmsQh3lZPyOCalPgUE3556bJOcLX2RmsXmVO1lRSuXuPaWDfdTMZZbsWtcfJg4dpLvmhKrXKEqShukMayUgITgIGBO0gwPaiz4ZNjyKgYUHhAO0g(u(q5)Dcc46lW5O4b)nNhlJJiWVeXyjf48C5gkTHY3qSRHjUK5LhcjZdKi8BigmnmX56m3Ql(LqupcXhHi(zwaN0qSXUH3uUHgQyYJKEWza4UIblzsPRyKgcCqakDdTuZ55aj4jrdjJLuZtRHO8VHeGF1tUr93fn0GgYaU(cHkugB7vgPyMx06LvwQyQua4UI5xcr9ieFeIIrd8HNYkMdYOyspi2dkftamxdXwdrWnuAdRuaKm85Zemsdz3WdnuAdtCjZlpesMhir43qPn8P8HY)7eeW1xGZrXd(BopwghrGFjIXskW55YnuAdp)jrqR58CGe8KqXKhj9GZaWDfdwYKsxXine4Gau6gABwcr9ieFesdjJLuZtRHO8VHeGF1tUr93fn0GgA7Mhir43qdAid46leQqzmcqzKIzErRxwzPIPsbG7kgK75GeUE1PIrd8HNYkMdYOyspi2dkfdzra8lrGCphKWtiR)UgkTHbWCneBn0(gkTHvkasg(8zcgPHSB4HgkTHyxdtCjZlpesMhir43qPn8P8HY)7eeW1xGZrXd(BopwghrGFjIXskW55YnuAdp)jrqR58CGe8KOHsByIZ1zUvxKqw)DIFMfWjneBnugH9kM8iPhCgaURyWsMu6kgPHaheGs3qw09CqQHSYQZgkBdXEK1FxdjJLuZtRHO8VHeGF1tUr93fn0Gg6CxU2U5bse(n0GgYaU(cHkugJGvgPyMx06LvwQyQua4UIjHS(7umAGp8uwXCqgft6bXEqPyilcGFjcK75GeEcz931qPnmaMRHyRH23qPnSsbqYWNptWinKDdp0qPne7AyIlzE5HqY8ajc)gkTHpLpu(FNGaU(cCokEWFZ5XY4ic8lrmwsbopxUHsB45pjcK75GeUE1PIjps6bNbG7kgSKjLUIrAiWbbO0nKfDphKAiRS6SHY2qShz931qYyj180Aik)Bib4x9KBu)DrdnOHo3LRTBEGeHFdnOHmGRVqOcLXSyLrkMkfaURyo5bG7kM5fTEzLLQqz8bzugPyMx06LvwQyspi2dkftIZ1zUvx8lHOEeIpcr8ZSaoPHyRH2QHsByu65H4xcr9ie8IU8m3fZlA9YkMkfaURy(Y8SUtfkJpCqzKIzErRxwzPIj9GypOum0uOOIFje1Jq8riIm3Q3qPnmpAkuubbS7O)viUxK5w9gIbtdrbxKb(pZc4KgITgAVmkMkfaURysCNLu75pbNUCFVkugFaRkJumZlA9YklvmPhe7bLI5P8HY)7eeGJsPXju)DI5fTE5gkTH3uw8ZSaoPHSBOmnuAdLVHsQhu06jMCwIkg(jYISgIbtdLVHr93fIayo8GJFMcCBzFdLTHSQmnuAdJsppeLF3JBwEDN58qmVO1l3qmyAyu)DHiaMdp44NPa3w23qzBicqMgkTHyxdJsppeLF3JBwEDN58qmVO1l3qdBOHnuAdLVHKZP14r93feHvKGxBf45gYUHhAigmnKMcfvyUkWt6vs2lOoBOHkMkfaURy(LqupcXhHOcLXhSLYifZ8IwVSYsft6bXEqPyEkFO8)oX0iKakh3eCrgI5fTE5gkTH3uw8ZSaoPHSBOmnuAdLVHjoxN5wDb5C1JZrXPlsa4U4NzbCsdXwdTVHyW0WeNRZCRUGCU6X5O40fjaCx8ZSaoPHY2qSktdnSHsBO8nu(gstHIkO1CEwtrcb1zdXGPHrPNhIYV7XnlVUZCEiMx06LBigmn8lqgFsMhIkNjcG3qzB4bzAOHnedMgg1FxicG5WdoEgSgkBdpiJmnedMgkPEqrRNyYzjQy4NilYAigmnmQ)UqeaZHhC8myneBn8G9nuAd)cKXNK5HOYzIa4nu2gEqMgAydL2q5Bi5CAnEu)Dbryfj41wbEUHSB4HgIbtdPPqrfMRc8KELK9cQZgAOIPsbG7kMFje1Jq8riQqz8bwvzKIzErRxwzPIj9GypOumyxdLupOO1tq5awsnC9UZZ1dgPHsB4nLf)mlGtAi7gktdL2q5BO8nKMcfvqR58SMIecQZgIbtdJsppeLF3JBwEDN58qmVO1l3qmyA4xGm(KmpevoteaVHY2WdY0qdBigmnmQ)UqeaZHhC8mynu2gEqgzAigmnus9GIwpXKZsuXWprwK1qmyAyu)DHiaMdp44zWAi2A4b7BO0g(fiJpjZdrLZebWBOSn8Gmn0WgkTHY3qY50A8O(7cIWksWRTc8Cdz3WdnedMgstHIkmxf4j9kj7fuNn0qftLca3vm)siQhH4JquHY4d2RmsXmVO1lRSuXKEqShukMNYhk)VtqaxFbohfp4V58yzCeb(LiglPaNNl3qPn88Ne8Bkloi(Y8SURHsBO8nu(gstHIkO1CEwtrcb1zdXGPHrPNhIYV7XnlVUZCEiMx06LBigmn8lqgFsMhIkNjcG3qzB4bzAOHnedMgg1FxicG5WdoEgSgkBdpiJmnedMgkPEqrRNyYzjQy4NilYAigmnmQ)UqeaZHhC8myneBn8G9nuAd)cKXNK5HOYzIa4nu2gEqMgAydL2q5Bi5CAnEu)Dbryfj41wbEUHSB4HgIbtdPPqrfMRc8KELK9cQZgAOIPsbG7kMFje1Jq8rikgkYW5OO43uwz8bvOm(GTxzKIzErRxwzPIj9GypOum6jz6gkBdTLTVHsBO8nKCoTgpQ)UGiSIe8ARap3qzB4HgkTHyxdPPqrfMRc8KELK9cQZgIbtd)cKXNK5HOYzIa4neBn8MYnuAdXUgstHIkmxf4j9kj7fuNn0qftLca3vmwrcETvGNvHY4diaLrkMkfaURyOidheZKOyMx06LvwQcLXhqWkJumvkaCxXqR58mok1JqfZ8IwVSYsvOm(alwzKIzErRxwzPIj9GypOum0uOOIFje1Jq8ricQtftLca3vm07j7re4xvOmgRYOmsXmVO1lRSuXKEqShukgAkuuXVeI6ri(ierMB1BO0gMhnfkQGa2D0)ke3lYCRUIPsbG7kgn4Imi422OYxZ5HkugJ1dkJumvkaCxXGc(rR58SIzErRxwzPkugJvSQmsXuPaWDft5PrIV04PsRvmZlA9YklvHYySAlLrkM5fTEzLLkM0dI9GsXqtHIk(LqupcXhHiYCREdL2W8OPqrfeWUJ(xH4ErMB1BO0gstHIkM)1DcQtftLca3vm01fNJIhpiHirfkJXkRQmsXmVO1lRSuXKEqShukgY50A8O(7cIWksWRTc8CdLTHhumK4bPqz8bftLca3vmPsRXRua4oUgqcfJgqcCVmNIP4tfkJXQ9kJumZlA9YklvmvkaCxX8uoELca3X1asOy0asG7L5umeGF1dpQ)UqfQqXC(lXnPRqzKY4dkJumvkaCxXqxrOhobjNkumZlA9YklvHYySQmsXmVO1lRSuXKEqShukgSRHpLpu(FNGaU(cCokEWFZ5XY4ic8lrmwsbopxwXuPaWDfZVeI6ri(ievOcvOyKSNa4UYySkdwpidcqgBjSLIXA9oWVefdccw22ymcQXSizHg2qJqUgcmp5F0qu(3qBk(SPH)yjf4xUHeU5AyrfCZkwUHjKLFhr0hzfGVgEGfAi2ZDj7JLBOneoLMg4zbwytddEdTHWP00aplWcX8IwVSnnu(dYXqrFKva(AO9SqdXEUlzFSCdT5P8HY)7eyHnnm4n0MNYhk)VtGfI5fTEzBAO8hKJHI(yFebblBBmgb1ywKSqdBOrixdbMN8pAik)BOneGF1dpQ)UWMg(JLuGF5gs4MRHfvWnRy5gMqw(DerFKva(AOTyHgI9CxY(y5gAtIlzE5HaleZlA9Y20WG3qBsCjZlpeyHnnu(dYXqrFKva(AiRYcne75UK9XYn0MNYhk)VtGf20WG3qBEkFO8)obwiMx06LTPHYFqogk6J9reeSSTXyeuJzrYcnSHgHCneyEY)OHO8VH2KhArPdBA4pwsb(LBiHBUgwub3SILBycz53re9rwb4RH2IfAi2ZDj7JLBOnrPNhcSWMgg8gAtu65HaleZlA9Y20q5pihdf9rwb4RHSkl0qSN7s2hl3qBEkFO8)obwytddEdT5P8HY)7eyHyErRx2Mgk)b5yOOpYkaFnKvzHgI9CxY(y5gAZt5dL)3jWcBAyWBOnpLpu(FNaleZlA9Y20WkAiwcbEwPHYFqogk6JScWxdzvwOHyp3LSpwUH28u(q5)DcSWMgg8gAZt5dL)3jWcX8IwVSnnu(dYXqrFKva(AOTNfAi2ZDj7JLBOnjUK5LhcSqmVO1lBtddEdTjXLmV8qGf20q5pihdf9rwb4RHiawOHyp3LSpwUH2K4sMxEiWcX8IwVSnnm4n0MexY8YdbwytdL)GCmu0hzfGVgIGzHgI9CxY(y5gAtIlzE5HaleZlA9Y20WG3qBsCjZlpeyHnnu(dYXqrFKva(A4bSYcne75UK9XYn0MO0ZdbwytddEdTjk98qGfI5fTEzBAO8yvogk6JScWxdpGvwOHyp3LSpwUH28u(q5)DcSWMgg8gAZt5dL)3jWcX8IwVSnnu(dYXqrFKva(A4bBXcne75UK9XYn0MNYhk)VtGf20WG3qBEkFO8)obwiMx06LTPHYFqogk6J9reuZt(hl3qwTHvkaCVHAajiI(OIHCUKYyeawvmNphfONIH1SUHSiOEe2qeK6Fa)7JSM1n8iLgHn0E7AiwLbRh6J9rwZ6gI9il)ocl0hznRBOCBiwoNxUHiWOmnNw0hznRBOCBiceGu06LBOjxYmNhn0IgYIUNdsnKvwD2WuP1nuENhn03Yl3qu(3qGl3BzUgM4Em5egk6JSM1nuUn02oxYYn0sDLhj4Vzdlp3qeOVUCVH2gE9nSO5swdTuZ55aj4jrddEdbMNpxYAi6pwsnpHWgYrB4Ve30CEUca3jnuEcWK0WNtDrQrydhlPkTHI(iRzDdLBdXY58Yn0Ykc9Aidsov0WG3WZFjUjDfnelJaJve9rwZ6gk3gILZ5LBOTfYAicAmtIOpYAw3q52qJSUcXgIY)gIGGe8ARap3q6HY)1q9KmDdTfcq0hznRBOCBOTzMCjl3qSeHmpnIOpYAw3q52qeiUBt0qkYAidy3r)RqCFdbOnee2qAyP)vze2qQZgkpc0QaPzH4Edf9rwZ6gk3gYSG6SHOfIRHKXsQ5PrAik)Bid46lAi)C(ErFSpYAw3qSKCwIkwUH0dL)RHjUjDfnKExGtenelNs7min05UCrwVjkLUHvkaCN0qURrOOpwPaWDI48xIBsxHbSTGUIqpCcsov0hRua4orC(lXnPRWa2w8lHOEeIpcXoakBS7P8HY)7eeW1xGZrXd(BopwghrGFjIXskW55Y9X(iRzDdXsYzjQy5goj7ryddG5AyGCnSsb)BiG0Wssb0fTEI(iRBi2JS(7AiaTHwNn)AOM73gEwKOHCQVH8Z57TRH8VHwxdZC3MOH(wUHbY1q(589nmXnP5neL)nKbC9fnuEN7Y12npqIW3qrFSsbG7e2jK1FNDau2bWCYIGXGjk98qK5u06HhaZjMx06LXGPsbqYWNptWiYEadMexY8YdHK5bse(yWGDpLpu(FNGaU(cCokEWFZ5XY4ic8lrmwsbopxgdMeNRZCRU4xcr9ieFeI4NzbCIS3uUpwPaWDIbST4KY0C6(yLca3jgW2cj1dkA9SZlZXEYzjQy4NilYStsPPg7O0ZdHzriv6N0O(7cbYv6aP4mfyZw2Jbtu)DHa5kDGuCMcSHvzWGjQ)UqGCLoqkotHSiyzKM4sMxEiKmpqIWVpwPaWDIbSTqs9GIwp78YCSPCalPgUE3556bJyNKstn2pLpu(FNGaU(cCokEWFZ5XY4ic8lbdMNYhk)VtqaokLgNq93HbZt5dL)3jMgHeq54MGlYOpYAw3qJqcineqAOjNeAe2WG3WZFsMhnmX56m3QtAi6ZnBi9a(THvkbYZJsRrydPil3Wm1d8Bdn5sM58q0hznRByLca3jgW2INYXRua4oUgqc78YCSn5sM58WoakBtUKzopezajkpnzTVpYAw3WkfaUtmGTfi3ZbjC9Qt7aOSL)lqgFsMhctUKzopezajkpnzXQ9s)cKXNK5HWKlzMZdbWLLvT3W(iRzDdRua4oXa2wqglPMNMDau2vkasg(8zcgH9bPjUK5LhcjZdKi8fZlA9YsFkFO8)obbC9f4Cu8G)MZJLXre4xIySKcCEUSDEzo2wAKuBZsiYc0AophibpjyHFje1Jq8ri9rw3qSKjLUIrAiWbbO0n0snNNdKGNenKmwsnpTgIY)gsa(vp5g1Fx0qdAid46le9XkfaUtmGTf0AophibpjStd8HNYSpiJDau2bWCydblTsbqYWNptWiSpi9P8HY)7eeW1xGZrXd(BopwghrGFjIXskW55YsLh7sCjZlpesMhir4JbtIZ1zUvx8lHOEeIpcr8ZSaobBSVPSH9rw3qSKjLUIrAiWbbO0n02SeI6ri(iKgsglPMNwdr5Fdja)QNCJ6VlAObn02npqIWVHg0qgW1xi6JvkaCNyaBl(LqupcXhHyNg4dpLzFqg7aOSdG5WgcwALcGKHpFMGryFqAIlzE5HqY8ajcFX8IwVS0NYhk)VtqaxFbohfp4V58yzCeb(LiglPaNNll98NebTMZZbsWtI(iRzDdRua4oXa2wqglPMNMDau2vkasg(8zcgH9bPyxIlzE5HqY8ajcFX8IwVS0NYhk)VtqaxFbohfp4V58yzCeb(LiglPaNNlBNxMJTLgjf7rw)DSaTMZZbsWtcwa5EoiHNqw)D9rw3qSKjLUIrAiWbbO0nKfDphKAiRS6SHY2qShz931qYyj180Aik)Bib4x9KBu)DrdnOHo3LRTBEGeHFdnOHmGRVq0hRua4oXa2wGCphKW1RoTtd8HNYSpiJDau2KfbWVebY9CqcpHS(7KgaZHn7LwPaiz4ZNjye2hKIDjUK5LhcjZdKi8fZlA9YsFkFO8)obbC9f4Cu8G)MZJLXre4xIySKcCEUS0ZFse0AophibpjKM4CDMB1fjK1FN4NzbCc2KryFFK1nelzsPRyKgcCqakDdzr3ZbPgYkRoBOSne7rw)DnKmwsnpTgIY)gsa(vp5g1Fx0qdAOZD5A7Mhir43qdAid46le9XkfaUtmGTfjK1FNDAGp8uM9bzSdGYMSia(LiqUNds4jK1FN0ayoSzV0kfajdF(mbJW(GuSlXLmV8qizEGeHVyErRxw6t5dL)3jiGRVaNJIh83CESmoIa)seJLuGZZLLE(tIa5EoiHRxD2hRua4oXa2wCYda37JvkaCNyaBl(Y8SUZoak7eNRZCRU4xcr9ieFeI4NzbCc2SL0O0ZdXVeI6ri4fD5zUlMx06L7JvkaCNyaBlsCNLu75pbNUCFVDau20uOOIFje1Jq8riIm3QlnpAkuubbS7O)viUxK5wDmyqbxKb(pZc4eSzVm9XkfaUtmGTf)siQhH4JqSdGY(P8HY)7eeGJsPXju)DsVPS4NzbCcBzKkVK6bfTEIjNLOIHFISiddg5J6VlebWC4bh)mf42YEzzvzKgLEEik)Uh3S86oZ5bgmr93fIayo8GJFMcCBzVSiazKIDrPNhIYV7XnlVUZCEyOHsLNCoTgpQ)UGiSIe8ARapZ(agm0uOOcZvbEsVsYEb1PH9XkfaUtmGTf)siQhH4JqSdGY(P8HY)7etJqcOCCtWfzi9MYIFMfWjSLrQ8joxN5wDb5C1JZrXPlsa4U4NzbCc2ShdMeNRZCRUGCU6X5O40fjaCx8ZSaorwSkJHsLxEAkuubTMZZAksiOoXGjk98qu(DpUz51DMZdX8IwVmgmFbY4tY8qu5mraCzpiJHyWe1FxicG5WdoEgmzpiJmyWiPEqrRNyYzjQy4NilYWGjQ)UqeaZHhC8myy7G9s)cKXNK5HOYzIa4YEqgdLkp5CAnEu)Dbryfj41wbEM9bmyOPqrfMRc8KELK9cQtd7JvkaCNyaBl(LqupcXhHyhaLn2jPEqrRNGYbSKA46DNNRhmI0Bkl(zwaNWwgPYlpnfkQGwZ5znfjeuNyWeLEEik)Uh3S86oZ5HyErRxgdMVaz8jzEiQCMiaUShKXqmyI6VlebWC4bhpdMShKrgmyKupOO1tm5Sevm8tKfzyWe1FxicG5WdoEgmSDWEPFbY4tY8qu5mraCzpiJHsLNCoTgpQ)UGiSIe8ARapZ(agm0uOOcZvbEsVsYEb1PH9XkfaUtmGTf)siQhH4JqSJImCokk(nLzFWoak7NYhk)VtqaxFbohfp4V58yzCeb(LiglPaNNll98Ne8Bkloi(Y8SUtQ8YttHIkO1CEwtrcb1jgmrPNhIYV7XnlVUZCEiMx06LXG5lqgFsMhIkNjcGl7bzmedMO(7cramhEWXZGj7bzKbdgj1dkA9etolrfd)ezrggmr93fIayo8GJNbdBhSx6xGm(Kmpevoteax2dYyOu5jNtRXJ6VlicRibV2kWZSpGbdnfkQWCvGN0RKSxqDAyFSsbG7edyBHvKGxBf4z7aOS1tY0YAlBVu5jNtRXJ6VlicRibV2kWZYEqk2rtHIkmxf4j9kj7fuNyW8fiJpjZdrLZebWX2nLLID0uOOcZvbEsVsYEb1PH9XkfaUtmGTfuKHdIzs6JvkaCNyaBlO1CEghL6ryFSsbG7edyBb9EYEeb(1oakBAkuuXVeI6ri(ieb1zFSsbG7edyBHgCrgeCBBu5R58WoakBAkuuXVeI6ri(ierMB1LMhnfkQGa2D0)ke3lYCREFSsbG7edyBbk4hTMZZ9XkfaUtmGTfLNgj(sJNkTUpwPaWDIbSTGUU4Cu84bjej2bqzttHIk(LqupcXhHiYCRU08OPqrfeWUJ(xH4ErMB1LstHIkM)1DcQZ(yLca3jgW2IuP14vkaChxdiHDK4bPG9b78YCSl(SdGYMCoTgpQ)UGiSIe8ARapl7H(yLca3jgW2INYXRua4oUgqc78YCSja)QhEu)DrFSpwPaWDIO4JDQ80040uOO25L5ytRR8ib)nTdGY(MYIFMfWjSLrkHtPPbEwGcEsGtIhG4KstHIkqbpjWjXdqCIFMfWjsPPqrfZ)6oXpZc4eSDt5(yLca3jIIpdyBr5jW8aVqJ9eK8eI2bqzttHIkM)1DcQtPjoxN5wDXVeI6ri(ieXpZc4ezTVpwPaWDIO4Za2wqox94CuC6IeaUBhaLnnfkQy(x3jOoL(1DyJvLPpwPaWDIO4Za2wqRR8ib)nTd4X(N6mWbOSVPS4NzbCcBzKs4uAAGNfOGNe4K4bioP0uOOcuWtcCs8aeN4NzbCIuAkuuX8VUt8ZSaobB3u2oakBAkuuX8VUtqDkLCoTgpQ)UGiSIe8ARapllw7JvkaCNik(mGTfjUNNPBhaLT80uOOI5FDNG6edgAkuuXVeI6ri(ieb1P0NYhk)VtqaokLgNq93zOuj1dkA9etolrfd)ezrwFSsbG7erXNbSTGa2D0)ke33hRua4oru8zaBl(Y8SURpwPaWDIO4Za2wqox94CuC6IeaUBhaLnnfkQy(x3jOoLM4CDMB1f)siQhH4Jqe)mlGtK1((yLca3jIIpdyBbTUYJe830oakBAkuuX8VUt8ZSaor2BkJahwf23h7JvkaCNiia)QhEu)DHbST4RlWV40AUv7aOSFkFO8)oHvGwJZrXdKdNEpzpI7fJLuGZZLLstHIkSc0ACokEGC407j7rCV4NzbCc2UPCFSsbG7ebb4x9WJ6VlmGTfPNIGe4xCAn3QDau2pLpu(FNWkqRX5O4bYHtVNShX9IXskW55YsPPqrfwbAnohfpqoC69K9iUx8ZSaobB3uUpwPaWDIGa8RE4r93fgW2Iu5PPXPPqrTZlZXMwx5rc(BAhaLn5CAnEu)Dbryfj41wbEM9bP3uw8ZSaoHTmsLpk98qywesL(jMx06LXGjXLmV8qizEGeHVyErRx2qPsQhu06jMCwIkg(jYImPY)1DYYILbdgSlX56m3QlsCpptx8ZSaoXW(yLca3jccWV6Hh1FxyaBlsCppt3oakB5PPqrfZ)6ob1jgm0uOOIFje1Jq8ricQtPpLpu(FNGaCuknoH6VZqPsQhu06jMCwIkg(jYIS(yLca3jccWV6Hh1FxyaBlsCppt3oakBAkuuX8VUtqDkvs9GIwpXKZsuXWprwK1hRua4orqa(vp8O(7cdyBbbS7O)viU3oak78OPqrfeWUJ(xH4ErMB1Lkp5CAnEu)Dbryfj41wbEw2dyW8fiJpjZdrLZebWL9G9g2hRua4orqa(vp8O(7cdyBXxMN1D2bqzlpnfkQ4xcr9ieFeIG6edgAkuuH5m5pcX5O4AQeiJN)vMeb1PHyWipnfkQy(x3j(zwaNGTBkJbZx3jllwgdXGHMcfvG(ZTTIqXpZc4eSDqyFFSsbG7ebb4x9WJ6VlmGTfjUNNP3hRua4orqa(vp8O(7cdyBr5jW8aVqJ9eK8eI2bqzttHIkM)1DcQtPYtoNwJh1FxqewrcETvGNL9agmFbY4tY8qu5mraCzra2ByFSsbG7ebb4x9WJ6VlmGTfKZvpohfNUibG72bqzttHIkM)1DcQtPYtoNwJh1FxqewrcETvGNL9agmFbY4tY8qu5mraCzzv7nSpwPaWDIGa8RE4r93fgW2IjNLOI1hRua4orqa(vp8O(7cdyBbTUYJe830oakBAkuuX8VUtqDkvESJMcfv8lHOEeIpcr8ZSaobdMVUdB2lJHsLNCoTgpQ)UGiSIe8ARapZ(G0Vaz8jzEiQCMiaUSSQ9yWqoNwJh1FxqewrcETvGNzJvd7JvkaCNiia)QhEu)DHbSTGwZ55aj4jHDjeM0dpQ)UGW(GDau20uOOI5FDNiZT6yWK4EMcecjGeGtrWtCpM5zi(Yruw7Lg1FxiqUshifNPaB2Y((yLca3jccWV6Hh1FxyaBlO1CEMUcK2bqzttHIkM)1DIm3QJbtI7zkqiKasaofbpX9yMNH4lhrzTxAu)DHa5kDGuCMcSzl7LIDrPNhI0tnDGqX8IwVCFSsbG7ebb4x9WJ6VlmGTf5VUCh)51BhaLnnfkQy(x3jOoLkp5CAnEu)Dbryfj41wbEw2dyW8fiJpjZdrLZebWL9G9g2hRua4orqa(vp8O(7cdyBb3j6I6Im6JvkaCNiia)QhEu)DHbSTWksWRTc8SDau20uOOcZ9jGEecon339bEEVG6uk5CAnEu)Dbryfj41wbEwwB1hRua4orqa(vp8O(7cdyBXxxGFXP1CR2bqzNqw)De2yfdgAkuuXVeI6ri(ieb1Puj1dkA9etolrfd)ezrM0O0ZdHzriv6NyErRxUpwPaWDIGa8RE4r93fgW2I0trqc8loTMB1oak7eY6VJWgRyWqtHIk(LqupcXhHiOoLkPEqrRNyYzjQy4NilYKgLEEimlcPs)eZlA9Y9XkfaUteeGF1dpQ)UWa2wqR58CGe8KWUect6Hh1FxqyFWoakBAkuuX8VUtK5w9(yLca3jccWV6Hh1FxyaBlO1CEoqcEs0hRua4orqa(vp8O(7cdyBbTMZZ0vGSpwPaWDIGa8RE4r93fgW2IVUa)ItR5w7JvkaCNiia)QhEu)DHbSTi9ueKa)ItR5w7JvkaCNiia)QhEu)DHbSTWksWRTc8SkuHsb]] )


end
