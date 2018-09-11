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


    spec:RegisterPack( "Vengeance", 20180902.1825, [[dOuouaqifi1JKqTjLk4taLyuqf6uqvYQuGWRuQAwsi3cOyxKYVaYWafhdQ0Yiv6zqv10uQORrQW2Gk4BqvQXjb5CqfzDkGMhuf3tPSpfO6Gqf1cvqpubWeLG6IkqYgvakFeOKmssf5KKkQvQqZubiDtfiANsKHQujlfQkpLstLu1vvaQ2kqP(QcqSxr)fWGr6WelgKhtYKL0LrTzO8zLy0suNw41avZMIBRODl1Vv1WbvhhOKA5qEoIPt11vsBhu67kvQXRuHoVey(kqz)QCIBQpTvX5SKUWGBHGbNGrxnClKU4a(XFA9cGZPfUOaxw402YKtlyZ9clTItlCPaZl1uFAj)ksXPTS7WjdeeOLWlVcPP(jismxnIhFRqcMdIetfiiZdbcctatLHfeC0JfgMaAxigFsujG2f(akmp)gqNwBNraGn3lS0kwJetvAHwdJRZDcL2Q4CwsxyWTqWGtWORgUfs3DcdoLwcCwLL0rHWnTvMOsBXhfS5EHLwXhTW887JQtRTZOBSS7WjdeeOLWlVcPP(jismxnIhFRqcMdIetfiiZdbcctatLHfeC0JfgMaAxigFsujG2f(akmp)gqNwBNraGn3lS0kwJet1nw8rTmCNNqm6O6w0r1fgCl0rbZrXHbcdmhDxdYB8gl(OdqzPxyYaVXIpkyokoxRC9OfoiOv4(r9)Ovgtwn(rfLhFFutqCTBS4JcMJoaFdlJCUE0vcdeoppk3okyYrXE0rDu0GZo5O(F0vcdeopjhfhjRWH)i)OQFg9Yrj)34L2nw8rbZrX5ALRhL8t(OrR(z0lhTktzHpkOJQklOf(Oku4mkKJ6)rlmp)(Ow4b4mr7gl(OG5O4Jjmcw(OYrvLf0cF0h7O6CJXiXCuRJcW5Jk(rfJ5OEmzIwAHJESWWPT4Jc2CVWsR4JwyE(9r1P12z0nw2D4Kbcc0s4LxH0u)eejMRgXJVvibZbrIPceK5HabHjGPYWcco6XcdtaTleJpjQeq7cFafMNFdOtRTZiaWM7fwAfRrIP6gl(OwgUZtigDuDl6O6cdUf6OG5O4WaHbMJURb5nEJfF0bOS0lmzG3yXhfmhfNRvUE0che0kC)O(F0kJjRg)OIYJVpQjiU2nw8rbZrhGVHLroxp6kHbcNNhLBhfm5Oyp6OokAWzNCu)p6kHbcNNKJIJKv4WFKFu1pJE5OK)B8s7gl(OG5O4CTY1Js(jF0Ov)m6LJwLPSWhf0rvLf0cFufkCgfYr9)OfMNFFul8aCMODJfFuWCu8XegblFu5OQYcAHp6JDuDUXyKyoQ1rb48rf)OIXCupMmr7gVXIp6GAhz1QZ1JcXypIpQ6NqIFuiEjAI2rXzLIH7KJ2FdMYcAITAoQO84BYr)2uG2nkkp(MObhXQFcj(gMriGFJIYJVjAWrS6NqIVFdKSUm52fp((gfLhFt0GJy1pHeF)giS)R3yXh12cCs53pksI6rHwXW46rjU4KJcXypIpQ6NqIFuiEjAYrLUEu4igmWF3JE5Ob5O1VzTBuuE8nrdoIv)es89BGiTaNu(DaIlo5gfLhFt0GJy1pHeF)gi4VhFFJ3yXhDqTJSA156rzyzubh1JjFuVmFur5p6Ob5OcSsyeidRDJIYJVjBYQ)aI7Ic8BuuE8nz)gOAqqRW9BuuE8nz)gi13K1jdmLLqDJIYJVj73aTsyGW5j5gfLhFt2VbsjgdGO84Batq8IAzYBqiPRffyBUy421uLfeIRaygMuwJBbYW1BuuE8nz)giLymaIYJVbmbXlQLjVvzmUjbSm5gfLhFt2VbsjgdGO84Batq8IAzYB9JMI5gVXIp6awWOco6qK01JIV3fp((gfLhFt0Gqsx3iXsyaEmamJm5IcSn1)M6V7wdlyubaqiPRAiEkrtWJU3OO84BIges66(nqrJXOwmaehfGZffyBQ)n1F3TgwWOcaGqsx1q8uIMSbZnkkp(MObHKUUFdewWOcaGqsxVrr5X3eniK019BGI58nIhFdiRiPOaBR(UgwWOcaGqsx18qbE0l3OO84BIges66(nqySbOYWkex847IcST67AybJkaacjDvZdf4rVCJIYJVjAqiPR73afngJAXaqCuaoxuGTvFxdlyubaqiPRAEOap6LBuuE8nrdcjDD)gisSegGhdaZitUOaBR(UgwWOcaGqsx18qbE0l34nw8rlmJXnjGLj3OO84BIwLX4MeWYKTkp)gGapaNjffyB4i2QXaGyvzbTWaEmz8G7oeT6NrVauLPSWa4NGxd2GHJrR(z0lavzklmGoidomA6QJbrzwmEzTPSJ41nkkp(MOvzmUjbSmz)gOj7Y8rWl)KGCJIYJVjAvgJBsalt2VbclyubaqiPR34nw8rl9OPyok(Ex847BuuE8nrRF0umBrJXOwmaehfGZffyByRgdaIvLf0cd4XKXdU3OO84BIw)OPy2VbIapqHda9tOIcSnYVAaWqYYKBNm4B78gfLhFt06hnfZ(nqKF1aOmSalxuGTnODXWTRrGhOWbG(jKg3cKHR3OO84BIw)OPy2VbI8RgaLHfy5IcSnxmC7Ae4bkCaOFcPXTaz46oq(vdagswMC7KnyUrr5X3eT(rtXSFdumNVr84BazfjffyBWLOXZgobZnkkp(MO1pAkM9BGWydKrQCrb2gCjA8SH3WCJIYJVjA9JMIz)gimKO8vexuGTr(vdagswMC7e8SH)BuuE8nrRF0um73aHXgGkdRqCXJVVrr5X3eT(rtXSFdejwcdWJbGzKjFJIYJVjA9JMIz)giszwq3OO84BIw)OPy2VbYlJ(DdSyKawoTWYis8DwsxyWTqWuiCHrtxC3Pos7Ufuh9cjTdi4m(kPZLaRg4rpQ(Y8rJj8h5hf7rhfSuzmz14GLJIyW61aX1Js(jFuz1)P4C9OQYsVWeTBCanA(O4oWJoG3Kv4WFKZ1Jkkp((OGfz1FaXDrboyr7gVrDEc)roxpQooQO847JAcIt0UX0AcIts9PfcjDn1NLWn1NwUfidxZHPvHcNrHKw1)M6V7wdlyubaqiPRAiEkrtokEoQUPvuE8DAjXsyaEmamJm50Zs6M6tl3cKHR5W0QqHZOqsR6Ft93DRHfmQaaiK0vnepLOjhD7OWKwr5X3PnAmg1IbG4OaCo9Se(t9PvuE8DAXcgvaaes6AA5wGmCnhMEwANP(0YTaz4AomTku4mkK0wFxdlyubaqiPRAEOap6L0kkp(oTXC(gXJVbKvKKEwshP(0YTaz4AomTku4mkK0wFxdlyubaqiPRAEOap6L0kkp(oTySbOYWkex8470Zs4qQpTClqgUMdtRcfoJcjT131Wcgvaaes6QMhkWJEjTIYJVtB0ymQfdaXrb4C6zj8o1NwUfidxZHPvHcNrHK267AybJkaacjDvZdf4rVKwr5X3PLelHb4XaWmYKtp90wzmz14P(SeUP(0kkp(oTYQ)aI7Ic80YTaz4Aom9SKUP(0kkp(oT1GGwH7PLBbYW1Cy6zj8N6tRO8470Q(MSozGPSeQ0YTaz4Aom9S0ot9PvuE8DAxjmq48KKwUfidxZHPNL0rQpTClqgUMdtRcfoJcjTUy421uLfeIRaygMuwJBbYW10kkp(oTkXyaeLhFdycINwtqCGwMCAHqsxtplHdP(0YTaz4AomTIYJVtRsmgar5X3aMG4P1eehOLjN2kJXnjGLjPNLW7uFA5wGmCnhMwr5X3PvjgdGO84Batq80AcId0YKtB)OPysp90chXQFcjEQplHBQpTClqgUMdtplPBQpTClqgUMdtplH)uFA5wGmCnhMEwANP(0YTaz4Aom9SKos9PvuE8DAH)E8DA5wGmCnhME6PTYyCtcyzsQplHBQpTClqgUMdtRcfoJcjT44rXwngaeRklOfgWJjFu8CuCp6oC0Ov)m6fGQmLfga)KJIxhDWgSJIJhnA1pJEbOktzHb0b5Od(rHrtxDC0bXrlZIXlRnLD8O4vAfLhFN2kp)gGapaNjPNL0n1Nwr5X3PDYUmFe8YpjiPLBbYW1Cy6zj8N6tRO8470IfmQaaiK010YTaz4Aom90tB)OPys9zjCt9PLBbYW1CyAvOWzuiPfB1yaqSQSGwyapM8rXZrXnTIYJVtB0ymQfdaXrb4C6zjDt9PLBbYW1CyAvOWzuiPL8RgamKSm52jhDW3o6otRO8470sGhOWbG(ju6zj8N6tl3cKHR5W0QqHZOqs7G(OUy421iWdu4aq)esJBbYW10kkp(oTKF1aOmSalNEwANP(0YTaz4AomTku4mkK06IHBxJapqHda9tinUfidxp6oCuYVAaWqYYKBNC0TJctAfLhFNwYVAaugwGLtplPJuFA5wGmCnhMwfkCgfsAHlrFu8SDuCcM0kkp(oTXC(gXJVbKvKKEwchs9PLBbYW1CyAvOWzuiPfUe9rXZ2rXBysRO8470IXgiJu50Zs4DQpTClqgUMdtRcfoJcjTKF1aGHKLj3o5O4z7O4pTIYJVtlgsu(kItplvOuFAfLhFNwm2auzyfIlE8DA5wGmCnhMEwcNs9PvuE8DAjXsyaEmamJm50YTaz4Aom9SeUWK6tRO8470skZckTClqgUMdtplHlUP(0kkp(oTEz0VBGfJeWYPLBbYW1Cy6PNEALvV8JsRnMdq6PNja]] )

    
end
