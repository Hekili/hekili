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


    spec:RegisterPack( "Vengeance", 20201113, [[dKK0GaqivP6rQsXMuv5tkQQgLQOtPkzvusLEfQOzrj5wOcf2Lk9liXWqv5yQQAzuv8muvnnkPCnubBJsQ6BkQknofv4CkQO1POQyEuv5EQk7JQQoiQqPfcj9quHQMiQq6IkQcTrfvbFeviYivuLCsfvPwjvPzIku0ovfwkLuXtLQPQOSvfvrFfviQXIkuzVk9xQmychM0IH4XumzPCzKnRIpRiJgsDAjVgvQzd1Tvy3c)gy4uIJJkewokpNOPl66uQTtv8DujJxrLopvLwVQuA(Ok7h07)D22BAs7dF4Zh(())p)xF(Z)CynoS90xl02TOgU1jA7HoOTppPyI0WqB3I6lgOTD22LaBMH2o6mTiNpOGYuLOTrUgWafznSXAwGWW0tIISggu2oIDHZ5DSiBVPjTp8HpF47)))8F95VpwJpoSDPfYSp4WC8F7ORwJIfz7nsA2(BGcoknabumVSJKyqX8KIjsddb9(gO4bWdnqigu8NFRGcF4Zh(2Ufg4uyA7Vbk4O0aeqX8YosIbfZtkMinme07BGIhap0aHyqXF(Tck8HpF4d6f69nqrpuls0GekyA1Gce7ZHAqHm1ucfi0bWiOWagiAcfi0ufsOqJguyHrCmSaYSIjOOKqrde0f6vnzbc51cJmGbIMC(HITKCvsdRcDqF6BLOvMkDhqKoWXzbWfXGEHEFdumpoxYyNudkipeZxOiRbbfjAckutcyqrjHc1JwyfbtxOx1KfiKC(HIhLvkcMSk0b9HW0O5qSlCZkpk2M(sftrE1jquVTIj3bRdsEPqrWu7xQykYlInlQyYP4YdDPqrWu7xQykYRbTYyuZDWKe9LcfbtnOx1KfiKC(HsRKmBlj0RAYceso)qXacP9GCdDQmqVQjlqi58dfg5HysYn0PYa9QMSaHKZpus0maxUjSwEiRQZhI95Cpe2HagikRnOiVYunC)XHFprSpNBngaSMfiCQntV2w4X7De7Z5oOuhaMf0azjV2wEb9QMSaHKZpumkg7utwGWHlzAvOd6dHPrZQ685rzLIGPlctJMdXUWnOx1KfiKC(HIrXyNAYceoCjtRcDqFn6qHS8qsOx1KfiKC(HIrXyNAYceoCjtRcDqFgaa3aCfsOx1KfiKC(HIrXyNAYceoCjtRcDqFbGnum0l07BGI5HIy(cfOY0ObfwhqQzbcOx1KfiKxeMgTVtrmFDimnAqVQjlqiVimnAC(HsngaSMfiCQntTQoFnqEpfX81HW0ODZYWDftqVqVQjlqiVgaa3aCfYplGSab0RAYceYRbaWnaxHKZpumGWqrY0KAUdwhKv15757nqEnGWqrY0KAUdwhKdXMf3SmCxX0V3vtwG4AaHHIKPj1ChSoOBfUdUMqN84DSXyhJmOv2e5YAq(nzA3Ho3xqVQjlqiVgaa3aCfso)qHlad38qv4yKeeAyiRQZhI95CX1HqWaq7kt1WTF8d9QMSaH8AaaCdWvi58dLbnamFDGJdBBQMRXiDiHEFdumVa4guyDi1sftqX8awhKekoaguqZLm2jbfmnMiOaWGcUlmgkqSphPvqrDGclaPSqW0fk4yXCP(kHIK5luKaOyIsOirtqbgWfjtOWaa4gGRakquj1GcqafQhTWkcMGckOrrYl0RAYceYRbaWnaxHKZpuyKAPIj3bRdsAvD(sLnr5nRb5sGRvKF)VCGhVNptLnr5fnP4e91Ij9Fo4JhVuztuErtkorFTys)(8HVx)EQMS8qokOrrYV)84DQj0PJrdTcP)(mNVEXJ3ZuztuEZAqUe4SysNp85p)897PAYYd5OGgfj)(ZJ3PMqNogn0kK(BnR96f07BGcokDuBCcfhfJrud3qXbWGcBPIGjOGKskmK8c9QMSaH8AaaCdWvi58df0KYshjLuyiOx1KfiKxdaGBaUcjNFOyljxL0Wk6Cit6cDqFgFnyqYarzCiyvMwvNpe7Z5oObG5RdCCyBt1CngPd5Tb4kGEvtwGqEnaaUb4kKC(HITKCvsdRcDqFQeThniPJPVfWCgatXwvNVgHyFoxM(waZzamf7AeI95CBaUcE8AeI95CnGOzBYYd5QGBxJqSpNRTLFPYMO8IMuCI(AXK(X)FE8sLnr5nRb5sGRvKF(Wh07BGcokDuBCcfhfJrud3qXbWGcBPIGjOOsAiVqVQjlqiVgaa3aCfso)qXwsUkPHe6vnzbc51aa4gGRqY5hkYko2yhctJMv1579giVYko2yhctJ2nld3vmb9QMSaH8AaaCdWvi58dLen5qBhj0RAYceYRbaWnaxHKZpuoGwJyUe4s0K7G1bb9QMSaH8AaaCdWvi58dfc7RS0W1idJiOxO33afCu6qHS8qsOx1KfiK3gDOqwEi5xJgGWjTuCtsRQZxQb3vm975ZJng7yKbTYMixwdYV))QWagvm5A6qNih)Yx849unz5HCuqJIK(Z)VkmGrftUMo0jYXV8hI95CB0aeoPLIBsEBaUIx849ScdyuXKRPdDICCq6pFxF4G1fnP4e9DOZ91lOx1KfiK3gDOqwEijNFOib2yhIYyfXSQoFpvtwEihf0OiP)8)RcdyuXKRPdDIC8l)HyFo3gnaHtAP4MK3gGR4fpEpRWagvm5A6qNihhK(Z31Awx0KIt03Ho3xqVQjlqiVn6qHS8qso)qbXgZTJMBYutwGWQ68HMuCI(AHygks)4aFqVQjlqiVn6qHS8qso)qzqPoamlObYsAvD(E)zQykYBJgGOmxkuem1E9757gGhk0iVEOir7l7sHIGPgpEV3a5vwXXg7qyA0Uzz4UIPx849ebiL)o1e60XOHwH0V)C4f0RAYceYBJouilpKKZpuofX81HW0Ob9c9(gO4bGnumuyDaPMfiGEvtwGqEdaBOyo)qPIdXcf7KjR4MSQoFhBm2XidALnrUSgKF))989uXuK3dwhKZWuj6lfkcMA849SbYRSMkSdCChSoOlJgAfs)4)37QjlqCR4qSqXozYkUPRSMkSZcwnu71lOx1KfiK3aWgkMZpuqSXC7O5Mm1KfiGEvtwGqEdaBOyo)qrAPyv6qadeRQZ3te7Z5oOuhaMf0azjV2w(jb2y3HPtdksP)F8ZJNeyJDhMonOiL()znOx1KfiK3aWgkMZpuoe21ipQm1SaHv15l1G7kM(9unz5HCuqJIK()NhVuXuK3gnarzUuOiyQ9c6vnzbc5naSHI58dfjWg7mys9qwvNVNVNkMI8kTuSkDiGbYLcfbtTFpFIyFo3bL6aWSGgil512YpjWg7omDAqrk9)J)x84jb2y3HPtdksP)Fw71lOx1KfiK3aWgkMZpuKaBSZGj1dzvD(sftrELwkwLoeWa5sHIGP2pjWg7omDAqrk)4d6vnzbc5naSHI58dLAmaynlq4uBMAvD(E(0JYkfbtxeMgnhIDHB)maaUb4kUNIy(6qyA0UmAOvi9)pFV4X7DpkRuemDryA0Ci2fU963XM5RFFZjFqVQjlqiVbGnumNFOCimcwBKv157yZ81VpRNpOx1KfiK3aWgkMZpuom1K2mYQ68jb2y3HPtdksPFF8d9QMSaH8ga2qXC(HISMkSdCChSoiRQZ37m7Goa2eDz6BjCXnAPRrNctdkYlXryxwSqnOx1KfiK3aWgkMZpuKOjLb9QMSaH8ga2qXC(HsIMb4YnH1YdTDpetwGyF4dF(W3F(8X63oxklQysUDoYCSwNhZ7hCKMpqbumdnbf1WcGLqXbWGI5VrhkKLhso)qbJ4iSlg1GcjyqqHANGHMudkmO1yIKxOxoMvqqH1Mpqbhpi8qSKAqX8BaEOqJ8YXDPqrWuB(HIeafZVb4HcnYlh38dfp)p3xxOxO359WcGLudkSEOqnzbcOaxYuEHE3oUKPCNTDeMgTD2(4)oB7QjlqS9trmFDimnABNcfbtTf1n3h(SZ2ofkcMAlQB3WQKyLU9giVNIy(6qyA0Uzz4UIPTRMSaX2RXaG1SaHtTz6MBU9gDuBCUZ2h)3zBNcfbtTf1TdSSDjLBxnzbIT7rzLIGPT7rX202tftrE1jquVTIj3bRdsEPqrWudk(bfPIPiVi2SOIjNIlp0LcfbtnO4huKkMI8AqRmg1ChmjrFPqrWuB7EuMl0bTDeMgnhIDHBBUp8zNTD1Kfi2ERKmBl52PqrWuBrDZ9b)7STRMSaX2nGqApi3qNkZ2PqrWuBrDZ9H12zBxnzbITZipetsUHovMTtHIGP2I6M7doSZ2ofkcMAlQB3WQKyLUDe7Z5EiSdbmquwBqrELPA4gk(Gcoaf)GINqbI95CRXaG1SaHtTz612cuWJhu8ouGyFo3bL6aWSGgil512cu8A7QjlqS9endWLBcRLhAZ9H1VZ2ofkcMAlQBxnzbITBum2PMSaHdxYC7gwLeR0T7rzLIGPlctJMdXUWTTJlz6cDqBhHPrBZ9X8DNTDkuem1wu3UAYceB3OyStnzbchUK52XLmDHoOT3OdfYYdj3CFmh7STtHIGP2I62vtwGy7gfJDQjlq4WLm3oUKPl0bTDdaGBaUc5M7J5CNTDkuem1wu3UAYceB3OyStnzbchUK52XLmDHoOTha2qXBU52TWidyGO5oBF8FNTDkuem1wu3EOdA76BLOvMkDhqKoWXzbWfX2UAYceBxFReTYuP7aI0boolaUi2MBUDdaGBaUc5oBF8FNTD1Kfi2UfqwGy7uOiyQTOU5(WND22PqrWuBrD7gwLeR0T)ekEhkAG8AaHHIKPj1ChSoihInlUzz4UIjO4hu8ouOMSaX1acdfjttQ5oyDq3kChCnHoHcE8GIJng7yKbTYMixwdck8dkMmT7qNlu8A7QjlqSDdimuKmnPM7G1bT5(G)D22PqrWuBrD7gwLeR0TJyFoxCDiema0UYunCdf(bf8VD1Kfi2oxagU5HQWXiji0WqBUpS2oB7QjlqS9bnamFDGJdBBQMRXiDi3ofkcMAlQBUp4WoB7uOiyQTOUDdRsIv62tLnr5nRb5sGRveu4hu8)YbOGhpO4ju8eksLnr5fnP4e91IjHc)HI5GpOGhpOiv2eLx0KIt0xlMek87dk8HpO4fu8dkEcfQjlpKJcAuKek(GI)qbpEqXPMqNogn0kKqH)qHpZju8ckEbf84bfpHIuztuEZAqUe4SysNp8bf(df8Zhu8dkEcfQjlpKJcAuKek(GI)qbpEqXPMqNogn0kKqH)qH1Sgu8ckETD1Kfi2oJulvm5oyDqYn3hw)oB7QjlqSD0KYshjLuyOTtHIGP2I6M7J57oB7uOiyQTOUDdRsIv62rSpN7GgaMVoWXHTnvZ1yKoK3gGRy7QjlqSDJVgmizGOmoeSkZTtNdzsxOdA7gFnyqYarzCiyvMBUpMJD22PqrWuBrD7HoOTRs0E0GKoM(waZzamfVD1Kfi2Ukr7rds6y6BbmNbWu82nSkjwPBVri2NZLPVfWCgatXUgHyFo3gGRak4XdkAeI95CnGOzBYYd5QGBxJqSpNRTfO4huKkBIYlAsXj6Rftcf(bf8)hk4XdksLnr5nRb5sGRveu4hu4dFBUpMZD22vtwGy72sYvjnKBNcfbtTf1n3h)5BNTDkuem1wu3UHvjXkD7VdfnqELvCSXoeMgTBwgURyA7QjlqSDzfhBSdHPrBZ9X))7STRMSaX2t0KdTDKBNcfbtTf1n3h)9zNTD1Kfi2(b0AeZLaxIMChSoOTtHIGP2I6M7J)8VZ2UAYceBNW(klnCnYWiA7uOiyQTOU5MBVrhkKLhsUZ2h)3zBNcfbtTf1TByvsSs3EQb3vmbf)GINqXtO4yJXogzqRSjYL1GGc)GI)qXpOOcdyuXKRPdDIC8lHIxqbpEqXtOqnz5HCuqJIKqH)qb)qXpOOcdyuXKRPdDIC8lHIFqbI95CB0aeoPLIBsEBaUcO4fuWJhu8ekQWagvm5A6qNihhKqH)qbFxF4auyDHc0KIt03HoxO4fu8A7QjlqS9gnaHtAP4MKBUp8zNTDkuem1wu3UHvjXkD7pHc1KLhYrbnkscf(df8df)GIkmGrftUMo0jYXVek(bfi2NZTrdq4KwkUj5Tb4kGIxqbpEqXtOOcdyuXKRPdDICCqcf(df8DTguyDHc0KIt03HoxO412vtwGy7sGn2HOmwrSn3h8VZ2ofkcMAlQB3WQKyLUD0KIt0xleZqrcf(bfCGVTRMSaX2rSXC7O5Mm1Kfi2CFyTD22PqrWuBrD7gwLeR0T)ou8eksftrEB0aeL5sHIGPgu8ck(bfpHI3HcdWdfAKxpuKO9Lbf84bfVdfnqELvCSXoeMgTBwgURyckEbf84bfpHceGucf)GItnHoDmAOviHc)GI)CakETD1Kfi2(GsDaywqdKLCZ9bh2zBxnzbITFkI5RdHPrB7uOiyQTOU5MBpaSHI3z7J)7STtHIGP2I62nSkjwPB)yJXogzqRSjYL1GGc)GI)qXpO4ju8ouKkMI8EW6GCgMkrFPqrWudk4XdkEcfnqEL1uHDGJ7G1bDz0qRqcf(bf8df)GI3Hc1KfiUvCiwOyNmzf30vwtf2zbRgQbfVGIxBxnzbITxXHyHIDYKvCtBUp8zNTD1Kfi2oInMBhn3KPMSaX2PqrWuBrDZ9b)7STtHIGP2I62nSkjwPB)juGyFo3bL6aWSGgil512cu8dkKaBS7W0PbfPek8)dk4hk4XdkKaBS7W0PbfPek8)dkS22vtwGy7slfRshcyGS5(WA7STtHIGP2I62nSkjwPBp1G7kMGIFqXtOqnz5HCuqJIKqH)qXFOGhpOivmf5TrdquMlfkcMAqXRTRMSaX2pe21ipQm1SaXM7doSZ2ofkcMAlQB3WQKyLU9NqX7qrQykYR0sXQ0Hagixkuem1GIFqXtO4juGyFo3bL6aWSGgil512cu8dkKaBS7W0PbfPek8)dk4hkEbf84bfsGn2Dy60GIucf()bfwdkEbfV2UAYceBxcSXodMup0M7dRFNTDkuem1wu3UHvjXkD7PIPiVslfRshcyGCPqrWudk(bfsGn2Dy60GIucfFqbFBxnzbITlb2yNbtQhAZ9X8DNTDkuem1wu3UHvjXkD7pHINqHhLvkcMUimnAoe7c3GIFqHbaWnaxX9ueZxhctJ2LrdTcju4pu8NpO4fuWJhu8ou4rzLIGPlctJMdXUWnO4fu8dko2mFHc)(GI5KVTRMSaX2RXaG1SaHtTz6M7J5yNTDkuem1wu3UHvjXkD7hBMVqHFFqH1Z32vtwGy7hcJG1gT5(yo3zBNcfbtTf1TByvsSs3UeyJDhMonOiLqHFFqb)BxnzbITFyQjTz0M7J)8TZ2ofkcMAlQB3WQKyLU93HcMDqhaBIUm9TeU4gT01OtHPbf5L4iSllwO22vtwGy7YAQWoWXDW6G2CF8))oB7QjlqSDjAszBNcfbtTf1n3h)9zNTD1Kfi2EIMb4YnH1YdTDkuem1wu3CZn3UANObST3Rbh)MBUl]] )

end
