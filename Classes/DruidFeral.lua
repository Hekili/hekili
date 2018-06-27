local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 103 )

    spec:RegisterResource( Enum.PowerType.Rage )
    spec:RegisterResource( Enum.PowerType.LunarPower )
    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy )
    
    -- Talents
    spec:RegisterTalents( {
        blood_scent = 22363, -- 202022
        predator = 22364, -- 202021
        lunar_inspiration = 22365, -- 155580

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        balance_affinity = 22163, -- 197488
        guardian_affinity = 22158, -- 217615
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 21708, -- 158476
        jagged_wounds = 18579, -- 202032
        incarnation = 21704, -- 102543

        sabertooth = 21714, -- 202031
        brutal_slash = 21711, -- 202028
        savage_roar = 22370, -- 52610

        moment_of_clarity = 21646, -- 236068
        bloodtalons = 21649, -- 155672
        feral_frenzy = 21653, -- 274837
    } )

    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        berserk = {
            id = 106951,
            duration = 15,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        bloodtalons = {
            id = 145152, 
            max_stack = 2,
            duration = 30,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        clearcasting = {
            id = 135700,
            duation = 15,
            max_stack = function()
                local x = 1 -- Base Stacks
                return talent.moment_of_clarity.enabled and 2 or x
            end,
        },
        dash = {
            id = 1850,
            duration = 10,
        },
        entangling = {
            id = 455,
            duration = 30,
            type = "Magic",
        },
        feline_swiftness = {
            id = 131768,
        },
        feral_frenzy = {
            id = 274837,
        },
        feral_instinct = {
            id = 16949,
        },
        flight_form = {
            id = 276029,
        },
        frenzied_regeneration = {
            id = 22842,
        },
        incarnation = {
            id = 102543,
            duration = 30,
        },
        infected_wounds = {
            id = 48484,
        },
        ironfur = {
            id = 192081,
        },
        jungle_stalker = {
            id = 252071, 
            duration = 30,
        },
        moonfire = {
            id = 155625, 
            duration = 16
        },
        moonkin_form = {
            id = 197625,
        },
        omen_of_clarity = {
            id = 16864,
            duration = 16,
            max_stack = function()
                local x = 1 -- Base Stacks
                if talent.moment_of_clarity.enabled then return 2 end
                return x
            end
        },
        predatory_swiftness = {
            id = 16974,
            duration = 12,
            max_stack = 1,
        },
        primal_fury = {
            id = 159286,
        },
        prowl = {
            id = 5215,
            duration = 3600,
        },
        rake = {
            id = 155722, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end,
            tick_time = function()
                local x = 3 -- Base Tick
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end,
        },
        regrowth = { 
            id = 8936, 
            duration = 12,
        },
        rip = {
            id = 1079,
            duration = function()
                local x = 24 --Base duration
                    return ( talent.jagged_wounds.enabled and x * 0.80 or x )
            end,
        },
        savage_roar = {
            id = 52610,
            duration = 36,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
        },
        survival_instincts = {
            id = 61336,
        },
        thrash ={
            id =  106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        thick_hide = {
            id = 16931,
        },
        tiger_dash = {
            id = 252216,
        },
        tigers_fury = {
            id = 5217,
            duration = function()
                local x = 8 -- Base Duration
                if talent.predator.enabled then return x + 4 end
                return x
            end,
        },
        travel_form = {
            id = 783,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },
    } )

    local tf_spells = { rake = true, rip = true, thrash = true, moonfire = true }
    local bt_spells = { rake = true, rip = true, thrash = true }
    local mc_spells = { thrash = true }
    local pr_spells = { rake = true }

    perMult = 1

    spec:RegisterStateFunction('persistent_multiplier', function ()
        local mult = 1

            if not this_action then return mult end

            if tf_spells[ this_action ] and buff.tigers_fury.up then mult = mult * 1.15 end
            if bt_spells[ this_action ] and buff.bloodtalons.up then mult = mult * 1.20 end
            if mc_spells[ this_action ] and buff.clearcasting.up then mult = mult * 1.20 end
            if pr_spells[ this_action ] and ( buff.prowl.up or buff.shadowmeld.up or buff.incarnation.up ) then mult = mult * 2.00 end
            perMult = mult
            return mult
    end )


    spec:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        if sourceGUID == state.GUID then
            if subtype == "SPELL_AURA_REMOVED" then
                -- Track Prowl and Shadowmeld dropping, give a 0.2s window for the Rake snapshot.
                if spellID == 58984 or spellID == 5215 or spellID == 1102547 then
                    stealth_dropped = GetTime()
                end
            elseif subtype == "SPELL_AURA_APPLIED" then
                if snapshots[ spellID ] and ( subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) then
                    ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                    ns.trackDebuff( spellID, destGUID, GetTime(), true )
                end
            end
        end
    end )

    local function calculate_multiplier( spellID )

        local tigers_fury = UnitBuff( "player", class.auras.tigers_fury.name, nil, "PLAYER" )
        local bloodtalons = UnitBuff( "player", class.auras.bloodtalons.name, nil, "PLAYER" )
        local clearcasting = UnitBuff( "player", class.auras.clearcasting.name, nil, "PLAYER" )
        local prowling = GetTime() - stealth_dropped < 0.2 or
                         UnitBuff( "player", class.auras.incarnation.name, nil, "PLAYER" )

        if spellID == 155722 then
            return 1 * ( prowling and 2 or 1 ) * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

        elseif spellID == 1079 then
            return 1 * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

        elseif spellID == 106830 then
            return 1 * ( clearcasting and 1.2 or 1 ) * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

        elseif spellID == 155625 then
            return 1 * ( tigers_fury and 1.15 or 1 )

        end

        return 1
    end

    -- Function to remove any form currently active
    state.unshift = setfenv( function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
    end, state )

    state.shift = setfenv( function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        applyBuff( form )
    end, state )

    -- Abilities
    spec:RegisterAbilities( {
        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132276,
            
            usable = function ()
                return not buff.bear_form.up
            end,
            handler = function ()
                shift("bear_form")
            end,
        },
        

        berserk = {
            id = 106951,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236149,
            useable = function ()
                return buff.cat_form.up
            end,

            handler = function ()
                applyBuff("berserk", 15)
                energy.max = energy.max + 50
            end,
        },
        

        brutal_slash = {
            id = 202028,
            cast = 0,
            charges = 3,
            cooldown = function()
                return 6.57 * haste
            end,
            recharge = function()
                return 6.57 * haste
            end,
            min_range = 0,
            max_range = 8,
            gcd = "spell",
            
            spend = function()
                local x = 30 --Base cost
                if buff.clearcasting.up then return 0 end
                return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
            end,
            spendType = "energy",
            ready = function ()
                --Removing settings options until implemented.
                --if active_enemies == 1 and settings.brutal_charges == 3 then return 3600 end
                --if active_enemies > 1 or settings.brutal_charges == 0 then return 0 end

                if active_enemies == 1 then return 3600 end
                if active_enemies > 1 then return 0 end

                -- We need time to generate 1 charge more than our settings.brutal_charges value.
                -- return ( 1 + settings.brutal_charges - cooldown.brutal_slash.charges_fractional ) * recharge
                return ( 4 - cooldown.brutal_slash.charges_fractional ) * recharge
            end,
            
            startsCombat = true,
            texture = 132141,
            usable = function()
                return buff.cat_form.up
            end,

            handler = function ()
                gain(1, "combo_point")
                removeStack("bloodtalons")
            end,
        },
        

        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132115,
            usable = function()
                return not buff.cat_form.up
            end,
            
            handler = function ()
                shift("cat_form")
            end,
        },
        

        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132120,
            usable = function ()
                return not buff.cat_form.up
            end,
            
            handler = function ()
                applyBuff("dash")
            end,
        },
        

        entangling_roots = {
            id = 339,
            cast = function()
                if buff.predatory_swiftness.up then return 0 end
                return 1.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136100,
            usable = function ()
                --add logic to use roots when current debuff is less than or equal to the cast time
                return (dot.entangling.expires <= abilities.entangling_roots.cast)
            end,
            
            handler = function ()
                applyDebuff("target","entangling", 30)
                removeBuff("predatory_swiftness")
                if talent.bloodtalons.enabled then applyBuff( "bloodtalons", 30, 2 ) end
            end,
        },
        

        feral_frenzy = {
            id = 274837,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 25,
            spendType = "energy",
            
            unsupported = true,
            startsCombat = true,
            texture = 132140,
            
            handler = function ()
            end,
        },
        

        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function()
                local x = 25 -- Base cost
                -- Calculate extra cost/damage modifier if used at max energy 
                if energy.max == 1 then
                    x = x + 25
                end

                return x * ((buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132127,
            usable = function()
                return combo_points.current > 0
            end,

            handler = function ()
                spend(min(5, combo_points.current), "combo_points")
                removeStack("bloodtalons")
                if (target.health_pct < 25 or talent.sabertooth.enabled) and dot.rip.up then 
                    dot.rip.expires = query_time + min(dot.rip.remains + dot.rip.duration, dot.rip.duration * 1.3)
                end
            end,
        },
        

        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 1,
            cooldown = 29.568,
            recharge = 29.568,
            gcd = "spell",
            
            spend = 10,
            spendType = "rage",
            
            unsupported = true,
            startsCombat = false,
            texture = 132091,
            
            handler = function ()
            end,
        },
        

        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132270,
            unsupported = true,

            handler = function ()
            end,
        },
        

        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136090,
            unsupported = true,

            handler = function ()
            end,
        },
        

        incarnation = {
            id = 102543,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 571586,
            
            handler = function ()
                applyBuff( "incarnation", 30 )
                applyBuff( "jungle_stalker", 30 )
                energy.max = energy.max + 50

                shift( "cat_form" )
            end,
        },
        

        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",
            
            spend = 45,
            spendType = "rage",
            
            unsupported = true,
            startsCombat = false,
            texture = 1378702,
            
            handler = function ()
            end,
        },
        

        lunar_strike = {
            id = 197628,
            cast = 2.499524837265,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 135753,
            
            handler = function ()
            end,
        },
        

        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = function()
                local x = 35 -- Base cost
                return x * ((buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132134,
            usable = function () 
                return (combo_points.current > 0 and buff.cat_form.up)
            end,            
            handler = function ()
                applyDebuff("target", "maim", combo_points.current)
                spend(combo_points.current, "combo_points")
                removeStack("bloodtalons")
            end,
        },
        

        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            unsupported = true,
            startsCombat = true,
            texture = 132135,
            
            handler = function ()
            end,
        },
        

        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            unsupported = true,
            startsCombat = false,
            texture = 538515,
            
            handler = function ()
            end,
        },
        

        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",
            min_range = 0,
            max_range = 0,
            
            startsCombat = true,
            texture = 132114,
            usable = function()
                return talent.mighty_bash.enabled
            end,
            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },
        

        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = true,
            texture = 136096,
            usable = function()
                return talent.lunar_inspiration.enabled
            end,            
            handler = function ()
                gain( 1, "combo_points" )
                applyDebuff( "target", "moonfire" )
            end,
            recheck = function ()
                return dot.moonfire.remains - dot.moonfire.duration * 0.3, dot.moonfire.remains
            end,
        },
        

        moonkin_form = {
            id = 197625,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            unsupported = true,
            startsCombat = false,
            texture = 136036,
            
            handler = function ()
            end,
        },
        

        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6, function()
                local x = 6 -- Base CD
                if buff.prowl.up then return 0 end
                return x
            end,
            gcd = "spell",
            startsCombat = false,
            texture = 514640,
            usable = function() 
                return (time == 0 or boss or buff.jungle_stalker.up ) and not buff.prowl.up 
            end,
            handler = function ()
                shift("cat_form")
                applyBuff("prowl")
            end,
        },
        

        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function()
                local x = 35 -- Base cost
                return x * ((buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            
            spendType = "energy",
            
            startsCombat = true,
            texture = 132122,
            usable = function () 
                return buff.cat_form.up 
            end,
            
            handler = function ()
                applyDebuff("target", "rake")
                debuff.rake.pmultiplier = persistent_multiplier()
    
                gain(1, "combo_points")
                removeStack("bloodtalons")
            end,
            recheck = function ()
                return dot.rake.remains - dot.rake.duration * 0.3, dot.rake.remains
            end,
        },
        

        rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",
            
            spend = 0,
            spendType = "mana",

            unsupported = true,
            startsCombat = true,
            texture = 136080,
            
            handler = function ()
            end,
        },
        

        regrowth = {
            id = 8936,
            cast = function()
                local x = 1.5 -- Base cast
                if buff.predatory_swiftness.up then return 0 end
                return x * haste
            end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136085,
            usable = function()
                if not talent.bloodtalons.enabled then return false end
                if buff.bloodtalons.up then return false end
                if buff.cat_form.up then
                    return buff.predatory_swiftness.up or time == 0
                end
            end,
            
            handler = function ()
                if buff.predatory_swiftness.down then
                    unshift()
                end
                removeBuff("predatory_swiftness")
                if talent.bloodtalons.enabled then
                    applyBuff("bloodtalons", 30, 2)
                end
                applyBuff( "regrowth", 12 )
            end,
        },
        

        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 136081,
            
            handler = function ()
            end,
        },
        
        --Add support to remove corruption effects if not removed fast enough by healer.
        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 135952,
            
            handler = function ()
            end,
        },
        

        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136059,
            usable = function()
                return talent.renewal.enabled
            end,
            
            handler = function ()
                health.actual = min( health.max, health.actual + ( health.max * 0.3 ) )
            end,
        },
        

        revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 132132,
            
            handler = function ()
            end,
        },
        
        -- Spend Points in handler, check for points in usable function of rotation.
        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function()
                local x = 30 --Base Cost
                return x * ((buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132152,
            usable = function () 
                return combo_points.current > 0 
            end,

            recheck = function () 
                return dot.rip.remains - dot.rip.duration * 0.3, dot.rip.remains 
            end,
            
            handler = function ()
                applyDebuff("target", "rip", min(1.3 * class.auras.rip.duration, dot.rip.remains + class.auras.rip.duration))
                spend(combo_points.current, "combo_points")
                debuff.rip.pmultiplier = persistent_multiplier()
                removeStack( "bloodtalons" )
            end,
        },
        
        -- Spend Points in handler, check for points in usable function of rotation.
        savage_roar = {
            id = 52610,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function()
                local x = 30
                return x * (( buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            spendType = "energy",
            
            startsCombat = false,
            texture = 236167,
            usable = function()
                return talent.savage_roar.enabled
            end,
            
            handler = function ()
                local cost = min(5, combo_points.current)
                spend(cost, "combo_points")
                applyBuff("savage_roar", 6 + (6 * cost))
            end,
        },
        

        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function()
                local x = 40 -- Base cost
                if buff.clearcasting.up then return 0 end
                return x * (( buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 136231,
            
            handler = function ()
                gain(1, "combo_points")
                removeStack("bloodtalons")
                removeStack("clearcasting")
            end,
        },
        

        skull_bash = {
            id = 106839,
            cast = 0,
            cooldown = 15,
            min_range = 0,
            max_range = 13,
            gcd = "spell",
            toggle = "interrupts",

            startsCombat = true,
            texture = 236946,
            usable = function() 
                return target.casting 
            end,
            
            handler = function ()
                interrupt()
            end,
        },
        

        solar_wrath = {
            id = 197629,
            cast = 1.4999584020996,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 535045,
            
            handler = function ()
            end,
        },
        

        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = false,
            texture = 132163,
            
            handler = function ()
            end,
        },
        

        stampeding_roar = {
            id = 106898,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 464343,
            
            handler = function ()
                if buff.bear_form.down and buff.cat_form.down then
                    shift( "bear_form" )

                end
            end,
        },
        

        starsurge = {
            id = 197626,
            cast = 2.0003503690338,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 135730,
            
            handler = function ()
            end,
        },
        

        sunfire = {
            id = 197630,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.12,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 236216,
            
            handler = function ()
            end,
        },
        

        survival_instincts = {
            id = 61336,
            cast = 0,
            charges = 2,
            cooldown = 120,
            recharge = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236169,
            usable = function () 
                return buff.survival_instincts.down 
            end,
            
            handler = function ()
                applyBuff( "survival_instincts", 6 )
            end,
        },
        

        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = false,
            texture = 134914,
            
            handler = function ()
            end,
        },
        

        swipe = {
            id = 213764,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            spend = function()
                x = 40
                if buff.clearcasting.up then return 0 end
                return x * ((buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 134296,
            usable = function()
                return (not talent.brutal_slash and buff.cat_form.up)
            end,

            handler = function ()
                gain(1, "combo_points") 
                removeStack("bloodtalons")
                removeStack("clearcasting")
            end,
        },
        

        teleport_moonglade = {
            id = 18960,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 4,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135758,
            
            handler = function ()
            end,
        },
        

        thrash = {
            id = 106830,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            spend = function()
                local x = 45
                if buff.clearcasting.up then return 0 end
                return x * ((buff.berserk.up or buff.incarnation.up) and 0.5 or 1)
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 451161,
            usable = function()
                return buff.cat_form.up
            end,
            recheck = function ()
                return dot.thrash.remains - dot.thrash.duration * 0.3, dot.thrash.remains
            end,            
            handler = function ()
                if buff.cat_form.up then
                    applyDebuff( "target", "thrash" )
                    active_dot.thrash = max( active_dot.thrash, true_active_enemies )

                    debuff.thrash.pmultiplier = persistent_multiplier()

                    removeStack( "bloodtalons" )
                    removeStack( "clearcasting" )
                    if target.within8 then gain( 1, "combo_points" ) end
                end
            end,
        },
        

        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            unsupported = true,
            startsCombat = false,
            texture = 1817485,
            
            handler = function ()
            end,
        },
        

        tigers_fury = {
            id = 5217,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            spend = -50,
            spendType = "energy",
            startsCombat = false,
            texture = 132242,

            usable = function ()
                return not buff.tigers_fury.up
            end,
            
            handler = function ()
                applyBuff("tigers_fury", (talent.predator.enabled and 14 or 10))
            end,
        },
        

        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            unsupported = true,
            startsCombat = false,
            texture = 132144,
            
            handler = function ()
            end,
        },
        

        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            unsupported = true,
            startsCombat = true,
            texture = 236170,
            
            handler = function ()
            end,
        },
        

        wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            unsupported = true,
            startsCombat = false,
            texture = 1518639,
            
            handler = function ()
            end,
        },
        

        wild_charge = {
            id = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538771,
            usable = function () if buff.cat_form.up and target.outside8 and target.within25 then return target.exists end
                return false
            end,
            
            handler = function ()
                setDistance(5)
                applyDebuff("target", "dazed", 3)
            end,
        },
        

        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.3,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 236153,
            
            handler = function ()
            end,
        },
    } )



    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = nil,
    } )
end