-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 71 )

    local base_rage_gen, arms_rage_mult = 1.75, 4.000

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand = {
            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = 'mainhand_speed',

            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.swings.mainhand_speed / state.haste
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
            shared = "player", -- check for anyone's buff on the player.
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
        hamstring = {
            id = 1715,
            duration = 15,
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
        victorious = {
            id = 32216,
            duration = 20,
            max_stack = 1,
        },

        -- Azerite Powers
        crushing_assault = {
            id = 278826,
            duration = 10,
            max_stack = 1
        },

        test_of_might = {
            id = 275540,
            duration = 12,
            max_stack = 1
        }
    } )


    local rageSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if talent.anger_management.enabled and resource == "rage" then
            rageSpent = rageSpent + amt
            local reduction = floor( rageSpent / 20 )
            rageSpent = rageSpent % 20

            if reduction > 0 then
                cooldown.colossus_smash.expires = cooldown.colossus_smash.expires - reduction
                cooldown.bladestorm.expires = cooldown.bladestorm.expires - reduction
                cooldown.warbreaker.expires = cooldown.warbreaker.expires - reduction
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
        if buff.bladestorm.up then setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.bladestorm.remains ) ) end
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

            nobuff = "battle_shout",
            essential = true,
            
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
            charges = function () return talent.double_time.enabled and 2 or nil end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132337,
            
            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute ) end,
            handler = function ()
                setDistance( 5 )
            end,
        },
        

        cleave = {
            id = 845,
            cast = 0,
            cooldown = 9,
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
            id = function () return talent.massacre.enabled and 281001 or 163201 end,
            known = 163201,
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

            recheck = function () return rage.time_to_40 end,
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

            copy = { 163201, 281001, 281000 }
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
            charges = function () return ( level < 116 and equipped.timeless_strategem ) and 3 or nil end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236171,

            usable = function () return ( equipped.weight_of_the_earth or target.distance > 10 ) and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute * 2 ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
                if level < 116 and equipped.weight_of_the_earth then
                    applyDebuff( "target", "colossus_smash" )
                    active_dot.colossus_smash = max( 1, active_enemies )
                end
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
                return 30 - ( ( level < 116 and equipped.archavons_heavy_hand ) and 8 or 0 )
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
            charges = function () return talent.dreadnaught.enabled and 2 or nil end,
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
            gcd = "off",
            
            startsCombat = true,
            texture = 132938,

            toggle = "interrupts",
            
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
            cooldown = 21,
            hasteCD = true,
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
                if buff.crushing_assault.up then return 0 end
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132340,
            
            recheck = function () return rage.time_to_30, rage.time_to_40 end,
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
                removeBuff( "crushing_assault" )
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
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132306,
            
            handler = function ()
                applyBuff( "sweeping_strikes" )
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
            end,
        },
        

        warbreaker = {
            id = 262161,
            cast = 0,
            cooldown = 45,
            velocity = 25,
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

            recheck = function () return rage.time_to_50 end,
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
        damageDots = false,
    
        package = "Arms",
    } )

    
    spec:RegisterPack( "Arms", 20180830.2054, [[dKuQbbqirkpseInjs(KivOrjfoLOQvjsf5vKknlrKBjsv2fIFjLmmrfhtuPLrk8msfMMuQCnOQY2iv03ePsghuvCorQkRdQQQ5jcUhP0(erDqOQ0cjf9qPuvUOivu(OuQQ0jfPszLsrZuKkv3uKkWoHQmuPuLLcvv5Ps1uHIUQivuTvrQG(Qivv7fYFbzWu5WuwmOEmvnzsUmQntWNHsJwv50aRwkvv9AOWSj62eA3k9Bvgou54sPQILR45sMUW1vLTtQ67IY4fH68sPSErinFvv7hPr5IWe1vwWi80iNCXNCWhDKdrJCWpDGFPlupAdhJ64mpggwg1xtKrD8DeluhN1M8mfctuVU34zu)lcCf(VvlSG47bt8NyRci(KwaU1pMq0QaI(wWYdUfSGLEkwFlCZjaKC1Q9gg)zav1Q9WFqPFBgWnq47iwKci6rD4hqgPBlcg1vwWi80iNCXNCWhDKdrJCANoANorD7fF3G6DGy7J6ArD474)aIbyUc1vC5r9eH6W3rSOU0Vnd4gAZeH6(IaxH)B1cli(EWe)j2QaIpPfGB9JjeTkGOVfS8GBblyPNI13c3CcajxTAVHXFgqvTAp8hu63MbCde(oIfPaIEAZeH6W3h2xfuNoYjjQtJCYfFOU0J60a)NRoOU2lDaTjTzIqDTVpBXYf(N2mrOU0J6WxLIvux79efzjH2mrOU0J6WxLIvux6qGpUPnQd)9QpQ70Zd11LMi11iR1rDTV5vFGfl1HVvzpzKNqBMiux6rD4RsXkQttlcjtD9V7fuxCuhUH9NiSfuh(2EP7euxcQOqyI6fyXkzOWgSCGWeHxUimrDEnyjRqAI6(be8amuFyrdSf1LGwQt9gla3sDPtuxoeDqDPOofd)eei(tEv9kOs0QpI6Ywu38b4wuF4vHceEAGWe151GLScPjQ7hqWdWq9XWYuxcuNoZH6srDnOo)Ds1LTefBkzBqEtksgw0aBrDjtD6G6()PU0OUWK8gefBkzBqEtks41GLSI6YJ6Mpa3I6fgpPSWjbrWdkq4PdeMOoVgSKvinrD)acEagQ3G683jvx2sGLMIR4grYWIgylQlzQtNu3)p1fMK3GmMEdlpeEnyjROUuuN)oP6YwYy6nS8qgw0aBrDjtD6K6YtDPOUguN)oP6YwI)KxvVcQeT6JmSOb2I6sG60G6()PUguxysEdsMnWdByWdHxdwYkQlf15VtQUSLKzd8Wgg8qgw0aBrDjqDAqD5PU8OU5dWTOUInLSniVjfrbcV2HWe151GLScPjQ7hqWdWq90Oo4NGarXMs2gK3KIKhoQlf11G683jvx2s8N8Q6vqLOvFKHfnWwuxcuNgu3)p11G6ctYBqYSbEyddEi8AWswrDPOo)Ds1LTKmBGh2WGhYWIgylQlbQtdQlp1Lh1nFaUf1htVHLhuGWd)qyI68AWswH0e19di4byOUIHFcce)jVQEfujA1hrDzlQB(aClQ7p5v1RGkrR(qbcpDIWe151GLScPjQ7hqWdWqDfd)eei(tEv9kOs0QpI6Ywu38b4wupZg4Hnm4bfi8sximrDEnyjRqAI6(be8amuh(jiqQNsXlKIT4JmS5du38b4wuNtm7FbJceE4dctuNxdwYkKMOUFabpad193jvx2seVjmjufdadMmSOb2I6srDnOUguNIHFcce)jVQEfujA1h5HJ6srDPrDwIYdiysWvaDcqIaSFbHxdwYkQlp19)tDWpbbsWvaDcqIaSFb5HJ6YJ6Mpa3I6WstXvCJikq4L(qyI68AWswH0e19di4byOEHJLsOWgSCuKSpWiZaRI6sM60a1nFaUf19s20ZOaHxU5GWe151GLScPjQ7hqWdWqDlr5bemPyqjc8qzMEMm2Ib1PL60bQB(aClQF65b3LXdkq4LBUimrDZhGBrDXBctcvXaWGrDEnyjRqAIceE5Qbctu38b4wu)0ZdUlJhuNxdwYkKMOaHxU6aHjQZRblzfstu3pGGhGH6Hj5nic8O)gOtac2IqYeEnyjROUuuxdQlnQZsuEabtcUcOtaseG9li8AWswrD))uxdQBmSm1LSwQtN5qD))uNIHFcce)jVQEfujA1h5HJ6()Po4NGarXMs2gK3KIKhoQlp1Lh1nFaUf1Z(aJmdSkuGWl32HWe151GLScPjQ7hqWdWq90OUXakiwpVbXuQI8WrDPOo4NGaXpV6dSyHSQSNmiQlBrDZhGBrD9aFCtBqZR(qbcVCXpeMOoVgSKvinrD)acEagQNg1fMK3GiWJ(BGobiylcjt41GLSI6srDnOU0Oolr5bemj4kGobira2VGWRblzf19)tDnOUXWYuxYAPoDMd19)tDkg(jiq8N8Q6vqLOvFKhoQ7)N6GFccefBkzBqEtksE4OU8uxEu38b4wuVKMikqbQRyb7jdeMi8YfHjQB(aClQ7)SblJ68AWswH0efi80aHjQB(aClQJ7jkYsuNxdwYkKMOaHNoqyI6Mpa3I62loilcZJbQZRblzfstuGWRDimrDZhGBrDCxaUf151GLScPjkq4HFimrDEnyjRqAI6(be8amuxXWpbbI)KxvVcQeT6J8WH6Mpa3I6WY7uqcVPnuGWtNimrDEnyjRqAI6(be8amuxXWpbbI)KxvVcQeT6J8WH6Mpa3I6W8u8GbyXIceEPleMOoVgSKvinrD)acEagQRy4NGaXFYRQxbvIw9rux2sDPOo)Ds1LTeXBctcvXaWGjdlAGTOUKPUCj4h1LI6gdltDjqD4xoOU5dWTOUnEBzO4MH3afi8WheMOoVgSKvinrD)acEagQRy4NGaXFYRQxbvIw9rux2I6Mpa3I6sa2VOGA)FkSI8gOaHx6dHjQZRblzfstu3pGGhGH6kg(jiq8N8Q6vqLOvFKhou38b4wuxammS8ofkq4LBoimrDEnyjRqAI6(be8amuxXWpbbI)KxvVcQeT6J8WH6Mpa3I6265kgtc5nPefi8YnxeMOoVgSKvinrD)acEagQ7VtQUSL4p5v1RGkrR(idlAGTOUeOo8H6()PUguxysEdsMnWdByWdHxdwYkQlf15VtQUSLKzd8Wgg8qgw0aBrDjqD4d1Lh1nFaUf1n9wydkq4LRgimrDEnyjRqAI6(be8amuVWXsjuydwoks2hyKzGvrDjtD5sDPOUguN)oP6YwcS0uCf3isgw0aBrDjtD5Md19)tD(7KQlBj(tEv9kOs0QpYWIgylQlzQdFOU)FQZsuEabtcUcOtaseG9li8AWswrD5rDZhGBr9kJzCGflufdadUqbcVC1bctuNxdwYkKMOUFabpad1hdOGy98getPkcNyqffQB(aClQpVfY8b4wijOcuxcQaAnrg1)mpkq4LB7qyI68AWswH0e19di4byOEHJLsOWgSCuKSpWiZaRI6sM6AhQB(aClQpVfY8b4wijOcuxcQaAnrg1fa6zOWgSCGceE5IFimrDEnyjRqAI6(be8amuVb1fMK3GiAvz(Hj8AWswrDPOUWgSCq(ytgFeC(G6sG60b(rD5PU)FQlSblhKp2KXhbNpOUeOonYb1nFaUf1N3cz(aClKeubQlbvaTMiJ6CIz)lyuGWlxDIWe151GLScPjQB(aClQpVfY8b4wijOcuxcQaAnrg1lWIvYqHny5afOa1XnS)eHTaHjcVCryI68AWswH0efi80aHjQZRblzfstuGWthimrDEnyjRqAIceETdHjQZRblzfstuGWd)qyI6Mpa3I6WwesgQ(UxG68AWswH0efi80jctu38b4wuh3fGBrDEnyjRqAIcuG6CIz)lyeMi8YfHjQZRblzfstu3pGGhGH6JHLPUeOoDMd1LI6AqDnOo)Ds1LTefBkzBqEtksgw0aBrDjtD6G6srDPrDWpbbIInLSniVjfjpCuxEQ7)N6sJ6ctYBquSPKTb5nPiHxdwYkQlpQB(aClQxy8KYcNeebpOaHNgimrDEnyjRqAI6(be8amu3FNuDzlbwAkUIBejdlAGTOUKPoDsDPOUguN)oP6YwI)KxvVcQeT6JmSOb2I6sG60G6()PUguxysEdsMnWdByWdHxdwYkQlf15VtQUSLKzd8Wgg8qgw0aBrDjqDAqD5PU8OU5dWTOUInLSniVjfrbcpDGWe151GLScPjQ7hqWdWq90Oo4NGarXMs2gK3KIKhoQlf11G683jvx2s8N8Q6vqLOvFKHfnWwuxcuNgu3)p11G6ctYBqYSbEyddEi8AWswrDPOo)Ds1LTKmBGh2WGhYWIgylQlbQtdQlp1Lh1nFaUf1htVHLhuGWRDimrDEnyjRqAI6(be8amuxXWpbbI)KxvVcQeT6JOUSf1nFaUf19N8Q6vqLOvFOaHh(HWe151GLScPjQ7hqWdWqDfd)eei(tEv9kOs0QpI6Ywu38b4wupZg4Hnm4bfi80jctuNxdwYkKMOUFabpad1hdltDjqD6ihQlf1Lg1b)eeik2uY2G8MuK8WH6Mpa3I6WstXvCJikq4LUqyI68AWswH0e19di4byOEHJLsOWgSCuKSpWiZaRI6sM60a1nFaUf19s20ZOaHh(GWe151GLScPjQ7hqWdWqD4NGaXpV6dSyHSQSNmipCOU5dWTOEjnruGWl9HWe151GLScPjQ7hqWdWqDfd)eei(tEv9kOs0QpYdh1LI6GFccKtpp4UmEivyEmOoTuNguxkQRb1fMK3GOg2uR9W(feEnyjROU)FQd(jiq4eZ(xaULNcc3WEqbULuH5XG60sDAqD5rDZhGBrDXBctcvXaWGrbcVCZbHjQB(aClQF65b3LXdQZRblzfstuGWl3CryI6Mpa3I6CIz)lyuNxdwYkKMOafO(N5ryIWlxeMOoVgSKvinrD)acEagQpSOb2I6sql1PEJfGBPU0jQlhIoOUuuxdQlnQBmGcI1ZBqmLQipCu3)p1b)eeivgZ4alwOkgagCrE4OU8OU5dWTO(WRcfi80aHjQZRblzfstu3pGGhGH6JHLPUeOoDMd1LI6AqD(7KQlBjk2uY2G8MuKmSOb2I6sM60b19)tDPrDHj5nik2uY2G8MuKWRblzf1Lh1nFaUf1lmEszHtcIGhuGWthimrDEnyjRqAI6(be8amuVb15VtQUSLalnfxXnIKHfnWwuxYuNoPU)FQlmjVbzm9gwEi8AWswrDPOo)Ds1LTKX0By5HmSOb2I6sM60j1LN6srDnOo)Ds1LTe)jVQEfujA1hzyrdSf1La1Pb19)tDnOUWK8gKmBGh2WGhcVgSKvuxkQZFNuDzljZg4Hnm4HmSOb2I6sG60G6YtD5rDZhGBrDfBkzBqEtkIceETdHjQZRblzfstu3pGGhGH6nOUXakiwpVbXuQI8WrD))u3yafeRN3Gykvral1Lm1f2GLdsaezO4GuaM6YtDPOUguN)oP6YwI)KxvVcQeT6JmSOb2I6sG60G6()PUguxysEdsMnWdByWdHxdwYkQlf15VtQUSLKzd8Wgg8qgw0aBrDjqDAqD5PU8OU5dWTO(y6nS8GceE4hctuNxdwYkKMOUFabpad1hdOGy98getPkYdh19)tDJbuqSEEdIPufbSuxYux7YH6()PUgu3yafeRN3Gykvral1Lm1ProuxkQlmjVbXwS8ajARHLf5ni8AWswrD5rDZhGBrD)jVQEfujA1hkq4PteMOoVgSKvinrD)acEagQpgqbX65niMsvKhoQ7)N6gdOGy98getPkcyPUKPU2Ld19)tDnOUXakiwpVbXuQIawQlzQtJCOUuuxysEdITy5bs0wdllYBq41GLSI6YJ6Mpa3I6z2apSHbpOaHx6cHjQZRblzfstu3pGGhGH6nOofd)eei(tEv9kOs0QpYdh1LI6gdOGy98getPkcyPUKPUWgSCqcGidfhKcWuxEQ7)N6gdOGy98getPkYdh1LI6AqDnOofd)eei(tEv9kOs0QpYWIgylQlzQRDe8J6srDPrDwIYdiysWvaDcqIaSFbHxdwYkQlp19)tDWpbbsWvaDcqIaSFb5HJ6YJ6Mpa3I6WstXvCJikq4HpimrDEnyjRqAI6(be8amupnQBmGcI1ZBqmLQipCu3)p11G6gdOGy98getPkYdh1LI6SeLhqWKIbLiWdLz6zcVgSKvuxEu38b4wu)0ZdUlJhuGWl9HWe151GLScPjQ7hqWdWq9chlLqHny5OizFGrMbwf1Lm1PbQB(aClQ7LSPNrbcVCZbHjQZRblzfstu3pGGhGH6PrDJbuqSEEdIPuf5HJ6()PUguxAuxysEdIxYMEMWRblzf1LI6uxqumJdk7ERQidlAGTOUeOonOU8u3)p1b)eei1tP4fsXw8rg28bQB(aClQZjM9VGrbcVCZfHjQZRblzfstu3pGGhGH6PrDJbuqSEEdIPuf5HJ6()PUguxAuxysEdIxYMEMWRblzf1LI6uxqumJdk7ERQidlAGTOUeOonOU8OU5dWTOU4nHjHQyayWOaHxUAGWe151GLScPjQ7hqWdWq9XakiwpVbXuQI8WH6Mpa3I6zFGrMbwfkq4LRoqyI6Mpa3I6NEEWDz8G68AWswH0efi8YTDimrDEnyjRqAI6(be8amupmjVbrGh93aDcqWwesMWRblzfQB(aClQN9bgzgyvOaHxU4hctuNxdwYkKMOUFabpad1tJ6gdOGy98getPkYdh1LI6GFcce)8QpWIfYQYEYGOUSf1nFaUf11d8XnTbnV6dfi8YvNimrDEnyjRqAI6(be8amupnQlmjVbrGh93aDcqWwesMWRblzf1LI6sJ6gdOGy98getPkYdhQB(aClQxstefOa1fa6zOWgSCGWeHxUimrDEnyjRqAI6(be8amuFmSm1La1PZCOUuuxdQZFNuDzlrXMs2gK3KIKHfnWwuxYuNoOU)FQlnQlmjVbrXMs2gK3KIeEnyjROU8OU5dWTOEHXtklCsqe8GceEAGWe151GLScPjQ7hqWdWqD)Ds1LTeyPP4kUrKmSOb2I6sM60j1LI6AqD(7KQlBj(tEv9kOs0QpYWIgylQlbQtdQ7)N6AqDHj5niz2apSHbpeEnyjROUuuN)oP6YwsMnWdByWdzyrdSf1La1Pb1LN6YJ6Mpa3I6k2uY2G8Muefi80bctuNxdwYkKMOUFabpad1tJ6GFccefBkzBqEtksE4OUuuxdQZFNuDzlXFYRQxbvIw9rgw0aBrDjqDAqD))uxdQlmjVbjZg4Hnm4HWRblzf1LI683jvx2sYSbEyddEidlAGTOUeOonOU8uxEu38b4wuFm9gwEqbcV2HWe151GLScPjQ7hqWdWqDfd)eei(tEv9kOs0QpI6Ywu38b4wu3FYRQxbvIw9HceE4hctuNxdwYkKMOUFabpad1vm8tqG4p5v1RGkrR(iQlBrDZhGBr9mBGh2WGhuGWtNimrDEnyjRqAI6(be8amuh(jiqQmMXbwSqvmam4IOUSL6srDPrDWpbbIInLSniVjfjpCuxkQRb11G6um8tqG4p5v1RGkrR(idlAGTOUKPU2rWpQlf1Lg1zjkpGGjbxb0jajcW(feEnyjROU8u3)p1b)eeibxb0jajcW(fKhoQlpQB(aClQdlnfxXnIOaHx6cHjQB(aClQ7LSPNrDEnyjRqAIceE4dctuNxdwYkKMOUFabpad1BqDPrDHj5niEjB6zcVgSKvuxkQtDbrXmoOS7TQImSOb2I6sG60G6YtD))uxdQd(jiqQNsXlKIT4JmS5dQ7)N6GFccKkULH(yBcYWMpOU8uxkQRb1b)eeivgZ4alwOkgagCrE4OU)FQZFNuDzlPYyghyXcvXaWGlYWIgylQlzQdFOU8OU5dWTOoNy2)cgfi8sFimrDEnyjRqAI6(be8amuVb1Lg1fMK3G4LSPNj8AWswrDPOo1fefZ4GYU3QkYWIgylQlbQtdQlp19)tDWpbbsLXmoWIfQIbGbxKhoQlf1b)eeiNEEWDz8qQW8yqDAPonOUuuxdQlmjVbrnSPw7H9li8AWswrD))uh8tqGWjM9VaClpfeUH9GcClPcZJb1PL60G6YJ6Mpa3I6I3eMeQIbGbJceE5MdctuNxdwYkKMOUFabpad1vm8tqG4p5v1RGkrR(ipCu3)p11G6GFcce)8QpWIfYQYEYG8WrDPOUWK8gebE0Fd0jabBrizcVgSKvuxEu38b4wup7dmYmWQqbcVCZfHjQB(aClQF65b3LXdQZRblzfstuGWlxnqyI6Mpa3I6zFGrMbwfQZRblzfstuGcuG665Pa3IWtJCYfFYbF0roKCBNosFOEMnlyXwOE6hFXF4LUHx7x8p1rDy(Xuhqe3nb1jCd1LoQyb7jJ0rQB42ppWWkQRorM6SxCIwWkQZ)zlwUi0MP7GLPoDG)PU05B9WH7MGvuN5dWTux6O9IdYIW8yKosOnPnt3eXDtWkQtNuN5dWTuNeurrOnrDCZjaKmQNiuh(oIf1L(Tza3qBMiu3xe4k8FRwybX3dM4pXwfq8jTaCRFmHOvbe9TGLhClybl9uS(w4Mtai5Qv7nm(ZaQQv7H)Gs)2mGBGW3rSifq0tBMiuh((W(QG60rojrDAKtU4d1LEuNg4)C1b11EPdOnPnteQR99zlwUW)0Mjc1LEuh(QuSI6AVNOilj0Mjc1LEuh(QuSI6shc8XnTrD4Vx9rDNEEOUU0ePUgzToQR9nV6dSyPo8Tk7jJ8eAZeH6spQdFvkwrDAArizQR)DVG6IJ6WnS)eHTG6W32lDNqBsBMiux6SeZ(xWkQdMfUHPo)jcBb1bZybBrOo817zCrrD7TP3NnIcpj1z(aCBrD3kBJqBA(aCBrWnS)eHTqRG0kmOnnFaUTi4g2FIWwOR2wc3POnnFaUTi4g2FIWwOR2w2dRiVHfGBPnteQRVgU67cQBmGI6GFccSI6QWII6GzHByQZFIWwqDWmwWwuNTkQd3WPhUlcWIL6af1PULj0MMpa3weCd7pryl0vBRAnC13fqvyrrBA(aCBrWnS)eHTqxTTGTiKmu9DVG208b42IGBy)jcBHUABH7cWT0M0Mjc1LolXS)fSI6y980g1farM6IpM6mFCd1bkQZ0BaPblzcTP5dWTLw)NnyzAtZhGBlD12c3tuKL0MMpa3w6QTL9IdYIW8yqBA(aCBPR2w4UaClTP5dWTLUABblVtbj8M2sciOvXWpbbI)KxvVcQeT6J8WrBA(aCBPR2wW8u8GbyXMeqqRIHFcce)jVQEfujA1h5HJ208b42sxTTSXBldf3m8gjbe0Qy4NGaXFYRQxbvIw9rux2MYFNuDzlr8MWKqvmamyYWIgyRKZLGFPgdlNa(LdTP5dWTLUABjby)IcQ9)PWkYBKeqqRIHFcce)jVQEfujA1hrDzlTP5dWTLUABjaggwENkjGGwfd)eei(tEv9kOs0QpYdhTP5dWTLUABzRNRymjK3KYKacAvm8tqG4p5v1RGkrR(ipC0MMpa3w6QTLP3cBsciO1FNuDzlXFYRQxbvIw9rgw0aBLa(8)3imjVbjZg4Hnm4HWRblzvk)Ds1LTKmBGh2WGhYWIgyReWN80MMpa3w6QTvLXmoWIfQIbGbxjbe0w4yPekSblhfj7dmYmWQso3un83jvx2sGLMIR4grYWIgyRKZnN)F)Ds1LTe)jVQEfujA1hzyrdSvY4Z)VLO8acMeCfqNaKia7xq41GLSkpTP5dWTLUABnVfY8b4wijOIKwtK1(z(KacAhdOGy98getPkcNyqffTP5dWTLUABnVfY8b4wijOIKwtK1ka0ZqHny5ijGG2chlLqHny5OizFGrMbwvYTJ208b42sxTTM3cz(aClKeursRjYA5eZ(xWjbe02imjVbr0QY8dt41GLSkvydwoiFSjJpcoFKGoWV8))Hny5G8XMm(i48rcAKdTP5dWTLUABnVfY8b4wijOIKwtK1wGfRKHcBWYbTjTP5dWTfHtm7FbRTW4jLfojicEsciODmSCc6mNunA4VtQUSLOytjBdYBsrYWIgyRK1rQ0GFccefBkzBqEtksE4Y))NwysEdIInLSniVjfj8AWswLN208b42IWjM9VG1vBlfBkzBqEtkMeqqR)oP6YwcS0uCf3isgw0aBLSot1WFNuDzlXFYRQxbvIw9rgw0aBLGg))nctYBqYSbEyddEi8AWswLYFNuDzljZg4Hnm4HmSOb2kbnYNN208b42IWjM9VG1vBRX0By5jjGG20GFccefBkzBqEtksE4s1WFNuDzlXFYRQxbvIw9rgw0aBLGg))nctYBqYSbEyddEi8AWswLYFNuDzljZg4Hnm4HmSOb2kbnYNN208b42IWjM9VG1vBl)jVQEfujA1xsabTkg(jiq8N8Q6vqLOvFe1LT0MMpa3weoXS)fSUABLzd8Wgg8KeqqRIHFcce)jVQEfujA1hrDzlTP5dWTfHtm7FbRR2wWstXvCJysabTJHLtqh5Kkn4NGarXMs2gK3KIKhoAtZhGBlcNy2)cwxTT8s20Zjbe0w4yPekSblhfj7dmYmWQswdAtZhGBlcNy2)cwxTTkPjMeqql8tqG4Nx9bwSqwv2tgKhoAtZhGBlcNy2)cwxTTeVjmjufdadojGGwfd)eei(tEv9kOs0QpYdxk4NGa50ZdUlJhsfMhdTAKQrysEdIAytT2d7xq41GLS6)h(jiq4eZ(xaULNcc3WEqbULuH5XqRg5PnnFaUTiCIz)lyD1260ZdUlJhAtZhGBlcNy2)cwxTT4eZ(xW0M0MMpa3webGEgkSblhAlmEszHtcIGNKacAhdlNGoZjvd)Ds1LTefBkzBqEtksgw0aBLSo()tlmjVbrXMs2gK3KIeEnyjRYtBA(aCBrea6zOWgSCOR2wk2uY2G8MumjGGw)Ds1LTeyPP4kUrKmSOb2kzDMQH)oP6YwI)KxvVcQeT6JmSOb2kbn()BeMK3GKzd8Wgg8q41GLSkL)oP6YwsMnWdByWdzyrdSvcAKppTP5dWTfraONHcBWYHUABnMEdlpjbe0Mg8tqGOytjBdYBsrYdxQg(7KQlBj(tEv9kOs0QpYWIgyRe04)VrysEdsMnWdByWdHxdwYQu(7KQlBjz2apSHbpKHfnWwjOr(80MMpa3webGEgkSblh6QTL)KxvVcQeT6ljGGwfd)eei(tEv9kOs0QpI6YwAtZhGBlIaqpdf2GLdD12kZg4Hnm4jjGGwfd)eei(tEv9kOs0QpI6YwAtZhGBlIaqpdf2GLdD12cwAkUIBetciOf(jiqQmMXbwSqvmam4IOUSnvAWpbbIInLSniVjfjpCPA0qXWpbbI)KxvVcQeT6JmSOb2k52rWVuPzjkpGGjbxb0jajcW(feEnyjRY))d)eeibxb0jajcW(fKhU80MMpa3webGEgkSblh6QTLxYMEM208b42Iia0ZqHny5qxTT4eZ(xWjbe02iTWK8geVKn9mHxdwYQuQlikMXbLDVvvKHfnWwjOr())gWpbbs9ukEHuSfFKHnF8)d)eeivCld9X2eKHnFKpvd4NGaPYyghyXcvXaWGlYd3)V)oP6YwsLXmoWIfQIbGbxKHfnWwjJp5PnnFaUTica9muydwo0vBlXBctcvXaWGtciOTrAHj5niEjB6zcVgSKvPuxqumJdk7ERQidlAGTsqJ8))WpbbsLXmoWIfQIbGbxKhUuWpbbYPNhCxgpKkmpgA1ivJWK8ge1WMATh2VGWRblz1)p8tqGWjM9VaClpfeUH9GcClPcZJHwnYtBA(aCBrea6zOWgSCOR2wzFGrMbwvsabTkg(jiq8N8Q6vqLOvFKhU))gWpbbIFE1hyXczvzpzqE4sfMK3GiWJ(BGobiylcjt41GLSkpTP5dWTfraONHcBWYHUABD65b3LXdTP5dWTfraONHcBWYHUABL9bgzgyv0M0MMpa3wKpZRD4vLeqq7WIgyRe0QEJfGBtNYHOJunsBmGcI1ZBqmLQipC))WpbbsLXmoWIfQIbGbxKhU80MMpa3wKpZRR2wfgpPSWjbrWtsabTJHLtqN5KQH)oP6YwIInLSniVjfjdlAGTswh))PfMK3GOytjBdYBsrcVgSKv5PnnFaUTiFMxxTTuSPKTb5nPysabTn83jvx2sGLMIR4grYWIgyRK15)FysEdYy6nS8q41GLSkL)oP6YwYy6nS8qgw0aBLSoZNQH)oP6YwI)KxvVcQeT6JmSOb2kbn()BeMK3GKzd8Wgg8q41GLSkL)oP6YwsMnWdByWdzyrdSvcAKppTP5dWTf5Z86QT1y6nS8KeqqBJXakiwpVbXuQI8W9)pgqbX65niMsveWMCydwoibqKHIdsb48PA4VtQUSL4p5v1RGkrR(idlAGTsqJ))gHj5niz2apSHbpeEnyjRs5VtQUSLKzd8Wgg8qgw0aBLGg5ZtBA(aCBr(mVUAB5p5v1RGkrR(sciODmGcI1ZBqmLQipC))JbuqSEEdIPufbSj3UC()BmgqbX65niMsveWMSg5KkmjVbXwS8ajARHLf5ni8AWswLN208b42I8zED12kZg4Hnm4jjGG2XakiwpVbXuQI8W9)pgqbX65niMsveWMC7Y5)VXyafeRN3GykvraBYAKtQWK8geBXYdKOTgwwK3GWRblzvEAtZhGBlYN51vBlyPP4kUrmjGG2gkg(jiq8N8Q6vqLOvFKhUuJbuqSEEdIPufbSjh2GLdsaezO4Guao)))yafeRN3GykvrE4s1OHIHFcce)jVQEfujA1hzyrdSvYTJGFPsZsuEabtcUcOtaseG9li8AWswL))h(jiqcUcOtaseG9lipC5PnnFaUTiFMxxTTo98G7Y4jjGG20gdOGy98getPkYd3)FJXakiwpVbXuQI8WLYsuEabtkguIapuMPNj8AWswLN208b42I8zED12YlztpNeqqBHJLsOWgSCuKSpWiZaRkznOnnFaUTiFMxxTT4eZ(xWjbe0M2yafeRN3GykvrE4()BKwysEdIxYMEMWRblzvk1fefZ4GYU3QkYWIgyRe0i))p8tqGupLIxifBXhzyZh0MMpa3wKpZRR2wI3eMeQIbGbNeqqBAJbuqSEEdIPuf5H7)VrAHj5niEjB6zcVgSKvPuxqumJdk7ERQidlAGTsqJ80MMpa3wKpZRR2wzFGrMbwvsabTJbuqSEEdIPuf5HJ208b42I8zED1260ZdUlJhAtZhGBlYN51vBRSpWiZaRkjGG2WK8gebE0Fd0jabBrizcVgSKv0MMpa3wKpZRR2w6b(4M2GMx9LeqqBAJbuqSEEdIPuf5Hlf8tqG4Nx9bwSqwv2tge1LT0MMpa3wKpZRR2wL0etciOnTWK8gebE0Fd0jabBrizcVgSKvPsBmGcI1ZBqmLQipC0M0MMpa3wKcSyLmuydwo0o8QsciODyrdSvcAvVXcWTPt5q0rkfd)eei(tEv9kOs0QpI6YwAtZhGBlsbwSsgkSblh6QTvHXtklCsqe8Keqq7yy5e0zoPA4VtQUSLOytjBdYBsrYWIgyRK1X)FAHj5nik2uY2G8MuKWRblzvEAtZhGBlsbwSsgkSblh6QTLInLSniVjftciOTH)oP6YwcS0uCf3isgw0aBLSo))dtYBqgtVHLhcVgSKvP83jvx2sgtVHLhYWIgyRK1z(un83jvx2s8N8Q6vqLOvFKHfnWwjOX)FJWK8gKmBGh2WGhcVgSKvP83jvx2sYSbEyddEidlAGTsqJ85PnnFaUTifyXkzOWgSCOR2wJP3WYtsabTPb)eeik2uY2G8MuK8WLQH)oP6YwI)KxvVcQeT6JmSOb2kbn()BeMK3GKzd8Wgg8q41GLSkL)oP6YwsMnWdByWdzyrdSvcAKppTP5dWTfPalwjdf2GLdD12YFYRQxbvIw9LeqqRIHFcce)jVQEfujA1hrDzlTP5dWTfPalwjdf2GLdD12kZg4Hnm4jjGGwfd)eei(tEv9kOs0QpI6YwAtZhGBlsbwSsgkSblh6QTfNy2)cojGGw4NGaPEkfVqk2IpYWMpOnnFaUTifyXkzOWgSCOR2wWstXvCJysabT(7KQlBjI3eMeQIbGbtgw0aBLQrdfd)eei(tEv9kOs0QpYdxQ0SeLhqWKGRa6eGeby)ccVgSKv5))HFccKGRa6eGeby)cYdxEAtZhGBlsbwSsgkSblh6QTLxYMEojGG2chlLqHny5OizFGrMbwvYAqBA(aCBrkWIvYqHny5qxTTo98G7Y4jjGGwlr5bemPyqjc8qzMEMm2IHwDqBA(aCBrkWIvYqHny5qxTTeVjmjufdadM208b42IuGfRKHcBWYHUABD65b3LXdTP5dWTfPalwjdf2GLdD12k7dmYmWQsciOnmjVbrGh93aDcqWwesMWRblzvQgPzjkpGGjbxb0jajcW(feEnyjR()BmgwozT6mN)Ffd)eei(tEv9kOs0QpYd3)p8tqGOytjBdYBsrYdx(80MMpa3wKcSyLmuydwo0vBl9aFCtBqZR(sciOnTXakiwpVbXuQI8WLc(jiq8ZR(alwiRk7jdI6YwAtZhGBlsbwSsgkSblh6QTvjnXKacAtlmjVbrGh93aDcqWwesMWRblzvQgPzjkpGGjbxb0jajcW(feEnyjR()BmgwozT6mN)Ffd)eei(tEv9kOs0QpYd3)p8tqGOytjBdYBsrYdx(8OEHJ9i8sx5IcuGqa]] )


end
