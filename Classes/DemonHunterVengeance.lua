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


    spec:RegisterPack( "Vengeance", 20201026, [[duKnFaqiGupsjP2eeAuavNcOSkIkvVcsmlQGBrujPDb4xaXWGihdsAzuHEgvKPrfvxJOITbK03usIXrfLohvuSoIkPmpLG7Ps2NsIdsujvluLYdvcfnrIkXfjQKyJevknsLqPtQekSsQKDQK6NevkwQsOYtLQPQeTvLqv7vXFP0GP4WKwmrEmHjtvxgzZk1NLsJgsDAHxRs1Sr52Qy3I(TQgor54kjPLd1Zr10LCDPy7qW3HOgpqIZtu16vcz(uP2pOhuNLt3RfnRDejhrcvKCeubq1zKJZ60Qm9sEz00LPI7Aln9up00x8u2sAkOPltLN9QFwoD(3Gf00rxLmUCnqaPnk0nsaI)acponmTIpfyDxGWJJaKPl1eSAXihPP71IM1oIKJiHksocQaO6mYXzDsotNlJeZA54SOoD0H3t5inDpXftF1qJCHoFcnl2MSim0S4PSL0uqqxRgAKBe1lryOXrq1bOXrKCePPld)7GrtF1qJCHoFcnl2MSim0S4PSL0uqqxRgAKBe1lryOXrq1bOXrKCejOlORvdn9uLXr)f0G1Wdnsn7n5HgEPfhAKO9JjOr8hjTGgjQnso0OPhAKHj5QY(QISfAco04)KaGUurfFYbKHjXFK0cLlqA4Knk64qQh6sxehTIvUD)zz)Tv2JmHHUGUwn0ixbuirtrEOHqGWYdnvCiOPqtqJkQhdnbhAue0GPsmca6sfv8j)YhCCJSc6sfv8jhLlqeFYBoK9OTHa6sfv8jhLlqWeceMt2J2gcOlvuXNCuUarOmMvfv8PLf8YHup0Lewtp0LkQ4tokxGiugZQIk(0YcE5qQh6YtBk5bceh6sfv8jhLlqekJzvrfFAzbVCi1dDj(N5FKto0LkQ4tokxGiugZQIk(0YcE5qQh6kF8rzqxqxRgAKBdclp0CdRPhAwCFPv8j0LkQ4toGewt)fpAdM932ntpKdX(c04MK2pULaW6IiwChn36PDWOdLfaTQnHmzKhrX)m)JCcSdclVvcRPhathns(cocDPIk(KdiH10JYfirUjCQmlVWXDYHyFj(N5FKtGDqy5Tsyn9ay6OrYVqcrqZJ2GzLXub5HUurfFYbKWA6r5cKDqy5Tsyn9qxQOIp5asyn9OCbsCoptR4tR2GvhI9L)lGDqy5Tsyn9aviUhzl0LkQ4toGewtpkxGe5MWPYS8ch3jhI9L)lGDqy5Tsyn9aviUhzl0LkQ4toGewtpkxGWJ2Gz)TDZ0d5qSVanUjP9JBjaSUiIf3rZTEAhm6qzbqRAtitg5r0)fWoiS8wjSMEGke3JSf6c6sfv8jhq8pZ)iN8lzFfFcDPIk(Kdi(N5FKtokxGWJC3WSsyn9oe7lq7)cGh5UHzLWA6bQqCpYwOlvuXNCaX)m)JCYr5cKcnzr3Kf0LkQ4toG4FM)ro5OCbY(9EcBR3wOj7MPhc6sfv8jhq8pZ)iNCuUaHyYZdnTEsGjc6sfv8jhq8pZ)iNCuUar8PGYcRf5TBMEihI9f4G2)fG4tbLfwlYB3m9qwPgCcuH4EKTicAvuXNaIpfuwyTiVDZ0dbePDZIw0LB37ggZIjbAf3s2ko0cTcpWrbfWGUurfFYbe)Z8pYjhLlqq(XmpcuKwmX)utb5qSVKA2BawSjj2)EaEPI7l4e0LkQ4toG4FM)ro5OCbYHopwE7VTSgr4TEmPho01QHMf7Z8qZIJuzr2cnYTm9qCOz)yOHafs0ue0G1SLGMhdn3dgdAKA2BUdqtSHgzpNhsmcaAKRZqwLNdnfwEOPEOPLkOPqtqd7rM4f0i(N5FKtOrs5KhA(eAue0GPsmcAOKobXbGUurfFYbe)Z8pYjhLlqWKklYw7MPhI7qSVkf3sfqfhYwV1h0cOcih3Ubh8sXTubGMuwHgqMOwXzrYT7sXTubGMuwHgqMOw4YrKadrWvrfiqwkPtq8luD7EhTOllMoAK8vC0zadm3UbVuClvavCiB9wzIY6isR4esicUkQabYsjDcIFHQB37OfDzX0rJKVIZDoyGbDTAOrUqBTHvqZwzmjvChA2pgAA4QeJGgIZPuqCaOlvuXNCaX)m)JCYr5ce0KIllX5ukiOlvuXNCaX)m)JCYr5cKgozJIooq7njkBQh6siVG9f(ZqyLykVCi2xsn7nWHopwE7VTSgr4TEmPhoG)roHUurfFYbe)Z8pYjhLlqA4Knk64qQh6s5OrqtIBX6IESv8yL5qSV8KuZEdG1f9yR4XkZ6jPM9gW)iNUD7jPM9gq8PVrubcKnY7wpj1S3anYqSuClvaOjLvObKjQfCcv3Ulf3sfqfhYwV1h0coIe01QHg5cT1gwbnBLXKuXDOz)yOPHRsmcAIIoCaOlvuXNCaX)m)JCYr5cKgozJIoCOlORvdnYfAtjpqG4qxQOIp5aEAtjpqG4xE68PLllUtChI9vP59iBreCW3nmMftc0kULSvCOfqfXif)jYwRxpAlzDIdMB3GRIkqGSusNG4R4eIrk(tKTwVE0wY6ehrPM9gWtNpTCzXDId4FKtWC7g8if)jYwRxpAlzLdFfKaCuoYD0KYk0ahfuadmOlvuXNCapTPKhiqCuUaH)nmRKIXbHDi2xGRIkqGSusNG4R4eIrk(tKTwVE0wY6ehrPM9gWtNpTCzXDId4FKtWC7g8if)jYwRxpAlzLdFfKaCUChnPScnWrbfWGUurfFYb80MsEGaXr5cePg2Dlbkfwfv8PdX(cnPScnGmclOSwqoibDPIk(Kd4PnL8abIJYfihQ0ZJLH(5bh6sfv8jhWtBk5bcehLlq2bHL3kH10dDbDTAOz9JpkdAwCFPv8j0LkQ4toq(4JYUiM88qtRNeyIGUurfFYbYhFugkxGe5MWPYS8ch3jhI91UHXSysGwXTKTIdTaQicoOlLrzbSz6HScSYrdqPkXiVB3G7)cGhTbZ(B7MPhcathns(coHiOvrfFce5MWPYS8ch3jaE0gmRmMkipyGbDPIk(KdKp(OmuUaHllWrzL(JKdX(cCWLA2BGdv65XYq)8Gd0idr(3WSBS2EOS4RC5eyUDZ)gMDJ12dLfFLlNdg0LkQ4toq(4JYq5cKnXSEcbLxAfF6qSVknVhzlIGRIkqGSusNG4RGQB3LYOSa805ZqaqPkXipyqxQOIp5a5JpkdLlq4FdZkyKIa5qSVah0LYOSa4YcCuwP)ibqPkXipIGdUuZEdCOsppwg6NhCGgziY)gMDJ12dLfFLlNaZTB(3WSBS2EOS4RC5CWad6sfv8jhiF8rzOCbc)BywbJueihI9vPmklaUSahLv6psauQsmYJi)By2nwBpuw8lKGUurfFYbYhFugkxGeNZZ0k(0Qny1HyFTBWYVWLZGe0LkQ4toq(4JYq5cKnXKyQNCi2x7gS8lCTkibDPIk(KdKp(OmuUazJvr1GjhI9f)By2nwBpuw8fUCc6sfv8jhiF8rzOCbcpAdM932ntpKdX(c04MK2pULaW6IiwChn36PDWOdLfaTQnHmzKh6sfv8jhiF8rzOCbchnPyOlvuXNCG8XhLHYfifA8JSTLPbc00rGW84ZzTJi5isOIeQG60rwXzKT8PVyCK94I8qdOcnQOIpHgwWloa010zbV4ZYPlH10plN1OolNoLQeJ8ZTPlWrr4qNoOHgCts7h3sayDrelUJMB90oy0HYcGw1MqMmYdnicnI)z(h5eyhewERewtpaMoAKCOzbOXXPRIk(C68Ony2FB3m9qtnRDCwoDkvjg5NBtxGJIWHoDX)m)JCcSdclVvcRPhathnso0CbnibnicnGgA4rBWSYyQG8txfv850JCt4uzwEHJ70uZANMLtxfv8503bHL3kH10pDkvjg5NBtnRD(SC6uQsmYp3MUahfHdD6(Va2bHL3kH10duH4EKTtxfv850JZ5zAfFA1gSo1SwoZYPtPkXi)CB6cCueo0P7)cyhewERewtpqfI7r2oDvuXNtpYnHtLz5foUttnRb1z50PuLyKFUnDbokch60bn0GBsA)4wcaRlIyXD0CRN2bJouwa0Q2eYKrEObrOX)fWoiS8wjSMEGke3JSD6QOIpNopAdM932ntp0utnDpT1gwnlN1OolNUkQ4ZP7doUrwnDkvjg5NBtnRDCwoDvuXNtx8jV5q2J2gIPtPkXi)CBQzTtZYPRIk(C6ycbcZj7rBdX0PuLyKFUn1S25ZYPtPkXi)CB6QOIpNUqzmRkQ4tll410zbVSPEOPlH10p1SwoZYPtPkXi)CB6QOIpNUqzmRkQ4tll410zbVSPEOP7PnL8abIp1SguNLtNsvIr(520vrfFoDHYywvuXNwwWRPZcEzt9qtx8pZ)iN8PM1RYSC6uQsmYp3MUkQ4ZPlugZQIk(0YcEnDwWlBQhA65JpkBQPMUmmj(JKwZYznQZYPtPkXi)CB6PEOPRlIJwXk3U)SS)2k7rMWtxfv8501fXrRyLB3Fw2FBL9it4PMA6I)z(h5KplN1OolNUkQ4ZPl7R4ZPtPkXi)CBQzTJZYPtPkXi)CB6cCueo0PdAOX)fapYDdZkH10duH4EKTtxfv8505rUBywjSM(PM1onlNUkQ4ZPxOjl6MSMoLQeJ8ZTPM1oFwoDvuXNtF)EpHT1Bl0KDZ0dnDkvjg5NBtnRLZSC6QOIpNoXKNhAA9Kat00PuLyKFUn1SguNLtNsvIr(520f4OiCOthCOb0qJ)laXNcklSwK3Uz6HSsn4eOcX9iBHgeHgqdnQOIpbeFkOSWArE7MPhcis7MfTOlOXTBOz3WywmjqR4wYwXHGMfGMwHh4OGc0a20vrfFoDXNcklSwK3Uz6HMAwVkZYPtPkXi)CB6cCueo0Pl1S3aSytsS)9a8sf3HMfGgNMUkQ4ZPJ8JzEeOiTyI)PMcAQzTZolNUkQ4ZPFOZJL3(BlRreERht6HpDkvjg5NBtnRDMz50PuLyKFUnDbokch60lf3sfqfhYwV1he0Sa0GkGCGg3UHgWHgWHMsXTubGMuwHgqMOGMvGgNfjOXTBOPuClvaOjLvObKjkOzHlOXrKGgWGgeHgWHgvubcKLs6eehAUGguHg3UHMD0IUSy6OrYHMvGghDgObmObmOXTBObCOPuClvavCiB9wzIY6isqZkqJtibnicnGdnQOceilL0jio0CbnOcnUDdn7OfDzX0rJKdnRano35qdyqdytxfv850XKklYw7MPhIp1SgvKMLtxfv850rtkUSeNtPGMoLQeJ8ZTPM1OI6SC6uQsmYp3MUkQ4ZPlKxW(c)ziSsmLxtxGJIWHoDPM9g4qNhlV93wwJi8wpM0dhW)iNtN2Bsu2up00fYlyFH)mewjMYRPM1O64SC6uQsmYp3MUkQ4ZPRC0iOjXTyDrp2kESYMUahfHdD6EsQzVbW6IESv8yLz9KuZEd4FKtOXTBOXtsn7nG4tFJOceiBK3TEsQzVbAKbnicnLIBPcanPScnGmrbnlanoHk042n0ukULkGkoKTERpiOzbOXrKMEQhA6khncAsClwx0JTIhRSPM1O60SC6QOIpNEdNSrrh(0PuLyKFUn1ut3tBk5bceFwoRrDwoDkvjg5NBtxGJIWHo9sZ7r2cnicnGdnGdn7ggZIjbAf3s2koe0Sa0Gk0Gi0eP4pr2A96rBjRtCObmOXTBObCOrfvGazPKobXHMvGgNGgeHMif)jYwRxpAlzDIdnicnsn7nGNoFA5YI7ehW)iNqdyqJB3qd4qtKI)ezR1RhTLSYHdnRanib4OCGg5o0GMuwHg4OGc0ag0a20vrfFoDpD(0YLf3j(uZAhNLtNsvIr(520f4OiCOthCOrfvGazPKobXHMvGgNGgeHMif)jYwRxpAlzDIdnicnsn7nGNoFA5YI7ehW)iNqdyqJB3qd4qtKI)ezR1RhTLSYHdnRanib4COrUdnOjLvObokOanGnDvuXNtN)nmRKIXbHNAw70SC6uQsmYp3MUahfHdD6OjLvObKrybLf0Sa0ihKMUkQ4ZPl1WUBjqPWQOIpNAw78z50vrfFo9dv65XYq)8GpDkvjg5NBtnRLZSC6QOIpN(oiS8wjSM(PtPkXi)CBQPME(4JYMLZAuNLtxfv850jM88qtRNeyIMoLQeJ8ZTPM1oolNoLQeJ8ZTPlWrr4qN(UHXSysGwXTKTIdbnlanOcnicnGdnGgAkLrzbSz6HScSYrdqPkXip042n0ao04)cGhTbZ(B7MPhcathnso0Sa04e0Gi0aAOrfv8jqKBcNkZYlCCNa4rBWSYyQG8qdyqdytxfv850JCt4uzwEHJ70uZANMLtNsvIr(520f4OiCOthCObCOrQzVbouPNhld9ZdoqJmObrOH)nm7gRThklo0SYf04e0ag042n0W)gMDJ12dLfhAw5cACo0a20vrfFoDUSahLv6pstnRD(SC6uQsmYp3MUahfHdD6LM3JSfAqeAahAurfiqwkPtqCOzfObvOXTBOPugLfGNoFgcakvjg5HgWMUkQ4ZPVjM1tiO8sR4ZPM1YzwoDkvjg5NBtxGJIWHoDWHgqdnLYOSa4YcCuwP)ibqPkXip0Gi0ao0ao0i1S3ahQ0ZJLH(5bhOrg0Gi0W)gMDJ12dLfhAw5cACcAadAC7gA4FdZUXA7HYIdnRCbnohAadAaB6QOIpNo)BywbJueOPM1G6SC6uQsmYp3MUahfHdD6LYOSa4YcCuwP)ibqPkXip0Gi0W)gMDJ12dLfhAUGgKMUkQ4ZPZ)gMvWifbAQz9QmlNoLQeJ8ZTPlWrr4qN(Ublp0SWf04minDvuXNtpoNNPv8PvBW6uZANDwoDkvjg5NBtxGJIWHo9DdwEOzHlOzvqA6QOIpN(Mysm1ttnRDMz50PuLyKFUnDbokch605FdZUXA7HYIdnlCbnonDvuXNtFJvr1GPPM1OI0SC6uQsmYp3MUahfHdD6GgAWnjTFClbG1frS4oAU1t7GrhklaAvBczYi)0vrfFoDE0gm7VTBMEOPM1OI6SC6QOIpNohnP4PtPkXi)CBQznQoolNUkQ4ZPxOXpY2wMgiqtNsvIr(52utn101Mc9JNEpolMtn1ma]] )

end
