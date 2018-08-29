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
    
        package = "Vengeance",
    } )


    spec:RegisterPack( "Vengeance", 20180810.2145, [[dS0NsaqivrPhjvvTjPu0NajAuGK6uGKSkPu4vkkZcf1TKQk7cL(LuyyOihtQYYKI8msfnnsL6AKkSnvrLVjLsgNuv6CQIQwNuk18KQI7jv2NuuoOQi1cLsEOQiXeLsLUOuuvBukQKpkfvyKKkP6KsPIvQkntPOsTtsPFkfv0qjvsAPKkXtPYurHRQksARsrv(kPsI9s5VQ0GPQdJSyv1Jr1Kv4YeBguFwrgnPQtlSAsLuETIQztYTvXUL8BLgoP44QIILd55qnDrxheBxv47sPQXRkIZdsnFqc7hyRNXWCdkftBtm1RVm13EmX2upDRdD2ZCj0AeZPH4ZPjXCfDeZ18KAsOIlMtdbTAPHXWC4fcIlMtFMAWTDJgtrQhYNLVNg44arrzSfhrWzdCC4n(Q934dt9BipAObTWHsWnyecQPEny0uVB7kNTU66qQuq3MNutcvCHfhhU5(qcv2oL9n3GsX02et96lt9ThtSn1t3MdRr4MwD03EMBiyU5yOpWapXZylGxdXNd8bg4)ewga)waVlopfOed8AqlCOeGhQXIa86QOfoucWN0h4HxeWN6fGxf1COIf8cEF6HUgeCEKkXTn4f47hWRlYZajqcW3g49iTbWhfFprnb8d6qtcWNlWZjCc8TRC2c4DAI5cMzGpGbEOxiaVE6Ha8NfjaFQNkGVhWZ1tOjHf8c89d41f5zGeib4jGhMceWtNfsLa)cd8rX3tuta)Go0Ka85c8qWcW3UYzlG3PjMlyOe4XcFRbWZ1tOjHf8c89d4Bolf0apeSa8TtblOIuaVlrXCb4BVEPa(ib(ad8CsJMOMyg4t9cWJKdfvutapxpHMeOgdvapHeGhjyb9qgapLap0leeWpcmhjzSfR50Gw4qjMR)aFZ)jchskdG)lWlsaE(E(uc8FzkkmlW)0CUOjXaFTv)0tOdmefWt8m2cd8BPGMf8s8m2cZQbj898PSdwr45GxINXwywniHVNpLZ6AqqMosLugBbEjEgBHz1Ge(E(uoRRb8UdWB)bExrAW63e4ruma(peyyza84KsmW)f4fjapFpFkb(Vmffg4PAa8Aqs)0Szg1eWhyGFSLWcEjEgBHz1Ge(E(uoRRbUiny9BEXjLyWlXZylmRgKW3ZNYzDn0SzSf4f82FGV5)eHdjLbWlpee0aFghb4t9cWt8CraFGbE6bfk6RewWlXZylChbj3lLjXNdEjEgBHN11GVfgYrUhAk4G3(d8mhWDplIIXvEivYsJbMvEsGtmuafepJhYvk5ecUz9aVepJTWZ6Aabl3iLdZy1MDjkQ5s2d8s8m2cpRRbNuQlXZyRRkWjZfDKUpIQbZbCxskPswUEcHKXfwjy9SsrFLmaVepJTWZ6AWjL6s8m26QcCYCrhPBiWsHJhcg8s8m2cpRRbNuQlXZyRRkWjZfDKUArhsbEbV9h4BUcbbnW3cr1a41LnPm2c8s8m2cZ(run6WXuOUl8fwrhH5aUJVRASTVyHdbb99JOAWIKdffUpnbEjEgBHz)iQgZ6AefSGksDXjkMlmhWD8DvJT9flCiiOVFevdwKCOOWDmbEjEgBHz)iQgZ6Aahcc67hr1a8s8m2cZ(runM11ioNvrzS1LGGiMd4UXMSWHGG((runyZGppQjWlXZylm7hr1ywxdyrDhYdcNugBXCa3n2Kfoee03pIQbBg85rnbEjEgBHz)iQgZ6AefSGksDXjkMlmhWDJnzHdbb99JOAWMbFEutGxINXwy2pIQXSUg4yku3f(cROJWCa3n2Kfoee03pIQbBg85rnbEbV9h4BxbwkC8qWGxINXwy2HalfoEi4UHC26I1eZfmZbChuhfFprnDh0HMKRoXTjxpHMeCZ6bvqbua1rX3tut3bDOj5QdCZyITxBOxivQN9qpbQaVepJTWSdbwkC8qWZ6ACKKolsJ(fhyWlXZylm7qGLchpe8SUgWHGG((runaVG3(d8Ax0HuaVUSjLXwGxINXwy2Arhs1ffSGksDXjkMlmhWDC9eAsWxyeXZyls1Sd9KlxpHMeC)yITjDaEjEgBHzRfDi1SUgynbkY7FpFMd4o8crDHr00rQe3SoDdEjEgBHzRfDi1SUg4fI6Yvc9qyoG7E2KusLSynbkY7FpFwPOVsgGxINXwy2ArhsnRRbEHOUCLqpeMd4UKusLSynbkY7FpFwPOVsgTjEHOUWiA6ivI7yc8s8m2cZwl6qQzDnIZzvugBDjiiI5aUtdfvF6EEMaVepJTWS1IoKAwxdyr9v0qyoG70qr1NU2IjWlXZylmBTOdPM11agr8ecsyoG7Wle1fgrthPsCF60j4L4zSfMTw0HuZ6AalQ7qEq4KYylWlXZylmBTOdPM11aVquxUsOhc4L4zSfMTw0HuZ6AGJPqDx4lSIoc4L4zSfMTw0HuZ6AG1lec8s8m2cZwl6qQzDns9OT93jffpeZ9qq4yltBtm1RVm13EmX2upDBU2tOkQjS50vEADrB7OT5OTbEGNHEb4JJMfLap8IaEOCiWeevcLapsEgibsgapEpcWtqY9qPmaEUEQMeml4T5okb4712a)tTWq0OzrPmaEINXwapusqY9szs85qjl4f82ohnlkLbWRdGN4zSfWRcCIzbVMJGK6xK5CX5PyovGtSXWCFevdJHPTNXWCsrFLmSwMJJIuqbzo(UQX2(Ifoee03pIQblsouuyGVpaFtMJ4zSL5WXuOUl8fwrhXstBtgdZjf9vYWAzooksbfK547QgB7lw4qqqF)iQgSi5qrHb(oGNjZr8m2YCrblOIuxCII5ILMwDAmmhXZylZbhcc67hr1WCsrFLmSwwAA1TXWCsrFLmSwMJJIuqbzUXMSWHGG((runyZGppQjZr8m2YCX5SkkJTUeeezPPvhgdZjf9vYWAzooksbfK5gBYchcc67hr1Gnd(8OMmhXZylZblQ7qEq4KYyllnTpNXWCsrFLmSwMJJIuqbzUXMSWHGG((runyZGppQjZr8m2YCrblOIuxCII5ILM22YyyoPOVsgwlZXrrkOGm3ytw4qqqF)iQgSzWNh1K5iEgBzoCmfQ7cFHv0rS0sZneycIkngM2EgdZr8m2YCeKCVuMeFU5KI(kzyTS002KXWCepJTmhFlmKJCp0uWnNu0xjdRLLMwDAmmNu0xjdRL5iEgBzoiy5gPCmhwTP5suuZLSNLMwDBmmNu0xjdRL54OifuqMljLujlxpHqY4cReSEwPOVsgMJ4zSL54KsDjEgBDvbonNkW5TOJyUpIQHLMwDymmNu0xjdRL5iEgBzooPuxINXwxvGtZPcCEl6iMBiWsHJhc2st7ZzmmNu0xjdRL5iEgBzooPuxINXwxvGtZPcCEl6iMRw0HuwAP50Ge(E(uAmmT9mgMtk6RKH1YstBtgdZjf9vYWAzPPvNgdZjf9vYWAzPPv3gdZjf9vYWAzPPvhgdZr8m2YCA2m2YCsrFLmSwwAP5gcSu44HGngM2EgdZjf9vYWAzooksbfK5GAGpk(EIA6oOdnjxDIb(2e456j0KGb(Mb89aEOc4HcOa4HAGpk(EIA6oOdnjxDGb(Mb8mX2d4BdGxVqQup7HEcWdvMJ4zSL5gYzRlwtmxWwAABYyyoINXwM7ijDwKg9loWMtk6RKH1YstRongMJ4zSL5Gdbb99JOAyoPOVsgwllT0C1IoKYyyA7zmmNu0xjdRL54OifuqMJRNqtc(cJiEgBrkGVza)HEYLRNqtcg47hWZeBt6WCepJTmxuWcQi1fNOyUyPPTjJH5KI(kzyTmhhfPGcYC4fI6cJOPJujg4BwhWRBZr8m2YCynbkY7FpFlnT60yyoPOVsgwlZXrrkOGm3Zc8jPKkzXAcuK3)E(SsrFLmmhXZylZHxiQlxj0dXstRUngMtk6RKH1YCCuKckiZLKsQKfRjqrE)75Zkf9vYa4BtGhVquxyenDKkXaFhWZK5iEgBzo8crD5kHEiwAA1HXWCsrFLmSwMJJIuqbzonuuaFF6a(NNjZr8m2YCX5SkkJTUeeezPP95mgMtk6RKH1YCCuKckiZPHIc47thW3wmzoINXwMdwuFfnelnTTLXWCsrFLmSwMJJIuqbzo8crDHr00rQed89Pd41P5iEgBzoyeXtiiXstBFngMJ4zSL5Gf1DipiCszSL5KI(kzyTS00(8gdZr8m2YC4fI6Yvc9qmNu0xjdRLLM2EmzmmhXZylZHJPqDx4lSIoI5KI(kzyTS002RNXWCepJTmhwVqiZjf9vYWAzPPTxtgdZr8m2YCPE02(7KIIhI5KI(kzyTS0slT0sZa]] )

    
end
