-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

-- TODO:  Heart of the Wild, Covenants, Legendaries, Conduits.

if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102, true )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {            
            aura = "fury_of_elune_ap",

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 0.5 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        },

        natures_balance = {
            talent = "natures_balance",

            last = function ()
                local app = state.combat
                local t = state.query_time

                return app + floor( ( t - app ) / 1.5 ) * 1.5
            end,

            interval = 2,
            value = 1,
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )


    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        heart_of_the_wild = 18577, -- 319454

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation = 21702, -- 102560

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
        stellar_flare = 22165, -- 202347

        shooting_stars = 21648, -- 202342
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
        thorns = 3731, -- 305497
    } )


    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
    } )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = 20,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse_lunar = {
            id = 48518,
            duration = 16,
            max_stack = 1,
        },
        eclipse_solar = {
            id = 48517,
            duration = 16,
            max_stack = 1,
        },
        elunes_wrath = {
            id = 64823,
            duration = 10,
            max_stack = 1
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            max_stack = 1,

            generate = function ()
                local foe = buff.fury_of_elune_ap
                local applied = action.fury_of_elune.lastCast

                if applied and now - applied < 8 then
                    foe.count = 1
                    foe.expires = applied + 8
                    foe.applied = applied
                    foe.caster = "player"
                    return
                end

                foe.count = 0
                foe.expires = 0
                foe.applied = 0
                foe.caster = "nobody"
            end,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        heart_of_the_wild = {
            id = 108292,
            duration = 45,
            max_stack = 1,
        },
        incarnation = {
            id = 102560,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 28,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solstice = {
            id = 343648,
            duration = 6,
            max_stack = 1,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )

                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = 10,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_flare = {
            id = 202347,
            duration = 24,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 18,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        --[[ thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        }, ]]
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
            duration = 0.5,
            max_stack = 1,
        },
        yseras_gift = {
            id = 145108,
        },
        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        arcanic_pulsar = {
            id = 287790,
            duration = 3600,
            max_stack = 9,
        },

        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
        },
    } )


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        removeBuff( "celestial_guardian" )
    end )


    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )

        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
    end )


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return 0
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return 0
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end 
    end )

    spec:RegisterHook( "pregain", function( amt, resource, overcap, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt > 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )

    spec:RegisterHook( "prespend", function( amt, resource, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt < 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )


    local check_for_ap_overcap = setfenv( function( ability )
        local a = ability or this_action
        if not a then return true end

        a = action[ a ]
        if not a then return true end

        local cost = 0
        if a.spendType == "astral_power" then cost = a.cost end

        return astral_power.current - cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
    end, state )

    spec:RegisterStateExpr( "ap_check", function() return check_for_ap_overcap() end )
    
    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = { 
        "force_of_nature", "full_moon", "half_moon", "incarnation", "moonfire", "new_moon", "starfall", "starfire", "starsurge", "sunfire", "wrath"
    }

    for i, lookup in ipairs( ap_checks ) do
        spec:RegisterStateExpr( lookup, function ()
            return action[ lookup ]
        end )
    end
    

    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell

    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 ) 
        end

        -- Eclipses
        solar_eclipse = buff.eclipse_lunar.up and 2 or GetSpellCount( 197628 )
        lunar_eclipse = buff.eclipse_solar.up and 2 or GetSpellCount( 5176 )
    end )


    --[[ spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.impeccable_fel_essence and resource == "astral_power" and cooldown.celestial_alignment.remains > 0 then
            setCooldown( "celestial_alignment", max( 0, cooldown.celestial_alignment.remains - ( amt / 12 ) ) )
        end 
    end ) ]]


    -- Legion Sets (for now).
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( 'solar_solstice', {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } ) 

    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )    
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },    
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )



    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 136097,

            handler = function ()
                applyBuff( "barkskin" )
            end,
        },


        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -25,
            spendType = "rage",

            startsCombat = false,
            texture = 132276,

            noform = "bear_form",

            handler = function ()
                shift( "bear_form" )
            end,
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            noform = "cat_form",

            handler = function ()
                shift( "cat_form" )
            end,
        },


        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "celestial_alignment" )
                gain( 40, "astral_power" )
                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 33786,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136022,

            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",

            handler = function ()
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },


        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },


        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,

            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
            end,
        },


        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
                spend( combo_points.current, "combo_points" )
            end,
        },


        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132925,

            handler = function ()
            end,
        }, ]]


        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",

            ap_check = function() return check_for_ap_overcap( "force_of_nature" ) end,

            handler = function ()
                summonPet( "treants", 10 )
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = function () return ( talent.guardian_affinity.enabled and buff.heart_of_the_wild.up ) and 2 or nil end,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },


        full_moon = {
            id = 274283,
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",

            ap_check = function() return check_for_ap_overcap( "full_moon" ) end,

            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },


        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune_ap" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 132270,

            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        half_moon = {
            id = 274282, 
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",

            ap_check = function() return check_for_ap_overcap( "half_moon" ) end,

            usable = function () return active_moon == 'half_moon' end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },


        heart_of_the_wild = {
            id = 319454,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            toggle = "cooldowns",
            talent = "heart_of_the_wild",

            startsCombat = true,
            texture = 135879,
            
            handler = function ()
                applyBuff( "heart_of_the_wild" )
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

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incarnation = {
            id = 102560,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                shift( "moonkin_form" )
                
                applyBuff( "incarnation" )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = { "incarnation_chosen_of_elune", "Incarnation" },
        },


        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,

            usable = function () return group end,
            handler = function ()
                active_dot.innervate = 1
            end,
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = 45,
            spendType = "rage",

            startsCombat = true,
            texture = 1378702,

            handler = function ()
                applyBuff( "ironfur" )
            end,
        },


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            talent = "feral_affinity",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132134,
            
            usable = function () return combo_points.current > 0, "requires combo points" end,
            handler = function ()
                applyDebuff( "target", "maim" )
                spend( combo_points.current, "combo_points" )
            end,
        },
        

        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            form = "bear_form",

            handler = function ()
            end,
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",

            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",

            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },


        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -2,
            spendType = "astral_power",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function() return check_for_ap_overcap( "moonfire" ) end,

            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )

                if talent.twin_moons.enabled and active_enemies > 1 then
                    active_dot.moonfire = min( active_enemies, active_dot.moonfire + 1 )
                end
            end,
        },


        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            essential = true,

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        new_moon = {
            id = 274281, 
            cast = 1,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -10,
            spendType = "astral_power",

            texture = 1392545,
            startsCombat = true,

            talent = "new_moon",
            bind = "full_moon",

            ap_check = function() return check_for_ap_overcap( "new_moon" ) end,

            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },


        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            texture = 514640,

            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
            end,
        },


        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },


        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",

            spend = 0,
            spendType = "rage",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 136080,

            handler = function ()
            end,
        }, ]]


        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.17,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.11,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
            end,
        },


        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

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

            talent = "renewal",

            handler = function ()
                gain( 0.3 * health.max, "health" )
            end,
        },


        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        }, ]]


        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            form = "cat_form",

            handler = function ()
                gain( 1, "combo_points" )
            end,
        },


        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            spend = 0.17,
            spendType = "mana",

            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 132163,

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeBuff( "dispellable_enrage" )
            end,
        },


        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
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
                applyBuff( "stampeding_roar" )
            end,
        },


        starfall = {
            id = 191034,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.oneths_overconfidence.up then return 0 end
                return 50
            end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_overconfidence" )
            end,
        },


        starfire = {
            id = 194153,
            cast = function () 
                if buff.warrior_of_elune.up or buff.elunes_wrath.up then return 0 end
                return haste * ( buff.eclipse_lunar and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 2.25 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -8 end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135753,

            ap_check = function() return check_for_ap_overcap( "starfire" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if buff.eclipse_lunar.down and solar_eclipse > 0 then
                    solar_eclipse = solar_eclipse - 1
                    if solar_eclipse == 0 then
                        applyBuff( "eclipse_solar" )
                        if talent.solstice.enabled then applyBuff( "solstice" ) end
                    end
                end

                if level > 53 then
                    if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                    if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
                end

                if buff.elunes_wrath.up then
                    removeBuff( "elunes_wrath" )
                elseif buff.warrior_of_elune.up then
                    removeStack( "warrior_of_elune" )
                    if buff.warrior_of_elune.down then
                        setCooldown( "warrior_of_elune", 45 ) 
                    end
                end

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end                
            end,
        },


        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135730,

            ap_check = function() return check_for_ap_overcap( "starsurge" ) end,   

            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                
                removeBuff( "oneths_intuition" )
                removeBuff( "sunblaze" )

                if buff.eclipse_solar.up then buff.eclipse_solar.expires = buff.eclipse_solar.expires + ( level > 57 and 3 or 2 ) end
                if buff.eclipse_lunar.up then buff.eclipse_lunar.expires = buff.eclipse_lunar.expires + ( level > 57 and 3 or 2 ) end

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if azerite.arcanic_pulsar.enabled then
                    addStack( "arcanic_pulsar" )
                    if buff.arcanic_pulsar.stack == 9 then
                        removeBuff( "arcanic_pulsar" )
                        applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment" )
                    end
                end
            end,
        },


        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",

            ap_check = function() return check_for_ap_overcap( "stellar_flare" ) end,

            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },


        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -2,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",

            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            

            readyTime = function()
                return mana[ "time_to_" .. ( 0.12 * mana.max ) ]
            end,

            handler = function ()
                spend( 0.12 * mana.max, "mana" ) -- I want to see AP in mouseovers.
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
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

            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",            

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },

        -- May want to revisit this and split out swipe_cat from swipe_bear.
        swipe = {
            known = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,

            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { 106785, 213771 }
        },


        thrash = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },


        thorns = {
            id = 236696,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.enabled then return end
                return "thorns"
            end,

            spend = 0.12,
            spendType = "mana",

            startsCombat = false,
            texture = 136104,

            handler = function ()
                applyBuff( "thorns" )
            end,
        },


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },


        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132145,

            handler = function ()
                shift( "treant_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "typhoon",

            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },


        ursols_vortex = {
            id = 102793,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            talent = "restoration_affinity",
            
            startsCombat = true,
            texture = 571588,

            handler = function ()
            end,
        },

        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        wild_charge = {
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 538771,

            talent = "wild_charge",

            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            talent = "wild_growth",

            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },


        wrath = {
            id = 190984,
            cast = function () return haste * ( buff.eclipse_solar.up and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.soul_of_the_forest.enabled and buff.eclipse_solar.up ) and -7.5 or -6 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 535045,

            ap_check = function() return check_for_ap_overcap( "solar_wrath" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if buff.eclipse_solar.down and lunar_eclipse > 0 then
                    lunar_eclipse = lunar_eclipse - 1
                    if lunar_eclipse == 0 then
                        applyBuff( "eclipse_lunar" )
                        if talent.solstice.enabled then applyBuff( "solstice" ) end
                    end
                end
                
                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
            end,

            copy = "solar_wrath"
        },
    } )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 6,

        potion = "unbridled_fury",

        package = "Balance",        
    } )

    
    spec:RegisterSetting( "starlord_cancel", false, {
        name = "Cancel |T462651:0|t Starlord",
        desc = "If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\n" ..
            "You will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat.",
        icon = 462651,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = 1.5
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )    


    spec:RegisterPack( "Balance", 20200829.1, [[dC0x2aqivLEesPUKcPSjI0NuiHrPqDkfXQqkXROcMfr4wQkIDrPFrfzykehJkvlJi6zuHAAkK01qkPTPa03uvKmoQq6CkawNcjY7uvKQ5Pa6Eiv7dP4GkKQfki9qQq0evvu1fvvuPnQqIYhvir1jPcbRubntvfvStQOwQQIuEQQmvbXEj8xHgmKdtAXe1JHAYG6YO2mv9zvvJwqDAjRMke61ujZMIBJKDR0VrmCbwUuphy6IUoiBxr67kqJxvr58uPSEvfMVIA)QSWDriIhSMSWzjhrYrgXrLCaSJmas6Oow8s3cyXlqXU0Fw8wLIfVqvJUyw8cu3mefweI4biqnMfVWzgagLCYP)kddjBXekNaffKrZIS4w9PtGIc7K4jdvM0ryfYIhSMSWzjhrYrgXrLCaSJmassRJ6akEkugM0I3ROCKIx4cgMxHS4bZaS4r7dfQA0fZh6Z3qf8nK2hA0H(Ha5HKCaK4qsoIKJCdVH0(qoYW6(ZGrPBiTp0NCOrhgMHp0Jy0(qHYkL9gs7d9jhYrgw3Fg(qP2)Cgl)HWkGbhkjhc7g2WXu7Fob2BiTp0NCOxrfykVBhA0)G7k5dLTw5HmeIlOaWHgdt2rrEiiaFiODzmdaA72HMQDPYg(qa32u)Sj2BiTp0NCOpnMImLHp0NtnLnUDOxq1vEimzHRSi7H8K(qos2WGSuZHgDt9Vu8MF6hYnc0OWyouyDkFOkpePpKBeOdnizhf5Ha1I5d5iSl3t1Kpubou46pm3hkOlsxPBwXZuGeicr8GzVczsricNDxeI4P4SiR4bigTJYSsjE8QYggweQifolPieXJxv2WWIqfpCxj3LkEYqEVfRXAXwOaXtXzrwXtMBa3UQ9xKcNDSieXJxv2WWIqfpfNfzfp9dqyTvq0t2ms8XaYGClE4UsUlv8(EiziV3I1yTyluWHKEiysAPiK1xnBZc7Q2)dj9qWK0cGwF1SnlSRA)pK0dn(qFpuQgEtlizJr7O3OnB5vLnm8HMNpemjTGKngTJEJ2SnlSRA)p0eXBvkw80paH1wbrpzZiXhdidYTifopQIqepEvzddlcv8WDLCxQ4n(qFpuQgEtli12qAylVQSHHp088HKH8Eli12qAyluWHMCiPh67HKH8ElwJ1ITqbhs6HGjPLIqwF1SnlSRA)pK0dbtslaA9vZ2SWUQ9)qsp04d99qPA4nTGKngTJEJ2SLxv2WWhAE(qWK0cs2y0o6nAZ2SWUQ9)qtepfNfzfVFiTHlDJeFu)GBsgwKcNPvriIhVQSHHfHkEkolYkEy3Wgs2KTWrzJcsXd3vYDPI33djd59wSgRfBHcoK0dbtslfHS(QzBwyx1(FiPhcMKwa06RMTzHDv7)HKEOXh67Hs1WBAbjBmAh9gTzlVQSHHp088HGjPfKSXOD0B0MTzHDv7)HMiES3Z4mUkflEy3Wgs2KTWrzJcsrkCEafHiE8QYggweQ4P4SiR4bcxt5ooLxcvSztHfVvPyXdeUMYDCkVeQyZMclE4UsUlv8(EiziV3I1yTyluWHKEOVhsgY7TYgcb2absluG4LA)ZzS8IhmjTGW1uUJt5LqzbPIDDiAOFiAvKcN)uIqepEvzddlcv8uCwKv8O0T8mijrIpsPWldaIhURK7sfpziV3I1yTyBZuATGdrZHCFKdnpFiziV3I1yTyBZuATGdrZHg1dj9qYqEVvBSUfogazaABbPIDDiAo0aEO55d5R)WzSzkTwWHg4HK0DXBvkw8O0T8mijrIpsPWldaIu4SJkcr84vLnmSiuXd3vYDPIhMqmWKbxlwJ1ITntP1coenhYXJiEkolYkEYgcbos8Xmmh5LPCtKcNhariIhVQSHHfHkE4UsUlv8(EiziV3I1yTyluWHKEOXhsbzRMyazqUp0apKK06HMNpeMqmWKbxlwJ1ITntP1coenhYXJCOjhs6HGjPfaT(QzBZuATGdrZHCFKdj9qWK0sriRVA22mLwl4q0Ci3h5qsp04d99qPA4nTGKngTJEJ2SLxv2WWhAE(qWK0cs2y0o6nAZ2MP0AbhIMd5(ihAI4P4SiR4rXuK2TiXhnq4coc3SsbePWz3hreI4P4SiR4fa1L3TA)JYgfKIhVQSHHfHksHZU7UieXtXzrwXRRGadhRnccumlE8QYggweQifo7UKIqepfNfzfpmzX8MTMmC0Bukw84vLnmSiurkC2Dhlcr84vLnmSiuXd3vYDPINmK3BBg7YWaq0tAmBHcoK0dbtslfHS(QzBwyx1(FiPhcMKwa06RMTzHDv7)HKEOXh67Hs1WBAbjBmAh9gTzlVQSHHp088HGjPfKSXOD0B0MTzHDv7)HMiEkolYkEzyocTYeOfo6jnMfPWz3hvriINIZISI3GK2apLRn2mGS6IzXJxv2WWIqfPWz3PvriIhVQSHHfHkE4UsUlv8gFOVhAQ2LkByR(reao088H(EiziV3I1yTyluWHMCiPhcMKwkcz9vZ2SWUQ9)qspemjTaO1xnBZc7Q2)dj9qJp03dLQH30cs2y0o6nAZwEvzddFO55dbtslizJr7O3OnBZc7Q2)dnr8uCwKv88emeGHJ6hCxjhLzLsKcNDFafHiEkolYkEzysVaXJxv2WWIqfPWz3)uIqepEvzddlcv8WDLCxQ4jd59wSgRfBHco088H81F4m2mLwl4qd8qsoI4P4SiR4bb4yLmfqKcND3rfHiEkolYkEdQDxKos8r2aTS4XRkByyrOIu4S7dGieXJxv2WWIqfpCxj3LkEFpKmK3BXASwSfk4qsp04djd59wkMI0Ufj(ObcxWr4MvkGfk4qZZhA8HgFimHyGjdUwkMI0Ufj(ObcxWr4MvkGTzkTwWHO5qsoYHMNp03dXaaVy2sXuK2TiXhnq4coc3SsbSuQJiPp0Kdj9qAqehMXUo0Kdn5qsp04djd59wkMI0Ufj(ObcxWr4MvkGfk4qZZhsdI4Wm21HMCiPhcMKwa06RMTntP1coenhYrpK0dbtslfHS(QzBZuATGdrZHCxYdj9qJpemjTGKngTJEJ2STzkTwWHO5qd4HMNp03dLQH30cs2y0o6nAZwEvzddFOjINIZISIxTyTxnlYksHZsoIieXJxv2WWIqfpCxj3LkEFpKmK3BXASwSfk4qsp04djd59wkMI0Ufj(ObcxWr4MvkGfk4qZZhA8HgFimHyGjdUwkMI0Ufj(ObcxWr4MvkGTzkTwWHO5qsoYHMNp03dXaaVy2sXuK2TiXhnq4coc3SsbSuQJiPp0Kdj9qAqehMXUo0Kdn5qsp04dbtslaA9vZ2MP0AbhIMdj5HKEiysAPiK1xnBZc7Q2)dj9qJpemjTGKngTJEJ2SnlSRA)p088H(EOun8MwqYgJ2rVrB2YRkBy4dn5qtepfNfzfpmByqwQjQM6FP4nfPWzjDxeI4P4SiR4XubKb5oktwyXJxv2WWIqfPWzjLueI4P4SiR416uEjqGOV59d3epEvzddlcvKcNL0XIqepEvzddlcv8WDLCxQ4n(qYqEVfRXAXwOGdnpFimHyGjdUwSgRfBBMsRfCiAoKJh5qtoK0dnyRzyRgeXHzSlXtXzrwXZd1Ufj(iBGwwKcNLCufHiE8QYggweQ4H7k5UuXB8HKH8ElwJ1ITqbhAE(qycXatgCTynwl22mLwl4q0CihpYHMCiPhsdI4Wm2L4P4SiR45jnMJeFC1eQzrkCwsAveI4XRkByyrOIhURK7sfpziV3csTnKg22mLwl4qd8qo(qsp03dnyRzyRgeXHzSlXtXzrwXdRlMnrziVx8KH8(4QuS4bsTnKgwKcNLCafHiE8QYggweQ4H7k5UuXB8H(EObBndB1GiomJDDO55dn(qYqEVfKABinSfKk21Hg4HC8HMNpKmK3BbP2gsdBBMsRfCiAOFih9qtoK0dn(q(6pCgBMsRfCihoK7hAYHOLdbcyJjMA)Zj4q0CimbKhA0oKKwA9qtoK0dbcyJjMA)Zj4q0q)qt1UuzdBb(yQ9pNaXtXzrwXdKA7vJrKcNL8tjcr84vLnmSiuXd3vYDPINIZAkh5LPkgCObEOPAxQSHTaFm1(NtWHKEOXhsgY7Tm2ubaocigTTntP1coenhcRGmMffFO55djd59wgBQaahnqR22MP0AbhIMdHvqgZIIp0eXtXzrwXdKAdG6FwKcNL0rfHiE8QYggweQ4H7k5UuXtgY7Tynwl2cfCiPhsgY7Tynwl22mLwl4qd8q)yylL(zhs6H0p4Us2cYMvx1(hbP2aBRRRdj9qWK0sriRVA22mLwl4q0COMP0AbINIZISIhaA9vZIu4SKdGieXJxv2WWIqfpCxj3LkEYqEVfRXAXwOGdj9qYqEVfRXAX2MP0AbhAGh6hdBP0p7qspK(b3vYwq2S6Q2)ii1gyBDDjEkolYkEueY6RMfPWzhpIieXJxv2WWIqfpfNfzfpa06RMfpCxj3LkEn7BgewLn8HKEiniIdZyxhs6H8gcPp04dLA)ZPnlkoMKiCXhA0o04dj5HOLdbcyJjgwbjFOjhAYHOLdbcyJjMA)Zj4q0q)qyUmhA8H8gcPp04dj5HgTdbcyJjMA)Zj4qtoeTCi3T06HMCihoKKhIwoeiGnMyQ9pNGdj9qJpeiGnMyQ9pNGdrZHC)qoCOun8M2CWAJueYcS8QYgg(qZZhcMKwkcz9vZ2SWUQ9)qtoK0dn(qFpK(b3vYwq2S6Q2)ii1gyBDDDO55d99qYqEVfRXAXwOGdnpFOVhkO5Pwa06RMp0Kdj9qJpKmK3BXASwSTzkTwWHO5qntP1co088H(EiziV3I1yTyluWHMiEy3WgoMA)Zjq4S7Iu4SJDxeI4XRkByyrOINIZISIhfHS(QzXd3vYDPIxZ(MbHvzdFiPhsdI4Wm21HKEiVHq6dn(qP2)CAZIIJjjcx8HgTdn(qsEiA5qGa2yIHvqYhAYHMCiA5qGa2yIP2)Ccoen0p0aEiPhA8H(Ei9dURKTGSz1vT)rqQnW2666qZZh67HKH8ElwJ1ITqbhAE(qFpuqZtTueY6RMp0Kdj9qJpKmK3BXASwSTzkTwWHO5qntP1co088H(EiziV3I1yTyluWHMiEy3WgoMA)Zjq4S7Iu4SJLueI4XRkByyrOINIZISIhizJr7O3OnlE4UsUlv8A23miSkB4dj9qAqehMXUoK0d5nesFOXhk1(NtBwuCmjr4Ip0ODOXhsYdrlhceWgtmScs(qto0Kdrd9drRhs6HgFOVhs)G7kzliBwDv7FeKAdSTUUo088H(EiziV3I1yTyluWHMNp03df08ulizJr7O3OnFOjIh2nSHJP2)Cceo7Uifo7yhlcr8uCwKv8WKDkXfhZWCeeuDLaXJxv2WWIqfPWzhpQIqepEvzddlcv8WDLCxQ4PbrCyg7s8uCwKv8wEWifHSIu4SJPvriIhVQSHHfHkE4UsUlv80GiomJDjEkolYkEHvJpsriRifo74bueI4XRkByyrOIhURK7sfpniIdZyxINIZISINhYyIueYksHZo(tjcr84vLnmSiuXd3vYDPINmK3BzSPcaC0aTABBMsRfCiAoewbzmlk(qZZhcqmAhzSPca8HO5qJiEkolYkEGuBF1Sifo7yhveI4XRkByyrOIhURK7sfpziV3Yytfa4iGy022mLwl4q0CiScYywu8HMNpKbA1oYytfa4drZHgr8uCwKv8gS1mSifo74bqeI4P4SiR4bGwF1S4XRkByyrOIuKIxqZycLSMIqeo7UieXJxv2WWIqfpsG4b4u8uCwKv8MQDPYgw8MQgiw8gvXBQ2XvPyXd4JP2)CcePWzjfHiE8QYggweQ4rcepfgw8uCwKv8MQDPYgw8MQgiw8Cx8WDLCxQ4PFWDLSvBSUfogazaAB5vLnmS4nv74QuS4b8Xu7FobIu4SJfHiE8QYggweQ4rcepfgw8uCwKv8MQDPYgw8MQgiw8Cx8WDLCxQ4LQH30csTnKg2YRkByyXBQ2XvPyXd4JP2)CcePW5rveI4XRkByyrOIhjq8uyyXtXzrwXBQ2LkByXBQAGyXZDXd3vYDPIN(b3vYwq2S6Q2)ii1gyBDDDiAoKKhs6H0p4Us2Qnw3chdGmaTT8QYggw8MQDCvkw8a(yQ9pNarkCMwfHiE8QYggweQ4rcepaKS4P4SiR4nv7sLnS4nvnqS45U4H7k5UuX77Hs1WBAZbRnsrilWYRkByyXBQ2XvPyXd4JP2)CcePW5bueI4P4SiR4rriRRAJEstjE8QYggweQifo)PeHiEkolYkEUQfUz4iiO6kbIhVQSHHfHksHZoQieXJxv2WWIqfVvPyXt)aewBfe9KnJeFmGmi3INIZISIN(biS2ki6jBgj(yazqUfPW5bqeI4XRkByyrOINIZISIxajlYkEWUTkvHJbnhqsXZDrkC29reHiEkolYkEd2Agw84vLnmSiurkC2D3fHiEkolYkEGuBau)ZIhVQSHHfHksrksXBk3GIScNLCejhzehvYbq8gu7T2FG45iqfq6KHpKKhsXzr2dzkqcS3qXlOj(YWIhTpuOQrxmFOpFdvW3qAFOrh6hcKhsYbqIdj5isoYn8gs7d5idR7pdgLUH0(qFYHgDyyg(qpIr7dfkRu2BiTp0NCihzyD)z4dLA)ZzS8hcRagCOKCiSBydhtT)5eyVH0(qFYHEfvGP8UDOr)dURKpu2ALhYqiUGcahAmmzhf5HGa8HG2LXmaOTBhAQ2LkB4dbCBt9ZMyVH0(qFYH(0ykYug(qFo1u242HEbvx5HWKfUYIShYt6d5izddYsnhA0n1)sXB(PFi3iqJcJ5qH1P8HQ8qK(qUrGo0GKDuKhculMpKJWUCpvt(qf4qHR)WCFOGUiDLUzVH3qAFOp3pJXqjdFiz2tA(qycLSMhsM)Rfyp0OJXCqco0s2pjS2uEiZHuCwKfCiYACZEdP9HuCwKfydAgtOK1KU3Oax3qAFifNfzb2GMXekznDGUtEcb(gs7dP4SilWg0mMqjRPd0DsH(P4n1Si7n8gs7dn6FWDL8HMQDPYggCdP9HuCwKfydAgtOK10b6onv7sLnSeRsX01pIaGetvdetx)G7kzliBwDv7FeKAdSTUUUH0(qkolYcSbnJjuYA6aDNMQDPYgwIvPy66hrnqIPQbIPRFWDLSvBSUfogazaABBDDDdVH0(qVuBVAmhA6HEP2aO(NpuQ9pNhcdLeV)gQ4SilWg0mMqjRj9PAxQSHLyvkMoWhtT)5eiXu1aX0h1BOIZISaBqZycLSMoq3PPAxQSHLyvkMoWhtT)5eibjGUcdlXu1aX0DxIYtx)G7kzR2yDlCmaYa02YRkBy4BOIZISaBqZycLSMoq3PPAxQSHLyvkMoWhtT)5eibjGUcdlXu1aX0DxIYtpvdVPfKABinSLxv2WW3qfNfzb2GMXekznDGUtt1UuzdlXQumDGpMA)ZjqcsaDfgwIPQbIP7UeLNU(b3vYwq2S6Q2)ii1gyBDDrJKs1p4Us2Qnw3chdGmaTT8QYgg(gQ4SilWg0mMqjRPd0DAQ2LkByjwLIPd8Xu7FobsqcOdGKLyQAGy6Ulr5P)nvdVPnhS2ifHSalVQSHHVHkolYcSbnJjuYA6aDNOiK1vTrpPPUH3qAFO3QbGWK8qTwWhsgY7z4dbsnbhsM9KMpeMqjR5HK5)Abhsx4df08NeqYS2)dvGdbtw2EdP9HuCwKfydAgtOK10b6obwnaeMKrqQj4gQ4SilWg0mMqjRPd0DYvTWndhbbvxj4gQ4SilWg0mMqjRPd0DccWXkzkjwLIPRFacRTcIEYMrIpgqgK7BOIZISaBqZycLSMoq3PaswKvcy3wLQWXGMdijD3VHkolYcSbnJjuYA6aDNgS1m8nuXzrwGnOzmHswthO7ei1ga1)8n8gs7d95(zmgkz4dXt52TdLffFOmmFifNK(qf4q6uTmQSHT3qfNfzb0beJ2rzwPUH0(qoYpp4gQ4SilWb6ojZnGBx1(lr5Pld59wSgRfBHcUHkolYcCGUtqaowjtjXQumD9dqyTvq0t2ms8XaYGClr5P)vgY7Tynwl2cfifMKwkcz9vZ2SWUQ9xkmjTaO1xnBZc7Q2FPJ)MQH30cs2y0o6nAZwEvzddppdtslizJr7O3OnBZc7Q2)j3qfNfzboq3PFiTHlDJeFu)GBsgwIYtF83un8MwqQTH0WwEvzddppld59wqQTH0WwOGjs)kd59wSgRfBHcKctslfHS(QzBwyx1(lfMKwa06RMTzHDv7V0XFt1WBAbjBmAh9gTzlVQSHHNNHjPfKSXOD0B0MTzHDv7)KBOIZISahO7eeGJvYusWEpJZ4QumDSBydjBYw4OSrbPeLN(xziV3I1yTyluGuysAPiK1xnBZc7Q2FPWK0cGwF1SnlSRA)Lo(BQgEtlizJr7O3OnB5vLnm88mmjTGKngTJEJ2SnlSRA)NCdvCwKf4aDNGaCSsMsIvPy6GW1uUJt5LqfB2uyjkp9VYqEVfRXAXwOaPFLH8ERSHqGnqG0cfirQ9pNXYthMKwq4Ak3XP8sOSGuXUOHoTEdvCwKf4aDNGaCSsMsIvPy6u6wEgKKiXhPu4LbajkpDziV3I1yTyBZuATaACFK5zziV3I1yTyBZuATaAgvPYqEVvBSUfogazaABbPIDrZaop7R)WzSzkTwWaL09BOIZISahO7KSHqGJeFmdZrEzk3KO80XeIbMm4AXASwSTzkTwanoEKBOIZISahO7eftrA3IeF0aHl4iCZkfqIYt)RmK3BXASwSfkq6yfKTAIbKb5EGssRZZycXatgCTynwl22mLwlGghpYePWK0cGwF1STzkTwanUpIuysAPiK1xnBBMsRfqJ7JiD83un8MwqYgJ2rVrB2YRkBy45zysAbjBmAh9gTzBZuATaACFKj3qfNfzboq3PaOU8Uv7Fu2OG8gQ4SilWb6o1vqGHJ1gbbkMVHkolYcCGUtyYI5nBnz4O3Ou8nuXzrwGd0DkdZrOvMaTWrpPXSeLNUmK3BBg7YWaq0tAmBHcKctslfHS(QzBwyx1(lfMKwa06RMTzHDv7V0XFt1WBAbjBmAh9gTzlVQSHHNNHjPfKSXOD0B0MTzHDv7)KBOIZISahO70GK2apLRn2mGS6I5BOIZISahO7KNGHamCu)G7k5OmRusuE6J)ov7sLnSv)icaZZFLH8ElwJ1ITqbtKctslfHS(QzBwyx1(lfMKwa06RMTzHDv7V0XFt1WBAbjBmAh9gTzlVQSHHNNHjPfKSXOD0B0MTzHDv7)KBOIZISahO7ugM0l4gQ4SilWb6obb4yLmfqIYtxgY7Tynwl2cfmp7R)WzSzkTwWaLCKBOIZISahO70GA3fPJeFKnqlFdP9HuCwKf4aDNQD5EQMSeLNU(b3vYwtnLnUfbbvxPLxv2WWshJjedmzW1wlw7vZIS2MP0AbduY5zmHyGjdUwmByqwQjQM6FP4nTntP1cgO7so5gQ4SilWb6ovlw7vZISsuE6FLH8ElwJ1ITqbshld59wkMI0Ufj(ObcxWr4MvkGfkyEE8ymHyGjdUwkMI0Ufj(ObcxWr4MvkGTzkTwansoY88xga4fZwkMI0Ufj(ObcxWr4MvkGLsDej9ePAqehMXUMmr6yziV3sXuK2TiXhnq4coc3SsbSqbZZAqehMXUMifMKwa06RMTntP1cOXrLctslfHS(QzBZuATaACxsPJHjPfKSXOD0B0MTntP1cOzaNN)MQH30cs2y0o6nAZwEvzddp5gQ4SilWb6oHzddYsnr1u)lfVPeLN(xziV3I1yTyluG0XYqEVLIPiTBrIpAGWfCeUzLcyHcMNhpgtigyYGRLIPiTBrIpAGWfCeUzLcyBMsRfqJKJmp)LbaEXSLIPiTBrIpAGWfCeUzLcyPuhrsprQgeXHzSRjtKogMKwa06RMTntP1cOrsPWK0sriRVA2Mf2vT)shdtslizJr7O3OnBZc7Q2)55VPA4nTGKngTJEJ2SLxv2WWtMCdvCwKf4aDNyQaYGChLjl8nuXzrwGd0DQ1P8sGarFZ7hUDdvCwKf4aDN8qTBrIpYgOLLO80hld59wSgRfBHcMNXeIbMm4AXASwSTzkTwanoEKjshS1mSvdI4Wm21nuXzrwGd0DYtAmhj(4QjuZsuE6JLH8ElwJ1ITqbZZycXatgCTynwl22mLwlGghpYePAqehMXUUH3qAFOxaVWCdUHkolYcCGUtyDXSjkd59sSkfthKABinSeLNUmK3BbP2gsdBBMsRfmqhl97GTMHTAqehMXUUHkolYcCGUtGuBVAmsuE6J)oyRzyRgeXHzSR55XYqEVfKABinSfKk21aD88SmK3BbP2gsdBBMsRfqdDhDI0X(6pCgBMsRf4G7tOfqaBmXu7Fob0GjGC0K0sRtKccyJjMA)ZjGg6t1UuzdBb(yQ9pNGBiTpKIZISahO7ei1ga1)SeLN(4XPA4nTGuBdPHT8QYggw6yziV3csTnKg2csf7AGoEEwgY7TGuBdPHTntP1cOHoTkvgY7TAJ1TWXaidqBlivSRb6OtMN)MQH30csTnKg2YRkByyPJLH8ER2yDlCmaYa02csf7AGo68SmK3BXASwSfkyYePJLH8ElJnvaGJaIrBluGuziV3Yytfa4ObA12cfmrQmK3BBg7YWaq0tAmhXeOn52csf7AGUpaZZYqEVTzSlddarpPXSfkyIuqaBmXu7FobwqQTxnMbov7sLnSf4JP2)CcKo(7uTlv2Ww9Jiamp)vgY7Tynwl2cfmp)nO5PwqQnaQ)5jZZ(6pCgBMsRfmq68NXyOKJzrX0IcYwnXaYGCpAJ6iZZFhS1mSvdI4Wm21nuXzrwGd0DcKAdG6FwIYtxXznLJ8Yufdg4uTlv2WwGpMA)Zjq6yziV3Yytfa4iGy022mLwlGgScYywu88SmK3BzSPcaC0aTABBMsRfqdwbzmlkEYnuXzrwGd0DcaT(QzjkpDziV3I1yTyluGuziV3I1yTyBZuATGb(JHTu6Njv)G7kzliBwDv7FeKAdSTUUKctslfHS(QzBZuATaAAMsRfCdvCwKf4aDNOiK1xnlr5Pld59wSgRfBHcKkd59wSgRfBBMsRfmWFmSLs)mP6hCxjBbzZQRA)JGuBGT111n8gs7d95jHaUHkolYcCGUtaO1xnlb2nSHJP2)CcO7UeLNEZ(MbHvzdlvdI4Wm2LuVHq6XP2)CAZIIJjjcx8OnwsAbeWgtmScsEYeAbeWgtm1(Ntan0XCzg7nespwYrdeWgtm1(NtWeAXDlToXbjPfqaBmXu7FobshdcyJjMA)ZjGg3DivdVPnhS2ifHSalVQSHHNNHjPLIqwF1SnlSRA)NiD8x9dURKTGSz1vT)rqQnW266AE(RmK3BXASwSfkyE(BqZtTaO1xnpr6yziV3I1yTyBZuATaAAMsRfmp)vgY7Tynwl2cfm5gQ4SilWb6orriRVAwcSBydhtT)5eq3Djkp9M9ndcRYgwQgeXHzSlPEdH0JtT)50MffhtseU4rBSK0ciGnMyyfK8Kj0ciGnMyQ9pNaAOpGsh)v)G7kzliBwDv7FeKAdSTUUMN)kd59wSgRfBHcMN)g08ulfHS(Q5jshld59wSgRfBBMsRfqtZuATG55VYqEVfRXAXwOGj3qfNfzboq3jqYgJ2rVrBwcSBydhtT)5eq3Djkp9M9ndcRYgwQgeXHzSlPEdH0JtT)50MffhtseU4rBSK0ciGnMyyfK8Kj0qNwLo(R(b3vYwq2S6Q2)ii1gyBDDnp)vgY7Tynwl2cfmp)nO5PwqYgJ2rVrBEYn8gs7dnkNxU1K0GBOIZISahO7eMStjU4ygMJGGQReCdvCwKf4aDNwEWifHSsuE6AqehMXUUHkolYcCGUtHvJpsriReLNUgeXHzSRBOIZISahO7KhYyIueYkr5PRbrCyg76gQ4SilWb6obsT9vZsuE6YqEVLXMkaWrd0QTTzkTwanyfKXSO45zaXODKXMkaW0mYnuXzrwGd0DAWwZWsuE6YqEVLXMkaWraXOTTzkTwanyfKXSO45zd0QDKXMkaW0mYn8gs7dnktnMmCdDipPpefzktXBEdvCwKf4aDNaqRVAw8abmw4S7JiPifPqaa]] )


end