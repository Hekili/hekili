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
    
    -- Tier 28:
    spec:RegisterSetBonuses( "tier28_2pc", 364454, "tier28_4pc", 363737 )
    -- 2-Set - Burning Hunger - Damage dealt by Immolation Aura has a 10% chance to generate a Lesser Soul Fragment.
    -- 4-Set - Rapacious Hunger - Consuming a Lesser Soul Fragment reduces the remaining cooldown of your Immolation Aura or Fel Devastation by 1 sec.
    -- Nothing to model (2/13/22).

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


    spec:RegisterPack( "Vengeance", 20220306, [[dOuaNaqivipIqWMKiFsfkJIkCkIQvrLQQxrf1SKa7ss)IO0WisDmIILrLYZKqnnvO6AQG2gHO(gvQ04OIGZrLkwhHqnpjK7bj7tc6GeI0cjKEOkanrvG6IecPnsfrFKkvfJufqDsvaSsjQzQci3Kkc1oHO(jHq0svbYtvPPcPSvQiKVsieglHi2lu)vjdg4WuwSQ8ysnzQ6YO2Ss9zv0OjuNwQxtKmBe3wvTBr)g0WjIJtLQslhPNtY0fUobBNk57qQgpvKopez9uPkZhc7xXyzWOHVElymYUjTBUjDXslYvzCx3e5JJVbssy8vIPLYoz8nTpJVorCEYwQz8vIHebAEmA4Rckq1m(kocjkrSSYE2HyHxvd)YQ6VaXIgMAQTdzv9xll((eAsCas8dF9wWyKDtA3Ct6ILwKRY4UUjYf7o4RscRXiFOtqg8vC79CIF4RNvA89G5pmhWbwidMoaNiopzl18u2j2OAXdqKlyaUjTBUnLNYIucbI(aCsQPdbkpalgabI(aCsbksdWHek7IZqnaNuGI0aALsGvda9oepGRKM2Xaef(FYR4RekC3egFfbryahm)H5aoWczW0b4eX5jBPMNYIGimaNyJQfparUGb4M0U52uEklcIWaePece9b4KuthcuEawmace9b4KcuKgGdju2fNHAaoPafPb0kLaRga6DiEaxjnTJbik8)KxNYtzthnmvvjuwd)plq9Grqy)AtmKyp6DEUcOt7CkB6OHPQkHYA4)zHZOKDtyLyn12rb9gLckqED6RseuHaHxmvqs0WebcfuG860xDbjw0eEPGexCgt5PSimaruNYAHG9dGDXuKgq0FEaHyEaMoG0b0QbyUSMypcxNYMoAyQCgLSUmABpcxqAFg1JAPF9eAIVaxgrGrfgHZOANWSDVopxBI9zvLt7ryFPWiCg1Nan78CzK2fx50Ee2xkmcNrvl2Ou2V2ewjUYP9iSFkB6OHPYzuY6BfvqsmLnD0Wu5mkz1Wuj8513oB9u20rdtLZOKLYUyQIxF7S1tzthnmvoJs2qmfI(6KyTlUGEJ6jS31ntwp4)zu)NZOQctlfQdl54jS31()HelAyUmbQvfKGaXrpH9U(5W(qQeXqvRQcsKpLnD0Wu5mkz1gHSmD0WCrAvuqAFg1JAPVavqBDGsMc6nkxgTThHRpQL(1tOj(PSPJgMkNrjR2iKLPJgMlsRIcs7ZO88Mtv7IvtzthnmvoJswTrilthnmxKwffK2NrPHqIhIEQMYMoAyQCgLSAJqwMoAyUiTkkiTpJkH0VrMYtzryaozZuKgGOul9d4GGHfnmNYMoAyQQpQLEu7MPiTEul9tzthnmv1h1sVZOKT)FiXIgMltGAf0BuEyu3ntrA9Ow6RrRLQZZP8u20rdtvvdHepe9uHscmAyoLnD0Wuv1qiXdrpvoJswnm1Cguly)AtSpxqVr54ipmQAyQ5mOwW(1MyFE9eOznATuDEw6ithnmRAyQ5mOwW(1MyFU25At6tXbceBbczrzTyJEYRO)CrNAF9Bov(u20rdtvvdHepe9u5mkzrhsjExCNlkRGPLAUGEJ6jS3vsV5hbc9vvyAPkQ4PSPJgMQQgcjEi6PYzuY(5pKI0cUxebD7xEkBF1uwegWbgs8d4GytsNNdWjj2NvdydPdGDkRfcEaulp5baPdqQMqgWtyVvfmGEpajqLQFeUoarkbDdj1acksdiGd4KJbeI5bqGOZQyaAiK4HONd4zk2payoaZL1e7r4bWj)BwvNYMoAyQQAiK4HONkNrjlLnjDEU2e7ZQc6nQWONCuJ(ZRaU8nxKm1drGWHJWONCufZgjexLOJcDcsJary0toQIzJeIRs0rrOCtA5LCy6ODXlo5FZkuYGaXUpfhlk)Tovf6M7ixoceocJEYrn6pVc4sIowUjDHflDjhMoAx8It(3ScLmiqS7tXXIYFRtvHh)4YLpLfHbCW82eiXa2gH8mTudydPdqqzpcpawP4uZQ6u20rdtvvdHepe9u5mkzfZgnwSsXPMNYMoAyQQAiK4HONkNrjRGIxDW)c49M1XkTpJsJKMadkmB96rmvuqVr9e276N)qksl4Ere0TF5PS9vvpe9CkB6OHPQQHqIhIEQCgLSckE1b)liTpJYuIDzjRwuZ9G0Lgsnsb9gLNFc7DLAUhKU0qQrwE(jS3vpe9ebcp)e27QgMEbD0U4vNsT88tyVRcskfg9KJQy2iH4QeDuuXYGary0toQr)5vax(MlYnPNYIWaoyEBcKyaBJqEMwQbSH0biOShHhqh8xvNYMoAyQQAiK4HONkNrjRGIxDWF1u20rdtvvdHepe9u5mkzvDUfiRh1sFb9g1rEyuvDUfiRh1sFnATuDEoLnD0Wuv1qiXdrpvoJs2qmVelKXu20rdtvvdHepe9u5mkzzcsQ2YLN1uMNYtzryahmV5u1Uy1u20rdtv1ZBovTlwHYZFyUusAPyvb9gvyPuDEwYHJTaHSOSwSrp5v0FUizk1Pg(78C5TVDYRIvYrGWHPJ2fV4K)nRkS4sDQH)opxE7BN8QyvPNWEx98hMlLKwkwv9q0t5iq4Otn8355YBF7KxhQku6QBh6(fZgjex)MtLlFkB6OHPQ65nNQ2fRCgLSkOaz9mkTzAb9gLdthTlEXj)BwvyXL6ud)DEU823o5vXQspH9U65pmxkjTuSQ6HONYrGWrNA4VZZL3(2jVouvO01J7(fZgjex)MtLpLnD0Wuv98Mtv7IvoJs2NarQf70GA6OHzb9gLy2iH4QeMQ5mk6qPNYMoAyQQEEZPQDXkNrj7Nd7dPsedvTQGEJ6ihHr4mQE(dZwx50Ee2lVKJJ0qxCAzuDXzigjkceh5Hrv15wGSEul91O1s15PCeiC8GkvPDFkowu(BDQksMdLpLnD0Wuv98Mtv7IvoJs2DZuKwpQL(P8uwegaYq63id4GGHfnmNYMoAyQQjK(nIZOKTZnttJSubTLIlO3O2ceYIYAXg9Kxr)5IKPKJJcJWzu3e7Zln1uIRCApc7rGWHhgvvF2KfCV2e7Zvk)TovfvCPJmD0WS25MPPrwQG2sXvvF2KLeIPzVC5tzthnmv1es)gXzuY(eisTyNguthnmNYMoAyQQjK(nIZOKvjPPDSEW)RGEJYHJNWEx)CyFivIyOQvvbjLcJWzu3uthcuUYP9iSVKckqwBQD(5mufIQy5iqOGcK1MANFodvHOoU8PSPJgMQAcPFJ4mkz3mz5zxMkSOHzb9gvyPuDEwYHPJ2fV4K)nRkugeicJWzu98hMTUYP9iSx(u20rdtvnH0VrCgLSkOazPjS5IlO3OC4imcNrvjPPDSEW)RYP9iSVKckqwBQD(5muOKwocehfgHZOQK00owp4)v50Ee2lVKdhHr4mQBQPdbkx50Ee2xAlqrQquhEOCeiCCuyeoJ6MA6qGYvoThH9L2cuKkeL7kTCei0qiXdrpRBMS8Sltfw0WSs5V1PQWWONCuJ(ZRaU8nJaHJNWEx)CyFivIyOQvvbjLC4imcNrDtnDiq5kN2JW(sBbksfIQ4dLJaHJJcJWzu3uthcuUYP9iSV0wGIuHOouA5YLlFkB6OHPQMq63ioJs2()HelAyUmbQvqVr5WHlJ22JW1h1s)6j0eFjnes8q0Z6UzksRh1sFLYFRtvHYiTCeioYLrB7r46JAPF9eAIxEPTafPIq5ospLnD0Wuvti9BeNrj7MjpI55c6nQTafPIqjYspLnD0Wuvti9BeNrj7MA6qGYf0BuBbksfvS0iq4WryeoJQsst7y9G)xLt7ryFjfuGS2u78ZzOkcvXYrGWXrHr4mQkjnTJ1d(FvoThH9LC44jS31ph2hsLigQAvvqsPTafPIqD4HYrGWXtyVRFoSpKkrmu1QQhIEwAlqrQiuUR0YLlx(u20rdtvnH0VrCgLSQ(Sjl4ETj2NlO3OoYHg6ItlJQuirBllrfsEdPNCLAUhtAPeRwEE3e(ZziFkB6OHPQMq63ioJswLy2Otzthnmv1es)gXzuYgIPq0xNeRDX4RlMQAyIr2nPDtgzKXTIXx0nA25PcFfrispiKpai7(iIhWaqtmpG(lbsJbSH0bCmjuwd)plo2aOS7Rqtz)auWppatiGFly)a0IT8Kv1P8bQtEaUjIhWbeMUyAW(bCmfuG860xfjhBabCahtbfiVo9vrsLt7ry)XgGdzCQ86u(a1jpa3eXd4actxmny)aoMckqED6RIKJnGaoGJPGcKxN(QiPYP9iS)ydWIbiIkI8anahY4u51P8uweHi9Gq(aGS7JiEadanX8a6VeingWgshWXsi9BKJnak7(k0u2paf8ZdWec43c2paTylpzvDkFG6KhG7iIhWbeMUyAW(bCmQqYBi9KRIKJnGaoGJrfsEdPNCvKu50Ee2FSb4qgNkVoLNYhGVeiny)ae5by6OH5aiTku1Pm(sAvOWOHVpQLEmAyKLbJg(YP9iShlk(6zLM2sIgM4Rt2mfPbik1s)aoiyyrdt810rdt8D3mfP1JAPhhyKDdJg(YP9iShlk(QPDW02WxpmQ7MPiTEul91O1s15j(A6OHj(2)pKyrdZLjqnCGd81ZBtGey0Wildgn8Lt7rypwu8fkbFvCGVMoAyIVUmABpcJVUmIaJVHr4mQ2jmB3RZZ1MyFwv50Ee2pGsdimcNr9jqZopxgPDXvoThH9dO0acJWzu1InkL9RnHvIRCApc7XxpR00ws0WeFfrDkRfc2pa2ftrAar)5beI5by6ashqRgG5YAI9iCfFDz0vAFgFFul9RNqt84aJSBy0WxthnmXxFROcsc8Lt7rypwuCGrUymA4RPJgM4RgMkHpV(2zRXxoThH9yrXbg5JJrdFnD0WeFPSlMQ413oBn(YP9iShlkoWiFign8Lt7rypwu8vt7GPTHVpH9UUzY6b)pJ6)CgvvyAPgaQbC4aknahd4jS31()HelAyUmbQvfKmaeigWrd4jS31ph2hsLigQAvvqYaKJVMoAyIVHyke91jXAxmoWilYy0WxoThH9yrXxnTdM2g(6YOT9iC9rT0VEcnXJVQG26aJSm4RPJgM4R2iKLPJgMlsRc8L0QyL2NX3h1spoWi7Uy0WxoThH9yrXxthnmXxTrilthnmxKwf4lPvXkTpJVEEZPQDXkCGr2jGrdF50Ee2JffFnD0WeF1gHSmD0WCrAvGVKwfR0(m(QHqIhIEQWbgz3bJg(YP9iShlk(A6OHj(Qnczz6OH5I0QaFjTkwP9z8nH0VrWboWxjuwd)plWOHrwgmA4RPJgM47dgbH9RnXqI9O355kGoTt8Lt7rypwuCGr2nmA4lN2JWESO4RM2btBdFvqbYRtFvIGkei8IPcsIgMvoThH9dabIbOGcKxN(QliXIMWlfK4IZOYP9iShFnD0WeF3ewjwtTDGdCGVAiK4HONkmAyKLbJg(A6OHj(kbgnmXxoThH9yrXbgz3WOHVCApc7XIIVAAhmTn81XaoAaEyu1WuZzqTG9RnX(86jqZA0AP68CaLgWrdW0rdZQgMAodQfSFTj2NRDU2K(uCmaeigWwGqwuwl2ON8k6ppGIgWP2x)MthGC810rdt8vdtnNb1c2V2e7Z4aJCXy0WxoThH9yrXxnTdM2g((e27kP38JaH(QkmTudOObum(A6OHj(IoKs8U4oxuwbtl1moWiFCmA4RPJgM47N)qksl4Ere0TF5PS9v4lN2JWESO4aJ8Hy0WxoThH9yrXxthnmXxkBs68CTj2Nv4RNvAAljAyIVhyiXpGdInjDEoaNKyFwnGnKoa2PSwi4bqT8KhaKoaPAczapH9wvWa69aKavQ(r46aePe0nKudiOinGaoGtogqiMhabIoRIbOHqIhIEoGNPy)aG5amxwtShHhaN8VzvfF10oyAB4By0toQr)5vax(MhqrdqM6HdabIb4yaogqy0toQIzJeIRs0XakCaobPhacedim6jhvXSrcXvj6yafHAaUj9aKpGsdWXamD0U4fN8Vz1aqnazgacedy3NIJfL)wNQbu4aCZDgG8biFaiqmahdim6jh1O)8kGlj6y5M0dOWbuS0dO0aCmathTlEXj)BwnaudqMbGaXa29P4yr5V1PAafoGJF8biFaYXbgzrgJg(YP9iShlk(6zLM2sIgM47bZBtGedyBeYZ0snGnKoabL9i8ayLItnRQ4RPJgM4Ry2OXIvko1moWi7Uy0WxoThH9yrXxthnmXxnsAcmOWS1RhXub(QPDW02W3NWEx)8hsrAb3lIGU9lpLTVQ6HON4lV3SowP9z8vJKMadkmB96rmvGdmYobmA4lN2JWESO4RPJgM4RPe7YswTOM7bPlnKAe8vt7GPTHVE(jS3vQ5Eq6sdPgz55NWEx9q0ZbGaXa88tyVRAy6f0r7IxDk1YZpH9UkizaLgqy0toQIzJeIRs0XakAaflZaqGyaHrp5Og9NxbC5BEafna3KgFt7Z4RPe7YswTOM7bPlnKAeCGr2DWOHVCApc7XIIVEwPPTKOHj(EW82eiXa2gH8mTudydPdqqzpcpGo4VQIVMoAyIVckE1b)v4aJSmsJrdF50Ee2JffF10oyAB47rdWdJQQZTaz9Ow6RrRLQZt810rdt8v15wGSEul94aJSmYGrdFnD0WeFdX8sSqg4lN2JWESO4aJSmUHrdFnD0WeFzcsQ2YLN1uMXxoThH9yrXboWxpV5u1UyfgnmYYGrdF50Ee2JffFnD0WeF98hMlLKwkwHVEwPPTKOHj(EW8Mtv7Iv4RM2btBdFdlLQZZbuAaogGJbSfiKfL1In6jVI(ZdOObiZaknGo1WFNNlV9TtEvSAaYhacedWXamD0U4fN8Vz1akCafpGsdOtn8355YBF7KxfRgqPb8e27QN)WCPK0sXQQhIEoa5dabIb4yaDQH)opxE7BN86q1akCasxD7Wb4(hGy2iH463C6aKpa54aJSBy0WxoThH9yrXxnTdM2g(6yaMoAx8It(3SAafoGIhqPb0Pg(78C5TVDYRIvdO0aEc7D1ZFyUusAPyv1drphG8bGaXaCmGo1WFNNlV9TtEDOAafoaPRhFaU)biMnsiU(nNoa54RPJgM4RckqwpJsBMIdmYfJrdF50Ee2JffF10oyAB4Ry2iH4QeMQ5mgqrd4qPXxthnmX3NarQf70GA6OHjoWiFCmA4lN2JWESO4RM2btBdFpAaogqyeoJQN)WS1voThH9dq(aknahd4ObOHU40YO6IZqms0bGaXaoAaEyuvDUfiRh1sFnATuDEoa5dabIb4yapOsnGsdy3NIJfL)wNQbu0aK5WbihFnD0WeF)CyFivIyOQv4aJ8Hy0WxthnmX3DZuKwpQLE8Lt7rypwuCGd8nH0VrWOHrwgmA4lN2JWESO4RPJgM4BNBMMgzPcAlfJVEwPPTKOHj(ImK(nYaoiyyrdt8vt7GPTHVBbczrzTyJEYRO)8akAaYmGsdWXaoAaHr4mQBI95LMAkXvoThH9dabIb4yaEyuv9ztwW9AtSpxP836unGIgqXdO0aoAaMoAyw7CZ00ilvqBP4QQpBYscX0SFaYhGCCGr2nmA4RPJgM47tGi1IDAqnD0WeF50Ee2JffhyKlgJg(YP9iShlk(QPDW02WxhdWXaEc7D9ZH9HujIHQwvfKmGsdimcNrDtnDiq5kN2JW(buAakOazTP25NZqnGcrnGIhG8bGaXauqbYAtTZpNHAafIAahFaYXxthnmXxLKM2X6b)pCGr(4y0WxoThH9yrXxnTdM2g(gwkvNNdO0aCmathTlEXj)BwnGchGmdabIbegHZO65pmBDLt7ry)aKJVMoAyIVBMS8Sltfw0WehyKpeJg(YP9iShlk(QPDW02WxhdWXacJWzuvsAAhRh8)QCApc7hqPbOGcK1MANFod1aqnaPhG8bGaXaoAaHr4mQkjnTJ1d(FvoThH9dq(aknahdWXacJWzu3uthcuUYP9iSFaLgWwGI0ake1ao8WbiFaiqmahd4ObegHZOUPMoeOCLt7ry)aknGTafPbuiQb4Uspa5dabIbOHqIhIEw3mz5zxMkSOHzLYFRt1akCaHrp5Og9NxbC5BEaiqmahd4jS31ph2hsLigQAvvqYaknahdWXacJWzu3uthcuUYP9iSFaLgWwGI0ake1ak(WbiFaiqmahd4ObegHZOUPMoeOCLt7ry)aknGTafPbuiQbCO0dq(aKpa5dqo(A6OHj(QGcKLMWMlghyKfzmA4lN2JWESO4RM2btBdFDmahdWLrB7r46JAPF9eAIFaLgGgcjEi6zD3mfP1JAPVs5V1PAafoazKEaYhaced4Ob4YOT9iC9rT0VEcnXpa5dO0a2cuKgqrOgG7in(A6OHj(2)pKyrdZLjqnCGr2DXOHVCApc7XIIVAAhmTn8DlqrAafHAaIS04RPJgM47MjpI5zCGr2jGrdF50Ee2JffF10oyAB47wGI0akAafl9aqGyaogGJbegHZOQK00owp4)v50Ee2pGsdqbfiRn1o)CgQbueQbu8aKpaeigGJbC0acJWzuvsAAhRh8)QCApc7hqPb4yaogWtyVRFoSpKkrmu1QQGKbuAaBbksdOiud4WdhG8bGaXaCmGNWEx)CyFivIyOQvvpe9CaLgWwGI0akc1aCxPhG8biFaYhGC810rdt8DtnDiqzCGr2DWOHVCApc7XIIVAAhmTn89Ob4yaAOloTmQsHeTTCaLgavi5nKEYvQ5EmPLsSA55Dt4pNrLt7ry)aKJVMoAyIVQ(Sjl4ETj2NXbgzzKgJg(A6OHj(QeZgfF50Ee2JffhyKLrgmA4RPJgM4BiMcrFDsS2fJVCApc7XIIdCGd81ecXqk(E7)beh4aJb]] )


end
