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

            toggle = "interrupts",
            
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
            gcd = "off",

            defensive = true,
            
            startsCombat = false,
            texture = 1344645,

            toggle = "defensives",

            readyTime = function ()
                return max( 0, ( 1 + action.demon_spikes.lastCast ) - query_time )
            end, 
                -- ICD
            
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
            
            toggle = "defensives",
            
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


    spec:RegisterPack( "Vengeance", 20181014.1134, [[dSuGwaqiqO8iQcBIqYNuvcJsbLtPeXQuvIEfbmlQIULQI2fu9lqAyeQoMsQLPQWZiuMMQsDncKTbcvFtbHXbc5CuvK1PeL5ri6EQQ2hHWbvqAHkHhQGOjQGQlQevAJkrf(OsurJujsojvf1kvLMPsKQUPsuv7ub(PsuLHsGQLsvHNk0uPkDvLiv2kbkFvjsXEL6Vk1Gr6WKwmOEmrtwWLrTzO8zfA0uvDAkVgenBQCBfTBj)gy4e0XvIuA5qEoIPl66QITRK8DcPgVQs68uvA(GG9RY962BhdAY9GpeFneTw81FJVETyFlOoM(kK7OqvcPoYDS0j3rbJRrwlj3rHQVoGgAVDKaEqsUJ(ZuizzqHoAP)hyCjycLyZhNMgOKiflHsSPekSdadfgt)mWRGkebWmhtGk4i2hQfiqfCFShopb1EPEQKrBbJRrwljJtSPSJWpMl95QH7yqtUh8H4RHO1IVwm8petCisSV7iril7bccIw3r)wiWvd3XatKD0JJkyCnYAj5JoCEcQJUupvYO71FMcjldk0rl9)aJlbtOeB(400aLePyjuInLqHDayOWy6NbEfuHiaM5ycubhX(qTabQG7J9W5jO2l1tLmAlyCnYAjzCInL3RhhD5jtamJo66V98OFi(Ai6OFE01RxMyFF0HU8V371JJoK(1AKjl7E94OFE0HgcC4Od3iOhH5rtWrdmM(4YJQY0a1rDgjXVxpo6NhDib1kgLC4OpeEBjppkxjYyYrXaOJMiRGKtYrtWrFi82sEsWVxpo6NhDOHahokbm5JALemTA8ObDQJ8rHEuPFfnYhvISKrME0eC0HZtqD0OqdsMGFVEC0ppQpycJwXhvpQ0VIg5JcWoQpxymsDhnMids(OAEu15oAAtMGFVEC0pp6qdboC0i4XD0fkczmcVJcramZXD0JJkyCnYAj5JoCEcQJUupvYO71FMcjldk0rl9)aJlbtOeB(400aLePyjuInLqHDayOWy6NbEfuHiaM5ycubhX(qTabQG7J9W5jO2l1tLmAlyCnYAjzCInL3RhhD5jtamJo66V98OFi(Ai6OFE01RxMyFF0HU8V371JJoK(1AKjl7E94OFE0HgcC4Od3iOhH5rtWrdmM(4YJQY0a1rDgjXVxpo6NhDib1kgLC4OpeEBjppkxjYyYrXaOJMiRGKtYrtWrFi82sEsWVxpo6NhDOHahokbm5JALemTA8ObDQJ8rHEuPFfnYhvISKrME0eC0HZtqD0OqdsMGFVEC0ppQpycJwXhvpQ0VIg5JcWoQpxymsDhnMids(OAEu15oAAtMGFVEC0pp6qdboC0i4XD0fkczmc)EVxpo6Y9RS8j5WrHzmaIpQemH18OW8Ove8JouPKfMKJwG6t)kAI94oQktduKJckNV43RktdueCHiwcMWA(J5ucK3RktdueCHiwcMWAkWpu9zCYvQPbQ7vLPbkcUqelbtynf4hkgaeUxpoASuHe)G8Oi1chf(bdJdhLKAsokmJbq8rLGjSMhfMhTICuTchviI)uiitRgpQroAaum(9QY0afbxiILGjSMc8dLuQqIFqUjPMK7vLPbkcUqelbtynf4hQqqAG6EVxpo6Y9RS8j5Wr5vmY3JM2KpA6NpQkta6Og5O6k1CkSJXVxvMgOi)6tc2AMQeY7vLPbkIa)qdgb9imVxvMgOic8dvckYZK3tD0K3Rktdueb(H(q4TL8K4PH9dXqQf28kUsCnei48xnssGaeuzAR4nx80yIiwFVQmnqre4hQuDUTktduBNrsplDY)WiTcEAy)P64kXL(veIdBmht8JZLc74W9QY0afrGFOs152QmnqTDgj9S0j)hymUi2kMCVQmnqre4hQuDUTktduBNrsplDY)fanv39EVEC0LdJr(E0fiTch1hGutdu3RktdueCyKwHFInAUnaBJ50j7PH9lbaxai6chZyKVByKwbCepvRiI8J7vLPbkcomsRGa)qTcJrL62KezqYEAy)saWfaIUWXmg57ggPvahXt1kYV43RktdueCyKwbb(HIzmY3nmsRW9QY0afbhgPvqGFO2CcCAAGARpi1td7pasCmJr(UHrAfWttcPvJ3RktdueCyKwbb(HIXUDGxPKutduEAy)bqIJzmY3nmsRaEAsiTA8EvzAGIGdJ0kiWpuRWyuPUnjrgKSNg2FaK4ygJ8DdJ0kGNMesRgVxvMgOi4WiTcc8dLyJMBdW2yoDYEAy)bqIJzmY3nmsRaEAsiTA8EVxpo6WzmUi2kMCVQmnqrWdmgxeBft(d8euBIqdsM4PH9pmShNBJyPFfnY70MSixlkRKGPvJ7Go1rElgzjqacdtLPTI3CXtJjIqmrzLemTACh0PoYBXiIc(bddpWtqTjcnizcEai6AjqacdZkjyA14oOtDK3cIicXX)qqFPFwDPF8P(1LCVQmnqrWdmgxeBft(jGh3gwriJrEAy)dtLPTI3CXtJjIqmrzLemTACh0PoYBXiIc(bddpWtqTjcnizcEai6AjqacdZkjyA14oOtDK3cIicXX)(l9ZQl9Jp1VUK7vLPbkcEGX4IyRyIa)qNCQtasOFaXi3Rktdue8aJXfXwXeb(HIzmY3nmsRW9EVEC0ba0uDh1hGutdu3Rktdue8cGMQ73kmgvQBtsKbj7PH9J94CBel9ROrEN2Kf567vLPbkcEbqt1jWpuIqdz5ggmH90W(jGh3gdPJtUsIi()(EvzAGIGxa0uDc8dLaECBPJ1vSNg2pelvhxjorOHSCddMW4CPWooCVQmnqrWlaAQob(HsapUT0X6k2td7pvhxjorOHSCddMW4CPWooikc4XTXq64KRK8l(9QY0afbVaOP6e4hQnNaNMgO26ds90W(fQwjYFFs87vLPbkcEbqt1jWpum2b70a7PH9luTsK)dH43Rktdue8cGMQtGFOyivMpi2td7NaECBmKoo5kjI8xS7vLPbkcEbqt1jWpum2Td8kLKAAG6EvzAGIGxa0uDc8dLyJMBdW2yoDY3Rktdue8cGMQtGFOe)SIUxvMgOi4fanvNa)qt)iGO3Jo1wXDCfJigO6bFi(AisCF6dFc)J1IVUJIwrLvJKoU0muFmWNhSCUSJEuV(5JAtHauEuma6OFrGX0hx(fhfXlTpgIdhLaM8r1Nem1Kdhv6xRrMGFVl9wXhD9Yo6sxrEekeGsoCuvMgOo6xOpjyRzQsi)c879E95Pqak5Wrf0rvzAG6OoJKe87TJoJKK2BhHrAfAV9G1T3oYLc74qVOJsKLmY0okbaxai6chZyKVByKwbCepvRihvKh9JoQY0avhj2O52aSnMtNCN9GpAVDKlf2XHErhLilzKPDucaUaq0foMXiF3WiTc4iEQwro6)rfVJQmnq1rRWyuPUnjrgKCN9aXAVDuLPbQoIzmY3nmsRqh5sHDCOx0zp472Bh5sHDCOx0rjYsgzAhdGehZyKVByKwb80KqA1yhvzAGQJ2CcCAAGARpiTZEGGAVDKlf2XHErhLilzKPDmasCmJr(UHrAfWttcPvJDuLPbQoIXUDGxPKutduD2dG4T3oYLc74qVOJsKLmY0ogajoMXiF3WiTc4PjH0QXoQY0avhTcJrL62KezqYD2dgI2Bh5sHDCOx0rjYsgzAhdGehZyKVByKwb80KqA1yhvzAGQJeB0CBa2gZPtUZo7yGX0hx2E7bRBVDuLPbQoQpjyRzQsi7ixkSJd9Io7bF0E7OktduDmye0JWSJCPWoo0l6Shiw7TJQmnq1rjOiptEp1rt2rUuyhh6fD2d(U92rUuyhh6fDuISKrM2ri2rrQf28kUsCnei48xnssokeGWrvzAR4nx80yYrfXrx3rvMgO64dH3wYtsN9ab1E7ixkSJd9IoQY0avhLQZTvzAGA7ms2rjYsgzAht1XvIl9Rieh2yoM4hNlf2XHo6msUlDYDegPvOZEaeV92rUuyhh6fDuLPbQokvNBRY0a12zKSJoJK7sNChdmgxeBft6ShmeT3oYLc74qVOJQmnq1rP6CBvMgO2oJKD0zKCx6K7ybqt11zNDuiILGjSMT3EW62Bh5sHDCOx0zp4J2Bh5sHDCOx0zpqS2Bh5sHDCOx0zp472Bh5sHDCOx0zpqqT3oQY0avhfcsduDKlf2XHErND2XaJXfXwXK2BpyD7TJCPWoo0l6OezjJmTJd7Oypo3gXs)kAK3Pn5JkYJU(OI6OwjbtRg3bDQJ8wmYrxYrHaeo6WoQktBfV5INgtoQioQyhvuh1kjyA14oOtDK3IroQOok8dggEGNGAteAqYe8aq01rxYrHaeo6WoQvsW0QXDqN6iVfe5OI4OIJ)HGo6xEu)S6s)4t9RhDjDuLPbQog4jO2eHgKmPZEWhT3oYLc74qVOJsKLmY0ooSJQY0wXBU4PXKJkIJk2rf1rTscMwnUd6uh5TyKJkQJc)GHHh4jO2eHgKmbpaeDD0LCuiaHJoSJALemTACh0PoYBbroQioQ44FF0V8O(z1L(XN6xp6s6OktduDKaECByfHmg1zpqS2BhvzAGQJto1jaj0pGyKoYLc74qVOZEW3T3oQY0avhXmg57ggPvOJCPWoo0l6SZowa0uDT3EW62Bh5sHDCOx0rjYsgzAhXECUnIL(v0iVtBYhvKhDDhvzAGQJwHXOsDBsImi5o7bF0E7ixkSJd9IokrwYit7ib842yiDCYvsoQi(p63DuLPbQoseAil3WGjCN9aXAVDKlf2XHErhLilzKPDeID0uDCL4eHgYYnmycJZLc74qhvzAGQJeWJBlDSUI7Sh8D7TJCPWoo0l6OezjJmTJP64kXjcnKLByWegNlf2XHJkQJsapUngshNCLKJ(FuX7OktduDKaECBPJ1vCN9ab1E7ixkSJd9IokrwYit7Oq1QJkY)J6tI3rvMgO6OnNaNMgO26ds7ShaXBVDKlf2XHErhLilzKPDuOA1rf5)rhcX7OktduDeJDWonWD2dgI2Bh5sHDCOx0rjYsgzAhjGh3gdPJtUsYrf5)rfRJQmnq1rmKkZhe3zpaIAVDuLPbQoIXUDGxPKutduDKlf2XHErN9aFQ92rvMgO6iXgn3gGTXC6K7ixkSJd9Io7bRfV92rvMgO6iXpROoYLc74qVOZEW61T3oQY0avht)iGO3Jo1wXDKlf2XHErND2zh1N0pa1XOnhYo7SB]] )

    
end
