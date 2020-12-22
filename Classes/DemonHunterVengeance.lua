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


    spec:RegisterPack( "Vengeance", 20201222, [[dGuEKaqijQEKQqTjQuFcsvzueQtruwLeq9kQiZscAxk8lcPHriogb1YiQ8mQettvixtIY2GujFtvqghKk15KaSoivO5rf19GO9rL0bLaPfsqEOeqAIQcQlkbe2OeO(Oeq0iHurDsivKvkHMjKkODcPSujq8uvAQQI2kKQkFfsvvnwivG9c6Vu1GH6WKwSQ6XuAYs6YO2SI(SQ0OjWPL61evnBKUTk2TOFdmCQWXHuvLLJ45umDHRtKTlr(oK04vf48qI1dPkZhc7xPHcdFcVvnyiAYjICIiSCYj3qyxEKWYvaWBGIdgEDOw51xgEt9WWl6hNVSMwgEDOOqbAf(eEnajILHxbr4WGokQOVDiq6pSGJOM(ir1ObPLOZqutFSIcVFPMgOtj8dVvnyiAYjICIiSCYj3qyxEKWYjm8ACWwiALHUfgEf01kNWp8wzJfEF8IFy(aYfJolLbtwm6hNVSMwEl(4f)WSLpFMSy5KRWflNiYjYwCl(4fxqPuaQlUGjQnKi8I1yXuaQlUGLiOSyXoiCjodZIlyjcklUngj2Syu7qWIVoAshlwiW5lBaVoiGztz49Xl(H5dixm6SugmzXOFC(YAA5T4Jx8dZw(8zYILtUcxSCIiNiBXT4JxCbLsbOU4cMO2qIWlwJftbOU4cwIGYIf7GWL4mmlUGLiOS42yKyZIrTdbl(6OjDSyHaNVSXwClQ2ObPz4GWwW5RbYpickx9tQIcxrTZxFaEqNBr1gnindhe2coFnCcPOsg23bFkm1dJurpJaLOg)eKHhm9oaOYKT4w8XlUaXdyRuW1fZLycklo6dV4qaVy1gaYIBZI1sAt1pLhBr1gninoHu0skP1pLlm1dJ8t0S6)snTwyjLkXidLYzm0xq2OxNV(jvpSzWP(PC1DOuoJXxIKD(6vAxIhCQFkxDhkLZyyfOecx9tkBem4u)uUUfvB0G04esrRTHi5i2IQnAqACcPOwqAKoS)OVTDlQ2ObPXjKIs4smXW(J(22TOAJgKgNqkAiGaq1)s1Uexypr(LMZXKP(p48vs9WzmmHALhzzUf)LMZrFoaQgni9QerhsoqGO8V0CooCOhaXHaGPndjhY2IQnAqACcPOwLs9QnAq6PTjkm1dJ8t0SwyprwsjT(P84t0S6)snTUfvB0G04esrTkL6vB0G0tBtuyQhgzLNCA6sSzlQ2ObPXjKIAvk1R2ObPN2MOWupmslaqRautZwuTrdsJtif1QuQxTrdspTnrHPEyKjGCu6wCl(4fxWntqzXcr0SU4cci0Ob5wuTrdsZ4t0SIC2mbf)NOzDlQ2ObPz8jAwDcPO95aOA0G0RseTWEIScIXSzck(prZ6iAR8D(Uf3IQnAqAgwaGwbOMgKoardYTOAJgKMHfaOvaQPXjKIAbPLZGObx9tQE4c7jsXLxbXWcslNbrdU6Nu9W(VejhrBLVZx3LR2Ob5WcslNbrdU6Nu9WJo9tA)kiqGykrPEcBfOKx2h9HD(1whh9bY2IQnAqAgwaGwbOMgNqkkQacTwI70tydi10Yf2tKFP5Cq7j)PaqDyc1kVZUSfvB0G0mSaaTcqnnoHu0dFaeu8GPNkz7QVsy9y2IpEXOZaADXfewD057IlyQEyZINaYI5hWwPGxmrZxEXaYILVP0f)LMttHlUNl2bWy6pLhlUGsrvrXS4GGYIdWIF5yXHaEXuaQSjwSfaOvaQ5I)QHRlgKlwlPnv)uEXCYNMnJTOAJgKMHfaOvaQPXjKIsy1rNV(jvpSPWEImuYlhJOpSpa(AZol8OmeielouYlhdbSsdbdh2Wv0Tiiqek5LJHawPHGHdB4ms5erMBXQn6sSNt(0SbPWiqm7xbHNWhTtJRYvaYKHaH4qjVCmI(W(a4DydVCI4QlI4wSAJUe75KpnBqkmceZ(vq4j8r7046JEKmzBXhV4hMNQenw8uP0VALFXtazXsg9t5fZgdNw2m2IQnAqAgwaGwbOMgNqkQawjHNngoT8wuTrdsZWca0ka104esrLmSVd(uipNSn8PEyKwuSuqqazB9FQAIc7jYV0Coo8bqqXdMEQKTR(kH1JzubOMBr1gnindlaqRautJtifvYW(o4tHPEyKQrqjnzJNOOhG4TaIslSNiR8xAohef9aeVfquQVYFP5CubOMiqu5V0CoSGSkzJUe77uEFL)sZ5qYH7qjVCmeWknemCydNDryeicL8YXi6d7dGV2SZYjYw8Xl(H5PkrJfpvk9Rw5x8eqwSKr)uEXDWhZylQ2ObPzybaAfGAACcPOsg23bFmBr1gnindlaqRautJtif105uI6)enRf2tKLxbXW05uI6)enRJOTY357wuTrdsZWca0ka104esrdbSxGugBr1gnindlaqRautJtifDcQvM4dGpeW(jvp8wuTrdsZWca0ka104esrzkkMwtFLTeM3IBXhV4hMNCA6sSzlQ2ObPzu5jNMUeBqw5di9ghT8SPWEIm0u(oFDlw8uIs9e2kqjVSp6d7SWU70coD(6R6rFzVlgziqiwTrxI9CYNMnU6I7oTGtNV(QE0x27IX9xAohv(asVXrlpBgvaQPmeie3PfC681x1J(Y(YmUkYqUYkWcyLgcgh9bYKTfvB0G0mQ8KttxInoHuudqI6)kH0mPWEIuSAJUe75KpnBC1f3DAbNoF9v9OVS3fJ7V0CoQ8bKEJJwE2mQautziqiUtl405RVQh9L9LzCvKXJkWcyLgcgh9bY2IQnAqAgvEYPPlXgNqk6xIkVNFqquB0GSWEIuaR0qWWbtSCgoxMiBr1gninJkp500LyJtif9WHEaehcaM2uyprwU4qPCgJkFazBhCQFkxL5wC5wqjo1mgL4meGcbbIYRGyy6Ckr9FIM1r0w578vgceI)aJX9SFfeEcF0onolCzY2IQnAqAgvEYPPlXgNqk6Szck(prZ6wCl(4fJgGCu6IliGqJgKBr1gninJeqok1jKI25KjPs9MG0YZf2tKtjk1tyRaL8Y(OpSZc7wC5Hs5mgtQEyVLOgbdo1pLRiqiUcIHPFBQhm9tQE4bHpANgNDXD5QnAqo6CYKuPEtqA55HPFBQ3bvTCvMSTOAJgKMrcihL6esr)su598dcIAJgKBr1gninJeqok1jKIAC0Ko8FW5xyprkw8xAohho0dG4qaW0MHKd3Hs5mgtIAdjcp4u)uU62aKO(jrFpCggxr6ImeimajQFs03dNHXvKps2wuTrdsZibKJsDcPOtM6RCj1eA0GSWEIm0u(oFDlwTrxI9CYNMnUkmceHs5mgv(aY2o4u)uUkBlQ2ObPzKaYrPoHuudqI6TuwlXf2tKIfhkLZyyC0Ko8FW5p4u)uU62aKO(jrFpCggKIidbIYdLYzmmoAsh(p48hCQFkxL5wS4qPCgJjrTHeHhCQFkxDpLiO4kYYktgceIlpukNXysuBir4bN6NYv3tjckUI8HergcewaGwbOMJjt9vUKAcnAqoi8r704AOKxogrFyFa81MrGq8xAohho0dG4qaW0MHKd3IfhkLZymjQnKi8Gt9t5Q7Pebfxr6szYqGqC5Hs5mgtIAdjcp4u)uU6EkrqXvKLjImzYKTfvB0G0msa5OuNqkAFoaQgni9QerlSNiflUKsA9t5XNOz1)LAA1TfaOvaQ5y2mbf)NOzDq4J2PXvHfrgceLxsjT(P84t0S6)snTkZ9uIGIZilar2IQnAqAgjGCuQtifDY0pvRCH9e5uIGIZirxISfvB0G0msa5OuNqk6KO2qIWf2tKtjcko7IiiqiwCOuoJHXrt6W)bN)Gt9t5QBdqI6Ne99WzyCgPlYqGqC5Hs5mgghnPd)hC(do1pLRUfl(lnNJdh6bqCiayAZqYH7PebfNrwwzYqGq8xAohho0dG4qaW0MrfGA6EkrqXzKpKiYKjt2wuTrdsZibKJsDcPOM(TPEW0pP6HlSNilxSfuItnJH8OqAnDtKsEciV8GOOhtB5fy8vE2u(WziBlQ2ObPzKaYrPoHuuJawjBr1gninJeqok1jKIgciau9VuTlXWBjMyAqcrtorKteHLtyxGxuvs25RbEr)xqliOHoHwbs0XfV4Nc4f3hhasS4jGSy0xcihLI(wmHr)j1eUUyd4WlwLcWrdUUyRanFzZylIoStEXfa64IlqbzjMeCDXOpIuYta5LhOdqFloalg9rKsEciV8aDWGt9t5k6BXIf(bYgBXTi60XbGeCDXORfR2Ob5IPTjmJTi8QsHaabEV9PafEPTjmWNW7NOzf(eIMWWNWRAJgKW7Szck(prZk8YP(PCfkemGOjh8j8YP(PCfke8AjDWKwH3kigZMjO4)enRJOTY35l8Q2Obj82NdGQrdsVkruyad4TYtvIgWNq0eg(eE5u)uUcfcEboGxdhWRAJgKWBjL06NYWBjLkXWBOuoJH(cYg9681pP6Hndo1pLRl29IdLYzm(sKSZxVs7s8Gt9t56IDV4qPCgdRaLq4QFszJGbN6NYv4TKs8PEy49t0S6)snTcdiAYbFcVQnAqcV12qKCeWlN6NYvOqWaIMlWNWRAJgKWRfKgPd7p6BBHxo1pLRqHGbeThbFcVQnAqcVeUetmS)OVTfE5u)uUcfcgq0kd(eE5u)uUcfcETKoysRW7xAohtM6)GZxj1dNXWeQv(fJCXLTy3lw8I)sZ5OphavJgKEvIOdjhlgbIfx(I)sZ54WHEaehcaM2mKCSyzWRAJgKWBiGaq1)s1UeddiAOl4t4Lt9t5kui41s6GjTcVLusRFkp(enR(VutRWRAJgKWRvPuVAJgKEABc4L2MWN6HH3prZkmGO9qWNWlN6NYvOqWRAJgKWRvPuVAJgKEABc4L2MWN6HH3kp500LydmGOHUHpHxo1pLRqHGx1gniHxRsPE1gni902eWlTnHp1ddVwaGwbOMgyarRaGpHxo1pLRqHGx1gniHxRsPE1gni902eWlTnHp1ddVjGCukmGb86GWwW5Rb8jenHHpHx1gniH3pickx9tQIcxrTZxFaEqNWlN6NYvOqWaIMCWNWlN6NYvOqWBQhgEv0ZiqjQXpbz4btVdaQmbEvB0GeEv0ZiqjQXpbz4btVdaQmbgWaETaaTcqnnWNq0eg(eEvB0GeEDaIgKWlN6NYvOqWaIMCWNWlN6NYvOqWRL0btAfEfV4YxCfedliTCgen4QFs1d7)sKCeTv(oFxS7fx(IvB0GCybPLZGObx9tQE4rN(jTFfelgbIfpLOupHTcuYl7J(Wl25f)ARJJ(GfldEvB0GeETG0Yzq0GR(jvpmmGO5c8j8YP(PCfke8AjDWKwH3V0CoO9K)uaOomHALFXoVyxGx1gniHxubeATe3PNWgqQPLHbeThbFcVQnAqcVh(aiO4btpvY2vFLW6XaVCQFkxHcbdiALbFcVCQFkxHcbVwshmPv4nuYlhJOpSpa(AZl25fl8OSfJaXIfVyXlouYlhdbSsdbdh2yXUUy0TilgbIfhk5LJHawPHGHdBSyNrUy5ezXYwS7flEXQn6sSNt(0SzXixSWlgbIfp7xbHNWhTtZIDDXYvalw2ILTyeiwS4fhk5LJr0h2haVdB4LtKf76IDrKf7EXIxSAJUe75KpnBwmYfl8IrGyXZ(vq4j8r70Syxx8JE0ILTyzWRAJgKWlHvhD(6Nu9WgyardDbFcVQnAqcVcyLeE2y40YWlN6NYvOqWaI2dbFcVCQFkxHcbVQnAqcVwuSuqqazB9FQAc41s6GjTcVFP5CC4dGGIhm9ujBx9vcRhZOcqnHxEozB4t9WWRfflfeeq2w)NQMagq0q3WNWlN6NYvOqWRAJgKWRAeust24jk6biElGOu41s6GjTcVv(lnNdIIEaI3cik1x5V0CoQauZfJaXIR8xAohwqwLSrxI9DkVVYFP5Ci5yXUxCOKxogcyLgcgoSXIDEXUi8IrGyXHsE5ye9H9bWxBEXoVy5ebEt9WWRAeust24jk6biElGOuyarRaGpHx1gniHxjd77Gpg4Lt9t5kuiyartyrGpHxo1pLRqHGxlPdM0k8w(IRGyy6Ckr9FIM1r0w578fEvB0GeEnDoLO(prZkmGOjSWWNWRAJgKWBiG9cKYaE5u)uUcfcgq0ewo4t4vTrds4DcQvM4dGpeW(jvpm8YP(PCfkemGOjSlWNWRAJgKWltrX0A6RSLWm8YP(PCfkemGb8w5jNMUeBGpHOjm8j8YP(PCfke8AjDWKwH3qt578DXUxS4flEXtjk1tyRaL8Y(Op8IDEXcVy3lUtl405RVQh9L9UywSSfJaXIfVy1gDj2ZjFA2SyxxSll29I70coD(6R6rFzVlMf7EXFP5Cu5di9ghT8SzubOMlw2IrGyXIxCNwWPZxFvp6l7lZSyxxSid5kBXf4flGvAiyC0hSyzlwg8Q2Obj8w5di9ghT8Sbgq0Kd(eE5u)uUcfcETKoysRWR4fR2OlXEo5tZMf76IDzXUxCNwWPZxFvp6l7DXSy3l(lnNJkFaP34OLNnJka1CXYwmcelw8I70coD(6R6rFzFzMf76Ifz8OfxGxSawPHGXrFWILbVQnAqcVgGe1)vcPzcmGO5c8j8YP(PCfke8AjDWKwHxbSsdbdhmXYzSyNxCzIaVQnAqcVFjQ8E(bbrTrdsyar7rWNWlN6NYvOqWRL0btAfElFXIxCOuoJrLpGSTdo1pLRlw2IDVyXlU8fBbL4uZyuIZqakKfJaXIlFXvqmmDoLO(prZ6iAR8D(UyzlgbIflEXFGXSy3lE2VccpHpANMf78IfUSfldEvB0GeEpCOhaXHaGPnWaIwzWNWRAJgKW7Szck(prZk8YP(PCfkemGb8MaYrPWNq0eg(eE5u)uUcfcETKoysRW7uIs9e2kqjVSp6dVyNxSWl29IfV4YxCOuoJXKQh2BjQrWGt9t56IrGyXIxCfedt)2upy6Nu9WdcF0onl25f7YIDV4YxSAJgKJoNmjvQ3eKwEEy63M6DqvlxxSSfldEvB0GeE7CYKuPEtqA5zyarto4t4vTrds49lrL3ZpiiQnAqcVCQFkxHcbdiAUaFcVCQFkxHcbVwshmPv4v8IfV4V0CooCOhaXHaGPndjhl29IdLYzmMe1gseEWP(PCDXUxSbir9tI(E4mml2vKl2LflBXiqSydqI6Ne99WzywSRix8JwSm4vTrds414OjD4)GZhgq0Ee8j8YP(PCfke8AjDWKwH3qt578DXUxS4fR2OlXEo5tZMf76IfEXiqS4qPCgJkFazBhCQFkxxSm4vTrds4DYuFLlPMqJgKWaIwzWNWlN6NYvOqWRL0btAfEfVyXloukNXW4OjD4)GZFWP(PCDXUxSbir9tI(E4mmlg5IfzXYwmcelU8fhkLZyyC0Ko8FW5p4u)uUUyzl29IfVyXloukNXysuBir4bN6NY1f7EXtjckl2vKlUSYwSSfJaXIfV4YxCOuoJXKO2qIWdo1pLRl29INseuwSRix8djYILTyeiwSfaOvaQ5yYuFLlPMqJgKdcF0onl21fhk5LJr0h2haFT5fJaXIfV4V0CooCOhaXHaGPndjhl29IfVyXloukNXysuBir4bN6NY1f7EXtjckl2vKl2LYwSSfJaXIfV4YxCOuoJXKO2qIWdo1pLRl29INseuwSRixCzISyzlw2ILTyzWRAJgKWRbir9wkRLyyardDbFcVCQFkxHcbVwshmPv4v8IfV4skP1pLhFIMv)xQP1f7EXwaGwbOMJzZeu8FIM1bHpANMf76IfwKflBXiqS4YxCjL06NYJprZQ)l106ILTy3lEkrqzXoJCXfGiWRAJgKWBFoaQgni9QerHbeThc(eE5u)uUcfcETKoysRW7uIGYIDg5IrxIaVQnAqcVtM(PALHben0n8j8YP(PCfke8AjDWKwH3PebLf78IDrKfJaXIfVyXloukNXW4OjD4)GZFWP(PCDXUxSbir9tI(E4mml2zKl2LflBXiqSyXlU8fhkLZyyC0Ko8FW5p4u)uUUy3lw8IfV4V0CooCOhaXHaGPndjhl29INseuwSZixCzLTyzlgbIflEXFP5CC4qpaIdbatBgvaQ5IDV4PebLf7mYf)qISyzlw2ILTyzWRAJgKW7KO2qIWWaIwbaFcVCQFkxHcbVwshmPv4T8flEXwqjo1mgYJcP1CXUxmrk5jG8YdIIEmTLxGXx5zt5dNXGt9t56ILbVQnAqcVM(TPEW0pP6HHbenHfb(eEvB0GeEncyLaVCQFkxHcbdiAclm8j8Q2Obj8gciau9VuTlXWlN6NYvOqWagWagWacba]] )

end
