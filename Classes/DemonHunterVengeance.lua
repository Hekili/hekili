-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DEMONHUNTER' then
    local spec = Hekili:NewSpecialization( 581 )

    spec:RegisterResource( Enum.PowerType.Fury )

    -- Talents
    spec:RegisterTalents( {
        abyssal_strike = 22502, -- 207550
        agonizing_flames = 22503, -- 207548
        felblade = 22504, -- 232893

        feast_of_souls = 22505, -- 207697
        fallout = 22766, -- 227174
        burning_alive = 22507, -- 207739

        infernal_armor = 22324, -- 320331
        charred_flesh = 22541, -- 336639
        spirit_bomb = 22540, -- 247454

        soul_rending = 22508, -- 217996
        feed_the_demon = 22509, -- 218612
        fracture = 22770, -- 263642

        concentrated_sigils = 22546, -- 207666
        quickened_sigils = 22510, -- 209281
        sigil_of_chains = 22511, -- 202138

        void_reaver = 22512, -- 268175
        demonic = 22513, -- 321453
        soul_barrier = 22768, -- 263648

        last_resort = 22543, -- 209258
        ruinous_bulwark = 23464, -- 326853
        bulk_extraction = 21902, -- 320341
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        cleansed_by_flame = 814, -- 205625
        demonic_trample = 3423, -- 205629
        detainment = 3430, -- 205596
        everlasting_hunt = 815, -- 205626
        illidans_grasp = 819, -- 205630
        jagged_spikes = 816, -- 205627
        reverse_magic = 3429, -- 205604
        sigil_mastery = 1948, -- 211489
        tormentor = 1220, -- 207029
        unending_hatred = 3727, -- 213480
    } )


    -- Auras
    spec:RegisterAuras( {
        chaos_brand = {
            id = 1490,
            duration = 3600,
            max_stack = 1,
        },
        charred_flesh = {
            id = 336640,
            duration = 9,
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
            duration = function () return ( level > 55 or azerite.revel_in_pain.enabled ) and 10 or 8 end,
            max_stack = 1,
        },
        frailty = {
            id = 247456,
            duration = 20,
            type = "Magic",
            max_stack = 1,
        },
        glide = {
            id = 131347,
            duration = 3600,
            max_stack = 1,
        },
        immolation_aura = {
            id = 258920,
            duration = function () return talent.agonizing_flames.enabled and 9 or 6 end,
            max_stack = 1,
        },
        metamorphosis = {
            id = 187827,
            duration = 10,
            max_stack = 1,
        },
        revel_in_pain = {
            id = 343013,
            duration = 15,
            max_stack = 1,
        },
        ruinous_bulwark = {
            id = 326863,
            duration = 10,
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
            t[ k ] = 0
            return t[ k ]
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

    local sigil_placed = function ()
        return sigils.flame > query_time
    end

    spec:RegisterStateExpr( "sigil_placed", sigil_placed )
    -- Also add to infernal_strike, sigil_of_flame.

    spec:RegisterStateTable( "fragments", {
        real = 0,
        realTime = 0,
    } )

    spec:RegisterStateFunction( "queue_fragments", function( num, extraTime )
        fragments.real = fragments.real + num
        fragments.realTime = GetTime() + 1.25 + ( extraTime or 0 )
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

        if IsSpellKnownOrOverridesKnown( class.abilities.elysian_decree.id ) then
            local activation = ( action.elysian_decree.lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
            if activation > now then sigils.elysian_decree = activation
            else sigils.elysian_decree = 0 end
        else
            sigils.elysian_decree = 0
        end

        if talent.abyssal_strike.enabled then
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


    -- Abilities
    spec:RegisterAbilities( {
        bulk_extraction = {
            id = 320341,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = true,
            texture = 136194,

            talent = "bulk_extraction",
            
            handler = function ()                
            end,
        },
        
        
        consume_magic = {
            id = 278326,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = -20,
            spendType = "fury",

            startsCombat = true,
            texture = 828455,

            toggle = "interrupts",
            buff = "dispellable_magic",

            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },


        demon_spikes = {
            id = 203720,
            cast = 0,
            icd = 1,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            hasteCD = true,
            gcd = "off",

            defensive = true,

            startsCombat = false,
            texture = 1344645,

            toggle = "defensives",

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

            spend = -30,
            spendType = "fury",

            startsCombat = true,
            texture = 1305153,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        fel_devastation = {
            id = 212084,
            cast = 2,
            fixedCast = true,
            channeled = true,
            cooldown = 45,
            gcd = "spell",
            
            spend = 50,
            spendType = "fury",

            startsCombat = true,
            texture = 1450143,

            start = function ()
                applyBuff( "fel_devastation" )
            end,

            finish = function ()
                if talent.demonic.enabled then applyBuff( "metamorphosis", 8 ) end
                if talent.ruinous_bulwark.enabled then applyBuff( "ruinous_bulwark" ) end
            end
        },


        felblade = {
            id = 232893,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = -40,
            spendType = "fury",

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

            toggle = "defensives",

            startsCombat = true,
            texture = 1344647,

            handler = function ()
                applyDebuff( "target", "fiery_brand" )
                if talent.charred_flesh.enabled then applyBuff( "charred_flesh" ) end
                removeBuff( "spirit_of_the_darkness_flame" )
            end,

            auras = {
                spirit_of_the_darkness_flame = {
                    id = 337542,
                    duration = 3600,
                    max_stack = 1
                }
            }
        },


        fracture = {
            id = 263642,
            cast = 0,
            charges = 2,
            cooldown = 4.5,
            recharge = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = function () return level > 47 and buff.metamorphosis.up and -45 or -25 end,
            spendType = "fury",            

            startsCombat = true,
            texture = 1388065,

            talent = "fracture",

            handler = function ()
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
            channeled = true,
            cooldown = function () return buff.illidans_grasp.up and ( 54 + buff.illidans_grasp.remains ) or 0 end,
            gcd = "off",

            pvptalent = "illidans_grasp",
            aura = "illidans_grasp",
            breakable = true,

            startsCombat = true,
            texture = function () return buff.illidans_grasp.up and 252175 or 1380367 end,

            start = function ()
                if buff.illidans_grasp.up then removeBuff( "illidans_grasp" )
                else applyBuff( "illidans_grasp" ) end
            end,

            copy = { 205630, 208173 }
        },


        immolation_aura = {
            id = 258920,
            cast = 0,
            cooldown = function () return level > 26 and 15 or 30 end,
            gcd = "spell",

            startsCombat = true,
            texture = 1344649,

            handler = function ()
                applyBuff( "immolation_aura" )

                if legendary.fel_flame_fortification.enabled then applyBuff( "fel_flame_fortification" ) end

                if pvptalent.cleansed_by_flame.enabled then
                    removeDebuff( "player", "reversible_magic" )
                end
            end,

            auras = {
                fel_flame_fortification = {
                    id = 337546,
                    duration = function () return class.auras.immolation_aura.duration end,
                    max_stack = 1
                }
            }
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
            icd = 1,
            charges = 2,
            cooldown = function () return talent.abyssal_strike.enabled and 12 or 20 end,
            recharge = function () return talent.abyssal_strike.enabled and 12 or 20 end,
            gcd = "off",

            startsCombat = true,
            texture = 1344650,

            sigil_placed = sigil_placed,

            handler = function ()
                setDistance( 5 )
                spendCharges( "demonic_trample", 1 )

                if talent.abyssal_strike.enabled then
                    create_sigil( "flame" )
                end
            end,
        },


        metamorphosis = {
            id = 187827,
            cast = 0,
            cooldown = function ()
                return ( level > 47 and 180 or ( level > 19 and 240 or 300 ) ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1247263,

            handler = function ()
                applyBuff( "metamorphosis" )
                gain( 8, "fury" )

                if IsSpellKnownOrOverridesKnown( 317009 ) then
                    applyDebuff( "target", "sinful_brand" )
                    active_dot.sinful_brand = active_enemies
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

            buff = "reversible_magic",

            handler = function ()
                if debuff.reversible_magic.up then removeDebuff( "player", "reversible_magic" ) end
            end,
        },


        shear = {
            id = 203782,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return level > 47 and buff.metamorphosis.up and -30 or -10 end,
            spendType = "fury",

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
            spendType = "fury",

            startsCombat = true,
            texture = 1344653,

            handler = function ()
                if talent.feed_the_demon.enabled then
                    gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
                end

                if talent.void_reaver.enabled then applyDebuff( "target", "void_reaver" ) end
                if legendary.fiery_soul.enabled then reduceCooldown( "fiery_brand", 2 * min( 2, buff.soul_fragments.stack ) ) end

                -- Razelikh's is random; can't predict it.

                buff.soul_fragments.count = max( 0, buff.soul_fragments.stack - 2 )
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
            spendType = "fury",

            startsCombat = true,
            texture = 1097742,

            buff = "soul_fragments",

            handler = function ()
                if talent.feed_the_demon.enabled then
                    gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
                end

                applyDebuff( "target", "frailty" )
                active_dot.frailty = active_enemies

                buff.soul_fragments.count = 0
            end,
        },


        throw_glaive = {
            id = 204157,
            cast = 0,
            cooldown = function () return level > 31 and 3 or 9 end,
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


    spec:RegisterPack( "Vengeance", 20200828.1, [[dqeKHaqiHu9iviBIIQrPc1PufSkkkPxbkMLq4wifSlq(LkQHjeDmvvSmKQEMqY0qkY1qk12qkuFdPqgNQqohfLY6ufkEhfLO5PQs3tvzFiLCqkkSqvrpuvOAIuu0ffsPSrHuQgjfLWjfsjReuTtvKLsrP6PszQQGTQkuAVk(RGbt0HjTyK8yetMsxg1MLQpRknAk0PP61QQA2eUTkTBr)wPHtrwouphY0LCDHA7GsFhPY4rkQZtbwVqkMpf0(bE(zomnRw8CI(iPpYiFe9pcIE6Pn90(rtRmWepntk5V(Ytl1lpThlNVSMeEAMudeRANdtdTXycpnJvzc9yoF(1lJXuqK9Eg53yHw(MeS2RZi)sopnQyxurRCOMMvlEorFK0hzKpI(hbrp90M(FIAAitmzor7h9Z0m6wlNd10SmImTJaYhlNVSMegint(UjqAweNfJbWpcinJ43yubK0)Oias6JK(ibWbWpciFCJA(YOhda(rajnaKMH1YwG0mDeo2ubK1cKwURXIcivs5BcKchvqa4hbK0aq(4BclJl2cKXio4fFbsolSZiGSVyGSWE(NleqwlqgJ4Gx8fzwcKy(UWYwGKSP1lFteea(rajnaKMH1YwGeTxgi9KSxpFbsRE1xgipdKeJk(Lbsc2lg7kqwlqAM8DtGSzY)Ziia8JasAain7mIXWYaPcKeJk(LbYTdKrRSZ4ufazRW(Fgi1civHail)Yiia8JasAaindRLTazBJfa5tfJDgdnnt4T7cEAhbKpwoFznjmqAM8DtG0SiolgdGFeqAgXVXOciP)rraK0hj9rcGdGFeq(4g18Lrpga8JasAaindRLTaPz6iCSPciRfiTCxJffqQKY3eifoQGaWpciPbG8X3ewgxSfiJrCWl(cKCwyNrazFXazH98pxiGSwGmgXbV4lYSeiX8DHLTajztRx(Miia8JasAaindRLTajAVmq6jzVE(cKw9QVmqEgijgv8ldKeSxm2vGSwG0m57MazZK)Nrqa4hbK0aqA2zeJHLbsfijgv8ldKBhiJwzNXPkaYwH9)mqQfqQcbqw(Lrqa4hbK0aqAgwlBbY2glaYNkg7mgcaha)iGmAJMzsCXwGKI7lMbsYEP0ciP4xprqaPzqiSPcbK5M0GrfF7XcGujLVjci3uyaea(raPskFteKjmt2lLwFDHI(dGFeqQKY3ebzcZK9sPfmFN143lNLw(Ma4hbKkP8nrqMWmzVuAbZ35(Uwa8JaYwQMqg3ciXQBbsQ4ENTajQ0cbKuCFXmqs2lLwajf)6jci10cKMWmnyARYZxG0raPDtgca)iGujLVjcYeMj7Lsly(oJs1eY4wbuPfcaxjLVjcYeMj7Lsly(o3xRLXHAdLro0f6LbWvs5BIGmHzYEP0cMVZXio4fFJi1l)PrdYOIvuOVzf2EW0shJbWvs5BIGmHzYEP0cMVZM2Y3eaha)iGmAJMzsCXwGKHLXgaKLFzGSmYaPsQfdKocivyvxOucgcaxjLVj6Z6iCSPcaxjLVjcMVZKnrXxoC1xNaGRKY3ebZ3zmdlJrC4QVobaxjLVjcMVZXio4fFra4kP8nrW8DMOcrqjLVzq4OkIuV8hfwtBeE)RubNfeXOIXSn0fmYieNkLGTa4kP8nrW8DMOcrqjLVzq4OkIuV8NL7CICyzueE)ZtYE98ny1R(YbAJOvKa4kP8nrW8DMOcrqjLVzq4OkIuV8hzxHDPlra4kP8nrW8DMOcrqjLVzq4OkIuV8xU4RkaWbWpciJ2DgBaq(eRPfin7BPLVjaUskFteefwt7NNDgNQiGkS)NJW7FKDf2LUeQ7m2GafwtleMVQNOVinVubNfKszacPIaQW(FgItLsWwZJUskFtip7movravy)pdH8xxemjucBn3YuX9oeYFDry7HUqVmKDPlbWvs5BIGOWAAH57mYFDry7HUqVCeE)JSRWU0LqDNXgeOWAAHW8v9e9l9MhDLu(MqE2zCQIaQW(Fgc5VUiysOe2cGRKY3ebrH10cZ35UZydcuynTa4kP8nrquynTW8D2V3vOLVzqJXAeE)ZUfu3zSbbkSMwOYj)98faxjLVjcIcRPfMVZDweSmSkQ0Y3mcV)z3cQ7m2Gafwtlu5K)E(cGRKY3ebrH10cZ3zp7movravy)phH3)SBb1DgBqGcRPfQCYFpFbWvs5BIGOWAAH57mYFDry7HUqVCeE)ZUfu3zSbbkSMwOYj)98faha)iG8X3vyx6seaUskFteezxHDPlrFM2Y3eaxjLVjcISRWU0Liy(ot2KWzH1ITHUqVCeE)74OB3cISjHZcRfBdDHE5avmoHkN83ZxZJUskFtiYMeolSwSn0f6LH8m0f(RXYqd7XcraZeJk(LdLF5FFjwORsZpaGRKY3ebr2vyx6semFNPBXclSSNbmJ2utchH3)OI7DiH3zkXUwiuPK))gfaUskFteezxHDPlrW8D(Y3fBqy7brmXTblM1lca)iG0m5UglkGSRcbLs(dK9fdKXiLsWajJqCsyeeaUskFteezxHDPlrW8D2iR4kWieNegaxjLVjcISRWU0Liy(o3xRLXHAdLro0f6LbWvs5BIGi7kSlDjcMVZip7XIafwtlaUskFteezxHDPlrW8DUmYbJXzbGRKY3ebr2vyx6semFNzHbixZGLjyMJW7FkPCy5aN81zeTOhaxjLVjcISRWU0Liy(ohJ4Gx8ncU3zsfs9YFediITWB6KaLqrveE)JkU3HU8DXge2EqetCBWIz9IGSlDjaUskFteezxHDPlrW8DogXbV4BePE5pfzewnzuaRrZIdKfRIi8(NLPI7DiSgnloqwSkcwMkU3HSlDPHgAzQ4EhISPnMuoSCWZ)bltf37qXMmVu8lxqgzvugHmrQFJ6hdnS8lhQnyD(x6Jea)iG0m5UglkGSRcbLs(dK9fdKXiLsWaPx8fbbGRKY3ebr2vyx6semFNJrCWl(IaWvs5BIGi7kSlDjcMVZDweSmSkQ0Y3mcV)vQGZcYY3nDceNkLGTa4a4hbKMj35e5WYiaCLu(Miil35e5WYOplF3mGm5)zueE)74ESqeWmXOIF5q5x(3Fm3tYE98ny1R(YHOqpyOHhRKYHLdCYxNr0kkZ9KSxpFdw9QVCikK5uX9oKLVBgqM8)mcYU0LpyOHh7jzVE(gS6vF5aTr0ksi6PTz1iRIYi0vP5haWvs5BIGSCNtKdlJG57mAJfbkfJDghH3)owjLdlh4KVoJOvuM7jzVE(gS6vF5quiZPI7DilF3mGm5)zeKDPlFWqdp2tYE98ny1R(YbAJOvKq0Kz1iRIYi0vP5haWvs5BIGSCNtKdlJG57mvS4FGP5cRKY3mcV)zKvrzeYeJjCw)s7ibWvs5BIGSCNtKdlJG578Ll9UytgxKJaWvs5BIGSCNtKdlJG57C3zSbbkSMwaCa8JaYtl(QcG0SVLw(Ma4a4kP8nrq5IVQ4ZZoJtveqf2)Zr49VESqeWmXOIF5q5x(3Fm)4OxQGZcQl0lhiyfzeItLsWwdn8y7wqi)1fHTh6c9Yqy(QEI(nkZJUskFtip7movravy)pdH8xxemjucBF4baCLu(MiOCXxvaZ3zKjh7vGAVur49VJpMkU3HUCP3fBY4ICeuSjZrBSi0X67LZcrRVOEWqdrBSi0X67LZcrRpA6baCLu(MiOCXxvaZ3z0glcebRWYr49VJJEPcoliKjh7vGAVuqCQuc2A(Xhtf37qxU07InzCrock2K5Onwe6y99YzHO1xupyOHOnwe6y99YzHO1hn9Wda4kP8nrq5IVQaMVZOnweicwHLJW7FLk4SGqMCSxbQ9sbXPsjyR5Onwe6y99YzH(IeaxjLVjckx8vfW8D2V3vOLVzqJXAeE)RhJn43pZwKa4kP8nrq5IVQaMVZw(UPtcfwVMemaUskFteuU4RkG57CNfuc1Yr49VEm2GF)OrrcGRKY3ebLl(Qcy(o3XkPIXCeE)dTXIqhRVxol0VFrbGRKY3ebLl(Qcy(o3zrWYWQOslFtaCLu(MiOCXxvaZ3zK)6IW2dDHEzaCLu(MiOCXxvaZ3zKrwXa4kP8nrq5IVQaMVZLr8sx4vOoS80GLXiFZ5e9rsFKr(i6F00OtXPNVOPfTUMwCXwGKgdKkP8nbsHJkeea(004Y4INwZVp(0eoQqZHPrH10ohMt)mhMgNkLGTZZPrWEXyxNgzxHDPlH6oJniqH10cH5R6jci)aYibsZbYsfCwqkLbiKkcOc7)ziovkbBbsZbYOdKkP8nH8SZ4ufbuH9)meYFDrWKqjSfinhiTmvCVdH8xxe2EOl0ldzx6YPPKY3CAE2zCQIaQW(FEQ5e9ZHPXPsjy78CAeSxm21Pr2vyx6sOUZydcuynTqy(QEIaYFbs6bsZbYOdKkP8nH8SZ4ufbuH9)meYFDrWKqjSDAkP8nNgYFDry7HUqV8uZPOMdttjLV506oJniqH10onovkbBNNtnNOP5W04uPeSDEonc2lg760SBb1DgBqGcRPfQCYFpFNMskFZP537k0Y3mOXyDQ5eTNdtJtLsW2550iyVySRtZUfu3zSbbkSMwOYj)98DAkP8nNwNfbldRIkT8nNAorJNdtJtLsW2550iyVySRtZUfu3zSbbkSMwOYj)98DAkP8nNMNDgNQiGkS)NNAorJMdtJtLsW2550iyVySRtZUfu3zSbbkSMwOYj)98DAkP8nNgYFDry7HUqV8utnnl31yrnhMt)mhMMskFZPzDeo2unnovkbBNNtnNOFomnLu(MtJSjk(YHR(6KPXPsjy78CQ5uuZHPPKY3CAygwgJ4WvFDY04uPeSDEo1CIMMdttjLV50IrCWl(IMgNkLGTZZPMt0EomnovkbBNNtJG9IXUoTsfCwqeJkgZ2qxWiJqCQuc2onLu(MtJOcrqjLVzq4OAAchvHuV80OWAANAorJNdtJtLsW2550iyVySRtZtYE98ny1R(YbAJasAbKronLu(MtJOcrqjLVzq4OAAchvHuV80SCNtKdlJMAorJMdtJtLsW2550us5BonIkebLu(MbHJQPjCufs9YtJSRWU0LOPMtpAomnovkbBNNttjLV50iQqeus5BgeoQMMWrvi1lpTCXxvm1utZeMj7LsR5WC6N5W0us5BoT(ATmouBOmYHUqV804uPeSDEo1CI(5W04uPeSDEoTuV800ObzuXkk03ScBpyAPJXttjLV500ObzuXkk03ScBpyAPJXtnNIAomnLu(MtZ0w(MtJtLsW255utnnYUc7sxIMdZPFMdttjLV50mTLV504uPeSDEo1CI(5W04uPeSDEonc2lg760ogiJoqA3cISjHZcRfBdDHE5avmoHkN83ZxG0CGm6aPskFtiYMeolSwSn0f6LH8m0f(RXcin0qGShlebmtmQ4xou(LbYFbYxIf6Q0mq(W0us5BonYMeolSwSn0f6LNAof1CyACQuc2opNgb7fJDDAuX9oKW7mLyxleQuYFG8xGmQPPKY3CA0TyHfw2ZaMrBQjHNAortZHPPKY3CAx(UydcBpiIjUnyXSErtJtLsW255uZjAphMMskFZPzKvCfyeItcpnovkbBNNtnNOXZHPPKY3CA91AzCO2qzKdDHE5PXPsjy78CQ5enAomnLu(Mtd5zpweOWAANgNkLGTZZPMtpAomnLu(MtRmYbJXznnovkbBNNtnNmBZHPXPsjy78CAeSxm21PPKYHLdCYxNrajTas6NMskFZPXcdqUMbltWmp1C6NiNdtJtLsW2550us5BonIbeXw4nDsGsOOAAeSxm21Prf37qx(UydcBpiIjUnyXSErq2LUCACVZKkK6LNgXaIyl8Mojqjuun1C6NFMdtJtLsW2550us5BonfzewnzuaRrZIdKfRIPrWEXyxNMLPI7DiSgnloqwSkcwMkU3HSlDjqAOHaPLPI7DiYM2ys5WYbp)hSmvCVdfBcinhilf)YfKrwfLritKci)fiJ6hG0qdbYYVCO2G1zG8xGK(iNwQxEAkYiSAYOawJMfhilwftnN(H(5W0us5BoTyeh8IVOPXPsjy78CQ50prnhMgNkLGTZZPrWEXyxNwPcolilF30jqCQuc2onLu(MtRZIGLHvrLw(Mtn10SCNtKdlJMdZPFMdtJtLsW2550iyVySRt7yGShlebmtmQ4xou(LbYFbYFasZbspj71Z3GvV6lhIcbKpaKgAiqEmqQKYHLdCYxNrajTaYOasZbspj71Z3GvV6lhIcbKMdKuX9oKLVBgqM8)mcYU0La5daPHgcKhdKEs2RNVbRE1xoqBeqslGmsi6PnqAwbsJSkkJqxLMbYhMMskFZPz57MbKj)pJMAor)CyACQuc2opNgb7fJDDAhdKkPCy5aN81zeqslGmkG0CG0tYE98ny1R(YHOqaP5ajvCVdz57MbKj)pJGSlDjq(aqAOHa5XaPNK965BWQx9Ld0gbK0ciJeIMasZkqAKvrze6Q0mq(W0us5Bon0glcukg7mEQ5uuZHPXPsjy78CAeSxm21PzKvrzeYeJjCwa5VajTJCAkP8nNgvS4FGP5cRKY3CQ5ennhMMskFZPD5sVl2KXf5OPXPsjy78CQ5eTNdttjLV506oJniqH10onovkbBNNtn10YfFvXCyo9ZCyACQuc2opNgb7fJDDA9yHiGzIrf)YHYVmq(lq(dqAoqEmqgDGSubNfuxOxoqWkYieNkLGTaPHgcKhdK2TGq(RlcBp0f6LHW8v9ebK)cKrbKMdKrhivs5Bc5zNXPkcOc7)ziK)6IGjHsylq(aq(W0us5Bonp7movravy)pp1CI(5W04uPeSDEonc2lg760ogipgiPI7DOlx6DXMmUihbfBcinhirBSi0X67LZcbK06diJciFain0qGeTXIqhRVxoleqsRpGKMaYhMMskFZPHm5yVcu7LAQ5uuZHPXPsjy78CAeSxm21PDmqgDGSubNfeYKJ9kqTxkiovkbBbsZbYJbYJbsQ4Eh6YLExSjJlYrqXMasZbs0glcDS(E5SqajT(aYOaYhasdneirBSi0X67LZcbK06diPjG8bG8HPPKY3CAOnweicwHLNAortZHPXPsjy78CAeSxm21PvQGZcczYXEfO2lfeNkLGTaP5ajAJfHowFVCwiG8diJCAkP8nNgAJfbIGvy5PMt0EomnovkbBNNtJG9IXUoTEm2aG83pG0Sf50us5Bon)ExHw(MbngRtnNOXZHPPKY3CAw(UPtcfwVMe804uPeSDEo1CIgnhMgNkLGTZZPrWEXyxNwpgBaq(7hqsJICAkP8nNwNfuc1YtnNE0CyACQuc2opNgb7fJDDAOnwe6y99YzHaYF)aYOMMskFZP1XkPIX8uZjZ2CyAkP8nNwNfbldRIkT8nNgNkLGTZZPMt)e5CyAkP8nNgYFDry7HUqV804uPeSDEo1C6NFMdttjLV50qgzfpnovkbBNNtnN(H(5W0us5BoTYiEPl8kuhwEACQuc2opNAQPMAQza]] )

end
