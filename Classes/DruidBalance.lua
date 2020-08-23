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
            charges = 1,
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
                -- TODO: Apply buff and related effects from HotW.
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
                return talent.soul_of_the_forest.enabled and 40 or 50
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
                    if solar_eclipse == 0 then applyBuff( "eclipse_solar" ) end
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

            spend = -6,
            spendType = "astral_power",

            startsCombat = true,
            texture = 535045,

            ap_check = function() return check_for_ap_overcap( "solar_wrath" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if buff.eclipse_solar.down and lunar_eclipse > 0 then
                    lunar_eclipse = lunar_eclipse - 1
                    if lunar_eclipse == 0 then applyBuff( "eclipse_lunar" ) end
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


    spec:RegisterPack( "Balance", 20200823, [[dCeo1aqifPhHuYLua1MOcFsbeJsrCkfQvHukVIkYSqQ6wkKYUO0VqQmmfOJHIAzOipJkktJkQ6AauTnfG(gsPIXPa4CkKkRtbKEhaL08ui5EOW(qkoivuXcfKEisPQjIuQ0fbOeBKkQu9rQOs5KauQvQGMPcPk7KkvlvHuvpvvMQGyVu8xHgmKdtAXO0JHAYi5YeBMQ(mGgTG60swnvujVMkz2O62aTBL(nIHlWYL65GMUORRQ2oa(UcX4bO48uPSEaY8vu7xLnmBcX8O0umUZ0Gmn4GdatoZYmtoZzdoaMx6wGyEbk2LcumVvbfZluLRlwmVa1norPmHyEqYVXI5foZa4aLo6awz4pRftaPdwGFUMfzXT6t6GfiMoZJ9x8eWEnSMhLMIXDMgKPbhCayYzwMzIPbbCMnp9NHjT59kqAV5fUOOK1WAEuceBE06qHQCDXYHOD7FrDdP1HcNzaCGshDaRm8N1IjG0blWpxZIS4w9jDWcet3nKwhA4FLdXSZt)HyAqMg8gEdP1HO9H1fOahO3qADOr7qohkkH6qpcx7dfQOG2BiTo0ODiAFyDbkuhk1gOKXYFiScf4HsYHWUH5sm1gOKq7nKwhA0o0Rad4L3Td5CaK0vkhkBTYdXjex)a4HMqr2bsEOpuo0FxblqO2UDia0UuwUCiOBBQaMX2BiTo0ODOrFbKaGqDOrVcaH72HEbvx5HWKLQYIShYt6dr7fUaZs5hY5WlGlOSjG1d5g5pq48dfwbqouLhI0hYnY)qJq2bsEiyTy5qa27knaAkhQGhkCbmS0hkOlsxPBwZJxWeAcX8OeV(5PjeJ7mBcX8uCwK18GeU2rwrbnpzvwUqzc1Kg3zYeI5jRYYfktOMhURu6snp2V3BXASwS9hyEkolYAESsdL2vTanPXDNzcX8Kvz5cLjuZtXzrwZtbemS2km6jBgj(yazePnpCxP0LAEtpe737Tynwl2(doKJdrrsliHS(QfBwyx1c8qooefjTW)6RwSzHDvlWd54qto00dLkx20ctHZ1o65AlwzvwUqDO55drrslmfox7ONRTyZc7QwGhAS5TkOyEkGGH1wHrpzZiXhdiJiTjnU78MqmpzvwUqzc18WDLsxQ5n5qtpuQCztlm1MtAkRSklxOo088Hy)EVfMAZjnL9hCOXhYXHMEi2V3BXASwS9hCihhIIKwqcz9vl2SWUQf4HCCiksAH)1xTyZc7QwGhYXHMCOPhkvUSPfMcNRD0Z1wSYQSCH6qZZhIIKwykCU2rpxBXMf2vTap0yZtXzrwZd4xBQs3iXhvajnjdBsJ7aUjeZtwLLluMqnpCxP0LAEtpe737Tynwl2(doKJdrrsliHS(QfBwyx1c8qooefjTW)6RwSzHDvlWd54qto00dLkx20ctHZ1o65AlwzvwUqDO55drrslmfox7ONRTyZc7QwGhAS5P4SiR5HDdZjzt2chz5kmnpX7fCgxfumpSByojBYw4ilxHPjnUpGMqmpzvwUqzc18uCwK18GHlaKocGSeWyl8cBERckMhmCbG0raKLagBHxyZd3vkDPM30dX(9ElwJ1IT)Gd54qtpe737TSCcHI)HP9hyEP2aLmwEZJIKwy4caPJailb0ctf76q0W4qaUjnUt7ycX8Kvz5cLjuZtXzrwZdu3YlWKej(iOsTceAE4UsPl18y)EVfRXAX2wa1AHhIMdX8GhAE(qSFV3I1yTyBlGATWdrZHC(d54qSFV3Qnw3chd(CO2wyQyxhIMdnGhAE(q(cy4m2cOwl8qJ6qmXS5TkOyEG6wEbMKiXhbvQvGqtACFamHyEYQSCHYeQ5H7kLUuZdtiCkYiRfRXAX2wa1AHhIMd5SbnpfNfznpwoHqfj(ygwIYkGUzsJ7JotiMNSklxOmHAE4UsPl18MEi2V3BXASwS9hCihhAYHuy2kpgqgr6dnQdXeGFO55dHjeofzK1I1yTyBlGATWdrZHC2GhA8HCCiksAH)1xTyBbuRfEiAoeZdEihhIIKwqcz9vl2wa1AHhIMdX8GhYXHMCOPhkvUSPfMcNRD0Z1wSYQSCH6qZZhIIKwykCU2rpxBX2cOwl8q0CiMh8qJnpfNfznpqbK0Ufj(i)JlQivlki0Kg3zEqtiMNIZISMxWVlVB1cmYYvyAEYQSCHYeQjnUZmZMqmpfNfznVUcc4sS2imqXI5jRYYfktOM04oZmzcX8uCwK18WKflB2AkurpxbfZtwLLluMqnPXDMDMjeZtwLLluMqnpCxP0LAESFV32c2fxGWON0yX(doKJdrrsliHS(QfBwyx1c8qooefjTW)6RwSzHDvlWd54qto00dLkx20ctHZ1o65AlwzvwUqDO55drrslmfox7ONRTyZc7QwGhAS5P4SiR5LHL4Fzj)Lk6jnwmPXDMDEtiMNIZISM3iKMtbGuBSfiz1flMNSklxOmHAsJ7md4MqmpzvwUqzc18WDLsxQ5n5qtpeaAxklxSkGIq4HMNp00dX(9ElwJ1IT)Gdn(qooefjTGeY6RwSzHDvlWd54quK0c)RVAXMf2vTapKJdn5qtpuQCztlmfox7ONRTyLvz5c1HMNpefjTWu4CTJEU2InlSRAbEOXMNIZISMNNG)qHkQas6kLiROGM04oZdOjeZtXzrwZldt6fAEYQSCHYeQjnUZmTJjeZtwLLluMqnpCxP0LAESFV3I1yTy7p4qZZhYxadNXwa1AHhAuhIPbnpfNfznVpuIvkGqtACN5bWeI5P4SiR5nI2Dr6iXhf(FfZtwLLluMqnPXDMhDMqmpzvwUqzc18WDLsxQ5n9qSFV3I1yTy7p4qoo0KdX(9ElOasA3IeFK)XfvKQffeA)bhAE(qto0KdHjeofzK1ckGK2TiXh5FCrfPArbH2wa1AHhIMdX0GhAE(qtpKaHYIflOasA3IeFK)XfvKQffeAbvNlsFOXhYXH0GioSGDDOXhA8HCCOjhI979wqbK0Ufj(i)JlQivlki0(do088H0GioSGDDOXhYXHOiPf(xF1ITfqTw4HO5qdWHCCiksAbjK1xTyBbuRfEiAoeZmDihhAYHOiPfMcNRD0Z1wSTaQ1cpenhAap088HMEOu5YMwykCU2rpxBXkRYYfQdn28uCwK18QfR9QzrwtACNPbnHyEYQSCHYeQ5H7kLUuZB6Hy)EVfRXAX2FWHCCOjhI979wqbK0Ufj(i)JlQivlki0(do088HMCOjhctiCkYiRfuajTBrIpY)4Iks1IccTTaQ1cpenhIPbp088HMEibcLflwqbK0Ufj(i)JlQivlki0cQoxK(qJpKJdPbrCyb76qJp04d54qtoefjTW)6RwSTaQ1cpenhIPd54quK0csiRVAXMf2vTapKJdn5quK0ctHZ1o65Al2SWUQf4HMNp00dLkx20ctHZ1o65AlwzvwUqDOXhAS5P4SiR5HfUaZs5rLxaxqzttACNjMnHyEYQSCHYeQ5H7kLUuZBYHy)EVfRXAX2FWHMNpeMq4uKrwlwJ1ITTaQ1cpenhYzdEOXhYXHgP1mSvdI4Wc2L5P4SiR55)TBrIpk8)kM04otmzcX8Kvz5cLjuZd3vkDPM3KdX(9ElwJ1IT)GdnpFimHWPiJSwSgRfBBbuRfEiAoKZg8qJpKJdPbrCyb7Y8uCwK188KglrIpUA(BXKg3zYzMqmp2V3hxfumpyQnN0uMNSklxOmHAEkolYAEyDXcpY(9EZd3vkDPMh737TWuBoPPSTaQ1cp0OoKZoKJdn9qJ0Ag2QbrCyb7YKg3zY5nHyEYQSCHYeQ5H7kLUuZBYHMEOrAndB1GioSGDDO55dn5qSFV3ctT5KMYctf76qJ6qo7qZZhI979wyQnN0u2wa1AHhIgghAao04d54qtoKVagoJTaQ1cpKthI5dn(q02HGbcNhtTbkj8q0CimbMhAGpetwa)qJpKJdbdeopMAdus4HOHXHaq7sz5If6JP2aLeAEkolYAEWuBVY5M04otaUjeZtwLLluMqnpCxP0LAESFV3kyEfaLiKW122cOwl8q0CiScZywGYHMNpe737TcMxbqjY)R22wa1AHhIMdHvygZcumpfNfznpyQn83aftACNPb0eI5jRYYfktOMhURu6snp2V3BXASwS9hCihhI979wSgRfBBbuRfEOrDiGyklOcyoKJdPas6kflmBrDvlWim1gABDDDihhIIKwqcz9vl2wa1AHhIMd1cOwl08uCwK18G)1xTysJ7mr7ycX8Kvz5cLjuZd3vkDPMh737Tynwl2(doKJdX(9ElwJ1ITTaQ1cp0OoeqmLfubmhYXHuajDLIfMTOUQfyeMAdTTUUmpfNfznpqcz9vlM04otdGjeZtwLLluMqnpCxP0LAET4Bbgwz5YHCCiniIdlyxhYXH8CcPp0KdLAdusBwGsmjrQso0aFOjhIPdrBhcgiCEmSct5qJp04drBhcgiCEm1gOKWdrdJdHLIFOjhYZjK(qtoethAGpemq48yQnqjHhA8HOTdXSfWp04d50Hy6q02HGbcNhtTbkj8qoo0KdbdeopMAdus4HO5qmFiNouQCztBosTrqczHwzvwUqDO55drrsliHS(QfBwyx1c8qJpKJdn5qtpKciPRuSWSf1vTaJWuBOT111HMNp00dX(9ElwJ1IT)GdnpFOPhkOfaSW)6Rwo04d54qtoe737Tynwl22cOwl8q0COwa1AHhAE(qtpe737Tynwl2(do0yZtXzrwZd(xF1I5HDdZLyQnqjHg3z2Kg3zA0zcX8Kvz5cLjuZd3vkDPMxl(wGHvwUCihhsdI4Wc21HCCipNq6dn5qP2aL0MfOetsKQKdnWhAYHy6q02HGbcNhdRWuo04dn(q02HGbcNhtTbkj8q0W4qd4HCCOjhA6HuajDLIfMTOUQfyeMAdTTUUo088HMEi2V3BXASwS9hCO55dn9qbTaGfKqwF1YHgFihhAYHy)EVfRXAX2wa1AHhIMd1cOwl8qZZhA6Hy)EVfRXAX2FWHgBEkolYAEGeY6RwmpSByUetTbkj04oZM04UZg0eI5jRYYfktOMhURu6snVw8TadRSC5qooKgeXHfSRd54qEoH0hAYHsTbkPnlqjMKivjhAGp0KdX0HOTdbdeopgwHPCOXhA8HOHXHa8d54qto00dPas6kflmBrDvlWim1gABDDDO55dn9qSFV3I1yTy7p4qZZhA6HcAbalmfox7ONRTCOXMNIZISMhmfox7ONRTyEy3WCjMAdusOXDMnPXDNXSjeZtwLLluMqnpCxP0LAEAqehwWUmpfNfznVvgjcsiRjnU7mMmHyEYQSCHYeQ5H7kLUuZtdI4Wc2L5P4SiR5fw5(iiHSM04UZCMjeZtwLLluMqnpCxP0LAEAqehwWUmpfNfznp)NZJGeYAsJ7oZ5nHyEYQSCHYeQ5H7kLUuZJ979wbZRaOe5)vBBlGATWdrZHWkmJzbkhAE(qqcx7OG5vauoenhAqZtXzrwZdMA7RwmPXDNb4MqmpzvwUqzc18WDLsxQ5X(9ERG5vauIqcxBBlGATWdrZHWkmJzbkhAE(q8)QDuW8kakhIMdnO5P4SiR5nsRzytAC3zdOjeZtXzrwZd(xF1I5jRYYfktOM0KMxqlyciRMMqmUZSjeZtwLLluMqnpsG5bL08uCwK18aq7sz5I5bGY)I558MhaAhxfumpOpMAdusOjnUZKjeZtwLLluMqnpsG5PuuMNIZISMhaAxklxmpau(xmpMnpa0oUkOyEqFm1gOKqZd3vkDPMNciPRuSAJ1TWXGphQTvwLLluM04UZmHyEYQSCHYeQ5rcmpLIY8uCwK18aq7sz5I5bGY)I5XS5bG2XvbfZd6JP2aLeAE4UsPl18sLlBAHP2CstzLvz5cLjnU78MqmpzvwUqzc18ibMNsrzEkolYAEaODPSCX8aq5FX8y28aq74QGI5b9XuBGscnpCxP0LAEkGKUsXcZwux1cmctTH2wxxhIMdX0HCCifqsxPy1gRBHJbFouBRSklxOmPXDa3eI5jRYYfktOMhjW8GFwZtXzrwZdaTlLLlMhak)lMhZMhaAhxfumpOpMAdusO5H7kLUuZB6HsLlBAZrQncsil0kRYYfktACFanHyEkolYAEGeY6Q2ON0GMNSklxOmHAsJ70oMqmpzvwUqzc18wfumpfqWWARWONSzK4JbKrK28uCwK18uabdRTcJEYMrIpgqgrAtACFamHyEYQSCHYeQ5P4SiR5fqYISMhLBRcw4yqlbK08y2Kg3hDMqmpfNfznVrAndBEYQSCHYeQjnUZ8GMqmpfNfznpyQn83afZtwLLluMqnPjnP5bG0WISg3zAqMgCWbKzN38gr7TwGqZdWgmG0PqDiMoKIZIShIxWeAVHMhmqWg3zEqMmVGM4lUyE06qHQCDXYHOD7FrDdP1HcNzaCGshDaRm8N1IjG0blWpxZIS4w9jDWcet3nKwhA4FLdXSZt)HyAqMg8gEdP1HO9H1fOahO3qADOr7qohkkH6qpcx7dfQOG2BiTo0ODiAFyDbkuhk1gOKXYFiScf4HsYHWUH5sm1gOKq7nKwhA0o0Rad4L3Td5CaK0vkhkBTYdXjex)a4HMqr2bsEOpuo0FxblqO2UDia0UuwUCiOBBQaMX2BiTo0ODOrFbKaGqDOrVcaH72HEbvx5HWKLQYIShYt6dr7fUaZs5hY5WlGlOSjG1d5g5pq48dfwbqouLhI0hYnY)qJq2bsEiyTy5qa27knaAkhQGhkCbmS0hkOlsxPB2B4nKwhcWcGrW)uOoeR4jTCimbKvZdXkaRfApKZbJLGeEOLSJwyTb9F(HuCwKfEiYYDZEdP1HuCwKfAdAbtaz1KHNRqx3qADifNfzH2GwWeqwnDIbDEcH6gsRdP4Sil0g0cMaYQPtmOt)abLn1Si7n8gsRd5CaK0vkhcaTlLLlWBiToKIZISqBqlyciRMoXGoa0UuwUq)QGcdfqriKEau(xyOas6kflmBrDvlWim1gABDDDdP1HuCwKfAdAbtaz10jg0bG2LYYf6xfuyOakQb0dGY)cdfqsxPy1gRBHJbFouBBRRRB4nKwh6LA7vo)qaCOxQn83aLdLAduYdH)jX7VHkolYcTbTGjGSAYaaTlLLl0VkOWa6JP2aLespak)lmC(BOIZISqBqlyciRMoXGoa0UuwUq)QGcdOpMAdusi9Kagkff9aO8VWGz6lpdfqsxPy1gRBHJbFouBRSklxOUHkolYcTbTGjGSA6ed6aq7sz5c9RckmG(yQnqjH0tcyOuu0dGY)cdMPV8msLlBAHP2CstzLvz5c1nuXzrwOnOfmbKvtNyqhaAxklxOFvqHb0htTbkjKEsadLIIEau(xyWm9LNHciPRuSWSf1vTaJWuBOT11fnm5qbK0vkwTX6w4yWNd12kRYYfQBOIZISqBqlyciRMoXGoa0UuwUq)QGcdOpMAdusi9KagWpl9aO8VWGz6lpJPPYLnT5i1gbjKfALvz5c1nuXzrwOnOfmbKvtNyqhiHSUQn6jn4n8gsRd9wnagMKhQ1I6qSFVxOoem1eEiwXtA5qyciRMhIvawl8q6sDOGwgTasM1c8qf8quKvS3qADifNfzH2GwWeqwnDIbDWvdGHjzeMAcVHkolYcTbTGjGSA6ed6(qjwPas)QGcdfqWWARWONSzK4JbKrK(gQ4Sil0g0cMaYQPtmOlGKfzPNYTvblCmOLasYG5BOIZISqBqlyciRMoXGUrAndFdvCwKfAdAbtaz10jg0btTH)gOCdVH06qawamc(Nc1HeaK2TdLfOCOmSCifNK(qf8qkaAXvwUyVHkolYczajCTJSIcEdP1HO90UWBOIZISqNyqhR0qPDvlq6lpd2V3BXASwS9hCdvCwKf6ed6(qjwPas)QGcdfqWWARWONSzK4JbKrKM(YZyk737Tynwl2(dCqrsliHS(QfBwyx1c0bfjTW)6RwSzHDvlqhtMMkx20ctHZ1o65AlwzvwUqnptrslmfox7ONRTyZc7QwGJVHkolYcDIbDa)Atv6gj(OciPjzy6lpJjttLlBAHP2CstzLvz5c18m737TWuBoPPS)GXoMY(9ElwJ1IT)ahuK0csiRVAXMf2vTaDqrsl8V(QfBwyx1c0XKPPYLnTWu4CTJEU2IvwLLluZZuK0ctHZ1o65Al2SWUQf44BOIZISqNyq3hkXkfq6fVxWzCvqHb2nmNKnzlCKLRWK(YZyk737Tynwl2(dCqrsliHS(QfBwyx1c0bfjTW)6RwSzHDvlqhtMMkx20ctHZ1o65AlwzvwUqnptrslmfox7ONRTyZc7QwGJVHkolYcDIbDFOeRuaPFvqHbmCbG0raKLagBHxy6lpJPSFV3I1yTy7pWXu2V3Bz5ecf)dt7pG(uBGsglpdksAHHlaKocGSeqlmvSlAya43qfNfzHoXGUpuIvkG0VkOWau3YlWKej(iOsTcesF5zW(9ElwJ1ITTaQ1cPH5bNNz)EVfRXAX2wa1AH048oy)EVvBSUfog85qTTWuXUOzaNN9fWWzSfqTw4OyI5BOIZISqNyqhlNqOIeFmdlrzfq3OV8mWecNImYAXASwSTfqTwinoBWBOIZISqNyqhOasA3IeFK)XfvKQffesF5zmL979wSgRfB)boMOWSvEmGmI0JIjaFEgtiCkYiRfRXAX2wa1AH04Sbh7GIKw4F9vl2wa1AH0W8GoOiPfKqwF1ITfqTwinmpOJjttLlBAHPW5Ah9CTfRSklxOMNPiPfMcNRD0Z1wSTaQ1cPH5bhFdvCwKf6ed6c(D5DRwGrwUcZBOIZISqNyqxxbbCjwBegOy5gQ4Sil0jg0Hjlw2S1uOIEUck3qfNfzHoXGUmSe)ll5VurpPXc9LNb737TTGDXfim6jnwS)ahuK0csiRVAXMf2vTaDqrsl8V(QfBwyx1c0XKPPYLnTWu4CTJEU2IvwLLluZZuK0ctHZ1o65Al2SWUQf44BOIZISqNyq3iKMtbGuBSfiz1fl3qfNfzHoXGopb)HcvubK0vkrwrbPV8mMmfaTlLLlwfqriCEEk737Tynwl2(dg7GIKwqcz9vl2SWUQfOdksAH)1xTyZc7QwGoMmnvUSPfMcNRD0Z1wSYQSCHAEMIKwykCU2rpxBXMf2vTahFdvCwKf6ed6YWKEH3qfNfzHoXGUpuIvkGq6lpd2V3BXASwS9hmp7lGHZylGATWrX0G3qfNfzHoXGUr0Ulshj(OW)RCdP1HuCwKf6ed6QDLganf6lpdfqsxPy5fac3TimO6kTYQSCHYXemHWPiJS2AXAVAwK12cOwlCumnpJjeofzK1IfUaZs5rLxaxqztBlGATWrXmtJVHkolYcDIbD1I1E1Sil9LNXu2V3BXASwS9h4yc737TGciPDls8r(hxurQwuqO9hmppzcMq4uKrwlOasA3IeFK)XfvKQffeABbuRfsdtdoppvGqzXIfuajTBrIpY)4Iks1IccTGQZfPh7qdI4Wc214XoMW(9ElOasA3IeFK)XfvKQffeA)bZZAqehwWUg7GIKw4F9vl2wa1AH0maoOiPfKqwF1ITfqTwinmZKJjuK0ctHZ1o65Al2wa1AH0mGZZttLlBAHPW5Ah9CTfRSklxOgFdvCwKf6ed6WcxGzP8OYlGlOSj9LNXu2V3BXASwS9h4yc737TGciPDls8r(hxurQwuqO9hmppzcMq4uKrwlOasA3IeFK)XfvKQffeABbuRfsdtdoppvGqzXIfuajTBrIpY)4Iks1IccTGQZfPh7qdI4Wc214XoMqrsl8V(QfBlGATqAyYbfjTGeY6RwSzHDvlqhtOiPfMcNRD0Z1wSzHDvlW55PPYLnTWu4CTJEU2IvwLLluJhFdvCwKf6ed68)2TiXhf(Ff6lpJjSFV3I1yTy7pyEgtiCkYiRfRXAX2wa1AH04Sbh7yKwZWwniIdlyx3qfNfzHoXGopPXsK4JRM)wOV8mMW(9ElwJ1IT)G5zmHWPiJSwSgRfBBbuRfsJZgCSdniIdlyx3WBiTo0lqwkPH3qfNfzHoXGoSUyHhz)Ep9RckmGP2CstrF5zW(9Elm1MtAkBlGATWr5mhthP1mSvdI4Wc21nuXzrwOtmOdMA7voN(YZyY0rAndB1GioSGDnppH979wyQnN0uwyQyxJYzZZSFV3ctT5KMY2cOwlKggdWyht8fWWzSfqTwOtmpM2GbcNhtTbkjKgmbMdmtwaFSdyGW5XuBGscPHbaAxklxSqFm1gOKWBiToKIZISqNyqhm1g(BGc9LNXKjPYLnTWuBoPPSYQSCHYXe2V3BHP2CstzHPIDnkNnpZ(9Elm1MtAkBlGATqAya4oy)EVvBSUfog85qTTWuXUg1amEEEAQCztlm1MtAkRSklxOCmH979wTX6w4yWNd12ctf7AudW8m737Tynwl2(dgp2Xe2V3BfmVcGses4AB)boy)EVvW8kakr(F12(dg7G9792wWU4ceg9Kglrm5VP0wyQyxJI5r38m737TTGDXfim6jnwS)GXoGbcNhtTbkj0ctT9kNpka0UuwUyH(yQnqjHoMmfaTlLLlwfqriCEEk737Tynwl2(dMNNg0cawyQn83aLXZZ(cy4m2cOwlCumeaJG)PeZcuOnfMTYJbKrKEGD(bNNNosRzyRgeXHfSRBOIZISqNyqhm1g(BGc9LNb737TcMxbqjcjCTTTaQ1cPbRWmMfOmpZ(9ERG5vauI8)QTTfqTwinyfMXSaLBOIZISqNyqh8V(Qf6lpd2V3BXASwS9h4G979wSgRfBBbuRfokGyklOcyCOas6kflmBrDvlWim1gABDD5GIKwqcz9vl2wa1AH00cOwl8gQ4Sil0jg0bsiRVAH(YZG979wSgRfB)boy)EVfRXAX2wa1AHJciMYcQaghkGKUsXcZwux1cmctTH2wxx3WBiToeTlje4nuXzrwOtmOd(xF1c9y3WCjMAdusidMPV8mAX3cmSYYfhAqehwWUC45espj1gOK2SaLysIuLmWtyI2GbcNhdRWugpM2GbcNhtTbkjKggyP4t8CcPNW0addeopMAdus4yAJzlGp2jMOnyGW5XuBGscDmbgiCEm1gOKqAy2Pu5YM2CKAJGeYcTYQSCHAEMIKwqcz9vl2SWUQf4yhtMQas6kflmBrDvlWim1gABDDnppL979wSgRfB)bZZtdAbal8V(QLXoMW(9ElwJ1ITTaQ1cPPfqTw488u2V3BXASwS9hm(gQ4Sil0jg0bsiRVAHESByUetTbkjKbZ0xEgT4Bbgwz5IdniIdlyxo8CcPNKAdusBwGsmjrQsg4jmrBWaHZJHvykJhtBWaHZJP2aLesdJb0XKPkGKUsXcZwux1cmctTH2wxxZZtz)EVfRXAX2FW880GwaWcsiRVAzSJjSFV3I1yTyBlGATqAAbuRfoppL979wSgRfB)bJVHkolYcDIbDWu4CTJEU2c9y3WCjMAdusidMPV8mAX3cmSYYfhAqehwWUC45espj1gOK2SaLysIuLmWtyI2GbcNhdRWugpMggaUJjtvajDLIfMTOUQfyeMAdTTUUMNNY(9ElwJ1IT)G55PbTaGfMcNRD0Z1wgFdVH06qo3KvAnjn8gQ4Sil0jg0TYirqczPV8m0GioSGDDdvCwKf6ed6cRCFeKqw6lpdniIdlyx3qfNfzHoXGo)NZJGeYsF5zObrCyb76gQ4Sil0jg0btT9vl0xEgSFV3kyEfaLi)VABBbuRfsdwHzmlqzEgs4AhfmVcGcndEdvCwKf6ed6gP1mm9LNb737TcMxbqjcjCTTTaQ1cPbRWmMfOmpZ)R2rbZRaOqZG3WBiToKZDLZZW9)qEsFiqcacOS5nuXzrwOtmOd(xF1IjnPXa]] )


end