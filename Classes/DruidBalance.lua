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


    spec:RegisterPack( "Balance", 20190709.1800, [[dGuL5aqivv9iQk5ssfytePpjfQAusLoLuLvbvLEffQzrHClPcAxu6xqvgMuKJrv0YKcEMurttQqxtkKTrvGVrvPmoQc15KcL1rvi9oOQqMhuvDpOY(Ok5GufulKQkpKQGmrOQOUiuvK2OuOs9rPqLCsPqfRuk1mHQIyNuLAPqvH6PGmvQk2lH)kyWahM0IjQhJyYG6YO2SqFMigTuYPvSAOQGxtbZMk3gk7wLFdz4u0XPkelxYZrA6IUUQSDPQ(UQkJNQs15PQQ1lf18vv2Vsl8u4Jacwtw4Ddn5zJ1KV1uJz90JBYdAKVjGs)nzbKPsmOsyb0PySaYp1PhHfqMQ)oKcl8rarrVIWcOwzAs9O4HNKjB9KTeegE0b750CqhP0yIhDWi4jGKFJlBCoHSacwtw4Ddn5zJ1KV1uJz9036yJAQJci9LTqLacAW8qcOwdmmFczbemtjciFTa)uNEeEb4Z1BG32(AbTY0K6rXdpjt26jBjim8Od2ZP5GosPXep6GrWBB7Rf0(58Fb(MrlOHM8SXwqhUGgAYJ2zJ22BBFTapul9KWup622xlOdxGhggMHxaeYP1c8Jvm722xlOdxGhQLEsy4fKAjHZWexarPmDbjAbe)jooKAjHtQDB7Rf0HlaAWmDt0)f4HBMRj5fKLo5cCiKHNjDbDHrxJpxWJYl4Dhtykvl)xqFTgv2XlG6)LQV3ZUT91c6WfGpMXq9z4fGpz6Zo)xaK5utUac6GNCq3cIOAbEi2X0Cu3c8WUrYHXxIpAb(JEnENBbT0(8cMCbOAb(JEl4h6A85cOZr4f04Chx91KxWqxqRrslUwGznOAs)Tci3qtQWhbemh1Nlf(i82tHpciLKd6equKtRGmRyci(uzhdl8tKcVBq4JaIpv2XWc)eqKAsUgvaj)IrlrdZrSfJPZrxGxlWdeqkjh0jGmr5Gork8UtHpci(uzhdl8tarQj5AubK8lgTenmhX(mfqkjh0jGKDieCi(k)fPW7ok8raXNk7yyHFcisnjxJkGKFXOLOH5i2NPasj5GobKmxuUmmNerk8UrcFeq8PYogw4NaIutY1Oci5xmAjAyoI9zkGusoOtaPfrpoKOQ4lfPWBpq4JaIpv2XWc)eqKAsUgvaj)IrlrdZrSptbKsYbDci3iPvsd4dpyjy8LIu4TVj8raXNk7yyHFcisnjxJkGKFXOLOH5i2NPasj5GobuCkw2HqWIu4Thl8raXNk7yyHFcisnjxJkGKFXOLOH5i2NPasj5GobKEeMML6ce15ePW7gt4JaIpv2XWc)eqNIXciTzAlTuAiIUmGIbt0pUeqkjh0jG0MPT0sPHi6Yakgmr)4sarQj5Aube7rEJPjdB1MPT0sPHi6Yakgmr)4AbsxamkTyi0fNIT5qmmNKfiDbWO0sFxCk2MdXWCswG0f0Db)xqQo(slnzNtRq0PfB5tLDm8c((wamkT0KDoTcrNwSnhIH5KSGEIu4TNnj8raXNk7yyHFcisnjxJkG6UG)livhFPLMA5qfSLpv2XWl47BbYVy0stTCOc2(mxqVfiDbWO0IHqxCk2MdXWCswG0faJsl9DXPyBoedZjzbsxq3f8FbP64lT0KDoTcrNwSLpv2XWl47BbWO0st250keDAX2CigMtYc6jGusoOtaj5Pf8OxafdAZCHYwIu4TNEk8raXNk7yyHFcOtXybuoWmnrfwGGGzFxaPKCqNakhyMMOclqqWSVlGi1KCnQaI9iVX0KHT5aZ0evybccM9Drk82Zge(iG4tLDmSWpb0PySaYermWjDAMHdeeM5l1CqxaM7pewaPKCqNaYermWjDAMHdeeM5l1CqxaM7pewarQj5Aube7rEJPjdBnredCsNMz4abHz(snh0fG5(dHxG0faJslgcDXPyBoedZjzbsxamkT03fNIT5qmmNKfiDbDxW)fKQJV0st250keDAXw(uzhdVGVVfaJslnzNtRq0PfBZHyyojlONifE7zNcFeq8PYogw4Na6umwarBn95k0NpewOy3qeqkjh0jGOTM(Cf6ZhcluSBicisnjxJkGypYBmnzylT10NRqF(qyHIDdzbsxabHCWOFNLOH5i2IX05OlWRf0ztlq6c(Va5xmAjAyoI9zksH3E2rHpci(uzhdl8tarQj5AubebHCWOFNLOH5i2IX05OlWRf0ztciLKd6eqpkhMKXOIu4TNns4JaIpv2XWc)eqKAsUgvarqihm63zjAyoITymDo6c8AbD2Kasj5GobKSdHGdOyiBXb(ym)fPWBp9aHpci(uzhdl8tarQj5AubemkT03fNITfJPZrxGxlWZMwG0faJslgcDXPyBXy6C0f41c8SPfiDbDxW)fKQJV0st250keDAXw(uzhdVGVVfaJslnzNtRq0PfBlgtNJUaVwGNnTGElq6c(Va5xmAjAyoI9zUaPlO7cuAwQlyI(X1cW)cAOrl47BbeeYbJ(DwIgMJylgtNJUaVwqNnTGEciLKd6eqymgQ8pGIb3JmWb4IvmQifE7PVj8raPKCqNaY8vt0)5KeKDknfq8PYogw4NifE7Phl8raPKCqNaQgtthhMlqnvclG4tLDmSWprk82Zgt4Jasj5GobebDe(YstgoeDkglG4tLDmSWprk8UHMe(iG4tLDmSWpbePMKRrfqYVy0wmXGJP0qeve2(mxW33cYbJxa(xqJeqkjh0jGYwC4DYO3bhIOIWIu4DdEk8raPKCqNa6hQCW955cftrNEewaXNk7yyHFIu4Ddni8raPKCqNakIipkdh0M5AsoiZkMaIpv2XWc)ePW7g6u4Jasj5GobKKNwWJEbumOnZfkBjG4tLDmSWprk8UHok8raPKCqNakBHQJkG4tLDmSWprk8UHgj8raPKCqNa6Nw1GQakgy37ybeFQSJHf(jsH3n4bcFeq8PYogw4NaIutY1OcO)lq(fJwIgMJyFMlq6c6Ua5xmAXymu5FafdUhzGdWfRyu7ZCbFFlO7c6Uacc5Gr)olgJHk)dOyW9idCaUyfJAlgtNJUaVwqdnTGVVf8FbmLYhHTymgQ8pGIb3JmWb4IvmQftXhq1c6TaPlqndKwmXWcKUaLML6cMOFCTaVWTGo20c6TGElq6c6Ua5xmAXymu5FafdUhzGdWfRyu7ZCbFFlqndKwmXWc6TaPlagLw67ItX2IX05OlWRf4Xlq6cGrPfdHU4uSTymDo6c8AbE2WcKUGUlagLwAYoNwHOtl2wmMohDbETapybFFl4)cs1XxAPj7CAfIoTylFQSJHxqpbKsYbDcO5iADAoOtKcVBW3e(iG4tLDmSWpbePMKRrfq)xG8lgTenmhX(mxG0f0DbYVy0IXyOY)akgCpYahGlwXO2N5c((wq3f0DbeeYbJ(Dwmgdv(hqXG7rg4aCXkg1wmMohDbETGgAAbFFl4)cykLpcBXymu5FafdUhzGdWfRyulMIpGQf0BbsxGAgiTyIHfiDbknl1fmr)4AbEHBbDSPf0Bb9wG0f0Db)xG2mxtYw30ND(hOMtnPLpv2XWl47BbYVy06M(SZ)a1CQjTpZf0Bbsxq3faJsl9DXPyBXy6C0f41cAybsxamkTyi0fNIT5qmmNKfiDbDxamkT0KDoTcrNwSnhIH5KSGVVf8FbP64lT0KDoTcrNwSLpv2XWlO3c6jGusoOtaryhtZrDb1nsom(srk8Ubpw4JaIpv2XWc)eqKAsUgva1DbYVy0s0WCe7ZCbFFlGGqoy0VZs0WCeBXy6C0f41c6SPf0Bbsxaf50k8R0SLvndKwmXGasj5Gobu8v(hqXa7EhlsH3n0ycFeq8PYogw4NaIutY1OcOUlq(fJwIgMJyFMl47BbeeYbJ(DwIgMJylgtNJUaVwqNnTGElq6cuZaPftmiGusoOtafrfHdOy408vSifE3ztcFeqYVymCkglGOPwoublG4tLDmSWpbePMKRrfqYVy0stTCOc2wmMohDb4FbDUaPl4)cOiNwHFLMTSQzG0Ijgeqkjh0jGi6ryxq(fJIu4DNEk8raXNk7yyHFcisnjxJkG6Ua5xmAPPwoubBPPsmSa8VGoxW33cKFXOLMA5qfSTymDo6c8c3c84f0Bbsxa1KDUqQLeoPlWlClOVwJk7ylngsTKWjDbsxq3fKAjHtBoyCirb4HxGXlWZf0Bb47cOMSZfsTKWjDbETacIMlOdwqd2gjGusoOtartTIQZjsH3D2GWhbeFQSJHf(jGi1KCnQaQ7cs1XxAPPwoubB5tLDm8cKUGUlq(fJwAQLdvWwAQedla)lOZf89Ta5xmAPPwoubBlgtNJUaVWTGgTaPlq(fJwTi6nKG5Zr1YstLyyb4FbE8c6TGVVf8FbP64lT0ulhQGT8PYogEbsxq3fi)IrRwe9gsW85OAzPPsmSa8VapEbFFlq(fJwIgMJyFMlO3c6TaPlGAYoxi1scNuln1kQo3cW)c6R1OYo2sJHuljCsxG0fi)IrR7DAfymt0pUW4lT0ujgwGXlq(fJwkYPvGXmr)4cJV0stLyyb4FbDCbsxG8lgTuKtRaJzI(XfgFPLMkXWcW)c6CbsxG8lgTU3PvGXmr)4cJV0stLyyb4FbDUaPlO7c(VaTzUMKT0Sy1WCsc0ulQT0ZWc((wW)fi)IrlrdZrSpZf89TG)lWS4(wAQf9vs4f0BbFFli1scN2CW4qIcWdVa8JBbSVZKxYHCW4fGVlqPzPUGj6hxlOdwqhBAbFFl4)cOiNwHFLMTSQzG0Ijgeqkjh0jGOPw0xjHfPW7o7u4JaIpv2XWc)eqKAsUgvaj)IrlrdZrSpZfiDbYVy0s0WCeBXy6C0fG)fiHaBXuFFbsxG2mxtYwAwSAyojbAQf1w6zybsxamkTyi0fNITfJPZrxGxlOymDoQasj5Gobe9DXPyrk8UZok8raXNk7yyHFcisnjxJkGKFXOLOH5i2N5cKUa5xmAjAyoITymDo6cW)cKqGTyQVVaPlqBMRjzlnlwnmNKan1IAl9miGusoOtaHHqxCkwKcV7SrcFeq8PYogw4NaIutY1OcOIJftBPYoEbsxGAgiTyIHfiDbrhcvlO7csTKWPnhmoKOa8WlOdwq3f0WcW3fqnzNl0sPjVGElO3cW3fqnzNlKAjHt6c8c3ci84wq3feDiuTGUlOHf0blGAYoxi1scN0f0Bb47c802Of0BbgVGgwa(UaQj7CHuljCsxG0f0Dbut25cPws4KUaVwGNlW4fKQJV0M)MlGHqh1YNk7y4f89TayuAXqOlofBZHyyojlO3cKUGUl4)c0M5As2sZIvdZjjqtTO2spdl47Bb)xG8lgTenmhX(mxW33c(VaZI7BPVlofVGElq6c6Ua5xmAjAyoITymDo6c8AbfJPZrxW33c(Va5xmAjAyoI9zUGEciLKd6eq03fNIfqe)jooKAjHtQWBpfPW7o9aHpci(uzhdl8tarQj5AubuXXIPTuzhVaPlqndKwmXWcKUGOdHQf0DbPws40MdghsuaE4f0blO7cAyb47cOMSZfAP0KxqVf0Bb47cOMSZfsTKWjDbEHBbEWcKUGUl4)c0M5As2sZIvdZjjqtTO2spdl47Bb)xG8lgTenmhX(mxW33c(VaZI7BXqOlofVGElq6c6Ua5xmAjAyoITymDo6c8AbfJPZrxW33c(Va5xmAjAyoI9zUGEciLKd6eqyi0fNIfqe)jooKAjHtQWBpfPW7o9nHpci(uzhdl8tarQj5AubuXXIPTuzhVaPlqndKwmXWcKUGOdHQf0DbPws40MdghsuaE4f0blO7cAyb47cOMSZfAP0KxqVf0BbEHBbnAbsxq3f8FbAZCnjBPzXQH5KeOPwuBPNHf89TG)lq(fJwIgMJyFMl47Bb)xGzX9T0KDoTcrNw8c6jGusoOtart250keDAXciI)ehhsTKWjv4TNIu4DNESWhbeFQSJHf(jGi1KCnQasndKwmXGasj5Gob0X)cyi0jsH3D2ycFeq8PYogw4NaIutY1Oci1mqAXedciLKd6eqTuxmGHqNifE3XMe(iG4tLDmSWpbePMKRrfqQzG0Ijgeqkjh0jGIpNlGHqNifE3rpf(iG4tLDmSWpbePMKRrfqYVy0sroTcmMj6hxy8LwAQedla)lOZfiDbDxGAgiTyIHf89Ta5xmADVtRaJzI(XfgFPLMkXWcWTGoxqVfiDbDxq3fi)Ir7pTQbvbumWU3X2N5c((wG8lgTU3PvGXmr)4cJV0(mxW33cOMSZfsTKWjDbEHBbnSaPl4)cKFXOLICAfymt0pUW4lTpZf0Bbsxq3f8FbAZCnjBPzXQH5KeOPwuBPNHf89TG)lq(fJwIgMJyFMlO3c((wG2mxtYwAwSAyojbAQf1w6zybsxG8lgTenmhX(mxG0fywCFlf50k8R0S1c6jGusoOta5ENwbAwJbwKcV7ydcFeq8PYogw4NaIutY1OciTzUMKT0Sy1WCsc0ulQT0ZWcW)c6CbFFl4)cKFXOLOH5i2N5c((wW)fywCFlf50k8R0SLasj5Gobef50k8R0SLifE3Xof(iGusoOtarFxCkwaXNk7yyHFIuKciZIjimznf(i82tHpci(uzhdl8tKcVBq4JaIpv2XWc)ePW7of(iG4tLDmSWprk8UJcFeq8PYogw4NaczkGOCkGusoOta1xRrLDSaQV6ESaQJcO(AfofJfq0yi1scNurk8UrcFeq8PYogw4NaczkGuyybKsYbDcO(AnQSJfq9v3JfqEkG6Rv4umwarJHuljCsfqKAsUgvaPnZ1KSvlIEdjy(CuTS8PYogwKcV9aHpci(uzhdl8taHmfqkmSasj5GobuFTgv2XcO(Q7Xcipfq91kCkglGOXqQLeoPcisnjxJkGs1XxAPPwoubB5tLDmSifE7BcFeq8PYogw4NaczkGuyybKsYbDcO(AnQSJfq9v3JfqEkG6Rv4umwarJHuljCsfqKAsUgvaPnZ1KSLMfRgMtsGMArTLEgwGxlOHfiDbAZCnjB1IO3qcMphvllFQSJHfPWBpw4JaIpv2XWc)eqitbe9jlGusoOta1xRrLDSaQV6ESaYtbuFTcNIXciAmKAjHtQaIutY1OcO)livhFPn)nxadHoQLpv2XWIu4DJj8raPKCqNacdHodZfIOctaXNk7yyHFIu4TNnj8raPKCqNaYeLd6eq8PYogw4NifE7PNcFeqkjh0jGOiNwHFLMTeq8PYogw4NifPifq95IoOt4Ddn5zJ1KV1KVzBOPokG(P1nNeQaQXbZevjdVGgwGsYbDlWn0KA32ciQjteE7ztniGmluCCSaYxlWp1PhHxa(C9g4TTVwqRmnPEu8WtYKTEYwccdp6G9CAoOJuAmXJoye822(AbTFo)xGVz0cAOjpBSf0HlOHM8OD2OT922xlWd1spjm1JUT91c6Wf4HHHz4faHCATa)yfZUT91c6Wf4HAPNegEbPws4mmXfquktxqIwaXFIJdPws4KA32(AbD4cGgmt3e9FbE4M5AsEbzPtUahcz4zsxqxy014Zf8O8cE3XeMs1Y)f0xRrLD8cO(FP679SBBFTGoCb4JzmuFgEb4tM(SZ)fazo1KlGGo4jh0TGiQwGhIDmnh1TapSBKCy8L4JwG)OxJ35wqlTpVGjxaQwG)O3c(HUgFUa6CeEbno3XvFn5fm0f0AK0IRfywdQM0F72EB7RfGp13zYlz4fiZruXlGGWK1CbYSK5O2f4Hje2mPl4qxh2slS4ZTaLKd6OlaDo)TBBLKd6OwZIjimznXfDk1W2wj5GoQ1SycctwtJXHxeHG32kjh0rTMftqyYAAmo80Nem(snh0TT32(AbE4M5AsEb91Auzht32(Abkjh0rTMftqyYAAmo86R1OYo2OtXyCAZbk1O(Q7X40M5As2sZIvdZjjqtTO2spdBBFTaLKd6OwZIjimznnghE91AuzhB0PymoT5GAAuF19yCAZCnjB1IO3qcMphvlBPNHT922xlak1kQo3c6VaOul6RKWli1scNlG8sumUTvsoOJAnlMGWK10yC41xRrLDSrNIX4OXqQLeoPg1xDpgxh32kjh0rTMftqyYAAmo86R1OYo2OtXyC0yi1scNuJqM4uyyJ6RUhJZtJMioTzUMKTAr0BibZNJQLLpv2XWBBLKd6OwZIjimznnghE91AuzhB0PymoAmKAjHtQritCkmSr9v3JX5PrtexQo(sln1YHkylFQSJH32kjh0rTMftqyYAAmo86R1OYo2OtXyC0yi1scNuJqM4uyyJ6RUhJZtJMioTzUMKT0Sy1WCsc0ulQT0ZGxnivBMRjzRwe9gsW85OAz5tLDm82wj5GoQ1SycctwtJXHxFTgv2XgDkgJJgdPws4KAeYeh9jBuF19yCEA0eX9pvhFPn)nxadHoQLpv2XWBBLKd6OwZIjimznnghEyi0zyUqevyB7TTVwa0PM0wOCbLoWlq(fJm8cOPM0fiZruXlGGWK1CbYSK5Olqp4fywChAIYCojlyOlagDSDB7RfOKCqh1AwmbHjRPX4WJEQjTfkd0ut62wj5GoQ1SycctwtJXHNjkh0TTvsoOJAnlMGWK10yC4rroTc)knBTT32(Ab4t9DM8sgEbCFU8Fb5GXliBXlqjjQwWqxG2xhNk7y72wj5GokokYPvqMvSTTsYbDuJXHNjkh0z0eXj)IrlrdZrSfJPZr9Yd22kjh0rnghEYoecoeFL)gnrCYVy0s0WCe7ZCBRKCqh1yC4jZfLldZjXOjIt(fJwIgMJyFMBBLKd6OgJdpTi6XHevfFPrteN8lgTenmhX(m32kjh0rnghEUrsRKgWhEWsW4lnAI4KFXOLOH5i2N52wj5GoQX4Wlofl7qiyJMio5xmAjAyoI9zUTvsoOJAmo80JW0SuxGOoNrteN8lgTenmhX(m32BBFTape(mDBRKCqh1yC49OCysgZOtXyCAZ0wAP0qeDzafdMOFCz0eXXEK3yAYWwp9GgRtp7OuyuAXqOlofBZHyyojsHrPL(U4uSnhIH5KiT7)uD8LwAYoNwHOtl2YNk7y4VpyuAPj7CAfIoTyBoedZjP32wj5GoQX4WtYtl4rVakg0M5cLTmAI46(pvhFPLMA5qfSLpv2XWFFYVy0stTCOc2(m7jfgLwme6ItX2CigMtIuyuAPVlofBZHyyojs7(pvhFPLMSZPvi60IT8PYog(7dgLwAYoNwHOtl2MdXWCs6TTvsoOJAmo8EuomjJz0PymUCGzAIkSabbZ(Urteh7rEJPjdB90dAuJ8npyBRKCqh1yC49OCysgZOtXyCMiIboPtZmCGGWmFPMd6cWC)HWgnrCSh5nMMmS1tpW3AuJAKuyuAXqOlofBZHyyojsHrPL(U4uSnhIH5KiT7)uD8LwAYoNwHOtl2YNk7y4VpyuAPj7CAfIoTyBoedZjP32wj5GoQX4W7r5WKmMrNIX4OTM(Cf6ZhcluSBignrCSh5nMMmS1tpWJBSMAKucc5Gr)olrdZrSfJPZr9QZMK(x(fJwIgMJyFMBBLKd6OgJdVhLdtYyuJMiocc5Gr)olrdZrSfJPZr9QZM22kjh0rnghEYoecoGIHSfh4JX83OjIJGqoy0VZs0WCeBXy6CuV6SPTTsYbDuJXHhgJHk)dOyW9idCaUyfJA0eXbJsl9DXPyBXy6CuV8SjPWO0IHqxCk2wmMoh1lpBsA3)P64lT0KDoTcrNwSLpv2XWFFWO0st250keDAX2IX05OE5zt9K(x(fJwIgMJyFMs7Q0SuxWe9Jl83qJ((iiKdg97SenmhXwmMoh1RoBQ32wj5GoQX4WZ8vt0)5KeKDkn32kjh0rnghE1yA64WCbQPs4TTsYbDuJXHhbDe(YstgoeDkgVTvsoOJAmo8YwC4DYO3bhIOIWgnrCYVy0wmXGJP0qeve2(m)(YbJXFJ22kjh0rnghE)qLdUppxOyk60JWBBLKd6OgJdViI8OmCqBMRj5GmRyBBLKd6OgJdpjpTGh9cOyqBMlu2ABRKCqh1yC4LTq1r32kjh0rnghE)0QgufqXa7EhVT91cusoOJAmo8M74QVMSrteN2mxtYw30ND(hOMtnPLpv2XWs7sqihm63zNJO1P5GoBXy6Cu83W3hbHCWOFNLWoMMJ6cQBKCy8L2IX05O43Zg6TTvsoOJAmo8MJO1P5GoJMiU)YVy0s0WCe7ZuAx5xmAXymu5FafdUhzGdWfRyu7Z87RBxcc5Gr)olgJHk)dOyW9idCaUyfJAlgtNJ6vdn999NPu(iSfJXqL)bum4EKboaxSIrTyk(aQ6jvndKwmXGuLML6cMOFC5fUo2uVEs7k)IrlgJHk)dOyW9idCaUyfJAFMFFQzG0Ijg6jfgLw67ItX2IX05OE5XsHrPfdHU4uSTymDoQxE2G0UWO0st250keDAX2IX05OE5bFF)t1XxAPj7CAfIoTylFQSJH7TTvsoOJAmo8iSJP5OUG6gjhgFPrte3F5xmAjAyoI9zkTR8lgTymgQ8pGIb3JmWb4IvmQ9z(91TlbHCWOFNfJXqL)bum4EKboaxSIrTfJPZr9QHM(((ZukFe2IXyOY)akgCpYahGlwXOwmfFav9KQMbslMyqQsZsDbt0pU8cxhBQxpPD)RnZ1KS1n9zN)bQ5utA5tLDm83N8lgTUPp78pqnNAs7ZSN0UWO0sFxCk2wmMoh1RgKcJslgcDXPyBoedZjrAxyuAPj7CAfIoTyBoedZj577FQo(slnzNtRq0PfB5tLDmCVEBBLKd6OgJdV4R8pGIb29o2OjIRR8lgTenmhX(m)(iiKdg97SenmhXwmMoh1RoBQNukYPv4xPzlRAgiTyIHTTsYbDuJXHxeveoGIHtZxXgnrCDLFXOLOH5i2N53hbHCWOFNLOH5i2IX05OE1zt9KQMbslMyyBVT91cGm5dMl62wj5GoQX4WJOhHDb5xmA0PymoAQLdvWgnrCYVy0stTCOc2wmMohf)Dk9pf50k8R0SLvndKwmXW2wj5GoQX4WJMAfvNZOjIRR8lgT0ulhQGT0ujgWFNFFYVy0stTCOc2wmMoh1lCECpPut25cPws4K6fU(AnQSJT0yi1scNuPDtTKWPnhmoKOa8Wg7zp8LAYoxi1scNuViiA2bnyB02wj5GoQX4WJMArFLe2OjIRBQo(sln1YHkylFQSJHL2v(fJwAQLdvWwAQed4VZVp5xmAPPwoubBlgtNJ6fUgjv(fJwTi6nKG5Zr1YstLya)ECVVV)P64lT0ulhQGT8PYogwAx5xmA1IO3qcMphvllnvIb87XFFYVy0s0WCe7ZSxpPut25cPws4KAPPwr15WFFTgv2XwAmKAjHtQu5xmADVtRaJzI(XfgFPLMkXGXYVy0sroTcmMj6hxy8LwAQed4VJsLFXOLICAfymt0pUW4lT0ujgWFNsLFXO19oTcmMj6hxy8LwAQed4VtPD)RnZ1KSLMfRgMtsGMArTLEg(((l)IrlrdZrSpZVV)Mf33stTOVsc377l1scN2CW4qIcWdJFCSVZKxYHCWy8vPzPUGj6hxDqhB677pf50k8R0SLvndKwmXW2wj5GoQX4WJ(U4uSrteN8lgTenmhX(mLk)IrlrdZrSfJPZrXVecSft9DPAZCnjBPzXQH5KeOPwuBPNbPWO0IHqxCk2wmMoh1RIX05OBBLKd6OgJdpme6ItXgnrCYVy0s0WCe7ZuQ8lgTenmhXwmMohf)siWwm13LQnZ1KSLMfRgMtsGMArTLEg22BBFTa8zKp0TTsYbDuJXHh9DXPyJi(tCCi1scNuCEA0eXvCSyAlv2XsvZaPftmin6qOQBQLeoT5GXHefGhUd62a(snzNl0sPj3Rh(snzNlKAjHtQx4i846gDiu1THoGAYoxi1scN0E4RN2g1Z4gWxQj7CHuljCsL2LAYoxi1scNuV804uD8L283Cbme6Ow(uzhd)9bJslgcDXPyBoedZjPN0U)1M5As2sZIvdZjjqtTO2spdFF)LFXOLOH5i2N533FZI7BPVlof3tAx5xmAjAyoITymDoQxfJPZr)((l)IrlrdZrSpZEBBLKd6OgJdpme6ItXgr8N44qQLeoP480OjIR4yX0wQSJLQMbslMyqA0Hqv3uljCAZbJdjkapCh0Tb8LAYoxOLstUxp8LAYoxi1scNuVW5bs7(xBMRjzlnlwnmNKan1IAl9m899x(fJwIgMJyFMFF)nlUVfdHU4uCpPDLFXOLOH5i2IX05OEvmMoh977V8lgTenmhX(m7TTvsoOJAmo8Oj7CAfIoTyJi(tCCi1scNuCEA0eXvCSyAlv2XsvZaPftmin6qOQBQLeoT5GXHefGhUd62a(snzNl0sPj3RNx4AK0U)1M5As2sZIvdZjjqtTO2spdFF)LFXOLOH5i2N533FZI7BPj7CAfIoT4EB7TTVwqJl(4stur32kjh0rnghEh)lGHqNrteNAgiTyIHTTsYbDuJXHxl1fdyi0z0eXPMbslMyyBRKCqh1yC4fFoxadHoJMio1mqAXedBBLKd6OgJdp370kqZAmWgnrCYVy0sroTcmMj6hxy8LwAQed4VtPDvZaPftm89j)IrR7DAfymt0pUW4lT0ujgW1zpPD7k)Ir7pTQbvbumWU3X2N53N8lgTU3PvGXmr)4cJV0(m)(OMSZfsTKWj1lCni9V8lgTuKtRaJzI(XfgFP9z2tA3)AZCnjBPzXQH5KeOPwuBPNHVV)YVy0s0WCe7ZS33N2mxtYwAwSAyojbAQf1w6zqQ8lgTenmhX(mLAwCFlf50k8R0SvVTTsYbDuJXHhf50k8R0SLrteN2mxtYwAwSAyojbAQf1w6za)D(99x(fJwIgMJyFMFF)nlUVLICAf(vA2ABVT91cACRox2QEliIQfGH6Zy8LBBLKd6OgJdp67ItXIuKcb]] )


end