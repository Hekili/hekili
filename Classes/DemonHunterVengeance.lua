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


    spec:RegisterPack( "Vengeance", 20201114, [[dG0)Jaqijv9iIuSjQuFcIsJIqDkIyvscQxrfzwsI2Lc)IGmmcXXGuwMQqptsQPrKQRjPY2ufOVbrHXPkGZjjuRJiLAEssUhe2hvuheIQYcjKEievPjkjGlcrrAJqueFeIQQrcrrDsjbzLskZusGANqKLsKsEQknvvrBfIQ4RscKXkje7f0FLyWqDyslwv9yknzQ6YiBwrFwvA0e40s9AIKzJQBRIDl63adNkCCjH0Yr55umDHRtuBNk57qQgVQGopb16HOY8HK9R0q0GpHxVgeePhf5rrqdn0K(4XQR(bR(bG3qyhe86qTsPVe8M6HGxKhkFjnTe86qfMdup8j8AaYmlbVcIWHrAlKqVDiq(pSGJqM(iZ1ObPLPZqitFScbVF5MhvOe(HxVgeePhf5rrqdn0Ko8ACqwis19aObVcAVNs4hE9KXcVsZIRa0bKlgzwodITyKhkFjnT0wtAwmsax05tSfJM0RCXpkYJIaVoyGzZj4vAwCfGoGCXiZYzqSfJ8q5lPPL2AsZIrc4IoFITy0KELl(rrEuKT2wtTrdsZWbJSGZxdNqiKSHkDqNkt9qiuKZiqzQPmbzuaZIda6eBRT1KMfJm9HKvoi)Ijxet4fh9HwCiGwSAdaBXTzXQlT56NtJTMAJgKgNqiKlL16NtvM6Hq8zA6lF5M7R0LYLjeHYPmg6liBKRZ3YKRhYmOu)CY7ouoLX4lZYoFlkVDrdk1pN8UdLtzmScugJ8LjNmcguQFo53AQnAqACcHq(2WKDeBn1gninoHqilinYhQC032U1uB0G04ecHyKlIzOYrFB7wtTrdsJtiekeWaOxE5A7IQSNi(YZ5ys8YhC(kZFOmgMqTsHOo3I)YZ5OphaxJgKfvMPdzhOqv)xEohhk0dG5qaW0MHSdjBn1gninoHqiRY5f1gnil82evM6Hq8zA6RSNiCPSw)CA8zA6lF5M73AQnAqACcHqwLZlQnAqw4TjQm1dHWttknTlYS1uB0G04ecHSkNxuB0GSWBtuzQhcHfa4Ea6PzRP2ObPXjeczvoVO2ObzH3MOYupeIeWokFRT1KMfJmPjMWlwuMM(flTaHgni3AQnAqAgFMMEeZMycx(mn9Bn1gninJpttVtieQphaxJgKfvMPv2teEqmMnXeU8zA6hrBLQZ3T2wtTrdsZWcaCpa90GWbiAqU1uB0G0mSaa3dqpnoHqiliTugmniFzY1dvzpriUEpigwqAPmyAq(YKRhQ8Lz5iARuD(6UE1gnihwqAPmyAq(YKRhA0zzY7xbbkutzoVWiRaL9sLOpuvVw)4OpuYwtTrdsZWcaCpa904ecHqhW4ExuNfgzaPMwQYEI4lpNdEpPpha8dtOwPQQ6TMAJgKMHfa4Ea6PXjecDOdGjCbmlCzB7lEgPhZwtAwmYmG7xS0IuhD(UyKjC9qMfpbSftpKSYbTyMMV0IbSflvZ5l(lpNMkxCpxSdGX0FonwmYhhDvyZIdMWloal(LIfhcOfZbOtMyXwaG7bONl(RgYVyqUy1L2C9ZPftjDAYm2AQnAqAgwaG7bONgNqieJuhD(wMC9qMk7jIqzVumI(qLau8nvfAJ6qHsS4qzVumeqkpemCydNFarqHku2lfdbKYdbdh2OkepkIe3IvB0UOcL0Pjdc0qHA2VcIcJoANgNFSILibfkXHYEPye9HkbO4WgLhfX5QfXTy1gTlQqjDAYGanuOM9RGOWOJ2PXzPlDjs2AsZIRa0uL5XINkN)vRulEcylw2OFoTyYyO0sMXwtTrdsZWcaCpa904ecHeqklkKXqPL2AQnAqAgwaG7bONgNqiKSHkDqNkP5KSrj1dHWkSLdcgiBB5Zvtuzpr8LNZXHoaMWfWSWLTTV4zKEmdpa9CRP2ObPzybaUhGEACcHqYgQ0bDQm1dHqncCPjzkmf5aSIfWuEL9eHN(YZ5GPihGvSaMYlE6lpNdpa9efkp9LNZHfKEzB0UOsNsv80xEohYoChk7LIHas5HGHdBuv1OHcvOSxkgrFOsak(MQ6rr2AsZIRa0uL5XINkN)vRulEcylw2OFoT4oOJzS1uB0G0mSaa3dqpnoHqizdv6GoMTMAJgKMHfa4Ea6PXjecz6CkZlFMM(k7jI69Gyy6CkZlFMM(r0wP68DRP2ObPzybaUhGEACcHqHaQiqoJTMAJgKMHfa4Ea6PXjecnbEpXkbOecOYKRhARP2ObPzybaUhGEACcHqexytRzXtwgrBTTM0S4kanP00UiZwtTrdsZWttknTlYGWthqwmoAPitL9erOPuD(6wS4PmNxyKvGYEPs0hQk0C3PfC68T41J(sLQnsqHsSAJ2fvOKonzCUA3DAbNoFlE9OVuPAJ7V8Co80bKfJJwkYm8a0tjOqjUtl405BXRh9Lk1zCwKXJ1vHfqkpemo6dLizRP2ObPz4PjLM2fzCcHqgGmV8vgRjwL9eHy1gTlQqjDAY4C1U70coD(w86rFPs1g3F55C4PdilghTuKz4bONsqHsCNwWPZ3Ixp6lvQZ4SidPxHfqkpemo6dLS1uB0G0m80Kst7ImoHqOVmxQc9WGP2ObzL9eHas5HGHdIzPmQQor2AQnAqAgEAsPPDrgNqi0Hc9ayoeamTPYEIOEXHYPmgE6aY2oOu)CYlXT46TaxuQzmCrziqy2Gs9Zjpku17bXW05uMx(mn9JOTs15ReuOe)bgJ7z)kikm6ODAQcT6KS1uB0G0m80Kst7ImoHqOztmHlFMM(T2wtAwmsa2r5lwAbcnAqU1uB0G0msa7OCNqiuNtILkVycwlfvzprmL58cJScu2lvI(qvHMBX1hkNYym56HkwMAemOu)CYJcLypigM(T5fWSm56Hgm6ODAQQA31R2Ob5OZjXsLxmbRLIgM(T5fhC1sEjs2AQnAqAgjGDuUtie6lZLQqpmyQnAqU1uB0G0msa7OCNqiKXrZ6O8bNFL9eHyXF55CCOqpaMdbatBgYoChkNYymzQnKz0Gs9ZjVBdqMxMm99qzyCgr1sqHYaK5LjtFpuggNriDjBn1gninJeWok3jecnjEXtUutOrdYk7jIqtP681Ty1gTlQqjDAY4mAOqfkNYy4PdiB7Gs9ZjVKTMAJgKMrcyhL7ecHmazEXYj1fvzpriwCOCkJHXrZ6O8bN)Gs9ZjVBdqMxMm99qzyqiIeuOQpuoLXW4OzDu(GZFqP(5KxIBXIdLtzmMm1gYmAqP(5K39uMjSZiQRojOqjU(q5ugJjtTHmJguQFo5DpLzc7mcKHisqHYcaCpa9CmjEXtUutOrdYbJoANgNdL9sXi6dvcqX3ekuI)YZ54qHEamhcaM2mKD4wS4q5ugJjtTHmJguQFo5DpLzc7mIQRtckuIRpuoLXyYuBiZObL6NtE3tzMWoJOorKirIKTMAJgKMrcyhL7ecH6ZbW1ObzrLzAL9eHyXUuwRFon(mn9LVCZ9UTaa3dqphZMycx(mn9dgD0onoJMisqHQExkR1pNgFMM(YxU5EjUNYmHRcrflYwtTrdsZibSJYDcHqtI)5QNQSNiMYmHRcXdkYwtTrdsZibSJYDcHqtMAdzgvzpriwCOCkJHXrZ6O8bN)Gs9ZjVBdqMxMm99qzyQcr1sqHsC9HYPmgghnRJYhC(dk1pN8Ufl(lpNJdf6bWCiayAZq2H7Pmt4QquxDsqHs8xEohhk0dG5qaW0MHhGE6EkZeUkeidrKirIKTMAJgKMrcyhL7ecHm9BZlGzzY1dvzpruVylWfLAgdPeM1AoOu)CY7MjN0eWEPbtroI3sjWu80S50HYyqvu52HdYlzRP2ObPzKa2r5oHqiJaszBn1gninJeWok3jecfcya0lVCTDrWRlIzAqcr6rrEue0qdnPdVORSSZxd8wbH8jTqQcHeYV0EXl(PaAX9XbGflEcylgz90Kst7Imi7IzufvUzKFXgWHwSkhGJgKFXwbA(sMXwRcUtAXsxAVyKxq6Iyb5xmYAbUOuZyurguQFo5r2fhGfJSwGlk1mgveKDXIr7HsgBTTwfeYN0cPkesi)s7fV4NcOf3hhawS4jGTyKnbSJYr2fZOkQCZi)InGdTyvoahni)ITc08LmJTwfCN0IRyP9IrEbPlIfKFXiRf4IsnJrfzqP(5KhzxCawmYAbUOuZyurq2flgThkzS12AvOJdali)IFWfR2Ob5I5TjmJTg8QYHaadEV9b5fE5TjmWNW7NPPh(eIeAWNWRAJgKW7SjMWLpttp8sP(5KhkkmGi9i8j8sP(5Khkk8AzDqSwHxpigZMycx(mn9JOTs15l8Q2Obj82NdGRrdYIkZuyad41ttvMhWNqKqd(eEPu)CYdffEboGxdfWRAJgKWRlL16NtWRlLltWBOCkJH(cYg568Tm56Hmdk1pN8l29IdLtzm(YSSZ3IYBx0Gs9Zj)IDV4q5ugdRaLXiFzYjJGbL6NtE41LYkPEi49Z00x(Yn3ddispcFcVQnAqcV(2WKDeWlL6NtEOOWaIu1WNWRAJgKWRfKg5dvo6BBHxk1pN8qrHbejPdFcVQnAqcVmYfXmu5OVTfEPu)CYdffgqKQd(eEPu)CYdffETSoiwRW7xEohtIx(GZxz(dLXWeQvQfJyX1Ty3lw8I)YZ5OphaxJgKfvMPdzhlgfQfx)I)YZ54qHEamhcaM2mKDSyjWRAJgKWBiGbqV8Y12fbdispi8j8sP(5Khkk8Q2Obj8AvoVO2ObzH3MaETSoiwRWRlL16NtJpttF5l3Cp8YBtus9qW7NPPhgqKqgWNWlL6NtEOOWRAJgKWRv58IAJgKfEBc4L3MOK6HGxpnP00UidmGi9aWNWlL6NtEOOWRAJgKWRv58IAJgKfEBc4L3MOK6HGxlaW9a0tdmGivXWNWlL6NtEOOWRAJgKWRv58IAJgKfEBc4L3MOK6HG3eWokhgWaEDWil481a(eIeAWNWlL6NtEOOWBQhcEvKZiqzQPmbzuaZIda6edEvB0GeEvKZiqzQPmbzuaZIda6edgWaETaa3dqpnWNqKqd(eEvB0GeEDaIgKWlL6NtEOOWaI0JWNWlL6NtEOOWRL1bXAfEfV46xShedliTugmniFzY1dv(YSCeTvQoFxS7fx)IvB0GCybPLYGPb5ltUEOrNLjVFfelgfQfpL58cJScu2lvI(qlUQf)A9JJ(WflbEvB0GeETG0szW0G8LjxpemGivn8j8sP(5Khkk8AzDqSwH3V8Co49K(CaWpmHALAXvT4QHx1gniHx0bmU3f1zHrgqQPLGbejPdFcVQnAqcVh6aycxaZcx22(INr6XaVuQFo5HIcdis1bFcVuQFo5HIcVwwheRv4nu2lfJOpujafFtlUQfJ2OUfJc1IfVyXlou2lfdbKYdbdh2yXoV4hqKfJc1IdL9sXqaP8qWWHnwCviw8JISyjl29IfVy1gTlQqjDAYSyelgTfJc1IN9RGOWOJ2PzXoV4hR4flzXswmkulw8IdL9sXi6dvcqXHnkpkYIDEXvlYIDVyXlwTr7IkusNMmlgXIrBXOqT4z)kikm6ODAwSZlw6sFXswSe4vTrds4LrQJoFltUEidmGi9GWNWRAJgKWRaszrHmgkTe8sP(5KhkkmGiHmGpHxk1pN8qrHxlRdI1k8(LNZXHoaMWfWSWLTTV4zKEmdpa9eEvB0GeETcB5GGbY2w(C1eWlnNKnkPEi41kSLdcgiBB5Zvtadispa8j8sP(5Khkk8Q2Obj8QgbU0KmfMICawXcykhETSoiwRWRN(YZ5GPihGvSaMYlE6lpNdpa9CXOqTyp9LNZHfKEzB0UOsNsv80xEohYowS7fhk7LIHas5HGHdBS4QwC1OTyuOwCOSxkgrFOsak(MwCvl(rrG3upe8QgbU0KmfMICawXcykhgqKQy4t4vTrds4v2qLoOJbEPu)CYdffgqKqte4t4Ls9Zjpuu41Y6GyTcV1VypigMoNY8YNPPFeTvQoFHx1gniHxtNtzE5Z00ddisOHg8j8Q2Obj8gcOIa5mGxk1pN8qrHbej0Ee(eEvB0GeENaVNyLaucbuzY1dbVuQFo5HIcdisOvn8j8Q2Obj8sCHnTMfpzzebVuQFo5HIcdyaVEAsPPDrg4tisObFcVuQFo5HIcVwwheRv4n0uQoFxS7flEXIx8uMZlmYkqzVuj6dT4QwmAl29I70coD(w86rFPs1MflzXOqTyXlwTr7IkusNMml25fx9IDV4oTGtNVfVE0xQuTzXUx8xEohE6aYIXrlfzgEa65ILSyuOwS4f3PfC68T41J(sL6ml25flY4X6wCfEXciLhcgh9HlwYILaVQnAqcVE6aYIXrlfzGbePhHpHxk1pN8qrHxlRdI1k8kEXQnAxuHs60KzXoV4QxS7f3PfC68T41J(sLQnl29I)YZ5WthqwmoAPiZWdqpxSKfJc1IfV4oTGtNVfVE0xQuNzXoVyrgsFXv4flGuEiyC0hUyjWRAJgKWRbiZlFLXAIbdisvdFcVuQFo5HIcVwwheRv4vaP8qWWbXSuglUQfxNiWRAJgKW7xMlvHEyWuB0GegqKKo8j8sP(5Khkk8AzDqSwH36xS4fhkNYy4PdiB7Gs9Zj)ILSy3lw8IRFXwGlk1mgUOmeimBXOqT46xShedtNtzE5Z00pI2kvNVlwYIrHAXIx8hyml29IN9RGOWOJ2PzXvTy0QBXsGx1gniH3df6bWCiayAdmGivh8j8Q2Obj8oBIjC5Z00dVuQFo5HIcdyaVjGDuo8jej0GpHxk1pN8qrHxlRdI1k8oL58cJScu2lvI(qlUQfJ2IDVyXlU(fhkNYym56HkwMAemOu)CYVyuOwS4f7bXW0VnVaMLjxp0GrhTtZIRAXvVy3lU(fR2Ob5OZjXsLxmbRLIgM(T5fhC1s(flzXsGx1gniH3oNelvEXeSwkcgqKEe(eEvB0GeE)YCPk0ddMAJgKWlL6NtEOOWaIu1WNWlL6NtEOOWRL1bXAfEfVyXl(lpNJdf6bWCiayAZq2XIDV4q5ugJjtTHmJguQFo5xS7fBaY8YKPVhkdZIDgXIREXswmkul2aK5LjtFpugMf7mIfl9flbEvB0GeEnoAwhLp48HbejPdFcVuQFo5HIcVwwheRv4n0uQoFxS7flEXQnAxuHs60KzXoVy0wmkulouoLXWthq22bL6Nt(flbEvB0GeENeV4jxQj0ObjmGivh8j8sP(5Khkk8AzDqSwHxXlw8IdLtzmmoAwhLp48huQFo5xS7fBaY8YKPVhkdZIrSyrwSKfJc1IRFXHYPmgghnRJYhC(dk1pN8lwYIDVyXlw8IdLtzmMm1gYmAqP(5KFXUx8uMj8IDgXIRRUflzXOqTyXlU(fhkNYymzQnKz0Gs9Zj)IDV4Pmt4f7mIfJmezXswmkul2caCpa9CmjEXtUutOrdYbJoANMf78IdL9sXi6dvcqX30IrHAXIx8xEohhk0dG5qaW0MHSJf7EXIxS4fhkNYymzQnKz0Gs9Zj)IDV4Pmt4f7mIfxDDlwYIrHAXIxC9louoLXyYuBiZObL6Nt(f7EXtzMWl2zelUorwSKflzXswSe4vTrds41aK5flNuxemGi9GWNWlL6NtEOOWRL1bXAfEfVyXl2LYA9ZPXNPPV8LBUFXUxSfa4Ea65y2et4YNPPFWOJ2PzXoVy0ezXswmkulU(f7szT(504Z00x(Yn3Vyjl29INYmHxCviwCflc8Q2Obj82NdGRrdYIkZuyarczaFcVuQFo5HIcVwwheRv4DkZeEXvHyXpOiWRAJgKW7K4FU6jyar6bGpHxk1pN8qrHxlRdI1k8kEXIxCOCkJHXrZ6O8bN)Gs9Zj)IDVydqMxMm99qzywCviwC1lwYIrHAXIxC9louoLXW4OzDu(GZFqP(5KFXUxS4flEXF55CCOqpaMdbatBgYowS7fpLzcV4QqS46QBXswmkulw8I)YZ54qHEamhcaM2m8a0Zf7EXtzMWlUkelgziYILSyjlwYILaVQnAqcVtMAdzgbdisvm8j8sP(5Khkk8AzDqSwH36xS4fBbUOuZyiLWSwZf7EXm5KMa2lnykYr8wkbMINMnNougdQIk3oCq(flbEvB0GeEn9BZlGzzY1dbdisOjc8j8Q2Obj8AeqkdEPu)CYdffgqKqdn4t4vTrds4neWaOxE5A7IGxk1pN8qrHbmGbmGbec]] )

end
