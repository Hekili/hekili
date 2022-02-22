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
            charges = function () return set_bonus.tier28_2pc > 0 and 3 or 2 end,
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


    spec:RegisterPack( "Fury", 20220221, [[d4K6kbqiiP8iuO2ek6tukgfrvNIOYQqHaEff0SubULki7IWVOinmIshJs1YOiEMkuMgkKUMkKTPck(MkuzCuGCovOkRdfW8GKCpIyFefhesuTqkLEiKunrvqLlcjkBKcu8ruiOrIcHoPkOQvQsmtuGUjfOs7Kc1prHanukqvlffIEkknvkKRsbkzRQGsFvfQQXcjYEj5Vq1GbDyjlgPESitwuxwzZq5ZqmAi1PbwnfOIxRsA2K62uYUP63OA4QOJJcA5Q65iMUW1rY2jsFNIA8uaNhsy9uGsnFvQ9l1k7kJuS5kMYytK1etK1etSlm5yMyx2JtXgO4Ck2ZkDTqMI1lRPynyOEuOypluO5vwzKILWP(0uSOJ4KWaMAkciqtrlsCltjalkDfaUN(clmLaSsMQyPPa64W7kAfBUIPm2eznXeznXe7ctoMj2L9yk2IkqZFfllWc1BOPneL)j0aRa8CIIfniNNROvS5rskwdgQhfn84x)d4FFXGz0pv9OOHMy)GgAISMysFPVG6OlhzegOVCOgIYZ5LBObpLL10I(YHA4HdqkA9Yn0IlDwZJgAAdze3ZbPgYGRoByQ06gkVZJg6B5LBig)BiWpeszTgM4EmdeYj6lhQHgC5sxUH2QR8ib)TAy55gE4(cH7nKrYRVHfnx6AOTAophObpjAyWBiW685sxdX(XqQ5ju0qowd)L4wwZZva4oPHYtawKg(Cke0Au0WXqQslNOVCOgIYZ5LBOTve61qw0CQOHbVHN)sCl6kAik3GNbf9Ld1quEoVCdnyrwdp8XSiI(YHAOrMxDTHy8VHhF0GxBg45gspm(VgQN0PB4XoorF5qnKrolU0LBikJqMNgr0xoudpCC3MOHuK1qwWqg9V66(gcWAiiSH0Ws)RYOOHuNnu(d3QaTvDDVCI(YHAi7cQZgIvxxdjJHuZtJ0qm(3qwaIVOH8Z57fkwnGeeLrk2IpLrkJTRmsXoVO1lRSvXMEqShukwKuw8ZQaoPHsAOSnKzdjCknnWZcmWtcCs8GRtmVO1l3qMnKMcdtGbEsGtIhCDIFwfWjnKzdPPWWeZ)czIFwfWjnevnejLvSvkaCxXMkpnnonfgMILMcdd3lRPyP1vEKG)wQqzSjkJuSZlA9YkBvSPhe7bLILMcdtm)lKjOoBiZgM4CDMB2f)sx1Jq8riIFwfWjnuMgEKITsbG7k2YtG5bEHf7jO5PRQqz8XugPyNx06Lv2Qytpi2dkflnfgMy(xitqD2qMn8lK1qu1qgvwfBLca3vSKZvpohdNUibG7QqzmJQmsXoVO1lRSvXMEqShukwAkmmX8VqMG6SHmBi5CAnEupYcIWmAWRnd8CdLPHMOyRua4UILwx5rc(BPybES)PodCaMIfjLf)SkGtKiltcNstd8Sad8KaNep46ystHHjWapjWjXdUoXpRc4eM0uyyI5FHmXpRc4euHKYQqz8rkJuSZlA9YkBvSPhe7bLIv(gstHHjM)fYeuNn8(UH0uyyIFPR6ri(ieb1zdz2WNYhg)rMGaCmknoH6rMyErRxUHY1qMnuA9GIwpXmWsuXWprxKPyRua4UInX98SCvOm(WOmsXwPaWDflbmKr)RUUxXoVO1lRSvfkJpoLrk2kfaURy)Y6SqMIDErRxwzRkugBqkJuSZlA9YkBvSPhe7bLILMcdtm)lKjOoBiZgM4CDMB2f)sx1Jq8riIFwfWjnuMgEKITsbG7kwY5QhNJHtxKaWDvOm(4PmsXoVO1lRSvXMEqShukwAkmmX8VqM4NvbCsdLPHiPCdzeOHMiosXwPaWDflTUYJe83sfQqXsaoIE4r9ilugPm2UYif78IwVSYwfB6bXEqPyFkFy8hzcZaTgNJHhOho9EY(R7fJHuGZZLBiZgstHHjmd0ACogEGE407j7VUx8ZQaoPHOQHiPSITsbG7k2VqaocoTMBwfkJnrzKIDErRxwzRIn9GypOuSpLpm(JmHzGwJZXWd0dNEpz)19IXqkW55YnKzdPPWWeMbAnohdpqpC69K9x3l(zvaN0qu1qKuwXwPaWDf7xiahbNwZnRcLXhtzKIDErRxwzRIn9GypOuSKZP14r9ilicZObV2mWZnusdT3qMnejLf)SkGtAOKgkBdz2q5Byu65HWQiKk9tmVO1l3W77gM4sNxEiKopqJIVHY1qMnuA9GIwpXmWsuXWprxK1qMnu(g(fYAOmn84jBdVVBiQ1WeNRZCZUiX98SCXpRc4KgkNITsbG7k2u5PPXPPWWuS0uyy4EznflTUYJe83sfkJzuLrk25fTEzLTk20dI9GsXkFdPPWWeZ)czcQZgEF3qAkmmXV0v9ieFeIG6SHmB4t5dJ)itqaogLgNq9itmVO1l3q5AiZgkTEqrRNygyjQy4NOlYuSvkaCxXM4EEwUkugFKYif78IwVSYwfB6bXEqPyZJMcdtqadz0)QR7fzUzVHmBO8nKCoTgpQhzbrygn41MbEUHY0q7n8(UHFbY4t68qu5mra8gktdTFudLtXwPaWDflbmKr)RUUxfkJpmkJuSZlA9YkBvSPhe7bLILMcdt8lDvpcXhHiOoB49DdLVH0uyyI5FHmXpRc4KgIQgIKYn8(UHFHSgktdnizBOCn8(UH0uyycSFUbBui(zvaN0qu1q7IJuSvkaCxX(L1zHmvOm(4ugPyRua4UInX98SCf78IwVSYwvOm2GugPyNx06Lv2Qytpi2dkflnfgMy(xitqD2qMnu(gsoNwJh1JSGimJg8AZap3qzAO9gEF3WVaz8jDEiQCMiaEdLPHh3rnuofBLca3vSLNaZd8cl2tqZtxvHY4JNYif78IwVSYwfB6bXEqPyPPWWeZ)czcQZgYSHY3qY50A8OEKfeHz0GxBg45gktdT3W77g(fiJpPZdrLZebWBOmnKrpQHYPyRua4UILCU6X5y40fjaCxfkJTlRYifBLca3vSZalrftXoVO1lRSvfkJTBxzKIDErRxwzRIn9GypOuS0uyyI5FHmb1zdz2q5BiQ1qAkmmXV0v9ieFeI4NvbCsdVVB4xiRHOQHhjBdLRHmBO8nKCoTgpQhzbrygn41MbEUHsAO9gYSHFbY4t68qu5mra8gktdz0JA49DdjNtRXJ6rwqeMrdETzGNBOKgAsdLtXwPaWDflTUYJe83sfkJTBIYif78IwVSYwfBLca3vS0AophObpjuSPhe7bLILMcdtm)lKjYCZEdVVByI7zkqiKcsaofbpX9ywNH4l)AdLPHh1qMnmQhzHa9kDGwCMIgIQgESJuSjuK0dpQhzbrzSDvOm2(XugPyNx06Lv2Qytpi2dkflnfgMy(xitK5M9gEF3We3ZuGqifKaCkcEI7XSodXx(1gktdpQHmByupYcb6v6aT4mfnevn8yh1qMne1Ayu65Hi9uthOqmVO1lRyRua4UILwZ55an4jHkugBNrvgPyNx06Lv2Qytpi2dkflnfgMy(xitqD2qMnu(gsoNwJh1JSGimJg8AZap3qzAO9gEF3WVaz8jDEiQCMiaEdLPH2pQHYPyRua4UIn)fc3XFE9QqzS9JugPyNx06Lv2Qytpi2dkflnfgMWAFcOhHGtZ9H8apVxqD2qMnKCoTgpQhzbrygn41MbEUHY0WJPyRua4UI1mAWRnd8SkugB)WOmsXoVO1lRSvXMEqShukwYcCAUtrebyVjgeUjNPgEF3We66rgPHsAOjn8(UHY3qAkmmXV0v9ieFeIG6SHmBO06bfTEIzGLOIHFIUiRHmByu65HWQiKk9tmVO1l3q5uSvkaCxX(fcWrWP1CZQqzS9JtzKIDErRxwzRIn9GypOuSKf40CNIicWEtmiCtotn8(UHj01JmsdL0qtA49DdLVH0uyyIFPR6ri(ieb1zdz2qP1dkA9eZalrfd)eDrwdz2WO0ZdHvriv6NyErRxUHYPyRua4UI9leGJGtR5MvHYy7gKYif78IwVSYwfB6bXEqPyPPWWeZ)czcQtfBLca3vSCNOlke0HkugB)4PmsXoVO1lRSvXwPaWDflTMZZbAWtcfB6bXEqPyPPWWeZ)czIm3SRytOiPhEupYcIYy7QqzSjYQmsXwPaWDflTMZZbAWtcf78IwVSYwvOm2e7kJuSvkaCxXsR58CGg8KqXoVO1lRSvfkJnXeLrk2kfaURy)cb4i40AUzf78IwVSYwvOm2KJPmsXwPaWDf7xiahbNwZnRyNx06Lv2QcLXMWOkJuSvkaCxXAgn41MbEwXoVO1lRSvfQqXMhwrPdLrkJTRmsXoVO1lRSvXwPaWDfBcD9itXMhj9GZaWDflQJUEK1qawdnpB(1qn3rA4zrIgYP(gYpNV)GgY)gAEnmZDBIg6B5ggOxd5NZ33We3IM3qm(3qwaIVOHY7C)qh25bAu8YjuSPhe7bLInawRHY0qdQH33nmk98qK5u06HhaRjMx06LB49DdRuaKo85ZcmsdLPH2B49DdtCPZlpesNhOrX3W77gIAn8P8HXFKjiaeFbohdp4V18yz8RahHigdPaNNl3W77gM4CDMB2f)sx1Jq8riIFwfWjnuMgIKYQqzSjkJuSvkaCxXEszznTIDErRxwzRkugFmLrk25fTEzLTkw(PILSqXwPaWDfR06bfTEkwPLMAk2O0ZdHvriv6NyErRxUHmByupYcb6v6aT4mfnevn8yh1W77gg1JSqGELoqlotrdrvdnr2gEF3WOEKfc0R0bAXzkAOmn0GKTHmByIlDE5Hq68ankEfR06X9YAk2zGLOIHFIUitfkJzuLrk25fTEzLTkw(PILSqXwPaWDfR06bfTEkwPLMAk2NYhg)rMGaq8f4Cm8G)wZJLXVcCeIyErRxUH33n8P8HXFKjiahJsJtOEKjMx06LB49DdFkFy8hzIPrbbuoUfabDiMx06LvSsRh3lRPyPCadPgUEiZZ1dgrfkJpszKIDErRxwzRITsbG7kwAnNNd0GNekwnWhEkRyTlRIn9GypOuSbWAnevn0GAiZgwPaiD4ZNfyKgkPH2BiZg(u(W4pYeeaIVaNJHh83AESm(vGJqeJHuGZZLBiZgkFdrTgM4sNxEiKopqJIVH33nmX56m3Sl(LUQhH4Jqe)SkGtAiQK0qKuUHYPyZJKEWza4UIfLzrPRyKgcCqakDdTvZ55an4jrdjJHuZtRHy8VHeGJO3HI6rw0qdBilaXxiuHY4dJYif78IwVSYwfBLca3vS)sx1Jq8rikwnWhEkRyTlRIn9GypOuSbWAnevn0GAiZgwPaiD4ZNfyKgkPH2BiZgM4sNxEiKopqJIVHmB4t5dJ)itqai(cCogEWFR5XY4xbocrmgsbopxUHmB45pPcAnNNd0GNek28iPhCgaURyrzwu6kgPHaheGs3qg5sx1Jq8rinKmgsnpTgIX)gsaoIEhkQhzrdnSHh25bAu8n0WgYcq8fcvOm(4ugPyNx06Lv2QyRua4UIf9EoiHRxDQy1aF4PSI1USk20dI9GsXsweahHiqVNds4j01JSgYSHbWAnevn8OgYSHvkash(8zbgPHsAO9gYSHOwdtCPZlpesNhOrX3qMn8P8HXFKjiaeFbohdp4V18yz8RahHigdPaNNl3qMn88NubTMZZbAWtIgYSHjoxN5MDrcD9it8ZQaoPHOQHYkosXMhj9GZaWDflkZIsxXine4Gau6gYiUNdsnKbxD2qzAiQJUEK1qYyi180Aig)Bib4i6DOOEKfn0Wg6C)qh25bAu8n0WgYcq8fcvOm2GugPyNx06Lv2QyRua4UInHUEKPy1aF4PSI1USk20dI9GsXsweahHiqVNds4j01JSgYSHbWAnevn8OgYSHvkash(8zbgPHsAO9gYSHOwdtCPZlpesNhOrX3qMn8P8HXFKjiaeFbohdp4V18yz8RahHigdPaNNl3qMn88Nub69CqcxV6uXMhj9GZaWDflkZIsxXine4Gau6gYiUNdsnKbxD2qzAiQJUEK1qYyi180Aig)Bib4i6DOOEKfn0Wg6C)qh25bAu8n0WgYcq8fcvOm(4PmsXwPaWDf7jpaCxXoVO1lRSvfkJTlRYif78IwVSYwfB6bXEqPytCUoZn7IFPR6ri(ieXpRc4KgIQgESgYSHrPNhIFPR6ri4fD5zUlMx06LvSvkaCxX(L1zHmvOm2UDLrk25fTEzLTk20dI9GsXstHHj(LUQhH4JqezUzVHmByE0uyyccyiJ(xDDViZn7n8(UHyae0b(pRc4KgIQgEKSk2kfaURytCNHu75pbNUCFVkugB3eLrk25fTEzLTk20dI9GsX(u(W4pYeeGJrPXjupYeZlA9YnKzdrszXpRc4KgkPHY2qMnu(gkTEqrRNygyjQy4NOlYA49DdLVHr9ilebWA4bh)mf4h7OgktdzuzBiZggLEEikhzpUv5fYSMhI5fTE5gEF3WOEKfIayn8GJFMc8JDudLPHhNSnKzdrTggLEEikhzpUv5fYSMhI5fTE5gkxdLRHmBO8nKCoTgpQhzbrygn41MbEUHsAO9gEF3qAkmmH1QapPxjDVG6SHYPyRua4UI9x6QEeIpcrfkJTFmLrk25fTEzLTk20dI9GsX(u(W4pYetJccOCClac6qmVO1l3qMnejLf)SkGtAOKgkBdz2q5ByIZ1zUzxqox94CmC6IeaUl(zvaN0qu1WJA49DdtCUoZn7cY5QhNJHtxKaWDXpRc4Kgktdnr2gkxdz2q5BO8nKMcdtqR58SMIecQZgEF3WO0Zdr5i7XTkVqM18qmVO1l3W77g(fiJpPZdrLZebWBOmn0USnuUgEF3WOEKfIayn8GJNbRHY0q7YkBdVVBO06bfTEIzGLOIHFIUiRH33nmQhzHiawdp44zWAiQAO9JAiZg(fiJpPZdrLZebWBOmn0USnuUgYSHY3qY50A8OEKfeHz0GxBg45gkPH2B49DdPPWWewRc8KEL09cQZgkNITsbG7k2FPR6ri(ievOm2oJQmsXoVO1lRSvXMEqShukwuRHsRhu06jOCadPgUEiZZ1dgPHmBiskl(zvaN0qjnu2gYSHY3q5BinfgMGwZ5znfjeuNn8(UHrPNhIYr2JBvEHmR5HyErRxUH33n8lqgFsNhIkNjcG3qzAODzBOCn8(UHr9ilebWA4bhpdwdLPH2Lv2gEF3qP1dkA9eZalrfd)eDrwdVVBinNqAiZgg1JSqeaRHhC8mynevn0(rnKzd)cKXN05HOYzIa4nuMgAx2gkxdz2q5Bi5CAnEupYcIWmAWRnd8CdL0q7n8(UH0uyycRvbEsVs6Eb1zdLRHmByIZ1zUzxK4odP2ZFcoD5(EXpRc4KgktdnrwfBLca3vS)sx1Jq8riQqzS9JugPyNx06Lv2Qytpi2dkf7t5dJ)itqai(cCogEWFR5XY4xbocrmgsbopxUHmB45pP4iPSWU4lRZcznKzdLVHY3qAkmmbTMZZAksiOoB49DdJsppeLJSh3Q8czwZdX8IwVCdVVB4xGm(KopevoteaVHY0q7Y2q5A49DdJ6rwicG1WdoEgSgktdTlRSn8(UHsRhu06jMbwIkg(j6ISgEF3WOEKfIayn8GJNbRHOQH2pQHmB4xGm(KopevoteaVHY0q7Y2q5AiZgkFdjNtRXJ6rwqeMrdETzGNBOKgAVH33nKMcdtyTkWt6vs3lOoBOCk2kfaURy)LUQhH4JquSuKHZXWWrszLX2vHYy7hgLrk25fTEzLTk20dI9GsXQN0PBOmn8yhMgYSHY3qY50A8OEKfeHz0GxBg45gktdT3qMne1AinfgMWAvGN0RKUxqD2W77g(fiJpPZdrLZebWBiQAisk3qMne1AinfgMWAvGN0RKUxqD2q5uSvkaCxXAgn41MbEwfkJTFCkJuSvkaCxXsrgoiMfrXoVO1lRSvfkJTBqkJuSvkaCxXsR58mog1Jcf78IwVSYwvOm2(XtzKIDErRxwzRIn9GypOuS0uyyIFPR6ri(ieb1PITsbG7kw69K9xboIkugBISkJuSZlA9YkBvSPhe7bLILMcdt8lDvpcXhHiYCZEdz2W8OPWWeeWqg9V66ErMB2vSvkaCxXQbiOdcUbhQmI18qfkJnXUYifBLca3vSyGF0AopRyNx06Lv2QcLXMyIYifBLca3vSLNgj(sJNkTwXoVO1lRSvfkJn5ykJuSZlA9YkBvSPhe7bLILMcdt8lDvpcXhHiYCZEdz2W8OPWWeeWqg9V66ErMB2BiZgstHHjM)fYeuNk2kfaURyPleCogE8G0vIkugBcJQmsXoVO1lRSvXMEqShukwY50A8OEKfeHz0GxBg45gktdTRyjXdsHYy7k2kfaURytLwJxPaWDCnGekwnGe4EznfBXNkugBYrkJuSZlA9YkBvSvkaCxX(uoELca3X1asOy1asG7L1uSeGJOhEupYcvOcf75Ve3IUcLrkJTRmsXwPaWDflDfHE4e0CQqXoVO1lRSvfkJnrzKIDErRxwzRIn9GypOuSOwdFkFy8hzccaXxGZXWd(Bnpwg)kWriIXqkW55Yk2kfaURy)LUQhH4JquHkuHIv6EcG7kJnrwtSl7Xj7rkwZ17ahHOyp(OCgPXhEJzeYanSHgHEneyDY)OHy8VH2u8ztd)XqkWVCdjCR1WIk4wvSCdtOlhzerFHbb(AODgOHOo3LUpwUH2q4uAAGNfOKnnm4n0gcNstd8SaLeZlA9Y20q5TBa5e9fge4RHhXane15U09XYn0MNYhg)rMaLSPHbVH28u(W4pYeOKyErRx2MgkVDdiNOV0xo(OCgPXhEJzeYanSHgHEneyDY)OHy8VH2qaoIE4r9ilSPH)yif4xUHeU1AyrfCRkwUHj0LJmIOVWGaFn8ymqdrDUlDFSCdTjXLoV8qGsI5fTEzBAyWBOnjU05LhcuYMgkVDdiNOVWGaFnKrzGgI6Cx6(y5gAZt5dJ)itGs20WG3qBEkFy8hzcusmVO1lBtdL3UbKt0x6lhFuoJ04dVXmczGg2qJqVgcSo5F0qm(3qBYdRO0Hnn8hdPa)YnKWTwdlQGBvXYnmHUCKre9fge4RHhJbAiQZDP7JLBOnrPNhcuYMgg8gAtu65HaLeZlA9Y20q5TBa5e9fge4RHmkd0quN7s3hl3qBEkFy8hzcuYMgg8gAZt5dJ)itGsI5fTEzBAO82nGCI(cdc81qgLbAiQZDP7JLBOnpLpm(JmbkztddEdT5P8HXFKjqjX8IwVSnnSIgIYyeKbBO82nGCI(cdc81qgLbAiQZDP7JLBOnpLpm(JmbkztddEdT5P8HXFKjqjX8IwVSnnuE7gqorFHbb(A4HHbAiQZDP7JLBOnjU05LhcusmVO1lBtddEdTjXLoV8qGs20q5TBa5e9fge4RHhhd0quN7s3hl3qBsCPZlpeOKyErRx2Mgg8gAtIlDE5HaLSPHYB3aYj6lmiWxdnigOHOo3LUpwUH2K4sNxEiqjX8IwVSnnm4n0Mex68YdbkztdL3UbKt0xyqGVgA3egOHOo3LUpwUH2eLEEiqjBAyWBOnrPNhcusmVO1lBtdL3ediNOVWGaFn0UjmqdrDUlDFSCdT5P8HXFKjqjBAyWBOnpLpm(JmbkjMx06LTPHYB3aYj6lmiWxdTFmgOHOo3LUpwUH28u(W4pYeOKnnm4n0MNYhg)rMaLeZlA9Y20q5TBa5e9L(YH36K)XYnKrByLca3BOgqcIOVOypFogqpflJzCdnyOEu0WJF9pG)9fgZ4gAWm6NQEu0qtSFqdnrwtmPV0xymJBiQJUCKryG(cJzCdpudr558Yn0GNYYAArFHXmUHhQHhoaPO1l3qlU0znpAOPnKrCphKAidU6SHPsRBO8opAOVLxUHy8VHa)qiL1AyI7XmqiNOVWyg3Wd1qdUCPl3qB1vEKG)wnS8CdpCFHW9gYi513WIMlDn0wnNNd0GNenm4neyD(CPRHy)yi18ekAihRH)sClR55kaCN0q5jalsdFofcAnkA4yivPLt0xymJB4HAikpNxUH2wrOxdzrZPIgg8gE(lXTOROHOCdEgu0xymJB4HAikpNxUHgSiRHh(ywerFHXmUHhQHgzE11gIX)gE8rdETzGNBi9W4)AOEsNUHh74e9fgZ4gEOgYiNfx6YneLriZtJi6lmMXn8qn8WXDBIgsrwdzbdz0)QR7BiaRHGWgsdl9VkJIgsD2q5pCRc0w119Yj6lmMXn8qnKDb1zdXQRRHKXqQ5PrAig)BilaXx0q(589I(sFHXmUHOmdSevSCdPhg)xdtCl6kAi9qaor0quEkTZG0qN7hcD9wyu6gwPaWDsd5UgfI(sLca3jIZFjUfDfgkXu6kc9WjO5urFPsbG7eX5Ve3IUcdLy6V0v9ieFeYbamjO2t5dJ)itqai(cCogEWFR5XY4xbocrmgsbopxUV0xymJBikZalrfl3WjDpkAyaSwdd0RHvk4FdbKgwslGUO1t0xyCdrD01JSgcWAO5zZVgQ5osdpls0qo13q(589h0q(3qZRHzUBt0qFl3Wa9Ai)C((gM4w08gIX)gYcq8fnuEN7h6WopqJIxorFPsbG7ejj01JSdayscG1KXGUVJsppezofTE4bWAI5fTE577kfaPdF(SaJiJ977ex68YdH05bAu833O2t5dJ)itqai(cCogEWFR5XY4xbocrmgsbopx((oX56m3Sl(LUQhH4Jqe)SkGtKbjL7lvkaCNyOetpPSSMUVuPaWDIHsmvA9GIwVd8YAsMbwIkg(j6ISdKwAQjjk98qyvesL(XmQhzHa9kDGwCMcuDSJUVJ6rwiqVshOfNPavMi79DupYcb6v6aT4mfYyqYYmXLoV8qiDEGgfFFPsbG7edLyQ06bfTEh4L1Kq5agsnC9qMNRhmYbsln1K8u(W4pYeeaIVaNJHh83AESm(vGJqUVFkFy8hzccWXO04eQhz33pLpm(JmX0OGakh3cGGo6lmMXn0i0asdbKgAXjHgfnm4n88N05rdtCUoZn7KgI9CRgspGJ0WkLa55rP1OOHuKLByM6bosdT4sN18q0xymJByLca3jgkX0NYXRua4oUgqId8YAsS4sN184aaMelU0znpezajkpnzoQVWyg3WkfaUtmuIPO3ZbjC9QZdaysK)lqgFsNhclU0znpezajkpnzm5iMFbY4t68qyXLoR5Ha4YWOhjxFHXmUHvkaCNyOetjJHuZt7aaMKkfaPdF(SaJiXoZex68YdH05bAu8I5fTEzMpLpm(JmbbG4lW5y4b)TMhlJFf4ieXyif48C5d8YAsS1iMmYLUYa0AophObpjyGFPR6ri(iK(cJBikZIsxXine4Gau6gARMZZbAWtIgsgdPMNwdX4FdjahrVdf1JSOHg2qwaIVq0xQua4oXqjMsR58CGg8K4anWhEklXUShaWKeaRHkdIzLcG0HpFwGrKyN5t5dJ)itqai(cCogEWFR5XY4xbocrmgsbopxMP8OwIlDE5Hq68ank(77eNRZCZU4x6QEeIpcr8ZQaobvsqsz56lmUHOmlkDfJ0qGdcqPBiJCPR6ri(iKgsgdPMNwdX4FdjahrVdf1JSOHg2Wd78ank(gAydzbi(crFPsbG7edLy6V0v9ieFeYbAGp8uwIDzpaGjjawdvgeZkfaPdF(SaJiXoZex68YdH05bAu8I5fTEzMpLpm(JmbbG4lW5y4b)TMhlJFf4ieXyif48CzMN)KkO1CEoqdEs0xymJByLca3jgkXuYyi180oaGjPsbq6WNplWisSZe1sCPZlpesNhOrXlMx06Lz(u(W4pYeeaIVaNJHh83AESm(vGJqeJHuGZZLpWlRjXwJyI6ORhzmaTMZZbAWtcga9EoiHNqxpY6lmUHOmlkDfJ0qGdcqPBiJ4Eoi1qgC1zdLPHOo66rwdjJHuZtRHy8VHeGJO3HI6rw0qdBOZ9dDyNhOrX3qdBilaXxi6lvkaCNyOetrVNds46vNhOb(Wtzj2L9aaMeYIa4ieb69CqcpHUEKXmawdvhXSsbq6WNplWisSZe1sCPZlpesNhOrXlMx06Lz(u(W4pYeeaIVaNJHh83AESm(vGJqeJHuGZZLzE(tQGwZ55an4jbZeNRZCZUiHUEKj(zvaNGkzfh1xyCdrzwu6kgPHaheGs3qgX9CqQHm4QZgktdrD01JSgsgdPMNwdX4FdjahrVdf1JSOHg2qN7h6WopqJIVHg2qwaIVq0xQua4oXqjMMqxpYoqd8HNYsSl7bamjKfbWric075GeEcD9iJzaSgQoIzLcG0HpFwGrKyNjQL4sNxEiKopqJIxmVO1lZ8P8HXFKjiaeFbohdp4V18yz8RahHigdPaNNlZ88Nub69CqcxV6SVuPaWDIHsm9KhaU3xQua4oXqjM(L1zHSdayssCUoZn7IFPR6ri(ieXpRc4euDmMrPNhIFPR6ri4fD5zUlMx06L7lvkaCNyOettCNHu75pbNUCF)bamj0uyyIFPR6ri(ierMB2zMhnfgMGagYO)vx3lYCZ(9ngabDG)ZQaobvhjBFPsbG7edLy6V0v9ieFeYbamjpLpm(Jmbb4yuACc1JmMiPS4NvbCIezzkV06bfTEIzGLOIHFIUi7(w(OEKfIayn8GJFMc8JDKmmQSmJsppeLJSh3Q8czwZJ77OEKfIayn8GJFMc8JDKmhNSmrTO0Zdr5i7XTkVqM18qo5ykp5CAnEupYcIWmAWRnd8Se7330uyycRvbEsVs6Eb1PC9LkfaUtmuIP)sx1Jq8rihaWK8u(W4pYetJccOCClac6Gjskl(zvaNirwMYN4CDMB2fKZvpohdNUibG7IFwfWjO6O77eNRZCZUGCU6X5y40fjaCx8ZQaorgtKvoMYlpnfgMGwZ5znfjeuN33rPNhIYr2JBvEHmR5HyErRx(((lqgFsNhIkNjcGlJDzL7(oQhzHiawdp44zWKXUSYEFlTEqrRNygyjQy4NOlYUVJ6rwicG1WdoEgmuz)iMFbY4t68qu5mraCzSlRCmLNCoTgpQhzbrygn41MbEwI97BAkmmH1QapPxjDVG6uU(sLca3jgkX0FPR6ri(iKdaysqnP1dkA9euoGHudxpK556bJWejLf)SkGtKilt5LNMcdtqR58SMIecQZ77O0Zdr5i7XTkVqM18qmVO1lFF)fiJpPZdrLZebWLXUSYDFh1JSqeaRHhC8myYyxwzVVLwpOO1tmdSevm8t0fz330CcHzupYcraSgEWXZGHk7hX8lqgFsNhIkNjcGlJDzLJP8KZP14r9ilicZObV2mWZsSFFttHHjSwf4j9kP7fuNYXmX56m3SlsCNHu75pbNUCFV4NvbCImMiBFPsbG7edLy6V0v9ieFeYbuKHZXWWrszj2paGj5P8HXFKjiaeFbohdp4V18yz8RahHigdPaNNlZ88NuCKuwyx8L1zHmMYlpnfgMGwZ5znfjeuN33rPNhIYr2JBvEHmR5HyErRx(((lqgFsNhIkNjcGlJDzL7(oQhzHiawdp44zWKXUSYEFlTEqrRNygyjQy4NOlYUVJ6rwicG1WdoEgmuz)iMFbY4t68qu5mraCzSlRCmLNCoTgpQhzbrygn41MbEwI97BAkmmH1QapPxjDVG6uU(sLca3jgkXuZObV2mWZhaWKON0PL5yhgMYtoNwJh1JSGimJg8AZaplJDMOgnfgMWAvGN0RKUxqDEF)fiJpPZdrLZebWrfskZe1OPWWewRc8KEL09cQt56lvkaCNyOetPidheZI0xQua4oXqjMsR58mog1JI(sLca3jgkXu69K9xboYbamj0uyyIFPR6ri(ieb1zFPsbG7edLyQgGGoi4gCOYiwZJdaysOPWWe)sx1Jq8riIm3SZmpAkmmbbmKr)RUUxK5M9(sLca3jgkXumWpAnNN7lvkaCNyOetlpns8LgpvADFPsbG7edLykDHGZXWJhKUsoaGjHMcdt8lDvpcXhHiYCZoZ8OPWWeeWqg9V66ErMB2zstHHjM)fYeuN9LkfaUtmuIPPsRXRua4oUgqIdiXdsHe7h4L1Ku8Daatc5CAnEupYcIWmAWRnd8Sm27lvkaCNyOetFkhVsbG74AajoWlRjHaCe9WJ6rw0x6lvkaCNik(KKkpnnonfg2bEznj06kpsWFRdaysqszXpRc4ejYYKWP00aplWapjWjXdUoM0uyycmWtcCs8GRt8ZQaoHjnfgMy(xit8ZQaobviPCFPsbG7erXNHsmT8eyEGxyXEcAE66bamj0uyyI5FHmb1jZeNRZCZU4x6QEeIpcr8ZQaorMJ6lvkaCNik(muIPKZvpohdNUibG7haWKqtHHjM)fYeuNm)czOIrLTVuPaWDIO4ZqjMsRR8ib)Toa4X(N6mWbysqszXpRc4ejYYKWP00aplWapjWjXdUoM0uyycmWtcCs8GRt8ZQaoHjnfgMy(xit8ZQaobviP8bamj0uyyI5FHmb1jtY50A8OEKfeHz0GxBg4zzmPVuPaWDIO4ZqjMM4EEw(bamjYttHHjM)fYeuN330uyyIFPR6ri(ieb1jZNYhg)rMGaCmknoH6rMCmLwpOO1tmdSevm8t0fz9LkfaUtefFgkXucyiJ(xDDFFPsbG7erXNHsm9lRZcz9LkfaUtefFgkXuY5QhNJHtxKaW9daysOPWWeZ)czcQtMjoxN5MDXV0v9ieFeI4NvbCImh1xQua4oru8zOetP1vEKG)whaWKqtHHjM)fYe)SkGtKbjLzeWeXr9L(sLca3jccWr0dpQhzHHsm9leGJGtR5MpaGj5P8HXFKjmd0ACogEGE407j7VUxmgsbopxMjnfgMWmqRX5y4b6HtVNS)6EXpRc4euHKY9LkfaUteeGJOhEupYcdLyA6PiObocoTMB(aaMKNYhg)rMWmqRX5y4b6HtVNS)6EXyif48CzM0uyycZaTgNJHhOho9EY(R7f)SkGtqfsk3xQua4orqaoIE4r9ilmuIPPYttJttHHDGxwtcTUYJe836aaMeY50A8OEKfeHz0GxBg4zj2zIKYIFwfWjsKLP8rPNhcRIqQ0pX8IwV89DIlDE5Hq68ankEX8IwVSCmLwpOO1tmdSevm8t0fzmL)lKjZXt27BulX56m3SlsCpplx8ZQaorU(sLca3jccWr0dpQhzHHsmnX98S8daysKNMcdtm)lKjOoVVPPWWe)sx1Jq8ricQtMpLpm(Jmbb4yuACc1Jm5ykTEqrRNygyjQy4NOlY6lvkaCNiiahrp8OEKfgkXucyiJ(xDD)bamj5rtHHjiGHm6F119Im3SZuEY50A8OEKfeHz0GxBg4zzSFF)fiJpPZdrLZebWLX(rY1xQua4orqaoIE4r9ilmuIPFzDwi7aaMeAkmmXV0v9ieFeIG68(wEAkmmX8VqM4NvbCcQqs577VqMmgKSYDFttHHjW(5gSrH4NvbCcQSloQVuPaWDIGaCe9WJ6rwyOettCpplVVuPaWDIGaCe9WJ6rwyOetlpbMh4fwSNGMNUEaatcnfgMy(xitqDYuEY50A8OEKfeHz0GxBg4zzSFF)fiJpPZdrLZebWL54osU(sLca3jccWr0dpQhzHHsmLCU6X5y40fjaC)aaMeAkmmX8VqMG6KP8KZP14r9ilicZObV2mWZYy)((lqgFsNhIkNjcGldJEKC9LkfaUteeGJOhEupYcdLy6mWsuX6lvkaCNiiahrp8OEKfgkXuADLhj4V1bamj0uyyI5FHmb1jt5rnAkmmXV0v9ieFeI4NvbCY99xidvhjRCmLNCoTgpQhzbrygn41MbEwIDMFbY4t68qu5mraCzy0JUVjNtRXJ6rwqeMrdETzGNLyIC9LkfaUteeGJOhEupYcdLykTMZZbAWtIdsOiPhEupYcIe7haWKqtHHjM)fYezUz)(oX9mfiesbjaNIGN4EmRZq8LFvMJyg1JSqGELoqlotbQo2r9LkfaUteeGJOhEupYcdLykTMZZ0vG(aaMeAkmmX8VqMiZn733jUNPaHqkib4ue8e3JzDgIV8RYCeZOEKfc0R0bAXzkq1XoIjQfLEEisp10bkeZlA9Y9LkfaUteeGJOhEupYcdLyA(leUJ)86paGjHMcdtm)lKjOozkp5CAnEupYcIWmAWRnd8Sm2VV)cKXN05HOYzIa4Yy)i56lvkaCNiiahrp8OEKfgkXuZObV2mWZhaWKqtHHjS2Na6ri40CFipWZ7fuNmjNtRXJ6rwqeMrdETzGNL5y9LkfaUteeGJOhEupYcdLy6xiahbNwZnFaatczbon3PiIaS3edc3KZ09DcD9iJiXK7B5PPWWe)sx1Jq8ricQtMsRhu06jMbwIkg(j6ImMrPNhcRIqQ0pX8IwVSC9LkfaUteeGJOhEupYcdLyA6PiObocoTMB(aaMeYcCAUtrebyVjgeUjNP77e66rgrIj33YttHHj(LUQhH4JqeuNmLwpOO1tmdSevm8t0fzmJsppewfHuPFI5fTEz56lvkaCNiiahrp8OEKfgkXuUt0ffc64aaMeAkmmX8VqMG6SVuPaWDIGaCe9WJ6rwyOetP1CEoqdEsCqcfj9WJ6rwqKy)aaMeAkmmX8VqMiZn79LkfaUteeGJOhEupYcdLykTMZZbAWtI(sLca3jccWr0dpQhzHHsmLwZ5z6kq3xQua4orqaoIE4r9ilmuIPFHaCeCAn3CFPsbG7ebb4i6Hh1JSWqjMMEkcAGJGtR5M7lvkaCNiiahrp8OEKfgkXuZObV2mWZkwY5skJpotuHkuka]] )


end
