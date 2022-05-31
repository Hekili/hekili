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

                return swing + floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed
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

                return swing + floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed
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

                return app + floor( ( t - app ) / state.haste ) * state.haste
            end,

            interval = function () return state.haste end,

            value = 5,
        },

        battle_trance = {
            aura = "battle_trance",

            last = function ()
                local app = state.buff.battle_trance.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 3 ) * 3
            end,

            interval = 3,

            value = 5,
        },

        conquerors_banner = {
            aura = "conquerors_banner",

            last = function ()
                local app = state.buff.conquerors_banner.applied
                local t = state.query_time

                return app + floor( t - app )
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


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364554, "tier28_4pc", 363738 )
    -- 2-Set - Frenzied Destruction - Raging Blow deals 15% increased damage and gains an additional charge.
    -- 4-Set - Frenzied Destruction - Raging Blow has a 20% chance to grant Recklessness for 4 sec.
    -- Now appropriately grants Crushing Blow and Bloodbath when Reckless Abandon is talented, and no longer grants 50 Rage when Recklessness triggers while Reckless Abandon is talented.


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


    spec:RegisterCombatLogEvent( function(  _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

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


        bloodbath = {
            id = 335096,
            known = 23881,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = function () return ( talent.seethe.enabled and ( stat.crit >= 100 and -4 or -2 ) or 0 ) - 8 end,
            spendType = "rage",

            cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

            startsCombat = true,
            texture = 236304,

            bind = "bloodthirst",
            talent = "reckless_abandon",
            buff = "recklessness",

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
        },


        bloodthirst = {
            id = 23881,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = function () return ( talent.seethe.enabled and ( stat.crit >= 100 and -4 or -2 ) or 0 ) - 8 end,
            spendType = "rage",

            cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

            startsCombat = true,
            texture = 136012,

            bind = "bloodbath",

            readyTime = function()
                if talent.reckless_abandon.enabled then return buff.recklessness.remains end
                return 0
            end,

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


        crushing_blow = {
            id = 335097,
            known = 85288,
            cast = 0,
            charges = function () return set_bonus.tier28_2pc > 0 and 3 or 2 end,
            cooldown = 8,
            recharge = 8,
            hasteCD = true,
            gcd = "spell",

            spend = -12,
            spendType = "rage",

            startsCombat = true,
            texture = 132215,

            bind = "raging_blow",
            talent = "reckless_abandon",
            buff = "recklessness",

            handler = function ()
                removeStack( "whirlwind" )
                if talent.reckless_abandon.enabled then spendCharges( "raging_blow", 1 ) end

                if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end
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
            id = 85288,
            cast = 0,
            charges = function () return set_bonus.tier28_2pc > 0 and 3 or 2 end,
            cooldown = 8,
            recharge = 8,
            hasteCD = true,
            gcd = "spell",

            spend = -12,
            spendType = "rage",

            startsCombat = true,
            texture = 589119,

            bind = "crushing_blow",

            readyTime = function ()
                if talent.reckless_abandon.enabled then return buff.recklessness.remains end
                return 0
            end,

            handler = function ()
                removeStack( "whirlwind" )
                if talent.reckless_abandon.enabled then spendCharges( "crushing_blow", 1 ) end

                if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end
            end,
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


    spec:RegisterPack( "Fury", 20220319, [[d4KkCbqiOk1JOeSjKYNecJIeCkc0QiHc8kskZIs0TGQODr0VOuzyqvDmsYYaGNjezAKq11OKABcr5Bcr14iH4CqvW6iGmpa09iO9Hu5GeqzHuQ6HivPjIuf6Ieq1gjHc9rOkegjju0jrQIALa0mjH0nHQq1oPK8tsOGgkufklLek9uuAQKuDvOkeTvKQGVIufzSqvYEj1Fr0GbDyjlgjpwWKb6YQ2mu(mcJgQCAiRgQcPEnLYSP42eA3u9BunCaDCcWYv65snDfxhfBNe9DH04Pe68iv16HQqY8fQ9lATkT6AwWAU2kaGpaaa(rsfEqca8XpYSwr0Sd9bEnlWkyRiUM1lXRzvmYS0xZcSOVHxGA11SnNzdxZIBgGTazNDeObhdLmWfTRrImMAqCpSf2yxJed2PzPyqMHE21uAwWAU2kaGpaaa(rsfEqca8XpYSoY0SfZGJVAwwKi9Mq7sOaBd4qIdA5TMfhce8UMsZc(oOzvmYS0pH0t1Ui(MaIhV2aUeQcpyzcba(aaajGjG0lUYjElqjG4zcfyGGhmH4XyefVrMaINjKEe1fL5GjuKR8I3NeAxcvm)YrHeQOVaMWqzmjubNpj0)bpycX4BcroEsuIpHbUp3IJGYeq8mH4X5kpycT3uGVh(kMWYbti94weCpHkwETjSO4kFcT3W5Gdo02tchEcrIaxUYNqS9cG5EG(jKJLW9bUO4DWAqCVtOcnsSt4YziWzOFcVaykJGYeq8mHcmqWdMq7RzmpHS44mtchEcbUpWfPQjHcm8ykQmbeptOade8GjepY(jKEEUyltaXZeQE0x2sigFti9eo0AIICWesDm((eAUYBsyKICzciEMqf7f5kpycf4DFp8wMaINjKEK7rmjKPFczrN4u7lBFticlHOjIoHLzFbs)eYamHkqp(AWjw2(kOmbepti7hgGjeRS9e2xam3dVtigFtilIW)KqoW7FLAwdQNwRUMT4xRU2kvA11S3lkZb12RzdlA(IknlrauUxSqENqHje)eslHnNXqHCqjgA7HSNfz7Y7fL5GjKwcPyWWKyOThYEwKTl3lwiVtiTesXGHjVVfXL7flK3jeGjKiaQzRWG4UMnuE4gskgmmnlfdggPxIxZszkW3dFf1J2kaOvxZEVOmhuBVMnSO5lQ0SumyyY7BrCjdWeslHbo3aYJ6Y9bBM3T)UL7flK3jKUeATMTcdI7A2YdO7dzHnFBC8Gn9OTksA11S3lkZb12RzdlA(IknlfdgM8(wexYamH0s4wepHamHko(A2kmiURzBGVwsogjv1dI76rBLIRvxZEVOmhuBVMnSO5lQ0SumyyY7BrCjdWeslHnWBmKtTeFAzuCO1ef5GjKUecanBfge31SuMc89WxrnlYNVldWHeHPzjcGY9IfYBH4tR5mgkKdkXqBpK9SiBNgfdgMedT9q2ZISD5EXc5nnkgmm59TiUCVyH8gGebq9OTYAT6A27fL5GA71SHfnFrLMvHesXGHjVVfXLmatyCCcPyWWK7d2mVB)DlzaMqAjCz8JXxIlBKJXyiBML4Y7fL5GjuWeslHkRfvuMlVfFGzojqCvFnBfge31SbUdErxpARImT6A2kmiURzB0jo1(Y2xn79IYCqT96rBvKRvxZwHbXDn7wIalIRzVxuMdQTxpARueT6A27fL5GA71SHfnFrLMLIbdtEFlIlzaMqAjmW5gqEuxUpyZ8U93TCVyH8oH0LqR1SvyqCxZ2aFTKCmsQQhe31J2k8GwDn79IYCqT9A2WIMVOsZsXGHjVVfXL7flK3jKUeseatOIbjeasR1SvyqCxZszkW3dFf1JE0SnYjmNCQL4JwDTvQ0QRzVxuMdQTxZgw08fvA2LXpgFjUmkYyi5yKdUts9T)A7R8cGbbe4btiTesXGHjJImgsog5G7KuF7V2(k3lwiVtiatirauZwHbXDn7weiNGKYWJQhTvaqRUM9ErzoO2EnByrZxuPzxg)y8L4YOiJHKJro4oj13(RTVYlageqGhmH0sifdgMmkYyi5yKdUts9T)A7RCVyH8oHamHebqnBfge31SHLPXHCcskdpQE0wfjT6A27fL5GA71SHfnFrLMTbEJHCQL4tlJIdTMOihmHctOQeslHebq5EXc5DcfMq8tiTeQqcNYCFKIv3vyV8ErzoycJJtyGR8E5Ju59bh93ekycPLqL1IkkZL3IpWmNeiUQFcPLqfs4wepH0Lq8a(jmooH4DcdCUbKh1LbUdErxUxSqENqb1SvyqCxZgkpCdjfdgMMLIbdJ0lXRzPmf47HVI6rBLIRvxZEVOmhuBVMnSO5lQ0SkKqkgmm59TiUKbycJJtifdgMCFWM5D7VBjdWeslHlJFm(sCzJCmgdzZSexEVOmhmHcMqAjuzTOIYC5T4dmZjbIR6RzRWG4UMnWDWl66rBL1A11S3lkZb12RzdlA(Iknl4PyWWKn6eNAFz7ReKh1tiTeQqcBG3yiNAj(0YO4qRjkYbtiDjuvcJJt4wiqYR8(ilqWwI8esxcvzDcfuZwHbXDnBJoXP2x2(QhTvrMwDn79IYCqT9A2WIMVOsZsXGHj3hSzE3(7wYamHXXjuHesXGHjVVfXL7flK3jeGjKiaMW44eUfXtiDjurWpHcMW44esXGHjX274rrF5EXc5DcbycvjTwZwHbXDn7wIalIRhTvrUwDn79IYCqT9A2WIMVOsZ2FiP4otlh0xaOiKaayiHXXjmGRwI3juycbqcJJtOcjKIbdtUpyZ8U93TKbycPLqL1IkkZL3IpWmNeiUQFcPLWPm3hPy1Df2lVxuMdMqb1SvyqCxZgwMghYjiPm8O6rBLIOvxZwHbXDnBG7Gx01S3lkZb12RhTv4bT6A27fL5GA71SHfnFrLMLIbdtEFlIlzaMqAjmW5gqEuxUpyZ8U93TCVyH8oH0LqRtiTeQqcP4DNqAjedrGBi3lwiVtiDjepyDcJJtifdgMCFWM5D7VBjdWeghNqkE3jKwcXqe4gY9IfY7ecWeca8tOGjKwc3cbsEL3hzbc2sKNq6syKBTMTcdI7A2YdO7dzHnFBC8Gn9OTsf(A11SvyqCxZEl(aZCn79IYCqT96rBLkvA11S3lkZb12RzdlA(Ikn7Y4hJVexEd9Bu5KIicCJ8ErzoycPLqkgmm59TiUKbycPLWaNBa5rD5(GnZ72F3Y9IfY7esxcToH0sOcjKIbdtUpyZ8U93TKbycJJtifV7eslHyicCd5EXc5Dcbycba(jmooHGNIbdt2OtCQ9LTVsgGjmooH4DcNYCFKn6eNAFz7R8ErzoycPLqkE3jKwcXqe4gY9IfY7esxcJmfjHcMqAjClei5vEFKfiylrEcPlHwBTMTcdI7A2g4RLKJrsv9G4UE0wPcaA11S3lkZb12RzdlA(IknlfdgM8(wexYamH0sOcjeVtifdgMCFWM5D7VB5EXc5DcJJt4wepHamHwJFcfmH0sOcjSbEJHCQL4tlJIdTMOihmHctOQeslHBHajVY7JSabBjYtiDjuXToHXXjSbEJHCQL4tlJIdTMOihmHctiasOGA2kmiURzPmf47HVI6rBLQiPvxZEVOmhuBVMnSO5lQ0SumyyY7BrCjdWeslHbo3aYJ6Y9bBM3T)UL7flK3jKUeADcPLqfsifdgMCFWM5D7VBjdWeghNqkE3jKwcXqe4gY9IfY7ecWeca8tyCCcbpfdgMSrN4u7lBFLmatyCCcX7eoL5(iB0jo1(Y2x59IYCWeslHu8UtiTeIHiWnK7flK3jKUegzkscfmH0s4wiqYR8(ilqWwI8esxcT2AnBfge31SnWxljhJKQ6bXD9OTsLIRvxZEVOmhuBVMnSO5lQ0SumyyY7BrCjipQNW44eg4oidAKkrbeNPjdCFUiWrULBlH0LqRtiTeo1s8rI7LzWjbgMecWegjR1SvyqCxZsz4CWbhA7rpARuzTwDn79IYCqT9A2WIMVOsZsXGHjVVfXLG8OEcJJtyG7GmOrQefqCMMmW95Iah5wUTesxcToH0s4ulXhjUxMbNeyysiatyKSoH0siENWPm3hzyzUzOV8ErzoOMTcdI7AwkdNdsvdo9OTsvKPvxZEVOmhuBVMnSO5lQ0SumyysXVbK5DtsX9tSih8RKbycPLWg4ngYPwIpTmko0AIICWesxcvPzRWG4UMnko0AIICq9OTsvKRvxZEVOmhuBVMnSO5lQ0S9hskUZ0Yb9fakcjaagsyCCcd4QL4DcfMqaKW44eQqcPyWWK7d2mVB)DlzaMqAjuzTOIYC5T4dmZjbIR6NqAjCkZ9rkwDxH9Y7fL5GjuqnBfge31SBrGCcskdpQE0wPsr0QRzVxuMdQTxZgw08fvAwkgmm59TiUKbycPLqfsyd8gd5ulXNwgfhAnrroycPlHQsyCCc3cbsEL3hzbc2sKNq6sOkRtOGA2kmiURzb3IG7KlVw9OTsfEqRUM9ErzoO2EnByrZxuPzPyWWK33I4sgGA2kmiURz5EBkgcCJE0wba81QRzRWG4UMLYW5Gdo02JM9ErzoO2E9OTcaQ0QRzRWG4UMLYW5Gu1GtZEVOmhuBVE0wbaaOvxZwHbXDn7weiNGKYWJQzVxuMdQTxpARaqK0QRzRWG4UMnSmnoKtqsz4r1S3lkZb12RhTvaqX1QRzRWG4UMnko0AIICqn79IYCqT96rpAwWJvmMrRU2kvA11S3lkZb12RzRWG4UMnGRwIRzbFhweWbXDnl9IRwINqewcJ(i2Nqd3jsiWQNeYz2eYbE)RLjKVjm6tii3JysO)dMWb3tih49VjmWfP4jeJVjKfr4FsOco3Xt6H7do6Vck1SHfnFrLMDqIpH0LqfjHXXjCkZ9rcYzOmNCqIxEVOmhmHXXjScds5jVFr07esxcvLW44eg4kVx(ivEFWr)nHXXjeVt4Y4hJVex2ic)djhJC4R495GK2qorlVayqabEWeghNWaNBa5rD5(GnZ72F3Y9IfY7esxcjcG6rBfa0QRzRWG4UMfiJO4nA27fL5GA71J2QiPvxZEVOmhuBVMLduZ2F0SvyqCxZQSwurzUMvzzyUMDkZ9rkwDxH9Y7fL5GjKwcNAj(iX9Ym4KadtcbycJK1jmooHtTeFK4EzgCsGHjHamHaa)eghNWPwIpsCVmdojWWKq6sOIGFcPLWax59YhPY7do6VAwL1s6L41S3IpWmNeiUQVE0wP4A11S3lkZb12Rz5a1S9hnBfge31SkRfvuMRzvwgMRzxg)y8L4Ygr4Fi5yKdFfVphK0gYjA59IYCWeghNWLXpgFjUSrogJHSzwIlVxuMdMW44eUm(X4lXL3q)gvoPiIa3iVxuMdQzvwlPxIxZY4ibWCsZjUdwl6TE0wzTwDn79IYCqT9A2kmiURzPmCo4GdT9Ozni)KbqnRk81SHfnFrLMDqIpHamHkscPLWkmiLN8(frVtOWeQkH0s4Y4hJVex2ic)djhJC4R495GK2qorlVayqabEWeslHkKq8oHbUY7LpsL3hC0FtyCCcdCUbKh1L7d2mVB)Dl3lwiVtiafMqIaycfuZc(oSiGdI7AwbUiJPM3je5ObvMeAVHZbhCOTNe2xam3dpHy8nHnYjmhpNAj(Kq1silIW)i1J2QitRUM9ErzoO2EnBfge31S7d2mVB)DRzni)KbqnRk81SHfnFrLMDqIpHamHkscPLWkmiLN8(frVtOWeQkH0syGR8E5Ju59bh93eslHlJFm(sCzJi8pKCmYHVI3NdsAd5eT8cGbbe4btiTecCVsjLHZbhCOThnl47WIaoiURzf4ImMAENqKJguzsOI9bBM3T)UtyFbWCp8eIX3e2iNWC8CQL4tcvlH0d3hC0FtOAjKfr4FK6rBvKRvxZEVOmhuBVMTcdI7AwCF5OaP5fqnRb5NmaQzvHVMnSO5lQ0S9Nb5eTe3xokqgWvlXtiTeoiXNqaMqRtiTewHbP8K3Vi6DcfMqvjKwcX7eg4kVx(ivEFWr)nH0s4Y4hJVex2ic)djhJC4R495GK2qorlVayqabEWeslHa3Rusz4CWbhA7jH0syGZnG8OUmGRwIl3lwiVtiati(sR1SGVdlc4G4UMvGlYyQ5DcroAqLjHkMF5Oqcv0xatiDjKEXvlXtyFbWCp8eIX3e2iNWC8CQL4tcvlHo3Xt6H7do6VjuTeYIi8ps9OTsr0QRzVxuMdQTxZwHbXDnBaxTexZAq(jdGAwv4RzdlA(IknB)zqorlX9LJcKbC1s8eslHds8jeGj06eslHvyqkp59lIENqHjuvcPLq8oHbUY7LpsL3hC0FtiTeUm(X4lXLnIW)qYXih(kEFoiPnKt0YlageqGhmH0siW9kL4(YrbsZlGAwW3HfbCqCxZkWfzm18oHihnOYKqfZVCuiHk6lGjKUesV4QL4jSVayUhEcX4BcBKtyoEo1s8jHQLqN74j9W9bh93eQwczre(hPE0wHh0QRzRWG4UMfiFqCxZEVOmhuBVE0wPcFT6A27fL5GA71SHfnFrLMDlINq6syKJVMTcdI7A2a3faZx(2KuL7F1J2kvQ0QRzVxuMdQTxZgw08fvAwkgmm59TiUKbycPLWTiEcbycJC81SvyqCxZ2aFTKCmsQQhe31J2kvaqRUM9ErzoO2EnByrZxuPzdCUbKh1L7d2mVB)Dl3lwiVtiatyKsiTeoL5(i3hSzE3Kfv5GCxEVOmhuZwHbXDn7wIalIRhTvQIKwDn79IYCqT9A2WIMVOsZsXGHj3hSzE3(7wcYJ6jKwcbpfdgMSrN4u7lBFLG8OEcJJtigIa3qUxSqENqaMqRXxZwHbXDnBG7cG5lFBsQY9V6rBLkfxRUM9ErzoO2EnByrZxuPzxg)y8L4Yg5ymgYMzjU8ErzoycPLqIaOCVyH8oHcti(jKwcviHkRfvuMlVfFGzojqCv)eghNqfs4ulXh5Gep5WjbggYizDcPlHko(jKwcNYCFKLt8LuS8I4I3h59IYCWeghNWPwIpYbjEYHtcmmKrY6esxcJC8tiTeI3jCkZ9rwoXxsXYlIlEFK3lkZbtOGjuWeslHkKWg4ngYPwIpTmko0AIICWekmHQsyCCcPyWWKIVgYG5LYVsgGjuqnBfge31S7d2mVB)DRhTvQSwRUM9ErzoO2EnByrZxuPzxg)y8L4YBOFJkNuerGBK3lkZbtiTeseaL7flK3juycXpH0sOcjmW5gqEux2aFTKCmsQQhe3L7flK3jeGj06eghNWaNBa5rDzd81sYXiPQEqCxUxSqENq6siaWpHcMqAjuHeQqcPyWWKugoh0W0JKbycJJt4uM7JSCIVKILxex8(iVxuMdMW44eUfcK8kVpYceSLipH0Lqv4NqbtyCCcP4DNqAjedrGBi3lwiVtiDjuf(4NW44eQSwurzU8w8bM5KaXv9tyCCcP4DNqAjedrGBi3lwiVtiatOkRtiTeUfcK8kVpYceSLipH0Lqv4NqbtiTeQqcBG3yiNAj(0YO4qRjkYbtOWeQkHXXjKIbdtk(AidMxk)kzaMqb1SvyqCxZUpyZ8U93TE0wPkY0QRzVxuMdQTxZgw08fvAw8oHkRfvuMlzCKayoP5e3bRf9oH0sirauUxSqENqHje)eslHkKqfsifdgMKYW5GgMEKmatyCCcNYCFKLt8LuS8I4I3h59IYCWeghNWTqGKx59rwGGTe5jKUeQc)ekycJJtifV7eslHyicCd5EXc5DcPlHQWh)eghNqL1IkkZL3IpWmNeiUQFcJJtifV7eslHyicCd5EXc5DcbycvzDcPLWTqGKx59rwGGTe5jKUeQc)ekycPLqfsyd8gd5ulXNwgfhAnrroycfMqvjmooHumyysXxdzW8s5xjdWekycPLqfsiENWax59YhP)WYn8fmHXXjmW5gqEuxg4Uay(Y3MKQC)RCVyH8oH0LqaGFcfuZwHbXDn7(GnZ72F36rBLQixRUM9ErzoO2EnByrZxuPzxg)y8L4Ygr4Fi5yKdFfVphK0gYjA5fadciWdMqAje4ELKebqPk5wIalINqAjuHeQqcPyWWKugoh0W0JKbycJJt4uM7JSCIVKILxex8(iVxuMdMW44eUfcK8kVpYceSLipH0Lqv4NqbtyCCcP4DNqAjedrGBi3lwiVtiDjuf(4NW44eQSwurzU8w8bM5KaXv9tyCCcP4DNqAjedrGBi3lwiVtiatOkRtiTeUfcK8kVpYceSLipH0Lqv4NqbtiTeQqcBG3yiNAj(0YO4qRjkYbtOWeQkHXXjKIbdtk(AidMxk)kzaMqb1SvyqCxZUpyZ8U93TMLPpjhdJKiaQTsLE0wPsr0QRzVxuMdQTxZgw08fvAwZvEtcPlHrkYsiTeQqcBG3yiNAj(0YO4qRjkYbtiDjuvcPLq8oHumyysXxdzW8s5xjdWeghNWTqGKx59rwGGTe5jeGjKiaMqAjeVtifdgMu81qgmVu(vYamHcQzRWG4UMnko0AIICq9OTsfEqRUM9ErzoO2EnBfge31SiVdlZuuMtkaMYhgrsWRefUMnSO5lQ0Sbo3aYJ6Y9bBM3T)UL7flK3jKUeQc)eslHkKqkgmm5(GnZ72F3sgGjmooHu8UtiTeIHiWnK7flK3jeGjeaQsyCCcP4DNqAjedrGBi3lwiVtiDjufEa)eghNqkgmmjLHZbnm9izaMqb1SEjEnlY7WYmfL5KcGP8HrKe8krHRhTvaaFT6A27fL5GA71SvyqCxZgTSD)BtITChuZgw08fvA2aNBa5rD5(GnZ72F3Y9IfY7esxcvHFcPLqfsifdgMCFWM5D7VBjdWeghNqkE3jKwcXqe4gY9IfY7ecWeQksjmooHu8UtiTeIHiWnK7flK3jKUeQks4Nqb1SEjEnB0Y29Vnj2YDq9OTcaQ0QRzVxuMdQTxZwHbXDnRyfkQ9KnU)HuKPrbnByrZxuPzdCUbKh1L7d2mVB)Dl3lwiVtiDjuf(jKwcviHumyyY9bBM3T)ULmatyCCcP4DNqAjedrGBi3lwiVtiatiaSoHXXjKI3DcPLqmebUHCVyH8oH0LqvQWpHcQz9s8AwXkuu7jBC)dPitJc6rBfaaGwDn79IYCqT9A2kmiURz5k)gf3nIiNGeip6xYWs)EkJMnSO5lQ0Sbo3aYJ6Y9bBM3T)UL7flK3jKUeQc)eslHkKqkgmm5(GnZ72F3sgGjmooHu8UtiTeIHiWnK7flK3jeGjuvKLW44esX7oH0sigIa3qUxSqENq6sOk8XpHcQz9s8AwUYVrXDJiYjibYJ(LmS0VNYOhTvaisA11S3lkZb12RzRWG4UMf59SmHHVnjisjYpj1ngnByrZxuPzdCUbKh1L7d2mVB)Dl3lwiVtiDjuf(jKwcviHumyyY9bBM3T)ULmatyCCcP4DNqAjedrGBi3lwiVtiatOk8tyCCcP4DNqAjedrGBi3lwiVtiDjepyDcfuZ6L41SiVNLjm8Tjbrkr(jPUXOhTvaqX1QRzVxuMdQTxZwHbXDnlMPepjhJKQMXCnByrZxuPzdCUbKh1L7d2mVB)Dl3lwiVtiDjuf(jKwcviHumyyY9bBM3T)ULmatyCCcP4DNqAjedrGBi3lwiVtiatOkvjmooHu8UtiTeIHiWnK7flK3jKUeQcF8tOGAwVeVMfZuINKJrsvZyUE0wbaR1QRzVxuMdQTxZwHbXDnlHPar1W3MKQajUMnSO5lQ0Sbo3aYJ6Y9bBM3T)UL7flK3jKUeQc)eslHkKqkgmm5(GnZ72F3sgGjmooHu8UtiTeIHiWnK7flK3jeGjuLQeghNqkE3jKwcXqe4gY9IfY7esxcJmRtOGAwVeVMLWuGOA4BtsvGexpARaqKPvxZEVOmhuBVM1lXRz7qTnjhJeBR5RxgYEwe21SvyqCxZ2HABsogj2wZxVmK9SiSRhTvaiY1QRzVxuMdQTxZ6L41SeLYBi5yKdUtIH2EiRLcnF1SvyqCxZsukVHKJro4ojgA7HSwk08vpARaGIOvxZwHbXDnltFs0CXwZEVOmhuBVE0wba8GwDnBfge31SugohKeJzPVM9ErzoO2E9OTks4RvxZEVOmhuBVMnSO5lQ0SumyyY9bBM3T)ULma1SvyqCxZs9T)Ad5e6rBvKuPvxZEVOmhuBVMnSO5lQ0SumyyY9bBM3T)ULG8OEcPLqWtXGHjB0jo1(Y2xjipQRzRWG4UM1GiWnnjE0mGeI3h9OTksaqRUMTcdI7Awm0EkdNdQzVxuMdQTxpARIuK0QRzRWG4UMT8W7zldzOmgn79IYCqT96rBvKuCT6A27fL5GA71SHfnFrLMLIbdtUpyZ8U93TeKh1tiTecEkgmmzJoXP2x2(kb5r9eslHumyyY7BrCjdqnBfge31SufbjhJCwuWwRhTvrYAT6A27fL5GA71SHfnFrLMTbEJHCQL4tlJIdTMOihmH0LqvA2Ewuy0wPsZwHbXDnBOmgYkmiUtAq9OznOEi9s8A2IF9OTksrMwDn79IYCqT9A2kmiURzxgNScdI7KgupAwdQhsVeVMTroH5KtTeF0JE0Sa3h4Iu1OvxBLkT6A2kmiURzPQzmNSXXzgn79IYCqT96rBfa0QRzVxuMdQTxZgw08fvAw8oHlJFm(sCzJi8pKCmYHVI3NdsAd5eT8cGbbe4b1SvyqCxZUpyZ8U93TE0wfjT6A2kmiURzdCxamF5BtsvU)vZEVOmhuBVE0JE0Sk)2iURTca4daaGFKuPsZgTwh5eTMLEsGPyTIE2k8ieOeMq1X9eIebY3jHy8nHru8hrc3lag0EWe2CXNWIz4I1CWegWvoXBzcOII8NqvcucPxUR87CWegrZzmuihuIxrKWHNWiAoJHc5Gs8sEVOmhmIeQGklkOmburr(tO1cucPxUR87CWegXY4hJVexIxrKWHNWiwg)y8L4s8sEVOmhmIeQGklkOmbmbKEsGPyTIE2k8ieOeMq1X9eIebY3jHy8nHr0iNWCYPwIprKW9cGbThmHnx8jSygUynhmHbCLt8wMaQOi)jmscucPxUR87CWegrGR8E5JeVK3lkZbJiHdpHre4kVx(iXRisOcQSOGYeqff5pHkUaLq6L7k)ohmHrSm(X4lXL4vejC4jmILXpgFjUeVK3lkZbJiHkOYIcktavuK)eQsLaLq6L7k)ohmHrmL5(iXRis4WtyetzUps8sEVOmhmIeQGklkOmburr(tOkvcucPxUR87CWegXY4hJVexIxrKWHNWiwg)y8L4s8sEVOmhmIeQGklkOmburr(tOQijqjKE5UYVZbtyetzUps8kIeo8egXuM7JeVK3lkZbJiHkOYIcktataPNeykwRONTcpcbkHjuDCpHirG8DsigFtyeGhRymtejCVayq7btyZfFclMHlwZbtyax5eVLjGkkYFcJKaLq6L7k)ohmHrmL5(iXRis4WtyetzUps8sEVOmhmIeQGklkOmburr(tOIlqjKE5UYVZbtyelJFm(sCjEfrchEcJyz8JXxIlXl59IYCWisOcQSOGYeqff5pHkUaLq6L7k)ohmHrSm(X4lXL4vejC4jmILXpgFjUeVK3lkZbJiH1KqbUIHkAcvqLffuMaQOi)juXfOesVCx535GjmILXpgFjUeVIiHdpHrSm(X4lXL4L8ErzoyejubvwuqzcOII8NWitGsi9YDLFNdMWicCL3lFK4L8ErzoyejC4jmIax59YhjEfrcvqLffuMaQOi)jmYfOesVCx535GjmIax59YhjEjVxuMdgrchEcJiWvEV8rIxrKqfuzrbLjGkkYFcvebkH0l3v(DoycJiWvEV8rIxY7fL5GrKWHNWicCL3lFK4vejubvwuqzcOII8NqvkUaLq6L7k)ohmHrmL5(iXRis4WtyetzUps8sEVOmhmIeQaaSOGYeqff5pHQuCbkH0l3v(DoycJyz8JXxIlXRis4WtyelJFm(sCjEjVxuMdgrcvqLffuMaQOi)juL1cucPxUR87CWegXY4hJVexIxrKWHNWiwg)y8L4s8sEVOmhmIeQGklkOmbmbKEweiFNdMqfpHvyqCpHgupTmbuZcC5yiZ1SwWcjuXiZs)espv7I4BcOfSqcXJxBaxcvHhSmHaaFaaGeWeqlyHesV4kN4TaLaAblKq8mHcmqWdMq8ymII3itaTGfsiEMq6ruxuMdMqrUYlEFsODjuX8lhfsOI(cycdLXKqfC(Kq)h8GjeJVje54jrj(eg4(ClocktaTGfsiEMq84CLhmH2BkW3dFfty5GjKEClcUNqflV2ewuCLpH2B4CWbhA7jHdpHirGlx5ti2EbWCpq)eYXs4(axu8oyniU3juHgj2jC5me4m0pHxamLrqzcOfSqcXZekWabpycTVMX8eYIJZmjC4je4(axKQMekWWJPOYeqlyHeINjuGbcEWeIhz)esppxSLjGwWcjeptO6rFzlHy8nH0t4qRjkYbti1X47tO5kVjHrkYLjGwWcjeptOI9ICLhmHc8UVhEltaTGfsiEMq6rUhXKqM(jKfDItTVS9nHiSeIMi6ewM9fi9tidWeQa94RbNyz7RGYeqlyHeINjK9ddWeIv2Ec7laM7H3jeJVjKfr4Fsih49VYeWeqlyHekWT4dmZbti1X47tyGlsvtcPobYBzcfyHWboDcDUJN4QveJXKWkmiU3jK7g6ltaRWG4ElbUpWfPQrnH2rvZyozJJZmjGvyqCVLa3h4Iu1OMq72hSzE3(72seMq8Ez8JXxIlBeH)HKJro8v8(CqsBiNOLxamiGapycyfge3BjW9bUivnQj0Ua3faZx(2KuL7FtataTGfsOa3IpWmhmHx5x6NWbj(eo4EcRWW3eI6ewklKPOmxMaAHesV4QL4jeHLWOpI9j0WDIecS6jHCMnHCG3)Azc5BcJ(ecY9iMe6)GjCW9eYbE)BcdCrkEcX4Bczre(NeQGZD8KE4(GJ(RGYeWkmiU3cd4QL4wIWeoiXtNIehpL5(ib5muMtoiXlVxuMdghxHbP8K3Vi6nDQIJdCL3lFKkVp4O)ghJ3lJFm(sCzJi8pKCmYHVI3NdsAd5eT8cGbbe4bJJdCUbKh1L7d2mVB)Dl3lwiVPJiaMawHbX9wnH2bKru8MeWkmiU3Qj0oL1IkkZT0lXl8w8bM5KaXv9TuzzyUWPm3hPy1Df2tBQL4Je3lZGtcmmamswhhp1s8rI7LzWjbggaca8JJNAj(iX9Ym4KaddDkc(0cCL3lFKkVp4O)MawHbX9wnH2PSwurzULEjEHmosamN0CI7G1IEBPYYWCHlJFm(sCzJi8pKCmYHVI3NdsAd5eDC8Y4hJVex2ihJXq2mlXJJxg)y8L4YBOFJkNuerGBsaTGfsO64qDcrDcf59yOFchEcbUx59jHbo3aYJ6DcXwUycPoYjsyfciW7tzm0pHm9btiiZICIekYvEX7Jmb0cwiHvyqCVvtODlJtwHbXDsdQhl9s8cf5kV49XseMqrUYlEFKGOEkpC6Sob0cwiHvyqCVvtOD4(YrbsZlGwIWeQWwiqYR8(if5kV49rcI6P8WPdawtBlei5vEFKICLx8(iroDkU1cMaAblKWkmiU3Qj0U(cG5E4wIWewHbP8K3Vi6Tqv0cCL3lFKkVp4O)kVxuMdsBz8JXxIlBeH)HKJro8v8(CqsBiNOLxamiGapOLEjEH2Ronf7d2eikdNdo4qBpc0(GnZ72F3jGwiHcCrgtnVtiYrdQmj0EdNdo4qBpjSVayUhEcX4BcBKtyoEo1s8jHQLqweH)rMawHbX9wnH2rz4CWbhA7XsdYpzauOk8TeHjCqIhGkcTkmiLN8(frVfQI2Y4hJVex2ic)djhJC4R495GK2qorlVayqabEqAkG3bUY7LpsL3hC0FJJdCUbKh1L7d2mVB)Dl3lwiVbOqIaOGjGwiHcCrgtnVtiYrdQmjuX(GnZ72F3jSVayUhEcX4BcBKtyoEo1s8jHQLq6H7do6VjuTeYIi8pYeWkmiU3Qj0U9bBM3T)UT0G8tgafQcFlrychK4bOIqRcds5jVFr0BHQOf4kVx(ivEFWr)vEVOmhK2Y4hJVex2ic)djhJC4R495GK2qorlVayqabEqAa3Rusz4CWbhA7jb0cwiHvyqCVvtOD9faZ9WTeHjScds5jVFr0BHQOH3bUY7LpsL3hC0FL3lkZbPTm(X4lXLnIW)qYXih(kEFoiPnKt0YlageqGh0sVeVq7vNg9IRwIlqugohCWH2EeiCF5OazaxTepb0cjuGlYyQ5DcroAqLjHkMF5Oqcv0xatiDjKEXvlXtyFbWCp8eIX3e2iNWC8CQL4tcvlHo3Xt6H7do6VjuTeYIi8pYeWkmiU3Qj0oCF5OaP5fqlni)KbqHQW3seMW(ZGCIwI7lhfid4QL40gK4bO10QWGuEY7xe9wOkA4DGR8E5Ju59bh9x59IYCqAlJFm(sCzJi8pKCmYHVI3NdsAd5eT8cGbbe4bPbCVsjLHZbhCOThAbo3aYJ6YaUAjUCVyH8gG4lTob0cjuGlYyQ5DcroAqLjHkMF5Oqcv0xatiDjKEXvlXtyFbWCp8eIX3e2iNWC8CQL4tcvlHo3Xt6H7do6VjuTeYIi8pYeWkmiU3Qj0UaUAjULgKFYaOqv4Bjcty)zqorlX9LJcKbC1sCAds8a0AAvyqkp59lIElufn8oWvEV8rQ8(GJ(R8ErzoiTLXpgFjUSre(hsog5WxX7ZbjTHCIwEbWGac8G0aUxPe3xokqAEbmbScdI7TAcTdiFqCpbScdI7TAcTlWDbW8LVnjv5(xlryc3I40f54NawHbX9wnH21aFTKCmsQQhe3TeHjKIbdtEFlIlzasBlIdWih)eWkmiU3Qj0UTebwe3seMWaNBa5rD5(GnZ72F3Y9IfYBagjAtzUpY9bBM3nzrvoi3L3lkZbtaRWG4ERMq7cCxamF5BtsvU)1seMqkgmm5(GnZ72F3sqEuNg4PyWWKn6eNAFz7ReKh1JJXqe4gY9IfYBaAn(jGvyqCVvtOD7d2mVB)DBjct4Y4hJVex2ihJXq2mlXPreaL7flK3cXNMckRfvuMlVfFGzojqCv)4yfMAj(ihK4jhojWWqgjRPtXXN2uM7JSCIVKILxex8(ehp1s8roiXtoCsGHHmswtxKJpn8EkZ9rwoXxsXYlIlEFeuqAk0aVXqo1s8PLrXHwtuKdkuvCmfdgMu81qgmVu(vYauWeWkmiU3Qj0U9bBM3T)UTeHjCz8JXxIlVH(nQCsrebUHgrauUxSqEleFAke4CdipQlBGVwsogjv1dI7Y9IfYBaADCCGZnG8OUSb(Aj5yKuvpiUl3lwiVPda4linfuGIbdtsz4CqdtpsgGXXtzUpYYj(skwErCX7J8ErzoyC8wiqYR8(ilqWwIC6uHVGXXu8UPHHiWnK7flK30PcF8JJvwlQOmxEl(aZCsG4Q(XXu8UPHHiWnK7flK3auL102cbsEL3hzbc2sKtNk8fKMcnWBmKtTeFAzuCO1ef5GcvfhtXGHjfFnKbZlLFLmafmbScdI7TAcTBFWM5D7VBlrycXBL1IkkZLmosamN0CI7G1IEtJiak3lwiVfIpnfuGIbdtsz4CqdtpsgGXXtzUpYYj(skwErCX7J8ErzoyC8wiqYR8(ilqWwIC6uHVGXXu8UPHHiWnK7flK30PcF8JJvwlQOmxEl(aZCsG4Q(XXu8UPHHiWnK7flK3auL102cbsEL3hzbc2sKtNk8fKMcnWBmKtTeFAzuCO1ef5GcvfhtXGHjfFnKbZlLFLmafKMc4DGR8E5J0Fy5g(cghh4CdipQldCxamF5BtsvU)vUxSqEthaWxWeWkmiU3Qj0U9bBM3T)UTKPpjhdJKiakuLLimHlJFm(sCzJi8pKCmYHVI3NdsAd5eT8cGbbe4bPbCVssIaOuLClrGfXPPGcumyyskdNdAy6rYamoEkZ9rwoXxsXYlIlEFK3lkZbJJ3cbsEL3hzbc2sKtNk8fmoMI3nnmebUHCVyH8Mov4JFCSYArfL5YBXhyMtcex1poMI3nnmebUHCVyH8gGQSM2wiqYR8(ilqWwIC6uHVG0uObEJHCQL4tlJIdTMOihuOQ4ykgmmP4RHmyEP8RKbOGjGvyqCVvtODrXHwtuKdAjctO5kVHUifz0uObEJHCQL4tlJIdTMOihKov0WBkgmmP4RHmyEP8RKbyC8wiqYR8(ilqWwICaseaPH3umyysXxdzW8s5xjdqbtaRWG4ERMq7y6tIMlAPxIxiY7WYmfL5KcGP8HrKe8krHBjctyGZnG8OUCFWM5D7VB5EXc5nDQWNMcumyyY9bBM3T)ULmaJJP4DtddrGBi3lwiVbiaufhtX7MggIa3qUxSqEtNk8a(XXumyyskdNdAy6rYauWeWkmiU3Qj0oM(KO5Iw6L4fgTSD)BtITCh0seMWaNBa5rD5(GnZ72F3Y9IfYB6uHpnfOyWWK7d2mVB)DlzaghtX7MggIa3qUxSqEdqvrkoMI3nnmebUHCVyH8MovrcFbtaRWG4ERMq7y6tIMlAPxIxOyfkQ9KnU)HuKPrblrycdCUbKh1L7d2mVB)Dl3lwiVPtf(0uGIbdtUpyZ8U93TKbyCmfVBAyicCd5EXc5nabG1XXu8UPHHiWnK7flK30Psf(cMawHbX9wnH2X0Nenx0sVeVqUYVrXDJiYjibYJ(LmS0VNYyjctyGZnG8OUCFWM5D7VB5EXc5nDQWNMcumyyY9bBM3T)ULmaJJP4DtddrGBi3lwiVbOQiloMI3nnmebUHCVyH8Mov4JVGjGvyqCVvtODm9jrZfT0lXle59SmHHVnjisjYpj1nglrycdCUbKh1L7d2mVB)Dl3lwiVPtf(0uGIbdtUpyZ8U93TKbyCmfVBAyicCd5EXc5navHFCmfVBAyicCd5EXc5nD4bRfmbScdI7TAcTJPpjAUOLEjEHyMs8KCmsQAgZTeHjmW5gqEuxUpyZ8U93TCVyH8Mov4ttbkgmm5(GnZ72F3sgGXXu8UPHHiWnK7flK3auLQ4ykE30Wqe4gY9IfYB6uHp(cMawHbX9wnH2X0Nenx0sVeVqctbIQHVnjvbsClrycdCUbKh1L7d2mVB)Dl3lwiVPtf(0uGIbdtUpyZ8U93TKbyCmfVBAyicCd5EXc5navPkoMI3nnmebUHCVyH8MUiZAbtaRWG4ERMq7y6tIMlAPxIxyhQTj5yKyBnF9Yq2ZIWEcyfge3B1eAhtFs0Crl9s8cjkL3qYXihCNedT9qwlfA(MawHbX9wnH2X0NenxStaRWG4ERMq7OmCoijgZs)eWkmiU3Qj0oQV9xBiNWseMqkgmm5(GnZ72F3sgGjGvyqCVvtODgebUPjXJMbKq8(yjctifdgMCFWM5D7VBjipQtd8umyyYgDItTVS9vcYJ6jGvyqCVvtODyO9ugohmbScdI7TAcTR8W7zldzOmMeWkmiU3Qj0oQIGKJrolkyRTeHjKIbdtUpyZ8U93TeKh1PbEkgmmzJoXP2x2(kb5rDAumyyY7BrCjdWeWkmiU3Qj0UqzmKvyqCN0G6XYEwuyeQYsVeVWIFlrycBG3yiNAj(0YO4qRjkYbPtvcyfge3B1eA3Y4KvyqCN0G6XsVeVWg5eMto1s8jbmbScdI7TS4xyO8WnKumyyw6L4fszkW3dFfTeHjKiak3lwiVfIpTMZyOqoOedT9q2ZISDAumyysm02dzplY2L7flK30OyWWK33I4Y9IfYBaseataRWG4Ell(vtODLhq3hYcB(244bBwIWesXGHjVVfXLmaPf4CdipQl3hSzE3(7wUxSqEtN1jGvyqCVLf)Qj0Ug4RLKJrsv9G4ULimHumyyY7BrCjdqABrCaQ44NawHbX9ww8RMq7Omf47HVIwI857YaCirycjcGY9IfYBH4tR5mgkKdkXqBpK9SiBNgfdgMedT9q2ZISD5EXc5nnkgmm59TiUCVyH8gGebqlrycPyWWK33I4sgG0AG3yiNAj(0YO4qRjkYbPdajGvyqCVLf)Qj0Ua3bVOBjctOcumyyY7BrCjdW4ykgmm5(GnZ72F3sgG0wg)y8L4Yg5ymgYMzjUG0uwlQOmxEl(aZCsG4Q(jGvyqCVLf)Qj0UgDItTVS9nbScdI7TS4xnH2TLiWI4jGvyqCVLf)Qj0Ug4RLKJrsv9G4ULimHumyyY7BrCjdqAbo3aYJ6Y9bBM3T)UL7flK30zDcyfge3BzXVAcTJYuGVh(kAjctifdgM8(wexUxSqEthrauXaaiTobmbScdI7TSroH5KtTeFutODBrGCcskdpQLimHlJFm(sCzuKXqYXihCNK6B)12x5fadciWdsJIbdtgfzmKCmYb3jP(2FT9vUxSqEdqIaycyfge3BzJCcZjNAj(OMq7cltJd5eKugEulrycxg)y8L4YOiJHKJro4oj13(RTVYlageqGhKgfdgMmkYyi5yKdUts9T)A7RCVyH8gGebWeWkmiU3Yg5eMto1s8rnH2fkpCdjfdgMLEjEHuMc89WxrlrycBG3yiNAj(0YO4qRjkYbfQIgrauUxSqEleFAkmL5(ifRURWE59IYCW44ax59YhPY7do6VY7fL5GcstzTOIYC5T4dmZjbIR6ttHTioD4b8JJX7aNBa5rDzG7Gx0L7flK3cMawHbX9w2iNWCYPwIpQj0Ua3bVOBjctOcumyyY7BrCjdW4ykgmm5(GnZ72F3sgG0wg)y8L4Yg5ymgYMzjUG0uwlQOmxEl(aZCsG4Q(jGvyqCVLnYjmNCQL4JAcTRrN4u7lBFTeHje8umyyYgDItTVS9vcYJ60uObEJHCQL4tlJIdTMOihKovXXBHajVY7JSabBjYPtL1cMawHbX9w2iNWCYPwIpQj0UTebwe3seMqkgmm5(GnZ72F3sgGXXkqXGHjVVfXL7flK3aKiaghVfXPtrWxW4ykgmmj2Ehpk6l3lwiVbOkP1jGvyqCVLnYjmNCQL4JAcTlSmnoKtqsz4rTeHjS)qsXDMwoOVaqribaWqCCaxTeVfcG4yfOyWWK7d2mVB)DlzastzTOIYC5T4dmZjbIR6tBkZ9rkwDxH9Y7fL5GcMawHbX9w2iNWCYPwIpQj0Ua3bVONawHbX9w2iNWCYPwIpQj0UYdO7dzHnFBC8GnlrycPyWWK33I4sgG0cCUbKh1L7d2mVB)Dl3lwiVPZAAkqX7MggIa3qUxSqEthEW64ykgmm5(GnZ72F3sgGXXu8UPHHiWnK7flK3aea4liTTqGKx59rwGGTe50f5wNawHbX9w2iNWCYPwIpQj0UBXhyMNawHbX9w2iNWCYPwIpQj0Ug4RLKJrsv9G4ULimHlJFm(sC5n0VrLtkIiWn0OyWWK33I4sgG0cCUbKh1L7d2mVB)Dl3lwiVPZAAkqXGHj3hSzE3(7wYamoMI3nnmebUHCVyH8gGaa)4yWtXGHjB0jo1(Y2xjdW4y8EkZ9r2OtCQ9LTV0O4DtddrGBi3lwiVPlYuebPTfcK8kVpYceSLiNoRTobScdI7TSroH5KtTeFutODuMc89WxrlrycPyWWK33I4sgG0uaVPyWWK7d2mVB)Dl3lwiVJJ3I4a0A8fKMcnWBmKtTeFAzuCO1ef5GcvrBlei5vEFKfiylroDkU1XXnWBmKtTeFAzuCO1ef5GcbGGjGvyqCVLnYjmNCQL4JAcTRb(Aj5yKuvpiUBjctifdgM8(wexYaKwGZnG8OUCFWM5D7VB5EXc5nDwttbkgmm5(GnZ72F3sgGXXu8UPHHiWnK7flK3aea4hhdEkgmmzJoXP2x2(kzaghJ3tzUpYgDItTVS9LgfVBAyicCd5EXc5nDrMIiiTTqGKx59rwGGTe50zT1jGvyqCVLnYjmNCQL4JAcTJYW5Gdo02JLimHumyyY7BrCjipQhhh4oidAKkrbeNPjdCFUiWrULBJoRPn1s8rI7LzWjbggagjRtaRWG4ElBKtyo5ulXh1eAhLHZbPQbNLimHumyyY7BrCjipQhhh4oidAKkrbeNPjdCFUiWrULBJoRPn1s8rI7LzWjbggagjRPH3tzUpYWYCZqF59IYCWeWkmiU3Yg5eMto1s8rnH2ffhAnrroOLimHumyysXVbK5DtsX9tSih8RKbiTg4ngYPwIpTmko0AIICq6uLawHbX9w2iNWCYPwIpQj0UTiqobjLHh1seMW(djf3zA5G(cafHeaadXXbC1s8wiaIJvGIbdtUpyZ8U93TKbinL1IkkZL3IpWmNeiUQpTPm3hPy1Df2lVxuMdkycyfge3BzJCcZjNAj(OMq7a3IG7KlVwlrycPyWWK33I4sgG0uObEJHCQL4tlJIdTMOihKovXXBHajVY7JSabBjYPtL1cMawHbX9w2iNWCYPwIpQj0oU3MIHa3yjctifdgM8(wexYambScdI7TSroH5KtTeFutODugohCWH2EsaRWG4ElBKtyo5ulXh1eAhLHZbPQbxcyfge3BzJCcZjNAj(OMq72Ia5eKugE0eWkmiU3Yg5eMto1s8rnH2fwMghYjiPm8OjGvyqCVLnYjmNCQL4JAcTlko0AIICqnBd8bTvroa0JE0Aa]] )


end
