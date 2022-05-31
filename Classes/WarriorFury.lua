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


    spec:RegisterPack( "Fury", 20220530, [[d4KBEbqiOk1JeISju4tukgfH4ueOvrivWRiPAwuIUfufTlI(fLsddQQJrswMsfpJKIPra6Aus2Mqu9nHOmocPCouuyDeaZtPs3JG2hkYbjKKfkeEikknrOkPUiHKAJesf9rOkbgjHuPtIIIALkvntcjUjuLO2jLu)KqQqdfQsKLsiv9uuAQucxfQsqBfQsYxrrrgluf2lf)fHbd5WswmIESGjRKlRAZq5Ziz0qLtdA1qvc1RPunBsDBsSBQ(nQgUs54eqlh45kMUuxhP2oH67cPXtsPZJIQ1dvjK5lu7x0gvglmSRQVX6DWFNDW3k1GVuLaALaIpZWW2mF7g2TkyVOUH1lLByfDsdyUHDRyUMxlJfg2Htdc3WIR7TraS1wkyJJMug4k2oqfAD1qUhafwB7avc2AyjPH6Mz2nKg2v13y9o4VZo4BLAWxQsaTsaXxng2IUXXbgwwOcZMiBtKOceWbvAiGpgwCW16UH0WU(emSIoPbmprmtfaa5GCpE5I5jsn4BzI2b)D2j3N7zwCLt9raY94zIevR1xjcVeTIY1YCpEMi8A4uK6VsKcx8vU3jY2ej6EahgsKO8AlrHsRtKioVtK)V(kryCqIGoEsvkprbU3xTTGYCpEMi8YCXFLOi016tZbkjQ8vIWRbff3tKONxGevKCXprrO58vJdcMornprqLnax8teg4cK(EG5jIJLiWdCfL7RQHCFsKiduzseGttHtZ8eDbsxAbL5E8mrIQ16Refr1T(jIfhNUtuZt0g4bUcz1jsuHxsuK5E8mrIQ16ReHx48eXm3xzK5E8mrwe9L9eHXbjIzcheOJc9vIipgh8ePV4RtKAImzUhptKO)kCXFLir9m3dFK5E8mr41C3Mor0Ztel8uNe8Y(bjcILiyBZKOsdETyEIO3sKi41VACkL9deuM7XZeX(MElryL9NO5cK(E4tIW4GeXcP83jIVD)aPHvdNEmwyyl(nwySwLXcd79Iu)LjcdBaa7dGLHLkSKGRuqFsKWeHFIyKOHtRjH(sIbbttmnaA)Y7fP(ReXirK0yysmiyAIPbq7xcUsb9jrmsejngM8oOOUeCLc6tI2nruHLHTcnK7g2q5HRjiPXWmSK0yyeEPCdlPUwFAoqX0gR3XyHH9ErQ)YeHHnaG9bWYWssJHjVdkQlP3seJef4C9Ih1LGhSR)m(NrcUsb9jrmLiRmSvOHC3WwEaEVjkS(Gbhpy30gRvJXcd79Iu)LjcdBaa7dGLHLKgdtEhuuxsVLigjcuupr7MibeFdBfAi3nSZ2labhJGSMgYDtBSwanwyyVxK6VmryydayFaSmSK0yyY7GI6s6TeXirZ21AIUauVhzuCqGok0xjIPeTJHTcnK7gwsDT(0CGIHf69ba6TMaIzyPclj4kf0hH4Zy40AsOVKyqW0etdG2pdsAmmjgemnX0aO9lbxPG(WGKgdtEhuuxcUsb9zxQWY0gRTYyHH9ErQ)YeHHnaG9bWYWksIiPXWK3bf1L0BjkoorK0yysWd21Fg)ZiP3seJebO9JXbuxoqhJwtm0aQlVxK6VsKGjIrIexayrQV8Q9b6(eB4Q5g2k0qUBydCFDf30gRJCJfg2k0qUByh4Poj4L9dmS3ls9xMimTX6iZyHHTcnK7gwqPSvu3WEVi1FzIW0gRfnJfg27fP(lteg2aa2haldljngM8oOOUKElrmsuGZ1lEuxcEWU(Z4Fgj4kf0NeXuISYWwHgYDd7S9cqWXiiRPHC30gRzgglmS3ls9xMimSbaSpawgwsAmm5DqrDj4kf0NeXuIOcRej6qI2rALHTcnK7gwsDT(0CGIPnTHDGoL(eDbOEBSWyTkJfg27fP(lteg2aa2haldlG2pghqDzuOwtWXiACNG8G5a7hiVaPHBBFLigjIKgdtgfQ1eCmIg3jipyoW(bsWvkOpjA3erfwg2k0qUBybff0Pii18OM2y9oglmS3ls9xMimSbaSpawgwaTFmoG6YOqTMGJr04ob5bZb2pqEbsd32(krmsejngMmkuRj4yenUtqEWCG9dKGRuqFs0UjIkSmSvOHC3Wga0doOtrqQ5rnTXA1ySWWEVi1FzIWWgaW(ayzyNTR1eDbOEpYO4GaDuOVsKWePkrmsevyjbxPG(KiHjc)eXirIKOU03BPsntfaxEVi1FLO44ef4IVxElfFVXXCqIemrmsK4cals9LxTpq3NydxnprmsKijcuuprmLiMb(jkoor4DIcCUEXJ6Ya3xxXLGRuqFsKGg2k0qUBydLhUMGKgdZWssJHr4LYnSK6A9P5aftBSwanwyyVxK6VmryydayFaSmSIKisAmm5DqrDj9wIIJtejngMe8GD9NX)ms6TeXiraA)yCa1Ld0XO1ednG6Y7fP(RejyIyKiXfawK6lVAFGUpXgUAUHTcnK7g2a3xxXnTXARmwyyVxK6VmryydayFaSmSRtsJHjh4Poj4L9dKlEuprmsKijA2Uwt0fG69iJIdc0rH(krmLivjkoorGcUiU47TSwRrc9eXuIuzvIe0WwHgYDd7ap1jbVSFGPnwh5glmS3ls9xMimSbaSpawgwsAmmj4b76pJ)zK0BjkoorIKisAmm5DqrDj4kf0NeTBIOcRefhNiqr9eXuIen8tKGjkoorK0yysmWD8IyUeCLc6tI2nrQKwzyRqd5UHfukBf1nTX6iZyHH9ErQ)YeHHnaG9bWYWoVji5o9iB4b7iAe7SfsuCCIc4ka1Nejmr7KO44ejsIiPXWKGhSR)m(NrsVLigjsCbGfP(YR2hO7tSHRMNigjQl99wQuZubWL3ls9xjsqdBfAi3nSba9Gd6ueKAEutBSw0mwyyRqd5UHnW91vCd79Iu)LjctBSMzySWWEVi1FzIWWgaW(ayzyjPXWK3bf1L0BjIrIcCUEXJ6sWd21Fg)ZibxPG(KiMsKvjIrIejrK8zseJeHbPW1eGRuqFsetjIzyvIIJtejngMe8GD9NX)ms6TefhNis(mjIrIWGu4AcWvkOpjA3eTd(jsWeXirGcUiU47TSwRrc9eXuIImRmSvOHC3WwEaEVjkS(Gbhpy30gRvHVXcdBfAi3nSxTpq33WEVi1FzIW0gRvPYyHH9ErQ)YeHHnaG9bWYWcO9JXbuxEnZhy5ekqkCT8ErQ)krmsejngM8oOOUKElrmsuGZ1lEuxcEWU(Z4Fgj4kf0NeXuISkrmsKijIKgdtcEWU(Z4Fgj9wIIJtejFMeXiryqkCnb4kf0NeTBI2b)efhNO1jPXWKd8uNe8Y(bs6TefhNi8orDPV3YbEQtcEz)a59Iu)vIyKis(mjIrIWGu4AcWvkOpjIPef5IwIemrmseOGlIl(ElR1AKqprmLiRSYWwHgYDd7S9cqWXiiRPHC30gRvTJXcd79Iu)LjcdBaa7dGLHLKgdtEhuuxsVLigjsKeH3jIKgdtcEWU(Z4Fgj4kf0NefhNiqr9eTBISc)ejyIyKirs0SDTMOla17rgfheOJc9vIeMivjIrIafCrCX3BzTwJe6jIPejGwLO44enBxRj6cq9EKrXbb6OqFLiHjANejOHTcnK7gwsDT(0CGIPnwRsnglmS3ls9xMimSbaSpawgwsAmm5DqrDj9wIyKOaNRx8OUe8GD9NX)msWvkOpjIPezvIyKirsejngMe8GD9NX)ms6TefhNis(mjIrIWGu4AcWvkOpjA3eTd(jkoorRtsJHjh4Poj4L9dK0Bjkoor4DI6sFVLd8uNe8Y(bY7fP(ReXirK8zseJeHbPW1eGRuqFsetjkYfTejyIyKiqbxex89wwR1iHEIykrwzLHTcnK7g2z7fGGJrqwtd5UPnwRsanwyyVxK6VmryydayFaSmSK0yyY7GI6YfpQNO44ef4(Ig2sXWaKtpebU3xzRLGYTNiMsKvjIrI6cq9wI7LUXj3cDI2nrQXkdBfAi3nSKAoF14GGPnTXAvwzSWWEVi1FzIWWgaW(ayzyjPXWK3bf1LlEuprXXjkW9fnSLIHbiNEicCVVYwlbLBprmLiRseJe1fG6Te3lDJtUf6eTBIuJvjIrIW7e1L(Elda6RBMlVxK6VmSvOHC3WsQ58fz14mTXAvrUXcd79Iu)LjcdBaa7dGLHLKgdtQCqaQ)meKC)uaOVoqsVLigjA2Uwt0fG69iJIdc0rH(krmLivg2k0qUByJIdc0rH(Y0gRvfzglmS3ls9xMimSbaSpawg25nbj3PhzdpyhrJyNTqIIJtuaxbO(KiHjANefhNirsejngMe8GD9NX)ms6TeXirIlaSi1xE1(aDFInC18eXirDPV3sLAMkaU8ErQ)krcAyRqd5UHfuuqNIGuZJAAJ1QenJfg27fP(lteg2aa2haldljngM8oOOUKElrmsKijA2Uwt0fG69iJIdc0rH(krmLivjkoorGcUiU47TSwRrc9eXuIuzvIe0WwHgYDd7cuuCNaWlGPnwRIzySWWEVi1FzIWWgaW(ayzyjPXWK3bf1L0Bg2k0qUBy5(OlAkCTPnwVd(glmSvOHC3WsQ58vJdcM2WEVi1FzIW0gR3rLXcdBfAi3nSKAoFrwnod79Iu)LjctBSENDmwyyRqd5UHfuuqNIGuZJAyVxK6VmryAJ17OgJfg2k0qUByda6bh0Pii18Og27fP(lteM2y9ocOXcdBfAi3nSrXbb6OqFzyVxK6VmryAtByxhRO1TXcJ1QmwyyVxK6VmryyRqd5UHnGRau3WU(eaWTgYDdlZIRauprqSef92aEI0CNkrB10jItdseF7(bwMioirrFIwC3Mor()krnUNi(29dsuGRqYteghKiwiL)orI4ChpXRU34yoqqPHnaG9bWYW2qLNiMsKOLO44e1L(ElxCAs9jAOYL3ls9xjkoorvOHIpX9Ra)KiMsKQefhNOax89YBP47noMdsuCCIW7ebO9JXbuxoqk)nbhJO5aL79xe2Ho1iVaPHBBFLO44ef4C9Ih1LGhSR)m(NrcUsb9jrmLiQWY0gR3XyHHTcnK7g2nAfLRnS3ls9xMimTXA1ySWWEVi1FzIWWY3mSZBdBfAi3nSIlaSi13WkU003W2L(ElvQzQa4Y7fP(ReXirDbOElX9s34KBHor7Mi1yvIIJtuxaQ3sCV0no5wOt0UjAh8tuCCI6cq9wI7LUXj3cDIykrIg(jIrIcCX3lVLIV34yoWWkUaeEPCd7v7d09j2WvZnTXAb0yHH9ErQ)YeHHLVzyN3g2k0qUByfxayrQVHvCPPVHfq7hJdOUCGu(BcogrZbk37ViSdDQrEVi1FLO44ebO9JXbuxoqhJwtm0aQlVxK6VsuCCIa0(X4aQlVM5dSCcfifUwEVi1FzyfxacVuUHL2HcK(e6tDFva4htBS2kJfg27fP(lteg2k0qUByj1C(QXbbtBy1q)eHLHvf(g2aa2haldBdvEI2nrIwIyKOk0qXN4(vGFsKWePkrmseG2pghqD5aP83eCmIMduU3Fryh6uJ8cKgUT9vIyKirseENOax89YBP47noMdsuCCIcCUEXJ6sWd21Fg)ZibxPG(KODfMiQWkrcAyxFca4wd5UHvuRqRR(tIGoSHLorrO58vJdcMorZfi99WteghKOb6u6JNDbOENi1telKYFlnTX6i3yHH9ErQ)YeHHTcnK7gwWd21Fg)Zyy1q)eHLHvf(g2aa2haldBdvEI2nrIwIyKOk0qXN4(vGFsKWePkrmsuGl(E5Tu89ghZbjIrIa0(X4aQlhiL)MGJr0CGY9(lc7qNAKxG0WTTVseJeTbUyjPMZxnoiyAd76taa3Ai3nSIAfAD1Fse0HnS0js0)GD9NX)mjAUaPVhEIW4GenqNsF8Sla17ePEIWRU34yoirQNiwiL)wAAJ1rMXcd79Iu)LjcdBfAi3nS4oGdde6xBgwn0pryzyvHVHnaG9bWYWoVBOtnsChWHbIaUcq9eXirnu5jA3ezvIyKOk0qXN4(vGFsKWePkrmseENOax89YBP47noMdseJebO9JXbuxoqk)nbhJO5aL79xe2Ho1iVaPHBBFLigjAdCXssnNVACqW0jIrIcCUEXJ6YaUcqDj4kf0NeTBIWxALHD9jaGBnK7gwrTcTU6pjc6Wgw6ej6EahgsKO8AlrmLiMfxbOEIMlq67HNimoird0P0hp7cq9orQNiN74jE19ghZbjs9eXcP83stBSw0mwyyVxK6VmryyRqd5UHnGRau3WQH(jcldRk8nSbaSpawg25DdDQrI7aomqeWvaQNigjQHkpr7MiRseJevHgk(e3Vc8tIeMivjIrIW7ef4IVxElfFVXXCqIyKiaTFmoG6Ybs5Vj4yenhOCV)IWo0Pg5finCB7ReXirBGlwI7aomqOFTzyxFca4wd5UHvuRqRR(tIGoSHLorIUhWHHejkV2setjIzXvaQNO5cK(E4jcJds0aDk9XZUauVtK6jY5oEIxDVXXCqIuprSqk)T00gRzgglmSvOHC3WUXBi3nS3ls9xMimTXAv4BSWWEVi1FzIWWgaW(ayzybf1tetjkYW3WwHgYDdBG7cK(aoyiil3pW0gRvPYyHH9ErQ)YeHHnaG9bWYWssJHjVdkQlP3seJebkQNODtuKHVHTcnK7g2z7fGGJrqwtd5UPnwRAhJfg27fP(lteg2aa2haldBGZ1lEuxcEWU(Z4Fgj4kf0NeTBIutIyKOU03Bj4b76pdrrw(I7Y7fP(ldBfAi3nSGszROUPnwRsnglmS3ls9xMimSbaSpawgwsAmmj4b76pJ)zKlEuprms06K0yyYbEQtcEz)a5Ih1tuCCIWGu4AcWvkOpjA3ezf(g2k0qUBydCxG0hWbdbz5(bM2yTkb0yHH9ErQ)YeHHnaG9bWYWcO9JXbuxoqhJwtm0aQlVxK6VseJerfwsWvkOpjsyIWprmsKijsCbGfP(YR2hO7tSHRMNO44ejsI6cq9w2qLt0CITqtOgRsetjsaXprmsux67TSCQdiukVOUY9wEVi1FLO44e1fG6TSHkNO5eBHMqnwLiMsuKHFIyKi8orDPV3YYPoGqP8I6k3B59Iu)vIemrcMigjsKenBxRj6cq9EKrXbb6OqFLiHjsvIIJtejngMu5vte0VeFGKElrcAyRqd5UHf8GD9NX)mM2yTkRmwyyVxK6VmryydayFaSmSaA)yCa1LxZ8bwoHcKcxlVxK6VseJerfwsWvkOpjsyIWprmsKijkW56fpQlNTxacogbznnK7sWvkOpjA3ezvIIJtuGZ1lEuxoBVaeCmcYAAi3LGRuqFsetjAh8tKGjIrIejrIKisAmmjPMZxA6PL0BjkoorDPV3YYPoGqP8I6k3B59Iu)vIIJteOGlIl(ElR1AKqprmLiv4NibtuCCIi5ZKigjcdsHRjaxPG(KiMsKk8XprXXjsCbGfP(YR2hO7tSHRMNO44erYNjrmsegKcxtaUsb9jr7MivwLigjcuWfXfFVL1AnsONiMsKk8tKGjIrIejrZ21AIUauVhzuCqGok0xjsyIuLO44ersJHjvE1eb9lXhiP3sKGg2k0qUBybpyx)z8pJPnwRkYnwyyVxK6VmryydayFaSmS4DIexayrQVK2HcK(e6tDFva4NeXiruHLeCLc6tIeMi8teJejsIejrK0yyssnNV00tlP3suCCI6sFVLLtDaHs5f1vU3Y7fP(RefhNiqbxex89wwR1iHEIykrQWprcMO44erYNjrmsegKcxtaUsb9jrmLiv4JFIIJtK4cals9LxTpq3NydxnprXXjIKptIyKimifUMaCLc6tI2nrQSkrmseOGlIl(ElR1AKqprmLiv4NibteJejsIMTR1eDbOEpYO4GaDuOVsKWePkrXXjIKgdtQ8Qjc6xIpqsVLibteJejsIW7ef4IVxEl9haCnhSsuCCIcCUEXJ6Ya3fi9bCWqqwUFGeCLc6tIykr7GFIe0WwHgYDdl4b76pJ)zmTXAvrMXcd79Iu)LjcdBaa7dGLHfq7hJdOUCGu(BcogrZbk37ViSdDQrEbsd32(krms0g4IjOclPkjOu2kQNigjsKejsIiPXWKKAoFPPNwsVLO44e1L(EllN6acLYlQRCVL3ls9xjkoorGcUiU47TSwRrc9eXuIuHFIemrXXjIKptIyKimifUMaCLc6tIykrQWh)efhNiXfawK6lVAFGUpXgUAEIIJtejFMeXiryqkCnb4kf0NeTBIuzvIyKiqbxex89wwR1iHEIykrQWprcMigjsKenBxRj6cq9EKrXbb6OqFLiHjsvIIJtejngMu5vte0VeFGKElrcAyRqd5UHf8GD9NX)mgw65eCmmcQWYyTktBSwLOzSWWEVi1FzIWWgaW(ayzy1x81jIPePMiprmsKijA2Uwt0fG69iJIdc0rH(krmLivjIrIW7ersJHjvE1eb9lXhiP3suCCIafCrCX3BzTwJe6jA3erfwjIrIW7ersJHjvE1eb9lXhiP3sKGg2k0qUByJIdc0rH(Y0gRvXmmwyyVxK6VmryyRqd5UHf6taq3fP(ecKU8MwHyDXWWnSbaSpawg2aNRx8OUe8GD9NX)msWvkOpjIPePc)eXirIKisAmmj4b76pJ)zK0BjkoorK8zseJeHbPW1eGRuqFs0UjAhvjkoorK8zseJeHbPW1eGRuqFsetjsfZa)efhNisAmmjPMZxA6PL0BjsqdRxk3Wc9jaO7IuFcbsxEtRqSUyy4M2y9o4BSWWEVi1FzIWWwHgYDdB0Y(9dgcma3xg2aa2haldBGZ1lEuxcEWU(Z4Fgj4kf0NeXuIuHFIyKirsejngMe8GD9NX)ms6TefhNis(mjIrIWGu4AcWvkOpjA3ePsnjkoorK8zseJeHbPW1eGRuqFsetjsLAWprcAy9s5g2OL97hmeyaUVmTX6DuzSWWEVi1FzIWWwHgYDdRsfksWjgC)nHc9adg2aa2haldBGZ1lEuxcEWU(Z4Fgj4kf0NeXuIuHFIyKirsejngMe8GD9NX)ms6TefhNis(mjIrIWGu4AcWvkOpjA3eTJvjkoorK8zseJeHbPW1eGRuqFsetjsLk8tKGgwVuUHvPcfj4edU)MqHEGbtBSENDmwyyVxK6VmryyRqd5UHLl(GO4Uwb6ueB8OhqeamF6sBydayFaSmSboxV4rDj4b76pJ)zKGRuqFsetjsf(jIrIejrK0yysWd21Fg)ZiP3suCCIi5ZKigjcdsHRjaxPG(KODtKQiprXXjIKptIyKimifUMaCLc6tIykrQWh)ejOH1lLBy5IpikURvGofXgp6bebaZNU0M2y9oQXyHH9ErQ)YeHHTcnK7gwOpnGo0CWqSGIH(jiVwBydayFaSmSboxV4rDj4b76pJ)zKGRuqFsetjsf(jIrIejrK0yysWd21Fg)ZiP3suCCIi5ZKigjcdsHRjaxPG(KODtKk8tuCCIi5ZKigjcdsHRjaxPG(KiMseZWQejOH1lLByH(0a6qZbdXckg6NG8ATPnwVJaASWWEVi1FzIWWwHgYDdlMUuobhJGS6wFdBaa7dGLHnW56fpQlbpyx)z8pJeCLc6tIykrQWprmsKijIKgdtcEWU(Z4Fgj9wIIJtejFMeXiryqkCnb4kf0NeTBIuPkrXXjIKptIyKimifUMaCLc6tIykrQWh)ejOH1lLByX0LYj4yeKv36BAJ17yLXcd79Iu)LjcdBfAi3nSu6AbRMdgcYArDdBaa7dGLHnW56fpQlbpyx)z8pJeCLc6tIykrQWprmsKijIKgdtcEWU(Z4Fgj9wIIJtejFMeXiryqkCnb4kf0NeTBIuPkrXXjIKptIyKimifUMaCLc6tIykrrUvjsqdRxk3WsPRfSAoyiiRf1nTX6DICJfg27fP(ltegwVuUHDcfyi4yeyGQpWlnX0ai2nSvOHC3WoHcmeCmcmq1h4LMyAae7M2y9orMXcd79Iu)LjcdRxk3WsvIVMGJr04obgemnrbiH9bg2k0qUByPkXxtWXiACNadcMMOaKW(atBSEhrZyHHTcnK7gw65eW(kJH9ErQ)YeHPnwVdZWyHHTcnK7gwsnNViWObm3WEVi1FzIW0gRvd(glmS3ls9xMimSbaSpawgwsAmmj4b76pJ)zK0Bg2k0qUByjpyoWo0PmTXA1OYyHH9ErQ)YeHHnaG9bWYWssJHjbpyx)z8pJCXJ6jIrIwNKgdtoWtDsWl7hix8OUHTcnK7gwnKcxpe4ftVOuU3M2yTA2XyHHTcnK7gwmi4KAoFzyVxK6VmryAJ1QrnglmSvOHC3WwE4tdknrO0Ad79Iu)LjctBSwncOXcd79Iu)LjcdBaa7dGLHLKgdtcEWU(Z4Fg5Ih1teJeTojngMCGN6KGx2pqU4r9eXirK0yyY7GI6s6ndBfAi3nSKffbhJObWG9X0gRvJvglmS3ls9xMimSbaSpawg2z7AnrxaQ3Jmkoiqhf6ReXuIuzyNgadTXAvg2k0qUBydLwtuHgYDcnCAdRgonHxk3Ww8BAJ1QjYnwyyVxK6VmryyRqd5UHnuAnrfAi3j0WPnSA40eEPCd7aDk9j6cq920gRvtKzSWWEVi1FzIWWgaW(ayzyhoTMe6l5g9006tCa9wd5U8ErQ)krXXjA40AsOVKI56QH6tmCT47T8ErQ)krmseENisAmmPyUUAO(edxl(EtGJwPCoCjP3mSqVpaqV1eqmd7WP1KqFjfZ1vd1Ny4AX3Bdl07da0Bnbur5ly13WQYWwHgYDdlM(dUaOWAdl07da0BnbLMtwAdRktBAd7g4bUcz1glmwRYyHHTcnK7gwYQB9jgCC62WEVi1FzIW0gR3XyHHTcnK7gwm9hCbqH1g27fP(lteM2yTAmwyyVxK6VmryydayFaSmS4DIa0(X4aQlhiL)MGJr0CGY9(lc7qNAKxG0WTTVmSvOHC3WcEWU(Z4FgtBSwanwyyRqd5UHnWDbsFahmeKL7hyyVxK6VmryAtBAdR4dgi3nwVd(7Sd(QrfZWWgTao0PgdlZKOs0BnZS14fiajkrwG7jcQSXbDIW4GeztXVnjcCbsdbFLOHR8ev0nxP6Vsuax5uFK5Erb6prQeGeXSCx8b9xjYMHtRjH(sIh2KOMNiBgoTMe6ljEiVxK6VSjrIOsTckZ9Ic0FISsaseZYDXh0FLiBa0(X4aQlXdBsuZtKnaA)yCa1L4H8ErQ)YMejIk1kOm3N7zMevIERzMTgVabirjYcCprqLnoOteghKiBgOtPprxaQ32KiWfine8vIgUYtur3CLQ)krbCLt9rM7ffO)ePgbirml3fFq)vISjWfFV8wIhY7fP(lBsuZtKnbU47L3s8WMejIk1kOm3lkq)jsafGeXSCx8b9xjYgaTFmoG6s8WMe18ezdG2pghqDjEiVxK6VSjrIOsTckZ9Ic0FIuPsaseZYDXh0FLiB6sFVL4HnjQ5jYMU03BjEiVxK6VSjrIOsTckZ9Ic0FIuPsaseZYDXh0FLiBa0(X4aQlXdBsuZtKnaA)yCa1L4H8ErQ)YMejIk1kOm3lkq)jsLAeGeXSCx8b9xjYMU03BjEytIAEISPl99wIhY7fP(lBsKiQuRGYCFUNzsuj6TMz2A8ceGeLilW9ebv24GoryCqISzDSIw32KiWfine8vIgUYtur3CLQ)krbCLt9rM7ffO)ePgbirml3fFq)vISPl99wIh2KOMNiB6sFVL4H8ErQ)YMejIk1kOm3lkq)jsafGeXSCx8b9xjYgaTFmoG6s8WMe18ezdG2pghqDjEiVxK6VSjrIOsTckZ9Ic0FIeqbirml3fFq)vISbq7hJdOUepSjrnpr2aO9JXbuxIhY7fP(lBsu1jsul6OOKiruPwbL5Erb6prcOaKiML7IpO)kr2aO9JXbuxIh2KOMNiBa0(X4aQlXd59Iu)LnjsevQvqzUxuG(tuKlajIz5U4d6VsKnbU47L3s8qEVi1FztIAEISjWfFV8wIh2KiruPwbL5Erb6prrMaKiML7IpO)kr2e4IVxElXd59Iu)LnjQ5jYMax89YBjEytIerLAfuM7ffO)ejAcqIywUl(G(ReztGl(E5TepK3ls9x2KOMNiBcCX3lVL4HnjsevQvqzUxuG(tKkbuaseZYDXh0FLiB6sFVL4HnjQ5jYMU03BjEiVxK6VSjrISJAfuM7ffO)ePsafGeXSCx8b9xjYgaTFmoG6s8WMe18ezdG2pghqDjEiVxK6VSjrIOsTckZ9Ic0FIuzLaKiML7IpO)kr2aO9JXbuxIh2KOMNiBa0(X4aQlXd59Iu)LnjsevQvqzUxuG(tKAImbirml3fFq)vISz40AsOVK4HnjQ5jYMHtRjH(sIhY7fP(lBsKi7OwbL5(CpZSYgh0FLibmrvOHCprA40Jm3ByNThmwhz7yy3aCmO(g2ifPej6KgW8eXmvaaKdY9rksjcVCX8ePg8Tmr7G)o7K7Z9rksjIzXvo1hbi3hPiLi8mrIQ16ReHxIwr5AzUpsrkr4zIWRHtrQ)krkCXx5ENiBtKO7bCyirIYRTefkTorI48or()6ReHXbjc64jvP8ef4EF12ckZ9rksjcpteEzU4Vsue6A9P5aLev(kr41GII7js0ZlqIksU4NOi0C(QXbbtNOMNiOYgGl(jcdCbsFpW8eXXse4bUIY9v1qUpjsKbQmjcWPPWPzEIUaPlTGYCFKIuIWZejQwRVsuev36NiwCC6ornprBGh4kKvNirfEjrrM7JuKseEMir1A9vIWlCEIyM7RmYCFKIuIWZezr0x2teghKiMjCqGok0xjI8yCWtK(IVorQjYK5(ifPeHNjs0FfU4VsKOEM7HpYCFKIuIWZeHxZDB6erpprSWtDsWl7hKiiwIGTntIkn41I5jIElrIGx)QXPu2pqqzUpsrkr4zIyFtVLiSY(t0CbsFp8jryCqIyHu(7eX3UFGm3N7JuKsKOwTpq3FLiYJXbprbUcz1jI8uqFKjsufcFRNe5ChpXvafmADIQqd5(KiURzUm3xHgY9rUbEGRqwT6cTLS6wFIbhNUZ9vOHCFKBGh4kKvRUqBX0FWfafwN7Rqd5(i3apWviRwDH2cEWU(Z4FglHycXBaTFmoG6Ybs5Vj4yenhOCV)IWo0Pg5finCB7RCFfAi3h5g4bUcz1Ql02a3fi9bCWqqwUFqUp3hPiLirTAFGU)krx8bmprnu5jQX9evHMdseCsujUG6IuFzUpsjIzXvaQNiiwIIEBaprAUtLOTA6eXPbjIVD)altehKOOprlUBtNi)FLOg3teF7(bjkWvi5jcJdselKYFNirCUJN4v3BCmhiOm3xHgY9ryaxbOULqmHnu5mjAXXDPV3YfNMuFIgQC59Iu)vCCfAO4tC)kWpmPkooWfFV8wk(EJJ5G4y8gq7hJdOUCGu(BcogrZbk37ViSdDQrEbsd32(kooW56fpQlbpyx)z8pJeCLc6dtuHvUVcnK7J6cTDJwr56CFfAi3h1fAR4cals9T0lLl8Q9b6(eB4Q5wkU00xyx67TuPMPcGZOla1BjUx6gNCl07QgRIJ7cq9wI7LUXj3c9U7GFCCxaQ3sCV0no5wOzs0WNrGl(E5Tu89ghZb5(k0qUpQl0wXfawK6BPxkxiTdfi9j0N6(QaWpwkU00xiG2pghqD5aP83eCmIMduU3Fryh6utCmG2pghqD5aDmAnXqdOECmG2pghqD51mFGLtOaPW15(ifPezbo4Ki4Kif(0AMNOMNOnWfFVtuGZ1lEuFsegGRKiYdDQevHaCDVlTM5jIE(krlAa0PsKcx8vU3YCFKIuIQqd5(OUqBb0orfAi3j0WPT0lLluHl(k3BlHycv4IVY9wUGtxE4mzvUpsrkrvOHCFuxOT4oGdde6xBwcXekcOGlIl(Elv4IVY9wUGtxE4mTJvmafCrCX3BPcx8vU3sOZKaALG5(ifPevHgY9rDH2oxG03d3siMWk0qXN4(vGFeQIrGl(E5Tu89ghZbY7fP(lgaA)yCa1LdKYFtWXiAoq5E)fHDOtnYlqA422xw6LYfgHfme9pyxai1C(QXbbtlaGhSR)m(Nj3hPejQvO1v)jrqh2WsNOi0C(QXbbtNO5cK(E4jcJds0aDk9XZUauVtK6jIfs5VL5(k0qUpQl0wsnNVACqW0wQH(jclHQW3siMWgQ8DfngvOHIpX9Ra)iufdaTFmoG6Ybs5Vj4yenhOCV)IWo0Pg5finCB7lgIG3bU47L3sX3BCmhehh4C9Ih1LGhSR)m(NrcUsb9zxHuHLG5(iLirTcTU6pjc6Wgw6ej6FWU(Z4FMenxG03dpryCqIgOtPpE2fG6DIupr4v3BCmhKi1telKYFlZ9vOHCFuxOTGhSR)m(NXsn0pryjuf(wcXe2qLVROXOcnu8jUFf4hHQye4IVxElfFVXXCG8ErQ)IbG2pghqD5aP83eCmIMduU3Fryh6uJ8cKgUT9fJnWflj1C(QXbbtN7JuKsufAi3h1fA7CbsFpClHycRqdfFI7xb(rOkg4DGl(E5Tu89ghZbY7fP(lgaA)yCa1LdKYFtWXiAoq5E)fHDOtnYlqA422xw6LYfgHfmywCfG6caPMZxnoiyAba3bCyGiGRaup3hPejQvO1v)jrqh2WsNir3d4WqIeLxBjIPeXS4ka1t0CbsFp8eHXbjAGoL(4zxaQ3js9e5ChpXRU34yoirQNiwiL)wM7Rqd5(OUqBXDahgi0V2Sud9tewcvHVLqmHZ7g6uJe3bCyGiGRauNrdv(UwXOcnu8jUFf4hHQyG3bU47L3sX3BCmhiVxK6VyaO9JXbuxoqk)nbhJO5aL79xe2Ho1iVaPHBBFXydCXssnNVACqW0mcCUEXJ6YaUcqDj4kf0NDXxAvUpsjsuRqRR(tIGoSHLorIUhWHHejkV2setjIzXvaQNO5cK(E4jcJds0aDk9XZUauVtK6jY5oEIxDVXXCqIuprSqk)Tm3xHgY9rDH2gWvaQBPg6NiSeQcFlHycN3n0PgjUd4WaraxbOoJgQ8DTIrfAO4tC)kWpcvXaVdCX3lVLIV34yoqEVi1FXaq7hJdOUCGu(BcogrZbk37ViSdDQrEbsd32(IXg4IL4oGdde6xB5(k0qUpQl02nEd5EUVcnK7J6cTnWDbsFahmeKL7hyjetiOOotrg(5(k0qUpQl02z7fGGJrqwtd5ULqmHK0yyY7GI6s6ngGI67gz4N7Rqd5(OUqBbLYwrDlHycdCUEXJ6sWd21Fg)ZibxPG(SRAy0L(Elbpyx)zikYYxCxEVi1FL7Rqd5(OUqBdCxG0hWbdbz5(bwcXessJHjbpyx)z8pJCXJ6mwNKgdtoWtDsWl7hix8OECmgKcxtaUsb9zxRWp3xHgY9rDH2cEWU(Z4FglHycb0(X4aQlhOJrRjgAa1zqfwsWvkOpcXNHiIlaSi1xE1(aDFInC184yr6cq9w2qLt0CITqtOgRysaXNrx67TSCQdiukVOUY9ooUla1BzdvorZj2cnHASIPidFg4Dx67TSCQdiukVOUY9wqbziYSDTMOla17rgfheOJc9LqvXXK0yysLxnrq)s8bs6nbZ9vOHCFuxOTGhSR)m(NXsiMqaTFmoG6YRz(alNqbsHRzqfwsWvkOpcXNHiboxV4rD5S9cqWXiiRPHCxcUsb9zxRIJdCUEXJ6Yz7fGGJrqwtd5UeCLc6dt7GVGmeresAmmjPMZxA6PL0BXXDPV3YYPoGqP8I6k3B59Iu)vCmOGlIl(ElR1AKqNjv4lyCmjFggyqkCnb4kf0hMuHp(XXIlaSi1xE1(aDFInC184ys(mmWGu4AcWvkOp7QYkgGcUiU47TSwRrcDMuHVGmez2Uwt0fG69iJIdc0rH(sOQ4ysAmmPYRMiOFj(aj9MG5(k0qUpQl0wWd21Fg)ZyjetiElUaWIuFjTdfi9j0N6(QaWpmOclj4kf0hH4ZqeriPXWKKAoFPPNwsVfh3L(EllN6acLYlQRCVL3ls9xXXGcUiU47TSwRrcDMuHVGXXK8zyGbPW1eGRuqFysf(4hhlUaWIuF5v7d09j2WvZJJj5ZWadsHRjaxPG(SRkRyak4I4IV3YATgj0zsf(cYqKz7AnrxaQ3Jmkoiqhf6lHQIJjPXWKkVAIG(L4dK0BcYqe8oWfFV8w6pa4Aoyfhh4C9Ih1LbUlq6d4GHGSC)aj4kf0hM2bFbZ9vOHCFuxOTGhSR)m(NXs65eCmmcQWsOklHycb0(X4aQlhiL)MGJr0CGY9(lc7qNAKxG0WTTVySbUycQWsQsckLTI6meresAmmjPMZxA6PL0BXXDPV3YYPoGqP8I6k3B59Iu)vCmOGlIl(ElR1AKqNjv4lyCmjFggyqkCnb4kf0hMuHp(XXIlaSi1xE1(aDFInC184ys(mmWGu4AcWvkOp7QYkgGcUiU47TSwRrcDMuHVGmez2Uwt0fG69iJIdc0rH(sOQ4ysAmmPYRMiOFj(aj9MG5(k0qUpQl02O4GaDuOVSeIjuFXxZKAICgImBxRj6cq9EKrXbb6OqFXKkg4njngMu5vte0VeFGKEloguWfXfFVL1AnsOVlvyXaVjPXWKkVAIG(L4dK0BcM7Rqd5(OUqBPNta7RyPxkxi0NaGUls9jeiD5nTcX6IHHBjetyGZ1lEuxcEWU(Z4Fgj4kf0hMuHpdriPXWKGhSR)m(NrsVfhtYNHbgKcxtaUsb9z3DufhtYNHbgKcxtaUsb9Hjvmd8JJjPXWKKAoFPPNwsVjyUVcnK7J6cTLEobSVILEPCHrl73pyiWaCFzjetyGZ1lEuxcEWU(Z4Fgj4kf0hMuHpdriPXWKGhSR)m(NrsVfhtYNHbgKcxtaUsb9zxvQjoMKpddmifUMaCLc6dtQud(cM7Rqd5(OUqBPNta7RyPxkxOsfksWjgC)nHc9adwcXeg4C9Ih1LGhSR)m(NrcUsb9Hjv4ZqesAmmj4b76pJ)zK0BXXK8zyGbPW1eGRuqF2DhRIJj5ZWadsHRjaxPG(WKkv4lyUVcnK7J6cTLEobSVILEPCHCXhef31kqNIyJh9aIaG5txAlHycdCUEXJ6sWd21Fg)ZibxPG(WKk8zicjngMe8GD9NX)ms6T4ys(mmWGu4AcWvkOp7QkYJJj5ZWadsHRjaxPG(WKk8XxWCFfAi3h1fAl9CcyFfl9s5cH(0a6qZbdXckg6NG8ATLqmHboxV4rDj4b76pJ)zKGRuqFysf(meHKgdtcEWU(Z4Fgj9wCmjFggyqkCnb4kf0NDvHFCmjFggyqkCnb4kf0hMygwjyUVcnK7J6cTLEobSVILEPCHy6s5eCmcYQB9TeIjmW56fpQlbpyx)z8pJeCLc6dtQWNHiK0yysWd21Fg)ZiP3IJj5ZWadsHRjaxPG(SRkvXXK8zyGbPW1eGRuqFysf(4lyUVcnK7J6cTLEobSVILEPCHu6AbRMdgcYArDlHycdCUEXJ6sWd21Fg)ZibxPG(WKk8zicjngMe8GD9NX)ms6T4ys(mmWGu4AcWvkOp7QsvCmjFggyqkCnb4kf0hMICRem3xHgY9rDH2spNa2xXsVuUWjuGHGJrGbQ(aV0etdGyp3xHgY9rDH2spNa2xXsVuUqQs81eCmIg3jWGGPjkajSpi3xHgY9rDH2spNa2xzY9vOHCFuxOTKAoFrGrdyEUVcnK7J6cTL8G5a7qNYsiMqsAmmj4b76pJ)zK0B5(k0qUpQl0wnKcxpe4ftVOuU3wcXessJHjbpyx)z8pJCXJ6mwNKgdtoWtDsWl7hix8OEUVcnK7J6cTfdcoPMZx5(k0qUpQl02YdFAqPjcLwN7Rqd5(OUqBjlkcogrdGb7JLqmHK0yysWd21Fg)Zix8OoJ1jPXWKd8uNe8Y(bYfpQZGKgdtEhuuxsVL7Rqd5(OUqBdLwtuHgYDcnCAlNgadTqvw6LYfw8Bjet4SDTMOla17rgfheOJc9ftQY9vOHCFuxOTHsRjQqd5oHgoTLEPCHd0P0NOla17CFfAi3h1fAlM(dUaOWAlHychoTMe6l5g9006tCa9wd5EC8WP1KqFjfZ1vd1Ny4AX3Bg4njngMumxxnuFIHRfFVjWrRuohUK0Bwc9(aa9wtavu(cw9fQYsO3haO3AcknNS0cvzj07da0Bnbet4WP1KqFjfZ1vd1Ny4AX37CFUVcnK7JS4xyO8W1eK0yyw6LYfsQR1NMduSeIjKkSKGRuqFeIpJHtRjH(sIbbttmnaA)miPXWKyqW0etdG2VeCLc6ddsAmm5DqrDj4kf0NDPcRCFfAi3hzXV6cTT8a8Etuy9bdoEWULqmHK0yyY7GI6s6ngboxV4rDj4b76pJ)zKGRuqFyYQCFfAi3hzXV6cTD2Ebi4yeK10qUBjetijngM8oOOUKEJbOO(Uci(5(k0qUpYIF1fAlPUwFAoqXsO3haO3AciMqQWscUsb9ri(mgoTMe6ljgemnX0aO9ZGKgdtIbbttmnaA)sWvkOpmiPXWK3bf1LGRuqF2LkSSeIjKKgdtEhuuxsVXy2Uwt0fG69iJIdc0rH(IPDY9vOHCFKf)Ql02a3xxXTeIjuesAmm5DqrDj9wCmjngMe8GD9NX)ms6ngaA)yCa1Ld0XO1ednG6cYqCbGfP(YR2hO7tSHRMN7Rqd5(il(vxOTd8uNe8Y(b5(k0qUpYIF1fAlOu2kQN7Rqd5(il(vxOTZ2labhJGSMgYDlHycjPXWK3bf1L0BmcCUEXJ6sWd21Fg)ZibxPG(WKv5(k0qUpYIF1fAlPUwFAoqXsiMqsAmm5DqrDj4kf0hMOclrh2rAvUp3xHgY9roqNsFIUauVvxOTGIc6ueKAEulHycb0(X4aQlJc1AcogrJ7eKhmhy)a5finCB7lgK0yyYOqTMGJr04ob5bZb2pqcUsb9zxQWk3xHgY9roqNsFIUauVvxOTba9Gd6ueKAEulHycb0(X4aQlJc1AcogrJ7eKhmhy)a5finCB7lgK0yyYOqTMGJr04ob5bZb2pqcUsb9zxQWk3xHgY9roqNsFIUauVvxOTHYdxtqsJHzPxkxiPUwFAoqXsiMWz7AnrxaQ3Jmkoiqhf6lHQyqfwsWvkOpcXNHiDPV3sLAMkaU8ErQ)kooWfFV8wk(EJJ5a59Iu)LGmexayrQV8Q9b6(eB4Q5mebuuNjMb(XX4DGZ1lEuxg4(6kUeCLc6JG5(k0qUpYb6u6t0fG6T6cTnW91vClHycfHKgdtEhuuxsVfhtsJHjbpyx)z8pJKEJbG2pghqD5aDmAnXqdOUGmexayrQV8Q9b6(eB4Q55(k0qUpYb6u6t0fG6T6cTDGN6KGx2pWsiMW1jPXWKd8uNe8Y(bYfpQZqKz7AnrxaQ3Jmkoiqhf6lMufhdk4I4IV3YATgj0zsLvcM7Rqd5(ihOtPprxaQ3Ql0wqPSvu3siMqsAmmj4b76pJ)zK0BXXIqsJHjVdkQlbxPG(SlvyfhdkQZKOHVGXXK0yysmWD8IyUeCLc6ZUQKwL7Rqd5(ihOtPprxaQ3Ql02aGEWbDkcsnpQLqmHZBcsUtpYgEWoIgXoBH44aUcq9r4oXXIqsJHjbpyx)z8pJKEJH4cals9LxTpq3NydxnNrx67TuPMPcGlVxK6Vem3xHgY9roqNsFIUauVvxOTbUVUIN7Rqd5(ihOtPprxaQ3Ql02YdW7nrH1hm44b7wcXessJHjVdkQlP3ye4C9Ih1LGhSR)m(NrcUsb9HjRyicjFggyqkCnb4kf0hMygwfhtsJHjbpyx)z8pJKEloMKpddmifUMaCLc6ZU7GVGmafCrCX3BzTwJe6mfzwL7Rqd5(ihOtPprxaQ3Ql02R2hO7N7Rqd5(ihOtPprxaQ3Ql02z7fGGJrqwtd5ULqmHaA)yCa1LxZ8bwoHcKcxZGKgdtEhuuxsVXiW56fpQlbpyx)z8pJeCLc6dtwXqesAmmj4b76pJ)zK0BXXK8zyGbPW1eGRuqF2Dh8JJxNKgdtoWtDsWl7hiP3IJX7U03B5ap1jbVSFads(mmWGu4AcWvkOpmf5IMGmafCrCX3BzTwJe6mzLv5(k0qUpYb6u6t0fG6T6cTLuxRpnhOyjetijngM8oOOUKEJHi4njngMe8GD9NX)msWvkOpXXGI67Af(cYqKz7AnrxaQ3Jmkoiqhf6lHQyak4I4IV3YATgj0zsaTkoE2Uwt0fG69iJIdc0rH(s4ocM7Rqd5(ihOtPprxaQ3Ql02z7fGGJrqwtd5ULqmHK0yyY7GI6s6ngboxV4rDj4b76pJ)zKGRuqFyYkgIqsJHjbpyx)z8pJKEloMKpddmifUMaCLc6ZU7GFC86K0yyYbEQtcEz)aj9wCmE3L(Elh4Poj4L9dyqYNHbgKcxtaUsb9HPix0eKbOGlIl(ElR1AKqNjRSk3xHgY9roqNsFIUauVvxOTKAoF14GGPTeIjKKgdtEhuuxU4r944a3x0WwkggGC6HiW9(kBTeuUDMSIrxaQ3sCV0no5wO3vnwL7Rqd5(ihOtPprxaQ3Ql0wsnNViRgNLqmHK0yyY7GI6YfpQhhh4(Ig2sXWaKtpebU3xzRLGYTZKvm6cq9wI7LUXj3c9UQXkg4Dx67TmaOVUzU8ErQ)k3xHgY9roqNsFIUauVvxOTrXbb6OqFzjetijngMu5Gau)zii5(PaqFDGKEJXSDTMOla17rgfheOJc9ftQY9vOHCFKd0P0NOla1B1fAlOOGofbPMh1siMW5nbj3PhzdpyhrJyNTqCCaxbO(iCN4yriPXWKGhSR)m(NrsVXqCbGfP(YR2hO7tSHRMZOl99wQuZubWL3ls9xcM7Rqd5(ihOtPprxaQ3Ql02fOO4obGxalHycjPXWK3bf1L0Bmez2Uwt0fG69iJIdc0rH(IjvXXGcUiU47TSwRrcDMuzLG5(k0qUpYb6u6t0fG6T6cTL7JUOPW1wcXessJHjVdkQlP3Y9vOHCFKd0P0NOla1B1fAlPMZxnoiy6CFfAi3h5aDk9j6cq9wDH2sQ58fz14Y9vOHCFKd0P0NOla1B1fAlOOGofbPMhn3xHgY9roqNsFIUauVvxOTba9Gd6ueKAE0CFfAi3h5aDk9j6cq9wDH2gfheOJc9LPnTXa]] )


end
