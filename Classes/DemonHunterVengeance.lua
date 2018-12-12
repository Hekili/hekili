-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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
            value = PTR and 8 or 7
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

        cleansed_by_flame = 814, -- 205625
        demonic_trample = 3423, -- 205629
        detainment = 3430, -- 205596
        everlasting_hunt = 815, -- 205626
        illidans_grasp = 819, -- 205630
        jagged_spikes = 816, -- 205627
        reverse_magic = 3429, -- 205604
        sigil_mastery = 1948, -- 211489
        solitude = 802, -- 211509
        tormentor = 1220, -- 207029
        unending_hatred = 3727, -- 213480
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
            duration = function () return azerite.revel_in_pain.enabled and 10 or 8 end,
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


        -- PvP Talents
        demonic_trample = {
            id = 205629,
            duration = 3,
            max_stack = 1,
        },

        everlasting_hunt = {
            id = 208769,
            duration = 3,
            max_stack = 1,
        },

        focused_assault = {
            id = 206891,
            duration = 6,
            max_stack = 5,
        },

        illidans_grasp = {
            id = 205630,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        revel_in_pain = {
            id = 272987,
            duration = 15,
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

        if buff.demonic_trample.up then
            setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.demonic_trample.remains ) )
        end

        if buff.illidans_grasp.up then
            setCooldown( "illidans_grasp", 0 )
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
                gain( buff.solitude.up and 22 or 20, "pain" )
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
        

        demonic_trample = {
            id = 205629,
            cast = 0,
            charges = 2,
            cooldown = 12,
            recharge = 12,
            gcd = "spell",

            pvptalent = "demonic_trample",
            nobuff = "demonic_trample",
            
            startsCombat = false,
            texture = 134294,
            
            handler = function ()
                spendCharges( "infernal_strike", 1 )
                setCooldown( "global_cooldown", 3 )
                applyBuff( "demonic_trample" )
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
                gain( buff.solitude.up and 33 or 30, "pain" )
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

            spend = function () return buff.solitude.enabled and -33 or -30 end,
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
                gain( buff.solitude.up and 27 or 25, "pain" )
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
        

        illidans_grasp = {
            id = function () return debuff.illidans_grasp.up and 208173 or 205630 end,
            known = 205630,
            cast = 0,
            cooldown = function () return buff.illidans_grasp.up and ( 54 + buff.illidans_grasp.remains ) or 0 end,
            gcd = "off",
            
            pvptalent = "illidans_grasp",
            aura = "illidans_grasp",
            breakable = true,
            channeled = true,

            startsCombat = true,
            texture = function () return buff.illidans_grasp.up and 252175 or 1380367 end,
            
            handler = function ()
                if buff.illidans_grasp.up then removeBuff( "illidans_grasp" )
                else applyBuff( "illidans_grasp" ) end
            end,

            copy = { 205630, 208173 }
        },
        

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

                if pvptalent.cleansed_by_flame.enabled then
                    removeDebuff( "player", "reversible_magic" )
                end
            end,
        },
        

        imprison = {
            id = 217832,
            cast = 0,
            cooldown = function () return pvptalent.detainment.enabled and 60 or 45 end,
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
                spendCharges( "demonic_trample", 1 )
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
                gain( PTR and 8 or 7, "pain" )

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
        

        reverse_magic = {
            id = 205604,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            -- toggle = "cooldowns",
            pvptalent = "reverse_magic",

            startsCombat = false,
            texture = 1380372,
            
            handler = function ()
                if debuff.reversible_magic.up then removeDebuff( "player", "reversible_magic" ) end
            end,
        },


        shear = {
            id = 203782,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.solitude.up and -11 or -10 end,
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
            cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 90 end,
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
            cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 30 end,
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
            cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 90 end,
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
            cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 60 end,
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

            nopvptalent = "tormentor",
            
            handler = function ()
                applyDebuff( "target", "torment" )
            end,
        },


        tormentor = {
            id = 207029,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344654,

            pvptalent = "tormentor",
            
            handler = function ()
                applyDebuff( "target", "focused_assault" )
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


    spec:RegisterPack( "Vengeance", 20181211.1749, [[dOKpwaqivvIEeHQnri8jvvQgLGQoLcIvPQs5vGsZsG6wQQyxq1Vavdtb1XuiltjPNjOmnqrxJGY2euPVrqyCeeDoqHwNsIENQkjZJq09uv2NcsheuWcvOEiHunrcjxuvLuBuvLGpQKq1ifuXjvsWkvLMPQkH2PcmucsTucfpvOPkGRQKqzRes5RkjK2Ru)vPgmshM0Ib5XenzQ6YO2mu(SsmAb50uETQQMnvUTI2TOFdmCcCCLeILd55iMUKRRk2UsQVtO04ji58cK5tq1(v5EuhOJET4EWQdpsihT6Or4JecycJHbJDScsa3rbQ8VUWDm1j3rrJZfwtj3rbAqoG67aDKaEqsUJHQsazLWHVyvOhiCjycNyZhNwgiLifRGtSPeoKdabhct)XZRHlabWmhtGl0iwmQ5jWfAXSffpb5oCEYIrBrJZfwtjJtSPSJqpMRwHSH6OxlUhS6WJeYrRoAe(iHaMW4QWyhjcyzpqyc5OogY8EoBOo6zISJIFurJZfwtjFurXtqE0W5jlgDVHQsazLWHVyvOhiCjycNyZhNwgiLifRGtSPeoKdabhct)XZRHlabWmhtGl0iwmQ5jWfAXSffpb5oCEYIrBrJZfwtjJtSP8Ef)OIIL8eIrhD0OGp6Qdpsip6phDu4Usyg29EVIFurpKMlmzL3R4h9NJcdEp7pQOmc6rqD0cCupJPpU6OQSmqEuNrk87v8J(ZrfDqUMrf7p6dH3wXZJYzHmMCuma6OfYY)CroAbo6dH3wXtYV6OiEcwZ(JkbP3kdKe87v8J(ZrHbVN9hLaM8rTucMwUCuVo1f(OWpQmKIw4JkrwXitpAboQO4jipAuG9Nj43R4h9NJkgMWO18r1JkdPOf(OaSJUcjgJs1D0yHS)8r16OQZD0YMmb)Ef)O)CuyW7z)rJGh3rhRiKXi8okabWmh3rXpQOX5cRPKpQO4jipA48KfJU3qvjGSs4WxSk0deUemHtS5JtldKsKIvWj2uchYbGGdHP)451WfGayMJjWfAelg18e4cTy2IINGChopzXOTOX5cRPKXj2uEVIFurXsEcXOJoAuWhD1HhjKh9NJokCxjmd7EVxXpQOhsZfMSY7v8J(ZrHbVN9hvugb9iOoAboQNX0hxDuvwgipQZif(9k(r)5OIoixZOI9h9HWBR45r5SqgtokgaD0cz5FUihTah9HWBR4j5xDuepbRz)rLG0BLbsc(9k(r)5OWG3Z(Jsat(OwkbtlxoQxN6cFu4hvgsrl8rLiRyKPhTahvu8eKhnkW(Ze87v8J(Zrfdty0A(O6rLHu0cFua2rxHeJrP6oASq2F(OADu15oAztMGFVIF0Fokm49S)OrWJ7OJveYye(9EVIF0FTqXYNI9hfIXai(OsWesRJcXlwsWpkmiLSGIC0eK)esrtSh3rvzzGKCuq6cc)EvzzGKGlaXsWesRpmNs(FVQSmqsWfGyjycPfSFW1NLjNLwgiVxvwgij4cqSemH0c2p4yaG)Ef)OXufqcbQJIuZFuOhmm2FusPf5OqmgaXhvcMqADuiEXsYr10Fubi(hbGQSC5Og5OEqY43RkldKeCbiwcMqAb7hCsQciHa1MuArUxvwgij4cqSemH0c2p4caLbY79Ef)O)AHILpf7pkVMrbD0YM8rRq8rvzbqh1ihvxRMtHCm(9QYYaj5tFkWwRsL)VxvwgijW(b3Be0JG6EvzzGKa7hCjijptEp1ftEVQSmqsG9d(dH3wXtY9QYYajb2p4s152QSmqUDgPco1j)bH00hSH9vQJZcxgsri2VXCmjeoNkKJ93RkldKey)GlvNBRYYa52zKk4uN8NNX4KyRzY9QYYajb2p4s152QSmqUDgPco1j)La0uD379k(r)fmgf0rhJ00FuXakTmqEVQSmqsWHqA6)i2I52aSnMtNCWg2NeaCEGytCmJrbTHqA6Xr8uTKiYvVxvwgij4qin9W(b3smgLQBtkK9Nd2W(KaGZdeBIJzmkOnestpoINQLKVHVxvwgij4qin9W(bhZyuqBiKM(7vLLbscoestpSFWT5e40Ya5wFqAWg2Nhu4ygJcAdH00JxM8VLl3RkldKeCiKMEy)GJXUTNxRKsldKbByFEqHJzmkOnestpEzY)wUCVQSmqsWHqA6H9dULymkv3Mui7phSH95bfoMXOG2qin94Lj)B5Y9QYYajbhcPPh2p4eBXCBa2gZPtoyd7ZdkCmJrbTHqA6Xlt(3YL79Ef)OIIX4KyRzY9QYYajb3ZyCsS1m5ZZtqUjcS)mjyd7l8ypo3gXYqkAH3Lnzrosewkbtlx2EDQl8omYqeUWdVklBnV5KNgtgAyIWsjyA5Y2RtDH3Hreb0dggUNNGCtey)zcUhi2Cicx4H3sjyA5Y2RtDH3cJm0HXxvy)wiwDvi8Pkud5EvzzGKG7zmoj2AM8rapUnKIqgJc2W(cVklBnV5KNgtgAyIWsjyA5Y2RtDH3Hreb0dggUNNGCtey)zcUhi2Cicx4H3sjyA5Y2RtDH3cJm0HXH5VfIvxfcFQc1qUxvwgij4EgJtITMjW(bFYLobibHaeJCVQSmqsW9mgNeBntG9doMXOG2qin9379k(rhaqt1DuXakTmqEVQSmqsWtaAQUplXyuQUnPq2Foyd7d7X52iwgsrl8USjlYr3RkldKe8eGMQd2p4ebgYQneycfSH9rapUngsxMCwKH(bZ7vLLbscEcqt1b7hCc4XTLowxZbByF)YsDCw4ebgYQneycHZPc5y)9QYYajbpbOP6G9dob842shRR5GnSVsDCw4ebgYQneycHZPc5yViiGh3gdPltolY3W3RkldKe8eGMQd2p42CcCAzGCRpinyd7tGAPi)GXHVxvwgij4janvhSFWXyhKt9CWg2Na1sr(jedFVQSmqsWtaAQoy)GJHuz9G4GnSpc4XTXq6YKZIiYVWUxvwgij4janvhSFWXy32ZRvsPLbY7vLLbscEcqt1b7hCITyUnaBJ50jFVQSmqsWtaAQoy)GtcXk6EvzzGKGNa0uDW(bVcHaIDV4uBn3X1mIyGShS6WJeYrdpcM4Jgfgm7OyvuA5cPJROWGygScdwXx5rpAGq8rTPaaQokgaD0F3Zy6JR(9JI4vKhdX(Jsat(O6tbMAX(JkdP5ctWV3Frl5JoALhDfljpceaqf7pQkldKh931NcS1Qu5)Fh)EV3vykaGk2FuHDuvwgipQZifb)E7OZifPd0riKM(oqpyuhOJCQqo23J7OezfJmTJsaW5bInXXmgf0gcPPhhXt1sYrf5rxTJQSmq2rITyUnaBJ50j3vpy1oqh5uHCSVh3rjYkgzAhLaGZdeBIJzmkOnestpoINQLKJ(D0H7OkldKD0smgLQBtkK9N7QhewhOJQSmq2rmJrbTHqA67iNkKJ994U6bWSd0rovih77XDuISIrM2rpOWXmgf0gcPPhVm5Flx6OkldKD0MtGtldKB9bPD1dewhOJCQqo23J7OezfJmTJEqHJzmkOnestpEzY)wU0rvwgi7ig72EETskTmq2vpiC7aDKtfYX(EChLiRyKPD0dkCmJrbTHqA6Xlt(3YLoQYYazhTeJrP62Kcz)5U6bcrhOJCQqo23J7OezfJmTJEqHJzmkOnestpEzY)wU0rvwgi7iXwm3gGTXC6K7QRo6zm9XvDGEWOoqhvzzGSJ6tb2AvQ8Fh5uHCSVh3vpy1oqhvzzGSJEJGEeuDKtfYX(ECx9GW6aDuLLbYokbj5zY7PUyYoYPc5yFpUREam7aDuLLbYo(q4Tv8K0rovih77XD1dewhOJCQqo23J7OezfJmTJL64SWLHueI9BmhtcHZPc5yFhvzzGSJs152QSmqUDgP6OZi1o1j3riKM(U6bHBhOJCQqo23J7OkldKDuQo3wLLbYTZivhDgP2Po5o6zmoj2AM0vpqi6aDKtfYX(EChvzzGSJs152QSmqUDgP6OZi1o1j3XeGMQRRU6OaelbtiT6a9GrDGoYPc5yFpUREWQDGoYPc5yFpUREqyDGoYPc5yFpUREam7aDKtfYX(ECx9aH1b6OkldKDuaOmq2rovih77XD1vh9mgNeBnt6a9GrDGoYPc5yFpUJsKvmY0og(JI94CBeldPOfEx2KpQip6OJkIJAPemTCz71PUW7WihDihv4c)OH)OQSS18MtEAm5Od9OHDurCulLGPLlBVo1fEhg5OI4Oqpyy4EEcYnrG9Nj4EGyZJoKJkCHF0WFulLGPLlBVo1fElmYrh6rhgFvHD0F7OHy1vHWNQqD0H0rvwgi7ONNGCtey)zsx9Gv7aDKtfYX(EChLiRyKPDm8hvLLTM3CYtJjhDOhnSJkIJAPemTCz71PUW7Wihvehf6bdd3ZtqUjcS)mb3deBE0HCuHl8Jg(JAPemTCz71PUWBHro6qp6W4W8O)2rdXQRcHpvH6OdPJQSmq2rc4XTHueYyux9GW6aDuLLbYoo5sNaKGqaIr6iNkKJ994U6bWSd0rvwgi7iMXOG2qin9DKtfYX(ECxD1XeGMQRd0dg1b6iNkKJ994okrwXit7i2JZTrSmKIw4Dzt(OI8OJ6OkldKD0smgLQBtkK9N7QhSAhOJCQqo23J7OezfJmTJeWJBJH0LjNf5Od97OWSJQSmq2rIadz1gcmH6QhewhOJCQqo23J7OezfJmTJ)YJwQJZcNiWqwTHatiCovih77OkldKDKaECBPJ11Cx9ay2b6iNkKJ994okrwXit7yPoolCIadz1gcmHW5uHCS)OI4OeWJBJH0LjNf5OFhD4oQYYazhjGh3w6yDn3vpqyDGoYPc5yFpUJsKvmY0okqT8OI87OW4WDuLLbYoAZjWPLbYT(G0U6bHBhOJCQqo23J7OezfJmTJculpQi)oQqmChvzzGSJySdYPEUREGq0b6iNkKJ994okrwXit7ib842yiDzYzroQi)oAyDuLLbYoIHuz9G4U6bczhOJQSmq2rm2T98ALuAzGSJCQqo23J7QhaJDGoQYYazhj2I52aSnMtNCh5uHCSVh3vpy0WDGoQYYazhjHyf1rovih77XD1dgnQd0rvwgi7yfcbe7EXP2AUJCQqo23J7QRU6O(uHaOogTPO3vxDd]] )

    
end
