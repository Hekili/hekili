-- MageArcane.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 62 )

    spec:RegisterResource( Enum.PowerType.ArcaneCharges, {
        arcane_orb = {
            aura = "arcane_orb",

            last = function ()
                local app = state.buff.arcane_orb.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.5,
            value = function () return state.active_enemies end,
        },
    } )

    spec:RegisterResource( Enum.PowerType.Mana, {
        evocation = {
            aura = "evocation",

            last = function ()
                local app = state.buff.evocation.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.1,
            value = function () return state.mana.regen * 0.1 end,
        }
    } )
    
    -- Talents
    spec:RegisterTalents( {
        amplification = 22458, -- 236628
        rule_of_threes = 22461, -- 264354
        arcane_familiar = 22464, -- 205022

        mana_shield = 23072, -- 235463
        shimmer = 22443, -- 212653
        slipstream = 16025, -- 236457

        incanters_flow = 22444, -- 1463
        mirror_image = 22445, -- 55342
        rune_of_power = 22447, -- 116011

        resonance = 22453, -- 205028
        charged_up = 22467, -- 205032
        supernova = 22470, -- 157980

        chrono_shift = 22907, -- 235711
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        reverberate = 22455, -- 281482
        touch_of_the_magi = 22449, -- 210725
        nether_tempest = 22474, -- 114923

        overpowered = 21630, -- 155147
        time_anomaly = 21144, -- 210805
        arcane_orb = 21145, -- 153626
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3580, -- 208683
        relentless = 3579, -- 196029
        adaptation = 3578, -- 214027

        netherwind_armor = 3442, -- 198062
        torment_the_weak = 62, -- 198151
        arcane_empowerment = 61, -- 276741
        master_of_escape = 635, -- 210476
        temporal_shield = 3517, -- 198111
        dampened_magic = 3523, -- 236788
        rewind_time = 636, -- 213220
        kleptomania = 3529, -- 198100
        prismatic_cloak = 3531, -- 198064
        mass_invisibility = 637, -- 198158
    } )

    -- Auras
    spec:RegisterAuras( {
        arcane_charge = {
            duration = 3600,
            max_stack = 4,
            generate = function ()
                local ac = buff.arcane_charge

                if arcane_charges.current > 0 then
                    ac.count = arcane_charges.current
                    ac.applied = query_time
                    ac.expires = query_time + 3600
                    ac.caster = "player"
                    return
                end

                ac.count = 0
                ac.applied = 0
                ac.expires = 0
                ac.caster = "nobody"
            end,
            --[[ meta = {
                stack = function ()
                    return arcane_charges.current
                end,
            } ]]
        },
        arcane_familiar = {
            id = 210126,
            duration = 3600,
            max_stack = 1,
        },
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        arcane_orb = {
            duration = 2.5,
            max_stack = 1,
            --[[ generate = function ()
                local last = action.arcane_orb.lastCast
                local ao = buff.arcane_orb

                if query_time - last < 2.5 then
                    ao.count = 1
                    ao.applied = last
                    ao.expires = last + 2.5
                    ao.caster = "player"
                    return
                end

                ao.count = 0
                ao.applied = 0
                ao.expires = 0
                ao.caster = "nobody"
            end, ]]
        },
        arcane_power = {
            id = 12042,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        blink = {
            id = 1953,
        },
        charged_up = {
            id = 205032,
        },
        chrono_shift_buff = {
            id = 236298,
            duration = 5,
            max_stack = 1,
        },
        chrono_shift = {
            id = 236299,
            duration = 5,
            max_stack = 1,
        },
        clearcasting = {
            id = 79684,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        displacement = {
            id = 212801,
        },
        displacement_beacon = {
            id = 212799,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        evocation = {
            id = 12051,
            duration = 1,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        greater_invisibility = {
            id = 113862,
            duration = 3,
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        mirror_image = {
            id = 55342,
            duration = 40,
            max_stack = 3,
            generate = function ()
                local mi = buff.mirror_image

                if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                    mi.count = 1
                    mi.applied = action.mirror_image.lastCast
                    mi.expires = mi.applied + 40
                    mi.caster = "player"
                    return
                end

                mi.count = 0
                mi.applied = 0
                mi.expires = 0
                mi.caster = "nobody"
            end,
        },
        nether_tempest = {
            id = 114923,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        presence_of_mind = {
            id = 205025,
            duration = 3600,
            max_stack = 2,
        },
        prismatic_barrier = {
            id = 235450,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        ring_of_frost = {
            id = 82691,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        rule_of_threes = {
            id = 264774,
            duration = 15,
            max_stack = 1,
        },
        rune_of_power = {
            id = 116014,
            duration = 3600,
            max_stack = 1,
        },
        shimmer = {
            id = 212653,
        },
        slow = {
            id = 31589,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        slow_fall = {
            id = 130,
            duration = 30,
            max_stack = 1,
        },
        touch_of_the_magi = {
            id = 210824,
            duration = 8,
            max_stack = 1,
        },

        -- Azerite Powers.
    } )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else applyBuff( "arcane_charge", nil, arcane_charges.current ) end
        end
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else applyBuff( "arcane_charge", nil, arcane_charges.current ) end
        end
    end )


    spec:RegisterStateTable( "burn_info", setmetatable( {
        __start = 0,
        start = 0,
        __average = 0,
        average = 0,
        n = 0,
        __n = 0,
    }, {
        __index = function( t, k )
            if k == "active" then
                return t.start > 0
            end
        end,
    } ) )

    spec:RegisterHook( "reset_precast", function ()
        burn_info.start = burn_info.__start
        burn_info.average = burn_info.__average
        burn_info.n = burn_info.__n
    end )

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        state.burn_info.__start = 0
        state.burn_info.__average = 0
        state.burn_info.__n = 0
    end )

    spec:RegisterEvent( "PLAYER_REGEN_DISABLED", function ()
        state.burn_info.__start = 0
        state.burn_info.__average = 0
        state.burn_info.__n = 0
    end )


    spec:RegisterStateFunction( "start_burn_phase", function ()
        burn_info.start = query_time
    end )

    spec:RegisterStateFunction( "stop_burn_phase", function ()
        if burn_info.start > 0 then
            burn_info.average = burn_info.average * burn_info.n
            burn_info.average = burn_info.average + ( query_time - burn_info.start )
            burn_info.n = burn_info.n + 1

            burn_info.average = burn_info.average / burn_info.n
            burn_info.start = 0
        end
    end )


    spec:RegisterStateExpr( "burn_phase", function ()
        return burn_info.start > 0
    end )

    spec:RegisterStateExpr( "average_burn_length", function ()
        return burn_info.average
    end )


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 12042 then
                burn_info.__start = GetTime()
            elseif spellID == 12051 and burn_info.start > 0 then
                burn_info.__average = burn_info.__average * burn_info.__n
                burn_info.__average = burn_info.__average + ( query_time - burn_info.__start )
                burn_info.__n = burn_info.__n + 1
    
                burn_info.__average = burn_info.__average / burn_info.__n
                burn_info.__start = 0
            end
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        arcane_barrage = {
            id = 44425,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236205,

            -- velocity = 24, -- ignore this, bc charges are consumed on cast.
            
            handler = function ()
                spend( arcane_charges.current, "arcane_charges" )
                if talent.chrono_shift.enabled then
                    applyBuff( "chrono_shift_buff" )
                    applyDebuff( "target", "chrono_shift" )
                end
            end,
        },
        

        arcane_blast = {
            id = 30451,
            cast = function () 
                if buff.presence_of_mind.up then return 0 end
                return 2.25 * ( 1 - ( 0.08 * arcane_charges.current ) ) * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 0.0275 * ( 1 + arcane_charges.current ) * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135735,
            
            handler = function ()
                if buff.presence_of_mind.up then
                    removeStack( "presence_of_mind" )
                    if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
                end
                if arcane_charges.current < arcane_charges.max then gain( 1, "arcane_charges" ) end
                if talent.rule_of_threes.enabled and  arcane_charges.current == 3 then applyBuff( "rule_of_threes" ) end
            end,
        },
        

        arcane_explosion = {
            id = 1449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.clearcasting.up and 0 or 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136116,
            
            usable = function () return target.distance < 10 end,
            handler = function ()
                removeBuff( "clearcasting" )
                gain( 1, "arcane_charges" )
            end,
        },
        

        summon_arcane_familiar = {
            id = 205022,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
           
            startsCombat = false,
            texture = 1041232,
            
            nobuff = "arcane_familiar",
            essential = true,

            handler = function ()
                if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
                applyBuff( "arcane_familiar" )
            end,

            copy = "arcane_familiar"
        },
        

        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,
            
            startsCombat = false,
            texture = 135932,
           
            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },
        

        arcane_missiles = {
            id = 5143,
            cast = function () return ( buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.clearcasting.up and 0 or 0.15 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136096,
            
            handler = function ()
                removeBuff( "clearcasting" )
            end,
        },
        

        arcane_orb = {
            id = 153626,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 1033906,

            talent = "arcane_orb",
            
            handler = function ()
                gain( 1, "arcane_charges" )
                applyBuff( "arcane_orb" )
            end,
        },
        

        arcane_power = {
            id = 12042,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136048,
            
            handler = function ()
                applyBuff( "arcane_power" )
                start_burn_phase()
            end,
        },
        

        blink = {
            id = 1953,
            cast = 0,
            charges = 1,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",
            
            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135736,

            notalent = "shimmer",
            
            handler = function ()
                if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            end,
        },
        

        charged_up = {
            id = 205032,
            cast = 0,
            cooldown = 40,
            gcd = "spell",
            
            startsCombat = true,
            texture = 839979,
            
            handler = function ()
                gain( 4, "arcane_charges" )
            end,
        },
        

        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 134029,
            
            handler = function ()
            end,
        }, ]]
        

        counterspell = {
            id = 2139,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",
            
            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135856,

            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        displacement = {
            id = 195676,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132171,
            
            buff = "displacement_beacon",

            handler = function ()
                removeBuff( "displacement_beacon" )
            end,
        },
        

        evocation = {
            id = 12051,
            cast = 6,
            charges = 1,
            cooldown = 90,
            recharge = 90,
            gcd = "spell",

            channeled = true,
            fixedCast = true,

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136075,
            
            handler = function ()
                stop_burn_phase()
                applyBuff( "evocation" )
            end,
        },
        

        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",
            
            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135848,
            
            handler = function ()
                applyDebuff( "target", "frost_nova" )
            end,
        },
        

        greater_invisibility = {
            id = 110959,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 575584,
            
            handler = function ()
                applyBuff( "greater_invisibility" )
            end,
        },
        

        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = 240,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 135841,
            
            handler = function ()
                applyBuff( "ice_block" )
                applyDebuff( "player", "hypothermia" )
            end,
        },
        

        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            talent = "mirror_image",
            
            handler = function ()
                applyBuff( "mirror_image" )
            end,
        },
        

        nether_tempest = {
            id = 114923,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 610471,
            
            handler = function ()
                applyDebuff( "target", "nether_tempest" )
            end,
        },
        

        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136071,
            
            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },
        

        presence_of_mind = {
            id = 205025,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 136031,

            nobuff = "presence_of_mind",
            
            handler = function ()
                applyBuff( "presence_of_mind", nil, 2 )
            end,
        },
        

        prismatic_barrier = {
            id = 235450,
            cast = 0,
            cooldown = function () return talent.mana_shield.enabled and 0 or 25 end    ,
            gcd = "spell",
            
            defensive = true,

            spend = function() return 0.03 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135991,
            
            handler = function ()
                applyBuff( "prismatic_barrier" )
            end,
        },
        

        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136082,
            
            handler = function ()
            end,
        },
        

        ring_of_frost = {
            id = 113724,
            cast = 2,
            cooldown = 45,
            gcd = "spell",
            
            spend = function () return 0.08 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 464484,

            talent = "ring_of_frost",
            
            handler = function ()                
            end,
        },
        

        rune_of_power = {
            id = 116011,
            cast = 1.5,
            charges = 2,
            cooldown = 40,
            recharge = 40,
            gcd = "spell",
            
            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",
            
            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },
        

        shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "off",
            
            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135739,

            talent = "shimmer",
            
            handler = function ()
                -- applies shimmer (212653)
            end,
        },
        

        slow = {
            id = 31589,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136091,
            
            handler = function ()
                applyDebuff( "target", "slow" )
            end,
        },
        

        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135992,
            
            handler = function ()
                applyBuff( "slow_fall" )
            end,
        },
        

        spellsteal = {
            id = 30449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135729,
            
            usable = function () return debuff.stealable_magic.up end,
            handler = function ()
                removeDebuff( "target", "stealable_magic" )
            end,
        },
        

        supernova = {
            id = 157980,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1033912,

            talent = "supernova",
            
            handler = function ()
            end,
        },
        

        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",
            
            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,
            
            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = false,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = nil,
    } )


    spec:RegisterPack( "Arcane", 20180813.1355, [[d0Ko0aqicOEebKlraq2eq8jkqgfrXPikTkcGWRiQmlIKBrKsTlr(frvdtuXXOGwMOspJivtJcuxJcX2ia13Oa04isHZrb06iajZtfv3JI2NkkhKcLfsq9qcamrcGIlsbWgjaI(ibqYijaQojrkzLQiVKaGAMeaLUjbqQDsqgkrkQLsacpfWubsxLae9vIue7fL)QWGv6WilwrpwvtMsDzOntsFwfgTOCAuTAca9Ac0SvPBtIDt1VbnCk54eGulx45KA6sDDcTDG67eX4Pq68uOA9ePinFrv7xYmdzGYaSPgzcLBogknYrAyO0tgkDJyednGmG24widWIEbPdKb4KcYamw8KJmalY4xizZaLbOHIXJmagWuKFBPLZMmaBQrMq5MJHsJCKggk9KH5AebSH5Ya0w4ZesaNldWg1pda0mUUwUUwQwl6fKoWAHQ1sFZHETxUU11QcJAfGJcYV8uDQobAgwl9nh61E56U2msx7erVwfOnxLJ212WA1IwwWORTZWANIHxRvgPXA1nfn3pQvcVZQ1yXtowR0mucg1sUDTOBZ9JALW7SAnaGHp1CONyaxUU1mqzap01yagzGYeYqgOma6Bo0zak8iGXGRqhidaDAErBMWSMjuUmqzaOtZlAZeMb8bVXGtmGPOQAIINCC8zuCGjDtVG1AwBoma6Bo0zaFgfhO9q0I1mHKoduga608I2mHzaFWBm4edqJ9ycDrDQ5yKBoJCT(AbP2POQAIINCC8zuCGjDtVG1AwBoma6Bo0zawbQr)XbuDOWDBwZeYGzGYaqNMx0Mjmd4dEJbNyaYuBGQbQZO5fRnF(Af4AB(li3pQv2AbP2POQAIINCC8zuCGjDtVG1Aw7uuvnrXtoo(mkoWKcz0HUPxWAbP2POQAkeDCavhwqjyKSHs8AbP2POQAIINCCybLGrYgkXza03COZaCSZWy0OIfQBwZeYimqzaOtZlAZeMb8bVXGtmGPOQAIINCC8zuCGjDtVG1EUzT5wli1ktTpeETHs8efp54WckbJuGke311EwTgMtT5Zxl9nhmoqhv4OU2ZnRn3ALLbqFZHodGINCCaJjRzcjGzGYaqNMx0Mjmd4dEJbNyatrv1uiEXbuD0zbI6KOvTGu7uuvnrXtoo(mkoWKUPxWApZSwPZaOV5qNbqXtooMxs3SMjKbKbkdaDAErBMWmGp4ngCIbmfvvtu8KJJpJIdmPB6fSwZANIQQjkEYXXNrXbMuiJo0n9cwli1ktTQI37iWpJIdC0CfS2ZnRfnk(InoAUcwB(81g4NrXboAUcw75M1(q41gkXtu8KJdlOemsbQqCxxB(812uCGDQ5k4OHdBow75M1(q41gkXtu8KJdlOemsbQqCxxRSma6Bo0zaHOJdO6WckbdwZesAWaLbGonVOntygWh8gdoXauiNswFx75M1AGgPwqQDkQQM(lsXt6M7hPaPVRfKAbtbNMxmzfOwlg4iGn1COxRzT5WaOV5qNbqXtoou4An)IAgWNrCNbyiRzczGmqzaOtZlAZeMb8bVXGtmazQvMANIQQjkEYXXNrXbM0n9cwRzTtrv1efp544ZO4atkKrh6MEbRv2AbPwzQvHCkz9DTNBwlyk408IPh6AmaJdfYPAZNVwWuWP5ftwbQ1Ibocytnh61kBT5ZxRm120f9orXtooGXmHonVODTGu7dHxBOeprXtooGXmfOcXDDTNBw7XBxli1(q41gkXtu8KJdlOemsbQqCxx7z1Ayo1kBTYwB(81QqoLS(U2ZnRvMAbtbNMxm9qxJbyCOqovR0UwdZPwzza03COZaO4jhhtkc6azntidZHbkdaDAErBMWmGp4ngCIbOqoLS(U2ZnR1ancdG(MdDgGw0cdhcMyntidnKbkdaDAErBMWmGp4ngCIbqFZbJd0rfoQR9mZALETGuRm1QqoLS(U2ZmRfmfCAEX0dDngGXHc5uT5Zx7uuvnrXtoo(mkoWKUPxWAnRv61kldG(MdDgafp54anQ1fQ5qN1mHmmxgOma6Bo0zau8KJJ5L0ndaDAErBMWSMjKHsNbkdG(MdDgafp54ysrqhidaDAErBMWSM1maBuLeVnduMqgYaLbqFZHod4HIEJH2cVxga608I2mHzntOCzGYaqNMx0Mjmd4dEJbNyanxbR1S2CQfKANIQQP5fcTVI6ozdL4ma6Bo0zanxbhsOWI1mHKoduga608I2mHzaqlgGgBga9nh6maWuWP5fzaGPRiYaKPwsAkg8gtu8KJdRa1AXatb5cw7zM1MBT5ZxRm120f9ofOg6K)ycDAEr7AbPw6BoyCGoQWrDTNzwBU1kBTYwli12uCGDkdPBNLS(U2ZnRv6gHbaMIHtkidWkqTwmWraBQ5qN1mHmygOma0P5fTzcZa(G3yWjgWum8HvgPXAZNV2MIdStnxbhnCyZXApVwcmg0boMIHpUOF0z1MpFTYu7dHxBOeprXtooSGsWifOcXDDTM1MtTGu7dHxBOepHGHp1CONcuH4UU2ZnRLaJbDGJPy4Jl6hDwTGuRm1ofvvtu8KJJpJIdmPB6fSwZANIQQjkEYXXNrXbMuiJo0n9cwB(81ktTnDrVtFgfhO9q0kHonVODTGu7dHxBOep9zuCG2drRuGke311AwBo1kBTYwRSma6Bo0zapDVd6Bo0hxUUzaxUUhoPGmGPy4SMjKryGYaqNMx0Mjmd4dEJbNyacCTtXWhwzKgza03COZaE6Eh03COpUCDZaUCDpCsbzap01yagzntibmduga608I2mHza03COZaE6Eh03COpUCDZaUCDpCsbzakqWOc6nRzndWkWhQmPMbktidzGYaqNMx0MjmRzcLlduga608I2mHzntiPZaLbGonVOntywZeYGzGYaOV5qNbqXtoo4EJ3l(ndaDAErBMWSMjKryGYaOV5qNbOfvuG(GINCCOsk8lNcga608I2mHzntibmduga608I2mHzaqlgGgBga9nh6maWuWP5fzaGPRiYaKUryaFWBm4edOPl6DccgdlOemq7e608I2maWumCsbzap01yaghkKtSMjKbKbkdaDAErBMWmaOfdqJndG(MdDgayk408ImaW0vezagSryaFWBm4edqGRTPl6DccgdlOemq7e608I2maWumCsbzap01yaghkKtSMjK0GbkdaDAErBMWSMjKbYaLbqFZHodqHhbmgCf6azaOtZlAZeM1mHmmhgOma6Bo0zawWMdDga608I2mHzntidnKbkdG(MdDgafp54yEjDZaqNMx0MjmRzndykgoduMqgYaLbGonVOntyga0Ibq22ma6Bo0zaGPGtZlYaatxrKbyid4dEJbNyacCTtXWhwzKgzaGPy4KcYaAyt3XumCnRzcLlduga608I2Sjd4dEJbNyacCTtXWhwzKgza03COZa0nf9ykg(WkJ0iRzcjDgOma0P5fTzcZaOV5qNbOWJagdUcDGmGp4ngCIbqFZHEIINCCybLGrkqY24SMjKbZaLbGonVOntygWh8gdoXaOV5qprXtooSGsWifizB8AbP2POQAIINCC8zuCGjDtVG1EUzTgwli1ktTcCTAShtOlQtnhJCZzKR1xB(81(q41gkXtwbQr)XbuDOWD7uGke311EwTgPwzza03COZa(mkoq7HOfRzczegOma0P5fTzcZa(G3yWjga9nh6jkEYXHfucgPajBJxli1ktTbQgOoJMxS285RvGRT5VGC)OwzRfKANIQQjkEYXXNrXbM0n9cwRzTtrv1efp544ZO4atkKrh6MEbRfKANIQQPq0XbuDybLGrYgkXRfKANIQQjkEYXHfucgjBOeNbqFZHodWXodJrJkwOUzntibmduga608I2mHzaFWBm4edG(Md9efp54WckbJuGKTXRfKANIQQjkEYXHfucgjBOeNbqFZHod4YpYA9qau0(qb9M1mHmGmqzaOtZlAZeMb8bVXGtma6Bo0tu8KJdlOemsbs2gVwqQvGRDkQQMO4jhhwqjyKeTQfKALPwfYPK131EMzTgjNAZNV2hcV2qjEIINCCybLGrkqfI76AnRnNALTwqQvMANIQQjkEYXXNrXbM0n9cwRzTtrv1efp544ZO4atkKrh6MEbRvwga9nh6mGq0XbuDybLGbRzcjnyGYaOV5qNbqXtooSGsWGbGonVOntywZeYazGYaqNMx0Mjmd4dEJbNyatrv1efp54WckbJKOvT5ZxBtXb2PMRGJgoS5yTNx7dHxBOeprXtooSGsWifOcXDndG(MdDgGOgh8gv0SMjKH5WaLbqFZHodyEHq7HQyyCga608I2mHzntidnKbkdG(MdDgWedngcY9dga608I2mHzntidZLbkdG(MdDgGkpW5fcTzaOtZlAZeM1mHmu6mqza03COZai)rDh0D809YaqNMx0MjmRzczObZaLbqFZHodWkqn6poGQdfUBZaqNMx0MjmRzczOryGYaqNMx0Mjmd4dEJbNyatrv1efp544ZO4at6MEbR1S2CQnF(ALPw6BoyCGoQWrDTNxR0RnF(ALPw6BoyCGoQWrDTNxBU1csTnDrVtbQHo5pMqNMx0UwzRvwga9nh6makEYXbmMSMjKHcygOma0P5fTzcZa(G3yWjgGm1sFZbJd0rfoQR9mZALET5ZxRm1sFZbJd0rfoQR9mZAZTwqQTPl6Dkqn0j)Xe608I21kBTYwli1ktTtrv1efp544ZO4at6MEbR1S2POQAIINCC8zuCGjfYOdDtVG1kldG(MdDgafp54ysrqhiRzczObKbkdaDAErBMWmGp4ngCIbqFZbJd0rfoQR9mZALET5ZxRm1sFZbJd0rfoQR9mZAZTwqQTPl6Dkqn0j)Xe608I21kldG(MdDgafp54anQ1fQ5qN1mHmuAWaLbGonVOntygWh8gdoXaatbNMxmzfOwlg4iGn1COxli1ofvvtu8KJJpJIdmPB6fSwZANIQQjkEYXXNrXbMuiJo0n9cYaOV5qNbqXtooMue0bYAMqgAGmqzaOtZlAZeMb8bVXGtmazQDkQQM(lsXt6M7hPaPVRfKAviNswFx75M1AGgPwzRfKAbtbNMxmzfOwlg4iGn1COxRzT5WaOV5qNbqXtoou4An)IAgWNrCNbyiRzcLBomqza03COZaO4jhhZlPBga608I2mHzntOCnKbkdG7ngHOvp4QmafYPK13NzAGgW85LzkQQM(lsXt6M7hPaPVbrHCkz99zMgyUYYaOV5qNbGGHp1COZaqNMx0MjmRzcLBUmqza03COZaO4jhhtkc6azaOtZlAZeM1SMbOabJkO3mqzcziduga608I2mHzaFWBm4edqbcgvqVt2CDt(J1EMzTgMddG(MdDgGoJROGbRzcLlduga608I2mHzaFWBm4edqbcgvqVt2CDt(J1EMzTgMddG(MdDgW8YDbzntiPZaLbqFZHodWkqn6poGQdfUBZaqNMx0MjmRzczWmqza03COZaO4jhhkCTMFrndaDAErBMWSMjKryGYaOV5qNbqXtooGXKbGonVOntywZesaZaLbqFZHodqlAHHdbtma0P5fTzcZAwZAgGekCUFOzastmMacHKwcjaLaQARf0mSwUIfm6AvHrTg0umCdQ2afqlYd0UwnubRLeBOc1ODTFg5hOovNeGL7yT5kGQwbKUw0YcgnAxl9nh61Aq6MIEmfdFyLrA0Gs1P6K0sXcgnAxRrQL(Md9AVCDRt1jgGvav5xKbiq1Aamk(InAx7evHbw7dvMux7ep4UovRX(hTADTo0L2zuOOkERL(MdDDTq)A8uDI(MdDDYkWhQmP2u9sAbRt03CORtwb(qLj1YzkVkeAxNOV5qxNSc8HktQLZuEs8qb9MAo0Rt03CORtwb(qLj1Yzkpfp54G7nEV431j6Bo01jRaFOYKA5mLxlQOa9bfp54qLu4xof1jbQ2h6AmaJdfYPA56A7mSwfYPATW4rVPdSwjyTsiVRTH1EaR1gkXRTH1AlgC)O2h6AmaJPALwDToI26AByTxKaJ1Iou8iR2acvQTH1kbg6U2N0yT6hDk4WA1wKsTgt4AH(141AlgC)OwJjnNQt03CORtwb(qLj1Yzkpyk408Is5KcA(qxJbyCOqojf0YuJTuGPRiAkDJifx1SPl6DccgdlOemq7e608I21j6Bo01jRaFOYKA5mLhmfCAErPCsbnFORXamouiNKcAzQXwkW0vennyJifx1uGB6IENGGXWckbd0oHonVODDI(MdDDYkWhQmPwot51ozPZG9q3uRRt03CORtwb(qLj1YzkVcpcym4k0bwNOV5qxNSc8HktQLZuElyZHEDI(MdDDYkWhQmPwot5P4jhhZlP76uDsGQ1ayu8fB0UwemggV2MRG12zyT03WOwUUwcmXV08IP6KavR0YBmcrRU2odRDc16ALKHETwqTMpVyQorFZHU28HIEJH2cV36e9nh6A5mLV5k4qcfwsXvnBUcAMditrv108cH2xrDNSHs86KavlGeYQ2gwBNH1AqglEYXALMduRfd0GQnGn1COxRKm0Rvcw7bSRfDO4rwTDq8wxRkmQL3PAbnJRRLRyD5OUwDlQQw7LliwRdR9c9dmQ9jDZ9JAnw8KJ1kanxR5xulvTKBxBNfqjC)OwOyxRXINCSwHPiOdSwjzOJGXOwjyThWUwdUwJjaivNOV5qxlNP8GPGtZlkLtkOPvGATyGJa2uZHUuqltn2sbMUIOPmK0um4nMO4jhhwbQ1IbMcYf8mZCZNxMMUO3Pa1qN8htOtZlAdc9nhmoqhv4O(mZCLvwqAkoWoLH0TZswFFUP0nsDsGQfOPORLQDkgETwzKgRvsg61YvSGrtEx7dHxBOexxlfyTeyIFP5ft1c0u01kH3z1AW1sXtow7NrXbQLQwr)IADTDggObPRLQ9acTRnqsd9ADyxBdt1kZNrXbAxROLS1j6Bo01Yzk)t37G(Md9XLRBPCsbnNIHlfx1Ckg(WkJ0y(8nfhyNAUcoA4WMJNtGXGoWXum8Xf9JolFEzEi8AdL4jkEYXHfucgPaviURnZbKhcV2qjEcbdFQ5qpfOcXD95MeymOdCmfdFCr)OZarMPOQAIINCC8zuCGjDtVGMtrv1efp544ZO4atkKrh6MEbZNxMMUO3PpJId0EiALqNMx0gKhcV2qjE6ZO4aThIwPaviURnZrwzLTorFZHUwot5F6Eh03COpUCDlLtkO5dDngGrP4QMc8um8HvgPX6e9nh6A5mL)P7DqFZH(4Y1TuoPGMkqWOc6DDQojq1kT8pqf07AHIrTtXWR1kJ0yTpu0Bms1knjdDemg1kbRf9gJA7mS2Dkg(wl9nh66ALW7mOyx7e5(rTCVwQ2Py41ALrAuQA5DTki56A7mQRvcwlfyT0ek212WA1nfDTqht1j6Bo01PPy4MGPGtZlkLtkOzdB6oMIHRLcAzs22sbMUIOPHsXvnf4Py4dRmsJ1j6Bo01PPy4YzkVUPOhtXWhwzKgLIRAkWtXWhwzKgRtcuTga3U2odRDkgETwzKgRvsg61kbRvauu31IGHp1ODQojq1sFZHUonfdxot51n0AmfdFyLrAukUQ5um8HvgPrqSce844TtgMqWWNAo0bPP4a7uZvWrdh2C8mWuWP5fteymOdCmfdFCr)OZazkg(WkJ04WwmOMd9ZYPorFZHUonfdxot5v4raJbxHoW6e9nh660umC5mL)ZO4aThIwsXvnNIQQjkEYXXNrXbM0n9cEUPHGiJaRXEmHUOo1CmYnNrUwF(8peETHs8KvGA0FCavhkC3ofOcXD9zgr26e9nh660umC5mL3XodJrJkwOULIRAktGQbQZO5fZNxGB(li3pKfKPOQAIINCC8zuCGjDtVGMtrv1efp544ZO4atkKrh6MEbbzkQQMcrhhq1HfucgjBOehKPOQAIINCCybLGrYgkXRt03CORttXWLZu(l)iR1dbqr7df0BP4QMtrv1efp54WckbJKnuIxNOV5qxNMIHlNP8HOJdO6WckbdP4QMc8uuvnrXtooSGsWijAbImkKtjRVpZ0i5Kp)dHxBOeprXtooSGsWifOcXDTzoYcImtrv1efp544ZO4at6MEbnNIQQjkEYXXNrXbMuiJo0n9ckBDI(MdDDAkgUCMYtXtooSGsWOorFZHUonfdxot5f14G3OIwkUQ5uuvnrXtooSGsWijALpFtXb2PMRGJgoS545peETHs8efp54WckbJuGke311j6Bo01PPy4Yzk)8cH2dvXW41j6Bo01PPy4Yzk)edngcY9J6e9nh660umC5mLxLh48cH21j6Bo01PPy4Yzkp5pQ7GUJNU36e9nh660umC5mL3kqn6poGQdfUBxNOV5qxNMIHlNP8u8KJdymLIRAofvvtu8KJJpJIdmPB6f0mN85LH(MdghOJkCuFU0ZNxg6BoyCGoQWr955cstx07uGAOt(Jj0P5fTLv26e9nh660umC5mLNINCCmPiOdukUQPm03CW4aDuHJ6ZmLE(8YqFZbJd0rfoQpZmxqA6IENcudDYFmHonVOTSYcImtrv1efp544ZO4at6MEbnNIQQjkEYXXNrXbMuiJo0n9ckBDI(MdDDAkgUCMYtXtooqJADHAo0LIRAsFZbJd0rfoQpZu65Zld9nhmoqhv4O(mZCbPPl6Dkqn0j)Xe608I2YwNOV5qxNMIHlNP8u8KJJjfbDGsXvnbtbNMxmzfOwlg4iGn1COdYuuvnrXtoo(mkoWKUPxqZPOQAIINCC8zuCGjfYOdDtVG1j6Bo01PPy4Yzkpfp54qHR18lQLIRAkZuuvn9xKIN0n3psbsFdIc5uY67ZnnqJiliGPGtZlMScuRfdCeWMAo0nZrQpJ4UPH1j6Bo01PPy4Yzkpfp54yEjDxNeOAfckP2oJ6ALGguG1AdDS2Py4C)qQALG1(KxROLn1yTDgwlbgd6ahtXWhx0p6SALW7SA7mS2l6hDwTq1A7mUU2Py4P6Kavl9nh660umC5mLhmfCAErPCsbnjWyqh4ykg(4I(rNjf0YuJTuGPRiAkdyk408Ijcmg0boMIHpUOF0zcqaMconVyQHnDhtXW1sBWuWP5fteymOdCmfdFCr)OZKtMPy4dRmsJdBXGAo0LvwbGatbNMxm1WMUJPy466e9nh660umC5mLhbdFQ5qxkU3yeIw9GRAQqoLS((mtd0aMpVmtrv10FrkEs3C)ifi9nikKtjRVpZ0aZv26KavRaKWO2odRnOaRf(pP5qVwjzyG1kbR9awleQu7evHbwlcg(uZHETCDTt6fSwrRuTYiGuls3RXRDIpjQXALG1EGDTGXW41oj7Ad)OwnS2odRDkgETCDTVyxlymmET6my0YwNOV5qxNMIHlNP8u8KJJjfbDG1P6e9nh660dDngGrtfEeWyWvOdSorFZHUo9qxJbyuot5)mkoq7HOLuCvZPOQAIINCC8zuCGjDtVGM5uNOV5qxNEORXamkNP8wbQr)XbuDOWDBP4QMAShtOlQtnhJCZzKR1dYuuvnrXtoo(mkoWKUPxqZCQt03CORtp01yagLZuEh7mmgnQyH6wkUQPmbQgOoJMxmFEbU5VGC)qwqMIQQjkEYXXNrXbM0n9cAofvvtu8KJJpJIdmPqgDOB6feKPOQAkeDCavhwqjyKSHsCqMIQQjkEYXHfucgjBOeVorFZHUo9qxJbyuot5P4jhhWykfx1CkQQMO4jhhFgfhys30l45M5cImpeETHs8efp54WckbJuGke31Nzyo5ZtFZbJd0rfoQp3mxzRtcuTglEYXAf(s6UwDgxT11kAvl3R1k4WG3gVwjzOxBi6o3pQneVyTq1A7SarDQorFZHUo9qxJbyuot5P4jhhZlPBP4QMtrv1uiEXbuD0zbI6KOfitrv1efp544ZO4at6MEbpZu61j6Bo01Ph6AmaJYzkFi64aQoSGsWqkUQ5uuvnrXtoo(mkoWKUPxqZPOQAIINCC8zuCGjfYOdDtVGGiJQ49oc8ZO4ahnxbp3enk(InoAUcMpFGFgfh4O5k45MpeETHs8efp54WckbJuGke315Z3uCGDQ5k4OHdBoEU5dHxBOeprXtooSGsWifOcXDTS1j6Bo01Ph6AmaJYzkpfp54qHR18lQLIRAQqoLS((Ctd0iGmfvvt)fP4jDZ9JuG03GaMconVyYkqTwmWraBQ5q3mhP(mI7MgwNeOAfGrm4(rTp01yagLQwjyT6MFV1kakQ7ALqExBdR9HEZDrSwh21AhqllUFu7NrXbQRL01EH(rTKUwlOwZNxmbaRvqeTQ1GMIHZ9ddQwsx7f6h1s6ATGAnFEXALHeKQ9HUgdW4qHCQ2olqDwg8AlBTKBxBNHETAjKvTnSwQwd2O1AmHL2NzSjfrTp01yagRnGn1CONQf0mUUwUUwfYPADuSd6wRkmQvabeuPQvHCQwhpOMdgRvcVZQLINCSwvsHF5uKQvAPwReSwByToSRnJaJ1AW1AmbasvReS2N8AT5w1QV8JS(A8AVqjyuBdR9a7APAn4oRwJjaivNOV5qxNEORXamkNP8u8KJJjfbDGsXvnLrMPOQAIINCC8zuCGjDtVGMtrv1efp544ZO4atkKrh6MEbLfezuiNswFFUjyk408IPh6AmaJdfYP85btbNMxmzfOwlg4iGn1COlB(8Y00f9orXtooGXmHonVOnipeETHs8efp54agZuGke31NBE82G8q41gkXtu8KJdlOemsbQqCxFMH5iRS5ZRqoLS((CtzatbNMxm9qxJbyCOqojTnmhzRtcuTaIwy4qWuTCDTtkWRXRvcm6SAFs3C)qQALKX)SA56ALKz8A5DTCDTAyTQuuRnuIlvTq)A8Afaf1DT0ecgR1ycNQTorFZHUo9qxJbyuot51Iwy4qWKuCvtfYPK13NBAGgPojq1kamIw1AqtXW5(Hbvl3RLGyTAElsnh66Af9MFR9HUgdW4qHCQwRVt1Am1gJA7mQRf6xJx7t6UwJzaQvcVZQv61AS4jhR9ZO4a1svRM7pwlVniDT0vbQ7Arb0I0TwfYPAFOURTH1s1k9A1n9cwRXeUwYnUeY4PAnwxBNrDTwqU31AmObO2a2uZHETs43BTtSwJjCTgv61kTpRwJzaQvAFwTgBsruNOV5qxNEORXamkNP8u8KJd0OwxOMdDP4QM03CW4aDuHJ6ZmLoiYOqoLS((mtWuWP5ftp01yaghkKt5Zpfvvtu8KJJpJIdmPB6f0u6YwNOV5qxNEORXamkNP8u8KJJ5L0DDI(MdDD6HUgdWOCMYtXtooMue0bwNQt03CORtkqWOc6TPoJROGHuCvtfiyub9ozZ1n5pEMPH5uNOV5qxNuGGrf0B5mLFE5UGsXvnvGGrf07Knx3K)4zMgMtDI(MdDDsbcgvqVLZuERa1O)4aQou4UDDI(MdDDsbcgvqVLZuEkEYXHcxR5xuxNOV5qxNuGGrf0B5mLNINCCaJzDI(MdDDsbcgvqVLZuETOfgoemXaiXodgmab4OG8lN1SMXa]] )
    

end
