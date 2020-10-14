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
            duration = function () return ( level > 53 or azerite.revel_in_pain.enabled ) and 10 or 8 end,
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


    spec:RegisterPack( "Vengeance", 20201013, [[dqe5Caqifv6rQQInHQ0OaQofeSkuvrVccnluvULQQQyxa(LQkddiogqzzujEgQOPHk01qfSnvvjFtvvLXHQQCofv06qvvP5rL09us7trvhuvvvAHQk9qvvvLjQQk1fvvvvTruvvmsuvvDsuvbRKkANQk(jQQqlvrf8uQAQkkBvrfAVs9xknykomPfdPhJ0Kv4YeBwP(SsmAuPtl61qKzJYTvLDl53QmCQWYH65iMUW1vKTdr9DG04vvvopQI1JQknFQu7h0ny9S2p0q6pUaIlGagiGXjai8hhaJJU0(Ghhs7DOuK0fP9L(K2phLAr0IkT3HYd70rpR9KBctL2Znche(3F)wYG7eka9E)i5BIPrEffR74hjF0FThDkzb)q1OTFOH0FCbexabmqaJtaq4poaghbR9ehcT)Wb(dS2ZnhdPA02pecT9)bA(B5Df0W)NQqWqZCuQfrlQaD(hOHFKghQGHgW4KpOXfqCbK27aF7KjT)pqZFlVRGg()ufcgAMJsTiArfOZ)an8J04qfm0agN8bnUaIlGaDcD(hOXxQdc3lGgSMdObDAVLb0qcniqdQSpSan07HQb0GklzrGgTgqJdS8)44IiRfOjjqZ4kba6uPrEfbWbwO3dvdex)nreBgYJVsFYQYVeUkwj29vH92whhOcg6e68pqZ)))e6uidOrqwW8anr(eOj4kqJsJddnjbAuK1KPOmba6uPrEfzDKe8KJa6uPrEfbX1F0RitpX(0LKcDQ0iVIG46pSGSGjI9Pljf6uPrEfbX1FuLXSknYRSSKe8v6twrXAnGovAKxrqC9hvzmRsJ8klljbFL(K1HSLIKileOtLg5veex)rvgZQ0iVYYssWxPpzLEhBCGweOtLg5veex)rvgZQ0iVYYssWxPpzTo8tzqNqN)bA4FsbZd08fR1aAMdxOrEf0PsJ8kcakwRXkjxsM922ntFcF5ELEhBCGwa7uW8yrXAnaWYtZI4QlqNknYRiaOyTgiU(lRTGlLzjbors4l3R07yJd0cyNcMhlkwRbawEAwKvqGovAKxraqXAnqC93ofmpwuSwdOtLg5veauSwdex)LV3X0iVYQtyLVCVoUayNcMhlkwRbqKuKYAb6uPrEfbafR1aX1FzTfCPmljWjscF5EDCbWofmpwuSwdGiPiL1c0PsJ8kcakwRbIR)i5sYS32Uz6t4l3RJla2PG5XII1AaejfPSwGoHovAKxraO3XghOfz1Xf5vqNknYRia07yJd0IG46psw7jMffR1GVCVo3XfaKS2tmlkwRbqKuKYAb6uPrEfbGEhBCGweex)fCfl3PkGovAKxraO3XghOfbX1F7BmeSnoBWvSBM(eOtLg5vea6DSXbArqC9NW4HKAzhcflc0PsJ8kca9o24aTiiU(JEfvQaRHmSBM(e(Y9k4ZDCba9kQubwdzy3m9jw0jCbejfPSw4DUknYRaOxrLkWAid7MPpbil7MLlCd3U3tmMfluUkErSr(exxOdGN(peGovAKxraO3XghOfbX1FGEy2azjllwixPfv4l3ROt7nal3ck7UbajuksUYj0PsJ8kca9o24aTiiU(7jVdZJ92w2enh2bw0hb68pqd))ydOzoiQJSwGg(hM(ec0Spm0i)tOtHanyTweO5WqdsjJbnOt7nHpOj3qJJJqsuMaan)VmqvEiqtG5bAIdAwKaAcUc0Woqfsan07yJd0cAqvImGMRGgfznzkktGgPKxkeaOtLg5vea6DSXbArqC9hwuhzTy3m9je(Y9AO4fjaI8j24SJuCfmao42n4GhkErcaUIYcUaoOX88hiUDhkErcaUIYcUaoOHRRUacc8cUsJezXkL8sHScMB37CHByXYtZImVlZjci42n4HIxKaiYNyJZ6GgwxazEobHxWvAKilwPKxkKvWC7ENlCdlwEAwK55ihrabOZ)an)TS1jwanBLXqvksqZ(WqZerrzc0ieIuuHaaDQ0iVIaqVJnoqlcIR)4kkoScHifvGovAKxraO3XghOfbX1FteXMH84t2BHg2sFYkLhk7c8vj1IYusWxUxrN2BGN8omp2BBzt0CyhyrFeGXbAbDQ0iVIaqVJnoqlcIR)MiInd5XxPpzvjCrwlHyXk)Eyl9WkJVCVoe0P9gaR87HT0dRm7qqN2BGXbA529qqN2Ba6vJjAKil2SqYoe0P9gyYbVHIxKaGROSGlGdA4kNG52DO4fjaI8j24SJuC1fqGo)d083YwNyb0SvgdvPibn7ddntefLjqtgYJaaDQ0iVIaqVJnoqlcIR)MiInd5rGoHo)d083YwksISqGovAKxragYwksISqwhY7klXrIKq4l3RHwiL1cVGd(EIXSyHYvXlInYN4ky8Mf9EzTyh6txelNeeC7gCLgjYIvk5LczEo5nl69YAXo0NUiwoj8IoT3ad5DLL4irsiaJd0cb3Ubpl69YAXo0NUiwoqMheax4a)KROSGlWt)hciaDQ0iVIamKTuKezHG46pYnXSOkgNcMVCVcUsJezXkL8sHmpN8Mf9EzTyh6txelNeErN2BGH8UYsCKijeGXbAHGB3GNf9EzTyh6txelhiZdcah5NCfLfCbE6)qa6uPrEfbyiBPijYcbX1FOtmKSY)cSsJ8k(Y9kxrzbxahcMkv4khab6uPrEfbyiBPijYcbX1Fpj03HDW9ijb6uPrEfbyiBPijYcbX1F7uW8yrXAnGoHo)d085WpLbnZHl0iVc6uPrEfbOo8tzRzTfCPmljWjscF5EDpXywSq5Q4fXg5tCfmEbFUHYKka2m9jwkwjCbKsrzYWTBWhxaqYLKzVTDZ0NaGLNMfXvo5DUknYRaYAl4szwsGtKeasUKmRdMsLbciaDQ0iVIauh(Pmex)rCK4mSO3dLVCVco4Ot7nWtc9DyhCpssaMCWl5My2nwxEsfK5x5eb3Uj3eZUX6YtQGm)khra6uPrEfbOo8tziU(JCtmlLjkYcF5Ef85gktQaG4iXzyrVhkGukktg8co4Ot7nWtc9DyhCpssaMCWl5My2nwxEsfK5x5eb3Uj3eZUX6YtQGm)khrabOtLg5veG6WpLH46pYnXSuMOil8L71qzsfaehjodl69qbKsrzYGxYnXSBSU8KkiRGaDQ0iVIauh(Pmex)LV3X0iVYQtyLVCVUNW8466Ccc0PsJ8kcqD4NYqC93wyOmDi8L719eMhxx)pqGovAKxraQd)ugIR)2yLgtyHVCVsUjMDJ1LNubX1voHovAKxraQd)ugIR)i5sYS32Uz6tGovAKxraQd)ugIR)iCffdDQ0iVIauh(Pmex)fCXhO2fMMilThzbtYR6pUaIlGagiGbw7bvXvwlK2Zp8CC4qgqZFbnknYRGgwscca0z71PG7HBVpF)FTNLKG0ZApkwRrpR)awpR9sPOmz0FBpfNHGtT907yJd0cyNcMhlkwRbawEAweOXvOXL2R0iVQ9KCjz2BB3m9jD0FCPN1EPuuMm6VTNIZqWP2E6DSXbAbStbZJffR1aalpnlc0ScnG0ELg5vTpRTGlLzjbors6O)WzpR9knYRA)ofmpwuSwJ2lLIYKr)TJ(dh7zTxkfLjJ(B7P4meCQTFCbWofmpwuSwdGiPiL1s7vAKx1(89oMg5vwDcRD0F4qpR9sPOmz0FBpfNHGtT9Jla2PG5XII1AaejfPSwAVsJ8Q2N1wWLYSKaNijD0F(REw7LsrzYO)2EkodbNA7hxaStbZJffR1aiskszT0ELg5vTNKljZEB7MPpPJoA)q26el6z9hW6zTxPrEv7hjbp5iAVukktg93o6pU0ZAVsJ8Q2tVIm9e7txsA7LsrzYO)2r)HZEw7vAKx1ESGSGjI9PljT9sPOmz0F7O)WXEw7LsrzYO)2ELg5vTNQmMvPrELLLKO9SKe2sFs7rXAn6O)WHEw7LsrzYO)2ELg5vTNQmMvPrELLLKO9SKe2sFs7hYwksISq6O)8x9S2lLIYKr)T9knYRApvzmRsJ8klljr7zjjSL(K2tVJnoqlsh9N)RN1EPuuMm6VTxPrEv7PkJzvAKxzzjjApljHT0N0(6WpL1rhT3bwO3dvJEw)bSEw7LsrzYO)2(sFs7v(LWvXkXUVkS3264avWTxPrEv7v(LWvXkXUVkS3264avWD0r7P3XghOfPN1FaRN1ELg5vT3Xf5vTxkfLjJ(Bh9hx6zTxkfLjJ(B7P4meCQTFUqZ4casw7jMffR1aiskszT0ELg5vTNK1EIzrXAn6O)WzpR9knYRAFWvSCNQO9sPOmz0F7O)WXEw7vAKx1(9ngc2gNn4k2ntFs7LsrzYO)2r)Hd9S2R0iVQ9cJhsQLDiuSiTxkfLjJ(Bh9N)QN1EPuuMm6VTNIZqWP2EWHM5cnJlaOxrLkWAid7MPpXIoHlGiPiL1c0Wl0mxOrPrEfa9kQubwdzy3m9jazz3SCHBanUDdn7jgZIfkxfVi2iFc04k0Sqhap9FqdcTxPrEv7PxrLkWAid7MPpPJ(Z)1ZAVukktg932tXzi4uBp60EdWYTGYUBaqcLIe04k0Wz7vAKx1EqpmBGSKLflKR0IkD0F4VEw7vAKx1(N8omp2BBzt0CyhyrFK2lLIYKr)TJ(ZC2ZAVukktg932tXzi4uBFO4fjaI8j24SJuGgxHgWa4a042n0ao0ao0ekErcaUIYcUaoOb0mp0WFGanUDdnHIxKaGROSGlGdAanUUcnUac0Ga0Wl0ao0O0irwSsjVuiqZk0ag042n0SZfUHflpnlc0mp04YCcnianianUDdnGdnHIxKaiYNyJZ6GgwxabAMhA4eeOHxObCOrPrISyLsEPqGMvObmOXTBOzNlCdlwEAweOzEOHJCeAqaAqO9knYRApwuhzTy3m9jKo6pGbspR9knYRApxrXHviePOs7LsrzYO)2r)bmW6zTxkfLjJ(B7vAKx1Ekpu2f4RsQfLPKO9uCgco12JoT3ap5DyES32YMO5WoWI(iaJd0Q9YEl0Ww6tApLhk7c8vj1IYus0r)bmx6zTxkfLjJ(B7vAKx1ELWfzTeIfR87HT0dRS2tXzi4uB)qqN2BaSYVh2spSYSdbDAVbghOf042n0me0P9gGE1yIgjYInlKSdbDAVbMCan8cnHIxKaGROSGlGdAanUcnCcg042n0ekErcGiFIno7ifOXvOXfqAFPpP9kHlYAjelw53dBPhwzD0FaJZEw7vAKx1(jIyZqEK2lLIYKr)TJoA)q2srsKfspR)awpR9sPOmz0FBpfNHGtT9HwiL1c0Wl0ao0ao0SNymlwOCv8IyJ8jqJRqdyqdVqtw07L1IDOpDrSCsGgeGg3UHgWHgLgjYIvk5LcbAMhA4eA4fAYIEVSwSd9PlILtc0Wl0GoT3ad5DLL4irsiaJd0cAqaAC7gAahAYIEVSwSd9PlILdeOzEObeax4a0WpHgUIYcUap9FqdcqdcTxPrEv7hY7klXrIKq6O)4spR9sPOmz0FBpfNHGtT9GdnknsKfRuYlfc0mp0Wj0Wl0Kf9EzTyh6txelNeOHxObDAVbgY7klXrIKqaghOf0Ga042n0ao0Kf9EzTyh6txelhiqZ8qdiaCeA4NqdxrzbxGN(pObH2R0iVQ9KBIzrvmofCh9ho7zTxkfLjJ(B7P4meCQTNROSGlGdbtLkGgxHgoas7vAKx1E0jgsw5FbwPrEvh9ho2ZAVsJ8Q2)KqFh2b3JKK2lLIYKr)TJ(dh6zTxPrEv73PG5XII1A0EPuuMm6VD0r7Rd)uwpR)awpR9sPOmz0FBpfNHGtT97jgZIfkxfVi2iFc04k0ag0Wl0ao0mxOjuMubWMPpXsXkHlGukktgqJB3qd4qZ4casUKm7TTBM(eaS80SiqJRqdNqdVqZCHgLg5vazTfCPmljWjscajxsM1btPYaAqaAqO9knYRAFwBbxkZscCIK0r)XLEw7LsrzYO)2EkodbNA7bhAahAqN2BGNe67Wo4EKKam5aA4fAi3eZUX6YtQGanZVcnCcnianUDdnKBIz3yD5jvqGM5xHgocni0ELg5vTN4iXzyrVhAh9ho7zTxkfLjJ(B7P4meCQThCOzUqtOmPcaIJeNHf9EOasPOmzan8cnGdnGdnOt7nWtc9DyhCpssaMCan8cnKBIz3yD5jvqGM5xHgoHgeGg3UHgYnXSBSU8KkiqZ8RqdhHgeGgeAVsJ8Q2tUjMLYefzPJ(dh7zTxkfLjJ(B7P4meCQTpuMubaXrIZWIEpuaPuuMmGgEHgYnXSBSU8KkiqZk0as7vAKx1EYnXSuMOilD0F4qpR9sPOmz0FBpfNHGtT97jmpqJRRqZCcs7vAKx1(89oMg5vwDcRD0F(REw7LsrzYO)2EkodbNA73tyEGgxxHM)dK2R0iVQ9BHHY0H0r)5)6zTxkfLjJ(B7P4meCQTNCtm7gRlpPcc046k0Wz7vAKx1(nwPXew6O)WF9S2R0iVQ9KCjz2BB3m9jTxkfLjJ(Bh9N5SN1ELg5vTNWvuC7LsrzYO)2r)bmq6zTxPrEv7dU4du7cttKL2lLIYKr)TJo6OJo6ga]] )

end
