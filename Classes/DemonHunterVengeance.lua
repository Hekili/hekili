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


    spec:RegisterPack( "Vengeance", 20211123, [[dGuvLaqivbpIaytcXNia1OiQofrzvcPsVsGAwcQ2Lu9lbyyerhdQYYek9mb00ufQRjuSnci(MQqmociDobswhbiMNGY9Gs7ti5Geq1cjqpuGuAIcPQlkqQAJce(ibuYifsfNKakwPq1mfif2juXsvfspvLMkuPTsasFvGu0yfiv2lK)QKbdCyklwv9ysnzPCzuBwP(SQ0OjOtl51eHzJ0TvXUf9BqdNiDCcOulhXZjz6uDDcTDb57qvnEHuoVQO1lq08HI9RyeEiCr3M5mcNyLmw8WdVydShlEXeiEpgD9Nsz0vQPLWEz0nTdJUcOC(YwQz0vQ9KcTgcx0vbfjAgDf6UuLasab8wUqXFxdpbOQJi18cMAIT9au1rha6(flQlWKOp62mNr4eRKXIhE4fBG9yXlMaLmOqxLuwJWjgbkEORWQ14e9r3gR0OB0ZhyoGOJy6mzacOC(YwQ5jooWq85ZKbGxGHpGyLmw8M4tCboLcXFabbX0UiHhG5dGcXFabHi55aKlLWH40vdiiejphqPuISAa4xUWbCLwKYhGGWZxwhDLsG7IYORaiadi65dmhq0rmDMmabuoFzl18exaeGbGdmeF(mza4fy4diwjJfVj(exaeGbiWPui(diiiM2fj8amFaui(diiejphGCPeoeNUAabHi55akLsKvda)YfoGR0Iu(aeeE(Y6t8jUP9cMQUucRHNV5y)q3PCBTP2tUHFLVlhgTkN4tCbyab9rJ1Io3gahIjphGxhEaUqEaM2HKbuQbyHSIAFk3N4M2lyQcgBaHmszFkhEAhg7NyzB9flAl8qgvKX6gLtVBVWScYkFxBQDyvNt7t5we3OC69VijR8Dz0ke350(uUfXnkNExl0ieUT2uwjSZP9PCBIBAVGPkySb0kfruQpXnTxWufm2a0WujE41XEl9e30EbtvWydGWHyIIxh7T0tCt7fmvbJnaxibI)6LAvio8AJ9lU39ntxF45BK2HtVRCtlb2yIi)lU396CGuZlyUmrI1fLIbZdFX9UFy3oqIuHqvP6IsLnXnTxWufm2a0gLUmTxWCrlLhEAhg7NyzlCLtkTJfVWRn2qgPSpL7FILT1xSOTjUP9cMQGXgG2O0LP9cMlAP8Wt7WyB8MtvfIvtCt7fmvbJnaTrPlt7fmx0s5HN2HXQHqAdIFQM4M2lyQcgBaAJsxM2lyUOLYdpTdJnHKJrN4tCbyabrXKNdqqILTb8Oq38cMtCt7fmv9pXYg2DXKNRpXY2e30Ebtv)tSSfm2aQZbsnVG5Yejw41gBd69DXKNRpXYw3lTev(oXN4M2lyQ6AiK2G4NkSsHEbZjUP9cMQUgcPni(PkySbOHPMtNyo3wBQD4WRnw5p0GExdtnNoXCUT2u7WRVij7EPLOY3ipyAVGzxdtnNoXCUT2u7W9kxBA9k0XGzlsPlcRfAKxE51Hd7v36hlAYM4M2lyQ6AiK2G4NQGXga(qcTfIRCryfmTuZHxBSFX9UtRn)PqyRRCtlryboXnTxWu11qiTbXpvbJnGdFGKNl4Erf1vB1iSDutCbyarhiTnGhLnPv(oGGGAhwnGnKmaoASw05bqS8LhaKmajkkDaFX9wf(aQ9aKcvQ6t5(ae4u8TNQb4KNdWHd4L9b4c5bqH4ZkFaAiK2G4Nd4BkUnayoalKvu7t5bWjFkw1N4M2lyQ6AiK2G4NQGXgaHnPv(U2u7WQWRnw3iVS396WlhUAfhgE9yWGrUC3iVS3fYg1f2LQ9OeOsIbJBKx27czJ6c7s1EyyJvszrKBAVcXlo5tXkS4HbZUEf6lcFSkvrfBqjtggmYDJ8YE3RdVC4sQ2xXkzubkze5M2Rq8It(uSclEyWSRxH(IWhRsvup(XYKnXfGbe982eP(a2gL(nTedydjdquzFkpawP4uZQ(e30EbtvxdH0ge)ufm2aeYgXxSsXPMN4M2lyQ6AiK2G4NQGXgGOIxLZNW59M1(kTdJv)utHobMLE9PMYdV2y)I7D)Whi55cUxurD1wncBhvVbXpN4M2lyQ6AiK2G4NQGXgGOIxLZNWt7WynLWqwYQfXcsizPHeJgETX24V4E3jwqcjlnKy0vJ)I7DVbXpXGPXFX9URHztu7viEvPeRg)f37UO0iUrEzVlKnQlSlv7HfiEyW4g5L9UxhE5WvR4WIvYjUamGON3Mi1hW2O0VPLyaBizaIk7t5buoFu9jUP9cMQUgcPni(PkySbiQ4v58rnXnTxWu11qiTbXpvbJnavLBr66tSSfETX(qd6DvLBr66tSS19slrLVtCt7fmvDnesBq8tvWydWfYlHIPpXnTxWu11qiTbXpvbJnaM(uvwUASMW8eFIladi65nNQkeRM4M2lyQ6nEZPQcXkSn(aZLsAjbRcV2yDlLOY3iYLVfP0fH1cnYlV86WHHxKk1WtLVRMDSxEfOsggmYnTxH4fN8PyvubgPsn8u57Qzh7LxbQI8f37EJpWCPKwsWQEdIFkddg5vQHNkFxn7yV8kgvus2JnMORq2OUW(XIMmztCt7fmv9gV5uvHyvWydqbfPRVriftcV2yLBAVcXlo5tXQOcmsLA4PY3vZo2lVcuf5lU39gFG5sjTKGv9ge)uggmYRudpv(UA2XE5vmQOKS)4ORq2OUW(XIMSjUP9cMQEJ3CQQqSkySb8fPsS4O5et7fmdV2yfYg1f2LYenNEyXi5e30EbtvVXBovviwfm2aoSBhirQqOQuHxBSpi3nkNEVXhyw6oN2NYnzrK)GggItl9EioDHpjyW8qd6DvLBr66tSS19slrLVYWGr(hQur21RqFr4JvPkm8Ir2e30EbtvVXBovviwfm2a2ftEU(elBt8jUamaCGKJrhWJcDZlyoXnTxWu1ti5y0GXgqLBMKgDPCsjbhETXUfP0fH1cnYlV86WHHxe5p4gLtVVP2HxAIPe250(uUHbJ8g07Q6TOl4ETP2H7e(yvQclWipyAVGzVYntsJUuoPKG7Q6TOlPutZnzYM4M2lyQ6jKCmAWyd4lsLyXrZjM2lyoXnTxWu1ti5y0GXgGsArkF9HNF41gRC5FX9UFy3oqIuHqvP6IsJ4gLtVVjM2fjCNt7t5wefuKU2e79WPRIcBGYWGrbfPRnXEpC6QOW(yztCt7fmv9esognySbSz6QXHmLBEbZWRnw3sjQ8nICt7viEXjFkwffEyW4gLtV34dmlDNt7t5MSjUP9cMQEcjhJgm2auqr6stzlehETXkxUBuo9UsArkF9HNFNt7t5wefuKU2e79WPRWkPmmyEWnkNExjTiLV(WZVZP9PCtwe5YDJYP33et7IeUZP9PClYwK8mkSXeJmmyK)GBuo9(MyAxKWDoTpLBr2IKNrH9rKuggmAiK2G4N9ntxnoKPCZly2j8XQufLBKx27ED4LdxTIXGr(xCV7h2TdKiviuvQUO0iYL7gLtVVjM2fjCNt7t5wKTi5zuydmgzyWi)b3OC69nX0UiH7CAFk3ISfjpJcBmsktMmztCt7fmv9esognySbuNdKAEbZLjsSWRnw5YdzKY(uU)jw2wFXI2IOHqAdIF23ftEU(elBDcFSkvrHNKYWG5HqgPSpL7FILT1xSOnzr2IKNHHnOKCIBAVGPQNqYXObJnGnt)uRXHxBSBrYZWWkqKCIBAVGPQNqYXObJnGnX0UiHdV2y3IKNHfOKyWixUBuo9UsArkF9HNFNt7t5wefuKU2e79WPRcdBGYWGr(dUr507kPfP81hE(DoTpLBrKl)lU39d72bsKkeQkvxuAKTi5zyyJjgzyWi)lU39d72bsKkeQkvVbXpJSfjpdd7JiPmzYKnXnTxWu1ti5y0GXgGQEl6cUxBQD4WRn2hKRHH40sVlXtszzeIyYBi5L7elizAjHq1QX7IYhoDztCt7fmv9esognySbOeYgzIBAVGPQNqYXObJnaxibI)6LAvigDdXevbteoXkzS4j5JLmq0fFJKv(Qq3GMc8hfhbgCeyjGmGbGRqEa1rkK4dydjdqaNqYXOc4bqyb2IfHBdqbp8amrhEmNBdql0Yxw1N4bnQKhqqjGmGGwygIjo3gGaMiM8gsE5EqNaEaoCacyIyYBi5L7bDDoTpLBc4bihVOjRpXN4cmhPqIZTbiqgGP9cMdGwkx1N4OlTuUcHl6(jw2q4IWbpeUOlN2NYnKGOBJvAsj1lyIUbrXKNdqqILTb8Oq38cMORP9cMO7UyYZ1Nyzd5iCIfHl6YP9PCdji6QjLZKYq3g077IjpxFILTUxAjQ8fDnTxWeDRZbsnVG5YejgYro624TjsDeUiCWdHl6YP9PCdji6cLIUk2rxt7fmr3qgPSpLr3qgvKrx3OC6D7fMvqw57AtTdR6CAFk3gqKb4gLtV)fjzLVlJwH4oN2NYTbezaUr507AHgHWT1MYkHDoTpLBOBJvAsj1lyIUb9rJ1Io3gahIjphGxhEaUqEaM2HKbuQbyHSIAFk3r3qgzL2Hr3pXY26lw0gYr4elcx010Ebt0TvkIOuhD50(uUHee5iCceHl6AAVGj6QHPs8WRJ9wA0Lt7t5gsqKJW5XiCrxt7fmrxchIjkEDS3sJUCAFk3qcICeoXGWfD50(uUHeeD1KYzszO7xCV7BMU(WZ3iTdNEx5MwIbGDaXmGidq(a(I7DVohi18cMltKyDrPdadMb8Wa(I7D)WUDGePcHQs1fLoazORP9cMORlKaXF9sTkeJCeoceeUOlN2NYnKGORMuotkdDdzKY(uU)jw2wFXI2qxLtkTJWbp010Ebt0vBu6Y0EbZfTuo6slLVs7WO7Nyzd5iCEeeUOlN2NYnKGORP9cMOR2O0LP9cMlAPC0LwkFL2Hr3gV5uvHyfYr4iqr4IUCAFk3qcIUM2lyIUAJsxM2lyUOLYrxAP8vAhgD1qiTbXpvihHtqHWfD50(uUHeeDnTxWeD1gLUmTxWCrlLJU0s5R0om6MqYXOih5ORucRHNV5iCr4Ghcx010Ebt09dDNYT1MAp5g(v(UCy0QeD50(uUHee5ihD1qiTbXpviCr4Ghcx010Ebt0vk0lyIUCAFk3qcICeoXIWfD50(uUHeeD1KYzszOR8b8WaAqVRHPMtNyo3wBQD41xKKDV0su57aImGhgGP9cMDnm1C6eZ52AtTd3RCTP1RqFayWmGTiLUiSwOrE5LxhEaHnGxDRFSOnazORP9cMORgMAoDI5CBTP2HrocNar4IUCAFk3qcIUAs5mPm09lU3DAT5pfcBDLBAjgqydiq010Ebt0fFiH2cXvUiScMwQzKJW5XiCrxt7fmr3dFGKNl4Erf1vB1iSDuOlN2NYnKGihHtmiCrxoTpLBibrxt7fmrxcBsR8DTP2HvOBJvAsj1lyIUrhiTnGhLnPv(oGGGAhwnGnKmaoASw05bqS8LhaKmajkkDaFX9wf(aQ9aKcvQ6t5(ae4u8TNQb4KNdWHd4L9b4c5bqH4ZkFaAiK2G4Nd4BkUnayoalKvu7t5bWjFkw1rxnPCMug66g5L9UxhE5WvR4be2aWRhZaWGzaYhG8b4g5L9Uq2OUWUuTpGOgGavYbGbZaCJ8YExiBuxyxQ2hqyyhqSsoazdiYaKpat7viEXjFkwnaSdaVbGbZa21RqFr4JvPAarnGydQbiBaYgagmdq(aCJ8YE3RdVC4sQ2xXk5aIAabk5aIma5dW0EfIxCYNIvda7aWBayWmGD9k0xe(yvQgqud4XpEaYgGmKJWrGGWfD50(uUHeeDBSstkPEbt0n65Tjs9bSnk9BAjgWgsgGOY(uEaSsXPMvD010Ebt0viBeFXkfNAg5iCEeeUOlN2NYnKGORP9cMOR(PMcDcml96tnLJUAs5mPm09lU39dFGKNl4Erf1vB1iSDu9ge)eD59M1(kTdJU6NAk0jWS0Rp1uoYr4iqr4IUCAFk3qcIUM2lyIUMsyilz1IybjKS0qIrrxnPCMug624V4E3jwqcjlnKy0vJ)I7DVbXphagmdOXFX9URHztu7viEvPeRg)f37UO0bezaUrEzVlKnQlSlv7diSbeiEdadMb4g5L9UxhE5WvR4be2aIvs0nTdJUMsyilz1IybjKS0qIrrocNGcHl6YP9PCdji62yLMus9cMOB0ZBtK6dyBu630smGnKmarL9P8akNpQo6AAVGj6kQ4v58rHCeo4jjcx0Lt7t5gsq0vtkNjLHUpmGg07Qk3I01NyzR7LwIkFrxt7fmrxvLBr66tSSHCeo4Hhcx010Ebt01fYlHIPJUCAFk3qcICeo4flcx010Ebt0LPpvLLRgRjmJUCAFk3qcICKJUnEZPQcXkeUiCWdHl6YP9PCdji6AAVGj624dmxkPLeScDBSstkPEbt0n65nNQkeRqxnPCMug66wkrLVdiYaKpa5dylsPlcRfAKxE51HhqydaVbezavQHNkFxn7yV8kq1aKnamygG8byAVcXlo5tXQbe1acCargqLA4PY3vZo2lVcunGid4lU39gFG5sjTKGv9ge)CaYgagmdq(aQudpv(UA2XE5vmQbe1aKShBmdi6oaHSrDH9JfTbiBaYqocNyr4IUCAFk3qcIUAs5mPm0v(amTxH4fN8Py1aIAaboGidOsn8u57Qzh7LxbQgqKb8f37EJpWCPKwsWQEdIFoazdadMbiFavQHNkFxn7yV8kg1aIAas2F8aIUdqiBuxy)yrBaYqxt7fmrxfuKU(gHumb5iCceHl6YP9PCdji6QjLZKYqxHSrDHDPmrZPpGWgqmsIUM2lyIUFrQeloAoX0EbtKJW5XiCrxoTpLBibrxnPCMug6(WaKpa3OC69gFGzP7CAFk3gGSbezaYhWddqddXPLEpeNUWNKbGbZaEyanO3vvUfPRpXYw3lTev(oazdadMbiFaFOsnGidyxVc9fHpwLQbe2aWlMbidDnTxWeDpSBhirQqOQuihHtmiCrxt7fmr3DXKNRpXYg6YP9PCdjiYro6MqYXOiCr4Ghcx0Lt7t5gsq010Ebt0TYntsJUuoPKGr3gR0KsQxWeDXbsogDapk0nVGj6QjLZKYq3TiLUiSwOrE5LxhEaHna8gqKbiFapma3OC69n1o8stmLWoN2NYTbGbZaKpGg07Q6TOl4ETP2H7e(yvQgqydiWbezapmat7fm7vUzsA0LYjLeCxvVfDjLAAUnazdqgYr4elcx010Ebt09lsLyXrZjM2lyIUCAFk3qcICeobIWfD50(uUHeeD1KYzszOR8biFaFX9UFy3oqIuHqvP6IshqKb4gLtVVjM2fjCNt7t52aImafuKU2e79WPRgquyhqGdq2aWGzakOiDTj27HtxnGOWoGhpazORP9cMORsArkF9HNpYr48yeUOlN2NYnKGORMuotkdDDlLOY3bezaYhGP9keV4KpfRgqudaVbGbZaCJYP3B8bMLUZP9PCBaYqxt7fmr3ntxnoKPCZlyICeoXGWfD50(uUHeeD1KYzszOR8biFaUr507kPfP81hE(DoTpLBdiYauqr6AtS3dNUAayhGKdq2aWGzapma3OC6DL0Iu(6dp)oN2NYTbiBargG8biFaUr507BIPDrc350(uUnGidylsEoGOWoGyIzaYgagmdq(aEyaUr507BIPDrc350(uUnGidylsEoGOWoGhrYbiBayWmanesBq8Z(MPRghYuU5fm7e(yvQgqudWnYl7DVo8YHRwXdadMbiFaFX9UFy3oqIuHqvP6IshqKbiFaYhGBuo9(MyAxKWDoTpLBdiYa2IKNdikSdiWygGSbGbZaKpGhgGBuo9(MyAxKWDoTpLBdiYa2IKNdikSdigjhGSbiBaYgGm010Ebt0vbfPlnLTqmYr4iqq4IUCAFk3qcIUAs5mPm0v(aKpGqgPSpL7FILT1xSOTbezaAiK2G4N9DXKNRpXYwNWhRs1aIAa4j5aKnamygWddiKrk7t5(NyzB9flABaYgqKbSfjphqyyhqqjj6AAVGj6wNdKAEbZLjsmKJW5rq4IUCAFk3qcIUAs5mPm0DlsEoGWWoabIKORP9cMO7MPFQ1yKJWrGIWfD50(uUHeeD1KYzszO7wK8CaHnGaLCayWma5dq(aCJYP3vsls5Rp887CAFk3gqKbOGI01MyVhoD1acd7acCaYgagmdq(aEyaUr507kPfP81hE(DoTpLBdiYaKpa5d4lU39d72bsKkeQkvxu6aImGTi55acd7aIjMbiBayWma5d4lU39d72bsKkeQkvVbXphqKbSfjphqyyhWJi5aKnazdq2aKHUM2lyIUBIPDrcJCeobfcx0Lt7t5gsq0vtkNjLHUpma5dqddXPLExINKYYbezaeXK3qYl3jwqY0scHQvJ3fLpC6DoTpLBdqg6AAVGj6QQ3IUG71MAhg5iCWtseUORP9cMORsiBe0Lt7t5gsqKJWbp8q4IUM2lyIUUqce)1l1Qqm6YP9PCdjiYroYrxt0fcjO7TobTih5ie]] )


end
