-- MageArcane.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 62, true )

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
            id = 263725,
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

        -- Azerite Powers
        brain_storm = PTR and {
            id = 273330,
            duration = 30,
            max_stack = 1,
        } or nil,

        equipoise = PTR and {
            id = 264352,
            duration = 3600,
            max_stack = 1,
        } or nil,
    } )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else applyBuff( "arcane_charge", nil, arcane_charges.current ) end
        
        elseif resource == "mana" then
            if azerite.equipoise.enabled and mana.percent < 70 then
                removeBuff( "equipoise" )
            end
        end
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else 
                applyBuff( "arcane_charge", nil, arcane_charges.current )
            end
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

        if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end
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
        return burn_info.average or 0
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
            
            spend = function () 
                if buff.rule_of_threes.up then return 0 end
                return 0.0275 * ( 1 + arcane_charges.current ) * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135735,
            
            handler = function ()
                if buff.presence_of_mind.up then
                    removeStack( "presence_of_mind" )
                    if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
                end
                if arcane_charges.current < arcane_charges.max then gain( 1, "arcane_charges" ) end
                removeBuff( "rule_of_threes" )
                if talent.rule_of_threes.enabled and arcane_charges.current == 2 then applyBuff( "rule_of_threes" ) end
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
            
            spend = function () 
                if buff.rule_of_threes.up then return 0 end
                return buff.clearcasting.up and 0 or 0.15 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136096,
            
            handler = function ()
                removeBuff( "rule_of_threes" )
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
                if azerite.brain_storm.enabled then applyBuff( "brain_storm" ) end
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
        
        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20180930.1656, [[d8Kg2aqiku6rOs1LijbAtKu(eLsPrrHCkkOvbbQEffyweOBHkr7sIFbHggLkhJsXYOuYZqLY0iPQUgeW2OqX3ijrnoku15OuQwhjvP3rsIyEuQ6EsQ9rsQdcbTqcYdjjjtKKeWfjPk2iLsH(iLsrJKKeKtIkHwPK4LKKqntssqDtssQDsq9tkLcgkfQSuuj4POQPssCviq6RqGyVe9xfnyPomYIvXJv1KPKld2mH(ScnAfCAuwneO8Acy2Q0TjXUP63qnCk64KKiTCrpNutxPRdPTJk(oenEujDEsQSEssiZxsA)clTrQIK3IwqkSTSZgJ3oBNB2vSXyqaJXoBxYVQZeK8M0lancsENuajpcZNCqYBsQ7IjlPksEngnFqYl5pOS7YfD5rYBrlif2w2zJXBNTZn7k2ymiGXyNXl51MWlf2ySLKFGzzbU8i5Ta9l55E0imFYHOv10iev4E0d7AQvViI4iBhqpLhRGOMPGEPLH9pjXfrnt5r8CXhepIexAbCq0mXISlOr04sGlqmlnIghxyQQPryIW8jhkAMYhv4E08G5ckhiJMB2jy02YoBm(O5YOTXyuVQVDrLOc3JgbbHCbH5IcBBQEJoAeMp5q0QAAeIMPJ2XB0iH7Ll1OMM4CblvjrpqU1L5JrFqtpAo6s0p21qYbIMPJM5p21m9c(wIkCpAeunenTrRomAgngPhDY0cuK8MjwKDbjp3JgH5toeTQMgHOc3JEyxtT6frehz7a6P8yfe1mf0lTmS)jjUiQzkpINl(G4rK4slGdIMjwKDbnIgxcCbIzPr044ctvnncteMp5qrZu(Oc3JMhmxq5az0CZobJ2w2zJXhnxgTngJ6v9TlQev4E0QQbYhbT6nQW9O5YO1lL78GM(0CG0GGrRxS58GM(0CG0GGrtUv0ehiPryEqtFEbFChIMsi6bYTUGv0h1f9oartwwyVevIkCpAeeeYfeMlkSTP6n6Ory(KdrRQPriAMoAhVrJeUxUuJAAIZfSuLe9a5wxMpg9bn9O5Olr)yxdjhiAMoAM)yxZ0l4BjQW9Orq1q00gT6WOz0yKE0jtlqjQev4E0QhUcp6cwrFarCcr)yLdTrFGrMRlrJW)bZvhTJDUCGsfr0B00VmSRJg7x1vIk0VmSRlMj8yLdT1IxslquH(LHDDXmHhRCO1GAefXyROc9ld76Izcpw5qRb1isOJkGV0YWEuH(LHDDXmHhRCO1GAeP8jhMmFH7f(nQq)YWUUyMWJvo0AqnIAuffSpP8jhMIKc7YOmQW9OFSRHKdmviNIMPJEhGOviNI2eYh8LgHOrcrJK8n6fh9ioAlmsp6fhTfAY8XOFSRHKduIMlUr7ayPJEXrFbIden4y0XHOtmwj6fhnsCQ3OFsdrRFWPKHJwBskrJqHIg7x1fTfAY8XOrOXvIk0VmSRlMj8yLdTguJihkz05cc6Kcu)yxdjhyQqoji2SwdRGCOlkuBm2fvOFzyxxmt4XkhAnOgrTtM6b8o1lT6Oc9ld76Izcpw5qRb1iQWYeNtMcncrf6xg21fZeESYHwdQr0eVmShvOFzyxxmt4XkhAnOgrkFYH55s6nQev4E0QhUcp6cwrdCGuDrVmfi6DaIM(fNrZ0rtCi2LoxOev4E0CrFHmrn3O3bi6dwRJg5a4rBI1A25cLOc9ld766hJ6lKAt4EJkCpABtC0loAHqtpAJBG0q0ihapA6MazPUOpOPZ8rbJgNrJCa8OpyToAKS7nAlgeTgJ9suH(LHDTb1i(09oPFzyFEz6vqNuG6dA6cYeRpOPpnhinuT6s5iSLLPaZfpTyG9ehiPryEqtFEbFChIkCpA(LYnAHqtpAJBG0q0ihapAeMp5q0ghgjKrZ0rNazPUOj3kA1dh8tld7rJKDVrFGOtGSux0gH9OjoqsJGHrFarCcrVdq0h00J2CG0q0mD0yoqwIgHxnoAfsaiAnAcrJeIEeVrR(rJW8jhIwvnq5iOfmACg9tE0JWgT6hncZNCiAv1aLJGoAKSDiAv1aLJGv0iOMLOc9ld7AdQr8P7Ds)YW(8Y0RGoPa1h00fKjwB0JXxlmsVq5tomnXiHSKGcXCDTDQ9y81cJ0lah8tld7LeuiMRTVM4ajncZdA6Zl4J7GAgDqfflu(KdZFGYrOOx6fO(GkkwO8jhM)aLJqrH46uV0lq1QgT0f8T8duocwtuZc405cwQ9y81cJ0l)aLJG1e1SKGcXCDTDgAOHrf6xg21guJ4t37K(LH95LPxbDsbQFSRHKdiitS2ypOPpnhinevOFzyxBqnIpDVt6xg2NxMEf0jfOwbZbuaFJkrfUhnx0)euaFJgJMrFqtpAZbsdr)yuFHSencYa4ahiJgjen4lKrVdq09bn9oA6xg21rJKTdy0n6dW8XOzE0u0h00J2CG0GGrZ2OvaY1rVd0gnsiAkHOPdgDJEXrRxk3OXouIkCpA6xg21LdA61COKrNliOtkq9Ix6opOPRfeBwtwwcYHUOqTncYeRn2dA6tZbsdrfUhn9ld76YbnDdQruVuUZdA6tZbsdcYeRn2dA6tZbsdrfUhT6XTIEhGOpOPhT5aPHOroaE0iHOrWq1B0ah8tlyvIkCpA6xg21LdA6guJOEXMZdA6tZbsdcYeRpOPpnhinOMzcCMJVvXMcWb)0YWUAlLJWwwMcmx80IbQM4ajncZdA6Zl4J7GAh00NMdKgMwOjTmSRA7IkCpAvHbTo6DG8OTjAMRxGSIglgnOkfLU6OxC02jy0h4junenwmAZe4YN0B0imFYHOf6s6nQq)YWUUCqt3GAe)bkhbRjQPGmX6dQOyHYNCy(duocf9sVa2xBtuH(LHDD5GMUb1iQWYeNtMcncrf6xg21LdA6guJOd7aKZfumb9kitS2OeetqpqNluTQXUSxaMpAOAhurXcLp5W8hOCek6LEbQpOIIfkFYH5pq5iuuiUo1l9cO2bvuSKOomXIttmsilwyKUAhurXcLp5W0eJeYIfgPhv4E0iidGhDI6oZhJ22ahinXiHeSemAYTIgje9iEJMIMlGEHOXIrRYqcGoAZe)rBecvfJWOrcrpI3OXOz0Q)oencZNCiAv1aLJq0Cyu0QQbkhbROrqnnuWOr1q0Sn6diItiAunZhJMlGnodqOXjy0h4june9oarRqofDcwO)YWE0mD04DasKmne9LYr4QUOrs6fSIwZ8hIEhGOrOqrJK0rlMaen5QdjPUsuH(LHDD5GMUb1is5tompxsVcYeRpOIILe9ctS4Chsa0fut1w6c(wWCG0eJesWQaoDUGLA0VmoWeCqHbA75wuH(LHDD5GMUb1iEzJdREIGHAnQa(kitS(GkkwO8jhMMyKqwSWi9Oc9ld76YbnDdQrmrDyIfNMyKqkitS2ypOIIfkFYHPjgjKfut1msHCQy(RQRra7Qw9X4RfgPxO8jhMMyKqwsqHyUU2odvZOdQOyHYNCy(duocf9sVa1hurXcLp5W8hOCekkexN6LEbmmQq)YWUUCqt3GAepqQHuaMpgvOFzyxxoOPBqnIu(KdttmsiJk0VmSRlh00nOgrunmzlOOfKjwFqfflu(KdttmsilOMvRUuocBzzkWCXtlgy)JXxlmsVq5tomnXiHSKGcXCDuH(LHDD5GMUb1iEUyS1uenvxuH(LHDD5GMUb1ikYs4CXyROc9ld76YbnDdQrK8h0Bs35t3BuH(LHDD5GMUb1iAMGg8hMyXPcZTeKjwFqffljQdtS40eJeYsckeZ12xFqfflMjOb)HjwCQWCRIcX1PEPxaeC6xg2lu(KdZZL0Bb4k8OlmxMcuT6bvuSq5tomnXiHSKGcXCT91hurXIzcAWFyIfNkm3QOqCDQx6fabN(LH9cLp5W8Cj9waUcp6cZLParf6xg21LdA6guJOjEzyxqMy9bvuSq5tomnXiHSGAQMrhurXYbsnKcW8XcQz1QhurXY5IXwtr0uDfuZQvnwJs6HYM47TA1KEOGZ3qdJk0VmSRlh00nOgrkFYHjopcYeRpOIIfkFYH5pq5iu0l9cuBx1Qgr)Y4atWbfgOTNBvRAe9lJdmbhuyG2EBP2sxW3scASt(dfWPZfSm0WOc9ld76YbnDdQrKYNCyEOmPrqqMyn9lJdmbhuyGw11CtnJoOIIfkFYH5pq5iu0l9cuFqfflu(KdZFGYrOOqCDQx6fWWOc9ld76YbnDdQrKYNCycC18I1mSlitSM(LXbMGdkmqR6AUfv4E0CXrhNq0imFYHOv1mTMDbD0wOjZhJgH5toeTXHrcPGrtAMfeTyIvIwJvGO5aP6IwBcptK9rdC9bZLHDTGrFzcar74n6bIdZhJ22ahinXiHeSIEPl4lyfTArNOUZ8XO5gxJgH5toeTXHQOaxMpwIk0VmSRlh00nOgrkFYHPctRzxqlitS(Gkkw(lq5t6L5JLeOFvJ(LXbMGdkmqBp3uZOLUGVfsX8YezpTmSxaNoxWQAvJm2LUGVfmhinXiHeSkGtNlyPgPkcs2cfkFYHPjQIcCz(yjjxavxBldRw9GkkwO8jhMMyKqwSWiDdf8hiMxBtuH(LHDD5GMUb1is5tompxsVcYeRPFzCGj4Gcd02ZTOc3JwymYO3bAJgjyBtiAlSdrFqtN5Jcgnsi6N8OrnTOfIEhGOjoqsJW8GM(8c(4oens2oe9oarFbFChIglg9oW0rFqtVev4E00VmSRlh00nOgrouYOZfe0jfOM4ajncZdA6Zl4J7GGyZAnScYHUOqTrCOKrNluioqsJW8GM(8c(4oGGZHsgDUqzXlDNh001Cjhkz05cfIdK0impOPpVGpUdgy0bn9P5aPHPfAsld7gAOQGCOKrNluw8s35bnDDuH(LHDD5GMUb1icCWpTmSliZxituZDYeRviNkM)Q6AJhbeK5lKjQ5ozkkGfJwO2MOc3J22ioJEhGOtkHOX)tAg2Jg5aKq0iHOhXrJXkrFarCcrdCWpTmShnth9HEbIg1SeTriOAu6Evx0h4junensi6ryJMdKQl6dzfD6JrRXrVdq0h00JMPJ(r3O5aP6IwpGZ1WOc9ld76YbnDdQrKYNCyEOmPriQevOFzyxxESRHKduRWYeNtMcncrf6xg21Lh7Ai5aguJ4pq5iynrnfKjwFqfflu(KdZFGYrOOx6fO2UOc9ld76YJDnKCadQr0HDaY5ckMGEfKjwBucIjOhOZfQw1yx2laZhnuTdQOyHYNCy(duocf9sVa1hurXcLp5W8hOCekkexN6LEbu7GkkwsuhMyXPjgjKflmsxTdQOyHYNCyAIrczXcJ0Jk0VmSRlp21qYbmOgrkFYHjopcYeRpOIIfkFYH5pq5iu0l9cyFTTuZOhJVwyKEHYNCyAIrczjbfI5AvBJDvRs)Y4atWbfgOTV2wggv4E0imFYHOf6s6nA9atC1rJAgnZJ2mz4KTQlAKdGhDI6oZhJorVq0yXO3HeaDjQq)YWUU8yxdjhWGAeP8jhMNlPxbzI1hurXsIEHjwCUdja6cQPAhurXcLp5W8hOCek6LEbun3Ik0VmSRlp21qYbmOgXe1HjwCAIrcPGmX6dQOyHYNCy(duocf9sVa1hurXcLp5W8hOCekkexN6LEbuZir07DMWpq5imxMcyFnWv4rxyUmfOAvr07DMWpq5imxMcyF9JXxlmsVq5tomnXiHSKGcXCD1QlLJWwwMcmx80Ib2x)y81cJ0lu(KdttmsiljOqmxByuH(LHDD5XUgsoGb1is5tomvyAn7cAbzI1kKtfZFTV22ra1oOIIL)cu(KEz(yjb6xb)bI512ev4E0QcGMmFm6h7Ai5acgnsiA9YU3OrWq1B0ijFJEXr)yFzokeTJ3OTsSPjZhJ(hOCe0rt6OVyFmAshTjwRzNlu4XrlaaMrBBpOPZ8rBB0Ko6l2hJM0rBI1A25crBejaf9JDnKCGPc5u07qc6Hb81YWOj3k6Da8O1ijZOxC0u0QpxJgHcXLQgHhkZOFSRHKdeDIxAzyVenxumAKq0w4OD8g9aXbIw9JgHQkbJgje9tE0wmZO1x24WEvx0xmsiJEXrpcB0u0Q)oencvvLOrqGOPRghTgvVeZJM2OPOhyJdqgTc5u0Mq(GV0ienYbWJgjeT5L8OxC0OAiAkAUaQdrJfJ24WiHmAl0K5Jr)yxdjhiAZbsdcgTghnsi6N8OpOPhTfAY8XO3biAUaQdrJfJ24WiHSevOFzyxxESRHKdyqnIu(KdZdLjnccYeRnYOdQOyHYNCy(duocf9sVa1hurXcLp5W8hOCekkexN6LEbmunJmsHCQy(R91COKrNluESRHKdmviNmSAvJEm(AHr6fkFYHPjgjKLeuiMRv9JXxlmsVKOomXIttmsilIO37mHFGYryUmfqnfYPI5V2xZHsgDUq5XUgsoWuHCYaBHagAy1QgT0f8Tq5tomX5PaoDUGLApgFTWi9cLp5WeNNsckeZ12xp(wQ9y81cJ0lu(KdttmsiljOqmxRABSZqdRwvHCQy(R91gXHsgDUq5XUgsoWuHCIlTXodRwvHCQy(R91gXHsgDUq5XUgsoWuHCIlra7mmQW9O5rnH0XCOOz6Opucx1fnsCUdr)KEz(OGrJCG9drZ0rJCqDrZ2Oz6O14OfPmAlmsxWOX(vDrJGHQ3OPdMdencfQeDuH(LHDD5XUgsoGb1iQrnH0XCibzI1kKtfZFTV22rGOc3JwvmaMrBBpOPZ8rBB0mpAcdrRzlkTmSRJg1x2n6h7Ai5atfYPOn)TencfxiJEhOnASFvx0pP3OrO6jAKSDiAUfncZNCi6FGYrqly0AM)q0S12QJMUky9gnOkfLUrRqof9J1B0loAkAUfTEPxGOrOqrtU6qsQRenc3O3bAJ2eZ8nAeIvprN4Lwg2Jgj7EJ(arJqHIMRClAUu1rJq1t0CPQJgHhkZOc9ld76YJDnKCadQrKYNCycC18I1mSlitSM(LXbMGdkmqR6AUPMrkKtfZFvDnhkz05cLh7Ai5atfYPQvpOIIfkFYH5pq5iu0l9cuZndJk0VmSRlp21qYbmOgrkFYH55s6nQq)YWUU8yxdjhWGAeP8jhMhktAeIkrf6xg21ffmhqb8TwpWuuGuqMyTcMdOa(wSy6L8huDTn2fvOFzyxxuWCafWxdQr8CzUacYeRvWCafW3IftVK)GQRTXUOc9ld76IcMdOa(AqnIMjOb)HjwCQWCROc9ld76IcMdOa(AqnIu(KdtfMwZUGoQq)YWUUOG5akGVguJiLp5WeNNOc9ld76IcMdOa(AqnIAutiDmhsYZbsnd7sHTLD2y82z82WTInCdbqajpskDMpQL8CrftCUGv0iq00VmSh9LPxDjQi5j0DaNsEvHabyxMK)Y0RwQIK)XUgsoGufPW2ivrYt)YWUKxHLjoNmfAeK8GtNlyjfsUsHTLufjp405cwsHK8FYwizKK)GkkwO8jhM)aLJqrV0lq01rBNKN(LHDj)pq5iynrnLRuyUjvrYdoDUGLuij)NSfsgj5nk6eetqpqNleD1QrBSrVSxaMpgTHrRw0hurXcLp5W8hOCek6LEbIUo6dQOyHYNCy(duocffIRt9sVarRw0hurXsI6WelonXiHSyHr6rRw0hurXcLp5W0eJeYIfgPl5PFzyxY7Woa5CbftqVYvkS6lvrYdoDUGLuij)NSfsgj5pOIIfkFYH5pq5iu0l9ceT91rBROvlAJI(X4RfgPxO8jhMMyKqwsqHyUoAvhTn2fD1Qrt)Y4atWbfgOJ2(6OTv0gk5PFzyxYt5tomX5rUsHraPksEWPZfSKcj5)KTqYij)bvuSKOxyIfN7qcGUGAgTArFqfflu(KdZFGYrOOx6fiAvhn3K80VmSl5P8jhMNlPx5kf2yKQi5bNoxWskKK)t2cjJK8hurXcLp5W8hOCek6LEbIUo6dQOyHYNCy(duocffIRt9sVarRw0gfTi69ot4hOCeMltbI2(6ObUcp6cZLParxTA0IO37mHFGYryUmfiA7RJ(X4RfgPxO8jhMMyKqwsqHyUo6QvJEPCe2YYuG5INwmiA7RJ(X4RfgPxO8jhMMyKqwsqHyUoAdL80VmSl5tuhMyXPjgjKYvkSQSufjp405cwsHK80VmSl5P8jhMkmTMDbTK)hiMl5TrY)jBHKrsEfYPI5VrBFD02oceTArFqffl)fO8j9Y8Xsc0VYvkSXlvrYdoDUGLuij)NSfsgj5nkAJI(GkkwO8jhM)aLJqrV0lq01rFqfflu(KdZFGYrOOqCDQx6fiAdJwTOnkAJIwHCQy(B02xhnhkz05cLh7Ai5atfYPOnm6QvJ2OOFm(AHr6fkFYHPjgjKLeuiMRJw1r)y81cJ0ljQdtS40eJeYIi69ot4hOCeMltbIwTOviNkM)gT91rZHsgDUq5XUgsoWuHCkAdI2wiq0ggTHrxTA0gf9sxW3cLp5WeNNc405cwrRw0pgFTWi9cLp5WeNNsckeZ1rBFD0JVv0Qf9JXxlmsVq5tomnXiHSKGcXCD0QoABSlAdJ2WORwnAfYPI5VrBFD0gfnhkz05cLh7Ai5atfYPO5YOTXUOnm6QvJwHCQy(B02xhTrrZHsgDUq5XUgsoWuHCkAUmAeWUOnuYt)YWUKNYNCyEOmPrqUsHTDPksEWPZfSKcj5)KTqYijVc5uX83OTVoABhbK80VmSl51OMq6yoKCLcBJDsvK8GtNlyjfsY)jBHKrsE6xghycoOWaD0QUoAUfTArBu0kKtfZFJw11rZHsgDUq5XUgsoWuHCk6QvJ(GkkwO8jhM)aLJqrV0lq01rZTOnuYt)YWUKNYNCycC18I1mSlxPW2yJufjp9ld7sEkFYH55s6vYdoDUGLui5kf2gBjvrYt)YWUKNYNCyEOmPrqYdoDUGLui5kxjVfisO3vQIuyBKQi5PFzyxY)yuFHuBc3RKhC6CblPqYvkSTKQi5bNoxWskKK)t2cjJK8h00NMdKgIUA1OxkhHTSmfyU4PfdI2(OjoqsJW8GM(8c(4oi5PFzyxY)09oPFzyFEz6vYFz6D6Kci5pOPlxPWCtQIKhC6CblPqs(pzlKmsYBu0pgFTWi9cLp5W0eJeYsckeZ1rxhTDrRw0pgFTWi9cWb)0YWEjbfI56OTVoAIdK0impOPpVGpUdrRw0gf9bvuSq5tom)bkhHIEPxGORJ(GkkwO8jhM)aLJqrH46uV0lq0vRgTrrV0f8T8duocwtuZc405cwrRw0pgFTWi9Ypq5iynrnljOqmxhDD02fTHrBy0gk5PFzyxY)09oPFzyFEz6vYFz6D6Kci5pOPlxPWQVufjp405cwsHK8FYwizKK3yJ(GM(0CG0GKN(LHDj)t37K(LH95LPxj)LP3PtkGK)XUgsoGCLcJasvK8GtNlyjfsYt)YWUK)P7Ds)YW(8Y0RK)Y070jfqYRG5akGVYvUsEZeESYHwPksHTrQIKhC6CblPqYvkSTKQi5bNoxWskKCLcZnPksEWPZfSKcjxPWQVufjp9ld7sEkFYHjZx4EHFL8GtNlyjfsUsHraPksE6xg2L8AuffSpP8jhMIKc7YOuYdoDUGLui5kf2yKQi5bNoxWskKKhBk51Wk5PFzyxYZHsgDUGKNdDrbjVXyNKNdLtNuaj)JDnKCGPc5KCLcRklvrYdoDUGLui5kf24LQi5PFzyxYRWYeNtMcncsEWPZfSKcjxPW2Uufjp9ld7sEt8YWUKhC6CblPqYvkSn2jvrYt)YWUKNYNCyEUKEL8GtNlyjfsUYvYFqtxQIuyBKQi5bNoxWskKK)t2cjJK8hurXcLp5W8hOCek6LEbI2(6OTrYt)YWUK)hOCeSMOMYvkSTKQi5PFzyxYRWYeNtMcncsEWPZfSKcjxPWCtQIKhC6CblPqs(pzlKmsYBu0jiMGEGoxi6QvJ2yJEzVamFmAdJwTOpOIIfkFYH5pq5iu0l9ceDD0hurXcLp5W8hOCekkexN6LEbIwTOpOIILe1HjwCAIrczXcJ0JwTOpOIIfkFYHPjgjKflmsxYt)YWUK3HDaY5ckMGELRuy1xQIKhC6CblPqs(pzlKmsYFqfflj6fMyX5oKaOlOMrRw0lDbFlyoqAIrcjyvaNoxWkA1IM(LXbMGdkmqhT9rZnjp9ld7sEkFYH55s6vUsHraPksEWPZfSKcj5)KTqYij)bvuSq5tomnXiHSyHr6sE6xg2L8x24WQNiyOwJkGVYvkSXivrYdoDUGLuij)NSfsgj5n2OpOIIfkFYHPjgjKfuZOvlAJIwHCQy(B0QUoAeWUORwn6hJVwyKEHYNCyAIrczjbfI56ORJ2UOnmA1I2OOpOIIfkFYH5pq5iu0l9ceDD0hurXcLp5W8hOCekkexN6LEbI2qjp9ld7s(e1HjwCAIrcPCLcRklvrYt)YWUK)aPgsby(OKhC6CblPqYvkSXlvrYt)YWUKNYNCyAIrcPKhC6CblPqYvkSTlvrYdoDUGLuij)NSfsgj5pOIIfkFYHPjgjKfuZORwn6LYrylltbMlEAXGOTp6hJVwyKEHYNCyAIrczjbfI5Ajp9ld7sEunmzlOOLRuyBStQIKN(LHDj)5IXwtr0uDsEWPZfSKcjxPW2yJufjp9ld7sErwcNlgBj5bNoxWskKCLcBJTKQi5PFzyxYt(d6nP78P7vYdoDUGLui5kf2gUjvrYdoDUGLuij)NSfsgj5pOIILe1HjwCAIrczjbfI56OTVo6dQOyXmbn4pmXItfMBvuiUo1l9cencE00VmSxO8jhMNlP3cWv4rxyUmfi6QvJ(GkkwO8jhMMyKqwsqHyUoA7RJ(Gkkwmtqd(dtS4uH5wffIRt9sVarJGhn9ld7fkFYH55s6TaCfE0fMltbK80VmSl5ntqd(dtS4uH5wYvkSnQVufjp405cwsHK8FYwizKK)GkkwO8jhMMyKqwqnJwTOnk6dQOy5aPgsby(yb1m6QvJ(Gkkwoxm2AkIMQRGAgD1QrBSrBu0j9qzt89gD1QrN0dfC(rBy0gk5PFzyxYBIxg2LRuyBqaPksEWPZfSKcj5)KTqYij)bvuSq5tom)bkhHIEPxGORJ2UORwnAJIM(LXbMGdkmqhT9rZTORwnAJIM(LXbMGdkmqhT9rBROvl6LUGVLe0yN8hkGtNlyfTHrBOKN(LHDjpLp5WeNh5kf2gJrQIKhC6CblPqs(pzlKmsYt)Y4atWbfgOJw11rZTOvlAJI(GkkwO8jhM)aLJqrV0lq01rFqfflu(KdZFGYrOOqCDQx6fiAdL80VmSl5P8jhMhktAeKRuyBuLLQi5bNoxWskKK)t2cjJK80VmoWeCqHb6OvDD0CtYt)YWUKNYNCycC18I1mSlxPW2y8svK8GtNlyjfsYt)YWUKNYNCyQW0A2f0s(FGyUK3gj)NSfsgj5pOIIL)cu(KEz(yjb63OvlA6xghycoOWaD02hn3IwTOnk6LUGVfsX8YezpTmSxaNoxWk6QvJ2OOn2Ox6c(wWCG0eJesWQaoDUGv0QfnPkcs2cfkFYHPjQIcCz(yjjxGOvDD02kAdJUA1OpOIIfkFYHPjgjKflmspAdLRuyBSDPksEWPZfSKcj5)KTqYijp9lJdmbhuyGoA7JMBsE6xg2L8u(KdZZL0RCLcBl7KQi5z(czIAUtMOKxHCQy(RQRnEeqYZ8fYe1CNmffWIrli5TrYt)YWUKh4GFAzyxYdoDUGLui5kf2w2ivrYt)YWUKNYNCyEOmPrqYdoDUGLui5kxjVcMdOa(kvrkSnsvK8GtNlyjfsY)jBHKrsEfmhqb8TyX0l5peTQRJ2g7K80VmSl51dmffiLRuyBjvrYdoDUGLuij)NSfsgj5vWCafW3IftVK)q0QUoABStYt)YWUK)CzUaYvkm3KQi5PFzyxYBMGg8hMyXPcZTK8GtNlyjfsUsHvFPksE6xg2L8u(KdtfMwZUGwYdoDUGLui5kfgbKQi5PFzyxYt5tomX5rYdoDUGLui5kf2yKQi5PFzyxYRrnH0XCijp405cwsHKRCLRCLRuca]] )
    

end
