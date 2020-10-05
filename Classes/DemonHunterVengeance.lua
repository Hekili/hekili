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


    spec:RegisterPack( "Vengeance", 20200926, [[dieNAaqifsEKQuztcuJsGCkb0QqGQxPQYSquDlvPQQDb4xQsggc5yQszzcWZisMgrQUgrkBdb03uLQmoerDoeG1PkvfZtH4EQI9HiSqfQhQqkAIkKQlQkvL2OQuvzKiqXjvifwjrStb1srGspLstvq2QcP0EP6Vumyv6WKwmqpgQjl0LrTzf9zvLrtuoTKxJqnBKUTk2TOFR0WjQwoONdz6sDDfSDePVJGgpcKZJOSEerMVQQ2pH938qUnQn7HdGOaiIiciaceGicq6KS0FZTnzYz3kxXeRFSBt9WUD0Y5hRjMDRCLm6QrpKBr7aeZUvw3YrVpVE9vTSbqa8EEHQZav7AtmuN9luDWVCl4qr7rJ0bDBuB2dharbqereqaeiareG0jzPia3IKZypS0i53CRSkg50bDBKry3(oXD05ZMIlbZq2muChTC(XAIzHK3jUwwEZhqgkUbqGKlUbquae5w5WDwu2TVtChD(SP4sWmKndf3rlNFSMywi5DIRLL38bKHIBaei5IBaefarcjcjVtCTPkhjBBXfQvuCbhMtokUOwBK4cYZfYIlEpGAlUG8xLiXvZO4khYV)Y3UR8tClK4g3KbesuCxBIaKdz8Ea1(3ZluQYrY22GATrcjkURnraYHmEpGA)75L8TRnfsuCxBIaKdz8Ea1(3ZRbeBQMpKN6HFuscjtHkYm3Sn70iFjKHcjcjVtCFFjigp0CuCzszizIBxhwCBzS4Q4EHIBHexLuTOkiLbesuCxBIEIfcoiVfsuCxBI(98cVjA4WMJ(vyHef31MOFpVGmPmeXMJ(vyHef31MOFpVWkLAuCxBAOfQjp1d)ac1mkKO4U2e975fwPuJI7AtdTqn5PE4Nip5evKYiHef31MOFpVWkLAuCxBAOfQjp1d)G3LgxctKqII7At0VNxyLsnkURnn0c1KN6HFYfEuQqIqY7e33VIHKjUJHAgfxc2T1U2uirXDTjcaeQz8bvFf1StZKQhM8A(G3LgxctGzXqYmGqnJaq(OvIgjaHef31MiaqOMXFpVQCYWuPgudlIzYR5dExACjmbMfdjZac1mca5Jwj6HiHef31MiaqOMXFpVMfdjZac1mkKO4U2ebac1m(75vDolv7AtJoavYR5tCBGzXqYmGqnJaDHjUYpHef31MiaqOMXFpVQCYWuPgudlIzYR5tCBGzXqYmGqnJaDHjUYpHef31MiaqOMXFpVq1xrn70mP6HjVMpXTbMfdjZac1mc0fM4k)esesuCxBIaW7sJlHj6r(21McjkURnra4DPXLWe975fQY5a1ac1msEnFgvCBauLZbQbeQzeOlmXv(jKO4U2ebG3Lgxct0VNxTm2iBiBHef31Mia8U04syI(98AUXidn9AAzSzs1dlKO4U2ebG3Lgxct0VNxmLmuPPjYyiZcjkURnra4DPXLWe975fEtmNnuBoAMu9WKxZNGgvCBa8MyoBO2C0mP6HnGdWeOlmXv(f8OuCxBcG3eZzd1MJMjvpmqLMjT(K1))phOudKXYu4hB66WJ8HJahLGcuirXDTjcaVlnUeMOFpViCH0iPCLgiJ2utmtEnFahMtaAnzq6UrauRyIhrkHef31Mia8U04syI(986WNfsMzNg6aUIMiK1dsi5DI7OZtDG2I7uPuqftS4oxO4oGuqklUmcXjMracjkURnra4DPXLWe975LmwHTHrioXSqII7AteaExACjmr)EEnGyt18HCEozCBs9WpyYW0THBwydivrn518bCyobo8zHKz2PHoGROjcz9GaIlHPqII7AteaExACjmr)EEnGyt18H8up8JIKrQMmYavsAHg8cvk518jYGdZjaujPfAWluPMidomNaXLW8))idomNa4nJd4UiLnvsSjYGdZjWG8GBf(XnGmwPTma54EePE7))wHFCd01Hn9AIfpsaejK8oXD05PoqBXDQukOIjwCNluChqkiLf3Q5dcqirXDTjcaVlnUeMOFpVgqSPA(GesesEN4o68KturkJesuCxBIaI8KturkJEI8ztdsErmJiVMpbnhOudKXYu4hB66WJ8wWvI3tLFMOE0p2ifkW))dsXDrkB4KpfJiHubxjEpv(zI6r)yJuOGbhMtGiF20GKxeZiG4syg4))bvjEpv(zI6r)yJ0qKGiGaKgbxgR0wgWrjOafsuCxBIaI8KturkJ(98cTdudOcHfdjVMpbP4UiLnCYNIrKqQGReVNk)mr9OFSrkuWGdZjqKpBAqYlIzeqCjmd8))GQeVNk)mr9OFSrAisqeG0j4YyL2YaokbfOqII7AteqKNCIksz0VNxGduInmb1qf31MKxZhzSsBzaYziMZEePrKqII7AteqKNCIksz0VNxhU1ZcLlBrfsirXDTjciYtorfPm63ZRzXqYmGqnJcjcjVtCdVWJsfxc2T1U2uirXDTjcix4rPpvozyQudQHfXm518zoqPgiJLPWp201Hh5TGdAuTs5SbMu9WgmurYa4ubPC8))GIBdGQVIA2Pzs1dda5JwjAePcEukURnbQCYWuPgudlIzau9vuJCQI5yGbkKO4U2ebKl8O0FpVqYly1gW9asEnFckiWH5e4WTEwOCzlQqadYdgTduZeQFhoBejEKkW))r7a1mH63HZgrIhPhOqII7AteqUWJs)98cTdudMYkPm518jOr1kLZgajVGvBa3diaNkiLJbhuqGdZjWHB9Sq5YwuHagKhmAhOMju)oC2is8ivG))J2bQzc1VdNnIepspWafsuCxBIaYfEu6VNxODGAWuwjLjVMpTs5SbqYly1gW9acWPcs5yWODGAMq97WzJEisirXDTjcix4rP)EEvNZs1U20OdqL8A(mhGKnYdbqKqII7AteqUWJs)98AYuqQgzYR5ZCas2ipVhrcjkURnra5cpk93ZRjuX9aKjVMpODGAMq97WzJg5rkHef31MiGCHhL(75fQ(kQzNMjvpSqII7AteqUWJs)98cjJvOqII7AteqUWJs)98QLbxcnFuTiLDlPmevB6HdGOaiIisoasg4n3sOcZk)qUD04iFHnhfxcuCvCxBkU0c1iaHe3sluJ8qUfeQz0d5HFZd5wovqkh9XUfdRMHL6w8U04sycmlgsMbeQzeaYhTsK4oI4gGBvCxB6wu9vuZontQEyV9Wb4HClNkiLJ(y3IHvZWsDlExACjmbMfdjZac1mca5JwjsCFexICRI7At3w5KHPsnOgweZE7HLYd5wf31MUDwmKmdiuZOB5ubPC0h7Thw6Ei3YPcs5Op2Tyy1mSu3g3gywmKmdiuZiqxyIR8ZTkURnDBDolv7AtJoavV9WsZd5wovqkh9XUfdRMHL6242aZIHKzaHAgb6ctCLFUvXDTPBRCYWuPgudlIzV9WeOhYTCQGuo6JDlgwndl1TXTbMfdjZac1mc0fM4k)CRI7At3IQVIA2Pzs1d7T3UnYtDG2Eip8BEi3Q4U20TXcbhK3ULtfKYrFS3E4a8qUvXDTPBXBIgoS5OFf2TCQGuo6J92dlLhYTkURnDlKjLHi2C0Vc7wovqkh9XE7HLUhYTCQGuo6JDRI7At3Ivk1O4U20qlu7wAHAtQh2TGqnJE7HLMhYTCQGuo6JDRI7At3Ivk1O4U20qlu7wAHAtQh2TrEYjQiLrE7HjqpKB5ubPC0h7wf31MUfRuQrXDTPHwO2T0c1MupSBX7sJlHjYBp875HClNkiLJ(y3Q4U20TyLsnkURnn0c1ULwO2K6HDBUWJs92B3khY49aQThYd)MhYTCQGuo6J92dhGhYTkURnDR8TRnDlNkiLJ(yV9Ws5HClNkiLJ(y3M6HDRssizkurM5MTzNg5lHm0TkURnDRssizkurM5MTzNg5lHm0BVDlExACjmrEip8BEi3Q4U20TY3U20TCQGuo6J92dhGhYTCQGuo6JDlgwndl1TJsCJBdGQCoqnGqnJaDHjUYp3Q4U20TOkNdudiuZO3EyP8qUvXDTPBBzSr2q2ULtfKYrFS3EyP7HCRI7At3o3yKHMEnTm2mP6HDlNkiLJ(yV9WsZd5wf31MULPKHknnrgdz2TCQGuo6J92dtGEi3YPcs5Op2Tyy1mSu3gK4okXnUnaEtmNnuBoAMu9WgWbyc0fM4k)e3Gf3rjUkURnbWBI5SHAZrZKQhgOsZKwFYAX9)FXDoqPgiJLPWp201Hf3re3pCe4OeK4gOBvCxB6w8MyoBO2C0mP6H92d)EEi3YPcs5Op2Tyy1mSu3comNa0AYG0DJaOwXelUJiUs5wf31MULWfsJKYvAGmAtnXS3Eys2d5wf31MU9WNfsMzNg6aUIMiK1dYTCQGuo6J92dtaEi3Q4U20TYyf2ggH4eZULtfKYrFS3E43iYd5wovqkh9XUvXDTPBXKHPBd3SWgqQIA3IHvZWsDl4WCcC4ZcjZStdDaxrteY6bbexct3YZjJBtQh2TyYW0THBwydivrT3E43EZd5wovqkh9XUvXDTPBvKms1KrgOssl0GxOsDlgwndl1TrgCyobGkjTqdEHk1ezWH5eiUeMI7))IBKbhMta8MXbCxKYMkj2ezWH5eyqU4gS42k8JBazSsBzaYXT4oI4k1BI7))IBRWpUb66WMEnXIf3re3aiYTPEy3QizKQjJmqLKwObVqL6Th(Ta8qUvXDTPBhqSPA(GClNkiLJ(yV92TrEYjQiLrEip8BEi3YPcs5Op2Tyy1mSu3gK4ohOudKXYu4hB66WI7iI7BIBWIBL49u5NjQh9JnsHe3af3))f3Gexf3fPSHt(umsCjH4kL4gS4wjEpv(zI6r)yJuiXnyXfCyobI8ztdsErmJaIlHP4gO4()V4gK4wjEpv(zI6r)yJ0qIljexIacqAIlbxCLXkTLbCucsCd0TkURnDBKpBAqYlIzK3E4a8qULtfKYrFSBXWQzyPUniXvXDrkB4KpfJexsiUsjUblUvI3tLFMOE0p2ifsCdwCbhMtGiF20GKxeZiG4sykUbkU))lUbjUvI3tLFMOE0p2inK4scXLiaPlUeCXvgR0wgWrjiXnq3Q4U20TODGAaviSyO3EyP8qULtfKYrFSBXWQzyPUvgR0wgGCgI5Sf3rexPrKBvCxB6wWbkXgMGAOI7AtV9Ws3d5wf31MU9WTEwOCzlQqULtfKYrFS3EyP5HCRI7At3olgsMbeQz0TCQGuo6J92B3Ml8OupKh(npKB5ubPC0h7wmSAgwQBNduQbYyzk8JnDDyXDeX9nXnyXniXDuIBRuoBGjvpSbdvKmaovqkhf3))f3Ge342aO6ROMDAMu9Waq(OvIe3rexPe3Gf3rjUkURnbQCYWuPgudlIzau9vuJCQI5O4gO4gOBvCxB62kNmmvQb1WIy2BpCaEi3YPcs5Op2Tyy1mSu3gK4gK4comNahU1ZcLlBrfcyqU4gS4I2bQzc1VdNnsCjXJ4kL4gO4()V4I2bQzc1VdNnsCjXJ4kDXnq3Q4U20Ti5fSAd4Ea92dlLhYTCQGuo6JDlgwndl1TbjUJsCBLYzdGKxWQnG7beGtfKYrXnyXniXniXfCyoboCRNfkx2IkeWGCXnyXfTduZeQFhoBK4sIhXvkXnqX9)FXfTduZeQFhoBK4sIhXv6IBGIBGUvXDTPBr7a1GPSsk7Thw6Ei3YPcs5Op2Tyy1mSu32kLZgajVGvBa3diaNkiLJIBWIlAhOMju)oC2iX9rCjYTkURnDlAhOgmLvszV9WsZd5wovqkh9XUfdRMHL625aKmXDKhXLaiYTkURnDBDolv7AtJoavV9WeOhYTCQGuo6JDlgwndl1TZbizI7ipI77rKBvCxB62jtbPAK92d)EEi3YPcs5Op2Tyy1mSu3I2bQzc1VdNnsCh5rCLYTkURnD7eQ4EaYE7HjzpKBvCxB6wu9vuZontQEy3YPcs5Op2Bpmb4HCRI7At3IKXk0TCQGuo6J92d)grEi3Q4U20TTm4sO5JQfPSB5ubPC0h7T3E7wDOLTq3ARZOP3E7o]] )

end
