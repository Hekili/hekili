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
        blood_moon = 5434, -- 355995
        chaotic_imprint = 5439, -- 356510
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
        demon_soul = {
            id = 163073,
            duration = 15,
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

                -- This is likely repeated per tick but it's not worth the CPU overhead to model each tick.
                if legendary.agony_gaze.enabled and debuff.sinful_brand.up then
                    debuff.sinful.brand.expires = debuff.sinful_brand.expires + 0.75
                end                
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


    spec:RegisterPack( "Vengeance", 20210403, [[dGuoLaqivqpckjBsq9jOKYOiQofrzvsrPELazwsr2Lu9lbyyeWXieltf4zsHMMukUMuQ2guc9nPOY4GsKZjfvToOKkZtG6EqL9jfCqPuQfsGEOuuOjkLsUOuuKnkG4JsrbnsPOKtcLOSsPKzcLuLDcv1sHsWtvPPcvzRqjQ(kusvnwPOO2lK)QKbdCyklwv9ysnzHUmQnRuFwfnAc60sEnH0Sr62QYUf9BqdNqDCPOalhXZjz6uDDISDb57qPgVaQZRcTEbKMpuSFfJebHh6gnNr4FGahiIaTrGg7IiYbTrGMdD9JIz0vSPf1oz0nThJUy5CEYwQz0vSDKcTicp0vbLiAgDf6UyfwxabCwUqPFxdFbOQNe18cMAIT9au1tha6(LkQJLLOp6gnNr4FGahiIaTrGg7IiYbTraSi6QeZAe(TJLebDfwXiNOp6gzLgDBl(bZb0SKsNjdalNZt2snpTABXKIoGdAAahiWbImTMwTnLcXEabcX0UeHhG5dGcXEabIe54aKlMWH40vdiqKihhqPusSAayxUWbCfxKYhGGW3xwhDftG7IYOlwHvdOT4hmhqZskDMmaSCopzl180cRWQb02IjfDah00aoqGdezAnTWkSAaTnLcXEabcX0UeHhG5dGcXEabIe54aKlMWH40vdiqKihhqPusSAayxUWbCfxKYhGGW3xwFAnTmTxWu1ftyn89nh3h6oLJRn1oYrSR8C5Wax50AAHvdOzkWSwY54a4qm54a86XdWfYdW0oKmGsnalKvu7t5(0Y0Ebtvq4ciKrk7t5Ms7X4(elJRVurJnfYOsmo3OC6D7eMvGw55AtThR6CAFkhd7gLtV)LizLNlJwH4oN2NYXWUr507AHgHWX1MYkHDoTpLJtlt7fmvbHlGyPisI9PLP9cMQGWfGgMkPhVE2zPNwM2lyQccxaeoetu86zNLEAzAVGPkiCb4cjqSxNuRcXnvBCFP9UVz66dFFJeFC6DLBArX1Ey5FP9UxVhKAEbZLjrSUKymyo8lT39h72dseleQkvxsSSPLP9cMQGWfG2O0LP9cMlAP8Ms7X4(elJnvBCHmszFk3)elJRVurJtlt7fmvbHlaTrPlt7fmx0s5nL2JXf5nNQkeRMwM2lyQccxaAJsxM2lyUOLYBkThJtdH0ie7unTmTxWufeUa0gLUmTxWCrlL3uApgxcjpJoTMwy1acKIjhhGGelJdalaDZlyoTmTxWu1)elJ42ftoU(elJtlt7fmv9pXYyq4cOEpi18cMltIynvBCrO33ftoU(elJDV0Iw550AAzAVGPQRHqAeIDQWjg6fmNwM2lyQ6AiKgHyNQGWfGgMAoDI5CCTP2JBQ24KFye6Dnm1C6eZ54AtThV(sKS7Lw0kpdFOP9cMDnm1C6eZ54AtTh3RCTP1PqhdMTeLUiSwOro5Lxpo4tDS)SalBAzAVGPQRHqAeIDQccxaydj0yiUYfHvW0sn3uTX9L27oT28NcHXUYnTOb340Y0EbtvxdH0ie7ufeUaE8dsoUG7fvsxXvKW2tnTWQb0SG04aWcSjUYZbeiu7XQbSHKbWbM1sopaILN8aGKbiArPd4lT3QMgqThGyOsvFk3hqBtX2oQgGtooahoGt2hGlKhafInR8bOHqAeIDoGVP44aG5aSqwrTpLhaN8RyvFAzAVGPQRHqAeIDQccxae2ex55AtThRAQ24CJCYE3RhVC4kwCWI0Bhdg5YDJCYExiBuxyxS2BaljagmUrozVlKnQlSlw7bJ7abKfwUP9keV4KFfRWjcgm76uOVi8ZQu1WbnVmzyWi3nYj7DVE8YHlXAFDGan0OaHLBAVcXlo5xXkCIGbZUof6lc)Skvn0M2it20cRgqBXBtI6dyBu630IoGnKmajL9P8ayLItnR6tlt7fmvDnesJqStvq4cqiBeFXkfNAEAzAVGPQRHqAeIDQccxaskEvo)AI3Bw7R0Emo9rnf6eyw61NAkVPAJ7lT39h)GKJl4ErL0vCfjS9u9ie7CAzAVGPQRHqAeIDQccxaskEvo)AkThJZucdzjRwelqHKLgsmAt1gxK)s7DNybkKS0qIrxr(lT39ie7edMi)L27UgMrjTxH4vLIUI8xAV7sId7g5K9Uq2OUWUyThCJIGbJBKt27E94LdxXId(abMwy1aAlEBsuFaBJs)Mw0bSHKbiPSpLhq58t1NwM2lyQ6AiKgHyNQGWfGKIxLZp10Y0EbtvxdH0ie7ufeUauvULORpXYyt1g3HrO3vvULORpXYy3lTOvEoTmTxWu11qincXovbHlaxiVekL(0Y0EbtvxdH0ie7ufeUay6rvz5kYAcZtRPfwnG2I3CQQqSAAzAVGPQh5nNQkeRWf5hmxkXLOSQPAJZTu0kpdlx(wIsxewl0iN8YRhhSiHRudFvEUI2Zo5vJkzyWi30EfIxCYVIvn0y4k1WxLNRO9StE1Ok8xAV7r(bZLsCjkR6ri2PmmyKxPg(Q8CfTNDYR2vniq)G2B2czJ6c7plWYKnTmTxWu1J8MtvfIvbHlafuIU(gHumPPAJtUP9keV4KFfRAOXWvQHVkpxr7zN8Qrv4V0E3J8dMlL4suw1JqStzyWiVsn8v55kAp7KxTRAqGEBA2czJ6c7plWYMwM2lyQ6rEZPQcXQGWfWxIk6IdStmTxWSPAJtiBuxyxmt0C6b3Uatlt7fmv9iV5uvHyvq4c4XU9GeXcHQs1uTXDOC3OC69i)GzP7CAFkhLfw(HAyioT07H40fEKGbZHrO3vvULORpXYy3lTOvEkddg5FOsfExNc9fHFwLQGfPDztlt7fmv9iV5uvHyvq4cyxm546tSmoTMwy1aWhsEgDaybOBEbZPLP9cMQEcjpJgeUaQCZK0OlLtkr5MQnUTeLUiSwOro5Lxpoyrcl)q3OC69n1E8stmLWoN2NYrmyKhHExvNfDb3Rn1ECNWpRsvWng(qt7fm7vUzsA0LYjLOCxvNfDjMAAokt20Y0EbtvpHKNrdcxaFjQOloWoX0EbZPLP9cMQEcjpJgeUauIls5Rp89BQ24Kl)lT39h72dseleQkvxsCy3OC69nX0UeH7CAFkhdRGs01MyNpoDvd4AuggmkOeDTj25Jtx1aU2iBAzAVGPQNqYZObHlGntxroKPCZly2uTX5wkALNHLBAVcXlo5xXQgebdg3OC69i)GzP7CAFkhLnTmTxWu1ti5z0GWfGckrxAkBH4MQno5YDJYP3vIls5Rp897CAFkhdRGs01MyNpoDfobKHbZHUr507kXfP81h((DoTpLJYclxUBuo9(MyAxIWDoTpLJH3sKJnGR92LHbJ8dDJYP33et7seUZP9PCm8wICSbCnNaYWGrdH0ie7SVz6kYHmLBEbZoHFwLQgCJCYE3RhVC4kwmgmY)s7D)XU9GeXcHQs1LehwUC3OC69nX0UeH7CAFkhdVLihBaxJTlddg5h6gLtVVjM2LiCNt7t5y4Te5yd4AxazYKjBAzAVGPQNqYZObHlG69GuZlyUmjI1uTXjxEiJu2NY9pXY46lv0yynesJqSZ(UyYX1NyzSt4NvPQbreqggmhgYiL9PC)tSmU(sfnkl8wICmyCnVatlt7fmv9esEgniCbSz6NArUPAJBlrogmoSOatlt7fmv9esEgniCbSjM2LiCt1g3wICm4gfadg5YDJYP3vIls5Rp897CAFkhdRGs01MyNpoDvW4AuggmYp0nkNExjUiLV(W3VZP9PCmSC5FP9U)y3EqIyHqvP6sIdVLihdgx7Tlddg5FP9U)y3EqIyHqvP6ri2z4Te5yW4AobKjtMSPLP9cMQEcjpJgeUau1zrxW9AtTh3uTXDOCnmeNw6DrpskldtKsEdjNCNybktlrfQwrExu(XPlBAzAVGPQNqYZObHlaLq2itlt7fmv9esEgniCb4cjqSxNuRcXOBiMOkyIW)aboqebAuaSe6ITrYkpvOlw)2glGpwg(ndX6gWaWtipG6jgs8bSHKbG1si5zuS2aiCZaPIWXbOGpEaMKdFMZXbOfA5jR6tlSEvYdO5X6gqZimdXeNJdaRrKsEdjNCVzgRnahoaSgrk5nKCY9M5oN2NYrS2aKlsGL1NwtlSSNyiX54aWIdW0EbZbqlLR6tl0LwkxHWdD)elJi8q4lccp0Lt7t5isq0nYknPe7fmr3aPyYXbiiXY4aWcq38cMORP9cMO7UyYX1Nyze5i8paHh6YP9PCeji6QjLZKYq3i077IjhxFILXUxArR8eDnTxWeDR3dsnVG5YKigYro6g5TjrDeEi8fbHh6YP9PCeji6cfJUk2rxt7fmr3qgPSpLr3qgvIrx3OC6D7eMvGw55AtThR6CAFkhhq4b4gLtV)LizLNlJwH4oN2NYXbeEaUr507AHgHWX1MYkHDoTpLJOBKvAsj2lyIUntbM1sohhahIjhhGxpEaUqEaM2HKbuQbyHSIAFk3r3qgzL2Jr3pXY46lv0iYr4Facp010Ebt0nwkIKyhD50(uoIee5i8BeHh6AAVGj6QHPs6XRNDwA0Lt7t5isqKJWVni8qxt7fmrxchIjkE9SZsJUCAFkhrcICe(TJWdD50(uoIeeD1KYzszO7xAV7BMU(W33iXhNEx5Mw0bGBaTpGWdq(a(s7DVEpi18cMltIyDjXdadMbC4a(s7D)XU9GeXcHQs1LepazORP9cMORlKaXEDsTkeJCe(yreEOlN2NYrKGORMuotkdDdzKY(uU)jwgxFPIgrxt7fmrxTrPlt7fmx0s5OlTu(kThJUFILrKJWV5q4HUCAFkhrcIUM2lyIUAJsxM2lyUOLYrxAP8vApgDJ8MtvfIvihHpwcHh6YP9PCeji6AAVGj6QnkDzAVG5IwkhDPLYxP9y0vdH0ie7uHCe(npcp0Lt7t5isq010Ebt0vBu6Y0EbZfTuo6slLVs7XOBcjpJICKJUIjSg((MJWdHVii8qxt7fmr3p0DkhxBQDKJyx55YHbUs0Lt7t5isqKJC0vdH0ie7uHWdHVii8qxt7fmrxXqVGj6YP9PCejiYr4Facp0Lt7t5isq0vtkNjLHUYhWHdic9UgMAoDI5CCTP2JxFjs29slALNdi8aoCaM2ly21WuZPtmNJRn1ECVY1MwNc9bGbZa2su6IWAHg5KxE94be8ao1X(Zc8aKHUM2lyIUAyQ50jMZX1MApg5i8BeHh6YP9PCeji6QjLZKYq3V0E3P1M)uim2vUPfDabpGgrxt7fmrxSHeAmex5IWkyAPMroc)2GWdDnTxWeDF8dsoUG7fvsxXvKW2tHUCAFkhrcICe(TJWdD50(uoIeeDnTxWeDjSjUYZ1MApwHUrwPjLyVGj62SG04aWcSjUYZbeiu7XQbSHKbWbM1sopaILN8aGKbiArPd4lT3QMgqThGyOsvFk3hqBtX2oQgGtooahoGt2hGlKhafInR8bOHqAeIDoGVP44aG5aSqwrTpLhaN8RyvhD1KYzszORBKt27E94LdxXIhqWdqKE7dadMbiFaYhGBKt27czJ6c7I1(aAyayjbgagmdWnYj7DHSrDHDXAFabJBahiWaKnGWdq(amTxH4fN8Ry1aWnargagmdyxNc9fHFwLQb0WaoO5hGSbiBayWma5dWnYj7DVE8YHlXAFDGadOHb0Oadi8aKpat7viEXj)kwnaCdqKbGbZa21PqFr4NvPAanmG20MbiBaYqocFSicp0Lt7t5isq0nYknPe7fmr32I3Me1hW2O0VPfDaBizask7t5bWkfNAw1rxt7fmrxHSr8fRuCQzKJWV5q4HUCAFkhrcIUM2lyIU6JAk0jWS0Rp1uo6QjLZKYq3V0E3F8dsoUG7fvsxXvKW2t1JqSt0L3Bw7R0Em6QpQPqNaZsV(ut5ihHpwcHh6YP9PCeji6AAVGj6AkHHSKvlIfOqYsdjgfD1KYzszOBK)s7DNybkKS0qIrxr(lT39ie7CayWmGi)L27UgMrjTxH4vLIUI8xAV7sIhq4b4g5K9Uq2OUWUyTpGGhqJImamygGBKt27E94LdxXIhqWd4abq30Em6AkHHSKvlIfOqYsdjgf5i8BEeEOlN2NYrKGOBKvAsj2lyIUTfVnjQpGTrPFtl6a2qYaKu2NYdOC(P6ORP9cMORKIxLZpfYr4lIai8qxoTpLJibrxnPCMug6E4aIqVRQClrxFILXUxArR8eDnTxWeDvvULORpXYiYr4lIii8qxt7fmrxxiVekLo6YP9PCejiYr4lYbi8qxt7fmrxMEuvwUISMWm6YP9PCejiYro6g5nNQkeRq4HWxeeEOlN2NYrKGORP9cMOBKFWCPexIYk0nYknPe7fmr32I3CQQqScD1KYzszORBPOvEoGWdq(aKpGTeLUiSwOro5LxpEabpargq4buPg(Q8CfTNDYRgvdq2aWGzaYhGP9keV4KFfRgqddOXbeEavQHVkpxr7zN8Qr1acpGV0E3J8dMlL4suw1JqSZbiBayWma5dOsn8v55kAp7KxTRgqddqG(bTpGM9aeYg1f2FwGhGSbid5i8paHh6YP9PCeji6QjLZKYqx5dW0EfIxCYVIvdOHb04acpGk1WxLNRO9StE1OAaHhWxAV7r(bZLsCjkR6ri25aKnamygG8buPg(Q8CfTNDYR2vdOHbiqVndOzpaHSrDH9Nf4bidDnTxWeDvqj66BesXeKJWVreEOlN2NYrKGORMuotkdDfYg1f2fZenN(acEaTla6AAVGj6(LOIU4a7et7fmroc)2GWdD50(uoIeeD1KYzszO7Hdq(aCJYP3J8dMLUZP9PCCaYgq4biFahoanmeNw69qC6cpsgagmd4WbeHExv5wIU(elJDV0Iw55aKnamygG8b8Hk1acpGDDk0xe(zvQgqWdqK2hGm010Ebt09XU9GeXcHQsHCe(TJWdDnTxWeD3ftoU(elJOlN2NYrKGih5OBcjpJIWdHVii8qxoTpLJibrxt7fmr3k3mjn6s5KsugDJSstkXEbt0fFi5z0bGfGU5fmrxnPCMug6ULO0fH1cnYjV86Xdi4biYacpa5d4Wb4gLtVVP2JxAIPe250(uooamygG8beHExvNfDb3Rn1ECNWpRs1acEanoGWd4WbyAVGzVYntsJUuoPeL7Q6SOlXutZXbiBaYqoc)dq4HUM2lyIUFjQOloWoX0Ebt0Lt7t5isqKJWVreEOlN2NYrKGORMuotkdDLpa5d4lT39h72dseleQkvxs8acpa3OC69nX0UeH7CAFkhhq4bOGs01MyNpoD1aAa3aACaYgagmdqbLORnXoFC6Qb0aUb0MbidDnTxWeDvIls5Rp89roc)2GWdD50(uoIeeD1KYzszORBPOvEoGWdq(amTxH4fN8Ry1aAyaImamygGBuo9EKFWS0DoTpLJdqg6AAVGj6Uz6kYHmLBEbtKJWVDeEOlN2NYrKGORMuotkdDLpa5dWnkNExjUiLV(W3VZP9PCCaHhGckrxBID(40vda3aeyaYgagmd4Wb4gLtVRexKYxF47350(uooazdi8aKpa5dWnkNEFtmTlr4oN2NYXbeEaBjYXb0aUb0E7dq2aWGzaYhWHdWnkNEFtmTlr4oN2NYXbeEaBjYXb0aUb0CcmazdadMbOHqAeID23mDf5qMYnVGzNWpRs1aAyaUrozV71JxoCflEayWma5d4lT39h72dseleQkvxs8acpa5dq(aCJYP33et7seUZP9PCCaHhWwICCanGBan2(aKnamygG8bC4aCJYP33et7seUZP9PCCaHhWwICCanGBaTlWaKnazdq2aKHUM2lyIUkOeDPPSfIrocFSicp0Lt7t5isq0vtkNjLHUYhG8beYiL9PC)tSmU(sfnoGWdqdH0ie7SVlMCC9jwg7e(zvQgqddqebgGSbGbZaoCaHmszFk3)elJRVurJdq2acpGTe54acg3aAEbqxt7fmr369GuZlyUmjIHCe(nhcp0Lt7t5isq0vtkNjLHUBjYXbemUbGffaDnTxWeD3m9tTiJCe(yjeEOlN2NYrKGORMuotkdD3sKJdi4b0OadadMbiFaYhGBuo9UsCrkF9HVFNt7t54acpafuIU2e78XPRgqW4gqJdq2aWGzaYhWHdWnkNExjUiLV(W3VZP9PCCaHhG8biFaFP9U)y3EqIyHqvP6sIhq4bSLihhqW4gq7TpazdadMbiFaFP9U)y3EqIyHqvP6ri25acpGTe54acg3aAobgGSbiBaYgGm010Ebt0DtmTlryKJWV5r4HUCAFkhrcIUAs5mPm09WbiFaAyioT07IEKuwoGWdGiL8gso5oXcuMwIkuTI8UO8JtVZP9PCCaYqxt7fmrxvDw0fCV2u7XihHVicGWdDnTxWeDvczJGUCAFkhrcICe(Iiccp010Ebt01fsGyVoPwfIrxoTpLJibroYro6AsUqibDV1Rze5ihHa]] )


end
