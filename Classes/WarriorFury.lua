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


    spec:RegisterPack( "Fury", 20220311, [[d40HBbqiKQ4raGnbv9jkPgfb5ueOvrsrWRiPAwuIUfsb7IOFrPQHHu5yKKLje9mcQMgjfUgLkBdPi(gaKXHuLohsrzDivvZdaDpsyFiLoibfwOq4HivLjIuK6Ieu0gjPi6JaqHrssr6KifvTsaAMeu6Maqv7KsYpjPi0qbGklLKI6PO0uPeUkau0wrks(ksrLXIuO9sQ)IKbd6WswmIESGjd0LvTzO8zegnu50qwnauQxtPmBkUnH2nv)gvdhqhNaA5k9CPMUIRJITtI(UqA8Ku68eG1daLmFHA)IwRsBHMfSMRTks6Ims6eUkvYifUQivdAMMDeaWRzbwbBfX1SEjEnRAsMvaAwGLam8cuBHMT5mB4AwCZaSPF7TNan4yiLbUO9nsKXudI7HTWg7BKyWEnljdYm08UMuZcwZ1wfjDrgjDcxLkzKcxvKcNE1SfZGJVAwwKi9Lq7tOWyd4qIdA5TMfhce8UMuZc(oOzvtYSciH0C1Ui(MacGV2aUesVwMWiPlYitataPpCLt8M(taPHekmabpycbWXikEJmbKgsinnQlsZbtOix5fVpj0(eQM(LJcjuyFbmHHYysOqoFsO)dEWeIX3eICAGOeFcdCFUAhbLjG0qcbWZvEWegHPaFp8vmHLdMqA6Ti4EcvZ8AtyrYv(egHHZbhCOTNeo8eIebUCLpHy7fiZ9GasihlH7dCrX7G1G4ENqHAKyNWLZqGZiGeEbYugbLjG0qcfgGGhmHruZyEczXXzMeo8ecCFGlswtcfga4ewzcinKqHbi4btiaM9tin)CXwMasdj0IOVSLqm(MqAoCO1ef5GjK8y89j0CL3KqHdGKjG0qcvZxKR8Gjuy299WBzcinKqAAUB9KqM(jKfDItUVS9nHiSeIgR7ewM9fOasidWeken9RbNyz7RGYeqAiHSFyaMqSY2tyFbYCp8oHy8nHSic)tc5aV)vQznOEATfA2IFTfARuPTqZEVinhuhHMnSO5lQ0Sebq5EXc5DcvKq6si(e2CgdjYbLyOThQEwKTlVxKMdMq8jKKbdtIH2EO6zr2UCVyH8oH4tijdgM8(wexUxSqENqaMqIaOMTcdI7A2q5HBOizWW0SKmyyuEjEnlPPaFp8vupARIuBHM9ErAoOocnByrZxuPzjzWWK33I4sgGjeFcdCUbKh1L7d2mVB)Dl3lwiVtiTj0onBfge31SLhq3hQcB(244bB6rBLW1wOzVxKMdQJqZgw08fvAwsgmm59TiUKbycXNWTiEcbycvd60SvyqCxZ2aFTuCmkYQhe31J2k1qBHM9ErAoOocnByrZxuPzjzWWK33I4sgGjeFcBG3yOMAj(0YO4qRjkYbtiTjmsnBfge31SKMc89WxrnlYNVldWHcHPzjcGY9IfYBf0HV5mgsKdkXqBpu9SiBhpjdgMedT9q1ZISD5EXc5nEsgmm59TiUCVyH8gGebq9OTYoTfA27fP5G6i0SHfnFrLMvOesYGHjVVfXLmatyCCcjzWWK7d2mVB)DlzaMq8jCz8JXxIlBKJXyOAML4Y7fP5GjuWeIpHkRfvKMlVAFGzofqCvFnBfge31SbUdErxpAROjAl0SvyqCxZ2OtCY9LTVA27fP5G6i0J2kaK2cnBfge31SBjcSiUM9ErAoOoc9OTIE1wOzVxKMdQJqZgw08fvAwsgmm59TiUKbycXNWaNBa5rD5(GnZ72F3Y9IfY7esBcTtZwHbXDnBd81sXXOiREqCxpAROzAl0S3lsZb1rOzdlA(IknljdgM8(wexUxSqENqAtiramHQjKWiL2PzRWG4UML0uGVh(kQh9OzBKtyo1ulXhTfARuPTqZEVinhuhHMnSO5lQ0SlJFm(sCzuKXqXXOgCNI8B)12x5fidciWdMq8jKKbdtgfzmuCmQb3Pi)2FT9vUxSqENqaMqIaOMTcdI7A2TiqobfPHhvpARIuBHM9ErAoOocnByrZxuPzxg)y8L4YOiJHIJrn4of53(RTVYlqgeqGhmH4tijdgMmkYyO4yudUtr(T)A7RCVyH8oHamHebqnBfge31SHLPXHCcksdpQE0wjCTfA27fP5G6i0SHfnFrLMTbEJHAQL4tlJIdTMOihmHksOQeIpHebq5EXc5DcvKq6si(ekucNYCFKIv3vyV8ErAoycJJtyGR8E5Ju59bNa2ekycXNqL1IksZLxTpWmNciUQFcXNqHs4wepH0MqAgDjmooH0tcdCUbKh1LbUdErxUxSqENqb1SvyqCxZgkpCdfjdgMMLKbdJYlXRzjnf47HVI6rBLAOTqZEVinhuhHMnSO5lQ0ScLqsgmm59TiUKbycJJtijdgMCFWM5D7VBjdWeIpHlJFm(sCzJCmgdvZSexEVinhmHcMq8juzTOI0C5v7dmZPaIR6RzRWG4UMnWDWl66rBLDAl0S3lsZb1rOzdlA(Iknl4jzWWKn6eNCFz7ReKh1ti(ekucBG3yOMAj(0YO4qRjkYbtiTjuvcJJt4wiqQR8(ilqWwI8esBcvzxcfuZwHbXDnBJoXj3x2(QhTv0eTfA27fP5G6i0SHfnFrLMLKbdtUpyZ8U93TKbycJJtOqjKKbdtEFlIl3lwiVtiatiramHXXjClINqAti9sxcfmHXXjKKbdtIT3bWsaY9IfY7ecWeQsANMTcdI7A2TebwexpARaqAl0S3lsZb1rOzdlA(IknB)HIK7mTCqFJKEPIeyiHXXjmGRwI3jurcJmHXXjuOesYGHj3hSzE3(7wYamH4tOYArfP5YR2hyMtbex1pH4t4uM7JuS6Uc7L3lsZbtOGA2kmiURzdltJd5euKgEu9OTIE1wOzRWG4UMnWDWl6A27fP5G6i0J2kAM2cn79I0CqDeA2WIMVOsZsYGHjVVfXLmati(eg4CdipQl3hSzE3(7wUxSqENqAtODjeFcfkHK8Uti(eIHiWnu7flK3jK2esZSlHXXjKKbdtUpyZ8U93TKbycJJtijV7eIpHyicCd1EXc5DcbycJKUekycXNWTqGux59rwGGTe5jK2ecGStZwHbXDnB5b09HQWMVnoEWME0wPIoTfA2kmiURzVAFGzUM9ErAoOoc9OTsLkTfA27fP5G6i0SHfnFrLMDz8JXxIlVranQCkrebUrEVinhmH4tijdgM8(wexYamH4tyGZnG8OUCFWM5D7VB5EXc5DcPnH2Lq8juOesYGHj3hSzE3(7wYamHXXjKK3DcXNqmebUHAVyH8oHamHrsxcJJti4jzWWKn6eNCFz7RKbycJJti9KWPm3hzJoXj3x2(kVxKMdMq8jKK3DcXNqmebUHAVyH8oH0MqAc9Mqbti(eUfcK6kVpYceSLipH0Mq7StZwHbXDnBd81sXXOiREqCxpARufP2cn79I0CqDeA2WIMVOsZsYGHjVVfXLmati(ekucPNesYGHj3hSzE3(7wUxSqENW44eUfXtiatOD0Lqbti(ekucBG3yOMAj(0YO4qRjkYbtOIeQkH4t4wiqQR8(ilqWwI8esBcvd7syCCcBG3yOMAj(0YO4qRjkYbtOIegzcfuZwHbXDnlPPaFp8vupARujCTfA27fP5G6i0SHfnFrLMLKbdtEFlIlzaMq8jmW5gqEuxUpyZ8U93TCVyH8oH0Mq7si(ekucjzWWK7d2mVB)DlzaMW44esY7oH4tigIa3qTxSqENqaMWiPlHXXje8KmyyYgDItUVS9vYamHXXjKEs4uM7JSrN4K7lBFL3lsZbti(esY7oH4tigIa3qTxSqENqAtinHEtOGjeFc3cbsDL3hzbc2sKNqAtOD2PzRWG4UMTb(AP4yuKvpiURhTvQudTfA27fP5G6i0SHfnFrLMT)qrYDMwoOVrsVurcmKW44egWvlX7eQiHrMW44ekucjzWWK7d2mVB)DlzaMq8juzTOI0C5v7dmZPaIR6Nq8jCkZ9rkwDxH9Y7fP5GjuqnBfge31SBrGCcksdpQE0wPYoTfA27fP5G6i0SvyqCxZsA4CWbhA7rZgw08fvAwsgmm59TiUeKh1tyCCcdChKbnsLOaIZ0ubUpxe4i3YTLqAtODjeFcNAj(iX9Ym4KadtcbycfUDA2GacMtn1s8P1wPspARurt0wOzVxKMdQJqZgw08fvAwsgmm59TiUeKh1tyCCcdChKbnsLOaIZ0ubUpxe4i3YTLqAtODjeFcNAj(iX9Ym4KadtcbycfUDA2kmiURzjnCoizn40J2kvaiTfA27fP5G6i0SHfnFrLMLKbdtEFlIlzaMq8juOe2aVXqn1s8PLrXHwtuKdMqAtOQeghNWTqGux59rwGGTe5jK2eQYUekOMTcdI7AwWTi4o1YRvpARurVAl0S3lsZb1rOzdlA(IknljdgMu8BazE3uKC)elYb)kzaMq8jSbEJHAQL4tlJIdTMOihmH0MqHRzRWG4UMnko0AIICq9OTsfntBHM9ErAoOocnByrZxuPzjzWWK33I4sgGA2kmiURz5EBkgcCJE0wfjDAl0SvyqCxZsA4CWbhA7rZEVinhuhHE0wfPkTfA2kmiURzjnCoizn40S3lsZb1rOhTvrgP2cnBfge31SBrGCcksdpQM9ErAoOoc9OTksHRTqZwHbXDnByzACiNGI0WJQzVxKMdQJqpARIun0wOzRWG4UMnko0AIICqn79I0CqDe6rpAwWJvmMrBH2kvAl0S3lsZb1rOzRWG4UMnGRwIRzbFhweWbXDnl9HRwINqewcJER3Nqd3jsiWQNeYz2eYbE)RLjKVjm6tii3TEsO)dMWb3tih49VjmWfj5jeJVjKfr4FsOqo3PbAQ7dobSck1SHfnFrLMDqIpH0Mq6nHXXjCkZ9rcYzinNAqIxEVinhmHXXjScds5PUFr07esBcvLW44eg4kVx(ivEFWjGnHXXjKEs4Y4hJVex2ic)dfhJA4R495Gu2qorlVazqabEWeghNWaNBa5rD5(GnZ72F3Y9IfY7esBcjcG6rBvKAl0SvyqCxZcKru8gn79I0CqDe6rBLW1wOzVxKMdQJqZYbQz7pA2kmiURzvwlQinxZQSmmxZoL5(ifRURWE59I0CWeIpHtTeFK4EzgCsGHjHamHc3UeghNWPwIpsCVmdojWWKqaMWiPlHXXjCQL4Je3lZGtcmmjK2esV0Lq8jmWvEV8rQ8(GtaRMvzTuEjEn7v7dmZPaIR6RhTvQH2cn79I0CqDeAwoqnB)rZwHbXDnRYArfP5AwLLH5A2LXpgFjUSre(hkog1WxX7ZbPSHCIwEVinhmHXXjCz8JXxIlBKJXyOAML4Y7fP5GjmooHlJFm(sC5ncOrLtjIiWnY7fP5GAwL1s5L41SmosGmNYCI7G1IERhTv2PTqZEVinhuhHMTcdI7AwsdNdo4qBpAwdYpvauZQIonByrZxuPzhK4tiati9Mq8jScds5PUFr07eQiHQsi(eUm(X4lXLnIW)qXXOg(kEFoiLnKt0YlqgeqGhmH4tOqjKEsyGR8E5Ju59bNa2eghNWaNBa5rD5(GnZ72F3Y9IfY7ecqfjKiaMqb1SGVdlc4G4UMvykYyQ5DcroAqLjHry4CWbhA7jH9fiZ9WtigFtyJCcZPHPwIpju9eYIi8ps9OTIMOTqZEVinhuhHMTcdI7A29bBM3T)U1SgKFQaOMvfDA2WIMVOsZoiXNqaMq6nH4tyfgKYtD)IO3jurcvLq8jmWvEV8rQ8(GtaBcXNWLXpgFjUSre(hkog1WxX7ZbPSHCIwEbYGac8GjeFcbUxPK0W5Gdo02JMf8Dyrahe31SctrgtnVtiYrdQmjun)GnZ72F3jSVazUhEcX4BcBKtyonm1s8jHQNqAQ7dobSju9eYIi8ps9OTcaPTqZEVinhuhHMTcdI7AwCF5OaL5fqnRb5NkaQzvrNMnSO5lQ0S9Nb5eTe3xokqfWvlXti(eoiXNqaMq7si(ewHbP8u3Vi6DcvKqvjeFcPNeg4kVx(ivEFWjGnH4t4Y4hJVex2ic)dfhJA4R495Gu2qorlVazqabEWeIpHa3RusA4CWbhA7jH4tyGZnG8OUmGRwIl3lwiVtiatiDs70SGVdlc4G4UMvykYyQ5DcroAqLjHQPF5Oqcf2xatiTjK(WvlXtyFbYCp8eIX3e2iNWCAyQL4tcvpHo3PbAQ7dobSju9eYIi8ps9OTIE1wOzVxKMdQJqZwHbXDnBaxTexZAq(PcGAwv0PzdlA(IknB)zqorlX9LJcubC1s8eIpHds8jeGj0UeIpHvyqkp19lIENqfjuvcXNq6jHbUY7LpsL3hCcyti(eUm(X4lXLnIW)qXXOg(kEFoiLnKt0YlqgeqGhmH4tiW9kL4(YrbkZlGAwW3HfbCqCxZkmfzm18oHihnOYKq10VCuiHc7lGjK2esF4QL4jSVazUhEcX4BcBKtyonm1s8jHQNqN70an19bNa2eQEczre(hPE0wrZ0wOzRWG4UMfiFqCxZEVinhuhHE0wPIoTfA27fP5G6i0SHfnFrLMDlINqAtiaIonBfge31SbUlqMV8TPil3)QhTvQuPTqZEVinhuhHMnSO5lQ0SKmyyY7BrCjdWeIpHBr8ecWecGOtZwHbXDnBd81sXXOiREqCxpARufP2cn79I0CqDeA2WIMVOsZg4CdipQl3hSzE3(7wUxSqENqaMqHNq8jCkZ9rUpyZ8UPkYYb5U8ErAoOMTcdI7A2TebwexpARujCTfA27fP5G6i0SHfnFrLMLKbdtUpyZ8U93TeKh1ti(ecEsgmmzJoXj3x2(kb5r9eghNqmebUHAVyH8oHamH2rNMTcdI7A2a3fiZx(2uKL7F1J2kvQH2cn79I0CqDeA2WIMVOsZUm(X4lXLnYXymunZsC59I0CWeIpHebq5EXc5DcvKq6si(ekucvwlQinxE1(aZCkG4Q(jmooHcLWPwIpYbjEQHtbmmuc3UesBcvd6si(eoL5(ilN4lLy5fXfVpY7fP5GjmooHtTeFKds8udNcyyOeUDjK2ecGOlH4ti9KWPm3hz5eFPelViU49rEVinhmHcMqbti(ekucBG3yOMAj(0YO4qRjkYbtOIeQkHXXjKKbdtk(AOcMxk)kzaMqb1SvyqCxZUpyZ8U93TE0wPYoTfA27fP5G6i0SHfnFrLMDz8JXxIlVranQCkrebUrEVinhmH4tirauUxSqENqfjKUeIpHcLWaNBa5rDzd81sXXOiREqCxUxSqENqaMq7syCCcdCUbKh1LnWxlfhJIS6bXD5EXc5DcPnHrsxcfmH4tOqjuOesYGHjjnCoOHPhjdWeghNWPm3hz5eFPelViU49rEVinhmHXXjClei1vEFKfiylrEcPnHQOlHcMW44esY7oH4tigIa3qTxSqENqAtOk6OlHXXjuzTOI0C5v7dmZPaIR6NW44esY7oH4tigIa3qTxSqENqaMqv2Lq8jClei1vEFKfiylrEcPnHQOlHcMq8juOe2aVXqn1s8PLrXHwtuKdMqfjuvcJJtijdgMu81qfmVu(vYamHcQzRWG4UMDFWM5D7VB9OTsfnrBHM9ErAoOocnByrZxuPzPNeQSwurAUKXrcK5uMtChSw07eIpHebq5EXc5DcvKq6si(ekucfkHKmyyssdNdAy6rYamHXXjCkZ9rwoXxkXYlIlEFK3lsZbtyCCc3cbsDL3hzbc2sKNqAtOk6sOGjmooHK8Uti(eIHiWnu7flK3jK2eQIo6syCCcvwlQinxE1(aZCkG4Q(jmooHK8Uti(eIHiWnu7flK3jeGjuLDjeFc3cbsDL3hzbc2sKNqAtOk6sOGjeFcfkHnWBmutTeFAzuCO1ef5GjurcvLW44esYGHjfFnubZlLFLmatOGjeFcfkH0tcdCL3lFK(dl3WxWeghNWaNBa5rDzG7cK5lFBkYY9VY9IfY7esBcJKUekOMTcdI7A29bBM3T)U1J2kvaiTfA27fP5G6i0SHfnFrLMDz8JXxIlBeH)HIJrn8v8(CqkBiNOLxGmiGapycXNqG7vsreaLQKBjcSiEcXNqHsOqjKKbdtsA4CqdtpsgGjmooHtzUpYYj(sjwErCX7J8ErAoycJJt4wiqQR8(ilqWwI8esBcvrxcfmHXXjKK3DcXNqmebUHAVyH8oH0Mqv0rxcJJtOYArfP5YR2hyMtbex1pHXXjKK3DcXNqmebUHAVyH8oHamHQSlH4t4wiqQR8(ilqWwI8esBcvrxcfmH4tOqjSbEJHAQL4tlJIdTMOihmHksOQeghNqsgmmP4RHkyEP8RKbycfuZwHbXDn7(GnZ72F3AwM(uCmmkIaO2kv6rBLk6vBHM9ErAoOocnByrZxuPznx5njK2ekCAscXNqHsyd8gd1ulXNwgfhAnrroycPnHQsi(espjKKbdtk(AOcMxk)kzaMW44eUfcK6kVpYceSLipHamHebWeIpH0tcjzWWKIVgQG5LYVsgGjuqnBfge31SrXHwtuKdQhTvQOzAl0S3lsZb1rOzRWG4UMf5DyzMI0CkbYu(WisbELOW1SHfnFrLMnW5gqEuxUpyZ8U93TCVyH8oH0Mqv0Lq8juOesYGHj3hSzE3(7wYamHXXjKK3DcXNqmebUHAVyH8oHamHrQkHXXjKK3DcXNqmebUHAVyH8oH0Mqv0m6syCCcjzWWKKgoh0W0JKbycfuZ6L41SiVdlZuKMtjqMYhgrkWRefUE0wfjDAl0S3lsZb1rOzRWG4UMnAz7(3McB5oOMnSO5lQ0Sbo3aYJ6Y9bBM3T)UL7flK3jK2eQIUeIpHcLqsgmm5(GnZ72F3sgGjmooHK8Uti(eIHiWnu7flK3jeGjuLWtyCCcj5DNq8jedrGBO2lwiVtiTjuLWPlHcQz9s8A2OLT7FBkSL7G6rBvKQ0wOzVxKMdQJqZwHbXDnRyfkY9unU)HsKPrbnByrZxuPzdCUbKh1L7d2mVB)Dl3lwiVtiTjufDjeFcfkHKmyyY9bBM3T)ULmatyCCcj5DNq8jedrGBO2lwiVtiatyK2LW44esY7oH4tigIa3qTxSqENqAtOkv0Lqb1SEjEnRyfkY9unU)HsKPrb9OTkYi1wOzVxKMdQJqZwHbXDnlx53O4Ure5eua5r)sfwb0tz0SHfnFrLMnW5gqEuxUpyZ8U93TCVyH8oH0Mqv0Lq8juOesYGHj3hSzE3(7wYamHXXjKK3DcXNqmebUHAVyH8oHamHQOjjmooHK8Uti(eIHiWnu7flK3jK2eQIo6sOGAwVeVMLR8BuC3iICckG8OFPcRa6Pm6rBvKcxBHM9ErAoOocnBfge31SiVNLjm8TParkr(PiVXOzdlA(IknBGZnG8OUCFWM5D7VB5EXc5DcPnHQOlH4tOqjKKbdtUpyZ8U93TKbycJJtijV7eIpHyicCd1EXc5DcbycvrxcJJtijV7eIpHyicCd1EXc5DcPnH0m7sOGAwVeVMf59SmHHVnfisjYpf5ng9OTks1qBHM9ErAoOocnBfge31SyMs8uCmkYAgZ1SHfnFrLMnW5gqEuxUpyZ8U93TCVyH8oH0Mqv0Lq8juOesYGHj3hSzE3(7wYamHXXjKK3DcXNqmebUHAVyH8oHamHQuLW44esY7oH4tigIa3qTxSqENqAtOk6OlHcQz9s8AwmtjEkogfznJ56rBvK2PTqZEVinhuhHMTcdI7AwctbIQHVnfzbsCnByrZxuPzdCUbKh1L7d2mVB)Dl3lwiVtiTjufDjeFcfkHKmyyY9bBM3T)ULmatyCCcj5DNq8jedrGBO2lwiVtiatOkvjmooHK8Uti(eIHiWnu7flK3jK2estSlHcQz9s8AwctbIQHVnfzbsC9OTksAI2cn79I0CqDeAwVeVMTd12uCmkSTMVEzO6zryxZwHbXDnBhQTP4yuyBnF9Yq1ZIWUE0wfjasBHMTcdI7AwM(uO5ITM9ErAoOoc9OTks6vBHMTcdI7AwsdNdsHXScqZEVinhuhHE0wfjntBHM9ErAoOocnByrZxuPzjzWWK7d2mVB)DlzaQzRWG4UML8B)1gYj0J2kHtN2cn79I0CqDeA2WIMVOsZsYGHj3hSzE3(7wcYJ6jeFcbpjdgMSrN4K7lBFLG8OUMTcdI7AwdIa30uayZasiEF0J2kHRsBHMTcdI7Awm0EsdNdQzVxKMdQJqpAReEKAl0SvyqCxZwE49SLHkugJM9ErAoOoc9OTs4cxBHM9ErAoOocnByrZxuPzjzWWK7d2mVB)Dlb5r9eIpHGNKbdt2OtCY9LTVsqEupH4tijdgM8(wexYauZwHbXDnlzrqXXOMffS16rBLWvdTfA27fP5G6i0SHfnFrLMTbEJHAQL4tlJIdTMOihmH0MqvA2Ewuy0wPsZwHbXDnBOmgQkmiUtzq9OznOEO8s8A2IF9OTs42PTqZEVinhuhHMTcdI7A2LXPQWG4oLb1JM1G6HYlXRzBKtyo1ulXh9OhnlW9bUiznAl0wPsBHMTcdI7AwYAgZPACCMrZEVinhuhHE0wfP2cn79I0CqDeA2WIMVOsZspjCz8JXxIlBeH)HIJrn8v8(CqkBiNOLxGmiGapOMTcdI7A29bBM3T)U1J2kHRTqZwHbXDnBG7cK5lFBkYY9VA27fP5G6i0JE0JMv53gXDTvrsxKrsNWPtLMnAToYjAnlnNWqnBfnVvayq)jmHwG7jejcKVtcX4BcTU436eUxGmO9GjS5IpHfZWfR5GjmGRCI3YeqHf5pHQO)esFCx535Gj06MZyiroOKgToHdpHw3CgdjYbL0O8ErAoO1juivQvqzcOWI8Nq7O)esFCx535Gj06LXpgFjUKgToHdpHwVm(X4lXL0O8ErAoO1juivQvqzcycinNWqnBfnVvayq)jmHwG7jejcKVtcX4BcTUroH5utTeFSoH7fidApycBU4tyXmCXAoycd4kN4Tmbuyr(tOWP)esFCx535Gj06ax59YhjnkVxKMdADchEcToWvEV8rsJwNqHuPwbLjGclYFcvd6pH0h3v(DoycTEz8JXxIlPrRt4WtO1lJFm(sCjnkVxKMdADcfsLAfuMakSi)juLk6pH0h3v(DoycTEkZ9rsJwNWHNqRNYCFK0O8ErAoO1juivQvqzcOWI8NqvQO)esFCx535Gj06LXpgFjUKgToHdpHwVm(X4lXL0O8ErAoO1juivQvqzcOWI8NqvcN(ti9XDLFNdMqRNYCFK0O1jC4j06Pm3hjnkVxKMdADcfsLAfuMaMasZjmuZwrZBfag0FctOf4EcrIa57Kqm(MqRbpwXygRt4EbYG2dMWMl(ewmdxSMdMWaUYjEltafwK)ekC6pH0h3v(DoycTEkZ9rsJwNWHNqRNYCFK0O8ErAoO1juivQvqzcOWI8Nq1G(ti9XDLFNdMqRxg)y8L4sA06eo8eA9Y4hJVexsJY7fP5GwNqHuPwbLjGclYFcvd6pH0h3v(DoycTEz8JXxIlPrRt4WtO1lJFm(sCjnkVxKMdADcRjHct1ef2ekKk1kOmbuyr(tOAq)jK(4UYVZbtO1lJFm(sCjnADchEcTEz8JXxIlPr59I0CqRtOqQuRGYeqHf5pH0e6pH0h3v(DoycToWvEV8rsJY7fP5GwNWHNqRdCL3lFK0O1juivQvqzcOWI8Nqae9Nq6J7k)ohmHwh4kVx(iPr59I0CqRt4WtO1bUY7LpsA06ekKk1kOmbuyr(ti9s)jK(4UYVZbtO1bUY7LpsAuEVinh06eo8eADGR8E5JKgToHcPsTcktafwK)eQsnO)esFCx535Gj06Pm3hjnADchEcTEkZ9rsJY7fP5GwNqHIuTcktafwK)eQsnO)esFCx535Gj06LXpgFjUKgToHdpHwVm(X4lXL0O8ErAoO1juivQvqzcOWI8Nqv2r)jK(4UYVZbtO1lJFm(sCjnADchEcTEz8JXxIlPr59I0CqRtOqQuRGYeWeqAErG8DoycvJewHbX9eAq90YeqnlWLJHmxZcaaqcvtYSciH0C1Ui(MacaaqcbWxBaxcPxltyK0fzKjGjGaaaKq6dx5eVP)eqaaasinKqHbi4btiaogrXBKjGaaaKqAiH00OUinhmHICLx8(Kq7tOA6xokKqH9fWegkJjHc58jH(p4btigFtiYPbIs8jmW95QDeuMacaaqcPHecGNR8Gjmctb(E4RyclhmH00BrW9eQM51MWIKR8jmcdNdo4qBpjC4jejcC5kFcX2lqM7bbKqowc3h4II3bRbX9oHc1iXoHlNHaNraj8cKPmcktabaaiH0qcfgGGhmHruZyEczXXzMeo8ecCFGlswtcfga4ewzciaaajKgsOWae8GjeaZ(jKMFUyltabaaiH0qcTi6lBjeJVjKMdhAnrroycjpgFFcnx5nju4aizciaaajKgsOA(ICLhmHcZUVhEltabaaiH0qcPP5U1tcz6Nqw0jo5(Y23eIWsiASUtyz2xGciHmatOq00VgCILTVcktabaaiH0qcz)WamHyLTNW(cK5E4DcX4Bczre(NeYbE)RmbmbeaaGekmv7dmZbti5X47tyGlswtcjpbYBzcfgHWboDcDUtd4QveJXKWkmiU3jK7gbitaRWG4ElbUpWfjRrDf2twZyovJJZmjGvyqCVLa3h4IK1OUc73hSzE3(72seMc6zz8JXxIlBeH)HIJrn8v8(CqkBiNOLxGmiGapycyfge3BjW9bUiznQRW(a3fiZx(2uKL7FtatabaaiHct1(aZCWeELFfqchK4t4G7jScdFtiQtyPSqMI0CzciaKq6dxTepHiSeg9wVpHgUtKqGvpjKZSjKd8(xltiFty0NqqUB9Kq)hmHdUNqoW7FtyGlsYtigFtilIW)KqHCUtd0u3hCcyfuMawHbX9wraxTe3seMIbjEAP344Pm3hjiNH0CQbjE59I0CW44kmiLN6(frVPvvCCGR8E5Ju59bNa24y6zz8JXxIlBeH)HIJrn8v8(CqkBiNOLxGmiGapyCCGZnG8OUCFWM5D7VB5EXc5nTebWeWkmiU3QRWEGmII3KawHbX9wDf2RSwurAULEjEfxTpWmNciUQVLkldZvmL5(ifRURWE8tTeFK4EzgCsGHbGc3U44PwIpsCVmdojWWaWiPloEQL4Je3lZGtcmm0sV0HpWvEV8rQ8(GtaBcyfge3B1vyVYArfP5w6L4vW4ibYCkZjUdwl6TLkldZvSm(X4lXLnIW)qXXOg(kEFoiLnKt0XXlJFm(sCzJCmgdvZSepoEz8JXxIlVranQCkrebUjbeaaGeAbouNquNqrEpgbKWHNqG7vEFsyGZnG8OENqSLlMqYJCIewHac8(ugJasitFWecYSiNiHICLx8(itabaaiHvyqCVvxH9lJtvHbXDkdQhl9s8ke5kV49XseMcrUYlEFKGOEkpCATlbeaaGewHbX9wDf2J7lhfOmVaAjctHqBHaPUY7JuKR8I3hjiQNYdN2iTd)wiqQR8(if5kV49rICAvd7embeaaGewHbX9wDf23xGm3d3seMIkmiLN6(frVvOcFGR8E5Ju59bNaw59I0Cq8lJFm(sCzJi8puCmQHVI3Ndszd5eT8cKbbe4bT0lXRiclWRMFWg9tA4CWbhA7H(3hSzE3(7obeasOWuKXuZ7eIC0GktcJWW5Gdo02tc7lqM7HNqm(MWg5eMtdtTeFsO6jKfr4FKjGvyqCVvxH9KgohCWH2ES0G8tfavOIolrykgK4bi9IVcds5PUFr0BfQWVm(X4lXLnIW)qXXOg(kEFoiLnKt0YlqgeqGheVq0tGR8E5Ju59bNa244aNBa5rD5(GnZ72F3Y9IfYBaQGiakyciaKqHPiJPM3je5ObvMeQMFWM5D7V7e2xGm3dpHy8nHnYjmNgMAj(Kq1tin19bNa2eQEczre(hzcyfge3B1vy)(GnZ72F3wAq(PcGkurNLimfds8aKEXxHbP8u3Vi6Tcv4dCL3lFKkVp4eWkVxKMdIFz8JXxIlBeH)HIJrn8v8(CqkBiNOLxGmiGapiEG7vkjnCo4GdT9KacaaqcRWG4ERUc77lqM7HBjctrfgKYtD)IO3kuHNEcCL3lFKkVp4eWkVxKMdIFz8JXxIlBeH)HIJrn8v8(CqkBiNOLxGmiGapOLEjEfrybE6dxTeN(jnCo4GdT9q)4(YrbQaUAjEciaKqHPiJPM3je5ObvMeQM(LJcjuyFbmH0Mq6dxTepH9fiZ9WtigFtyJCcZPHPwIpju9e6CNgOPUp4eWMq1tilIW)itaRWG4ERUc7X9LJcuMxaT0G8tfavOIolryk6pdYjAjUVCuGkGRwIJFqIhG2HVcds5PUFr0BfQWtpbUY7LpsL3hCcyL3lsZbXVm(X4lXLnIW)qXXOg(kEFoiLnKt0YlqgeqGhepW9kLKgohCWH2EWh4CdipQld4QL4Y9IfYBasN0UeqaiHctrgtnVtiYrdQmjun9lhfsOW(cycPnH0hUAjEc7lqM7HNqm(MWg5eMtdtTeFsO6j05onqtDFWjGnHQNqweH)rMawHbX9wDf2hWvlXT0G8tfavOIolryk6pdYjAjUVCuGkGRwIJFqIhG2HVcds5PUFr0BfQWtpbUY7LpsL3hCcyL3lsZbXVm(X4lXLnIW)qXXOg(kEFoiLnKt0YlqgeqGhepW9kL4(YrbkZlGjGvyqCVvxH9a5dI7jGvyqCVvxH9bUlqMV8TPil3)AjctXweNwaeDjGvyqCVvxH9nWxlfhJIS6bXDlrykizWWK33I4sgG43I4aearxcyfge3B1vy)wIalIBjctrGZnG8OUCFWM5D7VB5EXc5nafo(Pm3h5(GnZ7MQilhK7Y7fP5GjGvyqCVvxH9bUlqMV8TPil3)AjctbjdgMCFWM5D7VBjipQJh8KmyyYgDItUVS9vcYJ6XXyicCd1EXc5naTJUeWkmiU3QRW(9bBM3T)UTeHPyz8JXxIlBKJXyOAML44jcGY9IfYBf0HxiL1IksZLxTpWmNciUQFCSqtTeFKds8udNcyyOeUD0Qg0HFkZ9rwoXxkXYlIlEFIJNAj(ihK4PgofWWqjC7OfarhE6zkZ9rwoXxkXYlIlEFeuq8c1aVXqn1s8PLrXHwtuKdQqvCmjdgMu81qfmVu(vYauWeWkmiU3QRW(9bBM3T)UTeHPyz8JXxIlVranQCkrebUbprauUxSqERGo8cf4CdipQlBGVwkogfz1dI7Y9IfYBaAxCCGZnG8OUSb(AP4yuKvpiUl3lwiVPns6eeVqcrYGHjjnCoOHPhjdW44Pm3hz5eFPelViU49rEVinhmoElei1vEFKfiylroTQOtW4ysE34Xqe4gQ9IfYBAvrhDXXkRfvKMlVAFGzofqCv)4ysE34Xqe4gQ9IfYBaQYo8BHaPUY7JSabBjYPvfDcIxOg4ngQPwIpTmko0AIICqfQIJjzWWKIVgQG5LYVsgGcMawHbX9wDf2VpyZ8U93TLimf0JYArfP5sghjqMtzoXDWArVXteaL7flK3kOdVqcrYGHjjnCoOHPhjdW44Pm3hz5eFPelViU49rEVinhmoElei1vEFKfiylroTQOtW4ysE34Xqe4gQ9IfYBAvrhDXXkRfvKMlVAFGzofqCv)4ysE34Xqe4gQ9IfYBaQYo8BHaPUY7JSabBjYPvfDcIxOg4ngQPwIpTmko0AIICqfQIJjzWWKIVgQG5LYVsgGcIxi6jWvEV8r6pSCdFbJJdCUbKh1LbUlqMV8TPil3)k3lwiVPns6embScdI7T6kSFFWM5D7VBlz6tXXWOicGkuzjctXY4hJVex2ic)dfhJA4R495Gu2qorlVazqabEq8a3RKIiakvj3seyrC8cjejdgMK0W5GgMEKmaJJNYCFKLt8LsS8I4I3h59I0CW44TqGux59rwGGTe50QIobJJj5DJhdrGBO2lwiVPvfD0fhRSwurAU8Q9bM5uaXv9JJj5DJhdrGBO2lwiVbOk7WVfcK6kVpYceSLiNwv0jiEHAG3yOMAj(0YO4qRjkYbvOkoMKbdtk(AOcMxk)kzakycyfge3B1vyFuCO1ef5GwIWuyUYBOv40e8c1aVXqn1s8PLrXHwtuKdsRk80djdgMu81qfmVu(vYamoElei1vEFKfiylroajcG4PhsgmmP4RHkyEP8RKbOGjGvyqCVvxH9m9PqZfT0lXRa5DyzMI0CkbYu(WisbELOWTeHPiW5gqEuxUpyZ8U93TCVyH8Mwv0Hxisgmm5(GnZ72F3sgGXXK8UXJHiWnu7flK3amsvXXK8UXJHiWnu7flK30QIMrxCmjdgMK0W5GgMEKmafmbScdI7T6kSNPpfAUOLEjEfrlB3)2uyl3bTeHPiW5gqEuxUpyZ8U93TCVyH8Mwv0Hxisgmm5(GnZ72F3sgGXXK8UXJHiWnu7flK3auLWJJj5DJhdrGBO2lwiVPvLWPtWeWkmiU3QRWEM(uO5Iw6L4viwHICpvJ7FOezAuWseMIaNBa5rD5(GnZ72F3Y9IfYBAvrhEHizWWK7d2mVB)DlzaghtY7gpgIa3qTxSqEdWiTloMK3nEmebUHAVyH8MwvQOtWeWkmiU3QRWEM(uO5Iw6L4vWv(nkUBerobfqE0VuHva9uglrykcCUbKh1L7d2mVB)Dl3lwiVPvfD4fIKbdtUpyZ8U93TKbyCmjVB8yicCd1EXc5navrtIJj5DJhdrGBO2lwiVPvfD0jycyfge3B1vyptFk0Crl9s8kqEplty4BtbIuI8trEJXseMIaNBa5rD5(GnZ72F3Y9IfYBAvrhEHizWWK7d2mVB)DlzaghtY7gpgIa3qTxSqEdqv0fhtY7gpgIa3qTxSqEtlnZobtaRWG4ERUc7z6tHMlAPxIxbMPepfhJISMXClrykcCUbKh1L7d2mVB)Dl3lwiVPvfD4fIKbdtUpyZ8U93TKbyCmjVB8yicCd1EXc5navPkoMK3nEmebUHAVyH8Mwv0rNGjGvyqCVvxH9m9PqZfT0lXRGWuGOA4BtrwGe3seMIaNBa5rD5(GnZ72F3Y9IfYBAvrhEHizWWK7d2mVB)DlzaghtY7gpgIa3qTxSqEdqvQIJj5DJhdrGBO2lwiVPLMyNGjGvyqCVvxH9m9PqZfT0lXROd12uCmkSTMVEzO6zrypbScdI7T6kSNPpfAUyNawHbX9wDf2tA4CqkmMvajGvyqCVvxH9KF7V2qoHLimfKmyyY9bBM3T)ULmataRWG4ERUc7nicCttbGndiH49XseMcsgmm5(GnZ72F3sqEuhp4jzWWKn6eNCFz7ReKh1taRWG4ERUc7Xq7jnCoycyfge3B1vyF5H3ZwgQqzmjGvyqCVvxH9KfbfhJAwuWwBjctbjdgMCFWM5D7VBjipQJh8KmyyYgDItUVS9vcYJ64jzWWK33I4sgGjGvyqCVvxH9HYyOQWG4oLb1JL9SOWOqLLEjEff)wIWu0aVXqn1s8PLrXHwtuKdsRQeWkmiU3QRW(LXPQWG4oLb1JLEjEfnYjmNAQL4tcycyfge3BzXVIq5HBOizWWS0lXRG0uGVh(kAjctbrauUxSqERGo8nNXqICqjgA7HQNfz74jzWWKyOThQEwKTl3lwiVXtYGHjVVfXL7flK3aKiaMawHbX9ww8RUc7lpGUpuf28TXXd2SeHPGKbdtEFlIlzaIpW5gqEuxUpyZ8U93TCVyH8Mw7saRWG4Ell(vxH9nWxlfhJIS6bXDlrykizWWK33I4sgG43I4aunOlbScdI7TS4xDf2tAkW3dFfTe5Z3Lb4qHWuqeaL7flK3kOdFZzmKihuIH2EO6zr2oEsgmmjgA7HQNfz7Y9IfYB8KmyyY7BrC5EXc5najcGwIWuqYGHjVVfXLmaX3aVXqn1s8PLrXHwtuKdsBKjGvyqCVLf)QRW(a3bVOBjctHqKmyyY7BrCjdW4ysgmm5(GnZ72F3sgG4xg)y8L4Yg5ymgQMzjUG4vwlQinxE1(aZCkG4Q(jGvyqCVLf)QRW(gDItUVS9nbScdI7TS4xDf2VLiWI4jGvyqCVLf)QRW(g4RLIJrrw9G4ULimfKmyyY7BrCjdq8bo3aYJ6Y9bBM3T)UL7flK30Axcyfge3BzXV6kSN0uGVh(kAjctbjdgM8(wexUxSqEtlraunHiL2LaMawHbX9w2iNWCQPwIpQRW(TiqobfPHh1seMILXpgFjUmkYyO4yudUtr(T)A7R8cKbbe4bXtYGHjJImgkog1G7uKF7V2(k3lwiVbirambScdI7TSroH5utTeFuxH9HLPXHCcksdpQLimflJFm(sCzuKXqXXOgCNI8B)12x5fidciWdINKbdtgfzmuCmQb3Pi)2FT9vUxSqEdqIaycyfge3BzJCcZPMAj(OUc7dLhUHIKbdZsVeVcstb(E4ROLimfnWBmutTeFAzuCO1ef5GkuHNiak3lwiVvqhEHMYCFKIv3vyV8ErAoyCCGR8E5Ju59bNaw59I0CqbXRSwurAU8Q9bM5uaXv9Xl0weNwAgDXX0tGZnG8OUmWDWl6Y9IfYBbtaRWG4ElBKtyo1ulXh1vyFG7Gx0TeHPqisgmm59TiUKbyCmjdgMCFWM5D7VBjdq8lJFm(sCzJCmgdvZSexq8kRfvKMlVAFGzofqCv)eWkmiU3Yg5eMtn1s8rDf23OtCY9LTVwIWuaEsgmmzJoXj3x2(kb5rD8c1aVXqn1s8PLrXHwtuKdsRQ44TqGux59rwGGTe50QYobtaRWG4ElBKtyo1ulXh1vy)wIalIBjctbjdgMCFWM5D7VBjdW4yHizWWK33I4Y9IfYBaseaJJ3I40sV0jyCmjdgMeBVdGLaK7flK3auL0UeWkmiU3Yg5eMtn1s8rDf2hwMghYjOin8OwIWu0FOi5otlh03iPxQibgIJd4QL4TIiJJfIKbdtUpyZ8U93TKbiEL1IksZLxTpWmNciUQp(Pm3hPy1Df2lVxKMdkycyfge3BzJCcZPMAj(OUc7dCh8IEcyfge3BzJCcZPMAj(OUc7lpGUpuf28TXXd2SeHPGKbdtEFlIlzaIpW5gqEuxUpyZ8U93TCVyH8Mw7WlejVB8yicCd1EXc5nT0m7IJjzWWK7d2mVB)DlzaghtY7gpgIa3qTxSqEdWiPtq8BHaPUY7JSabBjYPfazxcyfge3BzJCcZPMAj(OUc7VAFGzEcyfge3BzJCcZPMAj(OUc7BGVwkogfz1dI7wIWuSm(X4lXL3iGgvoLiIa3GNKbdtEFlIlzaIpW5gqEuxUpyZ8U93TCVyH8Mw7WlejdgMCFWM5D7VBjdW4ysE34Xqe4gQ9IfYBagjDXXGNKbdt2OtCY9LTVsgGXX0ZuM7JSrN4K7lBFXtY7gpgIa3qTxSqEtlnHEfe)wiqQR8(ilqWwICATZUeWkmiU3Yg5eMtn1s8rDf2tAkW3dFfTeHPGKbdtEFlIlzaIxi6HKbdtUpyZ8U93TCVyH8ooElIdq7Otq8c1aVXqn1s8PLrXHwtuKdQqf(TqGux59rwGGTe50Qg2fh3aVXqn1s8PLrXHwtuKdQisbtaRWG4ElBKtyo1ulXh1vyFd81sXXOiREqC3seMcsgmm59TiUKbi(aNBa5rD5(GnZ72F3Y9IfYBATdVqKmyyY9bBM3T)ULmaJJj5DJhdrGBO2lwiVbyK0fhdEsgmmzJoXj3x2(kzaghtptzUpYgDItUVS9fpjVB8yicCd1EXc5nT0e6vq8BHaPUY7JSabBjYP1o7saRWG4ElBKtyo1ulXh1vy)weiNGI0WJAjctr)HIK7mTCqFJKEPIeyiooGRwI3kImowisgmm5(GnZ72F3sgG4vwlQinxE1(aZCkG4Q(4NYCFKIv3vyV8ErAoOGjGvyqCVLnYjmNAQL4J6kSN0W5Gdo02JLbbemNAQL4tRqLLimfKmyyY7BrCjipQhhh4oidAKkrbeNPPcCFUiWrULBJw7Wp1s8rI7LzWjbggakC7saRWG4ElBKtyo1ulXh1vypPHZbjRbNLimfKmyyY7BrCjipQhhh4oidAKkrbeNPPcCFUiWrULBJw7Wp1s8rI7LzWjbggakC7saRWG4ElBKtyo1ulXh1vyp4weCNA51AjctbjdgM8(wexYaeVqnWBmutTeFAzuCO1ef5G0QkoElei1vEFKfiylroTQStWeWkmiU3Yg5eMtn1s8rDf2hfhAnrroOLimfKmyysXVbK5DtrY9tSih8RKbi(g4ngQPwIpTmko0AIICqAfEcyfge3BzJCcZPMAj(OUc75EBkgcCJLimfKmyyY7BrCjdWeWkmiU3Yg5eMtn1s8rDf2tA4CWbhA7jbScdI7TSroH5utTeFuxH9KgohKSgCjGvyqCVLnYjmNAQL4J6kSFlcKtqrA4rtaRWG4ElBKtyo1ulXh1vyFyzACiNGI0WJMawHbX9w2iNWCQPwIpQRW(O4qRjkYb1SnWh0wbGIup6rRb]] )


end
