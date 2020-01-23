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

    
    local activation_time = function ()
        return talent.quickened_sigils.enabled and 1 or 2
    end

    spec:RegisterStateExpr( "activation_time", activation_time )
    spec:RegisterStateExpr( "sigil_placed", activation_time )

    local sigil_placed = function ()
        return sigils.flame > query_time
    end

    spec:RegisterStateExpr( "sigil_placed", sigil_placed )
    -- Also add to infernal_strike, sigil_of_flame.

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

            sigil_placed = sigil_placed,

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

            sigil_placed = sigil_placed,

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


    spec:RegisterPack( "Vengeance", 2020200123, [[dq0ADaqiGu9iksBsQKrjvQtjvXQqusVcrAwuIULuLAxG8lPIHrHCmGklJsYZOiMgqkxdrvBdrL(MuL04OKQ6CusL1bufVJskY8asUhG2hIIdsjLwiq5HsvIjcuvxeOkzJusrnsGQuNKskSsqzNaXsruINkLPkv1wPKQSxv(RqdgLdtAXi8yKMSGltSzf9zagnf1PP61GkZgv3wHDl63knCky5q9CitxY1PuBhu13PqnEevCEkH1JOuZhrSFv9bUR)1cAjhiwzKvgze4SYeiJSoYtUMqUxRSWGCndkfofGCTuhY1SEscq0KkxZGAbF1W1)AO1gtLRzUkdiWtNoa8YSnbeDhDq(WMRLVjfRZQdYh0oxJW25L1ipIRf0soqSYiRmYiWzLjqgzDKNCnH8xdzqOhiK36dURz2dbjpIRfee9AM(mRNKaenPYZaFzS5ZaVTZsWpmtFM5QmGapD6aWlZ2eq0D0b5dBUw(MuSoRoiFq78Wm9zW00wXw8mRSYYNzLrwz0d7Hz6Z6fZAcqqGNhMPpR3pZAdbj8mW3ryBd1ZQ9zbzQ286zkT8nFg3rf0dZ0N17N1lBcVGlj8mBKe9sgptYc7c6zZf)Sc7jCsHEwTpZgjrVKbYA6zyzSWlHNr3m4LVjc6Hz6Z69ZS2qqcpdTd5zEs3HNaEwqhka5zDEg1SIbipJI9sWU(SAFg4lJnFwZGdNGGEyM(SE)mYIGem8YZ0NrnRyaYZ25ZSg5uWPYFwRWoCYZ06zkN)SYhcc6Hz6Z69ZS2qqcpRT28NbMIXUGHUMb8oDUCntFM1tsaIMu5zGVm28zG32zj4hMPpZCvgqGNoDa4LzBci6o6G8HnxlFtkwNvhKpODEyM(myAARylEMvwz5ZSYiRm6H9Wm9z9IznbiiWZdZ0N17NzTHGeEg47iSTH6z1(SGmvBE9mLw(MpJ7Oc6Hz6Z69Z6LnHxWLeEMnsIEjJNjzHDb9S5IFwH9eoPqpR2NzJKOxYazn9mSmw4LWZOBg8Y3eb9Wm9z9(zwBiiHNH2H8mpP7WtaplOdfG8SopJAwXaKNrXEjyxFwTpd8LXMpRzWHtqqpmtFwVFgzrqcgE5z6ZOMvma5z78zwJCk4u5pRvyho5zA9mLZFw5dbb9Wm9z9(zwBiiHN1wB(ZatXyxWqpShMPpd8ICeQDjHNriZflpJUdcTEgHaWte0ZSwkvmuONLB2BZkEmT5ptPLVj6zBYTa6Hz6ZuA5BIGmGf6oi0c4KRi4EyM(mLw(MiidyHUdcTifyh1gWqYslFZhMPptPLVjcYawO7Gqlsb2zUB4Hz6ZAPAazERNHvp8mc75ucpdvAHEgHmxS8m6oi06zecaprptZWZmGLEByRYtapZrplSPa9Wm9zkT8nrqgWcDheArkWoOunGmVvevAHEykT8nrqgWcDheArkWo2ij6LmSm1HaujBKzfRO4CZkUZOH1yb)WuA5BIGmGf6oi0IuGDmSLV5d7Hz6ZaVihHAxs4zc8c2INv(qEwzwEMsRf)mh9mfE15kbxGEykT8nradocBBOEykT8nrKcSdDtK9qIdfGtFykT8nrKcSJnsIEjd0dtPLVjIuGDOkNhvA5Bg5oQSm1HaKaRzWsFcSuUKfe1SIXsio5cYmKKkbxcpmLw(Misb2HQCEuPLVzK7OYYuhcWGmLe5Wlil9jqpP7WtaXGouasK8iYy0dtPLVjIuGDOkNhvA5Bg5oQSm1HaKUlpSgNOhMslFtePa7qvopQ0Y3mYDuzzQdbyU4HYFypmtFM1SlylEgyyndpJSSLw(MpmLw(MiicSMbGihGZJ7mo56qS0NaP7YdRXj00fSfrcSMbiSmuprGYQhMslFteebwZaPa745uWPYJOc7Wjw6tG0D5H14eA6c2IibwZaewgQNiGg9WuA5BIGiWAgifyNPlylIeyndpmLw(MiicSMbsb2XhJLRLVzuTXQL(eyylOPlylIeyndqLtHZtapmLw(MiicSMbsb2zk8yqGxrLw(Mw6tGHTGMUGTisG1mavofopb8WuA5BIGiWAgifyhpNcovEevyhoXsFcmSf00fSfrcSMbOYPW5jGhMslFteebwZaPa7GCaopUZ4KRdXsFcmSf00fSfrcSMbOYPW5jGh2dZ0N1l7YdRXj6HP0Y3ebr3LhwJteqdB5B(WuA5BIGO7YdRXjIuGDOBsLSWAjH4KRdXsFcSBqpSfeDtQKfwljeNCDircBCcvofopb0fOR0Y3eIUjvYcRLeItUoeipJtUdWCrcjtBopIfQzfdqILpeqbGgGgk50ZdtPLVjcIUlpSgNisb2X4fZdWlEgXcAtnPIL(eiH9CcX9PqW3naHkLchOm5HP0Y3ebr3LhwJtePa7mKXITiUZi3M6Hyal6a9Wm9zGVmvBE9SPY5ekfUNnx8ZSrkbxEMGqssfe0dtPLVjcIUlpSgNisb2XSO4kkiKKu5HP0Y3ebr3LhwJtePa7yJKOxYWszofAftDiaPwq5BH30PrcUIkl9jqc75eAiJfBrCNrUn1dXaw0bckSgNpmLw(Mii6U8WACIifyhBKe9sgwM6qaQiZWRPGIyLSxCKUyLBPpbgec75ecRK9IJ0fR8yqiSNtOWACscjbHWEoHOBgSPLdVe9eUyqiSNtiBdDvkgGuqMfLxMHmqlqzc4iHKYhsS2yWfqzLrpmtFg4lt1MxpBQCoHsH7zZf)mBKsWLN5LmqqpmLw(Mii6U8WACIifyhBKe9sgOh2dZ0Nb(YusKdVGEykT8nrqbzkjYHxqadYyZiYGdNGS0Na7EAZ5rSqnRyasS8HakW1LN0D4jGyqhkajAcQhsiPBLwo8susz4cImM0LN0D4jGyqhkajAcQlc75ekiJnJidoCcckSgN9qcjD7jDhEcig0HcqIKhrgJGSI8KvZIYlZqdLC65HP0Y3ebfKPKihEbbeT28iHIXUGT0Na7wPLdVeLugUGiJjD5jDhEcig0HcqIMG6IWEoHcYyZiYGdNGGcRXzpKqs3Es3HNaIbDOaKi5rKXiiqJSAwuEzgAOKtppmLw(MiOGmLe5Wlisb2ziLowSbZlYrpmLw(MiOGmLe5Wlisb2z6c2IibwZWd7Hz6ZazXdL)mYYwA5B(WEykT8nrq5IhkhONtbNkpIkSdNyPpboT58iwOMvmajw(qaf46QBqVuUKf0KRdjsXkYmKKkbxcKqs3HTGqoaNh3zCY1HaHLH6jcuM0fOR0Y3eYZPGtLhrf2HtGqoaNhnWvQe6PNhMslFteuU4HYjfyhKbh7vKyhew6tGD3nH9CcnKshl2G5f5iiBdDHwBECIvadjlezaAspKqcAT5XjwbmKSqKbiO1ZdtPLVjckx8q5KcSdAT5rkxu4fl9jWUb9s5swqido2RiXoiGKuj4sORU7MWEoHgsPJfBW8ICeKTHUqRnpoXkGHKfImanPhsibT284eRagswiYae06PNhMslFteuU4HYjfyh0AZJuUOWlw6tGLYLSGqgCSxrIDqajPsWLqxO1MhNyfWqYcb0OhMslFteuU4HYjfyhFmwUw(Mr1gRw6tGgupbfqRZOhMslFteuU4HYjfyNPWj4AqS0NanOEckG9QrpmLw(MiOCXdLtkWotSslBSyPpbIwBECIvadjleOaAYdtPLVjckx8q5KcSZu4XGaVIkT8nFykT8nrq5IhkNuGDqoaNh3zCY1H8WuA5BIGYfpuoPa7Gmlk(HP0Y3ebLlEOCsb2PmJxJJa4QdVCn4fmY38aXkJaN1zK1zLrxZyfNEcaDnRXWWIlj8mY9zkT8nFg3rfc6HDn1UmV4R18rVCnUJk01)Aeyndx)deWD9VMKkbxchyxJI9sWUEn6U8WACcnDbBrKaRzacld1t0Za1ZS6AkT8nVgYb484oJtUoKRoqS66FnjvcUeoWUgf7LGD9A0D5H14eA6c2IibwZaewgQNONb8zgDnLw(MxZZPGtLhrf2HtU6aXKR)1uA5BETPlylIeyndxtsLGlHdSRoqaTR)1Kuj4s4a7AuSxc21Rf2cA6c2IibwZau5u48eW1uA5BEnFmwUw(Mr1gRxDGq(R)1Kuj4s4a7AuSxc21Rf2cA6c2IibwZau5u48eW1uA5BETPWJbbEfvA5BE1bc5E9VMKkbxchyxJI9sWUETWwqtxWwejWAgGkNcNNaUMslFZR55uWPYJOc7WjxDG0Rx)RjPsWLWb21OyVeSRxlSf00fSfrcSMbOYPW5jGRP0Y38AihGZJ7mo56qU6QRfKPAZRR)bc4U(xtPLV51cocBBOUMKkbxchyxDGy11)AkT8nVgDtK9qIdfGtVMKkbxchyxDGyY1)AkT8nVMnsIEjd01Kuj4s4a7Qdeq76FnjvcUeoWUgf7LGD9ALYLSGOMvmwcXjxqMHKuj4s4AkT8nVgv58OslFZi3r114oQIPoKRrG1mC1bc5V(xtsLGlHdSRrXEjyxVMN0D4jGyqhkajsE0ZiZZm6AkT8nVgv58OslFZi3r114oQIPoKRfKPKihEbD1bc5E9VMKkbxchyxtPLV51OkNhvA5Bg5oQUg3rvm1HCn6U8WACIU6aPxV(xtsLGlHdSRP0Y38AuLZJkT8nJChvxJ7OkM6qUwU4HYV6QRzal0DqO11)abCx)RjPsWLWb21sDixtjBKzfRO4CZkUZOH1ybFnLw(MxtjBKzfRO4CZkUZOH1ybF1bIvx)RP0Y38Ag2Y38AsQeCjCGD1vxJUlpSgNOR)bc4U(xtPLV51mSLV51Kuj4s4a7QdeRU(xtsLGlHdSRrXEjyxVw3pd0Fwyli6MujlSwsio56qIe24eQCkCEc4zD9mq)zkT8nHOBsLSWAjH4KRdbYZ4K7amxpJesE20MZJyHAwXaKy5d5zG6zaObOHsopRNRP0Y38A0nPswyTKqCY1HC1bIjx)RjPsWLWb21OyVeSRxJWEoH4(ui47gGqLsH7zG6zMCnLw(MxZ4fZdWlEgXcAtnPYvhiG21)AkT8nV2qgl2I4oJCBQhIbSOd01Kuj4s4a7QdeYF9VMslFZRzwuCffessQCnjvcUeoWU6aHCV(xtsLGlHdSRP0Y38AulO8TWB60ibxr11OyVeSRxJWEoHgYyXwe3zKBt9qmGfDGGcRX51K5uOvm1HCnQfu(w4nDAKGRO6QdKE96FnjvcUeoWUMslFZRPiZWRPGIyLSxCKUyLFnk2lb761ccH9CcHvYEXr6IvEmie2ZjuynoFgjK8SGqypNq0nd20YHxIEcxmie2ZjKTHN11ZkfdqkiZIYlZqgO1Za1ZmbCpJesEw5djwBm4YZa1ZSYORL6qUMImdVMckIvYEXr6Iv(vhiw)R)1uA5BEnBKe9sgORjPsWLWb2vxDTGmLe5WlOR)bc4U(xtsLGlHdSRrXEjyxVw3pBAZ5rSqnRyasS8H8mq9mW9SUEMN0D4jGyqhkajAc6z98msi5zD)mLwo8susz4c6zK5zM8SUEMN0D4jGyqhkajAc6zD9mc75ekiJnJidoCcckSgNpRNNrcjpR7N5jDhEcig0HcqIKh9mY8mJGSI8pJS(mZIYlZqdLCEwpxtPLV51cYyZiYGdNGU6aXQR)1Kuj4s4a7AuSxc21R19ZuA5WlrjLHlONrMNzYZ66zEs3HNaIbDOaKOjON11ZiSNtOGm2mIm4WjiOWAC(SEEgjK8SUFMN0D4jGyqhkajsE0ZiZZmcc0Egz9zMfLxMHgk58SEUMslFZRHwBEKqXyxWxDGyY1)AkT8nV2qkDSydMxKJUMKkbxchyxDGaAx)RP0Y38AtxWwejWAgUMKkbxchyxD11Yfpu(1)abCx)RjPsWLWb21OyVeSRxBAZ5rSqnRyasS8H8mq9mW9SUEw3pd0FwPCjlOjxhsKIvKzijvcUeEgjK8SUFwyliKdW5XDgNCDiqyzOEIEgOEMjpRRNb6ptPLVjKNtbNkpIkSdNaHCaopAGRuj8SEEwpxtPLV518Ck4u5ruHD4KRoqS66FnjvcUeoWUgf7LGD9AD)SUFgH9CcnKshl2G5f5iiBdpRRNHwBECIvadjl0ZidWNzYZ65zKqYZqRnpoXkGHKf6zKb4ZaTN1Z1uA5BEnKbh7vKyhexDGyY1)AsQeCjCGDnk2lb7616(zG(ZkLlzbHm4yVIe7GassLGlHN11Z6(zD)mc75eAiLowSbZlYrq2gEwxpdT284eRagswONrgGpZKN1ZZiHKNHwBECIvadjl0ZidWNbApRNN1Z1uA5BEn0AZJuUOWlxDGaAx)RjPsWLWb21OyVeSRxRuUKfeYGJ9ksSdcijvcUeEwxpdT284eRagswONb8zgDnLw(MxdT28iLlk8YvhiK)6FnjvcUeoWUgf7LGD9AgupFgOa(mRZORP0Y38A(ySCT8nJQnwV6aHCV(xtsLGlHdSRrXEjyxVMb1ZNbkGpRxn6AkT8nV2u4eCnixDG0Rx)RjPsWLWb21OyVeSRxdT284eRagswONbkGpZKRP0Y38AtSslBSC1bI1)6FnLw(MxBk8yqGxrLw(MxtsLGlHdSRoqSUR)1uA5BEnKdW5XDgNCDixtsLGlHdSRoqaNrx)RP0Y38AiZIIVMKkbxchyxDGaoWD9VMslFZRvMXRXraC1HxUMKkbxchyxD1vxD1D]] )


end
