-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 71 )

    local base_rage_gen, arms_rage_mult = 1.75, 4.286

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand = {
            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = 'mainhand_speed',

            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.swings.mainhand_speed
            end,
        }
    } )
    
    -- Talents
    spec:RegisterTalents( {
        war_machine = 22624, -- 262231
        sudden_death = 22360, -- 29725
        skullsplitter = 22371, -- 260643

        double_time = 19676, -- 103827
        impending_victory = 22372, -- 202168
        storm_bolt = 22789, -- 107570

        massacre = 22380, -- 281001
        fervor_of_battle = 22489, -- 202316
        rend = 19138, -- 772

        second_wind = 15757, -- 29838
        bounding_stride = 22627, -- 202163
        defensive_stance = 22628, -- 197690

        collateral_damage = 22392, -- 268243
        warbreaker = 22391, -- 262161
        cleave = 22362, -- 845

        in_for_the_kill = 22394, -- 248621
        avatar = 22397, -- 107574
        deadly_calm = 22399, -- 262228

        anger_management = 21204, -- 152278
        dreadnaught = 22407, -- 262150
        ravager = 21667, -- 152277
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3589, -- 208683
        relentless = 3588, -- 196029
        adaptation = 3587, -- 214027

        duel = 34, -- 236273
        disarm = 3534, -- 236077
        sharpen_blade = 33, -- 198817
        war_banner = 32, -- 236320
        spell_reflection = 3521, -- 216890
        death_sentence = 3522, -- 198500
        master_and_commander = 28, -- 235941
        shadow_of_the_colossus = 29, -- 198807
        storm_of_destruction = 31, -- 236308
    } )

    -- Auras
    spec:RegisterAuras( {
        avatar = {
            id = 107574,
            duration = 20,
            max_stack = 1,
        },
        battle_shout = {
            id = 6673,
            duration = 3600,
            max_stack = 1,
        },
        berserker_rage = {
            id = 18499,
            duration = 6,
            type = "",
            max_stack = 1,
        },
        bladestorm = {
            id = 227847,
            duration = 6,
            max_stack = 1,
        },
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        colossus_smash = {
            id = 208086,
            duration = 10,
            max_stack = 1,
        },
        deadly_calm = {
            id = 262228,
            duration = 6,
            max_stack = 1,
        },
        deep_wounds = {
            id = 262115,
            duration = 6,
            max_stack = 1,
        },
        defensive_stance = {
            id = 197690,
            duration = 3600,
            max_stack = 1,
        },
        die_by_the_sword = {
            id = 118038,
            duration = 8,
            max_stack = 1,
        },
        in_for_the_kill = {
            id = 248622,
            duration = 10,
            max_stack = 1,
        },
        intimidating_shout = {
            id = 5246,
            duration = 8,
            max_stack = 1,
        },
        mortal_wounds = {
            id = 115804,
            duration = 10,
            max_stack = 1,
        },
        overpower = {
            id = 7384,
            duration = 15,
            max_stack = 2,
        },
        rallying_cry = {
            id = 97463,
            duration = 10,
            max_stack = 1,
        },
        --[[ ravager = {
            id = 152277,
        }, ]]
        rend = {
            id = 772,
            duration = 12,
            max_stack = 1,
        },
        --[[ seasoned_soldier = {
            id = 279423,
        }, ]]
        sign_of_the_emissary = {
            id = 225788,
            duration = 3600,
            max_stack = 1,
        },
        stone_heart = {
            id = 225947,
            duration = 10,
        },
        sudden_death = {
            id = 52437,
            duration = 10,
            max_stack = 1,
        },
        sweeping_strikes = {
            id = 260708,
            duration = 12,
            max_stack = 1,
        },
        --[[ tactician = {
            id = 184783,
        }, ]]
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
    } )


    local rageSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if state.talent.anger_management.enabled and resource == "rage" then
            rageSpent = rageSpent + amt
            local reduction = floor( rageSpent / 20 )
            rageSpent = rageSpent % 20

            if reduction > 0 then
                state.cooldown.colossus_smash.expires = state.cooldown.colossus_smash.expires - reduction
                state.cooldown.bladestorm.expires = state.cooldown.bladestorm.expires - reduction
                state.cooldown.warbreaker.expires = state.cooldown.warbreaker.expires - reduction
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
    end )


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
        spec:RegisterAura( "war_veteran", {
            id = 253382,
            duration = 8
         } ) -- arms 2pc.
        spec:RegisterAura( "weighted_blade", { 
            id = 253383,  
            duration = 1,
            max_stack = 3
        } ) -- arms 4pc.

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



    -- Abilities
    spec:RegisterAbilities( {
        avatar = {
            id = 107574,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = -20,
            spendType = "rage",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 613534,

            talent = "avatar",
            
            handler = function ()
                applyBuff( "avatar" )
            end,
        },
        

        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132333,
            
            usable = function () return buff.battle_shout.remains < 10 end,
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

            startsCombat = true,
            texture = 136009,
            
            handler = function ()
                applyBuff( "berserker_rage" )
                if level < 116 and equipped.ceannar_charger then gain( 8, "rage" ) end
            end,
        },
        

        bladestorm = {
            id = 227847,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 236303,

            notalent = "ravager",
            
            handler = function ()
                applyBuff( "bladestorm" )
                if level < 116 and equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end
            end,
        },
        

        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or 1 end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132337,
            
            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd ) end,
            handler = function ()
                setDistance( 5 )
            end,
        },
        

        cleave = {
            id = 845,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132338,

            talent = "cleave",
            
            handler = function ()
                if active_enemies >= 3 then applyDebuff( "target", "deep_wounds" ) end
                if talent.collateral_damage.enabled then gain( 4, "rage" ) end
            end,
        },
        

        colossus_smash = {
            id = 167105,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 464973,

            notalent = "warbreaker",
            
            handler = function ()
                applyDebuff( "target", "colossus_smash" )

                if level < 116 then
                    if set_bonus.tier21_2pc == 1 then applyBuff( "war_veteran" ) end
                    if set_bonus.tier20_2pc == 1 then
                        if talent.ravager.enabled then setCooldown( "ravager", max( 0, cooldown.ravager.remains - 2 ) )
                        else setCooldown( "bladestorm", max( 0, cooldown.bladestorm.remains - 3 ) ) end
                    end
                end

                if talent.in_for_the_kill.enabled then
                    applyBuff( "in_for_the_kill" )
                    stat.haste = state.haste + ( target.health.pct < 20 and 0.2 or 0.1 )
                end
            end,
        },
        

        deadly_calm = {
            id = 262228,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 298660,
            
            handler = function ()
                applyBuff( "deadly_calm" )
            end,
        },
        

        defensive_stance = {
            id = 212520,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132349,

            talent = "defensive_stance",
            toggle = "defensives",
            
            handler = function ()
                if buff.defensive_stance.up then removeBuff( "defensive_stance" )
                else applyBuff( "defensive_stance" ) end
            end,
        },
        

        die_by_the_sword = {
            id = 118038,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 132336,

            toggle = "defensives",
            
            handler = function ()
                applyBuff( "die_by_the_sword" )
            end,
        },
        

        execute = {
            id = 163201,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.sudden_death.up then return 0 end
                if buff.stone_heart.up then return 0 end
                if buff.deadly_calm.up then return 0 end
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 135358,
            
            usable = function () return buff.sudden_death.up or buff.stone_heart.up or target.health.pct < ( talent.massacre.enabled and 35 or 20 ) end,
            handler = function ()
                if not buff.sudden_death.up and not buff.stone_heart.up then
                    local overflow = min( rage.current, 20 )
                    spend( overflow, "rage" )
                    gain( 0.3 * ( 20 + overflow ), "rage" )
                end
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                else removeBuff( "sudden_death" ) end

                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
            end,
        },
        

        hamstring = {
            id = 1715,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 10
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132316,
            
            handler = function ()
                applyDebuff( "target", "hamstring" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 2, "rage" ) end
            end,
        },
        

        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_strategem ) and 3 or 1 end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236171,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
        },
        

        heroic_throw = {
            id = 57755,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132453,
            
            usable = function () return target.distance > 10 end,
            handler = function ()
            end,
        },
        

        impending_victory = {
            id = 202168,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 10
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 589768,

            talent = "impending_victory",
            
            handler = function ()
                removeBuff( "victorious" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 2, "rage" ) end
            end,
        },
        

        intimidating_shout = {
            id = 5246,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132154,
            
            handler = function ()
                applyBuff( "intimidating_shout" )
            end,
        },
        

        mortal_strike = {
            id = 12294,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30 - ( ( level < 116 and equipiped.archavons_heavy_hand ) and 8 or 0 )
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132355,
            
            handler = function ()
                applyDebuff( "target", "mortal_wounds" )
                applyDebuff( "target", "deep_wounds" )
                removeBuff( "overpower" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
                if level < 116 and set_bonus.tier21_4pc == 1 then addStack( "weighted_blade", 12, 1 ) end
            end,
        },
        

        overpower = {
            id = 7384,
            cast = 0,
            charges = function () return talent.dreadnaught.enabled and 2 or 1 end,
            cooldown = 12,
            recharge = 12,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132223,
            
            handler = function ()
                if talent.dreadnaught.enabled then
                    addStack( "overpower", 15, 1 )
                else
                    applyBuff( "overpower" )
                end
            end,
        },
        

        pummel = {
            id = 6552,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132938,
            
            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        rallying_cry = {
            id = 97462,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132351,

            toggle = "defensives",
            
            handler = function ()
                applyBuff( "rallying_cry" )
            end,
        },
        

        ravager = {
            id = 152277,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -7,
            spendType = "rage",
            
            startsCombat = true,
            texture = 970854,

            talents = "ravager",
            toggle = "cooldowns",
            
            handler = function ()
                if ( level < 116 and equipped.the_great_storms_eye ) then addStack( "tornados_eye", 6, 1 ) end
                -- need to plan out rage gen.
            end,
        },
        

        rend = {
            id = 772,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132155,

            talent = "rend",
            
            handler = function ()
                applyDebuff( "target", "rend" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
            end,
        },
        

        skullsplitter = {
            id = 260643,
            cast = 0,
            cooldown = function () return 21 * haste end,
            gcd = "spell",

            spend = -20,
            spendType = "rage",
            
            startsCombat = true,
            texture = 2065621,

            talent = "skullsplitter",
            
            handler = function ()
            end,
        },
        

        slam = {
            id = 1464,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132340,
            
            recheck = function () return rage.time_to_30 end,
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
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
        

        sweeping_strikes = {
            id = 260708,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132306,
            
            handler = function ()
                -- applies sweeping_strikes (260708)
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
            
            handler = function ()
                removeBuff( "victorious" )
            end,
        },
        

        warbreaker = {
            id = 262161,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 2065633,

            talent = "warbreaker",
            
            handler = function ()                
                if talent.in_for_the_kill.enabled then
                    if buff.in_for_the_kill.down then
                        stat.haste = stat.haste + ( target.health.pct < 0.2 and 0.2 or 0.1 )
                    end
                    applyBuff( "in_for_the_kill" )
                end

                if level < 116 then
                    if set_bonus.tier21_2pc == 1 then applyBuff( "war_veteran" ) end
                    if set_bonus.tier20_2pc == 1 then
                        if talent.ravager.enabled then setCooldown( "ravager", max( 0, cooldown.ravager.remains - 2 ) )
                        else setCooldown( "bladestorm", max( 0, cooldown.bladestorm.remains - 3 ) ) end
                    end
                end

                applyDebuff( "target", "colossus_smash" )
            end,
        },
        

        whirlwind = {
            id = 1680,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132369,
            
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
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
    
        package = "Arms",
    } )

    spec:RegisterPack( "Arms", 20180714.1045, [[dm0JJaqivkEKkL0MePgfLItrP0QuPeEfPKzrkClvkr7IKFrkAyIOoMiYYev5ziQmnrfDnkv12uPuFtuvnorv5CIkuVJsvkMNOs3dr2hLkhKsvYcjL6HIkOUiLQuzJuQsvJuub5KIkKvQuzNiklvub8uvmvvQ2lO)QWGjCyQwmL8yIMmfxg1Mr4ZkLrtQonKvlQa9ArsZgQBRKDRQFlz4IYXPuflhPNlmDPUUI2UiX3vjJhrvNxPQ1tPkLMViSFGHjbVdpgVziz5LCs5l58NuovjLCoTFoZXWtVpJHNmxMQVXWZ7lgESx0vapz(EC5g4D4jQjvYWJ9Ik1rRgrRaESMiCNJEOf8y8MHKLxYjLVKZFs5uLuY50(KlFWJpB9Icp2lQuhTAeTc4XWHeEURJcGafaHdezUmvFJbIIaiCzJQhiWOOdGGOOaroeNkcJuGDGD31rbqC5bqKrRuqg2aew7bc7fvQJwnIwbq4Vbiqbq4aXvrt9wI(BzgT2OCekWoWU76mqupEpqi19FJdGO19giYraHn5qCQimYwGq3tHbILByGWPmq0fqKnBG4K6eJJmmQBMceorZuGihUWveZaiolp0bc0dezuurr9EnaIOacudew8ZeOoaccATaIwNbIC4dqyyRjbHcSdSZEFrbIwNbc7fDfarKXsKJr2B9gvVgarociUqymqyXaXvrtf9Bar9abALrRuq)gqKd4BmqSkdJr)gqqqRfqCXEw9arCH(Tqbearo6bIwNbIf7FJwSgaX(AcelFpqusPhO6DmEpqemdehSVaISkdiMzaXLo)abLDPo630mZJa9Bab5sgiYb8n2Edq06Oai09Sm(dG4sNFGWbIl2ZQhiIl0VbexEaem5ZyzZgGWIjkkdeTode8VHEgiwUHbcklR1IFJ3O6dnacRzdexEaegg77zdqquuGiQfdeu2J6vWdgfDaVdpb63W8OD6g3W7qYscEhE43TWSbQn8iPOMPihEO8YrFae5scimtQ3O6bIBbqKSICarAGWWwtccLSWveZyelp0vM66Hhx2O6Hhk)gydjlp4D4HF3cZgO2WJKIAMIC4rwf2uxVYc7go6IUuuE5Opac7aIBdePbcBaczvytD9kzHRiMXiwEORO8YrFae5ce5bejsae2aeS9mrzzSrDXOn9EueJwNhStBDGinqiRcBQRxPZ0cjhy2ZuuE5OpaICbI8acBbcBHhx2O6Hhd7g8(H0XlydjJCW7Wd)UfMnqTHhjf1mf5WJ1KGqjlCfXmgXYdDLPUE4XLnQE4rw4kIzmILh6WgswoH3Hh(DlmBGAdpskQzkYHhQVXarUar(tgisde2aeYQWM66vg2n49dPJxkkVC0haHDab5aIejaIBaI2X83kd7g8(H0Xlf)UfMnaHTWJlBu9WtK6eJJmmQBMcBiz2hEhE43TWSbQn8iPOMPihEy7zIYYyJ6IrB69OigTopyN26arAGWWwtccLSWveZyelp0vM66bI0aHSkSPUELSWveZyelp0vuE5Opac7aI8bePbIBaImkNYytAujPKfUIygJy5Ho84Ygvp8OZ0cjhy2ZGnKSBdVdp87wy2a1gEKuuZuKdpwtccvmng(hg2BDfLDzdejsaewtccv01ZdD2PTIYUSHhx2O6HhM8SC2mSHKLF4D4HF3cZgO2WJKIAMIC4XWwtccLSWveZyelp0vuE5Opac7aICQSpqKgiYOCkJnPrLKAv02XJOPOuzGinqydqCdqynjiug2n49dPJxQzgqKibqCdq0oM)wzy3G3pKoEP43TWSbiSfECzJQhESWUHJUOlydjlFW7Wd)UfMnqTHhjf1mf5WJHTMeekzHRiMXiwEORMzarAGWgGqwf2uxVYWUbVFiD8sr5LJ(aiSdiUnqKibqCdq0oM)wzy3G3pKoEP43TWSbiSfECzJQhEOEk(gtHnKSCm8o84Ygvp8SkA74r0uuQm8WVBHzduBydjlPKH3Hhx2O6HNkfMMvxmfE43TWSbQnSHKLusW7Wd)UfMnqTHhjf1mf5Wt7y(BfbttPOJIyy5DJzf)UfMnarAGWgGG6BmqyhjGGCjdejsaeg2AsqOKfUIygJy5HUAMbePbczvytD9aHTWJlBu9WZLoIIVqVb2qYskp4D4HF3cZgO2WJKIAMIC45gGODm)TIGPPu0rrmS8UXSIF3cZgGinqydqq9ngiSJeqqUKbIejacdBnjiuYcxrmJrS8qxr5LJ(aiSdiKvHn11RwfTD8iAkkvwr5LJ(aisdeYQWM66vRI2oEenfLkRO8YrFae2be5PSpqyl84Ygvp8eyFbBydpm5z5Sz4DizjbVdp87wy2a1gEKuuZuKdpuE5OpaICjbeMj1Bu9aXTaiswroGinqyyRjbHsw4kIzmILh6ktD9WJlBu9WdLFdSHKLh8o8WVBHzduB4rsrntro8iRcBQRxzHDdhDrxkkVC0haHDaXTbI0aHnaHSkSPUELSWveZyelp0vuE5OpaICbI8aIejacBac2EMOSm2OUy0MEpkIrRZd2PToqKgiKvHn11R0zAHKdm7zkkVC0harUarEaHTaHTWJlBu9WJHDdE)q64fSHKro4D4HF3cZgO2WJKIAMIC4XAsqOKfUIygJy5HUYuxp84Ygvp8ilCfXmgXYdDydjlNW7Wd)UfMnqTHhjf1mf5Wd13yGixGi)jdePbcBacBaczvytD9kd7g8(H0XlfLxo6dGWoGGCarAG4gGWAsqOmSBW7hshVuZmGWwGircG4gGODm)TYWUbVFiD8sXVBHzdqyl84Ygvp8ePoX4idJ6MPWgsM9H3Hh(DlmBGAdpskQzkYHh2EMOSm2OUy0MEpkIrRZd2PToqKgimS1KGqjlCfXmgXYdDLPUEGinqiRcBQRxjlCfXmgXYdDfLxo6dGWoGiFarAG4gGiJYPm2KgvskzHRiMXiwEOdpUSr1dp6mTqYbM9mydj72W7Wd)UfMnqTHhjf1mf5WJHTMeekzHRiMXiwEORO8YrFae2be5uzFGinqq9ngiYfiYFYarAGWgG4gGWAsqOmSBW7hshVuZmGircG4gGODm)TYWUbVFiD8sXVBHzdqyl84Ygvp8yHDdhDrxWgsw(H3Hh(DlmBGAdpskQzkYHhdBnjiuYcxrmJrS8qxnZaI0aHnaHSkSPUELHDdE)q64LIYlh9bqyhqCBGircG4gGODm)TYWUbVFiD8sXVBHzdqyl84Ygvp8q9u8nMcBiz5dEhE43TWSbQn8iPOMPihESMeeQkfMMvxmvfTltfiibe5bePbcBaI2X83kdLDZ7Zn9wXVBHzdqKibqW2ZeLLXgLtL6Ek1hdD2tz)q3Fdqyl84Ygvp8SkA74r0uuQmSHKLJH3Hhx2O6HNkfMMvxmfE43TWSbQnSHKLuYW7Wd)UfMnqTHhjf1mf5Wd13yGWosarotgisKaimS1KGqjlCfXmgXYdD1mdisKaiSMeeQyAm8pmS36kk7YgisKaiSMeeQORNh6StBfLDzdpUSr1dpm5z5SzydB4XWe(e3W7qYscEhECzJQhE8zxdVBxMk8WVBHzduBydjlp4D4XLnQE4rQ70ngE43TWSbQnSHKro4D4HF3cZgO2WJlBu9Wdf9BJIyilm2Zc0VniM9KYb8iPOMPihEUbiSMeeQMxzT3O6vZm459fdpu0VnkIHSWyplq)2Gy2tkhWgswoH3Hh(DlmBGAdpskQzkYHhdBnjiuYcxrmJrS8qxzQRhECzJQhEWOn9og5GtZ2I)g2qYSp8o84Ygvp8mdEGAEfWd)UfMnqTHnKSBdVdp87wy2a1gEKuuZuKdpg2AsqOKfUIygJy5HUAMbpUSr1dpw4QmdIjDpSHKLF4D4HF3cZgO2WJKIAMIC4XWwtccLSWveZyelp0vZm4XLnQE4XIPbttf9BWgsw(G3Hh(DlmBGAdpskQzkYHhdBnjiuYcxrmJrS8qxzQRhisdeYQWM66vRI2oEenfLkRO8YrFae2bejPSpqKgiO(gde5ceKlz4XLnQE4XPs)5rxuk)nSHKLJH3Hh(DlmBGAdpskQzkYHNiJX4r70nUd1LoIIVqVbiSdiscisde2aeYQWM66vYcxrmJrS8qxr5LJ(aiYfiYdisKaiSbiKvHn11R0zAHKdm7zkkVC0harUarEarAGqwf2uxVsw4kIzmILh6kkVC0haHDar(aI0aHHTMeekzHRiMXiwEORm11de2ce2cpUSr1dpXfZzOFBenfLkhWgswsjdVdp87wy2a1gEKuuZuKdp2aeTJ5Vvlpcxszf)UfMnarAGOD6g3kD2XTUkt2arUab5SpqylqKibq0oDJBLo74wxLjBGixGiVKHhx2O6Hh68hUSr1pWOOHhmk6X7lgEyYZYzZWgswsjbVdp87wy2a1gECzJQhEOZF4Ygv)aJIgEWOOhVVy4jq)gMhTt34g2WgEYOSSwwEdVdjlj4D4HF3cZgO2WtVpJHhzn)gZrmC6cXbSHKLh8o8WVBHzduB4P3NXWd2tbf6Jys9LtheShnSHKro4D4HF3cZgO2WtVpJHhdtGWSb2qYYj8o84Ygvp8y5DJ5rOxZgE43TWSbQnSHKzF4D4HF3cZgO2Wgs2TH3Hh(DlmBGAdpzvJQhEkSzC5u4XLnQE4jRAu9Wg2WgEsHPbQEiz5LCs5l58NuovjLCs2hEUC6J(TaEGNmArGWm84YgvFOYOSSwwEtIa7rQA07ZysYA(nMJy40fIdWox2O6dvgLL1YYBTiPjrvgn69zmjSNck0hXK6lNoiypAWox2O6dvgLL1YYBTiPPp3w83EJQxJEFgtYWeimBa7CzJQpuzuwwllV1IKMwE3yEe61Sb7UvG48EwOxnqqDKbiSMeeSbiI27aiSyIIYaHSwwEdew8g6dGWFdqKr5Bzw1n63acuaeM6zfyNlBu9HkJYYAz5TwK0mEpl0REeT3byNlBu9HkJYYAz5TwK0mRAu9A8(IjvyZ4YPGDGD3kqyVJ8SC2Sbi4uy6EGOrlgiADgiCzxuGafaHNIJWUfMvGDUSr1hK8zxdVBxMkyNlBu9HwK0uQ70ngS7wbI76OaiqbqSQOX7bIUaImkNc)nqiRcBQRpaccATaclg9BaHlLid)TJX7bIzWgGWmPOFdiwvk8I)wb2DRUSr1hArsZSQr1RX7lMuHnJlNQbIGK1KGqrzzQyoINJqnZa7CzJQp0IKMZGhOMxA8(Ijrr)2OigYcJ9Sa9BdIzpPCObIG0nwtccvZRS2Bu9QzgyhyNlBu9HwK0eJ207yKdonBl(BnqeKmS1KGqjlCfXmgXYdDLPUEWox2O6dTiP5m4bQ5va25YgvFOfjnTWvzget6EnqeKmS1KGqjlCfXmgXYdD1mdSZLnQ(qlsAAX0GPPI(nnqeKmS1KGqjlCfXmgXYdD1mdSZLnQ(qlsA6uP)8OlkL)wdebjdBnjiuYcxrmJrS8qxzQRpTSkSPUE1QOTJhrtrPYkkVC0h2LKY(PP(gNl5sgSZLnQ(qlsAgxmNH(Tr0uuQCObIGuKXy8OD6g3H6shrXxO3yxsPTrwf2uxVsw4kIzmILh6kkVC0h5MxIe2iRcBQRxPZ0cjhy2ZuuE5OpYnV0YQWM66vYcxrmJrS8qxr5LJ(WU8L2WwtccLSWveZyelp0vM66T1wWox2O6dTiPjD(dx2O6hyu0A8(IjXKNLZM1arqYM2X83QLhHlPSIF3cZM0Tt34wPZoU1vzYoxYzFBtKOD6g3kD2XTUkt25MxYGDUSr1hArst68hUSr1pWOO149ftkq)gMhTt34gSdSZLnQ(qXKNLZM1IKMu(nAGiir5LJ(ixsMj1Bu93IKvKlTHTMeekzHRiMXiwEORm11d2DRUSr1hkM8SC2SwK0KYVrdebjkVC0h5MuYPTrwf2uxVsw4kIzmILh6kkVC0h5MxIe2iRcBQRxPZ0cjhy2ZuuE5OpYnV0YQWM66vYcxrmJrS8qxr5LJ(WU8L2WwtccLSWveZyelp0vM66T1wWox2O6dftEwoBwlsAAy3G3pKoEPbIGKSkSPUELf2nC0fDPO8YrFy3TtBJSkSPUELSWveZyelp0vuE5OpYnVejSHTNjklJnQlgTP3JIy068GDARNwwf2uxVsNPfsoWSNPO8YrFKBE2AlyNlBu9HIjplNnRfjnLfUIygJy5HUgicswtccLSWveZyelp0vM66b7CzJQpum5z5SzTiPzK6eJJmmQBMQbIGe134CZFYPTXgzvytD9kd7g8(H0XlfLxo6d7ix6BSMeekd7g8(H0Xl1mZ2ejUPDm)TYWUbVFiD8sXVBHzJTGDUSr1hkM8SC2SwK0uNPfsoWSNPbIGeBptuwgBuxmAtVhfXO15b70wpTHTMeekzHRiMXiwEORm11Nwwf2uxVsw4kIzmILh6kkVC0h2LV03Kr5ugBsJkjLSWveZyelp0b7CzJQpum5z5SzTiPPf2nC0fDPbIGKHTMeekzHRiMXiwEORO8YrFyxov2pn134CZFYPT5gRjbHYWUbVFiD8snZsK4M2X83kd7g8(H0Xlf)UfMn2c25YgvFOyYZYzZArstQNIVXunqeKmS1KGqjlCfXmgXYdD1mlTnYQWM66vg2n49dPJxkkVC0h2D7ejUPDm)TYWUbVFiD8sXVBHzJTGDUSr1hkM8SC2SwK0Cv02XJOPOuznqeKSMeeQkfMMvxmvfTltLuEPTPDm)TYqz38(CtVv87wy2KibBptuwgBuovQ7PuFm0zpL9dD)n2c25YgvFOyYZYzZArsZkfMMvxmfSZLnQ(qXKNLZM1IKMm5z5SznqeKO(gBhPCMCIeg2AsqOKfUIygJy5HUAMLiH1KGqftJH)HH9wxrzx2jsynjiurxpp0zN2kk7YgSdSZLnQ(qfOFdZJ2PBCRfjnP8B0arqIYlh9rUKmtQ3O6VfjRixAdBnjiuYcxrmJrS8qxzQRhSZLnQ(qfOFdZJ2PBCRfjnnSBW7hshV0arqswf2uxVYc7go6IUuuE5OpS72PTrwf2uxVsw4kIzmILh6kkVC0h5MxIe2W2ZeLLXg1fJ207rrmADEWoT1tlRcBQRxPZ0cjhy2ZuuE5OpYnpBTfSZLnQ(qfOFdZJ2PBCRfjnLfUIygJy5HUgicswtccLSWveZyelp0vM66b7CzJQpub63W8OD6g3ArsZi1jghzyu3mvdebjQVX5M)KtBJSkSPUELHDdE)q64LIYlh9HDKlrIBAhZFRmSBW7hshVu87wy2ylyNlBu9Hkq)gMhTt34wlsAQZ0cjhy2Z0arqITNjklJnQlgTP3JIy068GDARN2WwtccLSWveZyelp0vM66tlRcBQRxjlCfXmgXYdDfLxo6d7Yx6BYOCkJnPrLKsw4kIzmILh6GDUSr1hQa9ByE0oDJBTiPjtEwoBwdebjRjbHkMgd)dd7TUIYUStKWAsqOIUEEOZoTvu2LnyNlBu9Hkq)gMhTt34wlsAAHDdhDrxAGiizyRjbHsw4kIzmILh6kkVC0h2LtL9tNr5ugBsJkj1QOTJhrtrPYPT5gRjbHYWUbVFiD8snZsK4M2X83kd7g8(H0Xlf)UfMn2c25YgvFOc0VH5r70nU1IKMupfFJPAGiizyRjbHsw4kIzmILh6QzwABKvHn11RmSBW7hshVuuE5OpS72jsCt7y(BLHDdE)q64LIF3cZgBb7CzJQpub63W8OD6g3ArsZvrBhpIMIsLb7CzJQpub63W8OD6g3ArsZkfMMvxmfSZLnQ(qfOFdZJ2PBCRfjnV0ru8f6nAGii1oM)wrW0uk6OigwE3ywXVBHztABO(gBhjYLCIeg2AsqOKfUIygJy5HUAMLwwf2uxVTGDUSr1hQa9ByE0oDJBTiPzG9Lgics30oM)wrW0uk6OigwE3ywXVBHztABO(gBhjYLCIeg2AsqOKfUIygJy5HUIYlh9HDYQWM66vRI2oEenfLkRO8YrFKwwf2uxVAv02XJOPOuzfLxo6d7YtzFBHNiJLqYYFsWg2qia]] )
end
