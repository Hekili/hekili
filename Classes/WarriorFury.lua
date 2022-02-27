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


    spec:RegisterPack( "Fury", 20220226, [[d4ezBbqier9ikbBcv6tuknksWPiIwfjubVIKQzrj6wic2fHFjk1WqKogjzzKuEMkHMgjuUgLITPsqFtLaJJesNdrvADeHmpvIUhrAFikhKiuwOOKhIOQMiIi1fjcvBere8rsOIgjjuPtIOkALQKMjje3erePDsj1pjHk0qrerTusOQNIQMkLKRIiczRiIKVIOkmweH2lP(lugmOdl1IrQhlYKvXLv2mcFgQgnQ40aRgreXRPunBkUnrTBQ(nkdxL64eblxvphY0fUos2oj67IIXtj05ruz9iIqnFr1(LSwL2kn)PJPTwnsvtnsvtTluOMk1ut1fO5dYDpn)DNS34tZ7T808KeOEYP5VBYzy9rBLMhXO(008CI4gjrzNnoi4qrlsm5SrazkthaMN(MiYgbKtzR5PPaMG8010A(thtBTAKQMAKQMAxOqnvQPMkftZ3ubh2R55bYKFbZUGsSpXbihGNH08CaNZCnTM)musZtsG6jxbjp6)bSVUssy0pv)KRGQzJLfunsvtT6ADL850o(qsuDLekOe7C2PGKKPKLNruxjHcssdqnTzNckZuo55rbZUGkU7zGubvK13fm1gtbvWzrb9TZofKG9fe4KaElVcMyEmlgskQRKqbjjLPCNcMLPpdfSxUGTFkij934mVGkEw)fSPzkxbZYWyNGd4rrbdwbbY3pt5kiXpjqnprUcYik4VetwE(PdaZrfubeqgvWNrHZXqUcojq1gjf1vsOGsSZzNcMvhHzfKNdJkkyWk49VetMUJckXijRiI6kjuqj25StbjjcTcsEgtgjQRKqbTkZA7fKG9fK8Gd4nza(PG0JG9RGMPCMcEXlquxjHcQ4Nmt5ofuIJqZtdjQRKqbjPzUTrbPqRG8GHp6FT99fequqqylQGT5xFixbPUlOcK0RdoYT99skQRKqb5xqDxqI2(kiAsGAEAOcsW(cYdW9ffKDpFVqZBaOaPTsZ3SPTsBTkTvA(5nTzhDwA(0dI9GwZJNoIFYnWrfuAbjTGCliIrzOb(rqaEuGHIhyFI5nTzNcYTG0ueeccWJcmu8a7t8tUboQGClinfbHy(34t8tUboQGxwq80rZ3PaWCnFQ90my0ueeAEAkccmVLNMN20NHc2lRdT1QPTsZpVPn7OZsZNEqSh0AEAkccX8VXNG6UGClyIXmhwgx8lz3meYhcj(j3ahvqYkOnA(ofaMR5BpbMhynrShXHLSRdT1xuBLMFEtB2rNLMp9GypO180ueeI5FJpb1Db5wWVXxbVSGkgPA(ofaMR5r3RFmgbgDJcaZ1H2AftBLMFEtB2rNLMp9GypO180ueeI5FJpb1Db5wq09mgSOF8firgoG3Kb4NcswbvtZ3PaWCnpTPpdfSxwZd8y)tDhyacnpE6i(j3ahjLuUigLHg4hbb4rbgkEG9XLMIGqqaEuGHIhyFIFYnWrCPPiieZ)gFIFYnWrxINo6qBTnAR08ZBAZo6S08Phe7bTMxHcstrqiM)n(eu3fmpVG0ueeIFj7MHq(qib1Db5wWNYhb7XNabCckdgI6XNyEtB2PGswqUfuz)GM2mXS4suXWU50OP57uayUMpX8ZKDDOT(c1wP57uayUMhbg(O)123R5N30MD0zPdT1xG2knFNcaZ18FlF34tZpVPn7OZshARvuTvA(5nTzhDwA(0dI9GwZttrqiM)n(eu3fKBbtmM5WY4IFj7MHq(qiXp5g4OcswbTrZ3PaWCnp6E9JXiWOBuayUo0wtE1wP5N30MD0zP5tpi2dAnpnfbHy(34t8tUboQGKvq80PGkouq1e2O57uayUMN20NHc2lRdDO5rah3mSOF8fAR0wRsBLMFEtB2rNLMp9GypO18pLpc2JprgGXGXiWcodJEpAV99IjbkW99ofKBbPPiiezagdgJal4mm69O923l(j3ahvWlliE6O57uayUM)BCGJJrByz0H2A10wP5N30MD0zP5tpi2dAn)t5JG94tKbymymcSGZWO3J2BFVysGcCFVtb5wqAkccrgGXGXiWcodJEpAV99IFYnWrf8YcINoA(ofaMR5)gh44y0gwgDOT(IAR08ZBAZo6S08Phe7bTMhDpJbl6hFbsKHd4nza(PGslOQcYTG4PJ4NCdCubLwqsli3cQqbJ2mpeYnc1PFI5nTzNcMNxWet582dHY5bhY9fuYcYTGk7h00MjMfxIkg2nNgTcYTGkuWVXxbjRGKxslyEEbj5cMymZHLXfjMFMSl(j3ahvqj18DkamxZNApndgnfbHMNMIGaZB5P5Pn9zOG9Y6qBTIPTsZpVPn7OZsZNEqSh0AEfkinfbHy(34tqDxW88cstrqi(LSBgc5dHeu3fKBbFkFeShFceWjOmyiQhFI5nTzNckzb5wqL9dAAZeZIlrfd7MtJMMVtbG5A(eZpt21H2AB0wP5N30MD0zP5tpi2dAn)z0ueecey4J(xBFV4WY4fKBbvOGO7zmyr)4lqImCaVjdWpfKScQQG55f8BWbBkNhI(CqcGxqYkOkBkOKA(ofaMR5rGHp6FT996qB9fQTsZpVPn7OZsZNEqSh0AEAkccXVKDZqiFiKG6UG55fuHcstrqiM)n(e)KBGJk4LfepDkyEEb)gFfKScQOKwqjlyEEbPPiiee)CsIjN4NCdCubVSGQe2O57uayUM)B57gF6qB9fOTsZ3PaWCnFI5Nj7A(5nTzhDw6qBTIQTsZpVPn7OZsZNEqSh0AEAkccX8VXNG6UGClyIXmhwgx8lz3meYhcj(j3ahvqYkOnfKBbvOGr)4lebqEybd7awbjRGKxBkyEEbPPiie)s2ndH8HqcQ7cMNxWOF8fIaipSGHDaRGxwq1iTGswqUf8BWbBkNhI(CqcGxqYk4fyJMVtbG5A(2tG5bwte7rCyj76qBn5vBLMVtbG5A(zXLOIP5N30MD0zPdT1QivBLMFEtB2rNLMp9GypO18pLpc2JpXmKdbAhtgGZjeZBAZofKBbPPiieZ)gFcQ7cYTGjgZCyzCXVKDZqiFiK4NCdCubjRG2uqUfuHcstrqi(LSBgc5dHeu3fmpVGr)4lebqEybd7awbVSGQrAbZZl4z0ueecey4J(xBFVG6UG55fKKly0M5Habg(O)123lM30MDki3cg9JVqea5HfmSdyfKScEHkAbLSGCl43Gd2uope95GeaVGKvqBSrZ3PaWCnp6E9JXiWOBuayUo0wRsL2kn)8M2SJolnF6bXEqR5PPiieZ)gFcQ7cYTGkuqsUG0ueeIFj7MHq(qiXp5g4OcMNxWVXxbVSG2qAbLSGClOcfeDpJbl6hFbsKHd4nza(PGslOQcYTGFdoyt58q0Ndsa8cswbvmBkyEEbr3ZyWI(XxGez4aEtgGFkO0cQwbLuZ3PaWCnpTPpdfSxwhARvPM2kn)8M2SJolnF6bXEqR5PPiieZ)gFcQ7cYTGjgZCyzCXVKDZqiFiK4NCdCubjRG2uqUfuHcstrqi(LSBgc5dHeu3fmpVGr)4lebqEybd7awbVSGQrAbZZl4z0ueecey4J(xBFVG6UG55fKKly0M5Habg(O)123lM30MDki3cg9JVqea5HfmSdyfKScEHkAbLSGCl43Gd2uope95GeaVGKvqBSrZ3PaWCnp6E9JXiWOBuayUo0wR6IAR08ZBAZo6S08DkamxZtByStWb8OqZNEqSh0AEAkccX8VXN4WY4fmpVGjMFOaHqjibyuiSeZJjFhIVD7fKScAtb5wWOF8fcoRnbhXDkk4Lf8I2O5tKlzgw0p(cK2Av6qBTkftBLMFEtB2rNLMp9GypO180ueeI5FJpXHLXlyEEbtm)qbcHsqcWOqyjMht(oeF72lizf0McYTGr)4leCwBcoI7uuWll4fTrZ3PaWCnpTHXobhWJcDOTwLnAR08ZBAZo6S08Phe7bTMNMIGqm)B8jOUli3cQqbr3ZyWI(XxGez4aEtgGFkizfuvbZZl43Gd2uope95GeaVGKvqv2uqj18DkamxZF(gN5ypRFDOTw1fQTsZpVPn7OZsZNEqSh0AEAkccH8(eWmecJM5d)b(zVG6UGCli6Egdw0p(cKidhWBYa8tbjRGxuZ3PaWCnFgoG3Kb4hDOTw1fOTsZpVPn7OZsZNEqSh0AE0cmAMtHebyVAkkMA3PcMNxWeN(XhQGslOAfmpVGkuqAkccXVKDZqiFiKG6UGClOY(bnTzIzXLOIHDZPrRGCly0M5HqUrOo9tmVPn7uqj18DkamxZ)noWXXOnSm6qBTkfvBLMFEtB2rNLMp9GypO18Ofy0mNcjcWE1uum1UtfmpVGjo9JpubLwq1kyEEbvOG0ueeIFj7MHq(qib1Db5wqL9dAAZeZIlrfd7MtJwb5wWOnZdHCJqD6NyEtB2PGsQ57uayUM)BCGJJrByz0H2AvKxTvA(5nTzhDwA(0dI9GwZttrqiM)n(eu3A(ofaMR5zoY0u4CcDOTwns1wP5N30MD0zP57uayUMN2WyNGd4rHMp9GypO180ueeI5FJpXHLX18jYLmdl6hFbsBTkDOTwnvAR08DkamxZtByStWb8OqZpVPn7OZshARvtnTvA(ofaMR5Pnm2j4aEuO5N30MD0zPdT1QDrTvA(ofaMR5)gh44y0gwgn)8M2SJolDOTwnftBLMVtbG5A(VXboogTHLrZpVPn7OZshARvZgTvA(ofaMR5ZWb8Mma)O5N30MD0zPdDO5pJOPmH2kT1Q0wP5N30MD0zP57uayUMpXPF8P5pdLEWDayUMN850p(kiGOGzMT)kOH54f8UrrbzuFbz3Z3BzbzFbZScEyUTrb9TtbdoRGS757lyIjtZkib7lipa3xuqfCMtcKuZdoK7LuO5tpi2dAnFaKxbjRGkAbZZly0M5H4WOOndlaYtmVPn7uW88c2PaOCyZNmyOcswbvvW88cMykN3Eiuop4qUVG55fKKl4t5JG94tGa4(cmgbwWE55Xoy2boosmjqbUV3PG55fmXyMdlJl(LSBgc5dHe)KBGJkizfepD0H2A10wP57uayUM)MswEgn)8M2SJolDOT(IAR08ZBAZo6S08SBnpAHMVtbG5AEL9dAAZ08kBd108rBMhc5gH60pX8M2Stb5wWOF8fcoRnbhXDkk4Lf8I2uW88cg9JVqWzTj4iUtrbVSGQrAbZZly0p(cbN1MGJ4offKScQOKwqUfmXuoV9qOCEWHCVMxz)yElpn)S4suXWU50OPdT1kM2kn)8M2SJolnp7wZJwO57uayUMxz)GM2mnVY2qnn)t5JG94tGa4(cmgbwWE55Xoy2boosmVPn7uW88c(u(iyp(eiGtqzWqup(eZBAZofmpVGpLpc2JpXmKdbAhtgGZjeZBAZoAEL9J5T808uoqcudZm85N(bdPdT12OTsZpVPn7OZsZ3PaWCnpTHXobhWJcnVb4dlD08QivZNEqSh0A(aiVcEzbv0cYTGDkakh28jdgQGslOQcYTGpLpc2JpbcG7lWyeyb7LNh7Gzh44iXKaf4(ENcYTGkuqsUGjMY5ThcLZdoK7lyEEbtmM5WY4IFj7MHq(qiXp5g4OcEP0cINofusn)zO0dUdaZ18sCzkthdvqGdcqBkywgg7eCapkkiAsGAEAfKG9febCCZiHOF8ffu9cYdW9fcDOT(c1wP5N30MD0zP57uayUM)xYUziKpesZBa(WshnVks18Phe7bTMpaYRGxwqfTGClyNcGYHnFYGHkO0cQQGClyIPCE7Hq58Gd5(cYTGpLpc2JpbcG7lWyeyb7LNh7Gzh44iXKaf4(ENcYTG3)ukOnm2j4aEuO5pdLEWDayUMxIltz6yOccCqaAtbv8lz3meYhcvq0Ka180kib7lic44Mrcr)4lkO6fKKAEWHCFbvVG8aCFHqhARVaTvA(5nTzhDwA(ofaMR55SNbsyM13AEdWhw6O5vrQMp9GypO18OfbWXrco7zGewIt)4RGClyaKxbVSG2uqUfStbq5WMpzWqfuAbvvqUfKKlyIPCE7Hq58Gd5(cYTGpLpc2JpbcG7lWyeyb7LNh7Gzh44iXKaf4(ENcYTG3)ukOnm2j4aEuuqUfmXyMdlJlsC6hFIFYnWrf8YcsQWgn)zO0dUdaZ18sCzkthdvqGdcqBkOI7Egivqfz9DbjRGKpN(XxbrtcuZtRGeSVGiGJBgje9JVOGQxqN5Kaj18Gd5(cQEb5b4(cHo0wROAR08ZBAZo6S08DkamxZN40p(08gGpS0rZRIunF6bXEqR5rlcGJJeC2ZajSeN(Xxb5wWaiVcEzbTPGClyNcGYHnFYGHkO0cQQGClijxWet582dHY5bhY9fKBbFkFeShFcea3xGXiWc2lpp2bZoWXrIjbkW99ofKBbV)PuWzpdKWmRV18NHsp4oamxZlXLPmDmubboiaTPGkU7zGubvK13fKScs(C6hFfenjqnpTcsW(cIaoUzKq0p(IcQEbDMtcKuZdoK7lO6fKhG7le6qBn5vBLMVtbG5A(BwayUMFEtB2rNLo0wRIuTvA(5nTzhDwA(0dI9GwZ)n(kizf8civZ3PaWCnFI5sGAp7ry0T771H2AvQ0wP5N30MD0zP5tpi2dAnpnfbHy(34tqDxqUf8B8vWll4fqQMVtbG5AE096hJrGr3OaWCDOTwLAAR08ZBAZo6S08Phe7bTMpXyMdlJl(LSBgc5dHe)KBGJk4Lf8IfKBbJ2mpe)s2ndHWA62pmxmVPn7O57uayUM)B57gF6qBTQlQTsZpVPn7OZsZNEqSh0AEAkccXVKDZqiFiK4WY4fKBbpJMIGqGadF0)A77fhwgVG55fKaGZjW(j3ahvWllOnKQ57uayUMpXCjqTN9im62996qBTkftBLMFEtB2rNLMp9GypO18pLpc2Jpbc4eugme1JpX8M2Stb5wq80r8tUboQGsliPfKBbvOGk7h00MjMfxIkg2nNgTcMNxqfky0p(craKhwWWUtb2fTPGKvqfJ0cYTGrBMhI2X3Jj3EJp55HyEtB2PG55fm6hFHiaYdlyy3Pa7I2uqYk4fqAb5wqsUGrBMhI2X3Jj3EJp55HyEtB2PGswqjli3cQqbr3ZyWI(XxGez4aEtgGFkO0cQQG55fKMIGqiVoWsM1k3lOUlOKA(ofaMR5)LSBgc5dH0H2Av2OTsZpVPn7OZsZNEqSh0A(NYhb7XNygYHaTJjdW5eI5nTzNcYTG4PJ4NCdCubLwqsli3cQqbtmM5WY4c096hJrGr3OaWCXp5g4OcEzbTPG55fmXyMdlJlq3RFmgbgDJcaZf)KBGJkizfunslOKfKBbvOGkuqAkccbTHXogkuiOUlyEEbJ2mpeTJVhtU9gFYZdX8M2StbZZl43Gd2uope95GeaVGKvqvKwqjlyEEbJ(XxicG8Wcg2bScswbvrkPfmpVGk7h00MjMfxIkg2nNgTcMNxWOF8fIaipSGHDaRGxwqv2uqUf8BWbBkNhI(CqcGxqYkOkslOKfKBbvOGO7zmyr)4lqImCaVjdWpfuAbvvW88cstrqiKxhyjZAL7fu3fusnFNcaZ18)s2ndH8Hq6qBTQluBLMFEtB2rNLMp9GypO18KCbv2pOPntq5ajqnmZWNF6hmub5wq80r8tUboQGsliPfKBbvOGkuqAkccbTHXogkuiOUlyEEbJ2mpeTJVhtU9gFYZdX8M2StbZZl43Gd2uope95GeaVGKvqvKwqjlyEEbJ(XxicG8Wcg2bScswbvrkPfmpVGk7h00MjMfxIkg2nNgTcMNxqAgcvqUfm6hFHiaYdlyyhWk4LfuLnfKBb)gCWMY5HOphKa4fKScQI0ckzb5wqfki6Egdw0p(cKidhWBYa8tbLwqvfmpVG0ueec51bwYSw5Eb1DbLSGClOcfKKlyIPCE7HWx6zg2FkyEEbtmM5WY4IeZLa1E2JWOB33l(j3ahvqYkOAKwqj18DkamxZ)lz3meYhcPdT1QUaTvA(5nTzhDwA(0dI9GwZ)u(iyp(eiaUVaJrGfSxEESdMDGJJetcuG77Dki3cE)tjgE6iuj(w(UXxb5wqfkOcfKMIGqqBySJHcfcQ7cMNxWOnZdr747XKBVXN88qmVPn7uW88c(n4GnLZdrFoibWlizfufPfuYcMNxWOF8fIaipSGHDaRGKvqvKsAbZZlOY(bnTzIzXLOIHDZPrRG55fm6hFHiaYdlyyhWk4LfuLnfKBb)gCWMY5HOphKa4fKScQI0ckzb5wqfki6Egdw0p(cKidhWBYa8tbLwqvfmpVG0ueec51bwYSw5Eb1DbLuZ3PaWCn)VKDZqiFiKMNcnmgbbgE6OTwLo0wRsr1wP5N30MD0zP5tpi2dAnVzkNPGKvWlEHfKBbvOGO7zmyr)4lqImCaVjdWpfKScQQGClijxqAkccH86alzwRCVG6UG55f8BWbBkNhI(CqcGxWlliE6uqUfKKlinfbHqEDGLmRvUxqDxqj18DkamxZNHd4nza(rhARvrE1wP5N30MD0zP57uayUMh4O0tfnTzysGQ9Gsg7mLG008Phe7bTMpXyMdlJl(LSBgc5dHe)KBGJkizfufPfKBbvOG0ueeIFj7MHq(qib1DbZZlindHki3csaW5ey)KBGJk4LfunvfmpVGr)4lebqEybd7awbjRGQiVKwW88cstrqiOnm2XqHcb1DbLuZ7T808ahLEQOPndtcuThuYyNPeKMo0wRgPAR08ZBAZo6S08DkamxZNPTpFpcJ4z(rZNEqSh0A(eJzoSmU4xYUziKpes8tUboQGKvqvKwqUfuHcstrqi(LSBgc5dHeu3fmpVG0meQGClibaNtG9tUboQGxwqvxSG55fm6hFHiaYdlyyhWkizfu1fjTGsQ59wEA(mT957ryepZp6qBTAQ0wP5N30MD0zP57uayUMxUtn9pmeNTatMcbsA(0dI9GwZNymZHLXf)s2ndH8HqIFYnWrfKScQI0cYTGkuqAkccXVKDZqiFiKG6UG55fKMHqfKBbja4CcSFYnWrf8YcQMnfmpVGr)4lebqEybd7awbjRGQurAbLuZ7T808YDQP)HH4SfyYuiqshARvtnTvA(5nTzhDwA(ofaMR5zk3NHZmYahh7MLzpw6jhkAJMp9GypO18jgZCyzCXVKDZqiFiK4NCdCubjRGQiTGClOcfKMIGq8lz3meYhcjOUlyEEbPziub5wqcaoNa7NCdCubVSGQUWcMNxWOF8fIaipSGHDaRGKvqvKsAbLuZ7T808mL7ZWzgzGJJDZYShl9KdfTrhARv7IAR08ZBAZo6S08DkamxZdCu8uPG9iSdqjWhg9mgnF6bXEqR5tmM5WY4IFj7MHq(qiXp5g4OcswbvrAb5wqfkinfbH4xYUziKpesqDxW88csZqOcYTGeaCob2p5g4OcEzbvrAbZZly0p(craKhwWWoGvqYki51MckPM3B5P5bokEQuWEe2bOe4dJEgJo0wRMIPTsZpVPn7OZsZ3PaWCnpHPLhgJaJUJWmnF6bXEqR5tmM5WY4IFj7MHq(qiXp5g4OcswbvrAb5wqfkinfbH4xYUziKpesqDxW88csZqOcYTGeaCob2p5g4OcEzbvPQG55fm6hFHiaYdlyyhWkizfufPKwqj18ElpnpHPLhgJaJUJWmDOTwnB0wP5N30MD0zP57uayUMh30hqhShHr3h8P5tpi2dAnFIXmhwgx8lz3meYhcj(j3ahvqYkOksli3cQqbPPiie)s2ndH8HqcQ7cMNxqAgcvqUfKaGZjW(j3ahvWllOkvfmpVGr)4lebqEybd7awbjRGxOnfusnV3YtZJB6dOd2JWO7d(0H2A1UqTvA(ofaMR5PqddetgP5N30MD0zPdT1QDbAR08DkamxZtBySdgb1ton)8M2SJolDOTwnfvBLMFEtB2rNLMp9GypO180ueeIFj7MHq(qib1TMVtbG5AE69O92boUo0wRg5vBLMFEtB2rNLMp9GypO180ueeIFj7MHq(qiXHLXli3cEgnfbHabg(O)123loSmUMVtbG5AEdaNtGWijH6Glpp0H26lsQ2knFNcaZ18eGF0gg7O5N30MD0zPdT1xuL2knFNcaZ18TNgk(2GLAJrZpVPn7OZshARVOAAR08ZBAZo6S08Phe7bTMNMIGq8lz3meYhcjoSmEb5wWZOPiieiWWh9V2(EXHLXli3cstrqiM)n(eu3A(ofaMR5PBCmgbw8GKDKo0wFXlQTsZpVPn7OZsZNEqSh0AE09mgSOF8firgoG3Kb4NcswbvP5rXdsH2AvA(ofaMR5tTXG1PaWCmdafAEdafyElpnFZMo0wFrftBLMFEtB2rNLMVtbG5A(NYX6uayoMbGcnVbGcmVLNMhbCCZWI(XxOdDO5V)LyY0DOTsBTkTvA(ofaMR5P7imddXHrfA(5nTzhDw6qBTAAR08ZBAZo6S08Phe7bTMNKl4t5JG94tGa4(cmgbwWE55Xoy2boosmjqbUV3rZ3PaWCn)VKDZqiFiKo0wFrTvA(ofaMR5tmxcu7zpcJUDFVMFEtB2rNLo0Ho08k3JamxBTAKQMAKQMAQ08z63boosZtEiXu8wtEATItjQGf0koRGa5B2hfKG9f02MnBl4pjqb(DkiIjVc2ubtUJDkyIt74djQRkcWxbvjrfK8zUY9Xof0weJYqd8JGeTTGbRG2IyugAGFeKOyEtB2X2cQGklkPOUQiaFf0gjQGKpZvUp2PG2(u(iyp(eKOTfmyf02NYhb7XNGefZBAZo2wqfuzrjf116k5HetXBn5P1koLOcwqR4SccKVzFuqc2xqBrah3mSOF8f2wWFsGc87uqetEfSPcMCh7uWeN2XhsuxveGVcErjQGKpZvUp2PG2MykN3EiirX8M2SJTfmyf02et582dbjABbvqLfLuuxveGVcQysubjFMRCFStbT9P8rWE8jirBlyWkOTpLpc2JpbjkM30MDSTGkOYIskQRkcWxbvrQevqYN5k3h7uqBJ2mpeKOTfmyf02OnZdbjkM30MDSTGkOYIskQRkcWxbvrQevqYN5k3h7uqBFkFeShFcs02cgScA7t5JG94tqII5nTzhBlOcQSOKI6QIa8vqvQjrfK8zUY9Xof02OnZdbjABbdwbTnAZ8qqII5nTzhBlOcQSOKI6ADL8qIP4TM80AfNsublOvCwbbY3Spkib7lOTNr0uMW2c(tcuGFNcIyYRGnvWK7yNcM40o(qI6QIa8vWlkrfK8zUY9Xof02OnZdbjABbdwbTnAZ8qqII5nTzhBlOcQSOKI6QIa8vqftIki5ZCL7JDkOTpLpc2JpbjABbdwbT9P8rWE8jirX8M2SJTfubvwusrDvra(kOIjrfK8zUY9Xof02NYhb7XNGeTTGbRG2(u(iyp(eKOyEtB2X2c2rbL4koQifubvwusrDvra(kOIjrfK8zUY9Xof02NYhb7XNGeTTGbRG2(u(iyp(eKOyEtB2X2cQGklkPOUQiaFf8cLOcs(mx5(yNcABIPCE7HGefZBAZo2wWGvqBtmLZBpeKOTfubvwusrDvra(k4firfK8zUY9Xof02et582dbjkM30MDSTGbRG2MykN3EiirBlOcQSOKI6QIa8vqfvIki5ZCL7JDkOTjMY5ThcsumVPn7yBbdwbTnXuoV9qqI2wqfuzrjf1vfb4RGQumjQGKpZvUp2PG2gTzEiirBlyWkOTrBMhcsumVPn7yBbvqnlkPOUQiaFfuLIjrfK8zUY9Xof02NYhb7XNGeTTGbRG2(u(iyp(eKOyEtB2X2cQGklkPOUQiaFfuLnsubjFMRCFStbT9P8rWE8jirBlyWkOTpLpc2JpbjkM30MDSTGkOYIskQR1vYt5B2h7uqfRGDkamVGgakqI6QMhDVK26lqnn)9ZiaMP5TGfkijbQNCfK8O)hW(6QfSqbjjm6NQFYvq1SXYcQgPQPwDTUAbluqYNt74djr1vlyHcscfuIDo7uqsYuYYZiQRwWcfKekijna10MDkOmt5KNhfm7cQ4UNbsfurwFxWuBmfubNff03o7uqc2xqGtc4T8kyI5XSyiPOUAbluqsOGKKYuUtbZY0NHc2lxW2pfKK(BCMxqfpR)c20mLRGzzyStWb8OOGbRGa57NPCfK4NeOMNixbzef8xIjlp)0bG5OcQaciJk4ZOW5yixbNeOAJKI6QfSqbjHckXoNDkywDeMvqEomQOGbRG3)smz6okOeJKSIiQRwWcfKekOe7C2PGKeHwbjpJjJe1vlyHcscf0QmRTxqc2xqYdoG3Kb4Ncspc2VcAMYzk4fVarD1cwOGKqbv8tMPCNckXrO5PHe1vlyHcscfKKM52gfKcTcYdg(O)123xqarbbHTOc2MF9HCfK6UGkqsVo4i323lPOUAbluqsOG8lOUlirBFfenjqnpnubjyFb5b4(IcYUNVxuxRRwWcfuIBXLOIDki9iy)kyIjt3rbPhoWrIckXsPDhOc6mNe40VmbLPGDkamhvqMBiNOU2PaWCK4(xIjt3H6sZMUJWmmehgvux7uayosC)lXKP7qDPz)lz3meYhczjGqkj)u(iyp(eiaUVaJrGfSxEESdMDGJJetcuG77DQRDkamhjU)LyY0DOU0Stmxcu7zpcJUDFFDTUAbluqjUfxIk2PGt5EYvWaiVcgCwb7uW(ccqfSv2attBMOUAHcs(C6hFfequWmZ2Ff0WC8cE3OOGmQVGS757TSGSVGzwbpm32OG(2PGbNvq2989fmXKPzfKG9fKhG7lkOcoZjbsQ5bhY9skQRDkamhjnXPF8zjGqAaKhzkAEE0M5H4WOOndlaYtmVPn7KN3PaOCyZNmyiYuLNNykN3Eiuop4qUppNKFkFeShFcea3xGXiWc2lpp2bZoWXrIjbkW99o55jgZCyzCXVKDZqiFiK4NCdCez4PtDTtbG5i1LM9nLS8m11ofaMJuxA2k7h00MzP3Yt6S4suXWU50OzPY2qnPrBMhc5gH60pUr)4leCwBcoI7uC5fTjpp6hFHGZAtWrCNIlvJ088OF8fcoRnbhXDkitrjLBIPCE7Hq58Gd5(6ANcaZrQlnBL9dAAZS0B5jLYbsGAyMHp)0pyilv2gQj9P8rWE8jqaCFbgJalyV88yhm7ahhLN)u(iyp(eiGtqzWqup(YZFkFeShFIzihc0oMmaNtuxTGfkOvCaOccqfuMHcd5kyWk49pLZJcMymZHLXrfK4zYfKEahVGDkboZJ2yixbPq7uWd1dC8ckZuo55HOUAbluWofaMJuxA2pLJ1PaWCmdafw6T8KkZuo55HLacPYmLtEEioau0EAKztD1cwOGDkamhPU0S5SNbsyM13wciKQW3Gd2uopeYmLtEEioau0EAKPMnC)gCWMY5HqMPCYZdbWjtXSrY6QfSqb7uayosDPzJMeOMNMLacPDkakh28jdgsQkUjMY5ThcLZdoK7fZBAZoCFkFeShFcea3xGXiWc2lpp2bZoWXrIjbkW99ow6T8KMLvCv8lzxIOnm2j4aEuir)s2ndH8Hq1vluqjUmLPJHkiWbbOnfmldJDcoGhffenjqnpTcsW(cIaoUzKq0p(IcQEb5b4(crDTtbG5i1LMnTHXobhWJclnaFyPJuvKAjGqAaK3Lkk3ofaLdB(Kbdjvf3NYhb7XNabW9fymcSG9YZJDWSdCCKysGcCFVdxfi5et582dHY5bhY955jgZCyzCXVKDZqiFiK4NCdC0LsXthjRRwOGsCzkthdvqGdcqBkOIFj7MHq(qOcIMeOMNwbjyFbrah3msi6hFrbvVGKuZdoK7lO6fKhG7le11ofaMJuxA2)s2ndH8HqwAa(WshPQi1saH0aiVlvuUDkakh28jdgsQkUjMY5ThcLZdoK7fZBAZoCFkFeShFcea3xGXiWc2lpp2bZoWXrIjbkW99oCV)PuqByStWb8OOUAbluWofaMJuxA2OjbQ5PzjGqANcGYHnFYGHKQIljNykN3Eiuop4qUxmVPn7W9P8rWE8jqaCFbgJalyV88yhm7ahhjMeOa337yP3YtAwwXL850p(KiAdJDcoGhfseN9mqclXPF8vxTqbL4YuMogQGaheG2uqf39mqQGkY67cswbjFo9JVcIMeOMNwbjyFbrah3msi6hFrbvVGoZjbsQ5bhY9fu9cYdW9fI6ANcaZrQlnBo7zGeMz9TLgGpS0rQksTeqifTiaoosWzpdKWsC6hFCdG8U0gUDkakh28jdgsQkUKCIPCE7Hq58Gd5EX8M2Sd3NYhb7XNabW9fymcSG9YZJDWSdCCKysGcCFVd37Fkf0gg7eCapk4MymZHLXfjo9JpXp5g4OljvytD1cfuIltz6yOccCqaAtbvC3ZaPcQiRVlizfK850p(kiAsGAEAfKG9febCCZiHOF8ffu9c6mNeiPMhCi3xq1lipa3xiQRDkamhPU0StC6hFwAa(WshPQi1saHu0Ia44ibN9mqclXPF8XnaY7sB42PaOCyZNmyiPQ4sYjMY5ThcLZdoK7fZBAZoCFkFeShFcea3xGXiWc2lpp2bZoWXrIjbkW99oCV)PuWzpdKWmRVRRDkamhPU0SVzbG511ofaMJuxA2jMlbQ9ShHr3UV3saH0VXhzxaP11ofaMJuxA2O71pgJaJUrbG5wciKstrqiM)n(eu3C)gFxEbKwx7uayosDPz)T8DJplbestmM5WY4IFj7MHq(qiXp5g4OlVi3OnZdXVKDZqiSMU9dZfZBAZo11ofaMJuxA2jMlbQ9ShHr3UV3saHuAkccXVKDZqiFiK4WY4CpJMIGqGadF0)A77fhwgppNaGZjW(j3ahDPnKwx7uayosDPz)lz3meYhczjGq6t5JG94tGaobLbdr94JlE6i(j3ahjLuUkOSFqtBMywCjQyy3CA0YZvi6hFHiaYdlyy3Pa7I2qMIrk3OnZdr747XKBVXN88ipp6hFHiaYdlyy3Pa7I2q2fqkxsoAZ8q0o(Em52B8jppKusUkGUNXGf9JVajYWb8Mma)ivvEonfbHqEDGLmRvUxqDlzDTtbG5i1LM9VKDZqiFiKLacPpLpc2JpXmKdbAhtgGZj4INoIFYnWrsjLRcjgZCyzCb6E9JXiWOBuayU4NCdC0L2KNNymZHLXfO71pgJaJUrbG5IFYnWrKPgPsYvbfOPiie0gg7yOqHG6oppAZ8q0o(Em52B8jppeZBAZo55Fdoyt58q0NdsaCYurQK55r)4lebqEybd7agzQiL08CL9dAAZeZIlrfd7MtJwEE0p(craKhwWWoGDPkB4(n4GnLZdrFoibWjtfPsYvb09mgSOF8firgoG3Kb4hPQYZPPiieYRdSKzTY9cQBjRRDkamhPU0S)LSBgc5dHSeqiLKv2pOPntq5ajqnmZWNF6hmex80r8tUboskPCvqbAkccbTHXogkuiOUZZJ2mpeTJVhtU9gFYZdX8M2StE(3Gd2uope95GeaNmvKkzEE0p(craKhwWWoGrMksjnpxz)GM2mXS4suXWU50OLNtZqiUr)4lebqEybd7a2LQSH73Gd2uope95GeaNmvKkjxfq3ZyWI(XxGez4aEtgGFKQkpNMIGqiVoWsM1k3lOULKRcKCIPCE7HWx6zg2FYZtmM5WY4IeZLa1E2JWOB33l(j3ahrMAKkzDTtbG5i1LM9VKDZqiFiKLuOHXiiWWthPQSeqi9P8rWE8jqaCFbgJalyV88yhm7ahhjMeOa337W9(Nsm80rOs8T8DJpUkOanfbHG2Wyhdfkeu355rBMhI2X3Jj3EJp55HyEtB2jp)BWbBkNhI(CqcGtMksLmpp6hFHiaYdlyyhWitfPKMNRSFqtBMywCjQyy3CA0YZJ(XxicG8Wcg2bSlvzd3VbhSPCEi6ZbjaozQivsUkGUNXGf9JVajYWb8Mma)ivvEonfbHqEDGLmRvUxqDlzDTtbG5i1LMDgoG3Kb4hlbesnt5mKDXlKRcO7zmyr)4lqImCaVjdWpKPIljttrqiKxhyjZAL7fu355Fdoyt58q0Ndsa8lXthUKmnfbHqEDGLmRvUxqDlzDTtbG5i1LMnfAyGyYw6T8KcCu6PIM2mmjq1EqjJDMsqAwciKMymZHLXf)s2ndH8HqIFYnWrKPIuUkqtrqi(LSBgc5dHeu3550meIlbaNtG9tUbo6s1uLNh9JVqea5HfmSdyKPI8sAEonfbHG2Wyhdfkeu3swx7uayosDPztHggiMSLElpPzA7Z3JWiEMFSeqinXyMdlJl(LSBgc5dHe)KBGJitfPCvGMIGq8lz3meYhcjOUZZPziexcaoNa7NCdC0LQUyEE0p(craKhwWWoGrMQlsQK11ofaMJuxA2uOHbIjBP3YtQCNA6FyioBbMmfcKSeqinXyMdlJl(LSBgc5dHe)KBGJitfPCvGMIGq8lz3meYhcjOUZZPziexcaoNa7NCdC0LQztEE0p(craKhwWWoGrMkvKkzDTtbG5i1LMnfAyGyYw6T8KYuUpdNzKboo2nlZES0tou0glbestmM5WY4IFj7MHq(qiXp5g4iYurkxfOPiie)s2ndH8HqcQ78CAgcXLaGZjW(j3ahDPQlmpp6hFHiaYdlyyhWitfPKkzDTtbG5i1LMnfAyGyYw6T8KcCu8uPG9iSdqjWhg9mglbestmM5WY4IFj7MHq(qiXp5g4iYurkxfOPiie)s2ndH8HqcQ78CAgcXLaGZjW(j3ahDPksZZJ(XxicG8Wcg2bmYiV2izDTtbG5i1LMnfAyGyYw6T8KsyA5HXiWO7imZsaH0eJzoSmU4xYUziKpes8tUboImvKYvbAkccXVKDZqiFiKG6opNMHqCja4CcSFYnWrxQsvEE0p(craKhwWWoGrMksjvY6ANcaZrQlnBk0WaXKT0B5jf30hqhShHr3h8zjGqAIXmhwgx8lz3meYhcj(j3ahrMks5QanfbH4xYUziKpesqDNNtZqiUeaCob2p5g4OlvPkpp6hFHiaYdlyyhWi7cTrY6ANcaZrQlnBk0WaXKr11ofaMJuxA20gg7Grq9KRU2PaWCK6sZMEpAVDGJBjGqknfbH4xYUziKpesqDxx7uayosDPzBa4CcegjjuhC55HLacP0ueeIFj7MHq(qiXHLX5EgnfbHabg(O)123loSmEDTtbG5i1LMnb4hTHXo11ofaMJuxA2TNgk(2GLAJPU2PaWCK6sZMUXXyeyXds2rwciKstrqi(LSBgc5dHehwgN7z0ueecey4J(xBFV4WY4CPPiieZ)gFcQ76ANcaZrQln7uBmyDkamhZaqHLO4bPqQkl9wEsB2SeqifDpJbl6hFbsKHd4nza(Hmv11ofaMJuxA2pLJ1PaWCmdafw6T8KIaoUzyr)4lQR11ofaMJenBstTNMbJMIGWsVLNuAtFgkyVSLacP4PJ4NCdCKus5IyugAGFeeGhfyO4b2hxAkccbb4rbgkEG9j(j3ahXLMIGqm)B8j(j3ahDjE6ux7uayos0SPU0SBpbMhynrShXHLSBjGqknfbHy(34tqDZnXyMdlJl(LSBgc5dHe)KBGJiZM6ANcaZrIMn1LMn6E9JXiWOBuayULacP0ueeI5FJpb1n3VX3LkgP11ofaMJenBQlnBAtFgkyVSLap2)u3bgGqkE6i(j3ahjLuUigLHg4hbb4rbgkEG9XLMIGqqaEuGHIhyFIFYnWrCPPiieZ)gFIFYnWrxINowciKstrqiM)n(eu3Cr3ZyWI(XxGez4aEtgGFitT6ANcaZrIMn1LMDI5Nj7wciKQanfbHy(34tqDNNttrqi(LSBgc5dHeu3CFkFeShFceWjOmyiQhFsYvz)GM2mXS4suXWU50Ovx7uayos0SPU0SrGHp6FT9911ofaMJenBQln7VLVB8vx7uayos0SPU0Sr3RFmgbgDJcaZTeqiLMIGqm)B8jOU5MymZHLXf)s2ndH8HqIFYnWrKztDTtbG5irZM6sZM20NHc2lBjGqknfbHy(34t8tUboIm80rXb1e2uxRRDkamhjqah3mSOF8fQln7VXboogTHLXsaH0NYhb7XNidWyWyeybNHrVhT3(EXKaf4(EhU0ueeImaJbJrGfCgg9E0E77f)KBGJUepDQRDkamhjqah3mSOF8fQln70tH4aCCmAdlJLacPpLpc2JprgGXGXiWcodJEpAV99IjbkW99oCPPiiezagdgJal4mm69O923l(j3ahDjE6ux7uayosGaoUzyr)4luxA2P2tZGrtrqyP3YtkTPpdfSx2saHu09mgSOF8firgoG3Kb4hPQ4INoIFYnWrsjLRcrBMhc5gH60pX8M2StEEIPCE7Hq58Gd5EX8M2SJKCv2pOPntmlUevmSBonACv4B8rg5L08CsoXyMdlJlsm)mzx8tUbosY6ANcaZrceWXndl6hFH6sZoX8ZKDlbesvGMIGqm)B8jOUZZPPiie)s2ndH8HqcQBUpLpc2Jpbc4eugme1Jpj5QSFqtBMywCjQyy3CA0QRDkamhjqah3mSOF8fQlnBey4J(xBFVLacPNrtrqiqGHp6FT99IdlJZvb09mgSOF8firgoG3Kb4hYuLN)n4GnLZdrFoibWjtLnswx7uayosGaoUzyr)4luxA2FlF34ZsaHuAkccXVKDZqiFiKG6opxbAkccX8VXN4NCdC0L4PtE(34JmfLujZZPPiiee)CsIjN4NCdC0LQe2ux7uayosGaoUzyr)4luxA2jMFMSxx7uayosGaoUzyr)4luxA2TNaZdSMi2J4Ws2TeqiLMIGqm)B8jOU5MymZHLXf)s2ndH8HqIFYnWrKzdxfI(XxicG8Wcg2bmYiV2KNttrqi(LSBgc5dHeu355r)4lebqEybd7a2LQrQKC)gCWMY5HOphKa4KDb2ux7uayosGaoUzyr)4luxA2ZIlrfRU2PaWCKabCCZWI(XxOU0Sr3RFmgbgDJcaZTeqi9P8rWE8jMHCiq7yYaCobxAkccX8VXNG6MBIXmhwgx8lz3meYhcj(j3ahrMnCvGMIGq8lz3meYhcjOUZZJ(XxicG8Wcg2bSlvJ088ZOPiieiWWh9V2(Eb1DEojhTzEiqGHp6FT99CJ(XxicG8Wcg2bmYUqfvsUFdoyt58q0NdsaCYSXM6ANcaZrceWXndl6hFH6sZM20NHc2lBjGqknfbHy(34tqDZvbsMMIGq8lz3meYhcj(j3ahLN)n(U0gsLKRcO7zmyr)4lqImCaVjdWpsvX9BWbBkNhI(CqcGtMIztEo6Egdw0p(cKidhWBYa8Ju1KSU2PaWCKabCCZWI(XxOU0Sr3RFmgbgDJcaZTeqiLMIGqm)B8jOU5MymZHLXf)s2ndH8HqIFYnWrKzdxfOPiie)s2ndH8HqcQ788OF8fIaipSGHDa7s1inp)mAkccbcm8r)RTVxqDNNtYrBMhcey4J(xBFp3OF8fIaipSGHDaJSlurLK73Gd2uope95GeaNmBSPU2PaWCKabCCZWI(XxOU0SPnm2j4aEuyzICjZWI(XxGKQYsaHuAkccX8VXN4WY455jMFOaHqjibyuiSeZJjFhIVD7Kzd3OF8fcoRnbhXDkU8I2ux7uayosGaoUzyr)4luxA20gg7q3bhlbesPPiieZ)gFIdlJNNNy(HcecLGeGrHWsmpM8Di(2TtMnCJ(Xxi4S2eCe3P4YlAtDTtbG5ibc44MHf9JVqDPzF(gN5ypRFlbesPPiieZ)gFcQBUkGUNXGf9JVajYWb8Mma)qMQ88VbhSPCEi6ZbjaozQSrY6ANcaZrceWXndl6hFH6sZodhWBYa8JLacP0ueec59jGziegnZh(d8ZEb1nx09mgSOF8firgoG3Kb4hYUyDTtbG5ibc44MHf9JVqDPz)noWXXOnSmwciKIwGrZCkKia7vtrXu7oLNN40p(qsvlpxbAkccXVKDZqiFiKG6MRY(bnTzIzXLOIHDZPrJB0M5HqUrOo9tmVPn7izDTtbG5ibc44MHf9JVqDPzNEkehGJJrByzSeqifTaJM5uira2RMIIP2DkppXPF8HKQwEUc0ueeIFj7MHq(qib1nxL9dAAZeZIlrfd7MtJg3OnZdHCJqD6NyEtB2rY6ANcaZrceWXndl6hFH6sZM5ittHZjSeqiLMIGqm)B8jOURRDkamhjqah3mSOF8fQlnBAdJDcoGhfwMixYmSOF8fiPQSeqiLMIGqm)B8joSmEDTtbG5ibc44MHf9JVqDPztByStWb8OOU2PaWCKabCCZWI(XxOU0SPnm2HUdo11ofaMJeiGJBgw0p(c1LM934ahhJ2WYux7uayosGaoUzyr)4luxA2PNcXb44y0gwM6ANcaZrceWXndl6hFH6sZodhWBYa8Jo0Hwd]] )


end
