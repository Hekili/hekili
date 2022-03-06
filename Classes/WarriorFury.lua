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


    spec:RegisterPack( "Fury", 20220301, [[d4KrBbqier9ikvztOsFIsLrrcofr0QiHc8ksQMfLOBHiyxe(LkHHHOCmsYYefEgjftJeQUgLKTrPQ8nkvvJJesNdrfToIqMNkr3JiTpePdsekluu0druPjIisDrIq1gjHc9rerGrscfDsevOvQsAMKqCteru7KsQFscf0qrerwkju6POQPsjCverqBfrK8vevWyreAVK6VqzWGoSulgPESitwfxwzZq1Nry0OItdSAerOEnLYSP42e1UP63OmCvQJteSCv9Citx46iz7KOVlknEskDEevTEeriZxuTFjRvPTqZF6yARZGSmYGm1qMkrgQXk7tvgA(G83tZF3jBnX08ElpnVIrQN8A(7M8gwF0wO5rmQpnnpNiUrs0fxqacou0Iet(ceqMY0bG5PVXJlqa50fAEAkGjihDnTM)0X0wNbzzKbzQHmvImuJv2NknFtfCyVMNhitUf8IckX(ehGCaEgsZZbCoZ10A(ZqjnVIrQN8fKCO)hW(6kj5(tCkOkllygKLrg116k5YPDIHKO6kjuqj25StbjjrjlpJOUscfKKgGAAZofuMPCYZJcErbvm3ZaPcQiRVlyQnMcQGZIc6BNDkio7liWjbIwEfmX8yQnKuuxjHcssMPCNcMPPpdfSxUGTFkij93emVGkww)fSPzkxbZ0WyNGd4rrbdwbbY3pt5ki(pjqnpr(cYWl4VetwE(PdaZrfubeqgvWNrrWXq(cojq1gjf1vsOGsSZzNcMzhHzfKNdJkkyWk49VetMUJckXijPiI6kjuqj25StbjjeTcsogtgjQRKqbTi7ABfeN9fKCGd4nzb(PG0dN9RGMPCMcQg7xuxjHcQyNmt5ofuIJqZtdjQRKqbjPzUDrbPqRG8Grm6FTT9feGxqqyhQGT5xFiFbPUlOcK0RdoYTT9skQRKqb5xqDxq822kiAsGAEAOcIZ(cYdi8ffKDpFVqZBaOaPTqZ3SPTqBTkTfA(5nTzhDMA(0dI9GwZtKoIFYnWrfuAbjRGCliIrzOb(rGdEuGHIhyBI5nTzNcYTG0u44cCWJcmu8aBt8tUboQGClinfoUy(3et8tUboQGxwqI0rZ3PaWCnFQ90my0u44AEAkCCmVLNMN20NHc2lRdT1zOTqZpVPn7OZuZNEqSh0AEAkCCX8VjMG6UGClyIXmhwwx8lzZmeYhcj(j3ahvqslOvA(ofaMR5BpbMhynEShXHLSPdT1QrBHMFEtB2rNPMp9GypO180u44I5Ftmb1Db5wWVjwbVSGkozA(ofaMR5r3RFmgogDJcaZ1H2AfxBHMFEtB2rNPMp9GypO180u44I5Ftmb1Db5wq09mgSOFIfirwoG3Kf4NcsAbZqZ3PaWCnpTPpdfSxwZd8y)tDhyaCnpr6i(j3ahjLmUigLHg4hbo4rbgkEGTXLMchxGdEuGHIhyBIFYnWrCPPWXfZ)MyIFYnWrxsKo6qBTvAl08ZBAZo6m18Phe7bTMxHcstHJlM)nXeu3fmpVG0u44IFjBMHq(qib1Db5wWNYho7jMabCCkdgI6jMyEtB2PGswqUfuz)GM2mXu7suXWU50OP57uayUMpX8ZKDDOT2(0wO57uayUMhbgXO)122R5N30MD0zQdT12V2cnFNcaZ18FlF3etZpVPn7OZuhARvuTfA(5nTzhDMA(0dI9GwZttHJlM)nXeu3fKBbtmM5WY6IFjBMHq(qiXp5g4OcsAbTsZ3PaWCnp6E9JXWXOBuayUo0wto1wO5N30MD0zQ5tpi2dAnpnfoUy(3et8tUboQGKwqI0PGkguWmewP57uayUMN20NHc2lRdDO5raNWmSOFIfAl0wRsBHMFEtB2rNPMp9GypO18pLpC2tmrwGXGXWXcodJEpAVT9IjbkW99ofKBbPPWXfzbgdgdhl4mm69O922l(j3ahvWllir6O57uayUM)BcGtGrByz1H26m0wO5N30MD0zQ5tpi2dAn)t5dN9etKfymymCSGZWO3J2BBVysGcCFVtb5wqAkCCrwGXGXWXcodJEpAVT9IFYnWrf8YcsKoA(ofaMR5)Ma4ey0gwwDOTwnAl08ZBAZo6m18Phe7bTMhDpJbl6NybsKLd4nzb(PGslOQcYTGePJ4NCdCubLwqYki3cQqbJ2mpeYnc1PFI5nTzNcMNxWet582dHY5bhY)fuYcYTGk7h00MjMAxIkg2nNgTcYTGkuWVjwbjTGKtYkyEEbj5cMymZHL1fjMFMSl(j3ahvqj18DkamxZNApndgnfoUMNMchhZB5P5Pn9zOG9Y6qBTIRTqZpVPn7OZuZNEqSh0AEfkinfoUy(3etqDxW88cstHJl(LSzgc5dHeu3fKBbFkF4SNyceWXPmyiQNyI5nTzNckzb5wqL9dAAZetTlrfd7MtJMMVtbG5A(eZpt21H2AR0wO5N30MD0zQ5tpi2dAn)z0u44ceyeJ(xBBV4WY6fKBbvOGO7zmyr)elqISCaVjlWpfK0cQQG55f8BWbBkNhI(CqcGxqslOkRkOKA(ofaMR5rGrm6FTT96qBT9PTqZpVPn7OZuZNEqSh0AEAkCCXVKnZqiFiKG6UG55fuHcstHJlM)nXe)KBGJk4LfKiDkyEEb)MyfK0cQOKvqjlyEEbPPWXf4)CsIiV4NCdCubVSGQewP57uayUM)B57My6qBT9RTqZpVPn7OZuZNEqSh0AE0cmAMtHebyFgkkwg3PcMNxWeN(jgQGslygfmpVGkuqAkCCXVKnZqiFiKG6UGClOY(bnTzIP2LOIHDZPrRGCly0M5HqUrOo9tmVPn7uqj18DkamxZ)nbWjWOnSS6qBTIQTqZ3PaWCnFI5Nj7A(5nTzhDM6qBn5uBHMFEtB2rNPMp9GypO180u44I5Ftmb1Db5wWeJzoSSU4xYMziKpes8tUboQGKwqRki3cQqbJ(jwicG8Wcg2bScsAbjNwvW88cstHJl(LSzgc5dHeu3fmpVGr)elebqEybd7awbVSGzqwbLSGCl43Gd2uope95GeaVGKwq73knFNcaZ18TNaZdSgp2J4Ws20H2AvKPTqZ3PaWCn)u7suX08ZBAZo6m1H2AvQ0wO5N30MD0zQ5tpi2dAn)t5dN9etmd5rG2XKbeCcX8M2Stb5wqAkCCX8VjMG6UGClyIXmhwwx8lzZmeYhcj(j3ahvqslOvfKBbvOG0u44IFjBMHq(qib1DbZZly0pXcraKhwWWoGvWllygKvW88cEgnfoUabgXO)122lOUlyEEbj5cgTzEiqGrm6FTT9I5nTzNcYTGr)elebqEybd7awbjTG2NIwqjli3c(n4GnLZdrFoibWliPf0kR08DkamxZJUx)ymCm6gfaMRdT1QYqBHMFEtB2rNPMp9GypO180u44I5Ftmb1Db5wqfkijxqAkCCXVKnZqiFiK4NCdCubZZl43eRGxwqRiRGswqUfuHcIUNXGf9tSajYYb8MSa)uqPfuvb5wWVbhSPCEi6ZbjaEbjTGkUvfmpVGO7zmyr)elqISCaVjlWpfuAbZOGsQ57uayUMN20NHc2lRdT1QuJ2cn)8M2SJotnF6bXEqR5PPWXfZ)MycQ7cYTGjgZCyzDXVKnZqiFiK4NCdCubjTGwvqUfuHcstHJl(LSzgc5dHeu3fmpVGr)elebqEybd7awbVSGzqwbZZl4z0u44ceyeJ(xBBVG6UG55fKKly0M5HabgXO)122lM30MDki3cg9tSqea5HfmSdyfK0cAFkAbLSGCl43Gd2uope95GeaVGKwqRSsZ3PaWCnp6E9JXWXOBuayUo0wRsX1wO5N30MD0zQ5tpi2dAnpAbgnZPqIaSpdfflJ7ubZZlyIt)edvqPfmJcMNxqfkinfoU4xYMziKpesqDxqUfuz)GM2mXu7suXWU50OvqUfmAZ8qi3iuN(jM30MDkOKA(ofaMR5)Ma4ey0gwwDOTwLvAl08ZBAZo6m18DkamxZtByStWb8OqZNEqSh0AEAkCCX8VjM4WY6fmpVGjMFOaHqjibyuiSeZJjFhIVDBfK0cAvb5wWOFIfcoRnbhXDkk4LfunwP5tKpzgw0pXcK2Av6qBTk7tBHMFEtB2rNPMp9GypO180u44I5FtmXHL1lyEEbtm)qbcHsqcWOqyjMht(oeF72kiPf0QcYTGr)eleCwBcoI7uuWllOASsZ3PaWCnpTHXobhWJcDOTwL9RTqZpVPn7OZuZNEqSh0AEAkCCX8VjMG6UGClOcfeDpJbl6NybsKLd4nzb(PGKwqvfmpVGFdoyt58q0Ndsa8csAbvzvbLuZ3PaWCn)5BcMJ9S(1H2AvkQ2cn)8M2SJotnF6bXEqR5PPWXfY7taZqimAMpIh4N9cQ7cYTGO7zmyr)elqISCaVjlWpfK0cQgnFNcaZ18z5aEtwGF0H2AvKtTfA(5nTzhDMA(0dI9GwZttHJlM)nXeu3A(ofaMR5zoY0ueCcDOTodY0wO57uayUMN2WyNGd4rHMFEtB2rNPo0wNHkTfA(ofaMR5Pnm2j4aEuO5N30MD0zQdT1zKH2cnFNcaZ18FtaCcmAdlRMFEtB2rNPo0wNHA0wO57uayUM)BcGtGrByz18ZBAZo6m1H26muCTfA(ofaMR5ZYb8MSa)O5N30MD0zQdDO5pdVPmH2cT1Q0wO5N30MD0zQ57uayUMpXPFIP5pdLEWDayUMNC50pXkiaVGzND)kOH5ef8UrrbzuFbz3Z3BzbzFbZUcEyUDrb9TtbdoRGS757lyIjtZkio7lipGWxuqfCMtcKuZdoK)LuO5tpi2dAnFaKxbjTGkAbZZly0M5H4WOOndlaYtmVPn7uW88c2PaOCyZNmyOcsAbvvW88cMykN3Eiuop4q(VG55fKKl4t5dN9etGae(cmgowWE55Xoy2aobsmjqbUV3PG55fmXyMdlRl(LSzgc5dHe)KBGJkiPfKiD0H26m0wO57uayUM)MswEgn)8M2SJotDOTwnAl08ZBAZo6m18SBnpAHMVtbG5AEL9dAAZ08kBd108rBMhc5gH60pX8M2Stb5wWOFIfcoRnbhXDkk4LfunwvW88cg9tSqWzTj4iUtrbVSGzqwbZZly0pXcbN1MGJ4offK0cQOKvqUfmXuoV9qOCEWH8VMxz)yElpn)u7suXWU50OPdT1kU2cn)8M2SJotnp7wZJwO57uayUMxz)GM2mnVY2qnn)t5dN9etGae(cmgowWE55Xoy2aobsmVPn7uW88c(u(WzpXeiGJtzWqupXeZBAZofmpVGpLpC2tmXmKhbAhtgqWjeZBAZoAEL9J5T808uoqcudZmI5N(bdPdT1wPTqZpVPn7OZuZ3PaWCnpTHXobhWJcnVb4dlD08QitZNEqSh0A(aiVcEzbv0cYTGDkakh28jdgQGslOQcYTGpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(ENcYTGkuqsUGjMY5ThcLZdoK)lyEEbtmM5WY6IFjBMHq(qiXp5g4OcEP0csKofusn)zO0dUdaZ18sCzkthdvqGdcqBkyMgg7eCapkkiAsGAEAfeN9febCcZiHOFIffu9cYdi8fcDOT2(0wO5N30MD0zQ57uayUM)xYMziKpesZBa(WshnVkY08Phe7bTMpaYRGxwqfTGClyNcGYHnFYGHkO0cQQGClyIPCE7Hq58Gd5)cYTGpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(ENcYTG3)ukOnm2j4aEuO5pdLEWDayUMxIltz6yOccCqaAtbvSlzZmeYhcvq0Ka180kio7lic4eMrcr)elkO6fKKAEWH8FbvVG8acFHqhARTFTfA(5nTzhDMA(ofaMR55SNbsyM13AEdWhw6O5vrMMp9GypO18OfbWjqco7zGewIt)eRGClyaKxbVSGwvqUfStbq5WMpzWqfuAbvvqUfKKlyIPCE7Hq58Gd5)cYTGpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(ENcYTG3)ukOnm2j4aEuuqUfmXyMdlRlsC6NyIFYnWrf8YcsMWkn)zO0dUdaZ18sCzkthdvqGdcqBkOI5Egivqfz9DbjTGKlN(jwbrtcuZtRG4SVGiGtygje9tSOGQxqN5Kaj18Gd5)cQEb5be(cHo0wROAl08ZBAZo6m18DkamxZN40pX08gGpS0rZRImnF6bXEqR5rlcGtGeC2ZajSeN(jwb5wWaiVcEzbTQGClyNcGYHnFYGHkO0cQQGClijxWet582dHY5bhY)fKBbFkF4SNyceGWxGXWXc2lpp2bZgWjqIjbkW99ofKBbV)PuWzpdKWmRV18NHsp4oamxZlXLPmDmubboiaTPGkM7zGubvK13fK0csUC6NyfenjqnpTcIZ(cIaoHzKq0pXIcQEbDMtcKuZdoK)lO6fKhq4le6qBn5uBHMVtbG5A(BwayUMFEtB2rNPo0wRImTfA(5nTzhDMA(0dI9GwZ)nXkiPf0(jtZ3PaWCnFI5sGAp7ry0T771H2AvQ0wO5N30MD0zQ5tpi2dAnpnfoUy(3etqDxqUf8BIvWllO9tMMVtbG5AE096hJHJr3OaWCDOTwvgAl08ZBAZo6m18Phe7bTMpXyMdlRl(LSzgc5dHe)KBGJk4LfunfKBbJ2mpe)s2mdHWA62pmxmVPn7O57uayUM)B57My6qBTk1OTqZpVPn7OZuZNEqSh0AEAkCCXVKnZqiFiK4WY6fKBbpJMchxGaJy0)AB7fhwwVG55fehqWjW(j3ahvWllOvKP57uayUMpXCjqTN9im62996qBTkfxBHMFEtB2rNPMp9GypO18pLpC2tmbc44ugme1tmX8M2Stb5wqI0r8tUboQGslizfKBbvOGk7h00MjMAxIkg2nNgTcMNxqfky0pXcraKhwWWUtbMASQGKwqfNScYTGrBMhI2j2Jj3Etm55HyEtB2PG55fm6NyHiaYdlyy3PatnwvqslO9twb5wqsUGrBMhI2j2Jj3Etm55HyEtB2PGswqjli3cQqbr3ZyWI(jwGez5aEtwGFkO0cQQG55fKMchxiVoWsM1k3lOUlOKA(ofaMR5)LSzgc5dH0H2AvwPTqZpVPn7OZuZNEqSh0A(NYho7jMygYJaTJjdi4eI5nTzNcYTGePJ4NCdCubLwqYki3cQqbtmM5WY6c096hJHJr3OaWCXp5g4OcEzbTQG55fmXyMdlRlq3RFmgogDJcaZf)KBGJkiPfmdYkOKfKBbvOGkuqAkCCbTHXogkuiOUlyEEbJ2mpeTtShtU9MyYZdX8M2StbZZl43Gd2uope95GeaVGKwqvKvqjlyEEbJ(jwicG8Wcg2bScsAbvrgzfmpVGk7h00MjMAxIkg2nNgTcMNxWOFIfIaipSGHDaRGxwqvwvqUf8BWbBkNhI(CqcGxqslOkYkOKfKBbvOGO7zmyr)elqISCaVjlWpfuAbvvW88cstHJlKxhyjZAL7fu3fusnFNcaZ18)s2mdH8Hq6qBTk7tBHMFEtB2rNPMp9GypO18KCbv2pOPntq5ajqnmZiMF6hmub5wqI0r8tUboQGslizfKBbvOGkuqAkCCbTHXogkuiOUlyEEbJ2mpeTtShtU9MyYZdX8M2StbZZl43Gd2uope95GeaVGKwqvKvqjlyEEbJ(jwicG8Wcg2bScsAbvrgzfmpVGk7h00MjMAxIkg2nNgTcMNxqAgcvqUfm6NyHiaYdlyyhWk4LfuLvfKBb)gCWMY5HOphKa4fK0cQISckzb5wqfki6Egdw0pXcKilhWBYc8tbLwqvfmpVG0u44c51bwYSw5Eb1DbLSGClOcfKKlyIPCE7HWx6zg2FkyEEbtmM5WY6IeZLa1E2JWOB33l(j3ahvqslygKvqj18DkamxZ)lzZmeYhcPdT1QSFTfA(5nTzhDMA(0dI9GwZ)u(WzpXeiaHVaJHJfSxEESdMnGtGetcuG77Dki3cE)tjgr6iuj(w(Ujwb5wqfkOcfKMchxqBySJHcfcQ7cMNxWOnZdr7e7XKBVjM88qmVPn7uW88c(n4GnLZdrFoibWliPfufzfuYcMNxWOFIfIaipSGHDaRGKwqvKrwbZZlOY(bnTzIP2LOIHDZPrRG55fm6NyHiaYdlyyhWk4LfuLvfKBb)gCWMY5HOphKa4fK0cQISckzb5wqfki6Egdw0pXcKilhWBYc8tbLwqvfmpVG0u44c51bwYSw5Eb1DbLuZ3PaWCn)VKnZqiFiKMNcnmgoogr6OTwLo0wRsr1wO5N30MD0zQ5tpi2dAnVzkNPGKwq1yFfKBbvOGO7zmyr)elqISCaVjlWpfK0cQQGClijxqAkCCH86alzwRCVG6UG55f8BWbBkNhI(CqcGxWllir6uqUfKKlinfoUqEDGLmRvUxqDxqj18DkamxZNLd4nzb(rhARvro1wO5N30MD0zQ57uayUMh4O0tfnTzysGQ9Gsg7mLG008Phe7bTMpXyMdlRl(LSzgc5dHe)KBGJkiPfufzfKBbvOG0u44IFjBMHq(qib1DbZZlindHki3cIdi4ey)KBGJk4LfmdvfmpVGr)elebqEybd7awbjTGQiNKvW88cstHJlOnm2XqHcb1DbLuZ7T808ahLEQOPndtcuThuYyNPeKMo0wNbzAl08ZBAZo6m18DkamxZNTTnFpcd)z(rZNEqSh0A(eJzoSSU4xYMziKpes8tUboQGKwqvKvqUfuHcstHJl(LSzgc5dHeu3fmpVG0meQGClioGGtG9tUboQGxwqvQPG55fm6NyHiaYdlyyhWkiPfuLAiRGsQ59wEA(STT57ry4pZp6qBDgQ0wO5N30MD0zQ57uayUMxUtn9pmeNTatMcbsA(0dI9GwZNymZHL1f)s2mdH8HqIFYnWrfK0cQIScYTGkuqAkCCXVKnZqiFiKG6UG55fKMHqfKBbXbeCcSFYnWrf8YcMHvfmpVGr)elebqEybd7awbjTGQurwbLuZ7T808YDQP)HH4SfyYuiqshARZidTfA(5nTzhDMA(ofaMR5zk3NLZmYaNa7MLDpw6jpkAJMp9GypO18jgZCyzDXVKnZqiFiK4NCdCubjTGQiRGClOcfKMchx8lzZmeYhcjOUlyEEbPziub5wqCabNa7NCdCubVSGQSVcMNxWOFIfIaipSGHDaRGKwqvKrwbLuZ7T808mL7ZYzgzGtGDZYUhl9KhfTrhARZqnAl08ZBAZo6m18DkamxZdCu8uPG9iSdqjWhg9mgnF6bXEqR5tmM5WY6IFjBMHq(qiXp5g4OcsAbvrwb5wqfkinfoU4xYMziKpesqDxW88csZqOcYTG4acob2p5g4OcEzbvrwbZZly0pXcraKhwWWoGvqsli50QckPM3B5P5bokEQuWEe2bOe4dJEgJo0wNHIRTqZpVPn7OZuZ3PaWCnpUPLhgdhJUJWmnF6bXEqR5tmM5WY6IFjBMHq(qiXp5g4OcsAbvrwb5wqfkinfoU4xYMziKpesqDxW88csZqOcYTG4acob2p5g4OcEzbvPQG55fm6NyHiaYdlyyhWkiPfufzKvqj18ElpnpUPLhgdhJUJWmDOTodR0wO5N30MD0zQ57uayUMNW0hqhShHr3hIP5tpi2dAnFIXmhwwx8lzZmeYhcj(j3ahvqslOkYki3cQqbPPWXf)s2mdH8HqcQ7cMNxqAgcvqUfehqWjW(j3ahvWllOkvfmpVGr)elebqEybd7awbjTG2NvfusnV3YtZty6dOd2JWO7dX0H26mSpTfA(5nTzhDMAEVLNMhL6hHXWXW)o27TbdfpaFA(ofaMR5rP(rymCm8VJ9EBWqXdWNo0wNH9RTqZ3PaWCnpfAyGyYin)8M2SJotDOTodfvBHMVtbG5AEAdJDWWPEYR5N30MD0zQdT1zqo1wO5N30MD0zQ5tpi2dAnpnfoU4xYMziKpesqDR57uayUMNEpAVnGtOdT1QHmTfA(5nTzhDMA(0dI9GwZttHJl(LSzgc5dHehwwVGCl4z0u44ceyeJ(xBBV4WY6A(ofaMR5nacobcJKyQdH88qhARvJkTfA(ofaMR5Xb)Onm2rZpVPn7OZuhARvtgAl08DkamxZ3EAO4BdwQngn)8M2SJotDOTwnQrBHMFEtB2rNPMp9GypO180u44IFjBMHq(qiXHL1li3cEgnfoUabgXO)122loSSEb5wqAkCCX8VjMG6wZ3PaWCnpDtGXWXIhKSH0H2A1O4Al08ZBAZo6m18Phe7bTMhDpJbl6NybsKLd4nzb(PGKwqvAEu8GuOTwLMVtbG5A(uBmyDkamhZaqHM3aqbM3YtZ3SPdT1QXkTfA(5nTzhDMA(ofaMR5FkhRtbG5ygak08gakW8wEAEeWjmdl6NyHo0HM)(xIjt3H2cT1Q0wO57uayUMNUJWmmehgvO5N30MD0zQdT1zOTqZpVPn7OZuZNEqSh0AEsUGpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(EhnFNcaZ18)s2mdH8Hq6qBTA0wO57uayUMpXCjqTN9im6299A(5nTzhDM6qh6qZRCpcWCT1zqwgzqwgzyFA(S97aNaP5jhKykwRjhTMKajQGf0coRGa5B2hfeN9f0UMn7k4pjqb(DkiIjVc2ubtUJDkyIt7edjQRkcWxbvjrfKCzUY9Xof0oeJYqd8JGeTRGbRG2HyugAGFeKOyEtB2XUcQGk1kPOUQiaFf0kjQGKlZvUp2PG29u(WzpXeKODfmyf0UNYho7jMGefZBAZo2vqfuPwjf116k5GetXAn5O1KeirfSGwWzfeiFZ(OG4SVG2HaoHzyr)elSRG)Kaf43PGiM8kytfm5o2PGjoTtmKOUQiaFfunsubjxMRCFStbTlXuoV9qqII5nTzh7kyWkODjMY5Thcs0UcQGk1kPOUQiaFfuXLOcsUmx5(yNcA3t5dN9etqI2vWGvq7EkF4SNycsumVPn7yxbvqLALuuxveGVcQsLevqYL5k3h7uq7I2mpeKODfmyf0UOnZdbjkM30MDSRGkOsTskQRkcWxbvPsIki5YCL7JDkODpLpC2tmbjAxbdwbT7P8HZEIjirX8M2SJDfubvQvsrDvra(kOk1irfKCzUY9Xof0UOnZdbjAxbdwbTlAZ8qqII5nTzh7kOcQuRKI6ADLCqIPyTMC0AscKOcwql4SccKVzFuqC2xq7odVPmHDf8NeOa)ofeXKxbBQGj3XofmXPDIHe1vfb4RGQrIki5YCL7JDkODrBMhcs0UcgScAx0M5HGefZBAZo2vqfuPwjf1vfb4RGkUevqYL5k3h7uq7EkF4SNycs0UcgScA3t5dN9etqII5nTzh7kOcQuRKI6QIa8vqfxIki5YCL7JDkODpLpC2tmbjAxbdwbT7P8HZEIjirX8M2SJDfSJckXvmurkOcQuRKI6QIa8vqfxIki5YCL7JDkODpLpC2tmbjAxbdwbT7P8HZEIjirX8M2SJDfubvQvsrDvra(kO9jrfKCzUY9Xof0Uet582dbjkM30MDSRGbRG2LykN3Eiir7kOcQuRKI6QIa8vq7xIki5YCL7JDkODjMY5ThcsumVPn7yxbdwbTlXuoV9qqI2vqfuPwjf1vfb4RGkQevqYL5k3h7uq7smLZBpeKOyEtB2XUcgScAxIPCE7HGeTRGkOsTskQRkcWxbvP4subjxMRCFStbTlAZ8qqI2vWGvq7I2mpeKOyEtB2XUcQqgQvsrDvra(kOkfxIki5YCL7JDkODpLpC2tmbjAxbdwbT7P8HZEIjirX8M2SJDfubvQvsrDvra(kOkRKOcsUmx5(yNcA3t5dN9etqI2vWGvq7EkF4SNycsumVPn7yxbvqLALuuxRRKJY3Sp2PGkEb7uayEbnauGe1vnp6EjT12FgA(7NHdmtZBp7vqfJup5li5q)pG91v7zVcssU)eNcQYYcMbzzKrDTUAp7vqYLt7edjr1v7zVcscfuIDo7uqssuYYZiQR2ZEfKekijna10MDkOmt5KNhf8IcQyUNbsfurwFxWuBmfubNff03o7uqC2xqGtceT8kyI5XuBiPOUAp7vqsOGKKzk3PGzA6Zqb7Lly7Ncss)nbZlOIL1FbBAMYvWmnm2j4aEuuWGvqG89ZuUcI)tcuZtKVGm8c(lXKLNF6aWCubvabKrf8zueCmKVGtcuTrsrD1E2RGKqbLyNZofmZocZkiphgvuWGvW7FjMmDhfuIrssre1v7zVcscfuIDo7uqscrRGKJXKrI6Q9SxbjHcAr212kio7li5ahWBYc8tbPho7xbnt5mfun2VOUAp7vqsOGk2jZuUtbL4i080qI6Q9SxbjHcssZC7IcsHwb5bJy0)AB7liaVGGWoubBZV(q(csDxqfiPxhCKBB7LuuxTN9kijuq(fu3feVTTcIMeOMNgQG4SVG8acFrbz3Z3lQR1v7zVckXv7suXofKE4SFfmXKP7OG0Ja4irbLyP0UdubDMtcC6xgNYuWofaMJkiZnKxux7uayosC)lXKP7qDPxq3ryggIdJkQRDkamhjU)LyY0DOU0l(LSzgc5dHSeGlLKFkF4SNyceGWxGXWXc2lpp2bZgWjqIjbkW99o11ofaMJe3)smz6oux6fjMlbQ9ShHr3UVVUwxTN9kOexTlrf7uWPCp5lyaKxbdoRGDkyFbbOc2kBGPPntuxTxbjxo9tSccWly2z3VcAyorbVBuuqg1xq2989wwq2xWSRGhMBxuqF7uWGZki7E((cMyY0ScIZ(cYdi8ffubN5Kaj18Gd5Fjf11ofaMJKM40pXSeGlnaYJufnppAZ8qCyu0MHfa5jM30MDYZ7uauoS5tgmePQYZtmLZBpekNhCi)NNtYpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(EN88eJzoSSU4xYMziKpes8tUboIuI0PU2PaWCK6sV4MswEM6ANcaZrQl9cL9dAAZS0B5jDQDjQyy3CA0SuzBOM0OnZdHCJqD6h3OFIfcoRnbhXDkUunwLNh9tSqWzTj4iUtXLzqwEE0pXcbN1MGJ4ofKQOKXnXuoV9qOCEWH8FDTtbG5i1LEHY(bnTzw6T8Ks5ajqnmZiMF6hmKLkBd1K(u(WzpXeiaHVaJHJfSxEESdMnGtGYZFkF4SNyceWXPmyiQNy55pLpC2tmXmKhbAhtgqWjQR2ZEf0coaubbOckZqHH8fmyf8(NY5rbtmM5WY6OcI)m5cspGtuWoLaN5rBmKVGuODk4H6borbLzkN88quxTN9kyNcaZrQl9INYX6uayoMbGcl9wEsLzkN88WsaUuzMYjppehakApnsTQUAp7vWofaMJux6fC2ZajmZ6Blb4sv4BWbBkNhczMYjppehakApnsZWkUFdoyt58qiZuo55Ha4KQ4wjzD1E2RGDkamhPU0lqtcuZtZsaU0ofaLdB(Kbdjvf3et582dHY5bhY)I5nTzhUpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(Ehl9wEsZ0cUk2LSjr0gg7eCapkKOFjBMHq(qO6Q9kOexMY0Xqfe4Ga0McMPHXobhWJIcIMeOMNwbXzFbraNWmsi6NyrbvVG8acFHOU2PaWCK6sVG2WyNGd4rHLgGpS0rQkYSeGlnaY7sfLBNcGYHnFYGHKQI7t5dN9etGae(cmgowWE55Xoy2aobsmjqbUV3HRcKCIPCE7Hq58Gd5)88eJzoSSU4xYMziKpes8tUbo6sPePJK1v7vqjUmLPJHkiWbbOnfuXUKnZqiFiubrtcuZtRG4SVGiGtygje9tSOGQxqsQ5bhY)fu9cYdi8fI6ANcaZrQl9IFjBMHq(qilnaFyPJuvKzjaxAaK3Lkk3ofaLdB(Kbdjvf3et582dHY5bhY)I5nTzhUpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(EhU3)ukOnm2j4aEuuxTN9kyNcaZrQl9c0Ka180SeGlTtbq5WMpzWqsvXLKtmLZBpekNhCi)lM30MD4(u(WzpXeiaHVaJHJfSxEESdMnGtGetcuG77DS0B5jntl4sUC6NyseTHXobhWJcjIZEgiHL40pXQR2RGsCzkthdvqGdcqBkOI5Egivqfz9DbjTGKlN(jwbrtcuZtRG4SVGiGtygje9tSOGQxqN5Kaj18Gd5)cQEb5be(crDTtbG5i1LEbN9mqcZS(2sdWhw6ivfzwcWLIweaNaj4SNbsyjo9tmUbqExAf3ofaLdB(KbdjvfxsoXuoV9qOCEWH8VyEtB2H7t5dN9etGae(cmgowWE55Xoy2aobsmjqbUV3H79pLcAdJDcoGhfCtmM5WY6IeN(jM4NCdC0LKjSQUAVckXLPmDmubboiaTPGkM7zGubvK13fK0csUC6NyfenjqnpTcIZ(cIaoHzKq0pXIcQEbDMtcKuZdoK)lO6fKhq4le11ofaMJux6fjo9tmlnaFyPJuvKzjaxkAraCcKGZEgiHL40pX4ga5DPvC7uauoS5tgmKuvCj5et582dHY5bhY)I5nTzhUpLpC2tmbcq4lWy4yb7LNh7Gzd4eiXKaf4(EhU3)uk4SNbsyM1311ofaMJux6f3SaW86ANcaZrQl9IeZLa1E2JWOB33Bjax63eJu7NS6ANcaZrQl9c096hJHJr3OaWClb4sPPWXfZ)MycQBUFtSlTFYQRDkamhPU0l(w(UjMLaCPjgZCyzDXVKnZqiFiK4NCdC0LQHB0M5H4xYMziewt3(H5I5nTzN6ANcaZrQl9IeZLa1E2JWOB33BjaxknfoU4xYMziKpesCyzDUNrtHJlqGrm6FTT9IdlRNNJdi4ey)KBGJU0kYQRDkamhPU0l(LSzgc5dHSeGl9P8HZEIjqahNYGHOEIXLiDe)KBGJKsgxfu2pOPntm1UevmSBonA55ke9tSqea5HfmS7uGPgRivXjJB0M5HODI9yYT3etEEKNh9tSqea5HfmS7uGPgRi1(jJljhTzEiANypMC7nXKNhskjxfq3ZyWI(jwGez5aEtwGFKQkpNMchxiVoWsM1k3lOULSU2PaWCK6sV4xYMziKpeYsaU0NYho7jMygYJaTJjdi4eCjshXp5g4iPKXvHeJzoSSUaDV(Xy4y0nkamx8tUbo6sRYZtmM5WY6c096hJHJr3OaWCXp5g4isZGmj5QGc0u44cAdJDmuOqqDNNhTzEiANypMC7nXKNhI5nTzN88VbhSPCEi6ZbjaoPQitY88OFIfIaipSGHDaJuvKrwEUY(bnTzIP2LOIHDZPrlpp6NyHiaYdlyyhWUuLvC)gCWMY5HOphKa4KQImj5Qa6Egdw0pXcKilhWBYc8Juv550u44c51bwYSw5Eb1TK11ofaMJux6f)s2mdH8HqwcWLsYk7h00MjOCGeOgMzeZp9dgIlr6i(j3ahjLmUkOanfoUG2Wyhdfkeu355rBMhI2j2Jj3Etm55HyEtB2jp)BWbBkNhI(CqcGtQkYKmpp6NyHiaYdlyyhWivfzKLNRSFqtBMyQDjQyy3CA0YZPzie3OFIfIaipSGHDa7svwX9BWbBkNhI(CqcGtQkYKKRcO7zmyr)elqISCaVjlWpsvLNttHJlKxhyjZAL7fu3sYvbsoXuoV9q4l9md7p55jgZCyzDrI5sGAp7ry0T77f)KBGJindYKSU2PaWCK6sV4xYMziKpeYsk0Wy44yePJuvwcWL(u(WzpXeiaHVaJHJfSxEESdMnGtGetcuG77D4E)tjgr6iuj(w(UjgxfuGMchxqBySJHcfcQ788OnZdr7e7XKBVjM88qmVPn7KN)n4GnLZdrFoibWjvfzsMNh9tSqea5HfmSdyKQImYYZv2pOPntm1UevmSBonA55r)elebqEybd7a2LQSI73Gd2uope95GeaNuvKjjxfq3ZyWI(jwGez5aEtwGFKQkpNMchxiVoWsM1k3lOULSU2PaWCK6sVilhWBYc8JLaCPMPCgsvJ9Xvb09mgSOFIfirwoG3Kf4hsvXLKPPWXfYRdSKzTY9cQ788VbhSPCEi6Zbja(LePdxsMMchxiVoWsM1k3lOULSU2PaWCK6sVGcnmqmzl9wEsbok9urtBgMeOApOKXotjinlb4stmM5WY6IFjBMHq(qiXp5g4isvrgxfOPWXf)s2mdH8HqcQ78CAgcXfhqWjW(j3ahDzgQYZJ(jwicG8Wcg2bmsvrojlpNMchxqBySJHcfcQBjRRDkamhPU0lOqddet2sVLN0STT57ry4pZpwcWLMymZHL1f)s2mdH8HqIFYnWrKQImUkqtHJl(LSzgc5dHeu3550meIloGGtG9tUbo6svQjpp6NyHiaYdlyyhWivLAitY6ANcaZrQl9ck0WaXKT0B5jvUtn9pmeNTatMcbswcWLMymZHL1f)s2mdH8HqIFYnWrKQImUkqtHJl(LSzgc5dHeu3550meIloGGtG9tUbo6YmSkpp6NyHiaYdlyyhWivLkYKSU2PaWCK6sVGcnmqmzl9wEszk3NLZmYaNa7MLDpw6jpkAJLaCPjgZCyzDXVKnZqiFiK4NCdCePQiJRc0u44IFjBMHq(qib1DEondH4Idi4ey)KBGJUuL9LNh9tSqea5HfmSdyKQImYKSU2PaWCK6sVGcnmqmzl9wEsbokEQuWEe2bOe4dJEgJLaCPjgZCyzDXVKnZqiFiK4NCdCePQiJRc0u44IFjBMHq(qib1DEondH4Idi4ey)KBGJUufz55r)elebqEybd7agPKtRKSU2PaWCK6sVGcnmqmzl9wEsXnT8Wy4y0DeMzjaxAIXmhwwx8lzZmeYhcj(j3ahrQkY4QanfoU4xYMziKpesqDNNtZqiU4acob2p5g4OlvPkpp6NyHiaYdlyyhWivfzKjzDTtbG5i1LEbfAyGyYw6T8Ksy6dOd2JWO7dXSeGlnXyMdlRl(LSzgc5dHe)KBGJivfzCvGMchx8lzZmeYhcjOUZZPziexCabNa7NCdC0LQuLNh9tSqea5HfmSdyKAFwjzDTtbG5i1LEbfAyGyYw6T8KIs9JWy4y4Fh792GHIhGV6ANcaZrQl9ck0WaXKr11ofaMJux6f0gg7GHt9KVU2PaWCK6sVGEpAVnGtyjaxknfoU4xYMziKpesqDxx7uayosDPxyaeCcegjXuhc55HLaCP0u44IFjBMHq(qiXHL15EgnfoUabgXO)122loSSEDTtbG5i1LEbo4hTHXo11ofaMJux6fTNgk(2GLAJPU2PaWCK6sVGUjWy4yXds2qwcWLstHJl(LSzgc5dHehwwN7z0u44ceyeJ(xBBV4WY6CPPWXfZ)MycQ76ANcaZrQl9IuBmyDkamhZaqHLO4bPqQkl9wEsB2SeGlfDpJbl6NybsKLd4nzb(Huv11ofaMJux6fpLJ1PaWCmdafw6T8KIaoHzyr)elQR11ofaMJenBstTNMbJMch3sVLNuAtFgkyVSLaCPePJ4NCdCKuY4IyugAGFe4GhfyO4b2gxAkCCbo4rbgkEGTj(j3ahXLMchxm)BIj(j3ahDjr6ux7uayos0SPU0lApbMhynEShXHLSzjaxknfoUy(3etqDZnXyMdlRl(LSzgc5dHe)KBGJi1Q6ANcaZrIMn1LEb6E9JXWXOBuayULaCP0u44I5Ftmb1n3Vj2Lkoz11ofaMJenBQl9cAtFgkyVSLap2)u3bgaxkr6i(j3ahjLmUigLHg4hbo4rbgkEGTXLMchxGdEuGHIhyBIFYnWrCPPWXfZ)MyIFYnWrxsKowcWLstHJlM)nXeu3Cr3ZyWI(jwGez5aEtwGFinJ6ANcaZrIMn1LErI5Nj7wcWLQanfoUy(3etqDNNttHJl(LSzgc5dHeu3CFkF4SNyceWXPmyiQNysYvz)GM2mXu7suXWU50Ovx7uayos0SPU0lqGrm6FTT911ofaMJenBQl9IVLVBIvx7uayos0SPU0lq3RFmgogDJcaZTeGlLMchxm)BIjOU5MymZHL1f)s2mdH8HqIFYnWrKAvDTtbG5irZM6sVG20NHc2lBjaxknfoUy(3et8tUboIuI0rXGmewvxRRDkamhjqaNWmSOFIfQl9IVjaobgTHL1saU0NYho7jMilWyWy4ybNHrVhT32EXKaf4(EhU0u44ISaJbJHJfCgg9E0EB7f)KBGJUKiDQRDkamhjqaNWmSOFIfQl9I0tH4aCcmAdlRLaCPpLpC2tmrwGXGXWXcodJEpAVT9IjbkW99oCPPWXfzbgdgdhl4mm69O922l(j3ahDjr6ux7uayosGaoHzyr)elux6fP2tZGrtHJBP3YtkTPpdfSx2saUu09mgSOFIfirwoG3Kf4hPQ4sKoIFYnWrsjJRcrBMhc5gH60pX8M2StEEIPCE7Hq58Gd5FX8M2SJKCv2pOPntm1UevmSBonACv4BIrk5KS8CsoXyMdlRlsm)mzx8tUbosY6ANcaZrceWjmdl6NyH6sViX8ZKDlb4svGMchxm)BIjOUZZPPWXf)s2mdH8HqcQBUpLpC2tmbc44ugme1tmj5QSFqtBMyQDjQyy3CA0QRDkamhjqaNWmSOFIfQl9ceyeJ(xBBVLaCPNrtHJlqGrm6FTT9IdlRZvb09mgSOFIfirwoG3Kf4hsvLN)n4GnLZdrFoibWjvLvswx7uayosGaoHzyr)elux6fFlF3eZsaUuAkCCXVKnZqiFiKG6opxbAkCCX8VjM4NCdC0LePtE(3eJufLmjZZPPWXf4)CsIiV4NCdC0LQewvx7uayosGaoHzyr)elux6fPNcXb4ey0gwwlb4srlWOzofseG9zOOyzCNYZtC6NyiPzKNRanfoU4xYMziKpesqDZvz)GM2mXu7suXWU50OXnAZ8qi3iuN(jM30MDKSU2PaWCKabCcZWI(jwOU0lsm)mzVU2PaWCKabCcZWI(jwOU0lApbMhynEShXHLSzjaxknfoUy(3etqDZnXyMdlRl(LSzgc5dHe)KBGJi1kUke9tSqea5HfmSdyKsoTkpNMchx8lzZmeYhcjOUZZJ(jwicG8Wcg2bSlZGmj5(n4GnLZdrFoibWj1(TQU2PaWCKabCcZWI(jwOU0lMAxIkwDTtbG5ibc4eMHf9tSqDPxGUx)ymCm6gfaMBjax6t5dN9etmd5rG2XKbeCcU0u44I5Ftmb1n3eJzoSSU4xYMziKpes8tUboIuR4QanfoU4xYMziKpesqDNNh9tSqea5HfmSdyxMbz55NrtHJlqGrm6FTT9cQ78CsoAZ8qGaJy0)AB75g9tSqea5HfmSdyKAFkQKC)gCWMY5HOphKa4KALv11ofaMJeiGtygw0pXc1LEbTPpdfSx2saUuAkCCX8VjMG6MRcKmnfoU4xYMziKpes8tUbokp)BIDPvKjjxfq3ZyWI(jwGez5aEtwGFKQI73Gd2uope95GeaNuf3Q8C09mgSOFIfirwoG3Kf4hPzizDTtbG5ibc4eMHf9tSqDPxGUx)ymCm6gfaMBjaxknfoUy(3etqDZnXyMdlRl(LSzgc5dHe)KBGJi1kUkqtHJl(LSzgc5dHeu355r)elebqEybd7a2LzqwE(z0u44ceyeJ(xBBVG6opNKJ2mpeiWig9V22EUr)elebqEybd7agP2NIkj3VbhSPCEi6ZbjaoPwzvDTtbG5ibc4eMHf9tSqDPx8nbWjWOnSSwcWLIwGrZCkKia7ZqrXY4oLNN40pXqsZipxbAkCCXVKnZqiFiKG6MRY(bnTzIP2LOIHDZPrJB0M5HqUrOo9tmVPn7izDTtbG5ibc4eMHf9tSqDPxqByStWb8OWYe5tMHf9tSajvLLaCP0u44I5FtmXHL1ZZtm)qbcHsqcWOqyjMht(oeF72i1kUr)eleCwBcoI7uCPASQU2PaWCKabCcZWI(jwOU0lOnm2HUdowcWLstHJlM)nXehwwpppX8dfiekbjaJcHLyEm57q8TBJuR4g9tSqWzTj4iUtXLQXQ6ANcaZrceWjmdl6NyH6sV48nbZXEw)wcWLstHJlM)nXeu3CvaDpJbl6NybsKLd4nzb(Huv55Fdoyt58q0NdsaCsvzLK11ofaMJeiGtygw0pXc1LErwoG3Kf4hlb4sPPWXfY7taZqimAMpIh4N9cQBUO7zmyr)elqISCaVjlWpKQM6ANcaZrceWjmdl6NyH6sVG5ittrWjSeGlLMchxm)BIjOURRDkamhjqaNWmSOFIfQl9cAdJDcoGhf11ofaMJeiGtygw0pXc1LEbTHXo0DWPU2PaWCKabCcZWI(jwOU0l(Ma4ey0gw26ANcaZrceWjmdl6NyH6sVi9uioaNaJ2WYwx7uayosGaoHzyr)elux6fz5aEtwGF0Ho0Aa]] )


end
