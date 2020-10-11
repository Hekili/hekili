-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] soul_furnace -- NYI: forecast stacks.

-- Vengeance Endurance
-- [-] demon_muzzle
-- [-] roaring_fire


if UnitClassBase( "player" ) == "DEMONHUNTER" then
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
            cooldown = function () return 60 + ( conduit.fel_defender.mod * 0.001 ) end,
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

                if conduit.felfire_haste.enabled then applyBuff( "felfire_haste" ) end
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

            auras = {
                -- Conduit, applies after SoS expires.
                demon_muzzle = {
                    id = 339589,
                    duration = 6,
                    max_stack = 1
                }
            }
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

                if buff.soul_furnace.up and buff.soul_furnace.stack == 10 then removeBuff( "soul_furnace" ) end
            end,

            auras = {
                -- Conduit
                soul_furnace = {
                    id = 339424,
                    duration = 30,
                    max_stack = 10,
                }
            }
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
                if conduit.serrated_glaive.enabled then applyDebuff( "target", "exposed_wound" ) end
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


    spec:RegisterPack( "Vengeance", 20201011, [[dqKiDaqifv6rQQInruAuqOtbuTkIK0RGGzrfClvvvXUa8lvvggqCmG0YikEgvIPrfY1isSnvvjFtvvLXrfkNJkuTofvqZJkP7PK2NIQoOQQQ0cvv6HQQQktuvvQlQQQQAJkQaJurf6KejHvsfTtvf)KijAPkQipLQMQIYwvurTxP(lLgmfhM0IH0JrAYkCzuBwP(SsmAI40IEne1SjCBvz3s(TkdNOA5q9Cetx46kY2HiFhOmEvvLZtKA9ej18PsTFq3G2ZA)qdU)idiYacOGakOaGckioMJKP9H0Y52lxPiRlC7l9XTFoZ1cRfLBVCvAXPJEw7j3eMYTxseYjZH)(TKHKjua69(rY3KqJ8kkw3Xps(O)Ap6ukcPIQrB)qdU)idiYacOGakOaGckioMmsP9e5mT)ifhd02ljhdUA02pycT9)bA(B(Df0mhNQGXqZCMRfwlkdD(hOrQKghkJHgqb1bOrgqKbK2lhF7uWT)pqZFZVRGM54ufmgAMZCTWArzOZ)ansL04qzm0akOoanYaImGaDcD(hOXxQCIKlGgSMdObDAV5b0qcniqdkVpmdn07HQb0GYlzrGgTgqJCm))i)IiRfOjjqZ4kga6uPrEfbqoMP3dvdew)j)I8kOtLg5vea5yMEpunqy93eHTzWphk9XRQutKOyLy3xf2BBLFGXyOtOZ)an)))JPtbpGggjgln0e5JHMqcdnknom0KeOrrstHIkyaOtLg5vK1rsWtYdOtLg5veew)rVIm9y7txsk0PsJ8kccR)WmsmMW2NUKuOtLg5veew)rvHWQ0iVYkss4qPpEffR1a6uPrEfbH1FuviSknYRSIKeou6Jxh8MlsIetGovAKxrqy9hvfcRsJ8kRijHdL(4v6DIXbwrGovAKxrqy9hvfcRsJ8kRijHdL(416WpvaDcD(hOzoizS0qZxSwdOzoDHg5vqNknYRiaOyTgRKCjf2BB3c9XoK7v6DIXbwbStglTffR1aaZpnlIRYaDQ0iVIaGI1AGW6VS2mUuHLe4ez2HCVsVtmoWkGDYyPTOyTgay(Pzrwbb6uPrEfbafR1aH1F7KXsBrXAnGovAKxraqXAnqy9x(ENqJ8kRoHvhY964cGDYyPTOyTgarsroRfOtLg5veauSwdew)L1MXLkSKaNiZoK71Xfa7KXsBrXAnaIKICwlqNknYRiaOyTgiS(JKlPWEB7wOp2HCVoUayNmwAlkwRbqKuKZAb6e6uPrEfbGENyCGvKv5xKxbDQ0iVIaqVtmoWkccR)izTNewuSwdhY96ChxaqYApjSOyTgarsroRfOtLg5vea6DIXbwrqy9xiHTsMQa6uPrEfbGENyCGveew)TVXGX24SHe2Uf6JHovAKxraO3jghyfbH1FSqAsQLDWumZqNknYRia07eJdSIGW6p6vuUcSg8WUf6JDi3Rio3Xfa0ROCfyn4HDl0hBrNWfqKuKZAr25Q0iVcGEfLRaRbpSBH(yGSSBrUijC7EpjewmtLO4f2g5JDDHoaE6)ah6uPrEfbGENyCGveew)b2HfdK4SSyMCLwu2HCVIoT3aICZOI7gaKqPi7QlqNknYRia07eJdSIGW6Vh)oS02BBft0CyhywFeOZ)anZXtmGM5eRYZAbAMde6JjqZ(Wqd)pMofm0G1AHHMddniNcb0GoT3ehGMCdnYpcjrfma08)katLManbwAOjoOzHdOjKWqJ4aJjb0qVtmoWkObvj8aAUcAuK0uOOcgA4IFjtaGovAKxraO3jghyfbH1FywLN1IDl0htCi3RHIx4aiYhBJZos2vqbKIB3iIyO4foaKWQiKaiNgZ7yG42DO4foaKWQiKaiNgUUkdiGllIknsKylx8lzYkOUDVZfjHfZpnlY8Y44GdUB3igkEHdGiFSnoRCAyLbK5DbezruPrIeB5IFjtwb1T7DUijSy(PzrM3rocCWHo)d0838wNeb0SvHavPidn7ddntefvWqdtiCrzca0PsJ8kca9oX4aRiiS(tcR4WYecxug6uPrEfbGENyCGveew)nryBg8ZbEVzAyl9XRuPPIlWxLulQqjHd5EfDAVbE87WsBVTvmrZHDGz9raghyf0PsJ8kca9oX4aRiiS(BIW2m4NdL(4vLibjTyIfRs9HT0dRchY96GrN2BaSk1h2spSkSdgDAVbghyLB3dgDAVbOxnMOrIeBZcz7GrN2BGj5YgkEHdajSkcjaYPHRUaQB3HIx4aiYhBJZos2vzab68pqZFZBDseqZwfcuLIm0Spm0mruubdnzWpca0PsJ8kca9oX4aRiiS(BIW2m4hb6e68pqZFZBUijsmb6uPrEfbyWBUijsmzDWVRSe5jYmXHCVgAHCwlYIiI7jHWIzQefVW2iFSRGkBw07L1IDOpDHTUqa3TBevAKiXwU4xYK5Dr2SO3lRf7qF6cBDHil60Edm43vwI8ezMamoWkWD7gXSO3lRf7qF6cBLczEqaKrksvjSkcjap9FGdo0PsJ8kcWG3CrsKyccR)i3KWIQyCYyhY9kIknsKylx8lzY8UiBw07L1IDOpDHTUqKfDAVbg87klrEImtaghyf4UDJyw07L1IDOpDHTsHmpiaosQkHvrib4P)dCOtLg5veGbV5IKiXeew)Hojq2Y)lWknYRCi3RsyvesaKZykxHRsbeOtLg5veGbV5IKiXeew)94qFhwUKJKeOtLg5veGbV5IKiXeew)TtglTffR1a6e68pqZNd)ub0mNUqJ8kOtLg5veG6WpvSM1MXLkSKaNiZoK719KqyXmvIIxyBKp2vqLfX5gQGRayl0hBPyLibGlfvWd3UrCCbajxsH922TqFmaMFAwexDr25Q0iVciRnJlvyjborMbi5skSYfkLhGdo0PsJ8kcqD4Nkqy9hrEIZWIEpuhY9kIiIoT3apo03HLl5ijbysUSKBsy3yD5XvqMF1fWD7MCtc7gRlpUcY8RocCOtLg5veG6WpvGW6pYnjSubRiXoK7veNBOcUcaI8eNHf9EOaCPOcEilIiIoT3apo03HLl5ijbysUSKBsy3yD5XvqMF1fWD7MCtc7gRlpUcY8RocCWHovAKxraQd)ubcR)i3KWsfSIe7qUxdvWvaqKN4mSO3dfGlfvWdzj3KWUX6YJRGScc0PsJ8kcqD4Nkqy9x(ENqJ8kRoHvhY96EclTRRooiqNknYRia1HFQaH1FBwGk0b7qUx3tyPDD9)ab6uPrEfbOo8tfiS(BJvAmHzhY9k5Me2nwxECfexxDb6uPrEfbOo8tfiS(JKlPWEB7wOpg6uPrEfbOo8tfiS(JiHvm0PsJ8kcqD4Nkqy9xibFGzxeAIe3EKymjVQ)idiYacioUm)v7btXvwlK2lv8KF4GhqZFbnknYRGgrscca0z7fjji9S2JI1A0Z6pG2ZApxkQGh932tXzW4uBp9oX4aRa2jJL2II1AaG5NMfbACfAKP9knYRApjxsH922TqFCh9hz6zTNlfvWJ(B7P4myCQTNENyCGva7KXsBrXAnaW8tZIanRqdiTxPrEv7ZAZ4sfwsGtK5o6pU0ZAVsJ8Q2VtglTffR1O9CPOcE0F7O)4OEw75srf8O)2EkodgNA7hxaStglTffR1aiskYzT0ELg5vTpFVtOrELvNWAh9hP0ZApxkQGh932tXzW4uB)4cGDYyPTOyTgarsroRL2R0iVQ9zTzCPcljWjYCh9N)QN1EUuubp6VTNIZGXP2(Xfa7KXsBrXAnaIKICwlTxPrEv7j5skS32Uf6J7OJ2p4TojIEw)b0Ew7vAKx1(rsWtYJ2ZLIk4r)TJ(Jm9S2R0iVQ90Ritp2(0LK2EUuubp6VD0FCPN1ELg5vThZiXycBF6ssBpxkQGh93o6poQN1EUuubp6VTxPrEv7PQqyvAKxzfjjAVijHT0h3EuSwJo6psPN1EUuubp6VTxPrEv7PQqyvAKxzfjjAVijHT0h3(bV5IKiXKo6p)vpR9CPOcE0FBVsJ8Q2tvHWQ0iVYkss0ErscBPpU907eJdSI0r)5)6zTNlfvWJ(B7vAKx1EQkewLg5vwrsI2lssyl9XTVo8tfD0r7LJz69q1ON1FaTN1ELg5vTx(f5vTNlfvWJ(Bh9hz6zTNlfvWJ(B7l9XTxLAIefRe7(QWEBR8dmg3ELg5vTxLAIefRe7(QWEBR8dmg3rhTNENyCGvKEw)b0Ew7vAKx1E5xKx1EUuubp6VD0FKPN1EUuubp6VTNIZGXP2(5cnJlaizTNewuSwdGiPiN1s7vAKx1Esw7jHffR1OJ(Jl9S2R0iVQ9He2kzQI2ZLIk4r)TJ(JJ6zTxPrEv733yWyBC2qcB3c9XTNlfvWJ(Bh9hP0ZAVsJ8Q2ZcPjPw2btXm3EUuubp6VD0F(REw75srf8O)2EkodgNA7reAMl0mUaGEfLRaRbpSBH(yl6eUaIKICwlqJSqZCHgLg5va0ROCfyn4HDl0hdKLDlYfjb042n0SNeclMPsu8cBJ8XqJRqZcDa80)bnG3ELg5vTNEfLRaRbpSBH(4o6p)xpR9CPOcE0FBpfNbJtT9Ot7nGi3mQ4UbajukYqJRqJlTxPrEv7b7WIbsCwwmtUslk3r)XX6zTxPrEv7F87WsBVTvmrZHDGz9rApxkQGh93o6poEpR9CPOcE0FBpfNbJtT9HIx4aiYhBJZosgACfAafqkqJB3qdIqdIqtO4foaKWQiKaiNgqZ8qJJbc042n0ekEHdajSkcjaYPb046k0idiqd4qJSqdIqJsJej2Yf)sManRqdOqJB3qZoxKewm)0SiqZ8qJmoo0ao0ao042n0Gi0ekEHdGiFSnoRCAyLbeOzEOXfqGgzHgeHgLgjsSLl(LmbAwHgqHg3UHMDUijSy(PzrGM5Hgh5iObCOb82R0iVQ9ywLN1IDl0ht6O)aki9S2R0iVQ9syfhwMq4IYTNlfvWJ(Bh9hqbTN1EUuubp6VTxPrEv7PstfxGVkPwuHsI2tXzW4uBp60Ed843HL2EBRyIMd7aZ6JamoWQ2Z7ntdBPpU9uPPIlWxLulQqjrh9hqLPN1EUuubp6VTxPrEv7vIeK0IjwSk1h2spSkApfNbJtT9dgDAVbWQuFyl9WQWoy0P9gyCGvqJB3qZGrN2Ba6vJjAKiX2Sq2oy0P9gyso0il0ekEHdajSkcjaYPb04k04cOqJB3qtO4foaI8X24SJKHgxHgzaP9L(42RejiPftSyvQpSLEyv0r)bux6zTxPrEv7NiSnd(rApxkQGh93o6O9dEZfjrIj9S(dO9S2ZLIk4r)T9uCgmo12hAHCwlqJSqdIqdIqZEsiSyMkrXlSnYhdnUcnGcnYcnzrVxwl2H(0f26cbAahAC7gAqeAuAKiXwU4xYeOzEOXfOrwOjl69YAXo0NUWwxiqJSqd60Edm43vwI8ezMamoWkObCOXTBObrOjl69YAXo0NUWwPqGM5HgqaKrkqJufAKWQiKa80)bnGdnG3ELg5vTFWVRSe5jYmPJ(Jm9S2ZLIk4r)T9uCgmo12Ji0O0irITCXVKjqZ8qJlqJSqtw07L1IDOpDHTUqGgzHg0P9gyWVRSe5jYmbyCGvqd4qJB3qdIqtw07L1IDOpDHTsHanZdnGa4iOrQcnsyvesaE6)GgWBVsJ8Q2tUjHfvX4KXD0FCPN1EUuubp6VTNIZGXP2EjSkcjaYzmLRaACfAKciTxPrEv7rNeiB5)fyLg5vD0FCupR9knYRA)Jd9Dy5sossApxkQGh93o6psPN1ELg5vTFNmwAlkwRr75srf8O)2rhTVo8tf9S(dO9S2ZLIk4r)T9uCgmo12VNeclMPsu8cBJ8XqJRqdOqJSqdIqZCHMqfCfaBH(ylfRejaCPOcEanUDdnicnJlai5skS32Uf6JbW8tZIanUcnUanYcnZfAuAKxbK1MXLkSKaNiZaKCjfw5cLYdObCOb82R0iVQ9zTzCPcljWjYCh9hz6zTNlfvWJ(B7P4myCQThrObrObDAVbECOVdlxYrscWKCOrwOHCtc7gRlpUcc0m)k04c0ao042n0qUjHDJ1LhxbbAMFfACe0aE7vAKx1EI8eNHf9EOD0FCPN1EUuubp6VTNIZGXP2EeHM5cnHk4kaiYtCgw07HcWLIk4b0il0Gi0Gi0GoT3apo03HLl5ijbyso0il0qUjHDJ1LhxbbAMFfACbAahAC7gAi3KWUX6YJRGanZVcnocAahAaV9knYRAp5MewQGvK4o6poQN1EUuubp6VTNIZGXP2(qfCfae5jodl69qb4srf8aAKfAi3KWUX6YJRGanRqdiTxPrEv7j3KWsfSIe3r)rk9S2ZLIk4r)T9uCgmo12VNWsdnUUcnooiTxPrEv7Z37eAKxz1jS2r)5V6zTNlfvWJ(B7P4myCQTFpHLgACDfA(pqAVsJ8Q2VzbQqhCh9N)RN1EUuubp6VTNIZGXP2EYnjSBSU84kiqJRRqJlTxPrEv73yLgtyUJ(JJ1ZAVsJ8Q2tYLuyVTDl0h3EUuubp6VD0FC8Ew7vAKx1EIewXTNlfvWJ(Bh9hqbPN1ELg5vTpKGpWSlcnrIBpxkQGh93o6OJ2RtHKd3EF(()6OJUb]] )

end
