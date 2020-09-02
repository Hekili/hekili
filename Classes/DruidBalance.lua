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
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 16,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
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
            id = 108291,
            duration = 45,
            max_stack = 1,
            copy = { 108292, 108293, 108294 }
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

        buff.eclipse_solar.empowerTime = 0
        buff.eclipse_lunar.empowerTime = 0

        if buff.eclipse_solar.up and action.starsurge.lastCast > buff.eclipse_solar.applied then buff.eclipse_solar.empowerTime = action.starsurge.lastCast end
        if buff.eclipse_lunar.up and action.starsurge.lastCast > buff.eclipse_lunar.applied then buff.eclipse_lunar.empowerTime = action.starsurge.lastCast end
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
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "celestial_alignment" )
                stat.haste = stat.haste + 0.15

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
            gcd = "off",

            spend = -40,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                shift( "moonkin_form" )
                
                applyBuff( "incarnation" )
                stat.crit = stat.crit + 0.10

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

                if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time end
                if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time end

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


    spec:RegisterPack( "Balance", 20200829.3, [[dC012aqifPhHuvxsHK2eb9jbvYOueNsHAvivXROcMfbClfszxK6xurgMcXXOcTmc0ZOIQPbqX1OIITjOIVbqjJJkkDofsSobvkVdGQ08eu19qk7dPYbvivluq6HivPMisvIlcqvSrbvQ6JcQu5KauvRubntakLDsLYsbOu9uv1uPs1Ej5VcnyehMYIj0JHmzGUmQntvFgqJwboTKvJuL0RPsMnr3gj7wPFd1Wfy5s9Cqtx01vLTdGVlOmEaQCEbX6biZxrTFvw5OYD1h0sw5MGJi4iJ4ScokAhD0XWrqNR(zibS6hyixgqw9xJIv)qnPTiw9dSqKydu5U6dXVgXQ)GmdGHBo5eWkh8e1imLtWI6jTSWlQnF6eSOqoP(IVsMa(Rsu9bTKvUj4icoYioRGJI2rhD05JiO6BVCaUv)FrrVv)bfiiVkr1hKHi1N(hjutAlIpc9s)kWBi9pYO)a(G5reCue4icoIGJCdVH0)i07b2cKHHB3q6FKr7iJoiidEKpwA9rcLnk9nK(hz0oc9EGTazWJKwdKZy5pcYGm8ij(iOqqsoMwdKtO(gs)JmAh5xubYYhYrgDaXDL8rY2Q8ism21laEKjG4nCLh5b5J82LrmeADihbaRltuYhbgYMgGBS(gs)JmAhbWotHbGbpcGTcawgYr(bvx5rq4fSYcVhXJ7JqVzjdZYKhz0LfWLI3eW7rcb)cxs5rgyaWhPYJG7Jec(DKWWB4kpcSweFea)D5gal5JuWJmOaoG7Je0fURmeT6llycvUR(GS3EYu5UYnhvUR(gkl8Q(qS06OiBuQpVMOKbvHQsLBcQCx951eLmOku1h1vYDzQV4Z71ilwls)cuFdLfEvFrUHC7QwGQu5MZvUR(8AIsgufQ6VgfR(gGGdS2GrpEZi2hdWHXT6BOSWR6BacoWAdg94nJyFmahg3QpQRK7Yu)Phr859AKfRfPFbhr4raXPMcJxF1SolKRAbEeHhbeNA4B9vZ6SqUQf4reEKjhz6rstYBQHjlLwh9sRznVMOKbpY88raXPgMSuAD0lTM1zHCvlWJmwLk3amk3vFEnrjdQcv9rDLCxM6p5itpsAsEtnmTwIBqnVMOKbpY88reFEVgMwlXnO(fCKXhr4rMEeXN3RrwSwK(fCeHhbeNAkmE9vZ6SqUQf4reEeqCQHV1xnRZc5QwGhr4rMCKPhjnjVPgMSuAD0lTM18AIsg8iZZhbeNAyYsP1rV0AwNfYvTapYy13qzHx1h4ZAWY2i2hnaXnohOsLBoJYD1NxtuYGQqvFuxj3LP(tpI4Z71ilwls)coIWJaItnfgV(QzDwix1c8icpcio1W36RM1zHCvlWJi8itoY0JKMK3udtwkTo6LwZAEnrjdEK55JaItnmzP06OxAnRZc5QwGhzS6BOSWR6JcbjXzJ3cffLgmvF27zugxJIvFuiijoB8wOOO0GPkvUfok3vFEnrjdQcv9nuw4v9Hdka4ocaVyQyZYcP(RrXQpCqba3ra4ftfBwwi1h1vYDzQ)0Ji(8EnYI1I0VGJi8itpI4Z71Ismgu(GP(fO(P1a5mwE1heNA4GcaUJaWlMsdtd56i0r7ioJkvUbyPCx951eLmOku1Fnkw9PST8mmXrSpszGldHQVHYcVQpLTLNHjoI9rkdCziu9rDLCxM6l(8EnYI1I0ntz1cpcDhXXroY88reFEVgzXAr6MPSAHhHUJayoIWJi(8ET1iBlum4jHwRHPHCDe6os4CK55J4lGdYyZuwTWJe(JiOJQu5MZQCx951eLmOku1h1vYDzQpcJLG4WwnYI1I0ntz1cpcDhX5JO(gkl8Q(IsmgmI9XCah5LPcrLk3gfL7QpVMOKbvHQ(OUsUlt9NEeXN3RrwSwK(fCeHhzYrmy2MmgGdJ7Je(JiOZCK55JGWyjioSvJSyTiDZuwTWJq3rC(ihz8reEeqCQHV1xnRBMYQfEe6oIJJCeHhbeNAkmE9vZ6MPSAHhHUJ44ihr4rMCKPhjnjVPgMSuAD0lTM18AIsg8iZZhbeNAyYsP1rV0Aw3mLvl8i0Dehh5iJvFdLfEvFkMc3HeX(O8HkWiyZgfuLk3CCeL7QVHYcVQFWRlFi1cmkknyQ(8AIsgufQkvU5OJk3vFdLfEv)UccKCS2imWqS6ZRjkzqvOQu5MJcQCx9nuw4v9r4fXB2wYGrV0Oy1NxtuYGQqvPYnhDUYD1NxtuYGQqvFuxj3LP(IpVx3mYLKHWOh3iw)coIWJaItnfgV(QzDwix1c8icpcio1W36RM1zHCvlWJi8itoY0JKMK3udtwkTo6LwZAEnrjdEK55JaItnmzP06OxAnRZc5QwGhzS6BOSWR6Nd44BfXVfm6XnIvPYnhbmk3vFdLfEv)WWTeeaU2yZq8AlIvFEnrjdQcvLk3C0zuUR(8AIsgufQ6J6k5Um1FYrMEeaSUmrjRnafHWJmpFKPhr859AKfRfPFbhz8reEeqCQPW41xnRZc5QwGhr4raXPg(wF1SolKRAbEeHhzYrMEK0K8MAyYsP1rV0AwZRjkzWJmpFeqCQHjlLwh9sRzDwix1c8iJvFdLfEvFpg9Gmy0ae3vYrr2OuPYnhdhL7QVHYcVQFoa3lu951eLmOkuvQCZralL7QpVMOKbvHQ(OUsUlt9fFEVgzXAr6xWrMNpIVaoiJntz1cps4pIGJO(gkl8Q(pihRKPGQu5MJoRYD13qzHx1pmR7c3rSpYY3YQpVMOKbvHQsLBookk3vFEnrjdQcv9rDLCxM6p9iIpVxJSyTi9l4icpYKJi(8EnftH7qIyFu(qfyeSzJcQFbhzE(itoYKJGWyjioSvtXu4oKi2hLpubgbB2OG6MPSAHhHUJi4ihzE(itpcdH8IynftH7qIyFu(qfyeSzJcQPm6vCFKXhr4rSGiAaJCDKXhz8reEKjhr859AkMc3HeX(O8HkWiyZgfu)coY88rSGiAaJCDKXhr4raXPg(wF1SUzkRw4rO7io7reEeqCQPW41xnRBMYQfEe6oIJcEeHhzYraXPgMSuAD0lTM1ntz1cpcDhjCoY88rMEK0K8MAyYsP1rV0AwZRjkzWJmw9nuw4v9Rfz9AzHxvQCtWruUR(8AIsgufQ6J6k5Um1F6reFEVgzXAr6xWreEKjhr859AkMc3HeX(O8HkWiyZgfu)coY88rMCKjhbHXsqCyRMIPWDirSpkFOcmc2Srb1ntz1cpcDhrWroY88rMEegc5fXAkMc3HeX(O8HkWiyZgfutz0R4(iJpIWJybr0ag56iJpY4Ji8itocio1W36RM1ntz1cpcDhrWJi8iG4utHXRVAwNfYvTapIWJm5iG4udtwkTo6LwZ6SqUQf4rMNpY0JKMK3udtwkTo6LwZAEnrjdEKXhzS6BOSWR6JyjdZYKrtwaxkEtvQCtqhvUR(gkl8Q(mvaomUJI4fu951eLmOkuvQCtqbvUR(gkl8Q(TbaV4hm6BEbuiQpVMOKbvHQsLBc6CL7QpVMOKbvHQ(OUsUlt9NCeXN3RrwSwK(fCK55JGWyjioSvJSyTiDZuwTWJq3rC(ihz8reEKWAlhOTGiAaJCP(gkl8Q((xhse7JS8TSkvUjiGr5U6ZRjkzqvOQpQRK7Yu)jhr859AKfRfPFbhzE(iimwcIdB1ilwls3mLvl8i0DeNpYrgFeHhXcIObmYL6BOSWR67XnIJyFCT81SkvUjOZOCx9fFEFCnkw9HP1sCdQ(8AIsgufQ6J6k5Um1x859AyATe3G6MPSAHhj8hX5hr4rMEKWAlhOTGiAaJCP(gkl8Q(iBrSmk(8EvQCtWWr5U6ZRjkzqvOQpQRK7YuFXN3RzKScGCu(wR1VGJi8itpI4Z71mswbqokFR1AMkahg3m4rMNpI4Z71mswbqocXsR1VGJi8itpI4Z71mswbqocXsR1mvaomUzq13qzHx1hMwdFnqwLk3eeWs5U6ZRjkzqvOQpQRK7Yu)jhz6rcRTCG2cIObmY1rMNpYKJi(8EnmTwIBqnmnKRJe(J48JmpFeXN3RHP1sCdQBMYQfEe6ODeN9iJpIWJm5i(c4Gm2mLvl8ioCehpY4JqphbgWszmTgiNWJq3rqyyEKr9icQDMJm(icpcmGLYyAnqoHhHoAhbaRltuYAOpMwdKtO6BOSWR6dtR9MuQsLBc6Sk3vFEnrjdQcv9rDLCxM6l(8EnYI1I0VGJi8iIpVxJSyTiDZuwTWJe(JaebQPma3reEedqCxjRHzZMRAbgHP1qDBRRJi8iG4utHXRVAw3mLvl8i0DKMPSAHQVHYcVQp8T(QzvQCtWrr5U6ZRjkzqvOQpQRK7YuFXN3RrwSwK(fCeHhr859AKfRfPBMYQfEKWFeGiqnLb4oIWJyaI7kznmB2CvlWimTgQBBDP(gkl8Q(uy86RMvPYnNpIYD1NxtuYGQqvFuxj3LP(n7BgoWeL8reEeliIgWixhr4r8smUpYKJKwdKtDwuCmXrWIpYOEKjhrWJqphbgWszCGbt(iJpY4JqphbgWszmTgiNWJqhTJG4sEKjhXlX4(itoIGhzupcmGLYyAnqoHhz8rONJ4O2zoY4J4Wre8i0ZrGbSugtRbYj8icpYKJadyPmMwdKt4rO7ioEehosAsEtDgwTrkmEHAEnrjdEK55JaItnfgV(QzDwix1c8iJpIWJm5itpIbiURK1WSzZvTaJW0AOUT11rMNpY0Ji(8EnYI1I0VGJmpFKPhjOza0W36RMpY4Ji8itoI4Z71ilwls3mLvl8i0DKMPSAHhzE(itpI4Z71ilwls)coYy13qzHx1h(wF1S6Jcbj5yAnqoHk3CuLk3CUJk3vFEnrjdQcv9rDLCxM63SVz4atuYhr4rSGiAaJCDeHhXlX4(itosAnqo1zrXXehbl(iJ6rMCebpc9CeyalLXbgm5Jm(iJpc9CeyalLX0AGCcpcD0os4CeHhzYrMEedqCxjRHzZMRAbgHP1qDBRRJmpFKPhr859AKfRfPFbhzE(itpsqZaOPW41xnFKXhr4rMCeXN3RrwSwKUzkRw4rO7intz1cpY88rMEeXN3RrwSwK(fCKXQVHYcVQpfgV(Qz1hfcsYX0AGCcvU5OkvU5CbvUR(8AIsgufQ6J6k5Um1VzFZWbMOKpIWJybr0ag56icpIxIX9rMCK0AGCQZIIJjocw8rg1Jm5icEe65iWawkJdmyYhz8rgFe6ODeN5icpYKJm9igG4UswdZMnx1cmctRH62wxhzE(itpI4Z71ilwls)coY88rMEKGMbqdtwkTo6LwZhzS6BOSWR6dtwkTo6LwZQpkeKKJP1a5eQCZrvQCZ5ox5U6BOSWR6JWlayxCmhWryq1vcvFEnrjdQcvLk3CoGr5U6ZRjkzqvOQpQRK7YuFliIgWixQVHYcVQ)YHfPW4vLk3CUZOCx951eLmOku1h1vYDzQVferdyKl13qzHx1FGj9rkmEvPYnNhok3vFEnrjdQcv9rDLCxM6Bbr0ag5s9nuw4v99pPmsHXRkvU5CalL7QpVMOKbvHQ(OUsUlt9fFEVMrYkaYr5BTw3mLvl8i0DeKbZywu8rMNpcelToYizfa5Jq3rgr9nuw4v9HP1(QzvQCZ5oRYD1NxtuYGQqvFuxj3LP(IpVxZizfa5ielTw3mLvl8i0DeKbZywu8rMNpI8TwhzKScG8rO7iJO(gkl8Q(H1woqLk3C(OOCx9nuw4v9HV1xnR(8AIsgufQkvP6h0mctjAPYDLBoQCx951eLmOku1hhO(qovFdLfEvFaSUmrjR(ayYhR(ag1haRJRrXQp0htRbYjuLk3eu5U6ZRjkzqvOQpoq9nqq13qzHx1haRltuYQpaM8XQVJQpawhxJIvFOpMwdKtO6J6k5Um13ae3vYARr2wOyWtcTwZRjkzqvQCZ5k3vFEnrjdQcv9XbQVbcQ(gkl8Q(ayDzIsw9bWKpw9Du9bW64AuS6d9X0AGCcvFuxj3LP(Pj5n1W0AjUb18AIsguLk3amk3vFEnrjdQcv9XbQVbcQ(gkl8Q(ayDzIsw9bWKpw9Du9bW64AuS6d9X0AGCcvFuxj3LP(gG4UswdZMnx1cmctRH62wxhHUJi4reEedqCxjRTgzBHIbpj0AnVMOKbvPYnNr5U6ZRjkzqvOQpoq9Hpr13qzHx1haRltuYQpaM8XQVJQpawhxJIvFOpMwdKtO6J6k5Um1F6rstYBQZWQnsHXluZRjkzqvQClCuUR(gkl8Q(uy86Q2Oh3uQpVMOKbvHQsLBawk3vFdLfEvFx1c2myeguDLq1NxtuYGQqvPYnNv5U6ZRjkzqvOQ)AuS6BacoWAdg94nJyFmahg3QVHYcVQVbi4aRny0J3mI9XaCyCRsLBJIYD1NxtuYGQqvFdLfEv)aCw4v9bdznQcfdAoaNQVJQu5MJJOCx9nuw4v9dRTCG6ZRjkzqvOQu5MJoQCx9nuw4v9HP1WxdKvFEnrjdQcvLQuLQpaCdl8QCtWreCKrCwbhfTGQFywV1ceQ(a(ub4ozWJi4rmuw49iYcMq9nu9Hbms5MJJiO6h0yFjz1N(hjutAlIpc9s)kWBi9pYO)a(G5reCue4icoIGJCdVH0)i07b2cKHHB3q6FKr7iJoiidEKpwA9rcLnk9nK(hz0oc9EGTazWJKwdKZy5pcYGm8ij(iOqqsoMwdKtO(gs)JmAh5xubYYhYrgDaXDL8rY2Q8ism21laEKjG4nCLh5b5J82LrmeADihbaRltuYhbgYMgGBS(gs)JmAhbWotHbGbpcGTcawgYr(bvx5rq4fSYcVhXJ7JqVzjdZYKhz0LfWLI3eW7rcb)cxs5rgyaWhPYJG7Jec(DKWWB4kpcSweFea)D5gal5JuWJmOaoG7Je0fURme9n8gs)Ja4bWXOxYGhrK94MpcctjA5rezG1c1hz0rioiHhzX7OnWAk)tEedLfEHhbVYq03q6FedLfEH6GMrykrlP5Lg01nK(hXqzHxOoOzeMs0shO5KhJbVH0)igkl8c1bnJWuIw6anNShqkEtll8EdVH0)iJoG4Us(iayDzIsgEdP)rmuw4fQdAgHPeT0bAobG1LjkzbwJIPzakcHcaGjFmndqCxjRHzZMRAbgHP1qDBRRBi9pIHYcVqDqZimLOLoqZjaSUmrjlWAumndqrlqaam5JPzaI7kzT1iBlum4jHwRBBDDdVH0)i)0AVjLhbGJ8tRHVgiFK0AGCEe0lXE)n0qzHxOoOzeMs0sAayDzIswG1OyAqFmTgiNqbaWKpMgG5gAOSWluh0mctjAPd0CcaRltuYcSgftd6JP1a5ekaoGMbckaaM8X0CuGYtZae3vYARr2wOyWtcTwZRjkzWBOHYcVqDqZimLOLoqZjaSUmrjlWAumnOpMwdKtOa4aAgiOaayYhtZrbkpT0K8MAyATe3GAEnrjdEdnuw4fQdAgHPeT0bAobG1LjkzbwJIPb9X0AGCcfahqZabfaat(yAokq5PzaI7kznmB2CvlWimTgQBBDrNGcnaXDLS2AKTfkg8KqR18AIsg8gAOSWluh0mctjAPd0CcaRltuYcSgftd6JP1a5ekaoGg8jkaaM8X0CuGYtBAAsEtDgwTrkmEHAEnrjdEdnuw4fQdAgHPeT0bAorHXRRAJECtDdVH0)i)1cGdW5rARapI4Z7zWJatlHhrK94MpcctjA5rezG1cpITGhjO5rlaNzTapsbpciEz9nK(hXqzHxOoOzeMs0shO5eCTa4aCgHPLWBOHYcVqDqZimLOLoqZjx1c2myeguDLWBOHYcVqDqZimLOLoqZPhKJvYucSgftZaeCG1gm6XBgX(yaomUVHgkl8c1bnJWuIw6anNcWzHxbadznQcfdAoaN0C8gAOSWluh0mctjAPd0CkS2Yb3qdLfEH6GMrykrlDGMtW0A4RbY3WBi9pcGhahJEjdEegaUd5izrXhjhWhXqjUpsbpIbGvstuY6BOHYcVqAqS06OiBu3q6Fe6n9c8gAOSWl0bAojYnKBx1cuGYtt859AKfRfPFb3qdLfEHoqZPhKJvYucSgftZaeCG1gm6XBgX(yaomUfO80Mk(8EnYI1I0VaHG4utHXRVAwNfYvTafcItn8T(QzDwix1cu4KPPj5n1WKLsRJEP1SMxtuYGZZG4udtwkTo6LwZ6SqUQf44BOHYcVqhO5eWN1GLTrSpAaIBCoqGYtBY00K8MAyATe3GAEnrjdopl(8EnmTwIBq9lySWPIpVxJSyTi9lqiio1uy86RM1zHCvlqHG4udFRVAwNfYvTafozAAsEtnmzP06OxAnR51eLm48mio1WKLsRJEP1SolKRAbo(gAOSWl0bAo9GCSsMsa27zugxJIPHcbjXzJ3cffLgmfO80Mk(8EnYI1I0VaHG4utHXRVAwNfYvTafcItn8T(QzDwix1cu4KPPj5n1WKLsRJEP1SMxtuYGZZG4udtwkTo6LwZ6SqUQf44BOHYcVqhO50dYXkzkbwJIPbhuaWDeaEXuXMLfsGYtBQ4Z71ilwls)ceov859ArjgdkFWu)ceiTgiNXYtdeNA4GcaUJaWlMsdtd5IoAoZn0qzHxOd0C6b5yLmLaRrX0OST8mmXrSpszGldHcuEAIpVxJSyTiDZuwTq6CCK5zXN3RrwSwKUzkRwiDagHIpVxBnY2cfdEsO1AyAix0foZZ(c4Gm2mLvlm8c64n0qzHxOd0CsuIXGrSpMd4iVmvicuEAimwcIdB1ilwls3mLvlKoNpYn0qzHxOd0CIIPWDirSpkFOcmc2SrbfO80Mk(8EnYI1I0VaHtmy2MmgGdJ7WlOZmpJWyjioSvJSyTiDZuwTq6C(iJfcItn8T(QzDZuwTq6CCeHG4utHXRVAw3mLvlKohhr4KPPj5n1WKLsRJEP1SMxtuYGZZG4udtwkTo6LwZ6MPSAH054iJVHgkl8cDGMtbVU8HulWOO0G5n0qzHxOd0CQRGajhRncdmeFdnuw4f6anNq4fXB2wYGrV0O4BOHYcVqhO5uoGJVve)wWOh3iwGYtt8596MrUKmeg94gX6xGqqCQPW41xnRZc5QwGcbXPg(wF1SolKRAbkCY00K8MAyYsP1rV0AwZRjkzW5zqCQHjlLwh9sRzDwix1cC8n0qzHxOd0CkmClbbGRn2meV2I4BOHYcVqhO5KhJEqgmAaI7k5OiBucuEAtMcG1LjkzTbOieoppv859AKfRfPFbJfcItnfgV(QzDwix1cuiio1W36RM1zHCvlqHtMMMK3udtwkTo6LwZAEnrjdopdItnmzP06OxAnRZc5QwGJVHgkl8cDGMt5aCVWBOHYcVqhO50dYXkzkOaLNM4Z71ilwls)cMN9fWbzSzkRwy4fCKBOHYcVqhO5uyw3fUJyFKLVLVH0)igkl8cDGMt1UCdGLSaLNMbiURK1YcawgseguDLAEnrjdkCccJLG4WwDTiRxll8QBMYQfgEbNNrySeeh2QrSKHzzYOjlGlfVPUzkRwy4DuWX3qdLfEHoqZPArwVww4vGYtBQ4Z71ilwls)ceor859AkMc3HeX(O8HkWiyZgfu)cMNNmbHXsqCyRMIPWDirSpkFOcmc2Srb1ntz1cPtWrMNNYqiViwtXu4oKi2hLpubgbB2OGAkJEf3JfAbr0ag5A8yHteFEVMIPWDirSpkFOcmc2Srb1VG5zliIgWixJfcItn8T(QzDZuwTq6CwHG4utHXRVAw3mLvlKohfu4eqCQHjlLwh9sRzDZuwTq6cN55PPj5n1WKLsRJEP1SMxtuYGJVHgkl8cDGMtiwYWSmz0KfWLI3uGYtBQ4Z71ilwls)ceor859AkMc3HeX(O8HkWiyZgfu)cMNNmbHXsqCyRMIPWDirSpkFOcmc2Srb1ntz1cPtWrMNNYqiViwtXu4oKi2hLpubgbB2OGAkJEf3JfAbr0ag5A8yHtaXPg(wF1SUzkRwiDckeeNAkmE9vZ6SqUQfOWjG4udtwkTo6LwZ6SqUQf48800K8MAyYsP1rV0AwZRjkzWXJVHgkl8cDGMtmvaomUJI4f8gAOSWl0bAo1ga8IFWOV5fqHCdnuw4f6anN8VoKi2hz5BzbkpTjIpVxJSyTi9lyEgHXsqCyRgzXAr6MPSAH058rglmS2YbAliIgWix3qdLfEHoqZjpUrCe7JRLVMfO80Mi(8EnYI1I0VG5zeglbXHTAKfRfPBMYQfsNZhzSqliIgWix3WBi9pYpGxqUH3qdLfEHoqZjKTiwgfFEVaRrX0GP1sCdkq5Pj(8EnmTwIBqDZuwTWW7CHtdRTCG2cIObmY1n0qzHxOd0CcMwdFnqwGYtt859AgjRaihLV1A9lq4uXN3RzKScGCu(wR1mvaomUzW5zXN3RzKScGCeILwRFbcNk(8EnJKvaKJqS0AntfGdJBg8gAOSWl0bAobtR9Mukq5PnzAyTLd0wqenGrUMNNi(8EnmTwIBqnmnKRW785zXN3RHP1sCdQBMYQfshnNDSWj(c4Gm2mLvl0bhhtpWawkJP1a5eshcdZrvqTZmwimGLYyAnqoH0rdaRltuYAOpMwdKt4nK(hXqzHxOd0CcMwdFnqwGYtBYK0K8MAyATe3GAEnrjdkCI4Z71W0AjUb1W0qUcVZNNfFEVgMwlXnOUzkRwiD0CgHIpVxBnY2cfdEsO1AyAixH3zhpppnnjVPgMwlXnOMxtuYGcNi(8ET1iBlum4jHwRHPHCfENDEw859AKfRfPFbJhlCI4Z71mswbqocXsR1VaHIpVxZizfa5O8TwRFbJfk(8EDZixsgcJECJ4ic)2KBnmnKRW74Ompl(8EDZixsgcJECJy9lySqyalLX0AGCc1W0AVjLHhaRltuYAOpMwdKtOWjtbW6YeLS2auecNNNk(8EnYI1I0VG55PbndGgMwdFnqE88SVaoiJntz1cdpngWXOxYXSOy6XGzBYyaomUhvaZiZZtdRTCG2cIObmY1nK(hXqzHxOd0CcMwdFnqwGYtZqzbah5LPkggEaSUmrjRH(yAnqoHcNi(8EnJKvaKJqS0ADZuwTq6qgmJzrXZZIpVxZizfa5O8TwRBMYQfshYGzmlkE8n0qzHxOd0Cc(wF1SaLNM4Z71ilwls)cek(8EnYI1I0ntz1cdpqeOMYaCcnaXDLSgMnBUQfyeMwd1TTUecItnfgV(QzDZuwTq6AMYQfEdnuw4f6anNOW41xnlq5Pj(8EnYI1I0VaHIpVxJSyTiDZuwTWWdebQPmaNqdqCxjRHzZMRAbgHP1qDBRRB4nK(hHEb7o8gAOSWl0bAobFRVAwauiijhtRbYjKMJcuEAn7BgoWeLSqliIgWixc9smUNKwdKtDwuCmXrWIh1jcspWawkJdmyYJhtpWawkJP1a5eshnexYjEjg3teCuHbSugtRbYjCm94O2zg7GG0dmGLYyAnqoHcNadyPmMwdKtiDo6qAsEtDgwTrkmEHAEnrjdopdItnfgV(QzDwix1cCSWjtnaXDLSgMnBUQfyeMwd1TTUMNNk(8EnYI1I0VG55PbndGg(wF18yHteFEVgzXAr6MPSAH01mLvlCEEQ4Z71ilwls)cgFdnuw4f6anNOW41xnlakeKKJP1a5esZrbkpTM9ndhyIswOferdyKlHEjg3tsRbYPolkoM4iyXJ6ebPhyalLXbgm5XJPhyalLX0AGCcPJw4iCYudqCxjRHzZMRAbgHP1qDBRR55PIpVxJSyTi9lyEEAqZaOPW41xnpw4eXN3RrwSwKUzkRwiDntz1cNNNk(8EnYI1I0VGX3qdLfEHoqZjyYsP1rV0AwauiijhtRbYjKMJcuEAn7BgoWeLSqliIgWixc9smUNKwdKtDwuCmXrWIh1jcspWawkJdmyYJhthnNr4KPgG4UswdZMnx1cmctRH62wxZZtfFEVgzXAr6xW880GMbqdtwkTo6LwZJVH3q6FKWD8YTL4gEdnuw4f6anNq4faSloMd4imO6kH3qdLfEHoqZPLdlsHXRaLNMferdyKRBOHYcVqhO50at6Juy8kq5Pzbr0ag56gAOSWl0bAo5FszKcJxbkpnliIgWix3qdLfEHoqZjyATVAwGYtt859AgjRaihLV1ADZuwTq6qgmJzrXZZqS06iJKvaKPBKBOHYcVqhO5uyTLdeO80eFEVMrYkaYriwATUzkRwiDidMXSO45z5BToYizfaz6g5gEdP)rc3BszoOFhXJ7JqHbGP4nVHgkl8cDGMtW36RMvPkvk]] )


end