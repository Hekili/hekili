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
            copy = 272987
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

        potion = "phantom_fire",

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


    spec:RegisterPack( "Vengeance", 20201123, [[dGuqKaqivcpIqsBIk1NOk0OiItrKwLkrPxrfzwufTlP8lcXWGuDmiLLrvXZOkzAquCnQsTniQ4Bes14GOuNJQaRJqcZJQs3dc7JkQdsirwiHYdvjkMiHu6IQevAJQev8rQcIrcrjojvb1kPQAMQevTtiYsjKINQktvL0wHOK(kvbPXcrL2lO)kPbd1HjTyv1JP0KL4YiBwQ(Sk1OjWPv8AcvZgv3wf7w0Vbgov44esulhLNtX0fUorTDQKVtqnEvICEcY6HOQ5dj7xPHObVcFfniis(GUpOJgA(4vdnVrx09r0HVqihe85qTIR3e8L6HGpKvkVjnTe85qfId0c8k8zaYmlbFcIWHruiIi3tiq(3SGJiM5iZ1yaPLP9qeZCSIaFF5HhE4e(HVIgeejFq3h0rdnF8QHM3Ol6(aFghKfIK3iB0GpbtPqj8dFfYyHprDXIw6aYfJSiNbXwmYkL3KMwA9lQlgjGl68j2I9XlpxSpO7d6WNdgOpCc(e1flAPdixmYICgeBXiRuEtAAP1VOUyKaUOZNyl2hV8CX(GUpOV(x)QngqAAoyKfC(A4ecrKnuDc64zQhcHI8gbktn1oiJkOxDaeMyR)1VOU4l3lrw5GklMCrmHwCmhAXHaAXQnaSfpMfRU0HRFo1w)QngqACcHiUu2OFo5zQhcXNPzP(LhEXtxkxMqekNYOP3GCq(jVRDUEitJs9ZPI7q5ugTVmlN8UQ8Xf1Ou)CQ4ouoLrZkqzmQu7CYiOrP(5uz9R2yaPXjeIugdt2rS(vBmG04ecrSG0iFO6rVh76xTXasJtieHrUiMHQh9ESRF1gdinoHqKqadiC9MRJlYZPJ4l37ToXRFW5RSYHYOzc1kocVDl5l37T5CaCngqwvzM2KDGc1fF5EVDOqpaMdbaZyAYoKU(vBmG04ecrSkNxvBmGSYht4zQhcXNPzXZPJWLYg9ZP2NPzP(LhEz9R2yaPXjeIyvoVQ2yazLpMWZupeIc1P0mUiZ6xTXasJtieXQCEvTXaYkFmHNPEiewaGxacNM1VAJbKgNqiIv58QAJbKv(ycpt9qisa7O81)6xux8LZqmHwSymnllw0acngqU(vBmG00(mnli6dXeQ(zAww)QngqAAFMMfNqiYCoaUgdiRQmt9C6ikGO1hIju9Z0S0IXk(K3R)1VAJbKMMfa4fGWPbHdqmGC9R2yaPPzbaEbiCACcHiwqAPmyAqLANRhYZPJqYffq0SG0szW0Gk1oxpu9lZYwmwXN829fQngq2SG0szW0Gk1oxpuBYANp3ccuO6YCELrwbk7MQXCiFVTL2rVK01VAJbKMMfa4fGWPXjeIimGXlUOjRmYasnTKNthXxU3B8PtFoauAMqTI7RxRF1gdinnlaWlaHtJtie5qhatOkOx5Y2PulmspM1VOUyKfaVSyrdPoM8EXxoC9qMf3bSftxISYbTyMM30IbSfl(W5l(l37gpx80xSdGXmFo1wSOexyviZIdMqloal(MIfhcOfZbctMyXwaGxacNl(RgQSyqUy1LoC9ZPftjDgY0w)QngqAAwaGxacNgNqicJuhtEx7C9qgpNoIqz3u0I5q1auld5lAnVrHsIKqz3u0eqkpe0CydNr2OJcvOSBkAciLhcAoSHVi8bDPULO2yCrvkPZqgeOHcvFUfevgD0jno7JhivkkuscLDtrlMdvdq1HnQ(GUZEHUBjQngxuLs6mKbbAOq1NBbrLrhDsJZidYiv66xuxSOL6QmpwCx58VAfFXDaBXYg9ZPftgdLwY0w)QngqAAwaGxacNgNqiIaszrLmgkT06xTXastZca8cq404ecrKnuDc64j17KnQPEiewHSCqWa5yRFUAcpNoIVCV3o0bWeQc6vUSDk1cJ0JPvacNRF1gdinnlaWlaHtJtier2q1jOJNPEieQrGlnjtLPipGvTaMY9C6ik0xU3Bmf5bSQfWuETqF5EVvacNOqvOVCV3SGSiBJXfvNu8AH(Y9Et2H7qz3u0eqkpe0CydF9cnuOcLDtrlMdvdqTmKV(G(6xuxSOL6QmpwCx58VAfFXDaBXYg9ZPfpbDmT1VAJbKMMfa4fGWPXjeIiBO6e0XS(vBmG00SaaVaeonoHqeZKDzE9Z0S450rCrbenZKDzE9Z0S0IXk(K3RF1gdinnlaWlaHtJtiejeqvbYzS(vBmG00SaaVaeonoHqKoOuiwna1qav7C9qRF1gdinnlaWlaHtJtieH4czgnRfYYiA9V(f1flAPoLMXfzw)QngqAAfQtPzCrgef6aYQXXioz8C6icnfFYB3sK0L58kJScu2nvJ5q(IM7jTGZK31IE0BQ6LrkkusuBmUOkL0ziJZE5Esl4m5DTOh9MQEzC)L79wHoGSACmItMwbiCkffkjtAbNjVRf9O3u1BJZO38X7lRas5HG2rVKuPRF1gdinTc1P0mUiJtieXaK51VYydX8C6iKO2yCrvkPZqgN9Y9KwWzY7Arp6nv9Y4(l37TcDaz14yeNmTcq4ukkusM0cotExl6rVPQ3gNrVHmxwbKYdbTJEjPRF1gdinTc1P0mUiJtie5lZfVsxkyQngq650riGuEiO5GywkdF9g91VAJbKMwH6uAgxKXjeICOqpaMdbaZy8C6iUqsOCkJwHoGCSnk1pNksDl5clWfLAgnxugceI1Ou)CQGc1ffq0mt2L51ptZslgR4tElffkjFGX4Up3cIkJo6KgFrZBPRF1gdinTc1P0mUiJtiePpetO6NPzz9V(f1fJeGDu(IfnGqJbKRF1gdinTeWok3jeImzNyPYRMGnItEoDeDzoVYiRaLDt1yoKVO5wYfHYPmADUEOQLPgbnk1pNkOqjPaIMzUhEf0RDUEOgJo6KgF9Y9fQngq2MStSu5vtWgXPMzUhE1bxTurQ01VAJbKMwcyhL7ecr(YCXR0LcMAJbKRF1gdinTeWok3jeIyCmSjQFW5750rirYxU3Bhk0dG5qaWmMMSd3HYPmADMAdzg1Ou)CQ42aK51otVpuggNr4LuuOmazETZ07dLHXzeiJ01VAJbKMwcyhL7ecr6eVwixQj0yaPNthrOP4tE7wIAJXfvPKodzCgnuOcLtz0k0bKJTrP(5ur66xTXastlbSJYDcHigGmVA5K6I8C6iKijuoLrZ4yytu)GZVrP(5uXTbiZRDMEFOmmiqxkkuxekNYOzCmSjQFW53Ou)CQi1TejHYPmADMAdzg1Ou)CQ4UlZeYzeE7TuuOKCrOCkJwNP2qMrnk1pNkU7YmHCgHOJUuuOSaaVaeoBDIxlKl1eAmGSXOJoPX5qz3u0I5q1auldHcLKVCV3ouOhaZHaGzmnzhULijuoLrRZuBiZOgL6Ntf3DzMqoJWlVLIcLKlcLtz06m1gYmQrP(5uXDxMjKZi8gDPsLkD9R2yaPPLa2r5oHqK5CaCngqwvzM650rirIlLn6NtTptZs9lp8IBlaWlaHZwFiMq1ptZsJrhDsJZOHUuuOUWLYg9ZP2NPzP(LhErQ7UmtiFr4bOV(vBmG00sa7OCNqisN4FUwipNoIUmtiFrGCqF9R2yaPPLa2r5oHqKotTHmJ8C6iKijuoLrZ4yytu)GZVrP(5uXTbiZRDMEFOmm(IWlPOqj5Iq5ugnJJHnr9do)gL6Ntf3sK8L792Hc9ayoeamJPj7WDxMjKVi82BPOqj5l37Tdf6bWCiaygtRaeoD3Lzc5lcrhDPsLkD9R2yaPPLa2r5oHqeZCp8kOx7C9qEoDexiXcCrPMrtCHyJMnk1pNkUzYj1bSBQXuKN4J4cm1c1hoDOmKU(vBmG00sa7OCNqiIraPS1VAJbKMwcyhL7ecrcbmGW1BUoUi4ZfXmdiHi5d6(GoAOHgYaFcRSCYBd85HkkjAqYdJKhIOyXl(QaAXZXbGflUdyl2JfQtPzCrgpUygjklpmQSyd4qlwLdWrdQSyRanVjtB9F5NKwmYikw8LbKUiwqLf7rlWfLAgnKBJs9ZPIhxCawShTaxuQz0qUECXsq7ssBR)1VhQOKObjpmsEiIIfV4RcOfphhawS4oGTypMa2r5ECXmsuwEyuzXgWHwSkhGJguzXwbAEtM26)YpjTypquS4ldiDrSGkl2JwGlk1mAi3gL6NtfpU4aSypAbUOuZOHC94ILG2LK2w)x(jPf7bIIfFzaPlIfuzXEKjNuhWUPgY1Jloal2Jm5K6a2n1qUnk1pNkECXsq7ssBR)1Vh(4aWcQSyKZIvBmGCX8XeM26h(4JjmWRW3NPzbEfIeAWRWNAJbKWxFiMq1ptZc8rP(5ubkgmGi5d8k8rP(5ubkg8zztqSrHVciA9Hycv)mnlTySIp5n8P2yaj8nNdGRXaYQkZuyad4RqDvMhWRqKqdEf(Ou)CQafd(aoGpdfWNAJbKWNlLn6NtWNlLltWxOCkJMEdYb5N8U256Hmnk1pNkl29IdLtz0(YSCY7QYhxuJs9ZPYIDV4q5ugnRaLXOsTZjJGgL6Ntf4ZLYQPEi47Z0Su)YdVadis(aVcFQngqcFLXWKDeWhL6NtfOyWaIKxWRWNAJbKWNfKg5dvp69yHpk1pNkqXGbejKbEf(uBmGe(yKlIzO6rVhl8rP(5ubkgmGi5n8k8rP(5ubkg8zztqSrHVVCV36eV(bNVYkhkJMjuR4lgXI9EXUxSKf)L792CoaUgdiRQmtBYowmkul(If)L792Hc9ayoeamJPj7yXsHp1gdiHVqadiC9MRJlcgqKqoWRWhL6NtfOyWNLnbXgf(CPSr)CQ9zAwQF5HxGp1gdiHpRY5v1gdiR8XeWhFmrn1dbFFMMfyars0HxHpk1pNkqXGp1gdiHpRY5v1gdiR8XeWhFmrn1dbFfQtPzCrgyarczdVcFuQFovGIbFQngqcFwLZRQngqw5JjGp(yIAQhc(SaaVaeonWaIKhaVcFuQFovGIbFQngqcFwLZRQngqw5JjGp(yIAQhc(sa7OCyad4ZbJSGZxd4visObVcFuQFovGIbFPEi4trEJaLPMAhKrf0Roactm4tTXas4trEJaLPMAhKrf0Roactmyad4Zca8cq40aVcrcn4v4tTXas4ZbigqcFuQFovGIbdis(aVcFuQFovGIbFw2eeBu4tYIVyXfq0SG0szW0Gk1oxpu9lZYwmwXN8EXUx8flwTXaYMfKwkdMguP256HAtw785wqSyuOwCxMZRmYkqz3unMdTyFx8TT0o6LwSu4tTXas4ZcslLbtdQu7C9qWaIKxWRWhL6NtfOyWNLnbXgf((Y9EJpD6ZbGsZeQv8f77I9c(uBmGe(egW4fx0KvgzaPMwcgqKqg4v4tTXas47qhatOkOx5Y2Pulmspg4Js9ZPcumyarYB4v4Js9ZPcum4ZYMGyJcFHYUPOfZHQbOwgAX(Uy0AEVyuOwSKflzXHYUPOjGuEiO5Wgl25fJSrFXOqT4qz3u0eqkpe0CyJf7lIf7d6lw6IDVyjlwTX4IQusNHmlgXIrBXOqT4(CliQm6OtAwSZl2hpyXsxS0fJc1ILS4qz3u0I5q1auDyJQpOVyNxSxOVy3lwYIvBmUOkL0ziZIrSy0wmkulUp3cIkJo6KMf78IrgKzXsxSu4tTXas4JrQJjVRDUEidmGiHCGxHp1gdiHpbKYIkzmuAj4Js9ZPcumyars0HxHpk1pNkqXGp1gdiHpRqwoiyGCS1pxnb8zztqSrHVVCV3o0bWeQc6vUSDk1cJ0JPvacNWh17KnQPEi4ZkKLdcgihB9ZvtadisiB4v4Js9ZPcum4tTXas4tncCPjzQmf5bSQfWuo8zztqSrHVc9L79gtrEaRAbmLxl0xU3BfGW5IrHAXf6l37nlilY2yCr1jfVwOVCV3KDSy3lou2nfnbKYdbnh2yX(UyVqBXOqT4qz3u0I5q1auldTyFxSpOdFPEi4tncCPjzQmf5bSQfWuomGi5bWRWNAJbKWNSHQtqhd8rP(5ubkgmGiHg6WRWhL6NtfOyWNLnbXgf(UyXfq0mt2L51ptZslgR4tEdFQngqcFMj7Y86NPzbgqKqdn4v4tTXas4leqvbYzaFuQFovGIbdisO5d8k8P2yaj81bLcXQbOgcOANRhc(Ou)CQafdgqKqZl4v4tTXas4J4czgnRfYYic(Ou)CQafdgWa(kuNsZ4ImWRqKqdEf(Ou)CQafd(SSji2OWxOP4tEVy3lwYILS4UmNxzKvGYUPAmhAX(Uy0wS7fpPfCM8Uw0JEtvVmlw6IrHAXswSAJXfvPKodzwSZl2Rf7EXtAbNjVRf9O3u1lZIDV4VCV3k0bKvJJrCY0kaHZflDXOqTyjlEsl4m5DTOh9MQEBwSZlg9MpEV4l7Ifqkpe0o6LwS0flf(uBmGe(k0bKvJJrCYadis(aVcFuQFovGIbFw2eeBu4tYIvBmUOkL0ziZIDEXETy3lEsl4m5DTOh9MQEzwS7f)L79wHoGSACmItMwbiCUyPlgfQflzXtAbNjVRf9O3u1BZIDEXO3qMfFzxSas5HG2rV0ILcFQngqcFgGmV(vgBigmGi5f8k8rP(5ubkg8zztqSrHpbKYdbnheZszSyFxS3OdFQngqcFFzU4v6sbtTXasyarczGxHpk1pNkqXGplBcInk8DXILS4q5ugTcDa5yBuQFovwS0f7EXsw8fl2cCrPMrZfLHaHylgfQfFXIlGOzMSlZRFMMLwmwXN8EXsxmkulwYI)aJzXUxCFUfevgD0jnl23fJM3lwk8P2yaj8DOqpaMdbaZyGbejVHxHp1gdiHV(qmHQFMMf4Js9ZPcumyad4lbSJYHxHiHg8k8rP(5ubkg8zztqSrHVUmNxzKvGYUPAmhAX(Uy0wS7flzXxS4q5ugToxpu1YuJGgL6NtLfJc1ILS4ciAM5E4vqV256HAm6OtAwSVl2Rf7EXxSy1gdiBt2jwQ8QjyJ4uZm3dV6GRwQSyPlwk8P2yaj8nzNyPYRMGnItWaIKpWRWNAJbKW3xMlELUuWuBmGe(Ou)CQafdgqK8cEf(Ou)CQafd(SSji2OWNKflzXF5EVDOqpaMdbaZyAYowS7fhkNYO1zQnKzuJs9ZPYIDVydqMx7m9(qzywSZiwSxlw6IrHAXgGmV2z69HYWSyNrSyKzXsHp1gdiHpJJHnr9doFyarczGxHpk1pNkqXGplBcInk8fAk(K3l29ILSy1gJlQsjDgYSyNxmAlgfQfhkNYOvOdihBJs9ZPYILcFQngqcFDIxlKl1eAmGegqK8gEf(Ou)CQafd(SSji2OWNKflzXHYPmAghdBI6hC(nk1pNkl29InazETZ07dLHzXiwm6lw6IrHAXxS4q5ugnJJHnr9do)gL6NtLflDXUxSKflzXHYPmADMAdzg1Ou)CQSy3lUlZeAXoJyXE79ILUyuOwSKfFXIdLtz06m1gYmQrP(5uzXUxCxMj0IDgXIfD0xS0fJc1ITaaVaeoBDIxlKl1eAmGSXOJoPzXoV4qz3u0I5q1auldTyuOwSKf)L792Hc9ayoeamJPj7yXUxSKflzXHYPmADMAdzg1Ou)CQSy3lUlZeAXoJyXE59ILUyuOwSKfFXIdLtz06m1gYmQrP(5uzXUxCxMj0IDgXI9g9flDXsxS0flf(uBmGe(mazE1Yj1fbdisih4v4Js9ZPcum4ZYMGyJcFswSKf7szJ(5u7Z0Su)YdVSy3l2ca8cq4S1hIju9Z0S0y0rN0SyNxmAOVyPlgfQfFXIDPSr)CQ9zAwQF5HxwS0f7EXDzMql2xel2dqh(uBmGe(MZbW1yazvLzkmGij6WRWhL6NtfOyWNLnbXgf(6YmHwSViwmYbD4tTXas4Rt8pxlemGiHSHxHpk1pNkqXGplBcInk8jzXswCOCkJMXXWMO(bNFJs9ZPYIDVydqMx7m9(qzywSViwSxlw6IrHAXsw8flouoLrZ4yytu)GZVrP(5uzXUxSKflzXF5EVDOqpaMdbaZyAYowS7f3LzcTyFrSyV9EXsxmkulwYI)Y9E7qHEamhcaMX0kaHZf7EXDzMql2xelw0rFXsxS0flDXsHp1gdiHVotTHmJGbejpaEf(Ou)CQafd(SSji2OW3flwYITaxuQz0exi2O5IDVyMCsDa7MAmf5j(iUatTq9HthkJgL6NtLflf(uBmGe(mZ9WRGETZ1dbdisOHo8k8P2yaj8zeqkd(Ou)CQafdgqKqdn4v4tTXas4leWacxV564IGpk1pNkqXGbmGb8PYHaad(EZ5YadyaHa]] )

end
