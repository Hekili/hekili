-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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

            interval = 1.5, -- actually 0.5 AP every 0.75s, but...
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
        typhoon = 18577, -- 132469

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
        adaptation = 3543, -- 214027
        relentless = 3542, -- 196029
        gladiators_medallion = 3541, -- 208683

        celestial_downpour = 183, -- 200726
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        cyclone = 857, -- 209753
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        ironfeather_armor = 1216, -- 233752
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
        thorns = 3731, -- 236696
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
        blessing_of_cenarius = {
            id = 238026,
            duration = 60,
            max_stack = 1,
        },
        blessing_of_the_ancients = {
            id = 206498,
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
        eclipse = {
            id = 279619,
        },
        empowerments = {
            id = 279708,
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
        flask_of_the_seventh_demon = {
            id = 188033,
            duration = 3600.006,
            max_stack = 1,
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
        legionfall_commander = {
            id = 233641,
            duration = 3600,
            max_stack = 1,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
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
            duration = 22,
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
        sign_of_the_critter = {
            id = 186406,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            type = "Magic",
            max_stack = 3,
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
            duration = function () return pvptalent.celestial_downpour.enabled and 16 or 8 end,
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
        stellar_drift = {
            id = 202461,
            duration = 3600,
            max_stack = 1,
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
        thorny_entanglement = {
            id = 241750,
            duration = 15,
            max_stack = 1,
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


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end 
    end )

    spec:RegisterHook( "gain_preforecast", function( amt, resource )
        if buff.memory_of_lucid_dreams.up then
            if amt > 0 and resource == "astral_power" then
                print( resource, "gain", GetTime() )
                gain( amt, resource, true )
                return false
            end
        end
    end )

    spec:RegisterHook( "spend_preforecast", function( amt, resource, overcap )
        if buff.memory_of_lucid_dreams.up then
            if amt < 0 and resource == "astral_power" then
                print( resource, "spend", GetTime() )
                spend( amt, resource, overcap, true )
                return false
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
        "force_of_nature", "full_moon", "half_moon", "incarnation", "lunar_strike", "moonfire", "new_moon", "solar_wrath", "starfall", "starsurge", "sunfire"
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
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.impeccable_fel_essence and resource == "astral_power" and cooldown.celestial_alignment.remains > 0 then
            setCooldown( "celestial_alignment", max( 0, cooldown.celestial_alignment.remains - ( amt / 12 ) ) )
        end 
    end )


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
            id = 209753,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",

            spend = 0.15,
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


        --[[ dreamwalk = {
            id = 193753,
            cast = 10,
            cooldown = 60,
            gcd = "spell",

            spend = 4,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135763,

            handler = function ()
            end,
        }, ]]


        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.18,
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
            talent = "feral_affinity",

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


        lunar_strike = {
            id = 194153,
            cast = function () 
                if buff.warrior_of_elune.up then return 0 end
                return haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) * 2.25 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -12 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135753,            

            ap_check = function() return check_for_ap_overcap( "lunar_strike" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "lunar_empowerment" )

                if buff.warrior_of_elune.up then
                    removeStack( "warrior_of_elune" )
                    if buff.warrior_of_elune.down then
                        setCooldown( "warrior_of_elune", 45 ) 
                    end
                end

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
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

            talent = "guardian_affinity",
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

            spend = -3,
            spendType = "astral_power",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function() return check_for_ap_overcap( "moonfire" ) end,

            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
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

            startsCombat = true,
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

            spend = 0.14,
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
                -- unshift?
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

            talent = "feral_affinity",
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


        solar_wrath = {
            id = 190984,
            cast = function () return haste * ( buff.solar_empowerment.up and 0.85 or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 535045,

            ap_check = function() return check_for_ap_overcap( "solar_wrath" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "solar_empowerment" )
                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
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
                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
            end,
        },


        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.oneths_intuition.up then return 0 end
                return 40 - ( buff.the_emerald_dreamcatcher.stack * 5 )
            end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135730,

            ap_check = function() return check_for_ap_overcap( "starsurge" ) end,   

            handler = function ()
                addStack( "lunar_empowerment", nil, 1 )
                addStack( "solar_empowerment", nil, 1 )
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_intuition" )
                removeBuff( "sunblaze" )

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end

                if azerite.arcanic_pulsar.enabled then
                    addStack( "arcanic_pulsar" )
                    if buff.arcanic_pulsar.stack == 9 then
                        removeBuff( "arcanic_pulsar" )
                        applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment" )
                    end
                end

                if ( level < 116 and equipped.the_emerald_dreamcatcher ) then addStack( "the_emerald_dreamcatcher", 5, 1 ) end
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

            spend = 0.12,
            spendType = "mana",

            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",

            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            

            handler = function ()
                gain( 3, "astral_power" )
                applyDebuff( "target", "sunfire" )
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
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 6,

        potion = "potion_of_rising_death",

        package = "Balance",        
    } )


    spec:RegisterPack( "Balance", 20190625.0915, [[dGeaRaqiqQhbqUKikTjr4tkIyukQofawfirVIsywuQ6wkkzxu5xqIHjs1XOKAzuIEMIW0aO6Akk12OK03ervJJscNdGY6aj07ajO5bs6EqQ9jICqruzHuf9qfr1efrrxurK0gfrH8rruOoPIi1kfjZuefStkvwQIiXtb1uPkSxk(ROgSshM0Ij4XiMmexg1Mv4ZGy0ukNwLvdsGxtvA2eDBQQDRQFJ0Wj0XveLLl1ZHA6cxhOTdj9DfPXtjrNxKY6vumFaTFjBS24Hbgrd2yNLPBnGLUvTC2U0bmRT6SbmdCKMiBGfvIxfcBGF1NnWEQs9jSbwuttsveJhgymfSjSb2weIyOikOa5cBGcoc1hf85dk14OpP1rGc(8jOyGfapzmPFJGbgrd2yNLPBnGLUvTC2U0bmRTQLgyfmSrBdm85p5gyBhcc)gbdmcJjgyavRNQuFcxBYSbpKkfGQ1weIyOikOa5cBGcoc1hf85dk14OpP1rGc(8jOuPauTPaFUwlTQ91Az6wdy1oRAthWGIwp7kvLcq1o520hcJHIvkav7SQn5qqyKAHPsTR1tw9Dvkav7SQDYTPpegP2qBiCKVrTefZ4AdATK0isohAdHdSRsbOANvTjhcuaioyKAXJCOneoW1IQ2Nki5Ah0UwfbH(1It7d1kDvkav7SQf(8fL3iTAtUz4(cU2O1lQvsPEbfX1ohH(tsuliMRf8FMWyS2PvlQAFQGKRfN2hQvcGRsbOANvTtkSpfvgP2KHdvwMwTWIxFrTe6JCXr)Ah0U2jNLmoovwBYjpiVp)buyTPrbNePSwBkQCTxulTRnnkyTtP)Ke1IVNW1oP)NBu1GR9W1A7GyJ7Af7J2xKMZalpCGnEyGr4HckdJhg7S24HbwjXrFdmMk1olWQVbMFvqYigpnHXolnEyG5xfKmIXtdmPVG7tnWcGJHJO57jUM917X1MuTw1aRK4OVbwKgh9nHXUjmEyG5xfKmIXtdmPVG7tnWcGJHJO57joqrdSsIJ(gybjLIKhGDAMWyhGB8WaZVkizeJNgysFb3NAGfahdhrZ3tCGIgyLeh9nWcCJ5279qmHXUzB8WaZVkizeJNgysFb3NAGfahdhrZ3tCGIgyLeh9nWAt0NZbTB(dtySZQgpmW8RcsgX4PbM0xW9PgybWXWr089ehOObwjXrFdS8GylWzOaqei(8hMWyxYB8WaZVkizeJNgysFb3NAGfahdhrZ3tCGIgyLeh9nWJRzbjLIycJDwHXddm)QGKrmEAGj9fCFQbwaCmCenFpXbkAGvsC03aRpHXrRYmrLstySdWmEyG5xfKmIXtdSsIJ(gybvYJR5SqRpXMbM0xW9PgyEYaprrgXjOsECnNfA9j2QnrTekvIqN(oIMVN4A2xVhxBs1or6g4x9zdSGk5X1CwO1NyZeg7SoDJhgy(vbjJy80aRK4OVbgPzfjdrQiNg0gNfueiSbM0xW9PgyEYaprrgXH0SIKHivKtdAJZckceU2e1sOujcD67iA(EIRzF9ECTjv7ePBGF1NnWinRizisf50G24SGIaHnHXoRT24HbMFvqYigpnWkjo6BG1zaBoSrXz89qyKSOe0xHWgysFb3NAG5jd8efzeNodyZHnkoJVhcJKfLG(keU2e1sOujcD67iA(EIRzF9ECTjv7ePBGF1NnW6mGnh2O4m(Eimswuc6RqytySZAlnEyG5xfKmIXtdSsIJ(g44qyCqB)mHIWwPbM0xW9PgyEYaprrgXfhcJdA7Njue2knWV6Zg44qyCqB)mHIWwPjm2z9egpmW8RcsgX4PbM0xW9PgycLkrOtFhrZ3tCn7R3JRnPANiDdSsIJ(gyqmNVG9XMWyN1aUXddSsIJ(g4PA3hTZ0rMLGpBG5xfKmIXttySZ6zB8WaZVkizeJNgysFb3NAG1z4(c2jpuzzAzS41x44xfKmsTjQDETekvIqN(U7jA)AC031SVEpUwOwRL1ceyTekvIqN(oclzCCQmRYdY7ZF4A2xVhxluR1AlRfadSsIJ(g47FUrvd2eg7S2QgpmW8RcsgX4PbM0xW9PgyeA4WG)4A21SVEpU2KQ1kQnrTi0W5tP)4A21SVEpU2KQ1AlRnrTZRfHgoCWsP25HuB21SVEpU2KQ1Q1ceyTqxBOs(dhoyPu78qQn74xfKmsTauBIAvXmXgt8wBIAHUwbWXWr089ehOObwjXrFd89eTFno6BcJDwN8gpmW8RcsgX4PbM0xW9PgyfhTkZI0PCxBsORfWtV2e1cDTcGJHJO57joqXAtuRkMj2yI3Atu78ArOHdd(JRzxZ(694AtQwlRnrTi0W5tP)4A2fhX79qQnrTZRfHgoCWsP25HuB2fhX79qQfiWAHU2qL8hoCWsP25HuB2XVkizKAbOwamWkjo6BGjSKXXPYSkpiVp)Hjm2zTvy8WaZVkizeJNgysFb3NAGNxRa4y4iA(EIduSwGaRLqPse603r089exZ(694AtQ2jsVwaQnrTyQu780wdBovmtSXeVgyLeh9nWdWoTmDKzj4ZMWyN1aMXddm)QGKrmEAGj9fCFQbEETcGJHJO57joqXAbcSwcLkrOtFhrZ3tCn7R3JRnPANi9AbO2e1QIzInM41aRK4OVbEqBcNPJ8RbyZMWyNLPB8WaZVkizeJNgysFb3NAGfahdho0wsBexZ(694AHATtuBIAHUwmvQDEARHnNkMj2yIxdSsIJ(gyI(ewMfahddSa4yKF1NnW4qBjTrmHXolT24HbMFvqYigpnWK(cUp1apVwbWXWHdTL0gXHdL4TwOw7e1ceyTcGJHdhAlPnIRzF9ECTjHUwROwaQnrTyrwkZH2q4axBsORfvTpvqYo8ihAdHdCTjQDETH2q4WfNpNdAg54ATOwRRfGAHYAXISuMdTHWbU2KQLqXrTjBTw6MTbwjXrFdmo0EOsPjm2zPLgpmW8RcsgX4PbM0xW9Pg451gQK)WHdTL0gXXVkizKAtu78Afahdho0wsBehouI3AHATtulqG1kaogoCOTK2iUM917X1Me6ANDTjQvaCmCAt0)izrqjwBhouI3AHATwrTaulqG1cDTHk5pC4qBjTrC8RcsgP2e1oVwbWXWPnr)JKfbLyTD4qjERfQ1Af1ceyTcGJHJO57joqXAbOwaQnrTyrwkZH2q4a7WH2dvkRfQ1IQ2NkizhEKdTHWbU2e1kaogoj4RDM9fPt52N)WHdL4TwlQvaCmCyQu7m7lsNYTp)HdhkXBTqTwaV2e1kaogomvQDM9fPt52N)WHdL4TwOw7e1MOwbWXWjbFTZSViDk3(8hoCOeV1c1ANO2e1oVwORvNH7lyhoAw9EpKmo0g74xfKmsTabwl01kaogoIMVN4afRfiWAHUwXMr1HdTXGneUwaQfiWAdTHWHloFoh0mYX1cv01YwjtadohNpxluwRIJwLzr6uURnzRfWtVwGaRf6AXuP25PTg2CQyMyJjEnWkjo6BGXH2yWgcBcJDwoHXddm)QGKrmEAGvsC03aJb)X1SbM0xW9Pg4MhnJTPcsU2e1oVwvmtSXeV1MO2HKs7ANxBOneoCX5Z5GMroU2KT251AzTqzTyrwkZ2uCW1cqTauluwlwKLYCOneoW1Me6Ab8ATOwSilL5qBiCGRnrTZRflYszo0gch4AtQwRR1IAdvYF4IP3N9P0h74xfKmsTabwlcnC(u6pUMDXr8EpKAbO2e1oVwORvNH7lyhoAw9EpKmo0g74xfKmsTabwl01kaogoIMVN4afRfiWAHUwXMr1Hb)X1CTaulagysAejNdTHWb2yN1MWyNLaUXddm)QGKrmEAGvsC03a7tP)4A2at6l4(udCZJMX2ubjxBIANxRkMj2yI3Atu7qsPDTZRn0gchU485CqZihxBYw78ATSwOSwSilLzBko4AbOwaQfkRflYszo0gch4AtcDTwT2e1oVwORvNH7lyhoAw9EpKmo0g74xfKmsTabwl01kaogoIMVN4afRfiWAHUwXMr15tP)4AUwaQfadmjnIKZH2q4aBSZAtySZYzB8WaZVkizeJNgyLeh9nW4GLsTZdP2SbM0xW9Pg4MhnJTPcsU2e1oVwvmtSXeV1MO2HKs7ANxBOneoCX5Z5GMroU2KT251AzTqzTyrwkZ2uCW1cqTauBsOR1Q1MO251cDT6mCFb7WrZQ37HKXH2yh)QGKrQfiWAHUwbWXWr089ehOyTabwl01k2mQoCWsP25HuBUwaQfadmjnIKZH2q4aBSZAtySZsRA8WaZVkizeJNgysFb3NAGvXmXgt8AGvsC03a)80SpL(MWyNLjVXddm)QGKrmEAGj9fCFQbwfZeBmXRbwjXrFdSnvoY(u6BcJDwAfgpmW8RcsgX4PbM0xW9PgyvmtSXeVgyLeh9nWdqPm7tPVjm2zjGz8WaZVkizeJNgysFb3NAGfahdhMk1oZ(I0PC7ZF4WHs8wluRDIAtu78AvXmXgt8wlqG1kaogoj4RDM9fPt52N)WHdL4Tw01orTauBIANx78Afahd3uT7J2z6iZsWNDGI1ceyTcGJHtc(ANzFr6uU95pCGI1ceyTyrwkZH2q4axBsOR1YAtul01kaogomvQDM9fPt52N)Wbkwla1MO251cDT6mCFb7WrZQ37HKXH2yh)QGKrQfiWAHUwbWXWr089ehOyTabw78AHUwXMr1jbFTZ4OpVCTjQf6AdvYF4UNO9RXrFh)QGKrQfiWAfBgvhMk1opT1WwTaula1ceyT6mCFb7WrZQ37HKXH2yh)QGKrQnrTcGJHJO57joqXAtuRyZO6WuP25PTg2QfadSsIJ(gyj4RDgh95LnHXUjs34HbMFvqYigpnWK(cUp1aRZW9fSdhnREVhsghAJDT(ERfQ1orTabwl01kaogoIMVN4afRfiWAHUwXMr1HPsTZtBnSzGvsC03aJPsTZtBnSzcJDtyTXddSsIJ(gym4pUMnW8RcsgX4PjmHbwSzc1xqdJhg7S24HbMFvqYigpnHXolnEyG5xfKmIXttySBcJhgy(vbjJy80eg7aCJhgy(vbjJy80atfnWyomWkjo6BGrv7tfKSbgvvcYgyaVwlQvNH7lyN2e9psweuI12XVkizKATO2qL8hoCOTK2io(vbjJuRf1oVwDgUVGD4Oz179qY4qBSR13BTjvRL1MOwDgUVGDAt0)izrqjwBh)QGKrQfGANvTqxBOs(dxm9(SpL(yh)QGKrmWOQD(vF2aJh5qBiCGnHXUzB8WaRK4OVb2NsFV3Nh023aZVkizeJNMWyNvnEyG5xfKmIXttySl5nEyGvsC03alsJJ(gy(vbjJy80eg7ScJhgyLeh9nWyQu780wdBgy(vbjJy80eMWegyu5gF03yNLPBnGLoGBz6oRt(0tEd8uT)7HGnWtAFrAhmsTwwRsIJ(1kpCGDvkdmwKjg7SoDlnWInDCs2adOA9uL6t4AtMn4HuPauT2IqedfrbfixyduWrO(OGpFqPgh9jTocuWNpbLkfGQnf4Z1APvTVwlt3AaR2zvB6agu06zxPQuaQ2j3M(qymuSsbOANvTjhccJulmvQDTEYQVRsbOANvTtUn9HWi1gAdHJ8nQLOygxBqRLKgrY5qBiCGDvkav7SQn5qGcaXbJulEKdTHWbUwu1(ubjx7G21Qii0VwCAFOwPRsbOANvTWNVO8gPvBYnd3xW1gTErTsk1lOiU25i0FsIAbXCTG)ZegJ1oTArv7tfKCT40(qTsaCvkav7SQDsH9POYi1MmCOYY0Qfw86lQLqFKlo6x7G21o5SKXXPYAto5b595pGcRnnk4KiL1AtrLR9IAPDTPrbRDk9NKOw89eU2j9)CJQgCThUwBheBCxRyF0(I0CvQkfGQDs1kzcyWi1kWdAZ1sO(cAuRad5ESR2KJqyXax7t)zztB)bOSwLeh9X1sFzAUkLsIJ(yNyZeQVGgOhsf7TsPK4Op2j2mH6lOHfOrzqPivkLeh9XoXMjuFbnSankkieF(dno6xPQuaQ2KBgUVGRfvTpvqY4kfGQvjXrFStSzc1xqdlqJcQAFQGKT)vFgTotgJThvvcYO1z4(c2HJMvV3djJdTXUwFVvkavRsIJ(yNyZeQVGgwGgfu1(ubjB)R(mADMSkApQQeKrRZW9fStBI(hjlckXA7A99wPQuaQw4q7HkL1IATWH2yWgcxBOneoQLag0XOsPK4Op2j2mH6lOHfOrbvTpvqY2)QpJgpYH2q4aBpvenMd7rvLGmAa3cDgUVGDAt0)izrqjwBh)QGKrSiuj)HdhAlPnIJFvqYiwmxNH7lyhoAw9EpKmo0g7A99MKLj0z4(c2Pnr)JKfbLyTD8RcsgbGzbDOs(dxm9(SpL(yh)QGKrQukjo6JDIntO(cAybAu8P03795bT9Ruvkavl8RIyB0O2wpKAfahdgPwCObUwbEqBUwc1xqJAfyi3JRvFKAfBEwI0iUhsThUwe6ZUkLsIJ(yNyZeQVGgwGgf8RIyB0iJdnWvkLeh9XoXMjuFbnSankI04OFLsjXrFStSzc1xqdlqJcMk1opT1WwLQsbOANuTsMagmsTmQCNwTX5Z1g24Avsq7ApCTkQ6jvbj7Qukjo6JrJPsTZcS6xPusC0hBbAuePXrF7VbAbWXWr089exZ(694KSALsjXrFSfOrrqsPi5byNM93aTa4y4iA(EIduSsPK4Op2c0OiWnMBV3dX(BGwaCmCenFpXbkwPusC0hBbAu0MOpNdA38h2Fd0cGJHJO57joqXkLsIJ(ylqJI8GylWzOaqei(8h2Fd0cGJHJO57joqXkLsIJ(ylqJY4AwqsPi2Fd0cGJHJO57joqXkLsIJ(ylqJI(eghTkZevkT)gOfahdhrZ3tCGIvQkfGQDYtM4kLsIJ(ylqJciMZxW(2)QpJwqL84Aol06tSz)nqZtg4jkYioRNnGz1jspbHsLi0PVJO57jUM917Xjnr6vkLeh9XwGgfqmNVG9T)vFgnsZksgIuronOnolOiqy7VbAEYaprrgXzTvTgWs3YeekvIqN(oIMVN4A2xVhN0ePxPusC0hBbAuaXC(c23(x9z06mGnh2O4m(Eimswuc6Rqy7VbAEYaprrgXzTvTEIKp5tqOujcD67iA(EIRzF9ECstKELsjXrFSfOrbeZ5lyF7F1NrhhcJdA7Njue2kT)gO5jd8efzeN1wD2Zo5TALsjXrFSfOrbeZ5lyFS93anHsLi0PVJO57jUM917Xjnr6vkLeh9XwGgLPA3hTZ0rMLGpxPusC0hBbAuU)5gvny7VbADgUVGDYdvwMwglE9fo(vbjJKyoHsLi0PV7EI2Vgh9Dn7R3JHQLabsOujcD67iSKXXPYSkpiVp)HRzF9EmuT2saQukjo6JTank3t0(14OV93ancnCyWFCn7A2xVhNKvKaHgoFk9hxZUM917XjzTLjMJqdhoyPu78qQn7A2xVhNKvbce6qL8hoCWsP25HuB2XVkizeasOIzInM4nb0cGJHJO57joqXkfGQnzs)jjQvjbOkLPvlXgt8w7G21MmCOYY0Qfw86lQ1g3muyTPrbNePSwBkQCTxulTRnnkyTtP)KeUkLsIJ(ylqJcHLmoovMv5b595pS)gOvC0QmlsNYDsOb80taTa4y4iA(EIdumHkMj2yI3eZrOHdd(JRzxZ(694KSmbcnC(u6pUMDXr8EpKeZrOHdhSuQDEi1MDXr8EpeGaHouj)HdhSuQDEi1MD8RcsgbaaQukjo6JTankdWoTmDKzj4Z2Fd0ZfahdhrZ3tCGIabsOujcD67iA(EIRzF9ECstKoajWuP25PTg2CQyMyJjERukjo6JTankdAt4mDKFnaB2(BGEUa4y4iA(EIdueiqcLkrOtFhrZ3tCn7R3JtAI0biHkMj2yI3kvLcq1clYpc34kLsIJ(ylqJcrFclZcGJH9V6ZOXH2sAJy)nqlaogoCOTK2iUM917XqDIeqJPsTZtBnS5uXmXgt8wPusC0hBbAuWH2dvkT)gONlaogoCOTK2ioCOeVqDcGafahdho0wsBexZ(694KqBfaKalYszo0gch4KqJQ2NkizhEKdTHWboX8qBiC4IZNZbnJCSfwdauIfzPmhAdHdCsekoswlDZUsPK4Op2c0OGdTXGne2(BGEEOs(dho0wsBeh)QGKrsmxaCmC4qBjTrC4qjEH6eabkaogoCOTK2iUM917XjHE2jeahdN2e9psweuI12HdL4fQwbaabcDOs(dho0wsBeh)QGKrsmxaCmCAt0)izrqjwBhouIxOAfabkaogoIMVN4afbaGeyrwkZH2q4a7WH2dvkHkQAFQGKD4ro0gch4ecGJHtc(ANzFr6uU95pC4qjETqaCmCyQu7m7lsNYTp)HdhkXlub8ecGJHdtLANzFr6uU95pC4qjEH6ejeahdNe81oZ(I0PC7ZF4WHs8c1jsmhADgUVGD4Oz179qY4qBSJFvqYiabcTa4y4iA(EIdueiqOfBgvho0gd2qyaacm0gchU485CqZihdv0SvYeWGZX5ZqPIJwLzr6uUtwapDGaHgtLANN2AyZPIzInM4TsvPauTjtQh4kLsIJ(ylqJcg8hxZ2tsJi5COneoWOT2(BGU5rZyBQGKtmxfZeBmXBIHKs75H2q4WfNpNdAg54KDULqjwKLYSnfhmaaaLyrwkZH2q4aNeAa3cSilL5qBiCGtmhlYszo0gch4KS2IqL8hUy69zFk9Xo(vbjJaeicnC(u6pUMDXr8EpeasmhADgUVGD4Oz179qY4qBSJFvqYiabcTa4y4iA(EIdueiqOfBgvhg8hxZaaqLsjXrFSfOrXNs)X1S9K0isohAdHdmART)gOBE0m2Mki5eZvXmXgt8MyiP0EEOneoCX5Z5GMroozNBjuIfzPmBtXbdaaqjwKLYCOneoWjH2QjMdTod3xWoC0S69EizCOn2XVkizeGaHwaCmCenFpXbkcei0InJQZNs)X1maauPusC0hBbAuWblLANhsTz7jPrKCo0gchy0wB)nq38OzSnvqYjMRIzInM4nXqsP98qBiC4IZNZbnJCCYo3sOelYsz2MIdgaascTvtmhADgUVGD4Oz179qY4qBSJFvqYiabcTa4y4iA(EIdueiqOfBgvhoyPu78qQndaavQkfGQnzm)CRbTXvkLeh9XwGgLNNM9P03(BGwfZeBmXBLsjXrFSfOrXMkhzFk9T)gOvXmXgt8wPusC0hBbAugGsz2NsF7VbAvmtSXeVvkLeh9XwGgfj4RDgh95LT)gOfahdhMk1oZ(I0PC7ZF4WHs8c1jsmxfZeBmXlqGcGJHtc(ANzFr6uU95pC4qjErpbajMpxaCmCt1UpANPJmlbF2bkceOa4y4KGV2z2xKoLBF(dhOiqGyrwkZH2q4aNeAltaTa4y4WuP2z2xKoLBF(dhOiajMdTod3xWoC0S69EizCOn2XVkizeGaHwaCmCenFpXbkce4COfBgvNe81oJJ(8YjGouj)H7EI2Vgh9D8RcsgbiqXMr1HPsTZtBnSbaaabQZW9fSdhnREVhsghAJD8RcsgjHa4y4iA(EIdumHyZO6WuP25PTg2aOsPK4Op2c0OGPsTZtBnSz)nqRZW9fSdhnREVhsghAJDT(EH6eabcTa4y4iA(EIdueiqOfBgvhMk1opT1WwLcq1MmsLYWwdw7G216trL95pQukjo6JTankyWFCnBctyma]] )


end