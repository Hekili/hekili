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
            value = 8,
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


    local sigils = setmetatable( {}, {
        __index = function( t, k )
            t[k] = 0
            return t[k]
        end
    } )

    spec:RegisterStateFunction( "create_sigil", function( sigil )
        sigils[ sigil ] = query_time + ( talent.quickened_sigils.enabled and 1 or 2 )
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

    
    local sigil_types = { "chains", "flame", "misery", "silence" }

    spec:RegisterHook( "reset_precast", function ()
        last_metamorphosis = nil
        last_infernal_strike = nil
        
        for i, sigil in ipairs( sigil_types ) do
            local activation = ( action[ "sigil_of_" .. sigil ].lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
            if activation > now then sigils[ sigil ] = activation
            else sigils[ sigil ] = 0 end            
        end

        if talent.flame_crash.enabled then
            -- Infernal Strike is also a trigger for Sigil of Flame.
            local activation = ( action.infernal_strike.lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
            if activation > now and activation > sigils[ sigil ] then sigils.flame = activation end
        end

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

    spec:RegisterHook( "advance_end", function( time )
        if query_time - time < sigils.flame and query_time >= sigils.flame then
            -- SoF should've applied.
            applyDebuff( "target", "sigil_of_flame", debuff.sigil_of_flame.duration - ( query_time - sigils.flame ) )
            active_dot.sigil_of_flame = active_enemies
            sigils.flame = 0
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

            usable = function () return buff.dispellable_magic.up end,
            handler = function ()
                removeBuff( "dispellable_magic" )
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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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

            spend = function () return ( buff.solitude.up and -27 or -25 ) + ( buff.metamorphosis.up and -20 or 0 ) end,
            spendType = "pain",            

            startsCombat = true,
            texture = 1388065,

            handler = function ()
                -- gain( buff.solitude.up and 27 or 25, "pain" )
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1247263,

            handler = function ()
                applyBuff( "metamorphosis" )
                gain( 8, "pain" )

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

            spend = function () return ( buff.solitude.up and -11 or -10 ) + ( buff.metamorphosis.up and -20 or 0 ) end,
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

            readyTime = function ()
                return sigils.flame - query_time
            end,
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

        potion = "superior_steelskin_potion",

        package = "Vengeance",
    } )


    spec:RegisterPack( "Vengeance", 20190920, [[dq0EBaqifeEesvBcPOrPG0PuiSkqQ4vGKzrbULck7cu)sbggsPJrr1Yur6zQiMMkv6Auq2Mkv03uPcJdKkDofuToqk8oqkY8uPQ7PQSpfIoifuwOkLhQGOjcsPlsbvSrkOsJeKI6KGuLvQQANQOwkiv1tfmvfQTsbvTxP(RqdMOdtAXi5XqnzkDzuBwv(Skz0uKtt1RbrZMWTv0Uf9BLgofA5qEoIPl56QW2bHVJuz8ifCEkkRhPqZxH0(bUnVh3bRwCF(uAnF40o8tPfM2HBiZV7PDOmZi3bJkgs9I7qQtUdgEoVynXChmQMjw12J7azpqyUdMQYibAmyWLxMoOGX7CaXNhcT8nXi9vdi(epOduhUOGEzt1bRwCF(uAnF40o8tPfM2HBiZn)KoqmY4(SHGUM3btU1Yzt1bltWDGEG0WZ5fRjMbsOLNBcKqZhzXiWp9aPPQmsGgdgC5LPdky8ohq85HqlFtmsF1aIpXda)0dKb2yXtkgbKNsRba5P0A(Wb)GF6bYH0KMxmbAa(PhihgqAywlBbsO1jOdJfqwlqA5NEikGuXLVjqkCsbd(PhihgqoKBcbJk2cKheo6fpbsolKZeG8TiGSqEcjxeGSwG8GWrV4jbAcir8CHGTajEtRx(MeyWp9a5WasdZAzlqs2jdKEI3PNxaPvN6fdKdasSjfDXajg5fJCfiRfiHwEUjqgm6qYeyWp9a5WasOptyeemqQaj2KIUyGCFaj0lFmkvbqgkKdjdKAbKQqaKLpzcm4NEGCyaPHzTSfid7HaiVPiKZi4oyeTpxWDGEG0WZ5fRjMbsOLNBcKqZhzXiWp9aPPQmsGgdgC5LPdky8ohq85HqlFtmsF1aIpXda)0dKb2yXtkgbKNsRba5P0A(Wb)GF6bYH0KMxmbAa(PhihgqAywlBbsO1jOdJfqwlqA5NEikGuXLVjqkCsbd(PhihgqoKBcbJk2cKheo6fpbsolKZeG8TiGSqEcjxeGSwG8GWrV4jbAcir8CHGTajEtRx(MeyWp9a5WasdZAzlqs2jdKEI3PNxaPvN6fdKdasSjfDXajg5fJCfiRfiHwEUjqgm6qYeyWp9a5WasOptyeemqQaj2KIUyGCFaj0lFmkvbqgkKdjdKAbKQqaKLpzcm4NEGCyaPHzTSfid7HaiVPiKZiyWp4NEG0WHgy8rXwGKIFlIbs8oP0ciP4lpjWaPHHXSXIaK5MdZKIMVdbqQ4Y3KaKBkmdg8tpqQ4Y3KaBeX4DsP13tOeib)0dKkU8njWgrmENuAb13a94AYzPLVj4NEGuXLVjb2iIX7KslO(g821c(PhidPAKyAlGePUfiPoEp2cKKslcqsXVfXajENuAbKu8LNeGutlqAeXdZ4wLNxaPtas7Mmm4NEGuXLVjb2iIX7KslO(gqs1iX0wrsPfb8R4Y3KaBeX4DsPfuFdoiC0lEAqQt(tPrIjfPK4BZkUVOXLogb(vC5BsGnIy8oP0cQVbg3Y3e8d(PhinCObgFuSfiziyKzaz5tgiltmqQ4AraPtasfc1fkLGHb)kU8njFwNGomwGFfx(MeO(gG3KCm54uVCm4xXLVjbQVbheo6fpjGFfx(MeO(gGvHiQ4Y3mkCszqQt(JcPP1a)9vQGZcgBsri2gFcMycMtLsWwWVIlFtcuFdWQqevC5BgfoPmi1j)z5hNehcMyG)(8eVtpVIwDQxC0qKrsl4xXLVjbQVbyviIkU8nJcNugK6K)W7kSlDjb8R4Y3Ka13aSkerfx(MrHtkdsDYF5IMQa8d(PhinCDgzgqEdPPfiH(BPLVj4xXLVjbMcPP9J4xUiUV4tOt2a)9H3vyx6s4NZiZIuinTWiEQEsU)uWVIlFtcmfstluFd88XOufrsHCizd83hExHDPlHFoJmlsH00cJ4P6j5JwWVIlFtcmfstluFdEoJmlsH00c(vC5BsGPqAAH6BGpNRqlFZOEGud83NDl4NZiZIuinTWLJH0ZlWVIlFtcmfstluFdESiAziusPLVPb(7ZUf8ZzKzrkKMw4YXq65f4xXLVjbMcPPfQVbE(yuQIiPqoKSb(7ZUf8ZzKzrkKMw4YXq65f4xXLVjbMcPPfQVbe)YfX9fFcDYg4Vp7wWpNrMfPqAAHlhdPNxGFWp9a5qURWU0LeWVIlFtcmExHDPljFg3Y3e8R4Y3KaJ3vyx6scuFdWBI5SqAX24tOt2a)9n0HWUfmEtmNfsl2gFcDYrQducxogspVO5qO4Y3egVjMZcPfBJpHozypJpHFzQgD03Hqerm2KIU4y5t((lSfEQ0Wia)kU8njW4Df2LUKa13a6wKWcb7zeXKn1eZg4VpQJ3dw4pMsSRfMukgY7pb8R4Y3KaJ3vyx6scuFdM8CrMf3xuCGDB0IyDsa)0dKql)0drbKpviOumKa5Bra5brPemqYecNyMad(vC5BsGX7kSlDjbQVbMyfvrMq4eZGFfx(Mey8Uc7sxsG6BWbHJEXtd43JXvm1j)Hndl2cTPJJucLug4VpQJ3dEYZfzwCFrXb2TrlI1jb2U0LGFfx(Mey8Uc7sxsG6BWbHJEXtdsDYFkXeeAYKisPXffXlsfg4VpltD8EWiLgxueViveTm1X7bBx6Yrh1YuhVhmEt7bUCi4ONqgTm1X7bFyKMLIU4c2eRIYeSrCD)jMp6OLp5yTrRZ3FkTGF6bsOLF6HOaYNkeukgsG8TiG8GOucgi9INeyWVIlFtcmExHDPljq9n4GWrV4jb8d(PhiHw(XjXHGjGFfx(Meyl)4K4qWKplp3msm6qYed833qFhcreXytk6IJLp57nNMEI3PNxrRo1loEczeJo6qvC5qWro5PZKrEcn9eVtpVIwDQxC8ecnPoEpylp3msm6qYey7sxoIrhDOEI3PNxrRo1loAiYiPf(udbDmXQOmbpvAyeGFfx(Meyl)4K4qWKpYEiIukc5mYa)9nufxoeCKtE6mzKNqtpX70ZROvN6fhpHqtQJ3d2YZnJeJoKmb2U0LJy0rhQN4D65v0Qt9IJgImsAHVl0XeRIYe8uPHra(vC5BsGT8JtIdbtG6BWKlDUiJMwIta)kU8njWw(XjXHGjq9n45mYSifstl4h8tpqEErtvaKq)T0Y3e8R4Y3KaNlAQIppFmkvrKuihs2a)99oeIiIXMu0fhlFY3Bo4xXLVjbox0ufq9nGy0rEfP2jLb(7JShI4dPxtolYi)Ul4xXLVjbox0ufq9nGShIiwWkeSb(7BikvWzbtm6iVIu7KcMtLsWwWVIlFtcCUOPkG6BazperSGviyd83xPcolyIrh5vKANuWCQuc2stYEiIpKEn5SiF0c(vC5BsGZfnvbuFd85CfA5Bg1dKAG)(mQEE)3WPf8R4Y3KaNlAQcO(g8ybLqTSb(7ZO659F3bTGFfx(Me4Crtva13GhsX1bInWFFK9qeFi9AYzrU)7eWVIlFtcCUOPkG6BWJfrldHskT8nb)kU8njW5IMQaQVbe)YfX9fFcDYGFfx(Me4Crtva13aIjwrGFfx(Me4Crtva13GYeAPlEjuhcUdqWiIVzF(uAnF40cDnN2oqNIspViDa6nnUOITa5DcKkU8nbsHtkcm4Vd6rzArDi4ZHSdcNuKEChOqAA7X9zZ7XDGtLsW2(whWiVyKRDaVRWU0LWpNrMfPqAAHr8u9KaK3dKN2bfx(MDG4xUiUV4tOtUR(8P94oWPsjyBFRdyKxmY1oG3vyx6s4NZiZIuinTWiEQEsaYpGK2oO4Y3SdE(yuQIiPqoKCx95t6XDqXLVzhEoJmlsH002bovkbB7BD1NVBpUdCQuc2236ag5fJCTd2TGFoJmlsH00cxogspV6GIlFZo4Z5k0Y3mQhiTR(SH6XDGtLsW2(whWiVyKRDWUf8ZzKzrkKMw4YXq65vhuC5B2HhlIwgcLuA5B2vF(o7XDGtLsW2(whWiVyKRDWUf8ZzKzrkKMw4YXq65vhuC5B2bpFmkvrKuihsUR(8D0J7aNkLGT9ToGrEXix7GDl4NZiZIuinTWLJH0ZRoO4Y3Sde)YfX9fFcDYD1vhS8tpevpUpBEpUdkU8n7G1jOdJvh4uPeSTV1vF(0EChuC5B2b8MKJjhN6LJ7aNkLGT9TU6ZN0J7GIlFZoCq4Ox8K0bovkbB7BD1NVBpUdCQuc2236ag5fJCTdLk4SGXMueITXNGjMG5uPeSTdkU8n7awfIOIlFZOWjvheoPIPo5oqH002vF2q94oWPsjyBFRdyKxmY1o4jENEEfT6uV4OHia5ibsA7GIlFZoGvHiQ4Y3mkCs1bHtQyQtUdw(XjXHGjD1NVZECh4uPeSTV1bfx(MDaRcruXLVzu4KQdcNuXuNChW7kSlDjPR(8D0J7aNkLGT9ToO4Y3SdyviIkU8nJcNuDq4KkM6K7qUOPk6QRoyeX4DsPvpUpBEpUdCQuc2236qQtUdknsmPiLeFBwX9fnU0XOoO4Y3SdknsmPiLeFBwX9fnU0XOU6ZN2J7GIlFZoyClFZoWPsjyBFRRU6aExHDPlj94(S594oO4Y3Sdg3Y3SdCQuc2236QpFApUdCQuc2236ag5fJCTddfihcG0UfmEtmNfsl2gFcDYrQducxogspVasAcKdbqQ4Y3egVjMZcPfBJpHozypJpHFzQaYrhfiFhcreXytk6IJLpzG8EG8cBHNknaKJOdkU8n7aEtmNfsl2gFcDYD1NpPh3bovkbB7BDaJ8IrU2bQJ3dw4pMsSRfMukgsG8EG8KoO4Y3Sd0TiHfc2ZiIjBQjM7QpF3EChuC5B2HjpxKzX9ffhy3gTiwNKoWPsjyBFRR(SH6XDqXLVzhmXkQImHWjM7aNkLGT9TU6Z3zpUdCQuc2236GIlFZoGndl2cTPJJucLuDaJ8IrU2bQJ3dEYZfzwCFrXb2TrlI1jb2U0LDGFpgxXuNChWMHfBH20XrkHsQU6Z3rpUdCQuc2236GIlFZoOetqOjtIiLgxueViv0bmYlg5AhSm1X7bJuACrr8Iur0YuhVhSDPlbYrhfiTm1X7bJ30EGlhco6jKrltD8EWhgbsAcKLIU4c2eRIYeSrCbK3dKNyoqo6Oaz5towB06mqEpqEkTDi1j3bLyccnzseP04II4fPIU6Zq3EChuC5B2Hdch9INKoWPsjyBFRRU6GLFCsCiyspUpBEpUdCQuc2236ag5fJCTddfiFhcreXytk6IJLpzG8EG0CGKMaPN4D65v0Qt9IJNqaYraKJokqouGuXLdbh5KNotaYrcKNaK0ei9eVtpVIwDQxC8ecqstGK649GT8CZiXOdjtGTlDjqocGC0rbYHcKEI3PNxrRo1loAicqosGKw4tneqcDastSkktWtLgaYr0bfx(MDWYZnJeJoKmPR(8P94oWPsjyBFRdyKxmY1omuGuXLdbh5KNotaYrcKNaK0ei9eVtpVIwDQxC8ecqstGK649GT8CZiXOdjtGTlDjqocGC0rbYHcKEI3PNxrRo1loAicqosGKw47cKqhG0eRIYe8uPbGCeDqXLVzhi7HisPiKZOU6ZN0J7GIlFZom5sNlYOPL4KoWPsjyBFRR(8D7XDqXLVzhEoJmlsH002bovkbB7BD1vhYfnvrpUpBEpUdCQuc2236ag5fJCTdVdHiIySjfDXXYNmqEpqAEhuC5B2bpFmkvrKuihsUR(8P94oWPsjyBFRdyKxmY1oq2dr8H0RjNfbih5hqE3oO4Y3SdeJoYRi1oP6QpFspUdCQuc2236ag5fJCTddbqwQGZcMy0rEfP2jfmNkLGTDqXLVzhi7HiIfScb3vF(U94oWPsjyBFRdyKxmY1ouQGZcMy0rEfP2jfmNkLGTajnbsYEiIpKEn5Sia5hqsBhuC5B2bYEiIybRqWD1NnupUdCQuc2236ag5fJCTdgvpbY7)aYHtBhuC5B2bFoxHw(Mr9aPD1NVZECh4uPeSTV1bmYlg5AhmQEcK3)bK3bTDqXLVzhESGsOwUR(8D0J7aNkLGT9ToGrEXix7azpeXhsVMCweG8(pG8KoO4Y3SdpKIRde3vFg62J7GIlFZo8yr0YqOKslFZoWPsjyBFRR(8W7XDqXLVzhi(LlI7l(e6K7aNkLGT9TU6ZMtBpUdkU8n7aXeROoWPsjyBFRR(S5M3J7GIlFZouMqlDXlH6qWDGtLsW2(wxD1vxD1n]] )


end
