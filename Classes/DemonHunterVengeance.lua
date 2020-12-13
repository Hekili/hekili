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


    spec:RegisterPack( "Vengeance", 20201213, [[dG0TJaqijvEeHu2evYNuLugfH6ueXQKerVIi1SOszxk8lc0WGuogK0YKu1ZOImnvj6AuPABesY3uLqJtvs15KeP1riPmpjH7bH9rf1bjKkTqcXdjKQAIQsWfvLeAJesv(iHurJuvsYjvLeTsjLzsiPQDcjwQKi8uLAQQsTvvjP(kHuHXQkjyVa)LQgmuhM0IvvpMIjlXLrTzf9zvXOjOtl1RjsMns3wj7w0VbnCQWXjKuz5iEoLMUW1jQTlj9DivJxsuNNawpHeZhI2Vkdqf8gSlAWauQhT6rd16r1PbQO5(lrZjWoeWbd2ouJu6dd2PUyW(vZ5dRPHbBhQauOwaVbBluMyyWwyeoSIAck4thcL)ddCjOTxYunAyAi6me02lJGG9xUPXRmbFWUObdqPE0QhnuRhvNgOIM7VenubBRd2aqX9xhvWwyxkCc(GDHTgWw0o8lWlyE4xLCgm5WVAoFynn8vt0o8lWgE9zYHr1j3oC9OvpAGTdcC2ugSfTd)c8cMh(vjNbto8RMZhwtdF1eTd)cSHxFMCyuDYTdxpA1J2v7QPMOHPD4GWg46RbIpmckx8tQkaxqVZhFaRCNxn1enmTdhe2axFnKgHGYw23bVCl1fJqffRqLOw)eMHho9oGOZKR2vt0o8RyLzJCWLdZvzIaho6fF4qiFy1eqYHB7H1QAt1pLhxn1enmTsJqWQkP1pLDl1fJ4t0S4)YnT4wvLkZicLYzm0hy2IsNp(jvxSDWP(PCXvOuoJXxMKD(4vAxLhCQFkxCfkLZyyeQecx8tkBfo4u)uUC1ut0W0kncblTLi7iUAQjAyALgHGgyALxSFPpT5QPMOHPvAecs4QmXY(L(0MRMAIgMwPriyiKar3)q1Uk7wpr8LNZXKP(pC9vszXzmSHAKcH7Ue)LNZrVwqQgnm9QmrhYoqISUV8CowCOliXHqOTTdzhsUAQjAyALgHGgLs9QjAy6PTnCl1fJ4t0S4wpruvjT(P84t0S4)YnTC1ut0W0kncbnkL6vt0W0tBB4wQlgrHNCA7QS9QPMOHPvAecAuk1RMOHPN22WTuxmcdeslq0t7vtnrdtR0ie0OuQxnrdtpTTHBPUyejKSu6v7QjAhw0RzIahweIMLdxjGHgnmVAQjAyAhFIMfeZMjc4)enlxn1enmTJprZI0ieSxlivJgMEvMOU1tefymMnteW)jAwgrBKQZNR2vtnrdt7WaH0ce90IWbmAyE1ut0W0omqiTarpTsJqqdmnCgen4IFs1f7wpriUUcmggyA4miAWf)KQl2)Lj5iAJuD(4Qo1enmhgyA4miAWf)KQlE0PFs7hHbsKtzk1tyJqL8W(OxCfpMYyPvwYvtnrdt7WaH0ce90kncbrhsOLQCNEcBHPMg2TEI4lpNdAp5pfcldBOgPQWPRMAIgM2HbcPfi6PvAecU4fKiGho9uztx8fcRl7vt0o8RcslhUsWQJoFoSOhvxS9Wti5WCLzJCWhMO5dFyi5Ws1u6H)YZP1Td3Zd7aAT9NYJdl6srxfWE4GiWHd4HF44WHq(Wui6SnoSbcPfi65H)QLlhgMhwRQnv)u(WCYRMTJRMAIgM2HbcPfi6PvAecsy1rNp(jvxS1TEIiuYdhJOxSpG(sZvG6WDKiflouYdhdHSsdHdhMW5xhnKidL8WXqiR0q4WHjQar9OjXLy1eDv2ZjVA2IavKiN9JWWt4L2P156RujsqIuCOKhogrVyFa9omHVE0C2j0CjwnrxL9CYRMTiqfjYz)im8eEPDAD(LVuIKRMOD4xGNQmno8uP0VAK6Wti5WYw9t5dZwlNg2oUAQjAyAhgiKwGONwPriOqwjHNTwon8vtnrdt7WaH0ce90kncbLTSVdE5gpNSj8PUyegbmuyqGzB8FQAd36jIV8Cow8cseWdNEQSPl(cH1LDuGONxn1enmTddeslq0tR0ieu2Y(o4LBPUyeQvyvnzRNOIcK4nqIsDRNik8xEohevuGeVbsuQVWF55CuGONirw4V8ComWSiBIUk77ukFH)YZ5q2HRqjpCmeYkneoCyIkCcvKidL8WXi6f7dOV0Cf1J2vt0o8lWtvMghEQu6xnsD4jKCyzR(P8H7Gx2Xvtnrdt7WaH0ce90kncbLTSVdEzVAQjAyAhgiKwGONwPriOTZPm1)jAwCRNiQRaJHTZPm1)jAwgrBKQZNRMAIgM2HbcPfi6PvAecgczVq5mUAQjAyAhgiKwGONwPri4ewkmXhqFiK9tQU4RMAIgM2HbcPfi6PvAecYubSTM(cBimF1UAI2HFbEYPTRY2RMAIgM2rHNCA7QSfrHxW0BD0sXw36jIqtP68XLyXtzk1tyJqL8W(OxCfO6QtdC15JVOl9H9ozLGePy1eDv2ZjVA26StU60axD(4l6sFyVtwxF55Cu4fm9whTuSDuGONsqIuCNg4QZhFrx6d7D36mAJ6DVskKvAiCS0klrYvtnrdt7OWtoTDv2kncbTqzQ)ResZe36jcXQj6QSNtE1S1zNC1PbU68Xx0L(WENSU(YZ5OWly6ToAPy7OarpLGeP4onWvNp(IU0h27U1z0gVSskKvAiCS0kl5QPMOHPDu4jN2UkBLgHGFzQuEUYbrnrdt36jcHSsdHdhmXWzuH7OD1ut0W0ok8KtBxLTsJqWfh6csCieABRB9erDIdLYzmk8cMTzWP(PCrIlX1zGv5uZyuLZqOaeKiRRaJHTZPm1)jAwgrBKQZhjirk(dTwxZ(ry4j8s70wbQUl5QPMOHPDu4jN2UkBLgHGZMjc4)enlxTRMODyuGKLspCLagA0W8QPMOHPDKqYsPsJqWoNmjvQ3gKwk2TEIyktPEcBeQKh2h9IRavxIRlukNXys1f7ne1kCWP(PCbjsXfymS9tt9WPFs1fpi8s70wHtUQtnrdZrNtMKk1BdslfpS9tt9oOQHlsKC1ut0W0osizPuPri4xMkLNRCqut0W8QPMOHPDKqYsPsJqqRJM0H)dxF36jcXI)YZ5yXHUGehcH22oKD4kukNXysutit4bN6NYfxwOm1pj6ZIZW6mcNKGePfkt9tI(S4mSoJ4LsUAQjAyAhjKSuQ0ieCYuFHRQ2qJgMU1teHMs15JlXQj6QSNtE1S1zurImukNXOWly2MbN6NYfjxn1enmTJeswkvAecAHYuVHYAv2TEIqS4qPCgdRJM0H)dx)bN6NYfxwOm1pj6ZIZWIanjirwxOuoJH1rt6W)HR)Gt9t5IexIfhkLZymjQjKj8Gt9t5IRPmraNr4U7sqIuCDHs5mgtIAczcp4u)uU4AkteWzeViAsqI0aH0ce9CmzQVWvvBOrdZbHxANwNdL8WXi6f7dOV0msKI)YZ5yXHUGehcH22oKD4sS4qPCgJjrnHmHhCQFkxCnLjc4mcNCxcsKIRlukNXysutit4bN6NYfxtzIaoJWD0KirIKRMAIgM2rcjlLkncb71cs1OHPxLjQB9eHyXvvsRFkp(enl(VCtlUmqiTarphZMjc4)enldcV0oToJkAsqISUQkP1pLhFIMf)xUPfjUMYebQarLI2vtnrdt7iHKLsLgHGtM(PAHDRNiMYebQaHOcTRMAIgM2rcjlLkncbNe1eYe2TEIqS4qPCgdRJM0H)dx)bN6NYfxwOm1pj6ZIZWwbcNKGeP46cLYzmSoAsh(pC9hCQFkxCjw8xEohlo0fK4qi022HSdxtzIavGWD3LGeP4V8CowCOliXHqOTTJce901uMiqfiEr0KirIKRMAIgM2rcjlLkncbT9tt9WPFs1f7wpruNydSkNAgdPeG0A6IiN8esE4brffM2sj06l8SP8IZqYvtnrdt7iHKLsLgHGwHSsUAQjAyAhjKSuQ0iemesGO7FOAxLb7QmX2WeGs9OvpAOIA9ob2ORKSZhlyl6q0TsGYRefrNIAh(WVfYhUxoGK4Wti5WVwcjlL(AhMWI6KBcxoSfU4dRYbCPbxoSrOMpSDC1e13jF4kvu7WI(WSktcUC4xJiN8esE4XRWRD4aE4xJiN8esE4XRWGt9t5YRDyXOwzjJR2v7vUCajbxoSO6WQjAyEyABd74Qb202gwWBW(t0SaEdqbvWBWwnrdtWE2mra)NOzbS5u)uUaebeauQh8gS5u)uUaebSnKoysRGDbgJzZeb8FIMLr0gP68bSvt0WeS71cs1OHPxLjkiabyx4PktdWBakOcEd2CQFkxaIa2qhGTLdWwnrdtWUQsA9tzWUQsLzWoukNXqFGzlkD(4NuDX2bN6NYLd76WHs5mgFzs25JxPDvEWP(PC5WUoCOuoJHrOsiCXpPSv4Gt9t5cyxvj(uxmy)jAw8F5MwabaL6bVbB1enmb7sBjYocWMt9t5cqeqaqXjWBWwnrdtW2atR8I9l9PnGnN6NYfGiGaGYlbVbB1enmbBcxLjw2V0N2a2CQFkxaIacakUdEd2CQFkxaIa2gshmPvW(lpNJjt9F46RKYIZyyd1i1HrCy3pSRdl(WF55C0RfKQrdtVkt0HSJdJe5HR7WF55CS4qxqIdHqBBhYooSeWwnrdtWoesGO7FOAxLbbafrf4nyZP(PCbicyBiDWKwb7QkP1pLhFIMf)xUPfWwnrdtW2OuQxnrdtpTTbytBB4tDXG9NOzbeauErWBWMt9t5cqeWwnrdtW2OuQxnrdtpTTbytBB4tDXGDHNCA7QSfeauEDWBWMt9t5cqeWwnrdtW2OuQxnrdtpTTbytBB4tDXGTbcPfi6PfeauQuWBWMt9t5cqeWwnrdtW2OuQxnrdtpTTbytBB4tDXGDcjlLccqa2oiSbU(AaEdqbvWBWwnrdtW(dJGYf)KQcWf078XhWk3jyZP(PCbiciaOup4nyZP(PCbicyN6IbBvuScvIA9tygE407aIotaB1enmbBvuScvIA9tygE407aIotabiaBdeslq0tl4nafubVbB1enmbBhWOHjyZP(PCbiciaOup4nyZP(PCbicyBiDWKwbBXhUUdxGXWatdNbrdU4NuDX(VmjhrBKQZNd76W1Dy1enmhgyA4miAWf)KQlE0PFs7hHXHrI8Wtzk1tyJqL8W(Ox8HR4WpMYyPv(WsaB1enmbBdmnCgen4IFs1fdcakobEd2CQFkxaIa2gshmPvW(lpNdAp5pfcldBOgPoCfh2jWwnrdtWgDiHwQYD6jSfMAAyqaq5LG3GTAIgMG9IxqIaE40tLnDXxiSUSGnN6NYfGiGaGI7G3GnN6NYfGiGTH0btAfSdL8WXi6f7dOV08HR4WOoC)WirEyXhw8HdL8WXqiR0q4WHjoSZh(1r7WirE4qjpCmeYkneoCyIdxbIdxpAhwYHDDyXhwnrxL9CYRMThgXHr9WirE4z)im8eEPDApSZhU(k9WsoSKdJe5HfF4qjpCmIEX(a6DycF9ODyNpStODyxhw8Hvt0vzpN8Qz7HrCyupmsKhE2pcdpHxAN2d78HF5lpSKdlbSvt0WeSjS6OZh)KQl2ccakIkWBWwnrdtWwiRKWZwlNggS5u)uUaebeauErWBWMt9t5cqeWwnrdtW2iGHcdcmBJ)tvBa2gshmPvW(lpNJfVGeb8WPNkB6IVqyDzhfi6jyZZjBcFQlgSncyOWGaZ24)u1gGaGYRdEd2CQFkxaIa2QjAyc2QvyvnzRNOIcK4nqIsbBdPdM0kyx4V8CoiQOajEdKOuFH)YZ5OarppmsKhUWF55CyGzr2eDv23Pu(c)LNZHSJd76WHsE4yiKvAiC4WehUId7eQhgjYdhk5HJr0l2hqFP5dxXHRhnWo1fd2QvyvnzRNOIcK4nqIsbbaLkf8gSvt0WeSLTSVdEzbBo1pLlarabafurd8gS5u)uUaebSnKoysRGDDhUaJHTZPm1)jAwgrBKQZhWwnrdtW225uM6)enlGaGcQOcEd2QjAyc2Hq2luodWMt9t5cqeqaqb16bVbB1enmb7jSuyIpG(qi7NuDXGnN6NYfGiGaGcQobEd2QjAyc2mvaBRPVWgcZGnN6NYfGiGaeGDHNCA7QSf8gGcQG3GnN6NYfGiGTH0btAfSdnLQZNd76WIpS4dpLPupHncvYd7JEXhUIdJ6HDD4onWvNp(IU0h27K9WsomsKhw8Hvt0vzpN8Qz7HD(WoDyxhUtdC15JVOl9H9ozpSRd)LNZrHxW0BD0sX2rbIEEyjhgjYdl(WDAGRoF8fDPpS3D7HD(WOnQ39dxjpSqwPHWXsR8HLCyjGTAIgMGDHxW0BD0sXwqaqPEWBWMt9t5cqeW2q6GjTc2IpSAIUk75KxnBpSZh2Pd76WDAGRoF8fDPpS3j7HDD4V8Cok8cMERJwk2okq0Zdl5WirEyXhUtdC15JVOl9H9UBpSZhgTXlpCL8WczLgchlTYhwcyRMOHjyBHYu)xjKMjGaGItG3GnN6NYfGiGTH0btAfSfYkneoCWedNXHR4WUJgyRMOHjy)LPs55khe1enmbbaLxcEd2CQFkxaIa2gshmPvWUUdl(WHs5mgfEbZ2m4u)uUCyjh21HfF46oSbwLtnJrvodHcqomsKhUUdxGXW25uM6)enlJOns15ZHLCyKipS4d)Hw7HDD4z)im8eEPDApCfhgv3pSeWwnrdtWEXHUGehcH22ccakUdEd2QjAyc2ZMjc4)enlGnN6NYfGiGaeGDcjlLcEdqbvWBWMt9t5cqeW2q6GjTc2tzk1tyJqL8W(Ox8HR4WOEyxhw8HR7WHs5mgtQUyVHOwHdo1pLlhgjYdl(WfymS9tt9WPFs1fpi8s70E4koSth21HR7WQjAyo6CYKuPEBqAP4HTFAQ3bvnC5WsoSeWwnrdtWUZjtsL6TbPLIbbaL6bVbB1enmb7Vmvkpx5GOMOHjyZP(PCbiciaO4e4nyZP(PCbicyBiDWKwbBXhw8H)YZ5yXHUGehcH22oKDCyxhoukNXysutit4bN6NYLd76WwOm1pj6ZIZWEyNrCyNoSKdJe5HTqzQFs0NfNH9WoJ4WV8WsaB1enmbBRJM0H)dxFqaq5LG3GnN6NYfGiGTH0btAfSdnLQZNd76WIpSAIUk75KxnBpSZhg1dJe5HdLYzmk8cMTzWP(PC5WsaB1enmb7jt9fUQAdnAyccakUdEd2CQFkxaIa2gshmPvWw8HfF4qPCgdRJM0H)dx)bN6NYLd76WwOm1pj6ZIZWEyehgTdl5WirE46oCOuoJH1rt6W)HR)Gt9t5YHLCyxhw8HfF4qPCgJjrnHmHhCQFkxoSRdpLjcCyNrCy3D)WsomsKhw8HR7WHs5mgtIAczcp4u)uUCyxhEkte4WoJ4WViAhwYHrI8WgiKwGONJjt9fUQAdnAyoi8s70EyNpCOKhogrVyFa9LMpmsKhw8H)YZ5yXHUGehcH22oKDCyxhw8HfF4qPCgJjrnHmHhCQFkxoSRdpLjcCyNrCyNC)WsomsKhw8HR7WHs5mgtIAczcp4u)uUCyxhEkte4WoJ4WUJ2HLCyjhwYHLa2QjAyc2wOm1BOSwLbbafrf4nyZP(PCbicyBiDWKwbBXhw8HRQKw)uE8jAw8F5MwoSRdBGqAbIEoMnteW)jAwgeEPDApSZhgv0oSKdJe5HR7WvvsRFkp(enl(VCtlhwYHDD4PmrGdxbIdxPOb2QjAyc29AbPA0W0RYefeauErWBWMt9t5cqeW2q6GjTc2tzIahUcehwuHgyRMOHjypz6NQfgeauEDWBWMt9t5cqeW2q6GjTc2IpS4dhkLZyyD0Ko8F46p4u)uUCyxh2cLP(jrFwCg2dxbId70HLCyKipS4dx3HdLYzmSoAsh(pC9hCQFkxoSRdl(WIp8xEohlo0fK4qi022HSJd76WtzIahUceh2D3pSKdJe5HfF4V8CowCOliXHqOTTJce98WUo8uMiWHRaXHFr0oSKdl5WsoSeWwnrdtWEsutityqaqPsbVbBo1pLlaraBdPdM0kyx3HfFydSkNAgdPeG0AEyxhMiN8esE4brffM2sj06l8SP8IZyWP(PC5WsaB1enmbBB)0upC6NuDXGaGcQObEd2QjAyc2wHSsaBo1pLlarabafurf8gSvt0WeSdHei6(hQ2vzWMt9t5cqeqacqa2QCiesa7DVe9bbiaa]] )

end
