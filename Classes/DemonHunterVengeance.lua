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

    spec:RegisterResource( Enum.PowerType.Fury, {
        -- Immolation Aura now grants 20 up front, 60 over 12 seconds (5 fps).
        immolation_aura = {
            aura    = "immolation_aura",

            last = function ()
                local app = state.buff.immolation_aura.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 2
        },
    } )

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

            spend = -8,
            spendType = "fury",

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


    spec:RegisterPack( "Vengeance", 20210308, [[dK0WLaqivbpcksBsi9jIsyuc4uevRsvi5vcKzji2Ls(fHQHrqDmIILjq9mHstdkIRjOABqrPVPkughrPCoIs16GIIMNG09Gk7tq5GeLOfsqEOqrQjQkexuOizJeL0hfkImsHIQtQkKALcvZuOi4Mcff7eQQLQku9uvmvOkBfkk8vHIqJvOO0EH8xjnyqhMYIvvpMutwIlJAZk1NvLgnboTuVMqz2iDBvA3I(nWWjKJlue1Yr8CsMovxNiBxi(ouy8cfoVQO1dfvZhkTFfJKbHh6umNr4hSWblJWXkSSTcwMWXKGLD0XFkIrhrMwm7LrN0Um6GzW5lBPMrhr2tkWki8qhfqIOz0rG7IuyMIl(B7cK(ln4kUQVsuZBqQj22fx1xT4OZxQP(JorF0PyoJWpyHdwgHJvyzBfSmHJjbho6OeXAe(HlBYGoc6sHt0hDkSsJopcFb5aJ5sPZKbIzW5lBPMN4XmgrlyGYwidmyHdwMj(exwsPamgOSsmTlr4bA(aPamgOSkrEoWaIiCeoD1aLvjYZb2kLeRgigTlyGhrnP9bke4(LVqhreWUPm6GPy6aFe(cYbgZLsNjdeZGZx2snpXXumDGXmgrlyGYwidmyHdwMj(ehtX0bklPuagduwjM2Li8anFGuagduwLiphyareocNUAGYQe55aBLsIvdeJ2fmWJOM0(afcC)Yxt8jUP9gKQLicRb3V54(a3PCPUP2tUGrNVvheJoN4M2BqQwIiSgC)MheoXLuCTD(gsAxgNH5kbgXu1ni9kyxfbWGjt8joMoWyQyWAjNldKJWKNd07lpqxapqt7aYaB1aTiwtTpLxtCt7nivbHt8igPTpLdjTlJ7tSSu)snTeseJkX4CJYPVSxq2yENV1n1USAXP9PCjQBuo91xIKD(wnAhHxCAFkxI6gLtFPfyecxQBkReS40(uUmXnT3GufeoXlTIijYN4M2BqQccN4AqQKUC9AVTEIBAVbPkiCIt4imrX1R926jUP9gKQGWjUlGaWO(sTochsVX9L271MP1p4(ns5YPVuUPfdx4rd8L27vFVaQ5niRMeXwsIWI9HV0EVUSBxarKaGQvljrYN4M2BqQccN4AJsRM2BqwPTYdjTlJ7tSSesVXfXiT9P86tSSu)snTmXnT3GufeoX1gLwnT3GSsBLhsAxgxH3CQ6iSAIBAVbPkiCIRnkTAAVbzL2kpK0Umonaqlams1e30Edsvq4exBuA10EdYkTvEiPDzCjGCn6eFIJPduwBM8CGcrSSmWhh4M3GCIBAVbPA9jwwWTBM8S(jwwM4M2BqQwFILLGWjEFVaQ5niRMeXcP34kaFTBM8S(jwwwERfRZ3j(e30Eds1sda0caJuHteWBqoXnT3GuT0aaTaWivbHtCni1C6eZ5sDtTlhsVXf4HcWxAqQ50jMZL6MAxU(Li5YBTyD(g9bt7nixAqQ50jMZL6MAxE1zDt7xbowSBjkTsyTaJ8YvVVCOV6Y6AXq(e30Eds1sda0caJufeoXXaqOLiCNvcRaPLAoKEJ7lT3lAV5pfaklLBAXcn2jUP9gKQLgaOfagPkiCIF5lG8Sc2vQKUl1cHTRAIJPdmMdOLb(4SjQZ3bkRu7YQbUbKbYXG1sopqILV8abKbkwtPd8lT3QqgyVhOiGs1FkVgOSKIH9unqN8CGoyGVSpqxapqkadw5duda0caJCGFtXLbcYbArSMAFkpqo5BZQ1e30Eds1sda0caJufeoXjSjQZ36MAxwfsVX5g5L9L3xU6GAP5qLzfowSbc4g5L9La2OUGLiThMSjmwSUrEzFjGnQlyjs7HIlyHLhnGP9ocx5KVnRWjdwS7(vGxj816ufwWYUC5yXgWnYl7lVVC1bvrAVgSWHfRWrdyAVJWvo5BZkCYGf7UFf4vcFTovHHjyIC5tCmDGpcVnjQpWTrPFtl2a3aYaLu2NYdKvko1SAnXnT3GuT0aaTaWivbHtCbSr8kRuCQ5jUP9gKQLgaOfagPkiCIlP4A78neEVzTxt7Y40p1uGtazRRFQP8q6nUV0EVU8fqEwb7kvs3LAHW2vTkamYjUP9gKQLgaOfagPkiCIlP4A78nK0UmotjiILSQsmmhqQAaXOH0BCf(lT3lIH5asvdigTw4V0EVkamsSyl8xAVxAqwK0EhHRDkwTWFP9EjjkQBKx2xcyJ6cwI0EOXkdwSUrEzF59LRoOwAo0GfEIJPd8r4Tjr9bUnk9BAXg4gqgOKY(uEGTZx1AIBAVbPAPbaAbGrQccN4skU2oFvtCt7nivlnaqlamsvq4ex15wIw)ellH0BCpua(s15wIw)elllV1I157e30Eds1sda0caJufeoXDbCvGu6tCt7nivlnaqlamsvq4eNPpvTL1cRjmpXN4y6aFeEZPQJWQjUP9gKQvH3CQ6iScxHVGSQe1IXQq6no3sX68nAGaBjkTsyTaJ8YvVVCOYeTtn425BTyx7LRXQKJfBat7DeUYjFBwfwSr7udUD(wl21E5ASQOFP9Ev4liRkrTySAvayKYXInqNAWTZ3AXU2lxdxfMWRGd)rjGnQlyDTyix(e30Eds1QWBovDewfeoXvajA9BesZKq6nUaM27iCLt(2SkSyJ2PgC78TwSR9Y1yvr)s79QWxqwvIAXy1QaWiLJfBGo1GBNV1IDTxUgUkmHxyYJsaBuxW6AXq(e30Eds1QWBovDewfeoX)suXQCmCIP9gKH0BCcyJ6cwIyIMtp0WfEIBAVbPAv4nNQocRccN4x2TlGisaq1Qq6nUhc4gLtFv4liB9It7t5I8ObEqdIWPL(kcNUGNeSyFOa8LQZTeT(jwwwERfRZx5yXg4duQO7(vGxj816ufQmHlFIBAVbPAv4nNQocRccN47MjpRFILLj(ehthi(aY1Od8XbU5niN4M2BqQwjGCnAq4eVZntsJwvoPfJdP342suALWAbg5LREF5qLjAGhCJYPV2u7YvnXucwCAFkxWInqb4lv)20kyx3u7YlcFTovHgB0hmT3GC15MjPrRkN0IXlv)20QiQP5IC5tCt7nivReqUgniCI)LOIv5y4et7niN4M2BqQwjGCnAq4exjQjTx)G7pKEJlqGV0EVUSBxarKaGQvljrrDJYPV2et7seEXP9PCjQcirRBI9E50vHHlw5yXQas06MyVxoDvy4We5tCt7nivReqUgniCIVzATWrmLBEdYq6no3sX68nAat7DeUYjFBwfMmyX6gLtFv4liB9It7t5I8jUP9gKQvcixJgeoXvajAvtzlchsVXfiGBuo9LsutAV(b3)It7t5sufqIw3e79YPRWjSCSyFWnkN(sjQjTx)G7FXP9PCrE0abCJYPV2et7seEXP9PCj6wI8mmCHhUCSyd8GBuo91MyAxIWloTpLlr3sKNHH7XewowSAaGwayKRntRfoIPCZBqUi816ufMBKx2xEF5QdQLMXInWxAVxx2TlGisaq1QLKOObc4gLtFTjM2Li8It7t5s0Te5zy4InC5yXg4b3OC6RnX0UeHxCAFkxIULipddx4clxUC5tCt7nivReqUgniCI33lGAEdYQjrSq6nUabIyK2(uE9jwwQFPMwIQbaAbGrU2ntEw)elllcFTovHjJWYXI9HigPTpLxFILL6xQPf5r3sKNHIt2fEIBAVbPALaY1ObHt8nt)uRWH0BCBjYZqXHzfEIBAVbPALaY1ObHt8nX0UeHdP342sKNHgRWyXgiGBuo9LsutAV(b3)It7t5sufqIw3e79YPRcfxSYXInWdUr50xkrnP96hC)loTpLlrde4lT3Rl72fqejaOA1ssu0Te5zO4cpC5yXg4lT3Rl72fqejaOA1QaWiJULipdf3JjSC5YLpXnT3GuTsa5A0GWjUQFBAfSRBQD5q6nUhcObr40sFj2tsBzuIuYBa5LxedZzAlMavTW7MYxoD5tCt7nivReqUgniCIReWgzIBAVbPALaY1ObHtCxabGr9LADegDIWevdse(blCWcltWbhm6GHrYoFvOtmrz5JJ)Jg)ysyMdCG4jGhyFfbi(a3aYaLfjGCnQSyGeoMSut4YavGlpqtYbxZ5Ya1cS8LvRjEmHo5bk7yMdmMgKryIZLbklisjVbKxEfZklgOdgOSGiL8gqE5vm7It7t5ISyGbKjgYxt8j(J(kcqCUmqm7anT3GCG0w5Q1ehDOTYvi8qNpXYccpe(YGWdD40(uUGecDkSstArEds0rwBM8CGcrSSmWhh4M3GeDmT3GeD2ntEw)ellihHFWi8qhoTpLliHqhnPDM0g6ua(A3m5z9tSSS8wlwNVOJP9gKOtFVaQ5niRMeXqoYrNcVnjQJWdHVmi8qhoTpLliHqhGi0rXo6yAVbj6eXiT9Pm6eXOsm64gLtFzVGSX8oFRBQDz1It7t5YaJoq3OC6RVej78TA0ocV40(uUmWOd0nkN(slWieUu3uwjyXP9PCbDkSstArEds0jMkgSwY5Ya5im55a9(Yd0fWd00oGmWwnqlI1u7t5f6eXi10Um68jwwQFPMwqoc)Gr4HoM2BqIoLwrKe5OdN2NYfKqihHFSi8qht7nirhnivsxUET3wJoCAFkxqcHCe(yccp0X0Eds0HWryIIRx7T1OdN2NYfKqihHF4i8qhoTpLliHqhnPDM0g68L271MP1p4(ns5YPVuUPfBG4gy4dm6admWV0EV67fqnVbz1Ki2ss0aXIDGpmWV0EVUSBxarKaGQvljrduo6yAVbj64ciamQVuRJWihHpMfHh6WP9PCbje6OjTZK2qNigPTpLxFILL6xQPf0X0Eds0rBuA10EdYkTvo6qBLxt7YOZNyzb5i8FmeEOdN2NYfKqOJP9gKOJ2O0QP9gKvARC0H2kVM2LrNcV5u1ryfYr4lBi8qhoTpLliHqht7nirhTrPvt7niR0w5OdTvEnTlJoAaGwayKkKJWx2r4HoCAFkxqcHoM2BqIoAJsRM2BqwPTYrhAR8AAxgDsa5AuKJC0reH1G73CeEi8LbHh6yAVbj68bUt5sDtTNCbJoFRoigDIoCAFkxqcHCe(bJWdD40(uUGecDs7YOJH5kbgXu1ni9kyxfbWGjOJP9gKOJH5kbgXu1ni9kyxfbWGjih5OJgaOfagPcHhcFzq4HoM2BqIoIaEds0Ht7t5csiKJWpyeEOdN2NYfKqOJM0otAdDcmWhgyb4lni1C6eZ5sDtTlx)sKC5TwSoFhy0b(WanT3GCPbPMtNyoxQBQD5vN1nTFf4del2bULO0kH1cmYlx9(Ydm0b(QlRRfJbkhDmT3GeD0GuZPtmNl1n1UmYr4hlcp0Ht7t5csi0rtANjTHoFP9Er7n)PaqzPCtl2adDGXIoM2BqIoyai0seUZkHvG0snJCe(yccp0X0Eds05Yxa5zfSRujDxQfcBxf6WP9PCbjeYr4hocp0Ht7t5csi0X0Eds0HWMOoFRBQDzf6uyLM0I8gKOtmhqld8XztuNVduwP2LvdCdidKJbRLCEGelF5bciduSMsh4xAVvHmWEpqraLQ)uEnqzjfd7PAGo55aDWaFzFGUaEGuagSYhOgaOfag5a)MIldeKd0Iyn1(uEGCY3Mvl0rtANjTHoUrEzF59LRoOwAEGHoqzwHpqSyhyGbgyGUrEzFjGnQlyjs7dmSbkBcpqSyhOBKx2xcyJ6cwI0(adf3adw4bkFGrhyGbAAVJWvo5BZQbIBGYmqSyh4UFf4vcFTovdmSbgSSpq5du(aXIDGbgOBKx2xEF5QdQI0EnyHhyydmwHhy0bgyGM27iCLt(2SAG4gOmdel2bU7xbELWxRt1adBGycMmq5duoYr4Jzr4HoCAFkxqcHofwPjTiVbj68i82KO(a3gL(nTydCdiduszFkpqwP4uZQf6yAVbj6iGnIxzLItnJCe(pgcp0Ht7t5csi0X0Eds0r)utbobKTU(PMYrhnPDM0g68L271LVaYZkyxPs6Uule2UQvbGrIo8EZAVM2Lrh9tnf4eq266NAkh5i8LneEOdN2NYfKqOJP9gKOJPeeXswvjgMdivnGyu0rtANjTHof(lT3lIH5asvdigTw4V0EVkamYbIf7al8xAVxAqwK0EhHRDkwTWFP9EjjAGrhOBKx2xcyJ6cwI0(adDGXkZaXIDGUrEzF59LRoOwAEGHoWGfgDs7YOJPeeXswvjgMdivnGyuKJWx2r4HoCAFkxqcHofwPjTiVbj68i82KO(a3gL(nTydCdiduszFkpW25RAHoM2BqIoskU2oFvihHVmcJWdD40(uUGecD0K2zsBOZddSa8LQZTeT(jwwwERfRZx0X0Eds0r15wIw)ellihHVmYGWdDmT3GeDCbCvGu6OdN2NYfKqihHVmbJWdDmT3GeDy6tvBzTWAcZOdN2NYfKqih5OtH3CQ6iScHhcFzq4HoCAFkxqcHoM2BqIof(cYQsulgRqNcR0KwK3GeDEeEZPQJWk0rtANjTHoULI157aJoWadmWa3suALWAbg5LREF5bg6aLzGrhyNAWTZ3AXU2lxJvnq5del2bgyGM27iCLt(2SAGHnWyhy0b2PgC78TwSR9Y1yvdm6a)s79QWxqwvIAXy1QaWihO8bIf7admWo1GBNV1IDTxUgUAGHnqHxbh(aFuduaBuxW6AXyGYhOCKJWpyeEOdN2NYfKqOJM0otAdDcmqt7DeUYjFBwnWWgySdm6a7udUD(wl21E5ASQbgDGFP9Ev4liRkrTySAvayKdu(aXIDGbgyNAWTZ3AXU2lxdxnWWgOWlmzGpQbkGnQlyDTymq5OJP9gKOJcirRFJqAMGCe(XIWdD40(uUGecD0K2zsBOJa2OUGLiMO50hyOdmCHrht7nirNVevSkhdNyAVbjYr4Jji8qhoTpLliHqhnPDM0g68Wadmq3OC6RcFbzRxCAFkxgO8bgDGbg4ddudIWPL(kcNUGNKbIf7aFyGfGVuDULO1pXYYYBTyD(oq5del2bgyGFGsnWOdC3Vc8kHVwNQbg6aLj8bkhDmT3GeDUSBxarKaGQvihHF4i8qht7nirNDZKN1pXYc6WP9PCbjeYro6KaY1Oi8q4ldcp0Ht7t5csi0X0Eds0PZntsJwvoPfJrNcR0KwK3GeDWhqUgDGpoWnVbj6OjTZK2qNTeLwjSwGrE5Q3xEGHoqzgy0bgyGpmq3OC6Rn1UCvtmLGfN2NYLbIf7admWcWxQ(TPvWUUP2Lxe(ADQgyOdm2bgDGpmqt7nixDUzsA0QYjTy8s1VnTkIAAUmq5duoYr4hmcp0X0Eds05lrfRYXWjM2BqIoCAFkxqcHCe(XIWdD40(uUGecD0K2zsBOtGbgyGFP9EDz3UaIibavRwsIgy0b6gLtFTjM2Li8It7t5YaJoqfqIw3e79YPRgyy4gySdu(aXIDGkGeTUj27LtxnWWWnqmzGYrht7nirhLOM0E9dUFKJWhtq4HoCAFkxqcHoAs7mPn0XTuSoFhy0bgyGM27iCLt(2SAGHnqzgiwSd0nkN(QWxq26fN2NYLbkhDmT3GeD2mTw4iMYnVbjYr4hocp0Ht7t5csi0rtANjTHobgyGb6gLtFPe1K2RFW9V40(uUmWOdubKO1nXEVC6QbIBGcpq5del2b(WaDJYPVuIAs71p4(xCAFkxgO8bgDGbgyGb6gLtFTjM2Li8It7t5YaJoWTe55add3adp8bkFGyXoWad8Hb6gLtFTjM2Li8It7t5YaJoWTe55add3aFmHhO8bIf7a1aaTaWixBMwlCet5M3GCr4R1PAGHnq3iVSV8(YvhulnpqSyhyGb(L271LD7ciIeauTAjjAGrhyGbgyGUr50xBIPDjcV40(uUmWOdClrEoWWWnWydFGYhiwSdmWaFyGUr50xBIPDjcV40(uUmWOdClrEoWWWnWWfEGYhO8bkFGYrht7nirhfqIw1u2IWihHpMfHh6WP9PCbje6OjTZK2qNadmWaJyK2(uE9jwwQFPMwgy0bQbaAbGrU2ntEw)elllcFTovdmSbkJWdu(aXIDGpmWigPTpLxFILL6xQPLbkFGrh4wI8CGHIBGYUWOJP9gKOtFVaQ5niRMeXqoc)hdHh6WP9PCbje6OjTZK2qNTe55adf3aXScJoM2BqIoBM(PwHrocFzdHh6WP9PCbje6OjTZK2qNTe55adDGXk8aXIDGbgyGb6gLtFPe1K2RFW9V40(uUmWOdubKO1nXEVC6QbgkUbg7aLpqSyhyGb(WaDJYPVuIAs71p4(xCAFkxgy0bgyGbg4xAVxx2TlGisaq1QLKObgDGBjYZbgkUbgE4du(aXIDGbg4xAVxx2TlGisaq1QvbGroWOdClrEoWqXnWht4bkFGYhO8bkhDmT3GeD2et7seg5i8LDeEOdN2NYfKqOJM0otAdDEyGbgOgeHtl9LypjTLdm6ajsjVbKxErmmNPTycu1cVBkF50xCAFkxgOC0X0Eds0r1VnTc21n1UmYr4lJWi8qht7nirhLa2iOdN2NYfKqihHVmYGWdDmT3GeDCbeag1xQ1ry0Ht7t5csiKJCKJoMKlaqqNtFJProYria]] )

end
