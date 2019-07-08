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

            spend = -3,
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


    spec:RegisterPack( "Balance", 20190707.2040, [[dG0A2aqikWJOkYLesLnrv6tcPuJsQYPKkTkiHEff0SqLClHu1UOYVGKggvvDmkKLrvPNjKmnPcDnPc2gKiFJQOACcP4COsvRdvQ07GeKMhQuUhiTpivhesuTqQkEiQuXeHeuxesGAJcPK6JcPKCsHuIvkuntibXoPqTuibYtvvtLQWEr5VcgmWHjTyu1JHAYqCzInlLpJkgTq50kTAib8AHy2u62GA3Q8BedNIooKOSCjphPPl66QY2Hu(UuvJNQOCEQQSEPIMpi2VIzgX8G9r0uyg7R)gX9(75(75oF9VJr5l3Z(PFMc7BQ4ikhH9pfwyFFuREyH9nv)SefH5b7tjVclSFSmnPCxurLZMXE8ombgv6c)SAUKdxAlrLUWyuzF(3AZOLJXZ(iAkmJ91FJ4E)9C)9CNV(hfkX(6lJrk2)VWCh2p2IGihJN9rekM990a8rT6HLbGcxVfzI7Pbelttk3fvu5SzShVdtGrLUWpRMl5WL2suPlmg1jUNgq8N1Vb45CnaF93iUFar)a81FUBuDyIpX90a4oX0JJq5UtCpnGOFaOCeebzaFIvRb4JOWUjUNgq0paUtm94iidi1IJKHTnaSsf6asYaW(HTsi1IJKu3e3tdi6hWFHnTBZVbGY7uQnLbKLU5aSesKNjDa9qix0ohWJkd4DNGfkvl)gaAATkVvga1VlvpRRBI7Pbe9dafKatqtqgakKfnX63a(MBT5aWKdzZLCdOrQbWDeRqZvTdaLBxohSCjk0b4h5fTT2betrtgWMdGudWpYBa9jx0ohaDpSmGOL7KcnnLbS0beB5etQbywlP20ph7BxAszEW(istF2K5bZyJyEW(koxYX(uIvRaVOWSVCkVvqy(WsMX(Y8G9Lt5TccZh2hxBk1QSp)R1CynSh2vcSUhDaOpauI9vCUKJ9nj5sowYmokMhSVCkVvqy(W(4AtPwL95FTMdRH9WUNj7R4Cjh7ZBjeKq7v(XsMXDK5b7lNYBfeMpSpU2uQvzF(xR5WAypS7zY(koxYX(8srLkYECyjZ4oW8G9Lt5TccZh2hxBk1QSp)R1CynSh29mzFfNl5yFTW6jHKuLCjlzgJsmpyF5uERGW8H9X1MsTk7Z)Anhwd7HDpt2xX5so23UCIL0akWdHdSCjlzg75mpyF5uERGW8H9X1MsTk7Z)Anhwd7HDpt2xX5so2VTLWBjeewYmoAyEW(YP8wbH5d7JRnLAv2N)1AoSg2d7EMSVIZLCSVEyHMLAdy1AzjZyUN5b7lNYBfeMpSpU2uQvzFbL9wttbXXRwPTLe4l9WXgG3bGjelcP)5WAypSReyDp6aqFar5p7FkSW(8QvABjb(spCm2xX5so2NxTsBljWx6HJXsMXg5pZd2xoL3kimFyFCTPuRY(ck7TMMcIdPefjWXQiRMKIg4veoYa8oamHyri9phwd7HDLaR7rha6dik)z)tHf2hPefjWXQiRMKIg4veoc7R4Cjh7JuIIe4yvKvtsrd8kchHLmJnYiMhSVCkVvqy(W(4AtPwL9fu2BnnfeN25RKmgHgO7XrqcM2hSYrgG3bGjelcP)5WAypSReyDp6aqFar5p7FkSW(ANVsYyeAGUhhbjyAFWkhH9vCUKJ91oFLKXi0aDpocsW0(GvoclzgBKVmpyF5uERGW8H9X1MsTk7lOS3AAkiUCreAsk4aMGiEg7FkSW(5Ii0KuWbmbr8m2xX5so2pxeHMKcoGjiINXsMXgffZd2xoL3kimFyFCTPuRY(ycXIq6FoSg2d7kbw3Joa0hqu(Z(koxYX(pQe2uGPSKzSrDK5b7lNYBfeMpSpU2uQvzFmHyri9phwd7HDLaR7rha6dik)zFfNl5yFElHGeiTqgtcYjW(XsMXg1bMhSVCkVvqy(W(4AtPwL9riPJ(U2wIReyDp6aqFag5)a8oaes6GjKRTL4kbw3Joa0hGr(paVdO3amyaPALlD0uSwTcnRwItoL3kidacKbGqshnfRvRqZQL4kbw3Joa0hGr(pGUdW7amya8VwZH1WEy3ZCaEhqVbO0SuBWK0xQbWTb4Bhgaeidatiwes)ZH1WEyxjW6E0bG(aIY)b0L9vCUKJ9Hfys5xG0c2hErciLOWuwYm2iuI5b7R4Cjh7B(QT53ECc8wLMSVCkVvqy(WsMXg55mpyFfNl5y)AnnTsyVa1uXc7lNYBfeMpSKzSrrdZd2xX5so2htoSCzPPGeAwfwyF5uERGW8HLmJnI7zEW(YP8wbH5d7JRnLAv2N)1AUsWrScLgAKclUN5aGaza5cldGBdOdSVIZLCSFgtcVJN8oKqJuyHLmJ91FMhSVIZLCSFFszrqt2lucLC6Hf2xoL3kimFyjZyFnI5b7R4Cjh73i4hvqcANsTPe4ffM9Lt5TccZhwYm2xFzEW(koxYX(CEAHS6fiTG2PuKmg7lNYBfeMpSKzSVrX8G9vCUKJ9ZyK6OSVCkVvqy(WsMX(2rMhSVIZLCSFFTQLubsli23jSVCkVvqy(WsMX(2bMhSVCkVvqy(W(4AtPwL9nya8VwZH1WEy3ZCaEhqVbW)AnhSatk)cKwW(WlsaPefM6EMdacKb0Ba9gaMqSiK(NdwGjLFbslyF4fjGuIctDLaR7rha6dWx)haeidWGbiuQCyXblWKYVaPfSp8IeqkrHPoyffGudO7a8oa1mGJj4idW7auAwQnys6l1aqh6a6O)dO7a6oaVdO3a4FTMdwGjLFbslyF4fjGuIctDpZbabYauZaoMGJmGUdW7aqiPJ(U2wIReyDp6aqFarZa8oaes6GjKRTL4kbw3Joa0hGr(oaVdO3aqiPJMI1QvOz1sCLaR7rha6daLgaeidWGbKQvU0rtXA1k0SAjo5uERGmGUSVIZLCS)EyTonxYXsMX(IsmpyF5uERGW8H9X1MsTk7BWa4FTMdRH9WUN5a8oGEdG)1AoybMu(fiTG9HxKasjkm19mhaeidO3a6namHyri9phSatk)cKwW(WlsaPefM6kbw3Joa0hGV(paiqgGbdqOu5WIdwGjLFbslyF4fjGuIctDWkkaPgq3b4DaQzahtWrgG3bO0SuBWK0xQbGo0b0r)hq3b0DaEhqVbyWa0oLAtXzx0eRFbQ5wB6Kt5TcYaGaza8VwZzx0eRFbQ5wB6EMdO7a8oGEdaHKo67ABjUsG19Oda9b47a8oaes6GjKRTL4YfhzpodW7a6naes6OPyTAfAwTexU4i7XzaqGmadgqQw5shnfRvRqZQL4Kt5TcYa6oGUSVIZLCSpwScnx1gu7Y5GLlzjZyF9CMhSVCkVvqy(W(4AtPwL97na(xR5WAypS7zoaiqgaMqSiK(NdRH9WUsG19Oda9beL)dO7a8oakXQvOFPzmNAgWXeCe2xX5so2V9k)cKwqSVtyjZyFJgMhSVCkVvqy(W(4AtPwL97na(xR5WAypS7zoaiqgaMqSiK(NdRH9WUsG19Oda9beL)dO7a8oa1mGJj4iSVIZLCSFJuyjqAHtZxjSKzSVCpZd2xoL3kimFyFfNl5yFSEyXg4FTg7JRnLAv2N)1AoAQLLuiUsG19OdGBdiQb4DagmakXQvOFPzmNAgWXeCe2N)1AHtHf2NMAzjfclzghL)mpyF5uERGW8H9X1MsTk73Ba8VwZrtTSKcXrtfhzaCBarnaiqga)R1C0ullPqCLaR7rha6qhq0mGUdW7aOMI1gsT4ijDaOdDaOP1Q8wXrBHulosshG3b0BaPwCK0LlSessazLby4amAaDhakoaQPyTHulossha6datO5aIUb4RRdSVIZLCSpn1QPwllzghLrmpyF5uERGW8H9X1MsTk73BaPALlD0ullPqCYP8wbzaEhqVbW)Anhn1YskehnvCKbWTbe1aGaza8VwZrtTSKcXvcSUhDaOdDaDyaEha)R1CAH1BXbZNLQLJMkoYa42aIMb0DaqGmadgqQw5shn1YskeNCkVvqgG3b0Ba8VwZPfwVfhmFwQwoAQ4idGBdiAgaeidG)1AoSg2d7EMdO7a6oaVdGAkwBi1IJKuhn1QPw7a42aqtRv5TIJ2cPwCKKoaVdG)1Ao770kiWMK(sblx6OPIJmadha)R1CuIvRGaBs6lfSCPJMkoYa42a64a8oa(xR5OeRwbb2K0xky5shnvCKbWTbe1a8oa(xR5SVtRGaBs6lfSCPJMkoYa42aIAaEhqVbyWa0oLAtXrZs0i7XjqtTOUsVidacKbyWa4FTMdRH9WUN5aGazagmaZsqZrtTOVIJmGUdacKbKAXrsxUWsijbKvga3GoaXZe8lLqUWYaqXbO0SuBWK0xQbeDdOJ(paiqgGbdGsSAf6xAgZPMbCmbhH9vCUKJ9PPw0xXryjZ4O8L5b7lNYBfeMpSpU2uQvzF(xR5WAypS7zoaVdG)1AoSg2d7kbw3JoaUnaoyehS6zdW7a0oLAtXrZs0i7XjqtTOUsVidW7aqiPdMqU2wIReyDp6aqFaLaR7rzFfNl5yF67ABjSKzCurX8G9Lt5TccZh2hxBk1QSp)R1CynSh29mhG3bW)Anhwd7HDLaR7rha3gahmIdw9Sb4DaANsTP4OzjAK94eOPwuxPxe2xX5so2hMqU2wclzghvhzEW(YP8wbH5d7R4Cjh7tFxBlH9X1MsTk7xsReAmL3kdW7auZaoMGJmaVdOzjKAa9gqQfhjD5clHKeqwzar3a6naFhakoaQPyTHyknLb0DaDhakoaQPyTHulossha6qhaww7a6nGMLqQb0Ba(oGOBautXAdPwCKKoGUdafhGrUomGUdWWb47aqXbqnfRnKAXrs6a8oGEdGAkwBi1IJK0bG(amAagoGuTYLUS)Ebyc5Oo5uERGmaiqgacjDWeY12sC5IJShNb0DaEhqVbyWa0oLAtXrZs0i7XjqtTOUsVidacKbyWa4FTMdRH9WUN5aGazagmaZsqZrFxBlzaDhG3b0Ba8VwZH1WEyxjW6E0bG(akbw3JoaiqgGbdG)1AoSg2d7EMdOl7J9dBLqQfhjPmJnILmJJQdmpyF5uERGW8H9vCUKJ9HjKRTLW(4AtPwL9lPvcnMYBLb4DaQzahtWrgG3b0SesnGEdi1IJKUCHLqsciRmGOBa9gGVdafha1uS2qmLMYa6oGUdafha1uS2qQfhjPdaDOdaLgG3b0BagmaTtP2uC0SenYECc0ulQR0lYaGazagma(xR5WAypS7zoaiqgGbdWSe0CWeY12sgq3b4Da9ga)R1CynSh2vcSUhDaOpGsG19OdacKbyWa4FTMdRH9WUN5a6Y(y)WwjKAXrskZyJyjZ4OqjMhSVCkVvqy(W(koxYX(0uSwTcnRwc7JRnLAv2VKwj0ykVvgG3bOMbCmbhzaEhqZsi1a6nGulos6YfwcjjGSYaIUb0Ba(oauCautXAdXuAkdO7a6oa0HoGomaVdO3amyaANsTP4OzjAK94eOPwuxPxKbabYamya8VwZH1WEy3ZCaqGmadgGzjO5OPyTAfAwTKb0L9X(HTsi1IJKuMXgXsMXr55mpyF5uERGW8H9X1MsTk7RMbCmbhH9vCUKJ9pPFaMqowYmoQOH5b7lNYBfeMpSpU2uQvzF1mGJj4iSVIZLCSFm12cWeYXsMXrX9mpyF5uERGW8H9X1MsTk7RMbCmbhH9vCUKJ9BpRnatihlzg3r)zEW(YP8wbH5d7JRnLAv2N)1AokXQvqGnj9LcwU0rtfhzaCBarnaVdO3auZaoMGJmaiqga)R1C23PvqGnj9LcwU0rtfhzaqhqudO7a8oGEdO3a4FTMRVw1sQaPfe77e3ZCaqGma(xR5SVtRGaBs6lfSCP7zoaiqga1uS2qQfhjPdaDOdW3b4Dagma(xR5OeRwbb2K0xky5s3ZCaDhG3b0BagmaTtP2uC0SenYECc0ulQR0lYaGazagma(xR5WAypS7zoGUdacKbODk1MIJMLOr2JtGMArDLErgG3bW)Anhwd7HDpZb4DaMLGMJsSAf6xAgBaDzFfNl5yF770kqZAJiSKzChnI5b7lNYBfeMpSpU2uQvzFTtP2uC0SenYECc0ulQR0lYa42aIAaqGmadga)R1CynSh29mhaeidWGbywcAokXQvOFPzm2xX5so2NsSAf6xAgJLmJ7OVmpyFfNl5yF67ABjSVCkVvqy(WswY(MLGjW8AY8GzSrmpyF5uERGW8HLmJ9L5b7lNYBfeMpSKzCumpyF5uERGW8HLmJ7iZd2xoL3kimFyFIj7tLK9vCUKJ9rtRv5Tc7JMAFc73r2hnTcNclSpTfsT4ijLLmJ7aZd2xoL3kimFyFIj7RiiSVIZLCSpAATkVvyF0u7tyFJyFCTPuRY(ANsTP40cR3IdMplvlNCkVvqyF00kCkSW(0wi1IJKuwYmgLyEW(YP8wbH5d7tmzFfbH9vCUKJ9rtRv5Tc7JMAFc7Be7JRnLAv2pvRCPJMAzjfItoL3kiSpAAfofwyFAlKAXrsklzg75mpyF5uERGW8H9jMSVIGW(koxYX(OP1Q8wH9rtTpH9nI9X1MsTk7RDk1MIJMLOr2JtGMArDLErga6dW3b4DaANsTP40cR3IdMplvlNCkVvqyF00kCkSW(0wi1IJKuwYmoAyEW(YP8wbH5d7tmzF6JN9vCUKJ9rtRv5Tc7JMAFc7Be7JRnLAv23GbKQvU0L93latih1jNYBfe2hnTcNclSpTfsT4ijLLmJ5EMhSVIZLCSpmHCr2l0ifm7lNYBfeMpSKzSr(Z8G9vCUKJ9nj5so2xoL3kimFyjZyJmI5b7R4Cjh7tjwTc9lnJX(YP8wbH5dlzjlzF0KIUKJzSV(Be37pk5l3783)oW9SFFTU94qz)OfytsLcYa8DakoxYna7stQBIZ(MfPTwH990a8rT6HLbGcxVfzI7Pbelttk3fvu5SzShVdtGrLUWpRMl5WL2suPlmg1jUNgq8N1Vb45CnaF93iUFar)a81FUBuDyIpX90a4oX0JJq5UtCpnGOFaOCeebzaFIvRb4JOWUjUNgq0paUtm94iidi1IJKHTnaSsf6asYaW(HTsi1IJKu3e3tdi6hWFHnTBZVbGY7uQnLbKLU5aSesKNjDa9qix0ohWJkd4DNGfkvl)gaAATkVvga1VlvpRRBI7Pbe9dafKatqtqgakKfnX63a(MBT5aWKdzZLCdOrQbWDeRqZvTdaLBxohSCjk0b4h5fTT2betrtgWMdGudWpYBa9jx0ohaDpSmGOL7KcnnLbS0beB5etQbywlP20p3eFI7PbGc2Ze8lfKbWlnsjdatG51Ca8cN9OUbGYXyXmPd4ix0htl42ZoafNl5OdGCw)CtCfNl5OoZsWeyEnH2SknYexX5soQZSembMxtdHIAJqqM4koxYrDMLGjW8AAiuu1hhy5snxYnXN4EAaO8oLAtzaOP1Q8wHoX90auCUKJ6mlbtG510qOOIMwRYBfUofwGQDgOuUqtTpbQ2PuBkoAwIgzpobAQf1v6fzI7PbO4Cjh1zwcMaZRPHqrfnTwL3kCDkSav7mOMCHMAFcuTtP2uCAH1BXbZNLQLR0lYeFI7Pb8tTAQ1oa0gWp1I(koYasT4i5aWVK0AtCfNl5OoZsWeyEnnekQOP1Q8wHRtHfO0wi1IJKuUqtTpbAhN4koxYrDMLGjW8AAiuurtRv5TcxNclqPTqQfhjPCrmHQiiCHMAFcuJ4ABq1oLAtXPfwVfhmFwQwo5uERGmXvCUKJ6mlbtG510qOOIMwRYBfUofwGsBHuloss5Iycvrq4cn1(eOgX12GMQvU0rtTSKcXjNYBfKjUIZLCuNzjycmVMgcfv00AvERW1PWcuAlKAXrskxetOkccxOP2Na1iU2guTtP2uC0SenYECc0ulQR0lc6(6v7uQnfNwy9wCW8zPA5Kt5TcYexX5soQZSembMxtdHIkAATkVv46uybkTfsT4ijLlIju6JNl0u7tGAexBdQbPALlDz)9cWeYrDYP8wbzIR4Cjh1zwcMaZRPHqrfMqUi7fAKcEIpX90a(NAsJrYbu6Ima(xRjidGMAshaV0iLmambMxZbWlC2Joa9qgGzjrVjjZ94mGLoaeYjUjUNgGIZLCuNzjycmVMgcfv6PM0yKmqtnPtCfNl5OoZsWeyEnnekQMKCj3exX5soQZSembMxtdHIkLy1k0V0m2eFI7PbGc2Ze8lfKbiOjLFdixyzazmzakoj1aw6au001Q8wXnXvCUKJcLsSAf4ffEIR4Cjh1qOOAsYLCCTnO8VwZH1WEyxjW6Eu0rPjUIZLCudHIkVLqqcTx5hxBdk)R1CynSh29mN4koxYrnekQ8srLkYEC4ABq5FTMdRH9WUN5exX5soQHqrvlSEsijvjxY12GY)Anhwd7HDpZjUIZLCudHIQD5elPbuGhchy5sU2gu(xR5WAypS7zoXvCUKJAiuuBBj8wcbHRTbL)1AoSg2d7EMtCfNl5Ogcfv9Wcnl1gWQ1Y12GY)Anhwd7HDpZj(e3tdG7GctN4koxYrnekQpQe2uG56uybkVAL2wsGV0dhJRTbvqzV10uqCg1bUhLIYFVycXIq6FoSg2d7kbw3JIEu(pXvCUKJAiuuFujSPaZ1PWcuKsuKahRISAskAGxr4iCTnOck7TMMcIZiuYiU3FF9IjelcP)5WAypSReyDpk6r5)exX5soQHqr9rLWMcmxNclq1oFLKXi0aDpocsW0(GvocxBdQGYERPPG4mcLmkkp3Z9IjelcP)5WAypSReyDpk6r5)exX5soQHqr9rLWMcmxNclqZfrOjPGdycI4zCTnOck7TMMcIZiuQdDWZrPjUIZLCudHI6JkHnfykxBdkMqSiK(NdRH9WUsG19OOhL)tCfNl5OgcfvElHGeiTqgtcYjW(X12GIjelcP)5WAypSReyDpk6r5)exX5soQHqrfwGjLFbslyF4fjGuIct5ABqriPJ(U2wIReyDpk6g5Vxes6GjKRTL4kbw3JIUr(7TNbPALlD0uSwTcnRwItoL3kiqGGqshnfRvRqZQL4kbw3JIUr(31Rb8VwZH1WEy3Z0BpLMLAdMK(sXnF7aeiycXIq6FoSg2d7kbw3JIEu(3DIR4Cjh1qOOA(QT53ECc8wLMtCfNl5Ogcf1AnnTsyVa1uXYexX5soQHqrftoSCzPPGeAwfwM4koxYrnekQzmj8oEY7qcnsHfU2gu(xR5kbhXkuAOrkS4EMqGKlSWTomXvCUKJAiuu7tklcAYEHsOKtpSmXvCUKJAiuuBe8JkibTtP2uc8IcpXvCUKJAiuu580cz1lqAbTtPizSjUIZLCudHIAgJuhDIR4Cjh1qOO2xRAjvG0cI9DYe3tdqX5soQHqrDVtk00u4ABq1oLAtXzx0eRFbQ5wB6Kt5TcI3EycXIq6FU9WADAUKZvcSUhLB(cbcMqSiK(NdlwHMRAdQD5CWYLUsG19OCZiF7oXvCUKJAiuu3dR1P5soU2gud4FTMdRH9WUNP3E8VwZblWKYVaPfSp8IeqkrHPUNjei96HjelcP)5Gfys5xG0c2hErciLOWuxjW6Eu091FiqmqOu5WIdwGjLFbslyF4fjGuIctDWkkaP66vnd4ycoIxLMLAdMK(sHo0o6F3UE7X)AnhSatk)cKwW(WlsaPefM6EMqGOMbCmbhPRxes6OVRTL4kbw3JIE04fHKoyc5ABjUsG19OOBKVE7HqshnfRvRqZQL4kbw3JIokbbIbPALlD0uSwTcnRwItoL3kiDN4koxYrnekQyXk0CvBqTlNdwUKRTb1a(xR5WAypS7z6Th)R1CWcmP8lqAb7dVibKsuyQ7zcbsVEycXIq6FoybMu(fiTG9HxKasjkm1vcSUhfDF9hcedekvoS4Gfys5xG0c2hErciLOWuhSIcqQUEvZaoMGJ4vPzP2GjPVuOdTJ(3TR3EgODk1MIZUOjw)cuZT20jNYBfeiq4FTMZUOjw)cuZT209m76ThcjD0312sCLaR7rr3xViK0btixBlXLloYEC82dHKoAkwRwHMvlXLloYECGaXGuTYLoAkwRwHMvlXjNYBfKUDN4koxYrnekQTx5xG0cI9DcxBdAp(xR5WAypS7zcbcMqSiK(NdRH9WUsG19OOhL)D9sjwTc9lnJ5uZaoMGJmXvCUKJAiuuBKclbslCA(kHRTbTh)R1CynSh29mHabtiwes)ZH1WEyxjW6Eu0JY)UEvZaoMGJmXN4EAaFt5qKIoXvCUKJAiuuX6HfBG)1ACDkSaLMAzjfcxBdk)R1C0ullPqCLaR7r5wuEnGsSAf6xAgZPMbCmbhzIR4Cjh1qOOstTAQ1Y12G2J)1AoAQLLuioAQ4iClkiq4FTMJMAzjfIReyDpk6qJMUEPMI1gsT4ijfDOOP1Q8wXrBHuloss92l1IJKUCHLqsciRyOrDrrQPyTHulossrhtOz05RRdtCfNl5OgcfvAQf9vCeU2g0EPALlD0ullPqCYP8wbXBp(xR5OPwwsH4OPIJWTOGaH)1AoAQLLuiUsG19OOdTdE5FTMtlSEloy(SuTC0uXr4w00fceds1kx6OPwwsH4Kt5TcI3E8VwZPfwVfhmFwQwoAQ4iClAGaH)1AoSg2d7EMD76LAkwBi1IJKuhn1QPwl3qtRv5TIJ2cPwCKK6L)1Ao770kiWMK(sblx6OPIJyi)R1CuIvRGaBs6lfSCPJMkoc36Ox(xR5OeRwbb2K0xky5shnvCeUfLx(xR5SVtRGaBs6lfSCPJMkoc3IYBpd0oLAtXrZs0i7XjqtTOUsViqGya)R1CynSh29mHaXaZsqZrtTOVIJ0fcKulos6YfwcjjGSc3GkEMGFPeYfwqrLMLAdMK(sfDD0FiqmGsSAf6xAgZPMbCmbhzIR4Cjh1qOOsFxBlHRTbL)1AoSg2d7EME5FTMdRH9WUsG19OCJdgXbREMxTtP2uC0SenYECc0ulQR0lIxes6GjKRTL4kbw3JIEjW6E0jUIZLCudHIkmHCTTeU2gu(xR5WAypS7z6L)1AoSg2d7kbw3JYnoyehS6zE1oLAtXrZs0i7XjqtTOUsVit8jUNgakmXd6exX5soQHqrL(U2wcxy)WwjKAXrskuJ4ABqlPvcnMYBfVQzahtWr82Ses1l1IJKUCHLqsciReD98ffPMI1gIP0u62ffPMI1gsT4ijfDOyzT9AwcP65B0rnfRnKAXrsAxu0ixh6AOVOi1uS2qQfhjPE7rnfRnKAXrsk6gzyQw5sx2FVamHCuNCkVvqGabHKoyc5ABjUCXr2JtxV9mq7uQnfhnlrJShNan1I6k9IabIb8VwZH1WEy3Zecedmlbnh9DTTKUE7X)Anhwd7HDLaR7rrVeyDpkeigW)Anhwd7HDpZUtCfNl5Ogcfvyc5ABjCH9dBLqQfhjPqnIRTbTKwj0ykVv8QMbCmbhXBZsivVulos6YfwcjjGSs01ZxuKAkwBiMstPBxuKAkwBi1IJKu0HIsE7zG2PuBkoAwIgzpobAQf1v6fbced4FTMdRH9WUNjeigywcAoyc5ABjD92J)1AoSg2d7kbw3JIEjW6EuiqmG)1AoSg2d7EMDN4koxYrnekQ0uSwTcnRwcxy)WwjKAXrskuJ4ABqlPvcnMYBfVQzahtWr82Ses1l1IJKUCHLqsciReD98ffPMI1gIP0u62fDODWBpd0oLAtXrZs0i7XjqtTOUsViqGya)R1CynSh29mHaXaZsqZrtXA1k0SAjDN4tCpnGOvYjLMKIoXvCUKJAiuupPFaMqoU2gu1mGJj4itCfNl5Ogcf1yQTfGjKJRTbvnd4ycoYexX5soQHqrT9S2amHCCTnOQzahtWrM4koxYrnekQ23PvGM1gr4ABq5FTMJsSAfeytsFPGLlD0uXr4wuE7PMbCmbhbce(xR5SVtRGaBs6lfSCPJMkoc0O66Txp(xR56RvTKkqAbX(oX9mHaH)1Ao770kiWMK(sblx6EMqGqnfRnKAXrsk6q91Rb8VwZrjwTccSjPVuWYLUNzxV9mq7uQnfhnlrJShNan1I6k9IabIb8VwZH1WEy3ZSleiANsTP4OzjAK94eOPwuxPxeV8VwZH1WEy3Z0RzjO5OeRwH(LMX6oXvCUKJAiuuPeRwH(LMX4ABq1oLAtXrZs0i7XjqtTOUsViClkiqmG)1AoSg2d7EMqGyGzjO5OeRwH(LMXM4tCpnGO1Q1MXQ3aAKAaWe0ey5YjUIZLCudHIk9DTTe2NAkyMXg5VVSKLmga]] )


end