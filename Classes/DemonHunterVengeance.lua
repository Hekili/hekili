-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DEMONHUNTER' then
    local spec = Hekili:NewSpecialization( 581 )

    spec:RegisterResource( Enum.PowerType.Pain, {
        metamorphosis = {
            aura = "metamorphosis",

            last = function ()
                local app = state.buff.metamorphosis.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 7
        },
    } )
    
    -- Talents
    spec:RegisterTalents( {
        abyssal_strike = 22502, -- 207550
        agonizing_flames = 22503, -- 207548
        razor_spikes = 22504, -- 209400

        feast_of_souls = 22505, -- 207697
        fallout = 22766, -- 227174
        burning_alive = 22507, -- 207739

        flame_crash = 22324, -- 227322
        charred_flesh = 22541, -- 264002
        felblade = 22540, -- 232893

        soul_rending = 22508, -- 217996
        feed_the_demon = 22509, -- 218612
        fracture = 22770, -- 263642

        concentrated_sigils = 22546, -- 207666
        quickened_sigils = 22510, -- 209281
        sigil_of_chains = 22511, -- 202138

        gluttony = 22512, -- 264004
        spirit_bomb = 22513, -- 247454
        fel_devastation = 22768, -- 212084

        last_resort = 22543, -- 209258
        void_reaver = 22548, -- 268175
        soul_barrier = 21902, -- 263648
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3544, -- 208683
        relentless = 3545, -- 196029
        adaptation = 3546, -- 214027

        everlasting_hunt = 815, -- 205626
        cleansed_by_flame = 814, -- 205625
        jagged_spikes = 816, -- 205627
        illidans_grasp = 819, -- 205630
        tormentor = 1220, -- 207029
        sigil_mastery = 1948, -- 211489
        unending_hatred = 3727, -- 213480
        solitude = 802, -- 211509
        demonic_trample = 3423, -- 205629
        reverse_magic = 3429, -- 205604
        detainment = 3430, -- 205596
    } )

    -- Auras
    spec:RegisterAuras( {
        chaos_brand = {
            id = 281242,
            duration = 3600,
            max_stack = 1,
        },
        demon_spikes = {
            id = 203819,
            duration = 6,
            max_stack = 1,
        },
        demonic_wards = {
            id = 203513,
        },
        double_jump = {
            id = 196055,
        },
        feast_of_souls = {
            id = 207693,
            duration = 6,
            max_stack = 1,
        },
        fel_devastation = {
            id = 212084,
        },
        fiery_brand = {
            id = 207771,
            duration = 8,
            max_stack = 1,
        },
        frailty = {
            id = 247456,
            duration = 26,
            type = "Magic",
            max_stack = 1,
        },
        glide = {
            id = 131347,
            duration = 3600,
            max_stack = 1,
        },
        immolation_aura = {
            id = 178740,
            duration = 6,
            max_stack = 1,
        },
        infernal_striking = {
            duration = 1,
            generate = function ()
                local is = buff.infernal_striking

                is.count = 1
                is.expires = last_infernal_strike + 1
                is.applied = last_infernal_strike
                is.caster = "player"
            end,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        metamorphosis = {
            id = 187827,
            duration = 5,
            max_stack = 1,
        },
        shattered_souls = {
            id = 204254,
        },
        sigil_of_chains = {
            id = 204843,
            duration = function () return talent.concentrated_sigils.enabled and 8 or 6 end,
            max_stack = 1,
        },
        sigil_of_flame = {
            id = 204598,
            duration = function () return talent.concentrated_sigils.enabled and 8 or 6 end,
            max_stack = 1,
        },
        sigil_of_misery = {
            id = 207685,
            duration = function () return talent.concentrated_sigils.enabled and 22 or 20 end,
            max_stack = 1,
        },
        sigil_of_silence = {
            id = 204490,
            duration = function () return talent.concentrated_sigils.enabled and 8 or 6 end,
            max_stack = 1,
        },
        soul_barrier = {
            id = 263648,
            duration = 12,
            max_stack = 1,
        },
        soul_fragments = {
            id = 203981,
            duration = 3600,
            max_stack = 5,
        },
        spectral_sight = {
            id = 188501,
        },
        spirit_bomb = {
            id = 247454,
        },
        torment = {
            id = 185245,
            duration = 3,
            max_stack = 1,
        },
        void_reaver = {
            id = 268178,
            duration = 12,
            max_stack = 1,
        },
    } )


    spec:RegisterStateFunction( "create_sigil", function( sigil )
        -- set up charge time, somehow.
        -- 2s baseline, 1s w/ quickened_sigils
    end )

    spec:RegisterStateExpr( "soul_fragments", function ()
        return buff.soul_fragments.stack
    end )

    spec:RegisterStateExpr( "last_metamorphosis", function ()
        return action.metamorphosis.lastCast
    end )

    spec:RegisterStateExpr( "last_infernal_strike", function ()
        return action.infernal_strike.lastCast
    end )


    spec:RegisterStateTable( "fragments", {
        real = 0,
        realTime = 0,
    } )

    spec:RegisterStateFunction( "queue_fragments", function( num )
        fragments.real = fragments.real + num
        fragments.realTime = GetTime() + 1.25
    end )

    spec:RegisterStateFunction( "purge_fragments", function()
        fragments.real = 0
        fragments.realTime = 0            
    end )


    local queued_frag_modifier = 0

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_CAST_SUCCESS" then
                -- Fracture:  Generate 2 frags.
                if spellID == 263642 then
                    queue_fragments( 2 ) end
                
                -- Shear:  Generate 1 frag.
                if spellID == 203782 then 
                    queue_fragments( 1 ) end
                
                --[[ Spirit Bomb:  Up to 5 frags.
                if spellID == 247454 then
                    local name, _, count = FindUnitBuffByID( "player", 203981 )
                    if name then queue_fragments( -1 * count ) end
                end

                -- Soul Cleave:  Up to 2 frags.
                if spellID == 228477 then 
                    local name, _, count = FindUnitBuffByID( "player", 203981 )
                    if name then queue_fragments( -1 * min( 2, count ) ) end
                end ]]
            
            -- We consumed or generated a fragment for real, so let's purge the real queue.
            elseif spellID == 203981 and fragments.real > 0 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
                fragments.real = fragments.real - 1
            
            end
        end
    end )
    
    spec:RegisterHook( "reset_precast", function ()
        last_metamorphosis = nil
        last_infernal_strike = nil

        if fragments.realTime > 0 and fragments.realTime < now then
            fragments.real = 0
            fragments.realTime = 0
        end

        if buff.soul_fragments.down then
            -- Apply the buff with zero stacks.
            applyBuff( "soul_fragments", nil, 0 + fragments.real )
        elseif fragments.real > 0 then
            addStack( "soul_fragments", nil, fragments.real )
        end
    end )

    
    -- Gear Sets
    spec:RegisterGear( "tier19", 138375, 138376, 138377, 138378, 138379, 138380 )
    spec:RegisterGear( "tier20", 147130, 147132, 147128, 147127, 147129, 147131 )
    spec:RegisterGear( "tier21", 152121, 152123, 152119, 152118, 152120, 152122 )
    spec:RegisterGear( "class", 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )

    spec:RegisterGear( "convergence_of_fates", 140806 )

    spec:RegisterGear( "achor_the_eternal_hunger", 137014 )
    spec:RegisterGear( "anger_of_the_halfgiants", 137038 )
    spec:RegisterGear( "chaos_theory", 151798 )
    spec:RegisterGear( "cloak_of_fel_flames", 137066 )
    spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
    spec:RegisterGear( "delusions_of_grandeur", 144279 )
    spec:RegisterGear( "fragment_of_the_betrayers_prison", 138854 )
    spec:RegisterGear( "kirel_narak", 138949 )
    spec:RegisterGear( "loramus_thalipedes_sacrifice", 137022 )
    spec:RegisterGear( "moarg_bionic_stabilizers", 137090 )
    spec:RegisterGear( "oblivions_embrace", 151799 )
    spec:RegisterGear( "raddons_cascading_eyes", 137061 )
    spec:RegisterGear( "runemasters_pauldrons", 137071 )
    spec:RegisterGear( "soul_of_the_slayer", 151639 )
    spec:RegisterGear( "spirit_of_the_darkness_flame", 144292 )
        spec:RegisterAura( "spirit_of_the_darkness_flame", {
            id = 235543,
            duration = 3600,
            max_stack = 15
        } )
    


    -- Abilities
    spec:RegisterAbilities( {
        consume_magic = {
            id = 278326,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            startsCombat = true,
            texture = 828455,
            
            usable = function () return debuff.dispellable_magic.up end,
            handler = function ()
                removeDebuff( "dispellable_magic" )
                gain( 20, "pain" )
            end,
        },
        

        demon_spikes = {
            id = 203720,
            cast = 0,
            charges = function () return ( ( level < 116 and equipped.oblivions_embrace ) and 3 or 2 ) end,
            cooldown = 20,
            recharge = 20,
            hasteCD = true,
            gcd = "spell",

            defensive = true,
            
            startsCombat = false,
            texture = 1344645,

            toggle = "defensives",
            
            handler = function ()
                applyBuff( "demon_spikes", buff.demon_spikes.remains + buff.demon_spikes.duration )
            end,
        },
        

        disrupt = {
            id = 183752,
            cast = 0,
            cooldown = 15,
            gcd = "off",
            
            interrupt = true,

            startsCombat = true,
            texture = 1305153,

            toggle = "interrupts",
            usable = function () return target.casting end,            
            handler = function ()
                gain( 30, "pain" )
                interrupt()
            end,
        },
        

        fel_devastation = {
            id = 212084,
            cast = 2,
            fixedCast = true,
            channeled = true,
            cooldown = 60,
            gcd = "spell",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 1450143,

            talent = "fel_devastation",
            
            handler = function ()
                applyBuff( "fel_devastation" )
            end,
        },
        

        felblade = {
            id = 232893,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = -30,
            spendType = "pain",
            
            startsCombat = true,
            texture = 1344646,

            talent = "felblade",
            
            handler = function ()
                setDistance( 5 )
            end,
        },
        

        fiery_brand = {
            id = 204021,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1344647,
            
            handler = function ()
                applyDebuff( "target", "fiery_brand" )
            end,
        },
        

        fracture = {
            id = 263642,
            cast = 0,
            charges = 2,
            cooldown = 4.5,
            recharge = 4.5,
            hasteCD = true,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1388065,
            
            handler = function ()
                gain( 25, "pain" )
                addStack( "soul_fragments", nil, 2 )
            end,
        },
        

        --[[ glide = {
            id = 131347,
            cast = 0,
            cooldown = 1.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1305157,
            
            handler = function ()
            end,
        }, ]]
        

        immolation_aura = {
            id = 178740,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344649,
            
            handler = function ()
                applyBuff( "immolation_aura" )

                if level < 116 and equipped.kirel_narak then
                    cooldown.fiery_brand.expires = cooldown.fiery_brand.expires - ( 2 * active_enemies )
                end
            end,
        },
        

        imprison = {
            id = 217832,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1380368,
            
            handler = function ()
                applyDebuff( "target", "imprison" )
            end,
        },
        

        infernal_strike = {
            id = 189110,
            cast = 0,
            charges = 2,
            cooldown = function () return talent.abyssal_strike.enabled and 12 or 20 end,
            recharge = function () return talent.abyssal_strike.enabled and 12 or 20 end,
            gcd = "off",
            
            startsCombat = true,
            texture = 1344650,

            nobuff = "infernal_striking",
            
            handler = function ()
                setDistance( 5 )
                applyBuff( "infernal_striking" )
                
                if talent.flame_crash.enabled then
                    create_sigil( "flame" )
                end
            end,
        },
        

        metamorphosis = {
            id = 187827,
            cast = 0,
            cooldown = 180,
            gcd = "off",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1247263,
            
            handler = function ()
                applyBuff( "metamorphosis" )
                gain( 7, "pain" )

                if level < 116 and equipped.runemasters_pauldrons then
                    setCooldown( "sigil_of_chains", 0 )
                    setCooldown( "sigil_of_flame", 0 )
                    setCooldown( "sigil_of_misery", 0 )
                    setCooldown( "sigil_of_silence", 0 )
                    gainCharges( "demon_spikes", 1 )
                end

                last_metamorphosis = query_time
            end,
        },
        

        shear = {
            id = 203782,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -10,
            spendType = "pain",
            
            startsCombat = true,
            texture = 1344648,

            notalent = "fracture",
            
            handler = function ()
                addStack( "soul_fragments", nil, 1 )
            end,
        },
        

        sigil_of_chains = {
            id = 202138,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1418286,

            talent = "sigil_of_chains",
            
            handler = function ()
                create_sigil( "chains" )
                
                if level < 116 and equipped.spirit_of_the_darkness_flame then
                    addStack( "spirit_of_the_darkness_flame", nil, active_enemies )
                end
            end,
        },
        

        sigil_of_flame = {
            id = function () return talent.concentrated_sigils.enabled and 204513 or 204596 end,
            known = 204596,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344652,
            
            handler = function ()
                create_sigil( "flame" )
            end,

            copy = { 204596, 204513 }
        },
        

        sigil_of_misery = {
            id = function () return talent.concentrated_sigils.enabled and 202140 or 207684 end,
            known = 207684,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1418287,
            
            handler = function ()
                create_sigil( "misery" )
            end,

            copy = { 207684, 202140 }
        },
        

        sigil_of_silence = {
            id = function () return talent.concentrated_sigils.enabled and 207682 or 202137 end,
            known = 202137,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1418288,
            
            toggle = "interrupts",

            usable = function () return debuff.casting.remains > ( talent.quickened_sigils.enabled and 1 or 2 ) end,
            handler = function ()
                interrupt() -- early, but oh well.
                create_sigil( "silence" )
            end,

            copy = { 207682, 202137 },
        },
        

        soul_barrier = {
            id = 263648,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 2065625,

            talent = "soul_barrier",
            
            handler = function ()
                if talent.feed_the_demon.enabled then
                    gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
                end
                
                buff.soul_fragments.count = 0
                applyBuff( "soul_barrier" )
            end,
        },
        

        soul_cleave = {
            id = 228477,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "pain",
            
            startsCombat = true,
            texture = 1344653,
            
            handler = function ()
                if talent.feed_the_demon.enabled then
                    gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
                end
                
                removeStack( "soul_fragments", min( buff.soul_fragments.stack, 2 ) )
                if talent.void_reaver.enabled then applyDebuff( "target", "void_reaver" ) end
            end,
        },
        

        --[[ spectral_sight = {
            id = 188501,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1247266,
            
            handler = function ()
            end,
        }, ]]
        

        spirit_bomb = {
            id = 247454,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "pain",
            
            startsCombat = true,
            texture = 1097742,
            
            buff = "soul_fragments",

            handler = function ()
                if talent.feed_the_demon.enabled then
                    gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
                end

                buff.soul_fragments.count = 0
            end,
        },
        

        throw_glaive = {
            id = 204157,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1305159,
            
            handler = function ()
            end,
        },
        

        torment = {
            id = 185245,
            cast = 0,
            cooldown = 8,
            gcd = "off",
            
            startsCombat = true,
            texture = 1344654,
            
            handler = function ()
                applyDebuff( "target", "torment" )
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
    
        potion = "steelskin_potion",
    
        package = "Vengeance",
    } )


    spec:RegisterPack( "Vengeance", 20180929.2101, [[dO0dvaqivfLhrvPnPQGpPGQgfuL6uqvPvPGk9kqPzrv0Taf2fQ8lvvddvLJbQSmufpduLPbvHRbQQTPQO6BqvY4afDoQkADkiMhQsUNQyFQk0bHQOfQqEiQQQjsvHlQGsTrfuIpQGIAKOQkNevPALkPzQGs6MkOIDsv1qvvKLIQkpvKPsv6QkOiBfQk(QckyVs(RsnychM0Ib5XenzrDzKndLpReJwbonLxRQ0SPYTv0UL63adhQCCfuOLd55OmDHRRkTDfQVRG04rvkNNQW8HQQ9RYfCL3kL1Gk)8WhCWKpFYJp54bo(4boywPWdCuLWPYV6cvPwNuLWhQxiTLuLWPE4aAU8wjg4fjPknicCSH8)VyXGxiojy(ZS5Rtdd0sKIf)mBk)HCaOFimfgzA8poeaZCe7)tiIFQLz)FIFBFqtqV5V3oi0gFOEH0wsCmBkRe0R5cEVlOkL1Gk)8WhCWKpFYJp54bo(4bo8QsmCKS8dFycxLgy5m1fuLYetwjFpb(q9cPTKoHpOjOpb)92bHU1brGJnK))flg8cXjbZFMnFDAyGwIuS4Nzt5pKda9dHPWitJ)XHayMJy)Fcr8tTm7)t8B7dAc6n)92bH24d1lK2sIJzt5T67jseUGMqe6e84tppbp8bhmpbmobmhc8H5j(0W5wVvFpb)pq7fInKB13taJtGN5mLpHpmg6fxCIaCImHPVU4eQmmqFcNXcUB13taJtW)GEmHckFIxgTTGMNG6aze7eya0jcK1FPGDIaCIxgTTGMmUB13taJtGN5mLpbdmPtyTemTE5ezDQl0j(pHCGIwOtirwqitpraoHpOjOprcN9LyC3QVNagNGFeJqJPtONqoqrl0jayNG3BmcPUtKcK9LoHgNqDUte2KyCvchcGzoQs(Ec8H6fsBjDcFqtqFc(7TdcDRdIahBi))lwm4fItcM)mB(60WaTePyXpZMYFiha6hctHrMg)JdbWmhX()eI4NAz2)N432h0e0B(7TdcTXhQxiTLehZMYB13tKiCbnHi0j4XNEEcE4doyEcyCcyoe4dZt8PHZTER(Ec(FG2leBi3QVNagNapZzkFcFym0lU4eb4ezctFDXjuzyG(eoJfC3QVNagNG)b9ycfu(eVmABbnpb1bYi2jWaOteiR)sb7eb4eVmABbnzC3QVNagNapZzkFcgysNWAjyA9YjY6uxOt8Fc5afTqNqISGqMEIaCcFqtqFIeo7lX4UvFpbmob)igHgtNqpHCGIwOtaWobV3yesDNifi7lDcnoH6CNiSjX4U1B13tmS5ns(gu(eqegarNqcMqACciAXAg3jWtPKWfSt0Gggdu0e71DcvggOzNa0op4UvvggOzC4qKemH04bZPSV3Qkdd0moCiscMqAa7ZV(UmPo0Wa9TQYWanJdhIKGjKgW(8Jba5B13tKAfhBaiobsT8jGEXWO8jyHgStaryaeDcjycPXjGOfRzNq78jWHiyGdeH1lNWyNidAI7wvzyGMXHdrsWesdyF(zTIJnaeBwOb7wvzyGMXHdrsWesdyF(Xbcd036T67jg28gjFdkFcAmH84eHnPtedOtOYaGoHXoHownNc5iUBvLHbA2J(gGTgHk)ERQmmqZG95pBm0lU4wvzyGMb7ZVe0S3jTN6IjVvvggOzW(8)YOTf0K5PH98zi1YBAm1bNMZmoI3mwWWp(vzyJPn100i2hH7wvzyGMb7ZVuDUTkdd0BNXcpBDspqiTZEAypH6Oo4KdueIYBmhXgWrTc5O8TQYWand2NFP6CBvggO3oJfE26KEYeg1mBmXUvvggOzW(8lvNBRYWa92zSWZwN0tdqt1DR3QVNyyXiKhNyes78j4hi0Wa9TQYWanJdcPD(HzlMBdW2yoDsEAypsaWLbdT5Wmc5XgcPDMdrt1AgV45wvzyGMXbH0od7ZV1yeQv3Mfi7l5PH9ibaxgm0MdZiKhBiK2zoenvRzp8DRQmmqZ4GqANH95hZiKhBiK25BvLHbAghes7mSp)2CcCAyGERVi1td7jdcomJqESHqAN5ct(16LBvLHbAghes7mSp)yKBNPXkl0WaTNg2tgeCygH8ydH0oZfM8R1l3Qkdd0moiK2zyF(TgJqT62SazFjpnSNmi4Wmc5XgcPDMlm5xRxUvvggOzCqiTZW(8ZSfZTbyBmNojpnSNmi4Wmc5XgcPDMlm5xRxU1B13t4dcJAMnMy3Qkdd0mUmHrnZgtSNmnb9MHZ(smpnSh8g7152isoqrl0oSjXl4(G1sW06LDwN6cTHhdFXp(XBvg2yAtnnnI9r49bRLGP1l7So1fAdp2hGEXW4Y0e0Bgo7lX4YGH24l(XpEBTemTEzN1PUqB4Z(iFC8a)H7asDXaUPYB47TQYWanJltyuZSXed2N)jf6eGWnaWm2TQYWanJltyuZSXed2NFmJqESHqANV1B13t4hGMQ7e8deAyG(wvzyGMX1a0uDpwJrOwDBwGSVKNg2d2RZTrKCGIwODytIxWDRQmmqZ4AaAQoyF(z4mKfBiWeYtd7HbEDBmKUmPoyF8bpUvvggOzCnanvhSp)mWRBlDKoM80WE(SqDuhCmCgYIneycXrTc5O8TQYWanJRbOP6G95NbEDBPJ0XKNg2tOoQdogodzXgcmH4OwHCu(dmWRBJH0Lj1b7HVBvLHbAgxdqt1b7ZVnNaNggO36ls90WEWPwZRhFY3TQYWanJRbOP6G95hJCqontEAyp4uR51dEX3TQYWanJRbOP6G95hdPY4frEAypmWRBJH0Lj1bJxpW7wvzyGMX1a0uDW(8JrUDMgRSqdd03Qkdd0mUgGMQd2NFMTyUnaBJ50jDRQmmqZ4AaAQoyF(zdifDRQmmqZ4AaAQoyF(JbiWq3lo1gtvAmHygOl)8WhCWKpFYhpCWbtEGFLgQIARxyvAyap5NFE3)W8qoXj8oGoHnXbqXjWaOtm8zctFDXWFcenm(AikFcgysNqFdWudkFc5aTxig3ToSAnDc4gYjgMA2loCauq5tOYWa9jgE9naBncv(D45U1BL3N4aOGYNa(NqLHb6t4mwW4U1kPVXaaQsjBY)vYzSGvERees7C5T8dx5TsuRqokxJQKezbHmTssaWLbdT5Wmc5XgcPDMdrt1A2j41j4PsQmmqxjMTyUnaBJ50jvr5NNYBLOwHCuUgvjjYcczALKaGldgAZHzeYJnes7mhIMQ1St8Cc(QKkdd0vYAmc1QBZcK9LQO8dVYBLuzyGUsygH8ydH0oxjQvihLRrvu(XJYBLOwHCuUgvjjYcczALYGGdZiKhBiK2zUWKFTEPsQmmqxjBobonmqV1xKwr5h(L3krTc5OCnQssKfeY0kLbbhMrip2qiTZCHj)A9sLuzyGUsyKBNPXkl0WaDfL)pV8wjQvihLRrvsISGqMwPmi4Wmc5XgcPDMlm5xRxQKkdd0vYAmc1QBZcK9LQO8JxL3krTc5OCnQssKfeY0kLbbhMrip2qiTZCHj)A9sLuzyGUsmBXCBa2gZPtQIkQuMW0xxuEl)WvERKkdd0vsFdWwJqLFRe1kKJY1Okk)8uERKkdd0vkBm0lUOsuRqokxJQO8dVYBLuzyGUssqZEN0EQlMSsuRqokxJQO8JhL3krTc5OCnQssKfeY0k9zNaPwEtJPo40CMXr8MXc2jWp(pHkdBmTPMMgXoXhpbCvsLHb6k9YOTf0Kvr5h(L3krTc5OCnQssKfeY0kfQJ6GtoqrikVXCeBah1kKJYvsLHb6kjvNBRYWa92zSOsoJf7wNuLGqANRO8)5L3krTc5OCnQsQmmqxjP6CBvggO3oJfvYzSy36KQuMWOMzJjwfLF8Q8wjQvihLRrvsLHb6kjvNBRYWa92zSOsoJf7wNuLAaAQUkQOs4qKemH0O8w(HR8wjQvihLRrvu(5P8wjQvihLRrvu(Hx5TsuRqokxJQO8JhL3krTc5OCnQIYp8lVvsLHb6kHdegORe1kKJY1OkQOszcJAMnMyL3YpCL3krTc5OCnQssKfeY0kH3Na7152isoqrl0oSjDcEDc4oXhoH1sW06LDwN6cTHh7e47jWp(pbEFcvg2yAtnnnIDIpEc4DIpCcRLGP1l7So1fAdp2j(WjGEXW4Y0e0Bgo7lX4YGH2NaFpb(X)jW7tyTemTEzN1PUqB4ZoXhpbFC8a)tmCpXasDXaUPYBNaFRKkdd0vkttqVz4SVeRIYppL3kPYWaDLMuOtac3aaZyvIAfYr5AufLF4vERKkdd0vcZiKhBiK25krTc5OCnQIkQudqt1vEl)WvERe1kKJY1OkjrwqitRe2RZTrKCGIwODyt6e86eWvjvggORK1yeQv3Mfi7lvr5NNYBLOwHCuUgvjjYcczALyGx3gdPltQd2j(4ZjWJkPYWaDLy4mKfBiWeQIYp8kVvIAfYr5AuLKiliKPv6ZorOoQdogodzXgcmH4OwHCuUsQmmqxjg41TLoshtvu(XJYBLOwHCuUgvjjYcczALc1rDWXWzil2qGjeh1kKJYN4dNGbEDBmKUmPoyN45e8vjvggORed862shPJPkk)WV8wjQvihLRrvsISGqMwjCQ1NGxpNWN8vjvggORKnNaNggO36lsRO8)5L3krTc5OCnQssKfeY0kHtT(e865e4fFvsLHb6kHroiNMPkk)4v5TsuRqokxJQKezbHmTsmWRBJH0Lj1b7e865eWRsQmmqxjmKkJxevr5hML3kPYWaDLWi3otJvwOHb6krTc5OCnQIYVplVvsLHb6kXSfZTbyBmNoPkrTc5OCnQIYpC8vERKkdd0vInGuuLOwHCuUgvr5ho4kVvsLHb6kfdqGHUxCQnMQe1kKJY1OkQOIkQOka]] )

    
end
