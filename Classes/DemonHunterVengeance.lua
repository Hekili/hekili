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
                if talent.demonic.enabled then applyBuff( "metamorphosis", 6 ) end
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

            readyTime = function ()
                if settings.infernal_charges == 0 then return end
                return ( ( 1 + settings.infernal_charges ) - cooldown.infernal_strike.charges_fractional ) * cooldown.infernal_strike.recharge
            end,

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
                addStack( "soul_fragments", nil, level > 19 and 2 or 1 )
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


    spec:RegisterSetting( "infernal_charges", 1, {
        name = "Reserve |T1344650:0|t Infernal Strike Charges",
        desc = "If set above zero, the addon will not recommend |T1344650:0|t Infernal Strike if it would leave you with fewer charges.",
        icon = 1344650,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 2,
        step = 0.1,
        width = 1.5
    } )


    spec:RegisterPack( "Vengeance", 20201016, [[dqe2DaqiPcEKQQyteHrbuDkG0QiIQEfe1SikDlIOK2fGFbeddcoMQklJkLNruzAev5Aer2MQQ03uvvACQQkoNuHADerPmpQuDpL0(Kk6GerjwOQspKOQstKikUiruQ2iruXijQQ6KevvSsQODQQ4NerLwQuH4Pu1uLkTvPcP9Q4VuAWuCyslgspgPjlLlJAZk1NLQgnr60cVgImBc3wv2TKFRYWPclhQNJy6IUUsSDGY3HqJxvv15jkwprvz(uj7h0ZVP74BAYZh3qWne(HWV)c873pjj3FhFkJdE8ouksApp(sF847OC1ZAr5X7qLrCAB6oEYTGP84LMPdIKnqaPpsPlOa07bcjElcnJROyDNGqIhfKXJUeIu(Pg0X30KNpUHGBi8dHF)f43VFYtsUnEIdMoFK0)8B8sJwJRbD8nMqh)FGgjd)UcAK)lvYyOPJYvpRfLHo)d0i5sZdLXqZV)kl04gcUHW4DGVDi4X)hOrYWVRGg5)sLmgA6OC1ZArzOZ)ansU08qzm087VYcnUHGBiaDcD(hOXxQdI0lHgSgnObDzV5g0qsnjqdkVpmdn07HQj0GY9rrGgTAqJdmlz1XLzu9qtqGM2vma0PsZ4kcGdmtVhQMiVcYcHTrYpzl9XRQ8rKQyLy3xL2BBDCiYyOtOZ)ans2)ptxsUbnmymwgOjJhdnPugAuAEyOjiqJcMgcfvWaqNknJRiRTGGxCKqNknJRiiVcc9kYYJTpTpOqNknJRiiVccMbJXe2(0(GcDQ0mUIG8kiuviSknJRSIGKYw6JxrXA1GovAgxrqEfeQkewLMXvwrqszl9XRnEZfjaJjqNknJRiiVccvfcRsZ4kRiiPSL(4v6DI2HyrGovAgxrqEfeQkewLMXvwrqszl9XR1HFQa6e68pqJKtWyzGMVyTAqth5snJRGovAgxraqXA1wjrFiS32Uf6JLn2R07eTdXcyhmwglkwRgaMFAue3Dd6uPzCfbafRvd5vqIAZ4sfwsIdKyzJ9k9or7qSa2bJLXII1QbG5Ngfzfbj6aj6dH1HqPCd6uPzCfbafRvd5vq2bJLXII1QbDQ0mUIaGI1QH8kiX7DcnJRS6cwLn2RTlb2bJLXII1QbKbfPO6HovAgxraqXA1qEfKO2mUuHLK4ajw2yV2UeyhmwglkwRgqguKIQh6uPzCfbafRvd5vqirFiS32Uf6JLn2RTlb2bJLXII1QbKbfPO6HoHovAgxraO3jAhIfz1XLXvqNknJRia07eTdXIG8kiKO2lclkwRMSXETdTlbirTxewuSwnGmOifvp0PsZ4kca9or7qSiiVcskLTsxQe6uPzCfbGENODiweKxbzFTgJT5ztPSDl0hdDQ0mUIaqVt0oelcYRGWcziHw2gtXmdDQ0mUIaqVt0oelcYRGqVIYvI1KB2TqFSSXEf8o0UeGEfLReRj3SBH(yl6cUaYGIuu9s0bLMXva0ROCLyn5MDl0hdeLDlIEPPlx7fHWIzQuf3Z2mES790gWt)pOqNknJRia07eTdXIG8kiiEyrdmoklMjxPfLLn2ROl7nGi2mQ4UgajvksUlh0PsZ4kca9or7qSiiVcYJFhwg7TTIfA0SnmRpc05FGg5)jAqthHvhr1dnsoc9XeOzFyOH)ptxsgAWA1ZqZHHgKcHaAqx2BISqtSHghhHeOcgaAKSiquLHanjwgOjpOPNtOjLYqJ4qKjj0qVt0oelObvjCdAUcAuW0qOOcgA4IFbtaGovAgxraO3jAhIfb5vqWS6iQE7wOpMiBSxtf3Zjqgp2MNTfS7)aKKlxGdEQ4EobKYQiLc4GMD(pi4YvQ4EobKYQiLc4GMUV6gcGkb4kndWylx8lyY6pxU2rV00I5NgfPt36yqb1LlWtf3Zjqgp2MN1bnTUHqNYHGeGR0maJTCXVGjR)C5Ah9stlMFAuKoLN8afuOZ)ansgERlIeA2QqGQuKGM9HHMfIIkyOHjeUOmba6uPzCfbGENODiweKxbrkR40Yecxug6uPzCfbGENODiweKxbzHW2i5NS8EZ00w6JxPYqfxIVkOwuHsszJ9k6YEd843HLXEBRyHgnBdZ6Ja0oelOtLMXvea6DI2HyrqEfKfcBJKFYw6JxvIuW0IjwSkFh2spSkKn2RngDzVbWQ8Dyl9WQW2y0L9gODiwUC1y0L9gGEvBHMbySnkKSngDzVbwCirQ4EobKYQiLc4GMUl3pxUsf3Zjqgp2MNTfS7UHa05FGgjdV1frcnBviqvksqZ(WqZcrrfm0ej)iaqNknJRia07eTdXIG8kile2gj)iqNqN)bAKm8MlsagtGovAgxraA8MlsagtwB87klXrGetKn2RPwifvVeGd(EriSyMkvX9SnJh7(pjIIEVO6Tn9P9SvocOUCbUsZam2Yf)cM0PCsef9Er1BB6t7zRCejqx2BGg)UYsCeiXeG2HybQlxGhf9Er1BB6t7zRKiDIaGBssYlLvrkf4P)huqHovAgxraA8MlsagtqEfeYTiSOkghmw2yVcUsZam2Yf)cM0PCsef9Er1BB6t7zRCejqx2BGg)UYsCeiXeG2HybQlxGhf9Er1BB6t7zRKiDIaG8K8szvKsbE6)bf6uPzCfbOXBUibymb5vqqxeiz5)NyLMXvYg7vPSksPaoymLR0DjHa0PsZ4kcqJ3CrcWycYRG84uFh2H0JeeOtLMXveGgV5IeGXeKxbzhmwglkwRg0j05FGMph(PcOPJCPMXvqNknJRia1HFQynQnJlvyjjoqILn2R7fHWIzQuf3Z2mES7)Ka8oKQGReyl0hBPyLifGlfvWnxUaVDjaj6dH922TqFmaMFAue3LtIoO0mUciQnJlvyjjoqIbirFiSoekLBGck0PsZ4kcqD4NkqEfeIJahPf9EOYg7vWbhDzVbECQVd7q6rccWIdji3IWUXA)JRK05QCG6Yf5we2nw7FCLKoxLhOqNknJRia1HFQa5vq2SW2yWusQzCLSXEn1cPO6LaCLMbySLl(fmPZFUCLQGReOXVRckaxkQGBGcDQ0mUIauh(PcKxbHClclvWkySSXEf8oKQGReG4iWrArVhkaxkQGBsao4Ol7nWJt9DyhspsqawCib5we2nw7FCLKoxLduxUi3IWUXA)JRK05Q8afuOtLMXveG6WpvG8kiKBryPcwbJLn2RPk4kbiocCKw07HcWLIk4MeKBry3yT)Xvswra6uPzCfbOo8tfiVcs8ENqZ4kRUGvzJ96EblJ7RDmcqNknJRia1HFQa5vq2SavOnw2yVUxWY4(6)Ia0PsZ4kcqD4NkqEfKnwP5cMLn2RKBry3yT)XvsCFvoOtLMXveG6WpvG8kiKOpe2BB3c9XqNknJRia1HFQa5vqiszfdDQ0mUIauh(PcKxbjLIpeT9cnaJhpymMexnFCdb3q4hc)(74ruXvu9KXl)8CC4KBqZFHgLMXvqJiijba6C86sk9WJ3hp53XlcssMUJhfRvB6oF(nDhpxkQGBZ3XtXrY4qhp9or7qSa2bJLXII1QbG5NgfbAChACB8knJRgpj6dH922TqF8KZh3MUJNlfvWT574P4izCOJNENODiwa7GXYyrXA1aW8tJIanRqdcqJeqthGgs0hcRdHs524vAgxn(O2mUuHLK4ajEY5JCt3XR0mUA87GXYyrXA1gpxkQGBZ3jNpYB6oEUuub3MVJNIJKXHo(2La7GXYyrXA1aYGIuu9JxPzC14J37eAgxz1fSo58rst3XZLIk428D8uCKmo0X3UeyhmwglkwRgqguKIQF8knJRgFuBgxQWssCGep585Vt3XZLIk428D8uCKmo0X3UeyhmwglkwRgqguKIQF8knJRgpj6dH922TqF8Kto(gV1froDNp)MUJxPzC14BbbV4ihpxkQGBZ3jNpUnDhVsZ4QXtVIS8y7t7d645srfCB(o58rUP74vAgxnEmdgJjS9P9bD8CPOcUnFNC(iVP745srfCB(oELMXvJNQcHvPzCLveKC8IGK2sF84rXA1MC(iPP745srfCB(oELMXvJNQcHvPzCLveKC8IGK2sF84B8MlsagtMC(83P745srfCB(oELMXvJNQcHvPzCLveKC8IGK2sF84P3jAhIfzY5Z)oDhpxkQGBZ3XR0mUA8uviSknJRSIGKJxeK0w6JhFD4NkMCYX7aZ07HQ50D(8B6oEUuub3MVJV0hpEv(isvSsS7Rs7TTooez84vAgxnEv(isvSsS7Rs7TTooez8KtoE6DI2HyrMUZNFt3XR0mUA8oUmUA8CPOcUnFNC(420D8CPOcUnFhpfhjJdD8DaAAxcqIAViSOyTAazqrkQ(XR0mUA8KO2lclkwR2KZh5MUJxPzC14tPSv6sLJNlfvWT57KZh5nDhVsZ4QXVVwJX28SPu2Uf6JhpxkQGBZ3jNpsA6oELMXvJNfYqcTSnMIzE8CPOcUnFNC(83P745srfCB(oEkosgh64bhA6a00UeGEfLReRj3SBH(yl6cUaYGIuu9qJeqthGgLMXva0ROCLyn5MDl0hdeLDlIEPj04Yf0SxeclMPsvCpBZ4XqJ7qtpTb80)dnGoELMXvJNEfLReRj3SBH(4jNp)70D8CPOcUnFhpfhjJdD8Ol7nGi2mQ4UgajvksqJ7qJCJxPzC14r8WIgyCuwmtUslkp585FMUJxPzC14F87WYyVTvSqJMTHz9rgpxkQGBZ3jNpD80D8CPOcUnFhpfhjJdD8PI75eiJhBZZ2cgAChA(bijOXLlObCObCOjvCpNaszvKsbCqtOPtO5FqaAC5cAsf3ZjGuwfPuah0eACFfACdbObuOrcObCOrPzagB5IFbtGMvO5h04Yf0SJEPPfZpnkc00j04whdnGcnGcnUCbnGdnPI75eiJhBZZ6GMw3qaA6eAKdbOrcObCOrPzagB5IFbtGMvO5h04Yf0SJEPPfZpnkc00j0ip5bnGcnGoELMXvJhZQJO6TBH(yYKZNFimDhVsZ4QXlLvCAzcHlkpEUuub3MVtoF(9B6oEUuub3MVJxPzC14PYqfxIVkOwuHsYXtXrY4qhp6YEd843HLXEBRyHgnBdZ6Ja0oeRXZ7nttBPpE8uzOIlXxfulQqj5KZNFUnDhpxkQGBZ3XR0mUA8krkyAXelwLVdBPhwfJNIJKXHo(gJUS3ayv(oSLEyvyBm6YEd0oelOXLlOPXOl7na9Q2cndWyBuizBm6YEdS4aAKaAsf3ZjGuwfPuah0eAChAK7h04Yf0KkUNtGmESnpBlyOXDOXnegFPpE8krkyAXelwLVdBPhwftoF(j30D8knJRg)cHTrYpY45srfCB(o5KJVXBUibymz6oF(nDhpxkQGBZ3XtXrY4qhFQfsr1dnsanGdnGdn7fHWIzQuf3Z2mEm04o08dAKaAIIEVO6Tn9P9Svoc0ak04Yf0ao0O0maJTCXVGjqtNqJCqJeqtu07fvVTPpTNTYrGgjGg0L9gOXVRSehbsmbODiwqdOqJlxqd4qtu07fvVTPpTNTsIanDcnia4MKGgjp0iLvrkf4P)hAafAaD8knJRgFJFxzjocKyYKZh3MUJNlfvWT574P4izCOJhCOrPzagB5IFbtGMoHg5GgjGMOO3lQEBtFApBLJansanOl7nqJFxzjocKycq7qSGgqHgxUGgWHMOO3lQEBtFApBLebA6eAqaqEqJKhAKYQiLc80)dnGoELMXvJNClclQIXbJNC(i30D8CPOcUnFhpfhjJdD8szvKsbCWykxj04o0ijegVsZ4QXJUiqYY)pXknJRMC(iVP74vAgxn(hN67WoKEKGmEUuub3MVtoFK00D8knJRg)oySmwuSwTXZLIk428DYjhFD4NkMUZNFt3XZLIk428D8uCKmo0XVxeclMPsvCpBZ4XqJ7qZpOrcObCOPdqtQcUsGTqFSLIvIuaUuub3GgxUGgWHM2LaKOpe2BB3c9Xay(PrrGg3Hg5GgjGMoanknJRaIAZ4sfwsIdKyas0hcRdHs5g0ak0a64vAgxn(O2mUuHLK4ajEY5JBt3XZLIk428D8uCKmo0Xdo0ao0GUS3apo13HDi9ibbyXb0ib0qUfHDJ1(hxjbA6CfAKdAafAC5cAi3IWUXA)JRKanDUcnYdAaD8knJRgpXrGJ0IEp0jNpYnDhpxkQGBZ3XtXrY4qhFQfsr1dnsanGdnkndWylx8lyc00j08dAC5cAsvWvc043vbfGlfvWnOb0XR0mUA8BwyBmykj1mUAY5J8MUJNlfvWT574P4izCOJhCOPdqtQcUsaIJahPf9EOaCPOcUbnsanGdnGdnOl7nWJt9DyhspsqawCansanKBry3yT)XvsGMoxHg5GgqHgxUGgYTiSBS2)4kjqtNRqJ8GgqHgqhVsZ4QXtUfHLkyfmEY5JKMUJNlfvWT574P4izCOJpvbxjaXrGJ0IEpuaUuub3GgjGgYTiSBS2)4kjqZk0GW4vAgxnEYTiSubRGXtoF(70D8CPOcUnFhpfhjJdD87fSmqJ7RqthJW4vAgxn(49oHMXvwDbRtoF(3P745srfCB(oEkosgh643lyzGg3xHM)fHXR0mUA8BwGk0gp585FMUJNlfvWT574P4izCOJNClc7gR9pUsc04(k0i34vAgxn(nwP5cMNC(0Xt3XR0mUA8KOpe2BB3c9XJNlfvWT57KZNFimDhVsZ4QXtKYkE8CPOcUnFNC(8730D8knJRgFkfFiA7fAagpEUuub3MVto5Kto5ma]] )

end
