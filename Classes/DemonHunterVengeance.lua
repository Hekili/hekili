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


    local queued_frag_modifier = 0

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_CAST_SUCCESS" then
                if spellID == 263642 then queued_frag_modifier = 2 end
                if spellID == 203782 then queued_frag_modifier = 1 end
                if spellID == 247454 then queued_frag_modifier = -5 end
                if spellID == 228477 then queued_frag_modifier = -2 end
            
            elseif spellID == 203981 then
                queued_frag_modifier = 0
            end
        end
    end )
    
    spec:RegisterHook( "reset_precast", function ()
        last_metamorphosis = nil
        last_infernal_strike = nil

        if queued_frag_modifier ~= 0 then
            buff.soul_fragments.count = min( 5, max( 0, buff.soul_fragments.count + queued_frag_modifier ) )

            if buff.soul_fragments.count > 0 and buff.soul_fragments.down then
                applyBuff( "soul_fragments", 3600, buff.soul_fragments.count )
            end

            if buff.soul_fragments.count == 0 then removeBuff( "soul_fragments" ) end
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
                
                removeBuff( "soul_fragments" )
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
                
                removeStack( "soul_fragments", 2 )

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
                
                removeBuff( "soul_fragments" )
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
    
        package = "Vengeance",
    } )


    spec:RegisterPack( "Vengeance", 20180802.2126, [[duupsaqiPc0JKQQ2ePk(KuHAvsfWRKQmlsr3sQk2fq)IuzyiKJbIwgIQNrQkttQuDnPs2gII8nPImoefohPkzDsvLMhIs3tuTpPs5GsfKfkkEiPkvMOuvIlkviTrsvk(iPkLgPuH4KsvPwjintsvQANKslvQQ4PKmveCvefvBvQG6Rikk7L4Vk1Gb1HHwSsEmktwkxMYMvPpRcJwu60cVgeMns3gWUL8BfdhroUuvslxvphvtNQRRI2oc13jvvJxQOopPW(fzbsHGOAOBIwYjcsYGiYGiYbjhsY7Ql9suUgKmrrczqGhMOkeWevh2QddlMjksOg0bBcbrXNZNzIkR7K49RoDhHN9CbYgaD8a4KIEmf7XRRJhamDl6S0TUyFAgX6i9ZnOgxhHWEYHuhbYHC3xmGP2DKZYTF3HT6WWIzG8aGjQ1zq9(UKLOAOBIwYjcsYGiYGiYbjNi9PxDVtIItYyI2UidifvZ4mrriBWtWbpbJjysidc8WsWZnbJmpMkbtdUZtW35tWDedIGgGII0p3GAIQ)j4oANn2PBTe8YUZBjy2aSqpbVSJO4Gj4oeJzKCEcUMQpzXh4EstWiZJP4j4POAaMGImpMIds6n2aSqp)sroejOiZJP4GKEJnal07LRdppaSYrpMkbfzEmfhK0BSbyHEVCD3zAjO9pbRkKep74j4hJwcEDEVwlbZD05j4LDN3sWSbyHEcEzhrXtWy1sWKERpKg3J6ibh8eCBkdmbfzEmfhK0BSbyHEVCD8cjXZo(M7OZtqrMhtXbj9gBawO3lxhPXJPsqtq7FcUJ2zJD6wlbBeBVgjypaSeSN1sWiZNpbh8emsmguCrnWeuK5Xu8C80Nn6oYGibfzEmfVxUo2u8taBdGhblbfzEmfVxUUwW)tsEckY8ykEVCDNCBhUbOjNoEU)rbH5qMGImpMI3lxhdP0nY8yQnn4UMfcy5RhRMMXn3rQvoill(V12xQXZcAfUOwlbfzEmfVxUogsPBK5XuBAWDnleWYB21kEqSXtqrMhtX7LRJHu6gzEm1MgCxZcbS8AEaKMGMG2)eSEtyVgj4mpwTeC)mo6XujOiZJP4GRhRwopoc6EU7lfbmnJBoBgAB0FbEd71yVESAGVbGrXjl5jOiZJP4GRhRwVCDrDTVq6M7FaHPzCZzZqBJ(lWByVg71Jvd8namkEorjOiZJP4GRhRwVCD3WEn2RhRwckY8yko46XQ1lxxaamu0JP245JAg3824G3WEn2RhRgOhmiI6ibfzEmfhC9y16LR7A0DZig5o6XuAg3824G3WEn2RhRgOhmiI6ibfzEmfhC9y16LRlQR9fs3C)dimnJBEBCWByVg71Jvd0dgerDKGImpMIdUESA9Y1XJJGUN7(sratZ4M3gh8g2RXE9y1a9GbruhjOjO9pb3xSRv8GyJNGImpMId2SRv8GyJN3mGP2CsbegxZ4MhfBaI6y3qa8W2DX7wwdPEwqaSZDaIaHupSS4Fy8UbGDEZYI)HX7drGK3vckY8ykoyZUwXdInEVCDaMJaZtk7WdEckY8ykoyZUwXdInEVCD3WEn2RhRwcAcA)tWANhaPj4(zC0JPsqrMhtXbR5bqAEux7lKU5(hqyAg3Cww8pm(((iZJPqA3aWoVzzX)W49HiqY7kbfzEmfhSMhaP9Y1XjfF471aS0mU585KUVpEayLZ7wE3tqrMhtXbR5bqAVCDbaWqrpMAJNpQzCZjHrr2C9IOeuK5XuCWAEaK2lx31Olk2mnJBojmkYM3jIsqrMhtXbR5bqAVCD85KUzudj20mU5osTYb5KIp89AawGwHlQ10JJuRCW7Jm)8nqRWf1A6HpN099XdaRCEor6HndTn6VaVpY8Z3azzX)W477JmpMcPKfsWo1vckY8ykoynpas7LR7(iZpFtZ4MZNt6((4bGvoNS56lbfzEmfhSMhaP9Y1Dn6UzeJCh9yQeuK5XuCWAEaK2lxhFoPBg1qInnJBEh0rQvoiNu8HVxdWc0kCrTwckY8ykoynpas7LRJpN0nJAiXMMXn3rQvoiNu8HVxdWc0kCrTME4ZjDFF8aWkNNtuckY8ykoynpas7LRJhhbDp39LIawckY8ykoynpas7LR7(iZpFlbfzEmfhSMhaP9Y1XZA4NGImpMIdwZdG0E568S)O)9bfdInrPF8ROo4IImRd1pA7BT6T9BcobtiRLGdasZ7j478j4oUzx8K6DCc(T(6z8wlbZhalbJN(aGU1sWSSyDyCWeu9(OSemK9BcMmV4NKinVBTemY8yQeChJN(Sr3rgeDmycAcAFdqAE3Aj4UsWiZJPsW0G7CWeurHNE25fLka07efn4oxiiQ1JvtiiAHuiikRWf1AsgrX(WTpqrXMH2g9xG3WEn2RhRg4Bayu8emztWKlkK5XuIIhhbDp39LIaM4IwYfcIYkCrTMKruSpC7duuSzOTr)f4nSxJ96XQb(gagfpbNNGjsuiZJPevux7lKU5(hqyIlA1NqquiZJPe1nSxJ96XQjkRWf1AsgXfTDxiikRWf1AsgrX(WTpqr1gh8g2RXE9y1a9GbruhIczEmLOcaGHIEm1gpFuCrBxcbrzfUOwtYik2hU9bkQ24G3WEn2RhRgOhmiI6quiZJPe11O7MrmYD0JPex0sMecIYkCrTMKruSpC7duuTXbVH9ASxpwnqpyqe1HOqMhtjQOU2xiDZ9pGWex02jHGOScxuRjzef7d3(afvBCWByVg71Jvd0dgerDikK5XuIIhhbDp39LIaM4IlQMDXtQleeTqkeefY8ykrHN(Sr3rgeIYkCrTMKrCrl5cbrHmpMsuSP4Na2gapcMOScxuRjzex0QpHGOqMhtjQwW)tsUOScxuRjzex02DHGOScxuRjzefY8ykrDYTD4gGO40XfL)rbH5qkUOTlHGOScxuRjzef7d3(afLJuRCqww8FRTVuJNf0kCrTMOqMhtjkgsPBK5XuBAWDrrdUVleWe16XQjUOLmjeeLv4IAnjJOqMhtjkgsPBK5XuBAWDrrdUVleWevZUwXdInU4I2ojeeLv4IAnjJOqMhtjkgsPBK5XuBAWDrrdUVleWevnpasfxCrr6n2aSqxiiAHuiikRWf1AsgXfTKleeLv4IAnjJ4Iw9jeeLv4IAnjJ4I2UleeLv4IAnjJ4I2UecIczEmLOinEmLOScxuRjzexCr1SRv8GyJleeTqkeeLv4IAnjJOyF42hOOIInarDSBiaEy7U4j4ULGZAi1ZccGDob3bsWebczcwpjyww8pmEcUBjyaSZBww8pmEcUpjyIajVlrHmpMsundyQnNuaHXfx0sUqquiZJPefG5iW8KYo8GlkRWf1AsgXfT6tiikK5XuI6g2RXE9y1eLv4IAnjJ4IlQAEaKkeeTqkeeLv4IAnjJOyF42hOOyzX)W477JmpMcPj4ULGbWoVzzX)W4j4(KGjcK8UefY8ykrf11(cPBU)beM4IwYfcIYkCrTMKruSpC7duu85KUVpEayLZtWDlpb3DrHmpMsuCsXh(EnalXfT6tiikRWf1AsgrX(WTpqrrcJkbt28eSErKOqMhtjQaayOOhtTXZhfx02DHGOScxuRjzef7d3(affjmQemzZtWDIirHmpMsuxJUOyZex02LqquwHlQ1KmII9HBFGIYrQvoiNu8HVxdWc0kCrTwcwpjyhPw5G3hz(5BGwHlQ1sW6jbZNt6((4bGvopbNNGjkbRNemBgAB0FbEFK5NVbYYI)HX33hzEmfstWKnbdjyN6suiZJPefFoPBg1qInXfTKjHGOScxuRjzef7d3(affFoP77Jhaw58emzZtW6tuiZJPe19rMF(M4I2ojeefY8ykrDn6UzeJCh9ykrzfUOwtYiUOLmecIYkCrTMKruSpC7duuDWeSJuRCqoP4dFVgGfOv4IAnrHmpMsu85KUzudj2ex0QxcbrzfUOwtYik2hU9bkkhPw5GCsXh(EnalqRWf1Ajy9KG5ZjDFF8aWkNNGZtWejkK5XuIIpN0nJAiXM4IwijsiikK5XuIIhhbDp39LIaMOScxuRjzex0cjKcbrHmpMsu3hz(5BIYkCrTMKrCrlKKleefY8ykrXZA4lkRWf1AsgXfTqQpHGOqMhtjkp7p6FFqXGytuwHlQ1KmIlU4IlUia]] )

    
end
